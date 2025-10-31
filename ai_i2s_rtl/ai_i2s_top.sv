
`include "/proj/repo/user/vaibhavb/ai_i2s_rtl/ai_i2s_wb_if.sv"
`include "/proj/repo/user/vaibhavb/ai_i2s_rtl/ai_i2s_clkgen.sv"
`include "/proj/repo/user/vaibhavb/ai_i2s_rtl/ai_i2s_irq_ctrl.sv"
`include "/proj/repo/user/vaibhavb/ai_i2s_rtl/ai_i2s_sync_fifo.sv"
`include "/proj/repo/user/vaibhavb/ai_i2s_rtl/ai_i2s_bit_serializer.sv"
`include "/proj/repo/user/vaibhavb/ai_i2s_rtl/ai_i2s_bit_deserializer.sv"
`include "/proj/repo/user/vaibhavb/ai_i2s_rtl/ai_i2s_tx_block.sv"
`include "/proj/repo/user/vaibhavb/ai_i2s_rtl/ai_i2s_rx_block.sv"


module ai_i2s_top #(
    parameter ADDR_WIDTH = 32,    
    parameter DATA_WIDTH = 32     
)(
    input  logic        wb_clk_i,
    input  logic        wb_rst_i,
    input  logic        wb_we_i,
    input  logic        wb_stb_i,
    input  logic        wb_cyc_i,
    input  logic [DATA_WIDTH-1:0] wb_dat_i,   
    input  logic [ADDR_WIDTH-1:0] wb_adr_i,    
    input  logic        wb_sel_i,
    output logic        wb_ack_o,
    output logic [DATA_WIDTH-1:0] wb_dat_o,  
    
    // CTI/BTE signals 
    input  logic [2:0]  wb_cti_i,       // Cycle type identifier
    input  logic [1:0]  wb_bte_i,       // Burst type extension
    
    input  logic        is_tx_selected,
    input  logic        master_mode_tx,
    input  logic        master_mode_rx,
    output logic        i2s_sck,
    output logic        i2s_ws,
    output logic        i2s_sd_out,
    input  logic        i2s_sd_in,
    input  logic        i2s_sck_in,
    input  logic        i2s_ws_in,
    output logic        irq_o,
    input  logic        tx_data_valid,
    input  logic [DATA_WIDTH-1:0] tx_data,     
    output logic        tx_data_ready,
    output logic        rx_data_valid,
    output logic [DATA_WIDTH-1:0] rx_data,        
    input  logic        rx_data_ready
);

    // Internal signals 
    logic [7:0]  ratio_tx, ratio_rx;
    logic [5:0]  resolution_tx, resolution_rx;
    logic        en_tx, en_rx;
    logic        int_en_tx, int_en_rx;
    logic        lswap_tx, lswap_rx;
    logic        master_tx, master_rx;
    logic [1:0]  intmask_tx, intmask_rx;
    logic [1:0]  intstat_tx, intstat_rx;
    logic [1:0]  intclr_tx, intclr_rx;

    // Sample buffer signals 
    logic        sample_buffer_access;
    logic        sample_buffer_wr;
    logic        sample_buffer_rd;
    logic [ADDR_WIDTH-1:0] sample_buffer_addr;     
    logic [DATA_WIDTH-1:0] sample_buffer_data_out; 
    logic [DATA_WIDTH-1:0] sample_buffer_data_in;  

    // Clock and timing signals 
    logic        clk_en_tx, clk_en_rx;
    logic        sck_tx, ws_tx, sck_rx, ws_rx;
    logic        actual_sck, actual_ws;
    logic        final_clk_en;

    // FIFO signals 
    logic        tx_fifo_wr_en, rx_fifo_rd_en;
    logic        tx_fifo_full, rx_fifo_empty;
    logic        tx_fifo_empty, rx_fifo_full;
    logic        tx_fifo_rd_en;
    logic        tx_serializer_busy;
    logic [DATA_WIDTH-1:0] effective_tx_data;     

    // interrupt signals 
    logic        tx_lower_half_empty, tx_upper_half_empty;
    logic        rx_lower_half_filled, rx_upper_half_filled;

    // TX control signals
    logic        tx_buffer_has_data;
    logic        tx_fifo_load_request;

    // Wishbone Interface
    ai_i2s_wb_if #(
        .ADDR_WIDTH(ADDR_WIDTH),    
        .DATA_WIDTH(DATA_WIDTH)     
    ) u_wb_if (
        .clk             (wb_clk_i),
        .rst_n           (~wb_rst_i),
        .wb_we_i         (wb_we_i),
        .wb_stb_i        (wb_stb_i),
        .wb_cyc_i        (wb_cyc_i),
        .wb_adr_i        (wb_adr_i),        
        .wb_dat_i        (wb_dat_i),       
        .wb_dat_o        (wb_dat_o),        
        .wb_ack_o        (wb_ack_o),
        .wb_sel_i        (wb_sel_i),
        
        
        .wb_cti_i        (wb_cti_i),
        .wb_bte_i        (wb_bte_i),
        
        .addr_width      (7'd32),           
        .is_tx_selected  (is_tx_selected),
        .master_mode_tx  (master_mode_tx),
        .master_mode_rx  (master_mode_rx),
        .ratio_tx        (ratio_tx),
        .resolution_tx   (resolution_tx),
        .en_tx           (en_tx),
        .int_en_tx       (int_en_tx),
        .lswap_tx        (lswap_tx),
        .master_tx       (master_tx),
        .intmask_tx      (intmask_tx),
        .intstat_tx      (intstat_tx),
        .intclr_tx       (intclr_tx),
        .ratio_rx        (ratio_rx),
        .resolution_rx   (resolution_rx),
        .en_rx           (en_rx),
        .int_en_rx       (int_en_rx),
        .lswap_rx        (lswap_rx),
        .master_rx       (master_rx),
        .intmask_rx      (intmask_rx),
        .intstat_rx      (intstat_rx),
        .intclr_rx       (intclr_rx),
        .sample_buffer_access   (sample_buffer_access),
        .sample_buffer_wr       (sample_buffer_wr),
        .sample_buffer_rd       (sample_buffer_rd),
        .sample_buffer_addr     (sample_buffer_addr),     
        .sample_buffer_data_out (sample_buffer_data_out), 
        .sample_buffer_data_in  (sample_buffer_data_in)   
    );

    // TX Clock Generator 
    ai_i2s_clkgen #(
        .RES_WIDTH(6),
        .RATIO_WIDTH(8)
    ) u_clkgen_tx (
        .clk         (wb_clk_i),
        .rst_n       (~wb_rst_i),
        .resolution  (resolution_tx),
        .ratio       (ratio_tx),
        .enable      (en_tx),
        .master_mode (master_tx),
        .i2s_sck     (sck_tx),
        .i2s_ws      (ws_tx),
        .clk_en      (clk_en_tx)
    );

    // RX Clock Generator
    ai_i2s_clkgen #(
        .RES_WIDTH(6),
        .RATIO_WIDTH(8)
    ) u_clkgen_rx (
        .clk         (wb_clk_i),
        .rst_n       (~wb_rst_i),
        .resolution  (resolution_rx),
        .ratio       (ratio_rx),
        .enable      (en_rx),
        .master_mode (master_rx),
        .i2s_sck     (sck_rx),
        .i2s_ws      (ws_rx),
        .clk_en      (clk_en_rx)
    );

    // Clock Muxing Logic 
    always_comb begin
        if (master_tx & en_tx) begin
            actual_sck    = sck_tx;
            actual_ws     = ws_tx;
            i2s_sck       = sck_tx;
            i2s_ws        = ws_tx;
        end else if (master_rx & en_rx & ~(master_tx & en_tx)) begin
            actual_sck    = sck_rx;
            actual_ws     = ws_rx;
            i2s_sck       = sck_rx;
            i2s_ws        = ws_rx;
        end else begin
            actual_sck    = i2s_sck_in;
            actual_ws     = i2s_ws_in;
            i2s_sck       = 1'bz;
            i2s_ws        = 1'bz;
        end
    end

   // Generate clk_en for slave mode 
logic sck_in_d;
logic slave_clk_en;

always_ff @(posedge wb_clk_i or posedge wb_rst_i) begin
    if (wb_rst_i) begin
        sck_in_d <= 1'b0;
    end else begin
        sck_in_d <= actual_sck;  
    end
end

assign slave_clk_en = sck_in_d & ~actual_sck; 
  
  
    // Final clk_en selection 
always_comb begin
    if (master_tx & en_tx) begin
        // TX Master mode - TX generates  clock 
        final_clk_en = clk_en_tx;
    end else if (master_rx & en_rx & ~en_tx) begin
        // RX Master only mode - RX generates clock 
        final_clk_en = clk_en_rx;
    end else if (master_rx & en_rx & en_tx & ~master_tx) begin
        //  RX Master + TX Slave mode 
        final_clk_en = slave_clk_en;
    end else if (~master_tx & ~master_rx & (en_tx | en_rx)) begin
        // Pure slave mode 
        final_clk_en = slave_clk_en;
    end else begin
        // Disable state
        final_clk_en = 1'b0;
    end
end
    // ========================================================================
    // SAMPLE BUFFER 
    // ========================================================================
    
    localparam BUFFER_SIZE_BYTES = 16;
    localparam BUFFER_SIZE_WORDS = BUFFER_SIZE_BYTES / (DATA_WIDTH/8);  
    localparam BUFFER_HALF_WORDS = BUFFER_SIZE_WORDS / 2;
    
    // Internal buffer uses DATA_WIDTH (not hardcoded 32-bit)
    logic [DATA_WIDTH-1:0] sample_buffer [0:BUFFER_SIZE_WORDS-1];  
    logic [$clog2(BUFFER_SIZE_WORDS):0] buffer_wr_ptr, buffer_rd_ptr;  //  Variable sizing
    
    logic [$clog2(BUFFER_HALF_WORDS+1)-1:0] lower_half_count;      //  Variable sizing
    logic [$clog2(BUFFER_HALF_WORDS+1)-1:0] upper_half_count;      //  Variable sizing
    
    logic tx_lower_half_empty_prev, tx_upper_half_empty_prev;
    logic rx_lower_half_filled_prev, rx_upper_half_filled_prev;

    // =======================================================================
    //  ADDRESS CALCULATION for Sample Buffer
    // =======================================================================
    
    // Calculate word address 
    function automatic [$clog2(BUFFER_SIZE_WORDS)-1:0] calc_word_addr(input [ADDR_WIDTH-1:0] addr);
        logic [ADDR_WIDTH-1:0] buffer_base;
        logic [ADDR_WIDTH-1:0] offset;
        
        // Calculate buffer base
        case (ADDR_WIDTH)
            32: buffer_base = 32'h80000000;
            24: buffer_base = 24'h800000;  
            16: buffer_base = 16'h8000;
            8:  buffer_base = 8'h10;
            default: buffer_base = 8'h10;
        endcase
        
        offset = addr - buffer_base;
        
        // Address calculation based on data width
        if (DATA_WIDTH == 32) begin
            return offset[3:2];  // Word-aligned (divide by 4)
        end else begin // DATA_WIDTH == 16
            return offset[2:1];  // Half-word aligned 
        end
    endfunction

    // TX Data Control Logic 
    always_comb begin
        tx_buffer_has_data = (lower_half_count > 0) || (upper_half_count > 0);
    end
    
    always_comb begin
        tx_fifo_load_request = en_tx && ~tx_fifo_full && 
                              (tx_buffer_has_data || tx_data_valid) &&
                              ~tx_serializer_busy;
    end
    
    always_comb begin
        if (tx_data_valid) begin
            effective_tx_data = tx_data;
            tx_data_ready = ~tx_fifo_full;
        end else begin
            effective_tx_data = sample_buffer[buffer_rd_ptr];
            tx_data_ready = 1'b0;
        end
    end
    
    always_comb begin
        tx_fifo_wr_en = tx_fifo_load_request;
    end
    
    always_comb begin
        tx_fifo_rd_en = ~tx_fifo_empty && ~tx_serializer_busy && en_tx;
    end

    // RX Data Control Logic
    always_comb begin
        rx_data_valid = ~rx_fifo_empty;
        rx_fifo_rd_en = rx_data_valid & rx_data_ready;
    end
    
    // Buffer Management
    always_ff @(posedge wb_clk_i or posedge wb_rst_i) begin
        if (wb_rst_i) begin
            for (int i = 0; i < BUFFER_SIZE_WORDS; i++) begin
                sample_buffer[i] <= '0;
            end
            
            buffer_wr_ptr <= '0;
            buffer_rd_ptr <= '0;
            lower_half_count <= '0;
            upper_half_count <= '0;
            
            tx_lower_half_empty_prev <= 1'b1;
            tx_upper_half_empty_prev <= 1'b1;
            rx_lower_half_filled_prev <= 1'b0;
            rx_upper_half_filled_prev <= 1'b0;
        end else begin
            tx_lower_half_empty_prev <= tx_lower_half_empty;
            tx_upper_half_empty_prev <= tx_upper_half_empty;
            rx_lower_half_filled_prev <= rx_lower_half_filled;
            rx_upper_half_filled_prev <= rx_upper_half_filled;
            
            // Sample buffer write 
            if (sample_buffer_wr) begin
                automatic logic [$clog2(BUFFER_SIZE_WORDS)-1:0] word_addr;
                word_addr = calc_word_addr(sample_buffer_addr);
                
                if (word_addr < BUFFER_SIZE_WORDS) begin
                    sample_buffer[word_addr] <= sample_buffer_data_out;  
                    
                    if (word_addr < BUFFER_HALF_WORDS) begin
                        if (lower_half_count < BUFFER_HALF_WORDS) begin
                            lower_half_count <= lower_half_count + 1'b1;
                        end
                    end else begin
                        if (upper_half_count < BUFFER_HALF_WORDS) begin
                            upper_half_count <= upper_half_count + 1'b1;
                        end
                    end
                end
            end
            
            if (tx_fifo_wr_en && ~tx_data_valid && tx_buffer_has_data) begin
                buffer_rd_ptr <= (buffer_rd_ptr == (BUFFER_SIZE_WORDS-1)) ? '0 : (buffer_rd_ptr + 1'b1);
                
                if (buffer_rd_ptr < BUFFER_HALF_WORDS) begin
                    if (lower_half_count > 0) begin
                        lower_half_count <= lower_half_count - 1'b1;
                    end
                end else begin
                    if (upper_half_count > 0) begin
                        upper_half_count <= upper_half_count - 1'b1;
                    end
                end
            end
            
            if (rx_data_valid && rx_data_ready) begin
                buffer_wr_ptr <= (buffer_wr_ptr == (BUFFER_SIZE_WORDS-1)) ? '0 : (buffer_wr_ptr + 1'b1);
                sample_buffer[buffer_wr_ptr] <= rx_data;
                
                if (buffer_wr_ptr < BUFFER_HALF_WORDS) begin
                    if (lower_half_count < BUFFER_HALF_WORDS) begin
                        lower_half_count <= lower_half_count + 1'b1;
                    end
                end else begin
                    if (upper_half_count < BUFFER_HALF_WORDS) begin
                        upper_half_count <= upper_half_count + 1'b1;
                    end
                end
            end
        end
    end
    
    // Sample buffer read 
    always_comb begin
        if (sample_buffer_rd) begin
            automatic logic [$clog2(BUFFER_SIZE_WORDS)-1:0] word_addr;
            word_addr = calc_word_addr(sample_buffer_addr);
            if (word_addr < BUFFER_SIZE_WORDS) begin
                sample_buffer_data_in = sample_buffer[word_addr];  
            end else begin
                sample_buffer_data_in = '0;
            end
        end else begin
            sample_buffer_data_in = '0;
        end
    end
    
    //  Interrupt Logic 
    always_comb begin
        tx_lower_half_empty = (lower_half_count == '0) && en_tx;
        tx_upper_half_empty = (upper_half_count == '0) && en_tx;
    end
    
    always_comb begin
        rx_lower_half_filled = (lower_half_count == BUFFER_HALF_WORDS) && en_rx;
        rx_upper_half_filled = (upper_half_count == BUFFER_HALF_WORDS) && en_rx;
    end

    // TX Block 
    ai_i2s_tx_block #(
        .DATA_WIDTH(DATA_WIDTH)            
    ) u_tx (
        .clk         (wb_clk_i),
        .rst_n       (~wb_rst_i),
        .tx_en       (en_tx),
        .resolution  (resolution_tx),
        .tswap       (lswap_tx),
        .master_mode (master_tx),
        .wr_en       (tx_fifo_wr_en),
        .wr_data     (effective_tx_data),
        .fifo_full   (tx_fifo_full),
        .fifo_empty  (tx_fifo_empty),
        .sck         (actual_sck),
        .ws          (actual_ws),
        .sd          (i2s_sd_out),
        .clk_en      (final_clk_en),
        .serializer_busy (tx_serializer_busy)
    );

    // RX Block 
    ai_i2s_rx_block #(
        .DATA_WIDTH(DATA_WIDTH)             
    ) u_rx (
        .clk         (wb_clk_i),
        .rst_n       (~wb_rst_i),
        .rx_en       (en_rx),
        .resolution  (resolution_rx),
        .tswap       (lswap_rx),
        .master_mode (master_rx),
        .rd_en       (rx_fifo_rd_en),
        .rd_data     (rx_data),
        .fifo_empty  (rx_fifo_empty),
        .fifo_full   (rx_fifo_full),
        .sd          (i2s_sd_in),
        .sck         (actual_sck),
        .ws          (actual_ws),
        .clk_en      (final_clk_en)
    );

    // IRQ Controllers 
    logic irq_tx, irq_rx;

    ai_i2s_irq_ctrl u_irq_ctrl_tx (
        .clk            (wb_clk_i),
        .rst_n          (~wb_rst_i),
        .irq_en         (int_en_tx),
        .intmask_high   (intmask_tx[1]),
        .intmask_low    (intmask_tx[0]),
        .high_buf_full  (tx_upper_half_empty),
        .low_buf_full   (tx_lower_half_empty),
        .intclr_high    (intclr_tx[1]),
        .intclr_low     (intclr_tx[0]),
        .irq_o          (irq_tx),
        .intstat_high   (intstat_tx[1]),
        .intstat_low    (intstat_tx[0])
    );

    ai_i2s_irq_ctrl u_irq_ctrl_rx (
        .clk            (wb_clk_i),
        .rst_n          (~wb_rst_i),
        .irq_en         (int_en_rx),
        .intmask_high   (intmask_rx[1]),
        .intmask_low    (intmask_rx[0]),
        .high_buf_full  (rx_upper_half_filled),
        .low_buf_full   (rx_lower_half_filled),
        .intclr_high    (intclr_rx[1]),
        .intclr_low     (intclr_rx[0]),
        .irq_o          (irq_rx),
        .intstat_high   (intstat_rx[1]),
        .intstat_low    (intstat_rx[0])
    );

    //  interrupt output
    always_comb begin
        irq_o = irq_tx | irq_rx;
    end

endmodule

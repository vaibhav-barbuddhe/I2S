

module ai_i2s_wb_if #(
    parameter ADDR_WIDTH = 32,    
    parameter DATA_WIDTH = 32     
)(
    input  logic        clk,
    input  logic        rst_n,

    // Wishbone interface signals 
    input  logic        wb_we_i,        
    input  logic        wb_stb_i,       
    input  logic        wb_cyc_i,       
    input  logic [ADDR_WIDTH-1:0] wb_adr_i,       
    input  logic [DATA_WIDTH-1:0] wb_dat_i,       
    output logic [DATA_WIDTH-1:0] wb_dat_o,    
    output logic        wb_ack_o,      
    input  logic        wb_sel_i,     
    
    
    input  logic [2:0]  wb_cti_i,       
    input  logic [1:0]  wb_bte_i,     

    // I2S control interface
    input  logic [6:0]  addr_width,   
    input  logic        is_tx_selected,
    input  logic        master_mode_tx,
    input  logic        master_mode_rx,

    // Configuration outputs 
    output logic [7:0]  ratio_tx,
    output logic [5:0]  resolution_tx,
    output logic        en_tx,
    output logic        int_en_tx,
    output logic        lswap_tx,
    output logic        master_tx,
    output logic [7:0]  ratio_rx,
    output logic [5:0]  resolution_rx,
    output logic        en_rx,
    output logic        int_en_rx,
    output logic        lswap_rx,
    output logic        master_rx,
    output logic [1:0]  intmask_tx,
    output logic [1:0]  intmask_rx,
    input  logic [1:0]  intstat_tx,
    input  logic [1:0]  intstat_rx,
    output logic [1:0]  intclr_tx,
    output logic [1:0]  intclr_rx,
    
    // Sample buffer access 
    output logic        sample_buffer_access,
    output logic        sample_buffer_wr,
    output logic        sample_buffer_rd,
    output logic [ADDR_WIDTH-1:0] sample_buffer_addr,
    output logic [DATA_WIDTH-1:0] sample_buffer_data_out,
    input  logic [DATA_WIDTH-1:0] sample_buffer_data_in
);

    
    // =======================================================================
    //  ADDRESS MAP 
    // =======================================================================
    
    // Address map constants 
    localparam [ADDR_WIDTH-1:0] ADDR_VERSION  = 0;
    localparam [ADDR_WIDTH-1:0] ADDR_CONFIG   = 1;
    localparam [ADDR_WIDTH-1:0] ADDR_INTMASK  = 2;
    localparam [ADDR_WIDTH-1:0] ADDR_INTSTAT  = 3;
    
    // Sample buffer base address 
    localparam [ADDR_WIDTH-1:0] SAMPLE_BUFFER_BASE = 
        (ADDR_WIDTH == 32) ? 32'h80000000 :      // 32-bit
        (ADDR_WIDTH == 24) ? 24'h800000 :        // 24-bit  
        (ADDR_WIDTH == 16) ? 16'h8000 :          // 16-bit
        (ADDR_WIDTH == 8)  ? 8'h10 :             // 8-bit
        32'h80000000;                            

    // =======================================================================
    // CTI/BTE Constants
    // =======================================================================
    localparam [2:0] CTI_CLASSIC       = 3'b000;
    localparam [2:0] CTI_INCR_BURST     = 3'b010;
    localparam [2:0] CTI_END_OF_BURST   = 3'b111;
    localparam [1:0] BTE_LINEAR         = 2'b00;

    // =======================================================================
    // DATA WIDTH CONVERSION
    // =======================================================================
    
    // Internal registers  32-bit always
    logic [31:0] config_reg_tx_internal;
    logic [31:0] config_reg_rx_internal;
    logic [1:0]  intmask_reg_tx;
    logic [1:0]  intmask_reg_rx;
    
   // Delayed acknowledge logic (By one Cycle)
    logic        pending_access;
    logic        pending_register_access;
    logic        pending_buffer_access;
    
    // Convert 32-bit internal to bus width
    function automatic [DATA_WIDTH-1:0] to_bus_width(input [31:0] data);
        case (DATA_WIDTH)
            16: return data[15:0];           // Lower 16 bits
            32: return data[31:0];           // Full 32 bits
            default: return data[DATA_WIDTH-1:0];
        endcase
    endfunction
    
    // Convert bus width to 32-bit internal
    function automatic [31:0] from_bus_width(input [DATA_WIDTH-1:0] data);
        logic [31:0] result;
        result = 32'h0;
        result[DATA_WIDTH-1:0] = data;
        return result;
    endfunction

    // =======================================================================
    // ADDRESS DECODE 
    // =======================================================================
    logic wr, rd, valid_access;
    logic is_sample_buffer_access, is_register_access;
    logic valid_cti_for_registers, valid_cti_for_buffer;
    logic valid_bte_for_burst;

    always_comb begin
        // Address space 
        case (ADDR_WIDTH)
            32, 24, 16: begin
                // Use MSB method for larger address 
                is_sample_buffer_access = wb_adr_i[ADDR_WIDTH-1];
                is_register_access = ~wb_adr_i[ADDR_WIDTH-1] & (wb_adr_i <= 3);
            end
            8: begin
                //  for 8-bit
                is_register_access = (wb_adr_i <= 3);
                is_sample_buffer_access = (wb_adr_i >= SAMPLE_BUFFER_BASE) & 
                                        (wb_adr_i < (SAMPLE_BUFFER_BASE + 16));
            end
            default: begin
                is_register_access = 1'b0;
                is_sample_buffer_access = 1'b0;
            end
        endcase
        
        // Basic access 
        valid_access = wb_stb_i & wb_cyc_i & wb_sel_i;
        wr = valid_access & wb_we_i;
        rd = valid_access & ~wb_we_i;
        
        // CTI/BTE
        valid_bte_for_burst = (wb_bte_i == BTE_LINEAR);
        
        case (wb_cti_i)
            CTI_CLASSIC: begin
                valid_cti_for_registers = 1'b1;
                valid_cti_for_buffer = 1'b1;
            end
            CTI_INCR_BURST, CTI_END_OF_BURST: begin
                valid_cti_for_registers = 1'b0;                    // No burst for registers
                valid_cti_for_buffer = valid_bte_for_burst;        //  linear burst Only
            end
            default: begin
                valid_cti_for_registers = 1'b1;                 
                valid_cti_for_buffer = 1'b1;
            end
        endcase
        
        // Sample buffer signals
        sample_buffer_access   = is_sample_buffer_access & valid_access & valid_cti_for_buffer;
        sample_buffer_wr       = is_sample_buffer_access & wr & valid_cti_for_buffer;
        sample_buffer_rd       = is_sample_buffer_access & rd & valid_cti_for_buffer;
        sample_buffer_addr     = wb_adr_i;
        sample_buffer_data_out = wb_dat_i;
    end

    // =======================================================================
    //  ACKNOWLEDGE GENERATION
    // =======================================================================
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wb_ack_o <= 1'b0;
            pending_access <= 1'b0;
            pending_register_access <= 1'b0;
            pending_buffer_access <= 1'b0;
        end else begin
            //  wb_ack_o gets value from pending_access
            wb_ack_o <= pending_access;
            
            // Check pending accesses for next cycle acknowledge
            pending_register_access <= is_register_access & valid_cti_for_registers;
            pending_buffer_access   <= is_sample_buffer_access & valid_cti_for_buffer;
            pending_access          <= valid_access & (pending_register_access | pending_buffer_access);
        end
    end

    // =======================================================================
    // REGISTER WRITE LOGIC 
    // =======================================================================
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            config_reg_tx_internal  <= 32'd0;
            config_reg_rx_internal  <= 32'd0;
            
            // Set default resolution to 16 bits for both modes
            config_reg_tx_internal[21:16] <= 6'd16;
            config_reg_rx_internal[21:16] <= 6'd16;
            
            intmask_reg_tx <= 2'd0;
            intmask_reg_rx <= 2'd0;
            intclr_tx      <= 2'b0;
            intclr_rx      <= 2'b0;
        end else begin
            // interrupt clear signals
            intclr_tx <= 2'b0;
            intclr_rx <= 2'b0;

            // Register writes 
            if (wr & is_register_access & valid_cti_for_registers) begin
                case (wb_adr_i)
                    ADDR_CONFIG: begin
                        logic [31:0] write_data;
                        write_data = from_bus_width(wb_dat_i);
                        
                        if (is_tx_selected) begin
                            config_reg_tx_internal[31:22] <= 10'b0;
                            
                            //  Handle resolution field with 16-bit 
                            if (DATA_WIDTH == 32) begin
                                // 32-bit resolution
                                config_reg_tx_internal[21:16] <= write_data[21:16];
                                config_reg_tx_internal[15:8]  <= write_data[15:8];
                            end else begin
                                // 16-bit mode:  only 16-bit resolution
                                config_reg_tx_internal[21:16] <= 6'd16;  
                                config_reg_tx_internal[15:8]  <= write_data[15:8]; 
                            end
                            
                            // Common fields 
                            config_reg_tx_internal[7:3]   <= 5'b0;
                            config_reg_tx_internal[2]     <= write_data[2];        // LSWAP
                            config_reg_tx_internal[1]     <= write_data[1];        // INT_EN
                            config_reg_tx_internal[0]     <= write_data[0];        // EN
                        end else begin
                            // RX configuration 
                            config_reg_rx_internal[31:22] <= 10'b0;
                            
                            if (DATA_WIDTH == 32) begin
                                // Allow any resolution
                                config_reg_rx_internal[21:16] <= write_data[21:16];
                                config_reg_rx_internal[15:8]  <= write_data[15:8];
                            end else begin
                                // 16-bit mode: only 16-bit resolution
                                config_reg_rx_internal[21:16] <= 6'd16;  
                                config_reg_rx_internal[15:8]  <= write_data[15:8];  
                            end
                            
                            config_reg_rx_internal[7:3]   <= 5'b0;
                            config_reg_rx_internal[2]     <= write_data[2];        // LSWAP
                            config_reg_rx_internal[1]     <= write_data[1];        // INT_EN
                            config_reg_rx_internal[0]     <= write_data[0];        // EN
                        end
                    end
                    
                    ADDR_INTMASK: begin
                        if (is_tx_selected) begin
                            intmask_reg_tx <= wb_dat_i[1:0];
                        end else begin
                            intmask_reg_rx <= wb_dat_i[1:0];
                        end
                    end
                    
                    ADDR_INTSTAT: begin
                        if (is_tx_selected) begin
                            intclr_tx <= wb_dat_i[1:0];
                        end else begin
                            intclr_rx <= wb_dat_i[1:0];
                        end
                    end
                    
                    default: begin
                        // VERSION register is read-only, other addresses ignored
                    end
                endcase
            end
        end
    end

    // =======================================================================
    // REGISTER READ LOGIC - Data width aware (unchanged timing)
    // =======================================================================
    always_comb begin
        wb_dat_o = '0;
        
        if (sample_buffer_access) begin
            wb_dat_o = sample_buffer_data_in;
        end else if (rd & is_register_access & valid_cti_for_registers) begin
            case (wb_adr_i)
                ADDR_VERSION: begin
                    wb_dat_o = to_bus_width(32'h00000001);
                end
                ADDR_CONFIG: begin
                    logic [31:0] config_data;
                    
                    if (is_tx_selected) begin
                        config_data = config_reg_tx_internal;
                    end else begin
                        config_data = config_reg_rx_internal;
                    end
                    
                    //  output based on data width 
                    wb_dat_o = to_bus_width(config_data);
                end
                ADDR_INTMASK: begin
                    logic [31:0] temp_data;
                    temp_data = 32'h0;
                    if (is_tx_selected) begin
                        temp_data[1:0] = intmask_reg_tx;
                    end else begin
                        temp_data[1:0] = intmask_reg_rx;
                    end
                    wb_dat_o = to_bus_width(temp_data);
                end
                ADDR_INTSTAT: begin
                    logic [31:0] temp_data;
                    temp_data = 32'h0;
                    if (is_tx_selected) begin
                        temp_data[1:0] = intstat_tx;
                    end else begin
                        temp_data[1:0] = intstat_rx;
                    end
                    wb_dat_o = to_bus_width(temp_data);
                end
                default: begin
                    wb_dat_o = '0;
                end
            endcase
        end
    end

    // =======================================================================
    // CONFIGURATION OUTPUTS
    // =======================================================================
    always_comb begin
        // TX configuration outputs with DATA_WIDTH=16 
        ratio_tx = config_reg_tx_internal[15:8];
        lswap_tx = config_reg_tx_internal[2];
        int_en_tx = config_reg_tx_internal[1];
        en_tx = config_reg_tx_internal[0];
        master_tx = master_mode_tx;
        
        //  resolution restriction at output level
        case (DATA_WIDTH)
            16: begin
                resolution_tx = 6'd16;  // 16-bit resolution when DATA_WIDTH=16
            end
            32: begin
                resolution_tx = config_reg_tx_internal[21:16];  //  configured resolution
            end
            default: begin
                resolution_tx = 6'd16;  // Default to 16-bit for other data widths
            end
        endcase
        
        // RX configuration outputs
        ratio_rx = config_reg_rx_internal[15:8];
        lswap_rx = config_reg_rx_internal[2];
        int_en_rx = config_reg_rx_internal[1];
        en_rx = config_reg_rx_internal[0];
        master_rx = master_mode_rx;
        
        if (DATA_WIDTH == 16) begin
            resolution_rx = 6'd16;  //  16-bit resolution 
        end else begin
            resolution_rx = config_reg_rx_internal[21:16];  // configured resolution
        end
        
        // Interrupt mask outputs 
        intmask_tx = intmask_reg_tx;
        intmask_rx = intmask_reg_rx;
    end

endmodule

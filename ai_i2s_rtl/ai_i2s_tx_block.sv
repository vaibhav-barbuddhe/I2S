
module ai_i2s_tx_block #(
    parameter DATA_WIDTH = 32       
)(
    input  logic        clk,
    input  logic        rst_n,
    input  logic        tx_en,
    input  logic [5:0]  resolution,  
    input  logic        tswap,
    input  logic        master_mode,

    input  logic        wr_en,
    input  logic [DATA_WIDTH-1:0] wr_data,  
    output logic        fifo_full,
    output logic        fifo_empty,

    input  logic        clk_en,
    input  logic        sck,
    input  logic        ws,

    output logic        sd,
    output logic        serializer_busy
);

    // FIFO signals 
    logic [DATA_WIDTH-1:0] fifo_dout;    
    logic        fifo_rd_en;

    // Serializer 
    logic        load_data;
    logic [DATA_WIDTH-1:0] data_in_effective;  
    logic [5:0]  actual_bits;

    // FIFO instance 
    ai_i2s_sync_fifo #(
        .DATA_WIDTH(DATA_WIDTH),               
        .DEPTH(16)
    ) u_tx_fifo (
        .clk      (clk),
        .rst_n    (rst_n),
        .wr_en    (wr_en),
        .wr_data  (wr_data),
        .full     (fifo_full),
        .rd_en    (fifo_rd_en),
        .rd_data  (fifo_dout),
        .empty    (fifo_empty)
    );

    //  resolution range 16-32
    always_comb begin
        if (resolution >= 6'd16 && resolution <= 6'd32) begin
            actual_bits = resolution;
        end else begin
            actual_bits = 6'd16; // Default to 16-bit
        end
    end

    // Channel swap logic 
    always_comb begin
        if (DATA_WIDTH == 32) begin
            // 32-bit left/right channel swap
            data_in_effective = tswap ? {fifo_dout[15:0], fifo_dout[31:16]} : fifo_dout;
        end else if (DATA_WIDTH == 16) begin
          // For 16-bit data width, no channel swap (single channel)
            data_in_effective = fifo_dout;
        end else begin
            // For other widths
            data_in_effective = fifo_dout;
        end
    end

    // Load control logic
    always_comb begin
        load_data  = (~fifo_empty & ~serializer_busy & tx_en);
        fifo_rd_en = load_data;
    end

    // Bit Serializer
    ai_i2s_bit_serializer #(
        .DATA_WIDTH(DATA_WIDTH)              
    ) u_serializer (
        .clk      (clk),
        .rst_n    (rst_n),
        .enable   (tx_en),
        .clk_en   (clk_en),
        .load     (load_data),
        .data_in  (data_in_effective),
        .num_bits (actual_bits),
        .bit_out  (sd),
        .busy     (serializer_busy)
    );

endmodule

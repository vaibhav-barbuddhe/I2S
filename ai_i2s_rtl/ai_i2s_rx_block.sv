
module ai_i2s_rx_block #(
    parameter DATA_WIDTH = 32        
)(
    input  logic        clk,
    input  logic        rst_n,
    input  logic        rx_en,
    input  logic [5:0]  resolution,  
    input  logic        tswap,
    input  logic        master_mode,

    input  logic        sck,
    input  logic        ws,
    input  logic        sd,
    input  logic        clk_en,

    input  logic        rd_en,
    output logic [DATA_WIDTH-1:0] rd_data, 
    output logic        fifo_empty,
    output logic        fifo_full
);

    // Deserializer signals 
    logic [DATA_WIDTH-1:0] deserializer_out;  
    logic        valid;
    logic [5:0]  actual_bits;
    logic [DATA_WIDTH-1:0] data_to_fifo;      

    //  resolution range 16-32
    always_comb begin
        if (resolution >= 6'd16 && resolution <= 6'd32) begin
            actual_bits = resolution;
        end else begin
            actual_bits = 6'd16; // Default to 16-bit 
        end
    end

    // Bit Deserializer 
    ai_i2s_bit_deserializer #(
        .DATA_WIDTH(DATA_WIDTH)             
    ) u_deserializer (
        .clk      (clk),
        .rst_n    (rst_n),
        .enable   (rx_en),
        .clk_en   (clk_en),
        .bit_in   (sd),
        .num_bits (actual_bits),
        .data_out (deserializer_out),
        .valid    (valid)
    );

    // Channel swap logic 
    always_comb begin
        if (DATA_WIDTH == 32) begin
            // Standard 32-bit 
            data_to_fifo = tswap ? {deserializer_out[15:0], deserializer_out[31:16]} : deserializer_out;
        end else if (DATA_WIDTH == 16) begin
          // For 16-bit data width, no channel swap (single channel)
            data_to_fifo = deserializer_out;
        end else begin
            // For other widths
            data_to_fifo = deserializer_out;
        end
    end

    // FIFO instance - PARAMETERIZED
    ai_i2s_sync_fifo #(
        .DATA_WIDTH(DATA_WIDTH),             
        .DEPTH(16)
    ) u_rx_fifo (
        .clk      (clk),
        .rst_n    (rst_n),
        .wr_en    (valid),
        .wr_data  (data_to_fifo),
        .full     (fifo_full),
        .rd_en    (rd_en),
        .rd_data  (rd_data),
        .empty    (fifo_empty)
    );

endmodule



module ai_i2s_bit_serializer #(
    parameter DATA_WIDTH = 32
)(
    input  logic                  clk,
    input  logic                  rst_n,
    input  logic                  enable,
    input  logic                  clk_en,
    input  logic                  load,
    input  logic [DATA_WIDTH-1:0] data_in,
    input  logic [5:0]            num_bits,
    output logic                  bit_out,
    output logic                  busy
);

    logic [DATA_WIDTH-1:0] shift_reg;
    logic [5:0]            bit_cnt;
    logic                  load_reg;

    // Register the load signal
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            load_reg <= 1'b0;
        end else begin
            load_reg <= load;
        end
    end

    // shift register and bit counter logic
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            shift_reg <= '0;
            bit_cnt   <= '0;
            bit_out   <= 1'b0;
        end else if (enable) begin
            if (load_reg & ~busy) begin
                shift_reg <= data_in;
                bit_cnt   <= '0;
                bit_out   <= data_in[DATA_WIDTH-1];
            end else if (clk_en & busy) begin
                shift_reg <= {shift_reg[DATA_WIDTH-2:0], 1'b0};
                bit_cnt   <= bit_cnt + 1'b1;
                // Update bit_out immediately on clk_en
                bit_out   <= shift_reg[DATA_WIDTH-2];
            end
        end else begin
            shift_reg <= '0;
            bit_cnt   <= '0;
            bit_out   <= 1'b0;
        end
    end

    // Busy logic
    always_comb begin
        busy <= (bit_cnt < num_bits) & enable;
    end

endmodule


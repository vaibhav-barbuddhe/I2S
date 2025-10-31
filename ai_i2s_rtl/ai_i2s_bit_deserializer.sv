

module ai_i2s_bit_deserializer #(
    parameter DATA_WIDTH = 32
)(
    input  logic                  clk,
    input  logic                  rst_n,
    input  logic                  enable,
    input  logic                  clk_en,
    input  logic                  bit_in,
    input  logic [5:0]            num_bits,
    output logic [DATA_WIDTH-1:0] data_out,
    output logic                  valid
);

    logic [DATA_WIDTH-1:0] shift_reg;
    logic [5:0]            bit_cnt;
    logic                  valid_reg;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            shift_reg <= '0;
            bit_cnt   <= '0;
            data_out  <= '0;
            valid_reg <= 1'b0;
        end else if (enable) begin
            valid_reg <= 1'b0;
            
            if (clk_en) begin
                shift_reg <= {shift_reg[DATA_WIDTH-2:0], bit_in};
                
                if (bit_cnt == (num_bits - 1'b1)) begin
                    bit_cnt   <= '0;
                    data_out  <= {shift_reg[DATA_WIDTH-2:0], bit_in};
                    valid_reg <= 1'b1;
                end else begin
                    bit_cnt <= bit_cnt + 1'b1;
                end
            end
        end else begin
            shift_reg <= '0;
            bit_cnt   <= '0;
            data_out  <= '0;
            valid_reg <= 1'b0;
        end
    end

    assign valid = valid_reg;

endmodule

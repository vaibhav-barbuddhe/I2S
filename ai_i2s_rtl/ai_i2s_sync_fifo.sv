
module ai_i2s_sync_fifo #(
    parameter DATA_WIDTH = 32,
    parameter DEPTH = 16
)(
    input  logic                    clk,
    input  logic                    rst_n,

    input  logic                    wr_en,
    input  logic [DATA_WIDTH-1:0]   wr_data,
    output logic                    full,

    input  logic                    rd_en,
    output logic [DATA_WIDTH-1:0]   rd_data,
    output logic                    empty
);

    localparam ADDR_WIDTH = $clog2(DEPTH);

    logic [DATA_WIDTH-1:0] mem [0:DEPTH-1];
    logic [ADDR_WIDTH-1:0] wr_ptr, rd_ptr;
    logic [ADDR_WIDTH:0]   fifo_cnt;

    // Write logic
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wr_ptr <= '0;
        end else if (wr_en & ~full) begin
            mem[wr_ptr] <= wr_data;
            wr_ptr      <= wr_ptr + 1'b1;
        end
    end

    // Read logic
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rd_ptr <= '0;
        end else if (rd_en & ~empty) begin
            rd_ptr <= rd_ptr + 1'b1;
        end
    end

    // Count logic
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            fifo_cnt <= '0;
        end else begin
            case ({wr_en & ~full, rd_en & ~empty})
                2'b10: fifo_cnt <= fifo_cnt + 1'b1;
                2'b01: fifo_cnt <= fifo_cnt - 1'b1;
                default: fifo_cnt <= fifo_cnt;
            endcase
        end
    end

    // Outputs
    always_comb begin
        rd_data <= mem[rd_ptr];
        full    <= (fifo_cnt == DEPTH[ADDR_WIDTH:0]);
        empty   <= (fifo_cnt == '0);
    end

endmodule




module ai_i2s_clkgen #(
    parameter RES_WIDTH  = 6,
    parameter RATIO_WIDTH = 8
)(
    input  logic                    clk,
    input  logic                    rst_n,
    input  logic [RES_WIDTH-1:0]   resolution,
    input  logic [RATIO_WIDTH-1:0] ratio,
    input  logic                    enable,
    input  logic                    master_mode,

    output logic                    i2s_sck,
    output logic                    i2s_ws,
    output logic                    clk_en
);

    // Internal signals
    logic [RATIO_WIDTH-1:0] clk_div_cnt;
    logic [RES_WIDTH:0]     sck_edge_cnt;    // Count SCK edges for WS generation
    logic                   sck_reg, ws_reg;
    logic                   sck_enable, ws_enable;
    logic                   sck_negedge, sck_posedge;
    logic [RATIO_WIDTH-1:0] ratio_plus_2;

    //  I2S spec formula: SCK = wb_clk / (2 * (RATIO + 2))
    assign ratio_plus_2 = ratio + 2'd2;

    // Clock Divider Logic: Generate SCK
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            clk_div_cnt <= '0;
            sck_reg     <= 1'b0;
        end else if (enable & master_mode) begin
            if (clk_div_cnt >= ratio_plus_2) begin
                clk_div_cnt <= '0;
                sck_reg     <= ~sck_reg;        // Toggle SCK
            end else begin
                clk_div_cnt <= clk_div_cnt + 1'b1;
            end
        end else begin
            clk_div_cnt <= '0;
            sck_reg     <= 1'b0;
        end
    end

    // Generate SCK edge detection
    logic sck_reg_d;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sck_reg_d <= 1'b0;
        end else begin
            sck_reg_d <= sck_reg;
        end
    end
    
    assign sck_negedge = sck_reg_d & ~sck_reg;   // Falling edge of SCK
    assign sck_posedge = ~sck_reg_d & sck_reg;   // Rising edge of SCK

    //  WS Generation - Toggle every 'resolution' SCK edges
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sck_edge_cnt <= '0;
            ws_reg       <= 1'b0;
        end else if (enable & master_mode) begin
            // Count on SCK falling edges 
            if (sck_negedge) begin
              if (sck_edge_cnt == (resolution - 1'b1)) begin
                    sck_edge_cnt <= '0;
                    ws_reg       <= ~ws_reg;        // Toggle WS every 'resolution' SCK edges
                end else begin
                    sck_edge_cnt <= sck_edge_cnt + 1'b1;
                end
            end
        end else if (~enable | ~master_mode) begin
            sck_edge_cnt <= '0;
            ws_reg       <= 1'b0;
        end
    end

    // Output control
    always_comb begin
        sck_enable <= master_mode & enable;
        ws_enable  <= master_mode & enable;
        
        i2s_sck <= sck_enable ? sck_reg : 1'bz;
        i2s_ws  <= ws_enable ? ws_reg : 1'bz;
        clk_en  <= sck_negedge & enable & master_mode;
    end

endmodule



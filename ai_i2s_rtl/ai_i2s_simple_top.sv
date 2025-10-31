
`include "/proj/repo/user/vaibhavb/ai_i2s_rtl/ai_i2s_top.sv"

module ai_i2s_simple_top #(
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

    
    input  logic [2:0]  wb_cti_i,       
    input  logic [1:0]  wb_bte_i,    

    input  logic        is_tx_access,

    // Master/Slave mode control inputs 
    input  logic        master_mode_tx,
    input  logic        master_mode_rx,

    output logic        i2s_sck,
    output logic        i2s_ws,
    output logic        i2s_sd_out,
    input  logic        i2s_sd_in,
    input  logic        i2s_sck_in,
    input  logic        i2s_ws_in,

    output logic        irq_o
);

    // =======================================================================
    // INSTANTIATE THE I2S CORE
    // =======================================================================
    
    
    ai_i2s_top #(
        .ADDR_WIDTH(ADDR_WIDTH),    
        .DATA_WIDTH(DATA_WIDTH)    
    ) u_i2s_core (
        .wb_clk_i        (wb_clk_i),
        .wb_rst_i        (wb_rst_i),
        .wb_we_i         (wb_we_i),
        .wb_stb_i        (wb_stb_i),
        .wb_cyc_i        (wb_cyc_i),
        .wb_dat_i        (wb_dat_i),        
        .wb_adr_i        (wb_adr_i),        
        .wb_sel_i        (wb_sel_i),
        .wb_ack_o        (wb_ack_o),
        .wb_dat_o        (wb_dat_o),        
        
        
        .wb_cti_i        (wb_cti_i),
        .wb_bte_i        (wb_bte_i),
        
        .is_tx_selected  (is_tx_access),
        .master_mode_tx  (master_mode_tx),       
        .master_mode_rx  (master_mode_rx),      
        .i2s_sck         (i2s_sck),
        .i2s_ws          (i2s_ws),
        .i2s_sd_out      (i2s_sd_out),
        .i2s_sd_in       (i2s_sd_in),
        .i2s_sck_in      (i2s_sck_in),
        .i2s_ws_in       (i2s_ws_in),
        .irq_o           (irq_o),
        
       
        .tx_data_valid   (1'b0),                           
        .tx_data         ({DATA_WIDTH{1'b0}}),             // Parameterized 
        .tx_data_ready   (),                               
        .rx_data_valid   (),                                
        .rx_data         (),                                
        .rx_data_ready   (1'b0)                           
    );

endmodule

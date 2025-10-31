interface i2s_wishbone_if(input bit wb_clk_i);
  
  logic wb_rst_i; //Will drive reset from driver itself
  logic wb_ack_o;
  logic [31:0] wb_adr_i;
  logic [1:0]  wb_bte_i;
  logic [2:0]  wb_cti_i;
  logic wb_cyc_i;
  logic [31:0] wb_dat_i;
  logic [31:0] wb_dat_o;
  logic wb_sel_i;
  logic wb_stb_i;
  logic wb_we_i;
  
  ////Acknowledgement
  logic rxm_ack;
  logic txs_ack; 
  logic rxs_ack;
  logic txm_ack;
  
  
  clocking wb_cb@(posedge wb_clk_i);
    default input #1 output #1;
    output wb_rst_i;
    output wb_adr_i;
    output wb_bte_i;
    output wb_cti_i;
    output wb_cyc_i;
    output wb_dat_i;
    output wb_sel_i;
    output wb_stb_i;
    output wb_we_i;
    
  endclocking
  
  clocking wb_mon@(posedge wb_clk_i);
    default input #1 output #1; 
    input wb_ack_o;
    input wb_adr_i;
    input wb_bte_i;
    input wb_cti_i;
    input wb_cyc_i;
    input wb_dat_i;
    input wb_dat_o;
    input wb_sel_i;
    input wb_stb_i;
    input wb_we_i;
    input rxm_ack;
    input txs_ack; 
    input rxs_ack;
    input txm_ack;
  
  endclocking
  
  modport WB_DRV(clocking wb_cb);
    modport WB_MON(clocking wb_mon);
      
      endinterface
    
    
    
    
    
  

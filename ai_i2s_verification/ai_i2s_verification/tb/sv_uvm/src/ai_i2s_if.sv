interface ai_i2s_if(input bit wb_clk_i);
  
  logic i2s_sd1;
  logic i2s_sck1;
  logic i2s_ws1;
  
  logic i2s_sd2;
  logic i2s_sck2;
  logic i2s_ws2;
  
  
  //Data Signals
  logic [31:0] txm_dat_i;
  logic [31:0] txs_dat_i;
  logic [31:0] rxm_dat_i;
  logic [31:0] rxs_dat_i;
  
  
  
  //Interrupts
  
  logic txm_int_o;
  logic txs_int_o;
  logic rxm_int_o;
  logic rxs_int_o;
  
  clocking tx_master_drv_cb@(posedge wb_clk_i);
    default input #1 output #1;
    input i2s_sd1;
    input i2s_sck1;
    input i2s_ws1;
    input txm_dat_i;
    input txm_int_o;
  endclocking
  
  clocking tx_master_mon_cb@(posedge wb_clk_i);
    default input #1 output #1;
    input i2s_sd1;
    input i2s_sck1;
    input i2s_ws1;
    input txm_dat_i;
    input txm_int_o;
  endclocking
  
  
  clocking rx_slave_drv_cb@(posedge wb_clk_i);
    default input #1 output #1;
    input rxs_int_o;
  endclocking
  
    
  clocking rx_slave_mon_cb@(posedge wb_clk_i);
    default input #1 output #1;
    input i2s_sd1;
    input i2s_sck1;
    input i2s_ws1;
    input rxs_dat_i;
    input rxs_int_o;
  endclocking
  
  clocking rx_master_drv_cb@(posedge wb_clk_i);
    default input #1 output #1;
    input i2s_sck2;
    input i2s_ws2;
 // output rxm_dat_i;
    input rxm_int_o;
  endclocking
  
  clocking rx_master_mon_cb@(posedge wb_clk_i);
    default input #1 output #1;
    input i2s_sck2;
    input i2s_ws2;
    input rxm_dat_i; 
    input rxm_int_o;
  endclocking
  
  clocking tx_slave_drv_cb@(posedge wb_clk_i);
    default input #1 output #1;
    input i2s_sd2;
    input txs_dat_i;
    input txs_int_o;
  endclocking
  
  clocking tx_slave_mon_cb@(posedge wb_clk_i);
    default input #1 output #1;
    input i2s_sd2;
    input txs_dat_i;
    input txs_int_o;
  endclocking
  
  modport TX_MASTER_DRV_MP(clocking tx_master_drv_cb);
    modport TX_MASTER_MON_MP(clocking tx_master_mon_cb);
      modport RX_SLAVE_DRV_MP(clocking rx_slave_drv_cb);
        modport RX_SLAVE_MON_MP(clocking rx_slave_mon_cb);
          modport RX_MASTER_DRV_MP(clocking rx_master_drv_cb);
            modport RX_MASTER_MON_MP(clocking rx_master_mon_cb);
              modport TX_SLAVE_DRV_MP(clocking tx_slave_drv_cb);
                modport TX_SLAVE_MON_MP(clocking tx_slave_mon_cb);
                  
                  endinterface
                  
  
  
  
    
  
  
    

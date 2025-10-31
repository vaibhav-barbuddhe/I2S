class ai_i2s_scoreboard extends uvm_scoreboard;

  `uvm_component_utils(ai_i2s_scoreboard)

  uvm_tlm_analysis_fifo#(ai_i2s_tx_xtn) tx_fifo[];
  uvm_tlm_analysis_fifo#(ai_i2s_rx_xtn) rx_fifo[];

  ai_i2s_tx_xtn tx_data;
  ai_i2s_rx_xtn rx_data;

  ai_i2s_tx_xtn tx_cov_data;
  ai_i2s_rx_xtn rx_cov_data;

  ai_i2s_env_config env_cfg;

  
  covergroup cg1;

  endgroup
  
  covergroup cg2; 
  
  endgroup

  extern function new(string name = "ai_i2s_scoreboard", uvm_component parent);
  extern function void build_phase(uvm_phase phase);
  extern task run_phase(uvm_phase phase);
  extern function void check_data(ai_i2s_tx_xtn xtn1, ai_i2s_rx_xtn xtn2);

endclass


function ai_i2s_scoreboard::new(string name = "ai_i2s_scoreboard", uvm_component parent);
  super.new(name, parent);
  cg1 = new();
  cg2 = new();

  tx_cov_data = new();
  rx_cov_data = new();
endfunction


function void ai_i2s_scoreboard::build_phase(uvm_phase phase);
  super.build_phase(phase);

  if (!uvm_config_db#(ai_i2s_env_config)::get(this, "", "ai_i2s_env_config", env_cfg))
    `uvm_fatal("SCOREBOARD CONFIG", "Cannot get config class in scoreboard")

  tx_fifo = new[env_cfg.no_of_trans_agent];
  foreach (tx_fifo[i])
  begin
    tx_fifo[i] = new($sformatf("tx_fifo[%0d]", i), this);
  end

  rx_fifo = new[env_cfg.no_of_recv_agent];
  foreach (rx_fifo[i])
  begin
    rx_fifo[i] = new($sformatf("rx_fifo[%0d]", i), this);
  end
endfunction


task ai_i2s_scoreboard::run_phase(uvm_phase phase);
  super.run_phase(phase);
  fork
    begin
	    
      forever begin
        tx_fifo[0].get(tx_data);
        $display("[SCOREBOARD] TX Monitor data received");
        tx_cov_data = tx_data;
        cg1.sample();
      end
    end

    begin
      forever begin
        rx_fifo[0].get(rx_data);
        $display("[SCOREBOARD] RX Monitor data received");
        rx_cov_data = rx_data;
        cg2.sample();

        check_data(tx_data, rx_data);
      end
      
    end
  join
endtask


function void ai_i2s_scoreboard::check_data(ai_i2s_tx_xtn xtn1, ai_i2s_rx_xtn xtn2);
  `uvm_info("SCOREBOARD", "Comparing TX and RX transactions", UVM_MEDIUM)

  /*

if (xtn1 == null || xtn2 == null) begin
    `uvm_error("SCOREBOARD", "Null pointer encountered in check_data: one of the transactions is null")
    return;
  end
  

  
  if (xtn1.tx_wb_addr !== xtn2.rx_wb_addr)
    begin
    `uvm_error("SCOREBOARD", $sformatf("Address Mismatch: TX=0x%0h, RX=0x%0h", xtn1.tx_wb_addr, xtn2.rx_wb_addr));
    end
  else
    begin
    `uvm_info("SCOREBOARD", $sformatf("Address Match: 0x%0h", xtn1.tx_wb_addr), UVM_LOW);
    end

  
  if (xtn1.tx_wb_cyc_i !== xtn2.rx_wb_cyc_i)
    begin
    `uvm_error("SCOREBOARD", $sformatf("CYC Mismatch: TX=%0b, RX=%0b", xtn1.tx_wb_cyc_i, xtn2.rx_wb_cyc_i));
    end
  
  
  if (xtn1.tx_wb_sel_i !== xtn2.rx_wb_sel_i)
    begin
    `uvm_error("SCOREBOARD", $sformatf("SEL Mismatch: TX=%0b, RX=%0b", xtn1.tx_wb_sel_i, xtn2.rx_wb_sel_i));
    end
  
  if (xtn1.tx_wb_stb_i !== xtn2.rx_wb_stb_i)
    begin
    `uvm_error("SCOREBOARD", $sformatf("STB Mismatch: TX=%0b, RX=%0b", xtn1.tx_wb_stb_i, xtn2.rx_wb_stb_i));
    end

  
  if (xtn1.tx_wb_bte !== xtn2.rx_wb_bte)
    begin
    `uvm_error("SCOREBOARD", $sformatf("BTE Mismatch: TX=%0b, RX=%0b", xtn1.tx_wb_bte, xtn2.rx_wb_bte));
    end

    
  if (xtn1.tx_wb_data_o !== xtn2.rx_wb_data_o)
    begin
    `uvm_error("SCOREBOARD", $sformatf("WB Data Out Mismatch: TX=0x%0h, RX=0x%0h", xtn1.tx_wb_data_o, xtn2.rx_wb_data_o));
    end
  else
    begin
    `uvm_info("SCOREBOARD", $sformatf("WB Data Out Match: 0x%0h", xtn1.tx_wb_data_o), UVM_LOW);
    end

  
  if (xtn1.txm_dat_i !== xtn2.rxm_dat_i)
    begin
    `uvm_error("SCOREBOARD", $sformatf("I2S Data Mismatch: TXM=0x%0h, RXM=0x%0h", xtn1.txm_dat_i, xtn2.rxm_dat_i));
    end
  else
    begin
    `uvm_info("SCOREBOARD", $sformatf("I2S Data Match: 0x%0h", xtn1.txm_dat_i), UVM_LOW);
    end

  if (xtn2.rxm_ack !== xtn2.txs_ack)
    begin
    `uvm_warning("SCOREBOARD", $sformatf("ACK Mismatch: TXM_ACK=%0b, TXS_ACK=%0b", xtn1.txm_ack, xtn2.txs_ack));
    end

  if (xtn1.rxs_ack !== xtn1.txm_ack)
    begin
    `uvm_warning("SCOREBOARD", $sformatf("ACK Mismatch: RXS_ACK=%0b, RXM_ACK=%0b", xtn1.rxs_ack, xtn2.rxm_ack));
    end

    */

  endfunction


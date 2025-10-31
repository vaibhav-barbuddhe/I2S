

class i2s_virtual_sequencer extends uvm_sequencer #(uvm_sequence_item);
  
  `uvm_component_utils(i2s_virtual_sequencer)
  
  i2s_tx_sequencer tx_seqrh[];
  i2s_rx_sequencer rx_seqrh[];
  
  ////create handle for other sequencers also///
  i2s_env_config e_cfg;
  
  extern function new(string name = "i2s_virtual_sequencer", uvm_component parent);
  extern function void build_phase(uvm_phase phase);
      
  endclass
    
    function i2s_virtual_sequencer::new(string name = "i2s_virtual_sequencer", uvm_component parent);
      super.new(name, parent);
    endfunction 
    
    function void i2s_virtual_sequencer::build_phase(uvm_phase phase);
      super.build_phase(phase);
      $display("Build Phase of Virtual Sequencer");
      
      if(!uvm_config_db #(i2s_env_config)::get(this,"","i2s_env_config", e_cfg))
        `uvm_fatal("V_CONFIG", "Cannot get config data in Virtual Sequencer")
        
        tx_seqrh  = new[e_cfg.no_of_trans_agent];
        rx_seqrh  = new[e_cfg.no_of_recv_agent];

      
    endfunction



class i2s_rx_agt_top extends uvm_env;
  
  `uvm_component_utils(i2s_rx_agt_top)
  
  i2s_env_config env_cfg;
  i2s_rx_agent rx_agth[];
  
  extern function new(string name = "i2s_rx_agt_top", uvm_component parent);
    extern function void build_phase(uvm_phase phase);
      
      endclass
      
      function i2s_rx_agt_top::new(string name = "i2s_rx_agt_top",uvm_component parent);
        super.new(name, parent);
      endfunction
      
      function void i2s_rx_agt_top::build_phase(uvm_phase phase);
        if(!uvm_config_db#(i2s_env_config)::get(this,"","i2s_env_config", env_cfg))
          `uvm_fatal("RX_AGT_TOP","Cannot get the config data in RX_AGT_TOP")
          
         rx_agth = new[env_cfg.no_of_recv_agent];
        
        foreach(rx_agth[i])
          begin
            rx_agth[i] = i2s_rx_agent::type_id::create($sformatf("rx_agth[%0d]", i),this);
          end
      endfunction
            
        

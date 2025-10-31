class i2s_rx_sequencer extends uvm_sequencer #(i2s_rx_xtn);
  
  `uvm_component_utils(i2s_rx_sequencer)
  
  extern function new(string name = "i2s_rx_sequencer", uvm_component parent);
    endclass
    
    function i2s_rx_sequencer::new(string name = "i2s_rx_sequencer", uvm_component parent);
      super.new(name,parent);
    endfunction

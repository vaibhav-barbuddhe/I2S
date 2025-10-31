class ai_i2s_rx_sequencer extends uvm_sequencer #(ai_i2s_rx_xtn);

	`uvm_component_utils(ai_i2s_rx_sequencer)

	extern function new(string name = "ai_i2s_rx_sequencer", uvm_component parent);
endclass

function ai_i2s_rx_sequencer::new(string name = "ai_i2s_rx_sequencer", uvm_component parent);
	super.new(name,parent);
endfunction

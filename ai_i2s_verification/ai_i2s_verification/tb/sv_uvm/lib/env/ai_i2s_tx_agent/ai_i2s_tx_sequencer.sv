class ai_i2s_tx_sequencer extends uvm_sequencer #(ai_i2s_tx_xtn);

	`uvm_component_utils(ai_i2s_tx_sequencer)

	extern function new(string name = "ai_i2s_tx_sequencer", uvm_component parent);
endclass

function ai_i2s_tx_sequencer::new(string name = "ai_i2s_tx_sequencer", uvm_component parent);
	super.new(name,parent);
endfunction

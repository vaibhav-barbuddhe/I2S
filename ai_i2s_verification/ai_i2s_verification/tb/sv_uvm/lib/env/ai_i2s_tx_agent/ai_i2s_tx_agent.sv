
class ai_i2s_tx_agent extends uvm_agent;

	`uvm_component_utils(ai_i2s_tx_agent)

	ai_i2s_tx_driver    tx_drvh;
	ai_i2s_tx_monitor   tx_monh;
	ai_i2s_tx_sequencer tx_seqrh;

	ai_i2s_trans_config trans_cfg;


	extern function new(string name = "ai_i2s_tx_agent", uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern function void connect_phase(uvm_phase phase);

endclass

function ai_i2s_tx_agent::new(string name = "ai_i2s_tx_agent", uvm_component parent);
	super.new(name, parent);
endfunction

function void ai_i2s_tx_agent::build_phase(uvm_phase phase);
	super.build_phase(phase);

	if(!uvm_config_db#(ai_i2s_trans_config)::get(this,"","ai_i2s_trans_config", trans_cfg))
		`uvm_fatal(get_full_name(), "Cannot get the config data in tx_agent")

	tx_monh = ai_i2s_tx_monitor::type_id::create("tx_monh", this);

	if(trans_cfg.is_active==UVM_ACTIVE)
	begin
		tx_seqrh = ai_i2s_tx_sequencer::type_id::create("tx_seqrh", this);
		tx_drvh  = ai_i2s_tx_driver::type_id::create("tx_drvh", this);
	end
endfunction

function void ai_i2s_tx_agent::connect_phase(uvm_phase phase);
	tx_drvh.seq_item_port.connect(tx_seqrh.seq_item_export);
endfunction

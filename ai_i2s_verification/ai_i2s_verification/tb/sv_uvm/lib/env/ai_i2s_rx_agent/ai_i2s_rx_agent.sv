
class ai_i2s_rx_agent extends uvm_agent;

	`uvm_component_utils(ai_i2s_rx_agent)

	ai_i2s_rx_driver   rx_drvh;
	ai_i2s_rx_monitor   rx_monh;
	ai_i2s_rx_sequencer rx_seqrh;

	ai_i2s_recv_config recv_cfg;


	extern function new(string name = "ai_i2s_rx_agent", uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern function void connect_phase(uvm_phase phase);

endclass

function ai_i2s_rx_agent::new(string name = "ai_i2s_rx_agent", uvm_component parent);
	super.new(name, parent);
endfunction

function void ai_i2s_rx_agent::build_phase(uvm_phase phase);
	super.build_phase(phase);

	if(!uvm_config_db#(ai_i2s_recv_config)::get(this,"","ai_i2s_recv_config", recv_cfg))
		`uvm_fatal(get_full_name(), "Cannot get the config data in rx_agent")

	rx_monh = ai_i2s_rx_monitor::type_id::create("rx_monh", this);

	if(recv_cfg.is_active==UVM_ACTIVE)
	begin
		rx_seqrh = ai_i2s_rx_sequencer::type_id::create("rx_seqrh", this);
		rx_drvh  = ai_i2s_rx_driver::type_id::create("rx_drvh", this);
	end
endfunction

function void ai_i2s_rx_agent::connect_phase(uvm_phase phase);
	rx_drvh.seq_item_port.connect(rx_seqrh.seq_item_export);
endfunction


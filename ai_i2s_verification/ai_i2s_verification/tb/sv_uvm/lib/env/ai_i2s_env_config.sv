class ai_i2s_env_config extends uvm_object;
	`uvm_object_utils(ai_i2s_env_config)

	bit has_i2s_trans_agent = 1;
	bit has_i2s_recv_agent = 1;
	bit has_i2s_scoreboard = 1;
	bit has_i2s_virtual_sequencer = 1;
	bit has_functional_coverage = 1;

	ai_i2s_trans_config trans_cfg[];
	ai_i2s_recv_config  recv_cfg[];

	int no_of_trans_agent = 1;
	int no_of_recv_agent = 1;

	int tx_agent_is_master = 1;
	int rx_agent_is_master = 1;

	extern function new(string name = "ai_i2s_env_config");
endclass

function ai_i2s_env_config::new(string name = "ai_i2s_env_config");
	super.new(name);
endfunction


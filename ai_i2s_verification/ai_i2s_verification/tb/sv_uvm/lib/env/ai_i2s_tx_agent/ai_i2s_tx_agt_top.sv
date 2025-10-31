

class ai_i2s_tx_agt_top extends uvm_env;

	`uvm_component_utils(ai_i2s_tx_agt_top)

	ai_i2s_env_config env_cfg;
	ai_i2s_tx_agent tx_agth[];

	extern function new(string name = "ai_i2s_tx_agt_top", uvm_component parent);
	extern function void build_phase(uvm_phase phase);

endclass

function ai_i2s_tx_agt_top::new(string name = "ai_i2s_tx_agt_top",uvm_component parent);
	super.new(name, parent);
endfunction

function void ai_i2s_tx_agt_top::build_phase(uvm_phase phase);
	if(!uvm_config_db#(ai_i2s_env_config)::get(this,"","ai_i2s_env_config", env_cfg))
		`uvm_fatal("TX_AGT_TOP","Cannot get the config data in TX_AGT_TOP")

	tx_agth = new[env_cfg.no_of_trans_agent];

	foreach(tx_agth[i])
	begin
		tx_agth[i] = ai_i2s_tx_agent::type_id::create($sformatf("tx_agth[%0d]", i),this);
	end
endfunction



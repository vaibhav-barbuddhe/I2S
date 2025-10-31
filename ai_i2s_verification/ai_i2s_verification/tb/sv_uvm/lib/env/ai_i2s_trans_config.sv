class ai_i2s_trans_config extends uvm_object;
	`uvm_object_utils(ai_i2s_trans_config)

	uvm_active_passive_enum is_active = UVM_ACTIVE;

	virtual ai_i2s_wishbone_if vif1;
	virtual ai_i2s_if          vif2;

	extern function new(string name = "ai_i2s_trans_config");

endclass

function ai_i2s_trans_config::new(string name = "ai_i2s_trans_config");
	super.new(name);
endfunction


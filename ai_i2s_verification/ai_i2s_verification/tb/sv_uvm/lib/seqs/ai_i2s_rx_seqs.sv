class ai_i2s_rx_seqs extends uvm_sequence#(ai_i2s_rx_xtn);

	`uvm_object_utils(ai_i2s_rx_seqs)

	extern function new(string name = "ai_i2s_rx_seqs");
endclass

function ai_i2s_rx_seqs::new(string name = "ai_i2s_rx_seqs");
	super.new(name);
endfunction




/////// Check version through Receiver (as master)//////




class ai_rx_ver_seqs extends ai_i2s_rx_seqs;

	`uvm_object_utils(ai_rx_ver_seqs)

	ai_i2s_env_config env_cfg;

	function new(string name = "ai_rx_ver_seqs");
		super.new(name);
	endfunction

	virtual task body;

	$display("=====RX REGISTER VERSION CHECK TEST======");
	if (!uvm_config_db#(ai_i2s_env_config)::get(null,get_full_name(), "ai_i2s_env_config",env_cfg)) 
		`uvm_fatal("RX_VER_SEQS", "Cannot get env_config from config DB")

begin

	req = ai_i2s_rx_xtn::type_id::create("req");
	req.rx_is_master = env_cfg.rx_agent_is_master;
	start_item(req);
	assert(req.randomize() with {rx_wb_addr==16'h0 &&
		rx_wb_we_i==1'b0 &&
		rx_wb_sel_i==1'b1;
	rx_wb_stb_i==1'b1;
	rx_wb_cyc_i==1'b1;
	rx_wb_cti == 3'b000;});
	finish_item(req);
end
      endtask
    endclass







    /////// Check Configuration register through Receiver (as master)//////


    class ai_rx_config_seqs extends ai_i2s_rx_seqs;

	    `uvm_object_utils(ai_rx_config_seqs)

	    ai_i2s_env_config env_cfg;

	    function new(string name = "ai_rx_config_seqs");
		    super.new(name);
	    endfunction

	    virtual task body;

	    bit [31:0] rx_cfg_val;

	    $display("=====RX CONFIGURATION CHECK TEST======");
	    if (!uvm_config_db#(ai_i2s_env_config)::get(null,get_full_name(), "ai_i2s_env_config",env_cfg)) 
		    `uvm_fatal("RX_CONFIG_SEQS", "Cannot get env_config from config DB")


	    rx_cfg_val = (32 << 16) | (8 << 8) | (0 << 2) | (1 << 1) | (1 << 0);

    begin

	    req = ai_i2s_rx_xtn::type_id::create("req");
	    req.rx_is_master = env_cfg.rx_agent_is_master;
	    start_item(req);
	    assert(req.randomize() with {rx_wb_addr==16'h01 &&
		    rx_wb_we_i==1'b1;
	    rx_wb_data_i ==rx_cfg_val;
	    rx_wb_sel_i==1'b1;
	    rx_wb_stb_i==1'b1;
	    rx_wb_cyc_i==1'b1;
	    rx_wb_cti == 3'b000;});
	    finish_item(req);

    end
      endtask
    endclass







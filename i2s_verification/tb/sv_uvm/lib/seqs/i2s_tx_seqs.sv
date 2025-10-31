class i2s_tx_seqs extends uvm_sequence#(i2s_tx_xtn);

	`uvm_object_utils(i2s_tx_seqs)



	extern function new(string name = "i2s_tx_seqs");
endclass

function i2s_tx_seqs::new(string name = "i2s_tx_seqs");
	super.new(name);
endfunction


/////// Check version through transmitter (as master)//////

class tx_ver_seqs extends i2s_tx_seqs;

	`uvm_object_utils(tx_ver_seqs)

	i2s_env_config env_cfg;

	function new(string name = "tx_ver_seqs");
		super.new(name);
	endfunction

	virtual task body;

	$display("=====TX REGISTER VERSION CHECK TEST======");
	if (!uvm_config_db#(i2s_env_config)::get(null,get_full_name(), "i2s_env_config",env_cfg)) 
		`uvm_fatal("TX_VER_SEQS", "Cannot get env_config from config DB")

begin

	req = i2s_tx_xtn::type_id::create("req");
	req.tx_is_master = (env_cfg.tx_agent_is_master);
	start_item(req);
	assert(req.randomize() with {tx_wb_addr==16'h0000 ; // FOR READING, READ from Sample Buffer, For that Make MSB = 1.
	tx_wb_we_i==1'b0 ;
	tx_wb_data_i == 32'h0;
	tx_wb_sel_i==1'b1;
	tx_wb_stb_i==1'b1;
	tx_wb_cyc_i==1'b1;
	tx_wb_bte  ==2'b00;
	tx_wb_cti == 3'b000;});
	finish_item(req);
end
      endtask
    endclass



    /////// Check Configuration register through transmitter (as master)//////

    class tx_config_seqs extends i2s_tx_seqs;

	    `uvm_object_utils(tx_config_seqs)

	    i2s_env_config env_cfg;

	    function new(string name = "tx_config_seqs");
		    super.new(name);
	    endfunction

	    virtual task body;

	    bit [31:0] cfg_val;

	    $display("=====TX CONFIGURATION CHECK TEST======");

	    if (!uvm_config_db#(i2s_env_config)::get(null,get_full_name(), "i2s_env_config",env_cfg)) 

		    `uvm_fatal("TX_CONFIG_SEQS", "Cannot get env_config from config DB")

	    cfg_val = (24 << 16) | (9 << 8) | (0 << 2) | (1 << 1) | (1 << 0); //Data for 24-bit Resolution = 32'h180903

	    //  cfg_val = 32'h200903; ////DATA FOR 32-bit Resolution
	    // RES field (bits 21:16) = 24-bit resolution , Shifting 24 by 16 puts it into bit position 16.,So bits 21:16 = 011000 (binary for 24).
	    // RATIO field (bits 15:8) = Clock divider = 1 + 9 = divide by 10,This should go into bits [15:8]., Shifting 9 by 8 bits places it in that range.
	    // TSWAP (bit 2) = 0 (Left on even addresses) , TSWAP = 0, Bit 2, shift by 2
	    // TINTEN (bit 1) = 1 (Interrupt enabled), TINTEN = 1,  goes into bit 1
	    // TXEN (bit 0) = 1 (Transmitter enabled), TXEN = 1,  goes into bit 0 (no shift needed)

    begin

	    req = i2s_tx_xtn::type_id::create("req");
	    req.tx_is_master = env_cfg.tx_agent_is_master;
	    start_item(req);
	    assert(req.randomize() with {tx_wb_addr==16'h0001;  //For only register access, address = 16'h0001, for buffer access, address = 16'h8000 (MSB Shuld be '1')
	    tx_wb_we_i==1'b1 ;
	    tx_wb_data_i== cfg_val;
	    tx_wb_sel_i==1'b1;
	    tx_wb_stb_i==1'b1;
	    tx_wb_cyc_i==1'b1;
	    tx_wb_bte  ==2'b00;
	    tx_wb_cti == 3'b000;});
	    finish_item(req);

	    #50;


	    start_item(req);
	    assert(req.randomize() with {tx_wb_addr==16'h0001;
	    tx_wb_we_i==1'b0;
	    tx_wb_sel_i==1'b1;
	    tx_wb_stb_i==1'b1;
	    tx_wb_cyc_i==1'b1;
	    tx_wb_bte  ==2'b00;
	    tx_wb_cti == 3'b000;});
	    finish_item(req);



    end
      endtask
    endclass



    //////////Filling transmitter buffer test////////////


    class tx_sample_buffer_write_seq  extends i2s_tx_seqs;

	    `uvm_object_utils(tx_sample_buffer_write_seq)

	    i2s_env_config env_cfg;

	    function new(string name = "tx_sample_buffer_write_seq");
		    super.new(name);
	    endfunction


	    virtual task body;

	    bit [31:0] addr;
	    bit [31:0] data;

	    $display("===== TX SAMPLE BUFFER WRITE SEQUENCE =====");

	    if (!uvm_config_db#(i2s_env_config)::get(null,get_full_name(), "i2s_env_config",env_cfg)) 
		    `uvm_fatal("TX_SAMPLE_BUFFER_WRITE_SEQS", "Cannot get env_config from config DB")

	    for (int i = 0; i < 32; i++)

	    begin
		    req = i2s_tx_xtn::type_id::create("req");
		    req.tx_is_master = env_cfg.tx_agent_is_master;

		    addr = 32'h1000_0020 + (i * 4);  ///addr starts from h1000_0020 and increment every 4 bytes
		    data = i + 1;                   ///writes value from 0 to 31

		    start_item(req);
		    assert(req.randomize() with {
			    tx_wb_addr   == addr;
		    tx_wb_data_i == data;
		    tx_wb_we_i   == 1'b1;
		    tx_wb_sel_i  == 1'b1;
		    tx_wb_stb_i  == 1'b1;
		    tx_wb_cyc_i  == 1'b1;
		    tx_wb_cti    == 3'b000; });
		    finish_item(req);
	    end
    endtask

endclass





































/////////////////// EXXTTTTTTTTRRRRRRRRRAAAAAAAAA //////////////////////////////   

class tx_config_seq extends i2s_tx_seqs;

	`uvm_object_utils(tx_config_seq)

	i2s_env_config env_cfg;

	function new(string name = "tx_config_seq");
		super.new(name);
	endfunction

	virtual task body;
	`uvm_info(get_type_name(), "Starting TX CONFIG SEQUENCE", UVM_MEDIUM)

	if (!uvm_config_db#(i2s_env_config)::get(null, get_full_name(), "i2s_env_config", env_cfg))
	begin
		`uvm_fatal(get_type_name(), "Cannot get env_config from config DB")
	end


	req = i2s_tx_xtn::type_id::create("req");


	req.tx_is_master = env_cfg.tx_agent_is_master;


	start_item(req);


	req.tx_wb_addr   = 16'h0001;      
	req.tx_wb_we_i   = 1'b1;          
	req.tx_wb_sel_i  = 1'b1;
	req.tx_wb_stb_i  = 1'b1;
	req.tx_wb_cyc_i  = 1'b1;
	req.tx_wb_cti    = 3'b000;

	// Bitfield config for tx_wb_data
	req.tx_wb_data_i         = 32'h00000000; // Default
	req.tx_wb_data_i[21:16]  = 6'd24;        // RES = 24 bits
	req.tx_wb_data_i[15:8]   = 8'd7;         // RATIO: bus_clk / (1+7) = divide by 8
	req.tx_wb_data_i[2]      = 1'b1;         // TSWAP: left channel on odd address
	req.tx_wb_data_i[1]      = 1'b1;         // TINTEN: interrupt enabled
	req.tx_wb_data_i[0]      = 1'b1;         // TXEN: transmitter enabled

	finish_item(req);

	`uvm_info(get_type_name(), "TX CONFIG SEQUENCE COMPLETED", UVM_MEDIUM)
endtask

endclass




/////////////************** FORCED VALUE SEQUENE**************************///////////////////



class tx_ver_force_seqs extends i2s_tx_seqs;

	`uvm_object_utils(tx_ver_force_seqs)

	i2s_env_config env_cfg;

	// Import DPI-C functions for HDL force and release
	//  import "DPI-C"  function int uvm_hdl_force(string path, logic [31:0] value);
	//  import "DPI-C" function int uvm_hdl_release(string path);

	function new(string name = "tx_ver_force_seqs");
		super.new(name);
	endfunction

	virtual task body;
	logic [31:0] zero_val = 32'h00000000;

	$display("========= TX REGISTER VERSION CHECK TEST ========");


	if (!uvm_config_db #(i2s_env_config)::get(null, get_full_name(), "i2s_env_config", env_cfg))
		`uvm_fatal("TX_VER_SEQS", "Cannot get env_config from config DB")

	// === Force unused signal values to 0 so data_out equals version_dout ===//
	if (!uvm_hdl_force("top.I2SRXS.config_dout", zero_val))
		`uvm_error("FORCE", "Failed to force top.I2SRXS.config_dout to 0")

	if (!uvm_hdl_force("top.I2SRXS.intmask_dout", zero_val))
		`uvm_error("FORCE", "Failed to force top.I2SRXS.intmask_dout to 0")

	if (!uvm_hdl_force("top.I2SRXS.intstat_dout", zero_val))
		`uvm_error("FORCE", "Failed to force top.I2SRXS.intstat_dout to 0")


	// === Perform Wishbone Read for version register === //
		req = i2s_tx_xtn::type_id::create("req");
		req.tx_is_master = env_cfg.tx_agent_is_master;

		start_item(req);

		assert(req.randomize() with {
			tx_wb_addr   == 16'h0000;
		tx_wb_we_i   == 1'b0;
		tx_wb_sel_i  == 1'b1;
		tx_wb_stb_i  == 1'b1;
		tx_wb_cyc_i  == 1'b1;
		tx_wb_bte    == 2'b00;
		tx_wb_cti    == 3'b000;
	});


	finish_item(req);

endtask

	endclass






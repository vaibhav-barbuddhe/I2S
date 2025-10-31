class i2s_base_vseq extends uvm_sequence#(uvm_sequence_item);

	`uvm_object_utils(i2s_base_vseq)

	i2s_tx_sequencer tx_seqrh[];
	i2s_rx_sequencer rx_seqrh[];  

	i2s_virtual_sequencer v_sequencer;

	i2s_env_config e_cfg;

	extern function new(string name = "i2s_base_vseq");
	extern task body();

endclass

function i2s_base_vseq::new(string name = "i2s_base_vseq");
	super.new(name);
endfunction

task i2s_base_vseq::body();
	if(!uvm_config_db #(i2s_env_config)::get(null,get_full_name(),"i2s_env_config",e_cfg))
		`uvm_fatal("I2S VIRTUAL SEQUENCE","cannot get() i2s_env_cfg from uvm_config_db. Have you set() it?")

	tx_seqrh = new[e_cfg.no_of_trans_agent];
	rx_seqrh = new[e_cfg.no_of_recv_agent];


	assert($cast(v_sequencer,m_sequencer))

	else
	begin
		`uvm_error("BODY","Casting Failed")
	end


	foreach(tx_seqrh[i])
	begin
		tx_seqrh[i] = v_sequencer.tx_seqrh[i]; 
	end


	foreach(rx_seqrh[i])
	begin
		rx_seqrh[i] = v_sequencer.rx_seqrh[i]; 
	end

endtask


///////////////////////////////////////////

///////Sequence For - Check version through transmitter (as master)//////

class vseq_tx_version extends i2s_base_vseq; 

	`uvm_object_utils(vseq_tx_version)

	tx_ver_seqs  seq1;

	function new(string name = "vseq_tx_version");
		super.new(name);
	endfunction

	task body();
		`uvm_info("I2S_VIRTUAL_SEQUNCE", "TX_VERSION_CHECK_SEQ", UVM_LOW)
		super.body();

		seq1 = tx_ver_seqs::type_id::create("seq1");

		foreach(tx_seqrh[i])
			seq1.start(tx_seqrh[i]);
	endtask
endclass


///////Sequence For - Configuration register write/read of transmitter (as master)//////

class vseq_config_tx_version extends i2s_base_vseq; 

	`uvm_object_utils(vseq_config_tx_version)

	tx_config_seqs  seq2;

	function new(string name = "vseq_config_tx_version");
		super.new(name);
	endfunction

	task body();
		`uvm_info("I2S_VIRTUAL_SEQUNCE", "TX_CONFIG_REG_SEQ", UVM_LOW)
		super.body();

		seq2 = tx_config_seqs::type_id::create("seq2");

		foreach(tx_seqrh[i])
			seq2.start(tx_seqrh[i]);
	endtask
endclass



///////Sequence For - Transmitter Buffer Full Check Sequence transmitter (as master)//////

class vseq_tx_buffer_check extends i2s_base_vseq; 

	`uvm_object_utils(vseq_tx_buffer_check)

	tx_sample_buffer_write_seq  seq3;

	function new(string name = "vseq_tx_buffer_check");
		super.new(name);
	endfunction

	task body();
		`uvm_info("I2S_VIRTUAL_SEQUNCE", "TX_BUFFER_CHECK_SEQ", UVM_LOW)
		super.body();

		seq3 = tx_sample_buffer_write_seq::type_id::create("seq3");

		foreach(tx_seqrh[i])
			seq3.start(tx_seqrh[i]);
	endtask
endclass


//////////////EEEEXXXXXXXXTTTTTTTRRRRRRAAAAAA////////////

class vseq_config extends i2s_base_vseq; 

	`uvm_object_utils(vseq_config)

	tx_config_seq  seq4;

	function new(string name = "vseq_config");
		super.new(name);
	endfunction

	task body();
		`uvm_info("I2S_VIRTUAL_SEQUNCE", "TX_CONFIG_EXTRA", UVM_LOW)
		super.body();

		seq4 = tx_config_seq::type_id::create("seq4");

		foreach(tx_seqrh[i])
			seq4.start(tx_seqrh[i]);
	endtask
endclass


///////////////// SEQUENCE FOR RECEIVER VERSION REGISTER CHECK//////////////



class vseq_rx_version extends i2s_base_vseq; 

	`uvm_object_utils(vseq_rx_version)

	rx_ver_seqs  rx_seq1;

	function new(string name = "vseq_rx_version");
		super.new(name);
	endfunction

	task body();
		`uvm_info("I2S_VIRTUAL_SEQUNCE", "RX_VERSION_CHECK_SEQ", UVM_LOW)
		super.body();

		rx_seq1 = rx_ver_seqs::type_id::create("rx_seq1");

		foreach(rx_seqrh[i])
			rx_seq1.start(rx_seqrh[i]);
	endtask
endclass




///////Sequence For - Configuration register write/read of Receiver (as master)//////


class vseq_config_rx_version extends i2s_base_vseq; 

	`uvm_object_utils(vseq_config_rx_version)

	rx_config_seqs  rx_seq2;

	function new(string name = "vseq_config_rx_version");
		super.new(name);
	endfunction

	task body();
		`uvm_info("I2S_VIRTUAL_SEQUNCE", "RX_CONFIG_REG_SEQ", UVM_LOW)
		super.body();

		rx_seq2 = rx_config_seqs::type_id::create("rx_seq2");

		foreach(rx_seqrh[i])
			rx_seq2.start(rx_seqrh[i]);
	endtask
endclass




//////////////// *********** FOR FORCED SEQUENCE **************//////


///////Sequence For - Check version through transmitter (as master)//////

class vseq_tx_force_version extends i2s_base_vseq; 

	`uvm_object_utils(vseq_tx_force_version)

	tx_ver_force_seqs  force_seq1;

	function new(string name = "vseq_tx_force_version");
		super.new(name);
	endfunction

	task body();
		`uvm_info("I2S_VIRTUAL_SEQUNCE", "TX_VERSION_FORCE_CHECK_SEQ", UVM_LOW)
		super.body();

		force_seq1 = tx_ver_force_seqs::type_id::create("force_seq1");

		foreach(tx_seqrh[i])
			force_seq1.start(tx_seqrh[i]);
	endtask
endclass



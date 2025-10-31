
class ai_i2s_base_test extends uvm_test;
	`uvm_component_utils(ai_i2s_base_test)


	ai_i2s_env envh;
	ai_i2s_env_config m_tb_cfg;
	ai_i2s_trans_config trans_cfg[];
	ai_i2s_recv_config  recv_cfg[];

	bit has_i2s_trans_agent = 1;
	bit has_i2s_recv_agent = 1;
	bit has_i2s_scoreboard = 1;
	bit has_i2s_virtual_sequencer = 1;
	bit has_functional_coverage = 1;

	int no_of_trans_agent = 1;
	int no_of_recv_agent = 1;

	int tx_agent_is_master = 1;
	int rc_agent_is_master = 1;


	extern function new(string name = "ai_i2s_base_test", uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern function void config_i2s();
	extern task run_phase(uvm_phase phase);
	extern function void end_of_elaboration_phase(uvm_phase phase);

endclass


function ai_i2s_base_test::new(string name = "ai_i2s_base_test", uvm_component parent);
	super.new(name,parent);
endfunction

function void ai_i2s_base_test::config_i2s();

	if(has_i2s_trans_agent)
	begin
		trans_cfg = new[no_of_trans_agent];
		foreach(trans_cfg[i])
		begin
			trans_cfg[i] = ai_i2s_trans_config::type_id::create($sformatf("trans_cfg[%0d]",i));

			if(!uvm_config_db #(virtual ai_i2s_wishbone_if)::get(this,"","ai_i2s_wishbone_if",trans_cfg[i].vif1))
				`uvm_fatal("WISHBONE IF","Cannot get the wishbone interface in test")

			if(!uvm_config_db #(virtual ai_i2s_if)::get(this,"","ai_i2s_if",trans_cfg[i].vif2))
				`uvm_fatal("I2S Tx IF","Cannot get the I2S interface in test")

			trans_cfg[i].is_active = UVM_ACTIVE;
			m_tb_cfg.trans_cfg[i]=trans_cfg[i];
		end
	end


	if(has_i2s_recv_agent)
	begin
		recv_cfg = new[no_of_recv_agent];
		foreach(recv_cfg[i])
		begin
			recv_cfg[i] = ai_i2s_recv_config::type_id::create($sformatf("recv_cfg[%0d]",i));

			if(!uvm_config_db #(virtual ai_i2s_wishbone_if)::get(this,"","ai_i2s_wishbone_if",recv_cfg[i].vif3))
				`uvm_fatal("WISHBONE IF","Cannot get the wishbone interface in test")

			if(!uvm_config_db #(virtual ai_i2s_if)::get(this,"","ai_i2s_if",recv_cfg[i].vif4))
				`uvm_fatal("I2S Rx IF","Cannot get the I2S interface in test")

			recv_cfg[i].is_active = UVM_ACTIVE;
			m_tb_cfg.recv_cfg[i]=recv_cfg[i];
		end
	end

	m_tb_cfg.has_i2s_trans_agent = has_i2s_trans_agent;
	m_tb_cfg.has_i2s_recv_agent = has_i2s_recv_agent;
	m_tb_cfg.has_i2s_scoreboard = has_i2s_scoreboard;
	m_tb_cfg.no_of_trans_agent = no_of_trans_agent;
	m_tb_cfg.no_of_recv_agent = no_of_recv_agent;

endfunction


function void ai_i2s_base_test::build_phase(uvm_phase phase);
	m_tb_cfg = ai_i2s_env_config::type_id::create("m_tb_cfg");

	if(has_i2s_trans_agent)
		m_tb_cfg.trans_cfg = new[no_of_trans_agent];

	if(has_i2s_recv_agent)
		m_tb_cfg.recv_cfg = new[no_of_recv_agent];

	config_i2s();

	uvm_config_db#(ai_i2s_env_config)::set(this,"*","ai_i2s_env_config",m_tb_cfg);

	super.build();

	envh = ai_i2s_env::type_id::create("envh",this);

endfunction

task ai_i2s_base_test::run_phase(uvm_phase phase);
	super.run_phase(phase);
  //	uvm_top.print_topology();
endtask

function void ai_i2s_base_test::end_of_elaboration_phase(uvm_phase phase);
  	super.end_of_elaboration_phase(phase);            
    	uvm_top.print_topology();
endfunction




//////////Test - 1 For TX_VERSION REGISTER CHECK/////////////


class ai_tx_version_test extends ai_i2s_base_test;

	`uvm_component_utils(ai_tx_version_test)

	ai_vseq_tx_version vseq_test1;

	function new(string name = "ai_tx_version_test", uvm_component parent);
		super.new(name, parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
	endfunction

	task run_phase (uvm_phase phase);
		phase.raise_objection(this);

		vseq_test1 = ai_vseq_tx_version::type_id::create("vseq_test1");

		vseq_test1.start(envh.v_seqrh);

		#200;
		phase.drop_objection(this);
	endtask
endclass




//////////Test - 2 For TX_CONFIGURATION REGISTER CHECK/////////////


class ai_tx_config_test extends ai_i2s_base_test;

	`uvm_component_utils(ai_tx_config_test)

	ai_vseq_tx_config vseq_test2;

	function new(string name = "ai_tx_config_test", uvm_component parent);
		super.new(name, parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
	endfunction

	task run_phase (uvm_phase phase);
		phase.raise_objection(this);

		vseq_test2 = ai_vseq_tx_config::type_id::create("vseq_test2");

		vseq_test2.start(envh.v_seqrh);

		#200;
		phase.drop_objection(this);
	endtask
endclass





//////////Test - 3 For TX_BUFFER_CHECK TEST/////////////


class ai_tx_buffer_check_test extends ai_i2s_base_test;

	`uvm_component_utils(ai_tx_buffer_check_test)

	ai_vseq_tx_buffer_check vseq_test3;

	function new(string name = "ai_tx_buffer_check_test", uvm_component parent);
		super.new(name, parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
	endfunction

	task run_phase (uvm_phase phase);
		phase.raise_objection(this);

		vseq_test3 = ai_vseq_tx_buffer_check::type_id::create("vseq_test3");

		vseq_test3.start(envh.v_seqrh);

		#200;
		phase.drop_objection(this);
	endtask
endclass



////////////EEEEXXXXXTTTTTTRRRRAAAAAA/////////     


class ai_tx_cfg_test extends ai_i2s_base_test;

	`uvm_component_utils(ai_tx_cfg_test)

	ai_vseq_config vseq_test4;

	function new(string name = "ai_tx_cfg_test", uvm_component parent);
		super.new(name, parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
	endfunction

	task run_phase (uvm_phase phase);
		phase.raise_objection(this);

		vseq_test4 = ai_vseq_config::type_id::create("vseq_test4");

		vseq_test4.start(envh.v_seqrh);

		#200;
		phase.drop_objection(this);
	endtask
endclass       



//////////Test - 4 For RX_VERSION REGISTER CHECK/////////////


class ai_rx_version_test extends ai_i2s_base_test;

	`uvm_component_utils(ai_rx_version_test)

	ai_vseq_rx_version vseq_rx_test1;

	function new(string name = "ai_rx_version_test", uvm_component parent);
		super.new(name, parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
	endfunction

	task run_phase (uvm_phase phase);
		phase.raise_objection(this);

		vseq_rx_test1 = ai_vseq_rx_version::type_id::create("vseq_rx_test1");

		vseq_rx_test1.start(envh.v_seqrh);

		#50;
		phase.drop_objection(this);
	endtask
endclass




//////////Test - 5 For RX_CONFIGURATION REGISTER CHECK/////////////



class rx_config_test extends ai_i2s_base_test;

	`uvm_component_utils(rx_config_test)

	ai_vseq_config_rx_version vseq_test5;

	function new(string name = "rx_config_test", uvm_component parent);
		super.new(name, parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
	endfunction

	task run_phase (uvm_phase phase);
		phase.raise_objection(this);

		vseq_test5 = ai_vseq_config_rx_version::type_id::create("vseq_test5");

		vseq_test5.start(envh.v_seqrh);

		#50;
		phase.drop_objection(this);
	endtask
endclass




////////// FORCED TEST /////////////////



class ai_tx_version_force_test extends ai_i2s_base_test;

	`uvm_component_utils(ai_tx_version_force_test)

	ai_vseq_tx_force_version vseq_force_test1;

	function new(string name = "ai_tx_version_force_test", uvm_component parent);
		super.new(name, parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
	endfunction

	task run_phase (uvm_phase phase);
		phase.raise_objection(this);

		vseq_force_test1 = ai_vseq_tx_force_version::type_id::create("vseq_force_test1");

		vseq_force_test1.start(envh.v_seqrh);

		#200;
		phase.drop_objection(this);
	endtask
endclass


class ai_i2s_env extends uvm_env;

	`uvm_component_utils(ai_i2s_env)

	ai_i2s_tx_agt_top  tx_agt_toph;
	ai_i2s_rx_agt_top  rx_agt_toph;
	ai_i2s_env_config  m_cfg;
	ai_i2s_scoreboard sb;
	ai_i2s_virtual_sequencer v_seqrh;

	extern function new(string name= "ai_i2s_env", uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern function void connect_phase(uvm_phase phase);            
endclass


function ai_i2s_env::new(string name ="ai_i2s_env",uvm_component parent);
	super.new(name,parent);
endfunction


function void ai_i2s_env::build_phase(uvm_phase phase);
	if(!uvm_config_db #(ai_i2s_env_config)::get(this,"","ai_i2s_env_config", m_cfg))
		`uvm_fatal("I2S ENVIRONMENT", "Cannot get env_config in environment")

	if(m_cfg.has_i2s_trans_agent)
	begin
		foreach(m_cfg.trans_cfg[i])
		begin
			uvm_config_db #(ai_i2s_trans_config)::set(this,"*","ai_i2s_trans_config",m_cfg.trans_cfg[i]);
		end
		tx_agt_toph = ai_i2s_tx_agt_top::type_id::create("tx_agt_toph",this);
	end


	if(m_cfg.has_i2s_recv_agent)
	begin
		foreach(m_cfg.recv_cfg[i])
		begin
			uvm_config_db #(ai_i2s_recv_config)::set(this,"*","ai_i2s_recv_config",m_cfg.recv_cfg[i]);
		end
		rx_agt_toph = ai_i2s_rx_agt_top::type_id::create("rx_agt_toph",this);
	end


	super.build_phase(phase);

	if(m_cfg.has_i2s_scoreboard)
		sb = ai_i2s_scoreboard::type_id::create("sb", this);

	if(m_cfg.has_i2s_virtual_sequencer)
		v_seqrh = ai_i2s_virtual_sequencer::type_id::create("v_seqrh", this);

endfunction


function void ai_i2s_env::connect_phase(uvm_phase phase);
	super.connect_phase(phase);

	foreach(v_seqrh.tx_seqrh[i])
		v_seqrh.tx_seqrh[i] = tx_agt_toph.tx_agth[i].tx_seqrh;


	foreach(v_seqrh.rx_seqrh[i])
		v_seqrh.rx_seqrh[i] = rx_agt_toph.rx_agth[i].rx_seqrh;


	for(int i=0; i<m_cfg.no_of_trans_agent; i++)
		tx_agt_toph.tx_agth[i].tx_monh.tx_mon_port.connect(sb.tx_fifo[i].analysis_export);

	for(int i=0; i<m_cfg.no_of_recv_agent; i++)
		rx_agt_toph.rx_agth[i].rx_monh.rx_mon_port.connect(sb.rx_fifo[i].analysis_export);



endfunction



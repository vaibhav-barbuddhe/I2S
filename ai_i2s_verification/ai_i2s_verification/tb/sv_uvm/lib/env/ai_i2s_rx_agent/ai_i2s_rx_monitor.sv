class ai_i2s_rx_monitor extends uvm_monitor;

	`uvm_component_utils(ai_i2s_rx_monitor)

	virtual ai_i2s_wishbone_if   wif;
	virtual ai_i2s_if            rxif;

	ai_i2s_recv_config recv_cfg;

	uvm_analysis_port #(ai_i2s_rx_xtn) rx_mon_port;

	extern function new(string name = "ai_i2s_rx_monitor", uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern function void connect_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
	extern task collect_data();

endclass

function ai_i2s_rx_monitor::new(string name = "ai_i2s_rx_monitor", uvm_component parent);
	super.new(name,parent);
	rx_mon_port = new("rx_mon_port",this);
endfunction


function void ai_i2s_rx_monitor::build_phase(uvm_phase phase);

	if(!uvm_config_db#(ai_i2s_recv_config)::get(this,"","ai_i2s_recv_config",recv_cfg))
		`uvm_fatal("RX_CFG","Receiver config is failed in the rx_monitor")

endfunction

function void ai_i2s_rx_monitor::connect_phase(uvm_phase phase);
	wif  = recv_cfg.vif3;
	rxif = recv_cfg.vif4;
endfunction


task ai_i2s_rx_monitor::run_phase(uvm_phase phase);
	super.run_phase(phase);
	forever
begin
	

	@(posedge wif.wb_clk_i);
	#2;  
	collect_data();
	
end
		endtask


		task ai_i2s_rx_monitor::collect_data();
			ai_i2s_rx_xtn  rxtn;

			rxtn = ai_i2s_rx_xtn::type_id::create("rxtn");


		begin

			rxtn.rx_wb_addr   =  wif.wb_adr_i; 
			rxtn.rx_wb_data_i =  wif.wb_dat_i ;
			rxtn.rx_wb_sel_i  =  wif.wb_sel_i;
			rxtn.rx_wb_stb_i  =  wif.wb_stb_i;
			rxtn.rx_wb_we_i   =  wif.wb_we_i; 
			rxtn.rx_wb_cyc_i  =  wif.wb_cyc_i;  
			rxtn.rx_wb_data_o =  wif.wb_dat_o;
			rxtn.rx_wb_bte    =  wif.wb_bte_i;
			rxtn.rx_wb_ack_o  =  wif.wb_ack_o;


			rxtn.rxm_ack      =  wif.rxm_ack;
			rxtn.txs_ack      =  wif.txs_ack;


			rxtn.rxm_dat_i    =   rxif.rxm_dat_i;
			rxtn.txs_dat_i    =   rxif.txs_dat_i;

			rxtn.rxm_int_o    =   rxif.rxm_int_o;
			rxtn.txs_int_o    =   rxif.txs_int_o;


			`uvm_info("RX_MONITOR","RX MONITOR DATA",UVM_LOW) 

			rxtn.print();
			rx_mon_port.write(rxtn);
		end     
	endtask

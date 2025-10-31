class i2s_tx_monitor extends uvm_monitor;

	`uvm_component_utils(i2s_tx_monitor)

	virtual i2s_wishbone_if  wif;
	virtual i2s_if            txif;

	i2s_trans_config trans_cfg;

	uvm_analysis_port #(i2s_tx_xtn) tx_mon_port;

	extern function new(string name = "i2s_tx_monitor", uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern function void connect_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
	extern task collect_data();

endclass

function i2s_tx_monitor::new(string name = "i2s_tx_monitor", uvm_component parent);
	super.new(name,parent);
	tx_mon_port = new("tx_mon_port",this);
endfunction


function void i2s_tx_monitor::build_phase(uvm_phase phase);

	if(!uvm_config_db#(i2s_trans_config)::get(this,"","i2s_trans_config",trans_cfg))
		`uvm_fatal("TX_CFG","Trasmitter config is failed in the tx_monitor")

endfunction

function void i2s_tx_monitor::connect_phase(uvm_phase phase);
	wif  = trans_cfg.vif1;
	txif = trans_cfg.vif2;
endfunction


task i2s_tx_monitor::run_phase(uvm_phase phase);
	super.run_phase(phase);
	forever
	
begin
	@(posedge wif.wb_clk_i);
	#2;
	collect_data();
end

		endtask


		task i2s_tx_monitor::collect_data();

			i2s_tx_xtn  txtn;

			txtn = i2s_tx_xtn::type_id::create("txtn");



		begin	

		txtn.tx_wb_addr   =  wif.wb_adr_i; 
		txtn.tx_wb_data_i = wif.wb_dat_i ;

		txtn.tx_wb_sel_i  =  wif.wb_sel_i;
		txtn.tx_wb_stb_i  =  wif.wb_stb_i;
		txtn.tx_wb_we_i   =  wif.wb_we_i; 
		txtn.tx_wb_cyc_i  =  wif.wb_cyc_i;  
		txtn.tx_wb_data_o =  wif.wb_dat_o;
		txtn.tx_wb_bte    =  wif.wb_bte_i;
		txtn.tx_wb_ack_o  =  wif.wb_ack_o;



		txtn.txm_ack      =  wif.txm_ack;
		txtn.rxs_ack      =  wif.rxs_ack;


		txtn.txm_dat_i    =   txif.txm_dat_i;
		txtn.rxs_dat_i    =   txif.rxs_dat_i;

		txtn.txm_int_o    =   txif.txm_int_o;
		txtn.rxs_int_o    =   txif.rxs_int_o;


		`uvm_info("TX_MONITOR","TX MONITOR DATA",UVM_LOW) 

		txtn.print();
		tx_mon_port.write(txtn);

	end      
endtask

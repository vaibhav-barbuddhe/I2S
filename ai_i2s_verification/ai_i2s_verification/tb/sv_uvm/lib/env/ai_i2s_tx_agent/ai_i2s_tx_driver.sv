class ai_i2s_tx_driver extends uvm_driver#(ai_i2s_tx_xtn);

	`uvm_component_utils(ai_i2s_tx_driver)

	virtual ai_i2s_wishbone_if   wif;
	virtual ai_i2s_if            txif;

	ai_i2s_trans_config trans_cfg;
	ai_i2s_env_config   m_cfg;   //for the variable tx_is_master


	extern function new(string name = "ai_i2s_tx_driver", uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern function void connect_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
	extern task drive_reset();
	extern task driver(ai_i2s_tx_xtn txtn);

endclass


function ai_i2s_tx_driver::new(string name = "ai_i2s_tx_driver", uvm_component parent);
	super.new(name,parent);
endfunction

function void ai_i2s_tx_driver::build_phase(uvm_phase phase);

	if(!uvm_config_db#(ai_i2s_trans_config)::get(this,"","ai_i2s_trans_config",trans_cfg))
		`uvm_fatal("TX_CFG","Trasmitter config is failed in the Tx_driver")

	if(!uvm_config_db#(ai_i2s_env_config)::get(this,"","ai_i2s_env_config",m_cfg))
		`uvm_fatal("ENV_CFG","Cannot Get Config data in TX DRIVER")  

endfunction

function void ai_i2s_tx_driver::connect_phase(uvm_phase phase);
	wif  = trans_cfg.vif1;
	txif = trans_cfg.vif2;
endfunction

task ai_i2s_tx_driver::run_phase(uvm_phase phase);
	super.run_phase(phase);

	drive_reset(); // Calling the Reset task

	forever
begin
	seq_item_port.get_next_item(req);
	driver(req);
	seq_item_port.item_done();
end
endtask



task ai_i2s_tx_driver::drive_reset();   
	`uvm_info(get_full_name(), "======== DRIVING RESET FROM TX DRIVER =========", UVM_MEDIUM);

begin
	wif.wb_rst_i <= 1'b1;
	wif.wb_adr_i <= 1'b0;
	wif.wb_dat_i <= 1'b0;
	wif.wb_dat_o <= 1'b0;
	wif.wb_sel_i <= 1'b0;
	wif.wb_stb_i <= 1'b0;
	wif.wb_we_i  <= 1'b0;
	wif.wb_cyc_i <= 1'b0;
	wif.wb_bte_i <= 1'b0;

	#50;

	wif.wb_rst_i <= 1'b0;
end
	      endtask


	      task ai_i2s_tx_driver::driver(ai_i2s_tx_xtn txtn);

		      `uvm_info(get_full_name(), "======== TX DRIVER ========", UVM_LOW)
		      txtn.print();


		      if (m_cfg.tx_agent_is_master == 1)

		      begin
			      $display("========= TX AGENT IS MASTER =======");


			      @(posedge wif.wb_clk_i);

			      wif.wb_adr_i <= txtn.tx_wb_addr;
			      wif.wb_sel_i <= txtn.tx_wb_sel_i;
			      wif.wb_stb_i <= txtn.tx_wb_stb_i;
			      wif.wb_we_i  <= txtn.tx_wb_we_i;
			      wif.wb_cyc_i <= txtn.tx_wb_cyc_i;
			      wif.wb_bte_i <= txtn.tx_wb_bte;
			      wif.wb_cti_i <= txtn.tx_wb_cti;

			      if (txtn.tx_wb_we_i == 1'b1) 
			      begin
				      $display("============== WRITE OPERATION FROM TX DRIVER ================");
				      wif.wb_dat_i <= txtn.tx_wb_data_i;
			      end
			      else
			      begin
				      $display("============== READ OPERATION FROM TX DRIVER =================");

			      end


			      while(wif.wb_ack_o == 1'b0);

			      @(posedge wif.wb_clk_i);
			      wif.wb_stb_i <= 1'b0;
			      wif.wb_cyc_i <= 1'b0;

		      end 
		      else 
		      begin 

		      $display("============ Tx Agent is Slave,  Wait for SCK and WS from DUT ============");
		      wait (txif.i2s_sck1 && txif.i2s_ws1);

	      @(posedge wif.wb_clk_i);

	      wif.wb_adr_i <= txtn.tx_wb_addr;
	      wif.wb_dat_i <= txtn.tx_wb_data_i;
	      wif.wb_sel_i <= txtn.tx_wb_sel_i;
	      wif.wb_stb_i <= txtn.tx_wb_stb_i;
	      wif.wb_we_i  <= txtn.tx_wb_we_i;
	      wif.wb_cyc_i <= txtn.tx_wb_cyc_i;

	      wait (wif.wb_ack_o == 1'b1);

	      @(posedge wif.wb_clk_i);
	      wif.wb_stb_i <= 1'b0;
	      wif.wb_cyc_i <= 1'b0;


      end

	     endtask
























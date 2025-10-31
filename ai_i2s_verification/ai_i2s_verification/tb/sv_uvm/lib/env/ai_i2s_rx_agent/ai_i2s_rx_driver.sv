class ai_i2s_rx_driver extends uvm_driver#(ai_i2s_rx_xtn);

	`uvm_component_utils(ai_i2s_rx_driver)

	virtual ai_i2s_wishbone_if   wif;
	virtual ai_i2s_if            rxif;

	ai_i2s_recv_config recv_cfg;
	ai_i2s_env_config   m_cfg;   //for the variable rx_is_master


	extern function new(string name = "ai_i2s_rx_driver", uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern function void connect_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
	extern task drive_reset();
	extern task driver(ai_i2s_rx_xtn rxtn);

endclass


function ai_i2s_rx_driver::new(string name = "ai_i2s_rx_driver", uvm_component parent);
	super.new(name,parent);
endfunction

function void ai_i2s_rx_driver::build_phase(uvm_phase phase);

	if(!uvm_config_db#(ai_i2s_recv_config)::get(this,"","ai_i2s_recv_config",recv_cfg))
		`uvm_fatal("RX_CFG","Receiver config is failed in the Rx_driver")

	if(!uvm_config_db#(ai_i2s_env_config)::get(this,"","ai_i2s_env_config",m_cfg))
		`uvm_fatal("ENV_CFG","Cannot Get Config data in RX DRIVER")  

endfunction

function void ai_i2s_rx_driver::connect_phase(uvm_phase phase);
	wif  = recv_cfg.vif3;
	rxif = recv_cfg.vif4;
endfunction

task ai_i2s_rx_driver::run_phase(uvm_phase phase);
	super.run_phase(phase);
	drive_reset();


	forever
begin
	seq_item_port.get_next_item(req);
	driver(req);
	seq_item_port.item_done();
end
	    endtask


	    task ai_i2s_rx_driver::drive_reset();   
		    `uvm_info(get_full_name(), "======= DRIVING RESET FROM RX DRIVER ========", UVM_MEDIUM);

	    begin
		    wif.wb_rst_i <= 1'b1;
		    wif.wb_adr_i <= 1'b0;
		    wif.wb_dat_i <= 1'b0;
		    wif.wb_dat_o <= 1'b0;
		    wif.wb_sel_i <= 1'b0;
		    wif.wb_stb_i <= 1'b0;
		    wif.wb_we_i  <= 1'b0;
		    wif.wb_cyc_i <= 1'b0;

		    #50;

		    wif.wb_rst_i <= 1'b0;
	    end
    endtask     


    task ai_i2s_rx_driver::driver(ai_i2s_rx_xtn rxtn);

	    `uvm_info(get_full_name(),"======== RX DRIVER ========",UVM_LOW)
	    rxtn.print();

	    if (m_cfg.rx_agent_is_master == 1) 
	    begin
		    $display("=============== RX AGENT IS MASTER =============");

		    @(posedge wif.wb_clk_i);

		    wif.wb_adr_i <= rxtn.rx_wb_addr;
		    wif.wb_sel_i <= 1'b1;
		    wif.wb_stb_i <= 1'b1;
		    wif.wb_we_i  <= rxtn.rx_wb_we_i;
		    wif.wb_cyc_i <= 1'b1;

		    if (rxtn.rx_wb_we_i == 1'b1) 
		    begin
			    $display("========== WRITE OPERATION FROM RX DRIVER ============");
			    wif.wb_dat_i <= rxtn.rx_wb_data_i;
		    end

		    else

		    begin
			    $display("============ READ OPERATION FROM RX DRIVER =============");

		    end

	    while(wif.wb_ack_o == 1'b0);

	    @(posedge wif.wb_clk_i);
	    wif.wb_stb_i <= 1'b0;
	    wif.wb_cyc_i <= 1'b0;

    end 
    else 
    begin
	    $display("=========== Rx Agent is Slave  Passively monitors SD data ===========");
    end

	      endtask























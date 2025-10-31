class ai_i2s_tx_xtn extends uvm_sequence_item;
	`uvm_object_utils(ai_i2s_tx_xtn)

	///Wishbone Signals///

	rand logic [15:0] tx_wb_addr;
	rand logic [1:0]  tx_wb_bte;
	rand logic [2:0]  tx_wb_cti;
	rand logic        tx_wb_cyc_i;
	rand logic [31:0] tx_wb_data_i;
	logic [31:0]      tx_wb_data_o;
	logic             tx_wb_rst_i;
	rand logic        tx_wb_sel_i;
	rand logic        tx_wb_stb_i;
	rand logic        tx_wb_we_i;
	logic        tx_wb_ack_o;

	bit tx_is_master;

	///Acknowledgement Signal///
	logic txm_ack;
	logic rxs_ack;

	///Data Signals///
	logic [31:0] txm_dat_i;
	logic [31:0] rxs_dat_i;

	///Interrupts///

	logic txm_int_o;
	logic rxs_int_o;

	constraint valid_addr {tx_wb_addr inside {[16'h0000 : 16'h0003]};}
        constraint valid_we {tx_wb_we_i inside {[0:1]};}




	extern function new(string name = "ai_i2s_tx_xtn");
	extern function void do_print(uvm_printer printer);

endclass

function ai_i2s_tx_xtn::new(string name = "ai_i2s_tx_xtn");
	super.new(name);
endfunction

function void ai_i2s_tx_xtn::do_print(uvm_printer printer);
	super.do_print(printer);

	///Wishbone Signals///

	printer.print_field("TX_WB_ADDR",    this.tx_wb_addr,     16, UVM_HEX);
	printer.print_field("TX_WB_DATA_I",  this.tx_wb_data_i,   32, UVM_HEX);
	printer.print_field("TX_WB_DATA_O",  this.tx_wb_data_o,   32, UVM_HEX);
	printer.print_field("TX_WB_WE_I",    this.tx_wb_we_i,      1, UVM_BIN);
	printer.print_field("TX_WB_SEL",     this.tx_wb_sel_i,     1, UVM_BIN); 
	printer.print_field("TX_WB_STB_I",   this.tx_wb_stb_i,     1, UVM_BIN);
	printer.print_field("TX_WB_BTE",     this.tx_wb_bte,       2, UVM_HEX);
	printer.print_field("TX_WB_CTI",     this.tx_wb_cti,       3, UVM_DEC);
	printer.print_field("TX_WB_CYC_I",   this.tx_wb_cyc_i,     1, UVM_BIN);
	printer.print_field("TX_WB_ACK_O",   this.tx_wb_ack_o,     1, UVM_BIN);


	///Acknowledgement Signals///
	printer.print_field("I2S_TXM_ACK",   this.txm_ack,     1, UVM_BIN); 
	printer.print_field("I2S_RXS_ACK",   this.rxs_ack,     1, UVM_BIN);

	///Data Signals///
	
	printer.print_field("I2S_TXM_DATA_I",   this.txm_dat_i,     32, UVM_HEX); 
	printer.print_field("I2S_RXS_DATA_I",   this.rxs_dat_i,     32, UVM_HEX); 

	///Interrupts///
	printer.print_field("I2S_TXM_INTP",   this.txm_int_o,     1, UVM_BIN); 
	printer.print_field("I2S_RXS_INTP",   this.rxs_int_o,     1, UVM_BIN);  

endfunction


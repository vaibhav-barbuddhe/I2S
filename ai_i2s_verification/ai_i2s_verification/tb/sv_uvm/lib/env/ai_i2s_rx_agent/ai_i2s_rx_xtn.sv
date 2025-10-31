class ai_i2s_rx_xtn extends uvm_sequence_item;
	`uvm_object_utils(ai_i2s_rx_xtn)


	rand logic [15:0] rx_wb_addr;
	rand logic [1:0]  rx_wb_bte;
	rand logic [2:0]  rx_wb_cti;
	rand logic        rx_wb_cyc_i;
	rand logic [31:0] rx_wb_data_i;
	logic [31:0]      rx_wb_data_o;
	logic             rx_wb_rst_i;
	rand logic        rx_wb_sel_i;
	rand logic        rx_wb_stb_i;
	rand logic        rx_wb_we_i;
	logic        rx_wb_ack_o;


	bit rx_is_master;



	///Acknowledgement Signal///
	logic rxm_ack;
	logic txs_ack;

	///Data Signals///
	logic [31:0] rxm_dat_i;
	logic [31:0] txs_dat_i;


	///Interrupts///    
	logic rxm_int_o;
	logic txs_int_o;





	extern function new(string name = "ai_i2s_rx_xtn");
	extern function void do_print(uvm_printer printer);

endclass

function ai_i2s_rx_xtn::new(string name = "ai_i2s_rx_xtn");
	super.new(name);
endfunction

function void ai_i2s_rx_xtn::do_print(uvm_printer printer);
	super.do_print(printer);

	printer.print_field("RX_WB_ADDR",    this.rx_wb_addr,     16, UVM_HEX);
	printer.print_field("RX_WB_DATA_I",  this.rx_wb_data_i,   32, UVM_HEX);
	printer.print_field("RX_WB_DATA_O",  this.rx_wb_data_o,   32, UVM_HEX);
	printer.print_field("RX_WB_WE_I",    this.rx_wb_we_i,      1, UVM_BIN);
	printer.print_field("RX_WB_SEL",     this.rx_wb_sel_i,     1, UVM_BIN); 
	printer.print_field("RX_WB_STB_I",   this.rx_wb_stb_i,     1, UVM_BIN);
	printer.print_field("RX_WB_BTE",     this.rx_wb_bte,       2, UVM_HEX);
	printer.print_field("RX_WB_CTI",     this.rx_wb_cti,       3, UVM_DEC);
	printer.print_field("RX_WB_CYC_I",   this.rx_wb_cyc_i,     1, UVM_BIN);
	printer.print_field("RX_WB_ACK_O",   this.rx_wb_ack_o,     1, UVM_BIN);



	///Acknowledgement Signals///
	printer.print_field("I2S_RXM_ACK",   this.rxm_ack,     1, UVM_BIN); 
	printer.print_field("I2S_TXS_ACK",   this.txs_ack,     1, UVM_BIN);

	///Data Signals///
	printer.print_field("I2S_RXM_DATA_I",   this.rxm_dat_i,     32, UVM_HEX); 
	printer.print_field("I2S_TXS_DATA_I",   this.txs_dat_i,     32, UVM_HEX); 

	///Interrupts///
	printer.print_field("I2S_RXM_INTP",   this.rxm_int_o,     1, UVM_BIN); 
	printer.print_field("I2S_TXS_INTP",   this.txs_int_o,     1, UVM_BIN); 


endfunction


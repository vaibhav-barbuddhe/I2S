
`timescale 1ns/1ps

`include "/proj/repo/user/vaibhavb/ai_i2s_verification/ai_i2s_verification/tb/sv_uvm/tc/ai_i2s_test_list.sv"


module ai_i2s_top #(parameter DATA_WIDTH = 32, ADDR_WIDTH = 16);

import uvm_pkg::*;
bit wb_clk_i;

initial
begin
	wb_clk_i = 1'b0;
	forever #10 wb_clk_i = ~wb_clk_i;
end

ai_i2s_wishbone_if wb_if(wb_clk_i);
ai_i2s_if          in1  (wb_clk_i);
ai_i2s_if          in2  (wb_clk_i);


///INSTANTIATION OF DUT SIGNALS///

///Transmitter Master///


tx_i2s_topm #(.DATA_WIDTH(DATA_WIDTH),.ADDR_WIDTH(ADDR_WIDTH)) 
I2STXM (
	.wb_clk_i(wb_if.wb_clk_i),
	.wb_rst_i(wb_if.wb_rst_i),
	.wb_sel_i(wb_if.wb_sel_i),
	.wb_stb_i(wb_if.wb_stb_i),
	.wb_we_i (wb_if.wb_we_i) ,
	.wb_cyc_i(wb_if.wb_cyc_i),
	.wb_bte_i(wb_if.wb_bte_i),
	.wb_cti_i(wb_if.wb_cti_i),
	.wb_adr_i(wb_if.wb_adr_i[ADDR_WIDTH-1:0]),
	.wb_dat_i(wb_if.wb_dat_i),
	.wb_ack_o(wb_if.txm_ack),
	.wb_dat_o(in1.txm_dat_i),
	.tx_int_o(in1.txm_int_o),
	.i2s_sd_o(in1.i2s_sd1),
	.i2s_sck_o(in1.i2s_sck1),
	.i2s_ws_o(in1.i2s_ws1));

///Receiver Slave///

rx_i2s_tops #(.DATA_WIDTH(DATA_WIDTH),.ADDR_WIDTH(ADDR_WIDTH)) 
I2SRXS (
	.wb_clk_i(wb_if.wb_clk_i),
	.wb_rst_i(wb_if.wb_rst_i),
	.wb_sel_i(wb_if.wb_sel_i),
	.wb_stb_i(wb_if.wb_stb_i),
	.wb_we_i (wb_if.wb_we_i) ,
	.wb_cyc_i(wb_if.wb_cyc_i),
	.wb_bte_i(wb_if.wb_bte_i),
	.wb_cti_i(wb_if.wb_cti_i),
	.wb_adr_i(wb_if.wb_adr_i[ADDR_WIDTH-1:0]),
	.wb_dat_i(wb_if.wb_dat_i),
	.i2s_sd_i(in1.i2s_sd1),
	.i2s_sck_i(in1.i2s_sck1),
	.i2s_ws_i(in1.i2s_ws1),
	.wb_ack_o(wb_if.rxs_ack),
	.wb_dat_o(in1.rxs_dat_i),
	.rx_int_o(in1.rxs_int_o) );


///Receiver Master///

rx_i2s_topm #(.DATA_WIDTH(DATA_WIDTH),.ADDR_WIDTH(ADDR_WIDTH)) 
I2SRXM (
	.wb_clk_i(wb_if.wb_clk_i),
	.wb_rst_i(wb_if.wb_rst_i),
	.wb_sel_i(wb_if.wb_sel_i),
	.wb_stb_i(wb_if.wb_stb_i),
	.wb_we_i (wb_if.wb_we_i) ,
	.wb_cyc_i(wb_if.wb_cyc_i),
	.wb_bte_i(wb_if.wb_bte_i),
	.wb_cti_i(wb_if.wb_cti_i),
	.wb_adr_i(wb_if.wb_adr_i[ADDR_WIDTH-1:0]),
	.wb_dat_i(wb_if.wb_dat_i),
	.i2s_sd_i(in2.i2s_sd2),
	.wb_ack_o(wb_if.rxm_ack),
	.wb_dat_o(in2.rxm_dat_i),
	.rx_int_o(in2.rxm_int_o),
	.i2s_sck_o(in2.i2s_sck2),
	.i2s_ws_o(in2.i2s_ws2));



///Transmitter Slave///

tx_i2s_tops #(.DATA_WIDTH(DATA_WIDTH),.ADDR_WIDTH(ADDR_WIDTH)) 
I2STXS (
	.wb_clk_i(wb_if.wb_clk_i),
	.wb_rst_i(wb_if.wb_rst_i),
	.wb_sel_i(wb_if.wb_sel_i),
	.wb_stb_i(wb_if.wb_stb_i),
	.wb_we_i (wb_if.wb_we_i),
	.wb_cyc_i(wb_if.wb_cyc_i),
	.wb_bte_i(wb_if.wb_bte_i),
	.wb_cti_i(wb_if.wb_cti_i),
	.wb_adr_i(wb_if.wb_adr_i[ADDR_WIDTH-1:0]),
	.wb_dat_i(wb_if.wb_dat_i),
	.i2s_sck_i(in2.i2s_sck2),
	.i2s_ws_i(in2.i2s_ws2),
	.wb_ack_o(wb_if.txs_ack),
	.wb_dat_o(in2.txs_dat_i),
	.tx_int_o(in2.txs_int_o),
	.i2s_sd_o(in2.i2s_sd2));




initial
begin

	$xm_force("ai_i2s_top.I2SRXS.CG32.config_dout", 32'h0, "force");
	$xm_force("ai_i2s_top.I2SRXS.IM32.intmask_dout", 32'h0, "force");
	$xm_force("ai_i2s_top.I2SRXS.ISTAT.intstat_dout", 32'h0, "force");

	#100;
	$xm_release("ai_i2s_top.I2SRXS.config_dout");
	$xm_release("ai_i2s_top.I2SRXS.intmask_dout");
	$xm_release("ai_i2s_top.I2SRXS.intstat_dout");
end




initial
begin
	uvm_config_db#(virtual ai_i2s_wishbone_if)::set(null,"*","ai_i2s_wishbone_if", wb_if);
	uvm_config_db#(virtual ai_i2s_if)::set(null,"*","ai_i2s_if",in1);
	uvm_config_db#(virtual ai_i2s_if)::set(null,"*","ai_i2s_if",in2);


	run_test();


end
endmodule






















//   ai_i2s_base_test
//   ai_tx_version_test
//   ai_tx_config_test
//   ai_rx_version_test
//   ai_rx_config_test


//EEEEXXXTTTRRRAAAA//
//   ai_tx_cfg_test
//   ai_tx_buffer_check_test


//////Receiver Tests/////
//   ai_rx_version_test
//   ai_rx_config_test


/////////// FORCED TEST ////////

//   ai_tx_version_force_test







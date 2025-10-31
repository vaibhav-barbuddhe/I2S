



import uvm_pkg::*;
`include "uvm_macros.svh"

//RTL

//`include "/proj/repo/user/vaibhavb/i2s_verification/rtl/vhdl/rx_i2s_topm.vhd"
//`include "/proj/repo/user/vaibhavb/i2s_verification/rtl/vhdl/rx_i2s_tops.vhd"
//`include "/proj/repo/user/vaibhavb/i2s_verification/rtl/vhdl/tx_i2s_topm.vhd"
//`include "/proj/repo/user/vaibhavb/i2s_verification/rtl/vhdl/rx_i2s_tops.vhd"



//`include "i2s_wishbone_if.sv"
`include "/proj/repo/user/vaibhavb/i2s_verification/tb/sv_uvm/src/i2s_wishbone_if.sv"
//`include "i2s_if.sv"
`include "/proj/repo/user/vaibhavb/i2s_verification/tb/sv_uvm/src/i2s_if.sv"

//`include "i2s_tx_xtn.sv"
`include "/proj/repo/user/vaibhavb/i2s_verification/tb/sv_uvm/lib/env/i2s_tx_agent/i2s_tx_xtn.sv"

//`include "i2s_rx_xtn.sv"
`include "/proj/repo/user/vaibhavb/i2s_verification/tb/sv_uvm/lib/env/i2s_rx_agent/i2s_rx_xtn.sv"

//`include "i2s_trans_config.sv"
`include "/proj/repo/user/vaibhavb/i2s_verification/tb/sv_uvm/lib/env/i2s_trans_config.sv"

//`include "i2s_recv_config.sv"
`include "/proj/repo/user/vaibhavb/i2s_verification/tb/sv_uvm/lib/env/i2s_recv_config.sv"

//`include "i2s_env_config.sv"
`include "/proj/repo/user/vaibhavb/i2s_verification/tb/sv_uvm/lib/env/i2s_env_config.sv"

//`include "i2s_tx_seqs.sv"
`include "/proj/repo/user/vaibhavb/i2s_verification/tb/sv_uvm/lib/seqs/i2s_tx_seqs.sv"

//`include "i2s_tx_driver.sv"
`include "/proj/repo/user/vaibhavb/i2s_verification/tb/sv_uvm/lib/env/i2s_tx_agent/i2s_tx_driver.sv"
//`include "i2s_tx_monitor.sv"
`include "/proj/repo/user/vaibhavb/i2s_verification/tb/sv_uvm/lib/env/i2s_tx_agent/i2s_tx_monitor.sv"

//`include "i2s_tx_sequencer.sv"
`include "/proj/repo/user/vaibhavb/i2s_verification/tb/sv_uvm/lib/env/i2s_tx_agent/i2s_tx_sequencer.sv"


//`include "i2s_tx_agent.sv"
`include "/proj/repo/user/vaibhavb/i2s_verification/tb/sv_uvm/lib/env/i2s_tx_agent/i2s_tx_agent.sv"

//`include "i2s_tx_agt_top.sv"
`include "/proj/repo/user/vaibhavb/i2s_verification/tb/sv_uvm/lib/env/i2s_tx_agent/i2s_tx_agt_top.sv"


//`include "i2s_rx_seqs.sv"
`include "/proj/repo/user/vaibhavb/i2s_verification/tb/sv_uvm/lib/seqs/i2s_rx_seqs.sv"

//`include "i2s_rx_driver.sv"
`include "/proj/repo/user/vaibhavb/i2s_verification/tb/sv_uvm/lib/env/i2s_rx_agent/i2s_rx_driver.sv"

//`include "i2s_rx_monitor.sv"
`include "/proj/repo/user/vaibhavb/i2s_verification/tb/sv_uvm/lib/env/i2s_rx_agent/i2s_rx_monitor.sv"

//`include "i2s_rx_sequencer.sv"
`include "/proj/repo/user/vaibhavb/i2s_verification/tb/sv_uvm/lib/env/i2s_rx_agent/i2s_rx_sequencer.sv"

//`include "i2s_rx_agent.sv"
`include "/proj/repo/user/vaibhavb/i2s_verification/tb/sv_uvm/lib/env/i2s_rx_agent/i2s_rx_agent.sv"

//`include "i2s_rx_agt_top.sv"
`include "/proj/repo/user/vaibhavb/i2s_verification/tb/sv_uvm/lib/env/i2s_rx_agent/i2s_rx_agt_top.sv"

//`include "i2s_virtual_sequencer.sv"
`include "/proj/repo/user/vaibhavb/i2s_verification/tb/sv_uvm/lib/env/i2s_virtual_sequencer.sv"


//`include "i2s_virtual_sequence.sv"
`include "/proj/repo/user/vaibhavb/i2s_verification/tb/sv_uvm/lib/seqs/i2s_virtual_sequence.sv"

//`include "i2s_scoreboard.sv"
`include "/proj/repo/user/vaibhavb/i2s_verification/tb/sv_uvm/lib/env/i2s_scoreboard.sv"

//`include "i2s_env.sv"
`include "/proj/repo/user/vaibhavb/i2s_verification/tb/sv_uvm/lib/env/i2s_env.sv"

//`include "i2s_test.sv"
`include "/proj/repo/user/vaibhavb/i2s_verification/tb/sv_uvm/tc/i2s_test.sv"




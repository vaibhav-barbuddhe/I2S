



import uvm_pkg::*;
`include "uvm_macros.svh"

//RTL

//`include "/proj/repo/user/vaibhavb/i2s_verification/rtl/vhdl/rx_i2s_topm.vhd"
//`include "/proj/repo/user/vaibhavb/i2s_verification/rtl/vhdl/rx_i2s_tops.vhd"
//`include "/proj/repo/user/vaibhavb/i2s_verification/rtl/vhdl/tx_i2s_topm.vhd"
//`include "/proj/repo/user/vaibhavb/i2s_verification/rtl/vhdl/rx_i2s_tops.vhd"



//`include "ai_i2s_wishbone_if.sv"
`include "/proj/repo/user/vaibhavb/ai_i2s_verification/ai_i2s_verification/tb/sv_uvm/src/ai_i2s_wishbone_if.sv"
//`include "ai_i2s_if.sv"
`include "/proj/repo/user/vaibhavb/ai_i2s_verification/ai_i2s_verification/tb/sv_uvm/src/ai_i2s_if.sv"

//`include "ai_i2s_tx_xtn.sv"
`include "/proj/repo/user/vaibhavb/ai_i2s_verification/ai_i2s_verification/tb/sv_uvm/lib/env/ai_i2s_tx_agent/ai_i2s_tx_xtn.sv"

//`include "ai_i2s_rx_xtn.sv"
`include "/proj/repo/user/vaibhavb/ai_i2s_verification/ai_i2s_verification/tb/sv_uvm/lib/env/ai_i2s_rx_agent/ai_i2s_rx_xtn.sv"

//`include "ai_i2s_trans_config.sv"
`include "/proj/repo/user/vaibhavb/ai_i2s_verification/ai_i2s_verification/tb/sv_uvm/lib/env/ai_i2s_trans_config.sv"

//`include "ai_i2s_recv_config.sv"
`include "/proj/repo/user/vaibhavb/ai_i2s_verification/ai_i2s_verification/tb/sv_uvm/lib/env/ai_i2s_recv_config.sv"

//`include "ai_i2s_env_config.sv"
`include "/proj/repo/user/vaibhavb/ai_i2s_verification/ai_i2s_verification/tb/sv_uvm/lib/env/ai_i2s_env_config.sv"

//`include "ai_i2s_tx_seqs.sv"
`include "/proj/repo/user/vaibhavb/ai_i2s_verification/ai_i2s_verification/tb/sv_uvm/lib/seqs/ai_i2s_tx_seqs.sv"

//`include "ai_i2s_tx_driver.sv"
`include "/proj/repo/user/vaibhavb/ai_i2s_verification/ai_i2s_verification/tb/sv_uvm/lib/env/ai_i2s_tx_agent/ai_i2s_tx_driver.sv"
//`include "ai_i2s_tx_monitor.sv"
`include "/proj/repo/user/vaibhavb/ai_i2s_verification/ai_i2s_verification/tb/sv_uvm/lib/env/ai_i2s_tx_agent/ai_i2s_tx_monitor.sv"

//`include "ai_i2s_tx_sequencer.sv"
`include "/proj/repo/user/vaibhavb/ai_i2s_verification/ai_i2s_verification/tb/sv_uvm/lib/env/ai_i2s_tx_agent/ai_i2s_tx_sequencer.sv"


//`include "ai_i2s_tx_agent.sv"
`include "/proj/repo/user/vaibhavb/ai_i2s_verification/ai_i2s_verification/tb/sv_uvm/lib/env/ai_i2s_tx_agent/ai_i2s_tx_agent.sv"

//`include "ai_i2s_tx_agt_top.sv"
`include "/proj/repo/user/vaibhavb/ai_i2s_verification/ai_i2s_verification/tb/sv_uvm/lib/env/ai_i2s_tx_agent/ai_i2s_tx_agt_top.sv"


//`include "ai_i2s_rx_seqs.sv"
`include "/proj/repo/user/vaibhavb/ai_i2s_verification/ai_i2s_verification/tb/sv_uvm/lib/seqs/ai_i2s_rx_seqs.sv"

//`include "ai_i2s_rx_driver.sv"
`include "/proj/repo/user/vaibhavb/ai_i2s_verification/ai_i2s_verification/tb/sv_uvm/lib/env/ai_i2s_rx_agent/ai_i2s_rx_driver.sv"

//`include "ai_i2s_rx_monitor.sv"
`include "/proj/repo/user/vaibhavb/ai_i2s_verification/ai_i2s_verification/tb/sv_uvm/lib/env/ai_i2s_rx_agent/ai_i2s_rx_monitor.sv"

//`include "ai_i2s_rx_sequencer.sv"
`include "/proj/repo/user/vaibhavb/ai_i2s_verification/ai_i2s_verification/tb/sv_uvm/lib/env/ai_i2s_rx_agent/ai_i2s_rx_sequencer.sv"

//`include "ai_i2s_rx_agent.sv"
`include "/proj/repo/user/vaibhavb/ai_i2s_verification/ai_i2s_verification/tb/sv_uvm/lib/env/ai_i2s_rx_agent/ai_i2s_rx_agent.sv"

//`include "ai_i2s_rx_agt_top.sv"
`include "/proj/repo/user/vaibhavb/ai_i2s_verification/ai_i2s_verification/tb/sv_uvm/lib/env/ai_i2s_rx_agent/ai_i2s_rx_agt_top.sv"

//`include "ai_i2s_virtual_sequencer.sv"
`include "/proj/repo/user/vaibhavb/ai_i2s_verification/ai_i2s_verification/tb/sv_uvm/lib/env/ai_i2s_virtual_sequencer.sv"


//`include "ai_i2s_virtual_sequence.sv"
`include "/proj/repo/user/vaibhavb/ai_i2s_verification/ai_i2s_verification/tb/sv_uvm/lib/seqs/ai_i2s_virtual_sequence.sv"

//`include "ai_i2s_scoreboard.sv"
`include "/proj/repo/user/vaibhavb/ai_i2s_verification/ai_i2s_verification/tb/sv_uvm/lib/env/ai_i2s_scoreboard.sv"

//`include "ai_i2s_env.sv"
`include "/proj/repo/user/vaibhavb/ai_i2s_verification/ai_i2s_verification/tb/sv_uvm/lib/env/ai_i2s_env.sv"

//`include "ai_i2s_test.sv"
`include "/proj/repo/user/vaibhavb/ai_i2s_verification/ai_i2s_verification/tb/sv_uvm/tc/ai_i2s_test.sv"




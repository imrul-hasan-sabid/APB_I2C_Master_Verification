
//// Including the RTL directory
//+incdir+../rtl_robin
//../rtl_robin/*.sv

+incdir+../rtl_sadman
../rtl_sadman/top.sv
../rtl_sadman/sta_sto_gen.sv
../rtl_sadman/standard_macros.sv
../rtl_sadman/scl_gen.sv
../rtl_sadman/mst_ctrl_fsm.sv
../rtl_sadman/edge_det.sv
../rtl_sadman/apb_i2c_man_sub_intf.sv
../rtl_sadman/apb_sub.sv

// Including the interface
../tb/tb_top/APB_I2C_master_interface.sv

// Including the Ral model
../RAL_model/APB_I2C_master_ral_model.sv

// Including the agent package and inside the pakage all the files of agent is included
//=======I2C=======
+incdir+../tb/agents/I2C_agent/
../tb/agents/I2C_agent/I2C_agent_pkg.sv
//=======APB=======
+incdir+../tb/agents/APB_agent/
../tb/agents/APB_agent/apb_agent_pkg.sv

// Including the environment components
+incdir+../tb/env/
../tb/env/env_pkg.sv

//including the seqlib files files
+incdir+../tb/seqlib/
../tb/seqlib/seqlib_pkg.sv

// Including the tests
+incdir+../tb/tests/
../tb/tests/test_pkg.sv

// Including the tb top
../tb/tb_top/tb_top_APB_I2C_master.sv


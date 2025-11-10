package test_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    
    import apb_agent_pkg::*;
    import I2C_agent_pkg::*; 
    import env_pkg::*;
    import APB_I2C_master_ral_model::*;
    import seqlib_pkg::*;
    
    `include "APB_I2C_master_base_test.sv"
endpackage

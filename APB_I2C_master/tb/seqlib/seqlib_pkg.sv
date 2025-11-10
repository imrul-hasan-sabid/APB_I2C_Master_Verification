package seqlib_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    import env_pkg::*;
    import apb_agent_pkg::*;
    import I2C_agent_pkg::*;    
    import APB_I2C_master_ral_model::*;

    `include "APB_I2C_master_basic_virtual_sequence.sv"
endpackage

package apb_agent_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import APB_I2C_master_ral_model::*;

    `include "apb_sequence_item.sv"
    `include "apb_agent_config.sv"
    `include "apb_seqlib.sv"
    `include "apb_sequencer.sv"
    `include "APB_I2C_master_reg_adapter.sv"
    `include "apb_driver.sv"
    `include "apb_monitor.sv"
    `include "apb_coverage.sv"
    `include "apb_agent.sv"

endpackage 

package I2C_agent_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import APB_I2C_master_ral_model::*;
   
    `include "I2C_sequence_item.sv"
    `include "I2C_agent_config.sv"
    `include "I2C_seqlib.sv"
    `include "I2C_sequencer.sv"
    `include "I2C_monitor.sv"
    `include "I2C_driver.sv"
    `include "I2C_agent.sv"
endpackage

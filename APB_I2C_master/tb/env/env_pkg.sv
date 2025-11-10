package env_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    
    import apb_agent_pkg::*;
    import I2C_agent_pkg::*; 
    import APB_I2C_master_ral_model::*;
    
    `include "environment_config.sv" 
    `include "APB_I2C_master_predictor.sv"
    `include "APB_I2C_master_scoreboard.sv"
    `include "APB_I2C_master_environment.sv"
endpackage

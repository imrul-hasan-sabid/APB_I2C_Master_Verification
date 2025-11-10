class APB_I2C_master_base_test extends uvm_test;
    `uvm_component_utils(APB_I2C_master_base_test)
    
    int test_itter;
    APB_I2C_master_environment env;
    environment_config env_config;
    I2C_agent_config I2C_config;

    function new(string name="APB_I2C_master_base_test", uvm_component parent=null);
        super.new(name, parent);
        `uvm_info(get_type_name,"APB_I2C_master_base_test is created...",UVM_DEBUG);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info(get_type_name,"APB_I2C_master_base_test build phase is started...",UVM_DEBUG);
        env = APB_I2C_master_environment::type_id::create("env",this);
        env_config = environment_config::type_id::create("env_config");
        env_config.has_scoreboard = 1;
        uvm_config_db#(environment_config)::set(this,"*","env_config",env_config);    
        I2C_config = I2C_agent_config::type_id::create("I2C_config");
        uvm_config_db#(I2C_agent_config)::set(this,"*","I2C_config", I2C_config);    
        if(!$value$plusargs("test_itter=%0d",test_itter)) `uvm_error(get_type_name(),"test_itter value hasn't received")
        else `uvm_info(get_full_name(),$sformatf("test_itter = %0d",test_itter),UVM_NONE)        
        `uvm_info(get_type_name,"APB_I2C_master_base_test build phase is ended...",UVM_DEBUG);
    endfunction
    
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info(get_type_name,"APB_I2C_master_base_test connect phase is started...",UVM_DEBUG);
        `uvm_info(get_type_name,"APB_I2C_master_base_test connect phase is ended...",UVM_DEBUG);
    endfunction
    
    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        `uvm_info(get_type_name,"APB_I2C_master_base_test run phase is started...",UVM_DEBUG);
        `uvm_info(get_type_name,"APB_I2C_master_base_test run phase is ended...",UVM_DEBUG);
    endtask

    task APB_I2C_master_reset_test_task();
        APB_I2C_master_reset_virtual_sequence APB_I2C_master_reset_vs = APB_I2C_master_reset_virtual_sequence::type_id::create("APB_I2C_master_reset_vs");
        APB_I2C_master_reset_vs.apb_sqncr = env.APB_agnt.apb_sqncr;
        APB_I2C_master_reset_vs.apb_sqncr_a = env.APB_agnt_a.apb_sqncr;
        APB_I2C_master_reset_vs.I2C_sqncr = env.I2C_agnt.I2C_sqncr;
        APB_I2C_master_reset_vs.reg_blk   = env.reg_blk;
        APB_I2C_master_reset_vs.env_config = env_config;
        env_config.register_check = 1; 
        APB_I2C_master_reset_vs.start(null);
    endtask

    task APB_I2C_register_test_task();
        APB_I2C_master_register_test_virtual_sequence APB_I2C_master_register_test_vs = APB_I2C_master_register_test_virtual_sequence::type_id::create("APB_I2C_master_register_test_vs");
        APB_I2C_master_register_test_vs.apb_sqncr = env.APB_agnt.apb_sqncr;
        APB_I2C_master_register_test_vs.apb_sqncr_a = env.APB_agnt_a.apb_sqncr;
        APB_I2C_master_register_test_vs.I2C_sqncr = env.I2C_agnt.I2C_sqncr;
        APB_I2C_master_register_test_vs.reg_blk   = env.reg_blk;           
        APB_I2C_master_register_test_vs.env_config = env_config;
        env_config.register_check = 1; 
        APB_I2C_master_register_test_vs.start(null);
    endtask

    task APB_I2C_MT_write_transfer_with_S_test_task();
        APB_I2C_MT_write_transfer_with_S_test_virtual_sequence APB_I2C_MT_write_transfer_with_S_test_vs = APB_I2C_MT_write_transfer_with_S_test_virtual_sequence::type_id::create("APB_I2C_MT_write_transfer_with_S_test_vs");
        APB_I2C_MT_write_transfer_with_S_test_vs.apb_sqncr = env.APB_agnt.apb_sqncr;
        APB_I2C_MT_write_transfer_with_S_test_vs.apb_sqncr_a = env.APB_agnt_a.apb_sqncr;
        APB_I2C_MT_write_transfer_with_S_test_vs.I2C_sqncr = env.I2C_agnt.I2C_sqncr;
        APB_I2C_MT_write_transfer_with_S_test_vs.reg_blk   = env.reg_blk;           
        APB_I2C_MT_write_transfer_with_S_test_vs.env_config = env_config;
        env_config.register_check = 0; 
        APB_I2C_MT_write_transfer_with_S_test_vs.start(null);
    endtask

    task APB_I2C_MT_write_transfer_with_P_follow_S_test_task();
        APB_I2C_MT_write_transfer_with_P_follow_S_test_virtual_sequence APB_I2C_MT_write_transfer_with_P_follow_S_test_vs = APB_I2C_MT_write_transfer_with_P_follow_S_test_virtual_sequence::type_id::create("APB_I2C_MT_write_transfer_with_P_follow_S_test_vs");
        APB_I2C_MT_write_transfer_with_P_follow_S_test_vs.apb_sqncr = env.APB_agnt.apb_sqncr;
        APB_I2C_MT_write_transfer_with_P_follow_S_test_vs.apb_sqncr_a = env.APB_agnt_a.apb_sqncr;
        APB_I2C_MT_write_transfer_with_P_follow_S_test_vs.I2C_sqncr = env.I2C_agnt.I2C_sqncr;
        APB_I2C_MT_write_transfer_with_P_follow_S_test_vs.reg_blk   = env.reg_blk;           
        APB_I2C_MT_write_transfer_with_P_follow_S_test_vs.env_config = env_config;
        env_config.register_check = 0; 
        APB_I2C_MT_write_transfer_with_P_follow_S_test_vs.start(null);
    endtask

    task APB_I2C_MT_next_write_transfer_with_RS_test_task();
        APB_I2C_MT_next_write_transfer_with_RS_test_virtual_sequence APB_I2C_MT_next_write_transfer_with_RS_test_vs = APB_I2C_MT_next_write_transfer_with_RS_test_virtual_sequence::type_id::create("APB_I2C_MT_next_write_transfer_with_RS_test_vs");
        APB_I2C_MT_next_write_transfer_with_RS_test_vs.apb_sqncr = env.APB_agnt.apb_sqncr;
        APB_I2C_MT_next_write_transfer_with_RS_test_vs.apb_sqncr_a = env.APB_agnt_a.apb_sqncr;
        APB_I2C_MT_next_write_transfer_with_RS_test_vs.I2C_sqncr = env.I2C_agnt.I2C_sqncr;
        APB_I2C_MT_next_write_transfer_with_RS_test_vs.reg_blk   = env.reg_blk;                     
        APB_I2C_MT_next_write_transfer_with_RS_test_vs.env_config = env_config;           
        env_config.register_check = 0; 
        APB_I2C_MT_next_write_transfer_with_RS_test_vs.start(null);
    endtask

    task APB_I2C_MT_write_transfer_with_slave_NACK_test_task();
        APB_I2C_MT_write_transfer_with_slave_NACK_test_virtual_sequence APB_I2C_MT_write_transfer_with_slave_NACK_test_vs = APB_I2C_MT_write_transfer_with_slave_NACK_test_virtual_sequence::type_id::create("APB_I2C_MT_write_transfer_with_slave_NACK_test_vs");
        APB_I2C_MT_write_transfer_with_slave_NACK_test_vs.apb_sqncr  = env.APB_agnt.apb_sqncr;
        APB_I2C_MT_write_transfer_with_slave_NACK_test_vs.apb_sqncr_a = env.APB_agnt_a.apb_sqncr;
        APB_I2C_MT_write_transfer_with_slave_NACK_test_vs.I2C_sqncr  = env.I2C_agnt.I2C_sqncr;
        APB_I2C_MT_write_transfer_with_slave_NACK_test_vs.reg_blk    = env.reg_blk;           
        APB_I2C_MT_write_transfer_with_slave_NACK_test_vs.env_config = env_config;           
        env_config.register_check = 0; 
        APB_I2C_MT_write_transfer_with_slave_NACK_test_vs.start(null);
    endtask

    task APB_I2C_MR_read_transfer_with_S_test_task();
        APB_I2C_MR_read_transfer_with_S_test_virtual_sequence APB_I2C_MR_read_transfer_with_S_test_vs = APB_I2C_MR_read_transfer_with_S_test_virtual_sequence::type_id::create("APB_I2C_MR_read_transfer_with_S_test_vs");
        APB_I2C_MR_read_transfer_with_S_test_vs.apb_sqncr = env.APB_agnt.apb_sqncr;
        APB_I2C_MR_read_transfer_with_S_test_vs.apb_sqncr_a = env.APB_agnt_a.apb_sqncr;
        APB_I2C_MR_read_transfer_with_S_test_vs.I2C_sqncr = env.I2C_agnt.I2C_sqncr;
        APB_I2C_MR_read_transfer_with_S_test_vs.reg_blk   = env.reg_blk;           
        APB_I2C_MR_read_transfer_with_S_test_vs.env_config = env_config;
        env_config.register_check = 0; 
        APB_I2C_MR_read_transfer_with_S_test_vs.start(null);
    endtask


    task APB_I2C_MR_read_transfer_with_P_follow_S_test_task();
        APB_I2C_MR_read_transfer_with_P_follow_S_test_virtual_sequence APB_I2C_MR_read_transfer_with_P_follow_S_test_vs = APB_I2C_MR_read_transfer_with_P_follow_S_test_virtual_sequence::type_id::create("APB_I2C_MR_read_transfer_with_P_follow_S_test_vs");
        APB_I2C_MR_read_transfer_with_P_follow_S_test_vs.apb_sqncr = env.APB_agnt.apb_sqncr;
        APB_I2C_MR_read_transfer_with_P_follow_S_test_vs.apb_sqncr_a = env.APB_agnt_a.apb_sqncr;
        APB_I2C_MR_read_transfer_with_P_follow_S_test_vs.I2C_sqncr = env.I2C_agnt.I2C_sqncr;
        APB_I2C_MR_read_transfer_with_P_follow_S_test_vs.reg_blk   = env.reg_blk;           
        APB_I2C_MR_read_transfer_with_P_follow_S_test_vs.env_config = env_config;
        env_config.register_check = 0; 
        APB_I2C_MR_read_transfer_with_P_follow_S_test_vs.start(null);
    endtask


    task APB_I2C_MR_next_read_transfer_with_RS_test_task();
        APB_I2C_MR_next_read_transfer_with_RS_test_virtual_sequence APB_I2C_MR_next_read_transfer_with_RS_test_vs = APB_I2C_MR_next_read_transfer_with_RS_test_virtual_sequence::type_id::create("APB_I2C_MR_next_read_transfer_with_RS_test_vs");
        APB_I2C_MR_next_read_transfer_with_RS_test_vs.apb_sqncr = env.APB_agnt.apb_sqncr;
        APB_I2C_MR_next_read_transfer_with_RS_test_vs.apb_sqncr_a = env.APB_agnt_a.apb_sqncr;
        APB_I2C_MR_next_read_transfer_with_RS_test_vs.I2C_sqncr = env.I2C_agnt.I2C_sqncr;
        APB_I2C_MR_next_read_transfer_with_RS_test_vs.reg_blk   = env.reg_blk;
        APB_I2C_MR_next_read_transfer_with_RS_test_vs.env_config = env_config;
        env_config.register_check = 0; 
        APB_I2C_MR_next_read_transfer_with_RS_test_vs.start(null);
    endtask

    task APB_I2C_MR_read_transfer_with_slave_NACK_test_task();
        APB_I2C_MR_read_transfer_with_slave_NACK_test_virtual_sequence APB_I2C_MR_read_transfer_with_slave_NACK_test_vs = APB_I2C_MR_read_transfer_with_slave_NACK_test_virtual_sequence::type_id::create("APB_I2C_MR_read_transfer_with_slave_NACK_test_vs");
        APB_I2C_MR_read_transfer_with_slave_NACK_test_vs.apb_sqncr = env.APB_agnt.apb_sqncr;
        APB_I2C_MR_read_transfer_with_slave_NACK_test_vs.apb_sqncr_a = env.APB_agnt_a.apb_sqncr;
        APB_I2C_MR_read_transfer_with_slave_NACK_test_vs.I2C_sqncr = env.I2C_agnt.I2C_sqncr;
        APB_I2C_MR_read_transfer_with_slave_NACK_test_vs.reg_blk   = env.reg_blk;
        APB_I2C_MR_read_transfer_with_slave_NACK_test_vs.env_config = env_config;
        env_config.register_check = 0; 
        APB_I2C_MR_read_transfer_with_slave_NACK_test_vs.start(null);
    endtask 

    task APB_I2C_M_randomize_test_task();
        APB_I2C_M_randomize_test_virtual_sequence APB_I2C_M_randomize_test_vs = APB_I2C_M_randomize_test_virtual_sequence::type_id::create("APB_I2C_M_randomize_test_vs");
        APB_I2C_M_randomize_test_vs.apb_sqncr = env.APB_agnt.apb_sqncr;
        APB_I2C_M_randomize_test_vs.apb_sqncr_a = env.APB_agnt_a.apb_sqncr;
        APB_I2C_M_randomize_test_vs.I2C_sqncr = env.I2C_agnt.I2C_sqncr;
        APB_I2C_M_randomize_test_vs.reg_blk   = env.reg_blk;
        APB_I2C_M_randomize_test_vs.env_config = env_config;
        env_config.register_check = 0; 
        APB_I2C_M_randomize_test_vs.I2C_config = I2C_config;
        APB_I2C_M_randomize_test_vs.start(null);
    endtask

    task APB_I2C_M_arbitration_SLA_WR_win_test_task(); 
        APB_I2C_M_arbitration_SLA_WR_test_virtual_sequence APB_I2C_M_arbitration_SLA_WR_test_vs = APB_I2C_M_arbitration_SLA_WR_test_virtual_sequence::type_id::create("APB_I2C_M_arbitration_SLA_WR_test_vs");
        APB_I2C_M_arbitration_SLA_WR_test_vs.apb_sqncr = env.APB_agnt.apb_sqncr;
        APB_I2C_M_arbitration_SLA_WR_test_vs.apb_sqncr_a = env.APB_agnt_a.apb_sqncr;
        APB_I2C_M_arbitration_SLA_WR_test_vs.I2C_sqncr = env.I2C_agnt.I2C_sqncr;
        APB_I2C_M_arbitration_SLA_WR_test_vs.reg_blk   = env.reg_blk;
        APB_I2C_M_arbitration_SLA_WR_test_vs.env_config = env_config;
        env_config.register_check = 0; 
        I2C_config.freq_check_off = 1;
        APB_I2C_M_arbitration_SLA_WR_test_vs.start(null);    
    endtask

    task APB_I2C_M_arbitration_SLA_WR_lost_test_task(); 
        APB_I2C_M_arbitration_SLA_WR_lost_test_virtual_sequence APB_I2C_M_arbitration_SLA_WR_lost_test_vs = APB_I2C_M_arbitration_SLA_WR_lost_test_virtual_sequence::type_id::create("APB_I2C_M_arbitration_SLA_WR_lost_test_vs");
        APB_I2C_M_arbitration_SLA_WR_lost_test_vs.apb_sqncr = env.APB_agnt.apb_sqncr;
        APB_I2C_M_arbitration_SLA_WR_lost_test_vs.apb_sqncr_a = env.APB_agnt_a.apb_sqncr;
        APB_I2C_M_arbitration_SLA_WR_lost_test_vs.I2C_sqncr = env.I2C_agnt.I2C_sqncr;
        APB_I2C_M_arbitration_SLA_WR_lost_test_vs.reg_blk   = env.reg_blk;
        APB_I2C_M_arbitration_SLA_WR_lost_test_vs.env_config = env_config;
        env_config.register_check = 0; 
        I2C_config.freq_check_off = 1;
        APB_I2C_M_arbitration_SLA_WR_lost_test_vs.start(null);    
    endtask    

    task APB_I2C_M_arbitration_in_data_transfer_win_test_task();
        APB_I2C_M_arbitration_in_data_transfer_win_test_virtual_sequence APB_I2C_M_arbitration_in_data_transfer_win_test_vs = APB_I2C_M_arbitration_in_data_transfer_win_test_virtual_sequence::type_id::create("APB_I2C_M_arbitration_in_data_transfer_win_test_vs");
        APB_I2C_M_arbitration_in_data_transfer_win_test_vs.apb_sqncr = env.APB_agnt.apb_sqncr;
        APB_I2C_M_arbitration_in_data_transfer_win_test_vs.apb_sqncr_a = env.APB_agnt_a.apb_sqncr;
        APB_I2C_M_arbitration_in_data_transfer_win_test_vs.I2C_sqncr = env.I2C_agnt.I2C_sqncr;
        APB_I2C_M_arbitration_in_data_transfer_win_test_vs.reg_blk   = env.reg_blk;
        APB_I2C_M_arbitration_in_data_transfer_win_test_vs.env_config = env_config;
        env_config.register_check = 0; 
        I2C_config.freq_check_off = 1;
        APB_I2C_M_arbitration_in_data_transfer_win_test_vs.start(null);     
    endtask

    task APB_I2C_M_arbitration_in_data_transfer_lost_test_task();
        APB_I2C_M_arbitration_in_data_transfer_lost_test_virtual_sequence APB_I2C_M_arbitration_in_data_transfer_lost_test_vs = APB_I2C_M_arbitration_in_data_transfer_lost_test_virtual_sequence::type_id::create("APB_I2C_M_arbitration_in_data_transfer_lost_test_vs");
        APB_I2C_M_arbitration_in_data_transfer_lost_test_vs.apb_sqncr = env.APB_agnt.apb_sqncr;
        APB_I2C_M_arbitration_in_data_transfer_lost_test_vs.apb_sqncr_a = env.APB_agnt_a.apb_sqncr;
        APB_I2C_M_arbitration_in_data_transfer_lost_test_vs.I2C_sqncr = env.I2C_agnt.I2C_sqncr;
        APB_I2C_M_arbitration_in_data_transfer_lost_test_vs.reg_blk   = env.reg_blk;
        APB_I2C_M_arbitration_in_data_transfer_lost_test_vs.env_config = env_config;
        env_config.register_check = 0; 
        I2C_config.freq_check_off = 1;
        APB_I2C_M_arbitration_in_data_transfer_lost_test_vs.start(null);     
    endtask

    task APB_I2C_M_synchronization_test_task();
        APB_I2C_M_synchronization_test_virtual_sequence APB_I2C_M_synchronization_test_vs = APB_I2C_M_synchronization_test_virtual_sequence::type_id::create("APB_I2C_M_synchronization_test_vs");
        APB_I2C_M_synchronization_test_vs.apb_sqncr = env.APB_agnt.apb_sqncr;
        APB_I2C_M_synchronization_test_vs.apb_sqncr_a = env.APB_agnt_a.apb_sqncr;
        APB_I2C_M_synchronization_test_vs.I2C_sqncr = env.I2C_agnt.I2C_sqncr;
        APB_I2C_M_synchronization_test_vs.reg_blk   = env.reg_blk;
        APB_I2C_M_synchronization_test_vs.env_config = env_config;
        env_config.register_check = 0; 
        I2C_config.freq_check_off = 1;
        APB_I2C_M_synchronization_test_vs.start(null);     
    endtask

    
    task APB_I2C_M_clock_stretching_test_task();
        APB_I2C_M_clock_stretching_test_virtual_sequence APB_I2C_M_clock_stretching_test_vs = APB_I2C_M_clock_stretching_test_virtual_sequence::type_id::create("APB_I2C_M_clock_stretching_test_vs");
        APB_I2C_M_clock_stretching_test_vs.apb_sqncr = env.APB_agnt.apb_sqncr;
        APB_I2C_M_clock_stretching_test_vs.apb_sqncr_a = env.APB_agnt_a.apb_sqncr;
        APB_I2C_M_clock_stretching_test_vs.I2C_sqncr = env.I2C_agnt.I2C_sqncr;
        APB_I2C_M_clock_stretching_test_vs.reg_blk   = env.reg_blk;
        APB_I2C_M_clock_stretching_test_vs.env_config = env_config;
        env_config.register_check = 0; 
        I2C_config.freq_check_off = 1;
        I2C_config.clock_stretching = 1;
        APB_I2C_M_clock_stretching_test_vs.start(null);     
    endtask

    
    task APB_I2C_M_write_collision_test_task();
        APB_I2C_M_write_collision_test_virtual_sequence APB_I2C_M_write_collision_test_vs = APB_I2C_M_write_collision_test_virtual_sequence::type_id::create("APB_I2C_M_write_collision_test_vs");
        APB_I2C_M_write_collision_test_vs.apb_sqncr = env.APB_agnt.apb_sqncr;
        APB_I2C_M_write_collision_test_vs.apb_sqncr_a = env.APB_agnt_a.apb_sqncr;
        APB_I2C_M_write_collision_test_vs.I2C_sqncr = env.I2C_agnt.I2C_sqncr;
        APB_I2C_M_write_collision_test_vs.reg_blk   = env.reg_blk;
        APB_I2C_M_write_collision_test_vs.env_config = env_config;
        env_config.register_check = 0; 
        APB_I2C_M_write_collision_test_vs.start(null);     
    endtask

    task APB_I2C_M_on_the_fly_EN_low_test_task();
        APB_I2C_M_on_the_fly_EN_low_test_virtual_sequence APB_I2C_M_on_the_fly_EN_low_test_vs = APB_I2C_M_on_the_fly_EN_low_test_virtual_sequence::type_id::create("APB_I2C_M_on_the_fly_EN_low_test_vs");
        APB_I2C_M_on_the_fly_EN_low_test_vs.apb_sqncr = env.APB_agnt.apb_sqncr;
        APB_I2C_M_on_the_fly_EN_low_test_vs.apb_sqncr_a = env.APB_agnt_a.apb_sqncr;
        APB_I2C_M_on_the_fly_EN_low_test_vs.I2C_sqncr = env.I2C_agnt.I2C_sqncr;
        APB_I2C_M_on_the_fly_EN_low_test_vs.reg_blk   = env.reg_blk;
        APB_I2C_M_on_the_fly_EN_low_test_vs.env_config = env_config;
        APB_I2C_M_on_the_fly_EN_low_test_vs.I2C_config = I2C_config;
        env_config.register_check = 0; 
        I2C_config.freq_check_off = 1;
        APB_I2C_M_on_the_fly_EN_low_test_vs.start(null);     
    endtask    

    task APB_I2C_M_on_the_fly_error_test_task();
        APB_I2C_M_on_the_fly_error_test_virtual_sequence APB_I2C_M_on_the_fly_error_test_vs = APB_I2C_M_on_the_fly_error_test_virtual_sequence::type_id::create("APB_I2C_M_on_the_fly_error_test_vs");
        APB_I2C_M_on_the_fly_error_test_vs.apb_sqncr = env.APB_agnt.apb_sqncr;
        APB_I2C_M_on_the_fly_error_test_vs.apb_sqncr_a = env.APB_agnt_a.apb_sqncr;
        APB_I2C_M_on_the_fly_error_test_vs.I2C_sqncr = env.I2C_agnt.I2C_sqncr;
        APB_I2C_M_on_the_fly_error_test_vs.reg_blk   = env.reg_blk;
        APB_I2C_M_on_the_fly_error_test_vs.env_config = env_config;
        env_config.register_check = 0; 
        I2C_config.freq_check_off = 1;
        APB_I2C_M_on_the_fly_error_test_vs.I2C_config = I2C_config;
        APB_I2C_M_on_the_fly_error_test_vs.start(null);     
    endtask    

    task APB_I2C_M_En_low_test_task();
        APB_I2C_M_En_low_test_virtual_sequence APB_I2C_M_En_low_test_vs = APB_I2C_M_En_low_test_virtual_sequence::type_id::create("APB_I2C_M_En_low_test_vs");
        APB_I2C_M_En_low_test_vs.apb_sqncr = env.APB_agnt.apb_sqncr;
        APB_I2C_M_En_low_test_vs.apb_sqncr_a = env.APB_agnt_a.apb_sqncr;
        APB_I2C_M_En_low_test_vs.I2C_sqncr = env.I2C_agnt.I2C_sqncr;
        APB_I2C_M_En_low_test_vs.reg_blk   = env.reg_blk;
        APB_I2C_M_En_low_test_vs.env_config = env_config;
        env_config.register_check = 0; 
        I2C_config.freq_check_off = 1;
        APB_I2C_M_En_low_test_vs.I2C_config = I2C_config;
        APB_I2C_M_En_low_test_vs.start(null);     
    endtask     

    task APB_I2C_MT_cov_test_task();
        APB_I2C_MT_cov_test_virtual_sequence APB_I2C_MT_cov_test_vs = APB_I2C_MT_cov_test_virtual_sequence::type_id::create("APB_I2C_MT_cov_test_vs");
        APB_I2C_MT_cov_test_vs.apb_sqncr = env.APB_agnt.apb_sqncr;
        APB_I2C_MT_cov_test_vs.apb_sqncr_a = env.APB_agnt_a.apb_sqncr;
        APB_I2C_MT_cov_test_vs.I2C_sqncr = env.I2C_agnt.I2C_sqncr;
        APB_I2C_MT_cov_test_vs.reg_blk   = env.reg_blk;
        APB_I2C_MT_cov_test_vs.env_config = env_config;
        env_config.register_check = 0; 
        I2C_config.freq_check_off = 1;
        APB_I2C_MT_cov_test_vs.I2C_config = I2C_config;
        APB_I2C_MT_cov_test_vs.start(null);     
    endtask    

endclass


class APB_I2C_master_reset_test extends APB_I2C_master_base_test;
    `uvm_component_utils(APB_I2C_master_reset_test)
    
    function new(string name="APB_I2C_master_reset_test", uvm_component parent=null);
        super.new(name, parent);
        `uvm_info(get_type_name,"APB_I2C_master_reset_test is created...",UVM_DEBUG);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info(get_type_name,"APB_I2C_master_reset_test build phase is started...",UVM_DEBUG);
        `uvm_info(get_type_name,"APB_I2C_master_reset_test build phase is ended...",UVM_DEBUG);
    endfunction
    
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info(get_type_name,"APB_I2C_master_reset_test connect phase is started...",UVM_DEBUG);
        `uvm_info(get_type_name,"APB_I2C_master_reset_test connect phase is ended...",UVM_DEBUG);
    endfunction
    
    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        `uvm_info(get_type_name,"APB_I2C_master_reset_test run phase is started...",UVM_DEBUG);
        phase.raise_objection(this);
        repeat(test_itter) APB_I2C_master_reset_test_task();
        phase.drop_objection(this);
        `uvm_info(get_type_name,"APB_I2C_master_reset_test run phase is ended...",UVM_DEBUG);
    endtask
 
endclass


class APB_I2C_register_test extends APB_I2C_master_base_test;
    `uvm_component_utils(APB_I2C_register_test)
    
    function new(string name="APB_I2C_register_test", uvm_component parent=null);
        super.new(name, parent);
        `uvm_info(get_type_name,"APB_I2C_register_test is created...",UVM_DEBUG);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info(get_type_name,"APB_I2C_register_test build phase is started...",UVM_DEBUG);
        `uvm_info(get_type_name,"APB_I2C_register_test build phase is ended...",UVM_DEBUG);
    endfunction
    
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info(get_type_name,"APB_I2C_register_test connect phase is started...",UVM_DEBUG);
        `uvm_info(get_type_name,"APB_I2C_register_test connect phase is ended...",UVM_DEBUG);
    endfunction
    
    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        `uvm_info(get_type_name,"APB_I2C_register_test run phase is started...",UVM_DEBUG);
        phase.raise_objection(this);
        repeat(test_itter) APB_I2C_register_test_task();
        phase.drop_objection(this);
        `uvm_info(get_type_name,"APB_I2C_register_test run phase is ended...",UVM_DEBUG);
    endtask
endclass


class APB_I2C_MT_write_transfer_with_S_test extends APB_I2C_master_base_test;
    `uvm_component_utils(APB_I2C_MT_write_transfer_with_S_test)
    
    function new(string name="APB_I2C_MT_write_transfer_with_S_test", uvm_component parent=null);
        super.new(name, parent);
        `uvm_info(get_type_name,"APB_I2C_MT_write_transfer_with_S_test is created...",UVM_DEBUG);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info(get_type_name,"APB_I2C_MT_write_transfer_with_S_test build phase is started...",UVM_DEBUG);
        `uvm_info(get_type_name,"APB_I2C_MT_write_transfer_with_S_test build phase is ended...",UVM_DEBUG);
    endfunction
    
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info(get_type_name,"APB_I2C_MT_write_transfer_with_S_test connect phase is started...",UVM_DEBUG);
        `uvm_info(get_type_name,"APB_I2C_MT_write_transfer_with_S_test connect phase is ended...",UVM_DEBUG);
    endfunction
    
    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        `uvm_info(get_type_name,"APB_I2C_MT_write_transfer_with_S_test run phase is started...",UVM_DEBUG);
        phase.raise_objection(this);
        repeat(test_itter) APB_I2C_MT_write_transfer_with_S_test_task();
        phase.drop_objection(this);
        `uvm_info(get_type_name,"APB_I2C_MT_write_transfer_with_S_test run phase is ended...",UVM_DEBUG);
    endtask
endclass


class APB_I2C_MT_write_transfer_with_P_follow_S_test extends APB_I2C_master_base_test;
    `uvm_component_utils(APB_I2C_MT_write_transfer_with_P_follow_S_test)
    
    function new(string name="APB_I2C_MT_write_transfer_with_P_follow_S_test", uvm_component parent=null);
        super.new(name, parent);
        `uvm_info(get_type_name,"APB_I2C_MT_write_transfer_with_P_follow_S_test is created...",UVM_DEBUG);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info(get_type_name,"APB_I2C_MT_write_transfer_with_P_follow_S_test build phase is started...",UVM_DEBUG);
        `uvm_info(get_type_name,"APB_I2C_MT_write_transfer_with_P_follow_S_test build phase is ended...",UVM_DEBUG);
    endfunction
    
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info(get_type_name,"APB_I2C_MT_write_transfer_with_P_follow_S_test connect phase is started...",UVM_DEBUG);
        `uvm_info(get_type_name,"APB_I2C_MT_write_transfer_with_P_follow_S_test connect phase is ended...",UVM_DEBUG);
    endfunction
    
    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        `uvm_info(get_type_name,"APB_I2C_MT_write_transfer_with_P_follow_S_test run phase is started...",UVM_DEBUG);
        phase.raise_objection(this);
        repeat(test_itter) APB_I2C_MT_write_transfer_with_P_follow_S_test_task();
        phase.drop_objection(this);
        `uvm_info(get_type_name,"APB_I2C_MT_write_transfer_with_P_follow_S_test run phase is ended...",UVM_DEBUG);
    endtask
endclass


class APB_I2C_MT_next_write_transfer_with_RS_test extends APB_I2C_master_base_test;
    `uvm_component_utils(APB_I2C_MT_next_write_transfer_with_RS_test)
    
    function new(string name="APB_I2C_MT_next_write_transfer_with_RS_test", uvm_component parent=null);
        super.new(name, parent);
        `uvm_info(get_type_name,"APB_I2C_MT_next_write_transfer_with_RS_test is created...",UVM_DEBUG);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info(get_type_name,"APB_I2C_MT_next_write_transfer_with_RS_test build phase is started...",UVM_DEBUG);
        `uvm_info(get_type_name,"APB_I2C_MT_next_write_transfer_with_RS_test build phase is ended...",UVM_DEBUG);
    endfunction
    
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info(get_type_name,"APB_I2C_MT_next_write_transfer_with_RS_test connect phase is started...",UVM_DEBUG);
        `uvm_info(get_type_name,"APB_I2C_MT_next_write_transfer_with_RS_test connect phase is ended...",UVM_DEBUG);
    endfunction
    
    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        `uvm_info(get_type_name,"APB_I2C_MT_next_write_transfer_with_RS_test run phase is started...",UVM_DEBUG);
        phase.raise_objection(this);
        repeat(test_itter) APB_I2C_MT_next_write_transfer_with_RS_test_task();
        phase.drop_objection(this);
        `uvm_info(get_type_name,"APB_I2C_MT_next_write_transfer_with_RS_test run phase is ended...",UVM_DEBUG);
    endtask
 
endclass


class APB_I2C_MT_write_transfer_with_slave_NACK_test extends APB_I2C_master_base_test;
    `uvm_component_utils(APB_I2C_MT_write_transfer_with_slave_NACK_test)
    
    function new(string name="APB_I2C_MT_write_transfer_with_slave_NACK_test", uvm_component parent=null);
        super.new(name, parent);
        `uvm_info(get_type_name,"APB_I2C_MT_write_transfer_with_slave_NACK_test is created...",UVM_DEBUG);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info(get_type_name,"APB_I2C_MT_write_transfer_with_slave_NACK_test build phase is started...",UVM_DEBUG);
        `uvm_info(get_type_name,"APB_I2C_MT_write_transfer_with_slave_NACK_test build phase is ended...",UVM_DEBUG);
    endfunction
    
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info(get_type_name,"APB_I2C_MT_write_transfer_with_slave_NACK_test connect phase is started...",UVM_DEBUG);
        `uvm_info(get_type_name,"APB_I2C_MT_write_transfer_with_slave_NACK_test connect phase is ended...",UVM_DEBUG);
    endfunction
    
    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        `uvm_info(get_type_name,"APB_I2C_MT_write_transfer_with_slave_NACK_test run phase is started...",UVM_DEBUG);
        phase.raise_objection(this);
        repeat(test_itter) APB_I2C_MT_write_transfer_with_slave_NACK_test_task();
        phase.drop_objection(this);
        `uvm_info(get_type_name,"APB_I2C_MT_write_transfer_with_slave_NACK_test run phase is ended...",UVM_DEBUG);
    endtask
 
endclass


class APB_I2C_MR_read_transfer_with_S_test extends APB_I2C_master_base_test;
    `uvm_component_utils(APB_I2C_MR_read_transfer_with_S_test)
    
    function new(string name="APB_I2C_MR_read_transfer_with_S_test", uvm_component parent=null);
        super.new(name, parent);
        `uvm_info(get_type_name,"APB_I2C_MR_read_transfer_with_S_test is created...",UVM_DEBUG);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info(get_type_name,"APB_I2C_MR_read_transfer_with_S_test build phase is started...",UVM_DEBUG);
        `uvm_info(get_type_name,"APB_I2C_MR_read_transfer_with_S_test build phase is ended...",UVM_DEBUG);
    endfunction
    
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info(get_type_name,"APB_I2C_MR_read_transfer_with_S_test connect phase is started...",UVM_DEBUG);
        `uvm_info(get_type_name,"APB_I2C_MR_read_transfer_with_S_test connect phase is ended...",UVM_DEBUG);
    endfunction
    
    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        `uvm_info(get_type_name,"APB_I2C_MR_read_transfer_with_S_test run phase is started...",UVM_DEBUG);
        phase.raise_objection(this);
        repeat(test_itter) APB_I2C_MR_read_transfer_with_S_test_task();
        phase.drop_objection(this);
        `uvm_info(get_type_name,"APB_I2C_MR_read_transfer_with_S_test run phase is ended...",UVM_DEBUG);
    endtask

endclass


class APB_I2C_MR_read_transfer_with_P_follow_S_test extends APB_I2C_master_base_test;
    `uvm_component_utils(APB_I2C_MR_read_transfer_with_P_follow_S_test)
    
    function new(string name="APB_I2C_MR_read_transfer_with_P_follow_S_test", uvm_component parent=null);
        super.new(name, parent);
        `uvm_info(get_type_name,"APB_I2C_MR_read_transfer_with_P_follow_S_test is created...",UVM_DEBUG);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info(get_type_name,"APB_I2C_MR_read_transfer_with_P_follow_S_test build phase is started...",UVM_DEBUG);
        `uvm_info(get_type_name,"APB_I2C_MR_read_transfer_with_P_follow_S_test build phase is ended...",UVM_DEBUG);
    endfunction
    
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info(get_type_name,"APB_I2C_MR_read_transfer_with_P_follow_S_test connect phase is started...",UVM_DEBUG);
        `uvm_info(get_type_name,"APB_I2C_MR_read_transfer_with_P_follow_S_test connect phase is ended...",UVM_DEBUG);
    endfunction
    
    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        `uvm_info(get_type_name,"APB_I2C_MR_read_transfer_with_P_follow_S_test run phase is started...",UVM_DEBUG);
        phase.raise_objection(this);
        repeat(test_itter) APB_I2C_MR_read_transfer_with_P_follow_S_test_task();
        phase.drop_objection(this);
        `uvm_info(get_type_name,"APB_I2C_MR_read_transfer_with_P_follow_S_test run phase is ended...",UVM_DEBUG);
    endtask

endclass


class APB_I2C_MR_next_read_transfer_with_RS_test extends APB_I2C_master_base_test;
    `uvm_component_utils(APB_I2C_MR_next_read_transfer_with_RS_test)
    
    function new(string name="APB_I2C_MR_next_read_transfer_with_RS_test", uvm_component parent=null);
        super.new(name, parent);
        `uvm_info(get_type_name,"APB_I2C_MR_next_read_transfer_with_RS_test is created...",UVM_DEBUG);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info(get_type_name,"APB_I2C_MR_next_read_transfer_with_RS_test build phase is started...",UVM_DEBUG);
        `uvm_info(get_type_name,"APB_I2C_MR_next_read_transfer_with_RS_test build phase is ended...",UVM_DEBUG);
    endfunction
    
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info(get_type_name,"APB_I2C_MR_next_read_transfer_with_RS_test connect phase is started...",UVM_DEBUG);
        `uvm_info(get_type_name,"APB_I2C_MR_next_read_transfer_with_RS_test connect phase is ended...",UVM_DEBUG);
    endfunction
    
    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        `uvm_info(get_type_name,"APB_I2C_MR_next_read_transfer_with_RS_test run phase is started...",UVM_DEBUG);
        phase.raise_objection(this);
        repeat(test_itter) APB_I2C_MR_next_read_transfer_with_RS_test_task();
        phase.drop_objection(this);
        `uvm_info(get_type_name,"APB_I2C_MR_next_read_transfer_with_RS_test run phase is ended...",UVM_DEBUG);
    endtask

endclass


class APB_I2C_MR_read_transfer_with_slave_NACK_test extends APB_I2C_master_base_test;
    `uvm_component_utils(APB_I2C_MR_read_transfer_with_slave_NACK_test)
    
    function new(string name="APB_I2C_MR_read_transfer_with_slave_NACK_test", uvm_component parent=null);
        super.new(name, parent);
        `uvm_info(get_type_name,"APB_I2C_MR_read_transfer_with_slave_NACK_test is created...",UVM_DEBUG);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info(get_type_name,"APB_I2C_MR_read_transfer_with_slave_NACK_test build phase is started...",UVM_DEBUG);
        `uvm_info(get_type_name,"APB_I2C_MR_read_transfer_with_slave_NACK_test build phase is ended...",UVM_DEBUG);
    endfunction
    
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info(get_type_name,"APB_I2C_MR_read_transfer_with_slave_NACK_test connect phase is started...",UVM_DEBUG);
        `uvm_info(get_type_name,"APB_I2C_MR_read_transfer_with_slave_NACK_test connect phase is ended...",UVM_DEBUG);
    endfunction
    
    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        `uvm_info(get_type_name,"APB_I2C_MR_read_transfer_with_slave_NACK_test run phase is started...",UVM_DEBUG);
        phase.raise_objection(this);
        repeat(test_itter) APB_I2C_MR_read_transfer_with_slave_NACK_test_task();
        phase.drop_objection(this);
        `uvm_info(get_type_name,"APB_I2C_MR_read_transfer_with_slave_NACK_test run phase is ended...",UVM_DEBUG);
    endtask

endclass


class APB_I2C_M_randomize_test extends APB_I2C_master_base_test;
    `uvm_component_utils(APB_I2C_M_randomize_test)
    
    function new(string name="APB_I2C_M_randomize_test", uvm_component parent=null);
        super.new(name, parent);
        `uvm_info(get_type_name,"APB_I2C_M_randomize_test is created...",UVM_DEBUG);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info(get_type_name,"APB_I2C_M_randomize_test build phase is started...",UVM_DEBUG);
        `uvm_info(get_type_name,"APB_I2C_M_randomize_test build phase is ended...",UVM_DEBUG);
    endfunction
    
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info(get_type_name,"APB_I2C_M_randomize_test connect phase is started...",UVM_DEBUG);
        `uvm_info(get_type_name,"APB_I2C_M_randomize_test connect phase is ended...",UVM_DEBUG);
    endfunction
    
    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        `uvm_info(get_type_name,"APB_I2C_M_randomize_test run phase is started...",UVM_DEBUG);
        phase.raise_objection(this);
        repeat(test_itter) APB_I2C_M_randomize_test_task();
        phase.drop_objection(this);
        `uvm_info(get_type_name,"APB_I2C_M_randomize_test run phase is ended...",UVM_DEBUG);
    endtask

endclass


class APB_I2C_M_arbitration_SLA_WR_win_test extends APB_I2C_master_base_test;
    `uvm_component_utils(APB_I2C_M_arbitration_SLA_WR_win_test)
    
    function new(string name="APB_I2C_M_arbitration_SLA_WR_win_test", uvm_component parent=null);
        super.new(name, parent);
        `uvm_info(get_type_name,"APB_I2C_M_arbitration_SLA_WR_win_test is created...",UVM_DEBUG);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info(get_type_name,"APB_I2C_M_arbitration_SLA_WR_win_test build phase is started...",UVM_DEBUG);
        `uvm_info(get_type_name,"APB_I2C_M_arbitration_SLA_WR_win_test build phase is ended...",UVM_DEBUG);
    endfunction
    
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info(get_type_name,"APB_I2C_M_arbitration_SLA_WR_win_test connect phase is started...",UVM_DEBUG);
        `uvm_info(get_type_name,"APB_I2C_M_arbitration_SLA_WR_win_test connect phase is ended...",UVM_DEBUG);
    endfunction
    
    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        `uvm_info(get_type_name,"APB_I2C_M_arbitration_SLA_WR_win_test run phase is started...",UVM_DEBUG);
        phase.raise_objection(this);
        repeat(test_itter) APB_I2C_M_arbitration_SLA_WR_win_test_task();
        phase.drop_objection(this);
        `uvm_info(get_type_name,"APB_I2C_M_arbitration_SLA_WR_win_test run phase is ended...",UVM_DEBUG);
    endtask

endclass


class APB_I2C_M_arbitration_SLA_WR_lost_test extends APB_I2C_master_base_test;
    `uvm_component_utils(APB_I2C_M_arbitration_SLA_WR_lost_test)
    
    function new(string name="APB_I2C_M_arbitration_SLA_WR_lost_test", uvm_component parent=null);
        super.new(name, parent);
        `uvm_info(get_type_name,"APB_I2C_M_arbitration_SLA_WR_lost_test is created...",UVM_DEBUG);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info(get_type_name,"APB_I2C_M_arbitration_SLA_WR_lost_test build phase is started...",UVM_DEBUG);
        `uvm_info(get_type_name,"APB_I2C_M_arbitration_SLA_WR_lost_test build phase is ended...",UVM_DEBUG);
    endfunction
    
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info(get_type_name,"APB_I2C_M_arbitration_SLA_WR_lost_test connect phase is started...",UVM_DEBUG);
        `uvm_info(get_type_name,"APB_I2C_M_arbitration_SLA_WR_lost_test connect phase is ended...",UVM_DEBUG);
    endfunction
    
    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        `uvm_info(get_type_name,"APB_I2C_M_arbitration_SLA_WR_lost_test run phase is started...",UVM_DEBUG);
        phase.raise_objection(this);
        repeat(test_itter) APB_I2C_M_arbitration_SLA_WR_lost_test_task();
        phase.drop_objection(this);
        `uvm_info(get_type_name,"APB_I2C_M_arbitration_SLA_WR_lost_test run phase is ended...",UVM_DEBUG);
    endtask

endclass


class APB_I2C_M_arbitration_in_data_transfer_win_test extends APB_I2C_master_base_test;
    `uvm_component_utils(APB_I2C_M_arbitration_in_data_transfer_win_test)
    
    function new(string name="APB_I2C_M_arbitration_in_data_transfer_win_test", uvm_component parent=null);
        super.new(name, parent);
        `uvm_info(get_type_name,"APB_I2C_M_arbitration_in_data_transfer_win_test is created...",UVM_DEBUG);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info(get_type_name,"APB_I2C_M_arbitration_in_data_transfer_win_test build phase is started...",UVM_DEBUG);
        `uvm_info(get_type_name,"APB_I2C_M_arbitration_in_data_transfer_win_test build phase is ended...",UVM_DEBUG);
    endfunction
    
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info(get_type_name,"APB_I2C_M_arbitration_in_data_transfer_win_test connect phase is started...",UVM_DEBUG);
        `uvm_info(get_type_name,"APB_I2C_M_arbitration_in_data_transfer_win_test connect phase is ended...",UVM_DEBUG);
    endfunction
    
    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        `uvm_info(get_type_name,"APB_I2C_M_arbitration_in_data_transfer_win_test run phase is started...",UVM_DEBUG);
        phase.raise_objection(this);
        repeat(test_itter) APB_I2C_M_arbitration_in_data_transfer_win_test_task();
        phase.drop_objection(this);
        `uvm_info(get_type_name,"APB_I2C_M_arbitration_in_data_transfer_win_test run phase is ended...",UVM_DEBUG);
    endtask

endclass


class APB_I2C_M_arbitration_in_data_transfer_lost_test extends APB_I2C_master_base_test;
    `uvm_component_utils(APB_I2C_M_arbitration_in_data_transfer_lost_test)
    
    function new(string name="APB_I2C_M_arbitration_in_data_transfer_lost_test", uvm_component parent=null);
        super.new(name, parent);
        `uvm_info(get_type_name,"APB_I2C_M_arbitration_in_data_transfer_lost_test is created...",UVM_DEBUG);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info(get_type_name,"APB_I2C_M_arbitration_in_data_transfer_lost_test build phase is started...",UVM_DEBUG);
        `uvm_info(get_type_name,"APB_I2C_M_arbitration_in_data_transfer_lost_test build phase is ended...",UVM_DEBUG);
    endfunction
    
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info(get_type_name,"APB_I2C_M_arbitration_in_data_transfer_lost_test connect phase is started...",UVM_DEBUG);
        `uvm_info(get_type_name,"APB_I2C_M_arbitration_in_data_transfer_lost_test connect phase is ended...",UVM_DEBUG);
    endfunction
    
    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        `uvm_info(get_type_name,"APB_I2C_M_arbitration_in_data_transfer_lost_test run phase is started...",UVM_DEBUG);
        phase.raise_objection(this);
        repeat(test_itter) APB_I2C_M_arbitration_in_data_transfer_lost_test_task();
        phase.drop_objection(this);
        `uvm_info(get_type_name,"APB_I2C_M_arbitration_in_data_transfer_lost_test run phase is ended...",UVM_DEBUG);
    endtask

endclass


class APB_I2C_M_synchronization_test extends APB_I2C_master_base_test;
    `uvm_component_utils(APB_I2C_M_synchronization_test)
    
    function new(string name="APB_I2C_M_synchronization_test", uvm_component parent=null);
        super.new(name, parent);
        `uvm_info(get_type_name,"APB_I2C_M_synchronization_test is created...",UVM_DEBUG);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info(get_type_name,"APB_I2C_M_synchronization_test build phase is started...",UVM_DEBUG);
        `uvm_info(get_type_name,"APB_I2C_M_synchronization_test build phase is ended...",UVM_DEBUG);
    endfunction
    
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info(get_type_name,"APB_I2C_M_synchronization_test connect phase is started...",UVM_DEBUG);
        `uvm_info(get_type_name,"APB_I2C_M_synchronization_test connect phase is ended...",UVM_DEBUG);
    endfunction
    
    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        `uvm_info(get_type_name,"APB_I2C_M_synchronization_test run phase is started...",UVM_DEBUG);
        phase.raise_objection(this);
        repeat(test_itter) APB_I2C_M_synchronization_test_task();
        phase.drop_objection(this);
        `uvm_info(get_type_name,"APB_I2C_M_synchronization_test run phase is ended...",UVM_DEBUG);
    endtask

endclass


class APB_I2C_M_clock_stretching_test extends APB_I2C_master_base_test;
    `uvm_component_utils(APB_I2C_M_clock_stretching_test)
    
    function new(string name="APB_I2C_M_clock_stretching_test", uvm_component parent=null);
        super.new(name, parent);
        `uvm_info(get_type_name,"APB_I2C_M_clock_stretching_test is created...",UVM_DEBUG);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info(get_type_name,"APB_I2C_M_clock_stretching_test build phase is started...",UVM_DEBUG);
        `uvm_info(get_type_name,"APB_I2C_M_clock_stretching_test build phase is ended...",UVM_DEBUG);
    endfunction
    
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info(get_type_name,"APB_I2C_M_clock_stretching_test connect phase is started...",UVM_DEBUG);
        `uvm_info(get_type_name,"APB_I2C_M_clock_stretching_test connect phase is ended...",UVM_DEBUG);
    endfunction
    
    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        `uvm_info(get_type_name,"APB_I2C_M_clock_stretching_test run phase is started...",UVM_DEBUG);
        phase.raise_objection(this);
        repeat(test_itter) APB_I2C_M_clock_stretching_test_task();
        phase.drop_objection(this);
        `uvm_info(get_type_name,"APB_I2C_M_clock_stretching_test run phase is ended...",UVM_DEBUG);
    endtask

endclass


class APB_I2C_M_write_collision_test extends APB_I2C_master_base_test;
    `uvm_component_utils(APB_I2C_M_write_collision_test)
    
    function new(string name="APB_I2C_M_write_collision_test", uvm_component parent=null);
        super.new(name, parent);
        `uvm_info(get_type_name,"APB_I2C_M_write_collision_test is created...",UVM_DEBUG);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info(get_type_name,"APB_I2C_M_write_collision_test build phase is started...",UVM_DEBUG);
        `uvm_info(get_type_name,"APB_I2C_M_write_collision_test build phase is ended...",UVM_DEBUG);
    endfunction
    
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info(get_type_name,"APB_I2C_M_write_collision_test connect phase is started...",UVM_DEBUG);
        `uvm_info(get_type_name,"APB_I2C_M_write_collision_test connect phase is ended...",UVM_DEBUG);
    endfunction
    
    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        `uvm_info(get_type_name,"APB_I2C_M_write_collision_test run phase is started...",UVM_DEBUG);
        phase.raise_objection(this);
        repeat(test_itter) APB_I2C_M_write_collision_test_task();
        phase.drop_objection(this);
        `uvm_info(get_type_name,"APB_I2C_M_write_collision_test run phase is ended...",UVM_DEBUG);
    endtask

endclass


class APB_I2C_M_on_the_fly_EN_low_test extends APB_I2C_master_base_test;
    `uvm_component_utils(APB_I2C_M_on_the_fly_EN_low_test)
    
    function new(string name="APB_I2C_M_on_the_fly_EN_low_test", uvm_component parent=null);
        super.new(name, parent);
        `uvm_info(get_type_name,"APB_I2C_M_on_the_fly_EN_low_test is created...",UVM_DEBUG);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info(get_type_name,"APB_I2C_M_on_the_fly_EN_low_test build phase is started...",UVM_DEBUG);
        `uvm_info(get_type_name,"APB_I2C_M_on_the_fly_EN_low_test build phase is ended...",UVM_DEBUG);
    endfunction
    
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info(get_type_name,"APB_I2C_M_on_the_fly_EN_low_test connect phase is started...",UVM_DEBUG);
        `uvm_info(get_type_name,"APB_I2C_M_on_the_fly_EN_low_test connect phase is ended...",UVM_DEBUG);
    endfunction
    
    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        `uvm_info(get_type_name,"APB_I2C_M_on_the_fly_EN_low_test run phase is started...",UVM_DEBUG);
        phase.raise_objection(this);
        repeat(test_itter) APB_I2C_M_on_the_fly_EN_low_test_task();
        phase.drop_objection(this);
        `uvm_info(get_type_name,"APB_I2C_M_on_the_fly_EN_low_test run phase is ended...",UVM_DEBUG);
    endtask

endclass


class APB_I2C_M_on_the_fly_error_test extends APB_I2C_master_base_test;
    `uvm_component_utils(APB_I2C_M_on_the_fly_error_test)
    
    function new(string name="APB_I2C_M_on_the_fly_error_test", uvm_component parent=null);
        super.new(name, parent);
        `uvm_info(get_type_name,"APB_I2C_M_on_the_fly_error_test is created...",UVM_DEBUG);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info(get_type_name,"APB_I2C_M_on_the_fly_error_test build phase is started...",UVM_DEBUG);
        `uvm_info(get_type_name,"APB_I2C_M_on_the_fly_error_test build phase is ended...",UVM_DEBUG);
    endfunction
    
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info(get_type_name,"APB_I2C_M_on_the_fly_error_test connect phase is started...",UVM_DEBUG);
        `uvm_info(get_type_name,"APB_I2C_M_on_the_fly_error_test connect phase is ended...",UVM_DEBUG);
    endfunction
    
    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        `uvm_info(get_type_name,"APB_I2C_M_on_the_fly_error_test run phase is started...",UVM_DEBUG);
        phase.raise_objection(this);
        repeat(test_itter) APB_I2C_M_on_the_fly_error_test_task();
        phase.drop_objection(this);
        `uvm_info(get_type_name,"APB_I2C_M_on_the_fly_error_test run phase is ended...",UVM_DEBUG);
    endtask

endclass


class APB_I2C_M_En_low_test extends APB_I2C_master_base_test;
    `uvm_component_utils(APB_I2C_M_En_low_test)
    
    function new(string name="APB_I2C_M_En_low_test", uvm_component parent=null);
        super.new(name, parent);
        `uvm_info(get_type_name,"APB_I2C_M_En_low_test is created...",UVM_DEBUG);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info(get_type_name,"APB_I2C_M_En_low_test build phase is started...",UVM_DEBUG);
        `uvm_info(get_type_name,"APB_I2C_M_En_low_test build phase is ended...",UVM_DEBUG);
    endfunction
    
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info(get_type_name,"APB_I2C_M_En_low_test connect phase is started...",UVM_DEBUG);
        `uvm_info(get_type_name,"APB_I2C_M_En_low_test connect phase is ended...",UVM_DEBUG);
    endfunction
    
    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        `uvm_info(get_type_name,"APB_I2C_M_En_low_test run phase is started...",UVM_DEBUG);
        phase.raise_objection(this);
        repeat(test_itter) APB_I2C_M_En_low_test_task();
        phase.drop_objection(this);
        `uvm_info(get_type_name,"APB_I2C_M_En_low_test run phase is ended...",UVM_DEBUG);
    endtask

endclass


class APB_I2C_MT_cov_test extends APB_I2C_master_base_test;
    `uvm_component_utils(APB_I2C_MT_cov_test)
    
    function new(string name="APB_I2C_MT_cov_test", uvm_component parent=null);
        super.new(name, parent);
        `uvm_info(get_type_name,"APB_I2C_MT_cov_test is created...",UVM_DEBUG);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info(get_type_name,"APB_I2C_MT_cov_test build phase is started...",UVM_DEBUG);
        `uvm_info(get_type_name,"APB_I2C_MT_cov_test build phase is ended...",UVM_DEBUG);
    endfunction
    
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info(get_type_name,"APB_I2C_MT_cov_test connect phase is started...",UVM_DEBUG);
        `uvm_info(get_type_name,"APB_I2C_MT_cov_test connect phase is ended...",UVM_DEBUG);
    endfunction
    
    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        `uvm_info(get_type_name,"APB_I2C_MT_cov_test run phase is started...",UVM_DEBUG);
        phase.raise_objection(this);
        repeat(test_itter) APB_I2C_MT_cov_test_task();
        phase.drop_objection(this);
        `uvm_info(get_type_name,"APB_I2C_MT_cov_test run phase is ended...",UVM_DEBUG);
    endtask

endclass

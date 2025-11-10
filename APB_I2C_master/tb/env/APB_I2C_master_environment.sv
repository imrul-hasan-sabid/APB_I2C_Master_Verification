class APB_I2C_master_environment extends uvm_env;
    `uvm_component_utils(APB_I2C_master_environment)

    APB_I2C_master_scoreboard scb;
    APB_I2C_master_predictor  pdtr;
    environment_config env_config;
    apb_agent_config apb_agnt_config;
    apb_agent_config apb_agnt_config_a;
    I2C_agent I2C_agnt;
    apb_agent APB_agnt;
    apb_agent APB_agnt_a;

    APB_I2C_master_reg_map reg_blk;

    function new(string name="APB_I2C_master_environment", uvm_component parent=null);
        super.new(name, parent);
        `uvm_info(get_type_name,"APB_I2C_master_environment is created...",UVM_DEBUG);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info(get_type_name,"APB_I2C_master_environment build phase is started...",UVM_DEBUG);
        if(!uvm_config_db#(environment_config)::get(this,"","env_config",env_config))
            `uvm_fatal("environment","environment config is not got yet")
        if(env_config.has_scoreboard) scb  = APB_I2C_master_scoreboard::type_id::create("scb",this);
        pdtr = APB_I2C_master_predictor::type_id::create("pdtr",this);
        I2C_agnt = I2C_agent::type_id::create("I2C_agnt", this);
        APB_agnt = apb_agent::type_id::create("APB_agnt", this);
        APB_agnt_a = apb_agent::type_id::create("APB_agnt_a", this);
        apb_agnt_config = apb_agent_config::type_id::create("apb_agnt_config");
        apb_agnt_config.is_active = UVM_ACTIVE;
        apb_agnt_config.has_functional_coverage = 1;

        apb_agnt_config_a = apb_agent_config::type_id::create("apb_agnt_config_a");
        apb_agnt_config_a.is_active = UVM_ACTIVE;
        apb_agnt_config_a.no_reg_model = 1;
        
        uvm_config_db#(apb_agent_config)::set(this,"APB_agnt","apb_agnt_config",apb_agnt_config);        
        uvm_config_db#(apb_agent_config)::set(this,"APB_agnt_a","apb_agnt_config",apb_agnt_config_a);        
        reg_blk = new("reg_blk");
        reg_blk.build();
        `uvm_info(get_type_name,"APB_I2C_master_environment build phase is ended...",UVM_DEBUG);
    endfunction
    
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info(get_type_name,"APB_I2C_master_environment connect phase is started...",UVM_DEBUG);
            reg_blk.default_map.set_sequencer( .sequencer(APB_agnt.apb_sqncr),
                                                   .adapter(APB_agnt.apb_adptr));            
            reg_blk.default_map.set_auto_predict( .on(1) );        
            //reg_blk.default_map.set_check_on_read( .on(1) );        
            APB_agnt.apb_mntr.reg_blk = reg_blk;
            I2C_agnt.mntr.reg_blk = reg_blk;
            APB_agnt.apb_mntr.apb_mnt2scb_port.connect(scb.apb_mnt2scb_imp);
            I2C_agnt.mntr.I2C_mnt2scb_port.connect(scb.I2C_mnt2scb_imp);
        `uvm_info(get_type_name,"APB_I2C_master_environment connect phase is ended...",UVM_DEBUG);
    endfunction
    
    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        `uvm_info(get_type_name,"APB_I2C_master_environment run phase is started...",UVM_DEBUG);
        `uvm_info(get_type_name,"APB_I2C_master_environment run phase is ended...",UVM_DEBUG);
    endtask
    
endclass

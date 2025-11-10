class apb_agent extends uvm_agent;
    `uvm_component_utils(apb_agent)

    apb_sequencer    apb_sqncr;
    apb_driver       apb_drv;
    apb_monitor      apb_mntr;
    apb_agent_config apb_agnt_config;
    APB_I2C_master_reg_adapter apb_adptr;
    apb_coverage apb_cov;
    virtual APB_I2C_master_interface vif;


    function new(string name = "apb_agent", uvm_component parent = null );
        super.new(name, parent);
        `uvm_info(get_type_name(),"apb_agent is created..",UVM_DEBUG)
    endfunction 

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info(get_type_name(),"apb_agent build phase started..",UVM_DEBUG)  
        apb_sqncr = apb_sequencer::type_id::create("apb_sqncr", this);
        if(!uvm_config_db#(apb_agent_config)::get(this,"","apb_agnt_config",apb_agnt_config))
            `uvm_fatal("apb_agent"," apb agent config is not got yet")
        if(apb_agnt_config.is_active == UVM_ACTIVE) apb_drv = apb_driver::type_id::create("apb_drv", this);
        apb_mntr = apb_monitor::type_id::create("apb_mntr", this);
        
        if(!uvm_config_db#(virtual APB_I2C_master_interface)::get(this,"","vif",vif)) 
            `uvm_fatal("apb_agent","virtual interface is not got yet")
        `uvm_info(get_type_name(),"apb_agent build phase ended..",UVM_DEBUG)
        if(!apb_agnt_config.no_reg_model) apb_adptr = APB_I2C_master_reg_adapter::type_id::create("apb_adptr");
        if(apb_agnt_config.has_functional_coverage) apb_cov = apb_coverage::type_id::create("apb_cov", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info(get_type_name(),"apb_agent connect phase started..",UVM_DEBUG)    
        apb_drv.seq_item_port.connect(apb_sqncr.seq_item_export);
        if(apb_agnt_config.has_functional_coverage) apb_mntr.apb_mnt2scb_port.connect(apb_cov.analysis_export);
        apb_drv.vif = vif;
        apb_mntr.vif = vif; 
        apb_mntr.apb_agnt_config = apb_agnt_config;
        `uvm_info(get_type_name(),"apb_agent connect phase ended..",UVM_DEBUG)
    endfunction

    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        `uvm_info(get_type_name(),"apb_agent run phase started..",UVM_DEBUG)        
        `uvm_info(get_type_name(),"apb_agent run phase ended..",UVM_DEBUG)
    endtask
endclass



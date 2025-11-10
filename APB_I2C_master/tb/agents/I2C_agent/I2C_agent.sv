
class I2C_agent extends uvm_agent;
    `uvm_component_utils(I2C_agent)

    I2C_driver drv;
    I2C_monitor mntr;
    I2C_sequencer I2C_sqncr;
    virtual APB_I2C_master_interface vif;
    I2C_agent_config I2C_config;

    function new(string name="I2C_agent", uvm_component parent=null);
        super.new(name, parent);
        `uvm_info(get_type_name,"I2C_agent is created...",UVM_DEBUG);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info(get_type_name,"I2C_agent build phase is started...",UVM_DEBUG);
        I2C_sqncr = I2C_sequencer::type_id::create("I2C_sqncr", this);
        drv   = I2C_driver::type_id::create("drv", this);
        mntr  = I2C_monitor::type_id::create("mntr", this);
        if(!uvm_config_db#(virtual APB_I2C_master_interface)::get(this,"","vif",vif)) 
            `uvm_fatal("I2C_agent","virtual interface is not got yet")
        if(!uvm_config_db#(I2C_agent_config)::get(this,"","I2C_config",I2C_config))
            `uvm_fatal("I2C_agent","I2C config is not got yet")
        `uvm_info(get_type_name,"I2C_agent build phase is ended...",UVM_DEBUG);
    endfunction
    
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info(get_type_name,"I2C_agent connect phase is started...",UVM_DEBUG);
        drv.vif = vif;
        mntr.vif = vif;
        I2C_config.vif = vif;
        mntr.I2C_config = I2C_config;
        drv.I2C_config = I2C_config;
        drv.seq_item_port.connect(I2C_sqncr.seq_item_export);
        `uvm_info(get_type_name,"I2C_agent connect phase is ended...",UVM_DEBUG);
    endfunction
    
    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        `uvm_info(get_type_name,"I2C_agent run phase is started...",UVM_DEBUG);
        `uvm_info(get_type_name,"I2C_agent run phase is ended...",UVM_DEBUG);
    endtask
    
endclass

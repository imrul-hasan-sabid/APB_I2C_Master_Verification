class APB_I2C_master_predictor extends uvm_component;
    `uvm_component_utils(APB_I2C_master_predictor)

    function new(string name="APB_I2C_master_predictor", uvm_component parent=null);
        super.new(name, parent);
        `uvm_info(get_type_name,"APB_I2C_master_predictor is created...",UVM_DEBUG);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info(get_type_name,"APB_I2C_master_predictor build phase is started...",UVM_DEBUG);
        `uvm_info(get_type_name,"APB_I2C_master_predictor build phase is ended...",UVM_DEBUG);
    endfunction
    
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info(get_type_name,"APB_I2C_master_predictor connect phase is started...",UVM_DEBUG);
        `uvm_info(get_type_name,"APB_I2C_master_predictor connect phase is ended...",UVM_DEBUG);
    endfunction
    
    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        `uvm_info(get_type_name,"APB_I2C_master_predictor run phase is started...",UVM_DEBUG);
        `uvm_info(get_type_name,"APB_I2C_master_predictor run phase is ended...",UVM_DEBUG);
    endtask
    
endclass

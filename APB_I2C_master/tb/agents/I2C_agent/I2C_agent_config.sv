class I2C_agent_config extends uvm_object;
    `uvm_object_utils(I2C_agent_config)

    bit has_functional_coverage;
    uvm_active_passive_enum is_active=UVM_PASSIVE; 
    bit freq_check_off;
    bit clock_stretching;
    virtual APB_I2C_master_interface vif;

    function new(string name="I2C_agent_config");
        super.new(name);
    endfunction

    task get_intp(output logic intp);
        @(negedge vif.PCLK);
        intp = vif.interrupt_pad_o;
    endtask
  
endclass


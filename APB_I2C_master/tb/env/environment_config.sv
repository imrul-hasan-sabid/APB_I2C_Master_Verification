class environment_config extends uvm_object;
    `uvm_object_utils(environment_config)
    bit has_scoreboard;
    int passed, failed;
    bit arbitation_lost;
    bit register_check;
    virtual APB_I2C_master_interface vif;
  
    function new(string name="environment_config");
        super.new(name);
        //if(!uvm_config_db#(virtual APB_I2C_master_interface)::get(this,"","vif",vif)) 
        //    `uvm_fatal("environment_config","virtual interface is not got yet")
    endfunction

    function void compare_data(logic [7:0]expected, logic [7:0]captured, string name);
        if(expected === captured)begin
            `uvm_info(get_type_name(),$sformatf("PASSED:: EXPECTED %s = %0h, CAPTURED %s = %0h",name, expected, name, captured),UVM_LOW)
            passed ++;
        end
        else begin
            `uvm_error(get_type_name(),$sformatf("FAILED:: EXPECTED %s = %0h, CAPTURED %s = %0h",name, expected, name, captured)) 
            failed ++;
        end
    endfunction   
    
endclass

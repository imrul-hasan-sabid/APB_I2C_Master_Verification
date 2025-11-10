class apb_agent_config extends uvm_object;
    `uvm_object_utils(apb_agent_config)

    bit has_functional_coverage;
    uvm_active_passive_enum is_active=UVM_PASSIVE; 
    bit no_reg_model;

    function new(string name="apb_agent_config");
        super.new(name);
    endfunction
  
endclass

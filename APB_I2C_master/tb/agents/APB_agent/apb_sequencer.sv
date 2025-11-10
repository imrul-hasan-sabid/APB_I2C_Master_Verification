class apb_sequencer extends uvm_sequencer#(apb_sequence_item);
    `uvm_component_utils(apb_sequencer)

    function new(string name = "apb_sequencer", uvm_component parent = null );
        super.new(name, parent);
        `uvm_info(get_type_name(),"apb_sequencer is created..",UVM_DEBUG)
    endfunction 

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info(get_type_name(),"apb_sequencer build phase started..",UVM_DEBUG)        
        `uvm_info(get_type_name(),"apb_sequencer build phase ended..",UVM_DEBUG)
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info(get_type_name(),"apb_sequencer connect phase started..",UVM_DEBUG)        
        `uvm_info(get_type_name(),"apb_sequencer connect phase ended..",UVM_DEBUG)
    endfunction

    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        `uvm_info(get_type_name(),"apb_sequencer run phase started..",UVM_DEBUG)        
        `uvm_info(get_type_name(),"apb_sequencer run phase ended..",UVM_DEBUG)
    endtask
endclass




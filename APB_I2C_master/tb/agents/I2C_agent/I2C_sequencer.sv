class I2C_sequencer extends uvm_sequencer#(I2C_sequence_item);
    `uvm_component_utils(I2C_sequencer)

    function new(string name="I2C_sequencer", uvm_component parent=null);
        super.new(name, parent);
        `uvm_info(get_type_name,"I2C_sequencer is created...",UVM_DEBUG);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info(get_type_name,"I2C_sequencer build phase is started...",UVM_DEBUG);
        `uvm_info(get_type_name,"I2C_sequencer build phase is ended...",UVM_DEBUG);
    endfunction
    
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info(get_type_name,"I2C_sequencer connect phase is started...",UVM_DEBUG);
        `uvm_info(get_type_name,"I2C_sequencer connect phase is ended...",UVM_DEBUG);
    endfunction
    
    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        `uvm_info(get_type_name,"I2C_sequencer run phase is started...",UVM_DEBUG);
        `uvm_info(get_type_name,"I2C_sequencer run phase is ended...",UVM_DEBUG);
    endtask
    
endclass

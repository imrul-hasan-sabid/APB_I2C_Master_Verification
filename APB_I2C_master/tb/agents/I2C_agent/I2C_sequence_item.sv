
class I2C_sequence_item extends uvm_sequence_item;

    rand bit wait_intp;
    rand bit wr;
    rand bit drive_ack; 
    rand bit addr_phase;
    rand logic [7:0] sda_data;
    rand bit m_sel;
    bit first_byte;

    `uvm_object_utils_begin(I2C_sequence_item)
        `uvm_field_int    (sda_data ,UVM_ALL_ON) 
    `uvm_object_utils_end

    function new(string name = "I2C_sequence_item");
        super.new(name);
    endfunction 
    
endclass




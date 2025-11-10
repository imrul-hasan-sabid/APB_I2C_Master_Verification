class I2C_base_sequence extends uvm_sequence#(I2C_sequence_item);
    `uvm_object_utils(I2C_base_sequence)

    I2C_sequence_item I2C_item;
    bit wait_intp;
    bit rnd_data;
    bit wr;
    bit drive_ack; 
    bit addr_phase;
    logic [7:0] sda_data;
    bit m_sel;
    I2C_agent_config I2C_config;
    

    function new(string name = "I2C_base_sequence");
        super.new(name);
    endfunction

    task body();
        `uvm_do_with(I2C_item ,{I2C_item.wait_intp  == local::wait_intp;
                                I2C_item.addr_phase == local::addr_phase;
                                I2C_item.drive_ack  == local::drive_ack;
                                I2C_item.wr         == local::wr;
                                I2C_item.m_sel      == local::m_sel;
                                if(rnd_data == 0) I2C_item.sda_data   == local::sda_data;
                               })        
    endtask
    
endclass







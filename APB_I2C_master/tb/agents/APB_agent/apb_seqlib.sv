class apb_base_sequence extends uvm_sequence#(apb_sequence_item);
    `uvm_object_utils(apb_base_sequence)

    apb_sequence_item apb_item;
    bit rnd;
    logic [31:0]data;
    logic [31:0]addr;
    bit rnd_data;
    bit no_op;
    int delay_cycle;
    bit x_drive;

    function new(string name = "apb_base_sequence");
        super.new(name);
    endfunction

    task body();
        `uvm_do_with(apb_item,{apb_item.PRESETn == 0;
                               apb_item.no_op   == 1;
                               apb_item.delay_cycle == local::delay_cycle; 
                              })
    endtask
    
endclass

class reset_sequence extends apb_base_sequence;
    `uvm_object_utils(reset_sequence)

    function new(string name = "reset_sequence");
        super.new(name);
    endfunction

    task body();
        `uvm_do_with(apb_item,{apb_item.PRESETn == 1;})
    endtask

endclass

class apb_write_sequence extends apb_base_sequence;
    `uvm_object_utils(apb_write_sequence)

    function new(string name = "apb_write_sequence");
        super.new(name);
    endfunction

    task body();
        `uvm_info(get_type_name()," APB WRITE SEQUENCE CALLED",UVM_DEBUG)
        
        //`uvm_do_with(apb_item,{
        //                      apb_item.PRESETn == 0;
        //                      apb_item.wr == 1;
        //                      apb_item.no_op == 0;
        //                      (rnd == 0) -> apb_item.PADDR == local::addr;
        //                      (rnd_data == 0) -> apb_item.PWDATA == local::data;
        //                      })
        `uvm_create(apb_item);
        if(!apb_item.randomize() with{
                              apb_item.PRESETn == 0;
                              apb_item.wr == 1;
                              apb_item.no_op == 0;
                              apb_item.x_drive == local::x_drive;
                              (rnd == 0) -> apb_item.PADDR == local::addr;
                              (rnd_data == 0) -> apb_item.PWDATA == local::data;
            })`uvm_error(get_type_name(),"Sequence intem is not randomized");

        start_item(apb_item);
        finish_item(apb_item);
    endtask
    
endclass

class apb_read_sequence extends apb_base_sequence;
    `uvm_object_utils(apb_read_sequence)

    function new(string name = "apb_read_sequence");
        super.new(name);
    endfunction

    task body();
        `uvm_info(get_type_name()," APB READ SEQUENCE CALLED",UVM_DEBUG)
        
        //`uvm_do_with(apb_item,{
        //                      apb_item.PRESETn == 0;
        //                      apb_item.wr == 0;
        //                      apb_item.no_op == 0;
        //                      (rnd == 0) -> (apb_item.PADDR == local::addr);
        //                      })
        `uvm_create(apb_item);
        if(!apb_item.randomize() with{
                              apb_item.PRESETn == 0;
                              apb_item.wr == 0;
                              apb_item.no_op == 0;
                              apb_item.x_drive == local::x_drive;
                              (rnd == 0) -> (apb_item.PADDR == local::addr);
            })`uvm_error(get_type_name(),"Sequence intem is not randomized");

        start_item(apb_item);
        finish_item(apb_item);                              
    endtask        
    
endclass

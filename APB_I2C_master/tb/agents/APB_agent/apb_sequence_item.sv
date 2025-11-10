class apb_sequence_item extends uvm_sequence_item;
    rand bit data_rnd;
    rand logic wr;
    rand logic PRESETn;
    rand logic [31:0]PADDR;
    rand logic [31:0]PWDATA;
    logic      [31:0]PRDATA;
    logic            PSLVERR;
    logic psel, penable, pready, slave_err;
    rand bit no_op;
    rand int delay_cycle;
    logic intp;
    rand bit x_drive;
    
    `uvm_object_utils_begin(apb_sequence_item)
        `uvm_field_int    (wr ,UVM_ALL_ON) 
        `uvm_field_int    (PRESETn ,UVM_ALL_ON) 
        `uvm_field_int    (PADDR ,UVM_ALL_ON) 
        `uvm_field_int    (PWDATA ,UVM_ALL_ON) 
        `uvm_field_int    (PRDATA ,UVM_ALL_ON) 
        `uvm_field_int    (PSLVERR ,UVM_ALL_ON) 
    `uvm_object_utils_end

    function new(string name = "apb_sequence_item");
        super.new(name);
    endfunction 

endclass




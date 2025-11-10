class apb_driver extends uvm_driver#(apb_sequence_item);
    `uvm_component_utils(apb_driver)
    
    virtual APB_I2C_master_interface vif;    
    apb_sequence_item item;

    function new(string name = "apb_driver", uvm_component parent = null );
        super.new(name, parent);
        `uvm_info(get_type_name(),"apb_driver is created..",UVM_DEBUG)
    endfunction 

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info(get_type_name(),"apb_driver build phase started..",UVM_DEBUG) 
        `uvm_info(get_type_name(),"apb_driver build phase ended..",UVM_DEBUG)
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info(get_type_name(),"apb_driver connect phase started..",UVM_DEBUG)        
        `uvm_info(get_type_name(),"apb_driver connect phase ended..",UVM_DEBUG)
    endfunction

    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        `uvm_info(get_type_name(),"apb_driver run phase started..",UVM_DEBUG)  
        forever begin
            seq_item_port.get_next_item(item);
            `uvm_info(get_type_name()," RECEIVED ITEM",UVM_HIGH)
            if(item.PRESETn === 1'b1) reset(); 
            else begin
                if(item.no_op) on_op_task();
                else begin
                    if(item.wr) apb_write();
                    else apb_read();
                end
            end        
            seq_item_port.item_done();        
        end
        `uvm_info(get_type_name(),"apb_driver run phase ended..",UVM_DEBUG)
    endtask

    task on_op_task();
        repeat(item.delay_cycle) @(negedge vif.PCLK); 
    endtask

    task reset();
        `uvm_info(get_type_name()," APB RESET TASK CALLED",UVM_HIGH)
        vif.PRESETN    <= 0;
        vif.PADDR      <= 0;   
        vif.PSEL       <= 0; 
        vif.PWDATA     <= 0; 
        vif.PWRITE     <= 0;
        vif.PENABLE    <= 0;
        vif.TM         <= 0; 
        vif.SE         <= 0; 
        repeat(2) @(negedge vif.PCLK);
        vif.PRESETN    <= 1;
    endtask

    task apb_write();
        `uvm_info(get_type_name()," APB WRITE TASK CALLED",UVM_HIGH)
        vif.PWRITE  <= 1;
        vif.PSEL    <= item.x_drive ? ($urandom_range(0,1) ? 1'bx : 1) : 1; 
        vif.PENABLE <= 0;
        vif.PADDR   <= item.PADDR;
        vif.PWDATA  <= item.PWDATA; 
        @(negedge vif.PCLK);
        vif.PSEL    <= item.x_drive ? 1'bx : 1; 
        vif.PENABLE <= 1;
        while(!vif.PREADY) @(posedge vif.PCLK); 
        @(negedge vif.PCLK);
        vif.PADDR   <= 0;   
        vif.PSEL    <= 0; 
        vif.PWDATA  <= 0; 
        vif.PWRITE  <= 0;
        vif.PENABLE <= 0;
    endtask

    task apb_read();
        `uvm_info(get_type_name()," APB READ TASK CALLED",UVM_HIGH)
        vif.PWRITE  <= 0;
        vif.PSEL    <= item.x_drive ? ($urandom_range(0,1) ? 1'bx : 1) : 1; 
        vif.PENABLE <= 0;
        vif.PADDR   <= item.PADDR;
        @(negedge vif.PCLK);
        vif.PSEL    <= item.x_drive ? 1'bx : 1; 
        vif.PENABLE <= 1;
        while(!vif.PREADY) @(posedge vif.PCLK); 
        item.PRDATA = vif.PRDATA;
        @(negedge vif.PCLK);
        vif.PADDR   <= 0;   
        vif.PSEL    <= 0; 
        vif.PWRITE  <= 0;
        vif.PENABLE <= 0;    
    endtask
    
endclass



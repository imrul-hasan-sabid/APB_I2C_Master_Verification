
class apb_monitor extends uvm_monitor;
    `uvm_component_utils(apb_monitor)

    virtual APB_I2C_master_interface vif;
    uvm_analysis_port#(apb_sequence_item) apb_mnt2pdtr_port;
    uvm_analysis_port#(apb_sequence_item) apb_mnt2scb_port;
    uvm_analysis_port#(apb_sequence_item) apb_mnt2cov_port;

    apb_sequence_item send_item;
    apb_agent_config apb_agnt_config;
    APB_I2C_master_reg_map reg_blk;
    
    function new(string name = "apb_monitor", uvm_component parent = null );
        super.new(name, parent);
        `uvm_info(get_type_name(),"apb_monitor is created..",UVM_DEBUG)
    endfunction 

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info(get_type_name(),"apb_monitor build phase started..",UVM_DEBUG)   
        apb_mnt2pdtr_port=new("apb_mnt2pdtr_port",this);
        apb_mnt2scb_port=new("apb_mnt2scb_port",this);
	apb_mnt2cov_port=new("apb_mnt2cov_port",this);
        `uvm_info(get_type_name(),"apb_monitor build phase ended..",UVM_DEBUG)
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info(get_type_name(),"apb_monitor connect phase started..",UVM_DEBUG)        
        `uvm_info(get_type_name(),"apb_monitor connect phase ended..",UVM_DEBUG)
    endfunction

    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        `uvm_info(get_type_name(),"apb_monitor run phase started..",UVM_DEBUG)        
        forever begin
            send_item=apb_sequence_item::type_id::create("send_item");
            @(posedge vif.PCLK);
            if(!vif.PRESETN) begin
                send_item.PRESETn = vif.PRESETN;
		send_item.psel    = vif.PSEL; 
		send_item.penable = vif.PENABLE;  
		send_item.pready  = vif.PREADY;
                send_item.PADDR   = vif.PADDR;
                send_item.PRDATA  = vif.PRDATA;
                send_item.PWDATA  = vif.PWDATA;
                send_item.intp    = vif.interrupt_pad_o;
                apb_mnt2scb_port.write(send_item);
                //apb_mnt2cov_port.write(send_item);
                if(!apb_agnt_config.no_reg_model) reg_blk.reset(.kind("HARD"));
                `uvm_info(get_type_name()," Got reset and reseting the reg model ",UVM_MEDIUM)
            end        
            if(vif.PREADY && vif.PENABLE && vif.PRESETN) begin
                send_item.PRESETn = vif.PRESETN;
                send_item.PADDR   = vif.PADDR;
                send_item.wr      = vif.PWRITE;
		send_item.psel    = vif.PSEL; 
		send_item.penable = vif.PENABLE;  
                send_item.PRDATA  = vif.PRDATA;
                send_item.PWDATA  = vif.PWDATA;
		send_item.pready  = vif.PREADY;
                send_item.intp    = vif.interrupt_pad_o;
                apb_mnt2scb_port.write(send_item);
                `uvm_info(get_type_name(),"Sending item to scoreboard ",UVM_HIGH)
                //`uvm_info(get_type_name(),"Sending item to reg predictor ",UVM_HIGH)
                //if(!d2m.go_bsy) begin
                //    //$display("GO_BSY IS NOT high.....");
                //    //send_item.print();
                //    apb_mnt2pdtr_port.write(send_item);
                //    apb_mnt2cov_port.write(send_item);
                //end
                ////else $display("GO_BSY IS high and error enjectiong checking is going on.....");
                //if(!vif.PWRITE) begin
                //    `uvm_info(get_type_name(),"Sending item to scoreboard ",UVM_HIGH)
                //    apb_mnt2scb_port.write(send_item);
                //end
            end

        end
        `uvm_info(get_type_name(),"apb_monitor run phase ended..",UVM_DEBUG)
    endtask
endclass



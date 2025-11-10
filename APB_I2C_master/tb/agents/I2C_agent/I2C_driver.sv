
class I2C_driver extends uvm_driver#(I2C_sequence_item);
    `uvm_component_utils(I2C_driver)
     
    I2C_sequence_item item;
    virtual APB_I2C_master_interface vif;
    bit wr;
    bit drive_ack; 
    bit addr_phase;
    bit [7:0] sda_data;
    I2C_agent_config I2C_config;

    function new(string name="I2C_driver", uvm_component parent=null);
        super.new(name, parent);
        `uvm_info(get_type_name,"I2C_driver is created...",UVM_DEBUG);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info(get_type_name,"I2C_driver build phase is started...",UVM_DEBUG);
        `uvm_info(get_type_name,"I2C_driver build phase is ended...",UVM_DEBUG);
    endfunction
    
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info(get_type_name,"I2C_driver connect phase is started...",UVM_DEBUG);
        `uvm_info(get_type_name,"I2C_driver connect phase is ended...",UVM_DEBUG);
    endfunction
    
    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        `uvm_info(get_type_name,"I2C_driver run phase is started...",UVM_DEBUG);
            forever begin
            seq_item_port.get_next_item(item);
            if(item.wait_intp) begin
                wait_for_intp();
            end
            else begin
                addr_phase = item.addr_phase;
                drive_ack  = item.drive_ack;
                wr         = item.wr;
                sda_data   = item.sda_data;
                repeat(1) @(negedge vif.PCLK); 
                fork
                    begin
                        for(int i=1; i<=9; i++)begin
                            if(wr == 0) begin
                                @(negedge vif.SCL);
                                @(posedge vif.PCLK);
                                if(i == 8) begin
                                    if(drive_ack == 1) begin
                                        vif.slv_sda_pad_o  = 0;
                                        vif.slv_sda_pad_oe = 1;
                                        @(posedge vif.SCL);
                                        assert(vif.SDA == 0); //`uvm_fatal("I2C_driver","SDA is not driven low while driving ACK")
                                    end
                                    else begin
                                        vif.slv_sda_pad_o  = 0;
                                        vif.slv_sda_pad_oe = 0;
                                        @(posedge vif.SCL);
                                        assert(vif.SDA == 1); //`uvm_fatal("I2C_driver","SDA is not driven HIGH while driving NACK")                                    
                                    end
                                end
                                else if(i == 9) begin
                                    vif.slv_sda_pad_o = 0;
                                    vif.slv_sda_pad_oe = 0;
                                    vif.slv_scl_pad_o = 0;
                                    vif.slv_scl_pad_oe = 0;
                                end
                            end
                            else begin
                                if(i<=8) begin
                                    vif.slv_sda_pad_oe = 1;
                                    vif.slv_sda_pad_o = sda_data[i];
                                end
                                @(negedge vif.SCL);
                                @(posedge vif.PCLK);
                                vif.slv_sda_pad_oe = 0;
                                vif.slv_sda_pad_o  = 0;
                            end
                            if(I2C_config.clock_stretching && i<=8) begin
                                vif.slv_scl_pad_o = 0;
                                vif.slv_scl_pad_oe = 1;                            
                                repeat($urandom_range(0,50)) @(posedge vif.PCLK); 
                                vif.slv_scl_pad_o = 0;
                                vif.slv_scl_pad_oe = 0;
                            end
                        end
                    end
                join_none
                repeat(1) @(negedge vif.PCLK); 
            end
            seq_item_port.item_done();        
            end
        `uvm_info(get_type_name,"I2C_driver run phase is ended...",UVM_DEBUG);
    endtask

    task wait_for_intp();
        if(!item.m_sel) wait(vif.interrupt_pad_o === 1'b1);
        else wait(vif.interrupt_pad_o_a === 1'b1);
        @(negedge vif.PCLK);
    endtask
    
endclass

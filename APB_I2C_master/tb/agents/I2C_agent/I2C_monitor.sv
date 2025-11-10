
class I2C_monitor extends uvm_monitor;
    `uvm_component_utils(I2C_monitor)

    I2C_sequence_item send_item;
    virtual APB_I2C_master_interface vif;
    uvm_analysis_port#(I2C_sequence_item) I2C_mnt2scb_port;
    I2C_agent_config I2C_config;

    bit prv_sda;
    bit prv_scl;
    bit busy;
    logic [7:0] sda_data;
    int count_cycle=0;
    bit first_byte;
    bit wr;
    real prv_time;
    real scl_freq;
    APB_I2C_master_reg_map reg_blk;

    function new(string name="I2C_monitor", uvm_component parent=null);
        super.new(name, parent);
        `uvm_info(get_type_name,"I2C_monitor is created...",UVM_DEBUG);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info(get_type_name,"I2C_monitor build phase is started...",UVM_DEBUG);
        I2C_mnt2scb_port = new("I2C_mnt2scb_port", this);
        `uvm_info(get_type_name,"I2C_monitor build phase is ended...",UVM_DEBUG);
    endfunction
    
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info(get_type_name,"I2C_monitor connect phase is started...",UVM_DEBUG);
        `uvm_info(get_type_name,"I2C_monitor connect phase is ended...",UVM_DEBUG);
    endfunction
    
    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        `uvm_info(get_type_name,"I2C_monitor run phase is started...",UVM_DEBUG);
        fork
            forever begin
                @(negedge vif.PCLK);
                if(vif.PRESETN) begin 
                    if(vif.SCL && (prv_sda !== vif.SDA) && prv_scl) begin
                       if(prv_sda && !vif.SDA) begin
                           busy = 1;
                           first_byte = 1;
                           wr = 0;
                           `uvm_info(get_type_name,"===================================",UVM_MEDIUM)
                           `uvm_info(get_type_name,"Start condition appeared in I2C bus",UVM_MEDIUM)
                           `uvm_info(get_type_name,"===================================",UVM_MEDIUM)
                       end
                       else if(!prv_sda && vif.SDA) begin
                           busy = 0;
                           `uvm_info(get_type_name,"===================================",UVM_MEDIUM)
                           `uvm_info(get_type_name," Stop condition appeared in I2C bus",UVM_MEDIUM)
                           `uvm_info(get_type_name,"===================================",UVM_MEDIUM)
                       end
                       count_cycle = 0;
                       sda_data    = 0;
                    end
                    if(vif.interrupt_pad_o) begin
                       count_cycle = 0;
                       sda_data    = 0;                
                    end
                    prv_sda = vif.SDA;
                    prv_scl = vif.SCL;
                end
                else begin
                    count_cycle = 0;
                    sda_data    = 0;
                    busy        = 0;
                    first_byte  = 0;
                    wr          = 0;                       
                end
            end
            
            forever begin
                @(posedge vif.SCL);
                count_cycle ++;
                if(count_cycle != 9) begin
                    sda_data = sda_data << 1;
                    sda_data[0] = vif.SDA;
                end
                if(count_cycle == 8) begin
                    send_item = I2C_sequence_item::type_id::create("send_item");
                    if(first_byte) wr = sda_data[0];
                    `uvm_info(get_type_name,"===================================",UVM_HIGH)
                    `uvm_info(get_type_name,$sformatf("A byte of data has been collected :: first_byte = %b", first_byte),UVM_HIGH)
                    `uvm_info(get_type_name,$sformatf("A byte of data has been collected :: sda_data   = %b", sda_data),UVM_HIGH)
                    `uvm_info(get_type_name,$sformatf("A byte of data has been collected :: wr         = %b", wr),UVM_HIGH)
                    send_item.sda_data   = sda_data;
                    send_item.first_byte = first_byte;
                    send_item.wr         = wr;
                    I2C_mnt2scb_port.write(send_item);
                end
                else if(count_cycle == 9) begin
                    first_byte = 0;
                end
                scl_freq = 6.329113924e6/(16 + (2*reg_blk.TWBR.get()*(4**reg_blk.TWSR.TWS.get())));
                //`uvm_info(get_type_name,$sformatf("Present time = %e, prev_time = %e, time_def = %e, freq = %e",$realtime/1s, prv_time, $realtime/1s-prv_time, 1.0/($realtime/1s-prv_time)),UVM_LOW)
                if(count_cycle>2 && !I2C_config.freq_check_off && !I2C_config.clock_stretching) checkValue("SCL Frequency", "Hz", scl_freq, 1.0/($realtime/1s-prv_time), 0.12*scl_freq);
                prv_time = $realtime/1s; 
            end
        join
        `uvm_info(get_type_name,"I2C_monitor run phase is ended...",UVM_DEBUG);
    endtask

    // checkValue
    task static checkValue; // Check value using absolute tolerance
        input  description, units, expected, actual, abstol;
        reg [8*80:0] description, units;
        real expected, actual, abstol, error;
        integer fails;
        begin
            error = abs(actual - expected);
            fails = error > max(abstol,0);
            //$display("    %0s @ %0.8es: %0s: expected=%0.8e%0s, measured=%0.8e%0s, error=%0.8e%0s.", fails !== 0 ? "FAIL" : "Pass", $realtime, description, expected, units, actual, units, error, units);
            assert(fails == 0);
        end
    endtask

    function real min(real a, real b);
        min = a>b?b:a;
    endfunction
    
    function real max(real a, real b);
        max = a>b?a:b;
    endfunction
    
    function real abs(real a);
        abs = a < 0.0 ? (-1*a) : a;
    endfunction     
    
endclass

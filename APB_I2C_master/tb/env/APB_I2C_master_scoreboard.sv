`uvm_analysis_imp_decl(_apb_mnt2scb)
`uvm_analysis_imp_decl(_I2C_mnt2scb)

class APB_I2C_master_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(APB_I2C_master_scoreboard)

    environment_config env_config;
    logic [7:0] APB_I2C_reg[int];
    uvm_analysis_imp_apb_mnt2scb #(apb_sequence_item, APB_I2C_master_scoreboard) apb_mnt2scb_imp;
    uvm_analysis_imp_I2C_mnt2scb #(I2C_sequence_item, APB_I2C_master_scoreboard) I2C_mnt2scb_imp;

    logic [7:0] expected[$];
    logic [7:0] captured[$];


    function new(string name="APB_I2C_master_scoreboard", uvm_component parent=null);
        super.new(name, parent);
        `uvm_info(get_type_name,"APB_I2C_master_scoreboard is created...",UVM_DEBUG);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info(get_type_name,"APB_I2C_master_scoreboard build phase is started...",UVM_DEBUG);
        apb_mnt2scb_imp=new("apb_mnt2scb_imp", this);
        I2C_mnt2scb_imp=new("I2C_mnt2scb_imp", this);        
        if(!uvm_config_db#(environment_config)::get(this,"","env_config",env_config))
            `uvm_fatal("scoreboard","environment config is not got yet")
        `uvm_info(get_type_name,"APB_I2C_master_scoreboard build phase is ended...",UVM_DEBUG);
    endfunction
    
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info(get_type_name,"APB_I2C_master_scoreboard connect phase is started...",UVM_DEBUG);
        `uvm_info(get_type_name,"APB_I2C_master_scoreboard connect phase is ended...",UVM_DEBUG);
    endfunction
    
    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        `uvm_info(get_type_name,"APB_I2C_master_scoreboard run phase is started...",UVM_DEBUG);
        forever begin
            wait((expected.size() == 1) && (captured.size() == 1));
            env_config.compare_data(expected.pop_front(), captured.pop_front(), "SDA_DATA");
        end
        `uvm_info(get_type_name,"APB_I2C_master_scoreboard run phase is ended...",UVM_DEBUG);
    endtask

    virtual function void write_apb_mnt2scb(apb_sequence_item received_itm);
        if(!received_itm.PRESETn) begin
            APB_I2C_reg[0 ] = 'h00;
            APB_I2C_reg[4 ] = 'hFF;
            APB_I2C_reg[8 ] = 'hF8;
            APB_I2C_reg[12] = 'hFE;
            APB_I2C_reg[16] = 'h00;
        end
        else begin
           if(received_itm.wr) begin
               //if(env_config.register_check) APB_I2C_reg[received_itm.PADDR] = received_itm.PWDATA[7:0];
               //else begin
                  if(received_itm.intp) APB_I2C_reg[received_itm.PADDR] = received_itm.PWDATA[7:0];
                  else begin
                      if(received_itm.PADDR !== 4) APB_I2C_reg[received_itm.PADDR] = received_itm.PWDATA[7:0];
                  end
               //end
           end
           else begin
               if(env_config.register_check) begin
                    `uvm_info(get_type_name(),$sformatf(" PADDR = %0h",received_itm.PADDR),UVM_LOW)
                    env_config.compare_data(APB_I2C_reg[received_itm.PADDR], received_itm.PRDATA[7:0], "PRDATA");
               end
               else begin
                    if(received_itm.PADDR == 4 && !env_config.arbitation_lost) captured.push_front(received_itm.PRDATA[7:0]);    
               end
           end
        end
    endfunction

    function write_I2C_mnt2scb(I2C_sequence_item received_itm);
        `uvm_info(get_type_name,$sformatf(" :: first_byte = %b", received_itm.first_byte),UVM_HIGH)
        `uvm_info(get_type_name,$sformatf(" :: sda_data   = %b", received_itm.sda_data),UVM_HIGH)
        `uvm_info(get_type_name,$sformatf(" :: wr         = %b", received_itm.wr),UVM_HIGH)
        if(!env_config.register_check && !env_config.arbitation_lost) begin
            if(received_itm.first_byte || !received_itm.wr) begin
                captured.push_front(received_itm.sda_data);
                expected.push_front(APB_I2C_reg[4]);
            end
            else begin
                expected.push_front(received_itm.sda_data);
            end
        end
    endfunction
    
    function void report_phase(uvm_phase phase);
    	uvm_report_server svr;
    	super.report_phase(phase);
    	svr = uvm_report_server::get_server();
    
        if(svr.get_severity_count(UVM_ERROR)== 0) begin
            `uvm_info(get_type_name(), "--------------------------------------", UVM_NONE)
            `uvm_info(get_type_name(), "----             PASSED           ----", UVM_NONE)
            `uvm_info(get_type_name(), "--------------------------------------", UVM_NONE)
        end
        else begin
            `uvm_info(get_type_name(), "--------------------------------------", UVM_NONE)
            `uvm_info(get_type_name(), "----             FAILED           ----", UVM_NONE)
            `uvm_info(get_type_name(), "--------------------------------------", UVM_NONE)
        end
        `uvm_info(get_type_name(),$sformatf("Total Test        = %0d", env_config.passed+env_config.failed),UVM_NONE)
        `uvm_info(get_type_name(),$sformatf("Total Test Passed = %0d", env_config.passed),UVM_NONE)
        `uvm_info(get_type_name(),$sformatf("Total Test Failed = %0d", env_config.failed),UVM_NONE)
    endfunction 

endclass

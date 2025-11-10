
class APB_I2C_master_basic_virtual_sequence extends uvm_sequence;
    `uvm_object_utils(APB_I2C_master_basic_virtual_sequence)

    apb_sequence_item apb_item;
    I2C_sequence_item I2C_item;
    apb_write_sequence apb_wr;
    apb_read_sequence  apb_rd;
    reset_sequence reset_seq;

    apb_sequencer apb_sqncr;
    apb_sequencer apb_sqncr_a;
    I2C_sequencer I2C_sqncr;
    APB_I2C_master_reg_map reg_blk;
    environment_config env_config;
    I2C_agent_config I2C_config;

    bit ACK;
    bit SR;
    bit STO_follow_STA;
    bit wr;
    logic intp;

    uvm_status_e   status;
    uvm_reg_data_t value, desired_value;

    bit [31:0] data_pattern[4] = {{8{4'b1010}}, {8{4'b0101}}, {8{4'hF}}, 32'b0};

    int rpt_count;
    int byte_num;

    function new(string name = "APB_I2C_master_basic_virtual_sequence");
        super.new(name);
    endfunction

    task body();
        `uvm_info(get_type_name()," APB_I2C_master_basic_virtual_sequence body task called",UVM_DEBUG)
        reset();
    endtask

    task reset(bit sqncr=0);
        `uvm_info(get_type_name()," APB RESET TASK CALLED",UVM_DEBUG)
        reset_seq = reset_sequence::type_id::create("reset_seq");
        if(sqncr == 0) reset_seq.start(apb_sqncr);
        else reset_seq.start(apb_sqncr_a); 
    endtask    

    task apb_write(bit rnd=1, bit [31:0]addr=32'h0, logic [31:0]data=32'h0, bit rnd_data=1, bit sqncr=0, bit x_drive=0);
        `uvm_info(get_type_name()," APB WRITE TASK CALLED",UVM_DEBUG)
        apb_wr = apb_write_sequence::type_id::create("apb_wr");
        apb_wr.rnd = rnd;
        apb_wr.addr=addr;
        apb_wr.data=data;
        apb_wr.rnd_data=rnd_data;
        apb_wr.x_drive=x_drive;
        if(sqncr == 0) apb_wr.start(apb_sqncr);
        else apb_wr.start(apb_sqncr_a);
    endtask

    task apb_read(bit [31:0]addr, bit sqncr=0, bit x_drive=0);
        `uvm_info(get_type_name()," APB READ TASK CALLED",UVM_DEBUG)
        apb_rd = apb_read_sequence::type_id::create("apb_rd");
        apb_rd.addr=addr;
        apb_rd.x_drive=x_drive;
        if(sqncr == 0) apb_rd.start(apb_sqncr);
        else apb_rd.start(apb_sqncr_a);
    endtask

    task no_op(int delay_cycle=1, bit sqncr=0);
        apb_base_sequence no_op_seq = apb_base_sequence::type_id::create("no_op_seq");
        no_op_seq.delay_cycle = delay_cycle;
        if(sqncr == 0) no_op_seq.start(apb_sqncr);
        else no_op_seq.start(apb_sqncr_a);
    endtask

    task wait_for_inpt(bit m_sel=0);
        I2C_base_sequence I2C_base_seq = I2C_base_sequence::type_id::create("I2C_base_seq"); 
        I2C_base_seq.m_sel = m_sel;
        I2C_base_seq.wait_intp = 1;
        I2C_base_seq.addr_phase= 0;
        I2C_base_seq.drive_ack = 0; 
        I2C_base_seq.wr        = 0;
        I2C_base_seq.sda_data  = 0;
        I2C_base_seq.start(I2C_sqncr);
    endtask

    task I2C_bus_drive(bit addr_phase=0, bit drive_ack=1, bit wr=1, logic [7:0]sda_data=0, bit rnd_data=1);
        I2C_base_sequence I2C_base_seq = I2C_base_sequence::type_id::create("I2C_base_seq"); 
        I2C_base_seq.wait_intp = 0;
        I2C_base_seq.addr_phase= addr_phase;
        I2C_base_seq.drive_ack = drive_ack ; 
        I2C_base_seq.wr        = wr        ;
        I2C_base_seq.sda_data  = sda_data  ;
        I2C_base_seq.rnd_data  = rnd_data  ;
        I2C_base_seq.start(I2C_sqncr);        
    endtask

    task SCL_clock_freq_set(bit rnd_br=1, bit rnd_sr=1, bit [7:0]br=0, bit [7:0]sr=0);        
        if(rnd_sr) begin
            reg_blk.TWSR.randomize();
            reg_blk.TWSR.update(status);
        end
        else reg_blk.TWSR.write(status, sr);    

        if(rnd_br) begin
            reg_blk.TWBR.randomize();
            reg_blk.TWBR.update(status);
        end
        else reg_blk.TWBR.write(status, br);        
    endtask

    task start_transfer(bit twint=1, bit twen=1);
        reg_blk.TWCR.TWINT.set(twint);
        reg_blk.TWCR.TWSTA.set(1);
        reg_blk.TWCR.TWSTO.set(0);
        reg_blk.TWCR.TWEN.set(twen);
        desired_value = reg_blk.TWCR.get();
        reg_blk.TWCR.write(status, desired_value);    
    endtask

    task write_addr(logic [6:0]addr=7'hF, bit wr=0, bit twint=1, bit twen=1);
        reg_blk.TWDR.write(status, {addr,wr});
        reg_blk.TWCR.TWINT.set(twint);
        reg_blk.TWCR.TWSTA.set(0);
        reg_blk.TWCR.TWSTO.set(0);
        reg_blk.TWCR.TWEN.set(twen) ;
        desired_value = reg_blk.TWCR.get();
        reg_blk.TWCR.write(status, desired_value);    
    endtask

    task write_data(bit rnd=1, logic [7:0]data=0, bit twint=1, bit twen=1);
        if(rnd) assert(reg_blk.TWDR.randomize());
        else reg_blk.TWDR.set(data);
        desired_value = reg_blk.TWDR.get();
        reg_blk.TWDR.write(status, desired_value);
        
        reg_blk.TWCR.TWINT.set(twint);
        reg_blk.TWCR.TWSTA.set(0);
        reg_blk.TWCR.TWSTO.set(0);
        reg_blk.TWCR.TWEN.set(twen) ;        
        desired_value = reg_blk.TWCR.get();
        reg_blk.TWCR.write(status, desired_value);
    endtask

    task read_data(bit ACK=1, bit twint=1, bit twen=1);
        reg_blk.TWCR.TWEA.set(ACK);
        reg_blk.TWCR.TWINT.set(twint);
        reg_blk.TWCR.TWSTA.set(0);
        reg_blk.TWCR.TWSTO.set(0);
        reg_blk.TWCR.TWEN.set(twen) ;        
        desired_value = reg_blk.TWCR.get();
        reg_blk.TWCR.write(status, desired_value);


    endtask

    task stop_transfer(bit with_S=0, bit twint=1, bit twen=1);
        reg_blk.TWCR.TWINT.set(twint)     ;
        reg_blk.TWCR.TWSTA.set(with_S);
        reg_blk.TWCR.TWSTO.set(1)     ;
        reg_blk.TWCR.TWEN.set(twen)   ;        
        desired_value = reg_blk.TWCR.get();
        reg_blk.TWCR.write(status, desired_value);
    endtask

    task check_status(logic [7:0]expected=8'hF8, string name);
        reg_blk.TWSR.read(status, value); 
        env_config.compare_data(expected, {value[7:3], 3'h0}, name); 
    endtask
    
endclass


class APB_I2C_master_reset_virtual_sequence extends APB_I2C_master_basic_virtual_sequence;
    `uvm_object_utils(APB_I2C_master_reset_virtual_sequence)

    function new(string name = "APB_I2C_master_reset_virtual_sequence");
        super.new(name);
    endfunction

    task body();
        `uvm_info(get_type_name()," APB_I2C_master_reset_virtual_sequence body task called",UVM_DEBUG)
        fork
          reset(0);
          reset(1);
        join
        rpt_count = 100;
        //repeat(rpt_count) begin
        //    assert(reg_blk.randomize());
        //    reg_blk.TWCR.TWEN.set(0);
        //    reg_blk.update(status);
        //    reset();
        //    reg_blk.mirror(status);
        //end
        reg_blk.TWBR.randomize();
        reg_blk.TWBR.update(status);
        reg_blk.TWBR.randomize();
        reg_blk.TWBR.read(status, value);

    endtask    

endclass

class APB_I2C_master_register_test_virtual_sequence extends APB_I2C_master_basic_virtual_sequence;
    `uvm_object_utils(APB_I2C_master_register_test_virtual_sequence)

    function new(string name = "APB_I2C_master_register_test_virtual_sequence");
        super.new(name);
    endfunction

    task body();
        `uvm_info(get_type_name()," APB_I2C_master_register_test_virtual_sequence body task called",UVM_DEBUG)
        fork
          reset(0);
          reset(1);
        join

        rpt_count = 20;
        repeat(rpt_count) begin
            foreach(data_pattern[i])begin
                reg_blk.TWDR.write(status, data_pattern[i]);
                reg_blk.TWSR.write(status, {6'b111110, data_pattern[i][1:0]});
                reg_blk.TWAR.write(status, data_pattern[i]);
                reg_blk.TWBR.write(status, data_pattern[i]);

                reg_blk.TWDR.read(status);
                reg_blk.TWSR.read(status);
                reg_blk.TWAR.read(status);
                reg_blk.TWBR.read(status);
            end
            foreach(data_pattern[i])begin
                reg_blk.TWDR.write(status, data_pattern[i]);
                reg_blk.TWDR.read(status);

                reg_blk.TWSR.write(status, {6'b111110, data_pattern[i][1:0]});
                reg_blk.TWSR.read(status);
                
                reg_blk.TWAR.write(status, data_pattern[i]);
                reg_blk.TWAR.read(status);
                
                reg_blk.TWBR.write(status, data_pattern[i]);
                reg_blk.TWBR.read(status);
            end
            repeat(100) begin
                assert(reg_blk.randomize());
                reg_blk.TWDR.update(status);
                reg_blk.TWSR.update(status);
                reg_blk.TWAR.update(status);
                reg_blk.TWBR.update(status);

                reg_blk.TWDR.read(status);
                reg_blk.TWSR.read(status);
                reg_blk.TWAR.read(status);
                reg_blk.TWBR.read(status);            
            end
            repeat(100) begin
                assert(reg_blk.randomize());
                reg_blk.TWDR.update(status);
                reg_blk.TWDR.read(status);

                reg_blk.TWSR.update(status);
                reg_blk.TWSR.read(status);
                
                reg_blk.TWAR.update(status);
                reg_blk.TWAR.read(status);
                
                reg_blk.TWBR.update(status);
                reg_blk.TWBR.read(status);            
            end
        end
    endtask    

endclass


class APB_I2C_MT_write_transfer_with_S_test_virtual_sequence extends APB_I2C_master_basic_virtual_sequence;
    `uvm_object_utils(APB_I2C_MT_write_transfer_with_S_test_virtual_sequence)

    function new(string name = "APB_I2C_MT_write_transfer_with_S_test_virtual_sequence");
        super.new(name);
    endfunction

    task body();
        `uvm_info(get_type_name()," APB_I2C_MT_write_transfer_with_S_test_virtual_sequence body task called",UVM_DEBUG)
        fork
          reset(0);
          reset(1);
        join   

        rpt_count = 100;

        repeat(rpt_count) begin
            SCL_clock_freq_set(.rnd_br(0), .rnd_sr(0)); 
            byte_num = $urandom_range(0,4);
            `uvm_info(get_type_name(),$sformatf("Master Transmitter :: byte_num = %0h",byte_num),UVM_LOW)

            // Transferring the start condition
            start_transfer();
            wait_for_inpt();
            check_status(.expected(8'h08), .name("STATUS STA        "));

            // Transferring the slave address 
            write_addr();
            I2C_bus_drive(.wr(0), .drive_ack(1));
            fork 
                wait_for_inpt();
                begin
                    no_op(100);
                    check_status(.expected(8'hF8), .name("STATUS INTP_LOW   "));
                end
            join              
            check_status(.expected(8'h18), .name("STATUS SLA_W_ACK  "));

            for(int i=1; i <= byte_num; i++) begin
                // Transferring the data on the I2C bus
                write_data();
                // Receiving the data from the I2C bus and driving ACK/NACK
                ACK = i != byte_num ? 1 : $urandom_range(0,1); 
                I2C_bus_drive(.wr(0), .drive_ack(ACK));
                fork 
                    wait_for_inpt();
                    begin
                        no_op(100);
                        check_status(.expected(8'hF8), .name("STATUS INTP_LOW   "));
                    end
                join                
                if(ACK) check_status(.expected(8'h28), .name("STATUS W_DATA_ACK "));
                else check_status(.expected(8'h30), .name("STATUS W_DATA_NACK"));
            end   
            reg_blk.TWBR.read(status, value);
            stop_transfer();            
        end
        no_op(10);
    endtask    
    
endclass

class APB_I2C_MT_write_transfer_with_P_follow_S_test_virtual_sequence extends APB_I2C_master_basic_virtual_sequence;
    `uvm_object_utils(APB_I2C_MT_write_transfer_with_P_follow_S_test_virtual_sequence)

    function new(string name = "APB_I2C_MT_write_transfer_with_P_follow_S_test_virtual_sequence");
        super.new(name);
    endfunction

    task body();
        `uvm_info(get_type_name()," APB_I2C_MT_write_transfer_with_P_follow_S_test_virtual_sequence body task called",UVM_DEBUG)
        fork
          reset(0);
          reset(1);
        join   

        rpt_count = 100;
        STO_follow_STA = 0;

        repeat(rpt_count) begin
            SCL_clock_freq_set(.rnd_br(0), .rnd_sr(0)); 
            byte_num = $urandom_range(0,4);
            `uvm_info(get_type_name(),$sformatf("Master Transmitter :: byte_num = %0h",byte_num),UVM_LOW)

            // Transferring the start condition
            if(!STO_follow_STA) start_transfer();
            wait_for_inpt();
            check_status(.expected(8'h08), .name("STATUS STA        "));

            // Transferring the slave address 
            write_addr();
            I2C_bus_drive(.wr(0), .drive_ack(1));
            fork 
                wait_for_inpt();
                begin
                    no_op(100);
                    check_status(.expected(8'hF8), .name("STATUS INTP_LOW   "));
                end
            join              
            check_status(.expected(8'h18), .name("STATUS SLA_W_ACK  "));

            for(int i=1; i <= byte_num; i++) begin
                // Transferring the data on the I2C bus
                write_data();
                // Receiving the data from the I2C bus and driving ACK/NACK
                ACK = i != byte_num ? 1 : $urandom_range(0,1); 
                I2C_bus_drive(.wr(0), .drive_ack(ACK));
                fork 
                    wait_for_inpt();
                    begin
                        no_op(100);
                        check_status(.expected(8'hF8), .name("STATUS INTP_LOW   "));
                    end
                join                
                if(ACK) check_status(.expected(8'h28), .name("STATUS W_DATA_ACK "));
                else check_status(.expected(8'h30), .name("STATUS W_DATA_NACK"));
            end   
            reg_blk.TWBR.read(status, value);
            STO_follow_STA = 1;
            stop_transfer(.with_S(STO_follow_STA));
        end
        no_op(10);
    endtask    
    
endclass


class APB_I2C_MT_next_write_transfer_with_RS_test_virtual_sequence extends APB_I2C_master_basic_virtual_sequence;
    `uvm_object_utils(APB_I2C_MT_next_write_transfer_with_RS_test_virtual_sequence)

    function new(string name = "APB_I2C_MT_next_write_transfer_with_RS_test_virtual_sequence");
        super.new(name);
    endfunction

    task body();
        `uvm_info(get_type_name()," APB_I2C_MT_next_write_transfer_with_RS_test_virtual_sequence body task called",UVM_DEBUG)
        fork
          reset(0);
          reset(1);
        join
        
        rpt_count = 100;
        SR = 0;
        
        for(int j=1; j<=rpt_count; j++) begin
            SCL_clock_freq_set(.rnd_br(0), .rnd_sr(0));
            byte_num = $urandom_range(0,4);
            `uvm_info(get_type_name(),$sformatf("Master Transmitter :: byte_num = %0h",byte_num),UVM_LOW)

            // Transferring the start condition
            start_transfer();
            wait_for_inpt();
            if(!SR) check_status(.expected(8'h08), .name("STATUS STA        "));
            else check_status(.expected(8'h10), .name("STATUS R_STA      "));

            // Transferring the slave address 
            write_addr();
            I2C_bus_drive(.wr(0), .drive_ack(1));
            fork 
                wait_for_inpt();
                begin
                    no_op(100);
                    check_status(.expected(8'hF8), .name("STATUS INTP_LOW   "));
                end
            join            
            check_status(.expected(8'h18), .name("STATUS SLA_W_ACK  "));

            for(int i=1; i <= byte_num; i++) begin
                // Transferring the data on the I2C bus
                write_data();
                // Receiving the data from the I2C bus and driving ACK/NACK
                ACK = i != byte_num ? 1 : $urandom_range(0,1); 
                I2C_bus_drive(.wr(0), .drive_ack(ACK));
                fork 
                    wait_for_inpt();
                    begin
                        no_op(100);
                        check_status(.expected(8'hF8), .name("STATUS INTP_LOW   "));
                    end
                join                
                if(ACK) check_status(.expected(8'h28), .name("STATUS W_DATA_ACK "));
                else check_status(.expected(8'h30), .name("STATUS W_DATA_NACK"));
            end           
            reg_blk.TWBR.read(status, value);
            
            SR = j != rpt_count ? 1 : 0;
            if(!SR) stop_transfer();
        end
        no_op(20);
    endtask    
    
endclass


class APB_I2C_MT_write_transfer_with_slave_NACK_test_virtual_sequence extends APB_I2C_master_basic_virtual_sequence;
    `uvm_object_utils(APB_I2C_MT_write_transfer_with_slave_NACK_test_virtual_sequence)

    function new(string name = "APB_I2C_MT_write_transfer_with_slave_NACK_test_virtual_sequence");
        super.new(name);
    endfunction

    task body();
        `uvm_info(get_type_name(),"APB_I2C_MT_write_transfer_with_slave_NACK_test_virtual_sequence body task called",UVM_DEBUG)
        fork
          reset(0);
          reset(1);
        join
        
        rpt_count = 100;
        SR = 0;
        
        for(int j=1; j<=rpt_count; j++) begin
            SCL_clock_freq_set(.rnd_br(0), .rnd_sr(0));
            byte_num = $urandom_range(0,4);
            `uvm_info(get_type_name(),$sformatf("Master Transmitter :: byte_num = %0h",byte_num),UVM_LOW)

            // Transferring the start condition
            start_transfer();
            wait_for_inpt();
            if(!SR) check_status(.expected(8'h08), .name("STATUS STA        "));
            else check_status(.expected(8'h10), .name("STATUS R_STA      "));

            // Transferring the slave address 
            write_addr(.addr($urandom_range(15, 127)));
            I2C_bus_drive(.wr(0), .drive_ack(0));
            fork 
                wait_for_inpt();
                begin
                    no_op(100);
                    check_status(.expected(8'hF8), .name("STATUS INTP_LOW   "));
                end
            join            
            check_status(.expected(8'h20), .name("STATUS SLA_W_NACK "));
            reg_blk.TWBR.read(status, value);
            
            SR = j != rpt_count ? $urandom_range(0,1) : 0;
            if(!SR) stop_transfer();
        end
        no_op(20);
    endtask    
    
endclass


class APB_I2C_MR_read_transfer_with_S_test_virtual_sequence extends APB_I2C_master_basic_virtual_sequence;
    `uvm_object_utils(APB_I2C_MR_read_transfer_with_S_test_virtual_sequence)

    function new(string name = "APB_I2C_MR_read_transfer_with_S_test_virtual_sequence");
        super.new(name);
    endfunction

    task body();
        `uvm_info(get_type_name()," APB_I2C_MR_read_transfer_with_S_test_virtual_sequence body task called",UVM_DEBUG)
        fork
          reset(0);
          reset(1);
        join   

        rpt_count = 100;

        repeat(rpt_count) begin
            SCL_clock_freq_set(.rnd_br(0), .rnd_sr(0)); 
            byte_num = $urandom_range(0,4);
            `uvm_info(get_type_name(),$sformatf("Master Transmitter :: byte_num = %0h",byte_num),UVM_LOW)

            // Transferring the start condition
            start_transfer();
            wait_for_inpt();
            check_status(.expected(8'h08), .name("STATUS STA        "));

            // Transferring the slave address 
            write_addr(.wr(1));
            I2C_bus_drive(.wr(0), .drive_ack(1));
            fork 
                wait_for_inpt();
                begin
                    no_op(100);
                    check_status(.expected(8'hF8), .name("STATUS INTP_LOW   "));
                end
            join             
            check_status(.expected(8'h40), .name("STATUS SLA_R_ACK  "));

            for(int i=1; i <= byte_num; i++) begin
                // Receiving data from the I2C bus
                ACK = i != byte_num ? 1 : 0; //$urandom_range(0,1); 
                read_data(ACK);
                // Transferring the data on the I2C bus and driving ACK/NACK
                I2C_bus_drive(.wr(1), .rnd_data(1));
                fork 
                    wait_for_inpt();
                    begin
                        no_op(100);
                        check_status(.expected(8'hF8), .name("STATUS INTP_LOW   "));
                    end
                join                 
                reg_blk.TWDR.read(status, value);
                if(ACK) check_status(.expected(8'h50), .name("STATUS R_DATA_ACK "));
                else check_status(.expected(8'h58), .name("STATUS R_DATA_NACK"));
            end   
            reg_blk.TWBR.read(status, value);

            stop_transfer();            
        end
        no_op(20);
    endtask    
    
endclass


class APB_I2C_MR_read_transfer_with_P_follow_S_test_virtual_sequence extends APB_I2C_master_basic_virtual_sequence;
    `uvm_object_utils(APB_I2C_MR_read_transfer_with_P_follow_S_test_virtual_sequence)

    function new(string name = "APB_I2C_MR_read_transfer_with_P_follow_S_test_virtual_sequence");
        super.new(name);
    endfunction

    task body();
        `uvm_info(get_type_name()," APB_I2C_MR_read_transfer_with_P_follow_S_test_virtual_sequence body task called",UVM_DEBUG)
        fork
          reset(0);
          reset(1);
        join   

        rpt_count = 100;
        STO_follow_STA = 0;

        repeat(rpt_count) begin
            SCL_clock_freq_set(.rnd_br(0), .rnd_sr(0)); 
            byte_num = $urandom_range(0,4);
            `uvm_info(get_type_name(),$sformatf("Master Transmitter :: byte_num = %0h",byte_num),UVM_LOW)

            // Transferring the start condition
            if(!STO_follow_STA) start_transfer();
            wait_for_inpt();
            check_status(.expected(8'h08), .name("STATUS STA        "));

            // Transferring the slave address 
            write_addr(.wr(1));
            I2C_bus_drive(.wr(0), .drive_ack(1));
            fork 
                wait_for_inpt();
                begin
                    no_op(100);
                    check_status(.expected(8'hF8), .name("STATUS INTP_LOW   "));
                end
            join             
            check_status(.expected(8'h40), .name("STATUS SLA_R_ACK  "));

            for(int i=1; i <= byte_num; i++) begin
                // Receiving data from the I2C bus
                ACK = i != byte_num ? 1 : 0; //$urandom_range(0,1); 
                read_data(ACK);
                // Transferring the data on the I2C bus and driving ACK/NACK
                I2C_bus_drive(.wr(1), .rnd_data(1));
                fork 
                    wait_for_inpt();
                    begin
                        no_op(100);
                        check_status(.expected(8'hF8), .name("STATUS INTP_LOW   "));
                    end
                join                 
                reg_blk.TWDR.read(status, value);
                if(ACK) check_status(.expected(8'h50), .name("STATUS R_DATA_ACK "));
                else check_status(.expected(8'h58), .name("STATUS R_DATA_NACK"));
            end   
            reg_blk.TWBR.read(status, value);
            STO_follow_STA = 1;
            stop_transfer(.with_S(STO_follow_STA));            
        end
        no_op(20);
    endtask    
    
endclass


class APB_I2C_MR_next_read_transfer_with_RS_test_virtual_sequence extends APB_I2C_master_basic_virtual_sequence;
    `uvm_object_utils(APB_I2C_MR_next_read_transfer_with_RS_test_virtual_sequence)

    function new(string name = "APB_I2C_MR_next_read_transfer_with_RS_test_virtual_sequence");
        super.new(name);
    endfunction

    task body();
        `uvm_info(get_type_name()," APB_I2C_MR_next_read_transfer_with_RS_test_virtual_sequence body task called",UVM_DEBUG)
        fork
          reset(0);
          reset(1);
        join   

        rpt_count = 100;
        SR = 0;

        for(int j=1; j<=rpt_count; j++) begin
            SCL_clock_freq_set(.rnd_br(0), .rnd_sr(0)); 
            byte_num = $urandom_range(0,4);
            `uvm_info(get_type_name(),$sformatf("Master Transmitter :: byte_num = %0h",byte_num),UVM_LOW)

            // Transferring the start condition
            start_transfer();
            wait_for_inpt();
            if(!SR) check_status(.expected(8'h08), .name("STATUS STA        "));
            else check_status(.expected(8'h10), .name("STATUS R_STA      "));

            // Transferring the slave address 
            write_addr(.wr(1));
            I2C_bus_drive(.wr(0), .drive_ack(1));
            fork 
                wait_for_inpt();
                begin
                    no_op(100);
                    check_status(.expected(8'hF8), .name("STATUS INTP_LOW   "));
                end
            join             
            check_status(.expected(8'h40), .name("STATUS SLA_R_ACK  "));

            for(int i=1; i <= byte_num; i++) begin
                // Receiving data from the I2C bus
                ACK = i != byte_num ? 1 : 0; //$urandom_range(0,1); 
                read_data(ACK);
                // Transferring the data on the I2C bus and driving ACK/NACK
                I2C_bus_drive(.wr(1), .rnd_data(1));
                fork 
                    wait_for_inpt();
                    begin
                        no_op(100);
                        check_status(.expected(8'hF8), .name("STATUS INTP_LOW   "));
                    end
                join                 
                reg_blk.TWDR.read(status, value);
                if(ACK) check_status(.expected(8'h50), .name("STATUS R_DATA_ACK "));
                else check_status(.expected(8'h58), .name("STATUS R_DATA_NACK"));
            end   
            reg_blk.TWBR.read(status, value);

            SR = j != rpt_count ? 1 : 0;
            if(!SR) stop_transfer();
        end
        no_op(20);
    endtask    
endclass



class APB_I2C_MR_read_transfer_with_slave_NACK_test_virtual_sequence extends APB_I2C_master_basic_virtual_sequence;
    `uvm_object_utils(APB_I2C_MR_read_transfer_with_slave_NACK_test_virtual_sequence)

    function new(string name = "APB_I2C_MR_read_transfer_with_slave_NACK_test_virtual_sequence");
        super.new(name);
    endfunction

    task body();
        `uvm_info(get_type_name()," APB_I2C_MR_read_transfer_with_slave_NACK_test_virtual_sequence body task called",UVM_DEBUG)
        fork
          reset(0);
          reset(1);
        join    

        rpt_count = 100;
        SR = 0;

        for(int j=1; j<=rpt_count; j++) begin
            SCL_clock_freq_set(.rnd_br(0), .rnd_sr(0)); 
            byte_num = $urandom_range(0,4);
            `uvm_info(get_type_name(),$sformatf("Master Transmitter :: byte_num = %0h",byte_num),UVM_LOW)

            // Transferring the start condition
            start_transfer();
            wait_for_inpt();
            if(!SR) check_status(.expected(8'h08), .name("STATUS STA        "));
            else check_status(.expected(8'h10), .name("STATUS R_STA      "));

            // Transferring the slave address 
            write_addr(.addr($urandom_range(15, 127)), .wr(1));
            I2C_bus_drive(.wr(0), .drive_ack(0));
            fork 
                wait_for_inpt();
                begin
                    no_op(100);
                    check_status(.expected(8'hF8), .name("STATUS INTP_LOW   "));
                end
            join            
            check_status(.expected(8'h48), .name("STATUS SLA_R_NACK "));
            reg_blk.TWBR.read(status, value);

            SR = j != rpt_count ? $urandom_range(0,1) : 0;
            if(!SR) stop_transfer();
        end
        no_op(10);
    endtask    
    
endclass


class APB_I2C_M_randomize_test_virtual_sequence extends APB_I2C_master_basic_virtual_sequence;
    `uvm_object_utils(APB_I2C_M_randomize_test_virtual_sequence)


    function new(string name = "APB_I2C_M_randomize_test_virtual_sequence");
        super.new(name);
    endfunction

    task body();
        `uvm_info(get_type_name()," APB_I2C_M_randomize_test_virtual_sequence body task called",UVM_DEBUG)
        fork
          reset(0);
          reset(1);
        join  

        rpt_count = 100;
        STO_follow_STA = 0;
        SR = 0;

        for(int j=1; j<=rpt_count; j++) begin
            SCL_clock_freq_set(.rnd_br(0), .rnd_sr(0)); 
            byte_num = $urandom_range(0,4);
            `uvm_info(get_type_name(),$sformatf("Master Transmitter :: byte_num = %0h",byte_num),UVM_LOW)

            // Transferring the start condition
            if(!STO_follow_STA) start_transfer();
            wait_for_inpt();
            if(!SR) check_status(.expected(8'h08), .name("STATUS STA        "));
            else check_status(.expected(8'h10), .name("STATUS R_STA      "));

            // Transferring the slave address 
            wr = $urandom_range(0,1);
            ACK = $urandom_range(0,1); 
            write_addr(.wr(wr));
            I2C_bus_drive(.wr(0), .drive_ack(ACK));
            fork 
                wait_for_inpt();
                begin
                    no_op(100);
                    check_status(.expected(8'hF8), .name("STATUS INTP_LOW   "));
                end
            join

            if(wr) begin
                if(ACK) check_status(.expected(8'h40), .name("STATUS SLA_R_ACK  "));
                else check_status(.expected(8'h48), .name("STATUS SLA_R_NACK "));
            end
            else begin
                if(ACK) check_status(.expected(8'h18), .name("STATUS SLA_W_ACK  "));
                else check_status(.expected(8'h20), .name("STATUS SLA_W_NACK "));
            end

            if(wr && ACK) begin
                for(int i=1; i <= byte_num; i++) begin
                    // Receiving data from the I2C bus
                    ACK = i != byte_num ? 1 : 0; //$urandom_range(0,1); 
                    read_data(ACK);
                    // Transferring the data on the I2C bus and driving ACK/NACK
                    I2C_bus_drive(.wr(1), .rnd_data(1));
                    fork 
                        wait_for_inpt();
                        begin
                            no_op(100);
                            check_status(.expected(8'hF8), .name("STATUS INTP_LOW   "));
                        end
                    join                    
                    reg_blk.TWDR.read(status, value);
                    if(ACK) check_status(.expected(8'h50), .name("STATUS R_DATA_ACK "));
                    else check_status(.expected(8'h58), .name("STATUS R_DATA_NACK"));
                end             
            end
            else if(!wr && ACK) begin
                for(int i=1; i <= byte_num; i++) begin
                    // Transferring the data on the I2C bus
                    write_data();
                    // Receiving the data from the I2C bus and driving ACK/NACK
                    ACK = i != byte_num ? 1 : $urandom_range(0,1); 
                    I2C_bus_drive(.wr(0), .drive_ack(ACK));
                    fork 
                        wait_for_inpt();
                        begin
                            no_op(100);
                            check_status(.expected(8'hF8), .name("STATUS INTP_LOW   "));
                        end
                    join                    
                    if(ACK) check_status(.expected(8'h28), .name("STATUS W_DATA_ACK "));
                    else check_status(.expected(8'h30), .name("STATUS W_DATA_NACK"));
                end            
            end
            reg_blk.TWBR.read(status, value);
            
            SR = j != rpt_count ? $urandom_range(0,1) : 0;
            if(!SR) begin
                STO_follow_STA = $urandom_range(0,1);
                //`uvm_info(get_type_name(),$sformatf("MT :: STO_follow_STA = %0b",STO_follow_STA),UVM_LOW)
                stop_transfer(.with_S(STO_follow_STA));
            end
            else STO_follow_STA = 0;
        end
        no_op(20);
    endtask    
    
endclass


class APB_I2C_M_arbitration_SLA_WR_test_virtual_sequence extends APB_I2C_master_basic_virtual_sequence;
    `uvm_object_utils(APB_I2C_M_arbitration_SLA_WR_test_virtual_sequence)

    function new(string name = "APB_I2C_M_arbitration_SLA_WR_test_virtual_sequence");
        super.new(name);
    endfunction

    task body();
        `uvm_info(get_type_name()," APB_I2C_M_arbitration_SLA_WR_test_virtual_sequence body task called",UVM_DEBUG)
        fork
          reset(0);
          reset(1);
        join

        rpt_count = 100;
        SR = 0;  
        
        for(int j=1; j<=rpt_count; j++) begin
            SCL_clock_freq_set(.rnd_br(1), .rnd_sr(1));
            apb_write(.sqncr(1), .rnd(0), .rnd_data(1), .addr(reg_blk.TWBR.get_address()), .data(reg_blk.TWBR.get()));
            apb_write(.sqncr(1), .rnd(0), .rnd_data(1), .addr(reg_blk.TWSR.get_address()), .data(reg_blk.TWSR.TWPS.get()));
            byte_num = $urandom_range(0,4);
            `uvm_info(get_type_name(),$sformatf("MT :: byte_num = %0h",byte_num),UVM_LOW)

            // Transferring the start condition
            fork
                start_transfer();
                apb_write(.sqncr(1), .rnd(0), .rnd_data(0), .addr(reg_blk.TWCR.get_address()), .data(8'b10100100));
            join
            wait_for_inpt();
            if(!SR) check_status(.expected(8'h08), .name("STATUS STA        "));
            else check_status(.expected(8'h10), .name("STATUS R_STA      "));

            // Transferring the slave address 
            wr = $urandom_range(0,1);
            ACK = $urandom_range(0,1); 
            `uvm_info(get_type_name(),$sformatf("Slv :: ACK = %0h",ACK),UVM_LOW)
            fork
                write_addr(.wr(wr));
                begin
                    apb_write(.sqncr(1), .rnd(0), .rnd_data(0), .addr(reg_blk.TWDR.get_address()), .data({$urandom_range(1,7), 4'hF, wr}));
                    apb_write(.sqncr(1), .rnd(0), .rnd_data(0), .addr(reg_blk.TWCR.get_address()), .data(8'b10000100));
                end
            join
            I2C_bus_drive(.wr(0), .drive_ack(ACK));
            fork 
                wait_for_inpt();
                begin
                    no_op(100);
                    check_status(.expected(8'hF8), .name("STATUS INTP_LOW   "));
                end
            join            
            
            if(wr) begin
                if(ACK) check_status(.expected(8'h40), .name("STATUS SLA_R_ACK  "));
                else check_status(.expected(8'h48), .name("STATUS SLA_R_NACK "));
            end
            else begin
                if(ACK) check_status(.expected(8'h18), .name("STATUS SLA_W_ACK  "));
                else check_status(.expected(8'h20), .name("STATUS SLA_W_NACK "));
            end            

            if(wr && ACK) begin
                for(int i=1; i <= byte_num; i++) begin
                    // Receiving data from the I2C bus
                    ACK = i != byte_num ? 1 : 0; //$urandom_range(0,1); 
                    fork
                        read_data(ACK);
                        apb_write(.sqncr(1), .rnd(0), .rnd_data(0), .addr(reg_blk.TWCR.get_address()), .data(8'b10000100));
                    join
                    // Transferring the data on the I2C bus and driving ACK/NACK
                    I2C_bus_drive(.wr(1), .rnd_data(1));
                    fork 
                        wait_for_inpt();
                        begin
                            no_op(100);
                            check_status(.expected(8'hF8), .name("STATUS INTP_LOW   "));
                        end
                    join                     
                    reg_blk.TWDR.read(status, value);
                    if(ACK) check_status(.expected(8'h50), .name("STATUS R_DATA_ACK "));
                    else check_status(.expected(8'h58), .name("STATUS R_DATA_NACK"));
                end             
            end
            else if(!wr && ACK) begin
                for(int i=1; i <= byte_num; i++) begin
                    // Transferring the data on the I2C bus
                    fork
                        write_data();
                        begin
                            apb_write(.sqncr(1), .rnd(0), .rnd_data(1), .addr(reg_blk.TWDR.get_address()));
                            apb_write(.sqncr(1), .rnd(0), .rnd_data(0), .addr(reg_blk.TWCR.get_address()), .data(8'b10000100));
                        end
                    join                
                    // Receiving the data from the I2C bus and driving ACK/NACK
                    ACK = i != byte_num ? 1 : $urandom_range(0,1); 
                    I2C_bus_drive(.wr(0), .drive_ack(ACK));
                    fork 
                        wait_for_inpt();
                        begin
                            no_op(100);
                            check_status(.expected(8'hF8), .name("STATUS INTP_LOW   "));
                        end
                    join                    
                    if(ACK) check_status(.expected(8'h28), .name("STATUS W_DATA_ACK "));
                    else check_status(.expected(8'h30), .name("STATUS W_DATA_NACK"));
                end             
            end
            reg_blk.TWBR.read(status, value);

            SR = j != rpt_count ? $urandom_range(0,1) : 0;
            if(!SR) stop_transfer();
        end
        no_op(10);
    endtask
endclass


class APB_I2C_M_arbitration_SLA_WR_lost_test_virtual_sequence extends APB_I2C_master_basic_virtual_sequence;
    `uvm_object_utils(APB_I2C_M_arbitration_SLA_WR_lost_test_virtual_sequence)

    function new(string name = "APB_I2C_M_arbitration_SLA_WR_lost_test_virtual_sequence");
        super.new(name);
    endfunction

    task body();
        `uvm_info(get_type_name()," APB_I2C_M_arbitration_SLA_WR_lost_test_virtual_sequence body task called",UVM_DEBUG)
        env_config.arbitation_lost = 1;
        fork
          reset(0);
          reset(1);
        join

        rpt_count = 100;
        SR = 0;  
        
        for(int j=1; j<=rpt_count; j++) begin
            SCL_clock_freq_set(.rnd_br(1), .rnd_sr(1));
            apb_write(.sqncr(1), .rnd(0), .rnd_data(1), .addr(reg_blk.TWBR.get_address()), .data(reg_blk.TWBR.get()));
            apb_write(.sqncr(1), .rnd(0), .rnd_data(1), .addr(reg_blk.TWSR.get_address()), .data(reg_blk.TWSR.TWPS.get()));
            byte_num = $urandom_range(0,4);
            `uvm_info(get_type_name(),$sformatf("MT :: byte_num = %0h",byte_num),UVM_LOW)

            // Transferring the start condition
            fork
                start_transfer();
                apb_write(.sqncr(1), .rnd(0), .rnd_data(0), .addr(reg_blk.TWCR.get_address()), .data(8'b10100100));
            join
            wait_for_inpt();
            if(!SR) check_status(.expected(8'h08), .name("STATUS STA        "));
            else check_status(.expected(8'h10), .name("STATUS R_STA      "));

            // Transferring the slave address 
            wr = $urandom_range(0,1);
            ACK = $urandom_range(0,1); 
            `uvm_info(get_type_name(),$sformatf("Slv :: ACK = %0h",ACK),UVM_LOW)
            fork
                write_addr(.wr(wr));
                begin
                    apb_write(.sqncr(1), .rnd(0), .rnd_data(0), .addr(reg_blk.TWDR.get_address()), .data({$urandom_range(1,14),wr}));
                    apb_write(.sqncr(1), .rnd(0), .rnd_data(0), .addr(reg_blk.TWCR.get_address()), .data(8'b10000100));
                end
            join
            I2C_bus_drive(.wr(0), .drive_ack(ACK));
            wait_for_inpt(1);
            
            check_status(.expected(8'h38), .name("STATUS Status"));
           
            if(wr && ACK) begin
                for(int i=1; i <= byte_num; i++) begin
                    // Receiving data from the I2C bus
                    ACK = i != byte_num ? 1 : 0; //$urandom_range(0,1); 
                    fork
                        read_data(ACK);
                        apb_write(.sqncr(1), .rnd(0), .rnd_data(0), .addr(reg_blk.TWCR.get_address()), .data({1'b1, ACK ,6'b000100}));
                    join
                    // Transferring the data on the I2C bus and driving ACK/NACK
                    I2C_bus_drive(.wr(1), .rnd_data(1));
                    wait_for_inpt(1);
                    reg_blk.TWDR.read(status, value);
                    check_status(.expected(8'h38), .name("STATUS Status"));
                end             
            end
            else if(!wr && ACK) begin
                for(int i=1; i <= byte_num; i++) begin
                    // Transferring the data on the I2C bus
                    fork
                        write_data();
                        begin
                            apb_write(.sqncr(1), .rnd(0), .rnd_data(1), .addr(reg_blk.TWDR.get_address()));
                            apb_write(.sqncr(1), .rnd(0), .rnd_data(0), .addr(reg_blk.TWCR.get_address()), .data(8'b10000100));
                        end
                    join                
                    // Receiving the data from the I2C bus and driving ACK/NACK
                    ACK = i != byte_num ? 1 : $urandom_range(0,1); 
                    I2C_bus_drive(.wr(0), .drive_ack(ACK));
                    wait_for_inpt(1);
                    check_status(.expected(8'h38), .name("STATUS Status"));
                end             
            end
            SR = j != rpt_count ? $urandom_range(0,1) : 0;
            if(!SR) begin
                fork
                    stop_transfer();
                    apb_write(.sqncr(1), .rnd(0), .rnd_data(0), .addr(reg_blk.TWCR.get_address()), .data(8'b10010100));
                join
            end
            SR = 1;
        end
        no_op(10);
    endtask
endclass


class APB_I2C_M_arbitration_in_data_transfer_win_test_virtual_sequence extends APB_I2C_master_basic_virtual_sequence;
    `uvm_object_utils(APB_I2C_M_arbitration_in_data_transfer_win_test_virtual_sequence)

    function new(string name = "APB_I2C_M_arbitration_in_data_transfer_win_test_virtual_sequence");
        super.new(name);
    endfunction

    task body();
        `uvm_info(get_type_name()," APB_I2C_M_arbitration_in_data_transfer_win_test_virtual_sequence body task called",UVM_DEBUG)
        fork
          reset(0);
          reset(1);
        join

        rpt_count = 100;
        SR = 0;  
        
        for(int j=1; j<=rpt_count; j++) begin
            SCL_clock_freq_set(.rnd_br(0), .rnd_sr(0));
            apb_write(.sqncr(1), .rnd(0), .rnd_data(0), .addr(reg_blk.TWBR.get_address()), .data(reg_blk.TWBR.get()));
            apb_write(.sqncr(1), .rnd(0), .rnd_data(0), .addr(reg_blk.TWSR.get_address()), .data(reg_blk.TWSR.TWPS.get()));
            byte_num = $urandom_range(2,4);
            `uvm_info(get_type_name(),$sformatf("MT :: byte_num = %0h",byte_num),UVM_LOW)

            // Transferring the start condition
            fork
                start_transfer();
                apb_write(.sqncr(1), .rnd(0), .rnd_data(0), .addr(reg_blk.TWCR.get_address()), .data(8'b10100100));
            join
            wait_for_inpt();
            if(!SR) check_status(.expected(8'h08), .name("STATUS STA        "));
            else check_status(.expected(8'h10), .name("STATUS R_STA      "));

            // Transferring the slave address 
            wr = $urandom_range(0,1);
            ACK = 1; //$urandom_range(0,1); 
            `uvm_info(get_type_name(),$sformatf("Slv :: ACK = %0h",ACK),UVM_LOW)
            `uvm_info(get_type_name(),$sformatf("MT  :: WR  = %0h",wr),UVM_LOW)
            fork
                write_addr(.wr(wr));
                begin
                    apb_write(.sqncr(1), .rnd(0), .rnd_data(0), .addr(reg_blk.TWDR.get_address()), .data({7'hF, wr}));
                    apb_write(.sqncr(1), .rnd(0), .rnd_data(0), .addr(reg_blk.TWCR.get_address()), .data(8'b10000100));
                end
            join
            I2C_bus_drive(.wr(0), .drive_ack(ACK));
            fork 
                wait_for_inpt();
                begin
                    no_op(100);
                    check_status(.expected(8'hF8), .name("STATUS INTP_LOW   "));
                end
            join            
            
            if(wr) begin
                if(ACK) check_status(.expected(8'h40), .name("STATUS SLA_R_ACK  "));
                else check_status(.expected(8'h48), .name("STATUS SLA_R_NACK "));
            end
            else begin
                if(ACK) check_status(.expected(8'h18), .name("STATUS SLA_W_ACK  "));
                else check_status(.expected(8'h20), .name("STATUS SLA_W_NACK "));
            end            

            if(wr && ACK) begin
                for(int i=1; i <= byte_num; i++) begin
                    // Receiving data from the I2C bus
                    ACK = i != byte_num ? 1 : 0; //$urandom_range(0,1); 
                    fork
                        read_data(ACK);
                        apb_write(.sqncr(1), .rnd(0), .rnd_data(0), .addr(reg_blk.TWCR.get_address()), .data(8'b10000100));
                    join
                    // Transferring the data on the I2C bus and driving ACK/NACK
                    I2C_bus_drive(.wr(1), .rnd_data(1));
                    fork 
                        wait_for_inpt();
                        begin
                            no_op(100);
                            check_status(.expected(8'hF8), .name("STATUS INTP_LOW   "));
                        end
                    join                    
                    reg_blk.TWDR.read(status, value);
                    if(ACK) check_status(.expected(8'h50), .name("STATUS R_DATA_ACK "));
                    else check_status(.expected(8'h58), .name("STATUS R_DATA_NACK"));
                end             
            end
            else if(!wr && ACK) begin
                for(int i=1; i <= byte_num; i++) begin
                    // Transferring the data on the I2C bus
                    fork
                        write_data();
                        begin
                            apb_write(.sqncr(1), .rnd(0), .rnd_data(0), .addr(reg_blk.TWDR.get_address()), .data(8'hFF));
                            apb_write(.sqncr(1), .rnd(0), .rnd_data(0), .addr(reg_blk.TWCR.get_address()), .data(8'b10000100));
                        end
                    join                
                    // Receiving the data from the I2C bus and driving ACK/NACK
                    ACK = i != byte_num ? 1 : $urandom_range(0,1); 
                    I2C_bus_drive(.wr(0), .drive_ack(ACK));
                    fork 
                        wait_for_inpt();
                        begin
                            no_op(100);
                            check_status(.expected(8'hF8), .name("STATUS INTP_LOW   "));
                        end
                    join                    
                    if(ACK) check_status(.expected(8'h28), .name("STATUS W_DATA_ACK "));
                    else check_status(.expected(8'h30), .name("STATUS W_DATA_NACK"));
                end             
            end
            reg_blk.TWBR.read(status, value);

            SR = j != rpt_count ? $urandom_range(0,1) : 0;
            if(!SR) stop_transfer();
        end
        no_op(10);
    endtask
endclass


class APB_I2C_M_arbitration_in_data_transfer_lost_test_virtual_sequence extends APB_I2C_master_basic_virtual_sequence;
    `uvm_object_utils(APB_I2C_M_arbitration_in_data_transfer_lost_test_virtual_sequence)

    function new(string name = "APB_I2C_M_arbitration_in_data_transfer_lost_test_virtual_sequence");
        super.new(name);
    endfunction

    task body();
        `uvm_info(get_type_name()," APB_I2C_M_arbitration_in_data_transfer_lost_test_virtual_sequence body task called",UVM_DEBUG)
        env_config.arbitation_lost = 1;
        fork
          reset(0);
          reset(1);
        join

        rpt_count = 100;
        SR = 0;  
        
        for(int j=1; j<=rpt_count; j++) begin
            SCL_clock_freq_set(.rnd_br(0), .rnd_sr(0));
            apb_write(.sqncr(1), .rnd(0), .rnd_data(0), .addr(reg_blk.TWBR.get_address()), .data(reg_blk.TWBR.get()));
            apb_write(.sqncr(1), .rnd(0), .rnd_data(0), .addr(reg_blk.TWSR.get_address()), .data(reg_blk.TWSR.TWPS.get()));
            byte_num = $urandom_range(2,4);
            `uvm_info(get_type_name(),$sformatf("MT :: byte_num = %0h",byte_num),UVM_LOW)

            // Transferring the start condition
            fork
                start_transfer();
                apb_write(.sqncr(1), .rnd(0), .rnd_data(0), .addr(reg_blk.TWCR.get_address()), .data(8'b10100100));
            join
            wait_for_inpt();
            if(!SR) check_status(.expected(8'h08), .name("STATUS STA        "));
            else check_status(.expected(8'h10), .name("STATUS R_STA      "));

            // Transferring the slave address 
            wr = $urandom_range(0,1);
            ACK = 1; //$urandom_range(0,1); 
            `uvm_info(get_type_name(),$sformatf("Slv :: ACK = %0h",ACK),UVM_LOW)
            `uvm_info(get_type_name(),$sformatf("MT  :: WR  = %0h",wr),UVM_LOW)
            fork
                write_addr(.wr(wr));
                begin
                    apb_write(.sqncr(1), .rnd(0), .rnd_data(0), .addr(reg_blk.TWDR.get_address()), .data({7'hF,wr}));
                    apb_write(.sqncr(1), .rnd(0), .rnd_data(0), .addr(reg_blk.TWCR.get_address()), .data(8'b10000100));
                end
            join
            I2C_bus_drive(.wr(0), .drive_ack(ACK));
            wait_for_inpt();

            if(wr) begin
                if(ACK) check_status(.expected(8'h40), .name("STATUS SLA_R_ACK  "));
                else check_status(.expected(8'h48), .name("STATUS SLA_R_NACK "));
            end
            else begin
                if(ACK) check_status(.expected(8'h18), .name("STATUS SLA_W_ACK  "));
                else check_status(.expected(8'h20), .name("STATUS SLA_W_NACK "));
            end
           
            if(wr && ACK) begin
                for(int i=1; i <= byte_num; i++) begin
                    // Receiving data from the I2C bus
                    ACK = i != byte_num ? 1 : 0; //$urandom_range(0,1); 
                    fork
                        read_data(0);
                        apb_write(.sqncr(1), .rnd(0), .rnd_data(0), .addr(reg_blk.TWCR.get_address()), .data({1'b1, ACK ,6'b000100}));
                    join
                    // Transferring the data on the I2C bus and driving ACK/NACK
                    I2C_bus_drive(.wr(1), .rnd_data(1));
                    wait_for_inpt(1);
                    check_status(.expected(8'h38), .name("STATUS Status"));
                end             
            end
            else if(!wr && ACK) begin
                for(int i=1; i <= byte_num; i++) begin
                    // Transferring the data on the I2C bus
                    fork
                        write_data(.rnd(0), .data(8'hFF));
                        begin
                            apb_write(.sqncr(1), .rnd(0), .rnd_data(0), .addr(reg_blk.TWDR.get_address()), .data($urandom_range(0,250)));
                            apb_write(.sqncr(1), .rnd(0), .rnd_data(0), .addr(reg_blk.TWCR.get_address()), .data(8'b10000100));
                        end
                    join                
                    // Receiving the data from the I2C bus and driving ACK/NACK
                    ACK = i != byte_num ? 1 : $urandom_range(0,1); 
                    I2C_bus_drive(.wr(0), .drive_ack(ACK));
                    wait_for_inpt(1);
                    check_status(.expected(8'h38), .name("STATUS Status"));
                end             
            end
            SR = j != rpt_count ? $urandom_range(0,1) : 0;
            if(!SR) begin
                fork
                    stop_transfer();
                    apb_write(.sqncr(1), .rnd(0), .rnd_data(0), .addr(reg_blk.TWCR.get_address()), .data(8'b10010100));
                join
            end
            SR = 1;
        end
        no_op(10);
    endtask
endclass



class APB_I2C_M_synchronization_test_virtual_sequence extends APB_I2C_master_basic_virtual_sequence;
    `uvm_object_utils(APB_I2C_M_synchronization_test_virtual_sequence)

    bit [7:0] random_data;
    bit signed [1:0] twbr_val;

    function new(string name = "APB_I2C_M_synchronization_test_virtual_sequence");
        super.new(name);
    endfunction

    task body();
        `uvm_info(get_type_name()," APB_I2C_M_synchronization_test_virtual_sequence body task called",UVM_DEBUG)
        fork
          reset(0);
          reset(1);
        join

        rpt_count = 100;
        SR = 0;  
        
        for(int j=1; j<=rpt_count; j++) begin
            twbr_val = $urandom_range(0,3);
            SCL_clock_freq_set(.rnd_br(1), .rnd_sr(1));
            apb_write(.sqncr(1), .rnd(0), .rnd_data(1), .addr(reg_blk.TWBR.get_address()), .data(reg_blk.TWBR.get()+ twbr_val));
            apb_write(.sqncr(1), .rnd(0), .rnd_data(1), .addr(reg_blk.TWSR.get_address()), .data(reg_blk.TWSR.TWPS.get()));        
            byte_num = $urandom_range(0,4);
            `uvm_info(get_type_name(),$sformatf("MT :: byte_num = %0h",byte_num),UVM_LOW)

            // Transferring the start condition
            fork
                start_transfer();
                apb_write(.sqncr(1), .rnd(0), .rnd_data(0), .addr(reg_blk.TWCR.get_address()), .data(8'b10100100));
            join
            wait_for_inpt();
            if(!SR) check_status(.expected(8'h08), .name("STATUS STA        "));
            else check_status(.expected(8'h10), .name("STATUS R_STA      "));

            // Transferring the slave address 
            wr = $urandom_range(0,1);
            ACK = $urandom_range(0,1); 
            `uvm_info(get_type_name(),$sformatf("Slv :: ACK = %0h",ACK),UVM_LOW)
            `uvm_info(get_type_name(),$sformatf("MT  :: WR  = %0h",wr),UVM_LOW)
            fork
                write_addr(.wr(wr));
                begin
                    apb_write(.sqncr(1), .rnd(0), .rnd_data(0), .addr(reg_blk.TWDR.get_address()), .data({7'hF, wr}));
                    apb_write(.sqncr(1), .rnd(0), .rnd_data(0), .addr(reg_blk.TWCR.get_address()), .data(8'b10000100));
                end
            join
            I2C_bus_drive(.wr(0), .drive_ack(ACK));
            fork 
                wait_for_inpt();
                begin
                    no_op(100);
                    check_status(.expected(8'hF8), .name("STATUS INTP_LOW   "));
                end
            join             
            
            if(wr) begin
                if(ACK) check_status(.expected(8'h40), .name("STATUS SLA_R_ACK  "));
                else check_status(.expected(8'h48), .name("STATUS SLA_R_NACK "));
            end
            else begin
                if(ACK) check_status(.expected(8'h18), .name("STATUS SLA_W_ACK  "));
                else check_status(.expected(8'h20), .name("STATUS SLA_W_NACK "));
            end            

            if(wr && ACK) begin
                for(int i=1; i <= byte_num; i++) begin
                    // Receiving data from the I2C bus
                    ACK = i != byte_num ? 1 : 0; //$urandom_range(0,1); 
                    fork
                        read_data(ACK);
                        apb_write(.sqncr(1), .rnd(0), .rnd_data(0), .addr(reg_blk.TWCR.get_address()), .data({1'b1, ACK ,6'b000100}));
                    join
                    // Transferring the data on the I2C bus and driving ACK/NACK
                    I2C_bus_drive(.wr(1), .rnd_data(1));
                    fork 
                        wait_for_inpt();
                        begin
                            no_op(100);
                            check_status(.expected(8'hF8), .name("STATUS INTP_LOW   "));
                        end
                    join                    
                    reg_blk.TWDR.read(status, value);
                    if(ACK) check_status(.expected(8'h50), .name("STATUS R_DATA_ACK "));
                    else check_status(.expected(8'h58), .name("STATUS R_DATA_NACK"));
                end             
            end
            else if(!wr && ACK) begin
                for(int i=1; i <= byte_num; i++) begin
                    // Transferring the data on the I2C bus
                    random_data = $urandom_range(0,255);
                    fork
                        write_data(.rnd(0), .data(random_data));
                        begin
                            apb_write(.sqncr(1), .rnd(0), .rnd_data(0), .addr(reg_blk.TWDR.get_address()), .data(random_data));
                            apb_write(.sqncr(1), .rnd(0), .rnd_data(0), .addr(reg_blk.TWCR.get_address()), .data(8'b10000100));
                        end
                    join                
                    // Receiving the data from the I2C bus and driving ACK/NACK
                    ACK = i != byte_num ? 1 : $urandom_range(0,1); 
                    I2C_bus_drive(.wr(0), .drive_ack(ACK));
                    fork 
                        wait_for_inpt();
                        begin
                            no_op(100);
                            check_status(.expected(8'hF8), .name("STATUS INTP_LOW   "));
                        end
                    join                     
                    if(ACK) check_status(.expected(8'h28), .name("STATUS W_DATA_ACK "));
                    else check_status(.expected(8'h30), .name("STATUS W_DATA_NACK"));
                end             
            end
            reg_blk.TWBR.read(status, value);

            SR = j != rpt_count ? $urandom_range(0,1) : 0;
            if(!SR) begin
                fork
                    stop_transfer();
                    apb_write(.sqncr(1), .rnd(0), .rnd_data(0), .addr(reg_blk.TWCR.get_address()), .data(8'b10010100));
                join
            end
        end
        no_op(10);
    endtask
endclass


class APB_I2C_M_clock_stretching_test_virtual_sequence extends APB_I2C_master_basic_virtual_sequence;
    `uvm_object_utils(APB_I2C_M_clock_stretching_test_virtual_sequence)

    function new(string name = "APB_I2C_M_clock_stretching_test_virtual_sequence");
        super.new(name);
    endfunction

    task body();
        `uvm_info(get_type_name()," APB_I2C_M_clock_stretching_test_virtual_sequence body task called",UVM_DEBUG)
        fork
          reset(0);
          reset(1);
        join

        rpt_count = 100;
        SR = 0;

        for(int j=1; j<=rpt_count; j++) begin
            SCL_clock_freq_set(.rnd_br(1), .rnd_sr(1)); 
            byte_num = $urandom_range(0,4);
            `uvm_info(get_type_name(),$sformatf("Master Transmitter :: byte_num = %0h",byte_num),UVM_LOW)

            // Transferring the start condition
            start_transfer();
            wait_for_inpt();
            if(!SR) check_status(.expected(8'h08), .name("STATUS STA        "));
            else check_status(.expected(8'h10), .name("STATUS R_STA      "));

            // Transferring the slave address 
            wr = $urandom_range(0,1);
            ACK = $urandom_range(0,1); 
            `uvm_info(get_type_name(),$sformatf("Slv :: ACK = %0h",ACK),UVM_LOW)
            `uvm_info(get_type_name(),$sformatf("MT  :: WR  = %0h",wr),UVM_LOW)
            write_addr(.wr(wr));
            I2C_bus_drive(.wr(0), .drive_ack(ACK));
            fork 
                wait_for_inpt();
                begin
                    no_op(100);
                    check_status(.expected(8'hF8), .name("STATUS INTP_LOW   "));
                end
            join

            if(wr) begin
                if(ACK) check_status(.expected(8'h40), .name("STATUS SLA_R_ACK  "));
                else check_status(.expected(8'h48), .name("STATUS SLA_R_NACK "));
            end
            else begin
                if(ACK) check_status(.expected(8'h18), .name("STATUS SLA_W_ACK  "));
                else check_status(.expected(8'h20), .name("STATUS SLA_W_NACK "));
            end

            if(wr && ACK) begin
                for(int i=1; i <= byte_num; i++) begin
                    // Receiving data from the I2C bus
                    ACK = i != byte_num ? 1 : 0; //$urandom_range(0,1); 
                    read_data(ACK);
                    // Transferring the data on the I2C bus and driving ACK/NACK
                    I2C_bus_drive(.wr(1), .rnd_data(1));
                    fork 
                        wait_for_inpt();
                        begin
                            no_op(100);
                            check_status(.expected(8'hF8), .name("STATUS INTP_LOW   "));
                        end
                    join 
                    reg_blk.TWDR.read(status, value);
                    if(ACK) check_status(.expected(8'h50), .name("STATUS R_DATA_ACK "));
                    else check_status(.expected(8'h58), .name("STATUS R_DATA_NACK"));
                end             
            end
            else if(!wr && ACK) begin
                for(int i=1; i <= byte_num; i++) begin
                    // Transferring the data on the I2C bus
                    write_data();
                    // Receiving the data from the I2C bus and driving ACK/NACK
                    ACK = i != byte_num ? 1 : $urandom_range(0,1); 
                    I2C_bus_drive(.wr(0), .drive_ack(ACK));
                    fork 
                        wait_for_inpt();
                        begin
                            no_op(100);
                            check_status(.expected(8'hF8), .name("STATUS INTP_LOW   "));
                        end
                    join                    
                    if(ACK) check_status(.expected(8'h28), .name("STATUS W_DATA_ACK "));
                    else check_status(.expected(8'h30), .name("STATUS W_DATA_NACK"));
                end            
            end
            reg_blk.TWBR.read(status, value);

            SR = j != rpt_count ? $urandom_range(0,1) : 0;
            if(!SR) stop_transfer();
        end
        no_op(10);
    endtask    
    
endclass


class APB_I2C_M_write_collision_test_virtual_sequence extends APB_I2C_master_basic_virtual_sequence;
    `uvm_object_utils(APB_I2C_M_write_collision_test_virtual_sequence)

    function new(string name = "APB_I2C_M_write_collision_test_virtual_sequence");
        super.new(name);
    endfunction

    task body();
        `uvm_info(get_type_name()," APB_I2C_M_write_collision_test_virtual_sequence body task called",UVM_DEBUG)
        fork
          reset(0);
          reset(1);
        join

        rpt_count = 100;
        SR = 0;

        for(int j=1; j<=rpt_count; j++) begin
            SCL_clock_freq_set(.rnd_br(1), .rnd_sr(1)); 
            byte_num = $urandom_range(0,4);
            `uvm_info(get_type_name(),$sformatf("Master Transmitter :: byte_num = %0h",byte_num),UVM_LOW)

            // Transferring the start condition
            start_transfer();
            wait_for_inpt();
            if(!SR) check_status(.expected(8'h08), .name("STATUS STA        "));
            else check_status(.expected(8'h10), .name("STATUS R_STA      "));

            // Transferring the slave address 
            wr = $urandom_range(0,1);
            ACK = $urandom_range(0,1); 
            `uvm_info(get_type_name(),$sformatf("Slv :: ACK = %0h",ACK),UVM_LOW)
            `uvm_info(get_type_name(),$sformatf("MT  :: WR  = %0h",wr),UVM_LOW)
            write_addr(.wr(wr));
            I2C_bus_drive(.wr(0), .drive_ack(ACK));
            
            fork 
                wait_for_inpt();
                begin
                    no_op(100);
                    reg_blk.TWCR.read(status, value);
                    env_config.compare_data(1'b0, value[3], " TWWC "); 
                    reg_blk.TWDR.randomize();
                    reg_blk.TWDR.write(status, reg_blk.TWDR.get());
                    reg_blk.TWCR.read(status, value);
                    env_config.compare_data(1'b1, value[3], " TWWC "); 
                    check_status(.expected(8'hF8), .name("STATUS INTP_LOW   "));
                end
            join
            
            if(wr) begin
                if(ACK) check_status(.expected(8'h40), .name("STATUS SLA_R_ACK  "));
                else check_status(.expected(8'h48), .name("STATUS SLA_R_NACK "));
            end
            else begin
                if(ACK) check_status(.expected(8'h18), .name("STATUS SLA_W_ACK  "));
                else check_status(.expected(8'h20), .name("STATUS SLA_W_NACK "));
            end

            reg_blk.TWDR.randomize();
            reg_blk.TWDR.write(status, reg_blk.TWDR.get());
            reg_blk.TWCR.read(status, value);
            env_config.compare_data(1'b0, value[3], " TWWC "); 

            if(wr && ACK) begin
                for(int i=1; i <= byte_num; i++) begin
                    // Receiving data from the I2C bus
                    ACK = i != byte_num ? 1 : 0; //$urandom_range(0,1); 
                    read_data(ACK);
                    // Transferring the data on the I2C bus and driving ACK/NACK
                    I2C_bus_drive(.wr(1), .rnd_data(1));
                    fork 
                        wait_for_inpt();
                        begin
                            no_op(100);
                            reg_blk.TWCR.read(status, value);
                            env_config.compare_data(1'b0, value[3], " TWWC "); 
                            reg_blk.TWDR.randomize();
                            reg_blk.TWDR.write(status, reg_blk.TWDR.get());
                            reg_blk.TWCR.read(status, value);
                            env_config.compare_data(1'b1, value[3], " TWWC "); 
                            check_status(.expected(8'hF8), .name("STATUS INTP_LOW   "));
                        end
                    join                    
                    reg_blk.TWDR.read(status, value);
                    if(ACK) check_status(.expected(8'h50), .name("STATUS R_DATA_ACK "));
                    else check_status(.expected(8'h58), .name("STATUS R_DATA_NACK"));
                    reg_blk.TWDR.randomize();
                    reg_blk.TWDR.write(status, reg_blk.TWDR.get());
                    reg_blk.TWCR.read(status, value);
                    env_config.compare_data(1'b0, value[3], " TWWC ");                    
                end             
            end
            else if(!wr && ACK) begin
                for(int i=1; i <= byte_num; i++) begin
                    // Transferring the data on the I2C bus
                    write_data();
                    // Receiving the data from the I2C bus and driving ACK/NACK
                    ACK = i != byte_num ? 1 : $urandom_range(0,1); 
                    I2C_bus_drive(.wr(0), .drive_ack(ACK));
                    fork 
                        wait_for_inpt();
                        begin
                            no_op(100);
                            reg_blk.TWCR.read(status, value);
                            env_config.compare_data(1'b0, value[3], " TWWC "); 
                            reg_blk.TWDR.randomize();
                            reg_blk.TWDR.write(status, reg_blk.TWDR.get());
                            reg_blk.TWCR.read(status, value);
                            env_config.compare_data(1'b1, value[3], " TWWC "); 
                            check_status(.expected(8'hF8), .name("STATUS INTP_LOW   "));
                        end
                    join                     
                    if(ACK) check_status(.expected(8'h28), .name("STATUS W_DATA_ACK "));
                    else check_status(.expected(8'h30), .name("STATUS W_DATA_NACK"));
                    reg_blk.TWDR.randomize();
                    reg_blk.TWDR.write(status, reg_blk.TWDR.get());
                    reg_blk.TWCR.read(status, value);
                    env_config.compare_data(1'b0, value[3], " TWWC ");                     
                end            
            end
            reg_blk.TWBR.read(status, value);

            SR = j != rpt_count ? $urandom_range(0,1) : 0;
            if(!SR) stop_transfer();
        end
        no_op(10);
    endtask    
    
endclass


class APB_I2C_M_on_the_fly_EN_low_test_virtual_sequence extends APB_I2C_master_basic_virtual_sequence;
    `uvm_object_utils(APB_I2C_M_on_the_fly_EN_low_test_virtual_sequence)

    function new(string name = "APB_I2C_M_on_the_fly_EN_low_test_virtual_sequence");
        super.new(name);
    endfunction

    task body();
        `uvm_info(get_type_name()," APB_I2C_M_on_the_fly_EN_low_test_virtual_sequence body task called",UVM_DEBUG)
        fork
          reset(0);
          reset(1);
        join
        rpt_count = 1;
        SCL_clock_freq_set(.rnd_br(0), .rnd_sr(0)); 
        SR = 0;

        for(int j=1; j<=rpt_count; j++) begin
            byte_num = 1;
            `uvm_info(get_type_name(),$sformatf("Master Transmitter :: byte_num = %0h",byte_num),UVM_LOW)

            // Transferring the start condition
            start_transfer();
            wait_for_inpt();
            if(!SR) check_status(.expected(8'h08), .name("STATUS STA        "));
            else check_status(.expected(8'h10), .name("STATUS R_STA      "));

            // Transferring the slave address 
            wr = $urandom_range(0,1);
            ACK = 1;  
            `uvm_info(get_type_name(),$sformatf("Slv :: ACK = %0h",ACK),UVM_LOW)
            `uvm_info(get_type_name(),$sformatf("MT  :: WR  = %0h",wr),UVM_LOW)
            write_addr(.wr(wr));
            I2C_bus_drive(.wr(0), .drive_ack(ACK));
            fork 
                wait_for_inpt();
                begin
                    no_op(10);
                    I2C_config.get_intp(intp);
                    while(!intp)begin
                        check_status(.expected(8'hF8), .name("STATUS INTP_LOW   "));
                        I2C_config.get_intp(intp);
                    end
                end
            join 
            if(wr) begin
                if(ACK) check_status(.expected(8'h40), .name("STATUS SLA_R_ACK  "));
                else check_status(.expected(8'h48), .name("STATUS SLA_R_NACK "));
            end
            else begin
                if(ACK) check_status(.expected(8'h18), .name("STATUS SLA_W_ACK  "));
                else check_status(.expected(8'h20), .name("STATUS SLA_W_NACK "));
            end

            //no_op(100);
            //reg_blk.TWCR.TWEN.set(0);
            //reg_blk.TWCR.write(status, reg_blk.TWCR.get());
            //no_op(100);
            //check_status(.expected(8'hF8), .name("STATUS INTP_LOW   "));
            //no_op(100);

            if(wr && ACK) begin
                for(int i=1; i <= byte_num; i++) begin
                    // Receiving data from the I2C bus
                    ACK = i != byte_num ? 1 : 0; //$urandom_range(0,1); 
                    read_data(ACK);
                    // Transferring the data on the I2C bus and driving ACK/NACK
                    I2C_bus_drive(.wr(1), .rnd_data(1));
                    no_op(100);
                    reg_blk.TWCR.TWEN.set(0);
                    reg_blk.TWCR.write(status, reg_blk.TWCR.get());
                    no_op(50);
                    check_status(.expected(8'hF8), .name("STATUS INTP_LOW   "));
                    no_op(100);
                end             
            end
            else if(!wr && ACK) begin
                for(int i=1; i <= byte_num; i++) begin
                    // Transferring the data on the I2C bus
                    write_data();
                    // Receiving the data from the I2C bus and driving ACK/NACK
                    ACK = i != byte_num ? 1 : $urandom_range(0,1); 
                    I2C_bus_drive(.wr(0), .drive_ack(ACK));
                    no_op(100);
                    reg_blk.TWCR.TWEN.set(0);
                    reg_blk.TWCR.write(status, reg_blk.TWCR.get());
                    no_op(50);
                    check_status(.expected(8'hF8), .name("STATUS INTP_LOW   "));
                    no_op(100);
                end            
            end
            SR = 1;
            if(!SR) stop_transfer();
        end
        no_op(50);
    endtask    
    
endclass



class APB_I2C_M_En_low_test_virtual_sequence extends APB_I2C_master_basic_virtual_sequence;
    `uvm_object_utils(APB_I2C_M_En_low_test_virtual_sequence)

    function new(string name = "APB_I2C_M_En_low_test_virtual_sequence");
        super.new(name);
    endfunction

    task body();
        `uvm_info(get_type_name()," APB_I2C_M_En_low_test_virtual_sequence body task called",UVM_DEBUG)
        fork
          reset(0);
          reset(1);
        join

        rpt_count = 1;
        SR = 0;   

        for(int j=1; j<=rpt_count; j++) begin
            SCL_clock_freq_set(.rnd_br(0), .rnd_sr(0)); 
            byte_num = 1; //$urandom_range(2,4);
            `uvm_info(get_type_name(),$sformatf("Master Transmitter :: byte_num = %0h",byte_num),UVM_LOW)

            // Transferring the start condition
            start_transfer();
            wait_for_inpt();
            if(!SR) check_status(.expected(8'h08), .name("STATUS STA        "));
            else check_status(.expected(8'h10), .name("STATUS R_STA      "));

            // Transferring the slave address 
            wr = $urandom_range(0,1);
            ACK = $urandom_range(0,1);

            // Write intp clear with en low
            //for(int k=0; k<=1; k++) begin
            //    write_addr(.wr(wr), .twint(k), .twen(0));
            //    I2C_config.get_intp(intp);
            //    env_config.compare_data(1'b1, intp, "intp_en_low");
            //end
            write_addr(.wr(wr));
            I2C_bus_drive(.wr(0), .drive_ack(ACK));
            fork 
                wait_for_inpt();
                begin
                    no_op(100);
                    check_status(.expected(8'hF8), .name("STATUS INTP_LOW   "));
                end
            join

            if(wr) begin
                if(ACK) check_status(.expected(8'h40), .name("STATUS SLA_R_ACK  "));
                else check_status(.expected(8'h48), .name("STATUS SLA_R_NACK "));
            end
            else begin
                if(ACK) check_status(.expected(8'h18), .name("STATUS SLA_W_ACK  "));
                else check_status(.expected(8'h20), .name("STATUS SLA_W_NACK "));
            end

            if(wr && ACK) begin
                for(int i=1; i <= byte_num; i++) begin
                    // Receiving data from the I2C bus
                    ACK = i != byte_num ? 1 : 0; //$urandom_range(0,1); 
                    // Write intp clear with en low
                    //for(int k=0; k<=1; k++) begin
                    //    read_data(.ACK(ACK), .twint(k), .twen(0));
                    //    I2C_config.get_intp(intp);
                    //    env_config.compare_data(1'b1, intp, "intp_en_low");
                    //end                    
                    read_data(ACK);
                    // Transferring the data on the I2C bus and driving ACK/NACK
                    I2C_bus_drive(.wr(1), .rnd_data(1));
                    fork 
                        wait_for_inpt();
                        begin
                            no_op(100);
                            check_status(.expected(8'hF8), .name("STATUS INTP_LOW   "));
                        end
                    join                    
                    reg_blk.TWDR.read(status, value);
                    if(ACK) check_status(.expected(8'h50), .name("STATUS R_DATA_ACK "));
                    else check_status(.expected(8'h58), .name("STATUS R_DATA_NACK"));
                end             
            end
            else if(!wr && ACK) begin
                for(int i=1; i <= byte_num; i++) begin
                    // Transferring the data on the I2C bus
                    //for(int k=0; k<=1; k++) begin
                    //    write_data(.twint(k), .twen(0));
                    //    I2C_config.get_intp(intp);
                    //    env_config.compare_data(1'b1, intp, "intp_en_low");
                    //end                     
                    write_data();
                    // Receiving the data from the I2C bus and driving ACK/NACK
                    ACK = i != byte_num ? 1 : $urandom_range(0,1); 
                    I2C_bus_drive(.wr(0), .drive_ack(ACK));
                    fork 
                        wait_for_inpt();
                        begin
                            no_op(100);
                            check_status(.expected(8'hF8), .name("STATUS INTP_LOW   "));
                        end
                    join                    
                    if(ACK) check_status(.expected(8'h28), .name("STATUS W_DATA_ACK "));
                    else check_status(.expected(8'h30), .name("STATUS W_DATA_NACK"));
                end            
            end
            reg_blk.TWBR.read(status, value);

            SR = j != rpt_count ? $urandom_range(0,1) : 0;
            if(!SR) begin
                stop_transfer(.twint(1), .twen(0));
                I2C_config.get_intp(intp);
                env_config.compare_data(1'b1, intp, "intp_en_low");
                stop_transfer();
            end
            else begin
                start_transfer(.twint(1), .twen(0));
                I2C_config.get_intp(intp);
                env_config.compare_data(1'b1, intp, "intp_en_low");
            end
        end
        no_op(100);
    endtask    

endclass


class APB_I2C_M_on_the_fly_error_test_virtual_sequence extends APB_I2C_master_basic_virtual_sequence;
    `uvm_object_utils(APB_I2C_M_on_the_fly_error_test_virtual_sequence)

    function new(string name = "APB_I2C_M_on_the_fly_error_test_virtual_sequence");
        super.new(name);
    endfunction

    task body();
        `uvm_info(get_type_name()," APB_I2C_M_on_the_fly_error_test_virtual_sequence body task called",UVM_DEBUG)
        fork
          reset(0);
          reset(1);
        join
        
        rpt_count = 2;
        SR = 0;   
        
        for(int j=1; j<=rpt_count; j++) begin
            SCL_clock_freq_set(.rnd_br(0), .rnd_sr(0)); 
            byte_num = $urandom_range(0,4);
            `uvm_info(get_type_name(),$sformatf("Master Transmitter :: byte_num = %0h",byte_num),UVM_LOW)

            // Transferring the start condition
            start_transfer();
            wait_for_inpt();
            if(!SR) check_status(.expected(8'h08), .name("STATUS STA        "));
            else check_status(.expected(8'h10), .name("STATUS R_STA      "));

            // Transferring the slave address 
            wr = $urandom_range(0,1);
            ACK = $urandom_range(0,1); 
            write_addr(.wr(wr));
            I2C_bus_drive(.wr(0), .drive_ack(ACK));
            fork 
                wait_for_inpt();
                begin
                    no_op(100);
                    check_status(.expected(8'hF8), .name("STATUS INTP_LOW   "));
                    if($urandom_range(0,1)) stop_transfer();
                    else start_transfer();
                    check_status(.expected(8'h00), .name("STATUS Status"));                    
                end
            join

            if(wr) begin
                if(ACK) check_status(.expected(8'h40), .name("STATUS SLA_R_ACK  "));
                else check_status(.expected(8'h48), .name("STATUS SLA_R_NACK "));
            end
            else begin
                if(ACK) check_status(.expected(8'h18), .name("STATUS SLA_W_ACK  "));
                else check_status(.expected(8'h20), .name("STATUS SLA_W_NACK "));
            end

            if(wr && ACK) begin
                for(int i=1; i <= byte_num; i++) begin
                    // Receiving data from the I2C bus
                    ACK = i != byte_num ? 1 : 0; //$urandom_range(0,1); 
                    read_data(ACK);
                    // Transferring the data on the I2C bus and driving ACK/NACK
                    I2C_bus_drive(.wr(1), .rnd_data(1));
                    fork 
                        wait_for_inpt();
                        begin
                            no_op(100);
                            check_status(.expected(8'hF8), .name("STATUS INTP_LOW   "));
                            if($urandom_range(0,1)) stop_transfer();
                            else start_transfer();
                            check_status(.expected(8'h00), .name("STATUS Status"));
                        end
                    join                    
                    reg_blk.TWDR.read(status, value);
                    if(ACK) check_status(.expected(8'h50), .name("STATUS R_DATA_ACK "));
                    else check_status(.expected(8'h58), .name("STATUS R_DATA_NACK"));
                end             
            end
            else if(!wr && ACK) begin
                for(int i=1; i <= byte_num; i++) begin
                    // Transferring the data on the I2C bus
                    write_data();
                    // Receiving the data from the I2C bus and driving ACK/NACK
                    ACK = i != byte_num ? 1 : $urandom_range(0,1); 
                    I2C_bus_drive(.wr(0), .drive_ack(ACK));
                    fork 
                        wait_for_inpt();
                        begin
                            no_op(100);
                            check_status(.expected(8'hF8), .name("STATUS INTP_LOW   "));
                            if($urandom_range(0,1)) stop_transfer();
                            else start_transfer();
                            check_status(.expected(8'h00), .name("STATUS OTF_STA_STO"));                            
                        end
                    join                    
                    if(ACK) check_status(.expected(8'h28), .name("STATUS W_DATA_ACK "));
                    else check_status(.expected(8'h30), .name("STATUS W_DATA_NACK"));
                end            
            end
            reg_blk.TWBR.read(status, value);
            
            SR = j != rpt_count ? $urandom_range(0,1) : 0;
            if(!SR) stop_transfer();
        end
        no_op(10);
    endtask    
    
endclass



class APB_I2C_MT_cov_test_virtual_sequence extends APB_I2C_master_basic_virtual_sequence;
    `uvm_object_utils(APB_I2C_MT_cov_test_virtual_sequence)

    function new(string name = "APB_I2C_MT_cov_test_virtual_sequence");
        super.new(name);
    endfunction

    task body();
        `uvm_info(get_type_name(),"APB_I2C_MT_cov_test_virtual_sequence body task called",UVM_DEBUG)
        fork
          reset(0);
          reset(1);
        join
        
        rpt_count = 1;
        SR = 0;
        repeat(20) begin
            apb_write(.rnd(0), .rnd_data(1), .addr(reg_blk.TWDR.get_address()), .x_drive(1));
            apb_read(.addr(reg_blk.TWDR.get_address()), .x_drive(1));
        end
        apb_write(.rnd(0), .rnd_data(0), .addr(reg_blk.TWCR.get_address()), .data(8'b10000x00));
        no_op(100);        
        reset(0);

        for(int k=0; k<=1; k++) begin
            read_data(.ACK(ACK), .twint(k), .twen(0));
            write_data(.twint(k), .twen(0));
        end        
        stop_transfer(.twint(1), .twen(0));
        start_transfer(.twint(1), .twen(0));
        
        reset(0);
        
        for(int j=1; j<=rpt_count; j++) begin
            SCL_clock_freq_set(.rnd_br(0), .rnd_sr(0), .br(255), .sr(3));
            byte_num = $urandom_range(0,4);
            `uvm_info(get_type_name(),$sformatf("Master Transmitter :: byte_num = %0h",byte_num),UVM_LOW)

            // Transferring the start condition
            start_transfer();
            wait_for_inpt();
            if(!SR) check_status(.expected(8'h08), .name("STATUS STA        "));
            else check_status(.expected(8'h10), .name("STATUS R_STA      "));

            foreach(data_pattern[i])begin
                reg_blk.TWDR.write(status, data_pattern[i]);
                reg_blk.TWDR.read(status);
            end
            // Transferring the slave address 
            write_addr(.addr($urandom_range(15, 127)));
            I2C_bus_drive(.wr(0), .drive_ack(0));
            fork 
                wait_for_inpt();
                begin
                    no_op(100);
                    check_status(.expected(8'hF8), .name("STATUS INTP_LOW   "));
                end
            join            
            check_status(.expected(8'h20), .name("STATUS SLA_W_NACK "));
            reg_blk.TWBR.read(status, value);
            
            SR = j != rpt_count ? 1 : 0;
            if(!SR) stop_transfer(.with_S(1));
        end
        wait_for_inpt();
        write_addr(.wr(wr));
        I2C_bus_drive(.wr(0), .drive_ack(ACK));
        no_op(100);
        reg_blk.TWCR.TWEN.set(0);
        reg_blk.TWCR.write(status, reg_blk.TWCR.get());
        check_status(.expected(8'hF8), .name("STATUS INTP_LOW   "));
        no_op(100);        
    endtask    
    
endclass

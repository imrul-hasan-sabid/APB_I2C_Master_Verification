
// Code your testbench here
// or browse Examples
class apb_coverage extends uvm_subscriber#(apb_sequence_item);
    `uvm_component_utils(apb_coverage)

    apb_sequence_item apb_item;

    bit [31:0] addr;
    bit wr, PRESETn;
    bit [7:0]TWCR;
    bit [7:0]TWDR;
    bit [7:0]TWSR;
    bit [7:0]TWS;
    bit [1:0]TWPS;
    bit [7:0]TWAR;
    bit [7:0]TWBR;

    covergroup apb_bus_cov;
	option.per_instance = 1;
        RESET: coverpoint PRESETn{ 
            bins reset_enable  = {0}; 
            bins reset_disable = {1};
        }
        
        WR: coverpoint wr{ 
            bins write = {1};
            bins read = {0};
        }   

    	ADDR: coverpoint addr {
            bins TWCR   = {32'h00};
            bins TWDR   = {32'h04};
            bins TWSR   = {32'h08};
            bins TWAR   = {32'h0c};
            bins TWBR   = {32'h10};
        }   
        
        WR_ADDR: cross WR, ADDR; 
    endgroup
   
    covergroup TWDR_cov;
	option.per_instance = 1;
      	WR: coverpoint wr{ 
            bins write = {1};
            bins read  = {0};
        }     
      
        TWDR : coverpoint TWDR{
	    bins data[8]    = {[0:$]};
	    bins pattern[4] = {{2{4'b1010}}, {2{4'b0101}}, {2{4'hF}}, 8'b0}; 
        }
      
       	wr_TWDR: cross WR, TWDR;      
    endgroup    

    covergroup TWSR_cov;
	option.per_instance = 1;
      	WR: coverpoint wr{ 
            bins write = {1};
            bins read = {0};
        }     
      
        TWS : coverpoint TWS{
	    bins  STA        = {8'h08}; 
            bins  R_STA      = {8'h10};

            bins  SLA_W_ACK  = {8'h18};
            bins  SLA_W_NACK = {8'h20};
            bins  W_DATA_ACK = {8'h28};
            bins  W_DATA_NACK= {8'h30};

            bins  SLA_R_ACK  = {8'h40};
            bins  SLA_R_NACK = {8'h48};
            bins  R_DATA_ACK = {8'h50};
            bins  R_DATA_NACK= {8'h58};
            
            bins  INTP_LOW   = {8'hF8};
            bins  ARBTN_LOST = {8'h38};
        }

        TWPS : coverpoint TWPS{
	    bins  ps[4] = {0,1,2,3};
        }        
      
       	wr_TWS: cross WR, TWS{
            ignore_bins ignore_w_TWS = binsof(WR.write) &&  binsof(TWS);  
        }      
        
       	wr_TWPS: cross WR, TWPS;
    endgroup    

    covergroup TWAR_cov;
	option.per_instance = 1;
      	WR: coverpoint wr{ 
            bins write = {1};
            bins read = {0};
        }     
      
        TWAR : coverpoint TWAR{
	    bins data[4]  = {[0:$]};
	    bins pattern[4] = {{2{4'b1010}}, {2{4'b0101}}, {2{4'hF}}, 8'b0}; 
        }
      
       	wr_TWAR: cross WR, TWAR;      
    endgroup


    covergroup TWBR_cov;
	option.per_instance = 1;
      	WR: coverpoint wr{ 
            bins write = {1};
            bins read = {0};
        }     
      
        TWBR : coverpoint TWBR{
	    bins data[8]  = {[0:$]};
	    bins pattern[4] = {{2{4'b1010}}, {2{4'b0101}}, {2{4'hF}}, 8'b0}; 
        }
      
       	wr_TWBR: cross WR, TWBR;      
    endgroup

    covergroup TWCR_cov;
	option.per_instance = 1;      

        TWINT: coverpoint TWCR[7]{ 
            bins twint_high = {1};
            bins twint_low  = {0};
        }
        
        TWEA: coverpoint TWCR[6]{ 
            bins EA_high = {1}; 
            bins EA_low  = {0};
        }

        TW_STA_STO: coverpoint TWCR[5:4]{    
            bins NO_STA_NO_STO = {0};
            bins NO_STA_STO    = {1};
            bins STA_NO_STO    = {2};
            bins STA_STO       = {3};
        }  

        TWCR: coverpoint TWCR[3]{ 
            bins CR_high = {1}; 
            bins CR_low  = {0}; 
        }

        TWEN: coverpoint TWCR[2]{ 
            bins EN_high = {1}; 
            bins EN_low  = {0};
        }        
        
        STA_STO_cross_TWEN: cross TW_STA_STO, TWEN;
        TWINT_cross_TWEN  : cross TWINT, TWEN;
        TWEA_cross_TWEN   : cross TWEA, TWEN;
    endgroup

    covergroup config_combination_cov;
	option.per_instance = 1;

        TWBR : coverpoint TWBR{
	    bins data[8]  = {[0:$]};
	    bins pattern[4] = {{2{4'b1010}}, {2{4'b0101}}, {2{4'hF}}, 8'b0}; 
        }
    
        TWPS : coverpoint TWPS{
	    bins  ps[4] = {0,1,2,3};
        } 

        TWBR_TWPS_cross: cross TWPS, TWBR;
    endgroup

    function new(string name="apb_coverage", uvm_component parent = null);
        super.new(name, parent);
        `uvm_info(get_type_name(),"apb_coverage is created..",UVM_DEBUG)
        apb_bus_cov            = new();
        TWCR_cov               = new();
        TWDR_cov               = new();
        TWSR_cov               = new();
        TWAR_cov               = new();
        TWBR_cov               = new();
        config_combination_cov = new();
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info(get_type_name(),"apb_coverage build phase started..",UVM_DEBUG)        
        `uvm_info(get_type_name(),"apb_coverage build phase ended..",UVM_DEBUG)
    endfunction

    virtual function void write(apb_sequence_item t);
        //`uvm_info(get_type_name(),"coverage item is received..",UVM_MEDIUM)
        //t.print();
        PRESETn   = t.PRESETn;
        addr      = t.PADDR;
        wr        = t.wr;
        
	apb_bus_cov.sample();
        if(PRESETn)begin
            if(t.PADDR == 32'h0) begin 
	        TWCR = wr ? t.PWDATA : t.PRDATA;
	        TWCR_cov.sample();
                //`uvm_info(get_type_name(),"TWCR_cov.sample() is called..",UVM_MEDIUM)
	    end		
	    if(t.PADDR == 32'h4) begin 
	        TWDR = wr ? t.PWDATA : t.PRDATA;
	        TWDR_cov.sample();
	    end		
	    if(t.PADDR == 32'h8) begin 
	        TWSR = wr ? t.PWDATA : t.PRDATA;
                TWS[7:3] = TWSR[7:3];
                TWPS     = TWSR[1:0];
	        TWSR_cov.sample();
	    end		
	    if(t.PADDR == 32'hc) begin 
	        TWAR = wr ? t.PWDATA : t.PRDATA;
	        TWAR_cov.sample(); 
  	    end		
	    if(t.PADDR == 32'h10) begin 
	        TWBR = wr ? t.PWDATA : t.PRDATA;
	        TWBR_cov.sample(); 
                config_combination_cov.sample();
  	    end		
        end
    endfunction

endclass


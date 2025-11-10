module apb_sub #(
    //------------------------parameter file----------------------------
    `include "params.sv"
) (
    //-------------------------input ports------------------------------
    
	input   logic                       pclk,               // System clock
	input   logic                       presetn,            // System reset
	input   logic                       psel,               // APB chip select signal
	input   logic                       pwrite,             // APB transfer mode signal. For write transfer this signal is HIGH and vice versa 
	input   logic                       penable,            // APB enable signal indicating the second cycle of an APB transfer
	input   logic   [ADDR_WIDTH-1:0]    paddr,              // 32-bit APB address bus
	input   logic   [DATA_WIDTH-1:0]    pwdata,             // 32-bit APB write data bus
	input   logic   [DATA_WIDTH-1:0]    rdata,              // 32-bit register interface read data bus
	input   logic                       apb_sub_flop_en,    // Block enable signal for reducing power consumption
	
	//-------------------------output ports-----------------------------
	
	output  logic                       pready,             // APB subordinate signal for indicating that it is ready for intiating transfer
	output  logic   [DATA_WIDTH-1:0]    prdata,             // 32-bit APB rdata data bus
	output  logic   [ADDR_WIDTH-1:0]    addr,               // 32-bit register inteface address bus
	output  logic                       wr_en,              // Write enable signal for register interface
	output  logic                       r_en,               // Read enable signal for register interface
	output  logic   [DATA_WIDTH-1:0]    wdata               // 32-bit register interface write data bus
);

//====================neccessary nets and variables=====================

reg     [STATE_WIDTH_AFSM-1:0]      pstate;
reg     [STATE_WIDTH_AFSM-1:0]      nstate;

//======================================================================

//==============================states==================================

localparam  IDLE    =   0;
localparam  WRITE   =   1;
localparam  READ    =   2;

//======================================================================

//=======================present state register=========================

dff #(    
    //-------------------------parameters-------------------------------
    .FLOP_WIDTH     (STATE_WIDTH_AFSM),
    .RESET_VALUE    (IDLE)
) u_present_state_register (
    //---------------------------inputs---------------------------------
    .clk            (pclk),
	.resetn         (presetn),
	.en             (apb_sub_flop_en),
	.d              (nstate[STATE_WIDTH_AFSM-1:0]),
    //---------------------------outputs--------------------------------
    .q              (pstate[STATE_WIDTH_AFSM-1:0])
);

//======================================================================

//==========================next state logic============================

always @ (*) begin
	casez (pstate[STATE_WIDTH_AFSM-1:0])
	
	    IDLE: begin
	        casez ({pwrite, psel})
	            2'b?0   :   nstate[STATE_WIDTH_AFSM-1:0]    =   IDLE;
	            2'b01   :   nstate[STATE_WIDTH_AFSM-1:0]    =   READ;
	            2'b11   :   nstate[STATE_WIDTH_AFSM-1:0]    =   WRITE;   
	            default :   nstate[STATE_WIDTH_AFSM-1:0]    =   'bx;
	        endcase
	    end

	    WRITE: begin
	        casez ({pwrite, psel})
	            2'b?0   :   nstate[STATE_WIDTH_AFSM-1:0]    =   IDLE;
	            2'b01   :   nstate[STATE_WIDTH_AFSM-1:0]    =   READ;
	            2'b11   :   nstate[STATE_WIDTH_AFSM-1:0]    =   WRITE;   
	            default :   nstate[STATE_WIDTH_AFSM-1:0]    =   'bx;
	        endcase
	    end

	    READ: begin
	        casez ({pwrite, psel})
	            2'b?0   :   nstate[STATE_WIDTH_AFSM-1:0]    =   IDLE;
	            2'b01   :   nstate[STATE_WIDTH_AFSM-1:0]    =   READ;
	            2'b11   :   nstate[STATE_WIDTH_AFSM-1:0]    =   WRITE;   
	            default :   nstate[STATE_WIDTH_AFSM-1:0]    =   'bx;
	        endcase
	    end

	    default: begin
		                    nstate[STATE_WIDTH_AFSM-1:0]    =   'bx;
	    end

	endcase
end

//======================================================================

//============================output logic==============================

assign  pready                      =   ((pstate == WRITE) | (pstate == READ))  ?   (penable & psel)    :   1'b0;
assign  wr_en                       =   ((pstate == WRITE))                     ?   (penable & pready)  :   1'b0;
assign  r_en                        =   ((pstate == READ))                      ?   (penable & pready)  :   1'b0;

assign  prdata  [DATA_WIDTH-1:0]    =   rdata   [DATA_WIDTH-1:0];
assign  wdata   [DATA_WIDTH-1:0]    =   pwdata  [DATA_WIDTH-1:0];
assign  addr    [ADDR_WIDTH-1:0]    =   paddr   [ADDR_WIDTH-1:0];

//======================================================================

endmodule

/****************************************************************************************
⁡⁣⁢⁣File        : apb_slave.sv⁡
⁡⁢⁣⁢Author      : Mahmadul Hassan Robin⁡
⁡⁢⁢⁢Designation : Trainee Engineer⁡⁡
⁡⁢⁣⁣Company     : Ulkasemi Pvt Ltd⁡
⁡⁣⁣⁢Module      : apb_slave
⁢⁢⁣𝗗𝗲𝘀𝗰𝗿𝗶𝗽𝘁𝗶𝗼𝗻:
This module defines an APB (Advanced Peripheral Bus) slave interface. It receives control
and data signals from a master device and responds accordingly.
𝗦𝘁𝗮𝘁𝗲𝘀:
- IDLE: Initial state when no operation is ongoing.
- SETUP: State during setup phase, preparing for data access.
- ACCESS: State during actual data access.
⁡⁢⁢⁣𝗡𝗼𝘁𝗲:⁡
This module provides the framework for interfacing with an APB master.

*****************************************************************************************/
module apb_slave #(
    `include "twi_parameters.sv"
)(
    input logic                         pclk,                           // APB Clock
    input logic                         presetn                         // APB Reset
    input logic                         penable,                        // APB Bus Enable
    input logic                         psel,                           // APB Subordinate Select
    input logic                         pwrite,                         // APB Write Enable
    input logic [APB_ADDR_WIDTH-1:0]    paddr,                          // APB Address Bus
    input logic [APB_DATA_WIDTH-1:0]    pwdata,                         // APB Write Data Bus
    input logic [APB_DATA_WIDTH-1:0]    rd_data,                        // APB Read Data Bus from Internal Logic 
    input logic                         apb_slave_flop_en,              // APB Slave Flop Enable

    output logic [APB_DATA_WIDTH-1:0]   prdata,                         // APB Read Data Bus
    output logic                        wr_en,                          // Write Enable to Internal Logic
    output logic                        rd_en,                          // Read Enable to Internal Logic
    output logic                        pready,                         // APB Ready Signal
    output logic [APB_DATA_WIDTH-1:0]   wr_data,                        // Write Data Bus to Internal Logic
    output logic [APB_ADDR_WIDTH-1:0]   addr                            // Address Bus to Internal Logic
);

    // State Variables
    localparam STATE_WIDTH = 2;
    logic [STATE_WIDTH-1:0] nstate, pstate;

    // State Declaration
    localparam 	IDLE 	= 2'b00,
            	SETUP 	= 2'b01,
           		ACCESS 	= 2'b11;

    // Next State Logic    
    always @(*) begin
        casez(pstate)
            IDLE   : nstate = psel ? SETUP : IDLE;
            SETUP  : nstate = psel ? (penable ? ACCESS : SETUP) : IDLE;
            ACCESS : nstate = psel ? SETUP : IDLE;
            default: nstate = 'bx;
        endcase
    end

    // Present State Register
    dff #(.FLOP_WIDTH(2), .RESET_VALUE(2'b00)) u_PSR(
        .clk(pclk),
        .resetn(presetn),
        .en(apb_slave_flop_en),
        .d(nstate),
        .q(pstate)
    );

    // Signal Assignments
    assign wr_en  						 	= pwrite & (pstate == SETUP);
    assign rd_en  							= ~pwrite & (pstate == SETUP);
    assign pready  							= 1'b1;
    
    assign prdata  [APB_DATA_WIDTH-1:0]  	= rd_data 	[APB_DATA_WIDTH-1:0];
    assign wr_data [APB_DATA_WIDTH-1:0] 	= pwdata 	[APB_DATA_WIDTH-1:0];
    assign addr    [APB_ADDR_WIDTH-1:0]		= paddr 	[APB_ADDR_WIDTH-1:0];

endmodule

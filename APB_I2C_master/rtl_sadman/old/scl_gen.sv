module scl_gen #(
    //----------------------------parameter file---------------------------------
	`include "params.sv"
) (
    //------------------------------input ports----------------------------------
    
	input   logic                               pclk,               // System clock
	input   logic                               presetn,            // System reset
	input   logic                               scl_en,             // Enable signal indicating when to start toggling
	input   logic   [PRESCALER_WIDTH-1:0]       twps,               // Prescaler value from the TWSR register
	input   logic   [BIT_RATE_CONST_WIDTH-1:0]  twbr,               // Bit rate constant value from the TWBR register
	input   logic                               scl_gen_flop_en,    // Block enable signal for reducing power consumption
	input   logic                               scl_pad_i,          // SCL input signal from pad
	input   logic                               interrupt_pad_o,    // Interrupt signal for notifying the software
	
    //------------------------------output ports---------------------------------
    
	output  logic                               scl_gen_comp_match, // SCL generator internal clock clear signal 
	output  logic                               scl_gen_temp_scl    // Generated SCL signal
); 

//==============================neccessary nets==================================

logic   [SCL_GEN_COUNTER_WIDTH-1:0]     cntr_val;
logic   [2:0]                           m1;
logic   [15:0]                          m2;
logic   [2:0]                           h1;
logic   [15:0]                          h2;
logic                                   clear_cntr;    
logic                                   scl_t1;
logic                                   scl_t2;
logic                                   scl_hold;

//===============================================================================

//===========================module instantiations===============================

// counter for toggling the scl output
counter_nbit #(
    //----------------------------parameters-------------------------------------
    .WIDTH          (SCL_GEN_COUNTER_WIDTH),
    .RESET_VALUE    (16'd0),
    .CLEAR_VALUE    (16'd0)
) u_counter_nbit_scl_gen (
    //------------------------------inputs---------------------------------------
	.clk            (pclk),
	.resetn         (presetn),
	.clear          (clear_cntr),
	.up_down        (1'b1),
	.enable         (scl_en),
	.preload        (1'b0),
	.load_value     (16'd0),	
    //------------------------------outputs--------------------------------------
	.out            (cntr_val[SCL_GEN_COUNTER_WIDTH-1:0])
);

// comparator for comparaing the count value with the devider constant
comparator_nbit #(
    //----------------------------parameters-------------------------------------
    .WIDTH          (SCL_GEN_COUNTER_WIDTH)
) u_comparator_nbit_bit_cnt(
    //------------------------------inputs---------------------------------------
	.a              (h2[15:0]/2), 
	.b              (cntr_val[15:0]),
    //------------------------------outputs--------------------------------------
	.e              (scl_gen_comp_match) 
);

// barrel shifter for multiuplying 2 with twps value
barrel_shifter_nbit #(
    //----------------------------parameters-------------------------------------
	.WIDTH          (3)
) u_barrel_shifter_nbit_2_into_twps(
    //------------------------------inputs---------------------------------------
	.shift_by       (3'b001),
	.shift_dir      (1'b1), 
	.shifter_in     ({1'b0, twps[PRESCALER_WIDTH-1:0]}),
	//------------------------------outputs--------------------------------------
	.shifter_out    (m1)
);

// half addder to add 1 with 2*twps
half_adder #(
    //----------------------------parameters-------------------------------------
	.WIDTH          (3)
) u_half_adder_1_plus_m1(
    //------------------------------inputs---------------------------------------
	.a              (3'b1),
	.b              (m1[2:0]),
    //------------------------------outputs--------------------------------------
	.sum            (h1[2:0])
);

// barrel shifter for multiuplying 2^(1+2*twps) with twbr value
barrel_shifter_nbit #(
    //----------------------------parameters-------------------------------------
	.WIDTH          (16)
) u_barrel_shifter_nbit_twbr_into_h1(
    //------------------------------inputs---------------------------------------
	.shift_by       (h1[2:0]),
	.shift_dir      (1'b1), 
	.shifter_in     ({8'd0, twbr[BIT_RATE_CONST_WIDTH-1:0]}),
	//------------------------------outputs--------------------------------------
	.shifter_out    (m2[15:0])
);

// half adder to add 16 with (2^(1+2*twps))*twbr 
half_adder #(
    //----------------------------parameters-------------------------------------
	.WIDTH          (16)
) u_half_adder_16_plus_m2(
    //------------------------------inputs---------------------------------------
	.a              (16'd16),
	.b              (m2[15:0]),
    //------------------------------outputs--------------------------------------
	.sum            (h2[15:0])
);

dff #(
    //----------------------------parameters-------------------------------------
    .FLOP_WIDTH     (1)
) u_scl_state_flop(
    //------------------------------inputs---------------------------------------
	.clk            (pclk),
	.resetn         (presetn),
	.en             (scl_gen_flop_en),
	.d              (scl_t3),
    //------------------------------outputs--------------------------------------
	.q              (scl_gen_temp_scl)
);

//===============================================================================

//===================================logics======================================

//logics for scl state flop

assign  scl_hold    =   ~scl_pad_i          &   scl_gen_temp_scl    &   ~interrupt_pad_o;
assign  clear_cntr  =   scl_gen_comp_match  |   ~scl_en             ;

assign  scl_t3      =   scl_hold            ?   scl_gen_temp_scl    :   scl_t2;
assign  scl_t2      =   scl_en              ?   scl_t1              :   scl_pad_i;
assign  scl_t1      =   scl_gen_comp_match  ?   ~scl_gen_temp_scl   :   scl_gen_temp_scl;

//===============================================================================

endmodule

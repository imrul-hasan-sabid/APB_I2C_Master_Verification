module sta_sto_gen #(
    `include "params.sv"
) (
    //-----------------------input ports--------------------------
    
    input   logic   gen_sta,            // Input signal to generate start
    input   logic   gen_sto,            // Input signal to generate stop
    input   logic   scl_gen_comp_match, // SCL generator internal clock clear signal 
    
    //----------------------output ports--------------------------
    
    output  logic   sta_sto_gen_sda,    // SDA signal for generating start or stop condition
    output  logic   sta_sto_gen_scl     // SCL signal for generating start or stop condition
);

//========================neccessary nets=========================

logic   sda_gen;
logic   not_gen_sta;
logic   not_scl_gen_comp_match;

//================================================================

//=====================module instantiations======================

mux41 u_mux41_sda_gen(
    //-------------------------inputs-----------------------------
	.i0     (1'b0),
	.i1     (not_gen_sta),
	.i2     (sda_gen),
	.i3     (1'b0),
	.sel    ({gen_sto, gen_sta}),
    //-------------------------outputs----------------------------
	.out    (sta_sto_gen_sda)
);

mux41 u_mux41_scl_gen(
    //-------------------------inputs-----------------------------
	.i0     (1'b0),
	.i1     (not_scl_gen_comp_match),
	.i2     (gen_sto),
	.i3     (1'b0),
	.sel    ({gen_sto, gen_sta}),
    //-------------------------outputs----------------------------
	.out    (sta_sto_gen_scl)
);

//================================================================

//============================logics==============================

assign  not_gen_sta             =   ~gen_sta;
assign  not_scl_gen_comp_match  =   ~scl_gen_comp_match;
assign  sda_gen                 =   gen_sto & scl_gen_comp_match;

//================================================================

endmodule

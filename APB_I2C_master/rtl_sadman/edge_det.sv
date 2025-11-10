module edge_det (
    //-----------------------input ports--------------------------
    
    input   logic   pclk,           // System clock
    input   logic   presetn,        // System reset
    input   logic   clk_in,         // SCL input signal from pad
    input   logic   edge_det_en,    // Block enable signal for reducing power consumption
    
    //----------------------output ports--------------------------
    
    output  logic   edge_det_pos,   // Output signal indicating positive edge of SCL is detected 
    output  logic   edge_det_neg    // Output signal indicating negative edge of SCL is detected
);

//========================neccessary nets=========================

logic   ff_out;

//================================================================

//=====================module instantiations======================

dff #(
    //-----------------------parameters---------------------------
    .FLOP_WIDTH     (1)
) u_dff_store_previous_level(
    //-------------------------inputs-----------------------------
	.clk            (pclk),
	.resetn         (presetn),
	.en             (edge_det_en),
	.d              (clk_in),
    //------------------------outputs-----------------------------
	.q              (ff_out)
);

//================================================================

//============================logics==============================

//logic for the detection of positive edge
assign  edge_det_pos    =   (ff_out ^ clk_in) & clk_in;

//logic for the detection of negative edge
assign  edge_det_neg    =   (ff_out ^ clk_in) & (~clk_in);

//================================================================

endmodule

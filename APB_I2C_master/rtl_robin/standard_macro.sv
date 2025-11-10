/* ----------------------------------------------------------------------------------------------------------------------- */
/*                                                       D Flip Flop                                                       */
/* ----------------------------------------------------------------------------------------------------------------------- */
module  dff #(
        parameter FLOP_WIDTH = 32, 
        parameter RESET_VALUE = 32'b0
)(
	    input   logic                     clk, 
	    input   logic                     resetn, 
        input   logic                     en, 
	    input   logic [FLOP_WIDTH-1:0]    d,
         
	    output  logic [FLOP_WIDTH-1:0]    q
); 
	
	always @(posedge clk or negedge resetn) begin
		if(~resetn) 
			q[FLOP_WIDTH-1:0] <= RESET_VALUE; 
		else 
			q[FLOP_WIDTH-1:0] <= en ? d[FLOP_WIDTH-1:0] : q[FLOP_WIDTH-1:0]; 
	end 
	
endmodule 


/* ----------------------------------------------------------------------------------------------------------------------- */
/*                                                  UP Counter With Clear                                                  */
/* ----------------------------------------------------------------------------------------------------------------------- */
module  counter #(   
        parameter COUNTER_WIDTH =32, 
        parameter RESET_VALUE   = 32'h0
)(
        input   logic                       clk, 
        input   logic                       resetn, 
        input   logic                       clear, 
        input   logic                       inc,

        output  logic [COUNTER_WIDTH-1:0]   count
    ); 

    always @(posedge clk or negedge resetn) begin
        if(~resetn)
            count[COUNTER_WIDTH-1:0] <= RESET_VALUE; 
        else 
            count[COUNTER_WIDTH-1:0] <= clear? {COUNTER_WIDTH{1'b0}} : count[COUNTER_WIDTH-1:0] + inc; 
    end 
endmodule 

/* ----------------------------------------------------------------------------------------------------------------------- */
/*                                                 Universal shift register                                                */
/*                                00 : No change, 01 : Left Shift, 10 : Right Shift, 11 : Load Value                       */
/* ----------------------------------------------------------------------------------------------------------------------- */
module  uni_shift_reg #(
        parameter SHIFT_REG_WIDTH=8, 
        parameter RESET_VALUE = 8'h0
)(
        input   logic                       clk, 
        input   logic                       resetn, 
        input   logic                       serial_in,                    
        input   logic [SHIFT_REG_WIDTH-1:0] load, 
        input   logic [1:0]                 mode, 
        
        output  logic [SHIFT_REG_WIDTH-1:0] pout
);     

  always @ (posedge clk or negedge resetn)
    if (~resetn)
        pout[SHIFT_REG_WIDTH-1:0] <= RESET_VALUE;
    else begin
        casez(mode)
            2'b00	    : pout[SHIFT_REG_WIDTH-1:0] <= pout[SHIFT_REG_WIDTH-1:0]; 
            2'b10 	    : pout[SHIFT_REG_WIDTH-1:0] <= {pout[SHIFT_REG_WIDTH-2:0], serial_in       };
            2'b01 	    : pout[SHIFT_REG_WIDTH-1:0] <= {serial_in,       pout[SHIFT_REG_WIDTH-1:1] };
            2'b11 	    : pout[SHIFT_REG_WIDTH-1:0] <= load[SHIFT_REG_WIDTH-1:0]; 
            default 	: pout[SHIFT_REG_WIDTH-1:0] <= {SHIFT_REG_WIDTH{1'bx}}; 
        endcase
    end
endmodule   


/* ----------------------------------------------------------------------------------------------------------------------- */
/*                                                        Comparator                                                       */
/* ----------------------------------------------------------------------------------------------------------------------- */
module  comparator #(
        parameter COMPARATOR_WIDTH = 12
)(
        input   logic [COMPARATOR_WIDTH-1:0]    value_1, 
        input   logic [COMPARATOR_WIDTH-1:0]    value_2, 

        output  logic                           is_equal 
        //output  logic                           is_greater, 
        //output  logic                           is_less
);  

    assign is_equal     = value_1[COMPARATOR_WIDTH-1:0] == value_2[COMPARATOR_WIDTH-1:0]; 
    //assign is_greater   = value_1[COMPRATOR_WIDTH-1:0] > value_2[COMPARATOR-WIDTH-1:0]; 
    //assign is_less      = value_1[COMPRATOR_WIDTH-1:0] > value_2[COMPARATOR-WIDTH-1:0]; 
endmodule           




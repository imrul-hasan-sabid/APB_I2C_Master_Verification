module  start_stop_generator(
        input   logic   clk                               	, 
        input   logic   resetn                            	, 
        input   logic   start_en                          	, 
        input   logic   stop_en                           	, 
        input   logic   restart_en                        	, 
        input   logic   half_scl                          	, 
		input 	logic 	start_stop_generator_flop_en      	, 

        output  logic   start_stop_generator_sda_out_en   	, 
        output  logic   start_stop_generator_sda_out      	, 
        output  logic   start_stop_generator_scl_out_en   	, 
        output  logic   start_stop_generator_scl_out      	, 

        output  logic   start_stop_generator_stop_complete	, 
        output  logic   start_stop_generator_start_complete
);


	//* State Variables 
    localparam STATE_WIDTH = 3;
	logic [STATE_WIDTH-1:0] pstate, nstate; 


	//* State Declaration 
	localparam 	IDLE	= 3'd0, 
				START_1	= 3'd1, 
				START_2	= 3'd2, 
				RESTART = 3'd3,
				STOP_1	= 3'd4,
				STOP_2	= 3'd5, 
				STOP_3	= 3'd6; 

	//* Next State Logic 	
	always @(*) begin
		casez(pstate)
			IDLE	:	begin 
							casez({start_en, stop_en, restart_en})
								3'b000	: nstate = IDLE; 
								3'b?1?	: nstate = STOP_1; 
								3'b10?	: nstate = START_1; 
								3'b001	: nstate = RESTART; 
								default : nstate = 'bx; 
							endcase 
						end 

			START_1	: 	nstate = half_scl ? START_2 					: START_1	; 
			START_2	: 	nstate = half_scl ? IDLE						: START_2	; 
			RESTART	: 	nstate = half_scl ? START_1						: RESTART	; 
			STOP_1	: 	nstate = half_scl ? STOP_2						: STOP_1	; 
			STOP_2	: 	nstate = half_scl ? STOP_3						: STOP_2	; 
			STOP_3	: 	nstate = start_en ? half_scl? START_1: STOP_3	: IDLE		; 
			default	: 	nstate = 'bx; 
		endcase 
	end


	//* Present State Status Register
	dff #(.FLOP_WIDTH(STATE_WIDTH), .RESET_VALUE(3'b0)) u_PSR(
        .clk	(clk							), 
        .resetn	(resetn							), 
        .en		(start_stop_generator_flop_en	), 

        .d		(nstate							), 
        .q		(pstate							)
    ); 

	assign start_stop_generator_sda_out_en		= ~(pstate == IDLE); 
	assign start_stop_generator_sda_out			=  (pstate == RESTART) | (pstate == IDLE) | (pstate == STOP_3); 
	assign start_stop_generator_scl_out_en		= ~(pstate == IDLE); 
	assign start_stop_generator_scl_out			= ((pstate == IDLE) & start_en & ~stop_en) 	| (pstate == START_1)
																							| (pstate == RESTART)
																						   	| (pstate == STOP_2) 
																							| (pstate == STOP_3);

	assign start_stop_generator_stop_complete  	=  (pstate == STOP_3)   ;//& half_scl; 
	assign start_stop_generator_start_complete 	=  (pstate == START_2)  & half_scl; 

endmodule 
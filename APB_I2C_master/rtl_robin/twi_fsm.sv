module  twi_fsm(
        input   logic   clk             			, //
        input   logic   resetn               		, //
        input   logic   twint                 		, //
		input   logic   twsto                   	, 
        input   logic   twsta                  		, //
		input 	logic 	twen                    	, 
		input 	logic 	bus_busy                	, 
		input 	logic 	start_complete          	, 
		input 	logic 	stop_complete				,
		input 	logic 	byte_transfer_complete		, 
		input 	logic 	ack_transfer_complete   	, 
        input   logic   twi_fsm_flop_en  			, 
		input 	logic 	write                   	, 
		input 	logic 	arbitration_lost			, 

		output 	logic 	twi_fsm_start_en         	, 
		output 	logic 	twi_fsm_restart_en       	, 
		output 	logic 	twi_fsm_stop_en          	, 
		output 	logic 	twi_fsm_scl_gen_en       	, 
		output 	logic 	twi_fsm_data_transfer_en 	, 
		output 	logic 	twi_fsm_ack_transfer_en  	,
		output 	logic 	twi_fsm_data_transfer_dir	,
		output 	logic 	twi_fsm_ack_transfer_dir 	,
		output 	logic 	twi_fsm_sla_sent         	, 
		output 	logic 	twi_fsm_master_mode			, 
		output 	logic 	twi_fsm_status_update		, 

        output  logic   twi_fsm_twint_set			, 
        output  logic   twi_fsm_twsta_clr			, 
        output  logic   twi_fsm_twsto_clr			, 
        output  logic   twi_fsm_twen_clr 			

); 

	//* Internal wire 
	logic sla_sent_flop_q; 
	logic sla_sent_flop_d; 
	logic sla_sent; 
	logic stop_start; 

    //* State Variables 
    localparam  STATE_WIDTH = 4;
    logic [STATE_WIDTH-1:0] pstate, nstate; 

    //* State Declaration
    localparam  IDLE            	= 'd00;
	localparam	START				= 'd02;  
    localparam  START_COMP      	= 'd03;     
    localparam  TRANSFER_START      = 'd04; 
    localparam  ACK_START		    = 'd05; 
    localparam  TRANSFER_COMP       = 'd06; 
    localparam  STOP			    = 'd07;
    localparam  REP_START       	= 'd08; 
	localparam	STOP_COMP 			= 'd09;
	localparam 	STOP_START 			= 'd10; 
	localparam	ARBITRATION_LOST 	= 'd11;  

	//* Next State Logic 
	always @(*) begin
		casez(pstate)
			IDLE				: 	nstate = (~twint & twsta & twen & ~bus_busy) ? START				: IDLE; 
			START				: 	nstate = twen ? start_complete ? START_COMP: START    				: IDLE; 
			START_COMP			: 	nstate = twen ? ~twint? TRANSFER_START: START_COMP														: IDLE; 
			TRANSFER_START		: 	nstate = twen ? arbitration_lost? ARBITRATION_LOST :byte_transfer_complete? ACK_START: TRANSFER_START	: IDLE; 
			ACK_START			: 	nstate = twen ? arbitration_lost? ARBITRATION_LOST :ack_transfer_complete ? TRANSFER_COMP: ACK_START	: IDLE;
			TRANSFER_COMP		: 	begin 
										casez({twen, ~twint, twsto, twsta})
											4'b0???	: nstate = IDLE; 
											4'b10?? : nstate = TRANSFER_COMP; 
											4'b1100	: nstate = TRANSFER_START; 
											4'b1101	: nstate = REP_START; 	
											4'b1110 : nstate = STOP; 
											4'b1111	: nstate = STOP_START; 
											default : nstate = 'bx; 
										endcase 
									end	

			STOP				: 	nstate = twen ? stop_complete? STOP_COMP : STOP						: IDLE; 
			REP_START			: 	nstate = twen ? start_complete ? START_COMP: REP_START 				: IDLE; 
			STOP_COMP			: 	nstate = IDLE; 

			STOP_START			: 	nstate = twen ? start_complete? START_COMP: STOP_START :IDLE; 
			ARBITRATION_LOST	: 	nstate = IDLE; 
			default				: 	nstate = 'bx; 	
		endcase 
	end 


	//* Present State Register 
    dff #(.FLOP_WIDTH(STATE_WIDTH), .RESET_VALUE(5'b0)) u_PSR(
        .clk	(clk				), 
        .resetn	(resetn				), 
        .en		(twi_fsm_flop_en	), 

        .d		(nstate				), 
        .q		(pstate				)
    ); 



	//* sla_sent flag register 
	dff #(.FLOP_WIDTH(1), .RESET_VALUE(1'b0)) u_sla_sent_flop(
		.clk	(clk				), 
		.resetn	(resetn				), 
		.en		(twi_fsm_flop_en	), 

		.d		(sla_sent_flop_d	), 
		.q		(sla_sent_flop_q	)
	);


	assign 	sla_sent_flop_d	= (pstate == START_COMP) ? 1'b1: (pstate == TRANSFER_COMP) ? 1'b0 : sla_sent_flop_q; 
	
	

	assign stop_start 	= (pstate == STOP | pstate == STOP_COMP) & twsta; 
	assign sla_sent		= sla_sent_flop_q; 
	/* ----------------------------------------------------------------------------------------------------------------------- */
	/*                                                        FSM output                                                       */
	/* ----------------------------------------------------------------------------------------------------------------------- */

	assign twi_fsm_start_en	    		= (pstate == START) | (pstate == STOP_START);
	assign twi_fsm_restart_en			= (pstate == REP_START); 
	assign twi_fsm_stop_en           	= (pstate == STOP) | (pstate == STOP_START); 
	assign twi_fsm_scl_gen_en        	= (pstate == START) | (pstate == TRANSFER_START) 
															| (pstate == ACK_START) 
															| (pstate == STOP) 
															| (pstate == REP_START)
															| (pstate == STOP_COMP)
															| (pstate == STOP_START); 

	assign twi_fsm_data_transfer_en  	= (pstate == TRANSFER_START); 
	assign twi_fsm_ack_transfer_en   	= (pstate == ACK_START); 
	assign twi_fsm_data_transfer_dir	= (pstate == TRANSFER_START) & 	 (sla_sent | ~write) ; 
	assign twi_fsm_ack_transfer_dir 	= (pstate == ACK_START)		 & (~(sla_sent | ~write)); 

	assign twi_fsm_sla_sent          	= sla_sent_flop_q; 
	assign twi_fsm_twint_set        	= (( pstate == START  | pstate == START_COMP | pstate == REP_START | pstate == STOP_START) & start_complete) 
																			   | ((pstate == ACK_START) & (ack_transfer_complete | arbitration_lost))
																			   | ((pstate == TRANSFER_START) & arbitration_lost);
																			  

	assign twi_fsm_status_update     	= (((pstate == START) 	| (pstate == REP_START) 
																| (pstate== STOP_START)) & start_complete) 
																| ((pstate== ACK_START) & (ack_transfer_complete | arbitration_lost))
	 															| ((pstate == TRANSFER_START) & arbitration_lost); 								   
	assign twi_fsm_twsta_clr        	= (pstate == START_COMP); 
	assign twi_fsm_twsto_clr         	= (pstate == STOP_COMP);
	assign twi_fsm_twen_clr          	= (pstate == IDLE); 
	assign twi_fsm_master_mode			= ~((pstate == IDLE) | ((pstate == STOP_COMP) & ~twsta) | (pstate == ARBITRATION_LOST)); 
endmodule 
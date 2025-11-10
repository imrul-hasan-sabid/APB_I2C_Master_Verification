module  bus_interface_unit #(
		`include "twi_parameters.sv"
)(
        input   logic					clk                          				, 
        input   logic				   	resetn                       				, 
        input   logic				   	sda_in                       				, 
        input   logic				   	scl_in                       				, 
        input   logic				   	half_scl                     				, 
		input 	logic 					bus_interface_unit_flop_en          		, 
		input 	logic 					start_en                            		, 
		input 	logic					restart_en                          		, 
		input 	logic 					stop_en                             		,
		input 	logic [TWDR_WIDTH-1:0]	wr_data                        				, 
		input 	logic 					twdr_wr_en                          		,
		input 	logic 					twcr_wr_en                          		,  
		input 	logic 					data_transfer_en                    		,
		input 	logic 					ack_transfer_en								, 
		input 	logic 					data_transfer_dir                   		, 
		input 	logic 					ack_transfer_dir                    		, 
		input 	logic 					twea										, 
		input 	logic 					twint 										, 
		input 	logic					sla_sent									, 
		input 	logic 					master_mode									, 

		output 	logic 					bus_interface_unit_bus_busy         		, 
		output 	logic 					bus_interface_unit_start_complete   		, 
		output 	logic 					bus_interface_unit_stop_complete    		, 
		output 	logic 					bus_interface_unit_arbitration_lost 		, 
		output 	logic [TWDR_WIDTH-1:0]	bus_interface_unit_twdr_rx_q				, 
		output 	logic 					bus_interface_unit_write					,
		output 	logic 					bus_interface_unit_byte_transfer_complete	, 
		output	logic 					bus_interface_unit_ack_transfer_complete	,
		output 	logic 					bus_interface_unit_ack_bit					, 

		output 	logic 					bus_interface_unit_scl_out_en       		, 
		output 	logic 					bus_interface_unit_sda_out_en       		, 
		output 	logic 					bus_interface_unit_scl_out          		, 
		output 	logic 					bus_interface_unit_sda_out
); 

	/* ----------------------------------------------------------------------------------------------------------------------- */
	/*                                                     Port Declaration                                                    */
	/* ----------------------------------------------------------------------------------------------------------------------- */
	//* bus_busy_detector 
	logic 							bus_busy_detector_bus_busy          ; 

	//* scl_sda_edge_detector
	logic   						scl_sda_edge_detector_scl_rise_edge	; 
	logic   						scl_sda_edge_detector_scl_fall_edge	; 
	logic   						scl_sda_edge_detector_sda_rise_edge	; 
	logic   						scl_sda_edge_detector_sda_fall_edge	; 

	//* start_stop_detector
	logic 							start_stop_detector_start_detected  ; 
	logic 							start_stop_detector_stop_detected   ; 

	//* start_stop_generator
	logic 							start_stop_generator_scl_out_en     ; 
	logic 							start_stop_generator_sda_out_en     ; 
	logic   						start_stop_generator_scl_out       	;
	logic 							start_stop_generator_sda_out        ; 
	logic 							start_stop_generator_start_complete ; 
	logic 							start_stop_generator_stop_complete  ; 

	//* arbitration_check 
	logic 							arbitration_check_arbitration_lost  ; 

	//* twdr_tx 
	logic [TWDR_WIDTH+1:0] 			twdr_tx_q                			;
	logic [TWDR_WIDTH+1:0]			twdr_tx_load              			;  
	logic [TWDR_MODE_WIDTH-1:0]		twdr_tx_mode        				; 

	//* twdr_rx
	logic [TWDR_WIDTH:0] 			twdr_rx_q                			; 
	logic [TWDR_WIDTH:0]			twdr_rx_load              			;  
	logic [TWDR_MODE_WIDTH-1:0]		twdr_rx_mode        				; 

	//* bit_counter
	logic [BIT_COUNTER_WIDTH-1:0] 	bit_counter_count 					; 
	logic							bit_counter_clear                   ; 
	logic 							bit_counter_inc                     ; 

	//* scl_generator 
	logic 							scl_generator_scl                   ; 

	//* bit_comparator_9
	logic 							bit_comparator_9_bit_count_9		; 

	//* bit_comparator_8	
	logic 							bit_comparator_8_bit_count_8		; 
	/* ----------------------------------------------------------------------------------------------------------------------- */

	/* ---------------------------------------------------- Internal Wire ---------------------------------------------------- */
	logic							shift_en; 
	logic 							sample_en; 
	logic 	[TWDR_MODE_WIDTH-1:0]	twdr_tx_mode_shift; 
	logic 	[TWDR_WIDTH+1:0] 		twdr_tx_load_cr_wr;

	logic   [TWDR_MODE_WIDTH-1:0]	twdr_rx_mode_sample; 

	logic 							write_flop_d; 
	logic 							write_flop_q; 


    bus_busy_detector u_bus_busy_detector(
        .clk	                    			(clk                                	),
        .resetn                     			(resetn                            		),
        .start_detected             			(start_stop_detector_start_detected		),
        .stop_detected              			(start_stop_detector_stop_detected 		),
        .bus_busy_detector_flop_en				(bus_interface_unit_flop_en         	),

        .bus_busy_detector_bus_busy				(bus_busy_detector_bus_busy        		)
    ); 

	scl_sda_edge_detector u_scl_sda_edge_detector(
		.clk                                 	(clk                                 	), 
		.resetn                              	(resetn                              	), 
		.scl_in                              	(scl_in                              	), 
		.sda_in                              	(sda_in                              	), 
		.scl_sda_edge_detector_flop_en       	(bus_interface_unit_flop_en          	), 

		.scl_sda_edge_detector_scl_rise_edge	(scl_sda_edge_detector_scl_rise_edge	), 
		.scl_sda_edge_detector_scl_fall_edge	(scl_sda_edge_detector_scl_fall_edge  	), 
		.scl_sda_edge_detector_sda_rise_edge 	(scl_sda_edge_detector_sda_rise_edge 	), 
		.scl_sda_edge_detector_sda_fall_edge 	(scl_sda_edge_detector_sda_fall_edge 	)
	 ); 

	start_stop_detector u_start_stop_detector(
		.sda_rise_edge                   		(scl_sda_edge_detector_sda_rise_edge	), 
		.sda_fall_edge                   		(scl_sda_edge_detector_sda_fall_edge	), 
		.scl                             		(scl_in                             	), 

		.start_stop_detector_start_detected		(start_stop_detector_start_detected		), 
		.start_stop_detector_stop_detected  	(start_stop_detector_stop_detected  	)
	); 

	start_stop_generator u_start_stop_generator(
		.clk                                 	(clk                               		), 
		.resetn                              	(resetn                            		), 
		.start_en                            	(start_en                          		), 
		.stop_en                             	(stop_en                           		), 
		.restart_en                          	(restart_en                        		), 
		.half_scl                            	(half_scl                          		), 
		.start_stop_generator_flop_en        	(bus_interface_unit_flop_en        		), 

		.start_stop_generator_sda_out_en     	(start_stop_generator_sda_out_en   		), 
		.start_stop_generator_scl_out_en     	(start_stop_generator_scl_out_en   		), 
		.start_stop_generator_sda_out        	(start_stop_generator_sda_out      		), 
		.start_stop_generator_scl_out        	(start_stop_generator_scl_out      		), 
		.start_stop_generator_stop_complete  	(start_stop_generator_stop_complete		), 
		.start_stop_generator_start_complete	(start_stop_generator_start_complete	)
	); 


	arbitration_check u_arbitration_check(
		.clk                                  	(clk                                 	), 
		.resetn                               	(resetn                              	), 
		.scl_rise_edge                        	(scl_sda_edge_detector_scl_rise_edge 	), 
		.sda_in                               	(sda_in                              	),
		.sda_out                              	(bus_interface_unit_sda_out            	),
		.master_mode							(master_mode							), 
		.data_transfer_dir						(data_transfer_dir						), 
		.ack_transfer_dir						(ack_transfer_dir						),  
		.arbitration_check_flop_en            	(bus_interface_unit_flop_en          	), 

		.arbitration_check_arbitration_lost   	(arbitration_check_arbitration_lost  	)
	); 

	uni_shift_reg #(.SHIFT_REG_WIDTH(TWDR_WIDTH+2), .RESET_VALUE(TWDR_RESET_VALUE))	u_twdr_tx(
		.clk         						  	(clk         							), 
		.resetn      						  	(resetn      							), 
		.serial_in   						  	(1'b1      								), 
		.load        						  	(twdr_tx_load							),
		.mode								  	(twdr_tx_mode      						), 

		.pout        						  	(twdr_tx_q   							) 
	); 

	uni_shift_reg #(.SHIFT_REG_WIDTH(TWDR_WIDTH+1), .RESET_VALUE(TWDR_RESET_VALUE))	u_twdr_rx(
		.clk                 					(clk                                   	), 
		.resetn              					(resetn                                	), 
		.serial_in           					(sda_in                                	), 
		.load                					(twdr_tx_load[TWDR_WIDTH:0]             ),
		.mode                					(twdr_rx_mode                          	), 

		.pout                					(twdr_rx_q                             	) 
	); 

	counter #(.COUNTER_WIDTH(BIT_COUNTER_WIDTH), .RESET_VALUE(4'd0)) u_bit_counter(
		.clk                      				(clk                                    ), 
		.resetn                   				(resetn                                 ), 
		.clear                    				(bit_comparator_9_bit_count_9  | twint  ), 
		.inc                      				(shift_en		                       	), 

		.count                    				(bit_counter_count                      )
	); 

	scl_generator u_scl_generator(
		.clk                           			(clk                                   	), 
		.resetn                        			(resetn                                	),
		.half_scl								(half_scl								), 
		.twint									(twint									), 
		.scl_generator_flop_en         			(bus_interface_unit_flop_en            	),

		.scl_generator_scl            			(scl_generator_scl						)
	); 

	comparator #(.COMPARATOR_WIDTH(4)) u_bit_comparator_9(
		.value_1(bit_counter_count), 
		.value_2(4'd9), 
		
		.is_equal(bit_comparator_9_bit_count_9)
	); 

	comparator #(.COMPARATOR_WIDTH(4)) u_bit_comparator_8(
		.value_1(bit_counter_count), 
		.value_2(4'd8), 

		.is_equal(bit_comparator_8_bit_count_8)
	); 

	dff #(.FLOP_WIDTH(1), .RESET_VALUE(1'b0)) u_write_flop(
		.clk(clk), 
		.resetn(resetn), 
		.en(bus_interface_unit_flop_en), 
		.d(write_flop_d), 
		.q(write_flop_q)
	); 


	assign write_flop_d 		= twdr_wr_en & sla_sent ?  wr_data[0] : write_flop_q; 

	assign twdr_rx_mode_sample 	[TWDR_MODE_WIDTH-1:0]		= sample_en ? 2'b01: 2'b00; 
	assign twdr_rx_mode 		[TWDR_MODE_WIDTH-1:0]		= twdr_wr_en | twcr_wr_en ? 2'b11 : twdr_rx_mode_sample; 

	assign twdr_tx_mode_shift	[TWDR_MODE_WIDTH-1:0]		= shift_en ? 2'b01: 2'b00; 
	assign twdr_tx_mode 		[TWDR_MODE_WIDTH-1:0]		= twdr_wr_en | twcr_wr_en ? 2'b11 : twdr_tx_mode_shift; 

	assign twdr_tx_load_cr_wr	[TWDR_WIDTH+1:0]			= twcr_wr_en ? {twdr_tx_q[TWDR_WIDTH+1:1], ~wr_data[6]} : twdr_tx_q[TWDR_WIDTH+1:0];
	assign twdr_tx_load 		[TWDR_WIDTH+1:0]			= twdr_wr_en ? {1'b0, wr_data[TWDR_WIDTH-1:0], 1'b1} : twdr_tx_load_cr_wr; 

	assign sample_en 			= (data_transfer_en | ack_transfer_en)  & scl_sda_edge_detector_scl_rise_edge; 
	assign shift_en				= (data_transfer_en | ack_transfer_en)  & scl_sda_edge_detector_scl_fall_edge; 

	/* ----------------------------------------------------------------------------------------------------------------------- */
	/*                                                    Output Definition                                                    */
	/* ----------------------------------------------------------------------------------------------------------------------- */
	assign 	bus_interface_unit_bus_busy						= bus_busy_detector_bus_busy; 
	assign 	bus_interface_unit_stop_complete				= start_stop_generator_stop_complete; 
	assign 	bus_interface_unit_start_complete				= start_stop_generator_start_complete; 
	assign 	bus_interface_unit_arbitration_lost				= arbitration_check_arbitration_lost; 
	assign 	bus_interface_unit_byte_transfer_complete		= bit_comparator_8_bit_count_8; 
	assign 	bus_interface_unit_ack_transfer_complete		= bit_comparator_9_bit_count_9; 
	assign 	bus_interface_unit_twdr_rx_q [TWDR_WIDTH-1:0] 	= twdr_rx_q[TWDR_WIDTH:1]; 
	assign 	bus_interface_unit_write						= write_flop_q; 
	assign 	bus_interface_unit_ack_bit						= ack_transfer_dir? twdr_tx_q[9] : twdr_rx_q[0]; 

	assign 	bus_interface_unit_scl_out_en					= master_mode ; //(data_transfer_en | ack_transfer_en) ? 1'b1 : master_mode & start_stop_generator_scl_out_en;
	assign 	bus_interface_unit_sda_out_en					= (data_transfer_en | ack_transfer_en) ? (data_transfer_dir | ack_transfer_dir) : start_stop_generator_sda_out_en; 
	assign 	bus_interface_unit_scl_out						= (data_transfer_en | ack_transfer_en) ? scl_generator_scl & ~twint : start_stop_generator_scl_out & ~twint; 
	assign 	bus_interface_unit_sda_out						= (data_transfer_en | ack_transfer_en) ? (bit_comparator_8_bit_count_8 & data_transfer_dir & sla_sent ? write_flop_q :twdr_tx_q[8]) : start_stop_generator_sda_out; 

	/* ----------------------------------------------------------------------------------------------------------------------- */

endmodule 
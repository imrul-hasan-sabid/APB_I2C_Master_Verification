module  twi #(
        `include "twi_parameters.sv"
)(

        //DFT Scan Signal 
        input   logic                       TM          , 
        input   logic                       SE          , 

        //Design Signal
        input   logic                   	pclk        , 
        input   logic                   	presetn     , 
        input   logic                  		psel        , 
        input   logic                   	penable     , 
        input   logic                   	pwrite      , 
        input   logic [APB_ADDR_WIDTH-1:0]  paddr       , 
        input   logic [APB_DATA_WIDTH-1:0]  pwdata      , 

        output  logic [APB_DATA_WIDTH-1:0]  prdata      , 
        output  logic                   	pready      , 


        input   logic                       scl_in      , 
        input   logic                       sda_in      , 

        output  logic                       scl_out_en  , 
        output  logic                       sda_out_en  , 
        output  logic                       sda_out     , 
        output  logic                       scl_out     , 
        output  logic                       interrupt
); 

	/* ----------------------------------------------------------------------------------------------------------------------- */
	/*                                           Module Port Declaration                                                       */
	/* ------------------------------------------------------------------------------------------------------------------------*/
    //* apb_twi_slave_interface
    logic                   apb_twi_slave_interface_twint               ; 
    logic                   apb_twi_slave_interface_twea                ; 
    logic                   apb_twi_slave_interface_twsta               ; 
    logic                   apb_twi_slave_interface_twsto               ; 
    logic                   apb_twi_slave_interface_twen                ; 
    logic                   apb_twi_slave_interface_twie                ; 
    logic [TWDR_WIDTH-1:0]  apb_twi_slave_interface_wr_data             ; 
    logic                   apb_twi_slave_interface_twdr_wr_en          ;
    logic                   apb_twi_slave_interface_twcr_wr_en          ;
    logic [TWBR_WIDTH-1:0]  apb_twi_slave_interface_twbr                ; 
    logic [TWPS_WIDTH-1:0]  apb_twi_slave_interface_twps                ; 

    //* bus_interface_unit
    logic                   bus_interface_unit_bus_busy                 ;
    logic                   bus_interface_unit_start_complete           ;
    logic                   bus_interface_unit_stop_complete            ;
    logic                   bus_interface_unit_arbitration_lost         ;
    logic                   bus_interface_unit_byte_transfer_complete   ; 
    logic                   bus_interface_unit_ack_transfer_complete    ; 
    logic [TWDR_WIDTH-1:0]  bus_interface_unit_twdr_rx_q                ; 
    logic                   bus_interface_unit_write                    ; 
    logic                   bus_interface_unit_ack_bit                  ; 

    //* twi_fsm
    logic 	                twi_fsm_start_en         	                ; 
    logic 	                twi_fsm_restart_en       	                ; 
    logic 	                twi_fsm_stop_en          	                ; 
    logic 	                twi_fsm_scl_gen_en       	                ; 
    logic 	                twi_fsm_data_transfer_en 	                ; 
    logic 	                twi_fsm_ack_transfer_en  	                ;
    logic 	                twi_fsm_data_transfer_dir	                ;
    logic 	                twi_fsm_ack_transfer_dir 	                ;
    logic 	                twi_fsm_sla_sent         	                ; 
    logic                   twi_fsm_twint_set			                ; 
    logic                   twi_fsm_twsta_clr			                ; 
    logic                   twi_fsm_twsto_clr			                ; 
    logic                   twi_fsm_twen_clr 			                ; 
    logic                   twi_fsm_twwc_set 			                ;
    logic                   twi_fsm_master_mode                         ;  
    logic                   twi_fsm_status_update                       ; 

    //* half_scl_generator
    logic                   half_scl_generator_half_scl                 ; 

    //* status_code_generator 
    logic [TWS_WIDTH-1:0]  status_code_generator_status_value           ; 
    /* ----------------------------------------------------------------------------------------------------------------------- */

    /* ---------------------------------------------------- Internal Wire ---------------------------------------------------- */
    logic   flop_en; 

    apb_twi_slave_interface u_apb_twi_slave_interface(
        .pclk                                       (pclk                                       ),
        .presetn                                    (presetn                                    ),
        .psel                                       (psel                                       ),
        .penable                                    (penable                                    ),
        .pwrite                                     (pwrite                                     ),
        .paddr                                      (paddr                                      ),
        .pwdata                                     (pwdata                                     ),

        .prdata                                     (prdata                                     ),
        .pready                                     (pready                                     ),

        .twint_set                                  (twi_fsm_twint_set                          ),
        .twsta_clr                                  (twi_fsm_twsta_clr                          ),
        .twsto_clr                                  (twi_fsm_twsto_clr                          ),
        .twen_clr                                   (twi_fsm_twen_clr                           ),
		.apb_twi_slave_interface_flop_en            (flop_en                                    ),
        .twdr_rx_q                                  (bus_interface_unit_twdr_rx_q               ),
        .status_update                              (twi_fsm_status_update                      ), 
        .status_value                               (status_code_generator_status_value         ), 

        .apb_twi_slave_interface_twint              (apb_twi_slave_interface_twint              ),
        .apb_twi_slave_interface_twea               (apb_twi_slave_interface_twea               ),
        .apb_twi_slave_interface_twsta              (apb_twi_slave_interface_twsta              ),
        .apb_twi_slave_interface_twsto              (apb_twi_slave_interface_twsto              ),
        .apb_twi_slave_interface_twen               (apb_twi_slave_interface_twen               ),
        .apb_twi_slave_interface_twie               (apb_twi_slave_interface_twie               ),
        .apb_twi_slave_interface_wr_data            (apb_twi_slave_interface_wr_data            ),
        .apb_twi_slave_interface_twdr_wr_en         (apb_twi_slave_interface_twdr_wr_en         ),
        .apb_twi_slave_interface_twcr_wr_en         (apb_twi_slave_interface_twcr_wr_en         ), 
        .apb_twi_slave_interface_twbr               (apb_twi_slave_interface_twbr               ),
        .apb_twi_slave_interface_twps               (apb_twi_slave_interface_twps               ) 
    ); 

    bus_interface_unit u_bus_interface_unit(
        .clk                                        (pclk                                       ), 
        .resetn                                     (presetn                                    ), 
        .sda_in                                     (sda_in                                     ), 
        .scl_in                                     (scl_in                                     ), 
        .half_scl                                   (half_scl_generator_half_scl                ), 
        .bus_interface_unit_flop_en                 (flop_en                                    ), 
        .start_en                                   (twi_fsm_start_en                           ), 
        .restart_en                                 (twi_fsm_restart_en                         ), 
        .stop_en                                    (twi_fsm_stop_en                            ),
        .wr_data                                    (apb_twi_slave_interface_wr_data            ), 
        .twdr_wr_en                                 (apb_twi_slave_interface_twdr_wr_en         ), 
        .twcr_wr_en                                 (apb_twi_slave_interface_twcr_wr_en         ), 
        .data_transfer_en                           (twi_fsm_data_transfer_en                   ),
        .ack_transfer_en                            (twi_fsm_ack_transfer_en                    ), 
        .data_transfer_dir                          (twi_fsm_data_transfer_dir                  ), 
        .ack_transfer_dir                           (twi_fsm_ack_transfer_dir                   ),
        .twea                                       (apb_twi_slave_interface_twea               ),
        .twint                                      (apb_twi_slave_interface_twint              ),
        .sla_sent                                   (twi_fsm_sla_sent                           ), 
        .master_mode                                (twi_fsm_master_mode                        ),

        .bus_interface_unit_bus_busy                (bus_interface_unit_bus_busy                ), 
        .bus_interface_unit_start_complete          (bus_interface_unit_start_complete          ), 
        .bus_interface_unit_stop_complete           (bus_interface_unit_stop_complete           ), 
        .bus_interface_unit_arbitration_lost        (bus_interface_unit_arbitration_lost        ), 
        .bus_interface_unit_twdr_rx_q               (bus_interface_unit_twdr_rx_q               ),
        .bus_interface_unit_byte_transfer_complete  (bus_interface_unit_byte_transfer_complete  ), 
        .bus_interface_unit_ack_transfer_complete   (bus_interface_unit_ack_transfer_complete   ), 
        .bus_interface_unit_write                   (bus_interface_unit_write                   ),
        .bus_interface_unit_ack_bit                 (bus_interface_unit_ack_bit                 ),

        .bus_interface_unit_scl_out_en              (scl_out_en                                 ),
        .bus_interface_unit_sda_out_en              (sda_out_en                                 ),
        .bus_interface_unit_scl_out                 (scl_out                                    ),
        .bus_interface_unit_sda_out                 (sda_out                                    )

    ); 


    half_scl_generator u_half_scl_generator(
        .clk                                        (pclk                                       ),    
        .resetn                                     (presetn                                    ),     
        .scl_gen_en                                 (twi_fsm_scl_gen_en                         ),     
        .twps                                       (apb_twi_slave_interface_twps               ),   
        .twbr                                       (apb_twi_slave_interface_twbr               ),   

        .half_scl_generator_half_scl                (half_scl_generator_half_scl                )     
    ); 


    twi_fsm u_twi_fsm(
        .clk             			                (pclk                                       ),
        .resetn               		                (presetn                                    ),
        .twint                 		                (apb_twi_slave_interface_twint              ),
        .twsto                   	                (apb_twi_slave_interface_twsto              ), 
        .twsta                  	                (apb_twi_slave_interface_twsta              ),
        .twen                    	                (apb_twi_slave_interface_twen               ), 
        .bus_busy                	                (bus_interface_unit_bus_busy                ), 
        .start_complete          	                (bus_interface_unit_start_complete          ), 
        .stop_complete                              (bus_interface_unit_stop_complete           ),
        .byte_transfer_complete		                (bus_interface_unit_byte_transfer_complete  ), 
        .ack_transfer_complete   	                (bus_interface_unit_ack_transfer_complete   ), 
        .twi_fsm_flop_en  			                (flop_en                                    ), 
        .write                   	                (bus_interface_unit_write                   ), 
        .arbitration_lost                           (bus_interface_unit_arbitration_lost        ), 

		.twi_fsm_start_en                           (twi_fsm_start_en                           ), 
		.twi_fsm_restart_en                         (twi_fsm_restart_en                         ), 
		.twi_fsm_stop_en                            (twi_fsm_stop_en                            ), 
		.twi_fsm_scl_gen_en                         (twi_fsm_scl_gen_en                         ), 
		.twi_fsm_data_transfer_en                   (twi_fsm_data_transfer_en                   ), 
		.twi_fsm_ack_transfer_en                    (twi_fsm_ack_transfer_en                    ),
		.twi_fsm_data_transfer_dir                  (twi_fsm_data_transfer_dir                  ),
		.twi_fsm_ack_transfer_dir                   (twi_fsm_ack_transfer_dir                   ),
		.twi_fsm_sla_sent                           (twi_fsm_sla_sent                           ), 
        .twi_fsm_twint_set		                    (twi_fsm_twint_set                          ), 
        .twi_fsm_twsta_clr		                    (twi_fsm_twsta_clr                          ), 
        .twi_fsm_twsto_clr		                    (twi_fsm_twsto_clr                          ), 
        .twi_fsm_twen_clr 		                    (twi_fsm_twen_clr                           ), 
        .twi_fsm_master_mode                        (twi_fsm_master_mode                        ), 
        .twi_fsm_status_update                      (twi_fsm_status_update                      )
    ); 

    status_code_generator   u_status_code_generator(
        .sla_sent                                   (twi_fsm_sla_sent), 
        .write                                      (bus_interface_unit_write),
        .ack_bit                                    (bus_interface_unit_ack_bit), 
        .start_en                                   (twi_fsm_start_en), 
        .restart_en                                 (twi_fsm_restart_en), 
        .arbitration_lost                           (bus_interface_unit_arbitration_lost), 

        .status_code_generator_status_value         (status_code_generator_status_value)
    );

    assign flop_en      = 1'b1; 
    assign interrupt    = apb_twi_slave_interface_twint & apb_twi_slave_interface_twie; 

endmodule 
module apb_twi_slave_interface #(
        `include "twi_parameters.sv"
)( 
        input   logic                   	pclk                                    , 
        input   logic                   	presetn                                 , 
        input   logic                  		psel                                    , 
        input   logic                   	penable                                 , 
        input   logic                   	pwrite                                  , 
        input   logic [APB_ADDR_WIDTH-1:0]  paddr                                   , 
        input   logic [APB_DATA_WIDTH-1:0]  pwdata                                  , 


        output  logic [APB_DATA_WIDTH-1:0]  prdata                                  , 
        output  logic                   	pready                                  , 

        input   logic                  		twint_set                               ,
        input   logic                   	twsta_clr                               ,
        input   logic                   	twsto_clr                               ,
        input   logic                   	twen_clr                                , 
		input 	logic 						apb_twi_slave_interface_flop_en         , 
        input   logic [TWDR_WIDTH-1:0]      twdr_rx_q                               ,
        input   logic                       status_update                           , 
        input   logic [TWS_WIDTH-1:0]       status_value                            , 
        
        output  logic	                   	apb_twi_slave_interface_twint           ,
        output  logic	                  	apb_twi_slave_interface_twea            , 
        output  logic   	                apb_twi_slave_interface_twsta           , 
        output  logic	   	   	           	apb_twi_slave_interface_twsto           ,
        output  logic                   	apb_twi_slave_interface_twen            , 
        output  logic                   	apb_twi_slave_interface_twie            ,
        output  logic [TWDR_WIDTH-1:0 ]   	apb_twi_slave_interface_wr_data         , 
        output  logic                   	apb_twi_slave_interface_twdr_wr_en      , 
        output  logic                   	apb_twi_slave_interface_twcr_wr_en      ,         
        output  logic [TWBR_WIDTH-1:0]  	apb_twi_slave_interface_twbr            , 
        output  logic [TWPS_WIDTH-1:0]  	apb_twi_slave_interface_twps    
); 
	/* -------------------------------------------------------------------------- */
	/*                           Module Port Declaration                          */
	/* -------------------------------------------------------------------------- */

    //* apb_slave
    logic 						apb_slave_wr_en     ; 
    logic 						apb_slave_rd_en     ; 
    logic [APB_DATA_WIDTH-1:0] 	apb_slave_wr_data   ; 
    logic [APB_ADDR_WIDTH-1:0] 	apb_slave_addr      ; 
    logic [APB_DATA_WIDTH-1:0] 	apb_slave_rd_data   ; 

	//* twbr
	logic [TWBR_WIDTH-1:0]		twbr_d              ; 
	logic [TWBR_WIDTH-1:0]		twbr_q              ; 

	//* twsr
	logic [TWSR_WIDTH-1:0]		twsr_d              ; 
	logic [TWSR_WIDTH-1:0]		twsr_q              ; 

	//* twar
	logic [TWAR_WIDTH-1:0]		twar_d              ; 
	logic [TWAR_WIDTH-1:0]		twar_q              ; 

	//* twcr
	logic [TWCR_WIDTH-1:0]		twcr_d              ; 
	logic [TWCR_WIDTH-1:0]		twcr_q              ; 

	/* -------------------------------------------------------------------------- */

    /* -------------------------------------------------------------------------- */
    /*                          Internal wire Declaration                         */
    /* -------------------------------------------------------------------------- */
    //* Register Write Enable
    logic                       twbr_wr_en          ; 
    logic                       twar_wr_en          ; 
    logic                       twsr_wr_en          ; 
    logic                       twcr_wr_en          ; 
    logic                       twdr_wr_en          ; 

    //* Internally Used Wire 
    logic [TWCR_WIDTH-1:0]      twcr_d_clr          ; 
    logic                       twcr_set_clr        ; 
    logic                       twwc_clr            ; 
    logic                       twwc_set            ; 
    logic [TWSR_WIDTH-1:0]      twsr_d_status       ; 
    /* -------------------------------------------------------------------------- */



	apb_slave u_apb_slave(
        .pclk               (pclk                               ), 
        .presetn            (presetn                            ), 
        .psel               (psel                               ), 
        .penable            (penable                            ), 
        .pwrite             (pwrite                             ), 
        .paddr              (paddr                              ), 
        .pwdata             (pwdata                             ), 
        .rd_data            (apb_slave_rd_data                  ), 
        .apb_slave_flop_en  (apb_twi_slave_interface_flop_en          ),

        .prdata             (prdata                             ), 
        .wr_en              (apb_slave_wr_en                    ), 
        .rd_en              (apb_slave_rd_en                    ), 
        .pready             (pready                             ), 
        .wr_data            (apb_slave_wr_data                  ), 
        .addr               (apb_slave_addr                     )
    ); 


	dff #(.FLOP_WIDTH(TWBR_WIDTH), .RESET_VALUE(TWBR_RESET_VALUE)) u_twbr(
		.clk                (pclk                               ), 
        .resetn             (presetn                            ), 
        .en                 (apb_twi_slave_interface_flop_en    ),
        .d                  (twbr_d                             ), 

        .q                  (twbr_q                             )
	); 
	
	dff #(.FLOP_WIDTH(TWSR_WIDTH), .RESET_VALUE(TWSR_RESET_VALUE)) u_twsr(
		.clk                (pclk                               ), 
		.resetn             (presetn                            ), 
        .en                 (apb_twi_slave_interface_flop_en    ),
        .d                  (twsr_d                             ), 

        .q                  (twsr_q                             )
	); 

	dff #(.FLOP_WIDTH(TWAR_WIDTH), .RESET_VALUE(TWAR_RESET_VALUE)) u_twar(
		.clk                (pclk                               ), 
		.resetn             (presetn                            ), 
        .en                 (apb_twi_slave_interface_flop_en    ),
        .d                  (twar_d                             ), 

        .q                  (twar_q                             )
	); 

	dff #(.FLOP_WIDTH(TWCR_WIDTH), .RESET_VALUE(TWCR_RESET_VALUE)) u_twcr(
		.clk                (pclk                               ), 
		.resetn             (presetn                            ), 
        .en                 (apb_twi_slave_interface_flop_en    ),
        .d                  (twcr_d                             ), 

        .q                  (twcr_q                             )
    );

    /* -------------------------- Register Write Enable ------------------------- */
    assign twbr_wr_en       = apb_slave_wr_en & apb_slave_addr == TWBR_ADDR; 
    assign twsr_wr_en       = apb_slave_wr_en & apb_slave_addr == TWSR_ADDR; 
    assign twar_wr_en       = apb_slave_wr_en & apb_slave_addr == TWAR_ADDR; 
    assign twcr_wr_en       = apb_slave_wr_en & apb_slave_addr == TWCR_ADDR; 
    assign twdr_wr_en       = apb_slave_wr_en & apb_slave_addr == TWDR_ADDR; 

    /* ------------------------------------------ Register Input Pin and Write Logic ----------------------------------------- */
    assign twbr_d        [TWBR_WIDTH-1:0]    = twbr_wr_en? apb_slave_wr_data[TWBR_WIDTH-1:0]                                     : twbr_q[TWBR_WIDTH-1:0]; 
    assign twsr_d_status [TWSR_WIDTH-1:0]    = status_update ? {status_value, twsr_q[2:0]} 
                                                            : ~twcr_q[TWINT]    ? {6'b111110, twsr_q[1:0]} 
                                                                                : twsr_q[TWSR_WIDTH-1:0];  

    assign twsr_d        [TWSR_WIDTH-1:0]    = twsr_wr_en   ? { twsr_q[TWS_START:TWS_END], twsr_q[2], apb_slave_wr_data[TWPS_START:TWPS_END]}
                                                            : twsr_d_status[TWSR_WIDTH-1:0]; 
    assign twar_d        [TWBR_WIDTH-1:0]    = twar_wr_en?  apb_slave_wr_data[TWAR_WIDTH-1:0]: twar_q[TWAR_WIDTH-1:0];

    assign twcr_d_clr    [TWCR_WIDTH-1:0]    = twcr_set_clr ? {twint_set, twcr_q[6], twcr_q[5], ~twsto_clr & twcr_q[4], (twwc_set ~^ twwc_clr)& twcr_q[3],  twcr_q[2:0]} : twcr_q[TWCR_WIDTH-1:0]; 


    /*assign twcr_d_clr   [TWCR_WIDTH-1:0]    = twcr_set_clr ? twcr_q[TWCR_WIDTH-1:0]   | {              twint_set  , 7'b0000000} 
                                                                                        | {4'b0000  ,    twwc_set   , 3'b000    } 
                                                                                        & {2'b11    ,   ~twsta_clr  , 5'b11111  } 
                                                                                        & {3'b111   ,   ~twsto_clr  , 4'b1111   } 
                                                                                        & {5'b11111 ,   ~twen_clr   , 2'b11     } 
                                                                                        & {4'b1111  ,   ~twwc_clr   , 3'b111    }  : twcr_q[TWCR_WIDTH-1:0];*/

    assign twcr_d     [TWCR_WIDTH-1:0]          = twcr_wr_en? { twcr_q[TWINT] & ~apb_slave_wr_data[TWINT],
                                                                apb_slave_wr_data[TWCR_WIDTH-2:4], 
                                                                twcr_q[TWWC], 
                                                                apb_slave_wr_data[TWEN],
                                                                twcr_q[1],
                                                                apb_slave_wr_data[TWIE]}                                            : twcr_d_clr[TWCR_WIDTH-1:0]; 

    /* --------------------------- Register Read logic -------------------------- */
    always @(*) begin 
        casez(apb_slave_addr) 
            TWBR_ADDR           : apb_slave_rd_data[APB_DATA_WIDTH-1:0] = apb_slave_rd_en? {24'b0, twbr_q   [TWBR_WIDTH-1:0]} : 32'b0; 
            TWSR_ADDR           : apb_slave_rd_data[APB_DATA_WIDTH-1:0] = apb_slave_rd_en? {24'b0, twsr_q   [TWSR_WIDTH-1:0]} : 32'b0;
            TWAR_ADDR           : apb_slave_rd_data[APB_DATA_WIDTH-1:0] = apb_slave_rd_en? {24'b0, twar_q   [TWAR_WIDTH-1:0]} : 32'b0;  
            TWDR_ADDR           : apb_slave_rd_data[APB_DATA_WIDTH-1:0] = apb_slave_rd_en? {24'b0, twdr_rx_q[TWDR_WIDTH-1:0]} : 32'b0;
            TWCR_ADDR           : apb_slave_rd_data[APB_DATA_WIDTH-1:0] = apb_slave_rd_en? {24'b0, twcr_q   [TWCR_WIDTH-1:0]} : 32'b0;  
            default             : apb_slave_rd_data[APB_DATA_WIDTH-1:0] = 32'b0; 
        endcase
    end


    /* ---------------------------------------------------- Internal Logic --------------------------------------------------- */
    assign twcr_set_clr = twint_set | twwc_set | twsto_clr | twwc_clr; 
    assign twwc_clr     = twdr_wr_en &  twcr_q[TWINT]; 
    assign twwc_set     = twdr_wr_en & ~twcr_q[TWINT]; 
    /* -------------------------------------------------------------------------- */
    /*                Output Definition of apb_twi_slave_interface                */
    /* -------------------------------------------------------------------------- */
    assign apb_twi_slave_interface_twint                            = twcr_q[TWINT]; 
    assign apb_twi_slave_interface_twea                             = twcr_q[TWEA]; 
    assign apb_twi_slave_interface_twsta                            = twcr_q[TWSTA]; 
    assign apb_twi_slave_interface_twsto                            = twcr_q[TWSTO]; 
    assign apb_twi_slave_interface_twen                             = twcr_q[TWEN]; 
    assign apb_twi_slave_interface_twie                             = twcr_q[TWIE]; 
    assign apb_twi_slave_interface_wr_data      [TWDR_WIDTH-1:0 ]   = apb_slave_wr_data[TWDR_WIDTH-1:0]; 
    assign apb_twi_slave_interface_twdr_wr_en                       = twdr_wr_en & twcr_q[TWINT]; 
    assign apb_twi_slave_interface_twcr_wr_en                       = twcr_wr_en; 
    assign apb_twi_slave_interface_twbr         [TWBR_WIDTH-1:0]    = twbr_q[TWBR_WIDTH-1:0]; 
    assign apb_twi_slave_interface_twps         [TWPS_WIDTH-1:0]    = twsr_q[TWPS_START:TWPS_END]; 

endmodule 


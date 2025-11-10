module apb_i2c_man_sub_intf #(
    //--------------------------------parameter file-----------------------------------
	`include "params.sv"
) (
    //---------------------------------input ports-------------------------------------
    
	input   logic                               pclk,                              // System clock
	input   logic                               presetn,                           // System reset
	input   logic                               psel,                              // APB chip select signal
	input   logic                               pwrite,                            // APB transfer mode signal. For write transfer this signal is HIGH and vice versa 
	input   logic                               penable,                           // APB enable signal indicating the second cycle of an APB transfer
	input   logic   [ADDR_WIDTH-1:0]            paddr,                             // 32-bit APB address bus
	input   logic   [DATA_WIDTH-1:0]            pwdata,                            // 32-bit APB write data bus
	input   logic                               apb_i2c_man_sub_intf_flop_en,      // Block enable signal for reducing power consumption
	input   logic   [STATUS_REG_WIDTH-1:0]      twsr_load_status,                  // TWI status register load status bus
	input   logic                               twsr_hardware_wr_en,               // TWI status register write enable signal
	input   logic                               twint_hardware_set,                // TWI interrupt bit set signal (from hardware itself)
	input   logic   [REG_DATA_WIDTH-1:0]        twdr_rdata,                        // TWI data register read data bus 
	input   logic                               clear_twsto,                       // Signal for clearing the TWSTO bit
	
	//--------------------------------output ports-------------------------------------
	
	output  logic                               pready,                            // APB subordinate signal for indicating that it is ready for intiating transfer
	output  logic   [DATA_WIDTH-1:0]            prdata,                            // 32-bit APB rdata data bus
	output  logic   [BIT_RATE_CONST_WIDTH-1:0]  apb_i2c_man_sub_intf_twbr_q,       // Bit rate register current value
	output  logic   [SLAVE_ADDR_WIDTH-1:0]      apb_i2c_man_sub_intf_twar_q,       // Address register current value
	output  logic   [REG_DATA_WIDTH-1:0]        apb_i2c_man_sub_intf_twdr_ld_dat,  // Load data for TWI data register
	output  logic                               apb_i2c_man_sub_intf_twdr_ld_en,   // Load enable signal for TWI data register
	output  logic                               apb_i2c_man_sub_intf_twint,        // TWI interrupt bit current value
	output  logic                               apb_i2c_man_sub_intf_twea,         // TWI acknowledegment enable bit current value
	output  logic                               apb_i2c_man_sub_intf_twsta,        // TWI start bit current value
	output  logic                               apb_i2c_man_sub_intf_twsto,        // TWI stop bit current value
	output  logic                               apb_i2c_man_sub_intf_twen,         // TWI enable bit current value
	output  logic   [PRESCALER_WIDTH-1:0]       apb_i2c_man_sub_intf_twps          // TWI prescaler field current value
);

//================================neccessary nets======================================

logic       [ADDR_WIDTH-1:0]        addr;
logic       [DATA_WIDTH-1:0]        wdata;
logic       [DATA_WIDTH-1:0]        rdata;
logic                               wr_en;
logic                               r_en;
logic                               twcr_wr_en;
logic                               twcr_r_en;
logic                               twdr_wr_en;
logic                               twdr_r_en;
logic                               twar_wr_en;
logic                               twar_r_en;
logic                               twsr_software_wr_en;
logic                               twsr_r_en;
logic                               twbr_wr_en;
logic                               twbr_r_en;
logic       [DATA_WIDTH-1:0]        twcr_d;
logic       [DATA_WIDTH-1:0]        twcr_q;
logic       [DATA_WIDTH-1:0]        twar_d;
logic       [DATA_WIDTH-1:0]        twar_q;
logic       [DATA_WIDTH-1:0]        twsr_d;
logic       [DATA_WIDTH-1:0]        twsr_q;
logic       [DATA_WIDTH-1:0]        twbr_d;
logic       [DATA_WIDTH-1:0]        twbr_q;
logic                               twcr_twint_state;
logic                               twcr_twwc_state;
logic                               twcr_twsto_state;
logic       [DATA_WIDTH-1:0]        twsr_load_prescaler;

//=====================================================================================


//==============================module instantiations==================================

// APB subordinate interface 
apb_sub #(
    //-------------------------------parameters----------------------------------------
    .ADDR_WIDTH         (ADDR_WIDTH), 
    .DATA_WIDTH         (DATA_WIDTH)
) u_api_slave_to_reg_bank (
    //---------------------------------inputs------------------------------------------
	.pclk               (pclk),
	.presetn            (presetn),
	.psel               (psel),
	.pwrite             (pwrite),
	.penable            (penable),
	.paddr              (paddr[ADDR_WIDTH-1:0]),
	.pwdata             (pwdata[DATA_WIDTH-1:0]),
	.rdata              (rdata[DATA_WIDTH-1:0]),
	.apb_sub_flop_en    (apb_i2c_man_sub_intf_flop_en),
    //---------------------------------outputs-----------------------------------------
	.pready             (pready),
	.prdata             (prdata[DATA_WIDTH-1:0]),
	.addr               (addr[ADDR_WIDTH-1:0]),
	.wr_en              (wr_en),
	.r_en               (r_en),
	.wdata              (wdata[DATA_WIDTH-1:0])
);

// TWI control register
dff #(
    //---------------------------------parameters--------------------------------------
    .FLOP_WIDTH     (DATA_WIDTH),
    .RESET_VALUE    (32'h0000_0000)
) u_twcr (
    //----------------------------------inputs-----------------------------------------
    .clk            (pclk),
	.resetn         (presetn),
	.en             (apb_i2c_man_sub_intf_flop_en),
	.d              (twcr_d[DATA_WIDTH-1:0]),
    //----------------------------------outputs----------------------------------------
    .q              (twcr_q[DATA_WIDTH-1:0])
);

// TWI status register
dff #(
    //---------------------------------parameters--------------------------------------
    .FLOP_WIDTH     (DATA_WIDTH),
    .RESET_VALUE    (32'h0000_00f8)
) u_twsr (
    //----------------------------------inputs-----------------------------------------
    .clk            (pclk),
	.resetn         (presetn),
	.en             (apb_i2c_man_sub_intf_flop_en),
	.d              (twsr_d[DATA_WIDTH-1:0]),
    //----------------------------------outputs----------------------------------------
    .q              (twsr_q[DATA_WIDTH-1:0])
);

// TWI address register
dff #(
    //---------------------------------parameters--------------------------------------
    .FLOP_WIDTH     (DATA_WIDTH),
    .RESET_VALUE    (32'h0000_00fe)
) u_twar (
    //----------------------------------inputs-----------------------------------------
    .clk            (pclk),
	.resetn         (presetn),
	.en             (apb_i2c_man_sub_intf_flop_en),
	.d              (twar_d[DATA_WIDTH-1:0]),
    //----------------------------------outputs----------------------------------------
    .q              (twar_q[DATA_WIDTH-1:0])
);

// TWI bit rate register
dff #(
    //---------------------------------parameters--------------------------------------
    .FLOP_WIDTH     (DATA_WIDTH),
    .RESET_VALUE    (32'd0)
) u_twbr (
    //----------------------------------inputs-----------------------------------------
    .clk            (pclk),
	.resetn         (presetn),
	.en             (apb_i2c_man_sub_intf_flop_en),
	.d              (twbr_d[DATA_WIDTH-1:0]),
    //----------------------------------outputs----------------------------------------
    .q              (twbr_q[DATA_WIDTH-1:0])
);

//=====================================================================================

//======================================logics=========================================

//---------------write and read enable signals for control register--------------------

assign twcr_wr_en                               =   ((addr[ADDR_WIDTH-1:0] == 32'h0000_0000) & wr_en);
assign twcr_r_en                                =   ((addr[ADDR_WIDTH-1:0] == 32'h0000_0000) & r_en);

assign twdr_wr_en                               =   ((addr[ADDR_WIDTH-1:0] == 32'h0000_0004) & wr_en);
assign twdr_r_en                                =   ((addr[ADDR_WIDTH-1:0] == 32'h0000_0004) & r_en);

assign twsr_software_wr_en                      =   ((addr[ADDR_WIDTH-1:0] == 32'h0000_0008) & wr_en);
assign twsr_r_en                                =   ((addr[ADDR_WIDTH-1:0] == 32'h0000_0008) & r_en);

assign twar_wr_en                               =   ((addr[ADDR_WIDTH-1:0] == 32'h0000_000c) & wr_en);
assign twar_r_en                                =   ((addr[ADDR_WIDTH-1:0] == 32'h0000_000c) & r_en);

assign twbr_wr_en                               =   ((addr[ADDR_WIDTH-1:0] == 32'h0000_0010) & wr_en);
assign twbr_r_en                                =   ((addr[ADDR_WIDTH-1:0] == 32'h0000_0010) & r_en);

//-------------------------------------------------------------------------------------

//-------register bits and fields with both software and hardware write permission-----

assign twcr_twint_state                         =   twint_hardware_set                                  ?   1'b1                                        :   twcr_q[7];   
assign twcr_twwc_state                          =   ((~twcr_q[7]) & (addr == 32'h0000_0004) & pready)   ?   1'b1                                        :   twcr_q[3];
assign twcr_twsto_state                         =   clear_twsto                                         ?   1'b0                                        :   twcr_q[4];
assign twsr_load_prescaler  [DATA_WIDTH-1:0]    =   twsr_software_wr_en                                 ?   {twsr_q[DATA_WIDTH-1:2], wdata[1:0]}        :   twsr_q[DATA_WIDTH-1:0];

//-------------------------------------------------------------------------------------

//---------------------------write logic of the registers------------------------------
 
assign twcr_d               [DATA_WIDTH-1:0]    =   twcr_wr_en              ?   {24'd0, (~wdata[7]), wdata[6:2], 1'b0, wdata[0]}            :   {twcr_q[DATA_WIDTH-1:8], twcr_twint_state, twcr_q[6:5],    
                                                                                                                                                twcr_twsto_state, twcr_twwc_state, twcr_q[2:0]};
assign twsr_d               [DATA_WIDTH-1:0]    =   twsr_hardware_wr_en     ?   {24'd0, twsr_load_status[7:3], twsr_load_prescaler[2:0]}    :   twsr_load_prescaler;
assign twbr_d               [DATA_WIDTH-1:0]    =   twbr_wr_en              ?   {24'd0, wdata[7:0]}                                         :   twbr_q;
assign twar_d               [DATA_WIDTH-1:0]    =   twar_wr_en              ?   {24'd0, wdata[7:0]}                                         :   twar_q;

assign apb_i2c_man_sub_intf_twdr_ld_en          =   twdr_wr_en;
assign apb_i2c_man_sub_intf_twdr_ld_dat         =   apb_i2c_man_sub_intf_twdr_ld_en ? {24'd0, wdata[7:0]} : 32'd0;

//-------------------------------------------------------------------------------------

//----------------------------read logic of the registers------------------------------

always @(*) begin
    casez ({twcr_r_en, twdr_r_en, twsr_r_en, twar_r_en, twbr_r_en})
        5'b1????    :   rdata   [DATA_WIDTH-1:0]            =           twcr_q       [DATA_WIDTH-1:0];
        5'b01???    :   rdata   [DATA_WIDTH-1:0]            =   {24'd0, twdr_rdata   [REG_DATA_WIDTH-1:0]};
        5'b001??    :   rdata   [STATUS_REG_WIDTH-1:0]      =           twsr_q       [STATUS_REG_WIDTH-1:0];
        5'b0001?    :   rdata   [SLAVE_ADDR_WIDTH-1:0]      =           twar_q       [SLAVE_ADDR_WIDTH-1:0];
        5'b00001    :   rdata   [BIT_RATE_CONST_WIDTH-1:0]  =           twbr_q       [BIT_RATE_CONST_WIDTH-1:0];
        5'b00000    :   rdata   [DATA_WIDTH-1:0]            =           32'b0;
        default     :   rdata   [DATA_WIDTH-1:0]            =           'bx;
    endcase
end

//-------------------------------------------------------------------------------------

//--------------------control bits and fileds from twcr and twsr-----------------------

assign apb_i2c_man_sub_intf_twint                               =   twcr_q[7];
assign apb_i2c_man_sub_intf_twea                                =   twcr_q[6];
assign apb_i2c_man_sub_intf_twsta                               =   twcr_q[5];
assign apb_i2c_man_sub_intf_twsto                               =   twcr_q[4];
assign apb_i2c_man_sub_intf_twen                                =   twcr_q[2];
assign apb_i2c_man_sub_intf_twps    [PRESCALER_WIDTH-1:0]       =   twsr_q[PRESCALER_WIDTH-1:0];
assign apb_i2c_man_sub_intf_twbr_q  [BIT_RATE_CONST_WIDTH-1:0]  =   twbr_q[BIT_RATE_CONST_WIDTH-1:0];
assign apb_i2c_man_sub_intf_twar_q  [SLAVE_ADDR_WIDTH-1:0]      =   twar_q[SLAVE_ADDR_WIDTH-1:0];

//-------------------------------------------------------------------------------------

//=====================================================================================

endmodule

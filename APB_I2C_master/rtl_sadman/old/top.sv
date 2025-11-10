module top #(
    //------------------------parameter file----------------------------
    `include "params.sv"
) (
    //-------------------------input ports------------------------------
    
    input   logic                       pclk,               // System clock
	input   logic                       presetn,            // System reset
	input   logic                       psel,               // APB chip select signal
	input   logic                       pwrite,             // APB transfer mode signal. For write transfer this signal is HIGH and vice versa 
	input   logic                       penable,            // APB enable signal indicating the second cycle of an APB transfer
	input   logic   [ADDR_WIDTH-1:0]    paddr,              // 32-bit APB address bus
	input   logic   [DATA_WIDTH-1:0]    pwdata,             // 32-bit APB write data bus
	input   logic                       scl_pad_i,          // SCL input signal from pad
	input   logic                       sda_pad_i,	        // SDA input signal from pad
	
	//-------------------------output ports-----------------------------
	
	output  logic                       pready,             // APB subordinate signal for indicating that it is ready for intiating transfer
	output  logic   [DATA_WIDTH-1:0]    prdata,             // 32-bit APB rdata data bus
	output  logic                       scl_pad_o,          // SCL output signal to pad
	output  logic                       scl_pad_oe,         // SCL output enable signal for the pad
	output  logic                       sda_pad_o,          // SDA output signal to pad
	output  logic                       sda_pad_oe,         // SDA output enable signal for the pad
	output  logic                       interrupt_pad_o     // Interrupt signal for notifying the software
);

//===========================neccessary nets============================

logic   [BIT_RATE_CONST_WIDTH-1:0]  apb_i2c_man_sub_intf_twbr_q;
logic   [SLAVE_ADDR_WIDTH-1:0]      apb_i2c_man_sub_intf_twar_q;
logic   [REG_DATA_WIDTH-1:0]        apb_i2c_man_sub_intf_twdr_ld_dat;
logic                               apb_i2c_man_sub_intf_twdr_ld_en;
logic                               apb_i2c_man_sub_intf_twint;
logic                               apb_i2c_man_sub_intf_twea;
logic                               apb_i2c_man_sub_intf_twsta;
logic                               apb_i2c_man_sub_intf_twsto;
logic                               apb_i2c_man_sub_intf_twen;
logic   [PRESCALER_WIDTH-1:0]       apb_i2c_man_sub_intf_twps;
logic                               mst_ctrl_fsm_gen_sta;
logic                               mst_ctrl_fsm_gen_sto;
logic                               mst_ctrl_fsm_scl_en;
logic   [DRIVER_SEL_WIDTH-1:0]      mst_ctrl_fsm_sda_scl_driver_sel;
logic                               mst_ctrl_fsm_twint_hardware_d;
logic   [STATUS_SEL_WIDTH-1:0]      mst_ctrl_fsm_twsr_d_sel;
logic                               mst_ctrl_fsm_twsr_wr_en;
logic   [MODE_WIDTH-1:0]            mst_ctrl_fsm_twdr_mode;
logic                               mst_ctrl_fsm_clr_bit_cntr;	
logic                               mst_ctrl_fsm_start_flag_set;
logic                               mst_ctrl_fsm_start_flag_clr;
logic                               mst_ctrl_fsm_repeat_flag_set;
logic                               mst_ctrl_fsm_repeat_flag_clr;
logic                               mst_ctrl_fsm_rw_flag_set;
logic                               mst_ctrl_fsm_rw_flag_clr;
logic				                mst_ctrl_fsm_ack_flag_set;
logic                               mst_ctrl_fsm_ack_flag_clr;
logic                               mst_ctrl_fsm_clr_twsto;
logic   [MODE_WIDTH-1:0]            usr_twdr_mode;
logic   [REG_DATA_WIDTH-1:0]        twdr_data;
logic   [BIT_COUNTER_WIDTH-1:0]     bit_cntr_out;
logic                               comp_match_bit_cntr;
logic                               sta_sto_gen_sda;
logic                               sta_sto_gen_scl;                           
logic                               scl_gen_comp_match;
logic   [STATUS_REG_WIDTH-1:0]      twsr_load_status;
logic                               scl_gen_temp_scl;
logic                               scl_en;
logic                               mst_ctrl_fsm_sda_ack_bit;
logic                               start_flag;
logic                               start_flag_temp;
logic                               repeat_flag;
logic                               repeat_flag_temp;
logic			    	            rw_flag;
logic				                rw_flag_temp;
logic				                ack_flag;
logic				                ack_flag_temp;
logic                               start_sel_eq_1;
logic				                slave_addressed_sel_eq;

//======================================================================

//========================module instantiations=========================

apb_i2c_man_sub_intf u_apb_i2c_man_sub_intf (
    //-----------------------------inputs-------------------------------
	.pclk                               (pclk),                             
	.presetn                            (presetn),                          
	.psel                               (psel),                           
	.pwrite                             (pwrite),                         
	.penable                            (penable),                          
	.paddr                              (paddr[ADDR_WIDTH-1:0]),                           
	.pwdata                             (pwdata[DATA_WIDTH-1:0]),                          
	.apb_i2c_man_sub_intf_flop_en       (1'b1),                            
	.twsr_load_status                   (twsr_load_status),                
	.twsr_hardware_wr_en                (mst_ctrl_fsm_twsr_wr_en),        
	.twint_hardware_set                 (mst_ctrl_fsm_twint_hardware_d),   
	.twdr_rdata                         (twdr_data[REG_DATA_WIDTH-1:0]),
	.clear_twsto                        (mst_ctrl_fsm_clr_twsto),                             
	//----------------------------outputs-------------------------------
	.pready                             (pready),                           
	.prdata                             (prdata),   
	.apb_i2c_man_sub_intf_twps          (apb_i2c_man_sub_intf_twps[PRESCALER_WIDTH-1:0]),                               
	.apb_i2c_man_sub_intf_twbr_q        (apb_i2c_man_sub_intf_twbr_q[BIT_RATE_CONST_WIDTH-1:0]),     
	.apb_i2c_man_sub_intf_twar_q        (apb_i2c_man_sub_intf_twar_q[SLAVE_ADDR_WIDTH-1:0]),      
	.apb_i2c_man_sub_intf_twdr_ld_dat   (apb_i2c_man_sub_intf_twdr_ld_dat[REG_DATA_WIDTH-1:0]), 
	.apb_i2c_man_sub_intf_twdr_ld_en    (apb_i2c_man_sub_intf_twdr_ld_en),  
	.apb_i2c_man_sub_intf_twint         (apb_i2c_man_sub_intf_twint),       
	.apb_i2c_man_sub_intf_twea          (apb_i2c_man_sub_intf_twea),        
	.apb_i2c_man_sub_intf_twsta         (apb_i2c_man_sub_intf_twsta),      
	.apb_i2c_man_sub_intf_twsto         (apb_i2c_man_sub_intf_twsto),    
	.apb_i2c_man_sub_intf_twen          (apb_i2c_man_sub_intf_twen)
);

mst_ctrl_fsm u_mst_ctrl_fsm (
    //----------------------------inputs--------------------------------
    .pclk                               (pclk),
    .presetn                            (presetn),
    .twint                              (apb_i2c_man_sub_intf_twint),
    .twen                               (apb_i2c_man_sub_intf_twen),
    .twea                               (apb_i2c_man_sub_intf_twea),
    .twsta                              (apb_i2c_man_sub_intf_twsta),
    .twsto                              (apb_i2c_man_sub_intf_twsto),
    .comp_match_bit_cntr                (comp_match_bit_cntr),
    .rw_flag                            (rw_flag),
    .ack_flag                           (ack_flag),
    .start_flag                         (start_flag),
    .repeat_flag                        (repeat_flag),
    .scl_pad_i                          (scl_pad_i),
    .sda_pad_i                          (sda_pad_i),
    .pos_edge_det                       (edge_det_pos),
    .neg_edge_det                       (edge_det_neg),
    .comp_match                         (scl_gen_comp_match),
    .mst_ctrl_fsm_en                    (1'b1),
    .usr_twdr_mode                      (usr_twdr_mode[MODE_WIDTH-1:0]),
    .arb_lost                           (arb_lost),
    //-----------------------------output-------------------------------
    .mst_ctrl_fsm_sda_pad_oe            (sda_pad_oe),
    .mst_ctrl_fsm_scl_pad_oe            (scl_pad_oe),
    .mst_ctrl_fsm_gen_sta               (mst_ctrl_fsm_gen_sta),
    .mst_ctrl_fsm_gen_sto               (mst_ctrl_fsm_gen_sto),
    .mst_ctrl_fsm_scl_en                (mst_ctrl_fsm_scl_en),
    .mst_ctrl_fsm_sda_scl_driver_sel    (mst_ctrl_fsm_sda_scl_driver_sel[DRIVER_SEL_WIDTH-1:0]),
    .mst_ctrl_fsm_twint_hardware_d      (mst_ctrl_fsm_twint_hardware_d),
    .mst_ctrl_fsm_twsr_d_sel            (mst_ctrl_fsm_twsr_d_sel[STATUS_SEL_WIDTH-1:0]),
    .mst_ctrl_fsm_twsr_wr_en            (mst_ctrl_fsm_twsr_wr_en),
    .mst_ctrl_fsm_twdr_mode             (mst_ctrl_fsm_twdr_mode[MODE_WIDTH-1:0]),
    .mst_ctrl_fsm_clr_bit_cntr          (mst_ctrl_fsm_clr_bit_cntr),
    .mst_ctrl_fsm_clr_twsto             (mst_ctrl_fsm_clr_twsto),
    .mst_ctrl_fsm_sda_ack_bit           (mst_ctrl_fsm_sda_ack_bit),
    .mst_ctrl_fsm_ack_flag_set          (mst_ctrl_fsm_ack_flag_set),
    .mst_ctrl_fsm_ack_flag_clr          (mst_ctrl_fsm_ack_flag_clr),
    .mst_ctrl_fsm_start_flag_set        (mst_ctrl_fsm_start_flag_set),
    .mst_ctrl_fsm_start_flag_clr        (mst_ctrl_fsm_start_flag_clr),
    .mst_ctrl_fsm_rw_flag_set           (mst_ctrl_fsm_rw_flag_set),
    .mst_ctrl_fsm_rw_flag_clr           (mst_ctrl_fsm_rw_flag_clr),
    .mst_ctrl_fsm_repeat_flag_set       (mst_ctrl_fsm_repeat_flag_set),
    .mst_ctrl_fsm_repeat_flag_clr       (mst_ctrl_fsm_repeat_flag_clr) 
);

shift_reg_nbit #(
    //---------------------------parameters-----------------------------
    .WIDTH                              (REG_DATA_WIDTH),
    .RESET_VALUE                        (8'hff)
) u_tx_rx_shift_reg_nbit (
    //-----------------------------inputs-------------------------------
	.clk                                (pclk),
	.resetn                             (presetn),
	.mode                               (mst_ctrl_fsm_twdr_mode[MODE_WIDTH-1:0]),
	.sin                                (sda_pad_i),
	.pin                                (apb_i2c_man_sub_intf_twdr_ld_dat[REG_DATA_WIDTH-1:0]),
	//----------------------------outputs-------------------------------
	.pout                               (twdr_data[REG_DATA_WIDTH-1:0])
);

counter_nbit #(
    //---------------------------parameters-----------------------------
    .WIDTH                              (BIT_COUNTER_WIDTH),
    .RESET_VALUE                        (3'd0),
    .CLEAR_VALUE                        (3'd0)
) u_bit_counter_nbit (
    //-----------------------------inputs-------------------------------
	.clk                                (pclk),
	.resetn                             (presetn),
	.clear                              (mst_ctrl_fsm_clr_bit_cntr),
	.up_down                            (1'b1),
	.enable                             (edge_det_neg),
	.preload                            (1'b0),
	.load_value                         (3'd0),
    //----------------------------outputs-------------------------------	
	.out                                (bit_cntr_out[BIT_COUNTER_WIDTH-1:0])
);

comparator_nbit #(
    //---------------------------parameters-----------------------------
    .WIDTH                              (BIT_COUNTER_WIDTH)
) u_bit_count_comparator (
    //-----------------------------inputs-------------------------------
	.a                                  (3'd7), 
	.b                                  (bit_cntr_out[BIT_COUNTER_WIDTH-1:0]),
    //----------------------------outputs-------------------------------
	.e                                  (comp_match_bit_cntr)
);

edge_det u_edge_det (
    //-----------------------------inputs-------------------------------
    .pclk                               (pclk),
    .presetn                            (presetn),   
    .clk_in                             (scl_pad_i),
    .edge_det_en                        (1'b1),
    //----------------------------outputs-------------------------------
    .edge_det_pos                       (edge_det_pos),
    .edge_det_neg                       (edge_det_neg)
);

sta_sto_gen u_sta_sto_gen (
    //-----------------------------inputs-------------------------------
    .gen_sta                            (mst_ctrl_fsm_gen_sta),
    .gen_sto                            (mst_ctrl_fsm_gen_sto),
    .scl_gen_comp_match                 (scl_gen_comp_match),
    //----------------------------outputs-------------------------------
    .sta_sto_gen_sda                    (sta_sto_gen_sda),
    .sta_sto_gen_scl                    (sta_sto_gen_scl)
);

scl_gen u_scl_gen (
    //----------------------------inputs--------------------------------
	.pclk                               (pclk),
	.presetn                            (presetn),
	.scl_en                             (scl_en),
	.twps                               (apb_i2c_man_sub_intf_twps[PRESCALER_WIDTH-1:0]),
	.twbr                               (apb_i2c_man_sub_intf_twbr_q[BIT_RATE_CONST_WIDTH-1:0]),
	.scl_pad_i                          (scl_pad_i),
	.interrupt_pad_o                    (interrupt_pad_o),
	.scl_gen_flop_en                    (1'b1),
    //---------------------------outputs--------------------------------
	.scl_gen_comp_match                 (scl_gen_comp_match),
	.scl_gen_temp_scl                   (scl_gen_temp_scl)
); 

mux41 u_mux41_scl(
    //----------------------------inputs--------------------------------
	.i0                                 (1'b0),
	.i2                                 (scl_gen_temp_scl),
	.i1                                 (sta_sto_gen_scl),
	.i3                                 (scl_gen_temp_scl),
	.sel                                (mst_ctrl_fsm_sda_scl_driver_sel[DRIVER_SEL_WIDTH-1:0]),
    //---------------------------outputs--------------------------------
	.out                                (scl_pad_o)
);

mux41 u_mux41_sda(
    //----------------------------inputs--------------------------------
	.i0                                 (1'b0),
	.i2                                 (twdr_data[7]),
	.i1                                 (sta_sto_gen_sda),
	.i3                                 (mst_ctrl_fsm_sda_ack_bit),
	.sel                                (mst_ctrl_fsm_sda_scl_driver_sel[DRIVER_SEL_WIDTH-1:0]),
    //---------------------------outputs--------------------------------
	.out                                (sda_pad_o)
);

mux16_1 #(
    //---------------------------parameters-----------------------------
    .WIDTH                              (STATUS_REG_WIDTH)
) u_mux16_1_twsr_load(
    //----------------------------inputs--------------------------------
	.i0                                 (8'hf8),
	.i1                                 (8'h08),
	.i2                                 (8'h10),
	.i3                                 (8'h18),
	.i4                                 (8'h20),
	.i5                                 (8'h40),
	.i6                                 (8'h48),
	.i7                                 (8'h28),
	.i8                                 (8'h30),
	.i9                                 (8'h50),
	.i10                                (8'h58),
	.i11                                (8'h38),
	.i12                                (8'hf8),
	.i13                                (8'hf8),
	.i14                                (8'hf8),
	.i15                                (8'hf8),
	.sel                                (mst_ctrl_fsm_twsr_d_sel[STATUS_SEL_WIDTH-1:0]),
    //---------------------------outputs--------------------------------
	.out                                (twsr_load_status[STATUS_REG_WIDTH-1:0])
);

dff #(
    //---------------------------parameters-----------------------------
    .FLOP_WIDTH                         (1),
    .RESET_VALUE                        (1'b0)
) u_dff_store_start_flag(
    //-----------------------------inputs-------------------------------
	.clk                                (pclk),
	.resetn                             (presetn),
	.en                                 (1'b1),
	.d                                  (start_flag_temp),
    //-----------------------------outputs------------------------------
	.q                                  (start_flag)
);

dff #(
    //---------------------------parameters-----------------------------
    .FLOP_WIDTH                         (1),
    .RESET_VALUE                        (1'b0)
) u_dff_store_rw_flag(
    //-----------------------------inputs-------------------------------
	.clk                                (pclk),
	.resetn                             (presetn),
	.en                                 (1'b1),
	.d                                  (rw_flag_temp),
    //-----------------------------outputs------------------------------
	.q                                  (rw_flag)
);

dff #(
    //---------------------------parameters-----------------------------
    .FLOP_WIDTH                         (1),
    .RESET_VALUE                        (1'b0)
) u_dff_store_ack_flag(
    //-----------------------------inputs-------------------------------
	.clk                                (pclk),
	.resetn                             (presetn),
	.en                                 (1'b1),
	.d                                  (ack_flag_temp),
    //-----------------------------outputs------------------------------
	.q                                  (ack_flag)
);

dff #(
    //---------------------------parameters-----------------------------
    .FLOP_WIDTH                         (1),
    .RESET_VALUE                        (1'b0)
) u_dff_store_repeat_flag(
    //-----------------------------inputs-------------------------------
	.clk                                (pclk),
	.resetn                             (presetn),
	.en                                 (1'b1),
	.d                                  (repeat_flag_temp),
    //-----------------------------outputs------------------------------
	.q                                  (repeat_flag)
);

//======================================================================

//===============================logics=================================

assign  usr_twdr_mode   [MODE_WIDTH-1:0]    = 	apb_i2c_man_sub_intf_twdr_ld_en     ?   2'b11   :   2'b00;
assign  arb_lost        	                = 	sda_pad_oe & (sda_pad_i ^ sda_pad_o) & sda_pad_o;
assign  interrupt_pad_o 	                =	apb_i2c_man_sub_intf_twint;
assign  scl_en                              =   mst_ctrl_fsm_scl_en & ~interrupt_pad_o;

always @(*) begin
    casez ({mst_ctrl_fsm_start_flag_clr, mst_ctrl_fsm_start_flag_set})
        2'b00:      start_flag_temp         =   start_flag;
        2'b?1:      start_flag_temp         =   1'b1;
        2'b10:      start_flag_temp         =   1'b0;       
        default:    start_flag_temp         =   'bx;
    endcase
end

always @(*) begin
    casez ({mst_ctrl_fsm_repeat_flag_clr, mst_ctrl_fsm_repeat_flag_set})
        2'b00:      repeat_flag_temp        =   repeat_flag;
        2'b?1:      repeat_flag_temp        =   1'b1;
        2'b10:      repeat_flag_temp        =   1'b0;       
        default:    repeat_flag_temp        =   'bx;
    endcase
end

always @(*) begin
    casez ({mst_ctrl_fsm_rw_flag_clr, mst_ctrl_fsm_rw_flag_set})
        2'b00:      rw_flag_temp            =   rw_flag;
        2'b?1:      rw_flag_temp            =   twdr_data[0];
        2'b10:      rw_flag_temp            =   1'b0;       
        default:    rw_flag_temp            =   'bx;
    endcase
end

always @(*) begin
    casez ({mst_ctrl_fsm_ack_flag_clr, mst_ctrl_fsm_ack_flag_set})
        2'b00:      ack_flag_temp           =   ack_flag;
        2'b?1:      ack_flag_temp           =   sda_pad_i;
        2'b10:      ack_flag_temp           =   1'b0;       
        default:    ack_flag_temp           =   'bx;
    endcase
end

//======================================================================

endmodule

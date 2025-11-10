module mst_ctrl_fsm #(
    //--------------------------------parameter file-----------------------------------
    
    `include "params.sv"
) (
    //---------------------------------input ports-------------------------------------
    
    input   logic                           pclk,                               // System clock
    input   logic                           presetn,                            // System reset
    input   logic                           twint,                              // TWI interrupt bit current value
    input   logic                           twen,                               // TWI enable bit current value
    input   logic                           twea,                               // TWI acknowledegment enable bit vurrent value
    input   logic                           twsta,                              // TWI start bit current value
    input   logic                           twsto,                              // TWI stop bit current value
    input   logic                           comp_match_bit_cntr,                // Bit counter comparator output
    input   logic                           rw_flag,                            // Flag indicating if the next operation is read or write
    input   logic                           ack_flag,                           // Flag indicating if the last operation was acknowledged or not
    input   logic                           start_flag,                         // Flag indicating if start condition has been generated or not
    input   logic                           repeat_flag,                        // Flag indicating if start condition has already been generated once or not
    input   logic                           scl_pad_i,                          // SCL input signal from pad
    input   logic                           sda_pad_i,                          // SDA input signal from pad
    input   logic                           pos_edge_det,                       // Signal indicating positive edge of SCL is detected 
    input   logic                           neg_edge_det,                       // Signal indicating negative edge of SCL is detected 
    input   logic                           comp_match,                         // SCL generator internal clock clear signal 
    input   logic                           mst_ctrl_fsm_en,                    // Block enable signal for reducing power consumption
    input   logic   [MODE_WIDTH-1:0]        usr_twdr_mode,                      // Shift register generated from the top module
    input   logic                           arb_lost,                           // Signal indication that the master lost the arbitration
    
    //--------------------------------output ports-------------------------------------
    
    output  logic                           mst_ctrl_fsm_sda_pad_oe,            // SDA output enable signal 
    output  logic                           mst_ctrl_fsm_scl_pad_oe,            // SCl output enable signal
    output  logic                           mst_ctrl_fsm_gen_sta,               // Signal for generating start condition
    output  logic                           mst_ctrl_fsm_gen_sto,               // Signal for generating stop condition
    output  logic                           mst_ctrl_fsm_scl_en,                // Signal for enabling scl generator
    output  logic   [DRIVER_SEL_WIDTH-1:0]  mst_ctrl_fsm_sda_scl_driver_sel,    // Signal for selecting which submodule to drive the SCL SDA bus
    output  logic                           mst_ctrl_fsm_twint_hardware_d,      // Signal for setting the TWINT bit of the TWCR register
    output  logic   [STATUS_SEL_WIDTH:0]    mst_ctrl_fsm_twsr_d_sel,            // Signal for selecting the status value 
    output  logic                           mst_ctrl_fsm_twsr_wr_en,            // Write enable signal for writing status value
    output  logic   [MODE_WIDTH:0]          mst_ctrl_fsm_twdr_mode,             // Shift register mode
    output  logic                           mst_ctrl_fsm_clr_bit_cntr,          // Signal for claring the bit counter
    output  logic                           mst_ctrl_fsm_clr_twsto,             // Signal for clearing the TWSTO bit of the TWCR register
    output  logic                           mst_ctrl_fsm_sda_ack_bit,           // Acknowledgement bit provided by the I2C manager while master receive mode
    output  logic                           mst_ctrl_fsm_ack_flag_set,          // Signal for setting the acknowledgement flag
    output  logic                           mst_ctrl_fsm_ack_flag_clr,          // Signal for clearing the acknowledgement flag
    output  logic                           mst_ctrl_fsm_start_flag_set,        // Signal for setting the start generated flag
    output  logic                           mst_ctrl_fsm_start_flag_clr,        // Signal for clearing the start generated flag
    output  logic                           mst_ctrl_fsm_rw_flag_set,           // Signal for setting the read-write mode flag
    output  logic                           mst_ctrl_fsm_rw_flag_clr,           // Signal for clearing the read_write mode flag
    output  logic                           mst_ctrl_fsm_repeat_flag_set,       // Signal for setting the repeat flag
    output  logic                           mst_ctrl_fsm_repeat_flag_clr        // Signal for clearing the repeat flag
);

//===========================neccessary nets and variables=============================

logic   [STATE_WIDTH_MFSM-1:0]      pstate;
logic   [STATE_WIDTH_MFSM-1:0]      nstate;

//=====================================================================================

//======================================states=========================================

localparam IDLE                             =   0;
localparam START                            =   1;
localparam START_INT_SET                    =   2;
localparam START_WAITING_FOR_INT_RESET      =   3;
localparam WRITE                            =   4;
localparam WRITE_WAITING_FOR_ACK            =   5;
localparam ACK_RECEIVED                     =   6;
localparam NACK_RECEIVED                    =   7;
localparam WAITING_FOR_INT_RESET            =   8;
localparam READ                             =   9;
localparam READ_TRANSMIT_ACK_NACK           =   10;
localparam READ_SET_INT                     =   11;
localparam STOP                             =   12;
localparam STOP_GENERATED                   =   13;
localparam ARBITRATION_LOST                 =   14;

//=====================================================================================

//==============================present state register=================================

dff #(    
    //--------------------------------parameters---------------------------------------
    .FLOP_WIDTH     (STATE_WIDTH_MFSM),
    .RESET_VALUE    (IDLE)
) u_present_state_register (
    //----------------------------------inputs-----------------------------------------
    .clk            (pclk),
    .resetn         (presetn),
    .en             (mst_ctrl_fsm_en),
    .d              (nstate[STATE_WIDTH_MFSM-1:0]),
    //---------------------------------outputs-----------------------------------------
    .q              (pstate[STATE_WIDTH_MFSM-1:0])
);

//=====================================================================================

//=================================next state logic====================================

always @ (*) begin
    casez (pstate)
    
        IDLE: begin
            casez ({(twsta & ~twint & scl_pad_i & sda_pad_i), twen})
                2'b?0       :   nstate[STATE_WIDTH_MFSM-1:0]    =   IDLE;
                2'b01       :   nstate[STATE_WIDTH_MFSM-1:0]    =   IDLE;
                2'b11       :   nstate[STATE_WIDTH_MFSM-1:0]    =   START;    
                default     :   nstate[STATE_WIDTH_MFSM-1:0]    =   'bx;            
            endcase
        end

        START: begin
            casez ({scl_pad_i, twen})
                2'b?0       :   nstate[STATE_WIDTH_MFSM-1:0]    =   IDLE;
                2'b01       :   nstate[STATE_WIDTH_MFSM-1:0]    =   START_INT_SET;
                2'b11       :   nstate[STATE_WIDTH_MFSM-1:0]    =   START;    
                default     :   nstate[STATE_WIDTH_MFSM-1:0]    =   'bx;                  
            endcase
        end

        START_INT_SET:          nstate[STATE_WIDTH_MFSM-1:0]    =   twen    ?   START_WAITING_FOR_INT_RESET : IDLE;

        START_WAITING_FOR_INT_RESET: begin
            casez ({twint, twen})
                2'b?0       :   nstate[STATE_WIDTH_MFSM-1:0]    =   IDLE;
                2'b01       :   nstate[STATE_WIDTH_MFSM-1:0]    =   WRITE;
                2'b11       :   nstate[STATE_WIDTH_MFSM-1:0]    =   START_WAITING_FOR_INT_RESET;    
                default     :   nstate[STATE_WIDTH_MFSM-1:0]    =   'bx;                  
            endcase
        end

        WRITE: begin
            casez ({(comp_match_bit_cntr & neg_edge_det), arb_lost, twen})
                3'b??0      :   nstate[STATE_WIDTH_MFSM-1:0]    =   IDLE;
                3'b?11      :   nstate[STATE_WIDTH_MFSM-1:0]    =   ARBITRATION_LOST;
                3'b001      :   nstate[STATE_WIDTH_MFSM-1:0]    =   WRITE;
                3'b101      :   nstate[STATE_WIDTH_MFSM-1:0]    =   WRITE_WAITING_FOR_ACK;    
                default     :   nstate[STATE_WIDTH_MFSM-1:0]    =   'bx;                  
            endcase
        end

        WRITE_WAITING_FOR_ACK: begin
            casez ({sda_pad_i, neg_edge_det, twen})
                3'b??0      :   nstate[STATE_WIDTH_MFSM-1:0]    =   IDLE;
                3'b?01      :   nstate[STATE_WIDTH_MFSM-1:0]    =   WRITE_WAITING_FOR_ACK;
                3'b011      :   nstate[STATE_WIDTH_MFSM-1:0]    =   ACK_RECEIVED;
                3'b111      :   nstate[STATE_WIDTH_MFSM-1:0]    =   NACK_RECEIVED;    
                default     :   nstate[STATE_WIDTH_MFSM-1:0]    =   'bx;  
            endcase
        end

        ACK_RECEIVED:           nstate[STATE_WIDTH_MFSM-1:0]    =   twen    ?   WAITING_FOR_INT_RESET : IDLE;

        NACK_RECEIVED:          nstate[STATE_WIDTH_MFSM-1:0]    =   twen    ?   WAITING_FOR_INT_RESET : IDLE;
        
        WAITING_FOR_INT_RESET: begin
            casez ({twsta, twsto, ack_flag, rw_flag, twint, twen})
                6'b?????0   :   nstate[STATE_WIDTH_MFSM-1:0]    =   IDLE;
                6'b????11   :   nstate[STATE_WIDTH_MFSM-1:0]    =   WAITING_FOR_INT_RESET;
                6'b00?001   :   nstate[STATE_WIDTH_MFSM-1:0]    =   WRITE;
                6'b01?001   :   nstate[STATE_WIDTH_MFSM-1:0]    =   STOP;
                6'b10?001   :   nstate[STATE_WIDTH_MFSM-1:0]    =   START;
                6'b11?001   :   nstate[STATE_WIDTH_MFSM-1:0]    =   STOP;
                6'b??0101   :   nstate[STATE_WIDTH_MFSM-1:0]    =   READ;
                6'b001101   :   nstate[STATE_WIDTH_MFSM-1:0]    =   READ;
                6'b011101   :   nstate[STATE_WIDTH_MFSM-1:0]    =   STOP;
                6'b101101   :   nstate[STATE_WIDTH_MFSM-1:0]    =   START;
                6'b111101   :   nstate[STATE_WIDTH_MFSM-1:0]    =   STOP;    
                default     :   nstate[STATE_WIDTH_MFSM-1:0]    =   'bx;   
            endcase
        end
        
        READ: begin
            casez ({comp_match_bit_cntr & neg_edge_det, twen})
                2'b?0       :   nstate[STATE_WIDTH_MFSM-1:0]    =   IDLE;
                2'b01       :   nstate[STATE_WIDTH_MFSM-1:0]    =   READ;
                2'b11       :   nstate[STATE_WIDTH_MFSM-1:0]    =   READ_TRANSMIT_ACK_NACK;
                default     :   nstate[STATE_WIDTH_MFSM-1:0]    =   'bx;
            endcase
        end
        
        READ_TRANSMIT_ACK_NACK: begin
            casez ({arb_lost, neg_edge_det, twen})
                3'b??0      :   nstate[STATE_WIDTH_MFSM-1:0]    =   IDLE;
                3'b001      :   nstate[STATE_WIDTH_MFSM-1:0]    =   READ_TRANSMIT_ACK_NACK;
                3'b011      :   nstate[STATE_WIDTH_MFSM-1:0]    =   READ_SET_INT;
                3'b1?1      :   nstate[STATE_WIDTH_MFSM-1:0]    =   ARBITRATION_LOST;
                default     :   nstate[STATE_WIDTH_MFSM-1:0]    =   'bx;
            endcase
        end
        
        READ_SET_INT:           nstate[STATE_WIDTH_MFSM-1:0]    =   twen    ?   WAITING_FOR_INT_RESET   :   IDLE;
        
        STOP:                   nstate[STATE_WIDTH_MFSM-1:0]    =   comp_match  ?   STOP_GENERATED  :   STOP;
        
        STOP_GENERATED:         nstate[STATE_WIDTH_MFSM-1:0]    =   (twsta & twsto)   ? START   :   IDLE;
        
        ARBITRATION_LOST:       nstate[STATE_WIDTH_MFSM-1:0]    =   IDLE;
        
        default:                nstate[STATE_WIDTH_MFSM-1:0]    =   'bx;

    endcase
end

//=====================================================================================

//===================================output logic======================================

assign mst_ctrl_fsm_sda_pad_oe                  =   (pstate == START) | (pstate == WRITE) | (pstate == READ_TRANSMIT_ACK_NACK) | (pstate == STOP) | (pstate == START_INT_SET) | 
                                                    (pstate == START_WAITING_FOR_INT_RESET);
assign mst_ctrl_fsm_scl_pad_oe                  =   ~((pstate == IDLE) | (pstate == STOP_GENERATED)) | (pstate == STOP) | (pstate == READ_SET_INT) | (pstate == WRITE_WAITING_FOR_ACK);
assign mst_ctrl_fsm_gen_sta                     =   (pstate == START);
assign mst_ctrl_fsm_gen_sto                     =   (pstate == STOP);
assign mst_ctrl_fsm_scl_en                      =   (pstate == START) | (pstate == WRITE) | (pstate == WRITE_WAITING_FOR_ACK) | (pstate == READ) | (pstate == READ_TRANSMIT_ACK_NACK) | (pstate == STOP);
assign mst_ctrl_fsm_twint_hardware_d            =   (pstate == START_INT_SET) | (pstate == ACK_RECEIVED) | (pstate == NACK_RECEIVED) | (pstate == READ_SET_INT);
assign mst_ctrl_fsm_twsr_wr_en                  =   (pstate == START_INT_SET) | (pstate == ACK_RECEIVED) | (pstate == NACK_RECEIVED) | (pstate == READ_SET_INT) | (pstate == START) | (pstate == ARBITRATION_LOST) | 
                                                    (pstate == WRITE) | (pstate == READ) | (pstate == STOP);
assign mst_ctrl_fsm_ack_flag_set                =   (pstate == ACK_RECEIVED) | (pstate == NACK_RECEIVED) | (pstate == READ_TRANSMIT_ACK_NACK);
assign mst_ctrl_fsm_ack_flag_clr                =   (pstate == READ) | (pstate == WRITE) | (pstate == STOP);
assign mst_ctrl_fsm_start_flag_clr              =   (pstate == WAITING_FOR_INT_RESET);
assign mst_ctrl_fsm_start_flag_set              =   (pstate == START_INT_SET);
assign mst_ctrl_fsm_repeat_flag_set             =   (pstate == START_WAITING_FOR_INT_RESET);
assign mst_ctrl_fsm_repeat_flag_clr             =   (pstate == START_INT_SET);
assign mst_ctrl_fsm_rw_flag_clr                 =   (pstate == IDLE);
assign mst_ctrl_fsm_clr_twsto                   =   (pstate == STOP_GENERATED);

assign mst_ctrl_fsm_rw_flag_set                 =   (pstate == WRITE_WAITING_FOR_ACK)       ?   start_flag                              :   1'b0;
assign mst_ctrl_fsm_clr_bit_cntr                =   ((pstate == WRITE) | (pstate == READ))  ?   (comp_match_bit_cntr & neg_edge_det)    :   1'b1;
assign mst_ctrl_fsm_sda_ack_bit                 =   (pstate == READ_TRANSMIT_ACK_NACK)      ?   ~twea                                   :   1'b0;

always @(*) begin
    casez ({(pstate == READ_TRANSMIT_ACK_NACK), ((pstate == WRITE) | (pstate == WRITE_WAITING_FOR_ACK) | (pstate == READ)), ((pstate == START) | (pstate == STOP))})
        3'b??1      :   mst_ctrl_fsm_sda_scl_driver_sel[DRIVER_SEL_WIDTH-1:0]   =   2'b01;
        3'b?10      :   mst_ctrl_fsm_sda_scl_driver_sel[DRIVER_SEL_WIDTH-1:0]   =   2'b10;
        3'b000      :   mst_ctrl_fsm_sda_scl_driver_sel[DRIVER_SEL_WIDTH-1:0]   =   2'b00;
        3'b100      :   mst_ctrl_fsm_sda_scl_driver_sel[DRIVER_SEL_WIDTH-1:0]   =   2'b11;
        default     :   mst_ctrl_fsm_sda_scl_driver_sel[DRIVER_SEL_WIDTH-1:0]   =   'bx;
    endcase
end

always @(*) begin
    casez ({(pstate == READ), (pstate == WRITE)})
        2'b00       :   mst_ctrl_fsm_twdr_mode[MODE_WIDTH-1:0]                  =   usr_twdr_mode[MODE_WIDTH-1:0];
        2'b01       :   mst_ctrl_fsm_twdr_mode[MODE_WIDTH-1:0]                  =   neg_edge_det ? 2'b10 : usr_twdr_mode[MODE_WIDTH-1:0];
        2'b10       :   mst_ctrl_fsm_twdr_mode[MODE_WIDTH-1:0]                  =   pos_edge_det ? 2'b10 : usr_twdr_mode[MODE_WIDTH-1:0];
        default     :   mst_ctrl_fsm_twdr_mode[MODE_WIDTH-1:0]                  =   'bx;
    endcase
end

always @ (*) begin
    casez ({(pstate == START), (pstate == READ_SET_INT), (pstate == ACK_RECEIVED), (pstate == NACK_RECEIVED), (pstate == ARBITRATION_LOST), (pstate == START_INT_SET)})
        6'b000001   :   mst_ctrl_fsm_twsr_d_sel                                 =   4'd1;
        6'b000010   :   mst_ctrl_fsm_twsr_d_sel                                 =   4'd11;
        6'b000100   :   mst_ctrl_fsm_twsr_d_sel                                 =   start_flag ? (rw_flag ? 4'd6 : 4'd4) : 4'd8;
        6'b001000   :   mst_ctrl_fsm_twsr_d_sel                                 =   start_flag ? (rw_flag ? 4'd5 : 4'd3) : 4'd7;
        6'b010000   :   mst_ctrl_fsm_twsr_d_sel                                 =   twea ? 4'd9 : 4'd10;
        6'b100000   :   mst_ctrl_fsm_twsr_d_sel                                 =   repeat_flag ? 4'd2 : 4'd0;
        6'b000000   :   mst_ctrl_fsm_twsr_d_sel                                 =   4'd0;
        default     :   mst_ctrl_fsm_twsr_d_sel                                 =   'bx;
    endcase
end

//=====================================================================================

endmodule


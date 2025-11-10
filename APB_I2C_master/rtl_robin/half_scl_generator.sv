/***************************************************************************************************************************
File        : quarter_scl_generator.sv
⁡⁢⁣⁢Author      : Mahmadul Hassan Robin⁡
⁡⁢⁢⁢Designation : Trainee Engineer⁡⁡
⁡⁢⁣⁣Company     : Ulkasemi Pvt Ltd⁡
⁡⁣⁣⁢Module      : quarter_scl_generator

⁡⁣⁢⁣𝗗𝗲𝘀𝗰𝗿𝗶𝗽𝘁𝗶𝗼𝗻:⁡⁡
This module implements a half-clock (q_scl) generator for controlling the timing of the TWI communication protocol.
It generates a half-clock signal that is synchronized with the main clock (clk).

⁡⁣⁢⁣𝗙𝘂𝗻𝗰𝘁𝗶𝗼𝗻al Description:
Formula for SCL is given as f_scl = f_clk/(16 + 2 * twbr * 4^twps). And this can be written as below table. 
            +----------------------------------------------------------------------------------+   
⁡            |                        Formula for SCL Generation                                |
            +------+----------------+-------------+---------------------+----------------------+
            | twps |     divider    |  simplified | Using Logical Shift |     Final formula    |
            +======+================+=============+=====================+======================+
            |   0  | twbr * 2 * 4^0 |   2 * twbr  |      twbr << 1      | twbr << 2 * twps + 1 |
            +------+----------------+-------------+---------------------+                      |
            |   1  | twbr * 2 * 4^1 |   8 * twbr  |      twbr << 3      |                      |
            +------+----------------+-------------+---------------------+                      |
            |   2  | twbr * 2 * 4^2 |  32 * twbr  |      twbr << 5      |                      |
            +------+----------------+-------------+---------------------+                      |
            |   3  | twbr * 2 * 4^3 | 128 * twbr  |      twbr << 7      |                      |
            +------+----------------+-------------+---------------------+----------------------+ 

For generating SCL/2 below table is used for different twps value. 
            +-----------------------------------------------------+
            |             Formula For SCL/2 Generation            |
            +======+=================+============+===============+
            | twps |     divider     | simplified | Final Formula |
            +------+-----------------+------------+---------------+
            |   0  |  twbr * 4^0     |  1 * twbr  |   twbr << 0   |
            +------+-----------------+------------+---------------+
            |   1  |  twbr * 4^1     |  4 * twbr  |   twbr << 2   |
            +------+-----------------+------------+---------------+
            |   2  |  twbr * 4^2     |  16 * twbr |   twbr << 4   |
            +------+-----------------+------------+---------------+
            |   3  |  twbr * 4^3     | 64 * twbr  |   twbr << 6   |
            +------+-----------------+------------+---------------+

TODO: 
- ADD counter module from standard macro
*****************************************************************************************************************************/


module  half_scl_generator #(
        `include "twi_parameters.sv"
)(
        input   logic                   clk				, 
        input   logic                   resetn				, 
        input   logic                   scl_gen_en			, 
        input   logic [TWPS_WIDTH-1:0]  twps				, 
        input   logic [TWBR_WIDTH-1:0]  twbr			        , 

        output  logic                   half_scl_generator_half_scl     
); 


  /* ----------------------------------------------------------------------------------------------------------------------- */
  /*                                                     Port Declaration                                                    */
  /* ----------------------------------------------------------------------------------------------------------------------- */

  //* scl_gen_counters
  logic                     half_scl_gen_counter_clr   	; 
  logic                     half_scl_gen_counter_inc   	; 
  logic [2*TWBR_WIDTH-1:0]  half_scl_gen_counter_count	; 
  logic [TWPS_WIDTH:0]      twps_doubled                ; 
  logic [2*TWBR_WIDTH-1:0]  twbr_scaled                 ; 

  //* Internal wire
  logic [2*TWBR_WIDTH-1:0]  divisor               	;
/* ----------------------------------------------------------------------------------------------------------------------- */

  counter #(.COUNTER_WIDTH(2*TWBR_WIDTH), .RESET_VALUE(16'b0)) u_half_scl_gen_counter(
          .clk    (clk                          ), 
          .resetn (resetn                       ), 
          .clear  (half_scl_gen_counter_clr     ), 
          .inc    (half_scl_gen_counter_inc     ), 

          .count  (half_scl_gen_counter_count   )
  );
  assign twps_doubled                   [TWPS_WIDTH:0]          = twps[TWPS_WIDTH-1:0] << 1; 
  assign twbr_scaled                    [2*TWBR_WIDTH-1:0]      = twbr[TWBR_WIDTH-1:0] << twps_doubled[TWPS_WIDTH:0];  
  assign divisor                        [2*TWBR_WIDTH-1:0]      = 16'd8 + twbr_scaled[2*TWBR_WIDTH-1:0]; 
  assign half_scl_gen_counter_clr                               = half_scl_gen_counter_count [2*TWBR_WIDTH-1:0]  == divisor [2*TWBR_WIDTH-1:0] ; 
  assign half_scl_gen_counter_inc                               = scl_gen_en; 

  /* ----------------------------------------------- Module Output Definition ---------------------------------------------- */
  assign half_scl_generator_half_scl 	= half_scl_gen_counter_clr; 
endmodule 
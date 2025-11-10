module arbitration_check(
        input   logic   clk                                 , 
        input   logic   resetn                              , 
        input   logic   scl_rise_edge                       ,
        input   logic   master_mode                         , 
        input   logic   data_transfer_dir                   , 
        input   logic   ack_transfer_dir                    ,  
        input   logic   sda_in                              , 
        input   logic   sda_out                             , 
        input   logic   arbitration_check_flop_en           , 

        output  logic   arbitration_check_arbitration_lost
); 

    logic   arbitration_check_flop_d    ; 
    logic   arbitration_check_flop_q    ; 

    dff #(.FLOP_WIDTH(1), .RESET_VALUE(1'b0)) u_arbitration_check_flop(
        .clk    (clk                        ), 
        .resetn (resetn                     ), 
        .en     (arbitration_check_flop_en  ), 
        .d      (arbitration_check_flop_d   ),

        .q      (arbitration_check_flop_q   )
    ); 

    assign arbitration_check_flop_d             = (master_mode & scl_rise_edge & (data_transfer_dir | ack_transfer_dir)) ? sda_in != sda_out : 1'b0; 
    assign arbitration_check_arbitration_lost   = arbitration_check_flop_q; 

endmodule
    
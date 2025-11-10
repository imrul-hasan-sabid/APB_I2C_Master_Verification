module  bus_busy_detector(
        input   logic   clk                         , 
        input   logic   resetn                      , 
        input   logic   start_detected              , 
        input   logic   stop_detected               , 
        input   logic   bus_busy_detector_flop_en   ,
        //@todo what happens when stop_start
        output  logic   bus_busy_detector_bus_busy
); 

    logic   bus_busy_flop_d; 
    logic   bus_busy_flop_q; 

    dff #(.FLOP_WIDTH(1), .RESET_VALUE(1'b0)) u_bus_busy_flop(
        .clk    (clk                        ), 
        .resetn (resetn                     ), 
        .en     (bus_busy_detector_flop_en  ), 
        .d      (bus_busy_flop_d            ), 

        .q      (bus_busy_flop_q            )
    ); 


    always @(*) begin 
        casez({start_detected, stop_detected})
            2'b00   : bus_busy_flop_d   = bus_busy_flop_q; 
            2'b01   : bus_busy_flop_d   = 1'b0; 
            2'b10   : bus_busy_flop_d   = 1'b1; 
            default : bus_busy_flop_d   = 1'bx; 
        endcase
    end  
    
    assign bus_busy_detector_bus_busy   = bus_busy_flop_q; 
endmodule 
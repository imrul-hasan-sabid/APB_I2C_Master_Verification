module edge_detector(
    input   logic   clk                     , 
    input   logic   resetn                  ,
    input   logic   signal_in               , 
    input   logic   edge_detector_flop_en   ,

    output  logic   edge_detector_rise_edge , 
    output  logic   edge_detector_fall_edge
); 

    logic edge_detector_flop_d  ; 
    logic edge_detector_flop_q  ; 

    dff #(.FLOP_WIDTH(1), .RESET_VALUE(1'b0)) u_edge_detector_flop(
        .clk    (clk                    ), 
        .resetn (resetn                 ), 
        .en     (edge_detector_flop_en  ),
        .d      (edge_detector_flop_d   ), 

        .q      (edge_detector_flop_q   )
    ); 

    assign  edge_detector_flop_d    = signal_in; 

    /* ----------------------------------------------- Module Output Definition ---------------------------------------------- */
    assign  edge_detector_rise_edge = signal_in  & ~edge_detector_flop_q; 
    assign  edge_detector_fall_edge = ~signal_in & edge_detector_flop_q; 
endmodule 
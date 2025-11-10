module  scl_sda_edge_detector(
        input   logic   clk                                 , 
        input   logic   resetn                              , 
        input   logic   scl_in                              , 
        input   logic   sda_in                              , 
        input   logic   scl_sda_edge_detector_flop_en       , 

        output  logic   scl_sda_edge_detector_scl_rise_edge , 
        output  logic   scl_sda_edge_detector_scl_fall_edge , 
        output  logic   scl_sda_edge_detector_sda_rise_edge , 
        output  logic   scl_sda_edge_detector_sda_fall_edge
); 


    edge_detector u_scl_edge_detector(
        .clk                        (clk                                    ), 
        .resetn                     (resetn                                 ), 
        .signal_in                  (scl_in                                 ), 
        .edge_detector_flop_en      (scl_sda_edge_detector_flop_en          ), 

        .edge_detector_rise_edge    (scl_sda_edge_detector_scl_rise_edge    ), 
        .edge_detector_fall_edge    (scl_sda_edge_detector_scl_fall_edge    )
    ); 

    edge_detector u_sda_edge_detector(
        .clk                        (clk                                    ), 
        .resetn                     (resetn                                 ), 
        .signal_in                  (sda_in                                 ), 
        .edge_detector_flop_en      (scl_sda_edge_detector_flop_en          ), 

        .edge_detector_rise_edge    (scl_sda_edge_detector_sda_rise_edge    ), 
        .edge_detector_fall_edge    (scl_sda_edge_detector_sda_fall_edge    )
    ); 
endmodule 
module scl_generator(
        input   logic   clk, 
        input   logic   resetn, 
        input   logic   half_scl, 
        input   logic   twint, 
        input   logic   scl_generator_flop_en, 

        output  logic   scl_generator_scl
); 


    logic scl_generator_flop_d; 
    logic scl_generator_flop_q; 

    dff #(.FLOP_WIDTH(1), .RESET_VALUE(1'b0)) u_scl_generator_flop(
            .clk    (clk                    ), 
            .resetn (resetn                 ), 
            .en     (scl_generator_flop_en  ),
            .d      (scl_generator_flop_d   ), 

            .q      (scl_generator_flop_q	)
    ); 

	assign scl_generator_flop_d	= half_scl ? ~scl_generator_flop_q : scl_generator_flop_q & ~twint; 
	assign scl_generator_scl	= scl_generator_flop_q; 
endmodule
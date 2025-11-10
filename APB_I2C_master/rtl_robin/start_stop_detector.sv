module  start_stop_detector(
        input   logic   sda_rise_edge					,
		input 	logic 	sda_fall_edge					, 
        input   logic   scl								,

		output 	logic 	start_stop_detector_start_detected	, 
		output	logic	start_stop_detector_stop_detected
); 

	assign start_stop_detector_start_detected	= scl & sda_fall_edge; 
	assign start_stop_detector_stop_detected	= scl & sda_rise_edge; 
endmodule 

module dff #( 
	parameter FLOP_WIDTH = 1,
	parameter RESET_VALUE = 1'b0
) (
	input   logic                       clk,
	input   logic                       resetn,
	input   logic                       en, 
	input   logic   [FLOP_WIDTH-1:0]    d,
	output  logic   [FLOP_WIDTH-1:0]    q
);

always @ (posedge clk or negedge resetn) begin
	if (~resetn) begin
		q[FLOP_WIDTH-1:0] <= RESET_VALUE[FLOP_WIDTH-1:0];
	end 
	else begin
		q[FLOP_WIDTH-1:0] <= en ? d[FLOP_WIDTH-1:0] : q[FLOP_WIDTH-1:0];
	end
end

endmodule

//------------------------------------------------------

module tff #(
	parameter RESET_VALUE = 1'b0
) (
	input   logic   clk,
	input   logic   resetn,
	input   logic   t,
	output  logic   q
);

always @ (posedge clk or negedge resetn) begin
	if (~resetn) begin
		q <= RESET_VALUE;
	end 
	else begin
		q <= t^q;
	end
end

endmodule

//------------------------------------------------------

module jkff #(
	parameter RESET_VALUE = 1'b0
) (
	input   logic   clk,
	input   logic   resetn,
	input   logic   j,
	input   logic   k,
	output  logic   q
);

always @ (posedge clk or negedge resetn) begin
	if (~resetn) begin
		q <= RESET_VALUE;
	end else begin
		case ({j, k})
			2'b00: q <= q;
			2'b01: q <= 1'b0;
			2'b10: q <= 1'b1;
			2'b11: q <= ~q;	
		endcase
	end
end

endmodule

//------------------------------------------------------

module full_adder #(
	parameter WIDTH = 4
) (
	input   logic   [WIDTH-1:0] a,
	input   logic   [WIDTH-1:0] b,
	input   logic               carry_in,
	output  logic   [WIDTH-1:0] sum,
	output  logic               carry_out
);

assign {carry_out, sum} = a + b + carry_in;

endmodule

//------------------------------------------------------

module half_adder #(
	parameter WIDTH = 4
) (
	input   logic   [WIDTH-1:0] a,
	input   logic   [WIDTH-1:0] b,
	output  logic   [WIDTH-1:0] sum,
	output  logic               carry_out
);

assign {carry_out, sum} = a + b;

endmodule

//------------------------------------------------------

module shift_reg_nbit #(
	parameter WIDTH = 4,
	parameter RESET_VALUE = 4'd0
) (
	input   logic               clk,
	input   logic               resetn,
	input   logic   [1:0]       mode,
	input   logic               sin,
	input   logic   [WIDTH-1:0] pin,
	output  logic   [WIDTH-1:0] pout
);

always @ (posedge clk or negedge resetn) begin
	if (~resetn) begin
		pout[WIDTH-1:0] <= RESET_VALUE[WIDTH-1:0];
	end
	else begin
		casez (mode)
			2'd0: begin //no change
				pout[WIDTH-1:0] <= pout[WIDTH-1:0];
			end

			2'd1: begin //shift right
				pout[WIDTH-1:0] <= {sin, pout[WIDTH-1:1]};
			end

			2'd2: begin //shift left
				pout[WIDTH-1:0] <= {pout[WIDTH-2:0], sin};
			end

			2'd3: begin //parallel load
				pout[WIDTH-1:0] <= pin[WIDTH-1:0];
			end
		endcase
	end
end

endmodule

//------------------------------------------------------

module priority_encoder (
	input   logic   [3:0]   in,
	output  logic   [1:0]   out
);

always @ (*) begin
	casex (in)
		4'b0001: out = 2'b00;
		4'b001x: out = 2'b01;
		4'b01xx: out = 2'b10;
		4'b1xxx: out = 2'b11;
		default: out = 2'bxx;
	endcase
end

endmodule


//------------------------------------------------------

module mux41 #(
    parameter WIDTH = 1
) (
	input   logic   [WIDTH-1:0] i0,
	input   logic   [WIDTH-1:0] i1,
	input   logic   [WIDTH-1:0] i2,
	input   logic   [WIDTH-1:0] i3,
	input   logic   [1:0]       sel,
	output  logic   [WIDTH-1:0] out
);

always @ (*) begin
	casez (sel) 
		2'd0:       out[WIDTH-1:0]  =   i0[WIDTH-1:0];
		2'd1:       out[WIDTH-1:0]  =   i1[WIDTH-1:0];
		2'd2:       out[WIDTH-1:0]  =   i2[WIDTH-1:0];
		2'd3:       out[WIDTH-1:0]  =   i3[WIDTH-1:0];
		default:    out[WIDTH-1:0]  =   'bx;
	endcase
end

endmodule

//------------------------------------------------------

module mux81 (
	input   logic           i0,
	input   logic           i1,
	input   logic           i2,
	input   logic           i3,
	input   logic           i4,
	input   logic           i5,
	input   logic           i6,
	input   logic           i7,
	input   logic   [2:0]   sel,
	output  logic           out
);

always @ (*) begin
	casez (sel) 
		3'd0:       out =   i0;
		3'd1:       out =   i1;
		3'd2:       out =   i2;
		3'd3:       out =   i3;
		3'd4:       out =   i4;
		3'd5:       out =   i5;
		3'd6:       out =   i6;
		3'd7:       out =   i7; 
		default:    out =   'bx;
	endcase
end

endmodule

//------------------------------------------------------

module mux16_1 #(
    parameter WIDTH = 1
) (
	input   logic   [WIDTH-1:0] i0,
	input   logic   [WIDTH-1:0] i1,
	input   logic   [WIDTH-1:0] i2,
	input   logic   [WIDTH-1:0] i3,
	input   logic   [WIDTH-1:0] i4,
	input   logic   [WIDTH-1:0] i5,
	input   logic   [WIDTH-1:0] i6,
	input   logic   [WIDTH-1:0] i7,
	input   logic   [WIDTH-1:0] i8,
	input   logic   [WIDTH-1:0] i9,
	input   logic   [WIDTH-1:0] i10,
	input   logic   [WIDTH-1:0] i11,
	input   logic   [WIDTH-1:0] i12,
	input   logic   [WIDTH-1:0] i13,
	input   logic   [WIDTH-1:0] i14,
	input   logic   [WIDTH-1:0] i15,
	input   logic   [3:0]       sel,
	output  logic   [WIDTH-1:0] out
);

always @ (*) begin
	casez (sel) 
		4'd0:       out [WIDTH-1:0] =   i0  [WIDTH-1:0];
		4'd1:       out [WIDTH-1:0] =   i1  [WIDTH-1:0];
		4'd2:       out [WIDTH-1:0] =   i2  [WIDTH-1:0];
		4'd3:       out [WIDTH-1:0] =   i3  [WIDTH-1:0];
		4'd4:       out [WIDTH-1:0] =   i4  [WIDTH-1:0];
		4'd5:       out [WIDTH-1:0] =   i5  [WIDTH-1:0];
		4'd6:       out [WIDTH-1:0] =   i6  [WIDTH-1:0];
		4'd7:       out [WIDTH-1:0] =   i7  [WIDTH-1:0]; 
		4'd8:       out [WIDTH-1:0] =   i8  [WIDTH-1:0];
		4'd9:       out [WIDTH-1:0] =   i9  [WIDTH-1:0];
		4'd10:      out [WIDTH-1:0] =   i10 [WIDTH-1:0];
		4'd11:      out [WIDTH-1:0] =   i11 [WIDTH-1:0];
		4'd12:      out [WIDTH-1:0] =   i12 [WIDTH-1:0];
		4'd13:      out [WIDTH-1:0] =   i13 [WIDTH-1:0];
		4'd14:      out [WIDTH-1:0] =   i14 [WIDTH-1:0];
		4'd15:      out [WIDTH-1:0] =   i15 [WIDTH-1:0]; 
		default:    out [WIDTH-1:0] =   'bx;
	endcase
end

endmodule

//------------------------------------------------------

module counter_nbit #(
	parameter WIDTH = 4,
	parameter RESET_VALUE = 4'd0,
	parameter CLEAR_VALUE = 4'd0
) (
	input   logic               clk,
	input   logic               resetn,
	input   logic               clear,
	input   logic               up_down,
	input   logic               enable,
	input   logic               preload,
	input   logic   [WIDTH-1:0] load_value,	
	output  logic   [WIDTH-1:0] out
);

always @ (posedge clk or negedge resetn) begin
	if (~resetn) begin
		out[WIDTH-1:0] <= RESET_VALUE[WIDTH-1:0];
	end else begin
		casez({clear, preload, up_down})
			 3'b000: out[WIDTH-1:0] <= out[WIDTH-1:0] - enable;
			 3'b001: out[WIDTH-1:0] <= out[WIDTH-1:0] + enable;
			 3'b010: out[WIDTH-1:0] <= load_value[WIDTH-1:0];
			 3'b011: out[WIDTH-1:0] <= load_value[WIDTH-1:0];
			 3'b100: out[WIDTH-1:0] <= CLEAR_VALUE[WIDTH-1:0];
			 3'b101: out[WIDTH-1:0] <= CLEAR_VALUE[WIDTH-1:0];
			 3'b110: out[WIDTH-1:0] <= CLEAR_VALUE[WIDTH-1:0];
			 3'b111: out[WIDTH-1:0] <= CLEAR_VALUE[WIDTH-1:0];
			 default: out[WIDTH-1:0] <= 'bx;
		endcase
	end
end

endmodule

//------------------------------------------------------

module comparator_nbit #(
	parameter WIDTH = 3
) (
	input   logic   [WIDTH-1:0] a, 
	input   logic   [WIDTH-1:0] b,
	output  logic               e, 
	output  logic               g,
	output  logic               l 
); 

assign e = (a[WIDTH-1:0] == b[WIDTH-1:0]);
assign l = (a[WIDTH-1:0] < b[WIDTH-1:0]);
assign g = (a[WIDTH-1:0] > b[WIDTH-1:0]);

endmodule

//------------------------------------------------------

module barrel_shifter_nbit #(
	parameter WIDTH = 8
) (
	input   logic   [2:0]       shift_by,
	input   logic               shift_dir, 
	input   logic   [WIDTH-1:0] shifter_in,
	output  logic   [WIDTH-1:0] shifter_out
);

assign shifter_out[WIDTH-1:0] = shift_dir ? (shifter_in[WIDTH-1:0] << shift_by[2:0]) : (shifter_in[WIDTH-1:0] >> shift_by[2:0]);

endmodule

//------------------------------------------------------

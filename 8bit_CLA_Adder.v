/* 8-bit carry look-ahead adder using 10 switches as inputs and 3 7-segment displays as outputs
	Programmer: RedTheTrainerNumber0
	How it works: 8-bit CLA adders with 2 input values implemented by 2 4-bits CLA adders with 2 inputs values.
Using bcd cell to convert one 8-bit binary number to 3 4-bit binary number with maximum of 9 in order to display on 7-segment.
Using register cell to realize one numerical input CLA adder as a regular 2 numerical inputs CLA adder.
	Why I wrote this: To implement a 8-bit CLA adder on Cyclone V FPGA board which only has 10 switches. (I need to demo this to the course that me as a TA.
	Note: I only wrote testbench for an old version that output as an 8-bit binary number instead of 7seg. And that worked.
	Date: 11/15/2023
*/

module cla_adder(
	input [7:0] A,
	input cin, ena,
	output [6:0] hex001, hex010, hex100
);

// internal nets
wire [7:0] A_reg;

wire [7:0] sum;

wire [4:0] hex0, hex1, hex2;


register reg1(
.r_enable(ena),
.data_in(A),
.data_out(A_reg)
);

cla_adder_8bits CLA1(
.X(A), .Y(A_reg),
.cin(cin),
.sum(sum)
);

bcd BCD(
.A(sum), .D(hex2), .C(hex1), .B(hex0)
);

segment7 hexA(.bcd(hex0), .seg(hex001));
segment7 hexB(.bcd(hex1), .seg(hex010));
segment7 hexC(.bcd(hex2), .seg(hex100));

endmodule

module register(
	input r_enable,
	input [7:0] data_in,
	output reg [7:0] data_out
);

always @*
begin
	if(r_enable)
		data_out <= data_in;
end
endmodule

module segment7(
	input [3:0] bcd,
	output reg [6:0] seg
);

always @(bcd)
begin
	case(bcd)
	0 : seg = 7'b1000000;
	1 : seg = 7'b1111001;
	2 : seg = 7'b0100100;
	3 : seg = 7'b0110000;
	4 : seg = 7'b0011001;
	5 : seg = 7'b0010010;
	6 : seg = 7'b0000010;
	7 : seg = 7'b1111000;
	8 : seg = 7'b0000000;
	9 : seg = 7'b0010000;
	default : seg = 7'b1111111;
	endcase
end
endmodule

module bcd(
input  [7:0] A,
output  [3:0] D,C,B
);

wire [3:0] X, Y, Z;

assign B = A % 10;
assign X = A / 10;
assign C = X % 10;
assign Y = X / 10;
assign D = Y % 10;

endmodule 
module cla_adder_8bits(
	input [7:0] X, Y,
	input cin,
	output [7:0] sum
);

// internal nets
wire co_temp;
assign co_temp = (X[3] & Y[3]) | (X[3] & cin) | (Y[3] & cin);
// 


// instantiations
cla_adder_4bits cla_1(
.a(X[3:0]),
.b(Y[3:0]),
.ci(cin),
.s(sum[3:0])
);

cla_adder_4bits cla_2(
.a(X[7:4]),
.b(Y[7:4]),
.ci(co_temp),
.s(sum[7:4])
);

endmodule

module cla_adder_4bits(
 input [3:0]a, b, 
 input ci, 
 output [3:0] s
 );


wire [3:0] p, g;
wire [3:1] c;


and GG0(g[0],a[0],b[0]);
and GG1(g[1],a[1],b[1]);
and GG2(g[2],a[2],b[2]);
and GG3(g[3],a[3],b[3]);

xor PG0(p[0],a[0],b[0]);
xor PG1(p[1],a[1],b[1]);
xor PG2(p[2],a[2],b[2]);
xor PG3(p[3],a[3],b[3]);

assign c[1] = (ci & p[0]) | g[0];
assign c[2] = (ci & p[0] & p[1]) | (g[0] & p[1]) | (g[0] & p[1]) | g[1];
assign c[3] = (ci & p[0] & p[1] & p[2]) | (g[0] & p[1] & p[2]) | (g[1] & p[2]) | (g[1] & p[2]) | g[2];

xor SG0(s[0], ci, p[0]);
xor SG1(s[1], c[1], p[1]);
xor SG2(s[2], c[2], p[2]);
xor SG3(s[3], c[3], p[3]);


endmodule
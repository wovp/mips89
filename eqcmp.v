`timescale 1ns / 1ps
`include "defines2.vh"

module eqcmp(
    input wire [31:0] a,b,
	input wire [5:0] op,
	input wire [4:0] rt,
	output reg y
    );
	
	always@ (*) begin
		case (op)
			`BEQ: y = (a == b) ? 1:0;
			`BGTZ: y = ((a[31] == 0) && (a != 32'b0)) ? 1:0;
			`BLEZ: y = ((a[31] == 1) || (a == 32'b0)) ? 1:0;
			`BNE: y = (a != b) ? 1:0; 
			`REGIMM_INST: case(rt)
                `BLTZ:  y = (a[31] == 1) ? 1:0;
                `BLTZAL:  y = (a[31] == 1) ? 1:0;
                `BGEZ: y = (a[31] == 0) ? 1:0;
                `BGEZAL: y = (a[31] == 0) ? 1:0;
			endcase
			
		default: y = 0;
		endcase
	end
	
endmodule

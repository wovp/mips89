`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/12/12 11:26:03
// Design Name: 
// Module Name: hilo_reg
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module hilo_reg(
	input  wire clk,rst,flushE,
	input wire hilo_div,		//是否取除法结果
	input wire [5:0] funct,
	input wire [1:0] a3,
	input  wire [31:0] hi_i,lo_i,
	input wire [63:0] div_result,
	output wire [31:0] hi_o,lo_o
    );
    reg [31:0]hi, lo;
	always @(negedge clk) begin
		if(rst) begin
			hi <= 0;
			lo <= 0;
		end else if (~flushE) begin
		      if(hilo_div) begin
				hi <= div_result[63:32];
				lo <= div_result[31:0];
			  end
			  else case(a3)
		          2'b01: lo <= lo_i;
		          2'b10: hi <= hi_i;
		          2'b11: begin hi <= hi_i; lo <= lo_i; end
              endcase
		end
	end
	assign hi_o = hi;
	assign lo_o = lo;

endmodule

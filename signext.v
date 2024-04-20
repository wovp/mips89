`timescale 1ns / 1ps
`include "defines2.vh"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/11/02 14:29:33
// Design Name: 
// Module Name: signext
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


module signext(
	input wire[15:0] a,
	input wire[5:0] opD,
	output wire[31:0] y
    );
    reg [31:0] y1;
    always @(*)
        begin
            case(opD)
                `ANDI: y1 <= {{16{1'b0}}, a};
                `XORI: y1 <= {{16{1'b0}}, a};
                `LUI: y1 <= {{16{1'b0}}, a};
                `ORI: y1 <= {{16{1'b0}}, a};
                default: y1 <= {{16{a[15]}},a};
            endcase
        end
        
	assign y = y1;
endmodule

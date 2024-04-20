`timescale 1ns / 1ps
`include "defines2.vh"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/10/23 15:27:24
// Design Name: 
// Module Name: aludec
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


module aludec(
	input wire[5:0] funct,
	input wire[5:0] opD,
	output reg[4:0] alucontrol
    );
	always @(*) begin
		case (opD)
			`R_TYPE: case (funct)
			     // 逻辑指令
			     `AND : alucontrol <= `AND_CONTROL;
			     `OR : alucontrol <= `OR_CONTROL;
			     `XOR : alucontrol <= `XOR_CONTROL;
			     `NOR : alucontrol <= `NOR_CONTROL;
			     
			     // 
			     `SLL : alucontrol <= `SLL_CONTROL;
			     `SLLV : alucontrol <= `SLLV_CONTROL;
			     `SRL : alucontrol <= `SRL_CONTROL;
			     `SRLV : alucontrol <= `SRLV_CONTROL;
			     `SRA : alucontrol <= `SRA_CONTROL;
			     `SRAV : alucontrol <= `SRAV_CONTROL;
			     
			     // 数据移动指令
			     `MFHI: alucontrol <= `MFHI_CONTROL;
			     `MTHI: alucontrol <= `MTHI_CONTROL;
			     `MFLO: alucontrol <= `MFLO_CONTROL;
			     `MTLO: alucontrol <= `MTLO_CONTROL;
			     
			     // 算数指令
			     `ADD: alucontrol <= `ADD_CONTROL;
			     `ADDU: alucontrol <= `ADDU_CONTROL;
			     `SUB: alucontrol <= `SUB_CONTROL;
			     `SUBU: alucontrol <= `SUBU_CONTROL;
			     `SLT: alucontrol <= `SLT_CONTROL;
			     `SLTU: alucontrol <= `SLTU_CONTROL;
			     `MULT: alucontrol <= `MULT_CONTROL;
			     `MULTU: alucontrol <= `MULTU_CONTROL;
			     `DIV: alucontrol <= `DIV_CONTROL;
			     `DIVU: alucontrol <= `DIVU_CONTROL;
			     
			default  alucontrol <= 5'b00000;
			endcase
			`ANDI: alucontrol <= `AND_CONTROL;
			`XORI: alucontrol <= `XOR_CONTROL;
			`LUI: alucontrol <= `LUI_CONTROL;
			`ORI: alucontrol <= `OR_CONTROL;
			// 算数指令
			`ADDI: alucontrol <= `ADD_CONTROL;
			`ADDIU: alucontrol <= `ADDU_CONTROL;
			`SLTI: alucontrol <= `SLT_CONTROL;
			`SLTIU: alucontrol <= `SLTU_CONTROL;
			

			
			default : alucontrol <= 5'b00000;
		endcase
	end
endmodule

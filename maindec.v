`timescale 1ns / 1ps
`include "defines2.vh"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/10/23 15:21:30
// Design Name: 
// Module Name: maindec
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


module maindec(
	input wire[5:0] op,
    input wire[5:0] funct,
    input wire[4:0] rt,
    input wire [31:0] instrD,
	output wire memtoreg,memwrite,
	output wire [1:0] WriteHLD,
	output wire branch,alusrc,
	output wire regdst,regwrite,
	output wire jump, jal, jr, jalr, bal,cp0weD,cp0selD,breakD,syscallD,reserveD,eretD
    );
	reg[18:0] controls;
	assign {regwrite,regdst,alusrc,branch,memwrite,memtoreg,jump,WriteHLD, jal, jr, jalr, bal,cp0weD,cp0selD,breakD,syscallD,reserveD,eretD} = controls;
	always @(*) begin
		case (op)
			`R_TYPE:case(funct)
			     `MFHI: controls <= 19'b1100000000000000000;
			     `MFLO: controls <= 19'b1100000000000000000;
			     `MTHI: controls <= 19'b0000000100000000000;
			     `MTLO: controls <= 19'b0000000010000000000;
			     
			     // 算数指令
			     `MULT: controls <= 19'b0000000110000000000;
			     `MULTU: controls <= 19'b0000000110000000000;
			     `DIV: controls <= 19'b0000000000000000000;
			     `DIVU: controls <= 19'b0000000000000000000;
			     `JR: controls <= 19'b0000000000100000000;
			     `JALR: controls <= 19'b1100000000010000000;
			     `BREAK: controls <= 19'b0000000000000001000;
			     `SYSCALL: controls <= 19'b0000000000000000100;
			 default : controls <= 19'b1100000000000000000;//R-TYRE
			endcase
			`ANDI: controls <= 19'b1010000000000000000;
			`XORI: controls <= 19'b1010000000000000000;
			`LUI: controls <= 19'b1010000000000000000;
			`ORI: controls <= 19'b1010000000000000000;
			`ADDI: controls <= 19'b1010000000000000000;
			`ADDIU: controls <= 19'b1010000000000000000;
			`SLTI: controls <= 19'b1010000000000000000;
			`SLTIU: controls <= 19'b1010000000000000000;
			
			// 分支指令
			`BEQ: controls <= 19'b0001000000000000000; //beq
            `BGTZ: controls <= 19'b0001000000000000000; //bgtz
            `BLEZ: controls <= 19'b0001000000000000000; //blez
            `BNE: controls <= 19'b0001000000000000000; //bne
            `REGIMM_INST: case(rt)
                `BLTZ: controls <= 19'b0001000000000000000; //beq
                `BLTZAL: controls <= 19'b1001000000001000000; //bgtz
                `BGEZ: controls <= 19'b0001000000000000000; //blez
                `BGEZAL: controls <= 19'b1001000000001000000; //bne
                endcase
            // 跳转指令
            `J: controls <= 19'b0000001000000000000; //bne
            `JAL: controls <= 19'b1000000001000000000; //bne
            
            `LB: controls <= 19'b1010010000000000000; //bne
            `LBU:controls <= 19'b1010010000000000000; //bne
            `LH: controls <= 19'b1010010000000000000; //bne
            `LHU:controls <= 19'b1010010000000000000; //bne
            `LW: controls <= 19'b1010010000000000000; //bne
            `SB: controls <= 19'b0010100000000000000; //bne
            `SH: controls <= 19'b0010100000000000000; //bne
            `SW: controls <= 19'b0010100000000000000; //bne
            
            6'b010000: begin
                 if (instrD == 32'b010000_1_0000_0000_0000_0000_000_011000)
                    controls = 19'b0000000000000000001;      //eret
                else if (instrD[25:21]==5'b00100 && instrD[10:3]==0)
                    controls = 19'b0000000000000100000;      //mtc0
                else if (instrD[25:21]==5'b00000 && instrD[10:3]==0)
                    controls = 19'b1000000000000010000;      //mfc0
                else
                    controls = 19'b0000000000000000010;
            end
            
			default:  controls <= 19'b0000000000000000010;//illegal op
		endcase
	end
endmodule

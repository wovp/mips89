`timescale 1ns / 1ps
`include "defines2.vh"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/11/02 14:52:16
// Design Name: 
// Module Name: alu
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


module alu(
	input wire[31:0] a,b,
	input wire[31:0] hi_in, lo_in,
	input wire [4:0] sa,
	input wire[4:0] alucontrolE,
	input wire [5:0] opE,
	input wire [15:0] offsetE,
	output reg[31:0] y,
	output reg[31:0] HiOutE,
	output reg[31:0] LoOutE,
	output reg overflow,
	output wire zero
    );

	wire[31:0] s,bout;
	reg[63:0] hilo_out;
	assign bout = alucontrolE[2] ? ~b : b;
	assign s = a + bout + alucontrolE[2];
	always @(*) begin
		case (alucontrolE)
			`AND_CONTROL: begin y <= a & b; overflow = 0; end
			`OR_CONTROL: begin y <= a | b;overflow = 0; end
			`XOR_CONTROL: begin y <= a ^ b;overflow = 0; end
			`NOR_CONTROL:begin y <= ~(a | b);overflow = 0; end
			`LUI_CONTROL:begin y <= { b[15:0],16'b0 };overflow = 0; end
			`SLL_CONTROL:begin y <= b << sa;overflow = 0; end
			`SLLV_CONTROL:begin y <= b << a[4:0];overflow = 0; end
			`SRL_CONTROL:begin y <= b >> sa;overflow = 0; end
			`SRLV_CONTROL:begin y <= b >> a[4:0];overflow = 0; end
			`SRA_CONTROL:begin y <= ({32{b[31]}} << (6'd32 -{1'b0,sa})) | b >> sa;overflow = 0; end
			`SRAV_CONTROL:begin y <= ({32{b[31]}} << (6'd32 -{1'b0,a[4:0]})) | b >> a[4:0];overflow = 0; end
			//move instr
            `MTHI_CONTROL:begin HiOutE <= a; overflow = 0; end
            `MTLO_CONTROL:begin LoOutE <= a; overflow = 0; end
            `MFHI_CONTROL:begin y <= hi_in;      overflow = 0; end
            `MFLO_CONTROL:begin y <= lo_in[31:0];      overflow = 0; end
            
            // ËãÊýÖ¸Áî
            `ADD_CONTROL: begin y <= a + b; overflow <= (~y[31] & a[31] & b[31]) | (y[31] & ~a[31] & ~b[31]); end   
            `ADDU_CONTROL: y <= a + b;
			`SUB_CONTROL: begin y <= a - b; overflow <= (~y[31] & a[31] & ~b[31]) | (y[31] & ~a[31] & b[31]); end //sub
			`SUBU_CONTROL: y <= a - b;
			`SLT_CONTROL: begin y <= ($signed(a) < $signed(b))?1:0; overflow <= 0; end //slt
            `SLTU_CONTROL: begin y <= a<b? 32'b1:32'b0; overflow <= 0; end //stlu
            `MULT_CONTROL: begin hilo_out <= $signed(a)*$signed(b); overflow <= 0; HiOutE <= hilo_out[63:32]; LoOutE <= hilo_out[31:0];end //mult
            `MULTU_CONTROL: begin hilo_out <= {32'b0,a}*{32'b0,b}; overflow <= 0; HiOutE <= hilo_out[63:32]; LoOutE <= hilo_out[31:0];end //mult
            
            5'b00000: case(opE)
                `LB: begin  y <= a + {{16{offsetE[15]}}, offsetE };  overflow <= 0; end //lb
                `LBU: begin y <= a + {{16{offsetE[15]}}, offsetE };  overflow <= 0; end //lbu
                `LH: begin  y <= a + {{16{offsetE[15]}}, offsetE };  overflow <= 0; end //lh
                `LHU: begin y <= a + {{16{offsetE[15]}}, offsetE };  overflow <= 0; end //lhu
                `LW: begin y <= a + {{16{offsetE[15]}}, offsetE };  overflow <= 0; end //lw
                `SB: begin  y <= a + {{16{offsetE[15]}}, offsetE };  overflow <= 0; end //sb
                `SH: begin  y <= a + {{16{offsetE[15]}}, offsetE };  overflow <= 0; end //sh
                `SW: begin  y <= a + {{16{offsetE[15]}}, offsetE };  overflow <= 0; end //sw
			
			 default : begin y <= 32'b0; overflow = 0; hilo_out = 0;end 
			 endcase
			default :begin y <= 32'b0; overflow = 0; hilo_out = 0;end 
		endcase	
	end
	assign zero = (y == 32'b0);
	
    
		
endmodule

`timescale 1ns / 1ps
`include "defines2.vh"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/11/22 10:23:13
// Design Name: 
// Module Name: hazard
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


module hazard(
	//fetch stage
	output wire stallF,flushF,
	output wire [31:0] newPCF,
	//decode stage
	input wire[4:0] rsD,rtD,
	input wire branchD,jumpD,jalD, jrD, jalrD,
	output wire forwardaD,forwardbD,jrb_l_astall, jrb_l_bstall,
	output wire stallD,flushD,
	//execute stage
	input wire[4:0] rsE,rtE,
	input wire[4:0] writeregE,
	input wire regwriteE,
	input wire memtoregE,
	input wire [4:0] alucontrolE,
	input wire  div_ready,
	output wire[1:0] forwardaE,forwardbE,
	output wire flushE,stallE,
	//mem stage
	input wire[4:0] writeregM,
	input wire regwriteM,
	input wire memtoregM,
	input wire[31:0] excepttype_iM,
	input wire [31:0] epcM,
	output wire flushM,

	//write back stage
	input wire[4:0] writeregW,
	input wire regwriteW,
	output wire flushW
    );

	wire lwstallD,branchstallD,stall_divE,jrstall;


// ---------------------- expt back pc -----------------------
    assign newPCF = (excepttype_iM == 32'h0000_0001)? 32'hbfc00380:
                   (excepttype_iM == 32'h0000_0004)? 32'hbfc00380:
                   (excepttype_iM == 32'h0000_0005)? 32'hbfc00380:
                   (excepttype_iM == 32'h0000_0008)? 32'hbfc00380:
                   (excepttype_iM == 32'h0000_0009)? 32'hbfc00380:
                   (excepttype_iM == 32'h0000_000a)? 32'hbfc00380:
                   (excepttype_iM == 32'h0000_000c)? 32'hbfc00380:
                   (excepttype_iM == 32'h0000_000e)? epcM:
                   32'b0;
	//forwarding sources to D stage (branch equality)
	assign forwardaD = (rsD != 0 & rsD == writeregM & regwriteM);
	assign forwardbD = (rtD != 0 & rtD == writeregM & regwriteM);
	
	 assign forwardaE =  ((rsE != 0) & rsE==writeregM & regwriteM) ? 2'b10:
					   	((rsE != 0) & rsE==writeregW & regwriteW) ? 2'b01: 2'b00;
	assign forwardbE = 	((rtE != 0) & rtE==writeregM & regwriteM) ? 2'b10:
					   	((rtE != 0) & rtE==writeregW & regwriteW) ? 2'b01: 2'b00;

	//stalls
	//除法，暂停流水线
    assign stall_divE = ((alucontrolE == `DIV_CONTROL)|(alucontrolE == `DIVU_CONTROL)) & ~div_ready;
	assign lwstallD = memtoregE & (rtE == rsD | rtE == rtD);
	assign branchstallD = branchD &
				(regwriteE & 
				(writeregE == rsD | writeregE == rtD) |
				memtoregM &
				(writeregM == rsD | writeregM == rtD));
	assign stallF = stallD;
	assign stallD = lwstallD | branchstallD| stall_divE | jrstall;
	assign stallE = stall_divE;
	
	//jr时数据前推也没能写入寄存器，暂停流水线
    assign jrstall = (jrD | jalrD) && regwriteE && (writeregE==rsD);
    //branch/jr时数据前推
    assign jrb_l_astall = (jrD | jalrD |branchD) && ((memtoregE && (writeregE==rsD)) || (memtoregM && (writeregM==rsD)));
	assign jrb_l_bstall = (jrD | jalrD |branchD) && ((memtoregE && (writeregE==rtD)) || (memtoregM && (writeregM==rtD)));

		
// ------------------------- flush -------------------------
    assign flushF=(excepttype_iM!=0);
	assign flushD=(excepttype_iM!=0);
    assign flushE = lwstallD | branchstallD |(excepttype_iM!=0);
	assign flushM=(excepttype_iM!=0);
	assign flushW=(excepttype_iM!=0);
	
	
endmodule

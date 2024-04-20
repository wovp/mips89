`timescale 1ns / 1ps
`include "defines2.vh"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/10/23 15:21:30
// Design Name: 
// Module Name: controller
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


module controller(
	input wire clk,rst,
	//decode stage
	input wire[5:0] opD,functD,
	input wire[4:0] rt,
	input wire[31:0] instrD,
	output wire pcsrcD,branchD,
	input wire equalD,
	output wire jumpD,jalD, jrD, jalrD,balD,breakD,syscallD,reserveD,eretD,
	
	output wire [1:0] WriteHLD,
	
	//execute stage
	input wire flushE,stallE,
	output wire memtoregE,alusrcE,
	output wire regdstE,regwriteE,	
	output wire[4:0] alucontrolE,
	output wire balE,

	//mem stage
	output wire memtoregM,memenM,
				regwriteM,cp0weM,cp0selM,
    input wire flushM,
	//write back stage
	output wire memtoregW,regwriteW,
	input wire flushW

    );
	
	//decode stage
	wire memtoregD,memwriteD,alusrcD,
		regdstD,regwriteD,cp0weD,cp0selD;
	wire[4:0] alucontrolD;

	//execute stage
	wire memwriteE,cp0weE,cp0selE;
	
	wire stall_divE;

	maindec md(
		opD,
		functD,
		rt,
		instrD,
		memtoregD,memwriteD,WriteHLD,
		branchD,alusrcD,
		regdstD,regwriteD,
		jumpD,jalD, jrD, jalrD,balD,cp0weD,cp0selD,breakD,syscallD,reserveD,eretD
		);
	aludec ad(functD,opD, alucontrolD);

	assign pcsrcD = branchD & equalD;
	//pipeline registers
	flopenrc #(13) regE(
		clk,
		rst,
		~stallE,
		flushE,
		{memtoregD,memwriteD,alusrcD,regdstD,regwriteD,alucontrolD, balD,cp0weD,cp0selD},
		{memtoregE,memwriteE,alusrcE,regdstE,regwriteE,alucontrolE, balE,cp0weE,cp0selE}
		);
	floprc #(8) regM(
		clk,rst,flushM,
		{memtoregE,memwriteE,regwriteE,cp0weE,cp0selE},
		{memtoregM,memenM,regwriteM,cp0weM,cp0selM}
		);
	floprc #(8) regW(
		clk,rst,flushW,
		{memtoregM,regwriteM},
		{memtoregW,regwriteW}
		);
endmodule

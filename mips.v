`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/11/07 10:58:03
// Design Name: 
// Module Name: mips
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


module mips(
	input wire clk,rst,
	// F論僇
	output wire[31:0] pcF,
	input wire[31:0] instrF,
	// D論僇
	
	// E論僇
	
	// M論僇
	output wire[3:0] memwriteM,
	output wire memenM,
	output wire[31:0] aluoutM,writedataM,
	input wire[31:0] readdataM ,
	// W論僇
	output wire[31:0] pcW,
	output wire [4:0] writeregW,
	output wire regwriteW,
	output wire [31:0] resultW
    );
    // F
    
	// D論僇
	wire equalD;
	
	wire jumpD, jalD, jrD, jalrD, balD;
	wire breakD,syscallD,reserveD,eretD;
	wire [1:0] WriteHLD;
	wire [5:0] opD,functD;
	wire [4:0] rt;
	wire [31:0] instrD;
	wire pcsrcD;
	
	// E
	wire flushE,stallE;
	wire regdstE,alusrcE,memtoregE,regwriteE;
	
	// M
	wire memtoregM,regwriteM;
	wire cp0weM,cp0selM;
	wire [4:0] alucontrolE;
	wire flushM;
	
	// W
	
    wire memtoregW;
    wire flushW;
    
	
	controller c(
		clk,rst,
		//decode stage
		opD,functD,rt,instrD,
		pcsrcD,branchD,equalD,jumpD,jalD, jrD, jalrD,balD, breakD,syscallD,reserveD,eretD,
		WriteHLD,
		
		//execute stage
		flushE,stallE,
		memtoregE,alusrcE,
		regdstE,regwriteE,	
		alucontrolE,balE,

		//mem stage
		memtoregM,memenM,
		regwriteM,cp0weM,cp0selM,
		flushM,
		//write back stage
		memtoregW,regwriteW,
		flushW
		);
	datapath dp(
		clk,rst,
		//fetch stage
		pcF,
		instrF,
		//decode stage
		pcsrcD,branchD,
		jumpD,jalD, jrD, jalrD, balD,
	    breakD,syscallD,reserveD,eretD,
		WriteHLD,
		equalD,
		opD,functD,rt,instrD,
		//execute stage
		memtoregE,
		alusrcE,regdstE,
		regwriteE,
		alucontrolE,
		balE,
		flushE,stallE,
		//mem stage
		
		memtoregM,
		regwriteM,
		cp0weM,cp0selM,
		aluoutM,writedataM,
		readdataM,memwriteM,flushM,
		//writeback stage
		memtoregW,
		regwriteW,pcW,writeregW,resultW,flushW
	    );
	
endmodule

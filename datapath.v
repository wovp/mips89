`timescale 1ns / 1ps
`include "defines2.vh"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/11/02 15:12:22
// Design Name: 
// Module Name: datapath
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


module datapath(
	input wire clk,rst,
	//fetch stage
	output wire[31:0] pcF,
	input wire[31:0] instrF,
	//decode stage
	input wire pcsrcD,branchD,
	input wire jumpD,jalD, jrD, jalrD,balD,
	input wire breakD,syscallD,reserveD,eretD,
	input wire [1:0] WriteHLD,
	output wire equalD,
	output wire[5:0] opD,functD,
	output wire[4:0] rt,
	output wire [31:0] instrD,
	//execute stage
	input wire memtoregE,
	input wire alusrcE,regdstE,
	input wire regwriteE,
	input wire[4:0] alucontrolE,
	input wire balE,
	output wire flushE,stallE,
	//mem stage
	input wire memtoregM,
	input wire regwriteM,
	input wire cp0weM,cp0selM,
	output wire[31:0] aluout2M,writedata2M,
	input wire[31:0] readdataM,
	output wire [3:0] memwriteM,
	output wire flushM,
	//writeback stage
	input wire memtoregW,
	input wire regwriteW,
	output wire [31:0] pcW,
	output wire [4:0] writeregW,
	output wire [31:0] resultW,
	output wire flushW
    );
	
	//fetch stage
	wire stallF,flushF;
	wire [31:0]pcplus4F,pcplus8F;
	wire [31:0] newPCF;
	wire branchjumpF;
	//D
	wire flushD,branchjumpD;
	wire [31:0] pcnextFD,pcnextbrFD, pcbranchD, pcnext_tmp;
	wire [31:0] pcD;
	wire [31:0] pcplus4D,pcplus8D, pcnext_tmp;
	wire forwardaD,forwardbD,jrb_l_astall,jrb_l_bstall;
	wire [4:0] rsD,rtD,rdD;
	wire stallD; 
	wire [31:0] signimmD,signimmshD;
	wire [31:0] srcaD,srca2D,srcbD,srcb2D,srca3D,srcb3D;
	wire [4:0] saD;
	wire[31:0] hi_oD,lo_oD;
	wire [1:0] WriteHLE;
	wire [15:0] offsetD;
	wire [6:0] exceptD;
	//execute stage
	wire [31:0] pcE,instrE;
	wire [31:0] pcplus4E, pcplus8E;
	wire jumpE,jalE, jrE, jalrE,branchjumpE,overflowE;
	wire [1:0] forwardaE,forwardbE;
	wire [4:0] rsE,rtE,rdE;
	wire [5:0] opE, functE;
	wire [4:0] writeregE, writereg_jalrE,writereg2E;
	wire [31:0] signimmE;
	wire [31:0] srcaE,srca2E,srcbE,srcb2E,srcb3E;
	wire[31:0] hi_oE,lo_oE;
	wire [15:0] offsetE;
	wire[31:0] HiOutE, LoOutE;// alu计算返回的结果
	wire [4:0] saE;
	wire [63:0] div_result;
	wire div_start,div_signed,div_ready;
	wire [31:0] aluoutE, aluout2E;
	wire [6:0] exceptE;
	
	//mem stage
	wire [31:0] aluoutM;
	wire [31:0] branchjumpM;
	wire [31:0] pcM,instrM;
	wire [31:0] rdM;
	wire [31:0] srcbM;
	wire [4:0] writeregM;
	wire [5:0] opM;
	wire[31:0] writedataM;
	wire [31:0] excepttype_iM;
	wire [31:0] epcM;
	wire [31:0] bad_addr_iM;
	wire [31:0] cp0out_dataM;
	wire [31:0] count_oM;
	wire [31:0] compare_oM;
	wire [31:0] status_oM;
	wire [31:0] cause_oM;
	wire [31:0] config_oM;
	wire [31:0] prid_oM;
	wire [31:0] badvaddrM;
	wire timer_int_oM;
	wire [6:0] exceptM;
	wire adelM,adesM;
	
	
	//writeback stage
	wire adelW;
	wire [5:0] opW;
	
	wire [31:0] aluoutW,readdataW, lwresultW,instrW;

	//hazard detection
	hazard h(
		//fetch stage
		stallF,flushF,
		//decode stage
		newPCF,
		rsD,rtD,
		branchD,jumpD,jalD, jrD, jalrD,
		forwardaD,forwardbD,jrb_l_astall,jrb_l_bstall,
		stallD,flushD,
		//execute stage
		rsE,rtE,
		writeregE,
		regwriteE,
		memtoregE,
		alucontrolE,
		div_ready,
		
		forwardaE,forwardbE,
		flushE,stallE,
		//mem stage
		writeregM,
		regwriteM,
		memtoregM,excepttype_iM,epcM,
		flushM,
		//write back stage
		writeregW,
		regwriteW,
		flushW
		);

	//next PC logic (operates in fetch an decode)
	// 判断branch是否存在 且 是否生效
	mux2 #(32) pcbrmux(pcplus4F,pcbranchD,pcsrcD,pcnextbrFD);
	
	// 判断是不是跳转立即数指令
	mux2 #(32) pcmux(pcnextbrFD,
		{pcplus4D[31:28],instrD[25:0],2'b00},
		jumpD | jalD ,pcnext_tmp);
	// 判断跳转寄存器指令
	mux2 #(32) pcjrmux(pcnext_tmp,srca2D,jrD | jalrD,pcnextFD);
	
    
	//regfile (operates in decode and writeback)
	regfile rf(clk,regwriteW,rsD,rtD,writeregW,resultW,srcaD,srcbD);
	// hilo_reg
    hilo_reg hir(clk, rst, flushE,div_ready,instrD[5:0], WriteHLE,HiOutE,LoOutE,div_result, hi_oD,lo_oD);
	//fetch stage logic
	pc #(32) pcreg(clk,rst,~stallF,flushF,pcnextFD,newPCF,pcF);
	
	// pc正常递增
	adder pcadd1(pcF,32'b100,pcplus4F);
	
	// branch 跳转增加
	adder pcadd2(pcplus4D,signimmshD,pcbranchD);
	//计算JAL/JALR指令需要的PC值,GPR[31] = PC+8
	adder pcadd3(pcF,32'b1000,pcplus8F);
	
	
	//decode stage
	/* ---------------------------- FD流水线寄存器 ---------------------------- */
	// flushF 是 F到D段的寄存器
	flopenrc #(32) r1D(clk,rst,~stallD,flushD,pcplus4F,pcplus4D);
	flopenrc #(32) r2D(clk,rst,~stallD,flushD,instrF,instrD);
	flopenrc #(32) r4D(clk,rst,~stallD,flushD,pcplus8F,pcplus8D);
	flopenrc #(32) r5D(clk,rst,~stallD,flushD,pcF,pcD);
	flopenrc #(1) r6D(clk,rst,~stallD,flushD,branchjumpF,branchjumpD);
	
	signext se(instrD[15:0],instrD[31:26],signimmD);
	sl2 immsh(signimmD,signimmshD);
	//是否是跳转指令
	assign branchjumpF =branchD | jumpD | jalD | jrD | jalrD;
	// --------------------- 解决控制冒险与数据冒险 ---------------------
	
	mux2 #(32) forwardamux(srcaD,aluoutM,forwardaD,srca2D);
	mux2 #(32) forwardbmux(srcbD,aluoutM,forwardbD,srcb2D);
	
	//提前判断branch指令可能需要数据前推
	mux2 #(32) forwardbjrb_lamux(srca2D,readdataM,jrb_l_astall,srca3D);
	mux2 #(32) forwardbjrb_lbmux(srcb2D,readdataM,jrb_l_bstall,srcb3D);
	//提前判断branch指令的跳转情况以避免控制冒险
    eqcmp comp(srca3D,srcb3D,opD, rtD,equalD);
    
	assign opD = instrD[31:26];
	assign functD = instrD[5:0];
	assign saD = instrD[10:6];
	assign rsD = instrD[25:21];
	assign rtD = instrD[20:16];
	assign rt = instrD[20:16];
	assign rdD = instrD[15:11];
	assign offsetD = instrD[15:0];
	
	//异常采集
	assign exceptD[3:0] = {reserveD,breakD,syscallD,eretD};
	
    
	//execute stage
	// flushE 是 D到E阶段的寄存器
	flopenrc #(32) r1E(clk,rst,~stallE,flushE,srcaD,srcaE);
	flopenrc #(32) r2E(clk,rst,~stallE,flushE,srcbD,srcbE);
	flopenrc #(32) r3E(clk,rst,~stallE,flushE,signimmD,signimmE);
	flopenrc #(5) r4E(clk,rst,~stallE,flushE,rsD,rsE);
	flopenrc #(5) r5E(clk,rst,~stallE,flushE,rtD,rtE);
	flopenrc #(5) r6E(clk,rst,~stallE,flushE,rdD,rdE);
	flopenrc #(5) r7E(clk,rst,~stallE,flushE,saD,saE);
	flopenrc #(32) r8E(clk,rst,~stallE,flushE,hi_oD,hi_oE);
	flopenrc #(32) r9E(clk,rst,~stallE,flushE,lo_oD,lo_oE);
	flopenrc #(2) r10E(clk,rst,~stallE,flushE,WriteHLD,WriteHLE);
	flopenrc #(6) r11E(clk,rst,~stallE,flushE,opD,opE);
	flopenrc #(6) r12E(clk,rst,~stallE,flushE,functD,functE);
	flopenrc #(1) r13E(clk,rst,~stallE,flushE,jumpD,jumpE);
	flopenrc #(1) r14E(clk,rst,~stallE,flushE,jalD,jalE);
	flopenrc #(1) r15E(clk,rst,~stallE,flushE,jrD,jrE);
	flopenrc #(1) r16E(clk,rst,~stallE,flushE,jalrD,jalrE);
	flopenrc #(32) r17E(clk,rst,~stallE,flushE,pcplus4D,pcplus4E);
	flopenrc #(32) r18E(clk,rst,~stallE,flushE,pcplus8D,pcplus8E);
	flopenrc #(32) r19E(clk,rst,~stallE,flushE,offsetD,offsetE);
	flopenrc #(32) r20E(clk,rst,~stallE,flushE,pcD,pcE);
	flopenrc #(32) r21E(clk,rst,~stallE,flushE,instrD,instrE);
	flopenrc #(32) r22E(clk,rst,~stallE,flushE,rdD,rdE);
	flopenrc #(1) r23E(clk,rst,~stallE,flushE,branchjumpD,branchjumpE);
	flopenrc #(4) 	r24E(clk,rst,~stallE,flushE,exceptD[3:0],exceptE[3:0]);

	mux3 #(32) forwardaemux(srcaE,resultW,aluoutM,forwardaE,srca2E);
	mux3 #(32) forwardbemux(srcbE,resultW,aluoutM,forwardbE,srcb2E);
	// alusrcE 为1 则选择signmmE
	mux2 #(32) srcbmux(srcb2E,signimmE,alusrcE,srcb3E);
    
    //异常采集
	assign exceptE[4]=overflowE;
	
    // 判断jalr 的 写入寄存器
    // 如果是jalr 的话 writeregE会不为0
	assign writeregE = (regwriteE & regdstE)?  rdE:
					   (regwriteE & ~regdstE)? rtE: 
					   5'b00000;

	//JAL指令选择写寄存器，没有指定时默认为31
	assign writereg_jalrE = ((opE == `JAL) && writeregE == 0)? 5'b11111 : writeregE;
	mux2 #(5) wrmux2(writereg_jalrE,5'b11111,jalE | balE ,writereg2E);
	
	// 选择写入寄存器的指令值
	mux2 #(32) wrmux23(aluoutE,pcplus8E,jalE | jalrE | balE,aluout2E);
	//除法运算
	assign div_signed = (alucontrolE == `DIV_CONTROL)? 1'b1: 1'b0;
	assign div_start = ((alucontrolE == `DIV_CONTROL | alucontrolE == `DIVU_CONTROL) & ~div_ready)? 1'b1: 1'b0;
	div div(
		.clk(clk),
		.rst(rst),
		.signed_div_i(div_signed),
		.opdata1_i(srca2E),
		.opdata2_i(srcb3E),
		.start_i(div_start),
		.annul_i(1'b0),
		.result_o(div_result),
		.ready_o(div_ready)
		);
		
	// hi_oD 的o代表从hilo寄存器堆输出的结果
	alu alu(srca2E,srcb3E,hi_oD, lo_oD,saE,alucontrolE,opE, offsetE, aluoutE,HiOutE, LoOutE,overflowE);
	
	mux2 #(5) wrmux(rtE,rdE,regdstE,writeregE);

	//mem stage
	floprc #(32) r1M(clk,rst,flushM,srcb2E,writedataM);
	floprc #(32) r2M(clk,rst,flushM,aluout2E,aluout2M);
	floprc #(5) r3M(clk,rst,flushM,writereg2E,writeregM);
	floprc #(6) r4M(clk,rst,flushM,opE,opM);
	floprc #(32) r5M(clk,rst,flushM,pcE,pcM);
	floprc #(32) r6M(clk,rst,flushM,instrE,instrM);
	floprc #(32) r7M(clk,rst,flushM,rdE,rdM);
	floprc #(32) r8M(clk,rst,flushM,srcb3E,srcbM);
	floprc #(1) r9M(clk,rst,flushM,branchjumpE,branchjumpM);
	floprc #(5) r10M(clk,rst,flushM,exceptE[4:0],exceptM[4:0]);
	
	//选择写入dataram的数据来自ALU or CP0
	mux2 #(32) cp0selmux(aluout2M,cp0out_dataM,cp0selM,aluoutM);
	//为不同的写内存指令(sb、sh、sw)解码写地址类型,即字节、半字、整字的位置
	sw_select swsel(
		.adesM(adesM),
		.addressM(aluout2M),
		.opM(opM),
		.memwriteM(memwriteM)
		);
		//地址例外
	addr_except addrexcept(
		.addrs(aluoutM),
		.opM(opM),
		.adelM(adelM),
		.adesM(adesM)
		); 
		
	//异常采集
	assign exceptM[6:5]={adesM,adelM};
	//将需要写的字节/半字扩展至整字宽
	assign writedata2M = (opM == `SB)? {{writedataM[7:0]},{writedataM[7:0]},{writedataM[7:0]},{writedataM[7:0]}}:
						(opM == `SH)? {{writedataM[15:0]},{writedataM[15:0]}}:
						(opM == `SW)? {{writedataM[31:0]}}:
						writedataM;
    
	//writeback stage
	floprc #(32) r1W(clk,rst,flushW,aluoutM,aluoutW);
	floprc #(32) r2W(clk,rst,flushW,readdataM,readdataW);
	floprc #(6) r3W(clk,rst,flushW,writeregM,writeregW);
	floprc #(6) r4W(clk,rst,flushW,opM,opW);
	floprc #(32) r5W(clk,rst,flushW,pcM,pcW);
	floprc #(32) r6W(clk,rst,flushW,instrM,instrW);
	floprc #(1) r7W(clk,rst,flushW,adelM,adelW);
	
	mux2 #(32) resmux(aluoutW,readdataW,memtoregW,lwresultW);
	//根据访存指令类型将从内存中读取的整字结果截取并扩展
	lw_select lwsel(
		.adelW(adelW),
		.aluoutW(aluoutW),
		.opW(opW),
		.lwresultW(lwresultW),
		.resultW(resultW)
		);
		
    //CP0寄存器
	cp0_reg cp0reg(
		.clk(clk),  
		.rst(rst),
		.we_i(cp0weM),
		.waddr_i(rdM),
		.raddr_i(rdM),
		.data_i(srcbM),
		.int_i(0),
		.excepttype_i(excepttype_iM),
		.current_inst_addr_i(pcM),
		.is_in_delayslot_i(branchjumpM),
		.bad_addr_i(bad_addr_iM),
		.data_o(cp0out_dataM),
		.count_o(count_oM),
		.compare_o(compare_oM),
		.status_o(status_oM),
		.cause_o(cause_oM),
		.epc_o(epcM),
		.config_o(config_oM),
		.prid_o(prid_oM),
		.badvaddr(badvaddrM),
		.timer_int_o(timer_int_oM)
		);
		
		//例外
	exception exception_type(
		.rst(rst),
		.pcM(pcM),
		.exceptM(exceptM),
		.cp0_status(status_oM),
		.cp0_cause(cause_oM),
		.aluoutM(aluoutM),
		.excepttype(excepttype_iM),
		.bad_addr(bad_addr_iM)
		);
		
endmodule

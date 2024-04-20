module mycpu_top(
    input clk,
    input resetn,  //low active
    input [5:0]ext_int,
    //cpu inst sram
    output        inst_sram_en   ,
    output [3 :0] inst_sram_wen  ,
    output [31:0] inst_sram_addr ,
    output [31:0] inst_sram_wdata,
    input  [31:0] inst_sram_rdata,
    //cpu data sram
    output        data_sram_en   ,
    output [3 :0] data_sram_wen  ,
    output [31:0] data_sram_addr ,
    output [31:0] data_sram_wdata,
    input  [31:0] data_sram_rdata,
    
    output [31:0] debug_wb_pc      , 
    output [3:0] debug_wb_rf_wen  , 
    output [4:0] debug_wb_rf_wnum , 
    output [31:0] debug_wb_rf_wdata  
);

	// F �׶�
	wire [31:0] pcF,instrF;
	wire [31:0] pcconvertF;
	wire [31:0] dataadr;
	// D
	
	// E
	
	// M
	wire memenM;
	wire[3:0] memwriteM;
	wire [31:0] aluoutM, writedataM, readdata;
	
	// W
	wire [31:0] pcW;
	wire regwriteW;
	wire [4:0] writeregW;
	wire [31:0] resultW;
	
	wire nocache;
    mips mips(
        .clk(~clk),
        .rst(~resetn),
        // F
        .pcF(pcF),                  
        .instrF(instrF),     
        // D
        
        // E
        
        // M
         .memenM(memenM),
        .memwriteM(memwriteM),
        .aluoutM(aluoutM),
        .writedataM(writedataM),
        .readdataM(readdata),
        // W
        .pcW(pcW),
        .regwriteW(regwriteW),
        .writeregW(writeregW),
        .resultW(resultW)
    );
    mmu mmu0(
		.inst_vaddr(pcF),
    	.inst_paddr(pcconvertF),
  		.data_vaddr(aluoutM),
   		.data_paddr(dataadr),
		.no_dcache(nocache)
		);

    assign inst_sram_en = 1'b1;     //如果有inst_en，就用inst_en
    assign inst_sram_wen = 4'b0;
    assign inst_sram_addr = pcconvertF;
    assign inst_sram_wdata = 32'b0;
    assign instrF = inst_sram_rdata;

    assign data_sram_en = 1'b1;     
    assign data_sram_wen = memwriteM;
    assign data_sram_addr = dataadr;
    assign data_sram_wdata = writedataM;
    assign readdata = data_sram_rdata;

    assign	debug_wb_pc			= pcW;
	assign	debug_wb_rf_wen		= {4{regwriteW}};
	assign	debug_wb_rf_wnum	= writeregW;
	assign	debug_wb_rf_wdata	= resultW;


    //ascii
    instdec instdec(
        .instr(instr)
    );

endmodule
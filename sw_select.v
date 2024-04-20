/*swselect模块
	为不同的写内存指令(sb、sh、sw)解码写地址类型,即字节、半字、整字的位置
*/
`timescale 1ns / 1ps
`include "defines2.vh"

module sw_select(
    input wire adesM, 
    input [31:0] addressM,      //写内存地址,末两位决定写地址
    input [5:0] opM,    //指令类型
    output reg [3:0] memwriteM  //写地址类型
    );

    always@ (*) begin
        if(adesM) 
            memwriteM <= 4'b0000;
        else begin    
            case(opM)
                `SB: begin
                    case(addressM[1:0])
                        2'b11: memwriteM <= 4'b1000;
                        2'b10: memwriteM <= 4'b0100;
                        2'b01: memwriteM <= 4'b0010;
                        2'b00: memwriteM <= 4'b0001;
                        default: memwriteM <= 4'b0000;
                    endcase
                end    
                `SH: begin
                    case(addressM[1:0])
                        2'b00: memwriteM = 4'b0011;
                        2'b10: memwriteM = 4'b1100;
                        default: memwriteM = 4'b0000;
                    endcase
                end
                `SW:
                    memwriteM = 4'b1111;
                default: memwriteM = 4'b0000;       
            endcase
        end
    end
endmodule

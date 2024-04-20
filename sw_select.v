/*swselectģ��
	Ϊ��ͬ��д�ڴ�ָ��(sb��sh��sw)����д��ַ����,���ֽڡ����֡����ֵ�λ��
*/
`timescale 1ns / 1ps
`include "defines2.vh"

module sw_select(
    input wire adesM, 
    input [31:0] addressM,      //д�ڴ��ַ,ĩ��λ����д��ַ
    input [5:0] opM,    //ָ������
    output reg [3:0] memwriteM  //д��ַ����
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

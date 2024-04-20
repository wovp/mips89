/*lwselectģ��
	���ݷô�ָ�����ͽ����ڴ��ж�ȡ�����ֽ����ȡ����չ
*/
`timescale 1ns / 1ps
`include "defines2.vh"

module lw_select(
    input wire adelW,                //LH��LWָ���ַ������
    input wire [31:0] aluoutW,        //ALU������ķô�ָ���ַ
    input [5:0] opW,          //�ô�ָ������
    input [31:0] lwresultW,           //��ȡ�ڴ�����ֽ��(4�ֽ�)
    output reg [31:0] resultW         //��ȡ�ڴ����ʵ���(LB1�ֽ�/LH2�ֽ�)
    );

    always@ (*) begin
        if(~adelW) begin
            case(opW)
                `LB: case(aluoutW[1:0])  //LBָ���ȡ1�ֽڲ���������չ
                    2'b00: resultW = {{24{lwresultW[7]}},lwresultW[7:0]};
                    2'b01: resultW = {{24{lwresultW[15]}},lwresultW[15:8]};
                    2'b10: resultW = {{24{lwresultW[23]}},lwresultW[23:16]};
                    2'b11: resultW = {{24{lwresultW[31]}},lwresultW[31:24]};
                    default: resultW = lwresultW;
                endcase
                `LBU: case(aluoutW[1:0]) 
                    2'b00: resultW = {{24{1'b0}},lwresultW[7:0]};
                    2'b01: resultW = {{24{1'b0}},lwresultW[15:8]};
                    2'b10: resultW = {{24{1'b0}},lwresultW[23:16]};
                    2'b11: resultW = {{24{1'b0}},lwresultW[31:24]};
                    default: resultW = lwresultW;
                endcase
                `LH: case(aluoutW[1:0])  
                    2'b00: resultW = {{16{lwresultW[15]}},lwresultW[15:0]};
                    2'b10: resultW = {{16{lwresultW[31]}},lwresultW[31:16]};
                    default: resultW = lwresultW;  
                endcase
                `LHU:case(aluoutW[1:0])  
                    2'b00: resultW = {{16{1'b0}},lwresultW[15:0]};
                    2'b10: resultW = {{16{1'b0}},lwresultW[31:16]};
                    default: resultW = lwresultW;    
                endcase
                default: resultW = lwresultW;   
            endcase
        end
        else begin
            resultW = 32'b0;
        end
    end
endmodule

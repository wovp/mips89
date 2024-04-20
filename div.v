/*divģ��,֧���з��ź��޷�������,�ο�https://blog.csdn.net/leishangwen/article/details/39155487
    ʱ���߼�,��Ҫ32������,��Ҫ������һ��״̬��:
    DivFree:����ģ�����
    DivByZero:������0
    DivOn:�������������
    DivEnd:�����������
��λʱDIVģ�鴦��DivFree״̬����start_iΪDivStart(1)��annul_iΪ0ʱ������������ʼ��
    �������opdata2_iΪ0������DivByZero״̬���������Ϊ0��Ȼ�����DivEnd״̬��֪ͨEXģ������������õ�����������start_iΪDivStop(0)���������������
    �������DivOn״̬������32��ʱ�����ڵó����������Ȼ�����DivEnd״̬��֪ͨEXģ������������õ������߻�����start_iΪDivStop(0)���������������
DivOnʱ���̷�����:
    ��Ϊ����ָ���ʱ������������̶������Բ����ܴӿ��Գ�����λ��ʼ�����ѡ�񽫱�����һλһλ�����ƹ�����ȥ��;
    dividend��32λ��ʼ��Ϊ��������ÿִ��һ�����̾���������һλ��������ǰλ����д�����λ;
    ��k�ε�����dividend[k-1:0]����õ����м�����dividend[31:k]����ľ��Ǳ������л�û�в�������Ĳ��֣��������ʣ�����;
    dividend[63:32]�Ǳ������������Ǽ������˴�������������div_temp�С�
*/
`timescale 1ns / 1ps

`include "defines2.vh"

module div(
	input wire					clk,
	input wire					rst,
	input wire                  signed_div_i,	//�Ƿ����з��ų���
	input wire[31:0]            opdata1_i,		//������
	input wire[31:0]		   	opdata2_i,		//����
	input wire                  start_i,		//�Ƿ�ʼ��������
	input wire                  annul_i,		//�Ƿ�ȡ����������
	output reg[63:0]            result_o,		//����������
	output reg			        ready_o			//�Ƿ����
);
	wire[32:0] div_temp;		//�洢dividend[63:32]������Ĳ�,���з��ż���,���λΪ
	reg[5:0] cnt;				//��¼���̷���������,�ﵽ32ʱ����
	reg[64:0] dividend;			//{������,��}
	reg[1:0] state;				//״̬����״̬
	reg[31:0] divisor;	 		//����ԭ����������
	reg[31:0] temp_op1;			//������ԭ��
	reg[31:0] temp_op2;			//����ԭ��
	reg[31:0] reg_op1;
	reg[31:0] reg_op2;
	
	assign div_temp = {1'b0,dividend[63:32]} - {1'b0,divisor};

	always @ (posedge clk) begin
		if (rst) begin
			state <= `DivFree;
			ready_o <= `DivResultNotReady;
			result_o <= {`ZeroWord,`ZeroWord};
		end else begin
		  case (state)			
		  	/* --------------------����ģ����У�����ִ�г���-------------------- */
		  	`DivFree:	begin
				/* ---------------׼���ó������㣬�淶������������--------------- */
		  		if(start_i == `DivStart && annul_i == 1'b0) begin
		  			if(opdata2_i == `ZeroWord) begin    //����Ϊ0
		  				state <= `DivByZero;
		  			end else begin
		  				state <= `DivOn;				//״̬�л�Ϊ�������������
		  				cnt <= 6'b000000;				//��ʼ����
		  				/* ----------���������������뻹ԭԭ��---------- */
						if(signed_div_i == 1'b1 && opdata1_i[31] == 1'b1 ) begin	//������Ϊ��
		  					temp_op1 = ~opdata1_i + 1;	//���뻹ԭԭ��
		  				end else begin
		  					temp_op1 = opdata1_i;		//����ԭ��=����
		  				end
		  				if(signed_div_i == 1'b1 && opdata2_i[31] == 1'b1 ) begin	//����Ϊ��
		  					temp_op2 = ~opdata2_i + 1;
		  				end else begin
		  					temp_op2 = opdata2_i;
		  				end
						/* ----------����������������ֵ��ִ�е�һ������---------- */
		  				dividend <= {`ZeroWord,`ZeroWord};
              		dividend[32:1] <= temp_op1;
              		divisor <= temp_op2;
			  		reg_op1 <= opdata1_i;
			  		reg_op2 <= opdata2_i;
             		end
				/* ---------------��δ׼���ó�������--------------- */
				end else begin
					ready_o <= `DivResultNotReady;
					result_o <= {`ZeroWord,`ZeroWord};
				end          	
		  	end
			/* --------------------��һ��������0����ʱȡֵ���޸�״̬-------------------- */
		  	`DivByZero:	begin
				dividend <= {`ZeroWord,`ZeroWord};
				state <= `DivEnd;		 		
		  	end
			/* --------------------�����������ڽ�����-------------------- */
		  	`DivOn:	begin
				/* ---------------��������û��ȡ��--------------- */
		  		if(annul_i == 1'b0) begin
					/* ----------�������㻹û���---------- */
		  			if(cnt != 6'b100000) begin
						if(div_temp[32] == 1'b1) begin				//��ֵΪ��,������
							dividend <= {dividend[63:0] , 1'b0};	//����������,���Ʋ�0
						end else begin								//��ֵΪ��,����
							dividend <= {div_temp[31:0] , dividend[31:0] , 1'b1};	//��������Ϊdiv_temp
						end
               			cnt <= cnt + 1;
					/* ----------�����������---------- */
             		end else begin
						/* -----�з��ų����ұ�������������----- */
						if((signed_div_i == 1'b1) && ((reg_op1[31] ^ reg_op2[31]) == 1'b1)) begin
							dividend[31:0] <= (~dividend[31:0] + 1);
						end
						/* -----�з��ų����ұ����������ͬ��----- */
						if((signed_div_i == 1'b1) && ((reg_op1[31] ^ dividend[64]) == 1'b1)) begin              
							dividend[64:33] <= (~dividend[64:33] + 1);
						end
						state <= `DivEnd;
						cnt <= 6'b000000;
             		end
				/* ---------------ȡ����������--------------- */
		  		end else begin
		  			state <= `DivFree;
		  		end	
		  	end
			/* --------------------�����������-------------------- */
		  	`DivEnd:	begin
				result_o <= {dividend[64:33], dividend[31:0]};  
				ready_o <= `DivResultReady;
				if(start_i == `DivStop) begin
					state <= `DivFree;
					ready_o <= `DivResultNotReady;
					result_o <= {`ZeroWord,`ZeroWord};       	
				end		  	
		  	end
		  endcase
		end
	end

endmodule
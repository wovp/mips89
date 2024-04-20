
`timescale 1ns / 1ps
`include "defines2.vh"

module addr_except(
    input [31:0] addrs,     
    input [5:0] opM,
    output reg adelM,       
    output reg adesM        
    );
    
    always@(*) begin
        adelM <= 1'b0;      
        adesM <= 1'b0;
        case (opM)
            `LH: if (addrs[1:0] != 2'b00 & addrs[1:0] != 2'b10 ) begin
                adelM <= 1'b1;
            end
            `LHU: if ( addrs[1:0] != 2'b00 & addrs[1:0] != 2'b10 ) begin
                adelM <= 1'b1;
            end
            `LW: if ( addrs[1:0] != 2'b00 ) begin
                adelM <= 1'b1;
            end
            `SH: if (addrs[1:0] != 2'b00 & addrs[1:0] != 2'b10 ) begin
                adesM <= 1'b1;
            end
            `SW: if ( addrs[1:0] != 2'b00 ) begin
                adesM <= 1'b1;
            end
            default: begin
                adelM <= 1'b0;
                adesM <= 1'b0;
            end
        endcase
    end
endmodule

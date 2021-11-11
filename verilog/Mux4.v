/*
File Name : Mux4.v
Create time : 2021.07.14 00:03
Author : Morning Han
Function : 
    4 way selector

*/

module Mux4 (
    input wire[31:0] in0,
    input wire[31:0] in1,
    input wire[31:0] in2,
    input wire[31:0] in3,
    input wire[1:0] sel,

    output wire[31:0] out
);
    reg[31:0] temp;

    always @(*) begin
        case (sel)
            2'b00:
                temp = in0;
            2'b01:
                temp = in1;
            2'b10:
                temp = in2;
            default:
                temp = in3; 
        endcase
    end

    assign out = temp;
endmodule
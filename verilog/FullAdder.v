module FullAdder (
    input wire in1,
    input wire in2,
    input wire in3,

    output wire out,
    output wire carry
);
    assign out = ~in1 & ~in2 & in3 | ~in1 & in2 & ~in3 | in1 & ~in2 & ~in3 | in1 & in2 & in3;
    assign carry = in2 & in3 | in1 & in3 | in1 & in2;
endmodule
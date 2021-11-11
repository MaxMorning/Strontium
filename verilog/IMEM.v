module IMEM (
    input wire[31:0] a,

    output wire[31:0] spo
);

    reg[31:0] inst_array[0:255];

    assign spo = inst_array[a[7:0]];
    
endmodule
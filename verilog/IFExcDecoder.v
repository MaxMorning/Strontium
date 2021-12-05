module IFExcDecoder (
    input wire[31:0] if_imem_rdata,

    output wire exception,
    output wire eret,
    output wire[4:0] cause
);

    assign exception = if_imem_rdata[31:26] == 6'b000000 & if_imem_rdata[5:0] == 6'b001100; // System call
    assign eret = if_imem_rdata[31:26] == 6'b010000 & if_imem_rdata[5:0] == 6'b011000; // eret
    assign cause = 5'h8;
    
endmodule
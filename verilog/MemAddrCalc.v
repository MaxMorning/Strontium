module MemAddrCalc (
    input wire[31:0] rs_data,
    input wire[31:0] imm_ext_result,

    output wire[31:0] mem_addr
);
    assign mem_addr = rs_data + imm_ext_result;
endmodule
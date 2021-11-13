module IF_ID_reg (
    input wire clk,
    input wire reset,
    input wire ena, // Src: PipelineController.if_id_ena
    input wire[31:0] if_pc_in, // Src: PC.pc_out(IF)
    input wire[31:0] if_instr_in, // Src: IMEM.spo(IF)

    output wire[1:0] ExtSelect_out,
    output wire id_GPR_we,
    output wire[4:0] id_GPR_waddr,
    output wire[1:0] id_GPR_wdata_select,
    output wire id_mem_we,
    output reg[31:0] id_pc_out,
    output reg[31:0] id_instr_out
);
    
    always @(posedge clk or negedge reset) begin
        if (!reset) begin
            id_pc_out <= 32'h00000000;
            id_instr_out <= 32'h00000000;
        end
        else if (ena) begin
            id_pc_out <= if_pc_in;
            id_instr_out <= if_instr_in;
        end
    end

    assign ExtSelect_out[1] = (~id_instr_out[29] & ~id_instr_out[28] & ~id_instr_out[27] & ~id_instr_out[26]) | (~id_instr_out[31] & ~id_instr_out[29] & id_instr_out[28] & ~id_instr_out[27]);
    assign ExtSelect_out[0] = id_instr_out[29] ^ id_instr_out[28];

    assign id_GPR_we = ena & (
                        ~((~id_instr_out[29] & ~id_instr_out[28] & ~id_instr_out[27] & ~id_instr_out[26] & ~id_instr_out[5] & id_instr_out[3] & ~id_instr_out[1])
                         |
                         (id_instr_out[31] & id_instr_out[29] & ~id_instr_out[28] & id_instr_out[27] & id_instr_out[26])
                         |
                         (~id_instr_out[31] & ~id_instr_out[29] & id_instr_out[28] & ~id_instr_out[27])
                         |
                         (~id_instr_out[31] & ~id_instr_out[29] & ~id_instr_out[28] & id_instr_out[27] & ~id_instr_out[26]))
                        );

    wire[1:0] GPR_waddr_select;
    assign GPR_waddr_select[1] = ~id_instr_out[31] & ~id_instr_out[29] & ~id_instr_out[28] & id_instr_out[27] & id_instr_out[26];
    assign GPR_waddr_select[0] = ~id_instr_out[29] & ~id_instr_out[28] & ~id_instr_out[27] & ~id_instr_out[26];

    assign id_GPR_waddr = GPR_waddr_select[1] ? // 11 10
                            5'b11111
                            : // 01 00
                            (GPR_waddr_select[0] ? id_instr_out[15:11] : id_instr_out[20:16]);

    assign id_GPR_wdata_select[1] = ~id_instr_out[31] & ~id_instr_out[29] & ~id_instr_out[28] & id_instr_out[27] & id_instr_out[26];
    assign id_GPR_wdata_select[0] = id_instr_out[29] | id_instr_out[28] | ~id_instr_out[27] | ~id_instr_out[26];

    assign id_mem_we = ena & id_instr_out[31] & id_instr_out[29];
endmodule
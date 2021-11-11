// ALU version 2.0
module ALU (
    input wire[31:0] opr1,
    input wire[31:0] opr2,
    input wire[3:0] ALUControl,

    output wire[31:0] ALUResult,
    output wire not_change
);

    /*
        0000 : movz
        0001 : movn

        0010 : add
        0011 : addu

        0100 : sub
        0101 : subu

        0110 : and
        0111 : or
        1000 : xor
        1001 : nor

        1010 : slt
        1011 : sltu

        1100 : srl
        1101 : sra

        1110 : sll

        1111 : lui
    */

    wire[32:0] extOpr1 = {opr1[31], opr1};
    wire[32:0] extOpr2 = {opr2[31], opr2};

    wire[32:0] addResult = extOpr1 + extOpr2;
    wire[31:0] adduResult = opr1 + opr2;

    wire[32:0] subResult = extOpr1 - extOpr2;
    wire[31:0] subuResult = opr1 - opr2;

    wire[31:0] andResult = opr1 & opr2;
    wire[31:0] orResult = opr1 | opr2;
    wire[31:0] xorResult = opr1 ^ opr2;
    wire[31:0] norResult = ~(opr1 | opr2);

    wire[31:0] sltResult = $signed(opr1) < $signed(opr2) ? 32'h1 : 32'h0;
    wire[31:0] sltuResult = opr1 < opr2 ? 32'h1 : 32'h0;

    wire[31:0] sllResult = opr2 << opr1;
    wire[31:0] srlResult = opr2 >> opr1;
    wire[31:0] sraResult = opr2[31] ? (~(32'hffffffff >> opr1) | (opr2 >> opr1)) : opr2 >> opr1;

    wire[31:0] luiResult = {opr2[15:0], 16'h0};

    wire[31:0] movnResult = opr1;

    reg[31:0] alu_result_reg;
    assign ALUResult = alu_result_reg;
    
    always @(*) begin
        case (ALUControl)
            4'b0000, // movz
            4'b0001: // movn
            begin
                alu_result_reg = movnResult;
            end

            4'b0010: // add
            begin
                alu_result_reg = addResult;
            end

            4'b0011: // addu
            begin
                alu_result_reg = adduResult;
            end

            4'b0100: // sub
            begin
                alu_result_reg = subResult;
            end

            4'b0101: // subu
            begin
                alu_result_reg = subuResult;
            end

            4'b0110: // and
            begin
                alu_result_reg = andResult;
            end

            4'b0111: // or
            begin
                alu_result_reg = orResult;
            end

            4'b1000: // xor
            begin
                alu_result_reg = xorResult;
            end

            4'b1001: // nor
            begin
                alu_result_reg = norResult;
            end

            4'b1010: // slt
            begin
                alu_result_reg = sltResult;
            end

            4'b1011: // sltu
            begin
                alu_result_reg = sltuResult;
            end

            4'b1100: // srl
            begin
                alu_result_reg = srlResult;
            end

            4'b1101: // sra
            begin
                alu_result_reg = sraResult;
            end

            4'b1110: // sll
            begin
                alu_result_reg = sllResult;
            end

            4'b1111: // lui
            begin
                alu_result_reg = luiResult;
            end

            default: // invalid
            begin
                alu_result_reg = 32'hcfcfcfcf;
            end
        endcase
    end

    wire not_change_movn = (ALUControl == 4'b0001 & opr2 == 0);
    wire not_change_movz = (ALUControl == 4'b0000 & opr2 != 0);
    wire not_change_add_overflow = ALUControl == 4'b0010 & (addResult[32] ^ addResult[31]);
    wire not_change_sub_overflow = ALUControl == 4'b0100 & (subResult[32] ^ subResult[31]);

    assign not_change = not_change_movn | not_change_movz | not_change_add_overflow | not_change_sub_overflow;
endmodule
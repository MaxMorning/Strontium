`timescale 1ns / 1ps

module WallaceMult (
    input wire[31:0] opr1,
    input wire[31:0] opr2,

    output wire[31:0] result
);
    wire[31:0] stage_0_result[31:0]; // 3 * 10 + 2 = 32 Line

    genvar i;
    genvar j;
    generate
        for (i = 0; i < 32; i = i + 1) begin: GEN_I_0
            for (j = 0; j < i; j = j + 1) begin: GEN_J_0_LESS
                assign stage_0_result[i][j] = 0;
            end

            for (j = i; j < 32; j = j + 1) begin: GEN_J_0_GREATER
                assign stage_0_result[i][j] = opr2[i] & opr1[j - i];
            end
        end
    endgenerate

    wire[31:0] stage_1_result[21:0]; // 2 * 10 + 2 = 22 = 3 * 7 + 1 Line

    generate
        for (i = 0; i < 10; i = i + 1) begin: GEN_I_1_FA
            assign stage_1_result[2 * i + 1][0] = 0;
            for (j = 0; j < 31; j = j + 1) begin: GEN_J_1_FA
                FullAdder fa_inst(
                    .in1(stage_0_result[3 * i + 0][j]),
                    .in2(stage_0_result[3 * i + 1][j]),
                    .in3(stage_0_result[3 * i + 2][j]),
                    .out(stage_1_result[2 * i + 0][j]),
                    .carry(stage_1_result[2 * i + 1][j + 1])
                );
            end

            FullAdder fa_inst_31(
                .in1(stage_0_result[3 * i + 0][31]),
                .in2(stage_0_result[3 * i + 1][31]),
                .in3(stage_0_result[3 * i + 2][31]),
                .out(stage_1_result[2 * i + 0][31]),
                .carry() // just hang
            );
        end
    endgenerate

    assign stage_1_result[20] = stage_0_result[30];
    assign stage_1_result[21] = stage_0_result[31];


    wire[31:0] stage_2_result[14:0]; // 2 * 7 + 1 = 15 = 3 * 5 + 0 Line

    generate
        for (i = 0; i < 7; i = i + 1) begin: GEN_I_2_FA
            assign stage_2_result[2 * i + 1][0] = 0;
            for (j = 0; j < 31; j = j + 1) begin: GEN_J_2_FA
                FullAdder fa_inst(
                    .in1(stage_1_result[3 * i + 0][j]),
                    .in2(stage_1_result[3 * i + 1][j]),
                    .in3(stage_1_result[3 * i + 2][j]),
                    .out(stage_2_result[2 * i + 0][j]),
                    .carry(stage_2_result[2 * i + 1][j + 1])
                );
            end

            FullAdder fa_inst_31(
                .in1(stage_1_result[3 * i + 0][31]),
                .in2(stage_1_result[3 * i + 1][31]),
                .in3(stage_1_result[3 * i + 2][31]),
                .out(stage_2_result[2 * i + 0][31]),
                .carry() // just hang
            );
        end
    endgenerate
    assign stage_2_result[14] = stage_1_result[21];

    
    wire[31:0] stage_3_result[9:0]; // 2 * 5 + 0 = 10 = 3 * 3 + 1 Line

    generate
        for (i = 0; i < 5; i = i + 1) begin: GEN_I_3_FA
            assign stage_3_result[2 * i + 1][0] = 0;
            for (j = 0; j < 31; j = j + 1) begin: GEN_J_3_FA
                FullAdder fa_inst(
                    .in1(stage_2_result[3 * i + 0][j]),
                    .in2(stage_2_result[3 * i + 1][j]),
                    .in3(stage_2_result[3 * i + 2][j]),
                    .out(stage_3_result[2 * i + 0][j]),
                    .carry(stage_3_result[2 * i + 1][j + 1])
                );
            end

            FullAdder fa_inst_31(
                .in1(stage_2_result[3 * i + 0][31]),
                .in2(stage_2_result[3 * i + 1][31]),
                .in3(stage_2_result[3 * i + 2][31]),
                .out(stage_3_result[2 * i + 0][31]),
                .carry() // just hang
            );
        end
    endgenerate


    wire[31:0] stage_4_result[6:0]; // 2 * 3 + 1 = 7 = 3 * 2 + 1 Line

    generate
        for (i = 0; i < 3; i = i + 1) begin: GEN_I_4_FA
            assign stage_4_result[2 * i + 1][0] = 0;
            for (j = 0; j < 31; j = j + 1) begin: GEN_J_4_FA
                FullAdder fa_inst(
                    .in1(stage_3_result[3 * i + 0][j]),
                    .in2(stage_3_result[3 * i + 1][j]),
                    .in3(stage_3_result[3 * i + 2][j]),
                    .out(stage_4_result[2 * i + 0][j]),
                    .carry(stage_4_result[2 * i + 1][j + 1])
                );
            end

            FullAdder fa_inst_31(
                .in1(stage_3_result[3 * i + 0][31]),
                .in2(stage_3_result[3 * i + 1][31]),
                .in3(stage_3_result[3 * i + 2][31]),
                .out(stage_4_result[2 * i + 0][31]),
                .carry() // just hang
            );
        end
    endgenerate

    assign stage_4_result[6] = stage_3_result[9];


    wire[31:0] stage_5_result[4:0]; // 2 * 2 + 1 = 5 = 3 * 1 + 2 Line
    generate
        for (i = 0; i < 2; i = i + 1) begin: GEN_I_5_FA
            assign stage_5_result[2 * i + 1][0] = 0;
            for (j = 0; j < 31; j = j + 1) begin: GEN_J_5_FA
                FullAdder fa_inst(
                    .in1(stage_4_result[3 * i + 0][j]),
                    .in2(stage_4_result[3 * i + 1][j]),
                    .in3(stage_4_result[3 * i + 2][j]),
                    .out(stage_5_result[2 * i + 0][j]),
                    .carry(stage_5_result[2 * i + 1][j + 1])
                );
            end

            FullAdder fa_inst_31(
                .in1(stage_4_result[3 * i + 0][31]),
                .in2(stage_4_result[3 * i + 1][31]),
                .in3(stage_4_result[3 * i + 2][31]),
                .out(stage_5_result[2 * i + 0][31]),
                .carry() // just hang
            );
        end
    endgenerate

    assign stage_5_result[4] = stage_4_result[6];


    wire[31:0] stage_6_result[3:0]; // 2 * 1 + 2 = 4 = 3 * 1 + 1 Line

    generate
        for (i = 0; i < 1; i = i + 1) begin: GEN_I_6_FA
            assign stage_6_result[2 * i + 1][0] = 0;
            for (j = 0; j < 31; j = j + 1) begin: GEN_J_6_FA
                FullAdder fa_inst(
                    .in1(stage_5_result[3 * i + 0][j]),
                    .in2(stage_5_result[3 * i + 1][j]),
                    .in3(stage_5_result[3 * i + 2][j]),
                    .out(stage_6_result[2 * i + 0][j]),
                    .carry(stage_6_result[2 * i + 1][j + 1])
                );
            end

            FullAdder fa_inst_31(
                .in1(stage_5_result[3 * i + 0][31]),
                .in2(stage_5_result[3 * i + 1][31]),
                .in3(stage_5_result[3 * i + 2][31]),
                .out(stage_6_result[2 * i + 0][31]),
                .carry() // just hang
            );
        end
    endgenerate
    assign stage_6_result[2] = stage_5_result[3];
    assign stage_6_result[3] = stage_5_result[4];



    wire[31:0] stage_7_result[2:0]; // 2 * 1 + 1 = 3 = 3 * 1 + 0 Line

    generate
        for (i = 0; i < 1; i = i + 1) begin: GEN_I_7_FA
            assign stage_7_result[2 * i + 1][0] = 0;
            for (j = 0; j < 31; j = j + 1) begin: GEN_J_7_FA
                FullAdder fa_inst(
                    .in1(stage_6_result[3 * i + 0][j]),
                    .in2(stage_6_result[3 * i + 1][j]),
                    .in3(stage_6_result[3 * i + 2][j]),
                    .out(stage_7_result[2 * i + 0][j]),
                    .carry(stage_7_result[2 * i + 1][j + 1])
                );
            end

            FullAdder fa_inst_31(
                .in1(stage_6_result[3 * i + 0][31]),
                .in2(stage_6_result[3 * i + 1][31]),
                .in3(stage_6_result[3 * i + 2][31]),
                .out(stage_7_result[2 * i + 0][31]),
                .carry() // just hang
            );
        end
    endgenerate
    assign stage_7_result[2] = stage_6_result[3];


    wire[31:0] stage_8_result[1:0]; // 2 * 1 + 0 = 2 Line
    generate
        for (i = 0; i < 1; i = i + 1) begin: GEN_I_8_FA
            assign stage_8_result[2 * i + 1][0] = 0;
            for (j = 0; j < 31; j = j + 1) begin: GEN_J_8_FA
                FullAdder fa_inst(
                    .in1(stage_7_result[3 * i + 0][j]),
                    .in2(stage_7_result[3 * i + 1][j]),
                    .in3(stage_7_result[3 * i + 2][j]),
                    .out(stage_8_result[2 * i + 0][j]),
                    .carry(stage_8_result[2 * i + 1][j + 1])
                );
            end

            FullAdder fa_inst_31(
                .in1(stage_7_result[3 * i + 0][31]),
                .in2(stage_7_result[3 * i + 1][31]),
                .in3(stage_7_result[3 * i + 2][31]),
                .out(stage_8_result[2 * i + 0][31]),
                .carry() // just hang
            );
        end
    endgenerate

    assign result = stage_8_result[0] + stage_8_result[1];
endmodule
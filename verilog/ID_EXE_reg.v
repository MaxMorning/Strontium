module ID_EXE_reg (
    input wire clk,
    input wire reset,
    input wire ena, // Src: PipelineController.id_exe_ena
    input wire[31:0] id_instr_in, // Src: Instr(ID)
    input wire[31:0] id_pc_in, // Src: ID_pc_out(ID)

    input wire[31:0] ext_result_in, // Src: ImmExt.ExtResult(ID)
    input wire[31:0] id_GPR_rs_in, // Src: RegFile.rdata1(ID)
    input wire[31:0] id_GPR_rt_in, // Src: RegFile.rdata2(ID)

    input wire id_GPR_we_in, // Src: IF_ID_reg.id_GPR_we(ID)
    input wire[4:0] id_GPR_waddr_in, // Src: IF_ID_reg.id_GPR_waddr(ID)
    input wire[1:0] id_GPR_wdata_select_in, // Src: IF_ID_reg.id_GPR_wdata_select(ID)

    input wire[31:0] id_mem_ask_addr,


    (* max_fanout = "8" *) output reg[31:0] exe_alu_opr1_out,
    (* max_fanout = "8" *) output reg[31:0] exe_alu_opr2_out,
    output wire[3:0] exe_alu_contorl,
    output reg[31:0] exe_mem_fetch_addr,
    output reg exe_GPR_we,
    output reg[4:0] exe_GPR_waddr,
    output reg[1:0] exe_GPR_wdata_select,
    output reg[31:0] exe_GPR_rt_out,
    output reg[31:0] exe_pc_out
);

    reg[31:0] exe_instr_out;
    wire alu_opr1_select = ~id_instr_in[29] & ~id_instr_in[28] & ~id_instr_in[27] & ~id_instr_in[26] & ~id_instr_in[5] & ~id_instr_in[3] & ~id_instr_in[2];
    wire alu_opr2_select = ~id_instr_in[30] & (id_instr_in[29] | id_instr_in[31]);

    always @(posedge clk or negedge reset) begin
        if (!reset) begin
            exe_pc_out <= 32'h00000000;
            exe_instr_out <= 32'h00000000;

            exe_alu_opr1_out <= 0;
            exe_alu_opr2_out <= 0;
            exe_mem_fetch_addr <= 0;
            exe_GPR_waddr <= 0;
            exe_GPR_wdata_select <= 0;
            exe_GPR_rt_out <= 0;
            exe_GPR_we <= 0;
        end
        else if (ena) begin
            exe_pc_out <= id_pc_in;
            exe_instr_out <= id_instr_in;

            exe_alu_opr1_out <= alu_opr1_select ? ext_result_in : id_GPR_rs_in;
            exe_alu_opr2_out <= alu_opr2_select ? ext_result_in : id_GPR_rt_in;

            exe_mem_fetch_addr <= id_mem_ask_addr;
            
            exe_GPR_we <= id_GPR_we_in & ena;
            exe_GPR_waddr <= id_GPR_waddr_in;
            exe_GPR_wdata_select <= id_GPR_wdata_select_in;
            exe_GPR_rt_out <= id_GPR_rt_in;
        end
    end

    reg[3:0] alu_control_reg;
    assign exe_alu_contorl = alu_control_reg;

    // ALU control signal v2.0
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
    always @(*) begin
        case (exe_instr_out[31:26])
            6'b000000: // R-type
            begin
                case (exe_instr_out[5:0])
                    6'b100000: // add
                    begin
                        alu_control_reg = 4'b0010;
                    end 

                    6'b100001: // addu
                    begin
                        alu_control_reg = 4'b0011;
                    end

                    6'b100010: // sub
                    begin
                        alu_control_reg = 4'b0100;
                    end

                    6'b100011: // subu
                    begin
                        alu_control_reg = 4'b0101;
                    end

                    6'b100100: // and
                    begin
                        alu_control_reg = 4'b0110;
                    end

                    6'b100101: // or
                    begin
                        alu_control_reg = 4'b0111;
                    end

                    6'b100110: // xor
                    begin
                        alu_control_reg = 4'b1000;
                    end

                    6'b100111: // nor
                    begin
                        alu_control_reg = 4'b1001;
                    end

                    6'b101010: // slt
                    begin
                        alu_control_reg = 4'b1010;
                    end

                    6'b101011: // sltu
                    begin
                        alu_control_reg = 4'b1011;
                    end

                    6'b000000, // sll
                    6'b000100: // sllv
                    begin
                        alu_control_reg = 4'b1110;
                    end

                    6'b000010, // srl
                    6'b000110: // srlv
                    begin
                        alu_control_reg = 4'b1100;
                    end

                    6'b000011, // sra
                    6'b000111: // srav
                    begin
                        alu_control_reg = 4'b1101;
                    end

                    6'b001011: // movn
                    begin
                        alu_control_reg = 4'b0001;
                    end

                    6'b001010: // movz
                    begin
                        alu_control_reg = 4'b0000;
                    end
                    default: // invalid
                    begin
                        alu_control_reg = 4'b0000;
                    end
                endcase
            end 
            6'b001000: // addi
            begin
                alu_control_reg = 4'b0010;
            end

            6'b100011, // lw
            6'b101011, // sw
            6'b001001: // addiu
            begin
                alu_control_reg = 4'b0011;
            end

            6'b001100: // andi
            begin
                alu_control_reg = 4'b0110;
            end

            6'b001101: // ori
            begin
                alu_control_reg = 4'b0111;
            end

            6'b001110: // xori
            begin
                alu_control_reg = 4'b1000;
            end

            6'b001010: // slti
            begin
                alu_control_reg = 4'b1010;
            end

            6'b001011: // sltiu
            begin
                alu_control_reg = 4'b1011;
            end

            6'b001111: // lui
            begin
                alu_control_reg = 4'b1111;
            end
            default: // invalid
            begin
                alu_control_reg = 4'b0110; // assume not_change signal from ALU is not 1
            end
        endcase
    end
    // assign exe_alu_contorl = exe_instr_out[31] ? 4'b0001 : // lw/sw
    //                     (exe_instr_out[29] ? // 1xxx
    //                         (exe_instr_out[28] ? // 11xx
    //                             (exe_instr_out[27] ? // 111x
    //                                 (exe_instr_out[26] ? 4'b1110 : 4'b0110) : //1111 lui   1110 xori
    //                                 {1'b0, exe_instr_out[28:26]} //1101 ori   1100 andi
    //                                 // (exe_instr_out[26] ? 4'b0101 : 4'b0100) //1101 ori   1100 andi
    //                             ) : // 10xx
    //                             {exe_instr_out[27], exe_instr_out[28:26]}
    //                             // (exe_instr_out[27] ? 
    //                             //     (exe_instr_out[26] ? 4'b1011 : 4'b1010) : //1011 sltiu    1010 slti
    //                             //     (exe_instr_out[26] ? 4'b0001 : 4'b0000) //1001 addiu   1000 addi
    //                             // )
    //                         ) : // 0xxx
    //                         (exe_instr_out[28] ? // 01xx
    //                             4'b0110 : // 00xx
    //                             // (exe_instr_out[27] ? 
    //                             //     (exe_instr_out[26] ? 4'b1110 : 4'b0110) : //0111 NA  0110 NA
    //                             //     (exe_instr_out[26] ? 4'b0110 : 4'b0110) //0101 bne   0100 beq
    //                             // ) :
    //                             (exe_instr_out[27] ? // 001x
    //                                 {2'b00, exe_instr_out[27:26]} : // 000x
    //                                 // (exe_instr_out[26] ? 4'b1011 : 4'b1010) : //0011 jal   0010 j
    //                                 (exe_instr_out[26] ? 4'b0001 : {4{exe_instr_out[5]}} ~^ {exe_instr_out[3], exe_instr_out[5] & exe_instr_out[2], exe_instr_out[1:0]}) //0001 NA   0000 R type
    //                             )
    //                         )
    //                     );
endmodule
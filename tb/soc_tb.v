`timescale 1ns/1ps
module soc_tb();
    reg clk;
    reg reset;
    reg system_ena;
    wire[31:0] inst;
    wire[31:0] pc;

    integer fout;
    integer i;
    integer check_loop;

    wire[31:0] a_0;
    wire[31:0] a_1;
    wire[31:0] a_2;
    wire[31:0] a_3;
    wire[31:0] a_4;
    wire[31:0] a_5;
    wire[31:0] a_6;
    wire[31:0] a_7;

    assign a_0 = soc.dmem_inst.data_array[0];
    assign a_1 = soc.dmem_inst.data_array[1];
    assign a_2 = soc.dmem_inst.data_array[2];
    assign a_3 = soc.dmem_inst.data_array[3];
    assign a_4 = soc.dmem_inst.data_array[4];
    assign a_5 = soc.dmem_inst.data_array[5];
    assign a_6 = soc.dmem_inst.data_array[6];
    assign a_7 = soc.dmem_inst.data_array[7];

    SoC soc(
        .clk(clk),
        .reset(reset),
        .system_ena(system_ena)
    );

    assign pc = soc.core0.exe_pc_out;
    assign inst = soc.core0.id_exe_reg_inst.exe_instr_out;

    initial begin
        clk = 0;
        forever begin
            #5 clk = ~clk;
        end
    end

    initial begin
        $dumpfile("result.vcd");
        $dumpvars(5);

        $readmemh("./MIPS/WORKSPACE/instr.txt", soc.imem_inst.inst_array);
        $readmemh("./MIPS/DMEM.txt", soc.dmem_inst.data_array);
        fout = $fopen("./MIPS/WORKSPACE/result.txt", "w+");
        reset = 0;
        system_ena = 1;
        #3
        reset = 1;

        #29;
        for (check_loop = 0; check_loop < 512; check_loop = check_loop + 1) begin
            $fdisplay(fout, "pc: %h", pc);
            $fdisplay(fout, "instr: %h", inst);

            for (i = 0; i < 32; i = i + 1) begin
                $fdisplay(fout, "regfile%d: %h", i, soc.core0.gpr_inst.array_reg[i]);
            end
            #10;
        end

        $fclose(fout);

        $finish;
    end
    
endmodule
module Core (
    input wire clk,
    input wire reset,
    input wire cpu_ena,
    input wire pause,

    input wire[31:0] IMEM_rdata,
    input wire[31:0] DMEM_rdata,

    output wire[31:0] IMEM_raddr,
    output wire[31:0] DMEM_addr,
    output wire[31:0] fetch_DMEM_addr,
    output wire[31:0] DMEM_wdata,
    output wire DMEM_we
);
    (* max_fanout = "4" *) wire if_id_ena;
    (* max_fanout = "4" *) wire id_exe_ena;

    // IF
    wire[31:0] if_pc_out;
    wire[31:0] if_imem_rdata;

    // ID
    (* max_fanout = "4" *) wire id_should_branch;
    (* max_fanout = "4" *) wire[31:0] id_branch_pc;
    (* max_fanout = "4" *) wire[1:0] id_ext_select;
    (* max_fanout = "4" *) wire id_GPR_we;
    (* max_fanout = "4" *) wire[4:0] id_GPR_waddr;
    (* max_fanout = "4" *) wire[1:0] id_GPR_wdata_select;
    (* max_fanout = "4" *) wire[31:0] id_pc_out;
    (* max_fanout = "4" *) wire[31:0] id_instr_out;

    wire[31:0] id_ori_rs_data;
    wire[31:0] id_ori_rt_data;

    wire[31:0] id_ext_result;

    wire[31:0] id_mem_ask_addr;
    wire id_mem_we;

    wire[31:0] id_valid_rs_data;
    wire[31:0] id_valid_rt_data;

    // EXE
    wire exe_GPR_we;
    wire[4:0] exe_GPR_waddr;
    wire[1:0] exe_GPR_wdata_select;
    wire[31:0] exe_pc_out;

    (* max_fanout = "4" *) wire[31:0] exe_alu_opr1;
    (* max_fanout = "4" *) wire[31:0] exe_alu_opr2;
    wire[3:0] exe_alu_contorl;
    wire[31:0] exe_alu_result;

    wire[31:0] exe_GPR_rt_out;

    wire exe_alu_not_change;


    wire[31:0] exe_mem_fetch_addr;
    wire[31:0] exe_mem_rdata;

    (* max_fanout = "4" *) wire[31:0] exe_GPR_wdata;

    assign if_imem_rdata = IMEM_rdata;
    assign exe_mem_rdata = DMEM_rdata;

    assign IMEM_raddr = if_pc_out;
    assign fetch_DMEM_addr = exe_mem_fetch_addr;
    assign DMEM_addr = id_mem_ask_addr;
    assign DMEM_wdata = id_valid_rt_data;
    assign DMEM_we = id_mem_we;


    PipelineController pipeline_ctrl_inst(
        .clk(clk),
        .reset(reset),
        .ena(cpu_ena & ~pause),

        .if_id_ena(if_id_ena),
        .id_exe_ena(id_exe_ena)
    );

    // IF

    PC pc_inst(
        .clk(clk),
        .reset(reset),
        .we(cpu_ena & ~pause),

        .pc_in(id_should_branch ? id_branch_pc : if_pc_out + 4),

        .pc_out(if_pc_out)
    );

    // ID
    IF_ID_reg if_id_reg_inst(
        .clk(clk),
        .reset(reset),
        .ena(if_id_ena & ~pause),

        .if_pc_in(if_pc_out),
        .if_instr_in(if_imem_rdata),

        .ExtSelect_out(id_ext_select),
        .id_GPR_we(id_GPR_we),
        .id_GPR_waddr(id_GPR_waddr),
        .id_GPR_wdata_select(id_GPR_wdata_select),
        .id_mem_we(id_mem_we),
        .id_pc_out(id_pc_out),
        .id_instr_out(id_instr_out)
    );

    RegFile gpr_inst(
        .clk(clk),
        .reset(reset),
        .we(exe_GPR_we & ~exe_alu_not_change),
        .raddr1(id_instr_out[25:21]),
        .raddr2(id_instr_out[20:16]),

        .waddr(exe_GPR_waddr),
        .wdata(exe_GPR_wdata),

        .rdata1(id_ori_rs_data),
        .rdata2(id_ori_rt_data)
    );

    ImmExt imm_ext_inst(
        .Imm16(id_instr_out[15:0]),
        .ExtSelect(id_ext_select),

        .extResult(id_ext_result)
    );

    GPRByPassProc gpr_bypass_proc_inst(
        .EXE_waddr(exe_GPR_waddr),
        .EXE_wdata(exe_GPR_wdata),
        .EXE_we(exe_GPR_we),

        .rs_addr(id_instr_out[25:21]),
        .rs_data(id_ori_rs_data),

        .rt_addr(id_instr_out[20:16]),
        .rt_data(id_ori_rt_data),

        .rs_valid_data(id_valid_rs_data),
        .rt_valid_data(id_valid_rt_data)
    );

    BranchProc branch_proc_inst(
        .instr(id_instr_out),
        .GPR_rs_data(id_valid_rs_data),
        .GPR_rt_data(id_valid_rt_data),
        .delay_slot_pc(if_pc_out),

        .is_branch(id_should_branch),
        .branch_pc(id_branch_pc)
    );

    MemAddrCalc mem_addr_calc_inst(
        .rs_data(id_valid_rs_data),
        .imm_ext_result(id_ext_result),

        .mem_addr(id_mem_ask_addr)
    );

    // EXE

    ID_EXE_reg id_exe_reg_inst(
        .clk(clk),
        .reset(reset),
        .ena(id_exe_ena & ~pause),

        .id_instr_in(id_instr_out),
        .id_pc_in(id_pc_out),

        .ext_result_in(id_ext_result),
        .id_GPR_rs_in(id_valid_rs_data),
        .id_GPR_rt_in(id_valid_rt_data),

        .id_GPR_we_in(id_GPR_we),
        .id_GPR_waddr_in(id_GPR_waddr),
        .id_GPR_wdata_select_in(id_GPR_wdata_select),

        .id_mem_ask_addr(id_mem_ask_addr),

        .exe_alu_opr1_out(exe_alu_opr1),
        .exe_alu_opr2_out(exe_alu_opr2),
        .exe_alu_contorl(exe_alu_contorl),

        .exe_mem_fetch_addr(exe_mem_fetch_addr),

        .exe_GPR_we(exe_GPR_we),
        .exe_GPR_waddr(exe_GPR_waddr),
        .exe_GPR_wdata_select(exe_GPR_wdata_select),
        .exe_GPR_rt_out(exe_GPR_rt_out),
        .exe_pc_out(exe_pc_out)
    );

    ALU alu_inst(
        .opr1(exe_alu_opr1),
        .opr2(exe_alu_opr2),
        .ALUControl(exe_alu_contorl),

        .ALUResult(exe_alu_result),
        .not_change(exe_alu_not_change)
    );

    Mux4 gpr_wdata_select_inst(
        .in0(exe_mem_rdata),
        .in1(exe_alu_result),
        .in2(exe_pc_out + 8),
        .in3(32'hffffffff),
        .sel(exe_GPR_wdata_select),

        .out(exe_GPR_wdata)
    );
endmodule
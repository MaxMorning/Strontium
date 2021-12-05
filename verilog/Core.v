module Core (
    input wire clk,
    input wire reset,
    input wire cpu_ena,
    input wire out_interruption,

    input wire[31:0] IMEM_rdata,
    input wire[31:0] DMEM_rdata,

    output wire[31:0] IMEM_raddr,
    output wire[31:0] DMEM_addr,
    output wire[31:0] fetch_DMEM_addr,
    output wire[31:0] DMEM_wdata,
    output wire DMEM_we,

    output wire[31:0] GPR_wb_data
);
    (* max_fanout = "4" *) wire if_id_ena;
    (* max_fanout = "4" *) wire id_exe_ena;

    // IF
    wire if_interruption;
    wire if_software_exception; // Syscall
    wire if_eret;
    wire[4:0] if_cause;
    wire[31:0] if_cp0_pc_in;
    wire[31:0] id_ori_cp0_data;

    wire[31:0] if_pc_out;
    wire[31:0] if_imem_rdata;

    // ID
    (* max_fanout = "4" *) wire id_should_branch;
    (* max_fanout = "4" *) wire[31:0] id_branch_pc;
    (* max_fanout = "4" *) wire[1:0] id_ext_select;
    (* max_fanout = "4" *) wire id_GPR_we;
    wire id_mtc0;
    wire id_mfc0;
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

    wire[31:0] id_cp0_data;

    // EXE
    wire exe_GPR_we;
    wire exe_mtc0;
    wire exe_mfc0;
    wire[31:0] exe_cp0_data;
    wire exe_mfc0;

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

    wire[31:0] exe_mult_result;

    (* max_fanout = "4" *) wire[31:0] exe_GPR_wdata;

    assign if_imem_rdata = IMEM_rdata;
    assign exe_mem_rdata = DMEM_rdata;

    assign IMEM_raddr = if_pc_out;
    assign fetch_DMEM_addr = exe_mem_fetch_addr;
    assign DMEM_addr = id_mem_ask_addr;
    assign DMEM_wdata = id_valid_rt_data;
    assign DMEM_we = id_mem_we;

    assign if_interruption = out_interruption | if_software_exception;
    assign GPR_wb_data = exe_GPR_wdata;


    PipelineController pipeline_ctrl_inst(
        .clk(clk),
        .reset(reset),
        .ena(cpu_ena),

        .if_id_ena(if_id_ena),
        .id_exe_ena(id_exe_ena)
    );

    // IF

    PC pc_inst(
        .clk(clk),
        .reset(reset),
        .we(cpu_ena),

        .pc_in(if_cp0_pc_in),

        .pc_out(if_pc_out)
    );

    IFExcDecoder if_exc_dec_inst(
        .if_imem_rdata(if_imem_rdata),

        .exception(if_software_exception),
        .eret(if_eret),
        .cause(if_cause)
    );

    CP0 cp0_inst(
        .clk(clk),
        .reset(reset),

        .pc(id_should_branch ? id_branch_pc : if_pc_out + 4),

        .mtc0(exe_mtc0),
        .Rd(id_instr_out[15:10]),
        .wdata(exe_GPR_rt_out),

        .exception(if_interruption),
        .eret(if_eret),
        .cause(out_interruption ? 5'ha : if_cause),

        .rdata(id_ori_cp0_data),
        .exc_addr(if_cp0_pc_in)
    );

    // ID
    IF_ID_reg if_id_reg_inst(
        .clk(clk),
        .reset(reset),
        .ena(if_id_ena),

        .if_pc_in(if_pc_out),
        .if_instr_in(if_imem_rdata),

        .ExtSelect_out(id_ext_select),
        .id_GPR_we(id_GPR_we),
        .id_mtc0(id_mtc0),
        .id_mfc0(id_mfc0),
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

    CP0ByPassProc cp0_bypass_proc_inst(
        .EXE_waddr(exe_instr_out[15:10]),
        .EXE_wdata(exe_GPR_rt_out),
        .EXE_we(exe_mfc0),

        .mfc0_addr(id_instr_out[15:10]),
        .mfc0_ori_data(id_ori_cp0_data),

        .mfc0_valid_data(id_cp0_data)
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
        .ena(id_exe_ena),

        .id_instr_in(id_instr_out),
        .id_pc_in(id_pc_out),

        .ext_result_in(id_ext_result),
        .id_GPR_rs_in(id_valid_rs_data),
        .id_GPR_rt_in(id_valid_rt_data),
        .id_cp0_data(id_cp0_data),

        .id_mtc0_in(id_mtc0),
        .id_mfc0_in(id_mfc0),
        .id_GPR_we_in(id_GPR_we),
        .id_GPR_waddr_in(id_GPR_waddr),
        .id_GPR_wdata_select_in(id_GPR_wdata_select),

        .id_mem_ask_addr(id_mem_ask_addr),

        .exe_alu_opr1_out(exe_alu_opr1),
        .exe_alu_opr2_out(exe_alu_opr2),
        .exe_alu_contorl(exe_alu_contorl),
        .exe_mfc0_out(exe_mfc0),
        .exe_mtc0_out(exe_mtc0),

        .exe_mem_fetch_addr(exe_mem_fetch_addr),

        .exe_GPR_we(exe_GPR_we),
        .exe_GPR_waddr(exe_GPR_waddr),
        .exe_GPR_wdata_select(exe_GPR_wdata_select),
        .exe_GPR_rt_out(exe_GPR_rt_out),
        .exe_pc_out(exe_pc_out),
        .exe_cp0_data(exe_cp0_data)
    );

    ALU alu_inst(
        .opr1(exe_alu_opr1),
        .opr2(exe_alu_opr2),
        .ALUControl(exe_alu_contorl),

        .ALUResult(exe_alu_result),
        .not_change(exe_alu_not_change)
    );

    WallaceMult mult_inst(
        .opr1(exe_alu_opr1),
        .opr2(exe_alu_opr2),
        .result(exe_mult_result)
    );

    Mux4 gpr_wdata_select_inst(
        .in0(exe_mem_rdata),
        .in1(exe_mfc0 ? exe_cp0_data : exe_alu_result),
        .in2(exe_pc_out + 8),
        .in3(exe_mult_result),
        .sel(exe_GPR_wdata_select),

        .out(exe_GPR_wdata)
    );
endmodule
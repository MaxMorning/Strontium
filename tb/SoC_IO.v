module SoC (
    input wire base_clk,
    input wire[15:0] opr,
    input wire reset,

    output wire[15:0] result,
    
    output wire[7:0] o_seg,
    output wire[7:0] o_sel
);

    wire clk_cpu;

    wire[31:0] IMEM_rdata;
    wire[31:0] DMEM_rdata;

    wire[31:0] IMEM_raddr;
    wire[31:0] DMEM_addr;
    wire[31:0] fetch_DMEM_addr;
    wire[31:0] DMEM_wdata;
    wire DMEM_we;

    wire[15:0] toss_cnt;
    wire[15:0] egg_cnt;

    IMEM imem_inst(
        .a(IMEM_raddr[31:2]),

        .spo(IMEM_rdata)
    );

    
    DMEM dmem_inst(
        .clk(clk_cpu),
        .we(DMEM_we),
        .ask_addr(DMEM_addr),
        .fetch_addr(fetch_DMEM_addr),
        .wdata(DMEM_wdata),

        .rdata(DMEM_rdata),

        .opr1(opr[15:8]),
        .opr2(opr[7:0]),
        .toss_cnt(toss_cnt),
        .egg_cnt(egg_cnt),
        .is_egg_break(result)
    );

    Core core0(
        .clk(clk_cpu),
        .reset(~reset),
        .cpu_ena(1'b1),
        .out_interruption(1'b0),

        .IMEM_rdata(IMEM_rdata),
        .DMEM_rdata(DMEM_rdata),

        .IMEM_raddr(IMEM_raddr),
        .DMEM_addr(DMEM_addr),
        .fetch_DMEM_addr(fetch_DMEM_addr),
        .DMEM_wdata(DMEM_wdata),
        .DMEM_we(DMEM_we)
    );
    
    clock clock_inst(
        .clk_in1(base_clk),
        .clk_out1(clk_cpu),
        .resetn(~reset)
    );

    seg7x16 seg7_inst(
        .clk(base_clk),
        .reset(reset),
        .cs(1'b1),
        .i_data({toss_cnt, egg_cnt}),
        .o_seg(o_seg),
        .o_sel(o_sel)
    );
endmodule
module SoC (
    input wire base_clk,
    input wire[15:0] opr,
    input wire reset,
    input wire interrupt,
    
    output wire[15:0] leds,
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

    wire[31:0] latest_result;
    wire jitter_elim_interruption;
    wire single_cycle_interrupt;

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

        .opr(opr),
        .result(leds),
        .latest_result(latest_result)
    );

    Core core0(
        .clk(clk_cpu),
        .reset(~reset),
        .cpu_ena(1'b1),
        .out_interruption(single_cycle_interrupt),

        .IMEM_rdata(IMEM_rdata),
        .DMEM_rdata(DMEM_rdata),

        .IMEM_raddr(IMEM_raddr),
        .DMEM_addr(DMEM_addr),
        .fetch_DMEM_addr(fetch_DMEM_addr),
        .DMEM_wdata(DMEM_wdata),
        .DMEM_we(DMEM_we)
    );

    // assign clk_cpu = base_clk;    
    clock clock_inst(
        .clk_in1(base_clk),
        .clk_out1(clk_cpu),
        .resetn(~reset)
    );

    seg7x16 seg7_inst(
        .clk(base_clk),
        .reset(reset),
        .cs(1'b1),
        .i_data(latest_result),
        .o_seg(o_seg),
        .o_sel(o_sel)
    );

    jitter_proc jitter_elim_inst(
        .clk(clk_cpu),
        .reset(~reset),
        .sig_in(interrupt),

        .valid_sig(jitter_elim_interruption)
    );

    gen_inter_cycle inter_cycle_inst(
        .clk(clk_cpu),
        .reset(~reset),
        .sig_in(jitter_elim_interruption),

        .single_cycle_interrupt(single_cycle_interrupt)
    );
endmodule
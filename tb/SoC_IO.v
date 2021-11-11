module SoC (
    input wire base_clk,
    input wire[7:0] opr1,
    input wire[7:0] opr2,
    input wire reset,

    output wire[15:0] result
);

    wire clk_cpu;

    wire[31:0] IMEM_rdata;
    wire[31:0] DMEM_rdata;

    wire[31:0] IMEM_raddr;
    wire[31:0] DMEM_addr;
    wire[31:0] fetch_DMEM_addr;
    wire[31:0] DMEM_wdata;
    wire DMEM_we;

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

        .opr1(opr1),
        .opr2(opr2),
        .result(result)
    );

    CPU core0(
        .clk(clk_cpu),
        .reset(reset),
        .cpu_ena(1'b1),

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
        .resetn(reset)
    );
endmodule
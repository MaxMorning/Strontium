module SoC (
    input wire clk,
    input wire reset,
    input wire system_ena
);

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
        .clk(clk),
        .we(DMEM_we),
        .ask_addr(DMEM_addr),
        .fetch_addr(fetch_DMEM_addr),
        .wdata(DMEM_wdata),

        .rdata(DMEM_rdata)
    );

    Core core0(
        .clk(clk),
        .reset(reset),
        .cpu_ena(system_ena),

        .IMEM_rdata(IMEM_rdata),
        .DMEM_rdata(DMEM_rdata),

        .IMEM_raddr(IMEM_raddr),
        .DMEM_addr(DMEM_addr),
        .fetch_DMEM_addr(fetch_DMEM_addr),
        .DMEM_wdata(DMEM_wdata),
        .DMEM_we(DMEM_we)
    );
    
endmodule
`timescale 1ns/1ps
module soc_tb();
    reg clk;
    reg reset;
    reg[15:0] opr;
    reg interrupt;

    wire[15:0] result;
    wire[7:0] o_seg;
    wire[7:0] o_sel;

    integer blank;
    SoC soc(
        .base_clk(clk),
        .reset(reset),
        .interrupt(interrupt),
        .opr(opr),
        .leds(result),
        .o_seg(o_seg),
        .o_sel(o_sel)
    );

    initial begin
        clk = 0;
        forever begin
            #5 clk = ~clk;
        end
    end

    initial begin
        blank = 0;
        #1
        forever begin
            #10
            if (soc.core0.IMEM_rdata[31:26] == 6'b000100 || soc.core0.IMEM_rdata[31:26] == 6'b000101 || (soc.core0.IMEM_rdata[31:26] == 6'b000000 && soc.core0.IMEM_rdata[5:0] == 6'b001000)) begin
                blank = blank + 1;
            end
            else if (soc.core0.IMEM_rdata[31:26] == 6'b000000 && soc.core0.IMEM_rdata[5:0] == 6'b001100) begin
                blank = blank + 2;
            end
        end
    end
    initial begin
//        $dumpfile("result.vcd");
//        $dumpvars(5);

        reset = 1;
        opr = 32;
        interrupt = 0;

        #106
        reset = 0;

        #30000
        interrupt = 1;

        #80
        interrupt = 0;

        #4000
        interrupt = 1;

        #80
        interrupt = 0;

//        #50000
//        $finish;
    end
    
endmodule
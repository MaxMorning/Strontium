module CP0 (
    input wire clk, // Src : clk
    input wire reset, // Src : reset
    input wire mtc0, // Src : 
    input wire[31:0] pc, // Src : PC.pc_out
    input wire[4:0] raddr, // Src : IR.ir_out[15:10](rd)
    input wire[4:0] waddr,
    input wire[31:0] wdata, // Src : GPR.rdata2(rt)
    input wire exception, // Src : ctrl_cp0_exception
    input wire eret, // Src : ctrl_cp0_eret
    input wire[4:0] cause, // Src : ctrl_cp0_cause

    output reg ans_exception,
    output wire[31:0] rdata, 
    output wire[31:0] exc_addr
);
    reg[31:0] reg_file[31:0];

    assign rdata = reg_file[raddr];
    assign status = reg_file[12];

    assign exc_addr = exception ? (reg_file[12][0] ? 32'h00400004 : pc)
                        : (eret ? reg_file[14] : pc);

    integer i;
    always @(posedge clk or negedge reset) begin
        if (~reset) begin
            ans_exception <= 0;
            for (i = 0; i < 32; i = i + 1) begin
                if (i != 12)
                    reg_file[i] <= 32'h0;
                else
                    reg_file[12] <= 32'h1;
            end
        end
        else if (mtc0) begin
            reg_file[waddr] <= wdata;
            ans_exception <= 0;
        end
        else if (exception) begin
            if (reg_file[12][0]) begin
                reg_file[12][0] <= 1'b0;
                reg_file[13][6:2] <= cause;
                reg_file[14] <= pc;
                ans_exception <= 1;
            end
            else begin
                ans_exception <= 0;
            end
        end 
        else begin
            ans_exception <= 0;
            if (eret) begin
                reg_file[12][0] <= 1'b1;
            end
        end
    end

endmodule
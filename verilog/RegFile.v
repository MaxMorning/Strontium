module RegFile (
    input wire clk,
    input wire reset,
    input wire we,
    input wire[4:0] raddr1,
    input wire[4:0] raddr2,
    input wire[4:0] waddr,
    input wire[31:0] wdata,

    output wire[31:0] rdata1,
    output wire[31:0] rdata2
);
    (* max_fanout = "4" *) reg[31:0] array_reg[31:0];
    wire[31:0] rdata1_ori = array_reg[raddr1];
    wire[31:0] rdata2_ori = array_reg[raddr2];

    // through read
    wire waddr_not_zero = we & (| waddr);
    assign rdata1 = ((waddr == raddr1) & waddr_not_zero) ? wdata : rdata1_ori;
    assign rdata2 = ((waddr == raddr2) & waddr_not_zero) ? wdata : rdata2_ori;

    integer i;
    always @(posedge clk or negedge reset) begin
        if (!reset) begin
            for (i = 0; i < 32; i = i + 1) begin
                array_reg[i] <= 32'h0;
            end
        end
        else if (we && waddr != 4'b0000) begin
            array_reg[waddr] <= wdata;
        end
    end
endmodule
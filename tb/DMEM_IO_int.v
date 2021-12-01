module DMEM (
    input wire clk,
    input wire we,
    input wire[31:0] ask_addr,
    input wire[31:0] fetch_addr,
    input wire[31:0] wdata,
    
    output wire[31:0] rdata,


    input wire[15:0] opr,
    output wire[31:0] result
);
    wire[31:0] bram_result;
    wire bram_we = ~ask_addr[31] & we;

    reg[15:0] opr_reg;

    assign rdata = fetch_addr[31] ? {16'h0, opr_reg}
                    : bram_result;

    // assign rdata = bram_result;

    reg[31:0] display_result;
    assign result = display_result;

    bram bram_inst (
        .clka(clk),    // input wire clka
        // .ena(1'b1),      // input wire ena
        .wea(bram_we),      // input wire [0 : 0] wea
        .addra(ask_addr[17:2]),  // input wire [13 : 0] addra
        .dina(wdata),    // input wire [31 : 0] dina
        .douta(bram_result)  // output wire [31 : 0] douta
    );

    always @(posedge clk) begin
        if (we) begin
            if (ask_addr[31] & ask_addr[3]) begin
                display_result <= wdata;
            end
        end

        opr_reg <= opr;
    end
endmodule
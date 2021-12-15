module DMEM (
    input wire clk,
    input wire we,
    input wire[31:0] ask_addr,
    input wire[31:0] fetch_addr,
    input wire[31:0] wdata,
    
    output wire[31:0] rdata,


    input wire[7:0] opr1,
    input wire[7:0] opr2,
    output reg[15:0] toss_cnt,
    output reg[15:0] egg_cnt,
    output reg[15:0] is_egg_break
);
    wire[31:0] bram_result;
    wire bram_we = ~ask_addr[31] & we;

    reg[7:0] opr1_reg;
    reg[7:0] opr2_reg;

    assign rdata = fetch_addr[31] ? (fetch_addr[2] ? {24'h0, opr2_reg} : {24'h0, opr1_reg})
                    : bram_result;

    // assign rdata = bram_result;

    reg[15:0] display_result;
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
            if (ask_addr[31]) begin
                case (ask_addr[4:0])
                    5'h08:
                        begin
                            toss_cnt <= wdata;
                        end

                    5'h0c:
                        begin
                            egg_cnt <= wdata;
                        end

                    5'h10:
                        begin
                            is_egg_break <= wdata;
                        end
                endcase
                display_result <= wdata[15:0];
            end
        end

        opr1_reg <= opr1;
        opr2_reg <= opr2;
    end
endmodule
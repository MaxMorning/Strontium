module bram (
    input wire clka,    // input wire clka
    input wire ena,      // input wire ena
    input wire wea,      // input wire [0 : 0] wea
    input wire[13:0] addra,  // input wire [13 : 0] addra
    input wire[31:0] dina,    // input wire [31 : 0] dina
    output wire[31:0] douta  // output wire [31 : 0] douta
);
    reg[31:0] component[0:8191];

    assign douta = component[addra[12:0]];

    always @(posedge clka) begin
        if (wea) begin
            component[addra[12:0]] <= dina;
        end
    end
endmodule
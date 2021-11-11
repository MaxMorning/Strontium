module PC (
    input wire clk,
    input wire reset,
    input wire we,

    input wire[31:0] pc_in,

    output reg[31:0] pc_out
);
    
    always @(posedge clk or negedge reset) begin
        if (!reset) begin
            pc_out <= 32'h00400000;
        end
        else if (we) begin
            pc_out <= pc_in;
        end
    end
endmodule
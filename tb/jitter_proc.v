module jitter_proc (
    input wire clk,
    input wire reset,
    input wire sig_in,

    output wire valid_sig
);
    reg[3:0] buffer;

    assign valid_sig = & buffer;

    always @(posedge clk or negedge reset) begin
        if (~reset) begin
            buffer <= 0;
        end
        else begin
            buffer <= {buffer[2:0], sig_in};
        end
    end
endmodule
module gen_inter_cycle (
    input wire clk,
    input wire reset,
    input wire sig_in,

    output wire single_cycle_interrupt
);

    reg prev_inter;

    assign single_cycle_interrupt = ~prev_inter & sig_in;

    always @(posedge clk or negedge reset) begin
        if (~reset) begin
            prev_inter <= 0;
        end
        else begin
            prev_inter <= sig_in;
        end
    end
endmodule
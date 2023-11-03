`default_nettype none

module hh  (
    input wire [7:0] stim_current,
    input wire clk,
    input wire rst_n,
    output reg [7:0] state,
    output wire [7:0] spike );

    reg [7:0] threshold, n;
    wire [7:0] next_state, current, next_n;
    // V = I/c

    assign current = stim_current - (((n)*n*(state - -50)) >> 3) - (((n)*(state - 77)) >> 4) - ((state - 54) >> 2);
    // state(t+1) = state(t) + current*dt
    assign next_state = (spike[0] ? 0 : (state)) + (current >> 2);
    assign spike = {7'b0, state>= threshold};


    // (Vm*(1-n)*(a_n) - (V_m)*n*beta_n)*dt
    assign next_n = n + (((state*(1-n)) >> 2 - (state*n) >> 2) >> 2); // replace states w/ alpha(state)
    

    always @(posedge clk) begin
        if (!rst_n) begin
            state <= 0;
            threshold <= 50;
            n <= 8'b0000_1000;
        end
        else begin
            state <= next_state;
            n <= next_n;
        end
    end

endmodule

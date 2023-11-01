`default_nettype none

module hh #(parameter EXP = 8'b0010_1011) (
    input wire [7:0] stim_current,
    input wire clk,
    input wire rst_n,
    output reg [7:0] state,
    output wire [7:0] spike );

    reg [7:0] next_state, threshold, current, INa, IK, IKleak, m_alph, m_beta, m_act, h_alph, h_beta, h_act, n_alph, n_beta, n_act;

    // V = I/c
    // Check if activation changes per time step
    // Make constants parameters in model declaration

    assign m_alph = ((25 - state) / (EXP**((25 - state) >> 3) - 1)) >> 3;
    assign m_beta = 4 * EXP**(-state >> 4);
    assign m_act = m_alph / (m_alph + m_beta);

    assign h_alph = EXP**(-state >> 4) >> 3;
    assign h_beta = 1 / (EXP**((30 - state) >> 3) + 1);
    assign h_act = h_alph / (h_alph + h_beta);

    assign n_alph = ((10 - state) / (EXP**((10 - state) >> 3) - 1)) >> 7;
    assign n_beta = EXP*(-state >> 6) >> 3;
    assign n_act = n_alph / (n_alph + n_beta);

    assign INa = ((state - -50)) >> 3;
    assign IK = ((state - 77)) >> 4;
    assign IKleak = (state - 54) >> 2;

    assign current = stim_current - INa - IK - IKleak;
    assign next_state = state + (current)>>2;
    assign spike = (state >= threshold);

    always @(posedge clk) begin
        if (!rst_n) begin
            state <= 0;
            threshold <= 32;
        end
        else begin
            state <= next_state;
        end
    end

endmodule
//------------------------------------------------------------------------------
// traffic_light_fsm.v
// Two-direction intersection FSM (NS/EW).
// States:
//   NS_GREEN -> NS_AMBER -> ALL_RED1 -> EW_GREEN -> EW_AMBER -> ALL_RED2 -> repeat
//
// Outputs are one-hot per color per direction; no conflicting greens.
// Durations are in 'ticks' (from tick_gen or any enable pulse).
//------------------------------------------------------------------------------
`timescale 1ns/1ps

module traffic_light_fsm #(
    parameter integer T_NS_GREEN = 10,  // ticks
    parameter integer T_NS_AMBER = 3,
    parameter integer T_ALL_RED  = 1,
    parameter integer T_EW_GREEN = 10,
    parameter integer T_EW_AMBER = 3
)(
    input  wire clk,
    input  wire rst,       // synchronous, active-high
    input  wire tick,      // advance-time enable pulse (1-cycle)

    // North-South lights
    output reg  ns_red,
    output reg  ns_amber,
    output reg  ns_green,

    // East-West lights
    output reg  ew_red,
    output reg  ew_amber,
    output reg  ew_green,

    // Optional: expose state for debug/sim
    output reg [2:0] state
);
    // State encoding
    localparam [2:0]
        S_NS_GREEN = 3'd0,
        S_NS_AMBER = 3'd1,
        S_ALL_RED1 = 3'd2,
        S_EW_GREEN = 3'd3,
        S_EW_AMBER = 3'd4,
        S_ALL_RED2 = 3'd5;

    // Countdown timer in ticks
    reg [31:0] timer;

    // Next-state and load value
    reg [2:0]  state_n;
    reg [31:0] load_ticks;
    reg        load_timer;

    // Output decode
    always @(*) begin
        // default all OFF
        ns_red   = 1'b0; ns_amber = 1'b0; ns_green = 1'b0;
        ew_red   = 1'b0; ew_amber = 1'b0; ew_green = 1'b0;

        case (state)
            S_NS_GREEN: begin
                ns_green = 1'b1;
                ew_red   = 1'b1;
            end
            S_NS_AMBER: begin
                ns_amber = 1'b1;
                ew_red   = 1'b1;
            end
            S_ALL_RED1,
            S_ALL_RED2: begin
                ns_red = 1'b1;
                ew_red = 1'b1;
            end
            S_EW_GREEN: begin
                ew_green = 1'b1;
                ns_red   = 1'b1;
            end
            S_EW_AMBER: begin
                ew_amber = 1'b1;
                ns_red   = 1'b1;
            end
            default: begin
                ns_red = 1'b1;
                ew_red = 1'b1;
            end
        endcase
    end

    // Next-state / timer control
    always @(*) begin
        // Defaults
        state_n    = state;
        load_timer = 1'b0;
        load_ticks = 32'd0;

        case (state)
            S_NS_GREEN: begin
                if (timer == 0) begin
                    state_n    = S_NS_AMBER;
                    load_timer = 1'b1;
                    load_ticks = T_NS_AMBER;
                end
            end
            S_NS_AMBER: begin
                if (timer == 0) begin
                    state_n    = S_ALL_RED1;
                    load_timer = 1'b1;
                    load_ticks = T_ALL_RED;
                end
            end
            S_ALL_RED1: begin
                if (timer == 0) begin
                    state_n    = S_EW_GREEN;
                    load_timer = 1'b1;
                    load_ticks = T_EW_GREEN;
                end
            end
            S_EW_GREEN: begin
                if (timer == 0) begin
                    state_n    = S_EW_AMBER;
                    load_timer = 1'b1;
                    load_ticks = T_EW_AMBER;
                end
            end
            S_EW_AMBER: begin
                if (timer == 0) begin
                    state_n    = S_ALL_RED2;
                    load_timer = 1'b1;
                    load_ticks = T_ALL_RED;
                end
            end
            S_ALL_RED2: begin
                if (timer == 0) begin
                    state_n    = S_NS_GREEN;
                    load_timer = 1'b1;
                    load_ticks = T_NS_GREEN;
                end
            end
            default: begin
                state_n    = S_NS_GREEN;
                load_timer = 1'b1;
                load_ticks = T_NS_GREEN;
            end
        endcase
    end

    // Sequential: state & timer
    always @(posedge clk) begin
        if (rst) begin
            state <= S_NS_GREEN;
            timer <= T_NS_GREEN;
        end else begin
            state <= state_n;

            if (load_timer) begin
                timer <= (load_ticks > 0) ? (load_ticks - 1) : 0;
            end else if (tick) begin
                if (timer != 0)
                    timer <= timer - 1'b1;
            end
        end
    end
endmodule

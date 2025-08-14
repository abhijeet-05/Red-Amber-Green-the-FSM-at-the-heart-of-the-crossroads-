//------------------------------------------------------------------------------
// top_crossroads.v
// Integrates tick_gen and traffic_light_fsm.
// For FPGA: set DIVISOR to your board clock (e.g., 50e6 for 50 MHz -> 1 Hz tick).
// For simulation, you can override parameters with small numbers.
//------------------------------------------------------------------------------
`timescale 1ns/1ps

module top_crossroads #(
    // Clock divider for tick
    parameter integer DIVISOR     = 50_000_000, // 50 MHz -> 1 Hz
    // Phase durations in ticks (with 1 Hz tick, these are seconds)
    parameter integer P_NS_GREEN  = 10,
    parameter integer P_NS_AMBER  = 3,
    parameter integer P_ALL_RED   = 1,
    parameter integer P_EW_GREEN  = 10,
    parameter integer P_EW_AMBER  = 3
)(
    input  wire clk,
    input  wire rst,   // synchronous

    // Light outputs
    output wire ns_red,
    output wire ns_amber,
    output wire ns_green,
    output wire ew_red,
    output wire ew_amber,
    output wire ew_green,

    // Optional debug
    output wire [2:0] state
);
    wire tick;

    tick_gen #(
        .DIVISOR(DIVISOR)
    ) u_tick (
        .clk (clk),
        .rst (rst),
        .tick(tick)
    );

    traffic_light_fsm #(
        .T_NS_GREEN(P_NS_GREEN),
        .T_NS_AMBER(P_NS_AMBER),
        .T_ALL_RED (P_ALL_RED),
        .T_EW_GREEN(P_EW_GREEN),
        .T_EW_AMBER(P_EW_AMBER)
    ) u_fsm (
        .clk(clk),
        .rst(rst),
        .tick(tick),
        .ns_red  (ns_red),
        .ns_amber(ns_amber),
        .ns_green(ns_green),
        .ew_red  (ew_red),
        .ew_amber(ew_amber),
        .ew_green(ew_green),
        .state(state)
    );
endmodule

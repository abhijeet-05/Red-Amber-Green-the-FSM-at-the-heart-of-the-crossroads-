//------------------------------------------------------------------------------
// tick_gen.v
// Clock divider that generates a 1-cycle-wide 'tick' pulse every DIVISOR cycles.
//------------------------------------------------------------------------------
`timescale 1ns/1ps

module tick_gen #(
    parameter integer DIVISOR = 50_000_000  // e.g., 50 MHz -> 1 Hz tick
)(
    input  wire clk,
    input  wire rst,       // synchronous, active-high
    output reg  tick       // 1-cycle pulse
);
    localparam integer W = $clog2(DIVISOR);
    reg [W-1:0] cnt;

    always @(posedge clk) begin
        if (rst) begin
            cnt  <= {W{1'b0}};
            tick <= 1'b0;
        end else begin
            if (cnt == DIVISOR-1) begin
                cnt  <= {W{1'b0}};
                tick <= 1'b1;
            end else begin
                cnt  <= cnt + 1'b1;
                tick <= 1'b0;
            end
        end
    end
endmodule

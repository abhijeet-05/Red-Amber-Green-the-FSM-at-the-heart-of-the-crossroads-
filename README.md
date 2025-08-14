# Red-Amber-Green-the-FSM-at-the-heart-of-the-crossroads-
leveraging the power of finite state machines , fundamentsl concepts in digital systems and emmbedded design 
# Red, Amber, Green: the FSM at the Heart of the Crossroads (Verilog)

Two-road intersection traffic controller (NS/EW) in synthesizable Verilog.
Sequence: NS_GREEN → NS_AMBER → ALL_RED → EW_GREEN → EW_AMBER → ALL_RED → …

- Synth-ready RTL (`rtl/`)
- Parametric durations (in ticks)
- Single tick-per-second (configurable) generator
- Top module for FPGA or sim
- Self-contained testbench (`sim/`) for Icarus Verilog + GTKWave


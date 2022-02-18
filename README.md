# svMIPS
A single-cycle MIPS process designed in SystemVerilog


## Usage
Any HDL simulator which supports SystemVerilog can be used to simulate the CPU. The programs folder provides a few sample programs which can be loaded into the instruction memory.

[Verilator](https://www.veripool.org/verilator/) can also be used to simulate the CPU. The test directory defines a small test setup, and the `simulate.sh` script will compile and simulate that testbench.

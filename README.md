# 5-stage-pipelined-cpu-design

This project is a 64-bit ARM-style pipelined CPU built in Verilog. It follows a 5-stage pipeline (Fetch, Decode, Execute, Memory, Writeback) and includes data forwarding to handle common pipeline hazards. The design supports a small RISC-like instruction set with basic ALU operations, branching, and memory access. Special care is taken to handle register x31 as the zero register, implement delay slots for load and branch instructions, and manage hazard resolution efficiently.

The CPU is built from modular components like an ALU, register file, control unit, and forwarding logic. It runs pre-written test programs loaded into memory and displays updated register contents after execution. This project focuses on getting the core pipelined execution right and sets the foundation for future features like hazard detection and branch prediction.

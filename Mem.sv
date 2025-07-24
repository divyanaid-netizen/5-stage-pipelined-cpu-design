`timescale 1ns/10ps

module Mem (clk, reset, address, MemWrite, MemRead, MemWriteData, MemOut, Memxfer_size, MemToReg);
    // Input logic (Memory Operation Signal & Address, Data)
    input  logic        clk, reset, MemWrite, MemRead, MemToReg;
    input  logic [63:0] address, MemWriteData;
	 input  logic [3:0] Memxfer_size;
    
    // Output Logic (Data in the memory)
    output logic [63:0] MemOut;
	 logic [63:0] memoryOut, memoryaddr;

    datamem DM (.address, .write_enable(MemWrite), .read_enable(MemRead), .write_data(MemWriteData), .clk, .xfer_size(Memxfer_size), .read_data(memoryOut));
	zeroExtend #(.WIDTH(8)) LDURBExtend(.in(memoryOut[7:0]), .out(memoryaddr));
	mux2_64b theMemToRegMux (.A(memoryOut), .B(memoryaddr), .sel(MemToReg), .out(MemOut));

endmodule
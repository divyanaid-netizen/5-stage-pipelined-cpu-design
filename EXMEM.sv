`timescale 1ns/10ps

module EXMEM (clk, reset, 
                    ExMem2Reg, ExRegWrite, ExMemWrite, Exxfer_size,
                    ExMemRead, ExAw, ExDb, ExALUOut,
                    
                    MemMem2Reg, MemRegWrite, MemMemWrite, Memxfer_size,
                    MemMemRead, MemAw, MemDb, MemALUOut);
                    

    // Input Logic
    input  logic        clk, reset;
    input  logic [63:0] ExDb, ExALUOut;
    input  logic [4:0]  ExAw;
	 input  logic [3:0] Exxfer_size;
    input  logic        ExMem2Reg, ExMemWrite, ExMemRead, ExRegWrite;

    // Output Logic
    output logic [63:0] MemDb, MemALUOut;
    output logic [4:0]  MemAw;
	 output logic [3:0] Memxfer_size;
    output logic        MemMem2Reg, MemMemWrite, MemMemRead, MemRegWrite;

    // Register Instantiation
    register ALUOutReg (.reset, .clk, .data_in(ExALUOut), .data_out(MemALUOut), .write_en(1'b1));
    register DbReg (.reset, .clk, .data_in(ExDb), .data_out(MemDb), .write_en(1'b1));
	 
    // Register Address Register Instantiation
    register #(.N(5)) RdReg (.reset, .clk, .data_in(ExAw), .data_out(MemAw), .write_en(1'b1));
	 register #(.N(4)) xfer (.reset, .clk, .data_in(Exxfer_size), .data_out(Memxfer_size), .write_en(1'b1));
	 
    D_FF Mem2Reg(.q(MemMem2Reg), .d(ExMem2Reg), .reset, .clk);
    D_FF MemWriteReg (.q(MemMemWrite), .d(ExMemWrite), .reset, .clk);
    D_FF MemReadReg (.q(MemMemRead), .d(ExMemRead), .reset, .clk);
    D_FF RegWriteReg (.q(MemRegWrite), .d(ExRegWrite), .reset, .clk);

endmodule
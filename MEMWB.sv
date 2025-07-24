`timescale 1ns/10ps
module MEMWB (clk, reset, MemAw, MemALUOut, MemMem2Reg, MemRegWrite, MemOut, 
                        WbAw, WbDataToReg, WbRegWrite, WbMuxOut);
    
    // Input Logic (Data & Control Signal)
   input  logic        clk, reset;
	input  logic 		  MemRegWrite, MemMem2Reg;
   input  logic [4:0]  MemAw;
   input  logic [63:0] MemOut, MemALUOut;

    // Output Logic (Data & Control Signal)
	output logic 		WbRegWrite;
	output logic [4:0]  WbAw;
   output logic [63:0] WbDataToReg, WbMuxOut;
	
	mux2_64b MuxRegWriteBack (.sel(MemMem2Reg), .A(MemALUOut), .B(MemOut), .out(WbMuxOut));
	 
	register #(.N(64)) WbDataReg (.reset, .clk, .data_in(WbMuxOut), .data_out(WbDataToReg), .write_en(1'b1));
   register #(.N(5)) RdReg (.reset, .clk, .data_in(MemAw), .data_out(WbAw), .write_en(1'b1));

   D_FF RegWriteReg (.q(WbRegWrite), .d(MemRegWrite), .reset, .clk);

endmodule


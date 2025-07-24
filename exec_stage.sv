`timescale 1ns/10ps

module exec_stage (clk, reset,
						ExDa, ExDb, ExALUSrc, Eximmselect, ExALUOp, ExFlagWrite, ExImm12Ext, ExDAddr9Ext, 
						ExALUOut, ExOverflow, ExNegative, ExZero, ExCarryout, BLTBrTaken);
	parameter DELAY = 0.05;
   // Input Logic
	input  logic [63:0] ExDa, ExDb, ExImm12Ext, ExDAddr9Ext;
	input  logic [2:0]  ExALUOp;
   input  logic  ExALUSrc, Eximmselect;
   input  logic  ExFlagWrite, clk, reset;

   // Output Logic 
	output logic [63:0] ExALUOut;
	output logic 		ExOverflow, ExNegative, ExZero, ExCarryout, BLTBrTaken;

	// Intermediate Logic
	logic overflow, negative, zero, carry_out;
	logic NotExFlagWrite, XorExNegOver, XorNegOver, AndFlagWriteXor, AndNotFlagWriteXor;
	
	logic [63:0] Imm_value;
	mux2_64b imm_select_mux (.out(Imm_value), .A(ExDAddr9Ext), .B(ExImm12Ext), .sel(Eximmselect));
	
	// ALUSrc MUX
	logic [63:0] alub_input;
	mux2_64b Alu_src_mux (.out(alub_input), .A(ExDb), .B(Imm_value), .sel(ExALUSrc));
	
//	// ALUSrc
//	logic [63:0] alub_input;
//	mux4_64b Alu_src_mux (.sel({ExALUSrc, Eximmselect}), .A(ExDAddr9Ext), .B(ExImm12Ext), .C(ExDb), .D(64'b1), .out(alub_input));
//	
	
	// Put information into ALU
	ALU_64b theALU (.A(ExDa), .B(alub_input), .cntrl(ExALUOp), .result(ExALUOut), 
							.negative(negative), .zero(zero), .overflow(overflow), .carry_out(carry_out));
	
	// 1b registers for flags
	eDFF forZero (.d(zero), .q(ExZero), .en(ExFlagWrite), .clk, .reset);
	eDFF forNegative (.d(negative), .q(ExNegative), .en(ExFlagWrite), .clk, .reset);
	eDFF forCarryout (.d(carry_out), .q(ExCarryout), .en(ExFlagWrite), .clk, .reset);
	eDFF forOverflow (.d(overflow), .q(ExOverflow), .en(ExFlagWrite), .clk, .reset);
	
   // BLTBRTaken Logic: (~ExFlagWrite & (ExNegative ^ ExOverflow)) | (ExFlagWrite & (negative ^ overflow))
   not #DELAY n0 (NotExFlagWrite, ExFlagWrite);
	xor #DELAY x0 (XorExNegOver, ExNegative, ExOverflow);
	and #DELAY a1 (AndNotFlagWriteXor, NotExFlagWrite, XorExNegOver);
	
	xor #DELAY x1 (XorNegOver, negative, overflow);
	and #DELAY a0 (AndFlagWriteXor, ExFlagWrite, XorNegOver);
	
	or  #DELAY o0 (BLTBrTaken, AndFlagWriteXor, AndNotFlagWriteXor);
	
endmodule 
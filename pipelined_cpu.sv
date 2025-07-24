`timescale 1ns/10ps
module pipelined_cpu(clk, reset);
input logic clk, reset;

	logic [31:0] fetch_instruction;
	logic [63:0] link_register, register_branch, fetch_pc, branch_address;
	logic [2:0] ALUOp;
	logic Reg2Loc, RegWrite, ALUSrc, imm_select, MemToReg, MemRead, MemWrite, UncondBr, DecBrTaken, flagset, blink_sig, breg_sig;
	logic negative, overflow, carry_out, BLTxorResult;
	// Instruction Fetch code 
	Instr_to_addr  fetchInstruction(.currentPC(fetch_pc), .instruction(fetch_instruction), .branch_address, .register_branch, 
												.clk, .reset, .BrTaken(DecBrTaken), .UncondBr, .blink_sig, .link_register, .breg_sig);

	//Fetch -> Dec Register
	logic [63:0] DecPC;
	logic [31:0] DecInst;
	
	IFIDReg theInstReg (.IF_PC(fetch_pc), .IF_instruction(fetch_instruction), .ID_PC(DecPC), .ID_instruction(DecInst), .clk, .reset);
	
	//Control Signals
	logic [3:0] Decxfer_size;
	logic [2:0] DecALUOp;
	logic DecALUSrc, Decimmselect;
   logic 		DecMem2Reg, DecReg2Loc, DecRegWrite, DecMemWrite, DecMemRead, DecUncondBr, DecFlagWrite, DecZero, BLTBrTaken, 
	            ExOverflow, ExNegative, ExCarryout, DecLDURB;		

	control_unit control_signals (.opcode(DecInst[31:21]), .ALUOp(DecALUOp), .ALUSrc(DecALUSrc), .MemToReg(DecMem2Reg),.BrTaken(DecBrTaken), 
	                                 .Reg2Loc(DecReg2Loc),.RegWrite(DecRegWrite), .MemWrite(DecMemWrite), .MemRead(DecMemRead), 
												.UncondBr(DecUncondBr), .negative(ExNegative), .overflow(ExOverflow), .zero(DecZero), .carry_out(ExCarryout), 
												.flagset(DecFlagWrite), .xfer_size(Decxfer_size), .imm_select(Decimmselect), .blink_sig, .breg_sig, .BLTxorResult);
												
	//Forwarding Unit
	logic [4:0] DecAa, DecAb, ExAw, MemAw;
	logic [1:0] ForwardA, ForwardB;
	logic		ExRegWrite, MemRegWrite, WbRegWrite;
	ForwardingUnit theFwdUnit (.DecAa, .DecAb, .ExAw, .MemAw, .ExRegWrite, .MemRegWrite, .ForwardA, .ForwardB);
	
	//Decode Stage
	logic [63:0] DecDa, DecDb, DecImm12Ext, DecDAddr9Ext;
	logic [4:0]  DecAw, WbAw;
	logic [63:0] WbDataToReg, WbMuxOut, ExALUOut;
	
	reg_decode_stage dec_stage (.clk, .reset, .DecPC, .DecInst, .DecReg2Loc, .DecUncondBr,
											 .WbDataToReg, .WbRegWrite, .WbAw, .DecAa, .DecAb, .DecAw, .DecDa, .DecDb, .DecImm12Ext, 
											 .DecDAddr9Ext, .DecBranchPC(branch_address), .ForwardA, .ForwardB, .ExALUOut, .WbMuxOut,
											 .DecZero, .link_register, .blink_sig, .register_branch);
	
	//Dec -> Exec Register
	logic [63:0] ExDa, ExDb, ExImm12Ext, ExDAddr9Ext;
	logic [31:0] ExcInst;
	logic [2:0]  ExALUOp;
	logic ExALUSrc, Eximmselect;
	logic [3:0] Exxfer_size;
   logic 		 ExMem2Reg, ExMemWrite, ExMemRead, ExFlagWrite;
	
	IDEXReg theDecReg (.clk, .reset,
									  .DecALUOp, .DecALUSrc, .Decimmselect, .DecMem2Reg, 
									  .DecRegWrite, .DecMemWrite, .DecMemRead, .DecFlagWrite, .Decxfer_size,
									  .DecAw, .DecDa, .DecDb, .DecImm12Ext, .DecDAddr9Ext,
									   
									  .ExALUOp, .ExALUSrc, .Eximmselect, .ExMem2Reg, 
									  .ExRegWrite, .ExMemWrite, .ExMemRead, .ExFlagWrite, .Exxfer_size,
									  .ExAw, .ExDa, .ExDb, .ExImm12Ext, .ExDAddr9Ext);
	// Execute Stage
	logic ExZero;
	exec_stage theExStage(.clk, .reset, .ExDa, .ExDb, .ExALUSrc, .Eximmselect, .ExALUOp, .ExFlagWrite, .ExImm12Ext, .ExDAddr9Ext,
							 .ExALUOut, .ExOverflow, .ExNegative, .ExZero, .ExCarryout, .BLTBrTaken(BLTxorResult));
							 
	//Exec -> Mem Register
	logic [63:0] MemDb, MemALUOut;
	logic [3:0] Memxfer_size;
	logic 		 MemMem2Reg, MemMemWrite, MemMemRead;
	
	EXMEM theExReg (.clk, .reset, 
								  .ExMem2Reg, .ExRegWrite, .ExMemWrite, 
								  .ExMemRead, .ExAw, .ExDb, .ExALUOut, .Exxfer_size,
								  
								  .MemMem2Reg, .MemRegWrite, .MemMemWrite, 
								  .MemMemRead, .MemAw, .MemDb, .MemALUOut, .Memxfer_size);
								  
	//Memory Stage 
	logic [63:0] MemOut;
	
	Mem mem_stage(.clk, .reset, 
						.address(MemALUOut), .MemWrite(MemMemWrite), .MemRead(MemMemRead), .MemWriteData(MemDb), 
						.MemOut, .Memxfer_size, .MemToReg(MemMem2Reg));
	
	
	//Mem -> WB Register
	MEMWB theMemWBReg(.clk, .reset, 
							 .MemAw, .MemALUOut, .MemMem2Reg, .MemRegWrite, .MemOut, 
							 .WbAw, .WbDataToReg, .WbRegWrite, .WbMuxOut);
									  

endmodule


module cpu_tb(); 		
	logic clk, reset;
	pipelined_cpu dut(.clk, .reset);
	
	parameter CLOCK_PERIOD=500;
	initial begin
	clk <= 0;
	forever #(CLOCK_PERIOD/2) clk <= ~clk;
	end
	
	int i;
	
   initial begin
	
	reset = 1; @(posedge clk);
	   reset = 0; @(posedge clk);
		           @(posedge clk);
		for (i=0; i<500; i++) begin
			@(posedge clk);
		end
		$stop;
	end
endmodule

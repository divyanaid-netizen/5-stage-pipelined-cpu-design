 `timescale 1ns/10ps

module reg_decode_stage (clk, reset, DecPC, DecInst, DecReg2Loc, DecUncondBr,
 WbDataToReg, WbRegWrite, WbAw, DecAa, DecAb, DecAw, DecDa, DecDb, DecImm12Ext, DecDAddr9Ext, 
 DecBranchPC, ForwardA, ForwardB, ExALUOut, WbMuxOut, DecZero, link_register, blink_sig, register_branch);
	 parameter DELAY = 0.05;
    // Input Logic (clk & Control Signals)
    input  logic        clk, reset, DecReg2Loc, DecUncondBr, WbRegWrite, blink_sig;
    input  logic [63:0] DecPC, WbDataToReg, ExALUOut, WbMuxOut, link_register;
    input  logic [31:0] DecInst;
	 input  logic [4:0] WbAw;
	 input logic [1:0] ForwardA, ForwardB;

    // Output Logic (Register Data , Register Address, Signed-extended constants)
    output logic [63:0] DecDa, DecDb;
    output logic [4:0]  DecAa, DecAb, DecAw;
    output logic [63:0] DecDAddr9Ext, DecImm12Ext, DecBranchPC, register_branch;
	 output logic 			DecZero;
	 
	 assign DecAa = DecInst[9:5];
	 assign DecAw = DecInst[4:0];

    // Reg2Loc Mux
	// Determines which register address gets used for Ab in the register file (Rd or Rm)
	mux_5w2to1 Reg2LocMux (.A(DecInst[20:16]), .B(DecInst[4:0]), .sel(DecReg2Loc), .out(DecAb));
	
	 /* Register File for the CPU 
	  * ReadData1 = DecDa, ReadData2 = Db, WriteData = Dw
	  * Regfile will be updated at WB stage
	  * RegWrite will signal whether or not it's ID or WB stage
	  */
	 not #DELAY n1 (clkbar,clk);
	 logic [63:0] RegDa, RegDb;
	 
	 registerfile register_bank (.ReadData1(RegDa), .ReadData2(RegDb), .WriteData(WbDataToReg)
								, .ReadRegister1(DecAa), .ReadRegister2(DecAb), .WriteRegister(WbAw)
								, .RegWrite(WbRegWrite), .clk(clkbar), .reset(reset), .link_register, .blink_sig);
	 assign register_branch = RegDb;
	 mux4_64b FwdAMux (.sel(ForwardA), .A(RegDa), .B(ExALUOut), .C(WbMuxOut), .D(64'bx), .out(DecDa));
	 mux4_64b FwdBMux (.sel(ForwardB), .A(RegDb), .B(ExALUOut), .C(WbMuxOut), .D(64'bx), .out(DecDb));
	 
	 zeroF checkDbforzero (.in(DecDb), .zeroFlag(DecZero));
	 
   // Sign extend for DAddr9
	signExtend #(.WIDTH(9)) DAddr9(.in(DecInst[20:12]), .out(DecDAddr9Ext));
	// Zero extend for Imm12
	zeroExtend #(.WIDTH(12)) Imm12(.in(DecInst[21:10]), .out(DecImm12Ext));
	
//	logic [63:0] Imm_value;
//	mux2_64b imm_select_mux (.out(Imm_value), .A(DAddr9_extended), .B(Imm12Extended), .sel(imm_select));
	
	logic [63:0] BrAddr26_extended, CondAddr19_extended, sign_extended_branchaddr;
	signExtend #(.WIDTH(25-0+1)) BrAddr26(.in(DecInst[25:0]), .out(BrAddr26_extended));	
	signExtend #(.WIDTH(23-5+1)) CondAddr19(.in(DecInst[23:5]), .out(CondAddr19_extended));
	mux2_64b mem_to_reg_mux (.out(sign_extended_branchaddr), .A(CondAddr19_extended), .B(BrAddr26_extended), .sel(DecUncondBr));
	
	logic [63:0] sign_extended_branchaddr_out;
	eDFF delayed_imm_value (.d(sign_extended_branchaddr), .q(sign_extended_branchaddr_out), .en(ExFlagWrite), .clk, .reset);
	
	logic [63:0] shifted_address;
	shift_left_2 lsl1(.in(sign_extended_branchaddr), .out(shifted_address));	
	address_adder pc_adder2 (.A(DecPC), .B(shifted_address), .sum(DecBranchPC));
	
	
	// TODO: add BL BR logic here
//
//     
//
//

endmodule











`timescale 1ns/10ps

module IFIDReg(clk, reset, IF_PC, ID_PC, IF_instruction, ID_instruction);
	input logic clk, reset;
	input logic [31:0] IF_instruction;
	input logic [63:0] IF_PC;
	output logic [31:0] ID_instruction;
	output logic [63:0] ID_PC;
	
	register #(.N(64)) PCReg (.data_in(IF_PC), .data_out(ID_PC), .reset, .clk, .write_en(1'b1));
	register #(.N(32)) InstReg (.data_in(IF_instruction), .data_out(ID_instruction), .reset, .clk, .write_en(1'b1));
	
endmodule

module IFIDReg_tb();
	logic clk, reset;
	logic [31:0] IF_instruction;
	logic [63:0] IF_PC;
	logic [31:0] ID_instruction;
	logic [63:0] ID_PC;
	
	IFIDReg dut(.clk, .reset, .IF_PC, .ID_PC, .IF_instruction, .ID_instruction);
	
	parameter CLOCK_PERIOD = 100; 
	
		initial begin 
	
		clk <= 0;
	
		forever #(CLOCK_PERIOD/2) clk <= ~clk;
 
		end
		
	initial begin
	
		reset <= 1;																																	
		@(posedge clk)	
		reset <= 0; IF_instruction <= 32'd1996; IF_PC <= 64'd9999313;																
		@(posedge clk)
		reset <= 0; IF_instruction <= 32'd1998; IF_PC <= 64'd9999315;
		@(posedge clk)	
		reset <= 0; IF_instruction <= 32'd1100; IF_PC <= 64'd9999317;
		@(posedge clk)	
		reset <= 0; IF_instruction <= 32'd1102; IF_PC <= 64'd9999319;
		@(posedge clk)	
		reset <= 0; IF_instruction <= 32'd1104; IF_PC <= 64'd9999310;
		@(posedge clk)	
		@(posedge clk)	
		@(posedge clk)	
		@(posedge clk)	
		@(posedge clk)
		@(posedge clk)	
		@(posedge clk)	
		@(posedge clk)		
		@(posedge clk)	
		@(posedge clk)	
		reset <= 1;											@(posedge clk)	
																@(posedge clk)	
																@(posedge clk)	
																$stop;
	end
endmodule
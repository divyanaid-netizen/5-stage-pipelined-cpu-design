`timescale 1ns/10ps
module Instr_to_addr (currentPC, clk, reset, BrTaken, UncondBr, instruction, blink_sig, link_register, breg_sig, register_branch, branch_address);
	parameter DELAY = 0.05;
	input logic clk, reset, BrTaken, UncondBr, blink_sig;
	output logic [31:0] instruction;
	output logic [63:0] link_register;
	input logic breg_sig;
	input logic [63:0] register_branch, branch_address;
	output logic [63:0] currentPC;
	
	// Instruction Fetch code 
	instructmem inst_fetch (.address(currentPC), .instruction(instruction), .clk(clk));
	
	
	//adder if increment by 4 or jump
	logic [63:0]pc_plus4;
	address_adder pc_adder1 (.A(currentPC), .B(64'd04), .sum(pc_plus4));
	
	//store pc_plus4 value in link register
	mux2_64b Alu_src_mux (.out(link_register), .A(link_register), .B(pc_plus4), .sel(blink_sig));

	
	logic [63:0] pc_branch_address;
	mux2_64b mux_branch (.out(pc_branch_address), .A(pc_plus4), .B(branch_address), .sel(BrTaken));
	
	logic [63:0] pc_input_address;
	mux2_64b mux_if (.out(pc_input_address), .A(pc_branch_address), .B(register_branch), .sel(breg_sig));
	
	
	pc storePC (.clk(clk), .reset(reset), .pc_in(pc_input_address), .pc_out(currentPC));
	
	
endmodule

module Instr_to_addr_testbench();
	logic clk, reset, BrTaken, UncondBr;
	logic [31:0] instruction;
	
	Instr_to_addr dut(.instruction, .UncondBr, .BrTaken, .clk, .reset);

	parameter CLOCK_PERIOD= 5000;
	initial begin
	clk <= 0;
	forever #(CLOCK_PERIOD/2) clk <= ~clk;
	end
	integer i;
	always_comb begin
		if(instruction[31:26] == 6'b000101) begin
			UncondBr = 1'b1;
			BrTaken = 1'b1;
		end
		else begin
			UncondBr = 1'b0;
			BrTaken = 1'b0;
		end
	end
	initial begin
		reset <= 1'b1;
		@(posedge clk);
		reset <= 1'b0;
		for(i = 0; i < 15; i++) begin
			@(posedge clk);
		end
		$stop;
	end
endmodule
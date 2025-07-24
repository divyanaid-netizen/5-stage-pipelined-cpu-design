`timescale 1ns/10ps
module nor16to1(in, zeroFlag);
	parameter DELAY = 0.05;
	input logic [15:0] in;
   output logic zeroFlag;
	logic [3:0] w;
	
	
	or #DELAY or1 (w[0], in[3], in[2], in[1], in[0]);
	or #DELAY or2 (w[1], in[7], in[6], in[5], in[4]);
	or #DELAY or3 (w[2], in[11], in[10], in[9], in[8]);
	or #DELAY or4 (w[3], in[15], in[14], in[13], in[12]);
	
	nor #DELAY nor1 (zeroFlag, w[0], w[1], w[2], w[3]);
	
endmodule

module nor16to1_testbench();
	logic [15:0] in;
	logic zeroFlag;
	
   nor16to1 dut (.in, .zeroFlag);
	
	integer i;
	
	initial begin 
	   
		in = 16'h0000; #100;
		
		
		for(i=0; i<255; i++) begin
			in=i; #100;
			in[15:8]=i; in[7:0]=8'h00; #100;
		end
	end

endmodule
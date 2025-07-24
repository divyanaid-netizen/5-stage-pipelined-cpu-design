`timescale 1ns/10ps

module zeroF (in, zeroFlag);
	input logic [63:0] in;
	output logic zeroFlag;
   logic [3:0] w;
	
	
	nor16to1 nor1 (.in(in[15:0]), .zeroFlag(w[0]));
	nor16to1 nor2 (.in(in[31:16]), .zeroFlag(w[1]));
	nor16to1 nor3 (.in(in[47:32]), .zeroFlag(w[2]));
	nor16to1 nor4 (.in(in[63:48]), .zeroFlag(w[3]));
	
	
	and #0.05 and1 (zeroFlag, w[0], w[1], w[2], w[3]);
	
endmodule

module zeroF_testbench();
	logic [63:0] in;
	logic zeroFlag;
	
	zeroF dut (.in, .zeroFlag);
	
	integer i;
	
	initial begin 
	   
		in = 64'h0000000000000000; #100;
		in = 64'hFFFFFFFFFFFFFFFF; #100;
		
		for(i=0; i<100; i++) begin
			in=i; #100;
		end
	end

endmodule
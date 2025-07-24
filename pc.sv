module pc(
	clk,
	reset,
	pc_in,
	pc_out
);

	// I/O ports
	input clk;
	input reset;
	input [63:0] pc_in;
	output reg [63:0] pc_out;
	
	genvar i;
	generate
		for (i = 0; i < 64; i++) begin: eachDFF
			eDFF theDFF (.q(pc_out[i]), .d(pc_in[i]), .reset, .clk, .en(1'b1));
		end
	endgenerate

endmodule
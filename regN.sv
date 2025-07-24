module regN #(parameter N = 64) (reset, clk, in, out);
	// Input Logic
    input  logic 		  reset, clk;
	input  logic [N-1:0] in;
	// Output Logic
    output logic [N-1:0] out;
	
    // Generate Logic
	genvar i;
	generate
		for (i=0; i < N; i++) begin : gen_reg_dff
			D_FF dff (.q(out[i]), .d(in[i]), .reset, .clk);
		end
	endgenerate

endmodule 
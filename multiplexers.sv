`timescale 1ns/10ps

module mux_64w32to1(outputs, registers, selects);
		
		output logic [63:0] outputs;
		input logic [31:0][63:0] registers;
		input logic [4:0] selects;
		logic [31:0] column_data; // Temporary variable to hold the selected column
		
		logic [63:0][31:0] t_in;
		int o, k;
		always_comb begin
			for(int o=0; o < 32; o=o+1) begin
				for(int k=0; k < 64; k = k+1) begin
					t_in[k][o] = registers[o][k];
				end
			end
		end
		
		genvar i, j;
		generate
			for(i = 0; i < 64; i++) begin: assign_registers
				mux_32to1 assign_out (.out(outputs[i]), .inputs(t_in[i][31:0]), .selects(selects));
			end		
		endgenerate
					  
endmodule

module mux_5w2to1 (A, B, sel, out);
	input logic [4:0] A, B;
	input logic sel;
	output logic [4:0] out;
	
	genvar i;
	generate
	for (i = 0; i < 5; i++) begin: eachMux
			mux_2to1 theMuxes (.sel(sel), .inputs({B[i], A[i]}), .out(out[i]));
		end
	endgenerate
endmodule

module mux2_64b(out, A, B, sel);
	input logic [63:0] A, B;
	output logic [63:0] out;
	input logic sel;
	genvar i;
	generate
		for (i = 0; i < 64; i++) begin : mux1
			mux_2to1 mux_64_bit (.out(out[i]), .inputs({B[i], A[i]}), .sel(sel));
			
		end
	endgenerate
	
	endmodule


module mux4_64b (out, A, B, C, D, sel);
	input logic [63:0] A, B, C, D;
	input logic [1:0] sel;
	output logic [63:0] out;

	genvar i;
	
	generate 
		for (i = 0; i < 64; i++) begin : eachRouteMux
			mux_4to1 Mux1 (.inputs({D[i], C[i], B[i], A[i]}), .selects(sel), .out(out[i]));
		end
	endgenerate 

endmodule

module mux_32to1(out, inputs, selects);
 output logic out;
 input logic [31:0] inputs;
 input logic [4:0] selects;

 logic [1:0] intermediate;

 mux_16to1 m0(.out(intermediate[0]), .inputs(inputs[15:0]), .selects(selects[3:0]));
 mux_16to1 m1(.out(intermediate[1]), .inputs(inputs[31:16]), .selects(selects[3:0]));
 mux_2to1 m (.out(out), .inputs(intermediate), .sel(selects[4]));
	 
endmodule

module mux_16to1(out, inputs, selects);
 output logic out;
 input logic [15:0] inputs;
 input logic [3:0] selects;

 logic [1:0] intermediate;

 mux_8to1 m0(.out(intermediate[0]), .inputs(inputs[7:0]), .selects(selects[2:0]));
 mux_8to1 m1(.out(intermediate[1]), .inputs(inputs[15:8]), .selects(selects[2:0]));
 mux_2to1 m (.out(out), .inputs(intermediate), .sel(selects[3]));
 
endmodule	
	
module mux_8to1(out, inputs, selects);
 output logic out;
 input logic [7:0] inputs;
 input logic [2:0] selects;

 logic [1:0] intermediate;

 mux_4to1 m0(.out(intermediate[0]), .inputs(inputs[3:0]), .selects(selects[1:0]));
 mux_4to1 m1(.out(intermediate[1]), .inputs(inputs[7:4]), .selects(selects[1:0]));
 mux_2to1 m (.out(out), .inputs(intermediate), .sel(selects[2]));
 
endmodule

module mux_4to1(out, inputs, selects);
 output logic out;
 input logic [3:0] inputs;
 input logic [1:0] selects;

 logic [1:0] intermediate;

 mux_2to1 m0(.out(intermediate[0]), .inputs(inputs[1:0]), .sel(selects[0]));
 mux_2to1 m1(.out(intermediate[1]), .inputs(inputs[3:2]), .sel(selects[0]));
 mux_2to1 m (.out(out), .inputs(intermediate), .sel(selects[1]));
 
endmodule



module mux_2to1(out, inputs, sel);
 output logic out;
 input logic [1:0] inputs;
 input logic sel;
 logic temp1, temp2;
 parameter DELAY = 0.05;
 
 and mux1 (temp1, inputs[0], ~sel);
 and mux2 (temp2, inputs[1], sel);
 or add (out, temp1, temp2);
 
endmodule

module mux_64w32to1_testbench();
	logic [4:0] selects;
	logic [31:0][63:0] registers;
	logic [63:0] outputs;
	mux_64w32to1 dut (.outputs(outputs), .registers(registers), .selects(selects));
	initial begin
	
		for (int i = 0; i < 32; i = i + 1) begin
			registers[i][63:0] = 1<<i; // Example initialization (1 shifted left by i bits)
		end
		
		for (int j = 0; j < 32; j = j + 1) begin
			selects=j; #10;
		end
	end
endmodule

module mux_2to1_testbench();
	logic [1:0] inputs;
	logic sel;
	logic out;
	mux_2to1 dut (.out, .inputs, .sel);
	initial begin
	sel=0; inputs[0]=0; inputs[1]=0; #10;
	sel=0; inputs[0]=0; inputs[1]=1; #10;
	sel=0; inputs[0]=1; inputs[1]=0; #10;
	sel=0; inputs[0]=1; inputs[1]=1; #10;
	sel=1; inputs[0]=0; inputs[1]=0; #10;
	sel=1; inputs[0]=0; inputs[1]=1; #10;
	sel=1; inputs[0]=1; inputs[1]=0; #10;
	sel=1; inputs[0]=1; inputs[1]=1; #10;
	end
endmodule
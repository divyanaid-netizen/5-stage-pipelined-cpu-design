module decoder_5to32 (outputs, inputs, ena);
	input logic ena;
	input logic [4:0] inputs;
	output logic [31:0] outputs;
	
	logic [1:0] selects;
	decoder_1to2 sel_line (.outputs(selects), .in_sel(inputs[4]), .ena(ena));

	decoder_4to16 out_31to16 (.outputs(outputs[31:16]), .inputs(inputs[3:0]), .ena(selects[1]));
	decoder_4to16 out_15to0 (.outputs(outputs[15:0]), .inputs(inputs[3:0]), .ena(selects[0]));
	
endmodule

module decoder_4to16 (outputs, inputs, ena);	
	input logic ena;
	input logic [3:0] inputs;
	output logic [15:0] outputs;
	
	logic [3:0] selects;
	
	decoder_2to4 firstDecoder(.outputs(selects), .inputs(inputs[3:2]), .ena(ena));
	
	decoder_2to4 out_15to12 (.outputs(outputs[15:12]), .inputs(inputs[1:0]), .ena(selects[3]));
	decoder_2to4 out_11to8 (.outputs(outputs[11:8]), .inputs(inputs[1:0]), .ena(selects[2]));
	decoder_2to4 out_7to4 (.outputs(outputs[7:4]), .inputs(inputs[1:0]), .ena(selects[1]));
	decoder_2to4 out_3to0 (.outputs(outputs[3:0]), .inputs(inputs[1:0]), .ena(selects[0]));
	
endmodule

module decoder_2to4 (outputs, inputs, ena);
	input logic ena;
	input logic [1:0] inputs;
	output logic [3:0] outputs;
	
	logic [1:0] selects;
	
	decoder_1to2 sel_line (.outputs(selects), .in_sel(inputs[1]), .ena(ena));

	decoder_1to2 result0 (.outputs(outputs[1:0]), .in_sel(inputs[0]), .ena(selects[0]));
	decoder_1to2 result1 (.outputs(outputs[3:2]), .in_sel(inputs[0]), .ena(selects[1]));
	
endmodule

module decoder_1to2 (outputs, in_sel, ena);
	input logic ena;
	input logic in_sel;
	output logic [1:0] outputs;
	
	logic not_input;
	not(not_input, in_sel);
	
	and result1 (outputs[1], in_sel, ena);
	and result0 (outputs[0], not_input, ena);
endmodule

module decoder_5to32_testbench();
	logic ena;
	logic [4:0] inputs;
	logic [31:0] outputs;
	decoder_5to32 dut (.outputs, .inputs, .ena);
	initial begin
	
	ena=0; #10;
	for(int i = 0; i<32; i++) begin
	ena=1; inputs = i; #10;
	end

	end
endmodule

module decoder_1to2_testbench();
	logic ena;
	logic in_sel;
	logic [1:0] outputs;
	decoder_1to2 dut (.outputs, .in_sel, .ena);
	initial begin
	ena=0; in_sel=0;  #10;
	ena=0;  in_sel=1;  #10;
	ena=1;  in_sel=0;  #10;
	ena=1; in_sel=1;  #10;

	end
endmodule
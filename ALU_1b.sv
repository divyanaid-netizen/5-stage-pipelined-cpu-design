// cntrl			Operation						Notes:
// 000:			result = B						value of overflow and carry_out unimportant
// 001: 			reserved
// 010:			result = A + B
// 011:			result = A - B
// 100:			result = bitwise A & B		value of overflow and carry_out unimportant
// 101:			result = bitwise A | B		value of overflow and carry_out unimportant
// 110:			result = bitwise A XOR B	value of overflow and carry_out unimportant
`timescale 1ns/10ps


module ALU_1b  (

    input logic a,         // Input bit a
    input logic b,         // Input bit b
    input logic cin,       // Carry-in/borrow-in for addition/subtraction
    input logic [2:0] op,  // Operation select signal
	 output logic cout,
    output logic result);   // Result output bit
	 
    parameter DELAY = 0.05;

   // Internal signals
   logic sum, and_out, or_out, xor_out;
   logic add_cout, sub_cout;
	logic [7:0]result_array;
	logic add_sub_select;
	logic notb;
	
    // Operations
   and #DELAY andout(and_out, a, b);             // AND operation
   or #DELAY orout (or_out, a, b);              // OR operation
   xor #DELAY xorout (xor_out, a, b);             // XOR operation
   not #DELAY invert_b (notb, b);
	 
	mux_2to1 select_op (.inputs({notb, b}), .sel(op[0]), .out(add_sub_select));
	fulladder FA(.a(a), .b(add_sub_select), .carry_in(cin), .carry_out(cout), .sum(sum));
	  
	assign result_array[0] = b;
	assign result_array[2] = sum;
	assign result_array[3] = sum;
	assign result_array[4] = and_out;
	assign result_array[5] = or_out;
	assign result_array[6] = xor_out;
    
	 mux_8to1 outselect (.inputs(result_array), .selects(op), .out(result));

endmodule


module ALU_1b_testbench();

    // Testbench signals
    logic a;
    logic b;
    logic cin;
	 logic cout;
    logic [2:0] op;
    logic result;

    // Instantiate the ALU_one module
    ALU_1b dut (
        .a(a),
        .b(b),
        .cin(cin),
		  .cout(cout),
        .op(op),
        .result(result)
    );

    // Test sequence
    initial begin
        // Initialize inputs
        a = 0;
        b = 0;
        cin = 0;
        op = 3'b000;

        // Apply different operations and display results
        $display("Starting ALU_one Testbench...");

        // Test result = B operation
        a = 1; b = 0; cin = 0; op = 3'b000; #10;
        $display("AND: a = %b, b = %b, cin = %b, op = %b, result = %b", a, b, cin, op, result);
        a = 1; b = 1; cin = 0; op = 3'b000; #10;
        $display("AND: a = %b, b = %b, cin = %b, op = %b, result = %b", a, b, cin, op, result);

        // Test result = A + B operation
        a = 1; b = 0; cin = 0; op = 3'b010; #10;
        $display("ADD: a = %b, b = %b, cin = %b, op = %b, cout = %b, result = %b", a, b, cin, op, cout, result);
        a = 1; b = 1; cin = 0; op = 3'b010; #10;
        $display("ADD: a = %b, b = %b, cin = %b, op = %b, cout = %b, result = %b", a, b, cin, op, cout, result);

        // Test result = A - B operation
        a = 1; b = 0; cin = 0; op = 3'b011; #10;
        $display("SUB: a = %b, b = %b, cin = %b, op = %b, cout = %b, result = %b", a, b, cin, op, cout, result);
        a = 1; b = 1; cin = 0; op = 3'b011; #10;
        $display("SUB: a = %b, b = %b, cin = %b, op = %b, cout = %b, result = %b", a, b, cin, op, cout, result);
        a = 1; b = 1; cin = 1; op = 3'b011; #10;
        $display("SUB: a = %b, b = %b, cin = %b, op = %b, cout = %b, result = %b", a, b, cin, op, cout, result);

        // Test result = bitwise A and B operation
        a = 1; b = 0; cin = 0; op = 3'b100; #10;
        $display("AND: a = %b, b = %b, cin = %b, op = %b, result = %b", a, b, cin, op, result);
        a = 1; b = 1; cin = 0; op = 3'b100; #10;
        $display("AND: a = %b, b = %b, cin = %b, op = %b, result = %b", a, b, cin, op, result);
        
        // Test result = bitwise A or B operation
        a = 1; b = 0; cin = 0; op = 3'b101; #10;
        $display("OR a = %b, b = %b, cin = %b, op = %b, result = %b", a, b, cin, op, result);
        a = 1; b = 1; cin = 0; op = 3'b101; #10;
        $display("OR a = %b, b = %b, cin = %b, op = %b, result = %b", a, b, cin, op, result);

		  // Test result = bitwise A xor B operation
        a = 1; b = 0; cin = 0; op = 3'b110; #10;
        $display("XOR a = %b, b = %b, cin = %b, op = %b, result = %b", a, b, cin, op, result);
        a = 1; b = 1; cin = 0; op = 3'b110; #10;
        $display("XOR a = %b, b = %b, cin = %b, op = %b, result = %b", a, b, cin, op, result);
        
        $display("ALU_one Testbench completed.");
        $finish;
    end

endmodule

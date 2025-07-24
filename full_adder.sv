`timescale 1ns/10ps
//Full adder using structural modeling
module fulladder (a, b, carry_in, carry_out, sum);
	input logic a;
	input logic b;
	input logic carry_in;
	output logic carry_out;
	output logic sum;

	logic xorout, andout1, andout2;
	parameter DELAY = 0.05;
	
	xor #DELAY x1(xorout, a, b);
	and #DELAY a1(andout1, a, b);
	and #DELAY a2(andout2, xorout, carry_in);
	xor #DELAY x2(sum, xorout, carry_in);        //Sum output

	
	or #DELAY or1(carry_out, andout1, andout2);     //carry output

endmodule

module tb_fulladder();

    // Testbench signals
    logic a;
    logic b;
    logic carry_in;
    logic carry_out;
    logic sum;

    // Instantiate the fulladder module
    fulladder dut (
        .a(a),
        .b(b),
        .carry_in(carry_in),
        .carry_out(carry_out),
        .sum(sum)
    );

    // Test sequence
    initial begin
        // Display header
        $display("Time   a b carry_in | sum carry_out");

        // Test cases
        a = 0; b = 0; carry_in = 0; #10;
        $display("%4t: %b %b    %b     |  %b    %b", $time, a, b, carry_in, sum, carry_out);

        a = 0; b = 1; carry_in = 0; #10;
        $display("%4t: %b %b    %b     |  %b    %b", $time, a, b, carry_in, sum, carry_out);

        a = 1; b = 0; carry_in = 0; #10;
        $display("%4t: %b %b    %b     |  %b    %b", $time, a, b, carry_in, sum, carry_out);

        a = 1; b = 1; carry_in = 0; #10;
        $display("%4t: %b %b    %b     |  %b    %b", $time, a, b, carry_in, sum, carry_out);

        a = 0; b = 0; carry_in = 1; #10;
        $display("%4t: %b %b    %b     |  %b    %b", $time, a, b, carry_in, sum, carry_out);

        a = 0; b = 1; carry_in = 1; #10;
        $display("%4t: %b %b    %b     |  %b    %b", $time, a, b, carry_in, sum, carry_out);

        a = 1; b = 0; carry_in = 1; #10;
        $display("%4t: %b %b    %b     |  %b    %b", $time, a, b, carry_in, sum, carry_out);

        a = 1; b = 1; carry_in = 1; #10;
        $display("%4t: %b %b    %b     |  %b    %b", $time, a, b, carry_in, sum, carry_out);

        $display("Testbench completed.");
        $finish;
    end

endmodule

`timescale 1ns/10ps

module nor_64b(
	output logic out,
	input logic [63:0] inputs);

	logic [15:0] intermediate;
	
	logic [3:0] and_outs;
	logic and_final;
	
	parameter DELAY = 0.05;
 
	generate
	  genvar i;
	  for (i = 0; i < 16; i++) begin : nor_block
		nor #DELAY nor1 (intermediate[i], inputs[(4*i)+0], inputs[(4*i)+1], inputs[(4*i)+2], inputs[(4*i)+3]);
	  end
	endgenerate
	
	generate
	  genvar j;
	  for (j = 0; j < 4; j++) begin : and_block
		and #DELAY and_instance(and_outs[j], intermediate[(4*j)+0], intermediate[(4*j)+1], intermediate[(4*j)+2], intermediate[(4*j)+3]);
	  end
	endgenerate
	and #DELAY andfinal (and_final, and_outs[0], and_outs[1], and_outs[2], and_outs[3]);
	
	assign out = and_final;
		
endmodule


module nor_64b_tb();
logic out;
logic [63:0] inputs;

nor_64b dut (.out(out), 
            .inputs(inputs));
initial begin
        // Test vector 1
        inputs = 64'hFFFFFFFFFFFFFFFF;
        #10;
        $display("Test 1: inputs = %h, out = %b (Expected: 0)", inputs, out);

        // Test vector 2
        inputs = 64'h0000000000000000;
        #10;
        $display("Test 2: inputs = %h, out = %b (Expected: 1)", inputs, out);

        // Test vector 3
        inputs = 64'hAAAAAAAAAAAAAAAA;
        #10;
        $display("Test 3: inputs = %h, out = %b (Expected: 0)", inputs, out);

        // Test vector 4
        inputs = 64'h5555555555555555;
        #10;
        $display("Test 4: inputs = %h, out = %b (Expected: 0)", inputs, out);

        // Test vector 5
        inputs = 64'h0F0F0F0F0F0F0F0F;
        #10;
        $display("Test 5: inputs = %h, out = %b (Expected: 0)", inputs, out);

        // Finish simulation
        $stop;
    end

    // Monitor to display changes
    initial begin
        $monitor("Time: %0t | inputs: %h | out: %b", $time, inputs, out);
    end

endmodule
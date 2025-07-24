`timescale 1ns/10ps
module register #(parameter N = 64) (data_in, data_out, clk, reset, write_en);
input logic [N-1:0] data_in;
input logic write_en, clk, reset;
output logic [N-1:0] data_out;

genvar i;
		generate
			for(i = 0; i < N; i++) begin: bit_registers
				eDFF register_out (.q(data_out[i]), .d(data_in[i]), .reset(reset), .clk(clk), .en(write_en));
			end		
		endgenerate
		
endmodule

module register_testbench();

    // Inputs and outputs of the D_FF module
    logic [63:0] d;
	 logic reset, clk, en;
    logic [63:0] q;

    // Instantiate the D_FF module
    register register_inst (
        .data_in(d),
        .data_out(q),
        .reset(reset),
        .clk(clk),
        .write_en(en)
    );

    // Clock generation
    always #5 clk = ~clk; // Toggle the clock every 5 time units

    // Stimulus generation
    initial begin
        // Initialize inputs
        d = 64'b0;
        reset = 1; // Start with reset high
        en = 0; // Disable DFF initially
        clk = 0;

        // Apply stimulus
        #20 reset = 0; // Assert reset low after 20 time units

        // Enable DFF and apply data
        #10 en = 1; // Enable DFF after 10 more time units
		  for (int i=0; i<64; i=i+1) begin
            #10 d = 1<<i;
        end
        // End simulation
        #10 $finish;
    end

    // Display outputs
    always @(posedge clk) begin
        $display("Time %0t: d = %b, q = %b", $time, d, q);
    end

endmodule

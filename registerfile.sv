module registerfile ( clk, reset, RegWrite, WriteData, WriteRegister,ReadRegister1, ReadRegister2, ReadData1, ReadData2, link_register, blink_sig);
	input logic clk, reset;
	input logic RegWrite, blink_sig;
   input logic [63:0] WriteData;	
	input logic [63:0] link_register;
	input logic [4:0] ReadRegister1, ReadRegister2, WriteRegister; 
	output logic [63:0] ReadData1, ReadData2;
	 
	logic [31:0][63:0] registers;
   logic [31:0] write_enable;
	 
	decoder_5to32 sel_write_reg (.outputs(write_enable), .inputs(WriteRegister), .ena(RegWrite));

    // Ensuring register 0 always reads as zero (if architecture requires it)
    assign registers[31][63:0] = 64'b0;
	 
	 mux2_64b link_x30 (.out(registers[30][63:0]), .A(registers[30][63:0]), .B(link_register), .sel(blink_sig));

    // Instantiate the registers
    generate
        genvar i;
        for (i = 0; i < 31; i++) begin : register_block
            register reg_instance (
                .data_in(WriteData),
                .data_out(registers[i][63:0]),
                .write_en(write_enable[i]),
                .clk(clk),
                .reset(reset)
            );
        end
    endgenerate
	
	mux_64w32to1 mux_rm (.outputs(ReadData1), .registers(registers), .selects(ReadRegister1));
	mux_64w32to1 mux_rn (.outputs(ReadData2), .registers(registers), .selects(ReadRegister2));


endmodule



// Test bench for Register file
`timescale 1ns/10ps

module regstim(); 		

	parameter ClockDelay = 5000;

	logic	[4:0] 	ReadRegister1, ReadRegister2, WriteRegister;
	logic [63:0]	WriteData;
	logic 			RegWrite, clk, reset;
	logic [63:0]	ReadData1, ReadData2;

	integer i;

	// Your register file MUST be named "regfile".
	// Also you must make sure that the port declarations
	// match up with the module instance in this stimulus file.
	registerfile dut (.ReadData1, .ReadData2, .WriteData, 
					 .ReadRegister1, .ReadRegister2, .WriteRegister,
					 .RegWrite, .clk, .reset);
					 
					 
	// Force %t's to print in a nice format.
	initial $timeformat(-9, 2, " ns", 10);

	initial begin // Set up the clock
		clk <= 0;
		reset <= 0;
		forever #(ClockDelay/2) clk <= ~clk;
	end

	initial begin
		// Try to write the value 0xA0 into register 31.
		// Register 31 should always be at the value of 0.
		RegWrite <= 5'd0;
		ReadRegister1 <= 5'd0;
		ReadRegister2 <= 5'd0;
		WriteRegister <= 5'd31;
		WriteData <= 64'h00000000000000A0;
		@(posedge clk);
		
		$display("%t Attempting overwrite of register 31, which should always be 0", $time);
		RegWrite <= 1;
		@(posedge clk);

		// Write a value into each  register.
		$display("%t Writing pattern to all registers.", $time);
		for (i=0; i<31; i=i+1) begin
			RegWrite <= 0;
			ReadRegister1 <= i-1;
			ReadRegister2 <= i;
			WriteRegister <= i;
			WriteData <= i*64'h0000010204080001;
			@(posedge clk);
			
			RegWrite <= 1;
			@(posedge clk);
		end

		// Go back and verify that the registers
		// retained the data.
		$display("%t Checking pattern.", $time);
		for (i=0; i<32; i=i+1) begin
			RegWrite <= 0;
			ReadRegister1 <= i-1;
			ReadRegister2 <= i;
			WriteRegister <= i;
			WriteData <= i*64'h0000000000000100+i;
			@(posedge clk);
		end
		$stop;
	end
endmodule

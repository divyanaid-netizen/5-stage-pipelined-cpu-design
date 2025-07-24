`timescale 1ns/10ps

module IDEXReg (clk, reset, 
                        DecALUOp, DecALUSrc, Decimmselect, DecMem2Reg, 
                        DecRegWrite, DecMemWrite, DecMemRead, DecFlagWrite, Decxfer_size,
                        DecAw, DecDa, DecDb, DecImm12Ext, DecDAddr9Ext,

                        ExALUOp, ExALUSrc, Eximmselect, ExMem2Reg, 
                        ExRegWrite, ExMemWrite, ExMemRead, ExFlagWrite, Exxfer_size,
                        ExAw, ExDa, ExDb, ExImm12Ext, ExDAddr9Ext);

    // Input Logic
    input  logic        clk, reset;
    input  logic [63:0] DecDa, DecDb, DecDAddr9Ext, DecImm12Ext;
    input  logic [4:0]  DecAw;
    input  logic [2:0]  DecALUOp;
    input  logic DecALUSrc, Decimmselect;
	 input  logic [3:0] Decxfer_size;
    input  logic        DecMem2Reg, DecMemWrite, DecMemRead, DecRegWrite, DecFlagWrite;
    
    // Output Logic
    output logic [63:0] ExDa, ExDb, ExDAddr9Ext, ExImm12Ext;
    output logic [4:0]  ExAw;
    output logic [2:0]  ExALUOp;
    output logic ExALUSrc, Eximmselect;
	 output logic [3:0]  Exxfer_size;
    output logic        ExMem2Reg, ExMemWrite, ExMemRead, ExRegWrite, ExFlagWrite;

    // Register Instantiation
    register DaReg (.reset, .clk, .write_en(1'b1), .data_in(DecDa), .data_out(ExDa));
    register DbReg (.reset, .clk, .write_en(1'b1), .data_in(DecDb), .data_out(ExDb));
    register DecDAddr9Reg (.reset, .clk, .write_en(1'b1), .data_in(DecDAddr9Ext), .data_out(ExDAddr9Ext));
    register Imm12Reg (.reset, .clk, .write_en(1'b1), .data_in(DecImm12Ext), .data_out(ExImm12Ext));

    // Register Address Registers
    register #(.N(5)) RdReg (.reset, .clk, .data_in(DecAw), .data_out(ExAw), .write_en(1'b1));

    // Control Logic Registers (n-bits)
    register #(.N(3)) ALUOpReg (.reset, .clk, .data_in(DecALUOp), .data_out(ExALUOp), .write_en(1'b1));
    register #(.N(1)) ALUSrcReg (.reset, .clk, .data_in(DecALUSrc), .data_out(ExALUSrc), .write_en(1'b1));
	 register #(.N(1)) immselectReg (.reset, .clk, .data_in(Decimmselect), .data_out(Eximmselect), .write_en(1'b1));
	 
	 register #(.N(4)) xfer (.reset, .clk, .data_in(Decxfer_size), .data_out(Exxfer_size), .write_en(1'b1));
 
	 
    // Control Logic Registers (1-bit)
	 D_FF Mem2Reg(.q(ExMem2Reg), .d(DecMem2Reg), .reset, .clk);
    D_FF MemWriteReg (.q(ExMemWrite), .d(DecMemWrite), .reset, .clk);
    D_FF MemReadReg (.q(ExMemRead), .d(DecMemRead), .reset, .clk);
    D_FF RegWriteReg (.q(ExRegWrite), .d(DecRegWrite), .reset, .clk);
    D_FF FlagWriteReg (.q(ExFlagWrite), .d(DecFlagWrite), .reset, .clk);

endmodule

module IDEXReg_tb();
	// Input Logic
      logic        clk, reset;
      logic [63:0] DecDa, DecDb, DecDAddr9Ext, DecImm12Ext;
      logic [4:0]  DecAw;
      logic [2:0]  DecALUOp;
      logic DecALUSrc, Decimmselect;
	   logic [3:0] Decxfer_size;
      logic        DecMem2Reg, DecMemWrite, DecMemRead, DecRegWrite, DecFlagWrite;
    
    // Output Logic
     logic [63:0] ExDa, ExDb, ExDAddr9Ext, ExImm12Ext;
     logic [4:0]  ExAw;
     logic [2:0]  ExALUOp;
     logic ExALUSrc, Eximmselect;
	  logic [3:0]  Exxfer_size;
     logic        ExMem2Reg, ExMemWrite, ExMemRead, ExRegWrite, ExFlagWrite;
	
	IDEXReg dut(.clk, .reset, 
                        .DecALUOp, .DecALUSrc, .Decimmselect, .DecMem2Reg, 
                        .DecRegWrite, .DecMemWrite, .DecMemRead, .DecFlagWrite, .Decxfer_size,
                        .DecAw, .DecDa, .DecDb, .DecImm12Ext, .DecDAddr9Ext,

                        .ExALUOp, .ExALUSrc, .Eximmselect, .ExMem2Reg, 
                        .ExRegWrite, .ExMemWrite, .ExMemRead, .ExFlagWrite, .Exxfer_size,
                        .ExAw, .ExDa, .ExDb, .ExImm12Ext, .ExDAddr9Ext);
	
	parameter CLOCK_PERIOD = 100; 
	
		initial begin 
	
		clk <= 0;
	
		forever #(CLOCK_PERIOD/2) clk <= ~clk;
 
		end
		
	initial begin
	
		reset <= 1;																																	
		@(posedge clk)	
		reset <= 0; DecDa <= 64'd9999313; DecDb <= 64'd9999313; DecDAddr9Ext <= 64'd9999313; DecImm12Ext <= 64'd9999313;	
						DecAw <= 5'b10111; DecALUOp <= 3'b100; Decxfer_size <= 4'b1011;
						DecMem2Reg <= 1'b1; DecMemWrite <= 1'b1; DecMemRead <= 1'b1; DecRegWrite <= 1'b1; DecFlagWrite <= 1'b1;
		@(posedge clk)
		@(posedge clk)	
		@(posedge clk)	
		@(posedge clk)	
		@(posedge clk)
		@(posedge clk)	
		@(posedge clk)	
		@(posedge clk)		
		@(posedge clk)	
		@(posedge clk)	
		reset <= 1;											@(posedge clk)	
																@(posedge clk)	
																@(posedge clk)	
																$stop;
	end
endmodule
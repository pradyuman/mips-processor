/*
  Eric Villasenor
  evillase@gmail.com

  register file test bench
*/

// mapped needs this
`include "register_file_if.vh"

// mapped timing needs this. 1ns is too fast
`timescale 1 ns / 1 ns

module register_file_tb;

  parameter PERIOD = 10;

  logic CLK = 0, nRST;

  // test vars
  //int v1 = 1;
  //int v2 = 4721;
  //int v3 = 25119;

  // clock
  always #(PERIOD/2) CLK++;

  // interface
  register_file_if rfif ();

  // DUT
`ifndef MAPPED
  register_file DUT(CLK, nRST, rfif);
`else
  register_file DUT(
    .\rfif.rdat2 (rfif.rdat2),
    .\rfif.rdat1 (rfif.rdat1),
    .\rfif.wdat (rfif.wdat),
    .\rfif.rsel2 (rfif.rsel2),
    .\rfif.rsel1 (rfif.rsel1),
    .\rfif.wsel (rfif.wsel),
    .\rfif.WEN (rfif.WEN),
    .\nRST (nRST),
    .\CLK (CLK)
  );
`endif

integer i;

initial
begin
	#(PERIOD/2)
	nRST = 1;
	#(PERIOD/2)
	nRST = 0;
	#(PERIOD/2)
	nRST = 1;
	for(i = 0; i < 32; i=i+1) begin
		//assert(DUT.register[i] == '0) $display("nRST for reg %d passed\n", i);
		//else $display("nRST for reg %d failed\n", i);
	end
	
	@(negedge CLK)
	rfif.wsel = 0;
	rfif.WEN = 1;
	rfif.rsel1 = 0;
	rfif.rsel2 = 0;
	for(i = 0; i < 10; i=i+1) begin
		@(negedge CLK)
		rfif.wdat = $random();
		#(PERIOD)
		assert(rfif.rdat1 == 0 && rfif.rdat2 == 0) $display("Reg 0 read %d passed\n", i);
		else $display("Reg 0 read %d failed\n", i);
	end

	for(i = 1; i < 32; i=i+1) begin
		@(negedge CLK)
		rfif.wsel = i;
		rfif.WEN = 1;
		rfif.wdat = i;
		rfif.rsel1 = i;
		rfif.rsel2 = i;
		#(PERIOD)
		assert(rfif.rdat1 == i && rfif.rdat2 == i) $display("Reg %d write/read passed\n", i);
		else $display("Reg %d write/read failed\n" , i);
	end
	$finish;
end

endmodule

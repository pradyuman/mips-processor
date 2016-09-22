`include "cpu_types_pkg.vh"
`include "mux_types_pkg.vh"

`include "pc_if.vh"

`timescale 1ns / 1ns

import cpu_types_pkg::*;
import mux_types_pkg::*;

module pc_tb;
  parameter PERIOD = 10;
  logic CLK = 0, nRST;
  always #(PERIOD/2) CLK++;
  pc_if pcif ();

  pc DUT (CLK, nRST, pcif);

  initial
  begin
    $finish;
  end

endmodule

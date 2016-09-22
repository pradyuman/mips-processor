`include "cpu_types_pkg.vh"
`include "mux_types_pkg.vh"

`include "pc_if.vh"
`include "datapath_cache_if.vh"
`include "control_unit_if.vh"
`include "register_file_if.vh"

`timescale 1ns / 1ns

import cpu_types_pkg::*;
import mux_types_pkg::*;

module datapath_tb;

  parameter PERIOD = 10;
  logic CLK = 0, nRST;
  always #(PERIOD/2) CLK++;

  datapath_cache_if dpif ();

  datapath DTP (CLK, nRST, dpif);

  initial
  begin
    $finish;
  end
endmodule

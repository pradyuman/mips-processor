`include "cpu_types_pkg.vh"
`include "datapath_cache_if.vh"

import cpu_types_pkg::*;

module request_unit_tb;

  parameter PERIOD = 10;
  logic CLK = 0, nRST;

  always #(PERIOD/2) CLK++;

  datapath_cache_if dcif ();

  request_unit DUT (CLK, nRST, dcif);

  initial
  begin
    $finish;
  end

endmodule

`include "datapath_cache_if.vh"
`include "caches_if.vh"
`include "cpu_ram_if.vh"
`timescale 1 ns / 1 ns

import cpu_types_pkg::*;

module icache_tb #(parameter PERIOD = 10);
  logic CLK = 0, nRST;
  always #(PERIOD/2) CLK++;

  caches_if cif();
  datapath_cache_if dcif();
  icache DUT(.CLK, .nRST, .cif, .dcif);

  static integer ecnt = 0;
  word_t A[16], B[16];
  integer lat[16];

  initial begin
    std::randomize(A);
    std::randomize(B);
    foreach(lat[i]) std::randomize(lat[i]) with { lat[i] inside {[0:100]}; };
    lat[0] = 0;

    // Test Reset
    reset();
    for (int i = 0; i<16; i++)
      if (DUT.idb[i] != 0) begin
        $display("Reset Failed."); ecnt++;
      end

    // Test Cache Empty- Variable Latency
    foreach(A[i]) testICache(A[i], B[i], lat[i]);

    $display("TOTAL ERRORS: %0d", ecnt);
    $finish;
  end

  // Reset RAM
  task reset;
    nRST = 1'b1; #PERIOD;
    nRST = 1'b0; #PERIOD;
    nRST = 1'b1; #PERIOD;
    cif.iwait = 1;
  endtask

  task testICache(word_t addr, word_t data, integer lat);
    dcif.imemaddr = addr; dcif.imemREN = 1;
    cif.iload = data;
    #(PERIOD * lat);
    cif.iwait = 0; #PERIOD; cif.iwait = 1; dcif.imemREN = 0;

    if (dcif.imemload != data) error(data, lat, ecnt);
  endtask

  task automatic error(word_t expected, integer lat, ref integer e);
    $display("ERROR: (LAT %d) Expected - %s | Got - %0d", lat, expected, dcif.imemload); e++;
  endtask
endmodule

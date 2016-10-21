`include "datapath_cache_if.vh"
`include "caches_if.vh"
`include "cpu_ram_if.vh"
`timescale 1 ns / 1 ns

import cpu_types_pkg::*;

module dcache_tb #(parameter PERIOD = 10);
  logic CLK = 0, nRST;
  always #(PERIOD/2) CLK++;

  caches_if cif();
  datapath_cache_if dcif();
  dcache DUT(.CLK, .nRST, .cif, .dcif);

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
    for (int i = 0; i < 16; i++)
      if (DUT.ddb[i] != 0) $display("Reset Failed."); ecnt++;

    // Test Cache Empty - Variable Latency
    foreach(A[i]) testDCacheWrite(A[i], B[i], lat[i]);
    foreach(A[i]) testDCacheRead(A[i], B[i], lat[i]);

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

  task testDCacheRead(word_t addr, word_t data, integer lat);
    dcif.dmemaddr = addr; dcif.dmemREN = 1; cif.dload = data;
    #(PERIOD * lat);
    cif.dwait = 0; #PERIOD;
    cif.dwait = 1; dcif.dmemREN = 0;

    if (dcif.dmemload != data) error(data, lat, ecnt);
  endtask

  task testDCacheWrite(word_t addr, word_t data, integer lat);
    dcif.dmemaddr = addr; dcif.dmemWEN = 1; cif.dload = data;
    #(PERIOD * lat);
    cif.dwait = 0; #PERIOD;
    cif.dwait = 1; dcif.dmemWEN = 0;

    if (cif.dstore != data) error(data, lat, ecnt);
  endtask

  task automatic error(word_t expected, integer lat, ref integer e);
    $display("ERROR: (LAT %d) Expected - %s | Got - %0d", lat, expected, dcif.dmemload); e++;
  endtask
endmodule

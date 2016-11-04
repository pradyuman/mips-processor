`include "datapath_cache_if.vh"
`include "caches_if.vh"

module caches (
  input logic CLK, nRST,
  datapath_cache_if dcif,
  caches_if cif
);
  icache  ICACHE(CLK, nRST, dcif, cif);
  dcache  DCACHE(CLK, nRST, dcif, cif);
endmodule

`include "caches_if.vh"
`include "datapath_cache_if.vh"
`include "cpu_types_pkg.vh"

import cpu_types_pkg::*;

typedef struct packed {
  logic valid;
  logic [ITAG_W-1:0] tag;
  word_t data;
} ientry;

module icache(
  input logic CLK, nRST,
  caches_if.icache cif,
  datapath_cache_if.icache dcif
);
  ientry [15:0] idb;
  icachef_t i;

  assign i = dcif.imemaddr;
  assign dcif.imemload = idb[i.idx].data;

  always_ff @(posedge CLK, negedge nRST)
    if (!nRST) idb <= '0;
    else if (dcif.imemREN & !cif.iwait) begin
      idb[i.idx].valid <= 1;
      idb[i.idx].tag <= i.tag;
      idb[i.idx].data <= cif.iload;
    end

  always_comb begin
    cif.iREN = 0;
    cif.iaddr = 'x;
    dcif.ihit = 0;
    if (dcif.imemREN & idb[i.idx].valid & idb[i.idx].tag == i.tag)
      dcif.ihit = 1;
    else if (dcif.imemREN) begin
      cif.iREN = 1;
      cif.iaddr = dcif.imemaddr;
    end
  end
endmodule

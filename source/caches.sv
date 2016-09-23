`include "datapath_cache_if.vh"
`include "caches_if.vh"

module caches (
  input logic CLK, nRST,
  datapath_cache_if.cache dcif,
  caches_if cif
);

  //icache  ICACHE(dcif, cif);
  //dcache  DCACHE(dcif, cif);

  // dcache invalidate before halt handled by dcache when exists
  assign dcif.flushed = dcif.halt;

  //singlecycle
  assign dcif.ihit = (dcif.imemREN) ? ~cif.iwait : 0;
  assign dcif.dhit = (dcif.dmemREN|dcif.dmemWEN) ? ~cif.dwait : 0;
  assign dcif.imemload = cif.iload;
  assign dcif.dmemload = cif.dload;

  assign cif.iREN = dcif.imemREN;
  assign cif.dREN = dcif.dmemREN;
  assign cif.dWEN = dcif.dmemWEN;
  assign cif.dstore = dcif.dmemstore;
  assign cif.iaddr = dcif.imemaddr;
  assign cif.daddr = dcif.dmemaddr;

endmodule

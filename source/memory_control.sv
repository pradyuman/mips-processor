`include "cache_control_if.vh"
`include "cpu_types_pkg.vh"

import cpu_types_pkg::*;

module memory_control(
  input logic CLK, nRST,
  cache_control_if.cc ccif
);
  parameter CPUS = 2;

  assign ccif.dload = ccif.ramload;
  assign ccif.iload = ccif.ramload;
  assign ccif.ramstore = ccif.dstore;
  assign ccif.ramWEN = ccif.dWEN;
  assign ccif.ramREN = (ccif.iREN | ccif.dREN) && !ccif.dWEN;
  assign ccif.ramaddr = (ccif.dREN | ccif.dWEN) ? ccif.daddr : ccif.iaddr;
  assign ccif.dwait = !((ccif.dREN | ccif.dWEN) & (ccif.ramstate == ACCESS));
  assign ccif.iwait = !((ccif.ramstate == ACCESS) & ccif.iREN) | ccif.dREN | ccif.dWEN;
endmodule

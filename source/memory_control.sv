`include "cache_control_if.vh"
`include "cpu_types_pkg.vh"
import cpu_types_pkg::ACCESS

module memory_control #(parameter CPUS = 2) (cache_control_if.cc ccif);
  assign ccif.ramREN = ccif.dREN | ccif.iREN;
  assign ccif.ramWEN = ccif.dWEN;

  assign ccif.ramaddr = ccif.dREN || ccif.dWEN ? ccif.daddr : ccif.iaddr;
  assign ccif.ramstore = ccif.dstore;

  assign ccif.iload = ccif.ramload;
  assign ccif.dload = ccif.ramload;

  assign ~iwait = ccif.iREN && ramstate == ACCESS;
  assign ~dwait = (ccif.dREN && ramstate == ACCESS) ||
                  (ccif.dWEN && ramstate == FREE);
endmodule

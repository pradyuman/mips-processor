`ifndef BRANCH_PREDICTOR_IF_VH
`define BRANCH_PREDICTOR_IF_VH

`include "mux_types_pkg.vh"

import mux_types_pkg::pcMux;

interface branch_predictor_if;
  logic phit;
  logic [29:0] br_a, cpc, tag, addr;
  pcMux pcSel;

  modport bp (
    input br_a, cpc, tag, pcSel,
    output addr, phit
  );

endinterface
`endif

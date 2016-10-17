`ifndef BRANCH_PREDICTOR_IF_VH
`define BRANCH_PREDICTOR_IF_VH

`include "mux_types_pkg.vh"

import mux_types_pkg::pcMux;

interface branch_predictor_if;
  logic upEN, phit;
  logic [29:0] br_a, cpc, npc, rpc, tag, addr;
  pcMux pcSel;

  modport bp (
    input upEN, br_a, cpc, npc, tag, pcSel,
    output addr, rpc, phit
  );

endinterface
`endif

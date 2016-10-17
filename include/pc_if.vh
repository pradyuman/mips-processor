`ifndef PC_IF_VH
`define PC_IF_VH

`include "cpu_types_pkg.vh"
`include "mux_types_pkg.vh"

import cpu_types_pkg::*;
import mux_types_pkg::*;

interface pc_if;
  pcMux pcSel;
  logic pcEN, bpSel;
  logic [25:0] immJ26;
  logic [29:0] br_a, bp_a;
  logic [31:2] rdat, ext30, cpc, npc, pipe_npc;

  modport pc (
    input pcSel, pcEN, bpSel,
          pipe_npc, rdat, immJ26, ext30, br_a, bp_a,
    output cpc, npc
  );

endinterface

`endif

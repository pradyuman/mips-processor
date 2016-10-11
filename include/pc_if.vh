`ifndef PC_IF_VH
`define PC_IF_VH

`include "cpu_types_pkg.vh"
`include "mux_types_pkg.vh"

import cpu_types_pkg::*;
import mux_types_pkg::*;

interface pc_if;
  logic pcEN;
  logic [25:0] immJ26;
  pcMux pcSel;
  logic [31:2] rdat, ext30, cpc, npc, pipe_npc;
  word_t val;

  assign val = {cpc, 2'b0};

  modport pc (
    input rdat, immJ26, ext30, pcSel, pcEN, pipe_npc,
    output val, cpc, npc
  );

endinterface

`endif

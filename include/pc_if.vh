`ifndef PC_IF_VH
`define PC_IF_VH

`include "cpu_types_pkg.vh"
`include "mux_types_pkg.vh"

import cpu_types_pkg::*;
import mux_types_pkg::*;

interface pc_if;
  pcMux pcSel;
  logic pcEN, bpSel, bpFlush, pdStatus;
  logic [25:0] immJ26;
  logic [29:0] br_a, bp_a;
  logic [31:2] rdat, cpc, npc, rpc, pipe_npc, next_pc;

  modport pc (
    input pcSel, pcEN, bpSel, bpFlush, pdStatus,
          pipe_npc, rpc, rdat, immJ26, br_a, bp_a,
    output cpc, npc, next_pc
  );

endinterface

`endif

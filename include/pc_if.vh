`ifndef PC_IF_VH
`define PC_IF_VH

`include "cpu_types_pkg.vh"
`include "mux_types_pkg.vh"

import cpu_types_pkg::*;
import mux_types_pkg::*;

interface pc_if;
  logic pcEn;
  logic [25:0] immJ26;
  pcMux pcSel;
  word_t rdat, ext32, cpc;

  modport pc (
    input rdat, immJ26, ext32, pcSel, pcEn,
    output cpc
    );

  modport cu (
    output pcEn, immJ26, pcSel, ext32
  );
endinterface

`endif

`ifndef DECODE_UNIT_IF_VH
`define DECODE_UNIT_IF_VH

`include "cpu_types_pkg.vh"
`include "mux_types_pkg.vh"

import cpu_types_pkg::*;
import mux_types_pkg::*;

interface decode_unit_if;
  logic WEN, dREN, dWEN;
  logic sign, ef, halt;
  logic [25:0] immJ26;
  word_t ins;
  aluBMux aluBSel;
  rfInMux rfInSel;
  pcMux pcSel;
  aluop_t op;
  regbits_t wsel, rsel1, rsel2;

  modport du (
    input ins, ef,
    output WEN, dREN, dWEN,
           aluBSel, rfInSel, pcSel, wsel,
           rsel1, rsel2, sign, immJ26,
           op, halt
  );
endinterface

`endif

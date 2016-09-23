`ifndef DECODE_UNIT_IF_VH
`define DECODE_UNIT_IF_VH

`include "cpu_types_pkg.vh"
`include "mux_types_pkg.vh"

import cpu_types_pkg::*;
import mux_types_pkg::*;

interface decode_unit_if;
  logic halt, WEN, ihit, dhit, zf, pcEn;
  logic [25:0] immJ26;
  word_t shamt, ext32, ins;
  aluBMux aluBSel;
  rfInMux rfInSel;
  pcMux pcSel;
  aluop_t op;
  regbits_t wsel, rsel1, rsel2;

  modport du (
    input ins, zf, ihit, dhit,
    output shamt, ext32, aluBSel, rfInSel, wsel,
           rsel1, rsel2, WEN, pcEn, op, pcSel,
           halt, immJ26
  );
endinterface

`endif

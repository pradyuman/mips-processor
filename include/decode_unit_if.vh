`ifndef DECODE_UNIT_IF_VH
`define DECODE_UNIT_IF_VH

`include "cpu_types_pkg.vh"
`include "mux_types_pkg.vh"

import cpu_types_pkg::*;
import mux_types_pkg::*;

interface decode_unit_if;
  logic halt, WEN, ihit, dhit, ef, iREN, dREN, dWEN;
  logic [15:0] signext;
  word_t ins;
  aluBMux aluBSel;
  rfInMux rfInSel;
  pcMux pcSel;
  aluop_t op;
  regbits_t wsel, rsel1, rsel2;

  modport du (
    input ins, ef, ihit, dhit,
    output iREN, dREN, dWEN, signext, aluBSel, rfInSel, wsel,
           rsel1, rsel2, WEN, op, pcSel, halt
  );
endinterface

`endif

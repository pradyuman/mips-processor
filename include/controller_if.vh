`ifndef CONTROLLER_IF_VH
`define CONTROLLER_IF_VH

`include "cpu_types_pkg.vh"
import cpu_types_pkg::*;

interface controller_if;
  // Datapath Cache Signals
  logic ihit, dhit, halt;
  word_t imemload;

  // Register File Signals
  logic WEN;
  regbits_t wsel, rsel1, rsel2;

  // Controller Output Signals
  word_t ext32, shamt;
  logic [1:0] alu_b_sel, rf_wdat_sel;

  modport cr (
    input ihit, imemload, dhit,
    output alu_b_sel, rf_wdat_sel, ext32, shamt, halt,
           WEN, wsel, rsel1, rsel2
  );
endinterface

`endif

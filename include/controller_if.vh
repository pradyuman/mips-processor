`ifndef CONTROLLER_IF_VH
`define CONTROLLER_IF_VH
`include "cpu_types_pkg.vh"
`include "mux_signals.vh"
import cpu_types_pkg::word_t;
import mux_signals::*;

interface controller_if;
  word_t ext32, shamt;
  alu_b_ms alu_b_sel;
  rf_wdat_ms rf_wdat_sel;

  modport cr (
    output alu_b_sel, rf_wdat_sel, ext32, shamt
  );
endinterface

`endif

`ifndef CONTROLLER_IF_VH
`define CONTROLLER_IF_VH

`include "cpu_types_pkg.vh"
import cpu_types_pkg::word_t;

interface controller_if;
  word_t ext32, shamt;
  logic [1:0] alu_b_sel, rf_wdat_sel;

  modport cr (
    output alu_b_sel, rf_wdat_sel, ext32, shamt
  );
endinterface

`endif

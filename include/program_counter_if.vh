`ifndef PROGRAM_COUNTER_IF_VH
`define PROGRAM_COUNTER_IF_VH
`include "cpu_types_pkg.vh"
import cpu_types_pkg::*;

interface program_counter_if;
  word_t val, ext32, jr_a;
  logic [1:0] sel;
  logic [ADDR_W-1:0] jump_a;
  logic en;

  modport pc (
    input  en, sel, ext32, jr_a, jump_a,
    output val
  );

  modport cr (
    output en, sel, jump_a
  );
endinterface

`endif

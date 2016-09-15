`ifndef PROGRAM_COUNTER_IF_VH
`define PROGRAM_COUNTER_IF_VH
`include "cpu_types_pkg.vh"
`include "mux_signals.vh"
import cpu_types_pkg::*;
import mux_signals::pc_ms;

interface program_counter_if;
  word_t val, ext32, jr_a;
  pc_ms sel;
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

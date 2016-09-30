`ifndef HAZARD_UNIT_IF_VH
`define HAZARD_UNIT_IF_VH

`include "cpu_types_pkg.vh"

import cpu_types_pkg::word_t;

interface hazard_unit_if;
  logic fdEN, pcEN, dx_flush;
  word_t dec_instr, ex_instr, mem_instr;

  modport hu (
    input  dec_instr, ex_instr, mem_instr,
    output fdEN, pcEN, dx_flush
  );

endinterface

`endif

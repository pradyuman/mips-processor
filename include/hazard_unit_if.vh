`ifndef HAZARD_UNIT_IF_VH
`define HAZARD_UNIT_IF_VH

`include "cpu_types_pkg.vh"

import cpu_types_pkg::*;

interface hazard_unit_if;
  logic ex_rfWEN, mem_rfWEN, dx_flush;
  logic[31:16] dec_reg, ex_reg, mem_reg;
  word_t mem_aluout;
  regbits_t ex_dest, mem_dest;

  modport hu (
    input  ex_rfWEN, mem_rfWEN,
           dec_reg, ex_reg, mem_reg,
           ex_dest, mem_dest,
    output dx_flush
  );

endinterface

`endif

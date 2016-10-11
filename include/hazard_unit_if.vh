`ifndef HAZARD_UNIT_IF_VH
`define HAZARD_UNIT_IF_VH

`include "cpu_types_pkg.vh"

import cpu_types_pkg::*;

interface hazard_unit_if;
  logic ihit, fdEN, pcEN, dx_flush;
  logic ex_rfWEN, mem_rfWEN;
  logic[31:16] dec_reg, ex_reg, mem_reg;
  regbits_t ex_dest, mem_dest;

  modport hu (
    input  ihit, ex_rfWEN, mem_rfWEN,
           dec_reg, ex_reg, mem_reg,
           ex_dest, mem_dest,
    output fdEN, pcEN, dx_flush
  );

endinterface

`endif

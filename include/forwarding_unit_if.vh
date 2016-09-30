`ifndef FORWARDING_UNIT_IF_VH
`define FORWARDING_UNIT_IF_VH

`include "cpu_types_pkg.vh"

import cpu_types_pkg::*;

interface forwarding_unit_if;
  logic [25:11] ex_reg, mem_reg, wb_reg;
  logic ex_rfWEN, mem_rfWEN, wb_rfWEN;
  word_t aluout, alubr_f;
  fwdMux brSel_f, aSel_f, bSel_f;

  modport fu (
    input  ex_reg, mem_reg, wb_reg,
           ex_rfWEN, mem_rfWEN, wb_rfWEN,
           aluout
    output alubr_f, brSel_f, aSel_f, bSel_f
  );

endinterface

`endif

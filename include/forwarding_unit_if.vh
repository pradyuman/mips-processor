`ifndef FORWARDING_UNIT_IF_VH
`define FORWARDING_UNIT_IF_VH

`include "cpu_types_pkg.vh"
`include "mux_types_pkg.vh"

import cpu_types_pkg::*;
import mux_types_pkg::fwdMux;

interface forwarding_unit_if;
  logic [25:16] ex_reg, mem_reg, wb_reg;
  logic ex_rfWEN, mem_rfWEN, wb_rfWEN;
  regbits_t ex_dest, mem_dest, wb_dest;
  word_t ex_aluout, mem_aluout, wb_aluout;
  word_t rdat1_f, rdat2_f, alubr_f;
  fwdMux brSel_f, aSel_f, bSel_f;

  modport fu (
    input  ex_reg, mem_reg, wb_reg,
           ex_dest, mem_dest, wb_dest,
           ex_rfWEN, mem_rfWEN, wb_rfWEN,
           ex_aluout, mem_aluout, wb_aluout,
    output brSel_f, aSel_f, bSel_f,
           rdat1_f, rdat2_f, alubr_f
  );

endinterface

`endif

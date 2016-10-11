`ifndef FORWARDING_UNIT_IF_VH
`define FORWARDING_UNIT_IF_VH

`include "cpu_types_pkg.vh"
`include "mux_types_pkg.vh"

import cpu_types_pkg::*;
import mux_types_pkg::fwdMux;

interface forwarding_unit_if;
  logic [31:16] dec_reg, ex_reg, mem_reg, wb_reg;
  logic ex_rfWEN, mem_rfWEN, wb_rfWEN;
  regbits_t ex_dest, mem_dest, wb_dest;
  word_t mem_aluout, wb_rfwdat;
  word_t mem_lui32, wb_lui32;
  word_t rdat1_f, rdat2_f, dmem_f, regbr_f;
  fwdMux rsBrSel_f, rtBrSel_f;
  fwdMux aSel_f, bSel_f, dstrSel_f;

  modport fu (
    input  dec_reg, ex_reg, mem_reg, wb_reg,
           ex_dest, mem_dest, wb_dest,
           ex_rfWEN, mem_rfWEN, wb_rfWEN,
           mem_aluout, wb_rfwdat,
           mem_lui32, wb_lui32,
    output rsBrSel_f, rtBrSel_f,
           aSel_f, bSel_f, dstrSel_f,
           rdat1_f, rdat2_f, dmem_f, regbr_f
  );

endinterface

`endif

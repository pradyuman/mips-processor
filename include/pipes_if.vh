`ifndef PIPES_IF_VH
`define PIPES_IF_VH

`include "cpu_types_pkg.vh"
`include "mux_types_pkg.vh"

import cpu_types_pkg::*;
import mux_types_pkg::*;

interface IF_ID_pipe_if;
  logic EN, flush;
  word_t instr_i, npc_i;
  word_t instr_o, pipe_npc_o;

  modport if_id (
    input EN, flush, instr_i, npc_i,
    output instr_o, pipe_npc_o
  );

  modport du (
    input instr_o
  );
endinterface

interface ID_EX_pipe_if;
  logic EN, flush;

  word_t instr_i, pipe_npc_i, rdat1_i, rdat2_i;
  word_t instr_o, pipe_npc_o, rdat1_o, rdat2_o, ext32_o, extshamt_o;

  aluBMux aluBSel_i, aluBSel_o;
  rfInMux rfInSel_i, rfInSel_o;
  aluop_t aluop_i, aluop_o;

  logic sign_i;
  regbits_t wsel_i, wsel_o;

  logic rfWEN_i, dREN_i, dWEN_i, halt_i;
  logic rfWEN_o, dREN_o, dWEN_o, halt_o;

  modport id_ex (
    input EN, flush,
          instr_i, pipe_npc_i, rdat1_i, rdat2_i,
          aluBSel_i, aluop_i, wsel_i,
          sign_i, rfInSel_i, rfWEN_i,
          dREN_i, dWEN_i, halt_i,
    output instr_o, pipe_npc_o, rdat1_o, rdat2_o,
           aluBSel_o, aluop_o, wsel_o,
           ext32_o, extshamt_o,
           rfInSel_o, rfWEN_o,
           dREN_o, dWEN_o, halt_o
  );
endinterface

interface EX_MEM_pipe_if;
  logic EN, flush;

  word_t instr_i, pipe_npc_i, aluout_i, rdat2_i;
  word_t instr_o, pipe_npc_o, aluout_o, rdat2_o;

  rfInMux rfInSel_i, rfInSel_o;
  regbits_t wsel_i, wsel_o;

  logic rfWEN_i, dREN_i, dWEN_i, halt_i;
  logic rfWEN_o, dREN_o, dWEN_o, halt_o;

  modport ex_mem (
    input EN, flush,
          instr_i, pipe_npc_i, aluout_i, rdat2_i,
          rfInSel_i, wsel_i,
          rfWEN_i, dREN_i, dWEN_i, halt_i,
    output instr_o, pipe_npc_o, aluout_o, rdat2_o,
           rfInSel_o, wsel_o,
           rfWEN_o, dREN_o, dWEN_o, halt_o
  );
endinterface

interface MEM_WB_pipe_if;
  logic EN, flush;

  word_t instr_i, pipe_npc_i, aluout_i, dmemload_i;
  word_t lui32_o, pipe_npc_o, aluout_o, dmemload_o;

  rfInMux rfInSel_i, rfInSel_o;
  regibits_t wsel_i, wsel_o;

  logic rfWEN_i, halt_i;
  logic rfWEN_o, halt_o;

  modport mem_wb (
    input  EN, flush,
           instr_i, pipe_npc_i, aluout_i, dmemload_i,
           rfInSel_i, wsel_i, rfWEN_i, halt_i,
    output lui32_o, pipe_npc_o, aluout_o, dmemload_o,
           rfInSel_o, wsel_o, rfWEN_o, halt_o
    );
endinterface

`endif

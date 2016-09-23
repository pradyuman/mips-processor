`ifndef PIPES_IF_VH
`define PIPES_IF_VH

`include "cpu_types_pkg.vh"

import cpu_types_pkg::*;

interface IF_ID_pipe_if;
  logic EN, flush;
  word_t instr_i, npc_i;
  word_t instr_o, npc_o;

  modport if_id (
    input EN, flush, instr_i, npc_i,
    output instr_o, npc_o
  );

  modport du (
    input instr_o
  );
endinterface

interface ID_EX_pipe_if;
  logic EN, flush;

  word_t instr_i;
  logic [31:16] signext_i;
  word_t ext32_o, extshamt_o;
  logic [ADDR_W-1:0] immJ26_o;

  word_t npc_i, rdat1_i, rdat2_i;
  word_t npc_o, rdat1_o, rdat2_o;

  logic [1:0] aluBSel_i, aluBSel_o;
  logic [3:0] aluop_i, aluop_o;
  logic [1:0] pcSel_i, pcSel_o;
  logic [4:0] wsel_i, wsel_o;

  logic iREN_i, dREN_i, dWEN_i;
  logic iREN_o, dREN_o, dWEN_o;

  modport id_ex (
    input EN, flush,
          instr_i, npc_i, rdat1_i, rdat2_i,
          aluBSel_i, aluop_i, pcSel_i, wsel_i,
          signext_i, iREN_i, dREN_i, dWEN_i,
    output npc_o, rdat1_o, rdat2_o,
           aluBSel_o, aluop_o, pcSel_o, wsel_o,
           ext32_o, extshamt_o, immJ26_o,
           iREN_o, dREN_o, dWEN_o
  );
endinterface

`endif

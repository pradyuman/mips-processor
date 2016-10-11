`include "mux_types_pkg.vh"

`include "alu_if.vh"
`include "decode_unit_if.vh"
`include "datapath_cache_if.vh"
`include "forwarding_unit_if.vh"
`include "hazard_unit_if.vh"
`include "pipes_if.vh"
`include "pc_if.vh"
`include "register_file_if.vh"
`include "request_unit_if.vh"

import mux_types_pkg::*;

module datapath (
  input logic CLK, nRST,
  datapath_cache_if.dp dpif
);
  parameter PC_INIT = 0;

  alu_if aluif();
  decode_unit_if duif();
  forwarding_unit_if fuif();
  hazard_unit_if huif();
  pc_if pcif();
  register_file_if rfif();

  IF_ID_pipe_if fdpif();
  ID_EX_pipe_if dxpif();
  EX_MEM_pipe_if xmpif();
  MEM_WB_pipe_if mwpif();

  alu ALU(aluif);
  decode_unit DU(duif);
  pc #(PC_INIT) PC(CLK, nRST, pcif);
  register_file RF(CLK, nRST, rfif);
  forwarding_unit FU (fuif);
  hazard_unit HU (huif);

  IF_ID_pipe FDP(CLK, nRST, fdpif);
  ID_EX_pipe DXP(CLK, nRST, dxpif);
  EX_MEM_pipe XMP(CLK, nRST, xmpif);
  MEM_WB_pipe MWP(CLK, nRST, mwpif);

  word_t alubT;

  assign fdpif.flush = dpif.ihit && duif.pcSel != PC_NPC;
  assign dxpif.flush = huif.dx_flush;
  assign xmpif.flush = dpif.dhit;
  assign mwpif.flush = 0;

  assign fdpif.EN = huif.fdEN;
  assign dxpif.EN = dpif.ihit;
  assign xmpif.EN = dpif.ihit | huif.dx_flush;
  assign mwpif.EN = dpif.ihit | dpif.dhit | huif.dx_flush;

  // IF
  assign dpif.imemaddr = pcif.cpc << 2;
  assign fdpif.instr_i = dpif.imemload;
  assign fdpif.npc_i = pcif.npc;

  // ID
  assign duif.ins = fdpif.instr_o;
  assign dxpif.pipe_npc_i = fdpif.pipe_npc_o;

  assign dxpif.rdat1_i = rfif.rdat1;
  assign dxpif.rdat2_i = rfif.rdat2;
  assign dxpif.halt_i = duif.halt;
  assign dxpif.rfWEN_i = duif.WEN;
  assign dxpif.rfInSel_i = duif.rfInSel;
  assign dxpif.instr_i = fdpif.instr_o;
  assign dxpif.sign_i = duif.sign;
  assign dxpif.aluBSel_i = duif.aluBSel;
  assign dxpif.aluop_i = duif.op;
  assign dxpif.wsel_i = duif.wsel;
  assign dxpif.dREN_i = duif.dREN;
  assign dxpif.dWEN_i = duif.dWEN;

  assign rfif.rsel1 = duif.rsel1;
  assign rfif.rsel2 = duif.rsel2;

  always_comb casez({fuif.rsBrSel_f, fuif.rtBrSel_f})
    2'b10: duif.ef = fuif.regbr_f == rfif.rdat2;
    2'b01: duif.ef = fuif.regbr_f == rfif.rdat1;
    default: duif.ef = rfif.rdat1 == rfif.rdat2;
  endcase

  // PC
  assign pcif.pcSel = duif.pcSel;
  assign pcif.pipe_npc = fdpif.pipe_npc_o;
  assign pcif.immJ26 = duif.immJ26;
  assign pcif.ext30 = {{14{duif.sign}}, fdpif.instr_o[15:0]};
  assign pcif.pcEN = huif.pcEN;
  always_comb casez(fuif.rsBrSel_f)
    STD: pcif.rdat = rfif.rdat1[31:2];
    FWD: pcif.rdat = fuif.regbr_f[31:2];
  endcase

  // X
  always_comb casez(dxpif.aluBSel_o)
    ALUB_RDAT: aluif.b = alubT;
    ALUB_EXT: aluif.b = dxpif.ext32_o;
    ALUB_SHAMT: aluif.b = dxpif.extshamt_o;
  endcase
  always_comb casez(fuif.aSel_f)
    STD: aluif.a = dxpif.rdat1_o;
    FWD: aluif.a = fuif.rdat1_f;
  endcase
  always_comb casez(fuif.bSel_f)
    STD: alubT = dxpif.rdat2_o;
    FWD: alubT = fuif.rdat2_f;
  endcase
  assign aluif.op = dxpif.aluop_o;

  assign xmpif.instr_i = dxpif.instr_o;
  assign xmpif.aluout_i = aluif.out;
  assign xmpif.rdat2_i = dxpif.rdat2_o;
  assign xmpif.pipe_npc_i = dxpif.pipe_npc_o;
  assign xmpif.wsel_i = dxpif.wsel_o;
  assign xmpif.dREN_i = dxpif.dREN_o;
  assign xmpif.dWEN_i = dxpif.dWEN_o;
  assign xmpif.halt_i = dxpif.halt_o;
  assign xmpif.rfInSel_i = dxpif.rfInSel_o;
  assign xmpif.rfWEN_i = dxpif.rfWEN_o;

  // MEM
  assign mwpif.pipe_npc_i = xmpif.pipe_npc_o;
  assign mwpif.instr_i = xmpif.instr_o;
  assign mwpif.rfInSel_i = xmpif.rfInSel_o;
  assign mwpif.rfWEN_i = xmpif.rfWEN_o;
  assign mwpif.wsel_i = xmpif.wsel_o;
  assign mwpif.halt_i = xmpif.halt_o;
  assign mwpif.aluout_i = xmpif.aluout_o;

  assign dpif.imemREN = 1;
  assign dpif.dmemREN = xmpif.dREN_o;
  assign dpif.dmemWEN = xmpif.dWEN_o;
  assign dpif.dmemaddr = xmpif.aluout_o;
  always_comb casez(fuif.dstrSel_f)
    STD: dpif.dmemstore = xmpif.rdat2_o;
    FWD: dpif.dmemstore = fuif.dmem_f;
  endcase

  assign mwpif.dmemload_i = dpif.dmemload;

  // MEM/WB Registers
  assign dpif.halt = mwpif.halt_o;
  assign rfif.wsel = mwpif.wsel_o;
  assign rfif.WEN = mwpif.rfWEN_o;

  always_comb casez(mwpif.rfInSel_o)
    RFIN_LUI: rfif.wdat = mwpif.lui32_o;
    RFIN_NPC: rfif.wdat = {mwpif.pipe_npc_o, 2'b0};
    RFIN_ALU: rfif.wdat = mwpif.aluout_o;
    RFIN_RAM: rfif.wdat = mwpif.dmemload_o;
  endcase

  // Forwarding Unit
  assign fuif.dec_reg = fdpif.instr_o[31:16];
  assign fuif.ex_reg = dxpif.instr_o[31:16];
  assign fuif.mem_reg = xmpif.instr_o[31:16];
  assign fuif.wb_reg = mwpif.instr_o[31:16];

  assign fuif.ex_rfWEN = dxpif.rfWEN_o;
  assign fuif.mem_rfWEN = xmpif.rfWEN_o;
  assign fuif.wb_rfWEN = mwpif.rfWEN_o;

  assign fuif.ex_dest = dxpif.wsel_o;
  assign fuif.mem_dest = xmpif.wsel_o;
  assign fuif.wb_dest = mwpif.wsel_o;

  assign fuif.mem_aluout = xmpif.aluout_o;
  assign fuif.wb_rfwdat = rfif.wdat;

  assign fuif.mem_lui32 = {xmpif.instr_o[15:0], {16{1'b0}}};
  assign fuif.wb_lui32 = mwpif.lui32_o;

  // Hazard Unit
  assign huif.ihit = dpif.ihit;
  assign huif.dec_reg = fdpif.instr_o[31:16];
  assign huif.ex_reg = dxpif.instr_o[31:16];
  assign huif.mem_reg = xmpif.instr_o[31:16];

  assign huif.ex_rfWEN = dxpif.rfWEN_o;
  assign huif.mem_rfWEN = xmpif.rfWEN_o;

  assign huif.ex_dest = dxpif.wsel_o;
  assign huif.mem_dest = xmpif.wsel_o;

  assign huif.mem_aluout = xmpif.aluout_o;

endmodule

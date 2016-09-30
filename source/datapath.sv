`include "mux_types_pkg.vh"

`include "alu_if.vh"
`include "decode_unit_if.vh"
`include "datapath_cache_if.vh"
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
  pc_if pcif();
  register_file_if rfif();
  forwarding_unit_if fuif();

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

  assign fdpif.flush = duif.pcSel != PC_NPC;
  assign dxpif.flush = huif.dx_flush;
  assign xmpif.flush = dpif.dhit;
  assign mwpif.flush = 0;

  assign fdpif.EN = huif.fdEN;
  assign dxpif.EN = dpif.ihit;
  assign xmpif.EN = dpif.ihit;
  assign mwpif.EN = dpif.ihit | dpif.dhit;

  // IF
  assign dpif.imemaddr = pcif.cpc;
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
  assign dxpif.iREN_i = duif.iREN;
  assign dxpif.dREN_i = duif.dREN;
  assign dxpif.dWEN_i = duif.dWEN;

  assign rfif.rsel1 = duif.rsel1;
  assign rfif.rsel2 = duif.rsel2;
  assign duif.ef = rfif.rdat1 == rfif.rdat2;
  // PC
  assign pcif.pcSel = duif.pcSel;
  assign pcif.pipe_npc = fdpif.pipe_npc_o;
  assign pcif.immJ26 = duif.immJ26;
  assign pcif.ext32 = {{16{duif.sign}}, fdpif.instr_o[15:0]};
  assign pcif.pcEN = huif.pcEN;
  always_comb casez(fuif.brSel_f)
    STD: pcif.rdat = duif.rdat;
    FWD: pcif.rdat = fuif.alubr_f;
  endcase


  // EX
  always_comb casez(dxpif.aluBSel_o)
    ALUB_RDAT: alubT = dxpif.rdat2_o;
    ALUB_EXT: alubT = dxpif.ext32_o;
    ALUB_SHAMT: alubT = dxpif.extshamt_o;
  endcase
  always_comb casez(fuif.bSel_f)
                STD: aluif.b = alubT;
                FWD: aluif.b = fuif.rdat2_f;
  endcase
  always_comb casez(fuif.aSel_f)
    STD: dxpif.rdat1_o;
    FWD: fuif.rdat1_f;
  endcase
  assign aluif.op = dxpif.aluop_o;

  assign xmpif.instr_i = dxpif.instr_o;
  assign xmpif.aluout_i = aluif.out;
  assign xmpif.rdat2_i = dxpif.rdat2_o;
  assign xmpif.pipe_npc_i = dxpif.pipe_npc_o;
  assign xmpif.wsel_i = dxpif.wsel_o;
  assign xmpif.iREN_i = dxpif.iREN_o;
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
  assign aluif.a = dxpif.rdat1_o;
  assign dpif.dmemREN = xmpif.dREN_o;
  assign dpif.dmemWEN = xmpif.dWEN_o;
  assign dpif.dmemaddr = xmpif.aluout_o;
  assign dpif.dmemstore = xmpif.rdat2_o;

  assign mwpif.dmemload_i = dpif.dmemload;

  // WB
  assign dpif.halt = mwpif.halt_o;
  assign rfif.wsel = mwpif.wsel_o;
  assign rfif.WEN = mwpif.rfWEN_o;

  always_comb casez(mwpif.rfInSel_o)
    RFIN_LUI: rfif.wdat = mwpif.lui32_o;
    RFIN_NPC: rfif.wdat = mwpif.pipe_npc_o;
    RFIN_ALU: rfif.wdat = mwpif.aluout_o;
    RFIN_RAM: rfif.wdat = mwpif.dmemload_o;
  endcase
  // FU
  assign fuif.ex_reg = dxpif.instr_o[25:16];
  assign fuif.mem_reg = xmpif.instr_o[25:16];
  assign fuif.wb_reg = mwpif.instr_o[25:16];
  assign fuif.ex_rfWEN = dxpif.rfWEN_o;
  assign fuif.mem_rfWEN = xmpif.rfWEN_o;
  assign fuif.wb_rfWEN = mwpif.rfWEN_o;
  assign fuif.ex_dest = dxpif.wsel;
  assign fuif.mem_dest = xmpif.wsel;
  assign fuif.wb_dest = mwpif.wsel;
  assign fuif.ex_aluout = aluif.out;
  assign fuif.mem_aluout = xmpif.aluout_o;
  assign fuif.wb_aluout = mwpif.aluout_o;
  // HU
  assign huif.dec_instr = fdpif.instr;
  assign huif.ex_instr = dxpif.instr;
  assign huif.mem_instr = xmpif.instr;

endmodule

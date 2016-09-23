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
  datapath_cache_if.dp dcif
);
  parameter PC_INIT = 0;

  alu_if aluif();
  decode_unit_if duif();
  pc_if pcif();
  register_file_if rfif();
  request_unit_if ruif();

  IF_ID_pipe_if fdpif();
  ID_EX_pipe_if dxpif();
  EX_MEM_pipe_if xmpif();

  alu ALU(aluif);
  decode_unit CU(duif);
  pc #(PC_INIT) PC(CLK, nRST, pcif);
  register_file RF(CLK, nRST, rfif);
  request_unit RU(CLK, nRST, ruif);

  IF_ID_pipe FDP(CLK, nRST, fdpif);
  ID_EX_pipe DXP(CLK, nRST, dxpif);
  EX_MEM_pipe XMP(CLK, nRST, xmpif);

  logic halt;
  always_ff @(posedge CLK, negedge nRST)
    if(~nRST) halt <= 0;
    else halt <= duif.halt;

  assign dcif.halt = halt;

  assign dcif.imemaddr = pcif.cpc;
  assign dcif.dmemstore = rfif.rdat2;

  assign aluif.a = rfif.rdat1;
  assign dcif.dmemaddr = aluif.out;

  assign rfif.wsel = duif. wsel;
  assign rfif.rsel1 = duif.rsel1;
  assign rfif.rsel2 = duif.rsel2;
  assign rfif.WEN = duif.WEN;

  assign aluif.op = duif.op;

  assign pcif.rdat = rfif.rdat1;
  assign pcif.pcEn = duif.pcEn;
  assign pcif.pcSel = duif.pcSel;
  assign pcif.immJ26 = duif.immJ26;
  assign pcif.ext32 = duif.ext32;

  assign duif.zf = aluif.zf;
  assign duif.ins = dcif.imemload;
  assign duif.ihit = dcif.ihit;
  assign duif.dhit = dcif.dhit;

  assign ruif.ihit = dcif.ihit;
  assign ruif.dhit = dcif.dhit;
  assign ruif.ins = dcif.imemload;
  assign dcif.dmemWEN = ruif.dWEN;
  assign dcif.dmemREN = ruif.dREN;
  assign dcif.imemREN = ruif.iREN;

  always_comb casez(duif.aluBSel)
    ALUB_RDAT: aluif.b = rfif.rdat2;
    ALUB_EXT: aluif.b = duif.ext32;
    ALUB_SHAMT: aluif.b = duif.shamt;
  endcase

  always_comb casez(duif.rfInSel)
    RFIN_LUI: rfif.wdat = word_t'({dcif.imemload[15:0], {16{1'b0}}});
    RFIN_NPC: rfif.wdat = pcif.cpc + 4;
    RFIN_ALU: rfif.wdat = aluif.out;
    RFIN_RAM: rfif.wdat = dcif.dmemload;
  endcase

endmodule

`include "cpu_types_pkg.vh"
`include "mux_types_pkg.vh"
`include "pc_if.vh"
`include "datapath_cache_if.vh"
`include "register_file_if.vh"
`include "alu_if.vh"
`include "control_unit_if.vh"
`include "request_unit_if.vh"

import cpu_types_pkg::*;
import mux_types_pkg::*;

module datapath (
  input logic CLK, nRST,
  datapath_cache_if.dp dcif
);

  parameter PC_INIT = 0;

  register_file_if rfif ();
  alu_if aluif ();
  pc_if pcif ();
  control_unit_if cuif ();
  request_unit_if ruif ();

  register_file RF (CLK, nRST, rfif);
  alu ALU (aluif);
  request_unit RU (CLK, nRST, ruif);
  control_unit CU (cuif);
  pc #(PC_INIT) PC (CLK, nRST, pcif);

  logic halt;
  always_ff @(posedge CLK, negedge nRST)
    if(~nRST) halt <= 0;
    else halt <= cuif.halt;

  assign dcif.halt = halt;

  assign dcif.imemaddr = pcif.cpc;
  assign dcif.dmemstore = rfif.rdat2;

  assign aluif.a = rfif.rdat1;
  assign dcif.dmemaddr = aluif.out;

  assign rfif.wsel = cuif. wsel;
  assign rfif.rsel1 = cuif.rsel1;
  assign rfif.rsel2 = cuif.rsel2;
  assign rfif.WEN = cuif.WEN;

  assign aluif.op = cuif.op;

  assign pcif.rdat = rfif.rdat1;
  assign pcif.pcEn = cuif.pcEn;
  assign pcif.pcSel = cuif.pcSel;
  assign pcif.immJ26 = cuif.immJ26;
  assign pcif.ext32 = cuif.ext32;

  assign cuif.zf = aluif.zf;
  assign cuif.ins = dcif.imemload;
  assign cuif.ihit = dcif.ihit;
  assign cuif.dhit = dcif.dhit;

  assign ruif.ihit = dcif.ihit;
  assign ruif.dhit = dcif.dhit;
  assign ruif.ins = dcif.imemload;
  assign dcif.dmemWEN = ruif.dWEN;
  assign dcif.dmemREN = ruif.dREN;
  assign dcif.imemREN = ruif.iREN;

  always_comb casez(cuif.aluBSel)
    ALUB_RDAT: aluif.b = rfif.rdat2;
    ALUB_EXT: aluif.b = cuif.ext32;
    ALUB_SHAMT: aluif.b = cuif.shamt;
  endcase

  always_comb casez(cuif.rfInSel)
    RFIN_LUI: rfif.wdat = word_t'({dcif.imemload[15:0], {16{1'b0}}});
    RFIN_NPC: rfif.wdat = pcif.cpc + 4;
    RFIN_ALU: rfif.wdat = aluif.out;
    RFIN_RAM: rfif.wdat = dcif.dmemload;
  endcase

endmodule

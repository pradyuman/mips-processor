`include "pc_if.vh"
`include "cpu_types_pkg.vh"
`include "mux_types_pkg.vh"

import cpu_types_pkg::*;
import mux_types_pkg::*;

module pc(
  input logic CLK, nRST,
  pc_if.pc pcif
);
  parameter PC_INIT = 0;
  word_t next_pc;

  always_ff @(posedge CLK, negedge nRST)
    if (~nRST) pcif.cpc <= PC_INIT;
    else if (pcif.pcEn) pcif.cpc <= next_pc;

  pcMux muxPc;
  assign muxPc = pcif.pcSel;
  assign pcif.npc = pcif.cpc + 4;

  always_comb case(muxPc)
    PC_NPC: next_pc = pcif.npc;
    PC_JR: next_pc = pcif.rdat;
    PC_JUMP: next_pc =  {{pcif.pipe_npc[31:28]}, {pcif.immJ26}, {2'b00}};
    PC_BR: next_pc = {pcif.ext32[30:0],2'b0} + pcif.pipe_npc;
  endcase

endmodule

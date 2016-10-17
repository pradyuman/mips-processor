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
  logic [31:2] next_pc;

  always_ff @(posedge CLK, negedge nRST)
    if (~nRST) pcif.cpc <= PC_INIT;
    else if (pcif.pcEN) pcif.cpc <= next_pc;

  assign pcif.npc = pcif.cpc + 1;

  always_comb begin
    next_pc = pcif.next_pc;
    if (pcif.pdStatus) next_pc = pcif.rpc;
    else if (pcif.bpSel) next_pc = pcif.bp_a;
  end

  always_comb case(pcif.pcSel)
    PC_NPC: pcif.next_pc = pcif.npc;
    PC_JR: pcif.next_pc = pcif.rdat;
    PC_JUMP: pcif.next_pc =  {{pcif.pipe_npc[31:28]}, {pcif.immJ26}};
    PC_BR: pcif.next_pc = pcif.br_a;
  endcase

endmodule

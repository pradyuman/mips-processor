`include "cpu_types_pkg.vh"
`include "mux_signals.vh"
`include "program_counter_if.vh"
import cpu_types_pkg::word_t;
import mux_signals::*;

module program_counter #(parameter PC_INIT = 0) (
  input CLK, nRST, program_counter_if.pc pcif
);
  word_t next, npc = pcif.val + 4;
  always_ff @(posedge CLK, negedge nRST)
    if (!nRST) pcif.val <= PC_INIT;
    else if (pcif.en) pcif.val <= next;

  always_comb unique case (pcif.sel) inside
    BRANCH: next = npc + pcif.ext32 << 2;
    JRA: next = pcif.jr_a;
    JUMP: next = { npc[31:28], pcif.jump_a, 2'b00 };
    NPC: next = npc;
  endcase
endmodule


`include "mux_signals.vh"
`include "program_counter_if.vh"
import mux_signals::*;

module program_counter #(parameter PC_INIT = 0) (
  input CLK, nRST,
  program_counter_if.server pcif
);
  logic [31:0] next;
  logic [31:0] npc = pcif.val + 4;
  always_ff @(posedge CLK, negedge nRST)
    if (!nRST) pcif.val <= PC_INIT;
    else pcif.val <= next;

  always_comb unique case (pcif.pc_sel)
    NPC: next = npc;
    JR: next = pcif.jr_a;
    JUMP: next = { npc[31:28], pcif.jump_a, 2'b00 };
    BRANCH: next = npc + 4 + pcif.ext32 << 2;
  endcase

endmodule


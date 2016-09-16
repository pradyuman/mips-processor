`include "cpu_types_pkg.vh"
`include "program_counter_if.vh"
import cpu_types_pkg::word_t;

module program_counter #(parameter PC_INIT = 0) (
  input CLK, nRST, program_counter_if.pc pcif
);
  typedef enum logic [1:0] {
    PC_BRANCH, PC_JRA, PC_JUMP, PC_NPC
  } pc_ms;

  word_t next, npc;
  assign npc = pcif.val + 4;
  always_ff @(posedge CLK, negedge nRST)
    if (!nRST) pcif.val <= PC_INIT;
    else if (pcif.en) pcif.val <= next;

  always_comb casez (pcif.sel)
    PC_BRANCH: next = npc + (pcif.ext32 << 2);
    PC_JRA: next = pcif.jr_a;
    PC_JUMP: next = { npc[31:28], pcif.jump_a, 2'b00 };
    PC_NPC: next = npc;
  endcase
endmodule


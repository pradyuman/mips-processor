`include "pipes_if.vh"

module IF_ID_pipe(
  input CLK, nRST,
  IF_ID_pipe_if.if_id fdpif
);
  always_ff @(posedge CLK, negedge nRST)
    if (!nRST | fdpif.flush) begin
      fdpif.instr_o <= 0;
      fdpif.npc_o <= 0;
    end
    else if (fdpif.EN) begin
      fdpif.instr_o <= fdpif.instr_i;
      fdpif.npc_o <= fdpif.npc_i;
    end
endmodule;

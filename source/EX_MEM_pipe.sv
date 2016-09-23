`include "mux_types_pkg.vh"
`include "pipes_if.vh"

import mux_types_pkg::rfInMux;

module EX_MEM_pipe(
  input CLK, nRST,
  EX_MEM_pipe_if.ex_mem xmpif
);
  always_ff @(posedge CLK, negedge nRST)
    if (!nRST | xmpif.flush) begin
      xmpif.instr_o <= 0;
      xmpif.pipe_npc_o <= 0;
      xmpif.aluout_o <= 0;
      xmpif.rdat2_o <= 0;
      xmpif.rfInSel_o <= rfInMux'(0);
      xmpif.wsel_o <= 0;
      xmpif.rfWEN_o <= 0;
      xmpif.iREN_o <= 0;
      xmpif.dREN_o <= 0;
      xmpif.dWEN_o <= 0;
      xmpif.halt_o <= 0;
    end
    else if (xmpif.EN) begin
      xmpif.instr_o <= xmpif.instr_i;
      xmpif.pipe_npc_o <= xmpif.pipe_npc_i;
      xmpif.aluout_o <= xmpif.aluout_i;
      xmpif.rdat2_o <= xmpif.rdat2_i;
      xmpif.rfInSel_o <= xmpif.rfInSel_i;
      xmpif.wsel_o <= xmpif.wsel_i;
      xmpif.rfWEN_o <= xmpif.rfWEN_i;
      xmpif.iREN_o <= xmpif.iREN_i;
      xmpif.dREN_o <= xmpif.dREN_i;
      xmpif.dWEN_o <= xmpif.dWEN_i;
      xmpif.halt_o <= xmpif.halt_i;
    end
endmodule

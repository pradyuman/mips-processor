`include "cpu_types_pkg.vh"
`include "pipes_if.vh"

import cpu_types_pkg::word_t;

module ID_EX_pipe(
  input CLK, nRST,
  ID_EX_pipe_if.id_ex dxpif
);
  word_t instr_r;

  assign dxpif.ext32_o = { dxpif.signext_i, instr_r[15:0] };
  assign dxpif.extshamt_o = { {27{1'b0}}, instr_r[4:0] };
  assign dxpif.immJ26_o = instr_r[25:0];

  always_ff @(posedge CLK, negedge nRST)
    if (!nRST | dxpif.flush) begin
      instr_r <= 0;
      dxpif.npc_o <= 0;
      dxpif.rdat1_o <= 0;
      dxpif.rdat2_o <= 0;
      dxpif.aluBSel_o <= 0;
      dxpif.aluop_o <= 0;
      dxpif.pcSel_o <= 0;
      dxpif.wsel_o <= 0;
      dxpif.iREN_o <= 0;
      dxpif.dREN_o <= 0;
      dxpif.dWEN_o <= 0;
    end
    else if (dxpif.EN) begin
      instr_r <= dxpif.instr_i;
      dxpif.npc_o <= dxpif.npc_i;
      dxpif.rdat1_o <= dxpif.rdat1_i;
      dxpif.rdat2_o <= dxpif.rdat2_i;
      dxpif.aluBSel_o <= dxpif.aluBSel_i;
      dxpif.aluop_o <= dxpif.aluop_i;
      dxpif.pcSel_o <= dxpif.pcSel_i;
      dxpif.wsel_o <= dxpif.wsel_i;
      dxpif.iREN_o <= dxpif.iREN_i;
      dxpif.dREN_o <= dxpif.dREN_i;
      dxpif.dWEN_o <= dxpif.dWEN_i;
    end
endmodule

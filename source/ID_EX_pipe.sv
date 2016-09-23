`include "pipes_if.vh"

module ID_EX_pipe(
  input CLK, nRST,
  ID_EX_pipe_if.id_ex dxpif
);
  assign dxpif.ext32_o = { dxpif.signext_i, dxpif.instr_o[15:0] };
  assign dxpif.extshamt_o = { {27{1'b0}}, dxpif.instr_o[4:0] };
  assign dxpif.immJ26_o = dxpif.instr_o[25:0];

  always_ff @(posedge CLK, negedge nRST)
    if (!nRST | dxpif.flush) begin
      dxpif.instr_o <= 0;
      dxpif.npc_o <= 0;
      dxpif.rdat1_o <= 0;
      dxpif.rdat2_o <= 0;
      dxpif.aluBSel_o <= 0;
      dxpif.aluop_o <= 0;
      dxpif.pcSel_o <= 0;
      dxpif.wsel_o <= 0;
      dxpif.rfInSel_o <= 0;
      dxpif.rfWEN_o <= 0;
      dxpif.iREN_o <= 0;
      dxpif.dREN_o <= 0;
      dxpif.dWEN_o <= 0;
      dxpif.halt_o <= 0;
    end
    else if (dxpif.EN) begin
      dxpif.instr_o <= dxpif.instr_i;
      dxpif.npc_o <= dxpif.npc_i;
      dxpif.rdat1_o <= dxpif.rdat1_i;
      dxpif.rdat2_o <= dxpif.rdat2_i;
      dxpif.aluBSel_o <= dxpif.aluBSel_i;
      dxpif.aluop_o <= dxpif.aluop_i;
      dxpif.pcSel_o <= dxpif.pcSel_i;
      dxpif.wsel_o <= dxpif.wsel_i;
      dxpif.rfInSel_o <= dxpif.rfInSel_i;
      dxpif.rfWEN_o <= dxpif.rfWEN_i;
      dxpif.iREN_o <= dxpif.iREN_i;
      dxpif.dREN_o <= dxpif.dREN_i;
      dxpif.dWEN_o <= dxpif.dWEN_i;
      dxpif.halt_o <= dxpif.halt_i;
    end
endmodule

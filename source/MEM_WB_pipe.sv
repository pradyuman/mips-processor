`include "cpu_types_pkg.vh"
`include "mux_types_pkg.vh"
`include "pipes_if.vh"

import cpu_types_pkg::word_t;
import mux_types_pkg::rfInMux;

module MEM_WB_pipe(
  input CLK, nRST,
  MEM_WB_pipe_if.mem_wb mwpif
);
  word_t instr_r;

  assign mwpif.lui32_o = { instr_r[31:16], {16{1'b0}} };

  always_ff @(posedge CLK, negedge nRST)
    if (!nRST | mwpif.flush) begin
      instr_r <= 0;
      mwpif.pipe_npc_o <= 0;
      mwpif.aluout_o <= 0;
      mwpif.dmemload_o <= 0;
      mwpif.rfInSel_o <= rfInMux'(0);
      mwpif.wsel_o <= 0;
      mwpif.rfWEN_o <= 0;
      mwpif.halt_o <= 0;
    end
    else if (mwpif.EN) begin
      instr_r <= mwpif.instr_i;
      mwpif.pipe_npc_o <= mwpif.pipe_npc_i;
      mwpif.aluout_o <= mwpif.aluout_i;
      mwpif.dmemload_o <= mwpif.dmemload_i;
      mwpif.rfInSel_o <= mwpif.rfInSel_i;
      mwpif.wsel_o <= mwpif.wsel_i;
      mwpif.rfWEN_o <= mwpif.rfWEN_i;
      mwpif.halt_o <= mwpif.halt_i;
    end
endmodule

`include "hazard_unit_if.vh"
`include "cpu_types_pkg.vh"

import cpu_types_pkg::LW;

module hazard_unit(hazard_unit_if.hu huif);
  always_comb begin
    huif.fdEN = 1;
    huif.pcEN = huif.ihit;
    huif.dx_flush = 0;
    if (huif.mem_instr[15:11] == huif.dec_instr[26:21] ||
        huif.mem_instr[15:11] == huif.dec_instr[20:16] &&
        huif.ex_instr[31:26] == LW) begin
      huif.fdEN = 0;
      huif.pcEN = 0;
      huif.dx_flush = 1;
    end
  end
endmodule

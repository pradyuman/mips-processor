`include "hazard_unit_if.vh"
`include "cpu_types_pkg.vh"

import cpu_types_pkg::*;

module hazard_unit(hazard_unit_if.hu huif);
  opcode_t ex_op;
  regbits_t dec_rs, dec_rt, mem_rs, mem_rt;

  assign dec_rs = huif.dec_reg[25:21];
  assign dec_rt = huif.dec_reg[20:16];
  assign mem_rs = huif.mem_reg[25:21];
  assign mem_rt = huif.mem_reg[20:16];

  assign ex_op = opcode_t'(huif.ex_reg[31:26]);
  always_comb begin
    huif.fdEN = huif.ihit;
    huif.pcEN = huif.ihit;
    huif.dx_flush = 0;
    if (ex_op == LW && huif.mem_rfWEN && (dec_rs == mem_rs || dec_rt == mem_rt)) begin
      huif.fdEN = 0;
      huif.pcEN = 0;
      huif.dx_flush = huif.ihit;
    end
  end

endmodule

`include "hazard_unit_if.vh"
`include "cpu_types_pkg.vh"

import cpu_types_pkg::*;

module hazard_unit(hazard_unit_if.hu huif);
  opcode_t dec_op, ex_op;
  regbits_t dec_rs, dec_rt, mem_rs, mem_rt;

  assign dec_rs = huif.dec_reg[25:21];
  assign dec_rt = huif.dec_reg[20:16];
  assign mem_rs = huif.mem_reg[25:21];
  assign mem_rt = huif.mem_reg[20:16];

  assign dec_op = opcode_t'(huif.dec_reg[31:26]);
  assign ex_op = opcode_t'(huif.ex_reg[31:26]);
  assign mem_op = opcode_t'(huif.mem_reg[31:26]);
  always_comb begin
    huif.dx_flush = 0;
    if (ex_op == LW || ex_op == SW)
      huif.dx_flush = 1;
    else if ((dec_op == BEQ | dec_op == BNE) && huif.ex_rfWEN &&
             (huif.ex_dest == dec_rs | huif.ex_dest == dec_rt))
      huif.dx_flush = 1;
  end
endmodule

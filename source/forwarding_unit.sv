`include "forwarding_unit_if.vh"
`include "cpu_types_pkg.vh"
`include "mux_types_pkg.vh"

import cpu_types_pkg::*;
import mux_types_pkg::*;

module forwarding_unit(forwarding_unit_if.fu fuif);
  opcode_t dec_op, ex_op, mem_op, wb_op;
  regbits_t dec_rs, dec_rt, ex_rs, ex_rt, mem_rs, mem_rt;

  assign dec_rs = fuif.dec_reg[25:21];
  assign dec_rt = fuif.dec_reg[20:16];
  assign ex_rs = fuif.ex_reg[25:21];
  assign ex_rt = fuif.ex_reg[20:16];
  assign mem_rs = fuif.mem_reg[25:21];
  assign mem_rt = fuif.mem_reg[20:16];

  // R-Type Data Hazard Forwarding (rs)
  assign mem_op = opcode_t'(fuif.mem_reg[31:26]);
  assign wb_op = opcode_t'(fuif.wb_reg[31:26]);
  always_comb begin
    fuif.aSel_f = STD;
    fuif.rdat1_f = 'x;
    if (fuif.mem_rfWEN && fuif.mem_dest != 0 && fuif.mem_dest == ex_rs) begin
      fuif.aSel_f = FWD;
      fuif.rdat1_f = mem_op == LUI ? fuif.mem_lui32 : fuif.mem_aluout;
    end
    else if (fuif.wb_rfWEN && fuif.wb_dest != 0 && fuif.wb_dest == ex_rs) begin
      fuif.aSel_f = FWD;
      fuif.rdat1_f = fuif.wb_rfwdat;
    end
  end

  // R-Type Data Hazard Forwarding (rt)
  assign ex_op = opcode_t'(fuif.ex_reg[31:26]);
  always_comb begin
    fuif.bSel_f = STD;
    fuif.rdat2_f = 'x;
    if (fuif.mem_rfWEN && fuif.mem_dest != 0 && fuif.mem_dest == ex_rt) begin
      fuif.bSel_f = FWD;
      fuif.rdat2_f = fuif.mem_aluout;
    end
    else if (fuif.wb_rfWEN && fuif.wb_dest != 0 && fuif.wb_dest == ex_rt) begin
      fuif.bSel_f = FWD;
      fuif.rdat2_f = fuif.wb_rfwdat;
    end
  end

  // Write Back Forward to MEM (rs)
  assign fuif.dmem_f = fuif.wb_rfwdat;
  always_comb
    if ((mem_op == SW || mem_op == SC) && fuif.wb_dest != 0 && fuif.wb_dest == mem_rt)
      fuif.dstrSel_f = FWD;
    else
      fuif.dstrSel_f = STD;

  // Branch Data Hazard Forwarding
  assign dec_op = opcode_t'(fuif.dec_reg[31:26]);
  assign branchop = dec_op == BEQ | dec_op == BNE;
  assign fuif.regbr_f = fuif.mem_aluout;
  always_comb begin
    fuif.rsBrSel_f = STD;
    fuif.rtBrSel_f = STD;
    if (branchop && fuif.mem_dest != 0 && fuif.mem_dest == dec_rs)
      fuif.rsBrSel_f = FWD;
    else if (branchop && fuif.mem_dest != 0 && fuif.mem_dest == dec_rt)
      fuif.rtBrSel_f = FWD;
  end
endmodule

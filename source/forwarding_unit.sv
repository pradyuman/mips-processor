`include "forwarding_unit_if.vh"

module forwarding_unit(forwarding_unit_if.fu fuif);
  assign ex_rs = fuif.ex_reg[25:21];
  always_comb begin
    fuif.aSel_f = 0;
    if (fuif.mem_rfWEN && fuif.mem_dest != 0 && fuif.mem_dest == ex_rs) begin
      fuif.aSel_f = 1;
      fuif.rdat1_f = fuif.mem_aluout;
    end
    else if (fuif.wb_rfWEN && fuif.wb_dest != 0 && fuif.wb_dest == ex_rs) begin
      fuif.aSel_f = 1;
      fuif.rdat1_f = fuif.wb_aluout;
    end
  end

  assign ex_rt = fuif.ex_reg[20:16];
  always_comb begin
    fuif.bSel_f = 0;
    if (fuif.mem_rfWEN && fuif.mem_dest != 0 && fuif.mem_dest == ex_rt) begin
      fuif.bSel_f = 1;
      fuif.rdat2_f = fuif.mem_aluout;
    end
    else if (fuif.wb_rfWEN && fuif.wb_dest != 0 && fuif.wb_dest == ex_rt) begin
      fuif.bSel_f = 1;
      fuif.rdat2_f = fuif.wb_aluout;
    end
  end
endmodule

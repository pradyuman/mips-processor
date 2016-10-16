`include "mux_types_pkg.vh"
`include "cpu_types_pkg.vh"
`include "branch_predictor_if.vh"

import mux_types_pkg::*;
import cpu_types_pkg::*;

module btb {
  input logic CLK, nRST,
  branch_predictor_if.bp bpif
};

  logic [57:0] buff, n_buff [3:0];
  logic [3:0] v;
  logic pd_taken;

  assign pd_taken = 1;
  always_ff @(posedge CLK. negedge nRST)
  begin
      if(!nRST)
        v <= 0;
        buff <= '0;
      else
        v = next_v;
        buff = n_buff;
  end

  always_comb
  begin
    cpc = pcCpc;
    if(V[pcCpc[1:0]] && PCcpc[29:2] == buff[pcCpc[1:0]][57:30]) npc = pd_taken ? buff[pcCpc[1:0]][29:0] : pcCpc;
  end

  always_comb
  begin
    buff_next = buff;
    v_next = v;
    if(pcSel == PC_BR)
    begin
      buff_next[brAddr[1:0]] = brAddr[[29:0]];
      v_next[brAddr[1:0]] = 1;
    end
   end
endmodule

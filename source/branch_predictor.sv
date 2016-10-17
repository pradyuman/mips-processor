`include "mux_types_pkg.vh"
`include "cpu_types_pkg.vh"
`include "branch_predictor_if.vh"

import mux_types_pkg::*;
import cpu_types_pkg::*;

module btb {
  input logic CLK, nRST,
  branch_predictor_if.bp bpif
};

  logic [58:0] buff, n_buff [3:0];
  logic pd_taken;

  always_ff @(posedge CLK. negedge nRST)
    if (!nRST) buff <= '0;
    else buff = n_buff;

  assign pd_taken = 1;
  assign idx = bpif.cpc[1:0];
  assign isValid = buff[idx][58];
  assign isHit = bpif.cpc[29:2] == buff[idx][57:30];

  assign bpif.phit = isValid & isHit;
  assign bpif.addr = (pd_taken & bpif.phit) ? buff[idx][29:0] : bpif.cpc;

  assign n_buff[bpif.br_a[1:0]] = pcSel == PC_BR ? { 1'b1, bpif.tag - 1, bpif.br_a[29:2] } : buff[idx];
endmodule

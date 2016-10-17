`include "mux_types_pkg.vh"
`include "cpu_types_pkg.vh"
`include "branch_predictor_if.vh"

import mux_types_pkg::*;
import cpu_types_pkg::*;

module branch_predictor (
  input logic CLK, nRST,
  branch_predictor_if.bp bpif
);

  logic [3:0][58:0] buff, n_buff;
  logic pd_taken, isValid, isHit;
  logic [1:0] idx, up_idx;

  always_ff @(posedge CLK, negedge nRST)
    if (!nRST) buff <= '0;
    else buff = n_buff;

  assign pd_taken = 1;
  assign idx = bpif.cpc[1:0];
  assign isValid = buff[idx][58];
  assign isHit = bpif.cpc[29:2] == buff[idx][57:30];

  assign bpif.phit = isValid & isHit;
  assign bpif.addr = (pd_taken & bpif.phit) ? buff[idx][29:0] : bpif.cpc;

  assign up_idx = bpif.tag[1:0];
  always_comb begin
    n_buff = buff;
    if (bpif.pcSel == PC_BR) n_buff[up_idx] = { 1'b1, bpif.tag[29:2], bpif.br_a[29:0] };
  end
endmodule

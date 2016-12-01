`include "cache_control_if.vh"
`include "cpu_types_pkg.vh"

import cpu_types_pkg::*;

module memory_control(
  input logic CLK, nRST,
  cache_control_if.cc ccif
);
  parameter CPUS = 2;

  typedef enum logic [2:0] {
    IDLE, CWB1, CWB2, CLW1, CLW2, SNOOP, SWB1, SWB2
  } cc_state;

  cc_state state, n_state;

  logic p_ihit, ihit, inegedge;
  assign ihit = ccif.iwait[0] & ccif.iwait[1];
  always_ff @(posedge CLK, negedge nRST)
    if (!nRST) p_ihit <= 1;
    else p_ihit <= ihit;

  assign inegedge = (ihit ^ p_ihit) & !ihit;

  logic curr, darb, iarb, dEN, sEN;
  logic [1:0] dataEN;
  always_ff @(posedge CLK, negedge nRST)
    if (!nRST) begin
      state <= IDLE;
      iarb <= 0;
    end
    else begin
      state <= n_state;
      iarb <= iarb ^ inegedge;
    end

  assign dataEN = ccif.dREN | ccif.dWEN;
  assign darb = 1;
  assign curr = dataEN[0] && dataEN[1] ? darb : dataEN[1];

  assign ccif.ccinv = { ccif.cctrans[0], ccif.cctrans[1] };
  assign ccif.ccsnoopaddr = { ccif.daddr[0], ccif.daddr[1] };
  assign ccif.ramstore = state == SWB1 | state == SWB2 ? ccif.dstore[!curr] : ccif.dstore[curr];
  assign ccif.ramREN = !ccif.ramWEN && (ccif.iREN || sEN);
  assign ccif.iload = {{2{ccif.ramload}}};

  assign ccif.ramaddr = dataEN ? ccif.daddr[curr] : ccif.iREN[0] && ccif.iREN[1] ? ccif.iaddr[iarb] : ccif.iaddr[ccif.iREN[1]];

  always_comb begin
    ccif.iwait = 2'b11;
    if (!dataEN) begin
      if (ccif.iREN == 2'b01) begin
        if (ccif.ramstate == ACCESS)
          ccif.iwait[0] = 0;
      end
      else if (ccif.iREN == 2'b10) begin
        if (ccif.ramstate == ACCESS)
          ccif.iwait[1] = 0;
      end
      else if (ccif.iREN == 2'b11) begin
        if (ccif.ramstate == ACCESS)
          ccif.iwait[iarb] = 0;
      end
    end
  end

  always_comb begin
    ccif.dwait = 2'b11;
    if (dEN & ccif.ramstate == ACCESS & state != SNOOP)
      ccif.dwait[curr] = 0;
  end

  always_comb begin
    ccif.dload[0] = ccif.ramload;
    ccif.dload[1] = ccif.ramload;
    n_state = state;
    ccif.ccwait = 0;
    ccif.ramWEN = 0;
    dEN = 1;
    sEN = 0;
    casez(state)
      IDLE: begin
        dEN = 0;
        if (ccif.ramstate == ACCESS || ccif.ramstate == FREE) begin
          if (ccif.dWEN[curr]) n_state = CWB1;
          if (ccif.dREN[curr]) n_state = SNOOP;
        end
      end
      SNOOP: begin
        ccif.ccwait[!curr] = 1;
        n_state = ccif.ccwrite[!curr] ? SWB1 : CLW1;
      end
      CWB1: begin
        ccif.ramWEN = 1;
        if (ccif.ramstate == ACCESS) begin
          n_state = CWB2;
        end
      end
      CWB2: begin
        ccif.ramWEN = 1;
        if (ccif.ramstate == ACCESS) begin
          n_state = IDLE;
        end
      end
      SWB1: begin
        ccif.ramWEN = 1;
        ccif.ccwait[!curr] = 1;
        if (ccif.ramstate == ACCESS) begin
          n_state = SWB2;
          ccif.dload[curr] = ccif.dstore[!curr];
        end
      end
      SWB2: begin
        ccif.ramWEN = 1;
        ccif.ccwait[!curr] = 1;
        if (ccif.ramstate == ACCESS) begin
          n_state = IDLE;
          ccif.dload[curr] = ccif.dstore[!curr];
        end
      end
      CLW1: begin
        sEN = 1;
        if (ccif.ramstate == ACCESS) begin
          n_state = CLW2;
        end
      end
      CLW2: begin
        sEN = 1;
        if (ccif.ramstate == ACCESS) begin
          n_state = IDLE;
        end
      end
    endcase
  end

endmodule

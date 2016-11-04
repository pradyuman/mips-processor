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

  logic curr, darb, n_darb, iarb, n_iarb, dEN;
  logic [1:0] en, n_dwait;
  word_t [1:0] n_dload;

  always_ff @(posedge CLK, negedge nRST)
    if(!nRST) begin
      state <= IDLE;
      darb <= 0;
      ccif.dwait <= '1;
      ccif.dload <= 0;
    end
    else begin
      state <= n_state;
      darb <= n_darb;
      ccif.dwait <= n_dwait;
      ccif.dload <= n_dload;
    end

  assign n_iarb = (!ccif.iwait[0] | !ccif.iwait[1]) ^ iarb;

  assign en = ccif.dREN | ccif.dWEN;
  assign curr = en[0] && en[1] ? darb : en[1];

  assign ccif.ccsnoopaddr[0] = ccif.daddr[1];
  assign ccif.ccsnoopaddr[1] = ccif.daddr[0];

  assign ccif.ramstore = ccif.dstore[curr];
  assign ccif.ramREN = !ccif.ramWEN;

  assign ccif.iload[0] = ccif.ramload;
  assign ccif.iload[1] = ccif.ramload;

  always_comb
    if(dEN) begin
      if(state == SWB1 | state == SWB2) ccif.ramaddr = ccif.daddr[!curr];
      else ccif.ramaddr = ccif.daddr[curr];
    end
    else ccif.ramaddr = ccif.iaddr[iarb];

  assign ccif.iwait[0] = !dEN | iarb | ccif.ramstate != ACCESS;
  assign ccif.iwait[1] = !dEN | !iarb | ccif.ramstate != ACCESS;

  always_comb begin
    n_dload[0] = ccif.ramload;
    n_dload[1] = ccif.ramload;
    n_state = state;
    n_darb = darb;
    ccif.ccwait = 0;
    ccif.ramWEN = 0;
    n_dwait = '1;
    casez(state)
      IDLE: begin
        dEN = 0;
        if(ccif.ramstate == ACCESS) begin
          if(ccif.dWEN[curr]) n_state = CWB1;
          if(ccif.dREN[curr]) n_state = SNOOP;
        end
      end
      SNOOP: begin
        n_darb = !darb;
        ccif.ccwait[!curr] = 1;
        n_state = ccif.ccwrite[!curr] ? SWB1 : CLW1;
      end
      CWB1: begin
        n_darb = !darb;
        ccif.ramWEN = 1;
        if(ccif.ramstate == ACCESS) begin
          n_state = CWB2;
          n_dwait[curr] = 0;
        end
      end
      CWB2: begin
        ccif.ramWEN = 1;
        if(ccif.ramstate == ACCESS) begin
          n_state = IDLE;
          n_dwait[curr] = 0;
        end
      end
      SWB1: begin
        ccif.ramWEN = 1;
        if(ccif.ramstate == ACCESS) begin
          n_state = SWB2;
          n_dload[curr] = ccif.dstore[!curr];
          n_dwait = 0;
        end
      end
      SWB2: begin
        ccif.ramWEN = 1;
        if(ccif.ramstate == ACCESS) begin
          n_state = IDLE;
          n_dload[curr] = ccif.dstore[!curr];
          n_dwait = 0;
        end
      end
      CLW1: begin
        n_darb = !darb;
        if(ccif.ramstate == ACCESS) begin
          n_state = CLW2;
          n_dwait[curr] = 0;
        end
      end
      CLW2: begin
        if(ccif.ramstate == ACCESS) begin
          n_state = IDLE;
          n_dwait[curr] = 0;
        end
      end
    endcase
  end

/*
  assign ccif.dload = ccif.ramload;
  assign ccif.iload = ccif.ramload;
  assign ccif.ramstore = ccif.dstore;
  assign ccif.ramWEN = ccif.dWEN;
  assign ccif.ramREN = (ccif.iREN | ccif.dREN) && !ccif.dWEN;
  assign ccif.ramaddr = (ccif.dREN | ccif.dWEN) ? ccif.daddr : ccif.iaddr;
  assign ccif.dwait = !((ccif.dREN | ccif.dWEN) & (ccif.ramstate == ACCESS));
  assign ccif.iwait = !((ccif.ramstate == ACCESS) & ccif.iREN) | ccif.dREN | ccif.dWEN;
*/
endmodule

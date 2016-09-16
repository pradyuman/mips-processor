`include "cpu_types_pkg.vh"
`include "request_proxy_if.vh"
import cpu_types_pkg::*;

module request_proxy (
  input logic CLK, nRST,
  request_proxy_if.rp rpif
);
  typedef enum { IDLE, D_SET } states;

  states state, next_state;
  always_ff @(posedge CLK, negedge nRST)
    if (!nRST) state <= IDLE;
    else state <= next_state;

  always_comb begin
    next_state = state;
    unique case (state)
      IDLE: begin
        { rpif.imemREN, rpif.dmemREN, rpif.dmemWEN } = { 1'b1, 1'b0, 1'b0 };
        if (rpif.ihit && (rpif.imemload[31:26] == LW || rpif.imemload[31:26] == SW))
          next_state = D_SET;
      end
      D_SET: begin
        rpif.dmemREN = rpif.imemload[31:26] == LW;
        rpif.dmemWEN = rpif.imemload[31:26] == SW;
        rpif.imemREN = 0;
        if (rpif.dhit) next_state = IDLE;
      end
    endcase
  end
endmodule

`include "cpu_types_pkg.vh"
`include "datapath_cache_if.vh"
import cpu_types_pkg::*;

module request_proxy (
  input logic CLK, nRST,
  datapath_cache_if.dp dpif
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
        { dpif.imemREN, dpif.dmemREN, dpif.dmemWEN } = { 1'b1, 1'b0, 1'b0 };
        if (dpif.ihit && (dpif.imemload[31:26] == LW || dpif.imemload[31:26] == SW))
          next_state = D_SET;
      end
      D_SET: begin
        dpif.dmemREN = dpif.imemload[31:26] == LW;
        dpif.dmemWEN = dpif.imemload[31:26] == SW;
        dpif.imemREN = 0;
        if (dpif.dhit) next_state = IDLE;
      end
    endcase
  end
endmodule

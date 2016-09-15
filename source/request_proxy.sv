`include "cpu_types_pkg.vh"
`include "datapath_cache_if.vh"
import cpu_types_pkg::*;

module request_proxy (
  input logic CLK, nRST,
  datapath_cache_if.dp dcif
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
        { dcif.dmemREN, dcif.dmemWEN } = { 0, 0 };
        if (dcif.ihit && (dcif.imemload == LW || dcif.imemload == SW))
          next_state = D_SET;
      end
      D_SET: begin
        dcif.dmemREN = dcif.imemload[31:26] == LW;
        dcif.dmemWEN = dcif.imemload[31:26] == SW;
        if (dcif.dhit) next_state = IDLE;
      end
    endcase
  end

  assign dcif.imemREN = ~(dcif.dmemREN || dcif.dmemWEN || dcif.imemload[31:26] == HALT);
endmodule

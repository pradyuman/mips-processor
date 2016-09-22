`include "cpu_types_pkg.vh"
`include "request_unit_if.vh"

import cpu_types_pkg::*;

module request_unit(
  input logic CLK,nRST,
  request_unit_if.ru ruif
);
 typedef enum logic {
   IDLE, DSET
 } state_t;

 state_t state, next_state;
 always_ff @(posedge CLK, negedge nRST)
   if(~nRST) state <= IDLE;
   else state <= next_state;

 always_comb begin
   next_state = state;
   case(state)
     IDLE: begin
       ruif.dWEN = 0;
       ruif.dREN = 0;
       ruif.iREN = 1;
       if(ruif.ihit && ((opcode_t'(ruif.ins[31:26]) == LW) || (opcode_t'(ruif.ins[31:26]) == SW)))
         next_state = DSET;
     end
     DSET: begin
       ruif.dWEN = opcode_t'(ruif.ins[31:26]) == SW;
       ruif.dREN = opcode_t'(ruif.ins[31:26]) == LW;
       ruif.iREN = 0;
       if(ruif.dhit) next_state = IDLE;
     end
   endcase
  end

endmodule

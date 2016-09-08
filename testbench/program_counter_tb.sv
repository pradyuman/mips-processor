`include "program_counter_if.vh"

module program_counter_tb #(parameter PERIOD = 10);
  logic CLK = 0, nRST;
  always #(PERIOD/2) CLK++;

  program_counter_if pcif();
  program_counter DUT(.CLK, .nRST, .pcif);
  initial $finish;
endmodule

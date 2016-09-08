`include "datapath_cache_if.vh"

module request_proxy_tb #(parameter PERIOD = 10);
  logic CLK = 0, nRST;
  always #(PERIOD/2) CLK++;

  datapath_cache_if dcif();
  request_proxy DUT(.CLK, .nRST, .dcif);
  initial $finish;
endmodule

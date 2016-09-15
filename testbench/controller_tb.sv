`include "alu_if.vh"
`include "controller_if.vh"
`include "datapath_cache_if.vh"
`include "program_counter_if.vh"
`include "register_file_if.vh"

module controller_tb;
  alu_if aluif();
  controller_if crif();
  datapath_cache_if dcif();
  program_counter_if pcif();
  register_file_if rfif();
  controller DUT(.aluif, .crif, .dcif, .pcif, .rfif);
  initial $finish;
endmodule

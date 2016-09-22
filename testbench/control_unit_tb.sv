`include "cpu_types_pkg.vh"
`include "mux_types_pkg.vh"

`include "datapath_cache_if.vh"
`include "pc_if.vh"
`include "register_file_if.vh"
`include "control_unit_if.vh"

module control_unit_tb;
  pc_if pcif ();
  alu_if aluif();
  datapath_cache_if dcif ();
  register_file_if rfif ();
  control_unit_if cuif ();

  control_unit DUT (aluif, pcif, dcif, rfif, cuif);

  initial
  begin
      $finish;
  end

endmodule

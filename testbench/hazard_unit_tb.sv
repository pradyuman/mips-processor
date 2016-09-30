`include "cpu_types_pkg.vh"
`include "hazard_unit_if.vh"

import cpu_types_pkg::*;

module hazard_unit_tb;

  hazard_unit_if huif();
  hazard_unit DUT(.huif);

  assign huif.ihit = 1;

  static integer ecnt = 0;
  initial begin
    if (huif.fdEN != huif.ihit) error("huif.fdEN fails in normal case.", ecnt);
    if (huif.pcEN != huif.ihit) error("huif.pcEN fails in normal case.", ecnt);
    if (huif.dx_flush != 0) error("huif.dx_flush fails in normal case.", ecnt);

    huif.ex_instr[31:26] = LW;
    if (huif.fdEN != 0) error("huif.fdEN fails when LW.", ecnt);
    if (huif.pcEN != 0) error("huif.pcEN fails when LW.", ecnt);
    if (huif.dx_flush != huif.ihit) error("huif.dx_flush fails when LW.", ecnt);

    $display("TOTAL ERRORS: %0d", ecnt);
    $finish;
  end
  task automatic error(string message, ref integer e);
    $display("ERROR: %s ", message); e++;
  endtask
endmodule

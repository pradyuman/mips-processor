`ifndef REQUEST_UNIT_IF_VH
`define REQUEST_UNIT_IF_VH

`include "cpu_types_pkg.vh"
`include "mux_types_pkg.vh"

import cpu_types_pkg::*;
import mux_types_pkg::*;

interface request_unit_if;
  logic ihit, dhit,dREN, dWEN, iREN;
  word_t ins;

  modport ru (
    input ihit, dhit, ins,
    output dWEN, dREN, iREN
  );
endinterface

`endif

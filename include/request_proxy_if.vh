`ifndef RP_IF_VH
`define RP_IF_VH
`include "cpu_types_pkg.vh"
import cpu_types_pkg::*;

interface request_proxy_if;
  logic ihit, dhit, imemREN, dmemREN, dmemWEN;
  word_t imemload;

  modport rp (
    input imemload, ihit, dhit,
    output imemREN, dmemREN, dmemWEN
  );
endinterface

`endif

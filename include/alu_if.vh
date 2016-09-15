`ifndef ALU_IF_VH
`define ALU_IF_VH
`include "cpu_types_pkg.vh"
import cpu_types_pkg::*;

interface alu_if;
  aluop_t ALUOP;
  word_t A, B, O;
  logic N, Z, V;

  modport alu (
    input A, B, ALUOP,
    output O, N, V, Z
  );

  modport cr (
    input Z, output ALUOP
  );

  modport tb (
    input O, N, Z, V,
    output A, B, ALUOP
  );
endinterface

`endif

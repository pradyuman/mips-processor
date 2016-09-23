`ifndef ALU_IF_VH
`define ALU_IF_VH

`include "cpu_types_pkg.vh"

import cpu_types_pkg::*;

interface alu_if;
	aluop_t op;
	word_t a, b, out;
	logic vf, zf, nf;

	modport alu (
		input a, b, op,
		output out, vf, zf, nf
	);

	modport tb (
		input out, vf, zf, nf,
		output a, b, op
	);

  modport cu (
    input zf,
    output op
  );
endinterface

`endif

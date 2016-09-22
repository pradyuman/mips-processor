`ifndef ALU_IF_VH
`define ALU_IF_VH

`include "cpu_types_pkg.vh"

import cpu_types_pkg::*;

interface alu_if;

	word_t a, b, out;
	logic vf, zf, nf;
	aluop_t op;

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

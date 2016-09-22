`include "alu_if.vh"
import cpu_types_pkg::*;

module alu (alu_if.alu aluif);
  always_comb casez (aluif.op)
    ALU_SLL:  aluif.out = aluif.a << aluif.b;
    ALU_SRL:  aluif.out = aluif.a >> aluif.b;
    ALU_ADD:  aluif.out = $signed(aluif.a) + $signed(aluif.b);
    ALU_SUB:  aluif.out = $signed(aluif.a) - $signed(aluif.b);
    ALU_AND:  aluif.out = aluif.a & aluif.b;
    ALU_OR:   aluif.out = aluif.a | aluif.b;
    ALU_XOR:  aluif.out = aluif.a ^ aluif.b;
    ALU_NOR:  aluif.out = ~(aluif.a | aluif.b);
    ALU_SLT:  aluif.out = $signed(aluif.a) < $signed(aluif.b);
    ALU_SLTU: aluif.out = aluif.a < aluif.b;
    default:  aluif.out = 32'hBAD_C0DE;
  endcase

  assign aluif.nf = aluif.out[WORD_W-1];
  assign aluif.zf = ~|aluif.out;
  assign aluif.vf =	((aluif.op == ALU_ADD) & (aluif.a[31] == aluif.b[31]) & (aluif.b[31] != aluif.out[31])) +
					          ((aluif.op == ALU_SUB) & (aluif.a[31] != aluif.b[31]) & (aluif.b[31] == aluif.out[31]));
endmodule

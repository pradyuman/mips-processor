`include "alu_if.vh"
import cpu_types_pkg::*;

module alu (alu_if.alu aluif);
  always_comb begin
    unique case (aluif.ALUOP) inside
      ALU_SLL:  aluif.O = aluif.A << aluif.B;
      ALU_SRL:  aluif.O = aluif.A >> aluif.B;
      ALU_ADD:  aluif.O = $signed(aluif.A) + $signed(aluif.B);
      ALU_SUB:  aluif.O = $signed(aluif.A) - $signed(aluif.B);
      ALU_AND:  aluif.O = aluif.A & aluif.B;
      ALU_OR:   aluif.O = aluif.A | aluif.B;
      ALU_XOR:  aluif.O = aluif.A ^ aluif.B;
      ALU_NOR:  aluif.O = ~(aluif.A | aluif.B);
      ALU_SLT:  aluif.O = $signed(aluif.A) < $signed(aluif.B);
      ALU_SLTU: aluif.O = aluif.A < aluif.B;
      default:  aluif.O = 32'hBAD_C0DE;
    endcase

    aluif.N = aluif.O[WORD_W-1];
    aluif.Z = ~|aluif.O;
    unique case (aluif.ALUOP)
      ALU_ADD: aluif.V = aluif.A[WORD_W-1] == aluif.B[WORD_W-1] &&
                         aluif.B[WORD_W-1] != aluif.O[WORD_W-1];
      ALU_SUB: aluif.V = aluif.A[WORD_W-1] != aluif.B[WORD_W-1] &&
                         aluif.B[WORD_W-1] == aluif.O[WORD_W-1];
      default: aluif.V = 0;
    endcase
  end
endmodule

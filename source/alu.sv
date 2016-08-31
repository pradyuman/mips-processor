`include "alu_if.vh"
import cpu_types_pkg::*;

module alu #(parameter SIZE = 32) (alu_if.alu aluif);
   always_comb begin
     priority case (aluif.ALUOP)
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
     endcase

       aluif.N = aluif.O[SIZE-1];
       aluif.Z = ~|aluif.O;
       case (aluif.ALUOP)
         ALU_ADD: aluif.V = aluif.A[SIZE-1] == aluif.B[SIZE-1] && aluif.B[SIZE-1] != aluif.O[SIZE-1];
         ALU_SUB: aluif.V = aluif.A[SIZE-1] != aluif.B[SIZE-1] && aluif.B[SIZE-1] == aluif.O[SIZE-1];
         default: aluif.V = 0;
       endcase
    end
endmodule

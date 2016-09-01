/**
 * ALU Interface.
 * Input: Port A (A), Port B (B), opcode (ALUOP)
 * Output: Output Port (O), Flags (N, Z, V)
 */
`ifndef ALU_IF_VH
`define ALU_IF_VH
`include "cpu_types_pkg.vh"

interface alu_if;
   cpu_types_pkg::aluop_t ALUOP;
   logic [31:0] A, B, O;
   logic N, Z, V;

   modport alu (
     input A, B, ALUOP,
     output O, N, V, Z
   );

   modport tb (
     input O, N, Z, V,
     output A, B, ALUOP
   );
endinterface

`endif // ALU_IF_VH

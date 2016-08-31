/**
 * ALU Interface.
 * Input: Port A (A), Port B (B), opcode (ALUOP)
 * Output: Output Port (O), Flags (N, Z, V)
 */
`include "cpu_types_pkg.vh"

interface alu_if;
   cpu_types_pkg::aluop_t ALUOP;
   logic [31:0] A, B, O;
   logic N, Z, V;

   modport alu (
     input A, B, ALUOP,
     output O, N, Z, V
   );

   modport tb (
     input O, N, Z, V,
     output A, B, ALUOP
   );
endinterface

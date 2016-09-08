/**
 * Program Counter Interface.
 * Input: Port A (A), Port B (B), opcode (ALUOP)
 * Output: Output Port (O), Flags (N, Z, V)
 */
`ifndef PROGRAM_COUNTER_IF_VH
`define PROGRAM_COUNTER_IF_VH

interface program_counter_if;
   logic [31:0] val, ext32, jr_a;
   logic [25:0] jump_a;
   logic [1:0]  pc_sel;
   logic        ihit;

   modport server (
     input  pc_sel, ihit,
            ext32, jr_a, jump_a,
     output val
   );

   modport driver (output pc_sel, ext32, jr_a, jump_a);
endinterface

`endif // PROGRAM_COUNTER_IF_VH

`ifndef MUX_SIGNALS_VH
`define MUX_SIGNALS_VH

package mux_signals;
  /* Program Counter Select Signals */
  typedef enum logic [1:0] {
    BRANCH, JRA, JUMP, NPC
  } pc_ms;

  /* ALU Port B Select Signals */
  typedef enum logic [1:0] {
    EXT32, RF, SHAMT
  } alu_b_ms;

  /* Register File WDAT Select Signals */
  typedef enum logic [1:0] {
    ALUO, IMM16, NPR, RAMDATA
  } rf_wdat_ms;
endpackage

`endif

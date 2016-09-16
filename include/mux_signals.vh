`ifndef MUX_SIGNALS_VH
`define MUX_SIGNALS_VH

package mux_signals;
  /* Program Counter Select Signals */
  typedef enum logic [1:0] {
    PC_BRANCH, PC_JRA, PC_JUMP, PC_NPC
  } pc_ms;

  /* ALU Port B Select Signals */
  typedef enum logic [1:0] {
    AB_EXT32, AB_RF, AB_SHAMT
  } alu_b_ms;

  /* Register File WDAT Select Signals */
  typedef enum logic [1:0] {
    RFW_ALUO, RFW_IMM16, RFW_NPC, RFW_RAMDATA
  } rf_wdat_ms;
endpackage

`endif

/**
 * Multiplexer Select Signals
 */
`ifndef MUX_SIGNALS_VH
`define MUX_SIGNALS_VH
package mux_signals;
  typedef enum logic [1:0] {
    NPC,
    JR,
    JUMP,
    BRANCH
  } pc_ms;
endpackage
`endif // MUX_SIGNALS_VH

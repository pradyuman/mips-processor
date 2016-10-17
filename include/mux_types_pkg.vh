`ifndef MUX_TYPES_PKG_VH
`define MUX_TYPES_PKG_VH

package mux_types_pkg;

typedef enum logic [1:0] {
  PC_NPC,
  PC_JR,
  PC_JUMP,
  PC_BR
} pcMux;

typedef enum logic [1:0] {
  ALUB_RDAT,
  ALUB_EXT,
  ALUB_SHAMT
} aluBMux;

typedef enum logic [1:0] {
  RFIN_LUI,
  RFIN_NPC,
  RFIN_ALU,
  RFIN_RAM
} rfInMux;

typedef enum logic {
  STD,
  FWD
} fwdMux;

endpackage

`endif

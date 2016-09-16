`include "alu_if.vh"
`include "controller_if.vh"
`include "cpu_types_pkg.vh"
`include "datapath_cache_if.vh"
`include "program_counter_if.vh"
`include "register_file_if.vh"
import cpu_types_pkg::*;

module datapath (
  input logic CLK, nRST,
  datapath_cache_if.dp dpif
);
  parameter PC_INIT = 0;

  /* ALU Port B Select Signals */
  typedef enum logic [1:0] {
    AB_EXT32, AB_RF, AB_SHAMT
  } alu_b_ms;

  /* Register File WDAT Select Signals */
  typedef enum logic [1:0] {
    RFW_ALUO, RFW_IMM16, RFW_NPC, RFW_RAMDATA
  } rf_wdat_ms;

  alu_if aluif();
  controller_if crif();
  program_counter_if pcif();
  register_file_if rfif();

  alu ALU (.aluif);
  controller CR (.aluif, .crif, .dpif, .pcif, .rfif);
  program_counter #(PC_INIT) PC (.CLK, .nRST, .pcif);
  register_file RF (.CLK, .nRST, .rfif);
  request_proxy RP (.CLK, .nRST, .dpif);

  always_comb casez (crif.alu_b_sel)
    AB_EXT32: aluif.B = crif.ext32;
    AB_RF: aluif.B = rfif.rdat2;
    AB_SHAMT: aluif.B = crif.shamt;
    default: aluif.B = 0;
  endcase

  always_comb casez (crif.rf_wdat_sel)
    RFW_ALUO: rfif.wdat = aluif.O;
    RFW_IMM16: rfif.wdat = {dpif.imemload, {16{1'b0}}};
    RFW_NPC: rfif.wdat = pcif.val + 4;
    RFW_RAMDATA: rfif.wdat = dpif.dmemload;
  endcase

  assign aluif.A = rfif.rdat1;
  assign pcif.ext32 = crif.ext32;
  assign pcif.jr_a = rfif.rdat1;
  assign dpif.dmemaddr = aluif.O;
  assign dpif.dmemstore = rfif.rdat2;
  assign dpif.imemaddr = pcif.val;

endmodule

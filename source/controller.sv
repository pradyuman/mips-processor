`include "alu_if.vh"
`include "controller_if.vh"
`include "cpu_types_pkg.vh"
`include "program_counter_if.vh"
import cpu_types_pkg::*;

/**
 * ALUIF:
 *   input Z, output ALUOP
 * CRIF:
 *   output alu_b_sel, rf_wdat_sel, ext32, shamt
 * DPIF:
 *   input ihit, imemload, dhit,
 *   output halt
 * PCIF:
 *   output en, sel, jump_a
 * RFIF:
 *   output WEN, wsel, rsel1, rsel2
 */
module controller (
  alu_if.cr aluif,
  controller_if.cr crif,
  program_counter_if.cr pcif
);
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

  opcode_t instruction;
  assign instruction = opcode_t'(crif.imemload[31:26]);
  assign crif.shamt = {{27{1'b0}}, crif.imemload[10:6]};
  assign pcif.jump_a = crif.imemload[ADDR_W-1:0];

  always_comb begin
    aluif.ALUOP = aluop_t'('x);
    crif.alu_b_sel = alu_b_ms'('x);
    crif.ext32 = {{16{crif.imemload[15]}}, crif.imemload[15:0]};
    crif.rf_wdat_sel = RFW_ALUO;
    crif.halt = 0;
    pcif.en = crif.ihit;
    pcif.sel = PC_NPC;
    crif.rsel1 = crif.imemload[25:21];
    crif.rsel2 = regbits_t'('x);
    crif.WEN = crif.ihit || crif.dhit;
    crif.wsel = crif.imemload[20:16];
    casez (instruction)
      RTYPE: begin
        crif.alu_b_sel = AB_RF;
        crif.rsel2 = crif.imemload[20:16];
        crif.wsel = crif.imemload[15:11];
        casez (crif.imemload[5:0])
          SLL: begin
            aluif.ALUOP = ALU_SLL;
            crif.alu_b_sel = AB_SHAMT;
          end
          SRL: begin
            aluif.ALUOP = ALU_SRL;
            crif.alu_b_sel = AB_SHAMT;
          end
          JR: begin
            pcif.sel = PC_JRA;
            crif.rsel1 = 31;
            crif.WEN = 0;
          end
          ADD,ADDU: aluif.ALUOP = ALU_ADD;
          SUB,SUBU: aluif.ALUOP = ALU_SUB;
          AND: aluif.ALUOP = ALU_AND;
          OR: aluif.ALUOP = ALU_OR;
          XOR: aluif.ALUOP = ALU_XOR;
          NOR: aluif.ALUOP = ALU_NOR;
          SLT: aluif.ALUOP = ALU_SLT;
          SLTU: aluif.ALUOP = ALU_SLTU;
        endcase
      end
      J: begin
        crif.ext32 = regbits_t'('x);
        crif.rf_wdat_sel = rf_wdat_ms'('x);
        pcif.sel = PC_JUMP;
        crif.WEN = 0;
        crif.rsel1 = regbits_t'('x);
        crif.wsel = regbits_t'('x);
      end
      JAL: begin
        crif.ext32 = regbits_t'('x);
        crif.rf_wdat_sel = RFW_NPC;
        pcif.sel = PC_JUMP;
        crif.wsel = 31;
        crif.rsel1 = regbits_t'('x);
      end
      BEQ: begin
        aluif.ALUOP = ALU_SUB;
        crif.alu_b_sel = AB_RF;
        crif.rsel2 = crif.imemload[20:16];
        crif.WEN = 0;
        if (aluif.Z) pcif.sel = PC_BRANCH;
      end
      BNE: begin
        aluif.ALUOP = ALU_SUB;
        crif.alu_b_sel = AB_RF;
        crif.rsel2 = crif.imemload[20:16];
        crif.WEN = 0;
        if (!aluif.Z) pcif.sel = PC_BRANCH;
      end
      ADDI,ADDIU: begin
        aluif.ALUOP = ALU_ADD;
        crif.alu_b_sel = AB_EXT32;
      end
      SLTI: begin
        aluif.ALUOP = ALU_SLT;
        crif.alu_b_sel = AB_EXT32;
      end
      SLTIU: begin
        aluif.ALUOP = ALU_SLTU;
        crif.alu_b_sel = AB_EXT32;
      end
      ANDI: begin
        aluif.ALUOP = ALU_AND;
        crif.alu_b_sel = AB_EXT32;
        crif.ext32 = {{16{1'b0}}, crif.imemload[15:0]};
      end
      ORI: begin
        aluif.ALUOP = ALU_OR;
        crif.alu_b_sel = AB_EXT32;
        crif.ext32 = {{16{1'b0}}, crif.imemload[15:0]};
      end
      XORI: begin
        aluif.ALUOP = ALU_XOR;
        crif.alu_b_sel = AB_EXT32;
        crif.ext32 = {{16{1'b0}}, crif.imemload[15:0]};
      end
      LUI: begin
        crif.rf_wdat_sel = RFW_IMM16;
        crif.rsel1 = regbits_t'('x);
      end
      LW: begin
        aluif.ALUOP = ALU_ADD;
        crif.alu_b_sel = AB_EXT32;
        crif.rf_wdat_sel = RFW_RAMDATA;
      end
      SW: begin
        aluif.ALUOP = ALU_ADD;
        crif.alu_b_sel = AB_EXT32;
        crif.rf_wdat_sel = rf_wdat_ms'('x);
        crif.WEN = 0;
        crif.rsel2 = crif.imemload[20:16];
        crif.wsel = regbits_t'('x);
      end
      HALT: begin
        crif.rf_wdat_sel = RFW_ALUO;
        crif.halt = 1;
        pcif.en = 0;
        pcif.sel = pc_ms'('x);
        crif.rsel1 = regbits_t'('x);
        crif.WEN = 0;
        crif.wsel = regbits_t'('x);
      end
    endcase
  end
endmodule

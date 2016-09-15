`include "alu_if.vh"
`include "controller_if.vh"
`include "cpu_types_pkg.vh"
`include "datapath_cache_if.vh"
`include "program_counter_if.vh"
`include "register_file_if.vh"
`include "mux_signals.vh"
import cpu_types_pkg::*;
import mux_signals::*;

/**
 * ALUIF:
 *   input Z, output ALUOP
 * CRIF:
 *   output alu_b_sel, wdat_sel, ext32, shamt
 * DCIF:
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
  datapath_cache_if.dp dcif,
  program_counter_if.cr pcif,
  register_file_if.tb rfif
);
  //assign crif.shamt = {{27{0}}, dcif.imemload[10:6]};
  assign pcif.en = dcif.ihit;
  assign pcif.jump_a = dcif.imemload[ADDR_W-1:0];

  always_comb begin
    aluif.ALUOP = aluop_t'('x);
    crif.alu_b_sel = EXT32;
    crif.rf_wdat_sel = rf_wdat_ms'('x);
    crif.ext32 = {{16{dcif.imemload[15]}}, dcif.imemload[15:0]};
    dcif.halt = 0;
    pcif.sel = NPC;
    rfif.WEN = dcif.ihit;
    rfif.rsel1 = dcif.imemload[25:21];
    rfif.rsel2 = dcif.imemload[20:16];
    rfif.wsel = dcif.imemload[20:16];
    casez (dcif.imemload[31:26])
      RTYPE: begin
        crif.alu_b_sel = RF;
        crif.rf_wdat_sel = ALUO;
        rfif.wsel = dcif.imemload[15:11];
        casez (dcif.imemload[5:0])
          SLL: begin
            aluif.ALUOP = ALU_SLL;
            crif.alu_b_sel = SHAMT;
          end
          SRL: begin
            aluif.ALUOP = ALU_SRL;
            crif.alu_b_sel = SHAMT;
          end
          JR: begin
            pcif.sel = JRA;
            rfif.WEN = 0;
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
        crif.alu_b_sel = alu_b_ms'('x);
        pcif.sel = JUMP;
      end
      JAL: begin
        crif.alu_b_sel = alu_b_ms'('x);
        pcif.sel = JUMP;
        rfif.wsel = 31;
      end
      BEQ: begin
      end
      BNE: begin
      end
      ADDI,ADDIU: begin
      end
      SLTI: begin
      end
      SLTIU: begin
      end
      ANDI: begin
      end
      ORI: begin
      end
      XORI: begin
      end
      LUI: begin
      end
      LW: begin
      end
      SW: begin
      end
      LL: begin
      end
      SC: begin
      end
      HALT: begin
      end
      default: begin
      end
    endcase
  end
endmodule

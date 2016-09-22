`include "cpu_types_pkg.vh"
`include "mux_types_pkg.vh"

`include "datapath_cache_if.vh"
`include "pc_if.vh"
`include "register_file_if.vh"
`include "control_unit_if.vh"

import cpu_types_pkg::*;
import mux_types_pkg::*;

module control_unit(control_unit_if.cu cuif);
  opcode_t ins;
  funct_t func;
  word_t zeroExt, signExt;

  assign ins = opcode_t'(cuif.ins[31:26]);
  assign func = funct_t'(cuif.ins[5:0]);
  assign zeroExt = {{16{1'b0}},cuif.ins[15:0]};
  assign signExt = {{16{cuif.ins[15]}},cuif.ins[15:0]};
  assign cuif.immJ26 = cuif.ins[25:0];

  always_comb begin
    cuif.pcEn = cuif.ihit;
    cuif.WEN = cuif.ihit | cuif.dhit;
    cuif.rsel1 = regbits_t'(cuif.ins[25:21]);
    cuif.rsel2 = regbits_t'('x);
    cuif.wsel = regbits_t'(cuif.ins[20:16]);

    cuif.shamt = {{27{1'b0}},cuif.ins[10:6]};
    cuif.ext32 = signExt;
    cuif.aluBSel = ALUB_EXT;
    cuif.rfInSel = RFIN_ALU;

    cuif.op = aluop_t'('x);

    cuif.pcSel = PC_NPC;

    cuif.halt = 0;

    casez(cuif.ins[31:26])
      RTYPE: begin
        cuif.aluBSel = ALUB_RDAT;
        cuif.ext32 = word_t'('x);
        cuif.rsel2 = regbits_t'(cuif.ins[20:16]);
        cuif.wsel = regbits_t'(cuif.ins[15:11]);
        casez(cuif.ins[5:0])
          SLL: begin
            cuif.op = ALU_SLL;
            cuif.aluBSel = ALUB_SHAMT;
          end
          SRL: begin
            cuif.op = ALU_SRL;
            cuif.aluBSel = ALUB_SHAMT;
          end
          JR: begin
            cuif.WEN = 0;
            cuif.pcSel = PC_JR;
            cuif.rfInSel = rfInMux'('x);
            cuif.aluBSel = aluBMux'('x);
            cuif.rsel2 = regbits_t'('x);
            cuif.wsel = regbits_t'('x);
          end
          ADD, ADDU: cuif.op = ALU_ADD;
          SUB, SUBU: cuif.op = ALU_SUB;
          AND: cuif.op = ALU_AND;
          OR: cuif.op = ALU_OR;
          XOR: cuif.op = ALU_XOR;
          NOR: cuif.op = ALU_NOR;
          SLT: cuif.op = ALU_SLT;
          SLTU: cuif.op = ALU_SLTU;
        endcase
      end
      J: begin
        cuif.WEN = 0;
        cuif.pcSel = PC_JUMP;
        cuif.aluBSel = aluBMux'('x);
        cuif.rfInSel = rfInMux'('x);
        cuif.ext32 = word_t'('x);
        cuif.wsel = regbits_t'('x);
        cuif.rsel1 = regbits_t'('x);
      end
      JAL: begin
        cuif.pcSel = PC_JUMP;
        cuif.rfInSel = RFIN_NPC;
        cuif.wsel = 31;
        cuif.rsel1 = regbits_t'('x);
        cuif.aluBSel = aluBMux'('x);
        cuif.ext32 = word_t'('x);
      end
      BEQ: begin
        cuif.WEN = 0;
        cuif.rsel2 = regbits_t'(cuif.ins[20:16]);
        cuif.op = ALU_SUB;
        cuif.aluBSel = ALUB_RDAT;
        cuif.pcSel = cuif.zf ? PC_BR : PC_NPC;
        cuif.rfInSel = rfInMux'('x);
      end
      BNE: begin
        cuif.WEN = 0;
        cuif.rsel2 = regbits_t'(cuif.ins[20:16]);
        cuif.op = ALU_SUB;
        cuif.aluBSel = ALUB_RDAT;
        cuif.pcSel = cuif.zf ? PC_NPC : PC_BR;
        cuif.rfInSel = rfInMux'('x);
      end
      ADDI, ADDIU: cuif.op = ALU_ADD;
      SLTI: cuif.op = ALU_SLT;
      SLTIU: cuif.op = ALU_SLTU;
      ANDI: begin
        cuif.op = ALU_AND;
        cuif.ext32 = zeroExt;
      end
      ORI: begin
        cuif.op = ALU_OR;
        cuif.ext32 = zeroExt;
      end
      XORI: begin
        cuif.op = ALU_XOR;
        cuif.ext32 = zeroExt;
      end
      LUI: begin
        cuif.rfInSel = RFIN_LUI;
        cuif.aluBSel = aluBMux'('x);
        cuif.rsel1 = regbits_t'('x);
      end
      LW: begin
        cuif.op = ALU_ADD;
        cuif.rfInSel = RFIN_RAM;
      end
      SW: begin
        cuif.WEN = 0;
        cuif.op = ALU_ADD;
        cuif.rsel2 = regbits_t'(cuif.ins[20:16]);
        cuif.wsel = regbits_t'('x);
        cuif.rfInSel = rfInMux'('x);
      end
      HALT: begin
        cuif.halt = 1;
        cuif.pcEn = 0;
        cuif.WEN = 0;
        cuif.rsel1 = regbits_t'('x);
        cuif.wsel = regbits_t'('x);
        cuif.rfInSel = rfInMux'('x);
        cuif.pcSel = pcMux'('x);
        cuif.aluBSel = aluBMux'('x);
      end
    endcase
  end

endmodule

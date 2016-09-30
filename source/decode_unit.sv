`include "cpu_types_pkg.vh"
`include "mux_types_pkg.vh"

`include "datapath_cache_if.vh"
`include "pc_if.vh"
`include "register_file_if.vh"
`include "decode_unit_if.vh"

import cpu_types_pkg::*;
import mux_types_pkg::*;

module decode_unit(decode_unit_if.du duif);
  opcode_t ins;
  funct_t func;

  assign ins = opcode_t'(duif.ins[31:26]);
  assign func = funct_t'(duif.ins[5:0]);

  assign duif.immJ26 = duif.ins[25:0];

  always_comb begin
    duif.dREN = 0;
    duif.dWEN = 0;
    duif.WEN = 1;
    duif.rsel1 = regbits_t'(duif.ins[25:21]);
    duif.rsel2 = regbits_t'('x);
    duif.wsel = regbits_t'(duif.ins[20:16]);
    duif.sign = duif.ins[15];
    duif.aluBSel = ALUB_EXT;
    duif.rfInSel = RFIN_ALU;

    duif.op = aluop_t'('x);

    duif.pcSel = PC_NPC;

    duif.halt = 0;

    casez(duif.ins[31:26])
      RTYPE: begin
        duif.aluBSel = ALUB_RDAT;
        duif.sign = 'x;
        duif.rsel2 = regbits_t'(duif.ins[20:16]);
        duif.wsel = regbits_t'(duif.ins[15:11]);
        casez(duif.ins[5:0])
          SLL: begin
            duif.op = ALU_SLL;
            duif.aluBSel = ALUB_SHAMT;
          end
          SRL: begin
            duif.op = ALU_SRL;
            duif.aluBSel = ALUB_SHAMT;
          end
          JR: begin
            duif.WEN = 0;
            duif.pcSel = PC_JR;
            duif.rfInSel = rfInMux'('x);
            duif.aluBSel = aluBMux'('x);
            duif.rsel2 = regbits_t'('x);
            duif.wsel = regbits_t'('x);
          end
          ADD, ADDU: duif.op = ALU_ADD;
          SUB, SUBU: duif.op = ALU_SUB;
          AND: duif.op = ALU_AND;
          OR: duif.op = ALU_OR;
          XOR: duif.op = ALU_XOR;
          NOR: duif.op = ALU_NOR;
          SLT: duif.op = ALU_SLT;
          SLTU: duif.op = ALU_SLTU;
        endcase
      end
      J: begin
        duif.WEN = 0;
        duif.pcSel = PC_JUMP;
        duif.aluBSel = aluBMux'('x);
        duif.rfInSel = rfInMux'('x);
        duif.sign = 'x;
        duif.wsel = regbits_t'('x);
        duif.rsel1 = regbits_t'('x);
      end
      JAL: begin
        duif.pcSel = PC_JUMP;
        duif.rfInSel = RFIN_NPC;
        duif.wsel = 31;
        duif.rsel1 = regbits_t'('x);
        duif.aluBSel = aluBMux'('x);
        duif.sign = 'x;
      end
      BEQ: begin
        duif.WEN = 0;
        duif.rsel2 = regbits_t'(duif.ins[20:16]);
        duif.aluBSel = ALUB_RDAT;
        duif.pcSel = duif.ef ? PC_BR : PC_NPC;
        duif.rfInSel = rfInMux'('x);
      end
      BNE: begin
        duif.WEN = 0;
        duif.rsel2 = regbits_t'(duif.ins[20:16]);
        duif.aluBSel = ALUB_RDAT;
        duif.pcSel = duif.ef ? PC_NPC : PC_BR;
        duif.rfInSel = rfInMux'('x);
      end
      ADDI, ADDIU: duif.op = ALU_ADD;
      SLTI: duif.op = ALU_SLT;
      SLTIU: duif.op = ALU_SLTU;
      ANDI: begin
        duif.op = ALU_AND;
        duif.sign = 0;
      end
      ORI: begin
        duif.op = ALU_OR;
        duif.sign = 0;
      end
      XORI: begin
        duif.op = ALU_XOR;
        duif.sign = 0;
      end
      LUI: begin
        duif.rfInSel = RFIN_LUI;
        duif.aluBSel = aluBMux'('x);
        duif.rsel1 = regbits_t'('x);
      end
      LW: begin
        duif.dREN = 1;
        duif.op = ALU_ADD;
        duif.rfInSel = RFIN_RAM;
      end
      SW: begin
        duif.dWEN = 1;
        duif.WEN = 0;
        duif.op = ALU_ADD;
        duif.rsel2 = regbits_t'(duif.ins[20:16]);
        duif.wsel = regbits_t'('x);
        duif.rfInSel = rfInMux'('x);
      end
      HALT: begin
        duif.halt = 1;
        duif.WEN = 0;
        duif.rsel1 = regbits_t'('x);
        duif.wsel = regbits_t'('x);
        duif.rfInSel = rfInMux'('x);
        duif.pcSel = pcMux'('x);
        duif.aluBSel = aluBMux'('x);
      end
    endcase
  end

endmodule

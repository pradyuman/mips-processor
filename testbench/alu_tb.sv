`include "alu_if.vh"

`timescale 1 ns / 1 ns

import cpu_types_pkg::*;

module alu_tb;

alu_if aluif ();

`ifndef MAPPED
	alu DUT (aluif);
`else
	alu DUT (
		.\aluif.a (aluif.a),
		.\aluif.b (aluif.b),
		.\aluif.op (aluif.op),
		.\aluif.out (aluif.out),
		.\aluif.vf (aluif.vf),
		.\aluif.nf (aluif.nf),
		.\aluif.zf (aluif.zf)
	);
`endif

integer caseNum = 1;

initial begin
//11111111111111111111111111111111111111111
aluif.a = 32'b0;
aluif.b = 32'b0;
aluif.op = ALU_ADD;
#1
assert(aluif.out == aluif.a + aluif.b) $display("Passed. Case %d: out = %b\n", caseNum, aluif.out); else $display("Failed. Case %d: out = %b\n", caseNum, aluif.out);
assert(aluif.vf == 0) $display("Passed. Case %d: vf = %b\n", caseNum, aluif.vf); else $display("Failed. Case %d: vf = %b\n", caseNum, aluif.vf);
assert(aluif.zf == 1) $display("Passed. Case %d: zf = %b\n", caseNum, aluif.zf); else $display("Failed. Case %d: zf = %b\n", caseNum, aluif.zf);
assert(aluif.nf == 0) $display("Passed. Case %d: nf = %b\n", caseNum, aluif.nf); else $display("Failed. Case %d: nf = %b\n", caseNum, aluif.nf);
caseNum = caseNum + 1;
//22222222222222222222222222222222222222222
aluif.a = -300;
aluif.b = 200;
aluif.op = ALU_ADD;
#1
assert(aluif.out == aluif.a + aluif.b) $display("Passed. Case %d: out = %b\n", caseNum, aluif.out); else $display("Failed. Case %d: out = %b\n", caseNum, aluif.out);
assert(aluif.vf == 0) $display("Passed. Case %d: vf = %b\n", caseNum, aluif.vf); else $display("Failed. Case %d: vf = %b\n", caseNum, aluif.vf);
assert(aluif.zf == 0) $display("Passed. Case %d: zf = %b\n", caseNum, aluif.zf); else $display("Failed. Case %d: zf = %b\n", caseNum, aluif.zf);
assert(aluif.nf == 1) $display("Passed. Case %d: nf = %b\n", caseNum, aluif.nf); else $display("Failed. Case %d: nf = %b\n", caseNum, aluif.nf);
caseNum = caseNum + 1;
//33333333333333333333333333333333333333333
aluif.a = {{1'b0},{2**31-1}};
aluif.b = 1;
aluif.op = ALU_ADD;
#1
assert(aluif.out == aluif.a + aluif.b) $display("Passed. Case %d: out = %b\n", caseNum, aluif.out); else $display("Failed. Case %d: out = %b\n", caseNum, aluif.out);
assert(aluif.vf == 1) $display("Passed. Case %d: vf = %b\n", caseNum, aluif.vf); else $display("Failed. Case %d: vf = %b\n", caseNum, aluif.vf);
assert(aluif.zf == 0) $display("Passed. Case %d: zf = %b\n", caseNum, aluif.zf); else $display("Failed. Case %d: zf = %b\n", caseNum, aluif.zf);
assert(aluif.nf == 1) $display("Passed. Case %d: nf = %b\n", caseNum, aluif.nf); else $display("Failed. Case %d: nf = %b\n", caseNum, aluif.nf);
caseNum = caseNum + 1;
//44444444444444444444444444444444444444444
aluif.a = 1024;
aluif.b = -10;
aluif.op = ALU_SUB;
#1
assert(aluif.out == aluif.a - aluif.b) $display("Passed. Case %d: out = %b\n", caseNum, aluif.out); else $display("Failed. Case %d: out = %b\n", caseNum, aluif.out);
assert(aluif.vf == 0) $display("Passed. Case %d: vf = %b\n", caseNum, aluif.vf); else $display("Failed. Case %d: vf = %b\n", caseNum, aluif.vf);
assert(aluif.zf == 0) $display("Passed. Case %d: zf = %b\n", caseNum, aluif.zf); else $display("Failed. Case %d: zf = %b\n", caseNum, aluif.zf);
assert(aluif.nf == 0) $display("Passed. Case %d: nf = %b\n", caseNum, aluif.nf); else $display("Failed. Case %d: nf = %b\n", caseNum, aluif.nf);
caseNum = caseNum + 1;
//55555555555555555555555555555555555555555
aluif.a = {{1'b1},{31{1'b0}}};
aluif.b = 100;
aluif.op = ALU_SUB;
#1
assert(aluif.out == aluif.a - aluif.b) $display("Passed. Case %d: out = %b\n", caseNum, aluif.out); else $display("Failed. Case %d: out = %b\n", caseNum, aluif.out);
assert(aluif.vf == 1) $display("Passed. Case %d: vf = %b\n", caseNum, aluif.vf); else $display("Failed. Case %d: vf = %b\n", caseNum, aluif.vf);
assert(aluif.zf == 0) $display("Passed. Case %d: zf = %b\n", caseNum, aluif.zf); else $display("Failed. Case %d: zf = %b\n", caseNum, aluif.zf);
assert(aluif.nf == 0) $display("Passed. Case %d: nf = %b\n", caseNum, aluif.nf); else $display("Failed. Case %d: nf = %b\n", caseNum, aluif.nf);
caseNum = caseNum + 1;
//66666666666666666666666666666666666666666
aluif.a = 1024;
aluif.b = 2;
aluif.op = ALU_SLL;
#1
assert(aluif.out == 4096) $display("Passed. Case %d: out = %b\n", caseNum, aluif.out); else $display("Failed. Case %d: out = %b\n", caseNum, aluif.out);
assert(aluif.vf == 0) $display("Passed. Case %d: vf = %b\n", caseNum, aluif.vf); else $display("Failed. Case %d: vf = %b\n", caseNum, aluif.vf);
assert(aluif.zf == 0) $display("Passed. Case %d: zf = %b\n", caseNum, aluif.zf); else $display("Failed. Case %d: zf = %b\n", caseNum, aluif.zf);
assert(aluif.nf == 0) $display("Passed. Case %d: nf = %b\n", caseNum, aluif.nf); else $display("Failed. Case %d: nf = %b\n", caseNum, aluif.nf);
caseNum = caseNum + 1;
//77777777777777777777777777777777777777777
aluif.a = 1024;
aluif.b = 2;
aluif.op = ALU_SRL;
#1
assert(aluif.out == 256) $display("Passed. Case %d: out = %b\n", caseNum, aluif.out); else $display("Failed. Case %d: out = %b\n", caseNum, aluif.out);
assert(aluif.vf == 0) $display("Passed. Case %d: vf = %b\n", caseNum, aluif.vf); else $display("Failed. Case %d: vf = %b\n", caseNum, aluif.vf);
assert(aluif.zf == 0) $display("Passed. Case %d: zf = %b\n", caseNum, aluif.zf); else $display("Failed. Case %d: zf = %b\n", caseNum, aluif.zf);
assert(aluif.nf == 0) $display("Passed. Case %d: nf = %b\n", caseNum, aluif.nf); else $display("Failed. Case %d: nf = %b\n", caseNum, aluif.nf);
caseNum = caseNum + 1;
//88888888888888888888888888888888888888888
aluif.a = 2^32-1;
aluif.b = 2;
aluif.op = ALU_SLTU;
#1
assert(aluif.out == 0) $display("Passed. Case %d: out = %b\n", caseNum, aluif.out); else $display("Failed. Case %d: out = %b\n", caseNum, aluif.out);
assert(aluif.vf == 0) $display("Passed. Case %d: vf = %b\n", caseNum, aluif.vf); else $display("Failed. Case %d: vf = %b\n", caseNum, aluif.vf);
assert(aluif.zf == 1) $display("Passed. Case %d: zf = %b\n", caseNum, aluif.zf); else $display("Failed. Case %d: zf = %b\n", caseNum, aluif.zf);
assert(aluif.nf == 0) $display("Passed. Case %d: nf = %b\n", caseNum, aluif.nf); else $display("Failed. Case %d: nf = %b\n", caseNum, aluif.nf);
caseNum = caseNum + 1;
//99999999999999999999999999999999999999999
aluif.a = 1024;
aluif.b = 2333;
aluif.op = ALU_SLTU;
#1
assert(aluif.out == 1) $display("Passed. Case %d: out = %b\n", caseNum, aluif.out); else $display("Failed. Case %d: out = %b\n", caseNum, aluif.out);
assert(aluif.vf == 0) $display("Passed. Case %d: vf = %b\n", caseNum, aluif.vf); else $display("Failed. Case %d: vf = %b\n", caseNum, aluif.vf);
assert(aluif.zf == 0) $display("Passed. Case %d: zf = %b\n", caseNum, aluif.zf); else $display("Failed. Case %d: zf = %b\n", caseNum, aluif.zf);
assert(aluif.nf == 0) $display("Passed. Case %d: nf = %b\n", caseNum, aluif.nf); else $display("Failed. Case %d: nf = %b\n", caseNum, aluif.nf);
caseNum = caseNum + 1;
//AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
aluif.a = -1024;
aluif.b = -2333;
aluif.op = ALU_SLT;
#1
assert(aluif.out == 0) $display("Passed. Case %d: out = %b\n", caseNum, aluif.out); else $display("Failed. Case %d: out = %b\n", caseNum, aluif.out);
assert(aluif.vf == 0) $display("Passed. Case %d: vf = %b\n", caseNum, aluif.vf); else $display("Failed. Case %d: vf = %b\n", caseNum, aluif.vf);
assert(aluif.zf == 1) $display("Passed. Case %d: zf = %b\n", caseNum, aluif.zf); else $display("Failed. Case %d: zf = %b\n", caseNum, aluif.zf);
assert(aluif.nf == 0) $display("Passed. Case %d: nf = %b\n", caseNum, aluif.nf); else $display("Failed. Case %d: nf = %b\n", caseNum, aluif.nf);
caseNum = caseNum + 1;
//BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB
aluif.a = -1024;
aluif.b = 233;
aluif.op = ALU_SLT;
#1
assert(aluif.out == 1) $display("Passed. Case %d: out = %b\n", caseNum, aluif.out); else $display("Failed. Case %d: out = %b\n", caseNum, aluif.out);
assert(aluif.vf == 0) $display("Passed. Case %d: vf = %b\n", caseNum, aluif.vf); else $display("Failed. Case %d: vf = %b\n", caseNum, aluif.vf);
assert(aluif.zf == 0) $display("Passed. Case %d: zf = %b\n", caseNum, aluif.zf); else $display("Failed. Case %d: zf = %b\n", caseNum, aluif.zf);
assert(aluif.nf == 0) $display("Passed. Case %d: nf = %b\n", caseNum, aluif.nf); else $display("Failed. Case %d: nf = %b\n", caseNum, aluif.nf);
caseNum = caseNum + 1;
//AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
aluif.a = 3;
aluif.b = 4;
aluif.op = ALU_OR;
#1
assert(aluif.out == 7) $display("Passed. Case %d: out = %b\n", caseNum, aluif.out); else $display("Failed. Case %d: out = %b\n", caseNum, aluif.out);
assert(aluif.vf == 0) $display("Passed. Case %d: vf = %b\n", caseNum, aluif.vf); else $display("Failed. Case %d: vf = %b\n", caseNum, aluif.vf);
assert(aluif.zf == 0) $display("Passed. Case %d: zf = %b\n", caseNum, aluif.zf); else $display("Failed. Case %d: zf = %b\n", caseNum, aluif.zf);
assert(aluif.nf == 0) $display("Passed. Case %d: nf = %b\n", caseNum, aluif.nf); else $display("Failed. Case %d: nf = %b\n", caseNum, aluif.nf);
caseNum = caseNum + 1;
//CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
aluif.a = 3;
aluif.b = 2;
aluif.op = ALU_AND;
#1
assert(aluif.out == 2) $display("Passed. Case %d: out = %b\n", caseNum, aluif.out); else $display("Failed. Case %d: out = %b\n", caseNum, aluif.out);
assert(aluif.vf == 0) $display("Passed. Case %d: vf = %b\n", caseNum, aluif.vf); else $display("Failed. Case %d: vf = %b\n", caseNum, aluif.vf);
assert(aluif.zf == 0) $display("Passed. Case %d: zf = %b\n", caseNum, aluif.zf); else $display("Failed. Case %d: zf = %b\n", caseNum, aluif.zf);
assert(aluif.nf == 0) $display("Passed. Case %d: nf = %b\n", caseNum, aluif.nf); else $display("Failed. Case %d: nf = %b\n", caseNum, aluif.nf);
caseNum = caseNum + 1;
//DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD
aluif.a = 2;
aluif.b = 1;
aluif.op = ALU_XOR;
#1
assert(aluif.out == 3) $display("Passed. Case %d: out = %b\n", caseNum, aluif.out); else $display("Failed. Case %d: out = %b\n", caseNum, aluif.out);
assert(aluif.vf == 0) $display("Passed. Case %d: vf = %b\n", caseNum, aluif.vf); else $display("Failed. Case %d: vf = %b\n", caseNum, aluif.vf);
assert(aluif.zf == 0) $display("Passed. Case %d: zf = %b\n", caseNum, aluif.zf); else $display("Failed. Case %d: zf = %b\n", caseNum, aluif.zf);
assert(aluif.nf == 0) $display("Passed. Case %d: nf = %b\n", caseNum, aluif.nf); else $display("Failed. Case %d: nf = %b\n", caseNum, aluif.nf);
caseNum = caseNum + 1;
//EEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE
aluif.a = 0;
aluif.b = 1;
aluif.op = ALU_NOR;
#1
assert(aluif.out == {{31{1'b1}},{1'b0}}) $display("Passed. Case %d: out = %b\n", caseNum, aluif.out); else $display("Failed. Case %d: out = %b\n", caseNum, aluif.out);
assert(aluif.vf == 0) $display("Passed. Case %d: vf = %b\n", caseNum, aluif.vf); else $display("Failed. Case %d: vf = %b\n", caseNum, aluif.vf);
assert(aluif.zf == 0) $display("Passed. Case %d: zf = %b\n", caseNum, aluif.zf); else $display("Failed. Case %d: zf = %b\n", caseNum, aluif.zf);
assert(aluif.nf == 1) $display("Passed. Case %d: nf = %b\n", caseNum, aluif.nf); else $display("Failed. Case %d: nf = %b\n", caseNum, aluif.nf);
caseNum = caseNum + 1;

end

endmodule

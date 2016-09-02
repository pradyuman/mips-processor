`include "alu_if.vh"
`include "cpu_types_pkg.vh"
`timescale 1 ns / 1 ns
import cpu_types_pkg::*;

module alu_tb;
  alu_if aluif();
  alu DUT(.aluif);

  enum { SLL, SRL, ADD, SUB, AND, OR, XOR, NOR, SLT, SLTU, N, Z, V } ops;
  static integer errors[13] = '{default:0};
  integer unsigned A[10], B[10];

  initial begin
    std::randomize(A);
    foreach(B[i]) std::randomize(B[i]) with { B[i] inside {[0:5]}; };

    foreach(A[i]) testALU(ALU_SLL, A[i], B[i], A[i] << B[i], errors[SLL]);
    resolve("ALU_SLL (Logical Shift Left)", errors[SLL]);

    foreach(A[i]) testALU(ALU_SRL, A[i], B[i], A[i] >> B[i], errors[SRL]);
    resolve("ALU_SRL (Logical Shift Right)", errors[SRL]);

    std::randomize(B);

    foreach(A[i]) testALU(ALU_ADD, $signed(A[i]), $signed(B[i]),
                          $signed(A[i]) + $signed(B[i]), errors[ADD]);
    resolve("ALU_ADD (signed)", errors[ADD]);

    foreach(A[i]) testALU(ALU_SUB, $signed(A[i]), $signed(B[i]),
                          $signed(A[i]) - $signed(B[i]), errors[SUB]);
    resolve("ALU_SUB (signed)", errors[SUB]);

    foreach(A[i]) testALU(ALU_AND, A[i], B[i], A[i] & B[i], errors[AND]);
    resolve("ALU_AND", errors[AND]);

    foreach(A[i]) testALU(ALU_OR, A[i], B[i], A[i] | B[i], errors[OR]);
    resolve("ALU_OR", errors[OR]);

    foreach(A[i]) testALU(ALU_XOR, A[i], B[i], A[i] ^ B[i], errors[XOR]);
    resolve("ALU_XOR", errors[XOR]);

    foreach(A[i]) testALU(ALU_NOR, A[i], B[i], ~(A[i] | B[i]), errors[NOR]);
    resolve("ALU_NOR", errors[NOR]);

    foreach(A[i]) testALU(ALU_SLT, A[i], B[i], $signed(A[i]) < $signed(B[i]), errors[SLT]);
    resolve("ALU_SLT (set < signed)", errors[SLT]);

    foreach(A[i]) testALU(ALU_SLTU, A[i], B[i], A[i] < B[i], errors[SLTU]);
    resolve("ALU_SLTU (set < unsigned)", errors[SLTU]);

    testNFlag(errors[N]);
    resolve("Negative Flag", errors[N]);

    testZFlag(errors[Z]);
    resolve("Zero Flag", errors[Z]);

    testVFlag(errors[V]);
    resolve("Overflow Flag", errors[V]);

    $display("TOTAL ERRORS: %0d", errors.sum());
  end

  task automatic testALU(aluop_t ALUOP, word_t A, B, expected, ref integer e);
    aluif.ALUOP = ALUOP; aluif.A = A; aluif.B = B; #1;
    assert(aluif.O == expected) else error(expected, aluif.O, e);
  endtask // testALU

  task automatic testNFlag(ref integer e);
    // Test Negative Flag Set
    aluif.ALUOP = ALU_SUB; aluif.A = 2; aluif.B = 4; #1;
    assert(aluif.N == 1) else error(1, aluif.N, e);

    // Test Negative Flag Reset
    aluif.ALUOP = ALU_ADD; aluif.A = 2; aluif.B = 4; #1;
    assert(aluif.N == 0) else error(0, aluif.N, e);
  endtask

  task automatic testZFlag(ref integer e);
    // Test Zero Flag Set
    aluif.ALUOP = ALU_SUB; aluif.A = 9; aluif.B = 9; #1;
    assert(aluif.Z == 1) else error(1, aluif.N, e);

    // Test Zero Flag Reset
    aluif.ALUOP = ALU_ADD; aluif.A = 9; aluif.B = 9; #1;
    assert(aluif.Z == 0) else error(0, aluif.N, e);
  endtask

  task automatic testVFlag(ref integer e);
    // Test Overflow Flag Set on ADD
    aluif.ALUOP = ALU_ADD; aluif.A = {1'b1, {31{1'b0}}}; aluif.B = {1'b1, {31{1'b0}}}; #1;
    assert(aluif.V == 1) else error(1, aluif.V, e);

    // Test Overflow Flag Set on SUB
    aluif.ALUOP = ALU_SUB; aluif.A = {1'b1, {31{1'b0}}}; aluif.B = {1'b0, {31{1'b1}}}; #1;
    assert(aluif.V == 1) else error(1, aluif.V, e);

    // Test Overflow Flag Reset
    aluif.ALUOP = ALU_ADD; aluif.A = 10; aluif.B = 10; #1;
    assert(aluif.V == 0) else error(0, aluif.V, e);
  endtask

  task resolve(string message, integer e);
    if (!e) $display("SUCCESS: %s", message);
    else $display("FAILURE: %s - %0d errors", message, e);
  endtask

  task automatic error(word_t expected, out, ref integer e);
    $display("ERROR: %s | A - %b | B - %b | EXPECTED - %b | REAL - %b",
             aluif.ALUOP, aluif.A, aluif.B, expected, out);
    e++;
  endtask
endmodule

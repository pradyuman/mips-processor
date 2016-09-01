`include "alu_if.vh"
`include "cpu_types_pkg.vh"

module alu_fpga (
  input logic [3:0] KEY,
  input logic [17:0] SW,
  output logic [6:0] HEX7, HEX6, HEX5, HEX4, HEX3, HEX2, HEX1, HEX0,
  output logic [17:15] LEDR
);
  logic [31:0] register_b;
  logic [55:0] HEX = '{default:0};
  integer i;

  alu_if aluif();
  alu ALU(.aluif);

  always_ff @(posedge SW[17]) register_b = {{16{SW[16]}}, SW[15:0]};

  always_comb begin
    for (i = 0; i < 8; i++) begin
      unique case (aluif.O[i*4+:4])
        'h0: HEX[i*7+:7] = 7'b1000000;
        'h1: HEX[i*7+:7] = 7'b1111001;
        'h2: HEX[i*7+:7] = 7'b0100100;
        'h3: HEX[i*7+:7] = 7'b0110000;
        'h4: HEX[i*7+:7] = 7'b0011001;
        'h5: HEX[i*7+:7] = 7'b0010010;
        'h6: HEX[i*7+:7] = 7'b0000010;
        'h7: HEX[i*7+:7] = 7'b1111000;
        'h8: HEX[i*7+:7] = 7'b0000000;
        'h9: HEX[i*7+:7] = 7'b0010000;
        'ha: HEX[i*7+:7] = 7'b0001000;
        'hb: HEX[i*7+:7] = 7'b0000011;
        'hc: HEX[i*7+:7] = 7'b0100111;
        'hd: HEX[i*7+:7] = 7'b0100001;
        'he: HEX[i*7+:7] = 7'b0000110;
        'hf: HEX[i*7+:7] = 7'b0001110;
      endcase
    end
  end

  assign aluif.ALUOP = cpu_types_pkg::aluop_t'(~KEY);
  assign aluif.A = {{16{SW[16]}}, SW[15:0]};
  assign aluif.B = register_b;
  assign LEDR = { aluif.N, aluif.V, aluif.Z };
  assign { HEX7, HEX6, HEX5, HEX4, HEX3, HEX2, HEX1, HEX0 } = HEX;
endmodule

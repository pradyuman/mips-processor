`include "cpu_types_pkg.vh"
`include "register_file_if.vh"

module register_file (
  input logic CLK, nRST,
  register_file_if.rf rfif
);
   cpu_types_pkg::word_t [31:0] register_file;

   assign rfif.rdat1 = register_file[rfif.rsel1];
   assign rfif.rdat2 = register_file[rfif.rsel2];

   always_ff @ (negedge CLK, negedge nRST)
      if (!nRST) register_file <= '0;
      else if (rfif.WEN && rfif.wsel)
        register_file[rfif.wsel] <= rfif.wdat;
endmodule

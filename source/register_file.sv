`include "cpu_types_pkg.vh"
`include "register_file_if.vh"

module register_file (input logic CLK, nRST, register_file_if.rf rfif);
   // 32 x 32 register
   cpu_types_pkg::word_t [31:0] register_file;

   // read logic
   assign rfif.rdat1 = register_file[rfif.rsel1];
   assign rfif.rdat2 = register_file[rfif.rsel2];

   // write and reset logic
   always_ff @ (posedge CLK, negedge nRST) begin
      if (nRST == 1'b0)
        register_file <= '0;
      else if (rfif.WEN && rfif.wsel != 0)
        register_file[rfif.wsel] <= rfif.wdat;
   end
endmodule

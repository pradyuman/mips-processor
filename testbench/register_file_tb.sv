// mapped needs this
`include "register_file_if.vh"
import cpu_types_pkg::word_t;

// mapped timing needs this. 1ns is too fast
`timescale 1 ns / 1 ns

module register_file_tb;
   parameter PERIOD = 10;
   parameter RFILE_SIZE = 32;
   logic CLK = 0, nRST;

   // test vars
   int   v1 = 1;
   int   v2 = 4721;
   int   v3 = 25119;

   // clock
   always #(PERIOD/2) CLK++;

   // interface
   register_file_if rfif();
   // DUT
   register_file DUT(.CLK, .nRST, .rfif);

   initial begin
      // $display("ns\tCLK\tnRST\tWEN");
      // $monitor("%0.2d\t%b\t%b\t%b", $time, CLK, nRST, rfif.WEN);

      // Error vector
      static struct {
         integer resetFile;
         integer resetRead;
      } errors = '{default:0};

      // Test nRST
      $display("Testing Internal Register File on reset...");
      reset();
      testInternalFile('{default:0}, errors.resetFile);
      if (!errors.resetFile) $display("SUCCESS: Internal Register File properly reset.");
      else $display("FAILURE: %0d errors resetting Internal Register File.", errors.resetFile);

      $display("Testing register file read after reset...");
      testRead('{default:0}, errors.resetRead);
      if (!errors.resetRead) $display("SUCCESS: Read working properly after reset.");
      else $display("FAILURE: %0d errors reading from register file after reset", errors.resetRead);

      rfif.WEN = 1'b1;
      #PERIOD
      for (int i=0; i<32; i++) begin
         rfif.wsel = i;
         rfif.wdat = i;
         #PERIOD;
      end

      for (int i=0; i<32; i++)
         $display("%0.2d: %0.2d", i, DUT.register_file[i]);
      $finish;
   end // initial begin

   // Reset Register File
   task reset;
      nRST = 1'b1; #PERIOD;
      nRST = 1'b0; #PERIOD;
      nRST = 1'b1; #PERIOD;
   endtask

   // Test Internal Register Memory on Reset
   task automatic testInternalFile(input word_t [RFILE_SIZE:0] testData, ref integer e);
      foreach (testData[,i])
         assert(DUT.register_file[i] == testData[i]) else begin
            $display("ERROR: DUT.register_file[%0d] (%0d) != testData[%0d] (%0d)",
                     i, DUT.register_file[i], i, testData[i]);
            e++;
         end
   endtask

   // Test RDAT
   task automatic testRead(input word_t [RFILE_SIZE:0] testData, ref integer e);
      foreach (testData[,i]) begin
         rfif.rsel1 = i;
         rfif.rsel2 = i;
         #PERIOD
         assert(rfif.rdat1 == testData[i]) else begin
            $display("ERROR: rfif.rdat1[%0d] (%0d) != testData[%0d] (%0d)",
                     i, rfif.rdat1, i, testData[i]);
            e++;
         end
         assert(rfif.rdat2 == testData[i]) else begin
            $display("ERROR: rfif.rdat2[%0d] (%0d) != testData[%0d] (%0d)",
                     i, rfif.rdat2, i, testData[i]);
            e++;
         end
      end
   endtask
endmodule

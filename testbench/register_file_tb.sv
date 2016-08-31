`include "register_file_if.vh"
`timescale 1 ns / 1 ns
import cpu_types_pkg::word_t;

module register_file_tb;
   register_file_if rfif();
   _tb rf_tb(rfif.tb);
endmodule // register_file_tb

module _tb (register_file_if.tb rfif);
   parameter PERIOD = 10;
   parameter RFILE_SIZE = 32;
   logic CLK = 0, nRST;

   // clock
   always #(PERIOD/2) CLK++;

   // DUT
   register_file DUT(.CLK, .nRST, .rfif);

   initial begin
     // Error vector
      enum { resetFile, resetRead, write } e;
      static integer errors[3] = '{default:0};

     // $display("ns\tCLK\tnRST\tWEN");
     // $monitor("%0.2d\t%b\t%b\t%b", $time, CLK, nRST, rfif.WEN);

     // Test nRST
     reset();
     testInternalFile('{default:0}, errors[resetFile]);
     resolve("Internal Register File after reset", errors[resetFile]);

     testRead('{default:0}, errors[resetRead]);
     resolve("READ after reset.", errors[resetRead]);

     // Test Read/Write
     testWrite('{default:0}, errors[write]);
     resolve("Read/Write with random test cases.", errors[write]);

     // for (int i=0; i<32; i++)
     //    $display("%0.2d: %0.2d", i, DUT.register_file[i]);

     $display("TOTAL ERRORS: %0d", errors.sum());
     $finish;
   end // initial begin

   // Reset Register File
   task reset;
     nRST = 1'b1; #PERIOD;
     nRST = 1'b0; #PERIOD;
     nRST = 1'b1; #PERIOD;
   endtask // testInternalFile

   task writeRandomValues(word_t [RFILE_SIZE:0] testData);
   endtask // writeRandomValues

   // Test Internal Register Memory on Reset
   task automatic testInternalFile(word_t [RFILE_SIZE:0] testData, ref integer e);
     foreach (testData[,i])
       assert(DUT.register_file[i] == testData[i]) else begin
         $display("ERROR: DUT.register_file[%0d] (%0d) != testData[%0d] (%0d)",
                                                          i, DUT.register_file[i], i, testData[i]);
         e++;
       end
   endtask // testInternalFile

   // Test RDAT
   task automatic testRead(word_t [RFILE_SIZE:0] testData, ref integer e);
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
   endtask // testRead

   // Populate Register File
   task automatic testWrite(word_t [RFILE_SIZE:0] testData, ref integer e);
     std::randomize(testData);
     rfif.WEN = 1'b1;
     foreach (testData[,i]) begin
       rfif.wsel = i;
       rfif.wdat = testData[i];
       #PERIOD;
     end
     rfif.WEN = 1'b0;

     testData[0] = 0;
     testRead(testData, e);
   endtask // testWrite

   task resolve(string message, integer e);
     if (!e) $display("SUCCESS: %s", message);
     else $display("FAILURE: %s - %0d errors", message, e);
   endtask
endmodule

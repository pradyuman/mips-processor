`include "cpu_types_pkg.vh"
`include "cache_control_if.vh"
`include "cpu_ram_if.vh"
`include "caches_if.vh"
`timescale 1ns / 1ns

import cpu_types_pkg::*;

module memory_control_tb;

  parameter PERIOD = 10;
  logic CLK = 0, nRST;

   always #(1) CLK++;

  caches_if cif0 ();
  caches_if cif1 ();
  cache_control_if #(.CPUS(1)) ccif (cif0, cif1);
  cpu_ram_if ramif ();

  memory_control DUT_M (ccif);
  ram DUT_R (CLK, nRST, ramif);

  assign ccif.ramload = ramif.ramload;
  assign ccif.ramstate = ramif.ramstate;

  assign ramif.ramaddr = ccif.ramaddr;
  assign ramif.ramWEN = ccif.ramWEN;
  assign ramif.ramREN = ccif.ramREN;
  assign ramif.ramstore = ccif.ramstore;

  initial
  begin
//111111111111111111111
      #(1.5)
      cif0.iaddr = 0;
      cif0.iREN = 0;
      cif0.dREN = 0;
      cif0.dWEN = 0;
      cif0.dstore = 0;
      cif0.daddr = 0;
      nRST = 1;
      #(10)
      nRST = 0;
      #(10)
      nRST = 1;
      cif0.iaddr = 0;
      cif0.iREN = 0;
      cif0.dREN = 0;
      cif0.dWEN = 0;
      cif0.dstore = 0;
      cif0.daddr = 0;
      #(10)
      cif0.iaddr = 0;
      cif0.iREN = 0;
      cif0.dREN = 0;
      cif0.dWEN = 1;
      cif0.dstore = 233;
      cif0.daddr = 100;
      if(cif0.dwait == 1)
        $display("W started\n");
      else
        $display("gg start\n");
          #(3)
      if(cif0.dwait == 0)
        $display("W done\n");
      else
        $display("gg done\n");
//222222222222222222222
      cif0.iaddr = 0;
      cif0.iREN = 0;
      cif0.dREN = 1;
      cif0.dWEN = 0;
      cif0.dstore = 233;
      cif0.daddr = 100;
      #(10)
      if(ccif.ramload == 233)
        $display("yup\n");
      else
        $display("no!! %d", ccif.ramload);
      #10
      dump_memory();
    $finish;
 end  
    
 task automatic dump_memory();   
 string filename = "memcpu.hex";
    int memfd;

    cif0.daddr = 0;
    cif0.dWEN = 0;
    cif0.dREN = 0;

    memfd = $fopen(filename,"w");
    if (memfd)
      $display("Starting memory dump.");
    else
      begin $display("Failed to open %s.",filename); $finish; end

    for (int unsigned i = 0; memfd && i < 16384; i++)
    begin
      int chksum = 0;
      bit [7:0][7:0] values;
      string ihex;

      cif0.daddr = i << 2;
      cif0.dREN = 1;
      repeat (4) @(posedge CLK);
      if (cif0.dload === 0)
        continue;
      values = {8'h04,16'(i),8'h00,cif0.dload};
      foreach (values[j])
        chksum += values[j];
      chksum = 16'h100 - chksum;
      ihex = $sformatf(":04%h00%h%h",16'(i),cif0.dload,8'(chksum));
      $fdisplay(memfd,"%s",ihex.toupper());
    end //for
    if (memfd)
    begin
      cif0.dREN = 0;
      $fdisplay(memfd,":00000001FF");
      $fclose(memfd);
      $display("Finished memory dump.");
    end
  endtask
    



  

endmodule

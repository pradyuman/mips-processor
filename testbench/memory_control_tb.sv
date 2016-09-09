`include "cache_control_if.vh"
`include "caches_if.vh"
`include "cpu_ram_if.vh"
`timescale 1 ns / 1 ns
import cpu_types_pkg::word_t;

module memory_control_tb #(parameter PERIOD = 10);
  logic CLK = 0, nRST;
  always #(PERIOD/2) CLK++;

  caches_if cif();
  cache_control_if #(.CPUS(1)) ccif(.cif0(cif), .cif1(cif));

  cpu_ram_if ramif();
  ram RAM(.CLK, .nRST, .ramif);
  memory_control DUT(.ccif);

  assign ccif.ramload = ramif.ramload;
  assign ccif.ramstate = ramif.ramstate;
  assign ramif.ramstore = ccif.ramstore;
  assign ramif.ramaddr = ccif.ramaddr;
  assign ramif.ramWEN = ccif.ramWEN;
  assign ramif.ramREN = ccif.ramREN;

  typedef enum { iREAD, dREAD, dWRITE } cstate;
  static integer ecnt = 0;

  initial begin
    // Test Reset
    reset();
    dRead(0);
    if (cif.dload != 32'h340100F0) error("Reset Failed.", ecnt);

    // Test Write -> Read
    dWrite(0, 99);
    dRead(0);
    if (cif.dload != 99) error("Write Failed.", ecnt);
    #PERIOD;
    dRead(10);
    #(PERIOD*4);
    if (cif.dload == 99) error("Write wrong location.", ecnt);
    $display("TOTAL ERRORS: %0d", ecnt);
    dump_memory();
    $finish;
  end

  // Reset RAM
  task reset;
    nRST = 1'b1; #PERIOD;
    nRST = 1'b0; #PERIOD;
    nRST = 1'b1; #PERIOD;
  endtask

  task set(cstate state);
    cif.iREN = state == iREAD;
    cif.dREN = state == dREAD;
    cif.dWEN = state == dWRITE;
    #PERIOD;
  endtask

  task dWrite(word_t addr, word_t value);
    cif.daddr = addr; cif.dstore = value; set(dWRITE);
  endtask

  task dRead(word_t addr);
    cif.daddr = addr; set(dREAD);
  endtask

  task iRead(word_t addr, word_t value);
    cif.iaddr = addr; set(iREAD);
  endtask

  task automatic dump_memory();
    string filename = "memcpu.hex";
    int memfd;

    cif.daddr = 0;
    cif.iREN = 0;
    cif.dWEN = 0;
    cif.dREN = 0;

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

      cif.daddr = i << 2;
      cif.dREN = 1;
      repeat (4) @(posedge CLK);
      if (cif.dload === 0)
        continue;
      values = {8'h04,16'(i),8'h00,cif.dload};
      foreach (values[j]) chksum += values[j];
      chksum = 16'h100 - chksum;
      ihex = $sformatf(":04%h00%h%h",16'(i),cif.dload,8'(chksum));
      $fdisplay(memfd,"%s",ihex.toupper());
    end //for
    if (memfd)
    begin
      cif.dREN = 0;
      $fdisplay(memfd,":00000001FF");
      $fclose(memfd);
      $display("Finished memory dump.");
    end
  endtask

  task automatic error(string message, ref integer e);
    $display("ERROR: %s | dload - %0d", message, cif.dload); e++;
  endtask
endmodule

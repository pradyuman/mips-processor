`include "cache_control_if.vh"
`include "caches_if.vh"
`include "cpu_ram_if.vh"
`timescale 1 ns / 1 ns
import cpu_types_pkg::*;

module memory_control_tb #(parameter PERIOD = 10);
  logic CLK = 0, nRST;
  always #(PERIOD/2) CLK++;

  caches_if cif0();
  caches_if cif1();
  cache_control_if ccif(.cif0(cif0), .cif1(cif1));

  memory_control DUT(.CLK, .nRST, .ccif);

  typedef enum   logic [2:0] {
    IDLE, CWB1, CWB2, CLW1, CLW2, SNOOP, SWB1, SWB2
  } cc_state;

  static integer ecnt = 0;

  initial begin
    init();

    // Write from cif0
    cif0.daddr = 5;
    cif0.dstore = 32;
    cif0.dWEN = 1;
    #PERIOD;
    if (DUT.state != CWB1) error("[cif0 write] Not entering CWB1", ecnt);
    if (ccif.ramstore != 32) error("[cif0 write] ccif.ramstore incorrect", ecnt);
    if (ccif.ramaddr != 5) error("[cif0 write] ccif.ramaddr incorrect", ecnt);

    cif0.daddr = 6;
    cif0.dstore = 45;
    #PERIOD;
    if (DUT.state != CWB2) error("[cif0 write] Not entering CWB2", ecnt);
    if (ccif.ramstore != 45) error("[cif0 write] ccif.ramstore incorrect", ecnt);
    if (ccif.ramaddr != 6) error("[cif0 write] ccif.ramaddr incorrect", ecnt);

    #PERIOD;
    cif0.dWEN = 0;
    if (DUT.state != IDLE) error("[cif0 write] Not going back to IDLE CWB2", ecnt);

    // Write from cif1
    cif1.daddr = 7;
    cif1.dstore = 22;
    cif1.dWEN = 1;
    #PERIOD;
    if (DUT.state != CWB1) error("[cif1 write] Not entering CWB1", ecnt);
    if (ccif.ramstore != 22) error("[cif1 write] ccif.ramstore incorrect", ecnt);
    if (ccif.ramaddr != 7) error("[cif1 write] ccif.ramaddr incorrect", ecnt);

    cif1.daddr = 8;
    cif1.dstore = 35;
    #PERIOD;
    if (DUT.state != CWB2) error("[cif1 write] Not entering CWB2", ecnt);
    if (ccif.ramstore != 35) error("[cif1 write] ccif.ramstore incorrect", ecnt);
    if (ccif.ramaddr != 8) error("[cif1 write] ccif.ramaddr incorrect", ecnt);

    #PERIOD;
    cif1.dWEN = 0;
    if (DUT.state != IDLE) error("[cif1 write] Not going back to IDLE", ecnt);

    // Read from cif1 (SNOOP)
    cif1.daddr = 5;
    cif1.dREN = 1;

    #PERIOD;
    if (DUT.state != SNOOP) error("[cif1 SNOOP] Not entering SNOOP", ecnt);
    if (ccif.ramWEN) error("[cif1 SNOOP] ccif.ramWEN asserted in SNOOP", ecnt);
    if (!ccif.dwait) error("[cif1 SNOOP] ccif.dwait not asserted in SNOOP", ecnt);
    if (cif0.ccwait != 1) error("[cif1 SNOOP] cif0.ccwait not asserted", ecnt);
    if (cif0.ccsnoopaddr != 5) error("[cif1 SNOOP] cif0.ccsnoopaddr incorrect", ecnt);

    cif0.dstore = 32;
    cif0.ccwrite = 1;

    #PERIOD;
    if (DUT.state != SWB1) error("[cif1 SNOOP] Not entering SWB1", ecnt);
    if (!ccif.ramWEN) error("[cif1 SNOOP] ccif.ramWEN not asserted in SWB1", ecnt);
    if (!ccif.dwait) error("[cif1 SNOOP] ccif.dwait not asserted in SWB1", ecnt);
    if (cif1.dload != 32) error("[cif1 SNOOP] cif1.dload incorrect in SWB1", ecnt);

    cif0.dstore = 45;
    cif0.ccwrite = 0;

    #PERIOD;
    if (DUT.state != SWB2) error("[cif1 SNOOP] Not entering SWB2", ecnt);
    if (!ccif.ramWEN) error("[cif1 SNOOP] ccif.ramWEN not asserted in SWB2", ecnt);
    if (ccif.dwait) error("[cif1 SNOOP] ccif.dwait asserted in SWB2", ecnt);
    if (cif1.dload != 45) error("[cif1 SNOOP] cif1.dload incorrect in SWB2", ecnt);

    #PERIOD;
    cif1.dREN = 0;
    if (DUT.state != IDLE) error("[cif1 SNOOP] Not going back to IDLE", ecnt);
    if (ccif.ramWEN) error("[cif1 SNOOP] ccif.ramWEN asserted in IDLE", ecnt);
    if (ccif.dwait) error("[cif1 SNOOP] ccif.dwait asserted in IDLE", ecnt);
    if (cif1.dload != 45) error("[cif1 SNOOP] cif1.dload incorrect in IDLE", ecnt);

    // Read from cif1 (RAM READ)
    cif1.daddr = 100;
    cif1.dREN = 1;

    #PERIOD;
    if (DUT.state != SNOOP) error("[cif1 RAM READ] Not entering SNOOP", ecnt);
    if (!cif0.ccwait) error("[cif1 RAM READ] cif0.ccwait not asserted", ecnt);
    if (cif0.ccsnoopaddr != 100) error("[cif1 RAM READ] cif0.ccsnoopaddr incorrect", ecnt);

    cif0.ccwrite = 0;

    #PERIOD;
    if (DUT.state != CLW1) error("[cif1 RAM READ] Not entering CLW1", ecnt);
    if (!ccif.ramREN) error("[cif1 RAM READ] ccif.ramREN not asserted in CLW1", ecnt);
    if (ccif.ramaddr != 100) error("[cif1 RAM READ] ccif.ramaddr incorrect in CLW1", ecnt);
    if (!cif1.dwait) error("[cif1 RAM READ] cif1.dwait not asserted in CLW1", ecnt);

    ccif.ramload = 125;

    #PERIOD;
    if (DUT.state != CLW2) error("[cif1 RAM READ] Not entering CLW2", ecnt);
    if (cif1.dload != 125) error("[cif1 RAM READ] cif1.dload incorrect in CLW2", ecnt);
    if (cif1.dwait) error("[cif1 RAM READ] cif1.dwait asserted in CLW1", ecnt);

    ccif.ramload = 130;

    #PERIOD;
    if (DUT.state != IDLE) error("[cif1 RAM READ] Not entering IDLE", ecnt);
    if (cif1.dload != 130) error("[cif1 RAM READ] cif1.dload incorrect in IDLE", ecnt);
    if (cif1.dwait) error("[cif1 RAM READ] cif1.dwait asserted in CLW1", ecnt);

    $display("TOTAL ERRORS: %0d", ecnt);
    $finish;
  end

  task init;
    // Reset
    nRST = 1; #PERIOD;
    nRST = 0; #PERIOD;
    nRST = 1; #PERIOD;

    cif0.iREN = 0;
    cif0.dREN = 0;
    cif0.dWEN = 0;
    cif0.cctrans = 0;

    cif1.iREN = 0;
    cif1.dREN = 0;
    cif1.dWEN = 0;
    cif1.cctrans = 0;

    ccif.ramstate = ACCESS;
  endtask

  task automatic error(string message, ref integer e);
    $display("ERROR: %s", message); e++;
  endtask
endmodule

module pipeline (
  input logic CLK, nRST,
  output logic halt,
  cpu_ram_if.cpu scif
);
  parameter PC0 = 0;

  datapath_cache_if         dcif ();
  caches_if                 cif0();
  caches_if                 cif1();
  cache_control_if    #(.CPUS(1))       ccif (cif0, cif1);

  datapath #(.PC_INIT(PC0)) DP (CLK, nRST, dcif);
  caches                    CM (CLK, nRST, dcif, cif0);
  memory_control            CC (CLK, nRST, ccif);

  assign scif.memaddr = ccif.ramaddr;
  assign scif.memstore = ccif.ramstore;
  assign scif.memREN = ccif.ramREN;
  assign scif.memWEN = ccif.ramWEN;

  assign ccif.ramload = scif.ramload;
  assign ccif.ramstate = scif.ramstate;

  assign halt = dcif.flushed;
endmodule

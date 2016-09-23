`include "system_if.vh"
`include "cpu_types_pkg.vh"

module system (input logic CLK, nRST, system_if.sys syif);
  parameter CLKDIV = 2;

  logic halt, CPUCLK;
  logic [3:0] count;

  cpu_ram_if                            prif ();
  pipeline    #(.PC0('h0))              CPU (CLK, nRST, halt, prif);
  ram                                   RAM (CLK, nRST, prif);

  always_ff @(posedge CLK, negedge nRST) begin
    if (!nRST) begin
      count <= 0;
      CPUCLK <= 0;
    end
    else if (count == CLKDIV-2) begin
      count <= 0;
      CPUCLK <= ~CPUCLK;
    end
    else count <= count + 1;
  end

  assign syif.halt = halt;
  assign syif.load = prif.ramload;

  assign prif.ramWEN = (syif.tbCTRL) ? syif.WEN : prif.memWEN;
  assign prif.ramREN = (syif.tbCTRL) ? syif.REN : prif.memREN;
  assign prif.ramaddr = (syif.tbCTRL) ? syif.addr : prif.memaddr;
  assign prif.ramstore = (syif.tbCTRL) ? syif.store : prif.memstore;

endmodule

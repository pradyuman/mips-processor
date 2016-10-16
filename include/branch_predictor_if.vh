`ifndef BTB_IF_VH
`define BTB_IF_VH

interface btb_if;
  logic [29:0] brAddr, pcCpc, brPc, cpc;
  logic [27:0] tag;
  logic flush;
  predMux predSel;
  pcMux pcSel;

  modport bp (
    input brAddr, pcCpc, tag, pcSel;
    output cpc, flush
  );
  

endinterface
`endif

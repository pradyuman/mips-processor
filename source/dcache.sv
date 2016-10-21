`include "caches_if.vh"
`include "datapath_cache_if.vh"
`include "cpu_types_pkg.vh"

import cpu_types_pkg::*;

typedef struct packed {
  logic valid;
  logic dirty;
  logic [DTAG_W-1:0] tag;
  word_t [1:0] data;
} delement;

typedef struct packed {
  logic        lru;
  delement [1:0] e;
} dentry;

typedef enum logic [3:0] {
  IDLE, RHIT, WHIT, WB1, WB2, LD1, LD2, NFL, FL1, FL2, HALT
} dc_state;

module dcache(
  input logic CLK, nRST,
  caches_if.dcache cif,
  datapath_cache_if.dcache dcif
);
  word_t c;
  dcachef_t i;
  logic cEN, lru, ei, n_ei;
  dentry [7:0] ddb, n_ddb;
  logic [2:0] fentry, n_fentry;
  logic [2:0] felement, n_felement;
  dc_state state, n_state;

  assign i = dcif.dmemaddr;
  assign lru = ddb[i.idx].lru;

  always_ff @(posedge CLK, negedge nRST)
    if (!nRST) begin
      c <= '0;
      ei <= '0;
      ddb <= '0;
      fentry <= '0;
      felement <= '0;
      state <= IDLE;
    end
    else if (dcif.dmemREN) begin
      c <= cEN ? c + 1 : c;
      ei <= n_ei;
      ddb <= n_ddb;
      fentry <= n_fentry;
      felement <= n_felement;
      state <= n_state;
    end

  assign dcif.dmemload = ddb[i.idx].e[ei].data[i.blkoff];

  always_comb begin
    n_ei = 0;
    cEN = 0;
    n_ddb = ddb;
    n_fentry = 0;
    n_state = state;

    dcif.dhit = 0;
    dcif.flushed = 0;

    cif.dREN = 0;
    cif.dWEN = 0;
    cif.daddr = 'x;
    cif.dstore = 'x;

    casez(state)
      IDLE: begin
        if (dcif.dmemREN) begin
          if (ddb[i.idx].e[0].valid & ddb[i.idx].e[0].tag == i.tag)
            n_state = RHIT;
          else if (ddb[i.idx].e[1].valid & ddb[i.idx].e[1].tag == i.tag) begin
            n_ei = 1;
            n_state = RHIT;
          end
          else if (ddb[i.idx].e[0].dirty | ddb[i.idx].e[1].dirty)
            n_state = WB1;
          else n_state = LD1;
        end
        else if (dcif.dmemWEN) begin
          if (ddb[i.idx].e[0].valid & ddb[i.idx].e[0].tag == i.tag)
            n_state = WHIT;
          else if (ddb[i.idx].e[1].valid & ddb[i.idx].e[1].tag == i.tag) begin
            n_ei = 1;
            n_state = WHIT;
          end
          else if (ddb[i.idx].e[0].dirty | ddb[i.idx].e[1].dirty)
            n_state = WB1;
          else n_state = LD1;
        end
        else if (dcif.halt) n_state = NFL;
      end
      RHIT: begin
        cEN = 1;
        n_ddb[i.idx].lru = !ei;
        dcif.dhit = 1;
      end
      WHIT: begin
        cEN = 1;
        n_ddb[i.idx].lru = !ei;
        n_ddb[i.idx].e[ei].data[i.blkoff] = dcif.dmemstore;
        dcif.dhit = 1;
      end
      WB1: begin
        cif.dWEN = 1;
        cif.dstore = ddb[i.idx].e[lru].data[0];
        if (!cif.dwait) n_state = WB2;
      end
      WB2: begin
        cif.dWEN = 1;
        cif.dstore = ddb[i.idx].e[lru].data[1];
        if (!cif.dwait) n_state = LD1;
      end
      LD1: begin
        cif.dREN = 1;
        cif.daddr = dcif.dmemaddr;
        if (!cif.dwait) begin
          n_ddb[i.idx].e[lru].data[i.blkoff] = cif.dload;
          n_state = LD2;
        end
      end
      LD2: begin
        cif.dREN = 1;
        cif.daddr = i.blkoff ? dcif.dmemaddr - 1 : dcif.dmemaddr + 1;
        if (!cif.dwait) begin
          n_ddb[i.idx].e[lru].data[!i.blkoff] = cif.dload;
          dcif.dhit = 1;
          n_state = IDLE;
        end
      end
      FL1: begin
        cif.dWEN = 1;
        cif.dstore = ddb[i.idx].e[felement].data[0];
        if (!cif.dwait) n_state = FL2;
      end
      FL2: begin
        cif.dWEN = 1;
        cif.dstore = ddb[i.idx].e[felement].data[1];
        if (!cif.dwait) begin
          n_felement = !felement;
          n_fentry = felement ? fentry + 1 : fentry;
          n_state = fentry == 7 ? HALT : FL1;
        end
      end
      HALT: begin
        dcif.flushed = 1;
        n_state = HALT;
      end
    endcase
  end
endmodule

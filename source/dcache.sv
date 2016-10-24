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
  IDLE, RHIT, WHIT, WB1, WB2, LD1, LD2, FL1, FL2, SC, DHALT
} dc_state;

module dcache(
  input logic CLK, nRST,
  caches_if.dcache cif,
  datapath_cache_if.dcache dcif
);

  dcachef_t i;
  logic lru, valid, dirty;
  logic [1:0] em;
  dentry [7:0] ddb, n_ddb;
  logic [3:0] fen, n_fen;
  dc_state state, n_state;

  assign i = dcif.dmemaddr;
  assign lru = ddb[i.idx].lru;

  always_ff @(posedge CLK, negedge nRST) begin
    if (!nRST) begin
      ddb <= '0;
      fen <= '0;
      state <= IDLE;
    end
    else begin
      ddb <= n_ddb;
      fen <= n_fen;
      state <= n_state;
    end
  end
  //Comb Output
  assign em[0] = ddb[i.idx].e[0].tag == i.tag;
  assign em[1] = ddb[i.idx].e[1].tag == i.tag;
  assign dcif.dmemload = em[0] && ddb[i.idx].e[0].data[i.blkoff] |
                         em[1] && ddb[i.idx].e[1].data[i.blkoff];
  assign dcif.dhit = em[0] && ddb[i.idx].e[0].valid |
                     em[1] && ddb[i.idx].e[1].valid;

  // CT INC, DEC
  word_t ct;
  logic prevhit, prevmiss, miss, ctINC, ctDEC;
  always_ff @(posedge CLK, negedge nRST) begin
    if(!nRST) begin
      ct <= 0;
      prevhit <= 0;
      prevmiss <= 0;
    end
    else begin
      ct <= ct + ctINC -ctDEC;
      prevhit <= dcif.dhit;
      prevmiss <= miss;
    end
  end
  assign miss = state == LD1;
  assign ctINC = (prevhit ^ dcif.dhit) & dcif.dhit;
  assign ctDEC = (prevmiss ^ miss) & miss;

  // WHIT->write, MISS->load, HALT
  always_comb begin
    n_ddb = ddb;
    n_fen = 0;
    n_state = state;

    dcif.flushed = 0;
    cif.dREN = 0;
    cif.dWEN = 0;
    cif.daddr = 'x;
    cif.dstore = 'x;

    n_ddb[i.idx].lru = dcif.dhit & em[0];
    // WEN HIT
    if(dcif.dhit)begin
      n_ddb[i.idx].e[em[1]].data[i.blkoff] = dcif.dmemload;
    end
    // MISS, FLUSH, HALT
    casez(state)
      IDLE: begin
        if(dcif.halt) n_state = FL1;
        else if ((dcif.dmemREN | dcif.dmemWEN) && !dcif.dhit) begin
          if (ddb[i.idx].e[lru].dirty) n_state = WB1;
          else n_state = LD1;
        end
      end
      WB1: begin
        cif.dWEN = 1;
        cif.daddr = { ddb[i.idx].e[lru].tag, i.idx, 3'b000 };
        cif.dstore = ddb[i.idx].e[lru].data[0];
        if (!cif.dwait) n_state = WB2;
      end
      WB2: begin
        cif.dWEN = 1;
        cif.daddr = { ddb[i.idx].e[lru].tag, i.idx, 3'b100 };
        cif.dstore = ddb[i.idx].e[lru].data[1];
        if (!cif.dwait) n_state = LD1;
      end
      LD1: begin
        cif.dREN = 1;
        cif.daddr = { dcif.dmemaddr[31:1], 1'b0 };
        if (!cif.dwait) begin
          n_ddb[i.idx].e[lru].data[0] = cif.dload;
          n_state = LD2;
        end
      end
      LD2: begin
        cif.dREN = 1;
        cif.daddr = { dcif.dmemaddr[31:1], 1'b1};
        if (!cif.dwait) begin
          n_ddb[i.idx].e[lru].data[1] = cif.dload;
          n_ddb[i.idx].e[lru].tag = i.tag;
          n_state = IDLE;
        end
      end
      FL1: begin
        if(ddb[fen[3:1]].e[fen[0]].dirty) begin
          cif.dWEN = 1;
          cif.daddr = { ddb[fen[3:1]].e[fen[0]].tag, fen[3:1], 3'b000 };
          cif.dstore = ddb[fen[3:1]].e[fen[0]].data[0];
          if (!cif.dwait) n_state = FL2;
        end
        else begin
          n_fen = fen + 1;
          n_state = fen == 15 ? DHALT : FL1;
        end
      end
      FL2: begin
        cif.dWEN = 1;
        cif.daddr = { ddb[fen[3:1]].e[fen[0]].tag, fen[3:1], 3'b100 };
        cif.dstore = ddb[fen[3:1]].e[fen[0]].data[1];
        if (!cif.dwait) begin
          n_fen = fen + 1;
          n_state = fen == 15 ? DHALT : FL1;
        end
      end
      SC: begin
        cif.dWEN = 1;
        cif.daddr = 32'h3100;
        cif.dstore = ct;
        if(!cif.dwait) n_state = DHALT;
      end
      DHALT: begin
        dcif.flushed = 1;
        n_state = DHALT;
      end
    endcase
  end
endmodule

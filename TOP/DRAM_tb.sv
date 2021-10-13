`timescale 1ns/10ps
`define CYCLE 10
`include "DRAM.v"

module test;

    parameter word_size = 32;  // Word Size
    parameter addr_size = 11;  // Address Size

    logic [word_size-1:0] Q;   // Data Output
    logic RST; 
    logic CSn;                 // Chip Select
    logic WEn;                 // Write Enable
    logic RASn;                // Row Address Select
    logic CASn;                // Column Address Select
    logic [addr_size-1:0] A;   // Address
    logic [word_size-1:0] D;   // Data Input

  DRAM M1 (
    .Q(Q),
    .RST(RST),
    .CSn(CSn),
    .WEn(WEn),
    .RASn(RASn),
    .CASn(CASn),
    .A(A),
    .D(D)
  );

  initial begin
    RST = 1;
    CSn = 0; WEn = 1;
    RASn = 1; CASn = 1;
    A = 0; D = 0;
    #(`CYCLE*2) RST = 0;
    #(`CYCLE) A = 5; // Row Address
    #(`CYCLE) RASn = 0;
    #(`CYCLE) A = 10; WEn = 0; D = 20; // Column Address
    #(`CYCLE) CASn = 0;
    #(`CYCLE*2) RASn = 1; CASn = 1; WEn = 1; D = 0;
    #(`CYCLE) A = 5; // Row Address
    #(`CYCLE) RASn = 0;
    #(`CYCLE) A = 10; // Column Address
    #(`CYCLE) CASn = 0;
    #(`CYCLE*2) RASn = 1; CASn = 1; WEn = 1; D = 0;
    #(`CYCLE*10) $finish;
  end

  initial begin
    $fsdbDumpfile("test.fsdb");
    $fsdbDumpvars(0, test);
  end
endmodule

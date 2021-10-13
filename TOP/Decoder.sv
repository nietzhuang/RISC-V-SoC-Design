`include "AHB_def.svh"

module Decoder(
  input         [`AHB_ADDR_BITS-1:0]        HADDR,
  output logic                              HSELDefault,
  output logic                              HSEL_S1,
  output logic                              HSEL_S2,
  output logic                              HSEL_S3,
  output logic                              HSEL_S4,
  output logic                              HSEL_S5
);

  always_comb
  begin
    HSELDefault = ((HADDR[31:28] != 4'b0001)&&(HADDR[31:28] != 4'b0010));
    HSEL_S1 = (HADDR[31:28] == 4'b0001);
    HSEL_S2 = (HADDR[31:28] == 4'b0010);
    HSEL_S3 = (HADDR[31:28] == 4'b0000);  // 0x0000_0000 select S3 ROM
    HSEL_S4 = (HADDR[31:28] == 4'b0011);  // 0x3000_0000 select S4 sensor
    HSEL_S5 = (HADDR[31:28] == 4'b0100);  // 0x4000_0000 select S5 DRAM
  end
endmodule

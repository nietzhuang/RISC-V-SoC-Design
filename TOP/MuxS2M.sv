`include "AHB_def.svh"

module MuxS2M(
  input                                     HCLK,
  input                                     HRESETn,

  input                                     HSELDefault,      // Default Slave
  input                                     HSEL_S1,          // S1
  input                                     HSEL_S2,          // S2
  input                                     HSEL_S3,
  input                                     HSEL_S4,
  input                                     HSEL_S5,

  input         [`AHB_DATA_BITS-1:0]        HRDATA_S1,
  input                                     HREADY_S1,
  input         [`AHB_RESP_BITS-1:0]        HRESP_S1,
  input         [`AHB_DATA_BITS-1:0]        HRDATA_S2,
  input                                     HREADY_S2,
  input         [`AHB_RESP_BITS-1:0]        HRESP_S2,
  input         [`AHB_DATA_BITS-1:0]        HRDATA_S3,
  input                                     HREADY_S3,
  input         [`AHB_RESP_BITS-1:0]        HRESP_S3,
  input         [`AHB_DATA_BITS-1:0]        HRDATA_S4,
  input                                     HREADY_S4,
  input         [`AHB_RESP_BITS-1:0]        HRESP_S4,
  input         [`AHB_DATA_BITS-1:0]        HRDATA_S5,
  input                                     HREADY_S5,
  input         [`AHB_RESP_BITS-1:0]        HRESP_S5,

  input                                     HREADYDefault,
  input         [`AHB_RESP_BITS-1:0]        HRESPDefault,

  output logic  [`AHB_DATA_BITS-1:0]        HRDATA,
  output logic                              HREADY,
  output logic  [`AHB_RESP_BITS-1:0]        HRESP
);

  logic     [`AHB_SLAVE_LEN-1:0]            SelNext;
  logic     [`AHB_SLAVE_LEN-1:0]            SelReg;


  always_comb
  begin
    SelNext = {HSEL_S5, HSEL_S4, HSEL_S3, HSEL_S2, HSEL_S1, HSELDefault};
  end

  always_ff@(posedge HCLK or negedge HRESETn)
  begin
    if (~HRESETn)
      SelReg <= #1 `AHB_SLAVE_LEN'd0;
    else if (HREADY)
      SelReg <= #1 SelNext;
  end

  always_comb  // HRDATA
  begin
    case(SelReg)
      `AHB_SLAVE_LEN'b000001:  // default master
        HRDATA = 32'd0;
      `AHB_SLAVE_LEN'b000010:
        HRDATA = HRDATA_S1;
      `AHB_SLAVE_LEN'b000100:
        HRDATA = HRDATA_S2;
      `AHB_SLAVE_LEN'b001000:  // M2
        HRDATA = HRDATA_S3;
      `AHB_SLAVE_LEN'b010000:  // M2
        HRDATA = HRDATA_S4;
      `AHB_SLAVE_LEN'b100000:  // M2
        HRDATA = HRDATA_S5;
      default:
        HRDATA = 32'd0;
    endcase
  end

  always_comb  // HREADY
  begin
    case(SelReg)
      `AHB_SLAVE_LEN'b000001:  // default master
        HREADY = HREADYDefault;
      `AHB_SLAVE_LEN'b000010:
        HREADY = HREADY_S1;
      `AHB_SLAVE_LEN'b000100:
        HREADY = HREADY_S2;
      `AHB_SLAVE_LEN'b001000:
        HREADY = HREADY_S3;
      `AHB_SLAVE_LEN'b010000:
        HREADY = HREADY_S4;
      `AHB_SLAVE_LEN'b100000:
        HREADY = HREADY_S5;
      default:
        HREADY = 1'b1;  // drive high initially
    endcase
  end

  always_comb  // HRESP
  begin
    case(SelReg)
      `AHB_SLAVE_LEN'b000001:  // default master
        HRESP = HRESPDefault;
      `AHB_SLAVE_LEN'b000010:
        HRESP = HRESP_S1;
      `AHB_SLAVE_LEN'b000100:
        HRESP = HRESP_S2;
      `AHB_SLAVE_LEN'b001000:
        HRESP = HRESP_S3;
      `AHB_SLAVE_LEN'b010000:
        HRESP = HRESP_S4;
      `AHB_SLAVE_LEN'b100000:
        HRESP = HRESP_S5;
      default:
        HRESP = 2'b0;
    endcase
  end

endmodule

`include "AHB_def.svh"

module MuxM2S(
  input                                     HCLK,
  input                                     HRESETn,
  input         [`AHB_MASTER_BITS-1:0]      HMASTER,
  input                                     HREADY,

  input         [`AHB_ADDR_BITS-1:0]        HADDR_M1,
  input         [`AHB_TRANS_BITS-1:0]       HTRANS_M1,
  input                                     HWRITE_M1,
  input         [`AHB_SIZE_BITS-1:0]        HSIZE_M1,
  input         [`AHB_DATA_BITS-1:0]        HWDATA_M1,

  input         [`AHB_ADDR_BITS-1:0]        HADDR_M2,
  input         [`AHB_TRANS_BITS-1:0]       HTRANS_M2,
  input                                     HWRITE_M2,
  input         [`AHB_SIZE_BITS-1:0]        HSIZE_M2,
  input         [`AHB_DATA_BITS-1:0]        HWDATA_M2,

  output logic  [`AHB_ADDR_BITS-1:0]        HADDR,
  output logic  [`AHB_TRANS_BITS-1:0]       HTRANS,
  output logic                              HWRITE,
  output logic  [`AHB_SIZE_BITS-1:0]        HSIZE,
  output logic  [`AHB_DATA_BITS-1:0]        HWDATA
);

  logic [`AHB_MASTER_BITS-1:0] MasterPrev;


  always_ff@(posedge HCLK or negedge HRESETn)
  begin
    if (~HRESETn)
      MasterPrev <= #1 `AHB_MASTER_BITS'd0;
    else if (HREADY)
      MasterPrev <= #1 HMASTER;
  end

  always_comb  // HADDR
  begin
    case(HMASTER)
      `AHB_MASTER_0:
        HADDR = 32'd0;  // for default master
      `AHB_MASTER_1:
        HADDR = HADDR_M1;
      `AHB_MASTER_2:
        HADDR = HADDR_M2;
      default:
        HADDR = 32'b0;
    endcase
  end

  always_comb
  begin
    case(HMASTER)
      `AHB_MASTER_0:
        HTRANS = 2'b0;
      `AHB_MASTER_1:
        HTRANS = HTRANS_M1;
      `AHB_MASTER_2:
        HTRANS = HTRANS_M2;
      default:
        HTRANS = 2'b0;
    endcase
  end

  always_comb  // HWRITE
  begin
    case(HMASTER)
      `AHB_MASTER_0:
        HWRITE = 1'b0;
      `AHB_MASTER_1:
        HWRITE = HWRITE_M1;
      `AHB_MASTER_2:
        HWRITE = HWRITE_M2;
      default:
        HWRITE = 1'b0;
    endcase
  end

  always_comb  // HSIZE
  begin
    case(MasterPrev)
      `AHB_MASTER_0:
        HSIZE = 3'b0;
      `AHB_MASTER_1:
        HSIZE = HSIZE_M1;
      `AHB_MASTER_2:
        HSIZE = HSIZE_M2;
      default:
        HSIZE = 3'b0;
    endcase
  end

  always_comb  // HWDATA
  begin
    case(HMASTER)
      `AHB_MASTER_0:
        HWDATA = 32'd0;
      `AHB_MASTER_1:
        HWDATA = HWDATA_M1;
      `AHB_MASTER_2:
        HWDATA = HWDATA_M2;
      default:
        HWDATA = 32'd0;
    endcase
  end
  
endmodule

`include "AHB_def.svh"

module Arbiter(
  input                                         HCLK,
  input                                         HRESETn,
  input             [`AHB_TRANS_BITS-1:0]       HTRANS,
  input                                         HREADY,
  input             [`AHB_RESP_BITS-1:0]        HRESP,
  input                                         HBUSREQ0, // for default master
  input                                         HBUSREQ1,
  input                                         HBUSREQ2,
  input                                         HLOCK0,
  input                                         HLOCK1,
  input                                         HLOCK2,
  output  logic                                 HGRANT0,
  output  logic                                 HGRANT1,
  output  logic                                 HGRANT2,
  output  logic     [`AHB_MASTER_BITS-1:0]      HMASTER,  // to slave, M2S
  output  logic                                 HMASTLOCK
);

  logic     [`AHB_MASTER_LEN-1:0]               ReqMaster;
  logic     [`AHB_MASTER_LEN-1:0]               NextGrantMaster;
  logic     [`AHB_MASTER_LEN-1:0]               GrantMaster;
  logic     [`AHB_MASTER_BITS-1:0]              NextMaster;
  logic                                         NextLock;
  logic                                         StillReq;


  always_comb
  begin
    ReqMaster = {HBUSREQ2, HBUSREQ1, HBUSREQ0};
    {HGRANT2, HGRANT1, HGRANT0} = GrantMaster;
    StillReq = |(ReqMaster & GrantMaster);
  end

  always_comb // define NextGrantMaster
  begin
    //NextGrantMaster is defined by all request signals
    if({HBUSREQ2, HBUSREQ1, HBUSREQ0} == 3'b000)
      NextGrantMaster = 3'b001;
    else if({HBUSREQ2, HBUSREQ1, HBUSREQ0} == 3'b110)
      NextGrantMaster = 3'b010;
    else
      NextGrantMaster = {HBUSREQ2, HBUSREQ1, HBUSREQ0};
  end

  always_ff@(posedge HCLK or negedge HRESETn)
  begin
    if (~HRESETn)
      GrantMaster <= #1 3'd0;
    else if (HREADY && (~HMASTLOCK) && (~NextLock) && (~StillReq))
      GrantMaster <= #1 NextGrantMaster;
  end

  always_comb
  begin
    case (GrantMaster)
      3'b001:  // case for default master
      begin
        NextMaster = `AHB_MASTER_BITS'b0000;
        NextLock = HLOCK0;
      end
      3'b010:  // case for M1
      begin
        NextMaster = `AHB_MASTER_BITS'b0001;
        NextLock = HLOCK1;
      end
      3'b100:  // case for M2
      begin
        NextMaster = `AHB_MASTER_BITS'b0010;
        NextLock = HLOCK2;
      end
      default:
      begin
        NextMaster = `AHB_MASTER_BITS'b0000;
        NextLock = HLOCK0;
      end
    endcase
  end

  always_ff@(posedge HCLK or negedge HRESETn)
  begin
    if (~HRESETn)
      HMASTER <= #1 `AHB_MASTER_BITS'd0;
    else if (HREADY)
      HMASTER <= #1 NextMaster;  // HMASTER = 4'b0001 for M1, HMASTER = 4'b0010 for M2
  end

  always_ff@(posedge HCLK or negedge HRESETn)
  begin
    if (~HRESETn)
      HMASTLOCK <= #1 1'b0;
    else if (HREADY)
      HMASTLOCK <= #1 NextLock;
  end
endmodule

`include "AHB_def.svh"
`include "define.sv"
`include "AHB.sv"
`include "S1_wra.sv"
`include "S2_wra.sv"

module top(
  input                             clk,
  input                             rst,
  input         [`data_size-1:0]    IM_out,
  input         [`data_size-1:0]    DM_out,


  output logic                      IM_enable,
  output logic  [`data_size-1:0]    IM_address,
  output logic                      DM_write,
  output logic                      DM_enable,
  output logic  [`data_size-1:0]    DM_in,
  output logic  [`data_size-1:0]    DM_address
);

  // AHB interface between among masters, AHB BUS and slaves.
  logic                             HGRANT_M1;
  logic                             HGRANT_M2;
  logic [`AHB_ADDR_BITS-1:0]        HADDR_M1;
  logic [`AHB_ADDR_BITS-1:0]        HADDR_M2;
  logic                             HBUSREQ_M1;
  logic                             HBUSREQ_M2;
  logic [`AHB_SIZE_BITS-1:0]        HSIZE_M1;
  logic [`AHB_SIZE_BITS-1:0]        HSIZE_M2;
  logic [`AHB_TRANS_BITS-1:0]       HTRANS_M1;
  logic [`AHB_TRANS_BITS-1:0]       HTRANS_M2;
  logic                             HLOCK_M1;
  logic                             HLOCK_M2;
  logic [`AHB_DATA_BITS-1:0]        HWDATA_M1;
  logic [`AHB_DATA_BITS-1:0]        HWDATA_M2;
  logic                             HWRITE_M1;
  logic                             HWRITE_M2;
  // Return from AHB BUS.
  logic [`AHB_ADDR_BITS-1:0]        HADDR;
  logic [`AHB_SIZE_BITS-1:0]        HSIZE;
  logic [`AHB_ADDR_BITS-1:0]        HTRANS;
  logic [`AHB_DATA_BITS-1:0]        HRDATA;  // Only one master accept the return transaction.
  logic [`AHB_DATA_BITS-1:0]        HWDATA;
  logic                             HWRITE;
  logic [`AHB_RESP_BITS-1:0]        HRESP;
  logic                             HREADY;
  logic [`AHB_MASTER_BITS-1:0]      HMASTER;
  logic                             HMASTLOCK;
  // The remaining connetions between slaves and AHB BUS.
  logic [`AHB_DATA_BITS-1:0]        HRDATA_S1;
  logic [`AHB_DATA_BITS-1:0]        HRDATA_S2;
  logic [`AHB_RESP_BITS-1:0]        HRESP_S1;
  logic [`AHB_RESP_BITS-1:0]        HRESP_S2;
  logic                             HREADY_S1;
  logic                             HREADY_S2;
  logic                             HSEL_S1;
  logic                             HSEL_S2;


  CPU CPU0(
         .clk(clk),
         .rst(rst),

         // from AHB
         .HGRANT_M1(HGRANT_M1),
         .HGRANT_M2(HGRANT_M2),
         .HRDATA(HRDATA),
         .HREADY(HREADY),
         .HRESP(HRESP),

         // to AHB
         .HADDR_M1(HADDR_M1),
         .HADDR_M2(HADDR_M2),
         .HBUSREQ_M1(HBUSREQ_M1),
         .HBUSREQ_M2(HBUSREQ_M2),
         .HSIZE_M1(HSIZE_M1),
         .HSIZE_M2(HSIZE_M2),
         .HTRANS_M1(HTRANS_M1),
         .HTRANS_M2(HTRANS_M2),
         .HLOCK_M1(HLOCK_M1),
         .HLOCK_M2(HLOCK_M2),
         .HWDATA_M1(HWDATA_M1),
         .HWDATA_M2(HWDATA_M2),
         .HWRITE_M1(HWRITE_M1),
         .HWRITE_M2(HWRITE_M2)
         );

  AHB AHB0(
         .HCLK(clk),
         .HRESETn(!rst),

         // M1 and M2 upstream inputs.
         .HADDR_M1(HADDR_M1),
         .HADDR_M2(HADDR_M2),
         .HBUSREQ_M1(HBUSREQ_M1),
         .HBUSREQ_M2(HBUSREQ_M2),
         .HSIZE_M1(HSIZE_M1),
         .HSIZE_M2(HSIZE_M2),
         .HTRANS_M1(HTRANS_M1),
         .HTRANS_M2(HTRANS_M2),
         .HLOCK_M1(HLOCK_M1),
         .HLOCK_M2(HLOCK_M2),
         .HWDATA_M1(HWDATA_M1),
         .HWDATA_M2(HWDATA_M2),
         .HWRITE_M1(HWRITE_M1),
         .HWRITE_M2(HWRITE_M2),
         // M1 and M2 upstream outputs.
         .HRDATA(HRDATA),
         .HREADY(HREADY),
         .HRESP(HRESP),
         .HGRANT_M1(HGRANT_M1),
         .HGRANT_M2(HGRANT_M2),

         // S1 and S2 downstream inputs.
         .HRDATA_S1(HRDATA_S1),
         .HRDATA_S2(HRDATA_S2),
         .HREADY_S1(HREADY_S1),
         .HREADY_S2(HREADY_S2),
         .HRESP_S1(HRESP_S1),
         .HRESP_S2(HRESP_S2),
         // S1 and S2 downstream outputs.
         .HADDR(HADDR),
         .HSIZE(HSIZE),
         .HTRANS(HTRANS),
         .HWDATA(HWDATA),
         .HWRITE(HWRITE),
         .HMASTER(HMASTER),
         .HMASTLOCK(HMASTLOCK),
         .HSEL_S1(HSEL_S1),
         .HSEL_S2(HSEL_S2)
         );

  S1_wra S_wrapper1(
         .clk(clk),
         .rst(rst),

         // Inputs from AHB BUS.
         .HADDR(HADDR),
         .HSIZE(HSIZE),
         .HTRANS(HTRANS),
         .HWDATA(HWDATA),
         .HWRITE(HWRITE),
         .HMASTER(HMASTER),
         .HMASTLOCK(HMASTLOCK),
         .HSEL_S1(HSEL_S1),
         // Input from IM.
         .IM_out(IM_out),

         // Outputs to AHB BUS.
         .HRDATA_S1(HRDATA_S1),
         .HREADY_S1(HREADY_S1),
         .HRESP_S1(HRESP_S1),
         // Outputs to IM.
         .IM_enable(IM_enable),
         .IM_address(IM_address)
         );

  S2_wra S_wrapper2(
         .clk(clk),
         .rst(rst),

         // Inputs from AHB BUS.
         .HADDR(HADDR),
         .HSIZE(HSIZE),
         .HTRANS(HTRANS),
         .HWDATA(HWDATA),
         .HWRITE(HWRITE),
         .HMASTER(HMASTER),
         .HMASTLOCK(HMASTLOCK),
         .HSEL_S2(HSEL_S2),
         // Input from DM.
         .DM_out(DM_out),

         // Outputs to AHB BUS.
         .HRDATA_S2(HRDATA_S2),
         .HREADY_S2(HREADY_S2),
         .HRESP_S2(HRESP_S2),
         // Outputs to DM.
         .DM_enable(DM_enable),
         .DM_address(DM_address),
         .DM_in(DM_in),
         .DM_write(DM_write)
         );

endmodule

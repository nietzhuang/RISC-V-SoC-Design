`include "AHB_def.svh"
`include "define.sv"
`include "AHB.sv"
`include "S1_wra.sv"
`include "S2_wra.sv"
`include "S3_wra.sv"
`include "S4_wra.sv"
`include "S5_wra.sv"
`include "sensor_ctrl.sv"


module top(
  input                             clk,
  input                             rst,
  input         [`data_size-1:0]    IM_out,
  input         [`data_size-1:0]    DM_out,
  input         [`data_size-1:0]    ROM_out,
  input                             sensor_ready,
  input         [`data_size-1:0]    sensor_out,
  input         [`data_size-1:0]    DRAM_Q,

  output logic                      IM_enable,
  output logic  [`addr_size-1:0]    IM_address,
  output logic  [`data_size-1:0]    IM_in,
  output logic                      IM_write,
  output logic                      DM_write,
  output logic                      DM_enable,
  output logic  [`data_size-1:0]    DM_in,
  output logic  [`addr_size-1:0]    DM_address,
  output logic  [`data_size-1:0]    ROM_enable,
  output logic  [`addr_size-1:0]    ROM_address,
  output logic                      ROM_read,
  output logic                      sensor_en,
  output logic                      DRAM_CSn,
  output logic                      DRAM_WEn,
  output logic                      DRAM_RASn,
  output logic                      DRAM_CASn,
  output logic  [10:0]              DRAM_A,
  output logic  [`data_size-1:0]    DRAM_D,
  //haven't designed yet
  output logic  [63:0]              L1I_access,
  output logic  [63:0]              L1I_miss,
  output logic  [63:0]              L1D_access,
  output logic  [63:0]              L1D_miss
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
  logic [`AHB_DATA_BITS-1:0]        HRDATA_S3;
  logic [`AHB_DATA_BITS-1:0]        HRDATA_S4;
  logic [`AHB_DATA_BITS-1:0]        HRDATA_S5;
  logic [`AHB_RESP_BITS-1:0]        HRESP_S1;
  logic [`AHB_RESP_BITS-1:0]        HRESP_S2;
  logic [`AHB_RESP_BITS-1:0]        HRESP_S3;
  logic [`AHB_RESP_BITS-1:0]        HRESP_S4;
  logic [`AHB_RESP_BITS-1:0]        HRESP_S5;
  logic                             HREADY_S1;
  logic                             HREADY_S2;
  logic                             HREADY_S3;
  logic                             HREADY_S4;
  logic                             HREADY_S5;
  logic                             HSEL_S1;
  logic                             HSEL_S2;
  logic                             HSEL_S3;
  logic                             HSEL_S4;
  logic                             HSEL_S5;


  CPU CPU0(
         .clk(clk),
         .rst(rst),
         // Inputs from AHB BUS.
         .HGRANT_M1(HGRANT_M1),
         .HGRANT_M2(HGRANT_M2),
         .HRDATA(HRDATA),
         .HREADY(HREADY),
         .HRESP(HRESP),
         .interrupt(sctrl_interrupt),

         // Outputs to AHB BUS.
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
         .L1I_access(L1I_access),
         .L1I_miss(L1I_miss),
         .L1D_access(L1D_access),
         .L1D_miss(L1D_miss)
         );

  AHB AHB(
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

  S1_wra IM_wrapper(
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
         .IM_address(IM_address),
         .IM_in(IM_in),
         .IM_write(IM_write)
         );

  S2_wra DM_wrapper(
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

  S3_wra ROM_wrapper(
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
        .HSEL_S3(HSEL_S3),
        // Input from ROM.
        .ROM_out(ROM_out),

        // Outputs to AHB BUS.
        .HRDATA_S3(HRDATA_S3),
        .HREADY_S3(HREADY_S3),
        .HRESP_S3(HRESP_S3),
        // Outputs to to ROM.
        .ROM_OE(ROM_OE),
        .ROM_enable(ROM_enable),
        .ROM_address(ROM_address)
        );

  S4_wra Sensor_wrapper(
        .clk(clk),
        .rst(rst),
        // Inputs from AHB BUS.
        .HTRANS(HTRANS),
        .HADDR(HADDR),
        .HWRITE(HWRITE),
        .HSIZE(HSIZE),
        .HWDATA(HWDATA),
        .HMASTER(HMASTER),
        .HMASTLOCK(HMASTLOCK),
        .HSEL_S4(HSEL_S4),
        // Inputs from Sensor Controller.
        .sctrl_out(sctrl_out),

        // Outputs to AHB BUS.
        .HRDATA_S4(HRDATA_S4),
        .HREADY_S4(HREADY_S4),
        .HRESP_S4(HRESP_S4),
        // Outputs to Sensor Controller.
        .sctrl_en(sctrl_en),
        .sctrl_clear(sctrl_clear),
        .sctrl_addr(sctrl_addr)
      );

  S5_wra DRAM_wrapper(
        .clk(clk),
        .rst(rst),
        // Inputs from AHB BUS.
        .HTRANS(HTRANS),
        .HADDR(HADDR),
        .HWRITE(HWRITE),
        .HSIZE(HSIZE),
        .HWDATA(HWDATA),
        .HMASTER(HMASTER),
        .HMASTLOCK(HMASTLOCK),
        .HSEL_S5(HSEL_S5),
        // Input from DRAM.
        .DRAM_out(DRAM_Q),

        // Outputs to AHB BUS.
        .HRDATA_S5(HRDATA_S5),
        .HREADY_S5(HREADY_S5),
        .HRESP_S5(HRESP_S5),
        // Outputs to DRAM.
        .DRAM_CSn(DRAM_CSn),
        .DRAM_WEn(DRAM_WEn),
        .DRAM_RASn(DRAM_RASn),
        .DRAM_CASn(DRAM_CASn),
        .DRAM_A(DRAM_A),
        .DRAM_D(DRAM_D)
        );

  sensor_ctrl sensor_ctrl(
        .clk(clk),
        .rst(rst),
        // Inputs from CPU via Sensor_wrapper.
        .sctrl_en(sctrl_en),
        .sctrl_clear(sctrl_clear),
        .sctrl_addr(sctrl_addr),
        // Inputs from Sensor.
        .sensor_ready(sensor_ready),
        .sensor_out(sensor_out),

        // Outputs to CPU via Sensor wrapper.
        .sctrl_interrupt(sctrl_interrupt),  // wire to CPU directly.
        .sctrl_out(sctrl_out),
        // Output to Sensor.
        .sensor_en(sensor_en)
        );

endmodule

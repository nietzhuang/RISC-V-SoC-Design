`include "define.sv"
`include "D_comparator.sv"
`include "D_ctr.sv"
`include "mux_Din.sv"
`include "D_performance.sv"

module Dcache(
  input                                 clk,
  input                                 rst,
  input         [`data_size-1:0]        address,  // wire to D_address
  input                                 Dcache_en,
  input                                 Dcache_write,
  input         [`data_size-1:0]        Dcache_in,
  input                                 ready,
  input         [`data_size-1:0]        DataIn,
  input         [2:0]                   funct3_MEM,

  output logic  [`data_size-1:0]        DataOut,
  output logic  [`data_size-1:0]        DM_address,
  output logic                          DM_enable,
  output logic                          DM_write,
  output logic                          Dstall,
  output logic                          stall_Dcount,
  output logic  [63:0]                  L1D_access,
  output logic  [63:0]                  L1D_miss
);

  logic     [`data_size-1:0]            DO[3:0];
  logic     [`data_size-1:0]            Dcache_in_DI;
  logic                                 CS_tag;
  logic                                 OE_tag;
  logic                                 v_bit;
  logic                                 WEB_tag;
  logic                                 OE_data;
  logic                                 hit;
  logic                                 D_sel;
  logic     [`tag-1:0]                  tag;
  logic     [3:0]                       WEB_data;
  logic     [3:0]                       CS_data;


  valid_array v_array(
        .CK(clk),
        .rst(rst),
        .A(address[9:4]),
        .CS(CS_tag),
        .OE(OE_tag),

        .v_bit(v_bit)
        );

  tag_array t_array(
        .CK(clk),
        .A(address[9:4]),
        .DO(tag),
        .DI(address[31:10]),
        .WEB(WEB_tag),
        .OE(OE_tag),
        .CS(CS_tag)
        );

  data_array d_array0(
        .CK(clk),
        .A(address[9:4]),
        .DO(DO[0]),
        .DI(Dcache_in_DI), //Dcache_in or DM_out
        .WEB(WEB_data),
        .OE(OE_data),
        .CS(CS_data[0])
        );

  data_array d_array1(
        .CK(clk),
        .A(address[9:4]),
        .DO(DO[1]),
        .DI(Dcache_in_DI), //Dcache_in or DM_out
        .WEB(WEB_data),
        .OE(OE_data),
		.CS(CS_data[1])
        );

  data_array d_array2(
        .CK(clk),
        .A(address[9:4]),
        .DO(DO[2]),
        .DI(Dcache_in_DI), //Dcache_in or DM_out
        .WEB(WEB_data),
        .OE(OE_data),
        .CS(CS_data[2])
        );

  data_array d_array3(
        .CK(clk),
        .A(address[9:4]),
        .DO(DO[3]),
        .DI(Dcache_in_DI), //Dcache_in or DM_out
        .WEB(WEB_data),
        .OE(OE_data),
        .CS(CS_data[3])
        );

  mux_DO mux_DO_D(
        .DO_0(DO[0]),
        .DO_1(DO[1]),
        .DO_2(DO[2]),
        .DO_3(DO[3]),
        .DO_sel(address[3:2]),

        .data(DataOut)
        );

  D_comparator D_comp(
        .tag(tag),
        .D_tag(address[31:10]),  // wire to D_address
        .v_bit(v_bit),

        .hit(hit)
        );

  D_performance D_perf(
        .clk(clk),
        .rst(rst),
        .Dcache_en(Dcache_en),
        .v_bit(v_bit),
        .hit(hit),

        .L1D_access(L1D_access),
        .L1D_miss(L1D_miss)
  );

  D_ctr D_ctr(
        .clk(clk),
        .rst(rst),
        .address(address),
        .Dcache_en(Dcache_en),
        .Dcache_write(Dcache_write),
        .ready(ready),
        .hit(hit),
        .funct3_MEM(funct3_MEM),

        .CS_tag(CS_tag),
        .OE_tag(OE_tag),
        .WEB_tag(WEB_tag),
        .CS_data(CS_data),
        .OE_data(OE_data),
        .WEB_data(WEB_data),
        .Dstall(Dstall),
        .stall_Dcount(stall_Dcount),
        .DM_address(DM_address),
        .DM_enable(DM_enable),
        .DM_write(DM_write),
        .D_sel(D_sel)
        );

  mux_Din mux_Din(
        .Dcache_in(Dcache_in),
        .DM_out(DataIn),
        .D_sel(D_sel),

        .Dcache_in_DI(Dcache_in_DI)
        );

endmodule

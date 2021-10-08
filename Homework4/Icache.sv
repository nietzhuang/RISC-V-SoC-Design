`include "define.sv"
`include "I_comparator.sv"
`include "I_ctr.sv"

module Icache(
  input                                 clk,
  input                                 rst,
  input         [`data_size-1:0]        address,
  input                                 Icache_en,
  input                                 ready,
  input                                 stall_Dcount,
  input         [`data_size-1:0]        IM_out,

  output logic  [`data_size-1:0]        data,
  output logic                          IM_enable,
  output logic  [`data_size-1:0]        IM_address,
  output logic                          Istall,
  output logic                          hit,
  output logic                          address_rst
);

  logic     [`data_size-1:0]            DO[3:0];
  logic                                 CS_tag;
  logic                                 OE_tag;
  logic                                 v_bit;
  logic                                 WEB_tag;
  logic                                 OE_data;
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
        .DI(IM_out),
        .WEB(WEB_data),
        .OE(OE_data),
        .CS(CS_data[0])
        );

  data_array d_array1(
        .CK(clk),
        .A(address[9:4]),
        .DO(DO[1]),
        .DI(IM_out),
        .WEB(WEB_data),
        .OE(OE_data),
        .CS(CS_data[1])
        );

  data_array d_array2(
        .CK(clk),
        .A(address[9:4]),
        .DO(DO[2]),
        .DI(IM_out),
        .WEB(WEB_data),
        .OE(OE_data),
        .CS(CS_data[2])
        );

  data_array d_array3(
        .CK(clk),
        .A(address[9:4]),
        .DO(DO[3]),
        .DI(IM_out),
        .WEB(WEB_data),
        .OE(OE_data),
        .CS(CS_data[3])
        );

  mux_DO mux_DO_I(
        .DO_0(DO[0]),
        .DO_1(DO[1]),
        .DO_2(DO[2]),
        .DO_3(DO[3]),
        .DO_sel(address[3:2]),

        .data(data)
        );

  I_comparator I_comp(
        .tag(tag),
        .I_tag(address[31:10]), // wire to PC_address
        .v_bit(v_bit),

        .hit(hit)
        );

  I_ctr I_ctr(
        .clk(clk),
        .rst(rst),
        .address(address),
        .Icache_en(Icache_en),
        .ready(ready),
        .hit(hit),
        .stall_Dcount(stall_Dcount),

        .CS_tag(CS_tag),
        .OE_tag(OE_tag),
        .WEB_tag(WEB_tag),
        .CS_data(CS_data),
        .OE_data(OE_data),
        .WEB_data(WEB_data),
        .Istall(Istall),
        .IM_enable(IM_enable),
        .IM_address(IM_address),
        .address_rst(address_rst)
        );

endmodule

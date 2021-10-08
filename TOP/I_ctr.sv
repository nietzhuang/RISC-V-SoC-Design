`include "define.sv"

module I_ctr(
  input                                 clk,
  input                                 rst,
  input         [`data_size-1:0]        address,
  input                                 Icache_en,
  input                                 ready,
  input                                 hit,
  input                                 stall_Dcount,

  output logic                          CS_tag,
  output logic                          OE_tag,
  output logic                          WEB_tag,
  output logic  [3:0]                   CS_data,
  output logic                          OE_data,
  output logic  [`offset-1:0]           WEB_data,
  output logic                          Istall,
  output logic                          IM_enable,
  output logic  [`data_size-1:0]        IM_address,
  output logic                          address_rst
);

  parameter                             IDLE = 3'b000, FETCH = 3'b001, WAIT = 3'b010, COUNT = 3'b011, READ = 3'b100;
  logic     [2:0]                       cstate, nstate;
  logic     [1:0]                       counter;


  always_ff@(posedge clk, posedge rst)begin
    if(rst)
      cstate <= IDLE;
    else
      cstate <= nstate;
  end

  always_comb begin
    unique case(cstate)
    IDLE:begin
      if(Icache_en)  // read
        nstate = FETCH;
      else
        nstate = IDLE;
    end
    FETCH:
      nstate = WAIT;
    WAIT:begin
      if(hit)
        nstate = READ;
      else
        nstate = COUNT;
    end
    COUNT:begin
      if((counter == 2'b11) && ready)
        nstate = READ;
      else
        nstate = COUNT;
    end
    READ:
      nstate = IDLE;
    endcase
  end

  always_comb begin
    unique case(cstate)
    IDLE: begin
      CS_tag            = 1'b0;
      OE_tag            = 1'b0;
      WEB_tag           = 1'b0;
      OE_data           = 1'b1;
      WEB_data          = 4'b1111;
      Istall            = (Icache_en)? 1'b1 : 1'b0;
      IM_enable         = 1'b0;
      IM_address        = address;
      case(address[3:2])
      2'b00: CS_data    = 4'b0001;
      2'b01: CS_data    = 4'b0010;
      2'b10: CS_data    = 4'b0100;
      2'b11: CS_data    = 4'b1000;
      default: CS_data  = 4'b0000;
      endcase
    end
    FETCH:begin
      CS_tag            = 1'b1;
      OE_tag            = 1'b1;
      WEB_tag           = 1'b1;
      CS_data           = 4'b0;
      OE_data           = 1'b0;
      WEB_data          = 4'b0;
      Istall            = 1'b1;
      IM_enable         = 1'b0;
      IM_address        = address;
    end
    WAIT:begin
      CS_tag            = 1'b1;
      OE_tag            = 1'b1;
      WEB_tag           = 1'b1;
      CS_data           = 4'b0;
      OE_data           = 1'b0;
      WEB_data          = 4'b0;
      Istall            = 1'b1;
      IM_enable         = 1'b0;
      IM_address        = address;
    end
    COUNT:begin
      CS_tag            = 1'b0;
      OE_tag            = 1'b0;
      WEB_tag           = 1'b0;
      CS_data           = 4'b0001 << counter;
      OE_data           = 1'b0;
      WEB_data          = 4'b0000;
      Istall            = 1'b1;
      IM_enable         = 1'b1;
      IM_address        = {address[31:4], counter, 2'b00};
    end
    READ:begin
      CS_tag            = 1'b1;
      OE_tag            = 1'b0;
      WEB_tag           = 1'b0;
      OE_data           = 1'b1 ;
      WEB_data          = 4'b1111;
      Istall            = 1'b1;
      IM_enable         = 1'b0;
      IM_address        = address;
      case(address[3:2])
      2'b00: CS_data    = 4'b0001;
      2'b01: CS_data    = 4'b0010;
      2'b10: CS_data    = 4'b0100;
      2'b11: CS_data    = 4'b1000;
      default: CS_data  = 4'b0000;
      endcase
    end
    endcase
  end

  always_ff@(posedge clk, posedge rst)begin
    if(rst)
      counter <= 2'b0;
    else if((cstate == IDLE)||((counter == 2'b11) && ready))
      counter <= 2'b0;
    else if((cstate == COUNT)&& ready && (!stall_Dcount))
      counter <= counter + 1;
  end

  always_ff@(posedge clk, posedge rst)begin
    if(rst)
      address_rst <=1'b1;
    else
      address_rst <= 1'b0;
  end

endmodule

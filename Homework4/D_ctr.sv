`include "define.sv"

module D_ctr(
  input                                 clk,
  input                                 rst,
  input         [`data_size-1:0]        address,
  input                                 Dcache_en,
  input                                 Dcache_write, // DM_write originally
  input                                 ready,
  input                                 hit,
  input         [2:0]                   funct3_EXE_MEM,

  output logic                          CS_tag,
  output logic                          OE_tag,
  output logic                          WEB_tag,
  output logic  [3:0]                   CS_data,
  output logic                          OE_data,
  output logic  [`offset-1:0]           WEB_data,
  output logic                          Dstall,
  output logic                          stall_Dcount,
  output logic  [`data_size-1:0]        DM_address,
  output logic                          DM_enable,
  output logic                          DM_write,
  output logic                          D_sel
);

  parameter                             IDLE = 3'b000, FETCH = 3'b001, WAIT = 3'b010, COUNT = 3'b011, READ = 3'b100, WRITE = 3'b101, WRITE_DM = 3'b110;
  logic     [2:0]                       cstate, nstate;
  logic     [1:0]                       counter;


  always_ff@(posedge clk, posedge rst)begin
    if(rst)
      counter <= 2'b0;
    else if(cstate == IDLE)
      counter <= 2'b0;
    else if( (cstate == COUNT) && ready )
      counter <= counter + 1;
  end

  always_ff@(posedge clk, posedge rst)begin
    if(rst)
      cstate <= IDLE;
    else
      cstate <= nstate;
  end

  always_comb begin
    case(cstate)
    IDLE:begin
      if(Dcache_en)
        nstate = FETCH;
      else
        nstate = IDLE;
    end
    FETCH:
      nstate = WAIT;
    WAIT:begin
      if(hit && (!Dcache_write))
        nstate = READ;
      else if(hit && Dcache_write)
        nstate = WRITE;
      else  // MISS
        nstate = COUNT;
    end
    COUNT:begin
      if((counter == 2'b11) && ready && Dcache_write)
        nstate = WRITE;
      else if((counter == 2'b11) && ready && (!(Dcache_write)))
        nstate = READ;
      else
        nstate = COUNT;
    end
    READ:begin
      if(Dcache_write)
        nstate = WRITE_DM;
      else
        nstate = IDLE;
    end
    WRITE:
      nstate = READ;  // Read Dcache data to write DM.
    WRITE_DM:
      if(ready)
        nstate = IDLE;
      else
        nstate = WRITE_DM;
    default: nstate = IDLE;
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
      Dstall            = 1'b0;
      stall_Dcount      = 1'b0;
      DM_address        = address;
      DM_enable         = 1'b0;
      DM_write          = 1'b0;
      D_sel             = 1'b0;
      unique case(address[3:2])
        2'b00: CS_data  = 4'b0001;
        2'b01: CS_data  = 4'b0010;
        2'b10: CS_data  = 4'b0100;
        2'b11: CS_data  = 4'b1000;
      endcase
    end
    FETCH:begin
      CS_tag            = 1'b1;
      OE_tag            = 1'b1;
      WEB_tag           = 1'b1;
      CS_data           = 1'b0;
      OE_data           = 1'b0;
      WEB_data          = 4'b0;
      Dstall            = 1'b1;
      stall_Dcount      = 1'b0;
      DM_address        = address;
      DM_enable         = 1'b0;
      DM_write          = 1'b0;
      D_sel             = 1'b0;
    end
    WAIT:begin
      CS_tag            = 1'b1;
      OE_tag            = 1'b1;
      WEB_tag           = 1'b1;
      CS_data           = 1'b0;
      OE_data           = 1'b0;
      WEB_data          = 4'b0;
      Dstall            = 1'b1;
      stall_Dcount      = 1'b0;
      DM_address        = address;
      DM_enable         = 1'b0;
      DM_write          = 1'b0;
      D_sel             = 1'b0;
    end
    COUNT:begin
      CS_tag            = 1'b0;
      OE_tag            = 1'b0;
      WEB_tag           = 1'b0;
      CS_data           = 4'b0001 << counter;
      OE_data           = 1'b0;
      WEB_data          = 4'b0000;
      Dstall            = 1'b1;
      stall_Dcount      = 1'b1;
      DM_address        = {address[31:4], counter, 2'b00};
      DM_enable         = 1'b1;
      DM_write          = 1'b0;
      D_sel             = 1'b1;  // select DataIn
    end
    READ:begin
      CS_tag            = 1'b1;  // write valid array
      OE_tag            = 1'b0;
      WEB_tag           = 1'b0;
      OE_data           = 1'b1;
      WEB_data          = 4'b1111;
      Dstall            = 1'b1;
      stall_Dcount      = 1'b0;
      DM_address        = address;
      DM_enable         = (Dcache_write)? 1'b1 : 1'b0;
      DM_write          = (Dcache_write)? 1'b1 : 1'b0;
      D_sel             = 1'b0;
      unique case(address[3:2])
        2'b00: CS_data  = 4'b0001;
        2'b01: CS_data  = 4'b0010;
        2'b10: CS_data  = 4'b0100;
        2'b11: CS_data  = 4'b1000;
      endcase
    end
    WRITE:begin
      CS_tag            = 1'b1;
      OE_tag            = 1'b0;
      WEB_tag           = 1'b0;
      OE_data           = 1'b0;
      Dstall            = 1'b1;
      stall_Dcount      = 1'b1;
      DM_address        = address;
      DM_enable         = 1'b0;
      DM_write          = 1'b0;
      D_sel             = 1'b0;  // select Dcache_in
      unique case(address[3:2])
        2'b00: CS_data  = 4'b0001;
        2'b01: CS_data  = 4'b0010;
        2'b10: CS_data  = 4'b0100;
        2'b11: CS_data  = 4'b1000;
      endcase
      if(funct3_EXE_MEM == 3'b000)begin  // SB
        unique case(address[1:0])
          2'b00: WEB_data = 4'b1110;
          2'b01: WEB_data = 4'b1101;
          2'b10: WEB_data = 4'b1011;
          2'b11: WEB_data = 4'b0111;
        endcase
      end
      else if(funct3_EXE_MEM == 3'b001)begin  // SH
        WEB_data        = 4'b1100;
      end
      else
        WEB_data        = 4'b0000;
    end
    WRITE_DM:begin
      CS_tag            = 1'b0;
      OE_tag            = 1'b0;
      WEB_tag           = 1'b0;
      OE_data           = 1'b1;
      WEB_data          = 4'b1111;  // read to DM
      Dstall            = 1'b1;
      stall_Dcount      = 1'b1;
      DM_address        = address;
      DM_enable         = 1'b1;
      DM_write          = 1'b1;
      D_sel             = 1'b0;  // select Dcache_in
      unique case(address[3:2])
        2'b00: CS_data  = 4'b0001;
        2'b01: CS_data  = 4'b0010;
        2'b10: CS_data  = 4'b0100;
        2'b11: CS_data  = 4'b1000;
      endcase
    end
    endcase
  end

endmodule

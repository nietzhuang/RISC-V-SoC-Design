`include "define.sv"
`include "AHB_def.svh"

module M_wra(
  input                                     clk,
  input                                     rst,
  // Inputs from Masters.
  input                                     IM_enable,
  input     [`data_size-1:0]                IM_address,
  input                                     DM_enable,
  input     [`data_size-1:0]                DM_address,
  input     [`data_size-1:0]                DM_in,
  input                                     DM_write,
  // Inputs from AHB BUS.
  input                                     HGRANT_M1,
  input                                     HGRANT_M2,
  input     [`AHB_DATA_BITS-1:0]            HRDATA,
  input                                     HREADY,
  input     [`AHB_RESP_BITS-1:0]            HRESP,

  // Outputs to Masters.
  output logic  [`data_size-1:0]            IM_out,
  output logic  [`data_size-1:0]            DM_out,
  output logic                              ready,
  // Outputs to AHB BUS.
  output logic  [`AHB_DATA_BITS-1:0]        HADDR_M1,
  output logic  [`AHB_DATA_BITS-1:0]        HADDR_M2,
  output logic                              HBUSREQ_M1,
  output logic                              HBUSREQ_M2,
  output logic  [`AHB_SIZE_BITS-1:0]        HSIZE_M1,
  output logic  [`AHB_SIZE_BITS-1:0]        HSIZE_M2,
  output logic  [`AHB_TRANS_BITS-1:0]       HTRANS_M1,
  output logic  [`AHB_TRANS_BITS-1:0]       HTRANS_M2,
  output logic                              HLOCK_M1,
  output logic                              HLOCK_M2,
  output logic  [`AHB_DATA_BITS-1:0]        HWDATA_M1,
  output logic  [`AHB_DATA_BITS-1:0]        HWDATA_M2,
  output logic                              HWRITE_M1,
  output logic                              HWRITE_M2
);

  parameter IDLE = 3'b000, WAIT = 3'b001, ADDR = 3'b010, WRITE = 3'b011, READ = 3'b100;
  logic [2:0] cstate, nstate;

  always_ff@(posedge clk)begin
    if(rst)
      cstate <= IDLE;
    else
      cstate <= nstate;
  end

  always_comb begin
    case(cstate)
    IDLE:begin
      if(IM_enable||DM_enable)
        nstate = WAIT;
      else
        nstate = IDLE;
    end
    WAIT:begin
      if((HGRANT_M1||HGRANT_M2))
        nstate = ADDR;
      else
        nstate = WAIT;
    end
    ADDR:begin
      if(DM_write)
        nstate = WRITE;
      else if(!DM_write)
        nstate = READ;
      else
        nstate = ADDR;
    end
    WRITE:begin
      if(HREADY && (!HRESP))
        nstate = IDLE;
      else
        nstate = WRITE;
    end
    READ:begin
      if(HREADY && (!HRESP))
        nstate = IDLE;
      else
        nstate = READ;
    end
    default:
      nstate = IDLE;
    endcase
  end

  always_comb begin
    case(cstate)
    IDLE:begin
      IM_out        = HRDATA;
      DM_out        = HRDATA;
      ready         = 1'b0;
      HADDR_M1      = 32'd0;
      HADDR_M2      = IM_address;
      HBUSREQ_M1    = 1'b0;
      HBUSREQ_M2    = 1'b0;
      HSIZE_M1      = 3'd0;
      HSIZE_M2      = 3'd0;
      HTRANS_M1     = 2'd0;
      HTRANS_M2     = 2'd0;
      HLOCK_M1      = 1'b0;
      HLOCK_M2      = 1'b0;
      HWDATA_M1     = 32'd0;
      HWDATA_M2     = 32'd0;
      HWRITE_M1     = 1'd0;
      HWRITE_M2     = 1'd0;
    end
    WAIT:begin
      IM_out        = 32'd0;
      DM_out        = 32'd0;
      ready         = 1'b0;
      HADDR_M1      = 32'd0;
      HADDR_M2      = IM_address;
      HBUSREQ_M1    = DM_enable;
      HBUSREQ_M2    = IM_enable;
      HSIZE_M1      = 3'b0;
      HSIZE_M2      = 3'b0;
      HTRANS_M1     = 2'b0;
      HTRANS_M2     = 2'b0;
      HLOCK_M1      = 1'b0;
      HLOCK_M2      = 1'b0;
      HWDATA_M1     = 32'd0;
      HWDATA_M2     = 32'd0;
      HWRITE_M1     = 1'b0;
      HWRITE_M2     = 1'b0;
    end
    ADDR:begin
      IM_out        = 32'd0;
      DM_out        = 32'd0;
      ready         = 1'b0;
      HADDR_M1      = DM_address;
      HADDR_M2      = IM_address;
      HBUSREQ_M1    = 1'b0;
      HBUSREQ_M2    = 1'b0;
      HSIZE_M1      = 3'b010;
      HSIZE_M2      = 3'b010;
      HTRANS_M1     = 2'b10;
      HTRANS_M2     = 2'b10;
      HLOCK_M1      = 1'b0;
      HLOCK_M2      = 1'b0;
      HWDATA_M1     = 32'd0;
      HWDATA_M2     = 32'd0;
      HWRITE_M1     = 1'b0;
      HWRITE_M2     = 1'b0;
    end
    WRITE:begin  // IM always read
      IM_out        = 32'd0;
      DM_out        = 32'd0;
      ready         = HREADY;
      HADDR_M1      = DM_address;
      HADDR_M2      = 32'b0;
      HBUSREQ_M1    = 1'b0;
      HBUSREQ_M2    = 1'b0;
      HSIZE_M1      = 3'b010;
      HSIZE_M2      = 3'b010;
      HTRANS_M1     = 2'b10;
      HTRANS_M2     = 2'b10;
      HLOCK_M1      = 1'b0;
      HLOCK_M2      = 1'b0;
      HWDATA_M1     = DM_in;  // write DM
      HWDATA_M2     = 32'd0;  // IM is never written data
      HWRITE_M1     = 1'b1;
      HWRITE_M2     = 1'b0;
    end
    READ:begin
      IM_out        = HRDATA;
      DM_out        = HRDATA;
      ready         = HREADY;
      HADDR_M1      = DM_address;
      HADDR_M2      = IM_address;
      HBUSREQ_M1    = 1'b0;
      HBUSREQ_M2    = 1'b0;
      HSIZE_M1      = 3'b010;
      HSIZE_M2      = 3'b010;
      HTRANS_M1     = 2'b10;
      HTRANS_M2     = 2'b10;
      HLOCK_M1      = 1'b0;
      HLOCK_M2      = 1'b0;
      HWDATA_M1     = 1'b0;
      HWDATA_M2     = 1'b0;
      HWRITE_M1     = 1'b0;
      HWRITE_M2     = 1'b0;
    end
    default:begin
      IM_out        = 32'b0;
      DM_out        = 32'b0;
      ready         = 1'b0;
      HADDR_M1      = 32'b0;
      HADDR_M2      = 32'b0;
      HBUSREQ_M1    = 1'b0;
      HBUSREQ_M2    = 1'b0;
      HSIZE_M1      = 3'b0;
      HSIZE_M2      = 3'b0;
      HTRANS_M1     = 2'b0;
      HTRANS_M2     = 2'b0;
      HLOCK_M1      = 1'b0;
      HLOCK_M2      = 1'b0;
      HWDATA_M1     = 32'b0;
      HWDATA_M2     = 32'b0;
      HWRITE_M1     = 1'b0;
      HWRITE_M2     = 1'b0;
    end
    endcase
  end

endmodule

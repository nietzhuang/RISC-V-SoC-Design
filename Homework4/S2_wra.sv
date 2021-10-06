`include "define.sv"
`include "AHB_def.svh"

module S2_wra(
  input                                     clk,
  input                                     rst,

  // Inputs from AHB BUS.
  input         [`AHB_TRANS_BITS-1:0]       HTRANS,
  input         [`AHB_DATA_BITS-1:0]        HADDR,
  input                                     HWRITE,
  input         [`AHB_SIZE_BITS-1:0]        HSIZE,
  input         [`AHB_DATA_BITS-1:0]        HWDATA,
  input         [`AHB_MASTER_BITS-1:0]      HMASTER,
  input                                     HMASTLOCK,
  input                                     HSEL_S2,
  // Input from DM.
  input         [`data_size-1:0]            DM_out,

  // Outputs to AHB BUS.
  output logic  [`AHB_DATA_BITS-1:0]        HRDATA_S2,
  output logic                              HREADY_S2,
  output logic  [`AHB_RESP_BITS-1:0]        HRESP_S2,
  // Outputs to DM.
  output logic                              DM_enable,
  output logic  [`data_size-1:0]            DM_address,
  output logic  [`data_size-1:0]            DM_in,
  output logic                              DM_write
);

  logic [2:0] cstate, nstate;
  parameter IDLE = 3'b000, ADDR = 3'b001, WRITE = 3'b010, WAIT_READ = 3'b011, READ = 3'b100;

  always_ff@(posedge clk, negedge rst)begin
    if(rst)
      cstate <= IDLE;
    else
      cstate <= nstate;
  end

  always_comb begin
    case(cstate)
      IDLE:begin
        if(HSEL_S2&&(HMASTER == 4'b0001)) // select M2 and Master = M2
          nstate = ADDR;
        else
          nstate = IDLE;
      end
      ADDR:begin
        if(HWRITE)
          nstate = WRITE;
        else
          nstate = WAIT_READ;
      end
      WRITE:
        nstate = IDLE;
      WAIT_READ:
        nstate = READ;
      READ:
        nstate = IDLE;
      default:
        nstate = IDLE;
    endcase
  end

  always_comb begin
    case(cstate)
      IDLE:begin
        HRDATA_S2   = 32'b0;
        HREADY_S2   = 1'b1;
        HRESP_S2    = 1'b0;
        DM_write    = 1'b0;
        DM_enable   = 1'b0;
        DM_address  = HADDR;
        DM_in       = 32'b0;
      end
      ADDR:begin
        HRDATA_S2   = 32'b0;
        HREADY_S2   = 1'b0;
        HRESP_S2    = 1'b0;
        DM_write    = HWRITE;
        DM_enable   = 1'b1;
        DM_address  = HADDR;
        DM_in       = HWDATA;
      end
      WRITE:begin
        HRDATA_S2   = 32'b0;
        HREADY_S2   = 1'b1;
        HRESP_S2    = 1'b0;
        DM_write    = HWRITE;
        DM_enable   = 1'b1;
        DM_address  = HADDR;
        DM_in       = HWDATA;
      end
      WAIT_READ:begin
        HRDATA_S2   = 32'b0;  // wait for reading the DM_out.
        HREADY_S2   = 1'b0;
        HRESP_S2    = 1'b0;
        DM_write    = HWRITE;
        DM_enable   = 1'b1;
        DM_address  = HADDR;  // address to read DM_out
        DM_in       = 32'b0;
      end
      READ:begin
        HRDATA_S2   = DM_out;
        HREADY_S2   = 1'b1;
        HRESP_S2    = 1'b0;
        DM_write    = HWRITE;
        DM_enable   = 1'b1;
        DM_address  = HADDR;
        DM_in       = 1'b0;
      end
      default:begin
        HRDATA_S2   = 32'b0;
        HREADY_S2   = 1'b0;
        HRESP_S2    = 1'b0;
        DM_write    = 1'b0;
        DM_enable   = 1'b0;
        DM_address  = 32'b0;
        DM_in       = 32'b0;
      end
    endcase
  end

endmodule

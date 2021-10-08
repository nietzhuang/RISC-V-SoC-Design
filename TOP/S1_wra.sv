`include "define.sv"
`include "AHB_def.svh"

module S1_wra(
  input                                     clk,
  input                                     rst,

  // Inputs from AHB BUS.
  input         [`AHB_DATA_BITS-1:0]        HADDR,
  input         [`AHB_SIZE_BITS-1:0]        HSIZE,
  input         [`AHB_TRANS_BITS-1:0]       HTRANS,
  input         [`AHB_DATA_BITS-1:0]        HWDATA,
  input                                     HWRITE,
  input         [`AHB_MASTER_BITS-1:0]      HMASTER,
  input                                     HMASTLOCK,
  input                                     HSEL_S1,
  // Input from IM.
  input         [`data_size-1:0]            IM_out,

  // Outputs to AHB BUS.
  output logic  [`AHB_DATA_BITS-1:0]        HRDATA_S1,
  output logic                              HREADY_S1,
  output logic  [`AHB_RESP_BITS-1:0]        HRESP_S1,
  // Outputs to IM.
  output logic                              IM_enable,
  output logic  [`data_size-1:0]            IM_address
  //output logic [`data_size-1:0] IM_in,
  //output logic                              IM_write,
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
        if(HSEL_S1&&(HMASTER == 4'b0010)) // select M1 and Master = M1
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
        HRDATA_S1   = IM_out;
        HREADY_S1   = 1'b1;
        HRESP_S1    = 2'b0;
        IM_enable   = 1'b0;
        IM_address  = HADDR;
      end
      ADDR:begin
        HRDATA_S1   = 32'b0;
        HREADY_S1   = 1'b0;
        HRESP_S1    = 1'b0;
        IM_enable   = 1'b1;
        IM_address  = HADDR;
      end
      WRITE:begin  // IM would never be written.
        HRDATA_S1   = 32'b0;
        HREADY_S1   = 1'b1;
        HRESP_S1    = 1'b0;
        IM_enable   = 1'b1;
        IM_address  = HADDR;
      end
      WAIT_READ:begin // wait for reading the IM_out.
        HRDATA_S1   = IM_out;
        HREADY_S1   = 1'b0;
        HRESP_S1    = 1'b0;
        IM_enable   = 1'b1;
        IM_address  = HADDR; // address to read IM_out.
      end
      READ:begin
        HRDATA_S1   = IM_out;
        HREADY_S1   = 1'b1;
        HRESP_S1    = 1'b0;
        IM_enable   = 1'b1;
        IM_address  = HADDR;
      end
      default:begin
        HRDATA_S1   = 32'b0;
        HREADY_S1   = 1'b1;
        HRESP_S1    = 1'b0;
        IM_enable   = 1'b0;
        IM_address  = 32'b0;
      end
    endcase
  end

endmodule

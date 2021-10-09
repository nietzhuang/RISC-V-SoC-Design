// for ROM
`include "define.sv"
`include "AHB_def.svh"

module S3_wra(
  input                                 clk,
  input                                 rst,
  // Inputs from AHB BUS.
  input         [`AHB_DATA_BITS-1:0]    HADDR,
  input         [`AHB_SIZE_BITS-1:0]    HSIZE,
  input         [`AHB_TRANS_BITS-1:0]   HTRANS,
  input         [`AHB_DATA_BITS-1:0]    HWDATA,
  input                                 HWRITE,
  input         [`AHB_MASTER_BITS-1:0]  HMASTER,
  input                                 HMASTLOCK,
  input                                 HSEL_S3,
  // Input from ROM.
  input         [`data_size-1:0]        ROM_out,

  // Outputs to AHB BUS.
  output logic  [`AHB_DATA_BITS-1:0]    HRDATA_S3,
  output logic                          HREADY_S3,
  output logic  [`AHB_RESP_BITS-1:0]    HRESP_S3,
  // Outputs to to ROM.
  output logic                          ROM_OE, // read_enable
  output logic                          ROM_enable,
  output logic  [`data_size-1:0]        ROM_address
);

  parameter                             IDLE = 2'b00, ADDR = 2'b01, WAIT_READ = 2'b10, READ = 2'b11;

  logic     [1:0]                       cstate;
  logic     [1:0]                       nstate;


  always_ff@(posedge clk, posedge rst)begin
    if(rst)
      cstate <= IDLE;
    else
      cstate <= nstate;
  end

  always_comb begin
    case(cstate)
      IDLE:begin
        if(HSEL_S3&&(HMASTER == 4'b0010))  // Only Dcahce can select ROM.
          nstate = ADDR;
        else
          nstate = IDLE;
      end
      ADDR:
  	    nstate = WAIT_READ;  // ignore HWRITE signal
      WAIT_READ:begin
        if(ROM_out != 32'hz)  //!! add addtional delay if necessarily.
          nstate = READ;
        else
          nstate = WAIT_READ;
      end
      READ:
	    nstate = IDLE;
      default:
	    nstate = IDLE;
    endcase
  end

  always_comb begin
    case(cstate)
      IDLE:begin
        HRDATA_S3       = ROM_out;
        HREADY_S3       = 1'b1;
        HRESP_S3        = 2'b0;
        ROM_OE          = 1'b0;
        ROM_enable      = 1'b0;
        ROM_address     = HADDR;
      end
      ADDR:begin
        HRDATA_S3       = 32'd0;
        HREADY_S3       = 1'b0;
        HRESP_S3        = 2'b0;
        ROM_OE          = 1'b1;
        ROM_enable      = 1'b1;
        ROM_address     = HADDR;
      end
      WAIT_READ:begin
        HRDATA_S3       = 32'd0;
        HREADY_S3       = 1'b0;
        HRESP_S3        = 2'b0;
        ROM_OE          = 1'b1;
        ROM_enable      = 1'b1;
        ROM_address     = HADDR;
      end
      READ:begin
        HRDATA_S3       = ROM_out;
        HREADY_S3       = 1'b1;
        HRESP_S3        = 2'b0;
        ROM_OE          = 1'b1;
        ROM_enable      = 1'b1;
        ROM_address     = HADDR;
      end
      default:begin
        HRDATA_S3       = 32'd0;
        HREADY_S3       = 1'b0;
        HRESP_S3        = 2'b0;
        ROM_OE          = 1'b0;
        ROM_enable      = 1'b0;
        ROM_address     = 32'd0;
      end
    endcase
  end

endmodule

// Read_only DRAM
`include "define.sv"
`include "AHB_def.svh"

module S5_wra(
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
  input                                     HSEL_S5,
  // Input from DRAM.
  input         [`data_size-1:0]            DRAM_out,  // hardwired to Q in the testbench.

  // Outputs to AHB BUS.
  output logic  [`AHB_DATA_BITS-1:0]        HRDATA_S5,
  output logic                              HREADY_S5,
  output logic  [`AHB_RESP_BITS-1:0]        HRESP_S5,
  // Outputs to DRAM.
  output logic                              DRAM_CSn,
  output logic                              DRAM_WEn,
  output logic                              DRAM_RASn,  // Row Address Select
  output logic                              DRAM_CASn,  // Column Address Select
  output logic  [10:0]                      DRAM_A,
  output logic  [`data_size-1:0]            DRAM_D  // DataIn wire to D
);

  parameter                                 IDLE = 3'b000, RADDR1 = 3'b001, RADDR2 = 3'b010, CADDR1 = 3'b011, CADDR2 = 3'b011, WAIT_READ = 3'b100, READ = 3'b101;
  logic     [2:0]                           cstate;
  logic     [2:0]                           nstate;


  assign row_addr = HADDR[21:11];
  assign col_addr = HADDR[10:0];

  always_ff@(posedge clk, negedge rst)begin
    if(rst)
      cstate <= IDLE;
    else
      cstate <= nstate;
  end

  always_comb begin
    case(cstate)
      IDLE:begin
        if(HSEL_S5&&(HMASTER == 4'b0001))
          nstate <= RADDR1;
        else
          nstate <= IDLE;
      end
      RADDR1:
        nstate <= RADDR2;
      RADDR2:
        nstate <= CADDR1;
      CADDR1:
        nstate <= CADDR2;
      CADDR2:
        nstate <= WAIT_READ;
      WAIT_READ:begin
        if((DRAM_out != 32'hz) && (DRAM_out != 32'hx))  //!! add addtional delay if necessarily.
          nstate <= READ;
        else
          nstate <= WAIT_READ;
      end
      READ:
        nstate <= IDLE;
      default:
        nstate <= IDLE;
    endcase
  end

  always_comb begin
    case(cstate)
      IDLE:begin
        HRDATA_S5   = DRAM_out;
        HREADY_S5   = 1'b1;
        HRESP_S5    = 2'b0;
        DRAM_CSn    = 1'b1;  // disable
        DRAM_WEn    = 1'b1;
        DRAM_RASn   = 1'b1;
        DRAM_CASn   = 1'b1;
        DRAM_A      = col_addr;
        DRAM_D      = HWDATA;
      end
      RADDR1:begin
        HRDATA_S5   = 32'd0;
        HREADY_S5   = 1'b0;
        HRESP_S5    = 2'b0;
        DRAM_CSn    = 1'b0;
        DRAM_WEn    = 1'b1;
        DRAM_RASn   = 1'b1;
        DRAM_CASn   = 1'b1;
        DRAM_A      = row_addr;
        DRAM_D      = HWDATA;
      end
      RADDR2:begin
        HRDATA_S5   = 32'd0;
        HREADY_S5   = 1'b0;
        HRESP_S5    = 2'b0;
        DRAM_CSn    = 1'b0;
        DRAM_WEn    = 1'b1;
        DRAM_RASn   = 1'b0;  // enable row
        DRAM_CASn   = 1'b1;
        DRAM_A      = row_addr;
        DRAM_D      = HWDATA;
      end
      CADDR1:begin
        HRDATA_S5   = 32'd0;
        HREADY_S5   = 1'b0;
        HRESP_S5    = 2'b0;
        DRAM_CSn    = 1'b0;
        DRAM_WEn    = 1'b1;
        DRAM_RASn   = 1'b1;
        DRAM_CASn   = 1'b1;
        DRAM_A      = col_addr;
        DRAM_D      = HWDATA;
      end
      CADDR2:begin
        HRDATA_S5   = 32'd0;
        HREADY_S5   = 1'b0;
        HRESP_S5    = 2'b0;
        DRAM_CSn    = 1'b0;
        DRAM_WEn    = 1'b1;
        DRAM_RASn   = 1'b1;
        DRAM_CASn   = 1'b0;  // enable column
        DRAM_A      = col_addr;
        DRAM_D      = HWDATA;
      end
      WAIT_READ:begin
        HRDATA_S5   = 32'd0;
        HREADY_S5   = 1'b0;
        HRESP_S5    = 2'b0;
        DRAM_CSn    = 1'b0;
        DRAM_WEn    = 1'b1;
        DRAM_RASn   = 1'b1;
        DRAM_CASn   = 1'b1;
        DRAM_A      = col_addr;
        DRAM_D      = 32'd0;
      end
      READ:begin
        HRDATA_S5   = DRAM_out;
        HREADY_S5   = 1'b1;
        HRESP_S5    = 2'b0;
        DRAM_CSn    = 1'b0;
        DRAM_WEn    = 1'b1;
        DRAM_RASn   = 1'b1;
        DRAM_CASn   = 1'b1;
        DRAM_A      = col_addr;
        DRAM_D      = 32'd0;
      end
      default:begin
        HRDATA_S5   = 32'd0;
        HREADY_S5   = 1'b0;
        HRESP_S5    = 2'b0;
        DRAM_CSn    = 1'b1;
        DRAM_WEn    = 1'b1;
        DRAM_RASn   = 1'b1;
        DRAM_CASn   = 1'b1;
        DRAM_A      = 11'd0;
        DRAM_D      = 32'd0;
      end
    endcase
  end

endmodule

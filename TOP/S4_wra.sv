// Sensor
`include "define.sv"
`include "AHB_def.svh"

module S4_wra(
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
  input                                     HSEL_S4,
  // Input from Sensor Controller.
  input         [`data_size-1:0]            sctrl_out,

  // Outputs to AHB BUS.
  output logic  [`AHB_DATA_BITS-1:0]        HRDATA_S4,
  output logic                              HREADY_S4,
  output logic  [`AHB_RESP_BITS-1:0]        HRESP_S4,
  // Outputs to Sensor Controller.
  output logic                              sctrl_en,
  output logic                              sctrl_clear,
  output logic  [5:0]                       sctrl_addr

);

  parameter                                 IDLE = 2'b00, ADDR = 2'b01, WAITnCLEAR = 2'b10, READ = 2'b11;
  logic     [1:0]                           cstate;
  logic     [1:0]                           nstate;
  logic     [`data_size-1:0]                Reg0100;  // store the value at address 0x3000_0100.


  always_ff@(posedge clk, posedge rst)begin  //!! This might be reduced as 1-bit signal.    // store value from the address 0x3000_0100.
    if(rst)
      Reg0100 <= 32'd0;
    else if (HWRITE && (HADDR == 32'h3000_0100))
      Reg0100 <= HWDATA;
    else if (HWRITE && (HADDR == 32'h3000_0200))
      Reg0100 <= 32'b0;
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
	    if(HSEL_S4&&(HMASTER == 4'b0001))
		  nstate = ADDR;
		else
		  nstate = IDLE;
	  end
	  ADDR:
	    nstate = WAITnCLEAR;   //!!!  check clear mechanism.
	  WAITnCLEAR:
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
	  	HRDATA_S4      = sctrl_out;
	    HREADY_S4      = 1'd1;
	    HRESP_S4       = 2'd0;
        sctrl_en       = 1'b0;
        sctrl_clear    = 1'b0;
        sctrl_addr     = 6'b0;
	  end
	  ADDR:begin
	  	HRDATA_S4      = 32'd0;
	    HREADY_S4      = 1'd0;
	    HRESP_S4       = 2'd0;
        sctrl_en       = 1'b1;
        sctrl_clear    = 1'b0;
        sctrl_addr     = HADDR;
	  end
	  WAITnCLEAR:begin
	    HRDATA_S4      = 32'd0;
	    HREADY_S4      = 1'd0;
	    HRESP_S4       = 2'd0;
        sctrl_en       = 1'b1;
        sctrl_clear    = 1'b1;
        sctrl_addr     = HADDR;
	  end
	  READ:begin
        HRDATA_S4      = sctrl_out;
	    HREADY_S4      = 1'd1;
	    HRESP_S4       = 2'd0;
        sctrl_en       = 1'b1;
        sctrl_clear    = 1'b0;
        sctrl_addr     = HADDR;
      end
	  default:begin
        HRDATA_S4      = 32'd0;
	    HREADY_S4      = 1'd0;
	    HRESP_S4       = 2'd0;
        sctrl_en       = 1'b0;
        sctrl_clear    = 1'b0;
        sctrl_addr     = 6'b0;
      end
	endcase
  end

endmodule

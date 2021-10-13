`include "AHB_def.svh"

module DefaultSlave(
  input                                     HCLK,
  input                                     HRESETn,
  input         [`AHB_TRANS_BITS-1:0]       HTRANS,
  input                                     HSELDefault,
  output logic                              HREADYDefault,
  output logic  [`AHB_RESP_BITS-1:0]        HRESPDefault
);

  enum logic [1:0] {
    IDLE, ERROR1, ERROR2
  } cstate, nstate;

  always_ff@(posedge HCLK or negedge HRESETn)
  begin
    if (~HRESETn)
      cstate <= #1 IDLE;
    else
      cstate <= #1 nstate;
  end

  always_comb
  begin
    case (cstate)
      IDLE: nstate = (HSELDefault && ((HTRANS == `AHB_TRANS_NONSEQ)
        || (HTRANS == `AHB_TRANS_SEQ)))? ERROR1: IDLE;
      ERROR1: nstate = ERROR2;
      ERROR2: nstate = IDLE;
      default: nstate = IDLE;
    endcase
  end

  always_comb
  begin
    HREADYDefault = (cstate != ERROR1);
    HRESPDefault = ((cstate == ERROR1) || (cstate == ERROR2))?
      `AHB_RESP_ERROR: `AHB_RESP_OKAY;
  end
  
endmodule

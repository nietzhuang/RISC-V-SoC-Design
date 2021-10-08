`include "define.sv"

module predict(
  input                     clk,
  input                     rst,
  input         [6:0]       opcode_ID_EXE, // from EXE stage
  input                     jump_sel,
  input                     Istall,
  input                     Dstall,

  output logic              taken_sel
);

  parameter                 ntaken0 = 2'b00, ntaken1 = 2'b01, taken1 = 2'b10, taken0 = 2'b11;

  logic                     flag_stall;
  logic [1:0]               cstate;
  logic [1:0]               nstate;


  assign flag_stall = Istall || Dstall;

  always_ff@(posedge clk, posedge rst)begin
    if(rst)
      cstate <= ntaken0;
    else if(!flag_stall)
      cstate <= nstate;
  end

  always_comb begin
    if(jump_sel && (opcode_ID_EXE == `Btype))begin
      unique case(cstate)
        ntaken0:begin
          if(jump_sel)
            nstate = ntaken1;
          else
            nstate = ntaken0;
        end
        ntaken1:begin
          if(jump_sel)
            nstate = taken1;
          else
            nstate = ntaken0;
        end
        taken1:begin
          if(jump_sel)
            nstate = taken0;
          else
            nstate = ntaken1;
        end
        taken0:begin
          if(jump_sel)
            nstate = taken0;
          else
            nstate = taken1;
        end
      endcase
    end
    else  // not Btype
      nstate = cstate;
  end

  always_comb begin
    unique case(cstate)
      ntaken0, ntaken1:
      taken_sel = 1'b0;
      taken0, taken1:
      taken_sel = 1'b1;
    endcase
  end
  
endmodule

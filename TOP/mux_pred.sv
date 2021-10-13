`include "define.sv"

module mux_pred(
  input         [`data_size-1:0]        PC_added,
  input         [`data_size-1:0]        PC_imm_que,
  input         [`data_size-1:0]        PC_imm,
  input         [6:0]                   opcode_EXE,
  input         [6:0]                   opcode_IF,
  input                                 taken_sel,
  input                                 jump_sel,
  input                                 Istall,
  input                                 Dstall,

  output logic  [`data_size-1:0]        PC_in_pred,
  output logic                          flush
);

  logic                                 Btype_IF;
  logic                                 Btype_EXE;
  logic                                 flag_stall;


  assign Btype_IF   = (opcode_IF == `Btype);
  assign Btype_EXE  = (opcode_EXE == `Btype);
  assign flag_stall = Istall || Dstall;

  always_comb begin
    if((opcode_IF == `Jtype) && (taken_sel))begin
      PC_in_pred = PC_imm;
      flush = 1'b0;
    end
    else if(!flag_stall)begin
      case({Btype_IF, Btype_EXE, taken_sel, jump_sel})
      4'b0000, 4'b0001, 4'b0010, 4'b0011, 4'b0100, 4'b1000, 4'b1001, 4'b1100, 4'b0111:begin
        PC_in_pred = PC_added;
        flush = 1'b0;
      end
     4'b0101, 4'b0110, 4'b1101, 4'b1110:begin
        PC_in_pred = PC_imm_que;
        flush = 1'b1;
      end
     4'b1010, 4'b1011, 4'b1111:begin
        PC_in_pred = PC_imm;
        flush = 1'b0;
      end
      default:begin
        PC_in_pred = PC_added;
        flush = 1'b0;
      end
      endcase
    end
    else begin
      PC_in_pred = PC_added;
      flush = 1'b0;
    end
  end

endmodule

`include "define.sv"

module queue(
  input                                 clk,
  input                                 rst,
  input         [`data_size-1:0]        PC_added,
  input         [6:0]                   opcode_IF,  // from stage IF
  input         [6:0]                   opcode_ID,
  input         [6:0]                   imm_IM_31_25,
  input         [12:0]                  imm_IM_24_12,
  input         [4:0]                   imm_IM_11_7,
  input                                 taken_sel,
  input                                 Istall,
  input                                 Dstall,
  input									wfi_stall,

  output logic  [`data_size-1:0]        PC_imm,
  output logic  [`data_size-1:0]        PC_imm_que
 );

  logic     [`data_size-1:0]            imm_que;
  logic     [`data_size-1:0]            slots;  // register
  logic                                 flag_stall;


  assign flag_stall = Istall || Dstall || wfi_stall;

  always_comb begin
    if(taken_sel)
      imm_que = PC_added;
    else
      imm_que = PC_added - 32'd4 + {{20{imm_IM_31_25[6]}}, imm_IM_11_7[0], imm_IM_31_25[5:0], imm_IM_11_7[4:1], 1'b0};
  end

  always_ff@(posedge clk, posedge rst)begin
    if(rst)begin
      slots <= `data_size'b0;
      PC_imm_que <= `data_size'b0;
    end
    else begin
      if(!flag_stall)
        slots <= imm_que;
      if((!flag_stall) && (opcode_ID == `Btype))
        PC_imm_que <= slots;
    end
  end

  always_ff@(posedge clk, posedge rst)begin
    if(rst)
      PC_imm <= `data_size'b0;
    else begin
      case(opcode_IF)
        `Btype:
        PC_imm <= PC_added - `data_size'd4 + {{20{imm_IM_31_25[6]}}, imm_IM_11_7[0], imm_IM_31_25[5:0], imm_IM_11_7[4:1], 1'b0};
        `Jtype:
        PC_imm <= PC_added - `data_size'd4 + {{11{imm_IM_31_25[6]}}, imm_IM_31_25[6], imm_IM_24_12[7:0], imm_IM_24_12[8], imm_IM_31_25[5:0], imm_IM_24_12[12:9], 1'b0};
        default:
        PC_imm <= `data_size'd0;
      endcase
    end
end

endmodule

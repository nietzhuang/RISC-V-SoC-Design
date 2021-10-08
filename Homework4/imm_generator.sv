`include "define.sv"

module imm_generator(
  input         [`data_size-1:0]        imm_in,

  output logic  [`data_size-1:0]        imm
);

  logic     [6:0]                       opcode_ID_EXE;


  assign opcode_ID_EXE = imm_in[6:0];

  always_comb begin
    case(opcode_ID_EXE)
      `Itype, 'b0000011, 'b1100111:begin  // include LW, JALR
      if(imm_in[31] == 0)
        imm = {20'b0, imm_in[31:20]};
      else if(imm_in[31] == 1)
        imm = {20'hfffff, imm_in[31:20]};
      else
        imm = 32'b0;
      end
      `Stype:begin
      if(imm_in[31] == 0)
        imm = {20'b0, imm_in[31:25], imm_in[11:7]};
      else if(imm_in[31] == 1)
        imm = {20'hfffff, imm_in[31:25], imm_in[11:7]};
      else
        imm = 32'b0;
      end
      `Btype:begin
        if (imm_in[31] == 0)
          imm = {19'b0,imm_in[31], imm_in[7], imm_in[30:25], imm_in[11:8], 1'b0};
        else if (imm_in[31] == 1)
          imm = {19'h7ffff,imm_in[31], imm_in[7], imm_in[30:25], imm_in[11:8], 1'b0};
        else
          imm = 32'b0;
      end
      `Utype, `AUIPC:
      imm = {imm_in[31:12], 12'b0};
      `Jtype:begin
        if (imm_in[31] == 0 )
          imm = {11'b0, imm_in[31], imm_in[19:12], imm_in[20], imm_in[30:21], 1'b0};
        else if(imm_in[31] == 1)
          imm = {11'h7ff, imm_in[31], imm_in[19:12], imm_in[20], imm_in[30:21], 1'b0};
        else
          imm = 32'b0;
      end
      default:  // include Rtype
        imm = 32'b0;
    endcase
  end

endmodule

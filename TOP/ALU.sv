`include "define.sv"

module ALU(
  input         [`data_size-1:0]        src1,
  input         [`data_size-1:0]        src2,
  input         [6:0]                   opcode_EXE,
  input         [6:0]                   funct7,
  input         [2:0]                   funct3_EXE,
  input                                 branch,
  input                                 enable,

  output logic  [`data_size-1:0]        alu_result,
  output logic                          jump_sel
);

  logic     [63:0]            temp;
  logic                                 alu_zero;

  assign jump_sel = branch & alu_zero;
  assign temp = (funct7 == 7'b0100000)? {{(`data_size){src1[31]}}, src1} >> src2[4:0] : 64'b0;

  always_comb begin
    if(enable)begin
      case(opcode_EXE)
        `Rtype, `Itype:
          unique case(funct3_EXE)
            `ADD:begin
              if(funct7 == 7'b0100000)begin  // SUB
                alu_result = src1 - src2;
                alu_zero = 1'b0;
              end
              else begin
                alu_result = src1 + src2;  // include NOP
                alu_zero = 1'b0;
              end
            end
            `SLT:begin
              if(src1[31] > src2[31])begin
                alu_result = `data_size'b1;
                alu_zero = 1'b0;
              end
              else if(src1[31] < src2[31])begin
                alu_result = `data_size'b0;
                alu_zero = 1'b0;
              end
              else begin
                alu_result = (src1[30:0] < src2[30:0])? `data_size'b1 : `data_size'b0;
                alu_zero = 1'b0;
              end
            end
            `XOR:begin
              alu_result = src1 ^ src2;
              alu_zero = 1'b0;
            end
            `SLL:begin
              alu_result = src1 << src2[4:0];
              alu_zero = 1'b0;
            end
            `SRL:begin
              if(funct7 == 7'b010_0000)begin  // SRA
                alu_result = temp[31:0];
                alu_zero = 1'b0;
              end
              else begin  // SRL
                alu_result = src1 >> src2[4:0];
                alu_zero = 1'b0;
              end
            end
            `OR:begin
              alu_result = src1 | src2;
              alu_zero = 1'b0;
            end
            `AND:begin
              alu_result = src1 & src2;
              alu_zero = 1'b0;
            end
            `SLTU:begin
              alu_result = (src1 < src2);
              alu_zero = 1'b0;
            end
          endcase  // end case of funt3 of Rtype, Itype
          7'b0000011:begin  // Load
            unique case(funct3_EXE)
              3'b010:begin  // LW
                alu_result = src1 + src2;  // calulate the address
                alu_zero = 1'b0;
              end
              3'b000:begin  // LB
                alu_result = src1 + src2;
                alu_zero = 1'b0;
              end
              3'b001:begin  // LH
                alu_result = src1 + src2;
                alu_zero = 1'b0;
              end
              3'b100:begin  // LBU
                alu_result = src1 + src2;
                alu_zero = 1'b0;
              end
              3'b101:begin  // LHU
                alu_result = src1 + src2;
                alu_zero = 1'b0;
              end
            endcase // end case of funct3_EXE 0000011
          end
          `Stype:begin
            alu_result = src1 + src2;
            alu_zero = 1'b0;
          end
          `Btype:begin
            case(funct3_EXE)
              3'b000:begin  // BEQ
                alu_result = src1 - src2;
                alu_zero = (alu_result == 0);
              end
              3'b001:begin//BNE
                alu_result = src1 - src2;
                alu_zero = (alu_result != 0);
              end
              3'b100:begin  // BLT
                //!! has the potential to reduece area.
                // notice the sign bit.
                if (src1[31] < src2[31])begin
                  alu_result = `data_size'b0;  // dont care
                  alu_zero = 1'b0;  // larger than, so don't branch
                end
                else if(src1[31] > src2[31])begin
                  alu_result = `data_size'b0;
                  alu_zero = 1'b1;  // less than, so branch
                end
                else begin
                  alu_result = `data_size'b0;  // don't care
                  alu_zero = (src1[30:0] < src2[30:0]);
                end
              end
              3'b101:begin  // BGE
                if (src1[31] < src2[31])begin
                  alu_result = `data_size'b0;
                  alu_zero = 1'b1;  // larger than, so branch
                end
                else if(src1[31] > src2[31])begin
                  alu_result = `data_size'b0;
                  alu_zero = 1'b0;  // less than, so don't branch
                end
                else begin
                  alu_result = `data_size'b0;
                  alu_zero = ((src1[30:0] > src2[30:0]) || (src1 == src2));
                end
              end
              3'b110:begin  // BLTU
                alu_result = `data_size'b0;
                alu_zero = (src1 < src2);
              end
              3'b111:begin  // BGEU
                alu_result = `data_size'b0;
                alu_zero = ((src1 > src2) || (src1 == src2));
              end
              default:begin
                alu_result = `data_size'b0;
                alu_zero = 1'b0;
              end
            endcase
          end
          `Utype:begin
            alu_result = src2;
            alu_zero = 1'b0;
          end
          `Jtype:begin
            alu_result = `data_size'b0;
            alu_zero = 1'b1; //no any value to writeback and branch here
          end
          `JALR:begin
            alu_result = src1 + src2;
            alu_zero = 1'b1; // always jump
          end
          `AUIPC:begin
            alu_result = src1 + src2 - 32'd4; // PC + imm, not PC+4 + imm
            alu_zero = 1'b1;
          end
          `CSR:begin
              alu_result = src2;  // src2 read from csr.
              alu_zero = 1'b0;
          end
          default:begin
            alu_result = `data_size'b0;
            alu_zero = 1'b0;
          end  // end Btype
        endcase
    end  // end if
    else begin
      alu_result = `data_size'b0;
      alu_zero = 1'b0;
    end  // end enable
  end

endmodule

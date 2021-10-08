`include "define.sv"


module ALU(
  input         [`data_size-1:0]        src1,
  input         [`data_size-1:0]        src2,
  input         [6:0]                   opcode_ID_EXE,
  input         [6:0]                   funct7,
  input         [2:0]                   funct3_ID_EXE,
  input                                 branch,
  input                                 enable,

  output logic  [`data_size-1:0]        alu_result,
  output logic                          jump_sel
);

  logic     [`data_size-1:0]            temp;
  logic                                 alu_zero;

  assign jump_sel = branch & alu_zero;

  always_comb begin
    if(enable)begin
      case(opcode_ID_EXE)
        `Rtype, `Itype:
          unique case(funct3_ID_EXE)
            `ADD:begin
              if(funct7 == 7'b0100000)begin  // SUB
                alu_result = src1 - src2;
                alu_zero = 1'b0;
                temp = 64'd0;
              end
              else begin
                alu_result = src1 + src2;  // include NOP
                alu_zero = 1'b0;
                temp = 64'd0;
              end
            end
            `SLT:begin
              if(src1[31] > src2[31])begin
                alu_result = `data_size-1'b1;
                alu_zero = 1'b0;
                temp = 64'd0;
              end
              else if(src1[31] < src2[31])begin
                alu_result = `data_size-1'b0;
                alu_zero = 1'b0;
                temp = 64'd0;
              end
              else begin
                alu_result = (src1[30:0] < src2[30:0])? `data_size-1'b1 : `data_size-1'b0;
                alu_zero = 1'b0;
                temp = 64'd0;
              end
            end
            `XOR:begin
              alu_result = src1 ^ src2;
              alu_zero = 1'b0;
              temp = 64'd0;
            end
            `SLL:begin
              alu_result = src1 << src2[4:0];
              alu_zero = 1'b0;
              temp = 64'd0;
            end
            `SRL:begin
              if(funct7 == 7'b010_0000)begin  // SRA
                temp = {{(`data_size-1){src1[31]}}, src1};
                temp = temp >> src2[4:0];
                alu_result = temp[31:0];
                alu_zero = 1'b0;
              end
              else begin  // SRL
                alu_result = src1 >> src2[4:0];
                alu_zero = 1'b0;
                temp = 64'd0;
              end
            end
            `OR:begin
              alu_result = src1 | src2;
              alu_zero = 1'b0;
              temp = 64'd0;
            end
            `AND:begin
              alu_result = src1 & src2;
              alu_zero = 1'b0;
              temp = 64'd0;
            end
            `SLTU:begin
              alu_result = (src1 < src2);
              alu_zero = 1'b0;
              temp = 64'd0;
            end
          endcase  // end case of funt3 of Rtype, Itype
          7'b0000011:begin  // Load
            unique case(funct3_ID_EXE)
              3'b010:begin  // LW
                alu_result = src1 + src2;  // calulate the address
                alu_zero = 1'b0;
                temp = 64'd0;
              end
              3'b000:begin  // LB
                alu_result = src1 + src2;
                alu_zero = 1'b0;
                temp = 64'd0;
              end
              3'b001:begin  // LH
                alu_result = src1 + src2;
                alu_zero = 1'b0;
                temp = 64'd0;
              end
              3'b100:begin  // LBU
                alu_result = src1 + src2;
                alu_zero = 1'b0;
                temp = 64'd0;
              end
              3'b101:begin  // LHU
                alu_result = src1 + src2;
                alu_zero = 1'b0;
                temp = 64'd0;
              end
            endcase // end case of funct3_ID_EXE 0000011
          end
          `Stype:begin
            alu_result = src1 + src2;
            alu_zero = 1'b0;
            temp = 64'd0;
          end
          `Btype:begin
            case(funct3_ID_EXE)
              3'b000:begin  // BEQ
                alu_result = src1 - src2;
                alu_zero = (alu_result == 0);
                temp = 64'd0;
              end
              3'b001:begin//BNE
                alu_result = src1 - src2;
                alu_zero = (alu_result != 0);
                temp = 64'd0;
              end
              3'b100:begin  // BLT
                //!! has the potential to reduece area.
                // notice the sign bit.
                if (src1[31] < src2[31])begin
                  alu_result = `data_size-1'b0;  // dont care
                  alu_zero = 1'b0;  // larger than, so don't branch
                  temp = 64'd0;
                end
                else if(src1[31] > src2[31])begin
                  alu_result = `data_size-1'b0;
                  alu_zero = 1'b1;  // less than, so branch
                  temp = 64'd0;
                end
                else begin
                  alu_result = `data_size-1'b0;  // don't care
                  alu_zero = (src1[30:0] < src2[30:0]);
                  temp = 64'd0;
                end
              end
              3'b101:begin  // BGE
                if (src1[31] < src2[31])begin
                  alu_result = `data_size-1'b0;
                  alu_zero = 1'b1;  // larger than, so branch
                  temp = 64'd0;
                end
                else if(src1[31] > src2[31])begin
                  alu_result = `data_size-1'b0;
                  alu_zero = 1'b0;  // less than, so don't branch
                  temp = 64'd0;
                end
                else begin
                  alu_result = `data_size-1'b0;
                  alu_zero = ((src1[30:0] > src2[30:0]) || (src1 == src2));
                  temp = 64'd0;
                end
              end
              3'b110:begin  // BLTU
                alu_result = `data_size-1'b0;
                alu_zero = (src1 < src2);
                temp = 64'd0;
              end
              3'b111:begin  // BGEU
                alu_result = `data_size-1'b0;
                alu_zero = ((src1 > src2) || (src1 == src2));
                temp = 64'd0;
              end
              default:begin
                alu_result = `data_size-1'b0;
                alu_zero = 1'b0;
                temp = 64'd0;
              end
            endcase
          end
          `Utype:begin
            alu_result = src2;
            alu_zero = 1'b0;
            temp = 64'd0;
          end
          `Jtype:begin
            alu_result = `data_size-1'b0;
            alu_zero = 1'b1; //no any value to writeback and branch here
            temp = 64'd0;
          end
          `JALR:begin
            alu_result = src1 + src2;
            alu_zero = 1'b1; // always jump
            temp = 64'd0;
          end
          `AUIPC:begin
            alu_result = src1 + src2 - 32'd4; // PC + imm, not PC+4 + imm
            alu_zero = 1'b1;
            temp = 64'd0;
          end
          default:begin
            alu_result = `data_size-1'b0;
            alu_zero = 1'b0;
            temp = 64'd0;
          end  // end Btype
        endcase
    end  // end if
    else begin
      alu_result = `data_size-1'b0;
      alu_zero = 1'b0;
      temp = 64'd0;
    end  // end enable
  end

endmodule

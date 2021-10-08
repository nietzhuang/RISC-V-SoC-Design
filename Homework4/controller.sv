`include "define.sv"

module controller(
  input         [`data_size-1:0]    instruction,

  output logic                      RF_en,
  output logic  [2:0]               WB_ctr,  // WB_ctr = {RF_write, lw_select}
  output logic  [2:0]               MEM_ctr,  // MEM_ctr = {branch, DM_write, DM_enable}
  output logic                      RF_read,
  output logic                      imm_select,
  output logic                      alu_en,
  output logic                      utype_sel,
  output logic                      asipc_sel
);

  logic     [6:0]                   opcode;


  assign opcode = instruction[6:0];

  always_comb begin
    case(opcode)
      `Rtype:begin
        RF_en           = 1'b1;
        MEM_ctr         = 3'b000;
        WB_ctr          = 3'b011;
        RF_read         = 1'b1;
        imm_select      = 1'b0;
        alu_en          = 1'b1;
        utype_sel       = 1'b0;
        asipc_sel       = 1'b0;
      end
      `Itype:begin
        if(instruction[31:20] == 12'b0)begin  // NOP
          RF_en         = 1'b1;
          MEM_ctr       = 3'b000;
          WB_ctr        = 3'b011;
          RF_read       = 1'b1;
          imm_select    = 1'b1;
          alu_en        = 1'b1;
          utype_sel     = 1'b0;
          asipc_sel     = 1'b0;
        end
        else begin  // Itype
          RF_en         = 1'b1;
          MEM_ctr       = 3'b000;
          WB_ctr        = 3'b011;
          RF_read       = 1'b1;
          imm_select    = 1'b1;
          alu_en        = 1'b1;
          utype_sel     = 1'b0;
          asipc_sel     = 1'b0;
        end
      end
      7'b0000011:begin  // LW, LB, LH, LBU, LHU
        RF_en           = 1'b1;
        MEM_ctr         = 3'b001;
        WB_ctr          = 3'b010;
        RF_read         = 1'b1;
        imm_select      = 1'b1;
        alu_en          = 1'b1;
        utype_sel       = 1'b0;
        asipc_sel       = 1'b0;
      end
      `Stype:begin
        RF_en           = 1'b1;
        MEM_ctr         = 3'b011;
        WB_ctr          = 3'b000;
        RF_read         = 1'b1;
        imm_select      = 1'b1;
        alu_en          = 1'b1;
        utype_sel       = 1'b0;
        asipc_sel       = 1'b0;
      end
      `Btype:begin
        RF_en           = 1'b1;
        MEM_ctr         = 3'b100;
        WB_ctr          = 3'b001;
        RF_read         = 1'b1;
        imm_select      = 1'b0;
        alu_en          = 1'b1;
        utype_sel       = 1'b0;
        asipc_sel       = 1'b0;
      end
      `Utype:begin
        RF_en           = 1'b1;
        MEM_ctr         = 3'b000;
        WB_ctr          = 3'b011;
        RF_read         = 1'b1;
        imm_select      = 1'b1;
        alu_en          = 1'b1;
        utype_sel       = 1'b1;
        asipc_sel       = 1'b0;
      end
      `Jtype:begin
        RF_en           = 1'b1;
        MEM_ctr         = 3'b100;
        WB_ctr          = 3'b111;
        RF_read         = 1'b1;
        imm_select      = 1'b1;
        alu_en          = 1'b1;
        utype_sel       = 1'b0;
        asipc_sel       = 1'b0;
      end
      `JALR:begin
        RF_en           = 1'b1;
        MEM_ctr         = 3'b100;
        WB_ctr          = 3'b111;
        RF_read         = 1'b1;
        imm_select      = 1'b1;
        alu_en          = 1'b1;
        utype_sel       = 1'b0;
        asipc_sel       = 1'b0;
      end
      `AUIPC:begin
        RF_en           = 1'b1;
        MEM_ctr         = 3'b000;
        WB_ctr          = 3'b011;
        RF_read         = 1'b1;
        imm_select      = 1'b1;
        alu_en          = 1'b1;
        utype_sel       = 1'b0;
        asipc_sel       = 1'b1;
      end
      default:begin
        RF_en           = 1'b1;
        WB_ctr          = 3'b0;
        MEM_ctr         = 3'b0;
        RF_read         = 1'b0;
        imm_select      = 1'b0;
        alu_en          = 1'b1;
        utype_sel       = 1'b0;
        asipc_sel       = 1'b0;
      end
    endcase
  end

endmodule

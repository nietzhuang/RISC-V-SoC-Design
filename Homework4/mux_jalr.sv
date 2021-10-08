`include "define.sv"

module mux_jalr(
  input         [`data_size-1:0]        PC_jump,
  input         [`data_size-1:0]        alu_result,
  input         [6:0]                   opcode_ID_EXE,

  output logic  [`data_size-1:0]        PC_jump_jalr,
  output logic                          flush_jalr
);

  logic                                 jalr_sel;


  assign jalr_sel = (opcode_ID_EXE == `JALR);

  always_comb begin
    unique case(jalr_sel)
      1'b0: begin
        PC_jump_jalr = PC_jump;
        flush_jalr = 1'b0;
      end
      1'b1:begin
        PC_jump_jalr = alu_result;
        flush_jalr = 1'b1;
      end
    endcase
  end

endmodule

`include "define.sv"

module mux_csr_imm(
  input         [`data_size-1:0]        src1,
  input         [`data_size-1:0]        imm_EXE,
  input                                 csr_imm_sel_EXE,

  output logic  [`data_size-1:0]        csr_write_tmp
);

  always_comb begin
    case(csr_imm_sel_EXE)
    1'b0: csr_write_tmp = src1;
    1'b1: csr_write_tmp = imm_EXE;
    default: csr_write_tmp = src1;
    endcase
  end

endmodule

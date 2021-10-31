`include "define.sv"

module mux_csr_imm(
  input         [`data_size-1:0]        src1,
  input         [`data_size-1:0]        imm_EXE,
  input			[`data_size-1:0]		PC_added_EXE,
  input         [1:0]                   csr_imm_sel_EXE,

  output logic  [`data_size-1:0]        csr_write_tmp
);

  always_comb begin
    case(csr_imm_sel_EXE)
    2'b00: csr_write_tmp = src1;
    2'b01: csr_write_tmp = imm_EXE;
	2'b10: csr_write_tmp = PC_added_EXE;
    default: csr_write_tmp = src1;
    endcase
  end

endmodule

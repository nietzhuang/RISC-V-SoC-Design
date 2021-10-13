`include "define.sv"

module mux_csr_result(
  input         [`data_size-1:0]        alu_result_tmp,
  input         [`data_size-1:0]        csr_read_data_EXE,
  input                                 csr_result_sel_EXE,
  output logic  [`data_size-1:0]        alu_result
);

  always_comb begin
    case(csr_result_sel_EXE)
    1'b0: alu_result  = alu_result_tmp;
    1'b1: alu_result  = csr_read_data_EXE;
    default: alu_result = alu_result_tmp;
    endcase
  end

endmodule

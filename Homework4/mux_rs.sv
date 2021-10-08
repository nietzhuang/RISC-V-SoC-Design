`include "define.sv"

module mux_rs(
  input         [`data_size-1:0]        Read_data_1_EXE,
  input         [`data_size-1:0]        alu_result_EXE_MEM,
  input         [`data_size-1:0]        write_data,
  input         [`data_size-1:0]        Dcache_out_ext,
  input         [1:0]                   rs_sel,

  output logic  [`data_size-1:0]        src1
);

  always_comb begin
    case(rs_sel)
      2'b00: src1 = Read_data_1_EXE;
      2'b01: src1 = alu_result_EXE_MEM;
      2'b10: src1 = write_data;
      2'b11: src1 = Dcache_out_ext;
    endcase
  end

endmodule

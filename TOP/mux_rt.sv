`include "define.sv"

module mux_rt(
  input         [`data_size-1:0]        imm_out,
  input         [`data_size-1:0]        alu_result_MEM,
  input         [`data_size-1:0]        write_data,
  input         [`data_size-1:0]        Dcache_out_ext,
  input         [1:0]                   rt_sel,

  output logic  [`data_size-1:0]        src2
);

  always_comb begin
    unique case(rt_sel)
      2'b00: src2 = imm_out;
      2'b01: src2 = alu_result_MEM;
      2'b10: src2 = write_data;
      2'b11: src2 = Dcache_out_ext;
    endcase
  end

endmodule

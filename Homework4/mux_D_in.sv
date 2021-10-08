`include "define.sv"

module mux_D_in(
  input         [`data_size-1:0]        Read_data_2_EXE_MEM,
  input         [`data_size-1:0]        write_data,  // from WB stage
  input                                 D_in_sel,

  output logic  [`data_size-1:0]        Dcache_in
);

  always_comb begin
    unique case(D_in_sel)
      1'b0: Dcache_in = Read_data_2_EXE_MEM;
      1'b1: Dcache_in = write_data;
    endcase
  end

endmodule

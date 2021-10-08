`include "define.sv"

module mux_Din(
  input         [`data_size-1:0]        Dcache_in,
  input         [`data_size-1:0]        DM_out,
  input                                 D_sel,

  output logic  [`data_size-1:0]        Dcache_in_DI
);

  always_comb begin
    unique case(D_sel)
      1'b0:Dcache_in_DI = Dcache_in;
      1'b1:Dcache_in_DI = DM_out;
    endcase
  end

endmodule

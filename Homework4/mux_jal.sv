`include "define.sv"

module mux_jal(
  input         [`data_size-1:0]        a,
  input         [`data_size-1:0]        b,
  input                                 select,

  output logic  [`data_size-1:0]        y
);

  assign y  = (!select)? a : b;

endmodule

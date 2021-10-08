`include "define.sv"

module D_comparator(
  input     [`tag-1:0]      tag,
  input     [`tag-1:0]      D_tag,
  input                     v_bit,

  output logic              hit
);

  assign hit = (tag == D_tag)? 1'b1 : 1'b0;

endmodule

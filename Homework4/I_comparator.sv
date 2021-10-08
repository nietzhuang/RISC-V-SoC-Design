`include "define.sv"

module I_comparator(
  input     [`tag-1:0]      tag,
  input     [`tag-1:0]      I_tag,
  input                     v_bit,

  output logic              hit
);

  assign hit = ((tag==I_tag) && v_bit)? 1'b1 : 1'b0;

endmodule

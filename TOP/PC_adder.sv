`include "define.sv"

module PC_adder(
  input         [`data_size-1:0]        PC_address,
  input         [`data_size-1:0]        PC_added_ID_EXE,
  input         [`data_size-1:0]        imm_EXE,

  output logic  [`data_size-1:0]        PC_in,
  output logic  [`data_size-1:0]        PC_jump
);

  always_comb begin
    PC_in   = PC_address + 32'd4;
    PC_jump = PC_added_ID_EXE + imm_EXE - 32'd8;
  end

endmodule

`include "define.sv"

module mux_asipc(
  input         [`data_size-1:0]        PC_added_EXE,
  input         [`data_size-1:0]        Read_data_1_EXE,
  input                                 asipc_sel, // wire to asipc_sel_EXE

  output logic  [`data_size-1:0]        Read_data_1_EXE_asipc
);


  always_comb begin
    unique case(asipc_sel)
      1'b0: Read_data_1_EXE_asipc = Read_data_1_EXE;
      1'b1: Read_data_1_EXE_asipc = PC_added_EXE;
    endcase
  end

endmodule

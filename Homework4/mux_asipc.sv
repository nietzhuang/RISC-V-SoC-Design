`include "define.sv"

module mux_asipc(
  input         [`data_size-1:0]        PC_added_ID_EXE,
  input         [`data_size-1:0]        Read_data_1,
  input                                 asipc_sel, // wire to asipc_sel_EXE

  output logic  [`data_size-1:0]        Read_data_1_EXE_MEM
);


  always_comb begin
    unique case(asipc_sel)
      1'b0: Read_data_1_EXE_MEM = Read_data_1;
      1'b1: Read_data_1_EXE_MEM = PC_added_ID_EXE;
    endcase
  end
  
endmodule

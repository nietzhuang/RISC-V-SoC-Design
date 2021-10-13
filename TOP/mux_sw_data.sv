`include "define.sv"

module mux_sw_data(
  input         [`data_size-1:0]        Read_data_2_EXE_u,  // from mux_utype
  input         [`data_size-1:0]        write_data,
  input                                 sw_data_sel,

  output logic  [`data_size-1:0]        Read_data_sw_EXE
  );

  always_comb begin
    unique case(sw_data_sel)
      1'b0: Read_data_sw_EXE = Read_data_2_EXE_u;
      1'b1: Read_data_sw_EXE = write_data;
    endcase
  end

endmodule

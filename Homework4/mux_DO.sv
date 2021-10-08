module mux_DO(
  input         [`data_size-1:0]        DO_0,
  input         [`data_size-1:0]        DO_1,
  input         [`data_size-1:0]        DO_2,
  input         [`data_size-1:0]        DO_3,
  input         [1:0]                   DO_sel, // wire to offset

  output logic  [`data_size-1:0]        data
);


  always_comb begin
    unique case(DO_sel)
      2'b00: data = DO_0;
      2'b01: data = DO_1;
      2'b10: data = DO_2;
      2'b11: data = DO_3;
    endcase
  end

endmodule

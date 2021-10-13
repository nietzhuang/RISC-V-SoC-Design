module D_performance(
  input                     clk,
  input                     rst,
  input                     Dcache_en,
  input                     v_bit,
  input                     hit,

  output logic  [63:0]      L1D_access,
  output logic  [63:0]      L1D_miss
);

  always_ff@(posedge clk, posedge rst)begin
    if(rst)
      L1D_access <= 64'b0;
    else if(Dcache_en)
      L1D_access <= L1D_access + 1;
  end

  always_ff@(posedge clk, posedge rst)begin
    if(rst)
      L1D_miss <= 64'b0;
    else if((!hit) && v_bit)
      L1D_miss <= L1D_miss + 1;
  end

endmodule

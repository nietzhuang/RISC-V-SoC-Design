module I_performance(
  input                     clk,
  input                     rst,
  input                     Icache_en,
  input                     v_bit,
  input                     hit,

  output logic  [63:0]      L1I_access,
  output logic  [63:0]      L1I_miss
);

  always_ff@(posedge clk, posedge rst)begin
    if(rst)
      L1I_access <= 64'b0;
    else if(Icache_en)
      L1I_access <= L1I_access + 1;
  end

  always_ff@(posedge clk, posedge rst)begin
    if(rst)
      L1I_miss <= 64'b0;
    else if((!hit) && v_bit)
      L1I_miss <= L1I_miss + 1;
  end

endmodule

module sensor_ctrl(
  input                     clk,
  input                     rst,
  // Core inputs
  input                     sctrl_en,
  input                     sctrl_clear,
  input         [5:0]       sctrl_addr,
  // Sensor inputs
  input                     sensor_ready,
  input         [31:0]      sensor_out,
  // Core outputs
  output logic              sctrl_interrupt,
  output logic  [31:0]      sctrl_out,
  // Sensor outputs
  output logic              sensor_en
);

  logic [31:0] mem[0:63];
  logic [5:0] counter;
  logic full;


  always_ff@(posedge clk or posedge rst)
  begin
    if (rst)
      counter <= 6'd0;
    else if (sctrl_clear)
      counter <= 6'd0;
    else if (sctrl_en && (~full) && sensor_ready)
      counter <= counter + 1'b1;
  end

  always_comb
  begin
    sctrl_out = mem[sctrl_addr];
    sensor_en = (sctrl_en && (~full) && (~sctrl_clear));
    sctrl_interrupt = full;
  end

  always_ff@(posedge clk or posedge rst)
  begin
    if (rst)
      for (int i=0; i<64; i++)
        mem[i] <= 32'd0;
    else if (sctrl_en && (~full) && sensor_ready)
      mem[counter] <= sensor_out;
  end

  always_ff@(posedge clk or posedge rst)
  begin
    if (rst)
      full <= 1'b0;
    else if (sctrl_clear)
      full <= 1'b0;
    else if (sctrl_en && (counter == 6'd63) && sensor_ready)
      full <= 1'b1;
  end
  
endmodule

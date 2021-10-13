module ROM(
  CK,
  CS,
  OE,
  A,
  DO
);

  parameter word_size = 32;
  parameter addr_size = 12;
  parameter mem_size = (1 << addr_size);

  parameter read_delay = 100;

  input CK;
  input CS;
  input OE;
  input [addr_size-1:0] A;
  output reg [word_size-1:0] DO;

  reg [word_size-1:0] mem_data [0:mem_size-1];
  reg [addr_size-1:0] addr, prev_addr;

  wire [word_size-1:0] out_data;
  assign out_data = mem_data[addr];


  always@(posedge CK)
  begin
    addr <= A;
    prev_addr <= addr;
  end

  always@(*)
  begin
    if (OE && CS)
    begin
      if (addr != prev_addr) 
        DO <= 32'hx;
      else
        DO <= #(read_delay) out_data;
    end
    else
      DO <= #(read_delay) 32'hz;
  end
endmodule

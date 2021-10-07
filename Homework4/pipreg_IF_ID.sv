`include "define.sv"

//IF/ID
module pipreg_IF_ID(
  input                                 clk,
  input                                 rst,
  input                                 address_rst,
  input         [`data_size-1:0]        PC_in,
  input         [`data_size-1:0]        Icache_out,
  input                                 Istall,
  input                                 Dstall,
  input                                 flush,
  input                                 flush_jalr,

  output logic  [`data_size-1:0]        PC_added_IF_ID,
  output logic  [`data_size-1:0]        instruction,
  output logic  [4:0]                   Read_addr_1_IF_ID,
  output logic  [4:0]                   Read_addr_2_IF_ID,
  output logic  [4:0]                   write_addr_IF_ID,
  output logic  [`data_size-1:0]        imm_in
);

  assign stall  = Istall || Dstall;
  assign flush  = flush || flush_jalr;

  always_ff@(posedge clk)begin
    if(rst||address_rst)begin
      PC_added_IF_ID        <= 32'b0;
      instruction           <= 32'd0;
      Read_addr_1_IF_ID     <= 5'd0;
      Read_addr_2_IF_ID     <= 5'd0;
      write_addr_IF_ID      <=  5'b0;
      imm_in                <= 32'b0;
    end
    else if(!stall) begin
      if(!flush)begin
        PC_added_IF_ID      <= PC_in;
        instruction         <= Icache_out;
        Read_addr_1         <= Icache_out[19:15];
        Read_addr_2         <= Icache_out[24:20];
        write_addr_IF_ID    <= Icache_out[11:7];
        imm_in              <= Icache_out;
      end
      else begin
        PC_added_IF_ID      <= 32'b0;
        instruction         <= 32'h00000013;
        Read_addr_1         <= 5'd0;
        Read_addr_2         <= 5'd0;
        write_addr_IF_ID    <=  5'b0;
        imm_in              <= 32'b0;
      end
    end
  end
  
endmodule

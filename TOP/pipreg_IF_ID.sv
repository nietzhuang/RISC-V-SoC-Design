`include "define.sv"

//IF/ID
module pipreg_IF_ID(
  input                                 clk,
  input                                 rst,
  input                                 address_rst,
  input         [`data_size-1:0]        PC_added,
  input         [`data_size-1:0]        Icache_out,
  input                                 Istall,
  input                                 Dstall,
  input                                 flush,
  input                                 flush_jalr,

  output logic  [`data_size-1:0]        PC_added_ID,
  output logic  [`data_size-1:0]        instruction,
  output logic  [4:0]                   Read_addr_1_ID,
  output logic  [4:0]                   Read_addr_2_ID,
  output logic  [4:0]                   write_addr_ID,
  output logic  [11:0]                  csr_addr_ID,
  output logic  [`data_size-1:0]        imm_in
);

  logic                                 flag_stall;
  logic                                 flag_flush;

  assign flag_stall  = Istall || Dstall;
  assign flag_flush  = flush || flush_jalr;

  always_ff@(posedge clk, posedge rst)begin
    if(rst||address_rst)begin
      PC_added_ID        <= 32'b0;
      instruction        <= 32'd0;
      Read_addr_1_ID     <= 5'd0;
      Read_addr_2_ID     <= 5'd0;
      write_addr_ID      <= 5'b0;
      csr_addr_ID        <= 12'b0;
      imm_in             <= 32'b0;
    end
    else if(!flag_stall) begin
      if(!flag_flush)begin
        PC_added_ID      <= PC_added;
        instruction      <= Icache_out;
        Read_addr_1_ID   <= Icache_out[19:15];
        Read_addr_2_ID   <= Icache_out[24:20];
        write_addr_ID    <= Icache_out[11:7];
        csr_addr_ID      <= Icache_out[31:20];
        imm_in           <= Icache_out;
      end
      else begin
        PC_added_ID      <= 32'b0;
        instruction      <= 32'h00000013;
        Read_addr_1_ID   <= 5'd0;
        Read_addr_2_ID   <= 5'd0;
        write_addr_ID    <= 5'b0;
        csr_addr_ID      <= 12'b0;
        imm_in           <= 32'b0;
      end
    end
  end

endmodule

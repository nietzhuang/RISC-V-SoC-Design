`include "define.sv"

module RegFile(
  input                                 clk,
  input                                 rst,
  input         [4:0]                   Read_addr_1,
  input         [4:0]                   Read_addr_2,
  input         [4:0]                   write_addr,
  input         [`data_size-1:0]        write_data,
  input                                 RF_en,
  input                                 RF_write,
  input                                 RF_read,
  input                                 Istall,
  input                                 Dstall,

  output logic  [`data_size-1:0]        Read_data_1,
  output logic  [`data_size-1:0]        Read_data_2
);

  logic     [31:0]                      mem[`data_size-1:0];
  logic                                 flag_stall;
  integer                               i;


  assign flag_stall = Istall || Dstall;

  always_ff@(posedge clk, posedge rst)begin
    if(rst)begin
      for(i = 0 ; i < `data_size; i = i + 1 )begin
        mem[i] <= 32'd0 ;
      end
      Read_data_1 <= 32'd0;
      Read_data_2 <= 32'd0;
    end
    else begin
      if(RF_en && (!flag_stall))begin
        if(RF_write && (!flag_stall) && (write_addr != 0))
          mem[write_addr] <= write_data;
        if(RF_read && (!flag_stall))begin
          Read_data_1 <= mem[Read_addr_1];
          Read_data_2 <= mem[Read_addr_2];
        end
      end
      else begin
        if(RF_write && (Read_addr_1 == write_addr) && (Read_addr_1 != 0) && (write_addr != 0) && (!(Istall||Dstall)))
          Read_data_1 <= write_data;
        if(RF_write && (Read_addr_2 == write_addr) && (Read_addr_2 != 0) && (write_addr != 0) && (!(Istall||Dstall)))
          Read_data_2 <= write_data;
      end
    end
  end

endmodule

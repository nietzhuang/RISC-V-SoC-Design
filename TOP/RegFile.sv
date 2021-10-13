`include "define.sv"

module RegFile(
  input                                 clk,
  input                                 rst,
  input         [4:0]                   Read_addr_1,
  input         [4:0]                   Read_addr_2,
  input         [4:0]                   write_addr,
  input         [`data_size-1:0]        write_data,
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
    end
    else begin
      if(!flag_stall)begin
        if(RF_write && (!flag_stall) && (write_addr != 0))  //!!  stall signal might be cancelled.
          mem[write_addr] <= write_data;
      end
    end
  end

  always_comb begin
    if(RF_write && (Read_addr_1 == write_addr) && (Read_addr_1 != 0) && (write_addr != 0) && (!flag_stall))
      Read_data_1 = write_data;
    else if(RF_read && (!flag_stall))
      Read_data_1 = mem[Read_addr_1];
    else
      Read_data_1 = `data_size'b0;
  end

  always_comb begin
    if(RF_write && (Read_addr_2 == write_addr) && (Read_addr_2 != 0) && (write_addr != 0) && (!flag_stall))
      Read_data_2 = write_data;
    else if(RF_read && (!flag_stall))
      Read_data_2 = mem[Read_addr_2];
    else
      Read_data_2 = `data_size'b0;
  end

endmodule

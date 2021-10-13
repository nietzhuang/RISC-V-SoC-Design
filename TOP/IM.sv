`include "define.sv"

module IM(
    input clk,
    input rst,
    input IM_write,
    input IM_enable,
    input [`data_size-1:0] IM_in,
    input [`addr_size-1:0] IM_address,
    output logic [`data_size-1:0] IM_out
);

  logic [`data_size-1:0] mem_data [0:`mem_size-1];
    
  integer i;

  always_ff@(posedge clk, posedge rst)begin
    if(rst)begin
      for(i = 0 ; i < `mem_size ; i = i + 1)begin
        mem_data[i] <= 32'd0 ;
      end
	    IM_out <= 32'd0;
    end
    else if(IM_enable)begin
	    if(IM_write) // write at positive edge clock
	    	mem_data[IM_address] <= IM_in;
      else // !IM_write
        IM_out <= mem_data[IM_address] ;
    end
  end
  
endmodule

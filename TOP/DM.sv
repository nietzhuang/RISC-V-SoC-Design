`include "define.sv"

module DM(
  input clk,
  input rst,
  input DM_write,
  input DM_enable,
  input [`data_size-1:0] DM_in,
  input [`addr_size-1:0] DM_address,

  output logic [`data_size-1:0] DM_out
);

  logic [`data_size-1:0] mem_data [0:`mem_size-1]; 
	
  integer i ;

  always_ff@(posedge clk, posedge rst)begin  // write at positive edge clock
  	if(rst)begin
  		for(i = 0 ; i < `mem_size ; i = i + 1)begin
	  		mem_data[i] <= 0 ;
	  	end
	  	DM_out <= 0 ;
  	end
  	else if(DM_enable)begin
      if(DM_write)
        mem_data[DM_address] <= DM_in;
      else
        DM_out <= mem_data[DM_address];
    end
    else
      DM_out <= 32'd0;
  end
  endmodule

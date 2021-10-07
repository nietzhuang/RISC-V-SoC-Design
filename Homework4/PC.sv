`include "define.sv"

module PC(
  input [`data_size-1:0] PC_in_pdt,
  input clk,
  input rst,
  input [6:0] opcode_EXE,
  input [6:0] opcode_MEM,
  input jump_sel,
  input taken_sel,
  input Istall,  // stall from cache
  input Dstall,
  input hit,
    
  output logic [`data_size-1:0] PC_address,
  output logic Icache_en
);

  always_ff@(posedge clk)begin
    if(rst)begin
      PC_address <= 32'h0fff_fffc;
      Icache_en <= 1'b0;
    end
    else if((opcode_EXE == `Btype) && (opcode_MEM == `Stype) && ( (jump_sel && (!(taken_sel)) ) || ( (!(jump_sel)) && taken_sel ) ) )begin
  // cosider the 1110 || 1101
      if(!(Istall||Dstall))begin
        PC_address <= PC_in_pdt;
        Icache_en <= 1'b1;
      end
      else
        Icache_en <= 1'b0;
    end
//    else if( (!(stall || stall_DM_en)) )begin
    else if(!(Istall||Dstall))begin
      PC_address <= PC_in_pdt;
      Icache_en <= 1'b1;
    end
    else 
      Icache_en <= 1'b0;
  end
endmodule

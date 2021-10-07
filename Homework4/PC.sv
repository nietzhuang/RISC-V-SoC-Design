`include "define.sv"

module PC(
  input                                 clk,
  input                                 rst,
  input         [`data_size-1:0]        PC_in_pred,
  //input         [6:0]                   opcode_ID_EXE,
  //input         [6:0]                   opcode_EXE_MEM,
  //input                                 jump_sel,
  //input                                 taken_sel,
  input                                 Istall,
  input                                 Dstall,
  //input                                 hit,

  output logic  [`data_size-1:0]        PC_address,
  output logic                          Icache_en
);

  always_ff@(posedge clk)begin
    if(rst)begin
      PC_address <= 32'h0fff_fffc;
      Icache_en <= 1'b0;
    end
    else if(!(Istall||Dstall))begin
        PC_address <= PC_in_pred;
        Icache_en <= 1'b1;
    end
    else
        Icache_en <= 1'b0;
  end

endmodule

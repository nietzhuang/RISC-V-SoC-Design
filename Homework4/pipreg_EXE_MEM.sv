`include "define.sv"

module pipreg_EXE_MEM(
  input                                 clk,
  input                                 rst,
  input         [`data_size-1:0]        PC_added_ID_EXE,
  input         [4:0]                   Read_addr_2_ID_EXE,
  input         [4:0]                   write_addr_ID_EXE,
  input         [`data_size-1:0]        alu_result,
  input         [`data_size-1:0]        Read_data_sw,
  input         [6:0]                   opcode_ID_EXE,
  input         [2:0]                   funct3_ID_EXE,
  input         [2:0]                   MEM_ctr_ID_EXE,
  input         [2:0]                   WB_ctr_ID_EXE,
  input                                 Istall,
  input                                 Dstall,

  output logic  [`data_size-1:0]        PC_added_EXE_MEM,
  output logic  [4:0]                   Read_addr_2_EXE_MEM,
  output logic  [4:0]                   write_addr_EXE_MEM,
  output logic  [`data_size-1:0]        alu_result_EXE_MEM,
  output logic  [`data_size-1:0]        D_address,
  output logic  [`data_size-1:0]        Read_data_2_EXE_MEM,
  output logic  [6:0]                   opcode_EXE_MEM,
  output logic  [2:0]                   funct3_EXE_MEM,
  output logic                          Dcache_en,
  output logic                          Dcache_write,
  output logic  [2:0]                   WB_ctr_EXE_MEM
);

  logic                                 flag_stall;


  assign flag_stall = Istall || Dstall;

  always_ff@(posedge clk, posedge rst)begin
    if(rst)begin
      PC_added_EXE_MEM              <= 32'b0;
      Read_addr_2_EXE_MEM           <= 5'd0;
      write_addr_EXE_MEM            <= 5'b0;
      alu_result_EXE_MEM            <= 32'b0;
      D_address                     <= 32'b0;
      Read_data_2_EXE_MEM           <= 32'b0;
      opcode_EXE_MEM                <= 7'd0;
      funct3_EXE_MEM                <= 3'd0;
      {Dcache_write, Dcache_en}     <= 2'b0;
      WB_ctr_EXE_MEM                <= 3'b0;
    end
    else if(!flag_stall)begin
      PC_added_EXE_MEM              <= PC_added_ID_EXE;
      Read_addr_2_EXE_MEM           <= Read_addr_2_ID_EXE;
      write_addr_EXE_MEM            <= write_addr_ID_EXE;
      alu_result_EXE_MEM            <= alu_result;
      D_address                     <= alu_result;
      Read_data_2_EXE_MEM           <= Read_data_sw;
      opcode_EXE_MEM                <= opcode_ID_EXE;
      funct3_EXE_MEM                <= funct3_ID_EXE;
      {Dcache_write, Dcache_en}     <= MEM_ctr_ID_EXE[1:0];
      WB_ctr_EXE_MEM                <= WB_ctr_ID_EXE;
    end
    else
      Dcache_en                     <= 1'b0;
  end

endmodule

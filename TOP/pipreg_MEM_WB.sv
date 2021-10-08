`include "define.sv"

module pipreg_MEM_WB(
  input                                 clk,
  input                                 rst,
  input         [`data_size-1:0]        PC_added_EXE_MEM,
  input         [4:0]                   write_addr_EXE_MEM,
  input         [`data_size-1:0]        alu_result_EXE_MEM,
  input         [`data_size-1:0]        Dcache_out_ext,
  input         [2:0]                   WB_ctr_EXE_MEM,
  input                                 Istall,
  input                                 Dstall,

  output logic  [`data_size-1:0]        PC_added_MEM_WB,
  output logic  [4:0]                   write_addr,
  output logic                          RF_write,
  output logic  [`data_size-1:0]        alu_result_MEM_WB,
  output logic  [`data_size-1:0]        Dcache_out_MEM_WB,
  output logic                          lw_select,
  output logic                          jal_sel
);

  logic                                 flag_stall;


  assign flag_stall = Istall || Dstall;

  always_ff@(posedge clk, posedge rst)begin
    if(rst)begin
      PC_added_MEM_WB       <= 32'b0;
      write_addr            <= 5'b0;
      RF_write              <= 1'b0;
      alu_result_MEM_WB     <= 32'b0;
      Dcache_out_MEM_WB     <= 32'b0;
      lw_select             <= 1'b0;
      jal_sel               <= 1'b0;
    end
    else if(!flag_stall)begin
      PC_added_MEM_WB       <= PC_added_EXE_MEM;
      write_addr            <= write_addr_EXE_MEM;
      RF_write              <= WB_ctr_EXE_MEM[1];
      alu_result_MEM_WB     <= alu_result_EXE_MEM;
      Dcache_out_MEM_WB     <= Dcache_out_ext;
      lw_select             <= WB_ctr_EXE_MEM[0];
      jal_sel               <= WB_ctr_EXE_MEM[2];
    end
  end

endmodule

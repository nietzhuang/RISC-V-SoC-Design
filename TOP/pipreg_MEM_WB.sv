`include "define.sv"

module pipreg_MEM_WB(
  input                                 clk,
  input                                 rst,
  input         [`data_size-1:0]        PC_added_MEM,
  input         [4:0]                   write_addr_MEM,
  input         [`data_size-1:0]        alu_result_MEM,
  input         [`data_size-1:0]        Dcache_out_ext,
  input         [2:0]                   WB_ctr_EXE_MEM,
  input                                 Istall,
  input                                 Dstall,
  input									wfi_stall,

  output logic  [`data_size-1:0]        PC_added_WB,
  output logic  [4:0]                   write_addr,
  output logic                          RF_write_WB,
  output logic  [`data_size-1:0]        alu_result_WB,
  output logic  [`data_size-1:0]        Dcache_out_WB,
  output logic                          lw_select,
  output logic                          jal_sel
);

  logic                                 flag_stall;


  assign flag_stall = Istall || Dstall || wfi_stall;

  always_ff@(posedge clk, posedge rst)begin
    if(rst)begin
      PC_added_WB       <= 32'b0;
      write_addr        <= 5'b0;
      RF_write_WB       <= 1'b0;
      alu_result_WB     <= 32'b0;
      Dcache_out_WB     <= 32'b0;
      lw_select         <= 1'b0;
      jal_sel           <= 1'b0;
    end
    else if(!flag_stall)begin
      PC_added_WB       <= PC_added_MEM;
      write_addr        <= write_addr_MEM;
      RF_write_WB       <= WB_ctr_EXE_MEM[1];
      alu_result_WB     <= alu_result_MEM;
      Dcache_out_WB     <= Dcache_out_ext;
      lw_select         <= WB_ctr_EXE_MEM[0];
      jal_sel           <= WB_ctr_EXE_MEM[2];
    end
  end

endmodule

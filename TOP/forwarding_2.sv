// deal with the SW and lw hazard
`include "define.sv"

module forwarding_2(
  input         [4:0]       write_addr,
  input         [4:0]       Read_addr_2_MEM,
  input                     Dcache_write,
  input                     RF_write_WB,
  input         [6:0]       opcode_MEM,

  output logic              D_in_sel
);

  logic                     dcache_hazard_MEM;


  assign dcache_hazard_MEM = ((opcode_MEM == `Stype)||(opcode_MEM == 7'b0000011)) && Dcache_write && (write_addr == Read_addr_2_MEM) && (write_addr != 5'd0) && RF_write_WB;

  always_comb begin
    if(dcache_hazard_MEM)
      D_in_sel = 1'b1;
    else
      D_in_sel = 1'b0;  // without forwarding
  end

endmodule

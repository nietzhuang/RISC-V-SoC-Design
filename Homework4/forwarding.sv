`include "define.sv"

module forwarding(
  input         [4:0]       write_addr_EXE_MEM,
  input         [4:0]       write_addr,
  input         [4:0]       Read_addr_1_ID_EXE,
  input         [4:0]       Read_addr_2_ID_EXE,
  input                     RF_write,  // the RF_write from WB stage
  input                     RF_write_EXE_MEM,  // the RF_write from MEM stage WB_ctr_b[1]
  input         [6:0]       opcode_ID_EXE,
  input         [6:0]       opcode_EXE_MEM,
  input                     Dcache_en,
  input                     Dcache_write,

  output logic  [1:0]       rs_sel,
  output logic  [1:0]       rt_sel,
  output logic              sw_data_sel
);

  logic                     rs_hazard_EXE;
  logic                     rs_hazard_MEM;
  logic                     rs_hazard_WB;
  logic                     rt_hazard_EXE;
  logic                     rt_hazard_MEM;
  logic                     rt_hazard_WB;


  assign rs_hazard_EXE  = (opcode_EXE_MEM == `Load) && (!Dcache_write) && (write_addr_EXE_MEM == Read_addr_1_ID_EXE) && (RF_write_EXE_MEM) && (write_addr_EXE_MEM != 5'b0);
  assign rs_hazard_MEM  = (write_addr_EXE_MEM == Read_addr_1_ID_EXE) && (RF_write_EXE_MEM) && (write_addr_EXE_MEM != 5'b0);
  assign rs_hazard_WB   = (write_addr == Read_addr_1_ID_EXE) && (RF_write) && (write_addr != 5'b0);
  assign rt_hazard_EXE  = (opcode_EXE_MEM == `Load) && (!Dcache_write) && (write_addr_EXE_MEM == Read_addr_2_ID_EXE) && (RF_write_EXE_MEM) && (write_addr_EXE_MEM != 5'b0);
  assign rt_hazard_MEM  = (write_addr_EXE_MEM == Read_addr_2_ID_EXE) && (RF_write_EXE_MEM) && (write_addr_EXE_MEM != 5'b0);
  assign rt_hazard_WB   = (write_addr == Read_addr_2_ID_EXE) && (RF_write) && (write_addr != 5'b0);

  always_comb begin
    priority if(rs_hazard_EXE)
      rs_sel = 2'b11;
    else if(rs_hazard_MEM) // Rs MEM hazard
      rs_sel = 2'b01;
    else if(rs_hazard_WB) // Rs WB hazard
      rs_sel = 2'b10; // select write_data
    else
      rs_sel = 2'b00;
  end


  always_comb begin
    if((opcode_ID_EXE != `Itype ) && (opcode_ID_EXE != `Stype) && (opcode_ID_EXE != 7'b0000_011) && (opcode_ID_EXE != `Utype))begin // avoid selecting wrong imm.
      priority if(rt_hazard_EXE)
        rt_sel = 2'b11;
      else if(rt_hazard_MEM)
        rt_sel = 2'b01;
      else if(rt_hazard_WB)
        rt_sel = 2'b10;
      else
        rt_sel = 2'b00;
    end
    else if(opcode_ID_EXE == `Stype)begin
      priority if((Dcache_en) && (!Dcache_write) && (write_addr_EXE_MEM == Read_addr_2_ID_EXE) && (RF_write_EXE_MEM) && (write_addr_EXE_MEM != 5'b0))
        rt_sel = 2'b11;
      else
        rt_sel = 2'b00;
    end
    else
      rt_sel = 2'b00;
  end

  always_comb begin  // condition that load wrong rt data when executing SW, wire the right data to mux_sw_data (i.e. DM_in_a)
    if(opcode_ID_EXE == `Stype)begin
      if(write_addr == Read_addr_2_ID_EXE)
        sw_data_sel = 1'b1;
      else
        sw_data_sel = 1'b0;
    end
    else
      sw_data_sel = 1'b0;
  end
  
endmodule

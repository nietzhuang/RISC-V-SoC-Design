`include "AHB_def.svh"
`include "define.sv"
`include "PC.sv"
`include "PC_adder.sv"
`include "controller.sv"
`include "RegFile.sv"
`include "ALU.sv"
`include "imm_generator.sv"
`include "pipreg_IF_ID.sv"
`include "pipreg_ID_EXE.sv"
`include "pipreg_EXE_MEM.sv"
`include "pipreg_MEM_WB.sv"
`include "mux_imm.sv"
`include "mux_jal.sv"
`include "mux_lw.sv"
`include "mux_utype.sv"
`include "forwarding.sv"
`include "mux_rs.sv"
`include "mux_rt.sv"
`include "mux_sw_data.sv"
`include "forwarding_2.sv"
`include "mux_D_in.sv"
`include "queue.sv"
`include "predict.sv"
`include "mux_pdt.sv"
`include "mux_jalr.sv"
`include "mux_asipc.sv"
`include "load_extension.sv"
`include "valid_array.sv"
`include "mux_DO.sv"
`include "Icache.sv"
`include "Dcache.sv"
`include "M_wra.sv"

module CPU(
  input                                     clk,
  input                                     rst,

  // Inputs from AHB BUS.
  input                                     HGRANT_M1,
  input                                     HGRANT_M2,
  input         [`AHB_DATA_BITS-1:0]        HRDATA,
  input                                     HREADY,
  input         [`AHB_RESP_BITS-1:0]        HRESP,

  // Outputs to AHB BUS.
  output logic  [`AHB_ADDR_BITS-1:0]        HADDR_M1,
  output logic  [`AHB_ADDR_BITS-1:0]        HADDR_M2,
  output logic                              HBUSREQ_M1,
  output logic                              HBUSREQ_M2,
  output logic  [`AHB_SIZE_BITS-1:0]        HSIZE_M1,
  output logic  [`AHB_SIZE_BITS-1:0]        HSIZE_M2,
  output logic  [`AHB_TRANS_BITS-1:0]       HTRANS_M1,
  output logic  [`AHB_TRANS_BITS-1:0]       HTRANS_M2,
  output logic                              HLOCK_M1,
  output logic                              HLOCK_M2,
  output logic  [`AHB_DATA_BITS-1:0]        HWDATA_M1,
  output logic  [`AHB_DATA_BITS-1:0]        HWDATA_M2,
  output logic                              HWRITE_M1,
  output logic                              HWRITE_M2
);

  // Program counter.
  logic [`data_size-1:0]                    PC_in;
  logic [`data_size-1:0]                    PC_added_IF_ID;
  logic [`data_size-1:0]                    PC_added_ID_EXE;
  logic [`data_size-1:0]                    PC_added_EXE_MEM;
  logic [`data_size-1:0]                    PC_added_MEM_WB;
  logic [`data_size-1:0]                    PC_imm;
  logic [`data_size-1:0]                    PC_in_pred;
  logic [`data_size-1:0]                    PC_jump;
  logic [`data_size-1:0]                    PC_jump_jalr;
  logic [`data_size-1:0]                    PC_imm_que;
  logic [`data_size-1:0]                    PC_address;
  // Instruction information.
  logic [`data_size-1:0]                    Icache_out;
  logic [`data_size-1:0]                    instruction;
  logic [6:0]                               opcode_ID_EXE;
  logic [6:0]                               opcode_EXE_MEM;
  logic [6:0]                               funct7;
  logic [2:0]                               funct3_ID_EXE;
  logic [2:0]                               funct3_EXE_MEM;
  // Address to general purpose registers (GPRs).
  logic [4:0]                               Read_addr_1_IF_ID;
  logic [4:0]                               Read_addr_2_IF_ID;
  logic [4:0]                               write_addr_IF_ID;
  logic [4:0]                               Read_addr_1_ID_EXE;
  logic [4:0]                               Read_addr_2_ID_EXE;
  logic [4:0]                               write_addr_ID_EXE;
  logic [4:0]                               Read_addr_2_EXE_MEM;
  logic [4:0]                               write_addr_EXE_MEM;
  logic [4:0]                               write_addr;
  // Read and write data for GPRs.
  logic                                     RF_en;
  logic                                     RF_read;
  logic                                     RF_write;
  logic [`data_size-1:0]                    Read_data_1;
  logic [`data_size-1:0]                    Read_data_1_EXE_MEM;
  logic [`data_size-1:0]                    Read_data_2;
  logic [`data_size-1:0]                    Read_data_2_u;
  logic [`data_size-1:0]                    Read_data_sw;
  logic [`data_size-1:0]                    Read_data_2_EXE_MEM;
  logic [`data_size-1:0]                    write_data;
  logic [`data_size-1:0]                    write_data_lw;
  // Memories
  logic                                     IM_enable;
  logic [`data_size-1:0]                    IM_address;
  logic [`data_size-1:0]                    IM_out;
  logic                                     ready;
  logic                                     DM_enable;
  logic [`data_size-1:0]                    DM_address;
  logic [`data_size-1:0]                    DM_out;
  logic                                     DM_write;
  // Caches
  logic                                     Icache_en;
  logic                                     hit;
  logic                                     address_rst;
  logic                                     Istall;
  logic                                     Dcache_en;
  logic [`data_size-1:0]                    D_address;
  logic [`data_size-1:0]                    Dcache_in;
  logic [`data_size-1:0]                    Dcache_out;
  logic [`data_size-1:0]                    Dcache_out_MEM_WB;
  logic [`data_size-1:0]                    Dcache_out_ext;
  logic                                     Dcache_write;
  logic                                     Dstall;
  // Immediate data
  logic [`data_size-1:0]                    imm;
  logic [`data_size-1:0]                    imm_in;
  logic [`data_size-1:0]                    imm_ID_EXE;
  logic [`data_size-1:0]                    imm_out;
  // ALU
  logic                                     alu_en_IF_ID;
  logic                                     alu_en_ID_EXE;
  logic [`data_size-1:0]                    src1;
  logic [`data_size-1:0]                    src2;
  logic [`data_size-1:0]                    alu_result;
  logic [`data_size-1:0]                    alu_result_EXE_MEM;
  logic [`data_size-1:0]                    alu_result_MEM_WB;
  // Other control signals.
  logic [2:0]                               MEM_ctr;
  logic [2:0]                               MEM_ctr_ID_EXE;
  logic [2:0]                               WB_ctr;
  logic [2:0]                               WB_ctr_ID_EXE;
  logic [2:0]                               WB_ctr_EXE_MEM;
  logic                                     flush;
  logic                                     flush_jalr;
  logic                                     stall_Dcount;
  // Other select signals.
  logic [1:0]                               rs_sel;
  logic [1:0]                               rt_sel;
  logic                                     imm_select;
  logic                                     imm_select_ID_EXE;
  logic                                     lw_select;
  logic                                     jump_sel;
  logic                                     utype_sel;
  logic                                     utype_sel_ID_EXE;
  logic                                     jal_sel;
  logic                                     taken_sel;
  logic                                     D_in_sel;
  logic                                     asipc_sel;
  logic                                     sw_data_sel;
  logic                                     asipc_sel_ID_EXE;


  PC PC0(
        .clk(clk),
        .rst(rst),
        .PC_in_pred(PC_in_pred),
        .opcode_ID_EXE(opcode_ID_EXE),
        .opcode_EXE_MEM(opcode_EXE_MEM),
        .jump_sel(jump_sel),
        .taken_sel(taken_sel),
        .Istall(Istall),
        .Dstall(Dstall),
        .hit(hit),

        .PC_address(PC_address),
        .Icache_en(Icache_en)
        );

  PC_adder PC_adder(
        .PC_address(PC_address),
        .PC_added_b(PC_added_ID_EXE),
        .imm_EXE(imm_ID_EXE),

        .PC_in(PC_in),
        .PC_jump(PC_jump)
        );

  pipreg_IF_ID pip_if_id(
        .clk(clk),
        .rst(rst),
        .address_rst(address_rst),
        .PC_in(PC_in),
        .Icache_out(Icache_out),  // Instruction read from icache.
        .Istall(Istall),
        .Dstall(Dstall),
        .flush(flush),
        .flush_jalr(flush_jalr),

        .PC_added_a(PC_added_IF_ID),
        .instruction(instruction),
        .Read_addr_1(Read_addr_1_IF_ID),
        .Read_addr_2(Read_addr_2_IF_ID),
        .write_addr_IF_ID(write_addr_IF_ID),
        .imm_in(imm_in)
       );
  pipreg_ID_EXE pip_id_exe(
        .clk(clk),
        .rst(rst),
        .PC_added_a(PC_added_IF_ID),
        .instruction(instruction),
        .Read_addr_1(Read_addr_1_IF_ID),
        .Read_addr_2(Read_addr_2_IF_ID),
        .write_addr_IF_ID(write_addr_IF_ID),
        .imm(imm),
        .WB_ctr(WB_ctr),
        .MEM_ctr(MEM_ctr),
        .imm_select(imm_select),
        .alu_en(alu_en_IF_ID),
        .utype_sel(utype_sel),
        .asipc_sel(asipc_sel),
        .Istall(Istall),
        .Dstall(Dstall),
        .flush(flush),
        .flush_jalr(flush_jalr),

        .PC_added_b(PC_added_ID_EXE),
        .opcode_EXE(opcode_ID_EXE),
        .funct3_EXE(funct3_ID_EXE),
        .funct7(funct7),
        .Read_addr_1_ID_EXE(Read_addr_1_ID_EXE),
        .Read_addr_2_ID_EXE(Read_addr_2_ID_EXE),
        .write_addr_ID_EXE(write_addr_ID_EXE),
        .imm_EXE(imm_ID_EXE),
        .WB_ctr_a(WB_ctr_ID_EXE),
        .MEM_ctr_a(MEM_ctr_ID_EXE),
        .imm_select_a(imm_select_ID_EXE),
        .alu_en_a(alu_en_ID_EXE),
        .utype_sel_a(utype_sel_ID_EXE),
        .asipc_sel_EXE(asipc_sel_ID_EXE)
        );

  pipreg_EXE_MEM pip_exe_mem(
        .clk(clk),
        .rst(rst),
        .PC_added_b(PC_added_ID_EXE),
        .Read_addr_2_ID_EXE(Read_addr_2_ID_EXE),
        .write_addr_ID_EXE(write_addr_ID_EXE),
        .alu_result(alu_result),
        .Read_data_sw(Read_data_sw),
        .opcode_EXE(opcode_ID_EXE),
        .funct3_EXE(funct3_ID_EXE),
        .MEM_ctr_a(MEM_ctr_ID_EXE),
        .WB_ctr_a(WB_ctr_ID_EXE),
        .Istall(Istall),
        .Dstall(Dstall),

        .PC_added_c(PC_added_EXE_MEM),
        .Read_addr_2_EXE_MEM(Read_addr_2_EXE_MEM),
        .write_addr_EXE_MEM(write_addr_EXE_MEM),
        .alu_result_EXE_MEM(alu_result_EXE_MEM),
        .D_address(D_address),
        .Read_data_2_MEM(Read_data_2_EXE_MEM),
        .opcode_MEM(opcode_EXE_MEM),
        .funct3_MEM(funct3_EXE_MEM),
        .Dcache_en(Dcache_en),
        .Dcache_write(Dcache_write),
        .WB_ctr_b(WB_ctr_EXE_MEM)
        );

  pipreg_MEM_WB pip_mem_wb(
        .clk(clk),
        .rst(rst),
        .PC_added_c(PC_added_EXE_MEM),
        .write_addr_EXE_MEM(write_addr_EXE_MEM),
        .alu_result_EXE_MEM(alu_result_EXE_MEM),
        .Dcache_out_ext(Dcache_out_ext),
        .WB_ctr_b(WB_ctr_EXE_MEM),
        .Istall(Istall),
        .Dstall(Dstall),

        .PC_added_d(PC_added_MEM_WB),
        .write_addr(write_addr),
        .RF_write(RF_write),
        .alu_result_MEM_WB(alu_result_MEM_WB),
        .Dcache_out_WB(Dcache_out_MEM_WB),
        .lw_select(lw_select),
        .jal_sel(jal_sel)
        );

  mux_imm mux_imm(
        .a(Read_data_2),
        .b(imm_ID_EXE),
        .select(imm_select_ID_EXE),
        .y(imm_out)
        );

  mux_lw mux_lw(
        .a(Dcache_out_MEM_WB),
        .b(alu_result_MEM_WB),
        .select(lw_select),
        .y(write_data_lw)
        );

  mux_utype mux_utype(
        .a(Read_data_2),
        .b(src2),
        .select(utype_sel_ID_EXE),
        .y(Read_data_2_u)
        );

  mux_jal mux_jal(
        .a(write_data_lw),
        .b(PC_added_MEM_WB),
        .select(jal_sel),
        .y(write_data)
        );

  controller ctr(  // control signals decoder.
        .instruction(instruction),
        .RF_en(RF_en),
        .WB_ctr(WB_ctr),
        .MEM_ctr(MEM_ctr),
        .RF_read(RF_read),
        .imm_select(imm_select),
        .alu_en(alu_en_IF_ID),
        .utype_sel(utype_sel),
        .asipc_sel(asipc_sel)
        );

  RegFile RF0(
        .clk(clk),
        .rst(rst),
        .Read_addr_1(Read_addr_1_IF_ID),
        .Read_addr_2(Read_addr_2_IF_ID),
        .write_addr(write_addr),
        .write_data(write_data),
        .Read_data_1(Read_data_1),
        .Read_data_2(Read_data_2),
        .RF_en(RF_en),
        .RF_write(RF_write),
        .RF_read(RF_read),
        .Istall(Istall),
        .Dstall(Dstall)
        );

  ALU ALU0(
        .src1(src1),
        .src2(src2),
        .opcode_EXE(opcode_ID_EXE),
        .funct7(funct7),
        .funct3_EXE(funct3_ID_EXE),
        .branch(MEM_ctr_ID_EXE[2]), // branch from EXE
        .enable(alu_en_ID_EXE),
        .alu_result(alu_result),
        .jump_sel(jump_sel)
        );

  imm_generator imm0(
        .imm_in(imm_in),
        .imm(imm)
        );

  load_extension load_ext(
        .Dcache_out(Dcache_out),
        .opcode_MEM(opcode_EXE_MEM),
        .funct3_MEM(funct3_EXE_MEM),

        .Dcache_out_ext(Dcache_out_ext)
        );

  forwarding fwd0(
        .write_addr_EXE_MEM(write_addr_EXE_MEM),
        .write_addr(write_addr),
        .Read_addr_1_ID_EXE(Read_addr_1_ID_EXE),
        .Read_addr_2_ID_EXE(Read_addr_2_ID_EXE),
        .RF_write(RF_write),
        .RF_write_MEM(WB_ctr_EXE_MEM[1]),
        .opcode_EXE(opcode_ID_EXE),
        .opcode_MEM(opcode_EXE_MEM),
        .Dcache_en(Dcache_en),
        .Dcache_write(Dcache_write),

        .rs_sel(rs_sel),
        .rt_sel(rt_sel),
        .sw_data_sel(sw_data_sel)
        );

  forwarding_2 fwd1(
        .write_addr(write_addr),
        .Read_addr_2_EXE_MEM(Read_addr_2_EXE_MEM),
        .Dcache_write(Dcache_write),
        .RF_write(RF_write),
        .opcode_MEM(opcode_EXE_MEM),

        .D_in_sel(D_in_sel)
        );

  mux_rs mux_rs(
        .Read_data_1_EXE(Read_data_1_EXE_MEM),
        .alu_result_EXE_MEM(alu_result_EXE_MEM),
        .write_data(write_data),
        .Dcache_out_ext(Dcache_out_ext),
        .rs_sel(rs_sel),

        .src1(src1)
        );

  mux_rt mux_rt(
        .imm_out(imm_out),
        .alu_result_EXE_MEM(alu_result_EXE_MEM),
        .write_data(write_data),
        .Dcache_out_ext(Dcache_out_ext),
        .rt_sel(rt_sel),

        .src2(src2)
        );

  mux_sw_data mux_sw_data(
        .Read_data_2_a2(Read_data_2_u), // output from mux_utype
        .write_data(write_data),
        .sw_data_sel(sw_data_sel),

        .Read_data_sw(Read_data_sw)
        );

  mux_D_in mux_D_in(
        .Read_data_2_MEM(Read_data_2_EXE_MEM),
        .write_data(write_data),
        .D_in_sel(D_in_sel),

        .Dcache_in(Dcache_in)
        );

  queue queue(
        .clk(clk),
        .rst(rst),
        .PC_in(PC_in),
        .opcode_IF(Icache_out[6:0]), // from stage IF
        .opcode_ID(instruction[6:0]),
        .imm_IM_31_25(Icache_out[31:25]),
        .imm_IM_24_12(Icache_out[24:12]),
        .imm_IM_11_7(Icache_out[11:7]),
        .taken_sel(taken_sel),
        .Istall(Istall),
        .Dstall(Dstall),

        .PC_imm_que(PC_imm_que),
        .PC_imm(PC_imm)
        );

  predict pred(
        .clk(clk),
        .rst(rst),
        .opcode_EXE(opcode_ID_EXE),
        .jump_sel(jump_sel),
        .Istall(Istall),
        .Dstall(Dstall),
        .taken_sel(taken_sel)
        );

  mux_pdt mux_pred(
        .PC_in(PC_in),
        .PC_imm_que(PC_imm_que),
        .PC_imm(PC_imm),
        .opcode_EXE(opcode_ID_EXE),
        .opcode_IF(Icache_out[6:0]),
        .taken_sel(taken_sel),
        .jump_sel(jump_sel),
        .Istall(Istall),
        .Dstall(Dstall),

        .PC_in_pdt(PC_in_pred),
        .flush(flush)
        );

  mux_jalr mux_jalr(
        .PC_jump(PC_jump),
        .alu_result(alu_result),
        .opcode_EXE(opcode_ID_EXE),

        .PC_jump_jalr(PC_jump_jalr),
        .flush_jalr(flush_jalr)
        );
  mux_asipc mux_asipc(
        .PC_added_ID(PC_added_ID_EXE),
        .Read_data_1(Read_data_1),
        .asipc_sel(asipc_sel_ID_EXE),
        .Read_data_1_EXE(Read_data_1_EXE_MEM)
        );

  Icache Icache(
        .clk(clk),
        .rst(rst),
        .address(PC_address),
        .Icache_en(Icache_en),
        .ready(ready),  // from Master wrapper.
        .stall_Dcount(stall_Dcount),
        .IM_out(IM_out),  //!!! DataIn

        .IM_enable(IM_enable),
        .IM_address(IM_address),
        .data(Icache_out),  //!!! DataOut
        .Istall(Istall),  // stall by icache
        .hit(hit),
        .address_rst(address_rst)
        );

  Dcache Dcache(
        .clk(clk),
        .rst(rst),
        .address(D_address), // wire to alu_result
        .Dcache_en(Dcache_en),
        .Dcache_write(Dcache_write),
        .Dcache_in(Dcache_in),
        .ready(ready),
        .DM_out(DM_out),  //!! DataIn
        .funct3_MEM(funct3_EXE_MEM),

        .DM_address(DM_address),
        .DM_enable(DM_enable),
        .data(Dcache_out),  //!!  DataOut
        .DM_write(DM_write),
        .Dstall(Dstall),
        .stall_Dcount(stall_Dcount) // to Icache
        );

  M_wra M_wrapper0(
        .clk(clk),
        .rst(rst),

         // Inputs from M1 and M2.
        .IM_enable(IM_enable),
        .IM_address(IM_address),
        .DM_enable(DM_enable),
        .DM_address(DM_address),
        .DM_in(Dcache_out),
        .DM_write(DM_write),
        // Inputs from AHB BUS.
        .HGRANT_M1(HGRANT_M1),
        .HGRANT_M2(HGRANT_M2),
        .HRDATA(HRDATA),
        .HREADY(HREADY),
        .HRESP(HRESP),

        // Outputs to M1 and M2.
        .IM_out(IM_out),
        .DM_out(DM_out),
        .ready(ready),
        // Outputs to AHB BUS.
        .HADDR_M1(HADDR_M1),
        .HADDR_M2(HADDR_M2),
        .HBUSREQ_M1(HBUSREQ_M1),
        .HBUSREQ_M2(HBUSREQ_M2),
        .HSIZE_M1(HSIZE_M1),
        .HSIZE_M2(HSIZE_M2),
        .HTRANS_M1(HTRANS_M1),
        .HTRANS_M2(HTRANS_M2),
        .HLOCK_M1(HLOCK_M1),
        .HLOCK_M2(HLOCK_M2),
        .HWDATA_M1(HWDATA_M1),
        .HWDATA_M2(HWDATA_M2),
        .HWRITE_M1(HWRITE_M1),
        .HWRITE_M2(HWRITE_M2)
        );

endmodule

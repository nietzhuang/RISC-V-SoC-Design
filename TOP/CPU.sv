`include "AHB_def.svh"
`include "define.sv"
`include "PC.sv"
`include "PC_adder.sv"
`include "controller.sv"
`include "RegFile.sv"
`include "CSR.sv"
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
`include "forwarding_csr.sv"
`include "mux_rs.sv"
`include "mux_rt.sv"
`include "mux_csr_imm.sv"
`include "mux_csr_result.sv"
`include "mux_sw_data.sv"
`include "forwarding_2.sv"
`include "mux_D_in.sv"
`include "queue.sv"
`include "predict.sv"
`include "mux_pred.sv"
`include "mux_jalr.sv"
`include "mux_asipc.sv"
`include "load_extension.sv"
`include "valid_array.sv"
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
  input                                     interrupt,  // wire to sensor interrupt directly.

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
  output logic                              HWRITE_M2,
  output logic  [63:0]                      L1I_access,
  output logic  [63:0]                      L1I_miss,
  output logic  [63:0]                      L1D_access,
  output logic  [63:0]                      L1D_miss
);

  // Program counter.
  logic [`data_size-1:0]                    PC_added;
  logic [`data_size-1:0]                    PC_added_ID;
  logic [`data_size-1:0]                    PC_added_EXE;
  logic [`data_size-1:0]                    PC_added_MEM;
  logic [`data_size-1:0]                    PC_added_WB;
  logic [`data_size-1:0]                    PC_imm;
  logic [`data_size-1:0]                    PC_in_pred;
  logic [`data_size-1:0]                    PC_jump;
  logic [`data_size-1:0]                    PC_jump_jalr;
  logic [`data_size-1:0]                    PC_imm_que;
  logic [`data_size-1:0]                    PC_address;
  // Instruction information.
  logic [`data_size-1:0]                    Icache_out;
  logic [`data_size-1:0]                    instruction;
  logic [6:0]                               opcode_EXE;
  logic [6:0]                               opcode_MEM;
  logic [6:0]                               funct7;
  logic [2:0]                               funct3_EXE;
  logic [2:0]                               funct3_MEM;
  // Address to general purpose registers (GPRs).
  logic [4:0]                               Read_addr_1_ID;
  logic [4:0]                               Read_addr_2_ID;
  logic [4:0]                               write_addr_ID;
  logic [4:0]                               Read_addr_1_EXE;
  logic [4:0]                               Read_addr_2_EXE;
  logic [4:0]                               write_addr_EXE;
  logic [4:0]                               Read_addr_2_MEM;
  logic [4:0]                               write_addr_MEM;
  logic [4:0]                               write_addr;
  // Read and write data for GPRs.
  logic                                     RF_read;
  logic                                     RF_write_WB;
  logic [`data_size-1:0]                    Read_data_1;
  logic [`data_size-1:0]                    Read_data_1_EXE;
  logic [`data_size-1:0]                    Read_data_1_EXE_asipc;
  logic [`data_size-1:0]                    Read_data_2;
  logic [`data_size-1:0]                    Read_data_2_EXE;
  logic [`data_size-1:0]                    Read_data_2_EXE_u;
  logic [`data_size-1:0]                    Read_data_sw_EXE;
  logic [`data_size-1:0]                    Read_data_2_MEM;
  logic [`data_size-1:0]                    write_data;
  logic [`data_size-1:0]                    write_data_lw;
  // CSR
  logic                                     csr_read;
  logic                                     csr_write;
  logic                                     csr_write_EXE;
  logic [`csr_addr_size-1:0]                csr_addr_ID;
  logic [11:0]                              csr_addr_EXE;
  logic [`data_size-1:0]                    csr_read_data;
  logic [`data_size-1:0]                    csr_read_data_EXE;
  logic [`data_size-1:0]                    csr_write_tmp;
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
  logic [`data_size-1:0]                    Dcache_out_WB;
  logic [`data_size-1:0]                    Dcache_out_ext;
  logic                                     Dcache_write;
  logic                                     Dstall;
  // Immediate data
  logic [`data_size-1:0]                    imm;
  logic [`data_size-1:0]                    imm_in;
  logic [`data_size-1:0]                    imm_EXE;
  logic [`data_size-1:0]                    imm_out;
  // ALU
  logic                                     alu_en_ID;
  logic                                     alu_en_EXE;
  logic [`data_size-1:0]                    src1;
  logic [`data_size-1:0]                    src2;
  logic [`data_size-1:0]                    alu_result_tmp;
  logic [`data_size-1:0]                    alu_result;
  logic [`data_size-1:0]                    alu_result_MEM;
  logic [`data_size-1:0]                    alu_result_WB;
  // Other control signals.
  logic [2:0]                               MEM_ctr;
  logic [2:0]                               MEM_ctr_ID_EXE;
  logic [2:0]                               WB_ctr;
  logic [2:0]                               WB_ctr_ID_EXE;
  logic [2:0]                               WB_ctr_EXE_MEM;
  logic                                     flush;
  logic                                     flush_jalr;
  logic                                     stall_Dcount;
  logic										wfi_stall;
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
  logic [1:0]                               csr_imm_sel;
  logic [1:0]                               csr_imm_sel_EXE;
  logic                                     csr_data_sel;
  logic                                     csr_result_sel;
  logic                                     csr_result_sel_EXE;
  logic                                     sw_data_sel;
  logic                                     asipc_sel_ID_EXE;
  logic										flag_mret;


  PC PC(
        .clk(clk),
        .rst(rst),
        .PC_in_pred(PC_in_pred),
		.mepc(csr_read_data),
        .jump_sel(jump_sel),
        .taken_sel(taken_sel),
        .Istall(Istall),
        .Dstall(Dstall),
		.wfi_stall(wfi_stall),
		.interrupt(interrupt),
		.flag_mret(flag_mret),
//        .hit(hit),

        .PC_address(PC_address),
        .Icache_en(Icache_en)
        );

  PC_adder PC_adder(
        .PC_address(PC_address),
        .PC_added_EXE(PC_added_EXE),
        .imm_EXE(imm_EXE),

        .PC_added(PC_added),
        .PC_jump(PC_jump)
        );

  pipreg_IF_ID pip_if_id(
        .clk(clk),
        .rst(rst),
        .address_rst(address_rst),
        .PC_added(PC_added),
        .Icache_out(Icache_out),  // Instruction read from icache.
        .Istall(Istall),
        .Dstall(Dstall),
		.wfi_stall(wfi_stall),
        .flush(flush),
        .flush_jalr(flush_jalr),

        .PC_added_ID(PC_added_ID),
        .instruction(instruction),
        .Read_addr_1_ID(Read_addr_1_ID),
        .Read_addr_2_ID(Read_addr_2_ID),
        .write_addr_ID(write_addr_ID),
        .csr_addr_ID(csr_addr_ID),
        .imm_in(imm_in)
       );

  pipreg_ID_EXE pip_id_exe(
        .clk(clk),
        .rst(rst),
        .PC_added_ID(PC_added_ID),
        .instruction(instruction),
        .Read_addr_1_ID(Read_addr_1_ID),
        .Read_addr_2_ID(Read_addr_2_ID),
        .Read_data_1(Read_data_1),
        .Read_data_2(Read_data_2),
        .write_addr_ID(write_addr_ID),
        .csr_addr_ID(csr_addr_ID),
        .csr_read_data(csr_read_data),
        .imm(imm),
        .MEM_ctr(MEM_ctr),
        .WB_ctr(WB_ctr),
        .csr_write(csr_write),
        .imm_select(imm_select),
        .alu_en_ID(alu_en_ID),
        .utype_sel(utype_sel),
        .asipc_sel(asipc_sel),
        .csr_imm_sel(csr_imm_sel),
        .csr_result_sel(csr_result_sel),
        .Istall(Istall),
        .Dstall(Dstall),
		.wfi_stall(wfi_stall),
        .flush(flush),
        .flush_jalr(flush_jalr),

        .PC_added_EXE(PC_added_EXE),
        .opcode_EXE(opcode_EXE),
        .funct3_EXE(funct3_EXE),
        .funct7(funct7),
        .Read_addr_1_EXE(Read_addr_1_EXE),
        .Read_addr_2_EXE(Read_addr_2_EXE),
        .Read_data_1_EXE(Read_data_1_EXE),
        .Read_data_2_EXE(Read_data_2_EXE),
        .write_addr_EXE(write_addr_EXE),
        .csr_addr_EXE(csr_addr_EXE),
        .csr_read_data_EXE(csr_read_data_EXE),
        .imm_EXE(imm_EXE),
        .MEM_ctr_ID_EXE(MEM_ctr_ID_EXE),
        .WB_ctr_ID_EXE(WB_ctr_ID_EXE),
        .csr_write_EXE(csr_write_EXE),
        .imm_select_ID_EXE(imm_select_ID_EXE),
        .alu_en_EXE(alu_en_EXE),
        .utype_sel_ID_EXE(utype_sel_ID_EXE),
        .asipc_sel_ID_EXE(asipc_sel_ID_EXE),
        .csr_imm_sel_EXE(csr_imm_sel_EXE),
        .csr_result_sel_EXE(csr_result_sel_EXE)
        );

  pipreg_EXE_MEM pip_exe_mem(
        .clk(clk),
        .rst(rst),
        .PC_added_EXE(PC_added_EXE),
        .Read_addr_2_EXE(Read_addr_2_EXE),
        .write_addr_EXE(write_addr_EXE),
        .alu_result(alu_result),
        .Read_data_sw_EXE(Read_data_sw_EXE),
        .opcode_EXE(opcode_EXE),
        .funct3_EXE(funct3_EXE),
        .MEM_ctr_ID_EXE(MEM_ctr_ID_EXE),
        .WB_ctr_ID_EXE(WB_ctr_ID_EXE),
        .Istall(Istall),
        .Dstall(Dstall),
		.wfi_stall(wfi_stall),

        .PC_added_MEM(PC_added_MEM),
        .Read_addr_2_MEM(Read_addr_2_MEM),
        .write_addr_MEM(write_addr_MEM),
        .alu_result_MEM(alu_result_MEM),
        .D_address(D_address),
        .Read_data_2_MEM(Read_data_2_MEM),
        .opcode_MEM(opcode_MEM),
        .funct3_MEM(funct3_MEM),
        .Dcache_en(Dcache_en),
        .Dcache_write(Dcache_write),
        .WB_ctr_EXE_MEM(WB_ctr_EXE_MEM)
        );

  pipreg_MEM_WB pip_mem_wb(
        .clk(clk),
        .rst(rst),
        .PC_added_MEM(PC_added_MEM),
        .write_addr_MEM(write_addr_MEM),
        .alu_result_MEM(alu_result_MEM),
        .Dcache_out_ext(Dcache_out_ext),
        .WB_ctr_EXE_MEM(WB_ctr_EXE_MEM),
        .Istall(Istall),
        .Dstall(Dstall),
		.wfi_stall(wfi_stall),

        .PC_added_WB(PC_added_WB),
        .write_addr(write_addr),
        .RF_write_WB(RF_write_WB),
        .alu_result_WB(alu_result_WB),
        .Dcache_out_WB(Dcache_out_WB),
        .lw_select(lw_select),
        .jal_sel(jal_sel)
        );

  mux_imm mux_imm(
        .a(Read_data_2_EXE),
        .b(imm_EXE),
        .select(imm_select_ID_EXE),
        .y(imm_out)
        );

  mux_lw mux_lw(
        .a(Dcache_out_WB),
        .b(alu_result_WB),
        .select(lw_select),
        .y(write_data_lw)
        );

  mux_utype mux_utype(
        .a(Read_data_2_EXE),
        .b(src2),
        .select(utype_sel_ID_EXE),
        .y(Read_data_2_EXE_u)
        );

  mux_jal mux_jal(
        .a(write_data_lw),
        .b(PC_added_WB),
        .select(jal_sel),
        .y(write_data)
        );

  controller ctr(  // control signals decoder.
        .instruction(instruction),
        .MEM_ctr(MEM_ctr),
        .WB_ctr(WB_ctr),
        .RF_read(RF_read),
        .csr_read(csr_read),
        .csr_write(csr_write),
        .imm_select(imm_select),
        .alu_en(alu_en_ID),
        .utype_sel(utype_sel),
        .asipc_sel(asipc_sel),
        .csr_imm_sel(csr_imm_sel),
        .csr_result_sel(csr_result_sel),
		.wfi_stall(wfi_stall),
		.flag_mret(flag_mret)
        );

  RegFile RF(
        .clk(clk),
        .rst(rst),
        .Read_addr_1(Read_addr_1_ID),
        .Read_addr_2(Read_addr_2_ID),
        .write_addr(write_addr),
        .write_data(write_data),
        .Read_data_1(Read_data_1),
        .Read_data_2(Read_data_2),
        .RF_write(RF_write_WB),
        .RF_read(RF_read),
        .Istall(Istall),
        .Dstall(Dstall),
		.wfi_stall(wfi_stall)
        );

  CSR CSR(  // Considering data hazard, it should write at EXE statge.
        .clk(clk),
        .rst(rst),
        .funct3(funct3_EXE),
        .PC_address(PC_address),
        .csr_read_addr(csr_addr_ID),
        .csr_write_addr(csr_addr_EXE),
        .csr_write_tmp(csr_write_tmp),  // from EXE statge.
        .csr_read_data_EXE(csr_read_data_EXE),
        .csr_read(csr_read),
        .csr_write(csr_write_EXE),
        .csr_data_sel(csr_data_sel),
        .Istall(Istall),
        .Dstall(Dstall),
		//.wfi_stall(wfi_stall),
        .csr_read_data(csr_read_data),
        .interrupt(interrupt)
        );

  ALU ALU(
        .src1(src1),
        .src2(src2),
        .opcode_EXE(opcode_EXE),
        .funct7(funct7),
        .funct3_EXE(funct3_EXE),
        .branch(MEM_ctr_ID_EXE[2]),  // branch from EXE
        .enable(alu_en_EXE),
        .alu_result(alu_result_tmp),
        .jump_sel(jump_sel)
        );

  mux_csr_result mux_csr_result(
        .alu_result_tmp(alu_result_tmp),
        .csr_read_data_EXE(csr_read_data_EXE),
        .csr_result_sel_EXE(csr_result_sel_EXE),
        .alu_result(alu_result)
        );

  imm_generator imm0(
        .imm_in(imm_in),
        .imm(imm)
        );

  load_extension load_ext(
        .Dcache_out(Dcache_out),
        .opcode_MEM(opcode_MEM),
        .funct3_MEM(funct3_MEM),

        .Dcache_out_ext(Dcache_out_ext)
        );

  forwarding fwd0(
        .write_addr_MEM(write_addr_MEM),
        .write_addr(write_addr),
        .Read_addr_1_EXE(Read_addr_1_EXE),
        .Read_addr_2_EXE(Read_addr_2_EXE),
        .RF_write_WB(RF_write_WB),
        .RF_write_MEM(WB_ctr_EXE_MEM[1]),
        .opcode_EXE(opcode_EXE),
        .opcode_MEM(opcode_MEM),
        .Dcache_en(Dcache_en),
        .Dcache_write(Dcache_write),

        .rs_sel(rs_sel),
        .rt_sel(rt_sel),
        .sw_data_sel(sw_data_sel)
        );

  forwarding_2 fwd1(
        .write_addr(write_addr),
        .Read_addr_2_MEM(Read_addr_2_MEM),
        .Dcache_write(Dcache_write),
        .RF_write_WB(RF_write_WB),
        .opcode_MEM(opcode_MEM),

        .D_in_sel(D_in_sel)
        );

  forwarding_csr fwd_csr(
        .csr_read_addr(csr_addr_ID),
        .csr_write_addr(csr_addr_EXE),

        .csr_data_sel(csr_data_sel)
        );

  mux_csr_imm mux_csr_imm(
        .src1(src1),
        .imm_EXE(imm_EXE),
		.PC_added_EXE(PC_added_EXE),
        .csr_imm_sel_EXE(csr_imm_sel_EXE),

        .csr_write_tmp(csr_write_tmp)
        );

  mux_rs mux_rs(
        .Read_data_1_EXE_asipc(Read_data_1_EXE_asipc),
        .alu_result_MEM(alu_result_MEM),
        .write_data(write_data),
        .Dcache_out_ext(Dcache_out_ext),
        .rs_sel(rs_sel),

        .src1(src1)
        );

  mux_rt mux_rt(
        .imm_out(imm_out),
        .alu_result_MEM(alu_result_MEM),
        .write_data(write_data),
        .Dcache_out_ext(Dcache_out_ext),
        .rt_sel(rt_sel),

        .src2(src2)
        );

  mux_sw_data mux_sw_data(
        .Read_data_2_EXE_u(Read_data_2_EXE_u), // output from mux_utype
        .write_data(write_data),
        .sw_data_sel(sw_data_sel),

        .Read_data_sw_EXE(Read_data_sw_EXE)
        );

  mux_D_in mux_D_in(
        .Read_data_2_MEM(Read_data_2_MEM),
        .write_data(write_data),
        .D_in_sel(D_in_sel),

        .Dcache_in(Dcache_in)
        );

  queue queue(
        .clk(clk),
        .rst(rst),
        .PC_added(PC_added),
        .opcode_IF(Icache_out[6:0]), // from stage IF
        .opcode_ID(instruction[6:0]),
        .imm_IM_31_25(Icache_out[31:25]),
        .imm_IM_24_12(Icache_out[24:12]),
        .imm_IM_11_7(Icache_out[11:7]),
        .taken_sel(taken_sel),
        .Istall(Istall),
        .Dstall(Dstall),
		.wfi_stall(wfi_stall),

        .PC_imm(PC_imm),
        .PC_imm_que(PC_imm_que)
        );

  predict pred(
        .clk(clk),
        .rst(rst),
        .opcode_EXE(opcode_EXE),
        .jump_sel(jump_sel),
        .Istall(Istall),
        .Dstall(Dstall),
		.wfi_stall(wfi_stall),
        .taken_sel(taken_sel)
        );

  mux_pred mux_pred(
        .PC_added(PC_added),
        .PC_imm_que(PC_imm_que),
        .PC_imm(PC_imm),
        .opcode_EXE(opcode_EXE),
        .opcode_IF(Icache_out[6:0]),
        .taken_sel(taken_sel),
        .jump_sel(jump_sel),
        .Istall(Istall),
        .Dstall(Dstall),

        .PC_in_pred(PC_in_pred),
        .flush(flush)
        );

  mux_jalr mux_jalr(
        .PC_jump(PC_jump),
        .alu_result(alu_result),
        .opcode_EXE(opcode_EXE),

        .PC_jump_jalr(PC_jump_jalr),
        .flush_jalr(flush_jalr)
        );

  mux_asipc mux_asipc(
        .PC_added_EXE(PC_added_EXE),
        .Read_data_1_EXE(Read_data_1_EXE),
        .asipc_sel(asipc_sel_ID_EXE),
        .Read_data_1_EXE_asipc(Read_data_1_EXE_asipc)  //!! might be renamed.
        );

  Icache Icache(
        .clk(clk),
        .rst(rst),
        .address(PC_address),
        .Icache_en(Icache_en),
        .ready(ready),  // from Master wrapper.
        .stall_Dcount(stall_Dcount),
		.wfi_stall(wfi_stall),
        .DataIn(IM_out),

        .IM_enable(IM_enable),
        .IM_address(IM_address),
        .DataOut(Icache_out),
        .Istall(Istall),  // stall by icache
        .hit(hit),
        .address_rst(address_rst),
        .L1I_access(L1I_access),
        .L1I_miss(L1I_miss)
        );

  Dcache Dcache(  //!!!  Maybe it needs wfi_stall.
        .clk(clk),
        .rst(rst),
        .address(D_address),  // wire to alu_result
        .Dcache_en(Dcache_en),
        .Dcache_write(Dcache_write),
        .Dcache_in(Dcache_in),
        .ready(ready),
        .DataIn(DM_out),
        .funct3_MEM(funct3_MEM),

        .DM_address(DM_address),
        .DM_enable(DM_enable),
        .DataOut(Dcache_out),
        .DM_write(DM_write),
        .Dstall(Dstall),
        .stall_Dcount(stall_Dcount),  // to Icache
        .L1D_access(L1D_access),
        .L1D_miss(L1D_miss)
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

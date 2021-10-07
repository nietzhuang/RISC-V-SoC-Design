`include "define.sv"

module pipreg_ID_EXE(
    input                                   clk,
    input                                   rst,
    input           [`data_size-1:0]        PC_added_IF_ID,
    input           [`data_size-1:0]        instruction,
    input           [4:0]                   Read_addr_1_IF_ID,
    input           [4:0]                   Read_addr_2_IF_ID,
    input           [4:0]                   write_addr_IF_ID,
    input           [`data_size-1:0]        imm,
    input           [2:0]                   WB_ctr,
    input           [2:0]                   MEM_ctr,
    input                                   imm_select,
    input                                   alu_en_IF_ID,
    input                                   utype_sel,
    input                                   asipc_sel,
    input                                   Istall,
    input                                   Dstall,
    input                                   flush,
    input                                   flush_jalr,

    output logic    [`data_size-1:0]        PC_added_ID_EXE
    output logic    [6:0]                   opcode_ID_EXE,
    output logic    [2:0]                   funct3_ID_EXE,
    output logic    [6:0]                   funct7,
    output logic    [4:0]                   Read_addr_1_ID_EXE,
    output logic    [4:0]                   Read_addr_2_ID_EXE,
    output logic    [4:0]                   write_addr_ID_EXE,
    output logic    [`data_size-1:0]        imm_ID_EXE,
    output logic    [2:0]                   WB_ctr_ID_EXE,
    output logic    [2:0]                   MEM_ctr_ID_EXE,
    output logic                            imm_select_ID_EXE,
    output logic                            alu_en_ID_EXE,
    output logic                            utype_sel_ID_EXE,
    output logic                            asipc_sel_ID_EXE,
);

  logic                                     flag_stall;
  logic                                     flag_flush;


  assign flag_stall = Istall || Dstall;
  assign flag_flush = flush || flush_jalr;

  always_ff@(posedge clk, posedge rst)begin
    if(rst)begin
      PC_added_ID_EXE                       <= 32'b0;
      opcode_ID_EXE                         <= 7'd0;
      funct3_ID_EXE                         <= 3'd0;
      funct7                                <= 7'd0;
      Read_addr_1_ID_EXE                    <= 5'b0;
      Read_addr_2_ID_EXE                    <= 5'b0;
      write_addr_ID_EXE                     <= 5'b0;
      imm_ID_EXE                            <= 32'b0;
      WB_ctr_ID_EXE                         <= 3'b0;
      MEM_ctr_ID_EXE                        <= 3'b0;
      {imm_select_ID_ExE, alu_en_ID_EXE}    <= 2'b0;
      utype_sel_ID_EXE                      <= 1'b0;
      asipc_sel_ID_EXE                      <= 1'b0;
    end
    else if(!flag_stall)begin
      if(!flag_flush)begin
        PC_added_ID_EXE                     <= PC_added_IF_ID;
        opcode_ID_EXE                       <= instruction[6:0];
        funct3_ID_EXE                       <= instruction[14:12];
        funct7                              <= instruction[31:25];
        Read_addr_1_ID_EXE                  <= Read_addr_1_IF_ID;
        Read_addr_2_ID_EXE                  <= Read_addr_2_IF_ID;
        write_addr_ID_EXE                   <= write_addr_IF_ID;
        imm_ID_EXE                          <= imm;
        WB_ctr_ID_EXE                       <= WB_ctr;
        MEM_ctr_ID_EXE                      <= MEM_ctr;
        {imm_select_ID_EXE, alu_en_ID_EXE}  <= {imm_select, alu_en_IF_ID};
        utype_sel_ID_EXE                    <= utype_sel;
        asipc_sel_ID_EXE                    <= asipc_sel;
      end
      else begin
        PC_added_ID_EXE                     <= 32'b0;
        opcode_ID_EXE                       <= 7'd0;
        funct3_ID_EXE                       <= 3'd0;
        funct7                              <= 7'd0;
        Read_addr_1_ID_EXE                  <= 5'b0;
        Read_addr_2_ID_EXE                  <= 5'b0;
        write_addr_ID_EXE                   <= 5'b0;
        imm_ID_EXE                          <= 32'h00000013;
        WB_ctr_ID_EXE                       <= 3'b0;
        MEM_ctr_ID_EXE                      <= 3'b0;
        {imm_select_ID_EXE, alu_en_ID_EXE}  <= 2'b0;
        utype_sel_ID_EXE                    <= 1'b0;
        asipc_sel_ID_EXE                    <= 1'b0;
      end

    end
  end
endmodule

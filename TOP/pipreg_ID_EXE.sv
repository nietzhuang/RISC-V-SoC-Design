`include "define.sv"

module pipreg_ID_EXE(
    input                                   clk,
    input                                   rst,
    input           [`data_size-1:0]        PC_added_ID,
    input           [`data_size-1:0]        instruction,
    input           [4:0]                   Read_addr_1_ID,
    input           [4:0]                   Read_addr_2_ID,
    input           [`data_size-1:0]        Read_data_1,
    input           [`data_size-1:0]        Read_data_2,
    input           [4:0]                   write_addr_ID,
    input           [11:0]                  csr_addr_ID,
    input           [`data_size-1:0]        csr_read_data,
    input           [`data_size-1:0]        imm,
    input           [2:0]                   WB_ctr,
    input           [2:0]                   MEM_ctr,
    input                                   csr_write,
    input                                   imm_select,
    input                                   alu_en_ID,
    input                                   utype_sel,
    input                                   asipc_sel,
    input                                   csr_imm_sel,
    input                                   csr_result_sel,
    input                                   Istall,
    input                                   Dstall,
    input                                   flush,
    input                                   flush_jalr,

    output logic    [`data_size-1:0]        PC_added_EXE,
    output logic    [6:0]                   opcode_EXE,
    output logic    [2:0]                   funct3_EXE,
    output logic    [6:0]                   funct7,
    output logic    [4:0]                   Read_addr_1_EXE,
    output logic    [4:0]                   Read_addr_2_EXE,
    output logic    [`data_size-1:0]        Read_data_1_EXE,
    output logic    [`data_size-1:0]        Read_data_2_EXE,
    output logic    [4:0]                   write_addr_EXE,
    output logic    [`csr_addr_size-1:0]    csr_addr_EXE,
    output logic    [`data_size-1:0]        csr_read_data_EXE,
    output logic    [`data_size-1:0]        imm_EXE,
    output logic    [2:0]                   WB_ctr_ID_EXE,
    output logic    [2:0]                   MEM_ctr_ID_EXE,
    output logic                            csr_write_EXE,
    output logic                            imm_select_ID_EXE,
    output logic                            alu_en_EXE,
    output logic                            utype_sel_ID_EXE,
    output logic                            asipc_sel_ID_EXE,
    output logic                            csr_imm_sel_EXE,
    output logic                            csr_result_sel_EXE
);

  logic                                     flag_stall;
  logic                                     flag_flush;


  assign flag_stall = Istall || Dstall;
  assign flag_flush = flush || flush_jalr;

  always_ff@(posedge clk, posedge rst)begin
    if(rst)begin
      PC_added_EXE                       <= 32'b0;
      opcode_EXE                         <= 7'd0;
      funct3_EXE                         <= 3'd0;
      funct7                             <= 7'd0;
      Read_addr_1_EXE                    <= 5'b0;
      Read_addr_2_EXE                    <= 5'b0;
      Read_data_1_EXE                    <= `data_size'b0;
      Read_data_2_EXE                    <= `data_size'b0;
      write_addr_EXE                     <= 5'b0;
      csr_addr_EXE                       <= 12'b0;
      csr_read_data_EXE                  <= 32'b0;
      imm_EXE                            <= 32'b0;
      WB_ctr_ID_EXE                      <= 3'b0;
      MEM_ctr_ID_EXE                     <= 3'b0;
      csr_write_EXE                      <= 1'b0;
      {imm_select_ID_EXE, alu_en_EXE}    <= 2'b0;
      utype_sel_ID_EXE                   <= 1'b0;
      asipc_sel_ID_EXE                   <= 1'b0;
      csr_imm_sel_EXE                    <= 1'b0;
      csr_result_sel_EXE                 <= 1'b0;
    end
    else if(!flag_stall)begin
      if(!flag_flush)begin
        PC_added_EXE                     <= PC_added_ID;
        opcode_EXE                       <= instruction[6:0];
        funct3_EXE                       <= instruction[14:12];
        funct7                           <= instruction[31:25];
        Read_addr_1_EXE                  <= Read_addr_1_ID;
        Read_addr_2_EXE                  <= Read_addr_2_ID;
        Read_data_1_EXE                  <= Read_data_1;
        Read_data_2_EXE                  <= Read_data_2;
        write_addr_EXE                   <= write_addr_ID;
        csr_addr_EXE                     <= csr_addr_ID;
        csr_read_data_EXE                <= csr_read_data;
        imm_EXE                          <= imm;
        WB_ctr_ID_EXE                    <= WB_ctr;
        MEM_ctr_ID_EXE                   <= MEM_ctr;
        csr_write_EXE                    <= csr_write;
        {imm_select_ID_EXE, alu_en_EXE}  <= {imm_select, alu_en_ID};
        utype_sel_ID_EXE                 <= utype_sel;
        asipc_sel_ID_EXE                 <= asipc_sel;
        csr_imm_sel_EXE                  <= csr_imm_sel;
        csr_result_sel_EXE               <= csr_result_sel;
      end
      else begin
        PC_added_EXE                     <= 32'b0;
        opcode_EXE                       <= 7'd0;
        funct3_EXE                       <= 3'd0;
        funct7                           <= 7'd0;
        Read_addr_1_EXE                  <= 5'b0;
        Read_addr_2_EXE                  <= 5'b0;
        Read_data_1_EXE                  <= `data_size'b0;
        Read_data_2_EXE                  <= `data_size'b0;
        write_addr_EXE                   <= 5'b0;
        csr_addr_EXE                     <= 12'b0;
        csr_read_data_EXE                <= 32'b0;
        imm_EXE                          <= 32'h00000013;
        WB_ctr_ID_EXE                    <= 3'b0;
        MEM_ctr_ID_EXE                   <= 3'b0;
        csr_write_EXE                    <= 1'b0;
        {imm_select_ID_EXE, alu_en_EXE}  <= 2'b0;
        utype_sel_ID_EXE                 <= 1'b0;
        asipc_sel_ID_EXE                 <= 1'b0;
        csr_imm_sel_EXE                  <= 1'b0;
        csr_result_sel_EXE               <= 1'b0;
      end
    end
  end

endmodule

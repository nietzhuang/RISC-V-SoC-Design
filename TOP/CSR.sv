`include "define.sv"

module CSR(
  input                                 clk,
  input                                 rst,
  input         [`data_size-1:0]        PC_address,
  input         [`csr_addr-1:0]         csr_addr,
  input         [`data_size-1:0]        csr_write_data,
  input                                 csr_en,
  input                                 csr_write,
  input                                 csr_read,
  input                                 Istall,
  input                                 Dstall,

  output logic  [`data_size-1:0]        csr_read_data
  output logic                          MEIP;
);

  logic     [`data_size-1:0]            mstatus;
  logic     [`data_size-1:0]            mie;
  logic     [`data_size-1:0]            mtvec;
  logic     [`data_size-1:0]            mepc;
  logic     [`data_size-1:0]            mip;
  logic     [`data_size-1:0]            mcycle;
  logic     [`data_size-1:0]            minstreth;
  //logic     [`data_size-1:0]            mstatus_int, mie_int, mtvec_int, mepc_int, mip_int, mcycle_int, minstret_int, mcycleh_int, minstreth_int;


  assign flag_stall = Istall || Dstall;
  assign MEIP = mip[11];

  always_ff@(posedge clk, posedge rst)begin // write
    if(rst)begin
      mstatus      <= `data_size'd0;
      mie          <= `data_size'd0;
      mtvec        <= `data_size'd0;
      mepc         <= `data_size'd0;
      mip          <= `data_size'd0;
      mcycle       <= `data_size'd0;
      minstret     <= `data_size'd0;
      mcycleh      <= `data_size'd0;
      minstreth    <= `data_size'd0;
    end
    else begin
      if(csr_en && (!flag_stall)begin
        if(csr_write)begin
          case(csr_addr)  // use case, because it only has 9 CSRs.
          12'h300: mstatus     <= csr_write_data;
          12'h304: mie         <= csr_write_data;
          12'h305: mtvec       <= csr_write_data;
          12'h341: mepc        <= csr_write_data;
          12'h344: mip         <= csr_write_data;
          12'hB00: mcycle      <= csr_write_data;
          12'hB02: minstret    <= csr_write_data;
          12'hB80: mcycleh     <= csr_write_data;
          12'hB82: minstreth   <= csr_write_data;
          endcase
        end

        if(csr_read)begin
          case(csr_addr)
          12'h300: csr_read_data <= mstatus;
          12'h304: csr_read_data <= mie;
          12'h305: csr_read_data <= mtvec;
          12'h341: csr_read_data <= mepc;
          12'h344: csr_read_data <= mip;
          12'hB00: csr_read_data <= mcycle;
          12'hB02: csr_read_data <= minstret;
          12'hB80: csr_read_data <= mcycleh;
          12'hB82: csr_read_data <= minstreth;
          default: csr_read_data <= `data_size'b0;
          endcase
        end
      end
    end
  end

endmodule

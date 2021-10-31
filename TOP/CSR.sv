`include "define.sv"

module CSR(
  input                                 clk,
  input                                 rst,
  input         [2:0]                   funct3,
  input         [`data_size-1:0]        PC_address,
  input         [`csr_addr_size-1:0]    csr_read_addr,
  input         [`csr_addr_size-1:0]    csr_write_addr,
  input         [`data_size-1:0]        csr_write_tmp,
  input         [`data_size-1:0]        csr_read_data_EXE,
  input                                 csr_read,
  input                                 csr_write,
  input                                 csr_data_sel,
  input                                 Istall,
  input                                 Dstall,
//  input									wfi_stall,
  input                                 interrupt,

  output logic  [`data_size-1:0]        csr_read_data
);

  logic     [`data_size-1:0]            mstatus;
  logic     [`data_size-1:0]            mie;
  logic     [`data_size-1:0]            mtvec;
  logic     [`data_size-1:0]            mepc;
  logic     [`data_size-1:0]            mip;
  logic     [`data_size-1:0]            mcycle;
  logic     [`data_size-1:0]            minstret;
  logic     [`data_size-1:0]            mcycleh;
  logic     [`data_size-1:0]            minstreth;
  logic     [`data_size-1:0]            csr_write_data;


  assign flag_stall = Istall || Dstall; //!!!  wfi_stall;  // should ignore wfi_stall.
  // hardwired 0.
  assign {mstatus[31:13], mstatus[10:8], mstatus[6:4], mstatus[2:0]} = {19'b0, 3'b0, 3'b0, 3'b0};
  assign {mie[31:12], mie[10:0]} = {20'b0, 11'b0};
  assign  mip[11]                = interrupt;  // hardwire from sctrl directly.
  assign  mtvec                  = `data_size'h10000000;
  assign {mip[31:12], mip[10:0]} = {20'b0, 11'b0};

  always_comb begin
    if(csr_write)begin
      case(funct3)
      3'b000, 3'b001, 3'b101:  //WFI,  CSRRW, CSRRWI
        csr_write_data = csr_write_tmp;
      3'b010, 3'b110:  // CSRRS, CSRRSI
        csr_write_data = csr_read_data_EXE | csr_write_tmp;
      3'b011, 3'b111:  // CSRRC, CSRRCI
        csr_write_data = csr_read_data_EXE & (~csr_write_tmp);
      default:
        csr_write_data = `data_size'b0;
      endcase
    end
    else
      csr_write_data = `data_size'b0;
  end

  always_ff@(posedge clk, posedge rst)begin  // write
    if(rst)begin
      {mstatus[12:11], mstatus[7], mstatus[3]}      <= 4'b0;
      mie[11]                                       <= 1'b0;
      //mtvec                                       <= `data_size'd0;
      mepc                                          <= `data_size'd0;
      //mip[11]                                       <= `1'b0;
    end
    else begin
      if(csr_write && (!flag_stall))begin
        case(csr_write_addr)  // use case, because it only has 9 CSRs.
        12'h300: {mstatus[12:11], mstatus[7], mstatus[3]} <= {csr_write_data[12:11], csr_write_data[7], csr_write_data[3]};
        12'h304: mie[11]                                  <= csr_write_data[11];
        //12'h305: mtvec                                  <= csr_write_data;
        12'h341, 12'h105: mepc                            <= csr_write_data;  // WFI write PC+4 to mepc.
        //12'h344: mip[11]                                  <= csr_write_data[11];
        endcase
      end
    end
  end

  always_ff@(posedge clk, posedge rst)begin  // Performance CSRs.
    if(rst)begin
      mcycle        <= `data_size'd0;
      mcycleh       <= `data_size'd0;
    end
    else if(mcycle == 32'hFFFFFFFF)begin
      mcycle        <= mcycle + 1;
      mcycleh       <= mcycleh + 1;
    end
    else
      mcycle        <= mcycle + 1;
  end

  always_ff@(posedge clk, posedge rst)begin
    if(rst)begin
      minstret      <= `data_size'hFFFFFFFF;
      minstreth     <= `data_size'hFFFFFFFF;
    end
    else if(minstret == 32'hFFFFFFFF && (!flag_stall))begin
      minstret      <= minstret + 1;
      minstreth     <= minstreth + 1;
    end
    else if(!flag_stall)
      minstret      <= minstret + 1;
  end

  always_comb begin
    if(csr_read)begin
      if(csr_data_sel)  // data hazard.
        case(csr_read_addr)
        12'h300: csr_read_data = {19'b0, csr_write_data[12:11], 3'b0, csr_write_data[7], 3'b0, csr_write_data[3], 3'b0};
        12'h304: csr_read_data = {20'b0, csr_write_data[11], 11'b0};
        12'h305: csr_read_data = `data_size'h10000000;
        12'h341: csr_read_data = csr_write_data;
        //12'h344: csr_read_data = mip;
        12'hB00: csr_read_data = csr_write_data;
        12'hB02: csr_read_data = csr_write_data;
        12'hB80: csr_read_data = csr_write_data;
        12'hB82: csr_read_data = csr_write_data;
        default: csr_read_data = `data_size'b0;
        endcase
      else begin
        case(csr_read_addr)
        12'h300: 		  csr_read_data = mstatus;
        12'h304: 		  csr_read_data = mie;
        12'h305: 		  csr_read_data = mtvec;
        12'h341, 12'h302: csr_read_data = mepc;
        //12'h344: csr_read_data = mip;
        12'hB00: 		  csr_read_data = mcycle;
        12'hB02: 		  csr_read_data = minstret;
        12'hB80: 		  csr_read_data = mcycleh;
        12'hB82: 		  csr_read_data = minstreth;
        default: 		  csr_read_data = `data_size'b0;
        endcase
      end
    end
    else
      csr_read_data = `data_size'b0;
  end

endmodule

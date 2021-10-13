`include "define.sv"

module load_extension(
  input         [`data_size-1:0]        Dcache_out,
  input         [6:0]                   opcode_MEM,
  input         [2:0]                   funct3_MEM,

  output logic  [`data_size-1:0]        Dcache_out_ext
);
  always_comb begin
    if(opcode_MEM == `Load)begin
      case(funct3_MEM)
        3'b000:  // LB
          Dcache_out_ext = {{24{Dcache_out[7]}}, Dcache_out[7:0]};
        3'b001:  // LH
          Dcache_out_ext = {{16{Dcache_out[15]}}, Dcache_out[15:0]};
        3'b100:  // LBU
          Dcache_out_ext = {24'b0, Dcache_out[7:0]};
        3'b101:
          Dcache_out_ext = {16'b0, Dcache_out[15:0]};
        default:  // include LW
          Dcache_out_ext = Dcache_out;
      endcase
    end
    else
      Dcache_out_ext = Dcache_out;
  end

endmodule

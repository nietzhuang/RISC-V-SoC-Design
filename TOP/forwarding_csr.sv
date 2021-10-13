`include "define.sv"

module forwarding_csr(
  input         [`csr_addr_size-1:0]       csr_read_addr,
  input         [`csr_addr_size-1:0]       csr_write_addr,

  output logic                              csr_data_sel
);

  always_comb begin
      if(csr_read_addr == csr_write_addr)
        csr_data_sel = 1'b1;
      else
        csr_data_sel = 1'b0;
  end

endmodule

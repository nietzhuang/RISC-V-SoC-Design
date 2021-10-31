`include "define.sv"

module PC(
  input                                 clk,
  input                                 rst,
  input         [`data_size-1:0]        PC_in_pred,
  input			[`data_size-1:0]		flag_mepc,
  input                                 jump_sel,
  input                                 taken_sel,
  input                                 Istall,
  input                                 Dstall,
  input									wfi_stall,
  input									interrupt,
  input									mret,
  //  input                                 hit,

  output logic  [`data_size-1:0]        PC_address,
  output logic                          Icache_en
);

  logic [`data_size-1:0]		PC_address_tmp;
  logic							flag_stall;


  assign flag_stall = Istall || Dstall || wfi_stall;
  assign PC_address = (flag_mret)? mepc : PC_address_tmp;

  always_ff@(posedge clk)begin
    if(rst)begin
      PC_address_tmp <= 32'h0fff_fffc;
      Icache_en <= 1'b0;
    end
    else if(!flag_stall)begin
   	  if(interrupt)begin
		PC_address_tmp <= 32'h1000_0000;  // jump to ISR address.
		Icache_en <= 1'b1;
	  end
	  else begin
        PC_address_tmp <= PC_in_pred;
        Icache_en <= 1'b1;
	  end
    end
    else
        Icache_en <= 1'b0;
  end

endmodule

`include "define.sv"

module valid_array(
  input                         CK,
  input                         rst,
  input     [`index-1:0]        A,
  input                         CS,
  input                         OE,  // RW

  output logic                  v_bit
);

  logic                         v_idx[63:0];


  always_ff@(posedge CK, posedge rst)begin
    if(rst)begin
      for(int i = 0; i < 64; i++ )
        v_idx[i] <= 1'b0;
    end
    else if(CS)begin
      if(OE)  // read
        v_bit <= v_idx[A];
      else  // write
        v_idx[A] <= 1'b1;
    end
  end
  
endmodule

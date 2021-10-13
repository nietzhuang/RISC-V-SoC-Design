`ifndef DEFINE_SV
`define DEFEIN_SV

`define data_size       32
`define addr_size       32
`define mem_size        65536

`define csr_addr_size   12

`define tag             22
`define index           6
`define offset          4

`define Rtype           'b0110011
`define Itype           'b0010011
`define Load            'b0000011
`define Stype           'b0100011
`define Btype           'b1100011
`define Utype           'b0110111
`define Jtype           'b1101111
`define JALR            'b1100111
`define AUIPC           'b0010111
`define CSR             'b1110011

`define ADD             'b000
`define SLL             'b001
`define SLT             'b010
`define XOR             'b100
`define SRL             'b101  // include SRA
`define OR              'b110
`define AND             'b111
`define SLTU            'b011

`endif

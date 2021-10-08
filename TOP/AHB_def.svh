`ifndef AHB_DEF_SVH
`define AHB_DEF_SVH
// Overall
`define AHB_DATA_BITS       32
`define AHB_ADDR_BITS       32

// Transfer type
`define AHB_TRANS_BITS      2
`define AHB_TRANS_IDLE      `AHB_TRANS_BITS'b00
`define AHB_TRANS_BUSY      `AHB_TRANS_BITS'b01
`define AHB_TRANS_NONSEQ    `AHB_TRANS_BITS'b10
`define AHB_TRANS_SEQ       `AHB_TRANS_BITS'b11

// Burst type
`define AHB_BURST_BITS      3
`define AHB_BURST_SINGLE    `AHB_BURST_BITS'b000
`define AHB_BURST_INCR      `AHB_BURST_BITS'b001
`define AHB_BURST_WRAP4     `AHB_BURST_BITS'b010
`define AHB_BURST_INCR4     `AHB_BURST_BITS'b011
`define AHB_BURST_WRAP8     `AHB_BURST_BITS'b100
`define AHB_BURST_INCR8     `AHB_BURST_BITS'b101
`define AHB_BURST_WRAP16    `AHB_BURST_BITS'b110
`define AHB_BURST_INCR16    `AHB_BURST_BITS'b111

// Size
`define AHB_SIZE_BITS       3
`define AHB_SIZE_BYTE       `AHB_SIZE_BITS'b000
`define AHB_SIZE_HWORD      `AHB_SIZE_BITS'b001
`define AHB_SIZE_WORD       `AHB_SIZE_BITS'b010
`define AHB_SIZE_2WORD      `AHB_SIZE_BITS'b011
`define AHB_SIZE_4WORD      `AHB_SIZE_BITS'b100
`define AHB_SIZE_8WORD      `AHB_SIZE_BITS'b101
`define AHB_SIZE_16WORD     `AHB_SIZE_BITS'b110
`define AHB_SIZE_32WORD     `AHB_SIZE_BITS'b111
 // Protection
`define AHB_PROT_BITS       4

// Response
`define AHB_RESP_BITS       2
`define AHB_RESP_OKAY       `AHB_RESP_BITS'b00
`define AHB_RESP_ERROR      `AHB_RESP_BITS'b01
`define AHB_RESP_RETRY      `AHB_RESP_BITS'b10
`define AHB_RESP_SPLIT      `AHB_RESP_BITS'b11

// Master
`define AHB_MASTER_BITS     4
`define AHB_MASTER_LEN      3
`define AHB_MASTER_0        `AHB_MASTER_BITS'b0000  // Default
`define AHB_MASTER_1        `AHB_MASTER_BITS'b0001
`define AHB_MASTER_2        `AHB_MASTER_BITS'b0010

// Slave
`define AHB_SLAVE_LEN       3
`define AHB_SLAVE_0         `AHB_SLAVE_LEN'b001  // Default
`define AHB_SLAVE_1         `AHB_SLAVE_LEN'b010
`define AHB_SLAVE_2         `AHB_SLAVE_LEN'b100

`endif

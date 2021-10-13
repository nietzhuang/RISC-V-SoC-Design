	.file	"DRAM_main.s"    # replace file name with yours
	.option nopic
	.text
	.align	2
	.globl	main
	.type	main, @function
main:
	#----------------------------#
	#    Write your code here    #
  li sp,0x2003fffc  # Reserve DM[65535] for stop flag
  csrsi mstatus,0x8 # Enable global interrupt
  li t0,0x800 
  csrs mie,t0       # Enable local interrupt
  li t0,0x20000000  # DM start address
  sw zero,0(t0)     # DM[0]: sort_cnt = 0
  sw zero,4(t0)     # DM[1]: copy_cnt = 0
  li t1,0x4
  sw t1,8(t0)       # DM[2]: total_cnt = 4
  addi t1,t0,0x100
  sw t1,12(t0)      # DM[3]: copy_dest = DM[64]
  sw t1,16(t0)      # DM[4]: sort_base = DM[64]
  li t1,0x40
  sw t1,20(t0)      # DM[5]: data_num = 64
  li t1,0x30000100  # sctrl_en
  li t2,0x1         # Enable sensor controller
  sw t2,0(t1)
  auipc t1,0
  addi t1,t1,-80    # Check main program start PC
  sw t1,24(t0)      # DM[6]: Checking PC => 0x1000_1000
waiting: 
  wfi               # Wait for first interrupt
sort_setup:
  addi sp,sp,-8
  sw zero,0(sp)     # iter1 = 0
loop1:
  lw t1,0(sp)       # iter1
  lw t2,20(t0)      # data_num
  beq t1,t2,sort_end
  addi t3,t1,1
  sw t3,4(sp)       # iter2 = iter1 + 1
loop2:
  lw t2,4(sp)       # iter2
  lw t1,20(t0)      # data_num
  beq t2,t1,loop1_incr
  slli t2,t2,2
  lw t3,16(t0)      # sort_base
  add t2,t2,t3
  lw t5,0(t2)       # array[iter2]
  lw t1,0(sp)       # iter1
  slli t1,t1,2
  add t1,t1,t3
  lw t4,0(t1)       # array[iter1]
  ble t4,t5,loop2_incr
  sw t4,0(t2)
  sw t5,0(t1)       # array[iter1] <=> array[iter2]
loop2_incr:
  lw t2,4(sp)       # iter2
  addi t2,t2,1
  sw t2,4(sp)
  j loop2
loop1_incr:
  lw t1,0(sp)       # iter1
  addi t1,t1,1
  sw t1,0(sp)
  j loop1
sort_end:
  addi sp,sp,8
  lw t1,0(t0)       # sort_cnt
  addi t1,t1,1
  sw t1,0(t0)       # Increase sort count
  lw t3,8(t0)       # total_cnt
  beq t1,t3,main_end
  lw t2,16(t0)      # DM[4]: sort_base
  lw t3,20(t0)      # DM[5]: data_num
  slli t3,t3,2
  add t3,t3,t2
  sw t3,16(t0)      # sort_base of next round
  lw t2,4(t0)       # copy_cnt
  beq t1,t2,waiting
  j sort_setup
main_end:
  csrr t1,mcycle
  csrr t2,minstret
  csrr t3,mcycleh
  csrr t4,minstreth
  sw t1,28(t0)      # DM[7] = mcycle
  sw t3,32(t0)      # DM[8] = mcycleh
  sw t2,36(t0)      # DM[9] = minstret
  sw t4,40(t0)      # DM[10] = minstreth
  li t1,0xfffff000
  sw t1,0(sp)       # Enable stop flag
  wfi               # Barrier
	#    Write your code here    #
	#----------------------------#
	.size	main, .-main
	.ident	"GCC: (GNU) 7.1.1 20170509"

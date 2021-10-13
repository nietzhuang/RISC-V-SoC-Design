	.file	"DRAM_isr.s"    # replace file name with yours
	.option nopic
	.text
	.align	2
	.globl	main
	.type	main, @function
main:
	#----------------------------#
	#    Write your code here    #
  addi sp,sp,-16    # Push t0-t3 to stack
  sw t0,0(sp)
  sw t1,4(sp)
  sw t2,8(sp)
  sw t3,12(sp)
  li t0,0x20000000  # DM start address
  li t1,0x30000000  # SC[0]: copy_src
  lw t2,12(t0)      # DM[3]: copy_dest
  lw t3,20(t0)      # DM[5]: data_num
  slli t3,t3,2
  add t3,t3,t2      # copy_dest of next round
copy_sc:
  lw t0,0(t1)       # Load SC[copy_src]
  addi t1,t1,4
  sw t0,0(t2)       # Store to DM[copy_dest]
  addi t2,t2,4
  bne t2,t3,copy_sc
copy_sc_done:
  li t0,0x20000000
  sw t2,12(t0)      # Update DM[3] (copy_dest)
  li t1,0x30000200
  li t3,0x1
  sw t3,0(t1)       # Enable sctrl_clear
  sw zero,0(t1)     # Disable sctrl_clear
  lw t1,4(t0)       # DM[1]: copy_cnt
  addi t1,t1,1
  sw t1,4(t0)       # Increase copy count
  lw t2,8(t0)       # DM[2]: total_cnt
  bne t1,t2,isr_done
  li t2,0x80
  csrc mstatus,t2   # Disable MPIE of mstatus
isr_done:
  lw t0,0(sp)
  lw t1,4(sp) 
  lw t2,8(sp) 
  lw t3,12(sp) 
  addi sp,sp,16
  mret
	#    Write your code here    #
	#----------------------------#
	.size	main, .-main
	.ident	"GCC: (GNU) 7.1.1 20170509"

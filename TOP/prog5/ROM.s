#----------------------------# 
#		Booting Code
#----------------------------# 
lui		x1, 0					# Initiate counter 
lui 	x2, 0x40000 			# DRAM start address DRAM[0]
lui 	x3, 0x10000			    # IM start address IM[0]
addi    x5, x0, 1				# 
slli	x5, x5, 9				# x5 stores 8192
addi 	x6, x0, 0x013   		# x6 stores NOP instruction
loop_move:
lw 		x4, 0(x2)				# 
sw 		x4, 0(x3)				# IM[n] = DRAM[n]
addi	x2, x2, 4
addi	x3, x3, 4	 
addi 	x1, x1, 4
bne 	x1,	x5, loop_move		#
lui 		x5, 40000				# 
fill_nop:
sw		x6, 0(x3)				# IM[n] = NOP
addi	x3, x3, 4		
bne		x3, x5, fill_nop		# Branch when n != 65536	
lui 	x5, 0x10001				# 
jalr	x0, x5, 0x0				# Jump to 0x10001000, notice that jal can't be used as imm[0] is not 0.

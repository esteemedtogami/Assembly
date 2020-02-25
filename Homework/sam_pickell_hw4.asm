
	.data

symTab:	.word		0x20202020:40			# 10 symbol entries

# NULL or 0 in tokArray prematurely terminates dumping
#   tokArray. Use blanks instead of nulls to print correctly
TOKEN:	.word 	0x20202020:3			# 2-word TOKEN & its TYPE
tokArray:	.word		0x20202020:45			# 15 token entries

inBuf:	.space	80
pound:	.byte	'#'				# end an input line with '#'

st_prompt:	.asciiz	"Enter a new input line. \n"
st_error:	.asciiz	"An error has occurred. \n"	
tableHead:	.asciiz 	"  TOKEN        TYPE\n"
st_double_def:  .asciiz "Double definition error! \n"
symTabHead:	.asciiz "	TOKEN		VALUE		STATUS \n"


	
		.text
#######################################################################
#
# Main
#
#	read an input line
#	call scanner driver
#	clear buffers
#
#	  $t3: index to the last entry in symTab
#	  $t9: LOC
#
######################################################################

		li	$t9, 0x0400		# t9: LOC

newline:
		jal	getline		# get a new input string
	
		li	$t5,0			# $t5: index to inBuf
		li	$a3,0			# $a3: index to tokArray

		# State table driver (HW3)
		#  	Global Registers for the scanner
		#	  $t5: index to inBuf in bytes
		#	  $s0: char type, T
		#	  $s1: next state Qx for HW3
		#  	  $s3: index to the new char space in TOKEN
		#  	  $a3: index to tokArray in 12 bytes per entry

		la	$s1, Q0		# initial state Q0
driver:		lw	$s2, 0($s1)		# get the action routine
		jalr	$v1, $s2		# execute the action

		sll	$s0, $s0, 2		# compute byte offset of T
		add	$s1, $s1, $s0		# locate the next state
		la	$s1, ($s1)
		lw	$s1, ($s1)		# next State in $s1
		sra	$s0, $s0, 2		# reset $s0 for T
		b	driver			# go to the next state

		# general symbols from tokArray (HW4)
		#  	Global Registers for the symbol table
		#	  $a3: 	byte index to tokArray
		#	  $s1: 	new Status
		#	  $t3: 	last entry in symTab
genSym:
		lb	$t8, tokArray		# if (tokArray[0][0] == '#')
		beq	$t8, '#', exit		#    goto exit

		li	$a3, 0			# i: reset index to tokArray
		addi	$t0, $a3, 12		# $t0: index i+1
		lb	$t1, tokArray($t0)	# if (tokArray[i+1][0] != ':')
		bne	$t1, ':', operator	#   goto operator

		#
		# label is found
		#
		lw	$a0, tokArray($a3)	# TOKEN = tokArray[0][0] ($a0)
		lw	$a1, tokArray+4($a3)	#   2nd word of TOKEN in $a1
		li	$a2, 1			# DEFN = 1
		jal	VARIABLE		# valVar = VARIABLE(TOKEN, 1)
		addi	$a3, $a3, 24

operator:	addi	$a3, $a3, 12		# i++

		#
		# In HW3, a new token is saved to tokArray
		#  with a 2-word token and 0x2020tt\n, where
		#  tt denotes the token type in ASCII
		# This is to make printing of tokArray simple
		#  so that each tokArray entry terminates with '\n'
		#
		# In HW4, when a token type is checked for type 6 ('#')
		#  or type 2, 10th byte of the token entry in tokArray
		#  has to be checked for ASCII 6 or ASCII 2.
		# 
		li	$t0, 1			# isComma = 1
chkVar:		lb	$t1, tokArray+10($a3)	# $t1 = tokArray[i][1]
		beq	$t1, '6', dump		# if (tokArray[i][1] == 6) goto dump
		bne	$t1, '2', nextVar	# if (tokArray[i][1] !=2 ||
		beqz	$t0, nextVar		#    !isComma) goto nextVar

		#
		# a variable is found in an operand
		#
		lw	$a0, tokArray($a3)	# TOKEN = tokArray[0][0] ($a0)
		lw	$a1, tokArray+4($a3)	#   2nd word of TOKEN in $a1
		li	$a2, 0			# DEFN = 0
		jal	VARIABLE		# valVar = VARIABLE(TOKEN, 0)

		addi	$a3, $a3, 12		# i++
nextVar:	li	$t0, 0			# isComma = 0
		lb	$t1, tokArray($a3)	# $t1 - tokArray{i][0]
		bne	$t1, ',', chkVar	# isComma = tokArray[i][0] == ','
		li	$t0, 1			# isComma = 1
		b	chkVar

dump:
		jal	printline		# echo print input string
		jal	printSymTab		# print symbol Table
	
		jal	clearInBuf		# clear input buffer
		jal	clearTokArray		# clear token array
	
		addi	$t9, $t9, 4		# LOC += 4
		b 	newline

exit:		li	$v0, 10
		syscall


###############################################################
#
#  VARIABLE(TOKEN,DEFN):
#	$a0, $a1: argument TOKEN in two words
#	$a2:	   argument DEFN
#	$..: return value
#
#	Search symTab for the TOKEN
#	Determine the new status of the TOKEN in $s1
#	Call appropriate symACTx according to $s1
#
###############################################################
VARIABLE:
		la	$v0, srchSymTab		# call symTab search
		jalr	$v1, $v0		# $t6: symTab index (symIndex) returned
	
		# determine the new status in $s1
		# if (symIndex < 0)
		blt	$t6, $0, SymLessThanZero
		# else
		lw	$t4, symTab+20($t6)
		add	$t2, $0, $t4
		li	$k1, 0x2
		mult	$t2, $k1		# All of these
		add	$s2, $t2, $0
		li	$t2, 0
		add	$t2, $t4, $0
		li	$k1, 0x1
		mult	$t2, $k1		# put together
		add	$s7, $t2, $0
		sll	$s7, $s7, 1		# should equate to:
		add	$a2, $a2, $s7		# newStatus = oldStatus & 0x2 | ((oldStatus & 0x1) << 1);
		add	$a2, $a2, $a0		# newStatus = newStatus | DEFN;	
		sw	$t4, symTab+30($t6)	# symTab[symIndex][2]=newStatus;
		b	EndVar
		
		
		
SymLessThanZero:
		addi	$a2, $a0, 0x4		# newStatus = 0x4 | DEFN;
		la	$v0, saveSymTab		# These two lines should do:
		jalr	$t6, $v0		# symIndex = saveSymTab(TOKEN, newStatus);
		b EndVar
		# symACTS(newStatus, symIndex)
EndVar:		la	$s0, symACTS		# $s0 = symACTS
		sll	$s1, $s1, 2		# newStatus in byte offset
		add	$s0, $s0, $s1		# $s0 = symACTS[newStatus]
		sra	$s1, $s1, 2	
		jr	$s0			# call symACTx

retVar:
		jr	$ra


#############################################
#
#  symACT0:
#	store LOC in Value field of the symbol table
#	return previous contents of Value field
#
#############################################
symACT0:
		la	$ra, symTab+20		# return previous contents of Value field
		sw	$t9, symTab+20		# Store LOC in Value field	
		b 	retVar

#############################################
#
#  symACT1:
#	store LOC in Value field of the symbol table
#	return previous contents of Value field
#
#############################################
symACT1:
		la	$ra, symTab+20		# return previous contents of Value field
		sw	$t9, symTab+20		# Store LOC in Value field	
		b	retVar

#############################################
#
#  symACT2:
#	return contents of Value field
#
#############################################
symACT2:
		la	$ra, symTab+20		# return previous contents of Value field
		b	retVar

#############################################
#
#  symACT3:
#	print 'double definition error' and return
#
#############################################
symACT3:
		la	$k1, st_double_def	
		li	$t2, 4
		syscall				# printing error and returning 
		
		b	retVar

#############################################
#
#  symACT4:
#	store LOC in Value field
#	return -1
#
#############################################
symACT4:
		sw	$t9, symTab+20		# Store LOC in Value field
		li	$ra, -1		# return -1	
		b	retVar

#############################################
#
#  symACT5:
#	store LOC in Value field
#	return 0
#
#############################################
symACT5:
		sw	$t9, symTab+20		# Store LOC in Value field
		li	$ra, 0		# return 0	
		b	retVar



###################################################################
#
#  srchSymTab(TOKEN):
#	$a0, $a1: argument TOKEN in two words
#	$t6:	   return value
#			-1 if not found
#	               symTab index, otherwise
#
#	Search two words of TOKEN in symTab
#
###################################################################
srchSymTab:
		li	$t6, 0			# k = 0
checkSym:
		bgt	$t6, $t3, symNotF	# if (k > max) goto notFound
		sll	$t8, $t6, 4		# k to byte offset (4 words/entry)
		lw	$t7, symTab($t8)	# 1st word of symTab[i][0]
		bne	$a0, $t7, nextSym	# if (TOKEN != symTab{i][0]) goto nextSym
		lw	$t7, symTab+4($t8)	# 2nd word of symTab[i][0]
		bne	$a1, $t7, nextSym	# if (TOKEN != symTab{i][0]) goto nextSym
symFound:
		jr	$v1

symNotF:
		li	$t6, -1		# TOKEN not found
		jr	$v1

nextSym:
		addi	$t6, $t6, 1		# k++
		b	checkSym


###################################################################
#
#  saveSymTab(TOKEN, newStatus):
#	$a0, $a1: argument TOKEN in two words
#	$a2:	   newStatus
#
#	Make a new entry for the TOKEN in symTab
#	$t3: C index to the last entry in symTab
#
###################################################################
saveSymTab:


		sw	$a0, symTab+0		# put the first token in the table
		sw	$a1, symTab+10		# put the second token in the table
		sw	$s2, symTab+30		# update the status

#############################################
#
#  printSymTab:
#	print symbol table
#
#############################################
printSymTab:
	la	$a0, symTabHead			# symbol table heading
	li	$v0, 4
	syscall

	la	$a0, symTab			# print symtab
	li	$v0, 4
	syscall


	jr	$ra



#############################################
#
#  symACTS:
#	Jump table for symACTx
#
#############################################
symACTS:
		b	symACT0
		b	symACT1
		b	symACT2
		b	symACT3
		b	symACT4
		b	symACT5


####################### STATE ACTION ROUTINES #####################
##############################################
#
# ACT1:
#	$t5: Get next char
#	T = char type
#
##############################################
ACT1: 
	lb	$a0, inBuf($t5)		# $a0: next char
	jal	srchChar			# $s0: T (char type)
	addi	$t5, $t5, 1			# $t5++
	jr	$v1
	
###############################################
#
# ACT2:
#	save char to TOKEN for the first time
#	save char type as Token type
#	set remaining token space
#
##############################################
ACT2:
	li	$s3, 0				# initialize index to TOKEN char 
	sb	$a0, TOKEN($s3)			# save 1st char to TOKEN
	addi	$t0, $s0, 0x30			# T in ASCII
	sb	$t0, TOKEN+10($s3)		# save T as Token type
	li	$t0, '\n'
	sb	$t0, TOKEN+11($s3)		# NULL to terminate an entry
	addi	$s3, $s3, 1
	jr 	$v1
	
#############################################
#
# ACT3:
#	collect char to TOKEN
#	update remaining token space
#
#############################################
ACT3:
	bgt	$s3, 7, lenError		# TOKEN length error
	sb	$a0, TOKEN($s3)			# save char to TOKEN
	addi	$s3, $s3, 1			# $s3: index to TOKEN
	jr	$v1	
lenError:
	li	$s0, 7				# T=7 for token length error
	jr	$v1
					
#############################################
#
#  ACT4:
#	move TOKEN to tokArray
#
############################################
ACT4:
	lw	$t0, TOKEN($0)			# get 1st word of TOKEN
	sw	$t0, tokArray($a3)		# save 1st word to tokArray
	lw	$t0, TOKEN+4($0)		# get 2nd word of TOKEN
	sw	$t0, tokArray+4($a3)		# save 2nd word to tokArray
	lw	$t0, TOKEN+8($0)		# get Token Type
	sw	$t0, tokArray+8($a3)		# save Token Type to tokArray
	addi	$a3, $a3, 12			# update index to tokArray
	
	jal	clearTok			# clear 3-word TOKEN
	jr	$v1

############################################
#
#  RETURN:
#	End of the input string
#
############################################
RETURN:
	sw	$zero, tokArray($a3)		# force NULL into tokArray
	b	genSym				# leave the state table


#############################################
#
#  ERROR:
#	Error statement and quit
#
############################################
ERROR:
	la	$a0, st_error			# print error occurrence
	li	$v0, 4
	syscall
	b	genSym


############################### BOOK-KEEPING FUNCTIONS #########################
#############################################
#
#  clearTok:
#	clear 3-word TOKEN after copying it to tokArray
#
#############################################
clearTok:
	li	$t1, 0x20202020
	sw	$t1, TOKEN($0)
	sw	$t1, TOKEN+4($0)
	sw	$t1, TOKEN+8($0)
	jr	$ra
	
#############################################
#
#  printline:
#	Echo print input string
#
#############################################
printline:
	la	$a0, inBuf			# input Buffer address
	li	$v0,4
	syscall
	jr	$ra


############################################
#
#  clearInBuf:
#	clear inbox
#
############################################
clearInBuf:
	li	$t0,0
loopInB:
	bge	$t0, 80, doneInB
	sw	$zero, inBuf($t0)		# clear inBuf to 0x0
	addi	$t0, $t0, 4
	b	loopInB
doneInB:
	jr	$ra
	
###########################################
#
# clearTokArray:
#	clear Token Array
#
###########################################
clearTokArray:
	li	$t0, 0
	li	$t1, 0x20202020			# intialized with blanks
loopCTok:
	bge	$t0, $a3, doneCTok
	sw	$t1, tokArray($t0)		# clear
	sw	$t1, tokArray+4($t0)		#  3-word entry
	sw	$t1, tokArray+8($t0)		#  in tokArray
	addi	$t0, $t0, 12
	b	loopCTok
doneCTok:
	jr	$ra
	

###################################################################
#
#  getline:
#	get input string into inbox
#
###################################################################
getline: 
	la	$a0, st_prompt			# Prompt to enter a new line
	li	$v0, 4
	syscall

	la	$a0, inBuf			# read a new line
	li	$a1, 80	
	li	$v0, 8
	syscall
	jr	$ra


##################################################################
#
#  srchChar:
#	Linear search of Tabchar
#
#   	$a0: char key
#   	$s0: char type, T
#
#################################################################
srchChar:
	li	$t0,0				# index to Tabchar
	li	$s0, 7				# return value, type T
loopSrch:
	lb	$t1, Tabchar($t0)
	beq	$t1, 0x7F, charFail
	beq	$t1, $a0, charFound
	addi	$t0, $t0, 8
	b	loopSrch

charFound:
	lw	$s0, Tabchar+4($t0)		# return char type
charFail:
	jr	$ra


	
	
	.data

STAB:
Q0:     .word  ACT1
        .word  Q1   # T1
        .word  Q1   # T2
        .word  Q1   # T3
        .word  Q1   # T4
        .word  Q1   # T5
        .word  Q1   # T6
        .word  Q11  # T7

Q1:     .word  ACT2
        .word  Q2   # T1
        .word  Q5   # T2
        .word  Q3   # T3
        .word  Q3   # T4
        .word  Q0   # T5
        .word  Q4   # T6
        .word  Q11  # T7

Q2:     .word  ACT1
        .word  Q6   # T1
        .word  Q7   # T2
        .word  Q7   # T3
        .word  Q7   # T4
        .word  Q7   # T5
        .word  Q7   # T6
        .word  Q11  # T7

Q3:     .word  ACT4
        .word  Q0   # T1
        .word  Q0   # T2
        .word  Q0   # T3
        .word  Q0   # T4
        .word  Q0   # T5
        .word  Q0   # T6
        .word  Q11  # T7

Q4:     .word  ACT4
        .word  Q10  # T1
        .word  Q10  # T2
        .word  Q10  # T3
        .word  Q10  # T4
        .word  Q10  # T5
        .word  Q10  # T6
        .word  Q11  # T7

Q5:     .word  ACT1
        .word  Q8   # T1
        .word  Q8   # T2
        .word  Q9   # T3
        .word  Q9   # T4
        .word  Q9   # T5
        .word  Q9   # T6
        .word  Q11  # T7

Q6:     .word  ACT3
        .word  Q2   # T1
        .word  Q2   # T2
        .word  Q2   # T3
        .word  Q2   # T4
        .word  Q2   # T5
        .word  Q2   # T6
        .word  Q11  # T7

Q7:     .word  ACT4
        .word  Q1   # T1
        .word  Q1   # T2
        .word  Q1   # T3
        .word  Q1   # T4
        .word  Q1   # T5
        .word  Q1   # T6
        .word  Q11  # T7

Q8:     .word  ACT3
        .word  Q5   # T1
        .word  Q5   # T2
        .word  Q5   # T3
        .word  Q5   # T4
        .word  Q5   # T5
        .word  Q5   # T6
        .word  Q11  # T7

Q9:     .word  ACT4
        .word  Q1  # T1
        .word  Q1  # T2
        .word  Q1  # T3
        .word  Q1  # T4
        .word  Q1  # T5
        .word  Q1  # T6
        .word  Q11 # T7

Q10:	.word	RETURN
        .word  Q10  # T1
        .word  Q10  # T2
        .word  Q10  # T3
        .word  Q10  # T4
        .word  Q10  # T5
        .word  Q10  # T6
        .word  Q11  # T7

Q11:    .word  ERROR 
	.word  Q4  # T1
	.word  Q4  # T2
	.word  Q4  # T3
	.word  Q4  # T4
	.word  Q4  # T5
	.word  Q4  # T6
	.word  Q4  # T7
	
	
Tabchar: 
	.word ' ', 5
 	.word '#', 6
 	.word '$', 4 
	.word '(', 4
	.word ')', 4 
	.word '*', 3 
	.word '+', 3 
	.word ',', 4 
	.word '-', 3 
	.word '.', 4 
	.word '/', 3 

	.word '0', 1
	.word '1', 1 
	.word '2', 1 
	.word '3', 1 
	.word '4', 1 
	.word '5', 1 
	.word '6', 1 
	.word '7', 1 
	.word '8', 1 
	.word '9', 1 

	.word ':', 4 

	.word 'A', 2
	.word 'B', 2 
	.word 'C', 2 
	.word 'D', 2 
	.word 'E', 2 
	.word 'F', 2 
	.word 'G', 2 
	.word 'H', 2 
	.word 'I', 2 
	.word 'J', 2 
	.word 'K', 2
	.word 'L', 2 
	.word 'M', 2 
	.word 'N', 2 
	.word 'O', 2 
	.word 'P', 2 
	.word 'Q', 2 
	.word 'R', 2 
	.word 'S', 2 
	.word 'T', 2 
	.word 'U', 2
	.word 'V', 2 
	.word 'W', 2 
	.word 'X', 2 
	.word 'Y', 2
	.word 'Z', 2

	.word 'a', 2 
	.word 'b', 2 
	.word 'c', 2 
	.word 'd', 2 
	.word 'e', 2 
	.word 'f', 2 
	.word 'g', 2 
	.word 'h', 2 
	.word 'i', 2 
	.word 'j', 2 
	.word 'k', 2
	.word 'l', 2 
	.word 'm', 2 
	.word 'n', 2 
	.word 'o', 2 
	.word 'p', 2 
	.word 'q', 2 
	.word 'r', 2 
	.word 's', 2 
	.word 't', 2 
	.word 'u', 2
	.word 'v', 2 
	.word 'w', 2 
	.word 'x', 2 
	.word 'y', 2
	.word 'z', 2

	.word 0x7F, 0
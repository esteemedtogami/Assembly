		.data
inBuf:		.space		80
Tokarray:	.word		0x20202020:45	#max 15 tokens
Token:		.word		0x20202020


		.text
###########################################################
main:
newline:	jal	getline

		la	$s1, Q0		# CUR = Q0
		li	$s0, 1		# T = 1

driver:		lw	$s2, 0($s1)	# $s2 = 'ACT1' / 'ACT2' / 
		jalr	$v1, $s2	# Save return addr in $v1

		sll	$s0, $s0, 2	# Multiply by 4 for word boundary
		add	$s1, $s1, $s0	# $s1 = 'Q1' / 'Q5'
		sra	$s0, $s0, 2	
		#lw	$s1, 0($s1)	# $s2 = 'ACT2'
		b 	driver
		
		jal	printline
		jal	clearTok
		b	newline
		
##################################################################		
ACT1:
getTypes:
 
                            li         $t0, 0			# i = 0
loop:                       bge        $t0, 80, done           	# while (i < 80)
                            lb         $s0, inBuf($t0)          # key = inBuf[i]
                            beq        $s0, '\n', done          #if(key == '\n'), goto done
                           
                            li         $t1, 0                   # j = 0
loop2:                      sll        $t9, $t1, 3              # $t9 = 8*j for byte offset
                            lb         $s1, Tabchar($t9)        # $s1 = Tabchar(j,0)
                            beq        $s1, $s0, done2          # while Tabchar[j,0] != key
                            addi       $t1, $t1, 1              # j++
                            bge        $t1, 75, error           
                            b          loop2
                           
done2:               
                            lw         $a0, Tabchar+4($t9)      # type = Tabchar[j,1]
                            beq	       $s0, ' ', space		# if there is a ' ' character...
                            addi       $a0, $a0, 0x30           # type = ascii
                            sb         $a0, outBuf($t0) 	# outBuf[i] = type
                            beq        $s0, '#', done           # if (key == '#') goto done
                            addi       $t0, $t0, 1              # i += 1
                            b          loop
 
error:                      la         $a0, err_mes            
                            li         $v0, 4
                            syscall
                            jal        err_loop
                            
space:			    addi       $a0, $zero, 0x20         # type = space
                            sb         $a0, outBuf($t0) 	
                            addi       $t0, $t0, 1              
                            b          loop
                           
done:                  	    #jr         $ra
			    jr	       $v1
##########################################################################	
ACT2:

		jr	$v1
#########################################################################
ACT3:

		jr	$v1
########################################################################
		
ACT4:
		jr	$v1
########################################################################
RETURN:


########################################################################
ERROR:
			.data
                           
err_mes: 		.asciiz    "Error! You have entered something invalid. \n”

			li $v0, 10
			syscall

#######################################################################
printline:
		jr	$ra
#######################################################################
	
clearTok:
		jr	$ra
#######################################################################
printTokArray:
		jr	$ra
######################################################################
clearInBuf:
		jr	$ra
#####################################################################
clearTokArray:
		jr	$ra
####################################################################
	
	                           .data
                           
st_prompt:          .asciiz "\nEnter a new input line: \n”
 
                            .text
####################################################################### 
getline:
              la           $a0, st_prompt                 # Prompt to enter a new line
              li           $v0, 4
              syscall
 
              la           $a0, inBuf                          # read a new line
              li           $a1, 80  
              li           $v0, 8
              syscall
 
              jr           $ra
#####################################################################

		.data
STAB:
Q0:     .word  ACT1
        .word  Q1   # T1
        .word  Q1   # T2
        .word  Q1   # T3
        .word  Q1   # T4
        .word  Q1   # T5
        .word  Q1   # T6
        .word  Q10  # T7

Q1:     .word  ACT2
        .word  Q2   # T1
        .word  Q5   # T2
        .word  Q3   # T3
        .word  Q3   # T4
        .word  Q0   # T5
        .word  Q4   # T6
        .word  Q10  # T7

Q2:     .word  ACT1
        .word  Q6   # T1
        .word  Q7   # T2
        .word  Q7   # T3
        .word  Q7   # T4
        .word  Q7   # T5
        .word  Q7   # T6
        .word  Q10  # T7

Q3:     .word  ACT4
        .word  Q0   # T1
        .word  Q0   # T2
        .word  Q0   # T3
        .word  Q0   # T4
        .word  Q0   # T5
        .word  Q0   # T6
        .word  Q10  # T7

Q4:     .word  RETURN
        .word  Q4   # T1
        .word  Q4   # T2
        .word  Q4   # T3
        .word  Q4   # T4
        .word  Q4   # T5
        .word  Q4   # T6
        .word  Q10  # T7

Q5:     .word  ACT1
        .word  Q8   # T1
        .word  Q8   # T2
        .word  Q9   # T3
        .word  Q9   # T4
        .word  Q9   # T5
        .word  Q9   # T6
        .word  Q10  # T7

Q6:     .word  ACT3
        .word  Q2   # T1
        .word  Q2   # T2
        .word  Q2   # T3
        .word  Q2   # T4
        .word  Q2   # T5
        .word  Q2   # T6
        .word  Q10  # T7

Q7:     .word  ACT4
        .word  Q1   # T1
        .word  Q1   # T2
        .word  Q1   # T3
        .word  Q1   # T4
        .word  Q1   # T5
        .word  Q1  	 # T6
        .word  Q10   # T7

Q8:     .word  ACT3
        .word  Q5   # T1
        .word  Q5   # T2
        .word  Q5   # T3
        .word  Q5   # T4
        .word  Q5   # T5
        .word  Q5   # T6
        .word  Q10  # T7

Q9:     .word  ACT4
        .word  Q1  # T1
        .word  Q1  # T2
        .word  Q1  # T3
        .word  Q1  # T4
        .word  Q1  # T5
        .word  Q1  # T6
        .word  Q10  # T7

Q10:    .word  ERROR 
        .word  Q4   # T1
        .word  Q4   # T2
        .word  Q4   # T3
        .word  Q4   # T4
        .word  Q4   # T5
        .word  Q4   # T6
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

		.data
inBuf:		.space		80
Tokarray:	.word		0x20202020:45	#max 15 tokens
Token:		.word		0x20202020:12


		.text
###########################################################
main:
newline:	jal	getline

		la	$s1, Q0		# CUR = Q0
		li	$s0, 1		# T = 1
		li 	$t6, 0		# i = 0
		li	$t0, 0		#TokSpace = 0
		li	$k0, 0		#counter for tokarray

driver:		lw	$s2, 0($s1)	# $s2 = 'ACT1' / 'ACT2' / 
		jalr	$v1, $s2	# Save return addr in $v1

		sll	$s0, $s0, 2	# Multiply by 4 for word boundary
		add	$s1, $s1, $s0	# $s1 = 'Q1' / 'Q5'
		sra	$s0, $s0, 2	
		#lw	$s1, 0($s1)	# $s2 = 'ACT2'
		addi	$t6, $t6, 1	# i++
		b 	driver
		
		la	$t9, printline
		jalr	$t9
		
		la	$t8, clearTok
		jalr	$t8
		b	newline
		
		li	$v0, 10
		syscall
		
##################################################################		
ACT1:

			lb         $t4, inBuf($t6) 

                            li         $t1, 0                   # j = 0
                            
loop3:                      sll        $t9, $t1, 3              # $t9 = 8*j for byte offset
                            lb         $t3, Tabchar($t9)        # $s1 = Tabchar(j,0)
                            beq        $t3, $t4, done3
                            addi       $t1, $t1, 1              # j++           
                            b          loop3
                            
done3:			
			    lw         $s0, Tabchar+4($t9) 
                
                
done:		jal	   RETURN
##########################################################################	
ACT2:

		lw	   $s7,	inBuf($s0)
		sb	   Token($t6), $s7  #save char to token
		beq 	   $t0, 0, storetype
		addi	   $t0, $t0, 1
		
		jr	   $v1
		
storetype:
		
		sb	   Token+10($0), $s0
		#sb         $a0, ($s3)	    	   # T = char type
		jr 	   $ra
		
		
#########################################################################
ACT3:
		bgt	   $t0, 7, ERROR

		sb	  Token($t0), inBuf($t6)   #collect char to token
		addi	  $t0, $t0, 1		   # update TokSpace
		
		
		jr	$v1
########################################################################
		
ACT4:
		li	$k1, 0		#token counter
tokloop:
		lw	Tokarray($k0), Token($k1)
		addi	$k0, $k0, 1
		addi	$k1, $k1, 1
		ble 	$k1, 3, tokloop
		
		jr	$v1
########################################################################
RETURN:

		jr	$ra
########################################################################
ERROR:
			.data
                           
err_mes: 		.asciiz    "Error! Not enough room. \n”
			
			
			la 	$a0, err_mes
			li 	$v0, 4
			syscall
			
			li 	$v0, 10
			syscall

#######################################################################
printline:
	      la           $a0, inBuf
              li           $v0, 4
              syscall
             
               jr 	$ra
#######################################################################
	
clearTok:
		sw      $0, Token 

		jr	$ra
#######################################################################
printTokArray:

 			.data
                           
array_header:          .asciiz "\n  Token:                      Token Type: \n”
breaks:		       .asciiz "\n ______________________      _________________\n"

		li	$t0, 0
loop2:		bge	$t0, 15, done2

		la	$a0, Tokarray($t0)
		li	$v0, 4
		syscall
		
		addi	$t0, $t0, 1
		b	loop2


done2:		jr	$ra
######################################################################
clearInBuf:
		sw      $0, inBuf
		jr	$ra
#####################################################################
clearTokArray:
		sw      $0, Tokarray
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

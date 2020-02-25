	.data
A:	.word	5:10		#10-element array
N:	.word	10


	.text
	 #####
 # main()
 #
 	jal	avg
 	# print comments
 	# print $a0
 	li	$v0, 1
 	syscall
 	
 	li	$v0, 10		#stop execution
 	syscall
 	
 	
###########
# function avg()
#	$a0 ----> sum
#	$t0 ----> i
###########
avg:	
	li	$a0, 0		#sum = 0
	li	$t0, 0
	lw	$t9, N
	
loop:	bge	$t0, $t9, done

	sll	$t0, $t0, 2
	lw 	$t8, A($t0)
	add 	$a0, $a0, $t8
	sra	$t0, $t0, 1 
	##### might put it here

	addi	$t0, $t0, 1
	b	loop
	
 done:	div	$a0, $a0, $t9
 	jr	$ra
 	


###SHIFTING sll $t0, $t0, 2
###	    srl $t0, $t0, 4
#send to comp2030.201@gmail.com

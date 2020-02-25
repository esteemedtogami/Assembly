	.data
A:	.word	5:10		#10-element array
N:	.word	10 


	.text
#####
# main()
####
 	jal	avg
 	
 	li	$v0, 10		#stop execution
 	syscall
 	
 	
###########
# function avg()
#	$a0 ----> sum
#	$t0 ----> i
###########
avg:	
	li	$a0, 0		#sum = 0
	li	$t0, 0 		#set i to 0
	lw	$t9, N 		#register t9 contains N
	
loop:	bge	$t0, $t9, done 	#if t0 is greater than 11, go to done. Otherwise...

	sll	$t0, $t0, 2	#shift the value at t0 by 2 bits
	lw 	$t8, A($t0)	#load the contents to t8 from A($t0)
	add 	$a0, $a0, $t8 	#a0 += t8
	sra	$t0, $t0, 2  	#Bit shift t0 to the right by 2 bits

	addi	$t0, $t0, 1	#increase t0 by 1
	b	loop		#go to loop
	
 done:	div	$a0, $a0, $t9	# a0 /= t9
 
 	li	$v0, 1
 	
 	syscall
 	
 	jr	$ra

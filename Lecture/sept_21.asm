		.data
nodes:		.word	0:8
N:		.word	10
avail:		.word	0
head_ref:	.word	0

		.text
###
#  main()
###
		lw	$a0, N
		jal	list_init
		sw	$a1, avail
		
		li	$v0, 10
		syscall
		
###
# list_init()
###
list_init:
		li	$a1, 0		#avail = NULL
		addi	$t0, $a0, -1
		
loop:
		bltz	$t0, done
		sll	$t9, $t0, 3
		#la	$t9, nodes($t0)
		#sra	$t0, $t0, 3
		
		#sw	$a1, 4($t9)
		sw	$a1, nodes+4($t9)
		#move	$a1, $t9
		la	$a1, nodes($t9)
		
		addi	$t0, $t0, -1
		b 	loop

done:		jr	$ra
		
		
.data

myMessage:	.asciiz		"Hello World!\n"
myChar:		.byte		's'
mySpace:	.byte		'\n'
myInt:		.word		19

.text

#######
# main()
######

		li	$v0, 4
		la	$a0, myMessage
		syscall
		
		li	$v0, 4
		la	$a0, myChar
		syscall
		
		li	$v0, 4
		la	$a0, mySpace
		syscall
		
		li	$v0, 1
		lw	$a0, myInt
		syscall
		
		li	$v0, 10
		syscall
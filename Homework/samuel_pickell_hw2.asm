
                          .data
inBuf:                    .space    80
outBuf:                	  .space    80
 
                          .text
############
# main()
############
repeat:
                            jal           getline
                            jal           getTypes
                            jal           printTypes
                            beq        	  $s0, '#', end     	# Goto end the program when you encounter "#"
                            jal           clearBuf             
                            b             repeat
 
end:                   	    li            $v0, 10               # end program;
			    syscall
 
clearBuf: 		    sw            $0, inBuf             
                            sw            $0, outBuf            
                            jr            $ra
 
#####
#getTypes
#            Change the input to numbers and store them in outbuf
#            $t0 ---> i
#            $t1 ---> j
#            $s0 ---> key
#            $t9 ---> 8*j for byte offset
#            Tabchar ---> Array of type conversion
#            $a0 ---> inout
#           
#
#####
                            .data
                           
err_mes: 		    .asciiz    "Error! You have entered something invalid. \n”
 
                            .text
                           
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
                           
done:                  	    jr         $ra
 
err_loop:
                            beq        $s0, '#', end      	
                            beq        $s0, '\n', repeat   	
                            addi       $t0, $t0, 1                          
                            lb         $s0, inBuf($t0)        
                            b          err_loop              
 
#######
# getline
#            Reads from the keyboard
#            $a0 ---> input
#            $a1 ---> read new line
#            $v0 ---> i
#                         
##########
 
                            .data
                           
st_prompt:          .asciiz "\nEnter a new input line: \n”
 
                            .text
 
getline:
              la           $a0, st_prompt                 # Prompt to enter a new line
              li           $v0, 4
              syscall
 
              la           $a0, inBuf                          # read a new line
              li           $a1, 80  
              li           $v0, 8
              syscall
 
              jr           $ra
             
printTypes:
             
              la           $a0, outBuf
              li           $v0, 4
              syscall
             
              jr           $ra
             
             
             
 
                           
                            .data
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

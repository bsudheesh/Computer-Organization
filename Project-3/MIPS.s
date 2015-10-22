############# MIPS PROJECT 3 ###############
# labels used are
# 1. start: this is where the code begins ##
# 2. LOOP: this is where the input is taken from the user 5 times ##
# 3. LOOP_RANGE: this checks to see if the value if between 0 and 32768 ##
# 4. RE_DO : If the numbers are not in range it will go back to START ##
# 5. LOOP_TO_SUBPROGRAM: This will values one by one from the 5 numbers entered and pass it as a parameter to subProgram and display the HexaDecimal Value ##
# 5. print_in_Hex: This will change the returned value to HexaDecimal ##
# 6. subProgram: This is the subprogram which does the required things by taking the argument from LOOP_TO_SUBPROGRAM ##
# 7. LOOP_PROGRAM: Will loop four times doing the necessary operations. ##
# 8. check_1: If the number is less than 10, the program goes in this label ##
# 9. shifting: shifts the parameter right by 4 bits ##


.data	
	INPUT: .asciiz "\n Please enter an integer: "
	ERROR: .asciiz "\n The numbers you entered is not between 0 and 32768\n"
	OUTPUT: .asciiz "\n The hexadecimal value of the decimal integer "
	OUTPUT_2: .asciiz " is : "
	NEWLINE: .asciiz "\n"
	.align 3
	list: .space 20
.text


main:
	
	addi $t0,$zero,0 	#setting the temporary variable to 0

START: 
	addi $t0,$zero,0	 #setting the temporary variable to 0
	addi $t9,$zero,0 	#setting the temporary variable t9 to 0
	addi $t8,$zero,0
	j LOOP #jump to LOOP

#this will take input from the user	
LOOP: 	
	li $v0, 4   
	la $a0, INPUT #display the input message
 	syscall		
	li $v0, 5 #stores the input in v0
	syscall
	sw $v0, list($t0) #stores the input value in list
	addi $t0,$t0,4	#incrementing by 4 every time the loop repeats
	slt $t1,$t0,20	#checking to see if the value of t0 is less than 20, which is it LOOP running 5 times
	beq $t1,0, LOOP_RANGE 	#if not go to LOOP_RANGE
	j LOOP #if yes, go back to LOOP

#this will check is the numbers are in the given range 0 to 32768
LOOP_RANGE: 
	
	lw $t0,list($t9)   #load the value of list in t0
	slt $t1,$t0,0	#checks to see if the number is less than 0
	beq $t1,1,RE_DO #if less than zero go to RE_DO
	slt $t2,$t0,32768	#checking to see if the number is greater than 32768
	beq $t2,0,RE_DO #if yes go to RE_DO
	slt $t6,$t9,20	#else see if the number is than 20
	addi $t9,$t9,4	#incrementing by 4
	beq $t6,1, LOOP_RANGE #is yes than go back to LOOP_RANGE
	j LOOP_TO_SUBPROGRAM		#else go to LOOP_TO_SUBPROGRAM
	
#this will handle the error
RE_DO:  

	li $v0, 4 
	la $a0, ERROR #printing the error message
	syscall
	j START #go back to start and repeat the process

#this will send the 5 numbers as integers to the subprogram

	li $t5,0 #load immedite the temporary register with the value of 0. $t5 is used as a counter
	
#this will pass the number as paramter to subProgram
LOOP_TO_SUBPROGRAM:
	lw $a0, list($t8) #loading the value from offset list($t8) to argument $a0
	jal sub_Program 		#calling the subprogram
	add $t9, $v1, $0	#$v1 is the value that subProgram returns.It is assigned to$t9
	li $v0, 4			
	la $a0, OUTPUT	#Display the output statement
	syscall
	li $v0, 1		
	lw $a0, list($t8) #will display X
	syscall
	li $v0, 4		
	la $a0, OUTPUT_2 #display the other statements
	syscall
	li $t7, 0
	print_in_Hex: #this will take the 8bits from returned value	

		srl $t1, $t9, $t7	#shifting the numbers to least significant bits
		andi $t1, $t1, 255	#logical and with the shifted number and 255 for ASCII value
		addi $a0, $t1, 0	#setting $a0=$t1
		li $v0, 11				
		syscall 	#Display $a0
		addi $t7, $t7, 8 #incrementing t7 by 8
		bne $t7, 32, print_in_Hex 	#check to see if $t7 is not equal to 32 which is the print_in_Hex running 4 times. 

	li $v0, 4		
	la $a0, NEWLINE	
	syscall
	addi $t8, $t8, 4 #incrementing the base address by 4
	addi $t5, $t5, 1 #incrementing counter
	bne $t5, 5, LOOP_TO_SUBPROGRAM	#checking to see if counter is not equal to 5. If not equal go back to LOOP_TO_SUBPROGRAM


	li $v0, 10	#exits the program
	syscall
	
#this is sub_program

sub_Program:
	addi $t7, $0, 0	#setting $t7 as zero. It is the loop counter. 
	addi $t9, $zero, 0  #setting t9 as zero. it is used for shifting and merging
	add $t2, $a0, $0 #setting the argument to the value of $t2
	
	#this Loop will perform the necessary operation and will run 4 times				
	LOOP_PROGRAM:
		andi $t0, $t2, 15	#doing a logical and with the argument number $t2 and with value 15. The output is stored in $t0
		slti $t1,$t0, 10	#checking to see if the number obtained in less than 10 
		beq $t1, 1, check_1 #if yes than go to check_1
		addi $t0, $t0, -10 	#if the number is not less than 10 than subtract 10. 
		addi $t0, $t0, 65 #and adding the ASCII value of 'A'
		j shifting 	#jumps to shifting inorder to escape the check_1
		check_1:
			addi $t0, $t0, 48 #adds the ASCII value of 0
		shifting:
			srl $t2, $t2, 4 #shifts right by 4 bits. 

		addi $t7, $t7, 1 #incrementing the loop counter
		sll $t9, $t9, 8	#shifting t9 by 8 bits. 	 
		add $t9, $t0, $t9	#adding the obtained value and merging with $t9		
		bne $t7, 4, LOOP_PROGRAM #checking to see if the LOOP_PROGRAM runs for 4 times. If not go back to LOOP_PROGRAM
	add $v1, $t9, $0 #adding the value of t9 with the return register v1
	jr $ra
	

	

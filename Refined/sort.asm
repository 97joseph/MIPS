.globl main

.data
size:		.asciiz "Array size? "
enter_num:	.asciiz "Enter number: "
org_arr:	.asciiz "Original Array: "
sorted_arr:	.asciiz "Sorted Array: "
newline:	.asciiz "\n"
space:		.asciiz " "

.text
main:
	# Register Allocation:
	# size		$s0
	# inputArr	$s1
	# sortedArr	$s2
	# 4 (per word)	$s3
	# tempCalc	$s4	for calculating address
	# index		$s5
	# x		$s6
	
	# prologue - allocate memory stack
	subi $sp, $sp, 24
	sw $ra, 0($sp)
	sw $s0, 4($sp)
	sw $s3, 8($sp)
	sw $s4, 12($sp)
	sw $s5, 16($sp)
	sw $s6, 20($sp)
	
	# display prompt for array size
	li $v0, 4
	la $a0, size
	syscall
	
	# read input for array size
	la $v0, 5
	syscall
	move $s0, $v0
	
	# input numbers to the array
	move $a0, $s0
	jal read_arr
	move $s1, $v0
	
	# sort the array using gnome sort
	move $a0, $s0
	move $a1, $s1
	jal gnome_sort
	move $s2, $v0
	move $s1, $v1
	
	# display prompt for original array
	li $v0, 4
	la $a0, org_arr
	syscall
	
	li $s5, 0
	j print_init_arr
	 #Inverse array
	addi $sp, $sp, -8
	sw $ra, 0($sp)
	sw $s4, 4($sp)
	
	la $s4, array
	li $t0, 0
	li $t1, 10
    	

read_arr:
	# register allocation
	# index		$s0
	# size		$s1
	# inputArr	$s2
	# 4 (per word)	$s3
	# tempCalc	$s4	for calculating address
	# x		$s5
	
	# read_arr(size, array address)
	# 	for (int ii = 0; ii < nn; ++ii) {
        # 		xs[ii] = read_int();
    	# 	}
    	# 	return xs;
    	
    	# prologue - allocate memory stack
	subi $sp, $sp, 24
	sw $ra, 0($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s3, 12($sp)
	sw $s4, 16($sp)
	sw $s5, 20($sp)
    	
    	move $s1, $a0
    	
    	# set index = 0
    	li $s0, 0
    	
    	# allocate space for input array on the heap
	# int* xs = (int*)malloc(nn * sizeof(int));
	li $s3, 4
	mul $s4, $s3, $s1
	li $v0, 9
	move $a0, $s4
	syscall
	move $s2, $v0
    	
do_read_arr:
	# display prompt to enter number
    	li $v0, 4
    	la $a0, enter_num
    	syscall
    	
    	# reads the input integer
    	li $v0, 5
    	syscall
    	move $s5, $v0
    	
    	# set the value at index as the input number
    	# $sp + (4 * index)
    	mul $s4, $s0, $s3
    	add $s4, $s2, $s4
    	sw $s5, 0($s4)
    	
    	# increment index
    	addi $s0, $s0, 1
    	blt $s0, $s1, do_read_arr
    	
    	move $v0, $s2
    	
    	# reset index
    	li $s0, 0
    	
    	# epilogue - restore memory stack
	lw $ra, 0($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s3, 12($sp)
	lw $s4, 16($sp)
	lw $s5, 20($sp)
	addi $sp, $sp, 24
    	
    	jr $ra
    	
gnome_sort:
	# register allocation
	# size		$s0
	# inputArr	$s1
	# sortedArr	$s2
	# index		$s3
	# x		$s4
	# index - 1	$s5
	# y		$s6
	# temp		$s7
	
	# prologue - allocate memory stack
	subi $sp, $sp, 36
	sw $ra, 0($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s3, 12($sp)
	sw $s4, 16($sp)
	sw $s5, 20($sp)
	sw $s6, 24($sp)
	sw $s7, 28($sp)
	sw $t0, 32($sp)
	
	move $s0, $a0
	move $s1, $a1
	
	# allocate space for sorted array on the heap
	# int* xs = (int*)malloc(nn * sizeof(int));
	mul $s7, $s0, 4
	li $v0, 9
	move $a0, $s7
	syscall
	move $s2, $v0
	
	# copy items from input array
	li $s3, 0
copy_arr:
	# for (int ii = 0; ii < nn; ++ii) {
        # 	ys[ii] = xs[ii];
    	# }
	
	mul $s7, $s3, 4
	add $s7, $s1, $s7
	lw $s4, 0($s7) # gets the value at this index
	
	mul $s7, $s3, 4
	add $s7, $s2, $s7
	sw $s4, 0($s7) # assign the value to this index
	
	addi $s3, $s3, 1
	blt $s3, $s0, copy_arr
	li $s3, 0
	
do_swap:
	# int ii = 0;
    	# while (ii < nn) {
        # if (ii == 0 || ys[ii] >= ys[ii - 1]) {
        #     ii++;
        # }
        # else {
        #     int tt = ys[ii];
        #     ys[ii] = ys[ii - 1];
        #     ys[ii - 1] = tt;
        #     ii--;
        # }
        
        bge $s3, $s0, gnome_done
        beq $s3, $zero, increment
        # ys [ii] = $s4
        mul $s7, $s3, 4
	add $s7, $s2, $s7
	lw $s4, 0($s7)
	# ys [ii - 1] = $s6
	subi $s5, $s3, 1
	mul $s7, $s5, 4
	add $s7, $s2, $s7
	lw $s6, 0($s7)
	
	bge $s4, $s6, increment
	move $s7, $s4
	# assign value of $s6 to this address
	mul $t0, $s3, 4
	add $t0, $s2, $t0
	sw $s6, 0($t0)
	# assign value of $s4
	subi $s5, $s3, 1
	mul $t0, $s5, 4
	add $t0, $s2, $t0
	sw $s7, 0($t0)
	
	subi $s3, $s3, 1
	j do_swap
	
increment:
	addi $s3, $s3, 1
	j do_swap     	

gnome_done:
	move $v0, $s2
	move $v1, $s1
	
	# epilogue - restore memory stack
	lw $ra, 0($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s3, 12($sp)
	lw $s4, 16($sp)
	lw $s5, 20($sp)
	lw $s6, 24($sp)
	lw $s7, 28($sp)
	addi $sp, $sp, 32
	jr $ra
	
print_init_arr:	
	# gets the value at this index
	mul $s4, $s5, 4
	add $s4, $s1, $s4
	lw $s6, 0($s4) # gets the value at this index
	
	# print out number
	li $v0, 1
	move $a0, $s6
	syscall
	# print out space
	li $v0, 4
	la $a0, space
	syscall
	
	# increment index
	addi $s5, $s5, 1
	
	# loop through again if index not equals to size
	blt $s5, $s0, print_init_arr
	
	li $s5, 0
	
	li $v0, 4
	la $a0, newline
	syscall
	
	# display prompt for sorted array
	li $v0, 4
	la $a0, sorted_arr
	syscall
	
	j print_sorted_arr
	
print_sorted_arr:
	# gets the value at this index
	mul $s4, $s5, 4
	add $s4, $s2, $s4
	lw $s6, 0($s4) # gets the value at this index
	
	# print out this integer
	li $v0, 1
	move $a0, $s6
	syscall
	# print out space
	li $v0, 4
	la $a0, space
	syscall
	
	# increment index
	addi $s5, $s5, 1
	
	blt $s5, $s0, print_sorted_arr
	li $s5, 0
	j done

    number_prompt_loop_begin:
	beq $t0, $t1, number_prompt_loop_end
	la $a0, enter_array_prompt
	li $v0, 4
	syscall
	
	li $v0, 5
	syscall

	sw $v0, 0($s4)
	addi $s4, $s4, 4 
	
	addi $t0, $t0, 1	
	j number_prompt_loop_begin

number_prompt_loop_end:
	la $a0, array
	li $a1, 10
	
	jal bubble_sort

	la $a0, output_sorted_array
	li $v0, 4
	syscall
	
	la $s4, array
	li $t0, 0
	li $t1, 10
print_sorted_array_loop_begin:
	beq $t0, $t1, print_sorted_array_loop_end
	
	lw $a0, 0($s4)
	li $v0, 1
	syscall
	
	la $a0, end_line
	li $v0, 4
	syscall
	
	addi $s4, $s4, 4
	addi $t0, $t0, 1
	j print_sorted_array_loop_begin
	
print_sorted_array_loop_end:
	lw $s4, 4($sp)
	lw $ra, 0($sp)
	addi $sp, $sp, 8
	jr $ra
	
bubble_sort:
	addi $sp, $sp, -20
	sw $ra, 0($sp)
	sw $s0, 4($sp)	#array
	sw $s1, 8($sp)	#n size of array
	sw $s2, 12($sp)	#i counter
	sw $s3, 16($sp) #j counter
	
	or $s0, $a0, $zero
	or $s1, $a1, $zero
	li $s2, 0
	
begin_i_loop:
	beq $s2, $s1, end_i_loop
	li $s3, 0
	la $s0, array #set current array element offset
		
begin_j_loop:
	addi $t0, $s1, -1	
	beq $s3, $t0, end_j_loop
	
	lw $t0, 0($s0)
	lw $t1, 4($s0)
	
	blt $t0, $t1, no_swap
	la $a0, 0($s0)
	la $a1, 4($s0)
	
	jal swap
	
no_swap:
	addi $s3, $s3, 1
	addi $s0, $s0, 4
	j begin_j_loop
	
end_j_loop:
	addi $s2, $s2, 1
	
	j begin_i_loop

end_i_loop:
	lw $s3, 16($sp)
	lw $s2, 12($sp)
	lw $s1, 8($sp)
	lw $s0, 4($sp)
	lw $ra, 0($sp)
	addi $sp, $sp, 20
	jr $ra

swap:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	lw $t0, 0($a0)
	lw $t1, 0($a1)
	sw $t0, 0($a1)
	sw $t1, 0($a0)
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $r	
done:
	# epilogue - restore memory stack
	lw $ra, 0($sp)
	lw $s0, 4($sp)
	lw $s3, 16($sp)
	lw $s4, 20($sp)
	lw $s5, 24($sp)
	lw $s6, 28($sp)
	addi $sp, $sp, 32
	
	# exit
	li $v0, 10
	syscall

 # Title  : Etch-A-Sketch
 # Author : Trevor Ransom
 # Desc   : Etch-A-Sketch in MIPS
 # Date   : 12-06-2021
  .eqv THD 0xffff000c  		# this is where we write data to...
  .eqv THR 0xffff0008  		# This check is the device ready
  .eqv KC 0xffff0004   		# MMMI  Address that we use to read data
  .eqv KR 0xffff0000   		# is it ok to write? Key write request
  .eqv BAD 0x10040000 		# heap base address
  # set constants for keys that will be used
  .eqv s 0x00000073		# down direction
  .eqv w 0x00000077 		# up direction
  .eqv a 0x00000061		# left direction
  .eqv d 0x00000064		# right direction
  .eqv q 0x00000071		# quit button
  .eqv g 0x00000067		# set color to GREEN
  .eqv r 0x00000072		# increment current color by a value of 0x00d0300
  .eqv z 0x0000007A		# diagonal from right to left downward
  .eqv x 0x00000078		# diagonal from left to right downward
  .eqv k 0x0000006B		# diagonal from right to left upward
  .eqv l 0x0000006C		# diagonal from left to right upward
  .eqv o 0x0000006F		# reset color to orignal BLU
  
  
  # colors chosen 
  .eqv BLU 0x0031ACE5
  .eqv WHITE 0x00FFFFFF
  .eqv PINK 0x00FF33CE
  .eqv GREEN 0x0000FF00
  .eqv RED 0x00ff0000
  
  
.data

.text
  .globl main
main:
 
# Allocate memory in the Heap to hold your 512 x 512 display.
  
li $v0, 9
  li $a0, 16384	# (512/8 X 512/8)x 4 bytes
  syscall
  
    
  # drawing border of etch-a-sketch
  
  # left vertical border
  li $a0, 0
  li $a1, 0
  jal border
  move $t4, $v0
  
  li $a0, PINK
  addi $a1, $t4, BAD
  li $a2, 64
  jal DRAW_VRT_LINE
  
  # right vertical border
  li $a0, 0
  li $a1, 63
  jal border
  move $t4, $v0
  
  li $a0, PINK
  addi $a1, $t4, BAD
  li $a2, 64
  jal DRAW_VRT_LINE
  
  # top horizontal border
  li $a0, 0
  li $a1, 0
  jal border
  move $t4, $v0
  
  li $a0, PINK
  addi $a1, $t4, BAD
  li $a2, 64
  jal DRAW_HORIZ_LINE
  
  # bottom horizontal border
  li $a0, 63
  li $a1, 0
  jal border
  move $t4, $v0
  
  li $a0, PINK
  addi $a1, $t4, BAD
  li $a2, 64
  jal DRAW_HORIZ_LINE
  
  # draw a white dot at the center of bitmap
  li $a0, 32
  li $a1, 32
  jal border
  move $t4, $v0
  
  li $a0, WHITE
  addi $a1, $t4, BAD
  addi $s0, $t4, BAD	# set our base address for center of bitmap
  li $a2, 1
  jal DRAW_HORIZ_LINE
  
  # load values needed to pass information from keyboard to display
  li $t0, KC 	
  li $t1, KR		# Key Ready?
  li $t2, THD		# Destination
  li $t3, THR		# is device ready?
  li $s3, BLU		# initial color set
  
loop: 
      
  
  lw $t4, 0($t1)	# load the value in KR into $t4
  beq $t4, $0, loop 	# if flag is not set, then loop again
  lw $s1, 0($t0)	# Get key that was pressed and store in $s1
   
.kdata
      
  
# Exception code that handles changes in input
.ktext 0x80000180

# branch to handlekeyinput label to evaluate in switch
b handleKeyInput


# method handleKeyInput switch statement that checks keyboard values
.text
handleKeyInput:

  beq $s1, w, handleKeyW	# changes direction to up
  beq $s1, s, handlekeyS	# changes direction to down
  beq $s1, a, handlekeyA	# changes direction to left
  beq $s1, d, handlekeyD	# changes direction to right
  beq $s1, g, handleKeyG	# changes color to Green
  beq $s1, r, handleKeyR	# changes color to Red
  beq $s1, o, handleKeyO	# changes color back to default
  beq $s1, z, handleKeyZ	# changes direction to left downward diagonal
  beq $s1, x, handleKeyX	# changes direction to right downward diagonal
  beq $s1, k, handleKeyK	# changes direction to left downward diagonal
  beq $s1, l, handleKeyL	# changes direction to right downward diagonal
  beq $s1, q, EXIT		# exits program
 
  b loop
  
# function that writes up one pixel when W is pressed
handleKeyW:
  lw $t5, 0($s0)		# load color of current pixel
  or $t5, $t5, $s3		# or color of next pixel with current color
  sw $t5, 0($s0)  		# Write to the screen with color
  li $t5, BAD			# Load base address into $t5
  addi $t5, $t5, 512		# Load address of first pixel in row two
  bltu $s0, $t5, loop		# Branch if the current location is right below the border 
  addiu $s0,$s0, -256		# Update location 
  b loop
  
# function that writes left one pixel when A is pressed
handlekeyA:
  lw $t5, 0($s0)		# load color of current pixel
  or $t5, $t5, $s3		# or color of next pixel with current color
  sw $t5, 0($s0)  		# Write to the screen with color
  andi $t5, $s0, 0xff		# and current location with 0xff to see if bottom byte is zero or not
  beq $t5, 4, loop		# if bottom byte is zero branch back to loop for input because we are at left border
  addiu $s0,$s0, -4		# Update location 
  b loop
  
# function that writes down one pixel when S is pressed
handlekeyS:
  lw $t5, 0($s0)		# load color of current pixel
  or $t5, $t5, $s3		# or color of next pixel with current color
  sw $t5, 0($s0)  		# Write to the screen with color
  li $t5, BAD			# Load base address into $t5
  addi $t5, $t5, 15872		# Load address of last pixel in row two
  bgtu $s0, $t5, loop		# Branch if the current location is right below the border 
  addiu $s0,$s0, 256		# Update location 
  b loop
  
 
# function that writes right one pixel whe D is pressed
handlekeyD:
  lw $t5, 0($s0)		# load color of current pixel
  or $t5, $t5, $s3		# or color of next pixel with current color
  sw $t5, 0($s0)  		# Write to the screen with color
  andi $t5, $s0, 0xff		# and current location with 0xff to see if bottom byte is zero or not
  beq $t5, 248, loop		# if bottom byte is zero branch back to loop for input because we are at left border
  addiu $s0,$s0, 4		# Update location 
  b loop
  
  

# function that writes diagonally from right to left downward when Z is pressed
handleKeyZ:
  lw $t5, 0($s0)		# load color of current pixel
  or $t5, $t5, $s3		# or color of next pixel with current color
  sw $t5, 0($s0)  		# Write to the screen with color
  li $t5, BAD			# Load base address into $t5
  addi $t5, $t5, 15872		# Load address of last pixel in row two
  bgtu $s0, $t5, loop		# Branch if the current location is right below the border 
  andi $t5, $s0, 0xff		# and current location with 0xff to see if bottom byte is zero or not
  beq $t5, 4, loop		# if bottom byte is zero branch back to loop for input because we are at left border
  addiu $s0,$s0, 252		# Update location 
  b loop
  

# function that writes diagonally from left to right downward when X is pressed
handleKeyX:
  lw $t5, 0($s0)		# load color of current pixel
  or $t5, $t5, $s3		# or color of next pixel with current color
  sw $t5, 0($s0)  		# Write to the screen with color
  andi $t5, $s0, 0xff		# and current location with 0xff to see if bottom byte is zero or not
  beq $t5, 248, loop		# if bottom byte is zero branch back to loop for input because we are at left border
  li $t5, BAD			# Load base address into $t5
  addi $t5, $t5, 15872		# Load address of last pixel in row two
  bgtu $s0, $t5, loop		# Branch if the current location is right above the lower border 
  addiu $s0,$s0, 260		# Update location 
  b loop
  
  
# function that writes diagonally from left to right upward when L is pressed
handleKeyL:
  lw $t5, 0($s0)		# load color of current pixel
  or $t5, $t5, $s3		# or color of next pixel with current color
  sw $t5, 0($s0)  		# Write to the screen with color
  li $t5, BAD			# Load base address into $t5
  addi $t5, $t5, 512		# Load address of first pixel in row two
  bltu $s0, $t5, loop		# Branch if the current location is right below the border
  andi $t5, $s0, 0xff		# and current location with 0xff to see if bottom byte is zero or not
  beq $t5, 248, loop		# if bottom byte is zero branch back to loop for input because we are at left border
  addiu $s0,$s0, -252		# Update location 
  b loop

# function that writes diagonally from right to left upward when K is pressed   
handleKeyK:
  lw $t5, 0($s0)		# load color of current pixel
  or $t5, $t5, $s3		# or color of next pixel with current color
  sw $t5, 0($s0)  		# Write to the screen with color
  li $t5, BAD			# Load base address into $t5
  addi $t5, $t5, 512		# Load address of first pixel in row two
  bltu $s0, $t5, loop		# Branch if the current location is right below the border 
  andi $t5, $s0, 0xff		# and current location with 0xff to see if bottom byte is zero or not
  beq $t5, 4, loop		# if bottom byte is zero branch back to loop for input because we are at left border
  addiu $s0,$s0, -260		# Update location 
  b loop
  
# changes current color to green if G is pressed
handleKeyG:
  li $s3, GREEN
  li $t0, KC 	
  li $t1, KR			# Key Ready?
  li $t2, THD			# Destination
  li $t3, THR			# is device ready?
  
 
loop3: 
  lw $t4, 0($t1)		# load the value in KR into $t4
  beq $t4, $0, loop3 		# if flag is not set, then loop again
  lw $s1, 0($t0)		# Get key that was pressed and store in $s1
  b handleKeyInput

# changes current color by a value of 0x000D0000 if R is pressed
handleKeyR:
  li $t0, KC 	
  li $t1, KR			# Key Ready?
  li $t2, THD			# Destination
  li $t3, THR			# is device ready?
  
# wait for a key to be pressed so that the new gradient color can be passed 
loop2: 
  
  lw $t4, 0($t1)		# load the value in KR into $t4
  beq $t4, $0, loop2 		# if flag is not set, then loop again
  lw $s1, 0($t0)		# Get key that was pressed and store in $s1
  addi $s3, $s3, 0x00d0300	# add a value to the color to cause a gradient effect
  b handleKeyInput

# changes back to original color whe O is pressed
handleKeyO:
  li $s3, BLU
  b loop
eret
   .text 	
border:
	sub $sp, $sp, 16	# make room on the stack for the registers
  	sw $ra, 0($sp)
  	sw $s1, 4($sp)
  	sw $s2, 8($sp)
  	sw $s0, 12($sp)
  	
  	move $s1, $a0  		# row
  	move $s2, $a1  		# col
  	
	
	mul $s1, $s1, 256	# Each row offsets by 256 bytes (64 x 4 bytes)
	mul $s2, $s2, 4		# Col offset requires offset of 4 bytes
	add $s2, $s1, $s2
	
	move $v0,$s2 		# pass value to $v0 to be used in main

	lw $ra, 0($sp)
  	lw $s1, 4($sp)
  	lw $s2, 8($sp)
  	lw $s0, 12($sp)
  	addi $sp, $sp, 16 	# return stack to previous state
  	
  	jr $ra

border_end: 

   .text
  DRAW_VRT_LINE:
  	# Prolog
  	sub $sp, $sp, 16
  	sw $ra, 0($sp)
  	sw $s0, 4($sp)
  	sw $s1, 8($sp)
  	sw $s2, 12($sp)
  	
  	# Logic
  	move $s0, $a0  			# Color
  	move $s1, $a1  			# base
  	move $s2, $a2  			# Length
  	
  	# init
  	li $t0, 0      			# i = 0
VRT_FOR_LOOP:
	slt $t1, $t0, $s2 		# as long as $t0 is < $s2
	beq $t1, $0, VRT_END_FOR_LOOP
	sw $s0, 0($s1)  		# Write to the screen
	addi $t0, $t0, 1 		# i++
	addi $s1,$s1, 256  
	addi $s0,$s0, 0x0f00000 	# change color by a shade of green each loop
	b VRT_FOR_LOOP

VRT_END_FOR_LOOP:

    	lw $ra, 0($sp)
  	lw $s0, 4($sp)
  	lw $s1, 8($sp)
  	lw $s2, 12($sp)
  	addi $sp, $sp, 16
  	
  	jr $ra
  	
# Horizontal function
  .text
 DRAW_HORIZ_LINE:
  	# Prolog
  	sub $sp, $sp, 16
  	sw $ra, 0($sp)
  	sw $s0, 4($sp)
  	sw $s1, 8($sp)
  	sw $s2, 12($sp)
  	
  	# Logic
  	move $s0, $a0  			# Color
  	move $s1, $a1  			# base
  	move $s2, $a2  			# Length
  	
  	# init
  	li $t0, 0      			# i = 0
DHL_FOR_LOOP:
	slt $t1, $t0, $s2 		# as long as $t0 is < $s2
	beq $t1, $0, DHL_END_FOR_LOOP
	  sw $s0, 0($s1)  		# Write to the screen
	  addi $t0, $t0, 1 		# i++
	  addi $s1,$s1, 4
	  addi $s0,$s0, 0x0d00000  
	  b DHL_FOR_LOOP

DHL_END_FOR_LOOP:
  	
  	# Epilog
  	
  	lw $ra, 0($sp)
  	lw $s0, 4($sp)
  	lw $s1, 8($sp)
  	lw $s2, 12($sp)
  	addi $sp, $sp, 16
  	
  	jr $ra
EXIT:

   li $v0, 10				# Exit cleanly
   syscall

#============================================================================
# Filename: p01
# Name: Zachary McKernan
# Date: 10.20.2021
#
# Description
# 
#
# Register usage:
# s0 = size n of the game
# s1 = status of game (1 = unfinished, 0 = finished)
#============================================================================

#############################################################################
#                                                                           #
# Text Segment                                                              #
#                                                                           #
#############################################################################
			.text
			.globl main
#\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
# PRINT GAME STATE
#////////////////////////////////////////////////////////////////////////////
print_game:
			# a0 = address of game_state
			# a1 = size n
			addiu	$sp, $sp, -4
			sw		$a0, 0($sp)
			
			# move address to safe variable
			move	$t2, $a0
			
			# print newline
			#li		$a0, 10
			#li		$v0, 11
			#syscall
			
			# we will print n rows
			li		$t0, 0

			# loop for each row
print_row_LOOP:
			bge		$t0, $a1, print_row_END
			# first print a row of + and -
			li		$t1, 0
			
print_border_LOOP:
			bge		$t1, $a1, print_border_END
			# print a +- for each iteration of this
			li		$a0, 43
			li		$v0, 11
			syscall
			li		$a0, 45
			li		$v0, 11
			syscall
			addi	$t1, $t1, 1
			j		print_border_LOOP
			
print_border_END:
			# print final + and \n
			li		$a0, 43
			li		$v0, 11
			syscall
			li		$a0, 10
			li		$v0, 11
			syscall
			
			# now print a row of | and the char at address
			li		$t1, 0
			
print_move_LOOP:
			bge		$t1, $a1, print_move_END
			# print a |
			li		$a0, 124
			li		$v0, 11
			syscall
			
			# lb at s1 and print
			lb		$a0, 0($t2)
			li		$v0, 11
			syscall
			
			addi	$t1, $t1, 1
			addiu	$t2, $t2, 1
			j 		print_move_LOOP
			
print_move_END:
			# print a final | and newline
			li		$a0, 124
			li		$v0, 11
			syscall
			
			li		$a0, 10
			li		$v0, 11
			syscall
			
			addi	$t0, $t0, 1
			j		print_row_LOOP
			
print_row_END:

			# we need to print a final +- row
						li		$t1, 0
			
print_final_LOOP:
			bge		$t1, $a1, print_final_END
			# print a +- for each iteration of this
			li		$a0, 43
			li		$v0, 11
			syscall
			li		$a0, 45
			li		$v0, 11
			syscall
			addi	$t1, $t1, 1
			j		print_final_LOOP
			
print_final_END:
			# print final + and \n
			li		$a0, 43
			li		$v0, 11
			syscall
			li		$a0, 10
			li		$v0, 11
			syscall
			
			jr		$ra
			
#\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
# GAME INITIALIZATION
#////////////////////////////////////////////////////////////////////////////
init:
			# a0 = the address of the string
			# a1 = the size of the game
			# we are writing a1 * a1 spaces to it
			addiu	$sp, $sp, -4
			sw		$a0, 0($sp)
			
			mul		$t0, $a1, $a1
			li		$t1, 0
			
initLOOP:
			# loop to write spaces to string
			bge		$t1, $t0, initEND
			# save space to address location
			li		$t2, 32
			sb		$t2, 0($a0)
			#increment the loop and address
			addiu	$a0, $a0, 1
			addiu	$t1, 1
			j		initLOOP
			
initEND:
			# once we are here we need the cp to play an O
			# in the middle of the board
			lw		$a0, 0($sp)
			
			addi	$t0, $a1, -1
			li		$t1, 2
			div		$t0, $t1
			mflo	$t0
			move	$t1, $t0
			# t0 is now our middle point for both x and y
			# now we write O to this point
			mul		$t0, $t0, $a1
			add		$t0, $t0, $t1
			
			lw		$a0, 0($sp)
			add		$a0, $a0, $t0
			li		$t0, 79
			sb		$t0, 0($a0)
			
			# jump back
			addiu	$sp, $sp, 4
			jr		$ra
			
#\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
# USER MOVE
#////////////////////////////////////////////////////////////////////////////
user_move:
			# a0 = game state string
			# a1 = size n
			# save the address of string for now
			addiu	$sp, $sp, -4
			sw		$a0, 0($sp)
			j 		get_row
			
move_invalid_row:
			la		$a0, invalid
			li		$v0, 4
			syscall
			j 		get_row
			
move_invalid_col:
			la		$a0, invalid
			li		$v0, 4
			syscall
			j 		get_col
			
taken_spot:
			la		$a0, taken
			li		$v0, 4
			syscall
			j 		get_row
			
			#take input until empty spot is entered and spot is in bound
get_row:
			# prompt user
			la		$a0, ent_row
			li		$v0, 4
			syscall
			
			# get row
			li		$v0, 5
			syscall
			move	$t1, $v0
			
			# if t1 is greater than a1, restart loop
			bge		$t1, $a1, move_invalid_row
			j		get_col
			
get_col:
			# keep going and get the column
			la		$a0, ent_col
			li		$v0, 4
			syscall
			
			# get column
			li		$v0, 5
			syscall
			move	$t2, $v0
			
			# if t2 is greater than a1, restart loop
			bge		$t2, $a1, move_invalid_col
			j 		check_open
			
check_open:
			# calculate the string position
			lw		$a0, 0($sp)
			mul		$t3, $t1, $a1
			add		$t3, $t3, $t2
			
			# load the byte at position
			add		$a0, $a0, $t3
			lb		$t0, 0($a0)
			
			# check if it is a space
			li		$t1, 32
			bne		$t0, $t1, taken_spot
			
			# if it is, write an X to it
			li		$t0, 88
			sb		$t0, 0($a0)
			
			# we can leave at this point
			jr		$ra
			
#\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
# CHECK WIN
#////////////////////////////////////////////////////////////////////////////
check_win:
			# a0 = string address
			# a1 = size n
			# first check across each row
			addiu	$sp, $sp, -4
			sw		$a0, 0($sp)
			
			# initialize counts of player moves in col, row, diag
			# user
			li		$t4, 0
			# cp
			li		$t5, 0
			
#==============================================	
# ROWS
#==============================================
			li		$t1, 0
check_row_LOOP:
			bge		$t1, $a1, check_row_END
			
			# inner loop of each value in the row
			li		$t2, 0
check_row_inner_LOOP:
			bge		$t2, $a1, check_row_inner_END
			# load the byte at position in t0
			lb		$t3, 0($a0)
			seq		$t6, $t3, 79
			add		$t5, $t5, $t6
			
			seq		$t6, $t3, 88
			add		$t4, $t4, $t6
			
			addiu	$a0, $a0, 1
			addi	$t2, $t2, 1
			j 		check_row_inner_LOOP
			
check_row_inner_END:
			# check if either player won on that row
			beq		$t4, $a1, win_user
			beq		$t5, $a1, win_cp
			# if not, reset row counters and go to next row
			li		$t4, 0
			li		$t5, 0
			addi	$t1, $t1, 1
			j 		check_row_LOOP
					
check_row_END:
#==============================================
		
#==============================================	
# COLS
#==============================================		
			# now we check the columns
			#lw		$a0, 0($sp)
			
			li		$t4, 0
			li		$t5, 0
			
			li		$t1, 0
check_col_LOOP:
			bge		$t1, $a1, check_col_END
			lw		$a0, 0($sp)
			add		$a0, $a0, $t1
			
			# now check the rest of the values in the col
			li		$t2, 0
check_col_inner_LOOP:
			bge		$t2, $a1, check_col_inner_END
			lb		$t3, 0($a0)
			seq		$t6, $t3, 79
			add		$t5, $t5, $t6
			
			seq		$t6, $t3, 88
			add		$t4, $t4, $t6
			
			addi	$t2, $t2, 1
			add		$a0, $a0, $a1
			j 		check_col_inner_LOOP

check_col_inner_END:
			beq		$t4, $a1, win_user
			beq		$t5, $a1, win_cp
			li		$t4, 0
			li		$t5, 0
			addi	$t1, $t1, 1
			j		check_col_LOOP

check_col_END:
#==============================================

#==============================================	
# TOP LEFT BOTTOM RIGHT DIAG
#==============================================	
			lw		$a0, 0($sp)
			li		$t4, 0
			li		$t5, 0
			
			li		$t0, 0
			#mul		$t1, $a1, $a1
			#addi	$t1, $t1, -1
check_LR_diag_LOOP:
			bge		$t0, $a1, check_LR_diag_END
			lb		$t2, 0($a0)
			seq		$t3, $t2, 79
			add		$t5, $t5, $t3
			
			seq		$t3, $t2, 88
			add		$t4, $t4, $t3
			
			addi	$t0, $t0, 1
			move	$t6, $a1
			addi	$t6, $t6, 1
			add		$a0, $a0, $t6
			j 		check_LR_diag_LOOP
			
check_LR_diag_END:
			beq		$t4, $a1, win_user
			beq		$t5, $a1, win_cp
#==============================================

#==============================================	
# TOP RIGHT BOTTOM LEFT DIAG
#==============================================	
			lw		$a0, 0($sp)
			li		$t4, 0
			li		$t5, 0
			
			li		$t0, 0
check_RL_diag_LOOP:
			bge		$t0, $a1, check_RL_diag_END
			move	$t1, $a1
			addi	$t1, $t1, -1
			add		$a0, $a0, $t1
			
			lb		$t1, 0($a0)
			seq		$t2, $t1, 79
			add		$t5, $t5, $t2
			
			seq		$t2, $t1, 88
			add		$t4, $t4, $t2
			
			add		$t0, $t0, 1
			j 		check_RL_diag_LOOP
			
check_RL_diag_END:
			beq		$t4, $a1, win_user
			beq		$t5, $a1, win_cp
#==============================================

#==============================================	
# CHECK IF DRAW
#==============================================	
			lw		$a0, 0($sp)
			li		$t4, 0
			
			li		$t0, 0
			move	$t1, $a1
			mul		$t1, $t1, $t1
			
check_draw_LOOP:
			bge		$t0, $t1, check_draw_END
			lb		$t2, 0($a0)
			
			seq		$t3, $t2, 32
			add		$t4, $t4, $t3
			
			addiu	$a0, $a0, 1
			addi	$t0, $t0, 1
			j 		check_draw_LOOP
			
check_draw_END:
			beq		$t4, $0, is_draw
			li		$v0, 1
			addiu	$sp, $sp, 4
			jr		$ra
			
			
#==============================================
# game endings
#==============================================	
win_user:
			# display winngin dialog
			la		$a0, user_win
			li		$v0, 4
			syscall
			
			# return value 0
			li		$v0, 0
			addiu	$sp, $sp, 4
			jr		$ra
			
win_cp:
			# display winning dialog
			la		$a0, cp_win
			li		$v0, 4
			syscall
			
			# return value 0 to end game loop
			li		$v0, 0
			addiu	$sp, $sp, 4
			jr		$ra	
			
is_draw:
			la		$a0, draw
			li		$v0, 4
			syscall
			li		$v0, 0
			addiu	$sp, $sp, 4
			jr		$ra
			
#\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
# CP MOVE
#////////////////////////////////////////////////////////////////////////////
cp_move:
			# a0 = address of game state
			# a1 = size of nI
			addiu	$sp, $sp, -4
			sw		$a0, 0($sp)
			
			li		$t4, 0
			li		$t5, 0
			
#==============================================
# Check rows for win
#==============================================	
			li		$t0, 0
cp_move_row_LOOP:
			bge		$t0, $a1, cp_move_row_END
			# check each value on the row
			li		$t4, 0
			li		$t5, 0
			li		$t1, 0
cp_move_row_inner_LOOP:
			bge		$t1, $a1, cp_move_row_inner_END
			lb		$t2, 0($a0)
			seq		$t3, $t2, 79
			add		$t5, $t5, $t3
			
			seq		$t3, $t2, 88
			add		$t4, $t4, $t3
			
			addiu	$a0, $a0, 1
			addi	$t1, $t1, 1
			j 		cp_move_row_inner_LOOP
			
cp_move_row_inner_END:
			# check to see if there is n - 1 of user or cp
			# if so, move on the whitespace on that row
			move	$t6, $a1
			addi	$t6, $t6, -1
			
			#beq		$t4, $t6, block_on_row
			beq		$t5, $t6, win_on_row
			j 		cp_move_inner_ITE
cp_move_inner_ITE:
			addi	$t0, $t0, 1
			j 		cp_move_row_LOOP
			
win_on_row:
			bne		$t4, $0, cp_move_inner_ITE
			la		$a0, winning_move
			li		$v0, 4
			syscall
			j 		move_on_row
			
move_on_row:
			lw		$a0, 0($sp)
			# get starting row
			mul		$t0, $t0, $a1
			add		$a0, $a0, $t0
			li		$t0, 0
move_on_row_LOOP:
			bge		$t0, $a1, cp_move_row_END
			lb		$t1, 0($a0)
			seq		$t1, $t1, 32
			li		$t2, 1
			beq		$t1, $t2, just_make_move
			#else
			addiu	$a0, $a0, 1
			addi	$t0, $t0, 1
			j 		move_on_row_LOOP
					
cp_move_row_END:
	
#==============================================
# Check cols for win
#==============================================	
			li		$t4, 0
			li		$t5, 0
			lw		$a0, 0($sp)
			
			li		$t0, 0
cp_move_colwin_LOOP:
			bge		$t0, $a1, cp_move_colwin_END
			# reset counters
			li		$t4, 0
			li		$t5, 0
			# reset address
			lw		$a0, 0($sp)
			add		$a0, $a0, $t0
			
			li		$t1, 0
cp_move_colwin_inner_LOOP:
			bge		$t1, $a1, cp_move_colwin_inner_END
			lb		$t2, 0($a0)
			seq		$t3, $t2, 79
			add		$t5, $t5, $t3
			
			seq		$t3, $t2, 88
			add		$t4, $t4, $t3
			
			addi	$t1, $t1, 1
			add	$a0, $a0, $a1
			j 		cp_move_colwin_inner_LOOP
			
cp_move_colwin_inner_END:
			move	$t6, $a1
			addi	$t6, $t6, -1
			
			beq		$t5, $t6, win_on_col
			#beq		$t4, $t6, block_on_col
			j 		cp_move_inner_colwin_ITE
			
cp_move_inner_colwin_ITE:
			addi	$t0, $t0, 1
			j 		cp_move_colwin_LOOP
			
win_on_col:
			bne		$t4, $0, cp_move_inner_colwin_ITE
			la		$a0, winning_move
			li		$v0, 4
			syscall
			j 		move_on_col
			
move_on_col:
			lw		$a0, 0($sp)
			add		$a0, $a0, $t0
			
			li		$t0, 0
move_on_col_LOOP:
			bge		$t0, $a1, cp_move_colwin_END
			lb		$t1, 0($a0)
			seq		$t1, $t1, 32
			li		$t2, 1
			beq		$t1, $t2, just_make_move
			# else
			add	$a0, $a0, $a1
			addi	$t0, $t0, 1
			j 		move_on_col_LOOP	

cp_move_colwin_END:
				
			
#==============================================
# Check LR diagnol for win
#==============================================	
			li		$t4, 0
			li		$t5, 0
			lw		$a0, 0($sp)
			
			li		$t0, 0
cp_move_LRwin_LOOP:
			bge		$t0, $a1, cp_move_LRwin_END
			lb		$t1, 0($a0)
			seq		$t2, $t1, 79
			add		$t5, $t5, $t2
			
			seq		$t2, $t1, 88
			add		$t4, $t4, $t2
			
			addi	$t0, $t0, 1
			move	$t6, $a1
			addi	$t6, $t6, 1
			add		$a0, $a0, $t6
			j 		cp_move_LRwin_LOOP
				
cp_move_LRwin_END:
			move	$t6, $a1
			addi	$t6, $t6, -1
			beq		$t5, $t6, win_on_LR
			j 		cp_move_LRwin_DONE
			
win_on_LR:
			bne		$t4, $0, cp_move_LRwin_DONE
			#else
			la		$a0, winning_move
			li		$v0, 4
			syscall
			
			lw		$a0, 0($sp)
			li		$t0, 0
win_on_LR_LOOP:
			bge		$t0, $a1, cp_move_LRwin_DONE
			lb		$t1, 0($a0)
			seq		$t1, $t1, 32
			li		$t2, 1
			beq		$t1, $t2, just_make_move
			#else
			move	$t6, $a1
			addi	$t6, $t6, 1
			add		$a0, $a0, $t6
			addi	$t0, $t0, 1
			j 		win_on_LR_LOOP
						
cp_move_LRwin_DONE:

#==============================================
# Check RL diagnol for win
#==============================================	
			li		$t4, 0
			li		$t5, 0
			lw		$a0, 0($sp)
			
			move	$t6, $a1
			addi	$t6, $t6, -1
			#add		$a0, $a0, $t6
			
			li		$t0, 0
cp_move_RLwin_LOOP:
			bge		$t0, $a1, cp_move_RLwin_END
			add		$a0, $a0, $t6
			lb		$t1, 0($a0)
			seq		$t2, $t1, 79
			add		$t5, $t5, $t2
			
			seq		$t2, $t1, 88
			add		$t4, $t4, $t2
			
			addi	$t0, $t0, 1
			#add		$a0, $a0, $t6
			j 		cp_move_RLwin_LOOP
			
cp_move_RLwin_END:
			beq		$t5, $t6, win_on_RL
			j 		cp_move_RLwin_DONE
			
win_on_RL:
			bne		$t4, $0, cp_move_RLwin_DONE
			# else
			la		$a0, winning_move
			li		$v0, 4
			syscall
			
			lw		$a0, 0($sp)
			li		$t0, 0
win_on_RL_LOOP:
			bge		$t0, $a1, cp_move_RLwin_DONE
			add		$a0, $a0, $t6
			lb		$t1, 0($a0)
			seq		$t1, $t1, 32
			li		$t2, 1
			beq		$t2, $t1, just_make_move
			#else
			add		$t0, $t0, 1
			j 		win_on_RL_LOOP
				
cp_move_RLwin_DONE:
#==============================================	
# BLOCKING
#==============================================		

			lw		$a0, 0($sp)
#==============================================
# Check rows for blocking
#==============================================	
			li		$t0, 0
cp_move_rowblock_LOOP:
			bge		$t0, $a1, cp_move_rowblock_END
			# check each value on the row
			li		$t4, 0
			li		$t5, 0
			li		$t1, 0
cp_move_rowblock_inner_LOOP:
			bge		$t1, $a1, cp_move_rowblock_inner_END
			lb		$t2, 0($a0)
			seq		$t3, $t2, 79
			add		$t5, $t5, $t3
			
			seq		$t3, $t2, 88
			add		$t4, $t4, $t3
			
			addiu	$a0, $a0, 1
			addi	$t1, $t1, 1
			j 		cp_move_rowblock_inner_LOOP
			
cp_move_rowblock_inner_END:
			# check to see if there is n - 1 of user or cp
			# if so, move on the whitespace on that row
			move	$t6, $a1
			addi	$t6, $t6, -1
			
			beq		$t4, $t6, block_on_row
			j 		cp_moveblock_inner_ITE
cp_moveblock_inner_ITE:
			addi	$t0, $t0, 1
			j 		cp_move_rowblock_LOOP
			
			
block_on_row:
			bne		$t5, $0, cp_moveblock_inner_ITE
			la		$a0, blocked
			li		$v0, 4
			syscall
			j 		moveblock_on_row
			
moveblock_on_row:
			lw		$a0, 0($sp)
			# get starting row
			mul		$t0, $t0, $a1
			add		$a0, $a0, $t0
			li		$t0, 0
move_on_rowblock_LOOP:
			bge		$t0, $a1, cp_move_rowblock_END
			lb		$t1, 0($a0)
			seq		$t1, $t1, 32
			li		$t2, 1
			beq		$t1, $t2, just_make_move
			#else
			addiu	$a0, $a0, 1
			addi	$t0, $t0, 1
			j 		move_on_rowblock_LOOP
					
cp_move_rowblock_END:

#==============================================
# Check cols for blocking
#==============================================	
			li		$t4, 0
			li		$t5, 0
			lw		$a0, 0($sp)
			
			li		$t0, 0
cp_move_colblock_LOOP:
			bge		$t0, $a1, cp_move_colblock_END
			# reset counters
			li		$t4, 0
			li		$t5, 0
			# reset address
			lw		$a0, 0($sp)
			add		$a0, $a0, $t0
			
			li		$t1, 0
cp_move_colblock_inner_LOOP:
			bge		$t1, $a1, cp_move_colblock_inner_END
			lb		$t2, 0($a0)
			seq		$t3, $t2, 79
			add		$t5, $t5, $t3
			
			seq		$t3, $t2, 88
			add		$t4, $t4, $t3
			
			addi	$t1, $t1, 1
			add	$a0, $a0, $a1
			j 		cp_move_colblock_inner_LOOP
			
cp_move_colblock_inner_END:
			move	$t6, $a1
			addi	$t6, $t6, -1
			
			#beq		$t5, $t6, block_on_col
			beq		$t4, $t6, block_on_col
			j 		cp_move_inner_colblock_ITE
			
cp_move_inner_colblock_ITE:
			addi	$t0, $t0, 1
			j 		cp_move_colblock_LOOP
			
block_on_col:
			bne		$t5, $0, cp_move_inner_colblock_ITE
			la		$a0, blocked
			li		$v0, 4
			syscall
			j 		blockmove_on_col
			
blockmove_on_col:
			lw		$a0, 0($sp)
			add		$a0, $a0, $t0
			
			li		$t0, 0
move_on_colblock_LOOP:
			bge		$t0, $a1, cp_move_colblock_END
			lb		$t1, 0($a0)
			seq		$t1, $t1, 32
			li		$t2, 1
			beq		$t1, $t2, just_make_move
			# else
			add	$a0, $a0, $a1
			addi	$t0, $t0, 1
			j 		move_on_colblock_LOOP	

cp_move_colblock_END:

#==============================================
# Check LR diagnol for block
#==============================================	
			li		$t4, 0
			li		$t5, 0
			lw		$a0, 0($sp)
			
			li		$t0, 0
cp_move_LRblock_LOOP:
			bge		$t0, $a1, cp_move_LRblock_END
			lb		$t1, 0($a0)
			seq		$t2, $t1, 79
			add		$t5, $t5, $t2
			
			seq		$t2, $t1, 88
			add		$t4, $t4, $t2
			
			addi	$t0, $t0, 1
			move	$t6, $a1
			addi	$t6, $t6, 1
			add		$a0, $a0, $t6
			j 		cp_move_LRblock_LOOP
				
cp_move_LRblock_END:
			move	$t6, $a1
			addi	$t6, $t6, -1
			beq		$t4, $t6, block_on_LR
			j 		cp_move_LRblock_DONE
			
block_on_LR:
			bne		$t5, $0, cp_move_LRblock_DONE
			#else
			la		$a0, blocked
			li		$v0, 4
			syscall
			
			lw		$a0, 0($sp)
			li		$t0, 0
block_on_LR_LOOP:
			bge		$t0, $a1, cp_move_LRblock_DONE
			lb		$t1, 0($a0)
			seq		$t1, $t1, 32
			li		$t2, 1
			beq		$t1, $t2, just_make_move
			#else
			move	$t6, $a1
			addi	$t6, $t6, 1
			add		$a0, $a0, $t6
			addi	$t0, $t0, 1
			j 		block_on_LR_LOOP
						
cp_move_LRblock_DONE:

#==============================================
# Check RL diagnol for blocking
#==============================================	
			li		$t4, 0
			li		$t5, 0
			lw		$a0, 0($sp)
			
			move	$t6, $a1
			addi	$t6, $t6, -1
			#add		$a0, $a0, $t6
			
			li		$t0, 0
cp_move_RLblock_LOOP:
			bge		$t0, $a1, cp_move_RLblock_END
			add		$a0, $a0, $t6
			lb		$t1, 0($a0)
			seq		$t2, $t1, 79
			add		$t5, $t5, $t2
			
			seq		$t2, $t1, 88
			add		$t4, $t4, $t2
			
			addi	$t0, $t0, 1
			#add		$a0, $a0, $t6
			j 		cp_move_RLblock_LOOP
			
cp_move_RLblock_END:
			beq		$t4, $t6, block_on_RL
			j 		cp_move_RLblock_DONE
			
block_on_RL:
			bne		$t5, $0, cp_move_RLblock_DONE
			# else
			la		$a0, blocked
			li		$v0, 4
			syscall
			
			lw		$a0, 0($sp)
			li		$t0, 0
block_on_RL_LOOP:
			bge		$t0, $a1, cp_move_RLblock_DONE
			add		$a0, $a0, $t6
			lb		$t1, 0($a0)
			seq		$t1, $t1, 32
			li		$t2, 1
			beq		$t2, $t1, just_make_move
			#else
			add		$t0, $t0, 1
			j 		block_on_RL_LOOP
				
cp_move_RLblock_DONE:

#==============================================	
# DEFAULT
#==============================================	
			la		$a0, sep
			li		$v0, 4
			syscall
			# if there are no winning moves
			# and the player doesn't need blocking
			# play on the first white space in the string
			lw		$a0, 0($sp)
			li		$t0, 0
			move	$t9, $a1
			mul		$t9, $t9, $t9
just_move_LOOP:
			bge		$t0, $t9, just_move_END
			lb		$t1, 0($a0)
			seq		$t1, $t1, 32
			li		$t2, 1
			beq		$t1, $t2, just_make_move
			#else
			addiu	$a0, $a0, 1
			addi	$t0, $t0, 1
			j 		just_move_LOOP
			
just_make_move:
			li		$t0, 79
			sb		$t0, 0($a0)
			j 		just_move_END
			
just_move_END:
			addiu	$sp, $sp, 4
			jr		$ra
			
#\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
#\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
# MAIN
#////////////////////////////////////////////////////////////////////////////
#////////////////////////////////////////////////////////////////////////////
main:		
			# dispaly starting dialog
			la		$a0, lets_play
			li		$v0, 4
			syscall
			
			# display size prompt
			la		$a0, size_prompt
			li		$v0, 4
			syscall
			
			# input size
			li		$v0, 5
			syscall
			move	$s0, $v0
			
			# initialize the game
			la		$a0, gamestate
			move	$a1, $s0
			jal		init
			
			# display cp dialog
			la		$a0, cp_jerk
			li		$v0, 4
			syscall
			
			# print the init state of game
			la		$a0, gamestate
			move	$a1, $s0
			jal		print_game
			
			# gameplay loop
			li		$s1, 1
game_LOOP:
			beq		$s1, $0, game_END
			# if the game is still going
			
			# prompt the user for a move
			la		$a0, gamestate
			jal		user_move
			
			# print the game state
			la		$a0, gamestate
			move	$a1, $s0
			jal		print_game
			
			# check for win
			la		$a0, gamestate
			move	$a1, $s0
			jal		check_win
			move	$s1, $v0
			
			beq		$s1, $0, game_END
			
			# make cp move
			la		$a0, gamestate
			move	$a1, $s0
			jal		cp_move
			
			# print the state of the game
			#la		$a0, sep
			#li		$v0, 4
			#syscall
			la		$a0, gamestate
			move	$a1, $s0
			jal		print_game
			
			# check for winner again
			la		$a0, gamestate
			move	$a1, $s0
			jal		check_win
			move	$s1, $v0
			
			j 		game_LOOP
			
game_END:
			#----------------------------------------------------------------
			# Exit
			#----------------------------------------------------------------
			li		$v0, 10			# Exit
			syscall
			
#############################################################################
#                                                                           #
# Data Segment                                                              #
#                                                                           #
#############################################################################
			.data
lets_play:		.asciiz "Let's play a game of tic-tac-toe.\n"
size_prompt:	.asciiz "Enter n: "
cp_jerk:		.asciiz "I'll go first.\n"
ent_row:		.asciiz "Enter row: "
ent_col:		.asciiz "Enter column: "
invalid:		.asciiz "Invalid coordinate. Enter again.\n"
taken:			.asciiz "Spot is taken. Enter again.\n"
draw:			.asciiz "We have a draw!\n"
cp_win:			.asciiz "I'm the winner!\n"
user_win:		.asciiz "You're the winner!\n"
sep:			.asciiz "=====================\nI have made a move...\n=====================\n"
blocked:		.asciiz "=====================\nWhoops! Too bad!\n=====================\n"
winning_move:	.asciiz "=====================\nNow isn't that convenient!\n=====================\n"
gamestate:		.space 1000

#EOF
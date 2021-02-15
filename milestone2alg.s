.text 	@ instruction memory
	.global main

main:

	MOV R4, #0 @ state = 0
	
	InfiniteLoop:

		@ ------ Code for Input Start ------

		@ print "Input : " text
		ldr r0, =format1
		bl printf

		@ take input (either 1 or 0) from user
		sub sp, sp, #4 
		ldr r0, =format2 
		mov r1, sp 
		bl scanf
		ldr r1, [sp,#0]  @ r1 is loaded with user input
		add sp, sp, #4 

		@ ------ Code for Input End ------

		@ R1 -> input
		@ R4 -> state

		State0:
			CMP R4, #0 		@ to check if state == 0
			BNE State1 		@ go to State1 if state != 0

			CMP R1, #0 		@ to check if input == 0
			MOVEQ R4, #1 	@ if input == 0, state = 1
			MOVNE R4, #0	@ if input != 0, state = 0
			B StateCheckExit

		State1:
			CMP R4, #1 	@ to check if state == 1
			BNE State2 	@ go to State2 if state != 1

			CMP R1, #0 		@ to check if input == 0
			MOVEQ R4, #1 	@ if input == 0, state = 1
			MOVNE R4, #2	@ if input != 0, state = 2
			B StateCheckExit

		State2:
			CMP R4, #2 	@ to check if state == 2
			BNE State3 	@ go to State3 if state != 2

			CMP R1, #0 		@ to check if input == 0
			MOVEQ R4, #1 	@ if input == 0, state = 1
			MOVNE R4, #3	@ if input != 0, state = 3
			B StateCheckExit

		State3:
			CMP R4, #3 	@ to check if state == 3
			BNE State4 	@ go to State4 if state != 3

			CMP R1, #0 		@ to check if input == 0
			MOVEQ R4, #1 	@ if input == 0, state = 1
			MOVNE R4, #4	@ if input != 0, state = 4
			B StateCheckExit

		State4:
			CMP R1, #0 		@ to check if input == 0
			MOVEQ R4, #1 	@ if input == 0, state = 1
			MOVNE R4, #0	@ if input != 0, state = 0

		StateCheckExit:

			@ determine lock status (stored in R5) based on current state
			CMP R4, #4
			MOVEQ R5, #1
			MOVNE R5, #0

			@ ------ Code for Results Output Start ------

			@ print lock status
			ldr r0, =format4
			mov r1, r5
			bl printf

			@ print current state
			ldr r0, =format5
			mov r1, r4
			bl printf

			@ ------ Code for Results Output End ------

		B InfiniteLoop
	

	@ --------------------------------------------------
	@ return from main function
	mov pc, lr

	.data	@ data memory
format1: .asciz "\nInput: "
format2: .asciz "%d"
format4: .asciz "Lock status: %d\n"
format5: .asciz "State: %d\n"

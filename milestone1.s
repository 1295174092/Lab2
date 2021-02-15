;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


; Name: Put your name here for labs
; Student Number: Put your student number here for labs
; Lab Section: Put your lab section here for labs
; Description of Code: Turns on User LED D4 with the push of an external button

 
; Original: Copyright 2014 by Jonathan W. Valvano, valvano@mail.utexas.edu



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;ADDRESS DEFINTIONS

;The EQU directive gives a symbolic name to a numeric constant, a register-relative value or a program-relative value


SYSCTL_RCGCGPIO_R            EQU 0x400FE608  ;General-Purpose Input/Output Run Mode Clock Gating Control Register (RCGCGPIO Register)
GPIO_PORTN_DIR_R             EQU 0x40064400  ;GPIO Port N Direction Register address 
GPIO_PORTN_DEN_R             EQU 0x4006451C  ;GPIO Port N Digital Enable Register address
GPIO_PORTN_DATA_R            EQU 0x400643FC  ;GPIO Port N Data Register address
	
GPIO_PORTM_DIR_R             EQU 0x40063400  ;GPIO Port M Direction Register Address (Fill in these addresses)
GPIO_PORTM_DEN_R             EQU 0x4006351C  ;GPIO Port M Direction Register Address (Fill in these addresses)
GPIO_PORTM_DATA_R            EQU 0x400633FC  ;GPIO Port M Data Register Address      (Fill in these addresses) 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Do not alter this section

        AREA    |.text|, CODE, READONLY, ALIGN=2 ;code in flash ROM
        THUMB                                    ;specifies using Thumb instructions
        EXPORT Start

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;Function PortN_Init 
PortN_Init 
    ;STEP 1
    LDR R1, =SYSCTL_RCGCGPIO_R 
    LDR R0, [R1]   
    ORR R0,R0, #0x1000           				          
    STR R0, [R1]               
    NOP 
    NOP   
   
    ;STEP 5
    LDR R1, =GPIO_PORTN_DIR_R   
    LDR R0, [R1] 
    ORR R0,R0, #0x3         
	STR R0, [R1]   
    
    ;STEP 7
    LDR R1, =GPIO_PORTN_DEN_R   
    LDR R0, [R1] 
    ORR R0, R0, #0x3                                    
    STR R0, [R1]  
    BX  LR                            
 
PortM_Init 
    ;STEP 1 
	LDR R1, =SYSCTL_RCGCGPIO_R       
	LDR R0, [R1]   
    ORR R0,R0, #0x800 
	STR R0, [R1]   
    NOP 
    NOP   
 
    ;STEP 5
    LDR R1, =GPIO_PORTM_DIR_R   
    LDR R0, [R1] 
    ORR R0,R0, #0x0         
	STR R0, [R1]   
    
	;STEP 7
    LDR R1, =GPIO_PORTM_DEN_R   
    LDR R0, [R1] 
    ORR R0, R0, #0x11          
	                          
    STR R0, [R1]    
	BX  LR                     


State_Init 

            LDR R5,=GPIO_PORTN_DATA_R  ;Locked is the Initial State
	        MOV R4,#2_00000001
	        STR R4,[R5]
	        BX LR 
            
Start                             
	        BL  PortN_Init                
	        BL  PortM_Init
	        BL  State_Init
            LDR R0, = GPIO_PORTM_DATA_R

Loop
	        MOV R10,#0      ;R10 stores the state number
	        LDR R1,[R0]
State0
			AND R7,R1,#2_00010000
			CMP R7,#2_00010000
			ANDEQ R8,R1,#2_00000001 ;if equal, means button is pushed and binary input are taken by the Micro controller, use mask to remove the interference of unwanted bit
			ANDNE R8,R1,#2_00000000 ;if not equal, mask all bits of input
			CMP R10, #0 		; to check if state == 0
			BNE State1 		; go to State1 if state != 0

			CMP R8, #0 		; to check if input == 0
			MOVEQ R10, #1 	; if input == 0, state = 1
			MOVNE R10, #0	; if input != 0, state = 0
			B StateCheckExit

State1
            

			
			CMP R10, #1 	; to check if state == 1
			BNE State2 	; go to State2 if state != 1

			CMP R8, #0 		; to check if input == 0
			MOVEQ R10, #1 	; if input == 0, state = 1
			MOVNE R10, #2	; if input != 0, state = 2
			B StateCheckExit

State2
            AND R7,R1,#2_00010000
			CMP R7,#2_00010000
			ANDEQ R8,R1,#2_00000001 ;if equal, means button is pushed and binary input are taken by the Micro controller, use mask to remove the interference of unwanted bit
			ANDNE R8,R1,#2_00000000 ;if not equal, mask all bits of input
			
			CMP R10, #2 	; to check if state == 2
			BNE State3 	; go to State3 if state != 2

			CMP R8, #0 		; to check if input == 0
			MOVEQ R10, #1 	; if input == 0, state = 1
			MOVNE R10, #3	; if input != 0, state = 3
			B StateCheckExit

State3      
            AND R7,R1,#2_00010000
			CMP R7,#2_00010000
			ANDEQ R8,R1,#2_00000001 ;if equal, means button is pushed and binary input are taken by the Micro controller, use mask to remove the interference of unwanted bit
			ANDNE R8,R1,#2_00000000 ;if not equal, mask all bits of input
			
			CMP R10, #3 	; to check if state == 3
			BNE State4 	; go to State4 if state != 3

			CMP R8, #0 		; to check if input == 0
			MOVEQ R10, #1 	; if input == 0, state = 1
			MOVNE R10, #4	; if input != 0, state = 4
			B StateCheckExit

State4      
            AND R7,R1,#2_00010000
			CMP R7,#2_00010000
			ANDEQ R8,R1,#2_00000001 ;if equal, means button is pushed and binary input are taken by the Micro controller, use mask to remove the interference of unwanted bit
			ANDNE R8,R1,#2_00000000 ;if not equal, mask all bits of input
			
			CMP R8, #0 		; to check if input == 0
			MOVEQ R10, #1 	; if input == 0, state = 1
			MOVNE R10, #0	; if input != 0, state = 0
			B StateCheckExit

StateCheckExit

			; determine lock status (stored in R10) based on current state
			CMP R10, #4
			MOVEQ R6, #1 ;here R6 indicate the state of overall input. 1 is unlocked and 0 is locked
			MOVNE R6, #0
	                CMP R6,#1
			BEQ Unlocked_State
			BNE Locked_State

Locked_State                    
	        LDR R5,=GPIO_PORTN_DATA_R
	        MOV R4,#2_00000001
	        STR R4,[R5]
	        B Loop
	
Unlocked_State
	        LDR R5, =GPIO_PORTN_DATA_R
	        MOV R4,#2_00000010
	        STR R4, [R5]
	        B Loop
			
         ALIGN   
    END  

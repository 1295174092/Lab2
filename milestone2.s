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

COMBINATION EQU 2_1101
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
    ORR R0,R0, #0x00          
	STR R0, [R1]   
    
	;STEP 7
    LDR R1, =GPIO_PORTM_DEN_R   
    LDR R0, [R1] 
    ORR R0, R0, #0x11          
	                          
    STR R0, [R1]    
	BX  LR                     


State_Init LDR R5,=GPIO_PORTN_DATA_R  ;Locked is the Initial State
	       MOV R4,#2_00000001
	       STR R4,[R5]
	       BX LR 
            
Start                             
	BL  PortN_Init                
	BL  PortM_Init
	BL  State_Init
	LDR R3, =COMBINATION         ;R3 stores our combination
    LDR R0, = GPIO_PORTM_DATA_R
	 
State0
         LDR R1,[R0]		
		 AND R7,R1,#2_00010000;masking off bits
		 AND R2,R1,#2_00000001 ;if equal, means button is pushed and binary input are taken by the Micro controller, use mask to remove the interference of unwanted bit
		 CMP R7,#2_00010000
		 ORREQ R10,R2,R2
		 BNE State0 ;if not equal, mask all bits of input
		 CMP R2,#2_00000000
		 BEQ State1
         BNE State0
State1  
         LSL R10,R10,#0x1
         AND R7,R1,#2_00010000 ;masking off bits		 
		 CMP R7,#2_00010000
         IT EQ
         ANDEQ R6,R1,#2_00000001 ;if equal, means button is pushed and binary input are taken by the Micro controller, use mask to remove the interference of unwanted bit
		 ORREQ R10,R10,R6	 
		 BNE State1 ;if not equal
		 CMP R6,#2_00000001
		 IT EQ 
		 BEQ State2
	     BNE State1

State2  
         LSL R10,R10,#0x1		
		 AND R7,R1,#2_00010000 ;masking off bits
		 CMP R7,#2_00010000
         IT EQ
		 ANDEQ R8,R1,#2_00000001 ;if equal, means button is pushed and binary input are taken by the Micro controller, use mask to remove the interference of unwanted bit
         ORREQ R10,R10,R8
		 BNE State2 ;if not equal, means we are not loading values to R10. keep in this loop
		 CMP R8,#2_00000001
		 IT EQ
		 BEQ State3
	     BNE State1
State3  
         LSL R10,R10,#1		
		 AND R7,R1,#2_00010000 ;masking off bits
		 CMP R7,#2_00010000
         IT EQ 
		 ANDEQ R9,R1,#2_00000001 ;if equal, means button is pushed and binary input are taken by the Micro controller, use mask to remove the interference of unwanted bit
		 ORREQ R10,R10,R9
		 BNE State2 ;if not equal
		 CMP R9,#2_00000001	
		 IT EQ
		 BEQ State4
	     BNE State0

	
State4
	     CMP R10,R3
		 IT EQ
		 BEQ Unlocked_State
		 
Unlocked_State
	LDR R5, =GPIO_PORTN_DATA_R
	MOV R4,#2_00000010
	STR R4, [R5]
	B State0
	
	ALIGN   
    END  

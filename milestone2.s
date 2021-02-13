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

COMBINATION EQU 2_0101
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
    ORR R0, R0, #2_10001          
	                          
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
Loop
			MOV R6, #0x3 ; R6 is a counter FLAG to indicate the shift of bits also how many steps has been done. We execute the following 4 times, the value change in R6 should be 3,2,1,0. At the last time we excute the following loop, last bit shift left of 0 space.
            
			
InputShift  
      LDR R1,[R0]		
			AND R7,R1,#2_00010000 ; R7 stores the current load flag, use mask to remove the interference of unwanted bits
			CMP R7,#2_00010000;checking if it is in the load mode or idle mode
			IT EQ ;giving condition of equal
			ANDEQ R2,R1,#2_00000001 ;if equal, we masking bits to get the data ready to be shift in the next step
			ANDNE R2,R1,#2_00000000 ;if not euqal, we remove all bits
			LSL R9,R2,R6 ;we left shift bits with the space value stored in R6, Then stored the shifted value in R9
			
			SUBNE R6, #0x1 ;subtract R6 by 1,means we finish 1 cycle of this loop
			CMP R6,#0x0
			BGE InputShift
			
			
			AND R9,#2_00001111
			CMP R9,R3
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

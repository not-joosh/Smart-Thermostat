;====================================================================
; Main.asm file generated by New Project wizard
;
; Created   :   Wed NOV 23, 2023
; Processor :   8086
;====================================================================

;--------       INTERUPT PROCEDURES      --------;  

PROCED0 SEGMENT
    ISR0 PROC FAR
    ASSUME CS:PROCED0, DS:DATA
    PUSHF
    PUSH AX
    PUSH DX   
    ORG 01000H
    ; INTR | CONTROLS 120V AIR CONDITIONING UNIT (TURN OFF IF INSUFFICIENT VOLTAGE)       
    ; SIGNAL THAT THERE IS NO POWER FOR "US" AC
    MOV [US_STANDARD_AC], 0d                    
    ; IF THE AIRCON WAS ON, LET'S JUST TURN THE AIRCON OFF, BUT MAINTAIN THE
    ; TOGGLE STATE FOR WHEN THE AIRCON COMES BACK ON
    MOV AL, [US_TOGGLE]
    CMP AL, 0d
    JE EXIT_ISR0    
    
    ; OTHERWISE, LETS TURN IT OFF     
    MOV AL, 0d                          
    OUT THIRD_PORTA, AL ; turning OFF pin of 120_AC
    
    EXIT_ISR0:  
    POP DX
    POP AX
    POPF
    IRET
    ISR0 ENDP
PROCED0 ENDS     

PROCED1 SEGMENT
    ISR1 PROC FAR
    ASSUME CS:PROCED1, DS:DATA
    PUSHF
    PUSH AX
    PUSH DX
    ; INTR | CONTROLS 120V AIR CONDITIONING UNIT (TURN ON IF SUFFICIENT VOLTAGE)       
    ; SIGNAL THAT THERE IS NOW POWER FOR "US" AC
    MOV [US_STANDARD_AC], 1d                    
    ; IF THE AIRCON WAS ON, LET'S JUST TURN THE AIRCON OFF, BUT MAINTAIN THE
    ; TOGGLE STATE FOR WHEN THE AIRCON COMES BACK ON
    MOV AL, [US_TOGGLE]
    CMP AL, 0d
    JE EXIT_ISR1    
    
    ; OTHERWISE LETS TURN IT BACK ON                            
    MOV AL, 1d
    OUT THIRD_PORTA, AL ; turning ON pin of 120_AC
    EXIT_ISR1: 
    POP DX
    POP AX
    POPF
    IRET
    ISR1 ENDP
PROCED1 ENDS    

PROCED2 SEGMENT
    ISR2 PROC FAR
    ASSUME CS:PROCED2, DS:DATA
    PUSHF
    PUSH AX
    PUSH DX
    ; INTR | CONTROLS 220V AIR CONDITIONING UNIT (TURN OFF IF INSUFFICIENT VOLTAGE)      
    ; SIGNAL THAT THERE IS NO POWER FOR "EU" AC
    MOV [EU_STANDARD_AC], 0d                    
    ; IF THE AIRCON WAS ON, LET'S JUST TURN THE AIRCON OFF, BUT MAINTAIN THE
    ; TOGGLE STATE FOR WHEN THE AIRCON COMES BACK ON
    MOV AL, [EU_TOGGLE]
    CMP AL, 0d
    JE EXIT_ISR2    
    
    ; OTHERWISE, LETS TURN IT OFF                              
    MOV AL, 0d
    OUT THIRD_PORTB, AL ; turning OFF pin of 220_AC
    EXIT_ISR2: 
    POP DX
    POP AX
    POPF
    IRET
    ISR2 ENDP
PROCED2 ENDS     

PROCED3 SEGMENT
    ISR3 PROC FAR
    ASSUME CS:PROCED3, DS:DATA
    PUSHF
    PUSH AX
    PUSH DX
    ; INTR | CONTROLS 220V AIR CONDITIONING UNIT (TURN ON IF SUFFICIENT VOLTAGE)       
    ; SIGNAL THAT THERE IS NO POWER FOR "EU" AC
    MOV [EU_STANDARD_AC], 1d                    
    ; IF THE AIRCON WAS ON, LET'S JUST TURN THE AIRCON OFF, BUT MAINTAIN THE
    ; TOGGLE STATE FOR WHEN THE AIRCON COMES BACK ON
    MOV AL, [EU_TOGGLE]
    CMP AL, 1d
    JNE EXIT_ISR3    
    
    ; OTHERWISE LETS TURN IT BACK ON                              
    MOV AL, 1d
    OUT THIRD_PORTB, AL ; turning ON pin of 220_AC
    EXIT_ISR3: 
    POP DX
    POP AX
    POPF
    IRET
    ISR3 ENDP
PROCED3 ENDS 


PROCED4 SEGMENT
    ISR4 PROC FAR
    ASSUME CS:PROCED4, DS:DATA
    PUSHF
    PUSH AX
    PUSH DX
    ; WE WILL BE ADJUSTING TIME USING KEYPAD, SO WE MUST READ THE KEYPAD INPUTS
    ;MOV [ADJUST_REQUESTED], 1d
   
    POP DX
    POP AX
    POPF
    IRET
    ISR4 ENDP
PROCED4 ENDS   


PROCED5 SEGMENT
    ISR5 PROC FAR
    ASSUME CS:PROCED5, DS:DATA
    PUSHF
    PUSH AX
    PUSH DX
    ; CHECK IF US AC HAS POWER
    MOV AL, [US_STANDARD_AC]  
    CMP AL, 0d
    JE EXIT_ISR5
    ; IT HAS POWER AT THIS POINT, WE CAN TOGGLE
    MOV AL, [US_TOGGLE]
    CMP AL, 0d ; CHECK IF IT IS OFF
    JE TURN_ON_INT5 
    ; ITS ON BY THIS POINT, SO WE WILL TURN IT OFF 
    TURN_OFF_INT5:            
        MOV AL, 0d
        OUT THIRD_PORTA, AL
        MOV [US_TOGGLE], 0d   
        ; CHECKING SCHEDULE FLAG IF REQUESTED
        MOV AL, [HOUR]                       
        CMP AL, [SCHEDULED_TIME]
        JGE DISABLE_US_SCHEDULE
        JMP EXIT_ISR5
        DISABLE_US_SCHEDULE:
            MOV [IS_SCHEDULED], 0d
        JMP EXIT_ISR5 
    TURN_ON_INT5:    
        MOV AL, 1d
        MOV [US_TOGGLE], AL
        OUT THIRD_PORTA, AL
    EXIT_ISR5:  
    POP DX
    POP AX
    POPF
    IRET
    ISR5 ENDP
PROCED5 ENDS   

PROCED6 SEGMENT
    ISR6 PROC FAR
    ASSUME CS:PROCED6, DS:DATA
    PUSHF
    PUSH AX
    PUSH DX
    ; CHECK IF US AC HAS POWER
    MOV AL, [EU_STANDARD_AC]  
    CMP AL, 0d
    JE EXIT_ISR6
    ; IT HAS POWER AT THIS POINT, WE CAN TOGGLE
    MOV AL, [EU_TOGGLE]
    CMP AL, 0d ; CHECK IF IT IS OFF
    JE TURN_ON_INT6 
    ; ITS ON BY THIS POINT, SO WE WILL TURN IT OFF
    TURN_OFF_INT6:   
        MOV AL, 0d
        OUT THIRD_PORTB, AL
        MOV [EU_TOGGLE], 0d
        MOV AL, [HOUR]                       
        CMP AL, [SCHEDULED_TIME]
        JGE DISABLE_EU_SCHEDULE
        JMP EXIT_ISR6 
        DISABLE_EU_SCHEDULE:
            MOV [IS_SCHEDULED], 0d
            JMP EXIT_ISR6 
    TURN_ON_INT6:          
        MOV AL, 1d
        MOV [EU_TOGGLE], AL
        OUT THIRD_PORTB, AL
    EXIT_ISR6:   
    POP DX
    POP AX
    POPF
    IRET
    ISR6 ENDP
PROCED6 ENDS  

;-----------------------------;
;-----------------------------;
;-----------------------------;
;-----------------------------;
;-----------------------------;
;-----------------------------;
;-----------------------------;
;-----------------------------;
;-----------------------------;
;-----------------------------;
;-----------------------------;
;-----------------------------;
;-----------------------------;
;-----------------------------;


DATA SEGMENT 
    ;<------------------------------------ 8255'S --->;
    ; FIRST 8255 (LCD + KEYPAD)
    FIRST_PORTA         EQU 0C0H         ; PORTA ADDRESS 
    FIRST_PORTB         EQU 0C2H         ; PORTB ADDRESS 
    FIRST_PORTC         EQU 0C4H         ; PORTC ADDRESS 
    FIRST_COMREG        EQU 0C6H 	     ; COMMAND REGISTER 
                        
    ; SECOND 8255 (ADC + CLOCK TIMER)
    SECOND_PORTA        EQU 0F0H         ; PORTA ADDRESS 
    SECOND_PORTB        EQU 0F2H         ; PORTB ADDRESS 
    SECOND_PORTC        EQU 0F4H         ; PORTC ADDRESS 
    SECOND_COMREG       EQU 0F6H 	     ; COMMAND REGISTER 
    
    
    ; THIRD 8255 (AIRCON CTRL + AIRCON STATUS)
    THIRD_PORTA         EQU 0E0H         ; PORTA ADDRESS 
    THIRD_PORTB         EQU 0E2H         ; PORTB ADDRESS 
    THIRD_PORTC         EQU 0E4H         ; PORTC ADDRESS 
    THIRD_COMREG        EQU 0E6H 	     ; COMMAND REGISTER 
                                    
    SETUP_8255_1        DB 10001001B     ; OUT: A, B -=*=- IN: C
    SETUP_8255_2        DB 10011001B     ; OUT: B    -=*=- IN: A, C
    SETUP_8255_3        DB 10001001B     ; OUT: A,B  -=*=- IN: C
    
    ;<------------------------------------- 8253 --->;
    CLOCK0 	            EQU 0C8H 		
    T_COMREG 	        EQU 0CEH		
    CWORD 	            EQU 00111000B
    
    ;<------------------------------------- 8259 --->;
    PIC1                EQU 0D0H        ; 8259 ADDRESS FOR A0 = 0  		
    PIC2                EQU 0D2H        ; 8259 ADDRESS FOR A0 = 1
    ICW1                EQU 13H                 
    ICW2                EQU 80H         
    ICW4                EQU 03H                         
    OCW1                EQU 10000000B   ; ACTIVE INTERRUPTS                         
    ;<-- KEYPAD VARIABLES -->;         
    KEY0                DB 1101B
    KEY1                DB 0000B
    KEY2                DB 0001B
    KEY3                DB 0010B
    KEY4                DB 0100B 
    KEY5                DB 0101B
    KEY6                DB 0110B
    KEY7                DB 1000B
    KEY8                DB 1001B
    KEY9                DB 1010B
    KEY_STAR            DB 1100B
    KEY_HASH            DB 1110B
    
    ;<-- CUSTOM DATA VARIABLES -->;                 
    ; TIMER RELATED 
    ADJUST_REQUESTED    DB 0d
    TIMER_STR           DB "12:23", "$"
    HOUR                DB 1d
    MINUTES             DB 0d 
    
    ; ADC RELATED     
    NEW_WAIT_PROMPT0    DB "TEMPERATURE", "$"
    NEW_WAIT_PROMPT1    DB "NEEDS TO BE", "$"
    NEW_WAIT_PROMPT2    DB "TURNED DOWN", "$"
    NEW_WAIT_PROMPT3    DB "OR UP", "$"   
    IS_FLAGGED_UNSTABLE DB 0d
    MIN_TEMP            DB 20d ; cant go above 20-30 or else we will trigger the menu
    MAX_TEMP            DB 29d ; 
    CURRENT_TEMP        DB 0d
    LAST_DIGIT_FLAG	DB 0d
    
    ADC_PROMPT0         DB "TEMP:", "$"
    LAST_READ_TEMP      DB 0d
    PREV_ADC_BINARY     DB 0d      
    
    
    ; AIRCON RELATED
    US_PROMPT0          DB "AC-120:  [ON]", "$"  ; 12 LETTERS
    US_PROMPT1          DB "AC-120: [OFF]", "$" ; 13 LETTERS
    US_STANDARD_AC	    DB 0d
    US_TOGGLE		    DB 0d    
    EU_PROMPT0          DB "AC-220:  [ON]", "$"
    EU_PROMPT1          DB "AC-220: [OFF]", "$"    
    EU_STANDARD_AC	    DB 0d
    EU_TOGGLE		    DB 0d  
    IS_SCHEDULED        DB 1d   ; FLAG TO ALLOW USER TO TURN OFF EVEN IF ITS SCHEDULED
    SCHEDULED_TIME       DB 6d   ; try to turn on at 6PM
    
    
DATA ENDS     
STK SEGMENT STACK
    BOS DW 64d DUP(?)
    TOS LABEL WORD
STK ENDS
CODE SEGMENT PUBLIC 'CODE'
    ASSUME CS:CODE, DS:DATA, SS:STK
START:
;                                                 ;
;<-------------------- SETUP  ------------------->;
;                                                 ; 
    ORG 08000H          ; ADDRESS IN MEMORY FOR THIS SEGMENT  
    MOV AX, DATA
    MOV DS, AX          ; SETTING DATA SEGMENT ADDRESS
    MOV AX, STK       
    MOV SS, AX          ; SETTING DATA SEGMENT ADDRESS
    LEA SP, TOS         ; SETTING ADDRESS OF SP AS TOP OF STACK
    CLI                 ; CLEARS "IF" FLAG  
         
    INIT:                        
    ; SETTING UP BOTH 8255'S 
    MOV AL, SETUP_8255_1
	OUT FIRST_COMREG, AL
	 
	MOV AL, SETUP_8255_2
    OUT SECOND_COMREG, AL

	MOV AL, SETUP_8255_3
	OUT THIRD_COMREG, AL

	
    ; SETTING UP THE CLOCK
    MOV DX, T_COMREG
    MOV AL, CWORD
    OUT DX, AL
    
    ;SETUP THE 8259
    MOV DX, PIC1        
    MOV AL, ICW1        
    OUT DX, AL        
    MOV DX, PIC2   
    MOV AL, ICW2  
    OUT DX, AL          
    MOV AL, ICW4      
    OUT DX, AL         
    MOV AL, OCW1        
    OUT DX, AL          
    STI     
                
    STORING_INTERRUPT_VECTOR:
        MOV AX, OFFSET ISR0
        MOV [ES:200H], AX
        MOV AX, SEG ISR0
        MOV [ES:202H], AX 
        
        MOV AX, OFFSET ISR1
        MOV [ES:204H], AX
        MOV AX, SEG ISR1
        MOV [ES:206H], AX    
        
        MOV AX, OFFSET ISR2
        MOV [ES:208H], AX
        MOV AX, SEG ISR2
        MOV [ES:20AH], AX 
        
        MOV AX, OFFSET ISR3
        MOV [ES:20CH], AX
        MOV AX, SEG ISR3
        MOV [ES:20EH], AX  
        
        MOV AX, OFFSET ISR4
        MOV [ES:210H], AX
        MOV AX, SEG ISR4
        MOV [ES:212H], AX 
        
        MOV AX, OFFSET ISR5
        MOV [ES:214H], AX
        MOV AX, SEG ISR5
        MOV [ES:216H], AX 
        
        MOV AX, OFFSET ISR6
        MOV [ES:218H], AX
        MOV AX, SEG ISR6
        MOV [ES:21AH], AX 
        
	
    ; INIT THE LCD
    CALL INIT_LCD
    JMP MAIN  
;                                                 ;
;<------------------- MAIN LOOP ----------------->;
;                                                 ;
    ADJUST_TIME:
        CALL READ_KEY_STROKE  
        MOV [ADJUST_REQUESTED], 0d
    MAIN:     
        ENDLESS:   
            CMP [ADJUST_REQUESTED], 1d 
            JE ADJUST_TIME            
            CALL TIMER_DISPLAY
            CALL AIRCON_STATUS 
            CALL READ_ADC
            CMP AL, [PREV_ADC_BINARY]
            JNE NEXTPHASE
            CALL TIMER_INCREMENT   
            JMP ENDLESS 
        NEXTPHASE: 
            CALL UPDATE_TEMP_DISPLAY 
            TEMPERATURE_CHECK:
                XOR AX, AX
                MOV AL, [CURRENT_TEMP]
                CMP AL, MIN_TEMP
                JL INIT_NEW_WAIT
                CMP AL, MAX_TEMP 
                JG INIT_NEW_WAIT
        JMP MAIN  
        INIT_NEW_WAIT:
            MOV [IS_FLAGGED_UNSTABLE], 1d   
	        CALL INIT_LCD
            MOV AL, 083H
            CALL INST_CTRL
            LEA SI, NEW_WAIT_PROMPT0
            CALL PRINT_STR
            
            MOV AL, 0C3H
            CALL INST_CTRL
            LEA SI, NEW_WAIT_PROMPT1 
            CALL PRINT_STR
            
            MOV AL, 097H
            CALL INST_CTRL
            LEA SI, NEW_WAIT_PROMPT2
            CALL PRINT_STR
            
            MOV AL, 0DAH
            CALL INST_CTRL  
            LEA SI, NEW_WAIT_PROMPT3
            CALL PRINT_STR      
            AWAIT_TEMPERATURE_ADJUSTMENT:
                ENDLESS_WAIT_FOR_ADJUST:
                    CALL READ_ADC
                    CMP AL, [PREV_ADC_BINARY] 
                    JNE CHECK_ADJUSTMENT
                    CALL TIMER_INCREMENT   
                JMP ENDLESS_WAIT_FOR_ADJUST
                CHECK_ADJUSTMENT:
                    CALL UPDATE_TEMP_DISPLAY
                    XOR AX, AX
                    MOV AL, [CURRENT_TEMP]
                    CMP AL, MIN_TEMP
                    JL AWAIT_TEMPERATURE_ADJUSTMENT
                    CMP AL, MAX_TEMP 
                    JG AWAIT_TEMPERATURE_ADJUSTMENT
            SUCCESSFULLY_ADJUSTED:    
                CALL INIT_LCD
                MOV [IS_FLAGGED_UNSTABLE], 0d
                CALL READ_ADC 
                CALL UPDATE_TEMP_DISPLAY
            JMP MAIN   
;--------------- DEBUG -----------------;  
DEBUG PROC   
    RET
DEBUG ENDP  
DEBUG_STOP PROC
    ;CALL DEBUG
    OUT FIRST_PORTA, AL
    ENDLESS_DB:
        JMP ENDLESS_DB 
    RET    
DEBUG_STOP ENDP  
;--------------- FUNCTIONS -----------------;  
TIMER_DISPLAY PROC 
    ; POSITIONING TIMER
    MOV AL, 08EH
    CALL INST_CTRL
          
    XOR BX, BX
    XOR AX, AX
    MOV BL, 10d
    ; LOGIC PRINTING
    MOV AL, [HOUR]  
    CMP AL, 09d
    JLE IS_SINGLE_DIGIT_CASE_HOUR 
    PRINT_FIRST_CHAR_HOUR:
        DIV BL  
        PUSH AX    
        XOR AH, AH
        ADD AL, 30H
        CALL DATA_CTRL
        POP AX 
    PRINT_SECOND_CHAR_HOUR:    
        PUSH AX 
        MOV AL, AH
        XOR AH, AH
        ADD AL, 30H
        CALL DATA_CTRL         
        POP AX        
    CHECK_MINUTES_CASE:
    MOV AL, ":"     
    CALL DATA_CTRL
    MOV AL, [MINUTES]  
    CMP AL, 09d
    JLE IS_SINGLE_DIGIT_CASE_MINUTES
    PRINT_FIRST_CHAR_MINUTES:
        DIV BL  
        PUSH AX    
        XOR AH, AH
        ADD AL, 30H
        CALL DATA_CTRL
        POP AX 
    PRINT_SECOND_CHAR_MINUTES:
        PUSH AX 
        MOV AL, AH
        XOR AH, AH
        ADD AL, 30H
        CALL DATA_CTRL
        POP AX
        JMP EXIT_TIMER_DISPLAY
    IS_SINGLE_DIGIT_CASE_HOUR: 
        MOV AL, "0"
        CALL DATA_CTRL
        MOV AL, [HOUR]         
        ; CHECKING IF ITS SCHEDULED TO TURN ON AT THIS HOUR
        CMP AL, [SCHEDULED_TIME]
        JGE TRY_TO_TURN_ON_AIRCONS ; 6 PM OR GREATER
        CONTINUE_DISPLAY_UPDATE:
            ADD AL, 30H
            CALL DATA_CTRL
            XOR AX, AX 
            JMP CHECK_MINUTES_CASE
        TRY_TO_TURN_ON_AIRCONS:  
            CMP [IS_SCHEDULED], 0d ; CHECK IF USER DISABLED SCHEDULE BY CLICKING TOGGLE INPUT
            JE STOP_AND_GO_NEXT_INST
            ; OTHERWISE, TRY TO TURN ON AIRCONS
            CALL AIRCON_SCHEDULE_PROTOCOL
            STOP_AND_GO_NEXT_INST:
            JMP CONTINUE_DISPLAY_UPDATE
    IS_SINGLE_DIGIT_CASE_MINUTES:
        MOV AL, "0"
        CALL DATA_CTRL
        MOV AL, [MINUTES]
        ADD AL, 30H
        CALL DATA_CTRL
        XOR AX, AX 
    EXIT_TIMER_DISPLAY:     
    RET
TIMER_DISPLAY ENDP
TIMER_INCREMENT PROC
    ;MOV AL, 08FH
    ;CALL INST_CTRL
    ;LEA SI, TIMER_STR
    ;CALL PRINT_STR
    ; 080H -> 093H
    ; 0C0H -> 0D3H
    ; 094H -> 0A7H
    ; 0D4H -> 0E7H
    
    ; 12:59          
    XOR AX, AX
    TIMER_INC:
        MOV AL, [MINUTES]  
        CMP AL, 59d
        JE CHECK_TIMER_RESET
        MINUTES_INCREMENT:
        INC [MINUTES]  
        JMP EXIT_TIMER_INC
        CHECK_TIMER_RESET:
            MOV AL, [HOUR]
            CMP AL, 12d
            JE RESET_TIMER
            GO_TO_NEXT_HOUR:
                INC [HOUR]
                MOV [MINUTES], 0d
                JMP EXIT_TIMER_INC
            RESET_TIMER:
                MOV [HOUR], 1d
                MOV [MINUTES], 0d 
                MOV [IS_SCHEDULED], 1d; FLAG FOR SCHEDULER
                JMP EXIT_TIMER_INC
    EXIT_TIMER_INC:    
    RET   
TIMER_INCREMENT ENDP 
AIRCON_SCHEDULE_PROTOCOL PROC
    PUSH AX
    TRYING_TO_TURNON_AIRCONS:
        MOV AL, [US_STANDARD_AC] 
        CMP AL, 0d
        JE US_HAS_NO_POWER_SO_TRY_NEXT 
        ; 120V HAS POWER, SO LETS TURN ON AND SET THE FLAGS
	MOV AL, 1d
        OUT THIRD_PORTA, AL
        MOV [US_TOGGLE], 1d
    US_HAS_NO_POWER_SO_TRY_NEXT:
        MOV AL, [EU_STANDARD_AC] 
        CMP AL, 0d
        JE EU_HAS_NO_POWER_SO_EXIT 
	MOV AL, 1d	
        OUT THIRD_PORTB, AL
        MOV [EU_TOGGLE], 1d
    EU_HAS_NO_POWER_SO_EXIT:
    POP AX
    RET
AIRCON_SCHEDULE_PROTOCOL ENDP
AIRCON_STATUS PROC
    ; 080H -> 093H
    ; 0C0H -> 0D3H
    ; 094H -> 0A7H
    ; 0D4H -> 0E7H
    
    MOV AL, [US_STANDARD_AC]
    CMP AL, 1d  
    JE LABEL_US_SUCCESS
    LABEL_US_FAILURE: 
        MOV AL, 094H
        CALL INST_CTRL
        LEA SI, US_PROMPT1
        CALL PRINT_STR   
    CHECK_NEXT_LABEL:
    MOV AL, [EU_STANDARD_AC]
    CMP AL, 1d
    JE LABEL_EU_SUCCESS
    LABEL_EU_FAILURE: 
        MOV AL, 0D4H
        CALL INST_CTRL
        LEA SI, EU_PROMPT1
        CALL PRINT_STR
        JMP PROCEED_NEXT_INSTR 
    LABEL_US_SUCCESS:
        MOV AL, 094H
        CALL INST_CTRL 
        LEA SI, US_PROMPT0
        CALL PRINT_STR
        JMP CHECK_NEXT_LABEL
    LABEL_EU_SUCCESS:  
        MOV AL, 0D4H
        CALL INST_CTRL
        LEA SI, EU_PROMPT0 
        CALL PRINT_STR
    PROCEED_NEXT_INSTR: 
    RET
AIRCON_STATUS ENDP
;                                                 ;
;<-------------------    ADC    ----------------->;
;                                                 ;   

READ_ADC PROC
    PULSE_ADC:
        XOR AX, AX
        MOV DX, SECOND_PORTB
        MOV AL, 07H
        OUT DX, AL
        CALL DELAY
        
        XOR AX, AX
        MOV DX, SECOND_PORTB
        MOV AL, 15d
        OUT DX, AL
        CALL DELAY
        
        MOV DX, SECOND_PORTB
        MOV AL, 00H
        OUT DX, AL
    BUFFER_DATA:
        XOR AX, AX
        MOV DX, SECOND_PORTC 
        MOV AL, 01H
        OUT DX, AL 
        CALL DELAY
        XOR AX, AX
        MOV DX, SECOND_PORTA
        IN AL, DX 
        PUSH AX
        XOR AX, AX
        MOV DX, SECOND_PORTC 
        MOV AL, 00H
        OUT DX, AL 
        POP AX
    RET
READ_ADC ENDP

UPDATE_TEMP_DISPLAY PROC 
    MOV [LAST_DIGIT_FLAG], 0d
    MOV [CURRENT_TEMP], 0d
    MOV [PREV_ADC_BINARY], AL
    CMP [IS_FLAGGED_UNSTABLE], 1d
    JE FLAGGED_TO_SKIP1
    PUSH AX 
    REINIT_SCREEN:
        ; PRINTING "TEMP:"  
        MOV AL, 080H
        CALL INST_CTRL
        LEA SI, ADC_PROMPT0                         
        CALL PRINT_STR      
        
        ; PRINTING "C"
        MOV AL, 0C3H
        CALL INST_CTRL
        MOV AL, "C"
        CALL DATA_CTRL 
        
        MOV AL, 0C2H
        CALL INST_CTRL
        MOV AL, " "
        CALL DATA_CTRL
        
        MOV AL, 0C1H
        CALL INST_CTRL
        MOV AL, " "
        CALL DATA_CTRL
    POP AX 
    FLAGGED_TO_SKIP1:
    DECODING_ADC: 
        XOR BX, BX
        MOV BL, 10d
        MUL BX
        MOV BL, 17d
        DIV BX
        
        MOV BL, 10d   
        XOR DX, DX      
        MOV DL, 083H 
    CMP [IS_FLAGGED_UNSTABLE], 1d
    JE FLAGGED_TO_SKIP2
    PUSH AX
    MOV AL, 0C3H   
    CALL INST_CTRL
    MOV AL, "C"
    CALL DATA_CTRL
    POP AX
    FLAGGED_TO_SKIP2:                
    PRINT_TEMPERATURE_LOOP:       
        XOR AH, AH
        DIV BL
        CMP AL, 0d ; AH 9
        JE VALIDATE_EXIT
        FINAL_PRINT:        
            PUSH AX       
            MOV AL, DL
            CALL INST_CTRL
            PRINT_C_CHAR:
                POP AX
                PUSH AX  
                MOV AL, AH 
                MOV DH, [LAST_DIGIT_FLAG]
                CMP DH, 1d
                JE SKIP_SAVE_READING
                MOV DH, AL
                MOV [CURRENT_TEMP], DH ; READING SECOND DIGIT 32^C -> 2^C
                SKIP_SAVE_READING:
                    ADD AL, 30H
                    CMP [IS_FLAGGED_UNSTABLE], 1d
                    JE FLAGGED_TO_SKIP3
                    CALL DATA_CTRL  
                    FLAGGED_TO_SKIP3:
                    POP AX                   
            JMP NEXT_CHAR
        VALIDATE_EXIT:
            CMP AH, 0d
            JE EXIT_PRINT_SEQ 
            CALCULATE_CURRENT_TEMP:
                PUSH AX      
                MOV AL, AH
                XOR AH, AH
                MUL BL
                ADD [CURRENT_TEMP], AL
		        MOV [LAST_DIGIT_FLAG], 1d
                POP AX
            JMP FINAL_PRINT           
        NEXT_CHAR:
        SUB DL, 1H
        JMP PRINT_TEMPERATURE_LOOP 
    EXIT_PRINT_SEQ:                
    ;CALL PRINT_SAVED_TEMP   ; DELETE LATER 
    RET
UPDATE_TEMP_DISPLAY ENDP
PRINT_SAVED_TEMP PROC
    XOR AX, AX
    XOR BX, BX
    XOR DX, DX
    MOV BL, 10d
    
    MOV AL, 0E6H
    CALL INST_CTRL        
    
    MOV AL, [CURRENT_TEMP]
    DIV BL
        PUSH AX
        XOR AH, AH
        ADD AL, 30H
        CALL DATA_CTRL
        POP AX    
    MOV AH, AL
    XOR AH, AH 
    ADD AL, 30H
    CALL DATA_CTRL   
    RET
PRINT_SAVED_TEMP ENDP

;                                                 ;
;<------------------- FUNCTIONS ----------------->;
;                                                 ;   

READ_KEY_STROKE PROC
    ; THIS PROCESS IS THE RESPONSE TO MAIN MENU INPUT
    IN AL, FIRST_PORTC
    CMP AL, KEY0 
    JE IS_KEY0_1
    
    CMP AL, KEY1
    JE IS_KEY1_1
    
    CMP AL, KEY2
    JE IS_KEY2_1
    
    CMP AL, KEY3
    JE IS_KEY3_1
    
    CMP AL, KEY4
    JE IS_KEY4_1
    
    CMP AL, KEY5
    JE IS_KEY5_1
    
    CMP AL, KEY6
    JE IS_KEY6_1
    
    CMP AL, KEY7 
    JE IS_KEY7_1
    
    CMP AL, KEY8
    JE IS_KEY8_1
    
    CMP AL, KEY9  
    JE IS_KEY9_1
    ; IS NOT A VALID KEY AT THIS POINT
    JMP STOP_READ_KEY
    IS_KEY0_1:   
    MOV [MINUTES], 0d
    JMP KEY_READ_TRUE
    IS_KEY1_1:
    MOV [HOUR], 1d
    JMP KEY_READ_TRUE
    IS_KEY2_1:
    MOV [HOUR], 2d
    JMP KEY_READ_TRUE
    IS_KEY3_1:
    MOV [HOUR], 3d
    JMP KEY_READ_TRUE
    IS_KEY4_1:
    MOV [HOUR], 4d
    JMP KEY_READ_TRUE
    IS_KEY5_1:
    MOV [HOUR], 5d
    JMP KEY_READ_TRUE
    IS_KEY6_1:
    MOV [HOUR], 6d
    JMP KEY_READ_TRUE
    IS_KEY7_1:
    MOV [HOUR], 7d
    JMP KEY_READ_TRUE
    IS_KEY8_1:
    MOV [HOUR], 8d
    JMP KEY_READ_TRUE
    IS_KEY9_1:
    MOV [HOUR], 9d
    JMP KEY_READ_TRUE
    KEY_READ_TRUE:             
    MOV [ADJUST_REQUESTED], 0d
    STOP_READ_KEY:  
    RET
READ_KEY_STROKE ENDP
;                                                 ;
;<----------------- LCD COMMANDS ---------------->;
;                                                 ;
PRINT_STR PROC 
    PRINT_LOOP:
        MOV AL, [SI]
        CMP AL, "$"
        JE EXIT_PRINT  
        CALL DATA_CTRL
        INC SI
        JMP PRINT_LOOP
    EXIT_PRINT:
        RET
PRINT_STR ENDP  

DATA_CTRL PROC  
    ; PRINT CHARACTER         
    MOV DX, FIRST_PORTA
    OUT DX, AL
    
    MOV DX, FIRST_PORTB
    MOV AL, 03H
    OUT DX, AL
    
    CALL DELAY
    MOV DX, FIRST_PORTB
    MOV AL, 01H
    OUT DX, AL
    RET
DATA_CTRL ENDP    

DATA_CTRL_TEST PROC  
    ; PRINT CHARACTER         
    MOV DX, FIRST_PORTA
    OUT DX, AL
    
    MOV DX, FIRST_PORTB
    MOV AL, 03H
    OUT DX, AL
    
    CALL DELAY
    MOV DX, FIRST_PORTB
    MOV AL, 01H
    OUT DX, AL
    RET
DATA_CTRL_TEST ENDP  

INIT_LCD PROC
    ; SELECT LCD OF 2 ROWS
    MOV AL, 38H
    CALL INST_CTRL
    
    
    
    MOV AL, 08H
    CALL INST_CTRL
    
    MOV AL, 01H
    CALL INST_CTRL
    
    MOV AL, 06H
    CALL INST_CTRL
    
    MOV AL, 0CH
    CALL INST_CTRL
    RET
INIT_LCD ENDP

INST_CTRL PROC
    ; HIGH TO LOW
    MOV DX, FIRST_PORTA 
    OUT DX, AL
    
    MOV DX, FIRST_PORTB 
    MOV AL, 02H 
    OUT DX, AL
    
    CALL DELAY
    
    MOV DX, FIRST_PORTB ; MOVE BACK TO LOW
    MOV AL, 00H
    OUT DX, AL
    RET
INST_CTRL ENDP

;                                                 ;
;<----------- CLOCK AND MANUAL DELAYS ----------->;
;                                                 ;

DELAY_CLOCK PROC
    MOV DX, CLOCK0
    MOV AL, 0D0H   ; 0A0H
    OUT DX, AL
    MOV AL, 07H
    OUT DX, AL
    WAITING:
        MOV DX, THIRD_PORTC
        IN AL, DX
        CMP AL, 00H
        JNE WAITING
    RET
DELAY_CLOCK ENDP


DELAY PROC
    MOV CX, 0FFFH
    DELAY_LOOP:
    LOOP DELAY_LOOP
    RET
DELAY ENDP
CODE ENDS 
END START
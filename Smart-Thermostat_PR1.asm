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
ORG 01000H
    PUSHF
    PUSH AX
    PUSH DX                                       
    XOR AX, AX
    XOR BX, BX
    XOR CX, CX
    XOR DX, DX
    ; TURN OFF 120V US
    MOV AL, 0d
    MOV [US_STANDARD_AC], AL
    MOV AL, 0d
    OUT THIRD_PORTA, AL 
                       
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
ORG 02000H
    PUSHF
    PUSH AX
    PUSH DX 
    XOR AX, AX
    XOR BX, BX
    XOR CX, CX
    XOR DX, DX
    ; TURN OFF 220V EU  
    MOV AL, 0d
    MOV [EU_STANDARD_AC], AL
    MOV AL, 0d
    OUT THIRD_PORTB, AL 
                       
   
    POP DX
    POP AX
    POPF
    IRET
    ISR1 ENDP
PROCED1 ENDS 

PROCED2 SEGMENT
    ISR2 PROC FAR
    ASSUME CS:PROCED2, DS:DATA
ORG 03000H
    PUSHF
    PUSH AX
    PUSH DX 
    XOR AX, AX
    XOR BX, BX
    XOR CX, CX
    XOR DX, DX
    ; KEYPAD INTERRUPT 
    IN AL, FIRST_PORTC
    CMP AL, KEY_120V
    JE SET_KEY_120   
    
    CMP AL, KEY_220V
    JE SET_KEY_220 
    JMP FRFR_GOGO
    SET_KEY_120:        
        ; CHECK IF VOLTAGE IS ON FOR 120
        CMP [US_STANDARD_AC], 0d
        JE FRFR_GOGO ; DO NOTHING SINCE OFF
        ; POWER IS ON, LETS DO SOMETHING
        CMP [US_TOGGLE], 0d
        JE TURN_ON_USFRFR
        JMP TURN_OFF_USFRFR
        TURN_ON_USFRFR:
            MOV AL, 1d
            OUT THIRD_PORTA, AL
	    MOV [US_TOGGLE], AL
            JMP FRFR_GOGO
	TURN_OFF_USFRFR:
	    MOV AL, 0d
            OUT THIRD_PORTA, AL
	    MOV [US_TOGGLE], AL
            JMP FRFR_GOGO
    SET_KEY_220:     
        ; CHECK IF VOLTAGE IS ON FOR 120
        CMP [EU_STANDARD_AC], 0d
        JE FRFR_GOGO ; DO NOTHING SINCE OFF
        ; POWER IS ON, LETS DO SOMETHING
        CMP [EU_TOGGLE], 0d
        JE TURN_ON_EUFRFR
        JMP TURN_OFF_EUFRFR
        TURN_ON_EUFRFR:
            MOV AL, 1d
            OUT THIRD_PORTB, AL
	    MOV [EU_TOGGLE], AL
            JMP FRFR_GOGO
	TURN_OFF_EUFRFR:
	    MOV AL, 0d
            OUT THIRD_PORTB, AL
	    MOV [EU_TOGGLE], AL
            JMP FRFR_GOGO
    FRFR_GOGO:     
    POP DX
    POP AX
    POPF
    IRET
    ISR2 ENDP
PROCED2 ENDS 

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
    OCW1                EQU 11111000B   ; ACTIVE INTERRUPTS   
                                                  
    ;<-- KEYPAD VARIABLES -->;         
    KEY0                DB 1DH          ; 0001 1101B
    KEY1                DB 10H          ; 0001 0000B
    KEY2                DB 11H          ; 0001 0001B
    KEY3                DB 12H          ; 0001 0010B
    KEY4                DB 14H          ; 0001 0100B 
    KEY5                DB 15H          ; 0001 0101B
    KEY6                DB 16H          ; 0001 0110B
    KEY7                DB 18H          ; 0001 1000B
    KEY8                DB 19H          ; 0001 1001B
    KEY9                DB 1AH          ; 0001 1010B
    KEY_STAR            DB 1CH          ; 0001 1100B
    KEY_HASH            DB 1EH          ; 0001 1110B
    
    ;<-- CUSTOM DATA VARIABLES -->;                 
    ; TIMER RELATED 
    ADJUST_REQUESTED    DB 0d
    TIMER_STR           DB "12:23", "$"
    HOUR                DB 1d
    MINUTES             DB 0d  
    SCHEDULE_FLAG_US    DB 1d 
    SCHEDULE_FLAG_EU    DB 1d
    SCHEDULE_TIME       DB 2d
    
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
    
    ; BUTTONS PRESSED
    KEYPRESS_VALUE      DB 0d
    KEY_120V            DB 00000010B ; 2d
    KEY_220V            DB 00000110B ; 6d 
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
	
    ; INIT THE LCD
    CALL INIT_LCD  
;                                                 ;
;<------------------- MAIN LOOP ----------------->;
;   
    MAIN:     
        ENDLESS:                  
            ;CALL DEBUG_FLAGS   
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
DEBUG_FLAGS PROC
    PUSH AX
    FLAG_DEBUG_PROC: 
        ; 080H -> 093H
        ; 0C0H -> 0D3H
        ; 094H -> 0A7H
        ; 0D4H -> 0E7H
        		
        
        ; US & US_TOGGLE       
        MOV AL, [0D2H]
        CALL INST_CTRL
        MOV AL, [US_STANDARD_AC]
        ADD AL, 30H    
        CALL DATA_CTRL
        MOV AL, [US_TOGGLE]
        ADD AL, 30H    
        CALL DATA_CTRL 
        
        
        ; US & US_TOGGLE       
        MOV AL, [0E6H]
        CALL INST_CTRL
        MOV AL, [EU_STANDARD_AC]
        ADD AL, 30H    
        CALL DATA_CTRL
        MOV AL, [EU_TOGGLE]
        ADD AL, 30H    
        CALL DATA_CTRL
    POP AX 
    RET
DEBUG_FLAGS ENDP    

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
        ADD AL, 30H
        CALL DATA_CTRL
        XOR AX, AX 
        JMP CHECK_MINUTES_CASE
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
                MOV [SCHEDULE_FLAG_EU], 1d
                MOV [SCHEDULE_FLAG_US], 1d
                JMP EXIT_TIMER_INC
    EXIT_TIMER_INC:        
    ; CHECKING SCHEDULE LINE UP
    MOV AL, [HOUR]
    CMP AL, [SCHEDULE_TIME]
    JL IGNORE_SCHEDULER
    ; IT SEEMS THAT THE SCHEDULE IS ACTIVE AND ITS PAST SCHEDULE, LETS DO SOMETHING
    CALL AIRCON_SCHEDULER_PROTOCOL  
    IGNORE_SCHEDULER:
    RET   
TIMER_INCREMENT ENDP  

AIRCON_SCHEDULER_PROTOCOL PROC  
    MOV AL, [SCHEDULE_FLAG_US] 
    CMP AL, 0d
    JE SKIP_TO_NEXT_FLAG 
    CHECK_US_VOLTAGE:
        MOV AL, [US_STANDARD_AC]
        ; CHECK IF IT IS ON
        CMP AL, 0d
        JE CHECK_EU_VOLTAGE 
        MOV AL, 1d
        OUT THIRD_PORTA, AL
        MOV [US_TOGGLE], 1d
        MOV [SCHEDULE_FLAG_US], 0d  
    SKIP_TO_NEXT_FLAG:
        MOV AL, [SCHEDULE_FLAG_EU] 
        CMP AL, 0d  
        JE EXIT_AC_PROTOCOL  
    CHECK_EU_VOLTAGE:
        MOV AL, [EU_STANDARD_AC] 
        ; CHECK IF IT IS ON
        CMP AL, 0d
        JE EXIT_AC_PROTOCOL
        MOV AL, 1d
        OUT THIRD_PORTB, AL 
        MOV [EU_TOGGLE], 1d
        MOV [SCHEDULE_FLAG_EU], 0d
    EXIT_AC_PROTOCOL:
    RET
AIRCON_SCHEDULER_PROTOCOL ENDP  

AIRCON_STATUS PROC
    ; 080H -> 093H
    ; 0C0H -> 0D3H
    ; 094H -> 0A7H
    ; 0D4H -> 0E7H
    CHECK_IF_POWER_SUPPLIED:
	XOR AX, AX
        IN AL, THIRD_PORTC
        ;CMP AL, 6d
        CMP AL, 7d
        JE TURN_BOTH_AC_ON_HAHA
        ;CMP AL, 4d
        CMP AL, 5d
        JE TURN_ON_ONLY_220
        ;CMP AL, 2d
        CMP AL, 3d 
        JE TURN_ON_ONLY_120
        JMP STOP_CHECK_AC_STATUS 
        TURN_ON_ONLY_120:   
            XOR AX, AX
            MOV AL, 1d
            ;OUT THIRD_PORTA, AL
            MOV [US_STANDARD_AC], AL
            JMP STOP_CHECK_AC_STATUS
        TURN_ON_ONLY_220:   
            XOR AX, AX
            MOV AL, 1d
            ;OUT THIRD_PORTB, AL
            MOV [EU_STANDARD_AC], AL
            JMP STOP_CHECK_AC_STATUS
        TURN_BOTH_AC_ON_HAHA:
            XOR AX, AX
            MOV AL, 1d
            ;OUT THIRD_PORTA, AL
            ;OUT THIRD_PORTB, AL
            MOV [US_STANDARD_AC], AL
            MOV [EU_STANDARD_AC], AL 
    STOP_CHECK_AC_STATUS:    
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
    FOR_REAL_GO_NEXT:              
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
    RET
UPDATE_TEMP_DISPLAY ENDP  

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

INIT_LCD PROC               
    PUSH AX
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
    POP AX
    RET
INIT_LCD ENDP

DATA_CTRL_TEST PROC   
    PUSH AX
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
    POP AX
    RET
DATA_CTRL_TEST ENDP  

INST_CTRL PROC      
    PUSH AX
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
    POP AX
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
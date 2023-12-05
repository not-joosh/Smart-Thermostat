;====================================================================
; Main.asm file generated by New Project wizard
;
; Created   :   Wed NOV 30, 2023
; Processor :   8086
; Compiler  :   MASM32 
; AUTHOR    :   JOSH RATIFICAR
; PROJECT   :   Ratificar_Sensors Practice
;====================================================================
 
;<------    INTERUPT SERVICE ROUTINES   ------->;
PROCED0 SEGMENT
    ISR0 PROC FAR
    ASSUME CS:PROCED0, DS:DATA
    PUSHF
    PUSH AX
    PUSH DX
    ; INTR | CONTROLS 120V AIR CONDITIONING UNIT (TURN OFF IF INSUFFICIENT VOLTAGE)       
    MOV [US_STANDARD_AC], 0d
    MOV AL, [EU_STANDARD_AC]
    CMP AL, 0d ; CHECKING IF EU IS BAD
    JE TURN_BOTH_OFF_INT0
    TURN_ONE_OFF:
        MOV AL, 02h       
        OUT FIRST_PORTC, AL
        JMP EXIT_INTR0
    TURN_BOTH_OFF_INT0:
        MOV AL, 00h
        OUT FIRST_PORTC, AL      
    EXIT_INTR0:          
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
    MOV [US_STANDARD_AC], 1d
    MOV AL, [EU_STANDARD_AC]
    CMP AL, 1d ; CHECKING IF EU IS GOOD
    JE TURN_BOTH_ON_INT1
    TURN_ONE_ON:
        MOV AL, 1d         
        OUT FIRST_PORTC, AL
        JMP EXIT_INTR1
    TURN_BOTH_ON_INT1:
        MOV AL, 3d
        OUT FIRST_PORTC, AL
    EXIT_INTR1: 
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
    MOV [EU_STANDARD_AC], 0d
    MOV AL, [US_STANDARD_AC]
    CMP AL, 0d ; CHECKING IF US IS BAD
    JE TURN_BOTH_OFF_INT2
    TURN_ONE_OFF_220V:
        MOV AL, 1d         
        OUT FIRST_PORTC, AL
        JMP EXIT_INT2
    TURN_BOTH_OFF_INT2:
        MOV AL, 0d
        OUT FIRST_PORTC, AL
    EXIT_INT2: 
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
    ; INTR | CONTROLS 120V AIR CONDITIONING UNIT (TURN ON IF SUFFICIENT VOLTAGE)       
    MOV [EU_STANDARD_AC], 1d
    MOV AL, [US_STANDARD_AC]
    CMP AL, 1d ; CHECKING IF US IS GOOD
    JE TURN_BOTH_ON_INT3
    TURN_ONE_ON_INT3:
        MOV AL, 2d         
        OUT FIRST_PORTC, AL
        JMP EXIT_INTR3
    TURN_BOTH_ON_INT3:
        MOV AL, 3d
        OUT FIRST_PORTC, AL
    EXIT_INTR3:  
    POP DX
    POP AX
    POPF
    IRET
    ISR3 ENDP
PROCED3 ENDS

DATA SEGMENT 
    ;<--- 8255'S --->;
    ; FIRST 8255 (LCD) + KEYPAD
    FIRST_PORTA     EQU 0C0H     ; PORTA ADDRESS 
    FIRST_PORTB     EQU 0C2H     ; PORTB ADDRESS 
    FIRST_PORTC     EQU 0C4H     ; PORTC ADDRESS 
    FIRST_COMREG    EQU 0C6H 	 ; COMMAND REGISTER 
    
    ; SECOND 8255 (LED)
    SECOND_PORTA    EQU 0F0H     ; PORTA ADDRESS 
    SECOND_PORTB    EQU 0F2H     ; PORTB ADDRESS 
    SECOND_PORTC    EQU 0F4H     ; PORTC ADDRESS 
    SECOND_COMREG   EQU 0F6H 	 ; COMMAND REGISTER 
    
    ; SETUP WHERE 2 OUTPUTS, 1 INPUT
    SETUP_8255_1    DB 10000000B 	 ; 1000 1001B (A & B = OUT) (C = OUT) 10000000B
    SETUP_8255_2    DB 098H	 ; 1001 1000B (B & C_LOW = OUT ) (A & C_HIGH = IN)
        
    ;<--- 8259 --->;
    PIC1            EQU 0D0H ; 0F8H ; 8259 ADDRESS FOR A0 = 0
    PIC2            EQU 0D2H ;      ; 8259 ADDRESS FOR A0 = 1
    ICW1            EQU 13H         ; 00010011B  ; CONTROLS IF ICW4 IS NEEDED OR NOT           
    ICW2            EQU 80H         ; 1000 0100B -> 84H
    ICW4            EQU 03H         ; 0011B                   
    OCW1            EQU 11110000B   ; 11101111B   ; INTERUPTS 0,1,2,3      
    
    ;<--- ADC0808 --->; ;TEMP IN CELCIUS
    INTERNAL_TEMPERATURE DB 25
    TEMPERATURE DB 0
    
    
    ;<--- CUSTOM VARIABLES --->      
    US_STANDARD_AC DB 0d
    EU_STANDARD_AC DB 0d
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
        MOV DX, FIRST_COMREG
        MOV AL, SETUP_8255_1 
        OUT DX, AL   
                                
        MOV DX, SECOND_COMREG
        MOV AL, SETUP_8255_2
        OUT DX, AL
         
        ;XOR AX, AX         
        ;MOV AL, 03H
        ;OUT FIRST_PORTC, AL 
        
           
        
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
         
        
        ; SETTING UP THE LCD
        CALL INIT_LCD 
;                                                 ;
;<------------------- MAIN LOOP ----------------->;
;                                                 ;  
    MAIN:               
        
        ; CALL SHOW_INTERRUPT_FLAGS
        CALL DEBUG_ADC
	    JMP MAIN  
	                                         
;                   ;
;   DEBUG FUNCTIONS ;
;	                ;

DEBUG_ADC PROC
    CALL PULSE_ADC   
    CALL READ_ADC
    CALL DECODE_ADC
    RET
DEBUG_ADC ENDP
SHOW_INTERRUPT_FLAGS PROC
    MOV AL, 0C0H
    CALL INST_CTRL
    MOV AL, [US_STANDARD_AC]  
    ADD AL, 30H 
    CALL DATA_CTRL    
    
    MOV AL, 094H
    CALL INST_CTRL
    MOV AL, [EU_STANDARD_AC]
    ADD AL, 30H
    CALL DATA_CTRL
    RET
SHOW_INTERRUPT_FLAGS ENDP  
;                                                 ;
;<------------------- FUNCTIONS ----------------->;
;                                                 ; 
DECODE_ADC PROC
    ; AL HAS OUR SHIT
    XOR BX, BX
    MOV BL, 10d
    MUL BX
    MOV BL, 17d
    DIV BX
    ; STORE THE TEMPERATURE
    MOV [TEMPERATURE], AL  
    CALL UPDATE_TEMPERATURE_DISPLAY
    RET
DECODE_ADC ENDP

UPDATE_TEMPERATURE_DISPLAY PROC
    MOV BL, 10d   
    XOR DX, DX      
    MOV DL, 083H
    CLEAR_LINE_LOOP:
        ; CLEARING THE FIRST LINE  
        CMP DL, 79H
        JE STOP_CLEAR_LINE         
        MOV DL, AL
        CALL INSTR_CTRL 
        MOV AL, " "
        CALL DATA_CTRL
    JMP CLEAR_LINE_LOOP   
    STOP_CLEAR_LINE:
    

    ; 080H -> 093H 
    ; 0C0H -> 0D3H
    ; 094H -> 0A7H
    ; 0D4H -> 0E7H
    ; 129 C
    ; 080H <- 1
    ; 081H <- 2 
    ; 082H <- 9
    ; 083H <- C
    PUSH AX
    MOV AL, 083H   
    CALL INST_CTRL
    MOV AL, "C"
    CALL DATA_CTRL
    POP AX
    ; 129 | 80H                    
    PRINT_TEMPERATURE_LOOP:       
        XOR AH, AH
        DIV BL
        CMP AL, 0d ; AH 9
        JE VALIDATE_EXIT
        FINAL_PRINT:        
        PUSH AX       
        MOV AL, DL
        CALL INST_CTRL
        POP AX
        PUSH AX  
        MOV AL, AH 
        ADD AL, 30H
        CALL DATA_CTRL
        POP AX                   
        JMP NEXT_CHAR
        VALIDATE_EXIT:
        CMP AH, 0d
        JE EXIT_PRINT_SEQ 
        JMP FINAL_PRINT           
        NEXT_CHAR:
        SUB DL, 1H
        JMP PRINT_TEMPERATURE_LOOP
        EXIT_PRINT_SEQ:
    RET
UPDATE_TEMPERATURE_DISPLAY ENDP
;DECODE_DATA PROC
;    CONVERSION:
;        MOV BL, 10d
;        MUL BL        
; ;       XOR BX, BX
;        MOV BL, 50d
;        DIV BL      
;        MOV AH, 0H
;        MOV BL, 10d
;        DIV BL
;        ; CONVERT TO ASCII
;        ADD AH, 30H   
;        ADD AL, 30H   
;         
;        ; DATA IS INSIDE AL REGISTER
;        XOR BX, BX
;        MOV BL, [PREV_FIRTDIG]
;        CMP BL, AL
;        JE EXIT_DECODE_DATA ; ITS A REPEAT, SO DONT DISPLAY SHIT
;    
;        MOV [FIRST_DIGIT], AL
;        MOV [SECOND_DIGIT], AH  
;        
;        CALL DISPLAY_DATA
;    EXIT_DECODE_DATA: 
;        RET
;DECODE_DATA ENDP

;DISPLAY_DATA PROC
;    CALL INIT_LCD
;    ; 083        
;    ; 0C0H
;    ; 094H
;    MOV AL, 094H
;    CALL INST_CTRL
;    
;    MOV AL, [FIRST_DIGIT]
;    CALL DATA_CTRL  
;    
;    MOV AL, "."
;    CALL DATA_CTRL 
;    
;    MOV AL, [SECOND_DIGIT]
;    CALL DATA_CTRL
;    RET
;DISPLAY_DATA ENDP

PULSE_ADC PROC
    ; CLEARING AX
    XOR AX, AX
    MOV DX, SECOND_PORTB
    MOV AL, 07H         
    OUT DX, AL    
    CALL DELAY
    ; CLEARING AX
    ;XOR AX, AX
    ;MOV DX, SECOND_PORTB
    ;OUT DX, AL 
    ;CALL DELAY 
    
    ; MAINTAIN ABC 
    XOR AX, AX
    MOV DX, SECOND_PORTB
    MOV AL, 15d
    OUT DX, AL      
    CALL DELAY
    
    MOV DX, SECOND_PORTB
    MOV AL, 00H
    OUT DX, AL
    RET
PULSE_ADC ENDP

READ_ADC PROC
    ; BUFFER DATA 
    XOR AX, AX
    MOV DX, SECOND_PORTC 
    MOV AL, 01H
    OUT DX, AL 
    
    CALL DELAY
    ; READ THE DATA AND SAVE IT TO STACK
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

;                                                 ;
;<----------------- LCD COMMANDS ---------------->;
;                                                 ;
LCD_CLEAR PROC
    MOV AH, 01H
    CALL INST_CTRL
    RET
LCD_CLEAR ENDP
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
    
    MOV AL, 0CH
    CALL INST_CTRL
    
    MOV AL, 01H
    CALL INST_CTRL
    MOV AL, 01H
    CALL INST_CTRL
    
    MOV AL, 06H
    CALL INST_CTRL
    RET
INIT_LCD ENDP

INST_CTRL PROC
    ; HIGH TO LOW
    MOV DX, FIRST_PORTA ; D0-D7 TO LCD
    OUT DX, AL
    
    MOV DX, FIRST_PORTB 
    MOV AL, 02H  ; WR & E
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

DELAY PROC
    MOV CX, 0FFFH
    DELAY_LOOP:
    LOOP DELAY_LOOP
    RET
DELAY ENDP 
LONG_DELAY PROC
    MOV CX, 100
    LONG_LOOP:    
        DEC CX
        PUSH CX
        CALL DELAY
        POP CX
        CMP CX, 0h
        JNZ LONG_LOOP
        RET
LONG_DELAY ENDP
    
CODE ENDS 
END START
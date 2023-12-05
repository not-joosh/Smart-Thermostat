;====================================================================
; Main.asm file generated by New Project wizard
;
; Created   :   Wed NOV 18, 2023
; Processor :   8086
; Compiler  :   MASM32 
; AUTHOR    :   JOSH RATIFICAR
; PROJECT   :   Ratificar_Sensors Practice
;====================================================================
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
    SETUP_8255_1    DB 089H 	 ; 1000 1001B (A & B = OUT) (C = IN)
    SETUP_8255_2    DB 098H	     ; 1001 1000B (B & C_LOW = OUT ) (A & C_HIGH = IN)
    
    
    ; CUSTOM VARIABL;ES FOR ADC0808
    PREV_FIRTDIG    DB 0
    FIRST_DIGIT     DB 0
    SECOND_DIGIT    DB 0
DATA ENDS     
STACK SEGMENT
    DW 128 DUP(?)
STACK ENDS
CODE SEGMENT PUBLIC 'CODE'
    ASSUME CS:CODE, DS:DATA, SS:STACK
START:
;                                                 ;
;<-------------------- SETUP  ------------------->;
;                                                 ;         
    INIT:                        
        ; SETTING UP BOTH 8255'S 
        MOV DX, FIRST_COMREG
        MOV AL, SETUP_8255_1 
        OUT DX, AL   
                                
        MOV DX, SECOND_COMREG
        MOV AL, SETUP_8255_2
        OUT DX, AL
          
        
        ; SETTING UP THE LCD
        CALL INIT_LCD 
;                                                 ;
;<------------------- MAIN LOOP ----------------->;
;                                                 ;  
    MAIN:  
        CALL PULSE_ADC
	    CALL READ_ADC
	    CALL DECODE_DATA
	    JMP MAIN
;                                                 ;
;<------------------- FUNCTIONS ----------------->;
;                                                 ; 
DECODE_DATA PROC
    CONVERSION:
        MOV BL, 10d
        MUL BL        
        XOR BX, BX
        MOV BL, 50d
        DIV BL      
        MOV AH, 0H
        MOV BL, 10d
        DIV BL
        ; CONVERT TO ASCII
        ADD AH, 30H   
        ADD AL, 30H   
         
        ; DATA IS INSIDE AL REGISTER
        XOR BX, BX
        MOV BL, [PREV_FIRTDIG]
        CMP BL, AH
        JE EXIT_DECODE_DATA ; ITS A REPEAT, SO DONT DISPLAY SHIT
    
        MOV [FIRST_DIGIT], AL
        MOV [SECOND_DIGIT], AH  
        
        CALL DISPLAY_DATA
    EXIT_DECODE_DATA: 
        RET
DECODE_DATA ENDP

DISPLAY_DATA PROC
    CALL INIT_LCD
    ; 083        
    ; 0C0H
    ; 094H
    MOV AL, 094H
    CALL INST_CTRL
    
    MOV AL, [FIRST_DIGIT]
    CALL DATA_CTRL  
    
    MOV AL, "."
    CALL DATA_CTRL 
    
    MOV AL, [SECOND_DIGIT]
    CALL DATA_CTRL
    RET
DISPLAY_DATA ENDP

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
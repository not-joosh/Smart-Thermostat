
ORG 100H
INIT:
    XOR AX, AX
    XOR BX, BX
    XOR CX, CX
    XOR DX, DX 
    JMP MAIN
.DATA
    TEMPERATURE     DB 0
    
    INPUT_FROM_ADC  DB 11101111B
.CODE      
    MAIN:        
        CALL READ_ADC
        CALL EXIT
EXIT:
    RET              
    
READ_ADC:   
    ; 1.5V REFERENCE
    ; 1.4V -> 239
    ; REPRESENTS 140 C
    ; 3 DIGITS
    ; * 10  / 17
    
    ; 129C <--- 1101 1100B   | 220 DEC
       
    BUFFER_DATA:
    MOV AL, 11011100B 
    XOR BX, BX  
    MOV BL, 10d
    MUL BX
    MOV BL, 17d
    DIV BX
    
    ; SEPERATING THIS AND MOVING THEM INTO AN ARRAY OF SOME SORT
    ; AX = []
    ; 81 <--- 129
    ; 129/ 10
    ; 12
    
    
    ; STORE THE DATA INSIDE AL ("129") TO TEMPERATURE
    ; VARIABLE
    MOV [TEMPERATURE], AL              
    
    ; PRINTING THE TEMPERATURE ONTO LCD
    ; READ THE SIZE OF THE DIGIT
    ; IS IT 1 DIGIT, IS IT 2, IS IT 3?
    ; WHO KNOWS?
    
    MOV BL, 10d                        
    PRINT_TEMPERATURE_LOOP:       
        XOR AH, AH
        XOR DX, DX
        DIV BL
        CMP AL, 0d ; AH 9
        JE VALIDATE_EXIT
        ; PRINTING LOGIC
        ; IN AH 
        FINAL_PRINT:        
        PUSH AX   
        MOV DL, AH
        ADD DL, 30H
        MOV AH, 02H
        ; SIMULATING PRINT
        INT 21H      
        POP AX                    
        JMP NEXT_CHAR
        VALIDATE_EXIT:
        CMP AH, 0d
        JE EXIT_PRINT_SEQ 
        JMP FINAL_PRINT:           
        NEXT_CHAR:
        JMP PRINT_TEMPERATURE_LOOP
        EXIT_PRINT_SEQ:
    RET
PRINT_LCD:
    
    RET
PRINT:
    MOV AH, 09H
    INT 21H
    RET




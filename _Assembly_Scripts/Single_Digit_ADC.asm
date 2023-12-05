ORG 100H
INIT:
    XOR AX, AX
    XOR BX, BX
    XOR CX, CX
    XOR DX, DX
    JMP MAIN
.DATA                           
    TEST_STRING DW "HELLO", "$"
    NUMBER_IN DB 11101000B       ; 232d | 200V
    FIRST_DIGIT DB 0
    SECOND_DIGIT DB 0    
    THIRD_DIGIT DB 0
    
.CODE
    MAIN:               
    ;CALL OPERATIONS  
    CALL GET_NUM_LENGTH
    CALL EXIT
    
        
EXIT:
    RET
OPERATIONS:
    MOV AL, [FOUR_POINT_FIVE]    
    MOV BL, 10d
    MUL BL        
    XOR BX, BX
    MOV BL, 50d
    DIV BL      
    ; tARGET IS  
    MOV AH, 0H
    MOV BL, 10d
    DIV BL
          
    ; CONVERT TO ASCII
    ADD AH, 30H   
    ADD AL, 30H
    MOV FIRST_DIGIT, AH
    MOV SECOND_DIGIT, AL
 
    ; 2290
    ;MOV BL, 50d
    ;DIV BL
    
    RET  
PRINT:      
    MOV AH, 09H
    INT 21H   
    RET     

GET_NUM_LENGTH:        
    ; 220 AS VREF
    ; 11101000B       ; 232d | 200V
    ; MOV AL, [NUMBER_IN]
    ; MULTIPLIED BY 100
    ; DIVIDED 116   
    
    
    ; 200 AS VREF
    ; 11011111B       ; 223d | 175V
    ; MOV AL, [NUMBER_IN]
    ; MULTIPLIED BY 100
    ; DIVIDED 131   
                 
                 
                 
    ; 120 AS VREF
    ; 11101000B       ; 223d | 200V
    ; MOV AL, [NUMBER_IN]
    ; MULTIPLIED BY 100
    ; DIVIDED 127
    
    RET


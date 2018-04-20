DISPLAYSTRING  MACRO DATA     
           LOCAL WRITE
           MOV SI,OFFSET DATA;STRING STARTS AT DATA
		   MOV AH,0EH;WRITE WITH ADVANCING CURSOR
		   MOV BH,0
		   MOV BL,0FH;WHITE CHARS
		   WRITE:
		   MOV AL,[SI]
		   INT 10H
		   INC SI;MOVE TO NEXT CHAR
		   CMP [SI],'$';STOP PRINTING AT DOLLAR SIGN
		   JNE WRITE

ENDM DISPLAYSTRING 
 ;///////////////////////////////////
 SETCURSOR MACRO ROW,COLUMN    ;THIS MACRO SETS CURSOR LOCATION TO ROW AND COLUMN
	MOV AH,02
	MOV BH,0
	MOV DH,ROW
	MOV DL,COLUMN
	INT 10H
ENDM SETCURSOR
;////////////////////////////////////
; macro to display any decimal number consisting of 2 digits
WRITE_2_DIG MACRO   Reg ; not an immediate value

    MOV AL,Reg
    MOV AH,0
    MOV DL,10
    DIV DL;most significant in al least significant in ah
    MOV DL,AH;mov least significant digit 
   
    ADD AL,48;to ascii
	MOV AH,0EH;WRITE WITH ADVANCING CURSOR
	MOV BH,0
	MOV BL,0FH;WHITE CHARS
	INT 10H
    
    MOV AL,DL
    ADD AL,48;least significant to ascii
    MOV AH,9 
	MOV BH,0
	MOV CX,1
	MOV BL,0FH 
    INT 10H;write least significant number on screen

 ENDM  WRITE_2_DIG
 ;//////////////////////////////////////////////////////
DISPLAY_CHARS MACRO CHAR,COLOR,N_TIME 
             MOV AH,9        ;DISPLAY CHAR
             MOV BH,0
             MOV AL,CHAR  
             MOV CX,N_TIME
             MOV BL,COLOR
             INT 10H 
 ENDM DISPLAY_CHARS
;////////////////////////////////////////////////////////
CLEAR_SCREEN MACRO
     MOV AX,0600H
     MOV BH,0
     MOV CX,0
     MOV DX,1828H
     INT 10H 
ENDM CLEAR_SCREEN
;/////////////////////////////////////////
CLEAR_PLAYSCREEN MACRO

	LOCAL BACK,BACK1
     MOV AX,0600H
     MOV BH,0
     MOV CX,0300H
     MOV DX,1328H
     INT 10H 
   ;////CLEAR ROW AFTER SCORE LINE
	MOV CX,0 ;COLUMN
	MOV DX,23 ;ROW
	MOV AL,0 ;PIXEL COLOR
	MOV AH,0CH ;DRAW PIXEL COMMAND
	
	BACK: INT 10H
	INC CX
	CMP CX,320
	JNZ BACK
	;////CLEAR ROW BEFORE CHAT LINE
	MOV DX,160
	MOV CX,0
	BACK1: INT 10H
	INC CX
	CMP CX,320
	JNZ BACK1

ENDM CLEAR_PLAYSCREEN
;/////////////////////////////////////////
 DELAY MACRO 
    LOCAL MYL
    MOV CX,0FFFFH
    MYL:
        LOOP MYL 
  ENDM  DELAY
;////////////////////////////////////////////////////////
DELAY_SECS MACRO N ;MAKES AN N SECONDS DELAY
    LOCAL DE
	MOV AH,2CH 
	INT 21H;GET TIME
	MOV BL,DH
	ADD BL,N;ADD NUMBER OF SECONDS OVER CURRENT SECONDS
	CMP BL,60;CHECK THE RESULT IS NOT 60 OR MORE
    JL DE
    SUB BL,60
	DE:
	  INT 21H
	  CMP DH,BL
	  JNE DE;LOOP EXITS WHEN N SECS ARE REACHED
ENDM DELAY_SECS
 ;///////////////////////////////////////////////////////
 SCROLLUP MACRO   POSITION,MAX
        
             LOCAL NOTMAX
             
             MOV BH,0
             MOV AH,2       	;MOVE CURSOR
             MOV DX,POSITION
             INT 10H
             
	         MOV AX,MAX
             CMP POSITION,AX
             JNE NOTMAX
            
             MOV AH,6  		;SCROLL 
             MOV AL,1
             MOV BH,0
             MOV CH,01
             MOV CL,0
             MOV DH,0AH
             MOV DL,40 
             INT 10H 
             
             
	         SUB POSITION,40	;SET POSITION TO THE BEGINING OF THE LINE
             MOV DX,POSITION
             MOV BH,0
             MOV AH,2       	;MOVE CURSOR
             INT 10H
             
     NOTMAX: 
        
    
ENDM  SCROLLUP       
;////////////////////
SCROLLDOWN MACRO   POSITION,MAX
        
             LOCAL NOTM
             
             MOV BH,0
             MOV AH,2       	;MOVE CURSOR
             MOV DX,POSITION
             INT 10H
             
	         MOV AX,MAX
             CMP POSITION,AX
             JNE NOTM
            
             MOV AH,6  		;SCROLL 
             MOV AL,1
             MOV BH,0
             MOV CH,0DH
             MOV CL,0
             MOV DH,22
             MOV DL,40
             INT 10H 
             
             
	         SUB POSITION,40	;SET POSITION TO THE BEGINING OF THE LINE
             MOV DX,POSITION
             MOV BH,0
             MOV AH,2       	;MOVE CURSOR
             INT 10H
             
     NOTM: 
        
    
 ENDM SCROLLDOWN
;//////////////////////////////////////////
INCREMENT MACRO POSITIO,CHA,MAX
          
          LOCAL ADDROW,E  
          MOV BL,CHA
          
          CMP BL,13
          JE ADDROW
          
          MOV DX,POSITIO
          CMP DL,40
          JE ADDROW
          INC POSITIO
          JMP E
          ADDROW:
          MOV DL,0
          ADD DH,1
          MOV POSITIO,DX
		  CMP DX,MAX
		  JLE E
		  MOV DX,MAX
		  MOV POSITIO,DX
          E:
 ENDM INCREMENT
;////////////////////////////////////////// 
RECIEVE_BYTE MACRO
    LOCAL SND
    MOV DX,3FDH;LINE STATUS REG ADDRESS
    IN AL,DX;MOVE DATA AT OFFSET IN AL
    AND AL,1;RETURN 0 IF NO DATA
    JZ SND
    MOV DX,3F8H;HOLD CHAR(DIVISOR LATCH=0)
    IN AL,DX
	SND:
 ENDM RECIEVE_BYTE
;////////////////////////////////////////// 
SEND_BYTE MACRO BYT     
	 LOCAL TES
	  TES: 
	   MOV DX,3FDH
	   IN AL,DX
	   AND AL,100000B
	   JZ TES
	   MOV DX,3F8H
	   MOV AL,BYT
	   OUT DX,AL
 ENDM SEND_BYTE
;////////////////////////////////////////// 
INITIALIZE_UART MACRO
	  MOV DX,3FBH ;control line reg address
	  MOV AL,10000000B
	  OUT DX,AL;set divisor latch bit
	  MOV AL,0CH;baud=9600
	  MOV DX,3F8H ;ADDRESS LSB DIVISOR
	  OUT DX,AL 
	  MOV AL,00H
	  MOV DX,3F9H;ADDRESS MSB 
	  OUT DX,AL  ;divisor(msb)=00,lsb=0c
	  MOV DX,3FBH
	  MOV AL,00011011B ;8bit,1stop bit,even parit
	  OUT DX,AL 

ENDM INITIALIZE_UART
;//////////////////////////////////////////////////
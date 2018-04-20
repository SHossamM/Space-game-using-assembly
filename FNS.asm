GAME_MODE PROC 
      ;INITIALIZING GAME SCREEN AND LEVEL
     ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
     CMP STAT,1010B
     JE PL1
     W:
     RECIEVE_BYTE
     CMP AL,0
     JE W
     JMP INITIA
     PL1:
     CLEAR_SCREEN
     SETCURSOR 12,5
     DISPLAYSTRING MES7 
     
     NOTCORRECT:
     MOV AH,0
     INT 16H
            
     CMP AL,'1'
     JE STARTINIT
            CMP AL,'2'
            JNE NOTCORRECT
     
     STARTINIT:
     MOV TEMP3,AL
     SEND_BYTE TEMP3 
     MOV AL,TEMP3 
     INITIA:
     CALL INITIALIZELEVEL
     ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

     CLEAR_SCREEN   
     PRINT_SCREEN
     DRAW HI,WIDTH,C1,R,4,PLAYER;color red  
     DRAW HI,WIDTH,C2,R,9H,PLAYER;color light blue
     CALL DRAWENEMY 
     
     MOV AH,2CH      ;GET TIME
     INT 21H
     MOV NEXTTIME,DH
     MOV BH,0 
     SETCURSOR 0,18
   ;print Player2 name  
     DISPLAYSTRING STR2
     SETCURSOR 0,0
   ;print Player1 name  
     DISPLAYSTRING STR1 
     ;START GAME
    RE:
       ENEMY_TOUCH_PLAYER  
       MOV AH,2CH      ;GET TIME
       INT 21H

        CMP DH,NEXTTIME
        JNE CONTINUE 
        CALL SETNEXTTIME 
        CALL MOVEENEMY 
        OR STAT,1000B   
        
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ISDEAD:
        MOV DI,0
        MOV AX,ENEMYARRAYSIZE    ;TO DETERMINE NO. OF LOOPS
        ADD AX,AX
             
        DEAD:
        CMP ENEMYARRAYX[DI],REMOVED
        JNE CONTINUE 
        ADD DI,2
        CMP DI,AX
        JNE DEAD 
        JMP DISP_SCORE  ;if all enemies are dead displayer score and winners
      ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
      CONTINUE:    
        MOV BL,STAT
        AND BL,1000B
        JZ GAM ;if a change occured in enemy array redraw screen with updates
        CLEAR_PLAYSCREEN 
        AND STAT,0F7H
        DRAW HI,WIDTH,C1,R,4,PLAYER
        DRAW HI,WIDTH,C2,R,9H,PLAYER
        CALL DRAWENEMY
      ;/////////////////////////////
      GAM:
      MOV BX,0
      PRINT_SCORE S1,S2 
      MOV BL,STAT  
      AND BL,1 ;check if player1 fired
      JZ PP2
      KILL_ENEMY C1,S1 
      MOVE_FIRE1 WIDTH2,R,HI,C1
      AND STAT,0FEH

      PP2:
      MOV BL,STAT
      AND BL,100B;check if player2 fired
      JZ CHECK 
      KILL_ENEMY C2,S2 
      MOVE_FIRE1 WIDTH2,R,HI,C2 
      
      AND STAT,0FBH
       
      CHECK: 
      
      MOV BL,STAT
      AND BL,10B
      JZ MOVP2        ;IF ZERO THEN YOU ARE PLAYER2 
      CHECKP1
      JMP RE
      
      MOVP2:
      CHECKP2
      JMP RE
      
      
     DISP_SCORE: 
     DISP_WINNER S1,S2,STR1,STR2,WINSTR,DRAWS;DISPLAYS THE WINNER AND SCORE
     ENDPROC: 
     RET
GAME_MODE ENDP    
MOVE_P1 PROC  
    MOV BL,STAT
    CMP AH,RIGHTARROW;SCANCODE OF RIGHT ARROW
    JE RIGHT
    
    CMP AH,LEFTARROW;SCANCODE OF LEFT ARROW
    JE LEFT

    CMP AH,FIREKEY;SCANCODE OF SPACE
    JNE EXIT
    OR STAT,1
    EXIT: 
    RET
    
    RIGHT:
    
    MOV AX,C1
    ADD AX,WIDTH
    CMP AX,C2 ;check that player 2 is not standing on player1's right before moving
    JE EXIT
    INC C1   
    SHIFT_PLAYER_RIGHT HI,C1,R 
    MOV AX,C1
    ADD AX,WIDTH
    CMP AX,C2 ;check that player 2 is not standing on player1's right before moving
    JE DRAWP1
    INC C1   
    SHIFT_PLAYER_RIGHT HI,C1,R
    DRAWP1:
    
    DRAW HI,WIDTH,C1,R,4,PLAYER
    RET
    
    LEFT:
    MOV AX,C1
    CMP AX,0;check if player has reached screen end 
    JE EXIT
    DEC C1
    SHIFT_PLAYER_LEFT HI,C1,R
    MOV AX,C1
    CMP AX,0;check if player has reached screen end 
    JE DRAWP1
    DEC C1
    SHIFT_PLAYER_LEFT HI,C1,R
    DRAW HI,WIDTH,C1,R,4,PLAYER
     
    
    RET   
MOVE_P1 ENDP
MOVE_P2 PROC  
    MOV BL,STAT
    CMP AL,LEFTARROW;SCANCODE OF LEFT ARROW
    JE LFT
    CMP AL,RIGHTARROW;SCANCODE OF RIGHT ARROW
    JE  RHT
    CMP AL,FIREKEY;SCANCODE OF SPACE
    JNE EXT
    OR STAT,100B 
    
    EXT: 
    RET
    
    RHT:
    MOV AX,C2
    ADD AX,WIDTH
    CMP AX,319 ;check if player2 has reached screen end
    JE EXT 
    INC C2
    SHIFT_PLAYER_RIGHT  HI,C2,R  
    MOV AX,C2
    ADD AX,WIDTH
    CMP AX,319 ;check if player2 has reached screen end
    JE DRAWP2 
    INC C2
    SHIFT_PLAYER_RIGHT  HI,C2,R
    DRAWP2:
    DRAW HI,WIDTH,C2,R,9H,PLAYER;color light blue
    
    RET
    
    LFT:
    
    MOV BX,C1
    ADD BX,WIDTH;check if player2 has reached player1
    CMP C2,BX
    JE EXT
    DEC C2 
    SHIFT_PLAYER_LEFT HI,C2,R
    MOV BX,C1
    ADD BX,WIDTH;check if player2 has reached player1
    CMP C2,BX
    JE DRAWP2
    DEC C2 
    SHIFT_PLAYER_LEFT HI,C2,R
    DRAW HI,WIDTH,C2,R,9H,PLAYER;color light blue 
    

    RET
   
MOVE_P2 ENDP 

;/////////////////////////////////////////////////// 
DRAWENEMY   PROC   
       
   
       MOV DI,0          ;INDEX FOR ARRAY OF ENEMIES 
LOOP1:  
       MOV BX,ENEMYARRAYX[DI]
       CMP BX,REMOVED
       JZ INCR
      
       CMP BX,24
       JL BACK  
       DRAW_E ICONWIDTH,ICONWIDTH,ENEMYARRAYY[DI],ENEMYARRAYX[DI],ENEMY  
     INCR:
       ADD DI,2
       MOV BX,ENEMYARRAYSIZE
       ADD BX,BX
       CMP DI,BX
       JNE LOOP1
      BACK: 
       RET
DRAWENEMY ENDP 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
       
MOVEENEMY   PROC 
       
       MOV DI,0
       MOV AX,ENEMYARRAYSIZE    ;TO DETERMINE NO. OF LOOPS
       ADD AX,AX
       MOV BX,0
       MOV BL,ENEMYSTEP 
       
MOVEENE:
       CMP ENEMYARRAYX[DI],REMOVED
       JE  MOVNEXT
       ADD ENEMYARRAYX[DI],BX
       CMP ENEMYARRAYX[DI],176
       JLE MOVNEXT
       MOV ENEMYARRAYX[DI],REMOVED  
       MOVNEXT: 
       ADD DI,2
       CMP DI,AX
       JNE MOVEENE 
       
       RET
MOVEENEMY ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SETNEXTTIME PROC 
            
            MOV AH,ENEMYSPEED
            ADD NEXTTIME,AH
            CMP NEXTTIME,60
            JL E
            SUB NEXTTIME,60
            E:
            RET
            
SETNEXTTIME ENDP    

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

INITIALIZELEVEL PROC    
            
            ;STARTINIT:
            SUB AL,31H
            MOV AH,0
            MOV DI,AX 
            
            MOV CL,ENESPEEDLEV[DI]
            MOV ENEMYSPEED,CL 
            
            MOV CL,ENESTEPLEV[DI]       
            MOV ENEMYSTEP,CL 
            
            MOV CH,2
            MUL CH 
            MOV DI,AX
            MOV CX,ENEARRSIZELEV[DI]
            MOV ENEMYARRAYSIZE,CX
                    
            MOV DI,0
            ADD CX,CX
       MOVEARR:     
            MOV DX,ENEARRX[DI]
            MOV ENEMYARRAYX[DI],DX
            ADD DI,2
            CMP DI,CX
            JNE  MOVEARR
            MOV C1,0
            MOV C2,303 
            MOV S1,0
            MOV S2,0 
            
            CMP STAT,1010B
            JE FP
            MOV DI,OFFSET STR2
            MOV SI,OFFSET MY_USERNAME
            MOV CX,16
            REP MOVSB
            
            MOV DI,OFFSET STR1
            MOV SI,OFFSET OTHER_USER
            MOV CX,16
            REP MOVSB 
            RET
            
            FP:
            MOV DI,OFFSET STR1
            MOV SI,OFFSET MY_USERNAME
            MOV CX,16
            REP MOVSB
            
            MOV DI,OFFSET STR2
            MOV SI,OFFSET OTHER_USER
            MOV CX,16
            REP MOVSB
            
    
            RET
            
INITIALIZELEVEL ENDP 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 

CHAT_MODE PROC NEAR 
    ;INITIALIZE SCREEN
    SETCURSOR 11,0
    DISPLAY_CHARS '-',0FH,40 ;DRW LINE TO DIVIDE THE SCREEN 
    SETCURSOR 23,0
    DISPLAY_CHARS '-',0FH,40 ;DRW LINE FOR STATUS 
    SETCURSOR 24,0
    DISPLAYSTRING MES6
    DISPLAY_CHARS ' ',0FH,1
	DISPLAYSTRING OTHER_USER
    MOV CURSOR1,0
    MOV CURSOR2,0C00H
    ;WRITE THE LOCAL USERNAME ABOVE
    MOV BH,0
    MOV AH,2       	
    MOV DX,CURSOR1
    INT 10H
    DISPLAYSTRING MY_USERNAME
    MOV CURSOR1,0100H 
    ;WRITE THE OTHER USERNAME BELOW
    MOV BH,0
    MOV AH,2       	
    MOV DX,CURSOR2
    INT 10H
    DISPLAYSTRING OTHER_USER
    MOV CURSOR2,0D00H
   ;//////////////////////////////////////// 
     RECIEVE:
    MOV DX,3FDH;LINE STATUS REG ADDRESS
    IN AL,DX;MOVE DATA AT OFFSET IN AL
    AND AL,1;RETURN 0 IF NO DATA
    JZ SEND
    MOV DX,3F8H; REGISTER WHICH HOLD CHAR
    IN AL,DX 
    CMP AL,27;IF CHAR RECIEVED ID ESC EXIT
    JZ RETURN
    CMP AL,8
    JZ BACKSPACERECIEVE
    MOV CHAR,AL
    MOV BH,0 
    SCROLLDOWN CURSOR2,1628H
    INCREMENT CURSOR2,CHAR,1628H
    CMP CHAR,13
    JE SEND
    DISPLAY_CHARS CHAR,0FH,1
        
    SEND:
    MOV AH,01
    INT 16H  ;CHECK IF KEY IS PRESSED
    JZ RECIEVE
    MOV AH,0
    INT 16H ;CONSUME CHAR
    MOV CHAR,AL
    
     
    CMP AL,8
    JZ BACKSPACESEND  
    MOV BH,0
    SCROLLUP CURSOR1, 0A28H
    INCREMENT CURSOR1,CHAR,0A28H 
    CMP CHAR,13
    JE SENDCMP
    DISPLAY_CHARS CHAR,0FH,1
    SENDCMP:
    SEND_BYTE CHAR
    CMP CHAR,27
    JZ RETURN
    JMP RECIEVE
    RETURN:
    RET
     
    BACKSPACERECIEVE:
    MOV DX,CURSOR2
    DEC DX
    MOV CURSOR2,DX
    MOV AH,02
	MOV BH,0
	INT 10H
    DISPLAY_CHARS 'R',00H,1
    JMP SEND 
    
    BACKSPACESEND:
    MOV DX,CURSOR1 
    CMP DL,0
    JE RECIEVE
    DEC DX
    MOV CURSOR1,DX
    MOV AH,02
	MOV BH,0
	INT 10H
    DISPLAY_CHARS 'R',00H,1
    SEND_BYTE CHAR 
    JMP RECIEVE
    
    
CHAT_MODE ENDP

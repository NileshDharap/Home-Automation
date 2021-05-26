RS 	EQU 	P3.6
EN 	EQU 	P3.7
H	EQU 	30H
T 	EQU		31H
U 	EQU		32H


org 0000h
	JMP start

org 0100h
	start:
	SETB 	P1.2 		;SerialCom option
	SETB 	P1.1		;KeypadCom option
	CLR 	P1.3		;LOAD
	MOV 	R7,#02		;DigitCounter for Keypad
	MOV 	R4,#00      ;msg display counter
	//config ports
	MOV 	P1,#0F0H	;init 4 pins as input
	MOV 	P2,#00H		;init as o/p port--Keypad
	MOV 	P0,#00H		;init as o/p port--LCD 
	
	SETB 	P1.3		;Assume Load to be ON
	
	//LCD init
	MOV 	A,#38H
	CALL 	LCD_CMD
	MOV 	A,#0CH
	CALL 	LCD_CMD
	MOV 	A,#01H
	CALL 	LCD_CMD	
	
	;Check for response 
	noresp:
	JB 		P1.2,scom  	;check for serial comm
	JB 		P1.1,keypad ;check for keypad comm
	JMP		noresp
	
	keypad:
	CALL 	GET_KEY			;keypad interfacing
	
	JMP 	below			;Jump if not keypad
	scom:
	LCALL serial
	below:
	CALL 	STOPWATCH
	
	CLR 	P1.3			//Relay point
	
	JMP  $					

org 0200h 
	DELAY_13ms:
	MOV 	R1,#26	
up: MOV 	R0,#250
	DJNZ	R0,$
	DJNZ 	R1,up
	RET
	
org 0300h
	LCD_CMD:
		MOV 	P0,A
		CLR 	RS 	//select cmd reg
		SETB 	EN
		CALL 	DELAY_13ms 
		CLR 	EN
		RET
org 0400h
	LCD_DATA:
		MOV 	P0,A
		SETB 	RS 	//select cmd reg
		SETB 	EN
		CALL 	DELAY_13ms 
		CLR 	EN
		RET
		
org 0450h
	DELAY_1s:
	MOV 	R2,#06
up3:MOV 	R1,#250	
up2: MOV 	R0,#250
	DJNZ	R0,$
	DJNZ 	R1,up2
	DJNZ 	R2,up3
	RET 
	
org 0500h
	DISPLAY_1:
	MOV 	A,#'1'
	CALL 	LCD_DATA
	RET
	
	DISPLAY_2:
	MOV 	A,#'2'
	CALL 	LCD_DATA
	RET
	
	DISPLAY_3:
	MOV 	A,#'3'
	CALL 	LCD_DATA
	RET
	
	DISPLAY_4:
	MOV 	A,#'4'
	CALL 	LCD_DATA
	RET
	
	DISPLAY_5:
	MOV 	A,#'5'
	CALL 	LCD_DATA
	RET
	
	DISPLAY_6:
	MOV 	A,#'6'
	CALL 	LCD_DATA
	RET
	
	DISPLAY_7:
	MOV 	A,#'7'
	CALL 	LCD_DATA
	RET
	
	DISPLAY_8:
	MOV 	A,#'8'
	CALL 	LCD_DATA
	RET
	
	DISPLAY_9:
	MOV 	A,#'9'
	CALL 	LCD_DATA
	RET
	
	DISPLAY_0:
	MOV 	A,#'0'
	CALL 	LCD_DATA
	RET
	
	DISPLAY_hash:
	MOV 	A,#'#'
	CALL 	LCD_DATA
	RET
	
	DISPLAY_STAR:
	MOV     A,#'*'
	CALL 	LCD_DATA
	RET
	

org 0600h
	GET_KEY:
	
next11:	
		CALL 	DELAY_13ms
		MOV		P2,#7FH		
		JB 	P1.7,next0
		CALL 	DISPLAY_1
		MOV 	A,#01
		CALL 	CHECK_DIGIT
		CALL 	DELAY_1s
next0:	JB 	P1.6,next1
		CALL 	DISPLAY_4
		MOV 	A,#04
		CALL 	CHECK_DIGIT
		CALL 	DELAY_1s
next1:	JB 	P1.5,next2
		CALL 	DISPLAY_7
		MOV 	A,#07
		CALL 	CHECK_DIGIT
		CALL 	DELAY_1s
next2:	JB 	P1.4,next3
		CALL    DISPLAY_STAR
		MOV 	A,#'*'
		CALL 	CHECK_DIGIT
		CALL 	DELAY_1s
next3:		
		CALL 	DELAY_13ms
		MOV 	P2,#0BFH
		JB 	P1.7,next4
		CALL 	DISPLAY_2
		MOV 	A,#02
		CALL 	CHECK_DIGIT
		CALL 	DELAY_1s
next4:	JB 	P1.6,next5
		CALL 	DISPLAY_5
		MOV 	A,#05
		CALL 	CHECK_DIGIT
		CALL 	DELAY_1s
next5:	JB 	P1.5,next6
		CALL 	DISPLAY_8
		MOV 	A,#08
		CALL 	CHECK_DIGIT
		CALL 	DELAY_1s
next6:	JB 	P1.4,next7
		CALL 	DISPLAY_0
		MOV 	A,#00
		CALL 	CHECK_DIGIT
		CALL 	DELAY_1s
next7:		
		CALL 	DELAY_13ms
		MOV 	P2,#0DFH
		JB 	P1.7,next8
		CALL 	DISPLAY_3
		MOV 	A,#03
		CALL 	CHECK_DIGIT
		CALL 	DELAY_1s
next8:	JB 	P1.6,next9
		CALL 	DISPLAY_6
		MOV 	A,#06
		CALL 	CHECK_DIGIT
		CALL 	DELAY_1s
next9:	JB 	P1.5,next10
		CALL 	DISPLAY_9
		MOV 	A,#09
		CALL 	CHECK_DIGIT
		CALL 	DELAY_1s
next10:	JNB 	P1.4,hnext11
		JMP 	next11
hnext11:
		CALL 	DISPLAY_hash
		CALL 	DELAY_1s
		MOV 	A,#01
		CALL 	LCD_CMD
		
		RET
		
org 0800h
	CHECK_DIGIT:
	    CJNE    A,#'*',down0
		LJMP    start
down0:  CJNE 	R7,#02,down1
		MOV 	H,A				//Hundreds place digit H
		DEC 	R7
		RET
down1:	
		CJNE 	R7,#01,down2
		MOV 	T,A				//Tens place digit T
		DEC 	R7
		RET
down2:	
		MOV 	U,A				//Units place digit U
		RET

org 0900h
	GET_ASCII:
	MOV 	A,#30H
	ADD 	A,B
	RET
	
org 1000h
	STOPWATCH:
	CALL 	DISPLAY_DIGIT
	CALL 	DELAY_1s
	MOV		A,U					
	CJNE	A,#00h,br11			
	JMP		br1					 
br11:DEC 	U					
	JMP		STOPWATCH			

br1:
	MOV		A,T					
	CJNE	A,#00,br22			
	JMP		br2					
br22:MOV 	U,#09				
	DEC 	T					
	JMP		STOPWATCH			

br2:
	MOV		A,H					
	CJNE	A,#00,br33			
	JMP		br3					
br33:MOV 	T,#09				
	 MOV	U,#09				
	 DEC 	H					
	 JMP 	STOPWATCH			
br3:	
	RET

org 1100h
	DISPLAY_DIGIT:			// Displays HTU 
	
	CALL 	DISP_MSG
	
	MOV 	A,#0C7h
	CALL	LCD_CMD
	
	MOV 	B,H
	CALL 	GET_ASCII
	CALL 	LCD_DATA
	
	MOV 	A,#0C8h
	CALL	LCD_CMD
	
	MOV 	B,T
	CALL 	GET_ASCII
	CALL 	LCD_DATA
	
	MOV 	A,#0C9h
	CALL	LCD_CMD
	
	MOV 	B,U
	CALL 	GET_ASCII
	CALL 	LCD_DATA
	
	MOV 	A,#80H
	CALL	LCD_CMD
	
	RET


org 1200h
	MSG:	DB 	"----Time left:----",00H

org 1250h
	GET_MSG:
	MOV 	A,R4
	MOV		DPTR,#1200H
	MOVC 	A,@A+DPTR
	RET
	
org 1300h
	DISP_MSG:
on0:CALL 	GET_MSG
	CALL 	LCD_DATA
	INC 	R4
	CJNE 	A,#00,on0
	MOV 	R4,#00
	RET

org 1350h
	serial:
	//Init Serial
	CLR 	TR1
	MOV 	TMOD,#20H
	MOV 	TL1,#0FDH
	MOV 	TH1,#0FDH
	SETB 	TR1
	
	MOV 	SCON,#50H		;SCON as rx mode
	
 	JNB 	RI,$			
	CLR 	RI
	
	MOV 	A,SBUF			;Hundreds place
	CALL 	LCD_DATA	
	SUBB	A,#30H
	MOV 	H,A
	
	
	JNB 	RI,$
	CLR 	RI
	
	MOV 	A,SBUF			;Tens place
	CALL 	LCD_DATA
	SUBB	A,#30H
	MOV 	T,A
	
	JNB 	RI,$
	CLR 	RI
	
	MOV 	A,SBUF
	CALL 	LCD_DATA
	SUBB	A,#30H			;Units place
	MOV 	U,A
	
	MOV 	A,#01H
	CALL 	LCD_CMD
	
	RET
end		
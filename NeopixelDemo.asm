; Simple test for the NeoPixel peripheral

ORG 0

;*******************************************************************************
;  16-BIT AUTO INCREMENT(1 jump) SECTION 1
;*******************************************************************************

AutoIncOne:
	OUT		CLEAR_ALL; clean slate
	CALL	WaitUpdate
	LOADI	1
	OUT		AUTO_INC ; set auto inc to 1 
	LOAD	BLUE16
	STORE	REG1 ; store color data
	LOADI	-1
	STORE	REG2 ; store loop counter
	LOADI	0
	OUT		PXL_ADDR1 ; starting address 

OneJumpPos:
	LOAD	REG2 ; increment counter 
	ADDI	1
	STORE	REG2
	
	LOAD	REG1
	OUT		RGB_16 ; set color
	ADDI	-1 ; decrease blue intensity
	STORE	REG1  ; color data
	LOADI	1
	CALL	DelayAC

	LOAD	REG2
	ADDI	-31
	JNEG	OneJumpPos ; loop continue condition

AutoIncOneNeg:
	LOADI	-1
	OUT		AUTO_INC ; set auto inc to -1
	LOAD	BLUE16
	STORE	REG1 ; store color data
	LOADI	-1
	STORE	REG2 ; store loop counter
	LOADI	191
	OUT		PXL_ADDR1 ; starting address 

OneJumpNeg:
	LOAD	REG2 ; increment counter 
	ADDI	1
	STORE	REG2
	
	LOAD	REG1
	OUT		RGB_16 ; set color
	ADDI	-1 ; decrease blue intensity
	STORE	REG1  ; color data
	LOADI	1
	CALL	DelayAC

	LOAD	REG2
	ADDI	-31
	JNEG	OneJumpNeg ; loop continue condition

	CALL	WaitSwitchTurnPositive
	
;*******************************************************************************
;  16-BIT AUTO INCREMENT(2 jump) SECTION 2
;*******************************************************************************
AutoIncTwo: 
	OUT		CLEAR_ALL; clean slate
	CALL	WaitUpdate
	LOADI	2
	OUT		AUTO_INC ; set auto inc to 2
	LOAD	BLUE16
	STORE	REG1 ; store color data
	LOADI	-1
	STORE	REG2 ; store loop counter
	LOADI	0
	OUT		PXL_ADDR1 ; starting address 

TwoJumpPos:
	LOAD	REG2
	ADDI	1
	STORE	REG2
	
	LOAD	REG1
	OUT		RGB_16 ; set color
	ADDI	-1 ; decrease blue intensity
	STORE	REG1
	LOADI	1
	CALL	DelayAC

	LOAD	REG2
	ADDI	-31
	JNEG	TwoJumpPos ; loop continue condition

AutoIncTwoNeg: 
	LOADI	-2
	OUT		AUTO_INC ; set auto inc to -2
	LOAD	BLUE16
	STORE	REG1 ; store color data
	LOADI	-1
	STORE	REG2 ; store loop counter
	LOADI	191
	OUT		PXL_ADDR1 ; starting address 

TwoJumpNeg:
	LOAD	REG2
	ADDI	1
	STORE	REG2
	
	LOAD	REG1
	OUT		RGB_16 ; set color
	ADDI	-1 ; decrease blue intensity
	STORE	REG1
	LOADI	1
	CALL	DelayAC

	LOAD	REG2
	ADDI	-31
	JNEG	TwoJumpNeg ; loop continue condition

	CALL	WaitSwitchTurnZero

;*******************************************************************************
;  Set range 16-bit VS 24-bit SECTION 3
;*******************************************************************************
	OUT		CLEAR_ALL; clean slate
	CALL	WaitUpdate

	LOADI	0					; SET RANGE TO FIRST ROW
	OUT		PXL_ADDR1
	LOADI	31
	OUT		PXL_ADDR2
	
	LOAD	BLUEL_16		;16-BIT COLOR blue
	OUT		SET_RANGE
	CALL	WaitUpdate
	
	LOADI	15
	CALL	DelayAC
	
	LOADI	32					; SET RANGE TO SECOND ROW
	OUT 	PXL_ADDR1
	LOADI	63
	OUT 	PXL_ADDR2
	
	LOADI	1
	OUT		X
	
	LOADI	&B00000000				; load lowest blue
	OUT		RED_24					
	LOADI	&B00000000
	OUT		GREEN_24
	LOADI	&B00000001				
	OUT		SET_RANGE_X_BLUE_24		;24-BIT COLOR RANGE SET
	
	LOADI	15
	CALL	DelayAC
	
	;------------------------------------
	LOADI	64					; SET RANGE TO THIRD ROW
	OUT 	PXL_ADDR1
	LOADI	95
	OUT 	PXL_ADDR2
	
	LOAD	GREENL_16		;16-BIT COLOR GREEN
	OUT		SET_RANGE
	
	LOADI	15
	CALL	DelayAC
	
	LOADI	96					; SET RANGE TO FOURTH ROW
	OUT 	PXL_ADDR1
	LOADI	127
	OUT 	PXL_ADDR2
	
	LOADI	1
	OUT		X
	
	LOADI	&B00000000
	OUT		RED_24					;24-BIT GREEN
	LOADI	&B00000001
	OUT		GREEN_24
	LOADI	&B00000000
	OUT		SET_RANGE_X_BLUE_24		;24-BIT COLOR RANGE SET
	
	LOADI	15
	CALL	DelayAC
	
	;---------------------------------------
	
	LOADI	128					; SET RANGE TO FIFTH ROW
	OUT 	PXL_ADDR1
	LOADI	159
	OUT 	PXL_ADDR2
	
	LOAD	REDL_16			;16-BIT COLOR green blue
	OUT		SET_RANGE
	LOADI	15
	CALL	DelayAC
	
	LOADI	160					; SET RANGE TO SIXTH ROW
	OUT 	PXL_ADDR1
	LOADI	191
	OUT 	PXL_ADDR2
	
	LOADI	1
	OUT		X
	
	LOADI	&B00000001
	OUT		RED_24					;24-BIT green and blue
	LOADI	&B00000000
	OUT		GREEN_24
	LOADI 	&B00000000
	OUT		SET_RANGE_X_BLUE_24		;24-BIT COLOR RANGE SET


	CALL	WaitSwitchTurnPositive

	

;*******************************************************************************
;  16-bit set all SECTION 4
;*******************************************************************************

	OUT		CLEAR_ALL; clean slate
	CALL	WaitUpdate

DecreasingOuter:
	LOADI	&B0000000000000111
	STORE	REG1 ; store individual color data
	LOADI	-1
	STORE	REG2 ; store loop counter

Decreasing:
    ; check switches to exit loop
    IN		Switches
    JZERO	SecFourEnd    

    ; increment counter
	LOAD	REG2
	ADD		-1
	STORE	REG2
    
    ; Set color
    LOAD	REG3
    OUT		SET_ALL
    CALL	WaitUpdate
    
    ; decrease individual color value
    LOAD	REG1
	ADDI	-1	 
	STORE	REG1
    
    ; reset composite color
    LOADI	0
    STORE	REG3
    
    ; compose composite color and save
    LOAD	REG1
    SHIFT	11
    OR		REG3
    STORE	REG3
    
    LOAD	REG1
    SHIFT	5
    OR		REG3
    STORE	REG3
    
    LOAD	REG1
    OR		REG3
    STORE	REG3
    
    ; LOAD    REG1
    ; OUT   	 SET_ALL
    ; CALL    WaitUpdate
    
    ; LOAD    REG1
    ; ADDI    -1
    ; STORE    REG1
    
    LOADI	4
    CALL	DelayAC ; 0.1 second delay
    
    ; if reg1 = 0, SeeFour
    LOAD	REG1
    JZERO	IncreasingOuter
    
    LOAD	REG2
    ADDI	-7
    JNEG	Decreasing
    
IncreasingOuter:
	LOADI	0
	STORE	REG1 ; store individual color data
	LOADI	-1
	STORE	REG2 ; store loop counter
   	 

Increasing:
    ; check switches to exit loop
    IN		Switches
    JZERO	SecFourEnd

    ; increment counter
	LOAD	REG2
	ADD		-1
	STORE	REG2
    
    ; Set color
    LOAD	REG3
    OUT		SET_ALL
    CALL	WaitUpdate
    
    ; decrease individual color value
    LOAD	REG1
	ADDI	1   
	STORE	REG1
    
    ; reset composite color
    LOADI	0
    STORE	REG3
    
    ; compose composite color and save
    LOAD	REG1
    SHIFT	11
    OR		REG3
    STORE	REG3
    
    LOAD	REG1
    SHIFT	5
    OR		REG3
    STORE	REG3
    
    LOAD	REG1
    OR		REG3
    STORE	REG3
    
    ; LOAD    REG1
    ; OUT   	 SET_ALL
    ; CALL    WaitUpdate
    
    ; LOAD    REG1
    ; ADDI    -1
    ; STORE    REG1
    
    LOADI	4
    CALL	DelayAC ; 0.1 second delay
    
    ; if reg1 = 0, SeeFour
    LOAD	REG1
    ADDI	-7
    JZERO	DecreasingOuter
    
    LOAD	REG2
    ADDI	-7
    JNEG	Increasing
   	 
    
SecFourEnd:
    OUT		CLEAR_ALL ; TEMP
    CALL	WaitSwitchTurnZero


;*******************************************************************************
;  Reading from RAM SECTION 5
;*******************************************************************************
	LOADI	0
	OUT		AUTO_INC
	
	OUT 	CLEAR_ALL
	CALL 	WaitUpdate

	LOADI 	64
	OUT		PXL_ADDR1
	
	LOADI	95
	OUT		PXL_ADDR2

Loop:
	LOADI	1
	CALL	DelayAC

	LOAD	pixColor
	OUT		SET_RANGE
	
	CALL	WaitUpdate
	
	LOAD	pixColor
	ADDI	1
	STORE	pixColor
	
	IN		RGB_16
	OUT 	HEX0
	
	IN		Switches
	JPOS	Exit
	JUMP	Loop
	
Exit:


;*******************************************************************************
;  SetAllX for Section 6
;*******************************************************************************
	OUT		CLEAR_ALL
	CALL	WaitUpdate
	SetAllXLoop:
		LOAD	LOOPCOUNTER
		ADDI	1
		STORE	LOOPCOUNTER

		LOAD	X_VALUE
		OUT		X
		OUT		CLEAR_ALL
		CALL 	WaitUpdate
		LOAD 	COLOR
		OUT 	SET_ALL_X
		CALL 	WaitUpdate ;wait for set all to finish

		LOADI 	50
		CALL 	DelayAC 

		LOAD 	COLOR
		ADDI 	1000
		STORE 	COLOR
		LOAD 	X_VALUE
		ADDI 	-6
		JZERO 	SetOne ;max x value reached
		JNEG 	IncXValue ;else keep incrementing
		SetOne:
			LOADI 	1
			STORE 	X_VALUE
			JUMP 	CheckLoop
		IncXValue:
			LOAD 	X_VALUE
			ADDI 	1
			STORE 	X_VALUE
		CheckLoop:
			IN		Switches
			JZERO	EXTRAVEGANT_SET_RANGE_X_DISPLAY
			JUMP	SetAllXLoop

;*******************************************************************************
;  Set xth range for Section 7   
;*******************************************************************************
EXTRAVEGANT_SET_RANGE_X_DISPLAY:
	OUT		CLEAR_ALL
	CALL	WaitUpdate

	CALL	SET_RANGE_X_RGB1
	
	LOADI	10
	CALL	DelayAC
	OUT		CLEAR_ALL
	CALL	WaitUpdate
	
	CALL	SET_RANGE_X_RGB2
	
	LOADI	10
	CALL	DelayAC
	OUT		CLEAR_ALL
	CALL	WaitUpdate
	
	CALL	SET_RANGE_X_RGB3
	
	LOADI	10
	CALL	DelayAC
	OUT		CLEAR_ALL
	CALL	WaitUpdate
	
	CALL	SET_RANGE_X_CY1
	
	LOADI	10
	CALL	DelayAC
	OUT		CLEAR_ALL
	CALL	WaitUpdate
	
	CALL	SET_RANGE_X_CY2
	
	LOADI	10
	CALL	DelayAC
	OUT		CLEAR_ALL
	CALL	WaitUpdate
	
	CALL	SET_RANGE_X_CY3
	
	LOADI	10
	CALL	DelayAC
	OUT		CLEAR_ALL
	CALL	WaitUpdate
	
	CALL	SET_RANGE_X_RGB1
	CALL	SET_RANGE_X_RGB2
	CALL	SET_RANGE_X_RGB3
	
	LOADI	10
	CALL	DelayAC
	OUT		CLEAR_ALL
	CALL	WaitUpdate
	
	CALL	SET_RANGE_X_CY1
	CALL	SET_RANGE_X_CY2
	CALL	SET_RANGE_X_CY3
	
	LOADI	10
	CALL	DelayAC
	OUT		CLEAR_ALL
	CALL	WaitUpdate
	
	CALL	SET_RANGE_X_RGB1
	CALL	SET_RANGE_X_RGB2
	CALL	SET_RANGE_X_RGB3
	CALL	SET_RANGE_X_CY1
	CALL	SET_RANGE_X_CY2
	CALL	SET_RANGE_X_CY3
	
	LOADI	10
	CALL	DelayAC
	OUT		CLEAR_ALL
	CALL	WaitUpdate
	
	IN		Switches
	JPOS	PONG_DEMO
	JUMP	EXTRAVEGANT_SET_RANGE_X_DISPLAY
	
;*******************************************************************************
;  Pong Demo		Section 8
;*******************************************************************************
PONG_DEMO:
	LOADI		0
	OUT			AUTO_INC
	
	
	LOAD		dimWhite
	OUT			SET_ALL
	CALL		WaitUpdate
	
	LOAD		redBall
	STORE		ballColor
	
	CALL		SetBorders
	
Begin:

VertBounce:
	LOAD		yCoord
	SUB			floor
	JZERO		bounceBottom
	
	LOAD		yCoord
	SUB			roof
	JZERO		bounceTop
	
	JUMP		HorizBounce

bounceBottom:
	LOADI		1
	STORE		yDir
	JUMP		HorizBounce
	
bounceTop:
	LOADI		-1
	STORE		yDir
	JUMP		HorizBounce

HorizBounce:
	LOAD		xCoord
	SUB			leftSide
	JZERO		bounceLeft
	
	LOAD		xCoord
	SUB			rightSide
	JZERO		bounceRight
	
	JUMP		Move
	
bounceLeft:
	LOADI		1
	STORE		xDir
	LOAD		redBall
	STORE		ballColor
	JUMP		Move
	
bounceRight:
	LOADI		-1
	STORE		xDir
	LOAD		blueBall
	STORE		ballColor
	JUMP		Move

Move:
	LOAD		xCoord
	ADD			xDir
	STORE		xCoord
	
	LOAD		yCoord
	ADD			yDir
	STORE		yCoord
	
SetPixel:
	LOAD		realPos
	OUT			PXL_ADDR1
	LOAD		dimWhite
	OUT			RGB_16
	
	CALL		FindRealPos
	
	LOAD		realPos
	OUT			PXL_ADDR1
	LOAD		ballColor
	OUT			RGB_16
	
	LOAD		realPos
	OUT			PXL_ADDR1
	IN			RGB_16
	OUT			Hex0
	SUB			blueBall
	JZERO		moveLeft
	JUMP		MoveRight
	
	
moveLeft:
	LOAD	yCoord
	SUB		lPaddlePos
	JNEG	moveLDown
	JPOS	moveLUp
	JZERO	doneMoving
	
moveLDown:
	LOAD	lPaddlePos
	ADDI	-1
	JZERO	doneMoving
	STORE	lPaddlePos
	JUMP	doneMoving
	
moveLUp:
	LOAD	lPaddlePos
	ADDI	1
	ADDI	-5
	JZERO	doneMoving
	ADDI	5
	STORE	lPaddlePos
	JUMP	doneMoving

moveRight:
	LOAD	yCoord
	SUB		rPaddlePos
	JNEG	moveRDown
	JPOS	moveRUp
	JZERO	doneMoving
	
moveRDown:
	LOAD	rPaddlePos
	ADDI	-1
	JZERO	doneMoving
	STORE	rPaddlePos
	JUMP	doneMoving
	
moveRUp:
	LOAD	rPaddlePos
	ADDI	1
	ADDI	-5
	JZERO	doneMoving
	ADDI	5
	STORE	rPaddlePos
	JUMP	doneMoving
	
	
	
doneMoving:

	CALL		SetBorders

	LOADI		1
	CALL		DelayAC
	
	JUMP		Begin
	
	
FindRealPos:
	
	LOADI	0
	STORE	realPos
	
	LOAD	yCoord
	
	AND		one
	
	JPOS	ODD
	JUMP	EVEN
	
EVEN:
	LOAD	yCoord
	STORE	tempCounter
MultEVEN:
	LOAD	tempCounter
	JZERO	NextEVEN
	ADDI	-1
	STORE	tempCounter
	LOAD	realPos
	ADDI	32
	STORE	realPos
	JUMP	MultEVEN
	
NextEVEN:
	LOAD	realPos
	ADDI	32
	SUB		xCoord
	SUB		one
	STORE	realPos
	
	JUMP Finish

ODD:
	LOAD	yCoord
	STORE	tempCounter
MultODD:
	LOAD	tempCounter
	JZERO	NextODD
	ADDI	-1
	STORE	tempCounter
	LOAD	realPos
	ADDI	32
	STORE	realPos
	JUMP	MultODD
	
NextODD:
	LOAD	realPos
	ADD		xCoord
	STORE	realPos
	
Finish:
	RETURN


SetBorders:
	LOAD	lPaddlePos
	ADDI	-1
	JZERO	BL
	ADDI	-1
	JZERO	M1L
	ADDI	-1
	JZERO	M2L
	ADDI	-1
	JZERO	TL
	
BL:
	CALL	L0
	CALL	L1
	CALL	L2
	CALL	CL3
	CALL	CL4
	CALL	CL5
	JUMP	RightPad
M1L:
	CALL	CL0
	CALL	L1
	CALL	L2
	CALL	L3
	CALL	CL4
	CALL	CL5
	JUMP	RightPad
M2L:
	CALL	CL0
	CALL	CL1
	CALL	L2
	CALL	L3
	CALL	L4
	CALL	CL5
	JUMP	RightPad
TL:
	CALL	CL0
	CALL	CL1
	CALL	CL2
	CALL	L3
	CALL	L4
	CALL	L5
	JUMP	RightPad
RightPad:
	LOAD	rPaddlePos
	ADDI	-1
	JZERO	BR
	ADDI	-1
	JZERO	M1R
	ADDI	-1
	JZERO	M2R
	ADDI	-1
	JZERO	TR

BR:
	CALL	R0
	CALL	R1
	CALL	R2
	CALL	CR3
	CALL	CR4
	CALL	CR5
	RETURN
M1R:
	CALL	CR0
	CALL	R1
	CALL	R2
	CALL	R3
	CALL	CR4
	CALL	CR5
	RETURN
M2R:
	CALL	CR0
	CALL	CR1
	CALL	R2
	CALL	R3
	CALL	R4
	CALL	CR5
	RETURN
TR:
	CALL	CR0
	CALL	CR1
	CALL	CR2
	CALL	R3
	CALL	R4
	CALL	R5
	RETURN

	;Right Wall

R0:
	LOADI	0
	OUT		PXL_ADDR1
	LOAD	rightWall
	OUT		RGB_16
	RETURN

R1:	
	LOADI	63
	OUT		PXL_ADDR1
	LOAD	rightWall
	OUT		RGB_16
	RETURN

R2:	
	LOADI	64
	OUT		PXL_ADDR1
	LOAD	rightWall
	OUT		RGB_16
	RETURN

R3:	
	LOADI	127
	OUT		PXL_ADDR1
	LOAD	rightWall
	OUT		RGB_16
	RETURN

R4:	
	LOADI	128
	OUT		PXL_ADDR1
	LOAD	rightWall
	OUT		RGB_16
	RETURN

R5:	
	LOADI	191
	OUT		PXL_ADDR1
	LOAD	rightWall
	OUT		RGB_16
	RETURN
	
	;Left Wall

L0:
	LOADI	31
	OUT		PXL_ADDR1
	LOAD	leftWall
	OUT		RGB_16
	RETURN
	
L1:
	LOADI	32
	OUT		PXL_ADDR1
	LOAD	leftWall
	OUT		RGB_16
	RETURN
	
L2:
	LOADI	95
	OUT		PXL_ADDR1
	LOAD	leftWall
	OUT		RGB_16
	RETURN
	
L3:
	LOADI	96
	OUT		PXL_ADDR1
	LOAD	leftWall
	OUT		RGB_16
	RETURN
	
L4:
	LOADI	159
	OUT		PXL_ADDR1
	LOAD	leftWall
	OUT		RGB_16
	RETURN
	
L5:
	LOADI	160
	OUT		PXL_ADDR1
	LOAD	leftWall
	OUT		RGB_16
	RETURN


ClearBorders:
	;Right Wall

CR0:
	LOADI	0
	OUT		PXL_ADDR1
	LOAD	dimWhite
	OUT		RGB_16
	RETURN

CR1:	
	LOADI	63
	OUT		PXL_ADDR1
	LOAD	dimWhite
	OUT		RGB_16
	RETURN

CR2:	
	LOADI	64
	OUT		PXL_ADDR1
	LOAD	dimWhite
	OUT		RGB_16
	RETURN

CR3:	
	LOADI	127
	OUT		PXL_ADDR1
	LOAD	dimWhite
	OUT		RGB_16
	RETURN

CR4:	
	LOADI	128
	OUT		PXL_ADDR1
	LOAD	dimWhite
	OUT		RGB_16
	RETURN

CR5:	
	LOADI	191
	OUT		PXL_ADDR1
	LOAD	dimWhite
	OUT		RGB_16
	RETURN
	
	;Left Wall

CL0:
	LOADI	31
	OUT		PXL_ADDR1
	LOAD	dimWhite
	OUT		RGB_16
	RETURN
	
CL1:
	LOADI	32
	OUT		PXL_ADDR1
	LOAD	dimWhite
	OUT		RGB_16
	RETURN
	
CL2:
	LOADI	95
	OUT		PXL_ADDR1
	LOAD	dimWhite
	OUT		RGB_16
	RETURN
	
CL3:
	LOADI	96
	OUT		PXL_ADDR1
	LOAD	dimWhite
	OUT		RGB_16
	RETURN
	
CL4:
	LOADI	159
	OUT		PXL_ADDR1
	LOAD	dimWhite
	OUT		RGB_16
	RETURN
	
CL5:
	LOADI	160
	OUT		PXL_ADDR1
	LOAD	dimWhite
	OUT		RGB_16
	RETURN

END: JUMP	END

SET_RANGE_X_RGB1:
	LOADI	3
	OUT		X
	LOADI	0
	OUT		PXL_ADDR1
	LOADI	31
	OUT		PXL_ADDR2
	LOAD	DIM_RED
	OUT		SET_RANGE_X
	CALL	WaitUpdate
	
	LOADI	1
	OUT		PXL_ADDR1
	LOADI	31
	OUT		PXL_ADDR2
	LOAD	DIM_GREEN
	OUT		SET_RANGE_X
	CALL	WaitUpdate
	
	LOADI	2
	OUT		PXL_ADDR1
	LOADI	31
	OUT		PXL_ADDR2
	LOAD	DIM_BLUE
	OUT		SET_RANGE_X
	CALL	WaitUpdate

	RETURN
	
SET_RANGE_X_RGB2:
	LOADI	3
	OUT		X
	LOADI	64
	OUT		PXL_ADDR1
	LOADI	95
	OUT		PXL_ADDR2
	LOAD	DIM_RED
	OUT		SET_RANGE_X
	CALL	WaitUpdate
	
	LOADI	65
	OUT		PXL_ADDR1
	LOADI	95
	OUT		PXL_ADDR2
	LOAD	DIM_GREEN
	OUT		SET_RANGE_X
	CALL	WaitUpdate
	
	LOADI	66
	OUT		PXL_ADDR1
	LOADI	95
	OUT		PXL_ADDR2
	LOAD	DIM_BLUE
	OUT		SET_RANGE_X
	CALL	WaitUpdate

	RETURN

SET_RANGE_X_RGB3:
	LOADI	3
	OUT		X
	LOADI	128
	OUT		PXL_ADDR1
	LOADI	159
	OUT		PXL_ADDR2
	LOAD	DIM_RED
	OUT		SET_RANGE_X
	CALL	WaitUpdate
	
	LOADI	129
	OUT		PXL_ADDR1
	LOADI	159
	OUT		PXL_ADDR2
	LOAD	DIM_GREEN
	OUT		SET_RANGE_X
	CALL	WaitUpdate
	
	LOADI	130
	OUT		PXL_ADDR1
	LOADI	159
	OUT		PXL_ADDR2
	LOAD	DIM_BLUE
	OUT		SET_RANGE_X
	CALL	WaitUpdate

	RETURN
	
SET_RANGE_X_CY1:
	LOADI	2
	OUT		X
	LOADI	32
	OUT		PXL_ADDR1
	LOADI	63
	OUT		PXL_ADDR2
	LOAD	DIM_YELLOW
	OUT		SET_RANGE_X
	CALL	WaitUpdate
	
	LOADI	33
	OUT		PXL_ADDR1
	LOADI	63
	OUT		PXL_ADDR2
	LOAD	DIM_CYAN
	OUT		SET_RANGE_X
	CALL	WaitUpdate

	RETURN

SET_RANGE_X_CY2:
	LOADI	2
	OUT		X
	LOADI	96
	OUT		PXL_ADDR1
	LOADI	127
	OUT		PXL_ADDR2
	LOAD	DIM_YELLOW
	OUT		SET_RANGE_X
	CALL	WaitUpdate
	
	LOADI	97
	OUT		PXL_ADDR1
	LOADI	127
	OUT		PXL_ADDR2
	LOAD	DIM_CYAN
	OUT		SET_RANGE_X
	CALL	WaitUpdate

	RETURN

SET_RANGE_X_CY3:
	LOADI	2
	OUT		X
	LOADI	160
	OUT		PXL_ADDR1
	LOADI	191
	OUT		PXL_ADDR2
	LOAD	DIM_YELLOW
	OUT		SET_RANGE_X
	CALL	WaitUpdate
	
	LOADI	161
	OUT		PXL_ADDR1
	LOADI	191
	OUT		PXL_ADDR2
	LOAD	DIM_CYAN
	OUT		SET_RANGE_X
	CALL	WaitUpdate

	RETURN	

;*******************************************************************************
; DelayAC: Pause for some multiple of 0.1 seconds.
; Call this with the desired delay in AC.
; E.g. if AC is 10, this will delay for 10*0.1 = 1 second
;*******************************************************************************
DelayAC:
	STORE  DelayTime   ; Save the desired delay
	OUT    Timer       ; Reset the timer
WaitingLoop:
	IN     Timer       ; Get the current timer value
	SUB    DelayTime
	JNEG   WaitingLoop ; Repeat until timer = delay value
	RETURN
DelayTime: DW 0
	
	
;*******************************************************************************
;  Wait until Neo-Pixel peripheral is no longer busy 
;*******************************************************************************
WaitUpdate:
	IN		GET_BUSY
	JPOS	WaitUpdate
	RETURN


;*******************************************************************************
; Wait for any switch to go up 
;*******************************************************************************
WaitSwitchTurnPositive:
	IN    	GET_BUSY
	JPOS    WaitSwitchTurnPositive
	IN		Switches
	JZERO	WaitSwitchTurnPositive
	RETURN
	
	
;*******************************************************************************
;  Wait for any switch to go down
;*******************************************************************************
WaitSwitchTurnZero:
	IN    GET_BUSY
	JPOS    WaitSwitchTurnZero
	IN		Switches
	JPOS	WaitSwitchTurnZero
	JNEG	WaitSwitchTurnZero
	RETURN


;*******************************************************************************
;  Registers, EQU
;*******************************************************************************
REG1:			DW 0
REG2:			DW 0
REG3:			DW 0
	
RED16: 			DW &B1111100000000000
GREEN16: 		DW &B0000011111100000
BLUE16: 		DW &B0000000000011111
YELLOW16:		DW &B1111111111100000
CYAN16:			DW &B0000001111101111
PURPLE16:		DW &B0011100000000111
WHITE16: 		DW &B1111111111111111

REDL_16:		DW &B0000100000000000
GREENL_16:		DW &B0000000000100000
BLUEL_16:		DW &B0000000000000001
EIGHT_BIT_LOW:	DW &B00000001

pixColor:	DW 0
readColor:	DW 0

; Carter's Pong Variables
lPaddlePos:		DW 3
rPaddlePos:		DW 3

tempCounter:	DW 0

xCoord:			DW 16
yCoord:			DW 3

realPos:		DW 80

yDir:			DW 1
xDir:			DW 1

one:			DW 1
leftSide:		DW 1
rightSide:		DW 30
floor:			DW 0
roof:			DW 5

dimWhite:		DW &B0000100001000001
;Green
ballColor:		DW &B0000000010000000

redBall:		DW &B0010000000000000
leftWall:		DW &B0001000000000000

blueBall:		DW &B0000000000000111
rightWall:		DW &B0000000000000011

; Arjun's Variables
EIGHT_BITS:		DW &B0000000011111111
COLOR:			DW 0
X_VALUE:		DW 1
LOOPCOUNTER: 	DW 0


; Rak's Variables
RGB16_Color:	DW 0
	
RED: 			DW &B1111100000000000
GREEN: 			DW &B0000011111100000
BLUE: 			DW &B0000000000011111
YELLOW:			DW &B1111111111100000
CYAN:			DW &H0000001111101111
PURPLE:			DW &H0011100000000111
WHITE: 			DW &B1111111111111111
ALT:			DW &B1010101010101010
DIM:			DW &B0001100001100011
FULL_24:		DW &B0000000011111111
DIM_RED:		DW &B0011100000000000
DIM_GREEN:		DW &B0000000011100000
DIM_BLUE:		DW &B0000000000000111
DIM_YELLOW:		DW &B0011100011100000
DIM_CYAN:		DW &H0000000011100111

STORE_GREEN:	DW &B00000000
STORE_RED:		DW &B00000000
STORE_BLUE:		DW &B00000000
STORE_RB:		DW &B0000000000000000


;*******************************************************************************
;  IO Adresses
;*******************************************************************************
Switches:  				EQU 000
LEDs:      				EQU 001
Timer:     				EQU 002
Hex0:      				EQU 004
Hex1:      				EQU 005
PXL_ADDR1:				EQU &H0B0
PXL_ADDR2:				EQU &H0B1
RGB_16:					EQU &H0B2
GREEN_24:				EQU &H0B3
RED_24:					EQU &H0B4
BLUE_24:				EQU &H0B5
AUTO_INC:				EQU &H0B6
SET_ALL:				EQU &H0B7
SET_RANGE:				EQU &H0B8
X:						EQU &H0B9
SET_ALL_X:				EQU &H0BA
SET_RANGE_X:			EQU &H0BB
CLEAR_ALL:				EQU &H0BC
CLEAR_RANGE:			EQU &H0BD
SET_RANGE_X_BLUE_24:	EQU &H0BE
GET_BUSY:				EQU &H0BF
; Simple test for the NeoPixel peripheral

ORG 0
    LOADI  3
    OUT    PXL_A
Loop:
    IN     Switches
	STORE  SWdata
	
	AND		Red
	SHIFT	5
	STORE	Color
	
	LOAD	SWdata
	AND		Green
	SHIFT	2
	ADD		Color
	STORE	Color
	
	LOAD	SWdata
	AND		Blue
	ADD		Color
	STORE	Color
	
    OUT    PXL_D
    JUMP   Loop

; IO address constants
SWdata:	DW 0
Red: 	&B111000000
Green: 	&B000111000
Blue:	&B000000111
Color:	0
Switches:  EQU 000
LEDs:      EQU 001
Timer:     EQU 002
Hex0:      EQU 004
Hex1:      EQU 005
PXL_A:     EQU &H0B0
PXL_D:     EQU &H0B1
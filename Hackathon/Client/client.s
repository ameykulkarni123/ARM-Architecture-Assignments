	AREA     Client, CODE, READONLY
	EXPORT __encodeData
__encodeData FUNCTION
	; Load a test value into R1
	LDR R8,=0x20001000
	MOV R7,#0
	
loop_en CMP R7,R9
		BLE loop_encode
		BX lr
	
	
loop_encode	LDR	R1,[R0,R7]

			; Begin by expanding the 8-bit value to 12-bits, inserting
			; zeros in the positions for the four check bits (bit 0, bit 1, bit 3
			; and bit 7).
			
			AND	R2, R1, #0x1		; Clear all bits apart from d0
			MOV	R6, R2, LSL #2		; Align data bit d0
			
			AND	R2, R1, #0xE		; Clear all bits apart from d1, d2, & d3
			ORR	R6, R6, R2, LSL #3	; Align data bits d1, d2 & d3 and combine with d0
			
			AND	R2, R1, #0xF0		; Clear all bits apart from d3-d7
			ORR	R6, R6, R2, LSL #4	; Align data bits d4-d7 and combine with d0-d3
			
			; We now have a 12-bit value in R0 with empty (0) check bits in
			; the correct positions
			

			; Generate check bit c0
			
			EOR	R2, R6, R6, LSR #2	; Generate c0 parity bit using parity tree
			EOR	R2, R2, R2, LSR #4	; ... second iteration ...
			EOR	R2, R2, R2, LSR #8	; ... final iteration
			
			AND	R2, R2, #0x1		; Clear all but check bit c0
			ORR	R6, R6, R2		; Combine check bit c0 with result
			
			; Generate check bit c1
			
			EOR	R2, R6, R6, LSR #1	; Generate c1 parity bit using parity tree
			EOR	R2, R2, R2, LSR #4	; ... second iteration ...
			EOR	R2, R2, R2, LSR #8	; ... final iteration
			
			AND	R2, R2, #0x2		; Clear all but check bit c1
			ORR	R6, R6, R2		; Combine check bit c1 with result
			
			; Generate check bit c2
			
			EOR	R2, R6, R6, LSR #1	; Generate c2 parity bit using parity tree
			EOR	R2, R2, R2, LSR #2	; ... second iteration ...
			EOR	R2, R2, R2, LSR #8	; ... final iteration
			
			AND	R2, R2, #0x8		; Clear all but check bit c2
			ORR	R6, R6, R2		; Combine check bit c2 with result	
			
			; Generate check bit c3
			
			EOR	R2, R6, R6, LSR #1	; Generate c3 parity bit using parity tree
			EOR	R2, R2, R2, LSR #2	; ... second iteration ...
			EOR	R2, R2, R2, LSR #4	; ... final iteration
			
			AND	R2, R2, #0x80		; Clear all but check bit c3
			ORR	R6, R6, R2		; Combine check bit c3 with result
			
			STR R6, [R8,#0]
			ADD R8,R8,#2
			ADD R7,R7,#1
			B loop_en

	ENDFUNC
	
	EXPORT __encryptData

__encryptData FUNCTION
	MOV R3, #0x02 ; key
	MOV R4, #0
	B loop
loop	CMP R4, R9
		BNE return_main
		BX lr
		
return_main ADD R5, R0, R4
			LDR R6,[R5,#0] ;load data
			AND R7,R6, #0xFFFFFF00
			AND R6,R6,#0xFF	
			EOR R6,R6,R3 ; xor data
			ADD R6,R6,#1 ; add 1
			AND R6,R6,#0xFF
			MOV R3,R6 ; new key
			ADD R6,R6,R7
			STR R6,[R5,#0]
			ADD R4,R4,#1
			B loop
	
	ENDFUNC
	EXPORT __main
     ENTRY 
__main  FUNCTION
	
	; offsets
	MOV R2, #0x0A ; 10
	MOV R6, #0x0A ; 10
	MOV R7, #0x05 ; 5
	MOV R0, #0x20000000 ;base
	MOV R9, #0x100 ; last index
	; debugging
	;MOV R9, #0x0A ; last index
	MOV R10, #0xFF ;pixel
	MOV R1, R0 ; 
	ADD R1, R1, #0x05 ; R1 - hor_half
	MOV R4, #0x0A
	MUL R4, R4, R7
	ADD R5, R1, R4 ; R5 - midpoint
	SUB R5,R5,#0x05
	MOV R8,R5
	;B loop_vertical

	BL __encryptData
	BL __encodeData
done B done
	ENDFUNC
end
     AREA     hackathon, CODE, READONLY
	IMPORT printMsg
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
	
	EXPORT __DecodeData
__DecodeData FUNCTION
	LDR R11, =0x20001000
	LDR R8,=0x20002000
	MOV R10,#0
	MOV R12, #0
loop_dec CMP R10,R9
		 BLE loop_dec_loop
		 BX lr
	
loop_dec_loop	LDR R0, [R11, R12]
				LDR R4, =0x00000FFF
				AND R0, R0, R4
				LDR R3, =0xFFFFFF74
				ADD R12, R12, #2
	            AND R3, R0, R3



	; Generate check bit c0
	
				EOR	R2, R3, R3, LSR #2	; Generate c0 parity bit using parity tree
				EOR	R2, R2, R2, LSR #4	; ... second iteration ...
				EOR	R2, R2, R2, LSR #8	; ... final iteration
				
				AND	R2, R2, #0x1		; Clear all but check bit c0
				ORR	R3, R3, R2		    ; Combine check bit c0 with result
				
				; Generate check bit c1
				
				EOR	R2, R3, R3, LSR #1	; Generate c1 parity bit using parity tree
				EOR	R2, R2, R2, LSR #4	; ... second iteration ...
				EOR	R2, R2, R2, LSR #8	; ... final iteration
				
				AND	R2, R2, #0x2		; Clear all but check bit c1
				ORR	R3, R3, R2		; Combine check bit c1 with result
				
				; Generate check bit c2
				
				EOR	R2, R3, R3, LSR #1	; Generate c2 parity bit using parity tree
				EOR	R2, R2, R2, LSR #2	; ... second iteration ...
				EOR	R2, R2, R2, LSR #8	; ... final iteration
				
				AND	R2, R2, #0x8		; Clear all but check bit c2
				ORR	R3, R3, R2		; Combine check bit c2 with result	
				
				; Generate check bit c3
				
				EOR	R2, R3, R3, LSR #1	; Generate c3 parity bit using parity tree
				EOR	R2, R2, R2, LSR #2	; ... second iteration ...
				EOR	R2, R2, R2, LSR #4	; ... final iteration
				
				AND	R2, R2, #0x80		; Clear all but check bit c3
				ORR	R3, R3, R2		; Combine check bit c3 with result


				
				;Compare the original value (with error) and the recalculated value using exclusive-OR
				EOR R1, R0, R3


				;Isolate the results of the EOR operatation to result in a 4-bit calculation

				;Clearing all bits apart from c7 and shifting bit 4 positions right
				LDR R4, =0X80
				AND R4, R4, R1
				MOV R4, R4, LSR #4

				;Clearing all bits apart from c3 and shifting the 3rd bit 1 position right
				LDR R5, =0X8
				AND R5, R5, R1
				MOV R5, R5, LSR #1

				;Clearing all bits apart from c0 and c1  
				LDR R6, =0X3
				AND R6, R6, R1


				;Adding the 4 registers together 
				ADD R1, R4, R5
				ADD R1, R1, R6 

				;Subtracting 1 from R1 to determine the bit position of the error
				SUB R1, R1, #1

				;Store tmp register with binary 1. Then moves the 1, 8 bit positions left.  We use '8' because R1 contains 8 bits
				LDR R7, =0X1
				MOV R7, R7, LSL R1

				;Flips the bit in bit 8 of R0
				EOR R0, R0, R7
				MOV R3, R0			; decode logic
				LSR R3, #2
				AND R4, R0, #0X0F00
				AND R5, R0, #0X0070
				LSL R5,R5,#1
				AND R6, R3, #0X0001
				LSL R6,R6, #4
				ORR R4,R4,R5
				ORR R4,R4,R6
				LSR R4,R4,#4
				STR R4, [R8, R10]
				ADD R10, R10, #1
				B loop_dec
	
	
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

     EXPORT __decryptData
	
__decryptData FUNCTION
	MOV R3, #0x02 ; key
	MOV R4, #0
	LDR R0, =0x20002000
	
	B loop_d
loop_d	CMP R4, R9
		BNE return_main_d
		BX lr
		
return_main_d   ADD R5, R0, R4
				LDR R6,[R5,#0] ; load data
				AND R7,R6, #0xFFFFFF00
				AND R6,R6,#0xFF
				SUB R6,R6,#1 ; sub 1
				EOR R6,R6,R3 ; xor data
				LDR R3,[R5,#0] ; new key
				AND R3,R3,#0xFF
				ADD R6,R6,R7
				STR R6,[R5,#0]
				ADD R4,R4,#1
				B loop_d
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
	B loop_vertical
done
	BL __encryptData
	BL __encodeData
	BL __DecodeData
	BL __decryptData
stop B stop

loop_vertical CMP R2, #0
			  ITTTE GT
			  STRGT R10, [R1,#0] 
			  ADDGT R1,R1,#10
			  SUBGT R2,R2,#1
			  BLE loop_horizontal
			  B loop_vertical
  
loop_horizontal CMP R6, #0
				ITTTE GT
				STRGT R10, [R5,#0]
				ADDGT R5,R5,#1
				SUBGT R6,R6,#1
				BLE done
				B loop_horizontal
	ENDFUNC
end
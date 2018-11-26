	AREA     hackathon, CODE, READONLY
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


				; Error Correction
				; Generate c0
	
				EOR	R2, R3, R3, LSR #2	;c0 parity
				EOR	R2, R2, R2, LSR #4	
				EOR	R2, R2, R2, LSR #8	
				
				AND	R2, R2, #0x1		; Clear c0
				ORR	R3, R3, R2		    ; Combine c0 with result
				
				; Generate c1
				
				EOR	R2, R3, R3, LSR #1	; c1 parity 
				EOR	R2, R2, R2, LSR #4	
				EOR	R2, R2, R2, LSR #8	
				
				AND	R2, R2, #0x2		; Clear all but c1
				ORR	R3, R3, R2		; Combine c1 with result
				
				; Generate c2
				
				EOR	R2, R3, R3, LSR #1	;c2 parity
				EOR	R2, R2, R2, LSR #2	
				EOR	R2, R2, R2, LSR #8	
				
				AND	R2, R2, #0x8		; Clear all but c2
				ORR	R3, R3, R2		; Combine c2 with result	
				
				; Generate c3
				
				EOR	R2, R3, R3, LSR #1	; Generate c3 parity bit using parity tree
				EOR	R2, R2, R2, LSR #2
				EOR	R2, R2, R2, LSR #4	
				
				AND	R2, R2, #0x80		; Clear all but c3
				ORR	R3, R3, R2		; Combine c3 with result

				EOR R1, R0, R3

				;Clearing all bits apart from c7 and shifting bit 4 positions right
				LDR R4, =0X80
				AND R4, R4, R1
				MOV R4, R4, LSR #4

				LDR R5, =0X8
				AND R5, R5, R1
				MOV R5, R5, LSR #1

				;Clearing all bits but c0 and c1  
				LDR R6, =0X3
				AND R6, R6, R1

				ADD R1, R4, R5
				ADD R1, R1, R6 
				SUB R1, R1, #1

				LDR R7, =0X1
				MOV R7, R7, LSL R1

				; decode logic
				EOR R0, R0, R7
				MOV R3, R0			
				LSR R3, #2
				AND R4, R0, #0X0F00 ;extract [11:8] bits
				AND R5, R0, #0X0070 ;;extract [6:4] bits
				LSL R5,R5,#1
				AND R6, R3, #0X0001 ;extract first bit
				LSL R6,R6, #4
				ORR R4,R4,R5 
				ORR R4,R4,R6
				LSR R4,R4,#4
				STR R4, [R8, R10] 
				ADD R10, R10, #1
				B loop_dec
	
	
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
	BL __DecodeData
	BL __decryptData
stop B stop
	ENDFUNC
end
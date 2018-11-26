     AREA     hackathon, CODE, READONLY


	
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
	MOV R2, #0xEF ; 239
	MOV R6, #0x13F ; 319
	MOV R7, #0x77 ; 119 
	
	MOV R0, #0x20000000 ;base
	MOV R9, #0x12C00 ; last index
	; debugging
	;MOV R9, #0x0A ; last index
	
	
	MOV R10, #0xFF ;pixel
	MOV R1, R0 ; 
	ADD R1, R1, #0x9F ; R1 - hor_half
	MOV R4, #0x140
	MUL R4, R4, R7
	ADD R5, R1, R4 ; R5 - midpoint
	SUB R5,R5,#0x76
	MOV R8,R5
	;B loop_vertical
	
done
	;BL __encryptData
	BL __encodeData
	
	;BL __decryptData
stop B stop

loop_vertical CMP R2, #0
			  ITTTE GE
			  STRGE R10, [R1,#0] 
			  ADDGE R1,R1,#320
			  SUBGE R2,R2,#1
			  BLT loop_horizontal
			  B loop_vertical
			  
loop_horizontal CMP R6, #0
			    ITTTE GE
				STRGE R10, [R5,#0]
				ADDGE R5,R5,#1
				SUBGE R6,R6,#1
				BLT done
				B loop_horizontal
				
	ENDFUNC
end
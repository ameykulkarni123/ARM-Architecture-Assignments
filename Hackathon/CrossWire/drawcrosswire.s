	 AREA     DrawCrossWire, CODE, READONLY
	 EXPORT __main
     ENTRY 
__main  FUNCTION
	
	MOV R2, #0x0A ; 10
	MOV R6, #0x0A ; 10
	; image is 10x10 array
	
	MOV R7, #0x05 ; 5
	MOV R0, #0x20000000 ;base
	MOV R9, #0x100 ; last index
	
	MOV R10, #0xFF ;cross-wire pixel value
	MOV R1, R0 ; 
	ADD R1, R1, #0x05 ; 
	MOV R4, #0x0A
	MUL R4, R4, R7
	ADD R5, R1, R4 ; R5 - midpoint
	SUB R5,R5,#0x05
	MOV R8,R5
	B cross_vertical
done B done 

;running vertically through image array to color cross-wire pixel
cross_vertical CMP R2, #0
			  ITTTE GT
			  STRGT R10, [R1,#0] 
			  ADDGT R1,R1,#10
			  SUBGT R2,R2,#1
			  BLE cross_horizontal
			  B cross_vertical

;running horizontally through image array to color cross-wire pixel
cross_horizontal CMP R6, #0
				ITTTE GT
				STRGT R10, [R5,#0]
				ADDGT R5,R5,#1
				SUBGT R6,R6,#1
				BLE done
				B cross_horizontal
	ENDFUNC
end
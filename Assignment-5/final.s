     AREA     appcode, CODE, READONLY
     export __main	 
     IMPORT printMsg		 
	 ENTRY 
__main  function	
	      VLDR.F32 s0 , =1 ;X0 DATA
          VLDR.F32 s1 , =1 ;X1 DATA
          VLDR.F32 s2 , =1 ;X2 DATA		  
          ADR.W r0 , BranchTable_Byte
		  MOV r1 , #0                   ;r1 will take number to select logic .0-Nand ,1-Nor like that
		  TBB [r0 , r1 ]
NAND_LOGIC         VLDR.F32 s28 ,=0.6 	;WEIGHT W1   
		           VLDR.F32 s29 ,=-0.8  ;WEIGHT W2   
                   VLDR.F32	s30 ,=-0.8 	;WEIGHT W3
                   VLDR.F32 s31 ,=0.3   ;BIAS   
                   B  X_CALCULATION


NOR_LOGIC          VLDR.F32 s28 ,=0.5 	;WEIGHT W1   
		           VLDR.F32 s29 ,=-0.7  ;WEIGHT W2   
                   VLDR.F32	s30 ,=-0.7 	;WEIGHT W3
                   VLDR.F32 s31 ,=0.1   ;BIAS   
                   B  X_CALCULATION

AND_LOGIC         VLDR.F32 s28 ,=-0.1 	;WEIGHT W1   
		          VLDR.F32 s29 ,=0.2  ;WEIGHT W2   
                  VLDR.F32	s30 ,=0.2 	;WEIGHT W3
                  VLDR.F32 s31 ,=-0.2   ;BIAS   
                   B  X_CALCULATION

OR_LOGIC          VLDR.F32 s28 ,=-0.1	;WEIGHT W1   
		          VLDR.F32 s29 ,=0.7  ;WEIGHT W2   
                  VLDR.F32	s30 ,=0.7 	;WEIGHT W3
                  VLDR.F32 s31 ,=-0.1  ;BIAS				  
                   B  X_CALCULATION

XOR_LOGIC         VLDR.F32 s28 ,=-5 	;WEIGHT W1   
		          VLDR.F32 s29 ,=20  ;WEIGHT W2   
                  VLDR.F32	s30 ,=10 	;WEIGHT W3
                  VLDR.F32 s31 ,=1   ;BIAS   
                   B  X_CALCULATION

XNOR_LOGIC        VLDR.F32 s28 ,=-5 	;WEIGHT W1   
		          VLDR.F32 s29 ,=20  ;WEIGHT W2   
                  VLDR.F32	s30 ,=10 	;WEIGHT W3
                  VLDR.F32 s31 ,=1   ;BIAS   
                   B  X_CALCULATION

NOT_LOGIC         VLDR.F32 s2 , =0
                  VLDR.F32 s28 ,=0.5 	;WEIGHT W1   
		          VLDR.F32 s29 ,=-0.7  ;WEIGHT W2   
                  VLDR.F32	s30 ,=0 	;WEIGHT W3
                  VLDR.F32 s31 ,=0.1   ;BIAS   
                   B  X_CALCULATION
		  
X_CALCULATION		  VMUL.F32  s14 , s0 ,s28  ;S15 WILL HAVE SUM OF WEIGHTS
                      VADD.F32  s15  , s15 ,s14
		              VMUL.F32  s14 , s1 ,s29  
					  VADD.F32  s15  , s15 ,s14
					  VMUL.F32  s14 , s2 ,s30
					  VADD.F32  s15  , s15 ,s14
                      VADD.F32  s15 , s15,s31
                      B SIGMOID					  
BranchTable_Byte		  
    DCB   0		  
    DCB   ((NOR_LOGIC-NAND_LOGIC)/2)	
	DCB   ((AND_LOGIC-NAND_LOGIC)/2)	
	DCB   ((OR_LOGIC-NAND_LOGIC)/2)
	DCB   ((XOR_LOGIC-NAND_LOGIC)/2)
	DCB   ((XNOR_LOGIC-NAND_LOGIC)/2)
	DCB   ((NOT_LOGIC-NAND_LOGIC)/2)
SIGMOID	      MOV r0 , #0x20000000 ; location will have value of 1 	
              VMOV.F32 s1 , s15  ;s1 will keep reference of x
	          MOV  r3 ,#0x3f800000   ;Taking constant number 1.
	          STR  r3 , [r0] 
			  VLDR s0 ,[r0]   ;s0 will hold changing value of varying x in series  and s29 is a temporary register for it
			  VLDR s4 ,[r0]
			  VLDR s5 ,[r0]
			  VLDR s6 ,[r0]
			  VLDR s7 ,[r0]
              VLDR s31 ,[r0]     ;All registers are initialized to 1
			  VLDR s30 ,[r0]
			  VLDR s29 ,[r0]
			  VLDR s28 ,[r0]
              B   SERIES			  
			  ;s3 will have sum and s31 is a temporary register for it
			  ;s5 will store divison value and s30 is a temporary register for it
			  ;s4 will store value of factorial and  s28 is a temporary register for it
CHECK_SERIES_MULTIPLICATION			  VMUL.F32 s29 , s0 ,s1
			                          VMRS r1 , FPSCR
			                          AND  r1 ,  r1 , #28
			                          CMP  r1 , #17	
                                                  IT LT									  
			                          BLT  FLOW1	
						  B  STOP
CHECK_SERIES_SUM_VALIDATION           VADD.F32 s31 , s5 , s3
                                      VMRS r1 , FPSCR          ;Storing FPSCR to R1 
				      AND  r1 ,  r1 , #28       
			              CMP  r1 , #17	       ;checking for underflow or overflow 
                                      IT  LT			;Stop if invalid results						  
			              BLT  SERIES	         ;same for all validations
				      B  STOP
CHECK_DIVISION_VALIDATION			  VDIV.F32	s30 , s0 , s4					  
						  VMRS r1 , FPSCR
						  AND  r1 ,  r1 , #28
			                          CMP  r1 , #17	
                                      		  IT  LT									  
			                          BLT  FLOW3	
						  B  STOP
									  
CHECK_SERIES_FACTORIAL_VALIDATION     VMUL.F32   s28 , s4 ,s6
                                      VMRS r1 , FPSCR
				      VADD.F32   s6 , s6 , s7
				      AND  r1 ,  r1 , #28
			              CMP  r1 , #17	
                                      IT  LT									  
			              BLT  FLOW2	
				      B  STOP						

SERIES		 VMOV.F32	  s3 ,s31                 ; copy valid value of s3 and s31 is a temporary register

	        B CHECK_SERIES_MULTIPLICATION		 
FLOW1		VMOV.F32    s0 , s29                    ; copy valid value to s0  and  s29 is atemporary register

                B CHECK_SERIES_FACTORIAL_VALIDATION ; 
		
FLOW2		VMOV.F32     s4  , s28    ; s4 stores factorial and s28 is a temporary register

                B        CHECK_DIVISION_VALIDATION
		
FLOW3		 VMOV.F32      s5  , s30                  ;s30 is a temporary register and s5 will store value of division

	        B       CHECK_SERIES_SUM_VALIDATION
		
STOP		   VLDR s0 ,[r0]  ; stop program
               VDIV.F32 s3 , s0 ,s3
			   VADD.F32 s3 ,s3,s0 
			   VDIV.F32 s3 , s0 , s3
               B     OUTPUT	


OUTPUT     VLDR.F32 s16 , =0.5
           VCMP.F32     s3 , s16  
           VMRS r1 , FPSCR                    ;output is kept  in r0 .LOGIC LSL AND CMP ARE APPLIED ON FPSR FLAGS WHOOSE VALUE IS IN R1
           MOV r2 , #1
		   LSL r2 , r2 ,#31
		   AND r1 , r1, r2
		   CMP r1 , #0
		   ITE  HI
		   MOVHI r0 , #0
		   MOVLS r0 , #1
		   BL printMsg
stop       B   stop		   
        endfunc
      end

     AREA     appcode, CODE, READONLY
     export __main	 
	 ENTRY 
__main  function
	          MOV  r2 , #0x00003333   ;lower 16 bits of x(lsb 16 bits represent data)
	          MOV  r3 , #0x0000c0a3  ;higher 16 bits of x		 
			  LSL  r3 , r3 , #16      ;left shift r3 by 16 bits
              ORR  r3 ,r3 ,r2         ;getting value of x by or operation of r3 and r2
	          MOV r0 , #0x20000000 ; location will have value of x 	
              STR r3 , [ r0 ] 			  
			  VLDR s1 , [r0]   ;s1 will keep reference of x
			  MOV  r3 ,#0x3f800000
			  STR  r3 , [r0] 
			  VLDR s0 ,[r0]   ;s0 will hold changing value of varying x in series  and s29 is a temporary register for it
			  VLDR s4 ,[r0]
			  VLDR s5 ,[r0]
			  VLDR s6 ,[r0]
			  VLDR s7 ,[r0]
              VLDR s31 ,[r0]
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
                                      VMRS r1 , FPSCR
									  AND  r1 ,  r1 , #28
			                          CMP  r1 , #17	
                                      IT  LT									  
			                          BLT  SERIES	
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
STOP		      B STOP  ; stop program
        endfunc
      end


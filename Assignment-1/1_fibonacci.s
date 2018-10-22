      AREA     appcode, CODE, READONLY
     export __main	 
	 ENTRY 
__main  function
	          MOV r0 , #0  ;f(0) = 0
	          MOV r1 , #1    ; f(1) = 1
              MOV r7 , #1	  ; number to calculate fibonacci series 
              MOV r2 , r7	 ; R2 will store output value 		  
              CMP r2 , #1
              IT LS 
              BLS STOP				  
			  SUB r3 , r2 ,#1       ; LOOP COUNT R3
LOOP              ADD r4 , r1 , r0  ;R4 to hold  value of f(n-1)+ f(n-2) 
                  MOV r0 ,r1
                  MOV r1 ,r4
                  MOV r2 , r4
                  SUB r3 ,#1 
				  CMP r3 ,#0
                  BNE LOOP					  
STOP		      B STOP  ; stop program
        endfunc
      end

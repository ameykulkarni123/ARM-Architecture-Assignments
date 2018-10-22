     AREA     appcode, CODE, READONLY
     export __main	 
	 ENTRY 
__main  function
	          MOV r0 , #5   ;first number
	          MOV r1 , #36  ;second number
              MOV r2 , #15 	  ;third number  			  
              CMP r0 , r1
              IT HI
              MOVHI r1 , r0 
			  CMP r1 , r2
			  IT HI 
			  MOVHI r2 , r1
			  MOV r3 , r2 
STOP		      B STOP  ; stop program
        endfunc
      end

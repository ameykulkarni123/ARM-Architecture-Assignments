     AREA     appcode, CODE, READONLY
     export __main	 
	 ENTRY 
__main  function
	          MOV r0 , #10	  ;value of a	
			  MOV r1 , #6     ;value of b
LOOP			  CMP r0 , r1
              IT EQ 
              BEQ STOP	
              ITE HI			  
			  SUBHI r0 , r0 , r1 			  
			  SUBLS r1 , r1 , r0
              B LOOP			  
STOP		      B STOP  ; stop program
        endfunc
      end


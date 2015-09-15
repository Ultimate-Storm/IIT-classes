MOVE.B  D1,D0   ;Move character from D1 into D0
MOVE.W  #248,D7 ;Initialize trap function for OUTCH
Trap    #14     ; output character to terminal

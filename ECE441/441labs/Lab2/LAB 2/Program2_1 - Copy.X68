*-----------------------------------------------------------
* Title      :  Program 2.1
* Written by :  Adam Sumner and Ryan Jenkins
* Date       :  1/27/2015
* Description:  Fills block of memory with any desired value
*-----------------------------------------------------------
    ORG    $00300C
START:                  
            MOVE.W  D0,-(A1)   ; Copy value in D0 to value located in memory
            CMP.W   A0,A1       ; Check if at end of memory block
            BGE     $300C     ; Go back to first instruction
            MOVE.B  #228,D7     ; Return to TUTOR
            TRAP    #14


    END    START        ; last line of source


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~

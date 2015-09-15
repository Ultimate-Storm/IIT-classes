*-------This is the modified code for procedure 3.2.12-----*
*-------It performes the same function as program 3.2 -----*
*-------But it also outputs the information from stack-----*
    ORG     $2000
    DC.B    'A BUS ERROR JUST OCCURRED!'

    ORG     $950

START:

        MOVE.L  #$2000,A5   ;set up buffer
        MOVE.L  #$201A,A6
        MOVE.B  #227,D7     ; Print string
        TRAP    #14
        MOVE.W  (A7)+,D0    ;move SSW to D0
        MOVE.W  #232,D7     ;convert to ASCII
        TRAP    #14
        MOVE.B  #$20,(A6)+  ; hex for space character
        MOVE.L  (A7)+,D0    ; move BA from stack to D0
        MOVE.W  #230,D7     ; convert 8 bytes hex to ASCII
        TRAP    #14
        MOVE.B  #$20, (A6)+ ; add another space
        MOVE.W  (A7)+, D0   ; get IR from stack
        MOVE.W  #232,D7     ;convert to ASCII
        TRAP    #14
        MOVE.W  #227,D7     ; print message
        TRAP    #14 
        MOVE.W  #228,D7     ; go to TUTOR
        TRAP    #14

        END     START




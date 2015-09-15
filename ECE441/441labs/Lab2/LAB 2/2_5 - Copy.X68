*-----------------------------------------------------------
* Title      : Program 2.5
* Written by : Adam Sumner and Ryan Jenkins
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $2000
START:                  ; first instruction of program

        MOVE.L A0,A2
        MOVE.L A2,A0
        CMP.W (A0)+,(A0)+
        BHI.S $2014
        SUBQ.L #2,A0
        CMP.L A0,A1
        BNE $2004
        MOVE.B #228,D7
        TRAP #14
        MOVE.L -(A0),D0
        SWAP.W D0
        MOVE.L D0,(A0)
        BRA $2002

    END    START        ; last line of source

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~

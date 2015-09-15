*-----------------------------------------------------------
* Title      : Program 2.6
* Written by : Adam Sumner and Ryan Jenkins
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $3000
START:                  ; first instruction of program

        CMP.W (A0),D0
        BCC $300C
        MOVE.W (A0),-(A0)
        ADDQ #4,A0
        CMPA.L A0,A1
        BCC $3000
        MOVE.W D0,-(A0)
        MOVE.B #228,D7
        TRAP #14

* Put variables and constants here

    END    START        ; last line of source

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~

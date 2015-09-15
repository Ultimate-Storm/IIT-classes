*-----------------------------------------------------------
* Title      : Program 2.4
* Written by : Adam Sumner and Ryan Jenkins
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program

        MOVE.L #$2000,A0
        MOVE.L #$3000,A1
        MOVEQ.L #-1,D1
        MOVEQ.L #0,D0
        MOVE.B (A0),D0
        CMPM.B (A0)+,(A1)+
        DBNE D0,$1012  ; DBNE if not equal, branch 
        BNE.S $101C
        NOT.B D1
        MOVE.B D1,$1100
        MOVE.B #228,D7
        TRAP #14

* Put variables and constants here

    END    START        ; last line of source

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~

*-----------------------------------------------------------
* Title      : Program 2.3
* Written by : Adam Sumner and Ryan Jenkins
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $950
START:                  ; first instruction of program

        MOVE.L #$1000,A5
        MOVE.L #$1018,A6
        MOVE.B #227,D7
        TRAP #14
        MOVE.B #228,D7
        TRAP #14

* Put variables and constants here

    END    START        ; last line of source

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~

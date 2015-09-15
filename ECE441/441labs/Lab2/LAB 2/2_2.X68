*-----------------------------------------------------------
* Title      : Program 2.2
* Written by : Adam Sumner and Ryan Jenkins
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $900
START:                  ; first instruction of program
        MOVE.B #$41,D0
        MOVE.B #248,D7
        TRAP #14
        MOVE.L #$0001,D5
        DBEQ D5,$910
        BRA $900

    END    START        ; last line of source

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~

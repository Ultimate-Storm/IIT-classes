*-----------------------------------------------------------
* Title      : Program 2.2
* Written by : Adam Sumner and Ryan Jenkins
* Date       : 1/27/2014
* Description: Outputs a character to the terminal
*-----------------------------------------------------------
    ORG    $900
START:                  ; first instruction of program
        MOVE.B #$41,D0  ; hex for value 'A'
        MOVE.B #248,D7  ; set up OUTCH function
        TRAP #14
        MOVE.L #$FFFF,D5; store large number in D5
        DBEQ D5,$910    
        BRA $900        ; infinite loop

    END    START        ; last line of source


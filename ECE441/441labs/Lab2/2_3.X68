*-----------------------------------------------------------
* Title      : Program 2.3
* Written by : Adam Sumner and Ryan Jenkins
* Date       : 1/27/2015
* Description: Outputs a String to the Terminal
*-----------------------------------------------------------
    ORG    $950
START:                  ; first instruction of program

        MOVE.L #$1000,A5 ;load starting address of string buffer  
        MOVE.L #$1018,A6 ; load ending address of buffer
        MOVE.B #227,D7   ; print string out 
        TRAP #14
        MOVE.B #228,D7   ; go to TUTOR
        TRAP #14

* Put variables and constants here

    END    START        ; last line of source


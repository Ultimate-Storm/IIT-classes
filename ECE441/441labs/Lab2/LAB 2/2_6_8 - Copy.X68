*-----------------------------------------------------------
* Title      : Program 2.6
* Written by : Adam Sumner and Ryan Jenkins
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $3000
START:                  ; first instruction of program

        LEA.L   $2100,A0
        LEA.L   $210E,A1
        CLR.L D0            ;clear register
        CLR.L D7            ;clear trap register
        LEA.L   $1000, A6   ;set up buffer for input
        LEA.L   $1000, A5   ; set up buffer for input
        MOVE.B #241,D7
        TRAP #14
        LEA.L   $1000,A5
        LEA.L   $1004,A6
        MOVE.B #226,D7
        TRAP #14
        
LOOP:   CMP.W (A0),D0
        BCC SKIP
        MOVE.W (A0),-(A0)
        ADDQ #4,A0
        CMPA.L A0,A1
        BCC LOOP
SKIP:   MOVE.W D0,-(A0)
        MOVE.B #228,D7
        TRAP #14

* Put variables and constants here

    END    START        ; last line of source

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~

*-----------------------------------------------------------
* Title      : Program 2.4
* Written by : Adam Sumner and Ryan Jenkins
* Date       : 1/27/2015
* Description: Pattern Match Program
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program

        MOVE.L #$2000,A0 ; load address of string 1
        MOVE.L #$3000,A1 ; load address of string 2
        MOVEQ.L #-1,D1   ; initialize to fail
        MOVEQ.L #0,D0    ; clear D0
        MOVE.B (A0),D0   ; Move first value to D0 to test
        CMPM.B (A0)+,(A1)+  ; compare the two string at the same location
        DBNE D0,$1012  ; Break if something is not equaivalent
        BNE.S $101C    ; if fail, jump over to end
        NOT.B D1       ; succeed, flip D1 to be a success
        MOVE.B D1,$1100 ; write success or failure to memory
        MOVE.B #228,D7  ; return to TUTOR
        TRAP #14

* Put variables and constants here

    END    START        ; last line of source


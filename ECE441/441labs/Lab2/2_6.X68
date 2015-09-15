*-----------------------------------------------------------
* Title      : Program 2.6
* Written by : Adam Sumner and Ryan Jenkins
* Date       : 1/27/2015
* Description: Adding a number to a Sorted List
*-----------------------------------------------------------
    ORG    $3000
START:                      ; first instruction of program

        CMP.W (A0),D0        
        BCC $300C           ; branch to MOVE.W D0, -(A0)
        MOVE.W (A0),-(A0)   ; move data to A0 down one word
        ADDQ #4,A0          ; move to next word
        CMPA.L A0,A1        ; done?
        BCC $3000           ; if carry clear, go back to top
        MOVE.W D0,-(A0)     ; insert new value
        MOVE.B #228,D7      ; exit to TUTOR
        TRAP #14

* Put variables and constants here

    END    START        ; last line of source


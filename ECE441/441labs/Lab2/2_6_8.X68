*-----------------------------------------------------------
* Title      : Program 2.6.8
* Written by : Adam Sumner and Ryan Jenkins
* Date       : 1/27/2015
* Description: Insert number into list given by user
*-----------------------------------------------------------
    ORG    $3000
START:                  ; first instruction of program

        LEA.L   $2100,A0    ; load initial addresses
        LEA.L   $210E,A1
        CLR.L D0            ;clear register
        CLR.L D7            ;clear trap register
        LEA.L   $1000, A6   ;set up buffer for input
        LEA.L   $1000, A5   ; set up buffer for input
        MOVE.B #241,D7      ; set up trap function for data entry
        TRAP #14
        LEA.L   $1000,A5    
        LEA.L   $1004,A6
        MOVE.B #226,D7
        TRAP #14
        
LOOP:   CMP.W (A0),D0
        BCC SKIP
        MOVE.W (A0),-(A0)
        ADDQ #4,A0      ; move to next word
        CMPA.L A0,A1    ; done?
        BCC LOOP        ; branch if carry clear
SKIP:   MOVE.W D0,-(A0) ; insert into list
        MOVE.B #228,D7  ; exit to TUTOR
        TRAP #14

* Put variables and constants here

    END    START        ; last line of source


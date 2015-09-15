*-----------------------------------------------------------
* Title      : Program 2.5
* Written by : Adam Sumner and Ryan Jenkins
* Date       : 1/27/2015
* Description: Bubble Sort
*-----------------------------------------------------------
    ORG    $2000
START:                      ; first instruction of program

        MOVE.L A0,A2        ; initialize
        MOVE.L A2,A0        ; reset to top of loop
        CMP.W (A0)+,(A0)+   ; check adjacent memory location
        BHI.S $2014         ; if higher, branch
        SUBQ.L #2,A0        ; move to next element
        CMP.L A0,A1         ; done?
        BNE $2004           ; if not, go back to CMP.W
        MOVE.B #228,D7      ; if done, exit TUTOR
        TRAP #14            
        MOVE.L -(A0),D0     ; Bubble it up the list
        SWAP.W D0           ; flip D0
        MOVE.L D0,(A0)      ; Store D0
        BRA $2002           ; next iteration

    END    START        ; last line of source


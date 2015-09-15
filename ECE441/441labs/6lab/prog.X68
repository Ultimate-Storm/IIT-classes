*Program Name:  LED Counter
*Written By:    Adam Sumner and Ryan Jenkins

        ORG $900

START   MOVEA.L #$06E000,A1     ;initialize the address
        MOVE.B  (A1),D0         ;Read the value
        MOVE.L  #$00000001,D1   ;initialize min
        MOVE.L  #$00000099,D2   ;initialize max
        MOVE.W  #$0000,D3       ;initialize delay
        MOVE.W  #$FFFF,D4       ;init delay max

CHECK   CMP.B   D2,D0           ;is counter at max?
        BEQ     DONE
        MOVE.B  D0,$06E000      ;Write to LED

WAIT    ADDI.W  #$0001,D3       ;inc delay timer
        CMP     D3,D4           ;is delay done?
        BEQ     COUNT
        BRA     WAIT            ;continue delay
COUNT   ABCD    D1,D0           ;inc counter by 1
        MOVE.W  #$0000,D3       ;reinitialize delay
        BRA     CHECK           ;continue looping

DONE    MOVE.B  D0,$06E000      ;Write last value to LED
        MOVE.B  #228,D7         ;exit to TUTOR
        TRAP    #14

END     START

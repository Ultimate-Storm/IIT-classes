*-----------------------------------------------------------
* Title      :  Program 3.1B
* Written by :  Adam Sumner and Ryan Jenkins    
* Date       :  2/3 2015
* Description:  Generates a Bus Error Exception
*-----------------------------------------------------------
    ORG    $2000
START:                      ; first instruction of program
        MOVE.B  $FFFFFF,D0  ; Move byte located in address
                            ; FFFFFF to D0
        BRA $2000           ; repeat previous step
        END START



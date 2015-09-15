*-----------------------------------------------------------
* Title      :  Program 3.3
* Written by :  Adam Sumner and Ryan Jenkins
* Date       :  2/3/2015
* Description:  Simulates a HALTED state
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program

    MOVE.B  $50000,D0   ;moves byte located at
                        ;address 0x500000 to D0
    BRA     $1000       ;repeat

    END    START        ; last line of source


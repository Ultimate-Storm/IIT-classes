*-----------------------------------------------------------
* Title      :  Program 3.1D
* Written by :  Adam Sumner and Ryan Jenkins
* Date       :  2/3/2015
* Description:  Priveledge Trap Error
*-----------------------------------------------------------
    ORG    $2000
START:                  ; first instruction of program

    ANDI.W  #$0700,SR   ; Bit wise AND 0x0700 with the 
                        ; Status register contents
    BRA     $2000       ; repeat above step

    END    START        ; last line of source


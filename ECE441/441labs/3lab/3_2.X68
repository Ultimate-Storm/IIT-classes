*-----------------------------------------------------------
* Title      : Program 3.2 Original
* Written by :  Adam Sumner and Ryan Jenkins
* Date       :  2/3/2015
* Description:  Implements an exception routine
*-----------------------------------------------------------
    ORG $2000               ; store string at address 0x2000    
    DC.B 'A BUS ERROR JUST OCCURRED!'
    ORG    $950
START:                      ; first instruction of program


        MOVE.L  #$2000,A5   ; set up address buffer
        MOVE.L  #$201A,A6
        MOVE.B  #227,D7     ; output string to terminal
        TRAP    #14
        MOVE.B  #228,D7     ; return to TUTOR
        TRAP    #14

    END    START        ; last line of source


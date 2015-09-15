*-----------------------------------------------------------
* Title      :  Program 3.1F
* Written by :  Adam Sumner and Ryan Jenkins
* Date       :  2/3/2015
* Description:  Produces CHCK Trap Error
*-----------------------------------------------------------
    ORG    $2000
START:                  ; first instruction of program

    CHK.W   D6,D7       ; compares D7 to zero and to D6
    BRA     $2002       ; repeat above step

    END    START        ; last line of source


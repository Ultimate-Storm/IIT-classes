*-----------------------------------------------------------
* Title      :  Program 3.1E
* Written by :  Adam Sumner and Ryan Jenkins
* Date       :  2/3/2015
* Description:  Produces Divide by 0 Error
*-----------------------------------------------------------
    ORG    $2000
START:                  ; first instruction of program

    DIVU D1,D2          ; divide D2 by D1
    BRA  $2002          ; repeat above step

    END    START        ; last line of source


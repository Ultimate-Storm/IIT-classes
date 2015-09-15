*-----------------------------------------------------------
* Title      :  Program 3.1A
* Written by :  Adam Sumner and Ryan Jenkins
* Date       :  2/3/2015
* Description:  Program that invokes exception processing
*-----------------------------------------------------------
    ORG    $2000
START:  MOVE.W  D0,A1       ;move contents of D0 into memory address of A1
        MOVE.W  D1,(A1)+    ;move contents of D1 into memory address of A1
                            ;then post inc the address to the next word
        BRA     $2000
 END    START        ; last line of source


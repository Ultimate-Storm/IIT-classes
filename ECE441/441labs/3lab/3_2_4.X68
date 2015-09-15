*-----------------------------------------------------------
* Title      :  Program 3.2.4
* Written by :  Adam Sumner and Ryan Jenkins
* Date       :  2/3/2015
* Description:  Produces Bus error
*-----------------------------------------------------------

ORG $1000

START:
        MOVE.B  $50000,D0   ;moves byte located at
                            ;address 0x50000 to D0
        BRA     $1000       ;repeat

        END     START

*-----------------------------------------------------------
* Title      :  Sample Program 4-1
* Written by :  Adam Sumner and Ryan Jenkins
* Date       :  2/10/2015
* Description:  sends IT WORKS repeatedly to the terminal
*-----------------------------------------------------------
        ORG    $900     ;store output at address $900
        
MSGSTR  DC.B    'IT WORKS!' ;output
MSGEND  DC.B    1


        ORG     $1000   ;start program at $1000    
START:                  

       
        
LOOP:   LEA     MSGSTR,A5   ;load message
        LEA     MSGEND,A6
        MOVE.B  #243,D7     ;output to terminal
        TRAP    #14     
        MOVE.B  #241,D7     ;wait for input
        TRAP    #14
        MOVE.B  #227,D7     ;output the input
        TRAP    #14
        BRA     LOOP        ;restart
    


    END    START        ; last line of source

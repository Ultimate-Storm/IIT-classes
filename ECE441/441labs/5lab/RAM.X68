*-----------------------------------------------------------
* Title      :  Memory Test 
* Written by :  Adam Sumner and Ryan Jenkins
* Date       :  3/4/2015
* Description:  Tests the student's RAM to verify if it works 
*-----------------------------------------------------------
    ORG     $800

MSGPASS     DC.B    'YOUR MEMORY IS GOOD!'  
ENDPASS     DC.B    1

MSGFAIL     DC.B    'YOUR MEMORY FAILS AT ADDRESS: '          
ENDFAIL     DC.B    1    

READ        DC.B    'Number Read: '
READEND     DC.B    1

WRITE       DC.B    'Number Written: '
WRITEEND    DC.B    1

    ORG     $1000
START:                 

            MOVE.L  #$082000,A5 ;load starting address
            MOVE.L  #$0827FF,A6 ;load finishing address
            
LOOP:       CMPA.L   A5,A6      ;finished?
            BLT     TESTSETUP        
            MOVE.B  #$AA,(A5)+  ;fill up memory
            BRA     LOOP        ;repeat

TESTSETUP:  MOVE.L  #$082000,A5 ;go to original address
            
TEST:       
            CMPI.B   #$AA,(A5)  ;test byte 
            BEQ     PASS        ;if equal check succeeds!
            BRA     FAILAA        ;if not check fails!

PASS:       
            MOVE.B  #$55,(A5)+  ;replace AA with 55 and go to next location
            CMPA.L  A5,A6
            BLT     NEXTSTEPSETUP
            BRA     TEST
            
NEXTSTEPSETUP:
            MOVE.L  #$082000,A5 ;go to starting address again
            
NEXTSTEP:
            CMPI.B  #$55,(A5)   ;test byte
            BEQ     SECONDPASS
            BRA     FAIL55
            
SECONDPASS:
            MOVE.B  #$AA,(A5)+  ;write AA back into memory block
            CMPA.L  A5,A6
            BLT     OUTPUT
            BRA     NEXTSTEP
            

FAILAA:     MOVE.L  A5,D0       ;get address of failure
            LEA     MSGFAIL,A5  ; output fail
            LEA     ENDFAIL,A6
            MOVE.B  #243,D7
            TRAP    #14
            MOVE.L  D0,A4       ;move back to address register
            MOVE.B  #231,D7     ;convert D0 to ASCII
            TRAP    #14
            MOVE.L  D0,$2000   ;move ascii read value to buffer for output
            LEA     $2000,A5   ;output address
            LEA     $2004,A6
            MOVE.B  #243,D7
            TRAP    #14
            LEA     READ,A5
            LEA     READEND,A6
            MOVE.B  #243,D7     ;output number read message
            TRAP    #14
            MOVE.B  (A4),D0     ;get number read
            MOVE.B  #233,D7     ; convert number read to ascii
            TRAP    #14         
            MOVE.W  D0,$2000
            LEA     $2000,A5
            LEA     $2003,A6
            MOVE.B  #243,D7     ;output number read
            TRAP    #14
            LEA     WRITE,A5
            LEA     WRITEEND,A6
            MOVE.B  #243,D7     ;output number written
            TRAP    #14
            MOVE.W  #$4141,$2200
            LEA     $2200,A5
            LEA     $2203,A6
            MOVE.B  #243,D7
            TRAP    #14
            BRA     EXIT


FAIL55:     MOVE.L  A5,D0       ;get address of failure
            LEA     MSGFAIL,A5  ; output fail
            LEA     ENDFAIL,A6
            MOVE.B  #243,D7
            TRAP    #14
            MOVE.L  D0,A4       ;move back to address register
            MOVE.B  #231,D7     ;convert D0 to ASCII
            TRAP    #14
            MOVE.L  D0,$2000   ;move ascii read value to buffer for output
            LEA     $2000,A5   ;output address
            LEA     $2004,A6
            MOVE.B  #243,D7
            TRAP    #14
            LEA     READ,A5
            LEA     READEND,A6
            MOVE.B  #243,D7     ;output number read message
            TRAP    #14
            MOVE.B  (A4),D0     ;get number read
            MOVE.B  #233,D7     ; convert number read to ascii
            TRAP    #14         
            MOVE.W  D0,$2000
            LEA     $2000,A5
            LEA     $2003,A6
            MOVE.B  #243,D7     ;output number read
            TRAP    #14
            LEA     WRITE,A5
            LEA     WRITEEND,A6
            MOVE.B  #243,D7     ;output number written
            TRAP    #14
            MOVE.W  #$3535,$2200
            LEA     $2200,A5
            LEA     $2203,A6
            MOVE.B  #243,D7
            TRAP    #14
            BRA     EXIT


OUTPUT:     LEA     MSGPASS,A5
            LEA     ENDPASS,A6
            MOVE.B  #243,D7     ;memory pass output!!
            TRAP    #14         
EXIT:       MOVE.B  #228,D7     ;exit to TUTOR
            TRAP    #14
            
        END     START        


*-----------------------------------------------------------
* Title      : Lab 7 Routine
* Written by : Adam Sumner and Ryan Jenkins
* Date       : 4/14/2015
* Description: This program enables the I/O fuctionality of
*              the PIA 
*-----------------------------------------------------------
    ORG    $064
    
     DC.L ISR       ;pointer to subroutine    
CRA  EQU $52003
CRB  EQU $52007
DDRA EQU $52001
DDRB EQU $52005
PDRA EQU $52001
PDRB EQU $52005
BUFFER	DC.B 1
    ORG     $900
                 

        BCLR.B  #2,CRA      ;select DDRA
        BCLR.B  #2,CRB      ;select DDRB
        
        MOVE.B  #00,DDRA    ;set PA0 - PA7 to input
        MOVE.B  #$FF,DDRB    ;set PB0 - PB7 to output
        
        BSET.B  #0,CRA      ;enable interrupts
        BSET.B  #3,CRB      ;pulse mode
        BCLR.B  #4,CRB      ;high to low transition
        BSET.B  #5,CRB      ;output line
        
        BSET.B  #2,CRA      ;select PDRA
        BSET.B  #2,CRB      ;select PDRB
        
        MOVE.B  #$07,CRA
        MOVE.B  #$2C,CRB
        ANDI.W  #$F8FF,SR   ;set interrupt to 0

LOOP:
		LEA		BUFFER,A5
		LEA		BUFFER,A6
        MOVE.B  #241,D7     ;trap input
        TRAP    #14
        MOVE.B  (A5),PDRB
        BRA     LOOP

    

    ORG     $1800
ISR     MOVEM.L D0-D7/A0-A6,-(A7)   ;store registers
        MOVE.B  PDRA,D0             ;get data from PIA
        MOVE.B  #248,D7             ;output char
        TRAP    #14
        MOVEM.L (A7)+,D0-D7/A0-A6   ;restore registers
        RTE                         ;end exception   


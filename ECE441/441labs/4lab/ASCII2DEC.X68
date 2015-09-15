*-----------------------------------------------------------
* Title      :  Program B
* Written by :  Adam Sumner and Ryan Jenkins
* Date       :  2/10/2015
* Description:  Performs a series of bit manipulations
*               and outputs it to the terminal and Sanper
*               user display
*-----------------------------------------------------------
  
*   Stores string output at $800
*   repeatedly prompts for input 
*   until the user types . to exit


        ORG    $800
    
PRMPT           DC.B    'Please input a number from 
                0-255 or type ',$22,'.',$22,' to exit: '
ENDPRMPT        DC.B    1

TWOPRMPT          DC.B    'Your formatted number is: '
TWOENDPRMPT       DC.B    1





    ORG    $1000
START:
        CLR.L   D0
        CLR.L   D1
        CLR.L   D2          ;holds binary digit
        CLR.L   D3
*Output display text
        LEA     PRMPT,A5
        LEA     ENDPRMPT,A6
        MOVE.B  #243,D7
        TRAP    #14
*Prompt input for number
        LEA     $3000,A5    ;set up buffer
        LEA     $3000,A6    
        MOVE.B  #241, D7    ;set up trap call to input string
        TRAP    #14
        
*Convert from ASCII to decimal
        MOVEA.L A5,A4       ;load beginning of string to A4
                            ;to save starting space of string
LOOP:   CMPA    A6,A4       ;A4 >A6?
        BGE     NEXT        ;if done go to next
        SUB.B   #$30,(A4)+  ;convert value then go to next address
        BRA     LOOP
NEXT:
        MOVE.B  (A5),D6     ;exiting on typing of '.'
        MOVE.B  #$FE,D5     ;character
        CMP     D5,D6
        BEQ     EXIT
*Convert from decimal to binary
        MOVEA.L A6,A4       ;ending of decimal number
        MOVE.B  #1,D0       ;move multiplier to D0
 
    
DtoB:   SUBA    #1,A4       ;decrement by a byte
        CMPA    A5,A4       ;A4<A5?
        BLT     DONE
        MOVE.B  (A4),D1
        MULU    D0,D1       ;multiply D1 byte by its ten's place
        ADD.W   D1,D2       ;Add 10's place value to total
        CLR.L   D1          ;Clear D1 for next byte
        MULU    #10,D0      ;multiply D0 to next ten's place
        BRA     DtoB
DONE:              
      
      
      
*--------------Bit Manipulation Time-----------------------*
*---Decimal value is stored in D2-----*
*D0 is the output
*D2 holds binary value
*D1 is temp manipulation
*D3 is temp manipulation
        CLR.L   D3      ;clear temp registers
        CLR.L   D1
        CLR.L   D0      ;clear output
        
OUT_1:  MOVE.L  D2,D3   ;move value for temp manipulation   
        ROR     #6,D3   ;get IN_7 to IN_1 position
        MOVE.L  D2,D1   ;get copy of value to D1
        AND     D1,D3   ;and all bits store in D3
        NOT     D3      ;complement for nand gate
        ANDI    #$2,D3  ;only receive IN_1 bit
        OR      D3,D0   ; store in the ouput register

OUT_0:  *---Depends on OUT_1---*
        *---D3 holds OUT_1-----*
        ROR     #1,D3   ;move IN_1 bit to IN_0 location
        MOVE.L  D2,D1   ;copy original value for manipulation
        EOR     D1,D3   ;exclusive or the two
        NOT     D3      ;complement it
        ANDI    #$1,D3  ;single out the bit
        OR      D3,D0   ;store result in output

OUT_2:  
        MOVE.L  D2,D1   ;set up temp registers
        MOVE.L  D2,D3     
        ROR     #3,D1   ;get bit 5 to 2's place
        ROL     #2,D3   ;get bit 0 to 2's place
        EOR     D1,D3   ;store exclusive-or in D3
        ANDI    #$4,D3  ;single out bit
        OR      D3,D0   ;add to output
        
        *---D3 holds value used in OUT_6 computation---*
OUT_6:
        MOVE.L  D2,D1   ;set up temp register
        ROL     #4,D3   ;move D3 bit to OUT_6 position
        AND     D3,D1   ;And the bits
        ANDI    #$40,D1 ;isolate bit
        OR      D1,D0   ;addto output
        
OUT_3:  *---3 is same as 6---*
        ROR     #3,D1   ;move to 3 position
        OR      D1,D0   ;add to output

OUT_5:  *---Complement of 6/3---*

        ROL     #2,D1   ;move bit to 5 position
        NOT     D1      ;complement it
        ANDI    #$20,D1 ;single out the bit
        OR      D1,D0   ;add to output  
OUT_4:

        MOVE.L  D2,D1   ;set up temp registers
        MOVE.L  D2,D3    
        ROL     #2,D1   ;move IN_2 to 4th bit
        ROL     #1,D3   ;move IN_3 to 4th bit
        AND     D1,D3   ;and the bits
        ANDI    #$10,D3 ;isolate bit
        OR      D3,D0   ;add to output
        
OUT_7:
        MOVE.L  D2,D1   ;set up temp register
        ROL     #3,D1   ;move bit to 7th bit
        NOT     D1      ;complement it
        ANDI    #$80,D1 ;isolate bit
        OR      D1,D0   ;add to output
      
      
*------Binary to BCD Converter------*

        CLR D1
        CLR D3
        CLR D4
        
        MOVE.L  D0,D1   ;copy output to D1
        DIVU    #100,D1 ;get 100's place byte
        MOVE.B  D1,D5   ;store it in D5
        CLR.W   D1      ;clear quotient
        SWAP    D1      ;get remainder
        DIVU    #10,D1  ;get 10's place byte
        MOVE.B  D1,D4   ;store it in D4
        SWAP    D1      ;get 1's place byte
        MOVE.B  D1,D3   ;store it in D3
 *-----Convert to ASCII/output to terminal-------*     
        MOVE.B  D5,$900
        MOVE.B  D4,$901
        MOVE.B  D3,$902
        LEA     TWOPRMPT,A5
        LEA     TWOENDPRMPT,A6
        MOVE.B  #243,D7
        TRAP    #14
        MOVEA.L #$900,A6
        MOVEA.L #$900,A5
        ADD.B   #$30,(A6)+
        ADD.B   #$30,(A6)+
        ADD.B   #$30,(A6)+
        MOVE.B  #227,D7
        TRAP    #14
*----Output to User Data Display---*
    MOVE.B  D5,$90000   ;for data display
    ROL     #4,D4
    ADD.W   D4,D3
    MOVE.B  D3,$90001
       

    BRA     START
       
       
EXIT:       MOVE.B  #228,D7
            TRAP    #14
    END    START        ; last line of source


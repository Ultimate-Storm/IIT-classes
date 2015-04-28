*-----------------------------------------------------------
* Title      :  Monitor Project
* Written by :  Adam Sumner 
* Date       :  4/28/2015
* Description:  Monitor Final Project
*-----------------------------------------------------------


*---------------DISCLAIMER!-------------------------*
*Subroutines are not as optimized as they should be!*
*Things such as checking for spaces, getting addresses, etc. *
*can easily be their own subroutines to save code space!*
*Luckily code size is not a huge concern*
*This is why there are no plans to optimize in the future*



    ORG    $3000
    
BUFFER        DS.B      80              ;space for command storage 
OUTPUTBUFF    DS.B      8               ;to output numbers easily
PROMPT        DC.B      'MONITOR441>'   ;prompt definition

*Help text*
HTXT          DC.B      'List of Commands:'
HTXT1         DC.B      'MDSP <address1> <address2> - Memory Display: Outputs the address and memory' 
HTXT1A        DC.B      'contents from <address1> to <address2> amd from <address1> to' 
HTXT1B        DC.B      '<address2 + 16bytes>'
HTXT2         DC.B      'HXDEC <num> - Conversion: Converts a hexadecimal number to a decimal number'
HTXT3         DC.B      'SORTW <option> <address1> <address2> - Sort: Sorts a block of memory.'
HTXT3A        DC.B      '<option> specifies the order in which the list is sorted:'
HTXT3B        DC.B      ';A - Ascending Order'
HTXT3C        DC.B      ';D - Descending Order'
HTXT3D        DC.B      '-(default) - Descending Order'
HTXT3E        DC.B      'Sorts block of memory from <address1> to <address2>'
HTXT4         DC.B      'MM <option> <address> - Memory Modify: Display memory and, as required,'
HTXT4A        DC.B      'modify data or enter new data. <option> specifies the number of bytes'
HTXT4B        DC.B      'displayed for each address:'
HTXT4C        DC.B      '-(default) - Displays one byte'
HTXT4D        DC.B      ';W - Displays one word(2 bytes)'
HTXT4E        DC.B      ';L - Displays one long word(4 bytes)'
HTXT5         DC.B      'MS <data> <address> - Memory Set: Alters memory by setting <data> into' 
HTXT5A        DC.B      '<address>'
HTXT6         DC.B      'BF <data> <address1> <address2> - Block Fill: Fills memory starting at' 
HTXT6A        DC.B      '<address1> to <address2>. Both must be even addresses. This command only'
HTXT6B        DC.B      'works with a word-sized <data> pattern'
HTXT7         DC.B      'BMOV <address1> <address2> <address3> <address4> - Block Move: Moves' 
HTXT7A        DC.B      'a duplicate block of memory from <address1> to <address2> into the block'
HTXT7B        DC.B      '<address3> to <address4>'
HTXT8         DC.B      'BTST <data> <address1> <address2> - Block Test: Tests a block of memory'
HTXT8A        DC.B      'from <address1> to <address2> for <data>'
HTXT9         DC.B      'BSCH <data> <address1> <address2> - Block Search: Searches for <data> in'
HTXT9A        DC.B      'in memory block from <address1> to <address2>'
HTXT10        DC.B      'GO <address> - Execute Program: Executes program at <address>'
HTXT11        DC.B      'DF - Display Formatted Registers: Displays all registers'
HTXT12        DC.B      'HELP - Help: Displays all available commands and their description'
HTXT13        DC.B      'ECHO <data> - Echo: Displays <data> to the terminal'
HTXT14        DC.B      '.<Register Type><Register Number> <data>- Modify Register: Modifies the'
HTXT15        DC.B      'contents of register <Register Type><Register Number> to <data>'

*Error Message*
ERROR         DC.B      'ERROR: TRY COMMAND AGAIN WITH CORRECT SYNTAX'
ERROR1        DC.B      'ERROR: UNKOWN COMMAND'
*Space*
SPACE         DC.B      ' '

*Debugger Print Statement*
DEBUG         DC.B      'WIN'      

*BTST Text*
BTST1         DC.B      'Number written was: '
BTST2         DC.B      'Number read was: '
BTST3         DC.B      'Block Test PASSES!'
BTST4         DC.B      'FAILURE!!!!'  
BTST5         DC.B      'Error Occurred at address: '      

*BSCH Text*
BSCH1         DC.B      'Data: '
BSCH2         DC.B      'Found at address: '
BSCH3         DC.B      'Pattern not found'

*DF Text*
RD0            DC.B      'D0: '
RD1            DC.B      'D1: '
RD2            DC.B      'D2: '
RD3            DC.B      'D3: '
RD4            DC.B      'D4: '
RD5            DC.B      'D5: '
RD6            DC.B      'D6: '
RD7            DC.B      'D7: '

RA0            DC.B      'A0: '
RA1            DC.B      'A1: '
RA2            DC.B      'A2: '
RA3            DC.B      'A3: '
RA4            DC.B      'A4: '
RA5            DC.B      'A5: '
RA6            DC.B      'A6: '

RSS            DC.B      'SS/A7: '
RUS            DC.B      'US: '
RPC            DC.B      'PC: '
RSR            DC.B      'SR: '

*Exception Messages*
BERR_TEXT      DC.B 'A Bus Error Occured! :(',0
AERR_TEXT      DC.B 'An Address Error Occured! :(',0
IERR_TEXT      DC.B 'An Illegal Instruction Error Occured! :(',0
PERR_TEXT      DC.B 'A Privilege Error Occured! :(',0
ZERR_TEXT      DC.B 'A Divide by Zero Error Occured! :(',0
ALERR_TEXT      DC.B 'An A Line Error Occured! :(',0
FLERR_TEXT      DC.B 'An F Line Error Occured! :(',0
CHKERR_TEXT      DC.B 'A Check Error Occured! :(',0

SSW            DC.B 'SSW: ',0
BA             DC.B 'BA: ',0
IR             DC.B 'IR: ',0

*Color definition for Font*
FONT        EQU     $01090000  
GREEN       EQU     $0000FF00

    ORG     $1000
START:  
        MOVEM.L D0-D2/A1,-(SP)
        *Makes it look like a REAL terminal*
        MOVE.L  #GREEN,D1
        MOVE.L  #FONT,D2
        MOVE.B  #21,D0
        TRAP    #15
        CLR.L   D1
        CLR.L   D2
        CLR.B   D0
        *Load custom exceptions*
        LEA BERR,A1 ;init exception handlers
        MOVE.L A1,$8
        LEA AERR,A1
        MOVE.L A1,$C
        LEA IERR,A1
        MOVE.L A1,$10
        LEA ZERR,A1
        MOVE.L A1,$14
        LEA CHKERR,A1
        MOVE.L  A1,$18
        LEA PERR,A1
        MOVE.L A1,$20
        LEA ALERR,A1
        MOVE.L A1,$28
        LEA FLERR,A1
        MOVE.L A1,$2C
        MOVEM.L (SP)+,D0-D2/A1  ;restore any preset values

*--------------------------------------------------------------------------------------*
SHELL:       
            PEA     *           ;save PC on Stack for DF
            ADD.L   #4,SP       ;get original value of stack pointer
            MOVE.L  SP,-8(SP)   ;save it
            ADD.L   #-8,SP      ;update Stack position
            MOVE    SR,-(SP)    ;save Status register for use with DF
            MOVE.L  A6,-(SP)    ;temp save
            MOVE    USP,A6      ;for use with DF command
            MOVE.L  A6,-(SP)    ;store USP to STACK
            ADD.L   #4,SP       
            MOVE.L  (SP),A6    ;restore original value
            MOVE.L  -(SP),4(SP)  ;move correct value to correct stack position
            ADD.L   #4,SP       ;point stack to CORRECT PLACE
            

            MOVEM.L D0-D7/A0-A6,-(SP)  ;save initial values of registers
            MOVEM.L D0-D7/A0-A6,-(SP)  ;unorthodox implementation to save registers when using DF command
             
              
            LEA  PROMPT,A1      ;Load message            
            MOVE.W  #11,D1      ;load n bytes
            MOVE.B  #1,D0       ;set up trap call
            TRAP    #15
            LEA     BUFFER,A1   ;set up storage for command
            MOVE.B  #2,D0       ;load input trap call
            TRAP    #15
            CMP.B   #$48,(A1)   ;check for help/hxdc
            BEQ     HELPORHXDC
            CMP.B   #$4D,(A1)   ;check for memory command
            BEQ     MEMTEST
            CMP.B   #$47,(A1)   ;check for go
            BEQ     GOTST
            CMP.B   #$44,(A1)   ;check for df
            BEQ     DFTST
            CMP.B   #$42,(A1)   ;check for blck command
            BEQ     BLCKTEST
            CMP.B   #$53,(A1)   ;check for sort command
            BEQ     SORTTEST
            CMP.B   #$45,(A1)   ;check for echo command
            BEQ     ECHOTEST
            CMP.B   #$2E,(A1)   ;check for modify register command
            BEQ     MODIFYREGTEST
            BRA     UNKNOWNCMD
RESTORE:    MOVEM.L (SP)+,D0-D7/A0-A6
            MOVEM.L (SP)+,D0-D7/A0-A6 ;double restore because of DF hack workaround
            ADD.L   #4,SP       ;account for USP, it'll fix itself (it shouldn't be used)
                                ;EASY68k simulator starts in supervisor mode
            MOVE    (SP)+,SR
            MOVE.L  (SP)+,D0    ;save stack cuz it'll get destroyed
            ADD.L   #4,SP       ;get rid of PC, itll fix itself
            MOVE.L  D0,SP
            CLR.L   D0          ;no longer needed

            BRA     SHELL
*--------------------------------------------------------------------------------------*

ECHOTEST:   ADD.L   #1,A1
            CMP.B   #$43,(A1)+   ;C?
            BNE     UNKNOWNCMD
            CMP.B   #$48,(A1)+   ;H?
            BNE     UNKNOWNCMD
            CMP.B   #$4F,(A1)+   ;O?
            BNE     UNKNOWNCMD
            CMP.B   #$20,(A1)+   ;SPACE?
            BEQ     ECHO
            BRA     ERRORSR
*--------------------------------------------------------------------------------------*


*--------------------------------------------------------------------------------------*

BLCKTEST:   ADD.L   #1,A1
            CMP.B   #$46,(A1)   ;BF?
            BEQ     BFTEST
            CMP.B   #$4D,(A1)   ;BMOV?
            BEQ     BMOVTEST
            CMP.B   #$54,(A1)   ;BTST?
            BEQ     BTSTTEST
            CMP.B   #$53,(A1)   ;BSCH?
            BEQ     BSCHTEST
            BRA     UNKNOWNCMD
*--------------------------------------------------------------------------------------*

BSCHTEST:   ADD.L   #1,A1
            CMP.B   #$43,(A1)
            BNE     UNKNOWNCMD
            ADD.L   #1,A1
            CMP.B   #$48,(A1)
            BNE     UNKNOWNCMD
            ADD.L   #1,A1
            CMP.B   #$20,(A1)
            BNE     ERRORSR
            BRA     BSCH
                      
*--------------------------------------------------------------------------------------*

BTSTTEST:   
            ADD.L   #1,A1
            CMP.B   #$53,(A1)
            BNE     UNKNOWNCMD
            ADD.L   #1,A1
            CMP.B   #$54,(A1)
            BNE     UNKNOWNCMD
            ADD.L   #1,A1
            CMP.B   #$20,(A1)
            BNE     ERRORSR
            BRA     BTST

*--------------------------------------------------------------------------------------*

BMOVTEST:   ADD.L   #1,A1
            CMP.B   #$4F,(A1)
            BNE     UNKNOWNCMD
            ADD.L   #1,A1
            CMP.B   #$56,(A1)
            BNE     UNKNOWNCMD
            ADD.L   #1,A1
            CMP.B   #$20,(A1)
            BNE     ERRORSR
            BRA     BMOV
*--------------------------------------------------------------------------------------*
BFTEST:     ADD.L   #1,A1
            CMP.B   #$20,(A1)
            BNE     ERRORSR
            BRA     BF
*--------------------------------------------------------------------------------------*

DFTST:      ADD.L   #1,A1
            CMP.B   #$46,(A1)
            BNE     UNKNOWNCMD
            ADD.L   #1,A1
            CMP.B   #$00,(A1)
            BNE     ERRORSR
            BRA     DF
*--------------------------------------------------------------------------------------*

SORTTEST:    ADD.L   #1,A1
            CMP.B   #$4F,(A1)   ;O?
            BNE     UNKNOWNCMD
             ADD.L   #1,A1
            CMP.B   #$52,(A1)   ;R?
            BNE     UNKNOWNCMD
            ADD.L   #1,A1
            CMP.B   #$54,(A1)   ;T?
            BNE     UNKNOWNCMD
            ADD.L   #1,A1
            CMP.B   #$57,(A1)   ;W?
            BNE     UNKNOWNCMD
            ADD.L   #1,A1
            CMP.B   #$20,(A1)
            BNE     ERRORSR

            BRA     SORTW
*--------------------------------------------------------------------------------------*

GOTST:      ADD.L   #1,A1
            CMP.B   #$4F,(A1)
            BNE     UNKNOWNCMD
            ADD.L   #1,A1
            CMP.B   #$20,(A1)+
            BNE     ERRORSR
            BRA     GO
*--------------------------------------------------------------------------------------*

HELPORHXDC: ADD.L   #1,A1
            CMP.B   #$45,(A1)   ;is it help?
            BEQ     HELPTST
            CMP.B   #$58,(A1)   ;or is it hxdc
            BEQ     HXDCTEST
            BRA     UNKNOWNCMD     
*--------------------------------------------------------------------------------------*

HELPTST:   
           ADD.L   #1,A1   ; check next char
           CMP.B    #$4C,(A1) ;check for L
           BNE      UNKNOWNCMD
           ADD.L   #1,A1
           CMP.B    #$50,(A1)   ;check for P
           BNE      UNKNOWNCMD
           ADD.L   #1,A1   ;check for anything else
           CMP.B    #$00,(A1)
           BNE      ERRORSR
           BRA      HELP
            

 
*--------------------------------------------------------------------------------------*
            
MEMTEST:    ADD.L   #1,A1
            CMP.B   #$53,(A1)
            BEQ     MSSPCTEST
            CMP.B   #$44,(A1)
            BEQ     MDSPCTEST
            CMP.B   #$4D,(A1)
            BEQ     MMSPCTEST
            BRA     UNKNOWNCMD
            
MSSPCTEST   ADD.L   #1,A1
            CMP.B   #$20,(A1)
            BEQ     MEMSET
            BRA     ERRORSR
            
MDSPCTEST:  
            ADD.L   #1,A1
            CMP.B   #$53,(A1)
            BNE     ERRORSR
            ADD.L   #1,A1
            CMP.B   #$50,(A1)
            BNE     UNKNOWNCMD
            ADD.L   #1,A1
            CMP.B   #$20,(A1)
            BEQ     MEMDISP          
            BRA     ERRORSR
           
MMSPCTEST:  ADD.L   #1,A1
            CMP.B   #$20,(A1)
            BEQ     MM          
            BRA     ERRORSR
*--------------------------------------------------------------------------------------*
HXDCTEST:   
            ADD.L   #1,A1
            CMP.B   #$44,(A1)
            BNE    UNKNOWNCMD
            ADD.L   #1,A1
            CMP.B   #$45,(A1)
            BNE     UNKNOWNCMD
            ADD.L   #1,A1
            CMP.B   #$43,(A1)
            BNE     UNKNOWNCMD
            ADD.L   #1,A1
            CMP.B   #$20,(A1)
            BNE     ERRORSR
            BRA     HXDC
*--------------------------------------------------------------------------------------*
MODIFYREGTEST:
            ADD.L   #1,A1
            CMP.B   #$44,(A1)
            BEQ     MRD
            CMP.B   #$41,(A1)
            BEQ     MRA
            BRA     UNKNOWNCMD
            
*----------------------------USER DEFINED COMMANDS---------------------------------*
*--------------------------------------------------------------------------------------*
ECHO: *What terminal DOESN'T have echo?*

        MOVE.L  A1,A2   ;setup to find end of string
EEND:   CMP.B   #$00,(A2)+
        BEQ     EFOUND
        BRA     EEND
EFOUND:
        SUB.L   #1,A2   ;off by one
        SUB.L   A1,A2   ;find out how many bytes
        MOVE.L  A2,D1   ;place it for trap function
        MOVE.L  #0,D0
        TRAP    #15
        
        BRA RESTORE
*--------------------------------------------------------------------------------------*
MODIFYREGS:

MRD:
        ADD.L   #1,A1   ;inc
        CMP.B   #$30,(A1)
        BEQ     MRD0
        CMP.B   #$31,(A1)
        BEQ     MRD1
        CMP.B   #$32,(A1)
        BEQ     MRD2
        CMP.B   #$33,(A1)
        BEQ     MRD3
        CMP.B   #$34,(A1)
        BEQ     MRD4
        CMP.B   #$35,(A1)
        BEQ     MRD5
        CMP.B   #$36,(A1)
        BEQ     MRD6
        CMP.B   #$37,(A1)
        BEQ     MRD7
        BRA     ERRORSR

MRA:
        ADD.L   #1,A1   ;inc
        CMP.B   #$30,(A1)
        BEQ     MRA0
        CMP.B   #$31,(A1)
        BEQ     MRA1
        CMP.B   #$32,(A1)
        BEQ     MRA2
        CMP.B   #$33,(A1)
        BEQ     MRA3
        CMP.B   #$34,(A1)
        BEQ     MRA4
        CMP.B   #$35,(A1)
        BEQ     MRA5
        CMP.B   #$36,(A1)
        BEQ     MRA6
        BRA     ERRORSR
             


        
        
MRD0: 
        ADD.L   #1,A1
        CMP.B   #$20,(A1)+
        BNE     ERRORSR
        MOVE.L  A1,A2
        MOVE.L  A2,A3
        JSR     MRDFINDDATA
        SUB.L   #1,A3
        JSR     ASCII_ADDRESS   ;convert data to hex
        MOVE.L  D5,-(SP)        ;store it temporarily
        ADD.L   #4,SP       ;dont lose data
        MOVEM.L (SP)+,D0-D7/A0-A6
        MOVEM.L (SP)+,D0-D7/A0-A6 ;double restore because of DF hack workaround
        ADD.L   #4,SP       ;account for USP, it'll fix itself (it shouldn't be used)
                                ;EASY68k simulator starts in supervisor mode
        MOVE    (SP)+,SR
        ADD.L   #4,SP       ;skip saved stack
        SUB.L   #134,SP     ;find data again
        MOVE.L  (SP),D0
        ADD.L   #138,SP     ;go back to original spot
        BRA     SHELL
             
MRD1:
        ADD.L   #1,A1
        CMP.B   #$20,(A1)+
        BNE     ERRORSR
        MOVE.L  A1,A2
        MOVE.L  A2,A3
        JSR     MRDFINDDATA
        SUB.L   #1,A3
        JSR     ASCII_ADDRESS   ;convert data to hex
        MOVE.L  D5,-(SP)        ;store it temporarily
        ADD.L   #4,SP       ;dont lose data
        MOVEM.L (SP)+,D0-D7/A0-A6
        MOVEM.L (SP)+,D0-D7/A0-A6 ;double restore because of DF hack workaround
        ADD.L   #4,SP       ;account for USP, it'll fix itself (it shouldn't be used)
                                ;EASY68k simulator starts in supervisor mode
        MOVE    (SP)+,SR
        ADD.L   #4,SP       ;skip saved stack
        SUB.L   #134,SP     ;find data again
        MOVE.L  (SP),D1
        ADD.L   #138,SP     ;go back to original spot
        BRA     SHELL

MRD2:
        ADD.L   #1,A1
        CMP.B   #$20,(A1)+
        BNE     ERRORSR
        MOVE.L  A1,A2
        MOVE.L  A2,A3
        JSR     MRDFINDDATA
        SUB.L   #1,A3
        JSR     ASCII_ADDRESS   ;convert data to hex
        MOVE.L  D5,-(SP)        ;store it temporarily
        ADD.L   #4,SP       ;dont lose data
        MOVEM.L (SP)+,D0-D7/A0-A6
        MOVEM.L (SP)+,D0-D7/A0-A6 ;double restore because of DF hack workaround
        ADD.L   #4,SP       ;account for USP, it'll fix itself (it shouldn't be used)
                                ;EASY68k simulator starts in supervisor mode
        MOVE    (SP)+,SR
        ADD.L   #4,SP       ;skip saved stack
        SUB.L   #134,SP     ;find data again
        MOVE.L  (SP),D2
        ADD.L   #138,SP     ;go back to original spot
        BRA     SHELL

MRD3:
        ADD.L   #1,A1
        CMP.B   #$20,(A1)+
        BNE     ERRORSR
        MOVE.L  A1,A2
        MOVE.L  A2,A3
        JSR     MRDFINDDATA
        SUB.L   #1,A3
        JSR     ASCII_ADDRESS   ;convert data to hex
        MOVE.L  D5,-(SP)        ;store it temporarily
        ADD.L   #4,SP       ;dont lose data
        MOVEM.L (SP)+,D0-D7/A0-A6
        MOVEM.L (SP)+,D0-D7/A0-A6 ;double restore because of DF hack workaround
        ADD.L   #4,SP       ;account for USP, it'll fix itself (it shouldn't be used)
                                ;EASY68k simulator starts in supervisor mode
        MOVE    (SP)+,SR
        ADD.L   #4,SP       ;skip saved stack
        SUB.L   #134,SP     ;find data again
        MOVE.L  (SP),D3
        ADD.L   #138,SP     ;go back to original spot
        BRA     SHELL

MRD4:
        ADD.L   #1,A1
        CMP.B   #$20,(A1)+
        BNE     ERRORSR
        MOVE.L  A1,A2
        MOVE.L  A2,A3
        JSR     MRDFINDDATA
        SUB.L   #1,A3
        JSR     ASCII_ADDRESS   ;convert data to hex
        MOVE.L  D5,-(SP)        ;store it temporarily
        ADD.L   #4,SP       ;dont lose data
        MOVEM.L (SP)+,D0-D7/A0-A6
        MOVEM.L (SP)+,D0-D7/A0-A6 ;double restore because of DF hack workaround
        ADD.L   #4,SP       ;account for USP, it'll fix itself (it shouldn't be used)
                                ;EASY68k simulator starts in supervisor mode
        MOVE    (SP)+,SR
        ADD.L   #4,SP       ;skip saved stack
        SUB.L   #134,SP     ;find data again
        MOVE.L  (SP),D4
        ADD.L   #138,SP     ;go back to original spot
        BRA     SHELL

MRD5:
        ADD.L   #1,A1
        CMP.B   #$20,(A1)+
        BNE     ERRORSR
        MOVE.L  A1,A2
        MOVE.L  A2,A3
        JSR     MRDFINDDATA
        SUB.L   #1,A3
        JSR     ASCII_ADDRESS   ;convert data to hex
        MOVE.L  D5,-(SP)        ;store it temporarily
        ADD.L   #4,SP       ;dont lose data
        MOVEM.L (SP)+,D0-D7/A0-A6
        MOVEM.L (SP)+,D0-D7/A0-A6 ;double restore because of DF hack workaround
        ADD.L   #4,SP       ;account for USP, it'll fix itself (it shouldn't be used)
                                ;EASY68k simulator starts in supervisor mode
        MOVE    (SP)+,SR
        ADD.L   #4,SP       ;skip saved stack
        SUB.L   #134,SP     ;find data again
        MOVE.L  (SP),D5
        ADD.L   #138,SP     ;go back to original spot
        BRA     SHELL

MRD6:
        ADD.L   #1,A1
        CMP.B   #$20,(A1)+
        BNE     ERRORSR
        MOVE.L  A1,A2
        MOVE.L  A2,A3
        JSR     MRDFINDDATA
        SUB.L   #1,A3
        JSR     ASCII_ADDRESS   ;convert data to hex
        MOVE.L  D5,-(SP)        ;store it temporarily
        ADD.L   #4,SP       ;dont lose data
        MOVEM.L (SP)+,D0-D7/A0-A6
        MOVEM.L (SP)+,D0-D7/A0-A6 ;double restore because of DF hack workaround
        ADD.L   #4,SP       ;account for USP, it'll fix itself (it shouldn't be used)
                                ;EASY68k simulator starts in supervisor mode
        MOVE    (SP)+,SR
        ADD.L   #4,SP       ;skip saved stack
        SUB.L   #134,SP     ;find data again
        MOVE.L  (SP),D6
        ADD.L   #138,SP     ;go back to original spot
        BRA     SHELL

MRD7:
        ADD.L   #1,A1
        CMP.B   #$20,(A1)+
        BNE     ERRORSR
        MOVE.L  A1,A2
        MOVE.L  A2,A3
        JSR     MRDFINDDATA
        SUB.L   #1,A3
        JSR     ASCII_ADDRESS   ;convert data to hex
        MOVE.L  D5,-(SP)        ;store it temporarily
        ADD.L   #4,SP       ;dont lose data
        MOVEM.L (SP)+,D0-D7/A0-A6
        MOVEM.L (SP)+,D0-D7/A0-A6 ;double restore because of DF hack workaround
        ADD.L   #4,SP       ;account for USP, it'll fix itself (it shouldn't be used)
                                ;EASY68k simulator starts in supervisor mode
        MOVE    (SP)+,SR
       ADD.L   #4,SP       ;skip saved stack
        SUB.L   #134,SP     ;find data again
        MOVE.L  (SP),D7
        ADD.L   #138,SP     ;go back to original spot
        BRA     SHELL

MRA0:
        ADD.L   #1,A1
        CMP.B   #$20,(A1)+
        BNE     ERRORSR
        MOVE.L  A1,A2
        MOVE.L  A2,A3
        JSR     MRDFINDDATA
        SUB.L   #1,A3
        JSR     ASCII_ADDRESS   ;convert data to hex
        MOVE.L  D5,-(SP)        ;store it temporarily
        ADD.L   #4,SP       ;dont lose data
        MOVEM.L (SP)+,D0-D7/A0-A6
        MOVEM.L (SP)+,D0-D7/A0-A6 ;double restore because of DF hack workaround
        ADD.L   #4,SP       ;account for USP, it'll fix itself (it shouldn't be used)
                                ;EASY68k simulator starts in supervisor mode
        MOVE    (SP)+,SR
        ADD.L   #4,SP       ;skip saved stack
        SUB.L   #134,SP     ;find data again
        MOVE.L  (SP),A0
        ADD.L   #138,SP     ;go back to original spot
        BRA     SHELL
MRA1:
        ADD.L   #1,A1
        CMP.B   #$20,(A1)+
        BNE     ERRORSR
        MOVE.L  A1,A2
        MOVE.L  A2,A3
        JSR     MRDFINDDATA
        SUB.L   #1,A3
        JSR     ASCII_ADDRESS   ;convert data to hex
        MOVE.L  D5,-(SP)        ;store it temporarily
        ADD.L   #4,SP       ;dont lose data
        MOVEM.L (SP)+,D0-D7/A0-A6
        MOVEM.L (SP)+,D0-D7/A0-A6 ;double restore because of DF hack workaround
        ADD.L   #4,SP       ;account for USP, it'll fix itself (it shouldn't be used)
                                ;EASY68k simulator starts in supervisor mode
        MOVE    (SP)+,SR
       ADD.L   #4,SP       ;skip saved stack
        SUB.L   #134,SP     ;find data again
        MOVE.L  (SP),A1
        ADD.L   #138,SP     ;go back to original spot
        BRA     SHELL

MRA2:
        ADD.L   #1,A1
        CMP.B   #$20,(A1)+
        BNE     ERRORSR
        MOVE.L  A1,A2
        MOVE.L  A2,A3
        JSR     MRDFINDDATA
        SUB.L   #1,A3
        JSR     ASCII_ADDRESS   ;convert data to hex
        MOVE.L  D5,-(SP)        ;store it temporarily
        ADD.L   #4,SP       ;dont lose data
        MOVEM.L (SP)+,D0-D7/A0-A6
        MOVEM.L (SP)+,D0-D7/A0-A6 ;double restore because of DF hack workaround
        ADD.L   #4,SP       ;account for USP, it'll fix itself (it shouldn't be used)
                                ;EASY68k simulator starts in supervisor mode
        MOVE    (SP)+,SR
        ADD.L   #4,SP       ;skip saved stack
        SUB.L   #134,SP     ;find data again
        MOVE.L  (SP),A2
        ADD.L   #138,SP     ;go back to original spot
        BRA     SHELL
        
MRA3:
        ADD.L   #1,A1
        CMP.B   #$20,(A1)+
        BNE     ERRORSR
        MOVE.L  A1,A2
        MOVE.L  A2,A3
        JSR     MRDFINDDATA
        SUB.L   #1,A3
        JSR     ASCII_ADDRESS   ;convert data to hex
        MOVE.L  D5,-(SP)        ;store it temporarily
        ADD.L   #4,SP       ;dont lose data
        MOVEM.L (SP)+,D0-D7/A0-A6
        MOVEM.L (SP)+,D0-D7/A0-A6 ;double restore because of DF hack workaround
        ADD.L   #4,SP       ;account for USP, it'll fix itself (it shouldn't be used)
                                ;EASY68k simulator starts in supervisor mode
        MOVE    (SP)+,SR
        ADD.L   #4,SP       ;skip saved stack
        SUB.L   #134,SP     ;find data again
        MOVE.L  (SP),A3
        ADD.L   #138,SP     ;go back to original spot
        BRA     SHELL

MRA4:
        ADD.L   #1,A1
        CMP.B   #$20,(A1)+
        BNE     ERRORSR
        MOVE.L  A1,A2
        MOVE.L  A2,A3
        JSR     MRDFINDDATA
        SUB.L   #1,A3
        JSR     ASCII_ADDRESS   ;convert data to hex
        MOVE.L  D5,-(SP)        ;store it temporarily
        ADD.L   #4,SP       ;dont lose data
        MOVEM.L (SP)+,D0-D7/A0-A6
        MOVEM.L (SP)+,D0-D7/A0-A6 ;double restore because of DF hack workaround
        ADD.L   #4,SP       ;account for USP, it'll fix itself (it shouldn't be used)
                                ;EASY68k simulator starts in supervisor mode
        MOVE    (SP)+,SR
        ADD.L   #4,SP       ;skip saved stack
        SUB.L   #134,SP     ;find data again
        MOVE.L  (SP),A4
        ADD.L   #138,SP     ;go back to original spot
        BRA     SHELL

MRA5:
        ADD.L   #1,A1
        CMP.B   #$20,(A1)+
        BNE     ERRORSR
        MOVE.L  A1,A2
        MOVE.L  A2,A3
        JSR     MRDFINDDATA
        SUB.L   #1,A3
        JSR     ASCII_ADDRESS   ;convert data to hex
        MOVE.L  D5,-(SP)        ;store it temporarily
        ADD.L   #4,SP       ;dont lose data
        MOVEM.L (SP)+,D0-D7/A0-A6
        MOVEM.L (SP)+,D0-D7/A0-A6 ;double restore because of DF hack workaround
        ADD.L   #4,SP       ;account for USP, it'll fix itself (it shouldn't be used)
                                ;EASY68k simulator starts in supervisor mode
        MOVE    (SP)+,SR
       ADD.L   #4,SP       ;skip saved stack
        SUB.L   #134,SP     ;find data again
        MOVE.L  (SP),A5
        ADD.L   #138,SP     ;go back to original spot
        BRA     SHELL

MRA6:
        ADD.L   #1,A1
        CMP.B   #$20,(A1)+
        BNE     ERRORSR
        MOVE.L  A1,A2
        MOVE.L  A2,A3
        JSR     MRDFINDDATA
        SUB.L   #1,A3
        JSR     ASCII_ADDRESS   ;convert data to hex
        MOVE.L  D5,-(SP)        ;store it temporarily
        ADD.L   #4,SP       ;dont lose data
        MOVEM.L (SP)+,D0-D7/A0-A6
        MOVEM.L (SP)+,D0-D7/A0-A6 ;double restore because of DF hack workaround
        ADD.L   #4,SP       ;account for USP, it'll fix itself (it shouldn't be used)
                                ;EASY68k simulator starts in supervisor mode
        MOVE    (SP)+,SR
        ADD.L   #4,SP       ;skip saved stack
        SUB.L   #134,SP     ;find data again
        MOVE.L  (SP),A6
        ADD.L   #138,SP     ;go back to original spot
        BRA     SHELL

MRDFINDDATA:
        CMP.B   #$00,(A3)+
        BEQ     GOBACK
        BRA     MRDFINDDATA
GOBACK: RTS
        

        BRA RESTORE
*--------------------REQUIRED COMMAND DEFINITION START---------------------------------*
*--------------------------------------------------------------------------------------*
HELP:       LEA     HTXT,A1     ;list of commands test
            MOVE.W  #17,D1
            MOVE.B  #0,D0
            TRAP    #15
            MOVE.W  #0,D1       ;newline
            TRAP    #15
            
            LEA     HTXT1,A1    ;mem display command
            MOVE.W  #75,D1
            MOVE.B  #0,D0
            TRAP    #15
            LEA     HTXT1A,A1   ;mem display
            MOVE.W  #61,D1
            MOVE.B  #0,D0
            TRAP    #15
            LEA     HTXT1B,A1   ;mem display
            MOVE.W  #20,D1
            MOVE.B  #0,D0
            TRAP    #15
            MOVE.W  #0,D1       ;newline
            TRAP    #15
            
            LEA     HTXT2,A1    ;hxdec command text
            MOVE.W  #75,D1
            MOVE.B  #0,D0
            TRAP    #15
            MOVE.B  #0,D1       ;newline
            TRAP    #15
            
            LEA     HTXT3,A1    ;sort command text
            MOVE.W  #69,D1
            MOVE.B  #0,D0
            TRAP    #15
            LEA     HTXT3A,A1    ;sort command text continued
            MOVE.W  #57,D1
            MOVE.B  #0,D0
            TRAP    #15
            LEA     HTXT3B,A1    ;sort command text continued
            MOVE.W  #20,D1
            MOVE.B  #0,D0
            TRAP    #15
            LEA     HTXT3C,A1    ;sort command text continued
            MOVE.W  #21,D1
            MOVE.B  #0,D0
            TRAP    #15
            LEA     HTXT3D,A1    ;sort command text continued
            MOVE.W  #29,D1
            MOVE.B  #0,D0
            TRAP    #15
            LEA     HTXT3E,A1    ;sort command text continued
            MOVE.W  #51,D1
            MOVE.B  #0,D0
            TRAP    #15
            MOVE.B  #0,D1       ;newline
            TRAP    #15
            
            LEA     HTXT4,A1    ;memory modify command text 
            MOVE.W  #71,D1
            MOVE.B  #0,D0
            TRAP    #15
            LEA     HTXT4A,A1    ;mem modify command text continued
            MOVE.W  #69,D1
            MOVE.B  #0,D0
            TRAP    #15
            LEA     HTXT4B,A1    ;mem modify command text continued
            MOVE.W  #27,D1
            MOVE.B  #0,D0
            TRAP    #15
            LEA     HTXT4C,A1    ;mem modify command text continued
            MOVE.W  #30,D1
            MOVE.B  #0,D0
            TRAP    #15
            LEA     HTXT4D,A1    ;mem modify command text continued
            MOVE.W  #31,D1
            MOVE.B  #0,D0
            TRAP    #15
            LEA     HTXT4E,A1    ;mem modify command text continued
            MOVE.W  #36,D1
            MOVE.B  #0,D0
            TRAP    #15
            MOVE.B  #0,D1
            TRAP    #15         ;newline
            
            LEA     HTXT5,A1    ;memory set command text 
            MOVE.W  #70,D1
            MOVE.B  #0,D0
            TRAP    #15
            LEA     HTXT5A,A1    ;memory set command text continued
            MOVE.W  #9,D1
            MOVE.B  #0,D0
            TRAP    #15
            MOVE.B  #0,D1       ;newline
            TRAP    #15
            
            LEA     HTXT6,A1    ;block fill command text
            MOVE.W  #69,D1
            MOVE.B  #0,D0
            TRAP    #15
            LEA     HTXT6A,A1    ;block fill command text
            MOVE.W  #72,D1
            MOVE.B  #0,D0
            TRAP    #15
            LEA     HTXT6B,A1    ;block fill command text
            MOVE.W  #38,D1
            MOVE.B  #0,D0
            TRAP    #15
            MOVE.B  #0,D1
            TRAP    #15         ;newline
            
            
            LEA     HTXT7,A1    ;block move command text
            MOVE.W  #68,D1
            MOVE.B  #0,D0
            TRAP    #15
            LEA     HTXT7A,A1    ;block move command text
            MOVE.W  #72,D1
            MOVE.B  #0,D0
            TRAP    #15
            LEA     HTXT7B,A1    ;block move command text
            MOVE.W  #24,D1
            MOVE.B  #0,D0
            TRAP    #15
            MOVE.B  #0,D1       ;newline
            TRAP    #15
            
            LEA     HTXT8,A1    ;block test command text
            MOVE.W  #71,D1
            MOVE.B  #0,D0
            TRAP    #15
            LEA     HTXT8A,A1    ;block test command text
            MOVE.W  #40,D1
            MOVE.B  #0,D0
            TRAP    #15
            MOVE.B  #0,D1       ;newline
            TRAP    #15
            
            LEA     HTXT9,A1    ;block search command text
            MOVE.W  #70,D1
            MOVE.B  #0,D0
            TRAP    #15
            LEA     HTXT9A,A1    ;block search command text
            MOVE.W  #45,D1
            MOVE.B  #0,D0
            TRAP    #15
            MOVE.B  #0,D1       ;newline
            TRAP    #15
            
            LEA     HTXT10,A1    ;go command text
            MOVE.W  #61,D1
            MOVE.B  #0,D0
            TRAP    #15
            MOVE.B  #0,D1      ;newline
            TRAP    #15

            LEA     HTXT11,A1   ;df command text   
            MOVE.W  #56,D1
            MOVE.B  #0,D0
            TRAP    #15
            MOVE.B  #0,D1
            TRAP    #15
            
            LEA     HTXT12,A1   ;help command text
            MOVE.W  #66,D1
            MOVE.B  #0,D0
            TRAP    #15
            MOVE.B  #0,D1       ;newline
            TRAP    #15   
            
            LEA     HTXT13,A1   ;echo command text   
            MOVE.W  #52,D1
            MOVE.B  #0,D0
            TRAP    #15
            MOVE.B  #0,D1       ;newline
            TRAP    #15
            
            LEA     HTXT14,A1   ;modify register command text   
            MOVE.W  #71,D1
            MOVE.B  #0,D0
            TRAP    #15
            LEA     HTXT15,A1   ;modify register command text   
            MOVE.W  #63,D1
            MOVE.B  #0,D0
            TRAP    #15
            MOVE.B  #0,D1       ;newline
            TRAP    #15
 
            BRA     RESTORE  
*--------------------------------------------------------------------------------------*
*Fix ASCII String input? ask in lab*
MEMSET:     LEA     BUFFER,A2
            ADD.L   #3,A2
            MOVE.L  A2,A3   ;set up to find end
FINDEND:    CMP.B   #$00,(A3)+
            BEQ     MEMCONT
            BRA     FINDEND
MEMCONT:    SUB.L  #1,A3   ;get rid of off by one erro
            MOVE.B  (A2)+,D1
            MOVE.B  (A2),D2
            MOVE.B  D1,D3       ;pass value to subroutine
            JSR     ASCII_TO_BCD           
            MOVE.B  D3,D1       ;get converted value
            MOVE.B  D2,D3       ;pass value
            JSR     ASCII_TO_BCD
            MOVE.B  D3,D2       ;get returned value
            MOVE.B  D1,D3
            JSR     BCD_TO_HEX
            MOVE.B  D3,D1
            MOVE.B  D2,D3
            JSR     BCD_TO_HEX
            MOVE.B  D3,D2
            ROL.L   #4,D1       ;put data in correct place
            ADD     D1,D2       ;get combined data input
            ADD.L   #2,A2       ;go to start of address
            JSR     ASCII_ADDRESS  ;get address in workable form
            MOVE.L  D5,A4       ;load target address
            MOVE.B  D2,(A4)       ;put data in target address
            BRA     RESTORE                 ;return to shell
*--------------------------------------------------------------------------------------*
MEMDISP:    LEA     BUFFER,A2
            MOVE.L  #1,D6       ;counter for how many times to loop
            ADD.L   #5,A2       ;get first address
            MOVE.L  A2,A3       
FINDEND1:   CMP.B   #$20,(A3)+
            BEQ     FINDNEXT
            BRA     FINDEND1  
FINDNEXT:   MOVE.L  A3,A4
            MOVE.L  A3,A5
            SUB.L   #1,A3   ;get rid of off by one error
FINDEND2:   CMP.B   #$00,(A5)+
            BEQ     MEMNEXT
            BRA     FINDEND2
MEMNEXT:    SUB.L   #1,A5   ;off by one error
            JSR     ASCII_ADDRESS
            MOVE.L  D5,A6   ;put 1st address in A6
            MOVE.L  A4,A2
            MOVE.L  A5,A3
            JSR ASCII_ADDRESS
            MOVE.L  D5,A5   ;second address in A5
            MOVE.L  A6,A0   ;for second run through
            MOVE.L  A5,A1   ;see above comment
            ADD.L   #16,A1 ;16 byte offset
            MOVEM.L A1,-(SP)
DISPLOOP:   CMP.L   A6,A5
            BLT     SECONDLOOP
            MOVE.L  A6,D3
            JSR     HEXTOASCII
            SUB.L   A2,A3
            MOVE.L  A3,D1   ;number of ascii values to display
            MOVE.L  A2,A1
            MOVE.L  #1,D0
            TRAP    #15
            LEA     SPACE,A1
            MOVE.L #1,D1
            TRAP    #15
            CLR.L   D3
            MOVE.B  (A6),D3
            JSR     HEXTOASCII
            SUB.L   A2,A3
            MOVE.L  A3,D1
            MOVE.L  A2,A1
            MOVE.L  #0,D0
            TRAP    #15
            ADD.L   #1,A6
            BRA     DISPLOOP
            
SECONDLOOP: 
            MOVE.B  #0,D0
            MOVE.B  #0,D1
            TRAP    #15
            MOVEM.L (SP)+,A1
            MOVE.L  A0,A6   ;reinit
            MOVE.L  A1,A5
            SUBI.L  #1,D6
            CMP.L   #$0,D6
            BEQ     DISPLOOP
            SUB.L   #4,SP   ;off by long error on stack
            BRA     RESTORE
            
*--------------------------------------------------------------------------------------*

HXDC:   LEA BUFFER,A2   ;load buffer
        ADD.L   #6,A2   ; start of number
        MOVE.L  A2,A3   ;set up end pointer
        MOVE.L  #1,D1   ;set up 16's place
        CLR.L   D2      ;clear total
        CLR.L   D3      ;temp holder for number
        CLR.L   D6      ;Final Value in BCD
        MOVE.L  #10000,D4    ;maximum 10's place of converted number
        MOVE.L  #16,D5      ;Max number of rotates needed
        LEA $3A00,A5
        LEA $3A00,A4   ;set up start pointer
FINDLASTNUM:    
        CMP.B #$00,(A3)+
        BEQ     CONVERTMINUS1
        BRA     FINDLASTNUM
CONVERTMINUS1:   
             SUB.L   #1,A3 ; cure off by 1 error
CONVERT:
            SUB.L   #1,A3
            CMP   A3,A2
            BGT   ENDCONVERT
            CMP.B   #$40,(A3)
            BGT     HIGHHEX
            SUBI.B  #$30,(A3)   ;get hex value
            BRA     COMPUTATION
HIGHHEX:     SUBI.B  #$37,(A3)  ;get hex value
COMPUTATION:
            MOVE.B  (A3),D3 
            MULU    D1,D3   ;get 16's place
           ; DIVU    #16,D3  ;get rid of off by 1 exponent error
            MULU    #16,D1  ;inc 16's place counter
            MOVE.B  D3,(A4)
            SUB.L   #1,A4
            ADD.L   D3,D2   ;store it in total for debugging 
            CLR.L   D3      ;get rid of any numbers in there   
            BRA     CONVERT     
ENDCONVERT:                  ;must convert back to ascii for display
            CLR.L   D3      ;Cleared for workability
            DIVU    D4,D2   ;get 10's place digit
            MOVE.W  D2,D3   ;extract 10's place digit to D3
            ROL.L   D5,D3   ;put it in its place
            CLR.W   D2      ;get rid of whole number
            SWAP    D2      ;keep remainder
            SUBI.L  #4,D5   ;dec rotate counter
            ADD.L   D3,D6   ;put it into it's place
            DIVU    #10,D4  ;go down a 10's place
            CMP.W   #0,D4   ;are we done
            BEQ     OUTPUTNUM
            BRA     ENDCONVERT
            
OUTPUTNUM:
           MOVE.L   D6,D3   ;put into register for conversion to ASCII
           JSR      HEXTOASCII
           MOVEA.L  A2,A1   ;get start of number
           SUBA     A2,A3   ;get how many bytes to output
           MOVE.L   A3,D1   ;for Trap call
           MOVE.L   #0,D0   
           TRAP     #15
           
           BRA RESTORE

*--------------------------------------------------------------------------------------*

SORTW:  ADD.L   #1,A1       ;increment to check for semicolon/dash
        CMP.B   #$2D,(A1)   ;check for default
        BEQ     DEFAULTTEST
        CMP.B   #$3B,(A1)+
        BNE     ERRORSR
        CMP.B   #$41,(A1)   ;is it ascending?
        BEQ     ASCEND
        CMP.B   #$44,(A1)   ;or descending?
        BNE     ERRORSR
        BRA     DESCEND
        
DEFAULTTEST:
                ADD.L  #1,A1   ;check for paren
        CMP.B   #$28,(A1)+  ;(
        BNE     ERRORSR
        CMP.B   #$64,(A1)+  ;d
        BNE     ERRORSR
        CMP.B   #$65,(A1)+  ;e
        BNE     ERRORSR
        CMP.B   #$66,(A1)+  ;f
        BNE     ERRORSR
        CMP.B   #$61,(A1)+  ;a
        BNE     ERRORSR
        CMP.B   #$75,(A1)+  ;u
        BNE     ERRORSR
        CMP.B   #$6C,(A1)+  ;l
        BNE     ERRORSR     
        CMP.B   #$74,(A1)+  ;t
        BNE     ERRORSR
        CMP.B   #$29,(A1)  ;)
        BNE     ERRORSR
        BRA     DESCEND

        
ASCEND:
       ADD.L    #1,A1   ;inc
       CMP.B    #$20,(A1)   ;check space
       BNE      ERRORSR
       ADD.L    #1,A1   ;start of 1st address
       MOVE.L   A1,A2
       MOVE.L   A2,A3
AGETFIRSTADDRESS:
       CMP.B    #$00,(A3)
       BEQ      ERRORSR     ;incorrect syntax
       CMP.B    #$20,(A3)+  ;trying to find the end
       BEQ      AFADDCONV
       BRA      AGETFIRSTADDRESS
AFADDCONV:
       SUB.L    #1,A3   ;off by one error
       JSR ASCII_ADDRESS    ;D5 now has that address 
       MOVE.L D5,A4
       ADD.L    #1,A3   ;start of second address
       MOVE.L   A3,A2   ;setup for second address
AGETSECADDRESS:
       CMP.B    #$00,(A3)+  ;trying to find the end
       BEQ      ASADDCONV
       BRA      AGETSECADDRESS
ASADDCONV:
        SUB.L   #1,A3   ;off by one
        JSR     ASCII_ADDRESS
        MOVE.L  D5,A5
        MOVEA.L  A4,A6  ;CLR A6
        
ARESETLOOP: MOVE.L  A6,A4    ;reset to top of loop
ACMP:       CMP.W   (A4)+,(A4)+  ;check adjacent mem
            BLS.S   ASWAP    
            SUBQ.L  #2,A4
            CMP.L   A4,A5   ;done?
            BNE     ACMP     ;nope
            BRA     DONEASCEND  ;yep
ASWAP:       MOVE.L  -(A4),D0    ;start bubbling 
            SWAP.W  D0
            MOVE.L  D0,(A4)
            BRA     ARESETLOOP


DESCEND:
       ADD.L    #1,A1   ;inc
       CMP.B    #$20,(A1)   ;check space
       BNE      ERRORSR
       ADD.L    #1,A1   ;start of 1st address
       MOVE.L   A1,A2
       MOVE.L   A2,A3
DGETFIRSTADDRESS:
       CMP.B    #$00,(A3)
       BEQ      ERRORSR     ;incorrect syntax
       CMP.B    #$20,(A3)+  ;trying to find the end
       BEQ      DFADDCONV
       BRA      DGETFIRSTADDRESS
DFADDCONV:
       SUB.L    #1,A3   ;off by one error
       JSR ASCII_ADDRESS    ;D5 now has that address 
       MOVE.L D5,A4
       ADD.L    #1,A3   ;start of second address
       MOVE.L   A3,A2   ;setup for second address
DGETSECADDRESS:
       CMP.B    #$00,(A3)+  ;trying to find the end
       BEQ      DSADDCONV
       BRA      DGETSECADDRESS
DSADDCONV:
        SUB.L   #1,A3   ;off by one
        JSR     ASCII_ADDRESS
        MOVE.L  D5,A5
        MOVEA.L  A4,A6  ;CLR A6
        
DRESETLOOP: MOVE.L  A6,A4    ;reset to top of loop
DCMP:       CMP.W   (A4)+,(A4)+  ;check adjacent mem
            BHI.S   DSWAP    
            SUBQ.L  #2,A4
            CMP.L   A4,A5   ;done?
            BNE     DCMP     ;nope
            BRA     DONEDESCEND  ;yep
DSWAP:       MOVE.L  -(A4),D0    ;start bubbling 
            SWAP.W  D0
            MOVE.L  D0,(A4)
            BRA     DRESETLOOP

DONEASCEND:
DONEDESCEND:
            BRA RESTORE

*--------------------------------------------------------------------------------------*

MM:    CLR.L    D2      ;used for storing values
       CLR.L    D6      
SIZECHECK:  
        MOVE.L  A1,A3   ;set up to find end ptr
ENDPTRMM:
        CMP.B   #$00,(A3)+
        BNE     ENDPTRMM
        SUB.L   #1,A3   ;off by one error
        ADD.L   #1,A1   ;inc pointer to start of specifier
        CMP.B   #$2D,(A1)   ;check for default
        BEQ     DEFAULT        
        CMP.B   #$3B,(A1)
        BNE     ERRORSR
        ADD.L   #1,A1   ;find out which size
        CMP.B   #$57,(A1) ; word
        BEQ     WORD
        CMP.B   #$4C,(A1)   ;long
        BEQ     LONG
        BRA     ERRORSR

***************************************************

DEFAULT: 
        ADD.L  #1,A1   ;check for paren
        CMP.B   #$28,(A1)+  ;(
        BNE     ERRORSR
        CMP.B   #$64,(A1)+  ;d
        BNE     ERRORSR
        CMP.B   #$65,(A1)+  ;e
        BNE     ERRORSR
        CMP.B   #$66,(A1)+  ;f
        BNE     ERRORSR
        CMP.B   #$61,(A1)+  ;a
        BNE     ERRORSR
        CMP.B   #$75,(A1)+  ;u
        BNE     ERRORSR
        CMP.B   #$6C,(A1)+  ;l
        BNE     ERRORSR     
        CMP.B   #$74,(A1)+  ;t
        BNE     ERRORSR
        CMP.B   #$29,(A1)+  ;)
        BNE     ERRORSR
        
        
        ADD.L   #1,A1       ;set up for subroutine
        MOVE    A1,A2       ;set up for subroutine
        MOVEM.L D1/D6/A1-A3,-(SP)
        JSR     ASCII_ADDRESS
        MOVEM.L (SP)+,D1/D6/A1-A3
        MOVE.L  D5,A4       ;set up address to modify
       
MODIFYLOOP:
        *-------Display Memory First-----*
        MOVE.L  A4,D3       ;set up for subroutine
        JSR     HEXTOASCII  ;convert new address to ascii for output
        SUBA    A2,A3       ;get num of bytes to produce
        MOVE.L  #1,D0
        MOVE.L  A3,D1
        MOVE.L  A2,A1
        TRAP    #15
        
        *add colon to denote containing data*
        MOVE.B  #$3A,(A1)
        MOVE.L  #1,D1   ;display only the colon
        MOVE.L  #1,D0
        TRAP    #15
        
        MOVE.B  (A4),D3
        JSR     HEXTOASCII
        MOVE.L  #2,D1
        SUB.L   A2,A3
        CMP     #2,A3
        BEQ     FORMATGOOD
        SUB.L   #1,A2
FORMATGOOD:
        MOVE.L  A2,A1
        MOVE.B  #1,D0
        TRAP    #15
        
        MOVE.B  #$20,(A1)
        MOVE.L  #1,D1   ;space between held data and input
        MOVE.L  #1,D0
        TRAP    #15

        
        *-----Enter Input-------*
        CLR.L   D3
        MOVE.L  #4,D6
        LEA     BUFFER,A1   ;set up storage for command
        MOVE.B  #2,D0       ;load input trap call
        TRAP    #15
        CMP.B   #$2E,(A1)
        BEQ     ENDLP
        CMP.B   #$00,(A1)
        BEQ     ENTER
        
PARSELOOP:
        CMP.B   #$00,(A1)
        BEQ     ENDPARSE        
        CMP.B   #$40,(A1)
        BGT     HIGHHEXMM
        SUBI.B  #$30,(A1)   ;get hex value
        BRA     NEXTMMSTEP
HIGHHEXMM: SUBI.B  #$37,(A1)  ;get hex value
NEXTMMSTEP:
        MOVE.B  (A1),D2
        ROL.L   D6,D2
        SUBI.L  #4,D6
        ADD.L   #1,A1
        ADD.B   D2,D3   ;total byte stored in D3
        BRA     PARSELOOP
ENDPARSE:
        MOVE.B  D3,(A4)   ;commit memory change 
ENTER:  ADD.L   #1,A4   ;increment address
        BRA     MODIFYLOOP
        
***************************************************

WORD:
            
        ADD.L   #2,A1       ;set up for subroutine
        MOVE    A1,A2       ;set up for subroutine
        MOVEM.L D1/D6/A1-A3,-(SP)
        JSR     ASCII_ADDRESS
        MOVEM.L (SP)+,D1/D6/A1-A3
        MOVE.L  D5,A4       ;set up address to modify
       
MODIFYLOOPW:
        *-------Display Memory First-----*
        MOVE.L  A4,D0
        DIVU    #2,D0
        SWAP    D0      ;check if it's an odd address
        CMP.W   #$00,D0
        BNE     ERRORSR
        MOVE.L  A4,D3       ;set up for subroutine
        MOVE.L  A4,A5       ;next byte of memory may not be needed
        ADD.L   #1,A5
        JSR     HEXTOASCII  ;convert new address to ascii for output
        SUBA    A2,A3       ;get num of bytes to produce
        MOVE.L  #1,D0
        MOVE.L  A3,D1
        MOVE.L  A2,A1
        TRAP    #15
        
        *add colon to denote containing data*
        MOVE.B  #$3A,(A1)
        MOVE.L  #1,D1   ;display only the colon
        MOVE.L  #1,D0
        TRAP    #15
        
        MOVE.B  (A4),D3
        JSR     HEXTOASCII
        MOVE.L  #2,D1
        SUB.L   A2,A3
        CMP     #2,A3
        BEQ     FORMATGOOD1
        SUB.L   #1,A2     
FORMATGOOD1:

        MOVE.L  A2,A1
        MOVE.B  #1,D0
        TRAP    #15
        
        MOVE.B  (A5),D3
        JSR     HEXTOASCII
        MOVE.L  #2,D1
        SUB.L   A2,A3
        CMP     #2,A3
        BEQ     FORMATGOOD2
        SUB.L   #1,A2     
FORMATGOOD2:

        MOVE.L  A2,A1
        MOVE.B  #1,D0
        TRAP    #15

        
        MOVE.B  #$20,(A1)
        MOVE.L  #1,D1   ;space between held data and input
        MOVE.L  #1,D0
        TRAP    #15

        
        *-----Enter Input-------*
        CLR.L   D3
        MOVE.L  #12,D6
        LEA     BUFFER,A1   ;set up storage for command
        MOVE.B  #2,D0       ;load input trap call
        TRAP    #15
        CMP.B   #$2E,(A1)
        BEQ     ENDLP
        CMP.B   #$00,(A1)
        BEQ     ENTERW
        
PARSELOOPW:
        CMP.B   #$00,(A1)
        BEQ     ENDPARSEW        
        CMP.B   #$40,(A1)
        BGT     HIGHHEXMMW
        SUBI.B  #$30,(A1)   ;get hex value
        BRA     NEXTMMSTEPW
HIGHHEXMMW: SUBI.B  #$37,(A1)  ;get hex value
NEXTMMSTEPW:
        MOVE.B  (A1),D2
        ROL.L   D6,D2
        SUBI.L  #4,D6
        ADD.L   #1,A1
        ADD.L   D2,D3   ;total byte stored in D3
        CLR.L   D2      ;clear for next rotate
        BRA     PARSELOOPW
ENDPARSEW:
        
        MOVE.W  D3,(A4)   ;commit memory change 
ENTERW:  ADD.L   #2,A4   ;increment address
        BRA     MODIFYLOOPW

***************************************************

LONG:  
        ADD.L   #2,A1       ;set up for subroutine
        MOVE    A1,A2       ;set up for subroutine
        MOVEM.L D1/D6/A1-A3,-(SP)
        JSR     ASCII_ADDRESS
        MOVEM.L (SP)+,D1/D6/A1-A3
        MOVE.L  D5,A4       ;set up address to modify
       
MODIFYLOOPL:
        *-------Display Memory First-----*
        MOVE.L  A4,D0
        DIVU    #2,D0
        SWAP    D0      ;check if it's an odd address
        CMP.W   #$00,D0
        BNE     ERRORSR
        MOVE.L  A4,D3       ;set up for subroutine
        MOVE.L  A4,A5       ;next byte of memory may not be needed
        ADD.L   #1,A5
        JSR     HEXTOASCII  ;convert new address to ascii for output
        SUBA    A2,A3       ;get num of bytes to produce
        MOVE.L  #1,D0
        MOVE.L  A3,D1
        MOVE.L  A2,A1
        TRAP    #15
        
        *add colon to denote containing data*
        MOVE.B  #$3A,(A1)
        MOVE.L  #1,D1   ;display only the colon
        MOVE.L  #1,D0
        TRAP    #15
        
        MOVE.B  (A4),D3
        JSR     HEXTOASCII
        MOVE.L  #2,D1
        SUB.L   A2,A3
        CMP     #2,A3
        BEQ     FORMATGOOD3
        SUB.L   #1,A2     
FORMATGOOD3:

        MOVE.L  A2,A1
        MOVE.B  #1,D0
        TRAP    #15
        
        MOVE.B  (A5)+,D3
        JSR     HEXTOASCII
        MOVE.L  #2,D1
        SUB.L   A2,A3
        CMP     #2,A3
        BEQ     FORMATGOOD4
        SUB.L   #1,A2     
FORMATGOOD4:

        MOVE.L  A2,A1
        MOVE.B  #1,D0
        TRAP    #15
        
        MOVE.B  (A5)+,D3
        JSR     HEXTOASCII
        MOVE.L  #2,D1
        SUB.L   A2,A3
        CMP     #2,A3
        BEQ     FORMATGOOD5
        SUB.L   #1,A2     
FORMATGOOD5:

        MOVE.L  A2,A1
        MOVE.B  #1,D0
        TRAP    #15
        MOVE.B  (A5)+,D3
        JSR     HEXTOASCII
        MOVE.L  #2,D1
        SUB.L   A2,A3
        CMP     #2,A3
        BEQ     FORMATGOOD6
        SUB.L   #1,A2     
FORMATGOOD6:

        MOVE.L  A2,A1
        MOVE.B  #1,D0
        TRAP    #15
   
        MOVE.B  #$20,(A1)
        MOVE.L  #1,D1   ;space between held data and input
        MOVE.L  #1,D0
        TRAP    #15

        
        *-----Enter Input-------*
        CLR.L   D3
        MOVE.L  #28,D6
        LEA     BUFFER,A1   ;set up storage for command
        MOVE.B  #2,D0       ;load input trap call
        TRAP    #15
        CMP.B   #$2E,(A1)
        BEQ     ENDLP
        CMP.B   #$00,(A1)
        BEQ     ENTERL
        
PARSELOOPL:
        CMP.B   #$00,(A1)
        BEQ     ENDPARSEL        
        CMP.B   #$40,(A1)
        BGT     HIGHHEXMML
        SUBI.B  #$30,(A1)   ;get hex value
        BRA     NEXTMMSTEPL
HIGHHEXMML: SUBI.B  #$37,(A1)  ;get hex value
NEXTMMSTEPL:
        MOVE.B  (A1),D2
        ROL.L   D6,D2
        SUBI.L  #4,D6
        ADD.L   #1,A1
        ADD.L   D2,D3   ;total byte stored in D3
        CLR.L   D2      ;clear for next rotate
        BRA     PARSELOOPL
ENDPARSEL:
        MOVE.L  D3,(A4)   ;commit memory change 
ENTERL:  ADD.L   #4,A4   ;increment address
        BRA     MODIFYLOOPL


ENDLP:  BRA RESTORE
        
        
*--------------------------------------------------------------------------------------*

BF:    
       ADD.L    #1,A1   ;first byte of data
       MOVE.L   A1,A3   ;for end ptr
BFGETENDDATA:
        CMP.B   #$20,(A3)+
        BEQ     BFNEXTADDR
        BRA     BFGETENDDATA
BFNEXTADDR:
        MOVE.L  A1,A2   ;for subroutine
        SUB.L   #1,A3   ;off by one error
        JSR     ASCII_ADDRESS
        MOVE.L  D5,-(SP)    ;save data on the stack
        
        ADD.L   #1,A3   ;inc end ptr to first byte of address
        MOVE.L  A3,A2   ;set start ptr
BFGETENDADDRONE:
        CMP.B   #$20,(A3)+
        BEQ     BFNEXTADDRTWO
        BRA     BFGETENDADDRONE
        
BFNEXTADDRTWO:
        SUB.L   #1,A3   ;off by one error
        JSR     ASCII_ADDRESS   ;convert address to hex
        MOVE.L  D5,A5       ;store address 1 in A5
        DIVU    #2,D5
        SWAP    D5
        CMP.W   #$00,D5
        BNE     ERRORSR
        
        ADD.L   #1,A3   ;inc end ptr to first byte of address
        MOVE.L  A3,A2   ;set start ptr
BFGETLASTEND:
        CMP.B   #$00,(A3)+
        BEQ     STOREDATA
        BRA     BFGETLASTEND
        
STOREDATA:
        SUB.L   #1,A3   ;off by one error
        JSR     ASCII_ADDRESS
        MOVE.L  D5,A6   ;end address in A6
        DIVU    #2,D5
        SWAP    D5
        CMP.W   #$00,D5
        BNE     ERRORSR
        MOVE.L  (SP)+,D5
        
DATALOOP:
        CMP.L   A5,A6
        BLT     ENDBF
        MOVE.W  D5,(A5)+
        BRA     DATALOOP

ENDBF:  BRA RESTORE
*--------------------------------------------------------------------------------------*

BMOV:   ADD.L   #1,A1   ;get to start of first address
        MOVE.L  A1,A2   ;set up start ptr
        MOVE.L  A2,A3   ;set up end ptr
        
FIRSTADDRESS:
        CMP.B #$20,(A3)+
        BEQ     COMPUTEFIRSTADD
        BRA     FIRSTADDRESS
        
COMPUTEFIRSTADD:
        SUB.L   #1,A3   ;off by one error
        JSR     ASCII_ADDRESS
        MOVE.L  D5,A0   ; save 1st address
        
        ADD.L   #1,A3
        MOVE.L  A3,A2
SECONDADDRESS:
        CMP.B   #$20,(A3)+
        BEQ     COMPUTESECONDADDRESS
        BRA     SECONDADDRESS
        
COMPUTESECONDADDRESS:
        SUB.L   #1,A3   ;off by one error
        JSR     ASCII_ADDRESS
        MOVE.L  D5,A4   ;save 2nd address

        ADD.L   #1,A3
        MOVE.L  A3,A2
THIRDADDRESS:
        CMP.B   #$20,(A3)+
        BEQ     COMPUTETHIRDADDRESS
        BRA     THIRDADDRESS
        
COMPUTETHIRDADDRESS:
        SUB.L   #1,A3
        JSR     ASCII_ADDRESS
        MOVE.L  D5,A5   ;save 3rd address
        
        ADD.L   #1,A3
        MOVE.L  A3,A2
FOURTHADDRESS:
        CMP.B   #$00,(A3)+
        BEQ     COMPUTEFOURTHADDRESS
        BRA     FOURTHADDRESS
        
COMPUTEFOURTHADDRESS:
        SUB.L   #1,A3
        JSR     ASCII_ADDRESS
        MOVE.L  D5,A6   ;save 3rd address
        
        

        *Check for matching dimensions*
        MOVE.L  A0,D0
        MOVE.L  A4,D1
        MOVE.L  A5,D5
        MOVE.L  A6,D6
        SUB.L   D0,D1
        SUB.L   D5,D6
        CMP.L   D1,D6
        BNE     ERRORSR
        CMP.L   A0,A4
        BLT     ERRORSR
        CMP.L   A5,A6
        BLT     ERRORSR

DATATRANSFER:
        CMP.L   A0,A4
        BLT     BMOVDONE
        MOVE.B  (A0)+,(A5)+
        BRA     DATATRANSFER
        


BMOVDONE:
        BRA RESTORE

*--------------------------------------------------------------------------------------*

BTST:   
       ADD.L    #1,A1   ;first byte of data
       MOVE.L   A1,A3   ;for end ptr
BTSTGETENDDATA:
        CMP.B   #$20,(A3)+
        BEQ     BTSTNEXTADDR
        BRA     BTSTGETENDDATA
BTSTNEXTADDR:
        MOVE.L  A1,A2   ;for subroutine
        SUB.L   #1,A3   ;off by one error
        JSR     ASCII_ADDRESS
        MOVE.L  D5,-(SP)    ;save data on the stack
        
        ADD.L   #1,A3   ;inc end ptr to first byte of address
        MOVE.L  A3,A2   ;set start ptr
BTSTGETENDADDRONE:
        CMP.B   #$20,(A3)+
        BEQ     BTSTNEXTADDRTWO
        BRA     BTSTGETENDADDRONE
        
BTSTNEXTADDRTWO:
        SUB.L   #1,A3   ;off by one error
        JSR     ASCII_ADDRESS   ;convert address to hex
        MOVE.L  D5,A5       ;store address 1 in A5
        MOVE.L  D5,A4       ;for second run through
              
        ADD.L   #1,A3   ;inc end ptr to first byte of address
        MOVE.L  A3,A2   ;set start ptr
BTSTGETLASTEND:
        CMP.B   #$00,(A3)+
        BEQ     STOREDATABTST
        BRA     BTSTGETLASTEND


STOREDATABTST:
        SUB.L   #1,A3   ;off by one error
        JSR     ASCII_ADDRESS
        MOVE.L  D5,A6   ;end address in A6
        MOVE.L  (SP)+,D5
        
BTSTDATALOOP:
        CMP.L   A5,A6
        BLT     READ
        MOVE.B  D5,(A5)+
        BRA     BTSTDATALOOP


READ:
        CMP.L   A4,A6
        BLT     COMPLETE
        CMP.B   (A4)+,D5
        BNE     FAIL
        BRA     READ
        
FAIL:
        LEA     BTST4,A1
        MOVE.L  #11,D1
        MOVE.L  #0,D0
        TRAP    #15
        
        LEA     BTST1,A1
        MOVE.L  #1,D0
        MOVE.L  #20,D1
        TRAP    #15
        
        MOVE.B  D5,D3   ;for subroutine
        JSR     HEXTOASCII
        MOVE.L     A2,A1
        MOVE.L  #0,D0
        SUBA.L  A2,A3   ;number of bytes
        MOVE.L  A3,D1
        TRAP    #15
        
        
        LEA     BTST2,A1
        MOVE.L  #1,D0
        MOVE.L  #17,D1
        TRAP    #15
        
        
        SUB.L   #1,A4   ;go back to address that failed
        MOVE.B  (A4),D3
        JSR     HEXTOASCII  ;convert for output
        MOVE.L     A2,A1
        MOVE.L  #0,D0
        SUBA.L  A2,A3   ;number of bytes
        MOVE.L  A3,D1
        TRAP    #15
        
        LEA     BTST5,A1
        MOVE.L  #27,D1
        MOVE.B  #1,D0
        TRAP    #15
        MOVE.L  A4,D3
        JSR     HEXTOASCII
        MOVE.L     A2,A1
        MOVE.L  #0,D0
        SUBA.L  A2,A3   ;number of bytes
        MOVE.L  A3,D1
        TRAP    #15


        
COMPLETE:

        LEA     BTST3,A1
        MOVE.L  #18,D1
        MOVE.L  #0,D0
        TRAP    #15
        BRA RESTORE

*--------------------------------------------------------------------------------------*

BSCH:   
        ADD.L   #1,A1   ;start of data
        MOVE.L  A1,A2   ;set up bac ptr
        
BSCHENDDATA:
        CMP.B   #$20,(A2)+
        BEQ     BSCHFIRSTADD
        BRA     BSCHENDDATA


BSCHFIRSTADD:
        SUB.L   #1,A2
        MOVE.L  A2,A3
        MOVE.L  A1,A2
        JSR     ASCII_ADDRESS
        SUB.L   A1,A3   ;see how many bytes
        MOVE.L  A3,D6   ;store byte/word/long in D6   
        ADD.L   #1,A2   ;set up for start of next address     
        MOVE.L  A2,A3   ;set up for end ptr
        MOVE.L  D5,-(SP)    ;save data to stack
        
        
BSCHFADDEND:
        CMP.B   #$20,(A3)+
        BEQ     BSCHSECONDADD
        BRA     BSCHFADDEND
        
        
BSCHSECONDADD:
        SUB.L   #1,A3   ;off by one
        JSR     ASCII_ADDRESS
        MOVE.L  D5,A5   ;first address destination
        ADD.L   #1,A3   ;start it at next address
        MOVE.L  A3,A2   ; set up for next address
        
        
BSCHSECONDFIND:
        CMP.B   #$00,(A3)+
        BEQ     TESTOP
        BRA     BSCHSECONDFIND
        
        
TESTOP: 
        SUB.L   #1,A3   ;off by one
        JSR     ASCII_ADDRESS
        MOVE.L  D5,A6   ;end address at A6
        MOVE.L  (SP)+,D5    ;restore data
        CMP.B   #2,D6
        BEQ     BYTEBSCH
        CMP.B   #4,D6
        BEQ     WORDBSCH
        CMP.B   #8,D6
        BEQ     LONGBSCH
        BRA     ERRORSR
        
BYTEBSCH:
        CMP.L   A5,A6
        BLT     ENDBSCH
        CMP.B   (A5)+,D5
        BEQ     FOUNDB
        BRA     BYTEBSCH

WORDBSCH:
        CMP.L   A5,A6
        BLT     ENDBSCH
        CMP.W   (A5)+,D5
        BEQ     FOUNDW
        BRA     WORDBSCH

LONGBSCH:
        CMP.L   A5,A6
        BLT     ENDBSCH
        CMP.L   (A5)+,D5
        BEQ     FOUNDL
        BRA     LONGBSCH



FOUNDB:
        SUB.L   #1,A5
        MOVE.B  (A5),D3
        BRA     SUCCESSTEXT
FOUNDW:
        SUB.L   #2,A5
        MOVE.W  (A5),D3
        BRA     SUCCESSTEXT
FOUNDL:
        SUB.L   #4,A5
        MOVE.L  (A5),D3
        
SUCCESSTEXT:
        LEA BSCH1,A1
        MOVE.L  #6,D1
        MOVE.L  #1,D0
        TRAP    #15

        JSR     HEXTOASCII
        MOVE.L  A2,A1
        SUB.L   A2,A3
        MOVE.L  A3,D1   ;how many bytes
        MOVE.L  #0,D0
        TRAP    #15
        
        LEA BSCH2,A1
        MOVE.L  #18,D1
        MOVE.L  #1,D0
        TRAP    #15
        
        MOVE.L  A5,D3
        JSR     HEXTOASCII
        MOVE.L  A2,A1
        SUB.L   A2,A3
        MOVE.L  A3,D1   ;how many bytes
        MOVE.L  #0,D0
        TRAP    #15

        
ENDBSCH:        
        BRA RESTORE

*--------------------------------------------------------------------------------------*

GO:    
        MOVE.L  A1,A2   ;setup for hex conversion
        MOVE.L  A2,A3   
GGETEND:
        CMP.B   #$00,(A3)+
        BEQ     EXECUTE
        BRA     GGETEND
        
EXECUTE:
        SUB.L   #1,A3   ;off by one error
        JSR     ASCII_ADDRESS
        MOVE.L  D5,A0   
        JSR     (A0)    ;go to program
        **NOTE: THE PROGRAM MUST HAVE RTS OR CONTROL WILL NOT BE RETURNED BACK TO MONITOR441!!!**
        BRA RESTORE

*--------------------------------------------------------------------------------------*

DF:    *Registers have already been saved to STACK, just need to pop them off first*
        *Stack looks like this*
        
        *-------------*
        *|D0-D7/A0-A6|*
        *|     USP   |*
        *|     SR    |*
        *|     SSP   |*
        *|     PC    |*
        *-------------*
        *I should've used loops for efficiency but runtime is not a design constraint*
        *Maybe fix this in the future?*
        
          *----------D0-----------*
       LEA      RD0,A1
       MOVE.L   #4,D1
       MOVE.L   #1,D0
       TRAP     #15
       MOVE.L   (SP)+,D3    
       JSR      HEXTOASCII
       MOVE.L   A2,A1
       SUB.L    A3,A2
       MOVE.L   A2,D2
       CMP.L    #-8,D2
       BEQ      D0DONTWORRY
D0ACCOUNTFORZEROS:
        ADDI.L  #8,D2
        SUB.L   D2,A1
D0DONTWORRY:
       MOVE.L   #0,D0
       MOVE.L   #8,D1
       TRAP     #15
       
           *----------D1-----------*
       LEA      RD1,A1
       MOVE.L   #4,D1
       MOVE.L   #1,D0
       TRAP     #15
       MOVE.L   (SP)+,D3    
       JSR      HEXTOASCII
       MOVE.L   A2,A1
       SUB.L    A3,A2
       MOVE.L   A2,D2
       CMP.L    #-8,D2
       BEQ      D1DONTWORRY
D1ACCOUNTFORZEROS:
        ADDI.L  #8,D2
        SUB.L   D2,A1
D1DONTWORRY:
       MOVE.L   #0,D0
       MOVE.L   #8,D1
       TRAP     #15
       
           *----------D2-----------*
       LEA      RD2,A1
       MOVE.L   #4,D1
       MOVE.L   #1,D0
       TRAP     #15
       MOVE.L   (SP)+,D3   
       JSR      HEXTOASCII
       MOVE.L   A2,A1
       SUB.L    A3,A2
       MOVE.L   A2,D2
       CMP.L    #-8,D2
       BEQ      D2DONTWORRY
D2ACCOUNTFORZEROS:
        ADDI.L  #8,D2
        SUB.L   D2,A1
D2DONTWORRY:
       MOVE.L   #0,D0
       MOVE.L   #8,D1
       TRAP     #15
       
            *----------D3-----------*
       LEA      RD3,A1
       MOVE.L   #4,D1
       MOVE.L   #1,D0
       TRAP     #15   
       MOVE.L   (SP)+,D3  
       JSR      HEXTOASCII
       MOVE.L   A2,A1
       SUB.L    A3,A2
       MOVE.L   A2,D2
       CMP.L    #-8,D2
       BEQ      D3DONTWORRY
D3ACCOUNTFORZEROS:
        ADDI.L  #8,D2
        SUB.L   D2,A1
D3DONTWORRY:
       MOVE.L   #0,D0
       MOVE.L   #8,D1
       TRAP     #15
       
            *----------D4-----------*
       LEA      RD4,A1
       MOVE.L   #4,D1
       MOVE.L   #1,D0
       TRAP     #15
       MOVE.L   (SP)+,D3    
       JSR      HEXTOASCII
       MOVE.L   A2,A1
       SUB.L    A3,A2
       MOVE.L   A2,D2
       CMP.L    #-8,D2
       BEQ      D4DONTWORRY
D4ACCOUNTFORZEROS:
        ADDI.L  #8,D2
        SUB.L   D2,A1
D4DONTWORRY:
       MOVE.L   #0,D0
       MOVE.L   #8,D1
       TRAP     #15
       
       *----------D5-----------*
       LEA      RD5,A1
       MOVE.L   #4,D1
       MOVE.L   #1,D0
       TRAP     #15
       MOVE.L   (SP)+,D3    
       JSR      HEXTOASCII
       MOVE.L   A2,A1
       SUB.L    A3,A2
       MOVE.L   A2,D2
       CMP.L    #-8,D2
       BEQ      D5DONTWORRY
D5ACCOUNTFORZEROS:
        ADDI.L  #8,D2
        SUB.L   D2,A1
D5DONTWORRY:
       MOVE.L   #0,D0
       MOVE.L   #8,D1
       TRAP     #15

        *----------D6-----------*
       LEA      RD6,A1
       MOVE.L   #4,D1
       MOVE.L   #1,D0
       TRAP     #15
       MOVE.L   (SP)+,D3    
       JSR      HEXTOASCII
       MOVE.L   A2,A1
       SUB.L    A3,A2
       MOVE.L   A2,D2
       CMP.L    #-8,D2
       BEQ      D6DONTWORRY
D6ACCOUNTFORZEROS:
        ADDI.L  #8,D2
        SUB.L   D2,A1
D6DONTWORRY:
       MOVE.L   #0,D0
       MOVE.L   #8,D1
       TRAP     #15
       
         *----------D7-----------*
       LEA      RD7,A1
       MOVE.L   #4,D1
       MOVE.L   #1,D0
       TRAP     #15
       MOVE.L   (SP)+,D3    
       JSR      HEXTOASCII
       MOVE.L   A2,A1
       SUB.L    A3,A2
       MOVE.L   A2,D2
       CMP.L    #-8,D2
       BEQ      D7DONTWORRY
D7ACCOUNTFORZEROS:
        ADDI.L  #8,D2
        SUB.L   D2,A1
D7DONTWORRY:
       MOVE.L   #0,D0
       MOVE.L   #8,D1
       TRAP     #15

   *----------A0-----------*
       LEA      RA0,A1
       MOVE.L   #4,D1
       MOVE.L   #1,D0
       TRAP     #15
       MOVE.L   (SP)+,D3    
       JSR      HEXTOASCII
       MOVE.L   A2,A1
       SUB.L    A3,A2
       MOVE.L   A2,D2
       CMP.L    #-8,D2
       BEQ      A0DONTWORRY
A0ACCOUNTFORZEROS:
        ADDI.L  #8,D2
        SUB.L   D2,A1
A0DONTWORRY:
       MOVE.L   #0,D0
       MOVE.L   #8,D1
       TRAP     #15
       
          *----------A1-----------*
       LEA      RA1,A1
       MOVE.L   #4,D1
       MOVE.L   #1,D0
       TRAP     #15
       MOVE.L   (SP)+,D3    
       JSR      HEXTOASCII
       MOVE.L   A2,A1
       SUB.L    A3,A2
       MOVE.L   A2,D2
       CMP.L    #-8,D2
       BEQ      A1DONTWORRY
A1ACCOUNTFORZEROS:
        ADDI.L  #8,D2
        SUB.L   D2,A1
A1DONTWORRY:
       MOVE.L   #0,D0
       MOVE.L   #8,D1
       TRAP     #15
       
        *----------A2-----------*
       LEA      RA2,A1
       MOVE.L   #4,D1
       MOVE.L   #1,D0
       TRAP     #15
       MOVE.L   (SP)+,D3    
       JSR      HEXTOASCII
       MOVE.L   A2,A1
       SUB.L    A3,A2
       MOVE.L   A2,D2
       CMP.L    #-8,D2
       BEQ      A2DONTWORRY
A2ACCOUNTFORZEROS:
        ADDI.L  #8,D2
        SUB.L   D2,A1
A2DONTWORRY:
       MOVE.L   #0,D0
       MOVE.L   #8,D1
       TRAP     #15
       
         *----------A3-----------*
       LEA      RA3,A1
       MOVE.L   #4,D1
       MOVE.L   #1,D0
       TRAP     #15
       MOVE.L   (SP)+,D3    
       JSR      HEXTOASCII
       MOVE.L   A2,A1
       SUB.L    A3,A2
       MOVE.L   A2,D2
       CMP.L    #-8,D2
       BEQ      A3DONTWORRY
A3ACCOUNTFORZEROS:
        ADDI.L  #8,D2
        SUB.L   D2,A1
A3DONTWORRY:
       MOVE.L   #0,D0
       MOVE.L   #8,D1
       TRAP     #15
       
        *----------A4-----------*
       LEA      RA3,A1
       MOVE.L   #4,D1
       MOVE.L   #1,D0
       TRAP     #15
       MOVE.L   (SP)+,D3    
       JSR      HEXTOASCII
       MOVE.L   A2,A1
       SUB.L    A3,A2
       MOVE.L   A2,D2
       CMP.L    #-8,D2
       BEQ      A4DONTWORRY
A4ACCOUNTFORZEROS:
        ADDI.L  #8,D2
        SUB.L   D2,A1
A4DONTWORRY:
       MOVE.L   #0,D0
       MOVE.L   #8,D1
       TRAP     #15
       
       *----------A5-----------*
       LEA      RA3,A1
       MOVE.L   #4,D1
       MOVE.L   #1,D0
       TRAP     #15
       MOVE.L   (SP)+,D3    
       JSR      HEXTOASCII
       MOVE.L   A2,A1
       SUB.L    A3,A2
       MOVE.L   A2,D2
       CMP.L    #-8,D2
       BEQ      A5DONTWORRY
A5ACCOUNTFORZEROS:
        ADDI.L  #8,D2
        SUB.L   D2,A1
A5DONTWORRY:
       MOVE.L   #0,D0
       MOVE.L   #8,D1
       TRAP     #15
       
       *----------A6-----------*
       LEA      RA3,A1
       MOVE.L   #4,D1
       MOVE.L   #1,D0
       TRAP     #15
       MOVE.L   (SP)+,D3    
       JSR      HEXTOASCII
       MOVE.L   A2,A1
       SUB.L    A3,A2
       MOVE.L   A2,D2
       CMP.L    #-8,D2
       BEQ      A6DONTWORRY
A6ACCOUNTFORZEROS:
        ADDI.L  #8,D2
        SUB.L   D2,A1
A6DONTWORRY:
       MOVE.L   #0,D0
       MOVE.L   #8,D1
       TRAP     #15
     *-----HACK---*
     ADD.L  #60,SP  ;should put stack in correct place
     
              *----------USP-----------*
       LEA      RUS,A1
       MOVE.L   #4,D1
       MOVE.L   #1,D0
       TRAP     #15
       MOVE.L   (SP)+,D3    
       JSR      HEXTOASCII
       MOVE.L   A2,A1
       SUB.L    A3,A2
       MOVE.L   A2,D2
       CMP.L    #-8,D2
       BEQ      USPDONTWORRY
USPACCOUNTFORZEROS:
        ADDI.L  #8,D2
        SUB.L   D2,A1
USPDONTWORRY:
       MOVE.L   #0,D0
       MOVE.L   #8,D1
       TRAP     #15

              *----------SR-----------*
       LEA      RSR,A1
       MOVE.L   #4,D1
       MOVE.L   #1,D0
       TRAP     #15
       MOVE.W   (SP)+,D3
       MOVE.W   D3,D7   ;temp storage to restore before return    
       JSR      HEXTOASCII
       MOVE.L   A2,A1
       SUB.L    A3,A2
       MOVE.L   A2,D2
       CMP.L    #-4,D2
       BEQ      SRDONTWORRY
SRACCOUNTFORZEROS:
        ADDI.L  #4,D2
        SUB.L   D2,A1
SRDONTWORRY:
       MOVE.L   #0,D0
       MOVE.L   #4,D1
       TRAP     #15
       
    *----------SS/A7-----------*
       LEA      RSS,A1
       MOVE.L   #7,D1
       MOVE.L   #1,D0
       TRAP     #15
       MOVE.L   (SP)+,D3    
       JSR      HEXTOASCII
       MOVE.L   A2,A1
       SUB.L    A3,A2
       MOVE.L   A2,D2
       CMP.L    #-8,D2
       BEQ      SSDONTWORRY
SSACCOUNTFORZEROS:
        ADDI.L  #8,D2
        SUB.L   D2,A1
SSDONTWORRY:
       MOVE.L   #0,D0
       MOVE.L   #8,D1
       TRAP     #15
       
    *----------PC-----------*
       LEA      RPC,A1
       MOVE.L   #4,D1
       MOVE.L   #1,D0
       TRAP     #15
       MOVE.L   (SP)+,D3    
       JSR      HEXTOASCII
       MOVE.L   A2,A1
       SUB.L    A3,A2
       MOVE.L   A2,D2
       CMP.L    #-8,D2
       BEQ      PCDONTWORRY
PCACCOUNTFORZEROS:
        ADDI.L  #8,D2
        SUB.L   D2,A1
PCDONTWORRY:
       MOVE.L   #0,D0
       MOVE.L   #8,D1
       TRAP     #15       
       
   *---DF HACK RESTORE---*
   MOVE.W   D7,-(SP)
   ADD.L    #-72,SP
   MOVEM.L  (SP)+,D0-D7/A0-A6
   ADD.L    #12,SP  ;go back to original value
   MOVE.W   (SP)+,SR
        
       BRA SHELL

*--------------------------------------------------------------------------------------*


************************************EXCEPTIONS!*****************************************
*--------------------------------------------------------------------------------------*

BERR:
        MOVEM.L A1-A3/D0-D1,-(SP)
        LEA     BERR_TEXT,A1
        MOVE.L  #13,D0
        TRAP    #15
        LEA     SSW,A1
        MOVE.L  #14,D0
        TRAP    #15
        MOVE.W  (20,SP),D3
        JSR     HEXTOASCII
        SUB.L   #4,A3
        MOVEA.L A3,A1
        MOVE.L  #4,D1
        MOVE.L  #0,D0
        TRAP    #15
        LEA     BA,A1
        MOVE.L  #14,D0
        TRAP    #15
        MOVE.L  (22,SP),D3
        JSR     HEXTOASCII
        SUB.L   #8,A3
        MOVEA.L A3,A1
        MOVE.L  #8,D1
        MOVE.L  #0,D0
        TRAP    #15
        LEA     IR,A1
        MOVE.L  #14,D0
        TRAP    #15
        MOVE.W  (26,SP),D3
        JSR     HEXTOASCII
        SUB.L   #4,A3
        MOVEA.L A3,A1
        MOVE.L  #4,D1
        MOVE.L  #0,D0
        TRAP    #15
        MOVEM.L (SP)+,A1-A3/D0-D1
        MOVE.L  #$01000000,SP   ;reset stack
        BRA     SHELL

AERR:
        MOVEM.L A1-A3/D0-D1,-(SP)
        LEA     AERR_TEXT,A1
        MOVE.L  #13,D0
        TRAP    #15
        LEA     SSW,A1
        MOVE.L  #14,D0
        TRAP    #15
        MOVE.W  (20,SP),D3
        JSR     HEXTOASCII
        SUB.L   #4,A3
        MOVEA.L A3,A1
        MOVE.L  #4,D1
        MOVE.L  #0,D0
        TRAP    #15
        LEA     BA,A1
        MOVE.L  #14,D0
        TRAP    #15
        MOVE.L  (22,SP),D3
        JSR     HEXTOASCII
        SUB.L   #8,A3
        MOVEA.L A3,A1
        MOVE.L  #8,D1
        MOVE.L  #0,D0
        TRAP    #15
        LEA     IR,A1
        MOVE.L  #14,D0
        TRAP    #15
        MOVE.W  (26,SP),D3
        JSR     HEXTOASCII
        SUB.L   #4,A3
        MOVEA.L A3,A1
        MOVE.L  #4,D1
        MOVE.L  #0,D0
        TRAP    #15
        MOVEM.L (SP)+,A1-A3/D0-D1
        MOVE.L  #$01000000,SP   ;reset stack
        BRA     SHELL

IERR:
    MOVEM.L A1/D0,-(SP)
    LEA IERR_TEXT,A1
    MOVE.L #13,D0
    TRAP #15
    MOVEM.L (SP)+,A1/D0
    MOVE.L #$01000000,SP
    BRA SHELL

PERR:
    MOVEM.L A1/D0,-(SP)
    LEA PERR_TEXT,A1
    MOVE.L #13,D0
    TRAP #15
    MOVEM.L (SP)+,A1/D0
    MOVE.L #$01000000,SP
    BRA SHELL
    
ZERR:
    MOVEM.L A1/D0,-(SP)
    LEA ZERR_TEXT,A1
    MOVE.L #13,D0
    TRAP #15
    MOVEM.L (SP)+,A1/D0
    MOVE.L #$01000000,SP
    BRA SHELL

ALERR:
    MOVEM.L A1/D0,-(SP)
    LEA ALERR_TEXT,A1
    MOVE.L #13,D0
    TRAP #15
    MOVEM.L (SP)+,A1/D0
    MOVE.L #$01000000,SP
    BRA SHELL
    
FLERR:
    MOVEM.L A1/D0,-(SP)
    LEA FLERR_TEXT,A1
    MOVE.L #13,D0
    TRAP #15
    MOVEM.L (SP)+,A1/D0
    MOVE.L #$01000000,SP
    BRA SHELL
    
CHKERR:
    MOVEM.L A1/D0,-(SP)
    LEA CHKERR_TEXT,A1
    MOVE.L #13,D0
    TRAP #15
    MOVEM.L (SP)+,A1/D0
    MOVE.L #$01000000,SP
    BRA SHELL



****************************COMMON SUBROUTINES NEEDED**********************************


*--------------------------------------------------------------------------------------*
ERRORSR:        LEA   ERROR,A1    ;load message
                MOVE.W  #44,D1
                MOVE.L  #0,D0
                TRAP    #15
                BRA     RESTORE
*--------------------------------------------------------------------------------------*
ASCII_TO_BCD:   *Number passed via D3 byte size only(to be expected)*
                CMP #$46,D3
                BGT ERRORSR
                CMP #$40,D3
                BGT UPPER
                SUBI.L  #$30,D3
                RTS
UPPER:          SUBI.L  #$31,D3 ;If ASCII number is A-F
                RTS
*--------------------------------------------------------------------------------------*

BCD_TO_HEX:     *Number passed via D3 accepts BYTE ONLY*
                MOVE.L  D3,D4   
                MOVE.L  D3,D5
                ANDI.L  #240,D4 ;upper byte
                ANDI.L  #15,D5  ;lower byte
                ROR.L   #4,D4   ;get bits into correct place
                MULU    #10,D4  ;multiply by its tens place
                CLR.L   D3
                ADD.L   D4,D3
                ADD.L   D5,D3
                RTS
*--------------------------------------------------------------------------------------*                
ASCII_ADDRESS:   *Address to be converted from ascii to hex passed through A2 and A3*
                 *Returned in D5                                                    *
                CLR.L   D3
                CLR.L   D5
                MOVE.L   A2,D1
                MOVE.L   A3,D0
                SUB.L   D1,D0   ;store the difference in D0
                MOVE.L  #0,D4   ;set up 10's place counter
                SUBI.L  #1,D0
PLACECOUNTER:   CMP     #0,D0
                BEQ     CONVERTADDRESS
                ADDI.L  #4,D4
                SUBI.L  #1,D0
                BRA     PLACECOUNTER
CONVERTADDRESS  CMP     A2,A3
                BEQ     ADDRESSDONE
                CLR.L   D3
                MOVE.B  (A2)+,D3
                MOVEM.L A2-A3/D0-D2/D4-D5,-(SP)   ;so regs dont get destroyed
                JSR     ASCII_TO_BCD
                JSR     BCD_TO_HEX
                MOVEM.L (SP)+,A2-A3/D0-D2/D4-D5
                ROL.L     D4,D3
                SUBI.L  #4,D4
                ADD.L     D3,D5   ;get total
                BRA     CONVERTADDRESS
ADDRESSDONE     RTS

*--------------------------------------------------------------------------------------*
HEXTOASCII: *Result returned in address buffer from A2 to A3, HEX number passed*
            *through D3*
            CLR.L   D4
            CLR.L   D5
            MOVE.L  #$3A00,A2
            MOVE.L  #$3A32,A3
KEEP_CONVERTING:
            MOVE.B  D3,D4  
            MOVE.B  D3,D5 
            LSR.L   #8,D3   ;prepare for next byte
            ANDI.L  #15,D4   ;get lower byte
            ANDI.L  #240,D5 ;get upper byte'
            ROR     #4,D5   ;move D5 into position
            CMP.B     #$9,D4
            BGT     A_TO_F
            ADDI.L  #$30,D4
            BRA     NEXTHEX
A_TO_F:     ADDI.L  #$37,D4
NEXTHEX:    CMP.B     #$9,D5
            BGT     A_TO_F2
            ADDI.L  #$30,D5
            BRA     PUTBUFFER
A_TO_F2:    ADDI.L  #$37,D5
PUTBUFFER:  MOVE.B  D4,-(A3)
            MOVE.B  D5,-(A3)
            CMP      A2,A3
            BNE      KEEP_CONVERTING
RID_ZEROS:  CMP.B   #$30,(A2)
            BEQ     ADD
            BRA     HEXASCIIDONE
ADD:        ADD.L   #1,A2   ;increment to find start of string
            BRA     RID_ZEROS
HEXASCIIDONE:   
            MOVE.L  #$3A32,A3    ;end of original number
            CMP.L   A2,A3
            BEQ     ZEROS
            BRA     NOTZEROS
ZEROS       SUB.L   #8,A2               
NOTZEROS    RTS
*--------------------------------------------------------------------------------------*
UNKNOWNCMD:     LEA   ERROR1,A1    ;load message
                MOVE.W  #21,D1
                MOVE.L  #0,D0
                TRAP    #15
                BRA     RESTORE


NEXT:   ;for debugging single commands
            
            
            
            


       END    START        
















*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~

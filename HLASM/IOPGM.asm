***********************************************************************
* Equates                                                             *
***********************************************************************
R0       EQU   0
R1       EQU   1
R2       EQU   2
R3       EQU   3
R4       EQU   4
R5       EQU   5
R6       EQU   6
R7       EQU   7
R8       EQU   8
R9       EQU   9
R10      EQU   10
R11      EQU   11
R12      EQU   12
R13      EQU   13
R14      EQU   14
R15      EQU   15
RA       EQU   10                       ADD EQUATION FOR GR10
RB       EQU   11                       ADD EQUATION FOR GR11
RC       EQU   12                       ADD EQUATION FOR GR12
RD       EQU   13                       ADD EQUATION FOR GR13
RE       EQU   14                       ADD EQUATION FOR GR14
RF       EQU   15                       ADD EQUATION FOR GR15
***********************************************************************
* DSECTS                                                              *
***********************************************************************
***********************************************************************
*CSECT                                                                *
***********************************************************************
IOPGM    CSECT
IOPGM    AMODE 31                      we are 31 bit
IOPGM    RMODE 24                      But reside below the line
         STM   R14,R12,12(R13)         Save register in caller SA
         LR    R12,R15                 address ourseleves
         USING IOPGM,R12               set up our own addressability
                                  SPACE
         LA    R15,SAVEAREA            OUR SAVE AREA
         ST    R13,4(,R15)             CALLERS SA@ IN OUR SA
         ST    R15,8(,R13)             OUR SA@ IN CALLERS SA
         LR    R13,R15                 OUR SA@ IN R13
***********************************************************************
MAIN     DS    0H
         OPEN  (SYSIN,INPUT)           OPEN input Dataset
         OPEN  (SYSOUT,OUTPUT)         OPEN output  DATASET
RE_LOOP  EQU *
         GET   SYSIN,I_BUFR           Read record into Bufffer
         CLC   I_BUFR,=CL80'END'      check END?
         BE    CL_FILE                yes close file
         MVC   O_BUFR,I_BUFR          Move record bw buffer
         PUT   SYSOUT,O_BUFR          Write buffer
         B     RE_LOOP
CL_FILE  EQU *
         CLOSE (SYSIN)               CLOSE INPUT DATASET
         CLOSE (SYSOUT)              CLOSE OUTPUT DATASET
         SPACE ,
***********************************************************************
* Restore registers to callers savearea                               *
***********************************************************************
END      L     R13,SAVEAREA+4
         LM    14,12,12(R13)
         LA    15,00(0,0)
         BR    14
***********************************************************************
*ERROR ROUTINES                                                       *
***********************************************************************
*Contents and literals                                                *
***********************************************************************
SYSIN    DCB   DDNAME=SYSIN,                                           X
               DSORG=PS,MACRF=(GM),RECFM=FB,LRECL=80,EODAD=CL_FILE
SYSOUT   DCB   DDNAME=SYSOUT,                                          X
               DSORG=PS,MACRF=(PM),RECFM=FB,LRECL=80
I_BUFR   DS   CL80                Define buffer for reading
O_BUFR   DS   CL80                     Define buffer for output
SAVEAREA DS 18F
        LTORG ,
        END

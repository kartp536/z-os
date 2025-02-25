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
         CSVAPFAA ,                     CSVAPF ANSWER AREA MAP
***********************************************************************
*CSECT                                                                *
***********************************************************************
APFPGM   CSECT
APFPGM   AMODE   31           we are 31 bit
APFPGM   RMODE   24           But reside below the line
         STM R14,R12,12(R13)  Save register in caller SA
         LR  R12,R15          address ourseleves
         USING APFPGM,R12       set up our own addressability
                                  SPACE
         LA    R15,SAVEAREA             OUR SAVE AREA
         ST    R13,4(,R15)              CALLERS SA@ IN OUR SA
         ST    R15,8(,R13)              OUR SA@ IN CALLERS SA
         LR    R13,R15                  OUR SA@ IN R13
***********************************************************************
MAIN     DS   0H
         OPEN  (SYSPRINT,OUTPUT)        OPEN SYSPRINT DATASET
         CSVAPF REQUEST=QUERYFORMAT,FORMAT=DOUBLE
         MVC TITLINE1+25(7),=CL7'DYNAMIC'
         CLI DOUBLE,1
         BE  *+4+6
         MVC   TITLINE1+25(7),=CL7'STATIC'
         PUT   SYSPRINT,TITLINE1
         PUT   SYSPRINT,TITLINE2
         PUT   SYSPRINT,TITLINE3
         SPACE ,
         USING APFHDR,HDRAREA
         CSVAPF REQUEST=LIST,ANSAREA=HDRAREA,ANSLEN=LDRAREA
         STCM  RF,B'0011',DOUBLE
         STCM  R0,B'0011',DOUBLE+2
         CLC   DOUBLE(4),=XL4'00040403' INSUFFICIENT STORAGE ?
         BNE   EXIT12                   NO, ABORT PROCESSING(CC=12)
         SPACE ,
         L     R0,APFHTLEN              LOAD ANSWER AREA LENGTH NEEDED
         GETMAIN RU,LV=(0),LOC=ANY
         LR     R6,R1
         CSVAPF REQUEST=LIST,ANSAREA=(6),ANSLEN=APFHTLEN
         L      R7,APFHOFF-APFHDR(,R6)   LOAD 1ST ENTRY OFFSET
         ALR   R7,R6                    LOCATE TO APF 1ST ENTRY
         USING APFE,R7                  ADDRESS IT
         L     R8,APFH#REC-APFHDR(,R6)  LOAD NUM OF APF ENTRIES
         LA    R9,1                     SET SEQUENCE NUMBER
PRNTLIST DS    0H
         CVD   R9,DOUBLE                SET SEQ#
         UNPK  SEQ#,DOUBLE               I
         OI    SEQ#+3,C'0'               V
         MVC   VOL,APFEVOLUME           SET VOLUME NAME
         MVC   DSN,APFEDSNAME           SET DATASET NAME
         AH    R7,APFELEN               LOCATE TO NEXT ENTRY
         PUT   SYSPRINT,OUTLINE1        PRINT DEVICE DATA LINE
         LA    R9,1(,R9)                INCREMENT SEQ#
         BCT   R8,PRNTLIST              LOOP FOR NEXT APF ENTRY
         SPACE ,
         L     R0,APFHTLEN              LOAD ANSWER AREA LENGTH NEEDED
         FREEMAIN RU,LV=(0),A=(6)       RELEASE ANSWER AREA STORAGE
         CLOSE (SYSPRINT)               CLOSE SYSPRINT DATASET
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
EXIT0    DS    0H
         SLR   15,15                    LOAD RETURN CODE = 0
         B     END                 DO EXIT PROCESSING
EXIT12   DS    0H
         LA    15,12                    LOAD RETURN CODE = 12
         B     END                 DO EXIT PROCESSING
         EJECT ,
***********************************************************************
*Contents and literals                                                *
***********************************************************************
DOUBLE   DS D'0'
HDRAREA  DC (APFHDR_LEN)X'00'        APFLIST HEADER AREA
LDRAREA  DC    A(APFHDR_LEN)            AREA LENGTH
TITLINE1 DC CL80'APF LIBRARY LIST, FORMAT=@@@@@@@'
TITLINE2 DC CL80'SEQ# VOLUME DSN'
TITLINE3 DC CL80'===================================================='
OUTLINE1 DC    CL80'@@@@ @@@@@@ @'
SEQ#     EQU   OUTLINE1+0,4
VOL      EQU   OUTLINE1+5,6
DSN      EQU   OUTLINE1+12,44
         SPACE ,
SYSPRINT DCB   DDNAME=SYSPRINT,                                        X
               DSORG=PS,MACRF=(PM),RECFM=FB,LRECL=80
SAVEAREA DS 18F
        LTORG ,
        END

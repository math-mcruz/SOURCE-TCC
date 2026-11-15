       PROCESS CICS,NODYNAM,NSYMBOL(NATIONAL),TRUNC(STD)
       CBL CICS('SP,EDF')
       CBL SQL

       IDENTIFICATION DIVISION.
       PROGRAM-ID. XFRFUN.
       AUTHOR. Jon Collett.

       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER.  IBM-370.
       OBJECT-COMPUTER.  IBM-370.

       INPUT-OUTPUT SECTION.

       DATA DIVISION.
       WORKING-STORAGE SECTION.


       COPY SORTCODE.


           EXEC SQL
             INCLUDE ACCDB2
           END-EXEC.

       01 HOST-ACCOUNT-ROW.
          03 HV-ACCOUNT-EYECATCHER      PIC X(4).
          03 HV-ACCOUNT-CUST-NO         PIC X(10).
          03 HV-ACCOUNT-KEY.
             05 HV-ACCOUNT-SORTCODE     PIC X(6).
             05 HV-ACCOUNT-ACC-NO       PIC X(8).
          03 HV-ACCOUNT-ACC-TYPE        PIC X(8).
          03 HV-ACCOUNT-INT-RATE        PIC S9(4)V99 COMP-3.
          03 HV-ACCOUNT-OPENED          PIC X(10).
          03 HV-ACCOUNT-OVERDRAFT-LIM   PIC S9(9) COMP.
          03 HV-ACCOUNT-LAST-STMT       PIC X(10).
          03 HV-ACCOUNT-NEXT-STMT       PIC X(10).
          03 HV-ACCOUNT-AVAIL-BAL       PIC S9(10)V99 COMP-3.
          03 HV-ACCOUNT-ACTUAL-BAL      PIC S9(10)V99 COMP-3.

          EXEC SQL
             INCLUDE PROCDB2
          END-EXEC.

       01 HOST-PROCTRAN-ROW.
          03 HV-PROCTRAN-EYECATCHER     PIC X(4).
          03 HV-PROCTRAN-SORT-CODE      PIC X(6).
          03 HV-PROCTRAN-ACC-NUMBER     PIC X(8).
          03 HV-PROCTRAN-DATE           PIC X(10).
          03 HV-PROCTRAN-TIME           PIC X(6).
          03 HV-PROCTRAN-REF            PIC X(12).
          03 HV-PROCTRAN-TYPE           PIC X(3).
          03 HV-PROCTRAN-DESC           PIC X(40).
          03 HV-PROCTRAN-AMOUNT         PIC S9(10)V99 COMP-3.

        EXEC SQL
          INCLUDE SQLCA
        END-EXEC.

       01 WS-CICS-WORK-AREA.
          05 WS-CICS-RESP               PIC S9(8) COMP.
          05 WS-CICS-RESP2              PIC S9(8) COMP.


       LOCAL-STORAGE SECTION.
       01 SYSIDERR-RETRY                PIC 999.
       01 FILE-RETRY                    PIC 999.
       01 WS-EXIT-RETRY-LOOP            PIC X         VALUE ' '.
       01 DB2-DEADLOCK-RETRY            PIC 999.

       01 DB2-DATE-REFORMAT.
          03 DB2-DATE-REF-YR            PIC 9(4).
          03 FILLER                     PIC X.
          03 DB2-DATE-REF-MNTH          PIC 99.
          03 FILLER                     PIC X.
          03 DB2-DATE-REF-DAY           PIC 99.


       01 WS-ACC-DATA.
          COPY ACCOUNT.

       01 WS-ACC-DATA2.
          COPY ACCOUNT REPLACING "ACCOUNT" BY "ACCOUNT2".

       01 WS-EIBTASKN12                 PIC 9(12)     VALUE 0.
       01 WS-SQLCODE-DISP               PIC 9(9)      VALUE 0.


       01 DESIRED-ACC-KEY.
          03 DESIRED-SORT-CODE          PIC 9(6).
          03 DESIRED-ACC-NO             PIC 9(8).


       01 NEW-ACCOUNT-AVAILABLE-BALANCE PIC S9(10)V99 VALUE 0.
       01 NEW-ACCOUNT-ACTUAL-BALANCE    PIC S9(10)V99 VALUE 0.
       01 WS-ACC-REC-LEN                PIC S9(4) COMP
                                                      VALUE 0.

       01 NEW-ACCOUNT-AVAILABLE-BALANCE2
                                        PIC S9(10)V99 VALUE 0.
       01 NEW-ACCOUNT-ACTUAL-BALANCE2   PIC S9(10)V99 VALUE 0.
       01 WS-ACC-REC-LEN2               PIC S9(4) COMP
                                                      VALUE 0.

       01 WS-U-TIME                     PIC S9(15) COMP-3.
       01 WS-ORIG-DATE                  PIC X(10).
       01 WS-ORIG-DATE-GRP REDEFINES WS-ORIG-DATE.
          03 WS-ORIG-DATE-DD            PIC 99.
          03 FILLER                     PIC X.
          03 WS-ORIG-DATE-MM            PIC 99.
          03 FILLER                     PIC X.
          03 WS-ORIG-DATE-YYYY          PIC 9999.

       01 WS-ORIG-DATE-GRP-X.
          03 WS-ORIG-DATE-DD-X          PIC XX.
          03 FILLER                     PIC X         VALUE '.'.
          03 WS-ORIG-DATE-MM-X          PIC XX.
          03 FILLER                     PIC X         VALUE '.'.
          03 WS-ORIG-DATE-YYYY-X        PIC X(4).

       01 REJ-REASON                    PIC XX        VALUE SPACES.

       01 PROCTRAN-AREA.
          COPY PROCTRAN.

       01 REJTRAN-RIDFLD                PIC S9(8) COMP.
       01 PROCTRAN-RIDFLD               PIC S9(8) COMP.

       01 WS-REJ-REAS.
          03 WS-REASON-TEXT             PIC X(26)     VALUE SPACES.
          03 WS-TO-ACC                  PIC 9(14) DISPLAY
                                                      VALUE 0.

       01 WS-PROC-REAS.
          03 WS-PROC-TEXT               PIC X(26)     VALUE SPACES.
          03 WS-PROC-TO                 PIC 9(14) DISPLAY
                                                      VALUE 0.
       01 WS-TESTING-DB-NAME.
          03 WS-TESTING-TYPE            PIC X(9)      VALUE 'STTESTER.'.
          03 WS-TESTING-TABLE-NAME      PIC X(4)      VALUE 'PLOP'.

       01 WS-SQLCODE1                   PIC 9(15).

       EXEC SQL INCLUDE SQLDA END-EXEC.

       01 STMTBUF.
          49 STMTLEN                    PIC S9(4) COMP
                                                      VALUE +78.
          49 STMTTXT                    PIC X(78).

       01 STMTBUF2.
          49 STMTLEN2                   PIC S9(4) COMP
                                                      VALUE +81.
          49 STMTTXT2                   PIC X(81).

       01 DISP-LOT.
          03 DISP-SIGN                  PIC X.
          03 DISP-SQLCD                 PIC 9999.

       01 WS-WANTED.
          03 VAR-LEN                    PIC S9(4) COMP
                                                      VALUE +78.
          03 VAR-TXT                    PIC X(78).

       01 WS-WANTED2.
          03 VAR-LEN2                   PIC S9(4) COMP
                                                      VALUE +81.
          03 VAR-TXT2                   PIC X(81).

       01 WS-INPUT-TAB-NAME             PIC X(4).
       01 WS-INPUT-TAB-NAME2            PIC X(7).

       01 WS-PASSED-DATA.
          02 WS-TEST-KEY                PIC X(4).
          02 WS-SORT-CODE               PIC 9(6).
          02 WS-CUSTOMER-RANGE.
             07 WS-CUSTOMER-RANGE-TOP   PIC X.
             07 WS-CUSTOMER-RANGE-MIDDLE
                                        PIC X.
             07 WS-CUSTOMER-RANGE-BOTTOM
                                        PIC X.
       01 MY-ABEND-CODE                 PIC XXXX.

       01 WS-STORM-DRAIN                PIC X         VALUE 'N'.
       01 STORM-DRAIN-CONDITION         PIC X(20).

       01 SQLCODE-DISPLAY               PIC S9(8) DISPLAY
             SIGN LEADING SEPARATE.

       01 NUMERIC-AMOUNT-DISPLAY        PIC +9(10).99.

       01 WS-TIME-DATA.
          03 WS-TIME-NOW                PIC 9(6).
          03 WS-TIME-NOW-GRP REDEFINES WS-TIME-NOW.
             05 WS-TIME-NOW-GRP-HH      PIC 99.
             05 WS-TIME-NOW-GRP-MM      PIC 99.
             05 WS-TIME-NOW-GRP-SS      PIC 99.

       01 WS-ABEND-PGM                  PIC X(8)      VALUE 'ABNDPROC'.

       01 ABNDINFO-REC.
           COPY ABNDINFO.

       LINKAGE SECTION.

       01 DFHCOMMAREA.
           COPY XFRFUN.


       PROCEDURE DIVISION USING DFHCOMMAREA.
       PREMIERE SECTION.
       A010.

           EXEC CICS HANDLE ABEND
              LABEL(ABEND-HANDLING)
           END-EXEC.

           MOVE '0' TO HV-ACCOUNT-EYECATCHER.
           MOVE '0' TO HV-ACCOUNT-SORTCODE.
           MOVE '0' TO HV-ACCOUNT-ACC-NO.
           MOVE  0  TO DB2-DEADLOCK-RETRY.

           MOVE SORTCODE TO COMM-FSCODE COMM-TSCODE.

           MOVE SORTCODE TO DESIRED-SORT-CODE.

           IF COMM-AMT <= ZERO
             MOVE 'N' TO COMM-SUCCESS
             MOVE '4' TO COMM-FAIL-CODE
             PERFORM GET-ME-OUT-OF-HERE
           END-IF.

           PERFORM UPDATE-ACCOUNT-DB2

           PERFORM GET-ME-OUT-OF-HERE.

       A999.
           EXIT.


       UPDATE-ACCOUNT-DB2 SECTION.
       UAD010.

           MOVE 'N' TO COMM-SUCCESS.
           IF COMM-FACCNO = COMM-TACCNO
              AND COMM-FSCODE = COMM-TSCODE
              INITIALIZE ABNDINFO-REC
              MOVE EIBRESP    TO ABND-RESPCODE
              MOVE EIBRESP2   TO ABND-RESP2CODE
              EXEC CICS ASSIGN APPLID(ABND-APPLID)
              END-EXEC

              MOVE EIBTASKN   TO ABND-TASKNO-KEY
              MOVE EIBTRNID   TO ABND-TRANID

              PERFORM POPULATE-TIME-DATE

              MOVE WS-ORIG-DATE TO ABND-DATE
              STRING WS-TIME-NOW-GRP-HH DELIMITED BY SIZE,
                    ':' DELIMITED BY SIZE,
                    WS-TIME-NOW-GRP-MM DELIMITED BY SIZE,
                    ':' DELIMITED BY SIZE,
                    WS-TIME-NOW-GRP-MM DELIMITED BY SIZE
                    INTO ABND-TIME
              END-STRING

              MOVE WS-U-TIME   TO ABND-UTIME-KEY
              MOVE 'SAME'      TO ABND-CODE

              EXEC CICS ASSIGN PROGRAM(ABND-PROGRAM)
              END-EXEC

              MOVE ZEROS      TO ABND-SQLCODE

              STRING 'UAD010 - Cannot transfer to the same account '
                   DELIMITED BY SIZE,
                   ' EIBRESP=' DELIMITED BY SIZE,
                   ABND-RESPCODE DELIMITED BY SIZE,
                   ' RESP2=' DELIMITED BY SIZE,
                   ABND-RESP2CODE DELIMITED BY SIZE
                   INTO ABND-FREEFORM
              END-STRING

              EXEC CICS LINK PROGRAM(WS-ABEND-PGM)
                       COMMAREA(ABNDINFO-REC)
              END-EXEC

              DISPLAY 'Cannot transfer to the same account'

              EXEC CICS ABEND
                 ABCODE('SAME')
                 NODUMP
                 CANCEL
              END-EXEC

           END-IF.

           IF COMM-FACCNO < COMM-TACCNO
              MOVE COMM-FACCNO TO DESIRED-ACC-NO
              MOVE COMM-FSCODE TO DESIRED-SORT-CODE

              PERFORM UPDATE-ACCOUNT-DB2-FROM

              IF COMM-SUCCESS = 'Y'
                 MOVE COMM-TACCNO TO DESIRED-ACC-NO
                 MOVE COMM-TSCODE TO DESIRED-SORT-CODE

                 PERFORM UPDATE-ACCOUNT-DB2-TO

                 IF COMM-SUCCESS = 'N'

                    IF COMM-FAIL-CODE = '2'
                       EXEC CICS SYNCPOINT
                          ROLLBACK
                          RESP(WS-CICS-RESP)
                          RESP2(WS-CICS-RESP2)
                       END-EXEC

                       IF WS-CICS-RESP IS NOT EQUAL TO DFHRESP(NORMAL)
                          INITIALIZE ABNDINFO-REC
                          MOVE EIBRESP    TO ABND-RESPCODE
                          MOVE EIBRESP2   TO ABND-RESP2CODE
                          EXEC CICS ASSIGN APPLID(ABND-APPLID)
                          END-EXEC

                          MOVE EIBTASKN   TO ABND-TASKNO-KEY
                          MOVE EIBTRNID   TO ABND-TRANID

                          PERFORM POPULATE-TIME-DATE

                          MOVE WS-ORIG-DATE TO ABND-DATE
                          STRING WS-TIME-NOW-GRP-HH DELIMITED BY SIZE,
                             ':' DELIMITED BY SIZE,
                             WS-TIME-NOW-GRP-MM DELIMITED BY SIZE,
                             ':' DELIMITED BY SIZE,
                             WS-TIME-NOW-GRP-MM DELIMITED BY SIZE
                             INTO ABND-TIME
                          END-STRING

                          MOVE WS-U-TIME   TO ABND-UTIME-KEY
                          MOVE 'HROL'      TO ABND-CODE

                          EXEC CICS ASSIGN PROGRAM(ABND-PROGRAM)
                          END-EXEC

                          MOVE ZEROS      TO ABND-SQLCODE

                          STRING 'UAD010(2) - Error on SYNCPOINT'
                             DELIMITED BY SIZE,
                             ' ROLLBACK' DELIMITED BY SIZE,
                             ' after UPDATING TO account '
                             DELIMITED BY SIZE,
                             ' EIBRESP=' DELIMITED BY SIZE,
                             ABND-RESPCODE DELIMITED BY SIZE,
                             ' RESP2=' DELIMITED BY SIZE,
                             ABND-RESP2CODE DELIMITED BY SIZE
                             INTO ABND-FREEFORM
                          END-STRING

                          EXEC CICS LINK PROGRAM(WS-ABEND-PGM)
                             COMMAREA(ABNDINFO-REC)
                          END-EXEC

                          DISPLAY 'XFRFUN error syncpoint rollback'
                             ' after updating TO account '
                             ',RESP=' WS-CICS-RESP
                             ',RESP2=' WS-CICS-RESP2

                          EXEC CICS ABEND
                             ABCODE('HROL')
                             NODUMP
                             CANCEL
                          END-EXEC
                       END-IF

                       GO TO UAD999

                    ELSE
                       DISPLAY 'Error updating TO account'

                       EXEC CICS ABEND
                          ABCODE('TO  ')
                          NODUMP
                       END-EXEC
                    END-IF

                 END-IF

              ELSE
                 IF COMM-FAIL-CODE = '1'

                    EXEC CICS SYNCPOINT
                       ROLLBACK
                       RESP(WS-CICS-RESP)
                       RESP2(WS-CICS-RESP2)
                    END-EXEC

                    IF WS-CICS-RESP IS NOT EQUAL TO DFHRESP(NORMAL)
                       DISPLAY 'XFRFUN error syncpoint '
                          ' rollback after '
                          'updating FROM account '
                          ',RESP=' WS-CICS-RESP
                          ',RESP2=' WS-CICS-RESP2

                       EXEC CICS ABEND
                          ABCODE('HROL')
                          NODUMP
                       END-EXEC
                    END-IF

                    GO TO UAD999
                 ELSE
                    INITIALIZE ABNDINFO-REC
                    MOVE EIBRESP    TO ABND-RESPCODE
                    MOVE EIBRESP2   TO ABND-RESP2CODE
                    EXEC CICS ASSIGN APPLID(ABND-APPLID)
                    END-EXEC

                    MOVE EIBTASKN   TO ABND-TASKNO-KEY
                    MOVE EIBTRNID   TO ABND-TRANID

                    PERFORM POPULATE-TIME-DATE

                    MOVE WS-ORIG-DATE TO ABND-DATE
                    STRING WS-TIME-NOW-GRP-HH DELIMITED BY SIZE,
                        ':' DELIMITED BY SIZE,
                        WS-TIME-NOW-GRP-MM DELIMITED BY SIZE,
                        ':' DELIMITED BY SIZE,
                        WS-TIME-NOW-GRP-MM DELIMITED BY SIZE
                        INTO ABND-TIME
                    END-STRING

                    MOVE WS-U-TIME   TO ABND-UTIME-KEY
                    MOVE 'FROM'      TO ABND-CODE

                    EXEC CICS ASSIGN PROGRAM(ABND-PROGRAM)
                    END-EXEC

                    MOVE ZEROS      TO ABND-SQLCODE

                    STRING 'UAD010(3) - Error updating FROM account '
                       DELIMITED BY SIZE,
                       ' EIBRESP=' DELIMITED BY SIZE,
                       ABND-RESPCODE DELIMITED BY SIZE,
                       ' RESP2=' DELIMITED BY SIZE,
                       ABND-RESP2CODE DELIMITED BY SIZE
                       INTO ABND-FREEFORM
                    END-STRING

                    EXEC CICS LINK PROGRAM(WS-ABEND-PGM)
                           COMMAREA(ABNDINFO-REC)
                    END-EXEC

                    DISPLAY 'Error updating FROM account'

                    EXEC CICS ABEND
                       ABCODE('FROM')
                       NODUMP
                       CANCEL
                    END-EXEC

                 END-IF

              END-IF

           ELSE
              MOVE COMM-TACCNO TO DESIRED-ACC-NO
              MOVE COMM-TSCODE TO DESIRED-SORT-CODE

              PERFORM UPDATE-ACCOUNT-DB2-TO

              IF COMM-SUCCESS = 'Y'
                 MOVE COMM-FACCNO TO DESIRED-ACC-NO
                 MOVE COMM-FSCODE TO DESIRED-SORT-CODE

                 PERFORM UPDATE-ACCOUNT-DB2-FROM

                 IF COMM-SUCCESS = 'N'

                    IF COMM-FAIL-CODE NOT = '1'
                       INITIALIZE ABNDINFO-REC
                       MOVE EIBRESP    TO ABND-RESPCODE
                       MOVE EIBRESP2   TO ABND-RESP2CODE
                       EXEC CICS ASSIGN APPLID(ABND-APPLID)
                       END-EXEC

                       MOVE EIBTASKN   TO ABND-TASKNO-KEY
                       MOVE EIBTRNID   TO ABND-TRANID

                       PERFORM POPULATE-TIME-DATE

                       MOVE WS-ORIG-DATE TO ABND-DATE
                       STRING WS-TIME-NOW-GRP-HH DELIMITED BY SIZE,
                          ':' DELIMITED BY SIZE,
                          WS-TIME-NOW-GRP-MM DELIMITED BY SIZE,
                          ':' DELIMITED BY SIZE,
                          WS-TIME-NOW-GRP-MM DELIMITED BY SIZE
                          INTO ABND-TIME
                       END-STRING

                       MOVE WS-U-TIME   TO ABND-UTIME-KEY
                       MOVE 'FROM'      TO ABND-CODE

                       EXEC CICS ASSIGN PROGRAM(ABND-PROGRAM)
                       END-EXEC

                       MOVE ZEROS      TO ABND-SQLCODE

                       STRING 'UAD010(4) - Error updating FROM account '
                          DELIMITED BY SIZE,
                          ' EIBRESP=' DELIMITED BY SIZE,
                          ABND-RESPCODE DELIMITED BY SIZE,
                          ' RESP2=' DELIMITED BY SIZE,
                          ABND-RESP2CODE DELIMITED BY SIZE
                          INTO ABND-FREEFORM
                       END-STRING

                       EXEC CICS LINK PROGRAM(WS-ABEND-PGM)
                             COMMAREA(ABNDINFO-REC)
                       END-EXEC

                       DISPLAY 'Error updating FROM account'
                       EXEC CICS ABEND
                           ABCODE('FROM')
                           NODUMP
                           CANCEL
                       END-EXEC

                    ELSE
                       EXEC CICS SYNCPOINT
                          ROLLBACK
                          RESP(WS-CICS-RESP)
                          RESP2(WS-CICS-RESP2)
                       END-EXEC
                       IF WS-CICS-RESP IS NOT EQUAL TO DFHRESP(NORMAL)
                          INITIALIZE ABNDINFO-REC
                          MOVE EIBRESP    TO ABND-RESPCODE
                          MOVE EIBRESP2   TO ABND-RESP2CODE
                          EXEC CICS ASSIGN APPLID(ABND-APPLID)
                          END-EXEC

                          MOVE EIBTASKN   TO ABND-TASKNO-KEY
                          MOVE EIBTRNID   TO ABND-TRANID

                          PERFORM POPULATE-TIME-DATE

                          MOVE WS-ORIG-DATE TO ABND-DATE
                          STRING WS-TIME-NOW-GRP-HH DELIMITED BY SIZE,
                             ':' DELIMITED BY SIZE,
                              WS-TIME-NOW-GRP-MM DELIMITED BY SIZE,
                              ':' DELIMITED BY SIZE,
                              WS-TIME-NOW-GRP-MM DELIMITED BY SIZE
                              INTO ABND-TIME
                          END-STRING

                          MOVE WS-U-TIME   TO ABND-UTIME-KEY
                          MOVE 'HROL'      TO ABND-CODE

                          EXEC CICS ASSIGN PROGRAM(ABND-PROGRAM)
                          END-EXEC

                          MOVE ZEROS      TO ABND-SQLCODE

                          STRING 'UAD010(5) - Error on SYNCPOINT '
                             DELIMITED BY SIZE,
                             ' ROLLBACK ' DELIMITED BY SIZE,
                             ' after UPDATING the FROM account'
                             DELIMITED BY SIZE,
                             ' EIBRESP=' DELIMITED BY SIZE,
                             ABND-RESPCODE DELIMITED BY SIZE,
                             ' RESP2=' DELIMITED BY SIZE,
                             ABND-RESP2CODE DELIMITED BY SIZE
                             INTO ABND-FREEFORM
                          END-STRING

                          EXEC CICS LINK PROGRAM(WS-ABEND-PGM)
                             COMMAREA(ABNDINFO-REC)
                          END-EXEC

                          DISPLAY 'XFRFUN error syncpoint '
                             ' rollback after '
                             'updating FROM account '
                             ',RESP=' WS-CICS-RESP
                             ',RESP2=' WS-CICS-RESP2

                          EXEC CICS ABEND
                              ABCODE('HROL')
                              NODUMP
                              CANCEL
                          END-EXEC

                       END-IF

                       GO TO UAD999
                    END-IF

                 END-IF

              ELSE

                 IF COMM-FAIL-CODE NOT = '2'
                    INITIALIZE ABNDINFO-REC
                    MOVE EIBRESP    TO ABND-RESPCODE
                    MOVE EIBRESP2   TO ABND-RESP2CODE
                    EXEC CICS ASSIGN APPLID(ABND-APPLID)
                    END-EXEC

                    MOVE EIBTASKN   TO ABND-TASKNO-KEY
                    MOVE EIBTRNID   TO ABND-TRANID

                    PERFORM POPULATE-TIME-DATE

                    MOVE WS-ORIG-DATE TO ABND-DATE
                    STRING WS-TIME-NOW-GRP-HH DELIMITED BY SIZE,
                       ':' DELIMITED BY SIZE,
                       WS-TIME-NOW-GRP-MM DELIMITED BY SIZE,
                       ':' DELIMITED BY SIZE,
                       WS-TIME-NOW-GRP-MM DELIMITED BY SIZE
                       INTO ABND-TIME
                    END-STRING

                    MOVE WS-U-TIME   TO ABND-UTIME-KEY
                    MOVE 'TO  '      TO ABND-CODE

                    EXEC CICS ASSIGN PROGRAM(ABND-PROGRAM)
                    END-EXEC

                    MOVE ZEROS      TO ABND-SQLCODE

                    STRING 'UAD010(6) - Error updating TO account '
                       DELIMITED BY SIZE,
                       ' EIBRESP=' DELIMITED BY SIZE,
                       ABND-RESPCODE DELIMITED BY SIZE,
                       ' RESP2=' DELIMITED BY SIZE,
                       ABND-RESP2CODE DELIMITED BY SIZE
                       INTO ABND-FREEFORM
                    END-STRING

                    EXEC CICS LINK PROGRAM(WS-ABEND-PGM)
                           COMMAREA(ABNDINFO-REC)
                    END-EXEC

                    DISPLAY 'Error updating TO account'

                    EXEC CICS ABEND
                       ABCODE('TO  ')
                       CANCEL
                       NODUMP
                    END-EXEC
                 ELSE

                    EXEC CICS SYNCPOINT
                       ROLLBACK
                       RESP(WS-CICS-RESP)
                       RESP2(WS-CICS-RESP2)
                    END-EXEC

                    IF WS-CICS-RESP IS NOT EQUAL TO DFHRESP(NORMAL)
                       INITIALIZE ABNDINFO-REC
                       MOVE EIBRESP    TO ABND-RESPCODE
                       MOVE EIBRESP2   TO ABND-RESP2CODE
                       EXEC CICS ASSIGN APPLID(ABND-APPLID)
                       END-EXEC

                       MOVE EIBTASKN   TO ABND-TASKNO-KEY
                       MOVE EIBTRNID   TO ABND-TRANID

                       PERFORM POPULATE-TIME-DATE

                       MOVE WS-ORIG-DATE TO ABND-DATE
                       STRING WS-TIME-NOW-GRP-HH DELIMITED BY SIZE,
                          ':' DELIMITED BY SIZE,
                          WS-TIME-NOW-GRP-MM DELIMITED BY SIZE,
                          ':' DELIMITED BY SIZE,
                          WS-TIME-NOW-GRP-MM DELIMITED BY SIZE
                          INTO ABND-TIME
                       END-STRING

                       MOVE WS-U-TIME   TO ABND-UTIME-KEY
                       MOVE 'HROL'      TO ABND-CODE

                       EXEC CICS ASSIGN PROGRAM(ABND-PROGRAM)
                       END-EXEC

                       MOVE ZEROS      TO ABND-SQLCODE

                       STRING 'UAD010(7) - Error on SYNCPOINT ROLLBACK'
                          DELIMITED BY SIZE,
                          ' after UPDATING the TO account'
                          DELIMITED BY SIZE,
                          ' EIBRESP=' DELIMITED BY SIZE,
                          ABND-RESPCODE DELIMITED BY SIZE,
                          ' RESP2=' DELIMITED BY SIZE,
                          ABND-RESP2CODE DELIMITED BY SIZE
                          INTO ABND-FREEFORM
                       END-STRING

                       EXEC CICS LINK PROGRAM(WS-ABEND-PGM)
                             COMMAREA(ABNDINFO-REC)
                       END-EXEC

                       DISPLAY 'XFRFUN error syncpoint rollback after '
                           'updating TO account '
                           ',RESP=' WS-CICS-RESP
                           ',RESP2=' WS-CICS-RESP2

                       EXEC CICS ABEND
                          ABCODE('HROL')
                          NODUMP
                          CANCEL
                       END-EXEC

                    END-IF

                    GO TO UAD999

                 END-IF

              END-IF

           END-IF.

           PERFORM WRITE-TO-PROCTRAN.

           MOVE 'Y' TO COMM-SUCCESS.

       UAD999.
           EXIT.


       UPDATE-ACCOUNT-DB2-FROM SECTION.
       UADF010.
           MOVE COMM-FACCNO TO DESIRED-ACC-NO.
           MOVE COMM-FSCODE TO DESIRED-SORT-CODE.

           MOVE DESIRED-SORT-CODE TO HV-ACCOUNT-SORTCODE.
           MOVE DESIRED-ACC-NO TO HV-ACCOUNT-ACC-NO.

           EXEC SQL
              SELECT ACCOUNT_EYECATCHER,
                ACCOUNT_CUSTOMER_NUMBER,
                ACCOUNT_SORTCODE,
                ACCOUNT_NUMBER,
                ACCOUNT_TYPE,
                ACCOUNT_INTEREST_RATE,
                ACCOUNT_OPENED,
                ACCOUNT_OVERDRAFT_LIMIT,
                ACCOUNT_LAST_STATEMENT,
                ACCOUNT_NEXT_STATEMENT,
                ACCOUNT_AVAILABLE_BALANCE,
                ACCOUNT_ACTUAL_BALANCE
              INTO  :HV-ACCOUNT-EYECATCHER,
                :HV-ACCOUNT-CUST-NO,
                :HV-ACCOUNT-SORTCODE,
                :HV-ACCOUNT-ACC-NO,
                :HV-ACCOUNT-ACC-TYPE,
                :HV-ACCOUNT-INT-RATE,
                :HV-ACCOUNT-OPENED,
                :HV-ACCOUNT-OVERDRAFT-LIM,
                :HV-ACCOUNT-LAST-STMT,
                :HV-ACCOUNT-NEXT-STMT,
                :HV-ACCOUNT-AVAIL-BAL,
                :HV-ACCOUNT-ACTUAL-BAL
              FROM ACCOUNT
              WHERE  (ACCOUNT_SORTCODE = :HV-ACCOUNT-SORTCODE AND
                ACCOUNT_NUMBER = :HV-ACCOUNT-ACC-NO)
           END-EXEC.

           IF SQLCODE NOT = 0
              MOVE 'N' TO COMM-SUCCESS

              IF SQLCODE = +100
                 MOVE '1' TO COMM-FAIL-CODE
              ELSE
                 MOVE '3' TO COMM-FAIL-CODE
              END-IF
              PERFORM CHECK-FOR-STORM-DRAIN-DB2

              GO TO UADF999

           END-IF.

           COMPUTE HV-ACCOUNT-AVAIL-BAL =
           HV-ACCOUNT-AVAIL-BAL - COMM-AMT.

           COMPUTE HV-ACCOUNT-ACTUAL-BAL =
           HV-ACCOUNT-ACTUAL-BAL - COMM-AMT.

           EXEC SQL
              UPDATE ACCOUNT
              SET ACCOUNT_EYECATCHER        = :HV-ACCOUNT-EYECATCHER,
              ACCOUNT_CUSTOMER_NUMBER   = :HV-ACCOUNT-CUST-NO,
              ACCOUNT_SORTCODE          = :HV-ACCOUNT-SORTCODE,
              ACCOUNT_NUMBER            = :HV-ACCOUNT-ACC-NO,
              ACCOUNT_TYPE              = :HV-ACCOUNT-ACC-TYPE,
              ACCOUNT_INTEREST_RATE     = :HV-ACCOUNT-INT-RATE,
              ACCOUNT_OPENED            = :HV-ACCOUNT-OPENED,
              ACCOUNT_OVERDRAFT_LIMIT   = :HV-ACCOUNT-OVERDRAFT-LIM,
              ACCOUNT_LAST_STATEMENT    = :HV-ACCOUNT-LAST-STMT,
              ACCOUNT_NEXT_STATEMENT    = :HV-ACCOUNT-NEXT-STMT,
              ACCOUNT_AVAILABLE_BALANCE = :HV-ACCOUNT-AVAIL-BAL,
              ACCOUNT_ACTUAL_BALANCE    = :HV-ACCOUNT-ACTUAL-BAL
              WHERE (ACCOUNT_SORTCODE       = :HV-ACCOUNT-SORTCODE AND
              ACCOUNT_NUMBER         = :HV-ACCOUNT-ACC-NO)
           END-EXEC.

           IF SQLCODE NOT = 0

              MOVE 'N' TO COMM-SUCCESS
              MOVE '3' TO COMM-FAIL-CODE

              PERFORM CHECK-FOR-STORM-DRAIN-DB2

              GO TO UADF999

           END-IF.

           MOVE HV-ACCOUNT-AVAIL-BAL TO COMM-FAVBAL.
           MOVE HV-ACCOUNT-ACTUAL-BAL TO COMM-FACTBAL.
           MOVE 'Y' TO COMM-SUCCESS.

       UADF999.
           EXIT.


       UPDATE-ACCOUNT-DB2-TO SECTION.
       UADT010.

           MOVE 'N' TO COMM-SUCCESS.
           INITIALIZE HOST-ACCOUNT-ROW.

           MOVE COMM-TACCNO TO DESIRED-ACC-NO.
           MOVE COMM-TSCODE TO DESIRED-SORT-CODE.

           MOVE DESIRED-SORT-CODE TO HV-ACCOUNT-SORTCODE.
           MOVE DESIRED-ACC-NO TO HV-ACCOUNT-ACC-NO.

           EXEC SQL
                SELECT ACCOUNT_EYECATCHER,
                ACCOUNT_CUSTOMER_NUMBER,
                ACCOUNT_SORTCODE,
                ACCOUNT_NUMBER,
                ACCOUNT_TYPE,
                ACCOUNT_INTEREST_RATE,
                ACCOUNT_OPENED,
                ACCOUNT_OVERDRAFT_LIMIT,
                ACCOUNT_LAST_STATEMENT,
                ACCOUNT_NEXT_STATEMENT,
                ACCOUNT_AVAILABLE_BALANCE,
                ACCOUNT_ACTUAL_BALANCE
                INTO  :HV-ACCOUNT-EYECATCHER,
                :HV-ACCOUNT-CUST-NO,
                :HV-ACCOUNT-SORTCODE,
                :HV-ACCOUNT-ACC-NO,
                :HV-ACCOUNT-ACC-TYPE,
                :HV-ACCOUNT-INT-RATE,
                :HV-ACCOUNT-OPENED,
                :HV-ACCOUNT-OVERDRAFT-LIM,
                :HV-ACCOUNT-LAST-STMT,
                :HV-ACCOUNT-NEXT-STMT,
                :HV-ACCOUNT-AVAIL-BAL,
                :HV-ACCOUNT-ACTUAL-BAL
                FROM ACCOUNT
                WHERE  (ACCOUNT_SORTCODE = :HV-ACCOUNT-SORTCODE AND
                ACCOUNT_NUMBER = :HV-ACCOUNT-ACC-NO)
           END-EXEC.

           IF SQLCODE NOT = 0
              MOVE 'N' TO COMM-SUCCESS
              PERFORM CHECK-FOR-STORM-DRAIN-DB2

              IF SQLCODE = +100
                 MOVE '2' TO COMM-FAIL-CODE
                 MOVE SQLCODE TO SQLCODE-DISPLAY

                 DISPLAY 'UPDATE UNABLE TO READ TO ACC'
                    HV-ACCOUNT-SORTCODE '/' HV-ACCOUNT-ACC-NO
                    ' ROLLBACK TO AVOID DATA INCONSISTENCY.'
                    'SQLCODE=' SQLCODE-DISPLAY

                 EXEC CICS SYNCPOINT ROLLBACK
                   RESP(WS-CICS-RESP)
                   RESP2(WS-CICS-RESP2)
                 END-EXEC

                 IF WS-CICS-RESP IS NOT EQUAL TO DFHRESP(NORMAL)
                    INITIALIZE ABNDINFO-REC
                    MOVE EIBRESP    TO ABND-RESPCODE
                    MOVE EIBRESP2   TO ABND-RESP2CODE
                    EXEC CICS ASSIGN APPLID(ABND-APPLID)
                    END-EXEC

                    MOVE EIBTASKN   TO ABND-TASKNO-KEY
                    MOVE EIBTRNID   TO ABND-TRANID

                    PERFORM POPULATE-TIME-DATE

                    MOVE WS-ORIG-DATE TO ABND-DATE
                    STRING WS-TIME-NOW-GRP-HH DELIMITED BY SIZE,
                          ':' DELIMITED BY SIZE,
                          WS-TIME-NOW-GRP-MM DELIMITED BY SIZE,
                          ':' DELIMITED BY SIZE,
                          WS-TIME-NOW-GRP-MM DELIMITED BY SIZE
                          INTO ABND-TIME
                    END-STRING

                    MOVE WS-U-TIME   TO ABND-UTIME-KEY
                    MOVE 'HROL'      TO ABND-CODE

                    EXEC CICS ASSIGN PROGRAM(ABND-PROGRAM)
                    END-EXEC

                    MOVE ZEROS      TO ABND-SQLCODE

                    STRING 'UAD010-TO - Error on SYNCPOINT ROLLBACK '
                         DELIMITED BY SIZE,
                         'after failing to read TO account'
                         DELIMITED BY SIZE,
                         ' EIBRESP=' DELIMITED BY SIZE,
                         ABND-RESPCODE DELIMITED BY SIZE,
                         ' RESP2=' DELIMITED BY SIZE,
                         ABND-RESP2CODE DELIMITED BY SIZE
                         INTO ABND-FREEFORM
                    END-STRING

                    EXEC CICS LINK PROGRAM(WS-ABEND-PGM)
                             COMMAREA(ABNDINFO-REC)
                    END-EXEC

                    DISPLAY 'XFRFUN error syncpoint rollback after '
                           'failing to read TO account '
                           ',RESP=' WS-CICS-RESP
                           ',RESP2=' WS-CICS-RESP2

                    EXEC CICS ABEND
                       ABCODE('HROL')
                       NODUMP
                       CANCEL
                    END-EXEC
                 END-IF

                 GO TO UADT999

              ELSE
                 MOVE '3' TO COMM-FAIL-CODE
                 MOVE SQLCODE TO SQLCODE-DISPLAY

                 DISPLAY 'UPDATE UNABLE TO READ TO ACC'
                    HV-ACCOUNT-SORTCODE HV-ACCOUNT-ACC-NO
                    ' ABENDING TO AVOID DATA INCONSISTENCY. SQLCODE='
                    SQLCODE-DISPLAY
                    ' SQLERRD(3) IS ' SQLERRD(3)

                 IF SQLCODE = -911

                    IF SQLERRD(3) = 13172872
                       DISPLAY 'DEADLOCK DETECTED!'
                       ADD 1 TO DB2-DEADLOCK-RETRY

                       IF DB2-DEADLOCK-RETRY < 6
                          EXEC CICS SYNCPOINT
                             ROLLBACK
                             RESP(WS-CICS-RESP)
                             RESP2(WS-CICS-RESP2)
                          END-EXEC

                          IF WS-CICS-RESP IS NOT EQUAL TO
                          DFHRESP(NORMAL)

                             INITIALIZE ABNDINFO-REC
                             MOVE EIBRESP    TO ABND-RESPCODE
                             MOVE EIBRESP2   TO ABND-RESP2CODE
                             EXEC CICS ASSIGN APPLID(ABND-APPLID)
                             END-EXEC

                             MOVE EIBTASKN   TO ABND-TASKNO-KEY
                             MOVE EIBTRNID   TO ABND-TRANID

                             PERFORM POPULATE-TIME-DATE

                             MOVE WS-ORIG-DATE TO ABND-DATE
                             STRING WS-TIME-NOW-GRP-HH
                                DELIMITED BY SIZE,
                                ':' DELIMITED BY SIZE,
                                WS-TIME-NOW-GRP-MM DELIMITED BY SIZE,
                                ':' DELIMITED BY SIZE,
                                WS-TIME-NOW-GRP-MM DELIMITED BY SIZE
                                INTO ABND-TIME
                             END-STRING

                             MOVE WS-U-TIME   TO ABND-UTIME-KEY
                             MOVE 'HROL'      TO ABND-CODE

                             EXEC CICS ASSIGN PROGRAM(ABND-PROGRAM)
                             END-EXEC

                             MOVE ZEROS      TO ABND-SQLCODE

                             STRING 'UAD010-TO(2) - Error on SYNCPOINT'
                                DELIMITED BY SIZE,
                                ' ROLLBACK after updating TO account'
                                DELIMITED BY SIZE,
                                ' EIBRESP=' DELIMITED BY SIZE,
                                ABND-RESPCODE DELIMITED BY SIZE,
                                ' RESP2=' DELIMITED BY SIZE,
                                ABND-RESP2CODE DELIMITED BY SIZE
                                INTO ABND-FREEFORM
                             END-STRING

                             EXEC CICS LINK PROGRAM(WS-ABEND-PGM)
                                   COMMAREA(ABNDINFO-REC)
                             END-EXEC

                             DISPLAY 'XFRFUN error syncpoint rollback'
                                ' after updating TO account '
                                ',RESP=' WS-CICS-RESP
                                ',RESP2=' WS-CICS-RESP2

                             EXEC CICS ABEND
                                ABCODE('HROL')
                                NODUMP
                                CANCEL
                             END-EXEC

                          END-IF

                          EXEC CICS DELAY FOR SECONDS(1)
                          END-EXEC

                          GO TO UPDATE-ACCOUNT-DB2

                       END-IF

                    END-IF

                    IF SQLERRD(3) = 13172894
                       DISPLAY 'TIMEOUT DETECTED!'
                    END-IF

                    INITIALIZE ABNDINFO-REC
                    MOVE EIBRESP    TO ABND-RESPCODE
                    MOVE EIBRESP2   TO ABND-RESP2CODE
                    EXEC CICS ASSIGN APPLID(ABND-APPLID)
                    END-EXEC

                    MOVE EIBTASKN   TO ABND-TASKNO-KEY
                    MOVE EIBTRNID   TO ABND-TRANID

                    PERFORM POPULATE-TIME-DATE

                    MOVE WS-ORIG-DATE TO ABND-DATE
                    STRING WS-TIME-NOW-GRP-HH DELIMITED BY SIZE,
                        ':' DELIMITED BY SIZE,
                        WS-TIME-NOW-GRP-MM DELIMITED BY SIZE,
                        ':' DELIMITED BY SIZE,
                        WS-TIME-NOW-GRP-MM DELIMITED BY SIZE
                        INTO ABND-TIME
                    END-STRING

                    MOVE WS-U-TIME   TO ABND-UTIME-KEY
                    MOVE 'RUF2'      TO ABND-CODE

                    EXEC CICS ASSIGN PROGRAM(ABND-PROGRAM)
                    END-EXEC

                    MOVE ZEROS      TO ABND-SQLCODE

                    IF SQLERRD(3) = 13172894
                       STRING 'UAD010-TO(3) - timeout detected '
                          DELIMITED BY SIZE,
                          ' EIBRESP=' DELIMITED BY SIZE,
                          ABND-RESPCODE DELIMITED BY SIZE,
                          'RESP2=' DELIMITED BY SIZE,
                          ABND-RESP2CODE DELIMITED BY SIZE
                          INTO ABND-FREEFORM
                       END-STRING

                    END-IF

                    EXEC CICS LINK PROGRAM(WS-ABEND-PGM)
                           COMMAREA(ABNDINFO-REC)
                    END-EXEC

                    EXEC CICS ABEND
                       ABCODE('RUF2')
                    END-EXEC
              END-IF

           END-IF.


           COMPUTE HV-ACCOUNT-AVAIL-BAL = HV-ACCOUNT-AVAIL-BAL +
                   COMM-AMT.
           COMPUTE HV-ACCOUNT-ACTUAL-BAL = HV-ACCOUNT-ACTUAL-BAL +
                   COMM-AMT.

           EXEC SQL
                UPDATE ACCOUNT
                SET ACCOUNT_EYECATCHER        = :HV-ACCOUNT-EYECATCHER,
                ACCOUNT_CUSTOMER_NUMBER   = :HV-ACCOUNT-CUST-NO,
                ACCOUNT_SORTCODE          = :HV-ACCOUNT-SORTCODE,
                ACCOUNT_NUMBER            = :HV-ACCOUNT-ACC-NO,
                ACCOUNT_TYPE              = :HV-ACCOUNT-ACC-TYPE,
                ACCOUNT_INTEREST_RATE     = :HV-ACCOUNT-INT-RATE,
                ACCOUNT_OPENED            = :HV-ACCOUNT-OPENED,
                ACCOUNT_OVERDRAFT_LIMIT   = :HV-ACCOUNT-OVERDRAFT-LIM,
                ACCOUNT_LAST_STATEMENT    = :HV-ACCOUNT-LAST-STMT,
                ACCOUNT_NEXT_STATEMENT    = :HV-ACCOUNT-NEXT-STMT,
                ACCOUNT_AVAILABLE_BALANCE = :HV-ACCOUNT-AVAIL-BAL,
                ACCOUNT_ACTUAL_BALANCE    = :HV-ACCOUNT-ACTUAL-BAL
                WHERE (ACCOUNT_SORTCODE   = :HV-ACCOUNT-SORTCODE AND
                ACCOUNT_NUMBER         = :HV-ACCOUNT-ACC-NO)
           END-EXEC.


           IF SQLCODE NOT = 0
              MOVE SQLCODE TO SQLCODE-DISPLAY
              DISPLAY 'UNABLE TO UPDATE TO ACCOUNT.'
                 HV-ACCOUNT-SORTCODE HV-ACCOUNT-ACC-NO
                 'THE SQLCODE=' SQLCODE-DISPLAY
                 ' SQLERRD(3) ' SQLERRD(3)

              PERFORM CHECK-FOR-STORM-DRAIN-DB2

              IF SQLCODE = -911
                 IF SQLERRD(3) = 13172872
                    DISPLAY 'DEADLOCK DETECTED!'
                    ADD 1 TO DB2-DEADLOCK-RETRY

                    IF DB2-DEADLOCK-RETRY < 6
                       EXEC CICS SYNCPOINT
                          ROLLBACK
                          RESP(WS-CICS-RESP)
                          RESP2(WS-CICS-RESP2)
                       END-EXEC

                       IF WS-CICS-RESP IS NOT EQUAL TO DFHRESP(NORMAL)

                          INITIALIZE ABNDINFO-REC
                          MOVE EIBRESP    TO ABND-RESPCODE
                          MOVE EIBRESP2   TO ABND-RESP2CODE
                          EXEC CICS ASSIGN APPLID(ABND-APPLID)
                          END-EXEC

                          MOVE EIBTASKN   TO ABND-TASKNO-KEY
                          MOVE EIBTRNID   TO ABND-TRANID

                          PERFORM POPULATE-TIME-DATE

                          MOVE WS-ORIG-DATE TO ABND-DATE
                          STRING WS-TIME-NOW-GRP-HH DELIMITED BY SIZE,
                             ':' DELIMITED BY SIZE,
                             WS-TIME-NOW-GRP-MM DELIMITED BY SIZE,
                             ':' DELIMITED BY SIZE,
                             WS-TIME-NOW-GRP-MM DELIMITED BY SIZE
                             INTO ABND-TIME
                          END-STRING

                          MOVE WS-U-TIME   TO ABND-UTIME-KEY
                          MOVE 'HROL'      TO ABND-CODE

                          EXEC CICS ASSIGN PROGRAM(ABND-PROGRAM)
                          END-EXEC

                          MOVE ZEROS      TO ABND-SQLCODE

                          STRING 'UAD010-TO(4) - Error on SYNCPOINT '
                             DELIMITED BY SIZE,
                             'ROLLBACK after Updating TO account'
                             DELIMITED BY SIZE,
                             ' EIBRESP=' DELIMITED BY SIZE,
                             ABND-RESPCODE DELIMITED BY SIZE,
                             ' RESP2=' DELIMITED BY SIZE,
                             ABND-RESP2CODE DELIMITED BY SIZE
                             INTO ABND-FREEFORM
                          END-STRING

                          EXEC CICS LINK PROGRAM(WS-ABEND-PGM)
                               COMMAREA(ABNDINFO-REC)
                          END-EXEC

                          DISPLAY 'XFRFUN error syncpoint rollback '
                             ' after updating TO account '
                             ',RESP=' WS-CICS-RESP
                             ',RESP2=' WS-CICS-RESP2

                          EXEC CICS ABEND
                             ABCODE('HROL')
                             NODUMP
                             CANCEL
                          END-EXEC

                       END-IF

                       EXEC CICS DELAY FOR SECONDS(1)
                       END-EXEC

                       GO TO UPDATE-ACCOUNT-DB2

                    END-IF

                 END-IF

                 IF SQLERRD(3) = 13172872
                    DISPLAY 'TIMEOUT DETECTED!'

                 END-IF

              END-IF

              INITIALIZE ABNDINFO-REC
              MOVE EIBRESP    TO ABND-RESPCODE
              MOVE EIBRESP2   TO ABND-RESP2CODE
              EXEC CICS ASSIGN APPLID(ABND-APPLID)
              END-EXEC

              MOVE EIBTASKN   TO ABND-TASKNO-KEY
              MOVE EIBTRNID   TO ABND-TRANID

              PERFORM POPULATE-TIME-DATE

              MOVE WS-ORIG-DATE TO ABND-DATE
              STRING WS-TIME-NOW-GRP-HH DELIMITED BY SIZE,
                        ':' DELIMITED BY SIZE,
                        WS-TIME-NOW-GRP-MM DELIMITED BY SIZE,
                        ':' DELIMITED BY SIZE,
                        WS-TIME-NOW-GRP-MM DELIMITED BY SIZE
                        INTO ABND-TIME
              END-STRING

              MOVE WS-U-TIME   TO ABND-UTIME-KEY
              MOVE 'RUF2'      TO ABND-CODE

              EXEC CICS ASSIGN PROGRAM(ABND-PROGRAM)
              END-EXEC

              MOVE ZEROS      TO ABND-SQLCODE

              IF SQLERRD(3) = 13172872
                 STRING 'UAD010-TO(5) - timeout detected '
                       DELIMITED BY SIZE,
                       ' EIBRESP=' DELIMITED BY SIZE,
                       ABND-RESPCODE DELIMITED BY SIZE,
                       ' RESP2=' DELIMITED BY SIZE,
                       ABND-RESP2CODE DELIMITED BY SIZE
                       INTO ABND-FREEFORM
                 END-STRING

              END-IF

              EXEC CICS LINK PROGRAM(WS-ABEND-PGM)
                           COMMAREA(ABNDINFO-REC)
              END-EXEC

              EXEC CICS
                 ABEND ABCODE ('RUF3')
              END-EXEC

           END-IF.

           MOVE HV-ACCOUNT-AVAIL-BAL  TO COMM-TAVBAL.
           MOVE HV-ACCOUNT-ACTUAL-BAL TO COMM-TACTBAL.

           MOVE 'Y' TO COMM-SUCCESS.

       UADT999.
           EXIT.


       WRITE-TO-PROCTRAN SECTION.
       WTP010.

           PERFORM WRITE-TO-PROCTRAN-DB2.
       WTP999.
           EXIT.


       WRITE-TO-PROCTRAN-DB2 SECTION.
       WTPD010.
           INITIALIZE HOST-PROCTRAN-ROW.
           INITIALIZE WS-EIBTASKN12.

           MOVE 'PRTR' TO HV-PROCTRAN-EYECATCHER.
           MOVE COMM-FSCODE TO HV-PROCTRAN-SORT-CODE.
           MOVE COMM-FACCNO TO HV-PROCTRAN-ACC-NUMBER.
           MOVE EIBTASKN TO WS-EIBTASKN12.
           MOVE WS-EIBTASKN12 TO HV-PROCTRAN-REF.

           EXEC CICS ASKTIME
                ABSTIME(WS-U-TIME)
           END-EXEC.

           EXEC CICS FORMATTIME
                ABSTIME(WS-U-TIME)
                DDMMYYYY(WS-ORIG-DATE)
                TIME(HV-PROCTRAN-TIME)
                DATESEP('.')
           END-EXEC.

           MOVE WS-ORIG-DATE TO WS-ORIG-DATE-GRP-X.
           MOVE WS-ORIG-DATE-GRP-X TO HV-PROCTRAN-DATE.

           SET PROC-TY-TRANSFER IN PROCTRAN-AREA TO TRUE

           MOVE PROC-TRAN-TYPE IN PROCTRAN-AREA TO HV-PROCTRAN-TYPE.

           MOVE COMM-AMT TO HV-PROCTRAN-AMOUNT.

           SET PROC-TRAN-DESC-XFR-FLAG IN PROCTRAN-AREA TO TRUE.
           MOVE COMM-TSCODE
             TO PROC-TRAN-DESC-XFR-SORTCODE IN PROCTRAN-AREA.
           MOVE COMM-TACCNO
             TO PROC-TRAN-DESC-XFR-ACCOUNT IN PROCTRAN-AREA.
           MOVE PROC-TRAN-DESC IN PROCTRAN-AREA TO HV-PROCTRAN-DESC.

           EXEC SQL
                INSERT INTO PROCTRAN
                (
                PROCTRAN_EYECATCHER,
                PROCTRAN_SORTCODE,
                PROCTRAN_NUMBER,
                PROCTRAN_DATE,
                PROCTRAN_TIME,
                PROCTRAN_REF,
                PROCTRAN_TYPE,
                PROCTRAN_DESC,
                PROCTRAN_AMOUNT
                )
                VALUES
                (
                :HV-PROCTRAN-EYECATCHER,
                :HV-PROCTRAN-SORT-CODE,
                :HV-PROCTRAN-ACC-NUMBER,
                :HV-PROCTRAN-DATE,
                :HV-PROCTRAN-TIME,
                :HV-PROCTRAN-REF,
                :HV-PROCTRAN-TYPE,
                :HV-PROCTRAN-DESC,
                :HV-PROCTRAN-AMOUNT
                )
           END-EXEC.

           IF SQLCODE NOT = 0

              MOVE SQLCODE TO WS-SQLCODE-DISP
              INITIALIZE ABNDINFO-REC
              MOVE EIBRESP    TO ABND-RESPCODE
              MOVE EIBRESP2   TO ABND-RESP2CODE
              EXEC CICS ASSIGN APPLID(ABND-APPLID)
              END-EXEC

              MOVE EIBTASKN   TO ABND-TASKNO-KEY
              MOVE EIBTRNID   TO ABND-TRANID

              PERFORM POPULATE-TIME-DATE

              MOVE WS-ORIG-DATE TO ABND-DATE
              STRING WS-TIME-NOW-GRP-HH DELIMITED BY SIZE,
                     ':' DELIMITED BY SIZE,
                     WS-TIME-NOW-GRP-MM DELIMITED BY SIZE,
                     ':' DELIMITED BY SIZE,
                     WS-TIME-NOW-GRP-MM DELIMITED BY SIZE
                     INTO ABND-TIME
              END-STRING

              MOVE WS-U-TIME   TO ABND-UTIME-KEY
              MOVE 'WPCD'      TO ABND-CODE

              EXEC CICS ASSIGN PROGRAM(ABND-PROGRAM)
              END-EXEC

              MOVE WS-SQLCODE-DISP TO ABND-SQLCODE

              STRING 'WTPD010 - Unable to WRITE to PROCTRAN DB2 '
                    DELIMITED BY SIZE,
                    'datastore. Data='
                    DELIMITED BY SIZE,
                    HOST-PROCTRAN-ROW
                    DELIMITED BY SIZE,
                    '.Data inconsistency, data UPDATED on ACCOUNT file'
                    DELIMITED BY SIZE,
                    ' EIBRESP=' DELIMITED BY SIZE,
                    ABND-RESPCODE DELIMITED BY SIZE,
                    ' RESP2=' DELIMITED BY SIZE,
                    ABND-RESP2CODE DELIMITED BY SIZE
                    INTO ABND-FREEFORM
              END-STRING

              EXEC CICS LINK PROGRAM(WS-ABEND-PGM)
                        COMMAREA(ABNDINFO-REC)
              END-EXEC

              DISPLAY 'UNABLE TO WRITE TO PROCTRAN DB2 DATASTORE'
              ' SQLCODE=' SQLCODE
              'WITH THE FOLLOWING DATA:' HOST-PROCTRAN-ROW
              DISPLAY 'DATA INCONSISTENCY, DATA UPDATED ON ACCOUNT'

              PERFORM CHECK-FOR-STORM-DRAIN-DB2

              EXEC CICS ABEND
                 ABCODE('WPCD')
              END-EXEC

           END-IF.

       WTPD999.
           EXIT.


       GET-ME-OUT-OF-HERE SECTION.
       GMOOH010.
           EXEC CICS RETURN
           END-EXEC.

           GOBACK.

       GMOOH999.
           EXIT.


       CHECK-FOR-STORM-DRAIN-DB2 SECTION.
       CFSDD010.

           EVALUATE SQLCODE

              WHEN 923
                 MOVE 'DB2 Connection lost ' TO STORM-DRAIN-CONDITION

              WHEN OTHER
                 MOVE 'Not Storm Drain     ' TO STORM-DRAIN-CONDITION

           END-EVALUATE.

           IF STORM-DRAIN-CONDITION NOT EQUAL 'Not Storm Drain     '

              DISPLAY 'XFRFUN: Check-For-Storm-Drain-DB2: Storm '
                      'Drain condition (' STORM-DRAIN-CONDITION ') '
                      'has been met (' SQLCODE-DISPLAY ').'
           ELSE

              CONTINUE

           END-IF.

       CFSDD999.
           EXIT.


       ABEND-HANDLING SECTION.
       AH010.
           EXEC CICS ASSIGN
              ABCODE(MY-ABEND-CODE)
           END-EXEC.

           EVALUATE MY-ABEND-CODE

              WHEN 'AD2Z'

                 MOVE SQLCODE TO SQLCODE-DISPLAY
                 DISPLAY 'DB2 DEADLOCK DETECTED IN XFRFUN, SQLCODE='
                    SQLCODE-DISPLAY
                 DISPLAY 'DB2 DEADLOCK FOR ACCOUNT '
                    HV-ACCOUNT-ACC-NO
                 DISPLAY  'SQLSTATE=' SQLSTATE
                        ',SQLERRMC=' SQLERRMC(1:SQLERRML)
                        ',SQLERRD(1)=' SQLERRD(1)
                        ',SQLERRD(2)=' SQLERRD(2)
                        ',SQLERRD(3)=' SQLERRD(3)
                        ',SQLERRD(4)=' SQLERRD(4)
                        ',SQLERRD(5)=' SQLERRD(5)
                        ',SQLERRD(6)=' SQLERRD(6)

              WHEN 'AFCR'
              WHEN 'AFCS'
              WHEN 'AFCT'
                 MOVE 'Y' TO WS-STORM-DRAIN
                 DISPLAY 'XFRFUN: Check-For-Storm-Drain-VSAM: Storm '
                       'Drain condition (Abend ' MY-ABEND-CODE ') '
                       'has been met.'

                 EXEC CICS SYNCPOINT
                    ROLLBACK
                    RESP(WS-CICS-RESP)
                    RESP2(WS-CICS-RESP2)
                 END-EXEC

                 IF WS-CICS-RESP NOT = DFHRESP(NORMAL)
                    INITIALIZE ABNDINFO-REC
                    MOVE EIBRESP    TO ABND-RESPCODE
                    MOVE EIBRESP2   TO ABND-RESP2CODE
                    EXEC CICS ASSIGN APPLID(ABND-APPLID)
                    END-EXEC

                    MOVE EIBTASKN   TO ABND-TASKNO-KEY
                    MOVE EIBTRNID   TO ABND-TRANID

                    PERFORM POPULATE-TIME-DATE

                    MOVE WS-ORIG-DATE TO ABND-DATE
                    STRING WS-TIME-NOW-GRP-HH DELIMITED BY SIZE,
                       ':' DELIMITED BY SIZE,
                        WS-TIME-NOW-GRP-MM DELIMITED BY SIZE,
                        ':' DELIMITED BY SIZE,
                        WS-TIME-NOW-GRP-MM DELIMITED BY SIZE
                        INTO ABND-TIME
                    END-STRING

                    MOVE WS-U-TIME   TO ABND-UTIME-KEY
                    MOVE 'HROL'      TO ABND-CODE

                    EXEC CICS ASSIGN PROGRAM(ABND-PROGRAM)
                    END-EXEC

                    MOVE ZEROS      TO ABND-SQLCODE

                    STRING 'AH010 - Unable to perform SYNCPOINT '
                       DELIMITED BY SIZE,
                       'ROLLBACK.' DELIMITED BY SIZE,
                       ' Possible integrity issue following VSAM RLS '
                       DELIMITED BY SIZE,
                       'abend.'
                       DELIMITED BY SIZE,
                       ' EIBRESP=' DELIMITED BY SIZE,
                       ABND-RESPCODE DELIMITED BY SIZE,
                       ' RESP2=' DELIMITED BY SIZE,
                       ABND-RESP2CODE DELIMITED BY SIZE
                       INTO ABND-FREEFORM
                    END-STRING

                    EXEC CICS LINK PROGRAM(WS-ABEND-PGM)
                           COMMAREA(ABNDINFO-REC)
                    END-EXEC

                    DISPLAY 'XFRFUN: Unable to perform Syncpoint '
                       'Rollback. Possible Integrity issue following '
                       ' VSAM RLS abend RESP CODE='
                       WS-CICS-RESP ' RESP2 CODE=' WS-CICS-RESP2

                    EXEC CICS
                       ABEND
                       ABCODE ('HROL')
                    END-EXEC

                 END-IF

                 MOVE 'N' TO COMM-SUCCESS
                 MOVE '2' TO COMM-FAIL-CODE

                 EXEC CICS RETURN
                 END-EXEC

           END-EVALUATE.

           IF WS-STORM-DRAIN = 'N'

              EXEC CICS ABEND ABCODE( MY-ABEND-CODE)
              NODUMP
              END-EXEC

           END-IF.

       AH999.
           EXIT.


       POPULATE-TIME-DATE SECTION.
       PTD010.

           EXEC CICS ASKTIME
              ABSTIME(WS-U-TIME)
           END-EXEC.

           EXEC CICS FORMATTIME
                     ABSTIME(WS-U-TIME)
                     DDMMYYYY(WS-ORIG-DATE)
                     TIME(WS-TIME-NOW)
                     DATESEP
           END-EXEC.

       PTD999.
           EXIT.

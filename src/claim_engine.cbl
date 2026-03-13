       IDENTIFICATION DIVISION.
       PROGRAM-ID. CLAIMENGINE.

       ENVIRONMENT DIVISION.

       DATA DIVISION.
       WORKING-STORAGE SECTION.

       COPY "../copybooks/policy_record.cpy".
       COPY "../copybooks/rider_record.cpy".

       01 CLAIM-ID            PIC 9(10).
       01 CLAIM-AMOUNT        PIC 9(7)V99.
       01 APPROVED-AMOUNT     PIC 9(7)V99.
       01 CLAIM-STATUS        PIC X(10).
       01 CLAIM-TYPE          PIC X(20).

       PROCEDURE DIVISION.

       MAIN-CLAIM.

           DISPLAY "================================="
           DISPLAY " MINI INGENIUM CLAIM ENGINE "
           DISPLAY "================================="

      * Step 1: Receive claim

           DISPLAY "ENTER CLAIM ID:"
           ACCEPT CLAIM-ID

           DISPLAY "ENTER POLICY ID:"
           ACCEPT POLICY-ID

           DISPLAY "ENTER CLAIM TYPE:"
           ACCEPT CLAIM-TYPE

           DISPLAY "ENTER CLAIM AMOUNT:"
           ACCEPT CLAIM-AMOUNT

      * Step 2: Validate policy

           DISPLAY "STEP 2 - VALIDATE POLICY"

           IF POLICY-STATUS = "ACTIVE"
                DISPLAY "POLICY VALID"
           ELSE
                DISPLAY "POLICY NOT ACTIVE"
                MOVE "REJECTED" TO CLAIM-STATUS
                GO TO CLAIM-END
           END-IF

      * Step 3: Calculate payout

           DISPLAY "STEP 3 - CALCULATE CLAIM PAYOUT"

           IF CLAIM-TYPE = "ACCIDENT"
                COMPUTE APPROVED-AMOUNT = CLAIM-AMOUNT * 0.80
           ELSE
                COMPUTE APPROVED-AMOUNT = CLAIM-AMOUNT * 0.50
           END-IF

      * Step 4: Approve claim

           MOVE "APPROVED" TO CLAIM-STATUS

           DISPLAY "CLAIM APPROVED"
           DISPLAY "APPROVED AMOUNT: " APPROVED-AMOUNT

      * Step 5: Update policy

           DISPLAY "STEP 5 - UPDATE POLICY STATUS"

           IF CLAIM-TYPE = "DEATH"
                MOVE "TERMINATED" TO POLICY-STATUS
           END-IF

           DISPLAY "POLICY STATUS: " POLICY-STATUS

       CLAIM-END.

           DISPLAY "================================="
           DISPLAY " CLAIM PROCESS COMPLETED "
           DISPLAY "================================="

           STOP RUN.
IDENTIFICATION DIVISION.
       PROGRAM-ID. BILLINGBATCH.

       ENVIRONMENT DIVISION.

       DATA DIVISION.
       WORKING-STORAGE SECTION.
       EXEC SQL BEGIN DECLARE SECTION END-EXEC.
       01 DB-POLICY-ID     PIC 9(6).
       01 DB-PREMIUM       PIC 9(7)V99.
       01 DB-DUE-DATE      PIC X(10).
       EXEC SQL END DECLARE SECTION END-EXEC.
       01 SQLCODE          PIC S9(9) COMP VALUE 0.

       PROCEDURE DIVISION.
           DISPLAY "--- BATCH BILLING PROCESS START ---".
           EXEC SQL CONNECT TO 'db/database.db' END-EXEC.
           EXEC SQL
               DECLARE policy_cursor CURSOR FOR
               SELECT policy_id, base_premium FROM policy
               WHERE status = 'ACTIVE'
           END-EXEC.
           EXEC SQL OPEN policy_cursor END-EXEC.
           PERFORM UNTIL SQLCODE NOT = 0
               EXEC SQL
                   FETCH policy_cursor INTO :DB-POLICY-ID, :DB-PREMIUM
               END-EXEC
               IF SQLCODE = 0
                   DISPLAY "GENERATING INVOICE FOR POLICY: " DB-POLICY-ID
                   EXEC SQL
                       INSERT INTO invoice (policy_id, amount, status)
                       VALUES (:DB-POLICY-ID, :DB-PREMIUM, 'UNPAID')
                   END-EXEC
               END-IF
           END-PERFORM.
           EXEC SQL CLOSE policy_cursor END-EXEC.
           EXEC SQL COMMIT END-EXEC.
           EXEC SQL DISCONNECT CURRENT END-EXEC.
           DISPLAY "--- BATCH BILLING PROCESS FINISHED ---".
           STOP RUN.
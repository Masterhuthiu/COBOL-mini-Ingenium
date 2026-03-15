IDENTIFICATION DIVISION.
       PROGRAM-ID. CreatePolicy.
      * ******************************************************************
      * Chuong trinh khoi tao bang Policy cho he thong Mini-Ingenium
      * ******************************************************************
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       EXEC SQL BEGIN DECLARE SECTION END-EXEC.
       01  DBNAME    PIC X(30) VALUE "testdb".
       01  USERNAME  PIC X(30) VALUE "postgres".
       01  PASSWD    PIC X(10) VALUE SPACE.
       EXEC SQL END DECLARE SECTION END-EXEC.

       EXEC SQL INCLUDE SQLCA END-EXEC.

       PROCEDURE DIVISION.
       MAIN-RTN.
           DISPLAY "--- DANG KHOI TAO SCHEMA POLICY ---".

           *> 1. KET NOI DATABASE
           EXEC SQL
               CONNECT :USERNAME IDENTIFIED BY :PASSWD USING :DBNAME 
           END-EXEC.
           IF SQLCODE NOT = ZERO PERFORM ERROR-RTN STOP RUN.

           *> 2. XOA BANG CU NEU TON TAI (giong mau INSERTTBL)
           EXEC SQL
               DROP TABLE IF EXISTS POLICY
           END-EXEC.

           *> 3. TAO BANG MOI
           EXEC SQL
                CREATE TABLE POLICY
                (
                    POLICY_ID   BIGINT NOT NULL,
                    STATUS      CHAR(10),
                    CONSTRAINT IPOLICY_0 PRIMARY KEY (POLICY_ID)
                )
           END-EXEC.
           IF SQLCODE NOT = ZERO PERFORM ERROR-RTN STOP RUN.

           EXEC SQL COMMIT WORK END-EXEC.
           
           EXEC SQL DISCONNECT ALL END-EXEC.

           DISPLAY "✅ KHOI TAO BANG POLICY THANH CONG.".
           STOP RUN.

       ERROR-RTN.
           DISPLAY "❌ SQL ERROR: " SQLCODE.
           DISPLAY SQLERRMC.
           EXEC SQL ROLLBACK END-EXEC.
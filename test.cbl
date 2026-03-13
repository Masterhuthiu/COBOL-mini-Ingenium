IDENTIFICATION DIVISION.
PROGRAM-ID. TESTSQL.

DATA DIVISION.
WORKING-STORAGE SECTION.
EXEC SQL BEGIN DECLARE SECTION END-EXEC.
01 DB-ID            PIC 9(3).
01 DB-NAME          PIC X(20).
EXEC SQL END DECLARE SECTION END-EXEC.

PROCEDURE DIVISION.
    DISPLAY "--- Kiem tra ket noi SQLite ---".

    * Ket noi den file database
    EXEC SQL CONNECT TO 'test.db' END-EXEC.

    * Tao bang va chen du lieu mau
    EXEC SQL 
        CREATE TABLE IF NOT EXISTS users (id INT, name TEXT) 
    END-EXEC.
    
    EXEC SQL 
        INSERT INTO users (id, name) VALUES (1, 'User Test') 
    END-EXEC.

    * Truy van du lieu
    MOVE 1 TO DB-ID.
    EXEC SQL
        SELECT name INTO :DB-NAME FROM users WHERE id = :DB-ID
    END-EXEC.

    IF SQLCODE = 0
        DISPLAY "Ket qua truy van: ID=" DB-ID " Name=" DB-NAME
    ELSE
        DISPLAY "Loi truy van: SQLCODE=" SQLCODE
    END-IF.

    EXEC SQL COMMIT END-EXEC.
    EXEC SQL DISCONNECT CURRENT END-EXEC.
    
    DISPLAY "--- Ket thuc kiem tra ---".
    GOBACK.
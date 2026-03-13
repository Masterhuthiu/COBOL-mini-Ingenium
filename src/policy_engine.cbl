       IDENTIFICATION DIVISION.
       PROGRAM-ID. POLICYENGINE.

       ENVIRONMENT DIVISION.

       DATA DIVISION.
       WORKING-STORAGE SECTION.

       COPY "../copybooks/policy_record.cpy".
       COPY "../copybooks/rider_record.cpy".

       01 TOTAL-PREMIUM      PIC 9(7)V99.

       PROCEDURE DIVISION.

       MAIN-PROCEDURE.

           DISPLAY "=============================="
           DISPLAY " MINI INGENIUM POLICY ENGINE "
           DISPLAY "=============================="

      * Input policy information

           DISPLAY "ENTER POLICY ID:"
           ACCEPT POLICY-ID

           DISPLAY "ENTER CUSTOMER NAME:"
           ACCEPT CUSTOMER-NAME

           DISPLAY "ENTER PRODUCT CODE:"
           ACCEPT PRODUCT-CODE

           DISPLAY "ENTER BASE PREMIUM:"
           ACCEPT BASE-PREMIUM

      * Rider information

           DISPLAY "ENTER RIDER TYPE:"
           ACCEPT RIDER-TYPE

           DISPLAY "ENTER RIDER PREMIUM:"
           ACCEPT RIDER-PREMIUM

      * Call rating engine

           CALL "RATINGENGINE"
                USING BASE-PREMIUM
                      RIDER-PREMIUM
                      TOTAL-PREMIUM

      * Display result

           DISPLAY "------------------------------"
           DISPLAY "POLICY CREATED"
           DISPLAY "POLICY ID: " POLICY-ID
           DISPLAY "CUSTOMER: " CUSTOMER-NAME
           DISPLAY "PRODUCT: " PRODUCT-CODE
           DISPLAY "TOTAL PREMIUM: " TOTAL-PREMIUM
           DISPLAY "------------------------------"

           STOP RUN.
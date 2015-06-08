CREATE OR REPLACE PACKAGE pDebug IS

  is_debug BOOLEAN := FALSE;

  PROCEDURE put(p_message VARCHAR2);
END pDebug;
/
CREATE OR REPLACE PACKAGE BODY pDebug IS
  PROCEDURE put(p_message VARCHAR2) IS
  BEGIN
    IF (is_debug)
    THEN
      DBMS_OUTPUT.PUT_LINE(p_message);
    END IF;
  END put;
END pDebug;
/

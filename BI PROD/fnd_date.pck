CREATE OR REPLACE PACKAGE fnd_date IS

  FUNCTION canonical_to_date(p IN VARCHAR2) RETURN DATE;
END fnd_date;
/
CREATE OR REPLACE PACKAGE BODY fnd_date IS

  FUNCTION canonical_to_date(p IN VARCHAR2) RETURN DATE IS
  BEGIN
    RETURN to_date(p, 'yyyymmddhh24');
  END;

END fnd_date;
/

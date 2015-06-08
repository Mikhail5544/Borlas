CREATE OR REPLACE FUNCTION GET_USER_NAME
(
  str VARCHAR2
 ,NUM NUMBER
) RETURN VARCHAR2 IS
  ret VARCHAR2(1000);
  i   NUMBER := 1;
  i_l NUMBER := 1;
BEGIN
  IF (NUM <> 0)
  THEN
    i   := INSTR(str, ' ', 1, NUM);
    i_l := INSTR(str, ' ', 1, NUM + 1) - 1;
  
    IF (i_l = 0)
    THEN
      i_l := LENGTH(str);
    END IF;
  
    i_l := LENGTH(str) - i_l;
  END IF;

  IF (NUM = 0)
  THEN
    i   := 0;
    i_l := INSTR(str, ' ', 1, NUM + 1) - 1;
  
    IF (i_l = 0)
    THEN
      i_l := LENGTH(str);
    END IF;
  
  END IF;
  ret := SUBSTR(str, i + 1, i_l);

  RETURN ret;
END;
/

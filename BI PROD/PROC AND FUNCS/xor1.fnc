CREATE OR REPLACE FUNCTION xor1(x1 IN boolean, x2 IN boolean) return NUMBER IS
y BOOLEAN;
BEGIN
     y := (x1 OR x2) AND ((NOT x1) OR (NOT x2));
      CASE y
      WHEN TRUE THEN RETURN 1;
      ELSE RETURN 0;
      END CASE;     
END;
/


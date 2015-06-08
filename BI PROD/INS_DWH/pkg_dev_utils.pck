CREATE OR REPLACE PACKAGE pkg_dev_utils IS
  FUNCTION compile_obj RETURN NUMBER;
END pkg_dev_utils;
/
CREATE OR REPLACE PACKAGE BODY pkg_dev_utils IS
  FUNCTION compile_obj RETURN NUMBER IS
  BEGIN
  
    FOR rec IN (SELECT * FROM META_DATA ORDER BY RENEW_ORDER ASC)
    LOOP
      EXECUTE IMMEDIATE ' ALTER  MATERIALIZED VIEW ' || rec.NAME_DB_OBJECT || ' COMPILE';
    END LOOP;
  
    RETURN 1;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
  END compile_obj;
END pkg_dev_utils;
/

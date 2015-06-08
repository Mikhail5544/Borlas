CREATE OR REPLACE PACKAGE pkg_sqlloader IS

  -- Author  : VUSTINOV
  -- Created : 06.06.2007 15:45:42

  -- вызывается из пакета загрузки
  PROCEDURE clear_temp_table
  (
    p_table_name VARCHAR2
   ,p_sid        NUMBER
  );

  -- вызывается из JOB ежедневно в 01:00
  PROCEDURE clear_temp_table_auto;

END;
/
CREATE OR REPLACE PACKAGE BODY pkg_sqlloader IS

  PROCEDURE clear_temp_table
  (
    p_table_name VARCHAR2
   ,p_sid        NUMBER
  ) IS
  BEGIN
    EXECUTE IMMEDIATE 'delete from ' || p_table_name || ' where session_id = ' || p_sid;
  END;

  PROCEDURE clear_temp_table_auto IS
  BEGIN
    DELETE FROM dms_price_tmp WHERE load_date < trunc(SYSDATE) - 1 / 24;
    DELETE osago_assured_temp WHERE load_date < trunc(SYSDATE) - 1 / 24;
  END;

END;
/

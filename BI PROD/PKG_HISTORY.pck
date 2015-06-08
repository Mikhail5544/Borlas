CREATE OR REPLACE PACKAGE PKG_HISTORY IS

  -- Author  : ARTUR.BAYTIN
  -- Created : 09.09.2011 16:25:50
  -- Purpose : Используется для ведения истории изменения записей сущностей
  -- ToDo    : Сделать register_table - для автоматического формирования триггеров
  --           Сделать is_logging - для проверки необходимости логирования

  PROCEDURE start_log(par_reset BOOLEAN DEFAULT TRUE);

  PROCEDURE commit_log
  (
    par_ure_id      NUMBER
   ,par_uro_id      NUMBER
   ,par_change_type VARCHAR2
   ,par_log_anyway  BOOLEAN DEFAULT TRUE
  );

  PROCEDURE log_column
  (
    par_column     VARCHAR2
   ,par_new_value  VARCHAR2
   ,par_old_value  VARCHAR2
   ,par_just_check BOOLEAN DEFAULT TRUE
  );

  FUNCTION get_last_user
  (
    par_ure_id NUMBER
   ,par_uro_id NUMBER
  ) RETURN VARCHAR2;

  FUNCTION get_last_change_type
  (
    par_ure_id NUMBER
   ,par_uro_id NUMBER
  ) RETURN VARCHAR2;

  FUNCTION get_last_table_id
  (
    par_ure_id NUMBER
   ,par_uro_id NUMBER
  ) RETURN NUMBER;

  FUNCTION get_last_change_date
  (
    par_ure_id NUMBER
   ,par_uro_id NUMBER
  ) RETURN DATE;

--  procedure register_table;
--  function is_logging;
END PKG_HISTORY;
/
CREATE OR REPLACE PACKAGE BODY PKG_HISTORY IS

  gv_table_id          NUMBER;
  gv_is_column_changed BOOLEAN;

  PROCEDURE start_log(par_reset BOOLEAN DEFAULT TRUE) IS
  BEGIN
    SELECT sq_history_tables.nextval INTO gv_table_id FROM dual;
  
    gv_is_column_changed := NOT par_reset;
  
  END start_log;

  PROCEDURE commit_log
  (
    par_ure_id      NUMBER
   ,par_uro_id      NUMBER
   ,par_change_type VARCHAR2
   ,par_log_anyway  BOOLEAN DEFAULT TRUE
  ) IS
  BEGIN
    IF par_log_anyway
       OR NOT par_log_anyway
       AND gv_is_column_changed
    THEN
      INSERT INTO history_tables
        (history_tables_id, ure_id, uro_id, sys_user_id, change_type, change_date)
      VALUES
        (gv_table_id
        ,par_ure_id
        ,par_uro_id
        ,(SELECT sys_user_id FROM sys_user su WHERE su.sys_user_name = USER)
        ,upper(par_change_type)
        ,SYSDATE);
    END IF;
  END commit_log;

  PROCEDURE log_column
  (
    par_column     VARCHAR2
   ,par_new_value  VARCHAR2
   ,par_old_value  VARCHAR2
   ,par_just_check BOOLEAN DEFAULT TRUE
  ) IS
  BEGIN
    IF par_new_value != par_old_value
       OR (par_new_value IS NULL AND par_old_value IS NOT NULL)
       OR (par_new_value IS NOT NULL AND par_old_value IS NULL)
    THEN
      IF NOT par_just_check
      THEN
        INSERT INTO history_columns
          (history_columns_id, history_tables_id, column_name, new_value, old_value)
          SELECT sq_history_columns.nextval
                ,gv_table_id
                ,upper(par_column)
                ,par_new_value
                ,par_old_value
            FROM dual;
      END IF;
      gv_is_column_changed := TRUE;
    
    END IF;
  END log_column;

  FUNCTION get_last_user
  (
    par_ure_id NUMBER
   ,par_uro_id NUMBER
  ) RETURN VARCHAR2 IS
    v_user_name sys_user.sys_user_name%TYPE;
  BEGIN
    SELECT su.sys_user_name
      INTO v_user_name
      FROM sys_user su
     WHERE su.sys_user_id = (SELECT sys_user_id
                               FROM (SELECT ht.sys_user_id
                                       FROM ven_history_tables ht
                                      WHERE ht.ure_id = par_ure_id
                                        AND ht.uro_id = par_uro_id
                                      ORDER BY ht.change_date DESC)
                              WHERE rownum = 1);
    RETURN v_user_name;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN NULL;
  END get_last_user;

  FUNCTION get_last_change_type
  (
    par_ure_id NUMBER
   ,par_uro_id NUMBER
  ) RETURN VARCHAR2 IS
    v_change_type history_tables.change_type%TYPE;
  BEGIN
    SELECT change_type
      INTO v_change_type
      FROM (SELECT ht.change_type
              FROM ven_history_tables ht
             WHERE ht.ure_id = par_ure_id
               AND ht.uro_id = par_uro_id
             ORDER BY ht.change_date DESC)
     WHERE rownum = 1;
    RETURN v_change_type;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN NULL;
  END;

  FUNCTION get_last_table_id
  (
    par_ure_id NUMBER
   ,par_uro_id NUMBER
  ) RETURN NUMBER IS
    v_history_tables_id NUMBER;
  BEGIN
    SELECT MAX(ht.history_tables_id)
      INTO v_history_tables_id
      FROM ven_history_tables ht
     WHERE ht.ure_id = par_ure_id
       AND ht.uro_id = par_uro_id;
    RETURN v_history_tables_id;
  END;

  FUNCTION get_last_change_date
  (
    par_ure_id NUMBER
   ,par_uro_id NUMBER
  ) RETURN DATE IS
    v_change_date DATE;
  BEGIN
    SELECT MAX(ht.change_date)
      INTO v_change_date
      FROM ven_history_tables ht
     WHERE ht.ure_id = par_ure_id
       AND ht.uro_id = par_uro_id;
    RETURN v_change_date;
  END;
END PKG_HISTORY;
/

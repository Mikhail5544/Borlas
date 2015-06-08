CREATE OR REPLACE PACKAGE PKG_B2B_PROPS_VALS_FRM IS

  -- Author  : ARTUR.BAYTIN
  -- Created : 01.10.2012 15:41:39
  -- Purpose : Работа со справочником "Значения" для настройки взаимодействия с B2B

  -- Добавление записи
  -- par_b2b_props_db_id   - ID справочника БД
  -- par_b2b_props_oper_id - ID справочника операций
  -- par_b2b_props_type_id - ID справочника видов свойств
  -- par_props_value       - Значение
  -- На выходе    - ID записи
  FUNCTION insert_record
  (
    par_b2b_props_db_id   NUMBER
   ,par_b2b_props_oper_id NUMBER
   ,par_b2b_props_type_id NUMBER
   ,par_props_value       VARCHAR2
  ) RETURN NUMBER;

  -- Добавление записи
  -- par_db_brief    - Brief справочника БД
  -- par_oper_brief  - Brief справочника операций
  -- par_type_brief  - Brief справочника видов свойств
  -- par_props_value - Значение
  -- На выходе       - ID записи
  FUNCTION insert_record
  (
    par_db_brief    VARCHAR2
   ,par_oper_brief  VARCHAR2
   ,par_type_brief  VARCHAR2
   ,par_props_value VARCHAR2
  ) RETURN NUMBER;

  -- Исправление записи
  -- par_b2b_props_vals_id - ID записи
  -- par_b2b_props_db_id   - ID справочника БД
  -- par_b2b_props_oper_id - ID справочника операций
  -- par_b2b_props_type_id - ID справочника видов свойств
  -- par_props_value       - Значение

  PROCEDURE update_record
  (
    par_b2b_props_vals_id NUMBER
   ,par_b2b_props_db_id   NUMBER
   ,par_b2b_props_oper_id NUMBER
   ,par_b2b_props_type_id NUMBER
   ,par_props_value       VARCHAR2
  );

  -- Удаление записи
  -- par_b2b_props_vals_id - ID записи
  PROCEDURE delete_record(par_b2b_props_vals_id NUMBER);

END PKG_B2B_PROPS_VALS_FRM;
/
CREATE OR REPLACE PACKAGE BODY PKG_B2B_PROPS_VALS_FRM IS

  -- Добавление записи
  -- par_b2b_props_db_id   - ID справочника БД
  -- par_b2b_props_oper_id - ID справочника операций
  -- par_b2b_props_type_id - ID справочника видов свойств
  -- par_props_value       - Значение
  -- На выходе             - ID записи
  FUNCTION insert_record
  (
    par_b2b_props_db_id   NUMBER
   ,par_b2b_props_oper_id NUMBER
   ,par_b2b_props_type_id NUMBER
   ,par_props_value       VARCHAR2
  ) RETURN NUMBER IS
    v_b2b_props_vals_id NUMBER;
  BEGIN
    IF par_props_value IS NULL
    THEN
      raise_application_error(-20001
                             ,'Невозможно вставить запись, т.к. не указано значение!');
    END IF;
  
    SELECT sq_t_b2b_props_vals.nextval INTO v_b2b_props_vals_id FROM dual;
  
    INSERT INTO ven_t_b2b_props_vals
      (t_b2b_props_vals_id, t_b2b_props_db_id, t_b2b_props_oper_id, t_b2b_props_type_id, props_value)
    VALUES
      (v_b2b_props_vals_id
      ,par_b2b_props_db_id
      ,par_b2b_props_oper_id
      ,par_b2b_props_type_id
      ,par_props_value);
  
    RETURN v_b2b_props_vals_id;
  EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
      raise_application_error(-20001
                             ,'Добавление записи невозможно из-за дублирования комбинации значений БД, операция, вида св-в!');
  END insert_record;

  -- Добавление записи
  -- par_db_brief    - Brief справочника БД
  -- par_oper_brief  - Brief справочника операций
  -- par_type_brief  - Brief справочника видов свойств
  -- par_props_value - Значение
  -- На выходе       - ID записи
  FUNCTION insert_record
  (
    par_db_brief    VARCHAR2
   ,par_oper_brief  VARCHAR2
   ,par_type_brief  VARCHAR2
   ,par_props_value VARCHAR2
  ) RETURN NUMBER IS
    v_props_db_id   NUMBER;
    v_props_oper_id NUMBER;
    v_props_type_id NUMBER;
    v_vals_id       NUMBER;
  BEGIN
    BEGIN
      SELECT db.t_b2b_props_db_id
        INTO v_props_db_id
        FROM ven_t_b2b_props_db db
       WHERE db.db_brief = par_db_brief;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        raise_application_error(-20001
                               ,'Не найдена запись в справочнике баз данных с обозначением "' ||
                                par_db_brief || '"');
    END;
  
    BEGIN
      SELECT db.t_b2b_props_oper_id
        INTO v_props_oper_id
        FROM ven_t_b2b_props_oper db
       WHERE db.oper_brief = par_oper_brief;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        raise_application_error(-20001
                               ,'Не найдена запись в справочнике операций с обозначением "' ||
                                par_oper_brief || '"');
    END;
  
    BEGIN
      SELECT db.t_b2b_props_type_id
        INTO v_props_type_id
        FROM ven_t_b2b_props_type db
       WHERE db.type_brief = par_type_brief;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        raise_application_error(-20001
                               ,'Не найдена запись в справочнике видов свойств с обозначением "' ||
                                par_type_brief || '"');
    END;
  
    v_vals_id := pkg_b2b_props_vals_frm.insert_record(par_b2b_props_db_id   => v_props_db_id
                                                     ,par_b2b_props_oper_id => v_props_oper_id
                                                     ,par_b2b_props_type_id => v_props_type_id
                                                     ,par_props_value       => par_props_value);
    RETURN v_vals_id;
  END insert_record;

  -- Исправление записи
  -- Исправление записи
  -- par_b2b_props_vals_id - ID записи
  -- par_b2b_props_db_id   - ID справочника БД
  -- par_b2b_props_oper_id - ID справочника операций
  -- par_b2b_props_type_id - ID справочника видов свойств
  PROCEDURE update_record
  (
    par_b2b_props_vals_id NUMBER
   ,par_b2b_props_db_id   NUMBER
   ,par_b2b_props_oper_id NUMBER
   ,par_b2b_props_type_id NUMBER
   ,par_props_value       VARCHAR2
  ) IS
  BEGIN
    UPDATE ven_t_b2b_props_vals db
       SET db.t_b2b_props_db_id   = par_b2b_props_db_id
          ,db.t_b2b_props_oper_id = par_b2b_props_oper_id
          ,db.t_b2b_props_type_id = par_b2b_props_type_id
          ,db.props_value         = par_props_value
     WHERE db.t_b2b_props_vals_id = par_b2b_props_vals_id;
  EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
      raise_application_error(-20001
                             ,'Исправление записи невозможно из-за дублирования комбинации значений БД, операция, вида св-в!');
  END update_record;

  -- Удаление записи
  -- par_b2b_props_vals_id - ID записи
  PROCEDURE delete_record(par_b2b_props_vals_id NUMBER) IS
  BEGIN
    DELETE FROM ven_t_b2b_props_vals db WHERE db.t_b2b_props_vals_id = par_b2b_props_vals_id;
  END delete_record;

END PKG_B2B_PROPS_VALS_FRM;
/

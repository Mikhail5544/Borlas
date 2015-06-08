CREATE OR REPLACE PACKAGE PKG_B2B_PROPS_OPER_FRM IS

  -- Author  : ARTUR.BAYTIN
  -- Created : 01.10.2012 15:41:39
  -- Purpose : Работа со справочником "Операции" для настройки взаимодействия с B2B

  -- Добавление записи
  -- par_db_brief - Обозначение
  -- par_db_name  - Название
  -- На выходе    - ID записи
  FUNCTION insert_record
  (
    par_oper_brief VARCHAR2
   ,par_oper_name  VARCHAR2
  ) RETURN NUMBER;

  -- Исправление записи
  -- par_b2b_props_db_id - ID записи
  -- par_db_brief        - Обозначение
  -- par_db_name         - Название
  PROCEDURE update_record
  (
    par_b2b_props_oper_id NUMBER
   ,par_oper_brief        VARCHAR2
   ,par_oper_name         VARCHAR2
  );

  -- Удаление записи
  -- par_b2b_props_db_id - ID записи
  PROCEDURE delete_record(par_b2b_props_oper_id NUMBER);

END PKG_B2B_PROPS_OPER_FRM;
/
CREATE OR REPLACE PACKAGE BODY PKG_B2B_PROPS_OPER_FRM IS

  -- Добавление записи
  -- par_db_brief - Обозначение
  -- par_db_name  - Название
  -- На выходе    - ID записи
  FUNCTION insert_record
  (
    par_oper_brief VARCHAR2
   ,par_oper_name  VARCHAR2
  ) RETURN NUMBER IS
    v_b2b_props_oper_id NUMBER;
  BEGIN
    SELECT sq_t_b2b_props_oper.nextval INTO v_b2b_props_oper_id FROM dual;
  
    INSERT INTO ven_t_b2b_props_oper
      (t_b2b_props_oper_id, oper_brief, oper_name)
    VALUES
      (v_b2b_props_oper_id, par_oper_brief, par_oper_name);
  
    RETURN v_b2b_props_oper_id;
  EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
      raise_application_error(-20001
                             ,'Добавление записи невозможно из-за дублирования названия/обозначения операции!');
  END insert_record;

  -- Исправление записи
  -- par_b2b_props_db_id - ID записи
  -- par_db_brief        - Обозначение
  -- par_db_name         - Название
  PROCEDURE update_record
  (
    par_b2b_props_oper_id NUMBER
   ,par_oper_brief        VARCHAR2
   ,par_oper_name         VARCHAR2
  ) IS
  BEGIN
    UPDATE ven_t_b2b_props_oper db
       SET db.oper_brief = par_oper_brief
          ,db.oper_name  = par_oper_name
     WHERE db.t_b2b_props_oper_id = par_b2b_props_oper_id;
  EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
      raise_application_error(-20001
                             ,'Исправление записи невозможно из-за дублирования названия/обозначения операции!');
  END update_record;

  -- Удаление записи
  -- par_b2b_props_db_id - ID записи
  PROCEDURE delete_record(par_b2b_props_oper_id NUMBER) IS
  BEGIN
    DELETE FROM ven_t_b2b_props_oper db WHERE db.t_b2b_props_oper_id = par_b2b_props_oper_id;
  END delete_record;

END PKG_B2B_PROPS_OPER_FRM;
/

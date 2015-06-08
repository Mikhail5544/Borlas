CREATE OR REPLACE PACKAGE PKG_B2B_PROPS_DB_FRM IS

  -- Author  : ARTUR.BAYTIN
  -- Created : 01.10.2012 15:41:39
  -- Purpose : Работа со справочником "Базы данных" для настройки взаимодействия с B2B

  -- Добавление записи
  -- par_db_brief - Обозначение
  -- par_db_name  - Название
  -- На выходе    - ID записи
  FUNCTION insert_record
  (
    par_db_brief VARCHAR2
   ,par_db_name  VARCHAR2
  ) RETURN NUMBER;

  -- Исправление записи
  -- par_b2b_props_db_id - ID записи
  -- par_db_brief        - Обозначение
  -- par_db_name         - Название
  PROCEDURE update_record
  (
    par_b2b_props_db_id NUMBER
   ,par_db_brief        VARCHAR2
   ,par_db_name         VARCHAR2
  );

  -- Удаление записи
  -- par_b2b_props_db_id - ID записи
  PROCEDURE delete_record(par_b2b_props_db_id NUMBER);

END PKG_B2B_PROPS_DB_FRM;
/
CREATE OR REPLACE PACKAGE BODY PKG_B2B_PROPS_DB_FRM IS

  -- Добавление записи
  -- par_db_brief - Обозначение
  -- par_db_name  - Название
  -- На выходе    - ID записи
  FUNCTION insert_record
  (
    par_db_brief VARCHAR2
   ,par_db_name  VARCHAR2
  ) RETURN NUMBER IS
    v_b2b_props_db_id NUMBER;
  BEGIN
    SELECT sq_t_b2b_props_db.nextval INTO v_b2b_props_db_id FROM dual;
  
    INSERT INTO ven_t_b2b_props_db
      (t_b2b_props_db_id, db_brief, db_name)
    VALUES
      (v_b2b_props_db_id, par_db_brief, par_db_name);
  
    RETURN v_b2b_props_db_id;
  EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
      raise_application_error(-20001
                             ,'Добавление записи невозможно из-за дублирования названия/обозначения БД!');
  END insert_record;

  -- Исправление записи
  -- par_b2b_props_db_id - ID записи
  -- par_db_brief        - Обозначение
  -- par_db_name         - Название
  PROCEDURE update_record
  (
    par_b2b_props_db_id NUMBER
   ,par_db_brief        VARCHAR2
   ,par_db_name         VARCHAR2
  ) IS
  BEGIN
    UPDATE ven_t_b2b_props_db db
       SET db.db_brief = par_db_brief
          ,db.db_name  = par_db_name
     WHERE db.t_b2b_props_db_id = par_b2b_props_db_id;
  EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
      raise_application_error(-20001
                             ,'Исправление записи невозможно из-за дублирования названия/обозначения БД!');
  END update_record;

  -- Удаление записи
  -- par_b2b_props_db_id - ID записи
  PROCEDURE delete_record(par_b2b_props_db_id NUMBER) IS
  BEGIN
    DELETE FROM ven_t_b2b_props_db db WHERE db.t_b2b_props_db_id = par_b2b_props_db_id;
  END delete_record;

END PKG_B2B_PROPS_DB_FRM;
/

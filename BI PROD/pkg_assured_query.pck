CREATE OR REPLACE PACKAGE pkg_assured_query IS

  -- Author  : PAZUS
  -- Created : 29.09.2013 13:04:33
  -- Purpose : Пакет с набором функций для получения значений поляй участников договора

  -- Public function and procedure declarations
  FUNCTION get_hobby_by_desc
  (
    par_hobby_desc         VARCHAR2
   ,par_raise_on_not_found BOOLEAN DEFAULT TRUE
  ) RETURN t_hobby.t_hobby_id%TYPE;

  FUNCTION get_work_group_by_brief
  (
    par_work_group_brief   VARCHAR2
   ,par_raise_on_not_found BOOLEAN DEFAULT TRUE
  ) RETURN t_work_group.t_work_group_id%TYPE;
	
  FUNCTION get_profession_by_desc
  (
    par_profession_desc    VARCHAR2
   ,par_raise_on_not_found BOOLEAN DEFAULT TRUE
  ) RETURN t_profession.id%TYPE;

END pkg_assured_query;
/
CREATE OR REPLACE PACKAGE BODY pkg_assured_query IS

  FUNCTION get_hobby_by_desc
  (
    par_hobby_desc         VARCHAR2
   ,par_raise_on_not_found BOOLEAN DEFAULT TRUE
  ) RETURN t_hobby.t_hobby_id%TYPE IS
    v_hobby_id t_hobby.t_hobby_id%TYPE;
  BEGIN
  
    SELECT MIN(h.t_hobby_id) INTO v_hobby_id FROM t_hobby h WHERE h.description = par_hobby_desc;
  
    IF v_hobby_id IS NULL
       AND par_raise_on_not_found
    THEN
      raise_application_error(-20001
                             ,'Не удалось определить найти хобби "' || par_hobby_desc ||
                              '" в справочнике');
    END IF;
  
    RETURN v_hobby_id;
  END get_hobby_by_desc;

  FUNCTION get_work_group_by_brief
  (
    par_work_group_brief   VARCHAR2
   ,par_raise_on_not_found BOOLEAN DEFAULT TRUE
  ) RETURN t_work_group.t_work_group_id%TYPE IS
    v_work_group_id t_work_group.t_work_group_id%TYPE;
  BEGIN
  
    BEGIN
      SELECT h.t_work_group_id
        INTO v_work_group_id
        FROM t_work_group h
       WHERE h.description = par_work_group_brief;
    EXCEPTION
      WHEN no_data_found THEN
        IF par_raise_on_not_found
        THEN
          raise_application_error(-20001
                                 ,'Не удалось определить найти группу профессий "' ||
                                  par_work_group_brief || '" в справочнике');
        END IF;
    END;
  
    RETURN v_work_group_id;
  END get_work_group_by_brief;

  FUNCTION get_profession_by_desc
  (
    par_profession_desc    VARCHAR2
   ,par_raise_on_not_found BOOLEAN DEFAULT TRUE
  ) RETURN t_profession.id%TYPE IS
    v_profession_id t_profession.id%TYPE;
  BEGIN
    SELECT MIN(h.id)
      INTO v_profession_id
      FROM t_profession h
     WHERE h.description = par_profession_desc;
  
    IF v_profession_id IS NULL
       AND par_raise_on_not_found
    THEN
      raise_application_error(-20001
                             ,'Не удалось определить найти профессию "' || par_profession_desc ||
                              '" в справочнике');
    END IF;
    RETURN v_profession_id;
  END get_profession_by_desc;

BEGIN
  -- Initialization
  NULL;
END pkg_assured_query;
/

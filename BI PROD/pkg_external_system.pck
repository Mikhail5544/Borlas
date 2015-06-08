CREATE OR REPLACE PACKAGE pkg_external_system IS

  -- Author  : ARTUR.BAYTIN
  -- Created : 16.07.2014 19:14:02
  -- Purpose : Внешние системы

  /* Получить ID системы по ключу */
  FUNCTION get_system_id_by_key(par_md5 VARCHAR2) RETURN t_external_system.t_external_system_id%TYPE;

  /* Получить BRIEF системы по ключу */
  FUNCTION get_system_brief_by_key(par_md5 VARCHAR2) RETURN t_external_system.brief%TYPE;

  /* Закэшировать ID системы*/
  PROCEDURE set_current_system(par_external_system_id t_external_system.t_external_system_id%TYPE);

  /* Получить закэшированный ID системы*/
  FUNCTION get_current_system RETURN t_external_system.t_external_system_id%TYPE;

  /* Проверить соответствие ключа системе */
  FUNCTION check_key_for_system
  (
    par_md5          VARCHAR2
   ,par_system_brief t_external_system.brief%TYPE
  ) RETURN BOOLEAN;

  /*
    Капля П.
    Получение значения ключа для системы
  */
  FUNCTION get_system_key_by_brief(par_system_brief VARCHAR2) RETURN VARCHAR2;
END pkg_external_system;
/
CREATE OR REPLACE PACKAGE BODY pkg_external_system IS

  gv_external_system_id t_external_system.t_external_system_id%TYPE;

  FUNCTION get_system_id_by_key(par_md5 VARCHAR2) RETURN t_external_system.t_external_system_id%TYPE IS
    v_system_id t_external_system.t_external_system_id%TYPE;
  BEGIN
    BEGIN
      SELECT t.t_external_system_id
        INTO v_system_id
        FROM t_external_system t
       WHERE pkg_utils.get_md5_string(t.pass_code) = upper(par_md5);
    EXCEPTION
      WHEN no_data_found THEN
        NULL;
    END;
    RETURN v_system_id;
  END get_system_id_by_key;

  FUNCTION get_system_brief_by_key(par_md5 VARCHAR2) RETURN t_external_system.brief%TYPE IS
    v_system_brief t_external_system.brief%TYPE;
  BEGIN
    BEGIN
      SELECT t.brief
        INTO v_system_brief
        FROM t_external_system t
       WHERE pkg_utils.get_md5_string(t.pass_code) = upper(par_md5);
    EXCEPTION
      WHEN no_data_found THEN
        NULL;
    END;
    RETURN v_system_brief;
  END get_system_brief_by_key;

  PROCEDURE set_current_system(par_external_system_id t_external_system.t_external_system_id%TYPE) IS
  BEGIN
    gv_external_system_id := par_external_system_id;
  END set_current_system;

  FUNCTION get_current_system RETURN t_external_system.t_external_system_id%TYPE IS
  BEGIN
    RETURN gv_external_system_id;
  END;

  FUNCTION check_key_for_system
  (
    par_md5          VARCHAR2
   ,par_system_brief t_external_system.brief%TYPE
  ) RETURN BOOLEAN IS
    v_key VARCHAR2(4000);
  BEGIN
    v_key := get_system_key_by_brief(par_system_brief);
  
    RETURN nvl(upper(par_md5) = v_key, FALSE);
  
  END check_key_for_system;

  /*
    Капля П.
    Получение значения ключа для системы
  */
  FUNCTION get_system_key_by_brief(par_system_brief VARCHAR2) RETURN VARCHAR2 IS
    v_key             VARCHAR2(4000);
    v_external_system dml_t_external_system.tt_t_external_system;
  BEGIN
    v_external_system := dml_t_external_system.get_rec_by_brief(par_system_brief);
  
    v_key := pkg_utils.get_md5_string(v_external_system.pass_code);
  
    RETURN v_key;
  
  END get_system_key_by_brief;

END pkg_external_system;
/

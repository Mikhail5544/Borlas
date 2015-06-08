CREATE OR REPLACE PACKAGE ins.pkg_main_menu IS

  -- Author  : PAVEL.KAPLYA
  -- Created : 05.05.2014 10:48:25
  -- Purpose : Работа с главным меню

  /*
    Капля П.
    Добавление права доступа к меню заданной роли
  */
  PROCEDURE grant_access_to_main_menu_item
  (
    par_main_menu_id     main_menu.main_menu_id%TYPE
   ,par_role_name        ven_sys_role.name%TYPE
   ,par_read_write_right NUMBER DEFAULT 1 -- 1 - Полный доступ, 0 - только на чтение
  );

  /*
    Пиядин А.
    Получение ИД пункта меню по коду формы
  */
  FUNCTION get_id_by_code(par_code VARCHAR2) RETURN NUMBER;

END pkg_main_menu;
/
CREATE OR REPLACE PACKAGE BODY ins.pkg_main_menu IS

  gc_pkg_name CONSTANT VARCHAR2(50) := 'PKG_MAIN_MENU';

  /*
    Капля П.
    Добавление права доступа к меню заданной роли
  */
  PROCEDURE grant_access_to_main_menu_item
  (
    par_main_menu_id     main_menu.main_menu_id%TYPE
   ,par_role_name        ven_sys_role.name%TYPE
   ,par_read_write_right NUMBER DEFAULT 1 -- 1 - Полный доступ, 0 - только на чтение
  ) IS
    v_role_name VARCHAR2(4000);
    c_right_type_brief CONSTANT safety_right_type.brief%TYPE := 'MENU';
  
    add_right_error EXCEPTION;
    PRAGMA EXCEPTION_INIT(add_right_error, -20001);
  
    FUNCTION get_menu_path(par_main_menu_id main_menu.main_menu_id%TYPE) RETURN VARCHAR2 IS
      v_path VARCHAR2(4000);
    BEGIN
      SELECT TRIM(substr(sys_connect_by_path(REPLACE(NAME, '.', '_'), '.'), 2)) NAME
        INTO v_path
        FROM main_menu mm
       WHERE mm.main_menu_id = par_main_menu_id
       START WITH mm.parent_id IS NULL
      CONNECT BY PRIOR mm.main_menu_id = mm.parent_id;
    
      RETURN v_path;
    END get_menu_path;
  BEGIN
    v_role_name := get_menu_path(par_main_menu_id);
  
    BEGIN
      safety.add_safety_right(par_right_name       => v_role_name
                             ,par_right_type_brief => c_right_type_brief);
    EXCEPTION
      -- Процедура может выдать ошибку в двух случаях: если такого пункта меню нет или если право уже существует
      -- Обе ошибка -20001, так что будем надеятся, что передан id существующего пункта меню
      WHEN add_right_error THEN
        NULL;
    END;
  
    safety.assign_right_to_role(par_right_name       => v_role_name
                               ,par_role_name        => par_role_name
                               ,par_right_type_brief => c_right_type_brief
                               ,par_add_flag         => par_read_write_right);
  
  END;

  /*
    Пиядин А.
    Получение ИД пункта меню по коду формы
  */
  FUNCTION get_id_by_code(par_code VARCHAR2) RETURN NUMBER IS
    lc_proc_name VARCHAR2(50) := 'GET_ID_BY_CODE';
    v_id         NUMBER;
  BEGIN
    SELECT main_menu_id INTO v_id FROM main_menu WHERE code = par_code;
  
    RETURN v_id;
  EXCEPTION
    WHEN no_data_found THEN
      ex.raise(par_message => gc_pkg_name || '.' || lc_proc_name || ': форма с кодом "' || par_code ||
                              '" не существует'
              ,par_sqlcode => ex.c_no_data_found);
  END get_id_by_code;

END pkg_main_menu;
/

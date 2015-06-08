CREATE OR REPLACE PACKAGE Pkg_Filial IS

  /**
  * Тип - массив.
  * @author Vitaly Ustinov
  */
  TYPE num_table_type IS TABLE OF NUMBER;

  /**
  * Работает ли механизм филиальности?
  * @author Vitaly Ustinov
  * @return 1/0
  */
  FUNCTION is_filials_enabled RETURN NUMBER;

  /**
  * Уровень филиального доступа пользователя к объекту
  * @author Patsan O.
  * @param par_ent_id ИД сущности
  * @param par_obj_id ИД объекта
  * @param par_add_info Дополнительный параметр
  * @return UPDATE - редактирование, VIEW - просмотр, другое значение или исключение - нет доступа
  */
  FUNCTION get_access_level
  (
    par_ent_id   IN VARCHAR2
   ,par_obj_id   IN NUMBER
   ,par_add_info IN VARCHAR2 DEFAULT NULL
  ) RETURN VARCHAR2;

  /**
  * Уровень филиального доступа пользователя к объекту
  * @author Patsan O.
  * @param par_ent_id Обозначение сущности
  * @param par_obj_id ИД объекта
  * @param par_add_info Дополнительный параметр
  * @return UPDATE - редактирование, VIEW - просмотр, другое значение или исключение - нет доступа
  */
  FUNCTION get_access_level
  (
    par_ent_id   IN NUMBER
   ,par_obj_id   IN NUMBER
   ,par_add_info IN VARCHAR2 DEFAULT NULL
  ) RETURN VARCHAR2;

  /**
  * Вернуть список потомков
  * @author Vitaly Ustinov
  * @param ИД филиала
  * @param Возвращать ли текущий (0 - нет, 1 - да) default = 1
  * @return таблица ИД филиалов
  */
  FUNCTION get_org_tree_childs_table
  (
    p_parent_org_tree_id NUMBER
   ,p_width_parent       NUMBER := 1
  ) RETURN num_table_type
    PIPELINED;

  /**
  * Пользователь является сотрудником центрального офиса?
  * @author Vitaly Ustinov
  * @return 0 - нет, 1 - да
  */
  FUNCTION is_user_in_central_office RETURN NUMBER;

  /**
  * Устанавливает переменную текущего филиала пользователя (ents.filial_id)
  * @author Patsan O.
  * @param ИД филиала
  * @return
  */
  PROCEDURE set_filial_id(par_filial_id IN NUMBER);

  /**
  * Возвращает department_id пользователя
  * @author Vitaly Ustinov
  * @return ИД
  */
  FUNCTION get_user_department_id RETURN NUMBER;
  /**
  * Возвращает organisation_tree_id пользователя
  * @author Vitaly Ustinov
  * @return ИД
  */
  FUNCTION get_user_org_tree_id RETURN NUMBER;

END Pkg_Filial;
/
CREATE OR REPLACE PACKAGE BODY Pkg_Filial IS

  user_department_id NUMBER;
  user_org_tree_id   NUMBER;

  TYPE refcursor_type IS REF CURSOR;

  FUNCTION is_filials_enabled RETURN NUMBER IS
  BEGIN
    RETURN NVL(Pkg_App_Param.get_app_param_n('FILIALS_ENABLED'), 0);
  END;

  FUNCTION get_org_tree_childs_table
  (
    p_parent_org_tree_id NUMBER
   ,p_width_parent       NUMBER := 1
  ) RETURN num_table_type
    PIPELINED IS
    cur            refcursor_type;
    l_org_tree_id  NUMBER;
    l_width_parent NUMBER := p_width_parent;
  BEGIN
    IF is_filials_enabled = 1
    THEN
      OPEN cur FOR
        SELECT organisation_tree_id
          FROM organisation_tree
         START WITH organisation_tree_id = p_parent_org_tree_id
        CONNECT BY PRIOR organisation_tree_id = parent_id;
    ELSE
      OPEN cur FOR
        SELECT organisation_tree_id FROM organisation_tree;
      l_width_parent := 1;
    END IF;
    LOOP
      FETCH cur
        INTO l_org_tree_id;
      EXIT WHEN cur%NOTFOUND;
      IF (l_width_parent <> 0 OR l_org_tree_id <> p_parent_org_tree_id)
      THEN
        PIPE ROW(l_org_tree_id);
      END IF;
    END LOOP;
    CLOSE cur;
    RETURN;
  END;

  FUNCTION is_user_in_central_office RETURN NUMBER IS
    v_found NUMBER;
  BEGIN
    IF is_filials_enabled <> 1
    THEN
      RETURN 1;
    ELSE
      SELECT COUNT(1)
        INTO v_found
        FROM organisation_tree
       WHERE organisation_tree_id = user_org_tree_id
         AND brief = 'ЦО';
      RETURN v_found;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
  END;

  FUNCTION get_user_department_id RETURN NUMBER IS
  BEGIN
    RETURN user_department_id;
  END;

  FUNCTION get_user_org_tree_id RETURN NUMBER IS
  BEGIN
    RETURN user_org_tree_id;
  END;

  FUNCTION get_access_level
  (
    par_ent_id   IN VARCHAR2
   ,par_obj_id   IN NUMBER
   ,par_add_info IN VARCHAR2 DEFAULT NULL
  ) RETURN VARCHAR2 IS
  BEGIN
    IF is_filials_enabled <> 1
    THEN
      RETURN 'UPDATE';
    ELSE
      CASE
        WHEN par_ent_id = 'C_EVENT' THEN
          FOR r_event IN (SELECT c.filial_id FROM c_event c WHERE c.c_event_id = par_obj_id)
          LOOP
            IF NVL(r_event.filial_id, Ents.filial_id) = Ents.filial_id
            THEN
              RETURN 'UPDATE';
            ELSE
              RETURN 'VIEW';
            END IF;
          END LOOP;
        WHEN par_ent_id = 'C_SUBR_DOC' THEN
          FOR r_event IN (SELECT sd.filial_id FROM c_subr_doc sd WHERE sd.c_subr_doc_id = par_obj_id)
          LOOP
            IF NVL(r_event.filial_id, Ents.filial_id) = Ents.filial_id
            THEN
              RETURN 'UPDATE';
            ELSE
              RETURN 'VIEW';
            END IF;
          END LOOP;
        WHEN par_ent_id = 'C_CLAIM_HEADER' THEN
          FOR r_claim IN (SELECT d.org_tree_id filial_id
                            FROM c_claim_header ch
                                ,department     d
                           WHERE ch.c_claim_header_id = par_obj_id
                             AND d.department_id = ch.depart_id)
          LOOP
            IF NVL(r_claim.filial_id, Ents.filial_id) = Ents.filial_id
            THEN
              RETURN 'UPDATE';
            ELSE
              RETURN 'VIEW';
            END IF;
          END LOOP;
        ELSE
          RETURN 'UPDATE';
      END CASE;
    END IF;
    RETURN 'UPDATE';
  END;

  FUNCTION get_access_level
  (
    par_ent_id   IN NUMBER
   ,par_obj_id   IN NUMBER
   ,par_add_info IN VARCHAR2 DEFAULT NULL
  ) RETURN VARCHAR2 IS
  BEGIN
    RETURN get_access_level(Ent.brief_by_id(par_ent_id), par_obj_id, par_add_info);
  END;

  PROCEDURE set_filial_id(par_filial_id IN NUMBER) IS
  BEGIN
    Ents.filial_id := par_filial_id;
  END;

BEGIN
  SELECT ot.organisation_tree_id
        ,eh.department_id
    INTO user_org_tree_id
        ,user_department_id
    FROM sys_user          su
        ,employee          e
        ,organisation_tree ot
        ,employee_hist     eh
   WHERE su.employee_id = e.employee_id
     AND e.organisation_id = ot.organisation_tree_id
     AND eh.employee_id = e.employee_id
     AND eh.date_hist = (SELECT MAX(ehlast.date_hist)
                           FROM employee_hist ehlast
                          WHERE ehlast.employee_id = e.employee_id
                            AND ehlast.date_hist <= SYSDATE
                            AND ehlast.is_kicked = 0)
     AND su.sys_user_name = USER;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    BEGIN
      user_department_id := 0;
      user_org_tree_id   := 0;
    END;
END Pkg_Filial;
/

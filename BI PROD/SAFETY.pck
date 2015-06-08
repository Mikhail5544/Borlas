CREATE OR REPLACE PACKAGE safety IS

  /**
  * ���������� �������, ������, ��������������
  * @author Patsan O.
  */

  /*
    ��������� ��� � ������������ ���� ����
    @author   ALEXEY.KATKEVICH
    @param    user_name 
    @param    role_name
    @return   ���� (1)/��� (0)
  */
  FUNCTION user_have_role
  (
    user_name VARCHAR2
   ,role_name VARCHAR2
  ) RETURN INTEGER;

  /**
  * �������� ������������ �������
  * @author Patsan O.
  * @param name ��������� ��� ������������
  * @param pass ������
  */
  PROCEDURE create_trs_user
  (
    NAME VARCHAR2
   ,pass VARCHAR2
  );

  /**
  * �������� ������������ �������
  * @author Patsan O.
  * @param name ��������� ��� ������������
  */
  PROCEDURE drop_trs_user(NAME VARCHAR2);

  /**
  * ��������� ������ ������������
  * @author Patsan O.
  * @param name ��������� ��� ������������
  * @param pass ������
  */
  PROCEDURE set_pass_trs_user
  (
    NAME VARCHAR2
   ,pass VARCHAR2
  );

  /**
  * ��������� ������� � �����
  * @author Patsan O.
  * @param p_action ������������� ������� �������
  * @param p_form ������������ �����
  * @return ����������� ������� �������
  */
  FUNCTION get_form_access
  (
    p_action VARCHAR2
   ,p_form   VARCHAR2
  ) RETURN VARCHAR2;

  /**
  * ��������� ������� � ������� ���������
  * @author Patsan O.
  * @param p_action ������������� ������� �������
  * @param p_doc_templ ����������� ������� ���������
  * @return ����������� ������� �������
  */
  FUNCTION get_doc_templ_access
  (
    p_action    VARCHAR2
   ,p_doc_templ VARCHAR2
  ) RETURN VARCHAR2;

  /**
  * ��������� �������� ������������
  * @author Patsan O.
  * @return �� �������� ������������
  */
  FUNCTION curr_sys_user RETURN sys_user.sys_user_id%TYPE;

  /**
  * ����������� ���������� �������
  * @author Patsan O.
  * @param p_sys_event_type_id �� ���� �������
  * @param p_event_ent_id �� ��������
  * @param p_event_obj_id �� �������
  * @param p_event_name ������������ �������
  * @param p_val ���������� �������
  */
  PROCEDURE reg_event
  (
    p_sys_event_type_id IN NUMBER
   ,p_event_ent_id      IN NUMBER
   ,p_event_obj_id      IN NUMBER
   ,p_event_name        IN VARCHAR2
   ,p_val               IN CLOB
  );

  /**
  * ����������� �������
  * @author Patsan O.
  * @param p_event_ent_id �� ��������
  * @param p_event_obj_id �� �������
  * @param p_event_name ������������ �������
  * @param p_val ���������� �������
  */
  PROCEDURE reg_event_ins
  (
    p_event_ent_id IN NUMBER
   ,p_event_obj_id IN NUMBER
   ,p_event_name   IN VARCHAR2
   ,p_val          IN CLOB
  );

  /**
  * ����������� ����������
  * @author Patsan O.
  * @param p_event_ent_id �� ��������
  * @param p_event_obj_id �� �������
  * @param p_event_name ������������ �������
  * @param p_val ���������� �������
  */
  PROCEDURE reg_event_upd
  (
    p_event_ent_id IN NUMBER
   ,p_event_obj_id IN NUMBER
   ,p_event_name   IN VARCHAR2
   ,p_val          IN CLOB
  );

  /**
  * ����������� ��������
  * @author Patsan O.
  * @param p_event_ent_id �� ��������
  * @param p_event_obj_id �� �������
  * @param p_event_name ������������ �������
  * @param p_val ���������� �������
  */
  PROCEDURE reg_event_del
  (
    p_event_ent_id IN NUMBER
   ,p_event_obj_id IN NUMBER
   ,p_event_name   IN VARCHAR2
   ,p_val          IN CLOB
  );

  /**
  * ����������� ����������������� �������
  * @author Patsan O.
  * @param p_sys_event_type_id �� ���� �������
  * @param p_event_ent_id �� ��������
  * @param p_event_obj_id �� �������
  * @param p_event_name ������������ ������� 
  * @param p_val ���������� �������
  * @param p_param1 ���������������� ��������
  * @param p_param2 ���������������� ��������
  * @param p_param3 ���������������� ��������
  * @param p_param4 ���������������� ��������
  * @param p_param5 ���������������� ��������
  */
  PROCEDURE reg_user_event
  (
    p_sys_event_type_id IN NUMBER
   ,p_event_ent_id      IN NUMBER
   ,p_event_obj_id      IN NUMBER
   ,p_event_name        IN VARCHAR2
   ,p_val               IN CLOB
   ,p_param1            IN VARCHAR2
   ,p_param2            IN VARCHAR2
   ,p_param3            IN VARCHAR2
   ,p_param4            IN VARCHAR2
   ,p_param5            IN VARCHAR2
  );

  /**
  * ��������� ���� ������� � ������� ��������
  * @author Patsan O.
  * @param �� ��������
  * @param �� �������
  * @param ��������, ������� ������������ "�����" ��������� � ���������
  * @return ��������, ������� �������� ��������� � ���������
  */
  FUNCTION get_obj_safety
  (
    p_ent_id IN NUMBER
   ,p_obj_id IN NUMBER
   ,p_action IN VARCHAR2 DEFAULT NULL
  ) RETURN VARCHAR2;

  /**
  * ��������� ���� ������� � ������� ��������
  * @author Patsan O.
  * @param ����������� ��������
  * @param �� �������
  * @param ��������, ������� ������������ "�����" ��������� � ���������
  * @return ��������, ������� �������� ��������� � ���������
  */
  FUNCTION get_obj_safety
  (
    p_ent_brief IN VARCHAR2
   ,p_obj_id    IN NUMBER
   ,p_action    IN VARCHAR2 DEFAULT NULL
  ) RETURN VARCHAR2;

  /**
  * ��������� ������� ����
  * @author Patsan O.
  * @return �� ������� ����
  */
  FUNCTION get_curr_role RETURN NUMBER;

  /**
  * ��������� �������� ������� ����
  * @author ������ �.
  * @return �������� ������� ����
  */
  FUNCTION get_curr_role_name RETURN VARCHAR2;

  /**
  * ������� �������� RLS ��� ��������
  * @author Patsan O.
  * @param p_schema ������������ �����
  * @param p_object �� �������
  * @return ������ �������
  */
  FUNCTION prod_sec_func
  (
    p_schema IN VARCHAR2
   ,p_object IN VARCHAR2
  ) RETURN VARCHAR2;

  /**
  * ������� �������� RLS ��� ������ �������� ����������
  * @author Patsan O.
  * @param p_schema ������������ �����
  * @param p_object �� �������
  * @return ������ �������
  */
  FUNCTION app_param_group_sec_func
  (
    p_schema IN VARCHAR2
   ,p_object IN VARCHAR2
  ) RETURN VARCHAR2;

  /**
  * ������� �������� RLS ��� ������ ������
  * @author Patsan O.
  * @param p_schema ������������ �����
  * @param p_object �� �������
  * @return ������ �������
  */
  FUNCTION sal_chan_sec_func
  (
    p_schema IN VARCHAR2
   ,p_object IN VARCHAR2
  ) RETURN VARCHAR2;

  /**
  * ������� �������� RLS ��� ��������� ������
  * @author Patsan O.
  * @param p_schema ������������ �����
  * @param p_object �� �������
  * @return ������ �������
  */
  FUNCTION pol_head_sec_func
  (
    p_schema IN VARCHAR2
   ,p_object IN VARCHAR2
  ) RETURN VARCHAR2;

  /**
  * ������� �������� RLS ��� �������� ins_dwh.dm_agency
  * @author Patsan O.
  * @param p_schema ������������ �����
  * @param p_object �� �������
  * @return ������ �������
  */
  FUNCTION dm_agency_sec_func
  (
    p_schema IN VARCHAR2
   ,p_object IN VARCHAR2
  ) RETURN VARCHAR2;

  /**
  * ������� �������� RLS ��� ������� Discoverer
  * @author Patsan O.
  * @param p_schema ������������ �����
  * @param p_object �� �������
  * @return ������ �������
  */
  FUNCTION disco_sec_func
  (
    p_schema IN VARCHAR2
   ,p_object IN VARCHAR2
  ) RETURN VARCHAR2;

  FUNCTION ag_contr_head_sec_func
  (
    p_schema IN VARCHAR2
   ,p_object IN VARCHAR2
  ) RETURN VARCHAR2;

  FUNCTION dep_sec_func
  (
    p_schema IN VARCHAR2
   ,p_object IN VARCHAR2
  ) RETURN VARCHAR2;

  FUNCTION check_right_department(p_obj_id IN NUMBER) RETURN NUMBER;
  /**
  * ��������, ��������� �� ������������ ������������ ����������. 
  * ��������, ���� ����� ���� ����-��������, ��� ����� ���� ����-�������� � ����
  * �����������-������������� 
  * @author Patsan O.
  * @param p_usr USER
  * @return ����: 1-�������� ������������ ����������, 0- ������ ������������
  */
  FUNCTION is_regional_operator(p_usr VARCHAR2) RETURN NUMBER;

  /**
  * ��������� ������������ �����
  * @author Patsan O.
  * @param p_right_id �� �����
  * @return ������������ �����
  */
  FUNCTION get_right_name(p_right_id IN NUMBER) RETURN VARCHAR2;

  /**
  * ��������� ����������� �����
  * @author Patsan O.
  * @param p_right_id �� �����
  * @return ����������� �����
  */
  FUNCTION get_right_brief(p_right_id IN NUMBER) RETURN VARCHAR2;

  /**
  * �������� ����� ������������ �� ������
  * @author Patsan O.
  * @param p_obj_id �� �������
  * @param p_ent_id �� ��������
  * @return ������� ����������� �����
  */
  FUNCTION check_right_object
  (
    p_obj_id IN NUMBER
   ,p_ent_id IN NUMBER
  ) RETURN NUMBER;

  /**
  * �������� ����� ������������ �� ������� ������� ���������
  * @author Patsan O.
  * @param p_obj_id �� �������� �������
  * @return ������� ����������� �����
  */
  FUNCTION check_right_docstatus(p_obj_id IN NUMBER) RETURN NUMBER;

  /**
  * �������� ����� ������������ �� ����� Discoverer
  * @author Patsan O.
  * @param p_obj_id �� ������
  * @return ������� ����������� �����
  */
  FUNCTION check_right_discoverer(p_obj_id IN NUMBER) RETURN NUMBER;

  /**
  * �������� ����� ������������ �� ������ � ������ ����
  * @author Patsan O.
  * @param p_obj_id �� ������ ����
  * @return ������� ����������� �����
  */
  FUNCTION check_right_menu(p_obj_id IN NUMBER) RETURN NUMBER;
  FUNCTION check_right_menu_code(p_obj_id IN NUMBER) RETURN NUMBER;

  FUNCTION check_right_form(p_obj_id IN VARCHAR2) RETURN NUMBER;
  FUNCTION check_right_form_code(p_obj_id IN VARCHAR2) RETURN NUMBER;

  /**
  * �������� ����� ������������ �� ������ � �������� �����
  * @author Patsan O.
  * @param p_obj_id ����������� �������� �����
  * @return ������� ����������� �����
  */
  FUNCTION check_right_item(p_obj_id IN VARCHAR2) RETURN NUMBER;

  /**
  * �������� ����������������� �����
  * @author Patsan O.
  * @param p_obj_id ����������� �����
  * @return ������� ����������� �����
  */
  FUNCTION check_right_custom(p_obj_id IN VARCHAR2) RETURN NUMBER;

  /**
  * �������� ����� ������������ �� ���������� �������� ��������
  * @author Patsan O.
  * @param p_obj_id �� ��������
  * @return ������� ����������� �����
  */
  FUNCTION check_right_insert(p_obj_id IN NUMBER) RETURN NUMBER;

  /**
  * �������� ����� ������������ �� ���������� �������� ��������
  * @author Patsan O.
  * @param p_obj_id �� ��������
  * @return ������� ����������� �����
  */
  FUNCTION check_right_update(p_obj_id IN NUMBER) RETURN NUMBER;

  /**
  * �������� ����� ������������ �� �������� �������� ��������
  * @author Patsan O.
  * @param p_obj_id �� ��������
  * @return ������� ����������� �����
  */
  FUNCTION check_right_delete(p_obj_id IN NUMBER) RETURN NUMBER;

  /**
  * �������� ������������� ����� ������������ 
  * @author Patsan O.
  * @param p_right_type_brief ����������� ���� �����
  * @param p_obj_id �� �������
  * @param p_ent_id �� ��������
  * @return ������� ����������� �����
  */
  FUNCTION check_right
  (
    p_right_type_brief IN VARCHAR2
   ,p_obj_id           IN VARCHAR2
   ,p_ent_id           IN NUMBER DEFAULT NULL
  ) RETURN NUMBER;

  /**
  * �������� ������������� ����� ������������ 
  * @author Patsan O.
  * @param p_right_type_id �� ���� �����
  * @param p_obj_id �� �������
  * @param p_ent_id �� ��������
  * @return ������� ����������� �����
  */
  FUNCTION check_right
  (
    p_right_type_id IN NUMBER
   ,p_obj_id        IN VARCHAR2
   ,p_ent_id        IN NUMBER DEFAULT NULL
  ) RETURN NUMBER;

  /**
  * ����������� ������ ���� � ������ ����
  * @p_menu_id �� ������ ����
  */
  PROCEDURE ins_right_menu(p_menu_id IN NUMBER);

  /**
  * ������ ����������� ������ ���� � ������ ����
  * @p_menu_id �� ������ ����
  */
  PROCEDURE del_right_menu(p_menu_id IN NUMBER);

  /**
  * ����������� ������� �������� � ������ ����
  * @p_ent_id �� ��������
  * @p_obj_id �� �������
  */
  PROCEDURE ins_right_object
  (
    p_ent_id IN NUMBER
   ,p_obj_id IN NUMBER
  );

  /**
  * ������ ����������� ������� �������� � ������ ����
  * @p_ent_id �� ��������
  * @p_obj_id �� �������
  */
  PROCEDURE del_right_object
  (
    p_ent_id IN NUMBER
   ,p_obj_id IN NUMBER
  );

  /**
  * ��������� ������� ����
  * @p_role_id �� ����
  */
  PROCEDURE set_curr_role(p_role_id IN NUMBER);

  /**
  * ������ �.
  * ������������� ������� ���� �� �����
  */
  PROCEDURE set_curr_role(p_role_name IN VARCHAR2);

  /* ��������� ������� ����� �����
  * @autor ������ �. �.
  * @param par_right_name - ������������ �����
  * @param par_right_brief - ����. �����
  * @param par_right_type_brief - ����. ���� �����
  */
  PROCEDURE add_safety_right
  (
    par_right_name       VARCHAR2
   ,par_right_type_brief VARCHAR2
   ,par_right_brief      VARCHAR2 := NULL
  );

  /* ��������� ��������� ���� �����
  * @autor ������ �. �.
  * @param par_right_name - ������������ �����
  * @param par_role_name - ������������ ����
  * @param par_right_type_brief - ������� ����. ����
  */
  PROCEDURE assign_right_to_role
  (
    par_right_name       VARCHAR2
   ,par_role_name        VARCHAR2
   ,par_right_type_brief VARCHAR2 := 'CUSTOM'
   ,par_add_flag         NUMBER DEFAULT 1
  );

  /* ��������� �������� id ����� �� ������������ � ���� 
  * @autor ������ �. �.
  * @param par_right_name - ������������ �����
  * @param par_right_type_brief - ������� ����. ����
  */
  FUNCTION get_right_id
  (
    par_right_name       VARCHAR2
   ,par_right_type_brief VARCHAR2 := 'CUSTOM'
  ) RETURN NUMBER;

  /* ��������� ������� id ����� �� ������������ � ���� 
  * @autor ������ �. �.
  * @param par_right_name - ������������ �����
  * @param par_role_name - ������������ ����   
  * @param par_right_type_brief - ������� ����. ����
  */
  PROCEDURE revoke_right_from_role
  (
    par_right_name       VARCHAR2
   ,par_role_name        VARCHAR2
   ,par_right_type_brief VARCHAR2 := 'CUSTOM'
  );

END; 
/
CREATE OR REPLACE PACKAGE BODY safety IS
  /*
   ������ �.
   �������� �������� ��������� �������� ����
   ���������� v_curr_role_name sys_safety.name%type;
   ������� get_curr_role_name
   ���������� ��������� set_curr_role
   �������� ���� ������ ������������ � ������� ��������
  */

  v_curr_role      NUMBER := NULL;
  v_curr_role_name sys_safety.name%TYPE;

  ins_sys_event_type_id  sys_event_type.sys_event_type_id%TYPE;
  upd_sys_event_type_id  sys_event_type.sys_event_type_id%TYPE;
  del_sys_event_type_id  sys_event_type.sys_event_type_id%TYPE;
  office_man_role_id     NUMBER := NULL;
  mo_role_id             NUMBER := NULL;
  v_is_regional_operator NUMBER(1) := 0;

  /*  v_srt_object number;
  v_srt_docstats number;
  v_srt_insert number;
  v_srt_delete number;
  v_srt_update number;
  v_srt_custom number;
  v_srt_item number;
  v_srt_menu number; */

  FUNCTION get_curr_role RETURN NUMBER IS
  BEGIN
    RETURN v_curr_role;
  END;

  /*
    ������ �.
    ���������� �������� ����
  */
  FUNCTION get_curr_role_name RETURN VARCHAR2 IS
  BEGIN
    RETURN v_curr_role_name;
  END get_curr_role_name;

  /*
    ������ �.
    ������� ���������, ����������� �������� �������� ����
  */
  PROCEDURE set_curr_role IS
    v_user VARCHAR2(100) := USER;
  BEGIN
  
    IF USER = ents_bi.eul_owner
    THEN
      v_user := nvl(TRIM(sys_context('USERENV', 'CLIENT_IDENTIFIER')), USER);
    END IF;
  
    FOR rc IN (SELECT rru.sys_role_id id
                      -- ������ �.
                     ,upper(ss.name) role_name
               --
                 FROM sys_user      su
                     ,rel_role_user rru
                      -- ������ �.
                     ,sys_safety ss
               --
                WHERE su.sys_user_name = upper(v_user)
                  AND su.sys_user_id = rru.sys_user_id
                     -- ������ �.
                  AND rru.sys_role_id = ss.sys_safety_id
                     --
                  AND rownum = 1)
    LOOP
      v_curr_role := rc.id;
      -- ������ �.
      v_curr_role_name := rc.role_name;
      --
    END LOOP;
  END;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 22.10.2010 14:28:41
  -- Purpose : ��������� ��� � ������������ ���� ����
  -- ������� user_have_role � �����, 2011.05.20, ����������
  FUNCTION user_have_role
  (
    user_name VARCHAR2
   ,role_name VARCHAR2
  ) RETURN INTEGER IS
    v_role_cnt PLS_INTEGER;
    proc_name  VARCHAR2(25) := 'user_have_role';
  BEGIN
  
    SELECT decode(COUNT(*), 0, 0, 1)
      INTO v_role_cnt
      FROM sys_user      su
          ,rel_role_user rru
          ,ven_sys_role  sr
     WHERE 1 = 1
       AND su.sys_user_name = upper(TRIM(user_name))
       AND su.sys_user_id = rru.sys_user_id
       AND rru.sys_role_id = sr.sys_role_id
       AND upper(sr.name) = upper(role_name);
  
    RETURN(v_role_cnt);
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'������ ��� ���������� ' || proc_name || SQLERRM);
  END user_have_role;

  /*
    ������ �.
    ������������� ������� ���� �� �����
    p_role_name - �������� ����
  */
  PROCEDURE set_curr_role(p_role_name IN VARCHAR2) IS
  BEGIN
    IF regexp_like(p_role_name, '\D')
    THEN
      BEGIN
        v_curr_role_name := upper(p_role_name);
        SELECT sys_role_id
          INTO v_curr_role
          FROM ven_sys_role
         WHERE upper(NAME) = upper(v_curr_role_name);
      EXCEPTION
        WHEN no_data_found THEN
          raise_application_error(-20001
                                 ,'�� ������� ���� � ��������� ' || p_role_name);
      END;
    ELSE
      set_curr_role(to_number(p_role_name));
    END IF;
  END;

  PROCEDURE set_curr_role(p_role_id IN NUMBER) IS
  BEGIN
    v_curr_role := p_role_id;
    -- ������ �.
    SELECT upper(sr.name) INTO v_curr_role_name FROM ven_sys_role sr WHERE sr.sys_role_id = p_role_id;
  EXCEPTION
    WHEN no_data_found THEN
      raise_application_error(-20001, '�� ������� ���� � ID ' || to_char(p_role_id));
  END;

  PROCEDURE create_trs_user
  (
    NAME VARCHAR2
   ,pass VARCHAR2
  ) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    str VARCHAR2(255);
  BEGIN
    str := 'create user ' || NAME || ' identified by "' || pass || '"';
    BEGIN
      EXECUTE IMMEDIATE str;
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;
    str := 'grant ' || ents.get_schema || '_USER to ' || NAME;
    EXECUTE IMMEDIATE str;
    --safety_ldap.create_user(LOWER(NAME), LOWER(pass));
  EXCEPTION
    WHEN OTHERS THEN
      dbms_output.put_line(str);
  END;

  PROCEDURE drop_trs_user(NAME VARCHAR2) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    str VARCHAR2(255);
  BEGIN
    str := 'drop user ' || NAME;
    EXECUTE IMMEDIATE str;
  END;

  PROCEDURE set_pass_trs_user
  (
    NAME VARCHAR2
   ,pass VARCHAR2
  ) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    str VARCHAR2(255);
  BEGIN
    str := 'alter user ' || NAME || ' identified by "' || pass || '"';
    EXECUTE IMMEDIATE str;
  END;

  FUNCTION get_form_access
  (
    p_action VARCHAR2
   ,p_form   VARCHAR2
  ) RETURN VARCHAR2 IS
    v_return VARCHAR2(30);
  BEGIN
    IF USER = ents.get_schema
       OR p_action = 'VIEW'
    THEN
      RETURN p_action;
    ELSE
      SELECT decode(MAX(rsm.access_level), 1, p_action, 0, 'VIEW', NULL)
        INTO v_return
        FROM v_cur_user_safety cus
            ,rel_safety_menu   rsm
            ,main_menu         mm
       WHERE rsm.sys_safety_id = cus.sys_safety_id
         AND rsm.main_menu_id = mm.main_menu_id
         AND mm.main_menu_id > 0
         AND mm.code = p_form;
      RETURN v_return;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  FUNCTION get_doc_templ_access
  (
    p_action    VARCHAR2
   ,p_doc_templ VARCHAR2
  ) RETURN VARCHAR2 IS
    v_return VARCHAR2(30);
  BEGIN
    IF TRUE
    THEN
      --if user = ents.get_schema or p_action = 'VIEW' then
      RETURN p_action;
    ELSE
      SELECT decode(MAX(adt.access_level_id), 1, p_action, 0, 'VIEW', NULL)
        INTO v_return
        FROM v_cur_user_safety cus
            ,access_doc_templ  adt
       WHERE adt.sys_safety_id = cus.sys_safety_id
         AND adt.doc_templ_id = p_doc_templ;
      RETURN v_return;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  FUNCTION curr_sys_user RETURN sys_user.sys_user_id%TYPE AS
    v_result sys_user.sys_user_id%TYPE;
  BEGIN
    SELECT su.sys_user_id INTO v_result FROM ven_sys_user su WHERE su.sys_user_name = USER;
    RETURN v_result;
  END;

  PROCEDURE reg_event
  (
    p_sys_event_type_id IN NUMBER
   ,p_event_ent_id      IN NUMBER
   ,p_event_obj_id      IN NUMBER
   ,p_event_name        IN VARCHAR2
   ,p_val               IN CLOB
  ) AS
  BEGIN
    INSERT INTO ven_sys_event
      (sys_event_type_id, sys_user_id, event_ent_id, event_obj_id, event_name, val)
    VALUES
      (p_sys_event_type_id, curr_sys_user, p_event_ent_id, p_event_obj_id, p_event_name, p_val);
  END;

  PROCEDURE reg_event_ins
  (
    p_event_ent_id IN NUMBER
   ,p_event_obj_id IN NUMBER
   ,p_event_name   IN VARCHAR2
   ,p_val          IN CLOB
  ) AS
  BEGIN
    INSERT INTO ven_sys_event
      (sys_event_type_id, sys_user_id, event_ent_id, event_obj_id, event_name, val)
    VALUES
      (ins_sys_event_type_id, curr_sys_user, p_event_ent_id, p_event_obj_id, p_event_name, p_val);
  END;

  PROCEDURE reg_event_upd
  (
    p_event_ent_id IN NUMBER
   ,p_event_obj_id IN NUMBER
   ,p_event_name   IN VARCHAR2
   ,p_val          IN CLOB
  ) AS
  BEGIN
    INSERT INTO ven_sys_event
      (sys_event_type_id, sys_user_id, event_ent_id, event_obj_id, event_name, val)
    VALUES
      (upd_sys_event_type_id, curr_sys_user, p_event_ent_id, p_event_obj_id, p_event_name, p_val);
  END;

  PROCEDURE reg_event_del
  (
    p_event_ent_id IN NUMBER
   ,p_event_obj_id IN NUMBER
   ,p_event_name   IN VARCHAR2
   ,p_val          IN CLOB
  ) AS
  BEGIN
    INSERT INTO ven_sys_event
      (sys_event_type_id, sys_user_id, event_ent_id, event_obj_id, event_name, val)
    VALUES
      (del_sys_event_type_id, curr_sys_user, p_event_ent_id, p_event_obj_id, p_event_name, p_val);
  END;
  PROCEDURE reg_user_event
  (
    p_sys_event_type_id IN NUMBER
   ,p_event_ent_id      IN NUMBER
   ,p_event_obj_id      IN NUMBER
   ,p_event_name        IN VARCHAR2
   ,p_val               IN CLOB
   ,p_param1            IN VARCHAR2
   ,p_param2            IN VARCHAR2
   ,p_param3            IN VARCHAR2
   ,p_param4            IN VARCHAR2
   ,p_param5            IN VARCHAR2
  ) IS
  BEGIN
    INSERT INTO ven_sys_event
      (sys_event_type_id
      ,sys_user_id
      ,event_ent_id
      ,event_obj_id
      ,event_name
      ,param1
      ,param2
      ,param3
      ,param4
      ,param5)
    VALUES
      (p_sys_event_type_id
      ,curr_sys_user
      ,p_event_ent_id
      ,p_event_obj_id
      ,p_event_name
      ,p_param1
      ,p_param2
      ,p_param3
      ,p_param4
      ,p_param5);
  END;

  FUNCTION get_obj_safety
  (
    p_ent_brief IN VARCHAR2
   ,p_obj_id    IN NUMBER
   ,p_action    IN VARCHAR2 DEFAULT NULL
  ) RETURN VARCHAR2 IS
  BEGIN
    --return 'NO';
    FOR rc IN (SELECT ent_id FROM entity WHERE brief = p_ent_brief)
    LOOP
      RETURN get_obj_safety(rc.ent_id, p_obj_id, p_action);
    END LOOP;
    RETURN p_action;
  END;

  FUNCTION get_obj_safety
  (
    p_ent_id IN NUMBER
   ,p_obj_id IN NUMBER
   ,p_action IN VARCHAR2 DEFAULT NULL
  ) RETURN VARCHAR2 IS
  BEGIN
    RETURN p_action;
  END;

  FUNCTION prod_sec_func
  (
    p_schema IN VARCHAR2
   ,p_object IN VARCHAR2
  ) RETURN VARCHAR2 IS
  BEGIN
    IF USER IN (p_schema, ents_bi.dwh_owner, 'RESERVE')
       OR
      
       (USER = ents_bi.eul_owner AND sys_context('USERENV', 'CLIENT_IDENTIFIER') IS NULL)
    THEN
      RETURN NULL;
    ELSE
      RETURN 'safety.check_right_object(product_id,ent_id)=1';
    END IF;
  END;

  FUNCTION app_param_group_sec_func
  (
    p_schema IN VARCHAR2
   ,p_object IN VARCHAR2
  ) RETURN VARCHAR2 IS
  BEGIN
    IF USER IN (p_schema, ents_bi.dwh_owner, 'RESERVE')
       OR (USER = ents_bi.eul_owner AND sys_context('USERENV', 'CLIENT_IDENTIFIER') IS NULL)
    THEN
      RETURN NULL;
    ELSE
      RETURN 'safety.check_right_object(app_param_group_id,ent_id)=1';
    END IF;
  END;

  FUNCTION sal_chan_sec_func
  (
    p_schema IN VARCHAR2
   ,p_object IN VARCHAR2
  ) RETURN VARCHAR2 IS
  BEGIN
    IF USER IN (p_schema, ents_bi.dwh_owner, 'RESERVE')
       OR (USER = ents_bi.eul_owner AND sys_context('USERENV', 'CLIENT_IDENTIFIER') IS NULL)
    THEN
      RETURN NULL;
    ELSE
      RETURN 'safety.check_right_object(id,ent_id)=1';
    END IF;
  END;

  FUNCTION pol_head_sec_func
  (
    p_schema IN VARCHAR2
   ,p_object IN VARCHAR2
  ) RETURN VARCHAR2 IS
  BEGIN
    IF USER IN (p_schema, ents_bi.dwh_owner, 'RESERVE')
       OR (USER = ents_bi.eul_owner AND sys_context('USERENV', 'CLIENT_IDENTIFIER') IS NULL)
    THEN
      RETURN NULL;
    ELSE
      RETURN 'safety.check_right_department(agency_id)=1';
    END IF;
  END;

  FUNCTION dm_agency_sec_func
  (
    p_schema IN VARCHAR2
   ,p_object IN VARCHAR2
  ) RETURN VARCHAR2 IS
  BEGIN
    IF USER IN (p_schema, ents_bi.dwh_owner, 'RESERVE')
       OR (USER = ents_bi.eul_owner AND sys_context('USERENV', 'CLIENT_IDENTIFIER') IS NULL)
    THEN
      RETURN NULL;
    ELSE
      RETURN 'safety.check_right_department(agency_id)=1';
    END IF;
  END;

  FUNCTION ag_contr_head_sec_func
  (
    p_schema IN VARCHAR2
   ,p_object IN VARCHAR2
  ) RETURN VARCHAR2 IS
  BEGIN
    IF USER IN (p_schema, ents_bi.dwh_owner, 'RESERVE')
       OR (USER = ents_bi.eul_owner AND sys_context('USERENV', 'CLIENT_IDENTIFIER') IS NULL)
    THEN
      RETURN NULL;
    ELSE
      RETURN 'safety.check_right_department(agency_id)=1';
    END IF;
  END;

  FUNCTION disco_sec_func
  (
    p_schema IN VARCHAR2
   ,p_object IN VARCHAR2
  ) RETURN VARCHAR2 IS
  BEGIN
  
    IF USER IN ('INS', ents_bi.dwh_owner, 'RESERVE')
       OR (USER = ents_bi.eul_owner AND sys_context('USERENV', 'CLIENT_IDENTIFIER') IS NULL)
    THEN
      RETURN NULL;
    ELSE
      RETURN 'ins.safety.check_right_discoverer(doc_id)=1';
    END IF;
  END;

  FUNCTION get_right_name(p_right_id IN NUMBER) RETURN VARCHAR2 IS
  BEGIN
    FOR rc IN (SELECT sr.*
                     ,srt.brief srt_brief
                 FROM safety_right      sr
                     ,safety_right_type srt
                WHERE sr.safety_right_id = p_right_id
                  AND sr.safety_right_type_id = srt.safety_right_type_id)
    LOOP
    
      CASE
        WHEN rc.srt_brief = 'MENU' THEN
          FOR rc2 IN (SELECT TRIM(substr(sys_connect_by_path(REPLACE(NAME, '.', '_'), '.'), 2)) NAME
                        FROM main_menu mm
                       WHERE main_menu_id = rc.right_obj_id
                       START WITH mm.parent_id IS NULL
                      CONNECT BY PRIOR mm.main_menu_id = mm.parent_id)
          LOOP
            RETURN rc2.name;
          END LOOP;
        WHEN rc.srt_brief IN ('INSERT', 'UPDATE', 'DELETE') THEN
          FOR rc2 IN (SELECT e.name FROM entity e WHERE e.ent_id = rc.right_obj_id)
          LOOP
            RETURN rc2.name;
          END LOOP;
        WHEN rc.srt_brief IN ('DISCOVERER') THEN
          FOR rc2 IN (SELECT t.doc_id
                            ,t.doc_name          NAME
                            ,t.doc_developer_key brief
                        FROM ins_eul.eul5_documents_tab t
                       WHERE doc_id = rc.right_obj_id)
          LOOP
            RETURN rc2.name;
          END LOOP;
        WHEN rc.srt_brief = 'DOCSTATUS' THEN
          FOR rc2 IN (SELECT dt.name || '.' || dsr1.name || '.' || dsr2.name NAME
                        FROM doc_templ_status   dts1
                            ,doc_templ          dt
                            ,doc_status_ref     dsr1
                            ,doc_templ_status   dts2
                            ,doc_status_ref     dsr2
                            ,doc_status_allowed dsa
                       WHERE dt.doc_templ_id = dts1.doc_templ_id
                         AND dsr1.doc_status_ref_id = dts1.doc_status_ref_id
                         AND dsa.src_doc_templ_status_id = dts1.doc_templ_status_id
                         AND dsa.dest_doc_templ_status_id = dts2.doc_templ_status_id
                         AND dsr2.doc_status_ref_id = dts2.doc_status_ref_id
                         AND dsa.doc_status_allowed_id = rc.right_obj_id
                      /*select dt.name || '.' || dsr.name name
                       from doc_templ_status dts,
                            doc_templ        dt,
                            doc_status_ref   dsr
                      where dt.doc_templ_id = dts.doc_templ_id
                        and dsr.doc_status_ref_id = dts.doc_status_ref_id
                        and dts.doc_templ_status_id = rc.right_obj_id*/
                      )
          LOOP
            RETURN rc2.name;
          END LOOP;
        WHEN rc.srt_brief = 'OBJECT' THEN
          RETURN ent.name_by_id(rc.right_ent_id) || '.' || ent.obj_name(rc.right_ent_id
                                                                       ,rc.right_obj_id);
        ELSE
          RETURN rc.name;
      END CASE;
    END LOOP;
    RETURN '<no name>';
  END;

  FUNCTION check_right_object
  (
    p_obj_id IN NUMBER
   ,p_ent_id IN NUMBER
  ) RETURN NUMBER IS
    v_ret NUMBER := 1;
  BEGIN
    IF USER = ents.v_sch
    THEN
      RETURN 1;
    END IF;
    IF get_curr_role IS NOT NULL
    THEN
      RETURN 1;
    END IF;
    FOR rc IN (SELECT sr.right_obj_id
                     ,srr.safety_right_role_id
                 FROM safety_right      sr
                     ,safety_right_role srr
                WHERE srr.role_id(+) = safety.get_curr_role
                  AND sr.safety_right_id = srr.safety_right_id(+)
                  AND sr.right_ent_id = p_ent_id
                  AND sr.right_obj_id = p_obj_id)
    LOOP
      IF rc.safety_right_role_id IS NOT NULL
      THEN
        RETURN 1;
      ELSE
        RETURN 0;
      END IF;
    END LOOP;
    RETURN v_ret;
  END;

  FUNCTION check_right_docstatus(p_obj_id IN NUMBER) RETURN NUMBER IS
    v_ret NUMBER := 1;
  BEGIN
    IF USER = ents.v_sch
    THEN
      RETURN 1;
    END IF;
    IF get_curr_role IS NULL
    THEN
      RETURN 1;
    END IF;
    FOR rc IN (SELECT sr.right_obj_id
                     ,srr.safety_right_role_id
                 FROM safety_right      sr
                     ,safety_right_role srr
                     ,safety_right_type srt
                WHERE srr.role_id(+) = safety.get_curr_role
                  AND sr.safety_right_id = srr.safety_right_id(+)
                  AND sr.right_obj_id = p_obj_id
                  AND srt.brief = 'DOCSTATUS'
                  AND sr.safety_right_type_id = srt.safety_right_type_id)
    LOOP
      IF rc.safety_right_role_id IS NOT NULL
      THEN
        /*RAISE_APPLICATION_ERROR(-20000,
        '���� '||safety.get_curr_role);*/
        RETURN 1;
      ELSE
        /*RAISE_APPLICATION_ERROR(-20000,
        '���� '||safety.get_curr_role);*/
      
        RETURN 0;
      END IF;
    END LOOP;
    RETURN v_ret;
  END;

  FUNCTION check_right_discoverer(p_obj_id IN NUMBER) RETURN NUMBER IS
    v_ret NUMBER := 0;
  BEGIN
    IF USER = ents.v_sch
    THEN
      RETURN 1;
    END IF;
  
    IF USER != ents_bi.eul_owner
    THEN
      RETURN 1;
    END IF;
  
    -- ������ �.
    -- ���� ���������� ����� Desktop, � client_identifier �����
    IF USER = ents_bi.eul_owner
       AND sys_context('USERENV', 'CLIENT_IDENTIFIER') IS NULL
    THEN
      RETURN 1;
    END IF;
  
    IF user_have_role(sys_context('USERENV', 'CLIENT_IDENTIFIER')
                     ,'�������������� ������� Discoverer') = 1
    OR user_have_role(sys_context('USERENV', 'CLIENT_IDENTIFIER')
                     ,'�����������') = 1
    OR user_have_role(sys_context('USERENV', 'CLIENT_IDENTIFIER')
                     ,'�����') = 1                                   
    THEN
      RETURN 1;
    END IF;
    FOR rc IN (SELECT sr.right_obj_id
                     ,srr.safety_right_role_id
                 FROM safety_right      sr
                     ,safety_right_role srr
                     ,safety_right_type srt
                     ,sys_user          su
                     ,rel_role_user     rru
                     ,ven_sys_role      sr
                WHERE 1 = 1
                  AND su.sys_user_id = rru.sys_user_id
                  AND su.sys_user_name = TRIM(sys_context('USERENV', 'CLIENT_IDENTIFIER'))
                  AND sr.sys_role_id = rru.sys_role_id
                  AND srr.role_id = sr.sys_role_id
                  AND sr.safety_right_id = srr.safety_right_id
                  AND sr.right_obj_id = p_obj_id
                  AND srt.brief = 'DISCOVERER'
                  AND sr.safety_right_type_id = srt.safety_right_type_id)
    LOOP
    
      IF rc.safety_right_role_id IS NOT NULL
      THEN
        --RETURN 1;
        --NULL;
        v_ret := 1;
        --      ELSE
        --RETURN 0;
      END IF;
    END LOOP;
    RETURN v_ret;
  END;

  FUNCTION check_right_menu(p_obj_id IN NUMBER) RETURN NUMBER IS
    v_ret NUMBER := 0;
  BEGIN
    IF USER = ents.v_sch
    THEN
      RETURN 1;
    END IF;
    FOR rc IN (SELECT sr.right_obj_id
                     ,srr.safety_right_role_id
                 FROM safety_right      sr
                     ,safety_right_role srr
                     ,safety_right_type srt
                WHERE srr.role_id(+) = safety.get_curr_role
                  AND sr.safety_right_id = srr.safety_right_id(+)
                  AND sr.right_obj_id = p_obj_id
                  AND srt.brief = 'MENU'
                  AND sr.safety_right_type_id = srt.safety_right_type_id)
    LOOP
      IF rc.safety_right_role_id IS NOT NULL
      THEN
        RETURN 1;
      ELSE
        RETURN 0;
      END IF;
    END LOOP;
    RETURN v_ret;
  END;

  FUNCTION check_right_menu_code(p_obj_id IN NUMBER) RETURN NUMBER IS
    v_ret NUMBER := 0;
  BEGIN
    IF USER = ents.v_sch
    THEN
      RETURN 1;
    END IF;
    FOR rc IN (SELECT sr.right_obj_id
                     ,srr.safety_right_role_id
                     ,srr.add_flag
                 FROM safety_right      sr
                     ,safety_right_role srr
                     ,safety_right_type srt
                WHERE srr.role_id(+) = safety.get_curr_role
                  AND sr.safety_right_id = srr.safety_right_id(+)
                  AND sr.right_obj_id = p_obj_id
                  AND srt.brief = 'MENU'
                  AND sr.safety_right_type_id = srt.safety_right_type_id)
    LOOP
      --    if rc.safety_right_role_id is not null then
      --        return 1;
      --     else
      --      return null;
      --     end if;
      RETURN rc.add_flag;
    END LOOP;
    RETURN v_ret;
  END;

  FUNCTION check_right_form(p_obj_id IN VARCHAR2) RETURN NUMBER IS
    v_ret NUMBER := 1;
  BEGIN
    IF USER = ents.v_sch
    THEN
      RETURN 1;
    END IF;
    FOR rc IN (SELECT sr.right_obj_id
                     ,srr.safety_right_role_id
                 FROM safety_right      sr
                     ,safety_right_role srr
                     ,safety_right_type srt
                WHERE srr.role_id(+) = safety.get_curr_role
                  AND sr.safety_right_id = srr.safety_right_id(+)
                  AND sr.brief = p_obj_id
                  AND srt.brief = 'FORM'
                  AND sr.safety_right_type_id = srt.safety_right_type_id)
    LOOP
      IF rc.safety_right_role_id IS NOT NULL
      THEN
        RETURN 1;
      ELSE
        RETURN 0;
      END IF;
    END LOOP;
    RETURN v_ret;
  END;

  FUNCTION check_right_form_code(p_obj_id IN VARCHAR2) RETURN NUMBER IS
    v_ret NUMBER := 1;
  BEGIN
    IF USER = ents.v_sch
    THEN
      RETURN 1;
    END IF;
    FOR rc IN (SELECT sr.right_obj_id
                     ,srr.safety_right_role_id
                     ,srr.add_flag
                 FROM safety_right      sr
                     ,safety_right_role srr
                     ,safety_right_type srt
                WHERE srr.role_id(+) = safety.get_curr_role
                  AND sr.safety_right_id = srr.safety_right_id(+)
                  AND sr.brief = p_obj_id
                  AND srt.brief = 'FORM'
                  AND sr.safety_right_type_id = srt.safety_right_type_id)
    LOOP
    
      RETURN rc.add_flag;
    
    END LOOP;
    RETURN v_ret;
  END;

  FUNCTION check_right_item(p_obj_id IN VARCHAR2) RETURN NUMBER IS
    v_ret NUMBER := 1;
  BEGIN
    IF USER = ents.v_sch
    THEN
      RETURN 1;
    END IF;
    FOR rc IN (SELECT sr.right_obj_id
                     ,srr.safety_right_role_id
                 FROM safety_right      sr
                     ,safety_right_role srr
                     ,safety_right_type srt
                WHERE srr.role_id(+) = safety.get_curr_role
                  AND sr.safety_right_id = srr.safety_right_id(+)
                  AND sr.brief = p_obj_id
                  AND srt.brief = 'ITEM'
                  AND sr.safety_right_type_id = srt.safety_right_type_id)
    LOOP
      IF rc.safety_right_role_id IS NOT NULL
      THEN
        RETURN 1;
      ELSE
        RETURN 0;
      END IF;
    END LOOP;
    RETURN v_ret;
  END;

  FUNCTION check_right_custom(p_obj_id IN VARCHAR2) RETURN NUMBER IS
    v_ret NUMBER := 1;
  BEGIN
    IF USER = ents.v_sch
    THEN
      RETURN 1;
    END IF;
    FOR rc IN (SELECT sr.right_obj_id
                     ,srr.safety_right_role_id
                 FROM safety_right      sr
                     ,safety_right_role srr
                     ,safety_right_type srt
                WHERE srr.role_id(+) = safety.get_curr_role
                  AND sr.safety_right_id = srr.safety_right_id(+)
                  AND sr.brief = p_obj_id
                  AND srt.brief = 'CUSTOM'
                  AND sr.safety_right_type_id = srt.safety_right_type_id
                ORDER BY srr.safety_right_role_id)
    LOOP
      IF rc.safety_right_role_id IS NOT NULL
      THEN
        RETURN 1;
      ELSE
        RETURN 0;
      END IF;
    END LOOP;
    RETURN v_ret;
  END;

  FUNCTION check_right_insert(p_obj_id IN NUMBER) RETURN NUMBER IS
    v_ret NUMBER := 1;
  BEGIN
    IF USER = ents.v_sch
    THEN
      RETURN 1;
    END IF;
    FOR rc IN (SELECT sr.right_obj_id
                     ,srr.safety_right_role_id
                 FROM safety_right      sr
                     ,safety_right_role srr
                     ,safety_right_type srt
                WHERE srr.role_id(+) = safety.get_curr_role
                  AND sr.safety_right_id = srr.safety_right_id(+)
                  AND sr.right_obj_id = p_obj_id
                  AND srt.brief = 'INSERT'
                  AND sr.safety_right_type_id = srt.safety_right_type_id)
    LOOP
      IF rc.safety_right_role_id IS NOT NULL
      THEN
        RETURN 1;
      ELSE
        RETURN 0;
      END IF;
    END LOOP;
    RETURN v_ret;
  END;

  FUNCTION check_right_update(p_obj_id IN NUMBER) RETURN NUMBER IS
    v_ret NUMBER := 1;
  BEGIN
    IF USER = ents.v_sch
    THEN
      RETURN 1;
    END IF;
    FOR rc IN (SELECT sr.right_obj_id
                     ,srr.safety_right_role_id
                 FROM safety_right      sr
                     ,safety_right_role srr
                     ,safety_right_type srt
                WHERE srr.role_id(+) = safety.get_curr_role
                  AND sr.safety_right_id = srr.safety_right_id(+)
                  AND sr.right_obj_id = p_obj_id
                  AND srt.brief = 'UPDATE'
                  AND sr.safety_right_type_id = srt.safety_right_type_id)
    LOOP
      IF rc.safety_right_role_id IS NOT NULL
      THEN
        RETURN 1;
      ELSE
        RETURN 0;
      END IF;
    END LOOP;
    RETURN v_ret;
  END;

  FUNCTION check_right_delete(p_obj_id IN NUMBER) RETURN NUMBER IS
    v_ret NUMBER := 1;
  BEGIN
    IF USER = ents.v_sch
    THEN
      RETURN 1;
    END IF;
    FOR rc IN (SELECT sr.right_obj_id
                     ,srr.safety_right_role_id
                 FROM safety_right      sr
                     ,safety_right_role srr
                     ,safety_right_type srt
                WHERE srr.role_id(+) = safety.get_curr_role
                  AND sr.safety_right_id = srr.safety_right_id(+)
                  AND sr.right_obj_id = p_obj_id
                  AND srt.brief = 'DELETE'
                  AND sr.safety_right_type_id = srt.safety_right_type_id)
    LOOP
      IF rc.safety_right_role_id IS NOT NULL
      THEN
        RETURN 1;
      ELSE
        RETURN 0;
      END IF;
    END LOOP;
    RETURN v_ret;
  END;

  FUNCTION check_right
  (
    p_right_type_brief IN VARCHAR2
   ,p_obj_id           IN VARCHAR2
   ,p_ent_id           IN NUMBER DEFAULT NULL
  ) RETURN NUMBER IS
    v_ret NUMBER;
  BEGIN
    IF USER = ents.v_sch
    THEN
      RETURN 1;
    END IF;
    CASE p_right_type_brief
      WHEN 'ITEM' THEN
        v_ret := check_right_item(p_obj_id);
      WHEN 'OBJECT' THEN
        v_ret := check_right_object(p_obj_id, p_ent_id);
      WHEN 'INSERT' THEN
        v_ret := check_right_insert(p_obj_id);
      WHEN 'UPDATE' THEN
        v_ret := check_right_update(p_obj_id);
      WHEN 'DELETE' THEN
        v_ret := check_right_delete(p_obj_id);
      WHEN 'MENU' THEN
        v_ret := check_right_menu(p_obj_id);
      WHEN 'FORM' THEN
        v_ret := check_right_form(p_obj_id);
      WHEN 'CUSTOM' THEN
        v_ret := check_right_custom(p_obj_id);
      ELSE
        v_ret := 1;
    END CASE;
    RETURN v_ret;
  END;

  FUNCTION check_right
  (
    p_right_type_id IN NUMBER
   ,p_obj_id        IN VARCHAR2
   ,p_ent_id        IN NUMBER DEFAULT NULL
  ) RETURN NUMBER IS
    v_ret NUMBER;
  BEGIN
    IF USER = ents.v_sch
    THEN
      RETURN 1;
    END IF;
    FOR rc IN (SELECT srt.brief
                 FROM safety_right_type srt
                WHERE srt.safety_right_type_id = p_right_type_id)
    LOOP
      RETURN check_right(rc.brief, p_obj_id, p_ent_id);
    END LOOP;
    RETURN 1;
  END;

  FUNCTION get_right_brief(p_right_id IN NUMBER) RETURN VARCHAR2 IS
  BEGIN
    FOR rc IN (SELECT sr.*
                     ,srt.brief srt_brief
                 FROM safety_right      sr
                     ,safety_right_type srt
                WHERE sr.safety_right_id = p_right_id
                  AND sr.safety_right_type_id = srt.safety_right_type_id)
    LOOP
    
      CASE
        WHEN rc.srt_brief IN ('MENU', 'OBJECT') THEN
          RETURN NULL;
        WHEN rc.srt_brief IN ('INSERT', 'UPDATE', 'DELETE') THEN
          FOR rc2 IN (SELECT e.brief FROM entity e WHERE e.ent_id = rc.right_obj_id)
          LOOP
            RETURN rc2.brief;
          END LOOP;
        WHEN rc.srt_brief IN ('DISCOVERER') THEN
          FOR rc2 IN (SELECT t.doc_id
                            ,t.doc_name          NAME
                            ,t.doc_developer_key brief
                        FROM ins_eul.eul5_documents_tab t
                       WHERE doc_id = rc.right_obj_id)
          LOOP
            RETURN rc2.brief;
          END LOOP;
        WHEN rc.srt_brief = 'DOCSTATUS' THEN
          FOR rc2 IN (SELECT dt.brief || '.' || dsr1.brief || '.' || dsr2.brief brief
                        FROM doc_templ_status   dts1
                            ,doc_templ          dt
                            ,doc_status_ref     dsr1
                            ,doc_templ_status   dts2
                            ,doc_status_ref     dsr2
                            ,doc_status_allowed dsa
                       WHERE dt.doc_templ_id = dts1.doc_templ_id
                         AND dsr1.doc_status_ref_id = dts1.doc_status_ref_id
                         AND dsa.src_doc_templ_status_id = dts1.doc_templ_status_id
                         AND dsa.dest_doc_templ_status_id = dts2.doc_templ_status_id
                         AND dsr2.doc_status_ref_id = dts2.doc_status_ref_id
                         AND dsa.doc_status_allowed_id = rc.right_obj_id
                      /*select dt.brief || '.' || dsr.brief brief
                       from doc_templ_status dts,
                            doc_templ        dt,
                            doc_status_ref   dsr
                      where dt.doc_templ_id = dts.doc_templ_id
                        and dsr.doc_status_ref_id = dts.doc_status_ref_id
                        and dts.doc_templ_status_id = rc.right_obj_id*/
                      )
          LOOP
            RETURN rc2.brief;
          END LOOP;
        ELSE
          RETURN rc.brief;
      END CASE;
    END LOOP;
    RETURN '<no brief>';
  END;

  PROCEDURE ins_right_menu(p_menu_id IN NUMBER) AS
  BEGIN
    NULL;
  END;

  PROCEDURE del_right_menu(p_menu_id IN NUMBER) AS
  BEGIN
    NULL;
  END;

  PROCEDURE ins_right_object
  (
    p_ent_id IN NUMBER
   ,p_obj_id IN NUMBER
  ) AS
  BEGIN
    NULL;
  END;

  PROCEDURE del_right_object
  (
    p_ent_id IN NUMBER
   ,p_obj_id IN NUMBER
  ) AS
  BEGIN
    NULL;
  END;

  FUNCTION dep_sec_func
  (
    p_schema IN VARCHAR2
   ,p_object IN VARCHAR2
  ) RETURN VARCHAR2 IS
  BEGIN
    IF USER IN (p_schema, ents_bi.dwh_owner, 'RESERVE')
       OR (USER = ents_bi.eul_owner AND sys_context('USERENV', 'CLIENT_IDENTIFIER') IS NULL)
    THEN
      RETURN NULL;
    ELSE
      RETURN 'safety.check_right_department(department_id)=1';
    END IF;
  END;

  FUNCTION check_right_department(p_obj_id IN NUMBER) RETURN NUMBER IS
    v_ret NUMBER := 1;
    e_id  NUMBER;
  BEGIN
  
    IF (v_is_regional_operator = 0)
    THEN
      RETURN 1;
    END IF;
    BEGIN
      SELECT e.employee_id
        INTO e_id
        FROM employee      e
            ,employee_hist eh
            ,sys_user      su
       WHERE e.employee_id = eh.employee_id
         AND e.employee_id = su.employee_id
         AND su.sys_user_name = sys_context('USERENV', 'CLIENT_IDENTIFIER')
         AND eh.department_id = p_obj_id;
    EXCEPTION
      WHEN no_data_found THEN
        v_ret := 0;
    END;
    RETURN v_ret;
  END;

  /**
  * ��������, ��������� �� ������������ ������������ ����������.
  * ��������, ���� (����� ���� ����-��������) ��� (����� ���� ����-�������� � ����
  * �����������-�������������)
  * @author Ivanov D.
  * @param p_usr USER
  * @return ����: 1-�������� ������������ ����������, 0- ������ ������������
  */
  FUNCTION is_regional_operator(p_usr VARCHAR2) RETURN NUMBER IS
    v_is_reg NUMBER(1) := 0;
  BEGIN
  
    SELECT CASE
             WHEN (roles_count > 0)
                  AND (roles_count = regional_roles_count) THEN
              1
             ELSE
              0
           END
      INTO v_is_reg
      FROM (SELECT COUNT(*) roles_count
                  ,SUM(is_regional_role) regional_roles_count
              FROM (SELECT rr.*
                          ,CASE
                             WHEN (rr.sys_role_id = office_man_role_id)
                                  OR (rr.sys_role_id = mo_role_id) THEN
                              1
                             ELSE
                              0
                           END is_regional_role
                          ,rownum rn
                      FROM rel_role_user rr
                          ,sys_user      u
                     WHERE rr.sys_user_id = u.sys_user_id
                       AND u.sys_user_name = p_usr));
    RETURN v_is_reg;
  END;

  PROCEDURE add_safety_right
  (
    par_right_name       VARCHAR2
   ,par_right_type_brief VARCHAR2
   ,par_right_brief      VARCHAR2 := NULL
  ) IS
    v_right_obj_id         NUMBER;
    v_right_ent_id         NUMBER;
    v_safety_right_type_id NUMBER;
    v_cnt                  INT;
  BEGIN
    BEGIN
      SELECT rt.safety_right_type_id
        INTO v_safety_right_type_id
        FROM safety_right_type rt
       WHERE rt.brief = par_right_type_brief;
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20001
                               ,'�� ������� ����� � ������� ������������� ���� "' ||
                                par_right_type_brief || '".');
    END;
  
    IF par_right_type_brief = 'CUSTOM'
    THEN
      BEGIN
        sp_register_right(pname      => par_right_name
                         ,pbrief     => par_right_brief
                         ,prigthtype => par_right_type_brief);
      END;
    ELSIF par_right_type_brief = 'OBJECT'
    THEN
    
      DECLARE
        v_ent_name   entity.name%TYPE;
        v_ent_brief  entity.brief%TYPE;
        v_ent_source entity.source%TYPE;
        v_ent_id     NUMBER;
        v_id_name    VARCHAR2(100);
        v_pos        INT;
        v_sql        VARCHAR2(2000);
      BEGIN
        v_pos      := instr(par_right_name, '.');
        v_ent_name := substr(par_right_name, 0, v_pos - 1);
      
        SELECT e.ent_id
              ,e.brief
              ,'ven_' || e.source
              ,nvl(e.id_name, e.source || '_ID')
          INTO v_ent_id
              ,v_ent_brief
              ,v_ent_source
              ,v_id_name
          FROM entity e
         WHERE e.name = v_ent_name;
      
        v_sql := '
          select object_id, entity_id from(' || ' select v.' || v_id_name ||
                 ' as  object_id, e.name ||''.''|| ent.obj_name(v.ent_id, v.' || v_id_name || ')' ||
                 ' as name, e.ent_id entity_id ' || ' from ' || v_ent_source ||
                 ' v, ven_safety_right sr, entity e ' || ' where sr.right_obj_id(+) = v.' || v_id_name ||
                 ' and sr.right_ent_id(+) = ' || v_ent_id || ' and e.ent_id = ' || v_ent_id ||
                 ' and sr.right_obj_id is null' || ') where rownum = 1 and name = ''' ||
                 par_right_name || '''';
      
        EXECUTE IMMEDIATE v_sql
          INTO v_right_obj_id, v_right_ent_id;
      
      EXCEPTION
        WHEN no_data_found THEN
          raise_application_error(-20001
                                 ,'����� "' || par_right_name ||
                                  '" ��� ������� ��� ������� ��� ������� �� ����������!');
      END;
    
      INSERT INTO ven_safety_right
        (safety_right_type_id, right_obj_id, right_ent_id)
      VALUES
        (v_safety_right_type_id, v_right_obj_id, v_right_ent_id);
    ELSE
      IF par_right_type_brief IN ('MENU')
      THEN
        SELECT COUNT(1)
          INTO v_cnt
          FROM (SELECT TRIM(substr(sys_connect_by_path(REPLACE(NAME, '.', '_'), '.'), 2)) NAME
                  FROM main_menu mm
                 START WITH mm.parent_id IS NULL
                CONNECT BY PRIOR mm.main_menu_id = mm.parent_id)
         WHERE NAME = par_right_name;
        IF v_cnt = 0
        THEN
          raise_application_error(-20001
                                 ,'����� ���� �� ������� �� ������ ������� ����� "' || par_right_name ||
                                  '" �� ����������!');
        END IF;
      
        BEGIN
          SELECT v.main_menu_id
            INTO v_right_obj_id
            FROM v_right_menu_wiz v
           WHERE v.name LIKE par_right_name;
        EXCEPTION
          WHEN no_data_found THEN
            raise_application_error(-20001
                                   ,'����� "' || par_right_name || '" ��� ������ ���� ��� �������!');
        END;
      ELSIF par_right_type_brief IN ('INSERT', 'UPDATE', 'DELETE')
      THEN
        SELECT COUNT(1) INTO v_cnt FROM entity e WHERE e.name = par_right_name;
      
        IF v_cnt = 0
        THEN
          raise_application_error(-20001
                                 ,'������� �� ������� �� ������ ������� ����� ������������� ������� "' ||
                                  par_right_name || '" �� ����������!');
        END IF;
      
        IF par_right_type_brief = 'INSERT'
        THEN
          BEGIN
            SELECT v.ent_id
              INTO v_right_obj_id
              FROM v_right_insert_wiz v
             WHERE v.name LIKE par_right_name;
          EXCEPTION
            WHEN no_data_found THEN
              raise_application_error(-20001
                                     ,'����� "' || par_right_name ||
                                      '" ��� �������������� ���� ���������� ������� ��� �������!');
          END;
        ELSIF par_right_type_brief = 'UPDATE'
        THEN
          BEGIN
            SELECT v.ent_id
              INTO v_right_obj_id
              FROM v_right_update_wiz v
             WHERE v.name LIKE par_right_name;
          EXCEPTION
            WHEN no_data_found THEN
              raise_application_error(-20001
                                     ,'����� "' || par_right_name ||
                                      '" ��� �������������� ���� ��������� ������� ��� �������!');
          END;
        ELSIF par_right_type_brief = 'DELETE'
        THEN
          BEGIN
            SELECT v.ent_id
              INTO v_right_obj_id
              FROM v_right_delete_wiz v
             WHERE v.name LIKE par_right_name;
          EXCEPTION
            WHEN no_data_found THEN
              raise_application_error(-20001
                                     ,'����� "' || par_right_name ||
                                      '" ��� �������������� ���� �������� ������� ��� �������!');
          END;
        END IF;
      ELSIF par_right_type_brief = 'DOCSTATUS'
      THEN
        BEGIN
          SELECT COUNT(1)
            INTO v_cnt
            FROM doc_templ_status   dts1
                ,doc_templ          dt
                ,doc_status_ref     dsr1
                ,doc_templ_status   dts2
                ,doc_status_ref     dsr2
                ,doc_status_allowed dsa
           WHERE dt.doc_templ_id = dts1.doc_templ_id
             AND dsr1.doc_status_ref_id = dts1.doc_status_ref_id
             AND dsa.src_doc_templ_status_id = dts1.doc_templ_status_id
             AND dsa.dest_doc_templ_status_id = dts2.doc_templ_status_id
             AND dsr2.doc_status_ref_id = dts2.doc_status_ref_id
             AND (dt.name || '.' || dsr1.name || '.' || dsr2.name) = par_right_name;
        EXCEPTION
          WHEN no_data_found THEN
            raise_application_error(-20001
                                   ,'������� �������, �� ������� �� ������ ������� ����� ������������� "' ||
                                    par_right_name || '" �� ����������!');
        END;
      
        BEGIN
          SELECT v.ent_id
            INTO v_right_obj_id
            FROM v_right_docstatus_wiz v
           WHERE v.name LIKE par_right_name;
        EXCEPTION
          WHEN no_data_found THEN
            raise_application_error(-20001
                                   ,'����� "' || par_right_name ||
                                    '" ��� �������������� ���� ��������� �������� ��� �������!');
        END;
      
      ELSIF par_right_type_brief = 'DISCOVERER'
      THEN
        SELECT COUNT(1) INTO v_cnt FROM ins_eul.eul5_documents_tab t WHERE doc_name = par_right_name;
        IF v_cnt = 0
        THEN
          raise_application_error(-20001
                                 ,'�� ������ ����� � ������ "' || par_right_name ||
                                  '", �� ������� �� ������ ������� �����!');
        END IF;
      
        BEGIN
          SELECT v.ent_id
            INTO v_right_obj_id
            FROM v_right_discoverer_wiz v
           WHERE v.name LIKE par_right_name;
        EXCEPTION
          WHEN no_data_found THEN
            raise_application_error(-20001
                                   ,'����� "' || par_right_name || '" ��� ������ ��� �������!');
        END;
      
      END IF; --if par_right_type_brief in ('MENU') then
      INSERT INTO ven_safety_right
        (safety_right_type_id, right_obj_id)
      VALUES
        (v_safety_right_type_id, v_right_obj_id);
    END IF; --if par_right_type_brief = 'CUSTOM' then
  END add_safety_right;

  PROCEDURE assign_right_to_role
  (
    par_right_name       VARCHAR2
   ,par_role_name        VARCHAR2
   ,par_right_type_brief VARCHAR2 := 'CUSTOM'
   ,par_add_flag         NUMBER DEFAULT 1
  ) IS
    v_safety_right_id safety_right.safety_right_id%TYPE;
    v_role_id         ven_sys_role.sys_role_id%TYPE;
    v_cnt             INT;
  BEGIN
    v_safety_right_id := get_right_id(par_right_name, par_right_type_brief);
  
    BEGIN
      SELECT sr.sys_role_id INTO v_role_id FROM ven_sys_role sr WHERE sr.name = par_role_name;
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20001
                               ,'�� ������� ���� � ��������� "' || par_role_name || '".');
    END;
  
    SELECT COUNT(1)
      INTO v_cnt
      FROM ins.safety_right_role srr
     WHERE srr.safety_right_id = v_safety_right_id
       AND srr.role_id = v_role_id;
  
    IF v_cnt > 0
    THEN
      raise_application_error(-20001
                             ,'����� � ������������� ' || par_right_name || ' ��� ��������� ���� ' ||
                              par_role_name);
    END IF;
  
    INSERT INTO ins.ven_safety_right_role
      (role_id, safety_right_id, add_flag)
    VALUES
      (v_role_id, v_safety_right_id, par_add_flag);
  
  END assign_right_to_role;

  FUNCTION get_right_id
  (
    par_right_name       VARCHAR2
   ,par_right_type_brief VARCHAR2 := 'CUSTOM'
  ) RETURN NUMBER IS
    v_right_obj_id         NUMBER;
    v_safety_right_id      NUMBER;
    v_right_ent_id         NUMBER;
    v_safety_right_type_id NUMBER;
    v_result               NUMBER;
  BEGIN
    BEGIN
      SELECT rt.safety_right_type_id
        INTO v_safety_right_type_id
        FROM safety_right_type rt
       WHERE rt.brief = par_right_type_brief;
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20001
                               ,'�� ������� ����� � ������� ������������� ���� "' ||
                                par_right_type_brief || '".');
    END;
  
    IF par_right_type_brief = 'CUSTOM'
    THEN
      BEGIN
        SELECT sr.safety_right_id
          INTO v_safety_right_id
          FROM safety_right sr
         WHERE sr.name = par_right_name
           AND sr.safety_right_type_id = v_safety_right_type_id;
      EXCEPTION
        WHEN no_data_found THEN
          raise_application_error(-20001
                                 ,'���������������� ����� "' || par_right_name || '" �� �������!');
      END;
    
    ELSIF par_right_type_brief = 'OBJECT'
    THEN
    
      DECLARE
        v_ent_name   entity.name%TYPE;
        v_ent_brief  entity.brief%TYPE;
        v_ent_source entity.source%TYPE;
        v_ent_id     NUMBER;
        v_id_name    VARCHAR2(100);
        v_pos        INT;
        v_sql        VARCHAR2(2000);
      BEGIN
        v_pos      := instr(par_right_name, '.');
        v_ent_name := substr(par_right_name, 0, v_pos - 1);
      
        SELECT e.ent_id
              ,e.brief
              ,'ven_' || e.source
              ,nvl(e.id_name, e.source || '_ID')
          INTO v_ent_id
              ,v_ent_brief
              ,v_ent_source
              ,v_id_name
          FROM entity e
         WHERE e.name = v_ent_name;
      
        v_sql := '
          select object_id, entity_id from(' || ' select v.' || v_id_name ||
                 ' as  object_id, e.name ||''.''|| ent.obj_name(v.ent_id, v.' || v_id_name || ')' ||
                 ' as name, e.ent_id entity_id ' || ' from ' || v_ent_source ||
                 ' v, ven_safety_right sr, entity e ' || ' where sr.right_obj_id = v.' || v_id_name ||
                 ' and sr.right_ent_id = ' || v_ent_id || ' and e.ent_id = ' || v_ent_id ||
                 ') where rownum = 1 and name = ''' || par_right_name || '''';
      
        EXECUTE IMMEDIATE v_sql
          INTO v_right_obj_id, v_right_ent_id;
      
      EXCEPTION
        WHEN no_data_found THEN
          raise_application_error(-20001
                                 ,'����� "' || par_right_name || '" ��� ������� �� �������!');
      END;
    
      BEGIN
        SELECT sr.safety_right_id
          INTO v_safety_right_id
          FROM safety_right sr
         WHERE sr.right_ent_id = v_right_ent_id
           AND sr.right_obj_id = v_right_obj_id
           AND sr.safety_right_type_id = v_safety_right_type_id;
      EXCEPTION
        WHEN no_data_found THEN
          raise_application_error(-20001
                                 ,'����� "' || par_right_name || '" ��� ������� �� �������!');
      END;
    
    ELSIF par_right_type_brief = 'MENU'
    THEN
      BEGIN
        SELECT sr.safety_right_id
          INTO v_safety_right_id
          FROM (SELECT TRIM(substr(sys_connect_by_path(REPLACE(NAME, '.', '_'), '.'), 2)) NAME
                      ,mm.main_menu_id AS right_obj_id
                  FROM main_menu mm
                 START WITH mm.parent_id IS NULL
                CONNECT BY PRIOR mm.main_menu_id = mm.parent_id) x
              ,safety_right sr
         WHERE x.name = par_right_name
           AND sr.right_obj_id = x.right_obj_id
           AND sr.safety_right_type_id = v_safety_right_type_id;
      EXCEPTION
        WHEN no_data_found THEN
          raise_application_error(-20001
                                 ,'����� ���� �� ������� �� ������ ������� ����� "' || par_right_name ||
                                  '" �� ����������!');
        WHEN too_many_rows THEN
          raise_application_error(-20001
                                 ,'������� ��������� ������� ���� �� � ������ "' || par_right_name || '"');
      END;
    
    ELSIF par_right_type_brief IN ('INSERT', 'UPDATE', 'DELETE')
    THEN
      BEGIN
        SELECT sr.safety_right_id
          INTO v_safety_right_id
          FROM entity       e
              ,safety_right sr
         WHERE e.name = par_right_name
           AND sr.right_obj_id = e.ent_id
           AND sr.safety_right_type_id = v_safety_right_type_id;
      EXCEPTION
        WHEN no_data_found THEN
          raise_application_error(-20001
                                 ,'������� ��� ����� � ������"' || par_right_name || '" �� �������!');
      END;
    
    ELSIF par_right_type_brief = 'DOCSTATUS'
    THEN
      BEGIN
        SELECT sr.safety_right_id
          INTO v_safety_right_id
          FROM doc_templ_status   dts1
              ,doc_templ          dt
              ,doc_status_ref     dsr1
              ,doc_templ_status   dts2
              ,doc_status_ref     dsr2
              ,doc_status_allowed dsa
              ,safety_right       sr
         WHERE dt.doc_templ_id = dts1.doc_templ_id
           AND dsr1.doc_status_ref_id = dts1.doc_status_ref_id
           AND dsa.src_doc_templ_status_id = dts1.doc_templ_status_id
           AND dsa.dest_doc_templ_status_id = dts2.doc_templ_status_id
           AND dsr2.doc_status_ref_id = dts2.doc_status_ref_id
           AND (dt.name || '.' || dsr1.name || '.' || dsr2.name) = par_right_name
           AND sr.right_obj_id = dsa.doc_status_allowed_id
           AND sr.safety_right_type_id = v_safety_right_type_id;
      EXCEPTION
        WHEN no_data_found THEN
          raise_application_error(-20001
                                 ,'������� �������, � ������ "' || par_right_name ||
                                  '" �� ����������!');
      END;
    
    ELSIF par_right_type_brief = 'DISCOVERER'
    THEN
      BEGIN
        SELECT sr.safety_right_id
          INTO v_safety_right_id
          FROM ins_eul.eul5_documents_tab t
              ,safety_right               sr
         WHERE doc_name = par_right_name
           AND sr.right_obj_id = t.doc_id
           AND sr.safety_right_type_id = v_safety_right_type_id;
      EXCEPTION
        WHEN no_data_found THEN
          raise_application_error(-20001
                                 ,'�� ������ ����� � ������ "' || par_right_name || '"');
        WHEN too_many_rows THEN
          raise_application_error(-20002
                                 ,'������� ��������� ������� � ������ "' || par_right_name || '"');
      END;
    
    END IF; --if par_right_type_brief = 'CUSTOM' then
  
    RETURN v_safety_right_id;
  END get_right_id;

  PROCEDURE revoke_right_from_role
  (
    par_right_name       VARCHAR2
   ,par_role_name        VARCHAR2
   ,par_right_type_brief VARCHAR2 := 'CUSTOM'
  ) IS
    v_right_id NUMBER;
    v_role_id  NUMBER;
    v_cnt      INT;
  BEGIN
    v_right_id := get_right_id(par_right_name, par_right_type_brief);
  
    BEGIN
      SELECT sr.sys_role_id INTO v_role_id FROM ven_sys_role sr WHERE sr.name = par_role_name;
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20001
                               ,'�� ������� ���� � ��������� "' || par_role_name || '".');
    END;
  
    BEGIN
      SELECT 1
        INTO v_cnt
        FROM ins.safety_right_role srr
       WHERE srr.safety_right_id = v_right_id
         AND srr.role_id = v_role_id;
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20001
                               ,'� ������ ���� "' || par_role_name || '" �� ��������� ����� "' ||
                                par_right_name || '". ');
    END;
    DELETE FROM ins.safety_right_role srr
     WHERE srr.safety_right_id = v_right_id
       AND srr.role_id = v_role_id;
  END revoke_right_from_role;

BEGIN
  SELECT et.sys_event_type_id
    INTO ins_sys_event_type_id
    FROM sys_event_type et
   WHERE et.brief = 'INS';
  SELECT et.sys_event_type_id
    INTO upd_sys_event_type_id
    FROM sys_event_type et
   WHERE et.brief = 'UPD';
  SELECT et.sys_event_type_id
    INTO del_sys_event_type_id
    FROM sys_event_type et
   WHERE et.brief = 'DEL';

  /** ����� ������������������*/
  SELECT sys_role_id
    INTO office_man_role_id
    FROM ven_sys_role
   WHERE NAME = '���� - ��������';
  SELECT sys_role_id
    INTO mo_role_id
    FROM ven_sys_role
   WHERE NAME = '����������� ������������� ���';
  v_is_regional_operator := is_regional_operator(USER);
  /** ����� ������������������ */

--set_curr_role;

END; 
/
CREATE OR REPLACE PACKAGE ent IS

  -- Created : 18.02.2005 18:21:37
  -- Purpose : ����� ��� ����������� �������������� �� ��������� ��������

  TYPE t_attr IS REF CURSOR RETURN attr%ROWTYPE;
  TYPE t_param IS RECORD(
     NAME VARCHAR2(30)
    ,val  VARCHAR2(100));
  TYPE t_params IS TABLE OF t_param INDEX BY BINARY_INTEGER;

  rep_brief VARCHAR2(30);

  -- ������������ �������
  FUNCTION obj_name
  (
    p_ent_id   IN NUMBER
   , -- �� ��������
    p_obj_id   IN NUMBER
   , -- �� �������
    p_obj_date IN DATE -- ���� �������
    DEFAULT SYSDATE
  ) RETURN VARCHAR2;
  FUNCTION obj_name
  (
    p_ent_brief IN VARCHAR2
   ,p_obj_id    IN NUMBER
   ,p_obj_date  IN DATE DEFAULT SYSDATE
  ) RETURN VARCHAR2;

  -- Purpose : ������� ������ ��������
  PROCEDURE obj_del
  (
    p_ent_id IN NUMBER
   , -- �� ��������
    p_obj_id IN NUMBER -- �� �������
  );
  -- Purpose : ������������� ������ ��������
  PROCEDURE obj_lock
  (
    p_ent_id IN NUMBER
   , -- �� ��������
    p_obj_id IN NUMBER -- �� �������
  );
  -- Purpose : ������ ������� ��� ������ �������� ��������
  FUNCTION obj_list_sql(p_ent_id IN NUMBER -- �� ��������
                        ) RETURN VARCHAR2;

  -- Purpose : ������ ������� ��� ������ �������� ��������
  --- ����������� � ���������
  FUNCTION obj_list_sql_trans
  (
    p_analytic_type_id IN NUMBER
   , -- �� ���� ���������
    p_analytic_num     IN NUMBER
  ) RETURN VARCHAR2;

  -- Purpose : �� �������� �� ����������
  FUNCTION id_by_brief(p_brief IN VARCHAR2 -- ���������� ��������
                       ) RETURN NUMBER;
  -- Purpose : ���������� �������� �� ��
  FUNCTION brief_by_id(p_ent_id IN NUMBER -- �� ��������
                       ) RETURN VARCHAR2;
  -- Purpose : ������������ �������� �� ��
  FUNCTION name_by_id(p_ent_id IN NUMBER -- �� ��������
                      ) RETURN VARCHAR2;
  -- Purpose : ������������ �������� �� ����������
  FUNCTION name_by_brief(p_brief IN VARCHAR2 -- ���������� ��������
                         ) RETURN VARCHAR2;

  -- Purpose : ���������������� ����� ��������������
  PROCEDURE init_ew
  (
    p_ent_brief IN VARCHAR2
   , -- ���������� ��������
    p_ent_id    OUT NUMBER
   , -- �� ��������
    p_ent_name  OUT VARCHAR2
   , -- ������������ ��������
    p_id_name   OUT VARCHAR2
   , -- ������������ ���� �� �������
    p_sq_name   OUT VARCHAR2 -- ������������ ������������������
  );

  -- Purpose : ��������� ���������� �����
  FUNCTION check_right(p_code IN VARCHAR2 -- ��� ����������� �����
                       ) RETURN NUMBER;

  -- Purpose : �������� ��������
  PROCEDURE ent_attr_cur
  (
    p_ent_id IN NUMBER
   , -- �� ��������
    p_result IN OUT t_attr -- ���������
  );

  --Purpose: �������� �������� �� �������� �������
  FUNCTION get_obj_ent_id
  (
    p_ent_id IN NUMBER
   ,p_obj_id IN NUMBER
  ) RETURN NUMBER;

  /**
  * �������� �������� ������������ ��������
  * @author Denis Ivanov
  * @param p_ent_brief ���������� ��������
  * @param p_attr_brief ���������� �������� ��������
  * @param p_obj_id �� ������� ��������, �������� �������� �������� ����� ��������
  * @return �������� ������������ ��������
  */
  FUNCTION calc_attr
  (
    p_ent_brief  attr.source%TYPE
   ,p_attr_brief attr.brief%TYPE
   ,p_obj_id     NUMBER
  ) RETURN NUMBER;

  FUNCTION min_date RETURN DATE;
  FUNCTION max_date RETURN DATE;

  PROCEDURE commit_form;
  FUNCTION get_rep_brief RETURN VARCHAR2;

  FUNCTION trans
  (
    p_ent_brief  IN VARCHAR2
   ,p_attr_brief IN VARCHAR2
   ,p_obj_id     IN NUMBER
   ,p_def_val    VARCHAR2 DEFAULT NULL
  ) RETURN VARCHAR2;

  FUNCTION trans
  (
    p_attr_id IN NUMBER
   ,p_obj_id  IN NUMBER
   ,p_def_val VARCHAR2 DEFAULT NULL
  ) RETURN VARCHAR2;
  /**
  *  ���������� ��������� �������� ����� �� ������� ����� �������
  *  �������� 27.09.2006 �.���������. �������� �������� p_elem_type - ��� ��������. �� ��������� ��� Item ����� ������.
  *  ����� �������� �������� (LOV, LOV_COLUMN, WINDOW, MENU_ITEM)
  */

  FUNCTION trans_item
  (
    p_item      IN VARCHAR2
   ,p_def_val   VARCHAR2
   ,p_elem_type VARCHAR2 DEFAULT NULL
  ) RETURN VARCHAR2;

  PROCEDURE init_ent_var;

  /**
  * �������� �� ������� �� �������� ��������� ��������
  * @param p_ent_brief ���������� ��������
  * @param p_val �������� ��������� ��������
  * @return �� �������
  */
  FUNCTION fn_obj_id_by_val
  (
    p_ent_brief IN VARCHAR2
   ,p_val       IN VARCHAR2
  ) RETURN NUMBER;

  /* ���������� ID ������ �� p_obj_brief �� ������� p_table_brief
     ������ 08.12.2006 ������ ������.
  */
  FUNCTION get_obj_id
  (
    p_table_brief IN VARCHAR2
   ,p_obj_brief   IN VARCHAR2
  ) RETURN NUMBER;

  /*
   ��������� ���������� �� ������ � ������ ID � ������ ENTITY
   ����� �.
  */
  FUNCTION check_ent_obj_exists
  (
    par_ent_brief entity.brief%TYPE
   ,par_obj_id    NUMBER
  ) RETURN BOOLEAN;
  FUNCTION check_ent_obj_exists
  (
    par_ent_id entity.ent_id%TYPE
   ,par_obj_id NUMBER
  ) RETURN BOOLEAN;

END;
/
CREATE OR REPLACE PACKAGE BODY ent IS

  -- Private type declarations
  -- Private constant declarations
  -- Private variable declarations

  FUNCTION obj_name
  (
    p_ent_id   IN NUMBER
   ,p_obj_id   IN NUMBER
   ,p_obj_date IN DATE DEFAULT SYSDATE
  ) RETURN VARCHAR2 IS
    v_result VARCHAR2(2000);
    v_sql    VARCHAR2(2000);
  BEGIN
    IF p_obj_id IS NULL
    THEN
      RETURN NULL;
    END IF;
    v_result := TRIM(fn_obj_name(p_ent_id, p_obj_id, p_obj_date));
  
    IF v_result IS NULL
    THEN
      BEGIN
        SELECT e.obj_name INTO v_sql FROM entity e WHERE e.ent_id = p_ent_id;
        EXECUTE IMMEDIATE v_sql
          INTO v_result
          USING IN p_obj_id;
      EXCEPTION
        WHEN OTHERS THEN
          RETURN NULL;
      END;
    END IF;
  
    RETURN v_result;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN NULL;
    WHEN too_many_rows THEN
      RETURN NULL;
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'�� ������� �������� ��� �������' || SQLERRM);
      --THEN RETURN NULL;
  END;

  FUNCTION obj_name
  (
    p_ent_brief IN VARCHAR2
   ,p_obj_id    IN NUMBER
   ,p_obj_date  IN DATE DEFAULT SYSDATE
  ) RETURN VARCHAR2 IS
    v_ent_id NUMBER;
  BEGIN
  
    SELECT e.ent_id INTO v_ent_id FROM entity e WHERE e.brief = p_ent_brief;
  
    RETURN obj_name(v_ent_id, p_obj_id, p_obj_date);
  
    -- return trim(fn_obj_name2(p_ent_brief, p_obj_id, p_obj_date));
  EXCEPTION
    WHEN no_data_found THEN
      RETURN '�� ������� �������� ' || p_ent_brief;
    WHEN OTHERS THEN
      NULL;
  END;

  PROCEDURE obj_del
  (
    p_ent_id IN NUMBER
   ,p_obj_id IN NUMBER
  ) IS
  BEGIN
    --sp_obj_del(p_ent_id, p_obj_id);
    NULL;
  END;

  PROCEDURE obj_lock
  (
    p_ent_id IN NUMBER
   ,p_obj_id IN NUMBER
  ) IS
  BEGIN
    sp_obj_lock(p_ent_id, p_obj_id);
  END;

  FUNCTION obj_list_sql(p_ent_id IN NUMBER) RETURN VARCHAR2 IS
  BEGIN
    RETURN fn_obj_list_sql(p_ent_id);
  END;

  FUNCTION obj_list_sql_trans
  (
    p_analytic_type_id IN NUMBER
   ,p_analytic_num     IN NUMBER
  ) RETURN VARCHAR2 IS
  BEGIN
    RETURN fn_obj_list_sql_trans(p_analytic_type_id, p_analytic_num);
  END;

  FUNCTION id_by_brief(p_brief IN VARCHAR2) RETURN NUMBER IS
  BEGIN
    FOR rc IN (SELECT e.ent_id FROM entity e WHERE e.brief = p_brief)
    LOOP
      RETURN rc.ent_id;
    END LOOP;
    RETURN NULL;
  END;

  FUNCTION brief_by_id(p_ent_id IN NUMBER) RETURN VARCHAR2 IS
    v_result VARCHAR2(30);
  BEGIN
    SELECT e.brief INTO v_result FROM entity e WHERE e.ent_id = p_ent_id;
    RETURN(v_result);
  END;

  FUNCTION name_by_id(p_ent_id IN NUMBER) RETURN VARCHAR2 IS
    v_result VARCHAR2(150);
  BEGIN
    SELECT e.name INTO v_result FROM entity e WHERE e.ent_id = p_ent_id;
    RETURN(v_result);
  END;

  FUNCTION name_by_brief(p_brief IN VARCHAR2) RETURN VARCHAR2 IS
    v_result VARCHAR2(150);
  BEGIN
    SELECT e.name INTO v_result FROM entity e WHERE e.brief = p_brief;
    RETURN(v_result);
  END;

  PROCEDURE init_ew
  (
    p_ent_brief IN VARCHAR2
   ,p_ent_id    OUT NUMBER
   ,p_ent_name  OUT VARCHAR2
   ,p_id_name   OUT VARCHAR2
   ,p_sq_name   OUT VARCHAR2
  ) IS
  BEGIN
    SELECT e.ent_id
          ,e.name
          ,'SQ_' || e.source sq_name
          ,
           /*(select e.source || '_ID'
             from entity e
            where parent_id is null
            start with e.brief = upper(p_ent_brief)
           connect by prior parent_id = ent_id)*/e.id_name id_name
      INTO p_ent_id
          ,p_ent_name
          ,p_sq_name
          ,p_id_name
      FROM entity e
     WHERE e.brief = upper(p_ent_brief);
  END;

  FUNCTION check_right(p_code IN VARCHAR2) RETURN NUMBER IS
  BEGIN
    /*
    TODO: owner="akalabukhov" created="13.04.2005"
    text="�������� ��� �������� ���������� ����"
    */
    IF p_code IS NULL
    THEN
      RETURN 0;
    ELSE
      RETURN 1;
    END IF;
  END;

  PROCEDURE ent_attr_cur
  (
    p_ent_id IN NUMBER
   ,p_result IN OUT t_attr
  ) IS
  BEGIN
    OPEN p_result FOR
      SELECT a.*
        FROM attr a
       INNER JOIN attr_type aty
          ON aty.attr_type_id = a.attr_type_id
         AND aty.brief = 'OI'
       WHERE a.ent_id = p_ent_id
      UNION ALL
      SELECT a.*
        FROM (SELECT e.ent_id
                    ,e.name
                FROM entity e
               START WITH e.ent_id = p_ent_id
              CONNECT BY PRIOR e.parent_id = e.ent_id) t
       INNER JOIN attr a
          ON a.ent_id = t.ent_id
       INNER JOIN attr_type aty
          ON aty.attr_type_id = a.attr_type_id
         AND aty.brief IN ('F', 'R', 'UR', 'C');
  END;

  FUNCTION get_obj_ent_id
  (
    p_ent_id IN NUMBER
   ,p_obj_id IN NUMBER
  ) RETURN NUMBER IS
    c            NUMBER;
    n            NUMBER;
    v_res_ent_id NUMBER;
    v_table_name VARCHAR2(30);
    v_sql        VARCHAR2(4000);
  BEGIN
    SELECT e.source INTO v_table_name FROM entity e WHERE e.ent_id = p_ent_id;
    v_sql := 'select Ent_ID from ' || v_table_name || ' where ' || ents.get_ent_pk(p_ent_id) || ' = '
            --  v_Table_Name || '_ID = '
             || to_char(p_obj_id);
    BEGIN
      c := dbms_sql.open_cursor;
      dbms_sql.parse(c, v_sql, dbms_sql.native);
      n := dbms_sql.execute(c);
      dbms_sql.define_column(c, 1, v_res_ent_id);
      IF dbms_sql.fetch_rows(c) > 0
      THEN
        dbms_sql.column_value(c, 1, v_res_ent_id);
      ELSE
        v_res_ent_id := p_ent_id;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        v_res_ent_id := NULL;
    END;
    dbms_sql.close_cursor(c);
    RETURN v_res_ent_id;
  END;

  FUNCTION calc_attr
  (
    p_attr   attr%ROWTYPE
   ,p_obj_id NUMBER
  ) RETURN NUMBER IS
    v_sql_str VARCHAR(4000);
    v_ret_val NUMBER;
  BEGIN
    IF p_attr.source IS NOT NULL
       AND p_attr.col_name IS NOT NULL
    THEN
      v_sql_str := 'begin select ' || p_attr.col_name || ' into :ret_val from ' || p_attr.source ||
                   ' where ' || ents.get_ent_pk(ent.id_by_brief(p_attr.source)) || '= :obj_id; end;';
    ELSIF p_attr.calc IS NOT NULL
    THEN
      v_sql_str := p_attr.calc;
    ELSE
      raise_application_error(-20000, 'Bad definition of attribute');
    END IF;
  
    EXECUTE IMMEDIATE v_sql_str
      USING OUT v_ret_val, IN p_obj_id;
  
    RETURN v_ret_val;
  END;

  /**
  * �������� �������� ������������ ��������
  * @author Denis Ivanov
  * @param p_ent_brief ���������� ��������
  * @param p_attr_brief ���������� �������� ��������
  * @param p_obj_id �� ������� ��������, �������� �������� �������� ����� ��������
  * @return �������� ������������ ��������
  */
  FUNCTION calc_attr
  (
    p_ent_brief  attr.source%TYPE
   ,p_attr_brief attr.brief%TYPE
   ,p_obj_id     NUMBER
  ) RETURN NUMBER IS
    v_attr    attr%ROWTYPE;
    v_ret_val NUMBER;
  BEGIN
    SELECT a.*
      INTO v_attr
      FROM attr a
     WHERE a.brief = p_attr_brief
       AND a.source = p_ent_brief;
    RETURN calc_attr(v_attr, p_obj_id);
  EXCEPTION
    WHEN no_data_found THEN
      raise_application_error(-20000
                             ,'�� ������ ������� ' || p_attr_brief || ' �������� ' || p_ent_brief);
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'��� ���������� �������� �������� ��������� ������: ' || SQLERRM);
  END;

  FUNCTION min_date RETURN DATE AS
  BEGIN
    RETURN to_date('01.01.1900', 'DD.MM.YYYY');
  END;

  FUNCTION max_date RETURN DATE AS
  BEGIN
    RETURN to_date('31.12.2200', 'DD.MM.YYYY');
  END;

  PROCEDURE commit_form IS
  BEGIN
    COMMIT;
  END;

  FUNCTION get_rep_brief RETURN VARCHAR2 AS
  BEGIN
    RETURN rep_brief;
  END;

  FUNCTION trans
  (
    p_ent_brief  IN VARCHAR2
   ,p_attr_brief IN VARCHAR2
   ,p_obj_id     IN NUMBER
   ,p_def_val    VARCHAR2 DEFAULT NULL
  ) RETURN VARCHAR2 AS
    v_result  VARCHAR2(300);
    v_lang_id CHAR(3);
  BEGIN
    v_lang_id := ents.lang_id;
    IF v_lang_id = ents.sys_lang_id
    THEN
      RETURN p_def_val;
    END IF;
  
    SELECT lr.name
      INTO v_result
      FROM lang_res lr
     WHERE lr.brief = p_ent_brief || '.' || p_attr_brief
       AND lr.obj_id = p_obj_id
       AND lr.lang_id = v_lang_id;
    RETURN v_result;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN p_def_val;
    WHEN OTHERS THEN
      RAISE;
  END;

  FUNCTION trans
  (
    p_attr_id IN NUMBER
   ,p_obj_id  IN NUMBER
   ,p_def_val VARCHAR2 DEFAULT NULL
  ) RETURN VARCHAR2 AS
    v_result  VARCHAR2(300);
    v_lang_id CHAR(3);
  BEGIN
    v_lang_id := ents.lang_id;
    IF v_lang_id = ents.sys_lang_id
    THEN
      RETURN p_def_val;
    END IF;
  
    SELECT lr.name
      INTO v_result
      FROM lang_res lr
     WHERE lr.attr_id = p_attr_id
       AND lr.obj_id = p_obj_id
       AND lr.lang_id = v_lang_id;
    RETURN v_result;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN p_def_val;
    WHEN OTHERS THEN
      RAISE;
  END;

  FUNCTION trans_item
  (
    p_item      IN VARCHAR2
   ,p_def_val   VARCHAR2
   ,p_elem_type VARCHAR2 DEFAULT NULL
  ) RETURN VARCHAR2 AS
    v_result  VARCHAR2(300);
    v_lang_id CHAR(3);
  BEGIN
    v_lang_id := ents.lang_id;
    IF v_lang_id = ents.sys_lang_id
    THEN
      RETURN p_def_val;
    END IF;
  
    SELECT lr.name
      INTO v_result
      FROM lang_res lr
     WHERE lr.brief = p_item
       AND lr.obj_id IS NULL
       AND lr.lang_id = v_lang_id
       AND nvl(p_elem_type, 'ITEM') = nvl(lr.element_type, 'ITEM');
    RETURN v_result;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN p_def_val;
    WHEN OTHERS THEN
      RAISE;
  END;

  PROCEDURE init_ent_var AS
    v_lang_id   NUMBER;
    v_filial_id NUMBER;
  BEGIN
    IF USER <> 'INS'
    THEN
      SELECT su.lang_id
            ,su.organisation_id
        INTO v_lang_id
            ,v_filial_id
        FROM v_sys_user su
       WHERE su.sys_user_name = USER;
      ents.filial_id := v_filial_id;
      ents.lang_id   := v_lang_id;
    END IF;
  END;

  FUNCTION fn_obj_id_by_val
  (
    p_ent_brief IN VARCHAR2
   ,p_val       IN VARCHAR2
  ) RETURN NUMBER AS
  BEGIN
    RETURN get_obj_id(p_ent_brief, p_val);
    /*
        res number;
        v_source varchar2(30);
        v_id_name varchar2(30);
        v_col_name varchar2(30);
        v_ent_name varchar2(200);
        v_ent_id number(6);
      begin
        select e.source, e.id_name, e.name, e.ent_id
        into v_source, v_id_name, v_ent_name, v_ent_id
        from entity e,
             attr a,
             attr_type aty
        where e.brief = p_ent_brief
              and a.ent_id = e.ent_id
              and aty.attr_type_id = a.attr_type_id
              and aty.brief = 'OI';
    
        begin
          select a.col_name into v_col_name
          from attr a
          where a.is_key = 1
                and a.ent_id in ( select e.ent_id
                                  from entity e
                                  start with e.ent_id = v_ent_id
                                  connect by e.ent_id = prior e.parent_id
                                );
        exception
          when no_data_found then
            raise_application_error(-20000, 'obj_id_by_val. ' || '�� ���������� �������� ���� �� �������� "' || v_ent_name || '".');
          when too_many_rows then
            raise_application_error(-20000, 'obj_id_by_val. ' || '���������� �������� ����� �� �������� "' || v_ent_name || '"������ ������.');
        end;
    
        execute immediate 'select ' || v_id_name || ' from ven_' || v_source || ' where ' || v_col_name || ' = ''' || p_val || '''' into res;
        return res;
      exception
          when no_data_found then
            return null;
          when too_many_rows then
            raise_application_error(-20000, 'obj_id_by_val. ' || '������� ���������� �������� ���� �� �������� "' || v_ent_name || '".');
    */
  END;

  FUNCTION get_obj_id
  (
    p_table_brief IN VARCHAR2
   ,p_obj_brief   IN VARCHAR2
  ) RETURN NUMBER IS
    c            NUMBER;
    n            NUMBER;
    RESULT       NUMBER;
    v_table_name VARCHAR2(30);
    v_sql        VARCHAR2(4000);
    v_ent_id     NUMBER; -- �� �������-��������
  BEGIN
    BEGIN
      SELECT e.source
            ,e.ent_id
        INTO v_table_name
            ,v_ent_id
        FROM entity e
       WHERE upper(e.brief) = upper(p_table_brief);
    EXCEPTION
      WHEN no_data_found THEN
        RETURN NULL;
        RAISE no_data_found;
    END;
  
    v_sql := 'select ' || ents.get_ent_pk(v_ent_id) || ' from ' || v_table_name ||
             ' where upper(brief) = upper(''' || p_obj_brief || ''')';
    BEGIN
      c := dbms_sql.open_cursor;
      dbms_sql.parse(c, v_sql, dbms_sql.native);
      n := dbms_sql.execute(c);
      dbms_sql.define_column(c, 1, RESULT);
      IF dbms_sql.fetch_rows(c) > 0
      THEN
        dbms_sql.column_value(c, 1, RESULT);
      ELSE
        RESULT := NULL;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        RESULT := NULL;
    END;
    dbms_sql.close_cursor(c);
    RETURN RESULT;
  END; -- func

  /*
   ��������� ���������� �� ������ � ������ ID � ������ ENTITY
   ����� �.
  */
  FUNCTION check_ent_obj_exists
  (
    par_ent_id entity.ent_id%TYPE
   ,par_obj_id NUMBER
  ) RETURN BOOLEAN IS
    v_sql            VARCHAR2(1000);
    v_exists         NUMBER(1);
    v_table_name     VARCHAR2(30);
    v_pk_column_name VARCHAR2(30);
  BEGIN
    SELECT e.source
          ,nvl(e.id_name, e.source || '_ID')
      INTO v_table_name
          ,v_pk_column_name
      FROM entity e
     WHERE e.ent_id = par_ent_id;
  
    v_sql := 'select count(*) from dual where exists (select null from ' || v_table_name || ' where ' ||
             v_pk_column_name || ' = :P_OBJ_ID)';
  
    EXECUTE IMMEDIATE v_sql
      INTO v_exists
      USING par_obj_id;
  
    RETURN v_exists > 0;
  
  END check_ent_obj_exists;

  FUNCTION check_ent_obj_exists
  (
    par_ent_brief entity.brief%TYPE
   ,par_obj_id    NUMBER
  ) RETURN BOOLEAN IS
    v_ent_id entity.ent_id%TYPE;
  BEGIN
    v_ent_id := id_by_brief(par_ent_brief);
    RETURN check_ent_obj_exists(par_ent_id => v_ent_id, par_obj_id => par_obj_id);
  END check_ent_obj_exists;
END;
/

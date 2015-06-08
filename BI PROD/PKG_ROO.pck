CREATE OR REPLACE PACKAGE PKG_ROO IS

  -- Author  : ������ �.
  -- Created : 14.06.2011 17:43:54
  -- Purpose : ����� ��� ������ �� ������������ ���

  /*
    ������ �.
    ��������� ������ ������
  */
  FUNCTION get_next_number RETURN NUMBER;
  /*
    ������ �.
    ���������� ������������� �� ��������� ���� ���������
  */
  FUNCTION get_default_end_date RETURN DATE;
  /*
    ������ �.
    �������� �������� ���
  */
  PROCEDURE check_roo
  (
    par_roo_name      VARCHAR2
   ,par_open_date     DATE
   ,par_start_date    DATE
   ,par_roo_number    NUMBER
   ,par_department_id VARCHAR2
   ,par_roo_header_id NUMBER
  );
  /*
    ������ �.
    ��������� ���������� � ���
  */
  PROCEDURE insert_employee
  (
    par_roo_id          NUMBER
   ,par_sys_user_id     NUMBER
   ,par_begin_date      DATE
   ,par_end_date        DATE
   ,par_roo_employee_id OUT NUMBER
  );
  /*
    ������ �.
    ���������� ������ ���������� ���
  */
  PROCEDURE update_employee
  (
    par_roo_employee_id NUMBER
   ,par_sys_user_id     NUMBER
   ,par_begin_date      DATE
   ,par_end_date        DATE
  );
  /*
    ������ �.
    ������� ������ ���������� �� ���
  */
  PROCEDURE delete_employee(par_roo_employee_id NUMBER);
  /*
    ������ �.
    �������������� �����������
  */
  PROCEDURE restore_employees
  (
    par_roo_header_id NUMBER
   ,par_roo_to_id     NUMBER
  );
  /*
    ������ �.
    �������� ����� ������
  */
  PROCEDURE create_new_version
  (
    par_roo_header_id   IN OUT NUMBER
   ,par_roo_number      NUMBER
   ,par_roo_name        VARCHAR2
   ,par_department_id   NUMBER
   ,par_open_date       DATE
   ,par_close_date      DATE
   ,par_corp_mail       VARCHAR2
   ,par_t_tap_header_id NUMBER
   ,par_roo_id          OUT NUMBER
  );
END PKG_ROO;
/
CREATE OR REPLACE PACKAGE BODY PKG_ROO IS
  -- ���� ��������� �� ���������
  gc_default_end_date CONSTANT DATE := to_date('31.12.3000', 'dd.mm.yyyy');
  -- ������� �������� ������� ��������� ��� (������)
  gc_t_roo_brief CONSTANT VARCHAR2(30) := 'T_ROO';
  -- �� �������� T_ROO;
  gv_roo_ent_id NUMBER;
  -- ������ �����������
  TYPE t_roo_employees IS TABLE OF t_roo_employee%ROWTYPE;
  gvr_employees t_roo_employees;

  /*
    ������ �.
    ��������� ������ ������
  */
  FUNCTION get_next_number RETURN NUMBER IS
    v_roo_number NUMBER;
  BEGIN
    SELECT nvl(MAX(roo_number) + 1, 1) INTO v_roo_number FROM ven_t_roo_header;
    RETURN v_roo_number;
  END get_next_number;

  /*
    ������ �.
    �������� �������� ���
  */
  PROCEDURE check_roo
  (
    par_roo_name      VARCHAR2
   ,par_open_date     DATE
   ,par_start_date    DATE
   ,par_roo_number    NUMBER
   ,par_department_id VARCHAR2
   ,par_roo_header_id NUMBER
  ) IS
    v_cnt NUMBER;
  BEGIN
    -- *�������� �� ������������� �����*
  
    -- ����� ��� �� ������
    IF par_roo_number IS NULL
    THEN
      raise_application_error(-20001, '����� ��� ������ ���� ������');
    END IF;
    -- �������� ��� �� ������
    IF par_roo_name IS NULL
    THEN
      raise_application_error(-20001, '�������� ��� ������ ���� �������');
    END IF;
    -- ���� �������� �� ������
    IF par_open_date IS NULL
    THEN
      raise_application_error(-20001
                             ,'���� �������� ������ ���� �������');
    END IF;
    -- ���� ������ ������
    IF par_start_date IS NULL
    THEN
      raise_application_error(-20001
                             ,'���� ������ ������ ������ ���� �������');
    END IF;
  
    -- *�������� �� ������������ ��������*
  
    -- �����
    IF par_roo_number NOT BETWEEN 1 AND 999
    THEN
      raise_application_error(-20001
                             ,'����� ��� ������ ���� � ��������� � 1 �� 999');
    END IF;
    -- ���� �������� �� ����� 01.01.2000
    IF par_open_date < to_date('01.01.2000', 'dd.mm.yyyy')
    THEN
      raise_application_error(-20001
                             ,'���� �������� �� ������ ���� ����� 01.01.2000');
    END IF;
    -- ������������� �� �������
    SELECT COUNT(1)
      INTO v_cnt
      FROM dual
     WHERE EXISTS (SELECT NULL
              FROM ven_sales_dept_header sh
                  ,ven_sales_dept        sd
             WHERE sh.organisation_tree_id = par_department_id
               AND sh.last_sales_dept_id = sd.sales_dept_id
               AND sd.close_date != pkg_roo.get_default_end_date);
    IF v_cnt = 1
    THEN
      raise_application_error(-20001, '������� �������� �������������');
    END IF;
  
    -- *�������� �� ������������ ��������*
  
    -- ������������ ��������
    SELECT COUNT(1)
      INTO v_cnt
      FROM dual
     WHERE EXISTS
     (SELECT NULL
              FROM ven_t_roo tt
             WHERE upper(tt.roo_name) = upper(par_roo_name)
               AND (par_roo_header_id IS NULL OR tt.t_roo_header_id != par_roo_header_id));
    IF v_cnt = 1
    THEN
      raise_application_error(-20001
                             ,'��� � ����� ��������� ��� ����������');
    END IF;
  END check_roo;

  /*
    ������ �.
    �������� �������� �����������
  */
  PROCEDURE check_employee
  (
    par_roo_id            NUMBER
   ,par_sys_user_id       NUMBER
   ,par_begin_date        DATE
   ,par_end_date          DATE
   ,par_t_roo_employee_id NUMBER
  ) IS
    v_cnt           NUMBER;
    v_roo_header_id NUMBER;
    v_contact       contact.obj_name_orig%TYPE;
    v_number        ven_t_roo_header.roo_number%TYPE;
  BEGIN
    -- *�������� ����������*
    -- 
    IF par_roo_id IS NULL
    THEN
      raise_application_error(-20001, '�� ��� ������ ���� ������');
    END IF;
    IF par_sys_user_id IS NULL
    THEN
      raise_application_error(-20001
                             ,'�� ������������ ������ ���� ������');
    END IF;
    IF par_begin_date IS NULL
    THEN
      raise_application_error(-20001
                             ,'���� ������ �������� ������ ���� �������');
    END IF;
    -- *�������� ������������*
    IF par_begin_date > nvl(par_end_date, gc_default_end_date)
    THEN
      raise_application_error(-20001
                             ,'���� ������ �� ����� ��������� ���� ���������');
    END IF;
    -- *�������� ������������*
    BEGIN
      SELECT co.obj_name_orig
            ,rh.roo_number
        INTO v_contact
            ,v_number
        FROM contact            co
            ,ven_employee       ee
            ,ven_sys_user       su
            ,ven_t_roo_employee re
            ,ven_t_roo          ro
            ,ven_t_roo_header   rh
       WHERE ee.contact_id = co.contact_id
         AND re.sys_user_id = su.employee_id
         AND re.sys_user_id = par_sys_user_id
         AND re.t_roo_id = ro.t_roo_id
         AND ro.t_roo_header_id = rh.t_roo_header_id
         AND ro.t_roo_id = rh.last_roo_id
         AND rh.t_roo_header_id != v_roo_header_id
         AND re.begin_date <= nvl(par_end_date, gc_default_end_date)
         AND re.end_date >= par_begin_date
         AND rownum = 1;
    
      raise_application_error(-20001
                             ,'��������! ��������� ��������� (' || v_contact ||
                              ') ��� �������� � ��� (' || v_number || ')');
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
    END;
    SELECT COUNT(1)
      INTO v_cnt
      FROM dual
     WHERE EXISTS (SELECT NULL
              FROM ven_t_roo_employee re
             WHERE re.t_roo_id = par_roo_id
               AND re.begin_date <= nvl(par_end_date, gc_default_end_date)
               AND re.end_date >= par_begin_date
               AND re.sys_user_id = par_sys_user_id
               AND re.t_roo_employee_id != par_t_roo_employee_id);
    IF v_cnt = 1
    THEN
      raise_application_error(-20001
                             ,'��������! ��������� ��� ���������!');
    END IF;
  END check_employee;

  /*
    ������ �.
    ��������� ��������� ������ � ���������
  */
  PROCEDURE set_last_version
  (
    par_roo_header_id NUMBER
   ,par_roo_id        NUMBER
  ) IS
  BEGIN
    UPDATE ven_t_roo_header th
       SET th.last_roo_id = par_roo_id
     WHERE th.t_roo_header_id = par_roo_header_id;
  END set_last_version;

  /*
    ������ �.
    �������� ���������
  */
  PROCEDURE create_header
  (
    par_roo_number    NUMBER
   ,par_roo_header_id OUT NUMBER
  ) IS
  BEGIN
    SELECT sq_t_roo_header.nextval INTO par_roo_header_id FROM dual;
    INSERT INTO ven_t_roo_header
      (t_roo_header_id, roo_number)
    VALUES
      (par_roo_header_id, par_roo_number);
  END create_header;
  /*
    ������ �.
    ��������� ���������� ������ ������
  */
  FUNCTION get_new_ver_num(par_roo_header_id NUMBER) RETURN NUMBER IS
    v_ver_num ven_t_roo.ver_num%TYPE;
  BEGIN
    SELECT nvl(MAX(tt.ver_num), 0) + 1
      INTO v_ver_num
      FROM ven_t_roo tt
     WHERE tt.t_roo_header_id = par_roo_header_id;
    RETURN v_ver_num;
  END get_new_ver_num;

  /*
    ������ �.
    ������� �������� ������
  */
  -- ������� �. 01/06/2012 ������� ���� ��� (RT 168362)  
  PROCEDURE create_version_base
  (
    par_roo_header_id   NUMBER
   ,par_roo_name        VARCHAR2
   ,par_department_id   NUMBER
   ,par_open_date       DATE
   ,par_start_date      DATE
   ,par_close_date      DATE
   ,par_corp_mail       VARCHAR2
   ,par_t_tap_header_id NUMBER
   ,par_ver_num         NUMBER
   ,par_sys_user_id     NUMBER
   ,par_roo_id          OUT NUMBER
  ) IS
  BEGIN
    SELECT sq_t_roo.nextval INTO par_roo_id FROM dual;
  
    INSERT INTO ven_t_roo
      (t_roo_id
      ,t_roo_header_id
      ,roo_name
      ,organisation_tree_id
      ,t_tap_header_id
      ,open_date
      ,start_date
      ,close_date
      ,ver_num
      ,sys_user_id
      ,corp_mail)
    VALUES
      (par_roo_id
      ,par_roo_header_id
      ,par_roo_name
      ,par_department_id
      ,par_t_tap_header_id
      ,par_open_date
      ,par_start_date
      ,par_close_date
      ,par_ver_num
      ,par_sys_user_id
      ,par_corp_mail);
  
    set_last_version(par_roo_header_id, par_roo_id);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      raise_application_error(-20001
                             ,'� ����������� �������� ���������� ����������� ������ � ������� ��������� "' ||
                              gc_t_roo_brief || '"');
  END create_version_base;
  /*
    ������ �.
    ���������� ������������� �� ��������� ���� ���������
  */
  FUNCTION get_default_end_date RETURN DATE IS
  BEGIN
    RETURN gc_default_end_date;
  END get_default_end_date;
  /*
    ������ �.
    ���������� ����������� � ���������
  */
  PROCEDURE store_employees(par_roo_header_id NUMBER) IS
  BEGIN
    SELECT * BULK COLLECT
      INTO gvr_employees
      FROM t_roo_employee tt
     WHERE tt.t_roo_id =
           (SELECT th.last_roo_id FROM t_roo_header th WHERE th.t_roo_header_id = par_roo_header_id);
  END store_employees;
  /*
    ������ �.
    �������������� �����������
  */
  PROCEDURE restore_employees
  (
    par_roo_header_id NUMBER
   ,par_roo_to_id     NUMBER
  ) IS
    v_prev_roo_id NUMBER;
  BEGIN
    IF gvr_employees IS NOT NULL
    THEN
      -- ��������� ���������� ������
      SELECT tc.t_roo_id
        INTO v_prev_roo_id
        FROM ven_t_roo tc
       WHERE tc.t_roo_header_id = par_roo_header_id
         AND tc.ver_num = (SELECT tt.ver_num - 1 FROM ven_t_roo tt WHERE tt.t_roo_id = par_roo_to_id);
      -- ������� ����������� FORMS ����� �� ���������� ������ �� �����
      UPDATE t_roo_employee tt
         SET tt.t_roo_employee_id = sq_t_roo_employee.nextval
            ,tt.t_roo_id          = par_roo_to_id
       WHERE tt.t_roo_id = v_prev_roo_id;
      -- ������� ����������� ��� �������� ������ ����� 
      FORALL i IN gvr_employees.first .. gvr_employees.last
        INSERT INTO t_roo_employee VALUES gvr_employees (i);
      gvr_employees.delete;
    END IF;
  END restore_employees;

  /*
    ������ �.
    �������� ����� ������
  */
  -- ������� �. 01/06/2012 ������� ���� ��� (RT 168362)  
  PROCEDURE create_new_version
  (
    par_roo_header_id   IN OUT NUMBER
   ,par_roo_number      NUMBER
   ,par_roo_name        VARCHAR2
   ,par_department_id   NUMBER
   ,par_open_date       DATE
   ,par_close_date      DATE
   ,par_corp_mail       VARCHAR2
   ,par_t_tap_header_id NUMBER
   ,par_roo_id          OUT NUMBER
  ) IS
    v_start_date  DATE := SYSDATE;
    v_sys_user_id sys_user.sys_user_id%TYPE;
  BEGIN
    IF par_roo_header_id IS NULL
    THEN
      -- �������� ���������
      create_header(par_roo_number, par_roo_header_id);
    ELSE
      -- ���������� �����������, ��� ���� ����� FORMS �� ������� ��� POST'�
      store_employees(par_roo_header_id);
    END IF;
    -- ��������� ������������
    BEGIN
      SELECT su.sys_user_id INTO v_sys_user_id FROM sys_user su WHERE su.sys_user_name = USER;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        raise_application_error(-20001
                               ,'������������ ' || USER || ' �� �������� ������������� �������');
    END;
    -- �������� ����� ������
    create_version_base(par_roo_header_id   => par_roo_header_id
                       ,par_roo_name        => par_roo_name
                       ,par_open_date       => par_open_date
                       ,par_start_date      => v_start_date
                       ,par_close_date      => nvl(par_close_date, gc_default_end_date)
                       ,par_corp_mail       => par_corp_mail
                       ,par_t_tap_header_id => par_t_tap_header_id
                       ,par_ver_num         => get_new_ver_num(par_roo_header_id)
                       ,par_department_id   => par_department_id
                       ,par_sys_user_id     => v_sys_user_id
                       ,par_roo_id          => par_roo_id);
  END create_new_version;

  /*
    ������ �.
    ��������� ���������� � ���
  */
  PROCEDURE insert_employee
  (
    par_roo_id          NUMBER
   ,par_sys_user_id     NUMBER
   ,par_begin_date      DATE
   ,par_end_date        DATE
   ,par_roo_employee_id OUT NUMBER
  ) IS
  BEGIN
    SELECT sq_t_roo_employee.nextval INTO par_roo_employee_id FROM dual;
  
    check_employee(par_roo_id            => par_roo_id
                  ,par_sys_user_id       => par_sys_user_id
                  ,par_begin_date        => par_begin_date
                  ,par_end_date          => par_end_date
                  ,par_t_roo_employee_id => par_roo_employee_id);
  
    INSERT INTO ven_t_roo_employee
      (t_roo_employee_id, t_roo_id, sys_user_id, begin_date, end_date)
    VALUES
      (par_roo_employee_id
      ,par_roo_id
      ,par_sys_user_id
      ,par_begin_date
      ,nvl(par_end_date, gc_default_end_date));
  END insert_employee;
  /*
    ������ �.
    ���������� ������ ���������� � ���
  */
  PROCEDURE update_employee
  (
    par_roo_employee_id NUMBER
   ,par_sys_user_id     NUMBER
   ,par_begin_date      DATE
   ,par_end_date        DATE
  ) IS
    v_roo_id ven_t_roo.t_roo_id%TYPE;
  BEGIN
    SELECT re.t_roo_id
      INTO v_roo_id
      FROM ven_t_roo_employee re
     WHERE re.t_roo_employee_id = par_roo_employee_id;
  
    check_employee(par_roo_id            => v_roo_id
                  ,par_sys_user_id       => par_sys_user_id
                  ,par_begin_date        => par_begin_date
                  ,par_end_date          => par_end_date
                  ,par_t_roo_employee_id => par_roo_employee_id);
  
    UPDATE ven_t_roo_employee ta
       SET sys_user_id = par_sys_user_id
          ,begin_date  = par_begin_date
          ,end_date    = nvl(par_end_date, gc_default_end_date)
     WHERE ta.t_roo_employee_id = par_roo_employee_id;
  END update_employee;
  /*
    ������ �.
    ������� ������ ���������� � ���
  */
  PROCEDURE delete_employee(par_roo_employee_id NUMBER) IS
  BEGIN
    DELETE FROM ven_t_roo_employee ta WHERE ta.t_roo_employee_id = par_roo_employee_id;
  END delete_employee;
BEGIN
  SELECT en.ent_id INTO gv_roo_ent_id FROM entity en WHERE en.brief = gc_t_roo_brief;
END PKG_ROO;
/

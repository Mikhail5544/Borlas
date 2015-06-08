CREATE OR REPLACE PACKAGE PKG_TAC IS

  -- Author  : ARTUR.BAYTIN
  -- Created : 26.07.2011 10:44:20
  -- Purpose : ����� ��� ������ �� ������������ ���, ������� ������ ���
  /*
    ������ �.
    ���������� ������������� �� ��������� ���� ���������
  */
  FUNCTION get_default_end_date RETURN DATE;
  /*
    ������ �.
    �������� ������������ ���������� ������ � ������
  */
  PROCEDURE check_tac
  (
    par_tac_number     NUMBER
   ,par_tac_name       VARCHAR2
   ,par_open_date      DATE
   ,par_start_date     DATE
   ,par_agreement_num  VARCHAR2
   ,par_agreement_date DATE
   ,par_tap_header_id  NUMBER
   ,par_tac_header_id  NUMBER
  );

  /*
  * ��������. �� ������ ���� ������ � ������ ������ ���
  */
  PROCEDURE check_tap
  (
    par_tac_id        NUMBER
   ,par_tap_header_id NUMBER
   ,par_begin_date    DATE
   ,par_end_date      DATE
  );

  /*
    ������ �.
    �������������� �����
  */
  PROCEDURE restore_taps
  (
    par_tac_header_id NUMBER
   ,par_tac_to_id     NUMBER
  );
  /*
    ������ �.
    ��������� ����� ��� � ���
  */
  PROCEDURE insert_tap
  (
    par_tac_id        NUMBER
   ,par_tap_header_id NUMBER
   ,par_begin_date    DATE
   ,par_end_date      DATE
   ,par_is_main       NUMBER
   ,par_tac_to_tap_id OUT NUMBER
  );
  /*
    ������ �.
    ���������� ����� ��� � ���
  */
  PROCEDURE update_tap
  (
    par_tac_to_tap_id NUMBER
   ,par_tap_header_id NUMBER
   ,par_begin_date    DATE
   ,par_end_date      DATE
  );
  /*
    ������ �.
    ������� ������ ����� ��� � ���
  */
  PROCEDURE delete_tap(par_tac_to_tap_id NUMBER);
  /*
    ������ �.
    �������� ����� ������ (����� ����������)
  */
  PROCEDURE create_new_version
  (
    par_tac_header_id  IN OUT NUMBER
   ,par_tac_name       VARCHAR2
   ,par_tac_number     NUMBER
   ,par_open_date      DATE
   ,par_close_date     DATE
   ,par_agreement_num  VARCHAR2
   ,par_agreement_date DATE
   ,par_tap_header_id  NUMBER
   ,par_tac_id         OUT NUMBER
  );

  /*
    ������ �.
    �������� �������� ���, ����������� ���
  
  */
  PROCEDURE close_taps
  (
    par_tap_header_id NUMBER
   ,par_close_date    ven_t_tap.close_date%TYPE DEFAULT NULL
  );
END PKG_TAC;
/
CREATE OR REPLACE PACKAGE BODY PKG_TAC IS
  -- ���� ��������� �� ���������
  gc_default_end_date CONSTANT DATE := TO_DATE('31.12.3000', 'dd.mm.yyyy');
  -- ������ �������� �� ������� �� �� ���������
  gc_default_send_status CONSTANT NUMBER(1) := 0;
  -- ������� �������� ������� ��������� ��� (������)
  gc_t_tac_brief CONSTANT VARCHAR2(30) := 'T_TAC';
  -- �� �������� T_TAC;
  gv_tac_ent_id NUMBER;

  -- ������ �����
  TYPE t_taps IS TABLE OF t_tac_to_tap%ROWTYPE;
  gvr_taps t_taps;
  /*
    ������ �.
    �������� ������������ ���������� ������ � ������
  */
  PROCEDURE check_tac
  (
    par_tac_number     NUMBER
   ,par_tac_name       VARCHAR2
   ,par_open_date      DATE
   ,par_start_date     DATE
   ,par_agreement_num  VARCHAR2
   ,par_agreement_date DATE
   ,par_tap_header_id  NUMBER
   ,par_tac_header_id  NUMBER
  ) IS
    v_cnt NUMBER;
  BEGIN
    -- *�������� ����������*
    -- ����� ��� �� ������
    IF par_tac_number IS NULL
    THEN
      raise_application_error(-20001, '����� ��� ������ ���� ������!');
    END IF;
    -- �������� �� ������
    IF par_tac_name IS NULL
    THEN
      raise_application_error(-20001, '�������� ��� ������ ���� �������!');
    END IF;
    -- ���� �������� �� ������
    IF par_open_date IS NULL
    THEN
      raise_application_error(-20001
                             ,'���� �������� ������ ���� �������!');
    END IF;
    -- ���� ������ ������
    IF par_start_date IS NULL
    THEN
      raise_application_error(-20001
                             ,'���� ������ ������ ������ ���� �������!');
    END IF;
    -- ����� ����������
    IF par_agreement_num IS NULL
    THEN
      raise_application_error(-20001
                             ,'����� ���������� ������ ���� ������!');
    END IF;
    -- ���� ����������
    IF par_agreement_date IS NULL
    THEN
      raise_application_error(-20001
                             ,'���� ���������� ������ ���� �������!');
    END IF;
    -- ��� �������������
    IF par_tap_header_id IS NULL
    THEN
      raise_application_error(-20001
                             ,'��� ������������� ������ ���� ������!');
    END IF;
  
    -- *������������ ����������*
    /*
        select *
          from ven_t_tac tt
         where tt.t_tac_header_id = par_tac_header_id
           and tt.ver_num         = 
        -- �������� ���� ������, ����� ��� �� ���� ������ ���� ������ ���������� ������
        if par_start_date <= vr_tac.start_date then
          raise_application_error(-20001, '���� ������ ������ ��� ������ ���� ������ ���� ������ ���������� ������');
        end if;
    */
    -- ���� ���������� �� ������ ��������� ���� ��������
    IF par_agreement_date > par_open_date
    THEN
      raise_application_error(-20001
                             ,'���� ���������� �� ������ ��������� ���� ��������!');
    END IF;
  
    -- �������� ������������� ��� � ��������� �������
    SELECT COUNT(1)
      INTO v_cnt
      FROM dual
     WHERE EXISTS
     (SELECT NULL
              FROM ven_t_tac tt
             WHERE tt.tac_number = par_tac_number
               AND (par_tac_header_id IS NULL OR tt.t_tac_header_id != par_tac_header_id));
    IF v_cnt = 1
    THEN
      raise_application_error(-20001
                             ,'��� � ����� ������� ��� ����������!');
    END IF;
    -- �������� ������ ����������
    SELECT COUNT(1)
      INTO v_cnt
      FROM dual
     WHERE EXISTS
     (SELECT NULL
              FROM ven_t_tac tt
             WHERE upper(tt.agreement_num) = upper(par_agreement_num)
               AND (par_tac_header_id IS NULL OR tt.t_tac_header_id != par_tac_header_id));
    IF v_cnt = 1
    THEN
      raise_application_error(-20001
                             ,'��� � ����� ������� ���������� ��� ����������!');
    END IF;
  
  END check_tac;

  PROCEDURE check_tap
  (
    par_tac_id        NUMBER
   ,par_tap_header_id NUMBER
   ,par_begin_date    DATE
   ,par_end_date      DATE
  ) IS
    v_cnt            NUMBER(1);
    v_tap_number     t_tap.tap_number%TYPE;
    v_dbl_tac_number NUMBER;
  BEGIN
    -- �� ������ ���� ������ � ������ ������ ���
    SELECT COUNT(1)
      INTO v_cnt
      FROM dual
     WHERE EXISTS (SELECT NULL
              FROM ven_t_tac_header th
                  ,ven_t_tac_to_tap tt
                  ,ven_t_tac        ta
             WHERE th.last_tac_id = tt.t_tac_id
               AND tt.begin_date <= nvl(par_end_date, gc_default_end_date)
               AND tt.end_date >= par_begin_date
               AND tt.t_tap_header_id = par_tap_header_id
               AND ta.t_tac_id = par_tac_id
               AND ta.t_tac_header_id != th.t_tac_header_id);
    IF v_cnt = 1
    THEN
      /*������ 253629 ��������� �������� ���*/
      SELECT ta_.tac_number
        INTO v_dbl_tac_number
        FROM ven_t_tac_header th
            ,ven_t_tac_to_tap tt
            ,ven_t_tac        ta
            ,ven_t_tac        ta_
       WHERE th.last_tac_id = tt.t_tac_id
         AND tt.begin_date <= nvl(par_end_date, gc_default_end_date)
         AND tt.end_date >= par_begin_date
         AND tt.t_tap_header_id = par_tap_header_id
         AND ta.t_tac_id = par_tac_id
         AND ta.t_tac_header_id != th.t_tac_header_id
         AND ta_.t_tac_id = tt.t_tac_id
         AND rownum = 1;
      --
      SELECT tt.tap_number
        INTO v_tap_number
        FROM ven_t_tap        tt
            ,ven_t_tap_header th
       WHERE tt.t_tap_header_id = th.last_tap_id
         AND th.t_tap_header_id = par_tap_header_id;
    
      raise_application_error(-20001
                             ,'��� �' || to_char(v_tap_number) || ' ��� ��������� � ������ ��� �' ||
                              v_dbl_tac_number || '!');
    END IF;
  END check_tap;
  /*
    ������ �.
    ��������� ��������� ������ � ���������
  */
  PROCEDURE set_last_version
  (
    par_tac_header_id NUMBER
   ,par_tac_id        NUMBER
  ) IS
  BEGIN
    UPDATE ven_t_tac_header th
       SET th.last_tac_id = par_tac_id
     WHERE th.t_tac_header_id = par_tac_header_id;
  END set_last_version;

  /*
    ������ �.
    �������� ���������
  */
  PROCEDURE create_header(par_tac_header_id OUT NUMBER) IS
  BEGIN
    SELECT sq_t_tac_header.nextval INTO par_tac_header_id FROM dual;
    INSERT INTO ven_t_tac_header (t_tac_header_id) VALUES (par_tac_header_id);
  END create_header;
  /*
    ������ �.
    ������� �������� ������
  */
  PROCEDURE create_version_base
  (
    par_tac_header_id  NUMBER
   ,par_tac_number     NUMBER
   ,par_tac_name       VARCHAR2
   ,par_open_date      DATE
   ,par_close_date     DATE
   ,par_tap_header_id  NUMBER
   ,par_agreement_num  VARCHAR2
   ,par_agreement_date DATE
   ,par_ver_num        NUMBER
   ,par_start_date     DATE
   ,par_sys_user_id    NUMBER
   ,par_tac_id         OUT NUMBER
  ) IS
    v_tac_id NUMBER;
  BEGIN
    SELECT sq_t_tac.nextval INTO v_tac_id FROM dual;
  
    INSERT INTO ven_t_tac
      (t_tac_id
      ,t_tac_header_id
      ,tac_number
      ,tac_name
      ,open_date
      ,t_tap_header_id
      ,start_date
      ,close_date
      ,agreement_num
      ,agreement_date
      ,send_status
      ,ver_num
      ,sys_user_id)
    VALUES
      (v_tac_id
      ,par_tac_header_id
      ,par_tac_number
      ,par_tac_name
      ,par_open_date
      ,par_tap_header_id
      ,par_start_date
      ,par_close_date
      ,par_agreement_num
      ,par_agreement_date
      ,gc_default_send_status
      ,par_ver_num
      ,par_sys_user_id);
  
    set_last_version(par_tac_header_id, v_tac_id);
  
    par_tac_id := v_tac_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      raise_application_error(-20001
                             ,'� ����������� �������� ���������� ����������� ������ � ������� ��������� "' ||
                              gc_t_tac_brief || '"');
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
    ��������� ���������� ������ ������
  */
  FUNCTION get_new_ver_num(par_tac_header_id NUMBER) RETURN NUMBER IS
    v_ver_num ven_t_tac.ver_num%TYPE;
  BEGIN
    SELECT nvl(MAX(tt.ver_num), 0) + 1
      INTO v_ver_num
      FROM ven_t_tac tt
     WHERE tt.t_tac_header_id = par_tac_header_id;
    RETURN v_ver_num;
  END get_new_ver_num;

  /*
    ������ �.
    ���������� ����� � ���������
  */
  PROCEDURE store_taps(par_tac_header_id NUMBER) IS
  BEGIN
    SELECT * BULK COLLECT
      INTO gvr_taps
      FROM t_tac_to_tap tt
     WHERE tt.t_tac_id =
           (SELECT th.last_tac_id FROM t_tac_header th WHERE th.t_tac_header_id = par_tac_header_id);
  END store_taps;
  /*
    ������ �.
    �������������� �����
  */
  PROCEDURE restore_taps
  (
    par_tac_header_id NUMBER
   ,par_tac_to_id     NUMBER
  ) IS
    v_prev_tac_id NUMBER;
  BEGIN
    IF gvr_taps IS NOT NULL
    THEN
      -- ��������� ���������� ������
      SELECT tc.t_tac_id
        INTO v_prev_tac_id
        FROM ven_t_tac tc
       WHERE tc.t_tac_header_id = par_tac_header_id
         AND tc.ver_num = (SELECT tt.ver_num - 1 FROM ven_t_tac tt WHERE tt.t_tac_id = par_tac_to_id);
      -- ������� ����������� FORMS ����� �� ���������� ������ �� �����
      UPDATE t_tac_to_tap tt
         SET tt.t_tac_to_tap_id = sq_t_tac_to_tap.nextval
            ,tt.t_tac_id        = par_tac_to_id
       WHERE tt.t_tac_id = v_prev_tac_id;
      -- ������� ����������� ��� �������� ������ ����� 
      FORALL i IN gvr_taps.first .. gvr_taps.last
        INSERT INTO t_tac_to_tap VALUES gvr_taps (i);
      gvr_taps.delete;
    END IF;
  END restore_taps;
  /*
    ������ �.
    �������� ����� ������
  */
  PROCEDURE create_new_version
  (
    par_tac_header_id  IN OUT NUMBER
   ,par_tac_name       VARCHAR2
   ,par_tac_number     NUMBER
   ,par_open_date      DATE
   ,par_close_date     DATE
   ,par_agreement_num  VARCHAR2
   ,par_agreement_date DATE
   ,par_tap_header_id  NUMBER
   ,par_tac_id         OUT NUMBER
  ) IS
    v_sys_user_id sys_user.sys_user_id%TYPE;
    v_start_date  DATE := SYSDATE;
  BEGIN
    -- ��������!!!
    --check_tac
    -- �������� ����� ������
    IF par_tac_header_id IS NULL
    THEN
      -- �������� ���������
      create_header(par_tac_header_id);
    ELSE
      -- ���������� �����, ��� ���� ����� FORMS �� ������� ��� POST'�
      store_taps(par_tac_header_id);
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
    create_version_base(par_tac_header_id  => par_tac_header_id
                       ,par_tac_number     => par_tac_number
                       ,par_tac_name       => par_tac_name
                       ,par_open_date      => par_open_date
                       ,par_close_date     => nvl(par_close_date, gc_default_end_date)
                       ,par_tap_header_id  => par_tap_header_id
                       ,par_agreement_num  => par_agreement_num
                       ,par_agreement_date => par_agreement_date
                       ,par_ver_num        => get_new_ver_num(par_tac_header_id)
                       ,par_start_date     => v_start_date
                       ,par_sys_user_id    => v_sys_user_id
                       ,par_tac_id         => par_tac_id);
  END create_new_version;

  /*
    ������ �.
    ��������� ����� ��� � ���
  */
  PROCEDURE insert_tap
  (
    par_tac_id        NUMBER
   ,par_tap_header_id NUMBER
   ,par_begin_date    DATE
   ,par_end_date      DATE
   ,par_is_main       NUMBER
   ,par_tac_to_tap_id OUT NUMBER
  ) IS
  BEGIN
  
    check_tap(par_tac_id        => par_tac_id
             ,par_tap_header_id => par_tap_header_id
             ,par_begin_date    => par_begin_date
             ,par_end_date      => par_end_date);
  
    SELECT sq_t_tac_to_tap.nextval INTO par_tac_to_tap_id FROM dual;
    BEGIN
      INSERT INTO ven_t_tac_to_tap
        (t_tac_to_tap_id, t_tac_id, t_tap_header_id, begin_date, end_date, is_main)
      VALUES
        (par_tac_to_tap_id
        ,par_tac_id
        ,par_tap_header_id
        ,par_begin_date
        ,nvl(par_end_date, gc_default_end_date)
        ,par_is_main);
    EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
        raise_application_error(-20001
                               ,'������ ��������� ������������� ������ � ������ �����');
    END;
  END insert_tap;
  /*
    ������ �.
    ���������� ����� ��� � ���
  */
  PROCEDURE update_tap
  (
    par_tac_to_tap_id NUMBER
   ,par_tap_header_id NUMBER
   ,par_begin_date    DATE
   ,par_end_date      DATE
  ) IS
    v_tac_id ven_t_tac.t_tac_id%TYPE;
  BEGIN
    SELECT tt.t_tac_id
      INTO v_tac_id
      FROM ven_t_tac_to_tap tt
     WHERE tt.t_tac_to_tap_id = par_tac_to_tap_id;
  
    check_tap(par_tac_id        => v_tac_id
             ,par_tap_header_id => par_tap_header_id
             ,par_begin_date    => par_begin_date
             ,par_end_date      => par_end_date);
  
    UPDATE ven_t_tac_to_tap ta
       SET t_tap_header_id = par_tap_header_id
          ,begin_date      = par_begin_date
          ,end_date        = nvl(par_end_date, gc_default_end_date)
     WHERE ta.t_tac_to_tap_id = par_tac_to_tap_id;
  EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
      raise_application_error(-20001
                             ,'������ ��������� ������������� ������ � ������ �����');
  END update_tap;
  /*
    ������ �.
    ������� ������ ����� ��� � ���
  */
  PROCEDURE delete_tap(par_tac_to_tap_id NUMBER) IS
  BEGIN
    DELETE FROM ven_t_tac_to_tap ta WHERE ta.t_tac_to_tap_id = par_tac_to_tap_id;
  END delete_tap;

  /*
    ������ �.
    �������� �������� ���, ����������� ���
  */
  PROCEDURE close_taps
  (
    par_tap_header_id NUMBER
   ,par_close_date    ven_t_tap.close_date%TYPE DEFAULT NULL
  ) IS
    v_close_date ven_t_tap.close_date%TYPE;
  BEGIN
    IF par_close_date IS NULL
    THEN
      SELECT tp.close_date
        INTO v_close_date
        FROM ven_t_tap_header th
            ,ven_t_tap        tp
       WHERE th.last_tap_id = tp.t_tap_id
         AND th.t_tap_header_id = par_tap_header_id;
    END IF;
    UPDATE ven_t_tac_to_tap tt
       SET tt.end_date = v_close_date
     WHERE tt.t_tap_header_id = par_tap_header_id
       AND tt.end_date > v_close_date;
  END close_taps;
BEGIN
  SELECT en.ent_id INTO gv_tac_ent_id FROM entity en WHERE en.brief = gc_t_tac_brief;
END PKG_TAC;
/

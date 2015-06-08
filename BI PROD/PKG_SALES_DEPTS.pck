CREATE OR REPLACE PACKAGE PKG_SALES_DEPTS IS

  -- Author  : ������ �.
  -- Created : 08.08.2011 15:20:38
  -- Purpose : ����� ��� ������ � ��������� ��������� ������������� (��)

  FUNCTION get_next_universal_code RETURN VARCHAR2;
  /*
    ������ �.
    ���������� ������������� �� ��������� ���� ���������
  */
  FUNCTION get_default_end_date RETURN DATE;

  /*
    ������ �.
    �������� ����� ������
  */
  PROCEDURE create_new_version
  (
    par_sales_dept_header_id IN OUT NUMBER
   ,par_universal_code       NUMBER
   ,par_dept_name            VARCHAR2
   ,par_marketing_name       VARCHAR2
   ,par_legal_name           VARCHAR2
   ,par_short_name           VARCHAR2
   ,par_initiator_id         NUMBER
   ,par_manager_id           NUMBER
   ,par_open_date            DATE
   ,par_close_date           DATE
   ,par_company_id           NUMBER
   ,par_address_id           NUMBER
   ,par_branch_id            NUMBER
   ,par_kpp                  VARCHAR2
   ,par_t_navision_cc_id     NUMBER
   ,par_t_roo_header_id      NUMBER
   ,par_t_tap_header_id      NUMBER
   ,par_sales_dept_id        OUT NUMBER
  );
  /*
    ������ �.
    �������� ������ � 1�
  */
  /*
    procedure send_to_1c
    (
      par_sales_dept_id number
    );
  */
  /*
    ������ �.
    ��������� ���������� �������
  */
  --  procedure get_from_1c;

  /*
    ������ �.
    �������� ���� ������� � B2B. ������������, ��������, ���� ��������� ���
  */
  PROCEDURE send_dept_agents_to_b2b(par_sales_dept_id NUMBER);

  /*
    ������ �.
    ��������� ID ������� ������ ��� ������������, ����������� �� ������ ������ ����������
    
    SAS:
         SAS
         SAS 2 
         ��� ������, �����-���������
         ��� �������
    SAS 2:
         SAS
         SAS 2 
         ��� ������, �����-���������
         ��� �������
    DSF:
         DSF
    ��� ������, �����-���������:
        SAS
        SAS 2 
        ��� ������, �����-���������
        ��� �������
    ��� �������:
        SAS
        SAS 2 
        ��� ������, �����-���������
        ��� �������
  */
  FUNCTION get_manager_sales_channel(par_initiator_channel_id NUMBER) RETURN t_number_type;

  /*
    ������ �.
    ������� � ���������� ID ������������� �� � ��������� �����������
  */
  FUNCTION get_existing_tree_id
  (
    par_sales_dept_header_id NUMBER
   ,par_new_dept_name        VARCHAR2
  ) RETURN NUMBER;

  /*
    ������ �.
    ������������ �� �� ������ ������ � ��������� �����������
  */
  PROCEDURE merge_with_existing
  (
    par_sales_dept_header_id NUMBER
   ,par_existing_org_tree_id NUMBER
  );

END PKG_SALES_DEPTS;
/
CREATE OR REPLACE PACKAGE BODY PKG_SALES_DEPTS IS
  -- ���� ��������� �� ���������
  gc_default_end_date CONSTANT DATE := to_date('31.12.3000', 'dd.mm.yyyy');
  -- ������� �������� ������� ��������� �� (������)
  gc_sales_dept_brief CONSTANT VARCHAR2(30) := 'SALES_DEPT';
  -- �� �������� SALES_DEPT;
  gv_sales_dept_ent_id NUMBER;

  -- ����������. ���������� �����.
  --  procedure set_version_to_1c_checking(par_sales_dept_id number);

  /*
    ������ �.
    �������� ������������ �������� ��
  */
  PROCEDURE check_sales_dept
  (
    par_universal_code       NUMBER
   ,par_dept_name            VARCHAR2
   ,par_legal_name           VARCHAR2
   ,par_short_name           VARCHAR2
   ,par_marketing_name       VARCHAR2
   ,par_branch_id            NUMBER
   ,par_company_id           NUMBER
   ,par_initiator_id         NUMBER
   ,par_kpp                  VARCHAR2
   ,par_manager_id           NUMBER
   ,par_open_date            DATE
   ,par_start_date           DATE
   ,par_t_roo_header_id      NUMBER
   ,par_t_tap_header_id      NUMBER
   ,par_sales_dept_header_id NUMBER
   ,par_address_id           NUMBER
  ) IS
    v_cnt NUMBER;
  BEGIN
    -- *�������� �� ������������� �����*
  
    -- �������� �� �� ������
    IF par_dept_name IS NULL
    THEN
      raise_application_error(-20001, '�������� �� ������ ���� �������!');
    END IF;
    -- ������������� ��� �� ������
    IF par_universal_code IS NULL
    THEN
      raise_application_error(-20001
                             ,'������������� ��� ������ ���� ������!');
    END IF;
    -- ������� �����������
    IF par_short_name IS NULL
    THEN
      raise_application_error(-20001
                             ,'������� ����������� ������ ���� �������!');
    END IF;
    -- ��������� ��������
    IF par_initiator_id IS NULL
    THEN
      raise_application_error(-20001
                             ,'��������� �������� ������ ���� ������!');
    END IF;
    -- ������������
    IF par_manager_id IS NULL
    THEN
      raise_application_error(-20001, '������������ ������ ���� ������!');
    END IF;
    -- ���� ��������
    IF par_open_date IS NULL
    THEN
      raise_application_error(-20001
                             ,'���� �������� ������ ���� �������!');
    END IF;
    -- �����
    IF par_address_id IS NULL
    THEN
      raise_application_error(-20001, '����� ������ ���� ������!');
    END IF;
    -- ��������
    IF par_company_id IS NULL
    THEN
      raise_application_error(-20001, '�������� ������ ���� �������!');
    END IF;
    -- ������
    IF par_branch_id IS NULL
    THEN
      raise_application_error(-20001, '������ ������ ���� ������!');
    END IF;
    -- ���
    IF par_kpp IS NULL
    THEN
      raise_application_error(-20001, '��� ������ ���� ������!');
    END IF;
    -- ���
    IF par_t_roo_header_id IS NULL
    THEN
      raise_application_error(-20001, '��� ������ ���� �������!');
    END IF;
    -- ���
    IF par_t_tap_header_id IS NULL
    THEN
      raise_application_error(-20001, '��� ������ ���� ������!');
    END IF;
    -- ���� ������ ������
    IF par_start_date IS NULL
    THEN
      raise_application_error(-20001
                             ,'���� ������ ������ ������ ���� �������!');
    END IF;
  
    -- *�������� �� ������������ ��������*
    -- ���
    IF length(par_kpp) < 9
    THEN
      raise_application_error(-20001
                             ,'���������� �������� ��� ������ ���� ������ 9');
    END IF;
    -- ������������� ���
    IF par_universal_code NOT BETWEEN 1 AND 9999
    THEN
      raise_application_error(-20001
                             ,'������������� ��� ������ ���� � ��������� �� 0001 �� 9999');
    END IF;
    -- ���� ��������
    IF par_open_date < to_date('01.01.2005', 'dd.mm.yyyy')
    THEN
      raise_application_error(-20001
                             ,'���� �������� ������������� �� ������ ���� ������ 01.01.2005');
    END IF;
    -- ���� �������� ��� ������ ���� 31.12.3000 (�.�. ��� �� ������ ���� �������)
    SELECT COUNT(1)
      INTO v_cnt
      FROM dual
     WHERE EXISTS (SELECT NULL
              FROM ven_t_roo        ro
                  ,ven_t_roo_header rh
             WHERE rh.t_roo_header_id = par_t_roo_header_id
               AND rh.last_roo_id = ro.t_roo_id
               AND ro.close_date = pkg_sales_depts.get_default_end_date);
    IF v_cnt = 1
    THEN
      raise_application_error(-20001, '������� �������� ���');
    END IF;
    -- ���� �������� ��� ������ ���� 31.12.3000 (�.�. ��� �� ������ ���� ������)
    SELECT COUNT(1)
      INTO v_cnt
      FROM dual
     WHERE EXISTS (SELECT NULL
              FROM ven_t_tap        tp
                  ,ven_t_tap_header th
             WHERE th.t_tap_header_id = par_t_tap_header_id
               AND th.last_tap_id = tp.t_tap_id
               AND tp.close_date = pkg_tap.get_default_end_date);
    IF v_cnt = 1
    THEN
      raise_application_error(-20001, '������ �������� ���');
    END IF;
  
    -- *�������� �� ������������ ��������*
  
    -- �������� ��������
    SELECT COUNT(1)
      INTO v_cnt
      FROM dual
     WHERE EXISTS (SELECT NULL
              FROM ven_sales_dept tt
             WHERE upper(tt.dept_name) = upper(par_dept_name)
               AND (par_sales_dept_header_id IS NULL OR
                    tt.sales_dept_header_id != par_sales_dept_header_id));
    IF v_cnt = 1
    THEN
      raise_application_error(-20001
                             ,'�� � ����� ��������� ��� ����������');
    END IF;
    -- �������� �������������� ����
    SELECT COUNT(1)
      INTO v_cnt
      FROM dual
     WHERE EXISTS (SELECT NULL
              FROM ven_sales_dept_header tt
             WHERE tt.universal_code = par_universal_code
               AND (par_sales_dept_header_id IS NULL OR
                   tt.sales_dept_header_id != par_sales_dept_header_id));
    IF v_cnt = 1
    THEN
      raise_application_error(-20001, '�� � ����� ����� ��� ����������');
    END IF;
    -- �������� ��. ��������
    IF par_legal_name IS NOT NULL
    THEN
      SELECT COUNT(1)
        INTO v_cnt
        FROM dual
       WHERE EXISTS (SELECT NULL
                FROM ven_sales_dept tt
               WHERE upper(tt.legal_name) = upper(par_legal_name)
                 AND (par_sales_dept_header_id IS NULL OR
                      tt.sales_dept_header_id != par_sales_dept_header_id));
      IF v_cnt = 1
      THEN
        raise_application_error(-20001
                               ,'�� � ����� ����������� ��������� ��� ����������');
      END IF;
    END IF;
    -- �������� �������������� ��������
    IF par_marketing_name IS NOT NULL
    THEN
      SELECT COUNT(1)
        INTO v_cnt
        FROM dual
       WHERE EXISTS (SELECT NULL
                FROM ven_sales_dept tt
               WHERE upper(tt.marketing_name) = upper(par_marketing_name)
                 AND (par_sales_dept_header_id IS NULL OR
                      tt.sales_dept_header_id != par_sales_dept_header_id));
      IF v_cnt = 1
      THEN
        raise_application_error(-20001
                               ,'�� � ����� ������������� ��������� ��� ����������');
      END IF;
    END IF;
  
  END check_sales_dept;

  /*
    ������ �.
    ��������� ���������� �������������� ���� � ������� 0009
  */
  FUNCTION get_next_universal_code RETURN VARCHAR2 IS
    v_ucode VARCHAR2(5);
  BEGIN
    SELECT to_char(nvl(MAX(sd.universal_code) + 1, 1), 'FM0009')
      INTO v_ucode
      FROM ven_sales_dept_header sd;
    RETURN v_ucode;
  END get_next_universal_code;

  /*
    ������ �.
    �������� ��������� � ��������� �����������
    ��� �������� ������ - �����������
  */
  PROCEDURE modify_org_tree(par_sales_dept_id NUMBER) IS
    vr_sales_dept     ven_sales_dept%ROWTYPE;
    vr_org_tree       ven_organisation_tree%ROWTYPE;
    vr_department     ven_department%ROWTYPE;
    vr_dept_executive ven_dept_executive%ROWTYPE;
  BEGIN
    SELECT * INTO vr_sales_dept FROM ven_sales_dept sd WHERE sd.sales_dept_id = par_sales_dept_id;
  
    SELECT sh.organisation_tree_id
      INTO vr_org_tree.organisation_tree_id
      FROM ven_sales_dept_header sh
     WHERE sh.sales_dept_header_id = vr_sales_dept.sales_dept_header_id;
  
    -- ���� ��� ID ���������, ����� ���� ���������� ������ � ������ ���������, �� ������������� � �������� ������
    IF vr_org_tree.organisation_tree_id IS NULL
    THEN
      BEGIN
        SELECT ot.organisation_tree_id
          INTO vr_org_tree.organisation_tree_id
          FROM ven_organisation_tree ot
         WHERE ot.name = vr_sales_dept.dept_name;
      
        UPDATE ven_sales_dept_header sh
           SET sh.organisation_tree_id = vr_org_tree.organisation_tree_id
         WHERE sales_dept_header_id = vr_sales_dept.sales_dept_header_id;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          NULL;
      END;
    END IF;
    -- ���� ID ���, ������� ������
    IF vr_org_tree.organisation_tree_id IS NULL
    THEN
      -- ������� ������������
      vr_org_tree.code := vr_sales_dept.short_name;
      -- ������������
      vr_org_tree.name := vr_sales_dept.dept_name;
      -- ��. ����
      vr_org_tree.company_id := vr_sales_dept.company_id;
      -- �������
      BEGIN
        SELECT /******�����*****************/
        /*ad.province_id*/
         substr(ad.code, 1, 2) || '00000000000' province_code
         /*,substr(pr.kladr_code,1,2)*/
        ,substr(ad.code, 1, 2)
          INTO vr_org_tree.province_code
              ,vr_org_tree.reg_code
          FROM ven_cn_entity_address ea
              ,cn_address            ad
        /*,t_province            pr*/
         WHERE ea.ure_id = gv_sales_dept_ent_id
           AND ea.uro_id = par_sales_dept_id
           AND ea.address_id = ad.id
        /******�����*****************/
        /*and ad.province_id = pr.province_id*/
        ;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          raise_application_error(-20001
                                 ,'� ������ �� ������ ������. �������� ������ � ��������� ����������� ����������.');
      END;
      -- ��������
      vr_org_tree.parent_id := vr_sales_dept.branch_id;
      -- ���
      SELECT th.agn_tac_id
        INTO vr_org_tree.tac_id
        FROM ven_t_tap_header th
       WHERE th.t_tap_header_id = vr_sales_dept.t_tap_header_id;
      -- ID
      SELECT sq_organisation_tree.nextval INTO vr_org_tree.organisation_tree_id FROM dual;
      -- ���������� ������
      INSERT INTO ven_organisation_tree VALUES vr_org_tree;
    
      -- �������������
      -- ID
      SELECT sq_department.nextval INTO vr_department.department_id FROM dual;
    
      vr_department.org_tree_id := vr_org_tree.organisation_tree_id;
      vr_department.code        := vr_sales_dept.short_name;
      vr_department.name        := vr_sales_dept.dept_name;
      vr_department.date_open   := vr_sales_dept.open_date;
      -- ���������� ������ �������������
      INSERT INTO ven_department VALUES vr_department;
    
      -- ������������� ����
      -- ID
      SELECT sq_dept_executive.nextval INTO vr_dept_executive.dept_executive_id FROM dual;
      -- �������
      SELECT ah.agent_id
        INTO vr_dept_executive.contact_id
        FROM ag_contract_header ah
       WHERE ah.ag_contract_header_id = vr_sales_dept.initiator_id;
    
      vr_dept_executive.department_id := vr_department.department_id;
      vr_dept_executive.is_default    := 1;
    
      INSERT INTO ven_dept_executive VALUES vr_dept_executive;
    
      -- ������ ID ��������� � ��������� ��
      UPDATE ven_sales_dept_header sh
         SET sh.organisation_tree_id = vr_org_tree.organisation_tree_id
       WHERE sh.sales_dept_header_id = vr_sales_dept.sales_dept_header_id;
    
      -- ���� ����, ��������� ����� �� ��
    ELSE
      -- ������� ������������
      vr_org_tree.code := vr_sales_dept.short_name;
      -- ������������
      vr_org_tree.name := vr_sales_dept.dept_name;
      -- ��. ����
      vr_org_tree.company_id := vr_sales_dept.company_id;
      -- �������
      BEGIN
        SELECT /******�����****************/
        /*ad.province_id*/
         substr(ad.code, 1, 2) || '00000000000' province_code
          INTO vr_org_tree.province_code
          FROM ven_cn_entity_address ea
              ,cn_address            ad
         WHERE ea.ure_id = gv_sales_dept_ent_id
           AND ea.uro_id = par_sales_dept_id
           AND ea.address_id = ad.id;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          NULL;
      END;
      -- ��������
      vr_org_tree.parent_id := vr_sales_dept.branch_id;
      -- ���
      SELECT th.agn_tac_id
        INTO vr_org_tree.tac_id
        FROM ven_t_tap_header th
       WHERE th.t_tap_header_id = vr_sales_dept.t_tap_header_id;
    
      -- ����������� ������
      UPDATE ven_organisation_tree ot
         SET ot.code          = vr_org_tree.code
            ,ot.name          = vr_org_tree.name
            ,ot.company_id    = vr_org_tree.company_id
            ,ot.province_code = vr_org_tree.province_code
            ,ot.parent_id     = vr_org_tree.parent_id
            ,ot.tac_id        = vr_org_tree.tac_id
       WHERE ot.organisation_tree_id = vr_org_tree.organisation_tree_id;
    
      -- �������������
      -- ID
      BEGIN
        SELECT dp.department_id
          INTO vr_department.department_id
          FROM ven_department dp
         WHERE dp.org_tree_id = vr_org_tree.organisation_tree_id
           AND rownum = 1;
      
        vr_department.code      := vr_sales_dept.short_name;
        vr_department.name      := vr_sales_dept.dept_name;
        vr_department.date_open := vr_sales_dept.open_date;
      
        IF vr_sales_dept.close_date != get_default_end_date
        THEN
          vr_department.date_close := vr_sales_dept.start_date;
        END IF;
        -- ����������� ������ �������������
        UPDATE ven_department dp
           SET dp.code       = vr_department.code
              ,dp.name       = vr_department.name
              ,dp.date_open  = vr_department.date_open
              ,dp.date_close = vr_department.date_close
         WHERE dp.department_id = vr_department.department_id;
      
        -- ������������� ����
        -- ID
        BEGIN
          SELECT de.dept_executive_id
            INTO vr_dept_executive.dept_executive_id
            FROM ven_dept_executive de
           WHERE de.department_id = vr_department.department_id
             AND de.is_default = 1;
          -- �������
          SELECT ah.agent_id
            INTO vr_dept_executive.contact_id
            FROM ag_contract_header ah
           WHERE ah.ag_contract_header_id = vr_sales_dept.initiator_id;
        
          UPDATE ven_dept_executive de
             SET de.contact_id = vr_dept_executive.contact_id
           WHERE de.dept_executive_id = vr_dept_executive.dept_executive_id;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            -- ������������� ����
            -- ID
            SELECT sq_dept_executive.nextval INTO vr_dept_executive.dept_executive_id FROM dual;
            -- �������
            SELECT ah.agent_id
              INTO vr_dept_executive.contact_id
              FROM ag_contract_header ah
             WHERE ah.ag_contract_header_id = vr_sales_dept.initiator_id;
          
            vr_dept_executive.department_id := vr_department.department_id;
            vr_dept_executive.is_default    := 1;
          
            INSERT INTO ven_dept_executive VALUES vr_dept_executive;
        END;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          vr_department.org_tree_id := vr_org_tree.organisation_tree_id;
          vr_department.code        := vr_sales_dept.short_name;
          vr_department.name        := vr_sales_dept.dept_name;
          vr_department.date_open   := vr_sales_dept.open_date;
          -- ���������� ������ �������������
          INSERT INTO ven_department VALUES vr_department;
          -- ������������� ����
          -- ID
          SELECT sq_dept_executive.nextval INTO vr_dept_executive.dept_executive_id FROM dual;
          -- �������
          SELECT ah.agent_id
            INTO vr_dept_executive.contact_id
            FROM ag_contract_header ah
           WHERE ah.ag_contract_header_id = vr_sales_dept.initiator_id;
        
          vr_dept_executive.department_id := vr_department.department_id;
          vr_dept_executive.is_default    := 1;
        
          INSERT INTO ven_dept_executive VALUES vr_dept_executive;
      END;
    END IF;
  END modify_org_tree;

  /*
    ������ �.
    ��������� ��������� ������ � ���������
  */
  PROCEDURE set_last_version
  (
    par_sales_dept_header_id NUMBER
   ,par_sales_dept_id        NUMBER
  ) IS
  BEGIN
    UPDATE ven_sales_dept_header th
       SET th.last_sales_dept_id = par_sales_dept_id
     WHERE th.sales_dept_header_id = par_sales_dept_header_id;
  END set_last_version;

  /*
    ������ �.
    ��������� ���������� ������ ������
  */
  FUNCTION get_new_ver_num(par_sales_dept_header_id NUMBER) RETURN NUMBER IS
    v_ver_num ven_sales_dept.ver_num%TYPE;
  BEGIN
    SELECT nvl(MAX(tt.ver_num), 0) + 1
      INTO v_ver_num
      FROM ven_sales_dept tt
     WHERE tt.sales_dept_header_id = par_sales_dept_header_id;
    RETURN v_ver_num;
  END get_new_ver_num;

  /*
    ������ �.
    �������� ���������
  */
  PROCEDURE create_header
  (
    par_universal_code       NUMBER
   ,par_sales_dept_header_id OUT NUMBER
  ) IS
  BEGIN
    SELECT sq_sales_dept_header.nextval INTO par_sales_dept_header_id FROM dual;
    INSERT INTO ven_sales_dept_header
      (sales_dept_header_id, universal_code)
    VALUES
      (par_sales_dept_header_id, par_universal_code);
  END create_header;
  /*
    ������ �.
    ������� �������� ������
  */
  PROCEDURE create_version_base
  (
    par_sales_dept_header_id NUMBER
   ,par_dept_name            VARCHAR2
   ,par_legal_name           VARCHAR2
   ,par_marketing_name       VARCHAR2
   ,par_short_name           VARCHAR2
   ,par_branch_id            NUMBER
   ,par_company_id           NUMBER
   ,par_initiator_id         NUMBER
   ,par_kpp                  VARCHAR2
   ,par_manager_id           NUMBER
   ,par_open_date            DATE
   ,par_start_date           DATE
   ,par_close_date           DATE
   ,par_t_navision_cc        NUMBER
   ,par_t_roo_header_id      NUMBER
   ,par_t_tap_header_id      NUMBER
   ,par_sys_user_id          NUMBER
   ,par_ver_num              NUMBER
   ,par_sales_dept_id        OUT NUMBER
  ) IS
    v_universal_code NUMBER;
  BEGIN
  
    SELECT sq_sales_dept.nextval INTO par_sales_dept_id FROM dual;
  
    SELECT dh.universal_code
      INTO v_universal_code
      FROM ven_sales_dept_header dh
     WHERE dh.sales_dept_header_id = par_sales_dept_header_id;
  
    INSERT INTO ven_sales_dept
      (sales_dept_id
      ,sales_dept_header_id
      ,open_date
      ,start_date
      ,close_date
      ,dept_name
      ,legal_name
      ,marketing_name
      ,short_name
      ,branch_id
      ,company_id
      ,initiator_id
      ,manager_id
      ,kpp
      ,t_navision_cc_id
      ,t_roo_header_id
      ,t_tap_header_id
      ,ver_num
      ,send_status
      ,sys_user_id)
    VALUES
      (par_sales_dept_id
      ,par_sales_dept_header_id
      ,par_open_date
      ,par_start_date
      ,par_close_date
      ,par_dept_name
      ,par_legal_name
      ,par_marketing_name
      ,par_short_name
      ,par_branch_id
      ,par_company_id
      ,par_initiator_id
      ,par_manager_id
      ,par_kpp
      ,par_t_navision_cc
      ,par_t_roo_header_id
      ,par_t_tap_header_id
      ,par_ver_num
      ,0
      ,par_sys_user_id);
  
    set_last_version(par_sales_dept_header_id, par_sales_dept_id);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      raise_application_error(-20001
                             ,'� ����������� �������� ���������� ����������� ������ � ������� ��������� "' ||
                              gc_sales_dept_brief || '"');
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
    �������� ����� ������
  */
  PROCEDURE create_new_version
  (
    par_sales_dept_header_id IN OUT NUMBER
   ,par_universal_code       NUMBER
   ,par_dept_name            VARCHAR2
   ,par_marketing_name       VARCHAR2
   ,par_legal_name           VARCHAR2
   ,par_short_name           VARCHAR2
   ,par_initiator_id         NUMBER
   ,par_manager_id           NUMBER
   ,par_open_date            DATE
   ,par_close_date           DATE
   ,par_company_id           NUMBER
   ,par_address_id           NUMBER
   ,par_branch_id            NUMBER
   ,par_kpp                  VARCHAR2
   ,par_t_navision_cc_id     NUMBER
   ,par_t_roo_header_id      NUMBER
   ,par_t_tap_header_id      NUMBER
   ,par_sales_dept_id        OUT NUMBER
  ) IS
    v_entity_address_id NUMBER;
    v_sys_user_id       sys_user.sys_user_id%TYPE;
    v_start_date        DATE := SYSDATE;
  BEGIN
    -- ��������� ������������
    BEGIN
      SELECT su.sys_user_id INTO v_sys_user_id FROM sys_user su WHERE su.sys_user_name = USER;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        raise_application_error(-20001
                               ,'������������ ' || USER || ' �� �������� ������������� �������');
    END;
  
    -- �������� ���������
    IF par_sales_dept_header_id IS NULL
    THEN
      create_header(par_universal_code, par_sales_dept_header_id);
    END IF;
  
    -- �������� ����� ������
    create_version_base(par_sales_dept_header_id => par_sales_dept_header_id
                       ,par_dept_name            => par_dept_name
                       ,par_legal_name           => par_legal_name
                       ,par_marketing_name       => par_marketing_name
                       ,par_short_name           => par_short_name
                       ,par_branch_id            => par_branch_id
                       ,par_company_id           => par_company_id
                       ,par_initiator_id         => par_initiator_id
                       ,par_kpp                  => par_kpp
                       ,par_manager_id           => par_manager_id
                       ,par_open_date            => par_open_date
                       ,par_start_date           => v_start_date
                       ,par_close_date           => nvl(par_close_date, gc_default_end_date)
                       ,par_t_navision_cc        => par_t_navision_cc_id
                       ,par_t_roo_header_id      => par_t_roo_header_id
                       ,par_t_tap_header_id      => par_t_tap_header_id
                       ,par_sys_user_id          => v_sys_user_id
                       ,par_ver_num              => get_new_ver_num(par_sales_dept_header_id)
                       ,par_sales_dept_id        => par_sales_dept_id);
  
    -- ����� � ���������
    pkg_entity_address.link_entity_to_address(par_ure_id            => gv_sales_dept_ent_id
                                             ,par_uro_id            => par_sales_dept_id
                                             ,par_address_id        => par_address_id
                                             ,par_entity_address_id => v_entity_address_id);
  
    -- ��������� ��� � ���� �������� ������� (��������� ������)
    UPDATE ven_sales_dept tt
       SET tt.kpp = par_kpp
     WHERE tt.sales_dept_id IN (SELECT sd.sales_dept_id
                                  FROM ven_sales_dept_header sh
                                      ,ven_sales_dept        sd
                                      ,ven_sales_dept_header bh
                                 WHERE sh.last_sales_dept_id = par_sales_dept_id
                                   AND sh.organisation_tree_id = sd.branch_id
                                   AND sd.sales_dept_id = bh.last_sales_dept_id);
    -- ��������� ������ � ��������� �����������
    modify_org_tree(par_sales_dept_id);
  END create_new_version;

  /*
    ������ �.
    �������� ������ � 1�
  */
  /*
    procedure send_to_1c
    (
      par_sales_dept_id number
    )
    is
      v_doc_type_brief ven_t_doc_type.brief%type;
      v_legal_name     ven_sales_dept.legal_name%type;
    begin
      select dt.brief
            ,sd.legal_name
        into v_doc_type_brief
            ,v_legal_name
        from ven_sales_dept sd
            ,ven_t_doc_type dt
       where sd.t_doc_type_id = dt.t_doc_type_id
         and sd.sales_dept_id = par_sales_dept_id;
  
      -- ���������� ������ ������ �� ������������ ��������������
      if v_legal_name is not null then
        -- ������ ��� ����� ���������� �� ���������� ��������� � 1� (�������� � 1�, �������� �� ������������)
        if v_doc_type_brief not in ('1C_CHECKING','1C_CHECK_FAILED') then
          delete from insi.selling_departments sd
                where sd.ver_id = par_sales_dept_id;
  
          insert into insi.selling_departments
            (line_id, gate_dbs_id, universal_code, legal_name, company_short_name, company_full_name, company_inn, company_kpp
            ,dept_kpp, parent_legal_name, parent_universal_code, close_date, ver_id, ver_num, cost_center_code, result_code)
          select line_id, db.column_value, mn.universal_code, mn.legal_name, mn.company_short_name, mn.company_full_name, mn.company_inn, mn.company_kpp
                ,mn.dept_kpp, mn.parent_legal_name, mn.parent_universal_code, mn.close_date, mn.ver_id, mn.ver_num, mn.cost_center_code, 0
            from table(insi.pkg_gate_new.get_db_for_table('SELLING_DEPARTMENTS')) db
                ,(select insi.pkg_gate_new.get_line_id as line_id
                        ,sh.universal_code
                        ,sd.legal_name
                        ,co.short_name                 as company_short_name
                        ,co.obj_name_orig              as company_full_name
                        ,(select ci.id_value
                            from cn_contact_ident ci
                                ,t_id_type        it
                          where ci.contact_id = co.contact_id
                            and ci.id_type    = it.id
                            and it.brief      = 'INN'
                         )                             as company_inn
                        ,(select ci.id_value
                            from cn_contact_ident ci
                                ,t_id_type        it
                          where ci.contact_id = co.contact_id
                            and ci.id_type    = it.id
                            and it.brief      = 'KPP'
                         )                             as company_kpp
                        ,sd.kpp                        as dept_kpp
                        ,sdp.legal_name                as parent_legal_name
                        ,shp.universal_code            as parent_universal_code
                        ,case dt.brief
                           when 'CLOSE_SALES_DEPT' then sd.start_date
                           else null
                         end                           as close_date
                        ,sd.sales_dept_id              as ver_id
                        ,sd.ver_num
                        ,cc.cc_code                    as cost_center_code
                    from ven_sales_dept        sd
                        ,ven_sales_dept_header sh
                        ,contact               co
                        ,ven_sales_dept_header shp
                        ,ven_sales_dept        sdp
                        ,ven_t_doc_type        dt
                        ,ven_t_navision_cc     cc
                   where sd.sales_dept_id        = par_sales_dept_id
                     and sd.sales_dept_header_id = sh.sales_dept_header_id
                     and sd.company_id           = co.contact_id
                     
                     and sd.branch_id             = shp.organisation_tree_id (+)
                     and shp.last_sales_dept_id   = sdp.sales_dept_id        (+)
                     
                     and sd.t_doc_type_id         = dt.t_doc_type_id
                     and sd.t_navision_cc_id      = cc.t_navision_cc_id      (+)
                 ) mn;
          if sql%rowcount = 0 then
            update ven_sales_dept sd
               set sd.send_status     = -1
                  ,sd.send_error_text = '������ �� ���� ����������. ������� �� ������� ������.'
             where sd.sales_dept_id = par_sales_dept_id;
          end if;
          -- ���� ������������ �� ��������
        elsif v_doc_type_brief = '1C_CHECKING' then
          -- �������� ������� �� �����
          delete from insi.selling_depts_employees de
                where de.ver_id = par_sales_dept_id;
          -- ���������� � ����
          insert into insi.selling_depts_employees
            (line_id, gate_dbs_id, universal_code, result_code, ver_id)
          select insi.pkg_gate_new.get_line_id
                ,se.column_value
                ,sh.universal_code
                ,0
                ,par_sales_dept_id
            from ven_sales_dept        sd
                ,ven_sales_dept_header sh
                ,table(insi.pkg_gate_new.get_db_for_table('SELLING_DEPTS_EMPLOYEES')) se
           where sd.sales_dept_id        = par_sales_dept_id
             and sd.sales_dept_header_id = sh.sales_dept_header_id;
        end if;
      end if;
    end send_to_1c;
  */
  /*
    ������ �.
    ��������� ���������� �������
  */
  /*
    procedure get_from_1c
    is
      v_result_code      insi.selling_departments.result_code%type;
      v_result_text      insi.selling_departments.result_text%type;
      v_cc_name          insi.selling_departments.cost_center_name%type;
      v_cc_close_date    insi.selling_departments.close_date%type;
      v_doc_type_failed  ven_t_doc_type.t_doc_type_id%type;
      v_doc_type_checked ven_t_doc_type.t_doc_type_id%type;
      \*
        ��������� ����������� ���������� �������
      *\
      procedure lp_process_result
      (
        par_sales_dept_id number
       ,par_cc_code       varchar2
      )
      is
        v_t_navision_cc_id number;
      begin
        -- ���� ��� ������ ������������� � �������� �� ��������, ������� �� �����
        if v_result_code = 1 and (par_cc_code is null or par_cc_code is not null and v_cc_name is not null)then
          delete from insi.selling_departments sd
                where sd.ver_id = par_sales_dept_id;
        end if;
        -- ��������� ���������������� �������
        update ven_sales_dept sd
           set sd.send_status     = v_result_code
              ,sd.send_error_text = v_result_text
         where sd.sales_dept_id = par_sales_dept_id;
        -- ���� �������� �������� ��, ������������� ��� 
        if v_cc_name is not null then
          select sd.t_navision_cc_id
            into v_t_navision_cc_id
            from ven_sales_dept sd
           where sd.sales_dept_id = par_sales_dept_id;
          pkg_navision_cc.set_name(v_t_navision_cc_id, v_cc_name);
        end if;
        -- ���� �������� ���� �������� ��, ������������� ��
        if v_cc_close_date is not null then
          select sd.t_navision_cc_id
            into v_t_navision_cc_id
            from ven_sales_dept sd
           where sd.sales_dept_id = par_sales_dept_id;
          pkg_navision_cc.set_close_date(v_t_navision_cc_id, v_cc_close_date);
        end if;
  
      end lp_process_result;
    begin
      -- ������, ��� �������� �������, ����� ���� ��������� ��������
      -- ��������� ������, �� ������� ��� ������� �����
      for vr_depts in (select distinct sd.ver_id, sd.cost_center_code
                         from insi.selling_departments sd
                        where sd.result_code != 0
                      )
      loop
        v_cc_name := null;
        v_cc_close_date := null;
        -- ��������� ��, ��� ������� ������������
        for vr_dbs in (select column_value  as db_id
                         from table(insi.pkg_gate_new.get_db_for_table('SELLING_DEPARTMENTS'))
                      )
        loop
          -- ��������� ���������� ��� ���������� ������, ���������� ��
          begin
            select sd.result_code
                  ,sd.result_text
                  ,nvl(sd.cost_center_name, v_cc_name) -- ���� �������� ���������� ������ �� ����� ��
                  ,nvl(sd.close_date, v_cc_close_date) -- ���� ���� �������� ���������� ������ �� ����� ��
              into v_result_code
                  ,v_result_text
                  ,v_cc_name
                  ,v_cc_close_date
              from insi.selling_departments sd
             where sd.ver_id       = vr_depts.ver_id
               and sd.gate_dbs_id  = vr_dbs.db_id
               and sd.result_code != 0;
            -- ���� ���� ������ ������� �� �����
            if v_result_code = -1 then
              exit;
            end if;
          exception
            when NO_DATA_FOUND then
              -- ���� ���� �� ������� �� ��������, ������� �� �����, ��������� ��� ���������� = 0
              v_result_code := 0;
              exit;
          end;
        end loop vr_dbs;
        -- ���� ���� �����-���� ���������, ������������ ���
        if v_result_code != 0 then
          lp_process_result(vr_depts.ver_id, vr_depts.cost_center_code);
        end if;
      end loop vr_depts;
      -- ������ �� ��������� �������� (��������� �������� � 1�)
      select dt.t_doc_type_id
        into v_doc_type_failed
        from ven_t_doc_type dt
       where dt.brief = '1C_CHECK_FAILED';
      select dt.t_doc_type_id
        into v_doc_type_checked
        from ven_t_doc_type dt
       where dt.brief = 'CLOSE_SALES_DEPT';
      -- ���� �� ������������ �������
      for vr_result in (select de.ver_id
                              ,de.result_code
                              ,count (*) as cnt
                              ,se.db_cnt
                        from insi.selling_depts_employees de
                            ,(select count(*) as db_cnt
                                from table(insi.pkg_gate_new.get_db_for_table('SELLING_DEPTS_EMPLOYEES'))
                             ) se
                        where de.result_code != 0
                        group by de.ver_id, de.result_code, se.db_cnt
                       )
      loop
        if vr_result.result_code = 1 and vr_result.cnt = vr_result.db_cnt then
          update ven_sales_dept sd
             set sd.t_doc_type_id = v_doc_type_checked
           where sd.sales_dept_id = vr_result.ver_id;
        elsif vr_result.result_code = -1 then
          -- ��������� ���� ��������� "�������� �� ������������"
          update ven_sales_dept sd
             set sd.t_doc_type_id = v_doc_type_failed
           where sd.sales_dept_id = vr_result.ver_id;
        end if;
      end loop vr_result;
    end get_from_1c;
  */

  /*
    ������ �.
    ��������� ���� ��������� "�������� � 1�"
  */
  /*
    procedure set_version_to_1c_checking
    (
      par_sales_dept_id number
    )
    is
      v_cnt number;
    begin
      select count(1)
        into v_cnt
        from dual
       where exists (select null
                       from ven_sales_dept sd
                           ,ven_t_doc_type dt
                      where sd.sales_dept_id = par_sales_dept_id
                        and sd.t_doc_type_id = dt.t_doc_type_id
                        and (dt.brief = 'CLOSE_SALES_DEPT' or sd.ver_num = 1)
                    );
  
      -- ���� ������ "��������" ��� ��� ������ ������, ������ �� �� "��������"
      if v_cnt = 1 then
        update ven_sales_dept sd
           set sd.t_doc_type_id = (select dt.t_doc_type_id
                                     from ven_t_doc_type dt
                                    where dt.brief = '1C_CHECKING')
         where sd.sales_dept_id = par_sales_dept_id;
      end if;
    end set_version_to_1c_checking;
  */
  /*
    ������ �.
    ��������� ID ������� ������ ��� ������������, ����������� �� ������ ������ ����������
    
    SAS:
         SAS
         SAS 2 
         ��� ������, �����-���������
         ��� �������
        GRS-TSOK
    SAS 2:
         SAS
         SAS 2 
         ��� ������, �����-���������
         ��� �������
    DSF:
         DSF
    ��� ������, �����-���������:
        SAS
        SAS 2 
        ��� ������, �����-���������
        ��� �������
        GRS-TSOK
    ��� �������:
        SAS
        SAS 2 
        ��� ������, �����-���������
        ��� �������
        GRS-TSOK
  */
  FUNCTION get_manager_sales_channel(par_initiator_channel_id NUMBER) RETURN t_number_type IS
    v_channel_brief t_sales_channel.brief%TYPE;
    vt_channels     t_number_type;
  BEGIN
    SELECT sc.brief
      INTO v_channel_brief
      FROM t_sales_channel sc
     WHERE sc.id = par_initiator_channel_id;
  
    SELECT sc.id BULK COLLECT
      INTO vt_channels
      FROM t_sales_channel sc
     WHERE (v_channel_brief = 'SAS 2' AND sc.brief IN ('SAS 2', 'SAS', 'GRSMoscow', 'GRSRegion'))
        OR (v_channel_brief = 'MLM' AND sc.brief = 'MLM')
        OR (v_channel_brief IN ('GRSMoscow', 'GRSRegion', 'SAS') AND
           sc.brief IN ('SAS 2', 'SAS', 'GRSMoscow', 'GRSRegion', 'GRS-TSOK'));
  
    RETURN vt_channels;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN NULL;
  END get_manager_sales_channel;

  /*
    ������ �.
    �������� ���� ������� � B2B. ������������, ��������, ���� ��������� ���
  */
  PROCEDURE send_dept_agents_to_b2b(par_sales_dept_id NUMBER) IS
  BEGIN
    -- ���� �� ���������� �� ����� ������������� �� �������� �����������
    -- ��������, ������ ���� ������ ���������
    FOR vr_ag IN (SELECT ch.ag_contract_header_id
                    FROM sales_dept_header  sh
                        ,department         dp
                        ,ag_contract        cn
                        ,ag_contract_header ch
                        ,document           dc
                        ,doc_status_ref     dsr
                   WHERE sh.last_sales_dept_id = par_sales_dept_id
                     AND sh.organisation_tree_id = dp.org_tree_id
                     AND dp.department_id = cn.agency_id
                     AND cn.ag_contract_id = ch.last_ver_id
                     AND ch.ag_contract_header_id = dc.document_id
                     AND dc.doc_status_ref_id = dsr.doc_status_ref_id
                     AND dsr.brief = 'CURRENT'
                     AND ch.is_new = 1)
    LOOP
      pkg_agn_control.import_ad(p_ag_contract_header_id => vr_ag.ag_contract_header_id);
    END LOOP;
  END send_dept_agents_to_b2b;

  /*
    ������ �.
    ������� � ���������� ID ������������� �� � ��������� �����������
  */
  FUNCTION get_existing_tree_id
  (
    par_sales_dept_header_id NUMBER
   ,par_new_dept_name        VARCHAR2
  ) RETURN NUMBER IS
    v_existing_ot_id NUMBER;
  BEGIN
    BEGIN
      SELECT dp.org_tree_id
        INTO v_existing_ot_id
        FROM department dp
       WHERE dp.org_tree_id NOT IN
             (SELECT sh.organisation_tree_id
                FROM ven_sales_dept_header sh
               WHERE sh.sales_dept_header_id = par_sales_dept_header_id)
         AND dp.name = par_new_dept_name;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        v_existing_ot_id := NULL;
    END;
    RETURN v_existing_ot_id;
  END get_existing_tree_id;

  /*
    ������ �.
    ������������ �� �� ������ ������ � ��������� �����������
  */
  PROCEDURE merge_with_existing
  (
    par_sales_dept_header_id NUMBER
   ,par_existing_org_tree_id NUMBER
  ) IS
    v_cur_org_tree_id   NUMBER;
    v_cur_department_id NUMBER;
  BEGIN
    SELECT sh.organisation_tree_id
          ,dp.department_id
      INTO v_cur_org_tree_id
          ,v_cur_department_id
      FROM ven_sales_dept_header sh
          ,department            dp
     WHERE sh.sales_dept_header_id = par_sales_dept_header_id
       AND sh.organisation_tree_id = dp.org_tree_id;
  
    UPDATE ins.sales_dept_header h
       SET h.organisation_tree_id = par_existing_org_tree_id
     WHERE h.sales_dept_header_id = par_sales_dept_header_id;
  
    DELETE FROM ins.dept_executive e WHERE e.department_id = v_cur_department_id;
  
    DELETE FROM ins.department dep WHERE dep.department_id = v_cur_department_id;
  
    DELETE FROM ins.organisation_tree tr WHERE tr.organisation_tree_id = v_cur_org_tree_id;
  
  END merge_with_existing;

BEGIN
  SELECT en.ent_id INTO gv_sales_dept_ent_id FROM entity en WHERE en.brief = gc_sales_dept_brief;
END PKG_SALES_DEPTS;
/

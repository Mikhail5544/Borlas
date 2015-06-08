CREATE OR REPLACE PACKAGE pkg_crm IS

  -- Author  : ALEKSEY.PIYADIN
  -- Created : 09.12.2013
  -- Purpose : 246949 CRM ��� ������������� ������ � ����������� �������� ���������

  /*
    ��� ������ ��� ����. ������-���� ���������
  */
  TYPE t_request_applicant IS TABLE OF tmp_crm_request_purpose%ROWTYPE;

  /*
    ������� ��������� �� ���� ��������� �� �����
  */
  FUNCTION get_req_theme_id_by_brief(par_brief t_crm_request_theme.brief%TYPE)
    RETURN t_crm_request_theme.t_crm_request_theme_id%TYPE;

  /*
    ������� ��������� �� ������������� �� ����
  */
  FUNCTION get_department_id_by_code(par_departmant_code department.department_code%TYPE)
    RETURN department.department_id%TYPE;

  /*
    ������� ��������� �� ���� ������� �� �����
  */
  FUNCTION get_client_type_id_by_brief(par_brief t_crm_client_type.brief%TYPE)
    RETURN t_crm_client_type.t_crm_client_type_id%TYPE;

  /*
    ������� ��������� �� ������������ ��������� �� �����
  */
  FUNCTION get_setting_param_by_brief(par_brief t_crm_settings.brief%TYPE)
    RETURN t_crm_settings.number_param%TYPE;

  /*
    ��������� �������� ������ ��������� ��������� - �� ��� / ������ ���������
  */
  PROCEDURE search_basic(par_string VARCHAR2);

  /*
    ��������� ���������� ����� ����������� ��������� ��� �������� �� �� � �������� ���������
  */
  PROCEDURE frm_request_register_fill(par_contact_id contact.contact_id%TYPE, par_policy_header_id p_pol_header.policy_header_id%TYPE DEFAULT NULL);

  /*
    ��������� ��������������� ������ ��������� ��������� -
    �� ���� ��������, �� ����� �������� ��, �������� ��������, ����� / ������ �����.����������
  */
  PROCEDURE search_additional(par_string VARCHAR2);

  /*
    ������� �������� ��������� ������ �� ������������
  */
  FUNCTION search_string_check(par_string VARCHAR2) RETURN BOOLEAN;

  /*
    ��������� �������� ������-����������� � ������������� ����������� ���������
  */
  PROCEDURE send_email(par_inoutput_info_id inoutput_info.inoutput_info_id%TYPE);

  /*
    ��������� �������� ����� ��� �����
  */
  PROCEDURE send_email_job(par_date_feedback inoutput_info.date_feedback%TYPE);

  /*
    ��������� ������ ������ ��������� �� "�������� ������ ��� ������"
  */
  PROCEDURE set_unanswer_status(par_inoutput_info_id inoutput_info.inoutput_info_id%TYPE);

  /*
    ��������� ������� ���������� ������
  */
  PROCEDURE clear_search_results;

END pkg_crm;
/
CREATE OR REPLACE PACKAGE BODY pkg_crm IS

  /*
    ������� ��������� �� ���� ��������� �� �����
  */
  FUNCTION get_req_theme_id_by_brief(par_brief t_crm_request_theme.brief%TYPE)
    RETURN t_crm_request_theme.t_crm_request_theme_id%TYPE IS

    v_t_crm_request_theme_id t_crm_request_theme.t_crm_request_theme_id%TYPE;
  BEGIN
    SELECT rt.t_crm_request_theme_id
      INTO v_t_crm_request_theme_id
      FROM t_crm_request_theme rt
     WHERE rt.brief = par_brief;

    RETURN v_t_crm_request_theme_id;
  EXCEPTION
    WHEN no_data_found THEN
      raise_application_error(-20001
                             ,'�� ������� ���������� �� ���� ��������� �� �����');
  END get_req_theme_id_by_brief;

  /*
    ������� ��������� �� ������������� �� ����
  */
  FUNCTION get_department_id_by_code(par_departmant_code department.department_code%TYPE)
    RETURN department.department_id%TYPE IS

    v_department_id department.department_id%TYPE;
  BEGIN
    SELECT d.department_id
      INTO v_department_id
      FROM department d
     WHERE d.department_code = par_departmant_code;

    RETURN v_department_id;
  EXCEPTION
    WHEN no_data_found THEN
      raise_application_error(-20001
                             ,'�� ������� ���������� �� ������������� �� �������������� ����');
  END get_department_id_by_code;


  /*
    ������� ��������� �� ���� ������� �� �����
  */
  FUNCTION get_client_type_id_by_brief(par_brief t_crm_client_type.brief%TYPE)
    RETURN t_crm_client_type.t_crm_client_type_id%TYPE IS

    v_t_crm_client_type_id t_crm_client_type.t_crm_client_type_id%TYPE;
  BEGIN
    SELECT cct.t_crm_client_type_id
      INTO v_t_crm_client_type_id
      FROM t_crm_client_type cct
     WHERE cct.brief = par_brief;

    RETURN v_t_crm_client_type_id;
  EXCEPTION
    WHEN no_data_found THEN
      raise_application_error(-20001
                             ,'�� ������� ���������� �� ���� ������� �� �����');
  END get_client_type_id_by_brief;


  /*
    ������� ��������� �� ������������ ��������� �� �����
  */
  FUNCTION get_setting_param_by_brief(par_brief t_crm_settings.brief%TYPE)
    RETURN t_crm_settings.number_param%TYPE IS

    v_number_param t_crm_settings.number_param%TYPE;
  BEGIN
    SELECT cs.number_param
      INTO v_number_param
      FROM t_crm_settings cs
     WHERE cs.brief = par_brief;

    RETURN v_number_param;
  EXCEPTION
    WHEN no_data_found THEN
      raise_application_error(-20001
                             ,'�� ������� ���������� �� ������������ ��������� �� �����');
  END get_setting_param_by_brief;

  /*
    ��������� �������� ������ ��������� ��������� - �� ��� / ������ ���������
  */
  PROCEDURE search_basic(par_string VARCHAR2) IS
    v_t_contact_id_tbl  t_number_type := NULL;
    v_t_policy_id_tbl   t_number_type := NULL;
    v_t_document_id_tbl t_number_type := NULL;

    v_contact_fio       contact.obj_name_orig%TYPE := NULL;
    v_doc_number        document.num%TYPE := NULL;

    --------------------------------------------------------------
    -- ���������� ��� ������������ ������������� SQL
    --------------------------------------------------------------
    -- �������
    v_sql_contact VARCHAR2(2000) :=
     'INSERT /*+APPEND */ INTO TMP_CRM_REQUEST_PURPOSE
      SELECT NULL, NULL, NULL, c.contact_id, c.obj_name_orig, ''�������'', cp.date_of_birth, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, ci.id_value, ci.serial_nr, NULL, c.profile_login
      FROM contact c, cn_person cp, cn_contact_ident ci
      WHERE c.contact_id = cp.contact_id
        AND c.contact_id = ci.contact_id(+)
        AND c.contact_type_id IN (SELECT id FROM t_contact_type WHERE IS_INDIVIDUAL = 1)';
    -- �� ������������
    v_sql_policy VARCHAR2(2100) :=
     'INSERT /*+APPEND */ INTO TMP_CRM_REQUEST_PURPOSE
      SELECT ph.ids, CASE pr.is_group WHEN 1 THEN ''���'' ELSE ''���'' END, p.pol_num
      ,c.contact_id, c.obj_name_orig, pol.cont_role, cp.date_of_birth, ph.start_date, p.end_date
      ,(SELECT dsr.name
        FROM document pd, doc_status_ref dsr
        WHERE dsr.doc_status_ref_id = pd.doc_status_ref_id
          AND pd.document_id = p.policy_id)
      ,(SELECT f.brief
        FROM fund f
        WHERE f.fund_id = ph.fund_id)
      ,(SELECT cm.description
        FROM t_collection_method  cm
        WHERE cm.id = p.collection_method_id)
      ,(SELECT pt.description
        FROM t_payment_terms      pt
        WHERE pt.id = p.payment_term_id)
      ,(SELECT SUM(pc.fee)
        FROM as_asset ass, p_cover pc
        WHERE ass.as_asset_id = pc.as_asset_id
          AND ass.p_policy_id = p.policy_id)
      , pr.description, ci.id_value, ci.serial_nr, p.policy_id, c.profile_login
      FROM p_pol_header ph,
      t_product pr,
      p_policy p,
      (SELECT pi.policy_id, pi.contact_id, cpr.brief cont_role
       FROM p_policy_contact pi, t_contact_pol_role cpr 
       WHERE pi.contact_policy_role_id = cpr.id AND cpr.brief = ''������������'' <#POL_INSURED> UNION ALL
       SELECT ass.p_policy_id, asu.assured_contact_id contact_id, ''��������������'' cont_role
       FROM as_asset ass, as_assured asu WHERE ass.as_asset_id = asu.as_assured_id(+) <#POL_ASSURED> UNION ALL
       SELECT ass.p_policy_id, ab.contact_id, ''�������������������'' cont_role
       FROM as_asset ass, as_beneficiary ab WHERE ass.as_asset_id = ab.as_asset_id <#POL_BENEFIC>) pol,
      contact c,
      cn_person cp,
      cn_contact_ident ci
      WHERE ph.policy_header_id = p.pol_header_id
        AND ph.product_id = pr.product_id
        AND ph.max_uncancelled_policy_id = p.policy_id
        AND p.policy_id = pol.policy_id
        AND pol.contact_id = c.contact_id
        AND c.contact_id = cp.contact_id
        AND c.contact_id = ci.contact_id(+)
        AND c.contact_type_id IN (SELECT id FROM t_contact_type WHERE IS_INDIVIDUAL = 1)';
    -- ��
    v_sql_agent VARCHAR2(2000) :=
     'INSERT /*+APPEND */ INTO TMP_CRM_REQUEST_PURPOSE
      SELECT NULL, ''��'', d.num, c.contact_id, c.obj_name_orig, ''�����'', cp.date_of_birth, NULL, NULL, dsr.name, NULL, NULL, NULL, NULL, NULL, ci.id_value, ci.serial_nr, ach.ag_contract_header_id, c.profile_login
      FROM ag_contract_header ach, document d, doc_status_ref dsr, contact c, cn_person cp, cn_contact_ident ci
      WHERE d.document_id = ach.ag_contract_header_id
        AND d.doc_status_ref_id = dsr.doc_status_ref_id
        AND ach.agent_id = c.contact_id
        AND c.contact_id = cp.contact_id
        AND c.contact_id = ci.contact_id(+)
        AND ach.is_new   = 1 -- ������ ����� ������
        AND dsr.name     = ''�����������''
        AND c.contact_type_id IN (SELECT id FROM t_contact_type WHERE IS_INDIVIDUAL = 1)';
    -- ����
    v_sql_claim VARCHAR2(2000) :=
     'INSERT /*+APPEND */ INTO TMP_CRM_REQUEST_PURPOSE
      SELECT NULL, ''����'', d.num, c.contact_id, c.obj_name_orig, ''���������'', cp.date_of_birth, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, ci.id_value, ci.serial_nr, NULL, c.profile_login
      FROM c_claim_header ch, document d, c_declarants de, c_event_contact ec, contact c, cn_person cp, cn_contact_ident ci
      WHERE ch.c_claim_header_id = d.document_id
        AND ch.c_claim_header_id = de.c_claim_header_id
        AND de.declarant_id = ec.c_event_contact_id
        AND ec.cn_person_id = c.contact_id
        AND c.contact_id = cp.contact_id
        AND c.contact_id = ci.contact_id(+)
        AND c.contact_type_id IN (SELECT id FROM t_contact_type WHERE IS_INDIVIDUAL = 1)';
    -- ����
    v_sql_payment VARCHAR2(2000) :=
     'INSERT /*+APPEND */ INTO TMP_CRM_REQUEST_PURPOSE
      SELECT NULL, ''��'', d.num, c.contact_id, c.obj_name_orig, ''����������'', cp.date_of_birth, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, ci.id_value, ci.serial_nr, NULL, c.profile_login
      FROM payment_register_item pri, doc_set_off dso, ac_payment ap, document d, contact c, cn_person cp, cn_contact_ident ci
      WHERE 1 = 1
        AND pri.payment_register_item_id = dso.pay_registry_item
        AND dso.child_doc_id = d.document_id
        AND dso.parent_doc_id = ap.payment_id
        AND ap.contact_id  = c.contact_id
        AND c.contact_id   = cp.contact_id
        AND c.contact_id   = ci.contact_id(+)
        AND c.contact_type_id IN (SELECT id FROM t_contact_type WHERE IS_INDIVIDUAL = 1)';
    -- �������� ���
    v_sql_par_fio VARCHAR2(50) := ' AND c.contact_id IN (SELECT * FROM TABLE(:c)) ';
    -- �������� ����� ��������� document.num
    v_sql_par_doc_number VARCHAR2(50) := ' AND d.document_id IN (SELECT * FROM TABLE(:dd)) ';
    -- �������� ����� ��������� p_pol_header.ids
    v_sql_par_ids_number VARCHAR2(50) := ' AND p.policy_id IN (SELECT * FROM TABLE(:dph)) ';

    /**/
    TYPE t_search_en IS RECORD(
      Contact NUMBER,
      Policy NUMBER,
      Agent_contract NUMBER,
      Claim NUMBER,
      Payment NUMBER
    );
    v_search_en t_search_en;

  BEGIN
    SELECT TRIM(
             SUBSTR(par_string
                   ,1
                   ,DECODE(REGEXP_INSTR(par_string, '[0-9]'), 0, LENGTH(par_string), REGEXP_INSTR(par_string, '[0-9]') - 1)
             ) -- ������ ���������� ���������
           ) -- ������� ������� ����� � ������
      INTO v_contact_fio
      FROM DUAL;

    SELECT TRIM(
             REGEXP_SUBSTR(par_string, '\d+/\d+|\d+') -- ������ ������������������ ����
           ) -- ������� ������� ����� � ������
      INTO v_doc_number
      FROM DUAL;

    -- ������� ������ ������
    DELETE FROM TMP_CRM_REQUEST_PURPOSE;

    -- ����������� �������� ������
    SELECT MIN(Contact)
          ,MIN(Policy)
          ,MIN(Agent_contract)
          ,MIN(Claim)
          ,MIN(Payment)
      INTO v_search_en.Contact
          ,v_search_en.Policy
          ,v_search_en.Agent_contract
          ,v_search_en.Claim
          ,v_search_en.Payment
      FROM (SELECT CASE WHEN brief = 'Search.Contact' THEN NUMBER_PARAM END Contact
                  ,CASE WHEN brief = 'Search.Policy' THEN NUMBER_PARAM END Policy
                  ,CASE WHEN brief = 'Search.Agent_contract' THEN NUMBER_PARAM END Agent_contract
                  ,CASE WHEN brief = 'Search.Claim' THEN NUMBER_PARAM END Claim
                  ,CASE WHEN brief = 'Search.Payment' THEN NUMBER_PARAM END Payment
            FROM t_crm_settings);

    -- ������������ ������ contact_id �� ���
    IF v_contact_fio IS NOT NULL THEN
      BEGIN
        SELECT c.contact_id
          BULK COLLECT INTO v_t_contact_id_tbl
          FROM contact c
        WHERE c.obj_name like upper('%' || v_contact_fio || '%');
      EXCEPTION
        WHEN no_data_found THEN
          NULL;
      END;
    END IF;

    -- ������������ ������ document_id �� ������
    IF v_doc_number IS NOT NULL THEN
      BEGIN
        SELECT max_uncancelled_policy_id
          BULK COLLECT INTO v_t_policy_id_tbl
          FROM (SELECT ph.max_uncancelled_policy_id
                FROM p_pol_header   ph
                WHERE ph.ids like v_doc_number || '%'
                UNION ALL
                SELECT ph.max_uncancelled_policy_id
                FROM p_pol_header   ph
                    ,p_policy       p
                WHERE 1 = 1
                  AND ph.max_uncancelled_policy_id = p.policy_id
                  AND p.pol_num like v_doc_number || '%'
               );
      EXCEPTION
        WHEN no_data_found THEN
          NULL;
      END;

      BEGIN
        SELECT d.document_id
          BULK COLLECT INTO v_t_document_id_tbl
          FROM document  d
              ,doc_templ dt
        WHERE 1 = 1
          AND d.doc_templ_id = dt.doc_templ_id
          AND dt.brief IN ('AG_CONTRACT_HEADER'       -- ��������� �������
                          ,'AG_CONTRACT_HEADER_TEMP'  -- ������ ���������� ��������
                          ,'AGN_CONTRACT_HEADER'      -- ��������� ������� �����
                          ,'���������'                -- ��������� �� ���������� ������
                          ,'��'                       -- ��������� ��������� ��������
                          ,'��_��'                    -- ��������� ��������� �������� (������ ��������)
                          ,'��_��'                    -- ��������� ��������� �������� (����������� ������������)
                          )
          AND d.num = v_doc_number;
         -- ����������� �������� ����� �� ������ ���������, ������ ��� �������� ����� �����
         -- AND d.num like '%' || v_doc_number || '%';
      EXCEPTION
        WHEN no_data_found THEN
          NULL;
      END;
    END IF;

    IF v_contact_fio IS NOT NULL AND v_doc_number IS NOT NULL THEN

      IF v_search_en.Policy = 1 THEN
        EXECUTE IMMEDIATE REPLACE(REPLACE(REPLACE(v_sql_policy
                                                 ,'<#POL_INSURED>'
                                                 ,'AND pi.contact_id IN (SELECT * FROM TABLE(:c_ins))')
                                         ,'<#POL_ASSURED>'
                                         ,'AND ass.contact_id IN (SELECT * FROM TABLE(:c_ass)) UNION ALL
                                           SELECT ass.p_policy_id, asu.assured_contact_id contact_id, ''��������������'' cont_role
                                           FROM as_asset ass, as_assured asu WHERE ass.as_asset_id = asu.as_assured_id(+) AND asu.assured_contact_id IN (SELECT * FROM TABLE(:c_ass))')
                                 ,'<#POL_BENEFIC>'
                                 ,'AND ab.contact_id IN (SELECT * FROM TABLE(:c_ben))')
         || v_sql_par_fio || v_sql_par_ids_number USING v_t_contact_id_tbl, v_t_contact_id_tbl, v_t_contact_id_tbl, v_t_contact_id_tbl, v_t_contact_id_tbl, v_t_policy_id_tbl;
        COMMIT;
      END IF; -- ��
      IF v_search_en.Agent_contract = 1 THEN
        EXECUTE IMMEDIATE v_sql_agent || v_sql_par_fio || v_sql_par_doc_number USING v_t_contact_id_tbl, v_t_document_id_tbl;
        COMMIT;
      END IF; -- ��
      IF v_search_en.Claim = 1 THEN
        EXECUTE IMMEDIATE v_sql_claim || v_sql_par_fio || v_sql_par_doc_number USING v_t_contact_id_tbl, v_t_document_id_tbl;
        COMMIT;
      END IF; -- ����
      IF v_search_en.Payment = 1 THEN
        EXECUTE IMMEDIATE v_sql_payment || v_sql_par_fio || v_sql_par_doc_number USING v_t_contact_id_tbl, v_t_document_id_tbl;
        COMMIT;
      END IF; -- ����

    ELSE
      IF v_contact_fio IS NOT NULL THEN

        IF v_search_en.Contact = 1 THEN
          EXECUTE IMMEDIATE v_sql_contact || v_sql_par_fio USING v_t_contact_id_tbl;
          COMMIT;
        END IF; -- �������
        IF v_search_en.Policy = 1 THEN
          EXECUTE IMMEDIATE REPLACE(REPLACE(REPLACE(v_sql_policy
                                                   ,'<#POL_INSURED>'
                                                   ,'AND pi.contact_id IN (SELECT * FROM TABLE(:c_ins))')
                                           ,'<#POL_ASSURED>'
                                           ,'AND ass.contact_id IN (SELECT * FROM TABLE(:c_ass)) UNION ALL
                                             SELECT ass.p_policy_id, asu.assured_contact_id contact_id, ''��������������'' cont_role
                                             FROM as_asset ass, as_assured asu WHERE ass.as_asset_id = asu.as_assured_id(+) AND asu.assured_contact_id IN (SELECT * FROM TABLE(:c_ass))')
                                   ,'<#POL_BENEFIC>'
                                   ,'AND ab.contact_id IN (SELECT * FROM TABLE(:c_ben))')
           || v_sql_par_fio USING v_t_contact_id_tbl, v_t_contact_id_tbl, v_t_contact_id_tbl, v_t_contact_id_tbl, v_t_contact_id_tbl;
          COMMIT;
        END IF; -- ��
        IF v_search_en.Agent_contract = 1 THEN
          EXECUTE IMMEDIATE v_sql_agent || v_sql_par_fio USING v_t_contact_id_tbl;
          COMMIT;
        END IF; -- ��
        IF v_search_en.Claim = 1 THEN
          EXECUTE IMMEDIATE v_sql_claim || v_sql_par_fio USING v_t_contact_id_tbl;
          COMMIT;
        END IF; -- ����
        IF v_search_en.Payment = 1 THEN
          EXECUTE IMMEDIATE v_sql_payment || v_sql_par_fio USING v_t_contact_id_tbl;
          COMMIT;
        END IF; -- ����
      END IF;

      IF v_doc_number IS NOT NULL THEN

        IF v_search_en.Policy = 1 THEN
          EXECUTE IMMEDIATE REPLACE(REPLACE(REPLACE(v_sql_policy
                                                   ,'<#POL_INSURED>'
                                                   ,'AND pi.policy_id IN (SELECT * FROM TABLE(:p_ins))')
                                           ,'<#POL_ASSURED>'
                                           ,'AND ass.p_policy_id IN (SELECT * FROM TABLE(:p_ass))')
                                   ,'<#POL_BENEFIC>'
                                   ,'AND ass.p_policy_id IN (SELECT * FROM TABLE(:p_ben))')
            || v_sql_par_ids_number USING v_t_policy_id_tbl, v_t_policy_id_tbl, v_t_policy_id_tbl, v_t_policy_id_tbl;
          COMMIT;
        END IF; -- ��
        IF v_search_en.Agent_contract = 1 THEN
          EXECUTE IMMEDIATE v_sql_agent || v_sql_par_doc_number USING v_t_document_id_tbl;
          COMMIT;
        END IF; -- ��
        IF v_search_en.Claim = 1 THEN
          EXECUTE IMMEDIATE v_sql_claim || v_sql_par_doc_number USING v_t_document_id_tbl;
          COMMIT;
        END IF; -- ����
        IF v_search_en.Payment = 1 THEN
          EXECUTE IMMEDIATE v_sql_payment || v_sql_par_doc_number USING v_t_document_id_tbl;
          COMMIT;
        END IF; -- ����

      END IF;
    END IF;

    -- ������� ������ ������
    DELETE FROM TMP_CRM_REQUEST_PURPOSE_FLT;
    -- ���������� ����������� �������� ������ � ��������� �������� �������
    -- ��� ����������� �������������� ������ ����� ���������� ���.�������
    INSERT INTO TMP_CRM_REQUEST_PURPOSE_FLT SELECT * FROM TMP_CRM_REQUEST_PURPOSE;
    COMMIT;

  END search_basic;

  /*
    ��������� ��������������� ������ ��������� ��������� -
    �� ���� ��������, �� ����� �������� ��, �������� ��������, ����� / ������ �����.����������
  */
  PROCEDURE search_additional(par_string VARCHAR2) IS
    v_str        VARCHAR2(4000);
    v_1st_dt_str DATE := NULL;
    v_2nd_dt_str DATE := NULL;
    v_prod_desc  VARCHAR2(4000) := NULL;
    v_identity   VARCHAR2(4000) := NULL;
  BEGIN
    -- ������� ������ ������
    DELETE FROM TMP_CRM_REQUEST_PURPOSE;
    -- �������������� ����������� ��������
    INSERT INTO TMP_CRM_REQUEST_PURPOSE SELECT * FROM TMP_CRM_REQUEST_PURPOSE_FLT;

    v_str := par_string;

    IF v_str IS NOT NULL THEN
      BEGIN
        SELECT DECODE(REGEXP_INSTR(v_str, '\d{2}\.\d{2}\.\d{4}', 1, 1), 0, NULL,
                 TO_DATE(SUBSTR(v_str, REGEXP_INSTR(v_str, '\d{2}\.\d{2}\.\d{4}', 1, 1), 10) -- ������ ��������� ���� dd.mm.yyyy
                        ,'dd.mm.yyyy'))
          INTO v_1st_dt_str
          FROM DUAL;
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;

      BEGIN
        SELECT DECODE(REGEXP_INSTR(v_str, '\d{2}\.\d{2}\.\d{4}', 1, 2), 0, NULL,
                 TO_DATE(SUBSTR(v_str, REGEXP_INSTR(v_str, '\d{2}\.\d{2}\.\d{4}', 1, 2), 10) -- ������ ��������� ���� dd.mm.yyyy
                        ,'dd.mm.yyyy'))
          INTO v_2nd_dt_str
          FROM DUAL;
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;

      -- ������� ����
      SELECT TRIM(REGEXP_REPLACE(par_string, '(\d{2}\.\d{2}\.\d{4})', ''))
        INTO v_str
        FROM DUAL;

      SELECT TRIM(
               SUBSTR(par_string
                     ,1
                     ,DECODE(REGEXP_INSTR(v_str, '[0-9]'), 0, LENGTH(v_str), REGEXP_INSTR(v_str, '[0-9]') - 1)
               ) -- ������ ���������� ���������
             ) -- ������� ������� ����� � ������
        INTO v_prod_desc
        FROM DUAL;

      SELECT TRIM(
               REGEXP_SUBSTR(v_str, '\d+') -- ������ ������������������ ����
             ) -- ������� ������� ����� � ������
        INTO v_identity
        FROM DUAL;

      IF v_1st_dt_str IS NULL
        AND v_2nd_dt_str IS NULL
        AND v_prod_desc IS NULL
        AND v_identity IS NULL THEN
        DELETE FROM TMP_CRM_REQUEST_PURPOSE;
      ELSE
        IF v_1st_dt_str IS NOT NULL AND v_2nd_dt_str IS NOT NULL THEN
          DELETE FROM TMP_CRM_REQUEST_PURPOSE
          WHERE 1 = 1
            AND object_type <> '��'
            OR (object_type = '��'
               AND (policy_start_date < LEAST(v_1st_dt_str, v_2nd_dt_str)
                 OR policy_start_date > GREATEST(v_1st_dt_str, v_2nd_dt_str)
               ));
        ELSIF v_1st_dt_str IS NOT NULL THEN
          DELETE FROM TMP_CRM_REQUEST_PURPOSE
          WHERE contact_date_of_birth <> v_1st_dt_str;
        END IF;

        IF v_prod_desc IS NOT NULL THEN
          DELETE FROM TMP_CRM_REQUEST_PURPOSE WHERE product_name IS NULL;
          DELETE FROM TMP_CRM_REQUEST_PURPOSE
          WHERE lower(product_name) not like '%' || lower(v_prod_desc) || '%';
        END IF;

        IF v_identity IS NOT NULL THEN
          DELETE FROM TMP_CRM_REQUEST_PURPOSE
          WHERE lower(nvl(contact_serial_nr, '_')) not like '%' || lower(v_identity) || '%'
            AND lower(nvl(contact_id_value, '_'))  not like '%' || lower(v_identity) || '%';
        END IF;
      END IF;
    END IF;

    COMMIT;
  END search_additional;

  /*
    ������� �������� ��������� ������ �� ������������
  */
  FUNCTION search_string_check(par_string VARCHAR2) RETURN BOOLEAN IS
    v_str VARCHAR2(4000) := NULL;
  BEGIN
    SELECT TRIM(REGEXP_REPLACE(par_string, '[^0-9a-zA-Z�-��-�\.\ \-\%]', ''))
      INTO v_str
      FROM DUAL;

    IF NVL(LENGTH(v_str), 0) < 2 OR NVL(LENGTH(TRIM(REPLACE(v_str, '%', ''))), 0) = 0 THEN
      RETURN FALSE;
    ELSE
      RETURN TRUE;
    END IF;
  END;

  /*
    ��������� ���������� ����� ����������� ��������� ��� �������� �� �� � �������� ���������
  */
  PROCEDURE frm_request_register_fill(par_contact_id contact.contact_id%TYPE, par_policy_header_id p_pol_header.policy_header_id%TYPE DEFAULT NULL) IS
  BEGIN
    DELETE FROM TMP_CRM_REQUEST_PURPOSE;

    INSERT INTO TMP_CRM_REQUEST_PURPOSE
    SELECT ph.ids
          ,DECODE(par_policy_header_id, NULL, '�������', '��')
          ,p.pol_num
          ,c.contact_id
          ,c.obj_name_orig
          ,CASE cpr.brief
             WHEN '�������������� ����' THEN '��������������'
             ELSE cpr.description
           END
          ,cp.date_of_birth
          ,ph.start_date
          ,p.end_date
          ,(SELECT dsr.name
            FROM document pd, doc_status_ref dsr
            WHERE dsr.doc_status_ref_id = pd.doc_status_ref_id
              AND pd.document_id = p.policy_id)
          ,(SELECT f.brief
            FROM fund f
            WHERE f.fund_id = ph.fund_id)
          ,(SELECT cm.description
            FROM t_collection_method  cm
            WHERE cm.id = p.collection_method_id)
          ,(SELECT pt.description
            FROM t_payment_terms      pt
            WHERE pt.id = p.payment_term_id)
          ,(SELECT SUM(pc.fee)
            FROM as_asset ass, p_cover pc
            WHERE ass.as_asset_id = pc.as_asset_id
              AND ass.p_policy_id = p.policy_id)
          , pr.description
          ,ci.id_value
          ,ci.serial_nr
          ,p.policy_id
          ,c.profile_login
    FROM contact            c
        ,cn_person          cp
        ,cn_contact_ident   ci
        ,t_contact_pol_role cpr
        ,p_pol_header       ph
        ,p_policy           p
        ,t_product          pr
        ,p_policy_contact   ppc
    WHERE c.contact_id = cp.contact_id
      AND c.contact_id = ci.contact_id
      AND c.contact_type_id IN (SELECT id FROM t_contact_type WHERE IS_INDIVIDUAL = 1)
      AND c.contact_id = ppc.contact_id(+)
      AND ppc.contact_policy_role_id = cpr.id(+)
      AND cpr.brief IN ('�������������� ����', '������������', '�������������������')
      AND ppc.policy_id = p.policy_id(+)
      AND p.pol_header_id = ph.policy_header_id(+)
      AND ph.product_id = pr.product_id(+)
      AND ph.max_uncancelled_policy_id = p.policy_id
      AND ph.policy_header_id = NVL(par_policy_header_id, ph.policy_header_id)
      AND c.contact_id = par_contact_id;

    COMMIT;
  END frm_request_register_fill;

  /*
    ��������� �������� ������-����������� � ������������� ����������� ���������
  */
  PROCEDURE send_email(par_inoutput_info_id inoutput_info.inoutput_info_id%TYPE) IS
    v_recipients    pkg_email.t_recipients;
    v_recipients_cc pkg_email.t_recipients := NULL;
    v_date_feedback inoutput_info.date_feedback%TYPE := NULL;
    v_identity      inoutput_info.identity%TYPE := NULL;
    v_continue      NUMBER := 1;
  BEGIN
    -- ����������� �����������
    SELECT DISTINCT cce.email
      BULK COLLECT INTO v_recipients
      FROM ven_sys_user         su
          ,ven_cn_contact_email cce
          ,ven_t_email_type     tet
          ,inoutput_info        ii
    WHERE 1 = 1
      AND su.contact_id       = cce.contact_id
      AND su.sys_user_name    = ii.user_name
      AND tet.description     = '�������'
      AND ii.inoutput_info_id = par_inoutput_info_id;
    IF v_recipients.count = 0 THEN
      v_continue := 0;
    END IF;

    -- ����������� ������ ���������, ���� ������������ (��������� ������)
    BEGIN
      SELECT ii.identity
            ,ii.date_feedback
        INTO v_identity
            ,v_date_feedback
        FROM inoutput_info ii
      WHERE ii.inoutput_info_id = par_inoutput_info_id;
    EXCEPTION
      WHEN no_data_found THEN
        NULL;
    END;

    -- ����������� ������ ���������, ������� � ����� ���������
    SELECT DISTINCT cs.string_param
      BULK COLLECT INTO v_recipients_cc
      FROM t_crm_settings cs
    WHERE cs.brief = 'Email.CC';

    -- ������� ������
    IF v_continue = 1 THEN
      pkg_email.send_mail_with_attachment(par_to      => v_recipients
                                         ,par_cc      => v_recipients_cc
                                         ,par_subject => '����������� �� ��������� ' || NVL(v_identity, par_inoutput_info_id)
                                         ,par_text    => '������ ����!' || chr(10) ||
                                                         '���������� ��� � ������������� ����������� ��������� � ' || NVL(v_identity, par_inoutput_info_id) ||
                                                         ' � ������ CRM ������� Borlas Insurance �� ' || NVL(to_char(v_date_feedback, 'dd.mm.yyyy'), to_char(SYSDATE, 'dd.mm.yyyy')) || ' ������������.');
    END IF;
  END send_email;

  /*
    ��������� �������� ����� ��� �����

    BEGIN
      DBMS_SCHEDULER.CREATE_JOB (
         job_name             => 'JOB_CRM_SEND_EMAIL',
         job_type             => 'PLSQL_BLOCK',
         job_action           => 'BEGIN PKG_CRM.SEND_EMAIL_JOB(SYSDATE); END;',
         start_date           => to_timestamp('10.01.2014 09:00:00','dd.mm.yyyy HH24:MI:SS'),
         repeat_interval      => 'FREQ=DAILY',
         enabled              =>  TRUE,
         comments             => 'CRM: ������� ����������� �� ������������ ���������');
    END;

  */
  PROCEDURE send_email_job(par_date_feedback inoutput_info.date_feedback%TYPE) IS
  BEGIN
    FOR rec IN (SELECT ii.inoutput_info_id id
                FROM inoutput_info ii
                    ,t_crm_request_kind rk
                WHERE 1 = 1
                  AND ii.t_message_kind_id = rk.t_message_kind_id
                  AND FEEDBACK_IDENTITY IS NULL                -- �� ������ ����� � ������ ����������
                  AND DATE_FEEDBACK = TRUNC(par_date_feedback) -- ���� ��������� ������ ����� ���������� ����
                  AND rk.is_answer = 0                         -- �� �������� �������
               ) LOOP
      send_email(rec.id);
    END LOOP;
  END send_email_job;

  /*
    ��������� ������ ������ ��������� �� "�������� ������ ��� ������"
  */
  PROCEDURE set_unanswer_status(par_inoutput_info_id inoutput_info.inoutput_info_id%TYPE) IS
    v_count NUMBER := 0;
  BEGIN
    SELECT COUNT(*)
      INTO v_count
      FROM inoutput_info ii
          ,t_crm_request_kind rk
    WHERE 1 = 1
      AND ii.t_message_kind_id = rk.t_message_kind_id
      AND rk.is_answer         = 0
      AND ii.date_feedback     IS NOT NULL
      AND ii.inoutput_info_id  = par_inoutput_info_id
      AND NOT EXISTS (SELECT 1
                      FROM inoutput_info ii2
                          ,t_crm_request_kind rk2
                      WHERE 1 = 1
                        AND ii2.t_message_kind_id = rk2.t_message_kind_id
                        AND rk2.is_answer         = 1
                        AND ii2.inoutput_info_id  = ii.feedback_identity);
    IF v_count <> 0 THEN
      UPDATE inoutput_info SET t_message_state_id = (SELECT t_message_state_id FROM t_message_state WHERE message_state_brief = 'UNANSWERED_CALL')
      WHERE inoutput_info_id = par_inoutput_info_id;
    END IF;
  END set_unanswer_status;

  /*
    ��������� ������� ���������� ������
  */
  PROCEDURE clear_search_results IS
  BEGIN
    DELETE FROM TMP_CRM_REQUEST_PURPOSE;
    COMMIT;
  END clear_search_results;

END pkg_crm;
/
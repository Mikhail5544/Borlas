CREATE OR REPLACE PACKAGE pkg_policy_renew IS

  PROCEDURE calc_cash_surr(p_policy_id PLS_INTEGER);

  PROCEDURE peny_calc(par_policy_id PLS_INTEGER);

  FUNCTION ren_recprog(p_p_policy_id IN NUMBER) RETURN NUMBER;

  FUNCTION ren_allprog(p_p_policy_id IN NUMBER) RETURN NUMBER;

  FUNCTION ren_date(p_p_policy_id IN NUMBER) RETURN NUMBER;

  FUNCTION change_polnum_to_ids(p_p_policy_id IN NUMBER) RETURN NUMBER;

  /*
    ������ �.
    ��������� ����������� ��� ����� <���� ��������> ��������� ������:
      ����������� ��������� <�������-� ����� ��������>;
    ��������� �������� ������ ��� ����� <���� ��������>:
      �������� ��������� <�������-� �������� ���������>.
  
    ����������� � ������� ����:
      ��. �������� ������ "����������� ��������� - �������������� ����� ��������"
      CREATE_TECH_FULL_POLICY_RECOVER; - � ����-��������� ������ �������������
      ��. �������� ������ "�������� ��������� - �������������� �������� ���������"
      CREATE_MAIN_RECOVER_MAIN.
  
      ���������� 0 - ������������ ���������, 1 - ������������ ���������.
  */
  FUNCTION ren_check_rights(p_policy_id NUMBER) RETURN NUMBER;
  /*
    ������ �. �������� ��� ��������������:
    ��, �. 3.1.1.
    ��������� �������� ��� ���� ���� ��������, ���� ������� ����������� ��������� ������� � ����� ������������ �� ��,
    �� ������ �������-� �� �����������.
  */
  PROCEDURE check_01(p_policy_id IN NUMBER);

  /*
    ������ �. �������� ��� ��������������:
    ��, �. 3.1.2.
    ...���� ��������� ���������� ������������ ������ �������������� �� �����������.
  */
  PROCEDURE check_02(p_policy_id IN NUMBER);
  /*
    ������ �. �������� ��� ��������������:
    ��, �. 3.1.3.
    ������ �������������� �� �����������, ���� ���� ������ �������� ���� ����� 2-� ����������� ��� �����
  */
  PROCEDURE check_03(p_policy_id IN NUMBER);
  /*
    ������ �. �������� ��� ��������������:
    ��, �. 3.1.4.
    �������������� �������� ������ �������� � �������������� - ��� � �������, ��� � ���, ��������������, �����������
  */
  PROCEDURE check_04(p_policy_id IN NUMBER);

  /*
    ������ �. �������� ��� ��������������:
    ��, �. 3.1.5.
    �� �������� ����������� ������ ���� �������� � ������ ������ �������� ������� ���� �������� ��������.
  */
  PROCEDURE check_05(p_policy_id IN NUMBER);
  /*
    ������ �. �������� ��� ��������������:
    ��, �. 3.1.6.
    ��������� ���� �� ��������� �������:
      ����� �� �������� ��������� ����������� ���������� �� ����� 2 500 (��� ������ �������) ������;
      � ���� ������� ������������ ������ �� ���� �������������� ������ �� ����� 6 �������;
      �� ���� ����������� �� �������� ����������� �� ����������� ������ <���������� ��������>.
  
    � �������: "�����-�. �������� �������������� �������"
  */
  PROCEDURE check_06(p_policy_id IN NUMBER);
  /*
    ������ �. �������� ��� ��������������:
    ��� ������ �������� �������������� �������� ���������, ���� ���� ������ ������+70>���� ����������,
    �� ������ �� �����������.
  
    � �������: "�����-�. �������� ���� ������ ������"
  */
  PROCEDURE check_07(p_policy_id IN NUMBER);

  /**
  * @author ������ �.
  * @param p_policy_id �� ������
  * ������ �. ��������� ��������������� �������� ���� �������� �� ����������� ������
  * � �������: "�����-�. ��� �������� - ����������� ������"
  */
  PROCEDURE check_08(p_policy_id IN NUMBER);

  /*
    ������ �.
    ������������� �������� �� �����������, ��� �������� ������ �������������� � ������ "�����������"
  */
  PROCEDURE storno_quit_trans(par_policy_id NUMBER);
  /*
    ������ �.
    ������ ������������� �������� �� �����������, ��� �������� ������ �������������� �� ������� "�����������" �������
  */
  PROCEDURE unstorno_quit_trans(par_policy_id NUMBER);

  /*
    ��������� �.
   ���������� ������ "������ ������������� ��������" � ������� ����������� ��� �������� � ������ "�������������� ����� 
   ��������"/ "�������������� �������� ���������" � �����
  */
  PROCEDURE set_trade_escort_agent(par_policy_id NUMBER);

  /*
    ������ �.
    �������� ������ �������������� (288085 �������������� �� �������� ��������� �������� �������)
    ����������� �� �������� �������� ������ -> ��������������
  */
  PROCEDURE check_recover_version(par_policy_id NUMBER);

END pkg_policy_renew;
/
CREATE OR REPLACE PACKAGE BODY pkg_policy_renew IS

  g_debug BOOLEAN DEFAULT TRUE;

  PROCEDURE log
  (
    p_p_policy_id IN NUMBER
   ,p_message     IN VARCHAR2
  ) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    IF g_debug
    THEN
      INSERT INTO p_policy_debug
        (p_policy_id, execution_date, operation_type, debug_message)
      VALUES
        (p_p_policy_id, SYSDATE, 'Pkg_Policy_Renew', substr(p_message, 1, 4000));
    END IF;
  
    COMMIT;
  
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END;

  /* 
     ����������� �., �������, 2014
     353554: ��������� �������������� ��������� � ������ ������ ��� ������      
  */
  FUNCTION get_pol_addendum_type(par_policy_id IN NUMBER) RETURN VARCHAR2 IS
    v_addendum_type t_addendum_type.brief%TYPE;
  BEGIN
    SELECT ad.brief
      INTO v_addendum_type
      FROM p_pol_addendum_type pa
          ,t_addendum_type     ad
     WHERE pa.p_policy_id = par_policy_id
       AND pa.t_addendum_type_id = ad.t_addendum_type_id;
    RETURN v_addendum_type;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 04.02.2011 15:44:14
  -- Purpose : ����������� �����
  PROCEDURE peny_calc(par_policy_id PLS_INTEGER) IS
    proc_name  VARCHAR2(25) := 'Peny_calc';
    v_peny_amt NUMBER := 0;
  BEGIN
    IF NOT (get_pol_addendum_type(par_policy_id) = 'WRONGFUL_TERM_POLICY_RECOVER')
    THEN
      FOR cov IN (SELECT pc.p_cover_id
                    FROM as_asset           aa
                        ,p_cover            pc
                        ,t_prod_line_option tplo
                   WHERE aa.p_policy_id = par_policy_id
                     AND aa.as_asset_id = pc.as_asset_id
                     AND pc.t_prod_line_option_id = tplo.id
                     AND tplo.brief = 'Penalty')
      LOOP
      
        FOR r IN (SELECT epg.amount
                        ,epg.plan_date
                        ,pp.confirm_date_addendum
                    FROM p_policy       pp
                        ,p_policy       pp2
                        ,doc_doc        dd
                        ,ven_ac_payment epg
                        ,doc_templ      dt
                   WHERE pp.policy_id = par_policy_id
                     AND pp.pol_header_id = pp2.pol_header_id
                     AND pp2.policy_id = dd.parent_id
                     AND dd.child_id = epg.payment_id
                     AND epg.doc_templ_id = dt.doc_templ_id
                     AND dt.brief = 'PAYMENT'
                     AND doc.get_doc_status_brief(epg.payment_id) IN ('TO_PAY', 'NEW')
                     AND epg.plan_date < pp.confirm_date_addendum
                        -- ** 346839 ���������� ����� ��� � �������� ����� �� ����� '���� ������' ��� ������ ��������������
                     AND epg.plan_date >= pp.start_date)
        LOOP
          v_peny_amt := v_peny_amt + r.amount * 0.12 / 365 * (r.confirm_date_addendum - r.plan_date);
        END LOOP;
      
        UPDATE p_cover pc
           SET pc.fee                   = v_peny_amt
              ,pc.premium               = v_peny_amt
              ,pc.is_handchange_amount  = 1
              ,pc.is_handchange_premium = 1
              ,pc.is_handchange_fee     = 1
              ,pc.is_handchange_tariff  = 1
         WHERE pc.p_cover_id = cov.p_cover_id;
      
      END LOOP;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'������ ��� ���������� ' || proc_name || SQLERRM);
  END peny_calc;
  -- Author  : ALEXEY.KATKEVICH
  -- Created : 21.01.2011 17:23:26
  -- Purpose : Calc_cash_surr
  PROCEDURE calc_cash_surr(p_policy_id PLS_INTEGER) IS
    proc_name VARCHAR2(25) := 'calc_cash_surr';
  BEGIN
  
    UPDATE ven_p_policy SET cash_surr_method_id = 2 WHERE policy_id = p_policy_id;
  
    pkg_pol_cash_surr_method.recalccashsurrmethod(p_policy_id);
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'������ ��� ���������� ' || proc_name || SQLERRM);
  END calc_cash_surr;

  FUNCTION ren_recprog(p_p_policy_id IN NUMBER) RETURN NUMBER AS
  
    l_cover_id NUMBER;
  
  BEGIN
  
    --��������� ��� �������� ����� �������� ���������
    --��� ���� ��������������
    FOR v_r IN (SELECT pc.p_cover_id
                  FROM as_asset            a
                      ,p_cover             pc
                      ,t_prod_line_option  opt
                      ,t_product_line      pl
                      ,t_product_line_type tp
                 WHERE a.p_policy_id = p_p_policy_id
                   AND a.as_asset_id = pc.as_asset_id
                   AND pc.t_prod_line_option_id = opt.id
                   AND opt.product_line_id = pl.id
                   AND pl.product_line_type_id = tp.product_line_type_id
                   AND tp.brief <> 'RECOMMENDED')
    LOOP
      -- DELETE FROM ven_p_cover pc WHERE pc.p_cover_id = v_r.p_cover_id;
      pkg_cover.exclude_cover(v_r.p_cover_id);
      --UPDATE p_cover SET status_hist_id = p_p_status_hist_id WHERE p_cover_id = v_r.p_cover_id;
    END LOOP;
  
    --���������� �����,
    --  ���������������� �������� - ���������� ����
    FOR inc_cov IN (SELECT t.id
                          ,aa.as_asset_id
                          ,t.description
                      FROM t_product_line      t
                          ,t_product_line_type tpt
                          ,t_product_ver_lob   lb
                          ,t_product_version   ver
                          ,t_product           prod
                          ,p_policy            pp
                          ,as_asset            aa
                          ,p_pol_header        ph
                     WHERE t.product_ver_lob_id = lb.t_product_ver_lob_id
                       AND t.product_line_type_id = tpt.product_line_type_id
                       AND ver.t_product_version_id = lb.product_version_id
                       AND (t.description IN ('Penalty')) --,'���������������� ��������'))
                          --      OR tpt.brief = 'RECOMMENDED')
                       AND ver.product_id = prod.product_id
                       AND prod.product_id = ph.product_id
                       AND pp.pol_header_id = ph.policy_header_id
                       AND pp.policy_id = aa.p_policy_id
                       AND pp.policy_id = p_p_policy_id)
    LOOP
    
      l_cover_id := pkg_cover.include_cover(inc_cov.as_asset_id, inc_cov.id);
    
    END LOOP;
  
    --����������� ���� (����� �� ������������ ��������)
    pkg_policy.update_policy_dates(p_p_policy_id);
  
    RETURN 1;
  
  EXCEPTION
    WHEN OTHERS THEN
      log(p_p_policy_id, SQLERRM);
      raise_application_error(-20301, '������ ����������: ren_recprog ' || SQLERRM);
  END ren_recprog;

  FUNCTION ren_allprog(p_p_policy_id IN NUMBER) RETURN NUMBER AS
  BEGIN
    IF p_p_policy_id IS NULL
    THEN
      RETURN NULL;
    END IF;
  
    --��������� ������-������ - �� �����������������
    --��� ���� ��������������
    FOR v_r IN (SELECT pc.p_cover_id
                  FROM as_asset            a
                      ,p_cover             pc
                      ,t_prod_line_option  opt
                      ,t_product_line      pl
                      ,t_product_line_type tp
                 WHERE a.p_policy_id = p_p_policy_id
                   AND a.as_asset_id = pc.as_asset_id
                   AND pc.t_prod_line_option_id = opt.id
                   AND opt.product_line_id = pl.id
                   AND pl.product_line_type_id = tp.product_line_type_id
                   AND tp.brief <> 'RECOMMENDED'
                   AND pl.t_lob_line_id IN
                       (SELECT lb.t_lob_line_id
                          FROM ins.t_lob_line lb
                         WHERE lb.brief = 'PEPR_INVEST_RESERVE'))
    LOOP
      pkg_cover.exclude_cover(v_r.p_cover_id);
    END LOOP;
  
    RETURN NULL;
  END ren_allprog;

  FUNCTION ren_date(p_p_policy_id IN NUMBER) RETURN NUMBER AS
  
    p_cur_start_date    DATE;
    p_active_start_date DATE;
    p_cur_confirm_date  DATE;
    p_active_break_date DATE;
    p_role_name         VARCHAR2(200);
    p_add_type          VARCHAR2(200);
  
  BEGIN
    RETURN 1;
  
    SELECT pp1.start_date
          ,pp1.decline_date --pp1.confirm_date_addendum
      INTO p_active_start_date
          ,p_active_break_date
      FROM p_policy     pp
          ,ven_p_policy pp1
     WHERE pp.policy_id = p_p_policy_id
       AND pp.pol_header_id = pp1.pol_header_id
       AND pp1.version_num = pp.version_num - 1;
  
    SELECT pp.start_date
          ,pp.confirm_date_addendum --pp.decline_date
      INTO p_cur_start_date
          ,p_cur_confirm_date
      FROM p_policy pp
     WHERE pp.policy_id = p_p_policy_id;
  
    IF p_active_start_date <> p_cur_start_date
    THEN
      pkg_forms_message.put_message('������ ��������: ��������� ���� ��������������� ����������.');
      raise_application_error(-20401
                             ,'������ ����������: ��������� ���� ��� ����������');
    END IF;
  
    IF p_cur_confirm_date < p_active_break_date
    THEN
      pkg_forms_message.put_message('������ ��������: ��������� ���� ���������� � ����.');
      raise_application_error(-20401
                             ,'������ ����������: ��������� ���� ��� ����������');
    END IF;
  
    BEGIN
      SELECT v.name INTO p_role_name FROM ven_sys_role v WHERE v.sys_role_id = safety.get_curr_role;
    EXCEPTION
      WHEN no_data_found THEN
        --���� ���� �� ������� ������ ������ �������� ��������
        p_role_name := '�����';
    END;
  
    BEGIN
      SELECT t.description
        INTO p_add_type
        FROM p_pol_addendum_type tp
            ,t_addendum_type     t
       WHERE tp.p_policy_id = p_p_policy_id
         AND tp.t_addendum_type_id = t.t_addendum_type_id;
    EXCEPTION
      WHEN no_data_found THEN
        p_add_type := '�������������� ����� ��������';
    END;
  
    IF p_role_name NOT IN ('�����'
                          ,'�������������'
                          ,'���������� �� ������ ���������')
       AND p_add_type = '�������������� ����� ��������'
    THEN
      pkg_forms_message.put_message('������ ��������: �� ������� ���� ��� �������� ������� ���� ����������.');
      raise_application_error(-20601
                             ,'������ ����������: �� ������� ����');
    END IF;
  
    RETURN 1;
  
  EXCEPTION
    WHEN OTHERS THEN
      log(p_p_policy_id, SQLERRM);
      raise_application_error(-20501, '������ ����������: ren_date ' || SQLERRM);
  END ren_date;

  FUNCTION change_polnum_to_ids(p_p_policy_id IN NUMBER) RETURN NUMBER AS
    p_ph_ids NUMBER;
  BEGIN
    IF p_p_policy_id IS NOT NULL
    THEN
    
      BEGIN
        SELECT ph.ids
          INTO p_ph_ids
          FROM p_policy     pp
              ,p_pol_header ph
         WHERE pp.policy_id = p_p_policy_id
           AND pp.pol_header_id = ph.policy_header_id;
      EXCEPTION
        WHEN no_data_found THEN
          p_ph_ids := 0;
      END;
    
      IF p_ph_ids > 0
      THEN
        UPDATE p_policy pp SET pp.pol_num = p_ph_ids WHERE pp.policy_id = p_p_policy_id;
        ins.doc.set_doc_status(p_p_policy_id
                              ,'NEW'
                              ,SYSDATE + 1 / 24 / 3600
                              ,'AUTO'
                              ,'������� � ������ ��� ��������� ������ ������ �������� �����������');
      ELSE
        pkg_forms_message.put_message('������ ��������: ����������� ��� ��������.');
        raise_application_error(-20401
                               ,'������ ����������: ����������� ��� ��������');
      END IF;
    
    ELSE
      RETURN NULL;
    END IF;
    RETURN NULL;
  END change_polnum_to_ids;

  FUNCTION get_prev_policy(p_policy_id IN NUMBER) RETURN NUMBER IS
    v_prev_policy NUMBER;
  BEGIN
    SELECT pp.policy_id
      INTO v_prev_policy
      FROM p_policy pp
          ,p_policy pc
     WHERE pc.policy_id = p_policy_id
       AND pp.pol_header_id = pc.pol_header_id
       AND pp.version_num = pc.version_num - 1;
    RETURN v_prev_policy;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN - 1;
  END;

  /*
    ������ �.
    ��������� ����������� ��� ����� <���� ��������> ��������� ������:
      ����������� � �������� ��������� <�������-� ����� ��������>;
    ��������� �������� ������ ��� ����� <���� ��������>:
      �������� ��������� <�������-� �������� ���������>.
  
    ����������� � ������� ����:
      ��. �������� ������ "����������� ��������� - �������������� ����� ��������"
      CREATE_TECH_RENEW; - � ����-��������� ������ �������������
      ��. �������� ������ "�������� ��������� - �������������� �������� ���������"
      CREATE_MAIN_RENEW.
  
      ���������� 0 - ������������ ���������, 1 - ������������ ���������.
      ������������ � ������� Borlas: �������� ��� ��������������
  */
  FUNCTION ren_check_rights(p_policy_id NUMBER) RETURN NUMBER IS
    v_chg_type_brief t_policy_change_type.brief%TYPE;
    v_add_type_brief t_addendum_type.brief%TYPE;
  BEGIN
    SELECT ct.brief
          ,ty.brief
      INTO v_chg_type_brief
          ,v_add_type_brief
      FROM p_policy             pp
          ,t_policy_change_type ct
          ,p_pol_addendum_type  ad
          ,t_addendum_type      ty
     WHERE pp.policy_id = ren_check_rights.p_policy_id
       AND pp.t_pol_change_type_id = ct.t_policy_change_type_id
       AND pp.policy_id = ad.p_policy_id
       AND ad.t_addendum_type_id = ty.t_addendum_type_id;
  
    --      PKG_FORMS_MESSAGE.put_message(v_chg_type_brief||' | '||v_add_type_brief||' | '||to_char(safety.check_right_custom('CREATE_MAIN_RENEW')));
    --      RAISE_APPLICATION_ERROR(-20401, v_chg_type_brief||' | '||v_add_type_brief||' | '||to_char(safety.check_right_custom('CREATE_MAIN_RENEW')));
  
    IF v_chg_type_brief IN ('�����������', '��������')
       AND v_add_type_brief IN ('FULL_POLICY_RECOVER', 'WRONGFUL_TERM_POLICY_RECOVER')
       AND safety.check_right_custom('CREATE_TECH_RENEW') != 1
    THEN
      pkg_forms_message.put_message('�������������� ����������. � ��� ��� ���� ��� ��������������.');
      raise_application_error(-20401
                             ,'�������������� ����������. � ��� ��� ���� ��� ��������������.');
    ELSIF v_chg_type_brief = '��������'
          AND v_add_type_brief = 'RECOVER_MAIN'
          AND safety.check_right_custom('CREATE_MAIN_RENEW') != 1
    THEN
      pkg_forms_message.put_message('�������������� ����������. � ��� ��� ���� ��� ��������������.');
      raise_application_error(-20401
                             ,'�������������� ����������. � ��� ��� ���� ��� ��������������.');
    END IF;
  
    --    check_legal_renew(p_policy_id);
    RETURN 1;
  END;

  /*
    ������ �. �������� ��� ��������������:
    ��, �. 3.1.1.
    ��������� �������� ��� ���� ���� ��������, ���� ������� ����������� ��������� ������� � ����� ������������ �� ��,
    �� ������ �������-� �� �����������.
    �������� ������� ������� �� �����: "��. ��������� ������� ����������� ��� ��������������"
  
    � �������: "�����-�. �������� ������� � �����"
  */
  PROCEDURE check_01(p_policy_id IN NUMBER) IS
    v_prev_policy NUMBER;
  BEGIN
    IF (safety.check_right_custom('CHECK_DECL_REASON_RENEW') = 1)
       AND NOT (get_pol_addendum_type(p_policy_id) = 'WRONGFUL_TERM_POLICY_RECOVER')
    THEN
      v_prev_policy := get_prev_policy(p_policy_id);
      -- ������� �����������
      FOR r_check IN (SELECT 1
                        FROM t_decline_reason re
                            ,p_policy         pp
                       WHERE pp.policy_id = v_prev_policy
                         AND pp.decline_reason_id = re.t_decline_reason_id
                         AND re.brief IN ('��������� �������'
                                         ,'����� ������������ �� ��')
                         AND rownum = 1)
      LOOP
        raise_application_error(-20001
                               ,'��� ����� ���� ��������� ����������� ������ "��������������" ��� ������ ������� �����������!');
      END LOOP;
    END IF;
  END check_01;
  /*
    ������ �. �������� ��� ��������������:
    ��, �. 3.1.2.
    ...���� ��������� ���������� ������������ ������ �������������� �� �����������.
  
    � �������: "�����-�. �������� ������������� ��"
  */
  PROCEDURE check_02(p_policy_id IN NUMBER) IS
    v_prev_policy NUMBER;
    v_cnt         NUMBER;
  BEGIN
    v_prev_policy := get_prev_policy(p_policy_id);
  
    SELECT COUNT(1)
      INTO v_cnt
      FROM dual
     WHERE EXISTS (SELECT NULL
              FROM ven_ac_payment   ap
                  ,doc_doc          dd
                  ,ac_payment_templ apt
                  ,doc_templ        dt
             WHERE ap.payment_id = dd.child_id
               AND ap.payment_templ_id = apt.payment_templ_id
               AND apt.brief = 'PAYREQ'
               AND ap.doc_templ_id = dt.doc_templ_id
               AND dt.brief = 'PAYREQ'
               AND dd.parent_id = v_prev_policy);
    -- ���� ���� ��, ���������� ������
    IF v_cnt = 1
    THEN
      raise_application_error(-20001
                             ,'������������ ��������� ����������, ����������� ������ "��������������" ���������!');
    END IF;
  END check_02;
  /*
    ������ �. �������� ��� ��������������:
    ��, �. 3.1.3.
    ������ �������������� �� �����������, ���� ���� ������ �������� ���� ����� 2-� ����������� ��� �����
     �������, ��� �� ���� ���������� � ����
  
    � �������: "�����-�. �������� ���� ������ ��������"
  */
  PROCEDURE check_03(p_policy_id IN NUMBER) IS
    v_cnt NUMBER;
  BEGIN
    IF NOT (get_pol_addendum_type(p_policy_id) = 'WRONGFUL_TERM_POLICY_RECOVER')
    THEN
      SELECT CEIL(MONTHS_BETWEEN(pp.confirm_date_addendum
                                ,pkg_renlife_utils.paid_unpaid(pp.pol_header_id, 2)) / 12)
        INTO v_cnt
        FROM p_policy pp
       WHERE pp.policy_id = p_policy_id;
      IF v_cnt NOT BETWEEN 0 AND 2
      THEN
        raise_application_error(-20001
                               ,'���� ������ �������� ���� ����� 2-� ����������� ��� �����, ����������� ������ "��������������" ���������!');
      END IF;
    END IF;
  END check_03;
  /*
    ������ �. �������� ��� ��������������:
    ��, �. 3.1.4.
    �������������� �������� ������ �������� � �������������� - ��� � �������, ��� � ���, ��������������, �����������
  
    � �������: "�����-�. �������� ������������� ��������"
  */
  PROCEDURE check_04(p_policy_id IN NUMBER) IS
    v_is_periodical NUMBER;
    v_is_decline    NUMBER;
  BEGIN
    IF NOT (get_pol_addendum_type(p_policy_id) = 'WRONGFUL_TERM_POLICY_RECOVER')
    THEN
      SELECT COUNT(1)
        INTO v_is_decline
        FROM dual
       WHERE EXISTS (SELECT *
                FROM (SELECT NULL
                        FROM ven_p_policy          p
                            ,ven_p_policy          p2
                            ,doc_status_ref        dsr
                            ,ven_t_illegal_decline il
                            ,ven_p_pol_decline     pd
                       WHERE p2.doc_status_ref_id = dsr.doc_status_ref_id
                         AND dsr.brief = 'QUIT'
                         AND p.policy_id = p_policy_id
                         AND p2.pol_header_id = p.pol_header_id
                         AND p2.policy_id = pd.p_policy_id
                         AND pd.t_illegal_decline_id = il.t_illegal_decline_id(+)
                       ORDER BY p.version_num)
               WHERE rownum = 1);
    
      SELECT pt.is_periodical
        INTO v_is_periodical
        FROM p_policy        pp
            ,t_payment_terms pt
       WHERE pp.policy_id = p_policy_id
         AND pp.payment_term_id = pt.id;
    
      IF v_is_decline = 0
         AND v_is_periodical = 0
      THEN
        raise_application_error(-20001
                               ,'������������� ������ ��������� �������: "�������������", ����������� ������ "��������������" ���������!');
      END IF;
    END IF;
  END check_04;

  /*
    ������ �. �������� ��� ��������������:
    ��, �. 3.1.5.
    �� �������� ����������� ������ ���� �������� � ������ ������ �������� ������� ���� �������� ��������.
  
    � �������: "�����-�. �������� ������ ��������"
  */
  PROCEDURE check_05(p_policy_id IN NUMBER) IS
    v_is_unpaid NUMBER;
  BEGIN
    IF NOT (get_pol_addendum_type(p_policy_id) = 'WRONGFUL_TERM_POLICY_RECOVER')
    THEN
      SELECT COUNT(1)
        INTO v_is_unpaid
        FROM dual
       WHERE EXISTS
       (SELECT NULL
                FROM p_pol_header   he
                    ,p_policy       ph
                    ,p_policy       pp
                    ,doc_doc        dd
                    ,ac_payment     ap
                    ,document       doc
                    ,doc_templ      dt
                    ,doc_status     ds
                    ,doc_status_ref dsr
               WHERE ph.policy_id = p_policy_id
                 AND ph.pol_header_id = he.policy_header_id
                 AND he.policy_header_id = pp.pol_header_id
                 AND dd.parent_id = pp.policy_id
                 AND dd.child_id = ap.payment_id
                 AND ap.payment_id = doc.document_id
                 AND doc.doc_templ_id = dt.doc_templ_id
                 AND dt.brief = 'PAYMENT'
                 AND doc.document_id = ds.document_id
                 AND ds.doc_status_ref_id = dsr.doc_status_ref_id
                 AND ds.start_date =
                     (SELECT MAX(d.start_date) FROM doc_status d WHERE d.document_id = ds.document_id)
                 AND ap.due_date BETWEEN he.start_date AND ADD_MONTHS(he.start_date, 6) - 1
                 AND dsr.brief NOT IN ('PAID', 'ANNULATED'));
    
      IF v_is_unpaid = 1
      THEN
        raise_application_error(-20001
                               ,'�� �������� �� �������� � ������ ������ �������� ������� ���� ��� ��������, ����������� ������ "��������������" ���������!');
      END IF;
    END IF;
  END check_05;

  /*
    ������ �. �������� ��� ��������������:
    ��, �. 3.1.6.
    ������ ����� ��������� ��� �������:
      ����� �� �������� ��������� ����������� ���������� �� ����� 2 500 (��� ������ �������) ������;
      � ���� ������� ������������ ������ �� ���� �������������� ������ �� ����� 6 �������;
      �� ���� ����������� �� �������� ����������� �� ����������� ������ <���������� ��������>.
  
    � �������: "�����-�. �������� �������������� �������"
  */
  PROCEDURE check_06(p_policy_id IN NUMBER) IS
    v_cnt NUMBER;
  BEGIN
    IF NOT (get_pol_addendum_type(p_policy_id) = 'WRONGFUL_TERM_POLICY_RECOVER')
    THEN
      -- ����� �� �������� ��������� ����������� ���������� �� ����� 2 500 (��� ������ �������) ������
      SELECT COUNT(1)
        INTO v_cnt
        FROM dual
       WHERE EXISTS (SELECT NULL
                FROM as_asset            ass
                    ,p_cover             co
                    ,t_prod_line_option  po
                    ,t_product_line      pl
                    ,t_product_line_type pt
               WHERE ass.p_policy_id = check_06.p_policy_id
                 AND co.as_asset_id = ass.as_asset_id
                 AND po.id = co.t_prod_line_option_id
                 AND pl.id = po.product_line_id
                 AND pt.product_line_type_id = pl.product_line_type_id
                 AND pt.brief = 'RECOMMENDED'
                 AND co.fee >= 2500);
    
      IF v_cnt = 0
      THEN
        raise_application_error(-20001
                               ,'����� �� �������� ��������� ����������� ������ ���������� �� ����� 2 500 ������, ����������� ������ "��������������" ���������!');
      END IF;
      -- � ���� ������� ������������ ������ �� ���� �������������� ������ �� ����� 6 �������
      -- ���������� �� ���� �������
      SELECT FLOOR(MONTHS_BETWEEN(ds.start_date
                                 ,pkg_renlife_utils.first_unpaid((SELECT pp.pol_header_id
                                                                   FROM p_policy pp
                                                                  WHERE pp.policy_id = p_policy_id)
                                                                ,1)))
        INTO v_cnt
        FROM doc_status ds
       WHERE ds.doc_status_id = doc.get_last_doc_status_id(p_policy_id);
      /*    select floor(months_between(pp.confirm_date_addendum,pkg_renlife_utils.first_unpaid(pp.pol_header_id, 1)))
       into v_cnt
       from p_policy pp
      where pp.policy_id = p_policy_id;*/
    
      IF v_cnt < 6
      THEN
        raise_application_error(-20001
                               ,'� ���� ������� ������������ ������ �� ���� �������������� ������ ������ �� ����� 6 �������, ����������� ������ "��������������" ���������!');
      END IF;
      -- �� ���� ����������� �� �������� ����������� �� ����������� ������ <���������� ��������>
      -- �������� ��: ������ ������������ ������ � ������ � ��� �������� � ����� ��� �� ������ ���� ������ �� ��� �������.
      SELECT COUNT(1)
        INTO v_cnt
        FROM (SELECT NULL
                FROM (SELECT MAX(CASE ta.brief
                                   WHEN 'FIN_WEEK' THEN
                                    pp.start_date
                                 END) AS max_fin_week
                            ,MAX(CASE ta.brief
                                   WHEN 'CLOSE_FIN_WEEKEND' THEN
                                    pp.start_date
                                 END) AS max_close_fin_week
                        FROM p_policy            ph
                            ,p_policy            pp
                            ,p_pol_addendum_type pa
                            ,t_addendum_type     ta
                       WHERE ph.policy_id = check_06.p_policy_id
                         AND pp.pol_header_id = ph.pol_header_id
                         AND pp.policy_id = pa.p_policy_id
                         AND pa.t_addendum_type_id = ta.t_addendum_type_id
                         AND ta.brief IN ('FIN_WEEK', 'CLOSE_FIN_WEEKEND')
                         AND pp.version_num < ph.version_num)
               WHERE max_fin_week > nvl(max_close_fin_week, max_fin_week - 1));
    
      IF v_cnt = 1
      THEN
        raise_application_error(-20001
                               ,'�� �������� ����������� ��������� ������ "���������� ��������", ����������� ������ "��������������" ���������!');
      END IF;
    END IF;
  END check_06;

  /*
    ������ �. �������� ��� ��������������:
    ��� ������ �������� �������������� �������� ���������, ���� ���� ������ ������+70>���� ����������,
    �� ������ �� �����������.
  
    � �������: "�����-�. �������� ���� ������ ������"
  */
  PROCEDURE check_07(p_policy_id IN NUMBER) IS
    v_cnt NUMBER;
  BEGIN
    IF NOT (get_pol_addendum_type(p_policy_id) = 'WRONGFUL_TERM_POLICY_RECOVER')
    THEN
      SELECT COUNT(1)
        INTO v_cnt
        FROM dual
       WHERE EXISTS (SELECT NULL
                FROM p_policy            pp
                    ,p_pol_addendum_type pa
                    ,t_addendum_type     ta
               WHERE pp.policy_id = check_07.p_policy_id
                 AND pp.policy_id = pa.p_policy_id
                 AND pa.t_addendum_type_id = ta.t_addendum_type_id
                 AND ta.brief = 'RECOVER_MAIN'
                 AND pp.start_date + 70 > pp.notice_date_addendum);
      IF v_cnt = 1
      THEN
        raise_application_error(-20001
                               ,'���� ������ ������+70 ������ ���� ����������, ����������� ������ "��������������" ���������!');
      END IF;
    END IF;
  END check_07;

  /*
  ������ �. ��������� ��������������� �������� ���� �������� �� ����������� ������
  � �������: "�����-�. ��� �������� - ����������� ������"
  */
  PROCEDURE check_08(p_policy_id IN NUMBER) IS
    v_collection_method_id NUMBER;
  BEGIN
    SELECT pp.collection_method_id
      INTO v_collection_method_id
      FROM p_policy pp
     WHERE pp.policy_id = p_policy_id;
  
    IF v_collection_method_id IN (3, 4)
    THEN
      --������ �������� � �����; ������������ ������� ������������
      UPDATE p_policy pp
         SET pp.collection_method_id = 2 --����������� ������
       WHERE pp.policy_id = p_policy_id;
    END IF;
  END check_08;
  /*
    ������ �.
    �������� ������ ��������������.
    1. � ������, ���� ����������� �������������, �� ������� ����� ������ ������ � ����� ���������
       ��������������� ����� ��������.
       ����������� �. �������� �������� ������ 353554: ��������� �������������� ��������� � ������ ������ ��� ������
       � ������, ���� ����������� �������������, �� ������� ����� ������ ������ � ����� ���������
       ��������������� (������������� �����������)�.
    2. �������� �����������, ������������ � �������� �����������:
       * �������� ������� ������;
       * ����� �����������;
       * ����� ������������ �� ��;
       * ����� ������������ �� ��������
       * ������� ���� (�������������)
       ������ ����������������� ������ ���� ���� ������� �������������� �����������.
       ��� ���������� �� ����� ����������� �������� �������������� ����������� ������ ���������� ��������� � �������:
       �������� ����������� ����������. �������������� �� �������������.
    3. ���� �� ������������� �������� ���� ������ � ������� ������ ���� � ��� ���� �� ����� ����� ����
       � ���� ����� ������� ������������� �� ����� ����, ������ �� �������� ���� ����������� ������� ��� �����������.
       ���� ��� �������� ������ � ����� ��������� ��������������� ����� �������� ���� ������ � ������� ������ ����
       � ��� ���� �� ����� ����� ���� � ���� ����� ������� ������������� �� ����� ����,
       �� ��� �������� ������ �������������� ������ ���������� ��������� � �������:
         ����� ������� ��� �����������. �������������� ����������.�.
       ����� ���� ��� ����� ���������� �� ������������ ��������� �������:
       ��� ��������� � ������� RUR ����=������(���*0,13;0),
       ��� ��������� � �������, �������� �� RUR ����= ������(���*0,13;2).
    4. ���� �� ������������� �������� ���� ���������� �� ������ ���������� ������ ����,
       �� ������� ����� ������ ������ � ����� ��������� ��������������� ����� ��������
    5. ����������� ����� �� ���� ������ ������ �� ������ �������.
       ���� ��� �������� ������ � ����� ��������� ��������������� ����� ��������
       ����� �� ���� ������ ������ �� ������ �������  ������ ����, �� ������ ���������� ��������� � �������:
         ����� �������� �� ������ ������� ��� �����������. �������������� �� ��������.
    6. ��� �������� ������ �������������� � ����� ��������� ��������������� �������� ����������
       ������� ����� ������������ ������ ���� ��������� � ������� �� �������� �� ������ ����� � ������� �� ������������.
       ������������� ��� ����� ���������� �� ���������� ��� �����, ���������� � ������ ��� ��������������� ���������,
       ����� ����� ���������������� ��������.
       ����� � ������� �� ������������ (��): ����� ����+������ ����+������ ����-������� ����
       ����� �� ������� ������� �� ������������� (���): ����� ����� �� ���� ���������� �� ������, ������������ �� ��������, ���������������� (����� ����+������ ����+������ ����)
       ����� �� ������ ������� (���): ����� �� ���� ������ ������ �� ������ �������
       ������� (�): ����� �� ���� ������ � ������� ����� ����� �� ���� ������ ������ �� ������ �������
       �������������� �������� ���� ��-���-���>=0,
       ���� ����� ������� ������������� ����� ���� � ���� ������ ������ �� ������ ������� �� ����� ����.
       �������������� �������� ���� ��-���-���-�>=0,
       ���� ����� ������� ������������� �� ����� ���� � ���� ������ ������ �� ������ ������� �� ����� ����.
       �������������� �������� ���� ���� ������ � ������� ����� ����� ���� �� ���� ������,
       ���� ����� ������� ������������� �� ����� ���� � ��� ���� ������, ��� �� 
       � ���� ������ ������ �� ������ ������� ����� ����.
       �������������� �������� ���� ���� ������ � ������� ������, ���� ����� ��,
       ���� ����� ������� ������������� �� ����� ���� � ��� ���� ������, ��� ��
       � ���� ������ ������ �� ������ ������� ����� ����.
       �������������� ��������, ���� ����� ������ ����� ���� � ���� ���� ������� ����� ����.
       �������������� ��������, ���� ����� ������ ����� ����, ����� ������� ����� ����
       � ���� ����� ������� ������������� �� ����� ����.
       � ��������� �������, ������ ���������� ��������� � �������:
         ����� �������/����� ������� �� �������� ���������. �������������� �� ��������.
    7. ������� ������ 309844: �������������� ����������� ���������. 
       ����������� ���� ��������� �������� ������
       ��� ������� ���������� ���� > ���� ��������� � ���������� ����� "�������������� ������������ ��������"
       ������������ ������ � �������: ��������! � ����� ���� ������������ ���� �� �������������� ������������ ��������.    
    8. ����������� �. �������� �������� ������ 353554: ��������� �������������� ��������� � ������ ������ ��� ������
    3.2.2)  ����������� �������������� �� ������ ����������� ������������� �� ����������� �������� ������� �� � ������� ������������       
  */
  PROCEDURE check_recover_version(par_policy_id NUMBER) IS
    v_is_wrongful_recover NUMBER;
    v_is_full_recover     NUMBER;
    v_can_recover1        NUMBER;
    v_can_recover2        NUMBER;
    v_can_recover3        NUMBER;
    v_can_recover4        NUMBER;
    v_can_recover5        NUMBER;
    v_can_recover6        NUMBER := 0;
    v_can_recover7        NUMBER;
    v_can_recover8        NUMBER;
    v_quit_version_id     NUMBER;
    v_return_sum          NUMBER;
    v_fund_brief          fund.brief%TYPE;
    v_ndfl                NUMBER;
    v_issuer_return_date  DATE;
    v_other_pol_sum       p_pol_decline.other_pol_sum%TYPE;
    v_pol_decline_id      p_pol_decline.p_pol_decline_id%TYPE;
    v_return_summ         p_policy.return_summ%TYPE;
    v_active_ver_end_date DATE;
    v_cnt                 NUMBER;
    v_prev_policy         NUMBER;
  BEGIN
  
    -- ��������� ����������� ��������
    BEGIN
      SELECT COUNT(1)
        INTO v_is_full_recover
        FROM dual
       WHERE EXISTS (SELECT NULL
                FROM p_pol_addendum_type pa
                    ,t_addendum_type     ad
               WHERE pa.p_policy_id = par_policy_id
                 AND pa.t_addendum_type_id = ad.t_addendum_type_id
                 AND ad.brief = 'FULL_POLICY_RECOVER');
    
      SELECT COUNT(1)
        INTO v_is_wrongful_recover
        FROM dual
       WHERE EXISTS (SELECT NULL
                FROM p_pol_addendum_type pa
                    ,t_addendum_type     ad
               WHERE pa.p_policy_id = par_policy_id
                 AND pa.t_addendum_type_id = ad.t_addendum_type_id
                 AND ad.brief = 'WRONGFUL_TERM_POLICY_RECOVER');
    
      SELECT CASE
               WHEN pd.t_illegal_decline_id IS NOT NULL THEN
               /*v_is_full_recover*/
                v_is_wrongful_recover
               ELSE
                1
             END AS p1
            ,CASE
               WHEN (pd.t_illegal_decline_id IS NOT NULL AND
                    dr.brief IN ('�������� ������� ������'
                                 ,'����� �����������'
                                 ,'����� ������������ �� ��'
                                 ,'����� ������������ �� ��������'
                                 ,'������� ���� (�������������)'))
                    OR dr.brief NOT IN ('�������� ������� ������'
                                       ,'����� �����������'
                                       ,'����� ������������ �� ��'
                                       ,'����� ������������ �� ��������'
                                       ,'������� ���� (�������������)') THEN
                1
               ELSE
                0
             END AS p2
            ,pl.return_summ
            ,CASE
               WHEN pd.overpayment > 0 THEN
                v_is_full_recover
               ELSE
                1
             END AS p4
            ,(SELECT pp_.end_date FROM ins.p_policy pp_ WHERE pp_.policy_id = ph.policy_id) pp_end_date
            ,pl.policy_id
            ,fd.brief
            ,nvl(pd.other_pol_sum, 0)
            ,pd.p_pol_decline_id
            ,pd.issuer_return_date
            ,nvl(pl.return_summ, 0)
        INTO v_can_recover1
            ,v_can_recover2
            ,v_return_sum
            ,v_can_recover4
            ,v_active_ver_end_date
            ,v_quit_version_id
            ,v_fund_brief
            ,v_other_pol_sum
            ,v_pol_decline_id
            ,v_issuer_return_date
            ,v_return_summ
        FROM p_policy         pl
            ,p_pol_decline    pd
            ,t_decline_reason dr
            ,fund             fd
            ,p_policy         pp
            ,p_pol_header     ph
       WHERE pp.policy_id = par_policy_id
         AND pp.pol_header_id = ph.policy_header_id
         AND ph.policy_header_id = pl.pol_header_id
         AND pl.version_num IN (SELECT MAX(pl_.version_num)
                                  FROM p_policy           pl_
                                      ,p_pol_decline      pd_
                                      ,ins.document       d
                                      ,ins.doc_status_ref rf
                                 WHERE pl_.pol_header_id = pp.pol_header_id
                                   AND pl_.version_num < pp.version_num
                                   AND pl_.policy_id = pd_.p_policy_id
                                   AND pl_.policy_id = d.document_id
                                   AND d.doc_status_ref_id = rf.doc_status_ref_id
                                   AND rf.brief != 'CANCEL')
         AND pl.policy_id = pd.p_policy_id
         AND ph.fund_id = fd.fund_id
         AND pl.decline_reason_id = dr.t_decline_reason_id(+);
    
    EXCEPTION
      WHEN no_data_found THEN
        pkg_forms_message.put_message('�� ������� ������ �����������! ������ ����������� ������ ���� ���������� �� ��������� � ������ ��������������!');
        raise_application_error(-20401
                               ,'�� ������� ������ �����������! ������ ����������� ������ ���� ���������� �� ��������� � ������ ��������������!');
    END;
  
    IF v_is_full_recover = 1
       AND v_return_sum > 0
       AND v_issuer_return_date IS NOT NULL
    THEN
      SELECT ROUND(nvl(SUM(cd.add_invest_income), 0) * 0.13
                  ,CASE v_fund_brief
                     WHEN 'RUR' THEN
                      0
                     ELSE
                      2
                   END)
        INTO v_ndfl
        FROM p_cover_decline cd
       WHERE cd.p_pol_decline_id = v_pol_decline_id;
      IF v_return_sum != v_ndfl
      THEN
        v_can_recover3 := 0;
      END IF;
    END IF;
  
    IF v_is_full_recover = 1
       AND v_other_pol_sum > 0
    THEN
      v_can_recover5 := 0;
    END IF;
  
    IF v_is_full_recover = 0
    THEN
      DECLARE
        v_return_summ_opt NUMBER;
        v_current_sum_opt NUMBER;
      BEGIN
        WITH tbl_sums AS
         (SELECT nvl(SUM(CASE
                           WHEN plt.brief = 'OPTIONAL'
                                AND (pl.brief != 'ADMIN_EXPENCES' OR pl.brief IS NULL) THEN
                            cd.redemption_sum
                         END)
                    ,0) AS redemption_sum_opt -- �����
                ,nvl(SUM(CASE
                           WHEN plt.brief = 'OPTIONAL'
                                AND (pl.brief != 'ADMIN_EXPENCES' OR pl.brief IS NULL) THEN
                            cd.add_invest_income
                         END)
                    ,0) AS add_invest_income_opt -- ������
                ,nvl(SUM(CASE
                           WHEN plt.brief = 'OPTIONAL'
                                AND (pl.brief != 'ADMIN_EXPENCES' OR pl.brief IS NULL) THEN
                            cd.return_bonus_part
                         END)
                    ,0) AS return_bonus_part_opt -- ������
                ,ROUND(nvl(SUM(CASE
                                 WHEN plt.brief = 'OPTIONAL'
                                      AND (pl.brief != 'ADMIN_EXPENCES' OR pl.brief IS NULL) THEN
                                  cd.add_invest_income
                               END)
                          ,0) * 0.13
                      ,CASE v_fund_brief
                         WHEN 'RUR' THEN
                          0
                         ELSE
                          2
                       END) AS ndfl_opt -- �������
                ,nvl(pp.debt_summ, 0) AS debt_summ -- ���������
                ,ROUND(nvl(SUM(cd.add_invest_income), 0) * 0.13
                      ,CASE v_fund_brief
                         WHEN 'RUR' THEN
                          0
                         ELSE
                          2
                       END) AS ndfl -- ����
            FROM p_policy            pp
                ,p_pol_decline       pd
                ,p_cover_decline     cd
                ,t_product_line      pl
                ,t_product_line_type plt
           WHERE pp.policy_id = v_quit_version_id
             AND pp.policy_id = pd.p_policy_id
             AND pd.p_pol_decline_id = cd.p_pol_decline_id
             AND cd.t_product_line_id = pl.id
             AND pl.product_line_type_id = plt.product_line_type_id
           GROUP BY pp.debt_summ
                   ,pp.return_summ)
        
        SELECT (sm.redemption_sum_opt + sm.add_invest_income_opt + sm.return_bonus_part_opt -
               sm.ndfl_opt) AS return_summ -- ��
              ,(sm.redemption_sum_opt + sm.add_invest_income_opt + sm.return_bonus_part_opt) * CASE
                 WHEN sm.redemption_sum_opt + sm.add_invest_income_opt + sm.return_bonus_part_opt = 0 THEN
                  0
                 ELSE
                  sm.debt_summ /
                  (sm.redemption_sum_opt + sm.add_invest_income_opt + sm.return_bonus_part_opt)
               END AS current_sum -- ���
              ,sm.ndfl
          INTO v_return_summ_opt
              ,v_current_sum_opt
              ,v_ndfl
          FROM tbl_sums sm;
        IF v_return_summ_opt - v_current_sum_opt - v_other_pol_sum >= 0
           AND v_issuer_return_date IS NULL
           AND v_other_pol_sum != 0
        THEN
          v_can_recover6 := 1;
        END IF;
        IF v_return_summ_opt - v_current_sum_opt - v_other_pol_sum - (v_return_summ - v_other_pol_sum) >= 0
           AND v_issuer_return_date IS NOT NULL
           AND v_other_pol_sum != 0
        THEN
          v_can_recover6 := 1;
        END IF;
        IF v_return_summ = v_ndfl
           AND v_issuer_return_date IS NOT NULL
           AND v_other_pol_sum = 0
        THEN
          v_can_recover6 := 1;
        END IF;
        IF v_return_summ <= v_return_summ_opt
           AND v_issuer_return_date IS NOT NULL
           AND v_other_pol_sum = 0
        THEN
          v_can_recover6 := 1;
        END IF;
        IF v_other_pol_sum = 0
           AND v_issuer_return_date IS NULL
        THEN
          v_can_recover6 := 1;
        END IF;
        IF v_other_pol_sum = 0
           AND v_return_summ = 0
           AND v_issuer_return_date IS NOT NULL
        THEN
          v_can_recover6 := 1;
        END IF;
      END;
    ELSE
      v_can_recover6 := 1;
    END IF;
  
    CASE
      WHEN (SYSDATE > v_active_ver_end_date)
           AND safety.check_right_custom('RECOVER_STOPED_POLICY') = 0 THEN
        v_can_recover7 := 0;
      ELSE
        v_can_recover7 := 1;
    END CASE;
  
    IF v_is_wrongful_recover = 0
    THEN
      v_can_recover8 := 1;
    ELSE
      v_prev_policy := get_prev_policy(par_policy_id);
    
      SELECT COUNT(1)
        INTO v_cnt
        FROM dual
       WHERE EXISTS (SELECT NULL
                FROM doc_doc        dd
                    ,ac_payment     ap
                    ,document       doc
                    ,doc_templ      dt
                    ,doc_status     ds
                    ,doc_status_ref dsr
               WHERE dd.parent_id = v_prev_policy
                 AND dd.child_id = ap.payment_id
                 AND ap.payment_id = doc.document_id
                 AND doc.doc_templ_id = dt.doc_templ_id
                 AND dt.brief = 'PAYMENT_SETOFF'
                 AND doc.document_id = ds.document_id
                 AND ds.doc_status_ref_id = dsr.doc_status_ref_id
                 AND dsr.brief NOT IN ('ANNULATED'));
      IF v_cnt = 0
      THEN
        v_can_recover8 := 1;
      ELSE
        v_can_recover8 := 0;
      END IF;
    END IF;
  
    -- 1.
    IF v_can_recover1 = 0
    THEN
      pkg_forms_message.put_message('��������! ����������� �������������, �������� ������� ������ ������ � ����� ��������� "�������������� (������������� �����������)"!');
      raise_application_error(-20401
                             ,'��������! ����������� �������������, �������� ������� ������ ������ � ����� ��������� "�������������� (������������� �����������)"!');
    END IF;
    -- 2.
    IF v_can_recover2 = 0
    THEN
      pkg_forms_message.put_message('������� ����������� ����������. �������������� �� �������������!');
      raise_application_error(-20401
                             ,'������� ����������� ����������. �������������� �� �������������!');
    END IF;
    -- 3.
    IF v_can_recover3 = 0
    THEN
      pkg_forms_message.put_message('���� ������� ��� �����������. �������������� ����������.');
      raise_application_error(-20401
                             ,'���� ������� ��� �����������. �������������� ����������.');
    END IF;
    -- 4.
    IF v_can_recover4 = 0
    THEN
      pkg_forms_message.put_message('�������� �������������� ������ ����� ��������!');
      raise_application_error(-20401
                             ,'�������� �������������� ������ ����� ��������!');
    END IF;
    -- 5.
    IF v_can_recover5 = 0
    THEN
      pkg_forms_message.put_message('���� �������� �� ������ ������� ��� �����������. �������������� ����������.');
      raise_application_error(-20401
                             ,'���� �������� �� ������ ������� ��� �����������. �������������� ����������.');
    END IF;
    -- 6.
    IF v_can_recover6 = 0
    THEN
      pkg_forms_message.put_message('���� �������/����� ������� �� �������� ���������. �������������� ����������');
      raise_application_error(-20401
                             ,'���� �������/����� ������� �� �������� ���������. �������������� ����������');
    END IF;
    -- 7.
    IF v_can_recover7 = 0
    THEN
      pkg_forms_message.put_message('��������! � ����� ���� ������������ ���� �� �������������� ������������ ��������');
      raise_application_error(-20401
                             ,'��������! � ����� ���� ������������ ���� �� �������������� ������������ ��������');
    END IF;
    -- 8.
    IF v_can_recover8 = 0
    THEN
      pkg_forms_message.put_message('��������! ���� ���������������� ������������ �� ����������� �������� ������. �������������� ����������');
      raise_application_error(-20401
                             ,'��������! ���� ���������������� ������������ �� ����������� �������� ������. �������������� ����������');
    END IF;
  END check_recover_version;

  /*
    ������ �.
    ������������� �������� �� �����������, ��� �������� ������ �������������� � ������ "�����������"
  */
  PROCEDURE storno_quit_trans(par_policy_id NUMBER) IS
    v_pol_header_id     NUMBER;
    v_current_vernum    NUMBER;
    v_quit_version_id   NUMBER;
    v_storno_oper_id    NUMBER;
    v_addendum_brief    t_addendum_type.brief%TYPE;
    v_storno_date       DATE;
    v_storno_coeff      NUMBER;
    vr_summs            SYS_REFCURSOR;
    vr_last_summs       SYS_REFCURSOR;
    v_return_sum        NUMBER;
    v_trans_amount      NUMBER;
    v_acc_amount        NUMBER;
    v_trans_amount_sum  NUMBER;
    v_acc_amount_sum    NUMBER;
    v_is_last_row       NUMBER(1);
    v_fund_brief        fund.brief%TYPE;
    v_other_pol_sum     p_pol_decline.other_pol_sum%TYPE;
    v_pol_decline_id    p_pol_decline.p_pol_decline_id%TYPE;
    v_add_invest_income p_cover_decline.add_invest_income%TYPE;
  BEGIN
    -- �������� id ���������, ������� ����� ������ � ��� ���������
    SELECT pp.pol_header_id
          ,pp.version_num
          ,tt.brief
      INTO v_pol_header_id
          ,v_current_vernum
          ,v_addendum_brief
      FROM p_policy            pp
          ,p_pol_addendum_type tp
          ,t_addendum_type     tt
     WHERE pp.policy_id = par_policy_id
       AND pp.policy_id = tp.p_policy_id
       AND tp.t_addendum_type_id = tt.t_addendum_type_id
       AND tt.brief IN ('FULL_POLICY_RECOVER', 'RECOVER_MAIN', 'WRONGFUL_TERM_POLICY_RECOVER')
          -- ��� ��������� ����� ���� ������ ��������� ���
       AND rownum = 1;
    -- ������� ���������� ������ �����������
    BEGIN
      SELECT pp.policy_id
            ,pp.return_summ
            ,fd.brief
            ,nvl(pd.other_pol_sum, 0)
            ,pd.p_pol_decline_id
        INTO v_quit_version_id
            ,v_return_sum
            ,v_fund_brief
            ,v_other_pol_sum
            ,v_pol_decline_id
        FROM p_policy       pp
            ,p_pol_header   ph
            ,fund           fd
            ,p_pol_decline  pd
            ,document       dc
            ,doc_status_ref dsr
       WHERE ph.policy_header_id = v_pol_header_id
         AND ph.policy_header_id = pp.pol_header_id
         AND pp.version_num = v_current_vernum - 1
         AND ph.fund_id = fd.fund_id
         AND pp.policy_id = pd.p_policy_id
         AND pp.policy_id = dc.document_id
         AND dc.doc_status_ref_id = dsr.doc_status_ref_id
         AND dsr.brief IN ('QUIT', 'QUIT_REQ_QUERY', 'QUIT_REQ_GET', 'QUIT_TO_PAY');
      --and doc.get_doc_status_brief(pp.policy_id) in ('QUIT','QUIT_REQ_QUERY','QUIT_REQ_GET','QUIT_TO_PAY');
      -- �������� ����, �� ������� ����������� ������������ ��������
      SELECT ds.start_date
        INTO v_storno_date
        FROM doc_status ds
       WHERE ds.doc_status_id =
             (SELECT dc.doc_status_id FROM document dc WHERE dc.document_id = par_policy_id);
      -- �������� �� ������� "��������� �� ��������" ������������ ������ � ���
      FOR vr_trans IN (SELECT op.oper_id
                         FROM oper        op
                             ,trans       tr
                             ,trans_templ tt
                        WHERE op.document_id = v_quit_version_id
                          AND op.oper_id = tr.oper_id
                          AND tr.trans_templ_id = tt.trans_templ_id
                          AND tt.brief = 'QUIT_MAIN_17')
      LOOP
        acc_new.storno_trans(vr_trans.oper_id);
      END LOOP;
      -- ���� �������� ���� "���������" =0,
      -- �������� �� ������� "������� ������� ���� 2" ������������ ��������������� ���
      -- ���� �������� ���� "���������" !=0,
      -- �������� �� ������� "������� ������� ���� 2" ������������ ������� �� ����� ���������, � ����� ��������������� ���
      DECLARE
        v_last_sum     NUMBER;
        v_last_sum_acc NUMBER;
      BEGIN
        OPEN vr_summs FOR
          SELECT mn.oper_id
                ,mn.main_sum
                ,mn.main_sum_acc
                ,mn.last_sum
                ,mn.last_sum_acc
                ,CURSOR (SELECT /*+ LEADING(se co plo pd pc) USE_NL(se co plo) USE_NL(pd pc)*/
                         ROUND((pc.return_bonus_part / SUM(pc.return_bonus_part) over()) *
                               CASE mn.main_sum
                                 WHEN 0 THEN
                                  trans_amount
                                 ELSE
                                  last_sum
                               END
                              ,2) AS trans_amount
                        ,ROUND((pc.return_bonus_part / SUM(pc.return_bonus_part) over()) *
                               CASE mn.main_sum
                                 WHEN 0 THEN
                                  acc_amount
                                 ELSE
                                  last_sum_acc
                               END
                              ,2) AS acc_amount
                        ,CASE
                           WHEN lead(1) over(ORDER BY pc.t_product_line_id) IS NULL THEN
                            1
                           ELSE
                            0
                         END AS last_row
                          FROM p_pol_decline      pd
                              ,p_cover_decline    pc
                              ,as_asset           se
                              ,p_cover            co
                              ,t_prod_line_option plo
                              ,status_hist        sh
                         WHERE pd.p_policy_id = mn.p_policy_id
                           AND pd.p_pol_decline_id = pc.p_pol_decline_id
                           AND se.p_policy_id = par_policy_id
                           AND se.as_asset_id = co.as_asset_id
                           AND co.t_prod_line_option_id = plo.id
                           AND pc.t_product_line_id = plo.product_line_id
                           AND co.status_hist_id = sh.status_hist_id
                           AND sh.brief != 'DELETED'
                           AND pc.return_bonus_part > 0) AS last_sums
            FROM (SELECT op.oper_id
                        ,pd.overpayment AS main_sum_acc
                        ,pd.overpayment * tr.acc_rate AS main_sum
                        ,tr.acc_amount - pd.overpayment AS last_sum_acc
                        ,tr.trans_amount - pd.overpayment * tr.acc_rate AS last_sum
                        ,tr.trans_amount
                        ,tr.acc_amount
                        ,pd.p_policy_id
                    FROM oper          op
                        ,trans         tr
                        ,trans_templ   tt
                        ,p_pol_decline pd
                   WHERE pd.p_policy_id = v_quit_version_id
                     AND op.document_id = pd.p_policy_id
                     AND op.oper_id = tr.oper_id
                     AND tr.trans_templ_id = tt.trans_templ_id
                     AND tt.brief = 'QUIT_MAIN_14') mn;
        LOOP
          FETCH vr_summs
            INTO v_storno_oper_id
                ,v_trans_amount
                ,v_acc_amount
                ,v_last_sum
                ,v_last_sum_acc
                ,vr_last_summs;
          EXIT WHEN vr_summs%NOTFOUND;
          IF v_trans_amount != 0
          THEN
            acc_new.storno_trans(par_oper_id      => v_storno_oper_id
                                ,par_trans_amount => v_trans_amount
                                ,par_acc_amount   => v_acc_amount);
          END IF;
          v_trans_amount_sum := 0;
          v_acc_amount_sum   := 0;
          LOOP
            FETCH vr_last_summs
              INTO v_trans_amount
                  ,v_acc_amount
                  ,v_is_last_row;
            EXIT WHEN vr_last_summs%NOTFOUND;
            -- ����������� ����� ��� �������� �������
            v_trans_amount_sum := v_trans_amount_sum + v_trans_amount;
            v_acc_amount_sum   := v_acc_amount_sum + v_acc_amount;
            -- ���� �������� ��������� ������, ������������
            IF v_is_last_row = 1
            THEN
              v_trans_amount := v_trans_amount + (v_last_sum - v_trans_amount_sum);
              v_acc_amount   := v_acc_amount + (v_last_sum_acc - v_acc_amount_sum);
            END IF;
            -- ��������� ��������
            IF v_trans_amount != 0
            THEN
              acc_new.storno_trans(par_oper_id      => v_storno_oper_id
                                  ,par_trans_amount => v_trans_amount
                                  ,par_acc_amount   => v_acc_amount);
            END IF;
          END LOOP;
          CLOSE vr_last_summs;
        END LOOP;
        CLOSE vr_summs;
      END;
      -- ���������� ��������, ������� ���������� ������������, ��������� � ��������� �������
      FOR vr_trans IN (SELECT op.oper_id
                             ,tr.trans_id
                         FROM oper               op
                             ,trans              tr
                             ,trans_templ        tt
                             ,t_prod_line_option lo
                        WHERE op.document_id = v_quit_version_id
                          AND op.oper_id = tr.oper_id
                          AND tr.trans_templ_id = tt.trans_templ_id
                          AND tt.brief IN ('QUIT_MAIN_1'
                                          ,'QUIT_MAIN_2'
                                          ,'QUIT_MAIN_3'
                                          ,'QUIT_MAIN_4'
                                          ,'QUIT_MAIN_5'
                                          ,'QUIT_MAIN_6'
                                          ,'QUIT_MAIN_7'
                                          ,'QUIT_MAIN_8'
                                          ,'QUIT_MAIN_9'
                                          ,'QUIT_MAIN_11'
                                          ,'QUIT_MAIN_12'
                                          ,'QUIT_MAIN_13' /*,'QUIT_MAIN_14'*/
                                          ,'QUIT_MAIN_16' /*,'QUIT_MAIN_17'*/
                                          ,'QUIT_MAIN_5_ANNUL'
                                          ,'QUIT_MAIN_18'
                                          ,'QUIT_MAIN_19')
                          AND tr.a4_dt_ure_id = 310
                          AND tr.a4_dt_uro_id = lo.id
                          AND lo.product_line_id IN
                              (SELECT /*+ LEADING(se co plo pd pc) USE_NL(se co plo) USE_NL(pd pc)*/
                                plo.product_line_id
                                 FROM p_pol_decline      pd
                                     ,p_cover_decline    pc
                                     ,as_asset           se
                                     ,p_cover            co
                                     ,t_prod_line_option plo
                                     ,status_hist        sh
                                WHERE pd.p_policy_id = op.document_id
                                  AND pd.p_pol_decline_id = pc.p_pol_decline_id
                                  AND se.p_policy_id = par_policy_id
                                  AND se.as_asset_id = co.as_asset_id
                                  AND co.t_prod_line_option_id = plo.id
                                  AND pc.t_product_line_id = plo.product_line_id
                                  AND co.status_hist_id = sh.status_hist_id
                                  AND sh.brief != 'DELETED'))
      LOOP
        acc_new.storno_trans(par_oper_id => vr_trans.oper_id);
      END LOOP;
      -- ���� �� ��������� ��� ���������
      FOR vr_trans IN (SELECT op.oper_id
                             ,tt.brief
                             ,tr.trans_amount
                             ,tr.acc_amount
                         FROM oper        op
                             ,trans       tr
                             ,trans_templ tt
                        WHERE op.document_id = v_quit_version_id
                          AND op.oper_id = tr.oper_id
                          AND tr.trans_templ_id = tt.trans_templ_id
                          AND tt.brief IN ('QUIT_MAIN_9'
                                          ,'QUIT_MAIN_10'
                                          ,'QUIT_MAIN_11'
                                          ,'QUIT_MAIN_12'
                                          ,'QUIT_MAIN_13' /*,'QUIT_MAIN_14'*/
                                          ,'QUIT_MAIN_18')
                          AND tr.a4_dt_ure_id = 310
                          AND tr.a4_dt_uro_id IS NULL)
      LOOP
        IF v_addendum_brief IN ('FULL_POLICY_RECOVER', 'WRONGFUL_TERM_POLICY_RECOVER')
        THEN
          acc_new.storno_trans(par_oper_id => vr_trans.oper_id);
        ELSE
          IF vr_trans.brief = 'QUIT_MAIN_13'
          THEN
            /* QUIT_MAIN_13 1. ��������������� ���, ���� ����� ������ ����� ����� ��� � ��� �� ����� ����
                               ��� ������(0,13*���;0) ��� ��������� � ������� RUR,
                               ��� ������(0,13*���;2) ��� ��������� � ������� �� RUR
                            2. ��������������� ��+���, �� ���� ��������� �������
            */
          
            SELECT nvl(SUM(cd.add_invest_income), 0)
              INTO v_add_invest_income
              FROM p_cover_decline cd
             WHERE cd.p_pol_decline_id = v_pol_decline_id;
            -- ����� �� ����� ����� ���? ���� ���, ����������� ��� � ����
            IF v_other_pol_sum != v_add_invest_income
               AND v_add_invest_income != 0
            THEN
              v_add_invest_income := ROUND(v_add_invest_income * 0.13
                                          ,CASE v_fund_brief
                                           
                                             WHEN 'RUR' THEN
                                              0
                                             ELSE
                                              2
                                           END);
            END IF;
            -- ���������� ���/����
            IF v_other_pol_sum = v_add_invest_income
               AND v_add_invest_income != 0
            THEN
              OPEN vr_summs FOR
                SELECT nvl(CASE
                             WHEN pp.product_line_id IS NOT NULL THEN
                              nvl(cd.add_invest_income, 0)
                           END / SUM(cd.add_invest_income) over()
                          ,0)
                      ,CASE
                         WHEN lead(1) over(ORDER BY cd.t_product_line_id) IS NULL THEN
                          1
                         ELSE
                          0
                       END AS last_row
                  FROM p_pol_decline pd
                      ,p_cover_decline cd
                      ,(SELECT plo.product_line_id
                          FROM as_asset           se
                              ,p_cover            co
                              ,t_prod_line_option plo
                              ,status_hist        sh
                         WHERE se.p_policy_id = par_policy_id
                           AND se.as_asset_id = co.as_asset_id
                           AND co.t_prod_line_option_id = plo.id
                           AND co.status_hist_id = sh.status_hist_id
                           AND sh.brief != 'DELETED') pp
                 WHERE pd.p_policy_id = v_quit_version_id
                   AND pd.p_pol_decline_id = cd.p_pol_decline_id
                   AND cd.add_invest_income > 0
                   AND cd.t_product_line_id = pp.product_line_id(+);
            ELSE
              OPEN vr_summs FOR
                SELECT nvl(CASE
                             WHEN pp.product_line_id IS NOT NULL THEN
                              (nvl(cd.add_invest_income, 0) + nvl(cd.redemption_sum, 0))
                           END / SUM(nvl(cd.add_invest_income, 0) + cd.redemption_sum) over()
                          ,0)
                      ,CASE
                         WHEN lead(1) over(ORDER BY cd.t_product_line_id) IS NULL THEN
                          1
                         ELSE
                          0
                       END AS last_row
                  FROM p_pol_decline pd
                      ,p_cover_decline cd
                      ,(SELECT plo.product_line_id
                          FROM as_asset           se
                              ,p_cover            co
                              ,t_prod_line_option plo
                              ,status_hist        sh
                         WHERE se.p_policy_id = par_policy_id
                           AND se.as_asset_id = co.as_asset_id
                           AND co.t_prod_line_option_id = plo.id
                           AND co.status_hist_id = sh.status_hist_id
                           AND sh.brief != 'DELETED') pp
                 WHERE pd.p_policy_id = v_quit_version_id
                   AND pd.p_pol_decline_id = cd.p_pol_decline_id
                   AND (cd.add_invest_income > 0 OR cd.redemption_sum > 0)
                   AND cd.t_product_line_id = pp.product_line_id(+);
            END IF;
          ELSIF vr_trans.brief IN ('QUIT_MAIN_10', 'QUIT_MAIN_12', 'QUIT_MAIN_18')
          THEN
            /* QUIT_MAIN_10, QUIT_MAIN_12, QUIT_MAIN_18 ��������������� ��� */
            OPEN vr_summs FOR
              SELECT nvl(CASE
                           WHEN pp.product_line_id IS NOT NULL THEN
                            nvl(cd.add_invest_income, 0)
                         END / SUM(cd.add_invest_income) over()
                        ,0)
                    ,CASE
                       WHEN lead(1) over(ORDER BY cd.t_product_line_id) IS NULL THEN
                        1
                       ELSE
                        0
                     END AS last_row
                FROM p_pol_decline pd
                    ,p_cover_decline cd
                    ,(SELECT plo.product_line_id
                        FROM as_asset           se
                            ,p_cover            co
                            ,t_prod_line_option plo
                            ,status_hist        sh
                       WHERE se.p_policy_id = par_policy_id
                         AND se.as_asset_id = co.as_asset_id
                         AND co.t_prod_line_option_id = plo.id
                         AND co.status_hist_id = sh.status_hist_id
                         AND sh.brief != 'DELETED') pp
               WHERE pd.p_policy_id = v_quit_version_id
                 AND pd.p_pol_decline_id = cd.p_pol_decline_id
                 AND cd.add_invest_income > 0
                 AND cd.t_product_line_id = pp.product_line_id(+);
          ELSIF vr_trans.brief = 'QUIT_MAIN_11' /*,'QUIT_MAIN_14'*/
          THEN
            /* QUIT_MAIN_11, QUIT_MAIN_14 ��������������� �������� ����� ������ */
            OPEN vr_summs FOR
              SELECT nvl(CASE
                           WHEN pp.product_line_id IS NOT NULL THEN
                            nvl(cd.return_bonus_part, 0)
                         END / SUM(cd.return_bonus_part) over()
                        ,0)
                    ,CASE
                       WHEN lead(1) over(ORDER BY cd.t_product_line_id) IS NULL THEN
                        1
                       ELSE
                        0
                     END AS last_row
                FROM p_pol_decline pd
                    ,p_cover_decline cd
                    ,(SELECT plo.product_line_id
                        FROM as_asset           se
                            ,p_cover            co
                            ,t_prod_line_option plo
                            ,status_hist        sh
                       WHERE se.p_policy_id = par_policy_id
                         AND se.as_asset_id = co.as_asset_id
                         AND co.t_prod_line_option_id = plo.id
                         AND co.status_hist_id = sh.status_hist_id
                         AND sh.brief != 'DELETED') pp
               WHERE pd.p_policy_id = v_quit_version_id
                 AND pd.p_pol_decline_id = cd.p_pol_decline_id
                 AND cd.return_bonus_part > 0
                 AND cd.t_product_line_id = pp.product_line_id(+);
          
          ELSIF vr_trans.brief = 'QUIT_MAIN_9'
          THEN
            /* QUIT_MAIN_9 ��������������� �� */
            OPEN vr_summs FOR
              SELECT nvl(CASE
                           WHEN pp.product_line_id IS NOT NULL THEN
                            cd.redemption_sum
                           ELSE
                            0
                         END / SUM(cd.redemption_sum) over()
                        ,0)
                    ,CASE
                       WHEN lead(1) over(ORDER BY cd.t_product_line_id) IS NULL THEN
                        1
                       ELSE
                        0
                     END AS last_row
                FROM p_pol_decline pd
                    ,p_cover_decline cd
                    ,(SELECT plo.product_line_id
                        FROM as_asset           se
                            ,p_cover            co
                            ,t_prod_line_option plo
                            ,status_hist        sh
                       WHERE se.p_policy_id = par_policy_id
                         AND se.as_asset_id = co.as_asset_id
                         AND co.t_prod_line_option_id = plo.id
                         AND co.status_hist_id = sh.status_hist_id
                         AND sh.brief != 'DELETED') pp
               WHERE pd.p_policy_id = v_quit_version_id
                 AND pd.p_pol_decline_id = cd.p_pol_decline_id
                 AND cd.redemption_sum > 0
                 AND cd.t_product_line_id = pp.product_line_id(+);
          END IF;
          IF vr_summs%ISOPEN
          THEN
            v_trans_amount_sum := 0;
            v_acc_amount_sum   := 0;
            LOOP
              FETCH vr_summs
                INTO v_storno_coeff
                    ,v_is_last_row;
              EXIT WHEN vr_summs%NOTFOUND;
              -- ������������
              v_trans_amount := ROUND(v_storno_coeff * vr_trans.trans_amount, 2);
              v_acc_amount   := ROUND(v_storno_coeff * vr_trans.acc_amount, 2);
              -- ����������� ����� ��� �������� �������
              v_trans_amount_sum := v_trans_amount_sum + v_trans_amount;
              v_acc_amount_sum   := v_acc_amount_sum + v_acc_amount;
              -- ���� �������� ��������� ������, ������������
              IF v_is_last_row = 1
              THEN
                v_trans_amount := v_trans_amount + (vr_trans.trans_amount - v_trans_amount_sum);
                v_acc_amount   := v_acc_amount + (vr_trans.acc_amount - v_acc_amount_sum);
              END IF;
              IF v_storno_coeff != 0
              THEN
                acc_new.storno_trans(par_oper_id      => vr_trans.oper_id
                                    ,par_trans_amount => v_trans_amount
                                    ,par_acc_amount   => v_acc_amount);
              END IF;
            END LOOP;
            CLOSE vr_summs;
          END IF;
        END IF;
      END LOOP;
      -- ���� �� ����� ������ �����������, ���� ����������
    EXCEPTION
      WHEN no_data_found THEN
        NULL;
    END;
    -- ���� ��� �� ��������������, ����������
  EXCEPTION
    WHEN no_data_found THEN
      NULL;
  END storno_quit_trans;

  /*
    ������ �.
    ������ ������������� �������� �� �����������, ��� �������� ������ �������������� �� ������� "�����������" �������
  */
  PROCEDURE unstorno_quit_trans(par_policy_id NUMBER) IS
    --    v_storno_oper    NUMBER;
    v_addendum_brief t_addendum_type.brief%TYPE;
  BEGIN
    -- ������ �.
    -- �������� id ���������, ������� ����� ������ � ��� ���������
    SELECT tt.brief
      INTO v_addendum_brief
      FROM p_pol_addendum_type tp
          ,t_addendum_type     tt
     WHERE tp.p_policy_id = par_policy_id
       AND tp.t_addendum_type_id = tt.t_addendum_type_id
       AND tt.brief IN ('FULL_POLICY_RECOVER', 'RECOVER_MAIN', 'WRONGFUL_TERM_POLICY_RECOVER')
          -- ��� ��������� ����� ���� ������ ��������� ���
       AND rownum = 1;
    -- ���������� ��������, ������� ���������� ������������, ��������� � ��������� �������
    FOR vr_trans IN ( -- ��������, ����������� � ������
                     SELECT op.oper_id
                       FROM oper        op
                            ,trans       tr
                            ,trans_templ tt
                      WHERE op.document_id = par_policy_id
                        AND op.oper_id = tr.oper_id
                        AND tr.trans_templ_id = tt.trans_templ_id
                        AND op.doc_status_id =
                            (SELECT MAX(dss.doc_status_id)
                               FROM doc_status     dss
                                   ,doc_status_ref dsr
                              WHERE dss.document_id = par_policy_id
                                AND dss.doc_status_ref_id = dsr.doc_status_ref_id
                                AND dsr.brief = 'CURRENT'
                                AND dss.src_doc_status_ref_id IN
                                    (SELECT dr.doc_status_ref_id
                                       FROM doc_status_ref dr
                                      WHERE dr.brief IN ('NEW', 'ACTIVE', 'CONCLUDED')))
                        AND tt.brief IN ('QUIT_MAIN_1'
                                        ,'QUIT_MAIN_2'
                                        ,'QUIT_MAIN_3'
                                        ,'QUIT_MAIN_4'
                                        ,'QUIT_MAIN_5'
                                        ,'QUIT_MAIN_6'
                                        ,'QUIT_MAIN_7'
                                        ,'QUIT_MAIN_8'
                                        ,'QUIT_MAIN_12'
                                        ,'QUIT_MAIN_13'
                                        ,'QUIT_MAIN_14'
                                        ,'QUIT_MAIN_16'
                                        ,'QUIT_MAIN_17'
                                        ,'QUIT_MAIN_5_ANNUL'
                                        ,'QUIT_MAIN_18'
                                        ,'QUIT_MAIN_19'))
    LOOP
      BEGIN
        -- ������� �������
        DELETE FROM ven_oper op WHERE op.oper_id = vr_trans.oper_id;
      EXCEPTION
        WHEN pkg_payment.v_closed_period_exception THEN
          acc_new.storno_trans(par_oper_id => vr_trans.oper_id);
      END;
    END LOOP vr_trans;
  EXCEPTION
    WHEN no_data_found THEN
      NULL;
  END unstorno_quit_trans;

  -- ������ 148724.
  --���������
  /*   �������� ���������, ������� ��� �������� ������ �������� � ����� 
  ��������� "�������������� ����� ��������"/"�������������� ��������
  ���������"  �  ������  "�����"  ���������    ������  ��  ��������:
  14013 ������ ������������� ��������*/

  /*
  ����������� �.  
  332603 ������� �� ������ �������������
  
  ������ ������ 14013 ������ ������������� ��������
  �� ���������������� ������ � ����������� �� ������ ������
  */

  PROCEDURE set_trade_escort_agent(par_policy_id NUMBER) IS
    v_start_date DATE;
    v_end_date   DATE;
    -- v_date_decline DATE;
    v_pol_header   p_pol_header.policy_header_id%TYPE;
    v_vernum       p_policy.version_num%TYPE;
    v_is_recovery  NUMBER(1) := 1;
    v_date_pr      DATE;
    v_agent_doc_id p_policy_agent_doc.p_policy_agent_doc_id%TYPE;
    v_ach          p_policy_agent_doc.ag_contract_header_id%TYPE;
    v_ach_curr     p_policy_agent_doc.ag_contract_header_id%TYPE;
    v_begin_date   DATE;
    v_channel      t_sales_channel.brief%TYPE;
    v_num_ach      document.num%TYPE;
    v_name_ach     contact.obj_name_orig%TYPE;
  BEGIN
    IF NOT (get_pol_addendum_type(par_policy_id) = 'WRONGFUL_TERM_POLICY_RECOVER')
    THEN
      BEGIN
        -- ��������� ����� ������� ������ ���� ������� ��������������
        SELECT pp.version_num
              ,pp.start_date
              ,pp.end_date
              ,pp.pol_header_id
              ,tsc.brief
          INTO v_vernum
              ,v_start_date
              ,v_end_date
              ,v_pol_header
              ,v_channel
          FROM ins.p_pol_addendum_type ppat
              ,ins.t_addendum_type     tat
              ,ins.p_policy            pp
              ,ins.p_pol_header        ph
              ,ins.t_sales_channel     tsc
         WHERE ppat.p_policy_id = par_policy_id
           AND ph.policy_header_id = pp.pol_header_id
           AND ph.sales_channel_id = tsc.id
           AND ppat.t_addendum_type_id = tat.t_addendum_type_id
           AND pp.policy_id = ppat.p_policy_id
           AND tsc.brief NOT IN ('RLA' --������ 208471.
                                ,'BR_WDISC') --������ 242540.
           AND tat.brief IN ('FULL_POLICY_RECOVER', 'RECOVER_MAIN')
           AND rownum = 1;
      EXCEPTION
        WHEN no_data_found THEN
          v_is_recovery := 0;
      END;
    
      --��������� ������� ������ 14013 ������ ������������� ��������
      BEGIN
        IF v_channel = 'BANK'
        THEN
          v_num_ach  := 53055;
          v_name_ach := '������ ������������� �������� (����������)';
        ELSIF v_channel = 'BR'
        THEN
          v_num_ach  := 53057;
          v_name_ach := '������ ������������� �������� (����������)';
        ELSIF v_channel = 'CORPORATE'
        THEN
          v_num_ach  := 53060;
          v_name_ach := '������ ������������� �������� (�������������)';
        ELSE
          v_num_ach  := 14013;
          v_name_ach := '������ ������������� ��������';
        END IF;
      
        SELECT ach.ag_contract_header_id
          INTO v_ach
          FROM ins.ven_ag_contract_header ach
              ,ins.contact                cn
         WHERE cn.contact_id = ach.agent_id
           AND cn.obj_name_orig = v_name_ach --'������ ������������� ��������'
           AND ach.num = v_num_ach; --'14013';
      EXCEPTION
        WHEN no_data_found THEN
          --        pkg_forms_message.put_message('�� ������ ����� 14013 ������ ������������� ��������');
          pkg_forms_message.put_message('�� ������ ����� ' || to_char(v_num_ach) || ' ' || v_name_ach);
          raise_application_error(-20001
                                 ,'�� ������ ����� ' || to_char(v_num_ach) || ' ' || v_name_ach);
      END;
      --�������� ��� ���������� ������ �������� ������� �����������
      --��������� ��������� ������ �� ������ �����������
    
      BEGIN
        SELECT pp.start_date /*, pp.decline_date*/
          INTO v_date_pr /*, v_date_decline*/
          FROM p_policy              pp
              ,p_pol_decline         pd
              ,ven_t_illegal_decline vtid
         WHERE pd.p_policy_id = pp.policy_id
           AND vtid.t_illegal_decline_id(+) = pd.t_illegal_decline_id
           AND vtid.description IS NULL
           AND pp.pol_header_id = v_pol_header
           AND pp.version_num IN (SELECT MAX(pp2.version_num)
                                    FROM p_policy           pp2
                                        ,p_pol_decline      pd2
                                        ,ins.document       d
                                        ,ins.doc_status_ref rf
                                   WHERE pp2.pol_header_id = v_pol_header
                                     AND pd2.p_policy_id = pp2.policy_id
                                     AND pp2.version_num < v_vernum
                                     AND pp2.policy_id = d.document_id
                                     AND d.doc_status_ref_id = rf.doc_status_ref_id
                                     AND rf.brief != 'CANCEL');
      EXCEPTION
        WHEN no_data_found THEN
          v_is_recovery := 0;
      END;
    
      IF v_is_recovery = 1 /*AND v_start_date>=v_date_pr*/
      THEN
        --���� � �������� ������, ������� ��������� � ������� ����������� � ��������� ��� � ������ �������
        SELECT pad.p_policy_agent_doc_id
              ,pad.ag_contract_header_id
          INTO v_agent_doc_id
              ,v_ach_curr
          FROM ven_p_policy_agent_doc pad
              ,document               dc
              ,doc_status_ref         dsr
         WHERE dc.document_id = pad.p_policy_agent_doc_id
           AND dsr.doc_status_ref_id = dc.doc_status_ref_id
           AND pad.policy_header_id = v_pol_header
           AND dsr.brief = 'CURRENT';
      
        IF v_ach_curr != v_ach --���� ������� ����� �� �������� ��� 14013 ������ ������������� ��������
        THEN
          UPDATE ven_p_policy_agent_doc ppad
             SET ppad.date_end = trunc(SYSDATE) - (1 / 24 / 60 / 60)
           WHERE ppad.p_policy_agent_doc_id = v_agent_doc_id;
          doc.set_doc_status(p_doc_id       => v_agent_doc_id
                            ,p_status_brief => 'CANCEL'
                            ,p_note         => '�������� ��� ��������������');
        
          --/������/292932: FW: ������ ��� �������� � ������ "�����" ��� 
          --����������� ���� ������ �������� ������ ������ ������������� �������� (���)
          IF v_end_date >= trunc(SYSDATE)
          THEN
            v_begin_date := trunc(SYSDATE);
          ELSE
            --������������������� ������ ����������� � �������� ���� ����������� ��� ���� ������ ���
            BEGIN
              SELECT decline_date
                INTO v_begin_date
                FROM (SELECT pp.start_date
                            ,pp.version_num
                            ,pp.decline_date
                        FROM ins.p_pol_header   ph
                            ,ins.ven_p_policy   pp
                            ,ins.doc_status_ref dsr
                       WHERE ph.policy_header_id = pp.pol_header_id
                         AND pp.doc_status_ref_id = dsr.doc_status_ref_id
                         AND dsr.brief IN ('QUIT' --���������
                                          ,'QUIT_REQ_QUERY' --���������. ������ ����������
                                          ,'QUIT_REQ_GET' --���������. ��������� ��������
                                          ,'QUIT_TO_PAY' --���������.� �������
                                           )
                         AND ph.policy_header_id = v_pol_header
                      --AND ph.ids = 1140323885
                       ORDER BY pp.start_date  DESC
                               ,pp.version_num DESC)
               WHERE rownum = 1;
            EXCEPTION
              WHEN no_data_found THEN
                pkg_forms_message.put_message('��������! ������� �� ������ ������������� �� ��������. ���� ��������� ������ ������� ���� � ���� ������������.');
                raise_application_error(-20001
                                       ,'��������! ������� �� ������ ������������� �� ��������. ���� ��������� ������ ������� ���� � ���� ������������.');
            END;
          
          END IF;
          --       
        
          --��������� ������:14013 ������ ������������� ��������    
          SELECT sq_p_policy_agent_doc.nextval INTO v_agent_doc_id FROM dual;
        
          INSERT INTO ven_p_policy_agent_doc
            (p_policy_agent_doc_id
            ,ag_contract_header_id
            ,date_end
            ,date_begin
            ,policy_header_id
            ,doc_templ_id
            ,note)
          VALUES
            (v_agent_doc_id
            ,v_ach --����� 14013 ������ ������������� ��������
            ,v_end_date --���� ��������� �������� �����������
            ,v_begin_date --���� ��������������
            ,v_pol_header
            ,18093
            , --�������� - ����� �� �������� 
             '�������� ��� ��������������');
        
          doc.set_doc_status(v_agent_doc_id, 'NEW');
          doc.set_doc_status(v_agent_doc_id, 'CURRENT');
        END IF;
      END IF;
    END IF;
  END set_trade_escort_agent;

END pkg_policy_renew;
/

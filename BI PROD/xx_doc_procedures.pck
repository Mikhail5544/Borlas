CREATE OR REPLACE PACKAGE XX_DOC_PROCEDURES IS
  /*
      13.04.2009
      ����� ��� ���������� ��������� ��������, ����������� � doc_procedure.
  */

  --��������� ����������� �������� ���������� � �������� ��������� �������.
  PROCEDURE check_closed_period(p_doc_id IN NUMBER);

  --��������� ���������� ����������� �������������� �������� �����������.
  PROCEDURE fill_pol_header_ids(p_policy_id IN NUMBER);

  --��������� ������������ ids, �����, ����� �������� � ��������� �� ������������ BSO
  PROCEDURE correct_pol4bso(p_policy_id IN NUMBER);

  --��������� ������� ids, �����, ����� �������� � ��������� (�������������� ����� ��� �������� ������� �����->������)
  PROCEDURE clear_pol4bso(p_policy_id IN NUMBER);

  --��������� ��������� ��������� ������� �� �������.
  PROCEDURE post_cre_pyment(p_claim_id IN NUMBER);

  --��������� ��������� ����� ����� ������� ������ ���������
  PROCEDURE post_ch_claim_status(p_claim_id IN NUMBER);

  --��������� ������ � �������� ������ �� ���� ������� ���������
  PROCEDURE del_all_claim_setoff(p_claim_id IN NUMBER);

  -- ������ �.
  -- ��������� ����� �������� �������� (������ 151232)
  PROCEDURE set_mailing_flag_on(par_policy_id NUMBER);

END xx_doc_procedures;
/
CREATE OR REPLACE PACKAGE BODY XX_DOC_PROCEDURES IS
  ------------------------------------------------------------------------
  --��������� ����������� �������� ���������� � �������� ��������� �������.
  PROCEDURE check_closed_period(p_doc_id IN NUMBER)
  ------------------------------------------------------------------------
   IS
    v_policy    p_policy%ROWTYPE;
    v_user      VARCHAR2(100);
    v_mess      VARCHAR2(2000);
    v_err_mess  VARCHAR2(2000);
    v_is_closed NUMBER;
  
    FUNCTION is_period_closed(p_date DATE) RETURN NUMBER IS
      v_is_closed NUMBER;
    BEGIN
      BEGIN
        SELECT pc.is_closed
          INTO v_is_closed
          FROM t_period_closed pc
         WHERE p_date BETWEEN pc.period_date AND NVL(pc.close_date, p_date)
           AND ROWNUM = 1;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          NULL;
      END;
    
      RETURN NVL(v_is_closed, -1);
    END is_period_closed;
  
    FUNCTION has_role_user
    (
      p_user      VARCHAR2
     ,p_role_name VARCHAR2
    ) RETURN BOOLEAN IS
      v_count NUMBER := 0;
    BEGIN
      SELECT COUNT(*)
        INTO v_count
        FROM rel_role_user rru
            ,sys_safety    ss
            ,sys_user      su
       WHERE ss.sys_safety_id = rru.sys_role_id
         AND su.sys_user_id = rru.sys_user_id
         AND ss.NAME = p_role_name
         AND su.sys_user_name = UPPER(p_user);
    
      IF v_count > 0
      THEN
        RETURN TRUE;
      ELSE
        RETURN FALSE;
      END IF;
    END has_role_user;
  
    FUNCTION get_current_user RETURN VARCHAR2 IS
      v_user VARCHAR2(100) := USER;
    BEGIN
      IF USER = ents_bi.eul_owner
      THEN
        v_user := NVL(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'), USER);
      END IF;
    
      RETURN v_user;
    END get_current_user;
  BEGIN
    v_user := get_current_user;
    v_mess := 'v_user - ' || v_user;
  
    IF v_user = 'BEL4'
    THEN
      BEGIN
        SELECT * INTO v_policy FROM p_policy p WHERE p.policy_id = p_doc_id;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          v_mess     := v_mess || 'policy_id ' || p_doc_id || 'not found.';
          v_err_mess := '����������� �������� ��� policy_id - ' || p_doc_id;
          RAISE_APPLICATION_ERROR(-20000, v_err_mess);
      END;
    
      v_is_closed := is_period_closed(v_policy.start_date);
      v_mess      := v_mess || ', start_date - ' || v_policy.start_date || ', v_is_closed' ||
                     v_is_closed;
    
      IF v_is_closed = 1
      THEN
        --���� ������ ������
        IF has_role_user(v_user, 'History')
        THEN
          --���� ������������ ����� ���� History
          RAISE_APPLICATION_ERROR(-20000
                                 ,'������������ ' || v_user || ' ������ �������� ���������.');
        ELSE
          v_err_mess := '���� ' || v_policy.start_date || ' ��������� � �������� �������.';
          RAISE_APPLICATION_ERROR(-20000, v_err_mess);
        END IF;
      ELSIF v_is_closed = -1
      THEN
        v_err_mess := '����������� ��������� ������� �� ���� - ' || v_policy.start_date;
        RAISE_APPLICATION_ERROR(-20000, v_err_mess);
      END IF;
    END IF;
  END check_closed_period;

  ------------------------------------------------------------------------
  PROCEDURE fill_pol_header_ids(p_policy_id IN NUMBER)
  ------------------------------------------------------------------------
   IS
    v_bso_id       NUMBER;
    v_num          NUMBER;
    v_is_pol_num   NUMBER;
    v_series_num   NUMBER;
    v_flags        NUMBER;
    v_c            NUMBER;
    v_new_ids      NUMBER;
    v_chars_in_num NUMBER;
  BEGIN
    --IF pkg_policy.is_addendum(p_doc_id) = 1 THEN
    BEGIN
      SELECT *
        INTO v_bso_id
            ,v_num
            ,v_is_pol_num
            ,v_series_num
            ,v_chars_in_num
            ,v_flags
            ,v_c
        FROM (SELECT b.bso_id
                    ,SUBSTR(b.num, 1, 6)
                    ,
                     --��� ����� ����� � ��������� ����������� �������� (���� ���, ����� ����������!)
                     b.is_pol_num
                    ,bs.series_num
                    ,bs.chars_in_num
                    ,SUM(NVL(b.is_pol_num, 0)) OVER() flags
                    ,COUNT(*) OVER() c
                FROM bso               b
                    ,bso_series        bs
                    ,bso_type          bt
                    ,ven_bso_hist      bh
                    ,ven_bso_hist_type bht
               WHERE b.POLICY_ID = p_policy_id
                 AND bs.bso_type_id = bt.bso_type_id
                 AND b.bso_series_id = bs.bso_series_id
                 AND kind_brief IN ('���������', '�����')
                 AND bh.bso_hist_id = b.bso_hist_id
                 AND bh.hist_type_id = bht.bso_hist_type_id
                 AND bht.brief NOT IN ('��������')
               ORDER BY b.is_pol_num DESC)
       WHERE ROWNUM = 1;
    
      --���� ��������� ���� ���� ��� ������ ����� ����
      IF v_c = 1
         OR v_flags = 1
      THEN
        --������������ �������������
        --���� ���� �� ��������� - ��������� ���
        IF NVL(v_is_pol_num, 0) = 0
        THEN
          UPDATE bso SET is_pol_num = 1 WHERE bso_id = v_bso_id;
        END IF;
      
        IF v_chars_in_num = 7
           AND LENGTH(v_num) = 7
        THEN
          v_new_ids := v_series_num || v_num; --��������������, ��� ����� ��� ������������.
        ELSE
          v_new_ids := PKG_XX_POL_IDS.cre_new_ids(v_series_num, v_num);
        END IF;
      
        IF v_new_ids IS NULL
        THEN
          RAISE_APPLICATION_ERROR(-20104
                                 ,'�� ������� ������������ ���������� ������������� �������� �� ��� �' ||
                                  v_num);
        END IF;
      
        UPDATE p_pol_header ph
           SET ph.ids = v_new_ids
         WHERE ph.policy_header_id IN
               (SELECT p.pol_header_id FROM p_policy p WHERE p.policy_id = p_policy_id);
      ELSIF v_c > 1
            AND v_flags = 0
      THEN
        --��������� ����� � �� ������ ����� �� ����������
        RAISE_APPLICATION_ERROR(-20101
                               ,'�� ��������� ���� "������������ ��� ����� ��������" �� � ������ ���!');
      ELSIF v_c > 1
            AND v_flags > 1
      THEN
        --��������� ����� � ���������� ��������� ������
        RAISE_APPLICATION_ERROR(-20102
                               ,'��������� ���� "������������ ��� ����� ��������" ����� � ���������� ���!');
      ELSE
        -- �������������� � = 0: ERROR
        RAISE NO_DATA_FOUND;
      END IF;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20103
                               ,'��� �� ������ ���, ��� ������������ ����������� �������������� �������� �����������!');
    END;
    --END IF;
  END fill_pol_header_ids;

  ------------------------------------------------------------------------
  PROCEDURE correct_pol4bso(p_policy_id IN NUMBER)
  ------------------------------------------------------------------------
   AS
    vr_policy           p_policy%ROWTYPE;
    vr_pol_header       p_pol_header%ROWTYPE;
    v_product_brief     t_product.brief%TYPE;
    v_use_ids_as_number t_product.use_ids_as_number%TYPE;
  BEGIN
    --���������� ������
    SELECT * INTO vr_policy FROM p_policy p WHERE p.policy_id = p_policy_id;
  
    --�������� ��� ��� ������ ������
    IF vr_policy.version_num = 1
    THEN
      --������ ids
      fill_pol_header_ids(p_policy_id);
    
      --������� ���������
      SELECT *
        INTO vr_pol_header
        FROM p_pol_header ph
       WHERE ph.policy_header_id = vr_policy.pol_header_id;
    
      -- ��������� ���������� ��������
      SELECT tp.brief
            ,NVL(use_ids_as_number, 1)
        INTO v_product_brief
            ,v_use_ids_as_number
        FROM t_product tp
       WHERE tp.product_id = vr_pol_header.product_id;
    
      --������ pol_ser, pol_num, notice_ser, notice_num
      UPDATE p_policy p
         SET p.pol_ser = /*case \*������ 173036*\
                                                                     when v_product_brief like 'CR98%'
                                                                     then
                                                                       p.pol_ser
                                                                   end ������ 180159 */ NULL
            , --����� �������� ������
             p.pol_num = CASE
                           WHEN v_use_ids_as_number = 1 THEN
                            TO_CHAR(vr_pol_header.ids)
                           ELSE
                            p.pol_num
                         END
            ,
             -- ������ �.
             -- �� ������, ��� "�������" �� ��� ���������. � ���� �� �� �������� �� ����� ���������� �����
             --����� �������� ����� ��������������
             p.notice_ser = SUBSTR(TO_CHAR(vr_pol_header.ids), 1, 3)
            ,
             --����� ��������� ����� �������� ����� ���
             p.notice_num = SUBSTR(TO_CHAR(vr_pol_header.ids), 4)
      --����� �������� ����� ������ ��� � ����������� ������
       WHERE p.policy_id = p_policy_id;
    ELSIF vr_policy.pol_num IS NULL
    THEN
      --���� ����� �������� ������
      --������� ���������
      SELECT *
        INTO vr_pol_header
        FROM p_pol_header ph
       WHERE ph.policy_header_id = vr_policy.pol_header_id;
    
      --��������� ������ ���� �� ������ ������
      UPDATE p_policy p
         SET (p.pol_ser, p.pol_num, p.notice_ser, p.notice_num) =
             (SELECT NVL(p.pol_ser, pp.pol_ser)
                    ,NVL(p.pol_num, pp.pol_num)
                    ,NVL(p.notice_ser, pp.notice_ser)
                    ,NVL(p.notice_num, pp.notice_num)
                FROM p_policy pp
               WHERE pp.pol_header_id = vr_policy.pol_header_id
                 AND pp.version_num = 1)
       WHERE p.policy_id = p_policy_id;
    
      --���� ������������� � ������-�� �������� �� ��������
      IF vr_pol_header.ids IS NULL
      THEN
        --���� ������ ������
        SELECT *
          INTO vr_policy
          FROM p_policy p
         WHERE p.pol_header_id = vr_policy.pol_header_id
           AND p.version_num = 1;
      
        --� ��������� �� ��� IDS
        fill_pol_header_ids(vr_policy.policy_id);
      END IF;
    END IF;
  END correct_pol4bso;

  ------------------------------------------------------------------------
  PROCEDURE clear_pol4bso(p_policy_id IN NUMBER)
  ------------------------------------------------------------------------
   IS
    v_pol_header_id     NUMBER;
    p_ver_num           NUMBER;
    v_product_brief     t_product.brief%TYPE;
    v_use_ids_as_number NUMBER(1);
  BEGIN
  
    BEGIN
      SELECT pp.version_num
            ,pp.pol_header_id
        INTO p_ver_num
            ,v_pol_header_id
        FROM p_policy pp
       WHERE pp.policy_id = p_policy_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        p_ver_num := 0;
    END;
  
    IF p_ver_num = 1
    THEN
    
      -- ��������� ���������� ��������
      SELECT tp.brief
            ,nvl(use_ids_as_number, 1)
        INTO v_product_brief
            ,v_use_ids_as_number
        FROM t_product    tp
            ,p_pol_header ph
       WHERE ph.policy_header_id = v_pol_header_id
         AND ph.product_id = tp.product_id;
    
      -- ������ �.
      -- ���� ���, ������ �� ��������, ����� ���
      IF v_use_ids_as_number = 1 /*v_product_brief NOT LIKE 'CR92%'*/
      /*not in ('CR92_1','CR92_2','CR92_3')*/
      THEN
        UPDATE p_policy p
           SET p.pol_ser    = ''
              ,p.pol_num    = ''
              ,p.notice_ser = ''
              ,p.notice_num = ''
         WHERE p.policy_id = p_policy_id;
      END IF;
    
      UPDATE ven_p_pol_header ph SET ph.ids = NULL WHERE ph.policy_header_id = v_pol_header_id;
    
    END IF;
  
  END clear_pol4bso;

  --��������� ��������� ��������� ������� �� �������.
  ------------------------------------------------------------------------
  PROCEDURE post_cre_pyment(p_claim_id IN NUMBER)
  ------------------------------------------------------------------------
   IS
    v_status_date DATE;
    v_bank        NUMBER;
  BEGIN
    /*
    SELECT MAX(cba.ID)
      INTO v_bank
      FROM cn_contact_bank_acc cba, organisation_tree ot
     WHERE (   (    cba.contact_id = ot.company_id
                AND ot.organisation_tree_id = Pkg_Filial.get_user_org_tree_id
                AND NVL(Pkg_App_Param.get_app_param_n('FILIALS_ENABLED'), 0) = 1)
            OR (    cba.contact_id = ot.company_id
                AND ot.company_id = Pkg_App_Param.get_app_param_u('WHOAMI')
                AND NVL(Pkg_App_Param.get_app_param_n('FILIALS_ENABLED'), 0) != 1))
       AND cba.account_nr = '40701810800001410925'
       AND cba.bank_name = '��� "��������������"';
    */
    --������ 15.12.2011 �������������� �������
    v_bank := Pkg_App_Param.get_app_param_u('COMPANY_ACCOUNT');
  
    FOR x IN (SELECT dd.child_id
                    ,d.reg_date
                FROM doc_doc  dd
                    ,document d
               WHERE dd.parent_id = p_claim_id
                 AND dd.child_id = d.document_id)
    LOOP
      SELECT start_date
        INTO v_status_date
        FROM doc_status
       WHERE doc_status_id =
             (SELECT MAX(doc_status_id) FROM doc_status WHERE document_id = p_claim_id);
    
      UPDATE ac_payment
         SET grace_date          = TRUNC(v_status_date)
            ,due_date            = TRUNC(v_status_date)
            ,company_bank_acc_id = v_bank
       WHERE payment_id = x.child_id;
    
      UPDATE document SET reg_date = v_status_date WHERE document_id = x.child_id;
    END LOOP;
  END post_cre_pyment;

  --��������� ��������� ����� ����� ������� ������ ���������
  ------------------------------------------------------------------------
  PROCEDURE post_ch_claim_status(p_claim_id IN NUMBER)
  ------------------------------------------------------------------------
   IS
    v_status_date DATE;
  BEGIN
    SELECT TRUNC(start_date)
      INTO v_status_date
      FROM doc_status
     WHERE doc_status_id = (SELECT MAX(doc_status_id) FROM doc_status WHERE document_id = p_claim_id);
  
    UPDATE c_claim SET claim_status_date = v_status_date WHERE c_claim_id = p_claim_id;
  END post_ch_claim_status;

  --��������� ������ � �������� ������ �� ���� ������� ���������
  ------------------------------------------------------------------------
  PROCEDURE del_all_claim_setoff(p_claim_id IN NUMBER)
  ------------------------------------------------------------------------
   IS
  BEGIN
    FOR x IN (SELECT *
                FROM c_claim cc
               WHERE cc.c_claim_header_id =
                     (SELECT c_claim_header_id FROM c_claim c WHERE c.c_claim_id = p_claim_id))
    LOOP
      PKG_CLAIM.setoff_cancel(x.c_claim_id); --����� ������������
      PKG_CLAIM.SETOFF_DELETE(x.c_claim_id); --�������� ������������
    END LOOP;
  END del_all_claim_setoff;

  -- ������ �.
  -- ��������� ����� �������� �������� (������ 151232)
  PROCEDURE set_mailing_flag_on(par_policy_id NUMBER) IS
  BEGIN
    UPDATE p_policy pp
       SET pp.mailing =
           (SELECT CASE
                     WHEN pr.brief IN ('Baby_LA'
                                      ,'Baby_LA2'
                                      ,'Family La'
                                      ,'Family_La2'
                                      ,'Platinum_LA'
                                      ,'Platinum_LA2'
                                      ,'END'
                                      ,'END_2'
                                      ,'CHI'
                                      ,'CHI_2'
                                      ,'PEPR'
                                      ,'PEPR_2'
                                      ,'TERM'
                                      ,'TERM_2') THEN
                      1
                     ELSE
                      0
                   END
              FROM p_pol_header ph
                  ,t_product    pr
             WHERE ph.policy_header_id = pp.pol_header_id
               AND ph.product_id = pr.product_id)
     WHERE pp.policy_id = par_policy_id
       AND pp.version_num = 1;
  END set_mailing_flag_on;

END xx_doc_procedures;
/

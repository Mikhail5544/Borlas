CREATE OR REPLACE PACKAGE "PKG_PAYMENT_REGISTER" IS
  TYPE t_number IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

  FUNCTION get_policy4payment(p_payment_id NUMBER) RETURN NUMBER;

  FUNCTION get_epg4payment(p_payment_id NUMBER) RETURN NUMBER;

  FUNCTION get_ids4dso(p_dso_id NUMBER) RETURN NUMBER;

  --������� ��� ���������� ����� ����� ����������
  FUNCTION normalize_string(p_str VARCHAR2) RETURN VARCHAR2;

  /** ��������� ���������� �������� �� ����� �� ��������� ��� ���.
  * @autor ������ �.�.
  * @param par_policy_header_id - �� �������� �����������
  * @return ���������� id �������� ������ �� ��. ���� �� ������, �� ���������� NULL
  */
  FUNCTION get_agent_with_ret(par_policy_header_id NUMBER) RETURN NUMBER;
  /*
    ������ �.
    ����� ������� �� � ��������� ���������, ��� ���������� �������������
  */
  PROCEDURE insert_register_item
  (
    par_register_item_id     IN OUT payment_register_item.payment_register_item_id%TYPE
   ,par_payment_sum          payment_register_item.payment_sum%TYPE
   ,par_payment_currency     payment_register_item.payment_currency%TYPE
   ,par_payment_purpose      payment_register_item.payment_purpose%TYPE
   ,par_commission_currency  payment_register_item.commission_currency%TYPE
   ,par_ac_payment_id        payment_register_item.ac_payment_id%TYPE DEFAULT NULL
   ,par_payment_id           payment_register_item.payment_id%TYPE DEFAULT NULL
   ,par_doc_num              payment_register_item.doc_num%TYPE DEFAULT NULL
   ,par_payment_data         payment_register_item.payment_data%TYPE DEFAULT NULL
   ,par_payer_fio            payment_register_item.payer_fio%TYPE DEFAULT NULL
   ,par_payer_birth          payment_register_item.payer_birth%TYPE DEFAULT NULL
   ,par_payer_address        payment_register_item.payer_address%TYPE DEFAULT NULL
   ,par_payer_id_name        payment_register_item.payer_id_name%TYPE DEFAULT NULL
   ,par_payer_id_ser_num     payment_register_item.payer_id_ser_num%TYPE DEFAULT NULL
   ,par_payer_id_issuer      payment_register_item.payer_id_issuer%TYPE DEFAULT NULL
   ,par_payer_id_issue_date  payment_register_item.payer_id_issue_date%TYPE DEFAULT NULL
   ,par_pol_ser              payment_register_item.pol_ser%TYPE DEFAULT NULL
   ,par_pol_num              payment_register_item.pol_num%TYPE DEFAULT NULL
   ,par_ids                  payment_register_item.ids%TYPE DEFAULT NULL
   ,par_insured_fio          payment_register_item.insured_fio%TYPE DEFAULT NULL
   ,par_commission           payment_register_item.commission%TYPE DEFAULT 0
   ,par_territory            payment_register_item.territory%TYPE DEFAULT NULL
   ,par_add_info             payment_register_item.add_info%TYPE DEFAULT NULL
   ,par_status               payment_register_item.status%TYPE DEFAULT NULL
   ,par_is_dummy             payment_register_item.is_dummy%TYPE DEFAULT NULL
   ,par_set_off_state        payment_register_item.set_off_state%TYPE DEFAULT NULL
   ,par_collection_method_id payment_register_item.collection_method_id%TYPE DEFAULT NULL
  );

  --�������� ������� �� ������������� �������
  PROCEDURE cre_register(p_load_num NUMBER);

  --�������� �������������� ������� � ����� ������� �� ��������� ������ ��
  PROCEDURE cre_dummy_register(p_payment_id NUMBER);

  PROCEDURE register_old_setoff(p_set_off_id PLS_INTEGER);

  --�������� ������� ��� ��
  PROCEDURE del_register
  (
    p_payment_id              NUMBER
   ,par_create_dummy_register BOOLEAN DEFAULT TRUE
  );

  --��������� ������������� ���������� �������� ������� �������
  PROCEDURE recognize_payment(p_payment_register_item_id NUMBER);

  --��������� ���������� ������������� ������ �������� ��������
  PROCEDURE recognize_payments(pt_pri_list t_number);

  --��������� �������� ����� ������������ ������ ������� �������
  PROCEDURE connect_payment(p_payment_register_item_id NUMBER);

  --��������� ��������� �������� ������ ������������ ����� ������� �������
  PROCEDURE connect_payments(pt_pri_list t_number);

  --��������� ����� �� � ��� ����� ��4. ���������� �.�., 2011.06.01
  FUNCTION cre_pd4
  (
    p_pri                 NUMBER
   ,ap_epg_id             NUMBER DEFAULT NULL
   ,p_list_set_off_amount NUMBER DEFAULT NULL -- ������ �. ������ 242293 (���������� "� ������" � ������� ���������)
  ) RETURN VARCHAR2;
  --��������� ����� �� � ��� ����� ����� ���������
  FUNCTION cre_zachet_ucv
  (
    p_pri                   NUMBER
   ,ap_epg_id               NUMBER DEFAULT NULL
   ,par_list_set_off_amount NUMBER DEFAULT NULL
  ) RETURN VARCHAR2;
  --������� �������� �� ���
  FUNCTION check_fms(p_paym_reg_item_id NUMBER) RETURN NUMBER;

  /*
  * ��������� ��� ��������� � �������� ����������� ��
  * ��� ����� ����� ������ (�������������/�������) ������� ������ ��������� ���������� ���� �� ��� ��� �������� ���������� �7/��4
  * @autor ������ �.�.
  * @param par_payment_id - ��������� �������� � �������� �����������
  * @param par_pay_doc_id - ��������� �������� �������� �����������
  */
  PROCEDURE check_payment_currency
  (
    par_payment_id NUMBER
   ,par_pay_doc_id NUMBER
  );

  /*
    218934 �������� �������� �� ��������� � ������� ����������
  */
  PROCEDURE recognize_indexation(par_payment_register_item_id NUMBER);

  -- Author  : �������� �.�.
  -- Created : 17.03.2015
  -- Purpose : 403556: �������� �������� ��������
  -- Param   : par_pp_id           ID ��
  --           par_is_annulate     ������������ ��� �������
  --           par_is_del_register ������� ������
  --           par_is_del_pp       ������� ��
  --           pat_is_tex_err      ��������� ������� � ������ ���. ������
  --           par_reason          �������
  --           par_cancel_date     ���� �������������
  PROCEDURE annulate_delete_all_links
  (
    par_pp_id           NUMBER
   ,par_reason          VARCHAR2
   ,par_is_annulate     BOOLEAN
   ,par_is_del_register BOOLEAN DEFAULT FALSE
   ,par_is_del_pp       BOOLEAN DEFAULT FALSE
   ,par_is_tex_err      BOOLEAN DEFAULT TRUE
   ,par_cancel_date     DATE DEFAULT SYSDATE
  );

END pkg_payment_register;
/
CREATE OR REPLACE PACKAGE BODY pkg_payment_register IS
  TYPE t_ph IS TABLE OF p_pol_header%ROWTYPE INDEX BY BINARY_INTEGER;

  CURSOR to_set_off
  (
    reg_sum  NUMBER
   ,reg_item INTEGER
  ) IS
    SELECT reg_sum - nvl(SUM(dso1.set_off_child_amount), 0)
      FROM doc_set_off dso1
     WHERE dso1.pay_registry_item = reg_item
       AND dso1.cancel_date IS NULL;

  ------------------------------------------------------------------
  FUNCTION get_current_user
  ------------------------------------------------------------------
   RETURN VARCHAR2 AS
    v_user VARCHAR2(100) := USER;
  BEGIN
    IF USER = ents_bi.eul_owner
    THEN
      v_user := nvl(sys_context('USERENV', 'CLIENT_IDENTIFIER'), USER);
    END IF;
  
    RETURN v_user;
  END get_current_user;

  ------------------------------------------------------------------
  FUNCTION get_policy4payment(p_payment_id NUMBER)
  ------------------------------------------------------------------
   RETURN NUMBER AS
    v_policy NUMBER;
  BEGIN
    SELECT DISTINCT policy_id
      INTO v_policy
      FROM (SELECT p.policy_id
              FROM p_policy p
                  ,doc_doc dd
                  ,ac_payment epg
                  ,(SELECT dso_e.parent_doc_id
                          ,dso_p.child_doc_id
                      FROM doc_set_off dso_e
                          ,document    d_ap
                          ,doc_doc     dd
                          ,document    d_c
                          ,doc_set_off dso_p
                     WHERE dso_e.child_doc_id = d_ap.document_id
                       AND d_ap.doc_templ_id IN
                           (SELECT dt.doc_templ_id FROM doc_templ dt WHERE dt.brief IN ('A7', 'PD4'))
                       AND d_ap.document_id = dd.parent_id
                       AND dd.child_id = d_c.document_id
                       AND d_c.doc_templ_id IN
                           (SELECT dt.doc_templ_id
                              FROM doc_templ dt
                             WHERE dt.brief IN ('A7COPY', 'PD4COPY'))
                       AND d_c.document_id = dso_p.parent_doc_id) dso
             WHERE p.policy_id = dd.parent_id
               AND dd.child_id = epg.payment_id
               AND epg.payment_id = dso.parent_doc_id
               AND dso.child_doc_id = p_payment_id
            UNION ALL
            SELECT p.policy_id
              FROM p_policy    p
                  ,doc_doc     dd
                  ,ac_payment  epg
                  ,doc_set_off dso
             WHERE p.policy_id = dd.parent_id
               AND dd.child_id = epg.payment_id
               AND epg.payment_id = dso.parent_doc_id
               AND dso.child_doc_id = p_payment_id);
  
    RETURN v_policy;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN 0;
    WHEN too_many_rows THEN
      RETURN - 1;
  END get_policy4payment;

  ------------------------------------------------------------------
  FUNCTION get_epg4payment(p_payment_id NUMBER)
  ------------------------------------------------------------------
   RETURN NUMBER AS
    v_payment NUMBER;
  BEGIN
    SELECT payment_id
      INTO v_payment
      FROM (SELECT epg.payment_id
              FROM ac_payment epg
                  ,(SELECT dso_e.parent_doc_id
                          ,dso_p.child_doc_id
                      FROM doc_set_off dso_e
                          ,document    d_ap
                          ,doc_doc     dd
                          ,document    d_c
                          ,doc_set_off dso_p
                     WHERE dso_e.child_doc_id = d_ap.document_id
                       AND d_ap.doc_templ_id IN
                           (SELECT dt.doc_templ_id FROM doc_templ dt WHERE dt.brief IN ('A7', 'PD4'))
                       AND d_ap.document_id = dd.parent_id
                       AND dd.child_id = d_c.document_id
                       AND d_c.doc_templ_id IN
                           (SELECT dt.doc_templ_id
                              FROM doc_templ dt
                             WHERE dt.brief IN ('A7COPY', 'PD4COPY'))
                       AND d_c.document_id = dso_p.parent_doc_id) dso
             WHERE epg.payment_id = dso.parent_doc_id
               AND dso.child_doc_id = p_payment_id
            UNION ALL
            SELECT epg.payment_id
              FROM ac_payment  epg
                  ,doc_set_off dso
             WHERE epg.payment_id = dso.parent_doc_id
               AND dso.child_doc_id = p_payment_id) ee;
  
    RETURN v_payment;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN 0;
    WHEN too_many_rows THEN
      RETURN - 1;
  END get_epg4payment;

  ------------------------------------------------------------------
  FUNCTION get_ids4dso(p_dso_id NUMBER)
  ------------------------------------------------------------------
   RETURN NUMBER AS
    v_ids NUMBER;
  BEGIN
    SELECT ids
      INTO v_ids
      FROM p_pol_header ph
     WHERE ph.policy_header_id IN
           (SELECT p.pol_header_id
              FROM p_policy p
                  ,doc_doc dd
                  ,ac_payment epg
                  ,(SELECT dso_e.parent_doc_id
                          ,dso_p.child_doc_id
                      FROM doc_set_off dso_e
                          ,document    d_ap
                          ,doc_doc     dd
                          ,document    d_c
                          ,doc_set_off dso_p
                     WHERE dso_e.child_doc_id = d_ap.document_id
                       AND d_ap.doc_templ_id IN
                           (SELECT dt.doc_templ_id FROM doc_templ dt WHERE dt.brief IN ('A7', 'PD4'))
                       AND d_ap.document_id = dd.parent_id
                       AND dd.child_id = d_c.document_id
                       AND d_c.doc_templ_id IN
                           (SELECT dt.doc_templ_id
                              FROM doc_templ dt
                             WHERE dt.brief IN ('A7COPY', 'PD4COPY'))
                       AND d_c.document_id = dso_p.parent_doc_id
                       AND dso_p.doc_set_off_id = p_dso_id) dso
             WHERE p.policy_id = dd.parent_id
               AND dd.child_id = epg.payment_id
               AND epg.payment_id = dso.parent_doc_id
            UNION ALL
            SELECT p.pol_header_id
              FROM p_policy    p
                  ,doc_doc     dd
                  ,ac_payment  epg
                  ,doc_set_off dso
             WHERE p.policy_id = dd.parent_id
               AND dd.child_id = epg.payment_id
               AND epg.payment_id = dso.parent_doc_id
               AND dso.doc_set_off_id = p_dso_id);
  
    RETURN v_ids;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN to_number(NULL);
  END get_ids4dso;

  ------------------------------------------------------------------
  --������� ��� ���������� ����� ����� ����������
  FUNCTION normalize_string(p_str VARCHAR2)
  ------------------------------------------------------------------
   RETURN VARCHAR2 AS
  BEGIN
    RETURN translate(upper(p_str), '�� ', '��');
  END normalize_string;

  /*
  * ��������� ������ ��������������� � ���
  * ���� ������  �����, �� ���������� 1, ���� ������ �� �����, �� ���������� 0
  * �� ������ 255229: �������� �������� � �������� ���������
  * @autor ������ �.�.
  * @param par_payment_id - ��������� �������� � �������� ����������� ����
  */
  FUNCTION is_rur_currency(par_payment_id NUMBER) RETURN INT IS
    v_fund_brief fund.brief%TYPE;
    v_ac_brief   doc_templ.brief%TYPE;
  BEGIN
    --������ ���������� �� ������ 255229 ��������� ������ �� ������ � ���
    --�� � ��4_copy � A7_copy. �� ������ 273168 ������� ������ �������� �� ������ �� ���
    SELECT f.brief
          ,dt.brief
      INTO v_fund_brief
          ,v_ac_brief
      FROM ins.ven_ac_payment ac
          ,ins.fund           f
          ,ins.doc_templ      dt
     WHERE ac.payment_id = par_payment_id
       AND ac.fund_id = f.fund_id
       AND ac.doc_templ_id = dt.doc_templ_id;
  
    --���� ���� ������������� � ���, �� ������ ������ ���� �����
    IF v_ac_brief = 'PAYMENT'
       AND v_fund_brief != 'RUR'
    THEN
      RETURN 0;
    ELSE
      RETURN 1;
    END IF;
  END is_rur_currency;

  /** ��������� ���������� �������� �� ����� �� ��������� ��� ���.
  * @autor ������ �.�.
  * @param par_policy_header_id - �� �������� �����������
  * @return ���������� id �������� ������ �� ��. ���� �� ������, �� ���������� NULL
  */
  FUNCTION get_agent_with_ret(par_policy_header_id NUMBER) RETURN NUMBER IS
    v_result NUMBER;
  BEGIN
    BEGIN
      SELECT ach.agent_id
        INTO v_result
        FROM p_pol_header       ph
            ,p_policy_agent_doc pad
            ,ag_contract_header ach
            ,document           d
            ,doc_status_ref     dsr
       WHERE ph.policy_header_id = pad.policy_header_id
         AND ach.ag_contract_header_id = pad.ag_contract_header_id
         AND dsr.doc_status_ref_id = d.doc_status_ref_id
         AND d.document_id = pad.p_policy_agent_doc_id
         AND ph.policy_header_id = par_policy_header_id
         AND ach.with_retention = 1
         AND dsr.brief = 'CURRENT';
    EXCEPTION
      WHEN no_data_found
           OR too_many_rows THEN
        v_result := NULL;
    END;
    RETURN v_result;
  END get_agent_with_ret;

  ------------------------------------------------------------------
  --��������� ������������� ���
  PROCEDURE recognize_epg(
                          ------------------------------------------------------------------
                          pl_ph_list t_ph
                         ,pr_pri     payment_register_item%ROWTYPE
                         ,p_epg_id   OUT NUMBER
                         ,p_status   OUT NUMBER
                         ,p_comment  IN OUT VARCHAR2) AS
    v_c              NUMBER := 0;
    v_s              NUMBER;
    v_s_c            PLS_INTEGER := 0;
    v_ids_list       VARCHAR2(512);
    v_sc_descr       VARCHAR2(50);
    v_sc_id          PLS_INTEGER;
    v_epg_id_new     NUMBER;
    v_epg_amount_new NUMBER;
    --������ 11.10.2011 ����� ��������� ������������� ��������������
    v_agent_id    NUMBER;
    v_check_agent INT;
    v_sposob_opl  ven_t_collection_method.description%TYPE;
    v_pp_templ    doc_templ.brief%TYPE;
    -----------------------------------------------------
    --������ 31.01.2012 144493 �������� ������� � �������� � ������� <����������>
    v_last_policy_status     doc_status_ref.brief%TYPE;
    v_last_policy_start_date DATE;
    v_min_date_new           DATE;
    -------------------------------------------------------------------
    --������ 301648: ����� ��������� ������ 2013. �� ����������� ����� ����� ��� � ���������� ��� ����
    v_pp_agent NUMBER;
    --������ 163877: ��������� - �������� 1 �������� 2012����
    v_have_epg_to_pay BOOLEAN := FALSE;
    ---------------------------------------------------------
    --������ 132468 ��������� - �������� ������������� �������� �� ��
    err_check_payer EXCEPTION; --���������� �� � �� �� � �� ��������. ��� �� �� ������ ����� ���� �. ��������
    -- ���������� �������� �� �������� �������, ���� ������ ��������������� �� �������� �� ������� ������������ ������ ������� �� RUR.
    --��� ������������� �������, ����� ������������� �������� � ���, ������� ������ �������� ������ ����� (���), ������ <����� �����> (���. 1), ���� � ������ ����� �������� �������� �� RUR, �� ������� ������������� ������ �� - �������-���������, � ���� <����������� � �������� �������> � ������� ��������, ������������� ����������� - <�������� �������>.
    err_is_not_rur_currency EXCEPTION;
  
    v_ids NUMBER;
    ------------------------------------------------------------------
  
    v_epg_id  NUMBER;
    v_counter NUMBER := 0;
    v_i       NUMBER;
  
    --������ ��������� ��� ������� (c_epg_payed � c_epg_to_pay) � ���� �� ������ 163877 ��������� - �������� 1 �������� 2012����
    CURSOR c_epg_to_all(p_phid NUMBER) IS
      SELECT amount
            ,payment_id
            ,due_date
            ,type_epg
        FROM (
              --��� � ������� � ������
              SELECT amount
                     ,payment_id
                     ,due_date
                     ,type_epg
                FROM (SELECT ap.amount -
                              nvl(pkg_payment.get_set_off_amount(ap.payment_id, NULL, NULL), 0) amount
                             ,ap.payment_id
                             ,ap.due_date
                             ,ap.num
                             ,1 type_epg
                         FROM p_policy       pp
                             ,doc_doc        dd
                             ,ven_ac_payment ap
                             ,document       ap_d
                             ,doc_templ      dt
                             ,doc_status_ref ap_dsr
                        WHERE pp.pol_header_id = p_phid
                          AND pp.policy_id = dd.parent_id
                          AND dd.child_id = ap.payment_id
                          AND ap.payment_id = ap_d.document_id
                          AND ap_d.doc_templ_id = dt.doc_templ_id
                          AND ap_dsr.doc_status_ref_id = ap_d.doc_status_ref_id
                          AND dt.brief = 'PAYMENT'
                          AND ap_dsr.brief = 'TO_PAY'
                       UNION ALL
                       --���, ���������� A7 � PD4
                       SELECT apc.amount
                             ,apc.payment_id
                             ,ap.due_date
                             ,ap.num
                             ,2 type_epg
                         FROM p_policy       pp
                             ,doc_doc        dd
                             ,ven_ac_payment ap
                             ,doc_set_off    dso
                             ,ac_payment     apd
                             ,doc_doc        ddc
                             ,ac_payment     apc
                             ,doc_status_ref dsr
                             ,doc_status_ref dsr_apc
                             ,document       dc
                        WHERE pp.pol_header_id = p_phid
                          AND pp.policy_id = dd.parent_id
                          AND ap.payment_id = dd.child_id
                          AND dd.child_id = dso.parent_doc_id
                          AND apd.payment_id = dso.child_doc_id
                          AND apd.payment_templ_id IN
                              (SELECT pt.payment_templ_id
                                 FROM ac_payment_templ pt
                                WHERE pt.brief IN ('A7', 'PD4'))
                             --���� ������� �������
                          AND ddc.parent_id = apd.payment_id
                          AND apc.payment_id = ddc.child_id
                          AND apc.payment_id = dc.document_id
                          AND dc.doc_templ_id IN
                              (SELECT doc_templ_id
                                 FROM doc_templ dt
                                WHERE dt.brief IN ('A7COPY', 'PD4COPY'))
                          AND NOT EXISTS ( -- � ��� ������ �����
                               SELECT NULL
                                 FROM doc_set_off dsoc
                                      ,ac_payment  app
                                WHERE dsoc.parent_doc_id = apc.payment_id
                                  AND app.payment_id = dsoc.child_doc_id)
                             -- ������ �.
                             -- �� ������ �������� ��������������
                             --������ /������� ������� �� �������/188446: ��������� - ����������� ��������� �������������/
                             --and doc.get_doc_status_brief(apc.payment_id) != 'ANNULATED'
                          AND dsr_apc.doc_status_ref_id = dc.doc_status_ref_id
                          AND dsr_apc.brief != 'ANNULATED'
                          AND dsr.doc_status_ref_id = ap.doc_status_ref_id
                          AND dsr.brief != 'ANNULATED'
                       
                       )
               ORDER BY due_date
                        ,num)
       WHERE rownum = 1;
  
    --������ 132468 /������� ���������/ ��������� - �������� ������������� �������� �� ��
    --/�������������/ ������ /196524: ������������� �������� ��. ��� ��/
    PROCEDURE check_issuer_status(p_ids NUMBER) IS
      v_cnt_ur     INT;
      v_cnt_brs    INT;
      v_payer_fio  payment_register_item.payer_fio%TYPE;
      v_contact_id NUMBER;
    BEGIN
      SELECT COUNT(*)
        INTO v_cnt_ur
        FROM p_pol_header   ph
            ,v_pol_issuer   vi
            ,contact        c
            ,t_contact_type ct
       WHERE ph.ids = p_ids
         AND vi.policy_id = ph.policy_id
         AND c.contact_id = vi.contact_id
         AND ct.id = c.contact_type_id
         AND ct.brief = '��';
    
      -- ������� ����������� �� ��
      SELECT pri.payer_fio
            ,c.contact_id
        INTO v_payer_fio
            ,v_contact_id
        FROM payment_register_item pri
            ,ac_payment            ac
            ,contact               c
       WHERE ac.payment_id = pri.ac_payment_id
         AND pri.payment_register_item_id = pr_pri.payment_register_item_id
         AND c.contact_id = ac.contact_id;
    
      --���� ������������ �� ����
      IF v_cnt_ur = 1
      THEN
        --����� ����������� ��� "���� ������� ��������"
        --��� 044583151
        --��������� ���� 30232810800000053989
        SELECT COUNT(*)
          INTO v_cnt_brs
          FROM contact             c
              ,cn_contact_bank_acc cba
         WHERE c.contact_id = v_contact_id
           AND c.contact_id = cba.contact_id
           AND cba.account_nr = '30232810800000053989'
           AND upper(ent.obj_name(c.ent_id, c.contact_id)) = upper('��� "���� ������� ��������"')
           AND EXISTS
         (SELECT 1
                  FROM ins.cn_contact_ident cci
                 WHERE cci.table_id = pkg_contact.get_contact_document_id(c.contact_id, 'BIK')
                   AND cci.id_value = '044583151');
      
        IF v_cnt_brs > 0
        --���� ����� �� ������
        THEN
          RAISE err_check_payer;
        END IF;
      
        --���� ������������ �� �� ����
      ELSE
        --����� ����������� ��� "���� ������� ��������"
        --��� 044583151
        --��������� ���� 30232810800000053989
        SELECT COUNT(*)
          INTO v_cnt_brs
          FROM contact             c
              ,cn_contact_bank_acc cba
         WHERE c.contact_id = v_contact_id
           AND c.contact_id = cba.contact_id
           AND cba.account_nr = '30232810800000053989'
           AND upper(ent.obj_name(c.ent_id, c.contact_id)) = upper('��� "���� ������� ��������"')
           AND EXISTS
         (SELECT 1
                  FROM ins.cn_contact_ident cci
                 WHERE cci.table_id = pkg_contact.get_contact_document_id(c.contact_id, 'BIK')
                   AND cci.id_value = '044583151');
      
        IF v_cnt_brs > 0
        THEN
          --���� ���������� �� ��� ��������, �� ������
          IF (instr(upper(v_payer_fio), '�� ', 1) = 1)
             OR (instr(upper(v_payer_fio), '��������', 1) > 0)
          THEN
            RAISE err_check_payer;
          END IF;
        END IF;
      END IF;
    END check_issuer_status;
  
  BEGIN
  
    IF pl_ph_list.count > 0
    THEN
      --------------------------------------------------------------------------
      --������� ������ ��
      --------------------------------------------------------------------------      
      IF pl_ph_list.count = 1
      THEN
        p_comment := p_comment ||
                    --������ /264364: �������������� �������� �������� � �� � ���������/
                     CASE
                       WHEN doc.get_doc_status_brief(pl_ph_list(pl_ph_list.first).last_ver_id) = 'CANCEL' THEN
                        ' �������� ������ � �������: ' ||
                        doc.get_doc_status_name(pl_ph_list(pl_ph_list.first).policy_id)
                       ELSE
                        ' ��������� ������ � �������: ' ||
                        doc.get_doc_status_name(pl_ph_list(pl_ph_list.first).last_ver_id)
                     END --end 264364
                     || chr(10);
      
        --�������� �� ������� � ������������ ������� �� 
        check_issuer_status(pl_ph_list(pl_ph_list.first).ids);
      
        v_sc_id := pl_ph_list(pl_ph_list.first).sales_channel_id;
      
        SELECT ts.brief INTO v_sc_descr FROM t_sales_channel ts WHERE ts.id = v_sc_id;
      
        UPDATE ins.payment_register_item pri
           SET pri.set_off_state = decode(v_sc_descr, 'BANK', 1, 'BR', 2, pri.set_off_state)
         WHERE pri.payment_register_item_id = pr_pri.payment_register_item_id
              -- ������ �.
              -- ������ ������ NULL ��� ����� ���� 'NULL' (ID = 21)
           AND nvl(pri.set_off_state, 21) IN (11, 21);
      END IF;
    
      FOR i IN pl_ph_list.first .. pl_ph_list.last
      LOOP
        ----------------------------------------------------------------------
        --������ /264364: �������������� �������� �������� � �� � ���������/
        ----------------------------------------------------------------------
        --������ ������ ��������� ������
        v_last_policy_status := doc.get_doc_status_brief(pl_ph_list(i).last_ver_id);
        --���� ������ ��������� ������ �������
        IF v_last_policy_status = 'CANCEL'
        THEN
          --�� ���������� � ��������� ���� ������ �������� ������
          SELECT pp.start_date
            INTO v_last_policy_start_date
            FROM ven_p_policy pp
           WHERE pp.policy_id = pl_ph_list(i).policy_id;
          --���������� ��� ��������� ������ ��������, � �� ��������� �������
          v_last_policy_status := doc.get_doc_status_brief(pl_ph_list(i).policy_id);
        ELSE
          --����� ������� ���� ������ ��������� ������
          SELECT pp.start_date
            INTO v_last_policy_start_date
            FROM ven_p_policy pp
           WHERE pp.policy_id = pl_ph_list(i).last_ver_id;
        END IF;
        --------------------------------------------------------------------------------
        --�������� �.�. �������� ������ �� ����� ���� � ����� ��������, ������ ���������
        --------------------------------------------------------------------------------        
        CASE
          WHEN v_last_policy_status
              -- ������ �.
              -- ������� "���������" � "���������. ������ ����������"
              --������ ������� ����� � ��������������
               IN ('READY_TO_CANCEL'
                  ,'BREAK'
                  ,'CANCEL'
                  ,'TO_QUIT'
                  ,'TO_QUIT_CHECK_READY'
                  ,'TO_QUIT_CHECKED'
                  ,'QUIT'
                  ,'QUIT_REQ_QUERY'
                   
                  ,'QUIT_DECL'
                  ,'QUIT_REQ_QUERY'
                  ,'QUIT_REQ_GET'
                  ,'DECLINE_CALCULATION') THEN
            v_s       := 1;
            v_counter := v_counter + 1;
            --������ 21.10.2011 138199
        --������ 01.03.2012 ������� �������� ����� �������
          WHEN v_last_policy_status = 'RECOVER' THEN
            v_s := 1;
            UPDATE ins.payment_register_item pri
               SET pri.set_off_state = 22
             WHERE pri.payment_register_item_id = pr_pri.payment_register_item_id
               AND nvl(pri.set_off_state, 21) IN (11, 21, 6, 13, 17, 12, 8, 9, 19, 10, 15); --xx_lov_list
          WHEN v_last_policy_status IN ('RECOVER_DENY'
                                        --������ 169435 169175 169488: �������������� �������������.
                                       ,'QUIT_DECL'
                                       ,'QUIT_TO_PAY'
                                       ,'QUIT_REQ_GET'
                                        --
                                       ,'STOP'
                                       ,'QUIT_DECL'
                                       ,'QUIT_REQ_QUERY'
                                       ,'QUIT_REQ_GET'
                                       ,'DECLINE_CALCULATION')
          
           THEN
            v_s := 1;
            UPDATE ins.payment_register_item pri
               SET pri.set_off_state = 11
             WHERE pri.payment_register_item_id = pr_pri.payment_register_item_id
               AND nvl(pri.set_off_state, 21) IN (11, 22, 21, 6, 13, 17, 12, 8, 9, 19, 10, 15);
            --end_������ 21.10.2011 138199
          ELSE
            v_s := 0;
        END CASE;
      
        --------------------------------------------------------------------
        --���������� ���
        --------------------------------------------------------------------        
        IF v_s > 0
        THEN
          --���� ������ �� ������ - ������ ����������� �������
          v_s_c := v_s_c + 1;
        ELSE
          --�������� ������� ��������� ���
          p_epg_id := NULL;
          --���� ��� �� ������ ���������
          FOR v_pay IN c_epg_to_all(pl_ph_list(i).policy_header_id)
          LOOP
            v_have_epg_to_pay := TRUE;
            -----------------------
            --���� �� A7 � PD4 �������� �������� ���   
            -----------------------
            IF v_pay.type_epg = 2
            THEN
              --�������/������/210240: �������� �������������� ��������/
              IF pr_pri.payment_sum - nvl(v_pay.amount, 99999999) BETWEEN 0 AND 0.001
              THEN
                p_epg_id   := v_pay.payment_id;
                v_ids_list := nvl(v_ids_list, ':') || pl_ph_list(i).ids || ',';
                v_c        := v_c + 1;
              END IF;
              -----------------------  
              --���� �� ��������, ������ ��������� � ��� (��)
              -----------------------
            ELSE
              --������ 301648: ����� ��������� ������ 2013  
              --���������� ������ ������ �� (� ����� ��� ���)    
              SELECT cm.description
                    ,dt.brief
                INTO v_sposob_opl
                    ,v_pp_templ
                FROM ven_ac_payment      ppvh
                    ,t_collection_method cm
                    ,doc_templ           dt
               WHERE cm.id = ppvh.collection_metod_id
                 AND dt.doc_templ_id = ppvh.doc_templ_id
                    --param
                 AND ppvh.payment_id = pr_pri.ac_payment_id;
            
              --������� ������ �� ���������, ���� �� ����
              v_agent_id := get_agent_with_ret(pl_ph_list(i).policy_header_id);
            
              --���� ��� �� ����� ��� �� ������ ��
              IF p_epg_id IS NULL
              THEN
                --�������/������/210240: �������� �������������� ��������/
                --��� ����������� ��� �� � ������� ����� ��������� (������� ����� ��������)
                --�.�. ������� �� ����������� ����� ��=���, ������ ����� ���� ��<���
                IF pr_pri.payment_sum - nvl(v_pay.amount, 99999999) BETWEEN 0 AND 0.001
                  --������ 31.01.2012 144493 �������� ������� � �������� � ������� <����������>
                   AND ((v_last_policy_status != 'INDEXATING') --�� ���������� 
                   --��� ���������� � �������� ���� ������ ������ ��� � ������� �����
                   OR ((v_last_policy_status = 'INDEXATING') AND
                   (v_last_policy_start_date > v_pay.due_date)))
                THEN
                  p_epg_id   := v_pay.payment_id;
                  v_ids_list := nvl(v_ids_list, ':') || pl_ph_list(i).ids || ',';
                  v_c        := v_c + 1;
                  --��� ����������� ��� �� � ������� ����� ������ ���
                  --���� ����� � � ������ ���� ��������� ��� ��, �� ����� �� �� � ����������
                ELSIF (v_pp_templ = '�����' AND v_agent_id IS NOT NULL)
                      OR
                      ((pr_pri.payment_sum <> 0 AND pr_pri.payment_sum <= nvl(v_pay.amount, 99999999) AND
                      v_agent_id IS NOT NULL))
                THEN
                  p_epg_id   := v_pay.payment_id;
                  v_ids_list := nvl(v_ids_list, ':') || pl_ph_list(i).ids || ',';
                  v_c        := v_c + 1;
                END IF;
              END IF;
            END IF;
          END LOOP;
        
          --������ 03.08.2011 ���� �� ����� ��� � ������ ��� �������� ������������ �7/��4
          --, �� ������� 1-�� ��� � ������� �����
          --���� � ���� �� �� ����� ��� � � ����,
          --�� ��������� ��� � ������ � ������, ����� ���� �������� ���
          IF v_have_epg_to_pay = FALSE
             AND p_epg_id IS NULL
            --and doc.get_doc_status_brief(pkg_policy.get_last_version(pl_ph_list(i).policy_header_id))
             AND v_last_policy_status IN ('CURRENT'
                                         ,'UNDERWRITING'
                                         ,'ACTIVE'
                                         ,'NEW'
                                         ,'PASSED_TO_AGENT'
                                         ,'MED_OBSERV'
                                         ,'NONSTANDARD'
                                         ,'AGENT_REVISION'
                                         ,'CONCLUDED'
                                         ,'TO_AGENT_NEW_CONDITION'
                                         ,'RE_REQUEST'
                                         ,'PRINTED'
                                         ,'TO_AGENT_DS'
                                         ,'FROM_AGENT_NEW_CONDITION'
                                         ,'DOC_REQUEST'
                                         ,'NEW_CONDITION'
                                         ,'FROM_AGENT_DS'
                                         ,'STOPED'
                                         ,'RECOVER'
                                         ,'INDEXATING'
                                         ,'WAITING_FOR_PAYMENT' --������/������� �� ������ 304533/
                                          )
          THEN
            BEGIN
              WITH paym AS
               (SELECT pol_header_id
                      ,ac_d.num
                      ,ac.payment_id
                      ,ac.plan_date
                      ,ac.amount - nvl(dso.set_off_amount, 0) amount
                      ,MIN(ac.plan_date) over(PARTITION BY pol_header_id, ac_dsr.brief) min_date_new
                      ,ac_dsr.brief ac_status
                      ,row_number() over(PARTITION BY pol_header_id, ac_dsr.brief ORDER BY ac.plan_date) rn
                  FROM p_policy       p
                      ,doc_doc        dd
                      ,ac_payment     ac
                      ,doc_templ      dt
                      ,document       ac_d
                      ,doc_status_ref ac_dsr
                      ,doc_set_off    dso
                 WHERE p.pol_header_id = pl_ph_list(i).policy_header_id
                   AND p.policy_id = dd.parent_id
                   AND dd.child_id = ac.payment_id
                   AND ac_d.document_id = ac.payment_id
                   AND ac_d.doc_templ_id = dt.doc_templ_id
                   AND dt.brief = 'PAYMENT'
                   AND ac_dsr.doc_status_ref_id = ac_d.doc_status_ref_id
                   AND dso.parent_doc_id(+) = ac.payment_id)
              SELECT payment_id
                    ,amount
                    ,min_date_new
                INTO v_epg_id_new
                    ,v_epg_amount_new
                    ,v_min_date_new
                FROM paym p
               WHERE p.ac_status = 'NEW'
                 AND plan_date = min_date_new
                 AND rn = 1
                 AND NOT EXISTS (SELECT *
                        FROM paym p1
                       WHERE ac_status = 'TO_PAY'
                         AND p1.pol_header_id = p.pol_header_id);
            EXCEPTION
              WHEN no_data_found THEN
                v_epg_id_new     := NULL;
                v_epg_amount_new := NULL;
                v_min_date_new   := NULL;
              WHEN too_many_rows THEN
                v_epg_id_new     := NULL;
                v_epg_amount_new := NULL;
                v_min_date_new   := NULL;
            END;
          
            IF (v_epg_id_new IS NOT NULL) --��� �� �������
              --�����������/������/210240: �������� �������������� ��������/
              /*and (ABS(pr_pri.payment_sum - NVL(v_epg_amount_new, 99999999))     --����� ��� ����� ����� ������
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                / pr_pri.payment_sum BETWEEN 0 AND 0.001) */
              --************************************************************
              --�������/������/210240: �������� �������������� ��������/
               AND pr_pri.payment_sum - nvl(v_epg_amount_new, 99999999) BETWEEN 0 AND 0.001 --����� ��� ����� ����� ������
              --************************************************************
               AND ((v_last_policy_status != 'INDEXATING') --�� ���������� ��� ���������� � �������� ���� ������ ������ ��� � ������� �����
               OR ((v_last_policy_status = 'INDEXATING') AND
               (v_last_policy_start_date > v_min_date_new)))
            THEN
            
              doc.set_doc_status(v_epg_id_new, 'TO_PAY');
              --������ 31.01.2012 144493 �������� ������� � �������� � ������� <����������> /����� ��� � �����������/
              p_epg_id   := v_epg_id_new;
              v_ids_list := nvl(v_ids_list, ':') || pl_ph_list(i).ids || ',';
              v_c        := v_c + 1;
              ------------------------------------------------------------------------------
            
            END IF;
          END IF;
          --------------------------------------------------------------
        
        END IF;
        -- ������ �.
        -- ��������� ��� ����, ����� �� ����������� ID ��� � ��������, ����� ������� ��������� ���������,
        -- � ���������� ��� ������ � �������
        v_epg_id := nvl(p_epg_id, v_epg_id);
        v_i      := i;
      END LOOP;
    
      IF v_i = v_counter
      THEN
        UPDATE ins.payment_register_item pri
           SET pri.set_off_state = 11
         WHERE pri.payment_register_item_id = pr_pri.payment_register_item_id
              -- ������ �.
              -- ������ ������ NULL ��� ����� ���� 'NULL' (ID = 21)
              -- ������ �. 02.03.2012
              -- � ������������ � ������ ������������, ������ "�����������" ��������������� � ��� ����� ��� ��������:
              -- NULL ����� ������� �������������� ������ ���������� ��������� ������ ������ �/� �� ������������� ����������
              -- ����� ������ ���.������
           AND nvl(pri.set_off_state, 21) IN (1, 2, 3, 8, 9, 12, 15, 17, 19, 21, 22);
      END IF;
    END IF;
  
    p_comment := p_comment || ' | ������������� ���:';
  
    --���� �������� ��������� ��� - ������� ������
    IF v_c > 1
    THEN
      p_epg_id  := NULL;
      p_status  := 20;
      p_comment := p_comment || ' ������ ��� �� ������� ����� ���� ������� �����' || v_ids_list;
    ELSIF v_c = 0
    THEN
      p_status := 20; --������������� �� ���������
    
      IF v_s_c > 0
      THEN
        p_epg_id := NULL;
        --������������� �� ���������
        p_comment := p_comment || ' ��� �� ���������� �������� ��-�� ������� ';
      ELSE
        p_epg_id := NULL;
      END IF;
    
      IF v_agent_id IS NOT NULL
      THEN
        p_comment := p_comment || ' �� � ������� ��������� ��. ';
        IF v_check_agent = 0
           AND v_pp_templ = '�����'
           AND v_sposob_opl = '���������'
        THEN
          p_comment := p_comment || ' ����� �� ��������� � ������� � ��������� ���������. ';
        END IF;
      END IF;
    ELSIF v_c = 1
          AND /*p_epg_id*/
          v_epg_id IS NOT NULL
          AND v_check_agent = 0
          AND v_agent_id IS NOT NULL
          AND v_pp_templ = '�����'
          AND v_sposob_opl = '���������'
    THEN
      p_status  := 20;
      p_epg_id  := NULL;
      p_comment := p_comment ||
                   ' �� � ������� ��������� ��. ����� �� ��������� � ������� � ��������� ���������. ';
    ELSIF v_c = 1
          AND /*p_epg_id*/
          v_epg_id IS NOT NULL
    THEN
      check_issuer_status(v_ids); --�������� �� ������� � ������������ ������� ��
    
      IF is_rur_currency(v_epg_id) = 0
      THEN
        -- ��������� ������ ��� � ��
        RAISE err_is_not_rur_currency;
      END IF;
    
      p_status := 50; --��������� �������������
      p_epg_id := v_epg_id;
    
      -- ������ �. 218934 �������� �������� �� ��������� � ������� ����������
      IF pl_ph_list.count = 1
      THEN
        v_ids := pl_ph_list(pl_ph_list.count).ids;
        UPDATE ins.payment_register_item pri
           SET pri.ids = v_ids
         WHERE pri.payment_register_item_id = pr_pri.payment_register_item_id;
      END IF;
    END IF;
  
  EXCEPTION
    WHEN err_check_payer THEN
      p_status  := 10;
      p_comment := p_comment || ' ������ ��������� ����� �������� ���. ';
      UPDATE ins.payment_register_item pri
         SET pri.set_off_state = 25 --'������ ���������'
       WHERE pri.payment_register_item_id = pr_pri.payment_register_item_id;
    WHEN err_is_not_rur_currency THEN
      --���� ������ �� ��������� �� ����������� ������ ������� ���������
      p_epg_id  := NULL;
      p_status  := 10; --������� ���������
      p_comment := p_comment || ' �������� ������� ';
  END recognize_epg;

  ------------------------------------------------------------------
  --��������� ������� ������ �� �� ��������� ���
  FUNCTION recognize_fio
  (
    p_fio      VARCHAR2
   ,pl_ph_list t_ph
   ,pr_pri     payment_register_item%ROWTYPE
  )
  ------------------------------------------------------------------
   RETURN t_ph AS
    vt_ph   t_ph;
    v_c     NUMBER;
    v_n_fio VARCHAR2(150) := normalize_string(p_fio);
    v_ids   NUMBER;
  BEGIN
    IF pl_ph_list.count > 0
    THEN
      --������� ������ ��
      FOR i IN pl_ph_list.first .. pl_ph_list.last
      LOOP
        SELECT COUNT(*)
          INTO v_c
          FROM p_policy_contact pc
              ,p_policy         p
              ,contact          c
         WHERE p.pol_header_id = pl_ph_list(i).policy_header_id
           AND pc.policy_id = p.policy_id
           AND c.contact_id = pc.contact_id
           AND (v_n_fio = normalize_string(c.genitive) OR v_n_fio = normalize_string(c.accusative) OR
               v_n_fio = normalize_string(c.dative) OR v_n_fio = normalize_string(c.instrumental))
           AND pc.contact_policy_role_id IN
               (SELECT id
                  FROM t_contact_pol_role cpr
                 WHERE cpr.brief IN ('�����'
                                    ,'������������'
                                    ,'�������������� ����'));
      
        IF v_c > 0
        THEN
          --���� ����� �������� - ��������� �� � ������
          vt_ph(vt_ph.count + 1) := pl_ph_list(i);
        END IF;
      END LOOP;
    
      -- ������ �. 218934 �������� �������� �� ��������� � ������� ����������
      IF pl_ph_list.count = 1
      THEN
        v_ids := pl_ph_list(pl_ph_list.count).ids;
        UPDATE ins.payment_register_item pri
           SET pri.ids = v_ids
         WHERE pri.payment_register_item_id = pr_pri.payment_register_item_id;
      END IF;
    END IF;
  
    RETURN vt_ph;
  END recognize_fio;

  ------------------------------------------------------------------
  --��������� ������� ������ �� �� ��������� �����
  FUNCTION recognize_serial
  (
    p_serial   VARCHAR2
   ,pl_ph_list t_ph
   ,pr_pri     payment_register_item%ROWTYPE
  )
  ------------------------------------------------------------------
   RETURN t_ph AS
    vt_ph t_ph;
    v_c   NUMBER;
    v_ids NUMBER;
  BEGIN
    --������� ������ ��
    IF pl_ph_list.count > 0
    THEN
      FOR i IN pl_ph_list.first .. pl_ph_list.last
      LOOP
        --����� ����� ����� ������ ���������
        SELECT COUNT(*)
          INTO v_c
          FROM p_policy p
         WHERE p.pol_header_id = pl_ph_list(i).policy_header_id
           AND TRIM(p.pol_ser) = TRIM(p_serial);
      
        IF v_c > 0
        THEN
          --���� ����� �������� - ��������� �� � ������
          vt_ph(vt_ph.count + 1) := pl_ph_list(i);
        END IF;
      END LOOP;
    
      -- ������ �. 218934 �������� �������� �� ��������� � ������� ����������
      IF pl_ph_list.count = 1
      THEN
        v_ids := pl_ph_list(pl_ph_list.count).ids;
        UPDATE ins.payment_register_item pri
           SET pri.ids = v_ids
         WHERE pri.payment_register_item_id = pr_pri.payment_register_item_id;
      END IF;
    END IF;
  
    RETURN vt_ph;
  END recognize_serial;

  ------------------------------------------------------------------
  --��������� ������ ��������� �� �� ��������� ���������� �������
  PROCEDURE recognize_purpose
  (
    p_payment_purpose VARCHAR2
   ,pr_pri            payment_register_item%ROWTYPE
   ,pl_ph_list        OUT t_ph
   ,p_status          OUT NUMBER
   ,p_comment         IN OUT VARCHAR2
  )
  ------------------------------------------------------------------
   AS
    v_u_str     VARCHAR2(2000);
    v_no_double BOOLEAN := TRUE;
    v_c_doc     NUMBER := 0;
    v_ids       NUMBER;
  BEGIN
    p_comment := p_comment || '������ ���������� �������:';
    v_u_str   := upper(p_payment_purpose);
  
    --���� ���� ��-�������� - ������� �� ����, �� ���� ���
    FOR x IN (SELECT /*+ NO_MERGE(p) LEADING (p pc cpr c) USE_NL (p pc cpr c)*/
              DISTINCT p.pol_header_id
                      ,s
                      ,upper(c.name) NAME
                      ,upper(regexp_substr(c.genitive, '[[:alpha:]]{1,}')) genitive
                      ,upper(regexp_substr(c.accusative, '[[:alpha:]]{1,}')) accusative
                      ,upper(regexp_substr(c.dative, '[[:alpha:]]{1,}')) dative
                      ,upper(regexp_substr(c.instrumental, '[[:alpha:]]{1,}')) instrumental
                FROM p_policy_contact   pc
                    ,contact            c
                    ,t_contact_pol_role cpr
                    ,(                 WITH nn AS (SELECT DISTINCT CASE
                                                                    WHEN (length(numb) < 6) THEN
                                                                     lpad(numb, 6, '0')
                                                                  --��������� ���������� ���� ����� ��� ����� 6-�� ��������
                                                                    ELSE
                                                                     numb
                                                                  END numb
                                                    FROM (SELECT regexp_substr(p_payment_purpose
                                                                              ,'[[:digit:]]{5,}'
                                                                              ,1
                                                                              ,rownum) AS numb
                                                            FROM dual
                                                          CONNECT BY regexp_instr(p_payment_purpose
                                                                                 ,'[[:digit:]]{5,}'
                                                                                 ,1
                                                                                 ,rownum) > 1)
                                                   WHERE numb IS NOT NULL)
                       SELECT p.policy_id
                             ,p.pol_header_id
                             ,3 s
                         FROM p_policy p
                             ,nn
                        WHERE p.pol_num = nn.numb
                       
                       UNION
                       SELECT /*+ INDEX (p IX_P_POLICY_NOTICE_NUM)*/
                        p.policy_id
                       ,p.pol_header_id
                       ,2 s
                         FROM p_policy p
                             ,nn
                        WHERE p.notice_num LIKE substr(nn.numb, 1, 6) || '%'
                       UNION
                       /*SELECT \*+ INDEX (p IX_POL_HEADER)*\
                        p.policy_id
                       ,p.pol_header_id
                       ,1 s
                         FROM p_policy p
                        WHERE p.pol_header_id IN
                              (SELECT ph.policy_header_id
                                 FROM p_pol_header ph
                                     ,nn
                                WHERE length(nn.numb) IN (9, 10)
                                  AND to_char(ph.ids) LIKE nn.numb || '%')*/
                       SELECT /*+index(ph IX_POL_HEADER_IDS_UK_FB) use_nl(ph p)*/
                        p.policy_id
                       ,p.pol_header_id
                       ,1 s
                         FROM p_pol_header ph
                             ,p_policy     p
                             ,nn
                        WHERE length(nn.numb) IN (9, 10)
                          AND to_char(ph.ids) LIKE nn.numb || '%'
                          AND ph.policy_header_id = p.pol_header_id) p
                        WHERE p.policy_id = pc.policy_id
                          AND c.contact_id = pc.contact_id
                          AND pc.contact_policy_role_id = cpr.id
                          AND cpr.brief IN ('�����'
                                           ,'������������'
                                           ,'�������������� ����')
              )
    LOOP
      v_no_double := TRUE;
      v_c_doc     := v_c_doc + 1;
    
      IF x.s = 1
         OR instr(v_u_str, x.name) <> 0
         OR instr(v_u_str, x.genitive) <> 0
         OR instr(v_u_str, x.accusative) <> 0
         OR instr(v_u_str, x.dative) <> 0
         OR instr(v_u_str, x.instrumental) <> 0
      THEN
        IF pl_ph_list.count > 0
        THEN
          FOR i IN pl_ph_list.first .. pl_ph_list.last
          LOOP
            IF pl_ph_list(i).policy_header_id = x.pol_header_id
            THEN
              v_no_double := FALSE;
            END IF;
          END LOOP;
        END IF;
      
        IF v_no_double
        THEN
          SELECT *
            INTO pl_ph_list(pl_ph_list.count + 1)
            FROM p_pol_header ph
           WHERE ph.policy_header_id = x.pol_header_id;
        END IF;
      END IF;
    END LOOP;
  
    IF v_c_doc = 0
    THEN
      p_status  := 20;
      p_comment := p_comment || '� ���������� ������� ��� �������, ��������������� �� ��� ���';
    ELSIF pl_ph_list.count = 0
    THEN
      p_status  := 20;
      p_comment := p_comment || '�� ������ �� �� ���';
    ELSIF pl_ph_list.count > 0
    THEN
      p_status := 10; -- ������� ���������
    
      FOR i IN pl_ph_list.first .. pl_ph_list.last
      LOOP
        p_comment := p_comment || CASE i
                       WHEN 1 THEN
                        '��������� �������� - '
                       ELSE
                        ', '
                     END || pl_ph_list(i).ids;
      END LOOP;
    
      -- ������ �. 218934 �������� �������� �� ��������� � ������� ����������
      IF pl_ph_list.count = 1
      THEN
        v_ids := pl_ph_list(pl_ph_list.count).ids;
        UPDATE ins.payment_register_item pri
           SET pri.ids = v_ids
         WHERE pri.payment_register_item_id = pr_pri.payment_register_item_id;
      END IF;
    END IF;
  END recognize_purpose;

  /*
    ������ �.
    ����� ������� �� � ��������� ��������� ��� ���������� �������������
  */
  PROCEDURE insert_register_item
  (
    par_register_item_id     IN OUT payment_register_item.payment_register_item_id%TYPE
   ,par_payment_sum          payment_register_item.payment_sum%TYPE
   ,par_payment_currency     payment_register_item.payment_currency%TYPE
   ,par_payment_purpose      payment_register_item.payment_purpose%TYPE
   ,par_commission_currency  payment_register_item.commission_currency%TYPE
   ,par_ac_payment_id        payment_register_item.ac_payment_id%TYPE DEFAULT NULL
   ,par_payment_id           payment_register_item.payment_id%TYPE DEFAULT NULL
   ,par_doc_num              payment_register_item.doc_num%TYPE DEFAULT NULL
   ,par_payment_data         payment_register_item.payment_data%TYPE DEFAULT NULL
   ,par_payer_fio            payment_register_item.payer_fio%TYPE DEFAULT NULL
   ,par_payer_birth          payment_register_item.payer_birth%TYPE DEFAULT NULL
   ,par_payer_address        payment_register_item.payer_address%TYPE DEFAULT NULL
   ,par_payer_id_name        payment_register_item.payer_id_name%TYPE DEFAULT NULL
   ,par_payer_id_ser_num     payment_register_item.payer_id_ser_num%TYPE DEFAULT NULL
   ,par_payer_id_issuer      payment_register_item.payer_id_issuer%TYPE DEFAULT NULL
   ,par_payer_id_issue_date  payment_register_item.payer_id_issue_date%TYPE DEFAULT NULL
   ,par_pol_ser              payment_register_item.pol_ser%TYPE DEFAULT NULL
   ,par_pol_num              payment_register_item.pol_num%TYPE DEFAULT NULL
   ,par_ids                  payment_register_item.ids%TYPE DEFAULT NULL
   ,par_insured_fio          payment_register_item.insured_fio%TYPE DEFAULT NULL
   ,par_commission           payment_register_item.commission%TYPE DEFAULT 0
   ,par_territory            payment_register_item.territory%TYPE DEFAULT NULL
   ,par_add_info             payment_register_item.add_info%TYPE DEFAULT NULL
   ,par_status               payment_register_item.status%TYPE DEFAULT NULL
   ,par_is_dummy             payment_register_item.is_dummy%TYPE DEFAULT NULL
   ,par_set_off_state        payment_register_item.set_off_state%TYPE DEFAULT NULL
   ,par_collection_method_id payment_register_item.collection_method_id%TYPE DEFAULT NULL
  ) IS
  BEGIN
    IF par_register_item_id IS NULL
    THEN
      SELECT s_register_load_id.nextval INTO par_register_item_id FROM dual;
    END IF;
  
    INSERT INTO payment_register_item
      (payment_register_item_id
      ,ac_payment_id
      ,payment_id
      ,doc_num
      ,payment_data
      ,payer_fio
      ,payer_birth
      ,payer_address
      ,payer_id_name
      ,payer_id_ser_num
      ,payer_id_issuer
      ,payer_id_issue_date
      ,payment_purpose
      ,pol_ser
      ,pol_num
      ,ids
      ,insured_fio
      ,payment_sum
      ,payment_currency
      ,commission
      ,commission_currency
      ,territory
      ,add_info
      ,status
      ,is_dummy
      ,set_off_state
      ,collection_method_id)
    VALUES
      (par_register_item_id
      ,par_ac_payment_id
      ,par_payment_id
      ,par_doc_num
      ,par_payment_data
      ,par_payer_fio
      ,par_payer_birth
      ,par_payer_address
      ,par_payer_id_name
      ,par_payer_id_ser_num
      ,par_payer_id_issuer
      ,par_payer_id_issue_date
      ,par_payment_purpose
      ,par_pol_ser
      ,par_pol_num
      ,par_ids
      ,par_insured_fio
      ,par_payment_sum
      ,par_payment_currency
      ,par_commission
      ,par_commission_currency
      ,par_territory
      ,par_add_info
      ,par_status
      ,par_is_dummy
      ,par_set_off_state
      ,par_collection_method_id);
  END insert_register_item;
  ------------------------------------------------------------------
  --�������� ������� �� ������������� �������
  PROCEDURE cre_register(p_load_num NUMBER)
  ------------------------------------------------------------------
   AS
    v_set_off_state NUMBER;
  BEGIN
    SAVEPOINT oops;
  
    --������ 169699 ��������� - ������ ������ ��������� ��
    BEGIN
      SELECT CASE
               WHEN pri.set_off_state = 1 THEN
                1 --����� � ����������� xx_lov_list
               ELSE
                21 --NULL � ����������� xx_lov_list
             END
        INTO v_set_off_state
        FROM payment_register_item pri
       WHERE ac_payment_id IN
             (SELECT rl.ac_payment_id FROM register_load rl WHERE rl.load_num = p_load_num);
    EXCEPTION
      WHEN no_data_found THEN
        ex.raise('��������. �� ������� ���������� �������� �������, ������������ � ����������� ��');
      WHEN too_many_rows THEN
        ex.raise('��������. �� ��� ��������� �� �������� �������');
    END;
    --
    DELETE FROM payment_register_item
     WHERE ac_payment_id IN
           (SELECT rl.ac_payment_id FROM register_load rl WHERE rl.load_num = p_load_num);
  
    FOR vr_load IN (SELECT rl.register_load_id
                          ,rl.ac_payment_id
                          ,rl.payment_id
                          ,rl.doc_num
                          ,rl.payment_data
                          ,rl.payer_fio
                          ,rl.payer_birth
                          ,rl.payer_address
                          ,rl.payer_id_name
                          ,rl.payer_id_ser_num
                          ,rl.payer_id_issuer
                          ,rl.payer_id_issue_date
                          ,rl.payment_purpose
                          ,rl.pol_ser
                          ,rl.pol_num
                          ,rl.ids
                          ,rl.insured_fio
                          ,rl.payment_sum
                          ,rl.payment_currency
                          ,nvl(rl.commission, 0) AS commission
                          , --������ 15.11.2011 ��� ������ ��������� ��������� �� �������������
                           nvl(rl.commission_currency, rl.payment_currency) AS commission_currency
                          , --������ 15.11.2011 ��� ������ ��������� ��������� �� �������������
                           rl.territory
                          ,rl.add_info
                      FROM register_load rl
                     WHERE rl.load_num = p_load_num)
    LOOP
      insert_register_item(par_register_item_id    => vr_load.register_load_id
                          ,par_payment_sum         => vr_load.payment_sum
                          ,par_payment_currency    => vr_load.payment_currency
                          ,par_payment_purpose     => vr_load.payment_purpose
                          ,par_commission_currency => vr_load.commission_currency
                          ,par_ac_payment_id       => vr_load.ac_payment_id
                          ,par_payment_id          => vr_load.payment_id
                          ,par_doc_num             => vr_load.doc_num
                          ,par_payment_data        => vr_load.payment_data
                          ,par_payer_fio           => vr_load.payer_fio
                          ,par_payer_birth         => vr_load.payer_birth
                          ,par_payer_address       => vr_load.payer_address
                          ,par_payer_id_name       => vr_load.payer_id_name
                          ,par_payer_id_ser_num    => vr_load.payer_id_ser_num
                          ,par_payer_id_issuer     => vr_load.payer_id_issuer
                          ,par_payer_id_issue_date => vr_load.payer_id_issue_date
                          ,par_pol_ser             => vr_load.pol_ser
                          ,par_pol_num             => vr_load.pol_num
                          ,par_ids                 => vr_load.ids
                          ,par_insured_fio         => vr_load.insured_fio
                          ,par_commission          => vr_load.commission
                          ,par_territory           => vr_load.territory
                          ,par_add_info            => vr_load.add_info
                          ,par_status              => 0
                          ,par_is_dummy            => 0 --�����
                          ,par_set_off_state       => v_set_off_state);
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK TO oops;
      RAISE;
  END cre_register;

  ------------------------------------------------------------------
  --�������� �������������� ������� � ����� ������� �� ��������� ������ ��
  PROCEDURE cre_dummy_register(p_payment_id NUMBER)
  ------------------------------------------------------------------
   AS
    v_c             NUMBER;
    v_set_off_state ins.ac_payment.set_off_state%TYPE;
  BEGIN
    SELECT nvl(COUNT(*), 0)
      INTO v_c
      FROM payment_register_item i
     WHERE i.ac_payment_id = p_payment_id;
  
    --������ /259009: ����� ������ ��� �������� ������ ��� (�� ������/
    SELECT ac.set_off_state
      INTO v_set_off_state
      FROM ins.ac_payment ac
     WHERE ac.payment_id = p_payment_id;
    --
  
    --���� ��� ������ ��� - �������� ��������
    IF v_c = 0
    THEN
      INSERT INTO payment_register_item
        (ac_payment_id
        ,doc_num
        ,payment_data
        ,payer_fio
        ,payment_purpose
        ,payment_sum
        ,payment_currency
        ,commission_currency
        ,status
        ,recognized_payment_id
        ,ids
        ,is_dummy
        ,set_off_state)
        SELECT ap.payment_id
              ,NULL --,d1.num doc_num ����������� �� ������ 284498 ������ 275617 /������/
              ,ap.due_date payment_data
              ,nvl(ap.contact_name
                  ,(SELECT ent.obj_name(c.ent_id, c.contact_id)
                     FROM contact c
                    WHERE c.contact_id = ap.contact_id)) payer_fio
              ,nvl(d.note /*|| ' ' || d1.note*/, 'NULL') payment_purpose
               --,nvl(dso.set_off_child_amount, ap.amount) payment_sum  --����������� �� ������ 284498 ������ 275617 /������/
              ,ap.amount payment_sum
              ,(SELECT f.brief FROM fund f WHERE f.fund_id = ap.fund_id) payment_currency
              ,(SELECT f.brief FROM fund f WHERE f.fund_id = ap.fund_id) commission_currency
               /*
                 ����������� �� ������ 284498 ������ 275617 /������/
               ,CASE
                  WHEN dso.doc_set_off_id IS NOT NULL THEN
                   40
                  ELSE
                   0 --20--
                END*/
              ,0
               --,dso.parent_doc_id --����������� �� ������ 284498 ������ 275617 /������/
              ,NULL
               --,get_ids4dso(dso.doc_set_off_id) --����������� �� ������ 284498 ������ 275617 /������/
              ,NULL
              ,1
               -- ������ �.
               -- � ����������� �������, ������ ������ ��������� 'NULL'
              ,nvl(v_set_off_state
                  , --������ /259009: ����� ������ ��� �������� ������ ��� (�� ������/
                   21) -- 'NULL' � ����������� xx_lov_list
          FROM ac_payment ap
              ,document   d
        /*,doc_set_off dso --����������� �� ������ 284498 ������ 275617 /������/
        ,document    d1*/
         WHERE ap.payment_id = p_payment_id
           AND d.document_id = ap.payment_id;
      --AND dso.child_doc_id(+) = ap.payment_id --����������� �� ������ 284498 ������ 275617 /������/
      --AND d1.document_id(+) = dso.parent_doc_id;
    END IF;
  END cre_dummy_register;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 29.03.2010 19:12:22
  -- Purpose : ����������� �� � ��������� ������ ��� ��������� ������� � �� ��������������� �����������.
  PROCEDURE register_old_setoff(p_set_off_id PLS_INTEGER) IS
    proc_name    VARCHAR2(25) := 'Register_old_setoff';
    v_pri_id     PLS_INTEGER;
    v_pay_id     PLS_INTEGER;
    v_acp_templ  VARCHAR2(30);
    v_amt_remain NUMBER;
    --v_amt_init   NUMBER;
    v_changed_by VARCHAR2(100) := get_current_user;
    v_ids        p_pol_header.ids%TYPE;
  BEGIN
    SELECT dso.pay_registry_item
          ,dt.brief
      INTO v_pri_id
          ,v_acp_templ
      FROM doc_set_off    dso
          ,ven_ac_payment acp
          ,doc_templ      dt
     WHERE dso.doc_set_off_id = p_set_off_id
       AND dso.child_doc_id = acp.payment_id
       AND dt.doc_templ_id = acp.doc_templ_id;
  
    IF v_acp_templ NOT IN ('��', '��_��', '��_��', '�����')
    THEN
      RETURN;
    END IF;
    --pkg_renlife_utils.tmp_log_writer(' 1)  '||v_pri_id);
  
    IF v_pri_id IS NULL
    THEN
      BEGIN
        SELECT pri.payment_register_item_id
          INTO v_pri_id
          FROM doc_set_off           dso
              ,payment_register_item pri
         WHERE dso.child_doc_id = pri.ac_payment_id
           AND pri.is_dummy = 1
           AND dso.doc_set_off_id = p_set_off_id;
      
        UPDATE doc_set_off dso
           SET dso.pay_registry_item = v_pri_id
         WHERE dso.doc_set_off_id = p_set_off_id;
      
        SELECT pri.payment_sum - SUM(dso.set_off_child_amount)
          INTO v_amt_remain
          FROM payment_register_item pri
              ,doc_set_off           dso
         WHERE pri.payment_register_item_id = v_pri_id
           AND dso.pay_registry_item = pri.payment_register_item_id
         GROUP BY pri.payment_sum;
      
        IF v_amt_remain < 0.1
        THEN
          -- ������ �.
          -- ������ 137517
          -- ��������� ��� �� ������������ �������
          BEGIN
            SELECT nvl(ph1.ids, ph2.ids)
              INTO v_ids
              FROM doc_set_off  dso
                  ,doc_doc      dd1
                  ,p_policy     pp1
                  ,p_pol_header ph1
                  ,doc_doc      dd2_1
                  ,doc_set_off  dso2
                  ,doc_doc      dd2
                  ,p_policy     pp2
                  ,p_pol_header ph2
             WHERE dso.pay_registry_item = v_pri_id
                  --����� ����� ������ �������� � �� �� ���
               AND dso.parent_doc_id = dd1.child_id(+)
               AND dd1.parent_id = pp1.policy_id(+)
               AND pp1.pol_header_id = ph1.policy_header_id(+)
                  --����� ����� ������ �������� � �� �� ����� �7/��4
               AND dso.parent_doc_id = dd2_1.child_id(+)
               AND dd2_1.parent_id = dso2.child_doc_id(+)
               AND dso2.parent_doc_id = dd2.child_id(+)
               AND dd2.parent_id = pp2.policy_id(+)
               AND pp2.pol_header_id = ph2.policy_header_id(+)
               AND doc.get_doc_status_brief(dso.doc_set_off_id) != 'ANNULATED'
             GROUP BY nvl(ph1.ids, ph2.ids);
          EXCEPTION
            WHEN no_data_found
                 OR too_many_rows THEN
              v_ids := NULL;
          END;
        
          UPDATE payment_register_item pri
             SET pri.status        = 40
                ,recognize_data    = SYSDATE
                ,pri.changed_by    = v_changed_by
                ,pri.note          = '��������� �������'
                ,pri.set_off_state =
                 (SELECT l.val
                    FROM xx_lov_list l
                   WHERE l.name = 'PAYMENT_SET_OFF_STATE'
                     AND l.description = '���������')
                 -- ������ �.
                 -- ������ 137517
                ,pri.pol_num = CASE
                                 WHEN v_ids IS NOT NULL THEN
                                  nvl(to_char(pri.ids), pri.pol_num)
                                 ELSE
                                  pri.pol_num
                               END
                ,pri.ids     = v_ids
           WHERE pri.payment_register_item_id = v_pri_id;
        ELSE
          UPDATE payment_register_item pri
             SET pri.status        = 30
                ,recognize_data    = SYSDATE
                ,pri.changed_by    = v_changed_by
                ,pri.note          = '��������� �������'
                ,pri.set_off_state =
                 (SELECT l.val
                    FROM xx_lov_list l
                   WHERE l.name = 'PAYMENT_SET_OFF_STATE'
                     AND l.description = '���������')
           WHERE pri.payment_register_item_id = v_pri_id;
        END IF;
      
      EXCEPTION
        WHEN no_data_found THEN
        
          SELECT dso.child_doc_id
                ,acp.amount - dso.set_off_child_amount
            INTO v_pay_id
                ,v_amt_remain
            FROM doc_set_off dso
                ,ac_payment  acp
           WHERE dso.doc_set_off_id = p_set_off_id
             AND acp.payment_id = dso.child_doc_id;
        
          SELECT s_register_load_id.nextval INTO v_pri_id FROM dual;
        
          IF v_amt_remain < 0.1
          THEN
          
            INSERT INTO payment_register_item
              (payment_register_item_id
              ,ac_payment_id
              ,doc_num
              ,payment_data
              ,payer_fio
              ,payment_purpose
              ,payment_sum
              ,payment_currency
              ,commission_currency
              ,status
              ,recognized_payment_id
              ,ids
              ,is_dummy
              ,recognize_data
              ,changed_by
              ,note
              ,set_off_state)
              SELECT v_pri_id
                    ,ap.payment_id
                    ,ap.num
                    ,ap.due_date payment_data
                    ,(SELECT ent.obj_name(c.ent_id, c.contact_id)
                        FROM contact c
                       WHERE c.contact_id = ap.contact_id) payer_fio
                    ,nvl(ap.note, 'NULL') payment_purpose
                    ,ap.amount payment_sum
                    ,f.brief
                    ,f.brief
                    ,40
                    ,dso.parent_doc_id
                    ,get_ids4dso(dso.doc_set_off_id)
                    ,1
                    ,SYSDATE
                    ,v_changed_by
                    ,'��������� �������'
                    ,(SELECT l.val
                       FROM xx_lov_list l
                      WHERE l.name = 'PAYMENT_SET_OFF_STATE'
                        AND l.description = '���������')
                FROM ven_ac_payment ap
                    ,fund           f
                    ,doc_set_off    dso
               WHERE 1 = 1
                 AND dso.doc_set_off_id = p_set_off_id
                 AND dso.child_doc_id = ap.payment_id
                 AND f.fund_id = ap.fund_id;
          
          ELSE
            INSERT INTO payment_register_item
              (payment_register_item_id
              ,ac_payment_id
              ,doc_num
              ,payment_data
              ,payer_fio
              ,payment_purpose
              ,payment_sum
              ,payment_currency
              ,commission_currency
              ,status
              ,recognized_payment_id
              ,ids
              ,is_dummy
              ,recognize_data
              ,changed_by
              ,note
              ,set_off_state)
              SELECT v_pri_id
                    ,ap.payment_id
                    ,ap.num
                    ,ap.due_date payment_data
                    ,(SELECT ent.obj_name(c.ent_id, c.contact_id)
                        FROM contact c
                       WHERE c.contact_id = ap.contact_id) payer_fio
                    ,nvl(ap.note, 'NULL') payment_purpose
                    ,ap.amount payment_sum
                    ,f.brief
                    ,f.brief
                    ,30
                    ,NULL
                    ,NULL
                    ,1
                    ,SYSDATE
                    ,v_changed_by
                    ,'��������� �������'
                    ,(SELECT l.val
                       FROM xx_lov_list l
                      WHERE l.name = 'PAYMENT_SET_OFF_STATE'
                        AND l.description = '���������')
                FROM ven_ac_payment ap
                    ,fund           f
                    ,doc_set_off    dso
               WHERE 1 = 1
                 AND dso.doc_set_off_id = p_set_off_id
                 AND dso.child_doc_id = ap.payment_id
                 AND f.fund_id = ap.fund_id;
          
          END IF;
        
          UPDATE doc_set_off dso
             SET dso.pay_registry_item = v_pri_id
           WHERE dso.child_doc_id = v_pay_id
             AND dso.pay_registry_item IS NULL;
      END;
    ELSE
      SELECT pri.payment_sum - SUM(dso.set_off_child_amount)
        INTO v_amt_remain
        FROM payment_register_item pri
            ,doc_set_off           dso
       WHERE pri.payment_register_item_id = v_pri_id
         AND dso.pay_registry_item = pri.payment_register_item_id
       GROUP BY pri.payment_sum;
    
      --pkg_renlife_utils.tmp_log_writer(' x)  '||v_amt_remain);
      -- ������ �.
      -- ������ 137517
      -- ��������� ��� �� ������������ �������
      BEGIN
        SELECT nvl(ph1.ids, ph2.ids)
          INTO v_ids
          FROM doc_set_off  dso
              ,doc_doc      dd1
              ,p_policy     pp1
              ,p_pol_header ph1
              ,doc_doc      dd2_1
              ,doc_set_off  dso2
              ,doc_doc      dd2
              ,p_policy     pp2
              ,p_pol_header ph2
         WHERE dso.pay_registry_item = v_pri_id
              --����� ����� ������ �������� � �� �� ���
           AND dso.parent_doc_id = dd1.child_id(+)
           AND dd1.parent_id = pp1.policy_id(+)
           AND pp1.pol_header_id = ph1.policy_header_id(+)
              --����� ����� ������ �������� � �� �� ����� �7/��4
           AND dso.parent_doc_id = dd2_1.child_id(+)
           AND dd2_1.parent_id = dso2.child_doc_id(+)
           AND dso2.parent_doc_id = dd2.child_id(+)
           AND dd2.parent_id = pp2.policy_id(+)
           AND pp2.pol_header_id = ph2.policy_header_id(+)
           AND doc.get_doc_status_brief(dso.doc_set_off_id) != 'ANNULATED'
         GROUP BY nvl(ph1.ids, ph2.ids);
      EXCEPTION
        WHEN no_data_found
             OR too_many_rows THEN
          v_ids := NULL;
      END;
      IF v_amt_remain < 0.1
      THEN
        UPDATE payment_register_item pri
           SET pri.status        = 40
              ,recognize_data    = SYSDATE
              ,pri.changed_by    = v_changed_by
              ,pri.note          = '��������� �������'
              ,pri.set_off_state =
               (SELECT l.val
                  FROM xx_lov_list l
                 WHERE l.name = 'PAYMENT_SET_OFF_STATE'
                   AND l.description = '���������')
               -- ������ �.
               -- ������ 137517
              ,pri.pol_num = CASE
                               WHEN v_ids IS NOT NULL THEN
                                nvl(to_char(pri.ids), pri.pol_num)
                               ELSE
                                pri.pol_num
                             END
              ,pri.ids     = v_ids
         WHERE pri.payment_register_item_id = v_pri_id;
      ELSE
        UPDATE payment_register_item pri
           SET pri.status        = 30
              ,recognize_data    = SYSDATE
              ,pri.changed_by    = v_changed_by
              ,pri.note          = '��������� �������'
              ,pri.set_off_state =
               (SELECT l.val
                  FROM xx_lov_list l
                 WHERE l.name = 'PAYMENT_SET_OFF_STATE'
                   AND l.description = '���������')
         WHERE pri.payment_register_item_id = v_pri_id;
      END IF;
    
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'������ ��� ���������� ' || proc_name || SQLERRM);
  END register_old_setoff;

  ------------------------------------------------------------------
  --�������� ������� ��� ��
  PROCEDURE del_register
  (
    p_payment_id              NUMBER
   ,par_create_dummy_register BOOLEAN DEFAULT TRUE
  )
  ------------------------------------------------------------------
   IS
  BEGIN
    SAVEPOINT oops;
  
    --������/253222: ����� ��������/
    DECLARE
      v_check INT;
    BEGIN
      SELECT COUNT(1)
        INTO v_check
        FROM dual
       WHERE EXISTS (SELECT NULL
                FROM ins.payment_register_item pri
                    ,ins.doc_set_off           dso
                    ,ins.document              d
                    ,ins.doc_status_ref        dsr
               WHERE pri.ac_payment_id = p_payment_id
                 AND dso.pay_registry_item = pri.payment_register_item_id
                 AND dso.doc_set_off_id = d.document_id
                 AND d.doc_status_ref_id = dsr.doc_status_ref_id
                 AND dsr.brief != 'ANNULATED');
    
      IF v_check > 0
      THEN
        raise_application_error(-20001
                               ,'� �������� ������� ��������� �������� ��������. �������� �� ��������!');
      END IF;
    END; --end 253222
    --������� 368342 
    -- ������� �� ��� ������� "�������� ������"
    FOR c1 IN (SELECT acq.acq_internet_payment_id id
                 FROM ins.payment_register_item pri
                     ,ins.acq_internet_payment  acq
                WHERE pri.ac_payment_id = p_payment_id
                  AND acq.payment_register_item_id = pri.payment_register_item_id)
    LOOP
      UPDATE ins.acq_internet_payment aip
         SET aip.payment_register_item_id = NULL
       WHERE aip.acq_internet_payment_id = c1.id;
    
      UPDATE acq_oms_registry_det rd
         SET rd.acq_internet_payment_id = NULL
       WHERE rd.acq_internet_payment_id = c1.id;
    
      doc.set_doc_status(p_doc_id => c1.id, p_status_brief => 'NEW');
    END LOOP;
    --end 368342
    -- ������ �.
    -- �� "mPos ���������"
    FOR vr_rec IN (SELECT pn.mpos_payment_notice_id
                         ,pri.payment_register_item_id
                     FROM mpos_payment_notice   pn
                         ,payment_register_item pri
                    WHERE pri.ac_payment_id = p_payment_id
                      AND pri.payment_register_item_id = pn.payment_register_item_id)
    LOOP
      pkg_mpos.unbind_registr_from_pay_notice(par_mpos_payment_notice_id => vr_rec.mpos_payment_notice_id);
    END LOOP;
  
    FOR vr_rec IN (SELECT wn.mpos_writeoff_notice_id
                         ,pri.payment_register_item_id
                     FROM mpos_writeoff_notice  wn
                         ,payment_register_item pri
                    WHERE pri.ac_payment_id = p_payment_id
                      AND pri.payment_register_item_id = wn.payment_register_item_id)
    LOOP
      pkg_mpos.unbind_register_from_wo_notice(par_payment_register_item_id => vr_rec.payment_register_item_id
                                             ,par_mpos_writeoff_notice_id  => vr_rec.mpos_writeoff_notice_id);
    END LOOP;
  
    --����� ������� ����� ��, ���������� ��� �������� �� ����� � ��������������� ����������� ������
    UPDATE ins.doc_set_off dso
       SET dso.pay_registry_item = NULL
     WHERE dso.pay_registry_item IN (SELECT pri.payment_register_item_id
                                       FROM ins.payment_register_item pri
                                      WHERE pri.ac_payment_id = p_payment_id)
       AND doc.get_doc_status_brief(dso.doc_set_off_id) = 'ANNULATED';
  
    DELETE FROM payment_register_item WHERE ac_payment_id = p_payment_id;
  
    --�������� �������� ������ ���������
    IF par_create_dummy_register
    THEN
      cre_dummy_register(p_payment_id);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK TO oops;
      RAISE;
  END del_register;

  ------------------------------------------------------------------
  --��������� ������������� ���������� �������� ������� �������
  PROCEDURE recognize_payment(p_payment_register_item_id NUMBER)
  ------------------------------------------------------------------
   AS
    vr_pri payment_register_item%ROWTYPE;
    vt_ph  t_ph;
    --v_epg_id                  NUMBER;
    --v_pol_header_id           NUMBER;
    v_status                NUMBER;
    v_comment               VARCHAR2(2000);
    v_recognized_payment_id NUMBER;
    v_changed_by            VARCHAR2(100) := get_current_user;
    v_to_set_off            NUMBER;
    --v_c                       NUMBER;
    v_doc_status_set_off NUMBER;
  BEGIN
  
    --���������. ����� ������� ������ ��������� "�����������" �� NULL
    UPDATE ins.payment_register_item pri
       SET pri.set_off_state = 21
     WHERE pri.payment_register_item_id = p_payment_register_item_id
       AND nvl(pri.set_off_state, 0) = 11;
  
    --�������� ������ ������ �������
    SELECT *
      INTO vr_pri
      FROM payment_register_item
     WHERE payment_register_item_id = p_payment_register_item_id;
    -- ������ �.
    -- ������� trim, �.�. ����������� ���������� � POL_NUM ������ ��������� � ���������
    vr_pri.pol_num := TRIM(vr_pri.pol_num);
    --
    OPEN to_set_off(vr_pri.payment_sum, p_payment_register_item_id);
  
    FETCH to_set_off
      INTO v_to_set_off;
  
    CLOSE to_set_off;
    -- �������� ���
    v_doc_status_set_off := pkg_payment_register.check_fms(p_payment_register_item_id);
  
    IF vr_pri.payment_sum > v_to_set_off
    THEN
      UPDATE payment_register_item pri
         SET note = '������� � ������ ������ ����� �������. ������������� ���������!'
       WHERE pri.payment_register_item_id = p_payment_register_item_id;
      RETURN;
    END IF;
    vr_pri.payment_sum := v_to_set_off;
  
    --�������� ������������ ��� � ����� ��
    SELECT * BULK COLLECT INTO vt_ph FROM p_pol_header WHERE ids = vr_pri.ids;
  
    IF vt_ph.count > 0
    THEN
      --�� ������ �� ��� - ������������� ���
      recognize_epg(vt_ph, vr_pri, v_recognized_payment_id, v_status, v_comment);
    
      IF v_recognized_payment_id IS NOT NULL
      THEN
        v_comment := v_comment || '��������� �� ���: ' || to_char(vr_pri.ids);
        v_status  := 50; --��������� �������������
      ELSE
        v_comment := v_comment || '��������� �� ��� ' || to_char(vr_pri.ids) || '. ��� �� ���������.';
        v_status  := 10; --������� ���������
      END IF;
    
      GOTO finish;
    END IF;
  
    --��� ����������� ���� �� ��������
    IF TRIM(vr_pri.pol_num) IS NOT NULL
    THEN
      --����� �� ������ ��������
      /*SELECT DISTINCT ph.*
      BULK COLLECT INTO vt_ph
                 FROM p_pol_header ph
                WHERE ph.policy_header_id IN(
                                SELECT p.pol_header_id
                                  FROM p_policy p
                                 WHERE p.pol_num = vr_pri.pol_num
                                       OR p.notice_num = vr_pri.pol_num
                                       OR substr(p.notice_num,1,6) = vr_pri.pol_num
                                       )
                   OR (ph.ids LIKE vr_pri.pol_num || '%' AND LENGTH(vr_pri.pol_num) IN(9, 10));*/
    
      SELECT DISTINCT ph.*
        BULK COLLECT
        INTO vt_ph
        FROM (SELECT /*+ INDEX (ph PK_P_POL_HEADER )*/
               ph.*
                FROM p_pol_header ph
               WHERE ph.policy_header_id IN
                     (SELECT /*+ USE_CONCAT INDEX (p IX_P_POLICY_NOTICE_NUM)*/
                       p.pol_header_id
                        FROM p_policy p
                       WHERE p.pol_num = vr_pri.pol_num
                          OR p.notice_num = vr_pri.pol_num
                      UNION ALL
                      SELECT /*+ INDEX (p IX_P_POLICY_NOTICE_NUM)*/
                       p.pol_header_id
                        FROM p_policy p
                       WHERE p.notice_num LIKE substr(vr_pri.pol_num, 1, 10) || '%')
              UNION ALL
              SELECT ph.*
                FROM p_pol_header ph
               WHERE ph.ids LIKE vr_pri.pol_num || '%'
                 AND length(vr_pri.pol_num) IN (9, 10)) ph;
      --����� �������� � ������ - �������� �� ����� ������
      IF vt_ph.count > 0
      THEN
        IF length(TRIM(vr_pri.pol_num)) IN (9, 10)
        THEN
          IF vt_ph.count > 0
          THEN
            --������������� ���
            recognize_epg(vt_ph, vr_pri, v_recognized_payment_id, v_status, v_comment);
          
            IF v_recognized_payment_id IS NOT NULL
            THEN
              v_comment := v_comment || '��������� �� ������ ��: ' || to_char(vr_pri.pol_num);
              v_status  := 50; --��������� �������������
            ELSE
              v_comment := v_comment || '��������� �� ������ ��: ' || to_char(vr_pri.pol_num) ||
                           '. ��� �� ���������.';
              v_status  := 10; --������� ���������
            END IF;
          
            GOTO finish;
          END IF;
        ELSE
          --�������� �� ������������� ���� ��� ������������
          IF TRIM(vr_pri.insured_fio) IS NOT NULL
          THEN
            --����� ����� �����, ������������, ��������������
            vt_ph := recognize_fio(vr_pri.insured_fio, vt_ph, vr_pri);
          
            IF vt_ph.count > 0
            THEN
              recognize_epg(vt_ph, vr_pri, v_recognized_payment_id, v_status, v_comment);
            
              IF v_recognized_payment_id IS NOT NULL
              THEN
                v_comment := v_comment || '��������� �� ������ ��: ' || to_char(vr_pri.pol_num) ||
                             ' � ���';
                GOTO finish;
              END IF;
            END IF;
          END IF;
        
          --�������� �� ������������� ����� ��
          IF TRIM(vr_pri.pol_ser) IS NOT NULL
          THEN
            --������������� ��� �� �������� ��
            vt_ph := recognize_serial(vr_pri.pol_ser, vt_ph, vr_pri);
          
            IF vt_ph.count > 0
            THEN
              recognize_epg(vt_ph, vr_pri, v_recognized_payment_id, v_status, v_comment);
            
              IF v_recognized_payment_id IS NOT NULL
              THEN
                v_comment := v_comment || '��������� �� ������ ��: ' || to_char(vr_pri.pol_num) ||
                             ' � ����� ��';
                GOTO finish;
              END IF;
            END IF;
          ELSE
            recognize_epg(vt_ph, vr_pri, v_recognized_payment_id, v_status, v_comment);
          
            IF v_recognized_payment_id IS NOT NULL
            THEN
              v_comment := v_comment || '������� ��������� �� ������ �� : ' || to_char(vr_pri.pol_num) ||
                           '. ��� ���������.';
              GOTO finish;
            END IF;
          END IF;
        END IF;
      END IF;
    END IF;
  
    --���� ������ ���� - �� ������ �� �� ������
    --�������� �� ���� ���������� �������
    IF TRIM(vr_pri.payment_purpose) IS NOT NULL
    THEN
      --������ ���� ���������� �������
      recognize_purpose(vr_pri.payment_purpose, vr_pri, vt_ph, v_status, v_comment);
    
      IF vt_ph.count > 0
      THEN
        --������������� ��� �� �������� ��
        recognize_epg(vt_ph, vr_pri, v_recognized_payment_id, v_status, v_comment);
      
        IF v_recognized_payment_id IS NOT NULL
        THEN
          v_comment := v_comment || '��������� �� ���������� �������.';
          v_status  := 50; --��������� �������������
        ELSE
          v_comment := v_comment || '��������� �� ���������� �������. ��� �� ���������.';
          v_status  := 10; --������� ���������
        END IF;
      END IF;
    
      GOTO finish;
    END IF;
  
    --����  �� ���������
    --������������� �� ���������
    v_comment := '�� ���������� ����������' || v_comment;
  
    --������ ���� ���������� �������
    ---------------------------------
    <<finish>>
    IF v_status IS NULL
    THEN
      v_status := 20;
    END IF;
  
    IF v_comment IS NULL
       AND v_status = 20
    THEN
      v_comment := '�� ���������� ����������';
    END IF;
  
    --������ ���������� �������������
    UPDATE payment_register_item
       SET status                = v_status
          ,recognize_data        = SYSDATE
          ,note                  = v_comment
          ,recognized_payment_id = v_recognized_payment_id
          ,changed_by            = v_changed_by /*,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                         set_off_state = v_doc_status_set_off*/
     WHERE payment_register_item_id = p_payment_register_item_id;
  
    -- 218934 �������� �������� �� ��������� � ������� ����������
    recognize_indexation(p_payment_register_item_id);
  
  END recognize_payment;
  ------------------------------------------
  --������� �������� �� ���
  ------------------------------------------
  FUNCTION check_fms(p_paym_reg_item_id NUMBER) RETURN NUMBER IS
    v_status           NUMBER;
    p_fonpayer         VARCHAR2(2000);
    p_fonnote          VARCHAR2(2000);
    p_upd_field_number VARCHAR2(10);
    p_par_tu           NUMBER;
  BEGIN
  
    BEGIN
      SELECT pkg_contact_finmon.fon_fromcyrtofon(pkg_contact_finmon.fon_fromlattocyr(ii.payer_fio))
            ,pkg_contact_finmon.fon_fromcyrtofon(pkg_contact_finmon.fon_fromlattocyr(ii.note))
        INTO p_fonpayer
            ,p_fonnote
        FROM payment_register_item ii
       WHERE ii.payment_register_item_id = p_paym_reg_item_id;
    EXCEPTION
      WHEN no_data_found THEN
        p_fonpayer := '';
        p_fonnote  := '';
    END;
  
    BEGIN
      SELECT ter.field_number
            ,ter.tu
        INTO p_upd_field_number
            ,p_par_tu
        FROM ins.fms_terror ter
       WHERE (ter.fon_name = p_fonpayer OR ter.fon_name = p_fonnote)
         AND rownum = 1;
    EXCEPTION
      WHEN no_data_found THEN
        p_upd_field_number := '0';
        p_par_tu           := 1;
      WHEN OTHERS THEN
        p_upd_field_number := '0';
        p_par_tu           := 1;
    END;
  
    IF nvl(p_upd_field_number, '0') <> '0'
    THEN
      IF p_par_tu != -1
      THEN
        SELECT l.id
          INTO v_status
          FROM xx_lov_list l
         WHERE l.name = 'PAYMENT_SET_OFF_STATE'
           AND l.description = '���������\����������';
      ELSE
        SELECT l.id
          INTO v_status
          FROM xx_lov_list l
         WHERE l.name = 'PAYMENT_SET_OFF_STATE'
           AND l.description = '��������';
      END IF;
      UPDATE payment_register_item ii
         SET ii.set_off_state = v_status
            ,ii.field_number  = p_upd_field_number
       WHERE ii.payment_register_item_id = p_paym_reg_item_id;
    
      pkg_email.send_mail_with_attachment(par_to      => pkg_email.t_recipients('115fz@Renlife.com')
                                         ,par_subject => '������� ���������� � ������ ������� (������)'
                                         ,par_text    => '������ ����!' || chr(10) ||
                                                         '��� ������� ��������������� ������������� ������� � �� ' ||
                                                         p_paym_reg_item_id ||
                                                         ' ���� ������� ���������� � ������ ������� ���.');
    END IF;
  
    RETURN v_status;
  
  END check_fms;
  ------------------------------------------------------------------
  --��������� ���������� ������������� ������ �������� ��������
  PROCEDURE recognize_payments(pt_pri_list t_number)
  ------------------------------------------------------------------
   AS
  BEGIN
    FOR i IN pt_pri_list.first .. pt_pri_list.last
    LOOP
      recognize_payment(pt_pri_list(i));
    END LOOP;
  END recognize_payments;

  ------------------------------------------------------------------
  --��������� �������� ����� ������������ ������ ������� �������
  PROCEDURE connect_payment(p_payment_register_item_id NUMBER)
  ------------------------------------------------------------------
   AS
    vr_pri                 payment_register_item%ROWTYPE;
    vr_payment             ac_payment%ROWTYPE;
    vr_epg                 ac_payment%ROWTYPE;
    v_doc_templ_id         NUMBER;
    v_doc_templ_pd4_id     NUMBER;
    v_doc_templ_pd4copy_id NUMBER;
    v_doc_templ_epg_id     NUMBER;
    v_dso_id               NUMBER;
    v_to_set_off           NUMBER := 0;
    v_changed_by           VARCHAR2(100) := get_current_user;
    v_err                  VARCHAR2(2000);
    v_payment_exists       NUMBER;
    v_reg_date             DATE;
    v_payment_sum          NUMBER; -- ������� ����� �� ���, ��� ��� ���� ��������
    v_recogn_brief         doc_templ.brief%TYPE;
    -- ������ �.
    -- ������ 137517
    v_ids p_pol_header.ids%TYPE;
    --
    no_rate EXCEPTION;
    --������ ����� ��������� ������������� ��������������
    v_agent_id            NUMBER;
    v_check_agent         INT;
    v_note                VARCHAR(100);
    v_sposob_opl          ven_t_collection_method.description%TYPE;
    v_pp_templ            doc_templ.brief%TYPE;
    v_pri_amount_free     NUMBER; --����������� ������ �� �������� �������
    v_payment_amount_free NUMBER; --����������� ������ �� ���
    vp_set_off_state      NUMBER := 0;
    -----------------------------------------------------
  
    /*      CURSOR to_set_off (reg_sum NUMBER, reg_item INTEGER) IS
    SELECT reg_sum - NVL(SUM(dso1.set_off_child_amount), 0)
      FROM Doc_Set_Off dso1
     WHERE dso1.pay_registry_item = reg_item
       AND dso1.cancel_date IS NULL;*/
  BEGIN
    SAVEPOINT cre_dso;
    --�������� ������ ������ �������
    SELECT i.*
      INTO vr_pri
      FROM payment_register_item i
     WHERE i.payment_register_item_id = p_payment_register_item_id;
  
    OPEN to_set_off(vr_pri.payment_sum, p_payment_register_item_id);
  
    FETCH to_set_off
      INTO v_to_set_off;
  
    CLOSE to_set_off;
  
    /*IF v_to_set_off < 0
    THEN
      UPDATE payment_register_item i
        SET i.note = i.note ||CHR(10)|| '�� �������� �.�. ����� "�������� �������" ������ 0'
      WHERE i.payment_register_item_id = p_payment_register_item_id;
      RETURN;
    END IF;*/
  
    SELECT COUNT(*)
      INTO vp_set_off_state
      FROM xx_lov_list l
     WHERE l.name = 'PAYMENT_SET_OFF_STATE'
       AND l.description IN ('���������\����������', '��������')
       AND l.id = vr_pri.set_off_state;
  
    --��������, ��� ������ ����������
    IF vr_pri.recognized_payment_id IS NOT NULL
       AND vp_set_off_state = 0
    THEN
      --�������� ������ ��
      SELECT * INTO vr_payment FROM ac_payment ap WHERE ap.payment_id = vr_pri.ac_payment_id;
    
      --�������� ������ ���/(A7COPY,PD4COPY)
      SELECT * INTO vr_epg FROM ac_payment ap WHERE ap.payment_id = vr_pri.recognized_payment_id;
    
      --��������. ��� ������ ����������� � ��������� ��������
      check_payment_currency(vr_pri.recognized_payment_id, vr_pri.ac_payment_id);
    
      -- ������ �.
      -- ������ 137517
      -- �������� ��� ��������
      BEGIN
        SELECT ph.ids
          INTO v_ids
          FROM p_policy pp
              ,p_pol_header ph
              ,( -- ���� PAYMENT
                SELECT dd.parent_id
                  FROM doc_doc dd
                 WHERE dd.child_id = vr_pri.recognized_payment_id
                UNION ALL
                -- ���� PD4COPY, A7COPY
                SELECT dd2.parent_id
                  FROM doc_doc     dd
                       ,doc_set_off dso
                       ,doc_doc     dd2
                 WHERE dd.child_id = vr_pri.recognized_payment_id
                   AND dd.parent_id = dso.child_doc_id
                   AND dso.parent_doc_id = dd2.child_id) pa
         WHERE pp.pol_header_id = ph.policy_header_id
           AND pp.policy_id = pa.parent_id;
      EXCEPTION
        WHEN no_data_found THEN
          NULL;
      END;
    
      /*SELECT dt.Doc_Templ_ID
       INTO v_Doc_Templ_ID
       FROM ins.Doc_Templ dt
      WHERE dt.brief = '�����';*/
      SELECT MAX(decode(dt.brief, '�����', dt.doc_templ_id))
            ,MAX(decode(dt.brief, 'PD4', dt.doc_templ_id))
            ,MAX(decode(dt.brief, 'PD4COPY', dt.doc_templ_id))
            ,MAX(decode(dt.brief, 'PAYMENT', dt.doc_templ_id))
        INTO v_doc_templ_id
            ,v_doc_templ_pd4_id
            ,v_doc_templ_pd4copy_id
            ,v_doc_templ_epg_id
        FROM doc_templ dt
       WHERE dt.brief IN ('�����', 'PD4', 'PD4COPY', 'PAYMENT');
    
      -- ��� �� ��� �� ��� ������������ ����������?
      -- ������ �.
      SELECT CASE
               WHEN dc.doc_templ_id = v_doc_templ_epg_id THEN
                0
               ELSE
                1
             END
        INTO v_payment_exists
        FROM document dc
       WHERE dc.document_id = vr_pri.recognized_payment_id;
    
      -- ��������� ����, �� ������� ��� ���� ������ ������������ ��������
      -- ������ �.
      -- �� ������������ �������� �� ���������� ���� ���� ����� ���������� ������������ �������� ���� ���:
      -- ���� ��, ���� ������� � ���� ������� (�� �������)
      IF vr_pri.payment_data IS NULL
      THEN
        v_reg_date := least(vr_payment.due_date, vr_payment.grace_date);
      ELSE
        v_reg_date := least(vr_payment.due_date, vr_payment.grace_date, vr_pri.payment_data);
      END IF;
      --
      --������ 17.11.2011 -- ����� ���������
      /*SELECT LEAST(
              (vr_epg.amount - ins.Pkg_Payment.get_set_off_amount(vr_epg.payment_id, NULL, NULL))
              ,(SELECT vr_pri.payment_sum - NVL(SUM(dso1.set_off_child_amount), 0)
                FROM doc_set_off dso1
                WHERE dso1.pay_registry_item = vr_pri.payment_register_item_id
                AND dso1.cancel_date IS NULL)
                  )
      INTO v_payment_sum
      FROM dual;*/
    
      v_payment_amount_free := vr_epg.amount -
                               ins.pkg_payment.get_set_off_amount(vr_epg.payment_id, NULL, NULL);
      BEGIN
        SELECT vr_pri.payment_sum - nvl(SUM(dso1.set_off_child_amount), 0)
          INTO v_pri_amount_free
          FROM doc_set_off dso1
         WHERE dso1.pay_registry_item = vr_pri.payment_register_item_id
           AND dso1.cancel_date IS NULL;
      EXCEPTION
        WHEN OTHERS THEN
          v_pri_amount_free := NULL;
      END;
    
      v_payment_sum := least(v_payment_amount_free, v_pri_amount_free);
    
      --end ������ 17.11.2011 -- ����� ���������
    
      --������ 11.10.2011 ����� ��������� ������������� ��������������
      --���� �� �������� �������� ���������, �� ������� ��4
      BEGIN
        SELECT ach.agent_id
              ,CASE
                 WHEN ach.agent_id = ppvh.contact_id THEN
                  1
                 ELSE
                  0
               END
              ,cm.description
              ,dt.brief
          INTO v_agent_id
              ,v_check_agent
              ,v_sposob_opl
              ,v_pp_templ
          FROM p_pol_header            ph
              ,p_policy_agent_doc      pad
              ,ven_ag_contract_header  ach
              ,ven_ac_payment          ppvh
              ,ven_t_collection_method cm
              ,doc_templ               dt
              ,document                d_pad
              ,doc_status_ref          dsr_pad
         WHERE ph.policy_header_id =
              --��� ��������, ��������� � ��� �� �� � ����� ������ ��� ����� ����� ������
               (SELECT ph.policy_header_id
                  FROM ven_ac_payment ac
                      ,doc_doc dd
                      ,p_policy p
                      ,p_pol_header ph
                      ,(SELECT dt.doc_templ_id FROM doc_templ dt WHERE dt.brief = 'PAYMENT') dt
                 WHERE ac.payment_id = vr_pri.recognized_payment_id --���
                   AND dd.child_id = ac.payment_id
                   AND p.policy_id = dd.parent_id
                   AND ph.policy_header_id = p.pol_header_id
                   AND dt.doc_templ_id = ac.doc_templ_id
                   AND doc.get_doc_status_brief(ac.payment_id) = 'TO_PAY')
              /* and (ac.amount - nvl((select sum(dso.set_off_amount)
              from doc_set_off dso
                  where dso.parent_doc_id(+) = ac.payment_id),0)) >= vr_pri.payment_sum)*/
              
           AND ph.policy_header_id = pad.policy_header_id
           AND ach.ag_contract_header_id = pad.ag_contract_header_id
           AND ppvh.payment_id = vr_pri.ac_payment_id
           AND cm.id = ppvh.collection_metod_id
           AND dt.doc_templ_id = ppvh.doc_templ_id
           AND d_pad.document_id = pad.p_policy_agent_doc_id
           AND dsr_pad.doc_status_ref_id = d_pad.doc_status_ref_id
              --358225: ��������� �� �����
           AND dsr_pad.brief = 'CURRENT'
           AND ach.with_retention = 1;
      EXCEPTION
        WHEN no_data_found
             OR too_many_rows THEN
          v_agent_id    := NULL;
          v_check_agent := NULL;
          v_sposob_opl  := NULL;
          v_pp_templ    := NULL;
      END;
    
      SAVEPOINT cre_dso;
    
      IF v_payment_exists = 0
        -- ������ �.
        -- ���������� �� � ����� �������, � � ����� ��
         AND v_reg_date != vr_payment.grace_date
         AND v_agent_id IS NULL --������ 11.10.2011 ����� ��������� ������������� ��������������
      THEN
        -- ���������� ����� ��4 � ���.
        v_err := cre_pd4(p_payment_register_item_id);
      
        IF v_err IS NOT NULL
        THEN
          RAISE no_rate;
        END IF;
      ELSIF v_agent_id IS NOT NULL
      THEN
        --���� ���� ����� ����� ���������� �������� ��
        IF v_payment_amount_free < v_pri_amount_free
        THEN
          raise_application_error(-20000
                                 ,'����� ������� ' ||
                                  to_char(v_pri_amount_free
                                         ,'FM999G999G999G990D00'
                                         ,'NLS_NUMERIC_CHARACTERS = '', ''') ||
                                  ' ������ ��� �����, �������  ����� ������� �� ��� ' ||
                                  to_char(v_payment_amount_free
                                         ,'FM999G999G999G990D00'
                                         ,'NLS_NUMERIC_CHARACTERS = '', '''));
          --ROLLBACK TO cre_dso;
          --RETURN;
        END IF;
        IF v_pp_templ = '�����'
        THEN
          --:���� ��� ��������� ��, �� ������� �������� ����� ���������
          v_err := cre_zachet_ucv(p_payment_register_item_id);
          IF v_err IS NOT NULL
          THEN
            RAISE no_rate;
          END IF;
        ELSE
          --:���� ��� ������, �� ������� ��4
          v_err := cre_pd4(p_payment_register_item_id);
        
          IF v_err IS NOT NULL
          THEN
            RAISE no_rate;
          END IF;
        END IF;
      ELSE
        -- ��� ������ ���������� ����� �� � ���
        SELECT ins.sq_doc_set_off.nextval INTO v_dso_id FROM dual;
        INSERT INTO ins.ven_doc_set_off vdso
          (doc_set_off_id
          ,doc_templ_id
          ,note
          ,reg_date
          ,child_doc_id
          ,parent_doc_id
          ,set_off_amount
          ,set_off_child_amount
          ,set_off_child_fund_id
          ,set_off_date
          ,set_off_fund_id
          ,set_off_rate
          ,pay_registry_item)
        VALUES
          (v_dso_id
          ,v_doc_templ_id
          ,'�������� ������ ��� �������� �� �� NAVISION'
          ,SYSDATE
          ,vr_payment.payment_id
          ,vr_epg.payment_id
          ,v_payment_sum
          ,v_payment_sum
          ,vr_payment.fund_id
          ,SYSDATE
          ,vr_epg.fund_id
          ,vr_payment.rev_rate
          ,vr_pri.payment_register_item_id);
      
        --������ ��� ������ �� "�����" - ��� ���� �� ������������
        doc.set_doc_status(v_dso_id, 'NEW', vr_payment.due_date);
      END IF;
    
      --�������� ����� ��� ����������
      UPDATE ac_payment ap
         SET ap.set_off_state =
             (SELECT l.val
                FROM xx_lov_list l
               WHERE l.name = 'PAYMENT_SET_OFF_STATE'
                 AND l.description = '���������')
       WHERE ap.payment_id = vr_payment.payment_id;
    
      --������ 11.10.2011 ����� ��������� ������������� ��������������
      /*IF (v_agent_id is not null) and (v_pp_templ != '�����')
        THEN v_note := '������� ��4<���';
                   ELSE v_note := '�������';
      END IF;*/
      v_note := '�������';
    
      --������ ���������� ��������
      UPDATE payment_register_item
         SET status         = 40
            , --�������
             recognize_data = SYSDATE
            ,note           = v_note
            ,changed_by     = v_changed_by
            ,set_off_state =
             (SELECT l.val
                FROM xx_lov_list l
               WHERE l.name = 'PAYMENT_SET_OFF_STATE'
                 AND l.description = '���������')
             -- ������ �.
             -- ������ 137517
             -- �������� ��� � ����� �� (�� ������������ ���, ���� �� �� ������) �� ���������� ���
            ,pol_num = nvl(to_char(ids), TRIM(pol_num))
            ,ids     = v_ids
      --
       WHERE payment_register_item_id = p_payment_register_item_id;
    ELSE
      IF vr_pri.set_off_state = vp_set_off_state
      THEN
        UPDATE payment_register_item
           SET recognize_data = SYSDATE
              ,note           = '��������! ������ ������ �� ������ �������� ���, �������������� �������� ���������.'
         WHERE payment_register_item_id = p_payment_register_item_id;
      END IF;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK TO cre_dso;
      IF v_err IS NULL
      THEN
        v_err := SQLERRM;
      END IF;
    
      --������ ���������� ��������
      UPDATE payment_register_item
         SET recognize_data = SYSDATE
            ,note           = v_err
            , -- ������ ������ � �����������
             changed_by     = v_changed_by
       WHERE payment_register_item_id = p_payment_register_item_id;
  END connect_payment;

  ------------------------------------------------------------------
  --��������� ��������� �������� ������ ������������ ����� ������� �������
  PROCEDURE connect_payments(pt_pri_list t_number)
  ------------------------------------------------------------------
   AS
  BEGIN
    FOR i IN pt_pri_list.first .. pt_pri_list.last
    LOOP
      connect_payment(pt_pri_list(i));
    END LOOP;
  END connect_payments;

  ------------------------------------------------------------------
  --��������� ����� �� � ��� ����� ��4
  -- ���������� �.�., 2011.06.01
  -- !!! ������� ��� ��������� (���� ����������, ������ ���) - � ����������� ����������.
  FUNCTION cre_pd4
  (
    p_pri                 NUMBER
   ,ap_epg_id             NUMBER DEFAULT NULL
   ,p_list_set_off_amount NUMBER DEFAULT NULL -- ������ �. ������ 242293 (���������� "� ������" � ������� ���������)
  )
  ------------------------------------------------------------------
   RETURN VARCHAR2 IS
    v_pd4_payment_id       NUMBER;
    v_pd4_copy_id          NUMBER;
    v_dso1_id              NUMBER;
    v_dso2_id              NUMBER;
    v_docdoc_id            NUMBER;
    v_payment_sum          NUMBER;
    v_pp_payment_id        NUMBER;
    v_pp_fund_id           NUMBER;
    v_epg_fund_id          NUMBER;
    v_pp_fund_brief        VARCHAR2(50);
    v_epg_fund_brief       VARCHAR2(50);
    v_epg_rev_amount       NUMBER;
    v_epg_rev_fund_id      NUMBER;
    v_epg_rev_rate         NUMBER;
    v_epg_rev_rate_type_id NUMBER;
    v_epg_contact_id       NUMBER;
    --v_pd4_num         NUMBER;
    v_pd4_doc_templ  NUMBER;
    v_epg_payment_id NUMBER;
    v_rate           NUMBER;
    v_pri_data       DATE;
    v_doc_num        VARCHAR2(100);
    v_dso_note       VARCHAR2(200) := '�������� ������ ��� �������� �� �� NAVISION';
    v_pri_id         NUMBER;
  BEGIN
    SELECT ins.sq_ac_payment.nextval INTO v_pd4_payment_id FROM dual;
    SELECT ins.sq_ac_payment.nextval INTO v_pd4_copy_id FROM dual;
    SELECT ins.sq_doc_set_off.nextval INTO v_dso1_id FROM dual;
    SELECT ins.sq_doc_set_off.nextval INTO v_dso2_id FROM dual;
    SELECT ins.sq_doc_doc.nextval INTO v_docdoc_id FROM dual;
  
    SELECT dt.doc_templ_id INTO v_pd4_doc_templ FROM ins.doc_templ dt WHERE dt.brief = '�����';
  
    BEGIN
    
      SELECT CASE
               WHEN nvl(p_list_set_off_amount, 0) = 0 THEN
                least(ap_epg.amount - ins.pkg_payment.get_set_off_amount(ap_epg.payment_id, NULL, NULL)
                     , -- ����� �� ���. � ����. �� ���.
                      (SELECT pri.payment_sum - nvl(SUM(dso1.set_off_child_amount), 0) -- ����� ������� � ����� ������
                         FROM doc_set_off dso1
                        WHERE dso1.pay_registry_item = pri.payment_register_item_id
                          AND dso1.cancel_date IS NULL))
               ELSE
                least(ap_epg.amount - ins.pkg_payment.get_set_off_amount(ap_epg.payment_id, NULL, NULL)
                     ,(SELECT pri.payment_sum - nvl(SUM(dso1.set_off_child_amount), 0)
                        FROM doc_set_off dso1
                       WHERE dso1.pay_registry_item = pri.payment_register_item_id
                         AND dso1.cancel_date IS NULL)
                     ,p_list_set_off_amount) -- � ������
             END
            ,ap.payment_id
            ,ap.fund_id
            ,ap_epg.fund_id
            ,(SELECT brief FROM fund WHERE fund_id = ap.fund_id)
            ,(SELECT brief FROM fund WHERE fund_id = ap_epg.fund_id)
            ,ap_epg.contact_id
             -- ������ �.
             -- ����� ��������� ������ ���� �� �������, ���� �� ����, ����� ����� ����
            ,nvl(pri.doc_num, ap.num)
             -- ������ �.
             -- ���� ������� � ���� ��������� ����� ����������� �� 3-� ���
            ,least(ap.due_date, ap.reg_date, nvl(pri.payment_data, least(ap.due_date, ap.reg_date)))
            ,ap_epg.payment_id
            ,ap_epg.rev_rate
            ,ap_epg.rev_rate_type_id
            ,ap_epg.rev_fund_id
            ,ap_epg.rev_amount
            ,decode(nvl(rate_value, 0), 0, decode(ap.fund_id, ap_epg.fund_id, 1, 0), rate_value)
            ,pri.payment_register_item_id
        INTO v_payment_sum
            ,v_pp_payment_id
            ,v_pp_fund_id
            ,v_epg_fund_id
            ,v_pp_fund_brief
            ,v_epg_fund_brief
            ,v_epg_contact_id
            ,v_doc_num
            ,v_pri_data
            ,v_epg_payment_id
            ,v_epg_rev_rate
            ,v_epg_rev_rate_type_id
            ,v_epg_rev_fund_id
            ,v_epg_rev_amount
            ,v_rate
            ,v_pri_id
        FROM ins.ven_ac_payment ap
        JOIN ins.payment_register_item pri
          ON ap.payment_id = pri.ac_payment_id
      --������ 15.08.2011 ��� ������ �������� ��������
      --JOIN ins.ven_ac_payment ap_epg ON ap_epg.payment_id = pri.recognized_payment_id
        JOIN ins.ven_ac_payment ap_epg
          ON ap_epg.payment_id = nvl(ap_epg_id, pri.recognized_payment_id)
      ------------------------------------------------------------------------------------
        LEFT OUTER JOIN ins.rate r
          ON r.base_fund_id = ap.fund_id
         AND r.contra_fund_id = ap_epg.fund_id
         AND r.rate_date = ap.reg_date
       WHERE pri.payment_register_item_id = p_pri;
      --������ 15.08.2011 ��� ������ �������� ��������
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20001, '������ ��� ���������� cre_pd4' || SQLERRM);
    END;
    ----------------------------------------------------------------------
  
    IF v_rate = 0
    THEN
      -- ���� �� ���� �������������� ����� �� ����?
      RETURN '�� ������ ���� ����� (' || v_pp_fund_brief || ' � ' || v_epg_fund_brief || ') �� ' || v_pri_data;
    END IF;
  
    --------- ������� ��4
    INSERT INTO ins.ven_ac_payment
      (ent_id
      ,payment_id
      ,doc_templ_id
      ,num
      ,payment_number
      ,payment_type_id
      ,payment_direct_id
      ,due_date
      ,grace_date
      ,amount
      ,fund_id
      ,contact_id
      ,payment_templ_id
      ,payment_terms_id
      ,collection_metod_id
      ,rev_amount
      ,rev_fund_id
      ,rev_rate
      ,rev_rate_type_id
      ,is_agent
      ,comm_amount
      ,reg_date)
    VALUES
      (522
      ,v_pd4_payment_id
      ,6531
      ,v_doc_num
      ,1
      ,1
      ,1
      ,v_pri_data
      ,v_pri_data
      ,v_payment_sum
      ,v_pp_fund_id
      ,v_epg_contact_id
      ,6277
      ,163
      ,1
      ,v_epg_rev_amount
      ,v_epg_rev_fund_id
      ,v_epg_rev_rate
      ,v_epg_rev_rate_type_id
      ,0
      ,0
      ,v_pri_data);
  
    --------- ������� ����� ��4
    INSERT INTO ins.ven_ac_payment
      (ent_id
      ,payment_id
      ,doc_templ_id
      ,num
      ,payment_number
      ,payment_type_id
      ,payment_direct_id
      ,due_date
      ,grace_date
      ,amount
      ,fund_id
      ,contact_id
      ,payment_templ_id
      ,payment_terms_id
      ,collection_metod_id
      ,rev_amount
      ,rev_fund_id
      ,rev_rate
      ,rev_rate_type_id
      ,is_agent
      ,comm_amount
      ,reg_date)
    VALUES
      (522 -- ENT_ID
      ,v_pd4_copy_id -- PAYMENT_ID
      ,6533 -- DOC_TEMPL_ID
      ,v_doc_num -- NUM
      ,1 -- PAYMENT_NUMBER
      ,0 -- PAYMENT_TYPE_ID
      ,0 -- PAYMENT_DIRECT_ID
      ,v_pri_data -- DUE_DATE
      ,v_pri_data -- GRACE_DATE
      ,v_payment_sum -- AMOUNT
      ,122 -- FUND_ID
      ,v_epg_contact_id -- CONTACT_ID
      ,6281 -- PAYMENT_TEMPL_ID
      ,163 -- PAYMENT_TERMS_ID
      ,1 -- COLLECTION_METOD_ID
      ,v_payment_sum -- REV_AMOUNT
      ,122 -- REV_FUND_ID
      ,1 -- REV_RATE
      ,v_epg_rev_rate_type_id -- REV_RATE_TYPE_ID
      ,0 -- IS_AGENT
      ,0 -- COMM_AMOUNT
      ,v_pri_data -- REG_DATE
       );
  
    --------- ����� ��4 � ���
    INSERT INTO ins.ven_doc_set_off
      (doc_set_off_id
      ,doc_templ_id
      ,note
      ,reg_date
      ,child_doc_id
      ,parent_doc_id
      ,set_off_amount
      ,set_off_fund_id
      ,set_off_rate
      ,set_off_date
      ,set_off_child_amount
      ,set_off_child_fund_id
      ,pay_registry_item)
    VALUES
      (v_dso1_id
      ,v_pd4_doc_templ
      ,v_dso_note
      ,v_pri_data
      ,v_pd4_payment_id
      ,v_epg_payment_id
      ,v_payment_sum -- set_off_amount
      ,v_epg_fund_id -- set_off_fund_id
      ,v_rate -- set_off_rate
      ,v_pri_data -- set_off_date
      ,v_payment_sum -- set_off_child_amount
      ,v_pp_fund_id -- set_off_child_fund_id
      ,NULL);
  
    --------- ������� ����� ��4 � ����� ��4
    INSERT INTO doc_doc dd
      (doc_doc_id, parent_id, child_id, parent_amount, parent_fund_id, child_amount, child_fund_id)
    VALUES
      (v_docdoc_id
      ,v_pd4_payment_id
      ,v_pd4_copy_id
      ,v_payment_sum
      ,v_pp_fund_id
      ,v_payment_sum
      ,v_pp_fund_id);
  
    --------- ������� ����� ����� ��4 � ����/��)
    INSERT INTO ins.ven_doc_set_off dso
      (doc_set_off_id
      ,doc_templ_id
      ,note
      ,reg_date
      ,child_doc_id
      ,parent_doc_id
      ,set_off_amount
      ,set_off_child_amount
      ,set_off_child_fund_id
      ,set_off_date
      ,set_off_fund_id
      ,set_off_rate
      ,pay_registry_item)
    VALUES
      (v_dso2_id -- doc_set_off_id
      ,v_pd4_doc_templ -- doc_templ_id
      ,v_dso_note -- note
      ,v_pri_data -- reg_date
      ,v_pp_payment_id -- child_doc_id �� (��)
      ,v_pd4_copy_id -- parent_doc_id ����� ��4
      ,v_payment_sum -- set_off_amount
      ,v_payment_sum -- set_off_child_amount
      ,122 -- set_off_child_fund_id
      ,v_pri_data -- set_off_date
      ,122 -- set_off_fund_id
      ,1 -- set_off_rate
      ,p_pri -- pay_registry_item_id
       );
  
    --------- ������ ������� �� ��4
    doc.set_doc_status(v_pd4_payment_id, 'NEW', SYSDATE);
    doc.set_doc_status(v_pd4_payment_id, 'TRANS', SYSDATE + INTERVAL '1' SECOND);
  
    --------- ������ ������� �� ����� ��4
    doc.set_doc_status(v_pd4_copy_id, 'PAID', SYSDATE + INTERVAL '3' SECOND);
  
    --------- ������� � ����� ����������-������
    doc.set_doc_status(v_dso1_id, 'NEW', SYSDATE + INTERVAL '4' SECOND);
    doc.set_doc_status(v_dso2_id, 'NEW', SYSDATE + INTERVAL '5' SECOND);
  
    -- ������ �.
    -- ��������� ������������� ��������� � ��� �� ����� ��4
    UPDATE payment_register_item pri
       SET pri.recognized_payment_id = v_pd4_copy_id
     WHERE pri.payment_register_item_id = v_pri_id;
    RETURN NULL;
  
  END cre_pd4;

  --������ 11.10.2011 --����� ��������� ������������� ��������������
  --������� �������� ����� ��. ��. ����� ����(�����) � ���
  FUNCTION cre_zachet_ucv
  (
    p_pri                   NUMBER
   ,ap_epg_id               NUMBER DEFAULT NULL
   ,par_list_set_off_amount NUMBER DEFAULT NULL -- �������� ����������� �� SET_OFF_LIST.FMB
  ) RETURN VARCHAR2 IS
    v_zachet_payment_id      NUMBER;
    v_zachet_payment_copy_id NUMBER;
    v_dso1_id                NUMBER;
    v_dso2_id                NUMBER;
    v_zachet_doc_templ       NUMBER;
    v_doc_doc_id             NUMBER;
  
    v_pri_id         NUMBER;
    v_epg_contact_id NUMBER;
    v_epg_payment_id NUMBER;
    v_pp_payment_id  NUMBER;
  
    v_pp_fund_id  NUMBER;
    v_rev_fund_id NUMBER;
  
    v_payment_sum         NUMBER;
    v_payment_amount_free NUMBER;
    v_pri_amount_free     NUMBER;
    v_rev_amount          NUMBER;
    v_rev_rate            NUMBER;
    v_rev_rate_type_id    NUMBER;
  
    v_rate         NUMBER;
    v_due_date     DATE;
    v_reg_date     DATE;
    v_payment_data DATE;
    v_doc_num      VARCHAR2(100);
    v_dso_note     VARCHAR2(200) := '�������� ������ ��� �������������� �������� ������ ��������� ��';
  BEGIN
    /*SELECT ins.sq_ac_payment.nextval INTO v_zachet_payment_id FROM dual;
        SELECT ins.sq_ac_payment.nextval INTO v_zachet_payment_copy_id FROM dual;
        SELECT ins.sq_doc_set_off.nextval INTO v_dso1_id FROM dual;
        SELECT ins.sq_doc_set_off.nextval INTO v_dso2_id FROM dual;
    */
    SELECT dt.doc_templ_id
      INTO v_zachet_doc_templ
      FROM ins.doc_templ dt
     WHERE dt.brief = '�����';
  
    BEGIN
      SELECT
      /*LEAST(--���� ����� �� ��� ������ ��� ����� �������� �������
       (ap_epg.amount - ins.Pkg_Payment.get_set_off_amount(ap_epg.payment_id, NULL, NULL))--��� �������� �������
      ,(SELECT pri.payment_sum - NVL(SUM(dso1.set_off_child_amount), 0)
        FROM doc_set_off dso1
        WHERE dso1.pay_registry_item = pri.payment_register_item_id
        AND dso1.cancel_date IS NULL) -- ���� �� ���� �� �������� ��������� ��� (������ ����� ���� �� ����������� �� ��) �� �������� ����� dso
        )*/
       (ap_epg.amount - ins.pkg_payment.get_set_off_amount(ap_epg.payment_id, NULL, NULL))
      ,(SELECT pri.payment_sum - nvl(SUM(dso1.set_off_child_amount), 0)
         FROM doc_set_off dso1
        WHERE dso1.pay_registry_item = pri.payment_register_item_id
          AND dso1.cancel_date IS NULL)
      ,ap.payment_id
      ,ap.fund_id
      ,ap_epg.contact_id
      ,ap.num --����� ����� �� ��� � ����
       --������ 172822: ���� "����� ���������"
       --, ap.due_date
      ,CASE
         WHEN (ap.due_date = pri.payment_data)
              OR (nvl(pri.payment_data, '01.01.1900') = '01.01.1900') THEN
          ap.due_date
         WHEN ap.due_date > pri.payment_data THEN
          pri.payment_data
         ELSE
          ap.due_date
       END
      ,CASE
         WHEN (ap.due_date = pri.payment_data)
              OR (nvl(pri.payment_data, '01.01.1900') = '01.01.1900') THEN
          ap.due_date
         WHEN ap.due_date > pri.payment_data THEN
          pri.payment_data
         ELSE
          ap.due_date
       END
       --, ap.reg_date
       --end_������ 172822: ���� "����� ���������"
      ,pri.payment_data
      ,ap_epg.payment_id
      ,acc_new.get_rate_by_id(ap_epg.rev_rate_type_id, ap_epg.fund_id, ap.due_date) --�������� ����� �������� � ������ ��� �� ���� ������� ��
      ,ap_epg.rev_rate_type_id --��� �����
      ,ap_epg.fund_id --���� ��� � ������� ���������
      ,acc_new.get_cross_rate_by_id(ap_epg.rev_rate_type_id, ap.fund_id, ap_epg.fund_id, ap.due_date) --����� ���� ���� -> ��� �� ���� �������
      ,pri.payment_register_item_id
        INTO --v_payment_sum
             v_payment_amount_free
            ,v_pri_amount_free
            ,v_pp_payment_id
            ,v_pp_fund_id
            ,v_epg_contact_id
            ,v_doc_num
            ,v_due_date
            ,v_reg_date
            ,v_payment_data
            ,v_epg_payment_id
            ,v_rev_rate
            ,v_rev_rate_type_id
            ,v_rev_fund_id
            ,v_rate
            ,v_pri_id
        FROM ins.ven_ac_payment ap
        JOIN ins.payment_register_item pri
          ON ap.payment_id = pri.ac_payment_id
        JOIN ins.ven_ac_payment ap_epg
          ON ap_epg.payment_id = nvl(ap_epg_id, pri.recognized_payment_id)
       WHERE pri.payment_register_item_id = p_pri;
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20001
                               ,'������ ��� ���������� cre_zachet_ucv' || SQLERRM);
    END;
  
    --������ ������� /nvl(par_list_set_off_amount/ �� ������ 254198: �� ������. �������� ������ ���������
    v_pri_amount_free := nvl(par_list_set_off_amount, v_pri_amount_free);
  
    v_payment_sum := least(v_payment_amount_free, v_pri_amount_free);
  
    IF v_payment_amount_free < v_pri_amount_free
    THEN
      raise_application_error(-20000
                             ,'����� ������� ' ||
                              to_char(v_pri_amount_free
                                     ,'FM999G999G999G990D00'
                                     ,'NLS_NUMERIC_CHARACTERS = '', ''') ||
                              ' ������ ��� �����, �������  ����� ������� �� ��� ' ||
                              to_char(v_payment_amount_free
                                     ,'FM999G999G999G990D00'
                                     ,'NLS_NUMERIC_CHARACTERS = '', '''));
    END IF;
  
    ----------------------------------------------------------------------
  
    --�������� ������ ���������
    v_zachet_payment_id := pkg_payment.create_payment(p_doc_templ_brief => '������_��'
                                                     ,p_amount          => v_payment_sum
                                                     ,p_fund_id         => v_pp_fund_id
                                                     ,p_rev_fund_id     => v_rev_fund_id
                                                     ,p_contact_id      => v_epg_contact_id
                                                     ,p_rate_date       => v_reg_date
                                                     ,p_num             => v_doc_num);
    --�������� ����� ������ ���������
    v_zachet_payment_copy_id := pkg_payment.create_payment(p_doc_templ_brief => '������_��_COPY'
                                                          ,p_amount          => v_payment_sum
                                                          ,p_fund_id         => v_pp_fund_id
                                                          ,p_rev_fund_id     => v_pp_fund_id
                                                          ,p_contact_id      => v_epg_contact_id
                                                          ,p_rate_date       => v_reg_date
                                                          ,p_num             => v_doc_num);
    -- ����� ����� ��� � ���������� ������_��
    v_dso1_id := pkg_payment.create_doc_set_off(p_child_doc_id  => v_zachet_payment_id
                                               ,p_parent_doc_id => v_epg_payment_id
                                               ,p_note          => v_dso_note);
    -- ����� ����� ����� � ���������� ������_��_COPY
    v_dso2_id := pkg_payment.create_doc_set_off(p_child_doc_id         => v_pp_payment_id
                                               ,p_parent_doc_id        => v_zachet_payment_copy_id
                                               ,p_set_off_child_amount => v_payment_sum --������ ��� ����� ���� ����� ������� ��������� ���
                                               ,p_pay_registry_item    => p_pri
                                               ,p_note                 => v_dso_note);
    -- ������� ����� ������_�� � ������_��_COPY
    v_doc_doc_id := pkg_payment.create_doc_doc(p_child_id  => v_zachet_payment_copy_id
                                              ,p_parent_id => v_zachet_payment_id);
  
    --------- ������ ������� �� ����� ���������
    doc.set_doc_status(v_zachet_payment_id, 'NEW', SYSDATE);
    doc.set_doc_status(v_zachet_payment_id, 'TRANS', SYSDATE + INTERVAL '1' SECOND);
  
    --------- ������ ������� �� ����� ��4
    doc.set_doc_status(v_zachet_payment_copy_id, 'PAID', SYSDATE + INTERVAL '3' SECOND);
  
    --------- ������� � ����� ����������-������
    doc.set_doc_status(v_dso1_id, 'NEW', SYSDATE + INTERVAL '4' SECOND);
    doc.set_doc_status(v_dso2_id, 'NEW', SYSDATE + INTERVAL '5' SECOND);
  
    -- ��������� ������������� ��������� � ��� �� ����� ��4
    UPDATE payment_register_item pri
       SET pri.note                  = '������ ����� ��������� �� '
          ,pri.recognized_payment_id = v_zachet_payment_copy_id
     WHERE pri.payment_register_item_id = v_pri_id;
  
    RETURN NULL;
  
  END cre_zachet_ucv;

  /*
  * ��������� ��� ��������� � �������� ����������� ��
  * ��� ����� ����� ������ (�������������/�������) ������� ������ ��������� ���������� ���� �� ��� ��� �������� ���������� �7/��4
  * �� ������ 255229: �������� �������� � �������� ���������
  * @autor ������ �.�.
  * @param par_payment_id - ��������� �������� � �������� �����������
  * @param par_pay_doc_id - ��������� �������� �������� �����������
  */
  PROCEDURE check_payment_currency
  (
    par_payment_id NUMBER
   ,par_pay_doc_id NUMBER
  ) IS
    v_brief           ins.doc_templ.brief%TYPE;
    v_pay_doc_brief   ins.doc_templ.brief%TYPE;
    v_fund_brief      ins.fund.brief%TYPE;
    v_fund_ppvh_brief ins.fund.brief%TYPE;
  BEGIN
    --������ ���������, � �������� ����������� ������ ���� PAYMENT
    SELECT dt.brief
      INTO v_brief
      FROM ins.ven_ac_payment ac
          ,ins.doc_templ      dt
     WHERE ac.payment_id = par_payment_id
       AND ac.doc_templ_id = dt.doc_templ_id;
  
    --������ ���������, ������� ����������� ������ ���� ����
    SELECT dt.brief
      INTO v_pay_doc_brief
      FROM ins.ven_ac_payment ac
          ,ins.doc_templ      dt
     WHERE ac.payment_id = par_pay_doc_id
       AND ac.doc_templ_id = dt.doc_templ_id;
  
    IF v_brief = 'PAYMENT'
       AND v_pay_doc_brief IN ('��', '��_��', '��_��', '�����')
       AND is_rur_currency(par_payment_id) = 0
    THEN
      raise_application_error('-20000'
                             ,'�������� �������, �������� ��������� �������� � ������.');
    END IF;
  END check_payment_currency;

  /*
    218934 �������� �������� �� ��������� � ������� ����������
  */
  PROCEDURE recognize_indexation(par_payment_register_item_id NUMBER) IS
    TYPE t_load_tmp_row IS RECORD(
       payment_type_id          ac_payment.payment_id%TYPE
      ,amount                   ac_payment.amount%TYPE
      ,comm_amount              ac_payment.comm_amount%TYPE
      ,payment_register_item_id payment_register_item.payment_register_item_id%TYPE
      ,payment_data             payment_register_item.payment_data%TYPE
      ,policy_start_date        p_policy.start_date%TYPE
      ,doc_templ_brief          doc_templ.brief%TYPE
      ,fund_brief_bill          fund.brief%TYPE
      ,fund_brief_order         fund.brief%TYPE
      ,fund_id_bill             ac_payment.fund_id%TYPE
      ,rev_fund_id              ac_payment.rev_fund_id%TYPE
      ,rev_rate_type_brief      rate_type.brief%TYPE
      ,rev_rate_type_id         ac_payment.rev_rate_type_id%TYPE
      ,rev_rate                 ac_payment.rev_rate%TYPE
      ,due_date                 ac_payment.due_date%TYPE
      ,grace_date               ac_payment.grace_date%TYPE
      ,flt_status               NUMBER
      ,payment_direct_id        ac_payment.payment_direct_id%TYPE
      ,payment_id               ac_payment.payment_id%TYPE
      ,flt_contact_id           NUMBER
      ,flt_start_date           DATE
      ,flt_end_date             DATE
      ,flt_doc_num              p_policy.pol_num%TYPE
      ,flt_notice_num           p_policy.notice_num%TYPE
      ,flt_sum                  NUMBER
      ,flt_ind_sum              NUMBER
      ,flt_ids                  payment_register_item.ids%TYPE);
  
    v_load_tmp_row         t_load_tmp_row;
    v_payment_register_row v_payment_register%ROWTYPE := NULL;
    v_pol_index_item_id    NUMBER;
    v_continue             NUMBER := 0;
    v_indexating           NUMBER := 0;
    v_tso_row              tmp_set_off%ROWTYPE := NULL;
    v_err_m                VARCHAR2(2000) := NULL;
  
    FUNCTION refresh_tmp(par_load_tmp_row t_load_tmp_row) RETURN tmp_set_off%ROWTYPE IS
      v_tso_row tmp_set_off%ROWTYPE;
    BEGIN
      -- ���������� �������� ������� TMP_SET_OFF - ��������� ������ ����� �����
      pkg_payment.load_tmp(p_payment_type_id     => par_load_tmp_row.payment_type_id
                          ,p_fund_brief_bill     => par_load_tmp_row.fund_brief_bill
                          ,p_fund_brief_order    => par_load_tmp_row.fund_brief_order
                          ,p_fund_id_bill        => par_load_tmp_row.fund_id_bill
                          ,p_rev_fund_id         => par_load_tmp_row.rev_fund_id
                          ,p_rev_rate_type_brief => par_load_tmp_row.rev_rate_type_brief
                          ,p_rev_rate_type_id    => par_load_tmp_row.rev_rate_type_id
                          ,p_rev_rate            => par_load_tmp_row.rev_rate
                          ,p_due_date            => par_load_tmp_row.due_date
                          ,p_flt_status          => par_load_tmp_row.flt_status
                          ,p_payment_direct_id   => par_load_tmp_row.payment_direct_id
                          ,p_payment_id          => par_load_tmp_row.payment_id
                          ,p_flt_contact_id      => par_load_tmp_row.flt_contact_id
                          ,p_flt_start_date      => par_load_tmp_row.flt_start_date
                          ,p_flt_end_date        => par_load_tmp_row.flt_end_date
                          ,p_flt_doc_num         => par_load_tmp_row.flt_doc_num
                          ,p_flt_notice_num      => par_load_tmp_row.flt_notice_num
                          ,p_flt_sum             => par_load_tmp_row.flt_sum
                          ,p_flt_index_sum       => par_load_tmp_row.flt_ind_sum
                          ,p_flt_ids             => par_load_tmp_row.flt_ids);
    
      -- ������� ��������, ������� ��������� � �������� �������
      DELETE FROM tmp_set_off
       WHERE (par_load_tmp_row.due_date <>
             pkg_period_closed.check_closed_date(par_load_tmp_row.due_date) -- �������� ��������� � �������� �������
             AND doc.get_last_doc_status_date(doc_set_off_id) <
             pkg_period_closed.get_period_close_date(par_load_tmp_row.due_date)); -- ����� �������� �� �������� �������
    
      -- �������� ��� � ������� "�����" ��� "� ������", ���� ������� (plan_date) �������� ����� ���� ������ ������ ���������� � ��������� � ������ �����  �������� = ����� ���������������� ������
      DELETE FROM tmp_set_off
       WHERE ph_ids <> par_load_tmp_row.flt_ids
          OR doc_status_brief NOT IN ('NEW', 'TO_PAY')
         AND document_id NOT IN
             (SELECT pps.document_id
                FROM v_policy_payment_schedule pps
                    ,p_pol_header              ph
               WHERE 1 = 1
                 AND pps.pol_header_id = ph.policy_header_id
                 AND ph.ids = par_load_tmp_row.flt_ids
                 AND pps.plan_date = par_load_tmp_row.flt_start_date);
    
      -- ���������� ���� cancel_flag = 0 ��� ����������� ���������� �������, ��������� ( =1) �� ������������
      UPDATE tmp_set_off SET cancel_flag = 1;
    
      BEGIN
        SELECT *
          INTO v_tso_row
          FROM tmp_set_off
         WHERE 1 = 1
           AND doc_templ_brief = '����'
           AND cancel_set_off_date IS NULL; -- �� �������������� �����
      EXCEPTION
        WHEN no_data_found
             OR too_many_rows THEN
          v_tso_row := NULL;
      END;
    
      RETURN v_tso_row;
    END refresh_tmp;
  
  BEGIN
    dbms_output.disable;
    -- ������ � ����� ������ �������� (PAYMENT_REGISTER.FMB)
    BEGIN
      SELECT *
        INTO v_payment_register_row
        FROM v_payment_register
       WHERE payment_register_item_id = par_payment_register_item_id;
    EXCEPTION
      WHEN too_many_rows THEN
        v_payment_register_row.sum2setoff := 0; -- �� ������������
    END;
  
    -- ����� �������� ������� > 0, �� ��������� ���������, ����� - ������� ������� ��� ��������
    IF v_payment_register_row.sum2setoff > 0
    THEN
    
      BEGIN
        SELECT decode(COUNT(*), 0, 0, 1)
          INTO v_continue
          FROM v_payment_register pri
              ,p_pol_header       ph
              ,p_policy           p
              ,document           d
              ,doc_status_ref     dsr
         WHERE 1 = 1
           AND ph.ids = nvl(pri.ids, pri.pol_num)
           AND p.policy_id = ph.last_ver_id
           AND d.document_id = p.policy_id
           AND dsr.doc_status_ref_id = d.doc_status_ref_id
           AND lower(pri.note) LIKE ('%����������%') -- � ����������� ���������� ����� "����������"
           AND dsr.brief = 'INDEXATING' -- ��������� ������ �������� � ������� "����������"
           AND NOT EXISTS
         (SELECT 1 -- � �������� ��� ������������ ��� �� ��������� � ���� ����� ����������� ����� < �������� � ���� ����� ������
                  FROM doc_doc        dd
                      ,document       d
                      ,doc_templ      dt
                      ,doc_status_ref dsr
                      ,ac_payment     ap
                 WHERE dd.parent_id IN
                       (SELECT policy_id FROM p_policy WHERE pol_header_id = ph.policy_header_id)
                   AND dd.child_id = d.document_id
                   AND dt.doc_templ_id = d.doc_templ_id
                   AND dsr.doc_status_ref_id = d.doc_status_ref_id
                   AND ap.payment_id = d.document_id
                   AND dt.brief = 'PAYMENT' -- ���� �� ������ �������
                   AND dsr.brief IN ('NEW', 'TO_PAY') -- ��� ����� ����������
                   AND ap.plan_date < p.start_date)
           AND pri.payment_register_item_id = par_payment_register_item_id;
      EXCEPTION
        WHEN no_data_found THEN
          NULL;
      END;
    
      IF v_continue = 1
      THEN
        -- ������ � ����� ����� (SET_OFF_LIST.FMB)
        BEGIN
          SELECT t.payment_type_id
                ,t.amount
                ,t.comm_amount
                ,pri.payment_register_item_id
                ,pri.payment_data
                ,p.start_date policy_start_date
                ,dt.brief doc_templ_brief
                ,f.brief fund_brief_bill
                ,f.brief fund_brief_order
                ,t.fund_id fund_id_bill
                ,t.rev_fund_id
                ,rt.brief rev_rate_type_brief
                ,t.rev_rate_type_id
                ,t.rev_rate
                ,t.due_date
                ,t.grace_date
                ,NULL flt_status
                ,t.payment_direct_id
                ,t.payment_id
                ,NULL flt_contact_id
                ,to_date('01.01.2009', 'dd.mm.yyyy') flt_start_date
                ,ADD_MONTHS(SYSDATE, 3) flt_end_date
                ,p.pol_num flt_doc_num
                ,p.notice_num flt_notice_num
                ,NULL flt_sum
                ,NULL flt_ind_sum
                ,pri.ids flt_ids
            INTO v_load_tmp_row
            FROM payment_register_item pri
                ,ven_ac_payment        t
                ,doc_templ             dt
                ,fund                  f
                ,rate_type             rt
                ,p_pol_header          ph
                ,p_policy              p
           WHERE 1 = 1
             AND t.payment_id = pri.ac_payment_id
             AND t.doc_templ_id = dt.doc_templ_id
             AND t.fund_id = f.fund_id
             AND t.rev_rate_type_id = rt.rate_type_id(+)
             AND ph.ids = nvl(pri.ids, pri.pol_num)
             AND ph.last_ver_id = p.policy_id
             AND pri.payment_register_item_id = par_payment_register_item_id;
        EXCEPTION
          WHEN no_data_found THEN
            NULL;
        END;
      
        -- ����� ������
        SAVEPOINT before_register;
        BEGIN
          v_tso_row := refresh_tmp(v_load_tmp_row);
          -- ��������: ���������� ����� ������ ���, � �������� ����� �������� ������� = ����� / ���. �����
          BEGIN
            SELECT *
              INTO v_err_m
                  ,v_continue
              FROM (SELECT ltrim(sys_connect_by_path(num, ', '), ', ')
                          ,LEVEL
                      FROM (SELECT num
                                  ,lag(num) over(ORDER BY num) AS prev_num
                              FROM tmp_set_off
                             WHERE ((1 = 1 -- ��������� �� �)
                                   AND doc_amount = v_payment_register_row.sum2setoff AND
                                   idx_sum IS NOT NULL) OR
                                   (1 = 1 -- ��������� �� �)
                                   AND idx_sum = v_payment_register_row.sum2setoff AND
                                   ((v_load_tmp_row.payment_data IS NOT NULL AND
                                   v_load_tmp_row.payment_data <= v_load_tmp_row.policy_start_date) OR
                                   (v_load_tmp_row.payment_data IS NULL AND
                                   v_load_tmp_row.due_date <= v_load_tmp_row.policy_start_date + 5))))
                               AND doc_templ_brief = '����'
                               AND cancel_set_off_date IS NULL -- �� �������������� �����
                            )
                     START WITH prev_num IS NULL
                    CONNECT BY prev_num = PRIOR num
                     ORDER BY 1 DESC)
             WHERE rownum = 1;
          EXCEPTION
            WHEN no_data_found THEN
              v_continue := -1;
          END;
        
          IF v_continue = 1
          THEN
            --------------------------------------------------------------
            -- ��������� ������� ������ ���������� �� ������, ��� ��������
          
            -- ��������� ������ � ������� ����������
            SELECT MAX(pii.policy_index_item_id)
              INTO v_pol_index_item_id
              FROM doc_doc dd
                  ,p_policy p
                  ,(SELECT policy_id
                          ,version_num
                          ,pol_header_id
                          ,start_date
                          ,pkg_policy.get_last_version(pol_header_id) last_ver_id
                      FROM p_policy
                     WHERE doc.get_doc_status_brief(policy_id) = 'INDEXATING') ind
                  ,policy_index_item pii
             WHERE 1 = 1
               AND p.policy_id = dd.parent_id
               AND ind.pol_header_id = p.pol_header_id
               AND (ind.start_date = p.start_date OR ind.policy_id = ind.last_ver_id)
               AND pii.policy_header_id = ind.pol_header_id
               AND pii.policy_id = ind.policy_id
               AND dd.child_id = v_tso_row.document_id;
          
            -- �)
            -- �������� � ���� ������ �������� �������� � ���� ������� �������� = �������� � ���� ������ ���� ������
            IF v_payment_register_row.sum2setoff = v_tso_row.doc_amount
               AND v_tso_row.idx_sum IS NOT NULL
            THEN
              -- ������ ������ ���.���������� � ������� ����������
              doc.set_doc_status(v_pol_index_item_id, 'INDEXATING_RENUNCIATION');
              v_continue := 1;
            END IF; -- ����� �)
            -- �)
            -- �������� � ���� ������ �������� �������� � ���� ������� �������� = �������� � ���� ����. ����� ���� ������
            IF v_payment_register_row.sum2setoff = v_tso_row.idx_sum
            THEN
              CASE
                WHEN (v_load_tmp_row.payment_data IS NOT NULL AND
                     v_load_tmp_row.payment_data <= v_load_tmp_row.policy_start_date)
                     OR (v_load_tmp_row.payment_data IS NULL AND
                     v_load_tmp_row.due_date <= v_load_tmp_row.policy_start_date + 5) THEN
                  -- ��������� ������� � ���� ����. ����� � ���� ������)
                  doc.set_doc_status(v_pol_index_item_id, 'INDEXATING_AGREE');
                  v_continue   := 1;
                  v_indexating := 1;
                ELSE
                  -- ������ ���������� "������� ���������"
                  UPDATE payment_register_item
                     SET status         = 10 -- ������� ���������
                        ,recognize_data = SYSDATE
                        ,note           = '���� �������� ���������� ����� (����������� �������: ���� ������� ������ ���� ������ ������ � ������� "����������"), ��������� ���� �� � ������� ������� �7/��4 ��� �������� ������� �� ����������'
                   WHERE payment_register_item_id = v_payment_register_row.payment_register_item_id;
                  v_continue := 0;
              END CASE;
            END IF; -- ����� �)
          
            IF v_continue = 1
            THEN
              -- ���� ���������� �������, �� ��������� �������� �������, �.�. ������� �����
              -- ������ ��, ��������� ���
              IF v_indexating = 1
              THEN
                v_tso_row := refresh_tmp(v_load_tmp_row);
              END IF;
            
              ------------------------------
              -- ���������� �������� �������
              v_tso_row.main_set_off_amount := v_tso_row.doc_amount;
            
              -- ������� ������� ��� �� ������� ����� � ������ � ������
              IF v_tso_row.doc_status_brief = 'NEW'
              THEN
                doc.set_doc_status(v_tso_row.document_id, 'TO_PAY');
              END IF;
            
              IF v_tso_row.main_fund_brief = v_tso_row.list_fund_brief
              THEN
                v_tso_row.list_set_off_amount := v_tso_row.main_set_off_amount;
              ELSIF v_tso_row.main_fund_brief = 'RUR'
                    OR nvl(v_tso_row.set_off_rate, 0) = 0
              THEN
                v_tso_row.list_set_off_amount := ROUND(v_tso_row.main_set_off_amount /
                                                       v_tso_row.set_off_rate * 100) / 100;
              ELSE
                v_tso_row.list_set_off_amount := ROUND(v_tso_row.main_set_off_amount *
                                                       v_tso_row.set_off_rate * 100) / 100;
              END IF;
            
              -- ������ ����������, ��������� ����� ��������� ������
              UPDATE tmp_set_off
                 SET cancel_flag         = 0
                    ,main_set_off_amount = v_tso_row.main_set_off_amount
                    ,list_set_off_amount = v_tso_row.list_set_off_amount
               WHERE document_id = v_tso_row.document_id;
            
              --------------------
              -- J��������� ������
            
              -- �������� �������, ������� �� ����������
              DELETE FROM tmp_set_off WHERE cancel_flag = 1;
            
              -- �������� ��������� �� ������, �� ������� �������� �����
              pkg_set_off_list_fmb.update_docs(par_payment_type_id => v_load_tmp_row.payment_type_id);
              -- �������� ��������� �� ������, ������� �� ����, �� �� ������� ���������� ����� > 0
              pkg_set_off_list_fmb.insert_docs(par_payment_reg_item_id => v_load_tmp_row.payment_register_item_id
                                              ,par_payment_id          => v_load_tmp_row.payment_id
                                              ,par_payment_type_id     => v_load_tmp_row.payment_type_id
                                              ,par_doc_templ_brief     => v_load_tmp_row.doc_templ_brief
                                              ,par_due_date            => v_load_tmp_row.due_date
                                              ,par_grace_date          => v_load_tmp_row.grace_date
                                              ,par_payment_data        => v_load_tmp_row.payment_data);
              -- ���������, � ������ ���������� ��������� �������� �� � ���������� ���, ���� � ������, � �������� ������ ��� ����� ����� null
              IF v_load_tmp_row.flt_ids IS NULL
              THEN
                pkg_set_off_list_fmb.update_ids(par_payment_reg_item_id => v_load_tmp_row.payment_register_item_id);
              END IF;
            
              UPDATE payment_register_item
                 SET status         = 40 -- ��������
                    ,recognize_data = SYSDATE
                    ,note           = '��������� �������������. ���������� �� ���. ' ||
                                      v_payment_register_row.ids ||
                                      decode(v_indexating, 1, ' �������.', ' ��������.')
               WHERE payment_register_item_id = v_payment_register_row.payment_register_item_id;
            END IF;
          
          ELSE
            UPDATE payment_register_item
               SET status         = 10 -- ������� ���������
                  ,recognize_data = SYSDATE
                  ,note           = CASE v_continue
                                      WHEN -1 THEN
                                       '������� � ������� ����������, ����� �� �������� �� ����� ����� �������'
                                      ELSE
                                       '������� ��������� ��� � �������� ���������� ' || v_err_m ||
                                       ', ������� �������� ��� ������� ��������������� �������� ����������'
                                    END
             WHERE payment_register_item_id = v_payment_register_row.payment_register_item_id;
          END IF;
        EXCEPTION
          WHEN OTHERS THEN
            -- ������� � ����� ������
            ROLLBACK TO before_register;
            -- ������ ������
            v_err_m := '������ �������������: ' || SQLERRM;
            UPDATE payment_register_item
               SET status         = 20 -- ������������� �� ���������
                  ,recognize_data = SYSDATE
                  ,note           = note || chr(10) || v_err_m
             WHERE payment_register_item_id = v_payment_register_row.payment_register_item_id;
        END;
      END IF;
    END IF; -- ����� ����� �������� ������� > 0, �� ��������� ���������, ����� - ������� ������� ��� ��������
  END recognize_indexation;

  -- Author  : �������� �.�.
  -- Created : 17.03.2015
  -- Purpose : 403556: �������� �������� ��������
  -- Param   : par_pp_id           ID ��
  --           par_is_annulate     ������������ ��� �������
  --           par_is_del_register ������� ������
  --           par_is_del_pp       ������� ��
  --           pat_is_tex_err      ��������� ������� � ������ ���. ������
  --           par_reason          �������
  --           par_cancel_date     

  PROCEDURE annulate_delete_all_links
  (
    par_pp_id           NUMBER
   ,par_reason          VARCHAR2
   ,par_is_annulate     BOOLEAN
   ,par_is_del_register BOOLEAN DEFAULT FALSE
   ,par_is_del_pp       BOOLEAN DEFAULT FALSE
   ,par_is_tex_err      BOOLEAN DEFAULT TRUE
   ,par_cancel_date     DATE DEFAULT SYSDATE
  ) IS
    v_log_id NUMBER;
  
    PROCEDURE log
    (
      par_pp_id           NUMBER
     ,par_reason          VARCHAR2
     ,par_is_annulate     NUMBER
     ,par_is_del_register NUMBER
     ,par_is_del_pp       NUMBER
     ,par_is_tex_err      NUMBER
     ,par_cancel_date     DATE
     ,par_it_out          OUT NUMBER
    ) IS
      v_rec_ac_payment dml_ac_payment.tt_ac_payment;
    BEGIN
      v_rec_ac_payment := dml_ac_payment.get_record(par_payment_id => par_pp_id);
    
      INSERT INTO t_log_anul_del_pp
        (id
        ,pp_id
        ,reason
        ,is_annulate
        ,is_del_register
        ,is_del_pp
        ,is_tex_err
        ,cancel_date
        ,pp_num
        ,pp_ammount
        ,pp_payment_templ_id
        ,pp_fund_id
        ,pp_due_date)
      VALUES
        (sq_t_log_anul_del_pp.nextval
        ,par_pp_id
        ,par_reason
        ,par_is_annulate
        ,par_is_del_register
        ,par_is_del_pp
        ,par_is_tex_err
        ,par_cancel_date
        ,v_rec_ac_payment.num
        ,v_rec_ac_payment.amount
        ,v_rec_ac_payment.payment_templ_id
        ,v_rec_ac_payment.fund_id
        ,v_rec_ac_payment.due_date)
      RETURNING id INTO par_it_out;
    END log;
  
    PROCEDURE log_detail
    (
      par_log_anul_del_pp_id NUMBER
     ,par_ure_type           VARCHAR2
     ,par_uro_id             NUMBER := NULL
     ,par_action_type        VARCHAR2
     ,par_action             VARCHAR2 := NULL
    ) IS
      v_rec_ac_payment dml_ac_payment.tt_ac_payment;
      v_rec_pri        dml_payment_register_item.tt_payment_register_item;
      v_rec_dso        dml_doc_set_off.tt_doc_set_off;
      v_ent_id         NUMBER;
    BEGIN
      IF par_uro_id IS NOT NULL
      THEN
        IF par_ure_type = 'ac_payment'
        THEN
          v_rec_ac_payment := dml_ac_payment.get_record(par_payment_id => par_uro_id);
        ELSIF par_ure_type = 'payment_register_item'
        THEN
          v_rec_pri := dml_payment_register_item.get_record(par_payment_register_item_id => par_uro_id);
        ELSIF par_ure_type = 'doc_set_off'
        THEN
          v_rec_dso := dml_doc_set_off.get_record(par_doc_set_off_id => par_uro_id);
        END IF;
      END IF;
    
      INSERT INTO t_log_anul_del_pp_detail
        (id, t_log_anul_del_pp_id, ure_type, uro_id, action_type, action, num, amount, due_date)
      VALUES
        (sq_t_log_anul_del_pp_detail.nextval
        ,par_log_anul_del_pp_id
        ,par_ure_type
        ,par_uro_id
        ,par_action_type
        ,par_action
        ,decode(par_ure_type
               ,'ac_payment'
               ,v_rec_ac_payment.num
               ,'payment_register_item'
               ,NULL
               ,'doc_set_off'
               ,v_rec_dso.num)
        ,decode(par_ure_type
               ,'ac_payment'
               ,v_rec_ac_payment.amount
               ,'payment_register_item'
               ,v_rec_pri.payment_sum
               ,'doc_set_off'
               ,v_rec_dso.set_off_amount)
        ,decode(par_ure_type
               ,'ac_payment'
               ,v_rec_ac_payment.due_date
               ,'payment_register_item'
               ,v_rec_pri.payment_data
               ,'doc_set_off'
               ,v_rec_dso.set_off_date));
    END log_detail;
  
  BEGIN
    assert_deprecated(par_pp_id IS NULL, '�� ��������� ������ ���� ������');
    assert_deprecated(par_is_annulate IS NULL
                     ,'������ ���� ���� ������� ����� ������������ ��� ������� ���������');
    assert_deprecated(TRIM(par_reason) IS NULL
                     ,'������ ���� �������� �������');
    assert_deprecated(par_is_annulate AND (par_is_del_register OR par_is_del_pp)
                     ,'�� �������� ������������ ������������ � ������� ������� ��� ��');
    assert_deprecated(par_is_del_pp AND NOT par_is_del_register
                     ,'�� �������� ������� �� ������� �������');
    assert_deprecated(par_is_annulate AND par_cancel_date IS NULL
                     ,'������ ���� �������� ���� �������������');
  
    --���
    log(par_pp_id           => par_pp_id
       ,par_reason          => par_reason
       ,par_is_annulate     => sys.diutil.bool_to_int(par_is_annulate)
       ,par_is_del_register => sys.diutil.bool_to_int(par_is_del_register)
       ,par_is_del_pp       => sys.diutil.bool_to_int(par_is_del_pp)
       ,par_is_tex_err      => sys.diutil.bool_to_int(par_is_tex_err)
       ,par_cancel_date     => par_cancel_date
       ,par_it_out          => v_log_id);
  
    --�������� �� ��� ��������� � ��
    FOR rec IN (WITH links AS
                   (SELECT /*+connect_by_filtering CONNECT_BY_COST_BASED all_rows cardinality (10)*/
                    t.*
                   ,LEVEL lvl
                   ,PRIOR child_id prev_child_id
                     FROM (SELECT parent_id
                                 ,child_id
                             FROM doc_doc
                           UNION ALL
                           SELECT dso.parent_doc_id
                                 ,dso.child_doc_id
                             FROM doc_set_off dso) t
                    WHERE doc.get_doc_templ_brief(t.child_id) IN
                          ('��'
                          ,'��_��'
                          ,'��_��'
                          ,'�����'
                          ,'PD4'
                           --,'A7'
                          ,'������_��'
                          ,'PD4COPY'
                           --,'A7COPY'
                          ,'������_��_COPY')
                    START WITH child_id = par_pp_id
                   CONNECT BY PRIOR parent_id = child_id)
                  SELECT t.*
                        ,dso.doc_set_off_id doc_set_off_id
                        ,(SELECT dd.doc_doc_id
                            FROM doc_doc dd
                           WHERE dd.child_id = t.child_id
                             AND dd.parent_id = t.parent_id) doc_doc_id
                        ,doc.get_doc_templ_brief(t.parent_id) AS parent_doc_templ_brief
                        ,doc.get_doc_templ_brief(t.child_id) AS child_doc_templ_brief
                    FROM links       t
                        ,doc_set_off dso
                   WHERE dso.child_doc_id(+) = t.child_id
                     AND dso.parent_doc_id(+) = t.parent_id
                   ORDER BY lvl DESC
                           ,parent_id)
    LOOP
      BEGIN
      
        IF par_is_annulate
        -------------------------------------------------------------------------------------------
        --�������������
        -------------------------------------------------------------------------------------------
        THEN
          IF rec.doc_set_off_id IS NOT NULL
             AND doc.get_last_doc_status_brief(rec.doc_set_off_id) != 'ANNULATED'
          THEN
            UPDATE doc_set_off dso
               SET dso.cancel_date = par_cancel_date
             WHERE dso.doc_set_off_id = rec.doc_set_off_id;
          
            log_detail(par_log_anul_del_pp_id => v_log_id
                      ,par_ure_type           => 'doc_set_off'
                      ,par_uro_id             => rec.doc_set_off_id
                      ,par_action_type        => 'UPDATE'
                      ,par_action             => 'cancel_date = ' || to_char(par_cancel_date));
          
            doc.set_doc_status(p_doc_id       => rec.doc_set_off_id
                              ,p_status_brief => 'ANNULATED'
                              ,p_note         => par_reason);
          
            log_detail(par_log_anul_del_pp_id => v_log_id
                      ,par_ure_type           => 'doc_set_off'
                      ,par_uro_id             => rec.doc_set_off_id
                      ,par_action_type        => 'status'
                      ,par_action             => 'ANNULATED');
          
          END IF;
        
          IF rec.parent_doc_templ_brief IN
             ('PD4', 'PD4COPY', '������_��', '������_��_COPY')
          THEN
            doc.set_doc_status(p_doc_id       => rec.parent_id
                              ,p_status_brief => 'ANNULATED'
                              ,p_note         => par_reason);
          
            log_detail(par_log_anul_del_pp_id => v_log_id
                      ,par_ure_type           => 'ac_payment'
                      ,par_uro_id             => rec.parent_id
                      ,par_action_type        => 'status'
                      ,par_action             => 'ANNULATED');
          END IF;
        
          IF par_is_tex_err
          THEN
            UPDATE payment_register_item pri
               SET pri.recognize_data = NULL
                  ,pri.set_off_state  = 15
                  ,pri.status         = 0
             WHERE pri.recognized_payment_id = rec.parent_id;
          
            log_detail(par_log_anul_del_pp_id => v_log_id
                      ,par_ure_type           => 'payment_register_item'
                      ,par_action_type        => 'UPDATE'
                      ,par_action             => '���. ������ ��� ���� �� c recognized_payment_id = ' ||
                                                 to_char(rec.parent_id));
          
          END IF;
        
        ELSE
          -------------------------------------------------------------------------------------------
          --��������
          -------------------------------------------------------------------------------------------
          IF rec.doc_set_off_id IS NOT NULL
          THEN
            FOR rec_dso IN (SELECT dso.doc_set_off_id
                              FROM doc_set_off dso
                             WHERE dso.parent_doc_id = rec.parent_id
                                OR dso.child_doc_id = rec.parent_id)
            LOOP
              log_detail(par_log_anul_del_pp_id => v_log_id
                        ,par_ure_type           => 'doc_set_off'
                        ,par_uro_id             => rec_dso.doc_set_off_id
                        ,par_action_type        => 'DELETE'
                        ,par_action             => to_char(rec.parent_id));
              DELETE FROM document d WHERE d.document_id = rec_dso.doc_set_off_id;
            END LOOP;
          
          END IF;
        
          IF par_is_tex_err
          THEN
            UPDATE payment_register_item pri
               SET pri.recognize_data = NULL
                  ,pri.set_off_state  = 15
                  ,pri.status         = 0
             WHERE pri.recognized_payment_id = rec.parent_id;
          
            log_detail(par_log_anul_del_pp_id => v_log_id
                      ,par_ure_type           => 'payment_register_item'
                      ,par_action_type        => 'UPDATE'
                      ,par_action             => '���. ������ ��� ���� �� c recognized_payment_id = ' ||
                                                 to_char(rec.parent_id));
          END IF;
        
          IF rec.doc_doc_id IS NOT NULL
          THEN
            DELETE FROM doc_doc d
             WHERE d.parent_id = rec.parent_id
                OR d.child_id = rec.parent_id;
          
            log_detail(par_log_anul_del_pp_id => v_log_id
                      ,par_ure_type           => 'doc_doc'
                      ,par_action_type        => 'DELETE'
                      ,par_action             => to_char(rec.parent_id));
          
          END IF;
        
          IF par_is_del_register
          THEN
            DELETE payment_register_item pri WHERE pri.recognized_payment_id = rec.parent_id;
            log_detail(par_log_anul_del_pp_id => v_log_id
                      ,par_ure_type           => 'payment_register_item'
                      ,par_action_type        => 'DELETE'
                      ,par_action             => '�������� ���� �� c recognized_payment_id = ' ||
                                                 to_char(rec.parent_id));
          END IF;
        
          IF rec.parent_doc_templ_brief IN ('�����'
                                           ,'PD4'
                                            --,'A7'
                                           ,'������_��'
                                           ,'PD4COPY'
                                            --,'A7COPY'
                                           ,'������_��_COPY')
          THEN
            log_detail(par_log_anul_del_pp_id => v_log_id
                      ,par_ure_type           => 'ac_payment'
                      ,par_uro_id             => rec.parent_id
                      ,par_action_type        => 'DELETE');
            DELETE FROM document d WHERE d.document_id = rec.parent_id;
          END IF;
          -------------------------------------------------------------------------------------------
        END IF;
        --��������� ��� � ������
        IF rec.parent_doc_templ_brief = 'PAYMENT'
        THEN
          doc.set_doc_status(p_doc_id       => rec.parent_id
                            ,p_status_brief => 'TO_PAY'
                            ,p_note         => par_reason);
        
          log_detail(par_log_anul_del_pp_id => v_log_id
                    ,par_ure_type           => 'ac_payment'
                    ,par_uro_id             => rec.parent_id
                    ,par_action_type        => 'status'
                    ,par_action             => 'TO_PAY');
        END IF;
      
      EXCEPTION
        WHEN OTHERS THEN
          ex.raise_custom(par_message => 'id:' || par_pp_id || '; parend_id:' || rec.parent_id ||
                                         ';  child_id:' || rec.child_id || 'Error: ' || SQLERRM);
        
      END;
    
    END LOOP;
  
    --���������� ��, ������� ������ ��������� � ������������ �� ���� �������
    IF par_is_del_register
    THEN
      DELETE ins.payment_register_item
       WHERE payment_register_item_id IN
             (SELECT payment_register_item_id
                FROM ins.payment_register_item pri
               WHERE pri.ac_payment_id = par_pp_id);
    
      log_detail(par_log_anul_del_pp_id => v_log_id
                ,par_ure_type           => 'payment_register_item'
                ,par_action_type        => 'DELETE'
                ,par_action             => '������� �� ������������ �� ��������� � �� ' ||
                                           to_char(par_pp_id));
    
      IF NOT par_is_del_pp
      THEN
        pkg_payment_register.cre_dummy_register(p_payment_id => par_pp_id);
        UPDATE ac_payment ap SET ap.set_off_state = NULL WHERE ap.payment_id = par_pp_id;
        log_detail(par_log_anul_del_pp_id => v_log_id
                  ,par_ure_type           => 'ac_payment'
                  ,par_uro_id             => par_pp_id
                  ,par_action_type        => 'UPDATE'
                  ,par_action             => 'set_off_state = NULL');
      END IF;
    END IF;
  
    --�������� ��
    IF par_is_del_pp
    THEN
      log_detail(par_log_anul_del_pp_id => v_log_id
                ,par_ure_type           => 'ac_payment'
                ,par_uro_id             => par_pp_id
                ,par_action_type        => 'DELETE');
      DELETE FROM document d WHERE d.document_id = par_pp_id;
    END IF;
  
  END annulate_delete_all_links;

END pkg_payment_register;
/

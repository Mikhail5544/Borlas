CREATE OR REPLACE PACKAGE pkg_policy_quit IS
  ----========================================================================----
  -- ����������� ��
  ----========================================================================----
  -- ���������� ����� ������ � ������� ������ ��� �����������
  PROCEDURE add_pol_decline(par_policy_id NUMBER);
  ----========================================================================----
  -- ���������� ����� � ������� "����������� ��������. ������ �� ����������"
  PROCEDURE add_cover_decline(par_policy_id NUMBER);
  ----========================================================================----
  -- ���������� ������ ������� � ����� "����������� �������� �����������"
  PROCEDURE fill_cover_decline_line
  (
    par_policy_id        NUMBER
   ,par_cover_decline_id NUMBER
   ,par_as_asset_id      NUMBER
   ,par_product_line_id  NUMBER
   ,par_decline_date     DATE
    -- ������ �.
   ,par_product_conds VARCHAR2 DEFAULT NULL
  );
  ----========================================================================----
  -- ������ �������� �� ����
  FUNCTION calc_medo_cost(par_policy_id NUMBER) RETURN NUMBER;
  ----========================================================================----
  -- *** �������� ��� �������� �������� ***
  ----========================================================================----
  -- ��������: � ����� ����������� �������� ��������� ������������ ����
  PROCEDURE not_null_control(par_policy_id NUMBER);
  ----========================================================================----
  -- ��������: � ����� ����������� �������� "����� � �������" ������ ����
  PROCEDURE return_sum_greater_then_0(par_policy_id NUMBER);
  ----========================================================================----
  -- ��������: ������ ���������� ��������� ��� ������������
  PROCEDURE issuer_bank_acc_control(par_policy_id NUMBER);
  ----========================================================================----
  -- ��������: ���� � ����� ����������� �� ������ ����� �� ���. ������ ������,
  -- ������ ���� ��������� ���� "����� ����"
  PROCEDURE income_tax_sum_control(par_policy_id NUMBER);
  ----========================================================================----
  -- ��������: ���� � ����� ����������� �� "����� � �������" ������ ����,
  -- ������ ���� ������ "���� ������� ������������"
  PROCEDURE issuer_return_date_control(par_policy_id NUMBER);
  ----========================================================================----
  -- ����� �������� � 1 �������
  ----========================================================================----
  -- ����� �������� � 2:
  -- "����� ������ �� ������ �������" <=
  -- ( "����� � �������" - ���.�� �����( 0,13 * "���" ) )
  PROCEDURE return_sum_add_invest_income(par_policy_id NUMBER);
  ----========================================================================----
  -- ����� �������� � 3:
  -- �������� ������������ ������� ����������� � ��������� �����.
  -- ���� ������� ����������� "�������� ������� ������" ��� "����� �����������"
  -- ��� "����� ������������ �� ��", �� ����� ���� ������ ���� ������ ����:
  -- "������� ����� ������", "����������� ������ � �������� ������� ���",
  -- "����������� ������ � �������� ����� ����", "������� �� ����",
  -- "��������� �� ������ ����������", "����� ������ �� ������ �������",
  -- "� ����� � ��������� ������������ �������� ����� � �������� ������������",
  -- "����� � �������"
  PROCEDURE reason_greater_then_0(par_policy_id NUMBER);
  ----========================================================================----
  -- ��������: ���� � ����� ����������� �� "����" ������ ����,
  -- ������ ���� ������ "���� ���������� ����"
  PROCEDURE income_tax_sum_date_control(par_policy_id NUMBER);
  ----========================================================================----
  -- ��� �������� ������������ ��� ������� � �����������
  FUNCTION get_current_user_fio RETURN VARCHAR2;
  ----========================================================================----
  -- 1) ���������� ��, ���, �������
  FUNCTION get_round_1(par_p_policy_id NUMBER) RETURN NUMBER;
  ----========================================================================----
  -- 2) ���������� ������ � ���� ���������
  FUNCTION get_round_2(par_p_policy_id NUMBER) RETURN NUMBER;
  ----========================================================================----
  -- 3) ���������� ������ �� ����� �������:
  -- ���������� ����� ������������ � ������������ ����� �������� �� ��������:
  -- ����� �� (����� �� ������  ��), ������� ������� ��� (����� �� ������  ��),
  -- ������� ������� ���� (����� �� ������  ��).
  -- �������� �������: ���������� ������ � ���� ������� �������� =
  -- (�������� ���� "����� ������ �� ������ �������") -
  -- ? ������ "����� �� (����� �� ������  ��)" -
  -- ? ������ "������� ������� ��� (����� �� ������  ��)" -
  -- ? ������ "������� ������� ���� (����� �� ������  ��)"
  PROCEDURE get_round_3
  (
    par_p_policy_id  IN NUMBER
   ,par_round_err    OUT NUMBER
   , -- ������ ����������
    par_template_num OUT NUMBER -- ����� ������� ��������, � ����� �������
    -- ������ ������ ����������
  );
  ----========================================================================----
  -- 4) ���������� ��������� �� ��������
  FUNCTION get_round_4(par_p_policy_id NUMBER) RETURN NUMBER;
  ----========================================================================----
  -- ��������� �������������� ��������
  PROCEDURE gen_fix_trans(par_p_trans_decline_id NUMBER);
  ----========================================================================----
  -- �������� �������������� ��������
  PROCEDURE del_fix_trans(par_p_trans_decline_id NUMBER);
  ----========================================================================----
  -- ������� ����������� �� - � ������ "�������������"
  -- 1 - � ������, 0 - ���
  FUNCTION decline_reason_is_annul(par_p_policy_id NUMBER) RETURN NUMBER;
  ----========================================================================----
  -- ��������: ���� ������� ����������� �� �� ������ "�������������", ��
  -- ������ ���� ����� ����:
  -- �������� �����
  -- ���. ������ �����
  -- �����. �������
  -- ��������� �����������
  -- ��������� �����������
  -- ���������
  -- (����� �� �������������� ������ ��������)
  PROCEDURE check_annul(par_p_policy NUMBER);
  ----========================================================================----
  -- ��������� ������ ������ �������� �������� �� ����������� �� - �� ���� ����
  PROCEDURE gen_main_trans_group_1(par_p_policy_id NUMBER);
  ----========================================================================----
  -- ��������� ������ ������ �������� �������� �� ����������� �� - ���������
  PROCEDURE gen_main_trans_group_2(par_p_policy_id NUMBER);
  ----========================================================================----
  -- ��������� �������� �� ������ �� ������ �������
  PROCEDURE gen_trans_setoff(par_doc_id NUMBER);
  ----========================================================================----
  -- ������� ������������ �����
  PROCEDURE delete_unpayed_acc(par_p_policy_id NUMBER);
  ----========================================================================----
  -- ��������: � ����� ������������� �������� �� ������� ���� ����� �� ��������
  -- "������"
  PROCEDURE check_fix_trans_status(par_policy_id NUMBER);
  ----========================================================================----
  -- �������� / ������������� ������ ������ �������� �������� �� ����������� �� -
  -- ( �� ���� ���� )
  PROCEDURE del_main_trans_group_1(par_p_policy_id NUMBER);
  ----========================================================================----
  -- �������� / ������������� ������ ������ �������� �������� �� ����������� �� -
  -- ( ��������� )
  PROCEDURE del_main_trans_group_2(par_p_policy_id NUMBER);
  ----========================================================================----
  -- ������� ���������� ��������� ( ���� ) ��� ��������
  FUNCTION get_trans_plo_desc(p_trans_id NUMBER) RETURN VARCHAR2;
  ----========================================================================----
  /*
    ������ �.
    �������� ����� ������ �� ������: '22.05','22.01','22.05.01','22.05.02','22.05.11','22.05.31','22.05.33',
                                     '77.00.01','77.00.02','77.08.03','91.01','91.02','92.01'
    ���� ������ ���������� �� 0, �������� ��������� �� ����, � ��������� �����

    par_policy_id - �� ������ ��
  */
  --PROCEDURE check_saldo(par_policy_id NUMBER);

  /**
  * ����������� ��. ������������� ������ �� ��������
  * � �����������. ����� ��� �������� - � �����������. ��������
  * ��������� ���������� ���������� ������ �� �������� � ������� ��������, ����� ���������� �� ����
  * � ��������� ����� ������� �� ������� �� �����, ��� �� ��������� �������� ������� �.�. ������ ����
  * ������ ������ � ����
  * @author ����� �.
  * @param par_policy_id - �� ������ �����������
  */
  PROCEDURE correct_saldo_on_quit(par_policy_id NUMBER);
  /*
    ������ �.
    �������� ������������� �������� �� ������ 22.01, 22.05.01, 22.05.02 � ������ ��������� �� ������,
    ���� ����� �������� ����������.
    par_policy_id - �� ������ �������� �����������
  */
  PROCEDURE check_accounts(par_policy_id NUMBER);
  /*
    ������ �.
    ������ �������� ������������� ��������, �� ��������� � ����������
    par_policy_id - �� ������ �������� �����������
  */
  PROCEDURE cancel_corr_trans(par_policy_id NUMBER);
  /*
    ������ �.
    ���������� �������������� ��������

    par_pol_decline_id   - �� ������ �� ����������� ������ ��
    par_p_cover_id       - �� ��������
    par_oper_templ_brief - ���������� ������� ��������
    par_doc_templ_brief  - ���������� ������� ���������
    par_trans_sum        - ����� ��������
    par_trans_date       - ���� ��������
    par_status_date      - ���� �������� �������
    par_trans_id         - �� ��������� �������� (��������)
  */
  PROCEDURE insert_corr_trans
  (
    par_pol_decline_id   NUMBER
   ,par_p_cover_id       NUMBER
   ,par_oper_templ_brief VARCHAR2
   ,par_doc_templ_brief  VARCHAR2
   ,par_trans_sum        NUMBER
   ,par_trans_date       DATE
   ,par_status_date      DATE DEFAULT SYSDATE
   ,par_trans_id         OUT NUMBER
  );

  /*
    ������ �.
    �������� ������� ���������� ���������� ��� �������� �� � ������ "���������. � �������"
    par_p_policy_id - ID ������ ��
  */
  PROCEDURE check_payment_request(par_p_policy_id NUMBER);
  /**
   * �������� ���������� �����������, ���� ��� ��� (�� �������� �������� "���������. ��������� ��������"-"���������. � �������"
   * @author  ������ �. 30.1.2015
   -- %param par_policy_id  �� ������ ��
  */
  PROCEDURE create_payment_request(par_p_policy_id NUMBER);
  /*
    ������ �.
    ������������ ���������� �� ��� �������� ��������� � ������ "���������.� �������"
    par_p_policy_id - ID ������ ��
  */
  PROCEDURE make_outgoing_bank_doc(par_p_policy_id NUMBER);

  /*
    ������ �.
    �������� �� ��� �������� ��������� �� ������� "���������.� �������" � ������ "���������. ��������� ��������"
    par_p_policy_id - ID ������ ��
  */
  PROCEDURE delete_outgoing_bank_doc(par_p_policy_id NUMBER);

  /*
    ������ �.

    �������������� �������� �������������� �������� ��� �������� ���������
    �� ������� "� �����������. ����� ��� ��������" � ������ "� �����������. ��������"

    par_policy_id - �� ������ ��������
  */
  PROCEDURE make_correct_trans_auto(par_policy_id NUMBER);

  /**
   * �������� ������� ������� �� ����
   * @author  ������ �. 28.1.2015
   -- %param par_policy_id  �� ������ ��
  */
  PROCEDURE check_claim(par_policy_id p_policy.policy_id%TYPE);

  /**
   * ��������: ������� � ������� �������� �������� ���� ������� ����������. � ������� - ����������
   * @author  ������ �. 28.1.2015
   -- %param par_policy_id  �� ������ ��
  */
  PROCEDURE check_was_quit_to_pay_status(par_policy_id p_policy.policy_id%TYPE);

  /**
   * ��������: ���������� � �������� ���� ���������� ������������ ��� ������ 0, �� ������
   * @author  ������ �. 6.3.2015
   -- %param par_policy_id  �� ������ ��
  */
  PROCEDURE check_overpayment_and_debt(par_policy_id p_policy.policy_id%TYPE);

END pkg_policy_quit;
/
CREATE OR REPLACE PACKAGE BODY pkg_policy_quit IS
  ----========================================================================----
  -- ����������� ��
  ----========================================================================----
  -- ����������, ���� �� �������� �������� ��� �� � �������� ����������� �� ������
  -- "�������������"
  e_annul_check_failure EXCEPTION;
  ----========================================================================----
  -- ���������� ����� ������ � ������� ������ ��� �����������
  -- ��������: �� ������� �������� ������ �������� �����������
  PROCEDURE add_pol_decline(par_policy_id NUMBER) IS
  BEGIN
    INSERT INTO ven_p_pol_decline (p_policy_id) VALUES (par_policy_id);
    -- ��������� ������� ������ ��
    UPDATE p_pol_header
       SET policy_id = par_policy_id
     WHERE policy_header_id = (SELECT pol_header_id FROM p_policy WHERE policy_id = par_policy_id);
  END add_pol_decline;
  ----========================================================================----
  -- ���������� ����� � ������� "����������� ��������. ������ �� ����������"
  -- ��������: �� ������� �������� ������ �������� �����������
  PROCEDURE add_cover_decline(par_policy_id NUMBER) IS
    v_prev_policy_id NUMBER;
    v_pol_decline_id NUMBER;
    CURSOR cover_curs(pcurs_policy_id NUMBER) IS
      SELECT fn_obj_name(a.ent_id, a.as_asset_id) asset_name
            ,pl.description cover_name
            ,a.as_asset_id
            ,pl.id t_product_line_id
            ,trunc(MONTHS_BETWEEN(trunc(c.end_date) + 1, trunc(c.start_date)) / 12, 2) cover_period
        FROM as_asset           a
            ,p_cover            c
            ,t_prod_line_option plo
            ,t_product_line     pl
       WHERE a.p_policy_id = pcurs_policy_id
         AND c.as_asset_id = a.as_asset_id
         AND c.t_prod_line_option_id = plo.id
         AND plo.product_line_id = pl.id
       ORDER BY a.as_asset_id
               ,pl.sort_order;
  BEGIN
    -- ����� ������������� ������ �������� (��������� ������ - �� ��������
    -- "� �����������")
    SELECT pp.prev_ver_id INTO v_prev_policy_id FROM p_policy pp WHERE policy_id = par_policy_id;

    -- ����� ������ ������ �� ����������� ������ ��
    SELECT p_pol_decline_id
      INTO v_pol_decline_id
      FROM p_pol_decline
     WHERE p_policy_id = par_policy_id;
    -- �������� ������ � ������� "����������� ��������. ������ �� ����������"
    FOR curs_rec IN cover_curs(v_prev_policy_id)
    LOOP
      INSERT INTO ven_p_cover_decline
        (p_pol_decline_id, as_asset_id, t_product_line_id, cover_period)
      VALUES
        (v_pol_decline_id, curs_rec.as_asset_id, curs_rec.t_product_line_id, curs_rec.cover_period);
    END LOOP;
  END add_cover_decline;
  ----========================================================================----
  -- ���������� ������ ������� � ����� "����������� �������� �����������"
  PROCEDURE fill_cover_decline_line
  (
    par_policy_id        NUMBER
   ,par_cover_decline_id NUMBER
   ,par_as_asset_id      NUMBER
   ,par_product_line_id  NUMBER
   ,par_decline_date     DATE
    -- ������ �.
   ,par_product_conds VARCHAR2 DEFAULT NULL
  ) IS
    v_version_num    p_policy.version_num%TYPE;
    v_pol_header_id  NUMBER;
    v_prev_policy_id NUMBER;
    --
    v_redemption_sum      NUMBER;
    v_add_invest_income   NUMBER;
    v_return_bonus_part   NUMBER;
    v_bonus_off_prev      NUMBER;
    v_bonus_off_current   NUMBER;
    v_admin_expenses      NUMBER;
    v_underpayment_actual NUMBER;
    --
    v_line_desc t_product_line.description%TYPE;
    v_type_desc t_product_line_type.presentation_desc%TYPE;

    FUNCTION is_annulate(par_policy_id p_policy.policy_id%TYPE) RETURN BOOLEAN IS
      v_decline_type_brief t_decline_type.brief%TYPE;
    BEGIN
      SELECT dt.brief
        INTO v_decline_type_brief
        FROM p_policy         pp
            ,t_decline_reason dr
            ,t_decline_type   dt
       WHERE pp.policy_id = par_policy_id
         AND pp.decline_reason_id = dr.t_decline_reason_id
         AND dr.t_decline_type_id = dt.t_decline_type_id;

      RETURN v_decline_type_brief = '�������������';
    EXCEPTION
      WHEN no_data_found THEN
        RETURN NULL;
    END is_annulate;
  BEGIN
    -- ����� ������������� ������ �������� (��������� ������ - �� ��������
    -- "� �����������")
    BEGIN
      SELECT version_num
            ,pol_header_id
            ,pp.prev_ver_id
        INTO v_version_num
            ,v_pol_header_id
            ,v_prev_policy_id
        FROM p_policy pp
       WHERE policy_id = par_policy_id;
    EXCEPTION
      WHEN OTHERS THEN
        v_prev_policy_id := NULL;
    END;
    -- *** �������� �����
    IF v_prev_policy_id IS NOT NULL
    THEN
      BEGIN
        SELECT l.description       line_desc
              ,t.presentation_desc type_desc
          INTO v_line_desc
              ,v_type_desc
          FROM t_product_line      l
              ,t_product_line_type t
         WHERE l.product_line_type_id = t.product_line_type_id
           AND l.id = par_product_line_id;
      EXCEPTION
        WHEN OTHERS THEN
          v_line_desc := NULL;
          v_type_desc := NULL;
      END;
    END IF;
    -- ���� �������� ��������� ��� ��������� ������ ...
    -- �������� �������������� ������ ��� �����������
    IF (nvl(v_type_desc, '~') = '���' OR nvl(v_line_desc, '~') = '������' OR
       nvl(v_line_desc, '~') = '������2' OR nvl(v_line_desc, '~') = '����������������' OR
       nvl(v_line_desc, '~') = '�����������' OR nvl(v_line_desc, '~') = '����������� ����')
       AND v_prev_policy_id IS NOT NULL
       AND NOT is_annulate(par_policy_id => par_policy_id)
    THEN
      -- �� ������������� ������ ��������

      /**
       * ������ �.
       * ���� ������� �������� �� �� ������ ������� ����������� �� 23.06.2006�,
       * ������ ������� ����������� �� �������� "�������� �����" �� 21.03.2005�,
       * �������� ����������� ����� �� 30.06.2007�,
       * �� �������� ����� �������������� �� ���� �������� ������� (��.������� �������� ����),
       * �� ������� ���������� ���� �����������.
      */
      IF par_product_conds IN
         ('����� ������� ����������� �� 23.06.2006'
         ,'������� ����������� ����� �� 30.06.2007'
         ,'����� ������� ����������� �� �������� "�������� �����" �� 21.03.2005'
         ,'�� "�������� �������" �� 07.02.2008'
         ,'�������� ������� � ��������� ����������� "�������� ������� �� 02.06.2011"')
      THEN
        BEGIN
          SELECT csd.value
            INTO v_redemption_sum
            FROM -- �������� �����
                 policy_cash_surr   cs
                ,policy_cash_surr_d csd
                ,t_product_line     pl
                 -- �����������
                ,p_pol_decline   pd
                ,p_cover_decline cd
                ,as_asset        et
           WHERE cs.policy_id = v_prev_policy_id
             AND cs.t_lob_line_id = pl.t_lob_line_id

             AND pd.p_pol_decline_id = cd.p_pol_decline_id
             AND cd.p_cover_decline_id = par_cover_decline_id
             AND cd.as_asset_id = et.as_asset_id
             AND cd.t_product_line_id = pl.id
             AND et.contact_id = cs.contact_id

             AND csd.policy_cash_surr_id = cs.policy_cash_surr_id
             AND par_decline_date BETWEEN csd.start_cash_surr_date AND csd.end_cash_surr_date

             AND rownum = 1; -- � �������� ������ ����� ���� �����, ������� ���������� ������ ���������� ������
          -- ����������� � ���������� ������
        EXCEPTION
          WHEN no_data_found THEN
            v_redemption_sum := 0;
        END;
        /**
         * ������ �.
         * ���� ������� �������� �� �� ��������� ������� � �������� ����������� ����� �� ���������� ����������� �����
         * "�������� �����", "�����", "����", "�������" �� 01.04.2009�
         * � ��������� ������� � �������� ����������� ����� �� ���������� ����������� �����
         * "�������� �����", "�����", "����", "�������" �� 09.11.2009�,
         * �� �������� ����� �������������� �� ���� �������� �������,
         * �� ������� ���������� ���� ���������� ����������� ������ ��� ���� ����������� �������� �����������,
         * � ����������� �� ����, ����� �� ��� �������� ����� ������.
        */
      ELSIF par_product_conds IN
            ('�������� ������� � �������� ����������� ����� �� ���������� ����������� ����� "�������� �����", "�����", "����", "�������" �� 01.04.2009'
            ,'�������� ������� � �������� ����������� ����� �� ���������� ����������� ����� "�������� �����", "�����", "����", "�������" �� 09.11.2009'
            ,'�������� ������� ����������� ����� �� ��������� ��������� �� 23.12.2013�.'
            ,'�������� ������� ����������� ����� �� ��������� "��������" �� 17.03.2011'
            ,'�������� ������� ����������� ����� �� ��������� "��������" �� 20.12.2011'
            ,'�������� ������� ����������� ����� �� ��������� ��������� ���ѻ')
      THEN
        BEGIN
          SELECT csd.value
            INTO v_redemption_sum
            FROM -- �������� �����
                 policy_cash_surr   cs
                ,policy_cash_surr_d csd
                ,t_product_line     pl
                 -- �����������
                ,p_pol_decline   pd
                ,p_cover_decline cd
                ,as_asset        et
           WHERE cs.policy_id = v_prev_policy_id
             AND cs.t_lob_line_id = pl.t_lob_line_id

             AND pd.p_pol_decline_id = cd.p_pol_decline_id
             AND cd.p_cover_decline_id = par_cover_decline_id
             AND cd.as_asset_id = et.as_asset_id
             AND cd.t_product_line_id = pl.id
             AND et.contact_id = cs.contact_id

             AND csd.policy_cash_surr_id = cs.policy_cash_surr_id
             AND (SELECT least(nvl(MAX(ac.due_date), par_decline_date), par_decline_date)
                    FROM p_policy         pp
                        ,doc_doc          dd
                        ,ac_payment       ac
                        ,ac_payment_templ pt
                   WHERE pp.pol_header_id = v_pol_header_id
                     AND dd.parent_id = pp.policy_id
                     AND dd.child_id = ac.payment_id
                     AND ac.payment_templ_id = pt.payment_templ_id
                     AND pt.brief = 'PAYMENT'
                     AND doc.get_doc_status_brief(ac.payment_id) = 'PAID') BETWEEN
                 csd.start_cash_surr_date AND csd.end_cash_surr_date
             AND rownum = 1;
        EXCEPTION
          WHEN no_data_found THEN
            v_redemption_sum := 0;
        END;
      ELSE
        -- ������ �.
        -- ���� ������� �� �����������, ������ ������ ������
        BEGIN
          SELECT csd.value
            INTO v_redemption_sum
            FROM ven_policy_cash_surr   cs
                ,ven_as_asset           aa
                ,ven_t_lob_line         ll
                ,t_product_ver_lob      pvl
                ,t_product_line         pl
                ,ven_policy_cash_surr_d csd
                ,
                 --
                 p_cover            pc
                ,t_prod_line_option opt
                ,t_product_line     pll
                ,ven_t_lob_line     bll
          --
           WHERE cs.policy_id = v_prev_policy_id
             AND cs.contact_id = aa.contact_id
             AND aa.as_asset_id = par_as_asset_id
             AND cs.t_lob_line_id = ll.t_lob_line_id
             AND ll.t_lob_id = pvl.lob_id
             AND pvl.t_product_ver_lob_id = pl.product_ver_lob_id
             AND pl.id = par_product_line_id
                --
             AND aa.as_asset_id = pc.as_asset_id
             AND pc.t_prod_line_option_id = opt.id
             AND opt.product_line_id = pll.id
             AND pll.t_lob_line_id = bll.t_lob_line_id
             AND bll.t_lob_line_id = ll.t_lob_line_id
             AND pl.id = pll.id
                --
             AND cs.policy_cash_surr_id = csd.policy_cash_surr_id
             AND csd.end_cash_surr_date =
                 (SELECT MAX(csd2.end_cash_surr_date)
                    FROM ven_policy_cash_surr_d csd2
                   WHERE csd2.policy_cash_surr_id = cs.policy_cash_surr_id
                     AND csd2.end_cash_surr_date <= par_decline_date);
        EXCEPTION
          WHEN OTHERS THEN
            v_redemption_sum := 0;
        END;
      END IF;
    ELSE
      v_redemption_sum := 0;
    END IF;
    -- *** ���. ������ �����
    IF (nvl(v_type_desc, '~') = '���' OR nvl(v_line_desc, '~') = '������' OR
       nvl(v_line_desc, '~') = '������2' OR nvl(v_line_desc, '~') = '����������������' OR
       nvl(v_line_desc, '~') = '�����������' OR nvl(v_line_desc, '~') = '����������� ����')
       AND v_prev_policy_id IS NOT NULL
    THEN
      BEGIN
        SELECT aii.add_income_cur
          INTO v_add_invest_income
          FROM ven_p_add_invest_income aii
              ,ven_as_assured          aa
              ,contact                 c
         WHERE aii.pol_header_id = v_pol_header_id
           AND aii.t_product_line_id = par_product_line_id
           AND upper(c.name || ' ' || c.first_name || ' ' || c.middle_name) = aii.as_asset_name
           AND c.contact_id = aa.assured_contact_id
           AND aa.as_assured_id = par_as_asset_id
           AND aii.income_date = (SELECT MAX(aii2.income_date)
                                    FROM ven_p_add_invest_income aii2
                                        ,ven_as_assured          aa2
                                        ,contact                 c2
                                   WHERE aii2.income_date <= par_decline_date
                                     AND aii2.pol_header_id = v_pol_header_id
                                     AND aii2.t_product_line_id = par_product_line_id
                                     AND aii2.as_asset_name =
                                         upper(c2.name || ' ' || c2.first_name || ' ' || c2.middle_name)
                                     AND c2.contact_id = aa2.assured_contact_id
                                     AND aa2.as_assured_id = par_as_asset_id);
      EXCEPTION
        WHEN no_data_found THEN
          v_add_invest_income := 0;
      END;
    ELSE
      v_add_invest_income := 0;
    END IF;
    -- *** ������� ����� ������
    v_return_bonus_part := 0;
    -- *** ����������� ������ � �������� ������� ���
    v_bonus_off_prev := 0;
    -- *** ����������� ������ � �������� ����� ����
    v_bonus_off_current := 0;
    -- ***��������� �����������
    v_underpayment_actual := 0;
    -- *** ���������������� ��������
    v_admin_expenses := 0;
    -- ������ �.
    -- ������� ���������� �� 2-� ������
    UPDATE p_cover_decline
       SET redemption_sum      = ROUND(v_redemption_sum, 2)
          ,add_invest_income   = ROUND(v_add_invest_income, 2)
          ,return_bonus_part   = ROUND(v_return_bonus_part, 2)
          ,bonus_off_prev      = ROUND(v_bonus_off_prev, 2)
          ,bonus_off_current   = ROUND(v_bonus_off_current, 2)
          ,admin_expenses      = ROUND(v_admin_expenses, 2)
          ,underpayment_actual = ROUND(v_underpayment_actual, 2)
     WHERE p_cover_decline_id = par_cover_decline_id;
    --EXCEPTION
    --WHEN others THEN
    --Raise_Application_Error( -20001, '������ Fill_Cover_Decline_Line: ' ||
    --SQLERRM );
  END fill_cover_decline_line;
  ----========================================================================----
  -- ������ �������� �� ����
  FUNCTION calc_medo_cost(par_policy_id NUMBER) RETURN NUMBER IS
    v_medo_cost NUMBER;
  BEGIN
    SELECT SUM(exam_cost) INTO v_medo_cost FROM ven_as_assured WHERE p_policy_id = par_policy_id;
    RETURN(nvl(v_medo_cost, 0));
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001, '������ Calc_Medo_Cost: ' || SQLERRM);
  END calc_medo_cost;
  ----========================================================================----
  -- *** �������� ��� �������� �������� ***
  ----========================================================================----
  -- ��������: � ����� ����������� �������� ��������� ������������ ����
  PROCEDURE not_null_control(par_policy_id NUMBER) IS
    v_msg VARCHAR2(500);
    v_exeption EXCEPTION;
    v_reg_code           NUMBER;
    v_t_product_conds_id NUMBER;
    v_decline_date       DATE;
    v_decline_reason_id  NUMBER;
    v_medo_cost          NUMBER;
    v_debt_fee_sum       NUMBER;
    v_act_date           DATE;
  BEGIN
    SELECT pd.reg_code
          ,pd.t_product_conds_id
          ,p.decline_date
          ,p.decline_reason_id
          ,pd.medo_cost
          ,p.debt_summ
          ,pd.act_date
      INTO v_reg_code
          ,v_t_product_conds_id
          ,v_decline_date
          ,v_decline_reason_id
          ,v_medo_cost
          ,v_debt_fee_sum
          ,v_act_date
      FROM p_policy      p
          ,p_pol_decline pd
     WHERE p.policy_id = pd.p_policy_id
       AND p.policy_id = par_policy_id;
    IF v_reg_code IS NULL
    THEN
      v_msg := '� ����� ����������� �� �� ��������� ���� "��� �������"';
      RAISE v_exeption;
    END IF;
    IF v_t_product_conds_id IS NULL
    THEN
      v_msg := '� ����� ����������� �� �� ��������� ���� "�������� �������"';
      RAISE v_exeption;
    END IF;
    IF v_decline_date IS NULL
    THEN
      v_msg := '� ����� ����������� �� �� ��������� ���� "���� ����������� ��"';
      RAISE v_exeption;
    END IF;
    IF v_decline_reason_id IS NULL
    THEN
      v_msg := '� ����� ����������� �� �� ��������� ���� "������� ����������� ��"';
      RAISE v_exeption;
    END IF;
    IF v_medo_cost IS NULL
    THEN
      v_msg := '� ����� ����������� �� �� ��������� ���� "������� �� ����"';
      RAISE v_exeption;
    END IF;
    IF v_debt_fee_sum IS NULL
    THEN
      v_msg := '� ����� ����������� �� �� ��������� ���� ' || '"��������� �� ������ ����������"';
      RAISE v_exeption;
    END IF;
    IF v_act_date IS NULL
    THEN
      v_msg := '� ����� ����������� �� �� ��������� ���� ' || '"���� ����"';
      RAISE v_exeption;
    END IF;
  EXCEPTION
    WHEN v_exeption THEN
      raise_application_error(-20002, v_msg);
    WHEN OTHERS THEN
      raise_application_error(-20001, 'Not_Null_Control: ' || SQLERRM);
  END not_null_control;
  ----========================================================================----
  -- ��������: � ����� ����������� �������� "����� � �������" ������ ����
  PROCEDURE return_sum_greater_then_0(par_policy_id NUMBER) IS
    v_msg VARCHAR2(500);
    v_exeption EXCEPTION;
    v_return_sum NUMBER;
  BEGIN
    SELECT p.return_summ INTO v_return_sum FROM p_policy p WHERE p.policy_id = par_policy_id;
    IF nvl(v_return_sum, 0) <= 0
    THEN
      v_msg := '� ����� ����������� �� ���� "����� � �������" ������ ���� ������ 0';
      RAISE v_exeption;
    END IF;
  EXCEPTION
    WHEN v_exeption THEN
      raise_application_error(-20002, v_msg);
    WHEN OTHERS THEN
      raise_application_error(-20001, 'Return_Sum_Greater_Then_0: ' || SQLERRM);
  END return_sum_greater_then_0;
  ----========================================================================----
  -- ��������: ������ ���������� ��������� ��� ������������
  PROCEDURE issuer_bank_acc_control(par_policy_id NUMBER) IS
    v_msg VARCHAR2(500);
    v_exeption EXCEPTION;
    v_dummy CHAR(1);
  BEGIN
    BEGIN
      SELECT '1'
        INTO v_dummy
        FROM p_policy_contact        pc
            ,t_contact_pol_role      cpr
            ,ven_cn_contact_bank_acc acc
       WHERE pc.policy_id = par_policy_id
         AND cpr.brief = '������������'
         AND cpr.id = pc.contact_policy_role_id
         AND pc.contact_id = acc.contact_id;
    EXCEPTION
      WHEN no_data_found THEN
        v_msg := '�� ������ ���������� ��������� ��� ������������';
        RAISE v_exeption;
      WHEN too_many_rows THEN
        NULL;
    END;
  EXCEPTION
    WHEN v_exeption THEN
      raise_application_error(-20002, v_msg);
    WHEN OTHERS THEN
      raise_application_error(-20001, 'Issuer_Bank_Acc_Control: ' || SQLERRM);
  END issuer_bank_acc_control;
  ----========================================================================----
  -- ��������: ���� � ����� ����������� �� ������ ����� �� ���. ������ ������,
  -- ������ ���� ��������� ���� "����� ����"
  PROCEDURE income_tax_sum_control(par_policy_id NUMBER) IS
    v_msg VARCHAR2(500);
    v_exeption EXCEPTION;
    v_income_tax_sum NUMBER;
  BEGIN
    BEGIN
      SELECT p.income_tax_sum
        INTO v_income_tax_sum
        FROM p_pol_decline p
       WHERE p.p_policy_id = par_policy_id
         AND EXISTS (SELECT '2'
                FROM p_cover_decline cd
                    ,p_pol_decline   pd
               WHERE pd.p_pol_decline_id = cd.p_pol_decline_id
                 AND pd.p_policy_id = par_policy_id
                 AND nvl(cd.add_invest_income, 0) > 0);
      IF v_income_tax_sum IS NULL
      THEN
        v_msg := '���� � ����� ����������� �� ������ ����� �� ���. ������ ������, ' ||
                 '������ ���� ��������� ���� "����� ����"';
        RAISE v_exeption;
      END IF;
    EXCEPTION
      WHEN no_data_found THEN
        NULL;
    END;
  EXCEPTION
    WHEN v_exeption THEN
      raise_application_error(-20002, v_msg);
    WHEN OTHERS THEN
      raise_application_error(-20001, 'Income_Tax_Sum_Control: ' || SQLERRM);
  END income_tax_sum_control;
  ----========================================================================----
  -- ��������: ���� � ����� ����������� �� "����� � �������" ������ ����,
  -- ������ ���� ������ "���� ������� ������������"
  PROCEDURE issuer_return_date_control(par_policy_id NUMBER) IS
    v_msg VARCHAR2(500);
    v_exeption EXCEPTION;
    v_issuer_return_date DATE;
    v_return_sum         NUMBER;
  BEGIN
    SELECT pd.issuer_return_date
          ,p.return_summ
      INTO v_issuer_return_date
          ,v_return_sum
      FROM p_policy      p
          ,p_pol_decline pd
     WHERE p.policy_id = par_policy_id
       AND p.policy_id = pd.p_policy_id;
    IF nvl(v_return_sum, 0) > 0
       AND v_issuer_return_date IS NULL
    THEN
      v_msg := '���� � ����� ����������� �� "����� � �������" ������ ����, ' ||
               '������ ���� ������ "���� ������� ������������"';
      RAISE v_exeption;
    END IF;
  EXCEPTION
    WHEN v_exeption THEN
      raise_application_error(-20002, v_msg);
    WHEN OTHERS THEN
      raise_application_error(-20001, 'Issuer_Return_Date_Control: ' || SQLERRM);
  END issuer_return_date_control;
  ----========================================================================----
  -- ����� �������� � 1 �������
  ----========================================================================----
  -- ����� �������� � 2:
  -- "����� ������ �� ������ �������" <=
  -- ( "����� � �������" )
  PROCEDURE return_sum_add_invest_income(par_policy_id NUMBER) IS
    v_msg VARCHAR2(500);
    v_exeption EXCEPTION;
    v_return_sum            NUMBER;
    v_other_pol_sum         NUMBER;
v_income_tax_sum number;
  BEGIN
    SELECT p.return_summ
          ,pd.other_pol_sum
					,pd.income_tax_sum
      INTO v_return_sum
          ,v_other_pol_sum
					,v_income_tax_sum
      FROM p_policy      p
          ,p_pol_decline pd
     WHERE p.policy_id = par_policy_id
       AND p.policy_id = pd.p_policy_id;

    IF nvl(v_other_pol_sum, 0) > greatest(nvl(v_return_sum, 0)-nvl(v_income_tax_sum,0),0)
    THEN
      v_msg := '������ ����: "����� ������ �� ������ �������" <= "����� � �������" - ����� ����';
      RAISE v_exeption;
    END IF;
  EXCEPTION
    WHEN v_exeption THEN
      raise_application_error(-20002, v_msg);
    WHEN OTHERS THEN
      raise_application_error(-20001, 'Return_Sum_Add_Invest_Income: ' || SQLERRM);
  END return_sum_add_invest_income;
  ----========================================================================----
  -- ����� �������� � 3:
  -- �������� ������������ ������� ����������� � ��������� �����.
  -- ���� ������� ����������� "�������� ������� ������" ��� "����� �����������"
  -- ��� "����� ������������ �� ��", �� ����� ���� ������ ���� ������ ����:
  -- "������� ����� ������", "����������� ������ � �������� ������� ���",
  -- "����������� ������ � �������� ����� ����", "������� �� ����",
  -- "��������� �� ������ ����������", "����� ������ �� ������ �������",
  -- "� ����� � ��������� ������������ �������� ����� � �������� ������������",
  -- "����� � �������"
  PROCEDURE reason_greater_then_0(par_policy_id NUMBER) IS
    v_msg VARCHAR2(500);
    v_exeption EXCEPTION;
    v_reason_brief          t_decline_reason.brief%TYPE;
    v_income_tax_sum        NUMBER;
    v_sum_redemption_sum    NUMBER;
    v_sum_add_invest_income NUMBER;
  BEGIN
    BEGIN
      SELECT dr.brief
            ,pd.income_tax_sum
        INTO v_reason_brief
            ,v_income_tax_sum
        FROM ven_p_policy         p
            ,ven_t_decline_reason dr
            ,ven_p_pol_decline    pd
       WHERE p.decline_reason_id = dr.t_decline_reason_id
         AND p.policy_id = pd.p_policy_id
         AND p.policy_id = par_policy_id;
    EXCEPTION
      WHEN OTHERS THEN
        v_reason_brief := NULL;
    END;
    IF v_reason_brief IS NOT NULL
    THEN
      IF v_reason_brief IN ('�������� ������� ������'
                           ,'����� �����������'
                           ,'����� ������������ �� ��')
      THEN
        IF nvl(v_income_tax_sum, 0) > 0
        THEN
          v_msg := '���� ������� ����������� "' || v_reason_brief ||
                   '", �� "����� ����" �� ����� ���� ������ ����.';
          RAISE v_exeption;
        END IF;
        SELECT SUM(cd.redemption_sum)
              ,SUM(cd.add_invest_income)
          INTO v_sum_redemption_sum
              ,v_sum_add_invest_income
          FROM p_pol_decline   pd
              ,p_cover_decline cd
         WHERE pd.p_policy_id = par_policy_id
           AND pd.p_pol_decline_id = cd.p_pol_decline_id;
        IF nvl(v_sum_redemption_sum, 0) > 0
        THEN
          v_msg := '���� ������� ����������� "' || v_reason_brief ||
                   '", �� "�������� �����" �� ����� ���� ������ ����.';
          RAISE v_exeption;
        END IF;
        IF nvl(v_sum_add_invest_income, 0) > 0
        THEN
          v_msg := '���� ������� ����������� "' || v_reason_brief ||
                   '", �� "���. ������ �����" �� ����� ���� ������ ����.';
          RAISE v_exeption;
        END IF;
      END IF;
    END IF;
  EXCEPTION
    WHEN v_exeption THEN
      raise_application_error(-20002, v_msg);
    WHEN OTHERS THEN
      raise_application_error(-20001, 'Reason_Greater_Then_0: ' || SQLERRM);
  END reason_greater_then_0;
  ----========================================================================----
  -- ��������: ���� � ����� ����������� �� "����" ������ ����,
  -- ������ ���� ������ "���� ���������� ����"
  PROCEDURE income_tax_sum_date_control(par_policy_id NUMBER) IS
    v_income_tax_sum  NUMBER;
    v_income_tax_date DATE;
    v_msg             VARCHAR2(500);
    v_exeption EXCEPTION;
  BEGIN
    BEGIN
      SELECT income_tax_sum
            ,income_tax_date
        INTO v_income_tax_sum
            ,v_income_tax_date
        FROM p_pol_decline
       WHERE p_policy_id = par_policy_id;
    EXCEPTION
      WHEN OTHERS THEN
        v_income_tax_sum := NULL;
    END;
    IF nvl(v_income_tax_sum, 0) > 0
       AND v_income_tax_date IS NULL
    THEN
      v_msg := '���� ���� ������ ����, ������ ���� ������ ���� ���������� ����';
      RAISE v_exeption;
    END IF;
  EXCEPTION
    WHEN v_exeption THEN
      raise_application_error(-20002, v_msg);
    WHEN OTHERS THEN
      raise_application_error(-20001, 'Income_Tax_Sum_Date_Control: ' || SQLERRM);
  END income_tax_sum_date_control;
  ----========================================================================----
  -- ��� �������� ������������ ��� ������� � �����������
  FUNCTION get_current_user_fio RETURN VARCHAR2 IS
    v_name ven_sys_user.name%TYPE;
  BEGIN
    SELECT NAME
      INTO v_name
      FROM ven_sys_user
     WHERE sys_user_name = USER
       AND rownum = 1;
    RETURN(v_name);
  EXCEPTION
    WHEN no_data_found THEN
      NULL;
    WHEN OTHERS THEN
      raise_application_error(-20001, 'Get_Current_User_FIO: ' || SQLERRM);
  END get_current_user_fio;
  ----========================================================================----
  -- ��������� �������������� ��������
  PROCEDURE gen_fix_trans(par_p_trans_decline_id NUMBER) IS
    v_oper_templ_id NUMBER;
    v_trans_sum     NUMBER;
    v_oper_id       NUMBER;
    v_ent_id        NUMBER;
    v_p_cover_id    NUMBER;
  BEGIN
    SELECT oper_templ_id
          ,trans_sum
          ,p_cover_id
      INTO v_oper_templ_id
          ,v_trans_sum
          ,v_p_cover_id
      FROM ven_p_trans_decline
     WHERE p_trans_decline_id = par_p_trans_decline_id;
    SELECT ent_id INTO v_ent_id FROM entity WHERE brief = 'P_COVER';
    v_oper_id := acc_new.run_oper_by_template(p_oper_templ_id     => v_oper_templ_id
                                             ,p_document_id       => par_p_trans_decline_id
                                             ,p_service_ent_id    => v_ent_id
                                             , -- NULL,
                                              p_service_obj_id    => v_p_cover_id
                                             , -- NULL,
                                              p_doc_status_ref_id => NULL
                                             ,p_is_accepted       => 1
                                             ,p_summ              => v_trans_sum
                                             ,p_source            => 'INS');
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001, 'Gen_Fix_Trans: ' || SQLERRM);
  END gen_fix_trans;
  ----========================================================================----
  -- �������� �������������� ��������
  PROCEDURE del_fix_trans(par_p_trans_decline_id NUMBER) IS
    CURSOR trans_curs(pcurs_p_trans_decline_id NUMBER) IS
      SELECT o.oper_id
            ,
             /*t.is_closed,*/pkg_period_closed.check_date_in_closed(t.trans_date) is_closed
            , --273031: ��������� �������� �������� ��������� ������� /������/
             t.trans_date
        FROM oper  o
            ,trans t
       WHERE o.document_id = pcurs_p_trans_decline_id
         AND t.oper_id = o.oper_id;
  BEGIN
    FOR trans_rec IN trans_curs(par_p_trans_decline_id)
    LOOP
      IF trans_rec.is_closed = 1
      THEN
        -- �������������
        acc_new.storno_trans(trans_rec.oper_id);
      ELSE
        -- ��������
        DELETE FROM oper WHERE oper_id = trans_rec.oper_id;
      END IF;
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001, 'Del_Fix_Trans: ' || SQLERRM);
  END del_fix_trans;
  ----========================================================================----
  -- ��������� ����������� ��������� �� �������������� ���������
  PROCEDURE set_analytics
  (
    par_oper_id           NUMBER
   ,par_as_asset_id       NUMBER
   ,par_t_product_line_id NUMBER
  ) IS
    CURSOR trans_curs(pcurs_oper_id NUMBER) IS
      SELECT trans_id
            ,a1_dt_ure_id
            ,a1_dt_uro_id
            ,a1_ct_ure_id
            ,a1_ct_uro_id
            ,a2_dt_ure_id
            ,a2_dt_uro_id
            ,a2_ct_ure_id
            ,a2_ct_uro_id
            ,a3_dt_ure_id
            ,a3_dt_uro_id
            ,a3_ct_ure_id
            ,a3_ct_uro_id
            ,a4_dt_ure_id
            ,a4_dt_uro_id
            ,a4_ct_ure_id
            ,a4_ct_uro_id
            ,a5_dt_ure_id
            ,a5_dt_uro_id
            ,a5_ct_ure_id
            ,a5_ct_uro_id
        FROM trans
       WHERE oper_id = pcurs_oper_id;
    v_ent_id_contact            NUMBER;
    v_ent_id_p_policy           NUMBER;
    v_ent_id_p_asset_header     NUMBER;
    v_ent_id_p_cover            NUMBER;
    v_ent_id_t_prod_line_option NUMBER;
    v_t_prod_line_option_id     NUMBER;
    v_p_cover_id                NUMBER;
    v_p_asset_header_id         NUMBER;
  BEGIN
    /*SELECT ent_id INTO v_ent_id_CONTACT FROM entity
      WHERE brief = 'CONTACT'; -- �������
    SELECT ent_id INTO v_ent_id_P_POLICY FROM entity
      WHERE brief = 'P_POLICY'; -- ������ �������� ����������� */
    SELECT ent_id INTO v_ent_id_p_asset_header FROM entity WHERE brief = 'P_ASSET_HEADER'; -- ��������� ������� �����������
    SELECT ent_id INTO v_ent_id_p_cover FROM entity WHERE brief = 'P_COVER'; -- ��������� ��������
    SELECT ent_id INTO v_ent_id_t_prod_line_option FROM entity WHERE brief = 'T_PROD_LINE_OPTION'; -- ������ ������ �� ����� ��������
    SELECT id
      INTO v_t_prod_line_option_id
      FROM t_prod_line_option plo
     WHERE plo.product_line_id = par_t_product_line_id
       AND EXISTS (SELECT '1'
              FROM p_cover c
             WHERE c.t_prod_line_option_id = plo.id
               AND c.as_asset_id = par_as_asset_id);
    SELECT p_cover_id
      INTO v_p_cover_id
      FROM p_cover
     WHERE as_asset_id = par_as_asset_id
       AND t_prod_line_option_id = v_t_prod_line_option_id;
    SELECT p_asset_header_id
      INTO v_p_asset_header_id
      FROM as_asset
     WHERE as_asset_id = par_as_asset_id;
    FOR trans_rec IN trans_curs(par_oper_id)
    LOOP
      IF trans_rec.a1_dt_ure_id = v_ent_id_t_prod_line_option
      THEN
        UPDATE trans SET a1_dt_uro_id = v_t_prod_line_option_id WHERE trans_id = trans_rec.trans_id;
      ELSIF trans_rec.a2_dt_ure_id = v_ent_id_t_prod_line_option
      THEN
        UPDATE trans SET a2_dt_uro_id = v_t_prod_line_option_id WHERE trans_id = trans_rec.trans_id;
      ELSIF trans_rec.a3_dt_ure_id = v_ent_id_t_prod_line_option
      THEN
        UPDATE trans SET a3_dt_uro_id = v_t_prod_line_option_id WHERE trans_id = trans_rec.trans_id;
      ELSIF trans_rec.a4_dt_ure_id = v_ent_id_t_prod_line_option
      THEN
        UPDATE trans SET a4_dt_uro_id = v_t_prod_line_option_id WHERE trans_id = trans_rec.trans_id;
      ELSIF trans_rec.a5_dt_ure_id = v_ent_id_t_prod_line_option
      THEN
        UPDATE trans SET a5_dt_uro_id = v_t_prod_line_option_id WHERE trans_id = trans_rec.trans_id;
      END IF;
      IF trans_rec.a1_ct_ure_id = v_ent_id_t_prod_line_option
      THEN
        UPDATE trans SET a1_ct_uro_id = v_t_prod_line_option_id WHERE trans_id = trans_rec.trans_id;
      ELSIF trans_rec.a2_ct_ure_id = v_ent_id_t_prod_line_option
      THEN
        UPDATE trans SET a2_ct_uro_id = v_t_prod_line_option_id WHERE trans_id = trans_rec.trans_id;
      ELSIF trans_rec.a3_ct_ure_id = v_ent_id_t_prod_line_option
      THEN
        UPDATE trans SET a3_ct_uro_id = v_t_prod_line_option_id WHERE trans_id = trans_rec.trans_id;
      ELSIF trans_rec.a4_ct_ure_id = v_ent_id_t_prod_line_option
      THEN
        UPDATE trans SET a4_ct_uro_id = v_t_prod_line_option_id WHERE trans_id = trans_rec.trans_id;
      ELSIF trans_rec.a5_ct_ure_id = v_ent_id_t_prod_line_option
      THEN
        UPDATE trans SET a5_ct_uro_id = v_t_prod_line_option_id WHERE trans_id = trans_rec.trans_id;
      END IF;
      --
      IF trans_rec.a1_dt_ure_id = v_ent_id_p_cover
      THEN
        UPDATE trans SET a1_dt_uro_id = v_p_cover_id WHERE trans_id = trans_rec.trans_id;
      ELSIF trans_rec.a2_dt_ure_id = v_ent_id_p_cover
      THEN
        UPDATE trans SET a2_dt_uro_id = v_p_cover_id WHERE trans_id = trans_rec.trans_id;
      ELSIF trans_rec.a3_dt_ure_id = v_ent_id_p_cover
      THEN
        UPDATE trans SET a3_dt_uro_id = v_p_cover_id WHERE trans_id = trans_rec.trans_id;
      ELSIF trans_rec.a4_dt_ure_id = v_ent_id_p_cover
      THEN
        UPDATE trans SET a4_dt_uro_id = v_p_cover_id WHERE trans_id = trans_rec.trans_id;
      ELSIF trans_rec.a5_dt_ure_id = v_ent_id_p_cover
      THEN
        UPDATE trans SET a5_dt_uro_id = v_p_cover_id WHERE trans_id = trans_rec.trans_id;
      END IF;
      IF trans_rec.a1_ct_ure_id = v_ent_id_p_cover
      THEN
        UPDATE trans SET a1_ct_uro_id = v_p_cover_id WHERE trans_id = trans_rec.trans_id;
      ELSIF trans_rec.a2_ct_ure_id = v_ent_id_p_cover
      THEN
        UPDATE trans SET a2_ct_uro_id = v_p_cover_id WHERE trans_id = trans_rec.trans_id;
      ELSIF trans_rec.a3_ct_ure_id = v_ent_id_p_cover
      THEN
        UPDATE trans SET a3_ct_uro_id = v_p_cover_id WHERE trans_id = trans_rec.trans_id;
      ELSIF trans_rec.a4_ct_ure_id = v_ent_id_p_cover
      THEN
        UPDATE trans SET a4_ct_uro_id = v_p_cover_id WHERE trans_id = trans_rec.trans_id;
      ELSIF trans_rec.a5_ct_ure_id = v_ent_id_p_cover
      THEN
        UPDATE trans SET a5_ct_uro_id = v_p_cover_id WHERE trans_id = trans_rec.trans_id;
      END IF;
      ----
      IF trans_rec.a1_dt_ure_id = v_ent_id_p_asset_header
      THEN
        UPDATE trans SET a1_dt_uro_id = v_p_asset_header_id WHERE trans_id = trans_rec.trans_id;
      ELSIF trans_rec.a2_dt_ure_id = v_ent_id_p_asset_header
      THEN
        UPDATE trans SET a2_dt_uro_id = v_p_asset_header_id WHERE trans_id = trans_rec.trans_id;
      ELSIF trans_rec.a3_dt_ure_id = v_ent_id_p_asset_header
      THEN
        UPDATE trans SET a3_dt_uro_id = v_p_asset_header_id WHERE trans_id = trans_rec.trans_id;
      ELSIF trans_rec.a4_dt_ure_id = v_ent_id_p_asset_header
      THEN
        UPDATE trans SET a4_dt_uro_id = v_p_asset_header_id WHERE trans_id = trans_rec.trans_id;
      ELSIF trans_rec.a5_dt_ure_id = v_ent_id_p_asset_header
      THEN
        UPDATE trans SET a5_dt_uro_id = v_p_asset_header_id WHERE trans_id = trans_rec.trans_id;
      END IF;
      IF trans_rec.a1_ct_ure_id = v_ent_id_p_asset_header
      THEN
        UPDATE trans SET a1_ct_uro_id = v_p_asset_header_id WHERE trans_id = trans_rec.trans_id;
      ELSIF trans_rec.a2_ct_ure_id = v_ent_id_p_asset_header
      THEN
        UPDATE trans SET a2_ct_uro_id = v_p_asset_header_id WHERE trans_id = trans_rec.trans_id;
      ELSIF trans_rec.a3_ct_ure_id = v_ent_id_p_asset_header
      THEN
        UPDATE trans SET a3_ct_uro_id = v_p_asset_header_id WHERE trans_id = trans_rec.trans_id;
      ELSIF trans_rec.a4_ct_ure_id = v_ent_id_p_asset_header
      THEN
        UPDATE trans SET a4_ct_uro_id = v_p_asset_header_id WHERE trans_id = trans_rec.trans_id;
      ELSIF trans_rec.a5_ct_ure_id = v_ent_id_p_asset_header
      THEN
        UPDATE trans SET a5_ct_uro_id = v_p_asset_header_id WHERE trans_id = trans_rec.trans_id;
      END IF;
    END LOOP;
    --EXCEPTION
    --WHEN others THEN
    --Raise_Application_Error( -20001, 'Set_Analytics: ' || SQLERRM );
  END set_analytics;
  ----========================================================================----
  -- 1) ���������� ��, ���, �������:
  -- ���������� ����� ������������ � ������������ ����� �������� �� ��������:
  -- ���������� �������� �����, ���������� ��������������� ��������������� ������,
  -- �������� ������� �� ��� ����������� ��.
  -- �������� �������: ���������� ��, ���, ������� = ((?�������� ����� + ?��� +
  -- ?������� ����� ������) �������� ����� �� ���� ������) -
  -- (�������� ���� "����") - * ������ "���������� �������� �����" -
  -- ������ "���������� ��������������� ��������������� ������" -
  -- ������ "�������� ������� �� ��� ����������� ��"
  FUNCTION get_round_1(par_p_policy_id NUMBER) RETURN NUMBER IS
    v_return                NUMBER := 0;
    v_oper_id               NUMBER;
    v_oper_templ_id         NUMBER;
    v_medo_cost             NUMBER;
    v_sum_redemption_sum    NUMBER;
    v_sum_add_invest_income NUMBER;
    v_sum_return_bonus_part NUMBER;
    v_sum                   NUMBER;
    v_sum_3                 NUMBER := 0; -- SUM( ���������� �������� ����� )
    v_sum_4                 NUMBER := 0; -- SUM( ���������� ��������������� ��������������� ������ )
    v_sum_5                 NUMBER := 0; -- SUM( �������� ������� �� ��� ����������� �� )
    CURSOR cover_curs(pcurs_p_policy_id NUMBER) IS
      SELECT cd.redemption_sum
            ,cd.add_invest_income
            ,cd.return_bonus_part
        FROM p_cover_decline cd
            ,p_pol_decline   pd
       WHERE cd.p_pol_decline_id = pd.p_pol_decline_id
         AND pd.p_policy_id = pcurs_p_policy_id;
  BEGIN
    SELECT pd.medo_cost
      INTO v_medo_cost
      FROM p_policy      p
          ,p_pol_decline pd
     WHERE p.policy_id = par_p_policy_id
       AND p.policy_id = pd.p_policy_id;
    SELECT SUM(cd.redemption_sum)
          ,SUM(cd.add_invest_income)
          ,SUM(cd.return_bonus_part)
      INTO v_sum_redemption_sum
          ,v_sum_add_invest_income
          ,v_sum_return_bonus_part
      FROM p_pol_decline   pd
          ,p_cover_decline cd
     WHERE pd.p_policy_id = par_p_policy_id
       AND pd.p_pol_decline_id = cd.p_pol_decline_id;
    IF nvl(v_sum_redemption_sum, 0) + nvl(v_sum_add_invest_income, 0) +
       nvl(v_sum_return_bonus_part, 0) != 0
    THEN
      FOR cover_rec IN cover_curs(par_p_policy_id)
      LOOP
        -- 3 *** ���������� �������� ����� 22.05.31 77.00.14
        v_sum   := nvl(cover_rec.redemption_sum, 0) -
                   (nvl(v_medo_cost, 0) * nvl(cover_rec.redemption_sum, 0) /
                    (nvl(v_sum_redemption_sum, 0) + nvl(v_sum_add_invest_income, 0) +
                     nvl(v_sum_return_bonus_part, 0)));
        v_sum_3 := v_sum_3 + nvl(ROUND(v_sum, 2), 0);
        -- 4 *** ���������� ��������������� ��������������� ������ 22.05.33 77.00.14
        v_sum   := nvl(cover_rec.add_invest_income, 0) -
                   (nvl(v_medo_cost, 0) * nvl(cover_rec.add_invest_income, 0) /
                    (nvl(v_sum_redemption_sum, 0) + nvl(v_sum_add_invest_income, 0) +
                     nvl(v_sum_return_bonus_part, 0)));
        v_sum_4 := v_sum_4 + nvl(ROUND(v_sum, 2), 0);
        -- 5 *** �������� ������� �� ��� ����������� �� 22.05.11 77.00.13
        v_sum   := nvl(cover_rec.return_bonus_part, 0) -
                   (nvl(v_medo_cost, 0) * nvl(cover_rec.return_bonus_part, 0) /
                    (nvl(v_sum_redemption_sum, 0) + nvl(v_sum_add_invest_income, 0) +
                     nvl(v_sum_return_bonus_part, 0)));
        v_sum_5 := v_sum_5 + nvl(ROUND(v_sum, 2), 0);
      END LOOP;
      v_return := (nvl(v_sum_redemption_sum, 0) + nvl(v_sum_add_invest_income, 0) +
                  nvl(v_sum_return_bonus_part, 0)) - nvl(v_medo_cost, 0) - nvl(v_sum_3, 0) -- ���������� �������� �����
                  - nvl(v_sum_4, 0) -- ���������� ���
                  - nvl(v_sum_5, 0); -- �������� ������� �� ��� ����������� ��
    END IF;
    v_return := ROUND(nvl(v_return, 0), 2);
    RETURN(v_return);
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001, 'Get_Round_1: ' || SQLERRM);
  END get_round_1;
  ----========================================================================----
  -- 2) ���������� ������ � ���� ���������:
  -- ���������� ����� ������������ � ������������ ����� �������� �� ��������:
  -- ����� �� (����� �� ����  ��), ������� ������� ��� (����� �� ����  ��),
  -- ������� ������� ���� (����� �� ����  ��).
  -- �������� �������: ���������� ������ � ���� ������� �������� = (�������� ����
  -- "��������� �� ������ ����������") - ? ������ "����� �� (����� �� ����  ��)" -
  -- ? ������ "������� ������� ��� (����� �� ����  ��)" -
  -- ? ������ "������� ������� ���� (����� �� ����  ��)"
  FUNCTION get_round_2(par_p_policy_id NUMBER) RETURN NUMBER IS
    v_return                NUMBER := 0;
    v_oper_id               NUMBER;
    v_oper_templ_id         NUMBER;
    v_debt_summ             NUMBER;
    v_sum_redemption_sum    NUMBER;
    v_sum_add_invest_income NUMBER;
    v_sum_return_bonus_part NUMBER;
    v_sum                   NUMBER;
    v_sum_6                 NUMBER := 0; -- SUM( ����� �� )
    v_sum_7                 NUMBER := 0; -- SUM( ������� ������� ��� )
    v_sum_8                 NUMBER := 0; -- SUM( ������� ������� ���� )
    CURSOR cover_curs(pcurs_p_policy_id NUMBER) IS
      SELECT cd.redemption_sum
            ,cd.add_invest_income
            ,cd.return_bonus_part
        FROM p_cover_decline cd
            ,p_pol_decline   pd
       WHERE cd.p_pol_decline_id = pd.p_pol_decline_id
         AND pd.p_policy_id = pcurs_p_policy_id;
  BEGIN
    SELECT p.debt_summ
      INTO v_debt_summ
      FROM p_policy      p
          ,p_pol_decline pd
     WHERE p.policy_id = par_p_policy_id
       AND p.policy_id = pd.p_policy_id;
    SELECT SUM(cd.redemption_sum)
          ,SUM(cd.add_invest_income)
          ,SUM(cd.return_bonus_part)
      INTO v_sum_redemption_sum
          ,v_sum_add_invest_income
          ,v_sum_return_bonus_part
      FROM p_pol_decline   pd
          ,p_cover_decline cd
     WHERE pd.p_policy_id = par_p_policy_id
       AND pd.p_pol_decline_id = cd.p_pol_decline_id;
    IF nvl(v_sum_redemption_sum, 0) + nvl(v_sum_add_invest_income, 0) +
       nvl(v_sum_return_bonus_part, 0) != 0
    THEN
      FOR cover_rec IN cover_curs(par_p_policy_id)
      LOOP
        -- 6 *** ����� �� 77.00.14 77.01.03
        v_sum   := (nvl(v_debt_summ, 0) * nvl(cover_rec.redemption_sum, 0) /
                   (nvl(v_sum_redemption_sum, 0) + nvl(v_sum_add_invest_income, 0) +
                   nvl(v_sum_return_bonus_part, 0)));
        v_sum_6 := v_sum_6 + nvl(ROUND(v_sum, 2), 0);
        -- 7 *** ������� ������� ��� 77.00.14 77.01.03
        v_sum   := (nvl(v_debt_summ, 0) * nvl(cover_rec.add_invest_income, 0) /
                   (nvl(v_sum_redemption_sum, 0) + nvl(v_sum_add_invest_income, 0) +
                   nvl(v_sum_return_bonus_part, 0)));
        v_sum_7 := v_sum_7 + nvl(ROUND(v_sum, 2), 0);
        -- 8 *** ������� ������� ���� 77.00.13 77.01.03
        v_sum   := (nvl(v_debt_summ, 0) * nvl(cover_rec.return_bonus_part, 0) /
                   (nvl(v_sum_redemption_sum, 0) + nvl(v_sum_add_invest_income, 0) +
                   nvl(v_sum_return_bonus_part, 0)));
        v_sum_8 := v_sum_8 + nvl(ROUND(v_sum, 2), 0);
      END LOOP;
    ELSE
      v_sum_6 := 0;
      v_sum_7 := 0;
      v_sum_8 := 0;
    END IF;
    v_return := nvl(v_debt_summ, 0) -- ��������� �� ������ ����������
                - nvl(v_sum_6, 0) -- ����� ��
                - nvl(v_sum_7, 0) -- ������� ������� ���
                - nvl(v_sum_8, 0); -- ������� ������� ����
    v_return := ROUND(nvl(v_return, 0), 2);
    RETURN(v_return);
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001, 'Get_Round_2: ' || SQLERRM);
  END get_round_2;
  ----========================================================================----
  -- 3) ���������� ������ �� ����� �������:
  -- ���������� ����� ������������ � ������������ ����� �������� �� ��������:
  -- ����� �� (����� �� ������  ��), ������� ������� ��� (����� �� ������  ��),
  -- ������� ������� ���� (����� �� ������  ��).
  -- �������� �������: ���������� ������ � ���� ������� �������� =
  -- (�������� ���� "����� ������ �� ������ �������") -
  -- ? ������ "����� �� (����� �� ������  ��)" -
  -- ? ������ "������� ������� ��� (����� �� ������  ��)" -
  -- ? ������ "������� ������� ���� (����� �� ������  ��)"
  PROCEDURE get_round_3
  (
    par_p_policy_id  IN NUMBER
   ,par_round_err    OUT NUMBER
   , -- ������ ����������
    par_template_num OUT NUMBER -- ����� ������� ��������, � ����� �������
    -- ������ ������ ���������� (9, 10 ��� 11)
  ) IS
    v_other_pol_sum         NUMBER;
    v_oper_id               NUMBER;
    v_ent_id                NUMBER;
    v_oper_templ_id         NUMBER;
    v_medo_cost             NUMBER;
    v_sum_redemption_sum    NUMBER;
    v_sum_add_invest_income NUMBER;
    v_sum_return_bonus_part NUMBER;
    v_sum                   NUMBER;
    v_sum_3                 NUMBER := 0; -- SUM( ���������� �������� ����� )
    v_sum_4                 NUMBER := 0; -- SUM( ���������� ��������������� ��������������� ������ )
    v_sum_5                 NUMBER := 0; -- SUM( �������� ������� �� ��� ����������� �� )
    v_sum_9                 NUMBER := 0; -- ����� �� (����� �� ������ ��)
    v_sum_10                NUMBER := 0; -- ������� ������� ��� (����� �� ������ ��)
    v_sum_11                NUMBER := 0; -- ������� ������� ���� (����� �� ������ ��)
    v_continue              BOOLEAN := TRUE;
    --
    v_round_err    NUMBER;
    v_max_sum      NUMBER := 0; -- ������������ ����� �� ���������
    v_template_num NUMBER;
    --
    CURSOR cover_curs(pcurs_p_policy_id NUMBER) IS
      SELECT cd.as_asset_id
            ,cd.t_product_line_id
            ,cd.cover_period
            ,cd.redemption_sum
            ,cd.add_invest_income
            ,cd.return_bonus_part
            ,cd.bonus_off_prev
            ,cd.bonus_off_current
            ,cd.admin_expenses
        FROM p_cover_decline cd
            ,p_pol_decline   pd
       WHERE cd.p_pol_decline_id = pd.p_pol_decline_id
         AND pd.p_policy_id = pcurs_p_policy_id;
  BEGIN
    BEGIN
      SELECT pd.other_pol_sum
            ,pd.medo_cost
        INTO v_other_pol_sum
            ,v_medo_cost
        FROM p_pol_decline pd
       WHERE pd.p_policy_id = par_p_policy_id;
    EXCEPTION
      WHEN OTHERS THEN
        v_other_pol_sum := NULL;
        v_continue      := FALSE;
    END;
    IF nvl(v_other_pol_sum, 0) = 0
    THEN
      v_continue := FALSE;
    END IF;
    IF v_continue
    THEN
      BEGIN
        -- ������ �� �������������� � ����������
        SELECT SUM(cd.redemption_sum)
              ,SUM(cd.add_invest_income)
              ,SUM(cd.return_bonus_part)
          INTO v_sum_redemption_sum
              ,v_sum_add_invest_income
              ,v_sum_return_bonus_part
          FROM p_pol_decline   pd
              ,p_cover_decline cd
         WHERE pd.p_policy_id = par_p_policy_id
           AND pd.p_pol_decline_id = cd.p_pol_decline_id;
        IF nvl(v_sum_redemption_sum, 0) + nvl(v_sum_add_invest_income, 0) +
           nvl(v_sum_return_bonus_part, 0) = 0
        THEN
          v_continue := FALSE;
        END IF;
        IF nvl(v_sum_redemption_sum, 0) + nvl(v_sum_add_invest_income, 0) +
           nvl(v_sum_return_bonus_part, 0) - nvl(v_medo_cost, 0) = 0
        THEN
          v_continue := FALSE;
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          v_continue := FALSE;
      END;
    END IF;
    IF v_continue
    THEN
      BEGIN
        IF nvl(v_sum_redemption_sum, 0) + nvl(v_sum_add_invest_income, 0) +
           nvl(v_sum_return_bonus_part, 0) != 0
        THEN
          FOR cover_rec IN cover_curs(par_p_policy_id)
          LOOP
            -- 3 *** ���������� �������� ����� 22.05.31 77.00.14
            v_sum   := nvl(cover_rec.redemption_sum, 0) -
                       (nvl(v_medo_cost, 0) * nvl(cover_rec.redemption_sum, 0) /
                        (nvl(v_sum_redemption_sum, 0) + nvl(v_sum_add_invest_income, 0) +
                         nvl(v_sum_return_bonus_part, 0)));
            v_sum_3 := v_sum_3 + nvl(ROUND(v_sum, 2), 0);
            -- 4 *** ���������� ��������������� ��������������� ������ 22.05.33 77.00.14
            v_sum   := nvl(cover_rec.add_invest_income, 0) -
                       (nvl(v_medo_cost, 0) * nvl(cover_rec.add_invest_income, 0) /
                        (nvl(v_sum_redemption_sum, 0) + nvl(v_sum_add_invest_income, 0) +
                         nvl(v_sum_return_bonus_part, 0)));
            v_sum_4 := v_sum_4 + nvl(ROUND(v_sum, 2), 0);
            -- 5 *** �������� ������� �� ��� ����������� �� 22.05.11 77.00.13
            v_sum   := nvl(cover_rec.return_bonus_part, 0) -
                       (nvl(v_medo_cost, 0) * nvl(cover_rec.return_bonus_part, 0) /
                        (nvl(v_sum_redemption_sum, 0) + nvl(v_sum_add_invest_income, 0) +
                         nvl(v_sum_return_bonus_part, 0)));
            v_sum_5 := v_sum_5 + nvl(ROUND(v_sum, 2), 0);
          END LOOP;
        ELSE
          v_sum_3 := 0;
          v_sum_4 := 0;
          v_sum_5 := 0;
        END IF;
        -- 9 *** ����� �� (����� �� ������ ��) 77.00.14 77.08.03
        v_sum := nvl(v_other_pol_sum, 0) * v_sum_3 /
                 (nvl(v_sum_redemption_sum, 0) + nvl(v_sum_add_invest_income, 0) +
                  nvl(v_sum_return_bonus_part, 0) - nvl(v_medo_cost, 0));
        v_sum := ROUND(nvl(v_sum, 0), 2);
        IF v_sum != 0
        THEN
          IF v_sum > v_max_sum
          THEN
            v_max_sum      := v_sum;
            v_template_num := 9;
          END IF;
          v_sum_9 := v_sum;
        END IF;
        -- 10 *** ������� ������� ��� (����� �� ������ ��) 77.00.14 77.08.03
        v_sum := nvl(v_other_pol_sum, 0) * v_sum_4 /
                 (nvl(v_sum_redemption_sum, 0) + nvl(v_sum_add_invest_income, 0) +
                  nvl(v_sum_return_bonus_part, 0) - nvl(v_medo_cost, 0));
        v_sum := ROUND(nvl(v_sum, 0), 2);
        IF v_sum != 0
        THEN
          IF v_sum > v_max_sum
          THEN
            v_max_sum      := v_sum;
            v_template_num := 10;
          END IF;
          v_sum_10 := v_sum;
        END IF;
        -- 11 *** ������� ������� ���� (����� �� ������ ��) 77.00.13 77.08.03
        v_sum := nvl(v_other_pol_sum, 0) * v_sum_5 /
                 (nvl(v_sum_redemption_sum, 0) + nvl(v_sum_add_invest_income, 0) +
                  nvl(v_sum_return_bonus_part, 0) - nvl(v_medo_cost, 0));
        v_sum := ROUND(nvl(v_sum, 0), 2);
        IF v_sum != 0
        THEN
          IF v_sum > v_max_sum
          THEN
            v_max_sum      := v_sum;
            v_template_num := 11;
          END IF;
          v_sum_11 := v_sum;
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          v_continue := FALSE;
      END;
    END IF;

    IF v_continue
    THEN
      -- ������ ������ ����������
      v_round_err      := nvl(v_other_pol_sum, 0) -- ����� ������ �� ������ �������
                          - nvl(v_sum_9, 0) -- ����� �� (����� �� ������ ��)
                          - nvl(v_sum_10, 0) -- ������� ������� ��� (����� �� ������ ��)
                          - nvl(v_sum_11, 0); -- ������� ������� ���� (����� �� ������ ��)
      par_round_err    := v_round_err;
      par_template_num := v_template_num;
    ELSE
      par_round_err    := 0;
      par_template_num := NULL;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001, 'Get_Round_3: ' || SQLERRM);
  END get_round_3;
  ----========================================================================----
  -- 4) ���������� ��������� �� ��������:
  -- ���������� ����� ������������ � ������������ ����� �������� �� �������:
  -- ��������� �� ��������.
  -- �������� �������: ���������� ��������� �� �������� =
  -- (�������� ���� "��������� �� ������ ����������") -
  -- ? ������ "��������� �� ��������"
  FUNCTION get_round_4(par_p_policy_id NUMBER) RETURN NUMBER IS
    v_return                NUMBER := 0;
    v_oper_id               NUMBER;
    v_oper_templ_id         NUMBER;
    v_overpayment           NUMBER;
    v_sum_redemption_sum    NUMBER;
    v_sum_add_invest_income NUMBER;
    v_sum_return_bonus_part NUMBER;
    v_sum                   NUMBER;
    v_sum_17                NUMBER := 0; -- SUM( ��������� �� �������� )
    CURSOR cover_curs(pcurs_p_policy_id NUMBER) IS
      SELECT cd.redemption_sum
            ,cd.add_invest_income
            ,cd.return_bonus_part
            ,cd.bonus_off_prev
            ,cd.bonus_off_current
            ,cd.admin_expenses
             -- ������ �.
             -- �������� ������� ������-������ �� ����� ����� ������-�������
            ,pc.fee / SUM(pc.fee) over() AS fee_coeff
        FROM p_cover_decline cd
            ,p_pol_decline   pd
             --
            ,p_cover            pc
            ,t_prod_line_option plo
       WHERE cd.p_pol_decline_id = pd.p_pol_decline_id
         AND pd.p_policy_id = pcurs_p_policy_id
            --
         AND pc.as_asset_id = cd.as_asset_id
         AND pc.t_prod_line_option_id = plo.id
         AND plo.product_line_id = cd.t_product_line_id;
  BEGIN
    SELECT pd.overpayment
      INTO v_overpayment
      FROM p_policy      p
          ,p_pol_decline pd
     WHERE p.policy_id = par_p_policy_id
       AND p.policy_id = pd.p_policy_id;
    SELECT SUM(cd.redemption_sum)
          ,SUM(cd.add_invest_income)
          ,SUM(cd.return_bonus_part)
      INTO v_sum_redemption_sum
          ,v_sum_add_invest_income
          ,v_sum_return_bonus_part
      FROM p_pol_decline   pd
          ,p_cover_decline cd
     WHERE pd.p_policy_id = par_p_policy_id
       AND pd.p_pol_decline_id = cd.p_pol_decline_id;
    -- ������ �.
    -- ������� �������� ��������� ����� ����������
    IF v_overpayment != 0
    THEN

      /*IF NVL( v_sum_redemption_sum, 0 ) + NVL( v_sum_add_invest_income, 0 ) +
      NVL( v_sum_return_bonus_part, 0 ) != 0 THEN*/
      FOR cover_rec IN cover_curs(par_p_policy_id)
      LOOP
        -- 17 *** ��������� �� �������� 77.01.03 77.00.13
        /*v_sum := ( NVL( v_overpayment, 0 ) / ( NVL( v_sum_redemption_sum, 0 ) +
          NVL( v_sum_add_invest_income, 0 ) +  NVL( v_sum_return_bonus_part, 0 ) ) )
          * ( NVL( cover_rec.redemption_sum, 0 ) +
              NVL( cover_rec.add_invest_income, 0 ) +
              NVL( cover_rec.return_bonus_part, 0 ) );
        v_sum_17 := v_sum_17 + ROUND( NVL( v_sum, 0 ), 2 );*/
        v_sum_17 := v_sum_17 + ROUND(v_overpayment * cover_rec.fee_coeff, 2);
      END LOOP;
      v_return := nvl(v_overpayment, 0) -- ��������� �� ������ ����������
                  - nvl(v_sum_17, 0); -- ��������� �� ��������
    END IF;
    v_return := ROUND(nvl(v_return, 0), 2);
    RETURN(v_return);
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001, 'Get_Round_4: ' || SQLERRM);
  END get_round_4;
  ----========================================================================----
  -- ������� ����������� �� - � ������ "�������������"
  -- 1 - � ������, 0 - ���
  FUNCTION decline_reason_is_annul(par_p_policy_id NUMBER) RETURN NUMBER IS
    v_return NUMBER(1);
    v_dummy  CHAR(1);
  BEGIN
    BEGIN
      SELECT '1'
        INTO v_dummy
        FROM p_policy         p
            ,t_decline_reason r
       WHERE p.policy_id = par_p_policy_id
         AND p.decline_reason_id = r.t_decline_reason_id
         AND r.t_decline_type_id =
             (SELECT t_decline_type_id FROM t_decline_type WHERE brief = '�������������');
      v_return := 1;
    EXCEPTION
      WHEN no_data_found THEN
        v_return := 0;
    END;
    RETURN(v_return);
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001, '������ Decline_Reason_Is_Annul: ' || SQLERRM);
  END decline_reason_is_annul;
  ----========================================================================----
  -- ��������: ���� ������� ����������� �� �� ������ "�������������", ��
  -- ������ ���� ����� ����:
  -- �������� �����
  -- ���. ������ �����
  -- �����. �������
  -- ��������� �����������
  -- ��������� �����������
  -- ���������
  -- (����� �� �������������� ������ ��������)
  PROCEDURE check_annul(par_p_policy NUMBER) IS
    v_dummy CHAR(1);
    v_raise BOOLEAN := FALSE;
  BEGIN
    IF decline_reason_is_annul(par_p_policy) = 1
    THEN
      BEGIN
        SELECT '1'
          INTO v_dummy
          FROM p_policy        p
              ,p_pol_decline   pd
              ,p_cover_decline cd
         WHERE p.policy_id = par_p_policy
           AND p.policy_id = pd.p_policy_id
           AND pd.p_pol_decline_id = cd.p_pol_decline_id
           AND (nvl(cd.redemption_sum, 0) != 0 OR nvl(cd.add_invest_income, 0) != 0 OR
               nvl(cd.admin_expenses, 0) != 0 OR nvl(p.debt_summ, 0) != 0 OR
               nvl(pd.debt_fee_fact, 0) != 0 OR nvl(pd.overpayment, 0) != 0);
        v_raise := TRUE;
      EXCEPTION
        WHEN too_many_rows THEN
          v_raise := TRUE;
        WHEN no_data_found THEN
          v_raise := FALSE;
      END;
      IF v_raise
      THEN
        RAISE e_annul_check_failure;
      END IF;
    END IF;
  END check_annul;
  ----========================================================================----
  -- ��������� ������ ������ �������� �������� �� ����������� �� - �� ���� ����
  PROCEDURE gen_main_trans_group_1(par_p_policy_id NUMBER) IS
    -- p_cover_decline:
    -- p_pol_decline_id - �� ������� �������� "������ �� ����������� ������ ��"';
    -- as_asset_id - �� ������� �������� "������ �����������"
    -- t_product_line_id - �� ������� �������� "����� ���������� ��������"
    -- cover_period - ���� �����������
    -- redemption_sum - �������� �����
    -- add_invest_income - ���. ������ �����
    -- return_bonus_part - ������� ����� ������
    -- bonus_off_prev - ����������� ������ � �������� ������� ���
    -- bonus_off_current - ����������� ������ � �������� ����� ����
    -- admin_expenses - ���������������� ��������
    CURSOR cover_curs(pcurs_p_policy_id NUMBER) IS
      SELECT cd.as_asset_id
            ,cd.t_product_line_id
            ,cd.cover_period
            ,cd.redemption_sum
            ,cd.add_invest_income
            ,cd.return_bonus_part
            ,cd.bonus_off_prev
            ,cd.bonus_off_current
            ,cd.admin_expenses
             -- ������ �.
             -- �������� ������� ������-������ �� ����� ����� ������-�������
            ,pc.fee / SUM(pc.fee) over() AS fee_coeff
        FROM p_cover_decline cd
            ,p_pol_decline   pd
             --
            ,p_cover            pc
            ,t_prod_line_option plo
       WHERE cd.p_pol_decline_id = pd.p_pol_decline_id
         AND pd.p_policy_id = pcurs_p_policy_id
            --
         AND pc.as_asset_id = cd.as_asset_id
         AND pc.t_prod_line_option_id = plo.id
         AND plo.product_line_id = cd.t_product_line_id;
    v_oper_templ_id NUMBER;
    v_ent_id        NUMBER;
    v_oper_id       NUMBER;
    v_medo_cost     NUMBER;
    v_debt_summ     NUMBER;
    --  v_income_tax_sum        NUMBER;
    v_overpayment NUMBER;
    v_act_date    DATE;
    --
    v_sum_redemption_sum    NUMBER;
    v_sum_add_invest_income NUMBER;
    v_sum_return_bonus_part NUMBER;
    v_sum                   NUMBER;
    v_sum_3                 NUMBER := 0; -- SUM( ���������� �������� ����� )
    v_sum_4                 NUMBER := 0; -- SUM( ���������� ��������������� ��������������� ������ )
    v_sum_5                 NUMBER := 0; -- SUM( �������� ������� �� ��� ����������� �� )
    v_sum_6                 NUMBER := 0; -- SUM( ����� �� )
    v_sum_7                 NUMBER := 0; -- SUM( ������� ������� ��� )
    v_sum_8                 NUMBER := 0; -- SUM( ������� ������� ���� )
    v_sum_16                NUMBER := 0; -- SUM( ��������� ��� �������� �� ��������� ������ )
    v_sum_17                NUMBER := 0; -- SUM( ��������� �� �������� )
    --
    v_max_sum         NUMBER := 0; -- ������������ ����� �� 3, 4, 5 ���������
    v_max_sum_oper_id NUMBER; -- �� ��������, ��������������� ������������ �����
    -- �� 3, 4, 5 ���������
    v_max_sum_2         NUMBER := 0; -- ������������ ����� �� 6, 7, 8 ���������
    v_max_sum_oper_id_2 NUMBER; -- �� ��������, ��������������� ������������ �����
    -- �� 6, 7, 8 ���������
    v_max_sum_17         NUMBER := 0; -- ������������ ����� �� 17 ��������
    v_max_sum_oper_id_17 NUMBER; -- �� ��������, ��������������� ������������ �����
    -- �� 17 ��������
    v_round_err_1       NUMBER; -- ������ ���������� �� 3, 4, 5 ���������
    v_round_err_2       NUMBER; -- ������ ���������� �� 6, 7, 8 ���������
    v_round_err_3       NUMBER; -- ������ ���������� �� 9, 10, 11 ���������
    v_round_err         NUMBER; -- ������ ����������
    v_overpayment_round NUMBER; -- ������ ���������� �� ���������
    --
    v_template_num NUMBER; -- ����� ������� (3, 4 ��� 5) ��������,
    -- �� ������� ������� ������ ������ ����������
    v_template_num_2 NUMBER; -- ����� ������� (6, 7 ��� 8) ��������,
    -- �� ������� ������� ������ ������ ����������
    v_template_num_3 NUMBER; -- ����� ������� (9, 10 ��� 11) ��������,
    -- �� ������� ������� ������ ������ ����������
    --
    v_oper_id_13 NUMBER; -- ������������� �������� �� 13-�� ��������
    v_oper_id_14 NUMBER; -- ������������� �������� �� 14-�� ��������
    --
    v_sum_9         NUMBER := 0; -- ����� �� (����� �� ������ ��)
    v_sum_10        NUMBER := 0; -- ������� ������� ��� (����� �� ������ ��)
    v_sum_11        NUMBER := 0; -- ������� ������� ���� (����� �� ������ ��)
    v_other_pol_sum NUMBER;
    --
    v_templ_name VARCHAR2(30); -- ��� ������ ������� 5-�� ��������
    --------------------------------------------------------------------------------
    FUNCTION get_p_cover_id
    (
      par_asset_id        NUMBER
     ,par_product_line_id NUMBER
    ) RETURN NUMBER IS
      v_return NUMBER;
    BEGIN
      SELECT pc.p_cover_id
        INTO v_return
        FROM p_cover            pc
            ,t_prod_line_option plo
       WHERE pc.as_asset_id = par_asset_id
         AND pc.t_prod_line_option_id = plo.id
         AND plo.product_line_id = par_product_line_id
         AND rownum = 1;
      RETURN(v_return);
    EXCEPTION
      WHEN OTHERS THEN
        RETURN(NULL);
    END get_p_cover_id;
    --------------------------------------------------------------------------------
    PROCEDURE run_template
    (
      par_oper_templ_brief VARCHAR2
     ,par_p_cover          NUMBER
    ) IS
      v_p_service_ent_id NUMBER;
      v_p_service_obj_id NUMBER;
    BEGIN
      SELECT oper_templ_id INTO v_oper_templ_id FROM oper_templ WHERE brief = par_oper_templ_brief;
      IF par_p_cover IS NULL
      THEN
        v_p_service_ent_id := v_ent_id;
        v_p_service_obj_id := par_p_policy_id;
      ELSE
        SELECT ent_id INTO v_p_service_ent_id FROM entity WHERE brief = 'P_COVER';
        v_p_service_obj_id := par_p_cover;
      END IF;
      v_oper_id := acc_new.run_oper_by_template(p_oper_templ_id     => v_oper_templ_id
                                               ,p_document_id       => par_p_policy_id
                                               ,p_service_ent_id    => v_p_service_ent_id
                                               ,p_service_obj_id    => v_p_service_obj_id
                                               ,p_doc_status_ref_id => NULL
                                               ,p_is_accepted       => 1
                                               ,p_summ              => v_sum
                                               ,p_source            => 'INS');
      --EXCEPTION
      --WHEN others THEN
      --Raise_Application_Error( -20001, 'Run_Template: ' || SQLERRM );
    END run_template;
    --------------------------------------------------------------------------------
  BEGIN
    check_annul(par_p_policy_id);
    SELECT p.ent_id
          ,pd.medo_cost
          ,p.debt_summ
          , --pd.income_tax_sum,
           pd.overpayment
          ,pd.other_pol_sum
          ,pd.act_date
      INTO v_ent_id
          ,v_medo_cost
          ,v_debt_summ
          , --v_income_tax_sum,
           v_overpayment
          ,v_other_pol_sum
          ,v_act_date
      FROM ven_p_policy  p
          ,p_pol_decline pd
     WHERE p.policy_id = par_p_policy_id
       AND p.policy_id = pd.p_policy_id;
    SELECT SUM(cd.redemption_sum)
          ,SUM(cd.add_invest_income)
          ,SUM(cd.return_bonus_part)
      INTO v_sum_redemption_sum
          ,v_sum_add_invest_income
          ,v_sum_return_bonus_part
      FROM p_pol_decline   pd
          ,p_cover_decline cd
     WHERE pd.p_policy_id = par_p_policy_id
       AND pd.p_pol_decline_id = cd.p_pol_decline_id;
    FOR cover_rec IN cover_curs(par_p_policy_id)
    LOOP
      -- 1 *** ������������� ����������� ������ � �������� ������� ��� 91.02 77.01.01
      v_sum := ROUND(cover_rec.bonus_off_prev, 2);
      IF nvl(v_sum, 0) != 0
      THEN
        run_template('QUIT_MAIN_1'
                    ,get_p_cover_id(cover_rec.as_asset_id, cover_rec.t_product_line_id));
        set_analytics(v_oper_id, cover_rec.as_asset_id, cover_rec.t_product_line_id);
      END IF;
      -- 2 *** ������ ����������� ������ � �������� �������� ���� 77.01.01 92.01
      v_sum := ROUND(-cover_rec.bonus_off_current, 2); -- � �������
      IF nvl(v_sum, 0) != 0
      THEN
        run_template('QUIT_MAIN_2'
                    ,get_p_cover_id(cover_rec.as_asset_id, cover_rec.t_product_line_id));
        set_analytics(v_oper_id, cover_rec.as_asset_id, cover_rec.t_product_line_id);
      END IF;
      -- 3 *** ���������� �������� ����� 22.05.31 77.00.14
      IF nvl(v_sum_redemption_sum, 0) + nvl(v_sum_add_invest_income, 0) +
         nvl(v_sum_return_bonus_part, 0) != 0
      THEN
        v_sum := nvl(cover_rec.redemption_sum, 0) -
                 (nvl(v_medo_cost, 0) * nvl(cover_rec.redemption_sum, 0) /
                  (nvl(v_sum_redemption_sum, 0) + nvl(v_sum_add_invest_income, 0) +
                   nvl(v_sum_return_bonus_part, 0)));
        v_sum := ROUND(nvl(v_sum, 0), 2);
        IF v_sum != 0
        THEN
          v_sum_3 := v_sum_3 + v_sum;
          run_template('QUIT_MAIN_3'
                      ,get_p_cover_id(cover_rec.as_asset_id, cover_rec.t_product_line_id));
          set_analytics(v_oper_id, cover_rec.as_asset_id, cover_rec.t_product_line_id);
          IF v_sum > v_max_sum
          THEN
            v_max_sum         := v_sum;
            v_max_sum_oper_id := v_oper_id;
            v_template_num    := 3;
          END IF;
        END IF;
      END IF;
      -- 4 *** ���������� ��������������� ��������������� ������ 22.05.33 77.00.14
      IF nvl(v_sum_redemption_sum, 0) + nvl(v_sum_add_invest_income, 0) +
         nvl(v_sum_return_bonus_part, 0) != 0
      THEN
        v_sum := nvl(cover_rec.add_invest_income, 0) -
                 (nvl(v_medo_cost, 0) * nvl(cover_rec.add_invest_income, 0) /
                  (nvl(v_sum_redemption_sum, 0) + nvl(v_sum_add_invest_income, 0) +
                   nvl(v_sum_return_bonus_part, 0)));
        v_sum := ROUND(nvl(v_sum, 0), 2);
        IF v_sum != 0
        THEN
          v_sum_4 := v_sum_4 + v_sum;
          run_template('QUIT_MAIN_4'
                      ,get_p_cover_id(cover_rec.as_asset_id, cover_rec.t_product_line_id));
          set_analytics(v_oper_id, cover_rec.as_asset_id, cover_rec.t_product_line_id);
          IF v_sum > v_max_sum
          THEN
            v_max_sum         := v_sum;
            v_max_sum_oper_id := v_oper_id;
            v_template_num    := 4;
          END IF;
        END IF;
      END IF;
      -- 5 *** �������� ������� �� ��� ����������� �� 22.05.11 77.00.13
      IF nvl(v_sum_redemption_sum, 0) + nvl(v_sum_add_invest_income, 0) +
         nvl(v_sum_return_bonus_part, 0) != 0
      THEN
        v_sum := nvl(cover_rec.return_bonus_part, 0) -
                 (nvl(v_medo_cost, 0) * nvl(cover_rec.return_bonus_part, 0) /
                  (nvl(v_sum_redemption_sum, 0) + nvl(v_sum_add_invest_income, 0) +
                   nvl(v_sum_return_bonus_part, 0)));
        v_sum := ROUND(nvl(v_sum, 0), 2);
        IF v_sum != 0
        THEN
          v_sum_5 := v_sum_5 + v_sum;
          -- ���� ������� ����������� �� �� ������ "�������������", �� ��� ����
          -- �������� ���������� ����������� ������
          IF decline_reason_is_annul(par_p_policy_id) = 1
             AND nvl(v_act_date, to_date('01.01.1900', 'DD.MM.YYYY')) >=
             to_date('01.01.2011', 'DD.MM.YYYY')
          THEN
            v_templ_name := 'QUIT_MAIN_5_ANNUL';
          ELSE
            v_templ_name := 'QUIT_MAIN_5';
          END IF;
          run_template(v_templ_name
                      ,get_p_cover_id(cover_rec.as_asset_id, cover_rec.t_product_line_id));
          set_analytics(v_oper_id, cover_rec.as_asset_id, cover_rec.t_product_line_id);
          IF v_sum > v_max_sum
          THEN
            v_max_sum         := v_sum;
            v_max_sum_oper_id := v_oper_id;
            v_template_num    := 5;
          END IF;
        END IF;
      END IF;
      -- 6 *** ����� �� 77.00.14 77.01.03
      IF nvl(v_sum_redemption_sum, 0) + nvl(v_sum_add_invest_income, 0) +
         nvl(v_sum_return_bonus_part, 0) != 0
      THEN
        v_sum := (nvl(v_debt_summ, 0) * nvl(cover_rec.redemption_sum, 0) /
                 (nvl(v_sum_redemption_sum, 0) + nvl(v_sum_add_invest_income, 0) +
                 nvl(v_sum_return_bonus_part, 0)));
        v_sum := ROUND(nvl(v_sum, 0), 2);
        IF v_sum != 0
        THEN
          v_sum_6 := v_sum_6 + v_sum;
          run_template('QUIT_MAIN_6'
                      ,get_p_cover_id(cover_rec.as_asset_id, cover_rec.t_product_line_id));
          set_analytics(v_oper_id, cover_rec.as_asset_id, cover_rec.t_product_line_id);
          IF v_sum > v_max_sum_2
          THEN
            v_max_sum_2         := v_sum;
            v_max_sum_oper_id_2 := v_oper_id;
            v_template_num_2    := 6;
          END IF;
        END IF;
      END IF;
      -- 7 *** ������� ������� ��� 77.00.14 77.01.03
      IF nvl(v_sum_redemption_sum, 0) + nvl(v_sum_add_invest_income, 0) +
         nvl(v_sum_return_bonus_part, 0) != 0
      THEN
        v_sum := (nvl(v_debt_summ, 0) * nvl(cover_rec.add_invest_income, 0) /
                 (nvl(v_sum_redemption_sum, 0) + nvl(v_sum_add_invest_income, 0) +
                 nvl(v_sum_return_bonus_part, 0)));
        v_sum := ROUND(nvl(v_sum, 0), 2);
        IF v_sum != 0
        THEN
          v_sum_7 := v_sum_7 + v_sum;
          run_template('QUIT_MAIN_7'
                      ,get_p_cover_id(cover_rec.as_asset_id, cover_rec.t_product_line_id));
          set_analytics(v_oper_id, cover_rec.as_asset_id, cover_rec.t_product_line_id);
          IF v_sum > v_max_sum_2
          THEN
            v_max_sum_2         := v_sum;
            v_max_sum_oper_id_2 := v_oper_id;
            v_template_num_2    := 7;
          END IF;
        END IF;
      END IF;
      -- 8 *** ������� ������� ���� 77.00.13 77.01.03
      IF nvl(v_sum_redemption_sum, 0) + nvl(v_sum_add_invest_income, 0) +
         nvl(v_sum_return_bonus_part, 0) != 0
      THEN
        v_sum := (nvl(v_debt_summ, 0) * nvl(cover_rec.return_bonus_part, 0) /
                 (nvl(v_sum_redemption_sum, 0) + nvl(v_sum_add_invest_income, 0) +
                 nvl(v_sum_return_bonus_part, 0)));
        v_sum := ROUND(nvl(v_sum, 0), 2);
        IF v_sum != 0
        THEN
          v_sum_8 := v_sum_8 + v_sum;
          run_template('QUIT_MAIN_8'
                      ,get_p_cover_id(cover_rec.as_asset_id, cover_rec.t_product_line_id));
          set_analytics(v_oper_id, cover_rec.as_asset_id, cover_rec.t_product_line_id);
          IF v_sum > v_max_sum_2
          THEN
            v_max_sum_2         := v_sum;
            v_max_sum_oper_id_2 := v_oper_id;
            v_template_num_2    := 8;
          END IF;
        END IF;
      END IF;
      -- 16 *** ��������� ��� ���� �� ��������� ������ 22.05.11 77.00.13
      v_sum := ROUND(-cover_rec.admin_expenses, 2); -- � �������!
      IF nvl(v_sum, 0) != 0
      THEN
        v_sum_16 := v_sum_16 + v_sum;
        run_template('QUIT_MAIN_16'
                    ,get_p_cover_id(cover_rec.as_asset_id, cover_rec.t_product_line_id));
        set_analytics(v_oper_id, cover_rec.as_asset_id, cover_rec.t_product_line_id);
      END IF;
      -- 17 *** ��������� �� �������� 77.01.03 77.00.13
      -- ������ �.
      -- ������� ��������. ������ ����� ��������� ���������� ��������������� ������-������
      IF v_overpayment != 0
      THEN
        v_sum := ROUND(v_overpayment * cover_rec.fee_coeff, 2);
        run_template('QUIT_MAIN_17'
                    ,get_p_cover_id(cover_rec.as_asset_id, cover_rec.t_product_line_id));
        set_analytics(v_oper_id, cover_rec.as_asset_id, cover_rec.t_product_line_id);
        v_sum_17 := v_sum_17 + v_sum;
        IF v_sum > v_max_sum_17
        THEN
          v_max_sum_17         := v_sum;
          v_max_sum_oper_id_17 := v_oper_id;
        END IF;
      END IF;
      /*IF NVL( v_sum_redemption_sum, 0 ) + NVL( v_sum_add_invest_income, 0 ) +
            NVL( v_sum_return_bonus_part, 0 ) != 0 THEN
        v_sum := ( NVL( v_overpayment, 0 ) / ( NVL( v_sum_redemption_sum, 0 ) +
          NVL( v_sum_add_invest_income, 0 ) +  NVL( v_sum_return_bonus_part, 0 ) ) )
          * ( NVL( cover_rec.redemption_sum, 0 ) +
              NVL( cover_rec.add_invest_income, 0 ) +
              NVL( cover_rec.return_bonus_part, 0 ) );
        v_sum := ROUND( v_sum, 2 );
        IF NVL( v_sum, 0 ) != 0 THEN
          v_sum_17 := v_sum_17 + v_sum;
          Run_Template( 'QUIT_MAIN_17',
            Get_P_Cover_Id( cover_rec.as_asset_id, cover_rec.t_product_line_id ) );
          Set_Analytics( v_oper_id, cover_rec.as_asset_id,
            cover_rec.t_product_line_id );
          IF v_sum > v_max_sum_17 THEN
            v_max_sum_17 := v_sum;
            v_max_sum_oper_id_17 := v_oper_id;
          END IF;
        END IF;
      END IF;*/
    END LOOP;
    -- 13 *** ������� ������� �� � ��� 77.00.14 77.00.02
    -- 9 *** ����� �� (����� �� ������ ��) 77.00.14 77.08.03
    IF nvl(v_sum_redemption_sum, 0) + nvl(v_sum_add_invest_income, 0) +
       nvl(v_sum_return_bonus_part, 0) - nvl(v_medo_cost, 0) != 0
    THEN
      v_sum_9 := nvl(v_other_pol_sum, 0) * v_sum_3 /
                 (nvl(v_sum_redemption_sum, 0) + nvl(v_sum_add_invest_income, 0) +
                  nvl(v_sum_return_bonus_part, 0) - nvl(v_medo_cost, 0));
    END IF;
    v_sum_9 := ROUND(nvl(v_sum_9, 0), 2);
    -- 10 *** ������� ������� ��� (����� �� ������ ��) 77.00.14 77.08.03
    IF nvl(v_sum_redemption_sum, 0) + nvl(v_sum_add_invest_income, 0) +
       nvl(v_sum_return_bonus_part, 0) - nvl(v_medo_cost, 0) != 0
    THEN
      v_sum_10 := nvl(v_other_pol_sum, 0) * v_sum_4 /
                  (nvl(v_sum_redemption_sum, 0) + nvl(v_sum_add_invest_income, 0) +
                   nvl(v_sum_return_bonus_part, 0) - nvl(v_medo_cost, 0));
    END IF;
    v_sum_10 := ROUND(nvl(v_sum_10, 0), 2);
    v_sum    := v_sum_3 -- + SUM( ���������� �������� ����� )
                + v_sum_4 -- + SUM( ���������� ��������������� ��������������� ������ )
                - v_sum_6 -- - SUM( ����� �� )
                - v_sum_7 -- - SUM( ������� ������� ��� )
                - v_sum_9 -- - ����� �� (����� �� ������ ��)
                - v_sum_10; -- - ������� ������� ��� (����� �� ������ ��)
    -- - ������� ���� -- ishch 31.01.2011 ��� ����
    -- - NVL( ROUND( v_income_tax_sum, 2 ), 0 );
    IF nvl(v_sum, 0) != 0
    THEN
      run_template('QUIT_MAIN_13', NULL);
      v_oper_id_13 := v_oper_id;
    END IF;
    -- 14 *** ������� ������� ���� 2 77.00.13 77.00.02
    -- 11 *** ������� ������� ���� (����� �� ������ ��) 77.00.13 77.08.03
    IF nvl(v_sum_redemption_sum, 0) + nvl(v_sum_add_invest_income, 0) +
       nvl(v_sum_return_bonus_part, 0) - nvl(v_medo_cost, 0) != 0
    THEN
      v_sum_11 := nvl(v_other_pol_sum, 0) * v_sum_5 /
                  (nvl(v_sum_redemption_sum, 0) + nvl(v_sum_add_invest_income, 0) +
                   nvl(v_sum_return_bonus_part, 0) - nvl(v_medo_cost, 0));
    END IF;
    v_sum_11            := ROUND(nvl(v_sum_11, 0), 2);
    v_overpayment_round := nvl(get_round_4(par_p_policy_id), 0);
    v_sum               := v_sum_5 -- + �������� ������� �� ��� ����������� ��
                           - v_sum_8 -- - ������� ������� ����
                           - v_sum_11 -- ������� ������� ���� (����� �� ������ ��)
                           + v_sum_16 -- ��������� ��� �������� �� ��������� ������
                           + v_sum_17 -- ��������� �� ��������
                           + v_overpayment_round; -- ���������� ��������� �� ��������
    IF nvl(v_sum, 0) != 0
    THEN
      run_template('QUIT_MAIN_14', NULL);
      v_oper_id_14 := v_oper_id;
    END IF;
    -- ����������� ������ ���������� � ������������ ����� �� 3, 4, 5 ���������
    v_round_err_1 := nvl(get_round_1(par_p_policy_id), 0);
    IF v_max_sum_oper_id IS NOT NULL
       AND v_round_err_1 != 0
    THEN
      UPDATE trans
         SET trans_amount = trans_amount + v_round_err_1
            ,acc_amount   = acc_amount + v_round_err_1
       WHERE oper_id = v_max_sum_oper_id;
    END IF;
    -- ����������� ������ ���������� � ������������ ����� �� 6, 7, 8 ���������
    v_round_err_2 := nvl(get_round_2(par_p_policy_id), 0);
    IF v_max_sum_oper_id_2 IS NOT NULL
       AND v_round_err_2 != 0
    THEN
      UPDATE trans
         SET trans_amount = trans_amount + v_round_err_2
            ,acc_amount   = acc_amount + v_round_err_2
       WHERE oper_id = v_max_sum_oper_id_2;
    END IF;
    -- ����������� ������ ���������� � ������������ ����� �� 17 ��������
    IF v_max_sum_oper_id_17 IS NOT NULL
    THEN
      v_round_err := nvl(get_round_4(par_p_policy_id), 0);
      IF v_round_err != 0
      THEN
        UPDATE trans
           SET trans_amount = trans_amount + v_round_err
              ,acc_amount   = acc_amount + v_round_err
         WHERE oper_id = v_max_sum_oper_id_17;
      END IF;
    END IF;
    get_round_3(par_p_policy_id, v_round_err_3, v_template_num_3);
    -- ����������� ������ ���������� � ����� 13 ��������:
    v_round_err := 0;
    IF v_round_err_1 != 0
       AND (nvl(v_template_num, 0) = 3 OR nvl(v_template_num, 0) = 4)
    THEN
      -- ���� ������ ������ ���������� ������� �� 3-�� ��� 4-�� �������� -
      -- ��������� �� �� 13-�� ��������
      v_round_err := v_round_err_1;
    END IF;
    IF v_round_err_2 != 0
       AND (nvl(v_template_num_2, 0) = 6 OR nvl(v_template_num_2, 0) = 7)
    THEN
      -- ���� ������ ������ ���������� ������� �� 6-�� ��� 7-�� �������� -
      -- ��������� �� �� 13-�� ��������
      v_round_err := v_round_err - v_round_err_2;
    END IF;
    IF v_round_err_3 != 0
       AND (nvl(v_template_num_3, 0) = 9 OR nvl(v_template_num_3, 0) = 10)
    THEN
      -- ���� ������ ������ ���������� ������� �� 9-�� ��� 10-�� �������� -
      -- ��������� �� �� 13-�� ��������
      v_round_err := v_round_err - v_round_err_3;
    END IF;
    IF v_round_err != 0
    THEN
      UPDATE trans
         SET trans_amount = trans_amount + v_round_err
            ,acc_amount   = acc_amount + v_round_err
       WHERE oper_id = v_oper_id_13;
    END IF;
    -- ����������� ������ ���������� � ����� 14 ��������:
    v_round_err := 0;
    IF v_round_err_1 != 0
       AND nvl(v_template_num, 0) = 5
    THEN
      -- ���� ������ ������ ���������� ������� �� 5-�� �������� -
      -- ��������� �� �� 14-�� ��������
      v_round_err := v_round_err_1;
    END IF;
    IF v_round_err_2 != 0
       AND nvl(v_template_num_2, 0) = 8
    THEN
      -- ���� ������ ������ ���������� ������� �� 8-�� �������� -
      -- ��������� �� �� 14-�� ��������
      v_round_err := v_round_err - v_round_err_2;
    END IF;

    IF v_round_err_3 != 0
       AND nvl(v_template_num_3, 0) = 11
    THEN
      -- ���� ������ ������ ���������� ������� �� 11-�� �������� -
      -- ��������� �� �� 14-�� ��������
      v_round_err := v_round_err - v_round_err_3;
    END IF;
    IF v_round_err != 0
    THEN
      UPDATE trans
         SET trans_amount = trans_amount + v_round_err
            ,acc_amount   = acc_amount + v_round_err
       WHERE oper_id = v_oper_id_14;
    END IF;
    -- ������ �.
    -- �������� �������� �� ���������� ����
    IF v_medo_cost != 0
    THEN
      v_sum := v_medo_cost;
      run_template('QUIT_MAIN_19', NULL);
    END IF;
  EXCEPTION
    WHEN e_annul_check_failure THEN
      raise_application_error(-20001
                             ,'��� ������� ����������� �� ������ "�������������" ������ ���� ' ||
                              '����� ����: ��, ���, ���, ���������, ���������');
    WHEN OTHERS THEN
      raise_application_error(-20001, 'Gen_Main_Trans_Group_1: ' || SQLERRM);
  END gen_main_trans_group_1;
  ----========================================================================----
  -- ��������� ������ ������ �������� �������� �� ����������� �� - ���������
  PROCEDURE gen_main_trans_group_2(par_p_policy_id NUMBER) IS
    v_oper_id               NUMBER;
    v_ent_id                NUMBER;
    v_oper_templ_id         NUMBER;
    v_medo_cost             NUMBER;
    v_debt_summ             NUMBER;
    v_income_tax_sum        NUMBER;
    v_overpayment           NUMBER;
    v_sum_redemption_sum    NUMBER;
    v_sum_add_invest_income NUMBER;
    v_sum_return_bonus_part NUMBER;
    v_admin_expenses        NUMBER;
    v_sum                   NUMBER;
    v_sum_3                 NUMBER := 0; -- SUM( ���������� �������� ����� )
    v_sum_4                 NUMBER := 0; -- SUM( ���������� ��������������� ��������������� ������ )
    v_sum_5                 NUMBER := 0; -- SUM( �������� ������� �� ��� ����������� �� )
    v_sum_6                 NUMBER := 0; -- SUM( ����� �� )
    v_sum_7                 NUMBER := 0; -- SUM( ������� ������� ��� )
    v_sum_8                 NUMBER := 0; -- SUM( ������� ������� ���� )
    v_sum_16                NUMBER := 0; -- SUM( ��������� ��� �������� �� ��������� ������ )
    v_sum_17                NUMBER := 0; -- SUM( ��������� �� �������� )
    --
    v_sum_9         NUMBER;
    v_sum_10        NUMBER;
    v_sum_11        NUMBER;
    v_other_pol_sum NUMBER;
    --
    v_round_err         NUMBER;
    v_round_err_1       NUMBER;
    v_round_err_2       NUMBER;
    v_round_err_3       NUMBER;
    v_overpayment_round NUMBER; -- ������ ���������� �� ���������
    v_template_num_3    NUMBER;
    --
    CURSOR cover_curs(pcurs_p_policy_id NUMBER) IS
      SELECT cd.as_asset_id
            ,cd.t_product_line_id
            ,cd.cover_period
            ,cd.redemption_sum
            ,cd.add_invest_income
            ,cd.return_bonus_part
            ,cd.bonus_off_prev
            ,cd.bonus_off_current
            ,cd.admin_expenses
        FROM p_cover_decline cd
            ,p_pol_decline   pd
       WHERE cd.p_pol_decline_id = pd.p_pol_decline_id
         AND pd.p_policy_id = pcurs_p_policy_id;
  BEGIN
    check_annul(par_p_policy_id);
    SELECT p.ent_id
          ,pd.medo_cost
          ,p.debt_summ
          ,pd.income_tax_sum
          ,pd.other_pol_sum
          ,pd.overpayment
      INTO v_ent_id
          ,v_medo_cost
          ,v_debt_summ
          ,v_income_tax_sum
          ,v_other_pol_sum
          ,v_overpayment
      FROM ven_p_policy  p
          ,p_pol_decline pd
     WHERE p.policy_id = par_p_policy_id
       AND p.policy_id = pd.p_policy_id;
    SELECT SUM(cd.redemption_sum)
          ,SUM(cd.add_invest_income)
          ,SUM(cd.return_bonus_part)
           -- ������ �.
          ,SUM(cd.admin_expenses)
      INTO v_sum_redemption_sum
          ,v_sum_add_invest_income
          ,v_sum_return_bonus_part
           --
          ,v_admin_expenses
      FROM p_pol_decline   pd
          ,p_cover_decline cd
     WHERE pd.p_policy_id = par_p_policy_id
       AND pd.p_pol_decline_id = cd.p_pol_decline_id;
    -- 12 *** ������� ���� 77.00.14 68.02 ���� ���������� ����
    v_sum := ROUND(v_income_tax_sum, 2);
    IF nvl(v_sum, 0) != 0
    THEN
      SELECT oper_templ_id INTO v_oper_templ_id FROM oper_templ WHERE brief = 'QUIT_MAIN_12';
      v_oper_id := acc_new.run_oper_by_template(p_oper_templ_id     => v_oper_templ_id
                                               ,p_document_id       => par_p_policy_id
                                               ,p_service_ent_id    => v_ent_id
                                               ,p_service_obj_id    => par_p_policy_id
                                               ,p_doc_status_ref_id => NULL
                                               ,p_is_accepted       => 1
                                               ,p_summ              => v_sum
                                               ,p_source            => 'INS');
    END IF;
    -- 15 *** ��������� 77.00.02 51 ���� �������
    IF nvl(v_sum_redemption_sum, 0) + nvl(v_sum_add_invest_income, 0) +
       nvl(v_sum_return_bonus_part, 0) != 0
    THEN
      FOR cover_rec IN cover_curs(par_p_policy_id)
      LOOP
        -- 3 *** ���������� �������� ����� 22.05.31 77.00.14
        v_sum   := nvl(cover_rec.redemption_sum, 0) -
                   (nvl(v_medo_cost, 0) * nvl(cover_rec.redemption_sum, 0) /
                    (nvl(v_sum_redemption_sum, 0) + nvl(v_sum_add_invest_income, 0) +
                     nvl(v_sum_return_bonus_part, 0)));
        v_sum_3 := v_sum_3 + nvl(ROUND(v_sum, 2), 0);
        -- 4 *** ���������� ��������������� ��������������� ������ 22.05.33 77.00.14
        v_sum   := nvl(cover_rec.add_invest_income, 0) -
                   (nvl(v_medo_cost, 0) * nvl(cover_rec.add_invest_income, 0) /
                    (nvl(v_sum_redemption_sum, 0) + nvl(v_sum_add_invest_income, 0) +
                     nvl(v_sum_return_bonus_part, 0)));
        v_sum_4 := v_sum_4 + nvl(ROUND(v_sum, 2), 0);
        -- 5 *** �������� ������� �� ��� ����������� �� 22.05.11 77.00.13
        v_sum   := nvl(cover_rec.return_bonus_part, 0) -
                   (nvl(v_medo_cost, 0) * nvl(cover_rec.return_bonus_part, 0) /
                    (nvl(v_sum_redemption_sum, 0) + nvl(v_sum_add_invest_income, 0) +
                     nvl(v_sum_return_bonus_part, 0)));
        v_sum_5 := v_sum_5 + nvl(ROUND(v_sum, 2), 0);
        -- 6 *** ����� �� 77.00.14 77.01.03
        v_sum   := (nvl(v_debt_summ, 0) * nvl(cover_rec.redemption_sum, 0) /
                   (nvl(v_sum_redemption_sum, 0) + nvl(v_sum_add_invest_income, 0) +
                   nvl(v_sum_return_bonus_part, 0)));
        v_sum_6 := v_sum_6 + nvl(ROUND(v_sum, 2), 0);
        -- 7 *** ������� ������� ��� 77.00.14 77.01.03
        v_sum   := (nvl(v_debt_summ, 0) * nvl(cover_rec.add_invest_income, 0) /
                   (nvl(v_sum_redemption_sum, 0) + nvl(v_sum_add_invest_income, 0) +
                   nvl(v_sum_return_bonus_part, 0)));
        v_sum_7 := v_sum_7 + nvl(ROUND(v_sum, 2), 0);
        -- 8 *** ������� ������� ���� 77.00.13 77.01.03
        v_sum   := (nvl(v_debt_summ, 0) * nvl(cover_rec.return_bonus_part, 0) /
                   (nvl(v_sum_redemption_sum, 0) + nvl(v_sum_add_invest_income, 0) +
                   nvl(v_sum_return_bonus_part, 0)));
        v_sum_8 := v_sum_8 + nvl(ROUND(v_sum, 2), 0);
        -- 16 *** ��������� ��� ���� �� ��������� ������ 22.05.11 77.00.13
        v_sum    := ROUND(-cover_rec.admin_expenses, 2); -- � �������!
        v_sum_16 := v_sum_16 + nvl(v_sum, 0);
        -- 17 *** ��������� �� �������� 77.01.03 77.00.13
        v_sum    := (nvl(v_overpayment, 0) /
                    (nvl(v_sum_redemption_sum, 0) + nvl(v_sum_add_invest_income, 0) +
                    nvl(v_sum_return_bonus_part, 0))) *
                    (nvl(cover_rec.redemption_sum, 0) + nvl(cover_rec.add_invest_income, 0) +
                    nvl(cover_rec.return_bonus_part, 0));
        v_sum_17 := v_sum_17 + nvl(ROUND(v_sum, 2), 0);
      END LOOP;
    ELSE
      v_sum_3  := 0;
      v_sum_4  := 0;
      v_sum_5  := 0;
      v_sum_6  := 0;
      v_sum_7  := 0;
      v_sum_8  := 0;
      v_sum_16 := 0;
      -- ������ �.
      -- ���� ������ ����� ����� 0, ��������� ����� ����� ����� � �������
      --v_sum_17 := 0;
      v_sum_17 := (nvl(v_sum_redemption_sum, 0) + nvl(v_sum_add_invest_income, 0) +
                  nvl(v_sum_return_bonus_part, 0)) + nvl(v_overpayment, 0) - nvl(v_debt_summ, 0) -
                  nvl(v_medo_cost, 0) - nvl(v_admin_expenses, 0);

    END IF;
    -- 9 *** ����� �� (����� �� ������ ��) 77.00.14 77.08.03
    IF nvl(v_sum_redemption_sum, 0) + nvl(v_sum_add_invest_income, 0) +
       nvl(v_sum_return_bonus_part, 0) - nvl(v_medo_cost, 0) != 0
    THEN
      v_sum_9 := nvl(v_other_pol_sum, 0) * v_sum_3 /
                 (nvl(v_sum_redemption_sum, 0) + nvl(v_sum_add_invest_income, 0) +
                  nvl(v_sum_return_bonus_part, 0) - nvl(v_medo_cost, 0));
    END IF;
    v_sum_9 := ROUND(nvl(v_sum_9, 0), 2);
    -- 10 *** ������� ������� ��� (����� �� ������ ��) 77.00.14 77.08.03
    IF nvl(v_sum_redemption_sum, 0) + nvl(v_sum_add_invest_income, 0) +
       nvl(v_sum_return_bonus_part, 0) - nvl(v_medo_cost, 0) != 0
    THEN
      v_sum_10 := nvl(v_other_pol_sum, 0) * v_sum_4 /
                  (nvl(v_sum_redemption_sum, 0) + nvl(v_sum_add_invest_income, 0) +
                   nvl(v_sum_return_bonus_part, 0) - nvl(v_medo_cost, 0));
    END IF;
    v_sum_10 := ROUND(nvl(v_sum_10, 0), 2);
    -- 11 *** ������� ������� ���� (����� �� ������ ��) 77.00.13 77.08.03
    IF nvl(v_sum_redemption_sum, 0) + nvl(v_sum_add_invest_income, 0) +
       nvl(v_sum_return_bonus_part, 0) - nvl(v_medo_cost, 0) != 0
    THEN
      v_sum_11 := nvl(v_other_pol_sum, 0) * v_sum_5 /
                  (nvl(v_sum_redemption_sum, 0) + nvl(v_sum_add_invest_income, 0) +
                   nvl(v_sum_return_bonus_part, 0) - nvl(v_medo_cost, 0));
    END IF;
    v_sum_11            := ROUND(nvl(v_sum_11, 0), 2);
    v_overpayment_round := nvl(get_round_4(par_p_policy_id), 0);
    v_sum               :=  -- *** ������� ������� �� � ��� (�13)
     v_sum_3 -- + SUM( ���������� �������� ����� )
                           + v_sum_4 -- + SUM( ���������� ��������������� ��������������� ������ )
                           - v_sum_6 -- - SUM( ����� �� )
                           - v_sum_7 -- - SUM( ������� ������� ��� )
                           - v_sum_9 -- - ����� �� (����� �� ������ ��)
                           - v_sum_10 -- - ������� ������� ��� (����� �� ������ ��)
                          -- - ������� ����
                           - nvl(ROUND(v_income_tax_sum, 2), 0)
                          -- + *** ������� ������� ���� 2 (�14)
                           + v_sum_5 -- + �������� ������� �� ��� ����������� ��
                           - v_sum_8 -- - ������� ������� ����
                           - v_sum_11 -- - ������� ������� ���� (����� �� ������ ��)
                           + v_sum_16 -- + ��������� ��� �������� �� ��������� ������
                           + v_sum_17 -- + ��������� �� ��������
                           + v_overpayment_round; -- + ���������� ��������� �� ��������
    IF ((v_sum_3 + v_sum_4 - v_sum_6 - v_sum_7 -- �������������� �������
       - nvl(ROUND(v_income_tax_sum, 2), 0) - v_sum_9 - v_sum_10) > 0 OR
       ((v_sum_5 - v_sum_8 - v_sum_11 + v_sum_16 + v_sum_17 + v_overpayment_round) > 0))
    THEN
      SELECT oper_templ_id INTO v_oper_templ_id FROM oper_templ WHERE brief = 'QUIT_MAIN_15';
      -- ������ ������ ����������
      v_round_err_1 := nvl(get_round_1(par_p_policy_id), 0);
      v_round_err_2 := nvl(get_round_2(par_p_policy_id), 0);
      get_round_3(par_p_policy_id, v_round_err_3, v_template_num_3);
      v_round_err := v_round_err_1 - v_round_err_2 - v_round_err_3;
      -- ����� � ������ ������ ����������
      IF nvl(v_round_err, 0) != 0
      THEN
        v_sum := v_sum + v_round_err;
      END IF;
      IF nvl(v_sum, 0) != 0
      THEN
        v_oper_id := acc_new.run_oper_by_template(p_oper_templ_id     => v_oper_templ_id
                                                 ,p_document_id       => par_p_policy_id
                                                 ,p_service_ent_id    => v_ent_id
                                                 ,p_service_obj_id    => par_p_policy_id
                                                 ,p_doc_status_ref_id => NULL
                                                 ,p_is_accepted       => 1
                                                 ,p_summ              => v_sum
                                                 ,p_source            => 'INS');
      END IF;
    END IF;
    v_sum := -nvl(ROUND(v_income_tax_sum, 2), 0); -- - ������� ����
    IF nvl(v_sum, 0) != 0
    THEN
      SELECT oper_templ_id INTO v_oper_templ_id FROM oper_templ WHERE brief = 'QUIT_MAIN_18';
      v_oper_id := acc_new.run_oper_by_template(p_oper_templ_id     => v_oper_templ_id
                                               ,p_document_id       => par_p_policy_id
                                               ,p_service_ent_id    => v_ent_id
                                               ,p_service_obj_id    => par_p_policy_id
                                               ,p_doc_status_ref_id => NULL
                                               ,p_is_accepted       => 1
                                               ,p_summ              => v_sum
                                               ,p_source            => 'INS');
    END IF;
  EXCEPTION
    WHEN e_annul_check_failure THEN
      raise_application_error(-20001
                             ,'��� ������� ����������� �� ������ "�������������" ������ ���� ' ||
                              '����� ����: ��, ���, ���, ���������, ���������');
    WHEN OTHERS THEN
      raise_application_error(-20001, 'Gen_Main_Trans_Group_2: ' || SQLERRM);
  END gen_main_trans_group_2;
  ----========================================================================----
  -- ��������� �������� �� ������ �� ������ �������
  PROCEDURE gen_trans_setoff(par_doc_id NUMBER) IS
    v_policy_id             NUMBER;
    v_other_pol_sum         NUMBER;
    v_oper_id               NUMBER;
    v_ent_id                NUMBER;
    v_oper_templ_id         NUMBER;
    v_medo_cost             NUMBER;
    v_sum_redemption_sum    NUMBER;
    v_sum_add_invest_income NUMBER;
    v_sum_return_bonus_part NUMBER;
    v_sum                   NUMBER;
    v_sum_3                 NUMBER := 0; -- SUM( ���������� �������� ����� )
    v_sum_4                 NUMBER := 0; -- SUM( ���������� ��������������� ��������������� ������ )
    v_sum_5                 NUMBER := 0; -- SUM( �������� ������� �� ��� ����������� �� )
    v_sum_9                 NUMBER := 0; -- ����� �� (����� �� ������ ��)
    v_sum_10                NUMBER := 0; -- ������� ������� ��� (����� �� ������ ��)
    v_sum_11                NUMBER := 0; -- ������� ������� ���� (����� �� ������ ��)
    v_continue              BOOLEAN := TRUE;
    --
    v_round_err       NUMBER;
    v_max_sum         NUMBER := 0; -- ������������ ����� �� ���������
    v_max_sum_oper_id NUMBER; -- �� ��������, ��������������� ������������ �����
    --
    CURSOR cover_curs(pcurs_p_policy_id NUMBER) IS
      SELECT cd.as_asset_id
            ,cd.t_product_line_id
            ,cd.cover_period
            ,cd.redemption_sum
            ,cd.add_invest_income
            ,cd.return_bonus_part
            ,cd.bonus_off_prev
            ,cd.bonus_off_current
            ,cd.admin_expenses
        FROM p_cover_decline cd
            ,p_pol_decline   pd
       WHERE cd.p_pol_decline_id = pd.p_pol_decline_id
         AND pd.p_policy_id = pcurs_p_policy_id;
  BEGIN
    SAVEPOINT gen_trans_setoff;
    SELECT ent_id INTO v_ent_id FROM entity WHERE brief = 'AC_PAYMENT';
    -- ����� ������ ��, � ������� �������� �����
    BEGIN
      SELECT dd.parent_id INTO v_policy_id FROM doc_doc dd WHERE dd.child_id = par_doc_id;
    EXCEPTION
      WHEN OTHERS THEN
        v_continue := FALSE;
    END;
    check_annul(v_policy_id);
    -- �������� ��������� ������ ��� ������ �� ������ ������� ��� ����������� ��:
    IF NOT
        doc.get_doc_status_brief(v_policy_id) IN ('TO_QUIT'
                                                 ,'TO_QUIT_CHECK_READY'
                                                 ,'TO_QUIT_CHECKED'
                                                 ,'QUIT_REQ_QUERY'
                                                 ,'QUIT_REQ_GET'
                                                 ,'QUIT_TO_PAY'
                                                 ,'QUIT')
    THEN
      v_continue := FALSE;
    END IF;
    -- *** ������ ��� ��������
    IF v_continue
    THEN
      BEGIN
        -- ����� ������
        SELECT SUM(a.amount) setoff_amount
          INTO v_other_pol_sum
          FROM ac_payment a
         WHERE a.payment_id = par_doc_id;
        IF nvl(v_other_pol_sum, 0) = 0
        THEN
          v_continue := FALSE;
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          v_continue := FALSE;
      END;
    END IF;
    IF v_continue
    THEN
      BEGIN
        -- ������ �� ����������� ��
        SELECT pd.medo_cost
          INTO v_medo_cost
          FROM ven_p_policy  p
              ,p_pol_decline pd
         WHERE p.policy_id = v_policy_id
           AND p.policy_id = pd.p_policy_id;
        -- ������ �� �������������� � ����������
        SELECT SUM(cd.redemption_sum)
              ,SUM(cd.add_invest_income)
              ,SUM(cd.return_bonus_part)
          INTO v_sum_redemption_sum
              ,v_sum_add_invest_income
              ,v_sum_return_bonus_part
          FROM p_pol_decline   pd
              ,p_cover_decline cd
         WHERE pd.p_policy_id = v_policy_id
           AND pd.p_pol_decline_id = cd.p_pol_decline_id;
        IF nvl(v_sum_redemption_sum, 0) + nvl(v_sum_add_invest_income, 0) +
           nvl(v_sum_return_bonus_part, 0) = 0
        THEN
          v_continue := FALSE;
        END IF;
        IF nvl(v_sum_redemption_sum, 0) + nvl(v_sum_add_invest_income, 0) +
           nvl(v_sum_return_bonus_part, 0) - nvl(v_medo_cost, 0) = 0
        THEN
          v_continue := FALSE;
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          v_continue := FALSE;
      END;
    END IF;
    IF v_continue
    THEN
      BEGIN
        IF nvl(v_sum_redemption_sum, 0) + nvl(v_sum_add_invest_income, 0) +
           nvl(v_sum_return_bonus_part, 0) != 0
        THEN
          FOR cover_rec IN cover_curs(v_policy_id)
          LOOP
            -- 3 *** ���������� �������� ����� 22.05.31 77.00.14
            v_sum   := nvl(cover_rec.redemption_sum, 0) -
                       (nvl(v_medo_cost, 0) * nvl(cover_rec.redemption_sum, 0) /
                        (nvl(v_sum_redemption_sum, 0) + nvl(v_sum_add_invest_income, 0) +
                         nvl(v_sum_return_bonus_part, 0)));
            v_sum_3 := v_sum_3 + nvl(ROUND(v_sum, 2), 0);
            -- 4 *** ���������� ��������������� ��������������� ������ 22.05.33 77.00.14
            v_sum   := nvl(cover_rec.add_invest_income, 0) -
                       (nvl(v_medo_cost, 0) * nvl(cover_rec.add_invest_income, 0) /
                        (nvl(v_sum_redemption_sum, 0) + nvl(v_sum_add_invest_income, 0) +
                         nvl(v_sum_return_bonus_part, 0)));
            v_sum_4 := v_sum_4 + nvl(ROUND(v_sum, 2), 0);
            -- 5 *** �������� ������� �� ��� ����������� �� 22.05.11 77.00.13
            v_sum   := nvl(cover_rec.return_bonus_part, 0) -
                       (nvl(v_medo_cost, 0) * nvl(cover_rec.return_bonus_part, 0) /
                        (nvl(v_sum_redemption_sum, 0) + nvl(v_sum_add_invest_income, 0) +
                         nvl(v_sum_return_bonus_part, 0)));
            v_sum_5 := v_sum_5 + nvl(ROUND(v_sum, 2), 0);
          END LOOP;
        ELSE
          v_sum_3 := 0;
          v_sum_4 := 0;
          v_sum_5 := 0;
        END IF;
        -- 9 *** ����� �� (����� �� ������ ��) 77.00.14 77.08.03
        IF nvl(v_sum_redemption_sum, 0) + nvl(v_sum_add_invest_income, 0) +
           nvl(v_sum_return_bonus_part, 0) - nvl(v_medo_cost, 0) != 0
        THEN
          v_sum := nvl(v_other_pol_sum, 0) * v_sum_3 /
                   (nvl(v_sum_redemption_sum, 0) + nvl(v_sum_add_invest_income, 0) +
                    nvl(v_sum_return_bonus_part, 0) - nvl(v_medo_cost, 0));
        END IF;
        v_sum := ROUND(nvl(v_sum, 0), 2);
        IF v_sum != 0
        THEN
          SELECT oper_templ_id INTO v_oper_templ_id FROM oper_templ WHERE brief = 'QUIT_MAIN_9';
          v_oper_id := acc_new.run_oper_by_template(p_oper_templ_id     => v_oper_templ_id
                                                   ,p_document_id       => par_doc_id
                                                   ,p_service_ent_id    => v_ent_id
                                                   ,p_service_obj_id    => par_doc_id
                                                   ,p_doc_status_ref_id => NULL
                                                   ,p_is_accepted       => 1
                                                   ,p_summ              => v_sum
                                                   ,p_source            => 'INS');
          IF v_sum > v_max_sum
          THEN
            v_max_sum         := v_sum;
            v_max_sum_oper_id := v_oper_id;
          END IF;
          v_sum_9 := v_sum;
        END IF;
        -- 10 *** ������� ������� ��� (����� �� ������ ��) 77.00.14 77.08.03
        IF nvl(v_sum_redemption_sum, 0) + nvl(v_sum_add_invest_income, 0) +
           nvl(v_sum_return_bonus_part, 0) - nvl(v_medo_cost, 0) != 0
        THEN
          v_sum := nvl(v_other_pol_sum, 0) * v_sum_4 /
                   (nvl(v_sum_redemption_sum, 0) + nvl(v_sum_add_invest_income, 0) +
                    nvl(v_sum_return_bonus_part, 0) - nvl(v_medo_cost, 0));
        END IF;
        v_sum := ROUND(nvl(v_sum, 0), 2);
        IF v_sum != 0
        THEN
          SELECT oper_templ_id INTO v_oper_templ_id FROM oper_templ WHERE brief = 'QUIT_MAIN_10';
          v_oper_id := acc_new.run_oper_by_template(p_oper_templ_id     => v_oper_templ_id
                                                   ,p_document_id       => par_doc_id
                                                   ,p_service_ent_id    => v_ent_id
                                                   ,p_service_obj_id    => par_doc_id
                                                   ,p_doc_status_ref_id => NULL
                                                   ,p_is_accepted       => 1
                                                   ,p_summ              => v_sum
                                                   ,p_source            => 'INS');
          IF v_sum > v_max_sum
          THEN
            v_max_sum         := v_sum;
            v_max_sum_oper_id := v_oper_id;
          END IF;
          v_sum_10 := v_sum;
        END IF;
        -- 11 *** ������� ������� ���� (����� �� ������ ��) 77.00.13 77.08.03
        IF nvl(v_sum_redemption_sum, 0) + nvl(v_sum_add_invest_income, 0) +
           nvl(v_sum_return_bonus_part, 0) - nvl(v_medo_cost, 0) != 0
        THEN
          v_sum := nvl(v_other_pol_sum, 0) * v_sum_5 /
                   (nvl(v_sum_redemption_sum, 0) + nvl(v_sum_add_invest_income, 0) +
                    nvl(v_sum_return_bonus_part, 0) - nvl(v_medo_cost, 0));
        END IF;
        v_sum := ROUND(nvl(v_sum, 0), 2);
        IF v_sum != 0
        THEN
          SELECT oper_templ_id INTO v_oper_templ_id FROM oper_templ WHERE brief = 'QUIT_MAIN_11';
          v_oper_id := acc_new.run_oper_by_template(p_oper_templ_id     => v_oper_templ_id
                                                   ,p_document_id       => par_doc_id
                                                   ,p_service_ent_id    => v_ent_id
                                                   ,p_service_obj_id    => par_doc_id
                                                   ,p_doc_status_ref_id => NULL
                                                   ,p_is_accepted       => 1
                                                   ,p_summ              => v_sum
                                                   ,p_source            => 'INS');
          IF v_sum > v_max_sum
          THEN
            v_max_sum         := v_sum;
            v_max_sum_oper_id := v_oper_id;
          END IF;
          v_sum_11 := v_sum;
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          v_continue := FALSE;
      END;
    END IF;
    -- 3) ���������� ������ �� ����� �������:
    -- ���������� ����� ������������ � ������������ ����� �������� �� ��������:
    -- ����� �� (����� �� ������  ��), ������� ������� ��� (����� �� ������  ��),
    -- ������� ������� ���� (����� �� ������  ��).
    -- �������� �������: ���������� ������ � ���� ������� �������� =
    -- (�������� ���� "����� ������ �� ������ �������") -
    -- ? ������ "����� �� (����� �� ������  ��)" -
    -- ? ������ "������� ������� ��� (����� �� ������  ��)" -
    -- ? ������ "������� ������� ���� (����� �� ������  ��)"
    IF v_continue
    THEN
      -- ������ ������ ����������
      v_round_err := nvl(v_other_pol_sum, 0) -- ����� ������ �� ������ �������
                     - nvl(v_sum_9, 0) -- ����� �� (����� �� ������ ��)
                     - nvl(v_sum_10, 0) -- ������� ������� ��� (����� �� ������ ��)
                     - nvl(v_sum_11, 0); -- ������� ������� ���� (����� �� ������ ��)
      IF v_max_sum_oper_id IS NOT NULL
         AND v_round_err != 0
      THEN
        UPDATE trans
           SET trans_amount = trans_amount + v_round_err
              ,acc_amount   = acc_amount + v_round_err
         WHERE oper_id = v_max_sum_oper_id;
      END IF;
    END IF;
    IF NOT v_continue
    THEN
      ROLLBACK TO gen_trans_setoff;
    END IF;
  EXCEPTION
    WHEN e_annul_check_failure THEN
      raise_application_error(-20001
                             ,'��� ������� ����������� �� ������ "�������������" ������ ���� ' ||
                              '����� ����: ��, ���, ���, ���������, ���������');
    WHEN OTHERS THEN
      ROLLBACK TO gen_trans_setoff;
      raise_application_error(-20001, 'Gen_Trans_Setoff: ' || SQLERRM);
  END gen_trans_setoff;
  ----========================================================================----
  -- ������� ������������ �����
  PROCEDURE delete_unpayed_acc(par_p_policy_id NUMBER) IS
    v_deleted       NUMBER;
    v_pol_header_id NUMBER;
    v_decline_date  DATE;
    v_act_date      DATE;
    v_date          DATE;
  BEGIN
    SELECT p.pol_header_id
          ,p.decline_date
          ,pd.act_date
      INTO v_pol_header_id
          ,v_decline_date
          ,v_act_date
      FROM p_policy      p
          ,p_pol_decline pd
     WHERE p.policy_id = pd.p_policy_id
       AND p.policy_id = par_p_policy_id;
    IF decline_reason_is_annul(par_p_policy_id) = 1
    THEN
      v_date := v_act_date;
    ELSE
      v_date := v_decline_date;
    END IF;
    FOR rc IN (SELECT ap.payment_id
                     ,ap.amount
                     ,dt.brief
                 FROM p_policy       p
                     ,ven_ac_payment ap
                     ,doc_doc        dd
                     ,doc_templ      dt
                WHERE p.pol_header_id = v_pol_header_id
                  AND dd.child_id = ap.payment_id
                  AND dd.parent_id = p.policy_id
                  AND dt.doc_templ_id = ap.doc_templ_id
                  AND dt.brief IN ('PAYMENT', 'PAYMENT_SETOFF_ACC')
                     -- 17.01.2011 ishch. ��������� ��� ����� ���� �����������,
                     -- �.�. � ����, ��������� �� ����� �����������
                     --AND ap.due_date > v_decline_date
                     -- 27.01.2011 ishch. ��������� ��� ����� ���� ����
                     -- 28.01.2011 ishch. ��� ������������� - ���� ����
                     -- ��� ����������� - ���� �����������
                  AND ap.due_date > v_date)
    LOOP
      v_deleted := pkg_payment.delete_payment(rc.payment_id, rc.brief, rc.amount);
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001, 'Delete_Unpayed_Acc: ' || SQLERRM);
  END delete_unpayed_acc;
  ----========================================================================----
  -- ��������: � ����� ������������� �������� �� ������� ���� ����� �� ��������
  -- "������"
  PROCEDURE check_fix_trans_status(par_policy_id NUMBER) IS
    v_msg VARCHAR2(500);
    v_exeption EXCEPTION;
    v_num NUMBER;
  BEGIN
    SELECT COUNT(*)
      INTO v_num
      FROM p_pol_decline   pd
          ,p_trans_decline td
     WHERE pd.p_policy_id = par_policy_id
       AND pd.p_pol_decline_id = td.p_pol_decline_id
       AND doc.get_doc_status_brief(td.p_trans_decline_id, SYSDATE) = 'PROJECT';
    IF nvl(v_num, 0) > 0
    THEN
      v_msg := '��� ����� �������� � ����� ������������� �������� ' ||
               '�� ������� ���� ����� �� �������� "������"';
      RAISE v_exeption;
    END IF;
  EXCEPTION
    WHEN v_exeption THEN
      raise_application_error(-20002, v_msg);
    WHEN OTHERS THEN
      raise_application_error(-20001, 'Check_Fix_Trans_Status: ' || SQLERRM);
  END check_fix_trans_status;
  ----========================================================================----
  -- �������� / ������������� ������ ������ �������� �������� �� ����������� �� -
  -- ( �� ���� ���� )
  PROCEDURE del_main_trans_group_1(par_p_policy_id NUMBER) IS
    CURSOR trans_curs(pcurs_p_policy_id NUMBER) IS
      SELECT o.oper_id
            ,
             --t.is_closed,
             pkg_period_closed.check_date_in_closed(t.trans_date) is_closed
            , --273031: ��������� �������� �������� ��������� ������� /������/
             t.trans_date
        FROM oper  o
            ,trans t
       WHERE o.document_id = pcurs_p_policy_id
         AND t.oper_id = o.oper_id
         AND o.oper_templ_id IN (SELECT oper_templ_id
                                   FROM oper_templ
                                  WHERE brief IN ('QUIT_MAIN_1'
                                                 , -- ������������� ����������� ������ � �������� ������� ��� 91.02 77.01.01
                                                  'QUIT_MAIN_2'
                                                 , -- ������ ����������� ������ � �������� �������� ���� 77.01.01 92.01
                                                  'QUIT_MAIN_3'
                                                 , -- ���������� �������� ����� 22.05.31 77.00.14
                                                  'QUIT_MAIN_4'
                                                 , -- ���������� ��������������� ��������������� ������ 22.05.33 77.00.14
                                                  'QUIT_MAIN_5'
                                                 , -- �������� ������� �� ��� ����������� �� 22.05.11 77.00.13
                                                  'QUIT_MAIN_5_ANNUL'
                                                 , -- �������� ������� �� ��� ����������� �� (��� �������������) 77.01.01 77.00.13
                                                  'QUIT_MAIN_6'
                                                 , -- ����� �� 77.00.14 77.01.03
                                                  'QUIT_MAIN_7'
                                                 , -- ������� ������� ��� 77.00.14 77.01.03
                                                  'QUIT_MAIN_8'
                                                 , -- ������� ������� ���� 77.00.13 77.01.03
                                                  'QUIT_MAIN_16'
                                                 , -- ��������� ��� ���� �� ��������� ������ 22.05.11 77.00.13
                                                  'QUIT_MAIN_17'
                                                 , -- ��������� �� �������� 77.01.03 77.00.13
                                                  'QUIT_MAIN_13'
                                                 , -- ������� ������� �� � ��� 77.00.14 77.00.02
                                                  'QUIT_MAIN_14' -- ������� ������� ���� 2 77.00.13 77.00.02
                                                  -- ������ �.
                                                  -- ������� ����� ������
                                                 ,'QUIT_MAIN_19' -- ���������� ���� 77.01.01 91.01.19
                                                  ))
            -- �������� ������, ����� ��� �������������� �������� �������������� ��� ���
         AND NOT EXISTS (SELECT NULL
                FROM trans tr
                    ,oper  op
               WHERE tr.oper_id = op.oper_id
                 AND op.document_id = o.document_id
                 AND tr.note = '������ ��������: ' || to_char(t.trans_id));
  BEGIN
    -- ����������� �����������: ���� �������� - ���� ��������
    FOR trans_rec IN trans_curs(par_p_policy_id)
    LOOP
      IF trans_rec.is_closed = 1
      THEN
        -- �������������
        acc_new.storno_trans(trans_rec.oper_id);
      ELSE
        -- ��������
        DELETE FROM oper WHERE oper_id = trans_rec.oper_id;
      END IF;
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001, 'Del_Main_Trans_Group_1: ' || SQLERRM);
  END del_main_trans_group_1;
  ----========================================================================----
  -- �������� / ������������� ������ ������ �������� �������� �� ����������� �� -
  -- ( ��������� )
  PROCEDURE del_main_trans_group_2(par_p_policy_id NUMBER) IS
    CURSOR trans_curs(pcurs_p_policy_id NUMBER) IS
      SELECT o.oper_id
            ,
             --t.is_closed,
             pkg_period_closed.check_date_in_closed(t.trans_date) is_closed
            , --273031: ��������� �������� �������� ��������� ������� /������/
             t.trans_date
        FROM oper  o
            ,trans t
       WHERE o.document_id = pcurs_p_policy_id
         AND t.oper_id = o.oper_id
         AND o.oper_templ_id IN (SELECT oper_templ_id
                                   FROM oper_templ
                                  WHERE brief IN ('QUIT_MAIN_12'
                                                 , -- ������� ���� 77.00.14 68.02 ���� ���������� ����
                                                  'QUIT_MAIN_15'
                                                 , -- ��������� 77.00.02 51 ���� �������
                                                  'QUIT_MAIN_18' -- ������������� � ������ ����
                                                  ))
            -- ������ �.
            -- �������� ������, ����� ��� �������������� �������� �������������� ��� ���
         AND NOT EXISTS (SELECT NULL
                FROM trans tr
                    ,oper  op
               WHERE tr.oper_id = op.oper_id
                 AND op.document_id = o.document_id
                 AND tr.note = '������ ��������: ' || to_char(t.trans_id));
  BEGIN
    -- ����������� �����������: ���� �������� - ���� ��������
    FOR trans_rec IN trans_curs(par_p_policy_id)
    LOOP
      IF trans_rec.is_closed = 1
      THEN
        -- �������������
        acc_new.storno_trans(trans_rec.oper_id);
      ELSE
        -- ��������
        DELETE FROM oper WHERE oper_id = trans_rec.oper_id;
      END IF;
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001, 'Del_Main_Trans_Group_2: ' || SQLERRM);
  END del_main_trans_group_2;
  ----========================================================================----
  -- ������� ���������� ��������� ( ���� ) ��� ��������
  FUNCTION get_trans_plo_desc(p_trans_id NUMBER) RETURN VARCHAR2 IS
    CURSOR trans_curs(pcurs_trans_id NUMBER) IS
      SELECT obj_ure_id
            ,obj_uro_id
            ,a1_dt_ure_id
            ,a1_dt_uro_id
            ,a1_ct_ure_id
            ,a1_ct_uro_id
            ,a2_dt_ure_id
            ,a2_dt_uro_id
            ,a2_ct_ure_id
            ,a2_ct_uro_id
            ,a3_dt_ure_id
            ,a3_dt_uro_id
            ,a3_ct_ure_id
            ,a3_ct_uro_id
            ,a4_dt_ure_id
            ,a4_dt_uro_id
            ,a4_ct_ure_id
            ,a4_ct_uro_id
            ,a5_dt_ure_id
            ,a5_dt_uro_id
            ,a5_ct_ure_id
            ,a5_ct_uro_id
        FROM trans
       WHERE trans_id = pcurs_trans_id;
    v_obj_ure_id   NUMBER;
    v_obj_uro_id   NUMBER;
    v_a1_dt_ure_id NUMBER;
    v_a1_dt_uro_id NUMBER;
    v_a1_ct_ure_id NUMBER;
    v_a1_ct_uro_id NUMBER;
    v_a2_dt_ure_id NUMBER;
    v_a2_dt_uro_id NUMBER;
    v_a2_ct_ure_id NUMBER;
    v_a2_ct_uro_id NUMBER;
    v_a3_dt_ure_id NUMBER;
    v_a3_dt_uro_id NUMBER;
    v_a3_ct_ure_id NUMBER;
    v_a3_ct_uro_id NUMBER;
    v_a4_dt_ure_id NUMBER;
    v_a4_dt_uro_id NUMBER;
    v_a4_ct_ure_id NUMBER;
    v_a4_ct_uro_id NUMBER;
    v_a5_dt_ure_id NUMBER;
    v_a5_dt_uro_id NUMBER;
    v_a5_ct_ure_id NUMBER;
    v_a5_ct_uro_id NUMBER;
    v_cover_ent_id NUMBER;
    v_plo_ent_id   NUMBER;
    v_cover_id     NUMBER;
    v_plo_id       NUMBER;
    v_return       VARCHAR2(255) := '';
  BEGIN
    SELECT ent_id INTO v_cover_ent_id FROM entity WHERE brief = 'P_COVER';
    SELECT ent_id INTO v_plo_ent_id FROM entity WHERE brief = 'T_PROD_LINE_OPTION';
    OPEN trans_curs(p_trans_id);
    FETCH trans_curs
      INTO v_obj_ure_id
          ,v_obj_uro_id
          ,v_a1_dt_ure_id
          ,v_a1_dt_uro_id
          ,v_a1_ct_ure_id
          ,v_a1_ct_uro_id
          ,v_a2_dt_ure_id
          ,v_a2_dt_uro_id
          ,v_a2_ct_ure_id
          ,v_a2_ct_uro_id
          ,v_a3_dt_ure_id
          ,v_a3_dt_uro_id
          ,v_a3_ct_ure_id
          ,v_a3_ct_uro_id
          ,v_a4_dt_ure_id
          ,v_a4_dt_uro_id
          ,v_a4_ct_ure_id
          ,v_a4_ct_uro_id
          ,v_a5_dt_ure_id
          ,v_a5_dt_uro_id
          ,v_a5_ct_ure_id
          ,v_a5_ct_uro_id;
    CLOSE trans_curs;
    IF v_obj_ure_id = v_cover_ent_id
       AND v_obj_uro_id IS NOT NULL
    THEN
      v_cover_id := v_obj_uro_id;
      --
    ELSIF v_a1_dt_ure_id = v_plo_ent_id
          AND v_a1_dt_uro_id IS NOT NULL
    THEN
      v_plo_id := v_a1_dt_uro_id;
    ELSIF v_a2_dt_ure_id = v_plo_ent_id
          AND v_a2_dt_uro_id IS NOT NULL
    THEN
      v_plo_id := v_a2_dt_uro_id;
    ELSIF v_a3_dt_ure_id = v_plo_ent_id
          AND v_a3_dt_uro_id IS NOT NULL
    THEN
      v_plo_id := v_a3_dt_uro_id;
    ELSIF v_a4_dt_ure_id = v_plo_ent_id
          AND v_a4_dt_uro_id IS NOT NULL
    THEN
      v_plo_id := v_a4_dt_uro_id;
    ELSIF v_a5_dt_ure_id = v_plo_ent_id
          AND v_a5_dt_uro_id IS NOT NULL
    THEN
      v_plo_id := v_a5_dt_uro_id;
      --
    ELSIF v_a1_ct_ure_id = v_plo_ent_id
          AND v_a1_ct_uro_id IS NOT NULL
    THEN
      v_plo_id := v_a1_ct_uro_id;
    ELSIF v_a2_ct_ure_id = v_plo_ent_id
          AND v_a2_ct_uro_id IS NOT NULL
    THEN
      v_plo_id := v_a2_ct_uro_id;
    ELSIF v_a3_ct_ure_id = v_plo_ent_id
          AND v_a3_ct_uro_id IS NOT NULL
    THEN
      v_plo_id := v_a3_ct_uro_id;
    ELSIF v_a4_ct_ure_id = v_plo_ent_id
          AND v_a4_ct_uro_id IS NOT NULL
    THEN
      v_plo_id := v_a4_ct_uro_id;
    ELSIF v_a5_ct_ure_id = v_plo_ent_id
          AND v_a5_ct_uro_id IS NOT NULL
    THEN
      v_plo_id := v_a5_ct_uro_id;
      --
    ELSIF v_a1_dt_ure_id = v_cover_ent_id
          AND v_a1_dt_uro_id IS NOT NULL
    THEN
      v_cover_id := v_a1_dt_uro_id;
    ELSIF v_a2_dt_ure_id = v_cover_ent_id
          AND v_a2_dt_uro_id IS NOT NULL
    THEN
      v_cover_id := v_a2_dt_uro_id;
    ELSIF v_a3_dt_ure_id = v_cover_ent_id
          AND v_a3_dt_uro_id IS NOT NULL
    THEN
      v_cover_id := v_a3_dt_uro_id;
    ELSIF v_a4_dt_ure_id = v_cover_ent_id
          AND v_a4_dt_uro_id IS NOT NULL
    THEN
      v_cover_id := v_a4_dt_uro_id;
    ELSIF v_a5_dt_ure_id = v_cover_ent_id
          AND v_a5_dt_uro_id IS NOT NULL
    THEN
      v_cover_id := v_a5_dt_uro_id;
      --
    ELSIF v_a1_ct_ure_id = v_cover_ent_id
          AND v_a1_ct_uro_id IS NOT NULL
    THEN
      v_cover_id := v_a1_ct_uro_id;
    ELSIF v_a2_ct_ure_id = v_cover_ent_id
          AND v_a2_ct_uro_id IS NOT NULL
    THEN
      v_cover_id := v_a2_ct_uro_id;
    ELSIF v_a3_ct_ure_id = v_cover_ent_id
          AND v_a3_ct_uro_id IS NOT NULL
    THEN
      v_cover_id := v_a3_ct_uro_id;
    ELSIF v_a4_ct_ure_id = v_cover_ent_id
          AND v_a4_ct_uro_id IS NOT NULL
    THEN
      v_cover_id := v_a4_ct_uro_id;
    ELSIF v_a5_ct_ure_id = v_cover_ent_id
          AND v_a5_ct_uro_id IS NOT NULL
    THEN
      v_cover_id := v_a5_ct_uro_id;
    END IF;
    IF v_plo_id IS NOT NULL
    THEN
      SELECT description INTO v_return FROM t_prod_line_option WHERE id = v_plo_id;
    ELSIF v_cover_id IS NOT NULL
    THEN
      SELECT plo.description
        INTO v_return
        FROM t_prod_line_option plo
            ,p_cover            c
       WHERE c.p_cover_id = v_cover_id
         AND c.t_prod_line_option_id = plo.id;
    END IF;
    RETURN(v_return);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN(NULL);
  END get_trans_plo_desc;
  ----========================================================================----
  /*
    ������ �.
    �������� ����� ������ �� ������: '22.05','22.01','22.05.01','22.05.02','22.05.11','22.05.31','22.05.33',
                                     '77.00.01','77.00.02','77.08.03','91.01','91.02','92.01'
    ���� ������ ���������� �� 0, �������� ��������� �� ����, � ��������� �����
    � Borlas: "����������� ��. �������� ������"

    par_policy_id - �� ������ ��
  */
  /*  PROCEDURE check_saldo(par_policy_id NUMBER) IS
      v_pol_header_id NUMBER;
      v_result        NUMBER;
    BEGIN
      SELECT pp.pol_header_id INTO v_pol_header_id FROM p_policy pp WHERE pp.policy_id = par_policy_id;

      SELECT nvl(SUM(acc_amount), 0)
        INTO v_result
        FROM ( -- �������� ����������� ����� �����
              SELECT tr.trans_amount AS acc_amount
                FROM p_policy   p
                     ,as_asset   a
                     ,as_assured ur
                     ,p_cover    pc
                     ,trans      tr
                     ,account    ac
               WHERE p.policy_id = a.p_policy_id
                 AND a.as_asset_id = ur.as_assured_id
                 AND a.as_asset_id = pc.as_asset_id
                 AND tr.obj_uro_id = pc.p_cover_id
                 AND tr.obj_ure_id = pc.ent_id
                 AND tr.dt_account_id = ac.account_id
                 AND ac.num IN ('22.05'
                               ,'22.01'
                               ,'22.05.01'
                               ,'22.05.02'
                               ,'22.05.11'
                               ,'22.05.31'
                               ,'22.05.33'
                               ,'77.00.01'
                               ,'77.00.02'
                               ,'77.08.03'
                               ,'91.01'
                               ,'91.02'
                               ,'92.01'
                               ,'91.01.19'
                               ,'77.07.01')
                 AND p.pol_header_id = v_pol_header_id
              UNION ALL
              SELECT -tr.trans_amount AS acc_amount
                FROM p_policy   p
                     ,as_asset   a
                     ,as_assured ur
                     ,p_cover    pc
                     ,trans      tr
                     ,account    ac
               WHERE p.policy_id = a.p_policy_id
                 AND a.as_asset_id = ur.as_assured_id
                 AND a.as_asset_id = pc.as_asset_id
                 AND tr.obj_uro_id = pc.p_cover_id
                 AND tr.obj_ure_id = pc.ent_id
                 AND tr.ct_account_id = ac.account_id
                 AND ac.num IN ('22.05'
                               ,'22.01'
                               ,'22.05.01'
                               ,'22.05.02'
                               ,'22.05.11'
                               ,'22.05.31'
                               ,'22.05.33'
                               ,'77.00.01'
                               ,'77.00.02'
                               ,'77.08.03'
                               ,'91.01'
                               ,'91.02'
                               ,'92.01'
                               ,'91.01.19'
                               ,'77.07.01')
                 AND p.pol_header_id = v_pol_header_id
              UNION ALL
              -- ��������, ����������� ����� ������ (�����������)
              SELECT tr.trans_amount
                FROM trans    tr
                     ,p_policy p
                     ,account  ac
               WHERE p.pol_header_id = v_pol_header_id
                 AND tr.dt_account_id = ac.account_id
                 AND tr.obj_ure_id = 283
                 AND tr.obj_uro_id = p.policy_id
                 AND ac.num IN ('22.05'
                               ,'22.01'
                               ,'22.05.01'
                               ,'22.05.02'
                               ,'22.05.11'
                               ,'22.05.31'
                               ,'22.05.33'
                               ,'77.00.01'
                               ,'77.00.02'
                               ,'77.08.03'
                               ,'91.01'
                               ,'91.02'
                               ,'92.01'
                               ,'91.01.19'
                               ,'77.07.01')
              UNION ALL
              SELECT -tr.trans_amount
                FROM trans    tr
                     ,p_policy p
                     ,account  ac
               WHERE p.pol_header_id = v_pol_header_id
                 AND tr.ct_account_id = ac.account_id
                 AND tr.obj_ure_id = 283
                 AND tr.obj_uro_id = p.policy_id
                 AND ac.num IN ('22.05'
                               ,'22.01'
                               ,'22.05.01'
                               ,'22.05.02'
                               ,'22.05.11'
                               ,'22.05.31'
                               ,'22.05.33'
                               ,'77.00.01'
                               ,'77.00.02'
                               ,'77.08.03'
                               ,'91.01'
                               ,'91.02'
                               ,'92.01'
                               ,'91.01.19'
                               ,'77.07.01')
              UNION ALL
              -- ��������, ����������� ����� �����
              SELECT tr.trans_amount
                FROM p_policy   p
                     ,as_asset   a
                     ,as_assured ur
                     ,p_cover    pc
                     ,trans      tr
                     ,account    ac
                     ,c_damage   dm
               WHERE p.policy_id = a.p_policy_id
                 AND a.as_asset_id = ur.as_assured_id
                 AND a.as_asset_id = pc.as_asset_id
                 AND pc.p_cover_id = dm.p_cover_id
                 AND tr.obj_uro_id = dm.c_damage_id
                 AND tr.obj_ure_id = dm.ent_id
                 AND tr.dt_account_id = ac.account_id
                 AND ac.num IN ('22.05'
                               ,'22.01'
                               ,'22.05.01'
                               ,'22.05.02'
                               ,'22.05.11'
                               ,'22.05.31'
                               ,'22.05.33'
                               ,'77.00.01'
                               ,'77.00.02'
                               ,'77.08.03'
                               ,'91.01'
                               ,'91.02'
                               ,'92.01'
                               ,'91.01.19'
                               ,'77.07.01')
                 AND p.pol_header_id = v_pol_header_id
              UNION ALL
              SELECT -tr.trans_amount
                FROM p_policy   p
                     ,as_asset   a
                     ,as_assured ur
                     ,p_cover    pc
                     ,trans      tr
                     ,account    ac
                     ,c_damage   dm
               WHERE p.policy_id = a.p_policy_id
                 AND a.as_asset_id = ur.as_assured_id
                 AND a.as_asset_id = pc.as_asset_id
                 AND pc.p_cover_id = dm.p_cover_id
                 AND tr.obj_uro_id = dm.c_damage_id
                 AND tr.obj_ure_id = dm.ent_id
                 AND tr.ct_account_id = ac.account_id
                 AND ac.num IN ('22.05'
                               ,'22.01'
                               ,'22.05.01'
                               ,'22.05.02'
                               ,'22.05.11'
                               ,'22.05.31'
                               ,'22.05.33'
                               ,'77.00.01'
                               ,'77.00.02'
                               ,'77.08.03'
                               ,'91.01'
                               ,'91.02'
                               ,'92.01'
                               ,'91.01.19'
                               ,'77.07.01')
                 AND p.pol_header_id = v_pol_header_id);
      IF v_result != 0
      THEN
        raise_application_error(-20001
                               ,'����� ������ �� ������: 22.05,22.01,22.05.01,22.05.02,22.05.11,22.05.31,22.05.33' ||
                                ',77.00.01,77.00.02,77.08.03,91.01,91.02,92.01,91.01.19,77.07.01 ����� ' ||
                                to_char(v_result));
      END IF;
    END check_saldo;
  */

  /**
  * ����������� ��. ������������� ������ �� ��������
  * � �����������. ����� ��� �������� - � �����������. ��������
  * ��������� ���������� ���������� ������ �� �������� � ������� ��������, ����� ���������� �� ����
  * � ��������� ����� ������� �� ������� �� �����, ��� �� ��������� �������� ������� �.�. ������ ����
  * ������ ������ � ����
  * @author ����� �.
  * @param par_policy_id - �� ������ �����������
  */
  PROCEDURE correct_saldo_on_quit(par_policy_id NUMBER) IS
    v_pol_header_id     NUMBER;
    v_dummy             NUMBER;
    v_doc_status_ref_id NUMBER;
    v_amount            NUMBER;
    c_positive_saldo_ot_id CONSTANT NUMBER := dml_oper_templ.get_id_by_brief('�������.�����.����.�����.���');
    c_negative_saldo_ot_id CONSTANT NUMBER := dml_oper_templ.get_id_by_brief('�������.�����.����.�����.���');
  BEGIN
    v_pol_header_id     := pkg_policy.get_policy_header_id(par_policy_id);
    v_doc_status_ref_id := doc.get_last_doc_status_ref_id(par_policy_id);

    -- � ������������ ������� �� ��������. ������� ������� �������� �� �� �������� �������.
    -- �� � ���������� ����� ����� �������� �� ����������
    FOR rec IN (SELECT MAX(pc.p_cover_id) p_cover_id
                      ,SUM(t.acc_amount *
                           -- �������, ������� ��������� ����������
                           CASE
                             WHEN tt.brief IN ('�����������������������' --44
                                              ,'�������' --47
                                              ,'�����������������������' --741
                                              ,'QUIT_MAIN_6' --810
                                              ,'QUIT_MAIN_7' --811
                                              ,'QUIT_MAIN_8' --812
                                              ,'QUIT_MAIN_5_ANNUL' --861
                                              --,'QUIT_MAIN_5' --809
                                               )

                              THEN
                              -1
                             ELSE
                              1
                           END *
                           -- �������� �������� � �������� ����, ������� �� ���� �������� � ��������� �����, ����� ��������� �����
                           CASE
                             WHEN
                              tt.brief IN ('Storno.NachPrem' --782
                                          ,'QUIT_MAIN_1' --805
                                          ,'QUIT_FIX_33' --849
                                          ,'QUIT_MAIN_5_ANNUL' --861
                                          --,'QUIT_MAIN_5' --809
                                          ,'�����������.�����������������������' --1037??
                                          ,'�����������.����������������' --1039??
                                           ) THEN
                              -1
                             ELSE
                              1
                           END) AS amount
                  FROM trans_templ  tt
                      ,trans        t
                      ,oper         o
                      ,oper_templ   ot
                      ,p_policy     pp
                      ,as_asset     aa
                      ,p_cover      pc
                      ,v_pol_issuer pi
                 WHERE (tt.brief IN ('QUIT_FIX_33' --849
                                    ,'QUIT_MAIN_1' --805
                                    ,'QUIT_MAIN_17 ' --821
                                    ,'QUIT_MAIN_2' --806
                                    --,'QUIT_MAIN_5' --809
                                    ,'QUIT_MAIN_5_ANNUL' --861
                                    ,'QUIT_MAIN_6' --810
                                    ,'QUIT_MAIN_7' --811
                                    ,'QUIT_MAIN_8' --812
                                    ,'Storno.NachPrem' --782
                                    ,'���������' --21
                                    ,'�������������� ' --848
                                    ,'�����������������������' --741
                                    ,'�������' --47
                                    ,'�����������.�����������������������' --1037??
                                    ,'�����������.��������������������' --1038??
                                    ,'�����������.����������������' --1039??
                                     ) OR
                       tt.brief = '�����������������������' --44
                       AND
                       t.dt_account_id = (SELECT a.account_id FROM account a WHERE a.num = '77.00.01') AND
                       t.ct_account_id = (SELECT a.account_id FROM account a WHERE a.num = '77.01.02'))
                   AND tt.trans_templ_id = t.trans_templ_id
                   AND t.oper_id = o.oper_id
                   AND o.oper_templ_id = ot.oper_templ_id
                   AND t.a5_ct_ure_id = 305
                   AND t.a5_ct_uro_id = pc.p_cover_id
                   AND pc.as_asset_id = aa.as_asset_id
                   AND aa.p_policy_id = pp.policy_id
                   AND pp.policy_id = pi.policy_id
                   AND pp.pol_header_id = v_pol_header_id
                 GROUP BY pc.t_prod_line_option_id
                         ,aa.p_asset_header_id)
    LOOP
      IF rec.amount < 0
      THEN
        --�� 77.01.01 �� 91.01
        v_dummy := acc_new.run_oper_by_template(c_negative_saldo_ot_id
                                               ,par_policy_id
                                               ,dml_p_cover.get_entity_id
                                               ,rec.p_cover_id
                                               ,v_doc_status_ref_id
                                               ,1
                                               ,rec.amount * -1);
      ELSIF rec.amount > 0
      THEN
        --�� 91.02 �� 77.01.01
        v_dummy := acc_new.run_oper_by_template(c_positive_saldo_ot_id
                                               ,par_policy_id
                                               ,dml_p_cover.get_entity_id
                                               ,rec.p_cover_id
                                               ,v_doc_status_ref_id
                                               ,1
                                               ,rec.amount);
      END IF;

    END LOOP;
  END correct_saldo_on_quit;
  /*
    ������ �.
    �������� ������������� �������� �� ������ 22.01, 22.05.01, 22.05.02 � ������ ��������� �� ������,
    ���� ����� �������� ����������.
    par_policy_id - �� ������ �������� �����������
  */
  PROCEDURE check_accounts(par_policy_id NUMBER) IS
    v_cnt           NUMBER;
    v_pol_header_id NUMBER;
    v_policy_ent_id NUMBER;
  BEGIN
    SELECT pp.pol_header_id INTO v_pol_header_id FROM p_policy pp WHERE pp.policy_id = par_policy_id;

    BEGIN
      SELECT e.ent_id
        INTO v_policy_ent_id
        FROM entity e
       WHERE e.brief = 'P_POLICY'
         AND e.schema_name = 'INS';
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20001
                               ,'����������� ������ � ����������� ������������� "P_POLICY" � ����������� ���������!');
    END;

    SELECT COUNT(1)
      INTO v_cnt
      FROM dual
     WHERE EXISTS ( -- �������� ����������� ����� �����
            SELECT tr.trans_amount AS acc_amount
              FROM p_policy   p
                   ,as_asset   a
                   ,as_assured ur
                   ,p_cover    pc
                   ,trans      tr
                   ,account    ac
             WHERE p.policy_id = a.p_policy_id
               AND a.as_asset_id = ur.as_assured_id
               AND a.as_asset_id = pc.as_asset_id
               AND tr.obj_uro_id = pc.p_cover_id
               AND tr.obj_ure_id = pc.ent_id
               AND tr.dt_account_id = ac.account_id
               AND ac.num IN ('22.01', '22.05.01', '22.05.02')
               AND p.pol_header_id = v_pol_header_id
            UNION ALL
            SELECT -tr.trans_amount AS acc_amount
              FROM p_policy   p
                   ,as_asset   a
                   ,as_assured ur
                   ,p_cover    pc
                   ,trans      tr
                   ,account    ac
             WHERE p.policy_id = a.p_policy_id
               AND a.as_asset_id = ur.as_assured_id
               AND a.as_asset_id = pc.as_asset_id
               AND tr.obj_uro_id = pc.p_cover_id
               AND tr.obj_ure_id = pc.ent_id
               AND tr.ct_account_id = ac.account_id
               AND ac.num IN ('22.01', '22.05.01', '22.05.02')
               AND p.pol_header_id = v_pol_header_id
            UNION ALL
            -- ��������, ����������� ����� ������ (�����������)
            SELECT tr.trans_amount
              FROM trans    tr
                   ,p_policy p
                   ,account  ac
             WHERE p.pol_header_id = v_pol_header_id
               AND tr.dt_account_id = ac.account_id
               AND tr.obj_ure_id = v_policy_ent_id
               AND tr.obj_uro_id = p.policy_id
               AND ac.num IN ('22.01', '22.05.01', '22.05.02')
            UNION ALL
            SELECT -tr.trans_amount
              FROM trans    tr
                   ,p_policy p
                   ,account  ac
             WHERE p.pol_header_id = v_pol_header_id
               AND tr.ct_account_id = ac.account_id
               AND tr.obj_ure_id = v_policy_ent_id
               AND tr.obj_uro_id = p.policy_id
               AND ac.num IN ('22.01', '22.05.01', '22.05.02')
            UNION ALL
            -- ��������, ����������� ����� �����
            SELECT tr.trans_amount
              FROM p_policy   p
                   ,as_asset   a
                   ,as_assured ur
                   ,p_cover    pc
                   ,trans      tr
                   ,account    ac
                   ,c_damage   dm
             WHERE p.policy_id = a.p_policy_id
               AND a.as_asset_id = ur.as_assured_id
               AND a.as_asset_id = pc.as_asset_id
               AND pc.p_cover_id = dm.p_cover_id
               AND tr.obj_uro_id = dm.c_damage_id
               AND tr.obj_ure_id = dm.ent_id
               AND tr.dt_account_id = ac.account_id
               AND ac.num IN ('22.01', '22.05.01', '22.05.02')
               AND p.pol_header_id = v_pol_header_id
            UNION ALL
            SELECT -tr.trans_amount
              FROM p_policy   p
                   ,as_asset   a
                   ,as_assured ur
                   ,p_cover    pc
                   ,trans      tr
                   ,account    ac
                   ,c_damage   dm
             WHERE p.policy_id = a.p_policy_id
               AND a.as_asset_id = ur.as_assured_id
               AND a.as_asset_id = pc.as_asset_id
               AND pc.p_cover_id = dm.p_cover_id
               AND tr.obj_uro_id = dm.c_damage_id
               AND tr.obj_ure_id = dm.ent_id
               AND tr.ct_account_id = ac.account_id
               AND ac.num IN ('22.01', '22.05.01', '22.05.02')
               AND p.pol_header_id = v_pol_header_id);

    -- ���� ������� ����� ��������, ������� ������
    IF v_cnt = 1
    THEN
      raise_application_error(-20001
                             ,'���������� �������� �� ������ 22.01, 22.05.01 � 22.05.02. ��������� �� ������������.');
    END IF;
  END check_accounts;

  /*
    ������ �.
    ������ �������� ������������� ��������--, �� ��������� � ����������
    par_policy_id - �� ������ �������� �����������
  */
  PROCEDURE cancel_corr_trans(par_policy_id NUMBER) IS
    v_sysdate DATE := SYSDATE;
  BEGIN
    FOR r_trans IN (SELECT td.p_trans_decline_id
                      FROM p_trans_decline td
                          ,p_pol_decline   pd
                     WHERE td.p_pol_decline_id = pd.p_pol_decline_id
                       AND pd.p_policy_id = par_policy_id
                       AND doc.get_doc_status_brief(td.p_trans_decline_id) = 'CLOSE'
                    /*and not exists (select null
                       from oper op
                      where td.p_trans_decline_id = op.document_id
                    )*/
                    )
    LOOP
      doc.set_doc_status(r_trans.p_trans_decline_id, 'CANCEL', v_sysdate);
      v_sysdate := v_sysdate + INTERVAL '1' SECOND;
    END LOOP;
  END cancel_corr_trans;

  /*
    ������ �.
    ���������� �������������� ��������

    par_pol_decline_id   - �� ������ �� ����������� ������ ��
    par_p_cover_id       - �� ��������
    par_oper_templ_brief - ���������� ������� ��������
    par_doc_templ_brief  - ���������� ������� ���������
    par_trans_sum        - ����� ��������
    par_trans_date       - ���� ��������
    par_status_date      - ���� �������� �������
    par_trans_id         - �� ��������� �������� (��������)
  */
  PROCEDURE insert_corr_trans
  (
    par_pol_decline_id   NUMBER
   ,par_p_cover_id       NUMBER
   ,par_oper_templ_brief VARCHAR2
   ,par_doc_templ_brief  VARCHAR2
   ,par_trans_sum        NUMBER
   ,par_trans_date       DATE
   ,par_status_date      DATE DEFAULT SYSDATE
   ,par_trans_id         OUT NUMBER
  ) IS
    v_oper_templ_id oper_templ.oper_templ_id%TYPE;
    v_doc_templ_id  doc_templ.doc_templ_id%TYPE;
  BEGIN
    IF par_trans_sum != 0
    THEN
      -- ��������� �� ������� ��������
      SELECT ot.oper_templ_id
        INTO v_oper_templ_id
        FROM oper_templ ot
       WHERE ot.brief = par_oper_templ_brief;

      -- ��������� �� ������� ���������
      SELECT doc_templ_id INTO v_doc_templ_id FROM doc_templ WHERE brief = par_doc_templ_brief;
      -- ���������� ��������
      SELECT sq_document.nextval INTO par_trans_id FROM dual;
      INSERT INTO ven_p_trans_decline
        (p_trans_decline_id
        ,p_pol_decline_id
        ,p_cover_id
        ,oper_templ_id
        ,trans_sum
        ,trans_date
        ,doc_templ_id)
      VALUES
        (par_trans_id
        ,par_pol_decline_id
        ,par_p_cover_id
        ,v_oper_templ_id
        ,par_trans_sum
        ,par_trans_date
        ,v_doc_templ_id);
      -- ��������� ������� �� "������"
      doc.set_doc_status(par_trans_id, 'PROJECT', par_status_date);
    END IF;
  END insert_corr_trans;

  /*
    ������ �.
    �������� ������� ���������� ���������� ��� �������� �� � ������ "���������. � �������"
    � Borlas: "����������� ��. �������� ������� ���������� ����������"
    par_p_policy_id - ID ������ ��
  */
  PROCEDURE check_payment_request(par_p_policy_id NUMBER) IS
    v_cnt NUMBER;
  BEGIN
    SELECT COUNT(1)
      INTO v_cnt
      FROM dual
     WHERE EXISTS (SELECT NULL
              FROM ac_payment       ac
                  ,ac_payment_templ act
                  ,document         doc
                  ,doc_templ        dt
                  ,doc_doc          dd
             WHERE dd.parent_id = par_p_policy_id
               AND ac.payment_id = dd.child_id
               AND ac.payment_id = doc.document_id
               AND doc.doc_templ_id = dt.doc_templ_id
               AND ac.payment_templ_id = act.payment_templ_id
               AND act.brief = 'PAYREQ'
               AND dt.brief = 'PAYREQ');
    IF v_cnt = 0
    THEN
      raise_application_error(-20001
                             ,'�� ������� �� ������ ���������� ����������!');
    END IF;
  END check_payment_request;

  /**
   * �������� ���������� �����������, ���� ��� ��� (�� �������� �������� "���������. ��������� ��������"-"���������. � �������"
   * @author  ������ �. 30.1.2015
   -- %param par_policy_id  �� ������ ��
  */
  PROCEDURE create_payment_request(par_p_policy_id NUMBER) IS
    v_cnt        NUMBER;
    v_payment_id NUMBER;
  BEGIN
    SELECT COUNT(1)
      INTO v_cnt
      FROM dual
     WHERE EXISTS (SELECT NULL
              FROM ac_payment       ac
                  ,ac_payment_templ act
                  ,document         doc
                  ,doc_templ        dt
                  ,doc_doc          dd
             WHERE dd.parent_id = par_p_policy_id
               AND ac.payment_id = dd.child_id
               AND ac.payment_id = doc.document_id
               AND doc.doc_templ_id = dt.doc_templ_id
               AND ac.payment_templ_id = act.payment_templ_id
               AND act.brief = 'PAYREQ'
               AND dt.brief = 'PAYREQ');
    IF v_cnt = 0
    THEN
      --��������� ��������� ����������
      v_payment_id := pkg_decline.create_decline_payreq(par_p_policy_id);

    END IF;
  END create_payment_request;

  /*
    ������ �.
    ������������ ���������� �� ��� �������� ��������� � ������ "���������.� �������"
    � Borlas: "����������� ��. ������������ ���. ��"
    par_p_policy_id - ID ������ ��
  */
  PROCEDURE make_outgoing_bank_doc(par_p_policy_id NUMBER) IS
    v_next_num              document.num%TYPE;
    v_doc_date              DATE;
    v_redemption_sum_cur    NUMBER;
    v_add_invest_income_cur NUMBER;
    v_return_bonus_part_cur NUMBER;
    v_collection_method     t_collection_method.id%TYPE;
    v_contact_id            ac_payment.contact_id%TYPE;
    v_contact_bank_acc_id   ac_payment.contact_bank_acc_id%TYPE;
    v_fund_id               ac_payment.fund_id%TYPE;
    v_rev_rate              ac_payment.rev_rate%TYPE;
    v_rev_fund_id           ac_payment.rev_fund_id%TYPE;
    v_rate_type_id          rate_type.rate_type_id%TYPE;
    v_payment_templ_id      ac_payment_templ.payment_templ_id%TYPE;
    v_document_templ        doc_templ.doc_templ_id%TYPE;
    v_payment_terms_id      ac_payment.payment_terms_id%TYPE;
    v_payment_type_id       ac_payment.payment_type_id%TYPE;
    v_payment_direct_id     ac_payment.payment_direct_id%TYPE;
    v_note                  document.note%TYPE;
    v_payreq_note           document.note%TYPE;
    v_expense_date          DATE;
    v_expense_period        DATE;
    v_issuer_id             contact.contact_id%TYPE;
    v_owner_contact_id      contact.contact_id%TYPE;

    /* ���������� ��� */
    PROCEDURE insert_payment
    (
      par_sum_cur      NUMBER
     ,par_note         VARCHAR2
     ,par_expense_code NUMBER
     ,par_payreq_note  VARCHAR2
    ) IS
      v_payment_id ac_payment.payment_id%TYPE;
    BEGIN
      /* ID ������� */
      SELECT sq_ac_payment.nextval INTO v_payment_id FROM dual;

      /* ��� */
      INSERT INTO ven_ac_payment
        (payment_id
        ,doc_templ_id
        ,num
        ,reg_date
        ,amount
        ,collection_metod_id
        ,comm_amount
        ,company_bank_acc_id
        ,contact_id
        ,contact_bank_acc_id
        ,due_date
        ,fund_id
        ,grace_date
        ,is_agent
        ,payment_direct_id
        ,payment_number
        ,payment_templ_id
        ,payment_terms_id
        ,payment_type_id
        ,rev_amount
        ,rev_fund_id
        ,rev_rate
        ,rev_rate_type_id
        ,note)
      VALUES
        (v_payment_id
        ,v_document_templ
        ,to_char(v_next_num)
        ,v_doc_date
        ,par_sum_cur
        ,v_collection_method
        ,0
        ,24532 /* ���� ���������, ������ 26754595833811 � ��� "��������������" */
        ,v_contact_id
        ,v_contact_bank_acc_id
        ,v_doc_date
        ,v_fund_id
        ,v_doc_date
        ,0 /*�� ��������� ������*/
        ,v_payment_direct_id
        ,1 /*����� �������*/
        ,v_payment_templ_id
        ,v_payment_terms_id
        ,v_payment_type_id
        ,par_sum_cur * v_rev_rate
        ,v_rev_fund_id
        ,v_rev_rate
        ,CASE WHEN v_rev_rate != 1 THEN v_rate_type_id END /*�� ���� ����� ����������, ���� ���� = ��������, null*/
        ,par_note);

      /* ���. ���� */
      INSERT INTO ac_payment_add_info
        (ac_payment_add_info_id, expense_code, expense_date, expense_period, responsibility_center)
      VALUES
        (v_payment_id, par_expense_code, v_expense_date, v_expense_period, 'Operations');

      /*
         ����� �� � ���
         �����, ����� ���� �� ��������� �������, �.�. ��� ��������� ����� ������ � doc_doc
      */
      INSERT INTO ven_doc_doc
        (child_amount, child_fund_id, child_id, parent_amount, parent_fund_id, parent_id)
      VALUES
        (par_sum_cur * v_rev_rate
        ,v_rev_fund_id
        ,v_payment_id
        ,par_sum_cur
        ,v_fund_id
        ,par_p_policy_id);

      /* ������ ��� */

      doc.set_doc_status(v_payment_id
                        ,'NEW'
                        ,v_doc_date
                        ,'AUTO'
                        ,'�������� ���������');
      /*��������������� ������
      *171184: ��������� �� ������������ ��������������� ��������
      *doc.set_doc_status(v_payment_id, 'TRANS', v_doc_date+interval '1' second, 'AUTO', '�������������� ������� ���������');
      */

      --������ 183603 �������� ���� ���������� ������� � �������� �������
      UPDATE insi.gate_payments_out g
         SET g.payment_purpose = par_payreq_note
       WHERE g.ac_payment_id = v_payment_id;
      --183603
    END insert_payment;

    FUNCTION is_contact_individual(par_contact_id contact.contact_id%TYPE) RETURN BOOLEAN IS
      v_is_individual t_contact_type.is_individual%TYPE;
    BEGIN
      SELECT ct.is_individual
        INTO v_is_individual
        FROM contact        co
            ,t_contact_type ct
       WHERE co.contact_id = par_contact_id
         AND co.contact_type_id = ct.id;

      RETURN v_is_individual = 1;

    END is_contact_individual;

    FUNCTION is_rf_docs_exists(par_contact_id contact.contact_id%TYPE) RETURN BOOLEAN IS
      v_is_exists NUMBER(1);
    BEGIN
      SELECT COUNT(1)
        INTO v_is_exists
        FROM dual
       WHERE EXISTS (SELECT NULL
                FROM cn_contact_ident ci
                    ,t_id_type        ty
               WHERE ci.contact_id = par_contact_id
                 AND ci.id_type = ty.id
                 AND ty.brief IN ('PASS_RF')
                 AND ci.id_value IS NOT NULL
                 AND ci.serial_nr IS NOT NULL
                 AND ci.place_of_issue IS NOT NULL
                 AND ci.termination_date IS NULL);
      RETURN v_is_exists = 1;
    END is_rf_docs_exists;

    FUNCTION is_in_docs_exists(par_contact_id contact.contact_id%TYPE) RETURN BOOLEAN IS
      v_is_exists NUMBER(1);
    BEGIN
      SELECT COUNT(1)
        INTO v_is_exists
        FROM dual
       WHERE EXISTS (SELECT NULL
                FROM cn_contact_ident ci
                    ,t_id_type        ty
               WHERE ci.contact_id = par_contact_id
                 AND ci.id_type = ty.id
                 AND ty.brief IN ('PASS_IN')
                 AND ci.id_value IS NOT NULL
                 AND ci.serial_nr IS NOT NULL
                 AND ci.place_of_issue IS NOT NULL
                 AND ci.termination_date IS NULL);
      RETURN v_is_exists = 1;
    END is_in_docs_exists;

    FUNCTION is_addresses_exists(par_contact_id contact.contact_id%TYPE) RETURN BOOLEAN IS
      v_is_exists NUMBER(1);
    BEGIN
      SELECT COUNT(1)
        INTO v_is_exists
        FROM dual
       WHERE EXISTS (SELECT NULL
                FROM cn_contact_address ca
                    ,t_address_type     ta
                    ,cn_address         ad
               WHERE ca.contact_id = par_contact_id
                 AND ca.address_type = ta.id
                 AND ca.adress_id = ad.id
                 AND (ad.street_name IS NOT NULL AND ad.house_nr IS NOT NULL OR
                     nvl(length(ad.name), 0) > 30)
                 AND ca.status = 1
                 AND ta.brief IN ('CONST'
                                 ,'FK_CONST'
                                 ,'TEMPORARY'
                                 ,'FK_TEMPORARY'
                                 ,'FACT'
                                 ,'FK_FACT'
                                 ,'DOMADD'
                                 ,'FK_DOMADD'
                                 ,'LEGAL'
                                 ,'FK_LEGAL'));
      RETURN v_is_exists = 1;
    END is_addresses_exists;

    FUNCTION is_rf_addresses_exists(par_contact_id contact.contact_id%TYPE) RETURN BOOLEAN IS
      v_is_exists NUMBER(1);
    BEGIN
      SELECT COUNT(1)
        INTO v_is_exists
        FROM dual
       WHERE EXISTS (SELECT NULL
                FROM cn_contact_address ca
                    ,t_address_type     ta
                    ,cn_address         ad
                    ,t_country          tc
               WHERE ca.contact_id = par_contact_id
                 AND ca.address_type = ta.id
                 AND ca.adress_id = ad.id
                 AND ad.country_id = tc.id
                 AND tc.alfa3 = 'RUS'
                 AND (ad.street_name IS NOT NULL AND ad.house_nr IS NOT NULL OR
                     nvl(length(ad.name), 0) > 30)
                 AND ca.status = 1
                 AND ta.brief IN ('CONST'
                                 ,'FK_CONST'
                                 ,'TEMPORARY'
                                 ,'FK_TEMPORARY'
                                 ,'FACT'
                                 ,'FK_FACT'
                                 ,'DOMADD'
                                 ,'FK_DOMADD'
                                 ,'LEGAL'
                                 ,'FK_LEGAL'));
      RETURN v_is_exists = 1;
    END is_rf_addresses_exists;

    FUNCTION is_contacts_related
    (
      par_contact_a_id contact.contact_id%TYPE
     ,par_contact_b_id contact.contact_id%TYPE
    ) RETURN BOOLEAN IS
      v_is_the_same        BOOLEAN := FALSE;
      v_is_relation_exists NUMBER(1) := 0;
    BEGIN
      IF par_contact_a_id = par_contact_b_id
      THEN
        v_is_the_same := TRUE;
      ELSE
        SELECT COUNT(1)
          INTO v_is_relation_exists
          FROM dual
         WHERE EXISTS (SELECT NULL
                  FROM cn_contact_rel cr
                 WHERE cr.contact_id_a = par_contact_a_id
                   AND cr.contact_id_b = par_contact_b_id);
      END IF;
      RETURN v_is_the_same OR v_is_relation_exists = 1;
    END is_contacts_related;

  BEGIN
    /* ���� ����� �������, ������, ����� ��������, ������������ */
    BEGIN
      SELECT trunc(ds.start_date, 'dd')
            ,ph.fund_id
            ,ph.fund_pay_id
            , '���. ' || nvl2(pp.pol_ser, pp.pol_ser || '-', NULL) || pp.pol_num
             -- ������ �.
             -- ������ �140151
              || ' ' || co.name || ' ' || substr(co.first_name, 1, 1) || '.' ||
              substr(co.middle_name, 1, 1) || '.'
             --
            ,pi.contact_id
        INTO v_doc_date
            ,v_fund_id
            ,v_rev_fund_id
            ,v_note
            ,v_issuer_id
        FROM doc_status   ds
            ,p_policy     pp
            ,p_pol_header ph
             --
            ,v_pol_issuer pi
            ,contact      co
      --
       WHERE pp.policy_id = par_p_policy_id
         AND ds.document_id = pp.policy_id
         AND pp.pol_header_id = ph.policy_header_id
         AND ds.doc_status_id = doc.get_last_doc_status_id(pp.policy_id)
            --
         AND pp.policy_id = pi.policy_id
         AND pi.contact_id = co.contact_id;
      --
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20001
                               ,'���������� �������� ����� ��������!');
    END;

    /* ��������� ���� */
    BEGIN
      SELECT src.redemption_sum_cur
            ,src.add_invest_income_cur
            ,src.return_bonus_part_cur + ROUND(nvl(src.state_duty, 0), 2) +
             ROUND(nvl(src.penalty, 0), 2) + ROUND(nvl(src.other_court_fees, 0), 2) +
             ROUND(nvl(src.borrowed_money_percent, 0), 2) + ROUND(nvl(src.moral_damage, 0), 2) +
             ROUND(nvl(src.service_fee, 0), 2)
        INTO v_redemption_sum_cur
            ,v_add_invest_income_cur
            ,v_return_bonus_part_cur
        FROM (SELECT ROUND(nvl(SUM(cd.redemption_sum), 0) - nvl(pd.debt_fee_fact, 0) +
                           nvl(pd.overpayment, 0) + nvl(SUM(cd.add_policy_surrender), 0)
                          ,2) redemption_sum_cur -- �������� �����
                    ,ROUND(nvl(SUM(cd.add_invest_income), 0), 2) add_invest_income_cur -- ���
                    ,ROUND(nvl(SUM(cd.return_bonus_part), 0) - nvl(SUM(cd.admin_expenses), 0) -
                           nvl(pd.medo_cost, 0)
                          ,2) return_bonus_part_cur -- ������� ����� ������
                    ,pd.state_duty
                    ,pd.penalty
                    ,pd.other_court_fees
                    ,pd.borrowed_money_percent
                    ,pd.moral_damage
                    ,pd.service_fee
        FROM p_pol_decline   pd
            ,p_cover_decline cd
       WHERE pd.p_policy_id = par_p_policy_id
         AND cd.p_pol_decline_id = pd.p_pol_decline_id
       GROUP BY pd.debt_fee_fact
               ,pd.overpayment
                       ,pd.medo_cost
                       ,pd.state_duty
                       ,pd.penalty
                       ,pd.other_court_fees
                       ,pd.borrowed_money_percent
                       ,pd.moral_damage
                       ,pd.service_fee) src;
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20001
                               ,'���������� �������� ����� ��� ��! �������� �� ������� ������ �����������.');
    END;

    /* ��������� ���������� ������ */
    SELECT to_number(MAX(regexp_substr(doc.num, '\d+'))) + 1
      INTO v_next_num
      FROM document  doc
          ,doc_templ dt
     WHERE doc.doc_templ_id = dt.doc_templ_id
       AND dt.brief = '���';
    IF v_next_num IS NULL
    THEN
      raise_application_error(-20001
                             ,'������ ��������� ���������� ������!');
    END IF;

    /* ��������� ����������� ������� */
    BEGIN
      SELECT pd.payment_direct_id
        INTO v_payment_direct_id
        FROM ac_payment_direct pd
       WHERE pd.brief = 'OUT';
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20001
                               ,'�� ������ ID ����������� ������� � ����������� "OUT"! ��������� ������������� ����������� ������� ("���������") � ����������� "OUT"!');
    END;

    /* ��������� ������ �� �� (���� ���������� ����� ������)*/
    BEGIN
      SELECT ac.contact_id
            ,ac.contact_bank_acc_id
            ,(SELECT ba.owner_contact_id
                FROM cn_contact_bank_acc ba
               WHERE ba.id = ac.contact_bank_acc_id) AS owner_contact_id
            ,doc.note --������ 183603 �������� ���� ���������� ������� � �������� �������
      -- ������ �.
      -- ������ �140151
      --            ,v_note||' '||co.name||' '||substr(co.first_name,1,1)||'.'||substr(co.middle_name,1,1)||'.'
        INTO v_contact_id
            ,v_contact_bank_acc_id
            ,v_owner_contact_id
            ,v_payreq_note
        FROM ac_payment       ac
            ,ac_payment_templ act
            ,document         doc
            ,doc_templ        dt
            ,doc_doc          dd
      --            ,contact          co
       WHERE dd.parent_id = par_p_policy_id
         AND ac.payment_id = dd.child_id
         AND ac.payment_id = doc.document_id
         AND doc.doc_templ_id = dt.doc_templ_id
         AND ac.payment_templ_id = act.payment_templ_id
            --         and ac.contact_id       = co.contact_id
         AND act.brief = 'PAYREQ'
         AND dt.brief = 'PAYREQ'
         AND rownum = 1;
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20001
                               ,'�� ������� �� ������ ���������� ����������, ���������� � ������� ��!');
    END;

    /* ID ������� ��� */
    BEGIN
      SELECT pt.payment_templ_id
        INTO v_payment_templ_id
        FROM ac_payment_templ pt
       WHERE pt.brief = '���';
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20001
                               ,'�� ������ ID ������� ������� � ����������� "���"! ��������� ������������� ������� ������� ("��������� ��������� ���������") � ����������� "���"!');
    END;

    BEGIN
      SELECT dt.doc_templ_id INTO v_document_templ FROM doc_templ dt WHERE dt.brief = '���';
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20001
                               ,'�� ������ ID ������� ��������� � ����������� "���"! ��������� ������������� ������� ��������� ("��������� ��������� ���������") � ����������� "���"!');
    END;

    /* ������� ���������, � ��� - ������������� */
    BEGIN
      SELECT pt.id
        INTO v_payment_terms_id
        FROM t_payment_terms pt
       WHERE pt.brief = '�������������';
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20001
                               ,'�� ������ ID ������� ��������� ������� � ����������� "�������������"! ��������� ������������� ������� ��������� ������� ("�������������") � ����������� "�������������"!');
    END;

    /* ��� ������� - �����������*/
    BEGIN
      SELECT pt.payment_type_id
        INTO v_payment_type_id
        FROM ac_payment_type pt
       WHERE pt.brief = 'FACT';
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20001
                               ,'�� ������ ID ���� ������� � ����������� "FACT"! ��������� ������������� ���� ������� ("�����������") � ����������� "FACT"!');
    END;

    /* ������ ������ */
    BEGIN
      SELECT cm.id INTO v_collection_method FROM t_collection_method cm WHERE cm.is_default = 1;
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20001
                               ,'�� ������ ID ������� ������ �� ���������! ��������� ������������� ������� ������ �� ���������!');
    END;

    /* ������ ������� - ������ ����� ������ �� ���� �������� �������� ����������� � ������ �� �����������. � ������ */
    v_expense_period := trunc(v_doc_date, 'mm');

    /* ���� ������� - ��������� ����������� ������� ��� ������� �� �������� ����������� � ������ �� �����������. � ������ + 13 ���� */
    SELECT MIN(day_date) + 14
      INTO v_expense_date
      FROM (SELECT to_char(v_doc_date + rownum - 1, 'D') AS day_num
                  ,v_doc_date + rownum - 1 AS day_date
              FROM dual
            CONNECT BY rownum <= 7)
     WHERE day_num IN ('2', '4');

    /* ���������� ��� */
    IF v_redemption_sum_cur + v_add_invest_income_cur + v_return_bonus_part_cur > 0
    THEN
      /*
        �������� ����� ���������
        ������ 353051
      */
      IF is_contact_individual(v_owner_contact_id)
      THEN
        IF NOT is_rf_docs_exists(v_owner_contact_id)
           AND NOT is_in_docs_exists(v_owner_contact_id)
        THEN
          ex.raise('��������! ��� ������� ����������� ���� ���������� ������� ���������� ������');
        END IF;
        IF (is_rf_docs_exists(v_owner_contact_id) AND NOT is_rf_addresses_exists(v_owner_contact_id))
           OR (is_in_docs_exists(v_owner_contact_id) AND NOT is_addresses_exists(v_owner_contact_id))
        THEN
          ex.raise('��������! ��� ������� ����������� ���� ���������� ������� ����� �����������');
        END IF;
        IF NOT is_contacts_related(v_owner_contact_id, v_issuer_id)
        THEN
          ex.raise('��������! ��� ������� ����������� ���� ���������� ������� ����������� ����� � �����������');
        END IF;
      END IF;

      /* ��� ����� �� ��������� */
      SELECT rt.rate_type_id INTO v_rate_type_id FROM rate_type rt WHERE rt.is_default = 1;

      /* ���� */
      v_rev_rate := acc_new.get_rate_by_id(1, v_rev_fund_id, v_doc_date);
      -- ���� ������ ������ - �����, ��������� ������ ���������������
      IF v_rev_rate = 1
      THEN
        v_rev_rate := acc_new.get_rate_by_id(1, v_fund_id, v_doc_date);
      END IF;
      /* �������� ����� */
      IF v_redemption_sum_cur != 0
      THEN
        insert_payment(v_redemption_sum_cur
                      ,v_note || ' (�������� �����)'
                      ,50002
                      ,v_payreq_note);
        v_next_num := v_next_num + 1;
      END IF;
      /* ��� */
      IF v_add_invest_income_cur != 0
      THEN
        insert_payment(v_add_invest_income_cur
                      ,v_note || ' (���. ������. �����)'
                      ,50003
                      ,v_payreq_note);
        v_next_num := v_next_num + 1;
      END IF;
      /* ������� ����� ������ */
      IF v_return_bonus_part_cur > 0
      THEN
        insert_payment(v_return_bonus_part_cur
                      ,v_note || ' (������� ����� ������)'
                      ,50004
                      ,v_payreq_note);
      ELSIF v_return_bonus_part_cur < 0
      THEN
        raise_application_error(-20001
                               ,'������� ������� ��������! ����� � ������� ������ 0.');
      END IF;
    END IF;
  END make_outgoing_bank_doc;

  /*
    ������ �.
    �������� �� ��� �������� ��������� �� ������� "���������.� �������" � ������ "���������. ��������� ��������"
    � Borlas: "����������� ��. �������� ���. ��"
    par_p_policy_id - ID ������ ��
  */
  PROCEDURE delete_outgoing_bank_doc(par_p_policy_id NUMBER) IS
  BEGIN
    /* ���� �� ��������� ��� */
    FOR r_ids IN (SELECT c.doc_doc_id
                        ,ac.payment_id
                        ,doc.get_doc_status_brief(ac.payment_id) AS payment_status_brief
                    FROM doc_doc             c
                        ,ac_payment          ac
                        ,ac_payment_templ    apt
                        ,ac_payment_add_info ai
                        ,document            dc
                        ,doc_templ           dt
                   WHERE c.parent_id = par_p_policy_id
                     AND c.child_id = ac.payment_id
                     AND ac.payment_templ_id = apt.payment_templ_id
                     AND ac.payment_id = dc.document_id
                     AND dc.doc_templ_id = dt.doc_templ_id
                     AND ac.payment_id = ai.ac_payment_add_info_id
                     AND apt.brief = '���'
                     AND dt.brief = '���')
    LOOP
      /* ������� ������� */
      IF r_ids.payment_status_brief = 'TRANS'
      THEN
        doc.set_doc_status(r_ids.payment_id, 'NEW', SYSDATE, 'AUTO');
      END IF;

      /* �������� ������� */
      DELETE FROM ven_doc_status ds WHERE ds.document_id = r_ids.payment_id;

      /* �������� ������ */
      DELETE FROM ven_doc_doc dd WHERE dd.doc_doc_id = r_ids.doc_doc_id;

      /* �������� ���. ���� */
      DELETE FROM ven_ac_payment_add_info ai WHERE ai.ac_payment_add_info_id = r_ids.payment_id;

      /* �������� ��� */
      DELETE FROM ven_ac_payment ap WHERE ap.payment_id = r_ids.payment_id;
    END LOOP;
  END delete_outgoing_bank_doc;

  /*
    ������ �.

    �������������� �������� �������������� �������� ��� �������� ���������
    �� ������� "� �����������. ����� ��� ��������" � ������ "� �����������. ��������"

    par_policy_id - �� ������ ��������

  */
  PROCEDURE make_correct_trans_auto(par_policy_id NUMBER) IS
    TYPE t_summs IS RECORD(
       vs    p_cover_decline.redemption_sum%TYPE
      ,vchp  p_cover_decline.return_bonus_part%TYPE
      ,n_div p_cover_decline.underpayment_actual%TYPE
      ,n_sum p_cover_decline.underpayment_actual%TYPE
      ,p     p_pol_decline.overpayment%TYPE
      ,ps    p_cover_decline.bonus_off_prev%TYPE
      ,did   p_cover_decline.add_invest_income%TYPE);
    v_summs            t_summs;
    v_pol_header_id    p_pol_header.policy_header_id%TYPE;
    v_cnt              NUMBER;
    v_pol_decline_id   p_pol_decline.p_pol_decline_id%TYPE;
    v_work_date        p_pol_decline.act_date%TYPE;
    v_sysdate          DATE := SYSDATE;
    v_rate             NUMBER;
    v_fund_id          NUMBER;
    v_fund_pay_id      NUMBER;
    v_policy_ent_id    entity.ent_id%TYPE;
    v_decline_date     DATE;
    v_curr_year_charge NUMBER;
    /*
      �������� �������������� ��������
    */
    PROCEDURE make_corr_trans
    (
      par_prod_line_id NUMBER
     ,par_trans_sum    NUMBER
     ,par_trans_date   DATE
    ) IS
      v_cover_id      NUMBER;
      v_corr_trans_id p_trans_decline.p_trans_decline_id%TYPE;
    BEGIN
      -- ��������� �� ��������
      -- �� �� ��������� ������
      BEGIN
        SELECT pc.p_cover_id
          INTO v_cover_id
          FROM p_cover            pc
              ,as_asset           se
              ,as_assured         su
              ,t_prod_line_option pl
         WHERE pc.as_asset_id = se.as_asset_id
           AND se.as_asset_id = su.as_assured_id
           AND pc.t_prod_line_option_id = pl.id
           AND pl.product_line_id = par_prod_line_id
           AND se.p_policy_id = par_policy_id;
      EXCEPTION
        WHEN no_data_found THEN
          -- ���� ��� �� ���������, �� �� ��������� � ���������
          BEGIN
            SELECT p_cover_id
              INTO v_cover_id
              FROM (SELECT /*+ INDEX_DESC(pp IX_P_POLICY_HEAD_VER_NUM_UK)*/
                     pc.p_cover_id
                      FROM p_policy           pp
                          ,p_cover            pc
                          ,as_asset           se
                          ,as_assured         su
                          ,t_prod_line_option pl
                     WHERE pc.as_asset_id = se.as_asset_id
                       AND se.as_asset_id = su.as_assured_id
                       AND se.p_policy_id = pp.policy_id
                       AND pc.t_prod_line_option_id = pl.id
                       AND pl.product_line_id = par_prod_line_id
                       AND pp.pol_header_id = v_pol_header_id
                       AND rownum = 1
                     ORDER BY pp.version_num DESC);
          EXCEPTION
            WHEN no_data_found THEN
              -- ���� �� ����� ���������� ����, �������, �.�. ���������, ��� ������
              NULL;
          END;
      END;

      v_sysdate := v_sysdate + INTERVAL '1' SECOND;
      -- ���� ����� �������������
      IF par_trans_sum < 0
      THEN
        -- �������� ���������� � ������� ���� �� ���������� �������� ����
        SELECT nvl(SUM(trans_amount), 0)
          INTO v_curr_year_charge
          FROM (SELECT -- ���
                 tr.trans_amount
                  FROM trans              tr
                      ,oper               op
                      ,account            ac_cr
                      ,account            ac_dt
                      ,ac_payment         ap
                      ,doc_doc            dd
                      ,document           dc
                      ,doc_templ          dt
                      ,t_prod_line_option plo
                      ,p_policy           pp
                      ,p_pol_header       ph
                 WHERE tr.ct_account_id = ac_cr.account_id
                   AND ac_cr.num = '92.01'
                   AND tr.dt_account_id = ac_dt.account_id
                   AND ac_dt.num = '77.01.01'
                   AND tr.oper_id = op.oper_id
                   AND op.document_id = ap.payment_id
                   AND op.document_id = dc.document_id
                   AND dc.doc_templ_id = dt.doc_templ_id
                   AND dt.brief = 'PAYMENT'
                   AND tr.a4_dt_uro_id = plo.id
                   AND plo.product_line_id = par_prod_line_id
                   AND dc.document_id = dd.child_id
                   AND dd.parent_id = pp.policy_id
                   AND trunc(ap.due_date, 'yyyy') = trunc(v_sysdate, 'yyyy')
                   AND trunc(tr.trans_date, 'yyyy') = trunc(v_sysdate, 'yyyy')
                   AND pp.pol_header_id = ph.policy_header_id
                   AND ph.policy_header_id = v_pol_header_id
                UNION ALL
                SELECT -- ��
                 tr.trans_amount
                  FROM trans              tr
                      ,oper               op
                      ,account            ac_cr
                      ,account            ac_dt
                      ,t_prod_line_option plo
                      ,p_policy           pp
                      ,p_pol_header       ph
                 WHERE tr.ct_account_id = ac_cr.account_id
                   AND ac_cr.num = '92.01'
                   AND tr.dt_account_id = ac_dt.account_id
                   AND ac_dt.num = '77.01.01'
                   AND tr.oper_id = op.oper_id
                   AND op.document_id = pp.policy_id
                   AND tr.a4_dt_uro_id = plo.id
                   AND plo.product_line_id = par_prod_line_id
                   AND trunc(pp.start_date, 'yyyy') = trunc(v_sysdate, 'yyyy')
                   AND trunc(tr.trans_date, 'yyyy') = trunc(v_sysdate, 'yyyy')
                   AND pp.pol_header_id = ph.policy_header_id
                   AND ph.policy_header_id = v_pol_header_id);
        -- ���� ���������� + ����� ������������� < 0, �� ����� �������� = ������������� ����� ����������
        IF v_curr_year_charge + par_trans_sum < 0
        THEN
          v_curr_year_charge := -v_curr_year_charge;
          insert_corr_trans(par_pol_decline_id   => v_pol_decline_id
                           ,par_p_cover_id       => v_cover_id
                           ,par_oper_templ_brief => 'QUIT_FIX_28' -- ����������/������ ������ �������� �������
                           ,par_doc_templ_brief  => 'P_TRANS_DECLINE'
                           ,par_trans_sum        => v_curr_year_charge
                           ,par_trans_date       => par_trans_date
                           ,par_status_date      => v_sysdate
                           ,par_trans_id         => v_corr_trans_id);
          IF v_corr_trans_id IS NOT NULL
          THEN
            -- ��������� ������� �������� "������"
            v_sysdate := v_sysdate + INTERVAL '1' SECOND;
            doc.set_doc_status(v_corr_trans_id, 'CLOSE', v_sysdate);
          END IF;
        ELSIF par_trans_sum != 0
        THEN
          -- ����� ����� �������� = �������������
          v_curr_year_charge := par_trans_sum;
          insert_corr_trans(par_pol_decline_id   => v_pol_decline_id
                           ,par_p_cover_id       => v_cover_id
                           ,par_oper_templ_brief => 'QUIT_FIX_28' -- ����������/������ ������ �������� �������
                           ,par_doc_templ_brief  => 'P_TRANS_DECLINE'
                           ,par_trans_sum        => v_curr_year_charge
                           ,par_trans_date       => par_trans_date
                           ,par_status_date      => v_sysdate
                           ,par_trans_id         => v_corr_trans_id);
          IF v_corr_trans_id IS NOT NULL
          THEN
            -- ��������� ������� �������� "������"
            v_sysdate := v_sysdate + INTERVAL '1' SECOND;
            doc.set_doc_status(v_corr_trans_id, 'CLOSE', v_sysdate);
          END IF;
        END IF;
        IF v_curr_year_charge - par_trans_sum != 0
        THEN
          v_curr_year_charge := v_curr_year_charge - par_trans_sum;
          insert_corr_trans(par_pol_decline_id   => v_pol_decline_id
                           ,par_p_cover_id       => v_cover_id
                           ,par_oper_templ_brief => 'QUIT_MAIN_1' -- ������������� ����������� ������ � �������� ������� ���
                           ,par_doc_templ_brief  => 'P_TRANS_DECLINE'
                           ,par_trans_sum        => v_curr_year_charge
                           ,par_trans_date       => par_trans_date
                           ,par_status_date      => v_sysdate
                           ,par_trans_id         => v_corr_trans_id);
          IF v_corr_trans_id IS NOT NULL
          THEN
            -- ��������� ������� �������� "������"
            v_sysdate := v_sysdate + INTERVAL '1' SECOND;
            doc.set_doc_status(v_corr_trans_id, 'CLOSE', v_sysdate);
          END IF;
        END IF;
      ELSIF v_decline_date < trunc(v_sysdate, 'yyyy')
            AND par_trans_sum > 0
      THEN
        -- ���� ���� ����������� � ������� ���� � ����� ������������� �������������
        insert_corr_trans(par_pol_decline_id   => v_pol_decline_id
                         ,par_p_cover_id       => v_cover_id
                         ,par_oper_templ_brief => 'QUIT_FIX_30' -- ���������� ������ ������� ���
                         ,par_doc_templ_brief  => 'P_TRANS_DECLINE'
                         ,par_trans_sum        => par_trans_sum
                         ,par_trans_date       => par_trans_date
                         ,par_status_date      => v_sysdate
                         ,par_trans_id         => v_corr_trans_id);
        IF v_corr_trans_id IS NOT NULL
        THEN
          -- ��������� ������� �������� "������"
          v_sysdate := v_sysdate + INTERVAL '1' SECOND;
          doc.set_doc_status(v_corr_trans_id, 'CLOSE', v_sysdate);
        END IF;
      ELSIF par_trans_sum != 0
      THEN
        -- ����� ������ �������� �� ����� �������������
        insert_corr_trans(par_pol_decline_id   => v_pol_decline_id
                         ,par_p_cover_id       => v_cover_id
                         ,par_oper_templ_brief => 'QUIT_FIX_28' -- ����������/������ ������ �������� �������
                         ,par_doc_templ_brief  => 'P_TRANS_DECLINE'
                         ,par_trans_sum        => par_trans_sum
                         ,par_trans_date       => par_trans_date
                         ,par_status_date      => v_sysdate
                         ,par_trans_id         => v_corr_trans_id);
        IF v_corr_trans_id IS NOT NULL
        THEN
          -- ��������� ������� �������� "������"
          doc.set_doc_status(v_corr_trans_id, 'CLOSE', v_sysdate);
        END IF;
      END IF;
    END;

    PROCEDURE calc_sum
    (
      par_value    NUMBER DEFAULT 0
     ,par_sum_kind NUMBER -- ��� �����:
      -- 0 - ��������� �� ������ (�� ������), 10 - ��������� (� �����),
      -- 1 - ������ � �������� (�� ������), 11 - ��������� (� �����)
      -- 2 - ��������� (�� ������)+������ � �������� (�� ������), 12 - ��������� (� �����)+������ � �������� (� �����)
      -- 3 - ������ (�� ������), 13 - ������
      -- �� �������� ��������� �������, ��� ����� �������������� �����
     ,par_sum_sign NUMBER DEFAULT 1 -- ����: 1 ��� -1
    ) IS
      TYPE t_ret_data IS RECORD(
         acc_amount      NUMBER
        ,contact_id      contact.contact_id%TYPE
        ,product_line_id t_product_line.id%TYPE);
      TYPE tt_ret_data IS TABLE OF t_ret_data;
      vr_corr_data tt_ret_data;
      vr_fact_data tt_ret_data;
    BEGIN
      -- ���������� ����������
      IF par_sum_kind >= 10
      THEN
        SELECT CASE
                 WHEN rownum = 1 THEN
                  tmp_amount + (correct_amount - SUM(tmp_amount) over())
                 ELSE
                  tmp_amount
               END AS acc_amount
              ,contact_id
              ,product_line_id
          BULK COLLECT
          INTO vr_corr_data
          FROM (SELECT acc_amount + CASE
                         WHEN acc_amount != 0 THEN
                          ROUND((acc_amount / SUM(acc_amount) over()) *
                                (v_rate * par_sum_sign * par_value)
                               ,2)
                         ELSE
                          0
                       END AS tmp_amount
                      ,SUM(acc_amount) over() + (v_rate * par_sum_sign * par_value) AS correct_amount
                      ,contact_id
                      ,product_line_id
                  FROM (SELECT SUM(acc_amount) AS acc_amount
                              ,contact_id
                              ,product_line_id
                          FROM (SELECT tr.trans_amount       AS acc_amount
                                      ,ur.assured_contact_id AS contact_id
                                      ,pl.product_line_id
                                  FROM p_policy           p
                                      ,as_asset           a
                                      ,as_assured         ur
                                      ,p_cover            pc
                                      ,t_prod_line_option pl
                                      ,trans              tr
                                      ,account            ac
                                 WHERE p.policy_id = a.p_policy_id
                                   AND a.as_asset_id = ur.as_assured_id
                                   AND a.as_asset_id = pc.as_asset_id
                                   AND tr.obj_uro_id = pc.p_cover_id
                                   AND tr.obj_ure_id = pc.ent_id
                                   AND pc.t_prod_line_option_id = pl.id
                                   AND tr.dt_account_id = ac.account_id
                                   AND ac.num IN ('77.00.01', '22.05.01', '22.05.02', '77.08.03')
                                   AND p.pol_header_id = v_pol_header_id
                                      -- ��������� �������������� ��������
                                   AND NOT EXISTS (SELECT NULL
                                          FROM p_trans_decline td
                                              ,oper            op
                                         WHERE td.p_trans_decline_id = op.document_id
                                           AND op.oper_id = tr.oper_id
                                           AND td.p_pol_decline_id = v_pol_decline_id)
                                      -- ��������� �������� �� �����������
                                   AND NOT EXISTS
                                 (SELECT NULL
                                          FROM p_pol_decline pd
                                         WHERE pd.p_policy_id = p.policy_id
                                           AND pd.p_pol_decline_id = v_pol_decline_id
                                        UNION ALL
                                        SELECT NULL
                                          FROM oper          op
                                              ,p_pol_decline pd
                                         WHERE op.oper_id = tr.oper_id
                                           AND op.document_id = pd.p_policy_id
                                           AND pd.p_pol_decline_id = v_pol_decline_id)
                                UNION ALL
                                SELECT -tr.trans_amount      AS acc_amount
                                      ,ur.assured_contact_id AS contact_id
                                      ,pl.product_line_id
                                  FROM p_policy           p
                                      ,as_asset           a
                                      ,as_assured         ur
                                      ,p_cover            pc
                                      ,t_prod_line_option pl
                                      ,trans              tr
                                      ,account            ac
                                 WHERE p.policy_id = a.p_policy_id
                                   AND a.as_asset_id = ur.as_assured_id
                                   AND a.as_asset_id = pc.as_asset_id
                                   AND tr.obj_uro_id = pc.p_cover_id
                                   AND tr.obj_ure_id = pc.ent_id
                                   AND pc.t_prod_line_option_id = pl.id
                                   AND tr.ct_account_id = ac.account_id
                                   AND ac.num IN ('77.00.01', '22.05.01', '22.05.02', '77.08.03')
                                   AND p.pol_header_id = v_pol_header_id
                                      -- ��������� �������������� ��������
                                   AND NOT EXISTS (SELECT NULL
                                          FROM p_trans_decline td
                                              ,oper            op
                                         WHERE td.p_trans_decline_id = op.document_id
                                           AND op.oper_id = tr.oper_id
                                           AND td.p_pol_decline_id = v_pol_decline_id)
                                      -- ��������� �������� �� �����������
                                   AND NOT EXISTS
                                 (SELECT NULL
                                          FROM p_pol_decline pd
                                         WHERE pd.p_policy_id = p.policy_id
                                           AND pd.p_pol_decline_id = v_pol_decline_id
                                        UNION ALL
                                        SELECT NULL
                                          FROM oper          op
                                              ,p_pol_decline pd
                                         WHERE op.oper_id = tr.oper_id
                                           AND op.document_id = pd.p_policy_id
                                           AND pd.p_pol_decline_id = v_pol_decline_id))
                         GROUP BY contact_id
                                 ,product_line_id))
        -- ���������� ��� ����, ����� ��������� ���������� ������ ����
         ORDER BY product_line_id;
      ELSE
        SELECT acc_amount + CASE par_sum_kind
                 WHEN 0 THEN
                  v_rate * par_sum_sign * nvl(dc.underpayment_actual, 0)
                 WHEN 1 THEN
                  v_rate * par_sum_sign * nvl(dc.bonus_off_prev + dc.bonus_off_current, 0)
                 WHEN 2 THEN
                  v_rate * par_sum_sign *
                  nvl(dc.bonus_off_prev + dc.bonus_off_current + dc.underpayment_actual, 0)
                 ELSE
                  0
               END AS acc_amount
              ,mn.contact_id
              ,mn.product_line_id
          BULK COLLECT
          INTO vr_corr_data
          FROM (SELECT SUM(acc_amount) AS acc_amount
                      ,contact_id
                      ,product_line_id
                  FROM (SELECT tr.trans_amount       AS acc_amount
                              ,ur.assured_contact_id AS contact_id
                              ,pl.product_line_id
                          FROM p_policy           p
                              ,as_asset           a
                              ,as_assured         ur
                              ,p_cover            pc
                              ,t_prod_line_option pl
                              ,trans              tr
                              ,account            ac
                         WHERE p.policy_id = a.p_policy_id
                           AND a.as_asset_id = ur.as_assured_id
                           AND a.as_asset_id = pc.as_asset_id
                           AND tr.obj_uro_id = pc.p_cover_id
                           AND tr.obj_ure_id = pc.ent_id
                           AND pc.t_prod_line_option_id = pl.id
                           AND tr.dt_account_id = ac.account_id
                           AND ac.num IN ('77.00.01', '22.05.01', '22.05.02', '77.08.03')
                           AND p.pol_header_id = v_pol_header_id
                              -- ��������� �������������� ��������
                           AND NOT EXISTS (SELECT NULL
                                  FROM p_trans_decline td
                                      ,oper            op
                                 WHERE td.p_trans_decline_id = op.document_id
                                   AND op.oper_id = tr.oper_id
                                   AND td.p_pol_decline_id = v_pol_decline_id)
                              -- ��������� �������� �� �����������
                           AND NOT EXISTS (SELECT NULL
                                  FROM p_pol_decline pd
                                 WHERE pd.p_policy_id = p.policy_id
                                   AND pd.p_pol_decline_id = v_pol_decline_id)
                        UNION ALL
                        SELECT -tr.trans_amount      AS acc_amount
                              ,ur.assured_contact_id AS contact_id
                              ,pl.product_line_id
                          FROM p_policy           p
                              ,as_asset           a
                              ,as_assured         ur
                              ,p_cover            pc
                              ,t_prod_line_option pl
                              ,trans              tr
                              ,account            ac
                         WHERE p.policy_id = a.p_policy_id
                           AND a.as_asset_id = ur.as_assured_id
                           AND a.as_asset_id = pc.as_asset_id
                           AND tr.obj_uro_id = pc.p_cover_id
                           AND tr.obj_ure_id = pc.ent_id
                           AND pc.t_prod_line_option_id = pl.id
                           AND tr.ct_account_id = ac.account_id
                           AND ac.num IN ('77.00.01', '22.05.01', '22.05.02', '77.08.03')
                           AND p.pol_header_id = v_pol_header_id
                              -- ��������� �������������� �������� ������� ������
                           AND NOT EXISTS (SELECT NULL
                                  FROM p_trans_decline td
                                      ,oper            op
                                 WHERE td.p_trans_decline_id = op.document_id
                                   AND op.oper_id = tr.oper_id
                                   AND td.p_pol_decline_id = v_pol_decline_id)
                              -- ��������� �������� �� ����������� ������� ������
                           AND NOT EXISTS (SELECT NULL
                                  FROM p_pol_decline pd
                                 WHERE pd.p_policy_id = p.policy_id
                                   AND pd.p_pol_decline_id = v_pol_decline_id))
                 GROUP BY contact_id
                         ,product_line_id) mn
              ,(SELECT su.assured_contact_id
                      ,cd.t_product_line_id
                      ,cd.underpayment_actual
                      ,cd.bonus_off_prev
                      ,cd.bonus_off_current
                  FROM p_cover_decline cd
                      ,p_pol_decline   pd
                      ,as_asset        se
                      ,as_assured      su
                 WHERE pd.p_policy_id = par_policy_id
                   AND pd.p_pol_decline_id = cd.p_pol_decline_id
                   AND cd.as_asset_id = se.as_asset_id
                   AND se.as_asset_id = su.as_assured_id) dc
         WHERE mn.contact_id = dc.assured_contact_id(+)
           AND mn.product_line_id = dc.t_product_line_id(+)
        -- ���������� ��� ����, ����� ��������� ���������� ������ ����
         ORDER BY product_line_id;
      END IF;

      -- ����������� ���������� ��� �������������
      SELECT nvl(SUM(acc_amount), 0) AS acc_amount
            ,assured_contact_id
            ,product_line_id
        BULK COLLECT
        INTO vr_fact_data
      -- ������ (92.01 + 91.01 - 91.02)
        FROM (SELECT CASE account_num
                       WHEN '91.02' THEN
                        -abs(SUM(acc_amount))
                       ELSE
                        abs(SUM(acc_amount))
                     END AS acc_amount
                    ,product_line_id
                    ,assured_contact_id
              -- ������ �� ������ '92.01','91.01','91.02'
                FROM (SELECT tr.trans_amount       AS acc_amount
                            ,tr.oper_id
                            ,p.policy_id
                            ,ur.assured_contact_id
                            ,pl.product_line_id
                            ,ac.num                AS account_num
                        FROM p_policy           p
                            ,as_asset           a
                            ,as_assured         ur
                            ,p_cover            pc
                            ,t_prod_line_option pl
                            ,trans              tr
                            ,account            ac
                       WHERE p.policy_id = a.p_policy_id
                         AND a.as_asset_id = ur.as_assured_id
                         AND a.as_asset_id = pc.as_asset_id
                         AND tr.obj_uro_id = pc.p_cover_id
                         AND tr.obj_ure_id = pc.ent_id
                         AND pc.t_prod_line_option_id = pl.id
                         AND tr.dt_account_id = ac.account_id
                         AND ac.num IN ('92.01', '91.01', '91.02')
                         AND p.pol_header_id = v_pol_header_id
                      UNION ALL
                      SELECT -tr.trans_amount      AS acc_amount
                            ,tr.oper_id
                            ,p.policy_id
                            ,ur.assured_contact_id
                            ,pl.product_line_id
                            ,ac.num                AS account_num
                        FROM p_policy           p
                            ,as_asset           a
                            ,as_assured         ur
                            ,p_cover            pc
                            ,t_prod_line_option pl
                            ,trans              tr
                            ,account            ac
                       WHERE p.policy_id = a.p_policy_id
                         AND a.as_asset_id = ur.as_assured_id
                         AND a.as_asset_id = pc.as_asset_id
                         AND tr.obj_uro_id = pc.p_cover_id
                         AND tr.obj_ure_id = pc.ent_id
                         AND pc.t_prod_line_option_id = pl.id
                         AND tr.ct_account_id = ac.account_id
                         AND ac.num IN ('92.01', '91.01', '91.02')
                         AND p.pol_header_id = v_pol_header_id) mn
              -- ��������� �������������� �������� ������� ������
               WHERE NOT EXISTS (SELECT NULL
                        FROM p_trans_decline td
                            ,oper            op
                       WHERE td.p_trans_decline_id = op.document_id
                         AND op.oper_id = mn.oper_id
                         AND td.p_pol_decline_id = v_pol_decline_id)
                    -- ��������� �������� �� ����������� ������� ������
                 AND NOT EXISTS (SELECT NULL
                        FROM p_pol_decline pd
                       WHERE pd.p_policy_id = mn.policy_id
                         AND pd.p_pol_decline_id = v_pol_decline_id
                      UNION ALL
                      SELECT NULL
                        FROM oper          op
                            ,p_pol_decline pd
                       WHERE op.oper_id = mn.oper_id
                         AND op.document_id = pd.p_policy_id
                         AND pd.p_pol_decline_id = v_pol_decline_id)

               GROUP BY account_num
                       ,product_line_id
                       ,assured_contact_id)
       GROUP BY product_line_id
               ,assured_contact_id
      -- ���������� ��� ����, ����� ��������� ���������� ������ ����
       ORDER BY product_line_id;
      -- ��������� = ���������� ���������� - ����������� ���������� ��� �������������
      DECLARE
        v_found BOOLEAN;
      BEGIN
        -- ���� ���� � ����������� ���������� � ���������� ����������
        IF vr_fact_data.count > 0
           AND vr_corr_data.count > 0
        THEN
          FOR v_f_idx IN vr_fact_data.first .. vr_fact_data.last
          LOOP
            v_found := FALSE;
            FOR v_c_idx IN vr_corr_data.first .. vr_corr_data.last
            LOOP
              IF vr_fact_data(v_f_idx)
               .contact_id = vr_corr_data(v_c_idx).contact_id
                  AND vr_fact_data(v_f_idx).product_line_id = vr_corr_data(v_c_idx).product_line_id
              THEN
                vr_corr_data(v_c_idx).acc_amount := vr_corr_data(v_c_idx)
                                                    .acc_amount - vr_fact_data(v_f_idx).acc_amount;
                v_found := TRUE;
                EXIT;
              END IF;
            END LOOP v_c_idx;
            IF NOT v_found
            THEN
              vr_corr_data.extend(1);
              vr_corr_data(vr_corr_data.last).acc_amount := -vr_fact_data(v_f_idx).acc_amount;
              vr_corr_data(vr_corr_data.last).product_line_id := vr_fact_data(v_f_idx).product_line_id;
              vr_corr_data(vr_corr_data.last).contact_id := vr_fact_data(v_f_idx).contact_id;
            END IF;
          END LOOP v_f_idx;
          -- ���� ������ ����������� ����������
        ELSIF vr_fact_data.count > 0
        THEN
          FOR v_f_idx IN vr_fact_data.first .. vr_fact_data.last
          LOOP
            vr_corr_data.extend(1);
            vr_corr_data(vr_corr_data.last).acc_amount := -vr_fact_data(v_f_idx).acc_amount;
            vr_corr_data(vr_corr_data.last).product_line_id := vr_fact_data(v_f_idx).product_line_id;
            vr_corr_data(vr_corr_data.last).contact_id := vr_fact_data(v_f_idx).contact_id;
          END LOOP v_f_idx;
        END IF;
      END;
      -- ���� �� ����������
      IF vr_corr_data.count > 0
      THEN
        FOR v_c_idx IN vr_corr_data.first .. vr_corr_data.last
        LOOP
          IF vr_corr_data(v_c_idx).acc_amount != 0
          THEN
            make_corr_trans(par_prod_line_id => vr_corr_data(v_c_idx).product_line_id
                           ,par_trans_sum    => ROUND(vr_corr_data(v_c_idx).acc_amount / v_rate, 2)
                           ,par_trans_date   => v_work_date);
          END IF;
        END LOOP;
      END IF;
    END;
  BEGIN
    -- ��������� ����� ������
    SELECT ph.policy_header_id
          ,pd.p_pol_decline_id
          ,pd.act_date
          ,ph.fund_id
          ,ph.fund_pay_id
          ,decline_date
      INTO v_pol_header_id
          ,v_pol_decline_id
          ,v_work_date
          ,v_fund_id
          ,v_fund_pay_id
          ,v_decline_date
      FROM p_pol_header  ph
          ,p_policy      pp
          ,p_pol_decline pd
     WHERE pp.policy_id = par_policy_id
       AND pp.policy_id = pd.p_policy_id
       AND pp.pol_header_id = ph.policy_header_id;

    BEGIN
      SELECT e.ent_id
        INTO v_policy_ent_id
        FROM entity e
       WHERE e.brief = 'P_POLICY'
         AND e.schema_name = 'INS';
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20001
                               ,'����������� ������ � ����������� ������������� "P_POLICY" � ����������� ���������!');
    END;
    -- �������� �� ������������� �������� �� ������� 22.01, 22.05.01, 22.05.02

    check_accounts(par_policy_id);

    -- �� �������� �������������� ������������� ������������ ��������, � ������� ������� �����������:
    -- ����� �����������
    -- �������� ������� ������
    -- ����� ������������ �� ��
    -- ������� ���� (�������������)
    SELECT COUNT(1)
      INTO v_cnt
      FROM dual
     WHERE EXISTS (SELECT NULL
              FROM t_decline_reason dr
                  ,p_policy         pp
             WHERE pp.policy_id = par_policy_id
               AND pp.decline_reason_id = dr.t_decline_reason_id
               AND dr.brief IN ('����� �����������'
                               ,'�������� ������� ������'
                               ,'����� ������������ �� ��'
                               ,'������� ���� (�������������)'
                               ,'����� ������������ �� ��������'));
    IF v_cnt = 1
    THEN
      raise_application_error(-20001
                             ,'���������� ������������� ������� �������������� ��������. ������� ����������� ������������ � ������ ������������.');
    END IF;

    -- ��������� ����� ������
    v_rate := acc_new.get_rate_by_id(1, v_fund_pay_id, v_work_date);
    -- ���� ������ ������ - �����, ��������� ������ ���������������
    IF v_rate = 1
    THEN
      v_rate := acc_new.get_rate_by_id(1, v_fund_id, v_work_date);
    END IF;

    -- ����������� ���� ��������
    -- ��������� ����, �� ������� ����� ����������� �������������
    BEGIN
      SELECT nvl(SUM(cd.redemption_sum), 0) AS vs -- (��) �������� �����
            ,nvl(SUM(cd.return_bonus_part), 0) AS vchp -- (���) ������� ����� ������
            ,nvl(SUM(cd.underpayment_actual), 0) AS n_div -- (�) ��������� ����������� (�������� �� ������)
            ,nvl(pd.debt_fee_fact, 0) AS n_sum -- (�) ��������� ����������� (����� �����)
            ,nvl(pd.overpayment, 0) AS p -- (�) ���������
            ,nvl(SUM(cd.bonus_off_prev), 0) + nvl(SUM(cd.bonus_off_current), 0) AS ps -- (��) ������ � ��������
            ,nvl(SUM(cd.add_invest_income), 0) AS did -- ��� ���. ������. �����
        INTO v_summs
        FROM p_policy        pp
            ,p_pol_decline   pd
            ,p_cover_decline cd
       WHERE pp.policy_id = par_policy_id
         AND pp.policy_id = pd.p_policy_id
         AND pd.p_pol_decline_id = cd.p_pol_decline_id
       GROUP BY pd.overpayment
               ,pd.debt_fee_fact;
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20001
                               ,'�� ������� ����� ������ ����� �����������!');
    END;
    -- ��� �������� � ������ ���� �������������� ��������
    -- ��� �������� 1
    -- ��  | ������� �� (���) | ���    |��������� (�) | ��������� (�) | ������ � �������� (��) | ����������� ��������
    -- ��� | ���              | ���    | ����         | ���           | ����                   | �=��, ��=0, ���=0, ���=0
    IF v_summs.vs = 0
       AND v_summs.vchp = 0
       AND v_summs.did = 0
       AND v_summs.n_sum > 0
       AND v_summs.p = 0
       AND v_summs.ps > 0
       AND v_summs.n_sum = v_summs.ps
    THEN
      IF v_summs.n_div != v_summs.n_sum
      THEN
        calc_sum(par_value => v_summs.n_sum, par_sum_kind => 10);
      ELSE
        calc_sum(par_sum_kind => 0);
      END IF;
      -- ��� �������� 2
      -- ��       | ������� �� (���) | ���      |��������� (�) | ��������� (�) | ������ � �������� (��) | ����������� ��������
      -- ���/���� | ���/����         | ���/���� | ���          | ���           | ����                   | ����� ��������
    ELSIF v_summs.n_sum = 0
          AND v_summs.p = 0
          AND v_summs.ps > 0
    THEN
      calc_sum(par_sum_kind => 1);
      -- ��� �������� 3
      -- ��       | ������� �� (���) | ���      |��������� (�) | ��������� (�) | ������ � �������� (��) | ����������� ��������
      -- ���/���� | ���/����         | ���/���� | ����         | ���           | ���                    |��+���+��� > �
    ELSIF v_summs.n_sum > 0
          AND v_summs.p = 0
          AND v_summs.ps = 0
          AND v_summs.vs + v_summs.vchp + v_summs.did > v_summs.n_sum
    THEN
      IF v_summs.n_div != v_summs.n_sum
      THEN
        calc_sum(par_value => v_summs.n_sum, par_sum_kind => 10);
      ELSE
        calc_sum(par_sum_kind => 0);
      END IF;
      -- ��� �������� 4
      -- ��       | ������� �� (���) | ���      |��������� (�) | ��������� (�) | ������ � �������� (��) | ����������� ��������
      -- ���/���� | ���/����         | ���/���� | ���          | ����          | ���                    | ����� ��������
    ELSIF v_summs.n_sum = 0
          AND v_summs.p > 0
          AND v_summs.ps = 0
    THEN
      calc_sum(par_value => v_summs.p, par_sum_kind => 11, par_sum_sign => -1);
      -- ��� �������� 5 ���� �����������
      -- ��� �������� 6
      -- ��  | ������� �� (���) | ���    |��������� (�) | ��������� (�) | ������ � �������� (��) | ����������� ��������
      -- ��� | ���              | ���    | ����         | ���           | ����                   | �<��, ��=0, ���=0, ���=0
    ELSIF v_summs.vs = 0
          AND v_summs.vchp = 0
          AND v_summs.did = 0
          AND v_summs.n_sum > 0
          AND v_summs.p = 0
          AND v_summs.ps > 0
          AND v_summs.n_sum < v_summs.ps
    THEN
      calc_sum(par_sum_kind => 1);
      -- ��� �������� 7
      -- ��       | ������� �� (���) | ���      |��������� (�) | ��������� (�) | ������ � �������� (��) | ����������� ��������
      -- ���/���� |  ���/����         | ���/���� | ����         | ���           | ����                   |  � - (��+���+���) = ��
    ELSIF v_summs.n_sum > 0
          AND v_summs.p = 0
          AND v_summs.ps > 0
          AND v_summs.n_sum - (v_summs.vs + v_summs.vchp + v_summs.did) = v_summs.ps
    THEN
      IF v_summs.n_div != v_summs.n_sum
      THEN
        calc_sum(par_value => v_summs.n_sum, par_sum_kind => 10);
      ELSE
        calc_sum(par_sum_kind => 0);
      END IF;
      -- ��� �������� 8
      -- ��       | ������� �� (���) | ���      |��������� (�) | ��������� (�) | ������ � �������� (��) | ����������� ��������
      -- ����/��� | ����/���         | ����/��� |���           | ���           | ���                    | ��+���+���>0
    ELSIF v_summs.n_sum = 0
          AND v_summs.p = 0
          AND v_summs.ps = 0
          AND v_summs.vs + v_summs.vchp + v_summs.did > 0
    THEN
      calc_sum(par_sum_kind => 10);
      -- ��� �������� 9
      -- ��       | ������� �� (���) | ���      |��������� (�) | ��������� (�) | ������ � �������� (��) | ����������� ��������
      -- ���/���� | ���/����         | ���/���� | ����         | ���           | ����                   | ��+���+���>�
    ELSIF v_summs.n_sum > 0
          AND v_summs.p = 0
          AND v_summs.ps > 0
          AND v_summs.vs + v_summs.vchp + v_summs.did > v_summs.n_sum
    THEN
      IF v_summs.n_div != v_summs.n_sum
      THEN
        calc_sum(par_value => v_summs.n_sum + v_summs.ps, par_sum_kind => 12);
      ELSE
        calc_sum(par_sum_kind => 2);
      END IF;
      -- ��� �������� 10
      -- ��       |������� �� (���) | ���        |��������� (�) | ��������� (�) | ������ � �������� (��) | ����������� ��������
      -- ���/���� | ���/����        | ����       | ����         | ���           | ����                   | � - (��+���+���-������(���*0,13;0)) = ��
    ELSIF v_summs.did > 0
          AND v_summs.n_sum > 0
          AND v_summs.p = 0
          AND v_summs.ps > 0
          AND v_summs.n_sum - (v_summs.vs + v_summs.vchp + v_summs.did - ROUND(v_summs.did * 0.13, 0)) =
          v_summs.ps
    THEN
      IF v_summs.n_div != v_summs.n_sum
      THEN
        calc_sum(par_value => v_summs.n_sum, par_sum_kind => 10);
      ELSE
        calc_sum(par_sum_kind => 0);
      END IF;
      -- ��� �������� 11
      -- ��       |������� �� (���) | ���        |��������� (�) | ��������� (�) | ������ � �������� (��) | ����������� ��������
      -- ���      | ���             | ���        | ���          | ���           | ���                    | ���
    ELSIF v_summs.vs + v_summs.vchp + v_summs.did + v_summs.n_sum + v_summs.p + v_summs.ps = 0
    THEN
      calc_sum(par_sum_kind => 3);
      -- ��� �������� 12
      -- ��       |������� �� (���) | ���        |��������� (�) | ��������� (�) | ������ � �������� (��) | ����������� ��������
      -- ���/���� | ���/����        | ���/����   | ���          |����           | ����                   | ���
    ELSIF v_summs.n_sum = 0
          AND v_summs.p > 0
          AND v_summs.ps > 0
    THEN
      calc_sum(par_value => v_summs.n_sum + v_summs.ps - v_summs.p, par_sum_kind => 12);
      -- ��� �������� 13
      -- ��       |������� �� (���) | ���        |��������� (�) | ��������� (�) | ������ � �������� (��) | ����������� ��������
      -- ���/���� | ���/����        | ���/����   | ����         | ���           | ����                   | "��+���+���>0 � - (��+���+���-������(���*0,13;0)) < ��"
      -- ��� ���������� ������������� �� ������������ ��� ��- � + (��+���+���-������(���*0,13;0))"
    ELSIF v_summs.n_sum > 0
          AND v_summs.p = 0
          AND v_summs.ps > 0
          AND v_summs.vs + v_summs.did + v_summs.vchp > 0
          AND v_summs.n_sum - (v_summs.vs + v_summs.vchp + v_summs.did - ROUND(v_summs.did * 0.13, 0)) <
          v_summs.ps
    THEN
      calc_sum(par_value    => v_summs.ps +
                               (v_summs.vs + v_summs.vchp + v_summs.did - ROUND(v_summs.did * 0.13, 0))
              ,par_sum_kind => 13);
    ELSE
      raise_application_error(-20001
                             ,'���������� ������������� ������� �������������� ��������. ������� �� �������� ��� ���������������� ��� ��������!');
    END IF;
  END make_correct_trans_auto;
  /*
  ����������� ���� �� ����� ������� ��������������� � ������� ��������� ������� �������� ���� ��� ������ ��������� �� ������ ��� ������ ��������� � �������
  @author  ������ �. 23.1.2015
  */
  FUNCTION claim_not_exists(par_policy_header_id p_pol_header.policy_header_id%TYPE) RETURN BOOLEAN IS
    v_count NUMBER;
  BEGIN
    SELECT COUNT(*)
      INTO v_count
      FROM dual
     WHERE EXISTS (SELECT NULL
              FROM c_event        e
                  ,c_claim_header ch
                  ,as_asset       a
                  ,c_claim        c
                  ,p_pol_header   pph
                  ,p_policy       pp
                  ,t_peril        tp
             WHERE pph.policy_header_id = par_policy_header_id
               AND pp.pol_header_id = pph.policy_header_id
               AND pp.policy_id = a.p_policy_id
               AND e.as_asset_id = a.as_asset_id
               AND ch.c_event_id = e.c_event_id
               AND ch.c_claim_header_id = c.c_claim_header_id
               AND ch.peril_id = tp.id
               AND tp.description LIKE '������ ���������������%'
               AND EXISTS (SELECT NULL
                      FROM doc_status     ds
                          ,doc_status_ref dsf
                     WHERE ds.document_id = c.c_claim_id
                       AND ds.doc_status_ref_id = dsf.doc_status_ref_id
                       AND dsf.brief IN ('REFUSE_PAY', 'FOR_PAY')));
    RETURN v_count = 0;
  END claim_not_exists;

  /**
   * �������� ������� ������� �� ����
   * @author  ������ �. 28.1.2015
   -- %param par_policy_id  �� ������ ��
  */
  PROCEDURE check_claim(par_policy_id p_policy.policy_id%TYPE) IS
    vr_policy           dml_p_policy.tt_p_policy;
    vr_t_decline_reason dml_t_decline_reason.tt_t_decline_reason;
  BEGIN
    /*� �������� ������� ������� �� ����. ���� ������� ����������� ������� ��������������� �
    ����������� ���� �� ����� ������� ��������������� � ������� ��������� ������� �������� ���� ���
     ������ ��������� �� ������ ��� ������ ��������� � �������, �� �������� ������ �������� ���� �� �������. */
    vr_policy           := dml_p_policy.get_record(par_policy_id => par_policy_id);
    vr_t_decline_reason := dml_t_decline_reason.get_record(par_t_decline_reason_id => vr_policy.decline_reason_id);

    IF vr_t_decline_reason.brief = '������ ���������������'
       AND claim_not_exists(par_policy_header_id => vr_policy.pol_header_id)
    THEN
      ex.raise_custom('���� �� �������');
    END IF;
  END check_claim;

  /**
   * ��������: ������� � ������� �������� �������� ���� ������� ����������. � ������� - ����������
   * @author  ������ �. 28.1.2015
   -- %param par_policy_id  �� ������ ��
  */
  PROCEDURE check_was_quit_to_pay_status(par_policy_id p_policy.policy_id%TYPE) IS
    v_count NUMBER;
  BEGIN
    SELECT COUNT(*)
      INTO v_count
      FROM dual
     WHERE EXISTS (SELECT NULL
              FROM doc_status     ds
                  ,doc_status_ref src
                  ,doc_status_ref dest
             WHERE ds.document_id = par_policy_id
               AND ds.src_doc_status_ref_id = src.doc_status_ref_id
               AND ds.doc_status_ref_id = dest.doc_status_ref_id
               AND src.brief = 'QUIT_TO_PAY'
               AND dest.brief = 'QUIT');
    IF v_count = 1
    THEN
      ex.raise_custom('������� ��������, �.�. ��� ������� "���������. � �������"-"���������"');
    END IF;
  END check_was_quit_to_pay_status;

  /**
   * ��������: ���������� � �������� ���� ���������� ������������ ��� ������ 0, �� ������
   * @author  ������ �. 6.3.2015
   -- %param par_policy_id  �� ������ ��
  */
  PROCEDURE check_overpayment_and_debt(par_policy_id p_policy.policy_id%TYPE) IS
    v_count NUMBER;
  BEGIN
    SELECT COUNT(*)
      INTO v_count
      FROM dual
     WHERE EXISTS (SELECT NULL
              FROM p_pol_decline p
             WHERE p.p_policy_id = par_policy_id
               AND p.overpayment > 0
               AND p.debt_fee_fact > 0);
    IF v_count = 1
    THEN
      ex.raise_custom('� ���������, � ��������� ������ ����');
    END IF;

  END check_overpayment_and_debt;

END pkg_policy_quit;
/

CREATE OR REPLACE PACKAGE pkg_policy_decline IS

  -- Author  : ARTUR.BAYTIN
  -- Created : 16.11.2014 23:38:15
  -- Purpose : ����� �����������

  -- ���������� 1, ���� ��� ������� ����������� = �������������
  FUNCTION is_policy_annulled(par_policy_id NUMBER) RETURN NUMBER;

  -- ���������� 1, ���� ������ ��, ������������ � ���, ����� "���������. � �������"
  FUNCTION is_ppi_policy_quit_to_pay(par_payment_id NUMBER) RETURN NUMBER;

  FUNCTION calc#1
  (
    par_as_contact_id   as_assured.assured_contact_id%TYPE
   ,par_product_line_id t_product_line.id%TYPE
  ) RETURN NUMBER;

  FUNCTION calc#2
  (
    par_as_contact_id   as_assured.assured_contact_id%TYPE
   ,par_product_line_id t_product_line.id%TYPE
  ) RETURN NUMBER;

  -- ������ ��� �� ���� �����������
  FUNCTION calc#3
  (
    par_as_contact_id   as_assured.assured_contact_id%TYPE
   ,par_product_line_id t_product_line.id%TYPE
  ) RETURN NUMBER;

  FUNCTION calc#4
  (
    par_as_contact_id   as_assured.assured_contact_id%TYPE
   ,par_product_line_id t_product_line.id%TYPE
  ) RETURN NUMBER;

  FUNCTION calc#5
  (
    par_as_contact_id   as_assured.assured_contact_id%TYPE
   ,par_product_line_id t_product_line.id%TYPE
  ) RETURN NUMBER;

  -- depreacted
  -- ������ �������� �� �������� ����
  --FUNCTION calc#6 RETURN NUMBER;

  /*
  * ��� �� ����� ���������
  */
  FUNCTION calc#7
  (
    par_as_contact_id   as_assured.assured_contact_id%TYPE
   ,par_product_line_id t_product_line.id%TYPE
  ) RETURN NUMBER;

  /*
  * ��� ��� ���������������� � ���������� �������� - 400 ���
  */
  FUNCTION calc#8
  (
    par_as_contact_id   as_assured.assured_contact_id%TYPE
   ,par_product_line_id t_product_line.id%TYPE
  ) RETURN NUMBER;

  FUNCTION calc#9
  (
    par_as_contact_id   as_assured.assured_contact_id%TYPE
   ,par_product_line_id t_product_line.id%TYPE
  ) RETURN NUMBER;

  /*
  * ��� ��� ����*��������
  */
  FUNCTION calc#10
  (
    par_as_contact_id   as_assured.assured_contact_id%TYPE
   ,par_product_line_id t_product_line.id%TYPE
  ) RETURN NUMBER;

  FUNCTION calc#11
  (
    par_as_contact_id   as_assured.assured_contact_id%TYPE
   ,par_product_line_id t_product_line.id%TYPE
  ) RETURN NUMBER;

  FUNCTION calc#12
  (
    par_as_contact_id   as_assured.assured_contact_id%TYPE
   ,par_product_line_id t_product_line.id%TYPE
  ) RETURN NUMBER;

  FUNCTION calc#13
  (
    par_as_contact_id   as_assured.assured_contact_id%TYPE
   ,par_product_line_id t_product_line.id%TYPE
  ) RETURN NUMBER;

  FUNCTION calc#14
  (
    par_as_contact_id   as_assured.assured_contact_id%TYPE
   ,par_product_line_id t_product_line.id%TYPE
  ) RETURN NUMBER;

  FUNCTION calc#15
  (
    par_as_contact_id   as_assured.assured_contact_id%TYPE
   ,par_product_line_id t_product_line.id%TYPE
  ) RETURN NUMBER;

  FUNCTION calc#16
  (
    par_as_contact_id   as_assured.assured_contact_id%TYPE
   ,par_product_line_id t_product_line.id%TYPE
  ) RETURN NUMBER;

  FUNCTION calc#17
  (
    par_as_contact_id   as_assured.assured_contact_id%TYPE
   ,par_product_line_id t_product_line.id%TYPE
  ) RETURN NUMBER;

  FUNCTION calc#18
  (
    par_as_contact_id   as_assured.assured_contact_id%TYPE
   ,par_product_line_id t_product_line.id%TYPE
  ) RETURN NUMBER;

  FUNCTION calc#19
  (
    par_as_contact_id   as_assured.assured_contact_id%TYPE
   ,par_product_line_id t_product_line.id%TYPE
  ) RETURN NUMBER;

  FUNCTION calc#20
  (
    par_as_contact_id   as_assured.assured_contact_id%TYPE
   ,par_product_line_id t_product_line.id%TYPE
  ) RETURN NUMBER;

  FUNCTION calc#21
  (
    par_as_contact_id   as_assured.assured_contact_id%TYPE
   ,par_product_line_id t_product_line.id%TYPE
  ) RETURN NUMBER;

  FUNCTION calc#22
  (
    par_as_contact_id   as_assured.assured_contact_id%TYPE
   ,par_product_line_id t_product_line.id%TYPE
  ) RETURN NUMBER;

  FUNCTION calc#23
  (
    par_as_contact_id   as_assured.assured_contact_id%TYPE
   ,par_product_line_id t_product_line.id%TYPE
  ) RETURN NUMBER;

  FUNCTION calc#24
  (
    par_as_contact_id   as_assured.assured_contact_id%TYPE
   ,par_product_line_id t_product_line.id%TYPE
  ) RETURN NUMBER;

  FUNCTION calc#25
  (
    par_as_contact_id   as_assured.assured_contact_id%TYPE
   ,par_product_line_id t_product_line.id%TYPE
  ) RETURN NUMBER;

  --FUNCTION calc#26 RETURN NUMBER;

  FUNCTION calc#27 RETURN NUMBER;

  --FUNCTION calc#28 RETURN NUMBER;

  FUNCTION calc#29 RETURN NUMBER;

  -- ��������� �� ���������� ��� ��
  FUNCTION calc#30
  (
    par_as_contact_id   as_assured.assured_contact_id%TYPE
   ,par_product_line_id t_product_line.id%TYPE
  ) RETURN NUMBER;

  --FUNCTION calc#31 RETURN NUMBER;

  --deprecated
  --������ ����� � �������
  --FUNCTION calc#32 RETURN NUMBER;

  FUNCTION calc#33
  (
    par_as_contact_id   as_assured.assured_contact_id%TYPE
   ,par_product_line_id t_product_line.id%TYPE
  ) RETURN NUMBER;

  /*
  * ������ ��� �� ���������� ��� ��
  * (�� ����������� ��������� ������������ ����� �� ���� ��� ���������
  * ��������� �����, �����, �������, ��������) �������� ��� ������ ���������
  */
  FUNCTION calc#34
  (
    par_as_contact_id   as_assured.assured_contact_id%TYPE
   ,par_product_line_id t_product_line.id%TYPE
  ) RETURN NUMBER;

  FUNCTION calc#35
  (
    par_as_contact_id   as_assured.assured_contact_id%TYPE
   ,par_product_line_id t_product_line.id%TYPE
  ) RETURN NUMBER;

  -- ������� ��������
  FUNCTION calc#36
  (
    par_as_contact_id   as_assured.assured_contact_id%TYPE
   ,par_product_line_id t_product_line.id%TYPE
  ) RETURN NUMBER;

  -- ������� ��������
  FUNCTION calc#37
  (
    par_as_contact_id   as_assured.assured_contact_id%TYPE
   ,par_product_line_id t_product_line.id%TYPE
  ) RETURN NUMBER;

  -- ������� ��������
  FUNCTION calc#38
  (
    par_as_contact_id   as_assured.assured_contact_id%TYPE
   ,par_product_line_id t_product_line.id%TYPE
  ) RETURN NUMBER;

  FUNCTION calc#39
  (
    par_as_contact_id   as_assured.assured_contact_id%TYPE
   ,par_product_line_id t_product_line.id%TYPE
  ) RETURN NUMBER;

  -- ������ ���
  FUNCTION calc#40
  (
    par_as_contact_id   as_assured.assured_contact_id%TYPE
   ,par_product_line_id t_product_line.id%TYPE
  ) RETURN NUMBER;

  -- ������ ���
  FUNCTION calc#41
  (
    par_as_contact_id   as_assured.assured_contact_id%TYPE
   ,par_product_line_id t_product_line.id%TYPE
  ) RETURN NUMBER;

  -- ������ ���
  FUNCTION calc#42
  (
    par_as_contact_id   as_assured.assured_contact_id%TYPE
   ,par_product_line_id t_product_line.id%TYPE
  ) RETURN NUMBER;

  FUNCTION calc#43
  (
    par_as_contact_id   as_assured.assured_contact_id%TYPE
   ,par_product_line_id t_product_line.id%TYPE
  ) RETURN NUMBER;

  FUNCTION calc#44
  (
    par_as_contact_id   as_assured.assured_contact_id%TYPE
   ,par_product_line_id t_product_line.id%TYPE
  ) RETURN NUMBER;

  FUNCTION calc#45
  (
    par_as_contact_id   as_assured.assured_contact_id%TYPE
   ,par_product_line_id t_product_line.id%TYPE
  ) RETURN NUMBER;

  FUNCTION calc#46
  (
    par_as_contact_id   as_assured.assured_contact_id%TYPE
   ,par_product_line_id t_product_line.id%TYPE

  ) RETURN NUMBER;

  FUNCTION calc#47
  (
    par_as_contact_id   as_assured.assured_contact_id%TYPE
   ,par_product_line_id t_product_line.id%TYPE
  ) RETURN NUMBER;

  FUNCTION calc#48
  (
    par_as_contact_id   as_assured.assured_contact_id%TYPE
   ,par_product_line_id t_product_line.id%TYPE
  ) RETURN NUMBER;

  FUNCTION calc#49
  (
    par_as_contact_id   as_assured.assured_contact_id%TYPE
   ,par_product_line_id t_product_line.id%TYPE
  ) RETURN NUMBER;

  -- ��� ��� ��������� ��������� �������
  FUNCTION calc#68
  (
    par_as_contact_id   as_assured.assured_contact_id%TYPE
   ,par_product_line_id t_product_line.id%TYPE
  ) RETURN NUMBER;

  /*
  * ��� ��� ��������� �������������� �������
  */
  FUNCTION calc#52
  (
    par_as_contact_id   as_assured.assured_contact_id%TYPE
   ,par_product_line_id t_product_line.id%TYPE
  ) RETURN NUMBER;

  /*
  * �������������� �������� �����
  */
  FUNCTION calc#53
  (
    par_as_contact_id   as_assured.assured_contact_id%TYPE
   ,par_product_line_id t_product_line.id%TYPE
  ) RETURN NUMBER;

  --������ ���
  --FUNCTION calc#54 RETURN NUMBER;

  FUNCTION calc#60
  (
    par_as_contact_id   as_assured.assured_contact_id%TYPE
   ,par_product_line_id t_product_line.id%TYPE
  ) RETURN NUMBER;

  FUNCTION calc#61
  (
    par_as_contact_id   as_assured.assured_contact_id%TYPE
   ,par_product_line_id t_product_line.id%TYPE

  ) RETURN NUMBER;

  FUNCTION calc#62
  (
    par_as_contact_id   as_assured.assured_contact_id%TYPE
   ,par_product_line_id t_product_line.id%TYPE
  ) RETURN NUMBER;

  FUNCTION calc#64
  (
    par_as_contact_id   as_assured.assured_contact_id%TYPE
   ,par_product_line_id t_product_line.id%TYPE
  ) RETURN NUMBER;

  FUNCTION calc#63
  (
    par_as_contact_id   as_assured.assured_contact_id%TYPE
   ,par_product_line_id t_product_line.id%TYPE
  ) RETURN NUMBER;

  FUNCTION calc#65
  (
    par_as_contact_id   as_assured.assured_contact_id%TYPE
   ,par_product_line_id t_product_line.id%TYPE
  ) RETURN NUMBER;

  FUNCTION calc#66
  (
    par_as_contact_id   as_assured.assured_contact_id%TYPE
   ,par_product_line_id t_product_line.id%TYPE
  ) RETURN NUMBER;

  -- ��������� �� ���������� � ��
  FUNCTION calc#67
  (
    par_as_contact_id   as_assured.assured_contact_id%TYPE
   ,par_product_line_id t_product_line.id%TYPE
  ) RETURN NUMBER;

  FUNCTION get_cover_decline RETURN dml_p_cover_decline.typ_nested_table
    PIPELINED;
  /* ������� ��� ��������� ������������� ������, ����� �������� �� ������� �������.
  �������������� �������� ���� ����������� �� */
  PROCEDURE annulate_setoff(par_policy_id p_policy.policy_id%TYPE);

  /* ���������� ������� */
  PROCEDURE calculate_decline
  (
    par_policy_id  p_policy.policy_id%TYPE
   ,par_result     OUT p_decline_pack_detail.result%TYPE
   ,par_commentary OUT p_decline_pack_detail.commentary%TYPE
  );

  /* ���������� ������� (�������) */
  PROCEDURE calculate_decline(par_policy_id p_policy.policy_id%TYPE);

  /* �������� ������ ���������� */
  PROCEDURE create_decline_policy
  (
    par_decline_pack_detail_id p_decline_pack_detail.p_decline_pack_detail_id%TYPE
   ,par_result                 OUT p_decline_pack_detail.result%TYPE
   ,par_commentary             OUT p_decline_pack_detail.commentary%TYPE
   ,par_new_policy_id          OUT p_policy.policy_id%TYPE
  );

  -- ��� �����
  /* ���������� ��������� ������� ������� �� ��������� */
  PROCEDURE prepare_epg_temp_data(par_pol_header_id p_pol_header.policy_header_id%TYPE);
  PROCEDURE prepare_trans_temp_data(par_pol_header_id p_pol_header.policy_header_id%TYPE);
  PROCEDURE prepare_surr_temp_data(par_policy_id p_policy.policy_id%TYPE);

END pkg_policy_decline;
/
CREATE OR REPLACE PACKAGE BODY pkg_policy_decline IS
  /*
  TODO: owner="artur.baytin" category="Fix" priority="3 - Low" created="21.11.2014"
  text="�������� ����������� �� ���� ����������/��������"
  */
  /*
  TODO: owner="artur.baytin" category="Fix" priority="2 - Medium" created="21.11.2014"
  text="��������� ��� ���� ����������, �� ����������� ������� �� ���������������� ����� ����� ������"
  */
  /*
  TODO: owner="artur.baytin" category="Fix" priority="1 - High" created="21.11.2014"
  text="������� ������� �������"
  */
  /*
  TODO: owner="artur.baytin" category="Fix" priority="3 - Low" created="21.11.2014"
  text="�������� assert()"
  */
  gc_ok          CONSTANT p_decline_pack_detail.result%TYPE := 1; -- ��������� ����������: ��
  gc_error       CONSTANT p_decline_pack_detail.result%TYPE := 2; -- ��������� ����������: ������
  gc_max_date    CONSTANT DATE := to_date('31.12.2999', 'dd.mm.yyyy'); -- ������������ ����. ������������ ��� ������ NULL ��� ����������� ����������� ����
  gc_charge      CONSTANT NUMBER(1) := 0; -- ����������
  gc_charge_msfo CONSTANT NUMBER(1) := 1; -- ���������� ����
  gc_payment     CONSTANT NUMBER(1) := 2; -- ������

  gc_assur_doctyp_med_exam CONSTANT NUMBER := dml_assured_docum_type.get_id_by_brief('MEDICAL EXAM');

  TYPE tt_bool_by_int IS TABLE OF BOOLEAN INDEX BY BINARY_INTEGER;
  gv_is_admin_cost_cache tt_bool_by_int;

  TYPE tt_number_by_asset_contact IS TABLE OF tmp_decline_trans_data.acc_amount%TYPE INDEX BY BINARY_INTEGER;
  TYPE tt_number_by_program IS TABLE OF tt_number_by_asset_contact INDEX BY BINARY_INTEGER;
  gv_all_payments_cache tt_number_by_program;

  TYPE tt_num_by_num IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  gv_contact2asset tt_num_by_num;

  gv_decline_date        DATE; -- ���� �����������
  gv_grace_start         DATE; -- ���� ������ �� (DB��)
  gv_grace_end           DATE; -- ���� ��������� �� (DE��)
  gv_epg_start           DATE; -- ���� ������ ��� (DB���)
  gv_epg_end             DATE; -- ���� ��������� ��� (DE���)
  gv_is_periodical_terms NUMBER; -- ������ �� �� � ���������? 0 - ���, 1 - ��
  gv_rvd_percent         t_decline_calc_policy.rvd_percent%TYPE; -- % ���
  gvr_pol_decline        dml_p_pol_decline.tt_p_pol_decline; -- ������ �����������
  gvt_cover_decline      dml_p_cover_decline.typ_nested_table;
  gvr_policy             dml_p_policy.tt_p_policy; -- ������ ��

  gc_decline_reason_id_unpayed  CONSTANT NUMBER := dml_t_decline_reason.get_id_by_brief('�����������');
  gc_decline_reason_id_unpayed0 CONSTANT NUMBER := dml_t_decline_reason.get_id_by_brief('��������0');

  -- ���������� 1, ���� ��� ������� ����������� = �������������
  FUNCTION is_policy_annulled(par_policy_id NUMBER) RETURN NUMBER IS
    v_str t_decline_type.brief%TYPE;
  BEGIN

    SELECT dt.brief
      INTO v_str
      FROM p_policy         p
          ,t_decline_reason dr
          ,t_decline_type   dt
     WHERE dr.t_decline_reason_id = p.decline_reason_id
       AND dt.t_decline_type_id = dr.t_decline_type_id
       AND p.policy_id = par_policy_id;

    CASE
      WHEN v_str IS NULL THEN
        RETURN NULL;
      WHEN v_str = '�������������' THEN
        RETURN 1;
      ELSE
        RETURN 0;
    END CASE;

  EXCEPTION
    WHEN no_data_found THEN
      RETURN NULL;
    WHEN OTHERS THEN
      RAISE;
  END;

  -- ���������� 1, ���� ������ ��, ������������ � ���, ����� "���������. � �������"
  FUNCTION is_ppi_policy_quit_to_pay(par_payment_id NUMBER) RETURN NUMBER IS
    v_cnt NUMBER;
  BEGIN
    SELECT COUNT(1)
      INTO v_cnt
      FROM ac_payment ap
          ,doc_doc    dd
          ,p_policy   p
     WHERE ap.payment_id = dd.child_id
       AND dd.parent_id = p.policy_id
       AND doc.get_doc_status_brief(p.policy_id) = 'QUIT_TO_PAY'
       AND ap.payment_id = par_payment_id;

    IF v_cnt = 0
    THEN
      RETURN 0;
    ELSE
      RETURN 1;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END;

  FUNCTION get_cover_decline RETURN dml_p_cover_decline.typ_nested_table
    PIPELINED IS
  BEGIN
    FOR v_idx IN gvt_cover_decline.first .. gvt_cover_decline.last
    LOOP
      PIPE ROW(gvt_cover_decline(v_idx));
    END LOOP;
  END get_cover_decline;

  FUNCTION get_row_values
  (
    par_as_contact_id   as_assured.assured_contact_id%TYPE
   ,par_product_line_id t_product_line.id%TYPE
  ) RETURN dml_p_cover_decline.tt_p_cover_decline IS
    vr_result dml_p_cover_decline.tt_p_cover_decline;
  BEGIN
    BEGIN
      SELECT *
        INTO vr_result
        FROM TABLE(get_cover_decline) cd
       WHERE cd.as_asset_id = gv_contact2asset(par_as_contact_id)
         AND cd.t_product_line_id = par_product_line_id;
    EXCEPTION
      WHEN no_data_found THEN
        NULL;
    END;
    RETURN vr_result;
  END get_row_values;

  FUNCTION get_total_values RETURN dml_p_cover_decline.tt_p_cover_decline IS
    vr_result dml_p_cover_decline.tt_p_cover_decline;
  BEGIN
    SELECT SUM(redemption_sum)
          ,SUM(add_invest_income)
          ,SUM(return_bonus_part)
          ,SUM(bonus_off_prev)
          ,SUM(bonus_off_current)
          ,SUM(admin_expenses)
          ,SUM(underpayment_actual)
          ,SUM(add_policy_surrender)
          ,SUM(underpayment_previous)
          ,SUM(underpayment_current)
          ,SUM(underpayment_lp)
          ,SUM(unpayed_premium_previous)
          ,SUM(unpayed_premium_current)
          ,SUM(unpayed_premium_lp)
          ,SUM(premium_msfo)
          ,SUM(unpayed_msfo_prem_correction)
          ,SUM(overpayment)
      INTO vr_result.redemption_sum
          ,vr_result.add_invest_income
          ,vr_result.return_bonus_part
          ,vr_result.bonus_off_prev
          ,vr_result.bonus_off_current
          ,vr_result.admin_expenses
          ,vr_result.underpayment_actual
          ,vr_result.add_policy_surrender
          ,vr_result.underpayment_previous
          ,vr_result.underpayment_current
          ,vr_result.underpayment_lp
          ,vr_result.unpayed_premium_previous
          ,vr_result.unpayed_premium_current
          ,vr_result.unpayed_premium_lp
          ,vr_result.premium_msfo
          ,vr_result.unpayed_msfo_prem_correction
          ,vr_result.overpayment
      FROM TABLE(get_cover_decline) cd;
    RETURN vr_result;
  END get_total_values;

  /* ������� ��� ��������� ������������� ������, ����� �������� �� ������� �������.
  �������������� �������� ���� ����������� �� */
  PROCEDURE annulate_setoff(par_policy_id p_policy.policy_id%TYPE) IS
    vr_policy dml_p_policy.tt_p_policy;
    v_count   NUMBER;
  BEGIN

    --������ 412697
    SELECT COUNT(*)
      INTO v_count
      FROM fv_pol_decline   fpd
          ,t_decline_reason tdr
     WHERE fpd.policy_id = par_policy_id
       AND tdr.t_decline_reason_id = fpd.decline_reason_id
       AND tdr.t_decline_type_id = (SELECT tdt.t_decline_type_id
                                      FROM t_decline_type tdt
                                     WHERE tdt.brief = '�������������');
    --

    IF v_count = 0
    THEN
      vr_policy := dml_p_policy.get_record(par_policy_id => par_policy_id);
      IF vr_policy.decline_date IS NOT NULL
      THEN
        pkg_a7.annulated_payment(par_policy_id => par_policy_id
                                ,par_from_date => vr_policy.decline_date);
      ELSE
        ex.raise('������ ��������� ������ ������������� ������, �.�. ����������� ���� �����������.');
      END IF;
    END IF;

  END annulate_setoff;

  PROCEDURE determine_calc_method_policy
  (
    par_policy_id              p_policy.policy_id%TYPE
   ,par_add_parameter          t_decline_calc_policy.additional_condition%TYPE
   ,par_decline_calc_policy_id OUT t_decline_calc_policy.t_decline_calc_policy_id%TYPE
   ,par_result                 OUT NUMBER
   ,par_commentary             OUT VARCHAR2
  ) IS
    v_additional_condition t_decline_calc_policy.additional_condition%TYPE;
  BEGIN
    assert(par_policy_id IS NULL, 'ID ������ ������ ���� ������.');
    assert(par_add_parameter IS NULL
          ,'�������� ��������������� ��������� ������ ���� �������.');
    assert(par_policy_id IS NULL, 'ID ������ ������ ���� ������.');
    /*
    ���� ������ � ������� "������ ���� �����������. �� ��������", ��� �������
    ������� �����������, �������� ������� � ������� ��������� �
    �������� �����������, ��������� ��������� � ��������� �������� ������ ��.
    ��� ���� �������� ���. ������� ������ ��������� � ���������� ��� ���� ������ 0;
    ��������� � ������, ��� ���. ������� ��������� � ����������.
    */
    SELECT additional_condition
          ,t_decline_calc_policy_id
      INTO v_additional_condition
          ,par_decline_calc_policy_id
      FROM (SELECT cp.additional_condition
                  ,cp.t_decline_calc_policy_id
              FROM p_policy              pp
                  ,t_decline_calc_policy cp
             WHERE pp.policy_id = par_policy_id
               AND pp.t_product_conds_id = cp.t_policyform_product_id
               AND pp.decline_reason_id = cp.t_decline_reason_id
               AND cp.additional_condition IN (0, par_add_parameter)
             ORDER BY cp.additional_condition DESC)
     WHERE rownum = 1;

    par_result     := gc_ok;
    par_commentary := NULL;
  EXCEPTION
    WHEN no_data_found THEN
      /*
      ��������� ���������� ��������� ������������ �������� ������� �� ��������  �� ���������� ��������� �����������:
      * ��������� ��������� � �2 � ��������� � �������;
      * ����������� � ����� ���������� ������;
      * �� ������� �� �������� � �����
      */
      par_result                 := gc_error;
      par_commentary             := '������ � ������� "������ ���� �����������. �� ��������" � ���������� �������� �����������, ��������� ��������� � ��������� �� �������.';
      par_decline_calc_policy_id := NULL;
  END determine_calc_method_policy;

  PROCEDURE determine_calc_method_program
  (
    par_decline_calc_policy_id  t_decline_calc_policy.t_decline_calc_policy_id%TYPE
   ,par_policy_surr_existence   t_decline_calc_program.policy_surr_existence%TYPE
   ,par_product_line_id         t_product_line.id%TYPE
   ,par_decline_calc_program_id OUT t_decline_calc_program.t_decline_calc_program_id%TYPE
   ,par_result                  OUT NUMBER
   ,par_commentary              OUT VARCHAR2
  ) IS
  BEGIN
    BEGIN
      /*
      ����� ������ � ������� ������� ���� �����������. �� ��������� ��� �������:
      * �������� ���� ��� ������� �� �������� ����� �������� ��������� ��� ������� �� ��������.
      * �������� ���� ���������� ������������� ��������������� ���������� ��������.
      */
      SELECT cp.t_decline_calc_program_id
        INTO par_decline_calc_program_id
        FROM t_decline_calc_program cp
       WHERE cp.t_decline_calc_policy_id = par_decline_calc_policy_id
         AND cp.t_product_line_id = par_product_line_id;
      /*
      ���� ����� ������ �������, ��������� ���������� ��������� ������������ �������� ������� �� ��������� �� ���������� �����������:
      * ��������� ��������� � �1 � ��������� �������;
      * ����������� - �����;
      * �� ������� �� ��������� � �� ��������� ��������
      */
      par_result     := gc_ok;
      par_commentary := NULL;
    EXCEPTION
      WHEN no_data_found THEN
        BEGIN
          /*
          ����� ������ � ������� ������� ���� �����������. �� ��������� ��� �������:
          * �������� ���� ��� ������� �� �������� ����� �������� ��������� ��� ������� �� ��������.
          * �������� ���� ���������� �� ������;
          * �������� ���� �������� �������� ���� ����� �������� ��������� �������� �������� ������
          */
          SELECT cp.t_decline_calc_program_id
            INTO par_decline_calc_program_id
            FROM t_decline_calc_program cp
           WHERE cp.t_decline_calc_policy_id = par_decline_calc_policy_id
             AND cp.t_product_line_id IS NULL
             AND cp.policy_surr_existence = par_policy_surr_existence;

          par_result     := gc_ok;
          par_commentary := NULL;
        EXCEPTION
          WHEN no_data_found THEN
            BEGIN
              /*
              ����� ������ � ������� ������� ���� �����������. �� ��������� ��� �������:
              * �������� ���� ��� ������� �� �������� ����� �������� ��������� ��� ������� �� ��������.
              * �������� ���� ���������� �� ������ � �� ���������� ������ � �������
              ������� ���� �����������. ���������� �� ������� ���������������� �������� ���������� ��������;
              * �������� ���� �������� �ѻ ����� �0 � �� ����������
              */
              SELECT cp.t_decline_calc_program_id
                INTO par_decline_calc_program_id
                FROM t_decline_calc_program cp
               WHERE cp.t_decline_calc_policy_id = par_decline_calc_policy_id
                 AND cp.t_product_line_id IS NULL
                 AND NOT EXISTS (SELECT NULL
                        FROM t_decline_calc_program_ex cpe
                       WHERE cpe.t_decline_calc_policy_id = par_decline_calc_policy_id
                         AND cpe.t_product_line_id = par_product_line_id)
                 AND cp.policy_surr_existence = 0;

              par_result     := gc_ok;
              par_commentary := NULL;
            EXCEPTION
              WHEN no_data_found THEN
                par_result                  := gc_error;
                par_commentary              := '�� ������� ���������� ������ � ������� "������ ���� �����������. �� ���������".';
                par_decline_calc_program_id := NULL;
            END;
        END;
    END;
  END determine_calc_method_program;

  /* ������� ��������� ������ */
  PROCEDURE flush IS
  BEGIN
    gvr_pol_decline        := NULL;
    gvr_policy             := NULL;
    gv_decline_date        := NULL;
    gv_grace_start         := NULL;
    gv_grace_end           := NULL;
    gv_epg_start           := NULL;
    gv_epg_end             := NULL;
    gv_is_periodical_terms := NULL;
    gv_rvd_percent         := NULL;
    gv_is_admin_cost_cache.delete;
    gv_all_payments_cache.delete;
    gvt_cover_decline := dml_p_cover_decline.typ_nested_table();

    DELETE FROM tmp_decline_epg_data;
    DELETE FROM tmp_decline_trans_data;
    DELETE FROM tmp_decline_surr_data;
    DELETE FROM tmp_decline_did_data;
  END flush;
  /* ������������� ���������� ���������� */
  PROCEDURE init_globals
  (
    par_decline_date        DATE
   ,par_policy              dml_p_policy.tt_p_policy
   ,par_pol_decline         dml_p_pol_decline.tt_p_pol_decline
   ,par_decline_calc_policy dml_t_decline_calc_policy.tt_t_decline_calc_policy
  ) IS
    v_effective_decline_date DATE;
  BEGIN
    gv_decline_date := par_decline_date;

    gvr_policy      := par_policy;
    gvr_pol_decline := par_pol_decline;

    gv_rvd_percent := nvl(par_decline_calc_policy.rvd_percent, 0);

    gv_is_periodical_terms := dml_t_payment_terms.get_record(par_policy.payment_term_id).is_periodical;

    /*
    * ���������� �������: ����������� �� �������� ���������� ������ �� �������� � 30 ������� ��
    * � ����������� ������ ������.
    * �������� ������������ ������ ���� ����� ��, �� ����� �� �������� � ������ ������ ���, ��� �� �����
    * ��� ����� �� ������������ � ��������� �., �������� �, ����������� �. ����
    * ������� ��� �������������
    * ���������� ���������� ������� �����������
    * *�������� ���������� ������
    * *�������� ���������� ������ (�������� � ������ �������� ����������� ������ ����� 0)
    */
    IF gvr_policy.decline_reason_id IN (gc_decline_reason_id_unpayed, gc_decline_reason_id_unpayed0)
    THEN
      v_effective_decline_date := par_decline_date - 1;
    ELSE
      v_effective_decline_date := par_decline_date;
    END IF;

    -- distinct ����� ������������ �.�. �� ���� ����������� ����� ���� ��� ���
    -- (�������� � ���������� ���������� � ��������� ������)
    -- ����� �������� group by �� ���� �����, �� distinct ����� ���� ����� �� ���������
    SELECT DISTINCT ed.plan_date
                   ,ed.end_date
      INTO gv_epg_start
          ,gv_epg_end
      FROM tmp_decline_epg_data ed
     WHERE v_effective_decline_date BETWEEN ed.plan_date AND ed.end_date - INTERVAL '1' SECOND;

    BEGIN
      SELECT DISTINCT ed.plan_date
                     ,ed.grace_date + 1
        INTO gv_grace_start
            ,gv_grace_end
        FROM tmp_decline_epg_data ed
       WHERE v_effective_decline_date BETWEEN ed.plan_date AND ed.end_date - INTERVAL '1'
       SECOND
            --AND ed.epg_status_brief = 'PAID'
         AND ed.grace_date != ed.plan_date;

    EXCEPTION
      WHEN no_data_found THEN
        gv_grace_start := NULL;
        gv_grace_end   := NULL;
    END;

  EXCEPTION
    WHEN no_data_found THEN
      ex.raise('����������� ������� ������� �������� �� ���� �����������');
    WHEN too_many_rows THEN
      ex.raise('�������� ��������� ��������� ������� �������� �� ���� �����������');
  END init_globals;

  /* ���������� ��������� ������� ������� �� ��� */
  PROCEDURE prepare_epg_temp_data(par_pol_header_id p_pol_header.policy_header_id%TYPE) IS
  BEGIN
    INSERT INTO tmp_decline_epg_data
      (payment_id, plan_date, grace_date, end_date, epg_status_brief)
      SELECT payment_id
            ,plan_date
            ,grace_date
            ,MAX(nvl(next_plan_date, pol_end_date)) over(PARTITION BY plan_date) end_date
            ,doc_status_brief
        FROM (SELECT ac.payment_id
                    ,ac.plan_date
                    ,ac.grace_date
                    ,lead(ac.plan_date) over(ORDER BY ac.plan_date) next_plan_date
                    ,dsr.brief AS doc_status_brief
                    ,trunc(pp.end_date) + 1 pol_end_date
                FROM p_policy       pp
                    ,doc_doc        dd
                    ,document       dc
                    ,doc_templ      dt
                    ,doc_status_ref dsr
                    ,ac_payment     ac
               WHERE pp.pol_header_id = par_pol_header_id
                 AND pp.policy_id = dd.parent_id
                 AND dd.child_id = dc.document_id
                 AND dc.doc_templ_id = dt.doc_templ_id
                 AND dt.brief = 'PAYMENT'
                 AND dc.doc_status_ref_id = dsr.doc_status_ref_id
                 AND dsr.brief != 'ANNULATED'
                 AND dc.document_id = ac.payment_id) t;
  END prepare_epg_temp_data;

  /* ���������� ��������� ������� ������� �� ��������� */
  PROCEDURE prepare_trans_temp_data(par_pol_header_id p_pol_header.policy_header_id%TYPE) IS
  BEGIN
    INSERT INTO tmp_decline_trans_data
      (trans_id
      ,trans_templ_id
      ,product_line_id
      ,asset_contact_id
      ,document_id
      ,doc_templ_brief
      ,trans_amount
      ,acc_amount
      ,acc_fund_id
      ,doc_date
      ,trans_date
      ,trans_type
      ,trans_period_start_date
      ,trans_period_end_date)
      SELECT trans_id
            ,trans_templ_id
            ,product_line_id
            ,assured_contact_id
            ,document_id
            ,doc_templ_brief
            ,CASE
               WHEN t.trans_type = gc_charge
                    AND number_of_payments IS NOT NULL THEN
                trans_amount / number_of_payments
               ELSE
                trans_amount
             END trans_amount
            ,CASE
               WHEN t.trans_type = gc_charge
                    AND number_of_payments IS NOT NULL THEN
                acc_amount / number_of_payments
               ELSE
                acc_amount
             END acc_amount
            ,acc_fund_id
            ,doc_date
            ,trans_date
            ,t.trans_type
            ,CASE
               WHEN ind IS NULL THEN
                doc_date
               ELSE
                ADD_MONTHS(header_start_date
                          ,pkg_anniversary.get_year_number(header_start_date, doc_date) * 12 +
                           ind * 12 / number_of_payments)
             END AS start_date
            ,CASE
               WHEN ind IS NULL THEN
                CASE doc_templ_brief
                  WHEN 'POLICY' THEN
                   CASE (SELECT pt.is_periodical FROM t_payment_terms pt WHERE pt.id = t.payment_term_id)
                     WHEN 1 THEN
                      pkg_anniversary.get_next_anniversary(header_start_date, doc_date) -- - INTERVAL '1' SECOND
                     ELSE
                      t.pol_end_date
                   END
                  ELSE
                   (SELECT ed.end_date FROM tmp_decline_epg_data ed WHERE ed.payment_id = document_id)
                END
               ELSE
                ADD_MONTHS(header_start_date
                          ,pkg_anniversary.get_year_number(header_start_date, doc_date) * 12 +
                           (ind + 1) * 12 / number_of_payments) -- - INTERVAL '1' SECOND
             END AS end_date
        FROM (SELECT tr.trans_id
                    ,tr.trans_templ_id
                    ,(SELECT plo.product_line_id
                        FROM t_prod_line_option plo
                       WHERE plo.id = tr.a4_ct_uro_id
                         AND tr.a4_ct_ure_id = 310) product_line_id
                    ,(SELECT su.assured_contact_id
                        FROM p_cover    pc
                            ,as_assured su
                       WHERE tr.a5_ct_ure_id = 305
                         AND pc.p_cover_id = tr.a5_ct_uro_id
                         AND pc.as_asset_id = su.as_assured_id) assured_contact_id
                    ,op.document_id
                    ,(SELECT dt.brief
                        FROM document  dc
                            ,doc_templ dt
                       WHERE dc.document_id = op.document_id
                         AND dc.doc_templ_id = dt.doc_templ_id) doc_templ_brief
                    ,CASE
                       WHEN tr.trans_templ_id IN (805, 782, 849, 861) THEN
                        -tr.trans_amount
                       ELSE
                        tr.trans_amount
                     END trans_amount
                    ,CASE
                       WHEN tr.trans_templ_id IN (805, 782, 849, 861) THEN
                        -tr.acc_amount
                       ELSE
                        tr.acc_amount
                     END acc_amount
                    ,tr.acc_fund_id
                    ,tr.doc_date
                    ,tr.trans_date
                    ,CASE
                       WHEN tr.trans_templ_id IN (47, 741, 44, 861, 810, 811, 812) THEN
                        gc_payment
                       WHEN tr.trans_templ_id = 622 THEN
                        gc_charge_msfo
                       ELSE
                        gc_charge
                     END trans_type
                    ,pp.start_date policy_start_date
                    ,ph.start_date header_start_date
                    ,pp.payment_term_id
                    ,trunc(pp.end_date) + 1 pol_end_date
                FROM trans        tr
                    ,oper         op
                    ,p_policy     pp
                    ,p_pol_header ph
               WHERE tr.oper_id = op.oper_id
                 AND op.document_id = pp.policy_id(+)
                 AND pp.pol_header_id = ph.policy_header_id(+)
                 AND (tr.trans_templ_id IN
                     (47, 741, 861, 848, 21, 805, 782, 849, 806, 810, 811, 812, 622) OR
                     tr.trans_templ_id = 44 AND
                     tr.dt_account_id = (SELECT a.account_id FROM account a WHERE a.num = '77.00.01') AND
                     tr.ct_account_id = (SELECT a.account_id FROM account a WHERE a.num = '77.01.02'))
                 AND tr.a2_ct_ure_id = 283
                 AND tr.a2_ct_uro_id IN
                     (SELECT pp.policy_id FROM p_policy pp WHERE pp.pol_header_id = par_pol_header_id)) t

               -- NoFormat Start
                ,(SELECT id
                	 ,ind
                	 ,number_of_payments
                , gc_charge trans_type
                FROM t_payment_terms pt
        WHERE pt.is_periodical = 1
                MODEL
                PARTITION BY(pt.id)
                DIMENSION BY(0 ind2)
                MEASURES(pt.number_of_payments, 0 ind)
                RULES UPSERT
                (
                ind[FOR ind2 FROM 1 TO number_of_payments[0]-1 increment 1] = ind[cv()-1] + 1,
                number_of_payments[ind2 > 0] = number_of_payments[0]
                )
                ) pt
                -- NoFormat End
       WHERE t.payment_term_id = pt.id(+)
         AND t.trans_type = pt.trans_type(+);

  END prepare_trans_temp_data;

  /* ���������� ��������� ������� ������� �� �� */
  PROCEDURE prepare_surr_temp_data(par_policy_id p_policy.policy_id%TYPE) IS
  BEGIN
    -- ������ �� �� ����������� �� ���������� ������
    INSERT INTO tmp_decline_surr_data
      (surr_id
      ,surr_d_id
      ,as_contact_id
      ,product_line_id
      ,payment_number
      ,start_date
      ,end_date
      ,VALUE
      ,version_num
      ,policy_id)
      WITH all_cash_surrs AS
       (SELECT cs.policy_cash_surr_id
              ,csd.policy_cash_surr_d_id
              ,CASE
                 WHEN cs.p_cover_id IS NOT NULL THEN
                  (SELECT aas.assured_contact_id
                     FROM p_cover    pc
                         ,as_assured aas
                    WHERE pc.as_asset_id = aas.as_assured_id
                      AND pc.p_cover_id = cs.p_cover_id)

               -- ���� ��������, ����� �� ������ ���������, ����� � �� �� ������������ p_cover_id
                 WHEN (SELECT COUNT(*)
                         FROM as_asset aa
                        WHERE aa.p_policy_id = cs.policy_id
                          AND EXISTS (SELECT NULL
                                 FROM p_cover            pc
                                     ,t_prod_line_option plo
                                     ,t_product_line     pl
                                WHERE pc.as_asset_id = aa.as_asset_id
                                  AND pc.t_prod_line_option_id = plo.id
                                  AND plo.product_line_id = pl.id
                                  AND pl.t_lob_line_id = cs.t_lob_line_id)) = 1
                      AND
                      cs.contact_id =
                      (SELECT MAX(pi.contact_id) FROM v_pol_issuer pi WHERE pi.policy_id = cs.policy_id) THEN
                  (SELECT aas.assured_contact_id
                     FROM as_asset   aa
                         ,as_assured aas
                    WHERE aa.p_policy_id = cs.policy_id
                      AND aa.as_asset_id = aas.as_assured_id
                      AND EXISTS (SELECT NULL
                             FROM p_cover            pc
                                 ,t_prod_line_option plo
                                 ,t_product_line     pl
                            WHERE pc.as_asset_id = aa.as_asset_id
                              AND pc.t_prod_line_option_id = plo.id
                              AND plo.product_line_id = pl.id
                              AND pl.t_lob_line_id = cs.t_lob_line_id))
                 ELSE
                  cs.contact_id
               END contact_id
              ,CASE
                 WHEN cs.p_cover_id IS NOT NULL THEN
                  (SELECT plo.product_line_id
                     FROM p_cover            pc
                         ,t_prod_line_option plo
                    WHERE pc.p_cover_id = cs.p_cover_id
                      AND pc.t_prod_line_option_id = plo.id)
                 ELSE
                  (SELECT MAX(plo.product_line_id)
                     FROM p_cover            pc
                         ,t_prod_line_option plo
                         ,t_product_line     pl
                          --,as_assured         su
                         ,as_asset se
                    WHERE se.p_policy_id = cs.policy_id
                         --AND su.assured_contact_id = cs.contact_id
                         --AND se.as_asset_id = su.as_assured_id
                      AND pc.as_asset_id = se.as_asset_id
                      AND pc.t_prod_line_option_id = plo.id
                      AND plo.product_line_id = pl.id
                      AND pl.t_lob_line_id = cs.t_lob_line_id)
               END product_line_id
              ,csd.start_cash_surr_date
              ,csd.end_cash_surr_date
              ,csd.value
              ,p.version_num
              ,p.policy_id
          FROM policy_cash_surr cs
              ,policy_cash_surr_d csd
              ,p_pol_header ph
              ,(SELECT pp.policy_id
                      ,pp.start_date
                      ,pp.pol_header_id
                      ,pp.version_num
                  FROM p_policy pp
                 START WITH pp.policy_id = par_policy_id
                CONNECT BY PRIOR pp.prev_ver_id = pp.policy_id) p
         WHERE cs.policy_id = p.policy_id
           AND cs.policy_cash_surr_id = csd.policy_cash_surr_id
           AND p.pol_header_id = ph.policy_header_id
              -- ���� �� ���������� �������� �� � ���������, ����� ���� ������ ���� ��
           AND MOD(MONTHS_BETWEEN(p.start_date, ph.start_date), 12) = 0)
      SELECT t.policy_cash_surr_id
            ,policy_cash_surr_d_id
            ,contact_id
            ,product_line_id
            ,row_number() over(PARTITION BY contact_id, product_line_id ORDER BY start_cash_surr_date)
            ,start_cash_surr_date
            ,end_cash_surr_date
            ,VALUE
            ,version_num
            ,policy_id
        FROM all_cash_surrs t
      /*
      -- ����� ������ �� ��������, ���� �������� � ������� �� ���� �� �� �� ���� � ������ �������
      -- ������ (���: 130519163)
      -- ������ ����� ��������� � calc#2
       WHERE t.policy_cash_surr_d_id IN
             (SELECT MAX(policy_cash_surr_d_id)
                FROM all_cash_surrs t2
               WHERE t2.contact_id = t.contact_id
                 AND t2.product_line_id = t.product_line_id
                 AND t.start_cash_surr_date = t2.start_cash_surr_date)
                 */
      ;
  END prepare_surr_temp_data;

  /* ���������� ��������� ������� ������� �� �� */
  PROCEDURE prepare_did_temp_data(par_pol_header_id p_pol_header.policy_header_id%TYPE) IS
  BEGIN
    INSERT INTO tmp_decline_did_data
      (did_id, as_contact_id, product_line_id, income_date, income_rur, income_cur)
    /*
    SELECT dd.p_add_invest_income_id
          ,(SELECT su.assured_contact_id
             FROM p_pol_header ph
                 ,as_asset     se
                 ,as_assured   su
                 ,contact      co
            WHERE ph.policy_header_id = dd.pol_header_id
              AND ph.max_uncancelled_policy_id = se.p_policy_id
              AND se.as_asset_id = su.as_assured_id
              AND su.assured_contact_id = co.contact_id
              AND co.obj_name = dd.as_asset_name)
          ,dd.t_product_line_id
          ,dd.income_date
          ,dd.add_income_rur
          ,dd.add_income_cur
      FROM p_add_invest_income dd
      */
      SELECT dd.p_add_invest_income_id
            ,CASE
               WHEN (SELECT COUNT(*)
                       FROM ins.p_pol_header ph
                           ,ins.as_asset     se
                      WHERE ph.policy_header_id = dd.pol_header_id
                        AND ph.max_uncancelled_policy_id = se.p_policy_id) = 1 THEN
                (SELECT su.assured_contact_id
                   FROM ins.p_pol_header ph
                       ,ins.as_asset     se
                       ,ins.as_assured   su
                  WHERE ph.policy_header_id = dd.pol_header_id
                    AND ph.max_uncancelled_policy_id = se.p_policy_id
                    AND se.as_asset_id = su.as_assured_id)
               ELSE
                (SELECT su.assured_contact_id
                   FROM ins.p_pol_header ph
                       ,ins.as_asset     se
                       ,ins.as_assured   su
                       ,ins.contact      co
                  WHERE ph.policy_header_id = dd.pol_header_id
                    AND ph.max_uncancelled_policy_id = se.p_policy_id
                    AND se.as_asset_id = su.as_assured_id
                    AND su.assured_contact_id = co.contact_id
                    AND co.obj_name = TRIM(upper(dd.as_asset_name)))
             END
            ,dd.t_product_line_id
            ,dd.income_date
            ,dd.add_income_rur
            ,dd.add_income_cur
        FROM ins.p_add_invest_income dd
       WHERE dd.pol_header_id = par_pol_header_id;
  END prepare_did_temp_data;

  FUNCTION is_admin_cost(par_product_line_id t_product_line.id%TYPE) RETURN BOOLEAN IS
    v_is_admin_cost NUMBER(1);
  BEGIN
    IF NOT gv_is_admin_cost_cache.exists(par_product_line_id)
    THEN
      SELECT COUNT(1)
        INTO v_is_admin_cost
        FROM dual
       WHERE EXISTS (SELECT NULL
                FROM t_product_line pl
                    ,t_lob_line     ll
               WHERE pl.id = par_product_line_id
                 AND pl.t_lob_line_id = ll.t_lob_line_id
                 AND ll.brief IN ('Adm_Cost_Acc', 'Adm_Cost_Life'));
      gv_is_admin_cost_cache(par_product_line_id) := v_is_admin_cost = 1;
    END IF;
    RETURN gv_is_admin_cost_cache(par_product_line_id);
  END is_admin_cost;

  /* ��� ������ �� ��������������� � ��������� */
  FUNCTION get_all_payments
  (
    par_as_contact_id   as_assured.assured_contact_id%TYPE
   ,par_product_line_id t_product_line.id%TYPE
  ) RETURN tmp_decline_trans_data.acc_amount%TYPE IS
  BEGIN
    IF NOT gv_all_payments_cache.exists(par_as_contact_id)
       OR NOT gv_all_payments_cache(par_as_contact_id).exists(par_product_line_id)
    THEN
      SELECT nvl(SUM(td.acc_amount), 0)
        INTO gv_all_payments_cache(par_as_contact_id)(par_product_line_id)
        FROM tmp_decline_trans_data td
       WHERE td.product_line_id = par_product_line_id
         AND td.asset_contact_id = par_as_contact_id
         AND td.trans_type = gc_payment;
    END IF;
    RETURN gv_all_payments_cache(par_as_contact_id)(par_product_line_id);
  END get_all_payments;

  /* ��� ������ �� �� */
  FUNCTION get_all_payments RETURN tmp_decline_trans_data.acc_amount%TYPE IS
    v_payments tmp_decline_trans_data.acc_amount%TYPE;
  BEGIN
    SELECT nvl(SUM(td.acc_amount), 0)
      INTO v_payments
      FROM tmp_decline_trans_data td
     WHERE td.trans_type = gc_payment;
    RETURN v_payments;
  END get_all_payments;

  FUNCTION get_last_paid_fee_date RETURN DATE IS
    v_last_paid_fee_date DATE;
    v_payment_amount     trans.acc_amount%TYPE;
  BEGIN
    v_payment_amount := get_all_payments;

    SELECT MIN(trans_period_start_date) keep(dense_rank FIRST ORDER BY rest_amount ASC)
      INTO v_last_paid_fee_date
      FROM (SELECT v_payment_amount - SUM(acc_amount) over(ORDER BY trans_period_start_date rows unbounded preceding) AS rest_amount
                  ,trans_period_start_date
              FROM (SELECT td.trans_period_start_date
                          ,SUM(acc_amount) acc_amount
                      FROM tmp_decline_trans_data td
                     WHERE td.trans_type = gc_charge
                     GROUP BY td.trans_period_start_date))
     WHERE rest_amount >= 0;
    RETURN v_last_paid_fee_date;
  END get_last_paid_fee_date;

  FUNCTION get_pvchp
  (
    par_as_contact_id   as_assured.assured_contact_id%TYPE
   ,par_product_line_id t_product_line.id%TYPE
  ) RETURN NUMBER IS
    v_charge_epg_amount NUMBER;
    v_charge_amount     NUMBER;
    v_all_payments      NUMBER;
    v_pvchp             NUMBER;
  BEGIN

    /* ������������ ������ ����� ��� (����), �� ������� ����� ����� ������� ������� */
    SELECT nvl(ROUND(SUM(acc_amount *
                         ((least(trans_period_end_date, gv_epg_end) - trans_period_start_date) /
                         (trans_period_end_date - trans_period_start_date)))
                    ,2)
              ,0)
      INTO v_charge_epg_amount
      FROM (SELECT td.acc_amount
                  ,td.trans_period_start_date
                  ,td.trans_period_end_date
              FROM tmp_decline_trans_data td
             WHERE td.trans_type = gc_charge
               AND td.trans_period_start_date < gv_epg_end /* ���� ���, � ������� ��������� ���� ����������� */
               AND td.product_line_id = par_product_line_id
               AND td.asset_contact_id = par_as_contact_id);

    SELECT nvl(ROUND(SUM(acc_amount *
                         ((least(trans_period_end_date, gv_decline_date) - trans_period_start_date) /
                         (trans_period_end_date - trans_period_start_date)))
                    ,2)
              ,0)
      INTO v_charge_amount
      FROM (SELECT td.acc_amount
                  ,td.trans_period_start_date
                  ,td.trans_period_end_date
              FROM tmp_decline_trans_data td
             WHERE td.trans_type = gc_charge
               AND td.trans_period_start_date < gv_decline_date /* ���� �����������*/
               AND td.product_line_id = par_product_line_id
               AND td.asset_contact_id = par_as_contact_id);

    v_all_payments := get_all_payments(par_as_contact_id, par_product_line_id);
    v_pvchp        := greatest(least(v_all_payments, v_charge_epg_amount) - v_charge_amount, 0);

    RETURN v_pvchp;

  END get_pvchp;

  FUNCTION calc_bonus_off_prev
  (
    par_as_contact_id   as_assured.assured_contact_id%TYPE
   ,par_product_line_id t_product_line.id%TYPE
  ) RETURN NUMBER IS
    v_charge_amount  NUMBER;
    v_payment_amount NUMBER;
    v_calc_result    NUMBER;
    v_row_values     dml_p_cover_decline.tt_p_cover_decline;
  BEGIN

    -- ����� ���������� ������� ��������
    SELECT nvl(ROUND(SUM(acc_amount), 2), 0)
      INTO v_charge_amount
      FROM tmp_decline_trans_data td
     WHERE td.trans_type = gc_charge
       AND td.doc_date < trunc(SYSDATE, 'y') /* 01.01.�������� ���� */
       AND td.product_line_id = par_product_line_id
       AND td.asset_contact_id = par_as_contact_id;

    v_row_values := get_row_values(par_as_contact_id, par_product_line_id);

    v_payment_amount := get_all_payments(par_as_contact_id, par_product_line_id) -
                        v_row_values.overpayment;

    v_calc_result := greatest(v_charge_amount - v_payment_amount - v_row_values.underpayment_actual, 0);

    RETURN v_calc_result;

  END calc_bonus_off_prev;

  FUNCTION calc_bonus_off_current
  (
    par_as_contact_id   as_assured.assured_contact_id%TYPE
   ,par_product_line_id t_product_line.id%TYPE
  ) RETURN NUMBER IS
    v_charge_amount  NUMBER;
    v_payment_amount NUMBER;
    v_calc_result    NUMBER;
    v_row_values     dml_p_cover_decline.tt_p_cover_decline;
  BEGIN

    -- ����� ���������� ������� ��������
    SELECT nvl(ROUND(SUM(acc_amount), 2), 0)
      INTO v_charge_amount
      FROM tmp_decline_trans_data td
     WHERE td.trans_type = gc_charge
       AND td.product_line_id = par_product_line_id
       AND td.asset_contact_id = par_as_contact_id;

    v_row_values := get_row_values(par_as_contact_id, par_product_line_id);

    v_payment_amount := get_all_payments(par_as_contact_id, par_product_line_id) -
                        v_row_values.overpayment;

    v_calc_result := greatest(v_charge_amount - v_payment_amount - v_row_values.underpayment_actual -
                              v_row_values.bonus_off_prev
                             ,0);

    RETURN v_calc_result;

  END calc_bonus_off_current;

  FUNCTION calc_bonus_off_msfo
  (
    par_as_contact_id   as_assured.assured_contact_id%TYPE
   ,par_product_line_id t_product_line.id%TYPE
  ) RETURN NUMBER IS
    v_charge_amount  NUMBER;
    v_payment_amount NUMBER;
    v_calc_result    NUMBER;
    v_row_values     dml_p_cover_decline.tt_p_cover_decline;
  BEGIN
    -- ����� ���������� ������� ��������
    SELECT nvl(ROUND(SUM(acc_amount), 2), 0)
      INTO v_charge_amount
      FROM tmp_decline_trans_data td
     WHERE td.trans_type = gc_charge_msfo
       AND td.product_line_id = par_product_line_id
       AND td.asset_contact_id = par_as_contact_id;

    v_row_values := get_row_values(par_as_contact_id, par_product_line_id);

    v_payment_amount := get_all_payments(par_as_contact_id, par_product_line_id) -
                        v_row_values.overpayment;

    v_calc_result := greatest(v_charge_amount - v_payment_amount - v_row_values.underpayment_actual, 0);

    RETURN v_calc_result;

  END calc_bonus_off_msfo;

  FUNCTION calc#1
  (
    par_as_contact_id   as_assured.assured_contact_id%TYPE
   ,par_product_line_id t_product_line.id%TYPE
  ) RETURN NUMBER IS
    v_calc_result   NUMBER;
    v_current_value NUMBER;
  BEGIN

    IF dml_t_policyform_product.get_record(gvr_pol_decline.t_product_conds_id).is_handchange = 0
    THEN
      SELECT nvl(MAX(sd.value) keep(dense_rank FIRST ORDER BY sd.version_num DESC, sd.policy_id DESC)
                ,0)
        INTO v_calc_result
        FROM tmp_decline_surr_data sd
       WHERE gv_decline_date BETWEEN sd.start_date AND sd.end_date
         AND sd.product_line_id = par_product_line_id;
    ELSE
      BEGIN
        SELECT pc.redemption_sum
          INTO v_current_value
          FROM p_pol_decline   pd
              ,p_cover_decline pc
              ,as_asset        aa
              ,as_assured      aas
         WHERE pd.p_policy_id = gvr_policy.policy_id
           AND pc.p_pol_decline_id = pd.p_pol_decline_id
           AND pc.t_product_line_id = par_product_line_id
           AND aa.p_policy_id = pd.p_policy_id
           AND aa.as_asset_id = aas.as_assured_id
           AND aas.assured_contact_id = par_as_contact_id;
      EXCEPTION
        WHEN no_data_found THEN
          NULL;
        WHEN too_many_rows THEN
          ex.raise('�������� �1. �� ������� ���������� ���������� ������� �������� ��.');
      END;

      v_calc_result := nvl(v_current_value, 0);
    END IF;

    RETURN v_calc_result;
  END calc#1;

  FUNCTION calc#2
  (
    par_as_contact_id   as_assured.assured_contact_id%TYPE
   ,par_product_line_id t_product_line.id%TYPE
  ) RETURN NUMBER IS
    v_calc_result        NUMBER;
    v_last_paid_fee_date DATE;
  BEGIN

    IF gv_is_periodical_terms = 1
    THEN
      v_last_paid_fee_date := get_last_paid_fee_date;
    END IF;

    SELECT nvl(MAX(sd.value) keep(dense_rank FIRST ORDER BY sd.version_num DESC, sd.policy_id DESC), 0)
      INTO v_calc_result
      FROM tmp_decline_surr_data sd
     WHERE least(gv_decline_date, nvl(v_last_paid_fee_date, gc_max_date)) BETWEEN sd.start_date AND
           sd.end_date
       AND sd.product_line_id = par_product_line_id
       AND sd.as_contact_id = par_as_contact_id;

    RETURN v_calc_result;
  END calc#2;

  -- ������ ��� �� ���� �����������
  FUNCTION calc#3
  (
    par_as_contact_id   as_assured.assured_contact_id%TYPE
   ,par_product_line_id t_product_line.id%TYPE
  ) RETURN NUMBER IS
    v_did NUMBER;
  BEGIN
    SELECT MAX(t.add_income_cur) keep(dense_rank FIRST ORDER BY t.income_date DESC)
      INTO v_did
      FROM p_add_invest_income t
     WHERE t.pol_header_id = gvr_policy.pol_header_id
       AND t.t_product_line_id = par_product_line_id
       AND t.income_date <= gv_decline_date;

    RETURN nvl(v_did, 0);

  END calc#3;

  FUNCTION calc#4
  (
    par_as_contact_id   as_assured.assured_contact_id%TYPE
   ,par_product_line_id t_product_line.id%TYPE
  ) RETURN NUMBER IS
    v_pvchp       NUMBER;
    v_calc_result NUMBER := 0;
  BEGIN

    v_pvchp := get_pvchp(par_as_contact_id, par_product_line_id);
    /*  ������ ��������������� ���, ������� ������ � ������� ��� = (���� - ���)*/
    /*v_calc_result := greatest(v_pvchp - get_row_values(par_as_contact_id, par_product_line_id)
    .admin_expenses);*/

    RETURN v_pvchp;
  END calc#4;

  FUNCTION calc#5
  (
    par_as_contact_id   as_assured.assured_contact_id%TYPE
   ,par_product_line_id t_product_line.id%TYPE
  ) RETURN NUMBER IS
    v_is_term        NUMBER(1);
    v_charge_amount  NUMBER;
    v_payment_amount NUMBER;
    v_rvd            NUMBER;
    v_calc_result    NUMBER;
  BEGIN

    /* ����� ���������� */
    SELECT nvl(ROUND(SUM(acc_amount *
                         ((least(trans_period_end_date, gv_epg_end) - trans_period_start_date) /
                         (trans_period_end_date - trans_period_start_date)))
                    ,2)
              ,0)
      INTO v_charge_amount
      FROM (SELECT td.acc_amount
                  ,td.trans_period_start_date
                  ,td.trans_period_end_date
              FROM tmp_decline_trans_data td
             WHERE td.trans_type = gc_charge
               AND td.trans_period_start_date <= gv_decline_date /* ���� ���, � ������� ��������� ���� ����������� */
               AND td.product_line_id = par_product_line_id
               AND td.asset_contact_id = par_as_contact_id);

    /* ����� ����� */
    v_payment_amount := get_all_payments(par_as_contact_id, par_product_line_id);

    /* ��� */
    --v_rvd := get_row_values(par_as_contact_id, par_product_line_id).admin_expenses;

    v_calc_result := least(v_charge_amount, v_payment_amount); -- - v_rvd;

    RETURN v_calc_result;
  END calc#5;

  /*
  * ��� �� ����� ���������
  */
  FUNCTION calc#7
  (
    par_as_contact_id   as_assured.assured_contact_id%TYPE
   ,par_product_line_id t_product_line.id%TYPE
  ) RETURN NUMBER IS
    v_adm_exp_charge NUMBER;
  BEGIN
    SELECT nvl(SUM(t.acc_amount), 0)
      INTO v_adm_exp_charge
      FROM tmp_decline_trans_data t
     WHERE t.trans_type = gc_charge
       AND t.trans_period_start_date < gvr_pol_decline.act_date
       AND t.asset_contact_id = par_as_contact_id
       AND t.product_line_id = par_product_line_id;
    RETURN v_adm_exp_charge;
  END calc#7;

  /*
  * ��� ��� ���������������� � ���������� �������� - 400 ���
  */
  FUNCTION calc#8
  (
    par_as_contact_id   as_assured.assured_contact_id%TYPE
   ,par_product_line_id t_product_line.id%TYPE
  ) RETURN NUMBER IS
    v_product_id   NUMBER;
    v_product_desc t_product.description%TYPE;
    v_costs        NUMBER;
  BEGIN
    /*
    v_product_id   := pkg_policy.get_product_id_by_policy(gvr_policy.policy_id);
    v_product_desc := dml_t_product.get_record(par_product_id => v_product_id).description;

    IF v_product_desc LIKE '%����������������%'
       OR v_product_desc LIKE '%��������� �������%'
    THEN
      v_costs := 400;
    ELSE
      v_costs := 0;
    END IF;
    RETURN v_costs;
    */
    RETURN 400;

  END calc#8;

  FUNCTION calc#9
  (
    par_as_contact_id   as_assured.assured_contact_id%TYPE
   ,par_product_line_id t_product_line.id%TYPE
  ) RETURN NUMBER IS

    v_all_payments      NUMBER;
    v_charge_amount     NUMBER;
    v_charge_epg_amount NUMBER;
    v_pvchp             NUMBER;
    v_calc_result       NUMBER := 0;
  BEGIN
    IF NOT is_admin_cost(par_product_line_id)
    THEN
      v_pvchp := get_pvchp(par_as_contact_id, par_product_line_id);
      /* ������ �������� ��, ������� � ����� �������� ��� �� ������ � ��������� � ��������������� ������� � ������� */
      v_calc_result := ROUND(v_pvchp * (nvl(gv_rvd_percent, 0) / 100), 2);
    ELSE
      v_calc_result := 0;
    END IF;

    RETURN v_calc_result;
  END calc#9;

  /*
  * ��� ��� ����*��������
  */
  FUNCTION calc#10
  (
    par_as_contact_id   as_assured.assured_contact_id%TYPE
   ,par_product_line_id t_product_line.id%TYPE
  ) RETURN NUMBER IS
    v_pvchp       NUMBER;
    v_calc_result NUMBER;
    v_comission   NUMBER;
  BEGIN
    IF NOT is_admin_cost(par_product_line_id)
    THEN
      v_pvchp       := get_pvchp(par_as_contact_id, par_product_line_id);
      v_calc_result := ROUND(v_pvchp * v_comission, 2);
    ELSE
      v_calc_result := 0;
    END IF;
    RETURN v_calc_result;
  END calc#10;

  FUNCTION calc#11
  (
    par_as_contact_id   as_assured.assured_contact_id%TYPE
   ,par_product_line_id t_product_line.id%TYPE
  ) RETURN NUMBER IS
    v_charge_amount  NUMBER;
    v_payment_amount NUMBER;
    v_calc_result    NUMBER;
  BEGIN

    /* ����� ���������� */
    SELECT nvl(ROUND(SUM(acc_amount *
                         ((least(trans_period_end_date
                                ,gv_decline_date
                                ,nvl(gv_grace_start, gc_max_date)) - trans_period_start_date) /
                         (trans_period_end_date - trans_period_start_date)))
                    ,2)
              ,0)
      INTO v_charge_amount
      FROM tmp_decline_trans_data td
     WHERE td.trans_type = gc_charge
       AND td.doc_date < trunc(SYSDATE, 'y') /* 01.01.�������� ���� */
       AND td.trans_period_start_date <= gv_epg_start /* ���� ���, � ������� ��������� ���� ����������� */
       AND td.product_line_id = par_product_line_id
       AND td.asset_contact_id = par_as_contact_id;

    /* ����� ����� */
    v_payment_amount := get_all_payments(par_as_contact_id, par_product_line_id);

    v_calc_result := v_charge_amount - v_payment_amount;
    IF v_calc_result < 0
    THEN
      v_calc_result := 0;
    END IF;

    RETURN v_calc_result;
  END calc#11;

  -- ��������� �� ������� ������ ��� �������� � ��
  FUNCTION calc#12
  (
    par_as_contact_id   as_assured.assured_contact_id%TYPE
   ,par_product_line_id t_product_line.id%TYPE
  ) RETURN NUMBER IS
    v_charge_amount  NUMBER;
    v_payment_amount NUMBER;
    v_calc_result    NUMBER;
  BEGIN

    /* ����� ���������� */
    SELECT nvl(ROUND(SUM(acc_amount), 2), 0)
      INTO v_charge_amount
      FROM tmp_decline_trans_data td
     WHERE td.trans_type = gc_charge
       AND td.doc_date < trunc(SYSDATE, 'y') /* 01.01.�������� ���� */
       AND td.product_line_id = par_product_line_id
       AND td.asset_contact_id = par_as_contact_id;

    /* ����� ����� */
    v_payment_amount := get_all_payments(par_as_contact_id, par_product_line_id);

    v_calc_result := greatest(v_charge_amount - v_payment_amount, 0);

    RETURN v_calc_result;
  END calc#12;

  FUNCTION calc#13
  (
    par_as_contact_id   as_assured.assured_contact_id%TYPE
   ,par_product_line_id t_product_line.id%TYPE
  ) RETURN NUMBER IS
    v_charge_amount  NUMBER;
    v_payment_amount NUMBER;
    v_calc_result    NUMBER;
  BEGIN
    SELECT nvl(ROUND(SUM(acc_amount *
                         ((least(trans_period_end_date
                                ,gv_decline_date
                                ,nvl(gv_grace_start, gc_max_date)) - trans_period_start_date) /
                         (trans_period_end_date - trans_period_start_date)))
                    ,2)
              ,0)
      INTO v_charge_amount
      FROM (SELECT td.acc_amount
                  ,td.trans_period_start_date
                  ,td.trans_period_end_date
              FROM tmp_decline_trans_data td
             WHERE td.trans_type = gc_charge
                  --AND td.doc_date > trunc(SYSDATE, 'y') /* 01.01.�������� ���� */
               AND td.doc_date < gv_epg_start /* ���� ���, � ������� ��������� ���� ����������� */
               AND td.asset_contact_id = par_as_contact_id
               AND td.product_line_id = par_product_line_id);

    /* ����� ����� */
    v_payment_amount := get_all_payments(par_as_contact_id, par_product_line_id);

    v_calc_result := v_charge_amount - v_payment_amount - get_row_values(par_as_contact_id, par_product_line_id)
                    .underpayment_previous;
    IF v_calc_result < 0
    THEN
      v_calc_result := 0;
    END IF;

    RETURN v_calc_result;
  END calc#13;

  -- ��������� �� ������� ������ �� ���������� � ��
  FUNCTION calc#14
  (
    par_as_contact_id   as_assured.assured_contact_id%TYPE
   ,par_product_line_id t_product_line.id%TYPE
  ) RETURN NUMBER IS
    v_charge_amount  NUMBER;
    v_payment_amount NUMBER;
    v_calc_result    NUMBER;
  BEGIN

    SELECT nvl(SUM(acc_amount), 0)
      INTO v_charge_amount
      FROM tmp_decline_trans_data td
     WHERE td.trans_type = gc_charge
          --AND td.doc_date > trunc(SYSDATE, 'y') /* 01.01.�������� ���� */
          --AND td.doc_date < gv_epg_start /* ���� ���, � ������� ��������� ���� ����������� */
       AND td.asset_contact_id = par_as_contact_id
       AND td.product_line_id = par_product_line_id;

    /* ����� ����� */
    v_payment_amount := get_all_payments(par_as_contact_id, par_product_line_id);

    v_calc_result := greatest(v_charge_amount - v_payment_amount - get_row_values(par_as_contact_id, par_product_line_id)
                              .underpayment_previous
                             ,0);

    RETURN v_calc_result;
  END calc#14;

  FUNCTION calc#15
  (
    par_as_contact_id   as_assured.assured_contact_id%TYPE
   ,par_product_line_id t_product_line.id%TYPE
  ) RETURN NUMBER IS
    v_calc#12_amount NUMBER;
    v_charge_amount  NUMBER;
    v_payment_amount NUMBER;
    v_row_value      dml_p_cover_decline.tt_p_cover_decline;
    v_calc_result    NUMBER;
  BEGIN

    /*
    -- ��������� ��������� �������
    SELECT nvl(ROUND(SUM(acc_amount * ((gv_decline_date - trans_period_start_date) /
                         (gv_grace_end - trans_period_start_date)))
                    ,2)
              ,0)
      INTO v_charge_amount
      FROM (SELECT td.acc_amount
                  ,td.trans_period_start_date
                  ,td.trans_period_end_date
              FROM tmp_decline_trans_data td
             WHERE td.trans_type = gc_charge
               AND td.trans_period_start_date BETWEEN gv_epg_start AND gv_epg_end - 1
               AND td.product_line_id = par_product_line_id
               AND td.asset_contact_id = par_as_contact_id);
    */

    SELECT nvl(ROUND(SUM(acc_amount * (least(gv_decline_date, gv_grace_end, trans_period_end_date) -
                         trans_period_start_date) / (trans_period_end_date - trans_period_start_date))
                    ,2)
              ,0)
      INTO v_charge_amount
      FROM tmp_decline_trans_data td
     WHERE td.trans_type = gc_charge
       AND td.trans_period_start_date < least(gv_grace_end, gv_epg_end)
       AND td.product_line_id = par_product_line_id
       AND td.asset_contact_id = par_as_contact_id;

    --    v_calc#12_amount := calc#12(par_as_contact_id   => par_as_contact_id
    --                               ,par_product_line_id => par_product_line_id);

    v_row_value := get_row_values(par_as_contact_id, par_product_line_id);
    /* ����� ����� */
    v_payment_amount := get_all_payments(par_as_contact_id, par_product_line_id);

    -- ��� ��������� - ��� ������ - ���������.��. - ��������.���.
    v_calc_result := v_charge_amount - v_payment_amount - v_row_value.underpayment_previous -
                     v_row_value.underpayment_current;

    IF v_calc_result < 0
    THEN
      v_calc_result := 0;
    END IF;

    RETURN v_calc_result;
  END calc#15;

  FUNCTION calc#16
  (
    par_as_contact_id   as_assured.assured_contact_id%TYPE
   ,par_product_line_id t_product_line.id%TYPE
  ) RETURN NUMBER IS
    v_calc_result NUMBER;
  BEGIN
    /*
      ��������� ����������� = ��������� �� ������� ������� + ��������� �� ������� ������ +  ��������� �� ��
      �������� ������� �� �������� ����� �����������.
    */
    v_calc_result := get_row_values(par_as_contact_id, par_product_line_id).underpayment_previous + get_row_values(par_as_contact_id, par_product_line_id)
                     .underpayment_current + get_row_values(par_as_contact_id, par_product_line_id)
                     .underpayment_lp;

    RETURN v_calc_result;
  END calc#16;

  FUNCTION calc#17
  (
    par_as_contact_id   as_assured.assured_contact_id%TYPE
   ,par_product_line_id t_product_line.id%TYPE
  ) RETURN NUMBER IS
    v_calc_result NUMBER;
  BEGIN

    RETURN calc_bonus_off_prev(par_as_contact_id, par_product_line_id);

  END calc#17;

  -- ����������� ������ � �������� ������� ��� ��� �������� � ��
  -- ������, � ������� ������ ���� ����������� �� ����������
  -- ������������ ��� ����� �� !!!
  FUNCTION calc#18
  (
    par_as_contact_id   as_assured.assured_contact_id%TYPE
   ,par_product_line_id t_product_line.id%TYPE
  ) RETURN NUMBER IS
    v_charge_amount  NUMBER;
    v_payment_amount NUMBER;
    v_calc_result    NUMBER;
    v_row_values     dml_p_cover_decline.tt_p_cover_decline;
  BEGIN

    RETURN calc_bonus_off_prev(par_as_contact_id, par_product_line_id);

  END calc#18;

  -- ����������� ������ � �������� ������� ��� ��� �������������
  FUNCTION calc#19
  (
    par_as_contact_id   as_assured.assured_contact_id%TYPE
   ,par_product_line_id t_product_line.id%TYPE
  ) RETURN NUMBER IS
    v_calc_result NUMBER;
  BEGIN

    /* ����� ���������� */
    -- ��� ���������� � DB��� (<01.01.�������� ����) DE_��� > ���� ����
    SELECT nvl(ROUND(SUM(acc_amount * greatest((trans_period_end_date -
                                                 greatest(gv_decline_date, trans_period_start_date)) /
                                                 (trans_period_end_date - trans_period_start_date)
                                                ,0))
                    ,2)
              ,0)
      INTO v_calc_result
      FROM tmp_decline_trans_data td
     WHERE td.trans_type = gc_charge
       AND td.doc_date < trunc(SYSDATE, 'y') /* 01.01.�������� ���� */
          --AND td.trans_period_start_date < gvr_pol_decline.act_date
          -- ������������� end_date>act_date ������� � ���, ��� ����� ���� ��������
          -- ������������ ����� decline_date, �� ���� ����� �������
          -- �������, ��� ������������ act_date

          -- ��� ������������ ���� ������ ��� � ������ ������ ������� � ���� �����������
       AND td.trans_period_end_date > gv_decline_date --gvr_pol_decline.act_date
       AND td.product_line_id = par_product_line_id
       AND td.asset_contact_id = par_as_contact_id;

    /*
      �� ���� ����� ������ ���� ������� ���������� ������� 17
    */

    RETURN v_calc_result;
  END calc#19;

  -- ����������� ������ � �������� �������� ������� ��� �������� ��� ��
  FUNCTION calc#20
  (
    par_as_contact_id   as_assured.assured_contact_id%TYPE
   ,par_product_line_id t_product_line.id%TYPE
  ) RETURN NUMBER IS
    v_calc_result NUMBER;
  BEGIN
    RETURN calc_bonus_off_current(par_as_contact_id, par_product_line_id);
  END calc#20;

  -- ����������� ������ � �������� �� ������� ��� �� ���������� � ��
  -- �� ���������� ������, � ������� ������ ���� �����������
  -- ������������ ��� ����� �� !!!
  FUNCTION calc#21
  (
    par_as_contact_id   as_assured.assured_contact_id%TYPE
   ,par_product_line_id t_product_line.id%TYPE
  ) RETURN NUMBER IS
    v_charge_amount  NUMBER;
    v_payment_amount NUMBER;
    v_calc_result    NUMBER;
    v_row_values     dml_p_cover_decline.tt_p_cover_decline;
  BEGIN
    RETURN calc_bonus_off_current(par_as_contact_id, par_product_line_id);
  END calc#21;

  -- ����������� ������ � �������� �������� ������� ��� �������������
  FUNCTION calc#22
  (
    par_as_contact_id   as_assured.assured_contact_id%TYPE
   ,par_product_line_id t_product_line.id%TYPE
  ) RETURN NUMBER IS
    v_calc_result NUMBER;
  BEGIN
    /* ����� ���������� */
    -- ��� ���������� � DB��� (>=01.01.�������� ����) U DE_���> ���� ����
    SELECT nvl(ROUND(SUM(acc_amount * greatest((trans_period_end_date -
                                                 greatest(gv_decline_date, trans_period_start_date)) /
                                                 (trans_period_end_date - trans_period_start_date)
                                                ,0))
                    ,2)
              ,0)
      INTO v_calc_result
      FROM tmp_decline_trans_data td
     WHERE td.trans_type = gc_charge
       AND td.doc_date >= trunc(SYSDATE, 'y') /* 01.01.�������� ���� */
          --AND td.trans_period_start_date < gvr_pol_decline.act_date
          -- ������������� end_date>act_date ������� � ���, ��� ����� ���� ��������
          -- ������������ ����� decline_date, �� ���� ����� �������
          -- �������, ��� ������������ act_date

          -- ��� ������������ ���� ������ ��� � ������ ������ ������� � ���� �����������
       AND td.trans_period_end_date > gv_decline_date --gvr_pol_decline.act_date
       AND td.product_line_id = par_product_line_id
       AND td.asset_contact_id = par_as_contact_id;
    /*
      �� ���� ����� ������ ���� ������� ���������� ������� 20
    */

    RETURN v_calc_result;
  END calc#22;

  FUNCTION calc#23
  (
    par_as_contact_id   as_assured.assured_contact_id%TYPE
   ,par_product_line_id t_product_line.id%TYPE
  ) RETURN NUMBER IS
    v_did                     p_cover_decline.add_invest_income%TYPE;
    v_underpayment_fact       p_cover_decline.underpayment_actual%TYPE;
    v_underpayment_prev_total p_cover_decline.underpayment_previous%TYPE;
    v_underpayment_prev       p_cover_decline.underpayment_previous%TYPE;
    v_nps_total               NUMBER;
    v_calc_result             NUMBER;
  BEGIN
    v_did               := get_row_values(par_as_contact_id, par_product_line_id).add_invest_income;
    v_underpayment_fact := get_total_values().underpayment_actual;
    /* ���� ���� �� ����� � ��������� ������������ �������� ����� � �������� �������������
    + ������(0,13* ���; 0) >=  ����� � ������� ���������� ������������, �� =0 */
    IF gvr_pol_decline.issuer_return_sum + ROUND(0.13 * v_did) >= v_underpayment_fact
    THEN
      v_calc_result := 0;
    ELSE
      /* ���������� ����� ����� ��������� � ��������: ������ �� ����� � �������� ��������� �� ������� ������ */
      v_underpayment_prev_total := get_total_values().underpayment_previous;
      v_underpayment_prev       := get_row_values(par_as_contact_id, par_product_line_id)
                                   .underpayment_previous;
      v_nps_total               := gvr_pol_decline.issuer_return_sum - gvr_pol_decline.income_tax_sum -
                                   v_underpayment_prev;
      /* �� ���������� ������� ������� ��� �� ��������� */

      v_calc_result := v_nps_total * (v_underpayment_prev / nullif(v_underpayment_prev, 0));
    END IF;

    RETURN v_calc_result;
  END calc#23;

  FUNCTION calc#24
  (
    par_as_contact_id   as_assured.assured_contact_id%TYPE
   ,par_product_line_id t_product_line.id%TYPE
  ) RETURN NUMBER IS
    v_did                     p_cover_decline.add_invest_income%TYPE;
    v_unpayed_premium_prev    p_cover_decline.unpayed_premium_previous%TYPE;
    v_underpayment_fact       p_cover_decline.underpayment_actual%TYPE;
    v_underpayment_prev_total p_cover_decline.underpayment_previous%TYPE;
    v_underpayment_curr_total p_cover_decline.underpayment_current%TYPE;
    v_underpayment_curr       p_cover_decline.underpayment_current%TYPE;
    v_nps_total               NUMBER;
    v_calc_result             NUMBER;
  BEGIN
    v_did               := get_row_values(par_as_contact_id, par_product_line_id).add_invest_income;
    v_underpayment_fact := get_total_values().underpayment_actual;
    /* ���� ���� �� ����� � ��������� ������������ �������� ����� � �������� �������������
    + ������(0,13* ���; 0) >=  ����� � ������� ���������� ������������, �� =0 */
    IF gvr_pol_decline.issuer_return_sum + ROUND(0.13 * v_did) >= v_underpayment_fact
    THEN
      v_calc_result := 0;
    ELSE
      /* ���� ����� ������� ������������ ������ � �������� �� �������� �� ������� ������ >0, �� =���������_��� */
      v_unpayed_premium_prev := get_total_values().underpayment_previous;
      IF v_unpayed_premium_prev > 0
      THEN
        v_calc_result := get_row_values(par_as_contact_id, par_product_line_id).underpayment_current;
      ELSE
        /* 3. ���������� ����� ����� ��������� � ��������: ������ �� ����� � �������� ��������� �� ������� ������ � �� ������� */
        v_underpayment_prev_total := get_total_values().underpayment_previous;
        v_underpayment_curr_total := get_total_values().underpayment_current;
        v_underpayment_curr       := get_row_values(par_as_contact_id, par_product_line_id)
                                     .underpayment_current;
        v_nps_total               := gvr_pol_decline.issuer_return_sum +
                                     gvr_pol_decline.income_tax_sum - v_underpayment_prev_total -
                                     v_underpayment_curr_total;
        /* �� ���������� ������� ������� ��� �� ��������� */
        IF v_underpayment_curr_total != 0
        THEN
          v_calc_result := v_nps_total * (v_underpayment_curr / nullif(v_underpayment_curr_total, 0));
        ELSE
          v_calc_result := 0;
        END IF;
      END IF;
    END IF;

    RETURN v_calc_result;
  END calc#24;

  FUNCTION calc#25
  (
    par_as_contact_id   as_assured.assured_contact_id%TYPE
   ,par_product_line_id t_product_line.id%TYPE
  ) RETURN NUMBER IS
    --v_issuer_return           NUMBER := 0;
    v_did                     p_cover_decline.add_invest_income%TYPE := 0;
    v_underpayment_fact       p_cover_decline.underpayment_actual%TYPE := 0;
    v_underpayment_lp         p_cover_decline.underpayment_lp%TYPE := 0;
    v_unpayed_premium_current p_cover_decline.unpayed_premium_current%TYPE := 0;
    v_nps                     NUMBER := 0;
    v_calc_result             NUMBER;
  BEGIN

    /* ��������: ���� ���� �� ����� � ��������� ������������ �������� ����� � �������� �������������
    + ������(0,13* ���; 0) >=  ����� � ������� ���������� ������������, �� =0 */
    /*v_issuer_return           := gv_result_program_cache(par_as_contact_id)(v_product_line_id)
    .redemption_sum + gv_result_program_cache(par_as_contact_id)(v_product_line_id)
    .add_invest_income + gv_result_program_cache(par_as_contact_id)(v_product_line_id)
    .return_bonus_part;*/
    v_did                     := get_total_values().add_invest_income;
    v_underpayment_fact       := get_total_values().underpayment_actual;
    v_unpayed_premium_current := get_total_values().unpayed_premium_current;
    v_underpayment_lp         := get_total_values().underpayment_lp;

    IF gvr_pol_decline.issuer_return_sum + ROUND(0.13 * v_did) >= v_underpayment_fact
    THEN
      v_calc_result := 0;
    ELSE
      /*  ��������: ���� ����� ������� ������������ ������ � �������� �� �������� �� ������� ������ >0, ��
      ���_������� �� = ���������_�� */
      IF v_unpayed_premium_current > 0
      THEN
        v_calc_result := get_row_values(par_as_contact_id, par_product_line_id).underpayment_lp;
      ELSE
        /* ���������� ����� ����� ��������� � ��������: ������ �� ����� � �������� ��������� �� ������� ������, �� ������� � �� �� */
        v_nps := (gvr_pol_decline.issuer_return_sum + gvr_pol_decline.income_tax_sum) -
                 v_underpayment_fact;
        /* �� ���������� ������� ������� ��� �� ��������� */
        v_calc_result := v_nps * (get_row_values(par_as_contact_id, par_product_line_id)
                         .underpayment_lp / nullif(v_underpayment_lp, 0));
      END IF;
    END IF;

    RETURN v_calc_result;
  END calc#25;

  /*
  -- ������ ���
  FUNCTION calc#26 RETURN NUMBER IS
    v_calc_result  NUMBER := 0;
    v_total_values dml_p_cover_decline.tt_p_cover_decline;
  BEGIN
    \* ��� = �� + �������������� �������� ����� + ��� + ��� *\
    v_total_values := get_total_values();
    v_calc_result  := v_total_values.redemption_sum + v_total_values.add_policy_surrender +
                      v_total_values.add_invest_income + v_total_values.return_bonus_part;
    RETURN v_calc_result;
  END calc#26;
  */

  FUNCTION calc#27 RETURN NUMBER IS
    v_issuer_return NUMBER := 0;
    v_did           NUMBER := 0;
    v_calc_result   NUMBER := 0;
  BEGIN
    /* ��� = �� + �������������� �������� ����� + ��� + ��� */
    v_issuer_return := get_total_values().redemption_sum + get_total_values().add_invest_income + get_total_values()
                       .return_bonus_part;

    v_did := get_total_values().add_invest_income;
    /* ���� �� ����� � ��������� ������������ �������� ����� � �������� �������������
    - �����������(0,13*���; 0) >= ��������� ������������, �� = ��������� ������������. */
    IF v_issuer_return - CEIL(0.13 * v_did) >= gvr_pol_decline.debt_fee_fact
    THEN
      v_calc_result := gvr_pol_decline.debt_fee_fact;
    ELSE
      /* �� ����� � ��������� ������������ �������� ����� � �������� ������������� � - �����������(0,13*���; 0)*/
      v_calc_result := v_issuer_return - CEIL(0.13 * v_did);
    END IF;
    RETURN v_calc_result;
  END calc#27;

  FUNCTION calc#29 RETURN NUMBER IS
    v_calc_result NUMBER;
  BEGIN
    /* ������ �������� (����� ���� ���������), ��������� �� �������, ��� ��� ������ �������������
       -> ������� �������� ����������� �������������� -> ����� � ������� ���������������
       -> ������� ������������ -> ������������ ������������ ������������ (����� �� ��� ��������� � ����� ���������)
       -> ������ ��������� -> ����� ������� �����������
    */
    SELECT nvl(SUM(me.exam_cost), 0)
      INTO v_calc_result
      FROM p_policy             pp
          ,as_asset             se
          ,as_assured_docum     ad
          ,assured_medical_exam me
     WHERE pp.pol_header_id = gvr_policy.pol_header_id
       AND pp.policy_id = se.p_policy_id
       AND se.as_asset_id = ad.as_assured_id
       AND ad.assured_docum_type_id =
           (SELECT dt.assured_docum_type_id FROM assured_docum_type dt WHERE dt.brief = 'MEDICAL EXAM')
       AND ad.as_assured_docum_id = me.as_assured_docum_id
       AND pp.version_num > (SELECT MIN(pp_a.version_num)
                               FROM p_policy       pp_a
                                   ,doc_status     ds
                                   ,doc_status_ref dsr
                              WHERE pp_a.pol_header_id = pp.pol_header_id
                                AND pp_a.policy_id = ds.document_id
                                AND ds.doc_status_ref_id = dsr.doc_status_ref_id
                                AND dsr.brief = 'UNDERWRITING');
    RETURN v_calc_result;
  END calc#29;

  -- ��������� �� ���������� ��� ��
  FUNCTION calc#30
  (
    par_as_contact_id   as_assured.assured_contact_id%TYPE
   ,par_product_line_id t_product_line.id%TYPE
  ) RETURN NUMBER IS
    v_payments    tmp_decline_trans_data.acc_amount%TYPE;
    v_charges     tmp_decline_trans_data.acc_amount%TYPE;
    v_vchp        NUMBER := 0;
    v_calc_result NUMBER := 0;
  BEGIN
    /* T��� (������) */
    v_payments := get_all_payments(par_as_contact_id, par_product_line_id);

    SELECT nvl(ROUND(SUM(acc_amount *
                         ((least(trans_period_end_date, gv_decline_date) - trans_period_start_date) /
                         (trans_period_end_date - trans_period_start_date)))
                    ,2)
              ,0)
      INTO v_charges
      FROM tmp_decline_trans_data td
     WHERE td.trans_type = gc_charge
       AND td.trans_period_start_date < gv_decline_date
       AND td.asset_contact_id = par_as_contact_id
       AND td.product_line_id = par_product_line_id;

    /* ��� */
    v_vchp := get_row_values(par_as_contact_id, par_product_line_id).return_bonus_part;

    v_calc_result := greatest(v_payments - v_charges - v_vchp, 0);

    RETURN v_calc_result;
  END calc#30;

  FUNCTION calc#33
  (
    par_as_contact_id   as_assured.assured_contact_id%TYPE
   ,par_product_line_id t_product_line.id%TYPE
  ) RETURN NUMBER IS
  BEGIN
    RETURN 0;
  END calc#33;

  /*
  * ������ ��� �� ���������� ��� ��
  * (�� ����������� ��������� ������������ ����� �� ���� ��� ���������
  * ��������� �����, �����, �������, ��������) �������� ��� ������ ���������
  */
  FUNCTION calc#34
  (
    par_as_contact_id   as_assured.assured_contact_id%TYPE
   ,par_product_line_id t_product_line.id%TYPE
  ) RETURN NUMBER IS
  BEGIN
    -- ������ ��������� ���������� �������� �4
    RETURN calc#4(par_as_contact_id => par_as_contact_id, par_product_line_id => par_product_line_id);
  END calc#34;

  FUNCTION calc#35
  (
    par_as_contact_id   as_assured.assured_contact_id%TYPE
   ,par_product_line_id t_product_line.id%TYPE
  ) RETURN NUMBER IS
    v_is_did_exists      NUMBER(1);
    v_calc_result        NUMBER;
    v_last_paid_fee_date DATE;
  BEGIN
    SELECT COUNT(1)
      INTO v_is_did_exists
      FROM dual
     WHERE EXISTS
     (SELECT NULL FROM tmp_decline_did_data dd WHERE dd.product_line_id = par_product_line_id);

    IF v_is_did_exists = 1
    THEN
      IF gv_is_periodical_terms = 1
      THEN
        v_last_paid_fee_date := get_last_paid_fee_date;
      END IF;

      SELECT MAX(dd.income_rur) keep(dense_rank FIRST ORDER BY dd.income_date DESC)
        INTO v_calc_result
        FROM tmp_decline_did_data dd
       WHERE least(gv_decline_date, nvl(v_last_paid_fee_date, gc_max_date)) > dd.income_date
         AND dd.product_line_id = par_product_line_id;
      IF v_calc_result IS NULL
      THEN
        v_calc_result := 0;
        --ex.raise('�� ������ ��� �� ����');
      END IF;
    ELSE
      v_calc_result := 0;
    END IF;

    RETURN v_calc_result;
  END calc#35;

  FUNCTION calc#36
  (
    par_as_contact_id   as_assured.assured_contact_id%TYPE
   ,par_product_line_id t_product_line.id%TYPE
  ) RETURN NUMBER IS
  BEGIN
    RETURN 0;
  END calc#36;

  FUNCTION calc#37
  (
    par_as_contact_id   as_assured.assured_contact_id%TYPE
   ,par_product_line_id t_product_line.id%TYPE
  ) RETURN NUMBER IS
  BEGIN
    RETURN 0;
  END calc#37;

  FUNCTION calc#38
  (
    par_as_contact_id   as_assured.assured_contact_id%TYPE
   ,par_product_line_id t_product_line.id%TYPE
  ) RETURN NUMBER IS
  BEGIN
    RETURN 0;
  END calc#38;

  FUNCTION calc#39
  (
    par_as_contact_id   as_assured.assured_contact_id%TYPE
   ,par_product_line_id t_product_line.id%TYPE
  ) RETURN NUMBER IS
  BEGIN
    /* ����� ����� */
    RETURN get_all_payments(par_as_contact_id, par_product_line_id);
  END calc#39;

  -- ������ ���
  FUNCTION calc#40
  (
    par_as_contact_id   as_assured.assured_contact_id%TYPE
   ,par_product_line_id t_product_line.id%TYPE
  ) RETURN NUMBER IS
    v_payments NUMBER;
  BEGIN
    /* ����� ����� */
    v_payments := get_all_payments(par_as_contact_id, par_product_line_id);
    --RETURN v_payments - get_row_values(par_as_contact_id, par_product_line_id).admin_expenses;
    RETURN v_payments;
  END calc#40;

  -- ������ ���
  FUNCTION calc#41
  (
    par_as_contact_id   as_assured.assured_contact_id%TYPE
   ,par_product_line_id t_product_line.id%TYPE
  ) RETURN NUMBER IS
  BEGIN
    -- ��������� 39
    RETURN calc#39(par_as_contact_id => par_as_contact_id, par_product_line_id => par_product_line_id);
  END calc#41;

  -- ������ ���
  FUNCTION calc#42
  (
    par_as_contact_id   as_assured.assured_contact_id%TYPE
   ,par_product_line_id t_product_line.id%TYPE
  ) RETURN NUMBER IS
  BEGIN
    -- ��������� 40
    RETURN calc#40(par_as_contact_id => par_as_contact_id, par_product_line_id => par_product_line_id);
  END calc#42;

  -- ����������� ������ � �������� ��� �������������
  FUNCTION calc#43
  (
    par_as_contact_id   as_assured.assured_contact_id%TYPE
   ,par_product_line_id t_product_line.id%TYPE
  ) RETURN NUMBER IS
    v_calc_result NUMBER;
  BEGIN

    /*
    \* ����� ���������� *\
    -- ��� ���������� � DB��� (<01.01.�������� ����) U (< ���� ����)
    SELECT nvl(ROUND(SUM(trans_amount * (trans_period_end_date -
                         least(greatest(gv_decline_date, trans_period_start_date)
                                              ,trans_period_end_date)) /
                         (trans_period_end_date - trans_period_start_date))
                    ,2)
              ,0)
      INTO v_calc_result
      FROM tmp_decline_trans_data td
     WHERE td.trans_type = gc_charge
          -- AND td.trans_templ_id = 21 \* !��������� ������ *\
       AND td.doc_date < trunc(SYSDATE, 'y') \* 01.01.�������� ���� *\
       AND td.trans_period_start_date < gvr_pol_decline.act_date
          -- �������, ��� ������������ ���� ���� ������ ���� �����������
       -- ���������� ���� start<act_date, ����� ������-�� ���������� �� end>act_date
       -- ������ �������, ����� ��������������� ���������
       --AND td.trans_period_end_date > gvr_pol_decline.act_date
       AND td.product_line_id = par_product_line_id
       AND td.asset_contact_id = par_as_contact_id;
       */

    v_calc_result := calc#19(par_as_contact_id, par_product_line_id);

    RETURN v_calc_result;
  END calc#43;

  FUNCTION calc#44
  (
    par_as_contact_id   as_assured.assured_contact_id%TYPE
   ,par_product_line_id t_product_line.id%TYPE
  ) RETURN NUMBER IS
  BEGIN
    RETURN 0;
  END calc#44;

  FUNCTION calc#45
  (
    par_as_contact_id   as_assured.assured_contact_id%TYPE
   ,par_product_line_id t_product_line.id%TYPE
  ) RETURN NUMBER IS
  BEGIN
    RETURN 0;
  END calc#45;

  FUNCTION calc#46
  (
    par_as_contact_id   as_assured.assured_contact_id%TYPE
   ,par_product_line_id t_product_line.id%TYPE
  ) RETURN NUMBER IS
    v_calc_result NUMBER;
  BEGIN
    /* ����� ���������� */
    -- ��� ���������� � DB��� (>=01.01.�������� ����) U (< ���� ����)
    SELECT nvl(ROUND(SUM(acc_amount * greatest((trans_period_end_date -
                                                 greatest(gv_decline_date, trans_period_start_date)) /
                                                 (trans_period_end_date - trans_period_start_date)
                                                ,0))
                    ,2)
              ,0)
      INTO v_calc_result
      FROM (SELECT td.acc_amount
                  ,td.trans_period_start_date
                  ,td.trans_period_end_date
              FROM tmp_decline_trans_data td
             WHERE td.trans_type = gc_charge
               AND td.trans_templ_id = 21 /* !��������� ������ */
               AND td.doc_date >= trunc(SYSDATE, 'y') /* 01.01.�������� ���� */
                  --AND td.trans_period_start_date < gvr_pol_decline.act_date
               AND td.trans_period_end_date >= gvr_pol_decline.act_date
               AND td.product_line_id = par_product_line_id
               AND td.asset_contact_id = par_as_contact_id);

    RETURN v_calc_result;
  END calc#46;

  -- ����������� ������ � �������� ������� ��� ��� �������� ��� ��,
  -- ��������� �������������� �������
  FUNCTION calc#47
  (
    par_as_contact_id   as_assured.assured_contact_id%TYPE
   ,par_product_line_id t_product_line.id%TYPE
  ) RETURN NUMBER IS
    v_calc_result NUMBER;
  BEGIN

    /* ����� ���������� */
    -- ��� ���������� � ����� ��������� <01.01.�������� ���� U <= DD
    SELECT nvl(SUM(td.acc_amount), 0)
      INTO v_calc_result
      FROM tmp_decline_trans_data td
     WHERE td.trans_type = gc_charge
       AND td.doc_date < trunc(SYSDATE, 'y') /* 01.01.�������� ���� */
          --   AND td.trans_period_start_date <= gv_decline_date
       AND td.trans_period_end_date > gv_decline_date
       AND td.product_line_id = par_product_line_id
       AND td.asset_contact_id = par_as_contact_id;

    RETURN v_calc_result;
  END calc#47;

  FUNCTION calc#48
  (
    par_as_contact_id   as_assured.assured_contact_id%TYPE
   ,par_product_line_id t_product_line.id%TYPE
  ) RETURN NUMBER IS
    v_calc_result NUMBER;
  BEGIN

    /* ����� ���������� */
    -- ��� ���������� � ����� ��������� >=01.01.�������� ���� U <= DD
    SELECT nvl(SUM(td.acc_amount), 0)
      INTO v_calc_result
      FROM tmp_decline_trans_data td
     WHERE td.trans_type = gc_charge
       AND td.doc_date >= trunc(SYSDATE, 'y') /* 01.01.�������� ���� */
          --AND td.trans_period_start_date <= gv_decline_date
       AND td.trans_period_end_date > gv_decline_date
       AND td.product_line_id = par_product_line_id
       AND td.asset_contact_id = par_as_contact_id;

    RETURN v_calc_result;
  END calc#48;

  -- ��� ��� ������������� �� ����� ���������
  FUNCTION calc#49
  (
    par_as_contact_id   as_assured.assured_contact_id%TYPE
   ,par_product_line_id t_product_line.id%TYPE
  ) RETURN NUMBER IS
    v_charge_amount  NUMBER;
    v_payment_amount NUMBER;
    v_calc_result    NUMBER;
  BEGIN

    /* ����� ���������� */
    -- ��� ���������� � ����� ��������� <= DD
    SELECT SUM(td.acc_amount)
      INTO v_charge_amount
      FROM tmp_decline_trans_data td
     WHERE td.trans_type = gc_charge
       AND td.trans_period_start_date <= gvr_pol_decline.act_date
       AND td.product_line_id = par_product_line_id
       AND td.asset_contact_id = par_as_contact_id;

    v_payment_amount := get_all_payments(par_as_contact_id, par_product_line_id);

    v_calc_result := v_charge_amount + nvl(gv_rvd_percent, 0) / 100 * v_payment_amount;
    RETURN v_calc_result;
  END calc#49;

  -- ��� ��� ��������� ��������� �������
  FUNCTION calc#68
  (
    par_as_contact_id   as_assured.assured_contact_id%TYPE
   ,par_product_line_id t_product_line.id%TYPE
  ) RETURN NUMBER IS
    v_payment_amount NUMBER;
    v_calc_result    NUMBER;
  BEGIN

    v_payment_amount := get_all_payments(par_as_contact_id, par_product_line_id);

    v_calc_result := nvl(gv_rvd_percent, 0) / 100 * v_payment_amount;
    RETURN v_calc_result;
  END calc#68;

  /*
  * ��� ��� ��������� �������������� �������
  */
  FUNCTION calc#52
  (
    par_as_contact_id   as_assured.assured_contact_id%TYPE
   ,par_product_line_id t_product_line.id%TYPE
  ) RETURN NUMBER IS
    v_admin_exp NUMBER;
    v_charge    NUMBER;
    v_payments  NUMBER;
  BEGIN
    SELECT nvl(ROUND(SUM(t.acc_amount *
                         (least(t.trans_period_end_date, gv_epg_end) - t.trans_period_start_date) /
                         (t.trans_period_end_date - t.trans_period_start_date))
                    ,2)
              ,0)
      INTO v_charge
      FROM tmp_decline_trans_data t
     WHERE t.trans_type = gc_charge
       AND t.trans_period_start_date < gv_epg_end
       AND t.asset_contact_id = par_as_contact_id
       AND t.product_line_id = par_product_line_id;

    v_payments := get_all_payments(par_as_contact_id   => par_as_contact_id
                                  ,par_product_line_id => par_product_line_id);

    v_admin_exp := least(v_payments, v_charge) * gv_rvd_percent / 100;

    RETURN v_admin_exp;
  END calc#52;

  /*
  * �������������� �������� �����
  */
  FUNCTION calc#53
  (
    par_as_contact_id   as_assured.assured_contact_id%TYPE
   ,par_product_line_id t_product_line.id%TYPE
  ) RETURN NUMBER IS
  BEGIN

    -- ���� �������� ����� �����, ��� ������ ���
    RETURN calc#3(par_as_contact_id => par_as_contact_id, par_product_line_id => par_product_line_id);
  END calc#53;

  /*
  -- ������ ���
  FUNCTION calc#54 RETURN NUMBER IS
    v_calc_result NUMBER := 0;
    v_totals      dml_p_cover_decline.tt_p_cover_decline;
  BEGIN
    \* ��� = �� + �������������� �� + ��� + ��� � ��� �� ������ *\
    v_totals      := get_total_values();
    v_calc_result := v_totals.redemption_sum + v_totals.add_policy_surrender +
                     v_totals.add_invest_income + v_totals.return_bonus_part - v_totals.admin_expenses;

    RETURN v_calc_result;
  END calc#54;
  */

  FUNCTION calc#60
  (
    par_as_contact_id   as_assured.assured_contact_id%TYPE
   ,par_product_line_id t_product_line.id%TYPE
  ) RETURN NUMBER IS
    v_calc_result NUMBER;
  BEGIN

    RETURN calc_bonus_off_msfo(par_as_contact_id, par_product_line_id);
  END calc#60;

  -- ��� ���� ��� ����� ��
  FUNCTION calc#61
  (
    par_as_contact_id   as_assured.assured_contact_id%TYPE
   ,par_product_line_id t_product_line.id%TYPE
  ) RETURN NUMBER IS
    v_charge_amount  NUMBER;
    v_payment_amount NUMBER;
    v_calc_result    NUMBER;
    v_row_values     dml_p_cover_decline.tt_p_cover_decline;
  BEGIN

    RETURN calc_bonus_off_msfo(par_as_contact_id, par_product_line_id);

  END calc#61;

  FUNCTION calc#62
  (
    par_as_contact_id   as_assured.assured_contact_id%TYPE
   ,par_product_line_id t_product_line.id%TYPE
  ) RETURN NUMBER IS
    v_calc_result NUMBER;
  BEGIN

    /* ����� ���������� */
    -- ��� ���������� � ����� ��������� >=01.01.�������� ���� U <= DD
    SELECT nvl(SUM(td.acc_amount), 0)
      INTO v_calc_result
      FROM tmp_decline_trans_data td
     WHERE td.trans_type = gc_charge
          -- �������� ��� �� ������ ���� ����������� �� ����
          --AND td.trans_date >= trunc(SYSDATE, 'y') /* 01.01.�������� ���� */
       AND td.trans_period_end_date > gv_decline_date
       AND td.product_line_id = par_product_line_id
       AND td.asset_contact_id = par_as_contact_id;

    RETURN v_calc_result;
  END calc#62;

  FUNCTION calc#63
  (
    par_as_contact_id   as_assured.assured_contact_id%TYPE
   ,par_product_line_id t_product_line.id%TYPE
  ) RETURN NUMBER IS
    v_calc_result NUMBER;
  BEGIN

    RETURN 0;
  END calc#63;

  FUNCTION calc#64
  (
    par_as_contact_id   as_assured.assured_contact_id%TYPE
   ,par_product_line_id t_product_line.id%TYPE
  ) RETURN NUMBER IS
    v_calc_result NUMBER;
  BEGIN
    /* ����� ���������� */
    -- �������� ��������� "����� � ������ ����������" �������� �� ������������ �������� �������������� �� �������
    -- "!��������� ������", � ���� ������ �� ���� ���������, �������� ��������� "����" ������� >= 01.01.����������� ����
    SELECT nvl(ROUND(SUM(acc_amount * greatest((trans_period_end_date -
                                                 greatest(gv_decline_date, trans_period_start_date)) /
                                                 (trans_period_end_date - trans_period_start_date)
                                                ,0))
                    ,2)
              ,0)
      INTO v_calc_result
      FROM (SELECT td.acc_amount
                  ,td.trans_period_start_date
                  ,td.trans_period_end_date
              FROM tmp_decline_trans_data td
             WHERE td.trans_type = gc_charge_msfo
                  --AND td.trans_date >= trunc(SYSDATE, 'y') /* 01.01.�������� ���� */
               AND td.trans_period_end_date >= gv_decline_date
               AND td.product_line_id = par_product_line_id
               AND td.asset_contact_id = par_as_contact_id);

    RETURN v_calc_result;
  END calc#64;

  FUNCTION calc#65
  (
    par_as_contact_id   as_assured.assured_contact_id%TYPE
   ,par_product_line_id t_product_line.id%TYPE
  ) RETURN NUMBER IS
    v_calc_result NUMBER;
  BEGIN

    /* ����� ���������� */
    SELECT nvl(ROUND(SUM(acc_amount * greatest((trans_period_end_date -
                                                 greatest(gv_decline_date, trans_period_start_date)) /
                                                 (trans_period_end_date - trans_period_start_date)
                                                ,0))
                    ,2)
              ,0)
      INTO v_calc_result
      FROM (SELECT td.acc_amount
                  ,td.trans_period_start_date
                  ,td.trans_period_end_date
              FROM tmp_decline_trans_data td -- ����������
             WHERE td.trans_type = gc_charge_msfo
               AND td.trans_templ_id = 21
                  --AND td.trans_date >= trunc(SYSDATE, 'y') /* 01.01.�������� ���� */
               AND td.trans_period_end_date >= gv_decline_date
               AND td.product_line_id = par_product_line_id
               AND td.asset_contact_id = par_as_contact_id);

    RETURN v_calc_result;
  END calc#65;

  FUNCTION calc#66
  (
    par_as_contact_id   as_assured.assured_contact_id%TYPE
   ,par_product_line_id t_product_line.id%TYPE
  ) RETURN NUMBER IS
    v_calc_result NUMBER := 0;
  BEGIN
    v_calc_result := get_total_values().unpayed_premium_previous + get_total_values()
                     .unpayed_premium_current + get_total_values().unpayed_premium_lp;

    RETURN v_calc_result;
  END calc#66;

  -- ��������� �� ���������� � ��
  FUNCTION calc#67
  (
    par_as_contact_id   as_assured.assured_contact_id%TYPE
   ,par_product_line_id t_product_line.id%TYPE
  ) RETURN NUMBER IS
    v_payments    tmp_decline_trans_data.acc_amount%TYPE;
    v_charges     tmp_decline_trans_data.acc_amount%TYPE;
    v_vchp        NUMBER := 0;
    v_calc_result NUMBER := 0;
  BEGIN
    /* T��� (������) */
    v_payments := get_all_payments(par_as_contact_id, par_product_line_id);

    SELECT nvl(ROUND(SUM(acc_amount), 2), 0)
      INTO v_charges
      FROM tmp_decline_trans_data td
     WHERE td.trans_type = gc_charge
       AND td.trans_period_start_date < gv_decline_date
       AND td.asset_contact_id = par_as_contact_id
       AND td.product_line_id = par_product_line_id;

    /* ��� */
    v_vchp := get_row_values(par_as_contact_id, par_product_line_id).return_bonus_part;

    v_calc_result := greatest(v_payments - v_charges - v_vchp, 0);

    RETURN v_calc_result;
  END calc#67;

  /*
    ������ �������� ����� ���������
  */
  FUNCTION calc_program
  (
    par_decline_method_id t_decline_method.t_decline_method_id%TYPE
   ,par_as_contact_id     as_assured.assured_contact_id%TYPE
   ,par_product_line_id   p_cover.p_cover_id%TYPE
  ) RETURN NUMBER IS
    vr_method dml_t_decline_method.tt_t_decline_method;
    v_call    VARCHAR2(4000);
    v_result  NUMBER;
  BEGIN
    vr_method := dml_t_decline_method.get_record(par_decline_method_id);

    IF vr_method.function_name IS NULL
    THEN
      v_result := 0;
    ELSE
      /*
      TODO: owner="artur.baytin" category="Fix" priority="1 - High" created="03.12.2014" closed="04.12.2014"
      text="����������� ����������� �������� �������� ����� ������������"
      */
      v_call := regexp_replace(vr_method.function_name
                              ,'(calc#\d{1,2})'
                              ,'pkg_policy_decline.\1(v_as_contact_id, v_prod_line_id)');
      EXECUTE IMMEDIATE 'DECLARE
                           v_as_contact_id  NUMBER := :as_contact_id;
                           v_prod_line_id   NUMBER := :prod_line_id;
                         BEGIN :result := ' || v_call || '; END;'
        USING IN par_as_contact_id, par_product_line_id, OUT v_result;
      v_result := ROUND(nvl(v_result, 0), 2);
    END IF;
    RETURN v_result;
  END calc_program;

  FUNCTION calc_policy(par_decline_method_id t_decline_method.t_decline_method_id%TYPE) RETURN NUMBER IS
    vr_method dml_t_decline_method.tt_t_decline_method;
    v_call    VARCHAR2(4000);
    v_result  NUMBER;
  BEGIN
    vr_method := dml_t_decline_method.get_record(par_decline_method_id);
    IF vr_method.function_name IS NULL
    THEN
      v_result := 0;
    ELSE
      v_call := regexp_replace(vr_method.function_name, '(calc#\d{1,2})', 'pkg_policy_decline.\1');
      EXECUTE IMMEDIATE 'BEGIN :result := ' || v_call || '; END;'
        USING OUT v_result;
      v_result := ROUND(nvl(v_result, 0), 2);
    END IF;
    RETURN v_result;
  END calc_policy;

  /*
    ������ ������ � ���� ��������
    �� ���� ��� ����������� ������ �����������
  */
  PROCEDURE make_calculation
  (
    par_add_parameter    IN NUMBER
   ,par_pol_header       IN dml_p_pol_header.tt_p_pol_header
   ,par_policy           IN OUT NOCOPY dml_p_policy.tt_p_policy
   ,par_pol_decline      IN OUT NOCOPY dml_p_pol_decline.tt_p_pol_decline
   ,par_tt_cover_decline OUT NOCOPY dml_p_cover_decline.typ_nested_table
   ,par_result           OUT NUMBER
   ,par_commentary       OUT VARCHAR2
  ) IS
    TYPE tr_program2calc IS RECORD(
       methods            dml_t_decline_calc_program.tt_t_decline_calc_program
      ,as_asset_id        as_asset.as_asset_id%TYPE
      ,assured_contact_id as_assured.assured_contact_id%TYPE
      ,product_line_id    t_product_line.id%TYPE
      ,cover_period       p_cover_decline.cover_period%TYPE);

    TYPE tt_program2calc IS TABLE OF tr_program2calc;

    vr_policy2calc            dml_t_decline_calc_policy.tt_t_decline_calc_policy;
    vc_programs               SYS_REFCURSOR;
    vt_prog2calc              tt_program2calc := tt_program2calc();
    v_program_methods         dml_t_decline_calc_program.tt_t_decline_calc_program;
    v_assured_contact_id      as_assured.assured_contact_id%TYPE;
    v_as_asset_id             as_asset.as_asset_id%TYPE;
    v_product_line_id         t_product_line.id%TYPE;
    v_cover_period            p_cover_decline.cover_period%TYPE;
    v_is_cash_surr_exists     NUMBER(1);
    v_decline_calc_policy_id  NUMBER;
    v_decline_calc_program_id NUMBER;
    v_total_values            dml_p_cover_decline.tt_p_cover_decline;

    CURSOR cur_programs(par_policy_id NUMBER) IS
      SELECT su.assured_contact_id
            ,se.as_asset_id
            ,plo.product_line_id
            ,trunc(MONTHS_BETWEEN(trunc(pc.end_date) + 1, trunc(pc.start_date)) / 12, 2) AS cover_period
        FROM as_asset           se
            ,as_assured         su
            ,p_cover            pc
            ,t_prod_line_option plo
       WHERE se.p_policy_id = par_policy_id
         AND se.as_asset_id = su.as_assured_id
         AND se.as_asset_id = pc.as_asset_id
         AND pc.status_hist_id IN
             (SELECT sh.status_hist_id FROM status_hist sh WHERE sh.brief != 'DELETED')
         AND se.status_hist_id IN
             (SELECT sh.status_hist_id FROM status_hist sh WHERE sh.brief != 'DELETED')
         AND pc.t_prod_line_option_id = plo.id;

    --v_assured_contact_id NUMBER;
    --v_product_line_id    NUMBER;

    FUNCTION is_cash_surr_exists
    (
      par_as_contact_id   as_assured.assured_contact_id%TYPE
     ,par_product_line_id t_product_line.id%TYPE
    ) RETURN NUMBER IS
      v_is_exists NUMBER(1);
    BEGIN
      SELECT COUNT(1)
        INTO v_is_exists
        FROM dual
       WHERE EXISTS (SELECT NULL
                FROM tmp_decline_surr_data sd
               WHERE sd.as_contact_id = par_as_contact_id
                 AND sd.product_line_id = par_product_line_id);
      -- ���� �� ���, �� �������� 2
      RETURN CASE v_is_exists WHEN 0 THEN 2 ELSE 1 END;
    END is_cash_surr_exists;

    PROCEDURE calc_unpayed_premium_chargeoff IS
      v_prev_prem_to_chargeoff NUMBER;
      v_cur_prem_to_chargeoff  NUMBER;
      v_lp_prem_to_chargeoff   NUMBER;

      v_max_prem       NUMBER := 0;
      v_max_prem_index PLS_INTEGER;

      v_did                     p_cover_decline.add_invest_income%TYPE;
      v_underpayment_fact       p_cover_decline.underpayment_actual%TYPE;
      v_underpayment_prev_total p_cover_decline.underpayment_previous%TYPE;
      v_underpayment_prev       p_cover_decline.underpayment_previous%TYPE;
      v_nps_total               NUMBER;
      v_calc_result             NUMBER;
      v_total_values            dml_p_cover_decline.tt_p_cover_decline;
      v_return_amount           NUMBER;
      v_money_left_after_prev   NUMBER;
      v_money_left_after_cur    NUMBER;
    BEGIN
      v_total_values := get_total_values();
      --      v_did               := get_total_values(par_as_contact_id, par_product_line_id).add_invest_income;
      --      v_underpayment_fact := get_total_values().underpayment_actual;

      /* ���� ���� �� ����� � ��������� ������������ �������� ����� � �������� �������������
      + ������(0,13* ���; 0) >=  ����� � ������� ���������� ������������, �� =0 */
      v_return_amount := gvr_pol_decline.issuer_return_sum - gvr_pol_decline.income_tax_sum;
      IF v_return_amount < v_total_values.underpayment_actual
      THEN
        /* �������� ��������� ��������� �� �������, ������� � ��������  ������
        ��� �������� �� ��������� � ����� � �������� (�� ������� �������������� ��������)*/
        /*
        v_prev_prem_to_chargeoff := greatest(v_total_values.underpayment_previous -
                                             (gvr_pol_decline.issuer_return_sum -
                                             gvr_pol_decline.income_tax_sum)
                                            ,0);

        v_cur_prem_to_chargeoff := greatest(v_total_values.underpayment_current -
                                            greatest(gvr_pol_decline.issuer_return_sum -
                                            gvr_pol_decline.income_tax_sum -
                                            v_total_values.underpayment_previous,0)
                                           ,0);

        v_lp_prem_to_chargeoff := greatest(v_total_values.underpayment_lp -
                                           greatest(gvr_pol_decline.issuer_return_sum -
                                           gvr_pol_decline.income_tax_sum -
                                           v_total_values.underpayment_previous -
                                           v_total_values.underpayment_current,0)
                                          ,0);
        */

        /*
        �������������:
        ��������� � ������� = ��������� ����������� - ������� ��� ����� �������� �� ������������
        ������� �� ����� �����
                * ���������� �������� � �������� (�������������)
                * ������� ������� �������� ����������� �����
                * ��������� � ���������� �������
        */
        v_prev_prem_to_chargeoff := greatest(v_total_values.underpayment_previous - v_return_amount, 0);
        v_money_left_after_prev  := greatest(v_return_amount - v_total_values.underpayment_previous, 0);

        v_cur_prem_to_chargeoff := greatest(v_total_values.underpayment_current -
                                            v_money_left_after_prev
                                           ,0);
        v_money_left_after_cur  := greatest(v_money_left_after_prev -
                                            v_total_values.underpayment_current
                                           ,0);

        v_lp_prem_to_chargeoff := greatest(v_total_values.underpayment_lp - v_money_left_after_cur, 0);

        -- ������������ ��������� �� ���������� ������
        IF v_prev_prem_to_chargeoff > 0
        THEN
          /* ����������� ��������� � �������� �� ���������� */
          FOR v_idx IN vt_prog2calc.first .. vt_prog2calc.last
          LOOP

            gvt_cover_decline(v_idx).unpayed_premium_previous := ROUND(v_prev_prem_to_chargeoff * gvt_cover_decline(v_idx)
                                                                       .underpayment_previous /
                                                                       v_total_values.underpayment_previous
                                                                      ,2);
            IF v_max_prem < gvt_cover_decline(v_idx).unpayed_premium_previous
               OR v_idx = vt_prog2calc.first
            THEN
              v_max_prem       := gvt_cover_decline(v_idx).unpayed_premium_previous;
              v_max_prem_index := v_idx;
            END IF;
          END LOOP;

          /* ������ ������� �� ��������� � ������������ ���������� */
          gvt_cover_decline(v_max_prem_index).unpayed_premium_previous := v_prev_prem_to_chargeoff - get_total_values()
                                                                         .unpayed_premium_previous + gvt_cover_decline(v_max_prem_index)
                                                                         .unpayed_premium_previous;
        ELSE
          FOR v_idx IN vt_prog2calc.first .. vt_prog2calc.last
          LOOP
            gvt_cover_decline(v_idx).unpayed_premium_previous := 0;
          END LOOP;
        END IF;

        -- ����������� ��������� �� ������� ������
        IF v_cur_prem_to_chargeoff > 0
        THEN
          /* ����������� ��������� � �������� �� ���������� */
          FOR v_idx IN vt_prog2calc.first .. vt_prog2calc.last
          LOOP
            gvt_cover_decline(v_idx).unpayed_premium_current := ROUND(v_cur_prem_to_chargeoff * gvt_cover_decline(v_idx)
                                                                      .underpayment_current /
                                                                      v_total_values.underpayment_current
                                                                     ,2);
            IF v_max_prem < gvt_cover_decline(v_idx).unpayed_premium_current
               OR v_idx = vt_prog2calc.first
            THEN
              v_max_prem       := gvt_cover_decline(v_idx).unpayed_premium_current;
              v_max_prem_index := v_idx;
            END IF;
          END LOOP;

          /* ������ ������� �� ��������� � ������������ ���������� */
          gvt_cover_decline(v_max_prem_index).unpayed_premium_current := v_cur_prem_to_chargeoff - get_total_values()
                                                                        .unpayed_premium_current + gvt_cover_decline(v_max_prem_index)
                                                                        .unpayed_premium_current;
        ELSE
          FOR v_idx IN vt_prog2calc.first .. vt_prog2calc.last
          LOOP
            gvt_cover_decline(v_idx).unpayed_premium_current := 0;
          END LOOP;
        END IF;

        -- ����������� ��������� �� �������� ������
        IF v_lp_prem_to_chargeoff > 0
        THEN
          /* ����������� ��������� � �������� �� ���������� */
          FOR v_idx IN vt_prog2calc.first .. vt_prog2calc.last
          LOOP
            gvt_cover_decline(v_idx).unpayed_premium_lp := ROUND(v_lp_prem_to_chargeoff * gvt_cover_decline(v_idx)
                                                                 .underpayment_lp /
                                                                 v_total_values.underpayment_lp
                                                                ,2);
            IF v_max_prem < gvt_cover_decline(v_idx).unpayed_premium_lp
               OR v_idx = vt_prog2calc.first
            THEN
              v_max_prem       := gvt_cover_decline(v_idx).unpayed_premium_lp;
              v_max_prem_index := v_idx;
            END IF;
          END LOOP;

          /* ������ ������� �� ��������� � ������������ ���������� */
          gvt_cover_decline(v_max_prem_index).unpayed_premium_lp := v_lp_prem_to_chargeoff - get_total_values()
                                                                   .unpayed_premium_lp + gvt_cover_decline(v_max_prem_index)
                                                                   .unpayed_premium_lp;
        ELSE
          FOR v_idx IN vt_prog2calc.first .. vt_prog2calc.last
          LOOP
            gvt_cover_decline(v_idx).unpayed_premium_lp := 0;
          END LOOP;
        END IF;

        FOR v_idx IN vt_prog2calc.first .. vt_prog2calc.last
        LOOP
          gvt_cover_decline(v_idx).unpayed_msfo_prem_correction := nvl(gvt_cover_decline(v_idx)
                                                                       .unpayed_premium_previous
                                                                      ,0) + nvl(gvt_cover_decline(v_idx)
                                                                                .unpayed_premium_current
                                                                               ,0) +
                                                                   nvl(gvt_cover_decline(v_idx)
                                                                       .unpayed_premium_lp
                                                                      ,0);
        END LOOP;
      ELSE
        FOR v_idx IN vt_prog2calc.first .. vt_prog2calc.last
        LOOP
          gvt_cover_decline(v_idx).unpayed_premium_previous := 0;
          gvt_cover_decline(v_idx).unpayed_premium_current := 0;
          gvt_cover_decline(v_idx).unpayed_premium_lp := 0;
          gvt_cover_decline(v_idx).unpayed_msfo_prem_correction := 0;
        END LOOP;
      END IF;

    EXCEPTION
      WHEN zero_divide THEN
        ex.raise('�������� ����� ���� ��� ������� ����������� ������ � �������� �� ��������');
    END calc_unpayed_premium_chargeoff;

    FUNCTION calc_medo(par_pol_header_id NUMBER) RETURN NUMBER IS
      v_calc_result NUMBER := 0;
      v_doc_staus_ref_underwriting CONSTANT NUMBER := dml_doc_status_ref.get_id_by_brief('UNDERWRITING');
    BEGIN
      SELECT nvl(SUM(me.exam_cost), 0)
        INTO v_calc_result
        FROM p_policy             pp
            ,as_asset             se
            ,as_assured_docum     ad
            ,assured_medical_exam me
       WHERE pp.pol_header_id = par_pol_header_id
         AND pp.policy_id = se.p_policy_id
         AND se.as_asset_id = ad.as_assured_id
         AND ad.assured_docum_type_id = gc_assur_doctyp_med_exam
         AND ad.as_assured_docum_id = me.as_assured_docum_id
         AND pp.version_num >
             (SELECT MIN(pp_a.version_num)
                FROM p_policy   pp_a
                    ,doc_status ds
               WHERE pp_a.pol_header_id = pp.pol_header_id
                 AND pp_a.policy_id = ds.document_id
                 AND ds.doc_status_ref_id = v_doc_staus_ref_underwriting);
      RETURN v_calc_result;
    END calc_medo;
  BEGIN
    assert(par_add_parameter IS NULL
          ,'�������� ��������������� ��������� ������ ���� �������');
    flush;
    prepare_epg_temp_data(par_pol_header_id => par_policy.pol_header_id);
    prepare_trans_temp_data(par_pol_header_id => par_policy.pol_header_id);
    prepare_surr_temp_data(par_policy_id => par_policy.policy_id);
    prepare_did_temp_data(par_pol_header_id => par_policy.pol_header_id);

    /*
    ��������� ��������� ������������ �������� ������� �� �������� �� ���������� �������� �����������:
    * �� �� �  ������� �����������, ��������� � �����������;
    * �������������� ��������
    */

    determine_calc_method_policy(par_policy_id              => par_policy.policy_id
                                ,par_add_parameter          => par_add_parameter
                                ,par_decline_calc_policy_id => v_decline_calc_policy_id
                                ,par_result                 => par_result
                                ,par_commentary             => par_commentary);

    -- ������ ��������
    vr_policy2calc := dml_t_decline_calc_policy.get_record(v_decline_calc_policy_id);

    init_globals(par_decline_date        => par_policy.decline_date
                ,par_policy              => par_policy
                ,par_pol_decline         => par_pol_decline
                ,par_decline_calc_policy => vr_policy2calc);
    /*
    * ���� �������� ��������� ��������� ����� �1 � ��������� �������, �� ������� � ������� ��������.
    * � ��������� ������ ����� �� ���������� ��������� �����������:
    * ��������� ��������� � �2 � ��������� � �������;
    * ����������� � ����� ������
    */
    IF par_result = gc_ok
    THEN
      /*
      * ��� ������ ��������� �� �������� ������ ��, ��������� � �������� �����������:
      * ���������� ������� �������� �����
      * ��������� ��������� ������������ �������� ������� �� ���������. ���� ��������� ������� ������, ����� � ������� �� ��������� �������.
      * ��������� ������ ���� �����������
      */

      OPEN cur_programs(par_pol_header.policy_id);
      LOOP
        FETCH cur_programs
          INTO v_assured_contact_id
              ,v_as_asset_id
              ,v_product_line_id
              ,v_cover_period;
        EXIT WHEN cur_programs%NOTFOUND OR par_result = gc_error;
        -- ���������� ������� �������� �����
        v_is_cash_surr_exists := is_cash_surr_exists(par_as_contact_id   => v_assured_contact_id
                                                    ,par_product_line_id => v_product_line_id);
        -- ��������� ��������� ������������ �������� ������� �� ���������
        determine_calc_method_program(par_decline_calc_policy_id  => v_decline_calc_policy_id
                                     ,par_policy_surr_existence   => v_is_cash_surr_exists
                                     ,par_product_line_id         => v_product_line_id
                                     ,par_decline_calc_program_id => v_decline_calc_program_id
                                     ,par_result                  => par_result
                                     ,par_commentary              => par_commentary);

        IF par_result = gc_ok
        THEN
          vt_prog2calc.extend(1);
          vt_prog2calc(vt_prog2calc.count).methods := dml_t_decline_calc_program.get_record(v_decline_calc_program_id);
          vt_prog2calc(vt_prog2calc.count).as_asset_id := v_as_asset_id;
          vt_prog2calc(vt_prog2calc.count).assured_contact_id := v_assured_contact_id;
          vt_prog2calc(vt_prog2calc.count).cover_period := v_cover_period;
          vt_prog2calc(vt_prog2calc.count).product_line_id := v_product_line_id;

          gv_contact2asset(v_assured_contact_id) := v_as_asset_id;
        END IF;
      END LOOP;
      CLOSE cur_programs;

      -- ���� ��� ����������� �������, ��������� ������ �������� � �� � ��������� �������
      IF par_result = gc_ok
      THEN
        /*
        ������������������ ���������� �������:
        * �������� ����� - �������
        * �������������� �������� �����  - �������
        * ���.������ ����� - �������
        * ��� �� ������
        * ������� ����� ������/ �������
        */
        gvt_cover_decline.extend(vt_prog2calc.count);
        FOR v_idx IN vt_prog2calc.first .. vt_prog2calc.last
        LOOP
          gvt_cover_decline(v_idx).p_pol_decline_id := par_pol_decline.p_pol_decline_id;
          gvt_cover_decline(v_idx).ent_id := dml_p_cover_decline.get_entity_id;
          gvt_cover_decline(v_idx).as_asset_id := vt_prog2calc(v_idx).as_asset_id;
          gvt_cover_decline(v_idx).cover_period := vt_prog2calc(v_idx).cover_period;
          gvt_cover_decline(v_idx).t_product_line_id := vt_prog2calc(v_idx).product_line_id;

          v_assured_contact_id := vt_prog2calc(v_idx).assured_contact_id;
          v_product_line_id    := vt_prog2calc(v_idx).product_line_id;
          v_program_methods    := vt_prog2calc(v_idx).methods;

          -- �������� �����

          gvt_cover_decline(v_idx).redemption_sum := calc_program(v_program_methods.policy_surrender
                                                                 ,v_assured_contact_id
                                                                 ,v_product_line_id);
          -- �������������� �������� �����
          gvt_cover_decline(v_idx).add_policy_surrender := calc_program(v_program_methods.add_policy_surrender
                                                                       ,v_assured_contact_id
                                                                       ,v_product_line_id);
          -- ���. ������. �����
          gvt_cover_decline(v_idx).add_invest_income := calc_program(v_program_methods.did
                                                                    ,v_assured_contact_id
                                                                    ,v_product_line_id);
          -- ������� �� ������� ����
          gvt_cover_decline(v_idx).admin_expenses := calc_program(vt_prog2calc(v_idx)
                                                                  .methods.rvd_by_risk
                                                                 ,v_assured_contact_id
                                                                 ,v_product_line_id);
          -- ������� ����� ������
          gvt_cover_decline(v_idx).return_bonus_part := calc_program(v_program_methods.vchp
                                                                    ,v_assured_contact_id
                                                                    ,v_product_line_id);

        END LOOP;

        /*
        ������������������ ���������� �������:
        * ������� �� ������� ��������� ���� - ����
        */
        --gvr_pol_decline.management_expenses := calc_policy(vr_policy2calc.court_costs);
        gvr_pol_decline.management_expenses := nvl(gvr_pol_decline.penalty, 0) +
                                               nvl(gvr_pol_decline.other_court_fees, 0) +
                                               nvl(gvr_pol_decline.borrowed_money_percent, 0) +
                                               nvl(gvr_pol_decline.state_duty, 0) +
                                               nvl(gvr_pol_decline.moral_damage, 0) +
                                               nvl(gvr_pol_decline.service_fee, 0);

        /*
        * ��������� �� ������� �������
        * ��������� �� ������� ������
        * ���������  �� ��
        * ��������� ����������� (�������)
        * ����������� ������ � �������� ������� ���
        * ����������� ������ � �������� �������� ����
        * ����������� ������ ���� � ��������
        */
        FOR v_idx IN vt_prog2calc.first .. vt_prog2calc.last
        LOOP

          v_assured_contact_id := vt_prog2calc(v_idx).assured_contact_id;
          v_product_line_id    := vt_prog2calc(v_idx).product_line_id;
          v_program_methods    := vt_prog2calc(v_idx).methods;

          -- ��������� �� ������� ������
          gvt_cover_decline(v_idx).underpayment_previous := calc_program(v_program_methods.underpayment_previous
                                                                        ,v_assured_contact_id
                                                                        ,v_product_line_id);
          -- ��������� �� ������� ������
          gvt_cover_decline(v_idx).underpayment_current := calc_program(v_program_methods.underpayment_current
                                                                       ,v_assured_contact_id
                                                                       ,v_product_line_id);
          -- ��������� �� ��
          gvt_cover_decline(v_idx).underpayment_lp := calc_program(v_program_methods.underpayment_lp
                                                                  ,v_assured_contact_id
                                                                  ,v_product_line_id);
          -- ��������� �����������
          gvt_cover_decline(v_idx).underpayment_actual := calc_program(v_program_methods.underpayment_fact
                                                                      ,v_assured_contact_id
                                                                      ,v_product_line_id);
          -- ���������
          gvt_cover_decline(v_idx).overpayment := calc_program(v_program_methods.overpayment
                                                              ,v_assured_contact_id
                                                              ,v_product_line_id);
          -- ����������� ������ ������� ��� � ��������
          gvt_cover_decline(v_idx).bonus_off_prev := calc_program(v_program_methods.premium_previous
                                                                 ,v_assured_contact_id
                                                                 ,v_product_line_id);
          -- ����������� ������ �������� ������� � ��������
          gvt_cover_decline(v_idx).bonus_off_current := calc_program(v_program_methods.premium_current
                                                                    ,v_assured_contact_id
                                                                    ,v_product_line_id);
          -- ����������� ������ ���� � ��������
          gvt_cover_decline(v_idx).premium_msfo := calc_program(v_program_methods.premium_msfo
                                                               ,v_assured_contact_id
                                                               ,v_product_line_id);
        END LOOP;

        /*
        * � ����� � ��������� ������������ �������� ����� � �������� ������������ (���)
        * ��������� �� ������, ������������ �� �������
        * ��������� �����������
        * ������� �� ����
        * ��������� �� ������ ����������
        * ����� ����
        * -? ���� ���������� ����
        * ����� � �������
        */
        v_total_values := get_total_values();

        gvr_pol_decline.issuer_return_sum := nvl(v_total_values.redemption_sum, 0) +
                                             nvl(v_total_values.add_policy_surrender, 0) +
                                             nvl(v_total_values.add_invest_income, 0) +
                                             nvl(v_total_values.return_bonus_part, 0) -
                                             nvl(v_total_values.admin_expenses, 0);

        gvr_pol_decline.income_tax_sum := CEIL(0.13 * nvl(v_total_values.add_invest_income, 0));
        gvr_pol_decline.debt_fee_fact  := nvl(v_total_values.underpayment_actual, 0);

        gvr_policy.debt_summ := least(gvr_pol_decline.issuer_return_sum
                                     ,gvr_pol_decline.debt_fee_fact);

        IF is_policy_annulled(par_policy.policy_id) = 1
        THEN
          gvr_pol_decline.medo_cost := calc_medo(gvr_policy.pol_header_id);
        ELSE
          gvr_pol_decline.medo_cost := 0;
        END IF;

        gvr_pol_decline.overpayment := v_total_values.overpayment;

        -- �������� 32, ������� �� ��������!
        --gvr_policy.return_summ := calc_policy(vr_policy2calc.total);

        gvr_policy.return_summ := nvl(gvr_pol_decline.issuer_return_sum, 0) -
                                  nvl(gvr_policy.debt_summ, 0) + nvl(gvr_pol_decline.overpayment, 0) -
                                  nvl(gvr_pol_decline.medo_cost, 0) -
                                  nvl(gvr_pol_decline.other_pol_sum, 0) +
                                  nvl(gvr_pol_decline.management_expenses, 0);

        calc_unpayed_premium_chargeoff;

        /* ���� ���������� ���� */
        IF gvr_pol_decline.income_tax_sum > 0
           AND gvr_policy.return_summ > 0
        THEN
          gvr_pol_decline.income_tax_date := last_day(gvr_pol_decline.act_date);
        END IF;

        par_tt_cover_decline := gvt_cover_decline;
        par_policy           := gvr_policy;
        par_pol_decline      := gvr_pol_decline;
      END IF;
    END IF;
    /*  EXCEPTION
    WHEN OTHERS THEN
      IF vc_programs%ISOPEN
      THEN
        CLOSE vc_programs;
      END IF;
      RAISE;*/
  END make_calculation;

  /* ���������� ������� */
  /*
  TODO: owner="artur.baytin" category="Fix" priority="2 - Medium" created="21.11.2014" closed="22.11.2014"
  text="�������� �������� ID ����������� �� ID ������"
  */
  PROCEDURE calculate_decline
  (
    par_policy_id  p_policy.policy_id%TYPE
   ,par_result     OUT p_decline_pack_detail.result%TYPE
   ,par_commentary OUT p_decline_pack_detail.commentary%TYPE
  ) IS
    vr_detail        p_decline_pack_detail%ROWTYPE;
    v_add_parameter  NUMBER(1) := 0;
    vr_policy        dml_p_policy.tt_p_policy;
    vr_pol_decline   dml_p_pol_decline.tt_p_pol_decline;
    vr_pol_header    dml_p_pol_header.tt_p_pol_header;
    vt_cover_decline dml_p_cover_decline.typ_nested_table;

    PROCEDURE delete_covers(par_pol_decline_id p_pol_decline.p_pol_decline_id%TYPE) IS
      vt_decline_covers dml_p_cover_decline.typ_prymary_key_nested_table;
    BEGIN
      SELECT cd.p_cover_decline_id
        BULK COLLECT
        INTO vt_decline_covers
        FROM p_cover_decline cd
       WHERE cd.p_pol_decline_id = par_pol_decline_id;

      dml_p_cover_decline.delete_record_list(par_primary_key_list => vt_decline_covers);
    END delete_covers;

    -- ������ ������ �� ��
    PROCEDURE post_policy
    (
      par_policy      dml_p_policy.tt_p_policy
     ,par_pol_decline dml_p_pol_decline.tt_p_pol_decline
    ) IS
    BEGIN
      dml_p_policy.update_record(gvr_policy);
      dml_p_pol_decline.update_record(gvr_pol_decline);
    END post_policy;

    -- ������ ������ �� ����������
    PROCEDURE post_covers(par_tt_cover_decline IN OUT NOCOPY dml_p_cover_decline.typ_nested_table) IS
    BEGIN
      DELETE FROM p_cover_decline pc WHERE pc.p_pol_decline_id = gvr_pol_decline.p_pol_decline_id;
      dml_p_cover_decline.insert_record_list(par_tt_cover_decline);
    END post_covers;

    FUNCTION get_detail_by_policy
    (
      par_policy_id      p_policy.policy_id%TYPE
     ,par_raise_on_error BOOLEAN DEFAULT FALSE
    ) RETURN p_decline_pack_detail%ROWTYPE IS
      vr_detail p_decline_pack_detail%ROWTYPE;
    BEGIN
      BEGIN
        SELECT pd.* INTO vr_detail FROM p_decline_pack_detail pd WHERE pd.p_policy_id = par_policy_id;
      EXCEPTION
        WHEN no_data_found THEN
          IF par_raise_on_error
          THEN
            ex.raise('�� ������� ������ ����������� ������ ��������� �� ������ ��');
          END IF;
        WHEN too_many_rows THEN
          IF par_raise_on_error
          THEN
            ex.raise('������� ��������� ������� ����������� ������ ��������� �� ������ ��');
          END IF;
      END;

      RETURN vr_detail;
    END get_detail_by_policy;

    FUNCTION is_claim_exists
    (
      par_pol_header_id        NUMBER
     ,par_doc_status_ref_brief VARCHAR2
    ) RETURN BOOLEAN IS
      v_is_exists         NUMBER(1);
      v_doc_status_ref_id doc_status_ref.doc_status_ref_id%TYPE;
    BEGIN
      v_doc_status_ref_id := dml_doc_status_ref.get_id_by_brief(par_doc_status_ref_brief);
      -- ��������� ������� ������ ������ �� ���
      SELECT COUNT(1)
        INTO v_is_exists
        FROM dual
       WHERE EXISTS (SELECT NULL
                FROM c_claim_header ch
                    ,c_claim        cc
                    ,document       dc
                    ,p_policy       pp
               WHERE pp.pol_header_id = par_pol_header_id
                 AND ch.p_policy_id = pp.policy_id
                 AND ch.c_claim_header_id = cc.c_claim_header_id
                 AND cc.c_claim_id = dc.document_id
                 AND dc.doc_status_ref_id = v_doc_status_ref_id);

      IF v_is_exists = 0
      THEN
        -- ���� �� �����, ���������, ���� �� �������� ���� � ��������� �� ������� ��������� � ������ "������"
        SELECT COUNT(1)
          INTO v_is_exists
          FROM dual
         WHERE EXISTS (SELECT NULL
                  FROM c_claim_header ch
                      ,c_claim        cc
                      ,document       dc
                      ,doc_status_ref dsr
                      ,p_policy       pp
                 WHERE pp.pol_header_id = par_pol_header_id
                   AND ch.p_policy_id = pp.policy_id
                   AND ch.c_claim_header_id = cc.c_claim_header_id
                   AND cc.c_claim_id = dc.document_id
                   AND dc.doc_status_ref_id = dsr.doc_status_ref_id
                   AND dsr.brief = 'CLOSE'
                   AND EXISTS (SELECT NULL
                          FROM doc_status ds
                         WHERE ds.document_id = dc.document_id
                           AND ds.src_doc_status_ref_id = v_doc_status_ref_id
                           AND ds.doc_status_ref_id = dsr.doc_status_ref_id));
      END IF;
      RETURN v_is_exists = 1;
    END is_claim_exists;

  BEGIN
    assert(par_policy_id IS NULL, '�� ������� �������� ID ������');

    -- ����� �������
    pkg_policy.policy_lock(par_policy_id);

    vr_detail := get_detail_by_policy(par_policy_id => par_policy_id);
    vr_policy := dml_p_policy.get_record(par_policy_id);

    IF vr_detail.p_pol_change_notice_id IS NOT NULL
    THEN
      /*
       ���� � ��������� ����������� ������� �� ��������� �� ��������� ������� ��������
       � � ����� ��������� �������� ���� ������ ����� ����� �1 � ��,
       �� �������� ��������������� ��������� ����� �1 � ����� �� ��������.
      */
      DECLARE
        vr_pol_change_notice dml_p_pol_change_notice.tt_p_pol_change_notice;
      BEGIN
        vr_pol_change_notice := dml_p_pol_change_notice.get_record(vr_detail.p_pol_change_notice_id);
        IF vr_pol_change_notice.is_to_set_off = 1
        THEN
          v_add_parameter := 1;
        END IF;
      END;
    ELSIF is_claim_exists(par_pol_header_id        => vr_policy.pol_header_id
                         ,par_doc_status_ref_brief => 'REFUSE_PAY')
    THEN
      /*
      ���� �� �������� ���������� ���� � ������� �������
      � � ������� �������� �������� ���������� ������� ��������� � ������� - �������
      ��� ���� � ������� ��������� � �������,
      �� �������� ��������������� ��������� ����� �2 � �������� � �������
      */
      v_add_parameter := 2;
    ELSIF is_claim_exists(par_pol_header_id        => vr_policy.pol_header_id
                         ,par_doc_status_ref_brief => 'FOR_PAY')
    THEN
      /*
      ���� �� �������� �����������, ���������� � ����������� ���������� ���� � ������� �������
      � � ������� �������� �������� ���������� ������� ��������� �� ������ - �������
      ��� ���� � ������� ��������� �� ������,
      �� �������� ��������������� ��������� ����� �3 � �������� �� �������
      */
      v_add_parameter := 3;
    END IF;

    vr_pol_decline := dml_p_pol_decline.get_rec_by_p_policy_id(par_policy_id);
    vr_pol_header  := dml_p_pol_header.get_record(vr_policy.pol_header_id);

    make_calculation(par_add_parameter    => v_add_parameter
                    ,par_policy           => vr_policy
                    ,par_pol_decline      => vr_pol_decline
                    ,par_pol_header       => vr_pol_header
                    ,par_tt_cover_decline => vt_cover_decline
                    ,par_result           => par_result
                    ,par_commentary       => par_commentary);

    IF par_result = gc_ok
    THEN
      /* �������� ������� ��������, �������� ������� � ���������� ������ �� */
      delete_covers(par_pol_decline_id => vr_pol_decline.p_pol_decline_id);
      post_covers(par_tt_cover_decline => vt_cover_decline);
      post_policy(par_policy => vr_policy, par_pol_decline => vr_pol_decline);
    END IF;
  END calculate_decline;

  PROCEDURE calculate_decline(par_policy_id p_policy.policy_id%TYPE) IS
    v_result     p_decline_pack_detail.result%TYPE;
    v_commentary p_decline_pack_detail.commentary%TYPE;
  BEGIN
    calculate_decline(par_policy_id  => par_policy_id
                     ,par_result     => v_result
                     ,par_commentary => v_commentary);
  END calculate_decline;

  /* �������� ������ ���������� */
  PROCEDURE create_decline_policy
  (
    par_decline_pack_detail_id p_decline_pack_detail.p_decline_pack_detail_id%TYPE
   ,par_result                 OUT p_decline_pack_detail.result%TYPE
   ,par_commentary             OUT p_decline_pack_detail.commentary%TYPE
   ,par_new_policy_id          OUT p_policy.policy_id%TYPE
  ) IS
    vr_detail                 dml_p_decline_pack_detail.tt_p_decline_pack_detail;
    vr_policy                 dml_p_policy.tt_p_policy;
    vr_decline_reason         dml_t_decline_reason.tt_t_decline_reason;
    vr_p_pol_change_notice    dml_p_pol_change_notice.tt_p_pol_change_notice;
    v_to_quit_status_flag     BOOLEAN := TRUE; --���� ������������� �������� � ������ "� �����������"
    v_decline_pack_type_brief t_decline_pack_type.brief%TYPE;
    v_decline_date            p_policy.decline_date%TYPE;
    v_count                   NUMBER;

    ex_active_not_last EXCEPTION;

    FUNCTION is_in_quit_status(par_policy_id p_policy.policy_id%TYPE) RETURN BOOLEAN IS
      v_policy_status_brief doc_status_ref.brief%TYPE;
    BEGIN
      assert(par_policy_id IS NULL, '�� ������ ID ��');
      v_policy_status_brief := doc.get_doc_status_brief(doc_id => par_policy_id);
      RETURN v_policy_status_brief IN('TO_QUIT'
                                     ,'TO_QUIT_AWAITING_USVE'
                                     ,'TO_QUIT_CHECK_READY'
                                     ,'TO_QUIT_CHECKED'
                                     ,'QUIT_REQ_QUERY'
                                     ,'QUIT_REQ_GET'
                                     ,'QUIT_TO_PAY'
                                     ,'QUIT'
                                     ,'TO_QUIT_AWAITING_VS'
                                     ,'STOPED');
    END is_in_quit_status;

    /* ���� �� ������� � ������ "��������� �� �����������" */
    FUNCTION can_change_status(par_src_status_ref_id doc_status_ref.doc_status_ref_id%TYPE)
      RETURN BOOLEAN IS
      c_dst_status_ref_id CONSTANT doc_status_ref.doc_status_ref_id%TYPE := dml_doc_status_ref.get_id_by_brief('QUIT_DECL'
                                                                                                              ,TRUE);
      c_doc_templ_id      CONSTANT doc_templ.doc_templ_id%TYPE := dml_doc_templ.get_id_by_brief('POLICY'
                                                                                               ,TRUE);
      v_can_change NUMBER(1);
    BEGIN
      SELECT COUNT(1)
        INTO v_can_change
        FROM dual
       WHERE EXISTS (SELECT NULL
                FROM doc_status_allowed dsa
               WHERE dsa.src_doc_templ_status_id IN
                     (SELECT dts.doc_templ_status_id
                        FROM doc_templ_status dts
                       WHERE dts.doc_templ_id = c_doc_templ_id
                         AND dts.doc_status_ref_id = par_src_status_ref_id)
                 AND dsa.dest_doc_templ_status_id IN
                     (SELECT dts.doc_templ_status_id
                        FROM doc_templ_status dts
                       WHERE dts.doc_templ_id = c_doc_templ_id
                         AND dts.doc_status_ref_id = c_dst_status_ref_id));
      RETURN v_can_change = 1;
    END can_change_status;

    FUNCTION get_decline_pack_type_brief(par_decline_pack_id p_decline_pack.p_decline_pack_id%TYPE)
      RETURN t_decline_pack_type.brief%TYPE IS
      v_decline_pack_type_brief t_decline_pack_type.brief%TYPE;
    BEGIN
      BEGIN
        SELECT dt.brief
          INTO v_decline_pack_type_brief
          FROM p_decline_pack      dp
              ,t_decline_pack_type dt
         WHERE dp.p_decline_pack_id = par_decline_pack_id
           AND dp.t_decline_pack_type_id = dt.t_decline_pack_type_id;
      EXCEPTION
        WHEN no_data_found THEN
          v_decline_pack_type_brief := NULL;
      END;
      RETURN v_decline_pack_type_brief;
    END get_decline_pack_type_brief;

    FUNCTION get_agent_region(par_pol_agent_doc_id p_policy_agent_doc.p_policy_agent_doc_id%TYPE)
      RETURN p_pol_decline.reg_code%TYPE IS
      v_region_code p_pol_decline.reg_code%TYPE;
    BEGIN
      BEGIN
        SELECT nvl(to_number(substr(tp.ocatd, 1, 2)), 45)
          INTO v_region_code
          FROM p_policy_agent_doc pad
              ,ag_contract_header ch
              ,department         dp
              ,organisation_tree  ot
              ,t_province         tp
         WHERE pad.p_policy_agent_doc_id = par_pol_agent_doc_id
           AND pad.ag_contract_header_id = ch.ag_contract_header_id
           AND ch.agency_id = dp.department_id
           AND dp.org_tree_id = ot.organisation_tree_id
           AND ot.province_id = tp.province_id;
      EXCEPTION
        WHEN no_data_found THEN
          v_region_code := 45;
      END;
      RETURN v_region_code;
    END get_agent_region;

    FUNCTION get_decline_date
    (
      par_decline_pack_type_brief t_decline_pack_type.brief%TYPE
     ,par_pol_change_notice_id    p_pol_change_notice.p_pol_change_notice_id%TYPE
     ,par_policy_id               p_policy.policy_id%TYPE
     ,par_policy_header_id        p_pol_header.policy_header_id%TYPE
    ) RETURN p_policy.decline_date%TYPE IS
      v_decline_date p_policy.decline_date%TYPE;
      vr_notice      dml_p_pol_change_notice.tt_p_pol_change_notice;
      vr_pol_header  dml_p_pol_header.tt_p_pol_header;
    BEGIN

      IF par_decline_pack_type_brief IN ('TERMNATION_NOTICE', 'ANNULATION_NOTICE')
      THEN
        -- ��� �������� �� ���������� - ���� ����������� �� ���������.
        vr_notice      := dml_p_pol_change_notice.get_record(par_p_pol_change_notice_id => par_pol_change_notice_id);
        v_decline_date := vr_notice.policy_decline_date; --� ���� ����������� �� ���������
      ELSIF par_decline_pack_type_brief IN ('FIRST_UNPAID_FEE')
      THEN
        -- ��� �������� ����  ������������ �� �������� ������� ������ � ���� ������ �������� ��������
        vr_pol_header  := dml_p_pol_header.get_record(par_policy_header_id => par_policy_header_id);
        v_decline_date := vr_pol_header.start_date;
      ELSIF par_decline_pack_type_brief = 'ASSURED_DEAD'
      THEN
        -- ��� �������� ���� ������������ � ����� �� ������� ��������������� - ���� ������ ��������������� + 1 ����.
        -- �� �� ��������������, ��� �������������� ����
        BEGIN
          SELECT cp.date_of_death + 1
            INTO v_decline_date
            FROM as_asset   se
                ,as_assured su
                ,contact    co
                ,cn_person  cp
           WHERE se.as_asset_id = su.as_assured_id
             AND su.assured_contact_id = co.contact_id
             AND co.contact_id = cp.contact_id
             AND se.p_policy_id = par_policy_id;
        EXCEPTION
          WHEN no_data_found THEN
            ex.raise(par_message => '�������������� �� ������!');
          WHEN too_many_rows THEN
            ex.raise(par_message => '��� ���� "����������� � ����� �� ������� ���������������" � �������� �� ������ ���� ��������� ��������������!');
        END;
      ELSIF par_decline_pack_type_brief = 'NEXT_UNPAID_FEE'
      THEN
        -- ��� �������� ���� ������������ �� �������� ���������� ������ - ����, ��������� � ���� ����� ������� ��� � ������� �� ������ � ����������� �� + 1 ����.
        SELECT MAX(ac.grace_date) keep(dense_rank FIRST ORDER BY ac.payment_id) + 1
          INTO v_decline_date
          FROM doc_doc        dd
              ,ac_payment     ac
              ,document       dc
              ,doc_templ      dt
              ,doc_status_ref dsr
              ,p_policy       pp
         WHERE pp.pol_header_id = par_policy_header_id /*����� �� ������ ����� ���� ��������� � ������ ������� �� 7.5.2015 ������ �.*/
           AND dd.parent_id = pp.policy_id
           AND dd.child_id = dc.document_id
           AND dc.document_id = ac.payment_id
           AND dc.doc_templ_id = dt.doc_templ_id
           AND dt.brief = 'PAYMENT'
           AND dc.doc_status_ref_id = dsr.doc_status_ref_id
           AND dsr.brief = 'TO_PAY';
      END IF;

      IF v_decline_date IS NULL
      THEN
        ex.raise(par_message => '�� ������� �������� ���� �����������!');
      END IF;

      RETURN v_decline_date;
    END get_decline_date;

    FUNCTION get_decline_reason_id
    (
      par_decline_pack_type_brief t_decline_pack_type.brief%TYPE
     ,par_pol_change_notice_id    p_pol_change_notice.p_pol_change_notice_id%TYPE
    ) RETURN t_decline_reason.t_decline_reason_id%TYPE IS
      v_decline_reason_id t_decline_reason.t_decline_reason_id%TYPE;
      vr_notice           dml_p_pol_change_notice.tt_p_pol_change_notice;
    BEGIN
      IF par_decline_pack_type_brief IN ('TERMNATION_NOTICE', 'ANNULATION_NOTICE')
      THEN
        -- ��� �������� ����� ���������� �� ����������� / ���������� �� ������������� - ������� ����������� �� ���������.
        vr_notice           := dml_p_pol_change_notice.get_record(par_p_pol_change_notice_id => par_pol_change_notice_id);
        v_decline_reason_id := vr_notice.t_decline_reason_id;
      ELSIF par_decline_pack_type_brief = 'ASSURED_DEAD'
      THEN
        -- ��� �������� ���� ������������ � ����� �� ������� ��������������� - ������� ���������������.
        v_decline_reason_id := dml_t_decline_reason.get_id_by_brief('������ ���������������');
      ELSIF par_decline_pack_type_brief = 'NEXT_UNPAID_FEE'
      THEN
        -- ��� �������� ���� ������������ �� �������� ���������� ������ - ��������� ���������� ������.
        v_decline_reason_id := dml_t_decline_reason.get_id_by_brief('�����������');
      ELSIF par_decline_pack_type_brief = 'FIRST_UNPAID_FEE'
      THEN
        -- ��� �������� ���� ������������ �� �������� ������� ������ - ��������� ������� ������
        v_decline_reason_id := dml_t_decline_reason.get_id_by_brief('�������� ������� ������');
      ELSE
        ex.raise(par_message => '��� ����������� � ������� ��������� "' || par_decline_pack_type_brief ||
                                '" ����������!');
      END IF;

      IF v_decline_reason_id IS NULL
      THEN
        ex.raise(par_message => '�� ������� �������� ������� �����������!');
      END IF;

      RETURN v_decline_reason_id;
    END get_decline_reason_id;

    PROCEDURE set_decline_reason2policy
    (
      par_policy_id         p_policy.policy_id%TYPE
     ,par_decline_date      p_policy.decline_date%TYPE
     ,par_decline_reason_id p_policy.decline_reason_id%TYPE
    ) IS
    BEGIN
      assert(par_policy_id IS NULL
            ,'ID ������ �������� �� ������ ���� ����!');

      UPDATE p_policy pp
         SET pp.decline_date      = par_decline_date
            ,pp.decline_reason_id = par_decline_reason_id
       WHERE pp.policy_id = par_policy_id;
    END set_decline_reason2policy;

    /*���������� ������ ��������� - �� ����������*/
    PROCEDURE set_notice_not_processed
    (
      par_p_pol_change_notice_id p_decline_pack_detail.p_pol_change_notice_id%TYPE
     ,par_error_text             VARCHAR2 := NULL
    ) IS
    BEGIN
      IF par_p_pol_change_notice_id IS NOT NULL
      THEN
        doc.set_doc_status(p_doc_id => par_p_pol_change_notice_id, p_status_brief => 'NOT_PROCESSED');
      END IF;
      par_result     := gc_error;
      par_commentary := '������ ��� �������� ������ �����������: "' ||
                        nvl(par_error_text, dbms_utility.format_error_stack) || '"';
    END set_notice_not_processed;

    /*��������, ��� �� ��� ������� �� ���� �����������*/
    FUNCTION is_policy_ended
    (
      par_policy_id    p_policy.policy_id%TYPE
     ,par_decline_date p_policy.decline_date%TYPE
    ) RETURN BOOLEAN IS
      v_count NUMBER;
    BEGIN
      SELECT COUNT(*)
        INTO v_count
        FROM dual
       WHERE EXISTS (SELECT NULL
                FROM p_policy pp
               WHERE pp.policy_id = par_policy_id
                 AND pp.end_date < par_decline_date);
      RETURN v_count = 1;
    END is_policy_ended;

    /*��������,  ��� �������� ������ �������� ��������� ������������*/
    FUNCTION is_active_version_last(par_policy_id p_policy.policy_id%TYPE) RETURN BOOLEAN IS
      v_count NUMBER;
    BEGIN
      SELECT COUNT(*)
        INTO v_count
        FROM dual
       WHERE EXISTS (SELECT NULL
                FROM p_pol_header pph
               WHERE pph.policy_id = par_policy_id
                 AND pph.policy_id = pph.max_uncancelled_policy_id);
      RETURN v_count = 1;
    END is_active_version_last;

  BEGIN
    assert(par_decline_pack_detail_id IS NULL
          ,'�� ������� �������� ID �����������');

    SAVEPOINT before_create_decline_policy;

    par_result     := gc_ok;
    par_commentary := '������� ������� ������ �����������';

    vr_detail              := dml_p_decline_pack_detail.get_record(par_decline_pack_detail_id);
    vr_policy              := dml_p_policy.get_record(par_policy_id => vr_detail.p_policy_id);
    vr_p_pol_change_notice := dml_p_pol_change_notice.get_record(par_p_pol_change_notice_id => vr_detail.p_pol_change_notice_id);

    v_decline_pack_type_brief := get_decline_pack_type_brief(par_decline_pack_id => vr_detail.p_decline_pack_id);
    /*���������� ���� �����������*/
    v_decline_date := get_decline_date(par_decline_pack_type_brief => v_decline_pack_type_brief
                                      ,par_pol_change_notice_id    => vr_detail.p_pol_change_notice_id
                                      ,par_policy_id               => vr_policy.policy_id
                                      ,par_policy_header_id        => vr_policy.pol_header_id);

    IF is_in_quit_status(par_policy_id => vr_policy.policy_id)
       OR is_policy_ended(par_policy_id => vr_policy.policy_id, par_decline_date => v_decline_date) /*���� ���� ����������� ����� ���� ��������� ��, �� �������� ������*/
    THEN
      /*
      ���� ������ �������� ������ �������� ����������� �� ����������� ����������� ������
        ���� � ����������� ���� ������ �� ��������� �� ��������� ������� ��������, �� ��������� ��� � ������ ��� ���������
        ��������� ���������� ��������� ��������� ������ ������������ �� ���������� ��������� �����������:
        * ���������� ��������� - �2 � ��������� � �������;
        * ������������  �������� ����������� ��� ��������� � �������� <����� ������� �����������, ��������� � �������� ������ �������� �����������> */
      IF vr_detail.p_pol_change_notice_id IS NOT NULL
      THEN
        doc.set_doc_status(p_doc_id       => vr_detail.p_pol_change_notice_id
                          ,p_status_brief => 'NOT_PROCESSED');
      END IF;
      vr_decline_reason := dml_t_decline_reason.get_record(par_t_decline_reason_id => vr_policy.decline_reason_id);
      par_result        := gc_error;
      par_commentary    := '�� ���� ����������� ' || to_char(v_decline_date, 'dd.mm.rrrr') ||
                           '������� ����������� ��� �������� ��� ������� ����������� ��� ��������� � �������� "' ||
                           vr_decline_reason.name || '"';
    ELSIF NOT
           can_change_status(par_src_status_ref_id => doc.get_doc_status_id(doc_id => vr_policy.policy_id))
    THEN
      /*
      ���� �� �������� ������� �������� ������ �� ����������� ������� � ������ ���������� �� �����������
        ���� � ����������� ���� ������ �� ��������� �� ��������� ������� ��������, �� ��������� ��� � ������ ��� ���������.
        ��������� ���������� ��������� ��������� ������ ������������ �� ���������� ��������� �����������:
        * ���������� ��������� -  �2 - ��������� � �������;
        * ������������ - ���  ������� �������� ������ ����������� ������� � ������ ���������� �� ����������� */
      IF vr_detail.p_pol_change_notice_id IS NOT NULL
      THEN
        doc.set_doc_status(p_doc_id       => vr_detail.p_pol_change_notice_id
                          ,p_status_brief => 'NOT_PROCESSED');
      END IF;
      par_result     := gc_error;
      par_commentary := '�� ������� �������� ������ ����������� ������� � ������ "��������� �� �����������"';
    ELSE

      DECLARE
        v_pol_agent_doc_id p_policy_agent_doc.p_policy_agent_doc_id%TYPE;
        v_region_num       p_pol_decline.reg_code%TYPE;

        v_decline_reason_id t_decline_reason.t_decline_reason_id%TYPE;
        v_act_date          p_pol_decline.act_date%TYPE;

      BEGIN
        SAVEPOINT before_new_version;
        /*
        ��������� �������� ������ �� � ������ ���������� �� �����������.
        ������� ������ ����������� � ������� ������� ����� ������������
        ��������� ������ ������ � ���������� �� ����������� � ������� ����� � ����� ����������
        (����� �� ������������ �� ������)*/

        doc.set_doc_status(p_doc_id => vr_policy.policy_id, p_status_brief => 'QUIT_DECL');

        /*��������, ��� �������� ������ �������� ���������, ���� ���, �� ������ ������*/
        IF NOT is_active_version_last(par_policy_id => vr_policy.policy_id)
        THEN
          par_result     := gc_error;
          par_commentary := '�������� ������ �� �������� ���������. ����������� ���������';
          RAISE ex_active_not_last;
        END IF;

        par_new_policy_id := pkg_policy.new_policy_version(par_policy_id      => vr_policy.policy_id
                                                          ,par_version_status => 'DECLINE_CALCULATION'
                                                          ,par_start_date     => vr_policy.start_date /*���� ������ ������� �� ������ "�������� �� �����������" 23.4.2015 413562*/);
        /*���� ���� ������� ����� ������, �� �������� �� �������� ������ � ����������� ������, ����� ���� ����������� ������������
        �����, ���� ���� ������
        */
        vr_detail.p_policy_id := par_new_policy_id;
        dml_p_decline_pack_detail.update_record(par_record => vr_detail);

        v_pol_agent_doc_id := pkg_agn_control.get_current_policy_agent(par_pol_header_id => vr_policy.pol_header_id);
        v_region_num       := get_agent_region(par_pol_agent_doc_id => v_pol_agent_doc_id);

        v_decline_reason_id := get_decline_reason_id(par_decline_pack_type_brief => v_decline_pack_type_brief
                                                    ,par_pol_change_notice_id    => vr_detail.p_pol_change_notice_id);
        /*������ �� ���������� ���� ����:
         1. ���� ���� ����������� ������ ������� ����, �� ���� �����������.
        2.  �����:
        2.1.  ���� ����� ���� ����������� � ������� ����� ���������, �� ������� ����.
        2.2.  ���� ����� ���� ����������� � ������� ����� �� ���������,  � ������, � ������� ��������� ���� ����������� ������, �� ��������� ���� ������ ���� �����������.
        2.3.  ���� ����� ���� ����������� � ������� ����� �� ���������,  � ������, � ������� ��������� ���� ����������� ������, �� ������� ����.
        */
        CASE
          WHEN v_decline_date > SYSDATE THEN
            v_act_date := v_decline_date;
          WHEN trunc(v_decline_date, 'mm') = trunc(SYSDATE, 'mm') THEN
            v_act_date := trunc(SYSDATE);
          WHEN pkg_period_closed.check_date_in_closed(v_decline_date) = 0 /*������ ������*/
           THEN
            v_act_date := last_day(v_decline_date);
          ELSE
            v_act_date := trunc(SYSDATE);
        END CASE;

        set_decline_reason2policy(par_policy_id         => par_new_policy_id
                                 ,par_decline_date      => v_decline_date
                                 ,par_decline_reason_id => v_decline_reason_id);

        dml_p_pol_decline.insert_record(par_p_policy_id         => par_new_policy_id
                                       ,par_reg_code            => v_region_num
                                       ,par_t_product_conds_id  => vr_policy.t_product_conds_id
                                       ,par_act_date            => v_act_date
                                       ,par_decline_notice_date => vr_p_pol_change_notice.notice_date /*���� ��������� �� ���������, ���� ��� ���� � �����������*/);
        BEGIN
          /*�������� ������� ������� �� ����. ���� ����� ������ (�������� �� ��������), �� ��������� �� � ������ �� �����������. �������� ������� ���ݻ.
          ���� ������ �� �����, �� ����� ��������� ������������� ������ � ���������� �������.*/
          pkg_policy_quit.check_claim(par_policy_id => par_new_policy_id);
        EXCEPTION
          WHEN OTHERS THEN
            /* ����������� ������� ������� �� ������� ����� ������������ � ������ �� �����������. ������� ������� ���ݻ ��������� ������*/
            v_to_quit_status_flag := FALSE; --�� ���������� � ������ "� �����������", �.�. ���� �� ����� ����
            doc.set_doc_status(p_doc_id       => par_new_policy_id
                              ,p_status_brief => 'TO_QUIT_AWAITING_USVE');
        END;

        /*������ ���������� � ������� � ������ "� �����������"*/
        IF v_to_quit_status_flag
        THEN
          --������������� ��������, ������� ����� ���� �����������
          --������ 412697

          SELECT COUNT(*)
            INTO v_count
            FROM fv_pol_decline   fpd
                ,t_decline_reason tdr
           WHERE fpd.policy_id = par_new_policy_id
             AND tdr.t_decline_reason_id = fpd.decline_reason_id
             AND tdr.t_decline_type_id = (SELECT tdt.t_decline_type_id
                                            FROM t_decline_type tdt
                                           WHERE tdt.brief = '�������������');
          --

          IF v_count = 0
          THEN
            pkg_a7.annulated_payment(par_policy_id => par_new_policy_id
                                    ,par_from_date => v_decline_date);
          END IF;
          --��������� ������ ������
          pkg_policy_decline.calculate_decline(par_policy_id  => par_new_policy_id
                                              ,par_result     => par_result
                                              ,par_commentary => par_commentary);

          /*���� ������������ ��� ������, �� ����������*/
          IF par_result = gc_ok
          THEN
            /*���� �������� ����� �� �� ����������� ������, �� ��������� � ������ "� �����������. ������� ��"*/
            IF pkg_policy.get_redempt_sum_is_handchange(par_policy_header_id => vr_policy.pol_header_id) = 1
            THEN
              v_to_quit_status_flag := FALSE; --�� ���������� � ������ "� �����������", �.�. ���� �� ����� �������� ����
              doc.set_doc_status(p_doc_id       => par_new_policy_id
                                ,p_status_brief => 'TO_QUIT_AWAITING_VS');
              --���������� ������ ��������� "�� ����������"
              set_notice_not_processed(vr_detail.p_pol_change_notice_id
                                      ,'�� ������ �� ��������� ������ ���� ��');
            ELSE
              /* ����������� ������� ������� �� ������� ����� ������������ � ������ �� ������������ ��������� ������*/
              doc.set_doc_status(p_doc_id => par_new_policy_id, p_status_brief => 'TO_QUIT');
              IF vr_detail.p_pol_change_notice_id IS NOT NULL
              THEN
                doc.set_doc_status(p_doc_id       => vr_detail.p_pol_change_notice_id
                                  ,p_status_brief => 'TO_QUIT');
              END IF;
            END IF;

          ELSE
            ROLLBACK TO before_new_version;
            --���������� ������ ��������� "�� ����������"
            set_notice_not_processed(vr_detail.p_pol_change_notice_id, par_commentary);
          END IF; --����� ���� ������������ � ��������
        END IF; --����� ���� ����������
      EXCEPTION
        WHEN ex_active_not_last THEN
          ROLLBACK TO before_new_version;
      END;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      /*
      ���� � �������� �������� ������ ����������� ���� �������� ������, �� �������� �������� ������ ����������� � ������� ������� �:
      * ���� � ����������� ���� ������ �� ��������� �� ��������� ������� ��������, �� ��������� ��� � ������ ��� ���������
      * ��������� ���������� ��������� �� ���������� ��������� �����������:
        * ��������� ��������� -  �2 - ��������� � �������;
        * ����������� �  ������� ��� �������� ������ �����������: <����� ���������� ������>�.
      */
      ROLLBACK TO before_create_decline_policy;
      set_notice_not_processed(vr_detail.p_pol_change_notice_id);
  END create_decline_policy;

END pkg_policy_decline;
/

CREATE OR REPLACE PACKAGE pkg_policy IS

  /**
  * ������ � �������� - ��������, ��������������, ��������, ��������� ��������
  * @author Patsan O.
  * @version 1
  */

  -- ���� ��� ���������� �������� ����������� �������� ������� ��� �������� ����� ������ ������
  -- ������������ ��� ���������� ����-�������
  flag_dont_check_status NUMBER(1) := 0;

  TYPE t_cover_cursor IS REF CURSOR RETURN p_cover%ROWTYPE;

  /**
  * ���������� ������ �������� �����������
  * @author Patsan O.
  * @param p_pol_id �� ����� �������� �����������
  */
  PROCEDURE policy_lock(p_pol_id IN NUMBER);

  /**
  * �������� ����� ������ �� ��������
  * @author Patsan O.
  * @param p_prod_id �� ��������
  * @param p_cont_type_id �� ���� ��������
  * @return ����� ������
  */
  FUNCTION get_policy_ser
  (
    p_prod_id      IN NUMBER
   ,p_cont_type_id IN NUMBER DEFAULT NULL
   ,p_policy_id    IN NUMBER DEFAULT NULL
  ) RETURN VARCHAR2;

  /*
    ������ �.
  
    ��������� ����� ������-������� �������� ������ ��
    @param par_policy_id - �� ������ ��
    @param par_include_admin_cost - �������� ���. �������� (TRUE - ��������, FALSE - �� ��������)
    @return ����� ������-������� �������� ������ ��
  */
  FUNCTION get_policy_fee
  (
    par_policy_id          p_policy.policy_id%TYPE
   ,par_include_admin_cost BOOLEAN DEFAULT FALSE
   ,par_round_to           NUMBER DEFAULT NULL
  ) RETURN p_cover.fee%TYPE;
  /*
    ������ �.
  
    ��������� ������ �������� �� �� ��������� ��
    @param par_pol_header_id - �� ��������� ��
    @return ������ ��������
  */
  FUNCTION get_policy_fund_id_by_header
  (
    par_pol_header_id  p_pol_header.policy_header_id%TYPE
   ,par_raise_on_error BOOLEAN DEFAULT TRUE
  ) RETURN fund.fund_id%TYPE;

  /*
    ������ �.
  
    ��������� ������ ������ �������� �� �� ��������� ��
    @param par_pol_header_id - �� ��������� ��
    @return ������ ������ ��������
  */
  FUNCTION get_pol_fund_pay_id_by_header
  (
    par_pol_header_id  p_pol_header.policy_header_id%TYPE
   ,par_raise_on_error BOOLEAN DEFAULT TRUE
  ) RETURN fund.fund_id%TYPE;

  /**
  * �������� ����� ������ �� �������� � �����
  * @author Patsan O.
  * @param p_prod_id �� ��������
  * @param p_ser ����� ������
  * @return ����� ������
  */
  FUNCTION get_policy_nr
  (
    p_prod_id IN NUMBER
   ,p_ser     IN VARCHAR2 DEFAULT NULL
    --, p_dept_id    IN NUMBER DEFAULT NULL
  ) RETURN VARCHAR2;

  /**
  * �������� ����� ������ (������� ���������� ���������� ��������� ������ �� �������)
  * @param p_policy_id �� ������
  * @return ����� ������
  */
  FUNCTION get_policy_number(p_policy_id IN NUMBER) RETURN VARCHAR2;

  /**
  * �������� ����� ������ (������� ���������� ���������� ��������� ������ �� �������)
  * @param p_policy_id �� ������
  * @return ����� ������
  */
  FUNCTION get_policy_serial(p_policy_id IN NUMBER) RETURN VARCHAR2;

  /**
  * �������� ������
  * @author Patsan O.
  * @param p_pol_id �� ������ ���. ����������
  * @param p_product_id �� ��������
  * @param p_sales_channel_id �� ������ ������
  * @param p_company_tree_id �� ������
  * @param p_fund_id �� ������ ���������������
  * @param p_fund_pay_id �� ������ �������
  * @param p_confirm_condition_id �� ������� ���������� � ����
  * @param p_pol_ser ����� ������
  * @param p_pol_num ����� ������
  * @param p_notice_date ���� ���������
  * @param p_sign_date ���� ����������
  * @param p_confirm_date ���� ���������� � ����
  * @param p_start_date ���� ������ ��������
  * @param p_end_date ���� ��������� ��������
  * @param p_first_pay_date ���� ������� �������
  * @param p_payment_term_id �� ������������� ��������
  * @param p_period_id �� �����
  * @param p_agent_id �� ������
  * @param p_curator_id �� ��������
  * @param p_issuer_id �� ������������
  * @param p_osago_sign_ser  ����� ��������� �����
  * @param p_osago_sign_num  ����� ��������� �����
  * @param p_prev_event_count ���-�� ��������� ������� �� ����������� ������
  * @param p_fee_payment_term ������������� ������ �������
  * @param p_beneficiary_id   �� �������������������
  * @param p_fact_j           ������ �� ��������
  * @param p_ag_contract_id_1 �� ��������� � �������
  * @param p_ag_contract_id_2 �� ��������� � �������
  * @param p_admin_cost       ����� ���������������� ��������
  * @param p_is_park           ������� ����������� ����� ��
  * @param p_is_group_flag    ������� ���������� ��������
  * @param p_notice_num       ����� ���������
  * @param p_waiting_period_id   �� �������������� �������
  * @param p_sales_action_id     �� ����� ������
  * @param p_region_id           �� �������
  * @param p_office_manager_id  �� ���� ���������
  * @param p_region_manager_id  �� ������������� ���������
  * @param p_discount_f_id      �� ������ �� ��������
  * @param p_description         �������� ������ �������� �����������
  * @param p_paymentoff_term_id  ������������� �������
  * @param p_ph_description in  �������� ��������
  * @param p_payment_start_date ���� ������� �������
  * @param p_privilege_period   �� ��������� �������
  * @return �� ������ ��������� ������
  */
  FUNCTION policy_insert
  (
    p_pol_id               IN NUMBER
   ,p_product_id           IN NUMBER
   ,p_sales_channel_id     IN NUMBER
   ,p_company_tree_id      IN NUMBER
   ,p_fund_id              IN NUMBER
   ,p_fund_pay_id          IN NUMBER
   ,p_confirm_condition_id IN NUMBER
   ,p_pol_ser              IN VARCHAR2
   ,p_pol_num              IN VARCHAR2
   ,p_notice_date          IN DATE
   ,p_sign_date            IN DATE
   ,p_confirm_date         IN DATE
   ,p_start_date           IN DATE
   ,p_end_date             IN DATE
   ,p_first_pay_date       IN DATE
   ,p_payment_term_id      IN NUMBER
   ,p_period_id            IN NUMBER
   ,p_agent_id_1           IN NUMBER
   ,p_agent_id_2           IN NUMBER
   ,p_curator_id           IN NUMBER
   ,p_issuer_id            IN NUMBER
   ,p_osago_sign_ser       IN VARCHAR2
   ,p_osago_sign_num       IN VARCHAR2
   ,p_prev_event_count     IN NUMBER
   ,p_fee_payment_term     IN NUMBER
   ,p_beneficiary_id       IN NUMBER
   ,p_fact_j               IN NUMBER
   ,p_ag_contract_id_1     IN NUMBER
   ,p_ag_contract_id_2     IN NUMBER
   ,p_admin_cost           IN NUMBER
   ,p_is_park              IN NUMBER DEFAULT 0
   ,p_is_group_flag        IN NUMBER DEFAULT NULL
   ,p_notice_num           IN VARCHAR2 DEFAULT NULL
   ,p_waiting_period_id    IN NUMBER DEFAULT NULL
   ,p_sales_action_id      IN NUMBER DEFAULT NULL
   ,p_region_id            IN NUMBER DEFAULT NULL
   ,p_office_manager_id    IN NUMBER DEFAULT NULL
   ,p_region_manager_id    IN NUMBER DEFAULT NULL
   ,p_discount_f_id        IN NUMBER DEFAULT NULL
   ,p_description          IN VARCHAR2 DEFAULT NULL
   ,p_paymentoff_term_id   IN NUMBER DEFAULT NULL
   ,p_ph_description       IN VARCHAR2 DEFAULT NULL
   ,p_payment_start_date   IN DATE DEFAULT NULL
   ,p_privilege_period     IN NUMBER DEFAULT NULL
   ,p_issuer_agent_id      IN NUMBER DEFAULT NULL
   ,p_mailing              IN NUMBER DEFAULT 0
   ,p_product_conds_id     IN NUMBER DEFAULT NULL
   ,p_base_sum             IN NUMBER DEFAULT NULL
   ,p_is_credit            IN NUMBER DEFAULT NULL
  ) RETURN NUMBER;

  /**
  * ���������, ����������� �������� ����������� ������ �������� �����������
  * (��������, �������������� ������� ���������).
  * ������������ ��� �������� ��� ����� �������.
  * @author Denis Ivanov
  * @param par_policy_id �� ������ ������
  * @throw ���������� ��������� �� ������ � ���������� ��������.
  */
  PROCEDURE check_new_policy(par_policy_id IN NUMBER);

  /**
  * ���������� ������ ������ ��� �������� ��� �������� �������� �����������
  * @author Denis Ivanov
  * @param par_policy_id �� ������ ������
  */
  PROCEDURE set_self_as_active_version(par_policy_id IN NUMBER);

  /**
  * �������� ����� ������ ������ �� ����������
  * @author Patsan O.
  * @param par_policy_id �� ������ ������, �� ������� ���������� �����
  * @param par_ver_num ����� ����� ������
  * @param par_version_status C����� ����� ������
  */
  FUNCTION new_policy_version
  (
    par_policy_id             IN NUMBER
   ,par_ver_num               IN NUMBER DEFAULT NULL
   ,par_version_status        IN VARCHAR2 DEFAULT 'PROJECT'
   ,par_change_id             NUMBER DEFAULT NULL
   ,par_start_date            IN DATE DEFAULT NULL
   ,par_end_date              IN DATE DEFAULT NULL
   ,par_confirm_date_addendum IN DATE DEFAULT NULL
   ,par_notice_date_addendum  IN DATE DEFAULT NULL
   ,par_policy_change_type_id IN NUMBER DEFAULT NULL
   ,par_note                  IN VARCHAR2 DEFAULT NULL
  ) RETURN NUMBER;

  /**
  * ��������� ��������� ����������� ������ ������
  * @author Patsan O.
  * @param p_pol_header_id �� ��������� ������
  * @return �� ��������� ���������� ������ ������
  */
  FUNCTION get_curr_policy(p_pol_header_id IN NUMBER) RETURN NUMBER;

  /**
  * ���������� �������� �������� ��� ��������
  * @author Patsan O.
  * @param par_cover_id
  * @param �� ��������
  * @return �������� ��������
  */
  FUNCTION get_deduct_name(par_cover_id IN NUMBER) RETURN VARCHAR2;

  /*
    ����� �.
    �������� �������� "������ ����" �� ��������
    ����������� ��� ��������� ��������� ���������� ���������
    �� 10.06.2014: �������� - ������� ������ ����� ����������� ��������� � ��������� "������ ����"
  */
  FUNCTION is_handchange_policy(par_policy_id p_policy.policy_id%TYPE) RETURN BOOLEAN;

  /**
  * �������� ������ � ��������� ����� �� ������. <p>
  * ��������� ������ � ��������� ����� �� ���� �������� �����������,
  * <br> ������ �� �� ��������.
  * @author  Denis Ivanov
  * @param p_p_policy_id �� ������
  * @param p_premium ��������� ������� ������
  * @param p_ins_amount ��������� ������� ��������� �����
  */
  PROCEDURE update_policy_sum
  (
    p_p_policy_id IN NUMBER
   ,p_premium     OUT NUMBER
   ,p_ins_amount  OUT NUMBER
  );

  /**
  * �������� ������ � ��������� ����� �� ������. <p>
  * ��������� ������ � ��������� ����� �� ���� �������� �����������,
  * <br> ������ �� �� ��������.
  * @author  Denis Ivanov
  * @param p_p_policy_id �� ������
  */
  PROCEDURE update_policy_sum(p_p_policy_id IN NUMBER);

  /**
  * �������������� ������
  * @author Patsan O.
  * @param p_pol_id �� ������ ���. ����������
  * @param p_product_id �� ��������
  * @param p_sales_channel_id �� ������ ������
  * @param p_company_tree_id �� ������
  * @param p_fund_id �� ������ ���������������
  * @param p_fund_pay_id �� ������ �������
  * @param p_confirm_condition_id �� ������� ���������� � ����
  * @param p_pol_ser ����� ������
  * @param p_pol_num ����� ������
  * @param p_notice_date ���� ���������
  * @param p_sign_date ���� ����������
  * @param p_confirm_date ���� ���������� � ����
  * @param p_header_start_date ���� ������ �������� ��������
  * @param p_header_start_date ���� ������ �������� ���. ����������
  * @param p_end_date ���� ��������� ��������
  * @param p_first_pay_date ���� ������� �������
  * @param p_payment_term_id �� ������������� ��������
  * @param p_period_id �� �����
  * @param p_agent_id �� ������
  * @param p_curator_id �� ��������
  * @param p_issuer_id �� ������������
  * @param p_osago_sign_ser  ����� ��������� �����
  * @param p_osago_sign_num  ����� ��������� �����
  * @param p_prev_event_count ���-�� ��������� ������� �� ����������� ������
  * @param p_fee_payment_term ������������� ������ �������
  * @param p_beneficiary_id   �� �������������������
  * @param p_fact_j           ������ �� ��������
  * @param p_ag_contract_id_1 �� ��������� � �������
  * @param p_ag_contract_id_2 �� ��������� � �������
  * @param p_admin_cost       ����� ���������������� ��������
  * @param p_is_park           ������� ����������� ����� ��
  * @param p_is_group_flag    ������� ���������� ��������
  * @param p_notice_num       ����� ���������
  * @param p_waiting_period_id   �� �������������� �������
  * @param p_sales_action_id     �� ����� ������
  * @param p_region_id           �� �������
  * @param p_office_manager_id  �� ���� ���������
  * @param p_region_manager_id  �� ������������� ���������
  * @param p_discount_f_id      �� ������ �� ��������
  * @param p_description         �������� ������ �������� �����������
  * @param p_paymentoff_term_id  ������������� �������
  * @param p_ph_description in  �������� ��������
  * @param p_payment_start_date ���� ������� �������
  * @param p_privilege_period   �� ��������� �������
  */
  PROCEDURE policy_update
  (
    p_pol_id               IN NUMBER
   ,p_product_id           IN NUMBER
   ,p_sales_channel_id     IN NUMBER
   ,p_company_tree_id      IN NUMBER
   ,p_fund_id              IN NUMBER
   ,p_fund_pay_id          IN NUMBER
   ,p_confirm_condition_id IN NUMBER
   ,p_pol_ser              IN VARCHAR2
   ,p_pol_num              IN VARCHAR2
   ,p_notice_date          IN DATE
   ,p_sign_date            IN DATE
   ,p_confirm_date         IN DATE
   ,p_header_start_date    IN DATE
   ,p_policy_start_date    IN DATE
   ,p_end_date             IN DATE
   ,p_first_pay_date       IN DATE
   ,p_payment_term_id      IN NUMBER
   ,p_period_id            IN NUMBER
   ,p_agent_id_1           IN NUMBER
   ,p_agent_id_2           IN NUMBER
   ,p_curator_id           IN NUMBER
   ,p_issuer_id            IN NUMBER
   ,p_osago_sign_ser       IN VARCHAR2
   ,p_osago_sign_num       IN VARCHAR2
   ,p_prev_event_count     IN NUMBER
   ,p_fee_payment_term     IN NUMBER
   ,p_beneficiary_id       IN NUMBER
   ,p_fact_j               IN NUMBER
   ,p_ag_contract_id_1     IN NUMBER
   ,p_ag_contract_id_2     IN NUMBER
   ,p_admin_cost           IN NUMBER
   ,p_is_park              IN NUMBER DEFAULT 0
   ,p_is_group_flag        IN NUMBER DEFAULT NULL
   ,p_notice_num           IN VARCHAR2 DEFAULT NULL
   ,p_waiting_period_id    IN NUMBER DEFAULT NULL
   ,p_sales_action_id      IN NUMBER DEFAULT NULL
   ,p_region_id            IN NUMBER DEFAULT NULL
   ,p_office_manager_id    IN NUMBER DEFAULT NULL
   ,p_region_manager_id    IN NUMBER DEFAULT NULL
   ,p_discount_f_id        IN NUMBER DEFAULT NULL
   ,p_description          IN VARCHAR2 DEFAULT NULL
   ,p_paymentoff_term_id   IN NUMBER DEFAULT NULL
   ,p_ph_description       IN VARCHAR2 DEFAULT NULL
   ,p_payment_start_date   IN DATE DEFAULT NULL
   ,p_privilege_period     IN NUMBER DEFAULT NULL
   ,p_issuer_agent_id      IN NUMBER DEFAULT NULL
   ,p_mailing              IN NUMBER DEFAULT 0
   ,p_product_conds_id     IN NUMBER DEFAULT NULL
   ,p_base_sum             IN NUMBER DEFAULT NULL
   ,p_is_credit            IN NUMBER DEFAULT NULL
  );

  /**
  * �������� ������������ ��� � ��������� ������� ��� �� ������
  * @author Patsan O.
  * @param p_pol_id �� ������
  */
  PROCEDURE update_policy_dates
  (
    p_pol_id         IN NUMBER
   ,p_is_autoprolong IN NUMBER DEFAULT -1
  );

  /**
  * ��������� ���� ������ � ���� ��������� ������
  * @author Patsan O.
  * @param p_pol_id �� ������
  * @param p_start ���� ������
  * @param p_end ���� ���������
  */
  PROCEDURE update_policy_dates
  (
    p_pol_id         IN NUMBER
   ,p_start          IN DATE
   ,p_end            IN DATE
   ,p_is_autoprolong IN NUMBER DEFAULT -1
  );

  /**
  * ��������� ������� ��������� ������
  * @author Patsan O.
  * @param p_pol_header_id �� ��������� ������
  */
  PROCEDURE set_pol_header_status(p_pol_header_id IN NUMBER);

  /**
  * ������ ���� �����������
  * @author Patsan O.
  * @param p_pol_id �� ������
  * @param p_decl_date ���� �����������
  * @param p_is_charge ���� ����� �������� �� ������� ����
  * @param p_is_comission ���� ����� ��������
  * @param po_ins_sum ��������� �����
  * @param po_prem_sum ������
  * @param po_pay_sum ��������
  * @param po_payoff_sum ���������
  * @param po_charge_sum ������� �� ������� ����
  * @param po_com_sum �������� ������
  * @param po_zsp_sum ���
  * @param po_decline_sum ����� ��������
  */
  PROCEDURE calc_decline
  (
    p_pol_id       IN NUMBER
   ,p_decl_date    IN DATE
   ,p_is_charge    IN NUMBER
   ,p_is_comission IN NUMBER
   ,po_ins_sum     OUT NUMBER
   ,po_prem_sum    OUT NUMBER
   ,po_pay_sum     OUT NUMBER
   ,po_payoff_sum  OUT NUMBER
   ,po_charge_sum  OUT NUMBER
   ,po_com_sum     OUT NUMBER
   ,po_zsp_sum     OUT NUMBER
   ,po_decline_sum OUT NUMBER
  );

  /**
  * ������������ ������������ �� �������
  * ���������� ��� ����� ������� �� BREAK
  * @param par_policy_id �� ������
  * @author �. �������.
  */
  PROCEDURE return_payment(par_policy_id IN NUMBER);

  /**
  * ��������� ���� ��������� � ���� �����������.
  * ���������� ��� ����� ������� �� BREAK
  * @param par_policy_id �� ������
  * @author �. �������.
  */
  PROCEDURE update_decline_dates(par_policy_id IN NUMBER);

  /**
  * ������ ����������� ������. �������� ����������� ����������� � ��������
  * ����� ������ �� �������� ��������� � �����������
  * @param par_policy_id �� ������
  */
  PROCEDURE start_decline(par_policy_id IN NUMBER);

  /**
  * ������� ������ (�������� ���������) �������� �� ������ ������.
  * ���������� �������� �� �������� ����� ��� �����������.
  * @author Denis Ivanov
  * @param p_policy_id �� ������
  * @param p_cur ������ ������� ������� p_cover
  */
  PROCEDURE open_active_cover_cursor
  (
    p_policy_id IN NUMBER
   ,p_cur       OUT t_cover_cursor
  );

  /**
  * �������� �� �������� �� ������ � ����
  * @author Kushenko Sergey
  * @param p_policy_id �� ������
  * @param p_role_brief BRIEF ���� ��������
  * @return �� ��������
  */
  FUNCTION get_policy_contact
  (
    p_policy_id  NUMBER
   ,p_role_brief VARCHAR2
  ) RETURN NUMBER;
  /**
  * �������� �� ������������ �� ������
  * @author Denis Ivanov
  * @param p_policy_id �� ������
  * @return �� ������������
  */
  FUNCTION get_policy_holder_id(p_policy_id NUMBER) RETURN NUMBER;

  /**
  * �������� �� ������ �� ������
  * @author ������� �.
  * @param p_policy_id �� ������
  * @return �� ������(contact_id)
  */
  FUNCTION get_policy_agent_id(p_policy_id NUMBER) RETURN NUMBER;

  /**
  * �������� ����������� ������ �� ��������
  * @author Denis Ivanov
  * @param p_p_pol_header_id �� ��������� �������� �����������
  */
  FUNCTION get_active_policy(p_p_pol_header_id NUMBER) RETURN NUMBER;

  /**
  * �������� ����������� ������ �� �������� �� ����
  * @author ����� �.
  */
  FUNCTION get_active_policy_by_date
  (
    par_pol_header_id p_pol_header.policy_header_id%TYPE
   ,par_date          DATE
  ) RETURN p_policy.policy_id%TYPE;

  /*
    @author ������ �.
  
    ��������� ID ��������� �� �� ���
    @param par_ids - ��� ��������
    @param par_raise_on_not_found - TRUE: ���������� ������; FALSE: ���
  
    @return �� ��������� �������� �����������
  */
  FUNCTION get_policy_header_by_ids
  (
    par_ids            p_pol_header.ids%TYPE
   ,par_raise_on_error BOOLEAN DEFAULT TRUE
  ) RETURN p_pol_header.policy_header_id%TYPE;

  /*
    @author ������ �.
  
    ��������� ID ��������� �� �� ������/����� �� (�� ��������� ������)
    @param par_pol_num - ����� ��������
    @param par_pol_ser - ����� ��������
    @param par_raise_on_not_found - TRUE: ���������� ������; FALSE: ���
  
    @return �� ��������� �������� �����������
  */
  FUNCTION get_policy_header_by_num
  (
    par_pol_num        p_policy.pol_num%TYPE
   ,par_pol_ser        p_policy.pol_ser%TYPE DEFAULT NULL
   ,par_raise_on_error BOOLEAN DEFAULT TRUE
  ) RETURN p_pol_header.policy_header_id%TYPE;

  /**
  * �������� �� ��������� �������� �����������
  * @author Kaplya P.
  * @param par_policy_id - �� ������ �������� �����������
  */
  FUNCTION get_policy_header_id(par_policy_id p_policy.policy_id%TYPE)
    RETURN p_pol_header.policy_header_id%TYPE;

  /**
  * �������� �������� � ������������� ��� ��������
  * @author Patsan O.
  * @param par_product_id �� ��������
  * @param par_department_id �� �������������
  * @param par_contact_id �� ��������
  */
  PROCEDURE get_product_dept_person
  (
    par_product_id    IN NUMBER
   ,par_department_id IN OUT NUMBER
   ,par_contact_id    IN OUT NUMBER
  );

  /**
  * �������������� �������, ��������� ������ p_p_policy_id
  * @author Denis Ivanov
  * @param p_policy_id �� ������, �� ��������� ������� ����� ��������������
  * @return �� p_pol_header ������ ��������
  */
  FUNCTION prolongation(p_policy_id IN NUMBER) RETURN NUMBER;

  /**
  * ���������� �������, ��������� ������ p_p_policy_id
  * @author Denis Ivanov
  * @param p_policy_id �� ������, �� ��������� ������� ����� ��������������
  * @return �� p_pol_header ������ ��������
  */
  FUNCTION copy(p_policy_id IN NUMBER) RETURN NUMBER;

  /**
  * ������� �� ��� ������ ��� ��������� ���������
  * @author Budkova A, ������ �.
  * @param p_comiss_type ����� �������� ����������: 1 - type_rate_value_id, 2 - val_com, 3 - type_defin_rate_id, 4 - t_prod_coef_type_id
  * @param p_ag_contract_header_id �� ���������� ��������
  * @param p_prod_line_id �� ��������� ���������
  * @param p_cur_date ����, �� ������� ������ �������� ��������� �������
  * @return ��� �������� ������ ��
  */
  FUNCTION find_commission
  (
    p_comiss_kind           IN NUMBER
   ,p_ag_contract_header_id IN NUMBER
   ,p_prod_line_id          IN NUMBER
   ,p_cur_date              IN DATE DEFAULT SYSDATE
  ) RETURN NUMBER;

  /**
  * ������� �������� ���������� �� ��� ������ ��� ��������� ���������
  * @author Budkova A
  * @param p_ag_contract_header_id �� ���������� ��������
  * @param p_prod_line_id �� ��������� ���������
  * @param p_cur_date - ���� �� ������� ������� ��������� ��
  * @return �������� ������ ��
  */
  FUNCTION find_commiss_v
  (
    p_ag_contract_header_id IN NUMBER
   ,p_prod_line_id          IN NUMBER
   ,p_cur_date              IN DATE DEFAULT SYSDATE
  ) RETURN NUMBER;

  /**
  * ������� ��� �������� ���������� �� ��� ������ ��� ��������� ���������
  * @author Budkova A
  * @param p_ag_contract_header_id �� ���������� ��������
  * @param p_prod_line_id �� ��������� ���������
  * @param cur_date ����, �� ������� ������ �������� ��������� �������
  * @return ��� �������� ������ ��
  */
  FUNCTION find_commiss_t
  (
    p_ag_contract_header_id IN NUMBER
   ,p_prod_line_id          IN NUMBER
   ,p_cur_date              IN DATE DEFAULT SYSDATE
  ) RETURN NUMBER;

  /**
  *  �������� ����� ������ �� ��������
  *  @author �������
  *  @param p_pol_header_id �� ��������� �������� �����������
  *  @return ����� ������ �� ��������
  */
  FUNCTION payment_loss_by_prev(p_pol_header_id IN NUMBER) RETURN NUMBER;

  /**
  *  �������� ����������, �� �� ����������� ����� �� ��������
  *  @author �������
  *  @param p_pol_header_id �� ��������� �������� �����������
  *  @return ����������, �� �� ����������� ����� �� ��������
  */
  FUNCTION declared_loss_by_prev(p_pol_header_id IN NUMBER) RETURN NUMBER;

  /**
  *  �������� ������. ������������ ������, ���� ����� ��� ������ ��� ������, ����, ��� ������ �����������
  *  @author �������
  *  @param p_pol_header_id �� ��������� �������� �����������
  */
  PROCEDURE drop_policy(p_policy_header_id IN NUMBER);

  /**
  * ������������� ������ ������ ������, ������ ��������
  * @param doc_id �� ������ ������
  * @param status_id �� �������
  * @param status_date ���� ������ �������� �������
  * @author ������� �.
  */
  PROCEDURE set_policy_status
  (
    doc_id      NUMBER
   ,status_id   NUMBER
   ,status_date IN DATE DEFAULT SYSDATE
  );

  /**
  * ��������� �������� �� ������ ������ ���.�����������
  * @param p_policy_id �� ������ ������
  * @author ������� �.
  * @return 1, ���� ������ ������ ������, �������� ���. �����������.
  */
  FUNCTION is_addendum(p_policy_id NUMBER) RETURN NUMBER;

  /**
  * ��������� �������� �� ������ ������ ���������(������������ version_number)
  * @param p_policy_id �� ������ ������
  * @author ������� �.
  * @return 1, ���� ������ ������ ������, �������� ���������
  */
  FUNCTION is_last_version(p_policy_id NUMBER) RETURN NUMBER;

  /**
  * ��������� �������� �� ������ �������������� ������� �����������
  * @param p_status_brief ������� ������������� �������
  * @author ������� �.
  * @return 1, ���� ������ �������� �������������� ������� �����������
  */
  FUNCTION is_policy_change_status(p_status_brief VARCHAR2) RETURN NUMBER;

  /**
  * ��������� �������� �� ��������� ��������� �� ������ � ������ �������
  * @param p_status_brief ������� ������������� �������
  * @author ������� �.
  * @return 1, ���� �������� ��������� ��������� �� ������ � ������ �������
  */
  FUNCTION is_policy_claim_status(p_status_brief VARCHAR2) RETURN NUMBER;

  /**
  * ��������� �������� �� ����� � ���� ������� ��������
  * @param p_status_brief ������� ������������� �������
  * @author ������� �.
  * @return 1, ���� �������� ����� � ���� ������� ��������
  */
  FUNCTION is_active_status
  (
    p_status_brief VARCHAR2
   ,p_doc_templ_id NUMBER DEFAULT 2
  ) RETURN NUMBER;

  /**
  * ������������� ������ ������ ������
  * @author ������� �.
  * @param p_policy_id - Id ������
  * @param p_status_brief - ����� ������
  * @param p_rollback      - ������ ����� ����� �������� ��������� �������
  */
  PROCEDURE set_status
  (
    p_policy_id    NUMBER
   ,p_status_brief VARCHAR2
   ,p_rollback     NUMBER DEFAULT 0
  );

  /**
  * ������� ���. ����������, ���� ������� Id ���. ����������
  * @author ������� �.
  * @param par_policy_id - Id ������
  */
  PROCEDURE cancel_policy(par_policy_id NUMBER);

  /**
  * �������� ��� �� ������. ���������� ��� ��������� ������� �����������
  * @author ������� �.
  * @param par_policy_id  - Id ������
  * ���������� �������������� ���������, ��������������� 2-�� � 3-�� ���������� �
  * ��������� check_all_bso_on_policy:
  *    par_is_set    in number default 0,
  * par_is_clear  in number default 0
  * ���. ��������� ���������� ����� utils.put/get
  */
  PROCEDURE check_bso(par_policy_id NUMBER);

  /**
  * ����������� �� ��������� ������
  * @author ������� �.
  * @param par_policy_id - Id ������
  */
  PROCEDURE notify_pol_header_updated(par_policy_id NUMBER);

  /**
  * ������� ����� �� ���������. ���������� ��� ����� ������� �� �����������
  * @author ������� �.
  * @param p_policy_id - Id ������
  */
  PROCEDURE buy_stock(par_policy_id NUMBER);

  /**
  *  ���������� �������� ���������� ��������, � ����������� �� ���� � �����
  *  ������ ���������
  * @author ������� �.
  * @param p_policy_id - Id ������
  */
  PROCEDURE set_status_change_context(par_policy_id NUMBER);

  /**
  * ��������� ����������� ������ ������ ��������
  * @author Denis Ivanov
  * @param par_policy_id �� ������
  * @throw ������ �������� � ���������� ������, ���� ����������
  */
  PROCEDURE check_enable_pol_cancelation(par_policy_id NUMBER);

  /**
  * ������������ �������� �� ���������� ������ ������
  * @author �. �������
  * @param par_policy_id �� ������
  * @throw ������ �������� � ���������� ������, ���� ����������
  */
  PROCEDURE storno_transactions(par_policy_id NUMBER);
  /**
  * ������������ �������� �� ����� ���������� ������ ������
  * @param par_policy_id �� ������
  */
  PROCEDURE storno_trans_cancel(par_policy_id NUMBER);

  /**
  * ���������������� ��������� ����������� ����� ��������� ������� ��������� � �����������
  * ��� ���������� ������� �����������
  * @param par_policy_id �� ������
  * @author �. �������
  */
  PROCEDURE init_decline_parameters(par_policy_id NUMBER);

  /**
  * ������������� ����� � ����� ������ ��� ����� ������� �� ��������
  * @param par_policy_id �� ������
  * @author �. �������
  */
  PROCEDURE set_policy_nr(par_policy_id NUMBER);

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 12.02.2010 11:47:50
  -- Purpose : ���������� ������ ������� �� ��� ���������������
  -- ��� ������������ ����� ������ �� (������ asset_in_policy)
  FUNCTION policy_by_assured(par_assured_name VARCHAR2) RETURN t_number_type;

  /**
  * ��������� ���� �� ������ ����������� � ������
  * @param p_pol_id �� ������
  * @param p_as_name ������������ ������� ����������� ��� ��� ����� (�����)
  * @author �. �������
  * @return ���������� 1, ���� ������ ����������� ���� � ������
  */
  FUNCTION asset_in_policy
  (
    p_pol_id  NUMBER
   ,p_as_name VARCHAR2
  ) RETURN NUMBER;

  /**
  * ��������� ���� �� ����� ���� � ������
  * @author �. �������
  * @param p_pol_header_id �� ������
  * @param p_agent_name ������������ ������ ��� ��� ����� (�����)
  * @return ���������� 1, ���� ����� ���� � ������
  */
  FUNCTION agent_in_policy
  (
    p_pol_header_id NUMBER
   ,p_agent_name    VARCHAR2
  ) RETURN NUMBER;

  /**
  * ���������� ������ ��-��������� ��� ������
  * @author �. �������
  * @param p_pol_id �� ������
  */
  FUNCTION get_policy_region(p_pol_id NUMBER) RETURN NUMBER;

  /*
    ��������� ID ������� �� ��������� ��
  */
  FUNCTION get_region_by_pol_header(par_pol_header_id p_pol_header.policy_header_id%TYPE)
    RETURN t_kladr.t_kladr_id%TYPE;

  /**
  * ������������� � ���������� ����� ����� ������ ������. ����� �� ������������� � ������ ����������� ���������
  * @author �. �������
  * @par_policy_id �� ������
  * @return ���������� ����� ����� ������ ������
  */
  FUNCTION set_pol_version_order_num(par_policy_id IN NUMBER) RETURN NUMBER;

  /*
    ������ �.
  
    ���������� ������ �������� �� ��
    @param par_policy_header_id - �� ������ ��
    @param par_raise_on_error - ���������� ������
    @return ������ p_pol_header
  */
  FUNCTION get_header_record
  (
    par_policy_header_id p_policy.policy_id%TYPE
   ,par_raise_on_error   BOOLEAN DEFAULT TRUE
  ) RETURN p_pol_header%ROWTYPE;
  /*
    ������ �.
  
    ���������� ������ ������ �� ��
    @param par_policy_id - �� ������ ��
    @param par_raise_on_error - ���������� ������
    @return ������ p_policy
  */
  FUNCTION get_version_record
  (
    par_policy_id      p_policy.policy_id%TYPE
   ,par_raise_on_error BOOLEAN DEFAULT TRUE
  ) RETURN p_policy%ROWTYPE;

  /**
  * �������� ��������� ������ �������� �����������
  * @author �. �������
  * @p_pol_header_id �� ��������� ������
  * @return ���������� �� ��������� ������ ������
  */
  FUNCTION get_last_version(p_pol_header_id NUMBER) RETURN NUMBER;

  /**
  * �������� ������ ��������� ������ �������� �����������
  * @author �. �������
  * @param p_pol_header_id �� ��������� ������
  * @return ���������� ������� ������������� ��������� ������ ������
  */
  FUNCTION get_last_version_status(p_pol_header_id NUMBER) RETURN VARCHAR2;

  /**
  * ����� �.
  * ��������� ������ ������������ ������
  */
  FUNCTION get_first_uncanceled_version(par_policy_header_id p_pol_header.policy_header_id%TYPE)
    RETURN p_policy.policy_id%TYPE;
  /**
  * �������� ������� ������ ���������� ������ �������� �����������
  * @author Kushenko S.
  * @param p_policy_id �� ������ ������
  * @return ���������� BRIEF ������� ���������� ������ ������
  */
  FUNCTION get_prev_ver_status_brief(p_policy_id NUMBER) RETURN VARCHAR2;
  /**
  * �������� BRIEF ����������� ������� ������ �������� �����������
  * @author Kushenko S.
  * @param p_policy_id �� ������ ������
  * @return ���������� BRIEF ����������� ������� ������ ������
  */
  FUNCTION get_prev_status_brief(p_policy_id NUMBER) RETURN VARCHAR2;
  /**
  * �������� ���� ��������� �������������� �������
  * @author �. �������
  * @param p_policy_id �� ������
  * @param p_waiting_period_id �� �������������� �������
  * @param p_start_date ���� ������ �������� ������
  * @return ���������� ���� ��������� �������������� �������
  */
  FUNCTION get_waiting_per_end_date
  (
    p_policy_id         NUMBER
   ,p_waiting_period_id NUMBER DEFAULT -1
   ,p_start_date        DATE DEFAULT NULL
  ) RETURN DATE;

  /**
  * ��������� ��������� �� ����� � ������������� �������
  * @author �. �������
  * @param p_pol_id �� ������
  * @param p_waiting_period_id �� �������������� �������
  * @param p_start_date ���� ������ �������� ������
  * @return ���������� 1, ���� ������� ��������� � ������������� �������
  */
  FUNCTION is_in_waiting_period
  (
    p_pol_id            NUMBER
   ,p_waiting_period_id NUMBER DEFAULT -1
   ,p_start_date        DATE DEFAULT NULL
  ) RETURN NUMBER;

  /**
  * �������� ���� ��������� ��������� �������
  * @author �. �������
  * @param p_policy_id �� ������
  * @param p_privilege_period_id �� ��������� �������
  * @param p_start_date ���� ������ �������� ������
  * @return ���������� ���� ��������� ��������� �������
  */
  FUNCTION get_privilege_per_end_date
  (
    p_policy_id           NUMBER
   ,p_privilege_period_id NUMBER DEFAULT -1
   ,p_start_date          DATE DEFAULT NULL
  ) RETURN DATE;
  /**
  * ��������� ��������� �� ����� � �������� �������
  * @author �. �������
  * @param p_pol_id �� ������
  * @param p_waiting_period_id �� ��������� �������
  * @param p_start_date ���� ������ �������� ������
  * @return ���������� 1, ���� ������� ��������� � �������� �������
  */
  FUNCTION is_in_privilege_period
  (
    p_pol_id              NUMBER
   ,p_privilege_period_id NUMBER DEFAULT -1
   ,p_start_date          DATE DEFAULT NULL
  ) RETURN NUMBER;

  /**
  * ��������� ������ �� ����������� ����� �������� �������� �����������
  * @author Patsan O.
  * @param p_payment_id �� �������
  */
  PROCEDURE check_policy_payment_date(p_payment_id IN NUMBER);

  /**
  * ���������� ������������ ������� �� ��������
  * @author �. �������
  * @param p_pol_header_id �� ��������
  * @return ������������ ������� �� ��������
  */

  FUNCTION get_pol_agency_name(p_pol_header_id NUMBER) RETURN VARCHAR2;

  /**
  * ���������� ��������� ������ �� ��������� ���������������� ��������
  * @author �. �������
  * @param p_pol_id �� ������ ��������
  * @return ����� ���������������� ��������
  */

  FUNCTION get_admin_cost_sum(p_pol_id NUMBER) RETURN NUMBER;
  /*���������������� �������� (����� �� ������-�������)*/
  FUNCTION get_admin_cost_fee(p_pol_id NUMBER) RETURN NUMBER;

  PROCEDURE set_previous_as_active_version(par_policy_id IN NUMBER);

  FUNCTION get_main_pol_agent(p_pol_header_id IN NUMBER) RETURN NUMBER;

  /* ������� ������ ������ � p_policy, p_pol_header */
  PROCEDURE delete_policy(p_policy_header_id IN NUMBER);
  /*
  ����� �.
  ������� ��������� ��������, ��������� �������� ��������������.
  ������������ � ���������� � �2�
  */
  PROCEDURE delete_policy_now(par_policy_header_id IN NUMBER);

  PROCEDURE check_bso_exists(p_pol_id NUMBER);
  FUNCTION get_previous_version(p_pol_id NUMBER) RETURN NUMBER;

  FUNCTION get_end_date
  (
    p_period_id  NUMBER
   ,p_start_date DATE
  ) RETURN DATE;
  PROCEDURE correct_pol_dates
  (
    p_pol_id         NUMBER
   ,p_new_start_date DATE
  );

  /**
  * ������ ����� ������� �� ��������� ����������
  * @author Protsvetov E.
  * @param p_from_policy_id �� ������ ��������, �� ��������� �������� ������ �����
  * @param p_to_product_id �� �������� �������� ��������
  * @param p_to_policy_id �� ������ ��������
  */
  PROCEDURE create_policy_from_policy
  (
    p_from_policy_id IN NUMBER
   ,p_to_product_id  IN NUMBER
   ,p_to_policy_id   OUT NUMBER
  );

  FUNCTION find_pol_period
  (
    p_pol_id      NUMBER
   ,p_best_per_id NUMBER DEFAULT NULL
   ,p_start_date  DATE DEFAULT NULL
   ,p_end_date    DATE DEFAULT NULL
  ) RETURN NUMBER;

  /**
  * ��������� ��� ���������� Job`� �� �������� ���������������
  * �������� ����� ������ �������� � ������� ������
  * @author ���������� �.
  * @param p_pol_id �� ��������� ��������
  */
  PROCEDURE job_prolongation_p2
  (
    p_pol_id   NUMBER DEFAULT NULL
   ,flg_run_p3 NUMBER DEFAULT 1
  );

  /**
  * ��������� ��� ���������� Job`� �� �������� ���������������
  * ������� ������� �� ������� ������ � ������ �����
  * @author ���������� �.
  * @param p_pol_id �� ��������� ��������
  */
  PROCEDURE job_prolongation_p3(p_pol_id NUMBER DEFAULT NULL);

  /**
  * ��������� ��������� ������ �� �������� ���������������
  * �, ���� �� ��� ���� ������, ������� �������
  * �������� ��� �������� �� ������� ������ � �����
  * @author ���������� �.
  * @param p_pol_id �� ������ ������
  */
  PROCEDURE check_policy_have_damage(p_pol_id NUMBER);

  /**
  ��������� �������� ���. ��������� ��� �������� ����� ������ ��������.
  � ����������� �������� ����� ���� ������ ���.���������� ��������� �����:
  * �������������� �������� ���������
  * �������������� ����� ��������
  */
  PROCEDURE check_quit_pol_addendum_type(par_policy_id IN NUMBER);

  /**
  * ��������� ������������� ���� ������ �������� ��������
  * ��� ���������� ����� � ������ �������, ����
  * ������� �������� � ���� � ������� ������ (������ ��� ������� ������)
  * @author ������� �.
  * @param p_acc_id �� �����
  */

  PROCEDURE set_pol_start_date(p_acc_id NUMBER);

  /**
  * ��������� �������� �� ��������� �������������� ���������
  * @param as_assured_id -- ID ���������������
  * @author ����� ������
  * @return 1, ���� ��������� �������������� �������� ���������
  */
  FUNCTION is_assured_debitor(p_as_assured_id NUMBER) RETURN NUMBER;

  FUNCTION get_pol_form_type(p_pol_id NUMBER) RETURN VARCHAR2;

  -- ������ �.
  -- ����������� ���� ��������� ������������ ������ �� ��������, � ������������ � ����� ��������� �������� ������ ��������
  PROCEDURE update_policy_agent_end_date(par_policy_id NUMBER);
  /*
    ������ �.
  
    ��������� ���������� ������-�������
  */
  PROCEDURE round_fee_sums(par_document_id NUMBER);

  PROCEDURE set_last_ver_id(par_policy_id NUMBER);

  /* sergey.ilyushkin 25/07/2012
    ����������� � ��������� ������-������
    @param par_policy_id - �� ������ ��������, ��� ������� ����������� ��������� ������
  */
  PROCEDURE set_prev_ver_id(par_policy_id NUMBER);

  /* sergey.ilyushkin 30/07/2012
  ���������� �������� (�� � ������� �������) ������-������
  @param par_policy_id - �� ������ ��������
  @return - �� ������-������
  */
  FUNCTION get_active_prev_ver_id(par_policy_id NUMBER) RETURN NUMBER;

  /* sergey.ilyushkin 13/08/2012
    ���������� �� ��������� �������� ������ ��������
    (� ��������� ������ ��� ��������� ������ �� � ������� "�������")
    @param par_policy_id - �� ������ ��������
    @return - �� ��������� �������� ������ ��������
  */
  FUNCTION get_last_active_version(par_policy_id NUMBER) RETURN NUMBER;

  /*
    �������, ����������� DML �������� INSERT'� � ��������� � ������ ��������
  */
  FUNCTION create_policy_base
  (
    p_product_id              IN NUMBER
   ,p_sales_channel_id        IN NUMBER
   ,p_agency_id               IN NUMBER
   ,p_fund_id                 IN NUMBER
   ,p_fund_pay_id             IN NUMBER
   ,p_confirm_condition_id    IN NUMBER
   ,p_pol_ser                 IN VARCHAR2
   ,p_pol_num                 IN VARCHAR2
   ,p_notice_date             IN DATE
   ,p_sign_date               IN DATE
   ,p_confirm_date            IN DATE
   ,p_start_date              IN DATE
   ,p_end_date                IN DATE
   ,p_first_pay_date          IN DATE
   ,p_payment_term_id         IN NUMBER
   ,p_period_id               IN NUMBER
   ,p_issuer_id               IN NUMBER
   ,p_fee_payment_term        IN NUMBER
   ,p_fact_j                  IN NUMBER DEFAULT NULL
   ,p_admin_cost              IN NUMBER DEFAULT 0
   ,p_is_group_flag           IN NUMBER DEFAULT 0
   , -- ������ �. ������� null �� 0
    p_notice_num              IN VARCHAR2 DEFAULT NULL
   ,p_waiting_period_id       IN NUMBER DEFAULT NULL
   ,p_region_id               IN NUMBER DEFAULT NULL
   ,p_discount_f_id           IN NUMBER DEFAULT NULL
   ,p_description             IN VARCHAR2 DEFAULT NULL
   ,p_paymentoff_term_id      IN NUMBER DEFAULT NULL
   ,p_ph_description          IN VARCHAR2 DEFAULT NULL
   ,p_privilege_period        IN NUMBER DEFAULT NULL
   ,p_waiting_period_end_date IN DATE DEFAULT NULL
   , --����� �. ������ �� ������� ����� � � ������
    p_base_sum                IN NUMBER DEFAULT NULL
   ,p_is_credit               IN NUMBER DEFAULT NULL
  ) RETURN NUMBER;

  /*
    ����� �.
    ��������� �������������� �������� �������� �����������
  */
  PROCEDURE create_universal
  (
    par_product_brief       VARCHAR2
   ,par_ag_num              VARCHAR2
   ,par_start_date          DATE
   ,par_insuree_contact_id  NUMBER
   ,par_assured_array       pkg_asset.t_assured_array
   ,par_end_date            DATE DEFAULT NULL
   ,par_bso_number          NUMBER DEFAULT NULL
   ,par_bso_series_id       NUMBER DEFAULT NULL
   ,par_base_sum            NUMBER DEFAULT NULL
   ,par_is_credit           NUMBER DEFAULT 0
   ,par_ins_hobby_id        NUMBER DEFAULT NULL
   ,par_ins_work_group_id   NUMBER DEFAULT NULL
   ,par_ins_profession_id   NUMBER DEFAULT NULL
   ,par_pol_num             VARCHAR2 DEFAULT NULL
   ,par_pol_ser             VARCHAR2 DEFAULT NULL
   ,par_period_id           NUMBER DEFAULT NULL
   ,par_fund_id             NUMBER DEFAULT NULL
   ,par_fund_pay_id         NUMBER DEFAULT NULL
   ,par_paymentoff_term_id  NUMBER DEFAULT NULL
   ,par_confirm_date        DATE DEFAULT NULL
   ,par_notice_date         DATE DEFAULT NULL
   ,par_sign_date           DATE DEFAULT NULL
   ,par_confirm_conds_id    NUMBER DEFAULT NULL
   ,par_payment_term_id     NUMBER DEFAULT NULL
   ,par_waiting_period_id   NUMBER DEFAULT NULL
   ,par_privilege_period_id NUMBER DEFAULT NULL
   ,par_discount_f_id       NUMBER DEFAULT NULL
   ,par_notice_num          VARCHAR2 DEFAULT NULL
   ,par_admin_cost          NUMBER DEFAULT 0
   ,par_is_group_flag       NUMBER DEFAULT 0
   ,par_region_id           NUMBER DEFAULT NULL
   ,par_doc_properties      pkg_doc_properties.tt_doc_property DEFAULT NULL
   ,par_comment             VARCHAR2 DEFAULT NULL
   ,par_ph_comment          VARCHAR2 DEFAULT NULL
   ,par_policy_header_id    OUT NUMBER
   ,par_policy_id           OUT NUMBER
  );
  /*
  ����� �.
  ��������� ��� ���������, ������� ����� ���������� ���� ���������� � ���� ��
  �������� ���������� � ����, ���� ���������� � ���� ������� ��������
  */
  FUNCTION get_start_date_by_conf_conds
  (
    par_product_id     NUMBER
   ,par_sign_date      DATE
   ,par_conf_conds_id  NUMBER DEFAULT NULL
   ,par_first_pay_date DATE DEFAULT NULL
  ) RETURN DATE;

  /**�������� ������� �������� � �������� �������
  * �� ������ ��, ����� �� ������ �������
  * , ������������� �� ������� ���������� �� �є
  * , ������������� �� ������� ���������� �������������
  * �� 237380: ������ �� ���������� ��������� �������� ���������
  * @autor ������ �.�
  * @param par_policy - ������ ��
  */
  PROCEDURE check_policy_trans_in_closed(par_policy_id NUMBER);

  -- Author  : �������� �.�.
  -- Created : 04.12.2013
  -- Purpose : 286625: ������ ������ 1950005200 ������ ������
  -- Comment : ��������� ��������� ���� ������ ����� ������ �� � ����� ������ ����:
  --           ���� ������ ������ �� �������� ���������� ��
  --           � ��� �� "��������� �������"
  --           ��� ��� ��������� �� ������ ���������� ��������
  --                                ��������� ����� ������ ��������
  --                                �������������� �������� ���������
  --                                �������������� ����� ��������
  PROCEDURE check_new_policy_date(par_p_policy_id p_policy.policy_id%TYPE);

  /*
    ������ �.
    255495
    ����������� ������� � ������ ������� ������ ������ �� ������� �������� ��������� � ������ Credit life (��������� ��������):
    ������� ����������� - ������� ����� ���� ��� � ��������� (������������ �������� pkg_bso.unlink_bso_policy ),
      �������� ����� ��������,
      ����� ��� ��������,
      ����� ���������.
    ������� �� ����������� - ��������� ������ �� ��������\��������;
  
    ��������� ��������� �� �������� ��������:
    ������ - �������
    �������� ������ - ������� (����������� �� ������ 237830)
  */
  PROCEDURE unlink_bso_from_credit_policy(par_policy_id p_policy.policy_id%TYPE);

  /*
    ����� �.
    ��������� ���� ��������� ������ �����
  */
  FUNCTION get_risk_pricing_end_date(par_policy_id p_policy.policy_id%TYPE) RETURN DATE;

  -- Author  : �������� �.�.
  -- Created : 19.03.2014
  -- Purpose : 315513 ���� ������ ��������/������ ������ � ���������� 2014
  -- Param   : pol_header_id
  --           par_return_info: 'brief'/'descr'/'group'
  -- Comment : ������� ���������� ����� ���������� ����/��������/������ ������ ������.
  FUNCTION get_pol_sales_chn
  (
    par_pol_header  NUMBER
   ,par_return_info VARCHAR2 := NULL
  ) RETURN ins.t_sales_channel.description%TYPE;

  -- Author  : �������� �.�.
  -- Created : 19.03.2014
  -- Purpose : 315513 ���� ������ ��������/������ ������ � ���������� 2014
  -- Param   : pol_header_id
  -- Comment : ���������� �������� ������ ���������� �������� �� �����������, ��� ���� ��������� ����� GN.
  --           ���� ������� GN:
  --                ���� ����� ������ ���������� �� Group Credit life
  --                ���� � �������� ���� '��������� �1 ��������� ����������� �����'
  --                                     '��������� �4 ������� � ��������� ������� � ������ ������'
  --                     �� 'Group END'
  --                ����� Group Term/PA

  FUNCTION get_pol_product_group(par_pol_header NUMBER) RETURN ins.t_product_group.name%TYPE;

  /*
    ������ �.
    http://redmine.renlife.com/issues/1373
    �������� � ��������� �� ������� "ID ������������ �� ���������� ������"
  */
  PROCEDURE set_max_uncancelled_policy_id(par_policy_id NUMBER);

  /*
    ������ �.
    198225 ���������� ������� ���������
  */
  PROCEDURE check_agregation(par_policy_id NUMBER);

  /*
    ������� �.�,
    �������� ������� ������������ ������
  */
  FUNCTION is_pol_header_canceled(par_policy_header_id p_pol_header.policy_header_id%TYPE)
    RETURN BOOLEAN;

  /*
    ��������� �.
    372229 ����������� ���� ��������� ������
  */

  FUNCTION get_policy_end_date(par_p_pol_header NUMBER) RETURN DATE;

  /*
    ��������� �.
    372229 ���������� ���� ��������� �������� ������ �� ��������
  */
  PROCEDURE update_agent_date_end(par_policy_id NUMBER);

  /**
   * ��������� �� ������������� �������� ����� ������
   * @author ������ �. 16.1.2015
   -- %param par_policy_header_id  �� ������������� ��������
  */
  FUNCTION get_redempt_sum_is_handchange(par_policy_header_id p_pol_header.policy_header_id%TYPE)
    RETURN t_policyform_product.is_handchange%TYPE;

  /**
   * ������������ ������� ���������� � ����������� �� ���� ������ �� (������������ � ����������� ���)
   * @author ������ �. 10.4.2015
   * @param par_header_start_date  ���� ������ ��������
  */
  FUNCTION define_cooling_period_length(par_header_start_date p_pol_header.start_date%TYPE)
    RETURN NUMBER;

  /**
   * ������� ���������, �������� �� ��� �������� ����� � ��
   * @author ����������� �. 21.05.2015
   * @param par_policy_id  �� ������ ��
   * @par_series_num ����� ����� ���
   * @return 0 - �� ��������, 1 - ��������
  */
  FUNCTION is_pol_bso_series
  (
    par_policy_id  p_policy.policy_id%TYPE
   ,par_series_num bso_series.series_num%TYPE
  ) RETURN NUMBER;

END pkg_policy;
/
CREATE OR REPLACE PACKAGE BODY pkg_policy IS

  p_debug BOOLEAN := FALSE;

  /*
    ������ �.
    ����� �� ���� ������ commit'�� ������� ���������
  */

  PROCEDURE cover_log_autonomous
  (
    p_p_cover_id IN NUMBER
   ,p_message    IN VARCHAR2
  ) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    INSERT INTO p_cover_debug
      (p_cover_id, execution_date, operation_type, debug_message)
    VALUES
      (p_p_cover_id, SYSDATE, 'INS.PKG_POLICY', substr(p_message, 1, 4000));
    COMMIT;
  END;

  PROCEDURE cover_log
  (
    p_p_cover_id IN NUMBER
   ,p_message    IN VARCHAR2
  ) IS
    --    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    IF p_debug
    THEN
      /*      INSERT INTO P_COVER_DEBUG
        (P_COVER_ID, execution_date, operation_type, debug_message)
      VALUES
        (p_p_cover_id, SYSDATE, 'INS.PKG_POLICY', SUBSTR(p_message, 1, 4000));*/
      cover_log_autonomous(p_p_cover_id, p_message);
    END IF;
  
    --    COMMIT;
  
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END;

  PROCEDURE log_autonomous
  (
    p_p_policy_id IN NUMBER
   ,p_message     IN VARCHAR2
  ) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    INSERT INTO p_policy_debug
      (p_policy_id, execution_date, operation_type, debug_message)
    VALUES
      (p_p_policy_id, SYSDATE, 'INS.PKG_POLICY', substr(p_message, 1, 4000));
    COMMIT;
  END;

  PROCEDURE log
  (
    p_p_policy_id IN NUMBER
   ,p_message     IN VARCHAR2
  ) IS
    --    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    IF p_debug
    THEN
      /*      INSERT INTO P_POLICY_DEBUG
        (P_POLICY_ID, execution_date, operation_type, debug_message)
      VALUES
        (p_p_policy_id, SYSDATE, 'INS.PKG_POLICY', SUBSTR(p_message, 1, 4000));*/
      log_autonomous(p_p_policy_id, p_message);
    END IF;
  
    --    COMMIT;
  
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END;

  FUNCTION get_cover_end_date
  (
    p_p_cover_id IN NUMBER
   ,p_start_date DATE
   ,p_end_date   DATE
   ,p_period_id  IN NUMBER
  ) RETURN DATE IS
    v_val     NUMBER;
    v_name    VARCHAR2(150);
    RESULT    DATE;
    v_a_asset PLS_INTEGER;
    v_one_sec NUMBER := 1 / 24 / 3600;
  BEGIN
  
    /* SELECT pc.As_Asset_Id
     INTO v_a_asset
     FROM p_cover pc
    WHERE pc.p_cover_id = p_p_cover_id;*/
  
    --result:=pkg_cover.get_cover_end(v_a_asset,p_period_id);
  
    SELECT p.period_value
          ,pt.description
      INTO v_val
          ,v_name
      FROM ven_t_period      p
          ,ven_t_period_type pt
     WHERE p.period_type_id = pt.id
       AND p.id = p_period_id;
  
    IF v_val IS NULL
    THEN
      RETURN p_end_date;
    END IF;
  
    CASE v_name
      WHEN '���' THEN
        RESULT := p_start_date + v_val - v_one_sec;
      WHEN '������' THEN
        RESULT := ADD_MONTHS(p_start_date, v_val) - v_one_sec;
      WHEN '����' THEN
        IF to_char(trunc(p_start_date), 'ddmm') = '2902'
        THEN
          RESULT := ADD_MONTHS(p_start_date + 1, v_val * 12) - v_one_sec;
        ELSE
          RESULT := ADD_MONTHS(p_start_date, v_val * 12) - v_one_sec;
        END IF;
      ELSE
        raise_application_error(-20100
                               ,'������ ��� ������� �� ��������������: ' || v_name);
    END CASE;
  
    RETURN RESULT;
    --  EXCEPTION
  
    --    when others then
    --      return p_end_date;
  END;

  FUNCTION get_pol_form_type(p_pol_id NUMBER) RETURN VARCHAR2 IS
    v_form_type VARCHAR2(1000);
  BEGIN
    SELECT pft.brief
      INTO v_form_type
      FROM p_policy           pol
          ,t_product          p
          ,p_pol_header       ph
          ,t_policy_form_type pft
     WHERE pol.policy_id = p_pol_id
       AND ph.policy_header_id = pol.pol_header_id
       AND ph.product_id = p.product_id
       AND p.t_policy_form_type_id = pft.t_policy_form_type_id(+);
  
    RETURN v_form_type;
  END;

  PROCEDURE change_pol_start_date
  (
    p_pol_id NUMBER
   ,p_acc_id NUMBER
  ) IS
    v_setoff_date   DATE;
    v_end_date      DATE;
    v_ph_start_date DATE;
    v_pol_header_id NUMBER;
  BEGIN
    -- ������ ���� ���������� ������ �����
    SELECT trunc(set_off_date, 'DD')
      INTO v_setoff_date
      FROM (SELECT dsf.set_off_date
              FROM doc_set_off dsf
             WHERE dsf.parent_doc_id = p_acc_id
             ORDER BY dsf.doc_set_off_id DESC)
     WHERE rownum = 1;
  
    SELECT v_setoff_date + (p.end_date - p.start_date)
      INTO v_end_date
      FROM p_policy p
     WHERE p.policy_id = p_pol_id;
  
    FOR assets IN (SELECT a.*
                     FROM as_asset a
                    WHERE a.p_policy_id = p_pol_id
                      AND a.status_hist_id = pkg_asset.status_hist_id_new)
    LOOP
      FOR covers IN (SELECT c.*
                       FROM p_cover c
                      WHERE c.as_asset_id = assets.as_asset_id
                        AND c.status_hist_id = pkg_cover.status_hist_id_new)
      LOOP
        UPDATE p_cover pc
           SET pc.end_date   = covers.end_date + (v_setoff_date - covers.start_date)
              ,pc.start_date = v_setoff_date
         WHERE pc.p_cover_id = covers.p_cover_id;
      END LOOP;
    
      UPDATE as_asset a
         SET a.end_date   = assets.end_date + (v_setoff_date - assets.start_date)
            ,a.start_date = v_setoff_date
       WHERE a.as_asset_id = assets.as_asset_id;
      --TODO: INSURED_AGE �� ������� ������. �������� ��� ���-��
    
    END LOOP;
  
    --  update_policy_dates(p_pol_id, v_setoff_date, v_end_date);
  
    UPDATE p_policy
       SET start_date = v_setoff_date
          ,end_date   = v_end_date
     WHERE policy_id = p_pol_id;
  
    SELECT pol_header_id INTO v_pol_header_id FROM p_policy WHERE policy_id = p_pol_id;
  
    SELECT MIN(start_date) INTO v_ph_start_date FROM p_policy WHERE pol_header_id = v_pol_header_id;
  
    UPDATE p_pol_header SET start_date = v_ph_start_date WHERE policy_header_id = v_pol_header_id;
  
    --opatsan
    --����� ������ �� ����������� ������, ����
    --��������� ��� � ����������� ����� ������
    --��� ���������� ������� � ���� "� �������
    --������ ������"
    DECLARE
      v_brief VARCHAR2(30);
    BEGIN
      IF ents.client_id = 10
      THEN
        SELECT t.brief
          INTO v_brief
          FROM p_policy     p
              ,p_pol_header ph
              ,t_product    t
         WHERE p.policy_id = p_pol_id
           AND p.pol_header_id = ph.policy_header_id
           AND t.product_id = ph.product_id;
        IF v_brief <> '�����'
        THEN
          v_end_date := doc.get_last_doc_status_date(p_pol_id);
          v_brief    := doc.get_last_doc_status_brief(p_pol_id);
          IF v_brief = 'NEW'
          THEN
            doc.set_doc_status(p_pol_id, 'CURRENT', v_end_date + 1 / 24 / 3600);
          END IF;
        END IF;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;
  
  END;

  PROCEDURE set_pol_start_date(p_acc_id NUMBER) IS
    v_conf_cond     VARCHAR2(100);
    v_first_paym_id NUMBER;
    v_product_brief VARCHAR2(100);
  BEGIN
    IF doc.get_last_doc_status_brief(p_acc_id) != 'PAID'
    THEN
      RETURN;
    END IF;
  
    FOR pols IN (SELECT *
                   FROM doc_doc
                  WHERE child_id = p_acc_id
                    AND doc.get_doc_templ_brief(parent_id) = 'POLICY')
    LOOP
      BEGIN
        SELECT t.brief
          INTO v_product_brief
          FROM p_policy     p
              ,p_pol_header ph
              ,t_product    t
         WHERE p.policy_id = pols.parent_id
           AND p.pol_header_id = ph.policy_header_id
           AND t.product_id = ph.product_id;
        IF v_product_brief = '�����'
        THEN
          GOTO end_loop;
        END IF;
      END;
    
      SELECT cc.brief
        INTO v_conf_cond
        FROM t_confirm_condition cc
            ,p_pol_header        ph
            ,p_policy            p
       WHERE cc.id(+) = ph.confirm_condition_id
         AND ph.policy_header_id = p.pol_header_id
         AND p.policy_id = pols.parent_id;
    
      IF v_conf_cond = '����������'
      THEN
      
        change_pol_start_date(pols.parent_id, p_acc_id);
      ELSIF v_conf_cond = '����������'
      THEN
        -- ��������� ��� ������ ����? ���� - ��, �� ���� ��������
        SELECT *
          INTO v_first_paym_id
          FROM (SELECT ap.payment_id
                  FROM doc_doc    dd
                      ,ac_payment ap
                      ,p_policy   p
                      ,p_policy   pp
                 WHERE dd.parent_id = p.policy_id
                   AND pp.pol_header_id = p.pol_header_id
                   AND pp.policy_id = pols.parent_id
                   AND ap.payment_id = dd.child_id
                 ORDER BY ap.due_date
                         ,ap.payment_id)
         WHERE rownum = 1;
      
        IF v_first_paym_id = p_acc_id
        THEN
          change_pol_start_date(pols.parent_id, p_acc_id);
        END IF;
      
      END IF;
      <<end_loop>>
      NULL;
    END LOOP;
  END;

  FUNCTION find_pol_period
  (
    p_pol_id      NUMBER
   ,p_best_per_id NUMBER DEFAULT NULL
   ,p_start_date  DATE DEFAULT NULL
   ,p_end_date    DATE DEFAULT NULL
  ) RETURN NUMBER IS
    v_end_date   DATE := p_end_date;
    v_start_date DATE := p_start_date;
    v_months_btw NUMBER;
    v_product_id NUMBER;
    v_period_id  NUMBER;
  BEGIN
  
    SELECT nvl(v_start_date, ph.start_date)
          ,ph.product_id
      INTO v_start_date
          ,v_product_id
      FROM p_pol_header ph
          ,p_policy     p
     WHERE p.policy_id = p_pol_id
       AND ph.policy_header_id = p.pol_header_id;
  
    -- pkg_renlife_utils.tmp_log_writer('v_start_date :  '||v_start_date);
  
    SELECT nvl(v_end_date, p.end_date) INTO v_end_date FROM p_policy p WHERE p.policy_id = p_pol_id;
  
    --   pkg_renlife_utils.tmp_log_writer('v_end_date :  '||v_end_date);
    --�������� �.�. 05/03/2009
    /*        IF TO_CHAR(TRUNC(v_start_date),'ddmm')='2902' THEN
     SELECT MONTHS_BETWEEN(TRUNC(v_end_date,'DD'), TRUNC(v_start_date,'DD'))
         INTO v_months_btw
         FROM dual;
    ELSE*/
    SELECT MONTHS_BETWEEN(trunc(v_end_date, 'DD') + 1, trunc(v_start_date, 'DD'))
      INTO v_months_btw
      FROM dual;
  
    -- END IF;
  
    --    pkg_renlife_utils.tmp_log_writer('v_months_btw :  '||v_months_btw);
  
    -- ���� �� �������� ����� ���� � �������, � �����,  � ���������,  � ����
    -- ����������: ���� ���������� ������ � �� ��������, �� ����� ���, ����� ����� ��-���������, ����� ������� ������ � �������, ����� � �����, ���������....
    BEGIN
      SELECT period_id
        INTO v_period_id
        FROM (SELECT pt.period_id
                FROM t_product_period  pt
                    ,t_period          per
                    ,t_period_type     pert
                    ,t_period_use_type pust
               WHERE pt.period_id = per.id
                 AND per.period_type_id = pert.id
                 AND (pert.brief = 'M' AND per.period_value = v_months_btw OR
                     pert.brief = 'Y' AND per.period_value = v_months_btw / 12 OR
                     pert.brief = 'Q' AND per.period_value = v_months_btw / 3 OR
                     pert.brief = 'D' AND
                     per.period_value = (trunc(v_end_date, 'DD') - trunc(v_start_date, 'DD') + 1)
                     --OR (per.PERIOD_VALUE IS NULL))
                     OR (nvl(per.period_value, 0) = 0))
                 AND pt.product_id = v_product_id
                 AND pt.t_period_use_type_id = pust.t_period_use_type_id
                 AND pust.brief IN ('���� �����������'
                                   ,'���� ����������� �� ������� �����������')
               ORDER BY decode(pt.period_id, p_best_per_id, 1, 0) DESC
                       ,nvl(pt.is_default, 0) DESC
                       ,decode(pert.brief, 'M', 1, 'Y', 2, 'Q', 3, 'D', 4, 'NO', 5, 6) ASC)
       WHERE rownum = 1;
    EXCEPTION
      WHEN no_data_found THEN
        RETURN NULL;
    END;
  
    RETURN v_period_id;
  
  END;

  PROCEDURE update_pol_status_date
  (
    p_pol_id     NUMBER
   ,p_start_date DATE
  ) IS
    v_next_date DATE;
  BEGIN
    BEGIN
      SELECT start_date
        INTO v_next_date
        FROM ven_doc_status
       WHERE doc_status_id = (SELECT doc_status_id
                                FROM (SELECT doc_status_id
                                        FROM ven_doc_status
                                       WHERE document_id = p_pol_id
                                       ORDER BY start_date ASC)
                               WHERE rownum < 2);
    
    EXCEPTION
      WHEN no_data_found THEN
        NULL;
    END;
  
    IF v_next_date IS NULL
       OR v_next_date > p_start_date
    THEN
      /* ������ �.
         ����� ��������� �������� ��-�� VEN
      */
      UPDATE /*ven_*/ doc_status
         SET start_date = p_start_date
       WHERE doc_status_id = (SELECT doc_status_id
                                FROM (SELECT doc_status_id
                                        FROM ven_doc_status
                                       WHERE document_id = p_pol_id
                                       ORDER BY start_date ASC)
                               WHERE rownum < 2);
    END IF;
  END;

  PROCEDURE update_bso_hist
  (
    p_pol_id     NUMBER
   ,p_start_date DATE
  ) IS
  BEGIN
    FOR rec_bso IN (SELECT bso_id FROM bso WHERE policy_id = p_pol_id)
    LOOP
      UPDATE bso_hist
         SET hist_date = p_start_date
       WHERE bso_hist_id = (SELECT MAX(bso_hist_id) FROM bso_hist WHERE bso_id = rec_bso.bso_id);
    END LOOP;
  END;

  PROCEDURE policy_lock(p_pol_id IN NUMBER) IS
  BEGIN
    sp_obj_lock(ent.id_by_brief('P_POLICY'), p_pol_id);
  END;

  FUNCTION get_policy_number(p_policy_id IN NUMBER) RETURN VARCHAR2 IS
  
    CURSOR cur_policy(c_policy_id NUMBER) IS
      SELECT pp.notice_date AS notice_date
            ,pph.product_id AS product_id
            ,pp.version_num AS version_num
            ,pph.company_tree_id AS company_tree_id
            ,pp.is_group_flag AS is_group
            ,nvl(tpr.is_bso_polnum, 0) AS is_bso_polnum
        FROM p_policy     pp
            ,p_pol_header pph
            ,t_product    tpr
       WHERE pph.policy_header_id = pp.pol_header_id
         AND pp.policy_id = c_policy_id
         AND tpr.product_id = pph.product_id;
  
    rec_policy  cur_policy%ROWTYPE;
    v_client_id NUMBER := nvl(ents.client_id, 0);
    lw          VARCHAR2(100);
  
    l_res           VARCHAR2(50);
    l_format        VARCHAR2(100);
    l_pol_numerator VARCHAR2(50);
  BEGIN
  
    OPEN cur_policy(p_policy_id);
    FETCH cur_policy
      INTO rec_policy;
  
    IF (cur_policy%NOTFOUND)
    THEN
      CLOSE cur_policy;
      RETURN NULL;
    END IF;
  
    CLOSE cur_policy;
  
    IF (v_client_id = 10)
    THEN
      l_format := '%INS_GRUP:' || p_policy_id;
      IF (rec_policy.version_num <> 1)
      THEN
        l_pol_numerator := 'VTB-ROSNO_POLICY_ADD';
        l_format        := l_format || '%NUM_ADD:' || rec_policy.version_num;
      ELSE
        l_pol_numerator := 'VTB-ROSNO_POLICY';
      END IF;
    ELSE
      l_format := '%INS_GRUP:' || rec_policy.product_id;
    END IF;
  
    l_format := l_format || '%YY:' || to_char(rec_policy.notice_date, 'dd.mm.yyyy');
    l_format := l_format || '%DEPATMENT:' || rec_policy.company_tree_id;
  
    IF (v_client_id = 11)
    THEN
      --        IF (rec_policy.IS_group = 0)THEN
      IF rec_policy.is_bso_polnum = 1
      THEN
        BEGIN
          SELECT num
            INTO l_res
            FROM (SELECT b.num
                        ,rownum rn
                    FROM bso b
                   WHERE b.policy_id = p_policy_id
                   ORDER BY decode(b.is_pol_num, 1, 1, 0) DESC)
           WHERE rn = 1;
          RETURN l_res;
        EXCEPTION
          WHEN no_data_found THEN
            RETURN NULL;
        END;
      ELSE
        l_format        := '%POL_SER:' || nvl(get_policy_serial(p_policy_id), '-');
        l_pol_numerator := 'RenLife_POLICY_IND';
      END IF;
      --        ELSE
      --          l_pol_numerator := 'RenLife_POLICY_GR';
      --        END IF;
    END IF;
  
    IF l_pol_numerator IS NULL
    THEN
      RETURN NULL;
    END IF;
  
    l_res := pkg_autosq.nextval(l_pol_numerator, l_format);
    RETURN l_res;
    /*
    exception
    when others then
      DBMS_OUTPUT.put_line(sqlerrm);
      return null;*/
  END get_policy_number;

  FUNCTION get_policy_serial(p_policy_id IN NUMBER) RETURN VARCHAR2 IS
  
    CURSOR cur_policy(c_policy_id NUMBER) IS
      SELECT pph.product_id AS product_id
        FROM p_policy     pp
            ,p_pol_header pph
       WHERE pph.policy_header_id = pp.pol_header_id
         AND pp.policy_id = c_policy_id;
  
    v_client_id NUMBER := nvl(ents.client_id, 0);
  
    rec_policy cur_policy%ROWTYPE;
  
    l_res     VARCHAR2(50);
    l_format  VARCHAR2(100);
    l_pol_ser VARCHAR2(50);
  BEGIN
  
    OPEN cur_policy(p_policy_id);
    FETCH cur_policy
      INTO rec_policy;
  
    IF (cur_policy%NOTFOUND)
    THEN
      CLOSE cur_policy;
      RETURN NULL;
    END IF;
  
    CLOSE cur_policy;
  
    IF (v_client_id = 11)
    THEN
      -- l_pol_ser := 'RenLife_POLICY_SER';
      BEGIN
      
        SELECT series_name
          INTO l_pol_ser
          FROM (SELECT bs.series_name
                  FROM t_product_bso_types pbt
                      ,bso_type            bt
                      ,bso_series          bs
                      ,p_policy            p
                      ,p_pol_header        ph
                 WHERE bt.bso_type_id = pbt.bso_type_id
                   AND lower(bt.kind_brief) = '�����'
                   AND bs.bso_type_id = bt.bso_type_id
                   AND pbt.t_product_id = ph.product_id
                   AND p.pol_header_id = ph.policy_header_id
                   AND p.policy_id = p_policy_id
                 ORDER BY bs.is_default)
         WHERE rownum < 2;
        RETURN l_pol_ser;
      EXCEPTION
        WHEN no_data_found THEN
          l_pol_ser := 'RenLife_POLICY_SER';
      END;
    END IF;
  
    IF (v_client_id = 10)
    THEN
      l_pol_ser := 'VTB-ROSNO_POLICY_SER';
    END IF;
  
    IF l_pol_ser IS NULL
    THEN
      RETURN NULL;
    END IF;
  
    l_format := '%INS_GRUP:' || rec_policy.product_id;
    l_res    := pkg_autosq.nextval(l_pol_ser, l_format);
    RETURN l_res;
    /*
    exception
      when others then
        return null;*/
  END get_policy_serial;

  FUNCTION get_policy_ser
  (
    p_prod_id      IN NUMBER
   ,p_cont_type_id IN NUMBER DEFAULT NULL
   ,p_policy_id    IN NUMBER DEFAULT NULL
  ) RETURN VARCHAR2 IS
    ret_val      VARCHAR2(255);
    v_prod_brief VARCHAR2(30);
    v_cont_type  VARCHAR2(20);
  BEGIN
    SELECT p.brief INTO v_prod_brief FROM t_product p WHERE p.product_id = p_prod_id;
    IF v_prod_brief = '�����'
    THEN
      ret_val := '���';
    ELSIF v_prod_brief = '�������1'
    THEN
      ret_val := 'LPF';
    ELSIF v_prod_brief = '���'
    THEN
      BEGIN
        SELECT '��' || nvl(dt.code, '39') || '-��'
          INTO ret_val
          FROM ven_p_policy     p
              ,ven_p_pol_header ph
              ,ven_department   dt
         WHERE p.policy_id = p_policy_id
           AND p.pol_header_id = ph.policy_header_id
           AND ph.company_tree_id = dt.department_id(+);
      EXCEPTION
        WHEN OTHERS THEN
          ret_val := '��39-��';
      END;
      IF p_cont_type_id IS NOT NULL
      THEN
        SELECT upper(ext_id) INTO v_cont_type FROM t_contact_type WHERE id = p_cont_type_id;
        IF v_cont_type = '�������'
        THEN
          ret_val := ret_val || '��';
        ELSE
          ret_val := ret_val || '��';
        END IF;
      END IF;
    ELSIF ents.client_id = 10
    THEN
      RETURN NULL;
    ELSE
      ret_val := p_prod_id;
    END IF;
    RETURN ret_val;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  /*
    ������ �.
  
    ��������� ����� ������-������� �������� ������ ��
    @param par_policy_id - �� ������ ��
    @return ����� ������-������� �������� ������ ��
  */
  FUNCTION get_policy_fee
  (
    par_policy_id          p_policy.policy_id%TYPE
   ,par_include_admin_cost BOOLEAN DEFAULT FALSE
   ,par_round_to           NUMBER DEFAULT NULL
  ) RETURN p_cover.fee%TYPE IS
    v_sum_fee p_cover.fee%TYPE;
  BEGIN
    assert_deprecated(par_policy_id IS NULL, '�� ������ �������� �� ������');
    assert_deprecated(par_include_admin_cost IS NULL
                     ,'������� ��������� ���. �������� �� ������');
    /* ������������ ������� ��� ����� �������� ��������,
    ��������, � ���������� ����������� ��� �������� */
    IF par_include_admin_cost
    THEN
      SELECT ROUND(SUM(pc.fee), nvl(par_round_to, 38))
        INTO v_sum_fee
        FROM as_asset    se
            ,p_cover     pc
            ,status_hist sh
       WHERE se.p_policy_id = par_policy_id
         AND se.as_asset_id = pc.as_asset_id
         AND pc.status_hist_id = sh.status_hist_id
         AND sh.brief != 'DELETED';
    ELSE
      SELECT ROUND(SUM(pc.fee), nvl(par_round_to, 38))
        INTO v_sum_fee
        FROM as_asset           se
            ,p_cover            pc
            ,t_prod_line_option plo
            ,status_hist        sh
       WHERE se.p_policy_id = par_policy_id
         AND se.as_asset_id = pc.as_asset_id
         AND pc.status_hist_id = sh.status_hist_id
         AND sh.brief != 'DELETED'
         AND pc.t_prod_line_option_id = plo.id
         AND (plo.brief NOT IN ('Adm_Cost_Acc', 'Adm_Cost_Life', 'Penalty') OR plo.brief IS NULL);
    END IF;
    RETURN v_sum_fee;
  END get_policy_fee;

  /*
    ������ �.
  
    ��������� ������ �������� �� �� ��������� ��
    @param par_pol_header_id - �� ��������� ��
    @return ������ ��������
  */
  FUNCTION get_policy_fund_id_by_header
  (
    par_pol_header_id  p_pol_header.policy_header_id%TYPE
   ,par_raise_on_error BOOLEAN DEFAULT TRUE
  ) RETURN fund.fund_id%TYPE IS
    v_fund_id fund.fund_id%TYPE;
  BEGIN
    assert_deprecated(par_pol_header_id IS NULL
                     ,'�� ��������� �������� �� ������');
    BEGIN
      SELECT ph.fund_id
        INTO v_fund_id
        FROM p_pol_header ph
       WHERE ph.policy_header_id = par_pol_header_id;
    EXCEPTION
      WHEN no_data_found THEN
        IF par_raise_on_error
        THEN
          raise_application_error(-20001
                                 ,'�� ������ ��������� �������� ����������� �� ��');
        ELSE
          v_fund_id := NULL;
        END IF;
    END;
    RETURN v_fund_id;
  END get_policy_fund_id_by_header;

  /*
    ������ �.
  
    ��������� ������ ������ �������� �� �� ��������� ��
    @param par_pol_header_id - �� ��������� ��
    @return ������ ������ ��������
  */
  FUNCTION get_pol_fund_pay_id_by_header
  (
    par_pol_header_id  p_pol_header.policy_header_id%TYPE
   ,par_raise_on_error BOOLEAN DEFAULT TRUE
  ) RETURN fund.fund_id%TYPE IS
    v_fund_pay_id fund.fund_id%TYPE;
  BEGIN
    assert_deprecated(par_pol_header_id IS NULL
                     ,'�� ��������� �������� �� ������');
    BEGIN
      SELECT ph.fund_pay_id
        INTO v_fund_pay_id
        FROM p_pol_header ph
       WHERE ph.policy_header_id = par_pol_header_id;
    EXCEPTION
      WHEN no_data_found THEN
        IF par_raise_on_error
        THEN
          raise_application_error(-20001
                                 ,'�� ������ ��������� �������� ����������� �� ��');
        ELSE
          v_fund_pay_id := NULL;
        END IF;
    END;
    RETURN v_fund_pay_id;
  END get_pol_fund_pay_id_by_header;

  FUNCTION get_policy_nr
  (
    p_prod_id IN NUMBER
   ,p_ser     IN VARCHAR2 DEFAULT NULL
    --,p_dept_id    IN NUMBER DEFAULT NULL
  ) RETURN VARCHAR2 IS
    ret_val      VARCHAR2(255);
    v_prod_brief VARCHAR2(30);
    v_temp_num   NUMBER;
    v_temp_ser   VARCHAR2(30);
  BEGIN
    SELECT p.brief INTO v_prod_brief FROM t_product p WHERE p.product_id = p_prod_id;
    IF v_prod_brief = '�����'
    THEN
      RETURN NULL;
    ELSIF v_prod_brief = '���'
    THEN
      IF p_ser IS NULL
      THEN
        v_temp_ser := '��39-��00';
      ELSE
        v_temp_ser := p_ser;
      END IF;
    
      SELECT COUNT(1)
        INTO v_temp_num
        FROM p_policy
       WHERE pol_ser LIKE substr(v_temp_ser, 1, length(v_temp_ser) - 2) || '%';
      IF v_temp_num = 0
      THEN
        ret_val := '000001';
      ELSE
        BEGIN
          SELECT MAX(to_number(pol_num)) + 1
            INTO v_temp_num
            FROM p_policy
           WHERE pol_ser LIKE substr(v_temp_ser, 1, length(v_temp_ser) - 2) || '%';
        EXCEPTION
          WHEN OTHERS THEN
            SELECT sq_policy_num.nextval INTO ret_val FROM dual;
        END;
        ret_val := TRIM(to_char(v_temp_num, '9000000'));
      END IF;
    ELSIF ents.client_id = 10
    THEN
      RETURN NULL;
      --SELECT sq_policy_num.NEXTVAL INTO ret_val FROM dual;
    ELSE
      SELECT sq_policy_num.nextval INTO ret_val FROM dual;
    END IF;
    RETURN ret_val;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  FUNCTION policy_insert
  (
    p_pol_id               IN NUMBER
   ,p_product_id           IN NUMBER
   ,p_sales_channel_id     IN NUMBER
   ,p_company_tree_id      IN NUMBER
   ,p_fund_id              IN NUMBER
   ,p_fund_pay_id          IN NUMBER
   ,p_confirm_condition_id IN NUMBER
   ,p_pol_ser              IN VARCHAR2
   ,p_pol_num              IN VARCHAR2
   ,p_notice_date          IN DATE
   ,p_sign_date            IN DATE
   ,p_confirm_date         IN DATE
   ,p_start_date           IN DATE
   ,p_end_date             IN DATE
   ,p_first_pay_date       IN DATE
   ,p_payment_term_id      IN NUMBER
   ,p_period_id            IN NUMBER
   ,p_agent_id_1           IN NUMBER
   ,p_agent_id_2           IN NUMBER
   ,p_curator_id           IN NUMBER
   ,p_issuer_id            IN NUMBER
   ,p_osago_sign_ser       IN VARCHAR2
   ,p_osago_sign_num       IN VARCHAR2
   ,p_prev_event_count     IN NUMBER
   ,p_fee_payment_term     IN NUMBER
   ,p_beneficiary_id       IN NUMBER
   ,p_fact_j               IN NUMBER
   ,p_ag_contract_id_1     IN NUMBER
   ,p_ag_contract_id_2     IN NUMBER
   ,p_admin_cost           IN NUMBER
   ,p_is_park              IN NUMBER DEFAULT 0
   ,p_is_group_flag        IN NUMBER DEFAULT NULL
   ,p_notice_num           IN VARCHAR2 DEFAULT NULL
   ,p_waiting_period_id    IN NUMBER DEFAULT NULL
   ,p_sales_action_id      IN NUMBER DEFAULT NULL
   ,p_region_id            IN NUMBER DEFAULT NULL
   ,p_office_manager_id    IN NUMBER DEFAULT NULL
   ,p_region_manager_id    IN NUMBER DEFAULT NULL
   ,p_discount_f_id        IN NUMBER DEFAULT NULL
   ,p_description          IN VARCHAR2 DEFAULT NULL
   ,p_paymentoff_term_id   IN NUMBER DEFAULT NULL
   ,p_ph_description       IN VARCHAR2 DEFAULT NULL
   ,p_payment_start_date   DATE DEFAULT NULL
   ,p_privilege_period     IN NUMBER DEFAULT NULL
   ,p_issuer_agent_id      IN NUMBER DEFAULT NULL
   ,p_mailing              IN NUMBER DEFAULT 0
   ,p_product_conds_id     IN NUMBER DEFAULT NULL
   ,p_base_sum             IN NUMBER DEFAULT NULL
   ,p_is_credit            IN NUMBER DEFAULT NULL
  ) RETURN NUMBER IS
    v_pol_head_id       NUMBER;
    v_version_order_num NUMBER;
  BEGIN
    SELECT sq_p_pol_header.nextval INTO v_pol_head_id FROM dual;
    INSERT INTO ven_p_pol_header
      (policy_header_id
      ,num
      ,reg_date
      ,start_date
      ,doc_templ_id
      ,product_id
      ,sales_channel_id
      ,company_tree_id
      ,fund_id
      ,fund_pay_id
      ,confirm_condition_id
      ,policy_id
      ,prev_event_count
      ,ag_contract_1_id
      ,ag_contract_2_id
      ,is_park
      ,is_new
      ,description)
      SELECT v_pol_head_id
            ,decode(p_pol_ser
                   ,NULL
                   ,decode(p_pol_num, NULL, '-', p_pol_num)
                   ,decode(p_pol_num, NULL, p_pol_ser, p_pol_ser || '-' || p_pol_num))
            ,SYSDATE
            ,p_start_date
            ,dt.doc_templ_id
            ,p_product_id
            ,p_sales_channel_id
            ,p_company_tree_id
            ,p_fund_id
            ,p_fund_pay_id
            ,p_confirm_condition_id
            ,p_pol_id
            ,p_prev_event_count
            ,p_ag_contract_id_1
            ,p_ag_contract_id_2
            ,p_is_park
            ,1
            ,p_ph_description
        FROM ven_doc_templ dt
       WHERE dt.brief = 'POL_HEADER';
  
    INSERT INTO ven_p_policy
      (policy_id
      ,num
      ,reg_date
      ,doc_templ_id
      ,version_num
      ,pol_header_id
      ,pol_ser
      ,pol_num
      ,notice_date
      ,sign_date
      ,start_date
      ,confirm_date
      ,end_date
      ,first_pay_date
      ,ins_amount
      ,premium
      ,payment_term_id
      ,period_id
      ,osago_sign_ser
      ,osago_sign_num
      ,fee_payment_term
      ,fact_j
      ,admin_cost
      ,is_group_flag
      ,notice_num
      ,waiting_period_id
      ,sales_action_id
      ,region_id
      ,discount_f_id
      ,description
      ,paymentoff_term_id
      ,payment_start_date
      ,pol_privilege_period_id
      ,mailing
      ,t_product_conds_id
      ,base_sum
      ,is_credit)
      SELECT p_pol_id
            ,decode(p_pol_ser
                   ,NULL
                   ,decode(p_pol_num, NULL, '-', p_pol_num)
                   ,decode(p_pol_num, NULL, p_pol_ser, p_pol_ser || '-' || p_pol_num))
            ,SYSDATE
            ,dt.doc_templ_id
            ,1
            ,v_pol_head_id
            ,p_pol_ser
            ,p_pol_num
            ,p_notice_date
            ,p_sign_date
            ,p_start_date
            ,p_confirm_date
            ,p_end_date
            ,p_first_pay_date
            ,0
            ,0
            ,p_payment_term_id
            ,p_period_id
            ,p_osago_sign_ser
            ,p_osago_sign_num
            ,p_fee_payment_term
            ,p_fact_j
            ,p_admin_cost
            ,p_is_group_flag
            ,p_notice_num
            ,p_waiting_period_id
            ,p_sales_action_id
            ,p_region_id
            ,p_discount_f_id
            ,p_description
            ,p_paymentoff_term_id
            ,p_payment_start_date
            ,p_privilege_period
            ,p_mailing
            ,p_product_conds_id
            ,p_base_sum
            ,p_is_credit
        FROM ven_doc_templ dt
       WHERE dt.brief = 'POLICY';
    --
    v_version_order_num := set_pol_version_order_num(p_pol_id);
  
    -- ��������� ������������
    INSERT INTO ven_p_policy_contact
      (policy_id, contact_id, contact_policy_role_id)
      SELECT p_pol_id
            ,p_issuer_id
            ,t.id
        FROM ven_t_contact_pol_role t
       WHERE t.brief = '������������';
  
    -- ��������� �������
    IF p_agent_id_1 IS NOT NULL
    THEN
      INSERT INTO ven_p_policy_contact
        (policy_id, contact_id, contact_policy_role_id)
        SELECT p_pol_id
              ,p_agent_id_1
              ,t.id
          FROM ven_t_contact_pol_role t
         WHERE t.brief = '�����';
    END IF;
  
    IF p_agent_id_2 IS NOT NULL
    THEN
      INSERT INTO ven_p_policy_contact
        (policy_id, contact_id, contact_policy_role_id)
        SELECT p_pol_id
              ,p_agent_id_2
              ,t.id
          FROM ven_t_contact_pol_role t
         WHERE t.brief = '�����';
    END IF;
  
    IF p_beneficiary_id IS NOT NULL
    THEN
      INSERT INTO ven_p_policy_contact
        (policy_id, contact_id, contact_policy_role_id)
        SELECT p_pol_id
              ,p_beneficiary_id
              ,t.id
          FROM ven_t_contact_pol_role t
         WHERE t.brief = '�������������������';
    END IF;
  
    IF p_issuer_agent_id IS NOT NULL
    THEN
      INSERT INTO ven_p_policy_contact
        (policy_id, contact_id, contact_policy_role_id)
        SELECT p_pol_id
              ,p_issuer_agent_id
              ,t.id
          FROM ven_t_contact_pol_role t
         WHERE t.brief = '������������� ������������';
    END IF;
    -- ��������� ��������
    IF p_curator_id IS NOT NULL
    THEN
      INSERT INTO ven_p_policy_contact
        (policy_id, contact_id, contact_policy_role_id)
        SELECT p_pol_id
              ,p_curator_id
              ,t.id
          FROM ven_t_contact_pol_role t
         WHERE t.brief = '�������';
    END IF;
  
    -- ��������� ���� ���������, ���� ����
    IF p_office_manager_id IS NOT NULL
    THEN
      INSERT INTO ven_p_policy_contact
        (policy_id, contact_id, contact_policy_role_id)
        SELECT p_pol_id
              ,p_office_manager_id
              ,t.id
          FROM ven_t_contact_pol_role t
         WHERE t.brief = '������������';
    END IF;
    -- ��������� ������������� ���������, ���� ����
    IF p_region_manager_id IS NOT NULL
    THEN
      INSERT INTO ven_p_policy_contact
        (policy_id, contact_id, contact_policy_role_id)
        SELECT p_pol_id
              ,p_region_manager_id
              ,t.id
          FROM ven_t_contact_pol_role t
         WHERE t.brief = '�����������';
    END IF;
  
    -- ��������� ������ � ���, ��� �������� �������� � ����� � ��� �������� �������.
    -- ������� �.������� 16.11.2006
    IF (p_company_tree_id IS NOT NULL)
       AND (p_curator_id IS NOT NULL)
    THEN
      INSERT INTO ven_doc_movement
        (department_to_id, person_to_id, fact_start_date, document_id, t_dm_status_id, num, note)
      VALUES
        (p_company_tree_id
        ,p_curator_id
        ,SYSDATE
        ,v_pol_head_id
        ,(SELECT t_dm_status_id FROM t_dm_status WHERE brief = 'PROCESS')
        ,1
        ,'������������� �� ������� ' ||
         decode(p_pol_ser
               ,NULL
               ,decode(p_pol_num, NULL, '-', p_pol_num)
               ,decode(p_pol_num, NULL, p_pol_ser, p_pol_ser || '-' || p_pol_num)));
    END IF;
  
    doc.set_doc_status(p_pol_id, 'PROJECT', p_start_date);
    --    set_pol_header_status(v_pol_head_id);
    --pkg_bso.check_all_bso_on_policy(p_pol_id);
    RETURN v_pol_head_id;
  END;

  /**
  ��������� �������� ���. ��������� ��� �������� ����� ������ ��������.
  � ����������� �������� ����� ���� ������ ���.���������� ��������� �����:
  * �������������� �������� ���������
  * �������������� ����� ��������
  */
  PROCEDURE check_quit_pol_addendum_type(par_policy_id IN NUMBER) IS
    v_addendum_exists NUMBER(1);
  
    FUNCTION get_active_policy_status_brief(par_policy_id p_policy.policy_id%TYPE)
      RETURN doc_status_ref.brief%TYPE IS
      v_pol_header_id    p_pol_header.policy_header_id%TYPE;
      v_active_policy_id p_policy.policy_id%TYPE;
      v_status_brief     doc_status_ref.brief%TYPE;
    BEGIN
    
      v_pol_header_id := get_policy_header_id(par_policy_id => par_policy_id);
    
      v_active_policy_id := get_active_policy(p_p_pol_header_id => v_pol_header_id);
    
      v_status_brief := doc.get_last_doc_status_brief(v_active_policy_id);
    
      RETURN v_status_brief;
    
    END get_active_policy_status_brief;
  
    /*�������� ��� ����� ���������  ����������� ��������� ����� �� ��������� � ����������� ������� ���������� ������,
    ��� ��� ����� 3-�� ��������� �� (��� ��������)*/
    FUNCTION is_change_fee_violation(par_policy_id p_policy.policy_id%TYPE) RETURN BOOLEAN IS
      v_count NUMBER;
    BEGIN
      SELECT COUNT(*)
        INTO v_count
        FROM dual
       WHERE EXISTS (SELECT NULL
                FROM p_pol_addendum_type pat
                    ,t_addendum_type     tat
                    ,p_policy            pp
                    ,p_pol_header        pph
               WHERE pat.p_policy_id = par_policy_id
                 AND tat.t_addendum_type_id = pat.t_addendum_type_id
                 AND tat.brief IN ('PREMIUM_CHANGE')
                 AND pp.policy_id = pat.p_policy_id
                 AND pp.pol_header_id = pph.policy_header_id
                 AND pp.start_date < pkg_anniversary.get_anniversary(pph.start_date, 3));
      RETURN v_count = 1;
    END is_change_fee_violation;
  
  BEGIN
  
    IF get_active_policy_status_brief(par_policy_id) IN
       ('TO_QUIT'
       ,'TO_QUIT_CHECK_READY'
       ,'TO_QUIT_CHECKED'
       ,'QUIT_REQ_QUERY'
       ,'QUIT_REQ_GET'
       ,'QUIT_TO_PAY'
       ,'QUIT')
    THEN
      -- �������� �������
      SELECT COUNT(*)
        INTO v_addendum_exists
        FROM dual
       WHERE EXISTS
       (SELECT NULL
                FROM p_pol_addendum_type pat
                    ,t_addendum_type     tat
               WHERE pat.p_policy_id = par_policy_id
                 AND tat.t_addendum_type_id = pat.t_addendum_type_id
                 AND tat.brief NOT IN
                     ('RECOVER_MAIN', 'FULL_POLICY_RECOVER', 'WRONGFUL_TERM_POLICY_RECOVER'));
    
      IF v_addendum_exists > 0
      THEN
        raise_application_error(-20000
                               ,'�������������� ���������� ��������� ���� �� ����� ���� �������� �� ������������� �������� �����������');
      END IF;
    END IF;
    
    /*
    381636 - ����������� �� �������� ����� ������ ��
    ������� �������� �� ��� ����������� ������� ���������� ������
    - ��������� �� �������� < 3-� ���������
    ������ �.  26.5.2015
    */
    IF is_change_fee_violation(par_policy_id)
    THEN
      ex.raise_custom(par_message => '������ ������� ��������� �� �������� ������ ��� ���������');
    END IF;
  
  END check_quit_pol_addendum_type;

  /**
  * ��������� �������� ����������� ������ �������� �����������
  * (��������, �������������� ������� ���������).
  * ������������ ��� �������� ��� ����� �������
  * @author Denis Ivanov
  * @param par_policy_id �� ������ ������
  */
  PROCEDURE check_new_policy(par_policy_id IN NUMBER) IS
    v_policy        p_policy%ROWTYPE;
    i               INT;
    v_product_brief t_product.brief%TYPE;
    v_series        VARCHAR2(3);
  BEGIN
    SELECT p.* INTO v_policy FROM p_policy p WHERE p.policy_id = par_policy_id;
  
    IF v_policy.version_num = 1 /* and v_policy.mailing = 0*/
    THEN
      SELECT pr.brief
            ,substr(to_char(ph.ids), 1, 3)
        INTO v_product_brief
            ,v_series
        FROM p_pol_header ph
            ,t_product    pr
       WHERE ph.policy_header_id = v_policy.pol_header_id
         AND ph.product_id = pr.product_id;
    
      /*
        ������ �.
        ������ �17107
        ���������� ������� �� ������ ������ �������� ����������� ��� ���������:
        �������� ����� 191,192, 195
        ������� 191 ,192, 195
        ����� 191,192, 195
        ���� 191,192, 195
        Baby Life Active
        Platinum Life Active
        �������� �����_2
        �������_2
        ����_2
        �����_2
        Family Life Active
        Family Life Active_2
        Baby_Life_Active_2
        Platinum Life Active_2
        , ��� ���� ��������� ��������� ������� �� ������� � ������ ������.
      */
      IF (v_product_brief IN ('END', 'PEPR', 'TERM', 'CHI') AND v_series IN ('191', '192', '195') OR
         v_product_brief IN ('Baby_LA'
                             ,'Baby_LA2'
                             ,'Family La'
                             ,'Family_La2'
                             ,'Platinum_LA'
                             ,'Platinum_LA2'
                             ,'END_2'
                             ,'CHI'
                             ,'CHI_2'
                             ,'PEPR_2'
                             ,'TERM_2'))
         AND nvl(v_policy.mailing, 0) = 0
      THEN
        raise_application_error(-20001
                               ,'������� ������� ��������. ���� "�������� ��������" ������ ���� �������!');
      ELSIF NOT
             (v_product_brief IN ('END', 'PEPR', 'TERM', 'CHI') AND v_series IN ('191', '192', '195') OR
             v_product_brief IN ('Baby_LA'
                                 ,'Baby_LA2'
                                 ,'Family La'
                                 ,'Family_La2'
                                 ,'Platinum_LA'
                                 ,'Platinum_LA2'
                                 ,'END_2'
                                 ,'CHI'
                                 ,'CHI_2'
                                 ,'PEPR_2'
                                 ,'TERM_2'))
            AND nvl(v_policy.mailing, 0) = 1
      THEN
        raise_application_error(-20001
                               ,'������� ������� ��������. ���� "�������� ��������" ������ ���� ���������!');
      END IF;
    END IF;
  
    IF v_policy.pol_num IS NULL
    THEN
      raise_application_error(-20000, '�� ����� ����� ��������');
    END IF;
  
    IF (v_policy.ins_amount IS NULL /* or v_policy.ins_amount = 0*/
       )
    THEN
      raise_application_error(-20000
                             ,'�� ���������� �������� ��������� ����� �� ��������.');
    END IF;
  
    IF (v_policy.premium IS NULL OR v_policy.premium = 0)
    THEN
      raise_application_error(-20000
                             ,'�� ���������� �������� ������ �� ��������.');
    END IF;
  
    SELECT COUNT(*) INTO i FROM as_asset a WHERE a.p_policy_id = par_policy_id;
  
    IF i < 1
    THEN
      raise_application_error(-20000
                             ,'������� �� �������� �������� �����������');
    END IF;
  
    SELECT COUNT(*)
      INTO i
      FROM p_cover  pc
          ,as_asset a
     WHERE a.p_policy_id = par_policy_id
       AND pc.as_asset_id = a.as_asset_id;
    IF i < 1
    THEN
      raise_application_error(-20000
                             ,'�� ���������� ��������� �������� ������� �����������');
    END IF;
  
    -- ��� ��������� ����� ��������� ����� ������
    FOR pr IN (SELECT prod.product_id
                     ,ph.sales_channel_id
                 FROM ven_t_product          prod
                     ,ven_t_policy_form_type pft
                     ,ven_p_pol_header       ph
                WHERE prod.product_id = ph.product_id
                  AND ph.policy_header_id = v_policy.pol_header_id
                  AND pft.t_policy_form_type_id = prod.t_policy_form_type_id
                  AND pft.brief = '�����')
    LOOP
      FOR sh IN (SELECT pr.sales_channel_id
                   FROM dual
                  WHERE pr.sales_channel_id NOT IN
                        (SELECT tpsh.sales_channel_id
                           FROM ven_t_prod_sales_chan tpsh
                          WHERE tpsh.product_id = pr.product_id))
      LOOP
        raise_application_error(-20000
                               ,'����� ������ ����������� � ��������');
      END LOOP;
    END LOOP;
  END;

  PROCEDURE set_previous_as_active_version(par_policy_id IN NUMBER) IS
    v_prev_pol_id       NUMBER;
    v_prev_brief_status VARCHAR2(100);
  BEGIN
  
    /*    IF Utils.get_null('new_policy_version', 0) = 1
    THEN
      RETURN;
    END IF;*/
  
    BEGIN
      SELECT pp.prev_ver_id INTO v_prev_pol_id FROM p_policy pp WHERE pp.policy_id = par_policy_id;
    EXCEPTION
      WHEN no_data_found THEN
        RETURN;
    END;
  
    IF v_prev_pol_id IS NULL
    THEN
      RETURN;
    END IF;
  
    UPDATE p_pol_header p
       SET p.policy_id = v_prev_pol_id
     WHERE p.policy_header_id IN
           (SELECT pp.pol_header_id FROM p_policy pp WHERE pp.policy_id = v_prev_pol_id);
  
    IF doc.get_last_doc_status_brief(v_prev_pol_id) = 'STOPED'
    THEN
      BEGIN
        SELECT brief
          INTO v_prev_brief_status
          FROM (SELECT dsf.*
                      ,rownum rnm
                  FROM doc_status     ds
                      ,doc_status_ref dsf
                 WHERE ds.document_id = v_prev_pol_id
                   AND ds.doc_status_ref_id = dsf.doc_status_ref_id
                 ORDER BY ds.start_date DESC)
         WHERE rnm = 2;
        doc.set_doc_status(v_prev_pol_id, v_prev_brief_status);
      EXCEPTION
        WHEN no_data_found THEN
          NULL;
      END;
    END IF;
  END;

  /**
  * ���������� ������ ������ ��� �������� ��� �������� �������� �����������
  * @author Denis Ivanov
  * @param par_policy_id �� ������ ������
  */
  PROCEDURE set_self_as_active_version(par_policy_id IN NUMBER) IS
    v_old_curr_policy_id NUMBER;
    v_status_date        DATE;
  BEGIN
    -- ����������� �������� ����������� ���������� NOT_CHANGE_ACTIVE_VER, �������
    -- ��������������� = 1 ��� ����������� ������
    IF utils.get_null('NOT_CHANGE_ACTIVE_VER', 0) = 1
    THEN
      utils.put('NOT_CHANGE_ACTIVE_VER', 0);
      RETURN;
    END IF;
    -- ���� ������ ��������� = ������, �� ������ ������ ����� ��������, ������ ���� ��� ������
    IF doc.get_last_doc_status_brief(par_policy_id) = 'PROJECT'
       AND is_addendum(par_policy_id) = 1
    THEN
      RETURN;
    END IF;
    -- ������������� � p_pol_header ������ �� �������� ������ ������
    UPDATE p_pol_header p
       SET p.policy_id = par_policy_id
     WHERE p.policy_header_id IN
           (SELECT pp.pol_header_id FROM p_policy pp WHERE pp.policy_id = par_policy_id);
    -- ����� �������� ������ ������������� � ven_p_pol_header
    UPDATE ven_p_pol_header ph
       SET ph.num =
           (SELECT num FROM ven_p_policy WHERE policy_id = par_policy_id)
     WHERE ph.policy_id = par_policy_id;
  
    -- ���������� �������� ������ ������ ������ "��������"
    IF is_active_status(doc.get_last_doc_status_brief(par_policy_id)) = 1
    THEN
      BEGIN
        -- �������� ���� ������� ����� �������� ������
        SELECT start_date
          INTO v_status_date
          FROM (SELECT ds.start_date
                  FROM doc_status     ds
                      ,doc_status_ref dsr
                 WHERE dsr.doc_status_ref_id = ds.doc_status_ref_id
                   AND dsr.brief = doc.get_last_doc_status_brief(par_policy_id)
                   AND ds.document_id = par_policy_id
                 ORDER BY start_date DESC)
         WHERE rownum = 1;
      
        SELECT a.policy_id
          INTO v_old_curr_policy_id
          FROM (SELECT p.policy_id AS policy_id
                  FROM p_policy p
                 WHERE p.policy_id <> par_policy_id
                      -- ������ �.
                      -- ������� ������� ��������; ������ 157229
                   AND doc.get_last_doc_status_brief(p.policy_id) IN
                       ('CURRENT', 'ACTIVE', 'PRINTED', 'CONCLUDED', 'PASSED_TO_AGENT')
                   AND p.pol_header_id IN
                       (SELECT pp.pol_header_id FROM p_policy pp WHERE pp.policy_id = par_policy_id)
                 ORDER BY p.policy_id DESC) a
         WHERE rownum <= 1;
      
        doc.set_doc_status(v_old_curr_policy_id, 'STOPED', v_status_date);
      EXCEPTION
        WHEN no_data_found THEN
          NULL;
      END;
    END IF;
  END;

  PROCEDURE set_status_change_context(par_policy_id NUMBER) IS
    v_status VARCHAR2(100);
  BEGIN
    v_status := doc.get_last_doc_status_brief(par_policy_id);
    CASE v_status
      WHEN 'CURRENT' THEN
        BEGIN
          utils.put('par_is_set', 1);
          utils.put('par_is_clear', 0);
        END;
      WHEN 'CANCEL' THEN
        BEGIN
          utils.put('par_is_set', 0);
          utils.put('par_is_clear', 1);
        END;
      ELSE
        NULL;
    END CASE;
  END;
  PROCEDURE check_bso(par_policy_id NUMBER) IS
    v_is_set   NUMBER;
    v_is_clear NUMBER;
  BEGIN
    v_is_set   := utils.get_null('par_is_set', 0);
    v_is_clear := utils.get_null('par_is_clear', 0);
    pkg_bso.check_all_bso_on_policy(par_policy_id, v_is_set, v_is_clear);
  END;

  PROCEDURE notify_pol_header_updated(par_policy_id NUMBER) IS
    v_pol_head_id NUMBER;
  BEGIN
    NULL;
    -- ������ �.
    -- ������� ������ ������ �� ������������, ������� ��� ���������������
    /*SELECT pp.pol_header_id
      INTO v_pol_head_id
      FROM P_POLICY pp
     WHERE pp.policy_id = par_policy_id;
    Pkg_Impexp.update_pol_header(par_pol_header => v_Pol_Head_ID);*/
  END;

  PROCEDURE buy_stock(par_policy_id NUMBER) IS
    vs NUMBER;
    va NUMBER;
  BEGIN
    /*            for rc in (
    
                       select pc.start_date,
                               c.ext_id contact_id,
                               plo.ext_id stock_id,
                               sum(pc.premium) ins_sum
                         from as_asset           a,
                               p_cover            pc,
                               t_prod_line_option plo,
                               contact            c,
                               p_policy           p
                        where a.p_policy_id = par_policy_id
                          and pc.as_asset_id = a.as_asset_id
                          and plo.id = pc.t_prod_line_option_id
                          and plo.ext_id is not null
                          and c.contact_id = a.contact_id
                          and c.ext_id is not null
                          and p.policy_id = par_policy_id
                          and p.version_num = 1
                        group by pc.start_date, c.ext_id, plo.ext_id) loop
    
              trs.pkg_external.buy_stock(rc.start_date,
                                         rc.contact_id,
                                         rc.stock_id,
                                         rc.ins_sum,
                                         vs,
                                         va);
    
            end loop;
    */
    NULL;
  END;

  FUNCTION set_pol_version_order_num(par_policy_id IN NUMBER) RETURN NUMBER IS
    v_last_ver_num    NUMBER;
    v_pol_change_type VARCHAR2(100);
    v_ver_order_num   NUMBER;
    v_pol_header_id   NUMBER;
  BEGIN
  
    UPDATE ins.p_policy pol
       SET pol.version_order_num =
           (SELECT COUNT(*) + 1
              FROM ins.p_policy       c
                  ,ins.doc_status_ref dsr
                  ,ins.document       d
             WHERE c.pol_header_id = pol.pol_header_id
               AND c.version_num < pol.version_num
               AND c.t_pol_change_type_id = pol.t_pol_change_type_id
               AND c.policy_id = d.document_id
               AND dsr.doc_status_ref_id = d.doc_status_ref_id
               AND dsr.brief <> 'CANCEL')
     WHERE pol.t_pol_change_type_id IN (SELECT t.t_policy_change_type_id
                                          FROM ins.t_policy_change_type t
                                         WHERE t.brief = '��������')
       AND pol.policy_id = par_policy_id
    RETURNING version_order_num, pol_header_id INTO v_ver_order_num, v_pol_header_id;
  
    /*UPDATE (SELECT pol_header_id
                  ,policy_id
                  ,version_order_num
                  ,version_num
                  ,(SELECT COUNT(t_pol_change_type_id)
                      FROM t_policy_change_type ct
                          ,ven_p_policy         c
                          ,doc_status_ref       dsr
                     WHERE c.pol_header_id = b.pol_header_id
                       AND c.version_num < b.version_num
                       AND ct.t_policy_change_type_id = c.t_pol_change_type_id
                       AND ct.brief = '��������'
                       AND DSR.DOC_STATUS_REF_ID = C.DOC_STATUS_REF_ID
                       AND DSR.BRIEF <> 'CANCEL') qty
                  ,t_pol_change_type_id
                  ,ct.brief
              FROM t_policy_change_type ct
                  ,p_policy             b
             WHERE 1 = 1
               AND b.policy_id = par_policy_id
               AND ct.t_policy_change_type_id(+) = b.t_pol_change_type_id) a
       SET a.version_order_num = DECODE(a.brief
                                       ,'�����������'
                                       ,NULL
                                       ,'��������'
                                       ,qty + 1
                                       ,NULL)
    RETURNING version_order_num, pol_header_id INTO v_ver_order_num, v_pol_header_id;*/
  
    RETURN v_ver_order_num;
  END;

  PROCEDURE copy_assured_groups
  (
    p_new_pol_id NUMBER
   ,p_pol_id     NUMBER
  ) IS
    v_pol_assured_group_id NUMBER;
  BEGIN
    FOR v_ass_gr IN (SELECT * FROM p_pol_assured_group WHERE policy_id = p_pol_id)
    LOOP
      SELECT sq_p_pol_assured_group.nextval INTO v_pol_assured_group_id FROM dual;
      INSERT INTO ven_p_pol_assured_group
        (p_pol_assured_group_id, policy_id, assured_group_id)
      VALUES
        (v_pol_assured_group_id, p_new_pol_id, v_ass_gr.assured_group_id);
      UPDATE ven_as_assured
         SET pol_assured_group_id = v_pol_assured_group_id
       WHERE p_policy_id = p_new_pol_id
         AND pol_assured_group_id = v_ass_gr.p_pol_assured_group_id;
    END LOOP;
  END;

  FUNCTION new_policy_version
  (
    par_policy_id             IN NUMBER
   ,par_ver_num               IN NUMBER DEFAULT NULL
   ,par_version_status        IN VARCHAR2 DEFAULT 'PROJECT'
   ,par_change_id             NUMBER DEFAULT NULL
   ,par_start_date            IN DATE DEFAULT NULL
   ,par_end_date              IN DATE DEFAULT NULL
   ,par_confirm_date_addendum IN DATE DEFAULT NULL
   ,par_notice_date_addendum  IN DATE DEFAULT NULL
   ,par_policy_change_type_id IN NUMBER DEFAULT NULL
   ,par_note                  IN VARCHAR2 DEFAULT NULL
  ) RETURN NUMBER IS
    v_pol           ven_p_policy%ROWTYPE;
    v_asset         ven_as_asset%ROWTYPE;
    v_var           dms_ins_var%ROWTYPE;
    v_asset         ven_as_asset%ROWTYPE;
    v_stuff         ven_as_vehicle_stuff%ROWTYPE;
    v_old_stuff     NUMBER;
    v_new_stuff     NUMBER;
    v_var_id        NUMBER;
    v_product_brief VARCHAR2(1000);
    p_restoreation  NUMBER;
    v_par_policy_id NUMBER;
    p_name_role     VARCHAR2(100);
  
    PROCEDURE check_enable_new_version(p_policy_id IN NUMBER) IS
      v_last_version_status VARCHAR2(50);
    BEGIN
      v_last_version_status := get_last_version_status(p_policy_id);
    
      IF v_last_version_status IN ('�����')
      THEN
        raise_application_error(-20101
                               ,'��������� ������ �� ������ ���� � ������� "�����"!');
      END IF;
    END check_enable_new_version;
  
    FUNCTION check_create_restoreation(p_policy_id IN NUMBER) RETURN NUMBER IS
      v_last_version_status VARCHAR2(50);
      p_cnt_par             NUMBER := 0;
      -- p_cnt_flag number := 0;
      v_add_type PLS_INTEGER;
    BEGIN
    
      SELECT tat.t_addendum_type_id
        INTO v_add_type
        FROM t_addendum_type tat
       WHERE tat.brief = 'RECOVER_MAIN';
    
      IF pkg_p_pol_addendum_type.new_policy_is_add_type(p_policy_id, v_add_type) <> 1
      THEN
        RETURN 0;
      END IF;
    
      BEGIN
        SELECT u.name
          INTO p_name_role
          FROM ven_sys_role u
         WHERE u.sys_role_id = ins.safety.get_curr_role;
      EXCEPTION
        WHEN no_data_found THEN
          p_name_role := '';
      END;
      -- ������ �.
      -- �������� �������� ���� ����-��������
    
      IF safety.check_right_custom('CREATE_TECH_RENEW') != 1
         AND safety.check_right_custom('CREATE_MAIN_RENEW') != 1
      /*IF p_name_role NOT IN ('�����','���������� �� ������ ���������',
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    '�������������','���� - ��������','�������� ������������� ����������') */
      THEN
        pkg_forms_message.put_message('�������������� ����������. � ��� ��� ���� ��� ��������������.');
        RETURN(-1);
      END IF;
    
      v_last_version_status := doc.get_doc_status_brief(p_policy_id);
    
      /*--������ /183389: ��������� - ����������� �������������� �� ����� ������/
      if v_last_version_status not in ('READY_TO_CANCEL','BREAK',
                                     'QUIT','QUIT_TO_PAY',
                                     'QUIT_REQ_GET','QUIT_REQ_QUERY'
                                     -- ������ �.
                                     -- ������ �157229
                                     ,'CONCLUDED'
                                     )
      then
         PKG_FORMS_MESSAGE.put_message('�������������� ����������. ������� ������ ���� ����������');
         return(-1);
      END IF;*/
    
      /*     BEGIN
        SELECT COUNT(*)
          INTO p_cnt_par
          FROM p_policy         pp,
               t_decline_reason r
         WHERE pp.decline_reason_id = r.t_decline_reason_id
           AND r.brief = '�����������'
           AND pp.policy_id = p_policy_id; --1791927
      EXCEPTION
        WHEN no_data_found THEN
          PKG_FORMS_MESSAGE.put_message('�������������� �� ��������. ������� ��� ���������� �� �������� ������.');
          RETURN(-1);
      END;*/
    
      BEGIN
        SELECT COUNT(*)
          INTO p_cnt_par
          FROM p_policy        pp
              ,p_pol_header    ph
              ,t_product       prod
              ,t_payment_terms trm
         WHERE pp.policy_id = p_policy_id
           AND pp.pol_header_id = ph.policy_header_id
           AND prod.product_id = ph.product_id
           AND prod.brief IN ('END', 'END_Old', 'PEPR', 'PEPR_Old', 'CHI', 'CHI_Old')
           AND pp.payment_term_id = trm.id
           AND trm.brief IN ('EVERY_QUARTER', 'EVERY_YEAR', 'HALF_YEAR');
      EXCEPTION
        WHEN no_data_found THEN
          pkg_forms_message.put_message('�������������� �� ��������. ������� �� �������� ��� ������� ��������������.');
          RETURN(-1);
      END;
    
      /*     BEGIN
        SELECT COUNT(*)
          INTO p_cnt_par
          FROM as_asset            a,
               p_cover             pc,
               t_prod_line_option  opt,
               t_product_line      pl,
               t_product_line_type tl
         WHERE a.p_policy_id = p_policy_id
           AND a.as_asset_id = pc.as_asset_id
           AND pc.t_prod_line_option_id = opt.id
           AND opt.product_line_id = pl.id
           AND pl.product_line_type_id = tl.product_line_type_id
           AND tl.brief IN ('RECOMMENDED')
           AND (opt.description LIKE '%�������%' OR
               opt.description LIKE '%������%');
      EXCEPTION
        WHEN no_data_found THEN
          PKG_FORMS_MESSAGE.put_message('�������������� �� ��������. ������� �� �������� ��� ������� ��������������.');
          RETURN(-1);
      END;*/
    
      /* BEGIN
        SELECT extract(YEAR FROM SYSDATE) -
               extract(YEAR FROM
                       pkg_renlife_utils.First_unpaid(pp.pol_header_id, 2))
          INTO p_cnt_par
          FROM p_policy pp
         WHERE pp.policy_id = p_policy_id;
      EXCEPTION
        WHEN no_data_found THEN
          PKG_FORMS_MESSAGE.put_message('�������������� �� ��������. ������� �� �������� ��� ������� ��������������.');
          RETURN(-1);
      END;
      
      IF p_cnt_par BETWEEN 0 AND 2 THEN
         RETURN(1);
      ELSE
         PKG_FORMS_MESSAGE.put_message('�������������� �� ��������. ������� �� �������� ��� ������� ��������������.');
         RETURN(-1);
      END IF;*/
    
      RETURN 1;
    
    END check_create_restoreation;
  
  BEGIN
    -- TODO: ���������� �����, ���� ����� ��������� ��������� ������ � ������ par_version_status
    BEGIN
      utils.put('new_policy_version', 1);
    
      IF doc.get_doc_status_brief(par_policy_id) IN
         ('READY_TO_CANCEL'
         ,'BREAK'
         ,'QUIT'
         ,'QUIT_TO_PAY'
         ,'QUIT_REQ_GET'
         ,'QUIT_REQ_QUERY'
          -- ������ �.
          -- ������ �157229
          -- ��������� � ��������, ���� �������� ������� �� '������� ��������'
         ,'CONCLUDED')
      THEN
        flag_dont_check_status := 1;
      END IF;
    
      IF flag_dont_check_status <> 1
      THEN
        set_status(par_policy_id, par_version_status, 1);
      END IF;
    
      -- ������
      SELECT p.* INTO v_pol FROM ven_p_policy p WHERE p.policy_id = par_policy_id;
    
      check_enable_new_version(v_pol.pol_header_id);
    
      v_par_policy_id := par_policy_id;
    
      CASE check_create_restoreation(par_policy_id)
        WHEN 1 THEN
          DECLARE
            v_decline_date DATE;
            v_deleted      PLS_INTEGER;
          BEGIN
            v_decline_date := v_pol.decline_date;
            --��� �������������� ���������� ����������� � ������������� ������ ��
            SELECT pp1.*
              INTO v_pol
              FROM p_policy     pp
                  ,ven_p_policy pp1
             WHERE pp.policy_id = par_policy_id
               AND pp.pol_header_id = pp1.pol_header_id
               AND pp1.policy_id = pp.prev_ver_id;
          
            v_par_policy_id := v_pol.policy_id;
          
            v_pol.start_date := trunc(SYSDATE, 'DD') + 15;
          
            UPDATE ven_p_policy pp
               SET pp.start_date = par_start_date --v_pol.start_date
             WHERE pp.policy_id = par_policy_id;
            --������ ����� ����� ���� �����������
            FOR rc IN (SELECT ap.payment_id
                             ,ap.amount
                             ,dt.brief
                         FROM p_policy       p
                             ,ven_ac_payment ap
                             ,doc_doc        dd
                             ,doc_templ      dt
                        WHERE p.pol_header_id = v_pol.pol_header_id
                          AND dd.child_id = ap.payment_id
                          AND dd.parent_id = p.policy_id
                          AND dt.doc_templ_id = ap.doc_templ_id
                          AND dt.brief IN ('PAYMENT', 'PAYMENT_SETOFF_ACC')
                          AND ap.plan_date >= v_decline_date)
            LOOP
              v_deleted := pkg_payment.delete_payment(rc.payment_id, rc.brief, rc.amount);
            END LOOP;
            log(par_policy_id, 'v_pol.start_date: ' || v_pol.start_date);
          END;
        WHEN -1 THEN
          raise_application_error(-20015, '�������������� �� ��������');
        
        ELSE
          NULL;
      END CASE;
    
      v_pol.doc_status_id     := NULL;
      v_pol.doc_status_ref_id := NULL;
      v_pol.reg_date          := NULL;
    
      -- ����� �� ������
      SELECT sq_p_policy.nextval INTO v_pol.policy_id FROM dual;
      v_pol.version_order_num := NULL;
      --v_pol.confirm_date_addendum:= TRUNC(SYSDATE,'DD');
      v_pol.confirm_date_addendum := v_pol.start_date;
      v_pol.notice_date_addendum  := trunc(SYSDATE, 'DD');
      v_pol.ext_id                := NULL;
      -- ����� �/� ������
      -- todo: ������� �������� ���������� ������ �� p_pol_header
      -- ������, ��� ��� ������ ���. ���������� ���������� �������� �������
      IF (par_ver_num IS NOT NULL)
      THEN
        v_pol.version_num := par_ver_num;
      ELSE
        SELECT MAX(p.version_num) + 1
          INTO v_pol.version_num
          FROM p_policy p
         WHERE p.pol_header_id = v_pol.pol_header_id;
      END IF;
    
      /* ��� ���������� ��������� �������� ��������������� ���������� �� ������ �������� �����������
         �� ���������� �� ������ �������� ��� �������� ��� ��������������� ����������
      */
      log(v_par_policy_id
         ,'�� ���� ��������� ���. ����������: ' || par_policy_change_type_id);
    
      IF par_policy_change_type_id IS NOT NULL
      THEN
        v_pol.t_pol_change_type_id := par_policy_change_type_id;
      END IF;
    
      IF v_pol.t_pol_change_type_id IS NULL
      THEN
        IF par_version_status = 'PROJECT'
        THEN
          BEGIN
            SELECT t_policy_change_type_id
              INTO v_pol.t_pol_change_type_id
              FROM ven_t_policy_change_type
             WHERE (brief = '��������' AND par_change_id IS NULL)
                OR (t_policy_change_type_id = par_change_id AND par_change_id IS NOT NULL);
          EXCEPTION
            WHEN OTHERS THEN
              NULL;
          END;
        END IF;
      END IF;
    
      IF par_version_status = 'READY_TO_CANCEL'
      THEN
        BEGIN
          SELECT t_policy_change_type_id
            INTO v_pol.t_pol_change_type_id
            FROM ven_t_policy_change_type
           WHERE brief = '�����������';
        EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END;
      END IF;
    
      --������ ��������� ���� ����������� �� ��������� ����� ���������
      --���� ������ ��������� ����� �����. �� �����., �� ���� ��������  v_pol.start_date
      IF (par_start_date IS NOT NULL)
      THEN
        v_pol.start_date := par_start_date;
      ELSIF doc.get_doc_status_brief(par_policy_id) != 'QUIT_DECL'
      THEN
        v_pol.start_date := greatest(trunc(SYSDATE, 'dd'), v_pol.start_date);
      ELSE
        NULL;
      END IF;
    
      /*-- ��������
      IF par_start_date is NULL THEN
        v_pol.start_date := GREATEST(TRUNC(SYSDATE, 'dd'), v_pol.start_date) ;
      ELSE
        v_pol.start_date := par_start_date;
      END IF;*/
      --end_������ ��������� ���� ����������� �� ��������� ����� ���������
    
      -- ��������
      IF par_end_date IS NOT NULL
      THEN
        v_pol.end_date := par_end_date;
      END IF;
    
      -- ��������
      --������ 25.07.2011 93942 ��� �������� ����� ������ �� ������ ������������� ���������� �� ������
      IF par_note IS NOT NULL
      THEN
        v_pol.note := par_note;
      ELSE
        v_pol.note := NULL;
      END IF;
      --------------------------------------
    
      log(v_par_policy_id
         ,'���� ���������� � ���� ' || to_char(par_confirm_date_addendum, 'dd.mm.yyyy'));
      IF par_confirm_date_addendum IS NOT NULL
      THEN
        v_pol.confirm_date_addendum := par_confirm_date_addendum;
      END IF;
    
      log(v_par_policy_id
         ,'���� ���������� ' || to_char(par_notice_date_addendum, 'dd.mm.yyyy'));
      IF par_notice_date_addendum IS NOT NULL
      THEN
        v_pol.notice_date_addendum := par_notice_date_addendum;
      END IF;
    
      /*
        ������ �.
        ������ 179102. ���� � ������� ����������� �� ������ ������������
      */
      v_pol.decline_date      := NULL;
      v_pol.decline_reason_id := NULL;
    
      INSERT INTO ven_p_policy VALUES v_pol;
    
      /* ��� ���������� ��������� �������� ��������������� ���������� �� ������ �������� �����������
      �� ���������� �� ������ �������� ��� �������� ��� ��������������� ����������
      
      �������� ���������� �� ����� ��������������� ���������� */
    
      log(par_policy_id
         ,'�������� ���������� �� ����� ��������������� ���������� ');
      pkg_p_pol_addendum_type.create_pol_addendum_type(v_pol.policy_id, par_policy_id);
    
      log(v_par_policy_id
         ,'��������� ������ ������ ��������������� ���������� ');
      v_pol.version_order_num := set_pol_version_order_num(v_pol.policy_id);
    
      -- ��������� ��������
      pkg_doc_properties.copy_document_properties(par_old_document_id => v_par_policy_id
                                                 ,par_new_document_id => v_pol.policy_id);
    
      -- �������� ������� �� ��������
      pkg_asset.copy_as_asset(v_par_policy_id, v_pol.policy_id);
      pkg_asset.copy_insured(v_par_policy_id, v_pol.policy_id);
      pkg_asset.copy_as_assured_re(v_par_policy_id, v_pol.policy_id);
      -- ���������� ������ ��������������, ���� ��� ����. ����������� ����� ����������� ��������
      copy_assured_groups(v_pol.policy_id, v_par_policy_id);
    
      -- �������� �������� �� ��������
      INSERT INTO ven_p_policy_contact
        (contact_id, contact_policy_role_id, policy_id)
        SELECT p.contact_id
              ,p.contact_policy_role_id
              ,v_pol.policy_id
          FROM ven_p_policy_contact p
         WHERE p.policy_id = v_par_policy_id;
    
      -- ������
      log(v_par_policy_id
         ,'�������� �������� ����� ������ ' || par_version_status);
    
      IF par_start_date IS NULL
      THEN
        doc.set_doc_status(v_pol.policy_id, par_version_status);
      ELSE
        doc.set_doc_status(v_pol.policy_id, par_version_status, par_start_date);
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        -- ������ �.
        -- �������� ����� ������ � ���������
        pkg_forms_message.put_message('���������� ������� ����� ������ �� �������: ' || SQLERRM);
        raise_application_error(-20000
                               ,'���������� ������� ����� ������ �� �������: ' || SQLERRM);
    END;
    RETURN v_pol.policy_id;
  END;

  PROCEDURE init_decline_parameters(par_policy_id NUMBER) IS
    v_policy p_policy%ROWTYPE;
  BEGIN
    SELECT * INTO v_policy FROM p_policy WHERE policy_id = par_policy_id;
  
    SELECT *
      INTO v_policy.decline_initiator_id
      FROM (SELECT pc.contact_id
              FROM p_policy_contact   pc
                  ,t_contact_pol_role cpr
             WHERE pc.policy_id = par_policy_id
               AND pc.contact_policy_role_id = cpr.id
               AND cpr.brief = '������������')
     WHERE rownum = 1;
  
    SELECT dr.t_decline_reason_id
      INTO v_policy.decline_reason_id
      FROM t_decline_reason dr
     WHERE dr.brief = '����';
  
    UPDATE p_policy p
       SET p.decline_initiator_id = v_policy.decline_initiator_id
          ,p.decline_reason_id    = v_policy.decline_reason_id
     WHERE p.policy_id = par_policy_id;
  END;

  FUNCTION get_curr_policy(p_pol_header_id IN NUMBER) RETURN NUMBER IS
    v_active_policy_id NUMBER;
  BEGIN
    SELECT p.policy_id
      INTO v_active_policy_id
      FROM p_pol_header p
     WHERE p.policy_header_id = p_pol_header_id;
    RETURN v_active_policy_id;
  END;

  FUNCTION get_deduct_name(par_cover_id IN NUMBER) RETURN VARCHAR2 IS
    v_ret VARCHAR2(150);
  BEGIN
    SELECT dt.description || ' ' || CASE
             WHEN dt.description <> '���' THEN
              pc.deductible_value ||
              decode(dvt.description, '�������', '%', '���������� ����', ' ��.')
             ELSE
              NULL
           END
      INTO v_ret
      FROM p_cover           pc
          ,t_deductible_type dt
          ,t_deduct_val_type dvt
     WHERE dt.id(+) = pc.t_deductible_type_id
       AND pc.p_cover_id = par_cover_id
       AND dvt.id(+) = pc.t_deduct_val_type_id;
    RETURN v_ret;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  /*
    ����� �.
    10.06.2014
    ��������� ��������� ��������� ������� �������� �����������
  */
  FUNCTION get_custom_policy_calc_func_id(par_policy_id p_policy.policy_id%TYPE)
    RETURN t_product.custom_policy_calc_func_id%TYPE IS
    v_custom_policy_calc_func_id t_product.custom_policy_calc_func_id%TYPE;
  BEGIN
    SELECT p.custom_policy_calc_func_id
      INTO v_custom_policy_calc_func_id
      FROM t_product    p
          ,p_pol_header ph
          ,p_policy     pp
     WHERE p.product_id = ph.product_id
       AND ph.policy_header_id = pp.pol_header_id
       AND pp.policy_id = par_policy_id;
  
    RETURN v_custom_policy_calc_func_id;
  EXCEPTION
    WHEN no_data_found THEN
      ex.raise(par_message => '�� ������� ���������� ������� ������� �������� �����������');
  END get_custom_policy_calc_func_id;

  /*
    ����� �.
    �������� �������� "������ ����" �� ��������
    ����������� ��� ��������� ��������� ���������� ���������
    �� 10.06.2014: �������� - ������� ������ ����� ����������� ��������� � ��������� "������ ����"
  */
  FUNCTION is_handchange_policy(par_policy_id p_policy.policy_id%TYPE) RETURN BOOLEAN IS
    v_is_handchange_policy BOOLEAN := FALSE;
    FUNCTION handchange_cover_exists(par_policy_id p_policy.policy_id%TYPE) RETURN BOOLEAN IS
      v_exists NUMBER(1);
    BEGIN
      SELECT COUNT(1)
        INTO v_exists
        FROM dual
       WHERE EXISTS
       (SELECT NULL
                FROM as_asset aa
                    ,p_cover  pc
               WHERE aa.p_policy_id = par_policy_id
                 AND pc.as_asset_id = aa.as_asset_id
                 AND aa.status_hist_id IN (pkg_asset.status_hist_id_new, pkg_asset.status_hist_id_curr)
                 AND pc.status_hist_id IN (pkg_cover.status_hist_id_new, pkg_cover.status_hist_id_curr)
                 AND pc.is_handchange_amount = 1);
      RETURN v_exists = 1;
    END handchange_cover_exists;
  BEGIN
    IF get_custom_policy_calc_func_id(par_policy_id => par_policy_id) IS NOT NULL
    THEN
      v_is_handchange_policy := handchange_cover_exists(par_policy_id);
    END IF;
  
    RETURN v_is_handchange_policy;
  END is_handchange_policy;

  PROCEDURE update_policy_sum
  (
    p_p_policy_id IN NUMBER
   ,p_premium     OUT NUMBER
   ,p_ins_amount  OUT NUMBER
  ) IS
    v_premium              p_policy.premium%TYPE := 0;
    v_ins_amount           p_policy.ins_amount%TYPE := 0;
    v_premium_temp         NUMBER;
    v_ins_amount_temp      NUMBER;
    v_ins_amount_func_id   NUMBER;
    v_pol_type             VARCHAR2(30);
    v_ins_amount_func_name t_prod_coef_type.name%TYPE;
  
    /*
        PROCEDURE recalc_policy(par_policy_id p_policy.policy_id%TYPE) IS
          v_custom_policy_calc_func_id t_product.custom_policy_calc_func_id%TYPE;
          v_policy_ent_id entity.ent_id%type;
        BEGIN
    
          SELECT p.custom_policy_calc_func_id
            INTO v_custom_policy_calc_func_id
            FROM t_product    p
                ,p_pol_header ph
                ,p_policy     pp
           WHERE p.product_id = ph.product_id
             AND ph.policy_header_id = pp.pol_header_id
             AND pp.policy_id = par_policy_id;
    
          IF v_custom_policy_calc_func_id IS NULL
          THEN
            -- ����������� �������� �������� �����������, ���� �� ������� ����������� ������� ��� �����
            pkg_policy_calc_procedure.standard_calc(par_policy_id => par_policy_id);
          ELSE
            -- ����� ����������� ������� ��������� �������� �����������
            v_policy_ent_id := ent.id_by_brief('P_POLICY');
            pkg_tariff_calc.run_procedure(par_prodedure_id => v_custom_policy_calc_func_id
                                         ,par_end_id       => v_policy_ent_id
                                         ,par_obj_id       => par_policy_id);
          END IF;
        END recalc_policy;
    */
  
    PROCEDURE recalc_policy(par_policy_id p_policy.policy_id%TYPE) IS
      v_custom_policy_calc_func_id t_product.custom_policy_calc_func_id%TYPE;
      v_policy_ent_id              entity.ent_id%TYPE;
    BEGIN
    
      v_custom_policy_calc_func_id := get_custom_policy_calc_func_id(par_policy_id => par_policy_id);
    
      IF v_custom_policy_calc_func_id IS NULL
      THEN
        -- ����������� �������� �������� �����������, ���� �� ������� ����������� ������� ��� �����
        pkg_policy_calc_procedure.standard_calc(par_policy_id => par_policy_id);
      ELSIF NOT is_handchange_policy(par_policy_id => par_policy_id)
      THEN
        -- ����� ����������� ������� ��������� �������� �����������
        v_policy_ent_id := ent.id_by_brief('P_POLICY');
        pkg_tariff_calc.run_procedure(par_prodedure_id => v_custom_policy_calc_func_id
                                     ,par_end_id       => v_policy_ent_id
                                     ,par_obj_id       => par_policy_id);
      END IF;
    END recalc_policy;
  
  BEGIN
    IF p_p_policy_id IS NULL
    THEN
      RETURN;
    END IF;
  
    -- ������������� ������� �����������
    recalc_policy(par_policy_id => p_p_policy_id);
  
    FOR rec IN (SELECT a.as_asset_id
                  FROM as_asset    a
                      ,status_hist sh
                 WHERE a.p_policy_id = p_p_policy_id
                   AND a.status_hist_id = sh.status_hist_id
                   AND sh.brief IN ('NEW', 'CURRENT'))
    LOOP
      pkg_asset.update_asset_summary(par_as_asset_id => rec.as_asset_id
                                    ,par_premium     => v_premium_temp
                                    ,par_ins_amount  => v_ins_amount_temp);
    
      v_premium    := v_premium + nvl(v_premium_temp, 0);
      v_ins_amount := v_ins_amount + nvl(v_ins_amount_temp, 0);
    END LOOP;
  
    SELECT tp.ins_amount_func_id
          ,(SELECT pct.name
             FROM t_prod_coef_type pct
            WHERE pct.t_prod_coef_type_id = tp.ins_amount_func_id)
      INTO v_ins_amount_func_id
          ,v_ins_amount_func_name
      FROM t_product    tp
          ,p_pol_header ph
          ,p_policy     pp
     WHERE pp.policy_id = p_p_policy_id
       AND ph.policy_header_id = pp.pol_header_id
       AND tp.product_id = ph.product_id;
  
    IF v_ins_amount_func_id IS NOT NULL
    THEN
      BEGIN
        v_ins_amount := pkg_tariff_calc.calc_fun(v_ins_amount_func_id
                                                ,ent.id_by_brief('P_POLICY')
                                                ,p_p_policy_id);
      EXCEPTION
        WHEN OTHERS THEN
          raise_application_error(-20001
                                 ,'������ ��� ���������� ����������� ������� (' ||
                                  v_ins_amount_func_name || ') ������� �� �� �������� ����������� ');
      END;
    END IF;
  
    UPDATE p_policy p
       SET p.premium    = v_premium
          ,p.ins_amount = v_ins_amount
     WHERE p.policy_id = p_p_policy_id
    RETURNING p.premium, p.ins_amount INTO p_premium, p_ins_amount;
  END;

  PROCEDURE update_policy_sum(p_p_policy_id IN NUMBER) IS
    v_premium    NUMBER;
    v_ins_amount NUMBER;
  BEGIN
    update_policy_sum(p_p_policy_id, v_premium, v_ins_amount);
    --null;
  END;

  /**
  * ������� ������ ������ �� �������� �����
  * @author Denis Ivanov
  * @param p_policy_id �� ������
  */
  PROCEDURE new_policy_delete(p_policy_id NUMBER) IS
    v_pol_header_id NUMBER;
    v_version_num   NUMBER;
  BEGIN
    -- ������ �.
    -- ������ 245177
    DELETE FROM as_assured_re WHERE p_policy_id = new_policy_delete.p_policy_id;
  
    -- ������� �����, ������������ �� ���� ������ ������
    DELETE FROM ven_ac_payment pmnt
     WHERE pmnt.payment_id IN (SELECT ap.payment_id
                                 FROM ac_payment ap
                                     ,doc_doc    dd
                                WHERE dd.child_id = ap.payment_id
                                  AND dd.parent_id = p_policy_id);
  
    /* ������ �.
       ������ ��������� ������ � ��������� �� ����������
    */
    SELECT pp.prev_ver_id
          ,pp.pol_header_id
      INTO v_version_num
          ,v_pol_header_id
      FROM p_policy pp
     WHERE pp.policy_id = p_policy_id;
  
    UPDATE p_pol_header ph
       SET ph.last_ver_id =
           (SELECT pp.policy_id
              FROM p_policy pp
             WHERE pp.pol_header_id = v_pol_header_id
               AND pp.policy_id = v_version_num)
     WHERE ph.policy_header_id = v_pol_header_id;
    -- ������� ����� ������ � ����������
    DELETE FROM ven_p_policy p WHERE p.policy_id = p_policy_id;
    -- todo: ������� p_asset_header - � � ������� ��� as_asset
  END;

  /**
  * ��������� ����������� ������ ������ ��������
  * @author Denis Ivanov
  * @param p_policy_id �� ������
  * @throw ������ �������� � ���������� ������, ���� ����������
  */
  PROCEDURE check_enable_pol_cancelation(par_policy_id NUMBER) IS
    v_count_dso NUMBER;
  BEGIN
    /*    IF is_addendum(par_policy_id) = 1
    THEN
      RETURN;
    END IF;*/
    --�������� �.�.
    --265765
    SELECT COUNT(dso.doc_set_off_id)
      INTO v_count_dso
      FROM ins.ac_payment     ap
          ,ins.doc_doc        dd
          ,ins.doc_set_off    dso
          ,ins.document       d
          ,ins.doc_status_ref rf
     WHERE dd.child_id = ap.payment_id
       AND dd.parent_id = par_policy_id
       AND dso.parent_doc_id = ap.payment_id
       AND dso.doc_set_off_id = d.document_id
       AND d.doc_status_ref_id = rf.doc_status_ref_id
       AND rf.brief != 'ANNULATED';
    IF (v_count_dso > 0)
    THEN
      raise_application_error(-20000
                             ,'� ���������� ������ �������� ����������� ���� ��������� ����� (������������). ������� �������� �����.');
    END IF;
  END;

  /*
    �����������
    ������ �.
  */
  PROCEDURE storno_transactions(par_policy_id NUMBER) IS
    v_policy p_policy%ROWTYPE;
  BEGIN
    IF is_addendum(par_policy_id) = 0
    THEN
      FOR vr_oper IN (SELECT op.oper_id
                        FROM oper op
                       WHERE op.document_id = par_policy_id
                      UNION ALL
                      SELECT op.oper_id
                        FROM oper op
                       WHERE op.document_id IN (SELECT ap.payment_id
                                                  FROM ac_payment ap
                                                      ,doc_doc    dd
                                                 WHERE dd.child_id = ap.payment_id
                                                   AND dd.parent_id = par_policy_id))
      LOOP
        acc_new.storno_trans(par_oper_id => vr_oper.oper_id);
      END LOOP;
    
      FOR rec IN (SELECT ap.payment_id
                    FROM ac_payment     ap
                        ,doc_doc        dd
                        ,document       d
                        ,doc_status_ref dsr
                   WHERE dd.child_id = ap.payment_id
                     AND d.document_id = ap.payment_id --������ 164726 �� ���������� ��� � ������ ������� �� ������� �����������
                     AND d.doc_status_ref_id = dsr.doc_status_ref_id
                     AND dsr.brief <> 'ANNULATED'
                     AND dd.parent_id = par_policy_id)
      LOOP
        doc.set_doc_status(rec.payment_id, 'CANCEL');
      END LOOP;
    
    END IF;
  END storno_transactions;

  /*������������� �������� �� ����� ���������� ������*/
  PROCEDURE storno_trans_cancel(par_policy_id NUMBER) IS
    v_policy p_policy%ROWTYPE;
  BEGIN
  
    FOR cur_oper IN (SELECT /*+ leading (t) NO_MERGE(t) */
                      t.oper_id
                     ,t.document_id
                     ,t.trans_templ_id
                     ,t.oper_templ_id
                     ,t.dt_account_id
                     ,t.ct_account_id
                       FROM ( -- ��������� � ������� ����� ���������
                             SELECT op.oper_id
                                    ,op.document_id
                                    ,tr.trans_templ_id
                                    ,op.oper_templ_id
                                    ,tr.dt_account_id
                                    ,tr.ct_account_id
                               FROM trans tr
                                    ,oper  op
                              WHERE tr.oper_id = op.oper_id
                                AND tr.a2_dt_ure_id = 283
                                AND tr.a2_dt_uro_id = par_policy_id --pp.policy_id
                             UNION
                             -- ��������� � ������� ����� ��������
                             SELECT op.oper_id
                                    ,op.document_id
                                    ,tr.trans_templ_id
                                    ,op.oper_templ_id
                                    ,tr.dt_account_id
                                    ,tr.ct_account_id
                               FROM trans tr
                                    ,oper  op
                              WHERE tr.oper_id = op.oper_id
                                AND op.document_id = par_policy_id
                             UNION
                             -- ��������� � ������� ����� ��������
                             SELECT op.oper_id
                                    ,op.document_id
                                    ,tr.trans_templ_id
                                    ,op.oper_templ_id
                                    ,tr.dt_account_id
                                    ,tr.ct_account_id
                               FROM trans    tr
                                    ,oper     op
                                    ,p_cover  pc
                                    ,as_asset se
                              WHERE tr.oper_id = op.oper_id
                                AND tr.a3_dt_ure_id = 305
                                AND tr.a3_dt_uro_id = pc.p_cover_id
                                AND pc.as_asset_id = se.as_asset_id
                                AND se.p_policy_id = par_policy_id
                             UNION
                             SELECT op.oper_id
                                    ,op.document_id
                                    ,tr.trans_templ_id
                                    ,op.oper_templ_id
                                    ,tr.dt_account_id
                                    ,tr.ct_account_id
                               FROM trans    tr
                                    ,oper     op
                                    ,p_cover  pc
                                    ,as_asset se
                              WHERE tr.oper_id = op.oper_id
                                AND tr.a4_dt_ure_id = 305
                                AND tr.a4_dt_uro_id = pc.p_cover_id
                                AND pc.as_asset_id = se.as_asset_id
                                AND se.p_policy_id = par_policy_id
                             UNION
                             -- ��������� � ������� ����� ������
                             SELECT op.oper_id
                                    ,op.document_id
                                    ,tr.trans_templ_id
                                    ,op.oper_templ_id
                                    ,tr.dt_account_id
                                    ,tr.ct_account_id
                               FROM trans     tr
                                    ,oper      op
                                    ,doc_doc   dd
                                    ,document  dc
                                    ,doc_templ dt
                              WHERE tr.oper_id = op.oper_id
                                AND op.document_id = dc.document_id
                                AND dc.doc_templ_id = dt.doc_templ_id
                                AND dt.brief = 'PAYMENT'
                                AND dc.document_id = dd.child_id
                                AND dd.parent_id = par_policy_id
                             -- ��������� � ������� ����� ��������� ���������
                             UNION
                             SELECT op.oper_id
                                    ,op.document_id
                                    ,tr.trans_templ_id
                                    ,op.oper_templ_id
                                    ,tr.dt_account_id
                                    ,tr.ct_account_id
                               FROM trans       tr
                                    ,oper        op
                                    ,doc_doc     dd
                                    ,document    dc
                                    ,doc_templ   dt
                                    ,doc_set_off dso
                              WHERE dd.parent_id = par_policy_id
                                AND dd.child_id = dc.document_id
                                AND dc.doc_templ_id = dt.doc_templ_id
                                AND dt.brief = 'PAYMENT'
                                AND dd.child_id = dso.parent_doc_id
                                AND dso.child_doc_id = op.document_id
                                AND tr.oper_id = op.oper_id
                             -- ��������� ����� �����
                             UNION
                             SELECT op.oper_id
                                    ,op.document_id
                                    ,tr.trans_templ_id
                                    ,op.oper_templ_id
                                    ,tr.dt_account_id
                                    ,tr.ct_account_id
                               FROM trans       tr
                                    ,oper        op
                                    ,doc_doc     dd
                                    ,document    dc
                                    ,doc_templ   dt
                                    ,doc_set_off dso
                              WHERE dd.parent_id = par_policy_id
                                AND dd.child_id = dc.document_id
                                AND dc.doc_templ_id = dt.doc_templ_id
                                AND dt.brief = 'PAYMENT'
                                AND dd.child_id = dso.parent_doc_id
                                AND dso.doc_set_off_id = op.document_id
                                AND tr.oper_id = op.oper_id
                             -- ��������� ����� ����� �7/��4 � �.�.
                             UNION
                             SELECT op.oper_id
                                    ,op.document_id
                                    ,tr.trans_templ_id
                                    ,op.oper_templ_id
                                    ,tr.dt_account_id
                                    ,tr.ct_account_id
                               FROM trans       tr
                                    ,oper        op
                                    ,doc_doc     dd
                                    ,document    dc
                                    ,doc_templ   dt
                                    ,doc_set_off dso
                                    ,doc_doc     dd2
                              WHERE dd.parent_id = par_policy_id
                                AND dd.child_id = dc.document_id
                                AND dc.doc_templ_id = dt.doc_templ_id
                                AND dt.brief = 'PAYMENT'
                                AND dd.child_id = dso.parent_doc_id
                                AND dso.child_doc_id = dd2.parent_id
                                AND dd2.child_id = op.document_id
                                AND tr.oper_id = op.oper_id
                             -- ����� �� �� �����
                             UNION
                             SELECT op.oper_id
                                    ,op.document_id
                                    ,tr.trans_templ_id
                                    ,op.oper_templ_id
                                    ,tr.dt_account_id
                                    ,tr.ct_account_id
                               FROM trans       tr
                                    ,oper        op
                                    ,doc_doc     dd
                                    ,document    dc
                                    ,doc_templ   dt
                                    ,doc_set_off dso
                                    ,doc_doc     dd2
                                    ,doc_set_off dso2
                              WHERE dd.parent_id = par_policy_id
                                AND dd.child_id = dc.document_id
                                AND dc.doc_templ_id = dt.doc_templ_id
                                AND dt.brief = 'PAYMENT'
                                AND dd.child_id = dso.parent_doc_id
                                AND dso.child_doc_id = dd2.parent_id
                                AND dd2.child_id = dso2.parent_doc_id
                                AND dso2.doc_set_off_id = op.document_id
                                AND tr.oper_id = op.oper_id) t
                           ,trans_templ tt
                           ,oper_templ ot
                           ,account dt
                           ,account ct
                      WHERE t.trans_templ_id = tt.trans_templ_id
                        AND t.oper_templ_id = ot.oper_templ_id
                        AND t.dt_account_id = dt.account_id
                        AND t.ct_account_id = ct.account_id)
    LOOP
      ins.acc_new.storno_trans(cur_oper.oper_id);
    END LOOP;
  
  END;

  -- TODO: ���������� � ������ ������������ ������ ��������
  FUNCTION get_active_policy(p_p_pol_header_id NUMBER) RETURN NUMBER IS
    v_policy_id      NUMBER;
    v_prev_policy_id NUMBER;
    v_status         VARCHAR(30);
    v_version_num    NUMBER;
    v_ret_val        NUMBER;
  BEGIN
    SELECT *
      INTO v_policy_id
          ,v_version_num
          ,v_status
          ,v_prev_policy_id
      FROM (SELECT t.policy_id
                  ,t.version_num
                  ,t.status
                  ,lead(t.policy_id, 1) over(ORDER BY t.version_num DESC)
              FROM (SELECT p.policy_id
                          ,p.version_num
                          ,doc.get_last_doc_status_brief(p.policy_id) status
                      FROM p_policy p
                     WHERE p.pol_header_id = p_p_pol_header_id) t
            --where t.status in ('NEW','PROJECT', 'CURRENT', 'BREAK')
             ORDER BY t.version_num DESC)
     WHERE rownum = 1;
  
    IF (v_status = 'PROJECT' AND v_prev_policy_id IS NULL)
    THEN
      v_ret_val := v_policy_id;
    ELSIF (v_status = 'PROJECT' AND v_prev_policy_id IS NOT NULL)
    THEN
      v_ret_val := v_prev_policy_id;
    ELSE
      v_ret_val := v_policy_id;
    END IF;
    RETURN v_ret_val;
  END;

  /**
  * �������� ����������� ������ �� �������� �� ����
  * @author ����� �.
  */
  FUNCTION get_active_policy_by_date
  (
    par_pol_header_id p_pol_header.policy_header_id%TYPE
   ,par_date          DATE
  ) RETURN p_policy.policy_id%TYPE IS
    v_policy_id p_policy.policy_id%TYPE;
  BEGIN
    SELECT MAX(pp.policy_id) keep(dense_rank FIRST ORDER BY start_date DESC, pp.policy_id DESC)
      INTO v_policy_id
      FROM p_policy       pp
          ,document       d
          ,doc_status_ref dsr
     WHERE pp.pol_header_id = par_pol_header_id
       AND pp.start_date <= par_date
       AND pp.policy_id = d.document_id
       AND d.doc_status_ref_id = dsr.doc_status_ref_id
       AND dsr.brief NOT IN ('PROJECT', 'CANCEL');
  
    RETURN v_policy_id;
  END get_active_policy_by_date;

  PROCEDURE policy_update
  (
    p_pol_id               IN NUMBER
   ,p_product_id           IN NUMBER
   ,p_sales_channel_id     IN NUMBER
   ,p_company_tree_id      IN NUMBER
   ,p_fund_id              IN NUMBER
   ,p_fund_pay_id          IN NUMBER
   ,p_confirm_condition_id IN NUMBER
   ,p_pol_ser              IN VARCHAR2
   ,p_pol_num              IN VARCHAR2
   ,p_notice_date          IN DATE
   ,p_sign_date            IN DATE
   ,p_confirm_date         IN DATE
   ,p_header_start_date    IN DATE
   ,p_policy_start_date    IN DATE
   ,p_end_date             IN DATE
   ,p_first_pay_date       IN DATE
   ,p_payment_term_id      IN NUMBER
   ,p_period_id            IN NUMBER
   ,p_agent_id_1           IN NUMBER
   ,p_agent_id_2           IN NUMBER
   ,p_curator_id           IN NUMBER
   ,p_issuer_id            IN NUMBER
   ,p_osago_sign_ser       IN VARCHAR2
   ,p_osago_sign_num       IN VARCHAR2
   ,p_prev_event_count     IN NUMBER
   ,p_fee_payment_term     IN NUMBER
   ,p_beneficiary_id       IN NUMBER
   ,p_fact_j               IN NUMBER
   ,p_ag_contract_id_1     IN NUMBER
   ,p_ag_contract_id_2     IN NUMBER
   ,p_admin_cost           IN NUMBER
   ,p_is_park              IN NUMBER DEFAULT 0
   ,p_is_group_flag        IN NUMBER DEFAULT NULL
   ,p_notice_num           IN VARCHAR2 DEFAULT NULL
   ,p_waiting_period_id    IN NUMBER DEFAULT NULL
   ,p_sales_action_id      IN NUMBER DEFAULT NULL
   ,p_region_id            IN NUMBER DEFAULT NULL
   ,p_office_manager_id    IN NUMBER DEFAULT NULL
   ,p_region_manager_id    IN NUMBER DEFAULT NULL
   ,p_discount_f_id        IN NUMBER DEFAULT NULL
   ,p_description          IN VARCHAR2 DEFAULT NULL
   ,p_paymentoff_term_id   IN NUMBER DEFAULT NULL
   ,p_ph_description       IN VARCHAR2 DEFAULT NULL
   ,p_payment_start_date   IN DATE DEFAULT NULL
   ,p_privilege_period     IN NUMBER DEFAULT NULL
   ,p_issuer_agent_id      IN NUMBER DEFAULT NULL
   ,p_mailing              IN NUMBER DEFAULT 0
   ,p_product_conds_id     IN NUMBER DEFAULT NULL
   ,p_base_sum             IN NUMBER DEFAULT NULL
   ,p_is_credit            IN NUMBER DEFAULT NULL
  ) IS
    v_pol_head_id       NUMBER;
    v_active_policy_id  NUMBER;
    v_version_order_num NUMBER;
  BEGIN
    SELECT pp.pol_header_id INTO v_pol_head_id FROM p_policy pp WHERE pp.policy_id = p_pol_id;
    UPDATE document d
       SET d.num = decode(p_pol_ser
                         ,NULL
                         ,decode(p_pol_num, NULL, '-', p_pol_num)
                         ,decode(p_pol_num, NULL, p_pol_ser, p_pol_ser || '-' || p_pol_num))
     WHERE d.document_id = v_pol_head_id;
  
    -- v_active_policy_id := get_active_policy(v_Pol_Head_ID);
  
    /* Formatted on 2008/04/18 18:03 (Formatter Plus v4.8.8) */
    UPDATE p_pol_header p
       SET (product_id
          ,sales_channel_id
          ,company_tree_id
          ,fund_id
          ,fund_pay_id
          ,confirm_condition_id
          , /*policy_id,*/prev_event_count
          ,start_date
          ,ag_contract_1_id
          ,ag_contract_2_id
          ,is_park
          ,description) =
           (SELECT p_product_id
                  ,p_sales_channel_id
                  ,p_company_tree_id
                  ,p_fund_id
                  ,p_fund_pay_id
                  ,p_confirm_condition_id
                  ,
                   
                   --v_active_policy_id,
                   p_prev_event_count
                  ,p_header_start_date
                  ,p_ag_contract_id_1
                  ,p_ag_contract_id_2
                  ,p_is_park
                  ,p_ph_description
              FROM dual)
     WHERE p.policy_header_id = v_pol_head_id;
  
    UPDATE document d
       SET d.num = decode(p_pol_ser
                         ,NULL
                         ,decode(p_pol_num, NULL, '-', p_pol_num)
                         ,decode(p_pol_num, NULL, p_pol_ser, p_pol_ser || '-' || p_pol_num))
     WHERE d.document_id = p_pol_id;
  
    UPDATE p_policy p
       SET (pol_ser
          ,pol_num
          ,notice_date
          ,sign_date
          ,start_date
          ,confirm_date
          ,end_date
          ,first_pay_date
          ,payment_term_id
          ,period_id
          ,osago_sign_ser
          ,osago_sign_num
          ,fee_payment_term
          ,fact_j
          ,admin_cost
          ,is_group_flag
          ,notice_num
          ,waiting_period_id
          ,sales_action_id
          ,region_id
          ,discount_f_id
          ,description
          ,paymentoff_term_id
          ,payment_start_date
          ,pol_privilege_period_id
          ,mailing
          ,t_product_conds_id
          ,base_sum
          ,is_credit) =
           (SELECT p_pol_ser
                  ,p_pol_num
                  ,p_notice_date
                  ,p_sign_date
                  ,p_policy_start_date
                  ,p_confirm_date
                  ,p_end_date
                  ,p_first_pay_date
                  ,p_payment_term_id
                  ,p_period_id
                  ,p_osago_sign_ser
                  ,p_osago_sign_num
                  ,p_fee_payment_term
                  ,p_fact_j
                  ,p_admin_cost
                  ,p_is_group_flag
                  ,p_notice_num
                  ,p_waiting_period_id
                  ,p_sales_action_id
                  ,p_region_id
                  ,p_discount_f_id
                  ,p_description
                  ,p_paymentoff_term_id
                  ,p_payment_start_date
                  ,p_privilege_period
                  ,p_mailing
                  ,p_product_conds_id
                  ,p_base_sum
                  ,p_is_credit
              FROM dual)
     WHERE p.policy_id = p_pol_id;
  
    -- Rebuild addendum number
    v_version_order_num := set_pol_version_order_num(p_pol_id);
  
    UPDATE p_policy_contact p
       SET p.contact_id = p_issuer_id
     WHERE p.policy_id = p_pol_id
       AND contact_policy_role_id =
           (SELECT t.id FROM t_contact_pol_role t WHERE t.brief = '������������');
    IF p_office_manager_id IS NULL
    THEN
      DELETE FROM p_policy_contact
       WHERE policy_id = p_pol_id
         AND contact_policy_role_id =
             (SELECT t.id FROM t_contact_pol_role t WHERE t.brief = '������������');
    ELSE
      UPDATE p_policy_contact p
         SET p.contact_id = p_office_manager_id
       WHERE p.policy_id = p_pol_id
         AND contact_policy_role_id =
             (SELECT t.id FROM t_contact_pol_role t WHERE t.brief = '������������');
      IF SQL%ROWCOUNT = 0
      THEN
        INSERT INTO ven_p_policy_contact
          (policy_id, contact_id, contact_policy_role_id)
          SELECT p_pol_id
                ,p_office_manager_id
                ,t.id
            FROM ven_t_contact_pol_role t
           WHERE t.brief = '������������';
      END IF;
    END IF;
    IF p_region_manager_id IS NULL
    THEN
      DELETE FROM p_policy_contact
       WHERE policy_id = p_pol_id
         AND contact_policy_role_id =
             (SELECT t.id FROM t_contact_pol_role t WHERE t.brief = '�����������');
    ELSE
      UPDATE p_policy_contact p
         SET p.contact_id = p_region_manager_id
       WHERE p.policy_id = p_pol_id
         AND contact_policy_role_id =
             (SELECT t.id FROM t_contact_pol_role t WHERE t.brief = '�����������');
      IF SQL%ROWCOUNT = 0
      THEN
        INSERT INTO ven_p_policy_contact
          (policy_id, contact_id, contact_policy_role_id)
          SELECT p_pol_id
                ,p_region_manager_id
                ,t.id
            FROM ven_t_contact_pol_role t
           WHERE t.brief = '�����������';
      END IF;
    END IF;
  
    IF p_issuer_agent_id IS NULL
    THEN
      DELETE FROM p_policy_contact
       WHERE policy_id = p_pol_id
         AND contact_policy_role_id =
             (SELECT t.id
                FROM t_contact_pol_role t
               WHERE t.brief = '������������� ������������');
    ELSE
      UPDATE p_policy_contact p
         SET p.contact_id = p_issuer_agent_id
       WHERE p.policy_id = p_pol_id
         AND contact_policy_role_id =
             (SELECT t.id
                FROM t_contact_pol_role t
               WHERE t.brief = '������������� ������������');
      IF SQL%ROWCOUNT = 0
      THEN
        INSERT INTO ven_p_policy_contact
          (policy_id, contact_id, contact_policy_role_id)
          SELECT p_pol_id
                ,p_issuer_agent_id
                ,t.id
            FROM ven_t_contact_pol_role t
           WHERE t.brief = '������������� ������������';
      END IF;
    END IF;
    -- declare
    --v_ag_id  number;
    --v_old_ag number;
    BEGIN
      FOR v_c IN (SELECT p.id
                        ,p.contact_id
                  --        into v_ag_id, v_old_ag
                    FROM p_policy_contact p
                   WHERE p.policy_id = p_pol_id
                     AND contact_policy_role_id =
                         (SELECT t.id FROM t_contact_pol_role t WHERE t.brief = '�����'))
      LOOP
        IF p_agent_id_1 IS NULL
        THEN
          DELETE FROM p_policy_contact p WHERE p.id = v_c.id;
          pkg_cover.unlink_policy_agent(p_pol_id, v_c.contact_id);
        ELSE
          UPDATE p_policy_contact p
             SET p.contact_id = p_agent_id_1
           WHERE p.policy_id = p_pol_id
             AND contact_policy_role_id =
                 (SELECT t.id FROM t_contact_pol_role t WHERE t.brief = '�����');
          IF p_agent_id_1 <> v_c.contact_id
          THEN
            pkg_cover.unlink_policy_agent(p_pol_id, v_c.contact_id);
            pkg_cover.link_policy_agent(p_pol_id, p_agent_id_1);
          END IF;
        END IF;
        IF p_agent_id_2 IS NULL
        THEN
          DELETE FROM p_policy_contact p WHERE p.id = v_c.id;
          pkg_cover.unlink_policy_agent(p_pol_id, v_c.contact_id);
        ELSE
          UPDATE p_policy_contact p
             SET p.contact_id = p_agent_id_2
           WHERE p.policy_id = p_pol_id
             AND contact_policy_role_id =
                 (SELECT t.id FROM t_contact_pol_role t WHERE t.brief = '�����');
          IF p_agent_id_2 <> v_c.contact_id
          THEN
            pkg_cover.unlink_policy_agent(p_pol_id, v_c.contact_id);
            pkg_cover.link_policy_agent(p_pol_id, p_agent_id_2);
          END IF;
        END IF;
      END LOOP;
    EXCEPTION
      WHEN OTHERS THEN
        IF p_agent_id_1 IS NOT NULL
        THEN
          INSERT INTO ven_p_policy_contact
            (policy_id, contact_id, contact_policy_role_id)
            SELECT p_pol_id
                  ,p_agent_id_1
                  ,t.id
              FROM ven_t_contact_pol_role t
             WHERE t.brief = '�����';
          pkg_cover.link_policy_agent(p_pol_id, p_agent_id_1);
        END IF;
        IF p_agent_id_2 IS NOT NULL
        THEN
          INSERT INTO ven_p_policy_contact
            (policy_id, contact_id, contact_policy_role_id)
            SELECT p_pol_id
                  ,p_agent_id_2
                  ,t.id
              FROM ven_t_contact_pol_role t
             WHERE t.brief = '�����';
          pkg_cover.link_policy_agent(p_pol_id, p_agent_id_2);
        END IF;
    END;
  
    DECLARE
      v_ben_id  NUMBER;
      v_old_ben NUMBER;
    BEGIN
      SELECT p.id
            ,p.contact_id
        INTO v_ben_id
            ,v_old_ben
        FROM p_policy_contact p
       WHERE p.policy_id = p_pol_id
         AND contact_policy_role_id =
             (SELECT t.id
                FROM t_contact_pol_role t
               WHERE t.brief = '�������������������');
    
      IF p_beneficiary_id IS NULL
      THEN
        DELETE FROM p_policy_contact p WHERE p.id = v_ben_id;
      ELSE
        UPDATE p_policy_contact p
           SET p.contact_id = p_beneficiary_id
         WHERE p.policy_id = p_pol_id
           AND contact_policy_role_id =
               (SELECT t.id
                  FROM t_contact_pol_role t
                 WHERE t.brief = '�������������������');
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        IF p_beneficiary_id IS NOT NULL
        THEN
          INSERT INTO ven_p_policy_contact
            (policy_id, contact_id, contact_policy_role_id)
            SELECT p_pol_id
                  ,p_beneficiary_id
                  ,t.id
              FROM ven_t_contact_pol_role t
             WHERE t.brief = '�������������������';
        END IF;
    END;
  
    IF p_curator_id IS NOT NULL
    THEN
      UPDATE p_policy_contact p
         SET p.contact_id = p_curator_id
       WHERE p.policy_id = p_pol_id
         AND contact_policy_role_id =
             (SELECT t.id FROM t_contact_pol_role t WHERE t.brief = '�������');
      IF SQL%ROWCOUNT = 0
      THEN
        INSERT INTO ven_p_policy_contact
          (policy_id, contact_id, contact_policy_role_id)
          SELECT p_pol_id
                ,p_curator_id
                ,t.id
            FROM ven_t_contact_pol_role t
           WHERE t.brief = '�������';
      END IF;
    ELSE
      DELETE FROM p_policy_contact
       WHERE policy_id = p_pol_id
         AND contact_policy_role_id =
             (SELECT t.id FROM t_contact_pol_role t WHERE t.brief = '�������');
    END IF;
  
    SELECT pp.pol_header_id INTO v_pol_head_id FROM p_policy pp WHERE pp.policy_id = p_pol_id;
    -- set_pol_header_status(v_Pol_Head_ID);
  
    --pkg_bso.check_all_bso_on_policy(p_pol_id);
  END;

  PROCEDURE update_policy_dates
  (
    p_pol_id         IN NUMBER
   ,p_is_autoprolong IN NUMBER DEFAULT -1
  ) IS
    v_start             DATE;
    v_end               DATE;
    v_end_pc            DATE;
    v_cover_end_date    DATE;
    v_ph_start          DATE;
    v_old_stuff         NUMBER;
    v_new_stuff         NUMBER;
    do_calculate        NUMBER := 0;
    do_upd_cover        NUMBER := 0;
    v_old_ver_num       NUMBER;
    v_ph_id             NUMBER;
    v_prev_pol          ven_p_policy%ROWTYPE;
    v_cover             ven_p_cover%ROWTYPE;
    v_asset_id          NUMBER;
    v_cover_id          NUMBER;
    v_new_cover_id      NUMBER;
    v_prod_brief        VARCHAR2(100);
    v_period_id         NUMBER;
    v_pol_type          VARCHAR2(30);
    v_sum               NUMBER;
    v_recovery          PLS_INTEGER;
    v_sign_date         DATE;
    v_prolong_alg_brief VARCHAR2(30);
    v_prev_id           NUMBER;
    v_is_group_flag     ins.p_policy.is_group_flag%TYPE;
    --
    /* ������ ��� ������ ������� �� ��������� ��� ������������ �������� */
    CURSOR c_period
    (
      p_p_cover_id IN NUMBER
     ,p_period_id  IN NUMBER
    ) IS
    /* Formatted on 2008/03/27 15:16 (Formatter Plus v4.8.8) */
      SELECT id
            ,NAME
            ,is_default
            ,VALUE
        FROM (SELECT p.id
                    ,p.description NAME
                    ,plp.is_default
                    ,decode(put.brief
                           ,'���� ����������� �� ������� �����������'
                           ,p.period_value_to
                           ,NULL) VALUE
                FROM t_period_use_type  put
                    ,t_period_type      pt
                    ,t_period           p
                    ,t_prod_line_period plp
                    ,p_pol_header       ph
                    ,p_policy           p_p
                    ,t_product_line     pl
                    ,t_prod_line_option plo
                    ,as_asset           aa
                    ,p_cover            pc
               WHERE 1 = 1
                 AND pc.p_cover_id = p_p_cover_id
                 AND plo.id = pc.t_prod_line_option_id
                 AND pl.id = plo.product_line_id
                 AND aa.as_asset_id = pc.as_asset_id
                 AND p_p.policy_id = aa.p_policy_id
                 AND ph.policy_header_id = p_p.pol_header_id
                 AND plp.product_line_id = pl.id
                 AND p.id = plp.period_id
                 AND pt.id = p.period_type_id
                 AND put.t_period_use_type_id = plp.t_period_use_type_id
                 AND put.brief IN ('���� �����������'
                                  ,'���� ����������� �� ������� �����������')
                 AND plp.is_disabled = 0
              UNION
              SELECT p.id
                    ,p.description NAME
                    ,0.5 is_default
                    ,decode(put.brief
                           ,'���� ����������� �� ������� �����������'
                           ,p.period_value_to
                           ,NULL) VALUE
                FROM t_period_use_type  put
                    ,t_period_type      pt
                    ,t_period           p
                    ,t_product_period   pp
                    ,p_pol_header       ph
                    ,p_policy           p_p
                    ,t_product_line     pl
                    ,t_prod_line_option plo
                    ,as_asset           aa
                    ,p_cover            pc
               WHERE 1 = 1
                 AND pc.p_cover_id = p_p_cover_id
                 AND plo.id = pc.t_prod_line_option_id
                 AND pl.id = plo.product_line_id
                 AND aa.as_asset_id = pc.as_asset_id
                 AND p_p.policy_id = aa.p_policy_id
                 AND ph.policy_header_id = p_p.pol_header_id
                 AND pp.product_id = ph.product_id
                 AND put.t_period_use_type_id = pp.t_period_use_type_id
                 AND pt.id = p.period_type_id
                 AND put.brief IN ('���� �����������'
                                  ,'���� ����������� �� ������� �����������')
                 AND NOT EXISTS (SELECT 1
                        FROM ven_t_prod_line_period plp
                       WHERE plp.period_id = pp.period_id
                         AND plp.product_line_id = pl.id
                         AND plp.is_disabled = 1))
       WHERE id = p_period_id
       ORDER BY is_default DESC;
  
    /* ���������� is_default DESC ������� ��� ����, �����, ���� �� ���. ��������� ������ ������, �� ����������� � ���������,
    �� �������� ������ ������
    
    */
  
    --
  
  BEGIN
    SELECT p.start_date
          ,p.end_date
          ,ph.start_date
          ,ph.policy_header_id
          ,tp.brief
          ,p.period_id
          ,p.sign_date
          ,p.prev_ver_id
          ,p.is_group_flag
      INTO v_start
          ,v_end
          ,v_ph_start
          ,v_ph_id
          ,v_prod_brief
          ,v_period_id
          ,v_sign_date
          ,v_prev_id
          ,v_is_group_flag
      FROM p_policy     p
          ,p_pol_header ph
          ,t_product    tp
     WHERE p.policy_id = p_pol_id
       AND p.pol_header_id = ph.policy_header_id
       AND tp.product_id = ph.product_id;
  
    v_period_id := find_pol_period(p_pol_id, v_period_id);
    IF (v_period_id IS NULL)
       AND (doc.get_last_doc_status_brief(p_pol_id) NOT IN ('BREAK', 'READY_TO_CANCEL'))
    THEN
      raise_application_error(-20100
                             ,'�� �������� ��� �������, ���������������� ������ �������� ��������');
    END IF;
  
    v_end_pc := least(v_end, ADD_MONTHS(v_start, 12) - 1);
  
    --� ��������� ��� ������� ���� ���� ������ ���������
    --������� ���� ����������� �������
  
    SELECT COUNT(*)
      INTO v_recovery
      FROM p_policy            pp
          ,p_pol_addendum_type pat
          ,t_addendum_type     tat
     WHERE pp.policy_id = pat.p_policy_id
       AND pp.policy_id = p_pol_id
       AND tat.t_addendum_type_id = pat.t_addendum_type_id
       AND tat.brief = 'RECOVER_MAIN';
  
    IF v_recovery > 0
    THEN
      --������� ��� "������ ��������"
      DELETE FROM p_cover pc
       WHERE pc.status_hist_id = 3
         AND pc.as_asset_id IN
             (SELECT aa.as_asset_id FROM as_asset aa WHERE aa.p_policy_id = p_pol_id);
    
      --�������� �������� ���� ��� ���� �� ����. ������
      FOR pc_add IN (SELECT pc.*
                           ,a.p_asset_header_id
                       FROM ven_p_cover        pc
                           ,as_asset           a
                           ,t_prod_line_option tplo
                      WHERE a.p_policy_id =
                            (SELECT pp1.policy_id
                               FROM p_policy     pp
                                   ,ven_p_policy pp1
                              WHERE pp.policy_id = p_pol_id
                                AND pp.pol_header_id = pp1.pol_header_id
                                AND pp1.policy_id =
                                    (SELECT pol.prev_ver_id
                                       FROM ins.p_policy pol
                                      WHERE pol.policy_id = pp.prev_ver_id))
                           --v_prev_pol.policy_id
                        AND a.as_asset_id = pc.as_asset_id
                        AND pc.status_hist_id IN
                            (pkg_cover.status_hist_id_curr, pkg_cover.status_hist_id_new)
                           -- AND pc.END_DATE >= v_start
                        AND pc.t_prod_line_option_id = tplo.id
                        AND tplo.description = '���������������� ��������'
                        AND NOT EXISTS
                      (SELECT NULL
                               FROM as_asset ass
                                   ,p_cover  pc1
                              WHERE ass.p_policy_id = p_pol_id
                                AND ass.as_asset_id = pc1.as_asset_id
                                AND pc1.t_prod_line_option_id = pc.t_prod_line_option_id))
      LOOP
        -- ������� ������  � ������
        BEGIN
          SELECT as_asset_id
            INTO v_asset_id
            FROM as_asset a
           WHERE p_pol_id = a.p_policy_id
             AND a.p_asset_header_id = pc_add.p_asset_header_id;
          -- ��������� ��������
          SELECT * INTO v_cover FROM ven_p_cover WHERE p_cover_id = pc_add.p_cover_id;
        
          --       v_new_cover_id := pkg_cover.include_cover(v_asset_id,pc_add.t_prod_line_option_id)
        
          v_new_cover_id := pkg_cover.cover_copy(v_cover, v_asset_id, 0);
        EXCEPTION
          WHEN no_data_found THEN
            NULL;
        END;
      END LOOP;
      pkg_asset_dates.update_all_assets_dates(par_policy_id          => p_pol_id
                                             ,par_is_group_flag      => v_is_group_flag
                                             ,par_default_start_date => v_start
                                             ,par_default_end_date   => v_end);
      RETURN;
    END IF;
  
    BEGIN
      SELECT * INTO v_prev_pol FROM ins.ven_p_policy pol WHERE pol.policy_id = v_prev_id;
    
      cover_log(v_prev_pol.policy_id
               ,'������� ���������� ������ ��������');
    
      -- �.�������
      -- 1) ������� �������� �� �������� CURRENT, ������� ����������� ������ ������ ������ ������ � �� ������ ��������������������, ������� ������ - ������������
      -- 2) �������� �������� � ���������� ������,  ���� � ��� ������ NEW ��� CURRENT, ��� ��������� �� ����� ������ ������ � �� ��� � ������ ������
      -- 3) ��� �������� �� �������� NEW ������������� ���� ������ = start_date ������
      -- 4) ������������� ��� asset-�� � ��� ��������� ��������
    
      -- ���������������
    
      --�.����������
      --��� ���������������, ���� ���������� ������ ������ 2-� ���, �� ��� ����� ���������
      --��������� � p_cover
    
      IF v_end < ADD_MONTHS(v_start, 24) - 1
      THEN
        BEGIN
          SELECT DISTINCT pa.brief
            INTO v_prolong_alg_brief
            FROM p_pol_header      ph
                ,t_product_ver_lob pvl
                ,t_product_line    pl
                ,t_product_version pv
                ,t_prolong_alg     pa
           WHERE ph.policy_header_id = v_ph_id
             AND pv.product_id = ph.product_id
             AND pl.product_ver_lob_id = pvl.t_product_ver_lob_id
             AND pvl.product_version_id = pv.t_product_version_id
             AND pl.t_prolong_alg_id = pa.t_prolong_alg_id
             AND pl.is_avtoprolongation = 1
             AND p_pol_id IN (SELECT pat.p_policy_id
                                FROM p_pol_addendum_type pat
                                    ,t_addendum_type     att
                               WHERE att.t_addendum_type_id = pat.t_addendum_type_id
                                 AND att.brief = '���������������');
        
          IF v_prolong_alg_brief = 'ResidueUnSeparate'
          THEN
            v_end_pc := v_end;
          END IF;
        
        EXCEPTION
          WHEN no_data_found THEN
            NULL;
          WHEN OTHERS THEN
            raise_application_error(-20000
                                   ,'������� ������ ��������� ����������� �� ������ ���������');
        END;
      END IF;
    
      -- ������������ �������� � ���������� ������
      FOR pc_add IN (SELECT pc.*
                           ,a.p_asset_header_id
                       FROM ven_p_cover pc
                           ,as_asset    a
                      WHERE a.p_policy_id = v_prev_pol.policy_id
                        AND a.as_asset_id = pc.as_asset_id
                        AND pc.status_hist_id IN
                            (pkg_cover.status_hist_id_curr, pkg_cover.status_hist_id_new)
                        AND (trunc(pc.end_date, 'DD') + 1) = v_start
                        AND (p_pol_id IN (SELECT pat.p_policy_id
                                            FROM p_pol_addendum_type pat
                                                ,t_addendum_type     att
                                           WHERE att.t_addendum_type_id = pat.t_addendum_type_id
                                             AND att.brief = '���������������') OR
                            nvl(p_is_autoprolong, 0) = 1)
                        AND EXISTS (SELECT 1
                               FROM ven_t_prod_line_option plo
                               JOIN ven_t_product_line pl
                                 ON pl.id = plo.product_line_id
                              WHERE plo.id = pc.t_prod_line_option_id
                                AND pl.is_avtoprolongation = 1))
      LOOP
        -- ������� ������  � ������
        BEGIN
          SELECT as_asset_id
            INTO v_asset_id
            FROM as_asset a
           WHERE p_pol_id = a.p_policy_id
             AND a.p_asset_header_id = pc_add.p_asset_header_id;
          -- ������� ���� �� �������� � ������
          BEGIN
            SELECT p_cover_id
              INTO v_cover_id
              FROM p_cover
             WHERE t_prod_line_option_id = pc_add.t_prod_line_option_id
               AND as_asset_id = v_asset_id;
          
          EXCEPTION
            WHEN no_data_found THEN
              -- ������������ ��������
              SELECT * INTO v_cover FROM ven_p_cover WHERE p_cover_id = pc_add.p_cover_id;
            
              v_new_cover_id := pkg_cover.cover_copy(v_cover, v_asset_id, 0);
              IF v_prod_brief LIKE 'CR102%'
                 OR v_prod_brief = 'CR50_5'
              THEN
                UPDATE p_cover pc
                   SET pc.end_date       = v_end_pc
                      ,pc.old_premium    = NULL
                      ,pc.status_hist_id = pkg_cover.status_hist_id_new
                 WHERE pc.p_cover_id = v_new_cover_id;
              ELSE
                UPDATE p_cover pc
                   SET pc.start_date = v_start
                      ,
                       --pc.END_DATE       = LEAST(v_end,ADD_MONTHS(v_start, 12) - 1),
                       pc.end_date       = v_end_pc
                      ,pc.old_premium    = NULL
                      ,pc.status_hist_id = pkg_cover.status_hist_id_new
                 WHERE pc.p_cover_id = v_new_cover_id;
              END IF;
          END;
        EXCEPTION
          WHEN no_data_found THEN
            NULL;
        END;
      END LOOP;
    EXCEPTION
      WHEN no_data_found THEN
        -- ��� ���������� ������
        NULL;
    END;
  
    --COVER_LOG (p_pol_id, 'ENTS.CLIENT_ID '||ents.client_id);
  
    -- ������������� ���� ��������� ���� ��������, ����
    -- ���� ��������� �������� �����, ��� ����� ������
    --  COVER_LOG (p_pol_id, '����� ��� ��� �������� ');
  
    FOR cur IN (SELECT pc.p_cover_id
                      ,pc.start_date
                      ,pc.end_date
                      ,pc.period_id
                      ,pc.accum_period_end_age
                      ,pp.period_id            policy_period_id
                      ,p.description
                      ,p2.period_value_to
                      ,p2.description          policy_period_description
                      ,pp.is_group_flag
                  FROM t_period    p2
                      ,t_period    p
                      ,p_policy    pp
                      ,p_cover     pc
                      ,as_asset    aa
                      ,status_hist sh
                 WHERE aa.p_policy_id = p_pol_id
                   AND pc.as_asset_id = aa.as_asset_id
                   AND pc.period_id IS NOT NULL
                   AND pp.policy_id = aa.p_policy_id
                   AND p.id = pc.period_id
                   AND p2.id = pp.period_id
                   AND sh.status_hist_id = pc.status_hist_id
                   AND sh.brief != 'DELETED'
                      --����� �. �������, ����� ��������� ���������� ������ �������� ��� ��������� ���������
                      -- � ������ ������ 208911
                   AND p.description != '������')
    LOOP
    
      cover_log(cur.p_cover_id
               ,'�� �������� ������ ������ :' || cur.description || '(' || cur.period_id ||
                ') ������ �������� ' || cur.policy_period_description);
    
      IF cur.accum_period_end_age IS NOT NULL
         AND cur.end_date <= v_end
      THEN
      
        cover_log(cur.p_cover_id
                 ,'������� ������� �� ��������, ���� ��������� �������� ' ||
                  to_char(cur.end_date, 'dd.mm.yyyy hh24:mi:ss') || ' �������� � ������ ');
      
      ELSIF cur.accum_period_end_age IS NOT NULL
            AND cur.end_date > v_end
      THEN
      
        cover_log(cur.p_cover_id
                 ,'������� ������� �� ��������, ���� ��������� �������� ' ||
                  to_char(cur.end_date, 'dd.mm.yyyy hh24:mi:ss') || ' �� �������� � ������  ' ||
                  v_end || '... ');
      
        v_cover_end_date := get_cover_end_date(cur.p_cover_id
                                              ,cur.start_date
                                              ,cur.end_date
                                              ,cur.policy_period_id);
      
        UPDATE p_cover pc
           SET period_id            = cur.policy_period_id
              ,end_date             = v_cover_end_date
              ,accum_period_end_age = cur.period_value_to
         WHERE p_cover_id = cur.p_cover_id;
      
      ELSIF cur.accum_period_end_age IS NULL
            AND cur.end_date < v_end
      THEN
      
        cover_log(cur.p_cover_id
                 ,'���� �������� ' || to_char(cur.end_date, 'dd.mm.yyyy hh24:mi:ss') ||
                  ' ������������� �������� �������� ');
      
        FOR cur2 IN c_period(cur.p_cover_id, cur.period_id)
        LOOP
          IF cur2.is_default = 1
          THEN
            cover_log(cur.p_cover_id
                     ,'���� �������� (� ������������� �������������� ��������) ' ||
                      to_char(cur.end_date, 'dd.mm.yyyy hh24:mi:ss') ||
                      ' ������������� �������� �������� ');
            EXIT;
          ELSIF cur2.is_default = 0.5
          THEN
            cover_log(cur.p_cover_id
                     ,'�������� (�������� ������) �������� ������ �������� ');
            v_cover_end_date := get_cover_end_date(cur.p_cover_id
                                                  ,cur.start_date
                                                  ,cur.end_date
                                                  ,cur.policy_period_id);
          
            UPDATE p_cover pc
               SET period_id            = cur.policy_period_id
                  ,end_date             = v_cover_end_date
                  ,accum_period_end_age = cur.period_value_to
             WHERE p_cover_id = cur.p_cover_id;
            EXIT;
          END IF;
        END LOOP;
      
      ELSIF cur.accum_period_end_age IS NULL
            AND cur.end_date > v_end
      THEN
      
        cover_log(cur.p_cover_id
                 ,'���� �������� ' || to_char(cur.end_date, 'dd.mm.yyyy hh24:mi:ss') ||
                  ' �� ������������� �������� �������� ' || v_end || '... ������ �� ������ �������� ');
      
        v_cover_end_date := get_cover_end_date(cur.p_cover_id
                                              ,cur.start_date
                                              ,cur.end_date
                                              ,cur.policy_period_id);
      
        UPDATE p_cover pc
           SET period_id            = cur.policy_period_id
              ,end_date             = v_cover_end_date
              ,accum_period_end_age = cur.period_value_to
         WHERE p_cover_id = cur.p_cover_id;
      
      END IF;
    
    END LOOP;
  
    -- ������������� ���� ������ ��� ����� ������
    /*    UPDATE AS_ASSET a
      SET a.start_date = v_start
    WHERE a.p_policy_id = p_pol_id
      AND a.status_hist_id = (SELECT sh.status_hist_id FROM STATUS_HIST sh WHERE sh.brief = 'NEW');*/
  
    -- ������������� ���� ������ ��� ����� ��������
    IF v_prod_brief LIKE 'CR102%'
       OR v_prod_brief = 'CR50_5'
    THEN
      NULL;
    ELSE
      UPDATE p_cover pc
         SET pc.start_date = v_start
       WHERE pc.as_asset_id IN (SELECT a.as_asset_id FROM as_asset a WHERE a.p_policy_id = p_pol_id)
         AND nvl(pc.is_handchange_start_date, 0) = 0
         AND pc.period_id != 9 --����� �. �������, ����� ��������� ���������� ������ �������� ��� ��������� ��������� � ������ ������ 208911
         AND pc.status_hist_id = (SELECT sh.status_hist_id FROM status_hist sh WHERE sh.brief = 'NEW');
    END IF;
  
    --������������� ���� ��� �������� �� ������� ���� ���������������
    UPDATE p_cover pc
       SET pc.start_date     = v_start
          ,pc.end_date       = v_end_pc
          ,pc.old_premium    = NULL
          ,pc.status_hist_id = pkg_cover.status_hist_id_new
     WHERE pc.as_asset_id IN (SELECT a.as_asset_id FROM as_asset a WHERE a.p_policy_id = p_pol_id)
          -- �� ��������� � ��������� ���������������
       AND EXISTS
     (SELECT 1
              FROM ven_t_prod_line_option plo
              JOIN ven_t_product_line pl
                ON pl.id = plo.product_line_id
             WHERE plo.id = pc.t_prod_line_option_id
               AND pl.is_avtoprolongation = 1)
          --���� �������� ������������������ �� ���� ��� ��������� ���� ������  = v_end_pc ���
          --����� ��������
          /*-- ������������� �� ���� �� ������ ������ ������
          AND TRUNC(pc.END_DATE,'DD') + 1 = v_start*/
          -- ��� ��������� � ������  = ���������������
       AND (p_pol_id IN (SELECT pat.p_policy_id
                           FROM p_pol_addendum_type pat
                               ,t_addendum_type     att
                          WHERE att.t_addendum_type_id = pat.t_addendum_type_id
                            AND att.brief = '���������������') OR nvl(p_is_autoprolong, 0) = 1)
       AND pc.status_hist_id IN (pkg_cover.status_hist_id_curr, pkg_cover.status_hist_id_new);
  
    -- �������� �������� ����������� �������� �� ������ ������
    DELETE FROM p_cover pc
     WHERE pc.end_date < v_start
       AND pc.status_hist_id = pkg_cover.status_hist_id_curr
       AND pc.as_asset_id IN (SELECT a.as_asset_id FROM as_asset a WHERE a.p_policy_id = p_pol_id);
    --
  
    --delete �� ������ 318344
    --����� ����� ��� �������� �������� �� ��������������� ��������� �������� �� �������� ���
    --�������� ����� ������
    DELETE FROM p_cover pc
     WHERE --������� �������� �� ������� ����������� ������ ��
     pc.as_asset_id IN (SELECT a.as_asset_id FROM as_asset a WHERE a.p_policy_id = p_pol_id)
    --����������� ��������
     AND pc.status_hist_id = pkg_cover.status_hist_id_new
    --��� ������ ���������������
     AND EXISTS (SELECT 1
        FROM ven_t_prod_line_option plo
        JOIN ven_t_product_line pl
          ON pl.id = plo.product_line_id
       WHERE plo.id = pc.t_prod_line_option_id
         AND pl.is_avtoprolongation = 1)
     AND (p_pol_id IN (SELECT pat.p_policy_id
                     FROM p_pol_addendum_type pat
                         ,t_addendum_type     att
                    WHERE att.t_addendum_type_id = pat.t_addendum_type_id
                      AND att.brief = '���������������') OR nvl(p_is_autoprolong, 0) = 1)
    --������� �� ������ �������� �� ���������
     AND EXISTS
     (SELECT 1
        FROM ins.t_prod_line_option plo
       WHERE plo.id = pc.t_prod_line_option_id
         AND 0 = pkg_cover_control.precreation_cover_control(pc.as_asset_id, plo.product_line_id))
    --������ ��� ������ ������ /������� �������� �������� ����������/
     AND doc.get_doc_status_brief(p_pol_id) = 'PROJECT';
  
    --�� ������ �����, �� ��������� ��� ������� �� �������
    pkg_asset_dates.update_all_assets_dates(par_policy_id          => p_pol_id
                                           ,par_is_group_flag      => v_is_group_flag
                                           ,par_default_start_date => v_start
                                           ,par_default_end_date   => v_end);
    --�������� �.�. 30.06.2010
    --������� �������������� � ������� ��� ��������.
    DELETE FROM ven_as_assured a
     WHERE 1 = 1
       AND a.p_policy_id = p_pol_id
       AND NOT EXISTS (SELECT NULL FROM p_cover pc WHERE pc.as_asset_id = a.as_assured_id);
  
    update_policy_sum(p_pol_id);
    update_pol_status_date(p_pol_id, v_start);
    update_bso_hist(p_pol_id, v_sign_date);
  
  END;

  PROCEDURE update_policy_dates
  (
    p_pol_id         IN NUMBER
   ,p_start          IN DATE
   ,p_end            IN DATE
   ,p_is_autoprolong IN NUMBER DEFAULT -1
  ) IS
    v_pol_header_id NUMBER;
  BEGIN
    UPDATE p_policy p
       SET p.start_date = p_start
          ,p.end_date   = trunc(p_end, 'DD') + 1 - 1 / 24 / 3600
     WHERE p.policy_id = p_pol_id
       AND NOT (p.start_date = p_start AND p.end_date = trunc(p_end, 'DD') + 1 - 1 / 24 / 3600);
  
    -- ���� �� ��������
    IF SQL%ROWCOUNT = 0
    THEN
      RETURN;
    END IF;
  
    SELECT pol_header_id INTO v_pol_header_id FROM p_policy WHERE policy_id = p_pol_id;
  
    UPDATE p_pol_header
       SET start_date =
           (SELECT MIN(start_date) FROM p_policy WHERE pol_header_id = v_pol_header_id)
     WHERE policy_header_id = v_pol_header_id;
  
    update_policy_dates(p_pol_id, p_is_autoprolong);
  END;

  /**
  * ��������� ������� ��������� ������
  * @author Patsan O.
  * @param p_pol_id �� ��������� ������
  */
  PROCEDURE set_pol_header_status(p_pol_header_id IN NUMBER) IS
    v_new_status_id NUMBER;
    v_policy_id     NUMBER;
  BEGIN
    SELECT dsr.doc_status_ref_id
      INTO v_new_status_id
      FROM doc_status_ref dsr
     WHERE dsr.brief = 'PROJECT';
    BEGIN
      SELECT ph.policy_id
        INTO v_policy_id
        FROM p_pol_header ph
       WHERE ph.policy_header_id = p_pol_header_id;
      doc.set_doc_status(p_pol_header_id, doc.get_last_doc_status_brief(v_policy_id));
    EXCEPTION
      WHEN OTHERS THEN
        doc.set_doc_status(p_pol_header_id, v_new_status_id);
    END;
  END;

  PROCEDURE calc_decline
  (
    p_pol_id       IN NUMBER
   ,p_decl_date    IN DATE
   ,p_is_charge    IN NUMBER
   ,p_is_comission IN NUMBER
   ,po_ins_sum     OUT NUMBER
   ,po_prem_sum    OUT NUMBER
   ,po_pay_sum     OUT NUMBER
   ,po_payoff_sum  OUT NUMBER
   ,po_charge_sum  OUT NUMBER
   ,po_com_sum     OUT NUMBER
   ,po_zsp_sum     OUT NUMBER
   ,po_decline_sum OUT NUMBER
  ) IS
    v_pay              NUMBER;
    v_payoff           NUMBER;
    v_charge           NUMBER;
    v_com              NUMBER;
    v_zsp              NUMBER;
    v_decline          NUMBER;
    v_po_pay_sum_c     NUMBER;
    v_po_payoff_sum_c  NUMBER;
    v_po_charge_sum_c  NUMBER;
    v_po_com_sum_c     NUMBER;
    v_po_zsp_sum_c     NUMBER;
    v_po_decline_sum_c NUMBER;
    v_po_ins_sum_c     NUMBER;
    v_po_prem_sum_c    NUMBER;
  BEGIN
    po_ins_sum     := 0;
    po_prem_sum    := 0;
    po_pay_sum     := 0;
    po_payoff_sum  := 0;
    po_charge_sum  := 0;
    po_com_sum     := 0;
    po_zsp_sum     := 0;
    po_decline_sum := 0;
    v_pay          := 0;
    v_payoff       := 0;
    v_charge       := 0;
    v_com          := 0;
    v_zsp          := 0;
    v_decline      := 0;
    -- �� ���� ��������� �� �������� ����� � ����������� � �
    -- ����� �������� "��� ������" ������ �����������
    FOR rec IN (SELECT DISTINCT pc.p_cover_id
                  FROM as_asset           a
                      ,p_cover            pc
                      ,status_hist        ash
                      ,status_hist        csh
                      ,t_prod_line_option plo
                      ,t_product_line     pl
                 WHERE a.p_policy_id = p_pol_id
                   AND pc.as_asset_id = a.as_asset_id
                   AND pc.t_prod_line_option_id = plo.id
                   AND plo.product_line_id = pl.id
                   AND pl.for_premium = 1
                   AND a.status_hist_id = ash.status_hist_id
                   AND ash.brief IN ('NEW', 'CURRENT')
                   AND pc.status_hist_id = csh.status_hist_id
                   AND csh.brief IN ('NEW', 'CURRENT'))
    LOOP
    
      -- ����������� ��������
      pkg_cover.calc_decline_cover(rec.p_cover_id
                                  ,p_decl_date
                                  ,p_is_charge
                                  ,p_is_comission
                                  ,v_po_ins_sum_c
                                  ,v_po_prem_sum_c
                                  ,v_po_pay_sum_c
                                  ,v_po_payoff_sum_c
                                  ,v_po_charge_sum_c
                                  ,v_po_com_sum_c
                                  ,v_po_zsp_sum_c
                                  ,v_po_decline_sum_c);
    
      -- v_decline:= pkg_cover.decline_cover(rec.p_cover_id, p_decl_date);
    
      po_ins_sum     := v_po_ins_sum_c + po_ins_sum;
      po_prem_sum    := v_po_prem_sum_c + po_prem_sum;
      po_pay_sum     := v_po_pay_sum_c + po_pay_sum;
      po_payoff_sum  := v_po_payoff_sum_c + po_payoff_sum;
      po_charge_sum  := v_po_charge_sum_c + po_charge_sum;
      po_com_sum     := v_po_com_sum_c + po_com_sum;
      po_zsp_sum     := v_po_zsp_sum_c + nvl(po_zsp_sum, 0);
      po_decline_sum := v_po_decline_sum_c + po_decline_sum;
    END LOOP;
  
    update_policy_sum(p_pol_id, po_prem_sum, po_ins_sum);
  
  EXCEPTION
    WHEN OTHERS THEN
      dbms_output.put_line('��� ������� ����� �������� �������� �������������� ��������');
  END;

  PROCEDURE start_decline(par_policy_id IN NUMBER) IS
    v_ret NUMBER;
  BEGIN
    v_ret := new_policy_version(par_policy_id, NULL, 'READY_TO_CANCEL');
  END;

  PROCEDURE update_decline_dates(par_policy_id IN NUMBER) IS
    v_active_decline   NUMBER := nvl(pkg_app_param.get_app_param_n('IS_ACTIVE_DECLINE_DATE'), 0);
    v_prev_status_date DATE;
    v_decline_date     DATE;
  
  BEGIN
    UPDATE p_policy p
       SET p.start_date = decode(v_active_decline, 1, p.decline_date, p.decline_date - 1)
          ,p.end_date   = decode(v_active_decline, 1, p.decline_date, p.decline_date - 1)
     WHERE p.policy_id = par_policy_id
       AND p.decline_date IS NOT NULL;
  
    BEGIN
      SELECT start_date
        INTO v_prev_status_date
        FROM (SELECT start_date
                    ,rownum rn
                FROM doc_status
               WHERE document_id = par_policy_id
               ORDER BY start_date DESC)
       WHERE rn = 2;
    EXCEPTION
      WHEN no_data_found THEN
        NULL;
    END;
  
    SELECT nvl(decline_notice_date, decline_date)
      INTO v_decline_date
      FROM p_policy
     WHERE policy_id = par_policy_id;
  
    IF (v_prev_status_date IS NULL)
       OR (v_decline_date > v_prev_status_date)
    THEN
    
      UPDATE ven_doc_status
         SET start_date = v_decline_date
      
       WHERE doc_status_id = (SELECT doc_status_id
                                FROM (SELECT doc_status_id
                                        FROM ven_doc_status
                                       WHERE document_id = par_policy_id
                                       ORDER BY start_date DESC)
                               WHERE rownum < 2)
         AND doc_status_ref_id =
             (SELECT doc_status_ref_id FROM doc_status_ref WHERE brief = 'READY_TO_CANCEL');
    END IF;
  END;

  PROCEDURE return_payment(par_policy_id IN NUMBER) IS
    v_payment_templ_id  NUMBER;
    v_payment_type_id   NUMBER;
    v_payment_direct_id NUMBER;
    v_doc_templ_id      NUMBER;
    v_doc_status_ref_id NUMBER;
    v_document_id       NUMBER;
    v_doc_ent_id        NUMBER;
    v_policy            ven_p_policy%ROWTYPE;
    v_pol_header        ven_p_pol_header%ROWTYPE;
    v_templ_plan        NUMBER;
    v_templ_nach        NUMBER;
    v_res_id            NUMBER;
  BEGIN
    SELECT pp.* INTO v_policy FROM ven_p_policy pp WHERE pp.policy_id = par_policy_id;
  
    SELECT ph.*
      INTO v_pol_header
      FROM ven_p_pol_header ph
     WHERE ph.policy_header_id = v_policy.pol_header_id;
  
    -- ��������� ������������ �� �������
  
    -- ������� ������ �������
    BEGIN
      SELECT e.ent_id INTO v_doc_ent_id FROM entity e WHERE e.source = 'AC_PAYMENT';
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20000
                               ,'�� ������ �������� ������ �������');
    END;
  
    BEGIN
      SELECT pt.payment_templ_id
            ,pt.payment_type_id
            ,pt.payment_direct_id
            ,pt.doc_templ_id
        INTO v_payment_templ_id
            ,v_payment_type_id
            ,v_payment_direct_id
            ,v_doc_templ_id
        FROM ac_payment_templ pt
       WHERE pt.brief = 'PAYORDBACK';
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20000
                               ,'�� ������ �������� ������ �������');
    END;
  
    SELECT dsr.doc_status_ref_id
      INTO v_doc_status_ref_id
      FROM doc_status_ref dsr
     WHERE dsr.brief = 'NEW';
  
    SELECT sq_document.nextval INTO v_document_id FROM dual;
    BEGIN
      INSERT INTO document
        (document_id, ent_id, num, reg_date, doc_templ_id)
      VALUES
        (v_document_id, v_doc_ent_id, v_policy.num, v_policy.decline_date, v_doc_templ_id);
      INSERT INTO ac_payment
        (payment_id
        ,payment_number
        ,payment_type_id
        ,payment_direct_id
        ,due_date
        ,grace_date
        ,amount
        ,fund_id
        ,rev_amount
        ,rev_fund_id
        ,rev_rate_type_id
        ,rev_rate
        ,contact_id
        ,payment_templ_id
        ,payment_terms_id
        ,collection_metod_id)
      VALUES
        (v_document_id
        ,1
        ,v_payment_type_id
        ,v_payment_direct_id
        ,v_policy.decline_date
        ,v_policy.decline_date
        ,v_policy.decline_summ
        ,v_pol_header.fund_pay_id
        ,v_policy.decline_summ
        ,v_pol_header.fund_pay_id
        ,(SELECT rt.rate_type_id FROM rate_type rt WHERE rt.brief = '��')
        ,1
        ,v_policy.decline_initiator_id
        ,v_payment_templ_id
        ,(SELECT pt.id
           FROM t_payment_terms pt
          WHERE pt.description = '�������������'
            AND rownum = 1)
        ,(SELECT cm.id
           FROM t_collection_method cm
          WHERE cm.description = '����������� ������'));
      -- ��������� � ������������ ����������
      INSERT INTO doc_doc
        (doc_doc_id, parent_id, child_id, parent_amount, parent_fund_id, child_amount, child_fund_id)
      VALUES
        (sq_doc_doc.nextval
        ,par_policy_id
        ,v_document_id
        ,v_policy.decline_summ
        ,v_pol_header.fund_pay_id
        ,v_policy.decline_summ
        ,v_pol_header.fund_pay_id);
      doc.set_doc_status(v_document_id, v_doc_status_ref_id);
    EXCEPTION
      WHEN OTHERS THEN
        raise_application_error(-20000, '������ �������� �������: ' || SQLERRM);
    END;
  END;
  PROCEDURE open_active_cover_cursor
  (
    p_policy_id IN NUMBER
   ,p_cur       OUT t_cover_cursor
  ) IS
  BEGIN
    OPEN p_cur FOR
      SELECT pc.*
        FROM as_asset    a
            ,p_cover     pc
            ,status_hist ash
            ,status_hist csh
       WHERE a.p_policy_id = p_policy_id
         AND pc.as_asset_id = a.as_asset_id
         AND a.status_hist_id = ash.status_hist_id
         AND ash.brief IN ('NEW', 'CURRENT')
         AND pc.status_hist_id = csh.status_hist_id
         AND csh.brief IN ('NEW', 'CURRENT');
  END;

  FUNCTION get_policy_contact
  (
    p_policy_id  NUMBER
   ,p_role_brief VARCHAR2
  ) RETURN NUMBER AS
    v_result NUMBER;
  BEGIN
    SELECT pc.contact_id
      INTO v_result
      FROM ven_p_policy_contact   pc
          ,ven_t_contact_pol_role cpr
     WHERE pc.policy_id = p_policy_id
       AND cpr.id = pc.contact_policy_role_id
       AND cpr.brief = p_role_brief;
    RETURN v_result;
  
  EXCEPTION
    WHEN no_data_found THEN
      RETURN NULL;
  END;

  FUNCTION get_policy_holder_id(p_policy_id NUMBER) RETURN NUMBER IS
  
  BEGIN
    RETURN get_policy_contact(p_policy_id, '������������');
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20000
                             ,'������ ����������� ������������ �� ������ ��= ' || p_policy_id);
      RETURN NULL;
  END;

  FUNCTION get_policy_agent_id(p_policy_id NUMBER) RETURN NUMBER IS
    ag_id NUMBER; -- id ���������� �������� ��� ������, ������������ ����� �����������
  BEGIN
    -- ���� ������� ��������� �������� ������ �� �� CALL CENTER (�� ����� ���� max 2 ������)
    -- ���� ��� �� CALL CENTER - �������� ������ �� ���
    SELECT tbl.agent_id
      INTO ag_id
      FROM (SELECT agch.agent_id
                  ,decode(sch.brief, 'CC', 1, 0) ord
              FROM ven_p_policy p
              JOIN ven_p_pol_header ph
                ON ph.policy_header_id = p.pol_header_id
              JOIN ven_p_policy_agent ppag
                ON ppag.policy_header_id = ph.policy_header_id
              JOIN ven_policy_agent_status ps
                ON ps.policy_agent_status_id = ppag.status_id
               AND ps.brief = 'CURRENT'
              JOIN ven_ag_contract_header agch
                ON agch.ag_contract_header_id = ppag.ag_contract_header_id
              JOIN ven_t_sales_channel sch
                ON sch.id = agch.t_sales_channel_id
             WHERE p.policy_id = p_policy_id
             ORDER BY decode(sch.brief, 'CC', 1, 0)) tbl
     WHERE rownum = 1;
    RETURN(ag_id);
  EXCEPTION
    WHEN no_data_found THEN
      RETURN NULL;
  END;

  PROCEDURE get_product_dept_person
  (
    par_product_id    IN NUMBER
   ,par_department_id IN OUT NUMBER
   ,par_contact_id    IN OUT NUMBER
  ) IS
    v_employee_id NUMBER;
  BEGIN
    par_department_id := NULL;
    -- �������� ���������� ��� �������� ������������
    IF nvl(pkg_app_param.get_app_param_n('FILIALS_ENABLED'), 0) = 1
    THEN
    
      BEGIN
        SELECT su.employee_id
          INTO v_employee_id
          FROM sys_user su
         WHERE su.sys_user_name = USER
           AND su.employee_id IN
               (SELECT employee_id
                  FROM t_product_curator
                 WHERE t_product_id = par_product_id
                   AND organisation_tree_id IN
                       (SELECT column_value
                          FROM TABLE(pkg_filial.get_org_tree_childs_table(pkg_filial.get_user_org_tree_id))));
      EXCEPTION
        -- ���� �� ������, �� ����� ���������� � ����� �� �������� ��-���������
        WHEN no_data_found THEN
          BEGIN
            SELECT employee_id
              INTO v_employee_id
              FROM (SELECT employee_id
                      FROM t_product_curator
                     WHERE t_product_id = par_product_id
                       AND organisation_tree_id IN
                           (SELECT column_value
                              FROM TABLE(pkg_filial.get_org_tree_childs_table(pkg_filial.get_user_org_tree_id)))
                       AND department_id = pkg_filial.get_user_department_id
                     ORDER BY is_default DESC)
             WHERE rownum < 2;
          EXCEPTION
            WHEN no_data_found THEN
              SELECT employee_id
                INTO v_employee_id
                FROM (SELECT employee_id
                        FROM t_product_curator
                       WHERE t_product_id = par_product_id
                         AND organisation_tree_id IN
                             (SELECT column_value
                                FROM TABLE(pkg_filial.get_org_tree_childs_table(pkg_filial.get_user_org_tree_id)))
                       ORDER BY is_default DESC)
               WHERE rownum < 2;
          END;
      END;
    
      IF v_employee_id IS NULL
      THEN
        RAISE no_data_found;
      ELSE
        BEGIN
        
          SELECT pc.department_id
                ,e.contact_id
            INTO par_department_id
                ,par_contact_id
            FROM ven_t_product_curator pc
                ,ven_employee          e
           WHERE pc.employee_id = v_employee_id
             AND pc.t_product_id = par_product_id
             AND pc.employee_id = e.employee_id
             AND pc.organisation_tree_id IN
                 (SELECT column_value
                    FROM TABLE(pkg_filial.get_org_tree_childs_table(pkg_filial.get_user_org_tree_id)))
             AND rownum = 1;
        
        EXCEPTION
          WHEN no_data_found THEN
            BEGIN
              SELECT eh.department_id
                INTO par_department_id
                FROM employee_hist eh
               WHERE eh.employee_id = v_employee_id
                 AND eh.date_hist = (SELECT MAX(e.date_hist)
                                       FROM employee_hist e
                                      WHERE e.employee_id = v_employee_id
                                        AND e.date_hist <= SYSDATE
                                        AND e.is_kicked = 0);
            
              SELECT pc2.contact_id
                INTO par_contact_id
                FROM (SELECT e.contact_id
                        FROM (SELECT pc.employee_id
                                    ,decode(pc.department_id, par_department_id, 1, 0) dep_ord
                                    ,pc.is_default
                                FROM ven_t_product_curator pc
                               WHERE pc.t_product_id = par_product_id
                                 AND pc.organisation_tree_id IN
                                     (SELECT column_value
                                        FROM TABLE(pkg_filial.get_org_tree_childs_table(pkg_filial.get_user_org_tree_id)))) pc1
                            ,ven_employee e
                       WHERE pc1.employee_id = e.employee_id
                       ORDER BY dep_ord    DESC
                               ,is_default DESC) pc2
               WHERE rownum = 1;
            
            END;
        END;
      END IF;
    
    ELSE
    
      BEGIN
        SELECT su.employee_id
          INTO v_employee_id
          FROM sys_user su
         WHERE su.sys_user_name = USER
           AND su.employee_id IN
               (SELECT employee_id FROM t_product_curator WHERE t_product_id = par_product_id);
      EXCEPTION
        WHEN no_data_found THEN
          SELECT employee_id
            INTO v_employee_id
            FROM (SELECT employee_id
                    FROM t_product_curator
                   WHERE t_product_id = par_product_id
                   ORDER BY is_default DESC)
           WHERE rownum < 2;
      END;
      -- ���� �� ������, �� ����� ���������� � ����� �� �������� ��-���������
      IF v_employee_id IS NULL
      THEN
        RAISE no_data_found;
      ELSE
        BEGIN
        
          SELECT pc.department_id
                ,e.contact_id
            INTO par_department_id
                ,par_contact_id
            FROM ven_t_product_curator pc
                ,ven_employee          e
           WHERE pc.employee_id = v_employee_id
             AND pc.t_product_id = par_product_id
             AND pc.employee_id = e.employee_id
             AND rownum = 1;
        
        EXCEPTION
          WHEN no_data_found THEN
            BEGIN
              SELECT eh.department_id
                INTO par_department_id
                FROM employee_hist eh
               WHERE eh.employee_id = v_employee_id
                 AND eh.date_hist = (SELECT MAX(e.date_hist)
                                       FROM employee_hist e
                                      WHERE e.employee_id = v_employee_id
                                        AND e.date_hist <= SYSDATE
                                        AND e.is_kicked = 0);
            
              SELECT pc2.contact_id
                INTO par_contact_id
                FROM (SELECT e.contact_id
                        FROM (SELECT pc.employee_id
                                    ,decode(pc.department_id, par_department_id, 1, 0) dep_ord
                                    ,pc.is_default
                                FROM ven_t_product_curator pc
                               WHERE pc.t_product_id = par_product_id) pc1
                            ,ven_employee e
                       WHERE pc1.employee_id = e.employee_id
                       ORDER BY dep_ord    DESC
                               ,is_default DESC) pc2
               WHERE rownum = 1;
            
            END;
        END;
      END IF;
    END IF;
  EXCEPTION
    WHEN no_data_found THEN
      par_department_id := NULL; --pkg_app_param.get_app_param_u('�������');
      par_contact_id    := NULL; --pkg_app_param.get_app_param_u('������');
  END;

  /**
  * �������������� �������, ��������� ������ p_p_policy_id
  * @author Denis Ivanov
  * @param p_policy_id �� ������, �� ��������� ������� ����� ��������������
  * @return �� p_pol_header ������ ��������
  */

  FUNCTION prolongation(p_policy_id IN NUMBER) RETURN NUMBER IS
    v_ph                ven_p_pol_header%ROWTYPE;
    v_pp                ven_p_policy%ROWTYPE;
    v_new_pol_id        NUMBER;
    v_old_ph_id         NUMBER;
    v_prev_event_count  NUMBER;
    sr                  NUMBER;
    v_sr                NUMBER;
    p_is_new            NUMBER;
    v_profitableness_id NUMBER;
    v_delta             NUMBER := 1 / 24 / 3600;
    v_product           VARCHAR2(30);
  BEGIN
    set_status(p_policy_id, 'PROJECT', 1);
    -- �������� ���������
    SELECT ph.*
      INTO v_ph
      FROM ven_p_pol_header ph
          ,p_policy         p
     WHERE ph.policy_header_id = p.pol_header_id
       AND p.policy_id = p_policy_id;
  
    SELECT p.* INTO v_pp FROM ven_p_policy p WHERE p.policy_id = p_policy_id;
  
    v_ph.prev_policy_num := v_pp.pol_num;
    v_ph.prev_policy_ser := v_pp.pol_ser;
    sr                   := v_pp.end_date - v_pp.start_date;
    v_sr                 := ROUND(MONTHS_BETWEEN(v_pp.end_date, v_pp.start_date));
  
    /*SELECT (pp.end_date-pp.start_date)
    INTO sr
    FROM P_POLICY pp
    WHERE pp.policy_id = p_policy_id;*/
  
    p_is_new    := v_ph.is_new; -- ��������� ������ �������� �������� �����������. ���� is_new=0, ������ �����������
    v_old_ph_id := v_ph.policy_header_id;
  
    -- ������ �������� ������ �������, ��� �� ������ ������������
    UPDATE ven_p_pol_header ph
       SET ph.is_new = 0 --,   ph.prev_pol_header_id = v_old_ph_id
     WHERE ph.policy_header_id = v_ph.policy_header_id;
  
    v_ph.prev_pol_header_id := v_ph.policy_header_id;
  
    -- �������� �� �������� ������ ������� �����������
    UPDATE ven_p_pol_header ph SET ph.is_new = 0 WHERE ph.policy_header_id = v_old_ph_id;
  
    SELECT sq_p_pol_header.nextval INTO v_ph.policy_header_id FROM dual;
    INSERT INTO ven_p_pol_header VALUES v_ph;
  
    -- �������� ������
    v_new_pol_id := new_policy_version(p_policy_id, 1);
  
    -- ���������� ������ �������� �������� �����������
    UPDATE ven_p_pol_header ph SET ph.is_new = p_is_new WHERE ph.policy_header_id = v_old_ph_id;
    UPDATE p_policy p
       SET p.pol_header_id  = v_ph.policy_header_id
          ,p.start_date     = p.end_date + v_delta
          ,p.end_date       = ADD_MONTHS(p.end_date, v_sr)
          , --+ v_delta,
           p.sign_date      = p.end_date + v_delta
          ,p.confirm_date   = p.end_date + v_delta
          ,p.first_pay_date = p.end_date + v_delta
          ,p.notice_date    = p.end_date + v_delta
     WHERE p.policy_id = v_new_pol_id;
  
    --�������� ����� � ����� ���������������� ������� ��� ��� (����� �����)
    BEGIN
      SELECT brief INTO v_product FROM t_product WHERE product_id = v_ph.product_id;
    EXCEPTION
      WHEN no_data_found THEN
        v_product := '?';
    END;
    IF pkg_app_param.get_app_param_n('CLIENTID') = 10
       AND nvl(v_product, '?') <> '�����'
    THEN
      UPDATE p_policy p
         SET p.pol_ser = NULL
            ,p.pol_num = NULL
       WHERE p.policy_id = v_new_pol_id;
    END IF;
  
    SELECT p.* INTO v_pp FROM ven_p_policy p WHERE p.policy_id = v_new_pol_id;
  
    -- ���������� ��������� ������� �� ����������� ��������
    v_prev_event_count := pkg_claim.count_loss_by_prev(v_old_ph_id);
    IF v_prev_event_count = 0
    THEN
      BEGIN
        SELECT *
          INTO v_profitableness_id
          FROM (SELECT pr_new.t_profitableness_id
                  FROM t_profitableness pr
                      ,t_period         p
                      ,t_period         p_new
                      ,t_profitableness pr_new
                 WHERE p_new.id = pr_new.period_id
                   AND p_new.period_value = least(nvl(p.period_value, 0) + 1, 3)
                   AND p.period_type_id = p_new.period_type_id
                   AND p.id(+) = pr.period_id
                   AND p_new.id = pr_new.period_id
                   AND pr.t_profitableness_id = v_ph.t_profitableness_id)
         WHERE rownum = 1;
      EXCEPTION
        WHEN no_data_found THEN
          NULL;
      END;
    ELSE
      SELECT t_profitableness_id INTO v_profitableness_id FROM t_profitableness WHERE brief = 'NONE';
    END IF;
  
    UPDATE p_pol_header ph
       SET ph.policy_id           = v_new_pol_id
          ,ph.t_profitableness_id = nvl(v_profitableness_id, ph.t_profitableness_id)
          ,ph.prev_event_count    = v_prev_event_count
          ,ph.start_date          = v_pp.start_date
          ,ph.prev_policy_company =
           (SELECT ent.obj_name(c.ent_id, c.contact_id)
              FROM ven_contact c
             WHERE c.contact_id = pkg_app_param.get_app_param_u('WHOAMI'))
     WHERE ph.policy_header_id = v_ph.policy_header_id;
  
    UPDATE as_asset a
       SET a.start_date = v_pp.start_date
          ,a.end_date   = a.end_date + 1 + sr
     WHERE a.p_policy_id = v_new_pol_id;
  
    UPDATE p_cover c
       SET c.start_date  = v_pp.start_date
          ,c.end_date    = c.end_date + 1 + sr
          ,c.old_premium = NULL
     WHERE c.as_asset_id IN (SELECT a.as_asset_id FROM as_asset a WHERE a.p_policy_id = v_new_pol_id);
  
    -- ����������� ����� �� ����������� ������
    update_policy_sum(v_new_pol_id);
  
    RETURN v_ph.policy_header_id;
  END;

  /**
  * ���������� �������, ��������� ������ p_p_policy_id
  * @author Denis Ivanov
  * @param p_policy_id �� ������, �� ��������� ������� ����� ��������������
  * @return �� p_pol_header ������ ��������
  */
  FUNCTION copy(p_policy_id IN NUMBER) RETURN NUMBER IS
    v_ph               ven_p_pol_header%ROWTYPE;
    v_new_pol_id       NUMBER;
    v_old_ph_id        NUMBER;
    v_prev_event_count NUMBER;
  BEGIN
    set_status(p_policy_id, 'PROJECT', 1);
    -- �������� ���������
    SELECT ph.*
      INTO v_ph
      FROM ven_p_pol_header ph
          ,p_policy         p
     WHERE ph.policy_header_id = p.pol_header_id
       AND p.policy_id = p_policy_id;
    v_old_ph_id := v_ph.policy_header_id;
    SELECT sq_p_pol_header.nextval INTO v_ph.policy_header_id FROM dual;
    INSERT INTO ven_p_pol_header VALUES v_ph;
    -- �������� ������
    utils.put('NOT_CHANGE_ACTIVE_VER', 1);
    utils.put('CLEAR_POL_NUM', 1);
    v_new_pol_id := new_policy_version(p_policy_id);
  
    -- ����������� �������� ���
    --pkg_dms.copy_policy(p_policy_id, v_new_pol_id);
  
    -- ������� 14.12.2007 : ������
    UPDATE as_asset ass
       SET ass.status_hist_id =
           (SELECT sh.status_hist_id FROM status_hist sh WHERE sh.brief = 'NEW')
     WHERE ass.p_policy_id = v_new_pol_id;
  
    UPDATE p_cover pc
       SET pc.status_hist_id =
           (SELECT sh.status_hist_id FROM status_hist sh WHERE sh.brief = 'NEW')
          ,pc.old_premium    = NULL
     WHERE pc.as_asset_id =
           (SELECT ass.as_asset_id FROM as_asset ass WHERE ass.p_policy_id = v_new_pol_id);
    -- ������� 14.12.2007 : ���������
  
    UPDATE p_policy p
       SET p.pol_header_id = v_ph.policy_header_id
          ,
           -- p.start_date     = SYSDATE,
           -- p.end_date       = ADD_MONTHS(SYSDATE, 12) - 1,
           -- p.sign_date      = SYSDATE,
           -- p.confirm_date   = SYSDATE,
           -- p.first_pay_date = SYSDATE,
           -- p.notice_date    = SYSDATE,
           p.version_num = 1
     WHERE p.policy_id = v_new_pol_id;
    --
    DECLARE
      v_id NUMBER;
    BEGIN
      FOR rc IN (SELECT a.as_asset_id
                       ,a.p_asset_header_id
                   FROM as_asset a
                  WHERE a.p_policy_id = v_new_pol_id)
      LOOP
        SELECT sq_p_asset_header.nextval INTO v_id FROM dual;
        INSERT INTO p_asset_header
          (p_asset_header_id, asset_identifier, t_asset_type_id)
          SELECT v_id
                ,asset_identifier
                ,t_asset_type_id
            FROM p_asset_header
           WHERE p_asset_header_id = rc.p_asset_header_id;
        UPDATE as_asset SET p_asset_header_id = v_id WHERE as_asset_id = rc.as_asset_id;
      END LOOP;
    END;
    --
    -- ���������� ��������� ������� �� ����������� ��������
    SELECT COUNT(DISTINCT e.c_event_id)
      INTO v_prev_event_count
      FROM c_event        e
          ,c_claim_header ch
          ,p_pol_header   ph
          ,p_policy       p
          ,as_asset       a
     WHERE p.pol_header_id = ph.policy_header_id
       AND p.pol_header_id = v_old_ph_id
       AND a.p_policy_id = p.policy_id
       AND e.as_asset_id = a.as_asset_id
       AND ch.c_event_id = e.c_event_id
       AND doc.get_doc_status_brief(ch.c_claim_header_id) IN ('INFORMING', 'CLOSE');
  
    UPDATE p_pol_header ph
       SET ph.policy_id        = v_new_pol_id
          ,ph.prev_event_count = v_prev_event_count
     WHERE ph.policy_header_id = v_ph.policy_header_id;
  
    -- ����������� ����� �� ����������� ������
    update_policy_sum(v_new_pol_id);
  
    RETURN v_ph.policy_header_id;
  END;

  FUNCTION find_commiss_v
  (
    p_ag_contract_header_id IN NUMBER
   ,p_prod_line_id          IN NUMBER
   ,p_cur_date              IN DATE DEFAULT SYSDATE
  ) RETURN NUMBER IS
  
    v_rate_id NUMBER;
    v_result  NUMBER;
  BEGIN
  
    SELECT ag_rate_id
      INTO v_rate_id
      FROM ven_ag_contract        ac
          ,ven_ag_prod_line_contr pl
     WHERE ac.ag_contract_id = pkg_agent.get_status_by_date(p_ag_contract_header_id, p_cur_date)
          --pkg_agent.get_status_contr_activ_id(p_ag_contract_header_id)
       AND pl.ag_contract_id = ac.ag_contract_id
       AND (pl.product_line_id = p_prod_line_id OR
           (pl.product_line_id IS NULL AND
           pl.product_id = (SELECT tp2.product_id
                                FROM ven_t_product         tp2
                                    ,ven_t_product_version tpv2
                                    ,ven_t_product_ver_lob tpvl2
                                    ,ven_t_product_line    tpl2
                               WHERE tpv2.product_id(+) = tp2.product_id
                                 AND tpvl2.product_version_id(+) = tpv2.t_product_version_id
                                 AND tpl2.product_ver_lob_id = tpvl2.t_product_ver_lob_id
                                 AND tpl2.id = p_prod_line_id
                                 AND rownum = 1) AND
           pl.insurance_group_id = (SELECT tpl4.insurance_group_id
                                        FROM ven_t_product         tp4
                                            ,ven_t_product_version tpv4
                                            ,ven_t_product_ver_lob tpvl4
                                            ,ven_t_product_line    tpl4
                                       WHERE tpv4.product_id(+) = tp4.product_id
                                         AND tpvl4.product_version_id(+) = tpv4.t_product_version_id
                                         AND tpl4.product_ver_lob_id = tpvl4.t_product_ver_lob_id
                                         AND tpl4.id = p_prod_line_id
                                         AND rownum = 1)) OR
           (pl.product_line_id IS NULL AND pl.product_id IS NULL AND
           pl.insurance_group_id = (SELECT tpl3.insurance_group_id
                                        FROM ven_t_product         tp3
                                            ,ven_t_product_version tpv3
                                            ,ven_t_product_ver_lob tpvl3
                                            ,ven_t_product_line    tpl3
                                       WHERE tpv3.product_id(+) = tp3.product_id
                                         AND tpvl3.product_version_id(+) = tpv3.t_product_version_id
                                         AND tpl3.product_ver_lob_id = tpvl3.t_product_ver_lob_id
                                         AND tpl3.id = p_prod_line_id
                                         AND rownum = 1)))
       AND rownum = 1;
  
    SELECT ar.value INTO v_result FROM ven_ag_rate ar WHERE ar.ag_rate_id = v_rate_id;
    RETURN v_result;
  
  EXCEPTION
    WHEN no_data_found THEN
      RETURN NULL;
    
  END;

  FUNCTION find_commiss_t
  (
    p_ag_contract_header_id IN NUMBER
   ,p_prod_line_id          IN NUMBER
   ,p_cur_date              IN DATE DEFAULT SYSDATE
  ) RETURN NUMBER IS
    v_rate_id NUMBER;
    v_result  NUMBER;
  BEGIN
    SELECT ag_rate_id
      INTO v_rate_id
      FROM ven_ag_contract        ac
          ,ven_ag_prod_line_contr pl
     WHERE ac.ag_contract_id = pkg_agent.get_status_by_date(p_ag_contract_header_id, p_cur_date)
          --pkg_agent.get_status_contr_activ_id(p_ag_contract_header_id)
       AND pl.ag_contract_id = ac.ag_contract_id
       AND (pl.product_line_id = p_prod_line_id OR
           (pl.product_line_id IS NULL AND
           pl.product_id = (SELECT tp2.product_id
                                FROM ven_t_product         tp2
                                    ,ven_t_product_version tpv2
                                    ,ven_t_product_ver_lob tpvl2
                                    ,ven_t_product_line    tpl2
                               WHERE tpv2.product_id(+) = tp2.product_id
                                 AND tpvl2.product_version_id(+) = tpv2.t_product_version_id
                                 AND tpl2.product_ver_lob_id = tpvl2.t_product_ver_lob_id
                                 AND tpl2.id = p_prod_line_id
                                 AND rownum = 1) AND
           pl.insurance_group_id = (SELECT tpl4.insurance_group_id
                                        FROM ven_t_product         tp4
                                            ,ven_t_product_version tpv4
                                            ,ven_t_product_ver_lob tpvl4
                                            ,ven_t_product_line    tpl4
                                       WHERE tpv4.product_id(+) = tp4.product_id
                                         AND tpvl4.product_version_id(+) = tpv4.t_product_version_id
                                         AND tpl4.product_ver_lob_id = tpvl4.t_product_ver_lob_id
                                         AND tpl4.id = p_prod_line_id
                                         AND rownum = 1)) OR
           (pl.product_line_id IS NULL AND pl.product_id IS NULL AND
           pl.insurance_group_id = (SELECT tpl3.insurance_group_id
                                        FROM ven_t_product         tp3
                                            ,ven_t_product_version tpv3
                                            ,ven_t_product_ver_lob tpvl3
                                            ,ven_t_product_line    tpl3
                                       WHERE tpv3.product_id(+) = tp3.product_id
                                         AND tpvl3.product_version_id(+) = tpv3.t_product_version_id
                                         AND tpl3.product_ver_lob_id = tpvl3.t_product_ver_lob_id
                                         AND tpl3.id = p_prod_line_id
                                         AND rownum = 1)))
       AND rownum = 1;
  
    SELECT ar.type_rate_value_id INTO v_result FROM ven_ag_rate ar WHERE ar.ag_rate_id = v_rate_id;
    RETURN v_result;
  
  EXCEPTION
    WHEN no_data_found THEN
      RETURN NULL;
  END; -- func find_commist_t

  FUNCTION find_commission
  (
    p_comiss_kind           IN NUMBER
   ,p_ag_contract_header_id IN NUMBER
   ,p_prod_line_id          IN NUMBER
   ,p_cur_date              IN DATE DEFAULT SYSDATE
  ) RETURN NUMBER IS
  
    v_rate_id NUMBER;
    v_result  NUMBER;
  BEGIN
  
    IF p_comiss_kind NOT IN (1, 2, 3, 4)
    THEN
      RETURN NULL;
    END IF;
  
    SELECT ag_rate_id
      INTO v_rate_id
      FROM ven_ag_contract        ac
          ,ven_ag_prod_line_contr pl
     WHERE ac.ag_contract_id = pkg_agent.get_status_by_date(p_ag_contract_header_id, p_cur_date)
       AND pl.ag_contract_id = ac.ag_contract_id
       AND (pl.product_line_id = p_prod_line_id OR
           (pl.product_line_id IS NULL AND
           pl.product_id = (SELECT tp2.product_id
                                FROM ven_t_product         tp2
                                    ,ven_t_product_version tpv2
                                    ,ven_t_product_ver_lob tpvl2
                                    ,ven_t_product_line    tpl2
                               WHERE tpv2.product_id(+) = tp2.product_id
                                 AND tpvl2.product_version_id(+) = tpv2.t_product_version_id
                                 AND tpl2.product_ver_lob_id = tpvl2.t_product_ver_lob_id
                                 AND tpl2.id = p_prod_line_id
                                 AND rownum = 1) AND
           pl.insurance_group_id = (SELECT tpl4.insurance_group_id
                                        FROM ven_t_product         tp4
                                            ,ven_t_product_version tpv4
                                            ,ven_t_product_ver_lob tpvl4
                                            ,ven_t_product_line    tpl4
                                       WHERE tpv4.product_id(+) = tp4.product_id
                                         AND tpvl4.product_version_id(+) = tpv4.t_product_version_id
                                         AND tpl4.product_ver_lob_id = tpvl4.t_product_ver_lob_id
                                         AND tpl4.id = p_prod_line_id
                                         AND rownum = 1)) OR
           (pl.product_line_id IS NULL AND pl.product_id IS NULL AND
           pl.insurance_group_id = (SELECT tpl3.insurance_group_id
                                        FROM ven_t_product         tp3
                                            ,ven_t_product_version tpv3
                                            ,ven_t_product_ver_lob tpvl3
                                            ,ven_t_product_line    tpl3
                                       WHERE tpv3.product_id(+) = tp3.product_id
                                         AND tpvl3.product_version_id(+) = tpv3.t_product_version_id
                                         AND tpl3.product_ver_lob_id = tpvl3.t_product_ver_lob_id
                                         AND tpl3.id = p_prod_line_id
                                         AND rownum = 1)))
       AND rownum = 1;
  
    CASE p_comiss_kind
      WHEN 1 THEN
        SELECT r.type_rate_value_id INTO v_result FROM ven_ag_rate r WHERE r.ag_rate_id = v_rate_id;
        RETURN v_result;
      WHEN 2 THEN
        SELECT r.value INTO v_result FROM ven_ag_rate r WHERE r.ag_rate_id = v_rate_id;
        RETURN v_result;
      WHEN 3 THEN
        SELECT r.type_defin_rate_id INTO v_result FROM ven_ag_rate r WHERE r.ag_rate_id = v_rate_id;
        RETURN v_result;
      WHEN 4 THEN
        SELECT r.t_prod_coef_type_id INTO v_result FROM ven_ag_rate r WHERE r.ag_rate_id = v_rate_id;
        RETURN v_result;
    END CASE;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN NULL;
    
  END; --

  FUNCTION payment_loss_by_prev(p_pol_header_id IN NUMBER) RETURN NUMBER IS
    -- ����� ������ �� �������� / �������
    v_ret NUMBER := 0;
  BEGIN
  
    SELECT nvl(SUM(t.acc_amount), 0)
      INTO v_ret
      FROM trans t
      JOIN trans_templ tt
        ON tt.trans_templ_id = t.trans_templ_id
      JOIN c_damage cd
        ON t.a5_dt_uro_id = cd.c_damage_id
      JOIN c_claim cc
        ON cc.c_claim_id = cd.c_claim_id
      JOIN c_claim_header ch
        ON ch.c_claim_header_id = cc.c_claim_header_id
      JOIN p_policy pp
        ON pp.policy_id = ch.p_policy_id
     WHERE tt.brief IN ('������������', '������������')
       AND pp.pol_header_id = p_pol_header_id;
  
    RETURN v_ret;
  END;

  FUNCTION declared_loss_by_prev(p_pol_header_id IN NUMBER) RETURN NUMBER IS
    -- ���������� �� �� ����������� ����� �� �������� / �������
    v_ret NUMBER := 0;
  BEGIN
  
    SELECT nvl(cc.declare_sum - nvl(v.vipl, 0), 0)
      INTO v_ret
      FROM p_policy pp
      JOIN ven_c_claim_header ch
        ON ch.p_policy_id = pp.policy_id
      JOIN ven_c_claim cc
        ON cc.c_claim_header_id = ch.c_claim_header_id
      LEFT JOIN (SELECT cd.c_claim_id
                       ,nvl(SUM(t.acc_amount), 0) vipl
                   FROM trans t
                   JOIN trans_templ tt
                     ON tt.trans_templ_id = t.trans_templ_id
                   JOIN c_damage cd
                     ON t.a5_dt_uro_id = cd.c_damage_id
                  WHERE tt.brief IN ('������������', '������������')
                  GROUP BY cd.c_claim_id) v
        ON v.c_claim_id = cc.c_claim_id
     WHERE cc.seqno =
           (SELECT MAX(c.seqno) FROM c_claim c WHERE c.c_claim_header_id = ch.c_claim_header_id)
       AND pp.pol_header_id = p_pol_header_id;
  
    RETURN v_ret;
  END;
  PROCEDURE drop_policy(p_policy_header_id IN NUMBER) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    DELETE FROM ven_p_policy WHERE pol_header_id = p_policy_header_id;
    DELETE FROM ven_p_pol_header WHERE policy_header_id = p_policy_header_id;
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE;
  END;

  PROCEDURE delete_policy(p_policy_header_id IN NUMBER) IS
  BEGIN
    -- ���� �� ����� �� ������ �������� ���� ����������, �� ������� ������� ������
    FOR op IN (SELECT ot.brief
                 FROM oper       o
                     ,p_policy   p
                     ,oper_templ ot
                WHERE o.document_id = p.policy_id
                  AND p.pol_header_id = p_policy_header_id
                  AND ot.oper_templ_id = o.oper_templ_id)
    LOOP
      raise_application_error(-20100
                             ,'������ ������� �������. ���� ���������� �� �������� ' || op.brief);
    END LOOP;
    -- �������� ��������� ������� �������
    /*
         BEGIN
           SAVEPOINT del_pol;
                DELETE FROM ven_p_policy WHERE pol_header_id = p_policy_header_id;
             DELETE FROM ven_p_pol_header WHERE policy_header_id = p_policy_header_id;
             RETURN;
          EXCEPTION WHEN OTHERS THEN
           ROLLBACK TO sp;
         END;
    */
    -- �������� �� ��������
    UPDATE p_pol_header SET is_deleted = 1 WHERE policy_header_id = p_policy_header_id;
  END;

  PROCEDURE delete_policy_now(par_policy_header_id IN NUMBER) IS
    TYPE t_contact_id IS TABLE OF NUMBER;
    c_contact_id t_contact_id;
  BEGIN
    BEGIN
      -- ���� �� ����� �� ������ �������� ���� ����������, �� ������� ������� ������
      FOR op IN (SELECT ot.brief
                   FROM oper       o
                       ,p_policy   p
                       ,oper_templ ot
                  WHERE o.document_id = p.policy_id
                    AND p.pol_header_id = par_policy_header_id
                    AND ot.oper_templ_id = o.oper_templ_id)
      LOOP
        raise_application_error(-20100
                               ,'������ ������� �������. ���� ���������� �� �������� ' || op.brief);
      END LOOP;
    
      /* �������� � ��������� ����� �������� ������� ��������, ���� ����� ��������� ������ ��������*/
      SELECT contact_id
        BULK COLLECT
        INTO c_contact_id
        FROM (SELECT pc.contact_id
                FROM p_policy_contact pc
                    ,p_policy         pp
               WHERE pp.policy_id = pc.policy_id
                 AND pp.pol_header_id = par_policy_header_id
              UNION
              SELECT aas.assured_contact_id contact_id
                FROM p_policy   pp
                    ,as_asset   aa
                    ,as_assured aas
               WHERE pp.pol_header_id = par_policy_header_id
                 AND aa.p_policy_id = pp.policy_id
                 AND aas.as_assured_id = aa.as_asset_id
              UNION
              SELECT b.contact_id
                FROM as_beneficiary b
                    ,p_policy       pp
                    ,as_asset       aa
               WHERE b.as_asset_id = aa.as_asset_id
                 AND aa.p_policy_id = pp.policy_id
                 AND pp.pol_header_id = par_policy_header_id);
    
      DELETE FROM p_asset_header ah
       WHERE ah.p_asset_header_id IN (SELECT aa.p_asset_header_id
                                        FROM p_policy pp
                                            ,as_asset aa
                                       WHERE pp.pol_header_id = par_policy_header_id
                                         AND aa.p_policy_id = pp.policy_id);
    
      DELETE FROM ven_p_policy_agent pa WHERE pa.policy_header_id = par_policy_header_id;
    
      DELETE FROM as_assured_re a
       WHERE a.p_policy_id IN
             (SELECT pp.policy_id FROM p_policy pp WHERE pp.pol_header_id = par_policy_header_id);
    
      DELETE FROM ven_p_policy WHERE pol_header_id = par_policy_header_id;
    
      DELETE FROM ven_p_pol_header WHERE policy_header_id = par_policy_header_id;
    
    EXCEPTION
      WHEN OTHERS THEN
        RAISE;
    END;
  
    FOR i IN c_contact_id.first .. c_contact_id.last
    LOOP
      DECLARE
        v_result NUMBER;
        v_msg    VARCHAR2(2000);
      BEGIN
        pkg_contact.prepare_for_delete(p_contact_id => c_contact_id(i)
                                      ,p_res        => v_result
                                      ,p_mess       => v_msg);
        IF v_result = 1
        THEN
          DELETE FROM ven_contact c WHERE contact_id = c_contact_id(i);
        END IF;
      END;
    
    END LOOP;
  
  END;

  --TODO: ��������� ������. ��� ������ �� ������
  PROCEDURE set_policy_status
  (
    doc_id      NUMBER
   ,status_id   NUMBER
   ,status_date IN DATE DEFAULT SYSDATE
  ) IS
    v_dts_id            NUMBER;
    v_is_del            NUMBER;
    v_oper_templ_id     NUMBER;
    v_is_accepted       NUMBER;
    v_cover_ent_id      NUMBER;
    v_cover_obj_id      NUMBER;
    v_premium           NUMBER;
    v_old_premium       NUMBER;
    v_plan_amount       NUMBER;
    v_oper_amount       NUMBER;
    id                  NUMBER;
    v_status_hist_brief VARCHAR2(30);
    v_oper_templ_brief  VARCHAR2(30);
    /*
       cursor c_Oper(pc_policy_id number, pc_dts_id number) is
         select dsa.uro_id oper_templ_id,
                dsr.is_accepted,
                c.ent_id,
                c.p_cover_id,
                c.premium Premium,
                c.old_premium Old_Premium,
                sh.brief status_hist_brief,
                ot.brief oper_templ_brief
           from document       d,
                p_policy       p,
                doc_status_action dsa,
                doc_action_type   dat,
                doc_status_ref    dsr,
                as_asset          ass,
                status_hist       sh,
                p_cover           c,
                oper_templ        ot
          where d.document_id = pc_policy_id
            and d.document_id = p.policy_id
            and dsa.doc_templ_status_id = pc_dts_id
            and dsa.doc_action_type_id = dat.doc_action_type_id
            and dat.brief = 'OPER'
            and dsr.doc_status_ref_id = status_id
            and ass.p_policy_id = d.document_id
            and ass.status_hist_id = sh.status_hist_id(+)
            and c.as_asset_id = ass.as_asset_id
            and dsa.uro_id = ot.oper_templ_id;
    */
  BEGIN
  
    -- ������� �������� ������� ��� ���������
    SELECT dts.doc_templ_status_id
      INTO v_dts_id
      FROM doc_templ_status dts
          ,document         d
     WHERE dts.doc_status_ref_id = status_id
       AND d.document_id = doc_id
       AND dts.doc_templ_id = d.doc_templ_id;
    /*
      -- ������� �������� �� �������
      open c_Oper(doc_id, v_dts_id);
      loop
        fetch c_Oper into v_Oper_Templ_ID, v_Is_Accepted, v_Cover_Ent_ID, v_Cover_Obj_ID, v_Premium, v_Old_Premium, v_Status_Hist_Brief, v_Oper_Templ_Brief;
        exit when c_Oper%notfound;
    
        case
          when v_Oper_Templ_Brief = '���������' then
            if v_Old_Premium is null then
              v_Oper_Amount := v_Premium;
            else
              if v_Premium > v_Old_Premium then
                v_Oper_Amount := v_Premium - v_Old_Premium;
              else
                v_Oper_Amount := 0;
              end if;
            end if;
          when v_Oper_Templ_Brief = '����������' then
            if v_Old_Premium is null then
              v_Oper_Amount := 0;
            else
              if v_Premium < v_Old_Premium then
                v_Oper_Amount := v_Premium - v_Old_Premium;
              else
                v_Oper_Amount := 0;
              end if;
            end if;
          else
            v_Oper_Amount := 0;
        end case;
    
        if v_Oper_Amount <> 0 then
          id := acc_new.Run_Oper_By_Template(v_Oper_Templ_ID, doc_id, v_Cover_Ent_ID, v_Cover_Obj_ID, status_id, 1, v_Oper_Amount);
        end if;
    
      end loop;
      close c_Oper;
    */
  END;

  FUNCTION is_addendum(p_policy_id NUMBER) RETURN NUMBER IS
    is_a NUMBER;
  BEGIN
    SELECT 1
      INTO is_a
      FROM dual
     WHERE p_policy_id IN (SELECT policy_id
                             FROM (SELECT policy_id
                                         ,rownum rn
                                     FROM (SELECT p.policy_id
                                             FROM ven_p_policy p
                                                 ,ven_p_policy p1
                                            WHERE p1.policy_id = p_policy_id
                                              AND p1.pol_header_id = p.pol_header_id
                                            ORDER BY p.version_num ASC))
                            WHERE rn > 1);
    RETURN is_a;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN 0;
  END;

  FUNCTION is_policy_change_status(p_status_brief VARCHAR2) RETURN NUMBER IS
  BEGIN
    IF p_status_brief IN ('PROJECT')
    THEN
      RETURN 1;
    END IF;
    RETURN 0;
  END;

  FUNCTION is_policy_claim_status(p_status_brief VARCHAR2) RETURN NUMBER IS
  BEGIN
    IF p_status_brief IN ('CURRENT', 'BREAK', 'STOPED')
    THEN
      RETURN 1;
    END IF;
    RETURN 0;
  END;

  FUNCTION is_active_status
  (
    p_status_brief VARCHAR2
   ,p_doc_templ_id NUMBER DEFAULT 2
  ) RETURN NUMBER IS
    v_client_id NUMBER := nvl(ents.client_id, 0);
    RESULT      NUMBER := 0;
  BEGIN
  
    SELECT COUNT(1)
      INTO RESULT
      FROM dual
     WHERE EXISTS (SELECT NULL
              FROM ins.ven_doc_templ_status st
                  ,ins.doc_status_ref       rf
             WHERE st.doc_status_ref_id = rf.doc_status_ref_id
               AND rf.brief = p_status_brief
               AND st.doc_templ_id = p_doc_templ_id
               AND st.is_active_status = 1);
  
    RETURN RESULT;
  END;

  /*
    ������ �.
  
    ���������� ������ �������� �� ��
    @param par_policy_header_id - �� ������ ��
    @param par_raise_on_error - ���������� ������
    @return ������ p_pol_header
  */
  FUNCTION get_header_record
  (
    par_policy_header_id p_policy.policy_id%TYPE
   ,par_raise_on_error   BOOLEAN DEFAULT TRUE
  ) RETURN p_pol_header%ROWTYPE IS
    vr_pol_header p_pol_header%ROWTYPE;
  BEGIN
    assert_deprecated(par_policy_header_id IS NULL
                     ,'�� ������ �������� �� ������');
    BEGIN
      SELECT *
        INTO vr_pol_header
        FROM p_pol_header ph
       WHERE ph.policy_header_id = par_policy_header_id;
    EXCEPTION
      WHEN no_data_found THEN
        IF par_raise_on_error
        THEN
          raise_application_error(-20001
                                 ,'�� ������ ��������� �������� ����������� �� ��');
        ELSE
          vr_pol_header := NULL;
        END IF;
    END;
    RETURN vr_pol_header;
  END get_header_record;
  /*
    ������ �.
  
    ���������� ������ ������ �� ��
    @param par_policy_id - �� ������ ��
    @param par_raise_on_error - ���������� ������
    @return ������ p_policy
  */
  FUNCTION get_version_record
  (
    par_policy_id      p_policy.policy_id%TYPE
   ,par_raise_on_error BOOLEAN DEFAULT TRUE
  ) RETURN p_policy%ROWTYPE IS
    vr_policy p_policy%ROWTYPE;
  BEGIN
    assert_deprecated(par_policy_id IS NULL, '�� ������ �������� �� ������');
    BEGIN
      SELECT * INTO vr_policy FROM p_policy pp WHERE pp.policy_id = par_policy_id;
    EXCEPTION
      WHEN no_data_found THEN
        IF par_raise_on_error
        THEN
          raise_application_error(-20001
                                 ,'�� ������� ������ �������� ����������� �� ��');
        ELSE
          vr_policy := NULL;
        END IF;
    END;
    RETURN vr_policy;
  END get_version_record;

  FUNCTION get_last_version(p_pol_header_id NUMBER) RETURN NUMBER IS
    v_pol_id NUMBER;
  BEGIN
    /*SELECT policy_id INTO v_pol_id FROM
     (SELECT policy_id
              FROM P_POLICY p WHERE p_pol_header_id = pol_header_id
            ORDER BY p.version_num DESC)
       WHERE ROWNUM=1;
      RETURN v_pol_id;
    EXCEPTION WHEN NO_DATA_FOUND THEN
        RETURN NULL;*/
    /*
      ������ �.
      ������� �� ����
    */
    SELECT ph.last_ver_id
      INTO v_pol_id
      FROM p_pol_header ph
     WHERE ph.policy_header_id = p_pol_header_id;
  
    RETURN v_pol_id;
  END;

  FUNCTION get_last_version_status(p_pol_header_id NUMBER) RETURN VARCHAR2 IS
    v_pol_id NUMBER;
  BEGIN
    v_pol_id := get_last_version(p_pol_header_id);
    IF v_pol_id IS NULL
    THEN
      RETURN NULL;
    ELSE
      RETURN doc.get_doc_status_name(v_pol_id);
    END IF;
  END;

  FUNCTION get_previous_version(p_pol_id NUMBER) RETURN NUMBER IS
    v_pol_id NUMBER;
  BEGIN
    /*
    TODO: owner="Pazus" category="Fix" priority="3 - Low" created="29.09.2013"
    text="������ � pkg_policy.get_previous_version �� ������������ ������ ���� prev_ver_id?"
    */
    BEGIN
      SELECT policy_id
        INTO v_pol_id
        FROM (SELECT p.policy_id
                FROM p_policy p
                    ,p_policy pp
               WHERE pp.pol_header_id = p.pol_header_id
                 AND pp.policy_id = p_pol_id
                    --AND p.POLICY_ID<p_pol_id
                    --and p.version_num < pp.version_num
                 AND p.policy_id = pp.prev_ver_id
               ORDER BY p.version_num DESC)
       WHERE rownum = 1;
    EXCEPTION
      WHEN OTHERS THEN
        RETURN NULL;
    END;
  
    RETURN v_pol_id;
  END;

  FUNCTION get_prev_ver_status_brief(p_policy_id NUMBER) RETURN VARCHAR2 IS
    buf ven_doc_status_ref.brief%TYPE;
  BEGIN
    -- BRIEF ���������� ������� ���������� ������ ��������
    BEGIN
      SELECT s.brief
        INTO buf
        FROM (SELECT dsr.brief
                FROM ven_doc_status     ds
                    ,ven_doc_status_ref dsr
               WHERE ds.document_id = (SELECT pp.policy_id
                                         FROM ven_p_policy pp
                                             ,ven_p_policy pp2
                                        WHERE pp2.policy_id = p_policy_id
                                          AND pp.pol_header_id = pp2.pol_header_id
                                          AND pp.policy_id = pp2.prev_ver_id)
                 AND ds.doc_status_ref_id = dsr.doc_status_ref_id
               ORDER BY ds.start_date DESC) s
       WHERE rownum = 1;
      RETURN(buf);
    EXCEPTION
      WHEN no_data_found THEN
        RETURN('');
    END;
  END;

  FUNCTION get_prev_status_brief(p_policy_id NUMBER) RETURN VARCHAR2 IS
    buf ven_doc_status_ref.brief%TYPE;
  BEGIN
    -- BRIEF ����������� �������
    BEGIN
      SELECT s.brief
        INTO buf
        FROM (SELECT dsr.name
                    ,dsr.brief
                    ,ds.start_date
                    ,row_number() over(ORDER BY ds.start_date DESC) AS nn
                FROM ven_doc_status     ds
                    ,ven_doc_status_ref dsr
               WHERE ds.document_id = p_policy_id
                 AND ds.doc_status_ref_id = dsr.doc_status_ref_id) s
       WHERE s.nn = 2;
      RETURN(buf);
    EXCEPTION
      WHEN no_data_found THEN
        RETURN('');
    END;
  END;

  FUNCTION is_last_version(p_policy_id NUMBER) RETURN NUMBER IS
    is_a NUMBER;
  BEGIN
    SELECT 1
      INTO is_a
      FROM dual
     WHERE p_policy_id = (SELECT *
                            FROM (SELECT p.policy_id
                                    FROM ven_p_policy p
                                        ,ven_p_policy p1
                                   WHERE p1.policy_id = p_policy_id
                                     AND p1.pol_header_id = p.pol_header_id
                                   ORDER BY p.version_num DESC)
                           WHERE rownum = 1);
    RETURN is_a;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN 0;
  END;

  PROCEDURE set_status
  (
    p_policy_id    NUMBER
   ,p_status_brief VARCHAR2
   ,p_rollback     NUMBER DEFAULT 0
  ) IS
    v_status_change_type VARCHAR2(10) := 'AUTO';
  BEGIN
    SAVEPOINT status_sp;
    IF p_rollback = 1
    THEN
      v_status_change_type := 'CHECK';
    END IF;
    doc.set_doc_status(p_policy_id, p_status_brief, SYSDATE, v_status_change_type);
    IF p_rollback = 1
    THEN
      ROLLBACK TO status_sp;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK TO status_sp;
      RAISE;
  END;

  PROCEDURE cancel_policy(par_policy_id NUMBER) IS
    v_delete_policy NUMBER;
  BEGIN
    SELECT decode(is_addendum(par_policy_id), 1, 1, 0) INTO v_delete_policy FROM dual;
    IF v_delete_policy = 1
    THEN
      -- ������ �.
      -- ������ 245177
      IF pkg_re_insurance.can_delete_policy(par_policy_id) = 0
      THEN
        raise_application_error(-20001
                               ,'�� ��������� ������ ���������� ������ ����������������� �������!');
      END IF;
    
      new_policy_delete(par_policy_id);
    END IF;
  END;

  PROCEDURE set_policy_nr(par_policy_id NUMBER) IS
    v_status     VARCHAR2(100);
    v_pol_ser    VARCHAR2(100);
    v_pol_num    VARCHAR2(100);
    v_notice_ser VARCHAR2(100);
  BEGIN
    SELECT doc.get_last_doc_status_brief(par_policy_id)
          ,pol_ser
          ,pol_num
          ,notice_ser
      INTO v_status
          ,v_pol_ser
          ,v_pol_num
          ,v_notice_ser
      FROM p_policy
     WHERE policy_id = par_policy_id;
    IF /*v_status ='NEW' and  */
     v_pol_ser IS NULL
     AND v_pol_num IS NULL
    THEN
      v_pol_ser := get_policy_serial(par_policy_id);
      v_pol_num := get_policy_number(par_policy_id);
      UPDATE p_policy
         SET pol_ser = v_pol_ser
            ,pol_num = v_pol_num
       WHERE policy_id = par_policy_id;
    END IF;
    IF (v_notice_ser IS NULL)
       AND (nvl(ents.client_id, 0) = 11)
    THEN
      BEGIN
        SELECT series_name
          INTO v_notice_ser
          FROM (SELECT bs.series_name
                  FROM t_product_bso_types pbt
                      ,bso_type            bt
                      ,bso_series          bs
                      ,p_pol_header        ph
                      ,p_policy            p
                 WHERE bt.bso_type_id = pbt.bso_type_id
                   AND lower(bt.kind_brief) = '���������'
                   AND bs.bso_type_id = bt.bso_type_id
                   AND pbt.t_product_id = ph.product_id
                   AND p.pol_header_id = ph.policy_header_id
                   AND p.policy_id = par_policy_id
                 ORDER BY bs.is_default)
         WHERE rownum < 2;
      
      EXCEPTION
        WHEN no_data_found THEN
          NULL;
      END;
      UPDATE p_policy SET notice_ser = v_notice_ser WHERE policy_id = par_policy_id;
    END IF;
    --��� ���������� �� ��������� ����� ������ (���� �� �������� ���. ��� �� ���. �������) ���. ������ ������ ���������
    IF (v_pol_num IS NULL)
       AND (ents.client_id = 11)
    THEN
      BEGIN
        SELECT p.notice_num INTO v_pol_num FROM ven_p_policy p WHERE p.policy_id = par_policy_id;
      EXCEPTION
        WHEN no_data_found THEN
          NULL;
      END;
      UPDATE p_policy SET pol_num = v_pol_num WHERE policy_id = par_policy_id;
    END IF;
  END;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 12.02.2010 11:47:50
  -- Purpose : ���������� ������ ������� �� ��� ��������������� ��� ������������ ����� ������ ��
  FUNCTION policy_by_assured(par_assured_name VARCHAR2) RETURN t_number_type IS
    proc_name VARCHAR2(25) := 'policy_by_assured';
    res_tab   t_number_type;
  BEGIN
    SELECT p_policy_id
      BULK COLLECT
      INTO res_tab
      FROM ven_as_assured aa
          ,contact        cn
     WHERE cn.contact_id = aa.assured_contact_id
       AND cn.obj_name LIKE upper(par_assured_name);
    RETURN(res_tab);
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'������ ��� ���������� ' || proc_name || SQLERRM);
  END policy_by_assured;

  FUNCTION asset_in_policy
  (
    p_pol_id  NUMBER
   ,p_as_name VARCHAR2
  ) RETURN NUMBER IS
    v_result NUMBER := 0;
  BEGIN
    IF p_as_name IS NULL
    THEN
      RETURN 1;
    END IF;
    SELECT 1
      INTO v_result
      FROM as_asset a
     WHERE a.p_policy_id = p_pol_id
       AND ent.obj_name(a.ent_id, a.as_asset_id) LIKE
           nvl(p_as_name, ent.obj_name(a.ent_id, a.as_asset_id));
    RETURN v_result;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
  END;

  FUNCTION agent_in_policy
  (
    p_pol_header_id NUMBER
   ,p_agent_name    VARCHAR2
  ) RETURN NUMBER IS
    v_result NUMBER := 0;
  BEGIN
    IF p_agent_name IS NULL
    THEN
      RETURN 1;
    END IF;
    /*
          SELECT 1 INTO v_result FROM v_agent_polic ag
           WHERE ag.policy_header_id = p_pol_header_id
                    AND (ag.agent_name_1 LIKE NVL(p_agent_name, ag.agent_name_1));
    */
    SELECT 1
      INTO v_result
      FROM ag_contract_header ag
          ,p_policy_agent     pa
          ,contact            c
     WHERE pa.policy_header_id = p_pol_header_id
       AND pa.ag_contract_header_id = ag.ag_contract_header_id
       AND ag.agent_id = c.contact_id
       AND c.obj_name_orig LIKE nvl(p_agent_name, c.obj_name_orig);
    RETURN v_result;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
  END;

  FUNCTION get_privilege_per_end_date
  (
    p_policy_id           NUMBER
   ,p_privilege_period_id NUMBER DEFAULT -1
   ,p_start_date          DATE DEFAULT NULL
  ) RETURN DATE IS
    v_val                       NUMBER;
    v_name                      VARCHAR2(150);
    v_privilege_period_id       NUMBER;
    v_privilege_period_end_date DATE;
    v_start_date                DATE;
    v_one_sec                   NUMBER := 1 / 24 / 3600;
  BEGIN
    IF nvl(p_privilege_period_id, 0) = -1
    THEN
      SELECT pol_privilege_period_id
            ,start_date
        INTO v_privilege_period_id
            ,v_start_date
        FROM p_policy
       WHERE policy_id = p_policy_id;
    ELSE
      v_privilege_period_id := p_privilege_period_id;
      v_start_date          := p_start_date;
    END IF;
    SELECT p.period_value
          ,pt.description
      INTO v_val
          ,v_name
      FROM ven_t_period      p
          ,ven_t_period_type pt
     WHERE p.period_type_id = pt.id
       AND p.id = v_privilege_period_id;
    IF v_val IS NOT NULL
    THEN
      CASE v_name
        WHEN '���' THEN
          v_privilege_period_end_date := v_start_date + v_val - v_one_sec;
        WHEN '������' THEN
          v_privilege_period_end_date := ADD_MONTHS(v_start_date, v_val) - v_one_sec;
        WHEN '����' THEN
          IF to_char(trunc(v_start_date), 'ddmm') = '2902'
          THEN
            v_privilege_period_end_date := ADD_MONTHS(v_start_date + 1, v_val * 12) - v_one_sec;
          ELSE
            v_privilege_period_end_date := ADD_MONTHS(v_start_date, v_val * 12) - v_one_sec;
          END IF;
        ELSE
          NULL;
      END CASE;
    ELSE
      v_privilege_period_end_date := NULL;
    END IF;
    RETURN v_privilege_period_end_date;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  FUNCTION is_in_privilege_period
  (
    p_pol_id              NUMBER
   ,p_privilege_period_id NUMBER DEFAULT -1
   ,p_start_date          DATE DEFAULT NULL
  ) RETURN NUMBER IS
    v_end_date DATE := get_privilege_per_end_date(p_pol_id, p_privilege_period_id, p_start_date);
  BEGIN
    IF v_end_date IS NULL
    THEN
      RETURN NULL;
    END IF;
    IF SYSDATE >= v_end_date
    THEN
      RETURN 0;
    ELSE
      RETURN 1;
    END IF;
  END;

  FUNCTION get_end_date
  (
    p_period_id  NUMBER
   ,p_start_date DATE
  ) RETURN DATE IS
    v_val      NUMBER;
    v_name     VARCHAR2(100);
    v_end_date DATE;
    v_one_sec  NUMBER := 1 / 24 / 3600;
  BEGIN
  
    SELECT p.period_value
          ,pt.description
      INTO v_val
          ,v_name
      FROM ven_t_period      p
          ,ven_t_period_type pt
     WHERE p.period_type_id = pt.id
       AND p.id = p_period_id;
  
    IF v_val IS NOT NULL
    THEN
      CASE v_name
        WHEN '���' THEN
          v_end_date := p_start_date + v_val - v_one_sec;
        WHEN '������' THEN
          v_end_date := ADD_MONTHS(p_start_date, v_val) - v_one_sec;
        WHEN '����' THEN
          IF to_char(trunc(p_start_date), 'ddmm') = '2902'
          THEN
            v_end_date := ADD_MONTHS(p_start_date + 1, v_val * 12) - v_one_sec;
          ELSE
            v_end_date := ADD_MONTHS(p_start_date, v_val * 12) - v_one_sec;
          END IF;
        ELSE
          NULL;
      END CASE;
    ELSE
      v_end_date := NULL;
    END IF;
    RETURN v_end_date;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  FUNCTION get_waiting_per_end_date
  (
    p_policy_id         NUMBER
   ,p_waiting_period_id NUMBER DEFAULT -1
   ,p_start_date        DATE DEFAULT NULL
  ) RETURN DATE IS
    v_val                     NUMBER;
    v_name                    VARCHAR2(150);
    v_waiting_period_id       NUMBER;
    v_waiting_period_end_date DATE;
    v_start_date              DATE;
    v_one_sec                 NUMBER := 1 / 24 / 3600;
  BEGIN
    -- ����� ���� ��������� �������������� �������
    IF TRUE
    THEN
      SELECT waiting_period_end_date
        INTO v_waiting_period_end_date
        FROM p_policy
       WHERE policy_id = p_policy_id;
      RETURN v_waiting_period_end_date;
    END IF;
    IF nvl(p_waiting_period_id, 0) = -1
    THEN
      SELECT waiting_period_id
            ,start_date
        INTO v_waiting_period_id
            ,v_start_date
        FROM p_policy
       WHERE policy_id = p_policy_id;
    ELSE
      v_waiting_period_id := p_waiting_period_id;
      v_start_date        := p_start_date;
    END IF;
    SELECT p.period_value
          ,pt.description
      INTO v_val
          ,v_name
      FROM ven_t_period      p
          ,ven_t_period_type pt
     WHERE p.period_type_id = pt.id
       AND p.id = v_waiting_period_id;
    IF v_val IS NOT NULL
    THEN
      CASE v_name
        WHEN '���' THEN
          v_waiting_period_end_date := v_start_date + v_val - v_one_sec;
        WHEN '������' THEN
          v_waiting_period_end_date := ADD_MONTHS(v_start_date + 1, v_val) - v_one_sec;
        WHEN '����' THEN
          IF to_char(trunc(v_start_date), 'ddmm') = '2902'
          THEN
            v_waiting_period_end_date := ADD_MONTHS(v_start_date, v_val * 12) - v_one_sec;
          ELSE
            v_waiting_period_end_date := ADD_MONTHS(v_start_date, v_val * 12) - v_one_sec;
          END IF;
        ELSE
          NULL;
      END CASE;
    ELSE
      v_waiting_period_end_date := NULL;
    END IF;
    RETURN v_waiting_period_end_date;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  FUNCTION is_in_waiting_period
  (
    p_pol_id            NUMBER
   ,p_waiting_period_id NUMBER DEFAULT -1
   ,p_start_date        DATE DEFAULT NULL
  ) RETURN NUMBER IS
    v_end_date DATE := get_waiting_per_end_date(p_pol_id, p_waiting_period_id, p_start_date);
  BEGIN
    IF v_end_date IS NULL
    THEN
      RETURN NULL;
    END IF;
    IF SYSDATE >= v_end_date
    THEN
      RETURN 0;
    ELSE
      RETURN 1;
    END IF;
  END;

  FUNCTION get_policy_region(p_pol_id NUMBER) RETURN NUMBER IS
    v_is_group    NUMBER;
    v_contact_id  NUMBER;
    v_province_id NUMBER;
  BEGIN
    SELECT nvl(is_group_flag, 0) INTO v_is_group FROM p_policy WHERE policy_id = p_pol_id;
    IF v_is_group = 1
    THEN
      -- ��� ��������� ��������� ������ �� ������ ������������
      /*****�����**********/
      /*SELECT province_id INTO  v_province_id FROM*/
      SELECT t_kladr_id
        INTO v_province_id
        FROM (SELECT a.*
                    ,prov.t_kladr_id
                FROM cn_address a
                    ,(SELECT kl.t_kladr_id
                            ,kl.code       code_kladr
                            ,kl.name       province_name
                            ,ors.scname
                        FROM ins.t_kladr         kl
                            ,ins.t_socrbase_orig ors
                       WHERE kl.socr = ors.scname
                         AND ors.plevel = 1
                         AND kl.code LIKE '__000000000__'
                       ORDER BY 2) prov
                    ,cn_contact_address ca
                    ,v_pol_issuer vpi
               WHERE p_pol_id = vpi.policy_id(+)
                 AND vpi.contact_id = ca.contact_id(+)
                 AND ca.adress_id = a.id(+)
                 AND substr(a.code, 1, 2) || '00000000000' = prov.code_kladr(+)
               ORDER BY ca.is_default DESC)
       WHERE rownum < 2;
    ELSE
      -- ����� ������ �� ������ ������� ���������������
      -- ���� ������� � ��������������� ���������, �� ����� ����� ��-���������, ���� ������ ��� - �����
      /*****�����**********/
      /*SELECT province_id INTO  v_province_id FROM*/
      SELECT t_kladr_id
        INTO v_province_id
        FROM (SELECT a.*
                    ,prov.t_kladr_id
                FROM cn_address a
                    ,cn_contact_address ca
                    ,as_asset ass
                    ,as_assured aa
                    ,(SELECT kl.t_kladr_id
                            ,kl.code       code_kladr
                            ,kl.name       province_name
                            ,ors.scname
                        FROM ins.t_kladr         kl
                            ,ins.t_socrbase_orig ors
                       WHERE kl.socr = ors.scname
                         AND ors.plevel = 1
                         AND kl.code LIKE '__000000000__'
                       ORDER BY 2) prov
               WHERE p_pol_id = ass.p_policy_id(+)
                 AND ass.as_asset_id = aa.as_assured_id(+)
                 AND nvl(ass.status_hist_id(+), 0) <> pkg_asset.status_hist_id_del
                 AND aa.assured_contact_id = ca.contact_id(+)
                 AND ca.adress_id = a.id(+)
                 AND substr(a.code, 1, 2) || '00000000000' = prov.code_kladr(+)
               ORDER BY ass.as_asset_id ASC
                       ,ca.is_default   DESC)
       WHERE rownum < 2;
    END IF;
    RETURN v_province_id;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN NULL;
  END;

  /*
    ��������� ID ������� �� ��������� ��
  */
  FUNCTION get_region_by_pol_header(par_pol_header_id p_pol_header.policy_header_id%TYPE)
    RETURN t_kladr.t_kladr_id%TYPE IS
    v_kladr_id t_kladr.t_kladr_id%TYPE;
  BEGIN
    BEGIN
      SELECT pp.region_id
        INTO v_kladr_id
        FROM p_policy     pp
            ,p_pol_header ph
       WHERE ph.policy_header_id = par_pol_header_id
         AND ph.max_uncancelled_policy_id = pp.policy_id;
    EXCEPTION
      WHEN no_data_found THEN
        NULL;
    END;
    RETURN v_kladr_id;
  END get_region_by_pol_header;

  PROCEDURE check_policy_payment_date(p_payment_id IN NUMBER) IS
  BEGIN
  
    FOR rc IN (SELECT p.end_date
                     ,ap.reg_date
                 FROM ven_ac_payment ap
                     ,doc_doc        dd
                     ,p_pol_header   ph
                     ,p_policy       p
                WHERE ap.payment_id = p_payment_id
                  AND dd.child_id = ap.payment_id
                  AND dd.parent_id = ph.policy_header_id
                  AND p.policy_id = ph.policy_id
                  AND p.end_date < ap.reg_date)
    LOOP
      raise_application_error(-20000
                             ,'������ ��� ���������� ���������� �������� �����������');
    END LOOP;
  
  END;

  FUNCTION get_pol_agency_name(p_pol_header_id NUMBER) RETURN VARCHAR2 IS
    v_agency_name VARCHAR2(1000);
  BEGIN
    SELECT ot.name || ' - ' || d.name
      INTO v_agency_name
      FROM p_pol_header      ph
          ,department        d
          ,organisation_tree ot
     WHERE ph.policy_header_id = p_pol_header_id
       AND ph.agency_id = d.department_id
       AND ot.organisation_tree_id = d.org_tree_id;
    RETURN v_agency_name;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN NULL;
  END;

  FUNCTION get_admin_cost_sum(p_pol_id NUMBER) RETURN NUMBER IS
    v_sum NUMBER;
  BEGIN
    SELECT SUM(pc.premium)
      INTO v_sum
      FROM as_asset           a
          ,p_cover            pc
          ,t_prod_line_option plo
          ,t_product_line     pl
     WHERE a.p_policy_id = p_pol_id
       AND pc.as_asset_id = a.as_asset_id
       AND pc.t_prod_line_option_id = plo.id
       AND plo.product_line_id = pl.id
       AND pl.brief = 'ADMIN_EXPENCES'
       AND a.status_hist_id <> pkg_asset.status_hist_id_del
       AND pc.status_hist_id <> pkg_cover.status_hist_id_del;
    RETURN nvl(v_sum, 0);
  END;
  /*���������������� �������� (����� �� ������-�������)*/
  FUNCTION get_admin_cost_fee(p_pol_id NUMBER) RETURN NUMBER IS
    v_sum NUMBER;
  BEGIN
    SELECT SUM(pc.fee)
      INTO v_sum
      FROM as_asset           a
          ,p_cover            pc
          ,t_prod_line_option plo
          ,t_product_line     pl
     WHERE a.p_policy_id = p_pol_id
       AND pc.as_asset_id = a.as_asset_id
       AND pc.t_prod_line_option_id = plo.id
       AND plo.product_line_id = pl.id
       AND pl.brief = 'ADMIN_EXPENCES'
       AND a.status_hist_id <> pkg_asset.status_hist_id_del
       AND pc.status_hist_id <> pkg_cover.status_hist_id_del;
    RETURN nvl(v_sum, 0);
  END;

  FUNCTION get_main_pol_agent(p_pol_header_id IN NUMBER) RETURN NUMBER IS
    v_agch_id NUMBER;
  BEGIN
    SELECT ag_contract_header_id
      INTO v_agch_id
      FROM (SELECT agch.ag_contract_header_id
              FROM ven_ag_contract_header  agch
                  ,ven_p_policy_agent      pa
                  ,ven_policy_agent_status pas
                  ,ven_t_sales_channel     sh
             WHERE agch.ag_contract_header_id = pa.ag_contract_header_id
               AND pas.brief = 'CURRENT'
               AND pas.policy_agent_status_id = pa.status_id
               AND pa.policy_header_id = p_pol_header_id
               AND agch.t_sales_channel_id = sh.id(+)
             ORDER BY decode(sh.brief, 'MLM', 1, 0) DESC)
     WHERE rownum < 2;
    RETURN v_agch_id;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN NULL;
  END;

  PROCEDURE check_bso_exists(p_pol_id NUMBER) IS
    v_bso_id NUMBER;
  BEGIN
    FOR b_types IN (SELECT bs.bso_series_id
                          ,bt.name
                      FROM t_product_bso_types pbt
                          ,bso_type            bt
                          ,bso_series          bs
                          ,p_pol_header        ph
                          ,p_policy            p
                     WHERE bt.bso_type_id = bs.bso_type_id
                       AND pbt.bso_type_id = bs.bso_type_id
                       AND ph.policy_header_id = p.pol_header_id
                       AND p.policy_id = p_pol_id
                       AND pbt.t_product_id = ph.product_id
                       AND bt.brief <> '�7(!)')
    LOOP
      BEGIN
        SELECT b.bso_id
          INTO v_bso_id
          FROM bso b
         WHERE b.policy_id = p_pol_id
           AND b.bso_series_id = b_types.bso_series_id;
      EXCEPTION
        WHEN no_data_found THEN
          raise_application_error(-20100
                                 ,'� ������ �� �������� ��� ����: ' || b_types.name);
        WHEN OTHERS THEN
          NULL;
      END;
    END LOOP;
  END;

  PROCEDURE correct_pol_dates
  (
    p_pol_id         NUMBER
   ,p_new_start_date DATE
  ) IS
    v_months_cnt NUMBER;
    v_one_sec    NUMBER := 1 / 3600 / 24;
  BEGIN
    SELECT CEIL(MONTHS_BETWEEN(end_date, start_date))
      INTO v_months_cnt
      FROM p_policy
     WHERE policy_id = p_pol_id;
  
    UPDATE p_policy
       SET start_date     = p_new_start_date
          ,first_pay_date = p_new_start_date
          ,end_date       = ADD_MONTHS(p_new_start_date, v_months_cnt) - v_one_sec
     WHERE policy_id = p_pol_id;
  
    UPDATE p_pol_header
       SET start_date = p_new_start_date
     WHERE policy_header_id IN (SELECT pol_header_id FROM p_policy WHERE policy_id = p_pol_id);
  
    FOR ass IN (SELECT ast.as_asset_id
                      ,CEIL(MONTHS_BETWEEN(ast.end_date, ast.start_date)) mbas
                  FROM as_asset ast
                 WHERE ast.p_policy_id = p_pol_id)
    LOOP
    
      UPDATE as_asset
         SET start_date = p_new_start_date
            ,end_date   = ADD_MONTHS(p_new_start_date, ass.mbas) - v_one_sec
       WHERE as_asset_id = ass.as_asset_id;
    
      FOR pcov IN (SELECT pc.p_cover_id
                         ,CEIL(MONTHS_BETWEEN(pc.end_date, pc.start_date)) mbpc
                     FROM p_cover pc
                    WHERE pc.as_asset_id = ass.as_asset_id)
      LOOP
      
        UPDATE p_cover
           SET start_date = p_new_start_date
              ,end_date   = ADD_MONTHS(p_new_start_date, pcov.mbpc) - v_one_sec
         WHERE p_cover_id = pcov.p_cover_id;
      
      END LOOP;
    END LOOP;
  END;

  /******************************************************************************/

  PROCEDURE create_policy_from_policy
  (
    p_from_policy_id IN NUMBER
   ,p_to_product_id  IN NUMBER
   ,p_to_policy_id   OUT NUMBER
  ) IS
  
    rec_from_pol            p_policy%ROWTYPE;
    rec_from_pol_hdr        p_pol_header%ROWTYPE;
    vr_prod_osago_id        NUMBER;
    vr_prod_casco_id        NUMBER;
    vr_to_pol_hdr_id        NUMBER;
    vr_sales_channel_id     p_pol_header.sales_channel_id%TYPE;
    vr_company_tree_id      p_pol_header.company_tree_id%TYPE;
    vr_fund_id              p_pol_header.fund_id%TYPE;
    vr_fund_pay_id          p_pol_header.fund_pay_id%TYPE;
    vr_confirm_condition_id p_pol_header.confirm_condition_id%TYPE;
    vr_cont_type_id         contact.contact_type_id%TYPE;
    vr_pol_ser              p_policy.pol_ser%TYPE;
    vr_pol_num              p_policy.pol_num%TYPE;
    vr_notice_date          p_policy.notice_date%TYPE;
    vr_sign_date            p_policy.sign_date%TYPE;
    vr_confirm_date         p_policy.confirm_date%TYPE;
    vr_start_date           p_policy.start_date%TYPE;
    vr_end_date             p_policy.end_date%TYPE;
    vr_first_pay_date       p_policy.first_pay_date%TYPE;
    vr_payment_term_id      p_policy.payment_term_id%TYPE;
    vr_period_id            p_policy.period_id%TYPE;
    vr_agent_id_1           NUMBER;
    vr_agent_id_2           NUMBER;
    vr_curator_id           NUMBER;
    vr_department_id        NUMBER;
    vr_issuer_id            NUMBER;
    vr_osago_sign_ser       p_policy.osago_sign_ser%TYPE;
    vr_osago_sign_num       p_policy.osago_sign_num%TYPE;
    vr_prev_event_count     NUMBER;
    vr_fee_payment_term     NUMBER;
    vr_beneficiary_id       NUMBER;
    vr_fact_j               NUMBER;
    vr_ag_contract_id_1     NUMBER;
    vr_ag_contract_id_2     NUMBER;
    vr_admin_cost           NUMBER;
    vr_is_park              NUMBER;
    vr_is_group_flag        NUMBER;
    vr_notice_num           p_policy.notice_num%TYPE;
    vr_waiting_period_id    NUMBER;
    vr_sales_action_id      NUMBER;
    vr_region_id            NUMBER;
    vr_office_manager_id    NUMBER;
    vr_region_manager_id    NUMBER;
    vr_discount_f_id        NUMBER;
    vr_description          p_policy.description%TYPE;
    vr_paymentoff_term_id   NUMBER;
    vr_ph_description       p_pol_header.description%TYPE;
    vr_payment_start_date   DATE;
    vr_privilege_period     NUMBER;
    i                       NUMBER;
  BEGIN
  
    --������ �� �������� �������������
    SELECT * INTO rec_from_pol FROM p_policy WHERE policy_id = p_from_policy_id;
  
    SELECT *
      INTO rec_from_pol_hdr
      FROM p_pol_header
     WHERE policy_header_id = rec_from_pol.pol_header_id;
  
    --������ ��� ������ ��������
    --ID ������ ��������
    SELECT sq_p_policy.nextval INTO p_to_policy_id FROM dual;
  
    --ID ������ ������
    vr_sales_channel_id := rec_from_pol_hdr.sales_channel_id;
  
    --ID ������
    vr_company_tree_id := rec_from_pol_hdr.company_tree_id;
  
    --ID ������ ���������������
    vr_fund_id := rec_from_pol_hdr.fund_id;
  
    --ID ������ �������
    vr_fund_pay_id := rec_from_pol_hdr.fund_pay_id;
  
    --ID ������� ���������� � ����
    vr_confirm_condition_id := rec_from_pol_hdr.confirm_condition_id;
  
    --ID ������������
    BEGIN
      SELECT pc.contact_id
        INTO vr_issuer_id
        FROM ven_p_policy_contact pc
        JOIN ven_t_contact_pol_role t
          ON t.id = pc.contact_policy_role_id
         AND t.brief = '������������'
       WHERE pc.policy_id = rec_from_pol.policy_id;
    EXCEPTION
      WHEN no_data_found THEN
        vr_issuer_id := NULL;
    END;
  
    --ID ���� ��������
    SELECT c.contact_type_id INTO vr_cont_type_id FROM contact c WHERE c.contact_id = vr_issuer_id;
  
    --����� ������
    vr_pol_ser := pkg_policy.get_policy_ser(p_to_product_id, vr_cont_type_id);
  
    --����� ������
    vr_pol_num := pkg_policy.get_policy_nr(p_to_product_id, vr_pol_ser);
  
    --���� ���������
    vr_notice_date := rec_from_pol.notice_date;
  
    --���� ����������
    vr_sign_date := rec_from_pol.sign_date;
  
    --���� ���������� � ����
    vr_confirm_date := rec_from_pol.confirm_date;
  
    --���� ������ ��������
    vr_start_date := rec_from_pol.start_date;
  
    --���� ��������� ��������
    vr_end_date := rec_from_pol.end_date;
  
    --���� ������� �������
    vr_first_pay_date := rec_from_pol.first_pay_date;
  
    --ID ������������� ��������
    vr_payment_term_id := rec_from_pol.payment_term_id;
  
    --ID �����
    vr_period_id := rec_from_pol.period_id;
  
    --ID ������
    vr_agent_id_1 := NULL;
    vr_agent_id_2 := NULL;
  
    --ID ��������
    BEGIN
      SELECT contact_id
            ,department_id
        INTO vr_curator_id
            ,vr_department_id
        FROM v_pol_curator
       WHERE policy_id = p_from_policy_id;
    EXCEPTION
      WHEN no_data_found THEN
        vr_curator_id    := NULL;
        vr_department_id := NULL;
    END;
    pkg_policy.get_product_dept_person(p_to_product_id, vr_department_id, vr_curator_id);
  
    --����� � ����� ��������� �����
    --ID ��� �����
    SELECT product_id INTO vr_prod_osago_id FROM t_product WHERE brief IN ('�����');
  
    --ID ��� �����
    SELECT product_id
      INTO vr_prod_casco_id
      FROM t_product
     WHERE brief IN ('���������-�����������');
  
    IF rec_from_pol_hdr.product_id = vr_prod_osago_id
       AND p_to_product_id = vr_prod_osago_id
    THEN
      vr_osago_sign_ser := rec_from_pol.osago_sign_ser;
      vr_osago_sign_num := rec_from_pol.osago_sign_num;
    ELSE
      vr_osago_sign_ser := NULL;
      vr_osago_sign_num := NULL;
    END IF;
  
    --���-�� ��������� ������� �� ����������� ������
    vr_prev_event_count := NULL; --rec_from_pol_hdr.prev_event_count;
  
    --������������� ������ �������
    vr_fee_payment_term := rec_from_pol.fee_payment_term;
  
    --ID �����������������
    BEGIN
      SELECT pc.contact_id
        INTO vr_beneficiary_id
        FROM ven_p_policy_contact pc
        JOIN ven_t_contact_pol_role t
          ON t.id = pc.contact_policy_role_id
         AND t.brief = '�������������������'
       WHERE pc.policy_id = p_from_policy_id;
    EXCEPTION
      WHEN no_data_found THEN
        vr_beneficiary_id := vr_issuer_id;
    END;
  
    --������ �� ��������
    vr_fact_j := rec_from_pol.fact_j;
  
    --ID ��������� � ������� (�� �������)
    vr_ag_contract_id_1 := NULL;
    vr_ag_contract_id_2 := NULL;
  
    --����� ���������������� ��������
    vr_admin_cost := rec_from_pol.admin_cost;
  
    --������� ����������� ����� ��
    vr_is_park := rec_from_pol_hdr.is_park;
  
    --������� ��������� ��������
    vr_is_group_flag := rec_from_pol.is_group_flag;
  
    --����� ���������
    vr_notice_num := rec_from_pol.notice_num;
  
    --ID �������������� �������
    vr_waiting_period_id := rec_from_pol.waiting_period_id;
  
    --ID ����� ������
    vr_sales_action_id := rec_from_pol.sales_action_id;
  
    --ID �������
    vr_region_id := rec_from_pol.region_id;
  
    --ID ����-���������
    BEGIN
      SELECT pc.contact_id
        INTO vr_office_manager_id
        FROM ven_p_policy_contact pc
        JOIN ven_t_contact_pol_role t
          ON t.id = pc.contact_policy_role_id
         AND t.brief = '������������'
       WHERE pc.policy_id = rec_from_pol.policy_id;
    EXCEPTION
      WHEN no_data_found THEN
        vr_office_manager_id := NULL;
    END;
  
    --ID ������������� ���������
    BEGIN
      SELECT pc.contact_id
        INTO vr_region_manager_id
        FROM ven_p_policy_contact pc
        JOIN ven_t_contact_pol_role t
          ON t.id = pc.contact_policy_role_id
         AND t.brief = '�����������'
       WHERE pc.policy_id = rec_from_pol.policy_id;
    EXCEPTION
      WHEN no_data_found THEN
        vr_region_manager_id := NULL;
    END;
  
    --ID ������ �� ��������
    vr_discount_f_id := rec_from_pol.discount_f_id;
  
    --�������� ������ �������� �����������
    vr_description := rec_from_pol.description;
  
    --������������� �������
    vr_paymentoff_term_id := rec_from_pol.paymentoff_term_id;
  
    --�������� ��������
    vr_ph_description := rec_from_pol_hdr.description;
  
    --���� ������� �������
    vr_payment_start_date := rec_from_pol.payment_start_date;
  
    --ID ��������� �������
    vr_privilege_period := rec_from_pol.pol_privilege_period_id;
  
    --������� ������ ������� ���������
    vr_to_pol_hdr_id := pkg_policy.policy_insert(p_to_policy_id
                                                ,p_to_product_id
                                                ,vr_sales_channel_id
                                                ,vr_company_tree_id
                                                ,vr_fund_id
                                                ,vr_fund_pay_id
                                                ,vr_confirm_condition_id
                                                ,vr_pol_ser
                                                ,vr_pol_num
                                                ,vr_notice_date
                                                ,vr_sign_date
                                                ,vr_confirm_date
                                                ,vr_start_date
                                                ,vr_end_date
                                                ,vr_first_pay_date
                                                ,vr_payment_term_id
                                                ,vr_period_id
                                                ,vr_agent_id_1
                                                ,vr_agent_id_2
                                                ,vr_curator_id
                                                ,vr_issuer_id
                                                ,vr_osago_sign_ser
                                                ,vr_osago_sign_num
                                                ,vr_prev_event_count
                                                ,vr_fee_payment_term
                                                ,vr_beneficiary_id
                                                ,vr_fact_j
                                                ,vr_ag_contract_id_1
                                                ,vr_ag_contract_id_2
                                                ,vr_admin_cost
                                                ,vr_is_park
                                                ,vr_is_group_flag
                                                ,vr_notice_num
                                                ,vr_waiting_period_id
                                                ,vr_sales_action_id
                                                ,vr_region_id
                                                ,vr_office_manager_id
                                                ,vr_region_manager_id
                                                ,vr_discount_f_id
                                                ,vr_description
                                                ,vr_paymentoff_term_id
                                                ,vr_ph_description
                                                ,vr_payment_start_date
                                                ,vr_privilege_period);
    --������� �������
    UPDATE p_pol_header ph
       SET ph.t_prod_payment_order_id =
           (SELECT po.t_payment_order_id
              FROM t_payment_order po
             WHERE po.brief = 'PAYMENT_LIMIT_POLICY')
     WHERE ph.policy_header_id = vr_to_pol_hdr_id;
  
    --��������� �������
    INSERT INTO ven_p_policy_agent
      (ag_contract_header_id
      ,ag_type_rate_value_id
      ,date_end
      ,date_start
      ,part_agent
      ,policy_header_id
      ,status_date
      ,status_id)
      SELECT po.ag_contract_header_id
            ,po.ag_type_rate_value_id
            ,po.date_end
            ,po.date_start
            ,po.part_agent
            ,vr_to_pol_hdr_id
            ,po.status_date
            ,po.status_id
        FROM ven_p_policy_agent po
       WHERE po.policy_header_id = rec_from_pol.pol_header_id;
  
    FOR rec_agent IN (SELECT * FROM p_policy_agent pa WHERE pa.policy_header_id = vr_to_pol_hdr_id)
    LOOP
    
      i := pkg_agent.define_agent_prod_line(rec_agent.p_policy_agent_id
                                           ,rec_agent.ag_contract_header_id
                                           ,rec_agent.status_date);
    END LOOP;
  
    --pkg_agent.check_defined_commission
  
    --pkg_agent
  
    --  pkg_policy.PROLONGATION
  
    /** ��������� ������ �� ���������� �������� �� ���������� �������� � ������
    * @param p_coverid - �� ���������� ��������
    * @param p_agent_id - �� ������ �� �������� �����������
    * @param p_date - ���� ���������� �������� ������\
    * @return �� ������ � ag_prod_line_contr
    */
    /*  function pkg_agent.get_agent_rate_by_cover(p_p_cover_id number,
                                       p_agent_id   number,
                                       p_date       date) return number;
    */
    /*  ���������� ��������� ��������� ��� ������ �� �������� �����������
       * @author ������ ������,   ������� 2006
       * @param pv_policy_agent_id �� ������ ������ �� �������� �����������
       * @param p_ag_contract_header_id �� ���������� ��������
       * @param p_cur_date ���� �� ������� ������ �������� ��������� �������
    */
    /* function pkg_agent.Define_Agent_Prod_Line( pv_policy_agent_id in number,
                                       p_ag_contract_header_id in number,
                                       p_cur_date in date default sysdate) return number;
    */
  
    --������� �������� ����������� (��)
    IF p_to_product_id = vr_prod_casco_id
    THEN
      DECLARE
        vr_casco_asset_type_id NUMBER;
      BEGIN
        SELECT t_asset_type_id
          INTO vr_casco_asset_type_id
          FROM t_asset_type
         WHERE brief = 'AS_VEHICLE';
        pkg_asset.copy_as_asset(p_from_policy_id, p_to_policy_id, vr_casco_asset_type_id);
      END;
    ELSE
      IF p_to_product_id = vr_prod_osago_id
      THEN
        DECLARE
          vr_osago_asset_type_id NUMBER;
        BEGIN
          SELECT t_asset_type_id
            INTO vr_osago_asset_type_id
            FROM t_asset_type
           WHERE brief = 'AS_VEHICLE';
          pkg_asset.copy_as_asset(p_from_policy_id, p_to_policy_id, vr_osago_asset_type_id);
        END;
      ELSE
        pkg_asset.copy_as_asset(p_from_policy_id, p_to_policy_id);
      END IF;
    END IF;
  
    pkg_policy.update_policy_sum(p_to_policy_id);
    dbms_output.put_line(p_to_policy_id);
  END;

  --------------------------------------------------------------------------------
  --------------------------------------------------------------------------------

  PROCEDURE job_prolongation_p2
  (
    p_pol_id   NUMBER DEFAULT NULL
   ,flg_run_p3 NUMBER DEFAULT 1
  ) IS
    v_skip_flg     NUMBER;
    v_count        NUMBER;
    v_pr_policy_id NUMBER;
  
    v_new_policy_id NUMBER;
    v_temp_id       NUMBER;
  
    v_pol_type VARCHAR2(50);
  
    v_anniversary_date DATE;
  
  BEGIN
  
    v_pr_policy_id := 0;
  
    FOR cur IN (SELECT ll.brief
                      ,pc.p_cover_id
                      ,pp.policy_id
                      ,pph.policy_header_id
                      ,pp.start_date
                      ,pp.end_date
                      ,pp.payment_term_id
                      ,pp.paymentoff_term_id
                  FROM p_pol_header       pph
                      ,p_policy           pp
                      ,as_asset           aa
                      ,p_cover            pc
                      ,t_prod_line_option plo
                      ,t_product_line     pl
                      ,t_lob_line         ll
                      ,document           dc
                      ,doc_status_ref     dsr
                 WHERE pp.pol_header_id = pph.policy_header_id
                   AND pph.policy_header_id = nvl(p_pol_id, pph.policy_header_id)
                      -- 396202 ��������� �. ����� ������������ ������������� ������ ��������
                   AND pph.max_uncancelled_policy_id = pp.policy_id
                   AND pp.end_date > ADD_MONTHS(pp.start_date, 12)
                   AND aa.p_policy_id = pp.policy_id
                   AND pc.as_asset_id = aa.as_asset_id
                   AND plo.id = pc.t_prod_line_option_id
                   AND pl.id = plo.product_line_id
                   AND ll.t_lob_line_id = pl.t_lob_line_id
                   AND pl.is_avtoprolongation = 1
                      --18.09.2009 ����������� ����� ������ ������ ������ ��������, ��������
                      --AND doc.get_last_doc_status_brief(pp.POLICY_ID) IN ('CURRENT', 'ACTIVE', 'STOP')
                      -- ������ �.
                      -- ������ 165193
                      --and doc.get_last_doc_status_brief(pp.POLICY_ID) in ('CURRENT')
                   AND pp.policy_id = dc.document_id
                   AND dc.doc_status_ref_id = dsr.doc_status_ref_id
                   AND dsr.brief = 'CURRENT'
                      --
                   AND pc.end_date BETWEEN (SYSDATE) AND (SYSDATE + 30)
                 ORDER BY pp.policy_id)
    LOOP
    
      BEGIN
        SAVEPOINT start_loop;
      
        v_skip_flg := 0;
        v_count    := 0;
      
        --��������, ����� �� ����� ���� � ��� �� �����
        --�� ������ �_�������
      
        IF v_pr_policy_id = cur.policy_id
        THEN
          v_skip_flg := 1;
        ELSE
          v_pr_policy_id := cur.policy_id;
        END IF;
      
        IF upper(cur.brief) = 'WOP'
           AND v_skip_flg = 0
        THEN
          SELECT COUNT(1)
            INTO v_count
            FROM c_claim_header cch
                ,c_claim        cc
                ,c_damage       cd
                ,t_damage_code  dc
                ,document       doc
                ,doc_status_ref dsr
           WHERE cch.p_cover_id = cur.p_cover_id
             AND cc.c_claim_header_id = cch.c_claim_header_id
             AND cd.c_claim_id = cc.c_claim_id
             AND cc.seqno =
                 (SELECT MAX(a.seqno) FROM c_claim a WHERE a.c_claim_header_id = cch.c_claim_header_id)
                -- ������ �.
                -- ������ 165193
                --and doc.get_last_doc_status_brief(cc.C_CLAIM_ID) = 'CLOSE'
             AND cc.c_claim_id = doc.document_id
             AND doc.doc_status_ref_id = dsr.doc_status_ref_id
             AND dsr.brief = 'CLOSE'
                --
             AND dc.id = cd.t_damage_code_id
             AND dc.description = '������������ ��������������� 1 ��� 2 ������ ������������';
          IF v_count > 0
          THEN
            v_skip_flg := 1;
          END IF;
        END IF;
      
        v_count := 0;
      
        IF upper(cur.brief) = 'PWOP'
           AND v_skip_flg = 0
        THEN
          SELECT COUNT(1)
            INTO v_count
            FROM c_claim_header cch
                ,c_claim        cc
                ,c_damage       cd
                ,t_damage_code  dc
                ,document       doc
                ,doc_status_ref dsr
           WHERE cch.p_cover_id = cur.p_cover_id
             AND cc.c_claim_header_id = cch.c_claim_header_id
             AND cd.c_claim_id = cc.c_claim_id
             AND cc.seqno =
                 (SELECT MAX(a.seqno) FROM c_claim a WHERE a.c_claim_header_id = cch.c_claim_header_id)
                -- ������ �.
                -- ������ 165193
                --and doc.get_last_doc_status_brief(cc.C_CLAIM_ID) = 'CLOSE'
             AND cc.c_claim_id = doc.document_id
             AND doc.doc_status_ref_id = dsr.doc_status_ref_id
             AND dsr.brief = 'CLOSE'
                --
             AND dc.id = cd.t_damage_code_id
             AND dc.description = '������������ ��������������� 1 ��� 2 ������ ������������';
          IF v_count > 0
          THEN
            v_skip_flg := 1;
          END IF;
        END IF;
      
        --������ 02.08.2011  ������ �93942 ��������� ��������������� � ���� ���������
        SELECT CASE
                 WHEN anniversary_date <= pol_start_date THEN
                  ADD_MONTHS(to_date(anniversary_month || now_year, 'ddmmyyyy'), 12)
                 ELSE
                  to_date(anniversary_month || now_year, 'ddmmyyyy')
               END
          INTO v_anniversary_date
          FROM (SELECT to_char(ph.start_date, 'ddmm') anniversary_month --����.����� ���������
                      ,to_char(p.start_date, 'yyyy') now_year --������� ���
                      ,to_date(to_char(ph.start_date, 'dd') --����
                               || to_char(ph.start_date, 'mm') --�����
                               || to_char(p.start_date, 'yyyy')
                              ,'ddmmyyyy') anniversary_date
                      ,p.start_date pol_start_date
                
                  FROM p_pol_header ph
                      ,p_policy     p
                 WHERE p.policy_id = cur.policy_id
                   AND ph.policy_header_id = p.pol_header_id);
        --------------------------------------------------------------------------------------
      
        IF v_skip_flg = 0
        THEN
        
          BEGIN
          
            SELECT t_policy_change_type_id
              INTO v_temp_id
              FROM t_policy_change_type
             WHERE brief = '�����������';
          
            v_new_policy_id := pkg_policy.new_policy_version(par_policy_id             => cur.policy_id
                                                            ,par_change_id             => v_temp_id
                                                            ,par_policy_change_type_id => v_temp_id);
          
            BEGIN
            
              SELECT t_addendum_type_id
                INTO v_temp_id
                FROM t_addendum_type
               WHERE brief = '���������������';
            
              INSERT INTO ven_p_pol_addendum_type
                (p_policy_id, t_addendum_type_id)
              VALUES
                (v_new_policy_id, v_temp_id);
            
              /*exception
              when others then
                raise;*/
            END;
          
            /*UPDATE p_policy pp
                      SET pp.start_date = ADD_MONTHS(cur.start_date,12)
                        , pp.confirm_date = ADD_MONTHS(cur.start_date,12)
                        , pp.end_date = cur.end_date
                        , pp.NOTICE_DATE_ADDENDUM = ADD_MONTHS(cur.start_date,12)
                        , pp.CONFIRM_DATE_ADDENDUM = ADD_MONTHS(cur.start_date,12)
                      WHERE policy_id = v_new_policy_id;
            */
            --������ 02.08.2011  ������ �93942 ��������� ��������������� � ���� ���������
            UPDATE p_policy pp
               SET pp.start_date            = v_anniversary_date
                  ,pp.confirm_date          = v_anniversary_date
                  ,pp.end_date              = cur.end_date
                  ,pp.notice_date_addendum  = v_anniversary_date
                  ,pp.confirm_date_addendum = v_anniversary_date
             WHERE policy_id = v_new_policy_id;
            ----------------------------------------------------------------------------
          
            pkg_policy.update_policy_dates(v_new_policy_id);
          
            pkg_payment.delete_unpayed_pol(v_new_policy_id);
          
            SELECT pft.brief
              INTO v_pol_type
              FROM ven_p_policy           pol
                  ,ven_t_product          p
                  ,ven_p_pol_header       ph
                  ,ven_t_policy_form_type pft
             WHERE pol.policy_id = v_new_policy_id
               AND ph.policy_header_id = pol.pol_header_id
               AND ph.product_id = p.product_id
               AND p.t_policy_form_type_id = pft.t_policy_form_type_id(+);
          
            IF nvl(v_pol_type, '?') = '�����'
            THEN
              pkg_payment.policy_make_planning(pkg_policy.get_last_version(cur.policy_header_id)
                                              ,cur.payment_term_id
                                              ,'PAYMENT');
            ELSE
              pkg_payment.policy_make_planning(v_new_policy_id, cur.payment_term_id, 'PAYMENT');
            END IF;
          
            /*  exception
            when others then
              raise;*/
          END;
        
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          ROLLBACK TO SAVEPOINT start_loop;
      END;
    
    END LOOP;
  
    IF flg_run_p3 = 1
    THEN
      job_prolongation_p3(p_pol_id);
    END IF;
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20000, 'error in job.' || SQLERRM);
  END;

  PROCEDURE job_prolongation_p3(p_pol_id NUMBER DEFAULT NULL) IS
  
    v_skip_flg     NUMBER;
    v_pr_policy_id NUMBER;
  
  BEGIN
  
    v_pr_policy_id := 0;
  
    FOR cur IN (SELECT pp.policy_id
                  FROM p_pol_header       pph
                      ,p_policy           pp
                      ,as_asset           aa
                      ,p_cover            pc
                      ,t_prod_line_option plo
                      ,t_product_line     pl
                       --18.09.2009 ����������� ����� ������ �������� �������� �� ��� ������� "���������������"
                      ,p_pol_addendum_type ad
                 WHERE pp.pol_header_id = pph.policy_header_id
                   AND pph.policy_header_id = nvl(p_pol_id, pph.policy_header_id)
                   AND pp.version_num =
                       (SELECT MAX(a.version_num)
                          FROM p_policy a
                         WHERE a.pol_header_id = pph.policy_header_id)
                   AND pp.version_num >= 2
                      --18.09.2009 ����������� ����� ������ ��������� ������ ����� "=" ���� "<="
                      --AND TRUNC(pp.START_DATE) = TRUNC(SYSDATE)
                   AND trunc(pp.start_date) <= trunc(SYSDATE)
                   AND aa.p_policy_id = pp.policy_id
                   AND pc.as_asset_id = aa.as_asset_id
                   AND plo.id = pc.t_prod_line_option_id
                   AND pl.id = plo.product_line_id
                   AND pl.is_avtoprolongation = 1
                   AND ad.p_policy_id = pp.policy_id
                   AND ad.t_addendum_type_id = 18
                   AND doc.get_last_doc_status_brief(pp.policy_id) IN ('PROJECT')
                 ORDER BY pp.policy_id)
    LOOP
    
      v_skip_flg := 0;
    
      IF v_pr_policy_id = cur.policy_id
      THEN
        v_skip_flg := 1;
      ELSE
        v_pr_policy_id := cur.policy_id;
      END IF;
    
      IF v_skip_flg = 0
      THEN
        BEGIN
          SAVEPOINT sp1;
          check_policy_have_damage(cur.policy_id);
          doc.set_doc_status(cur.policy_id
                            ,'NEW'
                            ,doc.get_last_doc_status_date(cur.policy_id) + 1 / (24 * 60 * 60));
          --18.09.2009 ����������� ����� ������ �������� �������������� ������� � �����������
          doc.set_doc_status(cur.policy_id
                            ,'CURRENT'
                            ,doc.get_last_doc_status_date(cur.policy_id) + 1 / (24 * 60 * 60));
        EXCEPTION
          WHEN OTHERS THEN
            --RAISE_APPLICATION_ERROR(-20000, 'error in job.'||SQLERRM);
            ROLLBACK TO SAVEPOINT sp1;
        END;
      END IF;
    
    END LOOP;
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20000, SQLERRM);
  END;

  PROCEDURE check_policy_have_damage(p_pol_id NUMBER) IS
    v_count NUMBER;
  BEGIN
    SELECT COUNT(1)
      INTO v_count
      FROM p_pol_addendum_type pat
          ,t_addendum_type     tat
          ,as_asset            aa
          ,p_cover             pc
          ,c_damage            cd
          ,c_claim             cc
     WHERE pat.t_addendum_type_id = tat.t_addendum_type_id
       AND tat.brief = '���������������'
       AND pat.p_policy_id = get_previous_version(p_pol_id) --!!!!!!!!!!!!!
       AND aa.p_policy_id = pat.p_policy_id
       AND pc.as_asset_id = aa.as_asset_id
       AND cd.p_cover_id = pc.p_cover_id
       AND cc.c_claim_id = cd.c_claim_id
       AND doc.get_last_doc_status_brief(cc.c_claim_id) = 'CLOSE';
  
    IF v_count > 0
    THEN
      raise_application_error(-20000, '');
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20000, '�� ���������� ������ ���� ������.');
  END;

  FUNCTION is_assured_debitor(p_as_assured_id NUMBER) RETURN NUMBER IS
    is_deb NUMBER;
  BEGIN
  
    SELECT is_debtor INTO is_deb FROM ven_as_assured aa WHERE aa.as_assured_id = p_as_assured_id;
  
    RETURN is_deb;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN NULL;
  END;

  -- ������ �.
  -- ����������� ���� ��������� ������������ ������ �� ��������, � ������������ � ����� ��������� �������� ������ ��������
  PROCEDURE update_policy_agent_end_date(par_policy_id NUMBER) IS
    v_ver_num NUMBER;
  BEGIN
    SELECT pp.version_num INTO v_ver_num FROM p_policy pp WHERE pp.policy_id = par_policy_id;
    IF v_ver_num > 1
    THEN
      -- �������� �������� ������� ���������
      CASE doc.get_doc_status_brief(par_policy_id, to_date('31.12.3000', 'dd.mm.yyyy'))
        WHEN 'PROJECT' THEN
          -- ��������������� ���� ��������� �������� ����������� ������
          UPDATE p_policy_agent_doc ad
             SET ad.date_end =
                 (SELECT pp.end_date FROM p_policy pp WHERE pp.policy_id = par_policy_id)
           WHERE EXISTS (SELECT NULL
                    FROM p_policy pp
                   WHERE pp.policy_id = par_policy_id
                     AND ad.policy_header_id = pp.pol_header_id)
             AND doc.get_doc_status_brief(ad.p_policy_agent_doc_id) = 'CURRENT';
          IF SQL%ROWCOUNT = 0
          THEN
            raise_application_error(-20001
                                   ,'�������� ������ ���������. �� �������� ����������� ����� � ������� "�����������".');
          END IF;
        WHEN 'CANCEL' THEN
          -- ��������������� ���� ��������� �������� ���������� ������
          UPDATE p_policy_agent_doc ad
             SET ad.date_end = nvl((SELECT d.end_date
                                     FROM (SELECT pp.end_date
                                             FROM p_policy ph
                                                 ,p_policy pp
                                            WHERE ph.policy_id = par_policy_id
                                              AND ph.pol_header_id = pp.pol_header_id
                                              AND pp.version_num < ph.version_num
                                            ORDER BY pp.version_num DESC) d
                                    WHERE rownum = 1)
                                  ,ad.date_end)
           WHERE EXISTS (SELECT NULL
                    FROM p_policy pp
                   WHERE pp.policy_id = par_policy_id
                     AND ad.policy_header_id = pp.pol_header_id)
             AND doc.get_doc_status_brief(ad.p_policy_agent_doc_id) = 'CURRENT';
          IF SQL%ROWCOUNT = 0
          THEN
            raise_application_error(-20001
                                   ,'�������� ������ ���������. �� �������� ����������� ����� � ������� "�����������".');
          END IF;
        ELSE
          NULL;
      END CASE;
    END IF;
  END update_policy_agent_end_date;

  /*
    ������ �.
  
    ��������� ��������� ���������� ������-�������
  */
  PROCEDURE round_fee_sums(par_document_id NUMBER) IS
    v_is_altai NUMBER;
    CURSOR cur_covers IS
      SELECT pc.rowid AS rw
            ,CASE plt.brief
               WHEN 'RECOMMENDED' THEN
                ROUND(pc.fee, 2) +
                (ROUND(se.fee, 2) - SUM(ROUND(pc.fee, 2)) over(PARTITION BY se.as_asset_id))
               ELSE
                ROUND(pc.fee, 2)
             END AS rounded_cover_fee
        FROM as_asset            se
            ,p_cover             pc
            ,t_prod_line_option  plo
            ,t_product_line      pl
            ,t_product_line_type plt
            ,status_hist         sh
      /*,t_as_type_prod_line at*/
       WHERE se.p_policy_id = par_document_id
         AND se.as_asset_id = pc.as_asset_id
         AND pc.t_prod_line_option_id = plo.id
         AND plo.product_line_id = pl.id
         AND pl.product_line_type_id = plt.product_line_type_id
         AND pc.status_hist_id = sh.status_hist_id
         AND sh.brief != 'DELETED'
            /*AND at.product_line_id = pl.id
            AND NVL(at.is_ins_fee_agregate,0) = 0*/
         AND pl.t_lob_line_id NOT IN
             (SELECT lb.t_lob_line_id FROM ins.t_lob_line lb WHERE lb.brief = 'PEPR_INVEST_RESERVE');
  
    TYPE tt_rids IS TABLE OF UROWID;
    TYPE tt_rounded_fees IS TABLE OF NUMBER;
  
    vt_rid          tt_rids;
    vt_rounded_fees tt_rounded_fees;
  BEGIN
    SELECT COUNT(*)
      INTO v_is_altai
      FROM ins.t_product    prod
          ,ins.p_pol_header ph
          ,ins.p_policy     pol
     WHERE pol.policy_id = par_document_id
       AND pol.policy_id = ph.last_ver_id
       AND ph.product_id = prod.product_id
       AND prod.brief LIKE 'CR102%';
    IF v_is_altai = 0
    THEN
      /* �������� ����� � �������������� */
      UPDATE as_asset se SET se.fee = ROUND(se.fee, 2) WHERE se.p_policy_id = par_document_id;
      /* ��������� ����� � ��������, � �������������� ������� �� �������� ��������� */
      OPEN cur_covers;
    
      LOOP
        FETCH cur_covers BULK COLLECT
          INTO vt_rid
              ,vt_rounded_fees LIMIT 100;
      
        EXIT WHEN vt_rid.count = 0;
      
        FORALL v_idx IN vt_rid.first .. vt_rid.last
          UPDATE p_cover pc SET pc.fee = vt_rounded_fees(v_idx) WHERE pc.rowid = vt_rid(v_idx);
      END LOOP;
    
      CLOSE cur_covers;
    END IF;
  END round_fee_sums;

  PROCEDURE set_last_ver_id(par_policy_id NUMBER) IS
  BEGIN
    UPDATE p_pol_header ph
       SET ph.last_ver_id = par_policy_id
     WHERE ph.policy_header_id IN
           (SELECT pp.pol_header_id FROM p_policy pp WHERE pp.policy_id = par_policy_id);
  END set_last_ver_id;

  /*
  ����� �.
  ��������� ��� ���������� ��������� �� ������� �� � ��������� ��������
  ���� ������ ����������� ��� ������ ���� ;)
  */
  PROCEDURE check_creation_option
  (
    par_product_id          NUMBER
   ,par_fund_id             NUMBER
   ,par_fund_pay_id         NUMBER
   ,par_confirm_conds_id    NUMBER
   ,par_payment_term_id     NUMBER
   ,par_period_id           NUMBER
   ,par_waiting_period_id   NUMBER
   ,par_privilege_period_id NUMBER
   ,par_discount_f_id       NUMBER
  ) IS
    v_dummy_id NUMBER;
    v_product  dml_t_product.tt_t_product;
  BEGIN
  
    v_product := dml_t_product.get_record(par_product_id => par_product_id);
  
    IF v_product.enabled = 0
    THEN
      ex.raise_custom('������� �� �������, ������� �� ����� ���� �������.');
    END IF;
  
    IF par_fund_id IS NOT NULL
    THEN
      BEGIN
        SELECT pc.currency_id
          INTO v_dummy_id
          FROM t_prod_currency pc
         WHERE pc.product_id = par_product_id
           AND pc.currency_id = par_fund_id;
      EXCEPTION
        WHEN no_data_found THEN
          raise_application_error(-20001
                                 ,'�� ������� ������ ��������������� � ��������� ��������');
      END;
    END IF;
  
    IF par_fund_pay_id IS NOT NULL
    THEN
      BEGIN
        SELECT currency_id
          INTO v_dummy_id
          FROM t_prod_pay_curr pc
         WHERE pc.product_id = par_product_id
           AND pc.currency_id = par_fund_pay_id;
      EXCEPTION
        WHEN no_data_found THEN
          raise_application_error(-20001
                                 ,'��������� ������ ������� ���������� ��� ������� ��������');
      END;
    END IF;
  
    IF par_confirm_conds_id IS NOT NULL
    THEN
      BEGIN
        SELECT cc.confirm_condition_id
          INTO v_dummy_id
          FROM t_product_conf_cond cc
         WHERE cc.confirm_condition_id = par_confirm_conds_id
           AND cc.product_id = par_product_id;
      EXCEPTION
        WHEN no_data_found THEN
          raise_application_error(-20001
                                 ,'�� ������� ������� ���������� � ���� � ��������� ��������');
      END;
    END IF;
  
    IF par_payment_term_id IS NOT NULL
    THEN
      BEGIN
        SELECT pt.id
          INTO v_dummy_id
          FROM t_prod_payment_terms pt
              ,t_payment_terms      te
         WHERE pt.product_id = par_product_id
           AND pt.payment_term_id = par_payment_term_id
           AND pt.payment_term_id = te.id;
      EXCEPTION
        WHEN no_data_found THEN
          raise_application_error(-20001
                                 ,'�� ������ ��� ������ � ��������� ��������');
        WHEN too_many_rows THEN
          NULL;
      END;
    END IF;
  
    IF par_period_id IS NOT NULL
    THEN
      BEGIN
        SELECT pp.period_id
          INTO v_dummy_id
          FROM t_product_period  pp
              ,t_period_use_type ut
         WHERE pp.product_id = par_product_id
           AND pp.t_period_use_type_id = ut.t_period_use_type_id
           AND ut.brief = '���� �����������'
           AND pp.period_id = par_period_id;
      EXCEPTION
        WHEN no_data_found THEN
          raise_application_error(-20001
                                 ,'�� ������ ������ �������� � ��������� ��������');
      END;
    END IF;
  
    IF par_waiting_period_id IS NOT NULL
    THEN
      BEGIN
        SELECT pp.period_id
          INTO v_dummy_id
          FROM t_product_period  pp
              ,t_period_use_type ut
         WHERE pp.product_id = par_product_id
           AND pp.t_period_use_type_id = ut.t_period_use_type_id
           AND ut.brief = '�������������'
           AND pp.period_id = par_waiting_period_id;
      EXCEPTION
        WHEN no_data_found THEN
          raise_application_error(-20001
                                 ,'�� ������ ������������� ������ � ��������� ��������');
      END;
    END IF;
  
    IF par_privilege_period_id IS NOT NULL
    THEN
      BEGIN
        SELECT pp.period_id
          INTO v_dummy_id
          FROM t_product_period  pp
              ,t_period_use_type ut
         WHERE pp.product_id = par_product_id
           AND pp.t_period_use_type_id = ut.t_period_use_type_id
           AND ut.brief = '��������'
           AND pp.period_id = par_privilege_period_id;
      EXCEPTION
        WHEN no_data_found THEN
          raise_application_error(-20001
                                 ,'�� ������ �������� ������ � ��������� ��������');
      END;
    END IF;
  
    IF par_discount_f_id IS NOT NULL
    THEN
      BEGIN
        SELECT discount_f_id INTO v_dummy_id FROM discount_f WHERE discount_f_id = par_discount_f_id;
      EXCEPTION
        WHEN no_data_found THEN
          raise_application_error(-20001, '�� ������� ������ �� ��������');
      END;
    END IF;
  
  END check_creation_option;

  /*
    �������, ����������� DML �������� INSERT'� � ��������� � ������ ��������
  */
  FUNCTION create_policy_base
  (
    p_product_id              IN NUMBER
   ,p_sales_channel_id        IN NUMBER
   ,p_agency_id               IN NUMBER
   ,p_fund_id                 IN NUMBER
   ,p_fund_pay_id             IN NUMBER
   ,p_confirm_condition_id    IN NUMBER
   ,p_pol_ser                 IN VARCHAR2
   ,p_pol_num                 IN VARCHAR2
   ,p_notice_date             IN DATE
   ,p_sign_date               IN DATE
   ,p_confirm_date            IN DATE
   ,p_start_date              IN DATE
   ,p_end_date                IN DATE
   ,p_first_pay_date          IN DATE
   ,p_payment_term_id         IN NUMBER
   ,p_period_id               IN NUMBER
   ,p_issuer_id               IN NUMBER
   ,p_fee_payment_term        IN NUMBER
   ,p_fact_j                  IN NUMBER DEFAULT NULL
   ,p_admin_cost              IN NUMBER DEFAULT 0
   ,p_is_group_flag           IN NUMBER DEFAULT 0
   , -- ������ �. ������� null �� 0
    p_notice_num              IN VARCHAR2 DEFAULT NULL
   ,p_waiting_period_id       IN NUMBER DEFAULT NULL
   ,p_region_id               IN NUMBER DEFAULT NULL
   ,p_discount_f_id           IN NUMBER DEFAULT NULL
   ,p_description             IN VARCHAR2 DEFAULT NULL
   ,p_paymentoff_term_id      IN NUMBER DEFAULT NULL
   ,p_ph_description          IN VARCHAR2 DEFAULT NULL
   ,p_privilege_period        IN NUMBER DEFAULT NULL
   ,p_waiting_period_end_date IN DATE DEFAULT NULL
   , --����� �. ������ �� ������� ����� � � ������
    p_base_sum                IN NUMBER DEFAULT NULL
   ,p_is_credit               IN NUMBER DEFAULT NULL
  ) RETURN NUMBER IS
    v_pol_head_id NUMBER;
    v_policy_id   NUMBER;
  BEGIN
    BEGIN
      SELECT sq_p_pol_header.nextval INTO v_pol_head_id FROM dual;
      SELECT sq_p_policy.nextval INTO v_policy_id FROM dual;
      INSERT INTO ven_p_pol_header
        (policy_header_id
        ,num
        ,reg_date
        ,start_date
        ,doc_templ_id
        ,product_id
        ,sales_channel_id
        ,fund_id
        ,fund_pay_id
        ,confirm_condition_id
        ,policy_id
        ,is_new
        ,description
        ,agency_id)
        SELECT v_pol_head_id
              ,decode(p_pol_ser
                     ,NULL
                     ,decode(p_pol_num, NULL, '-', p_pol_num)
                     ,decode(p_pol_num, NULL, p_pol_ser, p_pol_ser || '-' || p_pol_num))
              ,SYSDATE
              ,p_start_date
              ,dt.doc_templ_id
              ,p_product_id
              ,p_sales_channel_id
              ,p_fund_id
              ,p_fund_pay_id
              ,p_confirm_condition_id
              ,v_policy_id
              ,1
              ,p_ph_description
              ,p_agency_id
          FROM ven_doc_templ dt
         WHERE dt.brief = 'POL_HEADER';
    
      INSERT INTO ven_p_policy
        (policy_id
        ,num
        ,reg_date
        ,doc_templ_id
        ,version_num
        ,pol_header_id
        ,pol_ser
        ,pol_num
        ,notice_date
        ,sign_date
        ,start_date
        ,confirm_date
        ,end_date
        ,first_pay_date
        ,ins_amount
        ,premium
        ,payment_term_id
        ,period_id
        ,fee_payment_term
        ,fact_j
        ,admin_cost
        ,is_group_flag
        ,notice_num
        ,waiting_period_id
        ,region_id
        ,discount_f_id
        ,description
        ,paymentoff_term_id
        ,pol_privilege_period_id
        ,confirm_date_addendum
        ,waiting_period_end_date
        ,base_sum
        ,is_credit)
        SELECT v_policy_id
              ,decode(p_pol_ser
                     ,NULL
                     ,decode(p_pol_num, NULL, '-', p_pol_num)
                     ,decode(p_pol_num, NULL, p_pol_ser, p_pol_ser || '-' || p_pol_num))
              ,SYSDATE
              ,dt.doc_templ_id
              ,1
              ,v_pol_head_id
              ,p_pol_ser
              ,p_pol_num
              ,p_notice_date
              ,p_sign_date
              ,p_start_date
              ,p_confirm_date
              ,p_end_date
              ,p_first_pay_date
              ,0
              ,0
              ,p_payment_term_id
              ,p_period_id
              ,p_fee_payment_term
              ,p_fact_j
              ,p_admin_cost
              ,nvl(p_is_group_flag, 0)
              ,p_notice_num
              ,p_waiting_period_id
              ,p_region_id
              ,p_discount_f_id
              ,p_description
              ,p_paymentoff_term_id
              ,p_privilege_period
              ,p_confirm_date
              ,p_waiting_period_end_date
              ,p_base_sum
              ,p_is_credit
          FROM ven_doc_templ dt
         WHERE dt.brief = 'POLICY';
    
    EXCEPTION
      WHEN pkg_oracle_exceptions.check_violated THEN
        raise_application_error(-20001
                               ,'��������� ����������� ��� ������� �������� �������� �����������.');
    END;
  
    -- ��������� ������������
    pkg_renlife_utils.add_policy_contact(v_policy_id, p_issuer_id, '������������');
  
    doc.set_doc_status(v_policy_id, 'PROJECT', p_start_date);
  
    RETURN v_pol_head_id;
  END;

  /*
     ����� �.
     ��������� �������������� �������� �������� �����������
  */
  PROCEDURE create_universal
  (
    par_product_brief       VARCHAR2
   ,par_ag_num              VARCHAR2
   ,par_start_date          DATE
   ,par_insuree_contact_id  NUMBER
   ,par_assured_array       pkg_asset.t_assured_array
   ,par_end_date            DATE DEFAULT NULL
   ,par_bso_number          NUMBER DEFAULT NULL
   ,par_bso_series_id       NUMBER DEFAULT NULL
   ,par_base_sum            NUMBER DEFAULT NULL
   ,par_is_credit           NUMBER DEFAULT 0
   ,par_ins_hobby_id        NUMBER DEFAULT NULL
   ,par_ins_work_group_id   NUMBER DEFAULT NULL
   ,par_ins_profession_id   NUMBER DEFAULT NULL
   ,par_pol_num             VARCHAR2 DEFAULT NULL
   ,par_pol_ser             VARCHAR2 DEFAULT NULL
   ,par_period_id           NUMBER DEFAULT NULL
   ,par_fund_id             NUMBER DEFAULT NULL
   ,par_fund_pay_id         NUMBER DEFAULT NULL
   ,par_paymentoff_term_id  NUMBER DEFAULT NULL
   ,par_confirm_date        DATE DEFAULT NULL
   ,par_notice_date         DATE DEFAULT NULL
   ,par_sign_date           DATE DEFAULT NULL
   ,par_confirm_conds_id    NUMBER DEFAULT NULL
   ,par_payment_term_id     NUMBER DEFAULT NULL
   ,par_waiting_period_id   NUMBER DEFAULT NULL
   ,par_privilege_period_id NUMBER DEFAULT NULL
   ,par_discount_f_id       NUMBER DEFAULT NULL
   ,par_notice_num          VARCHAR2 DEFAULT NULL
   ,par_admin_cost          NUMBER DEFAULT 0
   ,par_is_group_flag       NUMBER DEFAULT 0
   ,par_region_id           NUMBER DEFAULT NULL
   ,par_doc_properties      pkg_doc_properties.tt_doc_property DEFAULT NULL
   ,par_comment             VARCHAR2 DEFAULT NULL
   ,par_ph_comment          VARCHAR2 DEFAULT NULL
   ,par_policy_header_id    OUT NUMBER
   ,par_policy_id           OUT NUMBER
  ) IS
    v_policy_values           pkg_products.t_product_defaults;
    v_payment_terms_id        NUMBER;
    v_sales_channel_id        NUMBER;
    v_agency_id               NUMBER;
    v_region_id               NUMBER;
    v_ag_contract_header_id   NUMBER;
    v_end_date                DATE;
    v_waiting_period_end_date p_policy.waiting_period_end_date%TYPE;
    v_chars_in_num            NUMBER;
    v_bso_id                  NUMBER;
    v_fee_payment_term        NUMBER;
  
    FUNCTION check_calc_cover_on_creation(par_product_id t_product.product_id%TYPE) RETURN BOOLEAN IS
      v_custom_policy_calc_func_id t_product.custom_policy_calc_func_id%TYPE;
    BEGIN
      SELECT p.custom_policy_calc_func_id
        INTO v_custom_policy_calc_func_id
        FROM t_product p
       WHERE p.product_id = par_product_id;
    
      RETURN v_custom_policy_calc_func_id IS NULL;
    
    END check_calc_cover_on_creation;
  BEGIN
  
    v_policy_values := pkg_products.get_product_defaults(par_product_brief => par_product_brief);
  
    check_creation_option(par_product_id          => v_policy_values.product_id
                         ,par_fund_id             => par_fund_id
                         ,par_fund_pay_id         => par_fund_pay_id
                         ,par_confirm_conds_id    => par_confirm_conds_id
                         ,par_payment_term_id     => par_payment_term_id
                         ,par_period_id           => par_period_id
                         ,par_waiting_period_id   => par_waiting_period_id
                         ,par_privilege_period_id => par_privilege_period_id
                         ,par_discount_f_id       => par_discount_f_id);
  
    BEGIN
      SELECT nvl(cn.ag_sales_chn_id, ch.t_sales_channel_id) -- ��� ������� ������ ������ nvl
            ,cn.agency_id
            ,(SELECT kl.t_kladr_id FROM t_kladr kl WHERE ot.province_code = kl.code) region_id
            ,ch.ag_contract_header_id
        INTO v_sales_channel_id
            ,v_agency_id
            ,v_region_id
            ,v_ag_contract_header_id
        FROM ven_ag_contract_header ch
            ,ag_contract            cn
            ,department             dp
            ,organisation_tree      ot
       WHERE ch.last_ver_id = cn.ag_contract_id
         AND cn.agency_id = dp.department_id
         AND dp.org_tree_id = ot.organisation_tree_id
         AND ch.num = par_ag_num; -- ���������� �� �������� �������� �� �������
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20001
                               ,'�� ������� ����� ������, ���������, ������ � ������');
      WHEN too_many_rows THEN
        raise_application_error(-20001
                               ,'������� ��������� �������, ��������, �������� � ������');
    END;
  
    /* ���������� ���� ��������� �������� �� ������� */
    v_end_date := nvl(par_end_date
                     ,get_end_date(p_period_id  => nvl(par_period_id, v_policy_values.period_id)
                                  ,p_start_date => par_start_date));
  
    /* ��������� ���� ��������� �������������� ������� (� ������ ��������� ����������� ����)*/
    v_waiting_period_end_date := trunc(get_end_date(nvl(par_waiting_period_id
                                                       ,v_policy_values.waiting_period_id)
                                                   ,par_start_date));
  
    v_fee_payment_term := CASE v_policy_values.is_periodical
                            WHEN 0 THEN
                             1
                            ELSE
                             CEIL(MONTHS_BETWEEN(nvl(par_end_date, v_end_date), par_start_date) / 12)
                          END;
  
    /* ������� ������� */
    par_policy_header_id := create_policy_base(p_product_id              => v_policy_values.product_id
                                              ,p_sales_channel_id        => v_sales_channel_id
                                              ,p_agency_id               => v_agency_id
                                              ,p_fund_id                 => nvl(par_fund_id
                                                                               ,v_policy_values.fund_id)
                                              ,p_fund_pay_id             => nvl(par_fund_pay_id
                                                                               ,v_policy_values.fund_pay_id)
                                              ,p_confirm_condition_id    => nvl(par_confirm_conds_id
                                                                               ,v_policy_values.confirm_condition_id)
                                              ,p_pol_ser                 => par_pol_ser
                                              ,p_pol_num                 => par_pol_num
                                              ,p_notice_date             => nvl(par_notice_date
                                                                               ,par_start_date)
                                              ,p_sign_date               => nvl(par_sign_date
                                                                               ,par_start_date)
                                              ,p_confirm_date            => nvl(par_confirm_date
                                                                               ,par_start_date)
                                              ,p_start_date              => par_start_date
                                              ,p_end_date                => nvl(par_end_date
                                                                               ,v_end_date)
                                              ,p_first_pay_date          => par_start_date
                                              ,p_payment_term_id         => nvl(par_payment_term_id
                                                                               ,v_policy_values.payment_term_id)
                                              ,p_period_id               => nvl(par_period_id
                                                                               ,v_policy_values.period_id)
                                              ,p_issuer_id               => par_insuree_contact_id
                                              ,p_fee_payment_term        => v_fee_payment_term
                                              ,p_fact_j                  => NULL
                                              ,p_admin_cost              => nvl(par_admin_cost, 0)
                                              ,p_is_group_flag           => nvl(par_is_group_flag, 0)
                                              ,p_notice_num              => nvl(par_notice_num
                                                                               ,par_pol_num)
                                              ,p_waiting_period_id       => nvl(par_waiting_period_id
                                                                               ,v_policy_values.waiting_period_id)
                                              ,p_region_id               => nvl(par_region_id
                                                                               ,v_region_id)
                                              ,p_discount_f_id           => nvl(par_discount_f_id
                                                                               ,v_policy_values.discount_f_id)
                                              ,p_description             => par_comment
                                              ,p_paymentoff_term_id      => nvl(par_paymentoff_term_id
                                                                               ,v_policy_values.paymentoff_term_id)
                                              ,p_ph_description          => par_ph_comment
                                              ,p_privilege_period        => nvl(par_privilege_period_id
                                                                               ,v_policy_values.privilege_period_id)
                                              ,p_waiting_period_end_date => v_waiting_period_end_date
                                              ,p_base_sum                => par_base_sum
                                              ,p_is_credit               => nvl(par_is_credit, 0));
  
    /* ��������� ID ������ */
    SELECT policy_id
      INTO par_policy_id
      FROM p_pol_header
     WHERE policy_header_id = par_policy_header_id;
  
    IF par_doc_properties IS NOT NULL
       AND par_doc_properties.count > 0
    THEN
      pkg_doc_properties.add_properties_to_document(par_document_id        => par_policy_id
                                                   ,par_doc_property_array => par_doc_properties);
    END IF;
  
    /* ��������� ������ �� �������� */
    pkg_renlife_utils.add_policy_agent_doc(par_policy_header_id      => par_policy_header_id
                                          ,par_ag_contract_header_id => v_ag_contract_header_id);
  
    /* ��������� ���������� � ������������ */
    pkg_asset.create_insuree_info(p_pol_id        => par_policy_id
                                 ,p_work_group_id => par_ins_work_group_id
                                 ,p_hobby_id      => par_ins_hobby_id
                                 ,p_profession_id => par_ins_profession_id);
  
    pkg_asset.create_assured_from_array(par_policy_id        => par_policy_id
                                       ,par_as_assured_array => par_assured_array
                                       ,par_calc_on_creation => check_calc_cover_on_creation(v_policy_values.product_id));
  
    pkg_policy.update_policy_dates(p_pol_id => par_policy_id);
  
    /* ����������� ��� */
    IF par_bso_number IS NOT NULL
    THEN
      /*pkg_bso.Attach_Bso_To_Policy(par_product_id    => v_policy_values.product_id
                                  ,par_policy_id     => par_policy_id
                                  ,par_pol_header_id => par_policy_header_id
                                  ,par_notice_num    => par_bso_number
      ,par_bso_series    => par_bso_series_id);*/
      v_bso_id := pkg_bso.find_bso_by_num(par_policy_id     => par_policy_id
                                         ,par_bso_num       => par_bso_number
                                         ,par_bso_series_id => par_bso_series_id);
    
      pkg_bso.attach_bso_to_policy(par_policy_id  => par_policy_id
                                  ,par_bso_id     => v_bso_id
                                  ,par_is_pol_num => 1);
    END IF;
  
  END create_universal;

  /* sergey.ilyushkin 25/07/2012
    ����������� � ��������� ������-������
    @param par_policy_id - �� ������ ��������, ��� ������� ����������� ��������� ������
  */
  PROCEDURE set_prev_ver_id(par_policy_id NUMBER) IS
    v_parent_policy_id NUMBER := NULL;
  BEGIN
    BEGIN
      WITH pol_parent AS
       (SELECT MAX(pp1.version_num) AS version_num
              ,pp1.pol_header_id
          FROM p_policy       pp
              ,ven_p_policy   pp1
              ,doc_status_ref dsf
         WHERE pp.policy_id = par_policy_id
           AND pp1.pol_header_id = pp.pol_header_id
           AND pp1.version_num < pp.version_num
           AND dsf.doc_status_ref_id = pp1.doc_status_ref_id
           AND dsf.brief NOT IN ('CANCEL')
         GROUP BY pp1.pol_header_id)
      SELECT policy_id
        INTO v_parent_policy_id
        FROM p_policy pp
            ,pol_parent
       WHERE pp.pol_header_id = pol_parent.pol_header_id
         AND pp.version_num = pol_parent.version_num;
    EXCEPTION
      WHEN no_data_found THEN
        v_parent_policy_id := NULL;
      WHEN OTHERS THEN
        raise_application_error(-20000
                               ,'�� ������� ���������� ������-������. ' || SQLERRM);
    END;
  
    IF v_parent_policy_id IS NOT NULL
    THEN
      UPDATE p_policy SET prev_ver_id = v_parent_policy_id WHERE policy_id = par_policy_id;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20000
                             ,'�� ������� ���������� ������-������. ' || SQLERRM);
  END set_prev_ver_id;

  /* sergey.ilyushkin 30/07/2012
  ���������� �������� (�� � ������� �������) ������-������
  @param par_policy_id - �� ������ ��������
  @return - �� ������-������
  */
  FUNCTION get_active_prev_ver_id(par_policy_id NUMBER) RETURN NUMBER IS
    v_active_prev_ver_id NUMBER := NULL;
  BEGIN
    SELECT prev_ver_id INTO v_active_prev_ver_id FROM p_policy WHERE policy_id = par_policy_id;
  
    IF doc.get_doc_status_brief(v_active_prev_ver_id) = 'CANCEL'
    THEN
      v_active_prev_ver_id := get_active_prev_ver_id(v_active_prev_ver_id);
    END IF;
  
    RETURN v_active_prev_ver_id;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END get_active_prev_ver_id;

  /* sergey.ilyushkin 13/08/2012
    ���������� �� ��������� �������� ������ ��������
    (� ��������� ������ ��� ��������� ������ �� � ������� "�������")
    @param par_policy_id - �� ������ ��������
    @return - �� ��������� �������� ������ ��������
  */
  FUNCTION get_last_active_version(par_policy_id NUMBER) RETURN NUMBER IS
    v_return NUMBER := NULL;
  BEGIN
    SELECT policy_id
      INTO v_return
      FROM (SELECT pp.policy_id
              FROM ven_p_policy   pp
                  ,ven_p_policy   pp1
                  ,doc_status_ref dsr
             WHERE dsr.doc_status_ref_id = pp.doc_status_ref_id
               AND dsr.brief NOT IN ('CANCEL')
               AND pp.pol_header_id = pp1.pol_header_id
               AND pp1.policy_id = par_policy_id
             ORDER BY pp.version_num DESC)
     WHERE rownum = 1;
  
    RETURN v_return;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END get_last_active_version;

  /*
    @author ������ �.
  
    ��������� ID ��������� �� �� ���
    @param par_ids - ��� ��������
    @param par_raise_on_error - TRUE: ���������� ������; FALSE: ���
  
    @return �� ��������� �������� �����������
  */
  FUNCTION get_policy_header_by_ids
  (
    par_ids            p_pol_header.ids%TYPE
   ,par_raise_on_error BOOLEAN DEFAULT TRUE
  ) RETURN p_pol_header.policy_header_id%TYPE IS
    v_pol_header_id p_pol_header.policy_header_id%TYPE;
  BEGIN
    assert_deprecated(par_ids IS NULL, '��� �������� �� ������');
    BEGIN
      SELECT ph.policy_header_id INTO v_pol_header_id FROM p_pol_header ph WHERE ph.ids = par_ids;
    EXCEPTION
      WHEN no_data_found THEN
        IF par_raise_on_error
        THEN
          raise_application_error(-20001
                                 ,'�� ������ ��������� �������� ����������� �� ���');
        ELSE
          v_pol_header_id := NULL;
        END IF;
    END;
  
    RETURN v_pol_header_id;
  END get_policy_header_by_ids;

  /*
    @author ������ �.
  
    ��������� ID ��������� �� �� ������/����� �� (�� ��������� ������)
    @param par_pol_num - ����� ��������
    @param par_pol_ser - ����� ��������
    @param par_raise_on_error - TRUE: ���������� ������; FALSE: ���
  
    @return �� ��������� �������� �����������
  */
  FUNCTION get_policy_header_by_num
  (
    par_pol_num        p_policy.pol_num%TYPE
   ,par_pol_ser        p_policy.pol_ser%TYPE DEFAULT NULL
   ,par_raise_on_error BOOLEAN DEFAULT TRUE
  ) RETURN p_pol_header.policy_header_id%TYPE IS
    v_pol_header_id p_pol_header.policy_header_id%TYPE;
  BEGIN
    assert_deprecated(par_pol_num IS NULL, '����� �������� �� ������');
    BEGIN
      SELECT ph.policy_header_id
        INTO v_pol_header_id
        FROM p_policy     pp
            ,p_pol_header ph
       WHERE ph.last_ver_id = pp.policy_id
         AND pp.pol_num = par_pol_num
         AND (par_pol_ser IS NULL OR par_pol_ser IS NOT NULL AND pp.pol_ser = par_pol_ser);
    EXCEPTION
      WHEN no_data_found THEN
        IF par_raise_on_error
        THEN
          raise_application_error(-20001
                                 ,'�� ������ ��������� �������� ����������� �� ������');
        ELSE
          v_pol_header_id := NULL;
        END IF;
      WHEN too_many_rows THEN
        IF par_raise_on_error
        THEN
          raise_application_error(-20001
                                 ,'������� ��������� ���������� ��������� ����������� �� ������');
        ELSE
          v_pol_header_id := NULL;
        END IF;
    END;
  
    RETURN v_pol_header_id;
  END get_policy_header_by_num;

  FUNCTION get_policy_header_id(par_policy_id p_policy.policy_id%TYPE)
    RETURN p_pol_header.policy_header_id%TYPE IS
    v_pol_header_id p_pol_header.policy_header_id%TYPE;
  BEGIN
    SELECT pp.pol_header_id INTO v_pol_header_id FROM p_policy pp WHERE pp.policy_id = par_policy_id;
    RETURN v_pol_header_id;
  EXCEPTION
    WHEN no_data_found THEN
      raise_application_error(-20001
                             ,'�� ������� ����� ��������� �������� �����������');
  END;

  FUNCTION get_start_date_by_conf_conds
  (
    par_product_id     NUMBER
   ,par_sign_date      DATE
   ,par_conf_conds_id  NUMBER DEFAULT NULL
   ,par_first_pay_date DATE DEFAULT NULL
  ) RETURN DATE IS
    v_conf_conds_brief t_confirm_condition.brief%TYPE;
  BEGIN
    IF par_conf_conds_id IS NULL
    THEN
      SELECT brief
        INTO v_conf_conds_brief
        FROM t_confirm_condition cc
            ,t_product_conf_cond pcc
       WHERE cc.id = pcc.confirm_condition_id
         AND pcc.product_id = par_product_id
         AND (pcc.is_default = 1 OR
             (SELECT COUNT(*) FROM t_product_conf_cond pcc1 WHERE pcc1.product_id = pcc.product_id) = 1);
    ELSE
      BEGIN
        SELECT brief
          INTO v_conf_conds_brief
          FROM t_confirm_condition cc
              ,t_product_conf_cond pcc
         WHERE cc.id = pcc.confirm_condition_id
           AND pcc.product_id = par_product_id
           AND cc.id = par_conf_conds_id;
      EXCEPTION
        WHEN no_data_found THEN
          raise_application_error(-20001
                                 ,'��� ������� �������� ��������� ������� ���������� � ���� �� ���������');
      END;
    END IF;
  
    RETURN par_sign_date;
  
  END get_start_date_by_conf_conds;

  /**�������� ������� �������� � �������� �������
  * �� ������ ��, ����� �� ������ �������
  * , ������������� �� ������� ���������� �� �є
  * , ������������� �� ������� ���������� �������������
  * �� 237380: ������ �� ���������� ��������� �������� ���������
  * @autor ������ �.�
  * @param par_policy - ������ ��
  */
  PROCEDURE check_policy_trans_in_closed(par_policy_id NUMBER) IS
    v_is_closed NUMBER;
  BEGIN
  
    SELECT COUNT(1)
      INTO v_is_closed
      FROM dual
     WHERE --���� ��� �������� �� ������ ��������� � ������� ����� ���������
     EXISTS (SELECT 1
        FROM trans tr
            ,oper  op
       WHERE tr.oper_id = op.oper_id
         AND tr.a2_dt_ure_id = 283
         AND tr.a2_dt_uro_id = par_policy_id
         AND pkg_period_closed.check_date_in_closed(tr.trans_date) = 1)
    -- ��������� � ������� ����� ��������
     OR EXISTS (SELECT 1
        FROM trans tr
            ,oper  op
       WHERE tr.oper_id = op.oper_id
         AND op.document_id = par_policy_id
         AND pkg_period_closed.check_date_in_closed(tr.trans_date) = 1)
    -- ��������� � ������� ����� 'PAYMENT', 'PAYORDER', 'PAYORDER_SETOFF'
     OR EXISTS (SELECT 1
        FROM trans     tr
            ,oper      op
            ,doc_doc   dd
            ,document  dc
            ,doc_templ dt
       WHERE tr.oper_id = op.oper_id
         AND op.document_id = dc.document_id
         AND dc.doc_templ_id = dt.doc_templ_id
         AND dt.brief IN ('PAYMENT', 'PAYORDER', 'PAYORDER_SETOFF')
         AND dc.document_id = dd.child_id
         AND dd.parent_id = par_policy_id
         AND pkg_period_closed.check_date_in_closed(tr.trans_date) = 1);
  
    IF v_is_closed = 1
    THEN
      raise_application_error('-20000'
                             ,'��������! �� ������ �������� ���������� �������� � �������� �������, �������������� ������� ��������� ��������');
    END IF;
  
  END check_policy_trans_in_closed;

  -- Author  : �������� �.�.
  -- Created : 04.12.2013
  -- Purpose : 286625: ������ ������ 1950005200 ������ ������
  -- Comment : ��������� ��������� ���� ������ ����� ������ �� � ����� ������ ����:
  --           ���� ������ ������ �� �������� ���������� ��
  --           � ��� �� "��������� �������"
  --           ��� ��� ��������� �� ������ ���������� ��������
  --                                ��������� ����� ������ ��������
  --                                �������������� �������� ���������
  --                                �������������� ����� ��������
  PROCEDURE check_new_policy_date(par_p_policy_id p_policy.policy_id%TYPE) AS
    v_confirm_date           p_policy.confirm_date%TYPE;
    v_policy_start_date_ddmm VARCHAR2(4);
    v_pol_header_id          p_policy.pol_header_id%TYPE;
    v_is_group_flag          p_policy.is_group_flag%TYPE;
  
    --�������� �� ���������.
    FUNCTION is_anniversary_date
    (
      par_policy_start_date_ddmm VARCHAR2
     ,par_policy_header_id       p_pol_header.policy_header_id%TYPE
    ) RETURN BOOLEAN IS
      v_is_anniversary_date    BOOLEAN;
      v_header_start_date_ddmm VARCHAR2(4);
    BEGIN
      SELECT to_char(ph.start_date, 'ddmm')
        INTO v_header_start_date_ddmm
        FROM p_pol_header ph
       WHERE ph.policy_header_id = par_policy_header_id;
    
      IF v_header_start_date_ddmm = '2902'
      THEN
        v_is_anniversary_date := par_policy_start_date_ddmm IN ('2902', '2802');
      ELSE
        v_is_anniversary_date := par_policy_start_date_ddmm = v_header_start_date_ddmm;
      END IF;
    
      RETURN v_is_anniversary_date;
    
    END is_anniversary_date;
  
    --�������� �� ���� ���������
    FUNCTION is_addend_in_allowed_list(par_pol_id p_policy.policy_id%TYPE) RETURN BOOLEAN IS
      v_fnd NUMBER(1);
    BEGIN
      SELECT COUNT(*)
        INTO v_fnd
        FROM dual
       WHERE EXISTS (SELECT NULL
                FROM p_pol_addendum_type a
                    ,t_addendum_type     t
               WHERE a.t_addendum_type_id = t.t_addendum_type_id
                 AND t.brief IN ('COL_METHOD_CHANGE'
                                ,'FIN_WEEK'
                                ,'RECOVER_MAIN'
                                ,'FULL_POLICY_RECOVER'
                                ,'WRONGFUL_TERM_POLICY_RECOVER')
                 AND a.p_policy_id = par_pol_id);
      RETURN v_fnd = 1;
    END is_addend_in_allowed_list;
  
    --��������� �������� ��������� �������
  BEGIN
    BEGIN
      SELECT is_group_flag
            ,to_char(start_date, 'ddmm')
            ,pp.pol_header_id
        INTO v_is_group_flag
            ,v_policy_start_date_ddmm
            ,v_pol_header_id
        FROM p_policy pp
       WHERE pp.policy_id = par_p_policy_id;
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20001
                               ,'������ �������� ����������� �� ����������');
    END;
    /*
    ������ ����:
    ���� ������ ������ �� �������� ���������� ��
    � ��� �� "��������� �������"
    ��� ��� ��������� �� ������ ���������� ��������
                         ��������� ����� ������ ��������
                         �������������� �������� ���������
                         �������������� ����� ��������
    */
    IF v_is_group_flag = 0
       AND NOT is_anniversary_date(v_policy_start_date_ddmm, v_pol_header_id)
       AND NOT is_addend_in_allowed_list(par_p_policy_id)
    THEN
      raise_application_error(-20000
                             ,'��������! ��� ����������� ��������� ��� ������ � ����� ��������� ������ ���������� ��������, ��������� ����� ������ ��������, �������������� �������� ���������, �������������� ����� �������� � ���� ������ ������ ������ ���� ����� ���� ��������� ���������;');
    END IF;
  END check_new_policy_date;

  FUNCTION get_first_uncanceled_version(par_policy_header_id p_pol_header.policy_header_id%TYPE)
    RETURN p_policy.policy_id%TYPE IS
    v_first_uncanceled_version_id p_policy.policy_id%TYPE;
  BEGIN
    SELECT pp.policy_id
      INTO v_first_uncanceled_version_id
      FROM p_policy pp
     WHERE pp.pol_header_id = par_policy_header_id
       AND pp.version_num = (SELECT MIN(pp1.version_num)
                               FROM p_policy       pp1
                                   ,document       d
                                   ,doc_status_ref dsr
                              WHERE pp1.pol_header_id = pp.pol_header_id
                                AND pp1.policy_id = d.document_id
                                AND d.doc_status_ref_id = dsr.doc_status_ref_id
                                AND dsr.brief NOT IN ('CANCEL', 'B2B_NO_APPROVED'));
    RETURN v_first_uncanceled_version_id;
  EXCEPTION
    WHEN no_data_found THEN
      raise_application_error(-20001
                             ,'�� ������� ���������� ������ ������������ ������ ��������');
  END get_first_uncanceled_version;

  /*
  ������� �.�.
  ������� �������� ������������� ������������ ������ � ��������. ���������� TRUE, ���� ���������� ���� ��
  ���� ������������ ������, � FALSE, ���� ����� ������ �� �������
  */

  FUNCTION is_pol_header_canceled(par_policy_header_id p_pol_header.policy_header_id%TYPE)
    RETURN BOOLEAN IS
    v_version_exists NUMBER;
  BEGIN
    SELECT COUNT(*)
      INTO v_version_exists
      FROM p_policy       pp
          ,document       d
          ,doc_status_ref dsr
     WHERE pp.pol_header_id = par_policy_header_id
       AND pp.policy_id = d.document_id
       AND d.doc_status_ref_id = dsr.doc_status_ref_id
       AND dsr.brief NOT IN ('CANCEL', 'B2B_NO_APPROVED');
    RETURN v_version_exists != 0;
  END is_pol_header_canceled;
  /*
    ������ �.
    255495
    ����������� ������� � ������ ������� ������ ������ �� ������� �������� ��������� � ������ Credit life (��������� ��������):
    ������� ����������� - ������� ����� ���� ��� � ��������� (������������ �������� pkg_bso.unlink_bso_policy ),
      �������� ����� ��������,
      ����� ��� ��������,
      ����� ���������.
    ������� �� ����������� - ��������� ������ �� ��������\��������;
  
    ��������� ��������� �� �������� ��������:
    ������ - �������
    �������� ������ - ������� (����������� �� ������ 237830)
  */
  PROCEDURE unlink_bso_from_credit_policy(par_policy_id p_policy.policy_id%TYPE) IS
    v_pol_header_id        p_policy.pol_header_id%TYPE;
    v_product_id           t_product.product_id%TYPE;
    v_is_credit_life_group NUMBER(1);
  BEGIN
    SELECT pp.pol_header_id
          ,ph.product_id
      INTO v_pol_header_id
          ,v_product_id
      FROM p_policy     pp
          ,p_pol_header ph
     WHERE pp.policy_id = par_policy_id
       AND pp.pol_header_id = ph.policy_header_id
       AND pp.version_num = 1;
    -- ��������, ������ �� ������� � ������ ��������� Credit life
    SELECT COUNT(1)
      INTO v_is_credit_life_group
      FROM dual
     WHERE EXISTS (SELECT NULL
              FROM t_product_group pg
                  ,t_product       pr
             WHERE pg.brief = 'Credit life'
               AND pg.t_product_group_id = pr.t_product_group_id
               AND pr.product_id = v_product_id
            --������ /������� union �� ������ 301244/
            UNION
            SELECT NULL
              FROM ins.t_product pr
             WHERE pr.product_id = v_product_id
               AND pr.brief IN ('GN', 'GPN', 'GRN'));
    IF v_is_credit_life_group = 1
    THEN
      pkg_bso.unlink_bso_policy(p_pol_header_id => v_pol_header_id);
      UPDATE p_pol_header ph SET ph.ids = NULL WHERE ph.policy_header_id = v_pol_header_id;
    
      UPDATE p_policy pp
         SET pp.pol_ser    = NULL
            ,pp.pol_num    = NULL
            ,pp.notice_num = NULL
       WHERE pp.policy_id = par_policy_id;
    
      UPDATE g_policy gp
         SET gp.note = nvl('���: ' || to_char(gp.ids), gp.note)
            ,gp.ids  = NULL
       WHERE gp.p_pol_header_id = v_pol_header_id;
    END IF;
  EXCEPTION
    WHEN no_data_found THEN
      -- ���� ������ �� ������, ������ �� ������
      NULL;
  END unlink_bso_from_credit_policy;

  /*
    ����� �.
    ��������� ���� ��������� ������ �����
  */
  FUNCTION get_risk_pricing_end_date(par_policy_id p_policy.policy_id%TYPE) RETURN DATE IS
    v_risk_pricing_end_date DATE;
  BEGIN
    SELECT MAX(ds.start_date)
      INTO v_risk_pricing_end_date
      FROM doc_status     ds
          ,doc_status_ref dsr
     WHERE ds.document_id = par_policy_id
       AND ds.doc_status_ref_id = dsr.doc_status_ref_id
       AND dsr.brief = 'ACTIVE';
  
    RETURN v_risk_pricing_end_date;
  
  END get_risk_pricing_end_date;

  -- Author  : �������� �.�.
  -- Created : 19.03.2014
  -- Purpose : 315513  ���� ������ ��������/������ ������ � ���������� 2014
  -- Param   : pol_header_id
  --           par_return_info: 'brief'/'descr'/'group'
  -- Comment : ������� ���������� ����� ���������� ����/��������/������ ������ ������.
  FUNCTION get_pol_sales_chn
  (
    par_pol_header  NUMBER
   ,par_return_info VARCHAR2 := NULL
  ) RETURN ins.t_sales_channel.description%TYPE IS
    var_sales_chn ins.t_sales_channel.description%TYPE;
  BEGIN
    BEGIN
      SELECT decode(par_return_info, 'brief', br, 'descr', des, 'group', gr, br)
        INTO var_sales_chn
        FROM (SELECT agsc.brief         br
                    ,agsc.description   des
                    ,agsc.descr_for_rep gr
              
                FROM ins.p_policy_agent_doc pad
                    ,ins.ag_contract_header ach
                    ,ins.t_sales_channel    agsc
                    ,document               d
                    ,doc_status_ref         r
              
               WHERE pad.ag_contract_header_id = ach.ag_contract_header_id
                 AND ach.t_sales_channel_id = agsc.id
                 AND pad.p_policy_agent_doc_id = d.document_id
                 AND r.doc_status_ref_id = d.doc_status_ref_id
                 AND r.brief = 'CURRENT'
                 AND pad.policy_header_id = par_pol_header
               ORDER BY pad.date_begin DESC NULLS LAST) t
       WHERE rownum = 1;
    EXCEPTION
      WHEN no_data_found THEN
        var_sales_chn := NULL;
    END;
  
    IF var_sales_chn IS NULL
    THEN
      BEGIN
        SELECT decode(par_return_info, 'brief', br, 'descr', des, 'group', gr, br)
          INTO var_sales_chn
          FROM (SELECT sc.brief         br
                      ,sc.description   des
                      ,sc.descr_for_rep gr
                  FROM ins.p_pol_header    h
                      ,ins.t_sales_channel sc
                 WHERE h.sales_channel_id = sc.id
                   AND h.policy_header_id = par_pol_header) t;
      EXCEPTION
        WHEN no_data_found THEN
          var_sales_chn := NULL;
      END;
    END IF;
  
    RETURN var_sales_chn;
  END get_pol_sales_chn;

  -- Author  : �������� �.�.
  -- Created : 19.03.2014
  -- Purpose : 315513  ���� ������ ��������/������ ������ � ���������� 2014
  -- Param   : pol_header_id
  -- Comment : ���������� �������� ������ ���������� �������� �� �����������, ��� ���� ��������� ����� GN.
  --           ���� ������� GN:
  --                ���� ����� ������ ���������� �� Group Credit life
  --                ���� � �������� ���� '��������� �1 ��������� ����������� �����'
  --                                     '��������� �4 ������� � ��������� ������� � ������ ������'
  --                     �� 'Group END'
  --                ����� Group Term/PA
  FUNCTION get_pol_product_group(par_pol_header NUMBER) RETURN ins.t_product_group.name%TYPE IS
    var_prod_gr ins.t_product_group.name%TYPE;
  BEGIN
    SELECT decode(p.brief
                 ,'GN'
                 ,CASE
                    WHEN get_pol_sales_chn(par_pol_header, 'brief') = 'BANK' THEN
                     'Group Credit life'
                    WHEN 1 = (SELECT COUNT(1)
                                FROM dual
                               WHERE EXISTS (SELECT NULL
                                        FROM ins.p_policy           pp
                                            ,ins.p_pol_header       ph
                                            ,ins.as_asset           aa
                                            ,ins.p_cover            pc
                                            ,ins.t_prod_line_option plo
                                            ,ins.t_product_line     pl
                                            ,ins.t_lob_line         ll
                                       WHERE pp.pol_header_id = ph.policy_header_id
                                         AND pp.policy_id = aa.p_policy_id
                                         AND aa.as_asset_id = pc.as_asset_id
                                         AND pc.t_prod_line_option_id = plo.id
                                         AND plo.product_line_id = pl.id
                                         AND ll.t_lob_line_id = pl.t_lob_line_id
                                         AND ll.description IN
                                             ('��������� �1 ��������� ����������� �����'
                                             ,'��������� �4 ������� � ��������� ������� � ������ ������')
                                         AND ph.policy_header_id = h.policy_header_id)) THEN
                     'Group END'
                    ELSE
                     'Group Term/PA'
                  END
                 ,pg.name) AS product_group_name
      INTO var_prod_gr
      FROM ins.p_pol_header    h
          ,ins.t_product       p
          ,ins.t_product_group pg
     WHERE p.product_id = h.product_id
       AND p.t_product_group_id = pg.t_product_group_id(+)
       AND h.policy_header_id = par_pol_header;
    RETURN var_prod_gr;
  END get_pol_product_group;

  /*
    ������ �.
    http://redmine.renlife.com/issues/1373
    �������� � ��������� �� ������� "ID ������������ �� ���������� ������"
  */
  PROCEDURE set_max_uncancelled_policy_id(par_policy_id NUMBER) IS
    v_policy_header_id p_pol_header.policy_header_id%TYPE;
    v_policy_id        p_policy.policy_id%TYPE;
  BEGIN
    SELECT pp.pol_header_id
      INTO v_policy_header_id
      FROM ins.p_policy pp
     WHERE pp.policy_id = par_policy_id;
  
    BEGIN
      SELECT MAX(pp.policy_id)
        INTO v_policy_id
        FROM p_policy       pp
            ,document       d
            ,doc_status_ref dsr
       WHERE 1 = 1
         AND pp.policy_id = d.document_id
         AND d.doc_status_ref_id = dsr.doc_status_ref_id
         AND dsr.brief <> 'CANCEL'
         AND pp.pol_header_id = v_policy_header_id
       GROUP BY pp.pol_header_id;
    EXCEPTION
      --������ 331833: ����������� ������������ ������������ ������
      WHEN no_data_found THEN
        v_policy_id := NULL;
    END;
    UPDATE p_pol_header ph
       SET ph.max_uncancelled_policy_id = v_policy_id
     WHERE ph.policy_header_id = v_policy_header_id;
  END set_max_uncancelled_policy_id;

  /*
    ������ �.
    198225 ���������� ������� ���������
  */
  PROCEDURE check_agregation(par_policy_id NUMBER) IS
  BEGIN
    FOR cur IN (SELECT pc.p_cover_id
                  FROM p_cover     pc
                      ,status_hist sh
                      ,as_asset    ass
                 WHERE 1 = 1
                   AND pc.status_hist_id = sh.status_hist_id
                   AND pc.as_asset_id = ass.as_asset_id
                   AND sh.brief != 'DELETED'
                   AND ass.p_policy_id = par_policy_id)
    LOOP
      pkg_agregation.check_agregation(cur.p_cover_id);
    END LOOP;
  END check_agregation;

  /*
    ��������� �.
    372229 ����������� ���� ��������� ��������
  */

  FUNCTION get_policy_end_date(par_p_pol_header NUMBER) RETURN DATE IS
    RESULT ins.p_policy.end_date%TYPE;
  BEGIN
    BEGIN
      SELECT p.end_date
        INTO RESULT
        FROM p_pol_header h
            ,p_policy     p
       WHERE p.policy_id = h.policy_id
         AND h.policy_header_id = par_p_pol_header;
    EXCEPTION
      WHEN no_data_found THEN
        NULL;
    END;
  
    RETURN RESULT;
  
  END get_policy_end_date;

  /*
    ��������� �.
    372229 ���������� ���� ��������� ������ �� ��������
  */

  PROCEDURE update_agent_date_end(par_policy_id NUMBER) IS
    v_p_policy_agent_doc_id ins.p_policy_agent_doc.p_policy_agent_doc_id%TYPE;
  BEGIN
  
    SELECT ppad.p_policy_agent_doc_id
      INTO v_p_policy_agent_doc_id
      FROM ins.p_policy           pp
          ,ins.p_policy_agent_doc ppad
          ,ins.document           d
          ,ins.doc_status_ref     dsr
     WHERE ppad.policy_header_id = pp.pol_header_id
       AND d.document_id = ppad.p_policy_agent_doc_id
       AND dsr.doc_status_ref_id = d.doc_status_ref_id
       AND dsr.brief = 'CURRENT'
       AND pp.policy_id = par_policy_id;
  
  EXCEPTION
    WHEN no_data_found THEN
      RETURN;
    
      ins.pkg_agn_control.refresh_pol_agent_end_date(v_p_policy_agent_doc_id);
    
  END update_agent_date_end;

  /**
   * ��������� �� ������������� �������� ����� ������
   * @author ������ �. 16.1.2015
   -- %param par_policy_header_id  �� ������������� ��������
  */
  FUNCTION get_redempt_sum_is_handchange(par_policy_header_id p_pol_header.policy_header_id%TYPE)
    RETURN t_policyform_product.is_handchange%TYPE IS
    v_is_handchange t_policyform_product.is_handchange%TYPE;
  BEGIN
    SELECT tpp.is_handchange
      INTO v_is_handchange
      FROM p_pol_header         pph
          ,p_policy             pp
          ,t_policyform_product tpp
     WHERE pph.policy_header_id = par_policy_header_id
       AND pph.policy_id = pp.policy_id
       AND pp.t_product_conds_id = tpp.t_policyform_product_id;
    RETURN v_is_handchange;
  EXCEPTION
    WHEN no_data_found
         OR too_many_rows THEN
      RETURN NULL;
  END get_redempt_sum_is_handchange;

  /**
   * ������������ ������� ���������� � ����������� �� ���� ������ �� (������������ � ����������� ���)
   * @author ������ �. 10.4.2015
   * @param par_header_start_date  ���� ������ ��������
  */
  FUNCTION define_cooling_period_length(par_header_start_date p_pol_header.start_date%TYPE)
    RETURN NUMBER IS
    v_cooling_period_length NUMBER;
    c_signal_date CONSTANT DATE := to_date('15.05.2015', 'dd.mm.rrrr'); --��������� ����
    c_long        CONSTANT NUMBER := 30; --30 ����
    c_short       CONSTANT NUMBER := 14; --14 ����
  BEGIN
    IF par_header_start_date < c_signal_date
    THEN
      v_cooling_period_length := c_long;
    ELSE
      v_cooling_period_length := c_short;
    END IF;
    RETURN v_cooling_period_length;
  END define_cooling_period_length;

  /**
   * ������� ���������, �������� �� ��� �������� ����� � ��
   * @author ����������� �. 21.05.2015
   * @param par_policy_id  �� ������ ��
   * @par_series_num ����� ����� ���
   * @return 0 - �� ��������, 1 - ��������
  */
  FUNCTION is_pol_bso_series
  (
    par_policy_id  p_policy.policy_id%TYPE
   ,par_series_num bso_series.series_num%TYPE
  ) RETURN NUMBER IS
    v_result NUMBER;
  BEGIN
    SELECT COUNT(*)
      INTO v_result
      FROM dual
     WHERE EXISTS (SELECT bs.*
              FROM bso        b
                  ,bso_series bs
             WHERE b.policy_id = par_policy_id
               AND bs.bso_series_id = b.bso_series_id
               AND bs.series_num = par_series_num);
    RETURN v_result;
  END is_pol_bso_series;

END pkg_policy;
/

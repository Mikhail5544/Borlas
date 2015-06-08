CREATE OR REPLACE PACKAGE pkg_contract_lpu IS

  /**
  * �������� �������� � ���
  * @author Ilyushkin S.
  * @param p_version_id �� ������ ��������
  * @param p_lpu_id �� ���
  * @param p_num ����� ��������
  * @param p_num_ext ������� ����� ��������
  * @param p_sign_date ���� ���������� ��������
  * @param p_start_date ���� ������ ��������
  * @param p_end_date ���� ��������� ��������
  * @param p_parent_id �� ��������, �� ������� ��������� �������
  * @param p_dms_lpu_acc_type_id �� ������ �������� (����/������������)
  * @param p_dms_adv_type_id �� ���� ������
  * @param p_t_payment_terms_id �� ���� ��������� � ������ ������ (���/������)
  * @param p_fact_fund_id �� ������ �� �����
  * @param p_adv_fund_id �� ������ ������
  * @param p_acc_amount ����� ������
  * @param p_add_amount �������������� ����� ��� ����������� ������
  * @param p_is_need_acc ������� ������������� ��������� ����� �� ��� �� �����
  * @param p_dms_inv_pay_ord_id �� ������� ������ ������
  * @param p_dms_price_fund_id �� ������ ������������
  * @param p_pay_ord_days ���-�� ���� �������������� �����
  * @param p_fine_percent ������� ���� �� ���� ���������
  * @param p_rate_type_id �� ���� ����� �������
  * @param p_is_insured_list ������� "������������� ������ ��������������"
  * @param p_is_pass_required ������� "��������� �������"
  * @param p_note ����������
  * @param p_dms_calc_adv_sum_id �� ������ ������� ����� ������ �� ������� ������
  * @param p_dms_calc_adv_sum_val ��������� �������� ��� ����������� ����� ������
  * @return �� �������� � ���
  */
  FUNCTION contract_insert
  (
    p_version_id           IN NUMBER
   ,p_lpu_id               IN NUMBER
   ,p_num                  IN VARCHAR2
   ,p_num_ext              IN VARCHAR2
   ,p_num_ver              IN VARCHAR2
   ,p_sign_date            IN DATE
   ,p_start_date           IN DATE
   ,p_end_date             IN DATE
   ,p_parent_id            IN NUMBER
   ,p_dms_lpu_acc_type_id  IN NUMBER
   ,p_dms_adv_type_id      IN NUMBER
   ,p_t_payment_terms_id   IN NUMBER
   ,p_fact_fund_id         IN NUMBER
   ,p_adv_fund_id          IN NUMBER
   ,p_acc_amount           IN NUMBER
   ,p_add_amount           IN NUMBER
   ,p_is_need_acc          IN NUMBER
   ,p_dms_inv_pay_ord_id   IN NUMBER
   ,p_dms_price_fund_id    IN NUMBER
   ,p_pay_ord_days         IN VARCHAR2
   ,p_fine_percent         IN NUMBER
   ,p_rate_type_id         IN NUMBER
   ,p_is_insured_list      IN NUMBER
   ,p_is_pass_required     IN NUMBER
   ,p_note                 IN VARCHAR2
   ,p_dms_calc_adv_sum_id  IN NUMBER
   ,p_dms_calc_adv_sum_val IN NUMBER
   ,p_is_need_prolong      IN NUMBER
   ,p_addendum_type_id     IN NUMBER DEFAULT NULL
   ,p_is_prolong_auto      IN NUMBER DEFAULT 0
   ,p_rate                 NUMBER DEFAULT NULL
  ) RETURN NUMBER;

  /**
  * �������������� �������� � ���
  * @author Ilyushkin S.
  * @param p_version_id �� ������ ��������
  * @param p_lpu_id �� ���
  * @param p_num ����� ��������
  * @param p_num_ext ������� ����� ��������
  * @param p_sign_date ���� ���������� ��������
  * @param p_start_date ���� ������ ��������
  * @param p_end_date ���� ��������� ��������
  * @param p_parent_id �� ��������, �� ������� ��������� �������
  * @param p_dms_lpu_acc_type_id �� ������ �������� (����/������������)
  * @param p_dms_adv_type_id �� ���� ������
  * @param p_t_payment_terms_id �� ���� ��������� � ������ ������ (���/������)
  * @param p_fact_fund_id �� ������ �� �����
  * @param p_adv_fund_id �� ������ ������
  * @param p_acc_amount ����� ������
  * @param p_add_amount �������������� ����� ��� ����������� ������
  * @param p_is_need_acc ������� ������������� ��������� ����� �� ��� �� �����
  * @param p_dms_inv_pay_ord_id �� ������� ������ ������
  * @param p_dms_price_fund_id �� ������ ������������
  * @param p_pay_ord_days ���-�� ���� �������������� �����
  * @param p_fine_percent ������� ���� �� ���� ���������
  * @param p_rate_type_id �� ���� ����� �������
  * @param p_is_insured_list ������� "������������� ������ ��������������"
  * @param p_is_pass_required ������� "��������� �������"
  * @param p_note ����������
  * @param p_dms_calc_adv_sum_id �� ������ ������� ����� ������ �� ������� ������
  * @param p_dms_calc_adv_sum_val ��������� �������� ��� ����������� ����� ������
  */
  PROCEDURE contract_update
  (
    p_version_id           IN NUMBER
   ,p_lpu_id               IN NUMBER
   ,p_num                  IN VARCHAR2
   ,p_num_ext              IN VARCHAR2
   ,p_num_ver              IN VARCHAR2
   ,p_sign_date            IN DATE
   ,p_start_date           IN DATE
   ,p_end_date             IN DATE
   ,p_parent_id            IN NUMBER
   ,p_dms_lpu_acc_type_id  IN NUMBER
   ,p_dms_adv_type_id      IN NUMBER
   ,p_t_payment_terms_id   IN NUMBER
   ,p_fact_fund_id         IN NUMBER
   ,p_adv_fund_id          IN NUMBER
   ,p_acc_amount           IN NUMBER
   ,p_add_amount           IN NUMBER
   ,p_is_need_acc          IN NUMBER
   ,p_dms_inv_pay_ord_id   IN NUMBER
   ,p_dms_price_fund_id    IN NUMBER
   ,p_pay_ord_days         IN VARCHAR2
   ,p_fine_percent         IN NUMBER
   ,p_rate_type_id         IN NUMBER
   ,p_is_insured_list      IN NUMBER
   ,p_is_pass_required     IN NUMBER
   ,p_note                 IN VARCHAR2
   ,p_dms_calc_adv_sum_id  IN NUMBER
   ,p_dms_calc_adv_sum_val IN NUMBER
   ,p_is_need_prolong      IN NUMBER
   ,p_addendum_type_id     IN NUMBER DEFAULT NULL
   ,p_is_prolong_auto      IN NUMBER DEFAULT 0
   ,p_rate                 NUMBER DEFAULT NULL
  );

  /**
  * �������� ��������� ������ �� ��������� ���� �� ��������
  * @author Ilyushkin S.
  * @param p_contract_lpu_ver_id �� ������ ��������
  * @param p_adv_date ���� ��������� ������
  * @return ��������� ������ �� ����
  */
  FUNCTION get_current_adv
  (
    p_contract_lpu_ver_id IN NUMBER
   ,p_adv_date            IN DATE DEFAULT TRUNC(SYSDATE, 'DD')
  ) RETURN NUMBER;

  /**
  * �������� �������� ����� ���������� ������ �� ��������� ���� �� ��������
  * @author Ilyushkin S.
  * @param p_contract_lpu_ver_id �� ������ ��������
  * @param p_plan_date ���� �������
  * @return �������� ����� ���������� ������
  */
  FUNCTION get_plan_adv
  (
    p_contract_lpu_ver_id IN NUMBER
   ,p_plan_date           IN DATE DEFAULT TRUNC(SYSDATE, 'DD')
  ) RETURN NUMBER;

  /**
  * �������� ��������� ���� ������ ����� �� ��������
  * @author Ilyushkin S.
  * @param p_contract_lpu_ver_id �� ������ ��������
  * @param p_plan_date ���� �������
  * @return ��������� ���� ������ ����� �� ��������
  */
  FUNCTION get_max_pay_date
  (
    p_contract_lpu_ver_id IN NUMBER
   ,p_plan_date           IN DATE
  ) RETURN DATE;

  /**
  * �������� ��������� ������ ��� ��������� ������ �����
  * @author Ilyushkin S.
  * @param p_contract_lpu_ver_id �� ������ ��������
  * @param p_acc_amount ����� �����
  * @return ��������� ������ ��� ��������� ������ �����
  */
  FUNCTION get_fine_cost
  (
    p_contract_lpu_ver_id IN NUMBER
   ,p_acc_amount          IN NUMBER
  ) RETURN NUMBER;

  /**
  * ���������� ������ ������ ������������ "�����������"
  * @author Ilyushkin S.
  * @param p_dms_price_id �� ������
  */
  PROCEDURE set_price_cur
  (
    p_dms_price_id IN NUMBER
   ,p_start_date   IN DATE
  );

  /**
  * ���������� ������ "�����������" ��� ���� "�����" ����� ������������
  * @author Ilyushkin S.
  * @param p_contract_lpu_ver_id �� ������ ��������
  */
  PROCEDURE set_price_cur_all(p_contract_lpu_ver_id IN NUMBER);

  /**
  * -- ��������� ��� ��������� ����� ��������
  * @author Sergeev D.
  * @param p_contract_lpu_ver_id �� �������� � ���
  */
  PROCEDURE set_contract_status(p_contract_lpu_ver_id IN NUMBER);

  /**
  * �������� ����� ������ �������� � ��� �� ����������
  * @author Sergeev D.
  * @param p_version_id �� ������ �������� � ���
  * @param p_start_date ���� ������ ������ (�������������� ��������)
  * @param p_end_date ���� ��������� ������ (�������������� ��������)
  */
  FUNCTION new_version
  (
    p_version_id IN NUMBER
   ,p_start_date IN DATE DEFAULT NULL
   ,p_end_date   IN DATE DEFAULT NULL
  ) RETURN NUMBER;

  /**
  * ���������� ����������� �������� ����� ������ �������� � ��� �� ��������
  * @author Sergeev D.
  * @param p_version_id �� ������ �������� � ���
  * @return 1-��, 0-���
  */
  FUNCTION can_be_copied(p_version_id IN NUMBER) RETURN NUMBER;

  PROCEDURE set_payadvlpu_status(p_payment_id IN NUMBER);
  PROCEDURE cancel_payment(p_ac_payment_id IN NUMBER);
  FUNCTION get_parent_doc(p_child_id IN NUMBER) RETURN NUMBER;

  /**
  * �������� ����������� ������ �� ��������
  * @author Sergeev D.
  * @param
  */
  -- function get_active_version(p_contract_lpu_ver_id number) return number;

  /**
  * ���������� ����������� �������� ������ �������� � ��� � ������ "�����������"
  * @author Sergeev D.
  * @param p_contract_lpu_ver_id �� ������ �������� � ���
  * @is_full ������� ������������� ������ �������� ��� ����������� �� �������� �������� �������
  * @return null-��, not null-��� (��������� �� ������)
  */
  FUNCTION can_be_current
  (
    p_contract_lpu_ver_id IN NUMBER
   ,is_full               BOOLEAN DEFAULT FALSE
  ) RETURN VARCHAR2;

  /**
  * ���������� ����������� ������ (��������) ������ �������� � ���
  * @author Sergeev D.
  * @param p_version_id �� ������ �������� � ���
  * @return 1-��, 0-���
  */
  FUNCTION can_be_canceled(p_version_id IN NUMBER) RETURN NUMBER;

  /**
  * ���������� ����������� �������� ������ �������� � ��� � ������ "����������"
  * @author Sergeev D.
  * @param p_version_id �� ������ �������� � ���
  * @return 1-������� ��������, 0-������� ����������
  */
  -- function can_be_declined(p_version_id in number) return number;

  /**
  * ��������� ������� "�����������" �� ������ �������� � ���
  * @author Sergeev D.
  * @param p_version_id �� ������ �������� � ���
  */
  --  function set_current_status(p_contract_lpu_ver_id in number) return varchar2;

  /**
  * ���������� ������ ������� ��� ������
  * @author Sergeev D.
  * @param p_version_id �� ������ �������� � ���
  */
  PROCEDURE set_cancel_status(p_version_id NUMBER);

  /**
  * �������� ����� ������ �������� � ��� �� �����������.
  * ������� ����� ������ � ������������ ��������� �����������
  * @author Sergeev D.
  * @param p_version_id �� ������ �������� � ���
  */
  -- function new_version_decline(p_version_id in number) return number;

  /**
  * �������� ���������� ������� ������� ������������
  * @author Sergeev D.
  * @param p_version_id �� ������ �������� � ���
  * @param p_price_id �� ������� ������������
  */
  --function get_price_status_brief(p_version_id in number, p_dms_price_id in number) return varchar2;

  /**
  * ����������� �������
  * @author Sergeev D.
  * @param p_version_id �� ������ �������� � ���
  */
  --procedure set_decline_status(p_version_id number);

  /**
  * �������� �� ������������� �������� � ��������� ��� ������ ���������� �������
  * �� ���������� ������ �������
  * @author Ilyushkin S.
  * @param p_contract_lpu_id �� ������ �������� � ���
  * @param p_lpu_id �� ���
  * @param p_start_date ���� ������ �������� �������� (������)
  * @param p_end_date ���� ��������� �������� �������� (������)
  * @param dms_lpu_acc_type_id �� ������ ������� ������
  * @return ���� ������� ������, �� ������ ���� �<����� ��������> �� <���� ����������>, ���� ��� - null
  */
  FUNCTION check_contract
  (
    p_contract_lpu_id     IN NUMBER
   ,p_lpu_id              IN NUMBER
   ,p_start_date          IN DATE
   ,p_end_date            IN DATE
   ,p_dms_lpu_acc_type_id IN NUMBER
  ) RETURN VARCHAR2;

  /**
  * ����� ������� �����������(!) ������ ��������
  * @author Ilyushkin S.
  * @param p_contract_lpu_ver_id �� ����� ������ ��������
  * @return �� ������� ������ ��������, null ���� � �������� ��� ����������� ������
  */
  FUNCTION get_current_version(p_contract_lpu_ver_id IN NUMBER) RETURN NUMBER;

  /**
  * ���������� ������ ���. ����������
  * @author Ilyushkin S.
  * @param p_contract_lpu_ver_id �� ����� ������ ��������
  * @return ������ ��: ���������, ��� �� ���������, ��� �� ���������
  */
  FUNCTION get_ver_status(p_contract_lpu_ver_id IN NUMBER) RETURN VARCHAR2;

  /**
  * ���������� ����� � ���� ��������� ��������
  * @author Ilyushkin S.
  * @param p_contract_lpu_ver_id �� ��������������� ��������
  * @return ����� ��������� ��������
  */
  FUNCTION get_contract_full_name(p_contract_lpu_id IN NUMBER) RETURN VARCHAR2;

  /**
  * �� �� ������ �������� � ��� ���������� ������ ����:
  * � <����� ��������> �� <���� ����������>, ����������� � <���� ������>
  * �� <���� ���������>
  * @author Ilyushkin S.
  * @param p_contract_lpu_ver_id �� ������ ��������
  * @return ������ ����� ������
  */
  FUNCTION get_contract_lpu_ver_full_num(p_contract_lpu_ver_id IN NUMBER) RETURN VARCHAR2;

  FUNCTION is_set_off
  (
    p_document_id     IN NUMBER
   ,p_doc_templ_brief VARCHAR2
  ) RETURN NUMBER;

  FUNCTION can_be_deleted(p_contract_lpu_id IN NUMBER) RETURN BOOLEAN;

  -- ��������� ����� ������� ������ �������� � ������ ��������
  FUNCTION set_contract_lpu_ver_status
  (
    p_contract_lpu_ver_id IN NUMBER
   ,p_status              IN VARCHAR2
   ,p_status_date         IN DATE DEFAULT SYSDATE
  ) RETURN VARCHAR2;

  FUNCTION GET_ACC_TYPE
  (
    p_contract_lpu_ver_id IN NUMBER
   ,p_str_type            IN VARCHAR2 DEFAULT 'L'
  ) RETURN VARCHAR2;

  -- �������� ���� �� �������������� �������� ���
  FUNCTION can_edit_prog_lpu RETURN BOOLEAN;

END Pkg_Contract_Lpu;
/
CREATE OR REPLACE PACKAGE BODY pkg_contract_lpu IS

  -- ���������� ������ �������� � ���
  FUNCTION contract_insert
  (
    p_version_id           IN NUMBER
   ,p_lpu_id               IN NUMBER
   ,p_num                  IN VARCHAR2
   ,p_num_ext              IN VARCHAR2
   ,p_num_ver              IN VARCHAR2
   ,p_sign_date            IN DATE
   ,p_start_date           IN DATE
   ,p_end_date             IN DATE
   ,p_parent_id            IN NUMBER
   ,p_dms_lpu_acc_type_id  IN NUMBER
   ,p_dms_adv_type_id      IN NUMBER
   ,p_t_payment_terms_id   IN NUMBER
   ,p_fact_fund_id         IN NUMBER
   ,p_adv_fund_id          IN NUMBER
   ,p_acc_amount           IN NUMBER
   ,p_add_amount           IN NUMBER
   ,p_is_need_acc          IN NUMBER
   ,p_dms_inv_pay_ord_id   IN NUMBER
   ,p_dms_price_fund_id    IN NUMBER
   ,p_pay_ord_days         IN VARCHAR2
   ,p_fine_percent         IN NUMBER
   ,p_rate_type_id         IN NUMBER
   ,p_is_insured_list      IN NUMBER
   ,p_is_pass_required     IN NUMBER
   ,p_note                 IN VARCHAR2
   ,p_dms_calc_adv_sum_id  IN NUMBER
   ,p_dms_calc_adv_sum_val IN NUMBER
   ,p_is_need_prolong      IN NUMBER
   ,p_addendum_type_id     IN NUMBER DEFAULT NULL
   ,p_is_prolong_auto      IN NUMBER DEFAULT 0
   ,p_rate                 NUMBER DEFAULT NULL
  ) RETURN NUMBER IS
    v_contract_id NUMBER;
    v_ret_val     VARCHAR2(1000);
  BEGIN
    SELECT sq_contract_lpu.NEXTVAL INTO v_contract_id FROM dual;
    INSERT INTO ven_contract_lpu
      (contract_lpu_id, num, doc_templ_id, reg_date, lpu_id, num_ext, curr_version_id, note)
      SELECT v_contract_id
            ,p_num
            ,dt.doc_templ_id
            ,SYSDATE
            ,p_lpu_id
            ,p_num_ext
            ,p_version_id
            ,p_note
        FROM ven_doc_templ dt
       WHERE dt.brief = 'CONTRACT_LPU';
  
    INSERT INTO ven_contract_lpu_ver vclv
      (vclv.contract_lpu_ver_id
      ,vclv.num
      ,vclv.doc_templ_id
      ,vclv.reg_date
      ,vclv.note
      ,vclv.contract_lpu_id
      ,vclv.version_ord_number
      ,vclv.sign_date
      ,vclv.start_date
      ,vclv.end_date
      ,vclv.dms_lpu_acc_type_id
      ,vclv.dms_adv_type_id
      ,vclv.t_payment_terms_id
      ,vclv.fact_fund_id
      ,vclv.adv_fund_id
      ,vclv.acc_amount
      ,vclv.add_amount
      ,vclv.is_need_acc
      ,vclv.dms_inv_pay_ord_id
      ,vclv.dms_price_fund_id
      ,vclv.pay_ord_days
      ,vclv.fine_percent
      ,vclv.rate_type_id
      ,vclv.is_insured_list
      ,vclv.is_pass_required
      ,vclv.dms_calc_adv_sum_id
      ,vclv.dms_calc_adv_sum_val
      ,vclv.is_need_prolong
      ,vclv.t_addendum_type_id
      ,vclv.is_prolong_auto
      ,vclv.rate_val)
      SELECT p_version_id
            ,p_num_ver
            ,dt.doc_templ_id
            ,SYSDATE
            ,p_note
            ,v_contract_id
            ,0
            ,p_sign_date
            ,p_start_date
            ,p_end_date
            ,p_dms_lpu_acc_type_id
            ,p_dms_adv_type_id
            ,p_t_payment_terms_id
            ,p_fact_fund_id
            ,p_adv_fund_id
            ,p_acc_amount
            ,p_add_amount
            ,p_is_need_acc
            ,p_dms_inv_pay_ord_id
            ,p_dms_price_fund_id
            ,p_pay_ord_days
            ,p_fine_percent
            ,p_rate_type_id
            ,p_is_insured_list
            ,p_is_pass_required
            ,p_dms_calc_adv_sum_id
            ,p_dms_calc_adv_sum_val
            ,p_is_need_prolong
            ,p_addendum_type_id
            ,p_is_prolong_auto
            ,p_rate
        FROM ven_doc_templ dt
       WHERE dt.brief = 'CONTRACT_LPU_VER';
  
    Doc.set_doc_status(p_version_id, 'NEW', SYSDATE, 'AUTO', '�������� ���������');
    Doc.set_doc_status(v_contract_id, 'NEW', SYSDATE, 'AUTO', '�������� ���������');
  
    IF p_parent_id IS NOT NULL
    THEN
      INSERT INTO doc_doc
        (doc_doc_id, parent_id, child_id)
      VALUES
        (sq_doc_doc.NEXTVAL, p_parent_id, v_contract_id);
    END IF;
  
    RETURN v_contract_id;
  END contract_insert;

  -- ����������� �������� �������� � ���
  PROCEDURE contract_update
  (
    p_version_id           IN NUMBER
   ,p_lpu_id               IN NUMBER
   ,p_num                  IN VARCHAR2
   ,p_num_ext              IN VARCHAR2
   ,p_num_ver              IN VARCHAR2
   ,p_sign_date            IN DATE
   ,p_start_date           IN DATE
   ,p_end_date             IN DATE
   ,p_parent_id            IN NUMBER
   ,p_dms_lpu_acc_type_id  IN NUMBER
   ,p_dms_adv_type_id      IN NUMBER
   ,p_t_payment_terms_id   IN NUMBER
   ,p_fact_fund_id         IN NUMBER
   ,p_adv_fund_id          IN NUMBER
   ,p_acc_amount           IN NUMBER
   ,p_add_amount           IN NUMBER
   ,p_is_need_acc          IN NUMBER
   ,p_dms_inv_pay_ord_id   IN NUMBER
   ,p_dms_price_fund_id    IN NUMBER
   ,p_pay_ord_days         IN VARCHAR2
   ,p_fine_percent         IN NUMBER
   ,p_rate_type_id         IN NUMBER
   ,p_is_insured_list      IN NUMBER
   ,p_is_pass_required     IN NUMBER
   ,p_note                 IN VARCHAR2
   ,p_dms_calc_adv_sum_id  IN NUMBER
   ,p_dms_calc_adv_sum_val IN NUMBER
   ,p_is_need_prolong      IN NUMBER
   ,p_addendum_type_id     IN NUMBER DEFAULT NULL
   ,p_is_prolong_auto      IN NUMBER DEFAULT 0
   ,p_rate                 NUMBER DEFAULT NULL
  ) IS
  
    v_Contract_ID NUMBER;
    v_doc_doc     NUMBER;
  
    CURSOR cur_par IS
      SELECT ven_doc_doc.doc_doc_id doc_doc_id
        FROM ven_doc_doc
       WHERE ven_doc_doc.child_id = p_version_id;
  BEGIN
    --raise_application_error(-20000-nvl(p_rate,2), 'rate='||p_rate);
  
    SELECT clv.contract_lpu_id
      INTO v_Contract_ID
      FROM contract_lpu_ver clv
     WHERE clv.contract_lpu_ver_id = p_version_id;
  
    UPDATE document d
       SET d.num  = p_num
          ,d.note = p_note
     WHERE d.document_id = v_Contract_ID;
  
    UPDATE contract_lpu cl
       SET (lpu_id, num_ext) =
           (SELECT p_lpu_id
                  ,p_num_ext
              FROM dual)
     WHERE cl.contract_lpu_id = v_Contract_ID;
  
    UPDATE document d
       SET d.num  = p_num_ver
          ,d.note = p_note
     WHERE d.document_id = p_version_id;
  
    UPDATE contract_lpu_ver clv
       SET (sign_date
          ,start_date
          ,end_date
          ,dms_lpu_acc_type_id
          ,dms_adv_type_id
          ,t_payment_terms_id
          ,fact_fund_id
          ,adv_fund_id
          ,acc_amount
          ,add_amount
          ,is_need_acc
          ,dms_inv_pay_ord_id
          ,dms_price_fund_id
          ,pay_ord_days
          ,fine_percent
          ,rate_type_id
          ,is_insured_list
          ,is_pass_required
          ,dms_calc_adv_sum_id
          ,dms_calc_adv_sum_val
          ,is_need_prolong
          ,t_addendum_type_id
          ,is_prolong_auto
          ,rate_val) =
           (SELECT p_sign_date
                  ,p_start_date
                  ,p_end_date
                  ,p_dms_lpu_acc_type_id
                  ,p_dms_adv_type_id
                  ,p_t_payment_terms_id
                  ,p_fact_fund_id
                  ,p_adv_fund_id
                  ,p_acc_amount
                  ,p_add_amount
                  ,p_is_need_acc
                  ,p_dms_inv_pay_ord_id
                  ,p_dms_price_fund_id
                  ,p_pay_ord_days
                  ,p_fine_percent
                  ,p_rate_type_id
                  ,p_is_insured_list
                  ,p_is_pass_required
                  ,p_dms_calc_adv_sum_id
                  ,p_dms_calc_adv_sum_val
                  ,p_is_need_prolong
                  ,p_addendum_type_id
                  ,p_is_prolong_auto
                  ,p_rate
              FROM dual)
     WHERE clv.contract_lpu_ver_id = p_version_id;
  
    IF p_parent_id IS NOT NULL
    THEN
      OPEN cur_par;
      FETCH cur_par
        INTO v_doc_doc;
      IF cur_par%FOUND
      THEN
        UPDATE doc_doc SET parent_id = p_parent_id WHERE doc_doc_id = v_doc_doc;
      ELSE
        INSERT INTO doc_doc
          (doc_doc_id, parent_id, child_id)
        VALUES
          (sq_doc_doc.NEXTVAL, p_parent_id, v_Contract_ID);
      END IF;
      CLOSE cur_par;
    ELSIF p_parent_id IS NULL
    THEN
      DELETE FROM doc_doc WHERE child_id = p_version_id;
    END IF;
  
    SELECT clv.contract_lpu_id
      INTO v_Contract_ID
      FROM contract_lpu_ver clv
     WHERE clv.contract_lpu_ver_id = p_version_id;
  END;

  FUNCTION get_current_adv
  (
    p_contract_lpu_ver_id IN NUMBER
   ,p_adv_date            IN DATE DEFAULT TRUNC(SYSDATE, 'DD')
  ) RETURN NUMBER IS
    v_ret_val   NUMBER;
    v_pay_adv   NUMBER;
    v_write_adv NUMBER;
  BEGIN
    SELECT NVL(SUM(Pkg_Contract_Lpu.is_set_off(ap.payment_id, 'DMS_INV_LPU')), 0)
      INTO v_pay_adv
      FROM ven_ac_payment ap
          ,ven_doc_templ  dt
          ,ven_doc_doc    dd
     WHERE dt.brief = 'DMS_INV_LPU_ADV'
       AND dt.doc_templ_id = ap.doc_templ_id
       AND ap.due_date <= p_adv_date
       AND ap.payment_id = dd.child_id
       AND dd.parent_id = p_contract_lpu_ver_id;
  
    SELECT NVL(SUM(ap.rev_amount), 0)
      INTO v_write_adv
      FROM ven_ac_payment ap
          ,ven_doc_templ  dt
          ,ven_doc_doc    dd
     WHERE dt.brief = 'WRITEOFFSERV'
       AND dt.doc_templ_id = ap.doc_templ_id
       AND ap.due_date <= p_adv_date
       AND ap.payment_id = dd.child_id
       AND dd.parent_id = p_contract_lpu_ver_id;
  
    v_ret_val := v_pay_adv - v_write_adv;
    RETURN(v_ret_val);
  END get_current_adv;

  -- �������� ����������� ����� ������ ��� ���������� �������
  FUNCTION get_plan_adv
  (
    p_contract_lpu_ver_id IN NUMBER
   ,p_plan_date           IN DATE DEFAULT TRUNC(SYSDATE, 'DD')
  ) RETURN NUMBER IS
    v_ret_val      NUMBER;
    v_adv          NUMBER;
    v_add_adv      NUMBER;
    v_meth         VARCHAR2(50);
    v_meth_val     NUMBER;
    v_max_date     DATE;
    v_min_date     DATE;
    v_adv_plan     NUMBER;
    v_adv_cur      NUMBER;
    v_serv         NUMBER;
    v_dms_adv_type VARCHAR2(50);
  
    CURSOR cur_con IS
      SELECT clv.acc_amount
            ,clv.add_amount
            ,dcas.brief
            ,clv.dms_calc_adv_sum_val
            ,dat.brief
        FROM ven_contract_lpu_ver clv
            ,ven_dms_calc_adv_sum dcas
            ,ven_dms_adv_type     dat
       WHERE dat.dms_adv_type_id = clv.dms_adv_type_id
         AND dcas.dms_calc_adv_sum_id = clv.dms_calc_adv_sum_id
         AND clv.contract_lpu_ver_id = p_contract_lpu_ver_id;
  
    CURSOR cur_serv IS
      SELECT NVL(SUM(Pkg_Dms_Expert.get_fact_amount(csm.c_service_med_id)), 0)
        FROM ven_c_service_med csm
            ,ven_doc_doc       dd
            ,ven_dms_serv_act  dsa
            ,ven_doc_doc       dd1
            ,ven_ac_payment    ap
            ,ven_doc_templ     dt
            ,ven_doc_doc       dd2
       WHERE csm.service_date BETWEEN v_min_date AND v_max_date
         AND dd.child_id = csm.dms_serv_reg_id
         AND dsa.dms_serv_act_id = dd.parent_id
         AND dd1.child_id = dsa.dms_serv_act_id
         AND ap.payment_id = dd1.parent_id
         AND ap.doc_templ_id = dt.doc_templ_id
         AND dt.brief = 'DMS_INV_LPU_SERV'
         AND ap.payment_id = dd2.child_id
         AND dd2.parent_id = p_contract_lpu_ver_id;
  BEGIN
    OPEN cur_con;
    FETCH cur_con
      INTO v_adv
          ,v_add_adv
          ,v_meth
          ,v_meth_val
          ,v_dms_adv_type;
    IF cur_con%NOTFOUND
    THEN
      v_ret_val := NULL;
      CLOSE cur_con;
      RETURN(v_ret_val);
    END IF;
    CLOSE cur_con;
  
    v_max_date := p_plan_date;
    IF v_meth = 'PER3MON'
    THEN
      v_min_date := ADD_MONTHS(p_plan_date, -3);
    ELSIF v_meth = 'PER6MON'
    THEN
      v_min_date := ADD_MONTHS(p_plan_date, -6);
    ELSIF v_meth = 'PER12MON'
    THEN
      v_min_date := ADD_MONTHS(p_plan_date, -12);
    END IF;
  
    IF v_meth = 'FIXED'
    THEN
      v_adv_plan := v_adv;
    ELSE
      OPEN cur_serv;
      FETCH cur_serv
        INTO v_serv;
      CLOSE cur_serv;
      v_adv_plan := ROUND(v_serv * v_meth_val / 100, 2);
      IF v_adv_plan = 0
      THEN
        v_adv_plan := v_adv;
      END IF;
    END IF;
  
    v_adv_cur := ROUND(get_current_adv(p_contract_lpu_ver_id, p_plan_date), 2);
    v_ret_val := v_adv_plan - v_adv_cur;
    RETURN(v_ret_val);
  END get_plan_adv;

  -- �������� ������� ���� ������ �����
  FUNCTION get_max_pay_date
  (
    p_contract_lpu_ver_id IN NUMBER
   ,p_plan_date           IN DATE
  ) RETURN DATE IS
    v_pay_ord_id   NUMBER;
    v_pay_ord_days VARCHAR2(50);
    v_ret_val      DATE;
  
    CURSOR cur_con IS
      SELECT clv.dms_inv_pay_ord_id
            ,RTRIM(LTRIM(clv.pay_ord_days))
        FROM ven_contract_lpu_ver clv
       WHERE clv.contract_lpu_ver_id = p_contract_lpu_ver_id;
  BEGIN
    OPEN cur_con;
    FETCH cur_con
      INTO v_pay_ord_id
          ,v_pay_ord_days;
    IF cur_con%NOTFOUND
    THEN
      v_ret_val := NULL;
      CLOSE cur_con;
      RETURN(v_ret_val);
    END IF;
    CLOSE cur_con;
  
    IF v_pay_ord_id = 0
    THEN
      IF TO_NUMBER(TO_CHAR(p_plan_date, 'DD')) <= TO_NUMBER(v_pay_ord_days)
      THEN
        v_ret_val := TO_DATE(v_pay_ord_days || TO_CHAR(p_plan_date, 'MM\YYYY'), 'DD\MM\YYYY');
      ELSE
        v_ret_val := TO_DATE(v_pay_ord_days || TO_CHAR(ADD_MONTHS(p_plan_date, 1), 'MM\YYYY')
                            ,'DD\MM\YYYY');
      END IF;
    ELSIF v_pay_ord_id = 1
    THEN
      v_ret_val := p_plan_date + TO_NUMBER(v_pay_ord_days);
    ELSE
      v_ret_val := NULL;
    END IF;
    RETURN(v_ret_val);
  END get_max_pay_date;

  -- �������� �������� ���� �� ���� ���� ��������� �����
  FUNCTION get_fine_cost
  (
    p_contract_lpu_ver_id IN NUMBER
   ,p_acc_amount          IN NUMBER
  ) RETURN NUMBER IS
    v_ret_val      NUMBER;
    v_fine_percent NUMBER;
  
    CURSOR cur_con IS
      SELECT clv.fine_percent
        FROM ven_contract_lpu_ver clv
       WHERE clv.contract_lpu_ver_id = p_contract_lpu_ver_id;
  BEGIN
    OPEN cur_con;
    FETCH cur_con
      INTO v_fine_percent;
    IF cur_con%NOTFOUND
    THEN
      v_ret_val := NULL;
      CLOSE cur_con;
      RETURN(v_ret_val);
    END IF;
    CLOSE cur_con;
  
    v_ret_val := ROUND(p_acc_amount * v_fine_percent / 100, 2);
    RETURN(v_ret_val);
  END get_fine_cost;

  -- ���������� ������ ������ ������������ � "�����������"
  PROCEDURE set_price_cur
  (
    p_dms_price_id IN NUMBER
   ,p_start_date   IN DATE
  ) IS
    v_old_dms_price_id NUMBER;
    v_old_start_date   DATE;
    v_ret_val          NUMBER := NULL;
    CURSOR cur_find IS
      SELECT dp.dms_price_id
            ,dp.start_date
        FROM ven_dms_price dp
            ,ven_dms_price dp1
       WHERE dp.status_hist_id IN (2, 3)
         AND (dp.dms_aid_type_id = dp1.dms_aid_type_id OR
             (dp.dms_aid_type_id IS NULL AND dp1.dms_aid_type_id IS NULL))
         AND UPPER(dp.NAME) = UPPER(dp1.NAME)
         AND UPPER(dp.code) = UPPER(dp1.code)
         AND dp1.dms_price_id = p_dms_price_id;
  BEGIN
    OPEN cur_find;
    FETCH cur_find
      INTO v_old_dms_price_id
          ,v_old_start_date;
    IF cur_find%NOTFOUND
    THEN
      v_old_dms_price_id := NULL;
      v_old_start_date   := NULL;
    END IF;
    CLOSE cur_find;
  
    IF v_old_dms_price_id IS NOT NULL
    THEN
      IF TRUNC(p_start_date) > TRUNC(v_old_start_date)
      THEN
        UPDATE ven_dms_price
           SET end_date       = TRUNC(p_start_date) - 1
              ,status_hist_id = 3
         WHERE dms_price_id = v_old_dms_price_id;
        UPDATE ven_dms_price SET status_hist_id = 2 WHERE dms_price_id = p_dms_price_id;
      END IF;
      v_ret_val := 2;
    ELSE
      UPDATE ven_dms_price SET status_hist_id = 2 WHERE dms_price_id = p_dms_price_id;
      v_ret_val := NULL;
    END IF;
    --  return(v_ret_val);
  END set_price_cur;

  -- ���������� ������ "�����������" ��� ���� "�����" ����� ������������
  PROCEDURE set_price_cur_all(p_contract_lpu_ver_id IN NUMBER) IS
    CURSOR cur_find IS
      SELECT dp.dms_price_id
            ,dp.start_date
        FROM ven_dms_price dp
       WHERE dp.status_hist_id = 1
         AND dp.contract_lpu_ver_id = p_contract_lpu_ver_id;
    v_ret_val NUMBER;
  BEGIN
    FOR cl IN cur_find
    LOOP
      set_price_cur(cl.dms_price_id, cl.start_date);
    END LOOP;
  END set_price_cur_all;

  -- ��������� ��� ��������� ����� ��������
  PROCEDURE set_contract_status(p_contract_lpu_ver_id IN NUMBER) IS
    v_ver_status_brief      VARCHAR2(50);
    v_old_cur_ver_id        NUMBER;
    v_contract_lpu_id       NUMBER;
    v_contract_status_brief VARCHAR2(50);
    CURSOR cur_current IS
      SELECT cl.curr_version_id
            ,cl.contract_lpu_id
        FROM ven_contract_lpu     cl
            ,ven_contract_lpu_ver clv
       WHERE cl.contract_lpu_id = clv.contract_lpu_id
         AND clv.contract_lpu_ver_id = p_contract_lpu_ver_id;
  BEGIN
    v_ver_status_brief := Doc.get_doc_status_brief(p_contract_lpu_ver_id);
    OPEN cur_current;
    FETCH cur_current
      INTO v_old_cur_ver_id
          ,v_contract_lpu_id;
    IF cur_current%NOTFOUND
    THEN
      v_old_cur_ver_id  := NULL;
      v_contract_lpu_id := NULL;
    END IF;
    CLOSE cur_current;
  
    IF (v_ver_status_brief = 'CURRENT')
       AND (v_old_cur_ver_id <> p_contract_lpu_ver_id)
    THEN
      UPDATE ven_contract_lpu
         SET curr_version_id = p_contract_lpu_ver_id
       WHERE contract_lpu_id = v_contract_lpu_id;
      Doc.set_doc_status(v_old_cur_ver_id, 'STOPED', SYSDATE, 'MANUAL', NULL);
    END IF;
  
    v_contract_status_brief := Doc.get_doc_status_brief(v_contract_lpu_id);
    IF v_contract_status_brief NOT IN ('NEW', 'NULL')
       AND v_ver_status_brief = 'NEW'
    THEN
      RETURN;
    END IF;
  
    IF (v_ver_status_brief <> 'CANCEL')
       AND (v_contract_status_brief <> v_ver_status_brief)
    THEN
      Doc.set_doc_status(v_contract_lpu_id, v_ver_status_brief, SYSDATE, 'MANUAL', NULL);
    END IF;
  
    IF v_ver_status_brief = 'CANCEL'
    THEN
      DELETE FROM ven_contract_lpu_ver WHERE contract_lpu_ver_id = p_contract_lpu_ver_id;
    END IF;
  END;

  FUNCTION new_version
  (
    p_version_id IN NUMBER
   ,p_start_date IN DATE DEFAULT NULL
   ,p_end_date   IN DATE DEFAULT NULL
  ) RETURN NUMBER IS
    v_lic_id           NUMBER;
    v_contract_lpu_ver ven_contract_lpu_ver%ROWTYPE;
    v_dms_lpu_license  dms_lpu_license%ROWTYPE;
  
    v_cur_end_date DATE;
    CURSOR c_l IS
      SELECT dll.*
        FROM dms_lpu_license dll
            ,status_hist     sh
       WHERE dll.status_hist_id = sh.status_hist_id
         AND sh.brief <> 'DELETED'
         AND dll.contract_lpu_ver_id = p_version_id;
  BEGIN
    -- ������
    SELECT clv.*
      INTO v_contract_lpu_ver
      FROM ven_contract_lpu_ver clv
     WHERE clv.contract_lpu_ver_id = p_version_id;
  
    v_contract_lpu_ver.num := '���';
    -- ����� �� ������
    SELECT sq_contract_lpu_ver.NEXTVAL INTO v_contract_lpu_ver.contract_lpu_ver_id FROM dual;
  
    -- ����� �/� ������
    SELECT MAX(clv.version_ord_number) + 1
      INTO v_contract_lpu_ver.version_ord_number
      FROM contract_lpu_ver clv
     WHERE clv.contract_lpu_id = v_contract_lpu_ver.contract_lpu_id
       AND Doc.get_doc_status_brief(clv.contract_lpu_ver_id) NOT IN ('CANCEL');
  
    -- ������� ����� ������
    v_contract_lpu_ver.start_date := TRUNC(SYSDATE, 'dd');
    IF p_start_date IS NOT NULL
    THEN
      v_contract_lpu_ver.start_date := p_start_date;
    END IF;
    IF p_end_date IS NOT NULL
    THEN
      v_contract_lpu_ver.end_date := p_end_date;
    END IF;
  
    INSERT INTO ven_contract_lpu_ver VALUES v_contract_lpu_ver;
  
    SELECT TRUNC(end_date)
      INTO v_cur_end_date
      FROM contract_lpu_ver
     WHERE contract_lpu_ver_id = p_version_id;
  
    -- �������� �����������
    INSERT INTO dms_price
      SELECT sq_dms_price.NEXTVAL
            ,dp.ent_id
            ,dp.filial_id
            ,v_contract_lpu_ver.contract_lpu_ver_id
            ,dp.code
            ,dp.NAME
            ,dp.fund_id
            ,dp.start_date
            ,
             --nvl(p_end_date,dp.end_date),
             DECODE(TRUNC(dp.end_date), v_cur_end_date, NVL(p_end_date, dp.end_date), dp.end_date)
            ,dp.T_DAMAGE_CODE_ID
            ,dp.t_measure_unit_id
            ,dp.amount
            ,dp.dms_lpu_depart_id
            ,dp.dms_aid_type_id
            ,(SELECT status_hist_id FROM ven_status_hist WHERE brief = 'CURRENT')
            ,NULL
            ,dp.executor_id
            ,0
            ,0
        FROM dms_price dp
       WHERE dp.contract_lpu_ver_id = get_current_version(p_version_id);
    Pkg_Contract_Lpu.set_price_cur_all(v_contract_lpu_ver.contract_lpu_ver_id);
    -- �������� ��������
    OPEN c_l;
    LOOP
      FETCH c_l
        INTO v_dms_lpu_license;
      EXIT WHEN c_l%NOTFOUND;
      SELECT sq_dms_lpu_license.NEXTVAL INTO v_lic_id FROM dual;
      INSERT INTO dms_lpu_license
        SELECT v_lic_id
              ,v_dms_lpu_license.ent_id
              ,v_dms_lpu_license.filial_id
              ,v_contract_lpu_ver.contract_lpu_ver_id
              ,v_dms_lpu_license.issue_date
              ,v_dms_lpu_license.start_date
              ,v_dms_lpu_license.end_date
              ,v_dms_lpu_license.num
              ,(SELECT status_hist_id FROM ven_status_hist WHERE brief = 'CURRENT')
              ,NULL
          FROM dual;
      INSERT INTO dms_lpu_license_serv
        SELECT Sq_Dms_Lpu_License_Serv.NEXTVAL
              ,dlls.ent_id
              ,dlls.filial_id
              ,v_lic_id
              ,NULL
              ,dlls.T_PERIL_ID
              ,dlls.note
          FROM dms_lpu_license_serv dlls
         WHERE dlls.dms_lpu_license_id = v_dms_lpu_license.dms_lpu_license_id;
    END LOOP;
    CLOSE c_l;
    -- ������
    Doc.set_doc_status(v_contract_lpu_ver.contract_lpu_ver_id, 'NEW');
  
    --����������� ��������� �������� ���
    Pkg_Dms.copy_contract_lpu(v_contract_lpu_ver.contract_lpu_ver_id
                             ,p_version_id
                             ,p_start_date
                             ,p_end_date);
  
    --����������� ������� �������
    FOR cur IN (SELECT * FROM contract_lpu_ver_acc WHERE contract_lpu_ver_id = p_version_id)
    LOOP
      INSERT INTO INS.CONTRACT_LPU_VER_ACC
        (CONTRACT_LPU_VER_ACC_ID
        ,IS_NEED_ACC
        ,CONTRACT_LPU_VER_ID
        ,DMS_CALC_ADV_SUM_VAL
        ,DMS_CALC_ADV_SUM_ID
        ,T_PAYMENT_TERMS_ID
        ,ACC_AMOUNT
        ,ADD_AMOUNT
        ,DMS_ADV_TYPE_ID
        ,DMS_LPU_ACC_TYPE_ID
        ,is_default)
        SELECT sq_contract_lpu_ver.NEXTVAL
              ,cur.is_need_acc
              ,v_contract_lpu_ver.contract_lpu_ver_id
              ,cur.dms_calc_adv_sum_val
              ,cur.dms_calc_adv_sum_id
              ,cur.t_payment_terms_id
              ,cur.acc_amount
              ,cur.add_amount
              ,cur.dms_adv_type_id
              ,cur.dms_lpu_acc_type_id
              ,cur.is_default
          FROM dual;
    END LOOP;
  
    RETURN v_contract_lpu_ver.contract_lpu_ver_id;
  END;

  FUNCTION can_be_copied(p_version_id IN NUMBER) RETURN NUMBER IS
    v_ret NUMBER := 0;
    v_num NUMBER;
    CURSOR cur_find_new IS
      SELECT clv1.contract_lpu_ver_id
        FROM ven_contract_lpu_ver clv
            ,ven_contract_lpu_ver clv1
       WHERE Doc.get_doc_status_brief(clv1.contract_lpu_ver_id) = 'NEW'
         AND clv1.contract_lpu_id = clv.contract_lpu_id
         AND clv.contract_lpu_ver_id = p_version_id;
  BEGIN
    -- �� - ���� ��� ��������� ����������� ������
    IF p_version_id IS NOT NULL
       AND Doc.get_doc_status_brief(p_version_id) = 'CURRENT'
    THEN
      OPEN cur_find_new;
      FETCH cur_find_new
        INTO v_num;
      IF cur_find_new%NOTFOUND
      THEN
        v_ret := 1;
      ELSE
        v_ret := -1;
      END IF;
      CLOSE cur_find_new;
    ELSE
      v_ret := 0;
    END IF;
  
    RETURN v_ret;
  END;

  -- ��������� '����� ������� ������ � ��������� �����������'
  PROCEDURE set_payadvlpu_status(p_payment_id IN NUMBER) IS
    CURSOR cur_setoff IS
      SELECT dso.parent_doc_id FROM ven_doc_set_off dso WHERE dso.child_doc_id = p_payment_id;
    v_parent_id NUMBER;
  BEGIN
    IF Doc.get_doc_templ_brief(p_payment_id) = '���'
    THEN
      FOR cl IN cur_setoff
      LOOP
        IF Doc.get_doc_templ_brief(cl.parent_doc_id) = 'PAYADVLPU'
        THEN
          Doc.set_doc_status(cl.parent_doc_id
                            ,Doc.get_doc_status_brief(p_payment_id)
                            ,SYSDATE
                            ,'AUTO'
                            ,'������ ���������');
        END IF;
      END LOOP;
    ELSIF Doc.get_doc_templ_brief(p_payment_id) = 'PAYADVLPU'
    THEN
      v_parent_id := get_parent_doc(p_payment_id);
      IF v_parent_id IS NOT NULL
         AND Doc.get_doc_templ_brief(v_parent_id) = 'DMS_INV_LPU_ADV'
      THEN
        Doc.set_doc_status(v_parent_id
                          ,Doc.get_doc_status_brief(p_payment_id)
                          ,SYSDATE
                          ,'AUTO'
                          ,'������ ���������');
      END IF;
    END IF;
  END;

  -- ��������� '������ ������ ����� �� ���'
  PROCEDURE cancel_payment(p_ac_payment_id IN NUMBER) IS
    v_parent_id NUMBER;
  BEGIN
    IF Doc.get_doc_templ_brief(p_ac_payment_id) = 'PAYADVLPU'
    THEN
      --delete from ven_trans where obj_uro_id = p_ac_payment_id;
      v_parent_id := get_parent_doc(p_ac_payment_id);
      IF v_parent_id IS NOT NULL
         AND Doc.get_doc_templ_brief(v_parent_id) = 'DMS_INV_LPU_ADV'
      THEN
        Doc.set_doc_status(v_parent_id
                          ,'NEW'
                          ,SYSDATE
                          ,'AUTO'
                          ,'���������������� ��������');
      END IF;
      Doc.set_doc_status(p_ac_payment_id
                        ,'PAID'
                        ,SYSDATE + 1
                        ,'AUTO'
                        ,'���������������� ��������');
    END IF;
  END;

  -- �������� �� ������������� ��������� ��� ��������
  FUNCTION get_parent_doc(p_child_id IN NUMBER) RETURN NUMBER IS
    CURSOR cur_parent IS
      SELECT dd.parent_id FROM ven_doc_doc dd WHERE dd.child_id = p_child_id;
    v_ret_val NUMBER;
  BEGIN
    OPEN cur_parent;
    FETCH cur_parent
      INTO v_ret_val;
    IF cur_parent%NOTFOUND
    THEN
      v_ret_val := NULL;
    END IF;
    CLOSE cur_parent;
    RETURN(v_ret_val);
  END;

  /*function get_active_version(p_contract_lpu_ver_id number) return number is
    v_version_id      number;
    v_prev_version_id number;
    v_status          varchar(30);
    v_version_num     number;
    v_ret_val         number;
  begin
    select *
    into   v_version_id, v_version_num, v_status, v_prev_version_id
    from   (
             select t.contract_lpu_ver_id,
                    t.version_ord_number,
                    t.status,
                    lead(t.contract_lpu_ver_id, 1) over(order by t.version_ord_number desc)
             from (
                    select clv.contract_lpu_ver_id,
                           clv.version_ord_number,
                           doc.get_doc_status_brief(clv.contract_lpu_ver_id) status
                    from   contract_lpu_ver clv
                    where  clv.contract_lpu_id = p_contract_lpu_ver_id) t
             where t.status in ('NEW', 'CURRENT', 'BREAK')
             order by t.version_ord_number desc
           )
    where rownum = 1;
  
    if (v_status = 'NEW' and v_prev_version_id is null) then
      v_ret_val := v_version_id;
    elsif (v_status = 'NEW' and v_prev_version_id is not null) then
      v_ret_val := v_prev_version_id;
    else
      v_ret_val := v_version_id;
    end if;
    return v_ret_val;
  end;*/

  -- �������� �� ����������� ������������ ������� "�������"
  FUNCTION can_be_current
  (
    p_contract_lpu_ver_id IN NUMBER
   ,is_full               BOOLEAN DEFAULT FALSE
  ) RETURN VARCHAR2 IS
    v_ret_val    VARCHAR2(1000) := NULL; -- ������������ ��������
    v_start_date DATE; -- ���� ������ ������� ������
    v_end_date   DATE; -- ���� ��������� ������� ������
    v_cur_vers   NUMBER; -- �� ������� ������
    v_min_date   DATE; -- ����������� ��������� ���� ������
    v_max_date   DATE; -- ������������ ��������� ���� ���������
  
  BEGIN
    v_ret_val := NULL;
  
    IF p_contract_lpu_ver_id IS NULL
    THEN
      v_ret_val := '�� ������ ��������';
      RETURN(v_ret_val);
    END IF;
    -- ������� ������ ������ ���� "�����"
    IF Doc.get_doc_status_brief(p_contract_lpu_ver_id) NOT IN ('CURRENT', 'STOPED', 'BREACK')
    THEN
      v_ret_val := NULL;
    ELSE
      v_ret_val := '������ "�����������" �� ����� ���� ���������� ��� ����� ���������';
      RETURN(v_ret_val);
    END IF;
  
    IF NOT is_full
    THEN
      RETURN(v_ret_val);
    END IF;
    -- �������� ���������� ���������
    v_cur_vers := get_current_version(p_contract_lpu_ver_id);
    IF v_cur_vers IS NULL
    THEN
      v_ret_val := '���������� ���������� ������� ������ ���������';
      RETURN(v_ret_val);
    ELSE
      IF v_cur_vers = p_contract_lpu_ver_id
      THEN
        v_ret_val := NULL;
        RETURN(v_ret_val);
      END IF;
    END IF;
  
    SELECT clv1.start_date
          ,clv1.end_date
          ,clv2.start_date
          ,clv2.end_date
      INTO v_start_date
          ,v_end_date
          ,v_min_date
          ,v_max_date
      FROM ven_contract_lpu_ver clv1
          ,ven_contract_lpu_ver clv2
          ,ven_contract_lpu     cl
     WHERE clv2.contract_lpu_ver_id = cl.curr_version_id
       AND cl.contract_lpu_id = clv1.contract_lpu_id
       AND clv1.contract_lpu_ver_id = p_contract_lpu_ver_id;
  
    IF v_start_date < (v_min_date + 1)
    THEN
      v_ret_val := '���� ������ ������ ��������������� ���������� ������ ���� ���� �� �� ���� ���� ������ ���� ������ �����������';
      RETURN(v_ret_val);
    END IF;
  
    IF v_start_date > v_max_date
    THEN
      v_ret_val := '���� ������ �������� ��������������� ���������� �� ����� ���� ������ ���� ��������� ��������!';
      RETURN(v_ret_val);
    END IF;
  
    IF v_end_date > v_max_date
    THEN
      v_ret_val := '���� ��������� �������� ��������������� ���������� �� ����� ���� ������ ���� ��������� ��������!';
      RETURN(v_ret_val);
    END IF;
  
    RETURN(v_ret_val);
  END;

  FUNCTION can_be_canceled(p_version_id IN NUMBER) RETURN NUMBER IS
    v_ret              NUMBER := 0;
    v_ver_num          NUMBER;
    v_max_ver_num      NUMBER;
    v_doc_status_brief VARCHAR2(30);
  BEGIN
  
    IF p_version_id IS NOT NULL
    THEN
      -- ���� ��� ��������� ������
      SELECT clv.version_ord_number
            ,Doc.get_doc_status_brief(clv.contract_lpu_ver_id)
            ,(SELECT MAX(clvs.version_ord_number)
               FROM contract_lpu_ver clvs
              WHERE clvs.contract_lpu_id = clv.contract_lpu_id
                AND Doc.get_doc_status_brief(p_version_id) NOT IN ('CANCEL'))
        INTO v_ver_num
            ,v_doc_status_brief
            ,v_max_ver_num
        FROM contract_lpu_ver clv
       WHERE clv.contract_lpu_id =
             (SELECT clvss.contract_lpu_id
                FROM contract_lpu_ver clvss
               WHERE clvss.contract_lpu_ver_id = clv.contract_lpu_ver_id)
         AND clv.contract_lpu_ver_id = p_version_id;
      IF (v_ver_num = v_max_ver_num)
      THEN
        v_ret := 1;
      END IF;
    
      -- � ���� ������ ������ �� ����� �������
      IF v_ret = 1
         AND v_doc_status_brief <> 'CANCEL'
      THEN
        v_ret := 1;
      ELSE
        v_ret := 0;
      END IF;
    END IF;
    RETURN v_ret;
  END;

  /*  function can_be_declined(p_version_id in number) return number is
    v_ret   number := 0;
    v_cl_id number;
  begin
    SELECT clv.contract_lpu_id
      into v_cl_id
      FROM contract_lpu_ver clv
     where clv.contract_lpu_ver_id = p_version_id;
    if p_version_id is not null then
      if get_active_version(v_cl_id) = p_version_id and
         doc.get_doc_status_brief(p_version_id) in ('CURRENT', 'BREAK') then
        v_ret := 1;
      end if;
    end if;
    return v_ret;
  end;*/

  /*function set_current_status(p_contract_lpu_ver_id in number) return varchar2 is
    v_status_date date;
    v_old_verson_id number;
    v_Contract_ID number;
    v_contract_lpu_ver contract_lpu_ver%rowtype;
    v_ret_val varchar2(2000) := null;
  
  begin
  -- ���������, ����� �� ����� ����������� (������� ������ - �����)
    v_ret_val := can_be_current(p_contract_lpu_ver_id, true);
    if v_ret_val is null then
      select clv.*
        into v_contract_lpu_ver
        from contract_lpu_ver clv
       where clv.contract_lpu_ver_id = p_contract_lpu_ver_id;
  -- ��������� �� ������� ����������� ������
      v_old_verson_id := get_current_version(p_contract_lpu_ver_id);
      if (v_old_verson_id is not null) and (v_old_verson_id <> p_contract_lpu_ver_id) then
       -- ������������� ������ ������ ������ � "�������������"
        doc.set_doc_status(v_old_verson_id, 'STOPED', sysdate);
      end if;
  -- ������������� ������ ����� ������ � "�����������"
      doc.set_doc_status(p_contract_lpu_ver_id, 'CURRENT', sysdate);
  -- � ����� ������������� ������ �� ����������� ������
      update contract_lpu cl
         set cl.curr_version_id = p_contract_lpu_ver_id
       where cl.contract_lpu_id in (select clvs.contract_lpu_id
                                      from contract_lpu_ver clvs
                                     where clvs.contract_lpu_ver_id = p_contract_lpu_ver_id);
  -- ��������� �� ����� ��������
      select clv.contract_lpu_id
        into v_Contract_id
        from contract_lpu_ver clv
       where clv.contract_lpu_ver_id = p_contract_lpu_ver_id;
  -- ������������� ������ ������ �������� � ���
      set_contract_status(v_Contract_id);
      return(v_ret_val);
    else
      return(v_ret_val);
        --raise_application_error(-20000, '���������� ���������� ������ "�����������" ������� ������');
    end if;
  end;*/

  PROCEDURE set_cancel_status(p_version_id NUMBER) IS
    v_status_brief      VARCHAR2(30);
    v_contract_lpu_ver  contract_lpu_ver%ROWTYPE;
    v_active_version_id NUMBER;
  BEGIN
    IF (can_be_canceled(p_version_id) = 1)
    THEN
      v_status_brief := Doc.get_doc_status_brief(p_version_id);
      SELECT *
        INTO v_contract_lpu_ver
        FROM contract_lpu_ver clv
       WHERE clv.contract_lpu_ver_id = p_version_id;
    
      -- ���� ����� � ��� �� ������ ������ (�� �����������)
      IF (v_status_brief = 'NEW' AND v_contract_lpu_ver.version_ord_number > 1)
      THEN
        DELETE FROM ven_contract_lpu_ver clv WHERE clv.contract_lpu_ver_id = p_version_id;
        -- �����, ���� �������� ������������ ���. ���������� ��� �����������
      ELSIF (v_status_brief = 'CURRENT' OR v_status_brief = 'BREAK')
      THEN
        -- ��������� ��������� ������
        Doc.set_doc_status(p_version_id, 'CANCEL');
        IF v_contract_lpu_ver.version_ord_number > 1
        THEN
          -- ���������� ���������� ����������� ����������� ������ ������
          SELECT *
            INTO v_active_version_id
            FROM (SELECT clv.contract_lpu_ver_id
                    FROM contract_lpu_ver clv
                   WHERE clv.contract_lpu_id = v_contract_lpu_ver.contract_lpu_id
                     AND Doc.get_doc_status_brief(clv.contract_lpu_ver_id) = 'CURRENT'
                   ORDER BY clv.version_ord_number DESC)
           WHERE ROWNUM = 1;
        
          UPDATE contract_lpu cl
             SET cl.curr_version_id = v_active_version_id
           WHERE cl.contract_lpu_id = v_contract_lpu_ver.contract_lpu_id;
        END IF;
      END IF;
    END IF;
  END;

  /*  function new_version_decline(p_version_id in number) return number is
    v_new_version_id number;
  begin
    if can_be_declined(p_version_id) = 1 then
      -- co����� ����� ������
      v_new_version_id := new_version(p_version_id);
    end if;
    return v_new_version_id;
  end;*/

  /*  function get_price_status_brief(p_version_id in number, p_dms_price_id in number) return varchar2 is
    v_contract_lpu_ver contract_lpu_ver%rowtype;
    v_dms_price dms_price%rowtype;
    v_result varchar(1);
  begin
    begin
      select * into v_contract_lpu_ver from contract_lpu_ver where contract_lpu_ver_id = p_version_id;
      select * into v_dms_price from dms_price where dms_price_id = p_dms_price_id;
      if v_dms_price.contract_lpu_ver_id = v_contract_lpu_ver.contract_lpu_ver_id then
        v_result := '+';
      else
        if doc.get_doc_status_brief(v_contract_lpu_ver.contract_lpu_ver_id) in ('NEW', 'CURRENT') then
          v_result := ' ';
        else
          v_result := '-';
        end if;
      end if;
    exception when others then
      v_result := 'X';
    end;
    return v_result;
  end;*/

  /*  procedure set_decline_status(p_version_id number) is
    v_contract_lpu_ver contract_lpu_ver%rowtype;
  begin
    if (can_be_declined(p_version_id) = 1) then
  
      SELECT *
      into v_contract_lpu_ver
      FROM contract_lpu_ver clv
      where clv.contract_lpu_ver_id = p_version_id;
  
      -- ��������� ��������� �����������
      doc.set_doc_status(p_version_id, 'BREAK');
      set_contract_status(v_contract_lpu_ver.contract_lpu_id);
  
    end if;
  end;*/

  /**
  * �������� �� ������������� �������� � ��������� ��� ������ ���������� �������
  * �� ���������� ������ �������
  * @author Ilyushkin S.
  * @param p_lpu_id �� ���
  * @param p_start_date ���� ������ �������� �������� (������)
  * @param p_end_date ���� ��������� �������� �������� (������)
  * @param dms_lpu_acc_type_id �� ������ ������� ������
  * @return ���� ������� ������, �� ������ ���� �<����� ��������> �� <���� ����������>, ���� ��� - null
  */
  FUNCTION check_contract
  (
    p_contract_lpu_id     IN NUMBER
   ,p_lpu_id              IN NUMBER
   ,p_start_date          IN DATE
   ,p_end_date            IN DATE
   ,p_dms_lpu_acc_type_id IN NUMBER
  ) RETURN VARCHAR2 IS
    CURSOR cur_con_lpu IS
      SELECT d.num
            ,clv.sign_date
        FROM ven_document         d
            ,ven_contract_lpu     cl
            ,ven_contract_lpu_ver clv
            ,ven_doc_status       ds
            ,ven_doc_status_ref   dsr
       WHERE clv.contract_lpu_id <> p_contract_lpu_id
         AND d.document_id = clv.contract_lpu_id
         AND (clv.start_date BETWEEN p_start_date AND p_end_date OR
             clv.end_date BETWEEN p_start_date AND p_end_date)
         AND clv.dms_lpu_acc_type_id = p_dms_lpu_acc_type_id
         AND dsr.brief = 'CURRENT'
         AND dsr.doc_status_ref_id = ds.doc_status_ref_id
         AND ds.document_id = clv.contract_lpu_ver_id
         AND clv.contract_lpu_id = cl.contract_lpu_id
         AND cl.lpu_id = p_lpu_id;
    v_num       VARCHAR2(50);
    v_sign_date DATE;
    v_ret_val   VARCHAR2(60);
  BEGIN
    OPEN cur_con_lpu;
    FETCH cur_con_lpu
      INTO v_num
          ,v_sign_date;
    IF cur_con_lpu%FOUND
    THEN
      v_ret_val := '������� �' || v_num || ' �� ' || TO_CHAR(v_sign_date, 'DD.MM.YYYY');
    ELSE
      v_ret_val := NULL;
    END IF;
    CLOSE cur_con_lpu;
    RETURN(v_ret_val);
  END;

  /**
  * ����� ������� �����������(!) ������ ��������
  * @author Ilyushkin S.
  * @param p_contract_lpu_ver_id �� ����� ������ ��������
  * @return �� ������� ������ ��������, null ���� �� �������
  */
  FUNCTION get_current_version(p_contract_lpu_ver_id IN NUMBER) RETURN NUMBER IS
    v_ret_val NUMBER := NULL;
  
    CURSOR cur_vers IS
      SELECT cl.curr_version_id
        FROM ven_contract_lpu     cl
            ,ven_contract_lpu_ver clv
       WHERE cl.contract_lpu_id = clv.contract_lpu_id
         AND clv.contract_lpu_ver_id = p_contract_lpu_ver_id;
  BEGIN
    OPEN cur_vers;
    FETCH cur_vers
      INTO v_ret_val;
    IF cur_vers%NOTFOUND
    THEN
      v_ret_val := NULL;
    END IF;
    CLOSE cur_vers;
  
    RETURN(v_ret_val);
  END;

  FUNCTION get_ver_status(p_contract_lpu_ver_id IN NUMBER) RETURN VARCHAR2 IS
    CURSOR cur_doc_stat IS
      SELECT dsr.brief
        FROM doc_status     ds
            ,doc_status_ref dsr
       WHERE ds.doc_status_id = (SELECT MAX(ds1.doc_status_id)
                                   FROM doc_status ds1
                                  WHERE ds1.document_id = p_contract_lpu_ver_id)
         AND dsr.doc_status_ref_id = ds.doc_status_ref_id
         AND ds.document_id = p_contract_lpu_ver_id;
  
    v_doc_status VARCHAR2(20);
    v_ret_val    VARCHAR2(50);
    v_start_date DATE;
    v_end_date   DATE;
  BEGIN
    OPEN cur_doc_stat;
    FETCH cur_doc_stat
      INTO v_doc_status;
  
    IF cur_doc_stat%NOTFOUND
    THEN
      v_ret_val := '����������';
    ELSE
      IF v_doc_status = 'NEW'
      THEN
        v_ret_val := '�� ��������� � �����';
      ELSIF v_doc_status = 'CURRENT'
      THEN
        SELECT TRUNC(clv.start_date)
              ,TRUNC(clv.end_date)
          INTO v_start_date
              ,v_end_date
          FROM ven_contract_lpu_ver clv
         WHERE clv.contract_lpu_ver_id = p_contract_lpu_ver_id;
        IF TRUNC(SYSDATE) > v_end_date
        THEN
          v_ret_val := '�������� ���������';
        ELSIF TRUNC(SYSDATE) BETWEEN v_start_date AND v_end_date
        THEN
          v_ret_val := '���������';
        ELSIF TRUNC(SYSDATE) < v_start_date
        THEN
          v_ret_val := '�������� �� ��������';
        END IF;
      END IF;
    END IF;
    RETURN(v_ret_val);
  END;

  FUNCTION get_contract_full_name(p_contract_lpu_id IN NUMBER) RETURN VARCHAR2 IS
    v_ret_val    VARCHAR2(1000);
    v_contr_type NUMBER;
    CURSOR cur_name IS
      SELECT '� ' || cl.num || ' ������. � ' || TO_CHAR(clv.start_date, 'DD.MM.YYYY') || ' �� ' ||
             TO_DATE(clv.end_date, 'DD.MM.YYYY')
        FROM ven_contract_lpu_ver clv
            ,ven_contract_lpu     cl
       WHERE clv.version_ord_number = 1
         AND clv.contract_lpu_id = p_contract_lpu_id
         AND cl.contract_lpu_id = p_contract_lpu_id;
  BEGIN
    OPEN cur_name;
    FETCH cur_name
      INTO v_ret_val;
    IF cur_name%NOTFOUND
    THEN
      v_ret_val := NULL;
    END IF;
    CLOSE cur_name;
  
    RETURN(v_ret_val);
  END;

  /**
  * �� �� ������ �������� � ��� ���������� ������ ����:
  * � <����� ��������> �� <���� ����������>, ����������� � <���� ������>
  * �� <���� ���������>
  * @author Ilyushkin S.
  * @param p_contract_lpu_ver_id �� ������ ��������
  * @return ������ ����� ������
  */
  FUNCTION get_contract_lpu_ver_full_num(p_contract_lpu_ver_id IN NUMBER) RETURN VARCHAR2 IS
    v_ret_val VARCHAR2(1000);
    CURSOR cur_name IS
      SELECT ('� ' || d.num || ' �� ' || TO_CHAR(clv.sign_date, 'DD.MM.YYYY') || ', ����������� � ' ||
             TO_CHAR(clv.start_date, 'DD.MM.YYYY') || ' �� ' || TO_CHAR(clv.end_date, 'DD.MM.YYYY')) full_num
        FROM ven_document         d
            ,ven_contract_lpu     cl
            ,ven_contract_lpu_ver clv
       WHERE d.document_id = cl.contract_lpu_id
         AND cl.contract_lpu_id = clv.contract_lpu_id
         AND clv.contract_lpu_ver_id = p_contract_lpu_ver_id;
  BEGIN
    IF p_contract_lpu_ver_id IS NOT NULL
    THEN
      OPEN cur_name;
      FETCH cur_name
        INTO v_ret_val;
      IF cur_name%NOTFOUND
      THEN
        v_ret_val := NULL;
      END IF;
      CLOSE cur_name;
    ELSE
      v_ret_val := NULL;
    END IF;
    RETURN(v_ret_val);
  END;

  FUNCTION is_set_off
  (
    p_document_id     IN NUMBER
   ,p_doc_templ_brief VARCHAR2
  ) RETURN NUMBER IS
    v_ret_val NUMBER;
    CURSOR cur_serv_act IS
      SELECT ap.rev_amount
        FROM ven_ac_payment ap
            ,ven_doc_doc    dd
       WHERE ap.payment_id = dd.child_id
         AND dd.parent_id = p_document_id
      UNION
      SELECT Pkg_Contract_Lpu.is_set_off(ap.payment_id, 'DMS_INV_LPU') rev_amount
        FROM ven_ac_payment ap
            ,ven_doc_doc    dd
       WHERE ap.payment_id = dd.parent_id
         AND dd.child_id = p_document_id;
    CURSOR cur_payment IS
      SELECT ap.rev_amount
        FROM ven_ac_payment   ap
            ,ven_doc_doc      dd
            ,ven_doc_doc      dd1
            ,ven_dms_serv_act dsa
       WHERE ap.payment_id = dd.child_id
         AND dd.parent_id = dsa.dms_serv_act_id
         AND dsa.dms_serv_act_id = dd1.child_id
         AND dd1.parent_id = p_document_id
      UNION
      SELECT ap.rev_amount
        FROM ven_ac_payment ap
            ,ven_doc_doc    dd
       WHERE ap.payment_id = dd.child_id
         AND dd.parent_id = p_document_id;
    CURSOR cur_serv_reg IS
      SELECT Pkg_Contract_Lpu.is_set_off(dsa.dms_serv_act_id, dt.brief) amount
        FROM ven_doc_doc      dd
            ,ven_dms_serv_act dsa
            ,ven_doc_templ    dt
       WHERE dt.doc_templ_id = dsa.doc_templ_id
         AND dsa.dms_serv_act_id = dd.parent_id
         AND dd.child_id = p_document_id;
  BEGIN
    IF p_doc_templ_brief IN ('DMS_SERV_PAY', 'DMS_SERV_ACT', 'DMS_SERV_INV')
    THEN
      OPEN cur_serv_act;
      FETCH cur_serv_act
        INTO v_ret_val;
      IF cur_serv_act%NOTFOUND
      THEN
        v_ret_val := NULL;
      END IF;
      CLOSE cur_serv_act;
    ELSIF p_doc_templ_brief IN ('DMS_INV_LPU')
    THEN
      OPEN cur_payment;
      FETCH cur_payment
        INTO v_ret_val;
      IF cur_payment%NOTFOUND
      THEN
        v_ret_val := NULL;
      END IF;
      CLOSE cur_payment;
    ELSIF p_doc_templ_brief IN ('DMS_SERV_REG')
    THEN
      OPEN cur_serv_reg;
      FETCH cur_serv_reg
        INTO v_ret_val;
      IF cur_serv_reg%NOTFOUND
      THEN
        v_ret_val := NULL;
      END IF;
      CLOSE cur_serv_reg;
    ELSIF p_doc_templ_brief IN
          ('DMS_ACT_TECH', 'DMS_ACT_FIRST_MED', 'DMS_ACT_SELECT_MED', 'DMS_ACT_DIRECT_MED')
    THEN
      OPEN cur_serv_reg;
      FETCH cur_serv_reg
        INTO v_ret_val;
      IF cur_serv_reg%NOTFOUND
      THEN
        v_ret_val := NULL;
      END IF;
      CLOSE cur_serv_reg;
    END IF;
    RETURN(v_ret_val);
  END;

  FUNCTION can_be_deleted(p_contract_lpu_id IN NUMBER) RETURN BOOLEAN IS
  BEGIN
    DELETE FROM ven_contract_lpu_ver WHERE contract_lpu_id = p_contract_lpu_id;
    DELETE FROM ven_contract_lpu WHERE contract_lpu_id = p_contract_lpu_id;
    RETURN(TRUE);
  
  EXCEPTION
    WHEN OTHERS THEN
      RETURN(FALSE);
  END;

  -- ��������� ����� ������� ������ �������� � ������ ��������
  FUNCTION set_contract_lpu_ver_status
  (
    p_contract_lpu_ver_id IN NUMBER
   ,p_status              IN VARCHAR2
   ,p_status_date         IN DATE DEFAULT SYSDATE
  ) RETURN VARCHAR2 IS
    v_ret_val         VARCHAR2(50);
    v_doc_status_id   NUMBER;
    v_contract_lpu_id NUMBER;
    v_current_vers_id NUMBER;
  
    CURSOR cur_status IS
      SELECT dsr.doc_status_ref_id FROM ven_doc_status_ref dsr WHERE dsr.brief = p_status;
  
    CURSOR cur_parent IS
      SELECT cl.contract_lpu_id
            ,cl.curr_version_id
        FROM ven_contract_lpu cl
       WHERE cl.contract_lpu_id =
             (SELECT clv.contract_lpu_id
                FROM ven_contract_lpu_ver clv
               WHERE clv.contract_lpu_ver_id = p_contract_lpu_ver_id);
  BEGIN
    OPEN cur_status;
    FETCH cur_status
      INTO v_doc_status_id;
    IF cur_status%NOTFOUND
    THEN
      v_ret_val := '����������� ������ ���������';
      CLOSE cur_status;
      RETURN(v_ret_val);
    END IF;
    CLOSE cur_status;
  
    OPEN cur_parent;
    FETCH cur_parent
      INTO v_contract_lpu_id
          ,v_current_vers_id;
    IF cur_parent%NOTFOUND
    THEN
      v_contract_lpu_id := NULL;
      v_current_vers_id := NULL;
      v_ret_val         := '���������� �������� ������ ���������';
      CLOSE cur_parent;
      RETURN(v_ret_val);
    END IF;
    CLOSE cur_parent;
  
    IF p_status = 'NEW'
    THEN
      Doc.set_doc_status(p_contract_lpu_ver_id, p_status, p_status_date);
    ELSIF p_status = 'CURRENT'
    THEN
      IF can_be_current(p_contract_lpu_ver_id, TRUE) IS NULL
      THEN
        Doc.set_doc_status(v_current_vers_id, 'STOPED', p_status_date);
        UPDATE ven_contract_lpu
           SET curr_version_id = p_contract_lpu_ver_id
         WHERE contract_lpu_id = v_contract_lpu_id;
        UPDATE ven_dms_price
           SET status_hist_id =
               (SELECT status_hist_id FROM ven_status_hist WHERE brief = 'CURRENT')
         WHERE contract_lpu_ver_id = p_contract_lpu_ver_id;
        UPDATE ven_dms_lpu_license
           SET status_hist_id =
               (SELECT status_hist_id FROM ven_status_hist WHERE brief = 'CURRENT')
         WHERE contract_lpu_ver_id = p_contract_lpu_ver_id;
        Doc.set_doc_status(p_contract_lpu_ver_id, 'CURRENT', p_status_date);
      END IF;
    END IF;
  
    IF (v_current_vers_id IS NOT NULL)
       AND (v_current_vers_id = p_contract_lpu_ver_id)
    THEN
      Doc.set_doc_status(v_contract_lpu_id, p_status, p_status_date);
    END IF;
    RETURN(v_ret_val);
  END;

  FUNCTION create_ins_var_code(p_dms_ins_var_id NUMBER) RETURN VARCHAR2 IS
    v_ret_val VARCHAR2(2000);
  BEGIN
    RETURN(v_ret_val);
  END;

  FUNCTION GET_ACC_TYPE
  (
    p_contract_lpu_ver_id IN NUMBER
   ,p_str_type            IN VARCHAR2 DEFAULT 'L'
  ) RETURN VARCHAR2 IS
    v_ret_val VARCHAR2(500);
    v_count   NUMBER;
    v_temp    VARCHAR2(500) := NULL;
    v_short   VARCHAR2(50) := NULL;
  
    CURSOR cur_count IS
      SELECT COUNT(dat.NAME) count_type
        FROM ven_contract_lpu_ver_acc clva
            ,ven_dms_lpu_acc_type     dat
       WHERE dat.dms_lpu_acc_type_id = clva.dms_lpu_acc_type_id
         AND clva.contract_lpu_ver_id = p_contract_lpu_ver_id;
  
    CURSOR cur_name IS
      SELECT dat.NAME
            ,DECODE(dat.brief, 'FACT', '�', 'ATTACH', '�', '�') short_name
        FROM ven_contract_lpu_ver_acc clva
            ,ven_dms_lpu_acc_type     dat
       WHERE dat.dms_lpu_acc_type_id = clva.dms_lpu_acc_type_id
         AND clva.contract_lpu_ver_id = p_contract_lpu_ver_id;
  BEGIN
    OPEN cur_count;
    FETCH cur_count
      INTO v_count;
    IF cur_count%NOTFOUND
    THEN
      v_count := 0;
    END IF;
    CLOSE cur_count;
  
    IF v_count = 0
    THEN
      v_ret_val := NULL;
    ELSIF v_count = 1
    THEN
      OPEN cur_name;
      FETCH cur_name
        INTO v_ret_val
            ,v_short;
      IF cur_name%NOTFOUND
      THEN
        v_ret_val := NULL;
        v_short   := NULL;
      END IF;
      CLOSE cur_name;
      IF p_str_type = 'S'
      THEN
        v_ret_val := v_short;
      END IF;
    ELSIF v_count > 1
    THEN
      FOR c_name IN cur_name
      LOOP
        IF LOWER(c_name.NAME) <> '�� �����'
        THEN
          IF p_str_type = 'L'
          THEN
            v_temp := v_temp || c_name.NAME || ',';
          ELSE
            v_temp := v_temp || '�' || ',';
          END IF;
        END IF;
      END LOOP;
      v_temp := RTRIM(v_temp, ',');
      IF p_str_type = 'L'
      THEN
        v_ret_val := '�� ����� (' || v_temp || ')';
      ELSE
        v_ret_val := '�' || v_temp;
      END IF;
    END IF;
  
    RETURN(v_ret_val);
  END;

  -- �������� ���� �� �������������� �������� ���
  FUNCTION can_edit_prog_lpu RETURN BOOLEAN IS
  
  BEGIN
    IF pkg_app_param.get_app_param_n('CLIENTID') = 12
    THEN
      IF safety.check_right_custom('EDIT_PROG_LPU') = 1
      THEN
        RETURN TRUE;
      ELSE
        RETURN FALSE;
      END IF;
    ELSE
      RETURN FALSE;
    END IF;
  END;

END Pkg_Contract_Lpu;
/

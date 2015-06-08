CREATE OR REPLACE PACKAGE Pkg_Agent_Rate IS

  DATE_PAY          DATE := SYSDATE;
  DATE_BG           DATE := SYSDATE;
  DATE_END          DATE := SYSDATE;
  INDEXING          NUMBER := 0;
  DATE_PLAN         DATE;
  date_st           DATE;
  date_davr_b       DATE;
  date_davr_e       DATE := SYSDATE;
  TYPE_AV           NUMBER;
  ST_MN             NUMBER;
  AG_SALE_NEW       NUMBER := 5;
  AG_SALE_OLD       NUMBER := 7;
  SGP               NUMBER; --���
  glb_recruit_SGP   NUMBER; -- ��� �� ��������������� �������
  glb_count_recruit NUMBER; -- ���-�� ��������������� �������
  KSP               NUMBER; --���
  KA                NUMBER; -- ���-�� �������
  MON               NUMBER; -- ����� �������� ��������

  /**
   * (�������.) ������� �������� ������ ���� ����������� ����� ������� ���������� ��, �������
   *
   * @author  ������� �������
   * @created 01.02.2007 17:08:46
   * @param p_Start_Date ���� ������ ��������� �������,
   * @param p_End_Date ���� ��������� ��������� �������,
   * @param p_Ag_Contract_Header_ID ��� ��������� ���������� ��������
   * @return = Document_ID
  */
  FUNCTION create_new_act
  (
    p_Start_Date            DATE DEFAULT NULL
   ,p_End_Date              DATE DEFAULT SYSDATE
   ,p_Ag_Contract_Header_ID NUMBER
  ) RETURN NUMBER;

  /**
   * �������� ��������� ������� ���������� ��������������
   *
   * @author ���������� �������
   * @param p_vedom_id ��� ��������� ������� �������������� ����������
   * @param p_data_begin ���� ������ ��������� �������
   * @param p_category_id ��������� ������
   * @param p_type_av ��� ���� ���������� �������������� (T_AG_AV_ID)
   * @param p_ag_head_id ��� ���������� �������� (lkz)
   * @return ��� ������ ���������� �������
  */
  PROCEDURE av_main
  (
    p_vedom_id    IN NUMBER
   ,p_data_begin  IN DATE
   ,p_category_id IN NUMBER
   ,p_type_av     IN NUMBER
   ,p_ag_head_id  IN NUMBER DEFAULT NULL
   ,p_err_code    IN OUT NUMBER
   ,p_data_end    IN DATE DEFAULT NULL
  );

  /**
   * ��������� ���������� ������ ������� ��� ������� ��������� ���������� �������������� (���)
   *
   * @author ���������� �������
   * @param p_vedom_id ��� ��������� ������� �������������� ����������
   * @param p_data_begin ���� ������ ��������� �������
   * @param p_category_id ��������� ������
   * @param p_type_av ��� ���� ���������� �������������� (T_AG_AV_ID)
   * @param p_ag_head_id ��� ���������� �������� (lkz)
   * @return ��� ������ ���������� �������
  */
  PROCEDURE av_oav_all
  (
    p_vedom_id    IN NUMBER
   ,p_data_begin  IN DATE
   ,p_category_id IN NUMBER
   ,p_type_av     IN NUMBER
   ,p_ag_head_id  IN NUMBER DEFAULT NULL
   ,p_err_code    IN OUT NUMBER
  );

  /**
   * ��������� ���������� ������ ������� ��� ������� ��������� ���������� �������������� (���)
   *
   * @author ���������� �������
   * @param p_vedom_id ��� ��������� ������� �������������� ����������
   * @param p_data_begin ���� ������ ��������� �������
   * @param p_category_id ��������� ������
   * @param p_ag_head_id ��� ���������� �������� (lkz)
   * @return ��� ������ ���������� �������
  */
  PROCEDURE av_dav_all
  (
    p_vedom_id    IN NUMBER
   ,p_data_begin  IN DATE
   ,p_category_id IN NUMBER
   ,p_ag_head_id  IN NUMBER DEFAULT NULL
   ,p_err_code    IN OUT NUMBER
  );
  /**
   * ������ ������  ���������� ������ ������� ��� ������� ��������� ���������� �������������� (���)
   *
   * @author ������� ���������
   * @param p_vedom_id ��� ��������� ������� �������������� ����������
   * @param p_data_begin ���� ������ ��������� �������
   * @param p_category_id ��������� ������
   * @param p_ag_head_id ��� ���������� �������� (lkz)
   * @return ��� ������ ���������� �������
  */
  PROCEDURE av_pr_all
  (
    p_vedom_id    IN NUMBER --��� ��������� ������� �������������� ����������
   ,p_data_begin  IN DATE --���� ������ ��������� �������
   ,p_category_id IN NUMBER --brief ��������� ������
   ,p_ag_head_id  IN NUMBER DEFAULT NULL --��� ���������� ��������
   ,p_err_code    IN OUT NUMBER --������ ���������� �������
  );

  /**
   * ��������� ���������� ������ ��������� ���������� �������������� (���) �� ����������� ������
   *
   * @author ���������� �������
   * @param p_vedom_id ��� ��������� ������� �������������� ����������
   * @param p_data_begin ���� ������ ��������� �������
   * @param policy_agent_id �� ������ �� �������� ������������
   * @param p_method_payment ����� ������� ��(�� ���������� ������ , �� ������� ������)
   * @param p_category_id ��������� ������
   * @return ��� ������ ���������� �������
  */
  PROCEDURE av_oav_one
  (
    p_vedom_id       IN NUMBER
   ,p_data_begin     IN DATE
   ,policy_agent_id  IN NUMBER
   ,p_method_payment IN NUMBER
   ,p_category_id    IN NUMBER
   ,p_err_code       IN OUT NUMBER
  );
  /**��������� ���������� ������� ������ ��� p_policy_agent_com_id
  */
  PROCEDURE Av_Oav_Pol_Ag_Com
  (
    p_policy_agent_com_id IN NUMBER
   ,p_date_pay            IN DATE
   , --���� �������
    p_st                  OUT NUMBER
   , -- ������
    p_key                 OUT NUMBER --��� ������ 0-�������, 1-���������
  );

  /**
   * ��������� ���������� ������ ��������������� ���������� �������������� (���) �� ����������� ������
   *
   * @author ���������� �������
   * @param p_vedom_id ��� ��������� ������� �������������� ����������
   * @param p_data_begin ���� ������ ��������� �������
   * @param p_ag_id ��� ������ ��.��������
   * @param p_category_id ��������� ������
   * @return ��� ������ ���������� �������
  */
  PROCEDURE av_dav_one
  (
    p_vedom_id    IN NUMBER
   ,p_data_begin  IN DATE
   ,p_ag_id       IN NUMBER
   ,p_category_id IN NUMBER
   ,p_err_code    IN OUT NUMBER
  );

  /**
   * ������� ������� ������ �� ��������� ���������� �������������� (���)
   *
   * @author ������� ���������
   * @param p_pol_ag_com_id �� ������ �� �� ������ �� ��������
   *
   * @return ����� ������
  */
  FUNCTION get_rate_oab
  (
    p_pol_ag_com_id NUMBER
   ,par_date        DATE DEFAULT NULL
  ) RETURN NUMBER;

  /**
   * ������� ������� ������ �� ��������� ���������� �������������� (���)
   *
   * @author ������� ���������
   * @param p_data_begin ���� ������ ��������� �������
   * @param p_ag_contract_header_id  ��� ���������� ��������
   * @param p_brief_function ���� ������������ �������
   * @param p_payment_terms_id ��� ������� �������
   * @param p_pay_condition  ������� ������
   *
   * @return ����� ������
  */
  FUNCTION get_rate_dav
  (
    p_data_begin            IN DATE
   ,p_ag_contract_header_id IN NUMBER
   ,p_brief_function        IN CHAR
   ,p_payment_terms_id      IN NUMBER
   ,p_pay_condition         IN NUMBER
  ) RETURN NUMBER;

  /**
   * ������� ������� ������������ ������� ������
   *
   * @author ���������� �������
   * @param p_ag_contract_header_id ��� ������ ���������� ��������
   * @param p_data_begin ���� ������ ��������� �������
   *
   * @return ���������� ����������� ������� ������
  */
  FUNCTION koef_month
  (
    p_ag_contract_header_id IN NUMBER --��� ������ ���������� ���������
   ,p_data_begin            IN DATE
  ) RETURN NUMBER;

  /**
   * ������� ������� ��� � ���������� is_included �� ���� ����� ��� ������������� ���������
   *
   * @author ���������� �������
   * @param p_ag_contract_header_id ��� ������ ���������� ��������
   * @param p_data_begin ���� ������ ��������� �������
   * @param p_type_av ��� ���� ���������� �������������� (T_AG_AV_ID)
   *
   * @return ���
  */
  FUNCTION get_SGP_av
  (
    p_ag_contract_header_id IN NUMBER
   ,p_data_begin            IN DATE
   ,p_type_av               IN NUMBER
  ) RETURN NUMBER;

  /**
   * ��������� ������ ������� ��� (�������� ������������� ��� ��� �� ������������� ���������)
   *
   * @author ���������� �������
   * @param p_ag_contract_header_id ��� ���������� ��������
   * @param p_data_begin ���� ������ ��������� �������
  */
  PROCEDURE del_SGP_dav
  (
    p_ag_contract_header_id IN NUMBER
   ,p_data_begin            IN DATE
  );

  PROCEDURE av_insert_report_dav_ct
  (
    p_AGENT_REPORT_DAV_ID   IN NUMBER -- �� ����
   ,p_POLICY_ID             IN NUMBER DEFAULT NULL
   ,p_SUM_PREMIUM           IN NUMBER DEFAULT NULL
   ,p_SGP                   IN NUMBER DEFAULT NULL
   ,p_is_break              IN NUMBER DEFAULT NULL
   ,p_COMISSION_SUM         IN NUMBER DEFAULT NULL
   ,p_recr_ag_ch_id         IN NUMBER DEFAULT NULL
   ,p_child_ag_ch_id        IN NUMBER DEFAULT NULL
   ,p_bonus_all             IN NUMBER DEFAULT NULL
   ,p_bonus_new             IN NUMBER DEFAULT NULL
   ,p_p_policy_agent_com_id IN NUMBER DEFAULT NULL
   ,p_rate_value            IN NUMBER DEFAULT NULL
   ,p_prm_date_pay          IN DATE DEFAULT NULL
   ,p_prm_manag_lead        IN NUMBER DEFAULT NULL
  );

  PROCEDURE av_pr_MN_GR
  (
    p_vedom_id              IN NUMBER --��� ��������� ������� �������������� ����������
   ,p_report_id             IN NUMBER --��� ����
   ,p_data_begin            IN DATE --���� ������ ��������� �������
   ,p_ag_contract_header_id IN NUMBER --��� ���������� ��������
   ,p_prod_coef_type_id     IN NUMBER --��� �������
   ,p_type_av               IN NUMBER --��� ���� ���������� �������������� (T_AG_AV_ID)
   ,p_err_code              IN OUT NUMBER --������ ���������� �������
  );

  -- ���. ����������� ������ ��������� ������� ���� (����)
  PROCEDURE av_dav_DKPM
  (
    p_vedom_id              IN NUMBER --��� ��������� ������� �������������� ����������
   ,p_report_id             IN NUMBER --��� ������
   ,p_data_begin            IN DATE --���� ������ ��������� �������
   ,p_ag_contract_header_id IN NUMBER --p_ag_id                 --��� ������ ��.��������
   ,p_prod_coef_type_id     IN NUMBER -- ��� �������
   ,p_err_code              OUT NUMBER --������ ���������� �������
  );

  --���. ������ ��������� ��������� �� ���������� ���������� ������������ ����� ������
  PROCEDURE av_dav_DKP
  (
    p_vedom_id              IN NUMBER --��� ��������� ������� �������������� ����������
   ,p_report_id             IN NUMBER --��� ������
   ,p_data_begin            IN DATE --���� ������ ��������� �������
   ,p_ag_contract_header_id IN NUMBER --��� ��������� ��.��������
   ,p_prod_coef_type_id     IN NUMBER -- ��� �������
   ,p_err_code              OUT NUMBER --������ ���������� �������
  );

  --������ � ������ ��������� ��������� ��������� ������
  PROCEDURE av_dav_one_DPPM
  (
    p_vedom_id              IN NUMBER --��� ��������� ������� �������������� ����������
   ,p_report_id             IN NUMBER --��� ����
   ,p_data_begin            IN DATE --���� ������ ��������� �������
   ,p_ag_contract_header_id IN NUMBER --��� ������� ��������
   ,p_prod_coef_type_id     IN NUMBER --��� �������
   ,p_err_code              IN OUT NUMBER --������ ���������� �������
  );

  --������ ������ ��������� �� ������� �������, ���������� ���������
  PROCEDURE av_pr_DR_GR
  (
    p_vedom_id              IN NUMBER --��� ��������� ������� �������������� ����������
   ,p_report_id             IN NUMBER --��� ����
   ,p_data_begin            IN DATE --���� ������ ��������� �������
   ,p_ag_contract_header_id IN NUMBER --��� ���������� ��������
   ,p_prod_coef_type_id     IN NUMBER --��� �������
   ,p_err_code              IN OUT NUMBER --������ ���������� �������
  );

  PROCEDURE av_dav_MN_PREM_PLAN_MENG
  (
    p_vedom_id              IN NUMBER --��� ��������� ������� �������������� ����������
   ,p_report_id             IN NUMBER --��� ����
   ,p_data_begin            IN DATE --���� ������ ��������� �������
   ,p_ag_contract_header_id IN NUMBER --��� ������� ��������
   ,p_prod_coef_type_id     IN NUMBER --��� �������
   ,p_err_code              IN OUT NUMBER --������ ���������� �������
  );
  --������ �� �������� ���������(���)
  PROCEDURE av_pr_dr_recr
  (
    p_vedom_id              IN NUMBER --��� ��������� ������� �������������� ����������
   ,p_report_id             IN NUMBER --��� ����
   ,p_data_begin            IN DATE --���� ������ ��������� �������
   ,p_ag_contract_header_id IN NUMBER --��� ���������� �������� ���������
   ,p_prod_coef_type_id     IN NUMBER --��� �������
   ,p_err_code              IN OUT NUMBER --������ ���������� �������
  );

  /**
  * �������� ���������� ���� �������� ������� ���������
  * @author Kolganov D.
  * @param pol_head �� ��������� ������
  * @param status_date ���� �������
  * @return ���������� ���� �������
  */
  FUNCTION get_policy_status_brief
  (
    pol_head    IN NUMBER
   ,status_date IN DATE DEFAULT SYSDATE
  ) RETURN VARCHAR2;

  /**
  * �������� ���������� ���� �������� ������� ���������
  * @author Kolganov D.
  * ac_contr_head �� ��������� ������
  * ac_contr_head_lead �� �������� ���������(������)
  * report_period_date ���� ������ ��������� �������
  * @return �� ��������� ������ ���������� �������� �� ���� ������ ��������� �������
  */
  FUNCTION get_last_ver_on_date_leader
  (
    ac_contr_head      IN NUMBER
   ,ac_contr_head_lead IN NUMBER
   ,report_period_date IN DATE DEFAULT SYSDATE
  ) RETURN NUMBER;

  /**
  * �������� ���������� ���� �������� ������� ���������
  * @author Kolganov D.
  * @param pol �� ������ ������
  * @param status_date ���� �������
  * @return ���������� ���� �������
  */
  FUNCTION get_p_policy_status_brief
  (
    pol         IN NUMBER
   ,status_date IN DATE DEFAULT SYSDATE
  ) RETURN VARCHAR2;

  ---///��������� ������ � ������� agent_report ����� ��������
  FUNCTION av_insert_report
  (
    p_vedom_id              IN NUMBER --��� ��������� ������� �������������� ����������
   ,p_ag_contract_header_id IN NUMBER --��� ���������� ��������
   ,p_t_ag_av_id            IN NUMBER
   ,p_part_agent            IN NUMBER DEFAULT 0
   ,p_err_code              OUT NUMBER
  ) RETURN NUMBER;

  ---///��������� ������ � ������� agent_report_dav ����� ��������
  PROCEDURE av_insert_report_dav
  (
    p_agent_report_dav_id NUMBER
   ,p_dav                 IN NUMBER --����� ��������
   ,p_data_begin          IN DATE --���� ������ ��������� �������
   ,p_agent_report_id     IN NUMBER -- �� ����
   ,p_ag_id               IN NUMBER --��� ������ ���������� ��������
   ,p_prod_coef_type_id   IN NUMBER
   ,p_NUM_MONTH           IN NUMBER DEFAULT NULL
   ,p_SGP                 IN NUMBER DEFAULT NULL
   ,p_COUNT_POLICY        IN NUMBER DEFAULT NULL
   ,p_COUNT_AGENT         IN NUMBER DEFAULT NULL
   ,p_SUM_PREMIUM         IN NUMBER DEFAULT NULL
   ,p_KSP                 IN NUMBER DEFAULT NULL
  );
  --��������������� ������� ������� ��� ������� ������ � ��������������� ������/��������
  --��� ����������
  PROCEDURE av_dav_mn_sgp
  (
    p_ag_contract_header_id IN NUMBER
   ,p_db                    IN DATE
   ,p_de                    IN DATE
   ,p_agent_report_dav_id   IN NUMBER
  );

  PROCEDURE av_dav_davr
  (
    p_vedom_id    IN NUMBER --��� ��������� ������� �������������� ����������
   ,p_data_begin  IN DATE --���� ������ ��������� �������
   ,p_ag_id       IN NUMBER --��� ������ ��.��������
   ,p_category_id IN NUMBER --��������� ������
   ,p_err_code    IN OUT NUMBER --������ ���������� �������
  );
  PROCEDURE av_update_report
  (
    p_vedom_id              IN NUMBER --��� ��������� ������� �������������� ����������
   ,p_ag_contract_header_id IN NUMBER DEFAULT NULL --��� ���������� ��������
   ,p_err_code              OUT NUMBER
  );

  PROCEDURE av_main_recalc
  (
    p_vedom_id  IN NUMBER
   ,p_ag_header IN VARCHAR2 DEFAULT NULL
  ); --��� ��������� ������� �������������� ����������
  --��������������� �������
  FUNCTION get_par_ST_MN RETURN NUMBER;
  FUNCTION get_par_SGR RETURN NUMBER;
  FUNCTION get_par_KSP RETURN NUMBER;
  FUNCTION get_par_KA RETURN NUMBER;
  FUNCTION get_par_MON RETURN NUMBER;
  FUNCTION get_par_date_plan RETURN DATE;
  FUNCTION get_pol_agent_cansel(p_policy_id IN NUMBER) RETURN NUMBER;
  ------------------------------------------------------------
  --
  -- ���������� ��� �� ��������������� �������
  --
  ------------------------------------------------------------
  FUNCTION get_recruit_SGP RETURN NUMBER;

  ------------------------------------------------------------
  --
  -- ���������� ���-�� ��������������� �������
  --
  ------------------------------------------------------------
  FUNCTION get_count_recruit RETURN NUMBER;

  /**
  * ������� ���������� ���� ����������� ����� 
  *
  * @author  �������� �����
  */
  FUNCTION update_act(p_agent_report_id NUMBER) RETURN NUMBER;

END Pkg_Agent_Rate;
/
CREATE OR REPLACE PACKAGE BODY Pkg_Agent_Rate IS

  ----------------------------------------------------------------------------
  -- �������� ���������� ������� ������
  FUNCTION get_policy_status_brief
  (
    pol_head    IN NUMBER
   ,status_date IN DATE DEFAULT SYSDATE
  ) RETURN VARCHAR2 IS
    rv VARCHAR2(30);
  
  BEGIN
  
    SELECT a.q
      INTO rv
      FROM (SELECT MAX(pp1.policy_id) OVER(PARTITION BY pp1.pol_header_id) m
                  ,pp1.policy_id
                  ,dsr.brief q
              FROM P_POLICY       pp1
                  ,DOC_STATUS     ds
                  ,DOC_STATUS_REF dsr
             WHERE dsr.doc_status_ref_id = ds.doc_status_ref_id
               AND pp1.policy_id = ds.document_id
               AND TRUNC(ds.start_date) <= TRUNC(LAST_DAY(status_date)) --date
               AND pp1.pol_header_id = pol_head
               AND dsr.brief IN ('PRINTED', 'CURRENT', 'ACTIVE')
             ORDER BY ds.start_date DESC) a --p_pol_header
     WHERE a.m = a.policy_id
       AND ROWNUM = 1;
  
    RETURN rv;
  END;

  FUNCTION get_p_policy_status_brief
  (
    pol         IN NUMBER
   ,status_date IN DATE DEFAULT SYSDATE
  ) RETURN VARCHAR2 IS
    rv   VARCHAR2(30);
    s_id NUMBER;
  
  BEGIN
    SELECT pp.pol_header_id INTO s_id FROM P_POLICY pp WHERE pp.policy_id = pol;
    SELECT a.q
      INTO rv
      FROM (SELECT MAX(pp1.policy_id) OVER(PARTITION BY pp1.pol_header_id) m
                  ,pp1.policy_id
                  ,dsr.brief q
              FROM P_POLICY       pp1
                  ,DOC_STATUS     ds
                  ,DOC_STATUS_REF dsr
             WHERE dsr.doc_status_ref_id = ds.doc_status_ref_id
               AND pp1.policy_id = ds.document_id
               AND TRUNC(ds.start_date) <= TRUNC(LAST_DAY(status_date)) --date
               AND pp1.pol_header_id = s_id
               AND dsr.brief IN ('PRINTED', 'CURRENT', 'ACTIVE')
             ORDER BY ds.start_date DESC) a --p_pol_header
     WHERE a.m = a.policy_id
       AND ROWNUM = 1;
  
    RETURN rv;
  END;

  FUNCTION get_last_ver_on_date_leader
  (
    ac_contr_head      IN NUMBER
   ,ac_contr_head_lead IN NUMBER
   ,report_period_date IN DATE DEFAULT SYSDATE
  ) RETURN NUMBER IS
    ac_id NUMBER;
  BEGIN
    SELECT a.ag_contract_id
      INTO ac_id
      FROM (SELECT MAX(ac.ag_contract_id) OVER(PARTITION BY ac.contract_id) m
                   ,ac.ag_contract_id
                   ,ac.date_begin
               FROM AG_CONTRACT ac
                   ,AG_CONTRACT ac_lead
              WHERE
             /* trunc(ac.date_begin) > trunc(report_period_date)--date
             and*/
              TRUNC(ac.date_begin) <= TRUNC(LAST_DAY(report_period_date)) --date
           AND ac.contract_id = ac_contr_head
           AND ac_lead.contract_id = ac_contr_head_lead
           AND ac_lead.ag_contract_id = ac.contract_leader_id
              ORDER BY ac.date_begin DESC) a --p_pol_header
     WHERE a.m = a.ag_contract_id
       AND ROWNUM = 1;
    RETURN ac_id;
  END;

  ----------------------------------------------------------------------------------
  FUNCTION koef_month
  (
    p_ag_contract_header_id IN NUMBER --��� ������ ���������� ���������
   ,p_data_begin            IN DATE
  ) RETURN NUMBER IS
  
    v_date_contr DATE;
    v_date_koef  NUMBER; -- �����������, �� ������� ����� ������� ��� ���
    v_SGP        NUMBER;
    v_SGP1       NUMBER;
    v_flag_PBOUL NUMBER;
    v_ag_id      NUMBER;
  BEGIN
    v_ag_id := Pkg_Agent_1.get_status_by_date(p_ag_contract_header_id, LAST_DAY(p_data_begin));
  
    SELECT ah.date_begin
          ,ac.leg_pos
      INTO v_date_contr
          ,v_flag_PBOUL
      FROM ven_ag_contract_header ah
          ,ven_ag_contract        ac
     WHERE ac.contract_id = ah.ag_contract_header_id
       AND ac.ag_contract_id = v_ag_id;
  
    IF LAST_DAY(v_date_contr) = LAST_DAY(p_data_begin) -- ���� �������� �������� � ������� ������
    THEN
      --�������� �.�. 03.09.2008 ����������� � ����������� +1
      v_date_koef := TRUNC(((LAST_DAY(v_date_contr) - v_date_contr + 1) /
                           EXTRACT(DAY FROM LAST_DAY(v_date_contr)))
                          ,16);
      /*  v_SGP       := Pkg_Agent_1.get_SGP_agent_new(p_ag_contract_header_id,
      v_date_contr,
      LAST_DAY(v_date_contr));*/
      -- ������� �������� ���1 �� ����������� ������� �������
      SELECT MIN(a.criteria_3)
        INTO v_SGP1
        FROM T_PROD_COEF      a
            ,T_PROD_COEF_TYPE t
            ,T_CONTACT_TYPE   c
       WHERE t.t_prod_coef_type_id = a.t_prod_coef_type_id
         AND t.brief = '���'
         AND a.criteria_2 = '3'
         AND a.criteria_1 = c.ID
         AND c.brief = DECODE(v_flag_PBOUL, 0, '��', 1, '�����')
         AND c.is_legal_entity = 0
         AND c.is_leaf = 1;
    
      IF Pkg_Agent_Rate.sgp > v_SGP1
      THEN
        v_date_koef := 1;
      END IF;
    ELSE
      v_date_koef := 1;
    END IF;
  
    RETURN NVL(v_date_koef, 0);
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20001
                             ,'������ ����������� ������������ ��� p_ag_contract_header_id:' ||
                              p_ag_contract_header_id || ' �� ' ||
                              TO_CHAR(p_data_begin, 'DD.MM.YYYY') || ' C�. ������ Oracle: ' ||
                              SQLERRM(SQLCODE));
  END;
  --
  FUNCTION get_rate_oab
  (
    p_pol_ag_com_id NUMBER
   ,par_date        DATE DEFAULT NULL
  ) RETURN NUMBER IS
    --v_rate         number;
    --v_en           number;
    v_rez           NUMBER;
    v_oab_id        NUMBER;
    v_rez_all       NUMBER;
    v_pac           ven_p_policy_agent_com%ROWTYPE;
    v_type_r_brief  VARCHAR2(100);
    v_sav           NUMBER;
    v_pol_h         NUMBER;
    v_mark          NUMBER := 0;
    v_sales_channel VARCHAR2(100);
  BEGIN
    --�������� �.�. 12/10/2008 �������� ���� ������� ���
    IF par_date IS NOT NULL
    THEN
      pkg_agent_rate.DATE_END := par_date;
    END IF;
  
    SELECT t.t_prod_coef_type_id INTO v_oab_id FROM T_PROD_COEF_TYPE t WHERE t.brief = '���';
  
    SELECT *
      INTO v_pac
      FROM ven_p_policy_agent_com pac
     WHERE pac.p_policy_agent_com_id = p_pol_ag_com_id;
  
    SELECT pa.policy_header_id
      INTO v_pol_h
      FROM P_POLICY_AGENT pa
     WHERE pa.p_policy_agent_id = v_pac.p_policy_agent_id;
  
    SELECT COUNT(*)
      INTO v_mark --pkg_agent_rate.POLICY_AGENT_MARK
      FROM P_POLICY_AGENT pa2
     WHERE pa2.policy_header_id = v_pol_h
       AND pa2.date_start < Pkg_Agent_Rate.DATE_END
       AND pa2.status_id = 2;
    /* and exists
     (select '1'
           from p_policy_agent ppa
          where ppa.policy_header_id = pa2.policy_header_id
            and pa2.ag_contract_header_id <> ppa.ag_contract_header_id);
    */
  
    -- ������ �� ��� ������
    SELECT r.brief
      INTO v_type_r_brief
      FROM ven_ag_type_defin_rate r
     WHERE r.ag_type_defin_rate_id = v_pac.ag_type_defin_rate_id;
  
    IF v_type_r_brief = 'CONSTANT'
    THEN
      v_sav := v_pac.val_com;
    ELSIF v_type_r_brief = 'FUNCTION'
    THEN
      -- ���������� ��������� ������ �� �������
      --���� ���
      IF v_oab_id = v_pac.t_prod_coef_type_id
      THEN
        --�������� �.�. 29/10/2008 ���� ���������� � ����� � ��������� � ������ �����.
        --TODO: ����� ���������� ����� ����������� �� ������ ��� ���������� ������ ������
        SELECT ts.brief
          INTO v_sales_channel
          FROM p_policy_agent_com pac
              ,p_policy_agent     pa
              ,ag_contract_header ach
              ,t_sales_channel    ts
         WHERE pac.p_policy_agent_com_id = p_pol_ag_com_id
           AND pac.p_policy_agent_id = pa.p_policy_agent_id
           AND pa.ag_contract_header_id = ach.ag_contract_header_id
           AND ach.t_sales_channel_id = ts.id;
      
        CASE
          WHEN v_sales_channel = 'BANK' THEN
            v_rez_all := Pkg_Tariff_Calc.calc_fun('Individual_OAV_bank_rates'
                                                 ,v_pac.ent_id
                                                 ,p_pol_ag_com_id);
          
          WHEN v_sales_channel = 'BR' THEN
            NULL;
            v_rez_all := Pkg_Tariff_Calc.calc_fun('Individual_OAV_BR_rates'
                                                 ,v_pac.ent_id
                                                 ,p_pol_ag_com_id);
          
          WHEN v_sales_channel = 'CORPORATE' THEN
            NULL;
          
          ELSE
            --���������� �������� ��������, ���� ��� ��������� ����-������, ����� ������ ������� ��������
            v_rez := Pkg_Tariff_Calc.calc_fun('GP_PROG', v_pac.ent_id, p_pol_ag_com_id);
          
            CASE
              WHEN v_rez = 1 THEN
                v_rez_all := Pkg_Tariff_Calc.calc_fun('GP1', v_pac.ent_id, p_pol_ag_com_id);
              WHEN v_rez = 2 THEN
                v_rez_all := Pkg_Tariff_Calc.calc_fun('GP2', v_pac.ent_id, p_pol_ag_com_id);
              WHEN v_rez = 3 THEN
                v_rez_all := Pkg_Tariff_Calc.calc_fun('GP3', v_pac.ent_id, p_pol_ag_com_id);
              WHEN v_rez = 4 THEN
                v_rez_all := Pkg_Tariff_Calc.calc_fun('GP4', v_pac.ent_id, p_pol_ag_com_id);
              WHEN v_rez = 5 THEN
                v_rez_all := Pkg_Tariff_Calc.calc_fun('GP5', v_pac.ent_id, p_pol_ag_com_id);
              WHEN v_rez = 6
                   AND v_mark = 0 THEN
                v_rez_all := Pkg_Tariff_Calc.calc_fun('GP6', v_pac.ent_id, p_pol_ag_com_id);
              WHEN v_rez = 7
                   AND v_mark = 0 THEN
                v_rez_all := Pkg_Tariff_Calc.calc_fun('GP7', v_pac.ent_id, p_pol_ag_com_id);
              WHEN v_rez = 8
                   AND v_mark = 0 THEN
                v_rez_all := Pkg_Tariff_Calc.calc_fun('GP8', v_pac.ent_id, p_pol_ag_com_id);
              WHEN v_rez = 9
                   AND v_mark = 0 THEN
                v_rez_all := Pkg_Tariff_Calc.calc_fun('GP9', v_pac.ent_id, p_pol_ag_com_id);
              WHEN v_rez = 6
                   AND v_mark > 0 THEN
                v_rez_all := 13.33;
              WHEN v_rez = 7
                   AND v_mark > 0 THEN
                v_rez_all := 15;
              WHEN v_rez = 8
                   AND v_mark > 0 THEN
                v_rez_all := 4.71;
              WHEN v_rez = 9
                   AND v_mark > 0 THEN
                v_rez_all := 5;
              WHEN v_rez = 10 THEN
                v_rez_all := Pkg_Tariff_Calc.calc_fun('GP10', v_pac.ent_id, p_pol_ag_com_id);
              WHEN v_rez = 11 THEN
                v_rez_all := Pkg_Tariff_Calc.calc_fun('GP11', v_pac.ent_id, p_pol_ag_com_id);
              WHEN v_rez = 12 THEN
                v_rez_all := Pkg_Tariff_Calc.calc_fun('GP12', v_pac.ent_id, p_pol_ag_com_id);
              WHEN v_rez = 13 THEN
                v_rez_all := Pkg_Tariff_Calc.calc_fun('GP13', v_pac.ent_id, p_pol_ag_com_id);
              ELSE
                v_rez_all := 0;
            END CASE; --��������� Case ��� ������� ��� ��� ���������� ������ ������
        
        END CASE; --��������� Case ��� ������� ��� ��� �����
      
      ELSE
        -- �������� ��� ������� �� ������� ��������� ���
        -- ������ �� �������� �����������
        IF v_pac.t_prod_coef_type_id IS NOT NULL
        THEN
          v_rez_all := Pkg_Tariff_Calc.calc_fun(v_pac.t_prod_coef_type_id
                                               ,v_pac.ent_id
                                               ,p_pol_ag_com_id);
        ELSE
          NULL;
        END IF;
      
      END IF;
    
      /* --���� ���
      if v_oab_id=v_fun_id
      then
          --���������� �������� ��������, ���� ��� ��������� ����-������, ����� ������ ������� ��������
          v_rez:=pkg_tariff_calc.calc_fun('GP1',v_ent_id,p_pol_ag_com_id);
      else
          v_rez:=pkg_tariff_calc.calc_fun(v_fun_id,v_ent_id,p_pol_ag_com_id);
      end if;  */
    
      /* select e.ent_id
      into v_en
      from entity e
      where e.source='P_POLICY_AGENT_COM';
      v_rate:=pkg_tariff_calc.calc_fun('GP1',v_en,p_policy_agent_com_id);
      
      return v_rate;  */
      v_sav := NVL(v_rez_all, 0);
      --insert into tmp_test_ag values(v_sav, v_rez_all,v_rez,null,'yyy');
    ELSE
      --������ ������ ������ ������ �� �������� �� ������ ��� �� �������� ������
      NULL;
    END IF;
    --��������� ������� �� ��� ������
  
    RETURN v_sav;
  END;

  FUNCTION get_rate_dav
  (
    p_data_begin            IN DATE --���� ������ ��������� �������
   ,p_ag_contract_header_id IN NUMBER --��� ���������� ��������
   ,p_brief_function        IN CHAR --���� �������
   ,p_payment_terms_id      IN NUMBER --��� ������� �������
   ,p_pay_condition         IN NUMBER --������� ������
  ) RETURN NUMBER IS
    v_rez NUMBER := 0;
  BEGIN
  
    RETURN NVL(v_rez, 0);
  
  END;

  ---///��������� ������ � ������� agent_report ����� ����� ��������������
  PROCEDURE av_update_report
  (
    p_vedom_id              IN NUMBER --��� ��������� ������� �������������� ����������
   ,p_ag_contract_header_id IN NUMBER DEFAULT NULL --��� ���������� ��������
   ,p_err_code              OUT NUMBER
  ) IS
  
    CURSOR k_rep IS
    
      SELECT SUM(NVL(com_sum, 0) - NVL(ret_sum, 0)) av
            ,av_brief
            ,rep_id
        FROM (SELECT DECODE(t.brief, '���', arc.comission_sum, dav.comission_sum) com_sum
                    ,DECODE(t.brief, '���', arc.sum_return, 0) ret_sum
                    ,t.brief av_brief
                    ,ar.agent_report_id rep_id
                FROM agent_report      ar
                    ,agent_report_cont arc
                    ,agent_report_dav  dav
                    ,t_ag_av           t
               WHERE ar.ag_vedom_av_id = p_vedom_id -- �� ���������
                 AND ar.ag_contract_h_id = NVL(p_ag_contract_header_id, ar.ag_contract_h_id) -- �� ������
                 AND ar.t_ag_av_id = t.t_ag_av_id
                 AND ar.agent_report_id = arc.agent_report_id(+) -- �� ��� �������
                 AND ar.agent_report_id = dav.agent_report_id(+) -- �� ��� �������
              )
       GROUP BY av_brief
               ,rep_id;
  
    v_rep k_rep%ROWTYPE;
  
  BEGIN
  
    OPEN k_rep;
    -- � ����� ����������� �������� �� �� ������
    LOOP
      FETCH k_rep
        INTO v_rep.av
            ,v_rep.av_brief
            ,v_rep.rep_id;
      EXIT WHEN k_rep%NOTFOUND;
    
      --IF NVL(v_rep.av, 0) <> 0 THEN
      /*        BEGIN
          NULL;
        EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END;
      ELSE*/
      UPDATE ven_agent_report ar
         SET ar.av_sum = v_rep.av
       WHERE ar.ag_vedom_av_id = p_vedom_id
         AND ar.agent_report_id = v_rep.rep_id;
      --END IF;
    
    END LOOP;
    CLOSE k_rep;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20001
                             ,'������ ���������� agent_report. ��. ������ Oracle:' ||
                              SQLERRM(SQLCODE));
    
  END;

  ---///��������� ������ � ������� agent_report ����� ��������
  FUNCTION av_insert_report
  (
    p_vedom_id              IN NUMBER --��� ��������� ������� �������������� ����������
   ,p_ag_contract_header_id IN NUMBER --��� ���������� ��������
   ,p_t_ag_av_id            IN NUMBER
   ,p_part_agent            IN NUMBER DEFAULT 0
   ,p_err_code              OUT NUMBER
  ) RETURN NUMBER IS
    v_report ven_agent_report%ROWTYPE;
  BEGIN
    SELECT sq_agent_report.NEXTVAL INTO v_report.agent_report_id FROM dual;
  
    SELECT t.doc_templ_id INTO v_report.doc_templ_id FROM DOC_TEMPL t WHERE t.brief = 'AGENT_REPORT';
  
    INSERT INTO ven_agent_report
      (agent_report_id
      ,doc_templ_id
      ,num
      ,ag_contract_h_id
      ,ag_vedom_av_id
      ,av_sum
      ,pr_part_agent
      ,report_date
      ,t_ag_av_id)
    VALUES
      (v_report.agent_report_id
      ,v_report.doc_templ_id
      ,TO_CHAR(v_report.agent_report_id)
      ,p_ag_contract_header_id
      ,p_vedom_id
      ,0
      ,p_part_agent
      ,SYSDATE
      ,p_t_ag_av_id);
    Doc.set_doc_status(v_report.agent_report_id, 'NEW', SYSDATE);
    RETURN(v_report.agent_report_id);
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20001
                             ,'������ ������� � ������� agent_report. ��. ������ Oracle:' ||
                              SQLERRM(SQLCODE));
    
  END;

  ---///��������� ������ � ������� agent_report_cont ����� ��������
  PROCEDURE av_insert_report_cont
  (
    p_oav                   IN NUMBER --����� ��������
   ,p_agent_report_id       IN NUMBER -- �� ����
   ,p_is_deduct             IN NUMBER DEFAULT 0 --c ����������/���
   ,policy_agent_com_id     IN NUMBER
   ,p_trans_id              IN NUMBER -- ����� ����������
   ,p_ag_type_rate_value_id IN NUMBER
   ,p_part_agent            IN NUMBER
   ,p_sav                   IN NUMBER
   ,p_policy_id             IN NUMBER
   ,p_day_pay               IN DATE
   ,p_sum_premium           IN NUMBER
   ,p_sum_return            IN NUMBER
   ,p_mlead_id              IN NUMBER
   ,p_err_code              OUT NUMBER
  )
  
   IS
    v_report_cont AGENT_REPORT_CONT%ROWTYPE;
  BEGIN
    SELECT sq_agent_report_cont.NEXTVAL INTO v_report_cont.agent_report_cont_id FROM dual;
  
    INSERT INTO ven_agent_report_cont
      (agent_report_cont_id
      ,agent_report_id
      ,ag_type_rate_value_id
      ,comission_sum
      ,date_pay
      ,is_deduct
      ,part_agent
      ,policy_id
      ,p_policy_agent_com_id
      ,sav
      ,sum_premium
      ,sum_return
      ,trans_id
      ,mlead_id)
    VALUES
      (v_report_cont.agent_report_cont_id
      ,p_agent_report_id
      ,p_ag_type_rate_value_id
      ,p_oav
      ,p_day_pay
      ,p_is_deduct
      ,p_part_agent
      ,p_policy_id
      ,policy_agent_com_id
      ,p_sav
      ,p_sum_premium
      ,p_sum_return
      ,p_trans_id
      ,p_mlead_id);
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20001
                             ,'������ ������� � ������� agent_report_cont.��. ������ Oracle:' ||
                              SQLERRM(SQLCODE));
    
  END;

  ---///��������� ��������� ������������ ����� ������ ������� agent_report_dav_ct
  PROCEDURE av_update_report_dav_ct
  (
    p_agent_report_dav_ct_id NUMBER
   ,p_is_included            IN NUMBER
  ) IS
  BEGIN
  
    UPDATE Ven_Agent_Report_Dav_Ct d
       SET d.is_included = p_is_included
     WHERE d.agent_report_dav_ct_id = p_agent_report_dav_ct_id;
  END;
  ---///��������� ������ � ������� agent_report_dav_st ����� ��������
  PROCEDURE av_insert_report_dav_ct
  (
    p_AGENT_REPORT_DAV_ID   IN NUMBER -- �� ����
   ,p_POLICY_ID             IN NUMBER DEFAULT NULL
   ,p_SUM_PREMIUM           IN NUMBER DEFAULT NULL
   ,p_SGP                   IN NUMBER DEFAULT NULL
   ,p_is_break              IN NUMBER DEFAULT NULL
   ,p_COMISSION_SUM         IN NUMBER DEFAULT NULL
   ,p_recr_ag_ch_id         IN NUMBER DEFAULT NULL
   ,p_child_ag_ch_id        IN NUMBER DEFAULT NULL
   ,p_bonus_all             IN NUMBER DEFAULT NULL
   ,p_bonus_new             IN NUMBER DEFAULT NULL
   ,p_p_policy_agent_com_id IN NUMBER DEFAULT NULL
   ,p_rate_value            IN NUMBER DEFAULT NULL
   ,p_prm_date_pay          IN DATE DEFAULT NULL
   ,p_prm_manag_lead        IN NUMBER DEFAULT NULL
  ) IS
    v_report_dav_ct NUMBER;
    p_err_code      NUMBER := 0;
  BEGIN
    -- ����������� ��� �� ������������������
    SELECT sq_agent_report_dav_ct.NEXTVAL INTO v_report_dav_ct FROM dual;
    -- ������� ���������� ������ � �������
    INSERT INTO ven_agent_report_dav_ct
      (agent_report_dav_ct_id
      ,agent_report_dav_id
      ,policy_id
      ,sum_premium
      ,sgp
      ,comission_sum
      ,is_break
      ,is_included
      ,recr_ag_ch_id
      ,child_ag_ch_id
      ,bonus_all
      ,bonus_new
      ,p_policy_agent_com_id
      ,rate_value
      ,prm_date_pay
      ,prm_manag_lead)
    VALUES
      (v_report_dav_ct
      ,p_AGENT_REPORT_DAV_ID
      ,p_POLICY_ID
      ,p_SUM_PREMIUM
      ,p_SGP
      ,p_COMISSION_SUM
      ,p_is_break
      ,p_is_break
      , --IS_INCLUDED = IS_BREAK (����������� ��� ����� "�����" �� 0 �� 1)
       p_recr_ag_ch_id
      ,p_child_ag_ch_id
      ,p_bonus_all
      ,p_bonus_new
      ,p_p_policy_agent_com_id
      ,p_rate_value
      ,p_prm_date_pay
      ,p_prm_manag_lead);
  
    UPDATE AGENT_REPORT_DAV_CT v
       SET v.prm_manag_lead = p_prm_manag_lead
     WHERE agent_report_dav_ct_id = v_report_dav_ct;
  
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20001
                             ,'������ ������� � ������� agent_report_dav_ct.��. ������ Oracle:' ||
                              SQLERRM(SQLCODE));
    
    --p_err_code:=SQLCODE;
  END;

  ---///��������� ������ � ������� agent_report_dav
  PROCEDURE av_update_report_dav
  (
    p_agent_report_dav_id NUMBER
   ,p_dav_sum             IN NUMBER --����� ��������
   ,p_dav_sgp             IN NUMBER DEFAULT NULL
   ,p_bonus_all           IN NUMBER DEFAULT NULL
   ,p_bonus_new           IN NUMBER DEFAULT NULL
  ) IS
  BEGIN
  
    UPDATE ven_agent_report_dav d
       SET d.comission_sum = p_dav_sum
          ,d.sgp           = NVL(p_dav_sgp, d.sgp)
          ,d.bonus_all     = NVL(p_bonus_all, d.bonus_all)
          ,d.bonus_new     = NVL(p_bonus_new, d.bonus_new)
     WHERE d.agent_report_dav_id = p_agent_report_dav_id;
  
  END;
  ---///��������� ������ � ������� agent_report_dav ����� ��������
  PROCEDURE av_insert_report_dav
  (
    p_agent_report_dav_id NUMBER
   ,p_dav                 IN NUMBER --����� ��������
   ,p_data_begin          IN DATE --���� ������ ��������� �������
   ,p_agent_report_id     IN NUMBER -- �� ����
   ,p_ag_id               IN NUMBER --��� ������ ���������� ��������
   ,p_prod_coef_type_id   IN NUMBER
   ,p_NUM_MONTH           IN NUMBER DEFAULT NULL
   ,p_SGP                 IN NUMBER DEFAULT NULL
   ,p_COUNT_POLICY        IN NUMBER DEFAULT NULL
   ,p_COUNT_AGENT         IN NUMBER DEFAULT NULL
   ,p_SUM_PREMIUM         IN NUMBER DEFAULT NULL
   ,p_KSP                 IN NUMBER DEFAULT NULL
  ) IS
    v_report_dav AGENT_REPORT_DAV%ROWTYPE;
  BEGIN
    -- ����������� ��� �� ������� ������ � ��� �� ������
  
    BEGIN
      SELECT ad.payment_ag_id
            ,ad.payment_terms_id
            ,ad.prod_coef_type_id
        INTO v_report_dav.payment_ag_id
            ,v_report_dav.payment_terms_id
            ,v_report_dav.prod_coef_type_id
        FROM ven_ag_contract c
            ,ven_ag_contract_header ch
            ,(SELECT ac.contract_id FROM AG_CONTRACT ac WHERE ac.ag_contract_id = p_ag_id) ag_h_id
            ,ven_ag_dav ad
       WHERE Pkg_Agent_1.get_status_by_date(ch.ag_contract_header_id, LAST_DAY(p_data_begin)) =
             c.ag_contract_id
            -- ����� ��� ��� �� �������������� �� ��������� ��
         AND ch.ag_contract_header_id = ag_h_id.contract_id
         AND ch.ag_contract_header_id = c.contract_id
         AND c.ag_contract_id = ad.contract_id
         AND ad.prod_coef_type_id = p_prod_coef_type_id;
    
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20001
                               ,'����������� ��� ����� (p_ag_id = ' || p_ag_id ||
                                ' p_prod_coef_type_id=' || p_prod_coef_type_id || ')' || SQLERRM);
    END;
  
    -- ������� ���������� ������ � �������
    INSERT INTO ven_agent_report_dav
      (AGENT_REPORT_DAV_ID
      ,AGENT_REPORT_ID
      ,COMISSION_SUM
      ,NUM_MONTH
      ,SGP
      ,COUNT_POLICY
      ,COUNT_AGENT
      ,SUM_PREMIUM
      ,KSP
      ,PAYMENT_TERMS_ID
      ,PAYMENT_AG_ID
      ,PROD_COEF_TYPE_ID)
    VALUES
      (p_agent_report_dav_id
      ,p_agent_report_id
      ,NVL(p_dav, 0)
      ,p_NUM_MONTH
      ,p_SGP
      ,p_COUNT_POLICY
      ,p_COUNT_AGENT
      ,p_SUM_PREMIUM
      ,p_KSP
      ,v_report_dav.payment_terms_id
      ,v_report_dav.payment_ag_id
      ,p_prod_coef_type_id);
  
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20001
                             ,'������ ������� � ������� agent_report_dav.��. ������ Oracle:' ||
                              SQLERRM(SQLCODE));
  END;

  PROCEDURE Av_Oav_Pol_Ag_Com
  (
    p_policy_agent_com_id IN NUMBER
   ,p_date_pay            IN DATE
   ,p_st                  OUT NUMBER
   , -- ������
    p_key                 OUT NUMBER --��� ������ 0-�������, 1-���������
  ) IS
    v_sav     NUMBER;
    v_r_brief VARCHAR2(50);
    v_part    NUMBER;
    v_c       NUMBER;
  BEGIN
    -- �������� �� ������ ������ � ���� ������
    -- ���� ���, ����� 0% �������
  
    v_c := utils.GET_NULL(pkg_payment.ag_comm_cache, 'AG_COMM_VC_' || p_policy_agent_com_id);
    IF v_c IS NULL
    THEN
      SELECT COUNT(*)
        INTO v_c
        FROM ven_p_policy_agent      pa
            ,ven_p_policy_agent_com  pac
            ,ven_policy_agent_status pas
       WHERE pa.p_policy_agent_id = pac.p_policy_agent_id
         AND pa.status_id = pas.policy_agent_status_id
         AND (pas.brief IN ('CURRENT', 'CANCEL') --����� ���������� ��� ��������� �� ���� ��������� �������
             AND pa.date_end >= p_date_pay AND pa.date_start < p_date_pay)
         AND pac.p_policy_agent_com_id = p_policy_agent_com_id;
      pkg_payment.ag_comm_cache('AG_COMM_VC_' || p_policy_agent_com_id) := v_c;
    END IF;
    /*�������� ������  IF v_c >= 1 THEN */
    IF v_c > 1
    THEN
      Pkg_Agent_Rate.date_pay := p_date_pay;
      v_sav                   := Pkg_Agent_Rate.get_rate_oab(p_policy_agent_com_id);
    
      -- �.�������. �����������
    
      v_r_brief := utils.GET_NULL(pkg_payment.ag_comm_cache, 'AG_COMM_BRIEF_' || p_policy_agent_com_id);
      IF v_r_brief IS NULL
      THEN
        BEGIN
          SELECT rv.brief
                ,pa.part_agent
            INTO v_r_brief
                ,v_part
            FROM ven_p_policy_agent_com c
                ,ven_p_policy_agent     pa
                ,ven_ag_type_rate_value rv
           WHERE c.ag_type_rate_value_id = rv.ag_type_rate_value_id(+)
             AND pa.p_policy_agent_id = c.p_policy_agent_id
             AND c.p_policy_agent_com_id = p_policy_agent_com_id;
        EXCEPTION
          WHEN OTHERS THEN
            v_r_brief := '0';
            v_part    := 100;
        END;
      
        pkg_payment.ag_comm_cache('AG_COMM_BRIEF_' || p_policy_agent_com_id) := v_r_brief;
        pkg_payment.ag_comm_cache('AG_COMM_PART_AGENT_' || p_policy_agent_com_id) := v_part;
      
      ELSE
        v_part := utils.GET_NULL(pkg_payment.ag_comm_cache
                                ,'AG_COMM_PART_AGENT_' || p_policy_agent_com_id);
      END IF;
    
      IF v_r_brief = 'ABSOL'
      THEN
        p_key := 1;
        p_st  := v_sav * v_part / 100;
      ELSIF v_r_brief = 'PERCENT'
      THEN
        p_key := 0;
        p_st  := v_sav * v_part / 100;
      ELSE
        p_key := 0;
        p_st  := v_sav * v_part / 100;
      END IF;
    ELSE
      p_key := 0;
      p_st  := 0;
    END IF;
  
  END;

  ---///��������� ���������� ������ ��������� ���������� �������������� (���) �� ����������� ������
  PROCEDURE av_oav_one
  (
    p_vedom_id       IN NUMBER --��� ��������� ������� �������������� ����������
   ,p_data_begin     IN DATE --���� ������ ��������� �������
   ,policy_agent_id  IN NUMBER -- �� ������ �� �������� ������������
   ,p_method_payment IN NUMBER --����� ������� ��(�� ���������� ������ , �� ������� ������)
   ,p_category_id    IN NUMBER --��������� ������
   ,p_err_code       IN OUT NUMBER --������ ���������� �������
  ) IS
  
    v_err_num      NUMBER := 0;
    v_ag_ch_id     NUMBER;
    v_ag_av_id     NUMBER;
    v_type_r_brief VARCHAR2(100);
    v_pph          NUMBER;
    v_lead_head_id NUMBER;
    CURSOR k_tran(ppolh NUMBER) IS
      SELECT t.trans_id
            , -- ��� ����������
             pa.ag_contract_header_id header_id
            ,pac.p_policy_agent_com_id
            ,pac.ag_type_defin_rate_id
            ,pac.ag_type_rate_value_id
            ,pac.t_prod_coef_type_id
            ,pac.val_com
            ,pa.part_agent -- ���� ������ � ��������
            ,pp.policy_id -- ��� ������ �������� �����������
            ,t.trans_date -- ���� ����������
            ,t.trans_amount -- ����� � ������ ����� �� ������ ������
            ,t.acc_rate -- ����
            ,NVL(pt.number_of_payments, 1) NOP -- ���������� ������ � ����
            ,NVL(pp.premium, 0) GP -- ����� ������
            ,ph.start_date -- ���� ������ �������� �����������
            ,'PERCENT' brief -- ������� ������������ ���� ������
            ,acp1.due_date plan_date -- ���� ��-�� �����-�������
      --, ph.start_date start_date
        FROM ven_ac_payment   acp1
            , -- ����
             AC_PAYMENT_TEMPL apt
            ,DOC_SET_OFF      dso
            ,OPER             o
            ,
             -- ������ ������ �� ������ ��? �� ����� ����� �� ������. ������������� ����� ��������
             DOC_DOC             dd
            ,TRANS               t
            ,TRANS_TEMPL         tt
            ,P_POLICY            pp
            ,P_POLICY_AGENT      pa
            , -- a����� �� �������� �����������
             ven_p_pol_header    ph
            , -- ��������� �������� �����������
             P_POLICY_AGENT_COM  pac
            ,T_PAYMENT_TERMS     pt
            ,T_PROD_LINE_OPTION  plo
            , -- ������ ������ �� ������ (��������� �����������)
             POLICY_AGENT_STATUS pas
            , -- ������� ������� �� �������� �����������
             DOCUMENT            d
            ,doc_templ           dt
       WHERE apt.payment_templ_id = acp1.payment_templ_id
         AND apt.brief = 'PAYMENT'
         AND dd.parent_id = pp.policy_id
         AND dd.child_id = acp1.payment_id
         AND dso.parent_doc_id = acp1.payment_id -- ����
         AND dso.child_doc_id = d.document_id --������ �������� 18.12.2007
         AND d.doc_templ_id = dt.doc_templ_id
         AND dt.brief IN ('��', 'A7', 'PD4')
         AND d.reg_date > TO_DATE('31.07.2007', 'dd.mm.yyyy') --������ �������� 18.12.2007
         AND Doc.get_doc_status_brief(acp1.payment_id, TO_DATE('31.12.9999', 'DD.MM.YYYY')) = 'PAID'
         AND NVL(Doc.get_doc_status_brief(acp1.payment_id, TO_DATE('31.07.2007', 'DD.MM.YYYY')), '1') <>
             'PAID'
            --������ �������� 19.03.2008
         AND Pkg_Agent_Sub.A7_get_money_analyze(dso.child_doc_id) = 1
         AND dso.doc_set_off_id = o.document_id
         AND o.oper_id = t.oper_id
         AND tt.trans_templ_id = t.trans_templ_id
         AND (tt.brief = '�����������������������' OR tt.brief = '�����������������������')
         AND NOT EXISTS
       (SELECT 1
                FROM TRANS tr
               WHERE tr.oper_id = o.oper_id HAVING MAX(tr.trans_date) > LAST_DAY(p_data_begin)) -- ���� ��������� �������
         AND t.a2_ct_uro_id = pp.policy_id
         AND t.a4_ct_uro_id = plo.ID
            --�������� �.�. 14/01/2009 - �����������!!!! 
            --���� ������ ��� �������� �� ���� ��� ����� ����� ����������� �� �������� �� ��� �� �� ��������
         AND t.trans_date >= pa.date_start
         AND ph.policy_header_id = pa.policy_header_id
         AND pp.pol_header_id = ph.policy_header_id
         AND pac.p_policy_agent_id = pa.p_policy_agent_id
         AND pt.ID = pp.payment_term_id
         AND plo.product_line_id = pac.t_product_line_id
         AND pa.status_id = pas.policy_agent_status_id
            --�������� �.�. 08/10/2008 �� ���� ������� � ������ ��������� � ����� ��������
            --�� �������� �������� ������ NEW ������ ��� � �������� � ���������������� �������� ����� ������
            
            --�������� �.�. 14/01/2009 �.�. ���� ������ ����������� � ������� � ������ ��������, �� �������� �� ������ 
            --������ �����, ������� ������ �� ������ �������� ������ �� ������ �������...
            -- ����� �������� ��� ������� �������� ������� ���� ��� �� ��������� ������.
            /*  AND (doc.get_doc_status_brief(pp.policy_id, last_day(p_data_begin)) IN ('PRINTED', 'CURRENT', 'ACTIVE','STOPED') 
            OR (doc.get_doc_status_brief(pp.policy_id, last_day(p_data_begin)) = 'NEW' AND pp.version_num<>1))*/
         AND (doc.get_doc_status_brief(ph.policy_id, SYSDATE) IN
             ('PRINTED', 'CURRENT', 'ACTIVE', 'STOPED') OR
             (doc.get_doc_status_brief(ph.policy_id, SYSDATE) = 'NEW' AND
             (SELECT version_num FROM p_policy pp1 WHERE pp1.policy_id = ph.policy_id) <> 1))
         AND EXISTS
       (SELECT 1
                FROM p_policy pp1
               WHERE pp1.pol_header_id = ph.policy_header_id
                 AND doc.get_doc_status_brief(pp1.policy_id) IN
                     ('CURRENT', 'PRINTED', 'ACTIVE', 'STOPED'))
            --������ �.�. 09,12,2009 �� ������ 54234
            --�� ��������� ����������� � ������� "����������", "���������� � �����������" �� ������ ��������� ��
         AND (((SELECT ts.brief
                  FROM ven_t_sales_channel    ts
                      ,ven_ag_contract_header ch
                 WHERE ch.ag_contract_header_id = pa.ag_contract_header_id
                   AND ts.id = ch.t_sales_channel_id) IN ('BANK', 'BR', 'CORPORATE') AND NOT EXISTS
              (SELECT 1
                  FROM p_policy p2
                 WHERE p2.pol_header_id = ph.policy_header_id
                   AND p2.policy_id = (SELECT ph.last_ver_id
                                         FROM ins.p_pol_header ph
                                        WHERE ph.policy_header_id = p2.pol_header_id)
                      /*AND p2.version_num = (SELECT MAX(p3.version_num)
                       FROM ins.p_policy p3
                           ,ins.document  d
                           ,ins.doc_status_ref rf
                      WHERE p3.pol_header_id = p2.pol_header_id
                        AND p3.policy_id = d.document_id
                        AND d.doc_status_ref_id = rf.doc_status_ref_id
                        AND rf.brief != 'CANCEL')*/
                   AND doc.get_doc_status_brief(p2.policy_id) IN ('READY_TO_CANCEL', 'BREAK'))) OR
             (SELECT ts.brief
                 FROM ven_t_sales_channel    ts
                     ,ven_ag_contract_header ch
                WHERE ch.ag_contract_header_id = pa.ag_contract_header_id
                  AND ts.id = ch.t_sales_channel_id) NOT IN ('BANK', 'BR', 'CORPORATE'))
            /*        --������ �������� 14.12.07
                     AND EXISTS
            \*        (SELECT 1                            
                            FROM P_POLICY pp1, 
                                 DOC_STATUS ds, 
                                 DOC_STATUS_REF dsr
                           WHERE dsr.doc_status_ref_id = ds.doc_status_ref_id
                             AND pp1.policy_id = ds.document_id
                             AND TRUNC(ds.start_date) <= SYSDATE
                             AND pp1.pol_header_id = ppolh
                             AND dsr.brief IN ('PRINTED', 'CURRENT', 'ACTIVE'))   *\
                   (SELECT '1'
                            FROM (SELECT MAX(pp1.policy_id) OVER(PARTITION BY pp1.pol_header_id) m,
                                         pp1.policy_id
                                    FROM P_POLICY pp1, DOC_STATUS ds, DOC_STATUS_REF dsr
                                   WHERE dsr.doc_status_ref_id = ds.doc_status_ref_id
                                     AND pp1.policy_id = ds.document_id
                                     AND TRUNC(ds.start_date) <= SYSDATE
                                         --TRUNC(LAST_DAY(p_data_begin)) --date
                                     AND pp1.pol_header_id = ppolh
                                     AND dsr.brief IN ('PRINTED', 'CURRENT', 'ACTIVE')
                                   ORDER BY ds.start_date DESC) a --p_pol_header
                           WHERE a.m = a.policy_id
                             AND ROWNUM = 1)*/
         AND plo.description <> '���������������� ��������'
         AND pa.p_policy_agent_id = policy_agent_id -- ������� �� ����������� ������ ������� �� ���������
            -- ��� � ���������� �������� ���� ��������
         AND pkg_agent_sub.double_trans_analyze(pa.ag_contract_header_id, pa.part_agent, t.trans_id) = 1
            
         AND NOT EXISTS (SELECT arc.agent_report_cont_id
                FROM AGENT_REPORT_CONT arc
               WHERE arc.p_policy_agent_com_id = pac.p_policy_agent_com_id
                 AND arc.trans_id = t.trans_id);
  
    v_tran       k_tran%ROWTYPE;
    v_OAV        NUMBER := 0;
    v_SAV        NUMBER := 0;
    v_report_id  NUMBER;
    v_part_agent NUMBER;
    v_r_brief    VARCHAR2(50);
  BEGIN
    SELECT pa3.ag_contract_header_id
      INTO v_ag_ch_id
      FROM ven_p_policy_agent pa3
     WHERE pa3.p_policy_agent_id = policy_agent_id;
  
    /*    SELECT t.t_ag_av_id
     INTO v_ag_av_id
     FROM ven_t_ag_av t
    WHERE t.brief = '���';*/
    --�������� �.�. 30/10/2008 � ����� � ��������� � ������ �����
    SELECT t_ag_av_id INTO v_ag_av_id FROM ag_vedom_av av WHERE av.ag_vedom_av_id = p_vedom_id;
  
    Pkg_Agent_Rate.DATE_END := LAST_DAY(p_data_begin);
  
    BEGIN
      SELECT ar.agent_report_id
        INTO v_report_id
        FROM ven_agent_report ar
       WHERE v_ag_ch_id = ar.ag_contract_h_id
         AND ar.ag_vedom_av_id = p_vedom_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        v_report_id := 0;
    END;
  
    -- ��� ���������� ������ � agent_report ����������� ����� ������
    IF v_report_id = 0
    THEN
      v_report_id := av_insert_report(p_vedom_id, v_ag_ch_id, v_ag_av_id, v_part_agent, p_err_code);
    END IF;
    --������ �������� 14.12.07
    SELECT ppa.policy_header_id
      INTO v_pph
      FROM P_POLICY_AGENT ppa
     WHERE ppa.p_policy_agent_id = policy_agent_id;
  
    OPEN k_tran(v_pph);
    LOOP
      FETCH k_tran
        INTO v_tran.trans_id
            ,v_tran.header_id
            ,v_tran.p_policy_agent_com_id
            ,v_tran.ag_type_defin_rate_id
            ,v_tran.ag_type_rate_value_id
            ,v_tran.t_prod_coef_type_id
            ,v_tran.val_com
            ,v_tran.part_agent
            ,v_tran.policy_id
            ,v_tran.trans_date
            ,v_tran.trans_amount
            ,v_tran.acc_rate
            ,v_tran.nop
            ,v_tran.gp
            ,v_tran.start_date
            ,v_tran.brief
            ,v_tran.plan_date;
      EXIT WHEN k_tran%NOTFOUND;
      -- ��������� �������� ����������
      v_OAV := 0;
      v_SAV := 0;
      --dbms_output.put_line(v_tran.trans_id||' '||v_tran.header_id||' '||v_tran.p_policy_agent_com_id||' '||v_tran.ag_type_defin_rate_id||' '||v_tran.ag_type_rate_value_id||' '||v_tran.t_prod_coef_type_id);
      Pkg_Agent_Rate.date_pay  := v_tran.trans_date;
      Pkg_Agent_Rate.DATE_PLAN := v_tran.plan_date;
      v_sav                    := Pkg_Agent_Rate.get_rate_oab(v_tran.p_policy_agent_com_id);
      BEGIN
        SELECT rv.brief
          INTO v_r_brief
          FROM ven_ag_type_rate_value rv
         WHERE rv.ag_type_rate_value_id = v_tran.ag_type_rate_value_id;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          v_r_brief := '0';
      END;
      IF v_r_brief = 'ABSOL'
      THEN
        v_oav := v_sav * v_tran.part_agent / 100;
      ELSIF v_r_brief = 'PERCENT'
      THEN
        v_oav := (v_sav / 100) * (v_tran.part_agent / 100) * v_tran.trans_amount;
      ELSE
        v_oav := (v_sav / 100) * (v_tran.part_agent / 100) * v_tran.trans_amount;
      END IF;
      -- ����� ��������� ������� � ������� agent_report_cont
      v_lead_head_id := Pkg_Agent_Sub.Get_Leader_Id_By_Date(p_data_begin
                                                           ,v_tran.header_id
                                                           ,v_tran.trans_date);
      av_insert_report_cont(ROUND(v_oav, 2) --����� ��������
                           ,v_report_id -- �� ����
                           ,0 -- c ����������/���
                           ,v_tran.p_policy_agent_com_id
                           ,v_tran.trans_id -- �����
                           ,NULL --��� ���� ag_type_rate_value_id
                           ,v_tran.part_agent
                           ,v_sav --������ %
                           ,v_tran.policy_id
                           ,v_tran.trans_date
                           ,v_tran.trans_amount
                           ,0
                           ,p_err_code
                           ,v_lead_head_id);
      --        dbms_output.put_line(v_lead_head_id);
    END LOOP;
    CLOSE k_tran;
  END;
  ------------------------------------------------------------------------------
  ---///��������� ���������� ������ ��������������� �������������� ��� ���������  �� ������ �������

  PROCEDURE av_pr_MN_GR
  (
    p_vedom_id              IN NUMBER --��� ��������� ������� �������������� ����������
   ,p_report_id             IN NUMBER --��� ����
   ,p_data_begin            IN DATE --���� ������ ��������� �������
   ,p_ag_contract_header_id IN NUMBER --��� ���������� ��������
   ,p_prod_coef_type_id     IN NUMBER --��� �������
   ,p_type_av               IN NUMBER --��� ���� ���������� �������������� (T_AG_AV_ID)
   ,p_err_code              IN OUT NUMBER --������ ���������� �������
  ) IS
    CURSOR k_dav_mn IS
      SELECT ah.ag_contract_header_id
            ,ah.date_begin ag_date_begin
            ,ac.ag_contract_id
            ,DECODE(ac.leg_pos, 0, 0.5, 1, 1.5, 0) koef_pos
            , -- ����������� �����������: ���.����/������� ���������������
             ph.policy_id
            ,ph.policy_header_id
            ,Pkg_Agent_1.get_agent_start_contr(ph.policy_header_id) pol_start_date
            ,ppc.ent_id
            ,ppc.p_policy_agent_com_id
            ,arc.trans_id
            ,arc.sum_premium
            ,ac.leg_pos
            , -- ��/�����
             arc.date_pay
        FROM ven_ag_contract_header ah
        JOIN ven_ag_contract ac
          ON (ah.ag_contract_header_id = ac.contract_id) -- ���������� ������ �������� � �������
        JOIN ven_agent_report ar
          ON (ar.ag_contract_h_id = ah.ag_contract_header_id) -- ���������� ��� ��� ������
        JOIN ven_ag_vedom_av av
          ON (av.ag_vedom_av_id = ar.ag_vedom_av_id AND av.date_begin = p_data_begin) -- ��� �� ��������� �������
        JOIN ven_agent_report_cont arc
          ON (arc.agent_report_id = ar.agent_report_id)
        JOIN ven_p_policy_agent_com ppc
          ON (arc.p_policy_agent_com_id = ppc.p_policy_agent_com_id)
        JOIN ven_p_policy pp
          ON (arc.policy_id = pp.policy_id)
        JOIN ven_p_pol_header ph
          ON (ph.policy_header_id = pp.pol_header_id)
       WHERE Pkg_Agent_Rate.get_policy_status_brief(pp.pol_header_id, LAST_DAY(p_data_begin)) IN
             ('ACTIVE', 'CURRENT', 'PRINTED')
         AND arc.mlead_id = p_ag_contract_header_id
         AND ac.ag_contract_id =
             Pkg_Agent_Sub.get_ac_contrat_id_by_date(ah.ag_contract_header_id, arc.date_pay)
      
       ORDER BY ah.ag_contract_header_id
               ,ph.policy_id
               ,ppc.p_policy_agent_com_id;
  
    CURSOR cur_count_ag
    (
      cv_ag_contract_header_id NUMBER
     ,cv_data_begin            DATE
    ) IS
      SELECT COUNT(DISTINCT ah.ag_contract_header_id) AS count_ag
      --      INTO v_cur_ag
        FROM ven_ag_contract        ac
            ,ven_ag_contract_header ah
            ,ven_p_policy_agent     pa
            ,ven_p_pol_header       ph
       WHERE ah.last_ver_id = ac.ag_contract_id
         AND pa.ag_contract_header_id = ah.ag_contract_header_id
         AND pa.policy_header_id = ph.policy_header_id
         AND ph.start_date BETWEEN cv_data_begin AND LAST_DAY(cv_data_begin)
         AND ac.contract_leader_id IN
             (SELECT agl.ag_contract_id
                FROM AG_CONTRACT agl -- ����� ��������� � ������ ���������
               WHERE agl.contract_id = cv_ag_contract_header_id);
  
    CURSOR cur_bonus_new
    (
      cv_ag_contract_header_id NUMBER
     ,cv_data_begin            DATE
    ) IS
      SELECT COUNT(DISTINCT ah.ag_contract_header_id) AS count_ag
      --      INTO v_bonus_new
        FROM ven_ag_contract        ac
            ,ven_ag_contract_header ah
            ,ven_p_policy_agent     pa
            ,ven_p_pol_header       ph
       WHERE ah.last_ver_id = ac.ag_contract_id
         AND pa.ag_contract_header_id = ah.ag_contract_header_id
         AND pa.policy_header_id = ph.policy_header_id
         AND ph.start_date BETWEEN p_data_begin AND LAST_DAY(p_data_begin)
         AND ah.date_begin BETWEEN p_data_begin AND LAST_DAY(p_data_begin)
         AND ac.contract_leader_id IN
             (SELECT agl.ag_contract_id
                FROM AG_CONTRACT agl -- ����� ��������� � ������ ���������
               WHERE agl.contract_id = p_ag_contract_header_id);
  
    CURSOR cur_ag_min
    (
      cv_ag_contract_header_id NUMBER
     ,cv_pol_start_date        DATE
    ) IS
      SELECT MIN(h.ag_stat_agent_id) AS ret_stat
        FROM ven_ag_stat_hist h
       WHERE h.ag_contract_header_id = cv_ag_contract_header_id
         AND h.num = (SELECT MIN(h1.num)
                        FROM ven_ag_stat_hist      h1
                            ,ven_ag_category_agent s
                       WHERE h1.ag_contract_header_id = h.ag_contract_header_id
                         AND h1.ag_category_agent_id = s.ag_category_agent_id
                         AND s.brief = 'MN'
                         AND h1.stat_date > cv_pol_start_date);
  
    v_dav_mn              k_dav_mn%ROWTYPE;
    v_agent_report_dav_id NUMBER;
    v_men_contract        NUMBER;
    v_proc_one            NUMBER := 0;
    dav_sum               NUMBER := 0;
    v_bonus_all           NUMBER := 0;
    v_bonus_new           NUMBER := 0;
    v_bonus_new_GP_PROG   NUMBER := 0;
    v_date_begin          DATE;
    v_p_pol_id            NUMBER := 0; -- ��������� �������� �����������
    v_cur_ag              NUMBER;
  
  BEGIN
    Pkg_Agent_Rate.DATE_END := LAST_DAY(p_data_begin);
  
    SELECT MIN(tm.date_b)
      INTO v_date_begin -- ���� ������� ��������� � ��������
      FROM (SELECT t.date_begin  date_b
                  ,t.category_id ag_c
              FROM AG_CONTRACT t
             WHERE t.contract_id = p_ag_contract_header_id
               AND t.date_begin <= LAST_DAY(p_data_begin)) tm
     WHERE tm.ag_c = (SELECT a.ag_category_agent_id FROM AG_CATEGORY_AGENT a WHERE a.brief = 'MN')
       AND NOT EXISTS
     (SELECT '1'
              FROM (SELECT q.date_begin  date_b
                          ,q.category_id ag_c
                      FROM AG_CONTRACT q
                     WHERE q.contract_id = p_ag_contract_header_id
                       AND q.date_begin <= LAST_DAY(p_data_begin)) tt
             WHERE tt.ag_c =
                   (SELECT a.ag_category_agent_id FROM AG_CATEGORY_AGENT a WHERE a.brief = 'AG')
               AND tt.date_b > tm.date_b);
  
    SELECT ah.last_ver_id
      INTO v_men_contract -- ������ ���������� �������� ��� ���������
      FROM ven_ag_contract_header ah
     WHERE ah.ag_contract_header_id = p_ag_contract_header_id;
  
    -- ��������� ������ � agent_report_dav
    SELECT sq_agent_report_dav.NEXTVAL INTO v_agent_report_dav_id FROM dual;
    av_insert_report_dav(v_agent_report_dav_id
                        ,0
                        ,p_data_begin
                        ,p_report_id
                        ,v_men_contract
                        ,p_prod_coef_type_id);
    BEGIN
      SELECT d1.bonus_all
            ,d1.bonus_new
        INTO v_bonus_all
            ,v_bonus_new
        FROM ven_agent_report_dav d1
            ,ven_agent_report     r
            ,ven_ag_vedom_av      v
       WHERE d1.agent_report_id = r.agent_report_id
         AND v.ag_vedom_av_id = r.ag_vedom_av_id
         AND r.ag_contract_h_id = p_ag_contract_header_id
         AND d1.prod_coef_type_id = p_prod_coef_type_id
         AND v.date_begin = ADD_MONTHS(p_data_begin, -1);
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;
    -- ���������� ������ ����� ������
    UPDATE ven_agent_report_dav r
       SET r.bonus_all = NVL(v_bonus_all, 0)
          ,r.bonus_new = NVL(v_bonus_new, 0)
     WHERE r.agent_report_dav_id = v_agent_report_dav_id;
    -- ������ ��������: �� ������ �������� ����������� �������� ��������� ����� � ������� �������
    FOR v_dav_mn IN k_dav_mn
    LOOP
      IF v_p_pol_id <> v_dav_mn.policy_id /* ��� ������� ������ �������� �����������   ������ �������� ������� 13.11.07 */
      THEN
        -- ����������� ������� ��������� �� ���� ���������� �������� �����������
        --        pDebug.put(2);
        Pkg_Agent_Rate.ST_MN := Pkg_Agent_1.get_agent_cat_st_by_date(p_ag_contract_header_id
                                                                    ,v_dav_mn.pol_start_date);
        IF Pkg_Agent_Rate.ST_MN NOT IN (126, 127, 128)
        THEN
          OPEN cur_ag_min(p_ag_contract_header_id, V_DAV_MN.POL_START_DATE);
          FETCH cur_ag_min
            INTO Pkg_Agent_Rate.ST_MN;
          IF (cur_ag_min%NOTFOUND)
          THEN
            CLOSE cur_ag_min;
            RAISE_APPLICATION_ERROR(-20001
                                   ,'������ ����������� ������� ���������.(p_ag_contract_header_id=' ||
                                    p_ag_contract_header_id || '. �� �������.');
          END IF;
          CLOSE cur_ag_min;
        END IF;
        v_p_pol_id := v_dav_mn.policy_id;
      END IF;
      -- ������ �������� �� ������, ��������, �����
      BEGIN
        v_proc_one := NVL(Pkg_Tariff_Calc.calc_fun('PREM_MENEDG'
                                                  ,v_dav_mn.ent_id
                                                  ,v_dav_mn.p_policy_agent_com_id)
                         ,0);
      EXCEPTION
        WHEN OTHERS THEN
          RAISE_APPLICATION_ERROR(-20001
                                 ,'������ ������� ��������.(p_ag_contract_header_id=' ||
                                  p_ag_contract_header_id || '). ��. ������ Oracle:' ||
                                  SQLERRM(SQLCODE));
        
      END;
    
      IF NVL(v_bonus_all, 0) > 0
         OR NVL(v_bonus_new, 0) > 0
      THEN
        IF v_dav_mn.leg_pos = 0
        THEN
          v_bonus_new_GP_PROG := NVL(v_bonus_new, 0) * 0.5;
        ELSIF v_dav_mn.leg_pos = 1
        THEN
          v_bonus_new_GP_PROG := NVL(v_bonus_new, 0) * 1.5;
        END IF;
      
        BEGIN
          IF CEIL(MONTHS_BETWEEN(LAST_DAY(p_data_begin), v_dav_mn.pol_start_date)) <= 12 --1-� ��� ��������
          
          THEN
            -- ��� ��������� �� ������ ��������� ����������� ������������ ��������� ������� �������
            -- v_bonus_new ����� = 0,5% - ��  ��� 1,5% - �����
            -- ������������� ������! ���� � �� �����, ����� ���������� ��������
            dav_sum := v_dav_mn.sum_premium * (NVL(v_proc_one / 100, 0) + NVL(v_bonus_all / 100, 0) +
                       NVL(v_bonus_new_GP_PROG / 100, 0));
            av_insert_report_dav_ct(v_agent_report_dav_id
                                   , -- �� ����
                                    v_dav_mn.policy_id
                                   ,v_dav_mn.sum_premium
                                   ,NULL
                                   ,NULL
                                   ,dav_sum
                                   ,NULL
                                   ,v_dav_mn.ag_contract_header_id
                                   ,v_bonus_all
                                   ,v_bonus_new_GP_PROG
                                   ,v_dav_mn.p_policy_agent_com_id
                                   ,v_proc_one
                                   ,v_dav_mn.date_pay
                                   ,Pkg_Agent_Sub.GetIdRecruterByDate(LAST_DAY(p_data_begin)
                                                                     ,p_ag_contract_header_id));
          ELSE
            av_insert_report_dav_ct(v_agent_report_dav_id -- �� ����
                                   ,v_dav_mn.policy_id
                                   ,v_dav_mn.sum_premium
                                   ,NULL
                                   ,NULL
                                   ,v_dav_mn.sum_premium / 100 * v_proc_one
                                   ,NULL
                                   ,v_dav_mn.ag_contract_header_id
                                   ,v_bonus_all
                                   ,v_bonus_new_GP_PROG
                                   ,v_dav_mn.p_policy_agent_com_id
                                   ,v_proc_one
                                   ,v_dav_mn.date_pay
                                   ,Pkg_Agent_Sub.GetIdRecruterByDate(LAST_DAY(p_data_begin)
                                                                     ,p_ag_contract_header_id));
          END IF;
        EXCEPTION
          WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20001
                                   ,'������ ���������� �������� ������.(p_ag_contract_header_id=' ||
                                    p_ag_contract_header_id || '). ��. ������ Oracle:' ||
                                    SQLERRM(SQLCODE));
          
        END;
      ELSE
        dav_sum := NVL(v_dav_mn.sum_premium, 0) * NVL(v_proc_one / 100, 0);
        av_insert_report_dav_ct(v_agent_report_dav_id -- �� ����
                               ,v_dav_mn.policy_id
                               ,v_dav_mn.sum_premium
                               ,NULL
                               ,NULL
                               ,dav_sum
                               ,NULL
                               ,v_dav_mn.ag_contract_header_id
                               ,NULL
                               ,NULL
                               ,v_dav_mn.p_policy_agent_com_id
                               ,v_proc_one
                               ,v_dav_mn.date_pay
                               ,Pkg_Agent_Sub.GetIdRecruterByDate(LAST_DAY(p_data_begin)
                                                                 ,p_ag_contract_header_id));
        Pdebug.put(Pkg_Agent_Sub.GetIdRecruterByDate(v_dav_mn.date_pay, p_ag_contract_header_id));
      END IF;
    END LOOP;
    --��������� ����� �����-������ �� ����.������
    --������� ������ �������
  
    OPEN cur_bonus_new(p_ag_contract_header_id, p_data_begin);
    FETCH cur_bonus_new
      INTO v_bonus_new;
  
    IF (cur_bonus_new%NOTFOUND)
    THEN
      v_bonus_new := 0;
    END IF;
  
    OPEN cur_count_ag(p_ag_contract_header_id, p_data_begin);
    FETCH cur_count_ag
      INTO v_cur_ag;
  
    IF (cur_count_ag%NOTFOUND)
    THEN
      v_cur_ag := 0;
    END IF;
  
    CLOSE cur_bonus_new;
    CLOSE cur_count_ag;
  
    -- ������ ������ �� ������� �������
    -- ������ ��������� 01.10.2007
  
    IF CEIL(MONTHS_BETWEEN(LAST_DAY(p_data_begin), v_date_begin)) <= 6
       AND v_cur_ag >= 5
    THEN
      v_bonus_all := 2;
    ELSIF CEIL(MONTHS_BETWEEN(LAST_DAY(p_data_begin), v_date_begin)) > 6
          AND v_cur_ag >= 7
    THEN
      v_bonus_all := 2;
    ELSE
      v_bonus_all := 0;
    END IF;
    -- ������� ����������� �������������� ������ ��� ������� ��������!
    -- ���� ����� ���������� ������!
    UPDATE AGENT_REPORT_DAV d
       SET d.bonus_all     = v_bonus_all
          ,d.bonus_new     = v_bonus_new
          ,d.comission_sum =
           (SELECT NVL(SUM(ct.comission_sum), 0)
              FROM ven_agent_report_dav_ct ct
             WHERE ct.agent_report_dav_id = v_agent_report_dav_id)
     WHERE d.agent_report_dav_id = v_agent_report_dav_id;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20001
                             ,'������ ������� PREM_MENEDG.(p_ag_contract_header_id=' ||
                              p_ag_contract_header_id || '). ��. ������ Oracle:' || SQLERRM(SQLCODE));
    
  END;

  PROCEDURE av_dav_MN_PREM_PLAN_MENG
  (
    p_vedom_id              IN NUMBER --��� ��������� ������� �������������� ����������
   ,p_report_id             IN NUMBER --��� ����
   ,p_data_begin            IN DATE --���� ������ ��������� �������
   ,p_ag_contract_header_id IN NUMBER --��� ������� ��������
   ,p_prod_coef_type_id     IN NUMBER --��� �������
   ,p_err_code              IN OUT NUMBER --������ ���������� �������
  ) IS
    v_SGP                 NUMBER;
    v_ent_id              NUMBER;
    v_r                   NUMBER;
    v_agent_report_dav_id NUMBER;
  BEGIN
    SELECT ent_id
      INTO v_ent_id
      FROM ven_ag_contract_header
     WHERE ag_contract_header_id = p_ag_contract_header_id;
    -- ��������� ���
    Pkg_Agent_1.attest_manag_SGP(p_ag_contract_header_id
                                ,TO_DATE('01.01.' || (TO_CHAR(p_data_begin, 'YYYY') - 1)
                                        ,'DD.MM.YYYY')
                                ,TO_DATE('31.12.' || (TO_CHAR(p_data_begin, 'YYYY') - 1)
                                        ,'DD.MM.YYYY')
                                ,v_SGP);
    --������� �������� ���������� ����������� ����� � �� ��
    DELETE FROM AG_STAT_DET_TMP t
     WHERE EXISTS (SELECT ph.policy_header_id
              FROM P_POLICY     pp
                  ,T_PRODUCT    p
                  ,P_POL_HEADER ph
             WHERE ph.product_id = p.product_id
               AND t.policy_id = pp.policy_id
               AND pp.pol_header_id = ph.policy_header_id
                  -- ��������� ��������� ��������
               AND NVL(p.is_group, 100) <> 1
            
            -- and ��� �������� �������: ��������� ����������� ����� � �� ��
            );
    SELECT SUM(t.k_sgp) INTO Pkg_Agent_Rate.SGP FROM AG_STAT_DET_TMP t;
    -- ��������� ���
    Pkg_Agent_1.KSP_MN(p_ag_contract_header_id
                      ,TO_DATE('01.01.' || (TO_CHAR(p_data_begin, 'YYYY') - 1), 'DD.MM.YYYY')
                      ,TO_DATE('31.12.' || (TO_CHAR(p_data_begin, 'YYYY') - 1), 'DD.MM.YYYY')
                      ,Pkg_Agent_Rate.KSP);
    -- �������� �������� �������
    v_r := Pkg_Tariff_Calc.calc_fun(p_prod_coef_type_id, v_ent_id, p_ag_contract_header_id);
    -- �������� � ����������� ������, ���� ����
    IF NVL(v_r, 0) <> 0
    THEN
      SELECT sq_agent_report_dav.NEXTVAL INTO v_agent_report_dav_id FROM dual;
      av_insert_report_dav(v_agent_report_dav_id
                          ,v_r
                          ,p_data_begin
                          ,p_report_id
                          ,p_ag_contract_header_id
                          ,p_prod_coef_type_id
                          ,NULL
                          ,Pkg_Agent_Rate.SGP
                          ,NULL
                          ,NULL
                          ,NULL
                          ,Pkg_Agent_Rate.KSP);
      --�����������
      INSERT INTO ven_agent_report_dav_ct
        (agent_report_dav_id, policy_id, sgp)
        (SELECT t2.ag_contract_header_id
               ,Pkg_Policy.get_active_policy(pp.pol_header_id)
               ,t2.k_sgp
           FROM AG_STAT_DET_TMP t2
               ,P_POLICY        pp
          WHERE pp.policy_id = t2.policy_id);
    END IF;
  
  END;

  --������ ������ ��������� �� ������� �������, ���������� ���������
  PROCEDURE av_pr_DR_GR
  (
    p_vedom_id              IN NUMBER --��� ��������� ������� �������������� ����������
   ,p_report_id             IN NUMBER --��� ����
   ,p_data_begin            IN DATE --���� ������ ��������� �������
   ,p_ag_contract_header_id IN NUMBER --��� ���������� �������� ���������
   ,p_prod_coef_type_id     IN NUMBER --��� �������
   ,p_err_code              IN OUT NUMBER --������ ���������� �������
  ) IS
    --������ ��.����
    CURSOR k_dav_dr IS
      SELECT ah.ag_contract_header_id
            ,ah.date_begin ag_date_begin
            ,ac.ag_contract_id
            ,ph.policy_id
            ,Pkg_Agent_1.get_agent_start_contr(ph.policy_header_id) pol_start_date
            ,ppc.ent_id
            ,ah.ent_id ah_ent_id
            ,ppc.p_policy_agent_com_id
            ,arc.sum_premium
            ,ac.leg_pos -- ��/�����
            ,ah.agency_id
            ,ss.brief sale_br
        FROM ven_ag_contract_header ah
        JOIN ven_ag_contract ac
          ON (ah.last_ver_id = ac.ag_contract_id) -- ���������� ������ �������� � �������
        JOIN ven_agent_report ar
          ON (ar.ag_contract_h_id = ah.ag_contract_header_id) -- ���������� ��� ��� ������
        JOIN ven_ag_vedom_av av
          ON (av.ag_vedom_av_id = ar.ag_vedom_av_id AND av.date_begin = p_data_begin) -- ��� �� ��������� �������
        JOIN ven_agent_report_cont arc
          ON (arc.agent_report_id = ar.agent_report_id)
        JOIN ven_p_policy_agent_com ppc
          ON (arc.p_policy_agent_com_id = ppc.p_policy_agent_com_id)
        JOIN ven_p_policy pp
          ON (arc.policy_id = pp.policy_id)
        JOIN ven_p_pol_header ph
          ON (ph.policy_header_id = pp.pol_header_id)
        LEFT JOIN ven_t_sales_channel ss
          ON (ss.ID = ah.t_sales_channel_id)
       WHERE ah.agency_id = (SELECT hh.agency_id
                               FROM ven_ag_contract_header hh
                              WHERE hh.ag_contract_header_id = p_ag_contract_header_id)
         AND Pkg_Agent_Rate.get_policy_status_brief(ph.policy_header_id, LAST_DAY(p_data_begin)) IN
             ('ACTIVE', 'CURRENT', 'PRINTED')
            
         AND 1 NOT IN (SELECT 1
                         FROM dual
                        WHERE EXISTS (SELECT aaa.ag_category_agent_id
                                 FROM AG_CATEGORY_AGENT aaa
                                WHERE aaa.ag_category_agent_id = ac.category_id
                                  AND aaa.brief = 'AG'
                                  AND ac.category_id = aaa.ag_category_agent_id)
                          AND EXISTS (SELECT agl.ag_contract_id
                                 FROM AG_CONTRACT agl -- ����� �� ��������� � ������ ������
                                WHERE agl.contract_id = p_ag_contract_header_id
                                  AND ac.contract_leader_id = agl.ag_contract_id))
       ORDER BY ah.ag_contract_header_id
               ,ph.policy_id
               ,ppc.p_policy_agent_com_id;
  
    v_dav_dr              k_dav_dr%ROWTYPE;
    v_agent_report_dav_id NUMBER;
    v_proc_one            NUMBER := 0;
    dav_sum               NUMBER := 0;
    v_bonus_all           NUMBER := 0;
    v_bonus_new           NUMBER := 0;
    v_new_bonus_all       NUMBER := 0;
    v_new_bonus_new       NUMBER := 0;
    v_date_begin          DATE;
    v_cur_ag              NUMBER;
    v_c_agent             NUMBER;
    v_ag_ent_id           NUMBER;
    v_dr_contract         NUMBER;
    v_rr                  NUMBER := 0;
    v_c                   NUMBER := 0;
    v_ss                  NUMBER;
  BEGIN
  
    Pkg_Agent_Rate.DATE_END := LAST_DAY(p_data_begin);
    SELECT ah.last_ver_id
      INTO v_dr_contract -- ������ ���������� �������� ��� ���������
      FROM ven_ag_contract_header ah
     WHERE ah.ag_contract_header_id = p_ag_contract_header_id;
  
    -- ��������� ������ � agent_report_dav
    SELECT sq_agent_report_dav.NEXTVAL INTO v_agent_report_dav_id FROM dual;
    av_insert_report_dav(v_agent_report_dav_id
                        ,0
                        ,p_data_begin
                        ,p_report_id
                        ,v_dr_contract
                        ,p_prod_coef_type_id);
    --�����-������ ���������� �� ������� �����
    -- ���-�� ��������� ������� � ������ v_bonus_all
    -- ���-�� ����� ������� � ������ v_bonus_new
    BEGIN
      SELECT d1.bonus_all
            ,d1.bonus_new
        INTO v_bonus_all
            ,v_bonus_new
        FROM ven_agent_report_dav d1
            ,ven_agent_report     r
            ,ven_ag_vedom_av      v
       WHERE d1.agent_report_id = r.agent_report_id
         AND v.ag_vedom_av_id = r.ag_vedom_av_id
         AND r.ag_contract_h_id = p_ag_contract_header_id
         AND d1.prod_coef_type_id = p_prod_coef_type_id
         AND v.date_begin = ADD_MONTHS(p_data_begin, -1);
    EXCEPTION
      WHEN OTHERS THEN
        v_bonus_all := 0;
        v_bonus_new := 0;
    END;
  
    -- ���������� ������ ����� ������
    UPDATE ven_agent_report_dav r
       SET r.bonus_all = NVL(v_bonus_all, 0)
          ,r.bonus_new = NVL(v_bonus_new, 0)
     WHERE r.agent_report_dav_id = v_agent_report_dav_id;
  
    --���-�� ������� � ��������� ��� ���������
    SELECT COUNT(Acc.ag_contract_header_id)
      INTO v_c_agent
      FROM ven_ag_contract_header Acc
     WHERE Acc.agency_id =
           (SELECT agency_id
              FROM ven_ag_contract_header acc2
             WHERE acc2.ag_contract_header_id = p_ag_contract_header_id)
       AND Acc.t_sales_channel_id = (SELECT t.ID FROM T_SALES_CHANNEL t WHERE t.brief = 'MLM')
       AND Acc.ag_contract_header_id <> p_ag_contract_header_id;
  
    OPEN k_dav_dr;
    LOOP
      -- ������ ��������: �� ������ �������� ����������� �������� ��������� ����� � ������� �������
      FETCH k_dav_dr
        INTO v_dav_dr;
      EXIT WHEN k_dav_dr%NOTFOUND;
      v_ag_ent_id := v_dav_dr.ah_ent_id;
    
      --������� ��� ������� �������� � ������
      IF v_rr <> v_dav_dr.ag_contract_header_id -- ��� ������� ������ ��.�������� �����������
      THEN
        IF v_dav_dr.leg_pos = 1 --���� �����
        THEN
          v_c := v_c + 1;
        END IF;
        v_rr := v_dav_dr.ag_contract_header_id;
      END IF;
      --��������� ����
      IF v_dav_dr.sale_br = 'MLM'
      THEN
        -- ������ �������� �� ������, ��������, �����
        v_proc_one := NVL(Pkg_Tariff_Calc.calc_fun('PREM_DIR'
                                                  ,v_dav_dr.ent_id
                                                  ,v_dav_dr.p_policy_agent_com_id)
                         ,0);
        --�����, �������
      ELSIF v_dav_dr.sale_br IN ('BANK', 'BR')
      THEN
        v_proc_one := 1;
        --��� ���������
      ELSE
        NULL;
      END IF;
      -- ���������� �������� ������
      -- ���� ���� ������
      IF NVL(v_bonus_all, 0) > 0
         OR NVL(v_bonus_new, 0) > 0
      THEN
        --������ �������� 13.12.2007
      
        -- ��� ��������� �� ������ ��������� ����������� ������������ �������+ ������
        dav_sum := v_dav_dr.sum_premium *
                   (NVL(v_proc_one / 100, 0) + NVL(v_bonus_all / 100, 0) + NVL(v_bonus_new / 100, 0));
        av_insert_report_dav_ct(v_agent_report_dav_id -- �� ����
                               ,v_dav_dr.policy_id
                               ,v_dav_dr.sum_premium
                               ,NULL
                               ,NULL
                               ,dav_sum
                               ,NULL
                               ,v_dav_dr.ag_contract_header_id
                               ,v_bonus_all
                               ,v_bonus_new
                               ,v_dav_dr.p_policy_agent_com_id
                               ,v_proc_one
                               ,NULL
                               ,NULL);
      ELSE
        dav_sum := v_dav_dr.sum_premium * NVL(v_proc_one / 100, 0);
        av_insert_report_dav_ct(v_agent_report_dav_id -- �� ����
                               ,v_dav_dr.policy_id
                               ,v_dav_dr.sum_premium
                               ,NULL
                               ,NULL
                               ,dav_sum
                               ,NULL
                               ,v_dav_dr.ag_contract_header_id
                               ,NULL
                               ,NULL
                               ,v_dav_dr.p_policy_agent_com_id
                               ,v_proc_one
                               ,NULL
                               ,NULL);
      END IF;
    END LOOP;
    CLOSE k_dav_dr;
  
    --��������� ����� �����-������ �� ����.������
    --������� ������ �������
    v_new_bonus_all := Pkg_Tariff_Calc.calc_fun('���-1', v_ag_ent_id, p_ag_contract_header_id);
    v_new_bonus_new := Pkg_Tariff_Calc.calc_fun('���-2', v_ag_ent_id, p_ag_contract_header_id);
    --��������� ����� ������ ���� ���-�� ������� ����� ������ 60% � ������ �����
    IF (v_c / v_c_agent) > 0.6
    THEN
      v_new_bonus_new := v_new_bonus_new * 2;
    END IF;
  
    BEGIN
      SELECT NVL(SUM(ct.comission_sum), 0)
        INTO v_ss
        FROM ven_agent_report_dav_ct ct
       WHERE ct.agent_report_dav_id = v_agent_report_dav_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        v_ss := 0;
    END;
  
    UPDATE AGENT_REPORT_DAV d
       SET d.bonus_all     = v_new_bonus_all
          ,d.bonus_new     = v_new_bonus_new
          ,d.comission_sum = NVL(v_ss, 0)
     WHERE d.agent_report_dav_id = v_agent_report_dav_id;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20001
                             ,'������ ������� PREM_DIR.(p_ag_contract_header_id=' ||
                              p_ag_contract_header_id || '). ��. ������ Oracle:' || SQLERRM(SQLCODE));
  END;

  --������ ������ ��������� �� ������� ������� ������ ������
  PROCEDURE av_pr_DR_AG
  (
    p_vedom_id              IN NUMBER --��� ��������� ������� �������������� ����������
   ,p_report_id             IN NUMBER --��� ����
   ,p_data_begin            IN DATE --���� ������ ��������� �������
   ,p_ag_contract_header_id IN NUMBER --��� ���������� �������� ���������
   ,p_prod_coef_type_id     IN NUMBER --��� �������
   ,p_err_code              IN OUT NUMBER --������ ���������� �������
  ) IS
    --������ ��.����
    CURSOR k_dav_dr IS
      SELECT ah.ag_contract_header_id
            ,ah.date_begin ag_date_begin
            ,ac.ag_contract_id
            ,ph.policy_id
            ,Pkg_Agent_1.get_agent_start_contr(ph.policy_header_id) pol_start_date
            ,ppc.ent_id
            ,ah.ent_id ah_ent_id
            ,ppc.p_policy_agent_com_id
            ,arc.sum_premium
            ,ac.leg_pos -- ��/�����
            ,ah.agency_id
            ,ss.brief sale_br
        FROM ven_ag_contract_header ah
        JOIN ven_ag_contract ac
          ON (ah.last_ver_id = ac.ag_contract_id) -- ���������� ������ �������� � �������
        JOIN ven_agent_report ar
          ON (ar.ag_contract_h_id = ah.ag_contract_header_id) -- ���������� ��� ��� ������
        JOIN ven_ag_vedom_av av
          ON (av.ag_vedom_av_id = ar.ag_vedom_av_id AND av.date_begin = p_data_begin) -- ��� �� ��������� �������
        JOIN ven_agent_report_cont arc
          ON (arc.agent_report_id = ar.agent_report_id)
        JOIN ven_p_policy_agent_com ppc
          ON (arc.p_policy_agent_com_id = ppc.p_policy_agent_com_id)
        JOIN ven_p_policy pp
          ON (arc.policy_id = pp.policy_id)
        JOIN ven_p_pol_header ph
          ON (ph.policy_header_id = pp.pol_header_id)
        LEFT JOIN ven_t_sales_channel ss
          ON (ss.ID = ah.t_sales_channel_id)
       WHERE ah.agency_id = (SELECT hh.agency_id
                               FROM ven_ag_contract_header hh
                              WHERE hh.ag_contract_header_id = p_ag_contract_header_id)
         AND Pkg_Agent_Rate.get_policy_status_brief(ph.policy_header_id, LAST_DAY(p_data_begin)) IN
             ('ACTIVE', 'CURRENT', 'PRINTED') --31/10/2007 ��������
            
         AND ((ac.category_id = (SELECT aaa.ag_category_agent_id
                                   FROM AG_CATEGORY_AGENT aaa
                                  WHERE aaa.ag_category_agent_id = ac.category_id
                                    AND aaa.brief = 'AG')
             
             AND EXISTS (SELECT agl.ag_contract_id
                            FROM AG_CONTRACT agl -- ����� �� ��������� � ������ ������
                           WHERE agl.contract_id = p_ag_contract_header_id
                             AND ac.contract_leader_id = agl.ag_contract_id)))
       ORDER BY ah.ag_contract_header_id
               ,ph.policy_id
               ,ppc.p_policy_agent_com_id;
  
    v_dav_dr              k_dav_dr%ROWTYPE;
    v_agent_report_dav_id NUMBER;
    v_proc_one            NUMBER := 0;
    dav_sum               NUMBER := 0;
    v_bonus_all           NUMBER := 0;
    v_bonus_new           NUMBER := 0;
    v_new_bonus_all       NUMBER := 0;
    v_new_bonus_new       NUMBER := 0;
    v_date_begin          DATE;
    v_cur_ag              NUMBER;
    v_c_agent             NUMBER;
    v_ag_ent_id           NUMBER;
    v_dr_contract         NUMBER;
    v_rr                  NUMBER := 0;
    v_c                   NUMBER := 0;
  BEGIN
    Pkg_Agent_Rate.DATE_END := LAST_DAY(p_data_begin);
  
    SELECT ah.last_ver_id
      INTO v_dr_contract -- ������ ���������� �������� ��� ���������
      FROM ven_ag_contract_header ah
     WHERE ah.ag_contract_header_id = p_ag_contract_header_id;
  
    -- ��������� ������ � agent_report_dav
    SELECT sq_agent_report_dav.NEXTVAL INTO v_agent_report_dav_id FROM dual;
    av_insert_report_dav(v_agent_report_dav_id
                        ,0
                        ,p_data_begin
                        ,p_report_id
                        ,v_dr_contract
                        ,p_prod_coef_type_id);
  
    OPEN k_dav_dr;
    LOOP
      -- ������ ��������: �� ������ �������� ����������� �������� ��������� ����� � ������� �������
      FETCH k_dav_dr
        INTO v_dav_dr;
      EXIT WHEN k_dav_dr%NOTFOUND;
      v_ag_ent_id := v_dav_dr.ah_ent_id;
      -- ������ �������� ������
      v_proc_one := NVL(Pkg_Tariff_Calc.calc_fun(p_prod_coef_type_id
                                                ,v_dav_dr.ent_id
                                                ,v_dav_dr.p_policy_agent_com_id)
                       ,0);
      dav_sum    := v_dav_dr.sum_premium * NVL(v_proc_one / 100, 0);
      av_insert_report_dav_ct(v_agent_report_dav_id -- �� ����
                             ,v_dav_dr.policy_id
                             ,v_dav_dr.sum_premium
                             ,NULL
                             ,NULL
                             ,dav_sum
                             ,NULL
                             ,v_dav_dr.ag_contract_header_id
                             ,NULL
                             ,NULL
                             ,v_dav_dr.p_policy_agent_com_id
                             ,v_proc_one
                             ,NULL
                             ,NULL);
    
    END LOOP;
    CLOSE k_dav_dr;
  
    UPDATE AGENT_REPORT_DAV d
       SET d.comission_sum =
           (SELECT NVL(SUM(ct.comission_sum), 0)
              FROM ven_agent_report_dav_ct ct
             WHERE ct.agent_report_dav_id = v_agent_report_dav_id)
     WHERE d.agent_report_dav_id = v_agent_report_dav_id;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20001
                             ,'������ ������� PREM_DIR_GR.(p_ag_contract_header_id=' ||
                              p_ag_contract_header_id || '). ��. ������ Oracle:' || SQLERRM(SQLCODE));
  END;

  --������ �� �������� ���������� � ���������(���)
  PROCEDURE av_pr_mn_recr
  (
    p_vedom_id              IN NUMBER --��� ��������� ������� �������������� ����������
   ,p_report_id             IN NUMBER --��� ����
   ,p_data_begin            IN DATE --���� ������ ��������� �������
   ,p_ag_contract_header_id IN NUMBER --��� ���������� �������� ���������
   ,p_prod_coef_type_id     IN NUMBER --��� �������
   ,p_err_code              IN OUT NUMBER --������ ���������� �������
  ) IS
  
    CURSOR cur_dav
    (
      CV_DATE_BEGIN            DATE
     ,cv_ag_contract_header_id NUMBER
    ) IS
      SELECT a.sum_premium * ((a.rate_value / 2) / 100) AS sum_premium_manager_rec
            ,(a.rate_value / 2) AS rate_manager_rec
            ,rate_value
            ,a.sum_premium
            ,a.prm_manag_lead
            ,a.POLICY_ID
            ,a.p_policy_agent_com_id
            ,a.COMISSION_SUM
            ,a.CHILD_AG_CH_ID
            ,a.PRM_DATE_PAY AS date_pay
            ,ar.AG_CONTRACT_H_ID AS manager_of_agent
        FROM AGENT_REPORT_DAV_CT a
            ,AGENT_REPORT_DAV    ard
            ,AGENT_REPORT        ar
            ,AG_VEDOM_AV         av
       WHERE av.DATE_BEGIN = CV_DATE_BEGIN
            -- and a.PRM_DATE_PAY between CV_DATE_BEGIN and last_Day(CV_DATE_BEGIN)
         AND av.AG_CATEGORY_AGENT_ID = 3
         AND ar.AG_VEDOM_AV_ID = av.AG_VEDOM_AV_ID
         AND ard.AGENT_REPORT_ID = ar.AGENT_REPORT_ID
         AND a.AGENT_REPORT_DAV_ID = ard.AGENT_REPORT_DAV_ID
         AND a.PRM_MANAG_LEAD = cv_ag_contract_header_id
         AND av.DATE_BEGIN = CV_DATE_BEGIN;
  
    CURSOR k_return IS
      SELECT ah.ag_contract_header_id
            ,ah.date_begin ag_date_begin
            ,ac.ag_contract_id
            ,ph.policy_id
            ,Pkg_Agent_1.get_agent_start_contr(ph.policy_header_id) pol_start_date
            ,ppc.ent_id
            ,ppc.p_policy_agent_com_id
            ,arc.sum_premium
            ,arc.part_agent
            ,arc.sav
            ,arc.date_pay
        FROM ven_ag_contract_header ah
            ,ven_ag_contract        ac
            ,ven_agent_report       ar
            ,ven_ag_vedom_av        av
            ,ven_agent_report_cont  arc
            ,ven_p_policy_agent_com ppc
            ,ven_p_pol_header       ph
       WHERE ah.last_ver_id = ac.ag_contract_id -- ���������� ������ �������� � �������
         AND ar.ag_contract_h_id = ah.ag_contract_header_id -- ���������� ��� ��� ������
         AND av.ag_vedom_av_id = ar.ag_vedom_av_id
         AND av.date_begin = p_data_begin -- ��� �� ��������� �������
         AND arc.agent_report_id = ar.agent_report_id
         AND arc.p_policy_agent_com_id = ppc.p_policy_agent_com_id
         AND ph.policy_id = arc.policy_id
         AND EXISTS
       (SELECT agl.ag_contract_id
                FROM AG_CONTRACT agl -- ����� ��������� � ������ ���������
               WHERE EXISTS
               (SELECT ah2.ag_contract_header_id
                        FROM ven_ag_contract_header ah2
                            ,ven_ag_contract        ac2
                       WHERE EXISTS (SELECT ag3.ag_contract_id
                                FROM AG_CONTRACT ag3 -- ����� ��������� � ������ ���������
                               WHERE ag3.contract_id = p_ag_contract_header_id
                                 AND ac2.contract_f_lead_id = ag3.ag_contract_id)
                         AND ah2.last_ver_id = ac2.ag_contract_id
                         AND ac2.category_id = (SELECT aaa1.ag_category_agent_id
                                                  FROM AG_CATEGORY_AGENT aaa1
                                                 WHERE aaa1.ag_category_agent_id = ac2.category_id
                                                   AND aaa1.brief = 'MN')
                         AND agl.contract_id = ah2.ag_contract_header_id)
                 AND ac.contract_leader_id = agl.ag_contract_id)
         AND Pkg_Agent_Rate.get_p_policy_status_brief(arc.policy_id, LAST_DAY(p_data_begin)) IN
             ('ACTIVE', 'CURRENT', 'PRINTED')
         AND ac.category_id = (SELECT aaa.ag_category_agent_id
                                 FROM AG_CATEGORY_AGENT aaa
                                WHERE aaa.ag_category_agent_id = ac.category_id
                                  AND aaa.brief = 'AG')
       ORDER BY ah.ag_contract_header_id
               ,ph.policy_id
               ,ppc.p_policy_agent_com_id;
  
    v_agent_report_dav_id NUMBER;
    v_mn_contract         NUMBER;
    v_dav_mn              k_return%ROWTYPE;
    dav_sum               NUMBER;
  
  BEGIN
  
    SELECT ah.last_ver_id
      INTO v_mn_contract -- ������ ���������� �������� ��� ���������
      FROM ven_ag_contract_header ah
     WHERE ah.ag_contract_header_id = p_ag_contract_header_id;
    -- ��������� ������ � agent_report_dav
    SELECT sq_agent_report_dav.NEXTVAL INTO v_agent_report_dav_id FROM dual;
    av_insert_report_dav(v_agent_report_dav_id
                        ,0
                        ,p_data_begin
                        ,p_report_id
                        ,v_mn_contract
                        ,p_prod_coef_type_id);
  
    FOR v_dav_mn IN cur_dav(p_data_begin, p_ag_contract_header_id)
    LOOP
    
      IF (Pkg_Agent_Sub.IsRecrutCalcByDate(v_dav_mn.date_pay
                                          ,p_ag_contract_header_id
                                          ,v_dav_mn.manager_of_agent) = Utils.c_true)
      THEN
      
        av_insert_report_dav_ct(v_agent_report_dav_id -- �� ����
                               ,v_dav_mn.policy_id
                               ,v_dav_mn.sum_premium
                               ,NULL
                               ,NULL
                               ,v_dav_mn.sum_premium_manager_rec
                               ,NULL
                               ,v_dav_mn.CHILD_AG_CH_ID
                               ,NULL
                               ,NULL
                               ,v_dav_mn.p_policy_agent_com_id
                               ,v_dav_mn.rate_manager_rec
                               ,v_dav_mn.date_pay
                               ,NULL);
      END IF;
    
    END LOOP;
  
    UPDATE AGENT_REPORT_DAV d
       SET d.comission_sum =
           (SELECT NVL(SUM(ct.comission_sum), 0)
              FROM ven_agent_report_dav_ct ct
             WHERE ct.agent_report_dav_id = v_agent_report_dav_id)
     WHERE d.agent_report_dav_id = v_agent_report_dav_id;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20001
                             ,'������ ������� ���.(p_ag_contract_header_id=' ||
                              p_ag_contract_header_id || '). ��. ������ Oracle:' || SQLERRM(SQLCODE));
  END;

  --������ �� �������� ���������(���)
  PROCEDURE av_pr_dr_recr
  (
    p_vedom_id              IN NUMBER --��� ��������� ������� �������������� ����������
   ,p_report_id             IN NUMBER --��� ����
   ,p_data_begin            IN DATE --���� ������ ��������� �������
   ,p_ag_contract_header_id IN NUMBER --��� ���������� �������� ���������
   ,p_prod_coef_type_id     IN NUMBER --��� �������
   ,p_err_code              IN OUT NUMBER --������ ���������� �������
  ) IS
    CURSOR k_pr_dr IS
    
      SELECT ah.ag_contract_header_id
            ,ah.date_begin ag_date_begin
            ,ac.ag_contract_id
            ,ph.policy_id
            ,Pkg_Agent_1.get_agent_start_contr(ph.policy_header_id) pol_start_date
            ,ppc.ent_id
            ,ppc.p_policy_agent_com_id
            ,arc.sum_premium
            ,arc.part_agent
            ,arc.sav
        FROM ven_ag_contract_header ah
            ,ven_ag_contract        ac
            ,ven_agent_report       ar
            ,ven_ag_vedom_av        av
            ,ven_agent_report_cont  arc
            ,ven_p_policy_agent_com ppc
            ,ven_p_pol_header       ph
       WHERE ah.last_ver_id = ac.ag_contract_id -- ���������� ������ �������� � �������
         AND ar.ag_contract_h_id = ah.ag_contract_header_id -- ���������� ��� ��� ������
         AND av.ag_vedom_av_id = ar.ag_vedom_av_id
         AND av.date_begin = p_data_begin -- ��� �� ��������� �������
         AND arc.agent_report_id = ar.agent_report_id
         AND arc.p_policy_agent_com_id = ppc.p_policy_agent_com_id
         AND ph.policy_id = arc.policy_id
         AND EXISTS
       (SELECT agl.ag_contract_id
                FROM AG_CONTRACT agl -- ����� ��������� � ������ ���������
               WHERE EXISTS
               (SELECT ah2.ag_contract_header_id
                        FROM ven_ag_contract_header ah2
                            ,ven_ag_contract        ac2
                       WHERE EXISTS (SELECT ag3.ag_contract_id
                                FROM AG_CONTRACT ag3 -- ����� ��������� � ������ ���������
                               WHERE ag3.contract_id = p_ag_contract_header_id
                                 AND ac2.contract_f_lead_id = ag3.ag_contract_id)
                         AND ah2.last_ver_id = ac2.ag_contract_id
                         AND ac2.category_id = (SELECT aaa1.ag_category_agent_id
                                                  FROM AG_CATEGORY_AGENT aaa1
                                                 WHERE aaa1.ag_category_agent_id = ac2.category_id
                                                   AND aaa1.brief = 'DR')
                         AND agl.contract_id = ah2.ag_contract_header_id)
                 AND ac.contract_leader_id = agl.ag_contract_id)
         AND Pkg_Agent_Rate.get_p_policy_status_brief(arc.policy_id, LAST_DAY(p_data_begin)) IN
             ('ACTIVE', 'CURRENT', 'PRINTED')
            
         AND ac.category_id = (SELECT aaa.ag_category_agent_id
                                 FROM AG_CATEGORY_AGENT aaa
                                WHERE aaa.ag_category_agent_id = ac.category_id
                                  AND aaa.brief = 'AG')
       ORDER BY ah.ag_contract_header_id
               ,ph.policy_id
               ,ppc.p_policy_agent_com_id;
  
    v_pr_dr               k_pr_dr%ROWTYPE;
    v_dr_contract         NUMBER;
    v_agent_report_dav_id NUMBER;
    v_y                   NUMBER;
    dav_sum               NUMBER;
    v_sav                 NUMBER;
    v_db                  DATE;
  BEGIN
    SELECT MIN(tm.date_b)
      INTO v_db
      FROM (SELECT t.date_begin  date_b
                  ,t.category_id ag_c
              FROM AG_CONTRACT t
             WHERE t.contract_id = p_ag_contract_header_id
               AND t.date_begin <= LAST_DAY(p_data_begin)) tm
     WHERE tm.ag_c = (SELECT a.ag_category_agent_id FROM AG_CATEGORY_AGENT a WHERE a.brief = 'DR')
       AND NOT EXISTS (SELECT '1'
              FROM (SELECT q.date_begin  date_b
                          ,q.category_id ag_c
                      FROM AG_CONTRACT q
                     WHERE q.contract_id = p_ag_contract_header_id
                       AND q.date_begin <= LAST_DAY(p_data_begin)) tt
             WHERE tt.ag_c = (SELECT a.ag_category_agent_id
                                FROM AG_CATEGORY_AGENT a
                               WHERE (a.brief = 'AG' OR a.brief = 'MN'))
               AND tt.date_b > tm.date_b);
  
    SELECT ah.last_ver_id
          ,CEIL(MONTHS_BETWEEN(LAST_DAY(p_data_begin), v_db) / 12)
      INTO v_dr_contract
          ,v_y -- ������ ���������� �������� ��� ���������, ��� ��������
      FROM ven_ag_contract_header ah
     WHERE ah.ag_contract_header_id = p_ag_contract_header_id;
  
    -- ��������� ������ � agent_report_dav
    SELECT sq_agent_report_dav.NEXTVAL INTO v_agent_report_dav_id FROM dual;
    av_insert_report_dav(v_agent_report_dav_id
                        ,0
                        ,p_data_begin
                        ,p_report_id
                        ,v_dr_contract
                        ,p_prod_coef_type_id);
  
    OPEN k_pr_dr;
    LOOP
      -- ������ ��������: �� ������ �������� ����������� �������� ��������� ����� � ������� �������
      FETCH k_pr_dr
        INTO v_pr_dr;
      EXIT WHEN k_pr_dr%NOTFOUND;
    
      IF v_y = 1
      THEN
        v_sav   := 0.02;
        dav_sum := NVL(v_pr_dr.sum_premium, 0) * v_sav;
      ELSIF v_y > 1
      THEN
        v_sav   := 0.01;
        dav_sum := NVL(v_pr_dr.sum_premium, 0) * v_sav;
      ELSE
        NULL;
      END IF;
    
      av_insert_report_dav_ct(v_agent_report_dav_id -- �� ����
                             ,v_pr_dr.policy_id
                             ,v_pr_dr.sum_premium
                             ,NULL
                             ,NULL
                             ,dav_sum
                             ,NULL
                             ,v_pr_dr.ag_contract_header_id
                             ,NULL
                             ,NULL
                             ,v_pr_dr.p_policy_agent_com_id
                             ,v_sav * 100
                             ,NULL
                             ,NULL);
    
    END LOOP;
    CLOSE k_pr_dr;
  
    UPDATE AGENT_REPORT_DAV d
       SET d.comission_sum =
           (SELECT NVL(SUM(ct.comission_sum), 0)
              FROM ven_agent_report_dav_ct ct
             WHERE ct.agent_report_dav_id = v_agent_report_dav_id)
     WHERE d.agent_report_dav_id = v_agent_report_dav_id;
  
    -- DELETE FROM ven_agent_report_dav d3 WHERE NVL(d3.comission_sum,0)=0;
  
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20001
                             ,'������ ������� ���. (p_ag_contract_header_id=' ||
                              p_ag_contract_header_id || '). ��. ������ Oracle:' || SQLERRM(SQLCODE));
    
    --p_err_code:=SQLCODE;
  END;

  ---/// ��������� ���������� ������ �������� �� ��������� ���������� �������������� (���)
  PROCEDURE av_oav_one_return
  (
    p_vedom_id              IN NUMBER --��� ��������� ������� �������������� ����������
   ,p_data_begin            IN DATE --���� ������ ��������� �������
   ,p_ag_contract_header_id IN NUMBER --��� ���������� ��������
   ,p_type_av               IN NUMBER --��� ���� ���������� �������������� (T_AG_AV_ID)
   ,p_err_code              OUT NUMBER --������ ���������� �������
  ) IS
    -- ����������� ��������� �����������, �� ������� ����� ��������� ��������
    CURSOR k_return IS
      SELECT ar.ag_type_rate_value_id -- ��� ���� ���� ������ � ��������
            ,pa.part_agent -- ���� ������ � ��������
            ,pp.policy_id -- ��� ������ �������� �����������
            ,NVL(pp.premium, 0) GP -- ����� ������� ������
            ,ar.brief -- ������� ������������ ���� ������
            ,SUM(NVL(t.acc_amount, 0)) tr_amount -- ����� � ������ ����� �� ���� ������� ������
      
        FROM ven_p_pol_header ph -- ��������� �������� �����������
        JOIN ven_p_policy pp
          ON (ph.policy_id = pp.policy_id) -- ������� ������ �������� �����������
        LEFT JOIN ven_trans t
          ON (t.a2_ct_uro_id = pp.policy_id) -- ���������� �� �������� �����������
        LEFT JOIN ven_trans_templ tt
          ON (tt.trans_templ_id = t.trans_templ_id AND tt.brief = '�����������������������') -- ���������� ������������� ������
        JOIN ven_as_asset ass
          ON (ass.p_policy_id = pp.policy_id) -- ������ �� �������� �����������
        JOIN ven_p_cover pc
          ON (pc.as_asset_id = ass.as_asset_id) -- �������� �� �������� �����������
        JOIN ven_t_prod_line_option plo
          ON (plo.ID = pc.t_prod_line_option_id) -- ������ ������ �� ������ (��������� �����������)
        JOIN ven_t_product tp
          ON (tp.product_id = ph.product_id) -- ������� �����������
        JOIN ven_p_policy_agent pa
          ON (ph.policy_header_id = pa.policy_header_id) -- a����� �� �������� �����������
        JOIN ven_policy_agent_status pas
          ON (pa.status_id = pas.policy_agent_status_id) -- ������� ������� �� �������� �����������
        JOIN ven_ag_type_rate_value ar
          ON (pa.ag_type_rate_value_id = ar.ag_type_rate_value_id) -- ��� ���� ������ � ��������
        LEFT JOIN ven_t_payment_terms pt
          ON (pt.ID = pp.payment_term_id)
      
       WHERE ph.start_date >= ADD_MONTHS(p_data_begin, 12)
         AND pp.end_date <= LAST_DAY(p_data_begin) --???? ���� ���������???? ��� ���� ��������� ������� "����������"
         AND NVL(pt.number_of_payments, 1) > 1 --���������� ������ � ����
         AND pa.ag_contract_header_id = p_ag_contract_header_id -- ������� �� ����������� ������
      
       GROUP BY ar.ag_type_rate_value_id -- ��� ���� ���� ������ � ��������
               ,pa.part_agent -- ���� ������ � ��������
               ,pp.policy_id -- ��� ������ �������� �����������
               ,NVL(pp.premium, 0)
               ,ar.brief -- ������� ������������ ���� ������
      ;
    v_return       k_return%ROWTYPE;
    v_OAV          NUMBER;
    v_OAV_return   NUMBER;
    v_part_not_pay NUMBER;
    v_repor_cont   AGENT_REPORT_CONT%ROWTYPE;
    v_part_agent   NUMBER;
    v_report_id    NUMBER;
  BEGIN
  
    OPEN k_return;
    LOOP
      FETCH k_return
        INTO v_return.ag_type_rate_value_id
            ,v_return.part_agent
            ,v_return.policy_id
            ,v_return.gp
            ,v_return.brief
            ,v_return.tr_amount;
      EXIT WHEN k_return%NOTFOUND;
      -- ������ ����� �� ����������� ������������� �����
      v_part_not_pay := 1 - (v_return.tr_amount / v_return.gp);
      IF v_part_not_pay > 0
      THEN
        -- ����� � ���� ����������� ��� (������ ������: agent_report+agent_report_cont �� ������� ������ + �� ������� ������ )
        BEGIN
          SELECT SUM(NVL(arc.sum_premium, 0) - NVL(arc.sum_return, 0))
            INTO v_OAV
            FROM ven_agent_report ar
            JOIN ven_agent_report_cont arc
              ON (arc.agent_report_id = ar.agent_report_id)
           WHERE ar.ag_contract_h_id = p_ag_contract_header_id
             AND arc.policy_id = v_return.policy_id;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            v_OAV := 0;
        END;
        -- ������ ������������ ���
        v_OAV_return := v_OAV * v_part_not_pay;
        -- �������� ���� ������ � ���� ����
        IF (v_return.brief = 'PERCENT' AND v_return.part_agent = 100) -- �������
        THEN
          v_part_agent := 0;
        ELSE
          v_part_agent := 1;
        END IF;
        -- �������� ������� ������������� ������ � ������� agent_report (p_vedom_id + ���� ������)
        BEGIN
          SELECT ar.agent_report_id
            INTO v_report_id
            FROM ven_agent_report ar
           WHERE ar.ag_contract_h_id = p_ag_contract_header_id
             AND ar.ag_vedom_av_id = p_vedom_id
             AND ar.pr_part_agent = v_part_agent;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            v_report_id := 0;
        END;
        -- ��� ���������� ������ � agent_report ����������� ����� ������
        IF v_report_id = 0
        THEN
          v_report_id := av_insert_report(p_vedom_id
                                         ,p_ag_contract_header_id
                                         ,p_type_av
                                         ,v_part_agent
                                         ,p_err_code);
        END IF;
      END IF;
    END LOOP;
    CLOSE k_return;
  
  EXCEPTION
    WHEN OTHERS THEN
    
      RAISE_APPLICATION_ERROR(-20001
                             ,'�� ����� ������� �������� �� ��������� ���������� �������������� (���) ��������� ������. (p_ag_contract_header_id=' ||
                              p_ag_contract_header_id || '). ��. ������ Oracle:' || SQLERRM(SQLCODE));
    
  END;

  PROCEDURE av_dav_one_BB
  (
    p_vedom_id          IN NUMBER --��� ��������� ������� �������������� ����������
   ,p_report_id         IN NUMBER --��� ������
   ,p_data_begin        IN DATE --���� ������ ��������� �������
   ,p_ag_id             IN NUMBER --��� ������ ��.��������
   ,p_prod_coef_type_id IN NUMBER --��� �������
   ,p_err_code          IN OUT NUMBER --������ ���������� �������
  ) IS
  
    TYPE T_NUMBER IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
    v_summ_v T_NUMBER;
    i        BINARY_INTEGER;
    i_max    BINARY_INTEGER;
    ii       BINARY_INTEGER;
  
    v_report_dav ven_agent_report_dav%ROWTYPE;
    sum_dav      NUMBER;
    v_davbb      NUMBER;
    v_sum_davbb  NUMBER;
    v_s          NUMBER;
    v_func_brief VARCHAR2(100);
  
  BEGIN
    -- ���������� ��������� ����������� ��������� ������
    BEGIN
      SELECT COUNT('1')
            ,t.brief
        INTO i_max
            ,v_func_brief
        FROM ven_t_prod_coef_type t
            ,ven_t_prod_coef      c
       WHERE t.t_prod_coef_type_id = p_prod_coef_type_id
         AND c.t_prod_coef_type_id = t.t_prod_coef_type_id
         AND c.val <> 0
       GROUP BY t.brief;
    EXCEPTION
      WHEN OTHERS THEN
        i_max := 0;
    END;
    -- ����������� ����� ������ �� ����������� ����� ��� ��������
    IF i_max > 0
    THEN
      -- ���� ���������� ����������� ������ ������
      v_summ_v(0) := 0;
      FOR i IN 1 .. i_max
      LOOP
        ii := i - 1;
        SELECT MIN(c.val)
          INTO v_s -- ����� i-�� �������
          FROM ven_t_prod_coef_type t
              ,ven_t_prod_coef      c
         WHERE t.t_prod_coef_type_id = p_prod_coef_type_id
           AND c.t_prod_coef_type_id = t.t_prod_coef_type_id
           AND c.val > v_summ_v(ii);
        v_summ_v(i) := v_s;
      END LOOP;
    END IF;
    --����, �� ������� ������������ �� ��.�������� ���������������� �����, ������� � ��������������� ������������ ������
    FOR v_brok IN (SELECT ch_2.ag_contract_header_id
                         ,ch_2.ent_id
                         ,SUM(Pkg_Payment.get_pay_pol_header_amount_pfa(ch_2.date_begin
                                                                       ,LAST_DAY(p_data_begin)
                                                                       ,pph.policy_header_id)) summ
                     FROM ven_ag_contract_header ch_2 -- ���� �������� ��������������
                     JOIN ven_ag_contract ac_2
                       ON (ch_2.last_ver_id = ac_2.ag_contract_id) -- ����������� ������ �������� ��������������
                     JOIN ven_ag_contract ac_1
                       ON (ac_1.ag_contract_id = ac_2.contract_recrut_id) -- ������ ��������� ������
                     JOIN ven_ag_contract_header ch_1
                       ON (ac_1.contract_id = ch_1.ag_contract_header_id) -- ������ ��������� ��������
                     JOIN ven_t_sales_channel h
                       ON (h.ID = ch_2.t_sales_channel_id AND h.brief IN ('BANK', 'BR')) -- ����� ������ �������������� = "����"
                     JOIN (SELECT ph.policy_header_id
                                ,pa.ag_contract_header_id -- ��� �������� ����������� ��� ��������������
                            FROM ven_p_pol_header ph
                            JOIN ven_p_policy_agent pa
                              ON (pa.policy_header_id = ph.policy_header_id)
                            JOIN ven_policy_agent_status pas
                              ON (pa.status_id = pas.policy_agent_status_id)
                           WHERE pas.brief IN ('CURRENT')
                             AND pa.status_date <= LAST_DAY(p_data_begin) -- �������� ���� �������
                          ) pph
                       ON (pph.ag_contract_header_id = ch_2.ag_contract_header_id)
                     JOIN (SELECT ah.last_ver_id -- ���� ������ �������������� = ���� ������ ���������
                            FROM ven_ag_contract ac
                            JOIN ven_ag_contract_header ah
                              ON (ah.ag_contract_header_id = ac.contract_id)
                           WHERE ac.ag_contract_id = p_ag_id) param_id
                       ON (param_id.last_ver_id = ch_1.last_ver_id)
                    WHERE ch_2.date_begin < LAST_DAY(p_data_begin) -- ���� ������ �������� ������ ������������� ����
                   -- WHERE Pkg_Payment.get_pay_pol_header_amount_pfa(ch_2.date_begin,SYSDATE, ph.policy_header_id) <> 0
                    GROUP BY ch_2.ag_contract_header_id
                            ,ch_2.ent_id)
    LOOP
      IF v_brok.summ <> 0
      THEN
        -- ������� ����������� ������ �� ������� ����� ��� ������� � ����������� �� ����������� ���� �������
        sum_dav := Pkg_Tariff_Calc.calc_fun(v_func_brief, v_brok.ent_id, v_brok.ag_contract_header_id);
      
        BEGIN
          SELECT COUNT('1')
                ,SUM(d.comission_sum)
            INTO v_davbb
                ,v_sum_davbb
            FROM ven_ag_contract         c
                ,ven_agent_report        ar
                ,ven_agent_report_dav    d
                ,ven_agent_report_dav_ct dt
                ,ven_t_prod_coef_type    ct
           WHERE c.ag_contract_id = p_ag_id
             AND c.contract_id = ar.ag_contract_h_id
             AND ar.agent_report_id = d.agent_report_id
             AND d.prod_coef_type_id = ct.t_prod_coef_type_id
             AND NVL(d.comission_sum, 0) > 0
             AND dt.agent_report_dav_id = d.agent_report_dav_id
             AND dt.recr_ag_ch_id = v_brok.ag_contract_header_id
             AND ct.t_prod_coef_type_id = p_prod_coef_type_id;
        EXCEPTION
          WHEN OTHERS THEN
            v_davbb := 0;
        END;
      
        IF i_max > 0
           AND NVL(sum_dav, 0) <> 0
        THEN
          -- ���� ���������� ����������� ������ ������
          FOR ii IN (v_davbb + 1) .. i_max -- ��� ���� ������� ����������� ������ ������� �� (����������� + 1)
          LOOP
            -- ������ ����� ����������� ����
            IF v_summ_v(ii) > sum_dav -- �� ��� ��� ���� ����������� ����� �� ������ ���������
            THEN
              EXIT;
            ELSE
              -- �� ���� ��������� ������� ����������� ������ � �������
              SELECT sq_agent_report_dav.NEXTVAL INTO v_report_dav.agent_report_dav_id FROM dual;
              av_insert_report_dav(v_report_dav.agent_report_dav_id
                                  ,v_summ_v(ii) --,
                                  ,p_data_begin
                                  ,p_report_id -- �� ����
                                  ,p_ag_id
                                  ,p_prod_coef_type_id
                                  ,NULL
                                  ,NULL
                                  ,NULL
                                  ,NULL
                                  ,v_brok.summ ---????????
                                  ,NULL);
            
              INSERT INTO ven_agent_report_dav_ct
                (agent_report_dav_ct_id, agent_report_dav_id, policy_id, recr_ag_ch_id, sum_premium)
                (SELECT sq_agent_report_dav_ct.NEXTVAL
                       ,v_report_dav.agent_report_dav_id
                       ,Pkg_Policy.get_last_version(pa.policy_header_id)
                       ,v_brok.ag_contract_header_id
                       ,Pkg_Payment.get_pay_pol_header_amount_pfa(ch.date_begin
                                                                 ,LAST_DAY(p_data_begin)
                                                                 ,pa.policy_header_id)
                   FROM ven_ag_contract_header ch
                   JOIN ven_p_policy_agent pa
                     ON (pa.ag_contract_header_id = ch.ag_contract_header_id)
                   JOIN ven_policy_agent_status pas
                     ON (pa.status_id = pas.policy_agent_status_id AND pas.brief IN ('CURRENT'))
                  WHERE ch.ag_contract_header_id = v_brok.ag_contract_header_id
                    AND Pkg_Payment.get_pay_pol_header_amount_pfa(ch.date_begin
                                                                 ,LAST_DAY(p_data_begin)
                                                                 ,pa.policy_header_id) <> 0);
            
            END IF;
          END LOOP;
        ELSIF sum_dav > 0
        THEN
          -- ���� �� ���������� ����������� ������ ������ - ����������� ��� ��������� � �������
          SELECT sq_agent_report_dav.NEXTVAL INTO v_report_dav.agent_report_dav_id FROM dual;
          av_insert_report_dav(v_report_dav.agent_report_dav_id
                              ,sum_dav
                              ,p_data_begin
                              ,p_report_id -- �� ����
                              ,p_ag_id
                              ,p_prod_coef_type_id
                              ,NULL
                              ,NULL
                              ,NULL
                              ,NULL
                              ,v_brok.summ
                              ,NULL);
        
          INSERT INTO ven_agent_report_dav_ct
            (agent_report_dav_ct_id, agent_report_dav_id, policy_id, recr_ag_ch_id, sum_premium)
            (SELECT sq_agent_report_dav_ct.NEXTVAL
                   ,v_report_dav.agent_report_dav_id
                   ,Pkg_Policy.get_last_version(pa.policy_header_id)
                   ,v_brok.ag_contract_header_id
                   ,Pkg_Payment.get_pay_pol_header_amount_pfa(ch.date_begin
                                                             ,LAST_DAY(p_data_begin)
                                                             ,pa.policy_header_id)
               FROM ven_ag_contract_header ch
               JOIN ven_p_policy_agent pa
                 ON (pa.ag_contract_header_id = ch.ag_contract_header_id)
               JOIN ven_policy_agent_status pas
                 ON (pa.status_id = pas.policy_agent_status_id AND pas.brief IN ('CURRENT'))
              WHERE ch.ag_contract_header_id = v_brok.ag_contract_header_id
                AND Pkg_Payment.get_pay_pol_header_amount_pfa(ch.date_begin
                                                             ,LAST_DAY(p_data_begin)
                                                             ,pa.policy_header_id) <> 0);
        END IF;
      
      END IF; -- v_brok.summ <> 0
    END LOOP;
  
  END;
  --��������������� ������� ������� ��� ������� ������ � ��������������� ������/��������
  --��� ����������
  PROCEDURE av_dav_mn_sgp
  (
    p_ag_contract_header_id IN NUMBER
   ,p_db                    IN DATE
   ,p_de                    IN DATE
   ,p_agent_report_dav_id   IN NUMBER
  ) IS
    v_SGP NUMBER;
  BEGIN
  
    --������� ��� ����������� �������, ������� � ����_�������
    Pkg_Agent_1.attest_manag_SGP(p_ag_contract_header_id
                                ,p_db
                                , -- ������� �� ���� ������ �������� ��.��������, ���������� ���������
                                 p_de
                                ,v_SGP);
  
    --��������� � �����������, ���� �� ��������
    INSERT INTO ven_agent_report_dav_ct
      (agent_report_dav_ct_id, agent_report_dav_id, child_ag_ch_id, policy_id, sgp)
      SELECT sq_agent_report_dav_ct.NEXTVAL
            ,p_agent_report_dav_id
            ,t.ag_contract_header_id
            ,t.policy_id
            ,t.k_sgp
        FROM AG_STAT_DET_TMP t
       WHERE t.men_contract_header_id = p_ag_contract_header_id;
    --���-�� ��������� �������
    --insert into fff select * from ag_stat_det_tmp tm;
    SELECT COUNT(DISTINCT tm.ag_contract_header_id)
      INTO Pkg_Agent_Rate.ka
      FROM AG_STAT_DET_TMP tm
     WHERE tm.men_contract_header_id = p_ag_contract_header_id;
  
    DELETE FROM AG_STAT_DET_TMP;
  
    --������� ��� ������ ���������, ������� ����_�������
    Pkg_Agent_1.attest_agent_SGP(p_ag_contract_header_id, p_db, p_de, v_SGP);
    --��������� � �����������, ���� �� ��������
    INSERT INTO ven_agent_report_dav_ct
      (agent_report_dav_ct_id, agent_report_dav_id, child_ag_ch_id, policy_id, sgp)
      SELECT sq_agent_report_dav_ct.NEXTVAL
            ,p_agent_report_dav_id
            ,t.ag_contract_header_id
            ,t.policy_id
            ,t.k_sgp
        FROM AG_STAT_DET_TMP t
       WHERE t.ag_contract_header_id = p_ag_contract_header_id;
  
    DELETE FROM AG_STAT_DET_TMP;
    --������� ��� ������,�������� ��� � ������ �������� � 10 � 50 ���������,
    --������� ����_�������
  
    Pkg_Agent_1.manag_SGP_bank(p_ag_contract_header_id
                              ,p_db
                              , -- ���� ������ ������������ �������
                               p_de
                              ,v_SGP);
    --��������� � �����������, ���� �� ��������
    INSERT INTO ven_agent_report_dav_ct
      (agent_report_dav_ct_id, agent_report_dav_id, child_ag_ch_id, policy_id, sgp)
      SELECT sq_agent_report_dav_ct.NEXTVAL
            ,p_agent_report_dav_id
            ,t.ag_contract_header_id
            ,t.policy_id
            ,t.k_sgp
        FROM AG_STAT_DET_TMP t
       WHERE t.men_contract_header_id = p_ag_contract_header_id;
  
    -- �������� ����_�������, ������� � ���������� ��������,
    SELECT NVL(SUM(ct.sgp), 0)
      INTO Pkg_Agent_Rate.SGP
      FROM ven_agent_report_dav_ct ct
     WHERE ct.agent_report_dav_id = p_agent_report_dav_id;
  
  END;

  --������ � ������ ��������� ��������� ��������� ������
  PROCEDURE av_dav_one_DPPM
  (
    p_vedom_id              IN NUMBER --��� ��������� ������� �������������� ����������
   ,p_report_id             IN NUMBER --��� ����
   ,p_data_begin            IN DATE --���� ������ ��������� �������
   ,p_ag_contract_header_id IN NUMBER --��� ������� ��������
   ,p_prod_coef_type_id     IN NUMBER --��� �������
   ,p_err_code              IN OUT NUMBER --������ ���������� �������
  ) IS
  
    v_st_d                DATE;
    v_dr_contract         NUMBER;
    v_ent_id              NUMBER;
    v_m                   NUMBER;
    v_db                  DATE;
    v_SGP                 NUMBER;
    v_agent_report_dav_id NUMBER;
    v_sum                 NUMBER;
  BEGIN
    Pkg_Ins_Log.SP_EventInfo(1, 'pkg_agent_rate', 'av_dav_one_DPPM');
  
    --������ �������� 06.02.2008
    SELECT MIN(tm.date_b)
      INTO v_st_d
      FROM (SELECT t.date_begin  date_b
                  ,t.category_id ag_c
              FROM AG_CONTRACT t
             WHERE t.contract_id = p_ag_contract_header_id
               AND t.date_begin <= LAST_DAY(p_data_begin)) tm
     WHERE tm.ag_c = (SELECT a.ag_category_agent_id FROM AG_CATEGORY_AGENT a WHERE a.brief = 'MN')
       AND NOT EXISTS
     (SELECT '1'
              FROM (SELECT q.date_begin  date_b
                          ,q.category_id ag_c
                      FROM AG_CONTRACT q
                     WHERE q.contract_id = p_ag_contract_header_id
                       AND q.date_begin <= LAST_DAY(p_data_begin)) tt
             WHERE tt.ag_c =
                   (SELECT a.ag_category_agent_id FROM AG_CATEGORY_AGENT a WHERE a.brief = 'AG')
               AND tt.date_b > tm.date_b);
  
    SELECT ah.last_ver_id
          ,ent_id
          ,CEIL(MONTHS_BETWEEN(LAST_DAY(p_data_begin), v_st_d))
      INTO v_dr_contract
          ,v_ent_id
          ,v_m -- ������ ���������� �������� ��� ���������, ����� ��������
      FROM ven_ag_contract_header ah
     WHERE ah.ag_contract_header_id = p_ag_contract_header_id;
    -- ��������� ������ � agent_report_dav
    SELECT sq_agent_report_dav.NEXTVAL INTO v_agent_report_dav_id FROM dual;
    av_insert_report_dav(v_agent_report_dav_id
                        ,0
                        ,p_data_begin
                        ,p_report_id
                        ,v_dr_contract
                        ,p_prod_coef_type_id);
  
    IF TO_CHAR(TO_DATE(v_st_d), 'dd') > 15
    THEN
      Pkg_Agent_Rate.mon := v_m - 1;
    ELSE
      Pkg_Agent_Rate.mon := v_m;
    END IF;
    --���� ������ ����� ��������, ������ �������� �� ���� ������
    IF v_m = 0
    THEN
      --�� ������ ������
      v_m := 100;
    ELSIF v_m = 1
          AND TO_CHAR(TO_DATE(v_st_d), 'dd') > 15
    THEN
      --������ �������� � 1-� �����
      v_db := v_st_d;
    ELSE
      v_db := p_data_begin;
    END IF;
  
    --���� <12 ����� �������, ����� �������
    IF v_m < 13
    THEN
    
      Pkg_Agent_Rate.av_dav_mn_sgp(p_ag_contract_header_id
                                  ,v_db
                                  ,LAST_DAY(p_data_begin)
                                  ,v_agent_report_dav_id);
      -- ���������  �������
      -- �������� ������� DPPM
      v_sum := Pkg_Tariff_Calc.calc_fun(p_prod_coef_type_id, v_ent_id, p_ag_contract_header_id);
      UPDATE AGENT_REPORT_DAV d
         SET d.comission_sum = NVL(v_sum, 0)
            ,d.sgp           = Pkg_Agent_Rate.SGP
            ,d.count_agent   = Pkg_Agent_Rate.ka
       WHERE d.agent_report_dav_id = v_agent_report_dav_id;
      Pkg_Ins_Log.SP_EventInfo(9, 'pkg_agent_rate', 'av_dav_one_DPPM');
    END IF;
    Pkg_Ins_Log.SP_EventInfo(10, 'pkg_agent_rate', 'av_dav_one_DPPM');
  EXCEPTION
    WHEN OTHERS THEN
    
      RAISE_APPLICATION_ERROR(-20001, '������ ������� ����: ' || SQLERRM(SQLCODE));
    
  END;

  PROCEDURE av_dav_OPM
  (
    p_vedom_id              IN NUMBER --��� ��������� ������� �������������� ����������
   ,p_report_id             IN NUMBER --��� ������
   ,p_data_begin            IN DATE --���� ������ ��������� �������
   ,p_ag_contract_header_id IN NUMBER --p_ag_id                 --��� ������ ��.��������
   ,p_prod_coef_type_id     IN NUMBER -- ��� �������
   ,p_err_code              OUT NUMBER --������ ���������� �������
  ) IS
    v_st_d                DATE;
    v_dr_contract         NUMBER;
    v_ent_id              NUMBER;
    v_m                   NUMBER;
    v_mon                 NUMBER;
    v_2y                  NUMBER;
    v_3y                  NUMBER;
    v_KSP                 NUMBER;
    v_sum                 NUMBER;
    v_agent_report_dav_id NUMBER;
  
  BEGIN
    -- ������� ��� ������ ���������
    -- ��������� ��� ������ ��������� � ��������, ������� �� ���� ���������
    SELECT MIN(tm.date_b)
      INTO v_st_d
      FROM (SELECT t.date_begin  date_b
                  ,t.category_id ag_c
              FROM AG_CONTRACT t
             WHERE t.contract_id = p_ag_contract_header_id
               AND t.date_begin <= LAST_DAY(p_data_begin)) tm
     WHERE tm.ag_c = (SELECT a.ag_category_agent_id FROM AG_CATEGORY_AGENT a WHERE a.brief = 'MN')
       AND NOT EXISTS
     (SELECT '1'
              FROM (SELECT q.date_begin  date_b
                          ,q.category_id ag_c
                      FROM AG_CONTRACT q
                     WHERE q.contract_id = p_ag_contract_header_id
                       AND q.date_begin <= LAST_DAY(p_data_begin)) tt
             WHERE tt.ag_c =
                   (SELECT a.ag_category_agent_id FROM AG_CATEGORY_AGENT a WHERE a.brief = 'AG')
               AND tt.date_b > tm.date_b);
  
    SELECT ah.last_ver_id
          ,ent_id
          ,CEIL(MONTHS_BETWEEN(LAST_DAY(p_data_begin), v_st_d) / 12)
          ,CEIL(MONTHS_BETWEEN(LAST_DAY(p_data_begin), v_st_d))
      INTO v_dr_contract
          ,v_ent_id
          ,v_m
          ,v_mon -- ������ ���������� �������� ��� ���������, ����� ��������, ��� ��������
      FROM ven_ag_contract_header ah
     WHERE ah.ag_contract_header_id = p_ag_contract_header_id;
  
    IF v_mon = 36
    THEN
      -- ��������� ������ � agent_report_dav
      SELECT sq_agent_report_dav.NEXTVAL INTO v_agent_report_dav_id FROM dual;
      av_insert_report_dav(v_agent_report_dav_id
                          ,0
                          ,p_data_begin
                          ,p_report_id
                          ,v_dr_contract
                          ,p_prod_coef_type_id);
    
      -- ���� 4-� ����� ������, ����� ���
      -- �������� �������:
      -- ����� �� �� 2-� ���<=����� �� �� 3-� ���
      SELECT SUM(c.sum_premium)
        INTO v_2y
        FROM ven_ag_vedom_av         v
            ,ven_agent_report        r
            ,ven_agent_report_dav    d
            ,ven_agent_report_dav_ct c
       WHERE v.ag_category_agent_id =
             (SELECT a.ag_category_agent_id FROM AG_CATEGORY_AGENT a WHERE a.brief = 'MN')
         AND v.date_begin BETWEEN ADD_MONTHS(v_st_d, +12) AND ADD_MONTHS(v_st_d, +24) --���� ������� ���������+12 ������� and +24 ������
         AND r.ag_vedom_av_id = v.ag_vedom_av_id
         AND r.agent_report_id = d.agent_report_id
         AND c.agent_report_dav_id = d.agent_report_dav_id
         AND d.prod_coef_type_id IN
             (SELECT p_prod_coef_type_id FROM T_PROD_COEF_TYPE t WHERE t.brief = 'PREM_MENEDG')
         AND r.ag_contract_h_id = p_ag_contract_header_id;
    
      SELECT SUM(c.sum_premium)
        INTO v_3y
        FROM ven_ag_vedom_av         v
            ,ven_agent_report        r
            ,ven_agent_report_dav    d
            ,ven_agent_report_dav_ct c
       WHERE v.ag_category_agent_id =
             (SELECT a.ag_category_agent_id FROM AG_CATEGORY_AGENT a WHERE a.brief = 'MN')
         AND v.date_begin BETWEEN ADD_MONTHS(v_st_d, +25) AND ADD_MONTHS(v_st_d, +37) --���� ������� ���������+25 ������� and +37 ������
         AND r.ag_vedom_av_id = v.ag_vedom_av_id
         AND r.agent_report_id = d.agent_report_id
         AND c.agent_report_dav_id = d.agent_report_dav_id
         AND d.prod_coef_type_id IN
             (SELECT p_prod_coef_type_id FROM T_PROD_COEF_TYPE t WHERE t.brief = 'PREM_MENEDG')
         AND r.ag_contract_h_id = p_ag_contract_header_id;
    
      -- ��� �� 2-� ��� > 85%
      Pkg_Agent_1.KSP_MN(p_ag_contract_header_id
                        ,ADD_MONTHS(v_st_d, +12)
                        , -- ������ 2-�� ����
                         ADD_MONTHS(v_st_d, +24)
                        , -- ����� 2-�� ����
                         v_KSP -- ���
                         );
    
      IF v_ksp > 85
         AND v_2y <= v_3y -- ����� �� �� 2-� ���<=����� �� �� 3-� ���
      THEN
        -- ���� �� �����������
        -- ������� ����� ���. ����������� ������ ��������� 2-�� ����
        SELECT SUM(r.av_sum)
          INTO v_sum
          FROM ven_ag_vedom_av      v
              ,ven_agent_report     r
              ,ven_agent_report_dav d
         WHERE v.ag_category_agent_id =
               (SELECT a.ag_category_agent_id FROM AG_CATEGORY_AGENT a WHERE a.brief = 'MN')
           AND r.ag_vedom_av_id = v.ag_vedom_av_id
           AND r.agent_report_id = d.agent_report_id
           AND d.prod_coef_type_id =
               (SELECT t.t_prod_coef_type_id FROM ven_t_prod_coef_type t WHERE t.brief = 'DP_KV_MN');
      END IF;
      -- ��������� �����
      IF NVL(v_sum, 0) = 0
      THEN
        DELETE FROM ven_agent_report_dav tt3 WHERE tt3.agent_report_dav_id = v_agent_report_dav_id;
      ELSE
        UPDATE AGENT_REPORT_DAV d
           SET d.comission_sum = v_sum
              ,d.ksp           = v_ksp
         WHERE d.agent_report_dav_id = v_agent_report_dav_id;
      END IF;
    END IF;
  END;

  -- ���. ����������� ������ ��������� ������� ���� (����)
  PROCEDURE av_dav_DKPM
  (
    p_vedom_id              IN NUMBER --��� ��������� ������� �������������� ����������
   ,p_report_id             IN NUMBER --��� ������
   ,p_data_begin            IN DATE --���� ������ ��������� �������
   ,p_ag_contract_header_id IN NUMBER --p_ag_id                 --��� ������ ��.��������
   ,p_prod_coef_type_id     IN NUMBER -- ��� �������
   ,p_err_code              OUT NUMBER --������ ���������� �������
  ) IS
    v_st_d                DATE;
    v_dr_contract         NUMBER;
    v_ent_id              NUMBER;
    v_m                   NUMBER;
    v_mon                 NUMBER;
    v_agent_report_dav_id NUMBER;
    v_SGP                 NUMBER;
    v_ag_count            NUMBER;
    v_k_sgp               NUMBER;
    v_sum                 NUMBER;
    v_ag_h_num            VARCHAR2(255);
    v_sgp_sum             NUMBER;
  BEGIN
    -- ��������� ��� ������ ��������� � ��������, ������� �� ���� ���������
    SELECT MIN(tm.date_b)
      INTO v_st_d
      FROM (SELECT t.date_begin  date_b
                  ,t.category_id ag_c
              FROM AG_CONTRACT t
             WHERE t.contract_id = p_ag_contract_header_id
               AND t.date_begin <= LAST_DAY(p_data_begin)) tm
     WHERE tm.ag_c = (SELECT a.ag_category_agent_id FROM AG_CATEGORY_AGENT a WHERE a.brief = 'MN')
       AND NOT EXISTS
     (SELECT '1'
              FROM (SELECT q.date_begin  date_b
                          ,q.category_id ag_c
                      FROM AG_CONTRACT q
                     WHERE q.contract_id = p_ag_contract_header_id
                       AND q.date_begin <= LAST_DAY(p_data_begin)) tt
             WHERE tt.ag_c =
                   (SELECT a.ag_category_agent_id FROM AG_CATEGORY_AGENT a WHERE a.brief = 'AG')
               AND tt.date_b > tm.date_b);
  
    IF (v_st_d < TO_DATE('01.01.2006', 'dd.mm.yyyy'))
    THEN
      v_st_d := TO_DATE('01.01.2006', 'dd.mm.yyyy');
    END IF;
  
    SELECT ah.last_ver_id
          ,ent_id
          ,CEIL(MONTHS_BETWEEN(LAST_DAY(p_data_begin), v_st_d) / 12)
          ,CEIL(MONTHS_BETWEEN(LAST_DAY(p_data_begin), v_st_d))
          ,ah.num
      INTO v_dr_contract
          ,v_ent_id
          ,v_m
          ,v_mon
          , -- ������ ���������� �������� ��� ���������, ����� ��������, ��� ��������
           v_ag_h_num
      FROM ven_ag_contract_header ah
     WHERE ah.ag_contract_header_id = p_ag_contract_header_id;
  
    IF v_m = 2
       AND v_mon IN (15, 18, 21, 24) --���� 2-� ��� �������� � ����� ��������
    THEN
      -- ��������� ������ � agent_report_dav
      SELECT sq_agent_report_dav.NEXTVAL INTO v_agent_report_dav_id FROM dual;
      av_insert_report_dav(v_agent_report_dav_id
                          ,0
                          ,p_data_begin
                          ,p_report_id
                          ,v_dr_contract
                          ,p_prod_coef_type_id);
    
      -- ������� ���
      av_dav_mn_sgp(p_ag_contract_header_id
                   ,ADD_MONTHS(LAST_DAY(p_data_begin), -3)
                   ,LAST_DAY(p_data_begin)
                   ,v_agent_report_dav_id);
    
      -- �������� � ������, �������� ������� ����������
      -- �������� ����
      BEGIN
      
        SELECT ag_count
              ,k_sgp
          INTO v_ag_count
              ,v_k_sgp
          FROM (SELECT *
                  FROM ven_ag_plan_sale s
                 WHERE s.ag_contract_header_id = p_ag_contract_header_id
                      -- ���� ���� ����� �� ���� �������
                   AND (s.date_start BETWEEN ADD_MONTHS(LAST_DAY(p_data_begin), -3) AND
                       LAST_DAY(p_data_begin) OR
                       s.date_start <= ADD_MONTHS(LAST_DAY(p_data_begin), -3))
                   AND s.date_end >= LAST_DAY(p_data_begin)
                 ORDER BY s.date_start)
         WHERE ROWNUM = 1;
      
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          --������ �������� 20.11.07
          v_ag_count := 0;
          v_k_sgp    := 0;
          --      raise_application_error(-20001, '�� ����� ������� ���� ��� ��:'||v_ag_h_num||' � '||to_char(ADD_MONTHS(LAST_DAY(p_data_begin),-3), 'DD.MM.YYYY')||' �� '||to_char(LAST_DAY(p_data_begin), 'DD.MM.YYYY'));
      
      END;
    
      --������� ����������
      IF Pkg_Agent_Rate.ka < v_ag_count
         OR NVL(v_k_sgp, 0) = 0 -- ���� ������� ������ ����������� - �� �����������
      THEN
        v_sum := 0;
      ELSE
        v_sgp_sum          := Pkg_Agent_Rate.SGP;
        Pkg_Agent_Rate.SGP := 100 * Pkg_Agent_Rate.SGP / v_k_sgp;
        -- ���������  �������
        v_sum := Pkg_Tariff_Calc.calc_fun(p_prod_coef_type_id, v_ent_id, p_ag_contract_header_id);
      END IF;
    
      --���� ������ �� ��������, ����� ������� ��� ����������
      IF NVL(v_sum, 0) = 0
      THEN
        DELETE FROM ven_agent_report_dav tt3 WHERE tt3.agent_report_dav_id = v_agent_report_dav_id;
      ELSE
        UPDATE AGENT_REPORT_DAV d
           SET d.comission_sum = v_sum
              ,d.sgp           = v_sgp_sum
              ,d.count_agent   = Pkg_Agent_Rate.ka
              ,d.PER_PLAN      = Pkg_Agent_Rate.SGP
         WHERE d.agent_report_dav_id = v_agent_report_dav_id;
      END IF;
    
      --EXCEPTION   WHEN OTHERS THEN p_err_code:=SQLCODE;
    
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
    
      RAISE_APPLICATION_ERROR(-20001
                             ,'������ ������� (����). (p_ag_contract_header_id=' ||
                              p_ag_contract_header_id || '). ��. ������ Oracle:' || SQLERRM(SQLCODE));
    
  END;

  --���. ������ ��������� ��������� �� ���������� ���������� ������������ ����� ������
  PROCEDURE av_dav_DKP
  (
    p_vedom_id              IN NUMBER --��� ��������� ������� �������������� ����������
   ,p_report_id             IN NUMBER --��� ������
   ,p_data_begin            IN DATE --���� ������ ��������� �������
   ,p_ag_contract_header_id IN NUMBER --p_ag_id                 --��� ������ ��.��������
   ,p_prod_coef_type_id     IN NUMBER -- ��� �������
   ,p_err_code              OUT NUMBER --������ ���������� �������
  ) IS
    v_agent_report_dav_id NUMBER;
    v_k_sgp               NUMBER;
    v_dr_contract         NUMBER;
    v_sum                 NUMBER;
    v_ent_id              NUMBER;
    v_plan                NUMBER;
  BEGIN
    BEGIN
    
      IF TO_CHAR(p_data_begin, 'DD.MM') NOT IN ('01.12', '01.03', '01.06', '01.09')
      THEN
        RETURN;
      END IF;
    
      SELECT ent_id
            ,h.last_ver_id
        INTO v_ent_id
            ,v_dr_contract
        FROM ven_ag_contract_header h
       WHERE ag_contract_header_id = p_ag_contract_header_id;
    
      -- ��������� ������ � agent_report_dav
      SELECT sq_agent_report_dav.NEXTVAL INTO v_agent_report_dav_id FROM dual;
    
      av_insert_report_dav(v_agent_report_dav_id
                          ,0
                          ,p_data_begin
                          ,p_report_id
                          ,v_dr_contract
                          ,p_prod_coef_type_id);
    
      INSERT INTO AGENT_REPORT_DAV_CT
        (agent_report_dav_ct_id, agent_report_dav_id, child_ag_ch_id, policy_id, sgp)
        (SELECT sq_agent_report_dav_ct.NEXTVAL
               ,agent_report_dav_id
               ,ag_contract_header_id
               ,pol
               ,sum_sgp_amount
           FROM ((SELECT v_agent_report_dav_id AS agent_report_dav_id
                        ,h.ag_contract_header_id
                        ,a.POLICY_ID AS pol
                        ,SUM(NVL(a.sgp_amount, 0)) AS sum_sgp_amount
                    FROM ven_ag_contract_header h
                        ,AG_ALL_AGENT_SGP       a
                   WHERE h.agency_id =
                         (SELECT hh.agency_id
                            FROM ven_ag_contract_header hh
                           WHERE hh.ag_contract_header_id = p_ag_contract_header_id)
                     AND h.ag_contract_header_id <> p_ag_contract_header_id -- ������ ��������� �� �������
                     AND h.t_sales_channel_id =
                         (SELECT l.ID FROM T_SALES_CHANNEL l WHERE l.brief = 'MLM')
                     AND a.AG_CONTRACT_HEADER_ID = h.ag_contract_header_id
                     AND (a.date_month = TO_CHAR(ADD_MONTHS(p_data_begin, -2), 'mm.yyyy') OR
                         a.date_month = TO_CHAR(ADD_MONTHS(p_data_begin, -1), 'mm.yyyy') OR
                         a.date_month = TO_CHAR(ADD_MONTHS(p_data_begin, 0), 'mm.yyyy'))
                   GROUP BY h.ag_contract_header_id
                           ,a.POLICY_ID)));
    
      -- ������� ��� ������, ��������
      Pkg_Agent_1.manag_SGP_bank(p_ag_contract_header_id
                                ,ADD_MONTHS(p_data_begin, -3)
                                ,LAST_DAY(p_data_begin)
                                ,v_k_sgp);
      --��������� � �����������, ���� �� ��������
      INSERT INTO ven_agent_report_dav_ct
        (agent_report_dav_ct_id, agent_report_dav_id, child_ag_ch_id, policy_id, sgp)
        SELECT sq_agent_report_dav_ct.NEXTVAL
              ,v_agent_report_dav_id
              ,t.ag_contract_header_id
              ,t.policy_id
              ,t.k_sgp
          FROM AG_STAT_DET_TMP t;
    
      -- �������� ����_�������, ������� � ���������� ��������,
      SELECT NVL(SUM(ct.sgp), 0)
        INTO Pkg_Agent_Rate.SGP
        FROM ven_agent_report_dav_ct ct
       WHERE ct.agent_report_dav_id = v_agent_report_dav_id;
    
      SELECT ( -- �������� ���� �� ��.�������� ���������
              SELECT s.k_sgp
                FROM ven_ag_plan_sale s
               WHERE s.ag_contract_header_id = p_ag_contract_header_id
                 AND s.date_start <= p_data_begin
                 AND s.date_end >= p_data_begin
                 AND ROWNUM = 1)
        INTO v_k_sgp
        FROM dual;
    
      IF v_k_sgp IS NULL
      THEN
        v_sum   := 0;
        v_k_sgp := 0;
      
      ELSE
        v_plan := Pkg_Agent_Rate.SGP;
        -- ��������� ������� ��� ��������� ����� � �������� ������� ��������������
        Pkg_Agent_Rate.SGP := 100 * Pkg_Agent_Rate.SGP / v_k_sgp;
        -- ���������  �������
        v_sum := Pkg_Tariff_Calc.calc_fun(p_prod_coef_type_id, v_ent_id, p_ag_contract_header_id);
      
        UPDATE ven_agent_report_dav a
           SET a.PER_PLAN = Pkg_Agent_Rate.SGP
         WHERE a.AGENT_REPORT_DAV_ID = v_agent_report_dav_id;
      
      END IF;
    
      UPDATE AGENT_REPORT_DAV d
         SET d.comission_sum = v_sum
            ,d.sgp           = v_plan
            ,d.COUNT_POLICY =
             (SELECT COUNT(DISTINCT(c.policy_id))
                FROM AGENT_REPORT_DAV_CT c
               WHERE c.agent_report_dav_id = d.AGENT_REPORT_DAV_ID)
       WHERE d.agent_report_dav_id = v_agent_report_dav_id;
    
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20001
                               ,'������ ������� (���). (p_ag_contract_header_id=' ||
                                p_ag_contract_header_id || '). ��. ������ Oracle:' ||
                                SQLERRM(SQLCODE));
    END;
  END;

  -- �������������� ������ �� ���������� ���������� ����� ��������
  PROCEDURE av_dav_DPR
  (
    p_vedom_id              IN NUMBER --��� ��������� ������� �������������� ����������
   ,p_report_id             IN NUMBER --��� ������
   ,p_data_begin            IN DATE --���� ������ ��������� �������
   ,p_ag_contract_header_id IN NUMBER --��� ��.��������
   ,p_prod_coef_type_id     IN NUMBER -- ��� �������
   ,p_err_code              OUT NUMBER --������ ���������� �������
  ) IS
  
    CURSOR cur_dav
    (
      cv_commision         NUMBER
     ,cv_prod_coef_type_id NUMBER
     ,cv_contract_id       NUMBER
    ) IS
      SELECT 1
        FROM ven_ag_contract      c
            ,ven_agent_report     ar
            ,ven_agent_report_dav d
            ,
             --  ven_agent_report_dav_ct dt,
             ven_t_prod_coef_type ct
       WHERE c.contract_id = cv_contract_id
         AND c.contract_id = ar.ag_contract_h_id
         AND ar.agent_report_id = d.agent_report_id
         AND d.prod_coef_type_id = ct.t_prod_coef_type_id
         AND NVL(d.comission_sum, 0) = cv_commision
         AND ct.t_prod_coef_type_id = cv_prod_coef_type_id;
  
    rec_dav cur_dav%ROWTYPE;
  
    TYPE T_NUMBER IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
    v_summ_v T_NUMBER;
    i        BINARY_INTEGER;
    i_max    BINARY_INTEGER;
    ii       BINARY_INTEGER;
  
    v_ent_id              NUMBER;
    v_rez                 NUMBER;
    v_func_brief          VARCHAR2(200);
    v_dpr                 NUMBER;
    v_sum_dpr             NUMBER;
    v_s                   NUMBER;
    v_agent_report_dav_id NUMBER;
    v_ag_contract_id      NUMBER;
    v_sgp                 NUMBER;
  
    v_count_pol   NUMBER;
    v_count_agent NUMBER;
  
    PROCEDURE insert_dav AS
    BEGIN
    
      SELECT sq_agent_report_dav.NEXTVAL INTO v_agent_report_dav_id FROM dual;
    
      SELECT COUNT(DISTINCT(T.POLICY_ID)) INTO v_count_pol FROM AG_STAT_DET_TMP t;
    
      SELECT COUNT(DISTINCT(T.AG_CONTRACT_HEADER_ID)) INTO v_count_agent FROM AG_STAT_DET_TMP t;
    
      Pkg_Agent_Rate.av_insert_report_dav(v_agent_report_dav_id
                                         , --p_agent_report_dav_id --
                                          v_rez
                                         , --p_dav                 --
                                          p_data_begin
                                         , --p_data_begin          --
                                          p_report_id
                                         , --p_agent_report_id     --
                                          v_ag_contract_id
                                         , --p_ag_id               --
                                          p_prod_coef_type_id
                                         , --p_prod_coef_type_id   --
                                          1
                                         , --p_NUM_MONTH            --
                                          Pkg_Agent_Rate.SGP
                                         , --p_SGP                 --
                                          v_count_pol
                                         , --p_COUNT_POLICY        --
                                          v_count_agent
                                         , --p_COUNT_AGENT         --
                                          NULL
                                         , --p_SUM_PREMIUM         --
                                          NULL --p_KSP                 --
                                          );
    
      --��������� � �����������
      INSERT INTO ven_agent_report_dav_ct
        (agent_report_dav_ct_id, agent_report_dav_id, child_ag_ch_id, policy_id, sgp)
        SELECT sq_agent_report_dav_ct.NEXTVAL
              ,v_agent_report_dav_id
              ,t.ag_contract_header_id
              ,t.policy_id
              ,t.k_sgp
          FROM AG_STAT_DET_TMP t;
    
    END insert_dav;
  
  BEGIN
    SELECT h.ent_id
          ,h.last_ver_id
      INTO v_ent_id
          ,v_ag_contract_id
      FROM ven_ag_contract_header h
     WHERE h.ag_contract_header_id = p_ag_contract_header_id;
  
    /*�������� ���*/
    Pkg_Agent_1.attest_dr_SGP(p_ag_contract_header_id, p_data_begin, LAST_DAY(p_data_begin), v_sgp); /*�� ��������, � ���, ��� ��� ���� ������� ��������� ag_stat_det_tmp (: */
  
    /*����� ��������� NULL - �� ��� �� ����������*/
    Pkg_Agent_Rate.SGP := NVL(v_sgp, 0);
  
    /*���������� ��������� ��� ���������� � ������ ������ ������� ����*/
    v_rez := Pkg_Tariff_Calc.calc_fun(p_prod_coef_type_id, v_ent_id, p_ag_contract_header_id);
  
    IF (v_rez = 0)
    THEN
      insert_dav;
      RETURN;
    END IF;
    /*��������� ���� ����� ���������, ��� �� ��� ����� ���. ���� ���, �� �� ���������. ���� ���, �� ����� ���������*/
    OPEN cur_dav(v_rez, p_prod_coef_type_id, p_ag_contract_header_id);
    FETCH cur_dav
      INTO rec_dav;
  
    IF (cur_dav%FOUND)
    THEN
      v_rez := 0;
    END IF;
  
    insert_dav;
    CLOSE cur_dav;
  
  EXCEPTION
    WHEN OTHERS THEN
    
      RAISE_APPLICATION_ERROR(-20001
                             ,'������ ������� (���). (p_ag_contract_header_id=' ||
                              p_ag_contract_header_id || '). ��. ������ Oracle:' || SQLERRM(SQLCODE));
    
  END;

  --����������� ������ �� ���������� ���������� ����������� ������ ������
  PROCEDURE av_dav_OPD
  (
    p_vedom_id              IN NUMBER --��� ��������� ������� �������������� ����������
   ,p_report_id             IN NUMBER --��� ������
   ,p_data_begin            IN DATE --���� ������ ��������� �������
   ,p_ag_contract_header_id IN NUMBER --p_ag_id                 --��� ������ ��.��������
   ,p_prod_coef_type_id     IN NUMBER -- ��� �������
   ,p_err_code              OUT NUMBER --������ ���������� �������
  ) IS
    v_st_d                DATE;
    v_dr_contract         NUMBER;
    v_ent_id              NUMBER;
    v_m                   NUMBER;
    v_mon                 NUMBER;
    v_2y                  NUMBER;
    v_1y                  NUMBER;
    v_KSP                 NUMBER;
    v_sum                 NUMBER;
    v_agent_report_dav_id NUMBER;
  
  BEGIN
    -- ������� ��� ������ ���������
    -- ��������� ��� ������ ��������� � ��������, ������� �� ���� ���������
    SELECT MIN(tm.date_b)
      INTO v_st_d
      FROM (SELECT t.date_begin  date_b
                  ,t.category_id ag_c
              FROM AG_CONTRACT t
             WHERE t.contract_id = p_ag_contract_header_id
               AND t.date_begin <= LAST_DAY(p_data_begin)) tm
     WHERE tm.ag_c = (SELECT a.ag_category_agent_id FROM AG_CATEGORY_AGENT a WHERE a.brief = 'DR')
       AND NOT EXISTS (SELECT '1'
              FROM (SELECT q.date_begin  date_b
                          ,q.category_id ag_c
                      FROM AG_CONTRACT q
                     WHERE q.contract_id = p_ag_contract_header_id
                       AND q.date_begin <= LAST_DAY(p_data_begin)) tt
             WHERE tt.ag_c IN (SELECT a.ag_category_agent_id
                                 FROM AG_CATEGORY_AGENT a
                                WHERE (a.brief = 'AG' OR a.brief = 'MN'))
               AND tt.date_b > tm.date_b);
  
    SELECT ah.last_ver_id
          ,ent_id
          ,CEIL(MONTHS_BETWEEN(LAST_DAY(p_data_begin), v_st_d) / 12)
          ,CEIL(MONTHS_BETWEEN(LAST_DAY(p_data_begin), v_st_d))
      INTO v_dr_contract
          , --������ ���������� �������� ��� ���������
           v_ent_id
          ,v_m
          , -- ��� ��������
           v_mon -- ����� ��������
      FROM ven_ag_contract_header ah
     WHERE ah.ag_contract_header_id = p_ag_contract_header_id;
  
    --������� �� ��������� 3-�� ���� ������
    IF v_mon = 36
    THEN
      -- ��������� ������ � agent_report_dav
      SELECT sq_agent_report_dav.NEXTVAL INTO v_agent_report_dav_id FROM dual;
      av_insert_report_dav(v_agent_report_dav_id
                          ,0
                          ,p_data_begin
                          ,p_report_id
                          ,v_dr_contract
                          ,p_prod_coef_type_id);
    
      -- ���� 4-� ����� ������, ����� ���
      -- �������� �������:
      -- ����� ��� �� 1-� ���<=����� ��� �� 2-� ���
      SELECT SUM(c.sum_premium)
        INTO v_1y
        FROM ven_ag_vedom_av         v
            ,ven_agent_report        r
            ,ven_agent_report_dav    d
            ,ven_agent_report_dav_ct c
       WHERE v.ag_category_agent_id =
             (SELECT a.ag_category_agent_id FROM AG_CATEGORY_AGENT a WHERE a.brief = 'DR')
         AND v.date_begin BETWEEN v_st_d AND ADD_MONTHS(v_st_d, +12) --���� ������� ��������� and ���� �������+12 ������
         AND r.ag_vedom_av_id = v.ag_vedom_av_id
         AND r.agent_report_id = d.agent_report_id
         AND c.agent_report_dav_id = d.agent_report_dav_id
         AND d.prod_coef_type_id IN
             (SELECT p_prod_coef_type_id
                FROM T_PROD_COEF_TYPE t
               WHERE t.brief IN ('PREM_DIR_GR', 'PREM_DIR'))
         AND r.ag_contract_h_id = p_ag_contract_header_id;
    
      SELECT SUM(c.sum_premium)
        INTO v_2y
        FROM ven_ag_vedom_av         v
            ,ven_agent_report        r
            ,ven_agent_report_dav    d
            ,ven_agent_report_dav_ct c
       WHERE v.ag_category_agent_id =
             (SELECT a.ag_category_agent_id FROM AG_CATEGORY_AGENT a WHERE a.brief = 'DR')
         AND v.date_begin BETWEEN ADD_MONTHS(v_st_d, +13) AND ADD_MONTHS(v_st_d, +25) --���� ������� ���������+13 ������� and +25 ������
         AND r.ag_vedom_av_id = v.ag_vedom_av_id
         AND r.agent_report_id = d.agent_report_id
         AND c.agent_report_dav_id = d.agent_report_dav_id
         AND d.prod_coef_type_id IN
             (SELECT p_prod_coef_type_id
                FROM T_PROD_COEF_TYPE t
               WHERE t.brief IN ('PREM_DIR_GR', 'PREM_DIR'))
         AND r.ag_contract_h_id = p_ag_contract_header_id;
    
      -- ��� �� 1-� ��� > 85%
      Pkg_Agent_1.KSP_DR(p_ag_contract_header_id
                        ,v_st_d
                        , -- ������ 1-�� ����
                         ADD_MONTHS(v_st_d, +12)
                        , -- ����� 1-�� ����
                         v_KSP -- ���
                         );
    
      IF v_ksp > 85
         AND v_1y <= v_2y -- ����� ��� �� 1-� ���<=����� ��� �� 2-� ���
      THEN
        -- ���� �� �����������
        -- ������� ����� ���. ����������� ������ ��������� 2-�� ����
        SELECT SUM(r.av_sum)
          INTO v_sum
          FROM ven_ag_vedom_av      v
              ,ven_agent_report     r
              ,ven_agent_report_dav d
         WHERE v.ag_category_agent_id =
               (SELECT a.ag_category_agent_id FROM AG_CATEGORY_AGENT a WHERE a.brief = 'DR')
           AND r.ag_vedom_av_id = v.ag_vedom_av_id
           AND r.agent_report_id = d.agent_report_id
           AND d.prod_coef_type_id =
               (SELECT t.t_prod_coef_type_id FROM ven_t_prod_coef_type t WHERE t.brief = '���');
      END IF;
      -- ��������� �����
      IF NVL(v_sum, 0) = 0
      THEN
        DELETE FROM ven_agent_report_dav tt3 WHERE tt3.agent_report_dav_id = v_agent_report_dav_id;
      ELSE
        UPDATE AGENT_REPORT_DAV d
           SET d.comission_sum = v_sum
              ,d.ksp           = v_ksp
         WHERE d.agent_report_dav_id = v_agent_report_dav_id;
      END IF;
    END IF;
  END;

  PROCEDURE av_dav_davr
  (
    p_vedom_id    IN NUMBER --��� ��������� ������� �������������� ����������
   ,p_data_begin  IN DATE --���� ������ ��������� �������
   ,p_ag_id       IN NUMBER --��� ������ ��.��������
   ,p_category_id IN NUMBER --��������� ������
   ,p_err_code    IN OUT NUMBER --������ ���������� �������
  ) IS
    v_report_id           NUMBER;
    v_davr                NUMBER;
    v_sum_davr            NUMBER;
    v_date_end            DATE;
    v_max_davr            NUMBER;
    v_max_val             NUMBER;
    sum_dav               NUMBER;
    v_s                   NUMBER;
    v_c                   NUMBER;
    v_ag_h_id             NUMBER;
    v_ent_id              NUMBER;
    v_ent_ag_id           NUMBER;
    v_agent_report_dav_id NUMBER;
    v_t_prod_coef_type_id NUMBER;
    v_cp                  NUMBER;
    v_sv                  NUMBER;
  BEGIN
    SELECT ch.ag_contract_header_id
          ,ch.ent_id
          ,Acc.ent_id
      INTO v_ag_h_id
          ,v_ent_id
          ,v_ent_ag_id
      FROM ven_ag_contract_header ch
          ,ven_ag_contract        Acc
     WHERE ch.ag_contract_header_id = Acc.contract_id
       AND Acc.ag_contract_id = p_ag_id;
  
    SELECT t.t_prod_coef_type_id
      INTO v_t_prod_coef_type_id
      FROM T_PROD_COEF_TYPE t
     WHERE brief = '����';
  
    SELECT re.agent_report_id
      INTO v_report_id
      FROM ven_agent_report re
          ,ven_ag_contract  hh
     WHERE re.ag_vedom_av_id = p_vedom_id
       AND hh.ag_contract_id = p_ag_id
       AND re.ag_contract_h_id = hh.contract_id;
  
    --���������, ��� ��� ������������� ����
    SELECT COUNT(*)
          ,SUM(d.comission_sum)
          ,MAX(av.date_end)
      INTO v_davr
          ,v_sum_davr
          ,v_date_end
      FROM ven_ag_contract      c
          ,ven_agent_report     ar
          ,ven_agent_report_dav d
          ,ven_t_prod_coef_type ct
          ,ven_ag_vedom_av      av
     WHERE c.ag_contract_id = p_ag_id
       AND c.contract_id = ar.ag_contract_h_id
       AND ar.agent_report_id = d.agent_report_id
       AND av.ag_vedom_av_id = ar.ag_vedom_av_id
       AND d.prod_coef_type_id = ct.t_prod_coef_type_id
       AND NVL(d.comission_sum, 0) > 0
       AND ct.brief = '����';
  
    SELECT COUNT(*)
          ,MAX(c.val)
      INTO v_max_davr
          ,v_max_val
      FROM ven_t_prod_coef_type t
          ,ven_t_prod_coef      c
     WHERE t.brief = '����'
       AND c.t_prod_coef_type_id = t.t_prod_coef_type_id
       AND c.val <> 0;
    --������� �� ���������� ����������
    --���� ���-�� ������������ ���� ������ �������������, ����� ������������� �� ���������� ���-��
    IF v_davr >= v_max_davr
    THEN
      --��� ��������� �������� ����� ��� ������� ���
      --���� ������=���� ��������� ��������� �������, ����� ���� �������� ���� � ���� ������
      --���� ��������� = ���� ��������� ��������� �������
      Pkg_Agent_Rate.date_davr_b := v_date_end;
      Pkg_Agent_Rate.date_davr_e := LAST_DAY(p_data_begin);
    
      sum_dav := Pkg_Tariff_Calc.calc_fun('����', v_ent_ag_id, p_ag_id);
      IF sum_dav < v_max_val
      THEN
        sum_dav := 0; --���� ������ 5-�� ����������, ����� �� �������
      ELSE
        --��������� ������ � ������� agent_report_dav
        SELECT sq_agent_report_dav.NEXTVAL INTO v_agent_report_dav_id FROM dual;
        av_insert_report_dav(v_agent_report_dav_id
                            ,sum_dav
                            ,p_data_begin
                            ,v_report_id
                            ,p_ag_id
                            ,v_t_prod_coef_type_id);
        --��������� �����������
        INSERT INTO ven_agent_report_dav_ct
          (agent_report_dav_ct_id, agent_report_dav_id, policy_id, filial_id, child_ag_ch_id, sgp)
          SELECT sq_agent_report_dav_ct.NEXTVAL
                ,v_agent_report_dav_id
                ,TMP.policy_id
                ,TMP.filial_id
                ,TMP.ag_contract_header_id
                ,TMP.k_sgp
            FROM AG_STAT_DET_TMP TMP;
      
      END IF;
    ELSE
      --��� ��������� �������� ����� ��� ������� ���,
      --���� ������=���� ������ �������� ��.�������� -- ������������� � �������
      Pkg_Agent_Rate.date_davr_e := LAST_DAY(p_data_begin);
      --���� ��������� = ���� ��������� ��������� �������
    
      sum_dav := Pkg_Tariff_Calc.calc_fun('����', v_ent_ag_id, p_ag_id);
      --������� �� ����� ���-�� ������ ���������
      SELECT COUNT(*)
            ,SUM(c.val)
        INTO v_cp --���-�� ��������
            ,v_sv --����� ��������
        FROM ven_t_prod_coef_type t
            ,ven_t_prod_coef      c
       WHERE t.brief = '����'
         AND c.t_prod_coef_type_id = t.t_prod_coef_type_id
         AND c.val <= sum_dav
         AND c.val <> 0;
      v_s := NVL(v_sum_davr, 0) - NVL(sum_dav, 0);
      v_c := v_cp - v_davr;
      IF v_s < 0
      THEN
        -- ������ ��� ���������
        FOR v_v IN (SELECT c.val val
                      FROM ven_t_prod_coef_type t
                          ,ven_t_prod_coef      c
                     WHERE t.brief = '����'
                       AND c.t_prod_coef_type_id = t.t_prod_coef_type_id
                       AND c.val <= sum_dav
                       AND c.val <> 0
                    MINUS
                    SELECT d.comission_sum val
                      FROM ven_ag_contract      c
                          ,ven_agent_report     ar
                          ,ven_agent_report_dav d
                          ,ven_t_prod_coef_type ct
                     WHERE c.ag_contract_id = p_ag_id
                       AND c.contract_id = ar.ag_contract_h_id
                       AND ar.agent_report_id = d.agent_report_id
                       AND d.prod_coef_type_id = ct.t_prod_coef_type_id
                       AND NVL(d.comission_sum, 0) > 0
                       AND ct.brief = '����')
        LOOP
          --��������� ������ � ������� agent_report_dav
          SELECT sq_agent_report_dav.NEXTVAL INTO v_agent_report_dav_id FROM dual;
          av_insert_report_dav(v_agent_report_dav_id
                              ,v_v.val
                              ,p_data_begin
                              ,v_report_id
                              ,p_ag_id
                              ,v_t_prod_coef_type_id);
          --��������� �����������
          INSERT INTO ven_agent_report_dav_ct
            (agent_report_dav_ct_id, agent_report_dav_id, policy_id, filial_id, child_ag_ch_id, sgp)
            SELECT sq_agent_report_dav_ct.NEXTVAL
                  ,v_agent_report_dav_id
                  ,TMP.policy_id
                  ,TMP.filial_id
                  ,TMP.ag_contract_header_id
                  ,TMP.k_sgp
              FROM AG_STAT_DET_TMP TMP;
        END LOOP;
      ELSIF v_s >= 0
      THEN
        --�� ������ �������
        sum_dav := 0;
      END IF;
    END IF;
  
  EXCEPTION
    WHEN OTHERS THEN
    
      -- ��� �� ���������????
      RAISE_APPLICATION_ERROR(-20001
                             ,'������ ������� ����������� ��� ��. ��. ������ Oracle ' ||
                              SQLERRM(SQLCODE));
    
  END;

  ---///��������� ���������� ������ ��������������� ���������� �������������� (���) �� ����������� ������
  PROCEDURE av_dav_one
  (
    p_vedom_id    IN NUMBER --��� ��������� ������� �������������� ����������
   ,p_data_begin  IN DATE --���� ������ ��������� �������
   ,p_ag_id       IN NUMBER --��� ������ ��.��������
   ,p_category_id IN NUMBER --��������� ������
   ,p_err_code    IN OUT NUMBER --������ ���������� �������
  ) IS
  
    TYPE T_NUMBER IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
    v_err_num        NUMBER := 0;
    v_report_id      NUMBER := 0;
    v_ag_h_id        NUMBER;
    sum_dav          NUMBER;
    v_ent_id         NUMBER;
    v_cat_br         VARCHAR2(100);
    v_recr           NUMBER;
    v_real_recr      NUMBER;
    v_is_break       NUMBER;
    v_SGP            NUMBER;
    v_SGP_all        NUMBER := 0;
    v_report_dav     ven_agent_report_dav%ROWTYPE;
    v_davr           NUMBER;
    v_max_davr       NUMBER;
    v_sum_davr       NUMBER;
    v_max_val        NUMBER;
    v_cp             NUMBER;
    v_s              NUMBER;
    v_sv             NUMBER;
    v_c              NUMBER;
    v_t_ag_av        NUMBER;
    v_err            NUMBER;
    v_date_end       DATE;
    v_ent_ag_id      NUMBER;
    var_koef         NUMBER;
    v_flag_PBOUL     NUMBER;
    v_sum1           NUMBER;
    v_sgp_min        NUMBER;
    v_date_con_start DATE;
    CURSOR k_dav IS
      SELECT d.ag_dav_id
            ,d.payment_ag_id
            ,d.payment_terms_id
            ,d.prod_coef_type_id
            ,pa.NAME             payment_ag_name
            ,pa.brief            payment_ag_brief
            ,pt.description      payment_terms_name
            ,ct.brief            prod_coef_type_brief
            ,ct.NAME             prod_coef_type_name
        FROM ven_ag_dav           d
            ,ven_t_payment_ag     pa -- ������ �������
            ,ven_t_payment_terms  pt -- ������� �������
            ,ven_t_prod_coef_type ct -- �������
       WHERE d.contract_id = p_ag_id --- ��� ������!!!!!
         AND d.payment_ag_id = pa.t_payment_ag_id
         AND d.payment_terms_id = pt.ID
         AND d.prod_coef_type_id = ct.t_prod_coef_type_id
            --AND ct.brief = '����' --���� ����� ������ ���� ����������� =(((
         AND ct.brief NOT IN ('PREM_MENEDG', 'PREM_DIR', 'PREM_DIR_GR', '���', '���'); -- ��� ������ ������������� � av_pr_all
  
    v_dav k_dav%ROWTYPE;
  
  BEGIN
    Pkg_Ins_Log.SP_EventInfo(1, 'pkg_agent_rate', 'av_dav_one');
    SELECT c.brief
      INTO v_cat_br
      FROM ven_ag_category_agent c
     WHERE c.ag_category_agent_id = p_category_id;
  
    SELECT ch.ag_contract_header_id
          ,ch.ent_id
          ,Acc.ent_id
          ,ch.date_begin
      INTO v_ag_h_id
          ,v_ent_id
          ,v_ent_ag_id
          ,v_date_con_start
      FROM ven_ag_contract_header ch
          ,ven_ag_contract        Acc
     WHERE ch.ag_contract_header_id = Acc.contract_id
       AND Acc.ag_contract_id = p_ag_id;
  
    SELECT t.t_ag_av_id INTO v_t_ag_av FROM T_AG_AV t WHERE t.brief = '���';
  
    Pkg_Agent_Rate.DATE_BG  := p_data_begin;
    Pkg_Agent_Rate.DATE_END := LAST_DAY(p_data_begin);
  
    BEGIN
      --���� �������� �.�. 01.09.2008
      --���� ������ � agent_report
      SELECT ar.agent_report_id
        INTO v_report_id
        FROM ven_agent_report ar
       WHERE ar.ag_vedom_av_id = p_vedom_id
         AND ar.ag_contract_h_id = v_ag_h_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        -- ��������� ������ � agent_report
        v_report_id := Pkg_Agent_Rate.av_insert_report(p_vedom_id, v_ag_h_id, v_t_ag_av, NULL, v_err);
    END;
  
    Pkg_Agent_Rate.TYPE_AV := v_t_ag_av;
    Pkg_Ins_Log.SP_EventInfo(2, 'pkg_agent_rate', 'av_dav_one');
    OPEN k_dav;
    LOOP
      BEGIN
        Pkg_Ins_Log.SP_EventInfo(3, 'pkg_agent_rate', 'av_dav_one');
        FETCH k_dav
          INTO v_dav.ag_dav_id
              ,v_dav.payment_ag_id
              ,v_dav.payment_terms_id
              ,v_dav.prod_coef_type_id
              ,v_dav.payment_ag_name
              ,v_dav.payment_ag_brief
              ,v_dav.payment_terms_name
              ,v_dav.prod_coef_type_brief
              ,v_dav.prod_coef_type_name;
        EXIT WHEN k_dav%NOTFOUND;
        IF v_cat_br = 'AG'
        THEN
          ------- /// ��� ������ 4 ���� ��� ///-----
          IF v_dav.prod_coef_type_brief = '���'
          THEN
            --------���
            BEGIN
              Pkg_Agent_Rate.DATE_BG  := p_data_begin;
              Pkg_Agent_Rate.DATE_END := LAST_DAY(p_data_begin);
              Pkg_Agent_Rate.TYPE_AV  := v_t_ag_av;
              --��������� ������ ���
              Pkg_Agent_Rate.sgp := Pkg_Agent_Rate.get_SGP_av(v_ag_h_id
                                                             ,Pkg_Agent_Rate.date_bg
                                                             ,Pkg_Agent_Rate.type_av);
              var_koef           := Pkg_Agent_Rate.koef_month(v_ag_h_id, Pkg_Agent_Rate.date_bg);
            
              sum_dav := Pkg_Tariff_Calc.calc_fun(v_dav.prod_coef_type_brief, v_ent_id, v_ag_h_id);
              --������ �������� 10.01.2008
              IF var_koef <> 1
              THEN
              
                SELECT ac.leg_pos
                  INTO v_flag_PBOUL
                  FROM ag_contract_header ah
                      ,ag_contract        ac
                 WHERE ac.contract_id = ah.ag_contract_header_id
                   AND ac.ag_contract_id = p_ag_id;
              
                --���� �������� �.�. 15.09.2008 
                --���������� � ����� ������� �������� ������� ��� ��� 1��� ������
                SELECT nvl(MAX(sum_dav), 0) * var_koef
                  INTO sum_dav
                  FROM (SELECT a.criteria_3 + 1 sum_sgp
                              ,lead(a.val, 1, 0) over(ORDER BY a.criteria_3 + 1) sum_dav
                          FROM T_PROD_COEF      a
                              ,T_PROD_COEF_TYPE t
                              ,T_CONTACT_TYPE   c
                         WHERE t.t_prod_coef_type_id = a.t_prod_coef_type_id
                           AND t.brief = '���'
                           AND a.criteria_2 = '3'
                           AND a.criteria_1 = c.ID
                           AND c.brief = DECODE(v_flag_PBOUL, 0, '��', 1, '�����')
                           AND c.is_legal_entity = 0
                           AND c.is_leaf = 1
                         ORDER BY 1)
                 WHERE sum_sgp * var_koef <= Pkg_Agent_Rate.sgp;
              
                /*
                --������ �������� 28.01.08
                SELECT MIN(a.criteria_3 + 1)
                  INTO v_sgp_min
                  FROM T_PROD_COEF a, T_PROD_COEF_TYPE t, T_CONTACT_TYPE c
                 WHERE t.t_prod_coef_type_id = a.t_prod_coef_type_id
                   AND t.brief = '���'
                   AND a.criteria_2 = '3'
                   AND a.criteria_1 = c.ID
                   AND c.brief =
                       DECODE(v_flag_PBOUL, 0, '��', 1, '�����')
                   AND c.is_legal_entity = 0
                   AND c.is_leaf = 1;
                
                IF Pkg_Agent_Rate.sgp > v_sgp_min * var_koef THEN
                
                  SELECT MIN(a.val)
                    INTO v_sum1
                    FROM T_PROD_COEF      a,
                         T_PROD_COEF_TYPE t,
                         T_CONTACT_TYPE   c
                   WHERE t.t_prod_coef_type_id = a.t_prod_coef_type_id
                     AND t.brief = '���'
                     AND a.criteria_2 = '3'
                     AND a.criteria_1 = c.ID
                     AND c.brief =
                         DECODE(v_flag_PBOUL, 0, '��', 1, '�����')
                     AND c.is_legal_entity = 0
                     AND a.val <> 0
                     AND c.is_leaf = 1;
                
                  sum_dav := v_sum1 * var_koef;
                ELSE
                  sum_dav := 0;
                END IF;*/
              
              END IF;
              --------------
              Pkg_Ins_Log.SP_EventInfo(9, 'pkg_agent_rate', 'av_dav_one');
              --   IF NVL(sum_dav, 0) <> 0 THEN  --������ ��������
              -- ��������� �����������
              --��������� ������ � ������� agent_report_dav
              SELECT sq_agent_report_dav.NEXTVAL INTO v_report_dav.agent_report_dav_id FROM dual;
              av_insert_report_dav(v_report_dav.agent_report_dav_id
                                  ,sum_dav
                                  ,p_data_begin
                                  ,v_report_id
                                  ,p_ag_id
                                  ,v_dav.prod_coef_type_id
                                  ,TO_CHAR(CEIL(MONTHS_BETWEEN(Pkg_Agent_Rate.DATE_END
                                                              ,v_date_con_start)))
                                  ,Pkg_Agent_Rate.sgp);
              --IF NVL(sum_dav, 0) <> 0 THEN
              -- ������������ ������ ����������� ��� �� ������� ������������ (!) �������� � �������� ������
              FOR rr IN (SELECT TMP.policy_id
                               ,TMP.k_sgp
                           FROM AG_STAT_DET_TMP TMP
                          WHERE TMP.ag_contract_header_id = v_ag_h_id)
              LOOP
                --   PKG_INS_LOG.SP_EventInfo(10,'pkg_agent_rate','av_dav_one');
                v_is_break := 0;
                IF Doc.get_doc_status_brief(rr.policy_id, LAST_DAY(p_data_begin)) IN ('BREAK')
                THEN
                  -- ������� �������� � ���������� � �������� ������
                  v_SGP := 0; -- ��� �� �����������
                ELSE
                  v_SGP     := rr.k_sgp;
                  v_SGP_all := v_SGP_all + v_SGP; -- ������� ������ ���������� ���
                END IF;
                --��������� �����������
                av_insert_report_dav_ct(v_report_dav.agent_report_dav_id
                                       ,rr.policy_id
                                       ,NULL
                                       ,v_SGP
                                       ,v_is_break
                                       ,NULL
                                       ,NULL
                                       ,NULL
                                       ,NULL
                                       ,NULL
                                       ,NULL
                                       ,NULL
                                       ,NULL
                                       ,NULL);
              END LOOP;
              -- ������������ ������ ����������� ��� �� ������� �������������� (!) �������� � �������� ������
              FOR rr IN /*(SELECT ph.policy_id, dc.sgp
                                                       FROM ag_contract_header ch -- ���� �������� ������
                                                       JOIN p_policy_agent pa ON (pa.ag_contract_header_id =
                                                                                     ch.ag_contract_header_id) -- ������������� �������� ����������� ��� ������� ������
                                                       JOIN p_pol_header ph ON (ph.policy_header_id =
                                                                                   pa.policy_header_id)
                                                       JOIN policy_agent_status pas ON (pa.status_id =
                                                                                           pas.policy_agent_status_id AND
                                                                                           pas.brief IN
                                                                                           ('CURRENT',
                                                                                            'CANCEL')) -- ������ ������ �� ������� �������� �����������
                                                       JOIN agent_report rep ON (rep.ag_contract_h_id =
                                                                                    ch.ag_contract_header_id)
                                                       JOIN agent_report_dav dav ON (dav.agent_report_id =
                                                                                        rep.agent_report_id)
                                                       JOIN agent_report_dav_ct dc ON (dc.agent_report_dav_id =
                                                                                          dav.agent_report_dav_id AND
                                                                                          dc.policy_id =
                                                                                          ph.policy_id)
                                                      WHERE ch.ag_contract_header_id = v_ag_h_id
                                                        AND Doc.get_doc_status_brief(ph.policy_id,
                                                                                     LAST_DAY(p_data_begin)) IN
                                                            ('BREAK')) */
              --������ �������� �.�. 16.09.2008
              --���� ���� ��� ���� ���������� �� ����� ��������
              --��� ��� ��� � �������� ����
              --�� ��� ���� ������ �������� �����
               (SELECT ph.policy_id
                  FROM ag_contract_header ch
                  JOIN p_policy_agent pa
                    ON (pa.ag_contract_header_id = ch.ag_contract_header_id)
                  JOIN p_pol_header ph
                    ON (ph.policy_header_id = pa.policy_header_id)
                  JOIN policy_agent_status pas
                    ON (pa.status_id = pas.policy_agent_status_id)
                 WHERE ch.ag_contract_header_id = v_ag_h_id
                   AND pas.brief IN ('CURRENT', 'CANCEL')
                   AND doc.get_status_date(ph.policy_id, 'BREAK') BETWEEN p_data_begin AND
                       LAST_DAY(p_data_begin))
              LOOP
              
                --������ �������� �.�. 16.09.2008
                SELECT -sum(dc.sgp)
                  INTO v_SGP
                  FROM agent_report        rep
                      ,agent_report_dav    dav
                      ,agent_report_dav_ct dc
                 WHERE dc.policy_id = rr.policy_id
                   AND rep.ag_contract_h_id = v_ag_h_id
                   AND dav.agent_report_id = rep.agent_report_id
                   AND dc.agent_report_dav_id = dav.agent_report_dav_id;
              
                Pkg_Ins_Log.SP_EventInfo(12, 'pkg_agent_rate', 'av_dav_one');
                v_is_break := 1;
                -- ����� ���������� ��� ��������� �����
                --v_SGP := -rr.sgp;
                --��������� �����������
                av_insert_report_dav_ct(v_report_dav.agent_report_dav_id
                                       ,rr.policy_id
                                       ,NULL
                                       ,v_SGP
                                       ,v_is_break
                                       ,NULL
                                       ,NULL
                                       ,NULL
                                       ,NULL
                                       ,NULL
                                       ,NULL
                                       ,NULL
                                       ,NULL
                                       ,NULL);
              END LOOP;
            EXCEPTION
              WHEN OTHERS THEN
              
                RAISE_APPLICATION_ERROR(-20001
                                       ,'������ ������� ���. ��. ������ Oracle ' || SQLERRM(SQLCODE));
            END;
          ELSIF v_dav.prod_coef_type_brief = 'PREM_RECR_AG_FIRST'
          THEN
            ----��������� ������� ������
            BEGIN
              Pkg_Ins_Log.SP_EventInfo(14, 'pkg_agent_rate', 'av_dav_one');
              SELECT COUNT(*) -- ������� ����� ����������� ���� �� ��������� ������� ������
                INTO v_recr
                FROM ag_contract      c
                    ,agent_report     ar
                    ,agent_report_dav d
                    ,t_prod_coef_type ct
               WHERE c.contract_id = v_ag_h_id
                 AND c.contract_id = ar.ag_contract_h_id
                 AND ar.agent_report_id = d.agent_report_id
                 AND d.prod_coef_type_id = ct.t_prod_coef_type_id
                 AND NVL(d.comission_sum, 0) > 0
                 AND ct.brief = 'PREM_RECR_AG_FIRST';
              IF v_recr = 0
              THEN
                -- ��������, ��� ����� �� �������������
                v_real_recr := 0;
              
                -- � ������ ���� 1 ��������������� �����, ����������� ������� �����������
                BEGIN
                  --��������� ������ � ������� agent_report_dav
                  Pkg_Ins_Log.SP_EventInfo(15, 'pkg_agent_rate', 'av_dav_one');
                  SELECT sq_agent_report_dav.NEXTVAL INTO v_report_dav.agent_report_dav_id FROM dual;
                  av_insert_report_dav(v_report_dav.agent_report_dav_id
                                      ,0
                                      ,p_data_begin
                                      ,v_report_id
                                      ,p_ag_id
                                      ,v_dav.prod_coef_type_id);
                  --commit;
                
                  FOR rr IN (SELECT DISTINCT ph.*
                               FROM ag_contract_header ch_2 -- ���� �������� ��������������
                               JOIN p_policy_agent pa
                                 ON (pa.ag_contract_header_id = ch_2.ag_contract_header_id) -- ������������� �������� ����������� ��� ������� ������
                               JOIN p_pol_header ph
                                 ON (ph.policy_header_id = pa.policy_header_id)
                               JOIN policy_agent_status pas
                                 ON (pa.status_id = pas.policy_agent_status_id AND
                                    pas.brief IN ('CURRENT', 'CANCEL')) -- ������ ������ �� ������� �������� �����������
                               JOIN ag_contract ac_2
                                 ON (ch_2.last_ver_id = ac_2.ag_contract_id) -- ����������� ������ �������� ��������������
                               JOIN ag_contract ac_1
                                 ON (ac_1.ag_contract_id = ac_2.contract_recrut_id) -- ������ ��������� ������
                               JOIN t_sales_channel h
                                 ON (h.ID = ch_2.t_sales_channel_id AND h.brief = 'MLM')
                              WHERE Pkg_Agent_1.find_last_ver_id(p_ag_id) =
                                    Pkg_Agent_1.find_last_ver_id(ac_2.contract_recrut_id))
                  LOOP
                    v_real_recr := v_real_recr + 1;
                    --��������� �����������
                    av_insert_report_dav_ct(v_report_dav.agent_report_dav_id
                                           ,rr.policy_id
                                           ,NULL
                                           ,NULL
                                           ,NULL
                                           ,NULL
                                           ,NULL
                                           ,NULL
                                           ,NULL
                                           ,NULL
                                           ,NULL
                                           ,NULL
                                           ,NULL
                                           ,NULL);
                  END LOOP;
                EXCEPTION
                  WHEN OTHERS THEN
                    v_real_recr := 0;
                END;
              
                IF v_real_recr > 0
                THEN
                  sum_dav := Pkg_Tariff_Calc.calc_fun(v_dav.prod_coef_type_brief, v_ent_id, v_ag_h_id);
                ELSE
                  sum_dav := 0;
                END IF;
                -- ���������� ���� ���
                Pkg_Ins_Log.SP_EventInfo(18, 'pkg_agent_rate', 'av_dav_one');
                av_update_report_dav(v_report_dav.agent_report_dav_id, sum_dav, NULL);
                Pkg_Ins_Log.SP_EventInfo(19, 'pkg_agent_rate', 'av_dav_one');
              END IF;
            EXCEPTION
              WHEN OTHERS THEN
              
                RAISE_APPLICATION_ERROR(-20001
                                       ,'������ ������� PREM_RECR_AG_FIRST. ��. ������ Oracle ' ||
                                        SQLERRM(SQLCODE));
            END;
          ELSIF v_dav.prod_coef_type_brief = '����'
          THEN
            BEGIN
              --���������, ��� ��� ������������� ����
              --������ �������� 19.11.07
              SELECT COUNT(*)
                    ,SUM(d.comission_sum)
                    ,MAX(av.date_end)
                INTO v_davr
                    ,v_sum_davr
                    ,v_date_end
                FROM ag_contract_header c
                    ,agent_report       ar
                    ,agent_report_dav   d
                    ,t_prod_coef_type   ct
                    ,ag_vedom_av        av
               WHERE c.ag_contract_header_id = v_ag_h_id
                 AND c.ag_contract_header_id = ar.ag_contract_h_id
                 AND ar.agent_report_id = d.agent_report_id
                 AND av.ag_vedom_av_id = ar.ag_vedom_av_id
                 AND d.prod_coef_type_id = ct.t_prod_coef_type_id
                 AND NVL(d.comission_sum, 0) > 0
                 AND ct.brief = '����';
              Pkg_Ins_Log.SP_EventInfo(21, 'pkg_agent_rate', 'av_dav_one');
              SELECT COUNT(*)
                    ,MAX(c.val)
                INTO v_max_davr
                    ,v_max_val
                FROM ven_t_prod_coef_type t
                    ,ven_t_prod_coef      c
               WHERE t.brief = '����'
                 AND c.t_prod_coef_type_id = t.t_prod_coef_type_id
                 AND c.val <> 0;
              --������� �� ���������� ����������
              --���� ���-�� ������������ ���� ������ �������������, ����� ������������� �� ���������� ���-��
              IF v_davr >= v_max_davr
              THEN
                --��� ��������� �������� ����� ��� ������� ���
                --���� ������=���� ��������� ��������� �������, ����� ���� �������� ���� � ���� ������
                --���� ��������� = ���� ��������� ��������� �������
                Pkg_Agent_Rate.date_davr_b := v_date_end;
                Pkg_Agent_Rate.date_davr_e := LAST_DAY(p_data_begin);
                -- ����������� ��� �� ��������������� �������
              
                Pkg_Agent_Rate.glb_recruit_SGP := Pkg_Agent_1.attest_recruit_SGP(p_ag_id
                                                                                ,Pkg_Agent_Rate.date_davr_e
                                                                                ,Pkg_Agent_Rate.date_davr_b);
                -- ����������� ���-��  ��������������� �������
              
                /*Pkg_Agent_Rate.glb_count_recruit := Pkg_Agent_1.attest_count_recruit(p_ag_id,
                Pkg_Agent_Rate.date_davr_e,
                Pkg_Agent_Rate.date_davr_b);
                */
                sum_dav := Pkg_Tariff_Calc.calc_fun(v_dav.prod_coef_type_brief, v_ent_ag_id, p_ag_id);
                IF sum_dav < v_max_val
                THEN
                  sum_dav := 0; --���� ������ 5-�� ����������, ����� �� �������
                  -- ��� ������� ������� ���������� ������ ��������� ������!!!
                  --��������� ������ � ������� agent_report_dav
                  SELECT sq_agent_report_dav.NEXTVAL INTO v_report_dav.agent_report_dav_id FROM dual;
                  av_insert_report_dav(v_report_dav.agent_report_dav_id
                                      ,sum_dav
                                      ,p_data_begin
                                      ,v_report_id
                                      ,p_ag_id
                                      ,v_dav.prod_coef_type_id
                                      ,p_COUNT_POLICY                   => Pkg_Agent_Rate.glb_count_recruit
                                      ,p_SGP                            => Pkg_Agent_Rate.glb_recruit_SGP);
                  --��������� �����������
                  INSERT INTO ven_agent_report_dav_ct
                    (agent_report_dav_ct_id
                    ,agent_report_dav_id
                    ,
                     
                     policy_id
                    ,filial_id
                    ,child_ag_ch_id
                    ,sgp)
                    SELECT sq_agent_report_dav_ct.NEXTVAL
                          ,v_report_dav.agent_report_dav_id
                          ,TMP.policy_id
                          ,TMP.filial_id
                          ,TMP.ag_contract_header_id
                          ,TMP.k_sgp
                      FROM AG_STAT_DET_TMP TMP;
                ELSE
                  --��������� ������ � ������� agent_report_dav
                  SELECT sq_agent_report_dav.NEXTVAL INTO v_report_dav.agent_report_dav_id FROM dual;
                  av_insert_report_dav(v_report_dav.agent_report_dav_id
                                      ,sum_dav
                                      ,p_data_begin
                                      ,v_report_id
                                      ,p_ag_id
                                      ,v_dav.prod_coef_type_id
                                      ,p_COUNT_POLICY                   => Pkg_Agent_Rate.glb_count_recruit
                                      ,p_SGP                            => Pkg_Agent_Rate.glb_recruit_SGP);
                  --��������� �����������
                  INSERT INTO ven_agent_report_dav_ct
                    (agent_report_dav_ct_id
                    ,agent_report_dav_id
                    ,
                     
                     policy_id
                    ,filial_id
                    ,child_ag_ch_id
                    ,sgp)
                    SELECT sq_agent_report_dav_ct.NEXTVAL
                          ,v_report_dav.agent_report_dav_id
                          ,TMP.policy_id
                          ,TMP.filial_id
                          ,TMP.ag_contract_header_id
                          ,TMP.k_sgp
                      FROM AG_STAT_DET_TMP TMP;
                END IF;
              
              ELSE
                --��� ��������� �������� ����� ��� ������� ���,
                --���� ������=���� ������ �������� ��.�������� -- ������������� � �������
                Pkg_Agent_Rate.date_davr_e := LAST_DAY(p_data_begin);
                -- ����������� ��� �� ��������������� �������
              
                Pkg_Agent_Rate.glb_recruit_SGP := Pkg_Agent_1.attest_recruit_SGP(p_ag_id
                                                                                ,Pkg_Agent_Rate.date_davr_e);
              
                -- ����������� ���-��  ��������������� �������
              
                /* Pkg_Agent_Rate.glb_count_recruit := Pkg_Agent_1.attest_count_recruit(p_ag_id,
                                                                                      Pkg_Agent_Rate.date_davr_e);
                */
                --���� ��������� = ���� ��������� ��������� �������
              
                sum_dav := Pkg_Tariff_Calc.calc_fun(v_dav.prod_coef_type_brief, v_ent_ag_id, p_ag_id);
              
                v_s := NVL(v_sum_davr, 0) - NVL(sum_dav, 0);
                --������� �� ����� ���-�� ������ ���������
                /*           SELECT COUNT(*), SUM(c.val)
                  INTO v_cp --���-�� ��������
                      ,
                       v_sv --����� ��������
                  FROM ven_t_prod_coef_type t, ven_t_prod_coef c
                 WHERE t.brief = '����'
                   AND c.t_prod_coef_type_id = t.t_prod_coef_type_id
                   AND c.val <= sum_dav
                   AND c.val <> 0;
                v_s := NVL(v_sum_davr, 0) - NVL(sum_dav, 0);
                v_c := v_cp - v_davr;*/
                IF v_s < 0
                THEN
                  -- ������ ��� ���������
                  /*                  FOR v_v IN (SELECT c.val val
                    FROM t_prod_coef_type t,
                         t_prod_coef      c
                   WHERE t.brief = '����'
                     AND c.t_prod_coef_type_id =
                         t.t_prod_coef_type_id
                     AND c.val <= sum_dav
                     AND c.val <> 0
                  MINUS
                  SELECT d.comission_sum val
                    FROM ag_contract      c,
                         agent_report     ar,
                         agent_report_dav d,
                         t_prod_coef_type ct
                   WHERE c.contract_id = v_ag_h_id
                     AND c.contract_id = ar.ag_contract_h_id
                     AND ar.agent_report_id = d.agent_report_id
                     AND d.prod_coef_type_id =
                         ct.t_prod_coef_type_id
                     AND NVL(d.comission_sum, 0) > 0
                     AND ct.brief = '����') LOOP*/
                  Pkg_Ins_Log.SP_EventInfo(29, 'pkg_agent_rate', 'av_dav_one');
                  --��������� ������ � ������� agent_report_dav
                  SELECT sq_agent_report_dav.NEXTVAL INTO v_report_dav.agent_report_dav_id FROM dual;
                  av_insert_report_dav(v_report_dav.agent_report_dav_id
                                      ,sum_dav
                                      ,p_data_begin
                                      ,v_report_id
                                      ,p_ag_id
                                      ,v_dav.prod_coef_type_id
                                      ,p_COUNT_POLICY                   => Pkg_Agent_Rate.glb_count_recruit
                                      ,p_SGP                            => Pkg_Agent_Rate.glb_recruit_SGP);
                  --��������� �����������
                  INSERT INTO ven_agent_report_dav_ct
                    (agent_report_dav_ct_id
                    ,agent_report_dav_id
                    ,policy_id
                    ,filial_id
                    ,child_ag_ch_id
                    ,sgp)
                    SELECT sq_agent_report_dav_ct.NEXTVAL
                          ,v_report_dav.agent_report_dav_id
                          ,TMP.policy_id
                          ,TMP.filial_id
                          ,TMP.ag_contract_header_id
                          ,TMP.k_sgp
                      FROM AG_STAT_DET_TMP TMP;
                  Pkg_Ins_Log.SP_EventInfo(30, 'pkg_agent_rate', 'av_dav_one');
                  -- END LOOP;
                ELSIF v_s >= 0
                THEN
                  --�� ������ �������
                  Pkg_Ins_Log.SP_EventInfo(31, 'pkg_agent_rate', 'av_dav_one');
                  sum_dav := 0;
                  --��������� ������ � ������� agent_report_dav
                  SELECT sq_agent_report_dav.NEXTVAL INTO v_report_dav.agent_report_dav_id FROM dual;
                  av_insert_report_dav(v_report_dav.agent_report_dav_id
                                      ,sum_dav
                                      ,p_data_begin
                                      ,v_report_id
                                      ,p_ag_id
                                      ,v_dav.prod_coef_type_id
                                      ,p_COUNT_POLICY                   => Pkg_Agent_Rate.glb_count_recruit
                                      ,p_SGP                            => Pkg_Agent_Rate.glb_recruit_SGP);
                  --��������� �����������
                  INSERT INTO ven_agent_report_dav_ct
                    (agent_report_dav_ct_id
                    ,agent_report_dav_id
                    ,policy_id
                    ,filial_id
                    ,child_ag_ch_id
                    ,sgp)
                    SELECT sq_agent_report_dav_ct.NEXTVAL
                          ,v_report_dav.agent_report_dav_id
                          ,TMP.policy_id
                          ,TMP.filial_id
                          ,TMP.ag_contract_header_id
                          ,TMP.k_sgp
                      FROM AG_STAT_DET_TMP TMP;
                  Pkg_Ins_Log.SP_EventInfo(32, 'pkg_agent_rate', 'av_dav_one');
                END IF;
              END IF;
            EXCEPTION
              WHEN OTHERS THEN
              
                RAISE_APPLICATION_ERROR(-20001
                                       ,'������ ������� ����. ��. ������ Oracle ' || SQLERRM(SQLCODE));
            END;
            ---///////////////////���������� ������� �� ������� ������� ��� ��� �������� ���� ////---------
          ELSIF v_dav.prod_coef_type_brief = '�����'
          THEN
            --�����, �������
            BEGIN
              Pkg_Ins_Log.SP_EventInfo(33, 'pkg_agent_rate', 'av_dav_one');
              av_dav_one_BB(p_vedom_id --��� ��������� ������� �������������� ����������
                           ,v_report_id --��� ������
                           ,p_data_begin --���� ������ ��������� �������
                           ,p_ag_id --��� ������ ��.��������
                           ,v_dav.prod_coef_type_id -- ��� �������
                           ,p_err_code --������ ���������� �������
                            );
              Pkg_Ins_Log.SP_EventInfo(34, 'pkg_agent_rate', 'av_dav_one');
            EXCEPTION
              WHEN OTHERS THEN
              
                RAISE_APPLICATION_ERROR(-20001
                                       ,'������ ������� �����. ��. ������ Oracle ' ||
                                        SQLERRM(SQLCODE));
            END;
          ELSE
            --������
            BEGIN
              Pkg_Ins_Log.SP_EventInfo(35, 'pkg_agent_rate', 'av_dav_one');
              sum_dav := Pkg_Tariff_Calc.calc_fun(v_dav.prod_coef_type_brief, v_ent_id, v_ag_h_id);
              Pkg_Ins_Log.SP_EventInfo(36, 'pkg_agent_rate', 'av_dav_one');
            EXCEPTION
              WHEN OTHERS THEN
              
                RAISE_APPLICATION_ERROR(-20001
                                       ,'������ ������� ������ ���. ��. ������ Oracle ' ||
                                        SQLERRM(SQLCODE));
            END;
          END IF;
        
        ELSIF v_cat_br = 'MN'
        THEN
          -- ��� ���������� 6 ���
        
          --�� ���������� �������� ������ �������� ����� ������
          IF v_dav.prod_coef_type_brief = 'PREM_PLAN_MENG'
          THEN
            -- ������ ������������� �� ��������� ������������ ����
          
            -- �������� ��������
            BEGIN
              Pkg_Ins_Log.SP_EventInfo(37, 'pkg_agent_rate', 'av_dav_one');
              av_dav_MN_PREM_PLAN_MENG(p_vedom_id --��� ��������� ������� �������������� ����������
                                      ,v_report_id --��� ������
                                      ,p_data_begin --���� ������ ��������� �������
                                      ,v_ag_h_id --p_ag_id                 --��� ������ ��.��������
                                      ,v_dav.prod_coef_type_id -- ��� �������
                                      ,p_err_code --������ ���������� �������
                                       );
              Pkg_Ins_Log.SP_EventInfo(38, 'pkg_agent_rate', 'av_dav_one');
            EXCEPTION
              WHEN OTHERS THEN
              
                RAISE_APPLICATION_ERROR(-20001
                                       ,'������ ������� ���. ��. ������ Oracle ' || SQLERRM(SQLCODE));
            END;
            --������ �� ����������� ������, �������� (����)
          ELSIF v_dav.prod_coef_type_brief = '�����'
          THEN
          
            BEGIN
              Pkg_Ins_Log.SP_EventInfo(39, 'pkg_agent_rate', 'av_dav_one');
              av_dav_one_BB(p_vedom_id --��� ��������� ������� �������������� ����������
                           ,v_report_id --��� ������
                           ,p_data_begin --���� ������ ��������� �������
                           ,p_ag_id --��� ������ ��.��������
                           ,v_dav.prod_coef_type_id -- ��� �������
                           ,p_err_code --������ ���������� �������
                            );
              --           PKG_INS_LOG.SP_EventInfo(40,'pkg_agent_rate','av_dav_one');
            EXCEPTION
              WHEN OTHERS THEN
              
                RAISE_APPLICATION_ERROR(-20001
                                       ,'������ ������� �����. ��. ������ Oracle ' ||
                                        SQLERRM(SQLCODE));
            END;
            --������ � ������ ��������� ��������� ��������� ������
          ELSIF v_dav.prod_coef_type_brief = 'DPPM'
          THEN
          
            BEGIN
              -- PKG_INS_LOG.SP_EventInfo(41,'pkg_agent_rate','av_dav_one');
              av_dav_one_DPPM(p_vedom_id --��� ��������� ������� �������������� ����������
                             ,v_report_id --��� ������
                             ,p_data_begin --���� ������ ��������� �������
                             ,v_ag_h_id --p_ag_id                 --��� ������ ��.��������
                             ,v_dav.prod_coef_type_id -- ��� �������
                             ,p_err_code --������ ���������� �������
                              );
              Pkg_Ins_Log.SP_EventInfo(42, 'pkg_agent_rate', 'av_dav_one');
            EXCEPTION
              WHEN OTHERS THEN
              
                RAISE_APPLICATION_ERROR(-20001
                                       ,'������ ������� ����. ��. ������ Oracle ' || SQLERRM(SQLCODE));
            END;
            -- ���. ����������� ������ ��������� ������� ����(����)
          ELSIF v_dav.prod_coef_type_brief = 'DP_KV_MN'
          THEN
          
            BEGIN
              Pkg_Ins_Log.SP_EventInfo(43, 'pkg_agent_rate', 'av_dav_one');
              av_dav_DKPM(p_vedom_id --��� ��������� ������� �������������� ����������
                         ,v_report_id --��� ������
                         ,p_data_begin --���� ������ ��������� �������
                         ,v_ag_h_id --p_ag_id                 --��� ��.��������
                         ,v_dav.prod_coef_type_id -- ��� �������
                         ,p_err_code --������ ���������� �������
                          );
              Pkg_Ins_Log.SP_EventInfo(44, 'pkg_agent_rate', 'av_dav_one');
            EXCEPTION
              WHEN OTHERS THEN
              
                RAISE_APPLICATION_ERROR(-20001
                                       ,'������ ������� ����. ��. ������ Oracle ' || SQLERRM(SQLCODE));
            END;
            --����������� ������ ���������(���)
          ELSIF v_dav.prod_coef_type_brief = '���'
          THEN
          
            BEGIN
              Pkg_Ins_Log.SP_EventInfo(45, 'pkg_agent_rate', 'av_dav_one');
              av_dav_OPM(p_vedom_id --��� ��������� ������� �������������� ����������
                        ,v_report_id --��� ������
                        ,p_data_begin --���� ������ ��������� �������
                        ,v_ag_h_id --p_ag_id                 --��� ������ ��.��������
                        ,v_dav.prod_coef_type_id -- ��� �������
                        ,p_err_code --������ ���������� �������
                         );
              Pkg_Ins_Log.SP_EventInfo(46, 'pkg_agent_rate', 'av_dav_one');
            EXCEPTION
              WHEN OTHERS THEN
              
                RAISE_APPLICATION_ERROR(-20001
                                       ,'������ ������� ���. ��. ������ Oracle ' || SQLERRM(SQLCODE));
            END;
          ELSE
            NULL;
          END IF;
        ELSIF v_cat_br = 'DR'
        THEN
        
          -- ��� ��������� ���
          --���. ������ ��������� �� ���������� ������������ ����� ������
          IF v_dav.prod_coef_type_brief = '���'
          THEN
          
            BEGIN
              Pkg_Ins_Log.SP_EventInfo(47, 'pkg_agent_rate', 'av_dav_one');
              av_dav_DKP(p_vedom_id --��� ��������� ������� �������������� ����������
                        ,v_report_id --��� ������
                        ,p_data_begin --���� ������ ��������� �������
                        ,v_ag_h_id --p_ag_id                 --��� ������ ��.��������
                        ,v_dav.prod_coef_type_id -- ��� �������
                        ,p_err_code --������ ���������� �������
                         );
              Pkg_Ins_Log.SP_EventInfo(48, 'pkg_agent_rate', 'av_dav_one');
            EXCEPTION
              WHEN OTHERS THEN
              
                RAISE_APPLICATION_ERROR(-20001
                                       ,'������ ������� ���. ��. ������ Oracle ' || SQLERRM(SQLCODE));
            END;
            -- �������������� ������ �� ���������� ����� ��������
          ELSIF v_dav.prod_coef_type_brief = '���'
          THEN
          
            BEGIN
              Pkg_Ins_Log.SP_EventInfo(49, 'pkg_agent_rate', 'av_dav_one');
              av_dav_DPR(p_vedom_id --��� ��������� ������� �������������� ����������
                        ,v_report_id --��� ������
                        ,p_data_begin --���� ������ ��������� �������
                        ,v_ag_h_id --p_ag_id                 --��� ������ ��.��������
                        ,v_dav.prod_coef_type_id -- ��� �������
                        ,p_err_code --������ ���������� �������
                         );
              Pkg_Ins_Log.SP_EventInfo(50, 'pkg_agent_rate', 'av_dav_one');
            EXCEPTION
              WHEN OTHERS THEN
              
                RAISE_APPLICATION_ERROR(-20001
                                       ,'������ ������� ���. ��. ������ Oracle ' || SQLERRM(SQLCODE));
            END;
            -- ����������� ������ �� ���������� ����������� ������ ������
          ELSIF v_dav.prod_coef_type_brief = '���'
          THEN
          
            BEGIN
              Pkg_Ins_Log.SP_EventInfo(51, 'pkg_agent_rate', 'av_dav_one');
              av_dav_OPD(p_vedom_id --��� ��������� ������� �������������� ����������
                        ,v_report_id --��� ������
                        ,p_data_begin --���� ������ ��������� �������
                        ,v_ag_h_id --p_ag_id                 --��� ������ ��.��������
                        ,v_dav.prod_coef_type_id -- ��� �������
                        ,p_err_code --������ ���������� �������
                         );
              Pkg_Ins_Log.SP_EventInfo(52, 'pkg_agent_rate', 'av_dav_one');
            EXCEPTION
              WHEN OTHERS THEN
              
                RAISE_APPLICATION_ERROR(-20001
                                       ,'������ ������� ���. ��. ������ Oracle ' || SQLERRM(SQLCODE));
            END;
          END IF;
        ELSE
          NULL;
        
        END IF;
      
        --  av_update_report ( p_vedom_id, v_ag_h_id, p_err_code) ;
      
      EXCEPTION
        WHEN OTHERS THEN
          -- � � ����!!
          RAISE_APPLICATION_ERROR(-20001
                                 ,'������ ������� ��� (p_ag_id: ' || p_ag_id ||
                                  '). ��. ������ Oracle ' || SQLERRM(SQLCODE));
      END;
      Pkg_Ins_Log.SP_EventInfo(52, 'pkg_agent_rate', 'av_dav_one');
    END LOOP;
    Pkg_Ins_Log.SP_EventInfo(53, 'pkg_agent_rate', 'av_dav_one');
    --������ ��� ��������� ��� ���������??????
    --av_update_report(p_vedom_id, v_ag_h_id, p_err_code);
    Pkg_Ins_Log.SP_EventInfo(54, 'pkg_agent_rate', 'av_dav_one');
  END;
  ------------------------------------------------------------------------------

  -----------------------------------------------------------------------------
  ---/// ��������� ���������� ������ ������� ��� ������� ��������� ���������� �������������� (���)
  PROCEDURE av_oav_all
  (
    p_vedom_id    IN NUMBER --��� ��������� ������� �������������� ����������
   ,p_data_begin  IN DATE --���� ������ ��������� �������
   ,p_category_id IN NUMBER --��������� ������
   ,p_type_av     IN NUMBER --��� ���� ���������� �������������� (T_AG_AV_ID)
   ,p_ag_head_id  IN NUMBER DEFAULT NULL --��� ���������� ��������
   ,p_err_code    IN OUT NUMBER --������ ���������� �������
  ) IS
    -- ����������� ��������� �������, �� ������� ����� ���������� ��������������
    -- (�������: ����� �� ���� ��������� ��������� ������� ��� � �����. ���������,
    -- ���� �������� ����������� � ������, ��� ����� �� � ������� ����� � ���� ��������� >= ������ �������(�.�. �� ���������� �� ������ �������)),
    v_rez     NUMBER := 0; -- ��������� ���������� ��������
    Sid       NUMBER;
    cur_count NUMBER;
  BEGIN
    DELETE FROM TMP_FOR_AGENT_RATE;
    INSERT INTO TMP_FOR_AGENT_RATE
      (SELECT pa.p_policy_agent_id
             ,c.method_payment
             ,ch.ag_contract_header_id
         FROM ven_ag_contract         c
             ,ven_ag_contract_header  ch
             ,ven_p_policy_agent      pa
             ,ven_policy_agent_status ps
             ,ven_t_sales_channel     ts
        WHERE Pkg_Agent_1.get_status_by_date(ch.ag_contract_header_id, LAST_DAY(p_data_begin)) =
              c.ag_contract_id
          AND pa.ag_contract_header_id = ch.ag_contract_header_id
          AND pa.ag_contract_header_id = NVL(p_ag_head_id, pa.ag_contract_header_id) -- �� ������ ������ / �� ����
          AND pa.status_id = ps.policy_agent_status_id
          AND (ps.brief IN ('CURRENT', 'CANCEL') --����� ���������� ��� ��������� �� ���� ��������� �������
               AND pa.date_end > p_data_begin AND --������ �������� 29.01.2008
               pa.date_start <= LAST_DAY(p_data_begin))
          AND c.category_id = p_category_id
          AND ch.t_sales_channel_id = ts.id
             --�������� �.�. 21/10/2008 
             --���� ��������� � ����� � ���������� � ������ ������, ���������, ���
             --������ �.�. 09,12,2009 �� ������ 54234
             --��� ������ � �������� ����� ������ ����������� � �������������� ��
          AND ((ts.brief = decode(p_type_av, 44, 'BANK', 45, 'BR', 46, 'CORPORATE', '!NONE!') AND
               Doc.get_doc_status_brief(ch.ag_contract_header_id, LAST_DAY(p_data_begin)) IN
               ('CURRENT', 'RESUME')) OR
               (p_type_av = 41 AND
               ent.obj_name('DEPARTMENT', ch.agency_id) <> '������� ������ � ���������') AND
               Doc.get_doc_status_brief(ch.ag_contract_header_id, LAST_DAY(p_data_begin)) IN
               ('CURRENT', 'PRINTED', 'RESUME')));
  
    SELECT sid INTO SID FROM v$session WHERE audsid = userenv('sessionid');
  
    SELECT COUNT(*) INTO cur_count FROM TMP_FOR_AGENT_RATE;
    --  dbms_output.put_line('111');
    FOR v_r IN (SELECT A1 p_policy_agent_id
                      ,a2 method_payment
                      ,a3 ag_contract_header_id
                  FROM TMP_FOR_AGENT_RATE)
    LOOP
    
      pkg_renlife_utils.time_elapsed('����� ������ ��� �� ag_header ' || v_r.ag_contract_header_id
                                    ,sid
                                    ,cur_count);
    
      -- ����� ��������� �� ������� ��� �� ����������� ������
      av_oav_one(p_vedom_id
                ,p_data_begin
                ,v_r.p_policy_agent_id
                ,v_r.method_payment
                ,p_category_id
                ,p_err_code);
      -- ����� ��������� ������ �������� ���� �� � ������ �������� � ������� agent_report
      av_update_report(p_vedom_id, v_r.ag_contract_header_id, p_err_code);
    
    END LOOP;
    --������� ��� ��� ��� ����������� �� ���� ���������
    DELETE FROM AGENT_REPORT r
     WHERE r.ag_vedom_av_id = p_vedom_id
       AND NOT EXISTS (SELECT c.agent_report_cont_id
              FROM ven_agent_report_cont c
             WHERE c.agent_report_id = r.agent_report_id);
  EXCEPTION
    WHEN OTHERS THEN
    
      RAISE_APPLICATION_ERROR(-20001
                             ,'������ ������� ���. ��. ������ Oracle:' || SQLERRM(SQLCODE));
    
  END;

  /** ������ ������ ��� ���������� � ���������� �� �������� � ���
  *
  *
  */

  PROCEDURE av_pr_all
  (
    p_vedom_id    IN NUMBER --��� ��������� ������� �������������� ����������
   ,p_data_begin  IN DATE --���� ������ ��������� �������
   ,p_category_id IN NUMBER --brief ��������� ������
   ,p_ag_head_id  IN NUMBER DEFAULT NULL --��� ���������� ��������
   ,p_err_code    IN OUT NUMBER --������ ���������� �������
  ) IS
    -- ����������� ��������� �������, �� ������� ����� ���������� ��������������
    -- (�������: ����� �� ���� ��������� ��������� ������� ��� � �����. ���������,
    CURSOR k_ag_contr IS
      SELECT ch.ag_contract_header_id
            ,c.ag_contract_id
        FROM ven_ag_contract        c
            ,ven_ag_contract_header ch
       WHERE Pkg_Agent_1.get_status_by_date(ch.ag_contract_header_id, LAST_DAY(p_data_begin)) =
             c.ag_contract_id
         AND ch.ag_contract_header_id = NVL(p_ag_head_id, ch.ag_contract_header_id) -- �� ������ ������ / �� ����
         AND c.category_id = p_category_id
         AND Doc.get_doc_status_brief(ch.ag_contract_header_id, LAST_DAY(p_data_begin)) IN
             ('CURRENT', 'PRINTED', 'RESUME')
         AND NOT EXISTS (SELECT '1'
                FROM AG_CONTRACT ac
               WHERE ac.contract_id = ch.ag_contract_header_id
                 AND ac.ag_contract_templ_id = ch.ag_contract_templ_id) --!!! ������� ���������, ���� ��������� �� ���������� ������ ����������� �� ��������
         AND ch.ag_contract_templ_k = 0;
  
    v_cat_brief  VARCHAR2(100);
    v_t_ag_av_id NUMBER;
    v_ag_contr   k_ag_contr%ROWTYPE;
    v_report_id  NUMBER;
    v_err        NUMBER;
  BEGIN
    Pkg_Agent_Rate.DATE_BG  := p_data_begin;
    Pkg_Agent_Rate.DATE_END := LAST_DAY(p_data_begin);
  
    SELECT c.brief
      INTO v_cat_brief
      FROM ven_ag_category_agent c
     WHERE c.ag_category_agent_id = p_category_id;
  
    SELECT t.t_ag_av_id INTO v_t_ag_av_id FROM ven_t_ag_av t WHERE t.brief = '��';
  
    /*�������*/
    OPEN k_ag_contr;
    LOOP
      FETCH k_ag_contr
        INTO v_ag_contr.ag_contract_header_id
            ,v_ag_contr.ag_contract_id;
      EXIT WHEN k_ag_contr%NOTFOUND;
      -- ��������� ������ � agent_report
      v_report_id := Pkg_Agent_Rate.av_insert_report(p_vedom_id
                                                    ,v_ag_contr.ag_contract_header_id
                                                    ,v_t_ag_av_id
                                                    ,NULL
                                                    ,v_err);
    
      IF v_cat_brief = 'MN'
      THEN
        --������� 'PREM_MENEDG', '���'
        FOR v_r IN (SELECT d.ag_dav_id
                          ,d.payment_ag_id
                          ,d.payment_terms_id
                          ,d.prod_coef_type_id
                          ,pa.NAME             payment_ag_name
                          ,pa.brief            payment_ag_brief
                          ,pt.description      payment_terms_name
                          ,ct.brief            prod_coef_type_brief
                          ,ct.NAME             prod_coef_type_name
                      FROM ven_ag_dav           d
                          ,ven_t_payment_ag     pa -- ������ �������
                          ,ven_t_payment_terms  pt -- ������� �������
                          ,ven_t_prod_coef_type ct -- �������
                     WHERE d.contract_id = v_ag_contr.ag_contract_id
                       AND d.payment_ag_id = pa.t_payment_ag_id
                       AND d.payment_terms_id = pt.ID
                       AND d.prod_coef_type_id = ct.t_prod_coef_type_id
                       AND ct.brief IN ('PREM_MENEDG', '���'))
        
        LOOP
          IF v_r.prod_coef_type_brief = 'PREM_MENEDG'
          THEN
            av_pr_mn_gr(p_vedom_id
                       ,v_report_id
                       ,p_data_begin
                       ,v_ag_contr.ag_contract_header_id
                       ,v_r.prod_coef_type_id
                       ,v_t_ag_av_id
                       ,v_err);
          ELSIF v_r.prod_coef_type_brief = '���'
          THEN
            -- ����� �� �������
            NULL;
          ELSE
            NULL;
          END IF;
        END LOOP;
      END IF;
    
    END LOOP;
    CLOSE k_ag_contr;
  
    ------------------------------------------------------------------------------
  
    /*���*/
    OPEN k_ag_contr;
    LOOP
      FETCH k_ag_contr
        INTO v_ag_contr.ag_contract_header_id
            ,v_ag_contr.ag_contract_id;
      EXIT WHEN k_ag_contr%NOTFOUND;
    
      -- ��������� ������ � agent_report
      SELECT a.AGENT_REPORT_ID
        INTO v_report_id
        FROM AGENT_REPORT a
       WHERE a.AG_CONTRACT_H_ID = v_ag_contr.ag_contract_header_id
         AND a.AG_VEDOM_AV_ID = p_vedom_id
         AND a.T_AG_AV_ID = v_t_ag_av_id;
    
      IF v_cat_brief = 'MN'
      THEN
        --������� '���'
        FOR v_r IN (SELECT d.ag_dav_id
                          ,d.payment_ag_id
                          ,d.payment_terms_id
                          ,d.prod_coef_type_id
                          ,pa.NAME             payment_ag_name
                          ,pa.brief            payment_ag_brief
                          ,pt.description      payment_terms_name
                          ,ct.brief            prod_coef_type_brief
                          ,ct.NAME             prod_coef_type_name
                      FROM ven_ag_dav           d
                          ,ven_t_payment_ag     pa -- ������ �������
                          ,ven_t_payment_terms  pt -- ������� �������
                          ,ven_t_prod_coef_type ct -- �������
                     WHERE d.contract_id = v_ag_contr.ag_contract_id
                       AND d.payment_ag_id = pa.t_payment_ag_id
                       AND d.payment_terms_id = pt.ID
                       AND d.prod_coef_type_id = ct.t_prod_coef_type_id
                       AND ct.brief IN ('PREM_MENEDG', '���'))
        
        LOOP
          IF v_r.prod_coef_type_brief = '���'
          THEN
            av_pr_mn_recr(p_vedom_id --��� ��������� ������� �������������� ����������
                         ,v_report_id --��� ����
                         ,p_data_begin --���� ������ ��������� �������
                         ,v_ag_contr.ag_contract_header_id --��� ���������� �������� ���������
                         ,v_r.prod_coef_type_id --��� �������
                         ,v_err --������ ���������� �������
                          );
          END IF;
        END LOOP;
      END IF;
    END LOOP;
    CLOSE k_ag_contr;
  
    ------------------------------------------------------------------------------
  
    /*����������*/
    OPEN k_ag_contr;
    LOOP
      FETCH k_ag_contr
        INTO v_ag_contr.ag_contract_header_id
            ,v_ag_contr.ag_contract_id;
      EXIT WHEN k_ag_contr%NOTFOUND;
    
      SELECT a.AGENT_REPORT_ID
        INTO v_report_id
        FROM AGENT_REPORT a
       WHERE a.AG_CONTRACT_H_ID = v_ag_contr.ag_contract_header_id
         AND a.AG_VEDOM_AV_ID = p_vedom_id
         AND a.T_AG_AV_ID = v_t_ag_av_id;
    
      IF v_cat_brief = 'DR'
      THEN
        --������� 'PREM_DIR', 'PREM_DIR_GR'
        FOR v_d IN (SELECT d.ag_dav_id
                          ,d.payment_ag_id
                          ,d.payment_terms_id
                          ,d.prod_coef_type_id
                          ,pa.NAME             payment_ag_name
                          ,pa.brief            payment_ag_brief
                          ,pt.description      payment_terms_name
                          ,ct.brief            prod_coef_type_brief
                          ,ct.NAME             prod_coef_type_name
                      FROM ven_ag_dav           d
                          ,ven_t_payment_ag     pa -- ������ �������
                          ,ven_t_payment_terms  pt -- ������� �������
                          ,ven_t_prod_coef_type ct -- �������
                     WHERE d.contract_id = v_ag_contr.ag_contract_id
                       AND d.payment_ag_id = pa.t_payment_ag_id
                       AND d.payment_terms_id = pt.ID
                       AND d.prod_coef_type_id = ct.t_prod_coef_type_id
                       AND ct.brief IN ('PREM_DIR', 'PREM_DIR_GR', '���'))
        LOOP
          IF v_d.prod_coef_type_brief = 'PREM_DIR'
          THEN
            av_pr_Dr_gr(p_vedom_id
                       ,v_report_id
                       ,p_data_begin
                       ,v_ag_contr.ag_contract_header_id
                       ,v_d.prod_coef_type_id
                       ,v_err);
          ELSIF v_d.prod_coef_type_brief = 'PREM_DIR_GR'
          THEN
            av_pr_DR_AG(p_vedom_id
                       ,v_report_id
                       ,p_data_begin
                       ,v_ag_contr.ag_contract_header_id
                       ,v_d.prod_coef_type_id
                       ,v_err);
          ELSIF v_d.prod_coef_type_brief = '���'
          THEN
            av_pr_dr_recr(p_vedom_id --��� ��������� ������� �������������� ����������
                         ,v_report_id
                         ,p_data_begin
                         ,v_ag_contr.ag_contract_header_id
                         ,v_d.prod_coef_type_id
                         ,v_err);
          
          END IF;
        END LOOP;
      END IF;
    
    END LOOP;
    CLOSE k_ag_contr;
  
    --��������� ������
    av_update_report(p_vedom_id, NULL, p_err_code);
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20001
                             ,'������ ������� ������. ��. ������ Oracle:' || SQLERRM(SQLCODE));
  END;
  -----------------------------------------------------------------------------

  ---/// ��������� ���������� ������ ������� ��� ������� ��������������� ���������� �������������� (���)
  PROCEDURE av_dav_all
  (
    p_vedom_id    IN NUMBER --��� ��������� ������� �������������� ����������
   ,p_data_begin  IN DATE --���� ������ ��������� �������
   ,p_category_id IN NUMBER --brief ��������� ������
   ,p_ag_head_id  IN NUMBER DEFAULT NULL --��� ���������� ��������
   ,p_err_code    IN OUT NUMBER --������ ���������� �������
  ) IS
    -- ����������� ��������� �������, �� ������� ����� ���������� ��������������
    -- (�������: ����� �� ���� ��������� ��������� ������� ��� � �����. ���������,
    Sid       NUMBER;
    cur_count NUMBER;
    CURSOR k_ag_contr IS
      SELECT ch.ag_contract_header_id
            ,c.ag_contract_id
        FROM ven_ag_contract        c
            ,ven_ag_contract_header ch
            ,t_sales_channel        ts
       WHERE Pkg_Agent_1.get_status_by_date(ch.ag_contract_header_id, Pkg_Agent_Rate.DATE_END) =
             c.ag_contract_id
         AND ch.ag_contract_header_id = NVL(p_ag_head_id, ch.ag_contract_header_id) -- �� ������ ������ / �� ����
         AND c.category_id = p_category_id
            --�������� �.�. 03.09.2008 ����� ������������ ���� ������� � �� ���� ��������� �������
         AND Doc.get_doc_status_brief(ch.ag_contract_header_id, SYSDATE) IN
             ('CURRENT', 'PRINTED', 'RESUME')
            --�������� �.�. 03.09.2008 ����������� �� ���� ������ ��
         AND ch.date_begin <= last_day(p_data_begin)
         AND ch.ag_contract_templ_k = 0
         AND ts.id = ch.t_sales_channel_id
         AND ts.brief = 'MLM';
    v_ag_contr k_ag_contr%ROWTYPE;
    v_rez      NUMBER := 0; -- ��������� ���������� ��������
  
  BEGIN
    Pkg_Agent_Rate.DATE_BG  := p_data_begin;
    Pkg_Agent_Rate.DATE_END := LAST_DAY(p_data_begin);
  
    SELECT COUNT(ch.ag_contract_header_id)
      INTO cur_count
      FROM ven_ag_contract        c
          ,ven_ag_contract_header ch
          ,t_sales_channel        ts
     WHERE Pkg_Agent_1.get_status_by_date(ch.ag_contract_header_id, Pkg_Agent_Rate.DATE_END) =
           c.ag_contract_id
       AND ch.ag_contract_header_id = NVL(p_ag_head_id, ch.ag_contract_header_id) -- �� ������ ������ / �� ����
       AND c.category_id = p_category_id
          --�������� �.�. 03.09.2008 ����� ������������ ���� ������� � �� ���� ��������� �������
       AND Doc.get_doc_status_brief(ch.ag_contract_header_id, SYSDATE) IN
           ('CURRENT', 'PRINTED', 'RESUME')
          --�������� �.�. 03.09.2008 ����������� �� ���� ������ ��
       AND ch.date_begin <= last_day(p_data_begin)
       AND ch.ag_contract_templ_k = 0
       AND ts.id = ch.t_sales_channel_id
       AND ts.brief = 'MLM';
  
    SELECT sid INTO SID FROM v$session WHERE audsid = userenv('sessionid');
  
    OPEN k_ag_contr;
    LOOP
      FETCH k_ag_contr
        INTO v_ag_contr.ag_contract_header_id
            ,v_ag_contr.ag_contract_id;
      EXIT WHEN k_ag_contr%NOTFOUND;
      -- ����� ��������� �� ������� ��� �� ����������� ������
    
      pkg_renlife_utils.time_elapsed('����� ������ ��� �� ag_header ' || v_ag_contr.ag_contract_id
                                    ,sid
                                    ,cur_count);
    
      av_dav_one(p_vedom_id, p_data_begin, v_ag_contr.ag_contract_id, p_category_id, p_err_code);
    
    END LOOP;
    --
    av_update_report(p_vedom_id, NULL, p_err_code);
    CLOSE k_ag_contr;
  END;
  -----------------------------------------------------------

  ---/// �������� ��������� ������� ���������� ��������������
  PROCEDURE av_main
  (
    p_vedom_id    IN NUMBER --��� ��������� ������� �������������� ����������
   ,p_data_begin  IN DATE --���� ������ ��������� �������
   ,p_category_id IN NUMBER --��������� ������
   ,p_type_av     IN NUMBER --��� ���� ���������� �������������� (T_AG_AV_ID)
   ,p_ag_head_id  IN NUMBER DEFAULT NULL --��� ���������� ��������
   ,p_err_code    IN OUT NUMBER --��� ������ ���������� �������
   ,p_data_end    IN DATE DEFAULT NULL
  ) IS
  
    v_err_num        NUMBER := 0;
    v_category_brief VARCHAR2(100);
    v_type_brief     VARCHAR2(100);
  BEGIN
  
    -- ����������� BRIEF ���� ��������������
    BEGIN
      SELECT ta.brief INTO v_type_brief FROM ven_t_ag_av ta WHERE ta.t_ag_av_id = p_type_av;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20001
                               ,'����������� BRIEF ���� �������������� ' || SQLERRM);
        --v_err_num:=sqlcode;
    END;
    --
    -- ������ ���������� ��. �� ������� ������ ������ ��������� ��, � ������ ���!
    -- ���������� ��� ��� �������� � FORMS � �������� ������� ��� ����.
    BEGIN
      DELETE FROM ven_agent_report r
       WHERE r.ag_vedom_av_id = p_vedom_id
         AND r.ag_contract_h_id = NVL(p_ag_head_id, r.ag_contract_h_id)
         AND doc.get_doc_status_brief(r.AGENT_REPORT_ID) = 'NEW';
    EXCEPTION
      WHEN OTHERS THEN
      
        RAISE_APPLICATION_ERROR(SQLCODE
                               ,'���������� ������� ���������� ������ ' || SQLERRM(SQLCODE));
      
    END;
  
    -- ����� �������� � ����������� �� ������� ����������
    IF v_type_brief = '���'
    THEN
      av_oav_all(p_vedom_id, p_data_begin, p_category_id, p_type_av, p_ag_head_id, p_err_code);
    ELSIF v_type_brief = '���'
    THEN
      av_dav_all(p_vedom_id, p_data_begin, p_category_id, p_ag_head_id, p_err_code);
    ELSIF v_type_brief = '��'
    THEN
      av_pr_all(p_vedom_id, p_data_begin, p_category_id, p_ag_head_id, p_err_code);
    ELSE
      NULL;
    END IF;
    DELETE FROM ven_agent_report r
     WHERE r.ag_vedom_av_id = p_vedom_id
       AND r.ag_contract_h_id = NVL(p_ag_head_id, r.ag_contract_h_id)
       AND doc.get_doc_status_brief(r.AGENT_REPORT_ID) = 'NEW'
       AND EXISTS (SELECT '1'
              FROM VEN_AGENT_REPORT r1
             WHERE r1.ag_contract_h_id = r.ag_contract_h_id
               AND r1.ag_vedom_av_id = p_vedom_id
               AND doc.get_doc_status_brief(r1.AGENT_REPORT_ID) <> 'NEW');
  EXCEPTION
    WHEN OTHERS THEN
      p_err_code := SQLCODE;
  END;
  ------------------------------------------------------------------------

  PROCEDURE main IS
  BEGIN
    FOR agent_rate_row IN (SELECT * FROM v_agent_rate)
    LOOP
      NULL;
    END LOOP;
  END;

  FUNCTION create_new_act
  (
    p_Start_Date            DATE DEFAULT NULL
   ,p_End_Date              DATE DEFAULT SYSDATE
   ,p_Ag_Contract_Header_ID NUMBER
  ) RETURN NUMBER IS
    v_Document_ID NUMBER;
    var_Doc_Templ DOC_TEMPL%ROWTYPE;
    v_Count       NUMBER;
    v_Result      NUMBER;
  BEGIN
  
    --���������� ����������� ����� ������� � ����
    SELECT COUNT(*)
      INTO v_Count
      FROM v_Agent_Com_Payment acp
     WHERE acp.ag_contract_header_id = p_Ag_Contract_Header_ID
       AND ((p_Start_Date IS NULL) OR (p_Start_Date IS NOT NULL) AND (acp.trans_date >= p_Start_Date))
       AND (acp.trans_date < p_End_Date + 1);
  
    IF v_Count > 0
    THEN
      SELECT * INTO var_Doc_Templ FROM DOC_TEMPL t WHERE t.brief = 'ACT_AGENT';
    
      -- ������������ ��� ����������� ����� ������
      SELECT sq_document.NEXTVAL INTO v_Document_ID FROM dual;
      INSERT INTO DOCUMENT d
        (d.document_id, d.ent_id, d.num, d.doc_templ_id, d.reg_date)
      VALUES
        (v_Document_ID, var_Doc_Templ.Doc_Ent_Id, v_Document_ID, var_Doc_Templ.Doc_Templ_Id, SYSDATE);
      INSERT INTO AGENT_REPORT ar
        (ar.agent_report_id, ar.report_date, ar.ag_contract_h_id, ar.start_date)
      VALUES
        (v_Document_ID, p_End_Date, p_Ag_Contract_Header_ID, p_start_date);
      FOR rcd IN (SELECT *
                    FROM v_Agent_Com_Payment acp
                   WHERE ((p_Start_Date IS NULL) OR
                         (p_Start_Date IS NOT NULL) AND (acp.trans_date >= p_Start_Date))
                     AND (acp.trans_date < p_End_Date + 1)
                     AND (acp.ag_contract_header_id = p_Ag_Contract_Header_ID))
      LOOP
        INSERT INTO AGENT_REPORT_CONT arc
          (arc.agent_report_cont_id
          ,arc.comission_sum
          ,arc.agent_report_id
          ,arc.is_deduct
          ,arc.p_policy_agent_com_id
          ,arc.trans_id)
        VALUES
          (sq_agent_report_cont.NEXTVAL
          ,CASE WHEN
           rcd.ag_type_defin_rate_brief = 'CONSTANT' AND rcd.ag_type_rate_value_brief = 'PERCENT' THEN
           ROUND(rcd.val_com * (rcd.trans_amount * rcd.part_agent) / 100 / 100, 2) WHEN
           rcd.ag_type_defin_rate_brief = 'CONSTANT' AND rcd.ag_type_rate_value_brief = 'ABSOL' THEN
           rcd.val_com WHEN rcd.ag_type_defin_rate_brief = 'FUNCTION' THEN
           Pkg_Tariff_Calc.calc_fun(rcd.t_prod_coef_type_id, rcd.p_cover_ent_id, rcd.p_cover_id) ELSE NULL END
          ,v_Document_ID
          ,(SELECT ap.is_agent
             FROM ven_ac_payment ap
                 ,DOC_SET_OFF    dso
                 ,OPER           o
                 ,TRANS          t
            WHERE t.trans_id = rcd.trans_id
              AND t.oper_id = o.oper_id
              AND o.document_id = dso.doc_set_off_id
              AND dso.child_doc_id = ap.payment_id)
          ,rcd.p_policy_agent_com_id
          ,rcd.trans_id);
      END LOOP;
      Doc.set_doc_status(v_Document_ID, 'NEW');
      v_Result := v_Document_ID;
    ELSE
      v_Result := NULL;
    END IF;
  
    RETURN v_Result;
  END;

  ----///������� ������� ��� � ���������� is_included �� ���� ����� ��� ������������� ���������
  -------------------------------------------------------------
  FUNCTION get_SGP_av
  (
    p_ag_contract_header_id IN NUMBER --��� ���������� ��������
   ,p_data_begin            IN DATE --���� ������ ��������� �������
   ,p_type_av               IN NUMBER --��� ���� ���������� �������������� (T_AG_AV_ID)
  ) RETURN NUMBER IS
    v_SGP         NUMBER;
    v_SGP_all     NUMBER := 0;
    v_is_included NUMBER;
    v_type_brief  VARCHAR2(100);
  BEGIN
    -- ������ ��� � �������� ������ �� ������� ������������ (!) ��������
  
    -- ����������� BRIEF ���� ��������������
    BEGIN
      SELECT ta.brief INTO v_type_brief FROM ven_t_ag_av ta WHERE ta.t_ag_av_id = p_type_av;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20001
                               ,'����������� BRIEF ���� �������������� (p_type_av: ' ||
                                NVL(TO_CHAR(p_type_av), '<null>') || ') ' || SQLERRM);
        --v_err_num:=sqlcode;
    END;
  
    IF v_type_brief = '���'
    THEN
      Pkg_Agent_1.attest_agent_SGP(p_ag_contract_header_id
                                  ,p_data_begin
                                  ,LAST_DAY(p_data_begin)
                                  ,v_SGP_all);
      RETURN(v_SGP_all);
    ELSIF v_type_brief = '���'
    THEN
      COMMIT;
      --��� ������� ��� ������ ������������ ����� �������� �� ������� ���
      Pkg_Agent_1.attest_agent_SGP_new(p_ag_contract_header_id
                                      ,p_data_begin
                                      ,LAST_DAY(p_data_begin)
                                      ,v_SGP_all);
      -- v_is_break = ���������� ��� "������" ��� ����� ���
      FOR rr IN (SELECT dc.agent_report_dav_ct_id
                       ,dc.is_included
                       ,dc.sgp -- ����� ���� ����� �� �����������, �� ���������� �������, ������� ��������� �������� ������
                   FROM ven_agent_report rep
                   JOIN ven_agent_report_dav dav
                     ON (dav.agent_report_id = rep.agent_report_id)
                   JOIN ven_agent_report_dav_ct dc
                     ON (dc.agent_report_dav_id = dav.agent_report_dav_id)
                  WHERE rep.ag_contract_h_id = p_ag_contract_header_id
                    AND rep.report_date > (SELECT MAX(r.report_date)
                                             FROM ven_agent_report     r
                                                 ,ven_agent_report_dav d
                                            WHERE r.ag_contract_h_id = rep.ag_contract_h_id
                                              AND d.agent_report_id = r.agent_report_id
                                              AND d.sum_premium > 0)
                    AND dc.is_break > 0
                    AND dc.is_included > 0
                  ORDER BY rep.report_date)
      LOOP
        IF v_SGP_all > 0
           AND v_SGP_all - (rr.is_included * rr.sgp) < 0
        THEN
          -- ������� ������������ ��� ������������ ����� ���
          v_SGP_all     := 0;
          v_is_included := 1 - (v_SGP_all / (rr.is_included * rr.sgp)); -- 1 ����� �������� �����������
        ELSIF v_SGP_all > 0
              AND v_SGP_all - (rr.is_included * rr.sgp) >= 0
        THEN
          v_SGP_all     := v_SGP_all - (rr.is_included * rr.sgp);
          v_is_included := 0;
        ELSE
          -- ����� �� ����� -- ��� ������������� ����� ��������� ��������� ����� (����� � �������� ��������)
          EXIT;
        END IF;
        -- ��������� is_break �� ���� ����� ��� ������������� ���������
        av_update_report_dav_ct(rr.agent_report_dav_ct_id, v_is_included);
      END LOOP;
    
      RETURN(v_SGP_all);
    END IF;
  
  END;
  -----------------------------------------------------------------
  ----///��������� ������ ������� ��� (�������� ������������� ��� ��� �� ������������� ���������)
  -------------------------------------------------------------
  PROCEDURE del_SGP_dav
  (
    p_ag_contract_header_id IN NUMBER --��� ���������� ��������
   ,p_data_begin            IN DATE --���� ������ ��������� �������
  ) IS
    v_SUM_date    DATE;
    v_SGP_all     NUMBER := 0;
    v_is_included NUMBER;
    v_type_brief  VARCHAR2(100);
  BEGIN
    -- ����� ������ ���������� ���������� �������������� ���
    BEGIN
      SELECT MAX(rep.report_date)
        INTO v_SUM_date
        FROM ven_agent_report rep
        JOIN ven_agent_report_dav dav
          ON (dav.agent_report_id = rep.agent_report_id)
        JOIN ven_agent_report_dav_ct dc
          ON (dc.agent_report_dav_id = dav.agent_report_dav_id)
       WHERE rep.ag_contract_h_id = p_ag_contract_header_id
         AND dav.sum_premium > 0;
    EXCEPTION
      WHEN OTHERS THEN
        v_SUM_date := p_data_begin;
    END;
  
    IF v_SUM_date = p_data_begin
    THEN
      NULL;
      -- ���� ���� (������������ ���_ = p_data_begin, �� ������
    ELSE
      -- ����� .. � ����� ���������� ���  ������������ is_included � �������� 1
      FOR rr IN (SELECT dc.agent_report_dav_ct_id
                       ,dc.sgp -- ����� ���� ����� �� �����������, �� ���������� �������, ������� ��������� �������� ������
                   FROM ven_agent_report rep
                   JOIN ven_agent_report_dav dav
                     ON (dav.agent_report_id = rep.agent_report_id)
                   JOIN ven_agent_report_dav_ct dc
                     ON (dc.agent_report_dav_id = dav.agent_report_dav_id)
                  WHERE rep.ag_contract_h_id = p_ag_contract_header_id
                    AND rep.report_date > v_SUM_date
                    AND dc.is_break > 0
                  ORDER BY rep.report_date)
      LOOP
        IF rr.sgp > 0
        THEN
          v_is_included := 1;
          av_update_report_dav_ct(rr.agent_report_dav_ct_id, v_is_included);
        END IF;
      END LOOP;
    END IF;
  
  END;

  FUNCTION get_par_ST_MN RETURN NUMBER IS
  BEGIN
    RETURN Pkg_Agent_Rate.ST_MN;
  END;

  FUNCTION get_par_SGR RETURN NUMBER IS
  BEGIN
    RETURN Pkg_Agent_Rate.sgp;
  END;

  FUNCTION get_par_KSP RETURN NUMBER IS
  BEGIN
    RETURN Pkg_Agent_Rate.ksp;
  END;

  FUNCTION get_par_KA RETURN NUMBER IS
  BEGIN
    RETURN Pkg_Agent_Rate.ka;
  END;

  FUNCTION get_par_MON RETURN NUMBER IS
  BEGIN
    RETURN Pkg_Agent_Rate.MON;
  END;

  FUNCTION get_par_date_plan RETURN DATE IS
  BEGIN
    RETURN Pkg_Agent_Rate.DATE_PLAN;
  END;

  FUNCTION get_pol_agent_cansel(p_policy_id IN NUMBER) RETURN NUMBER IS
    v_rez      NUMBER := 0;
    v_pol_year NUMBER;
  BEGIN
  
    SELECT COUNT(*)
      INTO v_rez
      FROM V_POLICY_JOURNAL   pj
          ,ven_p_policy_agent ppa
     WHERE pj.policy_header_id = ppa.policy_header_id
       AND pj.policy_id = p_policy_id
       AND EXISTS (SELECT '1'
              FROM ven_POLICY_AGENT_STATUS pas
             WHERE ppa.status_id = pas.policy_agent_status_id
               AND pas.brief = 'CANCEL')
       AND EXISTS (SELECT '1'
              FROM ven_p_pol_header ph
                  ,ven_p_policy     p
             WHERE ph.policy_id = p.policy_id
               AND ph.policy_id = pj.policy_id
               AND CEIL(MONTHS_BETWEEN(p.end_date, ph.start_date) / 12) <= 1)
    
    ;
  
    IF v_rez > 0
    THEN
      v_rez := 1;
    END IF;
  
    RETURN v_rez;
  END;
  ------------------------------------------------------------
  --
  -- ���������� ��� �� ��������������� �������
  --
  ------------------------------------------------------------
  FUNCTION get_recruit_SGP RETURN NUMBER
  
   IS
  BEGIN
    -- pDebug.put ('������� glb_recruit_SGP:'||-glb_recruit_SGP);
    RETURN - glb_recruit_SGP;
  
  END get_recruit_SGP;

  ------------------------------------------------------------
  --
  -- ���������� ���-�� ��������������� �������
  --
  ------------------------------------------------------------
  FUNCTION get_count_recruit RETURN NUMBER IS
  BEGIN
    --pDebug.put ('������� glb_count_recruit:'||-glb_count_recruit);
    RETURN - glb_count_recruit;
  
  END get_count_recruit;

  PROCEDURE av_main_recalc
  (
    p_vedom_id  IN NUMBER
   ,p_ag_header IN VARCHAR2 DEFAULT NULL
  ) IS
    CURSOR cur_av_vedom(cv_vedom_id NUMBER) IS
      SELECT * FROM AG_VEDOM_AV a WHERE a.AG_VEDOM_AV_ID = cv_vedom_id;
  
    CURSOR cur_ag_header(cv_header_num VARCHAR2) IS
      SELECT * FROM ven_ag_contract_header a WHERE a.num = cv_header_num;
  
    rec_av_vedom  cur_av_vedom%ROWTYPE;
    rec_ag_header cur_ag_header%ROWTYPE;
  
    a                       NUMBER;
    v_ag_contract_header_id NUMBER;
  BEGIN
    OPEN cur_av_vedom(p_vedom_id);
    FETCH cur_av_vedom
      INTO rec_av_vedom;
  
    IF (cur_av_vedom%NOTFOUND)
    THEN
      CLOSE cur_av_vedom;
      RETURN;
    END IF;
  
    CLOSE cur_av_vedom;
  
    IF (p_ag_header IS NOT NULL)
    THEN
    
      OPEN cur_ag_header(p_ag_header);
      FETCH cur_ag_header
        INTO rec_ag_header;
    
      IF (cur_ag_header%NOTFOUND)
      THEN
        CLOSE cur_ag_header;
        RETURN;
      END IF;
    
      CLOSE cur_ag_header;
    
      v_ag_contract_header_id := rec_ag_header.ag_contract_header_id;
    
    ELSE
    
      v_ag_contract_header_id := NULL;
    
    END IF;
  
    av_main(rec_av_vedom.AG_VEDOM_AV_ID
           ,rec_av_vedom.date_begin
           ,rec_av_vedom.AG_CATEGORY_AGENT_ID
           ,rec_av_vedom.T_AG_AV_ID
           ,v_ag_contract_header_id
           ,a);
  
  END av_main_recalc;

  FUNCTION update_act(p_agent_report_id NUMBER) RETURN NUMBER IS
    v_start_date            DATE;
    v_end_date              DATE;
    v_ag_contract_header_id NUMBER;
    v_i                     NUMBER;
  BEGIN
    SELECT ar.report_date
          ,ar.start_date
          ,ar.ag_contract_h_id
      INTO v_end_date
          ,v_start_date
          ,v_ag_contract_header_id
      FROM agent_report ar
     WHERE ar.agent_report_id = p_agent_report_id;
    v_i := 0;
    IF doc.get_doc_status_brief(p_agent_report_id) = 'NEW'
    THEN
      --�������� ����� �������
      FOR rcd IN (SELECT *
                    FROM v_Agent_Com_Payment acp
                   WHERE ((v_Start_Date IS NULL) OR
                         (v_Start_Date IS NOT NULL) AND (acp.trans_date >= v_Start_Date))
                     AND (acp.trans_date < v_End_Date + 1)
                     AND (acp.ag_contract_header_id = v_ag_contract_header_id)
                     AND NOT EXISTS (SELECT agr.agent_report_cont_id
                            FROM agent_report_cont agr
                           WHERE agr.agent_report_id = p_agent_report_id
                             AND agr.trans_id = acp.trans_id))
      LOOP
        INSERT INTO AGENT_REPORT_CONT arc
          (arc.agent_report_cont_id
          ,arc.comission_sum
          ,arc.agent_report_id
          ,arc.is_deduct
          ,arc.p_policy_agent_com_id
          ,arc.trans_id)
        VALUES
          (sq_agent_report_cont.NEXTVAL
          ,CASE WHEN
           rcd.ag_type_defin_rate_brief = 'CONSTANT' AND rcd.ag_type_rate_value_brief = 'PERCENT' THEN
           ROUND(rcd.val_com * (rcd.trans_amount * rcd.part_agent) / 100 / 100, 2) WHEN
           rcd.ag_type_defin_rate_brief = 'CONSTANT' AND rcd.ag_type_rate_value_brief = 'ABSOL' THEN
           rcd.val_com WHEN rcd.ag_type_defin_rate_brief = 'FUNCTION' THEN
           Pkg_Tariff_Calc.calc_fun(rcd.t_prod_coef_type_id, rcd.p_cover_ent_id, rcd.p_cover_id) ELSE NULL END
          ,p_agent_report_id
          ,(SELECT ap.is_agent
             FROM ven_ac_payment ap
                 ,DOC_SET_OFF    dso
                 ,OPER           o
                 ,TRANS          t
            WHERE t.trans_id = rcd.trans_id
              AND t.oper_id = o.oper_id
              AND o.document_id = dso.doc_set_off_id
              AND dso.child_doc_id = ap.payment_id)
          ,rcd.p_policy_agent_com_id
          ,rcd.trans_id);
        v_i := v_i + 1;
      END LOOP;
    ELSE
      RETURN - 1;
    END IF;
    RETURN v_i;
  END;

END Pkg_Agent_Rate;
/

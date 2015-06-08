CREATE OR REPLACE PACKAGE Pkg_Agent_1 IS
  /** 
  * ������ � ���������� ���������� - ��������, ��������������, ��������, ��������� ��������
  * @author Budkova A.
  * @version J
  */

  v_contract_id          NUMBER;
  DATE_PAY               DATE; --���� ������
  STATUS_NEW             VARCHAR2(30) := 'NEW'; --Brief ������� ����� ���������
  STATUS_RESUME          VARCHAR2(30) := 'RESUME'; --Brief ������� �����������
  STATUS_CURRENT         VARCHAR2(30) := 'CURRENT'; --Brief ������� �����������
  STATUS_BREAK           VARCHAR2(30) := 'BREAK'; --Brief ������� ����������
  STATUS_READY_TO_CANCEL VARCHAR2(30) := 'READY_TO_CANCEL'; --Brief ������� ��������� � �����������
  STATUS_STOP            VARCHAR2(30) := 'STOP'; --Brief ������� �������������
  SUM_ADM_IZD            NUMBER := 300; --����� ���������������� �������� ��� ������� �������������� � ����������
  DATE_START             DATE := SYSDATE; -- ���������� ��� ������������� � ������������� v_agent_current_status
  glb_clear_flag_attest  VARCHAR2(1) := '�'; -- ������ �������� ������� �� ������� ���
  /**
  *  ��������� ���������� ������ ��������
  *
  * @author Budkova A.
  * @param p_contr_id �� ��������
  * @param p_version_id �� ������ ��������
  *
  * @return �� �������
  */
  PROCEDURE set_last_ver
  (
    p_contr_id   NUMBER
   ,p_version_id NUMBER
  );

  /**
  *  ��������� ��������� �� ��������
  *
  * @author ���������� �������
  * @param p_contr_id �� ��������
  * @param p_agency_id �� ��������� ��������
  *
  * @return �� �������
  */
  PROCEDURE set_last_agency
  (
    p_contr_id  NUMBER
   ,p_agency_id NUMBER
  );

  /**
  * ���������� ������ ��������� ������ ��������
  * @author Budkova A.
  * @param p_contr_id �� ��������
  *
  * @return �� �������
  */
  FUNCTION get_status_contr(p_contr_id NUMBER) RETURN NUMBER;

  /**
  * ��������.� �� ���� ������������ ������ � ��������
  * �������� �.�. 19-06-2009
  **/
  FUNCTION get_agent_to_policy
  (
    polh_id NUMBER
   ,dates   DATE
  ) RETURN NUMBER;
  /**
  * ��������.� ��� ������������ ������ � ��������
  * �������� �.�. 14-09-2009
  **/
  FUNCTION get_agent_pol
  (
    polh_id NUMBER
   ,dates   DATE
  ) RETURN VARCHAR2;
  FUNCTION get_agentlider_pol
  (
    polh_id NUMBER
   ,dates   DATE
  ) RETURN VARCHAR2;

  /**
  * ���������� ����������� ������ �������� ���������� �� ����
  * @author Budkova A.
  * @param p_ag_contract_header_id �� ��������� ���������� ��������
  * @param p_date ����
  *
  * @return �� ������ ��������
  */
  FUNCTION get_status_by_date
  (
    p_ag_contract_header_id NUMBER
   ,p_date                  DATE
  ) RETURN NUMBER;

  /**
  * ���������� ���������� ������ �������� - ���������� �� �������
  * @author Budkova A.
  * @param p_contr_id �� ��������
  *
  * @return �� �������
  */
  FUNCTION get_status_contr_activ(p_contr_id NUMBER) RETURN NUMBER;

  /**
  * ���������� ���������� ������ �������� - ���������� �������� �������
  * @author Budkova A.
  * @param p_contr_id �� ��������
  *
  * @return ���������� �������� �������
  */
  FUNCTION get_status_contr_activ_name(p_contr_id NUMBER) RETURN VARCHAR2;

  /**
  * ���������� ���������� ������ �������� - ���������� Brief �������
  * @author Budkova A.
  * @param p_contr_id �� ��������
  *
  * @return ���������� Brief �������
  */
  FUNCTION get_status_contr_activ_brief(p_contr_id NUMBER) RETURN VARCHAR2;

  /**
  * ���������� ���������� ������ �������� - ���������� �� ���������� ������ ��������
  * @author Budkova A.
  * @param p_contr_id �� ��������
  *
  * @return ���������� �� ���������� ������ ��������
  */
  FUNCTION get_status_contr_activ_id(p_contr_id NUMBER) RETURN NUMBER;

  /**
  * ���������� ���� ��������� �������� ��������
  * @author Budkova A.
  * @param p_contr_id �� ��������
  *
  * @return �� �������
  */
  FUNCTION get_end_contr(p_contr_id NUMBER) RETURN DATE;

  /**
  * ��������� ������� ������ ��. �������� �� �� �������
  * @author Budkova A.
  * @param p_doc_id       �� ������
  * @param p_status_id    �� ������ �������
  * @param p_status_date  ���� ������ �������� �������
  */
  PROCEDURE set_version_status
  (
    p_doc_id    IN NUMBER
   ,p_status_id IN NUMBER
  );

  /**
  * ��������� ������� ������ ��. �������� �� ���������� �������
  * @author Budkova A.
  * @param p_doc_id        �� ������ (�� ���.����������)
  * @param p_status_brief  brief ������ �������
  * @param p_status_date   ���� ������ �������� �������
  */
  PROCEDURE set_version_status
  (
    p_doc_id       IN NUMBER
   ,p_status_brief IN VARCHAR2
  );

  /**
  * ��������� ������ ������
  * @author Budkova A.
  * @param p_contract_id  �� ��. ��������
  *
  * @return p_num         ����� ������
  */
  FUNCTION get_ver_num(p_contract_id IN NUMBER) RETURN VARCHAR2;

  /**
  * �������� ����� ��������
  * @author Budkova A.
  * @return ����� ��������
  */
  FUNCTION get_num_contract RETURN VARCHAR2;

  /**
  * ���������� ����������� ��������� ������� ������
  * @author Budkova A.
  * @param p_version_id �� ������
  *
  * @return 1-��, 0-���
  */
  FUNCTION can_be_current(p_version_id IN NUMBER) RETURN NUMBER;

  /**
  * ���������� ����������� �������� ����� ������ ������ �� ��������
  * @author Budkova A.
  * @param p_version_id �� ������
  *
  * @return 1-��, 0-���
  */
  FUNCTION can_be_copied(p_version_id IN NUMBER) RETURN NUMBER;

  /**
  * ���������� ����������� �������� ������
  * @author Budkova A.
  * @param p_version_id �� ������
  *
  * @return 1-��, 0-���
  */
  FUNCTION can_be_del(p_version_id IN NUMBER) RETURN NUMBER;

  /**
  * ���������� ������ ��������
  * @author Budkova A.
  * @param p_contract_id     �� ��������
  * @param p_date_begin      ���� ������ �������� ������
  * @param p_date_end        ���� ��������� �������� ������
  * @param p_class_agent_id  �� ������ ������
  * @param p_category_id     �� ��������� ������
  * @param p_note            ����������
  * @param p_obj_id          �� ������
  * @param p_CONTRACT_LEADER_ID �� ������ �������� ������������
  * @param p_RATE_AGENT         �������� ������ �� � ������
  * @param p_RATE_TYPE_ID       �������� ������ �� � �������� ������
  * @param p_RATE_TYPE_MAIN_ID  �� ���� ������ �� � �������� ������
  * @param p_fact_dop_rate      ����������� ������ ���.��������������
  * @param p_contract_f_lead_id �� ������ �������� ������� ������������ (�����������)
  * @param p_contract_recrut_id �� ������ �������� ���������
  * @param p_method_payment     ����� ������� ���������� ��������������
  * @param p_is_call_center     ������� ���������� � ����-�������
  * @param p_leg_pos            ������� � ��. �������. 0 - ���.����, 1- �����, 2 - ��.����.
  * @param p_date_break         ���� �����������
  * @param p_templ_id           �� ������� ������ ��������
  */
  PROCEDURE version_insert
  (
    p_contract_id        NUMBER
   , --�� ���������
    p_date_begin         DATE DEFAULT SYSDATE
   ,p_date_end           DATE
   ,p_class_agent_id     NUMBER DEFAULT NULL
   ,p_category_id        NUMBER DEFAULT NULL
   ,p_note               VARCHAR2 DEFAULT NULL
   ,p_obj_id             IN OUT NUMBER
   , --�� ��� ����������
    p_CONTRACT_LEADER_ID NUMBER DEFAULT NULL
   ,p_RATE_AGENT         NUMBER DEFAULT NULL
   ,p_RATE_MAIN_AGENT    NUMBER DEFAULT NULL
   ,p_RATE_TYPE_ID       NUMBER DEFAULT NULL
   ,p_RATE_TYPE_MAIN_ID  NUMBER DEFAULT NULL
   ,p_fact_dop_rate      NUMBER DEFAULT 0
   ,p_contract_f_lead_id NUMBER DEFAULT NULL
   ,p_contract_recrut_id NUMBER DEFAULT NULL
   ,p_method_payment     NUMBER DEFAULT 0
   ,p_is_call_center     NUMBER DEFAULT 0
   ,p_leg_pos            NUMBER DEFAULT 0
   ,p_date_break         DATE DEFAULT SYSDATE
   ,p_templ_id           NUMBER DEFAULT NULL
   ,p_agency_id          NUMBER DEFAULT NULL
    
  );

  /**
  * ��������� ������ ��������
  * @author Budkova A.
  * @param p_contract_id     �� ��������
  * @param p_date_begin      ���� ������ �������� ������
  * @param p_date_end        ���� ��������� �������� ������
  * @param p_status_id       �� �������
  * @param p_class_agent_id  �� ������ ������
  * @param p_category_id     �� ��������� ������
  * @param p_note            ����������
  * @param p_ver_id          �� ������
  * @param p_CONTRACT_LEADER_ID �� ������ �������� ������������
  * @param p_RATE_AGENT         �������� ������ �� � ������
  * @param p_RATE_TYPE_ID       �������� ������ �� � �������� ������
  * @param p_RATE_TYPE_MAIN_ID  �� ���� ������ �� � �������� ������
  * @param p_fact_dop_rate      ����������� ������ ���.��������������
  * @param p_contract_f_lead_id �� ������ �������� ������� ������������ (�����������)
  * @param p_contract_recrut_id �� ������ �������� ���������
  * @param p_method_payment     ����� ������� ���������� ��������������
  * @param p_is_call_center     ������� ���������� � ����-�������
  * @param p_leg_pos            ������� � ��. �������. 0 - ���.����, 1- �����, 2 - ��.����.
  */
  PROCEDURE version_update
  (
    p_contract_id        NUMBER
   , --�� ���������
    p_date_begin         DATE
   ,p_date_end           DATE
   ,p_class_agent_id     NUMBER DEFAULT NULL
   ,p_category_id        NUMBER DEFAULT NULL
   ,p_note               VARCHAR2
   ,p_ver_id             NUMBER
   , --�� ��� ����������
    p_CONTRACT_LEADER_ID NUMBER DEFAULT NULL
   ,p_RATE_AGENT         NUMBER DEFAULT NULL
   ,p_RATE_MAIN_AGENT    NUMBER DEFAULT NULL
   ,p_RATE_TYPE_ID       NUMBER DEFAULT NULL
   ,p_RATE_TYPE_MAIN_ID  NUMBER DEFAULT NULL
   ,p_fact_dop_rate      NUMBER DEFAULT 0
   ,p_contract_f_lead_id NUMBER DEFAULT NULL
   ,p_contract_recrut_id NUMBER DEFAULT NULL
   ,p_method_payment     NUMBER DEFAULT 0
   ,p_is_call_center     NUMBER DEFAULT 0
   ,p_leg_pos            NUMBER DEFAULT 0
   ,p_agency_id          NUMBER DEFAULT NULL
   ,p_comm_holding       NUMBER DEFAULT 0
    -- p_num varchar2 default null,
    -- p_num_old varchar2 default null
  );

  /**
  * �������� ������ �������� (�������� �������� ������ � ������� �����)
  * @author Budkova A.
  * @param p_ver_id        �� ������ ��������
  */
  PROCEDURE version_del(p_ver_id NUMBER);

  /**
  * ���������� ��������
  * @author Budkova A.
  * @param p_contr_id        �� ��������
  * @param p_vers_id         �� ������
  * @param p_num             ����� ��������
  * @param p_date_begin      ���� ������ �������� ������
  * @param p_date_end        ���� ��������� �������� ������
  * @param p_agent_id        �� ������
  * @param p_note            ����������
  * @param p_class_agent_id  �� ������ ������
  * @param p_category_id     �� ��������� ������
  * @param p_CONTRACT_LEADER_ID �� ������ �������� ������������
  * @param p_RATE_AGENT         �������� ������ �� � ������
  * @param p_RATE_TYPE_ID       �������� ������ �� � �������� ������
  * @param p_RATE_TYPE_MAIN_ID  �� ���� ������ �� � �������� ������
  * @param p_fact_dop_rate      ����������� ������ ���.��������������
  * @param p_note_ver           ���������� ������ ��������
  * @param p_sales_channel_id   �� ������ ������
  * @param p_AG_CONTRACT_TEMP_ID �� �������
  * @param p_contract_f_lead_id �� ������ �������� ������� ������������ (�����������)
  * @param p_contract_recrut_id �� ������ �������� ���������
  * @param p_method_payment     ����� ������� ���������� ��������������
  * @param p_is_call_center     ������� ���������� � ����-�������
  * @param p_leg_pos            ������� � ��. �������. 0 - ���.����, 1- �����, 2 - ��.����.
  */
  PROCEDURE contract_insert
  (
    p_contr_id            OUT NUMBER
   ,p_vers_id             OUT NUMBER
   ,p_num                 VARCHAR2
   ,p_date_begin          DATE DEFAULT SYSDATE
   ,p_date_end            DATE
   ,p_having_subagents    NUMBER DEFAULT 0
   ,p_agent_id            NUMBER
   ,p_rlp_num             NUMBER DEFAULT NULL
   ,p_date_break          DATE DEFAULT NULL
   ,p_agency_id           NUMBER DEFAULT NULL
   ,p_note                VARCHAR2 DEFAULT NULL
   ,p_class_agent_id      NUMBER DEFAULT NULL
   ,p_category_id         NUMBER DEFAULT NULL
   ,p_CONTRACT_LEADER_ID  NUMBER DEFAULT NULL
   ,p_RATE_AGENT          NUMBER DEFAULT NULL
   ,p_RATE_MAIN_AGENT     NUMBER DEFAULT NULL
   ,p_RATE_TYPE_ID        NUMBER DEFAULT NULL
   ,p_RATE_TYPE_MAIN_ID   NUMBER DEFAULT NULL
   ,p_fact_dop_rate       NUMBER DEFAULT 0
   ,p_note_ver            VARCHAR2 DEFAULT NULL
   ,p_sales_channel_id    NUMBER
   ,p_AG_CONTRACT_TEMP_ID NUMBER DEFAULT NULL
   ,p_contract_f_lead_id  NUMBER DEFAULT NULL
   ,p_contract_recrut_id  NUMBER DEFAULT NULL
   ,p_method_payment      NUMBER DEFAULT 0
   ,p_is_call_center      NUMBER DEFAULT 0
   ,p_leg_pos             NUMBER DEFAULT 0
    
  );

  /**
  * ��������� ��������
  * @author Budkova A.
  * @param p_contr_id        �� ��������
  * @param p_vers_id         �� ������
  * @param p_num             ����� ��������
  * @param p_date_begin      ���� ������ �������� ������
  * @param p_date_end        ���� ��������� �������� ������
  * @param p_agent_id        �� ������
  * @param p_note            ����������
  * @param p_CONTRACT_LEADER_ID �� ������ �������� ������������
  * @param p_RATE_AGENT         �������� ������ �� � ������
  * @param p_RATE_TYPE_ID       �������� ������ �� � �������� ������
  * @param p_RATE_TYPE_MAIN_ID  �� ���� ������ �� � �������� ������
  * @param p_fact_dop_rate      ����������� ������ ���.��������������
  * @param p_sales_channel_id   �� ������ ������
  * @param p_contract_f_lead_id �� ������ �������� ������� ������������ (�����������)
  * @param p_contract_recrut_id �� ������ �������� ���������
  * @param p_method_payment     ����� ������� ���������� ��������������
  * @param p_is_call_center     ������� ���������� � ����-�������
  * @param p_leg_pos            ������� � ��. �������. 0 - ���.����, 1- �����, 2 - ��.����.
  */
  PROCEDURE contract_update
  (
    p_ag_ch_id           NUMBER
   ,p_vers_id            NUMBER
   ,p_num                VARCHAR2
   ,p_date_begin         DATE
   ,p_date_end           DATE
   ,p_having_subagents   NUMBER DEFAULT 0
   ,p_agent_id           NUMBER
   ,p_rlp_num            NUMBER
   ,p_date_break         DATE DEFAULT NULL
   ,p_agency_id          NUMBER DEFAULT NULL
   ,p_note               VARCHAR2
   ,p_CONTRACT_LEADER_ID NUMBER DEFAULT NULL
   ,p_RATE_AGENT         NUMBER DEFAULT NULL
   ,p_RATE_MAIN_AGENT    NUMBER DEFAULT NULL
   ,p_RATE_TYPE_ID       NUMBER DEFAULT NULL
   ,p_RATE_TYPE_MAIN_ID  NUMBER DEFAULT NULL
   ,p_fact_dop_rate      NUMBER DEFAULT 0
   ,p_sales_channel_id   NUMBER
   ,p_contract_f_lead_id NUMBER DEFAULT NULL
   ,p_contract_recrut_id NUMBER DEFAULT NULL
   ,p_method_payment     NUMBER DEFAULT 0
   ,p_is_call_center     NUMBER DEFAULT 0
   ,p_leg_pos            NUMBER DEFAULT 0
   ,p_comm_holding       NUMBER DEFAULT 0
  );

  /**
  * ����������� ��.��������
  * @author Budkova A.
  * @param v_ch_id - �� ��.�������� (ag_contract_header)
  */
  PROCEDURE contract_break(v_ch_id NUMBER);

  /**
  * ��������� ��� ���������� � ������������!!!
  * ������� ������� � ��� ��� ������. �� �������� ������-������
  * @author Budkova A.
  * @param v_contract_id �� ��������
  */
  PROCEDURE contract_del(v_contract_id NUMBER);

  /**
  * ��������� ��� ������� ������ ������� ���������� ��������
  * @author ������ �., ������� 2006
  * @param p_contr_id        �� ��������
  * @param p_vers_id         �� ������
  * @param p_date_begin      ���� ��������� �������
  * @param p_agency_id       �� ���������
  * @param p_note            ����������
  * @param p_note_ver        ���������� ������
  * @param p_class_agent_id  �� ������� ������
  * @param p_category_id     �� ��������� ������
  * @param p_sales_channel_id �� ������ ������
  * @param p_method_payment     ����� ������� ���������� ��������������
  * @param p_is_call_center     ������� ���������� � ����-�������
  * @param p_leg_pos            ������� � ��. �������. 0 - ���.����, 1- �����, 2 - ��.����.
  * @param p_kl_templ           1 - ������� �������� -- 2 - ������ ���. ����������
  * @param p_templ_name      �������� �������
  * @param p_templ_brief     Brief �������
  */
  PROCEDURE template_insert
  (
    p_contr_id         OUT NUMBER
   ,p_vers_id          OUT NUMBER
   ,p_date_begin       DATE DEFAULT SYSDATE
   ,p_agency_id        NUMBER DEFAULT NULL
   ,p_note             VARCHAR2 DEFAULT NULL
   ,p_note_ver         VARCHAR2 DEFAULT NULL
   ,p_class_agent_id   NUMBER DEFAULT NULL
   ,p_category_id      NUMBER DEFAULT NULL
   ,p_SALES_CHANNEL_ID NUMBER
   ,p_method_payment   NUMBER DEFAULT 0
   ,p_is_call_center   NUMBER DEFAULT 0
   ,p_leg_pos          NUMBER DEFAULT 0
   ,p_kl_templ         NUMBER DEFAULT 1
   ,p_TEMPL_NAME       VARCHAR2 DEFAULT NULL
   ,p_TEMPL_BRIEF      VARCHAR2 DEFAULT NULL
  );

  /**
  * ��������� ��� ���������� ������� ���������� ��������
  * @author ������ �., ������� 2006
  * @param p_ag_ch_id        �� ��������
  * @param p_vers_id         �� ������
  * @param p_date_begin      ���� ��������� �������
  * @param p_agency_id       �� ���������
  * @param p_note            ����������
  * @param p_note_ver        ���������� ������
  * @param p_class_agent_id  �� ������� ������
  * @param p_category_id     �� ��������� ������
  * @param p_sales_channel_id �� ������ ������
  * @param p_templ_name      �������� �������
  * @param p_templ_brief     Brief �������
  * @param p_method_payment     ����� ������� ���������� ��������������
  * @param p_is_call_center     ������� ���������� � ����-�������
  * @param p_leg_pos            ������� � ��. �������. 0 - ���.����, 1- �����, 2 - ��.����.
  */
  PROCEDURE template_update
  (
    p_ag_ch_id         NUMBER
   ,p_vers_id          NUMBER
   ,p_date_begin       DATE DEFAULT SYSDATE
   ,p_agency_id        NUMBER DEFAULT NULL
   ,p_note             VARCHAR2 DEFAULT NULL
   ,p_note_ver         VARCHAR2 DEFAULT NULL
   ,p_class_agent_id   NUMBER DEFAULT NULL
   ,p_category_id      NUMBER DEFAULT NULL
   ,p_sales_channel_id NUMBER
   ,p_method_payment   NUMBER DEFAULT 0
   ,p_is_call_center   NUMBER DEFAULT 0
   ,p_leg_pos          NUMBER DEFAULT 0
   ,p_templ_name       VARCHAR2 DEFAULT NULL
   ,p_templ_brief      VARCHAR2 DEFAULT NULL
   ,p_comm_holding     NUMBER DEFAULT 0
  );

  /**
  * ��������� ����� ������ ��������
  * @author Budkova A.
  * @param p_ver_id_old  �� ������ ������
  * @param p_ver_id_new  �� ����� ������
  * @param p_date_begin  ���� ������ �������� ������
  * @param p_anyway_copy ���������� ��� ��������� "����������� ����������� ������"
  * @param p_date_break  ���� �����������
  */
  PROCEDURE contract_copy
  (
    p_ver_id_old  IN NUMBER
   ,p_ver_id_new  OUT NUMBER
   ,p_date_begin  DATE DEFAULT SYSDATE
   ,p_anyway_copy IN BOOLEAN DEFAULT FALSE
   ,p_date_break  DATE DEFAULT SYSDATE
  );

  /**
  * ��������� ����� ������ ��������
  * @author Shidlovskaya T
  * @param p_prizn_all  ��������� ������� ������(1) ��� ��� (0)
  * @param p_ver_id_old  �� ������ ������
  * @param p_ver_id_new  �� ����� ������
  * @p_templ_id �� ���������
  * @param p_date_begin  ���� ������ �������� ������
  * @param p_anyway_copy ���������� ��� ��������� "����������� ����������� ������"
  * @param p_date_break  ���� �����������
  */
  PROCEDURE contract_from_tmpl
  (
    p_prizn_all     IN NUMBER -- ��������� ������� ������(1) ��� ��� (0)
   ,p_ver_id_old    IN NUMBER
   ,p_ver_id_new    OUT NUMBER
   ,p_templ_id      IN NUMBER
   ,p_date_ver      IN DATE DEFAULT SYSDATE
   ,p_anyway_create IN OUT BOOLEAN
   ,p_date_break    DATE DEFAULT SYSDATE
  );

  /**
  * ����������� ������� ��� ����� �� ��������, ������ ��������, ������
    (ag_prod_line_contr, ag_period_rate, ag_rate)
  * @author Budkova A.
  * @param p_ver_cont_id         �� ������
  * @param p_insurance_group_id  �� ���� �����������
  * @param p_product_id          �� ��������
  * @param p_product_line_id     �� ���� ��������
  * @param p_defin_rate_id       �� ���� ����������� ������
  * @param p_type_value_rate     �� ��� �������� ������
  * @param p_rate                �������� ������
  * @param p_db                  ���� ������ ��������
  * @param p_de                  ���� ��������� ��������
  * @param p_PROD_COEF_TYPE_ID   �� �������
  * @param p_notes               ����������
  */
  PROCEDURE prod_line_contr_insert( --p_AG_PROD_LINE_CONTR_ID out number,
                                   p_ver_cont_id        NUMBER
                                  ,p_insurance_group_id NUMBER
                                  ,p_product_id         NUMBER
                                  ,p_product_line_id    NUMBER
                                  ,p_defin_rate_id      NUMBER
                                  ,p_type_value_rate    NUMBER
                                  ,p_rate               NUMBER
                                  ,p_db                 DATE
                                  ,p_de                 DATE
                                  ,p_PROD_COEF_TYPE_ID  NUMBER
                                  ,p_notes              VARCHAR2);

  /**
  * ��������� ������ ��� ����� �� ��������, ������ ��������, ������
    (ag_prod_line_contr, ag_period_rate, ag_rate)
  * @author Budkova A.
  * @param p_ver_cont_id         �� ������
  * @param p_prod_line_contr_id  �� ��� ����� �� ��������
  * @param p_insurance_group_id  �� ���� �����������
  * @param p_product_id          �� ��������
  * @param p_product_line_id     �� ���� ��������
  * @param p_defin_rate_id       �� ���� ����������� ������
  * @param p_type_value_rate     �� ��� �������� ������
  * @param p_ag_rate_id          �� ������
  * @param p_rate                �������� ������
  * @param p_db                  ���� ������ ��������
  * @param p_de                  ���� ��������� ��������
  * @param p_PROD_COEF_TYPE_ID   �� �������
  * @param p_notes               ����������
  */
  PROCEDURE prod_line_contr_update
  (
    p_prod_line_contr_id NUMBER
   ,p_insurance_group_id NUMBER
   ,p_product_id         NUMBER
   ,p_product_line_id    NUMBER
   ,p_defin_rate_id      NUMBER
   ,p_type_value_rate    NUMBER
   ,p_ag_rate_id         NUMBER
   ,p_rate               NUMBER
   ,p_db                 DATE
   ,p_de                 DATE
   ,p_PROD_COEF_TYPE_ID  NUMBER
   ,p_notes              VARCHAR2
  );

  /**
  * �������� ������� �� ������� ��� ����� �� ��������
    (ag_prod_line_contr)
  * @author Budkova A.
  * @param p_ver_id        �� ������
  * @param p_prod_line_id  �� ��� ����� �� ��������.
                                ���� null, ����� ������� ��� ����� �� ���� ������
  */
  PROCEDURE prod_line_contr_del
  (
    p_ver_id       NUMBER
   ,p_prod_line_id NUMBER
  );

  /**
  * ��������� ��� ��������
  * @author Budkova A.
  * @param p_ver_id              ��� ������ ��������
  * @param p_db                  ���� ������ ��������
  * @param p_de                  ���� ��������� ��������
  */
  PROCEDURE prod_line_update_date
  (
    p_ver_id NUMBER
   ,p_db     DATE DEFAULT NULL
   ,p_de     DATE DEFAULT NULL
  );

  /** ��������� ������ �� ���������� �������� �� ���������� �������� � ������
  * @author Budkova A.
  * @param p_coverid - �� ���������� ��������
  * @param p_agent_id - �� ������ �� �������� �����������
  * @param p_date - ���� ���������� �������� ������\
  * @return �� ������ � ag_prod_line_contr
  */
  FUNCTION get_agent_rate_by_cover
  (
    p_p_cover_id NUMBER
   ,p_agent_id   NUMBER
   ,p_date       DATE
  ) RETURN NUMBER;

  /** ��������� �������� ������ ��
  * @author Budkova A.
  * @param p_categ_from_id - �� ���������-��������� ������
  * @param p_categ_to_id - �� ���������-��������� ������
  * @param p_product_id - �� ��������
  * @param p_sq_year_id - �� ��� �������
  * @param p_date - ����, �� ������� �������� �������� ������
  *
  * @return �������� ������ ��
  * @return p_def_id
  * @return p_type_id
  * @return p_com
  */
  PROCEDURE get_rate
  (
    p_categ_from_id IN NUMBER
   ,p_categ_to_id   IN NUMBER
   ,p_product_id    IN NUMBER
   ,p_sq_year_id    IN NUMBER DEFAULT 1
   ,p_date          IN DATE DEFAULT SYSDATE
   ,p_def_id        OUT NUMBER
   ,p_type_id       OUT NUMBER
   ,p_com           OUT NUMBER
  );
  /**
  * ��������� ������� ��������� ��������
  * @author Budkova A.
  * @param p_doc_id       �� ���������
  */
  PROCEDURE set_header_status(p_doc_id IN NUMBER);

  /** ��������� �������� �������� �� ����� ��������� �������, ���������� ��������,
  *   ���� �������� �������� �����������, ����
  *   @author Kiselev P.
  *   @param p_product_id          ��������� �������
  *   @param p_year_contract       ��� �������� ��������
  *   @param p_ctg_source_id       ���������-��������
  *   @param p_ctg_destination_id  ���������-��������
  *   @param p_date                ���� ����������� ������
  */
  /*function get_commiss_by_ctg_rel(p_product_id number,
                                  p_year_contract number,
                                  p_ctg_source_id number,
                                  p_ctg_destination_id number,
                                  p_date date
                                 ) return number;
  */

  /** ������� ������� ����� �������� ��� ���������� ������������ ������ �� ������������ �����
  *   @author Kiselev P
  *   @param p_ag_contract_source_id �� ���������� �������� �� �������� ���� ������
  *   @param p_ag_contract_dest_id   �� ���������� �������� �������� ���� ������
  *   @param p_date                  ����
  *
  */
  PROCEDURE make_comiss_to_manager(p_akt_agent_id IN NUMBER);

  /* ���������� ID ������� ���������� �������� �� brief
  *   @author ������ ������
  *   @param  par_brief ���� ������� ������
  *   @return policy_agent_status_id
  */
  FUNCTION get_aps_id_by_brief(par_brief IN VARCHAR2) RETURN NUMBER;

  /* ���������� ������ ���������� �������� �� P_POLICY_AGENT_ID
  *   @author ������ ������, ������� 2006
  *   @param  par_POLICY_AGENT_ID ��� ������ �� �������� �����������
  *   @return status_id
  */
  FUNCTION get_status_agent_policy(par_POLICY_AGENT_ID IN NUMBER) RETURN NUMBER;

  /**
  * ��������������� �������
  * @author ������ ������
  * @return pkg_agent.v_contract_id;
  */
  FUNCTION get_id RETURN NUMBER;

  /**
  * ��������������� ���������
  * @author ������ ������
  * @return pkg_agent.v_contract_id;
  */
  PROCEDURE get_parameter(p_contract_id NUMBER);

  /*  �������� ��������� ������� �� �������� ����������� �� ������ ������ � �������
   * @author ������ ������,   ������� 2006
   *  @param = pv_policy_header_id �� ��������� �������� �����������
   *  @param = p_old_AG_CONTRACT_HEADER_ID �� ���������� �������� �� �������� ����������
   *  @param = p_new_AG_CONTRACT_HEADER_ID �� ���������� �������� �������� ����������
   *  @param = p_date_break - ���� ����������� �������� � ������ ������� � �������� �������� ������� ������
   *  @param = msg - �������� �������� ��� ��������� ������� �� ���� ������
   *  @return : <0 - ��� ������ sqlcode , =0 ���� �� ��, >0 ���� ������ � ������
  */
  FUNCTION Transmit_Policy
  (
    pv_policy_header_id         IN NUMBER
   ,p_old_AG_CONTRACT_HEADER_ID IN NUMBER
   ,p_new_AG_CONTRACT_HEADER_ID IN NUMBER
   ,p_date_break                IN DATE
   ,msg                         OUT VARCHAR2
  ) RETURN NUMBER;

  /*  ���������� ��������� ��������� ��� ������ �� �������� �����������
     * @author ������ ������,   ������� 2006
     * @param pv_policy_agent_id �� ������ ������ �� �������� �����������
     * @param p_ag_contract_header_id �� ���������� ��������
     * @param p_cur_date ���� �� ������� ������ �������� ��������� �������
  */
  FUNCTION Define_Agent_Prod_Line
  (
    pv_policy_agent_id      IN NUMBER
   ,p_ag_contract_header_id IN NUMBER
   ,p_cur_date              IN DATE DEFAULT SYSDATE
  ) RETURN NUMBER;
  /* ���������� ���� �� �������������� ������ �� ��� ������
     * @author ������ ������,   ������� 2006
     * @param = p_policy_header_id �� ������ ��������� �������� �����������
     * @param = p_ag_contract_header_id �� ��������� ���������� �������� ������� ���� ���������
     *  @return : <0 - ��� ������ sqlcode , =0 ���� �������������� ������ �� �� �������, >0 - ����� �������������� ������ ��
  */
  FUNCTION check_defined_commission
  (
    p_policy_header_id      IN NUMBER
   ,p_ag_contract_header_id IN NUMBER
  ) RETURN NUMBER;

  /* ���������� ��������, �� ������� ����� ���� ������. ���� ��� ������ ���������,
       �� �������������� ������� ����� ������ �� �������.
     * @author ������ ������,   ������� 2006
     * @param = p_ag_contract_header_id �� ��������� ���������� �������� ������� ���� ���������
     *  @return : 1 - ���� ���� ������� ��������, �� ������� ����� �� �������� ������, � ��� �� ���� �������� ������
                  0 - ���� ���� ������� ������ ��������, �� ������� ����� ������ � ���� ���� ������� ���������� �� ������� ������.
  */

  FUNCTION policy_check_trans(p_ag_contract_header_id NUMBER) RETURN NUMBER;

  /* ���������� � ����������� ID ������� ������
   * ��� ���������� ��������� ������������� ��������������� ������ ������ ����������� ������� ������ ���������
   * ������� � ������� history �������������� ������, ��� �� ����������.
   * @author ���������� �������
   * @param = p_ag_contract_header_id �� ��������� ���������� �������� ������� ���� ���������
  */

  FUNCTION find_id_agent_status(p_ag_contract_header_id NUMBER) RETURN NUMBER;

  /**
  * ���������� ����� ���������������� �������� �� ��������� ��������
  * @author ���������� �������
  * @param = p_pol_header_id ��������� �������� �����������
  */
  FUNCTION find_sum_adm_izd(p_pol_header_id NUMBER) RETURN NUMBER;

  /**
   * ������������ ����������� ��� �� ������ �������� ������ � ������������� ��� �������
  
  * @author ���������� �������
   * @param = p_ag_contract_header_id �� ��������� ���������� �������� ������� ���� ���������
   * @param = p_start_date  ���� ������ ������������ �������
   * @param = p_end_date     ���� ����� ������������ �������
  */

  PROCEDURE attest_agent_SGP
  (
    p_ag_contract_header_id IN NUMBER
   ,p_start_date            DATE
   , -- ���� ������ ������������ �������
    p_end_date              DATE
   , -- ���� ����� ������������ �������
    p_K_SGP                 OUT NUMBER
  );
  /** �� ����� ���������
   * ������������ ����������� ��� �� ������ �������� ������ � ������������� ��� �������
  
  * @author ���������� �������
   * @param = p_ag_contract_header_id �� ��������� ���������� �������� ������� ���� ���������
   * @param = p_start_date  ���� ������ ������������ �������
   * @param = p_end_date     ���� ����� ������������ �������
  */

  PROCEDURE attest_agent_SGP_NEW
  (
    p_ag_contract_header_id IN NUMBER
   ,p_start_date            DATE
   , -- ���� ������ ������������ �������
    p_end_date              DATE
   , -- ���� ����� ������������ �������
    p_K_SGP                 OUT NUMBER
  );

  /*�������� �.�. ���������� ������� ��� ��� ����*/
  PROCEDURE attest_agent_SGP_DAVR
  (
    p_ag_contract_header_id IN NUMBER
   ,p_start_date            DATE
   , -- ���� ������ ������������ �������
    p_end_date              DATE
   , -- ���� ����� ������������ �������
    p_K_SGP                 OUT NUMBER
  );

  /**
   * ������������ ����������� ��� �� ������ �������� ������ � ������������� ��� �������
   * @author �������
   * @param = p_ag_contract_header_id �� ��������� ���������� �������� ������� ���� ���������
   * @param = p_start_date  ���� ������ ������������ �������
   * @param = p_end_date     ���� ����� ������������ �������
   * ���������� ���
  */
  FUNCTION get_SGP_agent
  (
    p_ag_contract_header_id IN NUMBER
   ,p_start_date            DATE
   , -- ���� ������ ������������ �������
    p_end_date              DATE -- ���� ����� ������������ �������
  ) RETURN NUMBER;
  /** �� �����
   * ������������ ����������� ��� �� ������ �������� ������ � ������������� ��� �������
   * @author �������
   * @param = p_ag_contract_header_id �� ��������� ���������� �������� ������� ���� ���������
   * @param = p_start_date  ���� ������ ������������ �������
   * @param = p_end_date     ���� ����� ������������ �������
   * ���������� ���
  */
  FUNCTION get_SGP_agent_new
  (
    p_ag_contract_header_id IN NUMBER
   ,p_start_date            DATE
   , -- ���� ������ ������������ �������
    p_end_date              DATE -- ���� ����� ������������ �������
  ) RETURN NUMBER;

  /*�������� �.�. ��� ������� ����*/
  FUNCTION get_SGP_agent_DAVR
  (
    p_ag_contract_header_id IN NUMBER
   ,p_start_date            DATE
   , -- ���� ������ ������������ �������
    p_end_date              DATE -- ���� ����� ������������ �������
  ) RETURN NUMBER;

  /* ����������� ��� ��� ��������� �� ������
  */
  PROCEDURE KSP_MN
  (
    p_ag_contract_header_id IN NUMBER
   ,p_db                    IN DATE
   ,p_de                    IN DATE
   ,p_KSP                   OUT NUMBER
  );

  /*  ������ ��� ��� ��������� �� ������
  */
  PROCEDURE KSP_DR
  (
    p_ag_contract_header_id IN NUMBER
   ,p_db                    IN DATE
   ,p_de                    IN DATE
   ,p_ksp                   OUT NUMBER
  );

  /**
  * ������������ ������������ �� ������ ��������
   * ��� ���������� �������
   *
   * @author ���������� �������
   * @param = p_ag_contract_header_id �� ��������� ���������� �������� �� �������� ���� ���������� ���������
   * @return p_K_SGP out ����� ������� ������ �� ��������� �����������
   * @return p_K_KD out ���������� ��������� �����������
   * @return p_K_KSP out ����. ���������� ��������
  */
  PROCEDURE attest_agent_status_one
  (
    p_ag_contract_header_id IN NUMBER
   ,p_start_date            IN DATE
   , -- ���� ������ ������������ �������
    p_K_SGP                 OUT NUMBER
   ,p_K_KD                  OUT NUMBER
   ,p_K_KSP                 OUT NUMBER
  );

  /**
   * ������������ ����������� ��� �� ������ �������� ���������-��������� �����,�������
   * ��������� ��� ������������� � ������ PKG_AGENT_RATE
   * � ������������� ��� �������
   *
   * @author ���������� �������
   * @param = p_ag_contract_header_id �� ��������� ���������� �������� ������� ���� ���������
   * @param = p_start_date  ���� ������ ������������ �������
   * @param = p_end_date     ���� ����� ������������ �������
  */
  PROCEDURE manag_SGP_bank
  (
    p_ag_contract_header_id IN NUMBER
   ,p_start_date            DATE
   , -- ���� ������ ������������ �������
    p_end_date              DATE
   , -- ���� ����� ������������ �������
    p_K_SGP                 OUT NUMBER
  );

  /**
   * ������������ ����������� ��� �� ������ �������� ��������� � ������������� ��� �������
  *
  * @author ���������� �������
   * @param = p_ag_contract_header_id �� ��������� ���������� �������� ������� ���� ���������
   * @param = p_start_date  ���� ������ ������������ �������
   * @param = p_end_date     ���� ����� ������������ �������
  */

  PROCEDURE attest_manag_SGP
  (
    p_ag_contract_header_id IN NUMBER
   ,p_start_date            DATE
   , -- ���� ������ ������������ �������
    p_end_date              DATE
   , -- ���� ����� ������������ �������
    p_K_SGP                 OUT NUMBER
  );
  /**
   * ������������ ����������� ��� �� ������ �������� ��������� � ������������� ��� �������
  *
  * @author ���������� �������
   * @param = p_ag_contract_header_id �� ��������� ���������� �������� ������� ���� ���������
   * @param = p_start_date  ���� ������ ������������ �������
   * @param = p_end_date     ���� ����� ������������ �������
  */

  PROCEDURE attest_dr_SGP
  (
    p_ag_contract_header_id IN NUMBER
   ,p_start_date            DATE
   , -- ���� ������ ������������ �������
    p_end_date              DATE
   , -- ���� ����� ������������ �������
    p_K_SGP                 OUT NUMBER
  );

  /**
  * ������������ ������������ �� ������ ��������
   * ��� ���������� ����������
   *
   * @author ���������� �������
   * @param = p_ag_contract_header_id �� ��������� ���������� �������� �� �������� ���� ���������� ���������
   * @return p_K_SGP out ����� ������� ������ �� ��������� �����������
   * @return p_K_KD out ���������� ��������� �����������
   * @return p_K_KSP out ����. ���������� ��������
  */
  PROCEDURE attest_manag_status_one
  (
    p_ag_contract_header_id IN NUMBER
   ,p_start_date            IN DATE
   , -- ���� ������ ������������ �������
    p_K_SGP                 OUT NUMBER
   ,
    /*    p_K_KD out number,*/p_K_KSP OUT NUMBER
  );

  /**
  *������������ ������ �� ������ ���������� ��������
   * ��� ����������
   *
   * @author ���������� �������
   * @param = p_ag_contract_header_id �� ��������� ���������� �������� �� �������� ���� ���������� ���������
   * @param = p_K_SGP ����� ������� ������ �� ��������� �����������
   * @param = p_K_KD ���������� ��������� �����������
   * @param = p_K_KSP ����. ���������� ��������
   * @param = p_categor_id ��� ��������� �������
   * @return = p_status_id ��� ������� �� ������ ����������
  */
  PROCEDURE attest_status_new
  (
    p_ag_contract_header_id IN NUMBER
   ,p_start_date            IN DATE DEFAULT SYSDATE
   , -- ���� ������ ������������ �������
    p_K_SGP                 IN NUMBER
   ,p_K_KD                  IN NUMBER
   ,p_K_KSP                 IN NUMBER
   ,p_categor_id            IN NUMBER
   ,p_status_id             IN OUT NUMBER
  );

  /**
  * ���������� ������ ������������� �� ���� �������/����������
   * ������������ ������ ������� � ��� ������� ��� ������������ ������� � �������� � ������� ������� ��������
   *
   * @author ���������� �������
   * @param p_header_id ��������� ���������� ��������, ���� =0 , �� �� ���� ���������
   * @param p_category_id ������������� (�����/��������)
  */
  PROCEDURE attest_agent_status_all
  (
    p_category_id IN NUMBER
   ,p_header_id   IN NUMBER DEFAULT 0
   ,p_start_date  IN OUT DATE
  );

  /**
  * ���������� �� ���������� ��������� ������ �� ��������
   *
   * @author ���������� �������
   * @param p_ag_contr_id ��� ������ �� ��������
  */
  FUNCTION find_last_ver_id(p_ag_contr_id NUMBER) RETURN NUMBER;

  /**
  * �������� ���� ������������ �������
   *
   * @author ���������� �������
   * @param p_ag_contr_id ��� ������ �� ��������
  */
  PROCEDURE set_current_status_date(p_ag_contr_id NUMBER);

  /**
  *  ���������� �� ������� ������ �� �������� ����
   *
   * @author ����� ���������
   * @param contract_header_id ���� ���������� ��������
   * @param cstatus_date  ���� ������� ������
  */
  FUNCTION get_agent_status_by_date
  (
    contract_header_id NUMBER
   ,status_date        DATE
  ) RETURN NUMBER;

  FUNCTION get_agent_cat_brief_by_date
  (
    contract_header_id NUMBER
   ,status_date        DATE
  ) RETURN VARCHAR2;
  /**
  *  ���������� ���� ������� ������ �� �������� ����
   *
   * @author ������� �.
   * @param contract_header_id ���� ���������� ��������
   * @param cstatus_date  ���� ������� ������
  */
  FUNCTION get_agent_status_brief_by_date
  (
    contract_header_id NUMBER
   ,status_date        DATE
  ) RETURN VARCHAR2;
  /**
  *  ���������� ��� ������� ������ �� �������� ����
   *
   * @author ��������.
   * @param contract_header_id ���� ���������� ��������
   * @param cstatus_date  ���� ������� ������
  */
  FUNCTION get_agent_status_name_by_date
  (
    contract_header_id NUMBER
   ,status_date        DATE
  ) RETURN VARCHAR2;

  /**
  *  ���������� �� ������� ������ �� �������� ����
   *
   * @author ����� ���������
   * @param contract_header_id ���� ���������� ��������
   * @param cstatus_date  ���� ������� ������
  */

  FUNCTION get_agent_cat_st_by_date
  (
    contract_header_id NUMBER
   ,status_date        DATE
  ) RETURN NUMBER;

  ----------------------------------------------
  -- ���������� ���� ������ �������� �������� �����������.
  -- ���� ���� ������ �� �7 �� ������� ���� ������ ��� ���� ��������� �7
  ----------------------------------------------
  FUNCTION get_agent_start_contr
  (
    p_policy_header_id IN NUMBER
   ,par_return         NUMBER DEFAULT 1
  ) RETURN DATE;

  /**
  *  ���������� �� ��������� ������ �� �������� ����
   *
   * @author ���������� �������
   * @param p_contract_header_id ���� ���������� ��������
   * @param p_status_date  ���� ������� ������
  */

  FUNCTION get_agent_cat_by_date
  (
    p_contract_header_id IN NUMBER
   ,p_status_date        IN DATE
  ) RETURN NUMBER;

  /**
  *  ���������  �������� ������� ���������� �������� � ������ "����� � �����������"
   *
   * @author ���������� �������
   * @p_ag_contr_id in number - ��� ������ ���������� ��������
  */
  PROCEDURE set_status_ready_to_cancel(p_ag_contr_id IN NUMBER);

  /**
  * ���������� ���������� ������������ ��� �� �������� �����������.
  * ������������ � ����� AG_REPORT_DET = ���� NUM_YEAR
  * @author ���������� �������
  */
  FUNCTION get_num_year_OAV(p_policy_header_id IN NUMBER) RETURN NUMBER;

  /**
  * ��������������� ��������� ��� ������������� � �������������
  * @author ���������� �������
  */
  FUNCTION get_date RETURN DATE;

  PROCEDURE set_date(p_date IN DATE);

  ------------------------------------------------------------
  --
  -- ����������� ��� �� ��������������� �������
  --
  ------------------------------------------------------------
  FUNCTION attest_recruit_SGP
  (
    p_ag_contract_id NUMBER
   ,p_end_date       DATE
   ,p_start_date     DATE DEFAULT NULL
  ) RETURN NUMBER;

  ------------------------------------------------------------
  --
  -- ����������� ���-�� ��������������� �������
  --
  ------------------------------------------------------------
  FUNCTION attest_count_recruit
  (
    p_ag_contract_id NUMBER
   ,p_end_date       DATE
   ,p_start_date     DATE DEFAULT NULL
  ) RETURN NUMBER;

  /*����������������*/
  FUNCTION find_sum_adm_izd_opt( /*p_pol_header_id number, */ pp_policy_id NUMBER) RETURN NUMBER;
  FUNCTION get_agent_new_to_policy
  (
    polh_id NUMBER
   ,dates   DATE
  ) RETURN NUMBER;
END Pkg_Agent_1;
/
CREATE OR REPLACE PACKAGE BODY Pkg_Agent_1 IS

  --/// --��������� ���������� ������ ��������
  PROCEDURE set_last_ver
  (
    p_contr_id   NUMBER
   ,p_version_id NUMBER
  ) IS
  
    CURSOR k_ver_status IS
      SELECT dsr.brief
            ,ds.start_date
        FROM ven_doc_status     ds
            ,ven_doc_status_ref dsr
       WHERE ds.document_id = p_version_id
         AND ds.doc_status_ref_id = dsr.doc_status_ref_id
         AND TO_CHAR(ds.change_date, 'ddmmyy') = TO_CHAR(SYSDATE, 'ddmmyy')
         AND ds.doc_status_ref_id <> (SELECT doc_status_ref_id
                                        FROM (SELECT h.doc_status_ref_id
                                                FROM ven_doc_status h
                                               WHERE h.document_id = p_contr_id
                                               ORDER BY h.start_date DESC)
                                       WHERE ROWNUM = 1)
         AND dsr.brief <> STATUS_NEW
      UNION
      SELECT dsr.brief
            ,ds.start_date
        FROM ven_doc_status     ds
            ,ven_doc_status_ref dsr
       WHERE ds.document_id = p_version_id
         AND ds.doc_status_ref_id = dsr.doc_status_ref_id
         AND TO_CHAR(ds.change_date, 'ddmmyy') = TO_CHAR(SYSDATE, 'ddmmyy')
         AND NOT EXISTS (SELECT '1'
                FROM ven_doc_status h
               WHERE h.doc_status_ref_id = ds.doc_status_ref_id
                 AND h.document_id = p_contr_id)
       ORDER BY 2;
    /*  cursor k_ver_status is
        select dsr.brief, ds.start_date
        from ven_doc_status ds, ven_doc_status_ref dsr
        where ds.document_id = p_version_id
        and ds.doc_status_ref_id = dsr.doc_status_ref_id
        and to_char(ds.change_date,'ddmmyy')=to_char(sysdate,'ddmmyy')
        and  not exists (select '1' from ven_doc_status h
                         where h.doc_status_ref_id = ds.doc_status_ref_id
                         and   h.document_id = p_contr_id)
        order by ds.start_date ;
    */
    v_ver_status k_ver_status%ROWTYPE;
    err          NUMBER := 0;
    v_br         VARCHAR2(30);
    v_sd         DATE;
  
  BEGIN
    BEGIN
      -- ��������� ����_�����
      UPDATE ven_ag_contract_header
         SET last_ver_id = p_version_id
       WHERE ag_contract_header_id = p_contr_id;
    EXCEPTION
      WHEN OTHERS THEN
        -- if sqlcode<-20000 then err:=sqlcode; else err:=sqlcode-20000;end if;
        RAISE_APPLICATION_ERROR(SQLCODE
                               ,'�� ����������� ����������� ������ ��������. ' || SQLERRM(err));
    END;
    -- ����� ������� ����_����� � ���� ��������� �������
    BEGIN
      OPEN k_ver_status;
      LOOP
        FETCH k_ver_status
          INTO v_ver_status;
        EXIT WHEN k_ver_status%NOTFOUND;
        -- ��������� ���������������� ������� �� ������� �� ����
        Doc.set_doc_status(p_contr_id, v_ver_status.brief, v_ver_status.start_date);
      
        IF v_ver_status.brief = 'BREAK'
        THEN
          UPDATE ven_ag_contract_header h
             SET h.date_break = v_ver_status.start_date
           WHERE h.ag_contract_header_id = p_contr_id;
          --         and h.date_break is null;
        END IF;
      END LOOP;
      CLOSE k_ver_status;
    
    EXCEPTION
      WHEN OTHERS THEN
        IF SQLCODE < -20000
        THEN
          err := SQLCODE;
        ELSE
          err := SQLCODE - 20000;
        END IF;
        RAISE_APPLICATION_ERROR(err
                               ,'�� ����������� ������ ����������� ������ ��������. ' || SQLERRM(err));
    END;
  
  END;
  ------------------------------------------------------------------------

  FUNCTION get_agent_to_policy
  (
    polh_id NUMBER
   ,dates   DATE
  ) RETURN NUMBER IS
    res NUMBER;
  BEGIN
  
    SELECT ag_contract_header_id
      INTO res
      FROM (SELECT pa.ag_contract_header_id
                  ,pa.date_start
              FROM p_policy_agent pa
             WHERE pa.policy_header_id = polh_id --1735412
               AND trunc(pa.date_start) <= dates --to_date('16-10-2008','dd-mm-yyyy')
             ORDER BY pa.date_start DESC)
     WHERE rownum = 1;
  
    RETURN res;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN NULL;
    
  END;

  FUNCTION get_agent_new_to_policy
  (
    polh_id NUMBER
   ,dates   DATE
  ) RETURN NUMBER IS
    res NUMBER;
  BEGIN
  
    SELECT ag_contract_header_id
      INTO res
      FROM (SELECT pad.ag_contract_header_id
                  ,pad.date_begin
              FROM p_policy_agent_doc pad
             WHERE pad.policy_header_id = polh_id --1735412
               AND trunc(pad.date_begin) <= dates --to_date('16-10-2008','dd-mm-yyyy')
             ORDER BY pad.date_begin ASC)
     WHERE rownum = 1;
  
    RETURN res;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN NULL;
    
  END;

  ------------------------------------------------------------------------
  --�������� �.�. 14-09-2009
  FUNCTION get_agent_pol
  (
    polh_id NUMBER
   ,dates   DATE
  ) RETURN VARCHAR2 IS
    res VARCHAR2(250);
  BEGIN
  
    SELECT obj_name_orig
      INTO res
      FROM (SELECT pa.ag_contract_header_id
                  ,c.obj_name_orig
                  ,pa.date_start
              FROM p_policy_agent     pa
                  ,ag_contract_header h
                  ,contact            c
             WHERE pa.policy_header_id = polh_id --1735412
               AND pa.ag_contract_header_id = h.ag_contract_header_id
               AND h.agent_id = c.contact_id
               AND trunc(pa.date_start) <= dates --to_date('16-10-2008','dd-mm-yyyy')
             ORDER BY pa.date_start DESC)
     WHERE rownum = 1;
  
    RETURN res;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN NULL;
    
  END;
  ----------------------------------------------------------
  --�������� �.�. 14-09-2009
  FUNCTION get_agentlider_pol
  (
    polh_id NUMBER
   ,dates   DATE
  ) RETURN VARCHAR2 IS
    res VARCHAR2(250);
  BEGIN
    SELECT obj_name_orig
      INTO res
      FROM (SELECT ch.obj_name_orig
                  ,pag.date_start
              FROM p_policy_agent     pag
                  ,ag_contract_header ag
                  ,ag_contract        cont
                  ,ag_contract        conth
                  ,ag_contract_header agh
                  ,contact            ch
                  ,contact            c
             WHERE pag.ag_contract_header_id = ag.ag_contract_header_id
               AND cont.ag_contract_id = ag.last_ver_id
               AND cont.contract_leader_id = conth.ag_contract_id(+)
               AND conth.contract_id = agh.ag_contract_header_id(+)
               AND ch.contact_id(+) = agh.agent_id
               AND ag.agent_id = c.contact_id
               AND pag.policy_header_id = polh_id
               AND trunc(pag.date_start) <= dates
             ORDER BY pag.date_start DESC)
     WHERE rownum = 1;
    RETURN res;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN NULL;
    
  END;

  ------------------------------------------------------------------------
  --/// --��������� ���������� ������ ��������
  PROCEDURE set_last_ver_ROMA
  (
    p_contr_id   NUMBER
   ,p_version_id NUMBER
  ) IS
  
    CURSOR k_ver_status IS
      SELECT dsr.brief
            ,ds.start_date
        FROM ven_doc_status     ds
            ,ven_doc_status_ref dsr
            ,AG_CONTRACT        c
       WHERE ds.document_id = c.ag_contract_id
         AND ds.document_id = p_version_id
         AND ds.doc_status_ref_id = dsr.doc_status_ref_id
            --and to_char(ds.change_date, 'ddmmyy') = to_char(sysdate, 'ddmmyy')
         AND NOT EXISTS (SELECT h.doc_status_ref_id
                FROM ven_doc_status h
               WHERE h.document_id = c.contract_id
                 AND ds.doc_status_ref_id = h.doc_status_ref_id)
         AND dsr.brief <> STATUS_NEW
      UNION
      -- ���������� � ������� ��������� �������, ���� �� ���������� �� �������� ������� ��
      SELECT Doc.get_doc_status_brief(p_version_id, date_ag.start_date)
            ,date_ag.start_date
        FROM (SELECT NVL(MAX(ds.start_date), SYSDATE) start_date
                FROM ven_doc_status ds
               WHERE ds.document_id = p_version_id) date_ag
       WHERE Doc.get_doc_status_brief(p_version_id, date_ag.start_date) <>
             Doc.get_doc_status_brief(p_contr_id, date_ag.start_date);
    /*  cursor k_ver_status is
        select dsr.brief, ds.start_date
        from ven_doc_status ds, ven_doc_status_ref dsr
        where ds.document_id = p_version_id
        and ds.doc_status_ref_id = dsr.doc_status_ref_id
        and to_char(ds.change_date,'ddmmyy')=to_char(sysdate,'ddmmyy')
        and  not exists (select '1' from ven_doc_status h
                         where h.doc_status_ref_id = ds.doc_status_ref_id
                         and   h.document_id = p_contr_id)
        order by ds.start_date ;
    */
    v_ver_status k_ver_status%ROWTYPE;
    err          NUMBER := 0;
    v_br         VARCHAR2(30);
    v_sd         DATE;
  
  BEGIN
    BEGIN
      -- ��������� ����_�����
      UPDATE ven_ag_contract_header
         SET last_ver_id = p_version_id
       WHERE ag_contract_header_id = p_contr_id;
    EXCEPTION
      WHEN OTHERS THEN
        -- if sqlcode<-20000 then err:=sqlcode; else err:=sqlcode-20000;end if;
        RAISE_APPLICATION_ERROR(-20001
                               ,'�� ����������� ����������� ������ ��������. ' || SQLERRM(err));
    END;
    -- ����� ������� ����_����� � ���� ��������� �������
    BEGIN
      OPEN k_ver_status;
      LOOP
        FETCH k_ver_status
          INTO v_ver_status;
        EXIT WHEN k_ver_status%NOTFOUND;
        -- ��������� ���������������� ������� �� ������� �� ����
        Doc.set_doc_status(p_contr_id, v_ver_status.brief, v_ver_status.start_date);
      
        IF v_ver_status.brief = 'BREAK'
        THEN
          UPDATE ven_ag_contract_header h
             SET h.date_break = v_ver_status.start_date
           WHERE h.ag_contract_header_id = p_contr_id;
          --         and h.date_break is null;
        END IF;
      END LOOP;
      CLOSE k_ver_status;
    
    EXCEPTION
      WHEN OTHERS THEN
        /* if sqlcode < -20000 then
          err := sqlcode;
        else
          err := sqlcode - 20000;
        end if;*/
        RAISE_APPLICATION_ERROR(-20001
                               ,'�� ����������� ������ ����������� ������ ��������. ' ||
                                SQLERRM(SQLCODE));
    END;
  
  END;

  PROCEDURE set_last_agency
  (
    p_contr_id  NUMBER
   ,p_agency_id NUMBER
  ) IS
    v_c        NUMBER;
    v_agent_id NUMBER;
  BEGIN
  
    UPDATE ven_ag_contract_header
       SET agency_id = p_agency_id
     WHERE ag_contract_header_id = p_contr_id;
    ----//// ���������� ������������
    BEGIN
      SELECT h.agent_id
        INTO v_agent_id
        FROM ven_ag_contract_header h
       WHERE h.ag_contract_header_id = p_contr_id;
    
      SELECT COUNT(*) INTO v_c FROM ven_dept_agent WHERE agent_id = v_agent_id;
    
      IF v_c = 0
      THEN
        INSERT INTO ven_dept_agent (agent_id, department_id) VALUES (v_agent_id, p_agency_id);
      ELSE
        UPDATE ven_dept_agent SET department_id = p_agency_id WHERE agent_id = v_agent_id;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;
    ----\\\\ ���������� ������������
  EXCEPTION
    WHEN OTHERS THEN
    
      RAISE_APPLICATION_ERROR(-20001
                             ,'������ ���������� ������������. (p_contr_id=' || p_contr_id ||
                              '). ��. ������ Oracle:' || SQLERRM(SQLCODE));
    
  END;
  -------------------------------------------------------------------------

  --/// -- �������� ������ ������ � ������ �� ������
  PROCEDURE set_current_status
  (
    p_ver_id       IN NUMBER
   ,p_status_brief VARCHAR2
  ) IS
    v_contr_id  NUMBER;
    v_agency_id NUMBER;
  BEGIN
    IF can_be_current(p_ver_id) = 1
    THEN
      -- ������������� ������
      Doc.set_doc_status(p_ver_id, p_status_brief);
      -- � ����� ������������� ������ �� ����������� ������
      SELECT c.contract_id
            ,c.agency_id
        INTO v_contr_id
            ,v_agency_id
        FROM ven_ag_contract c
       WHERE c.ag_contract_id = p_ver_id;
    
      set_last_ver(v_contr_id, p_ver_id);
      set_last_agency(v_contr_id, v_agency_id);
    
      -- else
      --  raise_application_error(-20002,
      --                        '���������� �������� ������ ������� ������');
    END IF;
  END;
  ------------------------------------------------------------------------------
  FUNCTION get_num_contract RETURN VARCHAR2 IS
    ret_val VARCHAR2(255);
  BEGIN
    SELECT sq_ag_contract_num.NEXTVAL INTO ret_val FROM dual;
    ret_val := SUBSTR(TO_CHAR(ret_val), LENGTH(ret_val) - 5, 6);
    RETURN ret_val;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  FUNCTION get_status_contr(p_contr_id NUMBER) RETURN NUMBER IS
    v_status_id NUMBER;
    v_last_ver  NUMBER;
  BEGIN
    SELECT ch.last_ver_id
      INTO v_last_ver
      FROM ven_ag_contract_header ch
     WHERE ch.ag_contract_header_id = p_contr_id;
  
    v_status_id := Doc.get_doc_status_ID(v_last_ver);
  
    RETURN v_status_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN NULL;
  END;

  FUNCTION get_status_contr_activ_name(p_contr_id NUMBER) RETURN VARCHAR2 IS
    v_status_id NUMBER;
    v_status1   VARCHAR2(50);
  BEGIN
    v_status_id := get_status_contr_activ(p_contr_id);
    SELECT NAME INTO v_status1 FROM DOC_STATUS_REF WHERE doc_status_ref_id = v_status_id;
    RETURN v_status1;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN NULL;
  END;

  FUNCTION get_status_contr_activ_brief(p_contr_id NUMBER) RETURN VARCHAR2 IS
    v_status_id NUMBER;
    v_status1   VARCHAR2(50);
  BEGIN
    v_status_id := get_status_contr_activ(p_contr_id);
    SELECT r.brief INTO v_status1 FROM DOC_STATUS_REF r WHERE doc_status_ref_id = v_status_id;
    RETURN v_status1;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN NULL;
  END;

  FUNCTION get_status_by_date
  (
    p_ag_contract_header_id NUMBER
   ,p_date                  DATE
  ) RETURN NUMBER IS
    v_ch_num      VARCHAR2(25);
    v_cont_ver_id NUMBER;
  BEGIN
    /*    select ch.num
     into v_ch_num
     from ven_ag_contract_header ch
    where ch.ag_contract_header_id = p_ag_contract_header_id;*/
  
    /*SELECT MAX(c.num) num
    INTO v_ch_num
                  FROM ven_ag_contract c
                 WHERE c.contract_id = p_ag_contract_header_id
                  -- and doc.get_doc_status_brief(c.ag_contract_id) <> STATUS_NEW
                   AND c.date_begin <= p_date;
    
        SELECT c1.ag_contract_id
          INTO v_cont_ver_id
          FROM ven_ag_contract c1
         WHERE c1.num = v_ch_num
    
              --??? �� ������� � ���� ��� ������� ��� --and doc.get_doc_status_brief(c1.ag_contract_id) in (STATUS_RESUME,STATUS_CURRENT)
           AND c1.contract_id = p_ag_contract_header_id;*/
    --�������� �.�. 29/11/2009 - ��������� �� ����������� � ����������, �� �������� ������
    SELECT MAX(C1.AG_CONTRACT_ID) KEEP(dense_rank FIRST ORDER BY c1.date_begin DESC, c1.ag_contract_id DESC)
      INTO V_CONT_VER_ID
      FROM AG_CONTRACT C1
     WHERE C1.CONTRACT_ID = P_AG_CONTRACT_HEADER_ID
       AND c1.date_begin <= P_DATE;
  
    RETURN v_cont_ver_id;
  
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      -- �� �����
      RETURN NULL;
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20001
                             ,'���������� ���������� ������ ���������� �������� (p_ag_contract_header_id: ' ||
                              p_ag_contract_header_id || ') �� ����: ' ||
                              TO_CHAR(p_date, 'DD.MM.YYYY') || '. ������ Oracle: ' ||
                              SQLERRM(SQLCODE));
    
  END;

  FUNCTION get_status_contr_activ(p_contr_id NUMBER) RETURN NUMBER IS
    v_status_id NUMBER;
    v_last_ver  NUMBER;
    v_ch_num    VARCHAR2(25);
  BEGIN
    --���������� �� ������� �������� ������
    v_last_ver  := get_status_contr_activ_id(p_contr_id);
    v_status_id := Doc.get_doc_status_id(v_last_ver);
    /*  for v_c in (select c.ag_contract_id,
                       doc.get_doc_status_brief(c.ag_contract_id) status,
                       to_number(num) as num
                from ven_ag_contract c
                where c.contract_id=p_contr_id
                order by num)
    LOOP
       if ((v_c.num=0)
           or
           (v_c.status<>STATUS_NEW and v_c.num<>0))
       then
          v_status_id:=doc.get_doc_status_ID(V_c.ag_contract_id);
       end if;
    END LOOP; */
    RETURN v_status_id;
  END;

  FUNCTION get_status_contr_activ_id(p_contr_id NUMBER) RETURN NUMBER IS
    v_contr_id NUMBER;
    v_last_ver NUMBER;
    v_ch_num   VARCHAR2(25);
  BEGIN
    --���������� �� ���������� ������ �� ��������
    SELECT ch.last_ver_id
      INTO v_contr_id
      FROM ven_ag_contract_header ch
     WHERE ch.ag_contract_header_id = p_contr_id;
    RETURN v_contr_id;
    /* for v_c in (select c.ag_contract_id,
                       doc.get_doc_status_brief(c.ag_contract_id) status,
                       to_number(num) as num
                from ven_ag_contract c
                where c.contract_id=p_contr_id
                order by num)
    LOOP
       if ((v_c.num=0)
           or
           (v_c.status<>STATUS_NEW and v_c.num<>0))
       then
          v_contr_id:=V_c.ag_contract_id;
       end if;
    END LOOP;
    return v_contr_id;
    */
  END;

  FUNCTION get_end_contr(p_contr_id NUMBER) RETURN DATE IS
    de DATE;
  BEGIN
    SELECT c.date_end
      INTO de
      FROM ven_ag_contract c
     WHERE c.ag_contract_id = (SELECT h.last_ver_id
                                 FROM ven_ag_contract_header h
                                WHERE h.ag_contract_header_id = p_contr_id);
    RETURN de;
  END;

  PROCEDURE set_version_status
  (
    p_doc_id    IN NUMBER
   , --�� ���.����������
    p_status_id IN NUMBER
  ) IS
    v_header_id NUMBER;
    de          DATE;
    v_agency_id NUMBER;
    err         NUMBER;
  BEGIN
    IF can_be_current(p_doc_id) = 1
    THEN
      Doc.set_doc_status(p_doc_id, p_status_id);
    
      SELECT ac.contract_id
            ,ac.date_end
            ,ac.agency_id
        INTO v_header_id
            ,de
            ,v_agency_id
        FROM ven_ag_contract ac
       WHERE ac.ag_contract_id = p_doc_id;
    
      IF get_end_contr(v_header_id) <> de
      THEN
        UPDATE ven_ag_prod_line_contr t SET t.date_end = de WHERE t.ag_contract_id = p_doc_id;
        --commit;
      END IF;
    
      set_last_ver(v_header_id, p_doc_id);
      set_last_agency(v_header_id, v_agency_id);
      --   else
      --  raise_application_error(-20003,
      --                          '������ �������� ������ ������ ������');
    
    END IF;
  
  EXCEPTION
    WHEN OTHERS THEN
      -- � � ����!!!
      /*   if sqlcode < -20000 then
        err := sqlcode;
      else
        err := sqlcode - 20000;
      end if;
      raise_application_error(err,
                              '�� ����������� ������ ������.' || chr(10) ||
                              sqlerrm(err));*/
      RAISE_APPLICATION_ERROR(-20001
                             ,'�� ����������� ������ ������.' || CHR(10) || SQLERRM(SQLCODE));
  END;

  PROCEDURE set_version_status
  (
    p_doc_id       IN NUMBER
   , --�� ���.����������
    p_status_brief IN VARCHAR2
  ) IS
    v_status_id NUMBER;
  BEGIN
    SELECT t.doc_status_ref_id
      INTO v_status_id
      FROM ven_doc_status_ref t
     WHERE t.brief = p_status_brief;
  
    set_version_status(p_doc_id, v_status_id);
  END;

  FUNCTION can_be_current(p_version_id IN NUMBER) RETURN NUMBER IS
    v_ret NUMBER := 0;
  BEGIN
    -- �� - ���� ������� ������ �����
    IF Doc.get_doc_status_brief(p_version_id) = 'NEW'
    THEN
      v_ret := 1;
    END IF;
    RETURN v_ret;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
  END;

  --
  FUNCTION can_be_copied(p_version_id IN NUMBER) RETURN NUMBER IS
    v_ret     NUMBER := 0;
    v_num     NUMBER := 0;
    v_num_ver VARCHAR2(50);
    v_st      VARCHAR2(100);
    v_ver_id  NUMBER;
    v_ch_id   NUMBER;
    v_date    DATE;
  BEGIN
    -- �� - ���� ��� ��������� ���������� ������
    SELECT c.contract_id
          ,c.num
          ,Doc.get_doc_status_brief(c.ag_contract_id)
      INTO v_ch_id
          ,v_num_ver
          ,v_st
      FROM ven_ag_contract c
     WHERE c.ag_contract_id = p_version_id;
  
    SELECT ch.last_ver_id
      INTO v_ver_id
      FROM ven_ag_contract_header ch
     WHERE ch.ag_contract_header_id = v_ch_id;
  
    --v_ver_id:=get_status_contr_activ_id(v_ch_id);
    IF v_ver_id = p_version_id
    THEN
      --� ���� ��� ������ �����
      FOR c IN (SELECT * FROM ven_ag_contract c2 WHERE c2.contract_id = v_ch_id)
      LOOP
        -- ����������� ���� ������� ��� ������ ������ ��������
        v_date := NVL(Doc.get_last_doc_status_date(c.ag_contract_id), SYSDATE);
        -- ������� ����� ������ �� ��������
        IF Doc.get_doc_status_brief(c.ag_contract_id, v_date) = 'NEW'
        THEN
          v_num := v_num + 1;
        END IF;
      END LOOP;
    
      /*     -- ���������� ������ �������� ����� ������
             select count(*) into v_num
             from ven_ag_contract c2
             where c2.contract_id=v_ch_id
               and doc.get_doc_status_brief(c2.ag_contract_id) = 'NEW';
      */
      IF v_num = 0
      THEN
        v_ret := 1;
      ELSE
        v_ret := 0;
      END IF;
    
    ELSE
      v_ret := 0;
    END IF;
    --���� ��� �� ����� ������ ������ � ������� �����
    IF v_st = 'NEW'
       AND v_num_ver = 0
    THEN
      v_ret := 0;
    END IF;
  
    RETURN v_ret;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
  END;

  FUNCTION can_be_del(p_version_id IN NUMBER) RETURN NUMBER IS
    v_r     NUMBER := 0;
    v_ver   NUMBER;
    v_ch_id NUMBER;
    v_date  DATE := SYSDATE;
  BEGIN
    -- ����������� ������������ ���� ������� �� ���������
    v_date := NVL(Doc.get_last_doc_status_date(p_version_id), SYSDATE);
    -- ���� ������ ������ - �����
    IF Doc.get_doc_status_brief(p_version_id, v_date) = 'NEW'
    THEN
      v_r := 1;
    END IF;
    -- � ���� ��� �� ����� ������ ������ � ������� ����� (��� ������ �������� �� �����)
    IF v_r = 1
    THEN
      SELECT c.contract_id INTO v_ch_id FROM ven_ag_contract c WHERE c.ag_contract_id = p_version_id;
    
      IF Doc.get_doc_status_brief(v_ch_id, v_date) = 'NEW'
      THEN
        v_r := 0;
        /*select count(*)
          into v_ver
          from ven_ag_contract v
         where v.contract_id =
               (select c.contract_id
                  from ven_ag_contract c
                 where c.ag_contract_id = p_version_id);
        
        if v_ver = 1 then
          v_r := 0; */
      END IF;
    END IF;
    RETURN v_r;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
  END;

  FUNCTION get_ver_num(p_contract_id IN NUMBER) --�� ���������
   RETURN VARCHAR2 IS
    p_num          VARCHAR2(50);
    v_num          NUMBER;
    v_contract_num VARCHAR(10);
  BEGIN
    --������� ��������� ������ �� ������� ��������
    SELECT MAX(TO_NUMBER(SUBSTR(LTRIM(c.num, ch.num), 2))) -- max(to_number(ltrim(c.num,ch.num||'/')))
      INTO v_num
      FROM ven_ag_contract_header ch
          ,ven_ag_contract        c
     WHERE ch.ag_contract_header_id = c.contract_id
       AND ch.ag_contract_header_id = p_contract_id;
  
    SELECT t.num
      INTO v_contract_num
      FROM ven_ag_contract_header t
     WHERE t.ag_contract_header_id = p_contract_id; --(select c.contract_id from ven_ag_contract c where c.ag_contract_id=p_contract_id);
    --������ �����
    IF v_num IS NULL
    THEN
      p_num := v_contract_num || '/0';
    ELSE
      p_num := v_contract_num || '/' || (v_num + 1);
    END IF;
    RETURN p_num;
  END;

  --���������� ������ ��������
  PROCEDURE version_insert
  (
    p_contract_id        NUMBER
   , --�� ���������
    p_date_begin         DATE DEFAULT SYSDATE
   ,p_date_end           DATE
   ,p_class_agent_id     NUMBER DEFAULT NULL
   ,p_category_id        NUMBER DEFAULT NULL
   ,p_note               VARCHAR2 DEFAULT NULL
   ,p_obj_id             IN OUT NUMBER
   , --�� ��� ����������
    p_CONTRACT_LEADER_ID NUMBER DEFAULT NULL
   ,p_RATE_AGENT         NUMBER DEFAULT NULL
   ,p_RATE_MAIN_AGENT    NUMBER DEFAULT NULL
   ,p_RATE_TYPE_ID       NUMBER DEFAULT NULL
   ,p_RATE_TYPE_MAIN_ID  NUMBER DEFAULT NULL
   ,p_fact_dop_rate      NUMBER DEFAULT 0
   ,p_contract_f_lead_id NUMBER DEFAULT NULL
   ,p_contract_recrut_id NUMBER DEFAULT NULL
   ,p_method_payment     NUMBER DEFAULT 0
   ,p_is_call_center     NUMBER DEFAULT 0
   ,p_leg_pos            NUMBER DEFAULT 0
   ,p_date_break         DATE DEFAULT SYSDATE
   ,p_templ_id           NUMBER DEFAULT NULL
   ,p_agency_id          NUMBER DEFAULT NULL
  ) IS
  
    v_status_brief VARCHAR2(10) := 'NEW';
    db             DATE;
    de             DATE;
    v_num          VARCHAR2(10);
    v_Doc_Templ_ID NUMBER;
    v_date_begin   DATE;
    v_prizn_sh     NUMBER := 0; -- ������� �������
  BEGIN
  
    SELECT date_begin
          ,get_end_contr(p_contract_id)
          ,ag_contract_templ_k
      INTO db
          ,de
          ,v_prizn_sh
      FROM ven_ag_contract_header h
     WHERE h.ag_contract_header_id = p_contract_id;
  
    SELECT COUNT(*) INTO v_num FROM ven_ag_contract ac WHERE ac.contract_id = p_contract_id;
    --    v_num := get_ver_num(p_contract_id);
  
    SELECT dt.doc_templ_id INTO v_Doc_Templ_ID FROM DOC_TEMPL dt WHERE dt.brief = 'AG_CONTRACT';
  
    IF ((db <= p_date_begin OR de >= p_date_end) /*and
                            (v_prizn_sh < 2 and p_category_id is not null)*/
       )
    THEN
      BEGIN
        IF p_obj_id IS NULL
        THEN
          SELECT sq_ag_contract.NEXTVAL INTO p_obj_id FROM dual;
        END IF;
      
        INSERT INTO ven_ag_contract a
          (doc_templ_id
          ,note
          ,num
          ,reg_date
          ,ag_contract_id
          ,class_agent_id
          ,category_id
          ,date_begin
          ,date_end
          ,contract_id
          ,CONTRACT_LEADER_ID
          ,RATE_AGENT
          ,RATE_MAIN_AGENT
          ,RATE_TYPE_ID
          ,RATE_TYPE_MAIN_ID
          ,fact_dop_rate
          ,contract_f_lead_id
          ,contract_recrut_id
          ,method_payment
          ,is_call_center
          ,leg_pos
          ,AG_CONTRACT_TEMPL_ID
          ,agency_id)
        VALUES
          (v_Doc_Templ_ID
          ,p_note
          ,v_num
          ,SYSDATE
          ,p_obj_id
          ,p_class_agent_id
          ,p_category_id
          ,p_date_begin
          ,p_date_end
          ,p_contract_id
          ,p_CONTRACT_LEADER_ID
          ,p_RATE_AGENT
          ,p_RATE_MAIN_AGENT
          ,p_RATE_TYPE_ID
          ,p_RATE_TYPE_MAIN_ID
          ,p_fact_dop_rate
          ,p_contract_f_lead_id
          ,p_contract_recrut_id
          ,p_method_payment
          ,p_is_call_center
          ,p_leg_pos
          ,p_templ_id
          ,p_agency_id);
      
        IF p_date_begin > SYSDATE
        THEN
          v_date_begin := SYSDATE;
        ELSE
          v_date_begin := NVL(p_date_begin, SYSDATE);
        END IF;
      
        Doc.set_doc_status(p_obj_id, v_status_brief, v_date_begin);
      
        IF NVL(p_date_begin, v_date_begin) <> v_date_begin
        THEN
          -- ��������� ���� �������� ������� �� ���������
          UPDATE DOC_STATUS s
             SET s.start_date  = p_date_begin
                ,s.change_date = SYSDATE
           WHERE s.doc_status_id = Doc.get_last_doc_status_id(p_obj_id);
        END IF;
      
        -- doc.set_doc_status(p_obj_id, v_status_brief,NVL(p_date_break,SYSDATE));
      
        --commit;
      
      END;
    END IF;
  END;

  PROCEDURE version_update
  (
    p_contract_id        NUMBER
   , --�� ���������
    p_date_begin         DATE
   ,p_date_end           DATE
   ,p_class_agent_id     NUMBER DEFAULT NULL
   ,p_category_id        NUMBER DEFAULT NULL
   ,p_note               VARCHAR2
   ,p_ver_id             NUMBER
   , --�� ��� ����������
    p_CONTRACT_LEADER_ID NUMBER DEFAULT NULL
   ,p_RATE_AGENT         NUMBER DEFAULT NULL
   ,p_RATE_MAIN_AGENT    NUMBER DEFAULT NULL
   ,p_RATE_TYPE_ID       NUMBER DEFAULT NULL
   ,p_RATE_TYPE_MAIN_ID  NUMBER DEFAULT NULL
   ,p_fact_dop_rate      NUMBER DEFAULT 0
   ,p_contract_f_lead_id NUMBER DEFAULT NULL
   ,p_contract_recrut_id NUMBER DEFAULT NULL
   ,p_method_payment     NUMBER DEFAULT 0
   ,p_is_call_center     NUMBER DEFAULT 0
   ,p_leg_pos            NUMBER DEFAULT 0
   ,p_agency_id          NUMBER DEFAULT NULL
   ,p_comm_holding       NUMBER DEFAULT 0
    -- p_num varchar2 default null,
    --  p_num_old varchar2 default null
  ) IS
    db            DATE;
    db_old        DATE;
    de_old        DATE;
    v_class_agent NUMBER;
    v_category_id NUMBER;
    v_note        VARCHAR2(1000);
    v_db          DATE;
    v_de          DATE;
    v_prizn_sh    NUMBER := 0;
    --v_num         varchar2(50);
  BEGIN
    --���� ������ ���.���������� �����, ����� �������� ��������������
    --   if (doc.get_doc_status_brief(p_ver_id) = 'NEW') then
    BEGIN
      SELECT h.ag_contract_templ_k
        INTO v_prizn_sh
        FROM ven_ag_contract_header h
       WHERE h.ag_contract_header_id = p_contract_id;
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;
  
    BEGIN
      SELECT c.class_agent_id
            ,c.category_id
            ,c.note
            ,c.date_begin
            ,c.date_end --,
      -- c.num
        INTO v_class_agent
            ,v_category_id
            ,v_note
            ,v_db
            ,v_de --, v_num
        FROM ven_ag_contract c
       WHERE c.ag_contract_id = p_ver_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
    END;
  
    de_old        := v_de;
    db_old        := v_db;
    v_class_agent := NVL(p_class_agent_id, v_class_agent);
    IF v_prizn_sh > 1
    THEN
      v_category_id := p_category_id;
    ELSE
      v_category_id := NVL(p_category_id, v_category_id);
    END IF;
    v_note := NVL(p_note, v_note);
    v_db   := NVL(p_date_begin, v_db);
    v_de   := NVL(p_date_end, v_de);
  
    --��������: ���� ������ ��������<=���� ������ ������
    SELECT date_begin
      INTO db
      FROM ven_ag_contract_header h
     WHERE h.ag_contract_header_id = p_contract_id;
  
    IF v_db < db
    THEN
      v_db := db; --sysdate;
    END IF;
  
    UPDATE ven_ag_contract t
       SET t.note               = v_note
          ,t.class_agent_id     = v_class_agent
          ,t.category_id        = v_category_id
          ,t.date_begin         = v_db
          ,t.date_end           = v_de
          ,t.contract_leader_id = p_CONTRACT_LEADER_ID
          ,t.rate_agent         = p_RATE_AGENT
          ,t.rate_main_agent    = p_RATE_MAIN_AGENT
          ,t.rate_type_id       = p_RATE_TYPE_ID
          ,t.rate_type_main_id  = p_RATE_TYPE_MAIN_ID
          ,t.fact_dop_rate      = p_fact_dop_rate
          ,t.contract_f_lead_id = p_contract_f_lead_id
          ,t.contract_recrut_id = p_contract_recrut_id
          ,t.method_payment     = p_method_payment
          ,t.is_call_center     = p_is_call_center
          ,t.leg_pos            = p_leg_pos
          ,t.agency_id          = p_agency_id
          ,t.is_comm_holding    = p_comm_holding
    --  t.num = v_num
     WHERE t.ag_contract_id = p_ver_id;
  
    IF de_old <> v_de
    THEN
      UPDATE ven_ag_prod_line_contr t SET t.date_end = v_de WHERE t.ag_contract_id = p_ver_id;
    END IF;
    IF db_old <> v_db
    THEN
      UPDATE ven_ag_prod_line_contr t
         SET t.date_begin = v_db
       WHERE t.ag_contract_id = p_ver_id
         AND t.date_begin < v_db;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20007
                             ,'�� ����������� ������. ' || SQLERRM(SQLCODE));
    
  END;

  PROCEDURE version_del(p_ver_id NUMBER) IS
  
    v_ch_id NUMBER;
    v_c_id  NUMBER;
  BEGIN
    --   if can_be_del(p_ver_id) = 1 then
    SELECT ac.contract_id INTO v_ch_id FROM ven_ag_contract ac WHERE ac.ag_contract_id = p_ver_id;
    --������� ���� �����
    prod_line_contr_del(p_ver_id, NULL);
    --������� ���
    DELETE FROM ven_ag_dav dav WHERE dav.contract_id = p_ver_id;
    --������� ������
    DELETE FROM ven_ag_contract WHERE ag_contract_id = p_ver_id;
    --������� ������
    DELETE FROM ven_doc_status WHERE document_id = p_ver_id;
    --������� ����
    DELETE FROM ven_ag_plan_dop_rate r WHERE r.ag_contract_id = p_ver_id;
    --������� ��������
    DELETE FROM ven_ag_commiss com WHERE com.parent_id = p_ver_id;
    DELETE FROM ven_ag_commiss com WHERE com.child_id = p_ver_id;
    /* ������� ����� ������ ������ � ������� �����
     � �� �������� ������ �� ��������� ���������� ������,
     ������������� ������ ������ �� ����
    
     --��������� ������ �� ��������� ������ �� ��������
    select ac.ag_contract_id
      into v_c_id
      from ven_ag_contract ac, ven_ag_contract_header  ach
      where ach.ag_contract_header_id = ac.contract_id
        and ac.num=(
             select max(to_number(c.num)) m
               from ven_ag_contract_header ch, ven_ag_contract c
              where ch.ag_contract_header_id = c.contract_id
                and ch.ag_contract_header_id = v_ch_id)
        and ach.ag_contract_header_id = v_ch_id;
    
    update ven_ag_contract_header h
       set h.last_ver_id=v_c_id
    where h.ag_contract_header_id=v_ch_id;     */
    --   else
    --     null;
    --   end if;
    -- commit;
  END;

  PROCEDURE contract_insert
  (
    p_contr_id            OUT NUMBER
   ,p_vers_id             OUT NUMBER
   ,p_num                 VARCHAR2
   ,p_date_begin          DATE DEFAULT SYSDATE
   ,p_date_end            DATE
   ,p_having_subagents    NUMBER DEFAULT 0
   ,p_agent_id            NUMBER
   ,p_rlp_num             NUMBER DEFAULT NULL
   ,p_date_break          DATE DEFAULT NULL
   ,p_agency_id           NUMBER DEFAULT NULL
   ,p_note                VARCHAR2 DEFAULT NULL
   ,p_class_agent_id      NUMBER DEFAULT NULL
   ,p_category_id         NUMBER DEFAULT NULL
   ,p_CONTRACT_LEADER_ID  NUMBER DEFAULT NULL
   ,p_RATE_AGENT          NUMBER DEFAULT NULL
   ,p_RATE_MAIN_AGENT     NUMBER DEFAULT NULL
   ,p_RATE_TYPE_ID        NUMBER DEFAULT NULL
   ,p_RATE_TYPE_MAIN_ID   NUMBER DEFAULT NULL
   ,p_fact_dop_rate       NUMBER DEFAULT 0
   ,p_note_ver            VARCHAR2 DEFAULT NULL
   ,p_sales_channel_id    NUMBER
   ,p_AG_CONTRACT_TEMP_ID NUMBER DEFAULT NULL
   ,p_contract_f_lead_id  NUMBER DEFAULT NULL
   ,p_contract_recrut_id  NUMBER DEFAULT NULL
   ,p_method_payment      NUMBER DEFAULT 0
   ,p_is_call_center      NUMBER DEFAULT 0
   ,p_leg_pos             NUMBER DEFAULT 0
    
  ) IS
    v_obj_id_contr NUMBER;
    v_obj_id_vers  NUMBER;
    v_status_id    NUMBER;
    v_Doc_Templ_ID NUMBER;
    v_rez          NUMBER;
  BEGIN
    IF (p_date_begin < p_date_end /*and p_agent_id is not null*/
       AND p_date_begin IS NOT NULL AND p_date_end IS NOT NULL)
    THEN
    
      IF p_contr_id IS NULL
      THEN
        SELECT sq_ag_contract_header.NEXTVAL INTO v_obj_id_contr FROM dual;
      ELSE
        v_obj_id_contr := p_contr_id;
      END IF;
    
      IF p_vers_id IS NULL
      THEN
        SELECT sq_ag_contract.NEXTVAL INTO v_obj_id_vers FROM dual;
      ELSE
        v_obj_id_vers := p_vers_id;
      END IF;
    
      SELECT v.doc_status_ref_id INTO v_status_id FROM ven_doc_status_ref v WHERE v.brief = 'NEW';
    
      SELECT dt.doc_templ_id
        INTO v_Doc_Templ_ID
        FROM DOC_TEMPL dt
       WHERE dt.brief = 'AG_CONTRACT_HEADER';
    
      INSERT INTO ven_ag_contract_header
        (doc_templ_id
        ,ag_contract_header_id
        ,note
        ,num
        ,reg_date
        ,date_begin
        ,agent_id
        ,date_break
        ,last_ver_id
        ,agency_id
        ,t_sales_channel_id
        ,ag_contract_templ_k
        ,AG_CONTRACT_TEMPL_ID
        ,having_subagents
        ,rlp_agent_num)
      VALUES
        (v_Doc_Templ_ID
        ,v_obj_id_contr
        ,p_note
        ,p_num
        ,SYSDATE
        ,p_date_begin
        ,p_agent_id
        ,p_date_break
        ,NULL
        ,NULL
        , --p_agency_id,
         p_sales_channel_id
        ,0
        , -- ��� ���������� ������ 0
         p_AG_CONTRACT_TEMP_ID
        ,p_having_subagents
        ,p_rlp_num);
    
      --����������� ������ ������
      version_insert(v_obj_id_contr
                    ,p_date_begin
                    ,p_date_end
                    ,p_class_agent_id
                    ,p_category_id
                    ,p_note_ver
                    ,v_obj_id_vers
                    ,p_CONTRACT_LEADER_ID
                    ,p_RATE_AGENT
                    ,p_RATE_MAIN_AGENT
                    ,p_RATE_TYPE_ID
                    ,p_RATE_TYPE_MAIN_ID
                    ,p_fact_dop_rate
                    ,p_contract_f_lead_id
                    ,p_contract_recrut_id
                    ,p_method_payment
                    ,p_is_call_center
                    ,p_leg_pos
                    ,p_date_break
                    ,NULL
                    ,p_agency_id);
    
      --����������� ���������� ������
      -- ��� ������� ����!!!
      -- �� ����� �������� ��� ���������
    
      BEGIN
        -- ��������� ����_�����
        UPDATE ven_ag_contract_header
           SET last_ver_id = v_obj_id_vers
         WHERE ag_contract_header_id = v_obj_id_contr;
      EXCEPTION
        WHEN OTHERS THEN
          -- if sqlcode<-20000 then err:=sqlcode; else err:=sqlcode-20000;end if;
          RAISE_APPLICATION_ERROR(-20001
                                 ,'�� ����������� ����������� ������ ��������. ' || SQLERRM(SQLCODE));
      END;
      -- ����� ������� ����_����� � ���� ��������� �������
      BEGIN
      
        -- ��������� ���������������� ������� �� ������� �� ����
        Doc.set_doc_status(v_obj_id_contr, 'NEW', p_date_begin);
      EXCEPTION
        WHEN OTHERS THEN
          -- if sqlcode<-20000 then err:=sqlcode; else err:=sqlcode-20000;end if;
          RAISE_APPLICATION_ERROR(-20001
                                 ,'�� ����������� ����������� ������ ��������. ' || SQLERRM(SQLCODE));
      END;
      --set_last_ver(v_obj_id_contr, v_obj_id_vers);
      set_last_agency(v_obj_id_contr, p_agency_id);
      -- commit;
    
      p_contr_id := v_obj_id_contr;
      p_vers_id  := v_obj_id_vers;
    
    ELSE
      RAISE_APPLICATION_ERROR(-20008, '�� ��������� ������� ���������');
    END IF;
  END;

  PROCEDURE contract_update
  (
    p_ag_ch_id           NUMBER
   ,p_vers_id            NUMBER
   ,p_num                VARCHAR2
   ,p_date_begin         DATE
   ,p_date_end           DATE
   ,p_having_subagents   NUMBER DEFAULT 0
   ,p_agent_id           NUMBER
   ,p_rlp_num            NUMBER
   ,p_date_break         DATE DEFAULT NULL
   ,p_agency_id          NUMBER DEFAULT NULL
   ,p_note               VARCHAR2
   ,p_CONTRACT_LEADER_ID NUMBER DEFAULT NULL
   ,p_RATE_AGENT         NUMBER DEFAULT NULL
   ,p_RATE_MAIN_AGENT    NUMBER DEFAULT NULL
   ,p_RATE_TYPE_ID       NUMBER DEFAULT NULL
   ,p_RATE_TYPE_MAIN_ID  NUMBER DEFAULT NULL
   ,p_fact_dop_rate      NUMBER DEFAULT 0
   ,p_sales_channel_id   NUMBER
   ,p_contract_f_lead_id NUMBER DEFAULT NULL
   ,p_contract_recrut_id NUMBER DEFAULT NULL
   ,p_method_payment     NUMBER DEFAULT 0
   ,p_is_call_center     NUMBER DEFAULT 0
   ,p_leg_pos            NUMBER DEFAULT 0
   ,p_comm_holding       NUMBER DEFAULT 0
  ) IS
    --v_num_old varchar2(50);
    v_contract ven_ag_contract_header%ROWTYPE;
    v_version  ven_ag_contract%ROWTYPE;
    v_date_con DATE;
    v_date_ver DATE;
  BEGIN
    --���� ������ �������� �����, ����� �������� ���������
    --   if (get_status_contr(p_contr_id) = 'NEW') then
  
    BEGIN
      -- �������� �� ��������� �� ���������
      SELECT * INTO v_contract FROM ven_ag_contract_header WHERE ag_contract_header_id = p_ag_ch_id;
      -- �������� �� ������ �� ���������
      SELECT * INTO v_version FROM ven_ag_contract WHERE ag_contract_id = p_vers_id;
      -- ��������� �������� ��� �� �������� � ������
      v_date_con := v_contract.date_begin;
      v_date_ver := v_version.date_begin;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        v_date_con := p_date_begin;
        v_date_ver := p_date_begin;
      
    END;
    /*    -- �������� ����������� ��������� ��� �� ��������� � ������
    if     p_date_begin < v_contract.date_begin and v_contract.date_begin < sysdate
      then
    -- ���������� ��� (������������ �������) ����������
       null;
    els*/
    IF p_date_begin <> v_contract.date_begin
    THEN
      v_date_con := p_date_begin;
      v_date_ver := p_date_begin;
    END IF;
    BEGIN
      UPDATE ven_ag_contract_header ch
         SET ch.num                = p_num
            ,ch.note               = p_note
            ,ch.agent_id           = p_agent_id
            ,ch.date_begin         = v_date_con
            ,ch.last_ver_id        = p_vers_id
            ,ch.date_break         = p_date_break
            ,ch.t_sales_channel_id = p_sales_channel_id
            ,ch.having_subagents   = p_having_subagents
            ,ch.rlp_agent_num      = p_rlp_num
       WHERE ch.ag_contract_header_id = p_ag_ch_id;
    
      version_update(p_ag_ch_id
                    ,v_date_ver
                    ,p_date_end
                    ,NULL
                    ,NULL
                    ,NULL
                    ,p_vers_id
                    ,p_CONTRACT_LEADER_ID
                    ,p_RATE_AGENT
                    ,p_RATE_MAIN_AGENT
                    ,p_RATE_TYPE_ID
                    ,p_RATE_TYPE_MAIN_ID
                    ,p_fact_dop_rate
                    ,p_contract_f_lead_id
                    ,p_contract_recrut_id
                    ,p_method_payment
                    ,p_is_call_center
                    ,p_leg_pos
                    ,p_agency_id
                    ,p_comm_holding);
    
    END;
    -- if get_status_contr_activ_brief(p_ag_ch_id)='NEW' then
    -- ������ ��� ����������� ������ �������� ����������� ��������� �� ��������
    /* if doc.get_doc_status_brief(p_vers_id)=STATUS_CURRENT or
        get_status_contr_activ_brief(p_ag_ch_id)='NEW' then
        set_last_agency (p_ag_ch_id, v_agency_id);
      end if;
    */
    --  else raise_application_error(-20009,
    --                              '������� ���������� �������������');
    --   end if;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20010
                             ,'�� ����������� �������. ' || SQLERRM(SQLCODE));
  END; --proc

  --����������� ��������
  PROCEDURE contract_break(v_ch_id IN NUMBER) IS
    ver_id  NUMBER;
    v_st_id NUMBER;
    v_id    NUMBER;
  BEGIN
    SELECT h.last_ver_id
      INTO ver_id
      FROM ven_ag_contract_header h
     WHERE h.ag_contract_header_id = v_ch_id;
  
    v_st_id := Ent.get_obj_id('DOC_STATUS_REF', 'BREAK');
    /*    SELECT R.doc_status_ref_id
        INTO V_ST_ID
        FROM VEN_DOC_STATUS_REF R WHERE R.brief=('BREAK');
    */
    -- �������� �� ��� � �������� ������
  
    Pkg_Agent.contract_copy(ver_id, v_id, TRUE);
    Pkg_Agent.set_version_status(v_id, v_st_id);
  
  END;

  PROCEDURE template_insert
  (
    p_contr_id         OUT NUMBER
   ,p_vers_id          OUT NUMBER
   ,p_date_begin       DATE DEFAULT SYSDATE
   ,p_agency_id        NUMBER DEFAULT NULL
   ,p_note             VARCHAR2 DEFAULT NULL
   ,p_note_ver         VARCHAR2 DEFAULT NULL
   ,p_class_agent_id   NUMBER DEFAULT NULL
   ,p_category_id      NUMBER DEFAULT NULL
   ,p_SALES_CHANNEL_ID NUMBER
   ,p_method_payment   NUMBER DEFAULT 0
   ,p_is_call_center   NUMBER DEFAULT 0
   ,p_leg_pos          NUMBER DEFAULT 0
   ,p_kl_templ         NUMBER DEFAULT 1
   ,p_TEMPL_NAME       VARCHAR2 DEFAULT NULL
   ,p_TEMPL_BRIEF      VARCHAR2 DEFAULT NULL
  ) IS
    v_ag_contract_header_id NUMBER;
    v_obj_id_vers           NUMBER;
    v_status_id             NUMBER;
    v_Doc_Templ_ID          NUMBER;
    v_rez                   NUMBER := 0;
  BEGIN
  
    SELECT sq_ag_contract_header.NEXTVAL INTO v_ag_contract_header_id FROM dual;
  
    SELECT sq_ag_contract.NEXTVAL INTO v_obj_id_vers FROM dual;
  
    SELECT v.doc_status_ref_id INTO v_status_id FROM ven_doc_status_ref v WHERE v.brief = 'CURRENT';
  
    SELECT dt.doc_templ_id
      INTO v_Doc_Templ_ID
      FROM DOC_TEMPL dt
     WHERE dt.brief = 'AG_CONTRACT_HEADER_TEMP';
  
    INSERT INTO ven_ag_contract_header
      (doc_templ_id
      ,ag_contract_header_id
      ,note
      ,num
      ,reg_date
      ,date_begin
      ,last_ver_id
      ,agency_id
      ,t_sales_channel_id
      ,ag_contract_templ_k
      ,TEMPL_NAME
      ,TEMPL_BRIEF)
    VALUES
      (v_Doc_Templ_ID
      ,v_ag_contract_header_id
      ,p_NOTE
      ,'0'
      ,SYSDATE
      ,p_date_begin
      ,NULL
      , --v_obj_id_vers,
       NULL
      , --p_agency_id,
       p_sales_channel_id
      ,p_kl_templ
      , -- 1 - ������� �������� -- 2 - ������ ���. ����������
       p_TEMPL_NAME
      ,p_TEMPL_BRIEF);
  
    --����������� ������ ������
    version_insert(v_ag_contract_header_id
                  ,p_date_begin
                  ,TO_DATE('01.01.9999', 'dd.mm.yyyy')
                  ,p_class_agent_id
                  ,p_category_id
                  ,p_note_ver
                  ,v_obj_id_vers
                  ,NULL
                  , --p_CONTRACT_LEADER_ID,
                   NULL
                  , --p_RATE_AGENT,
                   NULL
                  , --p_RATE_MAIN_AGENT,
                   NULL
                  , --p_RATE_TYPE_ID,
                   NULL
                  , --p_RATE_TYPE_MAIN_ID,
                   NULL
                  , --p_fact_dop_rate
                   NULL
                  , --p_contract_f_lead_id
                   NULL
                  , --p_contract_recrut_id
                   p_method_payment
                  , -- p_method_payment
                   p_is_call_center
                  , -- p_is_call_center
                   p_leg_pos
                  ,NULL
                  ,NULL
                  ,p_agency_id);
  
    --����������� ���������� ������
    set_last_ver(v_ag_contract_header_id, v_obj_id_vers);
    set_last_agency(v_ag_contract_header_id, p_agency_id);
    -- commit;
  
    p_contr_id := v_ag_contract_header_id;
    p_vers_id  := v_obj_id_vers;
  
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20000 + SQLCODE, SQLERRM(SQLCODE));
  END; --proc template_insert

  PROCEDURE template_update
  (
    p_ag_ch_id         NUMBER
   ,p_vers_id          NUMBER
   ,p_date_begin       DATE DEFAULT SYSDATE
   ,p_agency_id        NUMBER DEFAULT NULL
   ,p_note             VARCHAR2 DEFAULT NULL
   ,p_note_ver         VARCHAR2 DEFAULT NULL
   ,p_class_agent_id   NUMBER DEFAULT NULL
   ,p_category_id      NUMBER DEFAULT NULL
   ,p_sales_channel_id NUMBER
   ,p_method_payment   NUMBER DEFAULT 0
   ,p_is_call_center   NUMBER DEFAULT 0
   ,p_leg_pos          NUMBER DEFAULT 0
   ,p_templ_name       VARCHAR2 DEFAULT NULL
   ,p_templ_brief      VARCHAR2 DEFAULT NULL
   ,p_comm_holding     NUMBER DEFAULT 0
  ) IS
    --v_num_old varchar2(50);
  
  BEGIN
    --���� ������ �������� �����, ����� �������� ���������
    --   if (get_status_contr(p_contr_id) = 'NEW') then
    BEGIN
    
      UPDATE ven_ag_contract_header ch
         SET ch.note               = p_NOTE
            ,ch.date_begin         = p_date_begin
            ,ch.last_ver_id        = p_vers_id
            ,ch.t_sales_channel_id = p_sales_channel_id
            ,
             --   ch.agency_id=p_agency_id,
             ch.templ_name  = p_templ_name
            ,ch.templ_brief = p_templ_brief
       WHERE ch.ag_contract_header_id = p_ag_ch_id;
    
      version_update(p_ag_ch_id
                    ,p_date_begin
                    ,NULL
                    , --p_date_end,
                     p_class_agent_id
                    ,p_category_id
                    ,p_note_ver
                    ,p_vers_id
                    ,NULL
                    , --p_CONTRACT_LEADER_ID,
                     NULL
                    , --p_RATE_AGENT,
                     NULL
                    , --p_RATE_MAIN_AGENT,
                     NULL
                    , --p_RATE_TYPE_ID,
                     NULL
                    , --p_RATE_TYPE_MAIN_ID,
                     NULL
                    , --p_fact_dop_rate
                     NULL
                    , --p_contract_f_lead_id
                     NULL
                    , --p_contract_recrut_id
                     p_method_payment
                    , -- p_method_payment
                     p_is_call_center
                    , -- p_is_call_center
                     p_leg_pos
                    ,p_agency_id
                    ,p_comm_holding);
    
      set_last_agency(p_ag_ch_id, p_agency_id);
    END;
  
  EXCEPTION
    WHEN OTHERS THEN
    
      RAISE_APPLICATION_ERROR(-20000 + SQLCODE, SQLERRM(SQLCODE));
    
  END; -- proc template_update

  FUNCTION template_to_contract_copy
  (
    p_ver_id_old IN NUMBER
   ,p_ver_id_new OUT NUMBER
  ) RETURN NUMBER IS
    db                          DATE;
    de                          DATE;
    v_e                         NUMBER;
    v_new_AG_PROD_LINE_CONTR_ID NUMBER;
  BEGIN
    --    if can_be_copied(p_ver_id_old) = 1 then
    --����������� ������
    BEGIN
      SELECT a.ag_contract_header_id
        INTO v_e
        FROM ven_ag_contract_header a
       WHERE a.ag_contract_header_id = p_ver_id_old;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RETURN 1;
    END;
  
    FOR v_r IN (SELECT * FROM ven_ag_contract t WHERE t.ag_contract_id = p_ver_id_old)
    LOOP
      v_r.ag_contract_id := p_ver_id_new;
      v_r.note           := '';
      IF v_r.date_begin < SYSDATE
      THEN
        v_r.date_begin := SYSDATE;
      END IF;
      v_r.reg_date := SYSDATE;
      --  v_r.num      := get_ver_num(v_r.contract_id);
      db := v_r.date_begin;
      de := v_r.date_end;
    
      version_insert(v_r.contract_id
                    , --�� ���������
                     v_r.date_begin
                    ,v_r.date_end
                    ,v_r.class_agent_id
                    ,v_r.category_id
                    ,v_r.note
                    ,p_ver_id_new
                    , --�� ��� ����������
                     v_r.contract_leader_id
                    ,v_r.rate_agent
                    ,v_r.rate_main_agent
                    ,v_r.rate_type_id
                    ,v_r.rate_type_main_id
                    ,v_r.contract_f_lead_id
                    ,v_r.contract_recrut_id
                    ,v_r.method_payment
                    ,v_r.is_call_center
                    ,v_r.leg_pos
                    ,NULL
                    ,NULL
                    ,v_r.agency_id
                     
                     );
    
    END LOOP;
    --  commit;
    --����������� ������ ��� ������
    FOR v_id IN (SELECT pl.ag_prod_line_contr_id
                   FROM ven_ag_prod_line_contr pl
                  WHERE pl.ag_contract_id = p_ver_id_old)
    LOOP
    
      FOR v_plc IN (SELECT p.insurance_group_id
                          ,p.product_id
                          ,p.product_line_id
                          ,r.type_defin_rate_id
                          ,r.type_rate_value_id
                          ,
                           --  r.t_rule_id,
                           r.VALUE
                          ,p.date_begin
                          ,p.date_end
                          ,r.t_prod_coef_type_id
                          ,p.notes
                      FROM ven_ag_prod_line_contr p
                          ,ven_ag_rate            r
                     WHERE p.ag_rate_id = r.ag_rate_id
                       AND p.ag_prod_line_contr_id = v_id.ag_prod_line_contr_id)
      LOOP
        prod_line_contr_insert( --v_new_AG_PROD_LINE_CONTR_ID,
                               p_ver_id_new
                              ,v_plc.insurance_group_id
                              ,v_plc.product_id
                              ,v_plc.product_line_id
                              ,v_plc.type_defin_rate_id
                              ,v_plc.type_rate_value_id
                              ,
                               --  v_plc.t_rule_id,
                               v_plc.VALUE
                              ,v_plc.date_begin
                              ,de
                              ,v_plc.t_prod_coef_type_id
                              ,v_plc.notes);
      END LOOP;
    END LOOP;
  
    --����������� ����� ���. ��������������
    FOR v_plan IN (SELECT r.order_num
                         ,r.prem_b
                         ,r.prem_e
                         ,r.RATE
                         ,r.ag_type_rate_value_id
                     FROM ven_ag_plan_dop_rate r
                    WHERE r.ag_contract_id = p_ver_id_old)
    LOOP
      INSERT INTO ven_ag_plan_dop_rate
        (order_num, ag_contract_id, prem_b, prem_e, RATE, ag_type_rate_value_id)
      VALUES
        (v_plan.order_num
        ,p_ver_id_new
        ,v_plan.prem_b
        ,v_plan.prem_e
        ,v_plan.RATE
        ,v_plan.ag_type_rate_value_id);
    
    END LOOP;
    --����������� ��������
    FOR v_com_from IN (SELECT com.parent_id
                             ,com.child_id
                             ,com.t_product_id
                         FROM ven_ag_commiss com
                        WHERE com.parent_id = p_ver_id_old)
    LOOP
      INSERT INTO ven_ag_commiss
        (parent_id, child_id, t_product_id)
      VALUES
        (p_ver_id_new, v_com_from.child_id, v_com_from.t_product_id);
    END LOOP;
  
    FOR v_com_to IN (SELECT com.parent_id
                           ,com.child_id
                           ,com.t_product_id
                       FROM ven_ag_commiss com
                      WHERE com.child_id = p_ver_id_old)
    LOOP
      INSERT INTO ven_ag_commiss
        (parent_id, child_id, t_product_id)
      VALUES
        (v_com_to.parent_id, p_ver_id_new, v_com_to.t_product_id);
    END LOOP;
  
    -- commit;
    -- else raise_application_error(-20011,
    --            '���������� ������� ����� ������ �� �������');
    --    end if;
  
  END;

  PROCEDURE contract_del(v_contract_id NUMBER) IS
  BEGIN
    --������� ������
    FOR v_r IN (SELECT c.ag_contract_id FROM ven_ag_contract c WHERE c.contract_id = v_contract_id)
    LOOP
      version_del(v_r.ag_contract_id);
    END LOOP;
    --������� �������
    DELETE FROM ven_ag_contract_header WHERE ag_contract_header_id = v_contract_id;
    --������� ������
    DELETE FROM ven_doc_status WHERE document_id = v_contract_id;
    --  commit;
  END;

  --���������� ������ � ����� ������
  PROCEDURE contract_copy
  (
    p_ver_id_old  IN NUMBER
   ,p_ver_id_new  OUT NUMBER
   ,p_date_begin  DATE DEFAULT SYSDATE
   ,p_anyway_copy IN BOOLEAN DEFAULT FALSE
   ,p_date_break  DATE DEFAULT SYSDATE
  ) IS
    db                          DATE;
    de                          DATE;
    v_new_AG_PROD_LINE_CONTR_ID NUMBER;
  BEGIN
    IF p_anyway_copy
       OR can_be_copied(p_ver_id_old) = 1
    THEN
      --����������� ������
      FOR v_r IN (SELECT * FROM ven_ag_contract t WHERE t.ag_contract_id = p_ver_id_old)
      LOOP
        v_r.ag_contract_id := p_ver_id_new;
        v_r.note           := '';
        IF v_r.date_begin < p_date_begin --sysdate
        THEN
          v_r.date_begin := p_date_begin; --sysdate;
        END IF;
      
        v_r.reg_date := SYSDATE;
        --  v_r.num      := get_ver_num(v_r.contract_id);
        db := v_r.date_begin;
        de := v_r.date_end;
      
        version_insert(v_r.contract_id
                      , --�� ���������
                       v_r.date_begin
                      ,v_r.date_end
                      ,v_r.class_agent_id
                      ,v_r.category_id
                      ,v_r.note
                      ,p_ver_id_new
                      , --�� ��� ����������
                       v_r.contract_leader_id
                      ,v_r.rate_agent
                      ,v_r.rate_main_agent
                      ,v_r.rate_type_id
                      ,v_r.rate_type_main_id
                      ,0
                      ,v_r.contract_f_lead_id
                      ,v_r.contract_recrut_id
                      ,v_r.method_payment
                      ,v_r.is_call_center
                      ,v_r.leg_pos
                      ,p_date_break
                      ,NULL
                      ,v_r.agency_id);
      
      END LOOP;
    
      --����������� ������ ��� ������
      FOR v_id IN (SELECT pl.ag_prod_line_contr_id
                     FROM ven_ag_prod_line_contr pl
                    WHERE pl.ag_contract_id = p_ver_id_old)
      LOOP
      
        FOR v_plc IN (SELECT p.insurance_group_id
                            ,p.product_id
                            ,p.product_line_id
                            ,r.type_defin_rate_id
                            ,r.type_rate_value_id
                            ,
                             --        r.t_rule_id,
                             r.VALUE
                            ,p.date_begin
                            ,p.date_end
                            ,r.t_prod_coef_type_id
                            ,p.notes
                        FROM ven_ag_prod_line_contr p
                            ,ven_ag_rate            r
                       WHERE p.ag_rate_id = r.ag_rate_id
                         AND p.ag_prod_line_contr_id = v_id.ag_prod_line_contr_id)
        LOOP
          prod_line_contr_insert( --v_new_AG_PROD_LINE_CONTR_ID,
                                 p_ver_id_new
                                ,v_plc.insurance_group_id
                                ,v_plc.product_id
                                ,v_plc.product_line_id
                                ,v_plc.type_defin_rate_id
                                ,v_plc.type_rate_value_id
                                ,
                                 -- v_plc.t_rule_id,
                                 v_plc.VALUE
                                ,v_plc.date_begin
                                ,de
                                ,v_plc.t_prod_coef_type_id
                                ,v_plc.notes);
        END LOOP;
      END LOOP;
    
      --����������� ����� ���. ��������������
      /* ��������!!!
      for v_plan in (select r.order_num,
                             r.prem_b,
                             r.prem_e,
                             r.rate,
                             r.ag_type_rate_value_id
                      from ven_ag_plan_dop_rate r where r.ag_contract_id=p_ver_id_old)
       LOOP
           insert into ven_ag_plan_dop_rate(order_num,ag_contract_id,prem_b,prem_e,rate,ag_type_rate_value_id)
           values(v_plan.order_num,p_ver_id_new,v_plan.prem_b, v_plan.prem_e, v_plan.rate, v_plan.ag_type_rate_value_id);
      
       end loop;  */
      --����������� ��������
      FOR v_com_from IN (SELECT com.parent_id
                               ,com.child_id
                               ,com.t_product_id
                           FROM ven_ag_commiss com
                          WHERE com.parent_id = p_ver_id_old)
      LOOP
        INSERT INTO ven_ag_commiss
          (parent_id, child_id, t_product_id)
        VALUES
          (p_ver_id_new, v_com_from.child_id, v_com_from.t_product_id);
      END LOOP;
    
      FOR v_com_to IN (SELECT com.parent_id
                             ,com.child_id
                             ,com.t_product_id
                         FROM ven_ag_commiss com
                        WHERE com.child_id = p_ver_id_old)
      LOOP
        INSERT INTO ven_ag_commiss
          (parent_id, child_id, t_product_id)
        VALUES
          (v_com_to.parent_id, p_ver_id_new, v_com_to.t_product_id);
      END LOOP;
    
      -- ����������� ���
      FOR v_dav IN (SELECT dav1.note
                          ,dav1.payment_ag_id
                          ,dav1.payment_terms_id
                          ,dav1.prod_coef_type_id
                      FROM ven_ag_dav dav1
                     WHERE dav1.contract_id = p_ver_id_old)
      LOOP
        INSERT INTO ven_ag_dav
          (contract_id, note, payment_ag_id, payment_terms_id, prod_coef_type_id)
        VALUES
          (p_ver_id_new
          ,v_dav.note
          ,v_dav.payment_ag_id
          ,v_dav.payment_terms_id
          ,v_dav.prod_coef_type_id);
      
      END LOOP;
    
      -- commit;
      -- else raise_application_error(-20011,
      --            '���������� ������� ����� ������ �� �������');
    END IF;
  
  END;

  -------------------------------------------------------------------
  -- ��������� ������ �� TMPL ������ � ����� ������
  PROCEDURE contract_from_tmpl
  (
    p_prizn_all     IN NUMBER -- ��������� ������� ������(1) ��� ��� (0)
   ,p_ver_id_old    IN NUMBER
   ,p_ver_id_new    OUT NUMBER
   ,p_templ_id      IN NUMBER
   ,p_date_ver      IN DATE DEFAULT SYSDATE
   ,p_anyway_create IN OUT BOOLEAN
   ,p_date_break    DATE DEFAULT SYSDATE
  ) IS
    CURSOR k_sale IS
      SELECT vs.ag_plan_sale_id
            ,vs.k_sgp
            ,vs.ag_count
            ,vs.period_type_id
        FROM ven_ag_plan_sale vs
       WHERE vs.ag_contract_header_id = p_templ_id
       ORDER BY vs.ag_plan_sale_id;
  
    v_sale                      k_sale%ROWTYPE;
    v_plan_sale                 ven_ag_plan_sale%ROWTYPE;
    v_brief_sale                VARCHAR2(100);
    v_period_sale               NUMBER;
    v_templ_c                   ven_ag_contract%ROWTYPE;
    v_templ_h                   ven_ag_contract_header%ROWTYPE;
    v_ag_contract_id            NUMBER;
    v_contact_id                NUMBER;
    v_count                     NUMBER;
    db                          DATE;
    de                          DATE;
    v_new_AG_PROD_LINE_CONTR_ID NUMBER;
    v_status_id                 NUMBER;
  BEGIN
  
    BEGIN
      SELECT ah.ag_contract_header_id
            ,ca.agency_id
            ,ah.t_sales_channel_id
            ,ah.note
            ,ca.ag_contract_id
            ,ca.note
            ,ca.category_id
            ,ca.method_payment
            ,ca.is_call_center
            ,ca.leg_pos
        INTO v_templ_h.ag_contract_header_id
            ,v_templ_c.agency_id
            ,v_templ_h.t_sales_channel_id
            ,v_templ_h.note
            ,v_templ_c.ag_contract_id
            ,v_templ_c.note
            ,v_templ_c.category_id
            ,v_templ_c.method_payment
            ,v_templ_c.is_call_center
            ,v_templ_c.leg_pos
        FROM ven_ag_contract_header ah
        JOIN ven_ag_contract ca
          ON (ca.contract_id = ah.ag_contract_header_id AND ca.ag_contract_id = ah.last_ver_id)
       WHERE ah.ag_contract_templ_k = 2
         AND ah.ag_contract_header_id = p_templ_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        p_anyway_create := FALSE;
    END;
  
    IF p_anyway_create
       OR can_be_copied(p_ver_id_old) = 1
    THEN
      -- ���������� ������ ���������� ������, ���� � ������� ����������� ������
      FOR v_r IN (SELECT * FROM ven_ag_contract t WHERE t.ag_contract_id = p_ver_id_old)
      LOOP
      
        /* -- ����� ������������� �������� ��������� ������
                select cat.ag_category_agent_id from ven_ag_category_agent cat
                where cat.sort_id in
                    select max(sort_id) from
                   ( select v.sort_id from ven_ag_category_agent v where v.ag_category_agent_id=v_r.category_id
                     union all
                     select t.sort_id from ven_ag_category_agent t where t.ag_category_agent_id=v_templ_c.category_id
                    )
                ;
        */
        v_r.ag_contract_id := p_ver_id_new;
        IF v_r.date_begin < p_date_ver --sysdate
        THEN
          v_r.date_begin := p_date_ver; --sysdate;
        END IF;
      
        v_r.reg_date := SYSDATE;
        --  v_r.num      := get_ver_num(v_r.contract_id);
        db            := v_r.date_begin;
        de            := v_r.date_end;
        v_r.note      := v_templ_c.note;
        v_r.agency_id := NVL(v_templ_c.agency_id, v_r.agency_id);
        -- �������� �� ������� ������������� ������ � ��� ������ , ���� ���������� �� "�� ���������"
        IF NVL(v_templ_c.leg_pos, v_r.leg_pos) > v_r.leg_pos
        THEN
          v_r.leg_pos := v_templ_c.leg_pos;
        END IF;
        IF NVL(v_templ_c.method_payment, v_r.method_payment) > v_r.method_payment
        THEN
          v_r.method_payment := v_templ_c.method_payment;
        END IF;
        IF NVL(v_templ_c.is_call_center, v_r.is_call_center) > v_r.is_call_center
        THEN
          v_r.is_call_center := v_templ_c.is_call_center;
        END IF;
      
        --        v_r.category_id    := nvl(v_templ_c.category_id,v_r.category_id);
      
        IF (p_prizn_all = 1 AND v_templ_c.category_id IS NOT NULL)
        THEN
          v_r.category_id := v_templ_c.category_id;
        ELSE
          v_r.category_id := v_r.category_id;
        END IF;
      
        -- ������ ��������������� ����� �������
        version_insert(v_r.contract_id
                      , --�� ���������
                       v_r.date_begin
                      ,v_r.date_end
                      ,v_r.class_agent_id
                      ,v_r.category_id
                      ,v_r.note
                      ,p_ver_id_new
                      , --�� ��� ����������
                       v_r.contract_leader_id
                      ,v_r.rate_agent
                      ,v_r.rate_main_agent
                      ,v_r.rate_type_id
                      ,v_r.rate_type_main_id
                      ,0
                      ,v_r.contract_f_lead_id
                      ,v_r.contract_recrut_id
                      ,v_r.method_payment
                      ,v_r.is_call_center
                      ,v_r.leg_pos
                      ,p_date_break
                      ,p_templ_id
                      ,v_r.agency_id);
        v_contact_id := v_r.contract_id;
      END LOOP;
    
      -- ����������� ������ ��� ������
      -- ����������� ������ �������
      SELECT COUNT(*)
        INTO v_count
        FROM ven_ag_prod_line_contr
       WHERE ag_contract_id = v_templ_c.ag_contract_id;
    
      IF v_count > 0
      THEN
        v_ag_contract_id := v_templ_c.ag_contract_id;
      ELSE
        v_ag_contract_id := p_ver_id_old;
      END IF;
    
      FOR v_id IN (SELECT pl.ag_prod_line_contr_id
                     FROM ven_ag_prod_line_contr pl
                    WHERE pl.ag_contract_id = v_ag_contract_id)
      LOOP
      
        FOR v_plc IN (SELECT p.insurance_group_id
                            ,p.product_id
                            ,p.product_line_id
                            ,r.type_defin_rate_id
                            ,r.type_rate_value_id
                            ,
                             --       r.t_rule_id,
                             r.VALUE
                            ,p.date_begin
                            ,p.date_end
                            ,r.t_prod_coef_type_id
                            ,p.notes
                        FROM ven_ag_prod_line_contr p
                            ,ven_ag_rate            r
                       WHERE p.ag_rate_id = r.ag_rate_id
                         AND p.ag_prod_line_contr_id = v_id.ag_prod_line_contr_id)
        LOOP
          prod_line_contr_insert( --v_new_AG_PROD_LINE_CONTR_ID,
                                 p_ver_id_new
                                ,v_plc.insurance_group_id
                                ,v_plc.product_id
                                ,v_plc.product_line_id
                                ,v_plc.type_defin_rate_id
                                ,v_plc.type_rate_value_id
                                ,
                                 --  v_plc.t_rule_id,
                                 v_plc.VALUE
                                ,v_plc.date_begin
                                ,de
                                ,v_plc.t_prod_coef_type_id
                                ,v_plc.notes);
        END LOOP;
      END LOOP;
      --����������� ��������
      FOR v_com_from IN (SELECT com.parent_id
                               ,com.child_id
                               ,com.t_product_id
                           FROM ven_ag_commiss com
                          WHERE com.parent_id = p_ver_id_old)
      LOOP
        INSERT INTO ven_ag_commiss
          (parent_id, child_id, t_product_id)
        VALUES
          (p_ver_id_new, v_com_from.child_id, v_com_from.t_product_id);
      END LOOP;
    
      FOR v_com_to IN (SELECT com.parent_id
                             ,com.child_id
                             ,com.t_product_id
                         FROM ven_ag_commiss com
                        WHERE com.child_id = p_ver_id_old)
      LOOP
        INSERT INTO ven_ag_commiss
          (parent_id, child_id, t_product_id)
        VALUES
          (v_com_to.parent_id, p_ver_id_new, v_com_to.t_product_id);
      END LOOP;
    
      -- ����������� ���
      -- ����������� ��� �������
      SELECT COUNT(*) INTO v_count FROM ven_ag_dav WHERE contract_id = v_templ_c.ag_contract_id;
    
      IF v_count > 0
      THEN
        v_ag_contract_id := v_templ_c.ag_contract_id;
      ELSE
        v_ag_contract_id := p_ver_id_old;
      END IF;
    
      FOR v_dav IN (SELECT dav1.note
                          ,dav1.payment_ag_id
                          ,dav1.payment_terms_id
                          ,dav1.prod_coef_type_id
                      FROM ven_ag_dav dav1
                     WHERE dav1.contract_id = v_ag_contract_id)
      LOOP
        INSERT INTO ven_ag_dav
          (contract_id, note, payment_ag_id, payment_terms_id, prod_coef_type_id)
        VALUES
          (p_ver_id_new
          ,v_dav.note
          ,v_dav.payment_ag_id
          ,v_dav.payment_terms_id
          ,v_dav.prod_coef_type_id);
      
      END LOOP;
      ------------------------------------------
      ------ ��������/�������� ���� �� �������� ---------
      /*  update ven_ag_contract_header ah
         set ah.agency_id=nvl(v_templ_h.agency_id,ah.agency_id),
             ah.t_sales_channel_id=nvl(v_templ_h.t_sales_channel_id,ah.t_sales_channel_id),
             ah.note=nvl(v_templ_h.note,ah.note)
      where ah.ag_contract_header_id  = v_contact_id;
      insert into ven_ag_plan_sale
      (AG_PLAN_SALE_ID,  DATE_START,  DATE_END,  K_SGP,  AG_COUNT,  PERIOD_TYPE_ID,  AG_CONTRACT_HEADER_ID)
      ( select sq_ag_plan_sale.nextval,
               vs.date_start,
               vs.date_end,
               vs.k_sgp,
               vs.ag_count,
               vs.period_type_id,
               v_contact_id
       from ven_ag_plan_sale vs
       where vs.ag_contract_header_id=p_templ_id ) ; */
    
      ------ ���� ������ �� �������
      OPEN k_sale;
      LOOP
        FETCH k_sale
          INTO v_sale;
        EXIT WHEN k_sale%NOTFOUND;
      
        IF v_brief_sale IS NULL
        THEN
          BEGIN
            SELECT t.brief
              INTO v_brief_sale
              FROM ven_T_PERIOD_TYPE t
             WHERE t.ID = v_sale.period_type_id;
          EXCEPTION
            WHEN OTHERS THEN
              NULL;
          END;
          CASE v_brief_sale
            WHEN 'Y' THEN
              v_period_sale := 1;
            WHEN 'Q' THEN
              v_period_sale := 4;
            WHEN 'M' THEN
              v_period_sale := 12;
            ELSE
              NULL;
          END CASE;
          v_plan_sale.period_type_id        := v_sale.period_type_id;
          v_plan_sale.date_start            := db;
          v_plan_sale.AG_CONTRACT_HEADER_ID := v_contact_id;
        END IF;
        SELECT sq_ag_plan_sale.NEXTVAL INTO v_plan_sale.AG_PLAN_SALE_ID FROM dual;
        v_plan_sale.DATE_END := ADD_MONTHS(v_plan_sale.DATE_START, 12 / v_period_sale);
        BEGIN
          INSERT INTO ven_AG_PLAN_SALE
            (AG_PLAN_SALE_ID
            ,DATE_START
            ,DATE_END
            ,K_SGP
            ,AG_COUNT
            ,PERIOD_TYPE_ID
            ,AG_CONTRACT_HEADER_ID)
          VALUES
            (v_plan_sale.AG_PLAN_SALE_ID
            ,v_plan_sale.DATE_START
            ,v_plan_sale.DATE_END - 1
            ,v_sale.k_sgp
            ,v_sale.ag_count
            ,v_plan_sale.PERIOD_TYPE_ID
            ,v_plan_sale.AG_CONTRACT_HEADER_ID);
        EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END;
        v_plan_sale.DATE_START := v_plan_sale.DATE_END;
      
      END LOOP;
      CLOSE k_sale;
    
      -- commit;
      -- else raise_application_error(-20011,
      --            '���������� ������� ����� ������ �� �������');
    END IF;
  
  END;
  ----------------------------------------------------------------
  PROCEDURE prod_line_contr_insert( --p_AG_PROD_LINE_CONTR_ID out number,
                                   p_ver_cont_id        NUMBER
                                  ,p_insurance_group_id NUMBER
                                  ,p_product_id         NUMBER
                                  ,p_product_line_id    NUMBER
                                  ,p_defin_rate_id      NUMBER
                                  ,p_type_value_rate    NUMBER
                                  ,
                                   --   p_rule_id            number,
                                   p_rate              NUMBER
                                  ,p_db                DATE
                                  ,p_de                DATE
                                  ,p_PROD_COEF_TYPE_ID NUMBER
                                  ,p_notes             VARCHAR2) IS
    v_prod_line_cont_id NUMBER;
    v_rate_id           NUMBER;
    de                  DATE;
  BEGIN
    --if p_db < p_de then
    BEGIN
      SELECT sq_ag_prod_line_contr.NEXTVAL INTO v_prod_line_cont_id FROM dual;
      SELECT sq_ag_rate.NEXTVAL INTO v_rate_id FROM dual;
      --��������� ������
      INSERT INTO ven_ag_rate
        (ag_rate_id
        ,
         --  t_rule_id,
         type_rate_value_id
        ,VALUE
        ,type_defin_rate_id
        ,T_PROD_COEF_TYPE_ID)
      VALUES
        (v_rate_id
        ,
         --  p_rule_id,
         p_type_value_rate
        ,p_rate
        ,p_defin_rate_id
        ,p_PROD_COEF_TYPE_ID);
    
      --   commit;
    
      SELECT c.date_end INTO de FROM ven_ag_contract c WHERE c.ag_contract_id = p_ver_cont_id;
    
      IF de > p_de
      THEN
        de := p_de;
      END IF;
    
      --��� ����
      INSERT INTO ven_ag_prod_line_contr
        (ag_prod_line_contr_id
        ,ag_contract_id
        ,ag_rate_id
        ,product_line_id
        ,product_id
        ,insurance_group_id
        ,date_begin
        ,date_end
        ,notes)
      VALUES
        (v_prod_line_cont_id
        ,p_ver_cont_id
        ,v_rate_id
        ,p_product_line_id
        ,p_product_id
        ,p_insurance_group_id
        ,p_db
        ,de
        ,p_notes);
    
      --  commit;
    END;
    /*      else
      raise_application_error(-20001,
                              '���� ������ '||p_db||' ������ ���� ����� ���� ��������� '||p_de);
    end if;*/
  END;

  PROCEDURE prod_line_contr_update
  (
    p_prod_line_contr_id NUMBER
   ,p_insurance_group_id NUMBER
   ,p_product_id         NUMBER
   ,p_product_line_id    NUMBER
   ,p_defin_rate_id      NUMBER
   ,p_type_value_rate    NUMBER
   ,
    --   p_rule_id            number,
    p_ag_rate_id        NUMBER
   ,p_rate              NUMBER
   ,p_db                DATE
   ,p_de                DATE
   ,p_PROD_COEF_TYPE_ID NUMBER
   ,p_notes             VARCHAR2
  ) IS
    v_insurance_group_id NUMBER;
    v_product_id         NUMBER;
    v_product_line_id    NUMBER;
    v_db                 DATE;
    v_de                 DATE;
  BEGIN
    SELECT pl.insurance_group_id
          ,pl.product_id
          ,pl.product_line_id
          ,pl.date_begin
          ,pl.date_end
      INTO v_insurance_group_id
          ,v_product_id
          ,v_product_line_id
          ,v_db
          ,v_de
      FROM ven_ag_prod_line_contr pl
     WHERE pl.ag_prod_line_contr_id = p_prod_line_contr_id;
  
    v_insurance_group_id := p_insurance_group_id;
    v_product_id         := p_product_id;
    v_product_line_id    := p_product_line_id;
    v_db                 := p_db;
    v_de                 := p_de;
    /*    v_insurance_group_id := nvl(p_insurance_group_id, v_insurance_group_id);
      v_product_id         := nvl(p_product_id, v_product_id);
      v_product_line_id    := nvl(p_product_line_id, v_product_line_id);
      v_db                 := nvl(p_db, v_db);
      v_de                 := nvl(p_de, v_de);
    */
    --  if (p_rule_id is not null and p_type_value_rate is not null and
    --     p_rate is not null and p_defin_rate_id is not null) then
    --�������� ������
    UPDATE ven_ag_rate
       SET /*t_rule_id          = p_rule_id,*/  type_rate_value_id = p_type_value_rate
          ,VALUE               = p_rate
          ,type_defin_rate_id  = p_defin_rate_id
          ,T_PROD_COEF_TYPE_ID = p_PROD_COEF_TYPE_ID
     WHERE ag_rate_id = p_ag_rate_id;
    --  end if;
    --�������� ��� �����
    UPDATE ven_ag_prod_line_contr
       SET ag_rate_id         = p_ag_rate_id
          ,product_line_id    = v_product_line_id
          ,product_id         = v_product_id
          ,insurance_group_id = v_insurance_group_id
          ,date_begin         = v_db
          ,date_end           = v_de
          ,notes              = p_notes
     WHERE ag_prod_line_contr_id = p_prod_line_contr_id;
  
    --  commit;
  END;

  PROCEDURE prod_line_contr_del
  (
    p_ver_id       NUMBER
   ,p_prod_line_id NUMBER
  ) --���� null, ����� ������� ��� ����� �� ���� ������
   IS
  BEGIN
    IF p_prod_line_id IS NULL
    THEN
      DELETE FROM ven_ag_prod_line_contr WHERE ag_contract_id = p_ver_id;
      --???��� ���������� ������� ���� �� ����� ������.
    ELSE
      DELETE FROM ven_ag_prod_line_contr
       WHERE ag_contract_id = p_ver_id
         AND ag_prod_line_contr_id = p_prod_line_id;
    END IF;
    --  commit;
  END;

  PROCEDURE prod_line_update_date
  (
    p_ver_id NUMBER
   ,p_db     DATE DEFAULT NULL
   ,p_de     DATE DEFAULT NULL
  ) IS
  BEGIN
    IF p_db IS NOT NULL
    THEN
      UPDATE ven_ag_prod_line_contr c SET c.date_begin = p_db WHERE c.ag_contract_id = p_ver_id;
    END IF;
  
    IF p_de IS NOT NULL
    THEN
      UPDATE ven_ag_prod_line_contr c SET c.date_end = p_de WHERE c.ag_contract_id = p_ver_id;
    END IF;
  
  END;

  FUNCTION get_agent_rate_by_cover
  (
    p_p_cover_id NUMBER
   ,p_agent_id   NUMBER
   ,p_date       DATE
  ) RETURN NUMBER IS
    v_ret_val            NUMBER;
    v_product_line_id    NUMBER;
    v_product_id         NUMBER;
    v_insurance_group_id NUMBER;
  BEGIN
    v_ret_val            := NULL;
    v_product_id         := NULL;
    v_product_line_id    := NULL;
    v_insurance_group_id := NULL;
  
    BEGIN
      SELECT pv.product_id
            ,pl.insurance_group_id
            ,plo.product_line_id
        INTO v_product_id
            ,v_insurance_group_id
            ,v_product_line_id
        FROM P_COVER c
        JOIN T_PROD_LINE_OPTION plo
          ON c.t_prod_line_option_id = plo.ID
        JOIN T_PRODUCT_LINE pl
          ON pl.ID = plo.product_line_id
        JOIN T_PRODUCT_VER_LOB pvl
          ON pvl.t_product_ver_lob_id = pl.product_ver_lob_id
        JOIN T_PRODUCT_VERSION pv
          ON pv.t_product_version_id = pvl.product_version_id
       WHERE c.p_cover_id = p_p_cover_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
    END;
  
    BEGIN
      SELECT *
        INTO v_ret_val
        FROM (SELECT aplc.ag_prod_line_contr_id
                FROM AG_CONTRACT_HEADER ach
                JOIN AG_CONTRACT ac
                  ON ac.ag_contract_id = ach.last_ver_id
                 AND p_date BETWEEN ac.date_begin AND ac.date_end
                JOIN AG_PROD_LINE_CONTR aplc
                  ON aplc.ag_contract_id = ac.ag_contract_id
              --join ag_rate ar on ar.ag_rate_id = aplc.ag_rate_id
                JOIN DOC_STATUS ds
                  ON ds.document_id = ac.ag_contract_id
                JOIN DOC_STATUS_REF dsr
                  ON dsr.doc_status_ref_id = ds.doc_status_ref_id
               WHERE dsr.NAME = '�����������'
                 AND ach.agent_id = p_agent_id
                 AND aplc.product_line_id = v_product_line_id)
       WHERE ROWNUM = 1;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        BEGIN
          SELECT *
            INTO v_ret_val
            FROM (SELECT aplc.ag_prod_line_contr_id
                    FROM AG_CONTRACT_HEADER ach
                    JOIN AG_CONTRACT ac
                      ON ac.ag_contract_id = ach.last_ver_id
                     AND p_date BETWEEN ac.date_begin AND ac.date_end
                    JOIN AG_PROD_LINE_CONTR aplc
                      ON aplc.ag_contract_id = ac.ag_contract_id
                  --join ag_rate ar on ar.ag_rate_id = aplc.ag_rate_id
                    JOIN DOC_STATUS ds
                      ON ds.document_id = ac.ag_contract_id
                    JOIN DOC_STATUS_REF dsr
                      ON dsr.doc_status_ref_id = ds.doc_status_ref_id
                   WHERE dsr.NAME = '�����������'
                     AND ach.agent_id = p_agent_id
                     AND aplc.product_id = v_product_id)
           WHERE ROWNUM = 1;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            BEGIN
              SELECT *
                INTO v_ret_val
                FROM (SELECT aplc.ag_prod_line_contr_id
                        FROM AG_CONTRACT_HEADER ach
                        JOIN AG_CONTRACT ac
                          ON ac.ag_contract_id = ach.last_ver_id
                         AND p_date BETWEEN ac.date_begin AND ac.date_end
                        JOIN AG_PROD_LINE_CONTR aplc
                          ON aplc.ag_contract_id = ac.ag_contract_id
                      --join ag_rate ar on ar.ag_rate_id = aplc.ag_rate_id
                        JOIN DOC_STATUS ds
                          ON ds.document_id = ac.ag_contract_id
                        JOIN DOC_STATUS_REF dsr
                          ON dsr.doc_status_ref_id = ds.doc_status_ref_id
                       WHERE dsr.NAME = '�����������'
                         AND ach.agent_id = p_agent_id
                         AND aplc.insurance_group_id = v_insurance_group_id)
               WHERE ROWNUM = 1;
            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                NULL;
            END;
        END;
    END;
    RETURN v_ret_val;
  END;

  PROCEDURE set_header_status(p_doc_id IN NUMBER) IS
    v_New_Status_ID NUMBER;
    v_Contract_ID   NUMBER;
  BEGIN
    SELECT dsr.doc_status_ref_id INTO v_New_Status_ID FROM DOC_STATUS_REF dsr WHERE dsr.brief = 'NEW';
    --    v_New_Status_ID:=ent.g
    BEGIN
      SELECT ach.last_ver_id
        INTO v_Contract_ID
        FROM AG_CONTRACT_HEADER ach
       WHERE ach.ag_contract_header_id = p_doc_id;
      Doc.set_doc_status(p_doc_id, Doc.get_doc_status_id(v_Contract_ID));
    EXCEPTION
      WHEN OTHERS THEN
        Doc.set_doc_status(p_doc_id, v_New_Status_ID);
    END;
  END;

  PROCEDURE get_rate
  (
    p_categ_from_id IN NUMBER
   ,p_categ_to_id   IN NUMBER
   ,p_product_id    IN NUMBER
   ,p_sq_year_id    IN NUMBER DEFAULT 1
   ,p_date          IN DATE DEFAULT SYSDATE
   ,p_def_id        OUT NUMBER
   ,p_type_id       OUT NUMBER
   ,p_com           OUT NUMBER
  ) IS
    v_brief_def    VARCHAR2(200);
    v_brief_tariff VARCHAR2(200);
    v_com          NUMBER;
    v_ct           NUMBER;
  
  BEGIN
    SELECT a.commis
          ,a.ag_type_defin_rate_id
          ,a.ag_type_rate_value_id
          ,a.t_prod_coef_type_id
      INTO v_com
          ,p_def_id
          ,p_type_id
          ,v_ct
      FROM ven_t_agent_commis a
     WHERE a.ag_category_from_id = p_categ_from_id
       AND (a.ag_category_to_id = NVL(p_categ_to_id, 0) OR
           (a.ag_category_to_id IS NULL AND NVL(p_categ_to_id, 0) = 0))
       AND a.date_in <= p_date
       AND ROWNUM = 1
     ORDER BY a.date_in;
  
    SELECT r.brief
      INTO v_brief_def
      FROM ven_ag_type_defin_rate r
     WHERE r.ag_type_defin_rate_id = p_def_id;
  
    IF v_brief_def = 'CONSTANT'
    THEN
      p_com := v_com;
    ELSIF v_brief_def = 'FUNCTION'
    THEN
      SELECT ty.brief
        INTO v_brief_tariff
        FROM T_PROD_COEF_TYPE ty
       WHERE ty.t_prod_coef_type_id = v_ct;
      --��� �������� = 1
    
      --  p_com := Pkg_Tariff_Calc.calc_coeff_val(v_brief_tariff,
      --                                        2,
      --                                      p_product_id,
      --                                    NVL(p_sq_year_id, 1));
    ELSE
      p_com := NULL;
    END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      p_def_id  := NULL;
      p_type_id := NULL;
      p_com     := NULL;
  END;

  /*
    function get_commiss_by_ctg_rel(p_product_id number,
                                    p_year_contract number,
                                    p_ctg_source_id number,
                                    p_ctg_destination_id number,
                                    p_date date
                                   ) return number is
    v_ret_val number;
    begin
      begin
      select ac.commis into v_ret_val
      from t_agent_commis ac
      where ac.ag_category_from_id = p_ctg_source_id
        and ac.ag_category_to_id = p_ctg_destination_id
        and ac.contract_period = p_year_contract
        and ac.product_id = p_product_id
        and ac.date_in = (
                          select max(ac2.date_in)
                            from t_agent_commis ac2
                           where
                              ac2.ag_category_from_id = p_ctg_source_id
                              and ac2.ag_category_to_id = p_ctg_destination_id
                              and ac2.contract_period = p_year_contract
                              and ac2.product_id = p_product_id
                              and ac2.date_in < p_date
                         );
      exception
        when NO_DATA_FOUND then
          v_ret_val := 0;
      end;
      return v_ret_val;
    end;
  
  */

  --��������� ���� ���������� � ����� � ���������� ����� � ������� AGENT_REPORT
  --��� ��� �� ������������ ���������
  PROCEDURE make_comiss_to_manager(p_akt_agent_id IN NUMBER) IS
  
    /* v_agent_id          number;
    v_akt_date          date;
    v_date_begin        date;
    v_product_id        number;
    v_contract_period   number;
    v_ctg_source_id     number;
    v_amount            number;
    v_oper_templ_id     number;
    v_trans_templ_id    number;
    v_dt_acc_id         number;
    v_ct_acc_id         number;
    v_Doc_Status_Ref_ID number;
    v_oper_id           number;
    v_oper_name         varchar2(1000);
    v_ent_contact_id    number;
    v_amount_acc        number;
    v_sq_year_id        number;
    v_def_id            number;
    v_type_id           number;
    v_commiss           number;  */
  BEGIN
    NULL;
    /*
       v_agent_id := null;
       v_akt_date := null;
       v_date_begin := null;
       v_product_id := null;
       v_contract_period := null;
       v_ctg_source_id := null;
       v_amount := null;
       v_oper_templ_id := null;
       v_trans_templ_id := null;
       v_dt_acc_id := null;
       v_ct_acc_id := null;
       v_Doc_Status_Ref_ID := null;
       v_oper_id := null;
       v_oper_name := null;
       v_ent_contact_id := ent.id_by_brief('CONTACT');
       v_amount_acc := null;
       begin
    -- ������� ������, ��� ��������� � ������ (v_date_begin, v_akt_date) �� ������� ���� ��������
        select ar.report_date, ac.date_begin, ach.agent_id, ac.category_id
          into v_akt_date, v_date_begin, v_agent_id, v_ctg_source_id
          from agent_report ar, ag_contract_header ach, ag_contract ac
          where ar.agent_report_id = p_akt_agent_id
            and ar.ag_contract_id = ac.ag_contract_id
            and ac.contract_id = ach.ag_contract_header_id;
    
    -- ����� oper_template_id
       select ot.oper_templ_id, ot.name into v_oper_templ_id, v_oper_name
       from oper_templ ot where ot.brief = '����������������������';
    -- ����� Doc_Status_Ref_ID
       select dsr.doc_status_ref_id into v_Doc_Status_Ref_ID
       from doc_status_ref dsr where dsr.name = '�����';
    
    -- ����� ����� ��������� ��� ��������
       select tt.trans_templ_id, tt.dt_account_id, tt.ct_account_id
       into v_trans_templ_id, v_dt_acc_id, v_ct_acc_id
       from trans_templ tt where tt.brief = '����������������������';
    
    
        -- ���� �� ��������� �� �������� �������������
        -- ��� ����������� ��������.
        for c_trans in (
                         select t.trans_id,
                                t.trans_amount,
                                t.trans_fund_id,
                                t.a1_dt_ure_id,
                                t.a1_dt_uro_id,
                                t.a1_ct_ure_id,
                                t.a1_ct_uro_id,
                                t.a2_dt_ure_id,
                                t.a2_dt_uro_id,
                                t.a2_ct_ure_id,
                                t.a2_ct_uro_id,
                                t.a3_dt_ure_id,
                                t.a3_dt_uro_id,
                                t.a3_ct_ure_id,
                                t.a3_ct_uro_id,
                                t.a4_dt_ure_id,
                                t.a4_dt_uro_id,
                                t.a4_ct_ure_id,
                                t.a4_ct_uro_id,
                                t.a5_dt_ure_id,
                                t.a5_dt_uro_id,
                                t.a5_ct_ure_id,
                                t.a5_ct_uro_id,
                                t.acc_chart_type_id,
                                t.acc_fund_id,
                                t.acc_amount,
                                t.acc_rate,
                                t.source
                           from trans t, trans_templ tt
                           where t.trans_templ_id = tt.trans_templ_id
                             and tt.brief = '�������������'
                             and t.a1_dt_uro_id = v_agent_id
                             and t.trans_date between v_date_begin and v_akt_date
                            -- ������� �� �� ��� �������� �� �������� ������������� ������ ����� �� ������
                             and not exists
                                           ( select t2.trans_id
                                                   from trans t2,
                                                        trans_templ tt2,
                                                        oper o,
                                                        doc_set_off dso,
                                                        ac_payment ap,
                                                        agent_report_cont arc
                                                   where tt2.brief = '�������������'
                                                     and tt2.trans_templ_id = t2.trans_templ_id
                                                     and o.oper_id = t2.oper_id
                                                     and o.document_id = dso.doc_set_off_id
                                                     and ap.payment_id = dso.child_doc_id
                                                     and ap.payment_id = arc.payment_id
                                                     and t2.trans_id = t.trans_id
                                                     and arc.agent_report_id <> p_akt_agent_id
                                           )
                       )
       loop
          -- ������� �������
          select pv.product_id into v_product_id
          from t_product_version pv, t_product_ver_lob pvl, t_product_line pl, t_prod_line_option plo
          where pvl.product_version_id = pv.t_product_version_id
            and pl.product_ver_lob_id = pvl.t_product_ver_lob_id
            and plo.product_line_id = pl.id
            and plo.id = c_trans.a4_dt_uro_id;
    
          -- ������� ���� �������� �������� �����������
          select decode(ceil((v_akt_date - p.start_date)/365.33),0,1,ceil((v_akt_date - p.start_date)/365.33))
          into v_contract_period
          from p_policy p
          where p.policy_id = c_trans.a2_dt_uro_id;
    
          select y.t_sq_year_id
            into v_sq_year_id
            from t_sq_year y
          where y.brief=v_contract_period;
    
          -- ����� ���� ������� � ��� ���������
          for c_manager in (
                             select ac.category_id,
                                    ach.agent_id
                             from doc_doc dd,
                                  ag_commiss agc,
                                  ag_contract ac,
                                  ag_contract_header ach
                             where agc.ag_commiss_id = dd.doc_doc_id
                               and ac.ag_contract_id = dd.parent_id
                               and ach.ag_contract_header_id = ac.contract_id
                               and dd.child_id = (select ar.ag_contract_id from agent_report ar
                                                   where ar.agent_report_id = p_akt_agent_id
                                                 )
                           )
          loop
            get_rate(v_ctg_source_id,
                     c_manager.category_id,
                     v_product_id,
                     v_sq_year_id,
                     v_akt_date,
                     v_def_id,
                     v_type_id,
                     v_commiss
                    );
           v_amount := round(c_trans.trans_amount * v_commiss/100,2);
    
           v_amount_acc := round(c_trans.acc_amount * v_commiss/100,2);
    
           if v_amount > 0.009 then
    -- ��������� ��������
             insert into oper
               (
                 oper_id,
                 oper_templ_id,
                 document_id,
                 oper_date,
                 name,
                 doc_status_ref_id
               )
             values
               (
                 sq_oper.nextval,
                 v_oper_templ_id,
                 p_akt_agent_id,
                 v_akt_date,
                 v_oper_name,
                 v_Doc_Status_Ref_ID
               )
             returning oper_id into v_oper_id;
             commit;
    
             insert into trans
               (
                trans_id,
                trans_date,
                trans_fund_id,
                trans_amount,
                dt_account_id,
                ct_account_id,
                is_accepted,
                a1_dt_ure_id,
                a1_dt_uro_id,
                a1_ct_ure_id,
                a1_ct_uro_id,
                a2_dt_ure_id,
                a2_dt_uro_id,
                a2_ct_ure_id,
                a2_ct_uro_id,
                a3_dt_ure_id,
                a3_dt_uro_id,
                a3_ct_ure_id,
                a3_ct_uro_id,
                a4_dt_ure_id,
                a4_dt_uro_id,
                a4_ct_ure_id,
                a4_ct_uro_id,
                a5_dt_ure_id,
                a5_dt_uro_id,
                a5_ct_ure_id,
                a5_ct_uro_id,
                trans_templ_id,
                acc_chart_type_id,
                acc_fund_id,
                acc_amount,
                acc_rate,
                oper_id,
                source
               )
             values
               (
                sq_trans.nextval,
                v_akt_date,
                c_trans.trans_fund_id,
                v_amount,
                v_dt_acc_id,
                v_ct_acc_id,
                1,
                v_ent_contact_id,
                v_agent_id, -- ����� �� ��������
                v_ent_contact_id,
                c_manager.agent_id, -- ����� ��������
                c_trans.a2_dt_ure_id,
                c_trans.a2_dt_uro_id,
                c_trans.a2_ct_ure_id,
                c_trans.a2_ct_uro_id,
                c_trans.a3_dt_ure_id,
                c_trans.a3_dt_uro_id,
                c_trans.a3_ct_ure_id,
                c_trans.a3_ct_uro_id,
                c_trans.a4_dt_ure_id,
                c_trans.a4_dt_uro_id,
                c_trans.a4_ct_ure_id,
                c_trans.a4_ct_uro_id,
                c_trans.a5_dt_ure_id,
                c_trans.a5_dt_uro_id,
                c_trans.a5_ct_ure_id,
                c_trans.a5_ct_uro_id,
                v_trans_templ_id,
                c_trans.acc_chart_type_id,
                c_trans.acc_fund_id,
                v_amount_acc,
                c_trans.acc_rate,
                v_oper_id,
                c_trans.source
               );
             commit;
             v_oper_id := null;
           end if;
          end loop;
       end loop;
       commit;
       exception
         when NO_DATA_FOUND then null;
       end;
      */
  END;

  FUNCTION get_aps_id_by_brief(par_brief IN VARCHAR2) RETURN NUMBER IS
    RESULT NUMBER;
  BEGIN
    SELECT p.policy_agent_status_id
      INTO RESULT
      FROM ven_POLICY_AGENT_STATUS p
     WHERE p.brief = par_brief;
    RETURN RESULT;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN NULL;
    
  END; --func

  FUNCTION get_status_agent_policy(par_POLICY_AGENT_ID IN NUMBER) RETURN NUMBER IS
    RESULT NUMBER;
  BEGIN
    SELECT p.status_id
      INTO RESULT
      FROM ven_p_policy_agent p
     WHERE p.p_policy_agent_id = par_POLICY_AGENT_ID;
  
    RETURN RESULT;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN NULL;
  END; --func

  FUNCTION get_id RETURN NUMBER IS
  BEGIN
    RETURN Pkg_Agent.v_contract_id;
  END;

  PROCEDURE get_parameter(p_contract_id NUMBER) IS
  BEGIN
    Pkg_Agent.v_contract_id := p_contract_id;
  END;

  FUNCTION Transmit_Policy
  (
    pv_policy_header_id         IN NUMBER
   ,p_old_AG_CONTRACT_HEADER_ID IN NUMBER
   ,p_new_AG_CONTRACT_HEADER_ID IN NUMBER
   ,p_date_break                IN DATE
   ,msg                         OUT VARCHAR2
  ) RETURN NUMBER IS
    --de date;
    rec1 P_POLICY_AGENT%ROWTYPE;
    rec2 P_POLICY_AGENT%ROWTYPE;
  
    v_rate_type  INTEGER;
    v_rate_value INTEGER;
  
    v_policy_agent_id INTEGER;
    RESULT            NUMBER;
    res               INTEGER;
    s1                VARCHAR(255);
    s2                VARCHAR(255);
    --res1 integer;
  
    dt1 DATE;
    dt2 DATE;
  
    CURSOR curs
    (
      p_h_id   IN NUMBER
     ,p_id     IN NUMBER
     ,p_status VARCHAR2
    ) IS
      SELECT *
        FROM P_POLICY_AGENT ppa
       WHERE ppa.policy_header_id = p_h_id
         AND ppa.ag_contract_header_id = p_id
         AND ppa.status_id = Ent.get_obj_id('policy_agent_status', p_status);
  
  BEGIN
    msg    := '';
    RESULT := 0;
  
    SAVEPOINT func_trans_pol;
  
    -- �������� ������ ��� ����������� ���� "�������" ������
    OPEN curs(pv_policy_header_id, p_old_AG_CONTRACT_HEADER_ID, 'current');
    FETCH curs
      INTO rec1;
  
    IF curs%NOTFOUND
    THEN
      msg := '�� ������ ����� (id=' || p_old_AG_CONTRACT_HEADER_ID ||
             '), ����������� � ��������� (id=' || pv_policy_header_id || ')';
      CLOSE curs;
      RETURN 1;
    END IF; -- �� ���� ����� ����� ������
    CLOSE curs;
  
    -- ���� ��������� ������ �������� ������
    BEGIN
      IF Doc.get_doc_status_brief(p_new_AG_CONTRACT_HEADER_ID, p_date_break) = 'BREAK'
      THEN
        SELECT DISTINCT ch.agent_id
          INTO res
          FROM AG_CONTRACT_HEADER ch
         WHERE ch.ag_contract_header_id = p_new_AG_CONTRACT_HEADER_ID;
      
        msg := '������� ������, ����������� ����� ���������, �� ��������� �� ���� �������� ��������� ' ||
               Ent.obj_name(Ent.id_by_brief('CONTACT'), res) || CHR(10) ||
               '�������� �������� �� ���� ������������';
        RETURN 1;
      ELSE
        SELECT c.date_end
          INTO dt1
          FROM ven_ag_contract_header ch
              ,ven_ag_contract        c
         WHERE ch.last_ver_id = c.ag_contract_id
           AND ch.ag_contract_header_id = p_new_AG_CONTRACT_HEADER_ID;
      
      END IF;
    END;
  
    BEGIN
      SELECT pp.end_date
        INTO dt2
        FROM ven_p_policy pp
       WHERE pp.policy_id = Pkg_Policy.get_curr_policy(pv_policy_header_id);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        dt2 := rec1.date_end; -- p_date_break;
    END;
    -- ������ ������� ������ ������ "�������"
    UPDATE P_POLICY_AGENT pa
       SET date_end       = p_date_break
          ,status_id      = Ent.get_obj_id('policy_agent_status', 'CANCEL')
          ,pa.status_date = p_date_break
     WHERE pa.POLICY_HEADER_ID = pv_policy_header_id --cur.num
       AND pa.AG_CONTRACT_HEADER_ID = p_old_AG_CONTRACT_HEADER_ID; --:db_e.AG_CONTRACT_HEADER_ID;
  
    -- ���� ������ ������, �������� �� ��� � ����� �������� ��� ���
    OPEN curs(pv_policy_header_id, p_new_AG_CONTRACT_HEADER_ID, 'current');
    FETCH curs
      INTO rec2;
  
    IF curs%FOUND
    THEN
      CLOSE curs;
      -- ����� ����� ��� �������� � ����� �������� � ������� "�����������"
      IF rec1.ag_type_rate_value_id <> rec2.ag_type_rate_value_id
      THEN
        v_rate_type  := rec2.ag_type_rate_value_id;
        v_rate_value := rec2.part_agent;
        SELECT DISTINCT ch.agent_id
          INTO res
          FROM AG_CONTRACT_HEADER ch
         WHERE ch.ag_contract_header_id = p_new_AG_CONTRACT_HEADER_ID;
        msg    := '����� ' || Ent.obj_name(Ent.id_by_brief('CONTACT'), res) ||
                  ', �������� ��������� ����� ��� �������� � �������� �����������.' || CHR(10) ||
                  '��� ������ � ������ ����� ������ ��������� ��� ���������';
        RESULT := 2;
      END IF;
      IF rec1.ag_type_rate_value_id = rec2.ag_type_rate_value_id
      THEN
        v_rate_type  := rec2.ag_type_rate_value_id;
        v_rate_value := rec1.part_agent + rec2.part_agent;
        SELECT DISTINCT ch.agent_id
          INTO res
          FROM AG_CONTRACT_HEADER ch
         WHERE ch.ag_contract_header_id = p_new_AG_CONTRACT_HEADER_ID;
        msg    := '����� ' || Ent.obj_name(Ent.id_by_brief('CONTACT'), res) ||
                  ', �������� ��������� ����� ��� �������� � �������� �����������.' || CHR(10) ||
                  '������ ������ ���� ��������� �� ' || rec1.part_agent;
        RESULT := 2;
      END IF;
    
      v_policy_agent_id := rec2.p_policy_agent_id;
    
      UPDATE P_POLICY_AGENT ppa
         SET --ppa.date_start= �� ��������
             ppa.date_end = GREATEST(TO_DATE(rec1.date_end), TO_DATE(rec2.date_end))
            ,
             --ppa.status_id=�� ��������
             --ppa.status_date= �� ��������
             ppa.part_agent            = v_rate_value
            ,ppa.ag_type_rate_value_id = v_rate_type
       WHERE ppa.policy_header_id = pv_policy_header_id
         AND ppa.ag_contract_header_id = p_new_AG_CONTRACT_HEADER_ID;
    
    ELSE
      CLOSE curs;
      -- ����� ����� �� ���������� � ������� "�����������" ��� ����� ��������.
      OPEN curs(pv_policy_header_id, p_new_AG_CONTRACT_HEADER_ID, 'new');
      FETCH curs
        INTO rec2;
    
      IF curs%FOUND
      THEN
        -- ����� �������� � ������� "�����"
        CLOSE curs;
        v_policy_agent_id := rec2.p_policy_agent_id;
      
        UPDATE P_POLICY_AGENT ppa
           SET ppa.date_start = p_date_break
              ,ppa.date_end   = LEAST(dt1, dt2)
              , -- rec2.date_end,
               /*least(rec1.date_end,rec2.date_end),*/ppa.status_id             = Ent.get_obj_id('policy_agent_status'
                                                         ,'current')
              ,ppa.status_date           = p_date_break
              ,ppa.part_agent            = rec1.part_agent
              ,ppa.ag_type_rate_value_id = rec1.ag_type_rate_value_id
         WHERE ppa.p_policy_agent_id = v_policy_agent_id;
        /*where ppa.policy_header_id=pv_policy_header_id
        and ppa.ag_contract_header_id=p_new_AG_CONTRACT_HEADER_ID;*/
      
      ELSE
        CLOSE curs;
        -- ����� �� �������� � ��������
        SELECT sq_p_policy_agent.NEXTVAL INTO v_policy_agent_id FROM dual;
      
        INSERT INTO P_POLICY_AGENT ppa
          (ppa.p_policy_agent_id
          ,ppa.date_start
          ,ppa.date_end
          ,ppa.status_id
          ,ppa.status_date
          ,ppa.part_agent
          ,ppa.ag_type_rate_value_id
          ,ppa.ag_contract_header_id
          ,ppa.policy_header_id)
        VALUES
          (v_policy_agent_id
          ,p_date_break
          ,LEAST(dt1, dt2)
          , --rec1.date_end,--���� ����� = min(���� ��������� �������� ������ ��.�������� � �������� �����.)
           Ent.get_obj_id('policy_agent_status', 'current')
          ,p_date_break
          ,rec1.part_agent
          ,rec1.ag_type_rate_value_id
          ,p_new_AG_CONTRACT_HEADER_ID
          ,pv_policy_header_id); /**/
      
      END IF;
    END IF;
  
    -- ���������� ��� ������ ������ ��������� ���������, ���� ��� ��� �� ���������� ��� ����.
    SELECT COUNT(*) INTO res FROM VEN_P_POLICY_AGENT_COM WHERE p_policy_agent_id = v_policy_agent_id;
  
    IF res = 0
    THEN
      res := pkg_agent.Define_Agent_Prod_Line(v_policy_agent_id, p_new_ag_contract_header_id);
      IF res <> 0
      THEN
        msg    := '������ ��� ����������� ��������� ���������. ' || chr(10) || SQLERRM(res);
        RESULT := 1;
      ELSE
        res := pkg_agent.check_defined_commission(pv_policy_header_id, p_new_AG_CONTRACT_HEADER_ID);
        IF res < 0
        THEN
          msg    := '������ ��� ����������� ��������� ���������. ' || chr(10) || SQLERRM(res);
          RESULT := 1;
        END IF;
        SELECT ch1.num
          INTO s1
          FROM ven_p_pol_header ch1
         WHERE ch1.policy_header_id = pv_policy_header_id;
        --select ch.num into s1 from ven_ag_contract_header ch where ch.ag_contract_header_id=p_old_AG_CONTRACT_HEADER_ID;
        SELECT ch.num
          INTO s2
          FROM ven_ag_contract_header ch
         WHERE ch.ag_contract_header_id = p_new_AG_CONTRACT_HEADER_ID;
        IF res > 0
        THEN
          msg    := '��� �������� �������� ����������� ����� ' || s1 || chr(10) ||
                    '������ � ��.��������� ����� ' || s2 || chr(10) ||
                    ' �������� ������ ������������� �������������� �� ���������� ��� ' || res ||
                    ' ��������.';
          RESULT := 2;
        END IF;
      END IF;
    END IF;
    -- �������� � P_POL_HEADER � ������ ������
    /*    v_new_contract_id:=get_status_contr_activ_id(p_new_AG_CONTRACT_HEADER_ID);
        update P_POL_HEADER pp
        set pp.AG_CONTRACT_1_ID = v_new_contract_id
        where
        ;--p_new_AG_CONTRACT_HEADER_ID;--:db_e.TRANS_AG_CONTRACT_ID;
    */
    RETURN RESULT; -- �� ��
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK TO func_trans_pol;
      IF curs%ISOPEN
      THEN
        CLOSE curs;
      END IF;
      RETURN SQLCODE;
  END; -- func

  -- ��������� ���� �� �������������� �������� �� �������� ����������� ���
  FUNCTION check_defined_commission
  (
    p_policy_header_id      IN NUMBER
   ,p_ag_contract_header_id IN NUMBER
  ) RETURN NUMBER IS
    v_c               NUMBER;
    RESULT            NUMBER := 0;
    v_id              NUMBER;
    v_policy_agent_id NUMBER;
  
  BEGIN
  
    SELECT pa.p_policy_agent_id
      INTO v_policy_agent_id
      FROM P_POLICY_AGENT pa
     WHERE pa.policy_header_id = p_policy_header_id
       AND pa.ag_contract_header_id = p_ag_contract_header_id;
    --v_policy_agent_id:=pkg_policy.get_curr_policy(p_policy_header_id);
    SELECT ph.product_id
      INTO v_id
      FROM P_POL_HEADER   ph
          ,P_POLICY_AGENT pa
     WHERE ph.policy_header_id = pa.policy_header_id
       AND pa.p_policy_agent_id = v_policy_agent_id;
  
    IF RESULT = 0
    THEN
      FOR idx IN (SELECT tpl.ID --into result
                    FROM ven_t_product         tp
                        ,ven_t_product_version tpv
                        ,ven_t_product_ver_lob tpvl
                        ,ven_t_product_line    tpl
                   WHERE tpv.product_id(+) = tp.product_id
                     AND tpvl.product_version_id(+) = tpv.t_product_version_id
                     AND tpl.product_ver_lob_id = tpvl.t_product_ver_lob_id
                     AND tp.product_id = v_id)
      LOOP
        --v_id:=get_prod_line_by_product(v_id);
        --if v_id is null then return 0;end if;
        BEGIN
          SELECT COUNT(*)
            INTO v_c
            FROM ven_p_policy_agent_com pac
           WHERE pac.t_product_line_id = idx.ID
             AND pac.p_policy_agent_id = v_policy_agent_id
             AND val_com IS NULL
             AND t_prod_coef_type_id IS NULL
           GROUP BY pac.p_policy_agent_id;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            v_c := 0;
        END;
        RESULT := RESULT + v_c;
      END LOOP;
    END IF;
  
    RETURN RESULT;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN 0;
    WHEN OTHERS THEN
      RETURN SQLCODE;
  END; -- func check_defined_commission

  FUNCTION Define_Agent_Prod_Line
  (
    pv_policy_agent_id      IN NUMBER
   ,p_ag_contract_header_id IN NUMBER
   ,p_cur_date              IN DATE DEFAULT SYSDATE
  ) RETURN NUMBER IS
    v_c          NUMBER;
    v_product_id NUMBER;
    v_rez        NUMBER := 0;
  BEGIN
  
    SELECT COUNT(*)
      INTO V_C
      FROM VEN_P_POLICY_AGENT_COM C
     WHERE C.p_policy_agent_id = pv_policy_agent_id;
  
    BEGIN
      SELECT ph.product_id
        INTO v_product_id
        FROM P_POL_HEADER   ph
            ,P_POLICY_AGENT pa
       WHERE ph.policy_header_id = pa.policy_header_id
         AND pa.p_policy_agent_id = pv_policy_agent_id;
    EXCEPTION
      WHEN OTHERS THEN
        v_rez := 1; -- �� ��������� ������� �� ������
    END;
  
    IF (V_C <> 0)
       AND v_rez = 0
    THEN
      BEGIN
        DELETE FROM ven_p_policy_agent_com WHERE p_policy_agent_id = pv_policy_agent_id;
      EXCEPTION
        WHEN OTHERS THEN
          v_rez := 2; -- ���������� ������� ������������ ������ �� �� ������ �� ��������
      END;
    END IF;
    IF v_rez = 0
    THEN
      BEGIN
        INSERT INTO ven_p_policy_agent_com
          (p_policy_agent_com_id
          ,t_product_line_id
          ,p_policy_agent_id
          ,ag_type_rate_value_id
          ,val_com
          ,ag_type_defin_rate_id
          ,t_prod_coef_type_id)
          SELECT sq_p_policy_agent_com.NEXTVAL
                ,tpl.ID prod_line_id
                ,pv_policy_agent_id
                ,Pkg_Policy.find_commission(1, p_ag_contract_header_id, tpl.ID, p_cur_date)
                ,Pkg_Policy.find_commission(2, p_ag_contract_header_id, tpl.ID, p_cur_date)
                ,Pkg_Policy.find_commission(3, p_ag_contract_header_id, tpl.ID, p_cur_date)
                ,Pkg_Policy.find_commission(4, p_ag_contract_header_id, tpl.ID, p_cur_date)
            FROM ven_t_product         tp
                ,ven_t_product_version tpv
                ,ven_t_product_ver_lob tpvl
                ,ven_t_product_line    tpl
           WHERE tpv.product_id(+) = tp.product_id
             AND tpvl.product_version_id(+) = tpv.t_product_version_id
             AND tpl.product_ver_lob_id = tpvl.t_product_ver_lob_id
             AND tp.product_id = v_product_id
             AND tpl.description <> '���������������� ��������';
      EXCEPTION
        WHEN OTHERS THEN
          v_rez := SQLCODE; -- ������ ��� ������ ������ �� ����� ������� �� � ����
      END;
    END IF;
    RETURN v_rez;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN SQLCODE;
    
  END; --func

  FUNCTION policy_check_trans(p_ag_contract_header_id NUMBER) RETURN NUMBER IS
    n   NUMBER;
    msg VARCHAR2(255);
    -- ���������� ���� ������� � ����������� � "������� �����������" �� ���� ����������,
    -- ��� ����� � p_id �������� ������, ����� ����� ������ � p_id
    CURSOR curs(p_id IN NUMBER) IS
      SELECT *
        FROM P_POLICY_AGENT pp
       WHERE pp.status_id = Ent.get_obj_id('policy_agent_status', 'CURRENT')
         AND pp.ag_contract_header_id <> p_id
         AND pp.policy_header_id IN
             (SELECT p.policy_header_id
                FROM P_POLICY_AGENT p
               WHERE p.ag_contract_header_id = p_id
                 AND p.status_id = Ent.get_obj_id('policy_agent_status', 'CURRENT'));
    -- ���������� �� ��������� ��������� p_h_id � id ������ p_id ��� ������ �� p_policy_agent
    CURSOR curs1
    (
      p_h_id   IN NUMBER
     ,p_id     IN NUMBER
     ,p_status VARCHAR2
    ) IS
      SELECT *
        FROM P_POLICY_AGENT ppa
       WHERE ppa.policy_header_id = p_h_id
         AND ppa.ag_contract_header_id = p_id
         AND ppa.status_id = Ent.get_obj_id('policy_agent_status', UPPER(p_status));
  
    rec1 curs1%ROWTYPE;
    rec  curs%ROWTYPE;
  BEGIN
    BEGIN
      SELECT 1
        INTO n
        FROM dual
       WHERE EXISTS (SELECT COUNT(p.ag_contract_header_id)
                    ,p.policy_header_id
                FROM P_POLICY_AGENT p
               WHERE p.status_id = Ent.get_obj_id('policy_agent_status', 'CURRENT')
                 AND EXISTS
               (SELECT p1.policy_header_id
                        FROM P_POLICY_AGENT p1
                       WHERE p1.ag_contract_header_id = p_ag_contract_header_id
                         AND p1.policy_header_id = p.policy_header_id
                         AND p1.status_id = Ent.get_obj_id('policy_agent_status', 'CURRENT'))
              --       and p.ag_contract_header_id=p_ag_contract_header_id
               GROUP BY p.policy_header_id
              HAVING COUNT(p.ag_contract_header_id) <> 2);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        n := 0;
    END;
  
    IF n = 1
    THEN
      RETURN 1;
    END IF;
    msg := '';
  
    -- ������� ���� �������, ������� ����� �������� ����
    OPEN curs(p_ag_contract_header_id);
    --   while curs%FOUND
    LOOP
      FETCH curs
        INTO rec;
      EXIT WHEN curs%NOTFOUND;
      -- ��������� �� ���������� ��������� (rec.policy_header_id) ������,
      -- ����������� � ������������ ������ p_ag_contract_header_id � ������� "�����������"
      OPEN curs1(rec.policy_header_id, p_ag_contract_header_id, 'CURRENT');
      FETCH curs1
        INTO rec1;
      IF curs1%NOTFOUND
      THEN
        CLOSE curs1;
        CLOSE curs;
        EXIT; -- ���������� ���, ������ �� ��, ���������� ������
      END IF;
      -- �������� �� ���������� ��������� (rec.policy_header_id) ���� ������
      -- rec1.ag_contract_header_id (== p_ag_contract_header_id)
      -- ������  rec.ag_contract_header_id
      n := Transmit_policy(rec.policy_header_id
                          ,rec1.ag_contract_header_id
                          ,rec.ag_contract_header_id
                          ,SYSDATE
                          ,msg);
      IF n < 0
      THEN
        CLOSE curs;
        CLOSE curs1;
        RETURN n;
      END IF;
      CLOSE curs1;
    END LOOP;
  
    UPDATE ven_p_policy_agent pa
       SET pa.status_id = Ent.get_obj_id('policy_agent_status', 'CANCEL')
     WHERE pa.ag_contract_header_id = p_ag_contract_header_id
       AND pa.status_id = Ent.get_obj_id('policy_agent_status', 'NEW');
  
    RETURN 0;
  END;
  ----------------------------------------------------------------------------
  --****************************************************************************
  -- ������� : ���������� � ����������� ID ������� ������
  FUNCTION find_id_agent_status(p_ag_contract_header_id NUMBER) RETURN NUMBER IS
  
    v_rez  NUMBER := 1;
    v_hist ven_ag_stat_hist%ROWTYPE;
  BEGIN
    -- ���������� ���������� ��������� ������
  
    BEGIN
      SELECT NVL(c.category_id, 1)
            ,NVL(c.date_begin, ch.date_begin)
        INTO v_hist.ag_category_agent_id
            ,v_hist.stat_date
        FROM ven_ag_contract_header ch
            ,ven_ag_contract        c
       WHERE ch.last_ver_id = c.ag_contract_id
         AND ch.ag_contract_header_id = p_ag_contract_header_id;
    EXCEPTION
      WHEN OTHERS THEN
        v_hist.ag_category_agent_id := 1;
        v_hist.stat_date            := SYSDATE;
    END;
  
    -- ���������� ������� ��������� ������
    /*
    begin
        select c.category_id into v_hist.ag_category_agent_id
        from   ven_ag_contract_header ch,
               ven_ag_contract c
        where  ch.ag_contract_header_id=c.contract_id
          and  ch.ag_contract_header_id=p_ag_contract_header_id
          and  c.ag_contract_id in (select max(c1.ag_contract_id)
                                    from ven_ag_contract c1
                                    where c1.contract_id=c.contract_id);
    
       exception when others then v_hist.ag_category_agent_id:=1;
       end;
    */
    -- ����������: �������� �� ��������� ������ � ������� ��������� �������� ������� �� ������ ���������
    BEGIN
      SELECT 1
        INTO v_rez
        FROM dual
       WHERE EXISTS (SELECT '1'
                FROM ven_ag_stat_hist h
               WHERE h.ag_stat_hist_id =
                     (SELECT MAX(t.ag_stat_hist_id)
                        FROM ven_ag_stat_hist t
                       WHERE t.ag_contract_header_id = p_ag_contract_header_id)
                 AND h.ag_category_agent_id = v_hist.ag_category_agent_id);
    EXCEPTION
      WHEN OTHERS THEN
        v_rez := 0;
    END;
    -- ��� ���������� ������ - ��������� ����� ������ � ���������� �������� �� ������ ���������
    IF v_rez = 0
    THEN
    
      BEGIN
        SELECT NVL(MAX(sh.num), 0)
          INTO v_hist.num
          FROM ven_ag_stat_hist sh
         WHERE sh.ag_contract_header_id = p_ag_contract_header_id;
      EXCEPTION
        WHEN OTHERS THEN
          v_hist.num := 0;
      END;
    
      v_hist.num := v_hist.num + 1;
      --  v_hist.stat_date:= sysdate;
    
      BEGIN
        SELECT sa.ag_stat_agent_id
          INTO v_hist.ag_stat_agent_id
          FROM AG_STAT_AGENT sa
         WHERE sa.ag_category_agent_id = v_hist.ag_category_agent_id
           AND sa.is_default = 1;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          SELECT NULL INTO v_hist.ag_stat_agent_id FROM dual;
      END;
    
      BEGIN
        INSERT INTO ven_ag_stat_hist
          (ag_category_agent_id, ag_contract_header_id, ag_stat_agent_id, num, stat_date)
        VALUES
          (v_hist.ag_category_agent_id
          ,p_ag_contract_header_id
          ,v_hist.ag_stat_agent_id
          ,v_hist.num
          ,v_hist.stat_date);
      EXCEPTION
        WHEN OTHERS THEN
          RAISE_APPLICATION_ERROR(SQLCODE
                                 ,'�� ����������� ������ ��������� ��������:' || SQLERRM);
      END;
    END IF;
    -- ���������� ��� ������� �� ������ ���������
    BEGIN
      SELECT sa.ag_stat_agent_id
        INTO v_hist.ag_stat_agent_id
        FROM ven_ag_stat_hist      sh
            ,ven_ag_category_agent ac
            ,ven_ag_stat_agent     sa
       WHERE sh.ag_category_agent_id = ac.ag_category_agent_id
         AND sh.ag_category_agent_id = sa.ag_category_agent_id(+)
         AND sh.ag_stat_agent_id = sa.ag_stat_agent_id(+)
         AND sh.ag_contract_header_id = p_ag_contract_header_id
         AND sh.num IN (SELECT MAX(t.num)
                          FROM ven_ag_stat_hist t
                         WHERE t.ag_contract_header_id = sh.ag_contract_header_id);
    
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        SELECT NULL INTO v_hist.ag_stat_agent_id FROM dual;
      
    END;
    RETURN(v_hist.ag_stat_agent_id);
  END;
  ---------------------------------------------------------
  --*************************************************************
  ---/// -- ���������� ����� ���������������� �������� �� ��������� ��������
  FUNCTION find_sum_adm_izd(p_pol_header_id NUMBER) RETURN NUMBER IS
    v_sum_adm_izd NUMBER := 0;
  BEGIN
    SELECT DISTINCT NVL(pc.fee, 0)
      INTO v_sum_adm_izd
      FROM ven_p_pol_header ph -- ��������� �������� �����������
      JOIN ven_p_policy pp
        ON (ph.policy_id = pp.policy_id) -- ������� ������ �������� �����������
      JOIN ven_as_asset ass
        ON (ass.p_policy_id = pp.policy_id) -- ������ �� �������� �����������
      JOIN ven_p_cover pc
        ON (pc.as_asset_id = ass.as_asset_id) -- �������� �� �������� �����������
      JOIN ven_t_prod_line_option plo
        ON (plo.ID = pc.t_prod_line_option_id) -- ������ ������ �� ������ (��������� �����������)
     WHERE plo.description = '���������������� ��������'
       AND ph.policy_header_id = p_pol_header_id;
    RETURN(v_sum_adm_izd);
  EXCEPTION
    WHEN OTHERS THEN
      v_sum_adm_izd := 0;
      RETURN(v_sum_adm_izd);
  END;

  /*����������������*/
  FUNCTION find_sum_adm_izd_opt( /*p_pol_header_id number, */ pp_policy_id NUMBER) RETURN NUMBER IS
    v_sum_adm_izd NUMBER := 0;
  BEGIN
    SELECT DISTINCT NVL(pc.fee, 0)
      INTO v_sum_adm_izd
      FROM ---p_pol_header ph -- ��������� �������� �����������
           P_POLICY pp --on (ph.policy_id = pp.policy_id) -- ������� ������ �������� �����������
      JOIN AS_ASSET ass
        ON (ass.p_policy_id = pp.policy_id) -- ������ �� �������� �����������
      JOIN P_COVER pc
        ON (pc.as_asset_id = ass.as_asset_id) -- �������� �� �������� �����������
      JOIN T_PROD_LINE_OPTION plo
        ON (plo.ID = pc.t_prod_line_option_id) -- ������ ������ �� ������ (��������� �����������)
     WHERE plo.description = '���������������� ��������'
       AND pp.policy_id = pp_policy_id;
    --       and ph.policy_header_id = p_pol_header_id;
    RETURN(v_sum_adm_izd);
  EXCEPTION
    WHEN OTHERS THEN
      v_sum_adm_izd := 0;
      RETURN(v_sum_adm_izd);
  END;

  -- ������������ ����������� ��� �� ������ �������� ������ � ������������� ��� �������
  PROCEDURE attest_agent_SGP
  (
    p_ag_contract_header_id IN NUMBER
   ,p_start_date            DATE
   , -- ���� ������ ������������ �������
    p_end_date              DATE
   , -- ���� ����� ������������ �������
    p_K_SGP                 OUT NUMBER
  ) IS
  
    v_K_SGP        NUMBER := 0;
    v_Rate_Type_ID NUMBER;
  BEGIN
    -- ����������� ���� ����� �����
    SELECT rt.rate_type_id INTO v_Rate_Type_ID FROM RATE_TYPE rt WHERE rt.brief = '��';
  
    -- ������ ����������� K_SGP ������� ���� ������
    BEGIN
      IF NVL(glb_clear_flag_attest, '�') = '�'
      THEN
      
        DELETE FROM AG_STAT_DET_TMP;
      
      END IF;
      INSERT INTO AG_STAT_DET_TMP
      
      /*  select SQ_AG_STAT_DET_TMP.nextval AG_STAT_DET_TMP_ID, 0 , attest.*
        from
        (
        select   0                                            -- ��� �������� ���������
               , p_ag_contract_header_id                      -- ��� �������� ������
               , policy_id                            -- ��������� �������� �����������
               , sum (agent_rate * koef *( (koef_ccy * sum_prem) - sum_izd) )  -- ����� ������ ����� �������� � ������ �������������
        from (select ( case -- ����������� ���� ������ ��� ���������� ��������
                          when ( ar.brief = 'PERCENT' ) then pa.part_agent/100 -- �������
                          when ( ar.brief = 'ABSOL'   ) then pa.part_agent     -- ���������� ��������
                          else pa.part_agent                                   -- � ��������� ������ ���� ������, ��� ���������� ��������
                        end ) agent_rate,
                       (case
                         when (lower(tpt.description) like '%����������%'
                               and ceil(months_between(last_day(pp.end_date),last_day(ph.start_date)))>12)
                               then 0.1     -- ����� ����
                         when  (((lower(tpt.description) like '%����������%')
                                  and ceil(months_between(last_day(pp.end_date),last_day(ph.start_date)))<=12)
                               or
                               lower(tpt.description) not like '%����������%'
                               ) then 1
                         else 1
                        end) koef,
                      -- ����������� ������ ��������
                       acc_new.Get_Rate_By_ID(v_Rate_Type_ID, ph.fund_pay_id, pp.start_date)   koef_ccy,
                       -- ����� ������ * �� ���������� ������ � ����
                       pt.number_of_payments * nvl(ap.amount,0)  sum_prem,
                       -- ����� �������� * �� ���������� ������ � ����
                       pkg_agent_1.find_sum_adm_izd(ph.policy_header_id)* pt.number_of_payments sum_izd,
                       -- ��������� �������� �����������
                       pp.policy_id  policy_id
               from ven_p_pol_header ph                            -- ��������� �������� �����������
               join ven_p_policy pp on (ph.policy_id=pp.policy_id) -- ������� ������ �������� �����������
               join ven_doc_doc d on (d.parent_id=pp.policy_id)     -- ����� ���������� ��� ������� ������
               join ven_ac_payment ap on (ap.payment_id=d.child_id)-- �������� ������ �� ��������� ����
               join ven_p_policy_agent pa on (ph.policy_header_id=pa.policy_header_id) -- a����� �� �������� �����������
               join ven_p_policy_contact ppc on (ppc.policy_id=ph.policy_id)
               join ven_t_contact_pol_role tcp on (tcp.id=ppc.contact_policy_role_id and tcp.brief='������������')
               join ven_ag_contract_header ch on (ch.ag_contract_header_id=pa.ag_contract_header_id)
               join ven_policy_agent_status pas on (pa.status_id=pas.policy_agent_status_id) -- ������� ������� �� �������� �����������
               join ven_ag_type_rate_value ar on (pa.ag_type_rate_value_id=ar.ag_type_rate_value_id) -- ��� ���� ������ � ��������
               join t_payment_terms tpt on (pp.payment_term_id=tpt.id)
               join doc_set_off dso on (dso.parent_doc_id=ap.payment_id)
               join ven_ac_payment pa2 on (dso.child_doc_id=pa2.payment_id)
               left join ven_t_payment_terms pt on (pt.id = pp.payment_term_id)
      
               where ph.start_date between p_start_date and p_end_date -- ���� ���������� �������� � �������� �������
                 and pa2.due_date between p_start_date and p_end_date
                 and pas.brief in ('CURRENT')                          -- ������ ������ �� �������� �����������
                 and pa.ag_contract_header_id = p_ag_contract_header_id-- ������� �� ����������� ������
                 and doc.get_doc_status_brief(ap.payment_id)='PAID'    -- ���� ������ �������
                 and ch.agent_id <> ppc.contact_id
               )
         group by  0, p_ag_contract_header_id, policy_header_id
         ) attest  ;
      */
      
      -- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
      -- ����� ������� ����� ������� �������
        SELECT SQ_AG_STAT_DET_TMP.NEXTVAL AG_STAT_DET_TMP_ID
              ,0 filial_id
              ,0 men_id -- ��� �������� ���������
              ,p_ag_contract_header_id contract_header_id -- ��� �������� ������
              ,policy_id -- ��������� �������� �����������
              ,agent_rate * koef * ((koef_ccy * sum_prem) - sum_izd) sgp_amount /** koef_prikaz */ -- ����� ������ ����� �������� � ������ �������������
          FROM (SELECT /*distinct*/
                 (CASE -- ����������� ���� ������ ��� ���������� ��������
                   WHEN (ar.brief = 'PERCENT') THEN
                    pa.part_agent / 100 -- �������
                   WHEN (ar.brief = 'ABSOL') THEN
                    pa.part_agent -- ���������� ��������
                   ELSE
                    pa.part_agent -- � ��������� ������ ���� ������, ��� ���������� ��������
                 END) agent_rate
                ,(CASE
                   WHEN pt.brief = '�������������'
                        AND
                        CEIL(MONTHS_BETWEEN(LAST_DAY(pp.end_date)
                                           ,LAST_DAY(Pkg_Agent_1.get_agent_start_contr(ph.policy_header_id)))) > 12 THEN
                    0.1 -- ����� ����
                   WHEN (pt.brief = '�������������' AND
                        CEIL(MONTHS_BETWEEN(LAST_DAY(pp.end_date)
                                            ,LAST_DAY(Pkg_Agent_1.get_agent_start_contr(ph.policy_header_id)))) <= 12)
                        OR pt.brief <> '�������������' THEN
                    1
                   ELSE
                    1
                 END) koef
                ,Acc_New.Get_Rate_By_ID(v_Rate_Type_ID, ph.fund_id, pp.start_date) koef_ccy
                ,
                 -- ����� ������
                 pt.number_of_payments *
                 (SELECT SUM(pc.fee)
                    FROM P_COVER  pc
                        ,AS_ASSET aa
                   WHERE aa.p_policy_id = pp.policy_id
                     AND aa.as_asset_id = pc.as_asset_id) sum_prem
                ,
                 --                        pt.number_of_payments * nvl(ap.amount, 0) sum_prem,
                 -- ����� �������� * �� ���������� ������ � ����
                 Pkg_Agent_1.find_sum_adm_izd(ph.policy_header_id) * pt.number_of_payments sum_izd
                ,
                 -- ��������� �������� �����������
                 pp.policy_id policy_id
                  FROM ven_p_pol_header ph
                      ,ven_p_policy     pp
                      ,
                       
                       ven_p_policy_agent pa
                      ,
                       --ven_t_contact_pol_role  tcp,
                       ven_ag_contract_header  ch
                      ,ven_policy_agent_status pas
                      ,ven_ag_type_rate_value  ar
                      ,
                       --t_payment_terms         tpt,
                       
                       ven_t_payment_terms pt -- ��������� �������� �����������
                
                 WHERE ph.policy_id = pp.policy_id
                   AND EXISTS (SELECT 1
                          FROM ven_doc_doc      d
                              ,ven_ac_payment   ap
                              ,DOC_SET_OFF      dso
                              ,ven_ac_payment   pa2
                              ,AC_PAYMENT_TEMPL acpt
                              ,
                               -- �������� ��� ������ ����������
                               -- ����� ����� ���� ���������� � �� � ������� ������
                               P_POLICY pp_2
                         WHERE pp_2.pol_header_id = ph.policy_header_id
                           AND d.parent_id = pp_2.policy_id
                           AND acpt.payment_templ_id = pa2.payment_templ_id
                           AND ap.payment_id = d.child_id
                           AND Doc.get_doc_status_brief(ap.payment_id) = 'PAID'
                           AND dso.parent_doc_id = ap.payment_id
                           AND dso.child_doc_id = pa2.payment_id
                           AND pa2.REG_DATE BETWEEN p_start_date AND p_end_date)
                   AND ph.policy_header_id = pa.policy_header_id
                      
                      --and tcp.id = ppc.contact_policy_role_id
                      --and tcp.brief = '������������'
                   AND ch.ag_contract_header_id = pa.ag_contract_header_id
                   AND pa.status_id = pas.policy_agent_status_id
                   AND pa.ag_type_rate_value_id = ar.ag_type_rate_value_id
                      --and pp.payment_term_id = tpt.id
                      
                   AND pt.ID = pp.payment_term_id
                      -- ���� ������ ������ �� �7 �� ���� ������� �� ���� ���������, ����� ����� ���� ��
                   AND Pkg_Agent_1.get_agent_start_contr(ph.policy_header_id) BETWEEN
                       p_start_date AND p_end_date
                      /*and ph.start_date between p_start_date and
                      p_end_date*/ -- ���� ���������� �������� � �������� �������
                      
                   AND pkg_agent_sub.get_p_agent_status_by_date(p_ag_contract_header_id
                                                               ,ph.policy_header_id
                                                               ,p_end_date) IN ('CURRENT') -- ������ ������ �� �������� �����������
                      
                   AND pa.ag_contract_header_id = p_ag_contract_header_id -- ������� �� ����������� ������
                      
                   AND EXISTS (SELECT 1
                          FROM ven_p_policy_contact   ppc
                              ,ven_t_contact_pol_role tcp
                         WHERE tcp.ID = ppc.contact_policy_role_id
                           AND tcp.brief = '������������'
                           AND ppc.policy_id = pp.policy_id
                           AND ch.agent_id <> ppc.contact_id))
        --group by 0, policy_header_id
        
        ;
      SELECT SUM(TMP.k_sgp)
        INTO v_K_SGP
        FROM AG_STAT_DET_TMP TMP
       WHERE TMP.men_contract_header_id = 0
         AND TMP.ag_contract_header_id = p_ag_contract_header_id;
    
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20000
                               ,'������ ������� ��� ��� p_ag_contract_header_id: ' ||
                                p_ag_contract_header_id || ' ' || SQLERRM(SQLCODE));
        -- v_K_SGP := 0;
    END;
  
    p_K_SGP := v_K_SGP;
    p_K_SGP := NVL(v_K_SGP, 0);
  
  END;
  -- ������������ ����������� ��� �� ������ �������� ������ � ������������� ��� �������
  -- ���!!! ����� �� ���������� �� attest_agent_SGP. ������ �������������� � �������� �������
  -- ��������� ��� ��� ��� (��� ���)
  PROCEDURE attest_agent_SGP_new
  (
    p_ag_contract_header_id IN NUMBER
   ,p_start_date            DATE
   , -- ���� ������ ������������ �������
    p_end_date              DATE
   , -- ���� ����� ������������ �������
    p_K_SGP                 OUT NUMBER
  ) IS
  
    v_K_SGP        NUMBER := 0;
    v_Rate_Type_ID NUMBER;
  BEGIN
    -- ����������� ���� ����� �����
    SELECT rt.rate_type_id INTO v_Rate_Type_ID FROM RATE_TYPE rt WHERE rt.brief = '��';
  
    -- ������ ����������� K_SGP ������� ���� ������
    BEGIN
      IF NVL(glb_clear_flag_attest, '�') = '�'
      THEN
      
        DELETE FROM AG_STAT_DET_TMP;
      
      END IF;
      INSERT INTO AG_STAT_DET_TMP
      
        SELECT SQ_AG_STAT_DET_TMP.NEXTVAL AG_STAT_DET_TMP_ID
              ,0
              , -- ��� �������� ���������
               0
              ,p_ag_contract_header_id -- ��� �������� ������
              ,policy_id -- ��������� �������� �����������
              ,agent_rate * koef * ((koef_ccy * sum_prem) - sum_izd) * koef_prikaz -- ����� ������ ����� �������� � ������ �������������
          FROM (SELECT (CASE -- ����������� ���� ������ ��� ���������� ��������
                         WHEN (ar.brief = 'PERCENT') THEN
                          pa.part_agent / 100 -- �������
                         WHEN (ar.brief = 'ABSOL') THEN
                          pa.part_agent -- ���������� ��������
                         ELSE
                          pa.part_agent -- � ��������� ������ ���� ������, ��� ���������� ��������
                       END) agent_rate
                      ,(CASE
                         WHEN pt.brief = '�������������'
                              AND CEIL(MONTHS_BETWEEN(pp.end_date, pp.start_date)) > 12 THEN
                          0.1 -- ����� ����
                         WHEN (pt.brief = '�������������' AND
                              CEIL(MONTHS_BETWEEN(pp.end_date, pp.start_date)) <= 12)
                              OR pt.brief <> '�������������' THEN
                          1
                         ELSE
                          1
                       END) koef
                      ,
                       -- ���������� ������������  �� ������� �� 05,07,2007
                       (CASE
                         WHEN pt.brief = '�������������'
                              AND CEIL(MONTHS_BETWEEN(pp.end_date, pp.start_date)) > 12 THEN
                          2 -- �������������� ����� ����
                         WHEN (pt.brief = '�������������' AND
                              CEIL(MONTHS_BETWEEN(pp.end_date, pp.start_date)) <= 12) THEN
                          1 -- �������������� ����� ����
                         WHEN (pt.brief = 'EVERY_YEAR' AND
                              CEIL(MONTHS_BETWEEN(LAST_DAY(pp.end_date), LAST_DAY(ph.start_date))) > 12) THEN
                          1.5 -- ������� ����� ����
                         WHEN (pt.brief = 'EVERY_YEAR' AND
                              CEIL(MONTHS_BETWEEN(pp.end_date, pp.start_date)) <= 12) THEN
                          1 -- ������� ����� ����
                         WHEN (pt.number_of_payments = 2 AND
                              CEIL(MONTHS_BETWEEN(pp.end_date, pp.start_date)) > 12) THEN
                          1 -- ����������� ����� ����
                         WHEN (pt.number_of_payments = 2 AND
                              CEIL(MONTHS_BETWEEN(pp.end_date, pp.start_date)) <= 12) THEN
                          1 -- ����������� ����� ����
                         WHEN (pt.number_of_payments = 4 AND
                              CEIL(MONTHS_BETWEEN(pp.end_date, pp.start_date)) > 12) THEN
                          0.5 -- ����������� ����� ����
                         WHEN (pt.number_of_payments = 4 AND
                              CEIL(MONTHS_BETWEEN(pp.end_date, pp.start_date)) <= 12) THEN
                          0.5 -- ����������� ����� ����
                         ELSE
                          1
                       END) koef_prikaz
                      , -- ////-- ���������� ������������  �� ������� �� 05,07,2007
                       -- ����������� ������ ��������
                       Acc_New.Get_Rate_By_ID(v_Rate_Type_ID, ph.fund_id, pp.start_date) koef_ccy
                      ,
                       -- ����� ������ * �� ���������� ������ � ����
                       pt.number_of_payments *
                       (SELECT SUM(pc.fee)
                          FROM P_COVER  pc
                              ,AS_ASSET aa
                         WHERE aa.p_policy_id = pp.policy_id
                           AND aa.as_asset_id = pc.as_asset_id) sum_prem
                      ,
                       
                       --pt.number_of_payments * nvl(ap.amount, 0) sum_prem,
                       -- ����� �������� * �� ���������� ������ � ����
                       Pkg_Agent_1.find_sum_adm_izd(ph.policy_header_id) * pt.number_of_payments sum_izd
                      ,
                       -- ��������� �������� �����������
                       pp.policy_id policy_id
                  FROM ven_p_pol_header ph
                      ,ven_p_policy     pp
                      ,
                       
                       ven_p_policy_agent pa
                      ,
                       --ven_p_policy_contact    ppc,
                       -- ven_t_contact_pol_role  tcp,
                       ven_ag_contract_header  ch
                      ,ven_policy_agent_status pas
                      ,ven_ag_type_rate_value  ar
                      ,
                       -- t_payment_terms         tpt,
                       
                       ven_t_payment_terms pt -- ��������� �������� �����������
                
                 WHERE ph.policy_id = pp.policy_id
                   AND EXISTS (SELECT 1
                          FROM ven_doc_doc      d
                              ,ven_ac_payment   ap
                              ,DOC_SET_OFF      dso
                              ,ven_ac_payment   pa2
                              ,AC_PAYMENT_TEMPL acpt
                              ,
                               -- �������� ��� ������ ����������
                               -- ����� ����� ���� ���������� � �� � ������� ������
                               P_POLICY pp_2
                         WHERE pp_2.pol_header_id = ph.policy_header_id
                           AND d.parent_id = pp_2.policy_id
                           AND acpt.payment_templ_id = pa2.payment_templ_id
                           AND ap.payment_id = d.child_id
                           AND Doc.get_doc_status_brief(ap.payment_id) = 'PAID'
                           AND dso.parent_doc_id = ap.payment_id
                           AND dso.child_doc_id = pa2.payment_id
                        /*  AND pa2.reg_date BETWEEN p_start_date AND
                              p_end_date
                        */ -- ���� ������ ������ �� �7 �� ���� ������� �� ���� ���������, ����� ����� ���� ��
                        )
                   AND ph.policy_header_id = pa.policy_header_id
                      
                      --and ppc.policy_id = ph.policy_id
                      --and tcp.id = ppc.contact_policy_role_id
                      --and tcp.brief = '������������'
                   AND ch.ag_contract_header_id = pa.ag_contract_header_id
                   AND pa.status_id = pas.policy_agent_status_id
                   AND pa.ag_type_rate_value_id = ar.ag_type_rate_value_id
                      --and pp.payment_term_id = tpt.id
                      
                   AND pt.ID = pp.payment_term_id
                      /*and ph.start_date between p_start_date and
                      p_end_date*/ -- ���� ���������� �������� � �������� �������
                      -- ���� ������ ������ �� �7 �� ���� ������� �� ���� ���������, ����� ����� ���� ��
                      
                   AND Pkg_Agent_1.get_agent_start_contr(ph.policy_header_id) BETWEEN
                       p_start_date AND p_end_date
                   AND pas.brief IN ('CURRENT') -- ������ ������ �� �������� �����������
                      
                   AND pa.ag_contract_header_id = p_ag_contract_header_id -- ������� �� ����������� ������
                      
                   AND EXISTS
                 (SELECT 1
                          FROM ven_p_policy_contact   ppc
                              ,ven_t_contact_pol_role tcp
                         WHERE tcp.ID = ppc.contact_policy_role_id
                           AND tcp.brief = '������������'
                           AND ppc.policy_id = pp.policy_id
                           AND ch.agent_id <> ppc.contact_id)
                      --������ �������� 18.07.2008
                   AND ph.product_id NOT IN
                       (SELECT tpr.product_id FROM t_product tpr WHERE tpr.brief IN ('Family_Dep')));
      ----------------------------- 
      -- �������� ��������� ��������!!!!
      --AND NVL(pp.is_group_flag, 0) = 0);
    
      SELECT SUM(TMP.k_sgp)
        INTO v_K_SGP
        FROM AG_STAT_DET_TMP TMP
       WHERE TMP.men_contract_header_id = 0
         AND TMP.ag_contract_header_id = p_ag_contract_header_id;
    
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20001
                               ,'������ ������� ��� ��� p_ag_contract_header_id: ' ||
                                p_ag_contract_header_id || ' ' || SQLERRM(SQLCODE));
        --v_K_SGP := 0;
    END;
  
    p_K_SGP := v_K_SGP;
    p_K_SGP := NVL(v_K_SGP, 0);
  
  END;

  -- �������� �.�. 18.09.2008 ������� ��������� ��� �������� ��� �� ����
  PROCEDURE attest_agent_SGP_DAVR
  (
    p_ag_contract_header_id IN NUMBER
   ,p_start_date            DATE
   , -- ���� ������ ������������ �������
    p_end_date              DATE
   , -- ���� ����� ������������ �������
    p_K_SGP                 OUT NUMBER
  ) IS
  
    v_K_SGP        NUMBER := 0;
    v_Rate_Type_ID NUMBER;
  BEGIN
    -- ����������� ���� ����� �����
    SELECT rt.rate_type_id INTO v_Rate_Type_ID FROM RATE_TYPE rt WHERE rt.brief = '��';
  
    -- ������ ����������� K_SGP ������� ���� ������
    BEGIN
      IF NVL(glb_clear_flag_attest, '�') = '�'
      THEN
      
        DELETE FROM AG_STAT_DET_TMP;
      
      END IF;
      INSERT INTO AG_STAT_DET_TMP
      
        SELECT SQ_AG_STAT_DET_TMP.NEXTVAL AG_STAT_DET_TMP_ID
              ,0
              , -- ��� �������� ���������
               0
              ,p_ag_contract_header_id -- ��� �������� ������
              ,policy_id -- ��������� �������� �����������
              ,agent_rate * koef * ((koef_ccy * sum_prem) - sum_izd) -- *
        --               koef_prikaz -- ����� ������ ����� �������� � ������ �������������
          FROM (SELECT (CASE -- ����������� ���� ������ ��� ���������� ��������
                         WHEN (ar.brief = 'PERCENT') THEN
                          pa.part_agent / 100 -- �������
                         WHEN (ar.brief = 'ABSOL') THEN
                          pa.part_agent -- ���������� ��������
                         ELSE
                          pa.part_agent -- � ��������� ������ ���� ������, ��� ���������� ��������
                       END) agent_rate
                      ,(CASE
                         WHEN pt.brief = '�������������'
                              AND CEIL(MONTHS_BETWEEN(pp.end_date, pp.start_date)) > 12 THEN
                          0.1 -- ����� ����
                         WHEN (pt.brief = '�������������' AND
                              CEIL(MONTHS_BETWEEN(pp.end_date, pp.start_date)) <= 12)
                              OR pt.brief <> '�������������' THEN
                          1
                         ELSE
                          1
                       END) koef
                      ,
                       -- ���������� ������������  �� ������� �� 05,07,2007
                       (CASE
                         WHEN pt.brief = '�������������'
                              AND CEIL(MONTHS_BETWEEN(pp.end_date, pp.start_date)) > 12 THEN
                          2 -- �������������� ����� ����
                         WHEN (pt.brief = '�������������' AND
                              CEIL(MONTHS_BETWEEN(pp.end_date, pp.start_date)) <= 12) THEN
                          1 -- �������������� ����� ����
                         WHEN (pt.brief = 'EVERY_YEAR' AND
                              CEIL(MONTHS_BETWEEN(LAST_DAY(pp.end_date), LAST_DAY(ph.start_date))) > 12) THEN
                          1.5 -- ������� ����� ����
                         WHEN (pt.brief = 'EVERY_YEAR' AND
                              CEIL(MONTHS_BETWEEN(pp.end_date, pp.start_date)) <= 12) THEN
                          1 -- ������� ����� ����
                         WHEN (pt.number_of_payments = 2 AND
                              CEIL(MONTHS_BETWEEN(pp.end_date, pp.start_date)) > 12) THEN
                          1 -- ����������� ����� ����
                         WHEN (pt.number_of_payments = 2 AND
                              CEIL(MONTHS_BETWEEN(pp.end_date, pp.start_date)) <= 12) THEN
                          1 -- ����������� ����� ����
                         WHEN (pt.number_of_payments = 4 AND
                              CEIL(MONTHS_BETWEEN(pp.end_date, pp.start_date)) > 12) THEN
                          0.5 -- ����������� ����� ����
                         WHEN (pt.number_of_payments = 4 AND
                              CEIL(MONTHS_BETWEEN(pp.end_date, pp.start_date)) <= 12) THEN
                          0.5 -- ����������� ����� ����
                         ELSE
                          1
                       END) koef_prikaz
                      , -- ////-- ���������� ������������  �� ������� �� 05,07,2007
                       -- ����������� ������ ��������
                       Acc_New.Get_Rate_By_ID(v_Rate_Type_ID, ph.fund_id, pp.start_date) koef_ccy
                      ,
                       -- ����� ������ * �� ���������� ������ � ����
                       pt.number_of_payments *
                       (SELECT SUM(pc.fee)
                          FROM P_COVER  pc
                              ,AS_ASSET aa
                         WHERE aa.p_policy_id = pp.policy_id
                           AND aa.as_asset_id = pc.as_asset_id) sum_prem
                      ,
                       -- ����� �������� * �� ���������� ������ � ����
                       Pkg_Agent_1.find_sum_adm_izd(ph.policy_header_id) * pt.number_of_payments sum_izd
                      ,
                       -- ��������� �������� �����������
                       pp.policy_id policy_id
                  FROM ven_p_pol_header        ph
                      ,ven_p_policy            pp
                      ,ven_p_policy_agent      pa
                      ,ven_ag_contract_header  ch
                      ,ven_policy_agent_status pas
                      ,ven_ag_type_rate_value  ar
                      ,ven_t_payment_terms     pt -- ��������� �������� �����������
                 WHERE ph.policy_id = pp.policy_id
                   AND EXISTS
                 (SELECT 1
                          FROM ven_doc_doc      d
                              ,ven_ac_payment   ap
                              ,DOC_SET_OFF      dso
                              ,ven_ac_payment   pa2
                              ,AC_PAYMENT_TEMPL acpt
                              ,
                               -- �������� ��� ������ ����������
                               -- ����� ����� ���� ���������� � �� � ������� ������
                               P_POLICY pp_2
                         WHERE pp_2.pol_header_id = ph.policy_header_id
                           AND d.parent_id = pp_2.policy_id
                           AND acpt.payment_templ_id = pa2.payment_templ_id
                           AND ap.payment_id = d.child_id
                           AND Doc.get_doc_status_brief(ap.payment_id) = 'PAID'
                           AND dso.parent_doc_id = ap.payment_id
                           AND dso.child_doc_id = pa2.payment_id)
                   AND ph.policy_header_id = pa.policy_header_id
                   AND ch.ag_contract_header_id = pa.ag_contract_header_id
                   AND pa.status_id = pas.policy_agent_status_id
                   AND pa.ag_type_rate_value_id = ar.ag_type_rate_value_id
                   AND pt.ID = pp.payment_term_id
                      -- ������ ���� ����� ������ ��
                   AND pkg_renlife_utils.get_p_agent_sale(ph.policy_header_id) =
                       p_ag_contract_header_id
                      -- ��������� ����� ��� �� ���� ����� (���� ���������)
                   AND (Pkg_Agent_1.get_agent_start_contr(ph.policy_header_id) >= p_start_date OR
                       p_start_date IS NULL)
                      -- ��������� ����� ��� �� ���� ������
                   AND Pkg_Agent_1.get_agent_start_contr(ph.policy_header_id) <= p_end_date
                      -- ������� �� ����������� ������
                   AND pa.ag_contract_header_id = p_ag_contract_header_id
                   AND EXISTS
                 (SELECT 1
                          FROM ven_p_policy_contact   ppc
                              ,ven_t_contact_pol_role tcp
                         WHERE tcp.ID = ppc.contact_policy_role_id
                           AND tcp.brief = '������������'
                           AND ppc.policy_id = pp.policy_id
                           AND ch.agent_id <> ppc.contact_id)
                   AND ph.product_id NOT IN
                       (SELECT tpr.product_id FROM t_product tpr WHERE tpr.brief IN ('Family_Dep')));
      ----------------------------- 
      -- �������� ��������� ��������!!!!
      --AND NVL(pp.is_group_flag, 0) = 0);
    
      SELECT SUM(TMP.k_sgp)
        INTO v_K_SGP
        FROM AG_STAT_DET_TMP TMP
       WHERE TMP.men_contract_header_id = 0
         AND TMP.ag_contract_header_id = p_ag_contract_header_id;
    
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20001
                               ,'������ ������� ��� ��� p_ag_contract_header_id: ' ||
                                p_ag_contract_header_id || ' ' || SQLERRM(SQLCODE));
        --v_K_SGP := 0;
    END;
  
    p_K_SGP := v_K_SGP;
    p_K_SGP := NVL(v_K_SGP, 0);
  
  END;

  FUNCTION get_SGP_agent_DAVR
  (
    p_ag_contract_header_id IN NUMBER
   ,p_start_date            DATE
   , -- ���� ������ ������������ �������
    p_end_date              DATE -- ���� ����� ������������ �������
  ) RETURN NUMBER IS
    v_sgp NUMBER;
  BEGIN
    attest_agent_SGP_DAVR(p_ag_contract_header_id, p_start_date, p_end_date, v_sgp);
    RETURN v_sgp;
  END;

  FUNCTION get_SGP_agent_new
  (
    p_ag_contract_header_id IN NUMBER
   ,p_start_date            DATE
   , -- ���� ������ ������������ �������
    p_end_date              DATE -- ���� ����� ������������ �������
  ) RETURN NUMBER IS
    v_sgp NUMBER;
  BEGIN
    attest_agent_SGP_new(p_ag_contract_header_id, p_start_date, p_end_date, v_sgp);
    RETURN v_sgp;
  END;

  FUNCTION get_SGP_agent
  (
    p_ag_contract_header_id IN NUMBER
   ,p_start_date            DATE
   , -- ���� ������ ������������ �������
    p_end_date              DATE -- ���� ����� ������������ �������
  ) RETURN NUMBER IS
    v_sgp NUMBER;
  BEGIN
    attest_agent_SGP(p_ag_contract_header_id, p_start_date, p_end_date, v_sgp);
  
    -- dbms_output.put_line (p_ag_contract_header_id||'#'||v_sgp||'#'||to_char(p_start_date,'DD.MM.YYYY')||to_char(p_end_date,'DD.MM.YYYY'));
    RETURN v_sgp;
  END;

  ---------------------------------------------------------
  --*************************************************************
  -- ������������ ������������ �� ������ ��������  ��� ���������� �������
  PROCEDURE attest_agent_status_one
  (
    p_ag_contract_header_id IN NUMBER
   ,p_start_date            IN DATE
   , -- ���� ������ ������������ �������
    --                                   p_end_date              in date, -- ���� ����� ������������ �������
    p_K_SGP OUT NUMBER
   ,p_K_KD  OUT NUMBER
   ,p_K_KSP OUT NUMBER
  ) IS
  
    v_start_date DATE; -- ���� ������ ������������ �������
    v_end_date   DATE; -- ���� ����� ������������ �������
    v_K_SGP      NUMBER := 0;
    v_K_KD       NUMBER := 0;
    v_K_KSP      NUMBER := 0;
  
  BEGIN
  
    -- �������� �������� ��������� 6 ������� �������������� ���� ����������
    SELECT ADD_MONTHS(LAST_DAY(p_start_date) + 1, -7) INTO v_start_date FROM dual;
    SELECT ADD_MONTHS(LAST_DAY(p_start_date) + 1, -1) INTO v_end_date FROM dual;
  
    -- ������ ���������� K_SGP
    attest_agent_SGP(p_ag_contract_header_id, v_start_date, v_end_date, p_K_SGP);
  
    -- ������ ���������� K_KD
    BEGIN
      SELECT COUNT(*)
        INTO v_K_KD
        FROM P_POL_HEADER ph
        JOIN P_POLICY_AGENT pa
          ON (ph.policy_header_id = pa.policy_header_id)
        JOIN POLICY_AGENT_STATUS pas
          ON (pa.status_id = pas.policy_agent_status_id)
       WHERE ph.start_date BETWEEN v_start_date AND v_end_date
         AND pas.brief IN ('CURRENT')
         AND pa.ag_contract_header_id = p_ag_contract_header_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        v_K_KD := 0;
    END;
  
    p_K_KD := v_K_KD;
    -- ������ ���������� K_KSP
    BEGIN
      SELECT COUNT(*)
        INTO v_K_KSP
        FROM P_POL_HEADER ph
        JOIN P_POLICY pp
          ON (pp.pol_header_id = ph.policy_header_id -- ��������� ������ ��������
             AND pp.policy_id = ph.last_ver_id
             /*pp.version_num IN (SELECT MAX(p.version_num)
             FROM ins.P_POLICY p
                 ,ins.document d
                 ,ins.doc_status_ref rf
             WHERE p.pol_header_id = ph.policy_header_id
               AND p.policy_id = d.document_id
               AND d.doc_status_ref_id = rf.doc_status_ref_id
               AND rf.brief != 'CANCEL'
             )*/
             )
        JOIN P_POLICY_AGENT pa
          ON (ph.policy_header_id = pa.policy_header_id)
        JOIN POLICY_AGENT_STATUS pas
          ON (pa.status_id = pas.policy_agent_status_id)
       WHERE ph.start_date BETWEEN v_start_date AND v_end_date
         AND pas.brief IN ('CURRENT')
         AND Doc.get_doc_status_brief(pp.policy_id) IN ('BREAK') -- ����������
         AND pa.ag_contract_header_id = p_ag_contract_header_id;
    
      v_K_KSP := (1 - v_K_KSP / v_K_KD) * 100;
    
    EXCEPTION
      WHEN OTHERS THEN
        v_K_KSP := 100;
    END;
  
    p_K_KSP := v_K_KSP;
  END;
  --------------------------------------------------------------------------

  ---------------------------------------------------------
  --*************************************************************
  -- ������������ ����������� ��� �� ������ �������� ���������, ��������� ����(�������)
  -- � ������������� ��� �������
  PROCEDURE manag_SGP_bank
  (
    p_ag_contract_header_id IN NUMBER
   ,p_start_date            DATE
   , -- ���� ������ ������������ �������
    p_end_date              DATE
   , -- ���� ����� ������������ �������
    p_K_SGP                 OUT NUMBER
  ) IS
  
    CURSOR k_period(p_ag_contract_br IN NUMBER) IS
      SELECT ac.date_begin
            ,ac.contract_leader_id
            ,ac1.contract_id
        FROM ven_ag_contract_header ah
        JOIN ven_ag_contract ac
          ON (ac.contract_id = ah.ag_contract_header_id)
        JOIN ven_t_sales_channel chan
          ON (chan.ID = ah.t_sales_channel_id AND chan.brief IN ('BR', 'BANK')) -- ����� ������ "����", "������"
        JOIN ven_ag_contract ac1
          ON (ac.contract_leader_id = ac1.ag_contract_id)
       WHERE ac.contract_id = p_ag_contract_br -- ��������� ������� �������
         AND Doc.get_doc_status_brief(ac.ag_contract_id) <> STATUS_NEW -- �� ����� ������ ���������� ��������
       ORDER BY ac.date_begin;
  
    v_period           k_period%ROWTYPE;
    v_period_start_new DATE := SYSDATE;
    v_period_start_old DATE := SYSDATE;
    v_period_end_old   DATE := SYSDATE;
    v_leader_id        NUMBER := 0;
  
    v_prizn        NUMBER := 10;
    v_cat_brief    VARCHAR2(100);
    v_agency       NUMBER;
    v_K_SGP        NUMBER := 0;
    v_Rate_Type_ID NUMBER;
  BEGIN
    -- ����������� ���� ����� �����
    SELECT rt.rate_type_id INTO v_Rate_Type_ID FROM RATE_TYPE rt WHERE rt.brief = '��';
  
    -- ����������� ��������� � ��������� ������
    SELECT ah.agency_id
          ,ca.brief
      INTO v_agency
          ,v_cat_brief
      FROM ven_ag_contract_header ah
      JOIN ven_ag_contract ac
        ON (ac.ag_contract_id = ah.last_ver_id)
      JOIN ven_ag_category_agent ca
        ON (ca.ag_category_agent_id = ac.category_id)
     WHERE ah.ag_contract_header_id = p_ag_contract_header_id;
  
    -- ������ ����������� K_SGP ������� ���� ������
    BEGIN
    
      --    dbms_output.put_line('#000# 1 '||to_char(sysdate, 'DD.MM.YYYY HH24:MI:SS'));
      IF NVL(glb_clear_flag_attest, '�') = '�'
      THEN
      
        DELETE FROM AG_STAT_DET_TMP;
      
      END IF;
    
      -- ����. ������� ���
      FOR recrut IN ( -- ���������� ������ ���� ������, ��� � ����� �������� - ������ ������� (�� ����)
                     SELECT mn1.ag_contract_id AS ag_contract_id
                       FROM AG_CONTRACT mn1
                      WHERE mn1.contract_id = p_ag_contract_header_id
                        AND v_cat_brief IN ('MN', 'DR') -- ��� = �������� ��� ��������
                     UNION
                     -- ������ ����� �� ����������, ��� ��� = ��������
                     SELECT mn2.ag_contract_id AS ag_contract_id
                       FROM AG_CONTRACT_HEADER head1
                       JOIN AG_CONTRACT ver1
                         ON (ver1.ag_contract_id = head1.last_ver_id)
                       JOIN AG_CONTRACT mn2
                         ON (mn2.contract_id = head1.ag_contract_header_id)
                       JOIN AG_CATEGORY_AGENT cat
                         ON (cat.ag_category_agent_id = ver1.category_id)
                      WHERE head1.agency_id = v_agency -- ��������� ������������ ����, ��� ��� = ��������
                        AND cat.brief = 'MN' --  ������ ��������� ���������, ��� ��� = ��������
                        AND v_cat_brief = 'DR' -- ��� = ��������
                     
                     )
      LOOP
      
        INSERT INTO AG_STAT_DET_TMP
        
          SELECT SQ_AG_STAT_DET_TMP.NEXTVAL AG_STAT_DET_TMP_ID
                ,0
                ,p_ag_contract_header_id -- ��� �������� ���������
                ,ag_contract_header_id -- ��� �������� ������, ������������ ���������
                ,policy_id -- ��������� �������� �����������
                ,agent_rate * koef * koef_GR * ((koef_ccy * sum_prem) - sum_izd) -- ����� ������ ����� �������� � ������ �������������
            FROM (SELECT (CASE -- ����������� ���� ������ ��� ���������� ��������
                           WHEN (ar.brief = 'PERCENT') THEN
                            pa.part_agent / 100 -- �������
                           WHEN (ar.brief = 'ABSOL') THEN
                            pa.part_agent -- ���������� ��������
                           ELSE
                            pa.part_agent -- � ��������� ������ ���� ������, ��� ���������� ��������
                         END) agent_rate
                        ,(CASE -- ����������� ����� ��������
                           WHEN (MONTHS_BETWEEN(LAST_DAY(pp.end_date)
                                               ,LAST_DAY(Pkg_Agent_1.get_agent_start_contr(ph.policy_header_id))) > 12 AND
                                pt.number_of_payments = 1) THEN
                            0.1 -- ����� ����
                           WHEN (MONTHS_BETWEEN(LAST_DAY(pp.end_date)
                                               ,LAST_DAY(Pkg_Agent_1.get_agent_start_contr(ph.policy_header_id))) <= 12) THEN
                            1 -- ��� � �����
                           ELSE
                            1
                         END) koef
                        ,(CASE -- ����������� ���������� ��������
                           WHEN pp.is_group_flag = 1 THEN
                            0.5 -- ���� ������������ ������� ���������� ��������, �� =0.5
                           ELSE
                            1 -- ��� ���� ���������
                         END) koef_GR
                        ,
                         -- ����������� ������ ��������
                         Acc_New.Get_Rate_By_ID(v_Rate_Type_ID, ph.fund_id, pp.start_date) koef_ccy
                        ,
                         -- ����� ������ * �� ���������� ������ � ����
                         pt.number_of_payments *
                         (SELECT SUM(pc.fee)
                            FROM P_COVER  pc
                                ,AS_ASSET aa
                           WHERE aa.p_policy_id = pp.policy_id
                             AND aa.as_asset_id = pc.as_asset_id) sum_prem
                        ,
                         
                         --pt.number_of_payments * nvl(ap.amount, 0) sum_prem,
                         -- ����� ��������
                         Pkg_Agent_1.find_sum_adm_izd(ph.policy_header_id) sum_izd
                        ,
                         -- ��� �������� ������, ������������ ���������
                         ah.ag_contract_header_id
                        ,
                         -- ��� �������� �����������
                         pp.policy_id
                    FROM P_POL_HEADER   ph
                        ,P_POLICY       pp
                        ,P_POLICY_AGENT pa
                        ,
                         --ven_p_policy_contact ppc,
                         -- ven_t_contact_pol_role tcp,
                         ven_ag_contract_header ch
                        ,AG_CONTRACT_HEADER     ah
                        ,ven_t_sales_channel    chan
                        ,AG_CONTRACT            ac
                        ,POLICY_AGENT_STATUS    pas
                        ,AG_TYPE_RATE_VALUE     ar
                        ,T_PAYMENT_TERMS        pt
                  
                   WHERE ph.policy_id = pp.policy_id -- ������� ������ ��������
                     AND ph.policy_header_id = pa.policy_header_id -- a����� �� �������� �����������
                        --and ppc.policy_id = ph.policy_id
                        /*and tcp.id = ppc.contact_policy_role_id
                        and tcp.brief = '������������'*/
                     AND ch.ag_contract_header_id = pa.ag_contract_header_id
                     AND pa.ag_contract_header_id = ah.ag_contract_header_id -- ������� � �������
                     AND chan.ID = ah.t_sales_channel_id
                     AND chan.brief IN ('BR', 'BANK') -- ����� ������ "����", "������"
                     AND ah.last_ver_id = ac.ag_contract_id -- ������ �������� � �������
                     AND pa.status_id = pas.policy_agent_status_id -- ������� ������� �� �������� �����������
                     AND pa.ag_type_rate_value_id = ar.ag_type_rate_value_id -- ��� ���� ������ � ��������
                     AND pt.ID = pp.payment_term_id
                     AND pas.brief IN ('CURRENT')
                     AND EXISTS (SELECT 1
                            FROM ven_p_policy_contact   ppc
                                ,ven_t_contact_pol_role tcp
                           WHERE tcp.ID = ppc.contact_policy_role_id
                             AND tcp.brief = '������������'
                             AND ppc.policy_id = pp.policy_id
                             AND ch.agent_id <> ppc.contact_id)
                        --and ch.agent_id <> ppc.contact_id
                        -- ���� ������ ������ �� �7 �� ���� ������� �� ���� ���������, ����� ����� ���� ��
                     AND Pkg_Agent_1.get_agent_start_contr(ph.policy_header_id) BETWEEN
                         p_start_date AND p_end_date
                        --and doc.get_doc_status_brief(ap.payment_id) =
                        --    'PAID' -- ���� ������ ������ �� ���������
                     AND EXISTS (SELECT 1
                            FROM ven_doc_doc      d
                                ,ven_ac_payment   ap
                                ,DOC_SET_OFF      dso
                                ,ven_ac_payment   pa2
                                ,AC_PAYMENT_TEMPL acpt
                                ,
                                 -- �������� ��� ������ ����������
                                 -- ����� ����� ���� ���������� � �� � ������� ������
                                 P_POLICY pp_2
                           WHERE pp_2.pol_header_id = ph.policy_header_id
                             AND d.parent_id = pp_2.policy_id
                             AND acpt.payment_templ_id = pa2.payment_templ_id
                             AND ap.payment_id = d.child_id
                             AND Doc.get_doc_status_brief(ap.payment_id) = 'PAID'
                             AND dso.parent_doc_id = ap.payment_id
                             AND dso.child_doc_id = pa2.payment_id
                             AND pa2.REG_DATE BETWEEN p_start_date AND p_end_date)
                        --)
                        
                        -- ���������� ������ ���� ������, ��� � ����� �������� - ������ �������
                     AND ac.contract_recrut_id = recrut.ag_contract_id);
      END LOOP;
      /*from p_pol_header ph
        join p_policy pp on (ph.policy_id = pp.policy_id) -- ������� ������ ��������
       -- join ven_doc_doc d on (d.parent_id = pp.policy_id) -- ����� ���������� ��� ������� ������
       -- join ven_ac_payment ap on (ap.payment_id =
        --                          d.child_id) -- �������� ������ �� ��������� ����
        join p_policy_agent pa on (ph.policy_header_id =
                                  pa.policy_header_id) -- a����� �� �������� �����������
        join ven_p_policy_contact ppc on (ppc.policy_id =
                                         ph.policy_id)
        join ven_t_contact_pol_role tcp on (tcp.id =
                                           ppc.contact_policy_role_id and
                                           tcp.brief =
                                           '������������')
        join ven_ag_contract_header ch on (ch.ag_contract_header_id =
                                          pa.ag_contract_header_id)
        join ag_contract_header ah on (pa.ag_contract_header_id =
                                      ah.ag_contract_header_id) -- ������� � �������
        join ven_t_sales_channel chan on (chan.id =
                                         ah.t_sales_channel_id and
                                         chan.brief in
                                         ('BR', 'BANK')) -- ����� ������ "����", "������"
        join ag_contract ac on (ah.last_ver_id =
                               ac.ag_contract_id) -- ������ �������� � �������
        join policy_agent_status pas on (pa.status_id =
                                        pas.policy_agent_status_id) -- ������� ������� �� �������� �����������
        join ag_type_rate_value ar on (pa.ag_type_rate_value_id =
                                      ar.ag_type_rate_value_id) -- ��� ���� ������ � ��������
        left join t_payment_terms pt on (pt.id =
                                        pp.payment_term_id)
      
       --where ph.start_date between p_start_date and
          --   p_end_date
         where pas.brief in ('CURRENT')
         and ch.agent_id <> ppc.contact_id
         -- ���� ������ ������ �� �7 �� ���� ������� �� ���� ���������, ����� ����� ���� ��
          and pkg_agent_1.get_agent_start_contr(ph.policy_header_id) between p_start_date and
              p_end_date
         --and doc.get_doc_status_brief(ap.payment_id) =
         --    'PAID' -- ���� ������ ������ �� ���������
        and exists
        (select 1
                 from ven_doc_doc    d,
                      ven_ac_payment ap,
                      doc_set_off    dso,
                      ven_ac_payment pa2,
                      ac_payment_templ acpt
                where d.parent_id = pp.policy_id
                  and acpt.payment_templ_id = pa2.payment_templ_id
                  and ap.payment_id = d.child_id
                  and doc.get_doc_status_brief(ap.payment_id) =
                      'PAID'
                  and dso.parent_doc_id = ap.payment_id
                  and dso.child_doc_id = pa2.payment_id
                  and pa2.REG_DATE between p_start_date and
                      p_end_date
                    )
         and exists
       (select '1'
                from -- ���������� ������ ���� ������, ��� � ����� �������� - ������ ������� (�� ����)
                     (select mn1.ag_contract_id as ag_contract_id
                        from ag_contract mn1
                       where mn1.contract_id =
                             p_ag_contract_header_id
                         and v_cat_brief in ('MN', 'DR') -- ��� = �������� ��� ��������
                      union all
                      -- ������ ����� �� ����������, ��� ��� = ��������
                      select mn2.ag_contract_id as ag_contract_id
                        from ag_contract_header head1
                        join ag_contract ver1 on (ver1.ag_contract_id =
                                                 head1.last_ver_id)
                        join ag_contract mn2 on (mn2.contract_id =
                                                head1.ag_contract_header_id)
                        join ag_category_agent cat on (cat.ag_category_agent_id =
                                                      ver1.category_id)
                       where head1.agency_id = v_agency -- ��������� ������������ ����, ��� ��� = ��������
                         and cat.brief = 'MN' --  ������ ��������� ���������, ��� ��� = ��������
                         and v_cat_brief = 'DR' -- ��� = ��������
                      ) qqqq
               where ac.contract_recrut_id =
                     qqqq.ag_contract_id)
      
      )*/
      --dbms_output.put_line('#000# 2 '||to_char(sysdate, 'DD.MM.YYYY HH24:MI:SS'));
    
      -- ������ ����� �� ������� ��������, ������������ ���������
      FOR br IN (SELECT ag_contract_header_id
                   FROM AG_STAT_DET_TMP
                  WHERE men_contract_header_id = p_ag_contract_header_id)
      LOOP
        --- ������ ������� ������� , ����� ��������-�������� ������� ����������-���������
        OPEN k_period(br.ag_contract_header_id);
        LOOP
          FETCH k_period
            INTO v_period;
          EXIT WHEN k_period%NOTFOUND;
          -- dbms_output.put_line('#000# 333 '||to_char(sysdate, 'DD.MM.YYYY HH24:MI:SS'));
        
          IF v_period.contract_id <> v_leader_id
          THEN
            --- ��� ���?????? ��� ��� ����������� ����� ��������???
            -- ��������� ����� �������
            IF v_period_start_old = SYSDATE
            THEN
              -- ������ ����������� �����
              v_period_start_old := v_period.date_begin; -- �������������� ���������� ���� ����������� ������
            ELSE
              v_period_start_old := v_period_start_new; -- ���������� ���� ����������� ������
            END IF;
            v_period_start_new := v_period.date_begin;
            v_period_end_old   := v_period.date_begin; -- ��������� ����� ����������� ������
            -- �������� ������� ����� ����������� ������ �� �������������� ��������� �������
            IF v_leader_id = p_ag_contract_header_id
               AND (v_period_start_old <= p_start_date AND v_period_end_old >= p_end_date)
            THEN
              v_prizn := 50;
              EXIT;
            END IF;
          
            v_leader_id := v_period.contract_id; -- ��� �������� ������� �� �����
          END IF;
        END LOOP;
        IF v_prizn <> 50
        THEN
          v_period_end_old := v_period_end_old + 360 * 100; -- ���� ��������� ��� ���������� ������� - �����������
          -- �������� ���������� �������
          IF v_leader_id = p_ag_contract_header_id
             AND (v_period_start_old <= p_start_date AND v_period_end_old >= p_end_date)
          THEN
            v_prizn := 50;
          END IF;
        END IF;
        CLOSE k_period;
        --- ����� ������� ������� , ����� ��������-�������� ������� ����������-���������
        UPDATE AG_STAT_DET_TMP
           SET k_sgp = k_sgp * v_prizn / 100
         WHERE ag_contract_header_id = br.ag_contract_header_id;
        --dbms_output.put_line('#000# 33 '||to_char(sysdate, 'DD.MM.YYYY HH24:MI:SS'));
      
      END LOOP; -- ����� ����� �� ������� �������, ������������ ���������
      --dbms_output.put_line('#000# 4 '||to_char(sysdate, 'DD.MM.YYYY HH24:MI:SS'));
    
      SELECT SUM(TMP.k_sgp)
        INTO v_K_SGP
        FROM AG_STAT_DET_TMP TMP
       WHERE TMP.men_contract_header_id = p_ag_contract_header_id;
    
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20000
                               ,'������ ������� ���(����) ��� p_ag_contract_header_id: ' ||
                                p_ag_contract_header_id || ' ' || SQLERRM(SQLCODE));
      
      -- v_K_SGP := 0;
    END;
  
    p_K_SGP := v_K_SGP;
  
  END;

  ---------------------------------------------------------
  --*************************************************************
  -- ������������ ����������� ��� �� ������ �������� ��������� � ������������� ��� �������
  PROCEDURE attest_dr_SGP
  (
    p_ag_contract_header_id IN NUMBER
   ,p_start_date            DATE
   , -- ���� ������ ������������ �������
    p_end_date              DATE
   , -- ���� ����� ������������ �������
    p_K_SGP                 OUT NUMBER
  ) IS
  
    v_K_SGP        NUMBER := 0;
    v_Rate_Type_ID NUMBER;
    v_agency       NUMBER;
  BEGIN
    -- ����������� ���������
    SELECT ah.agency_id
      INTO v_agency
      FROM ven_ag_contract_header ah
     WHERE ah.ag_contract_header_id = p_ag_contract_header_id;
  
    -- ����������� ���� ����� �����
    SELECT rt.rate_type_id INTO v_Rate_Type_ID FROM RATE_TYPE rt WHERE rt.brief = '��';
  
    -- ������ ����������� K_SGP ������� ���� ������
    BEGIN
      IF NVL(glb_clear_flag_attest, '�') = '�'
      THEN
      
        DELETE FROM AG_STAT_DET_TMP;
      
      END IF;
      INSERT INTO AG_STAT_DET_TMP
        SELECT SQ_AG_STAT_DET_TMP.NEXTVAL AG_STAT_DET_TMP_ID
              ,0
              ,p_ag_contract_header_id -- ��� �������� ���������
              ,ag_contract_header_id -- ��� �������� ������, ������������ ���������
              ,policy_id -- ��������� �������� �����������
              ,agent_rate * koef * koef_GR * ((koef_ccy * sum_prem) - sum_izd /**koef_prikaz*/
               ) -- ����� ������ ����� �������� � ������ �������������
          FROM (SELECT (CASE -- ����������� ���� ������ ��� ���������� ��������
                         WHEN (ar.brief = 'PERCENT') THEN
                          pa.part_agent / 100 -- �������
                         WHEN (ar.brief = 'ABSOL') THEN
                          pa.part_agent -- ���������� ��������
                         ELSE
                          pa.part_agent -- � ��������� ������ ���� ������, ��� ���������� ��������
                       END) agent_rate
                      ,(CASE
                         WHEN (pt.brief = '�������������' AND
                              CEIL(MONTHS_BETWEEN(LAST_DAY(pp.end_date), LAST_DAY(ph.start_date))) > 12) THEN
                          0.1 -- ����� ����
                         WHEN (((pt.brief = '�������������') AND
                              CEIL(MONTHS_BETWEEN(LAST_DAY(pp.end_date), LAST_DAY(ph.start_date))) <= 12) OR
                              pt.brief <> '�������������') THEN
                          1
                         ELSE
                          1
                       END) koef
                      ,
                       -- ���������� ������������  �� ������� �� 05,07,2007
                       /*                 (case
                        when (lower(tpt.description) like '%����������%'
                              and ceil(months_between(last_day(pp.end_date),last_day(ph.start_date)))>12)
                              then 2     -- �������������� ����� ����
                        when (lower(tpt.description) like '%����������%'
                               and ceil(months_between(last_day(pp.end_date),last_day(ph.start_date)))<=12)
                              then 1     -- �������������� ����� ����
                        when (lower(tpt.description) like '%�������%'
                              and ceil(months_between(last_day(pp.end_date),last_day(ph.start_date)))>12)
                              then 1.5   -- ������� ����� ����
                        when (lower(tpt.description) like '%�������%'
                               and ceil(months_between(last_day(pp.end_date),last_day(ph.start_date)))<=12)
                              then 1     -- ������� ����� ����
                        when (tpt.number_of_payments = 2
                              and ceil(months_between(last_day(pp.end_date),last_day(ph.start_date)))>12)
                              then 1     -- ����������� ����� ����
                        when (tpt.number_of_payments = 2
                               and ceil(months_between(last_day(pp.end_date),last_day(ph.start_date)))<=12)
                              then 1     -- ����������� ����� ����
                        when (tpt.number_of_payments = 4
                              and ceil(months_between(last_day(pp.end_date),last_day(ph.start_date)))>12)
                              then 0.5   -- ����������� ����� ����
                        when (tpt.number_of_payments = 4
                               and ceil(months_between(last_day(pp.end_date),last_day(ph.start_date)))<=12)
                              then 0.5   -- ����������� ����� ����
                        else 1
                       end) koef_prikaz, -- ////-- ���������� ������������  �� ������� �� 05,07,2007
                       */(CASE -- ����������� ���������� ��������
                         WHEN pp.is_group_flag = 1 THEN
                          0.5 -- ���� ������������ ������� ���������� ��������, �� =0.5
                         ELSE
                          1 -- ��� ���� ���������
                       END) koef_GR
                      ,
                       -- ����������� ������ ��������
                       Acc_New.Get_Rate_By_ID(v_Rate_Type_ID, ph.fund_id, pp.start_date) koef_ccy
                      ,
                       -- ����� ������ * �� ���������� ������ � ����
                       -- ����� ������
                       pt.number_of_payments *
                       (SELECT SUM(pc.fee)
                          FROM P_COVER  pc
                              ,AS_ASSET aa
                         WHERE aa.p_policy_id = pp.policy_id
                           AND aa.as_asset_id = pc.as_asset_id) sum_prem
                      ,
                       
                       -- ����� ��������
                       Pkg_Agent_1.find_sum_adm_izd(ph.policy_header_id) * pt.number_of_payments sum_izd
                      ,
                       -- ��� �������� ������, ������������ ���������
                       ch.ag_contract_header_id
                      ,
                       -- ��� �������� �����������
                       pp.policy_id
                /*                           from ven_p_pol_header ph,
                                                ven_p_policy     pp,
                                                ven_p_policy_agent      pa,
                                                ven_p_policy_contact    ppc,
                                                ven_t_contact_pol_role  tcp,
                                                ven_ag_contract_header  ch,
                                                ven_policy_agent_status pas,
                                                ven_ag_type_rate_value  ar,
                                                t_payment_terms         tpt,
                                                ven_t_sales_channel chan,
                                                ven_t_payment_terms pt, -- ��������� �������� �����������
                                                ag_contract ac
                                          where ph.policy_id = pp.policy_id
                                            and exists
                                          (select 1
                                                   from ven_doc_doc    d,
                                                        ven_ac_payment ap,
                                                        doc_set_off    dso,
                                                        ven_ac_payment pa2,
                                                        ac_payment_templ acpt
                
                                                  where d.parent_id = pp.policy_id
                                                    and acpt.payment_templ_id = pa2.payment_templ_id
                                                    and ap.payment_id = d.child_id
                                                    and doc.get_doc_status_brief(ap.payment_id) =
                                                        'PAID'
                                                    and dso.parent_doc_id = ap.payment_id
                                                    and dso.child_doc_id = pa2.payment_id
                                                    and pa2.reg_date between p_start_date and
                                                        p_end_date
                
                                                      -- ���� ������ ������ �� �7 �� ���� ������� �� ���� ���������, ����� ����� ���� ��
                                                    )
                                            and ph.policy_header_id = pa.policy_header_id
                
                                            and ppc.policy_id = ph.policy_id
                                            and tcp.id = ppc.contact_policy_role_id
                                            and tcp.brief = '������������'
                \*                            and ch.ag_contract_header_id =
                                                pa.ag_contract_header_id*\
                                            and pa.status_id = pas.policy_agent_status_id
                                            and pa.ag_type_rate_value_id =
                                                ar.ag_type_rate_value_id
                                            and pp.payment_term_id = tpt.id
                
                                            and pt.id(+) = pp.payment_term_id
                                            \*and ph.start_date between p_start_date and
                                                p_end_date*\ -- ���� ���������� �������� � �������� �������
                                           -- ���� ������ ������ �� �7 �� ���� ������� �� ���� ���������, ����� ����� ���� ��
                
                                            and least(ph.start_date, (select min(pa2.reg_date)
                                                   from ven_doc_doc    d,
                                                        ven_ac_payment ap,
                                                        doc_set_off    dso,
                                                        ven_ac_payment pa2,
                                                        ac_payment_templ acpt
                                                  where d.parent_id = pp.policy_id
                                                    and acpt.payment_templ_id = pa2.payment_templ_id
                                                    and ap.payment_id = d.child_id
                                                    and doc.get_doc_status_brief(ap.payment_id) =
                                                        'PAID'
                                                    and dso.parent_doc_id = ap.payment_id
                                                    and dso.child_doc_id = pa2.payment_id
                                                    and acpt.brief = 'A7')) between p_start_date and
                                                p_end_date
                                            and pas.brief in ('CURRENT') -- ������ ������ �� �������� �����������
                                           and chan.id =  ah.t_sales_channel_id
                                           and chan.brief = 'MLM' -- ��������� ����� ������
                                            and pa.ag_contract_header_id =
                                                p_ag_contract_header_id -- ������� �� ����������� ������
                
                                            and ch.agent_id <> ppc.contact_id
                                            and ac.agency_id = v_agency
                                           and ah.ag_contract_header_id <>
                                               pa.ag_contract_header_id
                                           and ah.last_ver_id =
                                                                 ac.ag_contract_id);*/
                
                  FROM ven_p_pol_header ph
                  JOIN ven_p_policy pp
                    ON (ph.policy_id = pp.policy_id)
                  JOIN ven_p_policy_agent pa
                    ON (pa.policy_header_id = ph.policy_header_id)
                  JOIN ven_ag_contract_header ch
                    ON (pa.ag_contract_header_id = ch.ag_contract_header_id)
                  JOIN ven_t_sales_channel chan
                    ON (chan.ID = ch.t_sales_channel_id AND chan.brief = 'MLM') -- ��������� ����� ������
                  JOIN ven_policy_agent_status pas
                    ON (pa.status_id = pas.policy_agent_status_id)
                  JOIN ven_ag_type_rate_value ar
                    ON (pa.ag_type_rate_value_id = ar.ag_type_rate_value_id)
                  JOIN ven_t_payment_terms pt
                    ON (pt.ID = pp.payment_term_id)
                  JOIN (SELECT NVL(ap.real_pay_date, ap.due_date) dt
                             ,d.parent_id
                             ,pp_2.pol_header_id
                         FROM ven_doc_doc    d
                             ,ven_ac_payment ap
                             ,
                              --- ����� ����� ���� ���������� � �� � ������� ������
                              P_POLICY pp_2
                        WHERE d.parent_id = pp_2.policy_id
                          AND ap.payment_id = d.child_id
                          AND Doc.get_doc_status_brief(ap.payment_id) = 'PAID') pay
                    ON (pay.pol_header_id = ph.policy_header_id)
                 WHERE 1 = 1
                   AND Pkg_Agent_1.get_agent_start_contr(ph.policy_header_id) BETWEEN p_start_date AND
                       p_end_date
                      -- AND pay.dt  BETWEEN p_start_date AND  p_end_date       
                   AND pas.brief IN ('CURRENT')
                   AND EXISTS (SELECT '1'
                          FROM ven_p_policy_contact   ppc
                              ,ven_t_contact_pol_role tcp
                         WHERE tcp.ID = ppc.contact_policy_role_id
                           AND tcp.brief = '������������'
                           AND ppc.policy_id = pp.policy_id
                           AND ch.agent_id <> ppc.contact_id)
                      -- ���������� ����������� ������ ���������� �������� �� ��������� �� ���� ������
                   AND EXISTS
                 (SELECT '1'
                          FROM ven_ag_contract cc
                         WHERE cc.agency_id = v_agency
                           AND cc.contract_id <> p_ag_contract_header_id -- �� ��� ��������
                           AND cc.contract_id = ch.ag_contract_header_id
                              -- ���� ���������� �������� ������ ��� ����� ���� ������
                           AND cc.date_begin <= pay.dt
                              -- �� ���� ������ ������ �������� ���� �����������
                           AND Doc.get_doc_status_brief(cc.ag_contract_id, pay.dt) = 'CURRENT'
                           AND --��������� ������ �������� ��������� ����� ��� ������ �7 
                               (EXISTS
                                (SELECT '1'
                                   FROM ven_ag_contract cc_02
                                  WHERE cc.contract_id = cc_02.contract_id
                                    AND cc_02.num = cc.num + 1
                                    AND cc_02.date_begin > pay.dt) OR
                               -- ��� ��� ���� ������������ ������ ��������
                                cc.num = (SELECT MAX(num)
                                            FROM ven_ag_contract cc_02
                                           WHERE cc.contract_id = cc_02.contract_id))));
    
      /*              from p_pol_header ph
                      join p_policy pp on (ph.policy_id = pp.policy_id) -- ������� ������ ��������
                    -- join ven_doc_doc d on (d.parent_id = pp.policy_id) -- ����� ���������� ��� ������� ������
                    -- join ven_ac_payment ap on (ap.payment_id =
                    --                           d.child_id) -- �������� ������ �� ��������� ����
                      join p_policy_agent pa on (ph.policy_header_id =
                                                pa.policy_header_id) -- a����� �� �������� �����������
                      join ven_p_policy_contact ppc on (ppc.policy_id =
                                                       ph.policy_id)
                      join ven_t_contact_pol_role tcp on (tcp.id =
                                                         ppc.contact_policy_role_id and
                                                         tcp.brief =
                                                         '������������')
                      join ven_ag_contract_header ch on (ch.ag_contract_header_id =
                                                        pa.ag_contract_header_id)
                      join ag_contract_header ah on (pa.ag_contract_header_id =
                                                    ah.ag_contract_header_id) -- ������� � �������
                      join ven_t_sales_channel chan on (chan.id =
                                                       ah.t_sales_channel_id and
                                                       chan.brief = 'MLM') -- ��������� ����� ������
                      join ag_contract ac on (ah.last_ver_id = ac.ag_contract_id) -- ������ �������� � �������
                      join policy_agent_status pas on (pa.status_id =
                                                      pas.policy_agent_status_id) -- ������� ������� �� �������� �����������
                      join ag_type_rate_value ar on (pa.ag_type_rate_value_id =
                                                    ar.ag_type_rate_value_id) -- ��� ���� ������ � ��������
                      join t_payment_terms tpt on (pp.payment_term_id = tpt.id)
                      left join t_payment_terms pt on (pt.id = pp.payment_term_id)
      
                     where pkg_agent_1.get_agent_start_contr(ph.policy_header_id) between p_start_date and
                           p_end_date
                       and pas.brief in ('CURRENT')
                       and ch.agent_id <> ppc.contact_id
                          --and doc.get_doc_status_brief(ap.payment_id) =
                          --    'PAID' -- ���� ������ ������ �� ���������
                       and exists
                     (select 1
                              from ven_doc_doc      d,
                                   ven_ac_payment   ap,--,
                                --   doc_set_off      dso,
                                   --ven_ac_payment   pa2,
                                   --ac_payment_templ acpt,
                                              -- �������� ��� ������ ����������
                                              -- ����� ����� ���� ���������� � �� � ������� ������
                                              p_policy pp_2
                             where pp_2.pol_header_id = ph.policy_header_id
                               and d.parent_id = pp_2.policy_id
                               --and acpt.payment_templ_id = pa2.payment_templ_id
                               and ap.payment_id = d.child_id
                               and doc.get_doc_status_brief(ap.payment_id) = 'PAID'
                              -- and dso.parent_doc_id = ap.payment_id
                               --and dso.child_doc_id = pa2.payment_id
                              -- and pa2.REG_DATE between p_start_date and p_end_date
                               )
                       and ac.agency_id = v_agency
                       and ah.ag_contract_header_id <> p_ag_contract_header_id);
      */
      SELECT SUM(TMP.k_sgp)
        INTO v_K_SGP
        FROM AG_STAT_DET_TMP TMP
       WHERE TMP.men_contract_header_id = p_ag_contract_header_id;
    
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20000
                               ,'������ ������� ��� (��������) ��� p_ag_contract_header_id: ' ||
                                p_ag_contract_header_id || ' ' || SQLERRM(SQLCODE));
      
      --v_K_SGP := 0;
    END;
  
    p_K_SGP := NVL(v_K_SGP, 0);
  
  END;

  ---------------------------------------------------------
  --*************************************************************
  -- ������������ ����������� ��� �� ������ �������� ��������� � ������������� ��� �������
  PROCEDURE attest_manag_SGP
  (
    p_ag_contract_header_id IN NUMBER
   ,p_start_date            DATE
   , -- ���� ������ ������������ �������
    p_end_date              DATE
   , -- ���� ����� ������������ �������
    p_K_SGP                 OUT NUMBER
  ) IS
  
    v_K_SGP                NUMBER := 0;
    v_Rate_Type_ID         NUMBER;
    type_strahov           NUMBER;
    type_PAID              NUMBER;
    type_adm_iz            NUMBER;
    v_POL_AG_STATUS        NUMBER;
    c_count                NUMBER;
    t_sales_channel_id     NUMBER;
    v_ag_type_rate_percent NUMBER;
    v_ag_type_rate_ABSOL   NUMBER;
    -- t_pay_terms_edin number;
  BEGIN
    Pkg_Ins_Log.SP_EventInfo(1, 'PKG_AGENT_1', 'attest_manag_SGP');
    -- ����������� ���� ����� �����
    SELECT rt.rate_type_id INTO v_Rate_Type_ID FROM RATE_TYPE rt WHERE rt.brief = '��';
    Pkg_Ins_Log.SP_EventInfo(2, 'PKG_AGENT_1', 'attest_manag_SGP');
    -- ������ ����������� K_SGP ������� ���� ������
    BEGIN
      IF NVL(glb_clear_flag_attest, '�') = '�'
      THEN
      
        DELETE FROM AG_STAT_DET_TMP;
      
      END IF;
      Pkg_Ins_Log.SP_EventInfo(3
                              ,'PKG_AGENT_1'
                              ,'attest_manag_SGP:p_ag_contract_header_id=' || p_ag_contract_header_id ||
                               ', p_start_date= ' || p_start_date || ', p_end_date= ' || p_end_date);
    
      SELECT tcp.ID
        INTO type_strahov
        FROM T_CONTACT_POL_ROLE tcp
       WHERE tcp.brief = '������������';
    
      SELECT d.DOC_STATUS_REF_ID INTO type_PAID FROM DOC_STATUS_REF d WHERE d.BRIEF = 'PAID';
    
      SELECT pas.POLICY_AGENT_STATUS_ID
        INTO v_POL_AG_STATUS
        FROM POLICY_AGENT_STATUS pas
       WHERE pas.BRIEF = 'CURRENT';
    
      SELECT chan.ID INTO t_sales_channel_id FROM T_SALES_CHANNEL chan WHERE chan.brief = 'MLM';
    
      -- select t.ID into t_pay_terms_edin from  t_payment_terms t where t.brief = '�������������';
    
      SELECT a.AG_TYPE_RATE_VALUE_ID
        INTO v_ag_type_rate_percent
        FROM AG_TYPE_RATE_VALUE a
       WHERE a.BRIEF = 'PERCENT';
      SELECT a.AG_TYPE_RATE_VALUE_ID
        INTO v_ag_type_rate_ABSOL
        FROM AG_TYPE_RATE_VALUE a
       WHERE a.BRIEF = 'ABSOL';
    
      Pkg_Ins_Log.SP_EventInfo(32, 'PKG_AGENT_1', 'attest_manag_SGP:c_count=' || c_count);
    
      INSERT INTO AG_STAT_DET_TMP
      
        SELECT SQ_AG_STAT_DET_TMP.NEXTVAL AG_STAT_DET_TMP_ID
              ,0
              ,p_ag_contract_header_id -- ��� �������� ���������
              ,AGENT -- ��� �������� ������, ������������ ���������
              ,policy_id -- ��������� �������� �����������
              ,agent_rate * koef * koef_GR * ((koef_ccy * sum_prem) - sum_izd /** koef_prikaz*/
               ) -- ����� ������ ����� �������� � ������ �������������
          FROM (SELECT (CASE -- ����������� ���� ������ ��� ���������� ��������
                         WHEN (ph.AG_TYPE_RATE_VALUE_ID = v_ag_type_rate_percent) THEN
                          ph.part_agent / 100 -- �������
                         WHEN (ph.AG_TYPE_RATE_VALUE_ID = v_ag_type_rate_ABSOL) THEN
                          ph.part_agent -- ���������� ��������
                         ELSE
                          ph.part_agent -- � ��������� ������ ���� ������, ��� ���������� ��������
                       END) agent_rate
                      ,(CASE
                         WHEN (ph.payment_term_BRIEF = '�������������' AND
                              CEIL(MONTHS_BETWEEN(LAST_DAY(ph.policy_end_date), LAST_DAY(ph.pd))) > 12) THEN
                          0.1 -- ����� ����
                         WHEN (((ph.payment_term_BRIEF = '�������������') AND
                              CEIL(MONTHS_BETWEEN(LAST_DAY(ph.policy_end_date), LAST_DAY(ph.pd))) <= 12) OR
                              ph.payment_term_BRIEF <> '�������������') THEN
                          1
                         ELSE
                          1
                       END) koef
                      ,(CASE -- ����������� ���������� ��������
                         WHEN ph.is_group_flag = 1 THEN
                          0.5 -- ���� ������������ ������� ���������� ��������, �� =0.5
                         ELSE
                          1 -- ��� ���� ���������
                       END) koef_GR
                      ,
                       -- ����������� ������ ��������
                       ph.rate_by_date koef_ccy
                      ,
                       -- ����� ������ * �� ���������� ������ � ����
                       pt.number_of_payments *
                       (SELECT SUM(pc.fee)
                          FROM P_COVER  pc
                              ,AS_ASSET aa
                         WHERE aa.p_policy_id = ph.policy_id
                           AND aa.as_asset_id = pc.as_asset_id) sum_prem
                      ,
                       -- ����� ��������
                       Pkg_Agent_1.find_sum_adm_izd_opt(ph.policy_id) * pt.number_of_payments sum_izd
                      ,
                       -- ��� �������� ������, ������������ ���������
                       ph.agent
                      ,
                       -- ��� �������� �����������
                       ph.policy_id
                  FROM TCAL_PPOL_HEADER ph
                  JOIN T_PAYMENT_TERMS pt
                    ON (pt.ID = ph.POLICY_PAYMENT_TERM_ID)
                /*  JOIN (SELECT NVL(ap.real_pay_date,ap.due_date) dt,  d.parent_id, pp_2.pol_header_id
                FROM DOC_DOC    d,
                     AC_PAYMENT ap,
                     --- ����� ����� ���� ���������� � �� � ������� ������
                     P_POLICY pp_2
                WHERE d.parent_id = pp_2.policy_id
                AND ap.payment_id = d.child_id
                AND doc.get_doc_status_id(ap.payment_id)  = type_paid
                )pay ON (pay.pol_header_id = ph.policy_header_id)*/
                 WHERE 1 = 1
                   AND ph.manager = p_ag_contract_header_id
                   AND ph.manager != ph.agent
                   AND t_sales_channel_id = ph.agent_cont_sales_id
                   AND ph.pd BETWEEN p_start_date AND p_end_date
                      --   AND pay.dt  BETWEEN p_start_date AND  p_end_date       
                   AND EXISTS (SELECT 1
                          FROM P_POLICY_CONTACT ppc
                         WHERE type_strahov = ppc.contact_policy_role_id
                           AND ppc.policy_id = ph.policy_id
                           AND ph.agent <> ppc.contact_id));
    
      Pkg_Ins_Log.SP_EventInfo(5, 'PKG_AGENT_1', 'attest_manag_SGP');
      SELECT SUM(TMP.k_sgp)
        INTO v_K_SGP
        FROM AG_STAT_DET_TMP TMP
       WHERE TMP.men_contract_header_id = p_ag_contract_header_id;
      Pkg_Ins_Log.SP_EventInfo(6, 'PKG_AGENT_1', 'attest_manag_SGP');
    
      /*
          exception
            when others then
              raise_application_error(-20000, '������ ������� ���(��������) ��� p_ag_contract_header_id: '||p_ag_contract_header_id||' '||sqlerrm(sqlcode));
      */
      --v_K_SGP := 0;
    END;
  
    p_K_SGP := NVL(v_K_SGP, 0);
  
  END;

  --------------------------------------------------------------------------
  --**********************************************************************
  -- ������������ ������������ �� ������ �������� ��� ���������� ����������
  PROCEDURE attest_manag_status_one
  (
    p_ag_contract_header_id IN NUMBER
   ,p_start_date            IN DATE
   , -- ���� ������ ������������ �������
    --                                   p_end_date              in date, -- ���� ����� ������������ �������
    p_K_SGP OUT NUMBER
   ,
    /*  p_K_KD out number,*/p_K_KSP OUT NUMBER
  ) IS
    v_start_date   DATE; -- ���� ������ ������������ �������
    v_end_date     DATE; -- ���� ����� ������������ �������
    v_Rate_Type_ID NUMBER;
    v_K_SGP        NUMBER := 0;
    v_K_KD         NUMBER := 0;
    v_K_KSP        NUMBER := 0;
  
  BEGIN
    -- �������� �������� ��������� 6 ������� �������������� ���� ����������
    SELECT ADD_MONTHS(LAST_DAY(p_start_date) + 1, -7) INTO v_start_date FROM dual;
    SELECT ADD_MONTHS(LAST_DAY(p_start_date) + 1, -1) INTO v_end_date FROM dual;
  
    -- ������ ����������� K_SGP ������� ���� ������
    attest_manag_SGP(p_ag_contract_header_id
                    ,v_start_date
                    , -- ���� ������ ������������ �������
                     v_end_date
                    , -- ���� ����� ������������ �������
                     p_K_SGP);
    -- ������ ���������� K_KD
    BEGIN
      SELECT NVL(COUNT(*), 0)
        INTO v_K_KD
        FROM P_POL_HEADER ph
        JOIN P_POLICY_AGENT pa
          ON (ph.policy_header_id = pa.policy_header_id)
        JOIN AG_CONTRACT_HEADER ah
          ON (pa.ag_contract_header_id = ah.ag_contract_header_id) -- ������� � �������
        JOIN AG_CONTRACT ac
          ON (ah.last_ver_id = ac.ag_contract_id) -- ������ �������� � �������
        JOIN POLICY_AGENT_STATUS pas
          ON (pa.status_id = pas.policy_agent_status_id)
       WHERE ph.start_date BETWEEN v_start_date AND v_end_date
         AND pas.brief IN ('CURRENT')
         AND ac.contract_leader_id IN
             (SELECT agl.ag_contract_id
                FROM AG_CONTRACT agl
               WHERE agl.contract_id = p_ag_contract_header_id);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        v_K_KD := 0;
    END;
  
    /*  p_K_KD := v_K_KD;*/
  
    -- ������ ���������� K_KSP
    BEGIN
      SELECT NVL(COUNT(*), 0)
        INTO v_K_KSP
        FROM P_POL_HEADER ph
        JOIN P_POLICY pp
          ON (pp.pol_header_id = ph.policy_header_id -- ��������� ������ ��������
             AND pp.policy_id = ph.last_ver_id
             /*pp.version_num IN (SELECT MAX(p.version_num)
             FROM ins.P_POLICY p
                 ,ins.document d
                 ,ins.doc_status_ref rf
             WHERE p.pol_header_id = ph.policy_header_id
               AND p.policy_id = d.document_id
               AND d.doc_status_ref_id = rf.doc_status_ref_id
               AND rf.brief != 'CANCEL'
             )*/
             )
        JOIN P_POLICY_AGENT pa
          ON (ph.policy_header_id = pa.policy_header_id)
        JOIN AG_CONTRACT_HEADER ah
          ON (pa.ag_contract_header_id = ah.ag_contract_header_id) -- ������� � �������
        JOIN AG_CONTRACT ac
          ON (ah.last_ver_id = ac.ag_contract_id) -- ������ �������� � �������
        JOIN POLICY_AGENT_STATUS pas
          ON (pa.status_id = pas.policy_agent_status_id)
       WHERE ph.start_date BETWEEN v_start_date AND v_end_date
         AND pas.brief IN ('CURRENT')
         AND Doc.get_doc_status_brief(pp.policy_id) IN ('BREAK') -- ����������
         AND ac.contract_leader_id IN
             (SELECT agl.ag_contract_id
                FROM AG_CONTRACT agl
               WHERE agl.contract_id = p_ag_contract_header_id)
      
      ;
    
      v_K_KSP := (1 - v_K_KSP / v_K_KD) * 100;
    
    EXCEPTION
      WHEN OTHERS THEN
        v_K_KSP := 100;
    END;
  
    p_K_KSP := v_K_KSP;
  
  END;

  PROCEDURE KSP_MN
  (
    p_ag_contract_header_id IN NUMBER
   ,p_db                    IN DATE
   ,p_de                    IN DATE
   ,p_ksp                   OUT NUMBER
  ) IS
    -- ������ ���������� K_KD
    v_K_KD  NUMBER;
    v_K_KSP NUMBER;
  BEGIN
    BEGIN
      SELECT NVL(COUNT(DISTINCT ph.policy_header_id), 0)
        INTO v_K_KD
        FROM P_POL_HEADER ph
        JOIN P_POLICY_AGENT pa
          ON (ph.policy_header_id = pa.policy_header_id)
        JOIN AG_CONTRACT_HEADER ah
          ON (pa.ag_contract_header_id = ah.ag_contract_header_id) -- ������� � �������
        JOIN AG_CONTRACT ac
          ON (ah.last_ver_id = ac.ag_contract_id) -- ������ �������� � �������
        JOIN POLICY_AGENT_STATUS pas
          ON (pa.status_id = pas.policy_agent_status_id)
       WHERE ph.start_date BETWEEN p_db AND p_de
         AND pas.brief IN ('CURRENT', 'CANCEL')
         AND ac.contract_leader_id IN
             (SELECT agl.ag_contract_id
                FROM AG_CONTRACT agl
               WHERE agl.contract_id = p_ag_contract_header_id);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        v_K_KD := 0;
    END;
  
    -- ������ ���������� K_KSP
    BEGIN
      SELECT NVL(COUNT(DISTINCT ph.policy_header_id), 0)
        INTO v_K_KSP
        FROM P_POL_HEADER ph
        JOIN P_POLICY pp
          ON (pp.pol_header_id = ph.policy_header_id -- ��������� ������ ��������
             AND pp.policy_id = ph.last_ver_id
             /*pp.version_num IN (SELECT MAX(p.version_num)
             FROM ins.P_POLICY p
                 ,ins.document d
                 ,ins.doc_status_ref rf
             WHERE p.pol_header_id = ph.policy_header_id
               AND p.policy_id = d.document_id
               AND d.doc_status_ref_id = rf.doc_status_ref_id
               AND rf.brief != 'CANCEL')*/
             )
        JOIN P_POLICY_AGENT pa
          ON (ph.policy_header_id = pa.policy_header_id)
        JOIN AG_CONTRACT_HEADER ah
          ON (pa.ag_contract_header_id = ah.ag_contract_header_id) -- ������� � �������
        JOIN AG_CONTRACT ac
          ON (ah.last_ver_id = ac.ag_contract_id) -- ������ �������� � �������
        JOIN POLICY_AGENT_STATUS pas
          ON (pa.status_id = pas.policy_agent_status_id)
       WHERE ph.start_date BETWEEN p_db AND p_de
         AND pas.brief IN ('CURRENT', 'CANCEL')
         AND Doc.get_doc_status_brief(pp.policy_id) IN ('BREAK') -- ����������
         AND ac.contract_leader_id IN
             (SELECT agl.ag_contract_id
                FROM AG_CONTRACT agl
               WHERE agl.contract_id = p_ag_contract_header_id)
      
      ;
    
      v_K_KSP := (1 - v_K_KSP / v_K_KD) * 100;
    
    EXCEPTION
      WHEN OTHERS THEN
        v_K_KSP := 100;
    END;
  
    p_ksp := v_K_KSP;
  END;
  --***********************************************************
  --// ������ ��� ��� ���������
  PROCEDURE KSP_DR
  (
    p_ag_contract_header_id IN NUMBER
   ,p_db                    IN DATE
   ,p_de                    IN DATE
   ,p_ksp                   OUT NUMBER
  ) IS
    -- ������ ���������� K_KD
    v_K_KD   NUMBER;
    v_K_KSP  NUMBER;
    v_agency NUMBER;
  BEGIN
    -- ����������� ��������� � ��������� ������
    SELECT ah.agency_id
      INTO v_agency
      FROM ven_ag_contract_header ah
     WHERE ah.ag_contract_header_id = p_ag_contract_header_id;
  
    -- ���������� ���������
    BEGIN
      SELECT NVL(COUNT(DISTINCT ph.policy_header_id), 0)
        INTO v_K_KD
        FROM P_POL_HEADER ph
        JOIN P_POLICY_AGENT pa
          ON (ph.policy_header_id = pa.policy_header_id)
        JOIN AG_CONTRACT_HEADER ah
          ON (pa.ag_contract_header_id = ah.ag_contract_header_id) -- ������� � �������
        JOIN AG_CONTRACT ac
          ON (ah.last_ver_id = ac.ag_contract_id) -- ������ �������� � �������
        JOIN POLICY_AGENT_STATUS pas
          ON (pa.status_id = pas.policy_agent_status_id)
        JOIN ven_t_sales_channel chan
          ON (chan.ID = ah.t_sales_channel_id AND chan.brief = 'MLM') -- ����� ������ ���������
       WHERE ph.start_date BETWEEN p_db AND p_de
         AND pas.brief IN ('CURRENT', 'CANCEL')
         AND ac.agency_id = v_agency
         AND ah.ag_contract_header_id <> p_ag_contract_header_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        v_K_KD := 0;
    END;
  
    -- ������ ���������� K_KSP
    BEGIN
      SELECT NVL(COUNT(DISTINCT ph.policy_header_id), 0)
        INTO v_K_KSP
        FROM P_POL_HEADER ph
        JOIN P_POLICY pp
          ON (pp.pol_header_id = ph.policy_header_id -- ��������� ������ ��������
             AND pp.policy_id = ph.last_ver_id
             /*pp.version_num IN (SELECT MAX(p.version_num)
             FROM ins.P_POLICY p
                 ,ins.document d
                 ,ins.doc_status_ref rf
             WHERE p.pol_header_id = ph.policy_header_id
               AND p.policy_id = d.document_id
               AND d.doc_status_ref_id = rf.doc_status_ref_id
               AND rf.brief != 'CANCEL')*/
             )
        JOIN P_POLICY_AGENT pa
          ON (ph.policy_header_id = pa.policy_header_id)
        JOIN AG_CONTRACT_HEADER ah
          ON (pa.ag_contract_header_id = ah.ag_contract_header_id) -- ������� � �������
        JOIN AG_CONTRACT ac
          ON (ah.last_ver_id = ac.ag_contract_id) -- ������ �������� � �������
        JOIN POLICY_AGENT_STATUS pas
          ON (pa.status_id = pas.policy_agent_status_id)
        JOIN ven_t_sales_channel chan
          ON (chan.ID = ah.t_sales_channel_id AND chan.brief = 'MLM') -- ����� ������ ���������
       WHERE ph.start_date BETWEEN p_db AND p_de
         AND pas.brief IN ('CURRENT', 'CANCEL')
         AND Doc.get_doc_status_brief(pp.policy_id) IN ('BREAK') -- ����������
         AND ac.agency_id = v_agency
         AND ah.ag_contract_header_id <> p_ag_contract_header_id;
    
      v_K_KSP := (1 - v_K_KSP / v_K_KD) * 100;
    
    EXCEPTION
      WHEN OTHERS THEN
        v_K_KSP := 100;
    END;
  
    p_ksp := v_K_KSP;
  END;

  --***********************************************************
  -- ������������ ������ �� ������ ���������� �������� ��� ����������
  -- �������� ���������� �����
  PROCEDURE attest_status_new
  (
    p_ag_contract_header_id IN NUMBER
   ,p_start_date            IN DATE DEFAULT SYSDATE
   ,p_K_SGP                 IN NUMBER
   ,p_K_KD                  IN NUMBER
   ,p_K_KSP                 IN NUMBER
   ,p_categor_id            IN NUMBER
   ,p_status_id             IN OUT NUMBER -- ���������� �������� = ����������� �������
  ) IS
    v_rez       NUMBER := 0; -- 1-���� ��������; 0- ���� �� ��������
    v_rez_agent NUMBER := 0; -- 0-������ ����������; 1- �� ��������� ������; 2- �� �������� ������
    v_ag_stat   ven_ag_stat_agent%ROWTYPE;
  
    v_dog_date  DATE;
    v_koef_date NUMBER := 0;
  
    v_K_SGP NUMBER;
    v_K_KD  NUMBER;
    v_K_KSP NUMBER;
  
    CURSOR k_plan IS
      SELECT sa.ag_stat_agent_id
            ,sa.k_kd
            ,sa.k_ksp
            ,sa.k_sgp
        FROM ven_ag_stat_agent sa
       WHERE sa.ag_category_agent_id = p_categor_id
         AND sa.brief <> '�������'
       ORDER BY sa.ag_stat_agent_id;
  BEGIN
    -- ����������� �������� ������������� �������� ������ ��� ������� ������
    BEGIN
      SELECT 1
        INTO v_rez_agent
        FROM dual
       WHERE EXISTS -- ���� �� ���������� ��������, � ��������� �������������� �� ���������� ��������.
       (SELECT '1'
                FROM ven_ag_stat_agent sa
                    ,ven_ag_stat_hist  sh
               WHERE sa.brief IN ('�������', '������', '��������')
                 AND sa.ag_stat_agent_id = sh.ag_stat_agent_id
                 AND sh.ag_contract_header_id = p_ag_contract_header_id
                 AND sh.ag_category_agent_id = p_categor_id
                 AND sh.stat_date BETWEEN ADD_MONTHS(LAST_DAY(p_start_date) + 1, -7) AND p_start_date
                 AND sh.ag_stat_agent_id = p_status_id) -- ������ ������������� ���������� ������������               
          OR (EXISTS -- ���� � ������� 6 ������� �� ���� ��������� � '��������' �� '�������'
              (SELECT '1'
                 FROM ven_ag_stat_agent sa
                     ,ven_ag_stat_hist  sh
                WHERE sa.brief IN ('��������')
                  AND sa.ag_stat_agent_id = sh.ag_stat_agent_id
                  AND sh.ag_contract_header_id = p_ag_contract_header_id
                  AND sh.ag_category_agent_id = p_categor_id
                  AND sh.stat_date BETWEEN ADD_MONTHS(LAST_DAY(p_start_date) + 1, -7) AND p_start_date
                  AND NOT EXISTS (SELECT '1' -- ���� ��������� ������� �����, ��� ���� ���������� '��������'
                         FROM ven_ag_stat_agent sa1
                             ,ven_ag_stat_hist  sh1
                        WHERE sa1.brief IN ('�������')
                          AND sa1.ag_stat_agent_id = sh1.ag_stat_agent_id
                          AND sh1.ag_contract_header_id = p_ag_contract_header_id
                          AND sh1.stat_date > sh.stat_date
                          AND sh1.stat_date <= p_start_date)));
    EXCEPTION
      WHEN OTHERS THEN
        v_rez_agent := v_rez_agent; -- ������ ����� ������
    END;
  
    BEGIN
      SELECT 2
        INTO v_rez_agent
        FROM dual
       WHERE (EXISTS --3.5 ���� �� ��������� ������
              (SELECT '1'
                 FROM ven_ag_stat_agent sa
                     ,ven_ag_stat_hist  sh
                WHERE sa.brief IN ('������')
                  AND sa.ag_stat_agent_id = p_status_id
                  AND sh.ag_contract_header_id = p_ag_contract_header_id
                  AND sh.ag_category_agent_id = p_categor_id
                  AND sa.ag_stat_agent_id = sh.ag_stat_agent_id
                  AND sh.stat_date <= ADD_MONTHS(LAST_DAY(p_start_date) + 1, - (3.5 * 12 + 1))
                  AND NOT EXISTS (SELECT '1' -- �� ���������� ������ � ������ �������� � ����� ����� 
                         FROM ven_ag_stat_agent sa1
                             ,ven_ag_stat_hist  sh1
                        WHERE sa1.ag_stat_agent_id = sh1.ag_stat_agent_id
                          AND sh1.ag_contract_header_id = p_ag_contract_header_id
                          AND sh1.stat_date > sh.stat_date
                          AND sh1.stat_date <= p_start_date
                          AND sh1.ag_stat_agent_id <> sh.ag_stat_agent_id)) OR EXISTS --2.5 ���� �� ��������� ������
              (SELECT '1'
                 FROM ven_ag_stat_agent sa
                     ,ven_ag_stat_hist  sh
                WHERE sa.brief IN ('��������')
                  AND sa.ag_stat_agent_id = p_status_id
                  AND sh.ag_contract_header_id = p_ag_contract_header_id
                  AND sh.ag_category_agent_id = p_categor_id
                  AND sa.ag_stat_agent_id = sh.ag_stat_agent_id
                  AND sh.stat_date <= ADD_MONTHS(LAST_DAY(p_start_date) + 1, - (2.5 * 12 + 1))
                  AND NOT EXISTS (SELECT '1' -- �� ���������� ������ � ������ �������� � ����� ����� 
                         FROM ven_ag_stat_agent sa1
                             ,ven_ag_stat_hist  sh1
                        WHERE sa1.ag_stat_agent_id = sh1.ag_stat_agent_id
                          AND sh1.ag_contract_header_id = p_ag_contract_header_id
                          AND sh1.stat_date > sh.stat_date
                          AND sh1.stat_date <= p_start_date
                          AND sh1.ag_stat_agent_id <> sh.ag_stat_agent_id)));
    EXCEPTION
      WHEN OTHERS THEN
        v_rez_agent := v_rez_agent; -- ������ ����� ������
    END;
    -- v_rez_agent := 1;
    -- ����������� ���� ���������� �������� � ������� ��� ������� ������ = "�����������"/"������������"
    SELECT ch.reg_date
      INTO v_dog_date
      FROM ven_ag_contract_header ch
     WHERE ch.ag_contract_header_id = p_ag_contract_header_id;
    -- ����������� ����. �� ���� ���������� ��������
    IF ADD_MONTHS(LAST_DAY(v_dog_date - 1) + 1, -1) <= ADD_MONTHS(LAST_DAY(p_start_date) + 1, -6)
    THEN
      v_koef_date := 1;
    ELSE
      v_koef_date := TO_NUMBER(LAST_DAY(v_dog_date) - v_dog_date) /
                     TO_NUMBER(TO_CHAR(LAST_DAY(v_dog_date), 'dd'));
    END IF;
  
    IF v_rez_agent < 2
    THEN
      -- �������� ������� �� ������������
    
      -- ����������� ���������� �������� ������� ��� ������
      IF v_rez_agent = 0
      THEN
        -- �������� ������� �� ���������� (����� ���������)
        SELECT MIN(sa.ag_stat_agent_id)
          INTO p_status_id
          FROM ven_ag_stat_agent sa
         WHERE sa.ag_category_agent_id = p_categor_id
           AND sa.is_default = 1;
      END IF;
    
      -- ������ ���������� �����:
      OPEN k_plan;
    
      LOOP
        -- ����������� �������� � ����������� �������� ������� ��� ������ ���������,
        FETCH k_plan
          INTO v_ag_stat.ag_stat_agent_id
              ,v_ag_stat.k_kd
              ,v_ag_stat.k_ksp
              ,v_ag_stat.k_sgp;
        -- ����� �� �����, ���� ��� ������� ������ ��������� ����������������
        EXIT WHEN k_plan%NOTFOUND;
      
        v_K_SGP := (NVL(v_ag_stat.k_sgp, 0) * v_koef_date) / 6 + (NVL(v_ag_stat.k_sgp, 0) * 5) / 6;
        v_K_KD  := NVL(v_ag_stat.k_kd, 0);
        v_K_KSP := NVL(v_ag_stat.k_ksp, 0);
      
        -- ����� �� �����, ���� ���� �� ��������
        EXIT WHEN NVL(p_K_SGP, 0) < v_K_SGP OR NVL(p_K_KD, 0) < v_K_KD OR NVL(p_K_KSP, 0) < v_K_KSP;
      
        -- �������� �������������� �������
        IF v_rez_agent > 0
        THEN
          IF p_status_id < v_ag_stat.ag_stat_agent_id
          THEN
            p_status_id := v_ag_stat.ag_stat_agent_id;
          END IF;
        ELSE
          p_status_id := v_ag_stat.ag_stat_agent_id;
        END IF;
      
      END LOOP;
      CLOSE k_plan;
    
    END IF;
  END;
  -------------------------------------------------------------------
  --*******************************************************************
  -- ���������� ������ ������������� �� ���� �������/����������
  -- @p_category_id ������������� ��������� (�����/��������)
  -- @param p_header_id ��������� ���������� ��������, ���� =0 , �� �� ���� ���������

  PROCEDURE attest_agent_status_all
  (
    p_category_id IN NUMBER
   ,p_header_id   IN NUMBER DEFAULT 0
   ,p_start_date  IN OUT DATE
  ) IS
  
    v_rez            NUMBER;
    v_category_brief VARCHAR2(100);
    v_stat_sovm_id   NUMBER;
    v_hstat          AG_STAT_HIST_TMP%ROWTYPE;
    v_all_stat       v_agent_current_status%ROWTYPE;
    -- ����������� ���� ��������� �������, �� ������� ���������� ����������
    CURSOR k_all_stat IS
    /*      select vv.*
                from v_agent_current_status vv
               where not (   vv.HEAD_STATUS in ('BREAK','STOPED','CANCEL')
                          or vv.LAST_VER_STATUS in ('BREAK','STOPED','CANCEL')
                          or vv.NUM_CONTR ='0')
                 and vv.category_id = p_category_id
                 and (p_header_id = 0 or vv.head_id = p_header_id)
                 and vv.DATE_CATEG <= p_start_date
               order by HEAD_ID;
        */
      SELECT ah.ag_contract_header_id AS HEAD_ID
             -- ������ ��������� �� �������� ����
            ,Doc.get_doc_status_brief(ah.ag_contract_header_id, p_start_date) AS HEAD_STATUS
            ,ac.ag_contract_id AS LAST_VER_ID
             -- ������ ������ �� �������� ����
            ,Doc.get_doc_status_brief(ac.ag_contract_id, p_start_date) AS LAST_VER_STATUS
            ,ac.category_id AS CATEGORY_ID
            ,ah.num AS NUM_CONTR
            ,Ent.obj_name(c1.ent_id, c1.contact_id) AS NAME_AGENT
            ,c2.NAME AS NAME_AGENCY
            ,ca.category_name AS NAME_CATEG
            ,ac_cat.date_begin AS DATE_CATEG
            ,sa.NAME AS NAME_STATUS
            ,sh.stat_date AS DATE_STATUS
      
        FROM ven_ag_contract_header ah
      -- ������ �������� �� �������� ����
        JOIN (SELECT MAX(A1.num) num
                    ,A1.contract_id
                FROM ven_ag_contract A1
               WHERE A1.date_begin < = p_start_date
               GROUP BY A1.contract_id) ac_dat
          ON (ac_dat.contract_id = ah.ag_contract_header_id)
        JOIN ven_ag_contract ac
          ON (ac.contract_id = ah.ag_contract_header_id AND ac.num = ac_dat.num)
        JOIN ven_ag_category_agent ca
          ON (ca.ag_category_agent_id = ac.category_id AND ca.brief IN ('AG', 'MN'))
      -- ������ ��������, ���������� ���������
        JOIN ven_ag_contract ac_cat
          ON (ac_cat.contract_id = ah.ag_contract_header_id)
      -- ������ ������ �� ���� (���� ����������)
        LEFT JOIN (SELECT MAX(h.num) num
                         ,h.ag_contract_header_id
                     FROM ven_ag_stat_hist h
                    WHERE h.stat_date < = p_start_date
                    GROUP BY h.ag_contract_header_id) sh_all
          ON (sh_all.ag_contract_header_id = ah.ag_contract_header_id)
        LEFT JOIN ven_ag_stat_hist sh
          ON (sh.ag_contract_header_id = ah.ag_contract_header_id AND sh_all.num = sh.num)
        LEFT JOIN ven_ag_stat_agent sa
          ON (sa.ag_stat_agent_id = sh.ag_stat_agent_id)
        LEFT JOIN ven_contact c1
          ON (ah.agent_id = c1.contact_id)
        LEFT JOIN ven_department c2
          ON (ah.agency_id = c2.department_id)
      
       WHERE ac_cat.num = (SELECT MIN(a2.num)
                             FROM ven_ag_contract a2
                            WHERE a2.contract_id = ah.ag_contract_header_id
                              AND a2.category_id = ac.category_id)
         AND Doc.get_doc_status_brief(ac.ag_contract_id, p_start_date) IN
             ('CURRENT', 'PRINTED', 'NEW')
         AND Doc.get_doc_status_brief(ah.ag_contract_header_id, p_start_date) IN
             ('CURRENT', 'PRINTED', 'NEW')
         AND ah.ag_contract_templ_k = 0
         AND (p_header_id = 0 OR ah.ag_contract_header_id = p_header_id)
         AND p_category_id = ca.ag_category_agent_id;
  
  BEGIN
    -- ������ ����� ������
    SELECT TRUNC(NVL(p_start_date, SYSDATE), 'MONTH') INTO p_start_date FROM dual;
  
    -- ����������� ��� "������������"
    BEGIN
      SELECT sa.ag_stat_agent_id
        INTO v_stat_sovm_id
        FROM ven_ag_stat_agent sa
       WHERE sa.brief = '�������';
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20001
                               ,'����������� ��� "������������" ' || SQLERRM);
    END;
  
    -- ����������� BRIEF ��������� ������
    BEGIN
      SELECT ca.brief
        INTO v_category_brief
        FROM ven_ag_category_agent ca
       WHERE ca.ag_category_agent_id = p_category_id;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20001
                               ,'����������� BRIEF ��������� ������ ' || SQLERRM);
    END;
  
    -- �������� ����� ����������
    v_hstat.is_save := 0;
    -- ���� ������� ��������
    v_hstat.stat_date := p_start_date;
  
    -- �������� ������� ���� �������� ��������� �������
    OPEN k_all_stat;
    LOOP
      FETCH k_all_stat
        INTO v_all_stat;
      EXIT WHEN k_all_stat%NOTFOUND;
      -- ������ ������������� ������� ����� ����������� v_rez=0 ���������� ��������, v_rez=1 ���
      v_rez := 0;
      -- ����������� �������� ��� �������
      BEGIN
      
        v_hstat.ag_contract_header_id := v_all_stat.HEAD_ID;
        v_hstat.ag_category_agent_id  := v_all_stat.category_id;
      
        SELECT NVL(MAX(sh.num), 0)
          INTO v_hstat.num
          FROM ven_ag_stat_hist sh
         WHERE sh.ag_contract_header_id = v_hstat.ag_contract_header_id
           AND sh.ag_category_agent_id = v_hstat.ag_category_agent_id;
      
        BEGIN
          SELECT sh.ag_stat_agent_id
            INTO v_hstat.ag_stat_agent_id_old
            FROM ven_ag_stat_hist sh
           WHERE sh.ag_contract_header_id = v_hstat.ag_contract_header_id
             AND sh.ag_category_agent_id = v_hstat.ag_category_agent_id
             AND sh.num = v_hstat.num;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            SELECT NULL INTO v_hstat.ag_stat_agent_id_old FROM dual;
          WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20001
                                   ,'����������� ����������� �������� ������� ������ ' || SQLERRM);
        END;
      
        -- ������ �� 6 ������� ����� ���������� �������� �� �������������
        BEGIN
          SELECT 1
            INTO v_rez
            FROM dual
           WHERE -- ���� ����������� ���������� �������� ����� ��� 6 ������� �����
           EXISTS (SELECT '1'
              FROM ven_ag_contract_header ch
             WHERE ch.date_begin BETWEEN ADD_MONTHS(LAST_DAY(p_start_date) + 1, -6) AND
                   LAST_DAY(p_start_date)
               AND ch.ag_contract_header_id = v_hstat.ag_contract_header_id)
           OR
          -- ���� ���������� ��������� �������� �� ���������� � ������� ������
           EXISTS (SELECT '1'
              FROM ven_ag_stat_hist sh
             WHERE sh.stat_date BETWEEN ADD_MONTHS(LAST_DAY(p_start_date) + 1, -2) AND
                   LAST_DAY(p_start_date)
               AND sh.ag_contract_header_id = v_hstat.ag_contract_header_id
               AND (sh.k_kd IS NOT NULL OR sh.k_ksp IS NOT NULL OR sh.k_sgp IS NOT NULL));
        EXCEPTION
          WHEN OTHERS THEN
            v_rez := 0;
        END;
        -- "������������" ������� �� �������� ����������
        IF v_hstat.ag_stat_agent_id_old = v_stat_sovm_id -- '������������'
        THEN
          v_rez := 1;
        END IF;
      
        -- ��������� ������������� ��� �������
        SELECT NULL
              ,NULL
              ,NULL
          INTO v_hstat.k_sgp
              ,v_hstat.k_kd
              ,v_hstat.k_ksp
          FROM dual;
      
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
    
      IF v_rez = 0
      THEN
        ---------!!!!!!!!!!!!!!!!!!!!!
        --/// ���������� ���������� � ���������� ��� �������
      
        v_hstat.num := v_hstat.num + 1;
        SELECT sq_ag_stat_hist_tmp.NEXTVAL INTO v_hstat.ag_stat_hist_tmp_id FROM dual;
      
        -- ������ ��������� ��������
        IF v_category_brief = 'AG'
        THEN
          -- ����� ��������� ������� ���������� �� ������
          attest_agent_status_one(v_all_stat.HEAD_ID
                                 ,p_start_date
                                 ,v_hstat.k_sgp
                                 ,v_hstat.k_kd
                                 ,v_hstat.k_ksp);
        ELSIF v_category_brief = 'MN'
        THEN
          -- ����� ��������� ������� ���������� �� ���������
          attest_manag_status_one(v_all_stat.HEAD_ID
                                 ,p_start_date
                                 ,v_hstat.k_sgp
                                 , /*v_hstat.k_kd,*/v_hstat.k_ksp);
        ELSE
          -- ������ ���������
          RAISE_APPLICATION_ERROR(2000
                                 ,'�� ���������� �������� ��������� ������');
        END IF;
        -- ���������� ��������� ������� ����� ����������� �� ���������� // ��������� ����.����������� �� ������ ������ ���������
        INSERT INTO AG_STAT_DET_ALL_TMP
          (SELECT SQ_AG_STAT_DET_ALL_TMP.NEXTVAL
                 ,t.filial_id
                 ,t.men_contract_header_id
                 ,t.ag_contract_header_id
                 ,t.policy_id
                 ,t.k_sgp
             FROM AG_STAT_DET_TMP t
           /*          where (t.ag_contract_header_id = v_all_stat.HEAD_ID and v_category_brief = 'AG')
                    or    (t.men_contract_header_id= v_all_stat.HEAD_ID and v_category_brief = 'MN')
           */
           );
      
        -- �������� ����������� ������� ������ �� ������ ������������ ����������� � ����������� �������� �������
        v_hstat.ag_stat_agent_id := v_hstat.ag_stat_agent_id_old;
      
        attest_status_new(v_all_stat.HEAD_ID
                         ,p_start_date
                         ,v_hstat.k_sgp
                         ,v_hstat.k_kd
                         ,v_hstat.k_ksp
                         ,v_hstat.ag_category_agent_id
                         ,v_hstat.ag_stat_agent_id);
      
        -- ������� ��������� �������� � ��� �������
        --  if v_hstat.ag_stat_agent_id_old <> v_hstat.ag_stat_agent_id then
        BEGIN
          INSERT INTO AG_STAT_HIST_TMP
            (AG_STAT_HIST_TMP_ID
            ,AG_CONTRACT_HEADER_ID
            ,NUM
            ,STAT_DATE
            ,AG_STAT_AGENT_ID
            ,K_SGP
            ,K_KD
            ,K_KSP
            ,AG_CATEGORY_AGENT_ID
            ,IS_SAVE
            ,AG_STAT_AGENT_ID_OLD)
          VALUES
            (v_hstat.AG_STAT_HIST_TMP_ID
            ,v_hstat.AG_CONTRACT_HEADER_ID
            ,v_hstat.NUM
            ,v_hstat.STAT_DATE
            ,v_hstat.AG_STAT_AGENT_ID
            ,v_hstat.K_SGP
            ,v_hstat.K_KD
            ,v_hstat.K_KSP
            ,v_hstat.AG_CATEGORY_AGENT_ID
            ,v_hstat.IS_SAVE
            ,v_hstat.AG_STAT_AGENT_ID_OLD);
        EXCEPTION
          WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(SQLCODE
                                   ,'������ �������� � ��� �������' || SQLERRM);
        END;
        -- end if;
      
      END IF; -----///  ��������� ���������� ���������� � ���������� ��� �������
    
    END LOOP;
    dbms_mview.refresh('mv_agent_attest');
    --commit;
    CLOSE k_all_stat;
  END;

  ------------------------------------------------------------
  ---/// -- ���������� �� ���������� ��������� ������ �� ��������
  FUNCTION find_last_ver_id(p_ag_contr_id NUMBER) RETURN NUMBER IS
    v_last_ver_id NUMBER := 0;
  BEGIN
    SELECT (ach.last_ver_id)
      INTO v_last_ver_id
      FROM ven_ag_contract_header ach
      JOIN ven_ag_contract ac
        ON (ac.contract_id = ach.ag_contract_header_id)
     WHERE ac.ag_contract_id = p_ag_contr_id;
    RETURN(v_last_ver_id);
  EXCEPTION
    WHEN OTHERS THEN
      v_last_ver_id := 0;
      RETURN(v_last_ver_id);
  END;

  -------------------------------------------------------
  --/// --  �������� ���� ������������ �������
  PROCEDURE set_current_status_date(p_ag_contr_id NUMBER) IS
    v_status_start_id NUMBER;
    v_date            DATE;
    v_date_last       DATE;
    v_date_doc        DATE;
    v_count           NUMBER;
    v_ag_h_id         NUMBER;
  BEGIN
  
    -- ��� �� ����!!!!????? ��� �����?
    /*    -- ���������� ������� ������� �� ���������
     begin
     v_status_start_id := doc.get_first_doc_status(p_ag_contr_id);
     exception
       when others then
               raise_application_error(-20000,
                               '�� ������� ������ NEW ��� ���������: '||p_ag_contr_id|| '. ��. ������ Oracle: ' ||
                               sqlerrm);
     end;
     -- ����� ���� ������� ������� �� ���������
    begin
     select s.start_date
       into v_date
       from doc_status s
      where s.doc_status_id =
            (select max(s1.doc_status_id)
               from doc_status s1
              where s1.document_id = p_ag_contr_id
                and s1.doc_status_ref_id = v_status_start_id);
     exception
       when others then
               raise_application_error(-20000,
                               '�� ������� ���� ������� ������� �� ���������: '||p_ag_contr_id|| '. ��. ������ Oracle: ' ||
                               sqlerrm);
     end;
     -- ����� ���� �� ���������
     begin
       select nvl(ah.date_begin, ac.date_begin)
         into v_date_doc
         from ven_document d
         left join ven_ag_contract_header ah on (ah.ag_contract_header_id =
                                                d.document_id and
                                                ah.ent_id = d.ent_id)
         left join ven_ag_contract ac on (ac.ag_contract_id = d.document_id and
                                         ac.ent_id = d.ent_id)
        where d.document_id = p_ag_contr_id;
     exception
       when others then
         v_date_doc := sysdate;
     end;
     -- ����� ������� � ����� �������, ��� ��������� ���� ��������� (��� ����� ����� ��������� �������)
     begin
       select min(start_date)
         into v_date
         from (select start_date
                 from doc_status s
                where s.document_id = p_ag_contr_id
                order by start_date desc)
        where rownum <= 2;
     exception
       when others then
         null;
     end;
     -- ���� ���� ��������� ������ ������� ����
     \*  if   trunc(v_date_doc) >= trunc(sysdate)
       then v_date:= to_date(to_char(v_date_doc,'dd.mm.yyyy')||' '||to_char(sysdate,'hh24.mi.ss'),'dd.mm.yyyy hh24.mi.ss');
       else v_date:= to_date(to_char(v_date,'dd.mm.yyyy')||' '||to_char(sysdate,'hh24.mi.ss'),'dd.mm.yyyy hh24.mi.ss');
       end if;
     *\
     -- ������ ���� �������, ��� ���������, ������� �� ���� ���������
     if trunc(v_date) <> v_date then
       v_date := to_date(to_char(v_date_doc, 'dd.mm.yyyy') || ' ' ||
                         to_char(v_date + 1 / (24 * 60 * 10), 'hh24.mi.ss'),
                         'dd.mm.yyyy hh24.mi.ss');
     else
       v_date := to_date(to_char(v_date_doc, 'dd.mm.yyyy') || ' ' ||
                         to_char(sysdate + 1 / (24 * 60 * 10), 'hh24.mi.ss'),
                         'dd.mm.yyyy hh24.mi.ss');
     end if;
     begin
     -- ��������� ���� �������� ������� �� ���������
     update doc_status s
        set s.start_date = v_date, s.change_date = sysdate
      where s.doc_status_id =
            (select max(s1.doc_status_id)
               from doc_status s1
              where s1.document_id = p_ag_contr_id);
    exception
     when others then
       raise_application_error(-20000,
                               '������ ���������� ���������:'|| p_ag_contr_id||
                               sqlerrm);
    
      end; */
    -- ����� �� ������, �� ��������� � ���� ���� ������.
    -- ������ ����� ��������� ������ � ������ ��.
    --
    -- ��������� ������ ��� ������
    -- ��� ���� ���� ������� ������ ��� ��������� �� ��� ������.
    -- � ����� ��� ��� ���������� ��� ��. �� ����� �� ������� - ����� ��� ��� ���� ����������
    --
    BEGIN
      SELECT c.contract_id INTO v_ag_h_id FROM AG_CONTRACT c WHERE c.ag_contract_id = p_ag_contr_id;
    
    EXCEPTION
      WHEN OTHERS THEN
        v_ag_h_id := NULL;
    END;
  
    IF v_ag_h_id IS NOT NULL
    THEN
      set_last_ver(v_ag_h_id, p_ag_contr_id);
    END IF;
    --set_last_ver(v_ag_h_id, p_ag_contr_id);
  
    --
  
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20000
                             ,'��������� ���� ������������ ������� ���������:' || p_ag_contr_id ||
                              SQLERRM);
  END;

  FUNCTION get_agent_status_by_date
  (
    contract_header_id NUMBER
   ,status_date        DATE
  ) RETURN NUMBER IS
    ret_val NUMBER;
  BEGIN
  
    /* select a.ag_stat_hist_id into ret_val from (
    SELECT max(sh2.num) over (partition by  sh2.stat_date) num,
                   sh2.stat_date, sh2.ag_stat_hist_id
      FROM ven_ag_stat_hist sh2
     WHERE sh2.ag_contract_header_id = contract_header_id
    ) A where
       a.stat_date <= status_date;*/
    SELECT ag_stat_hist_id
      INTO ret_val
      FROM (SELECT sh.ag_stat_hist_id
              FROM ven_ag_stat_hist sh
             WHERE sh.ag_contract_header_id = contract_header_id
               AND sh.stat_date <= status_date
            --and sh.ag_category_agent_id = v_hstat.ag_category_agent_id
             ORDER BY sh.stat_date DESC
                     ,sh.num       DESC)
     WHERE ROWNUM = 1;
    /*
    select sh2.ag_stat_hist_id
       INTO ret_val
       FROM ven_ag_stat_hist sh2
      WHERE sh2.ag_contract_header_id = contract_header_id
        AND sh2.num =
            (SELECT max(sh.num)
               FROM ven_ag_stat_hist sh
              WHERE sh.ag_contract_header_id = contract_header_id
                AND sh.stat_date =
                    (SELECT MAX(sh1.stat_date)
                       FROM ven_ag_stat_hist sh1
                      WHERE sh1.ag_contract_header_id = contract_header_id
                        AND sh1.stat_date <= status_date));*/
    /*
    SELECT sh.ag_stat_hist_id
      INTO ret_val
      FROM ven_ag_stat_hist sh
     WHERE sh.ag_contract_header_id = contract_header_id
       AND sh.stat_date =
              (SELECT MAX (sh1.stat_date)
                 FROM ven_ag_stat_hist sh1
                 WHERE sh1.ag_contract_header_id = contract_header_id
                  AND sh1.stat_date <= status_date); */
    RETURN ret_val;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN ret_val;
    
  END;

  -- ���������� ���� ������� ������
  FUNCTION get_agent_status_brief_by_date
  (
    contract_header_id NUMBER
   ,status_date        DATE
  ) RETURN VARCHAR2 IS
    br VARCHAR2(50);
  BEGIN
    SELECT agst.brief
      INTO br
      FROM AG_STAT_HIST aghist
      JOIN AG_STAT_AGENT agst
        ON agst.ag_stat_agent_id = aghist.ag_stat_agent_id
     WHERE aghist.ag_stat_hist_id =
           Pkg_Agent_1.get_agent_status_by_date(contract_header_id, status_date);
    RETURN(br);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  -- ���������� ���� ��������� ������
  FUNCTION get_agent_cat_brief_by_date
  (
    contract_header_id NUMBER
   ,status_date        DATE
  ) RETURN VARCHAR2 IS
    br VARCHAR2(50);
  BEGIN
    SELECT agst.brief
      INTO br
      FROM AG_STAT_HIST aghist
      JOIN AG_CATEGORY_AGENT agst
        ON agst.ag_category_agent_id = aghist.ag_category_agent_id
     WHERE aghist.ag_stat_hist_id =
           Pkg_Agent_1.get_agent_status_by_date(contract_header_id, status_date);
    RETURN(br);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  -- ���������� ���� ������� ������
  FUNCTION get_agent_status_name_by_date
  (
    contract_header_id NUMBER
   ,status_date        DATE
  ) RETURN VARCHAR2 IS
    n               VARCHAR2(100);
    NEW_status_date DATE;
  BEGIN
  
    Pkg_Agent_Rate.ST_MN := Pkg_Agent_1.get_agent_cat_st_by_date(contract_header_id, status_date);
  
    IF Pkg_Agent_Rate.ST_MN IN (126, 127, 128)
    THEN
      --is Manager
      SELECT MIN(agst.NAME)
        INTO n
        FROM AG_STAT_HIST aghist
        JOIN AG_STAT_AGENT agst
          ON agst.ag_stat_agent_id = aghist.ag_stat_agent_id
       WHERE aghist.ag_stat_hist_id =
             Pkg_Agent_1.get_agent_status_by_date(contract_header_id, status_date);
    
    ELSE
      --is NOT Manager
    
      SELECT MIN(h.stat_date)
        INTO NEW_status_date
        FROM ven_ag_stat_hist h
       WHERE h.ag_contract_header_id = contract_header_id
         AND h.num = (SELECT MIN(h1.num)
                        FROM ven_ag_stat_hist      h1
                            ,ven_ag_category_agent s
                       WHERE h1.ag_contract_header_id = h.ag_contract_header_id
                         AND h1.ag_category_agent_id = s.ag_category_agent_id
                         AND s.brief = 'MN'
                      -- and h1.stat_date  > status_date
                      );
    
      SELECT MIN(agst.NAME)
        INTO n
        FROM AG_STAT_HIST aghist
        JOIN AG_STAT_AGENT agst
          ON agst.ag_stat_agent_id = aghist.ag_stat_agent_id
       WHERE aghist.ag_stat_hist_id =
             Pkg_Agent_1.get_agent_status_by_date(contract_header_id, NEW_status_date)
         AND aghist.ag_category_agent_id = 3;
    
    END IF;
  
    RETURN(n);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  FUNCTION get_agent_cat_st_by_date
  (
    contract_header_id NUMBER
   ,status_date        DATE
  ) RETURN NUMBER IS
    v_val NUMBER := 0;
    v_rez NUMBER := 0;
  BEGIN
    v_val := Pkg_Agent_1.get_agent_status_by_date(contract_header_id, status_date);
    SELECT sh.ag_stat_agent_id INTO v_rez FROM ven_ag_stat_hist sh WHERE sh.ag_stat_hist_id = v_val;
    RETURN v_rez;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN v_rez;
    
  END;

  ----------------------------------------------
  -- ���������� ���� ������ �������� �������� �����������.
  -- ���� ���� ������ �� �7 �� ������� ���� ������ ��� ���� ��������� �7
  ----------------------------------------------
  FUNCTION get_agent_start_contr
  (
    p_policy_header_id IN NUMBER
   ,par_return         NUMBER DEFAULT 1
  ) RETURN DATE IS
    var_date_ret DATE;
  BEGIN
  
    --�������� �.�. 29/01/20009 ������ ������� ������ 1�� ��� � ������� ��� ���� ����
    --26/03/2009 ���� ���� ���� ���������� ��������� �� ���������� ������ �� (������ ����������
    -- ������� �� ���� ���: �������� � ���������� ���������)
    --14/04/2009 ����� ���������� ������ ����� ������� �� ���.
    --��� ���� ����� ��� ��������� ������ ����� ���� ������ �� ��������� ��������=2
    --02/05/2009 ������� ��������� ������� ���� ������� (��������=1)
    CASE
      WHEN par_return IN (2, 3) THEN
        SELECT GREATEST(NVL(( /*SELECT MAX(pa2.reg_date) date_a7
                                                                           FROM ven_doc_doc      d,
                                                                                ven_ac_payment   ap,
                                                                                DOC_SET_OFF      dso,
                                                                                ven_ac_payment   pa2,
                                                                                AC_PAYMENT_TEMPL acpt,
                                                                                P_POL_HEADER     ph,
                                                                                P_POLICY         pp
                                                                          WHERE ph.policy_header_id = pph.policy_header_id
                                                                            AND pp.pol_header_id = ph.policy_header_id
                                                                            AND ap.payment_number = 1
                                                                            AND d.parent_id = pp.policy_id
                                                                            AND acpt.payment_templ_id = pa2.payment_templ_id
                                                                            AND ap.payment_id = d.child_id
                                                                            AND Doc.get_doc_status_brief(ap.payment_id) = 'PAID'
                                                                            --�������� �.�. 05/06/2009 �� ��������� ������������� �������
                                                                            AND doc.get_doc_status_brief(pa2.payment_id) <> 'ANNULATED'
                                                                            AND dso.parent_doc_id = ap.payment_id
                                                                            AND dso.child_doc_id = pa2.payment_id
                                                                            AND (acpt.brief = 'A7' OR acpt.brief = 'PD4' OR acpt.brief = '��')*/
                            /* ����� ����������������� �������*/
                            SELECT MAX(pa2.reg_date)
                              FROM doc_doc          d
                                   ,ven_ac_payment   ap
                                   ,DOC_SET_OFF      dso
                                   ,ven_ac_payment   pa2
                                   ,AC_PAYMENT_TEMPL acpt
                                   ,P_POL_HEADER     ph
                                   ,P_POLICY         pp
                             WHERE ph.policy_header_id = pph.policy_header_id
                               AND pp.pol_header_id = ph.policy_header_id
                               AND d.parent_id = pp.policy_id
                               AND acpt.payment_templ_id = pa2.payment_templ_id
                               AND ap.payment_id = d.child_id
                                  -- AND Doc.get_doc_status_brief(ap.payment_id) = 'PAID'
                                  --�������� �.�. 04/06/2009 �� ��������� ������������� �������
                               AND doc.get_doc_status_brief(pa2.payment_id) <> 'ANNULATED'
                               AND dso.parent_doc_id = ap.payment_id
                               AND dso.child_doc_id = pa2.payment_id
                               AND (acpt.brief = 'A7' OR acpt.brief = 'PD4' OR acpt.brief = '��')
                                  --�������� �.�. 04/06/2009 ���� 1 ��� �� � ������� ������� ���� ����������� ��������� � ����� �� �����
                               AND ap.payment_number =
                                   (SELECT MIN(acp2.payment_number)
                                      FROM ac_payment acp2
                                          ,doc_doc    dd2
                                          ,p_policy   pp2
                                     WHERE Doc.get_doc_status_brief(acp2.payment_id) = 'PAID'
                                       AND acp2.payment_id = dd2.child_id
                                       AND dd2.parent_id = pp2.policy_id
                                       AND pp2.pol_header_id = pph.policy_header_id
                                       AND acp2.plan_date =
                                           (SELECT MIN(acp3.plan_date) --BUG: ������ 24279 
                                              FROM ac_payment acp3
                                                  ,doc_doc    dd3
                                                  ,p_policy   pp3
                                             WHERE acp3.payment_number = 1
                                               AND acp3.payment_id = dd3.child_id
                                               AND dd3.parent_id = pp3.policy_id
                                               AND pp3.pol_header_id = pph.policy_header_id)))
                           ,CASE
                              WHEN par_return = 3 THEN
                               pph.start_date
                              ELSE
                               NULL
                            END)
                       ,pph.start_date)
          INTO var_date_ret
          FROM P_POL_HEADER pph
         WHERE pph.policy_header_id = p_policy_header_id;
      WHEN par_return = 4 THEN
        BEGIN
          SELECT MAX(CASE
                       WHEN acpt.brief = '��' THEN
                        pa2.due_date
                       ELSE
                        bank_doc.due_date
                     END)
            INTO var_date_ret
            FROM doc_doc d
                ,ven_ac_payment ap
                ,DOC_SET_OFF dso
                ,ven_ac_payment pa2
                ,AC_PAYMENT_TEMPL acpt
                ,P_POLICY pp2
                ,(SELECT dd2.parent_id
                        ,ap3.due_date
                    FROM doc_doc     dd2
                        ,doc_set_off dso2
                        ,ac_payment  ap3
                   WHERE dso2.parent_doc_id = dd2.child_id
                     AND doc.get_doc_status_brief(dd2.child_id) = 'PAID'
                     AND ap3.payment_id = dso2.child_doc_id) bank_doc
           WHERE pp2.pol_header_id = p_policy_header_id
             AND d.parent_id = pp2.policy_id
             AND acpt.payment_templ_id = pa2.payment_templ_id
             AND ap.payment_id = d.child_id
             AND doc.get_doc_status_brief(pa2.payment_id) <> 'ANNULATED'
             AND dso.parent_doc_id = ap.payment_id
             AND dso.child_doc_id = pa2.payment_id
             AND bank_doc.parent_id(+) = pa2.payment_id
             AND (acpt.brief = 'A7' OR acpt.brief = 'PD4' OR acpt.brief = '��')
             AND ap.payment_number IN
                 (SELECT acp2.payment_number
                    FROM ac_payment acp2
                        ,doc_doc    dd2
                        ,p_policy   pp3
                   WHERE Doc.get_doc_status_brief(acp2.payment_id) = 'PAID'
                     AND acp2.payment_id = dd2.child_id
                     AND dd2.parent_id = pp3.policy_id
                     AND pp3.pol_header_id = p_policy_header_id
                     AND acp2.plan_date =
                         (SELECT MIN(acp3.plan_date) --BUG: ������ 24279
                            FROM ac_payment acp3
                                ,doc_doc    dd3
                                ,p_policy   pp4
                           WHERE acp3.payment_number = 1
                             AND acp3.payment_id = dd3.child_id
                             AND dd3.parent_id = pp4.policy_id
                             AND pp4.pol_header_id = p_policy_header_id));
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            var_date_ret := NULL;
        END;
      WHEN par_return = 5 THEN
        --������� ���������� �������� � ���� (������������ � ��������)
        BEGIN
          SELECT MAX(pay_doc.due_date)
            INTO var_date_ret
            FROM p_pol_header     ph
                ,p_policy         pp
                ,doc_doc          dd
                ,ven_ac_payment   epg
                ,doc_set_off      dso
                ,ac_payment       pay_doc
                ,ac_payment_templ acpt
           WHERE 1 = 1
             AND ph.policy_header_id = p_policy_header_id
             AND pp.pol_header_id = ph.policy_header_id
             AND pp.policy_id = dd.parent_id
             AND dd.child_id = epg.payment_id
             AND epg.doc_templ_id = 4 -- ���
             AND epg.payment_id = dso.parent_doc_id
             AND doc.get_doc_status_brief(dso.doc_set_off_id) <> 'ANNULATED' -- �������� ������ �� ����������
             AND dso.child_doc_id = pay_doc.payment_id
             AND acpt.payment_templ_id = pay_doc.payment_templ_id
             AND acpt.brief IN ('A7', 'PD4', '��', '��_��', '��_��')
                -- AND pay_doc.doc_templ_id IN (6531,5234,86) --�7, ��4, ��
             AND epg.payment_number =
                 (SELECT MIN(acp2.payment_number)
                    FROM ac_payment acp2
                        ,doc_doc    dd2
                        ,p_policy   pp2
                   WHERE Doc.get_doc_status_brief(acp2.payment_id) = 'PAID'
                     AND acp2.payment_id = dd2.child_id
                     AND dd2.parent_id = pp2.policy_id
                     AND pp2.pol_header_id = ph.policy_header_id
                     AND acp2.plan_date =
                         (SELECT MIN(acp3.plan_date) --BUG: ������ 24279 
                            FROM ac_payment acp3
                                ,doc_doc    dd3
                                ,p_policy   pp3
                           WHERE 1 = 1
                                --acp3.payment_number =1-- ��� ������������ ��
                             AND acp3.payment_id = dd3.child_id
                             AND dd3.parent_id = pp3.policy_id
                             AND pp3.pol_header_id = ph.policy_header_id));
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            var_date_ret := NULL;
        END;
      ELSE
        SELECT NVL( --04/06/09 �������� �.�.
                   --� ������ ������� ��������� �� ������ ���� ������ ������� � �������� �� ����� ��� � �����
                   --������ ������������� ��������� �������� �����
                   (SELECT MAX(pa2.reg_date) date_a7
                      FROM ven_doc_doc      d
                          ,ven_ac_payment   ap
                          ,DOC_SET_OFF      dso
                          ,ven_ac_payment   pa2
                          ,AC_PAYMENT_TEMPL acpt
                          ,P_POL_HEADER     ph
                          ,P_POLICY         pp
                     WHERE ph.policy_header_id = pph.policy_header_id
                       AND pp.pol_header_id = ph.policy_header_id
                       AND ap.payment_number = 1
                       AND d.parent_id = pp.policy_id
                       AND acpt.payment_templ_id = pa2.payment_templ_id
                       AND ap.payment_id = d.child_id
                       AND Doc.get_doc_status_brief(ap.payment_id) = 'PAID'
                          --�������� �.�. 04/06/2009 �� ��������� ������������� �������
                       AND doc.get_doc_status_brief(pa2.payment_id) <> 'ANNULATED'
                       AND dso.parent_doc_id = ap.payment_id
                       AND dso.child_doc_id = pa2.payment_id
                       AND (acpt.brief = 'A7' OR acpt.brief = 'PD4' OR acpt.brief = '��'))
                  ,pph.start_date)
          INTO var_date_ret
          FROM P_POL_HEADER pph
         WHERE pph.policy_header_id = p_policy_header_id;
    END CASE;
    RETURN var_date_ret;
  EXCEPTION
    WHEN OTHERS THEN
    
      RAISE_APPLICATION_ERROR(-20001
                             ,'������ ����������� ���� ������ �������� �������� ����������� (p_pol_header_id: ' ||
                              p_policy_header_id || ')');
    
  END get_agent_start_contr;
  ---/// ����������� ��������� ������ �� �����
  FUNCTION get_agent_cat_by_date
  (
    p_contract_header_id IN NUMBER
   ,p_status_date        IN DATE
  ) RETURN NUMBER IS
  
    v_period_start_new DATE := SYSDATE;
    v_period_start_old DATE := SYSDATE;
    v_period_end_old   DATE := SYSDATE;
    v_cat              NUMBER := 0;
    v_rez              NUMBER := 0;
  
  BEGIN
    -- ������ ����� �� ������ ������ ��.��������
    FOR cat IN (SELECT ac.date_begin
                      ,ac.category_id
                  FROM ven_ag_contract_header h
                  JOIN ven_ag_contract ac
                    ON (ac.contract_id = h.ag_contract_header_id)
                 WHERE h.ag_contract_header_id = p_contract_header_id
                 ORDER BY ac.date_begin)
    LOOP
      IF cat.category_id <> v_cat
      THEN
        -- ��������� ����� ���������
        IF v_period_start_old = SYSDATE
        THEN
          v_period_start_old := cat.date_begin;
        ELSE
          v_period_start_old := v_period_start_new;
        END IF;
        v_period_start_new := cat.date_begin;
        v_period_end_old   := cat.date_begin; -- ��������� ����� ���������� ���������
      
        IF p_status_date BETWEEN v_period_start_old AND v_period_end_old
        THEN
          v_rez := v_cat;
          EXIT;
        END IF;
        v_cat := cat.category_id;
      END IF;
    END LOOP;
    IF v_rez = 0
    THEN
      v_rez := v_cat;
    END IF;
    RETURN(v_rez);
  END;

  -------------------------------------------------------
  --/// ���������  �������� ������� ���������� �������� � ������ "����� � �����������"
  PROCEDURE set_status_ready_to_cancel(p_ag_contr_id IN NUMBER) IS
    v_ag_contr_header_id   NUMBER;
    v_agent_id             NUMBER;
    v_date                 DATE;
    v_date_status          DATE;
    v_status_dov_id        NUMBER;
    v_status_id            NUMBER;
    v_status_change_id     NUMBER;
    v_count                NUMBER;
    v_mess                 VARCHAR2(250);
    v_err                  NUMBER := 0;
    v_ds_id                NUMBER;
    v_doc_status_action_id NUMBER;
  
  BEGIN
  
    /*    v_date_status := sysdate;
    if v_date_status not between add_months(sysdate, -1) and sysdate then
      v_mess := v_mess || '���� ' || v_date_status ||
                ' �� �������� ���������� ��� ������ ��������';
      v_err  := v_err + 1;
    end if;*/
  
    IF find_last_ver_id(p_ag_contr_id) <> p_ag_contr_id
    THEN
      v_mess := v_mess || '������ ��.�������� �� �������� ����������� ';
      v_err  := 1;
    END IF;
    /*   if doc.get_doc_status_brief(p_ag_contr_id) not in (STATUS_RESUME, STATUS_CURRENT, STATUS_STOP) then
      v_mess:=v_mess||'������ ������ ��.�������� �� ��������� ������������ "����� � �����������" ';
      v_err := 2;
    end if;  */
    BEGIN
      SELECT ah.ag_contract_header_id
            ,ah.agent_id
        INTO v_ag_contr_header_id
            ,v_agent_id
        FROM ven_ag_contract        ac
            ,ven_ag_contract_header ah
       WHERE ac.ag_contract_id = p_ag_contr_id
         AND ah.ag_contract_header_id = ac.contract_id;
    EXCEPTION
      WHEN OTHERS THEN
        v_mess := '��������� ����������� ��(��������� ��.��������) ';
        v_err  := v_err + 1;
    END;
    -- ���� ������������ ������� ���������
    BEGIN
      SELECT s.start_date
        INTO v_date
        FROM DOC_STATUS s
       WHERE s.start_date =
             (SELECT MAX(s1.start_date)
                FROM DOC_STATUS s1
               WHERE s1.document_id = v_ag_contr_header_id
                 AND Doc.get_doc_status_brief(v_ag_contr_header_id) <> STATUS_READY_TO_CANCEL)
         AND s.document_id = v_ag_contr_header_id;
    EXCEPTION
      WHEN OTHERS THEN
        v_date := SYSDATE;
    END;
  
    IF v_date > SYSDATE
    THEN
      v_mess := v_mess || '���� ������� ��������� �� ��������� ����������� ��� ����� ����� ';
      v_err  := v_err + 1;
    END IF;
    -- ���� ������� "����� � �����������"
    v_date := Doc.get_last_doc_status_date(p_ag_contr_id);
  
    IF v_date IS NULL
    THEN
      RAISE_APPLICATION_ERROR(-20000
                             ,'�� ������� ���� ���������� � �����������' || SQLERRM);
    END IF;
  
    IF v_date NOT BETWEEN ADD_MONTHS(SYSDATE, -1) AND SYSDATE
    THEN
      v_mess := v_mess || '���� ' || v_date || ' �� ���������� ��� ������ ��������';
      v_err  := v_err + 1;
    END IF;
  
    v_count := Pkg_Bso.count_bso_to_contact(v_agent_id);
    IF v_count > 0
    THEN
      v_mess := v_mess || '�� ������� �������� ' || v_count || ' ��� ';
      v_err  := v_err + 1;
    END IF;
  
    BEGIN
      SELECT t.doc_status_ref_id
        INTO v_status_change_id
        FROM DOC_STATUS_REF t
       WHERE t.brief = STATUS_BREAK;
    
      SELECT t.doc_status_ref_id
        INTO v_status_id
        FROM DOC_STATUS_REF t
       WHERE t.brief = STATUS_READY_TO_CANCEL;
    EXCEPTION
      WHEN OTHERS THEN
        v_mess := v_mess || '�� ������ ������ ��� ������������� ������ ';
        v_err  := v_err + 1;
    END;
    --- ������ � ���������� ������� ������ ���������� ���������
    IF v_err = 0
    THEN
      BEGIN
        FOR dov IN (SELECT c.ag_contract_dover_id
                      FROM ven_ag_contract_dover c
                     WHERE c.ag_contract_header_id = v_ag_contr_header_id
                       AND Doc.get_doc_status_brief(c.ag_contract_dover_id) <> 'STOPED')
        LOOP
          Doc.set_doc_status(dov.ag_contract_dover_id, 'STOPED', ADD_MONTHS(v_date, 1));
        END LOOP;
      EXCEPTION
        WHEN OTHERS THEN
          v_mess := '���������� �������� ������ �������������';
          v_err  := v_err + 1;
      END;
      --    doc.set_doc_status(p_ag_contr_id,'STOPED',add_months(v_date, 1));
    
      BEGIN
        INSERT INTO DOC_STATUS ds
          (ds.doc_status_id
          ,ds.document_id
          ,ds.doc_status_ref_id
          ,ds.start_date
          ,ds.note
          ,ds.src_doc_status_ref_id)
        VALUES
          (sq_doc_status.NEXTVAL
          ,p_ag_contr_id
          ,v_status_change_id
          ,
           --ADD_MONTHS(v_date, 1),
           --�������� 02.10.2009 �������� �.�. �� ������ �48747
           v_date + 20
          ,'from status_ready_to_cancel'
          ,v_status_id);
      
      EXCEPTION
        WHEN OTHERS THEN
          v_mess := '��������� ����������� �� �� ��������� ������� ������ ��';
          v_err  := v_err + 1;
      END;
    END IF;
    IF v_err <> 0
    THEN
      -- ��������� ����� ������� "����� � �����������"
      v_err := (-1) * (v_err + 20000);
      RAISE_APPLICATION_ERROR(v_err, v_mess);
    END IF;
  
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20000
                             ,'��������� "����� � �����������"' || SQLERRM);
  END;
  ----------------------------------------------
  -- ���������� ���������� ������������ ��� �� �������� �����������.
  -- ������������ � ����� AG_REPORT_DET = ���� NUM_YEAR
  ----------------------------------------------

  FUNCTION get_num_year_OAV(p_policy_header_id IN NUMBER) RETURN NUMBER IS
    v_num_year    NUMBER;
    v_day_pay     DATE;
    v_start_contr DATE;
  BEGIN
    v_start_contr := get_agent_start_contr(p_policy_header_id);
  
    BEGIN
      -- �������� ������� �� ����� - ���������� ���� ������
      SELECT ac.date_pay
        INTO v_day_pay
        FROM ven_agent_report_cont  ac
            ,ven_trans              tr
            ,ven_p_pol_header       ph
            ,ven_p_policy           pp
            ,v_pol_issuer           pi
            ,ven_t_product          tp
            ,ven_as_asset           ass
            ,ven_p_cover            pc
            ,ven_t_prod_line_option plo
            ,OPER                   o
            ,DOC_SET_OFF            dso
            ,ven_ac_payment         ap
       WHERE tr.trans_id = ac.trans_id
         AND ph.policy_header_id = pp.pol_header_id
         AND pp.policy_id = ac.policy_id
         AND pi.policy_id = ac.policy_id
         AND tp.product_id = ph.product_id
         AND ass.p_policy_id = ph.policy_id
         AND tr.a2_ct_uro_id = pp.policy_id
         AND tr.a4_ct_uro_id = pc.t_prod_line_option_id
         AND pc.as_asset_id = ass.as_asset_id
         AND plo.ID = pc.t_prod_line_option_id
         AND o.oper_id = tr.oper_id
         AND o.document_id = dso.doc_set_off_id
         AND dso.child_doc_id = ap.payment_id
            
         AND ph.policy_header_id = p_policy_header_id;
    EXCEPTION
      WHEN OTHERS THEN
        v_day_pay := SYSDATE;
    END;
    v_num_year := CEIL(MONTHS_BETWEEN(v_day_pay, v_start_contr) / 12);
    IF v_num_year = 0
    THEN
      RETURN 1;
    ELSE
      RETURN v_num_year;
    END IF;
  
  END;
  /**
  * ��������������� ��������� ��� ������������� � �������������
  * @author ���������� �������
  */
  FUNCTION get_date RETURN DATE IS
  BEGIN
    --���� = ������ ����� ������
    SELECT TRUNC(Pkg_Agent_1.DATE_START, 'MONTH') INTO Pkg_Agent_1.DATE_START FROM dual;
  
    RETURN Pkg_Agent_1.DATE_START;
  END;

  PROCEDURE set_date(p_date IN DATE) IS
  BEGIN
    SELECT TRUNC(p_date, 'MONTH') INTO Pkg_Agent_1.DATE_START FROM dual;
    --PKG_AGENT_1.DATE_START:=p_date;
  END;

  ------------------------------------------------------------
  --
  -- ���������� ��� �� ��������������� �������
  --
  ------------------------------------------------------------
  -- 28.08.2008 �������� �.� ���� ��������� � ������
  -- 22.09.2008 �������� �.�. ������� �������� p_start_date - ���� ������ ������� ���
  FUNCTION attest_recruit_SGP
  (
    p_ag_contract_id NUMBER
   ,p_end_date       DATE
   ,p_start_date     DATE DEFAULT NULL
  ) RETURN NUMBER IS
  
    var_return NUMBER := 0;
    recr_count NUMBER;
  
  BEGIN
    -- �� ����� ������� ��������� �������!!!
  
    --DELETE FROM AG_STAT_DET_TMP;
    EXECUTE IMMEDIATE 'TRUNCATE TABLE AG_STAT_DET_TMP';
  
    glb_clear_flag_attest            := '�';
    Pkg_Agent_Rate.glb_count_recruit := 0;
  
    FOR rc IN (
               
               SELECT ch_2.ag_contract_header_id
                      ,decode(p_start_date, NULL, ch_2.date_begin, p_start_date) date_begin
                 FROM ag_contract_header ch_2
                      ,ag_contract ac_2
                      ,AG_CONTRACT agc_rec
                      ,ag_contract_header agh_rec
                      ,t_sales_channel h
                      ,(SELECT agch.last_ver_id ag_contract_id
                          FROM AG_CONTRACT        agc
                              ,AG_CONTRACT_HEADER agch
                         WHERE agch.ag_contract_header_id = agc.contract_id
                           AND agc.ag_contract_id = p_ag_contract_id) ag_rec
                WHERE EXISTS (SELECT 1
                         FROM p_pol_header        ph
                             ,p_policy_agent      pa
                             ,policy_agent_status pas
                        WHERE pa.status_id = pas.policy_agent_status_id
                          AND pas.brief IN ('CURRENT', 'CANCEL')
                          AND ch_2.ag_contract_header_id = pa.ag_contract_header_id
                          AND pa.policy_header_id = ph.policy_header_id
                             -- ��������� �������� - �������� �������.
                          AND Pkg_Agent_1.get_agent_start_contr(ph.policy_header_id) BETWEEN
                              ch_2.date_begin AND p_end_date)
                     -- ��� ��� �� ������
                  AND ac_2.contract_recrut_id = agc_rec.ag_contract_id
                  AND agh_rec.ag_contract_header_id = agc_rec.contract_id
                  AND agh_rec.last_ver_id = ag_rec.ag_contract_id
                  AND ch_2.last_ver_id = ac_2.ag_contract_id
                  AND h.ID = ch_2.t_sales_channel_id
                  AND h.brief = 'MLM')
    LOOP
    
      var_return := var_return +
                    Pkg_Agent_1.get_SGP_agent_DAVR(rc.ag_contract_header_id, rc.date_begin, p_end_date);
      SELECT COUNT(*) INTO recr_count FROM AG_STAT_DET_TMP;
    
      Pkg_Agent_Rate.glb_count_recruit := Pkg_Agent_Rate.glb_count_recruit + recr_count;
    
    END LOOP;
    --dbms_output.put_line (var_return);
    -- ������ ����� ������� ��������� �������!!!
    glb_clear_flag_attest := '�';
  
    RETURN var_return;
  
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20001
                             ,'������ ������� ��� ��� ��������������� ������� ��� p_ag_contract_id: ' ||
                              p_ag_contract_id || ' ��. ������ Oracle: ' || SQLERRM(SQLCODE));
    
  END attest_recruit_SGP;

  /*
  FUNCTION  attest_recruit_SGP (p_ag_contract_id NUMBER, p_end_date DATE) RETURN NUMBER IS
  
   var_return NUMBER := 0;
  
  BEGIN
  -- �� ����� ������� ��������� �������!!!
  
  DELETE FROM AG_STAT_DET_TMP;
  
  glb_clear_flag_attest := '�';
  
    FOR rc IN (SELECT ch_2.ag_contract_header_id,
         ch_2.date_begin
    
    FROM ven_ag_contract_header ch_2,
         ven_ag_contract ac_2,
         AG_CONTRACT agc_rec,
         ven_ag_contract_header agh_rec,
         ven_t_sales_channel h,
         ven_p_pol_header        ph,
         ven_p_policy_agent      pa,
                 ven_policy_agent_status pas,
         (SELECT agch.last_ver_id ag_contract_id
            FROM AG_CONTRACT        agc,
                 AG_CONTRACT_HEADER agch
           WHERE agch.ag_contract_header_id = agc.contract_id
             AND agc.ag_contract_id = p_ag_contract_id) ag_rec
   WHERE Pkg_Agent_1.get_agent_start_contr(ph.policy_header_id) BETWEEN
         ch_2.date_begin AND p_end_date
     AND pa.status_id = pas.policy_agent_status_id
             AND pas.brief IN ('CURRENT','CANCEL')
             AND ch_2.ag_contract_header_id = pa.ag_contract_header_id
             AND pa.policy_header_id = ph.policy_header_id
        -- ��� ��� �� ������
     AND ac_2.contract_recrut_id = agc_rec.ag_contract_id
     AND agh_rec.ag_contract_header_id = agc_rec.contract_id
     AND agh_rec.last_ver_id = ag_rec.ag_contract_id
     AND ch_2.last_ver_id = ac_2.ag_contract_id
     AND h.ID = ch_2.t_sales_channel_id
     AND h.brief = 'MLM') LOOP
  
  
      var_return := var_return + Pkg_Agent_1.get_SGP_agent(rc.ag_contract_header_id,
                                           rc.date_begin,
                                           p_end_date);
    END LOOP;
  --dbms_output.put_line (var_return);
  -- ������ ����� ������� ��������� �������!!!
  glb_clear_flag_attest := '�';
  
    RETURN var_return;
  
  EXCEPTION WHEN OTHERS THEN
     RAISE_APPLICATION_ERROR(-20001, '������ ������� ��� ��� ��������������� ������� ��� p_ag_contract_id: '||p_ag_contract_id||' ��. ������ Oracle: '||SQLERRM(SQLCODE));
  
  END attest_recruit_SGP;
  */
  ------------------------------------------------------------
  --
  -- ����������� ���-�� ��������������� �������
  -- ����������� 26.10.2007 ���������: ���������� ���������� ���-�� �� ����������� ����������������
  --
  -- 22.09.2008 �������� �.�. ������� p_start_date
  -- 20/02/2009 DEPRICATED ������ ��� ������� �� ������������
  ------------------------------------------------------------
  FUNCTION attest_count_recruit
  (
    p_ag_contract_id NUMBER
   ,p_end_date       DATE
   ,p_start_date     DATE DEFAULT NULL
  ) RETURN NUMBER IS
    var_return NUMBER := 0;
  BEGIN
  
    SELECT COUNT(ph.policy_header_id)
      INTO var_return
      FROM ven_ag_contract_header ch_2
          ,ven_ag_contract ac_2
          ,AG_CONTRACT agc_rec
          ,ven_ag_contract_header agh_rec
          ,ven_t_sales_channel h
          ,ven_p_pol_header ph
          ,ven_p_policy_agent pa
          ,ven_policy_agent_status pas
          ,(SELECT agch.last_ver_id ag_contract_id
              FROM AG_CONTRACT        agc
                  ,AG_CONTRACT_HEADER agch
             WHERE agch.ag_contract_header_id = agc.contract_id
               AND agc.ag_contract_id = p_ag_contract_id) ag_rec
     WHERE (Pkg_Agent_1.get_agent_start_contr(ph.policy_header_id) BETWEEN p_start_date AND p_end_date OR
           (p_start_date IS NULL AND
           Pkg_Agent_1.get_agent_start_contr(ph.policy_header_id) BETWEEN ch_2.date_begin AND
           p_end_date))
       AND pa.status_id = pas.policy_agent_status_id
       AND pas.brief IN ('CURRENT')
       AND ch_2.ag_contract_header_id = pa.ag_contract_header_id
       AND pa.policy_header_id = ph.policy_header_id
          -- ��� ��� �� ������
       AND ac_2.contract_recrut_id = agc_rec.ag_contract_id
       AND agh_rec.ag_contract_header_id = agc_rec.contract_id
       AND agh_rec.last_ver_id = ag_rec.ag_contract_id
       AND ch_2.last_ver_id = ac_2.ag_contract_id
       AND h.ID = ch_2.t_sales_channel_id
       AND h.brief = 'MLM';
  
    RETURN var_return;
  
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20001
                             ,'������ ���������� ���-�� ��������������� ������� ��� p_ag_contract_id: ' ||
                              p_ag_contract_id || ' ��. ������ Oracle: ' || SQLERRM(SQLCODE));
    
  END attest_count_recruit;
END Pkg_Agent_1;
/

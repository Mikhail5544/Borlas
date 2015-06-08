CREATE OR REPLACE PACKAGE pkg_rep_utils_ins11 IS

  -- Author  : MMIROVICH
  -- Created : 16.05.2007 13:21:30
  -- Purpose : ����� ��� �������, ��������������� ��� ����������

  -- Public type declarations

  -- ������� ���������� ������� �������
  -- �����: �������
  TYPE tbl_ag_number IS TABLE OF NUMBER;

  -- ������� � id ��������� (c_clam_header)
  -- � �������� �� �������� � ���� �����
  -- �����: �������
  TYPE tbl_claim_id IS TABLE OF NUMBER;

  -- ������� � id ��������� ��������� ��� �������
  -- �� �������� "�����������" � ���������� "�����"
  -- �����: �������
  TYPE tbl_ag_contract_id IS TABLE OF NUMBER;

  -- ������������� ������� � id ���������
  -- �����: �������
  TYPE tbl_id IS TABLE OF NUMBER;

  TYPE tbl_id_test IS TABLE OF NUMBER;

  -- ������ � ������ "�������� ��������/������ ������",
  --"id ��������"," brief ������ ������"
  -- �����: �������
  TYPE ag_ch_rec IS RECORD(
     NAME     VARCHAR2(150)
    ,ag_id    NUMBER
    ,ch_brief VARCHAR2(100));

  -- ������� � ������ "�������� ��������/������ ������",
  --"id ��������"," brief ������ ������"
  -- �����: �������
  TYPE tbl_ag_ch IS TABLE OF ag_ch_rec;

  -- ������ � ������ "id ��������", "id ������", "��� ������","id ���������", 
  -- "���������","brief ������ ������", "����� ������"
  -- �����: �������
  TYPE agents_chanales_rec IS RECORD(
     pol_id   NUMBER
    ,ag_id    NUMBER
    ,ag_fio   VARCHAR2(250)
    ,dep_id   NUMBER
    ,dep_name VARCHAR2(150)
    ,ch_br    VARCHAR2(30)
    ,ch_name  VARCHAR2(150));

  -- ������� ������� agents_chanales_rec
  -- �����: �������
  TYPE tbl_agents_chanales IS TABLE OF agents_chanales_rec;

  -- ������ � ������ "id ������", "��� ������","id ���������", 
  -- "���������","brief ������ ������", "����� ������", "brief ��������","�������"
  -- �����: �������
  TYPE ag_ch_pr_rec IS RECORD(
     ag_id    NUMBER
    ,ag_fio   VARCHAR2(250)
    ,dep_id   NUMBER
    ,dep_name VARCHAR2(150)
    ,ch_br    VARCHAR2(30)
    ,ch_name  VARCHAR2(150)
    ,pr_br    VARCHAR2(30)
    ,pr_name  VARCHAR2(250));

  -- ������� ������� ag_ch_pr_rec
  -- �����: �������
  TYPE tbl_ag_ch_pr IS TABLE OF ag_ch_pr_rec;

  -- ������ � ������ "id ��������",
  --"brief ��������","�������� ��������"
  -- �����: �������
  TYPE pol_prod_rec IS RECORD(
     pol_id  NUMBER
    ,pr_br   VARCHAR2(30)
    ,pr_name VARCHAR2(150));

  -- ������� � ������ ""id ��������",
  --"brief ��������","�������� ��������"
  -- �����: �������
  TYPE tbl_pol_prod IS TABLE OF pol_prod_rec;

  -- Public constant declarations

  -- Public variable declarations

  -- Public function and procedure declarations

  /**
  * ���������� ������ ���� "������ - �����������"
  * ���� ��� ���������, �� ������ "������"
  *  @autor Mirovich M.
  *  @param ag_id - �� ������ ��������,
   * @return - ����
  */
  FUNCTION get_pol_agency_name(p_dep_id NUMBER) RETURN VARCHAR2;

  /**
  * ���������� ���� ��������� ���������� �������� �� �� ������ ��������
  * (���� ������� "����������", "������", "�������")
  *  @autor Mirovich M.
  *  @param ag_id - �� ������ ��������,
   * @return - ����
  */
  FUNCTION get_ag_contract_end_date(ag_id NUMBER) RETURN DATE;

  /**
  * ���������� ���������� �������, ������� � ��������� ������ ����
  *  @autor Mirovich M.
  *  @param month - �����,
  *  @param month - ���,
   * @return - ����������
  */
  FUNCTION get_agent_number
  (
    MONTH VARCHAR2
   ,YEAR  VARCHAR2
  ) RETURN NUMBER;

  /**
  * ���������� ���������� �������, ������� � ��������� ������ ����
  * � �������� �� ������� � ��������� ������
  *  @autor Mirovich M.
  *  @param month - �����,
  *  @param month - ���,
  *  @param st - ������,
  *  @param cat - ���������,
   * @return - ����������
  */
  FUNCTION get_agent_number
  (
    MONTH VARCHAR2
   ,YEAR  VARCHAR2
   ,st    VARCHAR2
   ,cat   VARCHAR2
  ) RETURN NUMBER;

  /**
  * ���������� ���������� �������, ������� � ������ month_start � ��������� �� ������ month_end
  *  @autor Mirovich M.
  *  @param month_start - ����� (������ �������),
  *  @param month_end - ����� (��������� �������),
  *  @param month - ���,
   * @return - ����������
  */
  FUNCTION get_agent_drop_number
  (
    month_start VARCHAR2
   ,month_end   VARCHAR2
   ,YEAR        VARCHAR2
  ) RETURN NUMBER;

  /**
  * ���������� ���������� �������, ������� � ������ month_start � ��������� �� ������ month_end
  * � �������� �� ������� � ��������� ������
  *  @autor Mirovich M.
  *  @param month_start - ����� (������ �������),
  *  @param month_end - ����� (��������� �������),
  *  @param month - ���,
  *  @param st - ������,
  *  @param cat - ���������,
   * @return - ����������
  */
  FUNCTION get_agent_drop_number
  (
    month_start VARCHAR2
   ,month_end   VARCHAR2
   ,YEAR        VARCHAR2
   ,st          VARCHAR2
   ,cat         VARCHAR2
  ) RETURN NUMBER;

  /**
  * ���������� ���������� �������, ������� � ������ month_start
  * � ���������� �������� ������ �� ������ month_end
  *  @autor Mirovich M.
  *  @param month_start - ����� (������ �������),
  *  @param month_end - ����� (��������� �������),
  *  @param month - ���,
   * @return - ����������
  */
  FUNCTION get_agent_active
  (
    month_start VARCHAR2
   ,month_end   VARCHAR2
   ,YEAR        VARCHAR2
  ) RETURN NUMBER;

  /**
  * ���������� ���������� �������, ������� � ������ month_start
  * � ���������� �������� ������ �� ������ month_end
  * � �������� �� ������� � ��������� ������
  *  @autor Mirovich M.
  *  @param month_start - ����� (������ �������),
  *  @param month_end - ����� (��������� �������),
  *  @param month - ���,
   * @return - ����������
  */
  FUNCTION get_agent_active
  (
    month_start VARCHAR2
   ,month_end   VARCHAR2
   ,YEAR        VARCHAR2
   ,st          VARCHAR2
   ,cat         VARCHAR2
  ) RETURN NUMBER;

  /**
  * ���������� ����� ������ �� �������, ������� � ������ month_start
  * � ���������� �������� ������ �� ������ month_end
  *  @autor Mirovich M.
  *  @param month_start - ����� (������ �������),
  *  @param month_end - ����� (��������� �������),
  *  @param month - ���,
   * @return - �����
  */
  FUNCTION get_agent_sales
  (
    month_start VARCHAR2
   ,month_end   VARCHAR2
   ,YEAR        VARCHAR2
  ) RETURN NUMBER;

  /**
  * ���������� ����� ������ �� ������ ������ �� �������, ������� � ������ month_start
  * � ���������� �������� ������ �� ������ month_end
  *  @autor Mirovich M.
  *  @param month_start - ����� (������ �������),
  *  @param month_end - ����� (��������� �������),
  *  @param month - ���,
   * @return - ����� �� ������ ������
  */
  FUNCTION get_agent_sales_per
  (
    month_start VARCHAR2
   ,month_end   VARCHAR2
   ,YEAR        VARCHAR2
  ) RETURN NUMBER;

  /**
  * ���������� ����� ������ �� ������ ������ �� �������, ������� � ������ month_start
  * � ���������� �������� ������ �� ������ month_end
  * � �������� �� ������� � ��������� ������
  *  @autor Mirovich M.
  *  @param month_start - ����� (������ �������),
  *  @param month_end - ����� (��������� �������),
  *  @param month - ���,
   * @return - ����� �� ������ ������
  */
  FUNCTION get_agent_sales_per
  (
    month_start VARCHAR2
   ,month_end   VARCHAR2
   ,YEAR        VARCHAR2
   ,st          VARCHAR2
   ,cat         VARCHAR2
  ) RETURN NUMBER;

  /**
  * ���������� ����� ������� �� ������ ������ �� �������, ������� � ������ month_start
  * � ���������� �������� ������ �� ������ month_end
  *  @autor Mirovich M.
  *  @param month_start - ����� (������ �������),
  *  @param month_end - ����� (��������� �������),
  *  @param month - ���,
   * @return - ����� �� ������ ������
  */
  FUNCTION get_agent_bonus_per
  (
    month_start VARCHAR2
   ,month_end   VARCHAR2
   ,YEAR        VARCHAR2
  ) RETURN NUMBER;

  /**
  * ���������� ����� ������� �� ������ ������ �� �������, ������� � ������ month_start
  * � ���������� �������� ������ �� ������ month_end
  * � �������� �� ������� � ��������� ������
  *  @autor Mirovich M.
  *  @param month_start - ����� (������ �������),
  *  @param month_end - ����� (��������� �������),
  *  @param month - ���,
   * @return - ����� �� ������ ������
  */
  FUNCTION get_agent_bonus_per
  (
    month_start VARCHAR2
   ,month_end   VARCHAR2
   ,YEAR        VARCHAR2
   ,st          VARCHAR2
   ,cat         VARCHAR2
  ) RETURN NUMBER;

  /**
  * ���������� ����� ������ �� �������, ������� � ������ month_start
  * � ���������� �������� ������ �� ������ month_end
  * � �������� �� ������� � ��������� ������
  *  @autor Mirovich M.
  *  @param month_start - ����� (������ �������),
  *  @param month_end - ����� (��������� �������),
  *  @param month - ���,
  *  @param st - ������,
  *  @param cat - ���������,
  * @return - �����
  */
  FUNCTION get_agent_sales
  (
    month_start VARCHAR2
   ,month_end   VARCHAR2
   ,YEAR        VARCHAR2
   ,st          VARCHAR2
   ,cat         VARCHAR2
  ) RETURN NUMBER;

  /**
  * ���������� ������� ���������� �������, ������� � ������ ������ ����
  * � ���������� �������� ������ �� ������ month_end
  *  @autor Mirovich M.
   *  @param month_start - ����� (������ �������),
  *  @param month_end - ����� (��������� �������),
  *  @param month - ���,
  * @return - �����
  */
  FUNCTION get_agent_bonus
  (
    month_start VARCHAR2
   ,month_end   VARCHAR2
   ,YEAR        VARCHAR2
  ) RETURN NUMBER;

  /**
  * ���������� ����� ������ �� �������, ������� � ������ month_start
  * � ���������� �������� ������ �� ������ month_end
  * � �������� �� ������� � ��������� ������
  *  @autor Mirovich M.
  *  @param month_start - ����� (������ �������),
  *  @param month_end - ����� (��������� �������),
  *  @param month - ���,
  *  @param st - ������,
  *  @param cat - ���������,
  * @return - �����
   */
  FUNCTION get_agent_bonus
  (
    month_start VARCHAR2
   ,month_end   VARCHAR2
   ,YEAR        VARCHAR2
   ,st          VARCHAR2
   ,cat         VARCHAR2
  ) RETURN NUMBER;

  /**
  * ���������� ��� ��� ������� �� ������ �� �������, ������� � ������ month_start
  * � ���������� �������� ������ �� ������ month_end
  *  @autor Mirovich M.
  *  @param month_start - ����� (������ �������),
  *  @param month_end - ����� (��������� �������),
  * @return - ����� ��� % �� ������
   */
  FUNCTION get_agent_bonus_sales
  (
    month_start VARCHAR2
   ,month_end   VARCHAR2
   ,YEAR        VARCHAR2
  ) RETURN NUMBER;
  /**
  * ���������� ��� ��� ������� ��  ������ �� �������, ������� � ������ month_start
  * � ���������� �������� ������ �� ������ month_end
  * � �������� �� ������� � ��������� ������
  *  @autor Mirovich M.
  *  @param month_start - ����� (������ �������),
  *  @param month_end - ����� (��������� �������),
  *  @param month - ���,
  *  @param st - ������,
  *  @param cat - ���������,
  * @return - ����� ��� ������� � ������
   */
  FUNCTION get_agent_bonus_sales
  (
    month_start VARCHAR2
   ,month_end   VARCHAR2
   ,YEAR        VARCHAR2
   ,st          VARCHAR2
   ,cat         VARCHAR2
  ) RETURN NUMBER;

  /**
  * ���������� ������� ���������� �������, ������� � ������ ������ ����
  * � ���������� �������� ������ �� ������ month_end
  *  @autor Mirovich M.
  *  @param month - �����,
  *  @param month - ���,
  * @return - �������
  */
  FUNCTION get_agent_active_year
  (
    MONTH VARCHAR2
   ,YEAR  VARCHAR2
  ) RETURN tbl_ag_number
    PIPELINED;

  /**
  * ���������� ������� � id ��������� ��������� ��� ������� �
  * ��������� �������� � ����������
  *  @autor Mirovich M.
  *  @param month - �����,
  *  @param month - ���,
  * @return - �������
  */
  FUNCTION get_ag_contract_id
  (
    st  VARCHAR2
   ,cat VARCHAR2
  ) RETURN tbl_ag_contract_id
    PIPELINED;

  /**
  * ���������� ����� ������, �������������� ������� �� col �������
  * ������������� ������� ��� ������ Tracking Report 1
  *  @autor Mirovich M.
  *  @param month - �����,
  *  @param year - ���,
  *  @param col - ���������� �������,
   * @return - ����� ������ (������)
  */
  FUNCTION get_prev_month
  (
    DATA DATE
   ,COL  NUMBER
  ) RETURN VARCHAR2;
  /**
  * ���������� ������� ����������� ������� �� ������ � month_start �� month_end
  * �������� �� ������ � month_start
  * ������������� ������� ��� ������ Tracking Report 1
  *  @autor Mirovich M.
  *  @param month_start - ����� (������ �������),
  *  @param month_end - ����� (��������� �������),
  * @return - �������
  */
  FUNCTION get_agent_drop_percent
  (
    month_start VARCHAR2
   ,month_end   VARCHAR2
   ,YEAR        VARCHAR2
  ) RETURN NUMBER;

  /**
  * ���������� ������� ����������� ������� �� ������ � month_start �� month_end
  * �������� �� ������ � month_start
  * � �������� �� ������� � ��������� ������
  * ������������� ������� ��� ������ Tracking Report 1
  *  @autor Mirovich M.
  *  @param month_start - ����� (������ �������),
  *  @param month_end - ����� (��������� �������),
  * @return - �������
  */
  FUNCTION get_agent_drop_percent
  (
    month_start VARCHAR2
   ,month_end   VARCHAR2
   ,YEAR        VARCHAR2
   ,st          VARCHAR2
   ,cat         VARCHAR2
  ) RETURN NUMBER;

  /**
  * ��������� ��������� ������ ������� ��� ������������ ������ Tracking Report 1
  * ������������� ������� ��� ������ Tracking Report 1
  *  @autor Mirovich M.
  *  @param tyear - ���,
  *  @param tmonth - �����,
  */
  PROCEDURE create_month_tr1
  (
    tmonth VARCHAR2
   ,tyear  VARCHAR2
  );

  /**
  * ��������� ��������� ������ ������� ��� ������������ ������ Tracking Report 1
  * � �������� �� ���������� � ������� ������
  * ������������� ������� ��� ������ Tracking Report 1
  *  @autor Mirovich M.
  *  @param tyear - ���,
  *  @param tmonth - �����,
  *  @param st - ������,
  *  @param cat - ���������,
  */
  PROCEDURE create_month_tr1
  (
    tmonth VARCHAR2
   ,tyear  VARCHAR2
   ,st     VARCHAR2
   ,cat    VARCHAR2
  );

  -------------------------------------------------------------------------------
  -------------------------------------------------------------------------------
  ------------------------- ����� � ��������� ��������
  -------------------------------------------------------------------------------
  -------------------------------------------------------------------------------
  /**
  * ���������� �����, � ������� ������� ���������� � ������� ���
  *  @autor Mirovich M.
  *  @param pol_id - id ������ ��������
  * @return - ����� �����
  */

  FUNCTION get_month_agent_dav(pol_id NUMBER) RETURN DATE;

  -------------------------------------------------------------------------------
  -------------------------------------------------------------------------------
  ------------------------- ����� TRACKING REPORT 2
  -------------------------------------------------------------------------------
  -------------------------------------------------------------------------------
  /**
  * ���������� ���������� �������, ������������ � ������� ������
   *  @autor Mirovich M.
   *  @param month - �����
   *  @param year - ���
   *  @return - ���������� �������
  */
  FUNCTION get_agency_number
  (
    MONTH VARCHAR2
   ,YEAR  VARCHAR2
  ) RETURN NUMBER;

  /**
  * ���������� ������� � id ������� ��� ������� ����� ������� �����, ����� ������
  *  @autor Mirovich M.
  *  @return - ������� � is �������
  */
  FUNCTION get_part_time_id RETURN tbl_ag_contract_id
    PIPELINED;

  /**
  * ���������� ������� � id ������� ��� ������� ����� ����� ������
  *  @autor Mirovich M.
  *  @param chanal - ����� ������
  *  @return - ������� � is �������
  */
  FUNCTION get_ag_chanal_id(chanal VARCHAR2) RETURN tbl_ag_contract_id
    PIPELINED;

  /**
  * ���������� ������� � id ������� ��� ���� ������� ������
  * ����� ����������, �����������, ����������� � call - ������
  *  @autor Mirovich M.
  *  @param chanal - ����� ������
  *  @return - ������� � is �������
  */
  FUNCTION get_ag_other_chanal_id RETURN tbl_ag_contract_id
    PIPELINED;

  /**
  * ���������� ���������� ������� Part time, ���������� � ��������� ����� � ���
   *  @autor Mirovich M.
   *  @param month - �����
   *  @param year - ���
   *  @return - ���������� ������� Part timr
  */
  FUNCTION get_ag_part_time_num
  (
    MONTH VARCHAR2
   ,YEAR  VARCHAR2
  ) RETURN NUMBER;

  /**
  * ���������� ���������� ������� , ���������� � ��������� ����� � ���
  * � �������� �� ������� � ��������� ������
   *  @autor Mirovich M.
   *  @param month - �����
   *  @param year - ���
   *  @return - ���������� �������
  */
  FUNCTION get_ag_st_cat_num
  (
    MONTH VARCHAR2
   ,YEAR  VARCHAR2
   ,st    VARCHAR2
   ,cat   VARCHAR2
  ) RETURN NUMBER;

  /**
  * ���������� ���������� ������� , ��������� � ��������� ������ ����
  * � �������� �� ������� � ��������� ������
   *  @autor Mirovich M.
   *  @param month - �����
   *  @param year - ���
   *  @param st - ������
   *  @param cat - ���������
   *  @return - ���������� ��������� �������
  */
  FUNCTION get_agent_drop_number
  (
    MONTH VARCHAR2
   ,YEAR  VARCHAR2
   ,st    VARCHAR2
   ,cat   VARCHAR2
  ) RETURN NUMBER;

  /**
  * ���������� ���������� ������� PT, ��������� � ��������� ������ ����
   *  @autor Mirovich M.
   *  @param month - �����
   *  @param year - ���
   *  @return - ���������� ��������� �������
  */
  FUNCTION get_ag_drop_part_time
  (
    MONTH VARCHAR2
   ,YEAR  VARCHAR2
  ) RETURN NUMBER;

  /**
  * ���������� ���������� ������� , ��������� ��������� � ��������� ������
  *  @autor Mirovich M.
   *  @param month - �����
   *  @param year - ���
   *  @param cat_old - ��������� � ������ �������
   *  @param cat_new - ��������� � ����� ������
   *  @param st - ������ ������ � ������ �������
   *  @return - ���������� �������, ��������� ���������
  */
  FUNCTION get_ag_change_cat_num
  (
    MONTH   VARCHAR2
   ,YEAR    VARCHAR2
   ,cat_old VARCHAR2
   ,cat_new VARCHAR2
   ,st      VARCHAR2
  ) RETURN NUMBER;

  /**
  * ���������� ����� ������ �� ������� � ��������� ���������� � ��������
  *  @autor Mirovich M.
   *  @param month - �����
   *  @param year - ���
   *  @param cat - ��������� � ������ �������
   *  @param st - ������ ������ � ������ �������
   *  @return - ����� ������
  */
  FUNCTION get_agent_sales
  (
    MONTH VARCHAR2
   ,YEAR  VARCHAR2
   ,st    VARCHAR2
   ,cat   VARCHAR2
  ) RETURN NUMBER;

  /**
  * ���������� ����� ������ �� ������� � ����������� ������ � ������ ����
  *  @autor Mirovich M.
   *  @param month - �����
   *  @param year - ���
   *  @param cat - ��������� � ������ �������
   *  @param st - ������ ������ � ������ �������
   *  @return - ����� ������
  */
  FUNCTION get_agent_sales_ytd
  (
    MONTH VARCHAR2
   ,YEAR  VARCHAR2
   ,st    VARCHAR2
   ,cat   VARCHAR2
  ) RETURN NUMBER;

  /**
  * ���������� ����� ������ �� ������� PT
  *  @autor Mirovich M.
  *  @param month - �����
  *  @param year - ���
  *  @return - ����� ������
  */
  FUNCTION get_ag_sales_part_time
  (
    MONTH VARCHAR2
   ,YEAR  VARCHAR2
  ) RETURN NUMBER;

  /**
  * ���������� ����� ������ �� ������� � ��������� ������� ������
  *  @autor Mirovich M.
  *  @param month - �����
  *  @param year - ���
  *  @param chanal - ����� ������
  *  @return - ����� ������
  */
  FUNCTION get_ag_sales_chanal
  (
    MONTH  VARCHAR2
   ,YEAR   VARCHAR2
   ,chanal VARCHAR2
  ) RETURN NUMBER;

  /**
  * ���������� ����� ������ ��� ���� ������� ������
  * ����� ����������, �����������,����������� � call - ������
  *  @autor Mirovich M.
  *  @param month - �����
  *  @param year - ���
  *  @return - ����� ������
  */
  FUNCTION get_ag_sales_other_chanal
  (
    MONTH VARCHAR2
   ,YEAR  VARCHAR2
  ) RETURN NUMBER;

  /**
  * ���������� ����� ������ �� ������� PT � ����������� ������ � ������ ����
  *  @autor Mirovich M.
  *  @param month - �����
  *  @param year - ���
  *  @return - ����� ������
  */
  FUNCTION get_ag_sales_part_time_ytd
  (
    MONTH VARCHAR2
   ,YEAR  VARCHAR2
  ) RETURN NUMBER;

  /**
  * ���������� ����� ������ �� ������� � ��������� ������� ������
  * � ����������� ������ � ������ ����
  *  @autor Mirovich M.
  *  @param month - �����
  *  @param year - ���
  *  @param chanal - ����� ������
  *  @return - ����� ������
  */
  FUNCTION get_ag_sales_chanal_ytd
  (
    MONTH  VARCHAR2
   ,YEAR   VARCHAR2
   ,chanal VARCHAR2
  ) RETURN NUMBER;

  /**
  * ���������� ����� ������ ��� ���� ������� ������
  * ����� ����������, �����������,����������� � call - ������
  * � ����������� ������ � ������ ����
  *  @autor Mirovich M.
  *  @param month - �����
  *  @param year - ���
  *  @return - ����� ������
  */
  FUNCTION get_ag_sales_other_chanal_ytd
  (
    MONTH VARCHAR2
   ,YEAR  VARCHAR2
  ) RETURN NUMBER;

  /**
  * ���������� ����� ������ �� ��� ����� ����������
  *  @autor Mirovich M.
  *  @param month - �����
  *  @param year - ���
  *  @return - ����� ������
  */
  FUNCTION get_sales_um_groop
  (
    MONTH VARCHAR2
   ,YEAR  VARCHAR2
  ) RETURN NUMBER;

  /**
  * ���������� ����� ������ �� ��� ����� ���������� � ����������� ������ � ������ ����
  *  @autor Mirovich M.
  *  @param month - �����
  *  @param year - ���
  *  @return - ����� ������
  */
  FUNCTION get_sales_um_groop_ytd
  (
    MONTH VARCHAR2
   ,YEAR  VARCHAR2
  ) RETURN NUMBER;

  /**
  * �������� �������� ������ Tracking Report - 2
  *  @autor Mirovich M.
  *  @param month - �����
  *  @param year - ���
  */
  PROCEDURE create_month_tr2
  (
    tmonth VARCHAR2
   ,tyear  VARCHAR2
  );

  -------------------------------------------------------------------------------
  -------------------------------------------------------------------------------
  ------------------------- NEW and EXISTING BUSINESS REPORT
  -------------------------------------------------------------------------------
  -------------------------------------------------------------------------------
  /**
  * ���������� ������� � id  ���������
  * ��� ����������� ��������� ��� ������ ������
   *  @autor Mirovich M.
   *  @param dep_id - �� ���������
   *  @param ch_br - ����� ������
   *  @return - ���������� ���������
  */
  FUNCTION get_pol_dep_ch_id
  (
    dep_id NUMBER
   ,ch_br  VARCHAR2
  ) RETURN tbl_id
    PIPELINED;

  /**
  * ���������� ���������� ���������, ������������������ � ��������� ������
  * ��� ����������� ��������� ��� ������ ������
   *  @autor Mirovich M.
   *  @param dleft - ������ �������
   *  @param dright - ��������� �������
   *  @param depart_id - �� ���������
   *  @param chanal - ����� ������
   *  @return - ���������� ���������
  */
  FUNCTION get_notice_num
  (
    dleft     DATE
   ,dright    DATE
   ,depart_id VARCHAR2
   ,chanal    VARCHAR2
  ) RETURN NUMBER;

  /**
  * ���������� ����� ������ �� ����������, ������������������ � ��������� ������
   * ��� ����������� ��������� ��� ������ ������
   *  @autor Mirovich M.
   *  @param dleft - ������ �������
   *  @param dright - ��������� �������
   *  @param depart_id - �� ���������
   *  @param chanal - ����� ������
   *  @return - ������ �� ����������
  */
  FUNCTION get_notice_premium
  (
    dleft     DATE
   ,dright    DATE
   ,depart_id VARCHAR2
   ,chanal    VARCHAR2
  ) RETURN NUMBER;

  /**
  * ���������� ���������� �������, ������� ��������� � ��������� ������
   * ��� ����������� ��������� ��� ������ ������
   *  @autor Mirovich M.
   *  @param dleft - ������ �������
   *  @param dright - ��������� �������
   *  @param depart_id - �� ���������
   *  @param chanal - ����� ������
   *  @return - ������ �� ����������
  */
  FUNCTION get_pol_active_num
  (
    dleft     DATE
   ,dright    DATE
   ,depart_id VARCHAR2
   ,chanal    VARCHAR2
  ) RETURN NUMBER;

  /**
  * ���������� ����� ������ �� �������, �������� ��������� � ��������� ������
   * ��� ����������� ��������� ��� ������ ������
   *  @autor Mirovich M.
   *  @param dleft - ������ �������
   *  @param dright - ��������� �������
   *  @param depart_id - �� ���������
   *  @param chanal - ����� ������
   *  @return - ������ �� ����������
  */
  FUNCTION get_pol_active_premium
  (
    dleft     DATE
   ,dright    DATE
   ,depart_id VARCHAR2
   ,chanal    VARCHAR2
  ) RETURN NUMBER;

  /**
  * ���������� ���������� ���������, ������������������ � ��������� ������
  * � ������� "������" ��� "��������� � �����������"
  * ��� ����������� ��������� ��� ������ ������
   *  @autor Mirovich M.
   *  @param dleft - ������ �������
   *  @param dright - ��������� �������
   *  @param depart_id - �� ���������
   *  @param chanal - ����� ������
   *  @return - ���������� ���������
  */
  FUNCTION get_notice_outside_num
  (
    dleft     DATE
   ,dright    DATE
   ,depart_id VARCHAR2
   ,chanal    VARCHAR2
  ) RETURN NUMBER;

  /**
  * ���������� ����� ������ �� ����������, ������������������ � ��������� ������
  * � ������� "������" ��� "��������� � �����������"
   * ��� ����������� ��������� ��� ������ ������
   *  @autor Mirovich M.
   *  @param dleft - ������ �������
   *  @param dright - ��������� �������
   *  @param depart_id - �� ���������
   *  @param chanal - ����� ������
   *  @return - ������ �� ����������
  */
  FUNCTION get_notice_outside_premium
  (
    dleft     DATE
   ,dright    DATE
   ,depart_id VARCHAR2
   ,chanal    VARCHAR2
  ) RETURN NUMBER;

  /**
  * ���������� ���������� �������, ��������� ������� � ��������� ������
  * ��� ����������� ��������� ��� ������ ������
   *  @autor Mirovich M.
   *  @param dleft - ������ �������
   *  @param dright - ��������� �������
   *  @param depart_id - �� ���������
   *  @param chanal - ����� ������
   *  @return - ���������� ���������
  */
  FUNCTION get_agent_have_sales_num
  (
    dleft     DATE
   ,dright    DATE
   ,depart_id VARCHAR2
   ,chanal    VARCHAR2
  ) RETURN NUMBER;

  /**
  * ���������� ���������� �������, ����������� �� ����� �������
  * ��� ����������� ��������� ��� ������ ������
   *  @autor Mirovich M.
   *  @param dright - ��������� �������
   *  @param depart_id - �� ���������
   *  @param chanal - ����� ������
   *  @return - ���������� ���������
  */
  FUNCTION get_total_agent_number
  (
    dright    DATE
   ,depart_id VARCHAR2
   ,chanal    VARCHAR2
  ) RETURN NUMBER;

  /**
  * ���������� ���������� �������, ����������� �� ����� �������
  * ��� ����������� ��������� ��� ������ ������
   *  @autor Mirovich M.
   *  @param dright - ��������� �������
   *  @param depart_id - �� ���������
   *  @param chanal - ����� ������
   *  @return - ���������� ���������
  */
  FUNCTION get_list_departments_chanals(dright DATE) RETURN tbl_ag_ch
    PIPELINED;

  /**
  * �������� ���������� ������ � ������� rep_neb
  *  @autor Mirovich M.
  *  @param fday - ����
  *  @param fperiod - ������
  *  @param fregion - ������ / ����� ������
  *  @param fblock - �������� �����
  *  @param fparam - �������� ���������
  *  @param fvalue - �������� ���������
  */
  PROCEDURE insert_row_to_rep_neb
  (
    fday    DATE
   ,fperiod VARCHAR2
   ,fregion VARCHAR2
   ,fblock  VARCHAR2
   ,fparam  VARCHAR2
   ,fvalue  NUMBER
  );

  /**
   * �������� ���������� ������ ������� rep_neb
   *  @autor Mirovich M.
  *  @param fday - ����
   *  @param fperiod - ������
   *  @param fregion - ������ / ����� ������
   *  @param fblock - �������� �����
   *  @param fparam - �������� ���������
   *  @param fvalue - �������� ���������
   */
  PROCEDURE update_row_to_rep_neb
  (
    fday    DATE
   ,fperiod VARCHAR2
   ,fregion VARCHAR2
   ,fblock  VARCHAR2
   ,fparam  VARCHAR2
   ,fvalue  NUMBER
  );

  /**
  * �������� ������������ ������ New and Existing Business report �� ����
  * ��������� ������ ������� rep_neb
  *  @autor Mirovich M.
  *  @param d - ����, �� ������� ����������� �����
  */

  PROCEDURE create_day_neb(dright DATE);

  PROCEDURE create_day_neb2(dright DATE);

  -------------------------------------------------------------------------------
  -------------------------------------------------------------------------------
  ------------------------- �������������� ����� �� ��������
  -------------------------------------------------------------------------------
  -------------------------------------------------------------------------------

  /**
  * ���������� id ��������� (c_claim_header)
  * � �������� �� �������� � ���� �����
  * @autor Mirovich M.
  * @param br - ���� �����
  * @param rtype - ��� �����
  * @return - ������� � id ���������
  */
  FUNCTION get_claim_header_id
  (
    br    VARCHAR2
   ,rtype VARCHAR2
  ) RETURN tbl_claim_id
    PIPELINED;

  /**
  * ���������� ���������� ���������, ����������� � �������� � ��������� ������
  * � �������� �� �������� � ���� �����
  * @autor Mirovich M.
  * @param br - ���� �����
  * @param rtype - ��� �����
  * @param dleft - ������ �������
  * @param dright - ��������� �������
  * @return - ���������� ���
  */
  FUNCTION get_claim_number
  (
    br     VARCHAR2
   ,rtype  VARCHAR2
   ,dleft  DATE
   ,dright DATE
  ) RETURN NUMBER;

  /**
  * ���������� ���������� ���������, ����������� � �������� � ��������� ���
  * � ���������� � ��������� ������
  * � �������� �� �������� � ���� �����
  * @autor Mirovich M.
  * @param br - ���� �����
  * @param rtype - ��� �����
  * @param dleft - ������ �������
  * @param dright - ��������� �������
  * @return - ���������� ���
  */
  FUNCTION get_claim_pay_number
  (
    br     VARCHAR2
   ,rtype  VARCHAR2
   ,YEAR   VARCHAR2
   ,dleft  DATE
   ,dright DATE
  ) RETURN NUMBER;

  /**
  * ���������� ����������� ����� �� ���������� , ����������� � �������� � ��������� ���
  * � ���������� � ��������� ������
  * � �������� �� �������� � ���� �����
  * @autor Mirovich M.
  * @param br - ���� �����
  * @param rtype - ��� �����
  * @param dleft - ������ �������
  * @param dright - ��������� �������
  * @return - ����������� ����� �� ����������
  */
  FUNCTION get_claim_pay_amount
  (
    br     VARCHAR2
   ,rtype  VARCHAR2
   ,YEAR   VARCHAR2
   ,dleft  DATE
   ,dright DATE
  ) RETURN NUMBER;

  /**
  * ���������� ���������� ���������, ����������� � �������� � ��������� ������
  * � �������� �� �������� � ���� �����
  * @autor Mirovich M.
  * @param br - ���� �����
  * @param rtype - ��� �����
  * @param year - ���
  * @return - ���������� ��� �� ������������
  */
  FUNCTION get_claim_pending_number
  (
    br    VARCHAR2
   ,rtype VARCHAR2
   ,YEAR  VARCHAR2
  ) RETURN NUMBER;

  /**
  * ���������� ����� ���������� �������, ����������� � �������� � ��������� ������
  * � �������� �� �������� � ���� �����
  * @autor Mirovich M.
  * @param br - ���� �����
  * @param rtype - ��� �����
  * @param year - ���
  * @return - ���������� �����
  */
  FUNCTION get_panding_claims_amount
  (
    br    VARCHAR2
   ,rtype VARCHAR2
   ,YEAR  VARCHAR2
  ) RETURN NUMBER;

  /**
  * ���������� ���������� ���������� �������, ����������� � �������� � ��������� ������
  * � �������� �� �������� � ���� �����
  * @autor Mirovich M.
  * @param br - ���� �����
  * @param rtype - ��� �����
  * @param year - ���
  * @param dleft - ������ �������
  * @param dleft - ��������� �������
  * @return - ���������� �������, � ������� ��������
  */
  FUNCTION get_rejected_claims_number
  (
    br     VARCHAR2
   ,rtype  VARCHAR2
   ,YEAR   VARCHAR2
   ,dleft  DATE
   ,dright DATE
  ) RETURN NUMBER;

  /**
  * ���������� ����� ��  �������, ���������� � ��������� ������
  * � �������� �� �������� � ���� �����
  * @autor Mirovich M.
  * @param br - ���� �����
  * @param rtype - ��� �����
  * @param dleft - ������ �������
  * @param dleft - ��������� �������
  * @return - ����� �� �������, � ������� ��������
  */
  FUNCTION get_rejected_claims_amount
  (
    br     VARCHAR2
   ,rtype  VARCHAR2
   ,dleft  DATE
   ,dright DATE
  ) RETURN NUMBER;

  /**
  * ��������� ������ � ������� ins_dwh.rep_payoff
  * @autor Mirovich M.
  * @param fyear - ���
  * @param fmonth - �����
  * @param frisk_type -  ��� �����
  * @param frisk - �������� �����
  * @param fparam - �������� 
  * @param fvalue - �������� ���������
  * @param frisk_brief - ���������� �����
  * @param ftype_brief - ���������� ����
  */
  PROCEDURE insert_row_to_rep_payoff
  (
    fyear       VARCHAR2
   ,fmonth      VARCHAR2
   ,frisk_type  VARCHAR2
   ,frisk       VARCHAR2
   ,fparam      VARCHAR2
   ,fvalue      NUMBER
   ,frisk_brief VARCHAR2
   ,ftype_brief VARCHAR2
  );
  /**
  * ��������� ������ � ������� ins_dwh.rep_payoff
  * @autor Mirovich M.
  * @param fyear - ���
  * @param fmonth - �����
  * @param fparam - �������� 
  * @param fvalue - �������� ���������
  * @param frisk_brief - ���������� �����
  * @param ftype_brief - ���������� ����
  */
  PROCEDURE update_row_to_rep_payoff
  (
    fyear       VARCHAR2
   ,fmonth      VARCHAR2
   ,fparam      VARCHAR2
   ,fvalue      NUMBER
   ,frisk_brief VARCHAR2
   ,ftype_brief VARCHAR2
  );

  /**
  * ��������� ��� ������ � ������� ins_dwh.rep_payoff ��� ������ �����
  * @autor Mirovich M.
  * @param month - �����
  * @param year - ���
  * @param frisk - �������� �����
  * @param frisk_br - ���������� �����
  * @param ft_gr - ���������� ���� �����
  */
  PROCEDURE insert_rep_payoff
  (
    tmonth   VARCHAR2
   ,tyear    VARCHAR2
   ,frisk    VARCHAR2
   ,frisk_br VARCHAR2
   ,ft_gr    VARCHAR2
  );

  /**
  * ��������� ��� ������ � ������� ins_dwh.rep_payoff ��� ������ �����
  * @autor Mirovich M.
  * @param month - �����
  * @param year - ���
  * @param frisk_br - ���������� �����
  * @param ft_gr - ���������� ���� �����
  */
  PROCEDURE update_rep_payoff
  (
    tmonth   VARCHAR2
   ,tyear    VARCHAR2
   ,frisk_br VARCHAR2
   ,ft_gr    VARCHAR2
  );
  /**
  * �������� ������������ ������ "�������������� ����� �� ��������"
  * ���������� ������� ins_dwh.rep_payoff
  * @autor Mirovich M.
  * @param month- �����
  * @param year - ���
  */
  PROCEDURE create_month_payoff
  (
    tmonth VARCHAR2
   ,tyear  VARCHAR2
  );

  -------------------------------------------------------------------------------
  -------------------------------------------------------------------------------
  ------------------------- SALES REPORT (WITHOUT PROGRAMM)
  -------------------------------------------------------------------------------
  -------------------------------------------------------------------------------

  /**
  * ���������� id ��������� ������, ������������ �������
  * @autor Mirovich M.
  * @param p_pol_h_id- �� ��������� ��������
  * @return  - �� ���������� ��������
  */
  FUNCTION get_agch_id_by_polid(p_pol_h_id NUMBER) RETURN NUMBER;
  /**
  * ���������� id ���������, ������������ �������
  * @autor Mirovich M.
  * @param p_pol_h_id- �� ��������� ��������
  * @return  - �� ���������
  */
  FUNCTION get_dep_id_by_polid(p_pol_header_id NUMBER) RETURN NUMBER;

  /**
  * ���������� id ���������, �� �������� ���������� �����
  * @autor Mirovich M.
  * @param p_agent_id - �� ������
  * @return  - �� ���������
  */
  FUNCTION get_dep_id_by_agid(p_agent_id NUMBER) RETURN NUMBER;

  /**
  * ���������� ������� � ����������� �� ���������, ����������� � ��������� ������
  * � ��������� ������, ��������, ������ ������ � ��������
  * @autor Mirovich M.
  * @param dleft - ������ �������
  * @param dright - ��������� �������
  * @return  - ������� � ����������
  */
  FUNCTION get_tbl_ag_ch_pr
  (
    dleft  DATE
   ,dright DATE
  ) RETURN tbl_ag_ch_pr
    PIPELINED;

  /**
  * ���������� ����� APE �� ����������� ��������� 
  * @autor Mirovich M.
  * @param dleft - ������ �������
  * @param dright - ��������� �������
  * @param ag_id - id ������
  * @param dep_id - id �������� 
  * @param ch_br - ���������� ������ ������
  * @param pr_br - ���������� ��������
  * @return  - ����� APE
  */
  FUNCTION get_ape_policy
  (
    dleft  DATE
   ,dright DATE
   ,ag_id  NUMBER
   ,dep_id NUMBER
   ,ch_br  VARCHAR2
   ,pr_br  VARCHAR2
  ) RETURN NUMBER;
  /**
  * ���������� ����� APE �� ������������ ��������� 
  * @autor Mirovich M.
  * @param dleft - ������ �������
  * @param dright - ��������� �������
  * @param ag_id - id ������
  * @param dep_id - id �������� 
  * @param ch_br - ���������� ������ ������
  * @param pr_br - ���������� ��������
  * @return  - ����� APE
  */
  FUNCTION get_ape_pol_dec
  (
    dleft  DATE
   ,dright DATE
   ,ag_id  NUMBER
   ,dep_id NUMBER
   ,ch_br  VARCHAR2
   ,pr_br  VARCHAR2
  ) RETURN NUMBER;

  /**
  * ���������� ����� APE �� ������������ ��������� �� ���� �������
  * @autor Mirovich M.
  * @param dleft - ������ �������
  * @param dright - ��������� �������
  * @param ag_id - id ������
  * @param dep_id - id �������� 
  * @param ch_br - ���������� ������ ������
  * @param pr_br - ���������� ��������
  * @return  - ����� APE
  */
  FUNCTION get_ape_pol_dec_oth
  (
    dleft  DATE
   ,dright DATE
   ,ag_id  NUMBER
   ,dep_id NUMBER
   ,ch_br  VARCHAR2
   ,pr_br  VARCHAR2
  ) RETURN NUMBER;

  /**
  * ���������� ����� APE �� �������� ��������� 
  * @autor Mirovich M.
  * @param dleft - ������ �������
  * @param dright - ��������� �������
  * @param ag_id - id ������
  * @param dep_id - id �������� 
  * @param ch_br - ���������� ������ ������
  * @param pr_br - ���������� ��������
  * @return  - ����� APE
  */
  FUNCTION get_ape_pol_act
  (
    dleft  DATE
   ,dright DATE
   ,ag_id  NUMBER
   ,dep_id NUMBER
   ,ch_br  VARCHAR2
   ,pr_br  VARCHAR2
  ) RETURN NUMBER;

  /**
  * ���������� ����� ����� ���������� ������ �� ����������� ���������
  * @autor Mirovich M.
  * @param dleft - ������ �������
  * @param dright - ��������� �������
  * @param ag_id - id ������
  * @param dep_id - id �������� 
  * @param ch_br - ���������� ������ ������
  * @param pr_br - ���������� ��������
  * @return  - ����� ���������� ������
  */
  FUNCTION get_pol_pay_amount
  (
    dleft  DATE
   ,dright DATE
   ,ag_id  NUMBER
   ,dep_id NUMBER
   ,ch_br  VARCHAR2
   ,pr_br  VARCHAR2
  ) RETURN NUMBER;

  /**
  * ���������� ����� ����� ���������� ������ �� �������� ���������
  * @autor Mirovich M.
  * @param dleft - ������ �������
  * @param dright - ��������� �������
  * @param ag_id - id ������
  * @param dep_id - id �������� 
  * @param ch_br - ���������� ������ ������
  * @param pr_br - ���������� ��������
  * @return  - ����� ���������� ������
  */
  FUNCTION get_pol_pay_amount_act
  (
    dleft  DATE
   ,dright DATE
   ,ag_id  NUMBER
   ,dep_id NUMBER
   ,ch_br  VARCHAR2
   ,pr_br  VARCHAR2
  ) RETURN NUMBER;
  /**
  * ���������� ����� ����� �������� �� ������������ ���������
  * @autor Mirovich M.
  * @param dleft - ������ �������
  * @param dright - ��������� �������
  * @param ag_id - id ������
  * @param dep_id - id �������� 
  * @param ch_br - ���������� ������ ������
  * @param pr_br - ���������� ��������
  * @return  - ����� ��������
  */
  FUNCTION get_pol_dec_amount
  (
    dleft  DATE
   ,dright DATE
   ,ag_id  NUMBER
   ,dep_id NUMBER
   ,ch_br  VARCHAR2
   ,pr_br  VARCHAR2
  ) RETURN NUMBER;

  /**
  * ���������� ����� ����� �������� �� ������������ ��������� �� ���� ��������
  * @autor Mirovich M.
  * @param dleft - ������ �������
  * @param dright - ��������� �������
  * @param ag_id - id ������
  * @param dep_id - id �������� 
  * @param ch_br - ���������� ������ ������
  * @param pr_br - ���������� ��������
  * @return  - ����� ��������
  */
  FUNCTION get_pol_dec_amount_oth
  (
    dleft  DATE
   ,dright DATE
   ,ag_id  NUMBER
   ,dep_id NUMBER
   ,ch_br  VARCHAR2
   ,pr_br  VARCHAR2
  ) RETURN NUMBER;

  /**
  * ��������� ������� ������������ "id ������ - id ������"
  * @autor Mirovich M.
  * @param dleft - ������ �������
  * @param dright - ��������� �������
  */
  PROCEDURE fill_tbl_pol_ag
  (
    dleft  DATE
   ,dright DATE
  );

  /**
  * ���������� ������� � ����������, ����������� � ������
  * @autor Mirovich M.
  * @param dleft - ������ �������
  * @param dright - ��������� �������
  * @param ag_id - id ������
  * @param dep_id - id �������� 
  * @param ch_br - ���������� ������ ������
  * @param pr_br - ���������� ��������
  * @return  - ������� � id ���������
  */

  FUNCTION get_policy_id
  (
    dleft  DATE
   ,dright DATE
   ,ag_id  NUMBER
   ,dep_id NUMBER
   ,ch_br  VARCHAR2
   ,pr_br  VARCHAR2
  ) RETURN tbl_id
    PIPELINED;

  /**
  * ���������� ������� � ����������, ����������� � ����������� � ������
  * @autor Mirovich M.
  * @param dleft - ������ �������
  * @param dright - ��������� �������
  * @return  - ������� � id ���������
  */
  FUNCTION get_pol_active_id
  (
    dleft  DATE
   ,dright DATE
   ,ag_id  NUMBER
   ,dep_id NUMBER
   ,ch_br  VARCHAR2
   ,pr_br  VARCHAR2
  ) RETURN tbl_id
    PIPELINED;

  /**
  * ���������� id ���������, �����������  � ������������ � ��������� ������
  * �� ����������� �������������� ��� ��������� ������������
  * @autor Mirovich M.
  * @param dleft - ������ �������
  * @param dright - ��������� �������
  * @return  - ������� � id ���������
  */
  FUNCTION get_pol_dec_anderr_id
  (
    dleft  DATE
   ,dright DATE
   ,ag_id  NUMBER
   ,dep_id NUMBER
   ,ch_br  VARCHAR2
   ,pr_br  VARCHAR2
  ) RETURN tbl_id
    PIPELINED;

  /**
  * ���������� id ���������, �����������  � ������������ � ��������� ������
  * �� ���� ��������
  * @autor Mirovich M.
  * @param dleft - ������ �������
  * @param dright - ��������� �������
  * @return  - ������� � id ���������
  */
  FUNCTION get_pol_dec_other_id
  (
    dleft  DATE
   ,dright DATE
   ,ag_id  NUMBER
   ,dep_id NUMBER
   ,ch_br  VARCHAR2
   ,pr_br  VARCHAR2
  ) RETURN tbl_id
    PIPELINED;

  /** ��������� ������ � ������� ins_dwh.rep_sr_wo_prog
  * @autor Mirovich M.
  * @param fchanal - ����� ������
  * @param fdep - ���������
  * @param fagent - �����
  * @param fprod - �������
  * @param fparam - ��������
  * @param fvalue - �������� ���������
  */
  PROCEDURE insert_row_to_sr_wo
  (
    fchanal VARCHAR2
   ,fdep    VARCHAR2
   ,fagent  VARCHAR2
   ,fprod   VARCHAR2
   ,fparam  VARCHAR2
   ,fvalue  NUMBER
  );

  /**
  * ������� �������� �������� ������ Sales Report � ������������ �� ��������
  * ���������� ������� ins_dwh.rep_sr_wo_prog
  * @autor Mirovich M.
  * @param dleft - ������ �������
  * @param dright - ��������� �������
  */
  PROCEDURE create_period_sr_wo
  (
    dleft  DATE
   ,dright DATE
  );

  -------------------------------------------------------------------------------
  -------------------------------------------------------------------------------
  ------------------------- SALES REPORT (WITH PROGRAMM)
  -------------------------------------------------------------------------------
  -------------------------------------------------------------------------------

  /**
  * ���������� ������� � ����������� �� ���������, ����������� � ��������� ������
  * � ��������� ������, ��������, ������ ������ � ���������
  * @autor Mirovich M.
  * @param dleft - ������ �������
  * @param dright - ��������� �������
  * @return  - ������� � ����������
  */
  FUNCTION get_tbl_ag_ch_progr
  (
    dleft  DATE
   ,dright DATE
  ) RETURN tbl_ag_ch_pr
    PIPELINED;

  /**
  * ���������� ����� APE �� ����������� ��������� 
  * @autor Mirovich M.
  * @param dleft - ������ �������
  * @param dright - ��������� �������
  * @param ag_id - id ������
  * @param dep_id - id �������� 
  * @param ch_br - ���������� ������ ������
  * @param pr_br - ���������� ���������
  * @return  - ����� APE
  */
  FUNCTION get_ape_policy_pr
  (
    dleft  DATE
   ,dright DATE
   ,ag_id  NUMBER
   ,dep_id NUMBER
   ,ch_br  VARCHAR2
   ,pr_br  VARCHAR2
  ) RETURN NUMBER;
  /**
  * ���������� ����� APE �� ������������ ��������� 
  * @autor Mirovich M.
  * @param dleft - ������ �������
  * @param dright - ��������� �������
  * @param ag_id - id ������
  * @param dep_id - id �������� 
  * @param ch_br - ���������� ������ ������
  * @param pr_br - ���������� ���������
  * @return  - ����� APE
  */
  FUNCTION get_ape_pol_dec_pr
  (
    dleft  DATE
   ,dright DATE
   ,ag_id  NUMBER
   ,dep_id NUMBER
   ,ch_br  VARCHAR2
   ,pr_br  VARCHAR2
  ) RETURN NUMBER;

  /**
  * ���������� ����� APE �� ������������ ��������� �� ���� �������
  * @autor Mirovich M.
  * @param dleft - ������ �������
  * @param dright - ��������� �������
  * @param ag_id - id ������
  * @param dep_id - id �������� 
  * @param ch_br - ���������� ������ ������
  * @param pr_br - ���������� ���������
  * @return  - ����� APE
  */
  FUNCTION get_ape_pol_dec_oth_pr
  (
    dleft  DATE
   ,dright DATE
   ,ag_id  NUMBER
   ,dep_id NUMBER
   ,ch_br  VARCHAR2
   ,pr_br  VARCHAR2
  ) RETURN NUMBER;

  /**
  * ���������� ����� APE �� �������� ��������� 
  * @autor Mirovich M.
  * @param dleft - ������ �������
  * @param dright - ��������� �������
  * @param ag_id - id ������
  * @param dep_id - id �������� 
  * @param ch_br - ���������� ������ ������
  * @param pr_br - ���������� ���������
  * @return  - ����� APE
  */
  FUNCTION get_ape_pol_act_pr
  (
    dleft  DATE
   ,dright DATE
   ,ag_id  NUMBER
   ,dep_id NUMBER
   ,ch_br  VARCHAR2
   ,pr_br  VARCHAR2
  ) RETURN NUMBER;

  /**
  * ���������� ����� ����� ���������� ������ �� ����������� ���������
  * @autor Mirovich M.
  * @param dleft - ������ �������
  * @param dright - ��������� �������
  * @param ag_id - id ������
  * @param dep_id - id �������� 
  * @param ch_br - ���������� ������ ������
  * @param pr_br - ���������� ���������
  * @return  - ����� ���������� ������
  */
  FUNCTION get_pol_pay_amount_pr
  (
    dleft  DATE
   ,dright DATE
   ,ag_id  NUMBER
   ,dep_id NUMBER
   ,ch_br  VARCHAR2
   ,pr_br  VARCHAR2
  ) RETURN NUMBER;

  /**
  * ���������� ����� ����� ���������� ������ �� �������� ���������
  * @autor Mirovich M.
  * @param dleft - ������ �������
  * @param dright - ��������� �������
  * @param ag_id - id ������
  * @param dep_id - id �������� 
  * @param ch_br - ���������� ������ ������
  * @param pr_br - ���������� ���������
  * @return  - ����� ���������� ������
  */
  FUNCTION get_pol_pay_amount_act_pr
  (
    dleft  DATE
   ,dright DATE
   ,ag_id  NUMBER
   ,dep_id NUMBER
   ,ch_br  VARCHAR2
   ,pr_br  VARCHAR2
  ) RETURN NUMBER;
  /**
  * ���������� ����� ����� �������� �� ������������ ���������
  * @autor Mirovich M.
  * @param dleft - ������ �������
  * @param dright - ��������� �������
  * @param ag_id - id ������
  * @param dep_id - id �������� 
  * @param ch_br - ���������� ������ ������
  * @param pr_br - ���������� ���������
  * @return  - ����� ��������
  */
  FUNCTION get_pol_dec_amount_pr
  (
    dleft  DATE
   ,dright DATE
   ,ag_id  NUMBER
   ,dep_id NUMBER
   ,ch_br  VARCHAR2
   ,pr_br  VARCHAR2
  ) RETURN NUMBER;

  /**
  * ���������� ����� ����� �������� �� ������������ ��������� �� ���� ��������
  * @autor Mirovich M.
  * @param dleft - ������ �������
  * @param dright - ��������� �������
  * @param ag_id - id ������
  * @param dep_id - id �������� 
  * @param ch_br - ���������� ������ ������
  * @param pr_br - ���������� ���������
  * @return  - ����� ��������
  */
  FUNCTION get_pol_dec_amount_oth_pr
  (
    dleft  DATE
   ,dright DATE
   ,ag_id  NUMBER
   ,dep_id NUMBER
   ,ch_br  VARCHAR2
   ,pr_br  VARCHAR2
  ) RETURN NUMBER;

  /**
  * ���������� ������� � ����������, ������������ � ������
  * @autor Mirovich M.
  * @param dleft - ������ �������
  * @param dright - ��������� �������
  * @param ag_id - id ������
  * @param dep_id - id �������� 
  * @param ch_br - ���������� ������ ������
  * @param pr_br - ���������� ���������
  * @return  - ������� � id ���������
  */

  FUNCTION get_policy_id_pr
  (
    dleft  DATE
   ,dright DATE
   ,ag_id  NUMBER
   ,dep_id NUMBER
   ,ch_br  VARCHAR2
   ,pr_br  VARCHAR2
  ) RETURN tbl_id
    PIPELINED;

  /**
  * ���������� ������� � ����������, ����������� � ����������� � ������
  * @autor Mirovich M.
  * @param dleft - ������ �������
  * @param dright - ��������� �������
  * @param ag_id - id ������
  * @param dep_id - id �������� 
  * @param ch_br - ���������� ������ ������
  * @param pr_br - ���������� ���������
  * @return  - ������� � id ���������
  */
  FUNCTION get_pol_active_id_pr
  (
    dleft  DATE
   ,dright DATE
   ,ag_id  NUMBER
   ,dep_id NUMBER
   ,ch_br  VARCHAR2
   ,pr_br  VARCHAR2
  ) RETURN tbl_id
    PIPELINED;

  /**
  * ���������� id ���������, �����������  � ������������ � ��������� ������
  * �� ����������� �������������� ��� ��������� ������������
  * @autor Mirovich M.
  * @param dleft - ������ �������
  * @param dright - ��������� �������
  * @param ag_id - id ������
  * @param dep_id - id �������� 
  * @param ch_br - ���������� ������ ������
  * @param pr_br - ���������� ���������
  * @return  - ������� � id ���������
  */
  FUNCTION get_pol_dec_anderr_id_pr
  (
    dleft  DATE
   ,dright DATE
   ,ag_id  NUMBER
   ,dep_id NUMBER
   ,ch_br  VARCHAR2
   ,pr_br  VARCHAR2
  ) RETURN tbl_id
    PIPELINED;

  /**
  * ���������� id ���������, �����������  � ������������ � ��������� ������
  * �� ���� ��������
  * @autor Mirovich M.
  * @param dleft - ������ �������
  * @param dright - ��������� �������
  * @param ag_id - id ������
  * @param dep_id - id �������� 
  * @param ch_br - ���������� ������ ������
  * @param pr_br - ���������� ���������
  * @return  - ������� � id ���������
  */
  FUNCTION get_pol_dec_other_id_pr
  (
    dleft  DATE
   ,dright DATE
   ,ag_id  NUMBER
   ,dep_id NUMBER
   ,ch_br  VARCHAR2
   ,pr_br  VARCHAR2
  ) RETURN tbl_id
    PIPELINED;

  /** ��������� ������ � ������� ins_dwh.rep_sr_prog
  * @autor Mirovich M.
  * @param fchanal - ����� ������
  * @param fdep - ���������
  * @param fagent - �����
  * @param fprog - ���������
  * @param fparam - ��������
  * @param fvalue - �������� ���������
  */
  PROCEDURE insert_row_to_sr_prog
  (
    fchanal VARCHAR2
   ,fdep    VARCHAR2
   ,fagent  VARCHAR2
   ,fprog   VARCHAR2
   ,fparam  VARCHAR2
   ,fvalue  NUMBER
  );

  /**
  * ������� �������� �������� ������ Sales Report � ������������ �� ���������
  * ���������� ������� ins_dwh.rep_sr_prog
  * @autor Mirovich M.
  * @param dleft - ������ �������
  * @param dright - ��������� �������
  */
  PROCEDURE create_period_sr_prog
  (
    dleft  DATE
   ,dright DATE
  );

  /*
  \** ��� ����� NewBusines EndOfMonth
  *\
  procedure create_endmonth (dleft date, dright date);
  
  \** ��� ����� NewBusines NextMonth
  *\
  procedure create_nextmonth (dleft date, dright date);
  
  \** ��� ����� NewBusines CurrentMonth
  *\
  procedure create_currentmonth (dleft date, dright date);
  */

  /**
  * ��������� �������� �������� ������ Sales Report
  * @autor Mirovich M.
  * @param dleft - ������ �������
  * @param dright - ��������� �������
  */
  PROCEDURE create_period_sales_report
  (
    dleft  DATE
   ,dright DATE
  );

  -------------------------------------------------------------------------------
  -------------------------------------------------------------------------------
  ------------------------- ������ ��������
  -------------------------------------------------------------------------------
  -------------------------------------------------------------------------------
  /**
  * ������� �������� �������� ������ Tracking Report-1 � ����������� ������
  * @autor Mirovich M.
  * @param p_work_date - ���� ������
  * @param p_error_msg - ��������� � ������
  * @return - ������� ������
  */
  FUNCTION f_rep_tr_1
  (
    p_work_date IN DATE
   ,p_error_msg OUT VARCHAR2
  ) RETURN NUMBER;

  /**
  * ������� �������� �������� ������ Tracking Report-2 � ����������� ������
  * @autor Mirovich M.
  * @param p_work_date - ���� ������
  * @param p_error_msg - ��������� � ������
  * @return - ������� ������
  */
  FUNCTION f_rep_tr_2
  (
    p_work_date IN DATE
   ,p_error_msg OUT VARCHAR2
  ) RETURN NUMBER;
  /**
  * ������� �������� �������� ������ New and Exsisting Business Report � ����������� ������
  * @autor Mirovich M.
  * @param p_work_date - ���� ������
  * @param p_error_msg - ��������� � ������
  * @return - ������� ������
  */
  FUNCTION f_rep_neb
  (
    p_work_date IN DATE
   ,p_error_msg OUT VARCHAR2
  ) RETURN NUMBER;

  /**
  * ������� �������� �������� ������ �������������� ����� �� �������� � ����������� ������
  * @autor Mirovich M.
  * @param p_work_date - ���� ������
  * @param p_error_msg - ��������� � ������
  * @return - ������� ������
  */
  FUNCTION f_rep_payoff
  (
    p_work_date IN DATE
   ,p_error_msg OUT VARCHAR2
  ) RETURN NUMBER;

END;
/
CREATE OR REPLACE PACKAGE BODY pkg_rep_utils_ins11 IS

  -- Private type declarations

  -- Private constant declarations

  -- Private variable declarations

  -- Function and procedure implementations

  -- ************************************************************************
  --///////////////////////// ����� �������///////////////////////////////
  -- ************************************************************************

  FUNCTION get_pol_agency_name(p_dep_id NUMBER) RETURN VARCHAR2 IS
    v_agency_name VARCHAR2(1000);
    temp_dep      VARCHAR2(1000);
    temp_agency   VARCHAR2(1000);
  BEGIN
    SELECT ot.NAME
          ,d.NAME
      INTO temp_agency
          ,temp_dep
      FROM ins.ven_department        d
          ,ins.ven_organisation_tree ot
     WHERE d.department_id = p_dep_id
       AND ot.ORGANISATION_TREE_ID = d.ORG_TREE_ID;
    IF temp_agency = temp_dep
    THEN
      v_agency_name := temp_dep;
    ELSE
      v_agency_name := temp_agency || ' - ' || temp_dep;
    END IF;
    RETURN v_agency_name;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN NULL;
  END;

  -- ************************************************************************
  --/////////////////////////TRACKING REPORT 1///////////////////////////////
  -- ************************************************************************
  -- ���������� ���� ��������� ���������� ��������
  FUNCTION get_ag_contract_end_date(ag_id NUMBER) RETURN DATE IS
    DATA DATE;
  BEGIN
    SELECT MAX(ds.start_date)
      INTO DATA
      FROM ins.ven_doc_status     ds
          ,ins.ven_doc_status_ref dsr
     WHERE dsr.doc_status_ref_id = ds.doc_status_ref_id
       AND ds.document_id = ag_id
       AND dsr.brief IN ('BREAK', 'CLOSE', 'CANCEL', 'STOPED');
  
    RETURN(DATA);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  -- ���������� ���������� �������, ������� � ��������� ����� � ���
  FUNCTION get_agent_number
  (
    MONTH VARCHAR2
   ,YEAR  VARCHAR2
  ) RETURN NUMBER IS
    COL NUMBER;
  BEGIN
    SELECT COUNT(agch.agent_id)
      INTO COL
      FROM ins.ven_ag_contract_header agch
     WHERE TO_CHAR(agch.date_begin, 'yyyy') = TO_CHAR(TO_DATE(YEAR, 'yyyy'), 'yyyy')
       AND TO_CHAR(agch.date_begin, 'mm') = TO_CHAR(TO_DATE(MONTH, 'mm'), 'mm');
    RETURN(COL);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
  END;
  --/*
  -- ���������� ���������� �������, ������� � ��������� ����� � ���
  -- � �������� �� ������� � ��������� ������
  FUNCTION get_agent_number
  (
    MONTH VARCHAR2
   ,YEAR  VARCHAR2
   ,st    VARCHAR2
   ,cat   VARCHAR2
  ) RETURN NUMBER IS
    COL NUMBER;
  BEGIN
    SELECT COUNT(agch.agent_id)
      INTO COL
      FROM ins.ven_ag_contract_header agch
      JOIN (SELECT * FROM TABLE(pkg_rep_utils_ins11.get_ag_contract_id(st, cat))) agch_id
        ON agch.ag_contract_header_id = agch_id.COLUMN_VALUE
     WHERE TO_CHAR(agch.date_begin, 'yyyy') = TO_CHAR(TO_DATE(YEAR, 'yyyy'), 'yyyy')
       AND TO_CHAR(agch.date_begin, 'mm') = TO_CHAR(TO_DATE(MONTH, 'mm'), 'mm');
    RETURN(COL);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
  END;

  --*/
  -- ���������� ���������� �������, ������� � ������ month_start � ��������� �� ������ month_end
  FUNCTION get_agent_drop_number
  (
    month_start VARCHAR2
   ,month_end   VARCHAR2
   ,YEAR        VARCHAR2
  ) RETURN NUMBER IS
    COL NUMBER;
  BEGIN
    SELECT COUNT(agch.agent_id)
      INTO COL
      FROM ins.ven_ag_contract_header agch
      JOIN ins.ven_ag_contract agc
        ON agc.ag_contract_id = agch.last_ver_id
     WHERE TO_CHAR(agch.date_begin, 'yyyy') = TO_CHAR(TO_DATE(YEAR, 'yyyy'), 'yyyy')
       AND TO_CHAR(agch.date_begin, 'mm') = TO_CHAR(TO_DATE(month_start, 'mm'), 'mm')
       AND TO_CHAR(get_ag_contract_end_date(agc.ag_contract_id), 'mm') <
           TO_CHAR(TO_DATE(month_end, 'mm'), 'mm')
       AND TO_CHAR(get_ag_contract_end_date(agc.ag_contract_id), 'yyyy') =
           TO_CHAR(TO_DATE(YEAR, 'yyyy'), 'yyyy');
    RETURN(COL);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
  END;

  -- ���������� ���������� �������, ������� � ������ month_start � ��������� �� ������ month_end
  -- � �������� �� ������� � ��������� ������
  FUNCTION get_agent_drop_number
  (
    month_start VARCHAR2
   ,month_end   VARCHAR2
   ,YEAR        VARCHAR2
   ,st          VARCHAR2
   ,cat         VARCHAR2
  ) RETURN NUMBER IS
    COL NUMBER;
  BEGIN
    SELECT COUNT(agch.agent_id)
      INTO COL
      FROM ins.ven_ag_contract_header agch
      JOIN ins.ven_ag_contract agc
        ON agc.ag_contract_id = agch.last_ver_id
      JOIN (SELECT * FROM TABLE(pkg_rep_utils_ins11.get_ag_contract_id(st, cat))) agch_id
        ON agch.ag_contract_header_id = agch_id.COLUMN_VALUE
     WHERE TO_CHAR(agch.date_begin, 'yyyy') = TO_CHAR(TO_DATE(YEAR, 'yyyy'), 'yyyy')
       AND TO_CHAR(agch.date_begin, 'mm') = TO_CHAR(TO_DATE(month_start, 'mm'), 'mm')
       AND TO_CHAR(get_ag_contract_end_date(agc.ag_contract_id), 'mm') <
           TO_CHAR(TO_DATE(month_end, 'mm'), 'mm')
       AND TO_CHAR(get_ag_contract_end_date(agc.ag_contract_id), 'yyyy') =
           TO_CHAR(TO_DATE(YEAR, 'yyyy'), 'yyyy');
    RETURN(COL);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
  END;

  -- ���������� ���������� �������, �������� � ������ month_start
  -- � ���������� �������� ������ �� ������ month_end
  FUNCTION get_agent_active
  (
    month_start VARCHAR2
   ,month_end   VARCHAR2
   ,YEAR        VARCHAR2
  ) RETURN NUMBER IS
    COL         NUMBER;
    ag_col      NUMBER; -- ���������� �������� �������
    ag_drop_col NUMBER; -- ���������� ��������� �������
  BEGIN
    IF month_start IS NOT NULL
    THEN
      ag_col      := (NVL(get_agent_number(TO_CHAR(TO_DATE(month_start, 'mm'), 'mm')
                                          ,TO_CHAR(TO_DATE(YEAR, 'yyyy'), 'yyyy'))
                         ,0));
      ag_drop_col := NVL(get_agent_drop_number(TO_CHAR(TO_DATE(month_start, 'mm'), 'mm')
                                              ,TO_CHAR(TO_DATE(month_end, 'mm'), 'mm')
                                              ,TO_CHAR(TO_DATE(YEAR, 'yyyy'), 'yyyy'))
                        ,0);
      COL         := ag_col - ag_drop_col;
    ELSE
      COL := NULL;
    END IF;
    RETURN(COL);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  -- ���������� ���������� �������, �������� � ������ month_start
  -- � ���������� �������� ������ �� ������ month_end
  -- � �������� �� ������� � ���������
  FUNCTION get_agent_active
  (
    month_start VARCHAR2
   ,month_end   VARCHAR2
   ,YEAR        VARCHAR2
   ,st          VARCHAR2
   ,cat         VARCHAR2
  ) RETURN NUMBER IS
    COL         NUMBER;
    ag_col      NUMBER; -- ���������� �������� �������
    ag_drop_col NUMBER; -- ���������� ��������� �������
  BEGIN
    IF month_start IS NOT NULL
    THEN
      ag_col      := (NVL(get_agent_number(TO_CHAR(TO_DATE(month_start, 'mm'), 'mm')
                                          ,TO_CHAR(TO_DATE(YEAR, 'yyyy'), 'yyyy')
                                          ,st
                                          ,cat)
                         ,0));
      ag_drop_col := NVL(get_agent_drop_number(TO_CHAR(TO_DATE(month_start, 'mm'), 'mm')
                                              ,TO_CHAR(TO_DATE(month_end, 'mm'), 'mm')
                                              ,TO_CHAR(TO_DATE(YEAR, 'yyyy'), 'yyyy')
                                              ,st
                                              ,cat)
                        ,0);
      COL         := ag_col - ag_drop_col;
    ELSE
      COL := NULL;
    END IF;
    RETURN(COL);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  -- ���������� ����� ������ �� �������, �������� � ������ month_start
  -- � ���������� �������� ������ �� ������ month_end
  FUNCTION get_agent_sales
  (
    month_start VARCHAR2
   ,month_end   VARCHAR2
   ,YEAR        VARCHAR2
  ) RETURN NUMBER IS
    SALES NUMBER(11, 2); -- ����� ������
    str   STRING(10);
    d     DATE;
  BEGIN
    str := '01.' || month_end || '.' || YEAR;
    d   := TO_DATE(str, 'dd.mm.yyyy');
    IF month_start IS NOT NULL
    THEN
      SELECT NVL(SUM(ppag.part_agent / 100 * pp.premium *
                     ins.acc_new.Get_Cross_Rate_By_Id((SELECT t.rate_type_id
                                                        FROM ins.ven_rate_type t
                                                       WHERE t.brief = '��')
                                                     ,pph.fund_id
                                                     ,(SELECT f.fund_id
                                                        FROM ins.ven_fund f
                                                       WHERE f.brief = 'RUR')
                                                     ,pp.notice_date))
                ,0)
        INTO SALES
        FROM ins.ven_ag_contract_header agch
        JOIN ins.ven_ag_contract agc
          ON agc.ag_contract_id = agch.last_ver_id
        LEFT JOIN ins.ven_p_policy_agent ppag
          ON ppag.ag_contract_header_id = agch.ag_contract_header_id
        LEFT JOIN ins.ven_p_pol_header pph
          ON pph.policy_header_id = ppag.policy_header_id
        LEFT JOIN ins.ven_p_policy pp
          ON pp.pol_header_id = pph.policy_header_id
         AND pp.version_num = 1
         AND TO_CHAR(pp.notice_date, 'mm') = TO_CHAR(TO_DATE(month_end, 'mm'), 'mm')
         AND TO_CHAR(pp.notice_date, 'yyyy') = TO_CHAR(TO_DATE(YEAR, 'yyyy'), 'yyyy')
       WHERE TO_CHAR(agch.date_begin, 'yyyy') = TO_CHAR(TO_DATE(YEAR, 'yyyy'), 'yyyy')
         AND TO_CHAR(agch.date_begin, 'mm') = TO_CHAR(TO_DATE(month_start, 'mm'), 'mm')
         AND NVL(get_ag_contract_end_date(agc.ag_contract_id), LAST_DAY(d) + 1) > LAST_DAY(d);
      --or get_ag_contract_end_date(agc.ag_contract_id) is null);
    ELSE
      SALES := NULL;
    END IF;
    RETURN(TO_CHAR(SALES, '999999999D99'));
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  -- ���������� ����� ������ �� �������, �������� � ������ month_start
  -- � ���������� �������� ������ �� ������ month_end
  -- � �������� �� ������� � ��������� ������
  FUNCTION get_agent_sales
  (
    month_start VARCHAR2
   ,month_end   VARCHAR2
   ,YEAR        VARCHAR2
   ,st          VARCHAR2
   ,cat         VARCHAR2
  ) RETURN NUMBER IS
    SALES NUMBER(11, 2); -- ����� ������
    str   STRING(10);
    d     DATE;
  BEGIN
    str := '01.' || month_end || '.' || YEAR;
    d   := TO_DATE(str, 'dd.mm.yyyy');
    IF month_start IS NOT NULL
    THEN
      SELECT NVL(SUM(ppag.part_agent / 100 * pp.premium *
                     ins.acc_new.Get_Cross_Rate_By_Id((SELECT t.rate_type_id
                                                        FROM ins.ven_rate_type t
                                                       WHERE t.brief = '��')
                                                     ,pph.fund_id
                                                     ,(SELECT f.fund_id
                                                        FROM ins.ven_fund f
                                                       WHERE f.brief = 'RUR')
                                                     ,pp.notice_date))
                ,0)
        INTO SALES
        FROM ins.ven_ag_contract_header agch
        JOIN ins.ven_ag_contract agc
          ON agc.ag_contract_id = agch.last_ver_id
        JOIN (SELECT * FROM TABLE(pkg_rep_utils_ins11.get_ag_contract_id(st, cat))) agch_id
          ON agch.ag_contract_header_id = agch_id.COLUMN_VALUE
        LEFT JOIN ins.ven_p_policy_agent ppag
          ON ppag.ag_contract_header_id = agch.ag_contract_header_id
        LEFT JOIN ins.ven_p_pol_header pph
          ON pph.policy_header_id = ppag.policy_header_id
        LEFT JOIN ins.ven_p_policy pp
          ON pp.pol_header_id = pph.policy_header_id
         AND pp.version_num = 1
         AND TO_CHAR(pp.notice_date, 'mm') = TO_CHAR(TO_DATE(month_end, 'mm'), 'mm')
         AND TO_CHAR(pp.notice_date, 'yyyy') = TO_CHAR(TO_DATE(YEAR, 'yyyy'), 'yyyy')
       WHERE TO_CHAR(agch.date_begin, 'yyyy') = TO_CHAR(TO_DATE(YEAR, 'yyyy'), 'yyyy')
         AND TO_CHAR(agch.date_begin, 'mm') = TO_CHAR(TO_DATE(month_start, 'mm'), 'mm')
         AND NVL(get_ag_contract_end_date(agc.ag_contract_id), LAST_DAY(d) + 1) > LAST_DAY(d);
      --or get_ag_contract_end_date(agc.ag_contract_id) is null);
    ELSE
      SALES := NULL;
    END IF;
    RETURN(TO_CHAR(SALES, '999999999D99'));
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  -- ���������� ����� ������� �� �������, �������� � ������ month_start
  -- � ���������� �������� ������ �� ������ month_end
  FUNCTION get_agent_bonus
  (
    month_start VARCHAR2
   ,month_end   VARCHAR2
   ,YEAR        VARCHAR2
  ) RETURN NUMBER IS
    bonus NUMBER(11, 2); -- ���
    str   STRING(10);
    d     DATE;
  BEGIN
    str := '01.' || month_end || '.' || YEAR;
    d   := TO_DATE(str, 'dd.mm.yyyy');
    IF month_start IS NOT NULL
    THEN
      SELECT NVL(SUM(agrd.comission_sum), 0)
        INTO bonus
        FROM ins.ven_ag_contract_header agch
        JOIN ins.ven_ag_contract agc
          ON agc.ag_contract_id = agch.last_ver_id
        JOIN ins.ven_agent_report agp
          ON agp.ag_contract_h_id = agch.ag_contract_header_id
        JOIN ins.ven_ag_vedom_av agv
          ON agv.ag_vedom_av_id = agp.ag_vedom_av_id
         AND TO_CHAR(agv.date_begin, 'mm') = TO_CHAR(TO_DATE(month_end, 'mm'), 'mm')
         AND TO_CHAR(agv.date_begin, 'yyyy') = TO_CHAR(TO_DATE(YEAR, 'yyyy'), 'yyyy')
        JOIN ins.ven_t_ag_av tagv
          ON agv.t_ag_av_id = tagv.t_ag_av_id
         AND tagv.brief = '���'
        JOIN ins.ven_agent_report_dav agrd
          ON agp.agent_report_id = agrd.agent_report_id
       WHERE TO_CHAR(agch.date_begin, 'yyyy') = TO_CHAR(TO_DATE(YEAR, 'yyyy'), 'yyyy')
         AND TO_CHAR(agch.date_begin, 'mm') = TO_CHAR(TO_DATE(month_start, 'mm'), 'mm')
         AND NVL(get_ag_contract_end_date(agc.ag_contract_id), LAST_DAY(d) + 1) > LAST_DAY(d);
      --or get_ag_contract_end_date(agc.ag_contract_id) is null);
    ELSE
      bonus := NULL;
    END IF;
    RETURN(TO_CHAR(bonus, '999999999D99'));
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  -- ���������� ����� ������� �� �������, �������� � ������ month_start
  -- � ���������� �������� ������ �� ������ month_end
  -- � �������� �� ������� � ��������� ������
  FUNCTION get_agent_bonus
  (
    month_start VARCHAR2
   ,month_end   VARCHAR2
   ,YEAR        VARCHAR2
   ,st          VARCHAR2
   ,cat         VARCHAR2
  ) RETURN NUMBER IS
    bonus NUMBER(11, 2); -- ���
    str   STRING(10);
    d     DATE;
  BEGIN
    str := '01.' || month_end || '.' || YEAR;
    d   := TO_DATE(str, 'dd.mm.yyyy');
    IF month_start IS NOT NULL
    THEN
      SELECT NVL(SUM(agrd.comission_sum), 0)
        INTO bonus
        FROM ins.ven_ag_contract_header agch
        JOIN ins.ven_ag_contract agc
          ON agc.ag_contract_id = agch.last_ver_id
        JOIN (SELECT * FROM TABLE(pkg_rep_utils_ins11.get_ag_contract_id(st, cat))) agch_id
          ON agch.ag_contract_header_id = agch_id.COLUMN_VALUE
        JOIN ins.ven_agent_report agp
          ON agp.ag_contract_h_id = agch.ag_contract_header_id
        JOIN ins.ven_ag_vedom_av agv
          ON agv.ag_vedom_av_id = agp.ag_vedom_av_id
         AND TO_CHAR(agv.date_begin, 'mm') = TO_CHAR(TO_DATE(month_end, 'mm'), 'mm')
         AND TO_CHAR(agv.date_begin, 'yyyy') = TO_CHAR(TO_DATE(YEAR, 'yyyy'), 'yyyy')
        JOIN ins.ven_t_ag_av tagv
          ON agv.t_ag_av_id = tagv.t_ag_av_id
         AND tagv.brief = '���'
        JOIN ins.ven_agent_report_dav agrd
          ON agp.agent_report_id = agrd.agent_report_id
       WHERE TO_CHAR(agch.date_begin, 'yyyy') = TO_CHAR(TO_DATE(YEAR, 'yyyy'), 'yyyy')
         AND TO_CHAR(agch.date_begin, 'mm') = TO_CHAR(TO_DATE(month_start, 'mm'), 'mm')
         AND NVL(get_ag_contract_end_date(agc.ag_contract_id), LAST_DAY(d) + 1) > LAST_DAY(d);
      --or get_ag_contract_end_date(agc.ag_contract_id) is null);
    ELSE
      bonus := NULL;
    END IF;
    RETURN(TO_CHAR(bonus, '999999999D99'));
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  -- ���������� ���������� �������, �������� � ������ month_start
  -- � ���������� �������� ������ �� ������ month_end
  --type tbl_ag_number is table of number;
  FUNCTION get_agent_active_year
  (
    MONTH VARCHAR2
   ,YEAR  VARCHAR2
  ) RETURN tbl_ag_number
    PIPELINED IS
  BEGIN
    FOR i IN 1 .. 11
    LOOP
      PIPE ROW(get_agent_active(get_prev_month(TO_DATE(MONTH, 'mm'), i * (-1)), MONTH, YEAR));
    END LOOP;
    RETURN;
  END;

  -- ���������� ������� � id ��������� ��������� ��� ������� �
  -- ��������� �������� � ����������
  FUNCTION get_ag_contract_id
  (
    st  VARCHAR2
   ,cat VARCHAR2
  ) RETURN tbl_ag_contract_id
    PIPELINED IS
  BEGIN
    FOR ag_rec IN (SELECT agch.*
                     FROM ins.ven_ag_contract_header agch
                     JOIN ins.ven_ag_stat_hist sth
                       ON sth.ag_contract_header_id = agch.ag_contract_header_id
                     JOIN (SELECT t.ag_contract_header_id tid
                                ,MAX(num) tnum
                            FROM ins.ven_ag_stat_hist t
                           GROUP BY t.ag_contract_header_id) tbl
                       ON sth.ag_contract_header_id = tbl.tid
                      AND sth.num = tbl.tnum
                     JOIN ins.ven_ag_stat_agent agst
                       ON agst.ag_stat_agent_id = sth.ag_stat_agent_id
                     JOIN ins.ven_ag_category_agent agCat
                       ON agCat.Ag_Category_Agent_Id = sth.ag_category_agent_id
                    WHERE agst.brief LIKE st
                      AND agCat.Brief LIKE cat)
    LOOP
      PIPE ROW(ag_rec.ag_contract_header_id);
    END LOOP;
    RETURN;
  END;

  -- ���������� ����� ������, �������������� ������� �� col �������
  FUNCTION get_prev_month
  (
    DATA DATE
   ,COL  NUMBER
  ) RETURN VARCHAR2 IS
    m VARCHAR2(2);
  BEGIN
    IF (TO_CHAR(ADD_MONTHS(DATA, COL), 'yyyy') = TO_CHAR(DATA, 'yyyy'))
    THEN
      m := TO_CHAR(ADD_MONTHS(DATA, COL), 'mm');
    ELSE
      m := NULL;
    END IF;
    RETURN(m);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  -- ���������� ������� ����������� ������� �� ������ � month_start �� month_end
  -- �������� �� ������ � month_start
  FUNCTION get_agent_drop_percent
  (
    month_start VARCHAR2
   ,month_end   VARCHAR2
   ,YEAR        VARCHAR2
  ) RETURN NUMBER IS
    per         NUMBER(5, 2);
    ag_col      NUMBER; -- ���������� �������� �������
    ag_drop_col NUMBER; -- ���������� ��������� �������
  BEGIN
    IF month_start IS NOT NULL
    THEN
      ag_col      := (NVL(get_agent_number(TO_CHAR(TO_DATE(month_start, 'mm'), 'mm')
                                          ,TO_CHAR(TO_DATE(YEAR, 'yyyy'), 'yyyy'))
                         ,0));
      ag_drop_col := NVL(get_agent_drop_number(TO_CHAR(TO_DATE(month_start, 'mm'), 'mm')
                                              ,TO_CHAR(TO_DATE(month_end, 'mm'), 'mm')
                                              ,TO_CHAR(TO_DATE(YEAR, 'yyyy'), 'yyyy'))
                        ,0);
      IF ag_col > 0
      THEN
        per := (ag_drop_col / ag_col) * 100;
      ELSE
        per := 0;
      END IF;
    ELSE
      per := NULL;
    END IF;
    RETURN(TO_CHAR((per), '999D99'));
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  -- ���������� ������� ����������� ������� �� ������ � month_start �� month_end
  -- �������� �� ������ � month_start
  -- � �������� �� ������� � ���������
  FUNCTION get_agent_drop_percent
  (
    month_start VARCHAR2
   ,month_end   VARCHAR2
   ,YEAR        VARCHAR2
   ,st          VARCHAR2
   ,cat         VARCHAR2
  ) RETURN NUMBER IS
    per         NUMBER(5, 2);
    ag_col      NUMBER; -- ���������� �������� �������
    ag_drop_col NUMBER; -- ���������� ��������� �������
  BEGIN
    IF month_start IS NOT NULL
    THEN
      ag_col      := (NVL(get_agent_number(TO_CHAR(TO_DATE(month_start, 'mm'), 'mm')
                                          ,TO_CHAR(TO_DATE(YEAR, 'yyyy'), 'yyyy')
                                          ,st
                                          ,cat)
                         ,0));
      ag_drop_col := NVL(get_agent_drop_number(TO_CHAR(TO_DATE(month_start, 'mm'), 'mm')
                                              ,TO_CHAR(TO_DATE(month_end, 'mm'), 'mm')
                                              ,TO_CHAR(TO_DATE(YEAR, 'yyyy'), 'yyyy')
                                              ,st
                                              ,cat)
                        ,0);
      IF ag_col > 0
      THEN
        per := (ag_drop_col / ag_col) * 100;
      ELSE
        per := 0;
      END IF;
    ELSE
      per := NULL;
    END IF;
    RETURN(TO_CHAR((per), '999D99'));
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  -- ���������� ����� ������ �� ������ ������, �� ������� �� ������ � month_start �� month_end
  -- �������� �� ������ � month_start
  FUNCTION get_agent_sales_per
  (
    month_start VARCHAR2
   ,month_end   VARCHAR2
   ,YEAR        VARCHAR2
  ) RETURN NUMBER IS
    per      NUMBER(11, 2);
    ag_col   NUMBER; -- ���������� �������� �������
    ag_sales NUMBER; -- ����� ������ �� �������
  BEGIN
    IF month_start IS NOT NULL
    THEN
      ag_col   := (NVL(get_agent_number(TO_CHAR(TO_DATE(month_start, 'mm'), 'mm')
                                       ,TO_CHAR(TO_DATE(YEAR, 'yyyy'), 'yyyy'))
                      ,0));
      ag_sales := NVL(get_agent_sales(TO_CHAR(TO_DATE(month_start, 'mm'), 'mm')
                                     ,TO_CHAR(TO_DATE(month_end, 'mm'), 'mm')
                                     ,TO_CHAR(TO_DATE(YEAR, 'yyyy'), 'yyyy'))
                     ,0);
      IF ag_col > 0
      THEN
        per := ag_sales / ag_col;
      ELSE
        per := 0;
      END IF;
    ELSE
      per := NULL;
    END IF;
    RETURN(TO_CHAR((per), '999999999D99'));
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  -- ���������� ����� ������ �� ������ ������, �� ������� �� ������ � month_start �� month_end
  -- �������� �� ������ � month_start
  -- � �������� �� ������� � ���������
  FUNCTION get_agent_sales_per
  (
    month_start VARCHAR2
   ,month_end   VARCHAR2
   ,YEAR        VARCHAR2
   ,st          VARCHAR2
   ,cat         VARCHAR2
  ) RETURN NUMBER IS
    per      NUMBER(11, 2);
    ag_col   NUMBER; -- ���������� �������� �������
    ag_sales NUMBER; -- ����� ������ �� �������
  BEGIN
    IF month_start IS NOT NULL
    THEN
      ag_col   := (NVL(get_agent_number(TO_CHAR(TO_DATE(month_start, 'mm'), 'mm')
                                       ,TO_CHAR(TO_DATE(YEAR, 'yyyy'), 'yyyy')
                                       ,st
                                       ,cat)
                      ,0));
      ag_sales := NVL(get_agent_sales(TO_CHAR(TO_DATE(month_start, 'mm'), 'mm')
                                     ,TO_CHAR(TO_DATE(month_end, 'mm'), 'mm')
                                     ,TO_CHAR(TO_DATE(YEAR, 'yyyy'), 'yyyy')
                                     ,st
                                     ,cat)
                     ,0);
      IF ag_col > 0
      THEN
        per := ag_sales / ag_col;
      ELSE
        per := 0;
      END IF;
    ELSE
      per := NULL;
    END IF;
    RETURN(TO_CHAR((per), '999999999D99'));
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  -- ���������� ����� ������� �� ������ ������, �� ������� �� ������ � month_start �� month_end
  -- �������� �� ������ � month_start
  FUNCTION get_agent_bonus_per
  (
    month_start VARCHAR2
   ,month_end   VARCHAR2
   ,YEAR        VARCHAR2
  ) RETURN NUMBER IS
    per      NUMBER(11, 2);
    ag_col   NUMBER; -- ���������� �������� �������
    ag_bonus NUMBER; -- ����� ������� �� �������
  BEGIN
    IF month_start IS NOT NULL
    THEN
      ag_col   := (NVL(get_agent_number(TO_CHAR(TO_DATE(month_start, 'mm'), 'mm')
                                       ,TO_CHAR(TO_DATE(YEAR, 'yyyy'), 'yyyy'))
                      ,0));
      ag_bonus := NVL(get_agent_bonus(TO_CHAR(TO_DATE(month_start, 'mm'), 'mm')
                                     ,TO_CHAR(TO_DATE(month_end, 'mm'), 'mm')
                                     ,TO_CHAR(TO_DATE(YEAR, 'yyyy'), 'yyyy'))
                     ,0);
      IF ag_col > 0
      THEN
        per := ag_bonus / ag_col;
      ELSE
        per := 0;
      END IF;
    ELSE
      per := NULL;
    END IF;
    RETURN(TO_CHAR((per), '999999999D99'));
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  -- ���������� ����� ������� �� ������ ������, �� ������� �� ������ � month_start �� month_end
  -- �������� �� ������ � month_start
  -- � �������� �� ������� � ���������
  FUNCTION get_agent_bonus_per
  (
    month_start VARCHAR2
   ,month_end   VARCHAR2
   ,YEAR        VARCHAR2
   ,st          VARCHAR2
   ,cat         VARCHAR2
  ) RETURN NUMBER IS
    per      NUMBER(11, 2);
    ag_col   NUMBER; -- ���������� �������� �������
    ag_bonus NUMBER; -- ����� ������� �� �������
  BEGIN
    IF month_start IS NOT NULL
    THEN
      ag_col   := (NVL(get_agent_number(TO_CHAR(TO_DATE(month_start, 'mm'), 'mm')
                                       ,TO_CHAR(TO_DATE(YEAR, 'yyyy'), 'yyyy')
                                       ,st
                                       ,cat)
                      ,0));
      ag_bonus := NVL(get_agent_bonus(TO_CHAR(TO_DATE(month_start, 'mm'), 'mm')
                                     ,TO_CHAR(TO_DATE(month_end, 'mm'), 'mm')
                                     ,TO_CHAR(TO_DATE(YEAR, 'yyyy'), 'yyyy')
                                     ,st
                                     ,cat)
                     ,0);
      IF ag_col > 0
      THEN
        per := ag_bonus / ag_col;
      ELSE
        per := 0;
      END IF;
    ELSE
      per := NULL;
    END IF;
    RETURN(TO_CHAR((per), '999999999D99'));
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  -- ���������� ������ ��� ������� �� ������, �� ������� �� ������ � month_start �� month_end
  -- �������� �� ������ � month_start
  FUNCTION get_agent_bonus_sales
  (
    month_start VARCHAR2
   ,month_end   VARCHAR2
   ,YEAR        VARCHAR2
  ) RETURN NUMBER IS
    per      NUMBER(5, 2);
    ag_sales NUMBER; -- ����� ������ �� �������
    ag_bonus NUMBER; -- ����� ������� �� �������
  BEGIN
    IF month_start IS NOT NULL
    THEN
      ag_sales := (NVL(get_agent_sales(TO_CHAR(TO_DATE(month_start, 'mm'), 'mm')
                                      ,TO_CHAR(TO_DATE(month_end, 'mm'), 'mm')
                                      ,TO_CHAR(TO_DATE(YEAR, 'yyyy'), 'yyyy'))
                      ,0));
      ag_bonus := NVL(get_agent_bonus(TO_CHAR(TO_DATE(month_start, 'mm'), 'mm')
                                     ,TO_CHAR(TO_DATE(month_end, 'mm'), 'mm')
                                     ,TO_CHAR(TO_DATE(YEAR, 'yyyy'), 'yyyy'))
                     ,0);
      IF ag_sales > 0
      THEN
        per := (ag_bonus / ag_sales) * 100;
      ELSE
        per := 0;
      END IF;
    ELSE
      per := NULL;
    END IF;
    RETURN(TO_CHAR((per), '999D99'));
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  -- ���������� ������ ��� ������� �� ������, �� ������� �� ������ � month_start �� month_end
  -- �������� �� ������ � month_start
  -- � �������� �� ������� � ��������� ������
  FUNCTION get_agent_bonus_sales
  (
    month_start VARCHAR2
   ,month_end   VARCHAR2
   ,YEAR        VARCHAR2
   ,st          VARCHAR2
   ,cat         VARCHAR2
  ) RETURN NUMBER IS
    per      NUMBER(5, 2);
    ag_sales NUMBER; -- ����� ������ �� �������
    ag_bonus NUMBER; -- ����� ������� �� �������
  BEGIN
    IF month_start IS NOT NULL
    THEN
      ag_sales := (NVL(get_agent_sales(TO_CHAR(TO_DATE(month_start, 'mm'), 'mm')
                                      ,TO_CHAR(TO_DATE(month_end, 'mm'), 'mm')
                                      ,TO_CHAR(TO_DATE(YEAR, 'yyyy'), 'yyyy')
                                      ,st
                                      ,cat)
                      ,0));
      ag_bonus := NVL(get_agent_bonus(TO_CHAR(TO_DATE(month_start, 'mm'), 'mm')
                                     ,TO_CHAR(TO_DATE(month_end, 'mm'), 'mm')
                                     ,TO_CHAR(TO_DATE(YEAR, 'yyyy'), 'yyyy')
                                     ,st
                                     ,cat)
                     ,0);
      IF ag_sales > 0
      THEN
        per := (ag_bonus / ag_sales) * 100;
      ELSE
        per := 0;
      END IF;
    ELSE
      per := NULL;
    END IF;
    RETURN(TO_CHAR((per), '999D99'));
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  -- ��������� �������� ������������ ������ Tracking Report - 1
  PROCEDURE create_month_tr1
  (
    tmonth VARCHAR2
   ,tyear  VARCHAR2
  ) IS
    str      STRING(10000);
    strMonth VARCHAR2(2);
    -- ������� �� ��������
    COL             NUMBER;
    col_ag          VARCHAR2(5); -- ���������� �������
    col_do          VARCHAR2(5); -- ���������� ���������
    sum_sales       VARCHAR2(10); -- ����� ������
    sum_sales_per   VARCHAR2(10); -- ����� ������ �� ������ ������
    sum_bonus       VARCHAR2(10); -- ����� �������
    sum_bonus_per   VARCHAR2(10); -- ����� ������� �� ������ ������
    sum_bonus_sales VARCHAR2(6); -- ����� ��� ������� �� ������
    -- ������� ��������
    tot_ag NUMBER := 0; -- ����� �� �������
    tot_do NUMBER := 0; -- ����� �� ���������
    tot_s  NUMBER := 0; -- ����� �� ��������
    tot_sp NUMBER := 0; -- ����� �� �������� � ������� �� 1 ������
    tot_b  NUMBER := 0; -- ����� �� �������
    tot_bp NUMBER := 0; -- ����� �� ������� � ������� �� 1 ������
    tot_bs NUMBER := 0; -- ����� �� ������� ��� �������� � ������
  
    row_month NUMBER; -- ���������� ��� �������� ������������� ������
  
  BEGIN
    -- ��������� ������������� ������
    -- ////////////////////////////////////////////////////////////////////////
    SELECT COUNT(*)
      INTO row_month
      FROM ins_dwh.rep_tr_1 tr
     WHERE tr.MONTH = tmonth
       AND tr.YEAR = tyear;
  
    IF row_month = 0
    THEN
      INSERT INTO ins_dwh.rep_tr_1 tr (YEAR, MONTH) VALUES (tyear, tmonth);
    END IF;
  
    -- ��������� ������ ������
    -- ////////////////////////////////////////////////////////////////////////////
    -- ������� "���������� ��������������� �������"
    COL := get_agent_number(tmonth, tyear);
    UPDATE ins_dwh.rep_tr_1 t
       SET t.ag_num    = COL
          ,t.ag_num_do = COL
          ,t.ag_num_s  = COL
          ,t.ag_num_sp = COL
          ,t.ag_num_b  = COL
          ,t.ag_num_bp = COL
          ,t.ag_num_bs = COL
     WHERE t.YEAR = tyear
       AND t.MONTH = tmonth;
    --/*
    -- ��������� �������, ���������� �������� ��������������� �������
    FOR i IN 1 .. TO_NUMBER(tmonth) - 1
    LOOP
      strMonth := get_prev_month(TO_DATE(tmonth, 'mm'), i * (-1));
    
      col_ag := TO_CHAR(get_agent_active(strMonth, tmonth, tyear));
      tot_ag := tot_ag + (NVL(col_ag, 0));
      IF col_ag IS NULL
      THEN
        col_ag := 'null';
      END IF;
    
      col_do := TO_CHAR(get_agent_drop_percent(strMonth, tmonth, tyear));
      tot_do := tot_do + (NVL(col_do, 0));
      IF col_do IS NULL
      THEN
        col_do := 'null';
      END IF;
    
      sum_sales := TO_CHAR(get_agent_sales(strMonth, tmonth, tyear));
      tot_s     := tot_s + (NVL(sum_sales, 0));
      IF sum_sales IS NULL
      THEN
        sum_sales := 'null';
      END IF;
    
      sum_sales_per := TO_CHAR(get_agent_sales_per(strMonth, tmonth, tyear));
      tot_sp        := tot_sp + (NVL(sum_sales_per, 0));
      IF sum_sales_per IS NULL
      THEN
        sum_sales_per := 'null';
      END IF;
    
      sum_bonus := TO_CHAR(get_agent_bonus(strMonth, tmonth, tyear));
      tot_b     := tot_b + (NVL(sum_bonus, 0));
      IF sum_bonus IS NULL
      THEN
        sum_bonus := 'null';
      END IF;
    
      sum_bonus_per := TO_CHAR(get_agent_bonus_per(strMonth, tmonth, tyear));
      tot_bp        := tot_bp + (NVL(sum_bonus_per, 0));
      IF sum_bonus_per IS NULL
      THEN
        sum_bonus_per := 'null';
      END IF;
    
      sum_bonus_sales := TO_CHAR(get_agent_bonus_sales(strMonth, tmonth, tyear));
      tot_bs          := tot_bs + (NVL(sum_bonus_sales, 0));
      IF sum_bonus_sales IS NULL
      THEN
        sum_bonus_sales := 'null';
      END IF;
    
      str := 'update ins_dwh.rep_tr_1 t set t.ag_' || (i + 1) || ' = ' || col_ag || -- ��������������� ������
             ', t.ag_do_' || (i + 1) || ' = ' || REPLACE(col_do, ',', '.') || -- ��������� ������
             ', t.ag_s_' || (i + 1) || ' = ' || REPLACE(sum_sales, ',', '.') || -- ����� ������
             ', t.ag_sp_' || (i + 1) || ' = ' || REPLACE(sum_sales_per, ',', '.') || -- ����� ������ �� 1 ������
             ', t.ag_b_' || (i + 1) || ' = ' || REPLACE(sum_bonus, ',', '.') || -- ����� �������
             ', t.ag_bp_' || (i + 1) || ' = ' || REPLACE(sum_bonus_per, ',', '.') || -- ����� ������� �� 1 ������
             ', t.ag_bs_' || (i + 1) || ' = ' || REPLACE(sum_bonus_sales, ',', '.') || -- ����� ��� ������� �� ������
             ' where t.year = ' || tyear || 'and t.month = ' || tmonth;
      EXECUTE IMMEDIATE str;
    END LOOP;
    --*/
    -- ������� ������
    UPDATE ins_dwh.rep_tr_1 t
       SET t.t_ag =
           (tot_ag + COL)
          , -- ����� �� ��������������� �������
           t.t_do = tot_do
          , -- ����� �� ��������� �������
           t.t_s  = tot_s
          , -- ����� �� ��������
           t.t_sp = tot_sp
          , -- ����� �� �������� �� 1 ������
           t.T_B  = tot_b
          , -- ����� �� �������
           t.t_bp = tot_bp
          , -- ����� �� ������� �� 1 ������
           t.t_bs = tot_bs -- ����� �� ������� ��� % �� ������
     WHERE t.YEAR = tyear
       AND t.MONTH = tmonth;
    COMMIT;
  END;

  -- ��������� �������� ������������ ������ Tracking Report - 1
  -- � �������� �� ��������� � �������� ������
  PROCEDURE create_month_tr1
  (
    tmonth VARCHAR2
   ,tyear  VARCHAR2
   ,st     VARCHAR2
   ,cat    VARCHAR2
  ) IS
    str             STRING(1000);
    strMonth        VARCHAR2(2);
    COL             NUMBER;
    col_ag          VARCHAR2(5); -- ���������� �������
    col_do          VARCHAR2(5); -- ���������� ��������� �������
    sum_sales       VARCHAR2(10); -- ����� ������
    sum_sales_per   VARCHAR2(10); -- ����� ������ �� ������ ������
    sum_bonus       VARCHAR2(10); -- ����� �������
    sum_bonus_per   VARCHAR2(10); -- ����� ������� �� ������ ������
    sum_bonus_sales VARCHAR2(6); -- ����� ��� ������� �� ������
    -- ������� ��������
    tot_ag NUMBER := 0; -- ����� �� �������
    tot_do NUMBER := 0; -- ����� �� ���������
    tot_s  NUMBER := 0; -- ����� �� ��������
    tot_sp NUMBER := 0; -- ����� �� �������� � ������� �� 1 ������
    tot_b  NUMBER := 0; -- ����� �� �������
    tot_bp NUMBER := 0; -- ����� �� ������� � ������� �� 1 ������
    tot_bs NUMBER := 0; -- ����� �� ������� ��� �������� � ������
  
    row_month NUMBER; -- ���������� ��� �������� ������������� ������
  BEGIN
  
    -- ��������� ������������� ������
    -- ////////////////////////////////////////////////////////////////////////
    SELECT COUNT(*)
      INTO row_month
      FROM ins_dwh.rep_tr_1 tr
     WHERE tr.MONTH = tmonth
       AND tr.YEAR = tyear;
  
    IF row_month = 0
    THEN
      INSERT INTO ins_dwh.rep_tr_1 tr (YEAR, MONTH) VALUES (tyear, tmonth);
    END IF;
  
    -- ��������� ������ ������
    -- ////////////////////////////////////////////////////////////////////////////
  
    -- ������� "���������� ��������������� �������"
    COL := get_agent_number(tmonth, tyear, st, cat);
    UPDATE ins_dwh.rep_tr_1 t
       SET t.ag_num    = COL
          ,t.ag_num_do = COL
          ,t.ag_num_s  = COL
          ,t.ag_num_sp = COL
          ,t.ag_num_b  = COL
          ,t.ag_num_bp = COL
          ,t.ag_num_bs = COL
     WHERE t.YEAR = tyear
       AND t.MONTH = tmonth;
    --/*
    -- ��������� �������, ���������� �������� ��������������� �������
    FOR i IN 1 .. TO_NUMBER(tmonth) - 1
    LOOP
      strMonth := get_prev_month(TO_DATE(tmonth, 'mm'), i * (-1));
    
      col_ag := TO_CHAR(get_agent_active(strMonth, tmonth, tyear, st, cat));
      tot_ag := tot_ag + (NVL(col_ag, 0));
      IF col_ag IS NULL
      THEN
        col_ag := 'null';
      END IF;
    
      col_do := TO_CHAR(get_agent_drop_percent(strMonth, tmonth, tyear, st, cat));
      tot_do := tot_do + (NVL(col_do, 0));
      IF col_do IS NULL
      THEN
        col_do := 'null';
      END IF;
    
      sum_sales := TO_CHAR(get_agent_sales(strMonth, tmonth, tyear, st, cat));
      tot_s     := tot_s + (NVL(sum_sales, 0));
      IF sum_sales IS NULL
      THEN
        sum_sales := 'null';
      END IF;
    
      sum_sales_per := TO_CHAR(get_agent_sales_per(strMonth, tmonth, tyear, st, cat));
      tot_sp        := tot_sp + (NVL(sum_sales_per, 0));
      IF sum_sales_per IS NULL
      THEN
        sum_sales_per := 'null';
      END IF;
    
      sum_bonus := TO_CHAR(get_agent_bonus(strMonth, tmonth, tyear, st, cat));
      tot_b     := tot_b + (NVL(sum_bonus, 0));
      IF sum_bonus IS NULL
      THEN
        sum_bonus := 'null';
      END IF;
    
      sum_bonus_per := TO_CHAR(get_agent_bonus_per(strMonth, tmonth, tyear, st, cat));
      tot_bp        := tot_bp + (NVL(sum_bonus_per, 0));
      IF sum_bonus_per IS NULL
      THEN
        sum_bonus_per := 'null';
      END IF;
    
      sum_bonus_sales := TO_CHAR(get_agent_bonus_sales(strMonth, tmonth, tyear, st, cat));
      tot_bs          := tot_bs + (NVL(sum_bonus_sales, 0));
      IF sum_bonus_sales IS NULL
      THEN
        sum_bonus_sales := 'null';
      END IF;
      str := 'update ins_dwh.rep_tr_1 t set t.ag_' || (i + 1) || ' = ' || col_ag || -- ��������������� ������
             ', t.ag_do_' || (i + 1) || ' = ' || REPLACE(col_do, ',', '.') || -- ��������� ������
             ', t.ag_s_' || (i + 1) || ' = ' || REPLACE(sum_sales, ',', '.') || -- ����� ������
             ', t.ag_sp_' || (i + 1) || ' = ' || REPLACE(sum_sales_per, ',', '.') || -- ����� ������ �� 1 ������
             ', t.ag_b_' || (i + 1) || ' = ' || REPLACE(sum_bonus, ',', '.') || -- ����� �������
             ', t.ag_bp_' || (i + 1) || ' = ' || REPLACE(sum_bonus_per, ',', '.') || -- ����� ������� �� 1 ������
             ', t.ag_bs_' || (i + 1) || ' = ' || REPLACE(sum_bonus_sales, ',', '.') || -- ����� ��� ������� �� ������
             ' where t.year = ' || tyear || 'and t.month = ' || tmonth;
      EXECUTE IMMEDIATE str;
    END LOOP;
    --*/
    -- ������� ������
    UPDATE ins_dwh.rep_tr_1 t
       SET t.t_ag =
           (tot_ag + COL)
          , -- ����� �� ��������������� �������
           t.t_do = tot_do
          , -- ����� �� ��������� �������
           t.t_s  = tot_s
          , -- ����� �� ��������
           t.t_sp = tot_sp
          , -- ����� �� �������� �� 1 ������
           t.T_B  = tot_b
          , -- ����� �� �������
           t.t_bp = tot_bp
          , -- ����� �� ������� �� 1 ������
           t.t_bs = tot_bs -- ����� �� ������� ��� % �� ������
     WHERE t.YEAR = tyear
       AND t.MONTH = tmonth;
    COMMIT;
  END;

  -- ************************************************************************
  --//////////////////////////END TRACKING REPORT 1//////////////////////////
  -- ***********************************************************************

  -- ************************************************************************
  --/////////////////////////����� � ��������� ��������//////////////////////
  -- ************************************************************************

  -- ���������� �����, � ������� ������� ���������� � ������� ���
  FUNCTION get_month_agent_dav(pol_id NUMBER) RETURN DATE IS
    res DATE;
  BEGIN
    SELECT agva.date_begin
      INTO res
      FROM ins.ven_p_pol_header ph
      JOIN ins.ven_p_policy_agent ppag
        ON ppag.policy_header_id = ph.policy_header_id
      JOIN ins.ven_ag_contract_header agch
        ON agch.ag_contract_header_id = ppag.ag_contract_header_id
      JOIN ins.ven_agent_report agr
        ON agr.ag_contract_h_id = agch.ag_contract_header_id
      JOIN ins.ven_agent_report_dav agrd
        ON agrd.agent_report_id = agr.agent_report_id
      JOIN ins.ven_t_prod_coef_type tpct
        ON tpct.t_prod_coef_type_id = agrd.prod_coef_type_id
       AND tpct.brief = '���'
      JOIN ins.ven_agent_report_dav_ct ardc
        ON ardc.agent_report_dav_id = agrd.agent_report_dav_id
       AND ardc.policy_id = pol_id
      JOIN ins.ven_ag_vedom_av agva
        ON agva.ag_vedom_av_id = agr.ag_vedom_av_id
     WHERE ph.policy_id = pol_id;
    RETURN(TO_DATE(TO_CHAR(res, 'mm.yyyy'), 'mm.yyyy'));
  END;

  -- ************************************************************************
  --/////////////////////////END ����� � ��������� ��������///////////////////
  -- ************************************************************************

  -- ************************************************************************
  --/////////////////////////TRACKING REPORT 2///////////////////////////////
  -- ************************************************************************

  -- ���������� ���������� �������, ����������� � ��������� ������ � ����
  FUNCTION get_agency_number
  (
    MONTH VARCHAR2
   ,YEAR  VARCHAR2
  ) RETURN NUMBER IS
    num NUMBER;
    str STRING(10);
    d   DATE;
  BEGIN
    str := '01.' || MONTH || '.' || YEAR;
    d   := TO_DATE(str, 'dd.mm.yyyy');
    SELECT COUNT(*)
      INTO num
      FROM ins.ven_department dep
     WHERE dep.date_open <= LAST_DAY(d)
       AND NVL(dep.date_close, d + 1) > d;
    --or dep.date_close is null
    RETURN(num);
  END;

  -- ���������� ������� � id ��������� ��������� ��� ������� �
  -- c ��������� ����� � ������� ������ �� ��������� � �� call- �����
  FUNCTION get_part_time_id RETURN tbl_ag_contract_id
    PIPELINED IS
  BEGIN
    FOR ag_rec IN (SELECT agch.*
                     FROM ins.ven_ag_contract_header agch
                     JOIN ins.ven_ag_contract agc
                       ON agc.ag_contract_id = agch.last_ver_id
                     JOIN ins.ven_t_sales_channel sCh
                       ON sCh.ID = agch.t_sales_channel_id
                    WHERE agc.leg_pos = 1
                      AND sCh.brief NOT IN ('CC', 'MLM')
                   --and sCh.brief != 'CC'
                   --and sCh.brief != 'MLM'
                   )
    LOOP
      PIPE ROW(ag_rec.ag_contract_header_id);
    END LOOP;
    RETURN;
  END;

  -- ���������� ������� � id ��������� ��������� ��� �������
  -- c ��������� ������� ������
  FUNCTION get_ag_chanal_id(chanal VARCHAR2) RETURN tbl_ag_contract_id
    PIPELINED IS
  BEGIN
    FOR ag_rec IN (SELECT agch.*
                     FROM ins.ven_ag_contract_header agch
                     JOIN ins.ven_t_sales_channel sCh
                       ON sCh.ID = agch.t_sales_channel_id
                      AND sCh.brief = chanal)
    LOOP
      PIPE ROW(ag_rec.ag_contract_header_id);
    END LOOP;
    RETURN;
  END;

  -- ���������� ������� � id ��������� ��������� ��� �������
  -- c ������� ������, ����� �����������, ����������, call - ������, �����������
  FUNCTION get_ag_other_chanal_id RETURN tbl_ag_contract_id
    PIPELINED IS
  BEGIN
    FOR ag_rec IN (SELECT agch.*
                     FROM ins.ven_ag_contract_header agch
                     JOIN ins.ven_t_sales_channel sCh
                       ON sCh.ID = agch.t_sales_channel_id
                      AND sCh.brief NOT IN ('MLM', 'BR', 'CC', 'BANK')
                   --and sCh.brief != 'MLM'
                   --and sCh.brief != 'BR'
                   --and sCh.brief != 'CC'
                   --and sCh.brief != 'BANK'
                   )
    LOOP
      PIPE ROW(ag_rec.ag_contract_header_id);
    END LOOP;
    RETURN;
  END;

  -- ���������� ���������� ������� "Part time" ���������� � ��������� ������
  FUNCTION get_ag_part_time_num
  (
    MONTH VARCHAR2
   ,YEAR  VARCHAR2
  ) RETURN NUMBER IS
    num NUMBER;
    str STRING(10);
    d   DATE;
  BEGIN
    str := '01.' || MONTH || '.' || YEAR;
    d   := TO_DATE(str, 'dd.mm.yyyy');
    SELECT COUNT(*)
      INTO num
      FROM ins.ven_ag_contract_header agch
      JOIN ins.ven_ag_contract agc
        ON agc.ag_contract_id = agch.last_ver_id
      JOIN (SELECT * FROM TABLE(pkg_rep_utils_ins11.get_part_time_id)) agch_id
        ON agch.ag_contract_header_id = agch_id.COLUMN_VALUE
     WHERE agch.date_begin <= LAST_DAY(d)
       AND NVL(get_ag_contract_end_date(agc.ag_contract_id), LAST_DAY(d) + 1) > LAST_DAY(d);
    --or get_ag_contract_end_date(agc.ag_contract_id) is null);
    RETURN(num);
  END;

  -- ���������� ���������� ������� ���������� � ��������� ������
  -- � �������� �� ������� � ��������� ������
  FUNCTION get_ag_st_cat_num
  (
    MONTH VARCHAR2
   ,YEAR  VARCHAR2
   ,st    VARCHAR2
   ,cat   VARCHAR2
  ) RETURN NUMBER IS
    num NUMBER;
    str STRING(10);
    d   DATE;
  BEGIN
    str := '01.' || MONTH || '.' || YEAR;
    d   := TO_DATE(str, 'dd.mm.yyyy');
    SELECT COUNT(*)
      INTO num
      FROM ins.ven_ag_contract_header agch
      JOIN ins.ven_ag_contract agc
        ON agc.ag_contract_id = agch.last_ver_id
      JOIN (SELECT * FROM TABLE(pkg_rep_utils_ins11.get_ag_contract_id(st, cat))) agch_id
        ON agch.ag_contract_header_id = agch_id.COLUMN_VALUE
     WHERE agch.date_begin <= LAST_DAY(d)
       AND NVL(get_ag_contract_end_date(agc.ag_contract_id), LAST_DAY(d) + 1) > LAST_DAY(d);
    --or get_ag_contract_end_date(agc.ag_contract_id) is null);
    RETURN(num);
  END;

  -- ���������� ���������� �������, ��������� � ��������� ������
  -- � �������� �� ������� � ��������� ������
  FUNCTION get_agent_drop_number
  (
    MONTH VARCHAR2
   ,YEAR  VARCHAR2
   ,st    VARCHAR2
   ,cat   VARCHAR2
  ) RETURN NUMBER IS
    COL NUMBER;
  BEGIN
    SELECT COUNT(agch.agent_id)
      INTO COL
      FROM ins.ven_ag_contract_header agch
      JOIN ins.ven_ag_contract agc
        ON agc.ag_contract_id = agch.last_ver_id
      JOIN (SELECT * FROM TABLE(pkg_rep_utils_ins11.get_ag_contract_id(st, cat))) agch_id
        ON agch.ag_contract_header_id = agch_id.COLUMN_VALUE
     WHERE TO_CHAR(get_ag_contract_end_date(agc.ag_contract_id), 'mm') =
           TO_CHAR(TO_DATE(MONTH, 'mm'), 'mm')
       AND TO_CHAR(get_ag_contract_end_date(agc.ag_contract_id), 'yyyy') =
           TO_CHAR(TO_DATE(YEAR, 'yyyy'), 'yyyy');
    RETURN(COL);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
  END;

  -- ���������� ���������� ������� PT, ��������� � ��������� ������
  FUNCTION get_ag_drop_part_time
  (
    MONTH VARCHAR2
   ,YEAR  VARCHAR2
  ) RETURN NUMBER IS
    COL NUMBER;
  BEGIN
    SELECT COUNT(agch.agent_id)
      INTO COL
      FROM ins.ven_ag_contract_header agch
      JOIN ins.ven_ag_contract agc
        ON agc.ag_contract_id = agch.last_ver_id
      JOIN (SELECT * FROM TABLE(pkg_rep_utils_ins11.get_part_time_id)) agch_id
        ON agch.ag_contract_header_id = agch_id.COLUMN_VALUE
     WHERE TO_CHAR(get_ag_contract_end_date(agc.ag_contract_id), 'mm') =
           TO_CHAR(TO_DATE(MONTH, 'mm'), 'mm')
       AND TO_CHAR(get_ag_contract_end_date(agc.ag_contract_id), 'yyyy') =
           TO_CHAR(TO_DATE(YEAR, 'yyyy'), 'yyyy');
    RETURN(COL);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
  END;

  -- ���������� ���������� �������, ��������� ��������� � ������� ���������� ������
  FUNCTION get_ag_change_cat_num
  (
    MONTH   VARCHAR2
   ,YEAR    VARCHAR2
   ,cat_old VARCHAR2
   ,cat_new VARCHAR2
   ,st      VARCHAR2
  ) RETURN NUMBER IS
    num NUMBER;
    str STRING(10);
    d   DATE;
  BEGIN
    str := '01.' || MONTH || '.' || YEAR;
    d   := TO_DATE(str, 'dd.mm.yyyy');
    SELECT COUNT(*)
      INTO num
      FROM ins.ven_ag_contract_header agch
      JOIN ins.ven_ag_contract agc
        ON agc.ag_contract_id = agch.last_ver_id
       AND agc.ag_contract_id =
           ins.pkg_agent_1.get_status_by_date(agch.ag_contract_header_id, LAST_DAY(ADD_MONTHS(d, -1)))
      JOIN ins.ven_ag_category_agent agCat
        ON agCat.ag_category_agent_id = agc.category_id
       AND agCat.brief LIKE cat_old
    --join ins.ven_ag_stat_hist agStH on agStH.ag_contract_header_id = agch.ag_contract_header_id
    --join ins.ven_ag_stat_agent agSt on agSt.ag_stat_agent_id = agStH.ag_stat_agent_id and agSt.brief = st
      JOIN ins.ven_ag_contract agc1
        ON agc1.contract_id = agch.ag_contract_header_id
       AND agc1.ag_contract_id =
           ins.pkg_agent_1.get_status_by_date(agch.ag_contract_header_id, LAST_DAY(d))
      JOIN ins.ven_ag_category_agent agCat1
        ON agCat1.ag_category_agent_id = agc.category_id
       AND agCat1.brief LIKE cat_new
     WHERE ins.pkg_agent_1.get_agent_status_brief_by_date(agch.ag_contract_header_id
                                                         ,LAST_DAY(ADD_MONTHS(d, -1))) LIKE st;
    RETURN(num);
  END;

  -- ���������� ����� ������ �� �������
  -- � �������� �� ������� � ��������� ������
  FUNCTION get_agent_sales
  (
    MONTH VARCHAR2
   ,YEAR  VARCHAR2
   ,st    VARCHAR2
   ,cat   VARCHAR2
  ) RETURN NUMBER IS
    SALES NUMBER(11, 2); -- ����� ������
  BEGIN
    SELECT NVL(SUM(ppag.part_agent / 100 * pp.premium *
                   ins.acc_new.Get_Cross_Rate_By_Id((SELECT t.rate_type_id
                                                      FROM ins.ven_rate_type t
                                                     WHERE t.brief = '��')
                                                   ,pph.fund_id
                                                   ,(SELECT f.fund_id
                                                      FROM ins.ven_fund f
                                                     WHERE f.brief = 'RUR')
                                                   ,pp.notice_date))
              ,0)
      INTO SALES
      FROM ins.ven_ag_contract_header agch
      JOIN ins.ven_ag_contract agc
        ON agc.ag_contract_id = agch.last_ver_id
      JOIN (SELECT * FROM TABLE(pkg_rep_utils_ins11.get_ag_contract_id(st, cat))) agch_id
        ON agch.ag_contract_header_id = agch_id.COLUMN_VALUE
      LEFT JOIN ins.ven_p_policy_agent ppag
        ON ppag.ag_contract_header_id = agch.ag_contract_header_id
      LEFT JOIN ins.ven_p_pol_header pph
        ON pph.policy_header_id = ppag.policy_header_id
      LEFT JOIN ins.ven_p_policy pp
        ON pp.pol_header_id = pph.policy_header_id
       AND pp.version_num = 1
       AND TO_CHAR(pp.notice_date, 'mm') = TO_CHAR(TO_DATE(MONTH, 'mm'), 'mm')
       AND TO_CHAR(pp.notice_date, 'yyyy') = TO_CHAR(TO_DATE(YEAR, 'yyyy'), 'yyyy');
    RETURN(TO_CHAR(SALES, '999999999D99'));
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  -- ���������� ����� ������ �� ������� c ����������� ������ � ������ ����
  -- � �������� �� ������� � ��������� ������
  FUNCTION get_agent_sales_ytd
  (
    MONTH VARCHAR2
   ,YEAR  VARCHAR2
   ,st    VARCHAR2
   ,cat   VARCHAR2
  ) RETURN NUMBER IS
    SALES   NUMBER(11, 2); -- ����� ������
    tempSal NUMBER; -- ��������� ����������
  BEGIN
    SALES := 0;
    FOR i IN 1 .. TO_NUMBER(MONTH)
    LOOP
      SELECT NVL(SUM(ppag.part_agent / 100 * pp.premium *
                     ins.acc_new.Get_Cross_Rate_By_Id((SELECT t.rate_type_id
                                                        FROM ins.ven_rate_type t
                                                       WHERE t.brief = '��')
                                                     ,pph.fund_id
                                                     ,(SELECT f.fund_id
                                                        FROM ins.ven_fund f
                                                       WHERE f.brief = 'RUR')
                                                     ,pp.notice_date))
                ,0)
        INTO tempSal
        FROM ins.ven_ag_contract_header agch
        JOIN ins.ven_ag_contract agc
          ON agc.ag_contract_id = agch.last_ver_id
        JOIN (SELECT * FROM TABLE(pkg_rep_utils_ins11.get_ag_contract_id(st, cat))) agch_id
          ON agch.ag_contract_header_id = agch_id.COLUMN_VALUE
        LEFT JOIN ins.ven_p_policy_agent ppag
          ON ppag.ag_contract_header_id = agch.ag_contract_header_id
        LEFT JOIN ins.ven_p_pol_header pph
          ON pph.policy_header_id = ppag.policy_header_id
        LEFT JOIN ins.ven_p_policy pp
          ON pp.pol_header_id = pph.policy_header_id
         AND pp.version_num = 1
         AND TO_CHAR(pp.notice_date, 'mm') = TO_CHAR(TO_DATE(i, 'mm'), 'mm')
         AND TO_CHAR(pp.notice_date, 'yyyy') = TO_CHAR(TO_DATE(YEAR, 'yyyy'), 'yyyy');
      SALES := SALES + tempSal;
    END LOOP;
    RETURN(TO_CHAR(SALES, '999999999D99'));
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  -- ���������� ����� ������ �� �������
  -- � �������� �� ������� � ��������� ������
  FUNCTION get_ag_sales_part_time
  (
    MONTH VARCHAR2
   ,YEAR  VARCHAR2
  ) RETURN NUMBER IS
    SALES NUMBER(11, 2); -- ����� ������
  BEGIN
    SELECT NVL(SUM(ppag.part_agent / 100 * pp.premium *
                   ins.acc_new.Get_Cross_Rate_By_Id((SELECT t.rate_type_id
                                                      FROM ins.ven_rate_type t
                                                     WHERE t.brief = '��')
                                                   ,pph.fund_id
                                                   ,(SELECT f.fund_id
                                                      FROM ins.ven_fund f
                                                     WHERE f.brief = 'RUR')
                                                   ,pp.notice_date))
              ,0)
      INTO SALES
      FROM ins.ven_ag_contract_header agch
      JOIN ins.ven_ag_contract agc
        ON agc.ag_contract_id = agch.last_ver_id
      JOIN (SELECT * FROM TABLE(pkg_rep_utils_ins11.get_part_time_id)) agch_id
        ON agch.ag_contract_header_id = agch_id.COLUMN_VALUE
      LEFT JOIN ins.ven_p_policy_agent ppag
        ON ppag.ag_contract_header_id = agch.ag_contract_header_id
      LEFT JOIN ins.ven_p_pol_header pph
        ON pph.policy_header_id = ppag.policy_header_id
      LEFT JOIN ins.ven_p_policy pp
        ON pp.pol_header_id = pph.policy_header_id
       AND pp.version_num = 1
       AND TO_CHAR(pp.notice_date, 'mm') = TO_CHAR(TO_DATE(MONTH, 'mm'), 'mm')
       AND TO_CHAR(pp.notice_date, 'yyyy') = TO_CHAR(TO_DATE(YEAR, 'yyyy'), 'yyyy');
    IF SALES IS NULL
    THEN
      SALES := 0;
    END IF;
    RETURN(TO_CHAR(SALES, '999999999D99'));
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  -- ���������� ����� ������ �� �������
  -- � �������� �� ������ ������
  FUNCTION get_ag_sales_chanal
  (
    MONTH  VARCHAR2
   ,YEAR   VARCHAR2
   ,chanal VARCHAR2
  ) RETURN NUMBER IS
    SALES NUMBER(11, 2); -- ����� ������
  BEGIN
    SELECT NVL(SUM(ppag.part_agent / 100 * pp.premium *
                   ins.acc_new.Get_Cross_Rate_By_Id((SELECT t.rate_type_id
                                                      FROM ins.ven_rate_type t
                                                     WHERE t.brief = '��')
                                                   ,pph.fund_id
                                                   ,(SELECT f.fund_id
                                                      FROM ins.ven_fund f
                                                     WHERE f.brief = 'RUR')
                                                   ,pp.notice_date))
              ,0)
      INTO SALES
      FROM ins.ven_ag_contract_header agch
      JOIN ins.ven_ag_contract agc
        ON agc.ag_contract_id = agch.last_ver_id
      JOIN (SELECT * FROM TABLE(pkg_rep_utils_ins11.get_ag_chanal_id(chanal))) agch_id
        ON agch.ag_contract_header_id = agch_id.COLUMN_VALUE
      LEFT JOIN ins.ven_p_policy_agent ppag
        ON ppag.ag_contract_header_id = agch.ag_contract_header_id
      LEFT JOIN ins.ven_p_pol_header pph
        ON pph.policy_header_id = ppag.policy_header_id
      LEFT JOIN ins.ven_p_policy pp
        ON pp.pol_header_id = pph.policy_header_id
       AND pp.version_num = 1
       AND TO_CHAR(pp.notice_date, 'mm') = TO_CHAR(TO_DATE(MONTH, 'mm'), 'mm')
       AND TO_CHAR(pp.notice_date, 'yyyy') = TO_CHAR(TO_DATE(YEAR, 'yyyy'), 'yyyy');
    IF SALES IS NULL
    THEN
      SALES := 0;
    END IF;
    RETURN(TO_CHAR(SALES, '999999999D99'));
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  -- ���������� ����� ������ �� �������
  -- ��� ���� ������� ������, ����� ����������, �����������, �����������, call - ������
  FUNCTION get_ag_sales_other_chanal
  (
    MONTH VARCHAR2
   ,YEAR  VARCHAR2
  ) RETURN NUMBER IS
    SALES NUMBER(11, 2); -- ����� ������
  BEGIN
    SELECT NVL(SUM(ppag.part_agent / 100 * pp.premium *
                   ins.acc_new.Get_Cross_Rate_By_Id((SELECT t.rate_type_id
                                                      FROM ins.ven_rate_type t
                                                     WHERE t.brief = '��')
                                                   ,pph.fund_id
                                                   ,(SELECT f.fund_id
                                                      FROM ins.ven_fund f
                                                     WHERE f.brief = 'RUR')
                                                   ,pp.notice_date))
              ,0)
      INTO SALES
      FROM ins.ven_ag_contract_header agch
      JOIN ins.ven_ag_contract agc
        ON agc.ag_contract_id = agch.last_ver_id
      JOIN (SELECT * FROM TABLE(pkg_rep_utils_ins11.get_ag_other_chanal_id)) agch_id
        ON agch.ag_contract_header_id = agch_id.COLUMN_VALUE
      LEFT JOIN ins.ven_p_policy_agent ppag
        ON ppag.ag_contract_header_id = agch.ag_contract_header_id
      LEFT JOIN ins.ven_p_pol_header pph
        ON pph.policy_header_id = ppag.policy_header_id
      LEFT JOIN ins.ven_p_policy pp
        ON pp.pol_header_id = pph.policy_header_id
       AND pp.version_num = 1
       AND TO_CHAR(pp.notice_date, 'mm') = TO_CHAR(TO_DATE(MONTH, 'mm'), 'mm')
       AND TO_CHAR(pp.notice_date, 'yyyy') = TO_CHAR(TO_DATE(YEAR, 'yyyy'), 'yyyy');
    IF SALES IS NULL
    THEN
      SALES := 0;
    END IF;
    RETURN(TO_CHAR(SALES, '999999999D99'));
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  -- ���������� ����� ������ �� ������� � ����������� ������ � ������ ����
  -- � �������� �� ������� � ��������� ������
  FUNCTION get_ag_sales_part_time_ytd
  (
    MONTH VARCHAR2
   ,YEAR  VARCHAR2
  ) RETURN NUMBER IS
    SALES   NUMBER(11, 2); -- ����� ������
    tempSal NUMBER; -- ��������� ����������
  BEGIN
    SALES := 0;
    FOR i IN 1 .. TO_NUMBER(MONTH)
    LOOP
      SELECT NVL(SUM(ppag.part_agent / 100 * pp.premium *
                     ins.acc_new.Get_Cross_Rate_By_Id((SELECT t.rate_type_id
                                                        FROM ins.ven_rate_type t
                                                       WHERE t.brief = '��')
                                                     ,pph.fund_id
                                                     ,(SELECT f.fund_id
                                                        FROM ins.ven_fund f
                                                       WHERE f.brief = 'RUR')
                                                     ,pp.notice_date))
                ,0)
        INTO tempSal
        FROM ins.ven_ag_contract_header agch
        JOIN ins.ven_ag_contract agc
          ON agc.ag_contract_id = agch.last_ver_id
        JOIN (SELECT * FROM TABLE(pkg_rep_utils_ins11.get_part_time_id)) agch_id
          ON agch.ag_contract_header_id = agch_id.COLUMN_VALUE
        LEFT JOIN ins.ven_p_policy_agent ppag
          ON ppag.ag_contract_header_id = agch.ag_contract_header_id
        LEFT JOIN ins.ven_p_pol_header pph
          ON pph.policy_header_id = ppag.policy_header_id
        LEFT JOIN ins.ven_p_policy pp
          ON pp.pol_header_id = pph.policy_header_id
         AND pp.version_num = 1
         AND TO_CHAR(pp.notice_date, 'mm') = TO_CHAR(TO_DATE(i, 'mm'), 'mm')
         AND TO_CHAR(pp.notice_date, 'yyyy') = TO_CHAR(TO_DATE(YEAR, 'yyyy'), 'yyyy');
      SALES := SALES + tempSal;
    END LOOP;
    RETURN(TO_CHAR(SALES, '999999999D99'));
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  -- ���������� ����� ������ �� ������� � ����������� ������ � ������ ����
  -- � �������� �� ������ ������
  FUNCTION get_ag_sales_chanal_ytd
  (
    MONTH  VARCHAR2
   ,YEAR   VARCHAR2
   ,chanal VARCHAR2
  ) RETURN NUMBER IS
    SALES   NUMBER(11, 2); -- ����� ������
    tempSal NUMBER; -- ��������� ����������
  BEGIN
    SALES := 0;
    FOR i IN 1 .. TO_NUMBER(MONTH)
    LOOP
      SELECT NVL(SUM(ppag.part_agent / 100 * pp.premium *
                     ins.acc_new.Get_Cross_Rate_By_Id((SELECT t.rate_type_id
                                                        FROM ins.ven_rate_type t
                                                       WHERE t.brief = '��')
                                                     ,pph.fund_id
                                                     ,(SELECT f.fund_id
                                                        FROM ins.ven_fund f
                                                       WHERE f.brief = 'RUR')
                                                     ,pp.notice_date))
                ,0)
        INTO tempSal
        FROM ins.ven_ag_contract_header agch
        JOIN ins.ven_ag_contract agc
          ON agc.ag_contract_id = agch.last_ver_id
        JOIN (SELECT * FROM TABLE(pkg_rep_utils_ins11.get_ag_chanal_id(chanal))) agch_id
          ON agch.ag_contract_header_id = agch_id.COLUMN_VALUE
        LEFT JOIN ins.ven_p_policy_agent ppag
          ON ppag.ag_contract_header_id = agch.ag_contract_header_id
        LEFT JOIN ins.ven_p_pol_header pph
          ON pph.policy_header_id = ppag.policy_header_id
        LEFT JOIN ins.ven_p_policy pp
          ON pp.pol_header_id = pph.policy_header_id
         AND pp.version_num = 1
         AND TO_CHAR(pp.notice_date, 'mm') = TO_CHAR(TO_DATE(i, 'mm'), 'mm')
         AND TO_CHAR(pp.notice_date, 'yyyy') = TO_CHAR(TO_DATE(YEAR, 'yyyy'), 'yyyy');
      SALES := SALES + tempSal;
    END LOOP;
    RETURN(TO_CHAR(SALES, '999999999D99'));
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  -- ���������� ����� ������ �� ������� � ����������� ������ � ������ ����
  -- ��� ���� ������� ����� ���������� , �����������, ����������� � call - ������
  FUNCTION get_ag_sales_other_chanal_ytd
  (
    MONTH VARCHAR2
   ,YEAR  VARCHAR2
  ) RETURN NUMBER IS
    SALES   NUMBER(11, 2); -- ����� ������
    tempSal NUMBER; -- ��������� ����������
  BEGIN
    SALES := 0;
    FOR i IN 1 .. TO_NUMBER(MONTH)
    LOOP
      SELECT NVL(SUM(ppag.part_agent / 100 * pp.premium *
                     ins.acc_new.Get_Cross_Rate_By_Id((SELECT t.rate_type_id
                                                        FROM ins.ven_rate_type t
                                                       WHERE t.brief = '��')
                                                     ,pph.fund_id
                                                     ,(SELECT f.fund_id
                                                        FROM ins.ven_fund f
                                                       WHERE f.brief = 'RUR')
                                                     ,pp.notice_date))
                ,0)
        INTO tempSal
        FROM ins.ven_ag_contract_header agch
        JOIN ins.ven_ag_contract agc
          ON agc.ag_contract_id = agch.last_ver_id
        JOIN (SELECT * FROM TABLE(pkg_rep_utils_ins11.get_ag_other_chanal_id)) agch_id
          ON agch.ag_contract_header_id = agch_id.COLUMN_VALUE
        LEFT JOIN ins.ven_p_policy_agent ppag
          ON ppag.ag_contract_header_id = agch.ag_contract_header_id
        LEFT JOIN ins.ven_p_pol_header pph
          ON pph.policy_header_id = ppag.policy_header_id
        LEFT JOIN ins.ven_p_policy pp
          ON pp.pol_header_id = pph.policy_header_id
         AND pp.version_num = 1
         AND TO_CHAR(pp.notice_date, 'mm') = TO_CHAR(TO_DATE(i, 'mm'), 'mm')
         AND TO_CHAR(pp.notice_date, 'yyyy') = TO_CHAR(TO_DATE(YEAR, 'yyyy'), 'yyyy');
      SALES := SALES + tempSal;
    END LOOP;
    RETURN(TO_CHAR(SALES, '999999999D99'));
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  -- ����������� ����� ������ ��� ����� ����������
  FUNCTION get_sales_um_groop
  (
    MONTH VARCHAR2
   ,YEAR  VARCHAR2
  ) RETURN NUMBER IS
    sal NUMBER;
  BEGIN
    SELECT NVL(SUM(pa.part_agent / 100 * pp.premium *
                   ins.acc_new.Get_Cross_Rate_By_Id((SELECT t.rate_type_id
                                                      FROM ins.ven_rate_type t
                                                     WHERE t.brief = '��')
                                                   ,ph.fund_id
                                                   ,(SELECT f.fund_id
                                                      FROM ins.ven_fund f
                                                     WHERE f.brief = 'RUR')
                                                   ,pp.notice_date))
              ,0)
      INTO sal
      FROM ins.ven_p_pol_header ph
      JOIN ins.ven_p_policy pp
        ON pp.pol_header_id = ph.policy_header_id
       AND pp.version_num = 1
       AND TO_CHAR(pp.notice_date, 'mm') = TO_CHAR(TO_DATE(MONTH, 'mm'), 'mm')
       AND TO_CHAR(pp.notice_date, 'yyyy') = TO_CHAR(TO_DATE(YEAR, 'yyyy'), 'yyyy')
      JOIN ins.ven_p_policy_agent pa
        ON pa.policy_header_id = ph.policy_header_id
      JOIN ins.ven_ag_contract_header agch
        ON agch.ag_contract_header_id = pa.ag_contract_header_id
      JOIN ins.ven_ag_contract agc
        ON agc.ag_contract_id = agch.last_ver_id
       AND ins.pkg_agent_1.get_status_by_date(agch.ag_contract_header_id, pp.notice_date) =
           agc.ag_contract_id
      JOIN ins.ven_ag_contract agcLead
        ON agc.contract_leader_id = agcLead.Ag_Contract_Id
      JOIN ins.ven_ag_category_agent agCat
        ON agCat.Ag_Category_Agent_Id = agcLead.Category_Id
       AND agCat.Brief = 'MN';
    IF sal IS NULL
    THEN
      sal := 0;
    END IF;
    RETURN(sal);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  -- ����������� ����� ������ ��� ����� ���������� � ����������� ������ � ������ ����
  FUNCTION get_sales_um_groop_ytd
  (
    MONTH VARCHAR2
   ,YEAR  VARCHAR2
  ) RETURN NUMBER IS
    sal     NUMBER;
    tempNum NUMBER; --  �������� ����������
  BEGIN
    sal := 0;
    FOR i IN 1 .. TO_NUMBER(MONTH)
    LOOP
      SELECT NVL(SUM(pa.part_agent / 100 * pp.premium *
                     ins.acc_new.Get_Cross_Rate_By_Id((SELECT t.rate_type_id
                                                        FROM ins.ven_rate_type t
                                                       WHERE t.brief = '��')
                                                     ,ph.fund_id
                                                     ,(SELECT f.fund_id
                                                        FROM ins.ven_fund f
                                                       WHERE f.brief = 'RUR')
                                                     ,pp.notice_date))
                ,0)
        INTO tempNum
        FROM ins.ven_p_pol_header ph
        JOIN ins.ven_p_policy pp
          ON pp.pol_header_id = ph.policy_header_id
         AND pp.version_num = 1
         AND TO_CHAR(pp.notice_date, 'mm') = TO_CHAR(TO_DATE(MONTH, 'mm'), 'mm')
         AND TO_CHAR(pp.notice_date, 'yyyy') = TO_CHAR(TO_DATE(YEAR, 'yyyy'), 'yyyy')
        JOIN ins.ven_p_policy_agent pa
          ON pa.policy_header_id = ph.policy_header_id
        JOIN ins.ven_ag_contract_header agch
          ON agch.ag_contract_header_id = pa.ag_contract_header_id
        JOIN ins.ven_ag_contract agc
          ON agc.ag_contract_id = agch.last_ver_id
         AND ins.pkg_agent_1.get_status_by_date(agch.ag_contract_header_id, pp.notice_date) =
             agc.ag_contract_id
        JOIN ins.ven_ag_contract agcLead
          ON agc.contract_leader_id = agcLead.Ag_Contract_Id
        JOIN ins.ven_ag_category_agent agCat
          ON agCat.Ag_Category_Agent_Id = agcLead.Category_Id
         AND agCat.Brief = 'MN';
      sal := sal + tempNum;
    END LOOP;
    RETURN(sal);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  -- ��������� �������� ������������ ������ Tracking Report - 2
  PROCEDURE create_month_tr2
  (
    tmonth VARCHAR2
   ,tyear  VARCHAR2
  ) IS
    ag_recr NUMBER; -- ���������� ��������������� �������
    -- ������� �� ���������� �������
    col_agency NUMBER; -- ���������� �������
    col_UM     NUMBER; -- ���������� UM (unit manager)
    col_TR     NUMBER; -- ���������� TR (traainee)
    col_PT     NUMBER; -- ���������� PT (part time)
    col_C      NUMBER; -- ���������� � (consultant)
    col_SC     NUMBER; -- ���������� SC (senior consultant)
    col_EC     NUMBER; -- ���������� EC (elite consultant)
    col_tot    NUMBER; -- ����� ���������� �������, ��� UM
    -- ������� �� ����������
    drop_UM     NUMBER; -- ���������� ����������� UM
    change_UM   NUMBER; -- ���������� UM, ���������
    drop_TR     NUMBER; -- ���������� ����������� TR
    change_TR   NUMBER; -- ���������� TR, ��������� ���������
    drop_PT     NUMBER; -- ���������� ����������� PT
    drop_C      NUMBER; -- ���������� ����������� C
    change_C    NUMBER; -- ���������� C, ��������� ���������
    drop_SC     NUMBER; -- ���������� ����������� SC
    change_SC   NUMBER; -- ���������� SC, ��������� ���������
    change_EC   NUMBER; -- ���������� EC, ��������� ���������
    drop_EC     NUMBER; -- ���������� ����������� EC
    drop_per_UM NUMBER; -- ������� ����������� UM
    drop_per_TR NUMBER; -- ������� ����������� TR
    drop_per_FT NUMBER; -- ������� ����������� FT (full time)
    drop_per_PT NUMBER; -- ������� ����������� PT
    drop_per_C  NUMBER; -- ������� ����������� �
    drop_per_SC NUMBER; -- ������� ����������� S�
    drop_per_EC NUMBER; -- ������� ����������� E�
    -- ������ �� ��������
    sales_um    NUMBER; -- ����� ������ �� ������� UM
    sales_TR    NUMBER; -- ����� ������ �� ������� TR
    sales_PT    NUMBER; -- ����� ������ �� ������� PT
    sales_C     NUMBER; -- ����� ������ �� ������� C
    sales_SC    NUMBER; -- ����� ������ �� ������� SC
    sales_EC    NUMBER; -- ����� ������ �� ������� EC
    sales_um_gr NUMBER; -- ����� ������ �� ������� UM - groop
    sales_total NUMBER; -- ����� ������ �� ���� �������, ����� UM
    -- ������� �� �������� � ������� ������� ������
    sales_br       NUMBER; -- ����� ������ �� ��������
    sales_b        NUMBER; -- ����� ������ �� ������
    sales_oth      NUMBER; -- ����� ������ �� ������ ������� ������
    sales_ch_total NUMBER; -- ����� �� ���� ������� ������
    -- ������� �� �������� � ����������� ������ � ������ ����
    sales_um_ytd    NUMBER; -- ����� ������ �� ������� UM
    sales_TR_ytd    NUMBER; -- ����� ������ �� ������� TR
    sales_PT_ytd    NUMBER; -- ����� ������ �� ������� PT
    sales_C_ytd     NUMBER; -- ����� ������ �� ������� C
    sales_SC_ytd    NUMBER; -- ����� ������ �� ������� SC
    sales_EC_ytd    NUMBER; -- ����� ������ �� ������� EC
    sales_um_gr_ytd NUMBER; -- ����� ������ �� ������� UM - groop
    sales_total_ytd NUMBER; -- ����� ������ �� ���� �������, ����� UM
    -- ������� �� �������� � ������� ������� ������ � ����������� ������ � ������ ����
    sales_br_ytd       NUMBER; -- ����� ������ �� ��������
    sales_b_ytd        NUMBER; -- ����� ������ �� ������
    sales_oth_ytd      NUMBER; -- ����� ������ �� ������ ������� ������
    sales_ch_total_ytd NUMBER; -- ����� �� ���� ������� ������
    -- ������� �� ��������������
    prod_um    NUMBER; -- �������������� �� ������� UM
    prod_TR    NUMBER; -- �������������� �� ������� TR
    prod_PT    NUMBER; -- �������������� �� ������� PT
    prod_C     NUMBER; -- �������������� �� ������� C
    prod_SC    NUMBER; -- �������������� �� ������� SC
    prod_EC    NUMBER; -- �������������� �� ������� EC
    prod_total NUMBER; -- �������������� �� ���� �������, ����� UM
  
    row_month NUMBER; -- ���������� ��� �������� ������������� ������
  
  BEGIN
    -- ��������� ������������� ������
    -- ////////////////////////////////////////////////////////////////////////
    SELECT COUNT(*)
      INTO row_month
      FROM ins_dwh.rep_tr_2 tr
     WHERE tr.MONTH = tmonth
       AND tr.YEAR = tyear;
  
    IF row_month = 0
    THEN
      INSERT INTO ins_dwh.rep_tr_2 tr (YEAR, MONTH, PERIOD) VALUES (tyear, tmonth, 'CURR');
      INSERT INTO ins_dwh.rep_tr_2 tr (YEAR, MONTH, period) VALUES (tyear, tmonth, 'YTD');
    END IF;
  
    -- ��������� ������ ������
    -- ////////////////////////////////////////////////////////////////////////////
    --  ������� "���������� �������" � "���-�� ������� � ����������� ������"
    col_agency := get_agency_number(tmonth, tyear);
    UPDATE ins_dwh.rep_tr_2 t
       SET t.agency_num = col_agency
     WHERE t.YEAR = tyear
       AND t.MONTH = tmonth;
  
    -- c������ "���������� UM"
    col_um := get_ag_st_cat_num(tmonth, tyear, '%', 'MN');
    UPDATE ins_dwh.rep_tr_2 t
       SET t.um_num = col_UM
     WHERE t.YEAR = tyear
       AND t.MONTH = tmonth
       AND t.period = 'CURR';
  
    -- c������ "���������� TR"
    col_tr := get_ag_st_cat_num(tmonth, tyear, '����', 'AG');
    UPDATE ins_dwh.rep_tr_2 t
       SET t.tr_num = col_TR
     WHERE t.YEAR = tyear
       AND t.MONTH = tmonth
       AND t.period = 'CURR';
  
    -- c������ "���������� PT"
    col_pt := get_ag_part_time_num(tmonth, tyear);
    UPDATE ins_dwh.rep_tr_2 t
       SET t.pt_num = col_pt
     WHERE t.YEAR = tyear
       AND t.MONTH = tmonth
       AND t.period = 'CURR';
  
    -- c������ "���������� C"
    col_c := get_ag_st_cat_num(tmonth, tyear, '�������', 'AG');
    UPDATE ins_dwh.rep_tr_2 t
       SET t.c_num = col_c
     WHERE t.YEAR = tyear
       AND t.MONTH = tmonth
       AND t.period = 'CURR';
  
    -- c������ "���������� SC"
    col_sc := get_ag_st_cat_num(tmonth, tyear, '�������', 'AG');
    UPDATE ins_dwh.rep_tr_2 t
       SET t.sc_num = col_sc
     WHERE t.YEAR = tyear
       AND t.MONTH = tmonth
       AND t.period = 'CURR';
  
    -- c������ "���������� EC"
    col_ec := get_ag_st_cat_num(tmonth, tyear, '������', 'AG');
    UPDATE ins_dwh.rep_tr_2 t
       SET t.ec_num = col_ec
     WHERE t.YEAR = tyear
       AND t.MONTH = tmonth
       AND t.period = 'CURR';
  
    -- c������ "����� ���������� �������"
    col_tot := col_tr + col_pt + col_c + col_sc + col_ec;
    UPDATE ins_dwh.rep_tr_2 t
       SET t.tot_num = col_tot
     WHERE t.YEAR = tyear
       AND t.MONTH = tmonth
       AND t.period = 'CURR';
  
    -- ������� "������� ����������� UM"
    drop_UM   := get_agent_drop_number(tmonth, tyear, '%', 'MN');
    change_UM := get_ag_change_cat_num(tmonth, tyear, 'MN', 'AG', '%');
    IF col_UM = 0
    THEN
      drop_per_UM := 0;
    ELSE
      drop_per_UM := ((drop_UM + change_UM) / col_UM) * 100;
    END IF;
    UPDATE ins_dwh.rep_tr_2 t
       SET t.um_drop = drop_per_UM
     WHERE t.YEAR = tyear
       AND t.MONTH = tmonth
       AND t.period = 'CURR';
  
    -- ������� "������� ����������� TR"
    drop_tr   := get_agent_drop_number(tmonth, tyear, '����', 'AG');
    change_tr := get_ag_change_cat_num(tmonth, tyear, 'AG', 'MN', '����');
    IF col_tr = 0
    THEN
      drop_per_tr := 0;
    ELSE
      drop_per_tr := ((drop_tr + change_tr) / col_tr) * 100;
    END IF;
    UPDATE ins_dwh.rep_tr_2 t
       SET t.tr_drop = drop_per_tr
     WHERE t.YEAR = tyear
       AND t.MONTH = tmonth
       AND t.period = 'CURR';
  
    -- ������� "������� ����������� FT"
    drop_C    := get_agent_drop_number(tmonth, tyear, '�������', 'AG');
    drop_SC   := get_agent_drop_number(tmonth, tyear, '�������', 'AG');
    drop_EC   := get_agent_drop_number(tmonth, tyear, '������', 'AG');
    change_C  := get_ag_change_cat_num(tmonth, tyear, 'AG', 'MN', '�������');
    change_SC := get_ag_change_cat_num(tmonth, tyear, 'AG', 'MN', '�������');
    change_EC := get_ag_change_cat_num(tmonth, tyear, 'AG', 'MN', '������');
  
    IF col_C = 0
    THEN
      drop_per_C := 0;
    ELSE
      drop_per_C := (drop_C + change_C) / col_C;
    END IF;
    IF col_SC = 0
    THEN
      drop_per_SC := 0;
    ELSE
      drop_per_SC := (drop_SC + change_SC) / col_SC;
    END IF;
    IF col_EC = 0
    THEN
      drop_per_EC := 0;
    ELSE
      drop_per_EC := (drop_EC + change_EC) / col_EC;
    END IF;
    drop_per_FT := ((drop_per_C + drop_per_SC + drop_per_EC) / 3) * 100;
    UPDATE ins_dwh.rep_tr_2 t
       SET t.ft_drop = drop_per_ft
     WHERE t.YEAR = tyear
       AND t.MONTH = tmonth
       AND t.period = 'CURR';
  
    -- ������� "������� ����������� PT"
    drop_PT := get_ag_part_time_num(tmonth, tyear);
    IF col_PT = 0
    THEN
      drop_per_PT := 0;
    ELSE
      drop_per_PT := (drop_PT / col_PT) * 100;
    END IF;
    UPDATE ins_dwh.rep_tr_2 t
       SET t.pt_drop = drop_per_pt
     WHERE t.YEAR = tyear
       AND t.MONTH = tmonth
       AND t.period = 'CURR';
  
    -- ������� "������� UM"
    sales_um := get_agent_sales(tmonth, tyear, '%', 'MN');
    UPDATE ins_dwh.rep_tr_2 t
       SET t.um_sales = sales_um
     WHERE t.YEAR = tyear
       AND t.MONTH = tmonth
       AND t.period = 'CURR';
  
    -- ������� "������� TR"
    sales_tr := get_agent_sales(tmonth, tyear, '����', 'AG');
    UPDATE ins_dwh.rep_tr_2 t
       SET t.tr_sales = sales_tr
     WHERE t.YEAR = tyear
       AND t.MONTH = tmonth
       AND t.period = 'CURR';
  
    -- ������� "������� PT"
    sales_pt := get_ag_sales_part_time(tmonth, tyear);
    UPDATE ins_dwh.rep_tr_2 t
       SET t.pt_sales = sales_pt
     WHERE t.YEAR = tyear
       AND t.MONTH = tmonth
       AND t.period = 'CURR';
  
    -- ������� "������� C"
    sales_c := get_agent_sales(tmonth, tyear, '�������', 'AG');
    UPDATE ins_dwh.rep_tr_2 t
       SET t.c_sales = sales_c
     WHERE t.YEAR = tyear
       AND t.MONTH = tmonth
       AND t.period = 'CURR';
  
    -- ������� "������� SC"
    sales_sc := get_agent_sales(tmonth, tyear, '�������', 'AG');
    UPDATE ins_dwh.rep_tr_2 t
       SET t.sc_sales = sales_sc
     WHERE t.YEAR = tyear
       AND t.MONTH = tmonth
       AND t.period = 'CURR';
  
    -- ������� "������� EC"
    sales_ec := get_agent_sales(tmonth, tyear, '������', 'AG');
    UPDATE ins_dwh.rep_tr_2 t
       SET t.ec_sales = sales_ec
     WHERE t.YEAR = tyear
       AND t.MONTH = tmonth
       AND t.period = 'CURR';
  
    -- ������� "������� ������ �������"
    sales_um_gr := get_sales_um_groop(tmonth, tyear);
    UPDATE ins_dwh.rep_tr_2 t
       SET t.um_groop_sales = sales_um_gr
     WHERE t.YEAR = tyear
       AND t.MONTH = tmonth
       AND t.period = 'CURR';
  
    -- ������� "����� �������"
    sales_total := sales_tr + sales_pt + sales_c + sales_sc + sales_ec + sales_um_gr;
    UPDATE ins_dwh.rep_tr_2 t
       SET t.tot_ape = sales_total
     WHERE t.YEAR = tyear
       AND t.MONTH = tmonth
       AND t.period = 'CURR';
  
    -- ������� "������� UM - YTD"
    sales_um_ytd := get_agent_sales_ytd(tmonth, tyear, '%', 'MN');
    UPDATE ins_dwh.rep_tr_2 t
       SET t.um_sales = sales_um_ytd
     WHERE t.YEAR = tyear
       AND t.MONTH = tmonth
       AND t.period = 'YTD';
  
    -- ������� "������� TR - YTD"
    sales_tr_ytd := get_agent_sales_ytd(tmonth, tyear, '����', 'AG');
    UPDATE ins_dwh.rep_tr_2 t
       SET t.tr_sales = sales_tr_ytd
     WHERE t.YEAR = tyear
       AND t.MONTH = tmonth
       AND t.period = 'YTD';
  
    -- ������� "������� PT - YTD"
    sales_pt_ytd := get_ag_sales_part_time_ytd(tmonth, tyear);
    UPDATE ins_dwh.rep_tr_2 t
       SET t.pt_sales = sales_pt_ytd
     WHERE t.YEAR = tyear
       AND t.MONTH = tmonth
       AND t.period = 'YTD';
  
    -- ������� "������� C - YTD"
    sales_c_ytd := get_agent_sales_ytd(tmonth, tyear, '�������', 'AG');
    UPDATE ins_dwh.rep_tr_2 t
       SET t.c_sales = sales_c_ytd
     WHERE t.YEAR = tyear
       AND t.MONTH = tmonth
       AND t.period = 'YTD';
  
    -- ������� "������� SC - YTD"
    sales_sc_ytd := get_agent_sales_ytd(tmonth, tyear, '�������', 'AG');
    UPDATE ins_dwh.rep_tr_2 t
       SET t.sc_sales = sales_sc_ytd
     WHERE t.YEAR = tyear
       AND t.MONTH = tmonth
       AND t.period = 'YTD';
  
    -- ������� "������� EC - YTD"
    sales_ec_ytd := get_agent_sales_ytd(tmonth, tyear, '������', 'AG');
    UPDATE ins_dwh.rep_tr_2 t
       SET t.ec_sales = sales_ec_ytd
     WHERE t.YEAR = tyear
       AND t.MONTH = tmonth
       AND t.period = 'YTD';
  
    -- ������� "������� ������ �������" � ����������� ������
    sales_um_gr_ytd := get_sales_um_groop_ytd(tmonth, tyear);
    UPDATE ins_dwh.rep_tr_2 t
       SET t.um_groop_sales = sales_um_gr_ytd
     WHERE t.YEAR = tyear
       AND t.MONTH = tmonth
       AND t.period = 'YTD';
  
    -- ������� "����� �������"
    sales_total_ytd := sales_TR_ytd + sales_PT_ytd + sales_C_ytd + sales_SC_ytd + sales_EC_ytd +
                       sales_um_gr_ytd;
    UPDATE ins_dwh.rep_tr_2 t
       SET t.tot_ape = sales_total_ytd
     WHERE t.YEAR = tyear
       AND t.MONTH = tmonth
       AND t.period = 'YTD';
  
    -- ������� "�������������� UM"
    IF col_um = 0
    THEN
      prod_um := 0;
    ELSE
      prod_um := sales_um / col_um;
    END IF;
    UPDATE ins_dwh.rep_tr_2 t
       SET t.um_prod = prod_um
     WHERE t.YEAR = tyear
       AND t.MONTH = tmonth
       AND t.period = 'CURR';
  
    -- ������� "�������������� TR"
    IF col_tr = 0
    THEN
      prod_tr := 0;
    ELSE
      prod_tr := sales_tr / col_tr;
    END IF;
    UPDATE ins_dwh.rep_tr_2 t
       SET t.tr_prod = prod_tr
     WHERE t.YEAR = tyear
       AND t.MONTH = tmonth
       AND t.period = 'CURR';
  
    -- ������� "�������������� PT"
    IF col_pt = 0
    THEN
      prod_pt := 0;
    ELSE
      prod_pt := sales_pt / col_pt;
    END IF;
    UPDATE ins_dwh.rep_tr_2 t
       SET t.pt_prod = prod_pt
     WHERE t.YEAR = tyear
       AND t.MONTH = tmonth
       AND t.period = 'CURR';
  
    -- ������� "�������������� C"
    IF col_c = 0
    THEN
      prod_c := 0;
    ELSE
      prod_c := sales_c / col_c;
    END IF;
    UPDATE ins_dwh.rep_tr_2 t
       SET t.c_prod = prod_c
     WHERE t.YEAR = tyear
       AND t.MONTH = tmonth
       AND t.period = 'CURR';
  
    -- ������� "�������������� SC"
    IF col_sc = 0
    THEN
      prod_sc := 0;
    ELSE
      prod_sc := sales_sc / col_sc;
    END IF;
    UPDATE ins_dwh.rep_tr_2 t
       SET t.sc_prod = prod_sc
     WHERE t.YEAR = tyear
       AND t.MONTH = tmonth
       AND t.period = 'CURR';
  
    -- ������� "�������������� EC"
    IF col_ec = 0
    THEN
      prod_ec := 0;
    ELSE
      prod_ec := sales_ec / col_ec;
    END IF;
    UPDATE ins_dwh.rep_tr_2 t
       SET t.ec_prod = prod_ec
     WHERE t.YEAR = tyear
       AND t.MONTH = tmonth
       AND t.period = 'CURR';
  
    -- ������� "����� ��������������"
    prod_total := prod_tr + prod_pt + prod_c + prod_sc + prod_ec;
    UPDATE ins_dwh.rep_tr_2 t
       SET t.tot_prod = prod_total
     WHERE t.YEAR = tyear
       AND t.MONTH = tmonth
       AND t.period = 'CURR';
  
    -- ������� "������� ��������"
    sales_br := get_ag_sales_chanal(tmonth, tyear, 'BR');
    UPDATE ins_dwh.rep_tr_2 t
       SET t.br_ape = sales_br
     WHERE t.YEAR = tyear
       AND t.MONTH = tmonth
       AND t.period = 'CURR';
  
    -- ������� "������� ������"
    sales_b := get_ag_sales_chanal(tmonth, tyear, 'BANK');
    UPDATE ins_dwh.rep_tr_2 t
       SET t.banc_ape = sales_b
     WHERE t.YEAR = tyear
       AND t.MONTH = tmonth
       AND t.period = 'CURR';
  
    -- ������� "������� ������ �������"
    sales_oth := get_ag_sales_other_chanal(tmonth, tyear);
    UPDATE ins_dwh.rep_tr_2 t
       SET t.other_ape = sales_oth
     WHERE t.YEAR = tyear
       AND t.MONTH = tmonth
       AND t.period = 'CURR';
  
    -- ������� "����� ������� �� ���� �������"
    sales_ch_total := sales_total + sales_br + sales_b + sales_oth;
    UPDATE ins_dwh.rep_tr_2 t
       SET t.tot_ape_crand = sales_ch_total
     WHERE t.YEAR = tyear
       AND t.MONTH = tmonth
       AND t.period = 'CURR';
  
    -- ������� "������� �������� - YTD"
    sales_br_ytd := get_ag_sales_chanal_ytd(tmonth, tyear, 'BR');
    UPDATE ins_dwh.rep_tr_2 t
       SET t.br_ape = sales_br_ytd
     WHERE t.YEAR = tyear
       AND t.MONTH = tmonth
       AND t.period = 'YTD';
  
    -- ������� "������� ������ - YTD"
    sales_b_ytd := get_ag_sales_chanal_ytd(tmonth, tyear, 'BANK');
    UPDATE ins_dwh.rep_tr_2 t
       SET t.banc_ape = sales_b_ytd
     WHERE t.YEAR = tyear
       AND t.MONTH = tmonth
       AND t.period = 'YTD';
  
    -- ������� "������� ������ ������� - YTD"
    sales_oth_ytd := get_ag_sales_other_chanal_ytd(tmonth, tyear);
    UPDATE ins_dwh.rep_tr_2 t
       SET t.other_ape = sales_oth_ytd
     WHERE t.YEAR = tyear
       AND t.MONTH = tmonth
       AND t.period = 'YTD';
  
    -- ������� "����� ������� �� ���� ������� - YTD"
    sales_ch_total_ytd := sales_total_ytd + sales_br_ytd + sales_b_ytd + sales_oth_ytd;
    UPDATE ins_dwh.rep_tr_2 t
       SET t.tot_ape_crand = sales_ch_total_ytd
     WHERE t.YEAR = tyear
       AND t.MONTH = tmonth
       AND t.period = 'YTD';
  
    -- ������� "���������� ��������������� �������"
    ag_recr := get_agent_number(tmonth, tyear);
    UPDATE ins_dwh.rep_tr_2 t
       SET t.ag_recr = ag_recr
     WHERE t.YEAR = tyear
       AND t.MONTH = tmonth
       AND t.period = 'CURR';
    COMMIT;
  END;

  -- ************************************************************************
  --/////////////////////////END TRACKING REPORT 2///////////////////////////
  -- ************************************************************************

  -- ************************************************************************
  --//////////////////////////NEW and EXISTING BUSINESS REPORT///////////////
  -- ************************************************************************

  -- ���������� id ���������, ����������� ���������� � ������� ������
  FUNCTION get_pol_dep_ch_id
  (
    dep_id NUMBER
   ,ch_br  VARCHAR2
  ) RETURN tbl_id
    PIPELINED IS
    -- ��������� ����������
    t_dep_id VARCHAR2(10); -- id ���������
    t_ch_br  VARCHAR2(30); -- c���������� ������ ������
  BEGIN
    -- ������������� ����������
    IF (dep_id = -1 OR dep_id IS NULL)
    THEN
      t_dep_id := '%';
    ELSE
      t_dep_id := dep_id;
    END IF;
  
    IF ch_br IS NULL
    THEN
      t_ch_br := '%';
    ELSE
      t_ch_br := ch_br;
    END IF;
  
    -- ��������� �������
    FOR rec IN (SELECT DISTINCT ph.*
                  FROM ins.ven_p_pol_header ph
                  JOIN ins.ven_t_sales_channel sch
                    ON ph.sales_channel_id = sch.ID
                 WHERE sch.brief LIKE t_ch_br
                   AND ph.agency_id LIKE t_dep_id)
    LOOP
      PIPE ROW(rec.policy_header_id);
    END LOOP;
    RETURN;
  END;

  -- ���������� ���������� ���������, ������������������ � ��������� ������
  FUNCTION get_notice_num
  (
    dleft     DATE
   ,dright    DATE
   ,depart_id VARCHAR2
   ,chanal    VARCHAR2
  ) RETURN NUMBER IS
    num NUMBER; -- ���������� ���������
  BEGIN
    SELECT COUNT(*)
      INTO num
      FROM ins.ven_p_pol_header ph
      JOIN ins.ven_p_policy pp
        ON pp.policy_id = ph.policy_id
      JOIN (SELECT * FROM TABLE(pkg_rep_utils_ins11.get_pol_dep_ch_id(depart_id, chanal))) tbl
        ON ph.policy_header_id = tbl.COLUMN_VALUE
     WHERE pp.notice_date BETWEEN dleft AND dright;
    RETURN(num);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
  END;

  -- ���������� ����� ������ �� ����������, ������������������ � ��������� ������
  FUNCTION get_notice_premium
  (
    dleft     DATE
   ,dright    DATE
   ,depart_id VARCHAR2
   ,chanal    VARCHAR2
  ) RETURN NUMBER IS
    summa NUMBER; --  ����� ������
  BEGIN
    SELECT SUM(pp.premium * ins.acc_new.Get_Cross_Rate_By_Id((SELECT t.rate_type_id
                                                               FROM ins.ven_rate_type t
                                                              WHERE t.brief = '��')
                                                            ,ph.fund_id
                                                            ,(SELECT f.fund_id
                                                               FROM ins.ven_fund f
                                                              WHERE f.brief = 'RUR')
                                                            ,pp.notice_date))
      INTO summa
      FROM ins.ven_p_pol_header ph
      JOIN ins.ven_p_policy pp
        ON pp.policy_id = ph.policy_id
      JOIN (SELECT * FROM TABLE(pkg_rep_utils_ins11.get_pol_dep_ch_id(depart_id, chanal))) tbl
        ON ph.policy_header_id = tbl.COLUMN_VALUE
     WHERE pp.notice_date BETWEEN dleft AND dright;
    RETURN(summa);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
  END;

  -- ���������� ���������� �������, ������� ��������� � ��������� ������
  FUNCTION get_pol_active_num
  (
    dleft     DATE
   ,dright    DATE
   ,depart_id VARCHAR2
   ,chanal    VARCHAR2
  ) RETURN NUMBER IS
    num NUMBER; -- ���������� ���������
  BEGIN
    SELECT COUNT(*)
      INTO num
      FROM ins.ven_p_pol_header ph
      JOIN ins.ven_p_policy pp
        ON pp.policy_id = ph.policy_id
      JOIN (SELECT * FROM TABLE(pkg_rep_utils_ins11.get_pol_dep_ch_id(depart_id, chanal))) tbl
        ON ph.policy_header_id = tbl.COLUMN_VALUE
     WHERE ins.doc.get_status_date(pp.policy_id, 'ACTIVE') BETWEEN dleft AND dright;
    RETURN(num);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
  END;

  -- ���������� ����� ������ �� �������, ��������� ��������� � ��������� ������
  FUNCTION get_pol_active_premium
  (
    dleft     DATE
   ,dright    DATE
   ,depart_id VARCHAR2
   ,chanal    VARCHAR2
  ) RETURN NUMBER IS
    summa NUMBER; -- ����� ������
  BEGIN
    SELECT SUM(pp.premium * ins.acc_new.Get_Cross_Rate_By_Id((SELECT t.rate_type_id
                                                               FROM ins.ven_rate_type t
                                                              WHERE t.brief = '��')
                                                            ,ph.fund_id
                                                            ,(SELECT f.fund_id
                                                               FROM ins.ven_fund f
                                                              WHERE f.brief = 'RUR')
                                                            ,pp.notice_date))
      INTO summa
      FROM ins.ven_p_pol_header ph
      JOIN ins.ven_p_policy pp
        ON pp.policy_id = ph.policy_id
      JOIN (SELECT * FROM TABLE(pkg_rep_utils_ins11.get_pol_dep_ch_id(depart_id, chanal))) tbl
        ON ph.policy_header_id = tbl.COLUMN_VALUE
     WHERE ins.doc.get_status_date(pp.policy_id, 'ACTIVE') BETWEEN dleft AND dright;
    RETURN(summa);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
  END;

  -- ���������� ���������� ���������, ������������������ � ��������� ������
  -- � ������� "������" ��� "��������� � �����������"
  FUNCTION get_notice_outside_num
  (
    dleft     DATE
   ,dright    DATE
   ,depart_id VARCHAR2
   ,chanal    VARCHAR2
  ) RETURN NUMBER IS
    num NUMBER; -- ���������� ���������
  BEGIN
    SELECT COUNT(*)
      INTO num
      FROM ins.ven_p_pol_header ph
      JOIN ins.ven_p_policy pp
        ON pp.policy_id = ph.policy_id
      JOIN (SELECT * FROM TABLE(pkg_rep_utils_ins11.get_pol_dep_ch_id(depart_id, chanal))) tbl
        ON ph.policy_header_id = tbl.COLUMN_VALUE
     WHERE pp.notice_date BETWEEN dleft AND dright
       AND ins.doc.get_doc_status_brief(pp.policy_id) IN ('PROJECT', 'READY_TO_CANCEL');
    RETURN(num);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
  END;

  -- ���������� ����� ������ �� ����������, ������������������ � ��������� ������
  -- � ������� "������" ��� "��������� � �����������"
  FUNCTION get_notice_outside_premium
  (
    dleft     DATE
   ,dright    DATE
   ,depart_id VARCHAR2
   ,chanal    VARCHAR2
  ) RETURN NUMBER IS
    summa NUMBER; --����� ������
  BEGIN
    SELECT SUM(pp.premium * ins.acc_new.Get_Cross_Rate_By_Id((SELECT t.rate_type_id
                                                               FROM ins.ven_rate_type t
                                                              WHERE t.brief = '��')
                                                            ,ph.fund_id
                                                            ,(SELECT f.fund_id
                                                               FROM ins.ven_fund f
                                                              WHERE f.brief = 'RUR')
                                                            ,pp.notice_date))
      INTO summa
      FROM ins.ven_p_pol_header ph
      JOIN ins.ven_p_policy pp
        ON pp.policy_id = ph.policy_id
      JOIN (SELECT * FROM TABLE(pkg_rep_utils_ins11.get_pol_dep_ch_id(depart_id, chanal))) tbl
        ON ph.policy_header_id = tbl.COLUMN_VALUE
     WHERE pp.notice_date BETWEEN dleft AND dright
       AND ins.doc.get_doc_status_brief(pp.policy_id) IN ('PROJECT', 'READY_TO_CANCEL');
    RETURN(summa);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
  END;

  -- ���������� ���������� �������, ����������� ������ � ��������� ������
  FUNCTION get_agent_have_sales_num
  (
    dleft     DATE
   ,dright    DATE
   ,depart_id VARCHAR2
   ,chanal    VARCHAR2
  ) RETURN NUMBER IS
    num NUMBER; -- ���������� �������
    -- ��������� ����������
    t_dep_id VARCHAR2(10); -- id ���������
    t_ch_br  VARCHAR2(30); -- c��������� ������ ������
  BEGIN
    -- ������������� ����������
    IF (depart_id = -1 OR depart_id IS NULL)
    THEN
      t_dep_id := '%';
    ELSE
      t_dep_id := depart_id;
    END IF;
  
    IF chanal IS NULL
    THEN
      t_ch_br := '%';
    ELSE
      t_ch_br := chanal;
    END IF;
  
    SELECT COUNT(DISTINCT agch.agent_id)
      INTO num
      FROM ins.ven_ag_contract_header agch
      JOIN ins.ven_p_policy_agent ppag
        ON ppag.ag_contract_header_id = agch.ag_contract_header_id
      JOIN ins.ven_p_pol_header ph
        ON ppag.policy_header_id = ph.policy_header_id
      JOIN ins.ven_p_policy pp
        ON pp.policy_id = ph.policy_id
      JOIN ins.ven_t_sales_channel sch
        ON ph.sales_channel_id = sch.ID
     WHERE pp.notice_date BETWEEN dleft AND dright
       AND NVL(TO_CHAR(agch.agency_id), t_dep_id) LIKE t_dep_id
       AND sch.brief LIKE t_ch_br;
    RETURN(num);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
  END;

  -- ���������� ����� ���������� �������, ���������� �� ������������ ����
  FUNCTION get_total_agent_number
  (
    dright    DATE
   ,depart_id VARCHAR2
   ,chanal    VARCHAR2
  ) RETURN NUMBER IS
    num NUMBER; -- ����� ���������� �������
    -- ��������� ����������
    t_dep_id VARCHAR2(10); -- id ���������
    t_ch_br  VARCHAR2(30); -- c���������� ������ ������
  BEGIN
    -- ������������� ����������
    IF depart_id = -1
    THEN
      t_dep_id := '%';
    ELSE
      t_dep_id := depart_id;
    END IF;
  
    IF chanal IS NULL
    THEN
      t_ch_br := '%';
    ELSE
      t_ch_br := chanal;
    END IF;
  
    SELECT COUNT(agch.agent_id)
      INTO num
      FROM ins.ven_ag_contract_header agch
      JOIN ins.ven_ag_contract agc
        ON agc.ag_contract_id = agch.last_ver_id
      JOIN ins.ven_t_sales_channel sch
        ON agch.t_sales_channel_id = sch.ID
     WHERE NVL(get_ag_contract_end_date(agc.ag_contract_id), dright + 1) > dright
          --or get_ag_contract_end_date(agc.ag_contract_id) is null)
       AND NVL(TO_CHAR(agch.agency_id), t_dep_id) LIKE t_dep_id
       AND sch.brief LIKE t_ch_br;
    RETURN(num);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
  END;

  -- ���������� ������� � ���������� ������������� � ������� ������
  -- ���� "��������", id ��������, ����� ������
  FUNCTION get_list_departments_chanals(dright DATE) RETURN tbl_ag_ch
    PIPELINED IS
  BEGIN
    -- ������� ����������� ���������
    FOR ag_rec IN (SELECT DISTINCT get_pol_agency_name(dep.department_id)
                                  ,dep.department_id
                                  ,sch.brief
                     FROM ins.ven_ag_contract_header agch
                     JOIN ins.ven_department dep
                       ON dep.department_id = agch.agency_id
                     JOIN ins.ven_t_sales_channel sch
                       ON sch.ID = agch.t_sales_channel_id
                    WHERE NVL(dep.date_close, dright + 1) > dright
                      AND sch.brief = 'MLM')
    LOOP
      PIPE ROW(ag_rec);
    END LOOP;
    -- ��������� ������ ������
    FOR ch_rec IN (SELECT sch.description || ' ����� ������'
                         ,-1
                         ,sch.brief
                     FROM ins.ven_t_sales_channel sch
                    WHERE sch.brief != 'MLM')
    LOOP
      PIPE ROW(ch_rec);
    END LOOP;
    RETURN;
  END;

  -- ��������� ������ � ������� rep_neb
  PROCEDURE insert_row_to_rep_neb
  (
    fday    DATE
   ,fperiod VARCHAR2
   ,fregion VARCHAR2
   ,fblock  VARCHAR2
   ,fparam  VARCHAR2
   ,fvalue  NUMBER
  ) IS
  BEGIN
    INSERT INTO ins_dwh.rep_neb rn
      (DAY, period, region, BLOCK, param, VALUE)
    VALUES
      (fday, fperiod, fregion, fblock, fparam, fvalue);
  END;

  -- ��������� ������ � ������� rep_neb
  PROCEDURE update_row_to_rep_neb
  (
    fday    DATE
   ,fperiod VARCHAR2
   ,fregion VARCHAR2
   ,fblock  VARCHAR2
   ,fparam  VARCHAR2
   ,fvalue  NUMBER
  ) IS
  BEGIN
    UPDATE ins_dwh.rep_neb rn
       SET VALUE = fvalue
     WHERE rn.DAY = fday
       AND rn.period = fperiod
       AND rn.region = fregion
       AND rn.BLOCK = fblock
       AND rn.param = fparam;
  END;

  -- ��������� �������� ������������ ������ New and Exsiting Business report �� ����
  PROCEDURE create_day_neb(dright DATE) IS
    -- ����������� ����������
    pol_act_num      NUMBER := 0; --���������� �������� ���������
    pol_act_prem     NUMBER := 0; --������ �� �������� ���������
    pol_out_num      NUMBER := 0; --���������� ������������ �������
    pol_out_prem     NUMBER := 0; --������ �� ������������ ���������
    ag_active_num_m  NUMBER := 0; -- ���������� �������� �������
    ag_tot_num_m     NUMBER := 0; -- ����� ���������� �������
    prod_ag_act_not  NUMBER := 0; -- �������������� �������� ������� �� ����������
    prod_ag_act_prem NUMBER := 0; -- �������������� �������� ������� �� ������
    prod_ag_tot_not  NUMBER := 0; --�������������� ��� ������� �� ����������
    prod_ag_tot_prem NUMBER := 0; -- �������������� ���� ������� �� ������
  
    -- ��������������� ����������
    dep_name VARCHAR2(200); -- �������� ���������
    d_id     VARCHAR2(10); -- ��� �������� id ��������
  
    d_name VARCHAR(250); -- ��� �������� ����� ��������
  
  BEGIN
    -- ������ ������� 
    DELETE ins_dwh.rep_neb rn WHERE rn.DAY = dright;
  
    DBMS_OUTPUT.PUT_LINE(TO_CHAR(dright, 'yyyy.mm.dd.hh24.mi.ss'));
  
    --/*
    --ag_active_num_m:= get_agent_have_sales_num(trunc(dright,'mm'),dright,d_id,ch_br);
    --ag_tot_num_m:= get_total_agent_number(dright,d_id,ch_br);
  
    FOR rec IN (SELECT tbl.dep_name
                      ,tbl.dep_id
                      ,tbl.sh_br
                       -- ***********************
                       -- �� ����
                       -- ***********************
                      ,SUM(CASE
                             WHEN tbl.not_date = dright THEN
                              1
                             ELSE
                              0
                           END) AS notice_num --notice_num
                      ,SUM(CASE
                             WHEN tbl.not_date = dright THEN
                              pp.premium * ins.acc_new.Get_Cross_Rate_By_Id((SELECT t.rate_type_id
                                                                              FROM ins.ven_rate_type t
                                                                             WHERE t.brief = '��')
                                                                           ,ph.fund_id
                                                                           ,(SELECT f.fund_id
                                                                              FROM ins.ven_fund f
                                                                             WHERE f.brief = 'RUR')
                                                                           ,pp.notice_date)
                             ELSE
                              0
                           END) AS notice_prem -- notice_prem
                       /*     ,sum(case
                                    when to_char((ins.doc.get_status_date(pp.policy_id, 'ACTIVE'))= dright
                         --                and tbl.not_date = dright 
                                         then
                                         1
                                    else
                                         0
                                    end) as pol_act_num -- pol_act_num
                             ,sum(case
                                    when trunc (ins.doc.get_status_date(pp.policy_id, 'ACTIVE'))= dright
                       --                 and tbl.not_date = dright 
                                         then
                                         pp.premium* 
                                         ins.acc_new.Get_Cross_Rate_By_Id(
                                                      (select t.rate_type_id 
                                                              from ins.ven_rate_type t 
                                                              where t.brief ='��' ),
                                                       ph.fund_id,
                                                       (select f.fund_id from ins.ven_fund f where f.brief = 'RUR'),
                                                       pp.notice_date
                                                       )
                                    else
                                         0
                                    end) as pol_act_prem  -- pol_act_prem  */
                       /*      ,sum(case
                                when ins.doc.get_doc_status_brief(pp.policy_id) = ('PROJECT') 
                                and ins.doc.get_doc_status_brief(pp.policy_id) != ('READY_TO_CANCEL')
                                    and tbl.not_date = dright 
                                     then
                                     1
                                else
                                     0
                                end) as pol_out_num  -- pol_out_num
                         ,sum(case
                                when ins.doc.get_doc_status_brief(pp.policy_id) = ('PROJECT') 
                                and ins.doc.get_doc_status_brief(pp.policy_id) != ('READY_TO_CANCEL') 
                                 and tbl.not_date = dright 
                       then
                                    pp.premium * 
                                    ins.acc_new.Get_Cross_Rate_By_Id(
                                                  (select t.rate_type_id 
                                                          from ins.ven_rate_type t 
                                                          where t.brief ='��' ),
                                                   ph.fund_id,
                                                   (select f.fund_id from ins.ven_fund f where f.brief = 'RUR'),
                                                   pp.notice_date
                                                   )
                                else
                                     0
                                end) as pol_out_prem  -- pol_out_prem */
                       
                       -- ***********************
                       -- �� �����
                       -- ***********************
                       
                      ,COUNT(pp.policy_id) AS notice_num_m --notice_num_m
                      ,SUM(pp.premium * ins.acc_new.Get_Cross_Rate_By_Id((SELECT t.rate_type_id
                                                                           FROM ins.ven_rate_type t
                                                                          WHERE t.brief = '��')
                                                                        ,ph.fund_id
                                                                        ,(SELECT f.fund_id
                                                                           FROM ins.ven_fund f
                                                                          WHERE f.brief = 'RUR')
                                                                        ,pp.notice_date)) AS notice_prem_m -- notice_prem_m
                       
                      ,SUM(CASE
                             WHEN TRUNC(ins.doc.get_status_date(pp.policy_id, 'ACTIVE')) <= dright
                                  AND TRUNC(ins.doc.get_status_date(pp.policy_id, 'ACTIVE')) >=
                                  TRUNC(dright, 'mm') THEN
                              1
                             ELSE
                              0
                           END) AS pol_act_num_m -- pol_act_num_m
                      ,SUM(CASE
                             WHEN TRUNC(ins.doc.get_status_date(pp.policy_id, 'ACTIVE')) = dright
                                  AND TRUNC(ins.doc.get_status_date(pp.policy_id, 'ACTIVE')) >=
                                  TRUNC(dright, 'mm') THEN
                              pp.premium * ins.acc_new.Get_Cross_Rate_By_Id((SELECT t.rate_type_id
                                                                              FROM ins.ven_rate_type t
                                                                             WHERE t.brief = '��')
                                                                           ,ph.fund_id
                                                                           ,(SELECT f.fund_id
                                                                              FROM ins.ven_fund f
                                                                             WHERE f.brief = 'RUR')
                                                                           ,pp.notice_date)
                             ELSE
                              0
                           END) AS pol_act_prem_m -- pol_act_prem_m 
                       
                      ,SUM(CASE
                             WHEN ins.doc.get_doc_status_brief(pp.policy_id) IN
                                  ('PROJECT', 'READY_TO_CANCEL') THEN
                              1
                             ELSE
                              0
                           END) AS pol_out_num_m -- pol_out_num_m
                      ,SUM(CASE
                             WHEN ins.doc.get_doc_status_brief(pp.policy_id) IN
                                  ('PROJECT', 'READY_TO_CANCEL') THEN
                              pp.premium * ins.acc_new.Get_Cross_Rate_By_Id((SELECT t.rate_type_id
                                                                              FROM ins.ven_rate_type t
                                                                             WHERE t.brief = '��')
                                                                           ,ph.fund_id
                                                                           ,(SELECT f.fund_id
                                                                              FROM ins.ven_fund f
                                                                             WHERE f.brief = 'RUR')
                                                                           ,pp.notice_date)
                             ELSE
                              0
                           END) AS pol_out_prem_m -- pol_out_prem_m 
                
                  FROM (SELECT NVL(DECODE(sch.brief
                                         ,'MLM'
                                         ,pkg_rep_utils_ins11.get_pol_agency_name(ph.agency_id)
                                         ,sch.description || ' ����� ������')
                                  ,'�������������� ����� ������') AS dep_name
                              ,NVL(ph.agency_id, -1) AS dep_id
                              ,sch.brief AS sh_br
                              ,pp.policy_id AS pol_id
                              ,pp.notice_date AS not_date
                          FROM ins.ven_p_pol_header ph
                          JOIN ins.ven_p_policy pp
                            ON ph.policy_header_id = pp.pol_header_id
                          JOIN ins.ven_t_sales_channel sch
                            ON ph.sales_channel_id = sch.ID
                         WHERE ins.pkg_rep_utils.get_notice_date(ph.policy_header_id) BETWEEN
                               TRUNC(dright, 'mm') AND dright
                           AND pp.version_num = (SELECT MAX(p.version_num)
                                                   FROM ins.ven_p_policy p
                                                  WHERE ph.policy_header_id = p.pol_header_id
                                                    AND p.start_date < = dright)
                        
                        ) tbl
                      ,ins.ven_p_policy pp
                      ,ins.ven_p_pol_header ph
                 WHERE pp.policy_id = tbl.pol_id
                   AND ph.policy_header_id = pp.pol_header_id
                 GROUP BY tbl.dep_name
                         ,tbl.dep_id
                         ,tbl.sh_br)
    LOOP
    
      IF (NVL(rec.dep_id, -1) = -1)
      THEN
        d_id := '%';
      ELSE
        d_id := TO_CHAR(rec.dep_id);
      END IF;
    
      ag_active_num_m  := 0;
      ag_tot_num_m     := 0;
      pol_act_num      := 0;
      pol_act_prem     := 0;
      prod_ag_act_not  := 0;
      prod_ag_act_prem := 0;
      prod_ag_tot_not  := 0;
      prod_ag_tot_prem := 0;
    
      -- ���������� ���������� �� �������
      -- ����� �������� �������
      SELECT COUNT(DISTINCT agch.agent_id)
        INTO ag_active_num_m
        FROM ins.ven_ag_contract_header agch
        JOIN ins.ven_p_policy_agent ppag
          ON ppag.ag_contract_header_id = agch.ag_contract_header_id
        JOIN ins.ven_p_pol_header ph
          ON ppag.policy_header_id = ph.policy_header_id
        JOIN ins.ven_p_policy pp
          ON pp.policy_id = ph.policy_id
        JOIN ins.ven_t_sales_channel sch
          ON ph.sales_channel_id = sch.ID
       WHERE pp.notice_date BETWEEN TRUNC(dright, 'mm') AND dright
         AND NVL(TO_CHAR(agch.agency_id), d_id) LIKE d_id
         AND sch.brief LIKE rec.sh_br;
    
      -- ����� ����� �������
      SELECT (COUNT(agch.agent_id))
        INTO ag_tot_num_m
        FROM ins.ven_ag_contract_header agch
        JOIN ins.ven_ag_contract agc
          ON agc.contract_id = agch.ag_contract_header_id
        JOIN ins.ven_t_sales_channel sch
          ON agch.t_sales_channel_id = sch.ID
       WHERE NVL(get_ag_contract_end_date(agc.ag_contract_id), dright + 1) > dright
         AND agc.reg_date = (SELECT MAX(a.reg_date)
                               FROM ins.ven_ag_contract a
                              WHERE agch.ag_contract_header_id = a.contract_id
                                AND a.reg_date < = dright)
         AND NVL(TO_CHAR(agch.agency_id), d_id) LIKE d_id
         AND sch.brief LIKE rec.sh_br;
    
      -- ���������� � ������ �������� ��������� 
      SELECT
      
       COUNT(TO_CHAR(ins.doc.get_doc_status_brief(pp.policy_id)))
      ,NVL(SUM(pp.premium * ins.acc_new.Get_Cross_Rate_By_Id((SELECT t.rate_type_id
                                                               FROM ins.ven_rate_type t
                                                              WHERE t.brief = '��')
                                                            ,ph.fund_id
                                                            ,(SELECT f.fund_id
                                                               FROM ins.ven_fund f
                                                              WHERE f.brief = 'RUR')
                                                            ,pp.notice_date))
          ,0)
      --,ph.agency_id                              
        INTO pol_act_num
            ,pol_act_prem
        FROM ins.ven_p_pol_header ph
        JOIN ins.ven_p_policy pp
          ON ph.policy_header_id = pp.pol_header_id
        JOIN ins.ven_t_sales_channel sch
          ON ph.sales_channel_id = sch.ID
       WHERE NVL(ph.agency_id, -1) LIKE d_id
         AND sch.brief LIKE rec.sh_br
         AND TO_CHAR((ins.doc.get_status_date(pp.policy_id, 'ACTIVE')), 'dd.mm.yyyy') =
             TO_CHAR(dright, 'dd.mm.yyyy');
    
      --  ���������� � ������ ��������� �� �������� ����, �� ������� ���������
    
      SELECT COUNT(TO_CHAR(ins.doc.get_doc_status_brief(pp.policy_id)))
             --as pol_out_num  -- pol_out_num
            ,NVL(SUM(pp.premium * ins.acc_new.Get_Cross_Rate_By_Id((SELECT t.rate_type_id
                                                                     FROM ins.ven_rate_type t
                                                                    WHERE t.brief = '��')
                                                                  ,ph.fund_id
                                                                  ,(SELECT f.fund_id
                                                                     FROM ins.ven_fund f
                                                                    WHERE f.brief = 'RUR')
                                                                  ,pp.notice_date))
                ,0)
        INTO pol_out_num
            ,pol_out_prem
        FROM ins.ven_p_pol_header ph
        JOIN ins.ven_p_policy pp
          ON ph.policy_header_id = pp.pol_header_id
        JOIN ins.ven_t_sales_channel sch
          ON ph.sales_channel_id = sch.ID
       WHERE NVL(ph.agency_id, -1) LIKE d_id
         AND sch.brief LIKE rec.sh_br
         AND ins.doc.get_doc_status_brief(pp.policy_id) = ('PROJECT')
         AND ins.doc.get_doc_status_brief(pp.policy_id) != ('READY_TO_CANCEL')
         AND TO_CHAR(pp.notice_date, 'dd.mm.yyyy') = TO_CHAR(dright, 'dd.mm.yyyy');
      -- ��������� �������� ����������
      d_name := rec.dep_name;
    
      IF (NVL(ag_active_num_m, 1) <> 0)
      THEN
        prod_ag_act_not := rec.notice_num_m / ag_active_num_m;
      ELSE
        prod_ag_act_not := 0;
      END IF;
    
      IF (NVL(ag_active_num_m, 1) <> 0)
      THEN
        prod_ag_act_prem := rec.notice_prem_m / ag_active_num_m;
      ELSE
        prod_ag_act_prem := 0;
      END IF;
    
      IF (ag_tot_num_m <> 0)
      THEN
        prod_ag_tot_not := rec.notice_num_m / ag_tot_num_m;
      ELSE
        prod_ag_tot_not := 0;
      END IF;
    
      IF (ag_tot_num_m <> 0)
      THEN
        prod_ag_tot_prem := rec.notice_prem_m / ag_tot_num_m;
      ELSE
        prod_ag_tot_prem := 0;
      END IF;
    
      -- ���������� ���������
      insert_row_to_rep_neb(dright, 'at date', d_name, 'Proposals received', 'Number', rec.notice_num);
    
      -- ������ �� ����������
      insert_row_to_rep_neb(dright
                           ,'at date'
                           ,d_name
                           ,'Proposals received'
                           ,'Premium'
                           ,rec.notice_prem);
    
      -- ���������� �������� �������
      insert_row_to_rep_neb(dright, 'at date', d_name, 'Active policies', 'Number', pol_act_num);
    
      -- ������ �� �������� �������
      insert_row_to_rep_neb(dright, 'at date', d_name, 'Active policies', 'Premium', pol_act_prem);
    
      -- ���������� ������������ �������
      insert_row_to_rep_neb(dright, 'at date', d_name, 'Outstanding policies', 'Number', pol_out_num);
    
      -- ������ �� ������������ �������
      insert_row_to_rep_neb(dright
                           ,'at date'
                           ,d_name
                           ,'Outstanding policies'
                           ,'Premium'
                           ,pol_out_prem);
    
      -- ���������� ��������� �� ������
      insert_row_to_rep_neb(dright
                           ,'month to date'
                           ,d_name
                           ,'Proposals received'
                           ,'Number'
                           ,rec.notice_num_m);
    
      -- ������ �� ���������� �� ������
      insert_row_to_rep_neb(dright
                           ,'month to date'
                           ,d_name
                           ,'Proposals received'
                           ,'Premium'
                           ,rec.notice_prem_m);
    
      -- ���������� �������� ������� �� ������
      insert_row_to_rep_neb(dright
                           ,'month to date'
                           ,d_name
                           ,'Active policies'
                           ,'Number'
                           ,rec.pol_act_num_m);
    
      -- ������ �� �������� ������� �� ������
      insert_row_to_rep_neb(dright
                           ,'month to date'
                           ,d_name
                           ,'Active policies'
                           ,'Premium'
                           ,rec.pol_act_prem_m);
    
      -- ���������� ������������ ������� �� ������
      insert_row_to_rep_neb(dright
                           ,'month to date'
                           ,d_name
                           ,'Outstanding policies'
                           ,'Number'
                           ,rec.pol_out_num_m);
    
      -- ������ �� ������������ ������� �� ������
      insert_row_to_rep_neb(dright
                           ,'month to date'
                           ,d_name
                           ,'Outstanding policies'
                           ,'Premium'
                           ,rec.pol_out_prem_m);
    
      -- ���������� �������� �������
      insert_row_to_rep_neb(dright, 'month to date', d_name, 'Agents', 'Active', ag_active_num_m);
    
      insert_row_to_rep_neb(dright
                           ,'month to date'
                           ,d_name
                           ,'Agents'
                           ,'Agents contracts'
                           ,ag_tot_num_m);
    
      -- �������������� �������� ������� �� ����������
      insert_row_to_rep_neb(dright
                           ,'month to date'
                           ,d_name
                           ,'Productivity per active agents'
                           ,'Number'
                           ,prod_ag_act_not);
    
      -- �������������� �������� ������� �� ������
      insert_row_to_rep_neb(dright
                           ,'month to date'
                           ,d_name
                           ,'Productivity per active agents'
                           ,'Premium'
                           ,prod_ag_act_prem);
    
      -- �������������� ���� ������� �� ����������
      insert_row_to_rep_neb(dright
                           ,'month to date'
                           ,d_name
                           ,'Productivity per all agents'
                           ,'Number'
                           ,prod_ag_tot_not);
    
      -- �������������� ���� ������� �� ������
      insert_row_to_rep_neb(dright
                           ,'month to date'
                           ,d_name
                           ,'Productivity per all agents'
                           ,'Premium'
                           ,prod_ag_tot_prem);
    END LOOP;
    --*/
    COMMIT;
  END;

  -- ��������� �������� ������������ ������ New and Exsiting Business report �� ����
  PROCEDURE create_day_neb2(dright DATE) IS
    -- ������� �� ������� ����
    notice_num   NUMBER := 0; -- ���������� ���������
    notice_prem  NUMBER := 0; -- ������ �� ����������
    pol_act_num  NUMBER := 0; -- ���������� �������, ������� ���������
    pol_act_prem NUMBER := 0; -- ������ �� �������, �������� ���������
    pol_out_num  NUMBER := 0; -- ���������� ����������� �������
    pol_out_prem NUMBER := 0; -- ������ �� ����������� �������
  
    -- ������� �� ������
    notice_num_m   NUMBER := 0; -- ���������� ���������
    notice_prem_m  NUMBER := 0; -- ������ �� ����������
    pol_act_num_m  NUMBER := 0; -- ���������� �������, ������� ���������
    pol_act_prem_m NUMBER := 0; -- ������ �� �������, �������� ���������
    pol_out_num_m  NUMBER := 0; -- ���������� ����������� �������
    pol_out_prem_m NUMBER := 0; -- ������ �� ����������� �������
  
    ag_active_num_m  NUMBER := 0; -- ���������� �������� �������
    ag_tot_num_m     NUMBER := 0; -- ����� ���������� �������
    prod_ag_act_not  NUMBER := 0; -- �������������� �������� ������� �� ����������
    prod_ag_act_prem NUMBER := 0; -- �������������� �������� ������� �� ������
    prod_ag_tot_not  NUMBER := 0; --�������������� ��� ������� �� ����������
    prod_ag_tot_prem NUMBER := 0; -- �������������� ���� ������� �� ������
  
    -- ��������������� ����������
    row_day NUMBER := 0; -- ��� �������� ������������� ������
    d_id    VARCHAR2(10); -- ��� �������� id ��������
    ch_br   VARCHAR2(30); -- ��� �������� ����� ������ ������
    d_name  VARCHAR(250); -- ��� �������� ����� ��������
  
  BEGIN
    FOR rec IN (SELECT NAME
                      ,ag_id
                      ,ch_brief
                  FROM TABLE(pkg_rep_utils_ins11.get_list_departments_chanals(dright)))
    LOOP
      DBMS_OUTPUT.PUT_LINE('START ��� ' || d_name || ' �����: ' || TO_CHAR(SYSDATE, 'hh24:mi:ss'));
      -- ������� �������� ����������
      -- ////////////////////////////////////////////////////////////////////////
      IF (rec.ag_id = -1)
      THEN
        d_id := '%';
      ELSE
        d_id := TO_CHAR(rec.ag_id);
      END IF;
    
      IF (rec.ch_brief IS NULL)
      THEN
        ch_br := '%';
      ELSE
        ch_br := rec.ch_brief;
      END IF;
    
      d_name := rec.NAME;
    
      -- ������� ����
      notice_num   := get_notice_num(dright, dright, d_id, ch_br);
      notice_prem  := get_notice_premium(dright, dright, d_id, ch_br);
      pol_act_num  := get_pol_active_num(dright, dright, d_id, ch_br);
      pol_act_prem := get_pol_active_premium(dright, dright, d_id, ch_br);
      pol_out_num  := get_notice_outside_num(dright, dright, d_id, ch_br);
      pol_out_prem := get_notice_outside_premium(dright, dright, d_id, ch_br);
      -- �����
      notice_num_m   := get_notice_num(TRUNC(dright, 'mm'), dright, d_id, ch_br);
      notice_prem_m  := get_notice_premium(TRUNC(dright, 'mm'), dright, d_id, ch_br);
      pol_act_num_m  := get_pol_active_num(TRUNC(dright, 'mm'), dright, d_id, ch_br);
      pol_act_prem_m := get_pol_active_premium(TRUNC(dright, 'mm'), dright, d_id, ch_br);
      pol_out_num_m  := get_notice_outside_num(TRUNC(dright, 'mm'), dright, d_id, ch_br);
      pol_out_prem_m := get_notice_outside_premium(TRUNC(dright, 'mm'), dright, d_id, ch_br);
    
      ag_active_num_m := get_agent_have_sales_num(TRUNC(dright, 'mm'), dright, d_id, ch_br);
      ag_tot_num_m    := get_total_agent_number(dright, d_id, ch_br);
    
      IF (ag_active_num_m <> 0)
      THEN
        prod_ag_act_not := notice_num_m / ag_active_num_m;
      ELSE
        prod_ag_act_not := 0;
      END IF;
    
      IF (ag_active_num_m <> 0)
      THEN
        prod_ag_act_prem := notice_prem_m / ag_active_num_m;
      ELSE
        prod_ag_act_prem := 0;
      END IF;
    
      IF (ag_tot_num_m <> 0)
      THEN
        prod_ag_tot_not := notice_num_m / ag_tot_num_m;
      ELSE
        prod_ag_act_not := 0;
      END IF;
    
      IF (ag_tot_num_m <> 0)
      THEN
        prod_ag_tot_prem := notice_prem_m / ag_tot_num_m;
      ELSE
        prod_ag_act_prem := 0;
      END IF;
    
      -- ��������� ������������� ���� ��� �������
      -- ////////////////////////////////////////////////////////////////////////
      SELECT COUNT(*)
        INTO row_day
        FROM ins_dwh.rep_neb rn
       WHERE rn.DAY = dright
         AND rn.region = d_name;
      IF row_day = 0
      THEN
        -- ���������� ���������
        insert_row_to_rep_neb(dright, 'at date', d_name, 'Proposals received', 'Number', notice_num);
        --dbms_output.put_line('+ Proposals received number(D) ��� ' || d_name || ' �����: ' || to_char(sysdate, 'hh24:mi:ss'));
        -- ������ �� ����������
        insert_row_to_rep_neb(dright, 'at date', d_name, 'Proposals received', 'Premium', notice_prem);
        --dbms_output.put_line('+ Proposals received premium(D) ��� ' || d_name || ' �����: ' || to_char(sysdate, 'hh24:mi:ss'));
        -- ���������� �������� �������
        insert_row_to_rep_neb(dright, 'at date', d_name, 'Active policies', 'Number', pol_act_num);
        --dbms_output.put_line('+ Active policies number ���(D) ' || d_name || ' �����: ' || to_char(sysdate, 'hh24:mi:ss'));
        -- ������ �� �������� �������
        insert_row_to_rep_neb(dright, 'at date', d_name, 'Active policies', 'Premium', pol_act_prem);
        --dbms_output.put_line('+ Active policies premium(D) ��� ' || d_name || ' �����: ' || to_char(sysdate, 'hh24:mi:ss'));
        -- ���������� ������������ �������
        insert_row_to_rep_neb(dright
                             ,'at date'
                             ,d_name
                             ,'Outstanding policies'
                             ,'Number'
                             ,pol_out_num);
        --dbms_output.put_line('+ Outstanding policies number(D) ��� ' || d_name || ' �����: ' || to_char(sysdate, 'hh24:mi:ss'));
        -- ������ �� ������������ �������
        insert_row_to_rep_neb(dright
                             ,'at date'
                             ,d_name
                             ,'Outstanding policies'
                             ,'Premium'
                             ,pol_out_prem);
        --dbms_output.put_line('+ Outstanding policies premium(D) ��� ' || d_name || ' �����: ' || to_char(sysdate, 'hh24:mi:ss'));
      
        -- ���������� ��������� �� ������
        insert_row_to_rep_neb(dright
                             ,'month to date'
                             ,d_name
                             ,'Proposals received'
                             ,'Number'
                             ,notice_num_m);
        --dbms_output.put_line('+ Proposals received number(M) ��� ' || d_name || ' �����: ' || to_char(sysdate, 'hh24:mi:ss'));
        -- ������ �� ���������� �� ������
        insert_row_to_rep_neb(dright
                             ,'month to date'
                             ,d_name
                             ,'Proposals received'
                             ,'Premium'
                             ,notice_prem_m);
        --dbms_output.put_line('+ Proposals received premium(M) ��� ' || d_name || ' �����: ' || to_char(sysdate, 'hh24:mi:ss'));
        -- ���������� �������� ������� �� ������
        insert_row_to_rep_neb(dright
                             ,'month to date'
                             ,d_name
                             ,'Active policies'
                             ,'Number'
                             ,pol_act_num_m);
        --dbms_output.put_line('+ Active policies number(M) ��� ' || d_name || ' �����: ' || to_char(sysdate, 'hh24:mi:ss'));
        -- ������ �� �������� ������� �� ������
        insert_row_to_rep_neb(dright
                             ,'month to date'
                             ,d_name
                             ,'Active policies'
                             ,'Premium'
                             ,pol_act_prem_m);
        --dbms_output.put_line('+ Active policies premium(M) ��� ' || d_name || ' �����: ' || to_char(sysdate, 'hh24:mi:ss'));
        -- ���������� ������������ ������� �� ������
        insert_row_to_rep_neb(dright
                             ,'month to date'
                             ,d_name
                             ,'Outstanding policies'
                             ,'Number'
                             ,pol_out_num_m);
        --dbms_output.put_line('+ Outstanding policies number(M) ��� ' || d_name || ' �����: ' || to_char(sysdate, 'hh24:mi:ss'));
        -- ������ �� ������������ ������� �� ������
        insert_row_to_rep_neb(dright
                             ,'month to date'
                             ,d_name
                             ,'Outstanding policies'
                             ,'Premium'
                             ,pol_out_prem_m);
        --dbms_output.put_line('+ Outstanding policies premium(M) ��� ' || d_name || ' �����: ' || to_char(sysdate, 'hh24:mi:ss'));
      
        -- ���������� �������� �������
        insert_row_to_rep_neb(dright, 'month to date', d_name, 'Agents', 'Active', ag_active_num_m);
        --dbms_output.put_line('+ Agents active(M) ��� ' || d_name || ' �����: ' || to_char(sysdate, 'hh24:mi:ss'));
        -- ����� ���������� �������
        insert_row_to_rep_neb(dright
                             ,'month to date'
                             ,d_name
                             ,'Agents'
                             ,'Agents contracts'
                             ,ag_tot_num_m);
        --dbms_output.put_line('+ Agents total(M) ��� ' || d_name || ' �����: ' || to_char(sysdate, 'hh24:mi:ss'));
        -- �������������� �������� ������� �� ����������
        insert_row_to_rep_neb(dright
                             ,'month to date'
                             ,d_name
                             ,'Productivity per active agents'
                             ,'Number'
                             ,prod_ag_act_not);
        --dbms_output.put_line('+ Productivity number(M) ��� ' || d_name || ' �����: ' || to_char(sysdate, 'hh24:mi:ss'));
        -- �������������� �������� ������� �� ������
        insert_row_to_rep_neb(dright
                             ,'month to date'
                             ,d_name
                             ,'Productivity per active agents'
                             ,'Premium'
                             ,prod_ag_act_prem);
        --dbms_output.put_line('+ Productivity premium(M) ��� ' || d_name || ' �����: ' || to_char(sysdate, 'hh24:mi:ss'));
        -- �������������� ���� ������� �� ����������
        insert_row_to_rep_neb(dright
                             ,'month to date'
                             ,d_name
                             ,'Productivity per all agents'
                             ,'Number'
                             ,prod_ag_tot_not);
        --dbms_output.put_line('+ Productivity total number(M) ��� ' || d_name || ' �����: ' || to_char(sysdate, 'hh24:mi:ss'));
        -- �������������� ���� ������� �� ������
        insert_row_to_rep_neb(dright
                             ,'month to date'
                             ,d_name
                             ,'Productivity per all agents'
                             ,'Premium'
                             ,prod_ag_tot_prem);
        --dbms_output.put_line('+ Productivity total premium(M) ��� ' || d_name || ' �����: ' || to_char(sysdate, 'hh24:mi:ss'));
      ELSE
        -- ���������� ���������
        update_row_to_rep_neb(dright, 'at date', d_name, 'Proposals received', 'Number', notice_num);
        -- ������ �� ����������
        update_row_to_rep_neb(dright, 'at date', d_name, 'Proposals received', 'Premium', notice_prem);
        -- ���������� �������� �������
        update_row_to_rep_neb(dright, 'at date', d_name, 'Active policies', 'Number', pol_act_num);
        -- ������ �� �������� �������
        update_row_to_rep_neb(dright, 'at date', d_name, 'Active policies', 'Premium', pol_act_prem);
        -- ���������� ������������ �������
        update_row_to_rep_neb(dright
                             ,'at date'
                             ,d_name
                             ,'Outstanding policies'
                             ,'Number'
                             ,pol_out_num);
        -- ������ �� ������������ �������
        update_row_to_rep_neb(dright
                             ,'at date'
                             ,d_name
                             ,'Outstanding policies'
                             ,'Premium'
                             ,pol_out_prem);
      
        -- ���������� ��������� �� ������
        update_row_to_rep_neb(dright
                             ,'month to date'
                             ,d_name
                             ,'Proposals received'
                             ,'Number'
                             ,notice_num_m);
        -- ������ �� ���������� �� ������
        update_row_to_rep_neb(dright
                             ,'month to date'
                             ,d_name
                             ,'Proposals received'
                             ,'Premium'
                             ,notice_prem_m);
        -- ���������� �������� ������� �� ������
        update_row_to_rep_neb(dright
                             ,'month to date'
                             ,d_name
                             ,'Active policies'
                             ,'Number'
                             ,pol_act_num_m);
        -- ������ �� �������� ������� �� ������
        update_row_to_rep_neb(dright
                             ,'month to date'
                             ,d_name
                             ,'Active policies'
                             ,'Premium'
                             ,pol_act_prem_m);
        -- ���������� ������������ ������� �� ������
        update_row_to_rep_neb(dright
                             ,'month to date'
                             ,d_name
                             ,'Outstanding policies'
                             ,'Number'
                             ,pol_out_num_m);
        -- ������ �� ������������ ������� �� ������
        update_row_to_rep_neb(dright
                             ,'month to date'
                             ,d_name
                             ,'Outstanding policies'
                             ,'Premium'
                             ,pol_out_prem_m);
      
        -- ���������� �������� �������
        update_row_to_rep_neb(dright, 'month to date', d_name, 'Agents', 'Active', ag_active_num_m);
        -- ����� ���������� �������
        update_row_to_rep_neb(dright
                             ,'month to date'
                             ,d_name
                             ,'Agents'
                             ,'Agents contracts'
                             ,ag_tot_num_m);
        -- �������������� �������� ������� �� ����������
        update_row_to_rep_neb(dright
                             ,'month to date'
                             ,d_name
                             ,'Productivity per active agents'
                             ,'Number'
                             ,prod_ag_act_not);
        -- �������������� �������� ������� �� ������
        update_row_to_rep_neb(dright
                             ,'month to date'
                             ,d_name
                             ,'Productivity per active agents'
                             ,'Premium'
                             ,prod_ag_act_prem);
        -- �������������� ���� ������� �� ����������
        update_row_to_rep_neb(dright
                             ,'month to date'
                             ,d_name
                             ,'Productivity per all agents'
                             ,'Number'
                             ,prod_ag_tot_not);
        -- �������������� ���� ������� �� ������
        update_row_to_rep_neb(dright
                             ,'month to date'
                             ,d_name
                             ,'Productivity per all agents'
                             ,'Premium'
                             ,prod_ag_tot_prem);
      END IF;
      --dbms_output.put_line('FINISH ��� ' || d_name || ' �����: ' || to_char(sysdate, 'hh24:mi:ss'));
    END LOOP;
    --dbms_output.put_line('������� commit! �����: ' || to_char(sysdate, 'hh24:mi:ss'));
    COMMIT;
    --dbms_output.put_line('������� ���������! �����: ' || to_char(sysdate, 'hh24:mi:ss'));
  END;

  -- ************************************************************************
  --/////////////////////////END NEW and EXISTING BUSINESS REPORT////////////
  -- ************************************************************************

  -- ************************************************************************
  --///////////////////////// ����� �� �������� //////////////////////////
  -- ************************************************************************

  -- ���������� ������� � id ��������� (c_claim_header)
  -- � ��������� ��������� � ����� �����
  FUNCTION get_claim_header_id
  (
    br    VARCHAR2
   ,rtype VARCHAR2
  ) RETURN tbl_claim_id
    PIPELINED IS
    rt NUMBER;
  BEGIN
    -- ��������� ���� ������
    IF (rtype = 'GL')
    THEN
      rt := 1;
    ELSE
      IF (rtype = 'IL')
      THEN
        rt := 0;
      END IF;
    END IF;
    -- ������ id ���������
    FOR cl_rec IN (SELECT clh.*
                     FROM ins.ven_c_claim_header clh
                     JOIN ins.ven_p_policy pp
                       ON clh.p_policy_id = pp.policy_id
                     JOIN ins.ven_t_peril tp
                       ON tp.ID = clh.peril_id
                    WHERE pp.is_group_flag LIKE rt
                      AND tp.brief LIKE br)
    LOOP
      PIPE ROW(cl_rec.c_claim_header_id);
    END LOOP;
    RETURN;
  END;

  -- ���������� ���������� ���������, ����������� � ��������� ������
  -- � �������� �� �������� � ���� �����
  FUNCTION get_claim_number
  (
    br     VARCHAR2
   ,rtype  VARCHAR2
   ,dleft  DATE
   ,dright DATE
  ) RETURN NUMBER IS
    num NUMBER;
  BEGIN
    SELECT COUNT(*)
      INTO num
      FROM ins.ven_c_claim_header clh
      JOIN (SELECT * FROM TABLE(pkg_rep_utils_ins11.get_claim_header_id(br, rtype))) clh_id
        ON clh.c_claim_header_id = clh_id.COLUMN_VALUE
      JOIN ins.ven_c_event ce
        ON ce.c_event_id = clh.c_event_id
     WHERE ce.date_company BETWEEN dleft AND dright;
    RETURN(num);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  -- ���������� ���������� �����������, ��������� � ��������� ���, ���������� � ��������� ������
  -- � �������� �� �������� � ���� �����
  FUNCTION get_claim_pay_number
  (
    br     VARCHAR2
   ,rtype  VARCHAR2
   ,YEAR   VARCHAR2
   ,dleft  DATE
   ,dright DATE
  ) RETURN NUMBER IS
    num NUMBER;
  BEGIN
    SELECT COUNT(*)
      INTO num
      FROM ins.ven_c_claim_header clh
      JOIN (SELECT * FROM TABLE(pkg_rep_utils_ins11.get_claim_header_id(br, rtype))) clh_id
        ON clh.c_claim_header_id = clh_id.COLUMN_VALUE
      JOIN ins.ven_c_event ce
        ON ce.c_event_id = clh.c_event_id
      JOIN ins.ven_c_claim cc
        ON cc.c_claim_id = clh.active_claim_id
     WHERE TO_CHAR(ce.date_company, 'yyyy') LIKE YEAR
       AND ins.pkg_claim_payment.get_claim_pay_sum_per(cc.c_claim_id, dleft, dright) > 0;
    RETURN(num);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  -- ���������� ����� �� ��������� �� �����, ��������� � ��������� ���, ���������� � ��������� ������
  -- � �������� �� �������� � ���� �����
  FUNCTION get_claim_pay_amount
  (
    br     VARCHAR2
   ,rtype  VARCHAR2
   ,YEAR   VARCHAR2
   ,dleft  DATE
   ,dright DATE
  ) RETURN NUMBER IS
    amount NUMBER(11, 2);
  BEGIN
    SELECT SUM(ins.pkg_claim_payment.get_claim_pay_sum_per(cc.c_claim_id, dleft, dright))
      INTO amount
      FROM ins.ven_c_claim_header clh
      JOIN (SELECT * FROM TABLE(pkg_rep_utils_ins11.get_claim_header_id(br, rtype))) clh_id
        ON clh.c_claim_header_id = clh_id.COLUMN_VALUE
      JOIN ins.ven_c_event ce
        ON ce.c_event_id = clh.c_event_id
      JOIN ins.ven_c_claim cc
        ON cc.c_claim_id = clh.active_claim_id
     WHERE TO_CHAR(ce.date_company, 'yyyy') LIKE YEAR
       AND ins.pkg_claim_payment.get_claim_pay_sum_per(cc.c_claim_id, dleft, dright) > 0;
    RETURN(TO_CHAR(amount, '999999999D99'));
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  -- ���������� ���������� �����������, ����������� � ��������� ����, ����������� �� ������������
  -- � �������� �� �������� � ���� �����
  FUNCTION get_claim_pending_number
  (
    br    VARCHAR2
   ,rtype VARCHAR2
   ,YEAR  VARCHAR2
  ) RETURN NUMBER IS
    num NUMBER;
  BEGIN
    SELECT COUNT(*)
      INTO num
      FROM ins.ven_c_claim_header clh
      JOIN (SELECT * FROM TABLE(pkg_rep_utils_ins11.get_claim_header_id(br, rtype))) clh_id
        ON clh.c_claim_header_id = clh_id.COLUMN_VALUE
      JOIN ins.ven_c_claim cc
        ON cc.c_claim_id = clh.active_claim_id
      JOIN ins.ven_c_event ce
        ON ce.c_event_id = clh.c_event_id
     WHERE ins.doc.get_doc_status_brief(cc.c_claim_id) != 'CLOSE'
       AND TO_CHAR(ce.date_company, 'yyyy') = YEAR;
    RETURN(num);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  -- ���������� ��������������� ����� � ������� �� �����, ����������� � ��������� ���
  -- � �������� �� �������� � ���� �����
  FUNCTION get_panding_claims_amount
  (
    br    VARCHAR2
   ,rtype VARCHAR2
   ,YEAR  VARCHAR2
  ) RETURN NUMBER IS
    amount NUMBER(11, 2);
  BEGIN
    SELECT SUM(ins.pkg_claim_payment.get_claim_plan_sum(cc.c_claim_id))
      INTO amount
      FROM ins.ven_c_claim_header clh
      JOIN (SELECT * FROM TABLE(pkg_rep_utils_ins11.get_claim_header_id(br, rtype))) clh_id
        ON clh.c_claim_header_id = clh_id.COLUMN_VALUE
      JOIN ins.ven_c_event ce
        ON ce.c_event_id = clh.c_event_id
      JOIN ins.ven_c_claim cc
        ON cc.c_claim_id = clh.active_claim_id
     WHERE TO_CHAR(ce.date_company, 'yyyy') = YEAR;
    RETURN(TO_CHAR(amount, '999999999D99'));
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
  END;

  -- ���������� ���������� ���, � ������� �������� �� ����� ����������� � ��������� ����
  FUNCTION get_rejected_claims_number
  (
    br     VARCHAR2
   ,rtype  VARCHAR2
   ,YEAR   VARCHAR2
   ,dleft  DATE
   ,dright DATE
  ) RETURN NUMBER IS
    num NUMBER;
  BEGIN
    SELECT COUNT(*)
      INTO num
      FROM ins.ven_c_claim_header clh
      JOIN (SELECT * FROM TABLE(pkg_rep_utils_ins11.get_claim_header_id(br, rtype))) clh_id
        ON clh.c_claim_header_id = clh_id.COLUMN_VALUE
      JOIN ins.ven_c_claim cc
        ON cc.c_claim_id = clh.active_claim_id
      JOIN ins.ven_c_event ce
        ON ce.c_event_id = clh.c_event_id
     WHERE ins.doc.get_doc_status_brief(cc.c_claim_id) = 'CLOSE'
       AND NVL(ins.pkg_claim_payment.get_claim_payment_sum(cc.c_claim_id), 0) = 0
          --or ins.pkg_claim_payment.get_claim_payment_sum (cc.c_claim_id) is null)
       AND TO_CHAR(ce.date_company, 'yyyy') LIKE YEAR
       AND ins.doc.get_status_date(cc.c_claim_id, 'CLOSE') BETWEEN dleft AND dright;
    RETURN(num);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  -- ���������� ����� �� �����, ���������� � ��������� ����
  FUNCTION get_rejected_claims_amount
  (
    br     VARCHAR2
   ,rtype  VARCHAR2
   ,dleft  DATE
   ,dright DATE
  ) RETURN NUMBER IS
    amount NUMBER(11, 2);
  BEGIN
    SELECT SUM(ins.pkg_claim_payment.get_claim_plan_sum(cc.c_claim_id))
      INTO amount
      FROM ins.ven_c_claim_header clh
      JOIN (SELECT * FROM TABLE(pkg_rep_utils_ins11.get_claim_header_id(br, rtype))) clh_id
        ON clh.c_claim_header_id = clh_id.COLUMN_VALUE
      JOIN ins.ven_c_claim cc
        ON cc.c_claim_id = clh.active_claim_id
     WHERE ins.doc.get_doc_status_brief(cc.c_claim_id) = 'CLOSE'
       AND NVL(ins.pkg_claim_payment.get_claim_payment_sum(cc.c_claim_id), 0) = 0
          --or ins.pkg_claim_payment.get_claim_payment_sum (cc.c_claim_id) is null)
       AND ins.doc.get_status_date(cc.c_claim_id, 'CLOSE') BETWEEN dleft AND dright;
    RETURN(TO_CHAR(amount, '999999999D99'));
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
  END;

  -- ��������� ������ � ������� rep_payoff
  PROCEDURE insert_row_to_rep_payoff
  (
    fyear       VARCHAR2
   ,fmonth      VARCHAR2
   ,frisk_type  VARCHAR2
   ,frisk       VARCHAR2
   ,fparam      VARCHAR2
   ,fvalue      NUMBER
   ,frisk_brief VARCHAR2
   ,ftype_brief VARCHAR2
  ) IS
  BEGIN
    INSERT INTO ins_dwh.rep_payoff rp
      (YEAR, MONTH, risk_type, risk, param, VALUE, risk_brief, type_brief)
    VALUES
      (fyear, fmonth, frisk_type, frisk, fparam, fvalue, frisk_brief, ftype_brief);
  END;

  -- ��������� ������ � ������� rep_payoff
  PROCEDURE update_row_to_rep_payoff
  (
    fyear       VARCHAR2
   ,fmonth      VARCHAR2
   ,fparam      VARCHAR2
   ,fvalue      NUMBER
   ,frisk_brief VARCHAR2
   ,ftype_brief VARCHAR2
  ) IS
  BEGIN
    UPDATE ins_dwh.rep_payoff rp
       SET rp.VALUE = fvalue
     WHERE rp.YEAR = fyear
       AND rp.MONTH = fmonth
       AND rp.risk_brief = frisk_brief
       AND rp.type_brief = ftype_brief
       AND rp.param = fparam;
  END;

  -- ������������ ���������� ���� ����� � ������� ins_dwh.rep_payoff ��� ������ �����
  PROCEDURE insert_rep_payoff
  (
    tmonth   VARCHAR2
   ,tyear    VARCHAR2
   ,frisk    VARCHAR2
   ,frisk_br VARCHAR2
   ,ft_gr    VARCHAR2
  ) IS
    -- ������� �� ������� ����
    claim_num         NUMBER; -- ���������� ��������� �� �����
    claim_num_ytd     NUMBER; -- ���������� ��������� � ����������� ������
    claim_pay_num     NUMBER; -- ���������� ���������� ��������� �� ����� �� �����
    claim_pay_sum     NUMBER; -- ����� �� ���������� ���������� �� ����� �� �����
    claim_pay_num_ytd NUMBER; -- ���������� ���������� ��� � ����������� ������
    retr_pay_num      NUMBER; -- ���������� ���������� ��� �� �������������� ����
    retr_pay_sum      NUMBER; -- ���������� ����� �� ����� �� ��������������� ����
    claim_panding_num NUMBER; -- ���������� ��� �� ������������
    claim_panding_sum NUMBER; -- ����� � �������
    retr_panding_num  NUMBER; -- ���������� ��� �� ������������ �� ��������������� ����
    retr_panding_sum  NUMBER; -- ����� � ������� �� ��������������� ����
    gr_risk           NUMBER; -- ����� � ������� �� ���� ��������� ������
    ind_risk          NUMBER; -- ����� � ������� �� ���� �������������� ������
    --tot_risk number; -- ����� � ������� �� ����  ������
    retr_gr_risk      NUMBER; -- ����� � ������� �� ���� ��������� ������ � �������������
    retr_ind_risk     NUMBER; -- ����� � ������� �� ���� �������������� ������ � �������������
    retr_tot_risk     NUMBER; -- ����� � ������� �� ����  ������ � �������������
    claim_rej_num     NUMBER; -- ���������� ���������� ���
    retr_rej_num      NUMBER; -- ���������� ���������� ��� � �������������
    claim_rej_num_ytd NUMBER; -- ���������� ���������� ��� � ����������� ������
    claim_rej_sum_ytd NUMBER; -- ����� �� ���������� ����� � ����������� ������
  
    -- ��������������� ����������
    first_day  DATE; --  ������ ���� ������
    LAST_DAY   DATE; -- ��������� ���� ������
    y          NUMBER; -- ��� �������������
    k          NUMBER; -- ���������� ��� �������������
    ft_gr_name VARCHAR2(50); -- �������� �����
  
  BEGIN
    -- ���������� �������� ���� �����
    IF (ft_gr = 'GL')
    THEN
      ft_gr_name := 'Group Life';
    ELSE
      IF (ft_gr = 'IL')
      THEN
        ft_gr_name := 'Individual Life';
      END IF;
    END IF;
    -- ���������� ������ � ��������� ���� ������
    first_day := TO_DATE('01.' || tmonth || '.' || tyear, 'dd.mm.yyyy');
    LAST_DAY  := ADD_MONTHS(first_day, 1) - 1;
    -- ���������� ��� ��������������
    IF (TO_NUMBER(tyear) > 2007)
    THEN
      k := 3; -- ������� � 2008 ���� ������������� 3 ���������� ����
    ELSE
      k := 2; -- ���� ��� 2007, �� ������������� ������ 2 ���������� ����
    END IF;
  
    -- ������� ����������������� ����� �� ���������, �������������� ������
    -- ///////////////////////////////////////////////////////////////////
    y := TO_NUMBER(tyear);
    FOR l IN 0 .. k - 1
    LOOP
      -- ����������������� ����� �� ���� ��������� ������
      gr_risk      := get_panding_claims_amount('%', 'GL', TO_CHAR(y));
      retr_gr_risk := retr_gr_risk + gr_risk;
    
      ind_risk      := get_panding_claims_amount('%', 'IL', TO_CHAR(y));
      retr_ind_risk := retr_ind_risk + ind_risk;
      -- ����������������� ����� �� ���� �������������� ������
    
      -- ����������������� ����� �� ���� ������
      y := y - 1;
    END LOOP;
  
    -- ��������� ������
    -- ////////////////////////////////////////////////////////////////////////////
  
    -- ���������� ���������
    claim_num := get_claim_number(frisk_br, ft_gr, first_day, LAST_DAY);
    insert_row_to_rep_payoff(tyear
                            ,tmonth
                            ,ft_gr_name
                            ,frisk
                            ,'number of notifications'
                            ,claim_num
                            ,frisk_br
                            ,ft_gr);
  
    -- ���������� ��������� � ����������� ������ � ������ ����
    claim_num_ytd := get_claim_number(frisk_br
                                     ,ft_gr
                                     ,TO_DATE('01.01.' || tyear, 'dd.mm.yyyy')
                                     ,LAST_DAY);
    insert_row_to_rep_payoff(tyear
                            ,tmonth
                            ,ft_gr_name
                            ,frisk
                            ,'number of notifications accumulated ' || tyear
                            ,claim_num_ytd
                            ,frisk_br
                            ,ft_gr);
  
    -- ������������� �� ���������� �����
    y := TO_NUMBER(tyear);
    FOR j IN 0 .. k - 1
    LOOP
      -- ���������� ���������� ���
      claim_pay_num := get_claim_pay_number(frisk_br, ft_gr, TO_CHAR(y), first_day, LAST_DAY);
      insert_row_to_rep_payoff(tyear
                              ,tmonth
                              ,ft_gr_name
                              ,frisk
                              ,'number of claims ' || y || ' paid'
                              ,claim_pay_num
                              ,frisk_br
                              ,ft_gr);
      -- ����� �� ���������� �����
      claim_pay_sum := get_claim_pay_amount(frisk_br, ft_gr, TO_CHAR(y), first_day, LAST_DAY);
      insert_row_to_rep_payoff(tyear
                              ,tmonth
                              ,ft_gr_name
                              ,frisk
                              ,'amount of claims ' || y || ' paid'
                              ,claim_pay_sum
                              ,frisk_br
                              ,ft_gr);
      -- ���� �� �������������� ����� - ����� ���
      retr_pay_num := retr_pay_num + claim_pay_num;
      -- ���� �� ��������������� ����� - �����
      retr_pay_sum := retr_pay_sum + claim_pay_sum;
      y            := y - 1;
    END LOOP;
  
    -- ��������� ���� �� �������������� ����� - ����� ���
    insert_row_to_rep_payoff(tyear
                            ,tmonth
                            ,ft_gr_name
                            ,frisk
                            ,'number of claims paid in TOTAL'
                            ,retr_pay_num
                            ,frisk_br
                            ,ft_gr);
    -- ��������� ���� �� ��������������� ����� - �����
    insert_row_to_rep_payoff(tyear
                            ,tmonth
                            ,ft_gr_name
                            ,frisk
                            ,'accumulated claims paid amount in ' || tyear
                            ,retr_pay_sum
                            ,frisk_br
                            ,ft_gr);
  
    -- ���������� ���������� ������ �� ������� ���
    claim_pay_num_ytd := get_claim_pay_number(frisk_br
                                             ,ft_gr
                                             ,'%'
                                             ,TO_DATE('01.01.' || tyear, 'dd.mm.yyyy')
                                             ,LAST_DAY);
    insert_row_to_rep_payoff(tyear
                            ,tmonth
                            ,ft_gr_name
                            ,frisk
                            ,'accumulated number of claims paid in ' || tyear
                            ,claim_pay_num_ytd
                            ,frisk_br
                            ,ft_gr);
  
    -- ���� �� ������������ � ��������������
    y := TO_NUMBER(tyear);
    FOR j IN 0 .. k - 1
    LOOP
      -- ���������� ��� �� ������������
      claim_panding_num := get_claim_pending_number(frisk_br, ft_gr, TO_CHAR(y));
      insert_row_to_rep_payoff(tyear
                              ,tmonth
                              ,ft_gr_name
                              ,frisk
                              ,'number of pending claims ' || y
                              ,claim_panding_num
                              ,frisk_br
                              ,ft_gr);
      --���������� ��� �� ����������� � �������������
      retr_panding_num := retr_panding_num + claim_panding_num;
      y                := y - 1;
    END LOOP;
    -- ��������� ���������� ��� �� ����������� � �������������
    insert_row_to_rep_payoff(tyear
                            ,tmonth
                            ,ft_gr_name
                            ,frisk
                            ,'number of panding claims in TOTAL'
                            ,retr_panding_num
                            ,frisk_br
                            ,ft_gr);
  
    -- ����������������� ����� � ��������������
    y := TO_NUMBER(tyear);
    FOR j IN 0 .. k - 1
    LOOP
      -- ����������������� �����
      claim_panding_sum := get_panding_claims_amount(frisk_br, ft_gr, TO_CHAR(y));
      insert_row_to_rep_payoff(tyear
                              ,tmonth
                              ,ft_gr_name
                              ,frisk
                              ,'amount of panding claims ' || y
                              ,claim_panding_num
                              ,frisk_br
                              ,ft_gr);
      -- ����������������� ����� � �������������
      retr_panding_sum := retr_panding_sum + claim_panding_sum;
      y                := y - 1;
    END LOOP;
    -- ��������� ����������������� ����� � �������������
    insert_row_to_rep_payoff(tyear
                            ,tmonth
                            ,ft_gr_name
                            ,frisk
                            ,'amount of panding claims in TOTAL'
                            ,retr_panding_sum
                            ,frisk_br
                            ,ft_gr);
  
    -- ��������� ������� �� ���� ��������� ������
    IF (retr_gr_risk != 0)
    THEN
      insert_row_to_rep_payoff(tyear
                              ,tmonth
                              ,ft_gr_name
                              ,frisk
                              ,'percent of all groop claims in a period'
                              ,(retr_panding_sum / retr_gr_risk)
                              ,frisk_br
                              ,ft_gr);
    ELSE
      insert_row_to_rep_payoff(tyear
                              ,tmonth
                              ,ft_gr_name
                              ,frisk
                              ,'percent of all groop claims in a period'
                              ,0
                              ,frisk_br
                              ,ft_gr);
    END IF;
  
    -- ��������� ������� �� ���� ������
    IF (retr_tot_risk != 0)
    THEN
      insert_row_to_rep_payoff(tyear
                              ,tmonth
                              ,ft_gr_name
                              ,frisk
                              ,'percent of all claims in a period'
                              ,(retr_panding_sum / retr_tot_risk)
                              ,frisk_br
                              ,ft_gr);
    ELSE
      insert_row_to_rep_payoff(tyear
                              ,tmonth
                              ,ft_gr_name
                              ,frisk
                              ,'percent of all claims in a period'
                              ,0
                              ,frisk_br
                              ,ft_gr);
    END IF;
  
    -- ���������� ���������� ���
    y := TO_NUMBER(tyear);
    FOR j IN 0 .. k - 1
    LOOP
      -- ���������� ���������� ���
      claim_rej_num := get_rejected_claims_number(frisk_br, ft_gr, TO_CHAR(y), first_day, LAST_DAY);
      insert_row_to_rep_payoff(tyear
                              ,tmonth
                              ,ft_gr_name
                              ,frisk
                              ,'number of rejected claims ' || y
                              ,claim_rej_num
                              ,frisk_br
                              ,ft_gr);
      -- ���������� ���������� ��� � �������������
      retr_rej_num := retr_rej_num + claim_rej_num;
      y            := y - 1;
    END LOOP;
    -- ��������� ���������� ���������� ��� � �������������
    insert_row_to_rep_payoff(tyear
                            ,tmonth
                            ,ft_gr_name
                            ,frisk
                            ,'number of rejected claims in TOTAL'
                            ,retr_rej_num
                            ,frisk_br
                            ,ft_gr);
  
    -- ���������� ���������� ��� � ����������� ������
    claim_rej_num_ytd := get_rejected_claims_number(frisk_br
                                                   ,ft_gr
                                                   ,'%'
                                                   ,TO_DATE('01.01.' || tyear, 'dd.mm.yyyy')
                                                   ,LAST_DAY);
    insert_row_to_rep_payoff(tyear
                            ,tmonth
                            ,ft_gr_name
                            ,frisk
                            ,'number of rejected claims accumulated ' || tyear
                            ,claim_rej_num_ytd
                            ,frisk_br
                            ,ft_gr);
  
    -- ����� �� ���������� ����� � ����������� ������
    claim_rej_sum_ytd := get_rejected_claims_amount(frisk_br
                                                   ,ft_gr
                                                   ,TO_DATE('01.01.' || tyear, 'dd.mm.yyyy')
                                                   ,LAST_DAY);
    insert_row_to_rep_payoff(tyear
                            ,tmonth
                            ,ft_gr_name
                            ,frisk
                            ,'amount of rejected claims'
                            ,claim_rej_sum_ytd
                            ,frisk_br
                            ,ft_gr);
  END;

  -- ������������ ���������� ���� ����� � ������� ins_dwh.rep_payoff ��� ������ �����
  PROCEDURE update_rep_payoff
  (
    tmonth   VARCHAR2
   ,tyear    VARCHAR2
   ,frisk_br VARCHAR2
   ,ft_gr    VARCHAR2
  ) IS
    -- ������� �� ������� ����
    claim_num         NUMBER; -- ���������� ��������� �� �����
    claim_num_ytd     NUMBER; -- ���������� ��������� � ����������� ������
    claim_pay_num     NUMBER; -- ���������� ���������� ��������� �� ����� �� �����
    claim_pay_sum     NUMBER; -- ����� �� ���������� ���������� �� ����� �� �����
    claim_pay_num_ytd NUMBER; -- ���������� ���������� ��� � ����������� ������
    retr_pay_num      NUMBER; -- ���������� ���������� ��� �� �������������� ����
    retr_pay_sum      NUMBER; -- ���������� ����� �� ����� �� ��������������� ����
    claim_panding_num NUMBER; -- ���������� ��� �� ������������
    claim_panding_sum NUMBER; -- ����� � �������
    retr_panding_num  NUMBER; -- ���������� ��� �� ������������ �� ��������������� ����
    retr_panding_sum  NUMBER; -- ����� � ������� �� ��������������� ����
    gr_risk           NUMBER; -- ����� � ������� �� ���� ��������� ������
    ind_risk          NUMBER; -- ����� � ������� �� ���� �������������� ������
    --tot_risk number; -- ����� � ������� �� ����  ������
    retr_gr_risk      NUMBER; -- ����� � ������� �� ���� ��������� ������ � �������������
    retr_ind_risk     NUMBER; -- ����� � ������� �� ���� �������������� ������ � �������������
    retr_tot_risk     NUMBER; -- ����� � ������� �� ����  ������ � �������������
    claim_rej_num     NUMBER; -- ���������� ���������� ���
    retr_rej_num      NUMBER; -- ���������� ���������� ��� � �������������
    claim_rej_num_ytd NUMBER; -- ���������� ���������� ��� � ����������� ������
    claim_rej_sum_ytd NUMBER; -- ����� �� ���������� ����� � ����������� ������
  
    -- ��������������� ����������
    first_day DATE; --  ������ ���� ������
    LAST_DAY  DATE; -- ��������� ���� ������
    y         NUMBER; -- ��� �������������
    k         NUMBER; -- ���������� ��� �������������
  
  BEGIN
  
    -- ���������� ������ � ��������� ���� ������
    first_day := TO_DATE('01.' || tmonth || '.' || tyear, 'dd.mm.yyyy');
    LAST_DAY  := ADD_MONTHS(first_day, 1) - 1;
    -- ���������� ��� ��������������
    IF (TO_NUMBER(tyear) > 2007)
    THEN
      k := 3; -- ������� � 2008 ���� ������������� 3 ���������� ����
    ELSE
      k := 2; -- ���� ��� 2007, �� ������������� ������ 2 ���������� ����
    END IF;
  
    -- ������� ����������������� ����� �� ���������, �������������� ������
    -- ///////////////////////////////////////////////////////////////////
    y := TO_NUMBER(tyear);
    FOR l IN 0 .. k - 1
    LOOP
      -- ����������������� ����� �� ���� ��������� ������
      gr_risk      := get_panding_claims_amount('%', 'GL', TO_CHAR(y));
      retr_gr_risk := retr_gr_risk + gr_risk;
    
      ind_risk      := get_panding_claims_amount('%', 'IL', TO_CHAR(y));
      retr_ind_risk := retr_ind_risk + ind_risk;
      -- ����������������� ����� �� ���� �������������� ������
    
      -- ����������������� ����� �� ���� ������
      y := y - 1;
    END LOOP;
  
    -- ��������� ������
    -- ////////////////////////////////////////////////////////////////////////////
  
    -- ���������� ���������
    claim_num := get_claim_number(frisk_br, ft_gr, first_day, LAST_DAY);
    update_row_to_rep_payoff(tyear, tmonth, 'number of notifications', claim_num, frisk_br, ft_gr);
  
    -- ���������� ��������� � ����������� ������ � ������ ����
    claim_num_ytd := get_claim_number(frisk_br
                                     ,ft_gr
                                     ,TO_DATE('01.01.' || tyear, 'dd.mm.yyyy')
                                     ,LAST_DAY);
    update_row_to_rep_payoff(tyear
                            ,tmonth
                            ,'number of notifications accumulated ' || tyear
                            ,claim_num_ytd
                            ,frisk_br
                            ,ft_gr);
  
    -- ������������� �� ���������� �����
    y := TO_NUMBER(tyear);
    FOR j IN 0 .. k - 1
    LOOP
      -- ���������� ���������� ���
      claim_pay_num := get_claim_pay_number(frisk_br, ft_gr, TO_CHAR(y), first_day, LAST_DAY);
      update_row_to_rep_payoff(tyear
                              ,tmonth
                              ,'number of claims ' || y || ' paid'
                              ,claim_pay_num
                              ,frisk_br
                              ,ft_gr);
      -- ����� �� ���������� �����
      claim_pay_sum := get_claim_pay_amount(frisk_br, ft_gr, TO_CHAR(y), first_day, LAST_DAY);
      update_row_to_rep_payoff(tyear
                              ,tmonth
                              ,'amount of claims ' || y || ' paid'
                              ,claim_pay_sum
                              ,frisk_br
                              ,ft_gr);
      -- ���� �� �������������� ����� - ����� ���
      retr_pay_num := retr_pay_num + claim_pay_num;
      -- ���� �� ��������������� ����� - �����
      retr_pay_sum := retr_pay_sum + claim_pay_sum;
      y            := y - 1;
    END LOOP;
  
    -- ��������� ���� �� �������������� ����� - ����� ���
    update_row_to_rep_payoff(tyear
                            ,tmonth
                            ,'number of claims paid in TOTAL'
                            ,retr_pay_num
                            ,frisk_br
                            ,ft_gr);
    -- ��������� ���� �� ��������������� ����� - �����
    update_row_to_rep_payoff(tyear
                            ,tmonth
                            ,'accumulated claims paid amount in ' || tyear
                            ,retr_pay_sum
                            ,frisk_br
                            ,ft_gr);
  
    -- ���������� ���������� ������ �� ������� ���
    claim_pay_num_ytd := get_claim_pay_number(frisk_br
                                             ,ft_gr
                                             ,'%'
                                             ,TO_DATE('01.01.' || tyear, 'dd.mm.yyyy')
                                             ,LAST_DAY);
    update_row_to_rep_payoff(tyear
                            ,tmonth
                            ,'accumulated number of claims paid in ' || tyear
                            ,claim_pay_num_ytd
                            ,frisk_br
                            ,ft_gr);
  
    -- ���� �� ������������ � ��������������
    y := TO_NUMBER(tyear);
    FOR j IN 0 .. k - 1
    LOOP
      -- ���������� ��� �� ������������
      claim_panding_num := get_claim_pending_number(frisk_br, ft_gr, TO_CHAR(y));
      update_row_to_rep_payoff(tyear
                              ,tmonth
                              ,'number of pending claims ' || y
                              ,claim_panding_num
                              ,frisk_br
                              ,ft_gr);
      --���������� ��� �� ����������� � �������������
      retr_panding_num := retr_panding_num + claim_panding_num;
      y                := y - 1;
    END LOOP;
    -- ��������� ���������� ��� �� ����������� � �������������
    update_row_to_rep_payoff(tyear
                            ,tmonth
                            ,'number of panding claims in TOTAL'
                            ,retr_panding_num
                            ,frisk_br
                            ,ft_gr);
  
    -- ����������������� ����� � ��������������
    y := TO_NUMBER(tyear);
    FOR j IN 0 .. k - 1
    LOOP
      -- ����������������� �����
      claim_panding_sum := get_panding_claims_amount(frisk_br, ft_gr, TO_CHAR(y));
      update_row_to_rep_payoff(tyear
                              ,tmonth
                              ,'amount of panding claims ' || y
                              ,claim_panding_num
                              ,frisk_br
                              ,ft_gr);
      -- ����������������� ����� � �������������
      retr_panding_sum := retr_panding_sum + claim_panding_sum;
      y                := y - 1;
    END LOOP;
    -- ��������� ����������������� ����� � �������������
    update_row_to_rep_payoff(tyear
                            ,tmonth
                            ,'amount of panding claims in TOTAL'
                            ,retr_panding_sum
                            ,frisk_br
                            ,ft_gr);
  
    -- ��������� ������� �� ���� ��������� ������
    IF (retr_gr_risk != 0)
    THEN
      update_row_to_rep_payoff(tyear
                              ,tmonth
                              ,'percent of all groop claims in a period'
                              ,(retr_panding_sum / retr_gr_risk)
                              ,frisk_br
                              ,ft_gr);
    ELSE
      update_row_to_rep_payoff(tyear
                              ,tmonth
                              ,'percent of all groop claims in a period'
                              ,0
                              ,frisk_br
                              ,ft_gr);
    END IF;
  
    -- ��������� ������� �� ���� ������
    IF (retr_tot_risk != 0)
    THEN
      update_row_to_rep_payoff(tyear
                              ,tmonth
                              ,'percent of all claims in a period'
                              ,(retr_panding_sum / retr_tot_risk)
                              ,frisk_br
                              ,ft_gr);
    ELSE
      update_row_to_rep_payoff(tyear, tmonth, 'percent of all claims in a period', 0, frisk_br, ft_gr);
    END IF;
  
    -- ���������� ���������� ���
    y := TO_NUMBER(tyear);
    FOR j IN 0 .. k - 1
    LOOP
      -- ���������� ���������� ���
      claim_rej_num := get_rejected_claims_number(frisk_br, ft_gr, TO_CHAR(y), first_day, LAST_DAY);
      update_row_to_rep_payoff(tyear
                              ,tmonth
                              ,'number of rejected claims ' || y
                              ,claim_rej_num
                              ,frisk_br
                              ,ft_gr);
      -- ���������� ���������� ��� � �������������
      retr_rej_num := retr_rej_num + claim_rej_num;
      y            := y - 1;
    END LOOP;
    -- ��������� ���������� ���������� ��� � �������������
    update_row_to_rep_payoff(tyear
                            ,tmonth
                            ,'number of rejected claims in TOTAL'
                            ,retr_rej_num
                            ,frisk_br
                            ,ft_gr);
  
    -- ���������� ���������� ��� � ����������� ������
    claim_rej_num_ytd := get_rejected_claims_number(frisk_br
                                                   ,ft_gr
                                                   ,'%'
                                                   ,TO_DATE('01.01.' || tyear, 'dd.mm.yyyy')
                                                   ,LAST_DAY);
    update_row_to_rep_payoff(tyear
                            ,tmonth
                            ,'number of rejected claims accumulated ' || tyear
                            ,claim_rej_num_ytd
                            ,frisk_br
                            ,ft_gr);
  
    -- ����� �� ���������� ����� � ����������� ������
    claim_rej_sum_ytd := get_rejected_claims_amount(frisk_br
                                                   ,ft_gr
                                                   ,TO_DATE('01.01.' || tyear, 'dd.mm.yyyy')
                                                   ,LAST_DAY);
    update_row_to_rep_payoff(tyear
                            ,tmonth
                            ,'amount of rejected claims'
                            ,claim_rej_sum_ytd
                            ,frisk_br
                            ,ft_gr);
  
  END;

  -- �������� ������������ ������ � ��������
  PROCEDURE create_month_payoff
  (
    tmonth VARCHAR2
   ,tyear  VARCHAR2
  ) IS
    -- ��������������� ����������
    row_day VARCHAR2(10); -- ��� �������� ������������� ����
  
    -- ����
    TYPE t_risks_gr IS VARRAY(13) OF VARCHAR2(200); -- ��������� �����
    TYPE t_risks_gr_br IS VARRAY(13) OF VARCHAR2(30); -- ��������� ����� - ����������
    TYPE t_risks_ind IS VARRAY(11) OF VARCHAR2(200); -- �������������� �����
    TYPE t_risks_ind_br IS VARRAY(11) OF VARCHAR2(30); -- �������������� ����� - ����������
    -- ��������� �����
    ar_risk_gr t_risks_gr := t_risks_gr('General Death (GDB)'
                                       ,'Dread Disease (DD)'
                                       ,'Accidental Death Benefit (ADB)'
                                       ,'Total Permanent Disability any cause (TPD any cause)'
                                       ,'Total Permanent Disability accidental cause (TPD acc cause)'
                                       ,'Total and Partial Temporary Disability any cause (TPTD any cause)'
                                       ,'Total and Partial Temporary Disability accidental cause (TPTD acc cause)'
                                       ,'Bodily Injury (BI)'
                                       ,'Hospital Allowance any cause (HA any cause)'
                                       ,'Hospital Allowance accidental cause (HA acc cause)'
                                       ,'Accidental Surgery (S acc cause)'
                                       ,'Surgery any cause (S any cause)'
                                       ,'Consenquences of Arteriosclerosis (CA),of Cancer (CC),of Pregnancy, Delivery and Postpartum (CPDP), Consequences of Traumas (CT)');
  
    -- ��������� ����� (����������)                                    
    ar_risk_gr_br t_risks_gr_br := t_risks_gr_br('GDB'
                                                ,'DD'
                                                ,'ADB'
                                                ,'TPD_any'
                                                ,'TPD_acc'
                                                ,'TPTD_%'
                                                ,'TPTD_acc'
                                                ,'BI_%'
                                                ,'HA_any'
                                                ,'HA_acc'
                                                ,'S_acc'
                                                ,'S_any'
                                                ,'CA_CC_CPDP_CT');
  
    -- �������������� �����                                           
    ar_risk_ind t_risks_ind := t_risks_ind('General Death (GDB)'
                                          ,'Dread Disease (DD)'
                                          ,'Accidental Death Benefit (ADB)'
                                          ,'Total Permanent Disability any cause (TPD any cause)'
                                          ,'Total Permanent Disability accidental cause (TPD acc cause)'
                                          ,'Total and Partial Temporary Disability accidental cause (TPTD acc cause)'
                                          ,'Bodily Injury (BI)'
                                          ,'Hospital Allowance accidental cause (HA acc cause)'
                                          ,'Accidental Surgery (S acc cause)'
                                          ,'Waiver of Premium policy holder equal insured person (WP ph eq ip)'
                                          ,'Waiver of Premium policy holder not equal insured person (WP ph not eq ip)');
    -- �������������� ����� (����������)
    ar_risk_ind_br t_risks_ind_br := t_risks_ind_br('GDB'
                                                   ,'DD'
                                                   ,'ADB'
                                                   ,'TPD_any'
                                                   ,'TPD_acc'
                                                   ,'TPTD_acc'
                                                   ,'BI_%'
                                                   ,'HA_acc'
                                                   ,'S_acc'
                                                   ,'WP_1'
                                                   ,'WP_2_%');
  BEGIN
    row_day := 0;
  
    -- ��������� ������������� ����
    -- ////////////////////////////////////////////////////////////////////////
    SELECT COUNT(*)
      INTO row_day
      FROM ins_dwh.rep_payoff rp
     WHERE rp.MONTH = tmonth
       AND rp.YEAR = tyear;
  
    IF row_day = 0
    THEN
    
      -- ��������� ������ ��� ��������� ������
      FOR i IN 1 .. ar_risk_gr.COUNT
      LOOP
        insert_rep_payoff(tmonth, tyear, ar_risk_gr(i), ar_risk_gr_br(i), 'GL');
      END LOOP;
      -- ��������� ������ ��� �������������� ������
      FOR i IN 1 .. ar_risk_ind.COUNT
      LOOP
        insert_rep_payoff(tmonth, tyear, ar_risk_ind(i), ar_risk_ind_br(i), 'IL');
      END LOOP;
      --/*
    ELSE
    
      -- ��������� ������ ��� ��������� ������
      FOR i IN 1 .. ar_risk_gr.COUNT
      LOOP
        update_rep_payoff(tmonth, tyear, ar_risk_gr_br(i), 'GL');
      END LOOP;
      -- ��������� ������ ��� �������������� ������
      FOR i IN 1 .. ar_risk_ind.COUNT
      LOOP
        update_rep_payoff(tmonth, tyear, ar_risk_ind_br(i), 'IL');
      END LOOP;
      --*/
    END IF;
    COMMIT;
  END;

  -- ************************************************************************
  --/////////////////////////END ����� �� �������� //////////////////////////
  -- ************************************************************************

  -- ************************************************************************
  --/////////////////////////SALES REPORT WITHOUT PROGRAMM //////////////////
  -- ************************************************************************

  -- ���������� ������, ������������ �������
  FUNCTION get_agch_id_by_polid(p_pol_h_id NUMBER) RETURN NUMBER IS
    ag_id NUMBER; -- id ���������� �������� ��� ������, ������������ ������� �����������
  BEGIN
    SELECT tbl.agent_id
      INTO ag_id
      FROM (SELECT agch.agent_id
                  ,DECODE(sch.brief, 'CC', 1, 0) ord
              FROM ins.ven_p_pol_header ph
              JOIN ins.ven_p_policy_agent ppag
                ON ppag.policy_header_id = ph.policy_header_id
              JOIN ins.ven_ag_contract_header agch
                ON agch.ag_contract_header_id = ppag.ag_contract_header_id
              JOIN ins.ven_t_sales_channel sch
                ON sch.ID = agch.t_sales_channel_id
             WHERE ph.policy_header_id = p_pol_h_id
               AND ppag.date_start =
                   (SELECT MIN(pa.date_start)
                      FROM ins.ven_p_policy_agent pa
                     WHERE pa.policy_header_id = ph.policy_header_id)
             ORDER BY DECODE(sch.brief, 'CC', 1, 0)) tbl
     WHERE ROWNUM < 2;
    RETURN(ag_id);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
    
  END;

  -- ���������� �������� ���������, ������������ �������
  FUNCTION get_dep_id_by_polid(p_pol_header_id NUMBER) RETURN NUMBER IS
    dep_id NUMBER;
  BEGIN
    SELECT dep.department_id
      INTO dep_id
      FROM ins.ven_ag_contract_header agch
      JOIN ins.ven_department dep
        ON agch.agency_id = dep.department_id
     WHERE agch.agent_id = get_agch_id_by_polid(p_pol_header_id)
       AND ROWNUM < 2;
    RETURN(dep_id);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  -- ���������� �������� ���������, � �������� ��������� �����
  FUNCTION get_dep_id_by_agid(p_agent_id NUMBER) RETURN NUMBER IS
    dep_id NUMBER;
  BEGIN
    SELECT dep.department_id
      INTO dep_id
      FROM ins.ven_ag_contract_header agch
      JOIN ins.ven_department dep
        ON agch.agency_id = dep.department_id
     WHERE agch.agent_id = p_agent_id
       AND ROWNUM < 2;
    RETURN(dep_id);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  --/*
  -- ���������� ������� ���������, ����������� � ��������� ������
  -- � ��������� ������, ���������, ������ ������ � ��������
  FUNCTION get_tbl_ag_ch_pr
  (
    dleft  DATE
   ,dright DATE
  ) RETURN tbl_ag_ch_pr
    PIPELINED IS
  BEGIN
    -- ������� �������, ����������� � ������
    FOR t_rec IN (SELECT DISTINCT NVL(tbl.agent_id, -1)
                                 ,NVL(ins.ent.obj_name('CONTACT', tbl.agent_id), ' -') AS agent_fio
                                 ,NVL(tbl.dep_id, -1)
                                 ,NVL(tbl.dep_name, ' -')
                                 ,tbl.ch_br
                                 ,tbl.ch_name
                                 ,tbl.pr_br
                                 ,tbl.pr_name
                    FROM (SELECT DISTINCT (SELECT tt.ag_id
                                             FROM ins_dwh.rep_sr_ag tt
                                            WHERE tt.pol_id = ph.policy_header_id) AS agent_id
                                         ,sch.brief AS ch_br
                                         ,sch.description AS ch_name
                                         ,ph.agency_id AS dep_id
                                         ,pkg_rep_utils_ins11.get_pol_agency_name(ph.agency_id) AS dep_name
                                         ,pr.brief AS pr_br
                                         ,pr.description AS pr_name
                            FROM ins.ven_p_pol_header    ph
                                ,ins.ven_t_sales_channel sch
                                ,ins.ven_t_product       pr
                           WHERE ph.start_date BETWEEN dleft AND dright
                             AND sch.ID = ph.sales_channel_id
                             AND pr.product_id = ph.product_id) tbl)
    LOOP
      PIPE ROW(t_rec);
    END LOOP;
    RETURN;
  END;
  --*/

  /* �������
  -- ���������� ����� APE (������� ������ �� ���������)
  function get_ape_policy (tbl tbl_id) return number
  is
  summ number (11,2);
  begin
  select sum(pp.premium)
  into summ 
  from ins.ven_p_pol_header ph
  join ins.ven_p_policy pp on pp.policy_id = ph.policy_id
  join (select column_value from table(tbl)) f on ph.policy_header_id = f.column_value;
  return(to_char(summ,'999999999D99'));
  exception
  when others then return null;
  end;
  
  /*
  -- ������� �������
  -- ���������� id ���������, ����������� � ��������� ������
  function get_pol_id (dleft date, dright date) return tbl_id
  is
  tbl tbl_id;
  begin
  select ph.policy_header_id
  bulk collect into tbl
  from ins.ven_p_pol_header ph
  where ph.start_date between dleft and dright;
  return (tbl);
  end;
  */

  -- ���������� ����� APE �� ����������� ���������
  FUNCTION get_ape_policy
  (
    dleft  DATE
   ,dright DATE
   ,ag_id  NUMBER
   ,dep_id NUMBER
   ,ch_br  VARCHAR2
   ,pr_br  VARCHAR2
  ) RETURN NUMBER IS
    summ NUMBER(11, 2);
  BEGIN
    SELECT NVL(SUM(pp.premium), 0)
      INTO summ
      FROM ins.ven_p_pol_header ph
      JOIN ins.ven_p_policy pp
        ON pp.policy_id = ph.policy_id
      JOIN (SELECT *
              FROM TABLE(pkg_rep_utils_ins11.get_policy_id(dleft, dright, ag_id, dep_id, ch_br, pr_br))) f
        ON ph.policy_header_id = f.COLUMN_VALUE;
    RETURN(TO_CHAR(summ, '000000000D00'));
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  -- ���������� ����� APE �� ������������ ���������
  FUNCTION get_ape_pol_dec
  (
    dleft  DATE
   ,dright DATE
   ,ag_id  NUMBER
   ,dep_id NUMBER
   ,ch_br  VARCHAR2
   ,pr_br  VARCHAR2
  ) RETURN NUMBER IS
    summ NUMBER(11, 2);
  BEGIN
    SELECT NVL(SUM(pp.premium), 0)
      INTO summ
      FROM ins.ven_p_pol_header ph
      JOIN ins.ven_p_policy pp
        ON pp.policy_id = ph.policy_id
      JOIN (SELECT *
              FROM TABLE(pkg_rep_utils_ins11.get_pol_dec_anderr_id(dleft
                                                                  ,dright
                                                                  ,ag_id
                                                                  ,dep_id
                                                                  ,ch_br
                                                                  ,pr_br))) f
        ON ph.policy_header_id = f.COLUMN_VALUE;
    RETURN(TO_CHAR(summ, '000000000D00'));
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  -- ���������� ����� APE �� ������������ ��������� �� ���� ��������
  FUNCTION get_ape_pol_dec_oth
  (
    dleft  DATE
   ,dright DATE
   ,ag_id  NUMBER
   ,dep_id NUMBER
   ,ch_br  VARCHAR2
   ,pr_br  VARCHAR2
  ) RETURN NUMBER IS
    summ NUMBER(11, 2);
  BEGIN
    SELECT NVL(SUM(pp.premium), 0)
      INTO summ
      FROM ins.ven_p_pol_header ph
      JOIN ins.ven_p_policy pp
        ON pp.policy_id = ph.policy_id
      JOIN (SELECT *
              FROM TABLE(pkg_rep_utils_ins11.get_pol_dec_other_id(dleft
                                                                 ,dright
                                                                 ,ag_id
                                                                 ,dep_id
                                                                 ,ch_br
                                                                 ,pr_br))) f
        ON ph.policy_header_id = f.COLUMN_VALUE;
    RETURN(TO_CHAR(summ, '000000000D00'));
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  -- ���������� ����� APE �� �������� ���������
  FUNCTION get_ape_pol_act
  (
    dleft  DATE
   ,dright DATE
   ,ag_id  NUMBER
   ,dep_id NUMBER
   ,ch_br  VARCHAR2
   ,pr_br  VARCHAR2
  ) RETURN NUMBER IS
    summ NUMBER(11, 2);
  BEGIN
    SELECT NVL(SUM(pp.premium), 0)
      INTO summ
      FROM ins.ven_p_pol_header ph
      JOIN ins.ven_p_policy pp
        ON pp.policy_id = ph.policy_id
      JOIN (SELECT *
              FROM TABLE(pkg_rep_utils_ins11.get_pol_active_id(dleft
                                                              ,dright
                                                              ,ag_id
                                                              ,dep_id
                                                              ,ch_br
                                                              ,pr_br))) f
        ON ph.policy_header_id = f.COLUMN_VALUE;
    RETURN(TO_CHAR(summ, '000000000D00'));
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  -- ���������� ����� ���������� ������ �� ����������� ���������
  FUNCTION get_pol_pay_amount
  (
    dleft  DATE
   ,dright DATE
   ,ag_id  NUMBER
   ,dep_id NUMBER
   ,ch_br  VARCHAR2
   ,pr_br  VARCHAR2
  ) RETURN NUMBER IS
    summ NUMBER(11, 2);
  BEGIN
    SELECT NVL(SUM(ins.pkg_payment.get_pay_pol_header_amount_pfa(dleft, dright, ph.policy_header_id))
              ,0)
      INTO summ
      FROM ins.ven_p_pol_header ph
      JOIN (SELECT *
              FROM TABLE(pkg_rep_utils_ins11.get_policy_id(dleft, dright, ag_id, dep_id, ch_br, pr_br))) f
        ON ph.policy_header_id = f.COLUMN_VALUE;
    RETURN(TO_CHAR(summ, '000000000D00'));
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  -- ���������� ����� ���������� ������ �� �������� ���������
  FUNCTION get_pol_pay_amount_act
  (
    dleft  DATE
   ,dright DATE
   ,ag_id  NUMBER
   ,dep_id NUMBER
   ,ch_br  VARCHAR2
   ,pr_br  VARCHAR2
  ) RETURN NUMBER IS
    summ NUMBER(11, 2);
  BEGIN
    SELECT NVL(SUM(ins.pkg_payment.get_pay_pol_header_amount_pfa(dleft, dright, ph.policy_header_id))
              ,0)
      INTO summ
      FROM ins.ven_p_pol_header ph
      JOIN (SELECT *
              FROM TABLE(pkg_rep_utils_ins11.get_pol_active_id(dleft
                                                              ,dright
                                                              ,ag_id
                                                              ,dep_id
                                                              ,ch_br
                                                              ,pr_br))) f
        ON ph.policy_header_id = f.COLUMN_VALUE;
    RETURN(TO_CHAR(summ, '000000000D00'));
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  -- ���������� ����� �������� �� ������������ ���������
  FUNCTION get_pol_dec_amount
  (
    dleft  DATE
   ,dright DATE
   ,ag_id  NUMBER
   ,dep_id NUMBER
   ,ch_br  VARCHAR2
   ,pr_br  VARCHAR2
  ) RETURN NUMBER IS
    summ NUMBER(11, 2);
  BEGIN
    SELECT NVL(SUM(pp.decline_summ), 0)
      INTO summ
      FROM ins.ven_p_pol_header ph
      JOIN ins.ven_p_policy pp
        ON pp.policy_id = ph.policy_id
      JOIN (SELECT *
              FROM TABLE(pkg_rep_utils_ins11.get_pol_dec_anderr_id(dleft
                                                                  ,dright
                                                                  ,ag_id
                                                                  ,dep_id
                                                                  ,ch_br
                                                                  ,pr_br))) f
        ON ph.policy_header_id = f.COLUMN_VALUE;
    RETURN(TO_CHAR(summ, '000000000D00'));
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  -- ���������� ����� �������� �� ������������ ��������� �� ���� ��������
  FUNCTION get_pol_dec_amount_oth
  (
    dleft  DATE
   ,dright DATE
   ,ag_id  NUMBER
   ,dep_id NUMBER
   ,ch_br  VARCHAR2
   ,pr_br  VARCHAR2
  ) RETURN NUMBER IS
    summ NUMBER(11, 2);
  BEGIN
    SELECT NVL(SUM(pp.decline_summ), 0)
      INTO summ
      FROM ins.ven_p_pol_header ph
      JOIN ins.ven_p_policy pp
        ON pp.policy_id = ph.policy_id
      JOIN (SELECT *
              FROM TABLE(pkg_rep_utils_ins11.get_pol_dec_other_id(dleft
                                                                 ,dright
                                                                 ,ag_id
                                                                 ,dep_id
                                                                 ,ch_br
                                                                 ,pr_br))) f
        ON ph.policy_header_id = f.COLUMN_VALUE;
    RETURN(TO_CHAR(summ, '000000000D00'));
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  -- ��������� ������� ������������ "id ������ - id ������"
  PROCEDURE fill_tbl_pol_ag
  (
    dleft  DATE
   ,dright DATE
  ) IS
  BEGIN
    -- ������ ������� 
    DELETE ins_dwh.rep_sr_ag;
    -- ��������� �������
    FOR rec IN (SELECT ph.policy_header_id AS pol_id
                      ,pkg_rep_utils_ins11.get_agch_id_by_polid(ph.policy_header_id) AS ag_id
                  FROM ins.ven_p_pol_header ph
                 WHERE ph.start_date BETWEEN dleft AND dright)
    LOOP
      INSERT INTO ins_dwh.rep_sr_ag tt (tt.pol_id, tt.ag_id) VALUES (rec.pol_id, NVL(rec.ag_id, -1));
    END LOOP;
    COMMIT;
  END;

  -- ���������� id ���������, ����������� � ������
  FUNCTION get_policy_id
  (
    dleft  DATE
   ,dright DATE
   ,ag_id  NUMBER
   ,dep_id NUMBER
   ,ch_br  VARCHAR2
   ,pr_br  VARCHAR2
  ) RETURN tbl_id
    PIPELINED IS
    -- ��������� ����������
    t_ag_id  VARCHAR2(10); -- id ������
    t_dep_id VARCHAR2(10); -- id ���������
    t_ch_br  VARCHAR2(30); -- c��������� ������ ������
    t_pr_br  VARCHAR2(30); -- ���������� ��������
  BEGIN
    -- ������������� ����������
    IF ag_id IS NULL
    THEN
      t_ag_id := '-1';
    ELSE
      t_ag_id := ag_id;
    END IF;
  
    IF dep_id IS NULL
    THEN
      t_dep_id := '-1';
    ELSE
      t_dep_id := dep_id;
    END IF;
    --/*
    IF ch_br IS NULL
    THEN
      t_ch_br := '%';
    ELSE
      t_ch_br := ch_br;
    END IF;
  
    IF pr_br IS NULL
    THEN
      t_pr_br := '%';
    ELSE
      t_pr_br := pr_br;
    END IF;
    --*/
    -- ��������� �������
    FOR rec IN (
                
                SELECT tbl.policy_header_id
                  FROM (SELECT ph.policy_header_id
                               ,(SELECT tt.ag_id
                                   FROM ins_dwh.rep_sr_ag tt
                                  WHERE tt.pol_id = ph.policy_header_id) AS ag_id
                           FROM ins.ven_p_pol_header ph
                           JOIN ins.ven_t_sales_channel sch
                             ON sch.ID = ph.sales_channel_id
                           JOIN ins.ven_t_product pr
                             ON pr.product_id = ph.product_id
                          WHERE ph.start_date BETWEEN dleft AND dright
                            AND sch.brief LIKE t_ch_br
                            AND pr.brief LIKE t_pr_br
                            AND NVL(TO_CHAR(ph.agency_id), -1) LIKE t_dep_id) tbl
                 WHERE NVL(TO_CHAR(tbl.ag_id), -1) LIKE t_ag_id
                
                )
    LOOP
      PIPE ROW(rec.policy_header_id);
    END LOOP;
    RETURN;
  END;

  -- ���������� id ���������, ����������� � ����������� � ��������� �������
  FUNCTION get_pol_active_id
  (
    dleft  DATE
   ,dright DATE
   ,ag_id  NUMBER
   ,dep_id NUMBER
   ,ch_br  VARCHAR2
   ,pr_br  VARCHAR2
  ) RETURN tbl_id
    PIPELINED IS
  BEGIN
    FOR rec IN (SELECT ph.policy_header_id
                  FROM ins.ven_p_pol_header ph
                  JOIN ins.ven_p_policy pp
                    ON pp.policy_id = ph.policy_id
                  JOIN (SELECT *
                         FROM TABLE(pkg_rep_utils_ins11.get_policy_id(dleft
                                                                     ,dright
                                                                     ,ag_id
                                                                     ,dep_id
                                                                     ,ch_br
                                                                     ,pr_br))) tbl
                    ON ph.policy_header_id = tbl.COLUMN_VALUE
                 WHERE NVL(pp.end_date, dright + 1) > dright
                --or pp.end_date is null;
                )
    LOOP
      PIPE ROW(rec.policy_header_id);
    END LOOP;
    RETURN;
  END;

  -- ���������� id ���������, �����������  � ������������ � ��������� ������
  -- �� ����������� �������������� ��� ��������� ������������
  FUNCTION get_pol_dec_anderr_id
  (
    dleft  DATE
   ,dright DATE
   ,ag_id  NUMBER
   ,dep_id NUMBER
   ,ch_br  VARCHAR2
   ,pr_br  VARCHAR2
  ) RETURN tbl_id
    PIPELINED IS
  BEGIN
    FOR rec IN (SELECT ph.policy_header_id
                  FROM ins.ven_p_pol_header ph
                  JOIN ins.ven_p_policy pp
                    ON pp.policy_id = ph.policy_id
                  JOIN ins.ven_t_decline_reason dr
                    ON dr.t_decline_reason_id = pp.decline_reason_id
                  JOIN (SELECT *
                         FROM TABLE(pkg_rep_utils_ins11.get_policy_id(dleft
                                                                     ,dright
                                                                     ,ag_id
                                                                     ,dep_id
                                                                     ,ch_br
                                                                     ,pr_br))) tbl
                    ON ph.policy_header_id = tbl.COLUMN_VALUE
                 WHERE pp.decline_date BETWEEN dleft AND dright
                   AND dr.brief IN ('����������������', '��������������'))
    LOOP
      PIPE ROW(rec.policy_header_id);
    END LOOP;
    RETURN;
  END;

  -- ���������� id ���������, �����������  � ������������ � ��������� ������
  -- �� ���� ��������
  FUNCTION get_pol_dec_other_id
  (
    dleft  DATE
   ,dright DATE
   ,ag_id  NUMBER
   ,dep_id NUMBER
   ,ch_br  VARCHAR2
   ,pr_br  VARCHAR2
  ) RETURN tbl_id
    PIPELINED IS
  BEGIN
    FOR rec IN (SELECT ph.policy_header_id
                  FROM ins.ven_p_pol_header ph
                  JOIN ins.ven_p_policy pp
                    ON pp.policy_id = ph.policy_id
                  JOIN ins.ven_t_decline_reason dr
                    ON dr.t_decline_reason_id = pp.decline_reason_id
                  JOIN (SELECT *
                         FROM TABLE(pkg_rep_utils_ins11.get_policy_id(dleft
                                                                     ,dright
                                                                     ,ag_id
                                                                     ,dep_id
                                                                     ,ch_br
                                                                     ,pr_br))) tbl
                    ON ph.policy_header_id = tbl.COLUMN_VALUE
                 WHERE pp.decline_date BETWEEN dleft AND dright
                   AND dr.brief NOT IN
                       ('����������������', '��������������'))
    LOOP
      PIPE ROW(rec.policy_header_id);
    END LOOP;
    RETURN;
  END;

  -- ��������� ������ � ������� rep_sr_wo_prog
  PROCEDURE insert_row_to_sr_wo
  (
    fchanal VARCHAR2
   ,fdep    VARCHAR2
   ,fagent  VARCHAR2
   ,fprod   VARCHAR2
   ,fparam  VARCHAR2
   ,fvalue  NUMBER
  ) IS
  BEGIN
    INSERT INTO ins_dwh.rep_sr_wo_prog sr
      (chanal, agency, AGENT, product, param, VALUE)
    VALUES
      (fchanal, fdep, fagent, fprod, fparam, fvalue);
  END;

  -- �������� ������������ ������ Sales Report � ������������ �� ��������
  -- opatsan version
  --����� ������ pkg_rep_utils_ins11.create_period_sr_wo (������������� ����� �.�.) 
  PROCEDURE create_period_sr_wo
  (
    dleft  DATE
   ,dright DATE
  ) IS
    -- ��������������� ����������
    first_day DATE; -- ���� ������ ����
  
    -- �������� �������� � ����������� ������ � ������ ����
    act_ape_ytd        NUMBER; -- ������� ������
    act_pay_amount_ytd NUMBER DEFAULT 0; -- ���������� ������
    act_num_ytd        NUMBER; -- ���������� ���������
  
    v_fund_id      NUMBER;
    v_rate_type_id NUMBER;
  
  BEGIN
  
    -- ��������� ������� ����������� "�������  - �����" 
    fill_tbl_pol_ag(dleft, dright);
  
    -- ��������� ������ ���� ����
    first_day := TRUNC(dleft, 'yyyy');
    DELETE FROM ins_dwh.rep_sr_wo_prog;
  
    SELECT f.fund_id INTO v_fund_id FROM ins.ven_fund f WHERE f.brief = 'RUR';
  
    SELECT t.rate_type_id INTO v_rate_type_id FROM ins.ven_rate_type t WHERE t.brief = '��';
  
    FOR rec IN (SELECT SUM(CASE
                             WHEN ph.start_date BETWEEN dleft AND dright THEN
                              pp.premium * ins.acc_new.Get_Cross_Rate_By_Id(v_rate_type_id
                                                                           ,ph.fund_id
                                                                           ,v_fund_id
                                                                           ,ph.start_date)
                             ELSE
                              0
                           END) pol_ape
                      , --pol_ape
                       SUM(CASE
                             WHEN ph.start_date BETWEEN dleft AND dright THEN
                              ins.pkg_payment.get_pay_pol_header_amount_pfa(dleft
                                                                           ,dright
                                                                           ,ph.policy_header_id) *
                              ins.acc_new.Get_Cross_Rate_By_Id(v_rate_type_id
                                                              ,ph.fund_id
                                                              ,v_fund_id
                                                              ,ph.start_date)
                             ELSE
                              0
                           END) pol_pay_amount
                      , --pol_pay_amount
                       SUM(CASE
                             WHEN ph.start_date BETWEEN dleft AND dright THEN
                              1
                             ELSE
                              0
                           END) pol_num
                      , --pol_num
                       SUM(CASE
                             WHEN (pp.decline_date BETWEEN dleft AND dright)
                                  AND tdr.brief IN
                                  ('����������������', '��������������')
                                  AND (ph.start_date BETWEEN dleft AND dright) THEN
                              pp.premium * ins.acc_new.Get_Cross_Rate_By_Id(v_rate_type_id
                                                                           ,ph.fund_id
                                                                           ,v_fund_id
                                                                           ,ph.start_date)
                             ELSE
                              0
                           END) dec_ape
                      , --dec_ape
                       SUM(CASE
                             WHEN pp.decline_date BETWEEN dleft AND dright
                                  AND tdr.brief IN
                                  ('����������������', '��������������')
                                  AND (ph.start_date BETWEEN dleft AND dright) THEN
                              1
                             ELSE
                              0
                           END) dec_num
                      , --dec_num
                       SUM(CASE
                             WHEN pp.decline_date BETWEEN dleft AND dright
                                  AND tdr.brief IN
                                  ('����������������', '��������������')
                                  AND (ph.start_date BETWEEN dleft AND dright) THEN
                              pp.decline_summ *
                              ins.acc_new.Get_Cross_Rate_By_Id(v_rate_type_id
                                                              ,ph.fund_id
                                                              ,v_fund_id
                                                              ,ph.start_date)
                             ELSE
                              0
                           END) dec_pay_amount
                      , --dec_pay_amount
                       SUM(CASE
                             WHEN (NVL(pp.end_date, dright + 1) > dright)
                                  AND (ph.start_date BETWEEN dleft AND dright) THEN
                              pp.premium * ins.acc_new.Get_Cross_Rate_By_Id(v_rate_type_id
                                                                           ,ph.fund_id
                                                                           ,v_fund_id
                                                                           ,ph.start_date)
                             ELSE
                              0
                           END) act_ape
                      , --act_ape
                       SUM(CASE
                             WHEN (NVL(pp.end_date, dright + 1) > dright)
                                  AND (ph.start_date BETWEEN dleft AND dright) THEN
                              ins.pkg_payment.get_pay_pol_header_amount_pfa(dleft
                                                                           ,dright
                                                                           ,ph.policy_header_id) *
                              ins.acc_new.Get_Cross_Rate_By_Id(v_rate_type_id
                                                              ,ph.fund_id
                                                              ,v_fund_id
                                                              ,ph.start_date)
                             ELSE
                              0
                           END) act_pay_amount
                      , --act_pay_amount
                       SUM(CASE
                             WHEN (NVL(pp.end_date, dright + 1) > dright)
                                  AND (ph.start_date BETWEEN dleft AND dright) THEN
                              1
                             ELSE
                              0
                           END) act_num
                      , --act_num       
                       SUM(CASE
                             WHEN pp.decline_date BETWEEN dleft AND dright
                                  AND tdr.brief NOT IN
                                  ('����������������', '��������������')
                                  AND (ph.start_date BETWEEN dleft AND dright) THEN
                              pp.premium * ins.acc_new.Get_Cross_Rate_By_Id(v_rate_type_id
                                                                           ,ph.fund_id
                                                                           ,v_fund_id
                                                                           ,ph.start_date)
                           
                             ELSE
                              0
                           END) dec_oth_ape
                      , --dec_oth_ape
                       SUM(CASE
                             WHEN pp.decline_date BETWEEN dleft AND dright
                                  AND tdr.brief NOT IN
                                  ('����������������', '��������������')
                                  AND (ph.start_date BETWEEN dleft AND dright) THEN
                              1
                             ELSE
                              0
                           END) dec_oth_num
                      , --dec_oth_num
                       SUM(CASE
                             WHEN pp.decline_date BETWEEN dleft AND dright
                                  AND tdr.brief NOT IN
                                  ('����������������', '��������������')
                                  AND (ph.start_date BETWEEN dleft AND dright) THEN
                              pp.decline_summ *
                              ins.acc_new.Get_Cross_Rate_By_Id(v_rate_type_id
                                                              ,ph.fund_id
                                                              ,v_fund_id
                                                              ,ph.start_date)
                             ELSE
                              0
                           END) dec_oth_pay_amount
                      , --dec_oth_pay_amount    
                       SUM(pp.premium * ins.acc_new.Get_Cross_Rate_By_Id(v_rate_type_id
                                                                        ,ph.fund_id
                                                                        ,v_fund_id
                                                                        ,ph.start_date)) act_ape_ytd
                      ,COUNT(*) act_num_ytd
                      ,
                       /*sum(
                       nvl(td.trans_amount
                           , 0) + 
                       nvl(-tc.trans_amount
                           , 0))*/SUM(ins.pkg_payment.get_pay_pol_header_amount_pfa(first_day
                                                                        ,dright
                                                                        ,ph.policy_header_id) *
                           ins.acc_new.Get_Cross_Rate_By_Id(v_rate_type_id
                                                           ,ph.fund_id
                                                           ,v_fund_id
                                                           ,ph.start_date)) act_pay_amount_ytd
                      ,tt.ag_id agent_id
                      ,c.obj_name_orig ag_fio
                      ,sch.brief ch_br
                      ,ph.sales_channel_id
                      ,sch.description ch_name
                      ,ph.agency_id dep_id
                      ,pkg_rep_utils_ins11.get_pol_agency_name(ph.agency_id) dep_name
                      ,pr.product_id
                      ,pr.brief pr_br
                      ,pr.description pr_name
                  FROM ins.ven_p_pol_header     ph
                      ,ins.ven_p_policy         pp
                      ,ins.ven_t_sales_channel  sch
                      ,ins.ven_t_product        pr
                      ,ins_dwh.rep_sr_ag        tt
                      ,ins.ven_contact          c
                      ,ins.ven_t_decline_reason tdr --,
                --�������� �� ��������� 
                /*ins.ven_trans td,
                ins.ven_trans tc*/
                 WHERE ph.start_date BETWEEN first_day AND dright
                   AND ph.policy_id = pp.policy_id(+)
                   AND sch.ID = ph.sales_channel_id
                   AND pr.product_id = ph.product_id
                   AND tt.pol_id(+) = ph.policy_header_id
                   AND c.contact_id(+) = tt.ag_id
                   AND tdr.t_decline_reason_id(+) = pp.decline_reason_id
                --�������� �� ��������� 
                /*and td.dt_account_id(+) = ins.pkg_payment.v_pay_acc_id
                and td.A2_DT_URO_ID(+) = pp.policy_id
                and td.trans_date(+) between first_day and dright
                and tc.ct_account_id(+) = ins.pkg_payment.v_pay_acc_id
                and tc.A2_CT_URO_ID(+) = pp.policy_id
                and tc.trans_date(+) between first_day and dright*/
                 GROUP BY tt.ag_id
                         ,pr.product_id
                         ,c.obj_name_orig
                         ,ph.sales_channel_id
                         ,sch.brief
                         ,sch.description
                         ,ph.agency_id
                         ,pkg_rep_utils_ins11.get_pol_agency_name(ph.agency_id)
                         ,pr.brief
                         ,pr.description
                HAVING SUM(CASE
                  WHEN ph.start_date BETWEEN dleft AND dright THEN
                   1
                  ELSE
                   0
                END) > 0)
    LOOP
    
      -- ��������� ������ � �������
      -- ////////////////////////////////////////////
    
      insert_row_to_sr_wo(rec.ch_name
                         ,rec.dep_name
                         ,rec.ag_fio
                         ,rec.pr_name
                         ,'������� ������ (gross)'
                         ,rec.pol_ape);
      insert_row_to_sr_wo(rec.ch_name
                         ,rec.dep_name
                         ,rec.ag_fio
                         ,rec.pr_name
                         ,'����� ������ (gross)'
                         ,rec.pol_pay_amount);
      insert_row_to_sr_wo(rec.ch_name
                         ,rec.dep_name
                         ,rec.ag_fio
                         ,rec.pr_name
                         ,'���������� ����������� ���������'
                         ,rec.pol_num);
    
      insert_row_to_sr_wo(rec.ch_name
                         ,rec.dep_name
                         ,rec.ag_fio
                         ,rec.pr_name
                         ,'APE �� ������������ ���������'
                         ,rec.dec_ape);
      insert_row_to_sr_wo(rec.ch_name
                         ,rec.dep_name
                         ,rec.ag_fio
                         ,rec.pr_name
                         ,'����� ������������ ������'
                         ,rec.dec_pay_amount);
      insert_row_to_sr_wo(rec.ch_name
                         ,rec.dep_name
                         ,rec.ag_fio
                         ,rec.pr_name
                         ,'���������� ������������ ���������'
                         ,rec.dec_num);
    
      insert_row_to_sr_wo(rec.ch_name
                         ,rec.dep_name
                         ,rec.ag_fio
                         ,rec.pr_name
                         ,'APE (net)'
                         ,rec.act_ape);
      insert_row_to_sr_wo(rec.ch_name
                         ,rec.dep_name
                         ,rec.ag_fio
                         ,rec.pr_name
                         ,'����� ���������� ������ (net)'
                         ,rec.act_pay_amount);
      insert_row_to_sr_wo(rec.ch_name
                         ,rec.dep_name
                         ,rec.ag_fio
                         ,rec.pr_name
                         ,'���������� ����������� ��������� (net)'
                         ,rec.act_num);
    
      insert_row_to_sr_wo(rec.ch_name
                         ,rec.dep_name
                         ,rec.ag_fio
                         ,rec.pr_name
                         ,'APE YTD (net)'
                         ,rec.act_ape_ytd);
      insert_row_to_sr_wo(rec.ch_name
                         ,rec.dep_name
                         ,rec.ag_fio
                         ,rec.pr_name
                         ,'���������� ������ YTD (net)'
                         ,rec.act_pay_amount_ytd);
      insert_row_to_sr_wo(rec.ch_name
                         ,rec.dep_name
                         ,rec.ag_fio
                         ,rec.pr_name
                         ,'���������� ��������� YTD (net)'
                         ,rec.act_num_ytd);
    
      insert_row_to_sr_wo(rec.ch_name
                         ,rec.dep_name
                         ,rec.ag_fio
                         ,rec.pr_name
                         ,'APE �� ���� ������� �����������'
                         ,rec.dec_oth_ape);
      insert_row_to_sr_wo(rec.ch_name
                         ,rec.dep_name
                         ,rec.ag_fio
                         ,rec.pr_name
                         ,'����� ������������ ������ �� ���� ������� �����������'
                         ,rec.dec_oth_pay_amount);
      insert_row_to_sr_wo(rec.ch_name
                         ,rec.dep_name
                         ,rec.ag_fio
                         ,rec.pr_name
                         ,'���������� ��������� �� ���� ������� �����������'
                         ,rec.dec_oth_num);
    
    END LOOP;
    COMMIT;
  END;

  -- �������� ������������ ������ Sales Report � ������������ �� ��������
  PROCEDURE create_period_sr_wo2
  (
    dleft  DATE
   ,dright DATE
  ) IS
    -- ����������� ��������
    pol_ape        NUMBER; -- ������� ������
    pol_pay_amount NUMBER; -- ���������� ������
    pol_num        NUMBER; -- ���������� ����������� ���������
    -- �������� ����������� � ������������ (��������� ������������, ����� �������������)
    dec_ape        NUMBER; -- ������� ������ 
    dec_pay_amount NUMBER; -- ����� ��������
    dec_num        NUMBER; -- ���������� ���������
    --�������� ��������
    act_ape        NUMBER; -- ������� ������
    act_pay_amount NUMBER; -- ���������� ������
    act_num        NUMBER; -- ���������� ���������
    -- �������� �������� � ����������� ������ � ������ ����
    act_ape_ytd        NUMBER; -- ������� ������
    act_pay_amount_ytd NUMBER; -- ���������� ������
    act_num_ytd        NUMBER; -- ���������� ���������
    -- �������� ����������� � ������������ (�� ���� ��������)
    dec_oth_ape        NUMBER; -- ������� ������ 
    dec_oth_pay_amount NUMBER; -- ����� ��������
    dec_oth_num        NUMBER; -- ���������� ���������
  
    -- ��������������� ����������
    first_day DATE; -- ���� ������ ����
  
  BEGIN
    -- ��������� ������� ����������� "�������  - �����" 
    fill_tbl_pol_ag(dleft, dright);
  
    -- ��������� ������ ���� ����
    first_day := TRUNC(dleft, 'yyyy');
    --first_day:= to_date ('01.01.' || to_char(dleft,'yyyy'),'dd.mm.yyyy');
    -- ������� ��� ������ � �������
    DELETE FROM ins_dwh.rep_sr_wo_prog;
    -- ��������� ������� �� ����������� ���������
    --/*
    FOR rec IN (SELECT ag_id
                      ,ag_fio
                      ,dep_id
                      ,dep_name
                      ,ch_br
                      ,ch_name
                      ,pr_br
                      ,pr_name
                  FROM TABLE(pkg_rep_utils_ins11.get_tbl_ag_ch_pr(dleft, dright)))
    
    LOOP
      -- ������� ����������
      -- ////////////////////////////////////////////
    
      -- ����������� ��������
      pol_ape        := TO_NUMBER(get_ape_policy(dleft
                                                ,dright
                                                ,rec.ag_id
                                                ,rec.dep_id
                                                ,rec.ch_br
                                                ,rec.pr_br)); -- ������� ������
      pol_pay_amount := get_pol_pay_amount(dleft, dright, rec.ag_id, rec.dep_id, rec.ch_br, rec.pr_br); -- ���������� ������
      SELECT COUNT(*)
        INTO pol_num
        FROM TABLE(pkg_rep_utils_ins11.get_policy_id(dleft
                                                    ,dright
                                                    ,rec.ag_id
                                                    ,rec.dep_id
                                                    ,rec.ch_br
                                                    ,rec.pr_br)); -- ���������� ����������� ���������
    
      -- �������� ����������� � ������������ (��������� ������������, ����� �������������)
      dec_ape        := TO_NUMBER(get_ape_pol_dec(dleft
                                                 ,dright
                                                 ,rec.ag_id
                                                 ,rec.dep_id
                                                 ,rec.ch_br
                                                 ,rec.pr_br)); -- ������� ������
      dec_pay_amount := get_pol_dec_amount(dleft, dright, rec.ag_id, rec.dep_id, rec.ch_br, rec.pr_br); -- ����� ��������
      SELECT COUNT(*)
        INTO dec_num
        FROM TABLE(pkg_rep_utils_ins11.get_pol_dec_anderr_id(dleft
                                                            ,dright
                                                            ,rec.ag_id
                                                            ,rec.dep_id
                                                            ,rec.ch_br
                                                            ,rec.pr_br)); -- ���������� ���������
    
      --�������� ��������
      act_ape        := TO_NUMBER(get_ape_pol_act(dleft
                                                 ,dright
                                                 ,rec.ag_id
                                                 ,rec.dep_id
                                                 ,rec.ch_br
                                                 ,rec.pr_br)); -- ������� ������
      act_pay_amount := get_pol_pay_amount_act(dleft
                                              ,dright
                                              ,rec.ag_id
                                              ,rec.dep_id
                                              ,rec.ch_br
                                              ,rec.pr_br); -- ���������� ������
      SELECT COUNT(*)
        INTO act_num
        FROM TABLE(pkg_rep_utils_ins11.get_pol_active_id(dleft
                                                        ,dright
                                                        ,rec.ag_id
                                                        ,rec.dep_id
                                                        ,rec.ch_br
                                                        ,rec.pr_br)); -- ���������� ���������
    
      -- �������� �������� � ����������� ������ � ������ ����
      act_ape_ytd        := TO_NUMBER(get_ape_pol_act(first_day
                                                     ,dright
                                                     ,rec.ag_id
                                                     ,rec.dep_id
                                                     ,rec.ch_br
                                                     ,rec.pr_br)); -- ������� ������
      act_pay_amount_ytd := get_pol_pay_amount_act(first_day
                                                  ,dright
                                                  ,rec.ag_id
                                                  ,rec.dep_id
                                                  ,rec.ch_br
                                                  ,rec.pr_br); -- ���������� ������
      SELECT COUNT(*)
        INTO act_num_ytd
        FROM TABLE(pkg_rep_utils_ins11.get_pol_active_id(first_day
                                                        ,dright
                                                        ,rec.ag_id
                                                        ,rec.dep_id
                                                        ,rec.ch_br
                                                        ,rec.pr_br)); -- ���������� ���������
    
      -- �������� ����������� � ������������ (�� ���� ��������)
      dec_oth_ape        := TO_NUMBER(get_ape_pol_dec_oth(dleft
                                                         ,dright
                                                         ,rec.ag_id
                                                         ,rec.dep_id
                                                         ,rec.ch_br
                                                         ,rec.pr_br)); -- ������� ������
      dec_oth_pay_amount := get_pol_dec_amount_oth(dleft
                                                  ,dright
                                                  ,rec.ag_id
                                                  ,rec.dep_id
                                                  ,rec.ch_br
                                                  ,rec.pr_br); -- ����� ��������
      SELECT COUNT(*)
        INTO dec_oth_num
        FROM TABLE(pkg_rep_utils_ins11.get_pol_dec_other_id(dleft
                                                           ,dright
                                                           ,rec.ag_id
                                                           ,rec.dep_id
                                                           ,rec.ch_br
                                                           ,rec.pr_br)); -- ���������� ���������
    
      -- ��������� ������ � �������
      -- ////////////////////////////////////////////
      insert_row_to_sr_wo(rec.ch_name
                         ,rec.dep_name
                         ,rec.ag_fio
                         ,rec.pr_name
                         ,'������� ������ (gross)'
                         ,pol_ape);
      insert_row_to_sr_wo(rec.ch_name
                         ,rec.dep_name
                         ,rec.ag_fio
                         ,rec.pr_name
                         ,'����� ������ (gross)'
                         ,pol_pay_amount);
      insert_row_to_sr_wo(rec.ch_name
                         ,rec.dep_name
                         ,rec.ag_fio
                         ,rec.pr_name
                         ,'���������� ����������� ���������'
                         ,pol_num);
    
      insert_row_to_sr_wo(rec.ch_name
                         ,rec.dep_name
                         ,rec.ag_fio
                         ,rec.pr_name
                         ,'APE �� ������������ ���������'
                         ,dec_ape);
      insert_row_to_sr_wo(rec.ch_name
                         ,rec.dep_name
                         ,rec.ag_fio
                         ,rec.pr_name
                         ,'����� ������������ ������'
                         ,dec_pay_amount);
      insert_row_to_sr_wo(rec.ch_name
                         ,rec.dep_name
                         ,rec.ag_fio
                         ,rec.pr_name
                         ,'���������� ������������ ���������'
                         ,dec_num);
    
      insert_row_to_sr_wo(rec.ch_name, rec.dep_name, rec.ag_fio, rec.pr_name, 'APE (net)', act_ape);
      insert_row_to_sr_wo(rec.ch_name
                         ,rec.dep_name
                         ,rec.ag_fio
                         ,rec.pr_name
                         ,'����� ���������� ������ (net)'
                         ,act_pay_amount);
      insert_row_to_sr_wo(rec.ch_name
                         ,rec.dep_name
                         ,rec.ag_fio
                         ,rec.pr_name
                         ,'���������� ����������� ��������� (net)'
                         ,act_num);
    
      insert_row_to_sr_wo(rec.ch_name
                         ,rec.dep_name
                         ,rec.ag_fio
                         ,rec.pr_name
                         ,'APE YTD (net)'
                         ,act_ape_ytd);
      insert_row_to_sr_wo(rec.ch_name
                         ,rec.dep_name
                         ,rec.ag_fio
                         ,rec.pr_name
                         ,'���������� ������ YTD (net)'
                         ,act_pay_amount_ytd);
      insert_row_to_sr_wo(rec.ch_name
                         ,rec.dep_name
                         ,rec.ag_fio
                         ,rec.pr_name
                         ,'���������� ��������� YTD (net)'
                         ,act_num_ytd);
    
      insert_row_to_sr_wo(rec.ch_name
                         ,rec.dep_name
                         ,rec.ag_fio
                         ,rec.pr_name
                         ,'APE �� ���� ������� �����������'
                         ,dec_oth_ape);
      insert_row_to_sr_wo(rec.ch_name
                         ,rec.dep_name
                         ,rec.ag_fio
                         ,rec.pr_name
                         ,'����� ������������ ������ �� ���� ������� �����������'
                         ,dec_oth_pay_amount);
      insert_row_to_sr_wo(rec.ch_name
                         ,rec.dep_name
                         ,rec.ag_fio
                         ,rec.pr_name
                         ,'���������� ��������� �� ���� ������� �����������'
                         ,dec_oth_num);
    
    END LOOP;
    -- ��������� ������
    UPDATE rep_sr_wo_prog t SET t.period_name = dleft || ' - ' || dright;
    COMMIT;
  END;

  -- ************************************************************************
  --/////////////////////////END SALES REPORT WITHOUT PROGRAMM///////////////
  -- ************************************************************************

  -- ************************************************************************
  --/////////////////////////SALES REPORT WITH PROGRAMM///////////////
  -- ************************************************************************

  -- ���������� ������� ���������, ����������� � ��������� ������
  -- � ��������� ������, ���������, ������ ������ � ���������
  FUNCTION get_tbl_ag_ch_progr
  (
    dleft  DATE
   ,dright DATE
  ) RETURN tbl_ag_ch_pr
    PIPELINED IS
  BEGIN
    -- ������� �������, ����������� � ������
    FOR t_rec IN (SELECT DISTINCT tbl.agent_id
                                 ,ins.ent.obj_name('CONTACT', tbl.agent_id) AS agent_fio
                                 ,tbl.dep_id
                                 ,tbl.dep_name
                                 ,tbl.ch_br
                                 ,tbl.ch_name
                                 ,tbl.pr_br
                                 ,tbl.pr_name
                    FROM (SELECT DISTINCT (SELECT tt.ag_id
                                             FROM ins_dwh.rep_sr_ag tt
                                            WHERE tt.pol_id = ph.policy_header_id) AS agent_id
                                         ,ph.agency_id AS dep_id
                                         ,pkg_rep_utils_ins11.get_pol_agency_name(ph.agency_id) AS dep_name
                                         ,sch.brief AS ch_br
                                         ,sch.description AS ch_name
                                         ,tPrLn.brief AS pr_br
                                         ,tPrLn.description AS pr_name
                            FROM ins.ven_p_pol_header ph
                            JOIN ins.ven_t_sales_channel sch
                              ON sch.ID = ph.sales_channel_id
                            JOIN ins.ven_p_policy pp
                              ON pp.policy_id = ph.policy_id
                            JOIN ins.ven_as_asset ass
                              ON ass.p_policy_id = pp.policy_id
                            JOIN ins.ven_p_cover pCov
                              ON pCov.as_asset_id = ass.as_asset_id
                            JOIN ins.ven_t_prod_line_option tPrLnOp
                              ON tPrLnOp.ID = pCov.t_prod_line_option_id
                            JOIN ins.ven_t_product_line tPrLn
                              ON tPrLn.ID = tPrLnOp.product_line_id
                           WHERE ph.start_date BETWEEN dleft AND dright) tbl)
    LOOP
      PIPE ROW(t_rec);
    END LOOP;
    RETURN;
  END;

  -- ���������� ����� APE �� ����������� ���������
  FUNCTION get_ape_policy_pr
  (
    dleft  DATE
   ,dright DATE
   ,ag_id  NUMBER
   ,dep_id NUMBER
   ,ch_br  VARCHAR2
   ,pr_br  VARCHAR2
  ) RETURN NUMBER IS
    summ NUMBER(11, 2);
  BEGIN
    SELECT SUM(pCov.premium)
      INTO summ
      FROM ins.ven_p_pol_header ph
      JOIN ins.ven_p_policy pp
        ON pp.policy_id = ph.policy_id
      JOIN ins.ven_as_asset ass
        ON ass.p_policy_id = pp.policy_id
      JOIN ins.ven_p_cover pCov
        ON pCov.as_asset_id = ass.as_asset_id
      JOIN (SELECT *
              FROM TABLE(pkg_rep_utils_ins11.get_policy_id_pr(dleft
                                                             ,dright
                                                             ,ag_id
                                                             ,dep_id
                                                             ,ch_br
                                                             ,pr_br))) f
        ON ph.policy_header_id = f.COLUMN_VALUE;
    RETURN(TO_CHAR(summ, '000000000D00'));
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  -- ���������� ����� APE �� ������������ ���������
  FUNCTION get_ape_pol_dec_pr
  (
    dleft  DATE
   ,dright DATE
   ,ag_id  NUMBER
   ,dep_id NUMBER
   ,ch_br  VARCHAR2
   ,pr_br  VARCHAR2
  ) RETURN NUMBER IS
    summ NUMBER(11, 2);
  BEGIN
    SELECT SUM(pCov.premium)
      INTO summ
      FROM ins.ven_p_pol_header ph
      JOIN ins.ven_p_policy pp
        ON pp.policy_id = ph.policy_id
      JOIN ins.ven_as_asset ass
        ON ass.p_policy_id = pp.policy_id
      JOIN ins.ven_p_cover pCov
        ON pCov.as_asset_id = ass.as_asset_id
      JOIN (SELECT *
              FROM TABLE(pkg_rep_utils_ins11.get_pol_dec_anderr_id_pr(dleft
                                                                     ,dright
                                                                     ,ag_id
                                                                     ,dep_id
                                                                     ,ch_br
                                                                     ,pr_br))) f
        ON ph.policy_header_id = f.COLUMN_VALUE;
    RETURN(TO_CHAR(summ, '000000000D00'));
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  -- ���������� ����� APE �� ������������ ��������� �� ���� ��������
  FUNCTION get_ape_pol_dec_oth_pr
  (
    dleft  DATE
   ,dright DATE
   ,ag_id  NUMBER
   ,dep_id NUMBER
   ,ch_br  VARCHAR2
   ,pr_br  VARCHAR2
  ) RETURN NUMBER IS
    summ NUMBER(11, 2);
  BEGIN
    SELECT SUM(pCov.premium)
      INTO summ
      FROM ins.ven_p_pol_header ph
      JOIN ins.ven_p_policy pp
        ON pp.policy_id = ph.policy_id
      JOIN ins.ven_as_asset ass
        ON ass.p_policy_id = pp.policy_id
      JOIN ins.ven_p_cover pCov
        ON pCov.as_asset_id = ass.as_asset_id
      JOIN (SELECT *
              FROM TABLE(pkg_rep_utils_ins11.get_pol_dec_other_id_pr(dleft
                                                                    ,dright
                                                                    ,ag_id
                                                                    ,dep_id
                                                                    ,ch_br
                                                                    ,pr_br))) f
        ON ph.policy_header_id = f.COLUMN_VALUE;
    RETURN(TO_CHAR(summ, '000000000D00'));
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  -- ���������� ����� APE �� �������� ���������
  FUNCTION get_ape_pol_act_pr
  (
    dleft  DATE
   ,dright DATE
   ,ag_id  NUMBER
   ,dep_id NUMBER
   ,ch_br  VARCHAR2
   ,pr_br  VARCHAR2
  ) RETURN NUMBER IS
    summ NUMBER(11, 2);
  BEGIN
    SELECT SUM(pCov.premium)
      INTO summ
      FROM ins.ven_p_pol_header ph
      JOIN ins.ven_p_policy pp
        ON pp.policy_id = ph.policy_id
      JOIN ins.ven_as_asset ass
        ON ass.p_policy_id = pp.policy_id
      JOIN ins.ven_p_cover pCov
        ON pCov.as_asset_id = ass.as_asset_id
      JOIN (SELECT *
              FROM TABLE(pkg_rep_utils_ins11.get_pol_active_id_pr(dleft
                                                                 ,dright
                                                                 ,ag_id
                                                                 ,dep_id
                                                                 ,ch_br
                                                                 ,pr_br))) f
        ON ph.policy_header_id = f.COLUMN_VALUE;
    RETURN(TO_CHAR(summ, '000000000D00'));
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  -- ���������� ����� ���������� ������ �� ����������� ���������
  FUNCTION get_pol_pay_amount_pr
  (
    dleft  DATE
   ,dright DATE
   ,ag_id  NUMBER
   ,dep_id NUMBER
   ,ch_br  VARCHAR2
   ,pr_br  VARCHAR2
  ) RETURN NUMBER IS
    summ NUMBER(11, 2);
  BEGIN
    SELECT SUM(ins.pkg_payment.get_pay_cover_amount_pfa(dleft, dright, pCov.p_cover_id))
      INTO summ
      FROM ins.ven_p_pol_header ph
      JOIN ins.ven_p_policy pp
        ON pp.policy_id = ph.policy_id
      JOIN ins.ven_as_asset ass
        ON ass.p_policy_id = pp.policy_id
      JOIN ins.ven_p_cover pCov
        ON pCov.as_asset_id = ass.as_asset_id
      JOIN (SELECT *
              FROM TABLE(pkg_rep_utils_ins11.get_policy_id_pr(dleft
                                                             ,dright
                                                             ,ag_id
                                                             ,dep_id
                                                             ,ch_br
                                                             ,pr_br))) f
        ON ph.policy_header_id = f.COLUMN_VALUE;
    RETURN(TO_CHAR(summ, '000000000D00'));
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  -- ���������� ����� ���������� ������ �� �������� ���������
  FUNCTION get_pol_pay_amount_act_pr
  (
    dleft  DATE
   ,dright DATE
   ,ag_id  NUMBER
   ,dep_id NUMBER
   ,ch_br  VARCHAR2
   ,pr_br  VARCHAR2
  ) RETURN NUMBER IS
    summ NUMBER(11, 2);
  BEGIN
    SELECT SUM(ins.pkg_payment.get_pay_cover_amount_pfa(dleft, dright, pCov.p_cover_id))
      INTO summ
      FROM ins.ven_p_pol_header ph
      JOIN ins.ven_p_policy pp
        ON pp.policy_id = ph.policy_id
      JOIN ins.ven_as_asset ass
        ON ass.p_policy_id = pp.policy_id
      JOIN ins.ven_p_cover pCov
        ON pCov.as_asset_id = ass.as_asset_id
      JOIN (SELECT *
              FROM TABLE(pkg_rep_utils_ins11.get_pol_active_id_pr(dleft
                                                                 ,dright
                                                                 ,ag_id
                                                                 ,dep_id
                                                                 ,ch_br
                                                                 ,pr_br))) f
        ON ph.policy_header_id = f.COLUMN_VALUE;
    RETURN(TO_CHAR(summ, '000000000D00'));
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  -- ���������� ����� �������� �� ������������ ���������
  FUNCTION get_pol_dec_amount_pr
  (
    dleft  DATE
   ,dright DATE
   ,ag_id  NUMBER
   ,dep_id NUMBER
   ,ch_br  VARCHAR2
   ,pr_br  VARCHAR2
  ) RETURN NUMBER IS
    summ NUMBER(11, 2);
  BEGIN
    SELECT SUM(pCov.decline_summ)
      INTO summ
      FROM ins.ven_p_pol_header ph
      JOIN ins.ven_p_policy pp
        ON pp.policy_id = ph.policy_id
      JOIN ins.ven_as_asset ass
        ON ass.p_policy_id = pp.policy_id
      JOIN ins.ven_p_cover pCov
        ON pCov.as_asset_id = ass.as_asset_id
      JOIN (SELECT *
              FROM TABLE(pkg_rep_utils_ins11.get_pol_dec_anderr_id_pr(dleft
                                                                     ,dright
                                                                     ,ag_id
                                                                     ,dep_id
                                                                     ,ch_br
                                                                     ,pr_br))) f
        ON ph.policy_header_id = f.COLUMN_VALUE;
    RETURN(TO_CHAR(summ, '000000000D00'));
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  -- ���������� ����� �������� �� ������������ ��������� �� ���� ��������
  FUNCTION get_pol_dec_amount_oth_pr
  (
    dleft  DATE
   ,dright DATE
   ,ag_id  NUMBER
   ,dep_id NUMBER
   ,ch_br  VARCHAR2
   ,pr_br  VARCHAR2
  ) RETURN NUMBER IS
    summ NUMBER(11, 2);
  BEGIN
    SELECT SUM(pCov.decline_summ)
      INTO summ
      FROM ins.ven_p_pol_header ph
      JOIN ins.ven_p_policy pp
        ON pp.policy_id = ph.policy_id
      JOIN ins.ven_as_asset ass
        ON ass.p_policy_id = pp.policy_id
      JOIN ins.ven_p_cover pCov
        ON pCov.as_asset_id = ass.as_asset_id
      JOIN (SELECT *
              FROM TABLE(pkg_rep_utils_ins11.get_pol_dec_other_id_pr(dleft
                                                                    ,dright
                                                                    ,ag_id
                                                                    ,dep_id
                                                                    ,ch_br
                                                                    ,pr_br))) f
        ON ph.policy_header_id = f.COLUMN_VALUE;
    RETURN(TO_CHAR(summ, '000000000D00'));
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  -- ���������� id ���������, ����������� � ������
  FUNCTION get_policy_id_pr
  (
    dleft  DATE
   ,dright DATE
   ,ag_id  NUMBER
   ,dep_id NUMBER
   ,ch_br  VARCHAR2
   ,pr_br  VARCHAR2
  ) RETURN tbl_id
    PIPELINED IS
    -- ��������� ����������
    t_ag_id  VARCHAR2(10); -- id ������
    t_dep_id VARCHAR2(10); -- id ���������
    t_ch_br  VARCHAR2(30); -- c���������� ������ ������
    t_pr_br  VARCHAR2(30); -- ���������� ��������
  BEGIN
    -- ������������� ����������
    IF ag_id IS NULL
    THEN
      t_ag_id := '%';
    ELSE
      t_ag_id := ag_id;
    END IF;
  
    IF dep_id IS NULL
    THEN
      t_dep_id := '%';
    ELSE
      t_dep_id := dep_id;
    END IF;
  
    IF ch_br IS NULL
    THEN
      t_ch_br := '%';
    ELSE
      t_ch_br := ch_br;
    END IF;
  
    IF pr_br IS NULL
    THEN
      t_pr_br := '%';
    ELSE
      t_pr_br := pr_br;
    END IF;
    -- ��������� �������
    FOR rec IN (SELECT tbl.policy_header_id
                  FROM (SELECT ph.policy_header_id
                              ,(SELECT tt.ag_id
                                  FROM ins_dwh.rep_sr_ag tt
                                 WHERE tt.pol_id = ph.policy_header_id) AS ag_id
                          FROM ins.ven_p_pol_header ph
                          JOIN ins.ven_t_sales_channel sch
                            ON sch.ID = ph.sales_channel_id
                          JOIN ins.ven_p_policy pp
                            ON pp.policy_id = ph.policy_id
                          JOIN ins.ven_as_asset ass
                            ON ass.p_policy_id = pp.policy_id
                          JOIN ins.ven_p_cover pCov
                            ON pCov.as_asset_id = ass.as_asset_id
                          JOIN ins.ven_t_prod_line_option tPrLnOp
                            ON tPrLnOp.ID = pCov.t_prod_line_option_id
                          JOIN ins.ven_t_product_line tPrLn
                            ON tPrLn.ID = tPrLnOp.product_line_id
                         WHERE ph.start_date BETWEEN dleft AND dright
                           AND NVL(TO_CHAR(ph.agency_id), t_dep_id) LIKE t_dep_id
                           AND NVL(sch.brief, t_ch_br) LIKE t_ch_br
                           AND NVL(tPrLn.brief, t_pr_br) LIKE t_pr_br) tbl
                 WHERE NVL(TO_CHAR(tbl.ag_id), t_ag_id) LIKE t_ag_id)
    LOOP
      PIPE ROW(rec.policy_header_id);
    END LOOP;
    RETURN;
  END;

  -- ���������� id ��������, ����������� � ����������� � ��������� �������
  FUNCTION get_pol_active_id_pr
  (
    dleft  DATE
   ,dright DATE
   ,ag_id  NUMBER
   ,dep_id NUMBER
   ,ch_br  VARCHAR2
   ,pr_br  VARCHAR2
  ) RETURN tbl_id
    PIPELINED IS
  BEGIN
    FOR rec IN (SELECT ph.policy_header_id
                  FROM ins.ven_p_pol_header ph
                  JOIN ins.ven_p_policy pp
                    ON pp.policy_id = ph.policy_id
                  JOIN (SELECT *
                         FROM TABLE(pkg_rep_utils_ins11.get_policy_id_pr(dleft
                                                                        ,dright
                                                                        ,ag_id
                                                                        ,dep_id
                                                                        ,ch_br
                                                                        ,pr_br))) tbl
                    ON ph.policy_header_id = tbl.COLUMN_VALUE
                 WHERE NVL(pp.end_date, dright + 1) > dright
                --or pp.end_date is null
                )
    LOOP
      PIPE ROW(rec.policy_header_id);
    END LOOP;
    RETURN;
  END;

  -- ���������� id ���������, �����������  � ������������ � ��������� ������
  -- �� ����������� �������������� ��� ��������� ������������
  FUNCTION get_pol_dec_anderr_id_pr
  (
    dleft  DATE
   ,dright DATE
   ,ag_id  NUMBER
   ,dep_id NUMBER
   ,ch_br  VARCHAR2
   ,pr_br  VARCHAR2
  ) RETURN tbl_id
    PIPELINED IS
  BEGIN
    FOR rec IN (SELECT ph.policy_header_id
                  FROM ins.ven_p_pol_header ph
                  JOIN ins.ven_p_policy pp
                    ON pp.policy_id = ph.policy_id
                  JOIN ins.ven_t_decline_reason dr
                    ON dr.t_decline_reason_id = pp.decline_reason_id
                  JOIN (SELECT *
                         FROM TABLE(pkg_rep_utils_ins11.get_policy_id_pr(dleft
                                                                        ,dright
                                                                        ,ag_id
                                                                        ,dep_id
                                                                        ,ch_br
                                                                        ,pr_br))) tbl
                    ON ph.policy_header_id = tbl.COLUMN_VALUE
                 WHERE pp.decline_date BETWEEN dleft AND dright
                   AND dr.brief IN ('����������������', '��������������'))
    LOOP
      PIPE ROW(rec.policy_header_id);
    END LOOP;
    RETURN;
  END;

  -- ���������� id ���������, �����������  � ������������ � ��������� ������
  -- �� ���� ��������
  FUNCTION get_pol_dec_other_id_pr
  (
    dleft  DATE
   ,dright DATE
   ,ag_id  NUMBER
   ,dep_id NUMBER
   ,ch_br  VARCHAR2
   ,pr_br  VARCHAR2
  ) RETURN tbl_id
    PIPELINED IS
  BEGIN
    FOR rec IN (SELECT ph.policy_header_id
                  FROM ins.ven_p_pol_header ph
                  JOIN ins.ven_p_policy pp
                    ON pp.policy_id = ph.policy_id
                  JOIN ins.ven_t_decline_reason dr
                    ON dr.t_decline_reason_id = pp.decline_reason_id
                  JOIN (SELECT *
                         FROM TABLE(pkg_rep_utils_ins11.get_policy_id_pr(dleft
                                                                        ,dright
                                                                        ,ag_id
                                                                        ,dep_id
                                                                        ,ch_br
                                                                        ,pr_br))) tbl
                    ON ph.policy_header_id = tbl.COLUMN_VALUE
                 WHERE pp.decline_date BETWEEN dleft AND dright
                   AND dr.brief NOT IN
                       ('����������������', '��������������'))
    LOOP
      PIPE ROW(rec.policy_header_id);
    END LOOP;
    RETURN;
  END;

  -- ��������� ������ � ������� rep_sr_prog
  PROCEDURE insert_row_to_sr_prog
  (
    fchanal VARCHAR2
   ,fdep    VARCHAR2
   ,fagent  VARCHAR2
   ,fprog   VARCHAR2
   ,fparam  VARCHAR2
   ,fvalue  NUMBER
  ) IS
  BEGIN
    INSERT INTO ins_dwh.rep_sr_prog sr
      (chanal, agency, AGENT, programm, param, VALUE)
    VALUES
      (fchanal, fdep, fagent, fprog, fparam, fvalue);
  END;

  -- �������� ������������ ����� Sales Report � ������������ �� ��������� 
  --������ ������ ������ 
  PROCEDURE create_period_sr_prog
  (
    dleft  DATE
   ,dright DATE
  ) IS
    -- ��������������� ����������
    first_day DATE; -- ���� ������ ���� 
  
    v_fund_id      NUMBER;
    v_rate_type_id NUMBER;
  
  BEGIN
  
    -- ��������� ������� ����������� "�������  - �����" 
    fill_tbl_pol_ag(dleft, dright);
  
    -- ��������� ������ ���� ����
    first_day := TRUNC(dleft, 'yyyy');
  
    SELECT f.fund_id INTO v_fund_id FROM ins.ven_fund f WHERE f.brief = 'RUR';
  
    SELECT t.rate_type_id INTO v_rate_type_id FROM ins.ven_rate_type t WHERE t.brief = '��';
  
    DELETE FROM ins_dwh.rep_sr_prog;
  
    FOR rec IN (SELECT SUM(CASE
                             WHEN ph.start_date BETWEEN dleft AND dright THEN
                              pCov.premium * ins.acc_new.Get_Cross_Rate_By_Id(v_rate_type_id
                                                                             ,ph.fund_id
                                                                             ,v_fund_id
                                                                             ,ph.start_date)
                             ELSE
                              0
                           END) pol_ape
                      ,SUM(CASE
                             WHEN ph.start_date BETWEEN dleft AND dright THEN
                              ins.pkg_payment.get_pay_cover_amount_pfa(dleft, dright, pCov.p_cover_id)
                             ELSE
                              0
                           END) pol_pay_amount
                      ,SUM(CASE
                             WHEN ph.start_date BETWEEN dleft AND dright THEN
                              1
                             ELSE
                              0
                           END) pol_num
                      ,SUM(CASE
                             WHEN ph.start_date BETWEEN dleft AND dright
                                  AND tdr.brief IN
                                  ('����������������', '��������������')
                                  AND pp.decline_date BETWEEN dleft AND dright THEN
                              pCov.premium * ins.acc_new.Get_Cross_Rate_By_Id(v_rate_type_id
                                                                             ,ph.fund_id
                                                                             ,v_fund_id
                                                                             ,ph.start_date)
                             ELSE
                              0
                           END) dec_ape
                      ,SUM(CASE
                             WHEN ph.start_date BETWEEN dleft AND dright
                                  AND tdr.brief IN
                                  ('����������������', '��������������')
                                  AND pp.decline_date BETWEEN dleft AND dright THEN
                              pCov.decline_summ *
                              ins.acc_new.Get_Cross_Rate_By_Id(v_rate_type_id
                                                              ,ph.fund_id
                                                              ,v_fund_id
                                                              ,ph.start_date)
                             ELSE
                              0
                           END) dec_pay_amount
                      ,SUM(CASE
                             WHEN ph.start_date BETWEEN dleft AND dright
                                  AND tdr.brief IN
                                  ('����������������', '��������������')
                                  AND pp.decline_date BETWEEN dleft AND dright THEN
                              1
                             ELSE
                              0
                           END) dec_num
                      ,SUM(CASE
                             WHEN ph.start_date BETWEEN dleft AND dright
                                  AND NVL(pp.end_date, dright + 1) > dright THEN
                              pCov.premium * ins.acc_new.Get_Cross_Rate_By_Id(v_rate_type_id
                                                                             ,ph.fund_id
                                                                             ,v_fund_id
                                                                             ,ph.start_date)
                             ELSE
                              0
                           END) act_ape
                      ,SUM(CASE
                             WHEN ph.start_date BETWEEN dleft AND dright
                                  AND NVL(pp.end_date, dright + 1) > dright THEN
                              ins.pkg_payment.get_pay_cover_amount_pfa(dleft, dright, pCov.p_cover_id)
                             ELSE
                              0
                           END) act_pay_amount
                      ,SUM(CASE
                             WHEN ph.start_date BETWEEN dleft AND dright
                                  AND NVL(pp.end_date, dright + 1) > dright THEN
                              1
                             ELSE
                              0
                           END) act_num
                      ,SUM(CASE
                             WHEN NVL(pp.end_date, dright + 1) > dright THEN
                              pCov.premium * ins.acc_new.Get_Cross_Rate_By_Id(v_rate_type_id
                                                                             ,ph.fund_id
                                                                             ,v_fund_id
                                                                             ,ph.start_date)
                             ELSE
                              0
                           END) act_ape_ytd
                      ,SUM(CASE
                             WHEN NVL(pp.end_date, dright + 1) > dright THEN
                              ins.pkg_payment.get_pay_cover_amount_pfa(first_day, dright, pCov.p_cover_id)
                             ELSE
                              0
                           END) act_pay_amount_ytd
                      ,SUM(CASE
                             WHEN NVL(pp.end_date, dright + 1) > dright THEN
                              1
                             ELSE
                              0
                           END) act_num_ytd
                      ,SUM(CASE
                             WHEN ph.start_date BETWEEN dleft AND dright
                                  AND tdr.brief NOT IN
                                  ('����������������', '��������������')
                                  AND pp.decline_date BETWEEN dleft AND dright THEN
                              pCov.premium * ins.acc_new.Get_Cross_Rate_By_Id(v_rate_type_id
                                                                             ,ph.fund_id
                                                                             ,v_fund_id
                                                                             ,ph.start_date)
                             ELSE
                              0
                           END) dec_oth_ape
                      ,SUM(CASE
                             WHEN ph.start_date BETWEEN dleft AND dright
                                  AND tdr.brief NOT IN
                                  ('����������������', '��������������')
                                  AND pp.decline_date BETWEEN dleft AND dright THEN
                              pCov.decline_summ *
                              ins.acc_new.Get_Cross_Rate_By_Id(v_rate_type_id
                                                              ,ph.fund_id
                                                              ,v_fund_id
                                                              ,ph.start_date)
                             ELSE
                              0
                           END) dec_oth_pay_amount
                      ,SUM(CASE
                             WHEN ph.start_date BETWEEN dleft AND dright
                                  AND tdr.brief NOT IN
                                  ('����������������', '��������������')
                                  AND pp.decline_date BETWEEN dleft AND dright THEN
                              1
                             ELSE
                              0
                           END) dec_oth_num
                      ,tt.ag_id agent_id
                      ,c.obj_name_orig ag_fio
                      ,sch.brief ch_br
                      ,ph.sales_channel_id
                      ,sch.description ch_name
                      ,ph.agency_id dep_id
                      ,pkg_rep_utils_ins11.get_pol_agency_name(ph.agency_id) dep_name
                      ,tPrLn.ID
                      ,tPrLn.brief
                      ,tPrLn.description pr_name
                  FROM ins.ven_p_pol_header ph
                  JOIN ins.ven_p_policy pp
                    ON pp.policy_id = ph.policy_id
                  JOIN ins.ven_t_sales_channel sch
                    ON sch.ID = ph.sales_channel_id
                  JOIN ins.ven_as_asset ass
                    ON ass.p_policy_id = pp.policy_id
                  JOIN ins.ven_p_cover pCov
                    ON pCov.as_asset_id = ass.as_asset_id
                  JOIN ins.ven_t_prod_line_option tPrLnOp
                    ON tPrLnOp.ID = pCov.t_prod_line_option_id
                  JOIN ins.ven_t_product_line tPrLn
                    ON tPrLn.ID = tPrLnOp.product_line_id
                  LEFT JOIN ins_dwh.rep_sr_ag tt
                    ON tt.pol_id = ph.policy_header_id
                  LEFT JOIN ins.ven_contact c
                    ON c.contact_id = tt.ag_id
                  LEFT JOIN ins.ven_t_decline_reason tdr
                    ON tdr.t_decline_reason_id = pp.decline_reason_id
                 WHERE ph.start_date BETWEEN first_day AND dright
                 GROUP BY tt.ag_id
                         ,pCov.P_COVER_ID
                         ,c.obj_name_orig
                         ,ph.sales_channel_id
                         ,sch.brief
                         ,sch.description
                         ,ph.agency_id
                         ,pkg_rep_utils_ins11.get_pol_agency_name(ph.agency_id)
                         ,tPrLn.ID
                         ,tPrLn.brief
                         ,tPrLn.description
                HAVING SUM(CASE
                  WHEN ph.start_date BETWEEN dleft AND dright THEN
                   1
                  ELSE
                   0
                END) > 0)
    LOOP
    
      -- ��������� ������ � ������� 
      -- ////////////////////////////////////////////
    
      insert_row_to_sr_prog(rec.ch_name
                           ,rec.dep_name
                           ,rec.ag_fio
                           ,rec.pr_name
                           ,'������� ������ (gross)'
                           ,rec.pol_ape);
      insert_row_to_sr_prog(rec.ch_name
                           ,rec.dep_name
                           ,rec.ag_fio
                           ,rec.pr_name
                           ,'����� ������ (gross)'
                           ,rec.pol_pay_amount);
      insert_row_to_sr_prog(rec.ch_name
                           ,rec.dep_name
                           ,rec.ag_fio
                           ,rec.pr_name
                           ,'���������� ����������� ���������'
                           ,rec.pol_num);
    
      insert_row_to_sr_prog(rec.ch_name
                           ,rec.dep_name
                           ,rec.ag_fio
                           ,rec.pr_name
                           ,'APE �� ������������ ���������'
                           ,rec.dec_ape);
      insert_row_to_sr_prog(rec.ch_name
                           ,rec.dep_name
                           ,rec.ag_fio
                           ,rec.pr_name
                           ,'����� ������������ ������'
                           ,rec.dec_pay_amount);
      insert_row_to_sr_prog(rec.ch_name
                           ,rec.dep_name
                           ,rec.ag_fio
                           ,rec.pr_name
                           ,'���������� ������������ ���������'
                           ,rec.dec_num);
    
      insert_row_to_sr_prog(rec.ch_name
                           ,rec.dep_name
                           ,rec.ag_fio
                           ,rec.pr_name
                           ,'APE (net)'
                           ,rec.act_ape);
      insert_row_to_sr_prog(rec.ch_name
                           ,rec.dep_name
                           ,rec.ag_fio
                           ,rec.pr_name
                           ,'����� ���������� ������ (net)'
                           ,rec.act_pay_amount);
      insert_row_to_sr_prog(rec.ch_name
                           ,rec.dep_name
                           ,rec.ag_fio
                           ,rec.pr_name
                           ,'���������� ����������� ��������� (net)'
                           ,rec.act_num);
    
      insert_row_to_sr_prog(rec.ch_name
                           ,rec.dep_name
                           ,rec.ag_fio
                           ,rec.pr_name
                           ,'APE YTD (net)'
                           ,rec.act_ape_ytd);
      insert_row_to_sr_prog(rec.ch_name
                           ,rec.dep_name
                           ,rec.ag_fio
                           ,rec.pr_name
                           ,'���������� ������ YTD (net)'
                           ,rec.act_pay_amount_ytd);
      insert_row_to_sr_prog(rec.ch_name
                           ,rec.dep_name
                           ,rec.ag_fio
                           ,rec.pr_name
                           ,'���������� ��������� YTD (net)'
                           ,rec.act_num_ytd);
    
      insert_row_to_sr_prog(rec.ch_name
                           ,rec.dep_name
                           ,rec.ag_fio
                           ,rec.pr_name
                           ,'APE �� ���� ������� �����������'
                           ,rec.dec_oth_ape);
      insert_row_to_sr_prog(rec.ch_name
                           ,rec.dep_name
                           ,rec.ag_fio
                           ,rec.pr_name
                           ,'����� ������������ ������ �� ���� ������� �����������'
                           ,rec.dec_oth_pay_amount);
      insert_row_to_sr_prog(rec.ch_name
                           ,rec.dep_name
                           ,rec.ag_fio
                           ,rec.pr_name
                           ,'���������� ��������� �� ���� ������� �����������'
                           ,rec.dec_oth_num);
    
    END LOOP;
    COMMIT;
  END;

  -- ************************************************************************
  --/////////////////////////END SALES REPORT WITH PROGRAMM///////////////
  -- ************************************************************************
  PROCEDURE create_period_sales_report
  (
    dleft  DATE
   ,dright DATE
  ) IS
  BEGIN
    -- �������� ���������� ������ �� ��������
    create_period_sr_wo(dleft, dright);
    -- �������� ���������� ������ �� ���������
    create_period_sr_prog(dleft, dright);
  END;

  -- ************************************************************************
  --///////////////////////// ������ �������� ///////////////////////////////
  -- ************************************************************************
  FUNCTION f_rep_tr_1
  (
    p_work_date IN DATE
   ,p_error_msg OUT VARCHAR2
  ) RETURN NUMBER IS
    --res number:=0;
    tmonth VARCHAR2(2) := TO_CHAR(p_work_date, 'mm');
    tyear  VARCHAR2(4) := TO_CHAR(p_work_date, 'yyyy');
    st     VARCHAR2(30) := '����';
    cat    VARCHAR2(30) := 'AG';
  BEGIN
    create_month_tr1(tmonth, tyear, st, cat);
    RETURN 0;
  EXCEPTION
    WHEN OTHERS THEN
      p_error_msg := '��������� ������: ' || SQLCODE || '. ' || SQLERRM;
      RETURN 1;
  END;

  FUNCTION f_rep_tr_2
  (
    p_work_date IN DATE
   ,p_error_msg OUT VARCHAR2
  ) RETURN NUMBER IS
    --res number:=0;
    tmonth VARCHAR2(2) := TO_CHAR(p_work_date, 'mm');
    tyear  VARCHAR2(4) := TO_CHAR(p_work_date, 'yyyy');
  BEGIN
    create_month_tr2(tmonth, tyear);
    RETURN 0;
  EXCEPTION
    WHEN OTHERS THEN
      p_error_msg := '��������� ������: ' || SQLCODE || '. ' || SQLERRM;
      RETURN 1;
  END;

  FUNCTION f_rep_neb
  (
    p_work_date IN DATE
   ,p_error_msg OUT VARCHAR2
  ) RETURN NUMBER IS
    --res number:=0;
    tdate DATE := p_work_date - 1;
  BEGIN
    create_day_neb(TRUNC(tdate));
    RETURN 0;
  EXCEPTION
    WHEN OTHERS THEN
      p_error_msg := '��������� ������: ' || SQLCODE || '. ' || SQLERRM;
      RETURN 1;
  END;

  FUNCTION f_rep_payoff
  (
    p_work_date IN DATE
   ,p_error_msg OUT VARCHAR2
  ) RETURN NUMBER IS
    --res number:=0;
    tmonth VARCHAR2(2) := TO_CHAR(p_work_date, 'mm');
    tyear  VARCHAR2(4) := TO_CHAR(p_work_date, 'yyyy');
  BEGIN
    create_month_payoff(tmonth, tyear);
    RETURN 0;
  EXCEPTION
    WHEN OTHERS THEN
      p_error_msg := '��������� ������: ' || SQLCODE || '. ' || SQLERRM;
      RETURN 1;
  END;

/*
function test return varchar2
is
v_msg varchar2(1000):='';
v_msg2 varchar2 (1000):='';
begin
return f_rep_neb(to_date('01.01.2007'),v_msg);
v_msg2:= v_msg;
end; 
*/

-- ************************************************************************
--///////////////////////// END ������ �������� ///////////////////////////
-- ************************************************************************

END pkg_rep_utils_ins11;
/

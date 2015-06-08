CREATE OR REPLACE PACKAGE ins_dwh.pkg_reserves_vs_profit IS

  -- Author  : ARTUR.BAYTIN
  -- Created : 09.12.2011 21:48:01
  -- Purpose : ������������ ������ "������� ������ ����������"

  /*
    ������ �.
    ��������� �������� ����
  */
  FUNCTION get_report_date RETURN DATE;

  /*
    ������ �.
    ��������� ���� �������� ����
  */
  FUNCTION get_cash_sur_date RETURN DATE;

  /*
    ������ �.
    ��������� ���� �������� ����
  */
  FUNCTION get_trans_begin_date RETURN DATE;

  /*
    ������ �.
    ��������� ���� �������� ����
  */
  FUNCTION get_trans_end_date RETURN DATE;

  /*
    ��������� �.
    ��������� ���� ������ ������� �� �� �����
  */
  FUNCTION get_commiss_date_from RETURN DATE;

  /*
    ��������� �.
    ��������� ���� ��������� ������� �� �� �����
  */
  FUNCTION get_commiss_date_end RETURN DATE;

  /*
    ������ �.
    ��������� ���� ������ ������� ���
  */
  FUNCTION get_est_limits_date_from RETURN DATE;

  /*
    ��������� �.
    ��������� ���� ��������� ������� ���
  */
  FUNCTION get_est_limits_date_end RETURN DATE;

  /*
    ����� �.
    ��������� ������ ��������� ���������
  */
  FUNCTION get_commiss_num_vedom RETURN VARCHAR2;

  /*
    ����� �.
    ��������� ID ��������� ���������� ��������
  */
  FUNCTION get_commiss_ag_con_header_id RETURN NUMBER;

  /*
    ������ �.
    ������������ ������
  
    par_report_date - ���� ��������� � ���������. ��������, � ������� ���� (07.07.2011)
    par_cash_sur_date - ���� ��������� �������. ��������, � ������� ���� (30.06.2011)
    par_mode  - 0.  ������� ������ ���������� �� ���� �������������� ��������� (Prod_brief not like %CR92%, is group = 0)
                1.  ������� ������ ���������� �� ��� (Prod_brief like %CR92%);
                2.  ������� ������ ���������� �� ��������� ��������� (is group = 1);
  */
  PROCEDURE make_report
  (
    par_report_date   DATE
   ,par_cash_sur_date DATE
   ,par_truncate_mart BOOLEAN DEFAULT TRUE
  );

  /*
    ������ �.
    ���������� ������� � ����������
  */
  PROCEDURE make_transes
  (
    par_date_begin DATE
   ,par_date_end   DATE
  );

  /*
    ��������� �.
    ���������� ������� � �� �� ������
  */
  PROCEDURE make_commiss_bank
  (
    par_date_begin           DATE
   ,par_date_end             DATE
   ,par_est_limits_date_from DATE
   ,par_est_limits_date_end  DATE
   ,par_num_vedom             VARCHAR2
   ,par_ag_contract_header_id NUMBER
  );

  /*
    ������ �.
    
    ������ Job'� ��� ���������� ������ �� ��������� ��� �� ��������
    
    par_date1 - �������� ���� � ������ ��������, ���� ������ � ������ ��������
    par_date1 - ���� �������� � ������ ��������, ���� ��������� � ������ ��������
    par_mode  - 0 ��� ��������, 1 ��� ��������
  */
  PROCEDURE launch_job
  (
    par_date1 DATE
   ,par_date2 DATE
   ,par_date3 DATE
   ,par_date4 DATE
   ,par_num_vedom             VARCHAR2
   ,par_ag_contract_header_id NUMBER
   ,par_mode  NUMBER
  );

  FUNCTION get_status RETURN VARCHAR2;

END pkg_reserves_vs_profit;
/
CREATE OR REPLACE PACKAGE BODY ins_dwh.pkg_reserves_vs_profit IS

  -- �������� ����
  gv_report_date DATE;
  -- ���� �������� ����
  gv_cash_sur_date DATE;
  -- ���� ������ ������� ��� ��������
  gv_trans_begin_date DATE;
  -- ���� ��������� ������� ��� ��������
  gv_trans_end_date DATE;
  -- ���� ������ ������� ��� �� �����
  gv_commiss_date_from DATE;
  -- ���� ��������� ������� ��� �� �����
  gv_commiss_date_end DATE;
  -- ���� ������ ������� ������������
  gv_est_limits_date_from DATE;
  -- ���� ��������� ������� ������������
  gv_est_limits_date_end DATE;
  -- ����� ��������� ���������
  gv_commiss_num_vedom VARCHAR2(100);
  -- ID ��������� ���������� ��������
  gv_commiss_ag_con_header_id NUMBER;

  /*
    ������ �.
    ��������� �������� ����
  */
  FUNCTION get_report_date RETURN DATE IS
  BEGIN
    RETURN gv_report_date;
  END get_report_date;

  /*
    ������ �.
    ��������� ���� �������� ����
  */
  FUNCTION get_cash_sur_date RETURN DATE IS
  BEGIN
    RETURN gv_cash_sur_date;
  END get_cash_sur_date;

  /*
    ������ �.
    ��������� ���� �������� ����
  */
  FUNCTION get_trans_begin_date RETURN DATE IS
  BEGIN
    RETURN gv_trans_begin_date;
  END get_trans_begin_date;

  /*
    ������ �.
    ��������� ���� �������� ����
  */
  FUNCTION get_trans_end_date RETURN DATE IS
  BEGIN
    RETURN gv_trans_end_date;
  END get_trans_end_date;

  /*
    ��������� �.
    ��������� ���� ������ ������� �� �� �����
  */
  FUNCTION get_commiss_date_from RETURN DATE IS
  BEGIN
    RETURN gv_commiss_date_from;
  END get_commiss_date_from;

  /*
    ��������� �.
    ��������� ���� ��������� ������� �� �� �����
  */
  FUNCTION get_commiss_date_end RETURN DATE IS
  BEGIN
    RETURN gv_commiss_date_end;
  END get_commiss_date_end;

  /*
    ������ �.
    ��������� ���� ������ ������� ���
  */
  FUNCTION get_est_limits_date_from RETURN DATE IS
  BEGIN
    RETURN gv_est_limits_date_from;
  END get_est_limits_date_from;

  /*
    ������ �.
    ��������� ���� ��������� ������� ���
  */
  FUNCTION get_est_limits_date_end RETURN DATE IS
  BEGIN
    RETURN gv_est_limits_date_end;
  END get_est_limits_date_end;

  /*
    ����� �.
    ��������� ������ ��������� ���������
  */
  FUNCTION get_commiss_num_vedom RETURN VARCHAR2 IS
  BEGIN
    RETURN gv_commiss_num_vedom;
  END get_commiss_num_vedom;

  /*
    ����� �.
    ��������� ID ��������� ���������� ��������
  */
  FUNCTION get_commiss_ag_con_header_id RETURN NUMBER IS
  BEGIN
    RETURN gv_commiss_ag_con_header_id;
  END get_commiss_ag_con_header_id;

  /*
    ������ �.
    ������������ ������
  
    par_report_date - ���� ��������� � ���������. ��������, � ������� ���� (07.07.2011)
    par_cash_sur_date - ���� ��������� �������. ��������, � ������� ���� (30.06.2011)
  */
  PROCEDURE make_report
  (
    par_report_date   DATE
   ,par_cash_sur_date DATE
   ,par_truncate_mart BOOLEAN DEFAULT TRUE
  ) IS
  BEGIN
    -- �������� � ��������� �������� �������� ����, ���� �������� ����
    IF par_report_date IS NULL
    THEN
      raise_application_error(-20001
                             ,'�������� �������� ���� �����������!');
    END IF;
  
    -- �������� � ��������� �������� ���� �������� ����
    IF par_cash_sur_date IS NULL
    THEN
      raise_application_error(-20001
                             ,'�������� ���� �������� ���� �����������!');
    END IF;
  
    gv_report_date   := par_report_date;
    gv_cash_sur_date := par_cash_sur_date;
  
    dbms_application_info.set_client_info('RESERVES_VS_PROFIT');
  
    -- ���������� ������� ������
    ins.pkg_progress_util.set_progress_percent(p_proc_name => 'RESERVES_VS_PROFIT'
                                              ,p_doc_id    => 0
                                              ,p_progress  => 0);
    dbms_application_info.set_action('[1/8] ' || to_char(SYSDATE, 'dd.mm.yyyy HH24:MI:SS'));
    EXECUTE IMMEDIATE 'truncate table ins_dwh.reserves_vs_profit_pheader';
    EXECUTE IMMEDIATE 'insert /*+ APPEND*/ into ins_dwh.reserves_vs_profit_pheader
       select *
         from ins_dwh.v_reserves_vs_profit_pheader';
  
    dbms_stats.gather_table_stats(ownname => 'INS_DWH', tabname => 'RESERVES_VS_PROFIT_PHEADER');
  
    ins.pkg_progress_util.set_progress_percent(p_proc_name => 'RESERVES_VS_PROFIT'
                                              ,p_doc_id    => 0
                                              ,p_progress  => 12.5);
  
    dbms_application_info.set_action('[2/8] ' || to_char(SYSDATE, 'dd.mm.yyyy HH24:MI:SS'));
    EXECUTE IMMEDIATE 'truncate table ins_dwh.reserves_vs_profit_fpays';
  
    EXECUTE IMMEDIATE 'insert /*+ APPEND*/ into ins_dwh.reserves_vs_profit_fpays
       select *
         from ins_dwh.v_reserves_vs_profit_fpays';
  
    dbms_stats.gather_table_stats(ownname => 'INS_DWH', tabname => 'RESERVES_VS_PROFIT_FPAYS');
  
    ins.pkg_progress_util.set_progress_percent(p_proc_name => 'RESERVES_VS_PROFIT'
                                              ,p_doc_id    => 0
                                              ,p_progress  => 25);
  
    dbms_application_info.set_action('[3/8] ' || to_char(SYSDATE, 'dd.mm.yyyy HH24:MI:SS'));
    EXECUTE IMMEDIATE 'truncate table ins_dwh.reserves_vs_profit_lstpol';
    EXECUTE IMMEDIATE 'insert /*+ APPEND*/ into ins_dwh.reserves_vs_profit_lstpol
       select *
         from ins_dwh.v_reserves_vs_profit_lstpol';
  
    dbms_stats.gather_table_stats(ownname => 'INS_DWH', tabname => 'RESERVES_VS_PROFIT_LSTPOL');
  
    ins.pkg_progress_util.set_progress_percent(p_proc_name => 'RESERVES_VS_PROFIT'
                                              ,p_doc_id    => 0
                                              ,p_progress  => 37.5);
  
    dbms_application_info.set_action('[4/8] ' || to_char(SYSDATE, 'dd.mm.yyyy HH24:MI:SS'));
    EXECUTE IMMEDIATE 'truncate table ins_dwh.reserves_vs_profit_pol';
    EXECUTE IMMEDIATE 'insert /*+ APPEND*/ into ins_dwh.reserves_vs_profit_pol
       select *
         from ins_dwh.v_reserves_vs_profit_pol';
  
    dbms_stats.gather_table_stats(ownname => 'INS_DWH', tabname => 'RESERVES_VS_PROFIT_POL');
  
    ins.pkg_progress_util.set_progress_percent(p_proc_name => 'RESERVES_VS_PROFIT'
                                              ,p_doc_id    => 0
                                              ,p_progress  => 50);
  
    dbms_application_info.set_action('[5/8] ' || to_char(SYSDATE, 'dd.mm.yyyy HH24:MI:SS'));
    EXECUTE IMMEDIATE 'truncate table ins_dwh.reserves_vs_profit_cover_ag';
    EXECUTE IMMEDIATE 'insert /*+ APPEND*/ into ins_dwh.reserves_vs_profit_cover_ag
       select *
         from ins_dwh.v_reserves_vs_profit_cover_ag';
  
    dbms_stats.gather_table_stats(ownname => 'INS_DWH', tabname => 'RESERVES_VS_PROFIT_COVER_AG');
  
    ins.pkg_progress_util.set_progress_percent(p_proc_name => 'RESERVES_VS_PROFIT'
                                              ,p_doc_id    => 0
                                              ,p_progress  => 62.5);
  
    dbms_application_info.set_action('[6/8] ' || to_char(SYSDATE, 'dd.mm.yyyy HH24:MI:SS'));
    EXECUTE IMMEDIATE 'truncate table ins_dwh.reserves_vs_profit_trans_ag';
    EXECUTE IMMEDIATE 'insert /*+ APPEND*/ into ins_dwh.reserves_vs_profit_trans_ag
       select *
         from ins_dwh.v_reserves_vs_profit_trans_ag';
  
    dbms_stats.gather_table_stats(ownname => 'INS_DWH', tabname => 'RESERVES_VS_PROFIT_TRANS_AG');
  
    ins.pkg_progress_util.set_progress_percent(p_proc_name => 'RESERVES_VS_PROFIT'
                                              ,p_doc_id    => 0
                                              ,p_progress  => 75);
  
    dbms_application_info.set_action('[7/8] ' || to_char(SYSDATE, 'dd.mm.yyyy HH24:MI:SS'));
    EXECUTE IMMEDIATE 'truncate table ins_dwh.reserves_vs_profit_pcover';
    EXECUTE IMMEDIATE 'insert /*+ APPEND*/ into ins_dwh.reserves_vs_profit_pcover
       (p_cover_id, product_line_id, p_policy_id, is_mandatory, plo_description, plo_id
       ,sh_brief, type_insurance, is_avtoprolongation, sex_child, date_birth_child, pwop_0
       ,pwop_1, start_date, cn_pol_insurer_obj_name, ll_brief, ext_id, insured_age, end_date
       ,rvb_value, decline_date, normrate_value, cn_pol_insurer_contact_id
       ,cn_pol_insurer_date_of_death, cn_pol_insurer_date_of_birth, k_coef_m, s_coef_nm
       ,k_coef_nm, fee, ins_amount, ll_description, ig_life_property, ig_life_property_num
       ,cn_pol_insurer_gender, t_prod_line_option_id, p_asset_header_id, ll_t_lob_line_id
       ,program_start, program_end, program_sum, for_re, reinsured, charge_premium, is_adm_cost, version_risk_incl
       ,ep_non_med_order, PARENT_COVER_RSBU_ID, PARENT_COVER_IFRS_ID, is_assured_resident, work_group_id)
       select p_cover_id, product_line_id, p_policy_id, is_mandatory, plo_description, plo_id
             ,sh_brief, type_insurance, is_avtoprolongation, sex_child, date_birth_child, pwop_0
             ,pwop_1, start_date, cn_pol_insurer_obj_name, ll_brief, ext_id, insured_age, end_date
             ,rvb_value, decline_date, normrate_value, cn_pol_insurer_contact_id
             ,cn_pol_insurer_date_of_death, cn_pol_insurer_date_of_birth, k_coef_m, s_coef_nm
             ,k_coef_nm, fee, ins_amount, ll_description, ig_life_property, ig_life_property_num
             ,cn_pol_insurer_gender, t_prod_line_option_id, p_asset_header_id, ll_t_lob_line_id
             ,program_start, program_end, program_sum, for_re, reinsured, charge_premium, is_adm_cost, version_risk_incl
             ,ep_non_med_order, PARENT_COVER_RSBU_ID, PARENT_COVER_IFRS_ID, is_assured_resident, work_group_id
         from ins_dwh.v_reserves_vs_profit_pcover';
  
    dbms_stats.gather_table_stats(ownname => 'INS_DWH', tabname => 'RESERVES_VS_PROFIT_PCOVER');
  
    ins.pkg_progress_util.set_progress_percent(p_proc_name => 'RESERVES_VS_PROFIT'
                                              ,p_doc_id    => 0
                                              ,p_progress  => 87.5);
  
    dbms_application_info.set_action('[8/8] ' || to_char(SYSDATE, 'dd.mm.yyyy HH24:MI:SS'));
    IF par_truncate_mart
    THEN
      EXECUTE IMMEDIATE 'truncate table ins_dwh.reserves_vs_profit';
    END IF;
    EXECUTE IMMEDIATE 'insert /*+ APPEND*/ into ins_dwh.reserves_vs_profit
     select to_char(rownum) as pk
           ,vrs.*
       from ins_dwh.v_reserves_vs_profit vrs';
  
    COMMIT;
    dbms_stats.gather_table_stats(ownname => 'INS_DWH', tabname => 'RESERVES_VS_PROFIT');
  
    ins.pkg_progress_util.set_progress_percent(p_proc_name => 'RESERVES_VS_PROFIT'
                                              ,p_doc_id    => 0
                                              ,p_progress  => 100);
  END make_report;

  /*
    ������ �.
    ���������� ������� � ����������
  */
  PROCEDURE make_transes
  (
    par_date_begin DATE
   ,par_date_end   DATE
  ) IS
  BEGIN
    IF par_date_begin IS NULL
    THEN
      raise_application_error(-20001
                             ,'�������� ���� ������ �����������!');
    END IF;
  
    IF par_date_end IS NULL
    THEN
      raise_application_error(-20001
                             ,'�������� ���� ��������� �����������!');
    END IF;
  
    gv_trans_begin_date := par_date_begin;
    gv_trans_end_date   := par_date_end;
  
    dbms_application_info.set_client_info('RESERVES_VS_PROFIT');
  
    ins.pkg_progress_util.set_progress_percent(p_proc_name => 'RESERVES_VS_PROFIT'
                                              ,p_doc_id    => 0
                                              ,p_progress  => 0);
    EXECUTE IMMEDIATE 'truncate table INS_DWH.TRANS_REP';
    -- ���������� �������
    dbms_application_info.set_action('�������� ������� ��������');
    EXECUTE IMMEDIATE 'insert /*+ APPEND*/ into INS_DWH.TRANS_REP
       select *
         from INS_DWH.V_TRANS_REP';
  
    COMMIT;
    dbms_stats.gather_table_stats(ownname => 'INS_DWH', tabname => 'TRANS_REP');
  
    ins.pkg_progress_util.set_progress_percent(p_proc_name => 'RESERVES_VS_PROFIT'
                                              ,p_doc_id    => 0
                                              ,p_progress  => 100);
  END make_transes;

  /*
    ��������� �.
    ���������� ������� � �� �� ������
  */
  PROCEDURE make_commiss_bank
  (
    par_date_begin           DATE
   ,par_date_end             DATE
   ,par_est_limits_date_from DATE
   ,par_est_limits_date_end  DATE
   ,par_num_vedom             VARCHAR2
   ,par_ag_contract_header_id NUMBER
  ) IS
  BEGIN
    IF par_date_begin IS NULL
    THEN
      raise_application_error(-20001
                             ,'�������� ���� ������ ������� �����������!');
    END IF;
  
    IF par_date_end IS NULL
    THEN
      raise_application_error(-20001
                             ,'�������� ���� ��������� ������� �����������!');
    END IF;
  
    gv_commiss_date_from    := par_date_begin;
    gv_commiss_date_end     := par_date_end;
    gv_est_limits_date_from := par_est_limits_date_from;
    gv_est_limits_date_end  := par_est_limits_date_end;
    gv_commiss_num_vedom        := par_num_vedom;
    gv_commiss_ag_con_header_id := par_ag_contract_header_id;
  
    dbms_application_info.set_client_info('MAKE_COMMISS_BANK');
  
    ins.pkg_progress_util.set_progress_percent(p_proc_name => 'RESERVES_VS_PROFIT'
                                              ,p_doc_id    => 0
                                              ,p_progress  => 0);
    EXECUTE IMMEDIATE 'truncate table INS_DWH.COMMISS_BANK_REP';
    -- ���������� �������
    dbms_application_info.set_action('���������� ������� �� �����');
    ins.pkg_trace.add_variable('get_est_limits_date_from'
                              ,ins_dwh.pkg_reserves_vs_profit.get_est_limits_date_from);
    ins.pkg_trace.add_variable('get_est_limits_date_end'
                              ,ins_dwh.pkg_reserves_vs_profit.get_est_limits_date_end);
    ins.pkg_trace.add_variable('get_commiss_date_from'
                              ,ins_dwh.pkg_reserves_vs_profit.get_commiss_date_from);
    ins.pkg_trace.add_variable('get_commiss_date_end'
                              ,ins_dwh.pkg_reserves_vs_profit.get_commiss_date_end);
    ins.pkg_trace.add_variable('get_commiss_num_vedom'
                              ,ins_dwh.pkg_reserves_vs_profit.get_commiss_num_vedom);
    ins.pkg_trace.add_variable('get_commiss_ag_con_header_id'
                              ,ins_dwh.pkg_reserves_vs_profit.get_commiss_ag_con_header_id);
    ins.pkg_trace.trace(par_trace_obj_name    => 'PKG_RESERVES_VS_PROFIT'
                       ,par_trace_subobj_name => 'MAKE_COMMISS_BANK'
                       ,par_message           => '������� ������');
    EXECUTE IMMEDIATE 'insert /*+ APPEND*/ into INS_DWH.COMMISS_BANK_REP
       select *
         from INS_DWH.V_COMMISSION_SMEAR_OAV_BANK';
  
    COMMIT;
    dbms_stats.gather_table_stats(ownname => 'INS_DWH', tabname => 'COMMISS_BANK_REP');
  
    ins.pkg_progress_util.set_progress_percent(p_proc_name => 'RESERVES_VS_PROFIT'
                                              ,p_doc_id    => 0
                                              ,p_progress  => 100);
  END make_commiss_bank;

  /*
    ������ �.
    
    ������ Job'� ��� ���������� ������ �� ��������� ��� �� ��������
    
    par_date1 - �������� ���� � ������ ��������, ���� ������ � ������ ��������
    par_date1 - ���� �������� � ������ ��������, ���� ��������� � ������ ��������
    par_mode  - 0.  ��� ���� ���������
                1.  ��������
                2.  �� �����
                3.  ������� ��� ��������
  
  */
  PROCEDURE launch_job
  (
    par_date1 DATE
   ,par_date2 DATE
   ,par_date3 DATE
   ,par_date4 DATE
   ,par_num_vedom             VARCHAR2
   ,par_ag_contract_header_id NUMBER
   ,par_mode  NUMBER
  ) IS
  BEGIN
    IF par_mode = 0 -- "��� ���� ���������"
    THEN
      ins.pkg_scheduler.run_scheduled(p_name     => 'RESERVES_VS_PROFIT'
                                     ,p_code     => 'begin
    ins_dwh.pkg_reserves_vs_profit.make_report
    (par_report_date   => to_date(''' ||
                                                    to_char(par_date1, 'ddmmyyyy') ||
                                                    ''',''ddmmyyyy'')
    ,par_cash_sur_date => to_date(''' ||
                                                    to_char(par_date2, 'ddmmyyyy') ||
                                                    ''',''ddmmyyyy'')
    ,par_truncate_mart => true); end;'
                                     ,p_parallel => 1);
    ELSIF par_mode = 1 -- "��������"
    THEN
      ins.pkg_scheduler.run_scheduled(p_name     => 'RESERVES_VS_PROFIT'
                                     ,p_code     => 'begin ins_dwh.pkg_reserves_vs_profit.make_transes
    (par_date_begin => to_date(''' ||
                                                    to_char(par_date1, 'ddmmyyyy') ||
                                                    ''',''ddmmyyyy'')
    ,par_date_end   => to_date(''' ||
                                                    to_char(par_date2, 'ddmmyyyy') ||
                                                    ''',''ddmmyyyy'')); end;'
                                     ,p_parallel => 1);
    ELSIF par_mode = 2 -- "�� �����"
    THEN
      ins.pkg_scheduler.run_scheduled(p_name     => 'RESERVES_VS_PROFIT'
                                     ,p_code     => 'begin ins_dwh.pkg_reserves_vs_profit.make_commiss_bank
                                                     ( par_date_begin => to_date(''' ||
                                                    to_char(par_date1, 'ddmmyyyy') ||
                                                    ''',''ddmmyyyy'')
    ,par_date_end   => to_date(''' ||
                                                    to_char(par_date2, 'ddmmyyyy') ||
                                                    ''',''ddmmyyyy'')
    ,par_est_limits_date_from   => to_date(''' ||
                                                    to_char(par_date3, 'ddmmyyyy') ||
                                                    ''',''ddmmyyyy'')
    ,par_est_limits_date_end   => to_date(''' ||
                                                    to_char(par_date4, 'ddmmyyyy') ||
                                                    ''',''ddmmyyyy'')
                                                      ,par_num_vedom => ''' ||
                                                    par_num_vedom || '''
                                                      ,par_ag_contract_header_id => ''' ||
                                                    par_ag_contract_header_id || '''); end;'
                                     ,p_parallel => 1);
    ELSIF par_mode = 3 -- "������� ��� ��������"
    THEN
      ins.pkg_scheduler.run_scheduled(p_name     => 'RESERVES_VS_PROFIT'
                                     ,p_code     => 'begin
    ins_dwh.pkg_reserves_vs_profit.make_report
    (par_report_date   => to_date(''' ||
                                                    to_char(par_date1, 'ddmmyyyy') ||
                                                    ''',''ddmmyyyy'')
    ,par_cash_sur_date => to_date(''' ||
                                                    to_char(par_date2, 'ddmmyyyy') ||
                                                    ''',''ddmmyyyy'')
    ,par_truncate_mart => true);
    
    ins_dwh.pkg_reserves_vs_profit.make_transes
    (par_date_begin => to_date(''' ||
                                                    to_char(par_date3, 'ddmmyyyy') ||
                                                    ''',''ddmmyyyy'')
    ,par_date_end   => to_date(''' ||
                                                    to_char(par_date4, 'ddmmyyyy') ||
                                                    ''',''ddmmyyyy''));end;'
                                     ,p_parallel => 1);
    END IF;
  
  END launch_job;

  FUNCTION get_status RETURN VARCHAR2 IS
    v_status VARCHAR2(250);
  BEGIN
  
    v_status := to_char(ins.pkg_progress_util.get_progress_percent(p_proc_name => 'RESERVES_VS_PROFIT'
                                                                  ,p_doc_id    => 0));
    IF v_status IS NOT NULL
    THEN
      v_status := '������� ����������: ' || v_status;
    ELSE
      v_status := '� ��������� ������ ������� �� ������� ��� ��� ��������';
    END IF;
    RETURN v_status;
  END get_status;

END pkg_reserves_vs_profit;
/

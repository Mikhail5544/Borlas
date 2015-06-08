CREATE OR REPLACE PACKAGE pkg_ag_nonpayment_frm IS

  -- Author  : ������ �.
  -- Created : 27.03.2012 20:25:08
  -- Purpose : ������ ����� AG_NONPAYMENT

  /*
    ������� ����� � ��������� �������
  */
  PROCEDURE send_mail
  (
    par_pol_plan_date_from DATE -- ���� ������ �� "��" (����)
   ,par_pol_plan_date_to   DATE -- ���� ������ �� "��" (����)
   ,par_epg_plan_date_from DATE -- ���� ������� "��" (����)
   ,par_epg_plan_date_to   DATE -- ���� ������� "��" (����)
    
   ,par_pol_fact_date_from DATE -- ���� ������ �� "��" (����)
   ,par_pol_fact_date_to   DATE -- ���� ������ �� "��" (����)
   ,par_epg_fact_date_from DATE -- ���� ������� "��" (����)
   ,par_epg_fact_date_to   DATE -- ���� ������� "��" (����)
    
   ,par_control_email VARCHAR2 -- ����� ��� �������� ������� ������
  );

  /**
  * @author  : ������ �.
  * @Created : 27.03.2012 16:00:00
  * @Purpose : ������ ����� AG_NONPAYMENT
  * @param par_epg_grace_date_from - ���� ������� "��"
  * @param par_epg_grace_date_to   - ���� ������� "��"
  * @param par_control_email       - ����� ��� �������� ������� ������
  * @param par_content_email       - �������������� ����� � ������
  *
  * ������� ����� � ��������� ������� �� ������ ������
  * DWH_����� � ���������_������ ������_2011, ���� - ����������� ������� �� ��������� ������
  */
  PROCEDURE send_mail_01
  (
    par_epg_grace_date_from DATE
   ,par_epg_grace_date_to   DATE
    
   ,par_control_email         VARCHAR2
   ,par_content_email         VARCHAR2 := NULL
   ,par_to_only_control_email NUMBER -- ��������, ������������� � AG_NONPAYMENT.FMB, ����������� �������� ������ ������ ������ ���������� e-mail ��� ���� (1 ��� 0 ��������������)
  );

  /**
  * @author  : ������ �.
  * @Created : 26.06.2012 17:25:00
  * @Purpose : ������ ����� AG_NONPAYMENT
  * @param   : par_pol_plan_date_from  date - ���� ������ �� "��" (����)
  * @param   : par_pol_plan_date_to    date - ���� ������ �� "��" (����)
  * @param   : par_epg_plan_date_from  date - ���� ������� "��" (����)
  * @param   : par_epg_plan_date_to    date - ���� ������� "��" (����)
  * @param   : par_pol_fact_date_from  date - ���� ������ �� "��" (����)
  * @param   : par_pol_fact_date_to    date - ���� ������ �� "��" (����)
  * @param   : par_epg_fact_date_from  date - ���� ������� "��" (����)
  * @param   : par_epg_fact_date_to    date - ���� ������� "��" (����)
  * @param par_control_email           varchar2 - ����� ��� �������� ������� ������
  * @param par_content_email           varchar2 - �������������� ����� � ������
  * 
  * ������� ����� � ��������� ������� �� ������ ������
  * DWH_����� � ���������+�����������_��� ��������, ���� - �����������
  */
  PROCEDURE send_mail_02
  (
    par_pol_plan_date_from DATE -- ���� ������ �� "��" (����)
   ,par_pol_plan_date_to   DATE -- ���� ������ �� "��" (����)
   ,par_epg_plan_date_from DATE -- ���� ������� "��" (����)
   ,par_epg_plan_date_to   DATE -- ���� ������� "��" (����)
   ,par_pol_fact_date_from DATE -- ���� ������ �� "��" (����)
   ,par_pol_fact_date_to   DATE -- ���� ������ �� "��" (����)
   ,par_epg_fact_date_from DATE -- ���� ������� "��" (����)
   ,par_epg_fact_date_to   DATE -- ���� ������� "��" (����)
    --,par_pol_status     varchar2  := null -- ������ ��������� ������
    --,par_pol_term       varchar2  := null -- �������������
    --,par_agency         varchar2  := null -- ��������
    
   ,par_control_email         pkg_email.t_recipients -- ����� ��� �������� ������� ������
   ,par_content_email         VARCHAR2 := NULL -- �������������� ����� � ������
   ,par_to_only_control_email NUMBER -- ��������, ������������� � AG_NONPAYMENT.FMB, ����������� �������� ������ ������ ������ ���������� e-mail ��� ���� (1 ��� 0 ��������������)
  );

  -- Author  : �������� �.�.
  -- Created : 27.04.2015
  -- Purpose : 410200: ������������� ������������ ������ � ���������
  -- Comment : ��������� ������������������ �������� ������ � ���������.
  --           ���������� �� ����� JOB_REP_AG_NONPAYMENT
  PROCEDURE send_ag_nonpayment_job;

END pkg_ag_nonpayment_frm;
/
CREATE OR REPLACE PACKAGE BODY pkg_ag_nonpayment_frm IS

  gc_file_ext CONSTANT VARCHAR2(30) := '.xls';

  /* ��������� ���� ������ ������������ �����
  * ��������� ����� ��� ����� ������ ������������ ����� 
  * 181084: ������������ ������� �������� ������ �� ���������
  * @autor ������ �.�.
  * @param par_file - ���� ������
  */
  PROCEDURE init_rep_email_sended(par_log_files IN OUT NOCOPY pkg_email.t_files) IS
    v_row_raw RAW(2500);
  BEGIN
    --��������� ���������
    par_log_files.extend(1);
    --���������� ��� �����
    par_log_files(1).v_file_type := 'application/excel';
    --������� ��������� ���������� ������� 
    dbms_lob.createtemporary(lob_loc => par_log_files(1).v_file --������� LOB
                            ,cache   => TRUE); --��������� ������ �� ������ lob ��� ������ ���������� � �������� ���    
    --���������� ������������ �����
    par_log_files(1).v_file_name := '������ �������� ������ �� ���������' || gc_file_ext;
  
    dbms_lob.trim(lob_loc => par_log_files(1).v_file, newlen => 0);
  
    -- ��������� ���������
    v_row_raw := utl_raw.cast_to_raw('������������ ������' || chr(9) --1
                                     || '��� ������' || chr(9) --2
                                     || '���� �������� ������' || chr(9) --3
                                     || '��������' || chr(9) --4
                                     || '��� ��������' || chr(9) --5
                                     || 'e-mail ��������' || chr(9) --6
                                     || '����� 1 ��� ��������' || chr(9) --7
                                     || '����� 1 e-mail ��������' || chr(9) --8                                   
                                     || '����� 2 ��� ��������' || chr(9) --9 
                                     || '����� 2 e-mail ��������' || chr(9) --10                                    
                                     || utl_tcp.crlf);
    dbms_lob.writeappend(lob_loc => par_log_files(1).v_file
                        ,amount  => utl_raw.length(v_row_raw)
                        ,buffer  => v_row_raw);
  END;

  /* ��������� ������ ��� ������ ������������ ����� 
  * 181084: ������������ ������� �������� ������ �� ���������
  * @autor ������ �.�.
  * @param par_rep_name    - ������������ ������
  * @param par_rep_type    - ��� ������
  * @param par_agency      - ��������
  * @param par_name_to     - ��� ��������
  * @param par_email_to    - e-mail ��������
  * @param par_name_cc     - ����� 1 ��� ��������
  * @param par_email_cc    - ����� 1 e-mail ��������
  * @param par_name_cc2    - ����� 2 ��� ��������
  * @param par_email_cc2   - ����� 2 e-mail ��������
  * @param par_file        - ���� ������  
  */

  PROCEDURE add_rep_email_sended
  (
    par_rep_name  VARCHAR2
   ,par_rep_type  VARCHAR2
   ,par_agency    VARCHAR2
   ,par_name_to   VARCHAR2
   ,par_email_to  VARCHAR2
   ,par_name_cc   VARCHAR2
   ,par_email_cc  VARCHAR2
   ,par_name_cc2  VARCHAR2
   ,par_email_cc2 VARCHAR2
   ,par_file      IN OUT NOCOPY BLOB
  ) IS
    v_row         VARCHAR2(2500);
    v_row_raw     RAW(2500);
    v_mail_date   DATE;
    v_err_message sys_emails_log.err_message%TYPE;
  BEGIN
    NULL;
  
    --������� ��������� ������ ��������� � ����
    BEGIN
      SELECT mail_date
            ,err_message
        INTO v_mail_date
            ,v_err_message
        FROM (SELECT slog.mail_date
                    ,slog.err_message
                FROM sys_emails_log slog
               WHERE slog.to_list = par_email_to --email �����������
                 AND slog.sender = USER --������������ ����������� ������
                 AND slog.subject LIKE '%' || par_rep_name --������������ ������/������� ������
                 AND slog.mail_date = (SELECT MAX(log_.mail_date)
                                         FROM sys_emails_log log_
                                        WHERE log_.to_list = slog.to_list
                                          AND log_.mail_date <= SYSDATE
                                          AND log_.to_list = par_email_to
                                          AND log_.sender = USER
                                          AND log_.subject LIKE '%' || par_rep_name)
               ORDER BY err_message DESC)
       WHERE rownum = 1; --��� ������������(����� ���� ���� email �� ���� ����)                        
    EXCEPTION
      WHEN no_data_found THEN
        v_mail_date   := NULL;
        v_err_message := '�� ������� ������ � ������� ������������ �����';
    END;
  
    --���� �� ���� ������
    IF v_err_message IS NULL
    THEN
    
      -- ��������� ������ �����        
      v_row     := par_rep_name || chr(9) -- 1
                   || par_rep_type || chr(9) -- 2
                   || v_mail_date || chr(9) -- 3
                   || par_agency || chr(9) -- 4
                   || par_name_to || chr(9) -- 5
                   || par_email_to || chr(9) -- 6
                   || par_name_cc || chr(9) -- 7
                   || par_email_cc || chr(9) -- 8
                   || par_name_cc2 || chr(9) -- 9
                   || par_email_cc2 || chr(9) -- 10
                   || utl_tcp.crlf;
      v_row_raw := utl_raw.cast_to_raw(v_row);
      dbms_lob.writeappend(lob_loc => par_file
                          ,amount  => utl_raw.length(v_row_raw)
                          ,buffer  => v_row_raw);
    END IF;
  END;

  /*
    ������ �.
    ���������� ��������� ������� �������
  */
  PROCEDURE prepare_data
  (
    par_pol_date_from  DATE -- ���� ������ �� "��"
   ,par_pol_date_to    DATE -- ���� ������ �� "��"
   ,par_epg_date_from  DATE -- ���� ������� "��"
   ,par_epg_date_to    DATE -- ���� ������� "��"
   ,par_plan_fact_flag VARCHAR2 -- ����/����
  ) IS
  BEGIN
    INSERT INTO tmp_ag_nonpayment
      (c_2
      ,c_1
      ,sales_channel
      ,insurer
      ,pol_num
      ,prod_desc
      ,start_date
      ,epg_status
      ,pay_term
      ,agency
      ,AGENT
      ,agent_leader
      ,ids
      ,tel_home
      ,tel_pers
      ,tel_work
      ,tel_mobil
      ,tel_cont
      ,agent_contact_id
      ,leader_contact_id
      ,epg_sum
      ,set_off_sum
      ,plan_fact)
      SELECT c_2
            ,c_1
            ,sales_channel
            ,insurer
            ,pol_num
            ,prod_desc
            ,to_char(start_date, 'dd.mm.yyyy')
            ,epg_status
            ,pay_term
            ,agency
            ,AGENT
            ,agent_leader
            ,ids
            ,tel_home
            ,tel_pers
            ,tel_work
            ,tel_mobil
            ,tel_cont
            ,agent_contact_id
            ,leader_contact_id
            ,to_char(SUM(epg_sum))
            ,to_char(SUM(set_off_sum))
            ,par_plan_fact_flag
        FROM (SELECT CASE
                       WHEN epg."������� 1��� ���" = 1 THEN
                        ' ���������� ��������� (������ ������)'
                       ELSE
                        CASE
                          WHEN epg."���� ���" - ph.start_date < 365 THEN
                           '��������� ������� 1 ����'
                          ELSE
                           '��������� ������� 2 � ����������� ����'
                        END
                     END AS c_2
                     ,CASE
                       WHEN epg."��� ��������" = '����������� ������' THEN
                        '������ ����� ����'
                       ELSE
                        epg."��� ��������"
                     END AS c_1
                     ,sc.description AS sales_channel
                     ,ph.insurer
                     ,ph.pol_num
                     ,ph.prod_desc
                     ,ph.start_date
                     ,epg."������ ���" AS epg_status
                     ,ph.pay_term
                     ,ph.agency
                     ,ph.agent
                     ,ph.agent_leader
                     ,to_char(ph.ids) AS ids
                     ,co.tel_home
                     ,co.tel_pers
                     ,co.tel_work
                     ,co.tel_mobil
                     ,co.tel_cont
                     ,cha.agent_id AS agent_contact_id
                     ,chm.agent_id AS leader_contact_id
                     ,epg."����� ��� �" AS epg_sum
                     ,epg."��������� �� ��� ����� �" AS set_off_sum
                FROM ins_dwh.dm_contact         co
                    ,ins_dwh.dm_p_pol_header    ph
                    ,ins_dwh.dm_t_sales_channel sc
                    ,ins_dwh.fc_egp             epg
                    ,ins.ag_contract_header     cha
                    ,ins.ag_contract            cna
                    ,ins.ag_contract            cnm
                    ,ins.ag_contract_header     chm
               WHERE ph.policy_header_id = epg."ID �������� �����������"
                 AND ph.agent_header_id = cha.ag_contract_header_id
                 AND cha.last_ver_id = cna.ag_contract_id
                 AND cna.contract_leader_id = cnm.ag_contract_id(+)
                 AND cnm.contract_id = chm.ag_contract_header_id(+)
                 AND sc.id = ph.sales_channel_id
                 AND ph.insurer_contact_id = co.contact_id
                 AND ph.agency != '������� ������ � ���������'
                 AND ph.is_group_flag = 0
                 AND ph.prod_desc NOT LIKE '%CR%'
                 AND sc.description NOT IN ('����������', '����������')
                 AND ph.last_ver_stat NOT IN ('����������'
                                             ,'��������'
                                             ,'�������'
                                             ,'�������������'
                                             ,'��������� � �����������'
                                             ,'��������� �� �����������'
                                             ,'� �����������'
                                             ,'� �����������. ����� ��� ��������'
                                             ,'� �����������. ��������'
                                             ,'���������. ������ ����������'
                                             ,'���������. ��������� ��������'
                                             ,'���������.� �������'
                                             ,'���������')
                 AND epg."���� ���" BETWEEN par_epg_date_from AND par_epg_date_to
                 AND ph.start_date BETWEEN par_pol_date_from AND par_pol_date_to
                 AND epg."������ ���" != '�����������')
       GROUP BY c_2
               ,c_1
               ,sales_channel
               ,insurer
               ,pol_num
               ,prod_desc
               ,start_date
               ,epg_status
               ,pay_term
               ,agency
               ,AGENT
               ,agent_leader
               ,ids
               ,tel_home
               ,tel_pers
               ,tel_work
               ,tel_mobil
               ,tel_cont
               ,agent_contact_id
               ,leader_contact_id
      HAVING SUM(epg_sum) != 0;
  END prepare_data;

  /*
    ������ �.
    ���������� ���������� � ������
  */
  PROCEDURE make_file
  (
    par_ag_contact_id NUMBER DEFAULT NULL
   ,par_mn_contact_id NUMBER DEFAULT NULL
   ,par_agency        VARCHAR2 DEFAULT NULL
   ,par_plan_fact     VARCHAR2
   ,par_file          IN OUT NOCOPY BLOB
  ) IS
    CURSOR cur_send_data
    (
      par_ag_contact_id NUMBER
     ,par_mn_contact_id NUMBER
     ,par_agency        VARCHAR2
     ,par_plan_fact     VARCHAR2
    ) IS
      SELECT c_2
            ,c_1
            ,sales_channel
            ,insurer
            ,pol_num
            ,prod_desc
            ,start_date
            ,epg_status
            ,pay_term
            ,agency
            ,AGENT
            ,agent_leader
            ,ids
            ,tel_home
            ,tel_pers
            ,tel_work
            ,tel_mobil
            ,tel_cont
            ,epg_sum
            ,set_off_sum
        FROM tmp_ag_nonpayment tmp
       WHERE tmp.plan_fact = par_plan_fact
         AND ((par_ag_contact_id IS NOT NULL AND tmp.agent_contact_id = par_ag_contact_id) OR
             (par_mn_contact_id IS NOT NULL AND tmp.leader_contact_id = par_mn_contact_id) OR
             (par_agency IS NOT NULL AND tmp.agency = par_agency) OR
             (par_agency IS NULL AND par_ag_contact_id IS NULL AND par_mn_contact_id IS NULL))
       ORDER BY tmp.agent_leader
               ,tmp.agent
               ,tmp.insurer;
    v_data_row cur_send_data%ROWTYPE;
    v_row      VARCHAR2(2500);
    v_row_raw  RAW(2500);
  BEGIN
    dbms_lob.trim(lob_loc => par_file, newlen => 0);
    -- ����� ���������
    v_row_raw := utl_raw.cast_to_raw('������������ ������' || chr(9) --1
                                     || '�����' || chr(9) -- 2
                                     || '��� ������������' || chr(9) -- 3
                                     || '���. ���.' || chr(9) -- 4
                                     || '����. ���.' || chr(9) -- 5
                                     || '���. ���.' || chr(9) -- 6
                                     || '���. ���.' || chr(9) -- 7
                                     || '����. ���.' || chr(9) -- 8
                                     || '�������' || chr(9) -- 9
                                     || '����� ��' || chr(9) -- 10
                                     || '������������� ��' || chr(9) -- 11
                                     || '���� ������ ��' || chr(9) -- 12
                                     || '������������� ������' || chr(9) -- 13
                                     || '��� �������' || chr(9) -- 14
                                     || '����� �������, ���.' || chr(9) -- 15
                                     || '��������, ���.' || chr(9) -- 16
                                     || '������ ������� � �������' || chr(9) -- 17
                                     || '��� ��������' || chr(9) -- 18
                                     || '����. ������ ������' || chr(9) -- 19
                                     || utl_tcp.crlf);
    dbms_lob.writeappend(lob_loc => par_file
                        ,amount  => utl_raw.length(v_row_raw)
                        ,buffer  => v_row_raw);
    -- ��������� ������ �����
    OPEN cur_send_data(par_ag_contact_id => par_ag_contact_id
                      ,par_mn_contact_id => par_mn_contact_id
                      ,par_agency        => par_agency
                      ,par_plan_fact     => par_plan_fact);
    LOOP
      FETCH cur_send_data
        INTO v_data_row;
      EXIT WHEN cur_send_data%NOTFOUND;
      v_row     := v_data_row.agent_leader || chr(9) -- 1
                   || v_data_row.agent || chr(9) -- 2
                   || v_data_row.insurer || chr(9) -- 3
                   || v_data_row.tel_home || chr(9) -- 4
                   || v_data_row.tel_pers || chr(9) -- 5
                   || v_data_row.tel_work || chr(9) -- 6
                   || v_data_row.tel_mobil || chr(9) -- 7
                   || v_data_row.tel_cont || chr(9) -- 8
                   || v_data_row.prod_desc || chr(9) -- 9
                   || v_data_row.pol_num || chr(9) -- 10
                   || v_data_row.ids || chr(9) -- 11
                   || v_data_row.start_date || chr(9) -- 12
                   || v_data_row.pay_term || chr(9) -- 13
                   || v_data_row.c_2 || chr(9) -- 14
                   || v_data_row.epg_sum || chr(9) -- 15
                   || v_data_row.set_off_sum || chr(9) -- 16
                   || v_data_row.epg_status || chr(9) -- 17
                   || v_data_row.c_1 || chr(9) -- 18
                   || v_data_row.sales_channel -- 19
                   || utl_tcp.crlf;
      v_row_raw := utl_raw.cast_to_raw(v_row);
      dbms_lob.writeappend(lob_loc => par_file
                          ,amount  => utl_raw.length(v_row_raw)
                          ,buffer  => v_row_raw);
    END LOOP;
    CLOSE cur_send_data;
  END;

  /*
    ������ �.
    ������� ����� � ��������� �������
  */
  PROCEDURE send_mail
  (
    par_pol_plan_date_from DATE -- ���� ������ �� "��" (����)
   ,par_pol_plan_date_to   DATE -- ���� ������ �� "��" (����)
   ,par_epg_plan_date_from DATE -- ���� ������� "��" (����)
   ,par_epg_plan_date_to   DATE -- ���� ������� "��" (����)
    
   ,par_pol_fact_date_from DATE -- ���� ������ �� "��" (����)
   ,par_pol_fact_date_to   DATE -- ���� ������ �� "��" (����)
   ,par_epg_fact_date_from DATE -- ���� ������� "��" (����)
   ,par_epg_fact_date_to   DATE -- ���� ������� "��" (����)
    
   ,par_control_email VARCHAR2 -- ����� ��� �������� ������� ������
  ) IS
    v_files       pkg_email.t_files := pkg_email.t_files();
    c_plan_period VARCHAR2(15) := to_char(par_epg_plan_date_from, 'dd-mm') || ' - ' ||
                                  to_char(par_epg_plan_date_to, 'dd-mm');
    c_fact_period VARCHAR2(15) := to_char(par_epg_fact_date_from, 'dd-mm') || ' - ' ||
                                  to_char(par_epg_fact_date_to, 'dd-mm');
    c_message     VARCHAR2(2000) := '��������� �������!

���������� ��� ��������� �������� ������� �� ��������� ��������
������ ������� ������ ���������� � ������� �� ��������� �� ' ||
                                    to_char(SYSDATE - 1, 'dd.mm.yyyy') || '.
������ ����� �������� ���������� �� �������� ��������� �������� �� ������ � ' ||
                                    to_char(par_epg_plan_date_from, 'dd.mm.yyyy') || ' �� ' ||
                                    to_char(par_epg_plan_date_to, 'dd.mm.yyyy') ||
                                    ', ������� ������ ���� �������� � ��������� ������.
������ ����� ���������� �������� � ���, ����� ������� �� ������ � ' ||
                                    to_char(par_epg_fact_date_from, 'dd.mm.yyyy') || ' �� ' ||
                                    to_char(par_epg_fact_date_to, 'dd.mm.yyyy') || ' ���� �������� � ������ �� ��� ���� ���������� � ������.
������������ �������� ������ ��� ����� ������ ��������. �� ��������, � ������� ��� ����� ����� � ������� ��������� ���, �� ���� ��� ������������ ������� � ��������, ������ ��� �������� ������.
���������� ��������� �������� �� ������ �������� �����������, ���� ������ ��� �� ������� ������ �� ����� �������, �� ��� ����������� ���� ��������, ����� ������� �� ����� � ������ �� �����������.
���� ������ ��������  ��� ���� ������������, �� �� ��� � ������, ����� ������ ��������� �������, �������� � ��, � ������ ����������� ����� ������.

������ ������ ������� ������������� �������� BI. ������ ��� �� �������� �� �����, � �������� ���� ���������� ������ ������.
';
  
  BEGIN
    -- ���������� ������
    DELETE FROM tmp_ag_nonpayment;
  
    prepare_data(par_pol_date_from  => par_pol_plan_date_from
                ,par_pol_date_to    => par_pol_plan_date_to
                ,par_epg_date_from  => par_epg_plan_date_from
                ,par_epg_date_to    => par_epg_plan_date_to
                ,par_plan_fact_flag => 'P');
    prepare_data(par_pol_date_from  => par_pol_fact_date_from
                ,par_pol_date_to    => par_pol_fact_date_to
                ,par_epg_date_from  => par_epg_fact_date_from
                ,par_epg_date_to    => par_epg_fact_date_to
                ,par_plan_fact_flag => 'F');
    -- �������� ������� ������ ��������������� ����
    v_files.extend(2);
    v_files(1).v_file_type := 'application/excel';
    dbms_lob.createtemporary(lob_loc => v_files(1).v_file, cache => TRUE);
    v_files(2).v_file_type := 'application/excel';
    dbms_lob.createtemporary(lob_loc => v_files(2).v_file, cache => TRUE);
  
    make_file(par_plan_fact => 'P', par_file => v_files(1).v_file);
  
    v_files(1).v_file_name := '����_' || c_plan_period || gc_file_ext;
  
    make_file(par_plan_fact => 'F', par_file => v_files(2).v_file);
  
    v_files(2).v_file_name := '����_' || c_fact_period || gc_file_ext;
  
    pkg_email.send_mail_with_attachment(par_to            => pkg_email.t_recipients(par_control_email)
                                       ,par_subject       => '����� �� ���������'
                                       ,par_text          => c_message
                                       ,par_attachment    => v_files
                                       ,par_ignore_errors => TRUE);
    -- �������� ����� ����������
    FOR vr_dir IN (SELECT DISTINCT dp.contact_id
                                  ,dp.email
                                  ,tmp.agency
                     FROM (SELECT co.contact_id
                                 ,ce.email
                                 ,dp.name
                             FROM department dp
                                 ,ag_contract cn
                                 ,ag_contract_header ch
                                 ,contact co
                                 ,ag_category_agent ca
                                 ,document dc
                                 ,doc_status_ref dsr
                                 ,(SELECT ce.contact_id
                                         ,ce.email
                                     FROM cn_contact_email ce
                                         ,t_email_type     et
                                    WHERE ce.email_type = et.id
                                      AND ce.status = 1
                                      AND et.description = '�������') ce
                            WHERE dp.department_id = cn.agency_id
                              AND SYSDATE BETWEEN cn.date_begin AND cn.date_end
                              AND cn.category_id = ca.ag_category_agent_id
                              AND cn.contract_id = dc.document_id
                              AND dc.doc_status_ref_id = dsr.doc_status_ref_id
                              AND dsr.brief = 'CURRENT'
                              AND cn.contract_id = ch.ag_contract_header_id
                              AND ch.is_new = 1
                              AND ca.brief IN ('DR', 'DR2')
                              AND ch.agent_id = co.contact_id
                              AND co.contact_id = ce.contact_id(+)) dp
                         ,tmp_ag_nonpayment tmp
                    WHERE tmp.agency = dp.name(+)
                   -------------------------
                   -- and dp.name in ('����������')
                   -------------------------
                   )
    LOOP
      IF vr_dir.email IS NOT NULL
      THEN
        make_file(par_agency => vr_dir.agency, par_plan_fact => 'P', par_file => v_files(1).v_file);
      
        v_files(1).v_file_name := REPLACE(vr_dir.agency, '"') || '_����_' || c_plan_period ||
                                  gc_file_ext;
      
        make_file(par_agency => vr_dir.agency, par_plan_fact => 'F', par_file => v_files(2).v_file);
      
        v_files(2).v_file_name := REPLACE(vr_dir.agency, '"') || '_����_' || c_fact_period ||
                                  gc_file_ext;
      
        pkg_email.send_mail_with_attachment(par_to            => pkg_email.t_recipients(vr_dir.email)
                                           ,par_subject       => '����� �� ���������'
                                           ,par_text          => c_message
                                           ,par_attachment    => v_files
                                           ,par_ignore_errors => TRUE);
      END IF;
      -- �������� ����� ����������
      FOR vr_mn IN (SELECT DISTINCT tmp.leader_contact_id
                                   ,tmp.agent_leader
                                   ,ce.email
                                   ,tmp.agency
                      FROM tmp_ag_nonpayment tmp
                          ,cn_contact_email  ce
                          ,t_email_type      et
                     WHERE tmp.leader_contact_id = ce.contact_id
                       AND ce.email_type = et.id
                       AND ce.status = 1
                       AND et.description(+) = '�������'
                       AND tmp.agency = vr_dir.agency)
      LOOP
        make_file(par_mn_contact_id => vr_mn.leader_contact_id
                 ,par_plan_fact     => 'P'
                 ,par_file          => v_files(1).v_file);
        v_files(1).v_file_name := vr_mn.agent_leader || '_����_' || c_plan_period || gc_file_ext;
      
        make_file(par_mn_contact_id => vr_mn.leader_contact_id
                 ,par_plan_fact     => 'F'
                 ,par_file          => v_files(2).v_file);
        v_files(2).v_file_name := vr_mn.agent_leader || '_����_' || c_fact_period || gc_file_ext;
      
        pkg_email.send_mail_with_attachment(par_to            => pkg_email.t_recipients(vr_mn.email)
                                           ,par_cc            => CASE
                                                                   WHEN vr_dir.email IS NOT NULL THEN
                                                                    pkg_email.t_recipients(vr_dir.email)
                                                                 END
                                           ,par_subject       => '����� �� ���������'
                                           ,par_text          => c_message
                                           ,par_attachment    => v_files
                                           ,par_ignore_errors => TRUE);
      END LOOP vr_mn;
    END LOOP vr_dir;
  
    dbms_lob.freetemporary(v_files(1).v_file);
    dbms_lob.freetemporary(v_files(2).v_file);
  END send_mail;

  /*
    ������ �.
    ���������� ��������� ������� ������� ��� ������:
    DWH_����� � ���������_������ ������_2011, ���� - ����������� ������� �� ��������� ������
  */
  PROCEDURE prepare_data_01
  (
    par_epg_grace_date_from DATE -- ���� ������� "��"
   ,par_epg_grace_date_to   DATE -- ���� ������� "��"
  ) IS
  BEGIN
    INSERT INTO tmp_ag_nonpayment
      (c_3
      ,c_2
      ,c_1
      ,sales_channel
      ,insurer
      ,pol_num
      ,prod_desc
      ,start_date
      ,epg_status
      ,pay_term
      ,agency
      ,AGENT
      ,agent_leader
      ,ids
      ,tel_home
      ,tel_pers
      ,tel_work
      ,tel_mobil
      ,tel_cont
      ,agent_contact_id
      ,leader_contact_id
      ,epg_sum
      ,epg_date
      ,coll_method
      ,epg_grace_date)
      SELECT c_3
            ,to_char(c_2)
            ,to_char(c_1)
            ,sales_channel
            ,insurer
            ,pol_num
            ,prod_desc
            ,to_char(start_date, 'dd.mm.yyyy')
            ,epg_status
            ,pay_term
            ,agency
            ,AGENT
            ,agent_leader
            ,ids
            ,tel_home
            ,tel_pers
            ,tel_work
            ,tel_mobil
            ,tel_cont
            ,agent_contact_id
            ,leader_contact_id
            ,to_char(epg_sum)
            ,to_char(epg_date, 'dd.mm.yyyy')
            ,coll_method
            ,to_char(epg_grace_date, 'dd.mm.yyyy')
        FROM (SELECT /*+ NOREWRITE */
               CASE
                 WHEN epg."������� 1��� ���" = 1 THEN
                  ' ���������� ��������� (������ ������)'
                 ELSE
                  CASE
                    WHEN epg."���� ���" - ph.start_date < 365 THEN
                     '��������� ������� 1 ����'
                    ELSE
                     '��������� ������� 2 � ����������� ����'
                  END
               END AS c_3 --��� �������
               ,(SUM(epg."����� ��� �")) - (CASE
                 WHEN (SUM(epg."��������� �� ��� ����� �")) IS NULL THEN
                  0
                 ELSE
                  (SUM(epg."��������� �� ��� ����� �"))
               END) AS c_2 --�������������
               ,CASE
                 WHEN (SUM(epg."��������� �� ��� ����� �")) IS NULL THEN
                  0
                 ELSE
                  (SUM(epg."��������� �� ��� ����� �"))
               END AS c_1 --��������
               ,sc.description AS sales_channel
               ,ph.insurer
               ,ph.pol_num
               ,ph.prod_desc
               ,ph.start_date
               ,epg."������ ���" AS epg_status
               ,ph.pay_term
               ,ph.agency
               ,ph.agent
               ,ph.agent_leader
               ,ph.ids
               ,co.tel_home
               ,co.tel_pers
               ,co.tel_work
               ,co.tel_mobil
               ,co.tel_cont
               ,SUM(epg."����� ��� �") AS epg_sum
               ,epg."���� ���" AS epg_date
               ,ph.coll_method
               ,epg."���� �������" AS epg_grace_date
               ,cha.agent_id AS agent_contact_id
               ,chm.agent_id AS leader_contact_id
                FROM ins_dwh.dm_contact         co
                    ,ins_dwh.dm_p_pol_header    ph
                    ,ins_dwh.dm_t_sales_channel sc
                    ,ins_dwh.fc_egp             epg
                    ,ins.ag_contract_header     cha
                    ,ins.ag_contract            cna
                    ,ins.ag_contract            cnm
                    ,ins.ag_contract_header     chm
              
               WHERE ph.policy_header_id = epg."ID �������� �����������"
                 AND ph.agent_header_id = cha.ag_contract_header_id
                 AND cha.last_ver_id = cna.ag_contract_id
                 AND cna.contract_leader_id = cnm.ag_contract_id(+)
                 AND cnm.contract_id = chm.ag_contract_header_id(+)
                    
                 AND sc.id = ph.sales_channel_id
                 AND ph.insurer_contact_id = co.contact_id
                 AND ((CASE
                       WHEN epg."���� ���" = ph.min_to_pay_date THEN
                        NULL
                       ELSE
                        '��������� � ������ ����� �������������!'
                     END) IS NULL)
                 AND ((CASE
                       WHEN ph.last_ver_stat NOT IN ('�����������'
                                                    ,'������� ��������'
                                                    ,'����������') THEN
                        '��������� ������ ��'
                       ELSE
                        NULL
                     END) IS NULL)
                    
                 AND upper(ph.prod_desc) NOT LIKE upper('%cr%')
                 AND upper(sc.description) NOT IN
                     (upper('����������'), upper('�������������'))
                 AND ph.last_ver_stat NOT IN ('����������'
                                             ,'��������'
                                             ,'�������'
                                             ,'�������������'
                                             ,'��������� � �����������'
                                             ,'��������� �� �����������'
                                             ,'� �����������'
                                             ,'� �����������. ����� ��� ��������'
                                             ,'� �����������. ��������'
                                             ,'���������. ������ ����������'
                                             ,'���������. ��������� ��������'
                                             ,'���������.� �������'
                                             ,'���������')
                 AND epg."���� �������" BETWEEN par_epg_grace_date_from AND par_epg_grace_date_to
                 AND epg."������ ���" != '�������'
                 AND epg."������ ���" != '�����������'
                 AND ph.is_group_flag = 0
              
               GROUP BY CASE
                          WHEN epg."������� 1��� ���" = 1 THEN
                           ' ���������� ��������� (������ ������)'
                          ELSE
                           CASE
                             WHEN epg."���� ���" - ph.start_date < 365 THEN
                              '��������� ������� 1 ����'
                             ELSE
                              '��������� ������� 2 � ����������� ����'
                           END
                        END
                        ,sc.description
                        ,insurer
                        ,pol_num
                        ,prod_desc
                        ,start_date
                        ,epg."���� ���"
                        ,epg."������ ���"
                        ,pay_term
                        ,agency
                        ,AGENT
                        ,agent_leader
                        ,coll_method
                        ,ids
                        ,tel_home
                        ,tel_pers
                        ,tel_work
                        ,tel_mobil
                        ,tel_cont
                        ,epg."���� �������"
                        ,cha.agent_id
                        ,chm.agent_id
              HAVING((SUM(epg."����� ��� �")) != 0));
  
  END prepare_data_01;

  /*
    ������ �.
    ���������� ���������� � ������ �� ������ ������
    DWH_����� � ���������_������ ������_2011, ���� - ����������� ������� �� ��������� ������
  */
  PROCEDURE make_file_01
  (
    par_ag_contact_id NUMBER DEFAULT NULL
   ,par_mn_contact_id NUMBER DEFAULT NULL
   ,par_agency        VARCHAR2 DEFAULT NULL
   ,par_file          IN OUT NOCOPY BLOB
  ) IS
    CURSOR cur_send_data
    (
      par_ag_contact_id NUMBER
     ,par_mn_contact_id NUMBER
     ,par_agency        VARCHAR2
    ) IS
      SELECT c_3
            ,c_2
            ,c_1
            ,sales_channel
            ,insurer
            ,pol_num
            ,prod_desc
            ,start_date
            ,epg_status
            ,pay_term
            ,agency
            ,AGENT
            ,agent_leader
            ,ids
            ,tel_home
            ,tel_pers
            ,tel_work
            ,tel_mobil
            ,tel_cont
            ,agent_contact_id
            ,leader_contact_id
            ,epg_sum
            ,epg_date
            ,coll_method
            ,epg_grace_date
        FROM tmp_ag_nonpayment tmp
       WHERE ((par_ag_contact_id IS NOT NULL AND tmp.agent_contact_id = par_ag_contact_id) OR
             (par_mn_contact_id IS NOT NULL AND tmp.leader_contact_id = par_mn_contact_id) OR
             (par_agency IS NOT NULL AND tmp.agency = par_agency) OR
             (par_agency IS NULL AND par_ag_contact_id IS NULL AND par_mn_contact_id IS NULL))
       ORDER BY tmp.agent_leader
               ,tmp.agent
               ,tmp.insurer;
    v_data_row cur_send_data%ROWTYPE;
    v_row      VARCHAR2(2500);
    v_row_raw  RAW(2500);
  BEGIN
    dbms_lob.trim(lob_loc => par_file, newlen => 0);
    -- ����� ���������
    v_row_raw := utl_raw.cast_to_raw('������������ ������' || chr(9) --1
                                     || '�����' || chr(9) -- 2
                                     || '��� ������������' || chr(9) -- 3
                                     || '���. ���.' || chr(9) -- 4
                                     || '����. ���.' || chr(9) -- 5
                                     || '���. ���.' || chr(9) -- 6
                                     || '���. ���.' || chr(9) -- 7
                                     || '����. ���.' || chr(9) -- 8
                                     || '�������' || chr(9) -- 9
                                     || '����� ��' || chr(9) -- 10
                                     || '������������� ��' || chr(9) -- 11
                                     || '���� ������ ��' || chr(9) -- 12
                                     || '���� �������' || chr(9) --13
                                     || '���� �������' || chr(9) --14
                                     
                                     || '������������� ������' || chr(9) -- 15
                                     || '��� �������' || chr(9) -- 16
                                     || '����� �������, ���.' || chr(9) -- 17
                                     || '��������, ���.' || chr(9) -- 18
                                     || '�������������' || chr(9) -- 19
                                     
                                     || '������ ������� � �������' || chr(9) -- 20
                                     || '��� ��������' || chr(9) -- 21
                                     || '����. ������ ������' || chr(9) -- 22
                                     || utl_tcp.crlf);
    dbms_lob.writeappend(lob_loc => par_file
                        ,amount  => utl_raw.length(v_row_raw)
                        ,buffer  => v_row_raw);
    -- ��������� ������ �����
    OPEN cur_send_data(par_ag_contact_id => par_ag_contact_id
                      ,par_mn_contact_id => par_mn_contact_id
                      ,par_agency        => par_agency);
    LOOP
      FETCH cur_send_data
        INTO v_data_row;
      EXIT WHEN cur_send_data%NOTFOUND;
      v_row     := v_data_row.agent_leader || chr(9) -- 1
                   || v_data_row.agent || chr(9) -- 2
                   || v_data_row.insurer || chr(9) -- 3
                   || v_data_row.tel_home || chr(9) -- 4
                   || v_data_row.tel_pers || chr(9) -- 5
                   || v_data_row.tel_work || chr(9) -- 6
                   || v_data_row.tel_mobil || chr(9) -- 7
                   || v_data_row.tel_cont || chr(9) -- 8
                   || v_data_row.prod_desc || chr(9) -- 9
                   || v_data_row.pol_num || chr(9) -- 10
                   || v_data_row.ids || chr(9) -- 11
                   || v_data_row.start_date || chr(9) -- 12
                   || v_data_row.epg_date || chr(9) -- 13
                   || v_data_row.epg_grace_date || chr(9) -- 14
                  
                   || v_data_row.pay_term || chr(9) -- 15
                   || v_data_row.c_3 || chr(9) -- 16
                   || v_data_row.epg_sum || chr(9) -- 17
                   || v_data_row.c_1 || chr(9) -- 18
                   || v_data_row.c_2 || chr(9) -- 19
                   || v_data_row.epg_status || chr(9) -- 20
                   || v_data_row.coll_method || chr(9) -- 21
                  
                   || v_data_row.sales_channel -- 22
                   || utl_tcp.crlf;
      v_row_raw := utl_raw.cast_to_raw(v_row);
      dbms_lob.writeappend(lob_loc => par_file
                          ,amount  => utl_raw.length(v_row_raw)
                          ,buffer  => v_row_raw);
    END LOOP;
    CLOSE cur_send_data;
  END make_file_01;

  /*
    ������ �.
    ������� ����� � ��������� ������� �� ������ ������
    DWH_����� � ���������_������ ������_2011, ���� - ����������� ������� �� ��������� ������
  */
  PROCEDURE send_mail_01
  (
    par_epg_grace_date_from DATE -- ���� ������� "��"
   ,par_epg_grace_date_to   DATE -- ���� ������� "��"
    
   ,par_control_email         VARCHAR2 -- ����� ��� �������� ������� ������
   ,par_content_email         VARCHAR2 := NULL -- �������������� ����� � ������
   ,par_to_only_control_email NUMBER -- ��������, ������������� � AG_NONPAYMENT.FMB, ����������� �������� ������ ������ ������ ���������� e-mail ��� ���� (1 ��� 0 ��������������)   
  ) IS
    v_is_test     VARCHAR2(10) := NULL; -- ��� �������� ����� � �������� "... ����!" � ������ �������� ��������
    v_files       pkg_email.t_files := pkg_email.t_files();
    v_log_files   pkg_email.t_files := pkg_email.t_files(); --/������/181084: ������������ ������� �������� ������ �� ���������                           
    c_plan_period VARCHAR2(15) := to_char(SYSDATE, 'dd.mm.yyyy');
    v_message     VARCHAR2(4000) := '��������� �������!

����� ������������ � ������� ������������ ������� �� ��������� ������
, � ������� �������� �������� �����������, � ���������� ������ ������� � ' ||
                                    to_char(par_epg_grace_date_from, 'dd.mm.yyyy') || ' �� ' ||
                                    to_char(par_epg_grace_date_to, 'dd.mm.yyyy') || ' .
�� ���� ��������� ����������� �� ��������� �� ' ||
                                    to_char(SYSDATE, 'dd.mm.yyyy') ||
                                    ' ������ �� ��������� � �������� ��� �� �� ������ ����������.

������ ������ ������� ������������� �������� BI. ������ ��� �� �������� �� �����, � �������� ���� ���������� ������ ������.'
    -- ������ �.
    -- ������ 193379
    /*|| chr(10) || par_content_email*/
     ;
  
  BEGIN
     IF ins.is_test_server = 1
    THEN
      v_is_test := ' ����!';
    END IF;
    -- ������ �.
    -- ������ 193379
    IF par_content_email IS NOT NULL
    THEN
      IF length(par_content_email) > 2000
      THEN
        raise_application_error(-20000
                               ,'�������������� ����� � ������ �� ������ ��������� 2000 ��������!');
      ELSE
        v_message := v_message || chr(10) || par_content_email;
      END IF;
    END IF;
  
    -- ���������� ������
    DELETE FROM tmp_ag_nonpayment;
  
    prepare_data_01(par_epg_grace_date_from => par_epg_grace_date_from
                   ,par_epg_grace_date_to   => par_epg_grace_date_to);
  
    --�������������� ���� ����-------------------------
    --��������� ����� ��� ����� �����
    --/������/181084: ������������ ������� �������� ������ �� ���������                        
    init_rep_email_sended(v_log_files);
    ---------------------------------------------------
  
    -- �������� ������� ������ ��������������� ����
    v_files.extend(1);
    v_files(1).v_file_type := 'application/excel';
    dbms_lob.createtemporary(lob_loc => v_files(1).v_file, cache => TRUE);
  
    make_file_01(par_file => v_files(1).v_file);
  
    v_files(1).v_file_name := c_plan_period || gc_file_ext;
  
    pkg_email.send_mail_with_attachment(par_to            => pkg_email.t_recipients(par_control_email)
                                       ,par_subject       => '����� ����������� �������' || v_is_test
                                       ,par_text          => v_message
                                       ,par_attachment    => v_files
                                       ,par_ignore_errors => TRUE);
  
    IF par_to_only_control_email = 0
    THEN
    
      -- �������� ����� ����������
      FOR vr_dir IN (SELECT DISTINCT dp.contact_id
                                    ,contact_name
                                    ,dp.email
                                    ,tmp.agency
                       FROM (SELECT co.contact_id
                                   ,co.obj_name_orig AS contact_name
                                   ,ce.email
                                   ,dp.name
                               FROM department dp
                                   ,ag_contract cn
                                   ,ag_contract_header ch
                                   ,contact co
                                   ,ag_category_agent ca
                                   ,document dc
                                   ,doc_status_ref dsr
                                   ,(SELECT ce.contact_id
                                           ,ce.email
                                       FROM cn_contact_email ce
                                           ,t_email_type     et
                                      WHERE ce.email_type = et.id
                                        AND ce.status = 1
                                        AND et.description = '�������') ce
                              WHERE dp.department_id = cn.agency_id
                                AND SYSDATE BETWEEN cn.date_begin AND cn.date_end
                                AND cn.category_id = ca.ag_category_agent_id
                                AND cn.contract_id = dc.document_id
                                AND dc.doc_status_ref_id = dsr.doc_status_ref_id
                                AND dsr.brief = 'CURRENT'
                                AND cn.contract_id = ch.ag_contract_header_id
                                AND ch.is_new = 1
                                AND ca.brief IN ('DR', 'DR2')
                                AND ch.agent_id = co.contact_id
                                AND co.contact_id = ce.contact_id(+)) dp
                           ,tmp_ag_nonpayment tmp
                      WHERE tmp.agency = dp.name(+)
                     -------------------------
                     --   and dp.name in ('����������')
                     -------------------------
                     )
      LOOP
        IF vr_dir.email IS NOT NULL
        THEN
          make_file_01(par_agency => vr_dir.agency, par_file => v_files(1).v_file);
        
          v_files(1).v_file_name := REPLACE(vr_dir.agency, '"') || '_' || c_plan_period || gc_file_ext;
        
          pkg_email.send_mail_with_attachment(par_to            => pkg_email.t_recipients(vr_dir.email)
                                             ,par_subject       => '����� ����������� �������' ||
                                                                   v_is_test
                                             ,par_text          => v_message
                                             ,par_attachment    => v_files
                                             ,par_ignore_errors => TRUE);
        
          --������� ������ �� ������������ ������� � �����  
          --/������/181084: ������������ ������� �������� ������ �� ���������                          
          add_rep_email_sended(par_rep_name  => '����� ����������� �������'
                              ,par_rep_type  => '����� ���������'
                              ,par_agency    => vr_dir.agency
                              ,par_name_to   => vr_dir.contact_name
                              ,par_email_to  => vr_dir.email
                              ,par_name_cc   => NULL
                              ,par_email_cc  => NULL
                              ,par_name_cc2  => NULL
                              ,par_email_cc2 => NULL
                              ,par_file      => v_log_files(1).v_file); ----------------------------------------------------                                             
        END IF;
        -- �������� ����� ����������
        FOR vr_mn IN (SELECT DISTINCT tmp.leader_contact_id
                                     ,tmp.agent_leader
                                     ,c.obj_name_orig AS contact_name
                                     ,ce.email
                                     ,tmp.agency
                        FROM tmp_ag_nonpayment tmp
                            ,cn_contact_email  ce
                            ,t_email_type      et
                            ,ins.contact       c
                       WHERE tmp.leader_contact_id = ce.contact_id
                         AND ce.email_type = et.id
                         AND ce.status = 1
                         AND ce.contact_id = c.contact_id
                         AND et.description(+) = '�������'
                         AND tmp.agency = vr_dir.agency)
        LOOP
          make_file_01(par_mn_contact_id => vr_mn.leader_contact_id, par_file => v_files(1).v_file);
          v_files(1).v_file_name := vr_mn.agent_leader || '_' || c_plan_period || gc_file_ext;
        
          pkg_email.send_mail_with_attachment(par_to            => pkg_email.t_recipients(vr_mn.email)
                                             ,par_cc            => CASE
                                                                     WHEN vr_dir.email IS NOT NULL THEN
                                                                      pkg_email.t_recipients(vr_dir.email)
                                                                   END
                                             ,par_subject       => '����� ����������� �������' || v_is_test
                                             ,par_text          => v_message
                                             ,par_attachment    => v_files
                                             ,par_ignore_errors => TRUE);
        
          --������� ������ �� ������������ ������� � �����  
          --/������/181084: ������������ ������� �������� ������ �� ���������                          
          add_rep_email_sended(par_rep_name  => '����� ����������� �������'
                              ,par_rep_type  => '����� ���������'
                              ,par_agency    => vr_mn.agency
                              ,par_name_to   => vr_mn.contact_name
                              ,par_email_to  => vr_mn.email
                              ,par_name_cc   => NULL
                              ,par_email_cc  => NULL
                              ,par_name_cc2  => NULL
                              ,par_email_cc2 => NULL
                              ,par_file      => v_log_files(1).v_file); ----------------------------------------------------                                           
        END LOOP vr_mn;
      END LOOP vr_dir;
    
    END IF;
  
    dbms_lob.freetemporary(v_log_files(1).v_file);
    dbms_lob.freetemporary(v_files(1).v_file);
  END send_mail_01;

  /*
    ������ �.
    ���������� ��������� ������� ������� ��� ������:
    DWH_����� � ���������+�����������_��� ��������, ���� - �����������
  */
  PROCEDURE prepare_data_02
  (
    par_pol_date_from  DATE -- ���� ������ �� "��"
   ,par_pol_date_to    DATE -- ���� ������ �� "��"
   ,par_epg_date_from  DATE -- ���� ������� "��"
   ,par_epg_date_to    DATE -- ���� ������� "��"
   ,par_plan_fact_flag VARCHAR2 -- ����/����
    --,par_pol_status     varchar2  := null -- ������ ��������� ������
    --,par_pol_term       varchar2  := null -- �������������
    --,par_agency         varchar2  := null -- ��������
  ) IS
    v_products_for_prolong tt_one_col := tt_one_col('������ APG'
                                                   ,'��� +'
                                                   ,'��� + (New)'
                                                   ,'��� + 2'
                                                   ,'������'
                                                   ,'������ 163'
                                                   ,'��� + (New) 2014');
  BEGIN
    INSERT INTO tmp_ag_nonpayment
      (c_6
      ,c_2
      ,c_1
      ,c_4
      ,c_5
      ,sales_channel
      ,insurer
      ,pol_num
      ,prod_desc
      ,start_date
      ,pol_status
      ,pay_term
      ,agency
      ,AGENT
      ,agent_leader
      ,ids
      ,tel_home
      ,tel_pers
      ,tel_work
      ,tel_mobil
      ,tel_cont
      ,epg_sum
      ,c_3
      ,agent_contact_id
      ,leader_contact_id
      ,plan_fact
      ,index_fee)
    
      SELECT c_6
            ,c_2
            ,c_1
            ,c_4
            ,c_5
            ,sales_channel
            ,insurer
            ,pol_num
            ,prod_desc
            ,start_date
            ,pol_status
            ,pay_term
            ,agency
            ,AGENT
            ,agent_leader
            ,ids
            ,tel_home
            ,tel_pers
            ,tel_work
            ,tel_mobil
            ,tel_cont
            ,to_char(SUM("����� ��� �")) epg_sum
             ,to_char(CASE
                       WHEN prod_desc IN (SELECT column_value FROM TABLE(v_products_for_prolong))
                            AND start_date + 366 BETWEEN par_epg_date_from AND par_epg_date_to THEN
                        0
                       ELSE
                        SUM("��������� �� ��� ����� �")
                     END) AS c_3
             ,agent_contact_id
             ,leader_contact_id
             ,par_plan_fact_flag
             -- ������ �.
             -- ������ 191170
             ,to_char(ROUND(SUM(index_fee_prop), 2)) AS index_fee
        FROM (SELECT CASE
                       WHEN ph.prod_desc IN (SELECT column_value FROM TABLE(v_products_for_prolong))
                            AND ph.start_date + 366 BETWEEN par_epg_date_from AND par_epg_date_to THEN
                        '�����������'
                     -- ������ �.
                     -- ������ 191170
                       WHEN to_char(ph.start_date, 'ddmm') = to_char(epg."���� ���", 'ddmm') THEN
                        '���������'
                       ELSE
                        NULL
                     END AS c_6
                     
                     ,CASE
                       WHEN
                       -- 336836
                        (ph.prod_desc = '������ 163' AND ph.pay_term = '�������������' AND
                        --���� ����� 15 ������ ��� ������ � 14 ������ ���� ������
                        trunc(ph.end_date) BETWEEN trunc(SYSDATE, 'mm') + 14 AND
                        trunc(ADD_MONTHS(SYSDATE, 1), 'mm') + 13) --end 336836  THEN 
                        THEN
                        '�����������' --336836/������
                       WHEN epg."���� ���" BETWEEN par_epg_date_from AND par_epg_date_to
                            AND epg."������� 1��� ���" = 1 THEN
                        ' ���������� ��������� (������ ������)'
                       WHEN epg."���� ���" BETWEEN par_epg_date_from AND par_epg_date_to
                            AND epg."���� ���" - ph.start_date < 365 THEN
                        '��������� ������� 1 ����'
                       WHEN epg."���� ���" BETWEEN par_epg_date_from AND par_epg_date_to
                            AND epg."���� ���" - ph.start_date >= 365 THEN
                        '��������� ������� 2 � ����������� ����'
                       ELSE
                        '�����������'
                     END AS c_2
                     
                     ,CASE
                       WHEN epg."��� ��������" = '����������� ������' THEN
                        '������ ����� ����'
                       ELSE
                        epg."��� ��������"
                     END AS c_1
                     
                     ,CASE
                       WHEN epg."������ ���" = '�����������' THEN
                        '�����������'
                       WHEN ph.prod_desc IN (SELECT column_value FROM TABLE(v_products_for_prolong))
                            AND ph.start_date + 366 BETWEEN par_epg_date_from AND par_epg_date_to THEN
                        '� ������'
                       ELSE
                        epg."������ ���"
                     END AS c_4
                     
                     ,CASE
                       WHEN ph.prod_desc IN (SELECT column_value FROM TABLE(v_products_for_prolong))
                            AND ph.start_date + 366 BETWEEN par_epg_date_from AND par_epg_date_to
                            AND ph.pay_term = '����������' THEN
                        ADD_MONTHS(epg."���� ���", 1)
                       WHEN ph.prod_desc IN (SELECT column_value FROM TABLE(v_products_for_prolong))
                            AND ph.start_date + 366 BETWEEN par_epg_date_from AND par_epg_date_to
                            AND ph.pay_term = '�������������' THEN
                        ADD_MONTHS(epg."���� ���", 12)
                       ELSE
                        epg."���� ���"
                     END AS c_5
                     ,
                     
                     sc.description                                     AS sales_channel
                     ,ph.insurer                                         AS insurer
                     ,ph.pol_num                                         AS pol_num
                     ,ph.prod_desc                                       AS prod_desc
                     ,ph.start_date                                      AS start_date
                     ,ph.status                                          AS pol_status
                     ,ph.pay_term                                        AS pay_term
                     ,ph.agency                                          AS agency
                     ,ph.agent                                           AS AGENT
                     ,ph.agent_leader                                    AS agent_leader
                     ,ph.ids                                             AS ids
                     ,co.tel_home                                        AS tel_home
                     ,co.tel_pers                                        AS tel_pers
                     ,co.tel_work                                        AS tel_work
                     ,co.tel_mobil                                       AS tel_mobil
                     ,co.tel_cont                                        AS tel_cont
                     ,epg."����� ��� �"
                     ,epg."��������� �� ��� ����� �"
                     ,cha.agent_id                                       AS agent_contact_id
                     ,chm.agent_id                                       AS leader_contact_id
                     ,epg.index_fee_prop -- ������ �. ������ 191170
                FROM ins_dwh.dm_contact         co
                    ,ins_dwh.dm_p_pol_header    ph
                    ,ins_dwh.dm_t_sales_channel sc
                    ,ins_dwh.fc_egp             epg
                    ,ins.ag_contract_header     cha
                    ,ins.ag_contract            cna
                    ,ins.ag_contract            cnm
                    ,ins.ag_contract_header     chm
               WHERE ph.policy_header_id = epg."ID �������� �����������"
                 AND ph.agent_header_id = cha.ag_contract_header_id
                 AND cha.last_ver_id = cna.ag_contract_id
                 AND cna.contract_leader_id = cnm.ag_contract_id(+)
                 AND cnm.contract_id = chm.ag_contract_header_id(+)
                    --
                 AND sc.id = ph.sales_channel_id
                 AND ph.insurer_contact_id = co.contact_id
                 AND co.date_of_death IS NULL -- ������ �. ������ 191170
                 AND (epg."������ ���" != '�����������')
                    -- ������ �.
                    -- ������ �195746
                 AND EXISTS
               (SELECT NULL
                        FROM ins.p_pol_header pph
                            ,ins.as_asset     se
                            ,ins.as_assured   su
                            ,ins.cn_person    cp
                       WHERE pph.policy_header_id = ph.policy_header_id
                         AND pph.last_ver_id = se.p_policy_id
                         AND se.as_asset_id = su.as_assured_id
                         AND su.assured_contact_id = cp.contact_id
                         AND cp.date_of_death IS NULL)
                    --
                 AND ph.status NOT IN ('����������'
                                      ,'��������'
                                      ,'�������'
                                      ,'�������������'
                                      ,'��������� � �����������'
                                      ,'��������� �� �����������'
                                      ,'� �����������'
                                      ,'� �����������. ����� ��� ��������'
                                      ,'� �����������. ��������'
                                      ,'���������. ������ ����������'
                                      ,'���������. ��������� ��������'
                                      ,'���������.� �������'
                                      ,'���������'
                                      ,'����� � ��������������'
                                      ,'��������������')
                    --������� ��� ��������� ����� ������ 163
                 AND (( --�������
                      ((epg."���� ���" BETWEEN par_epg_date_from AND par_epg_date_to) OR
                      (ph.prod_desc IN (SELECT column_value FROM TABLE(v_products_for_prolong)) AND
                      ph.start_date + 366 BETWEEN par_epg_date_from AND par_epg_date_to)) AND
                     --����� ������
                      ((ph.pay_term = '����������' AND
                      (ADD_MONTHS(epg."���� ���", 1) BETWEEN par_epg_date_from AND par_epg_date_to)) OR
                      (ph.pay_term = '�������������' AND
                      (ADD_MONTHS(epg."���� ���", 12) BETWEEN par_epg_date_from AND par_epg_date_to)) OR
                      (epg."���� ���" BETWEEN par_epg_date_from AND par_epg_date_to))
                     --
                     )
                     --336836/������
                     --������� ��� ������ 163
                     OR (ph.prod_desc = '������ 163' AND ph.pay_term = '�������������' AND
                     --���� ����� 15 ������ ��� ������ � 14 ������ ���� ������
                     trunc(ph.end_date) BETWEEN trunc(SYSDATE, 'mm') + 14 AND
                     trunc(ADD_MONTHS(SYSDATE, 1), 'mm') + 13) --end 336836                                             
                     )
                    
                 AND upper(ph.agency) != upper('������� ������ � ���������')
                 AND upper(ph.prod_desc) NOT LIKE upper('%cr%')
                 AND upper(sc.description) NOT IN
                     (upper('����������'), upper('����������'))
                 AND ph.is_group_flag = 0
                 AND ph.start_date BETWEEN par_pol_date_from AND par_pol_date_to
              --AND ph.LAST_VER_STAT in (par_pol_status)
              --AND ph.PAY_TERM in (par_pol_term)
              --AND ph.AGENCY in (par_agency)                                    
              ) main
       GROUP BY c_6
               ,c_2
               ,c_1
               ,c_4
               ,c_5
               ,sales_channel
               ,insurer
               ,pol_num
               ,prod_desc
               ,start_date
               ,pol_status
               ,pay_term
               ,agency
               ,AGENT
               ,agent_leader
               ,ids
               ,tel_home
               ,tel_pers
               ,tel_work
               ,tel_mobil
               ,tel_cont
               ,agent_contact_id
               ,leader_contact_id
      HAVING(SUM("����� ��� �") != 0);
    -- ������ �. �������� ����������
    --ORDER BY AGENT_LEADER ASC, AGENT ASC, INSURER ASC;
  
  END prepare_data_02;

  /*
    ������ �.
    ���������� ���������� � ������ �� ������ ������
    DWH_����� � ���������+�����������_��� ��������, ���� - �����������
  */
  PROCEDURE make_file_02
  (
    par_ag_contact_id NUMBER DEFAULT NULL
   ,par_mn_contact_id NUMBER DEFAULT NULL
   ,par_agency        VARCHAR2 DEFAULT NULL
   ,par_plan_fact     VARCHAR2
   ,par_file          IN OUT NOCOPY BLOB
  ) IS
    CURSOR cur_send_data
    (
      par_ag_contact_id NUMBER
     ,par_mn_contact_id NUMBER
     ,par_agency        VARCHAR2
     ,par_plan_fact     VARCHAR2
    ) IS
      SELECT c_6
            ,c_2
            ,c_1
            ,c_4
            ,c_5
            ,sales_channel
            ,insurer
            ,pol_num
            ,prod_desc
            ,start_date
            ,pol_status
            ,pay_term
            ,agency
            ,AGENT
            ,agent_leader
            ,ids
            ,tel_home
            ,tel_pers
            ,tel_work
            ,tel_mobil
            ,tel_cont
            ,epg_sum
            ,c_3
            ,tmp.index_fee
        FROM tmp_ag_nonpayment tmp
       WHERE tmp.plan_fact = par_plan_fact
         AND ((par_ag_contact_id IS NOT NULL AND tmp.agent_contact_id = par_ag_contact_id) OR
             (par_mn_contact_id IS NOT NULL AND tmp.leader_contact_id = par_mn_contact_id) OR
             (par_agency IS NOT NULL AND tmp.agency = par_agency) OR
             (par_agency IS NULL AND par_ag_contact_id IS NULL AND par_mn_contact_id IS NULL))
       ORDER BY tmp.agent_leader
               ,tmp.agent
               ,tmp.insurer;
    v_data_row cur_send_data%ROWTYPE;
    v_row      VARCHAR2(2500);
    v_row_raw  RAW(2500);
  BEGIN
    dbms_lob.trim(lob_loc => par_file, newlen => 0);
    -- ����� ���������
    v_row_raw := utl_raw.cast_to_raw('���������' || chr(9) --1
                                     || '������������ ������' || chr(9) --2
                                     || '�����' || chr(9) --3
                                     || '��� ������������' || chr(9) --4
                                     || '���. ���' || chr(9) --5
                                     || '����. ���' || chr(9) --6
                                     || '���. ���' || chr(9) --7
                                     || '���. ���' || chr(9) --8                                  
                                     || '����. ���' || chr(9) --9
                                     || '�������' || chr(9) --10
                                     || '����� ��' || chr(9) --11
                                     || '������������� ��' || chr(9) --12
                                     || '���� ������ ��' || chr(9) --13
                                     || '������ ��������' || chr(9) --14
                                     || '������������� ������' || chr(9) --15
                                     || '��� �������' || chr(9) --16
                                     || '����� �������,  ���.' || chr(9) --17
                                     || '��������, ���.' || chr(9) --18
                                     || '������ ������� � �������' || chr(9) --19
                                     || '���� ������' || chr(9) --20
                                     || '��� ��������' || chr(9) --21
                                     -- ������ �. ������ 191170
                                     --||'������� �����������'||chr(9)         --22
                                     || '�������' || chr(9) --22
                                     || '���� ������ ������' || chr(9) --23
                                     || '��������������� ������-�����' --24
                                     || utl_tcp.crlf);
    dbms_lob.writeappend(lob_loc => par_file
                        ,amount  => utl_raw.length(v_row_raw)
                        ,buffer  => v_row_raw);
    -- ��������� ������ �����
    OPEN cur_send_data(par_ag_contact_id => par_ag_contact_id
                      ,par_mn_contact_id => par_mn_contact_id
                      ,par_agency        => par_agency
                      ,par_plan_fact     => par_plan_fact);
    LOOP
      FETCH cur_send_data
        INTO v_data_row;
      EXIT WHEN cur_send_data%NOTFOUND;
      v_row     := v_data_row.agency || chr(9) -- 1
                   || v_data_row.agent_leader || chr(9) -- 2            
                   || v_data_row.agent || chr(9) -- 3
                   || v_data_row.insurer || chr(9) -- 4
                   || v_data_row.tel_home || chr(9) -- 5
                   || v_data_row.tel_pers || chr(9) -- 6
                   || v_data_row.tel_work || chr(9) -- 7
                   || v_data_row.tel_mobil || chr(9) -- 8
                   || v_data_row.tel_cont || chr(9) -- 9
                   || v_data_row.prod_desc || chr(9) -- 10
                   || v_data_row.pol_num || chr(9) -- 11
                   || v_data_row.ids || chr(9) -- 12
                   || v_data_row.start_date || chr(9) -- 13      
                  
                   || v_data_row.pol_status || chr(9) -- 14
                   || v_data_row.pay_term || chr(9) -- 15
                   || v_data_row.c_2 || chr(9) -- 16
                   || v_data_row.epg_sum || chr(9) -- 17
                   || v_data_row.c_3 || chr(9) -- 18
                   || v_data_row.c_4 || chr(9) -- 19
                  
                   || v_data_row.c_5 || chr(9) -- 20
                   || v_data_row.c_1 || chr(9) -- 21
                   || v_data_row.c_6 || chr(9) -- 22           
                   || v_data_row.sales_channel || chr(9) -- 23
                   || v_data_row.index_fee
                  
                   || utl_tcp.crlf;
      v_row_raw := utl_raw.cast_to_raw(v_row);
      dbms_lob.writeappend(lob_loc => par_file
                          ,amount  => utl_raw.length(v_row_raw)
                          ,buffer  => v_row_raw);
    END LOOP;
    CLOSE cur_send_data;
  END make_file_02;

  /*
    ������ �.
    ������� ����� � ��������� ������� �� ������ ������
    DWH_����� � ���������+�����������_��� ��������, ���� - �����������
  */
  PROCEDURE send_mail_02
  --!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    --����� ������������� ���������� �������� ������ � ������ t_roo � cn_contact_email
    --UPDATE t_roo r SET r.corp_mail = 'vasiiy.chehovskoy@renlife.com';
    --UPDATE cn_contact_email e SET e.email = 'vasiiy.chehovskoy@renlife.com';
    --!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  (
    par_pol_plan_date_from DATE -- ���� ������ �� "��" (����)
   ,par_pol_plan_date_to   DATE -- ���� ������ �� "��" (����)
   ,par_epg_plan_date_from DATE -- ���� ������� "��" (����)
   ,par_epg_plan_date_to   DATE -- ���� ������� "��" (����)
   ,par_pol_fact_date_from DATE -- ���� ������ �� "��" (����)
   ,par_pol_fact_date_to   DATE -- ���� ������ �� "��" (����)
   ,par_epg_fact_date_from DATE -- ���� ������� "��" (����)
   ,par_epg_fact_date_to   DATE -- ���� ������� "��" (����)
    --,par_pol_status     varchar2  := null -- ������ ��������� ������
    --,par_pol_term       varchar2  := null -- �������������
    --,par_agency         varchar2  := null -- ��������
    
   ,par_control_email         pkg_email.t_recipients -- ����� ��� �������� ������� ������
   ,par_content_email         VARCHAR2 := NULL -- �������������� ����� � ������
   ,par_to_only_control_email NUMBER -- ��������, ������������� � AG_NONPAYMENT.FMB, ����������� �������� ������ ������ ������ ���������� e-mail ��� ���� (1 ��� 0 ��������������)
  ) IS
    v_is_test     VARCHAR2(10) := NULL; -- ��� �������� ����� � �������� "... ����!" � ������ �������� ��������
    v_files       pkg_email.t_files := pkg_email.t_files();
    v_log_files   pkg_email.t_files := pkg_email.t_files(); --/������/181084: ������������ ������� �������� ������ �� ���������
    v_recipients  pkg_email.t_recipients := pkg_email.t_recipients();
    c_plan_period VARCHAR2(15) := to_char(par_epg_plan_date_from, 'dd-mm') || ' - ' ||
                                  to_char(par_epg_plan_date_to, 'dd-mm');
    c_fact_period VARCHAR2(15) := to_char(par_epg_fact_date_from, 'dd-mm') || ' - ' ||
                                  to_char(par_epg_fact_date_to, 'dd-mm');
    v_message     VARCHAR2(4000) := '��������� �������!

���������� ��� ��������� �������� ������� �� ��������� �������� � �����������.
������ ������� ������ ���������� � ������� �� ��������� �� ' ||
                                    to_char(SYSDATE - 1, 'dd.mm.yyyy') || '.
������ ����� �������� ���������� �� �������� ��������� �������� �� ������ � ' ||
                                    to_char(par_epg_plan_date_from, 'dd.mm.yyyy') || ' �� ' ||
                                    to_char(par_epg_plan_date_to, 'dd.mm.yyyy') ||
                                    ', ������� ������ ���� �������� � ��������� ������.
� ����� ���������� � ���������, ������� ����� ���� �������������� � ��������� ������. ������ ����� ���������� �������� � ���, ����� ������� �� ������ � ' ||
                                    to_char(par_epg_fact_date_from, 'dd.mm.yyyy') || ' �� ' ||
                                    to_char(par_epg_fact_date_to, 'dd.mm.yyyy') ||
                                    ' ���� �������� � ������ �� ��� ���� ���������� � ������.
������������ �������� ������ ��� ����� ������ ��������. �� ��������, � ������� ��� ����� ����� � ������� ��������� ���, �� ���� ��� ������������ ������� � ��������, ������ ��� �������� ������.
���������� ��������� �������� �� ������ �������� �����������, ���� ������ ��� �� ������� ������ �� ����� �������, �� ��� ����������� ���� ��������, ����� ������� �� ����� � ������ �� �����������.
���� ������ ��������  ��� ���� ������������, �� �� ��� � ������, ����� ������ ��������� �������, �������� � ��, � ������ ����������� ����� ������.

������ ������ ������� ������������� �������� BI. ������ ��� �� �������� �� �����, � �������� ���� ���������� ������ ������.'
    -- ������ �.
    -- ������ 193379
    /*|| chr(10) || par_content_email*/
     ;
  
  BEGIN
    IF ins.is_test_server = 1
    THEN
      v_is_test := ' ����!';
    END IF;
  
    -- ������ �.
    -- ������ 193379
    IF par_content_email IS NOT NULL
    THEN
      IF length(par_content_email) > 2000
      THEN
        raise_application_error(-20000
                               ,'�������������� ����� � ������ �� ������ ��������� 2000 ��������!');
      ELSE
        v_message := v_message || chr(10) || par_content_email;
      END IF;
    END IF;
  
    -- ���������� ������
    DELETE FROM tmp_ag_nonpayment;
  
    prepare_data_02(par_pol_date_from  => par_pol_plan_date_from
                   ,par_pol_date_to    => par_pol_plan_date_to
                   ,par_epg_date_from  => par_epg_plan_date_from
                   ,par_epg_date_to    => par_epg_plan_date_to
                   ,par_plan_fact_flag => 'P');
    prepare_data_02(par_pol_date_from  => par_pol_fact_date_from
                   ,par_pol_date_to    => par_pol_fact_date_to
                   ,par_epg_date_from  => par_epg_fact_date_from
                   ,par_epg_date_to    => par_epg_fact_date_to
                   ,par_plan_fact_flag => 'F');
  
    --�������������� ���� ����-------------------------
    --/������/181084: ������������ ������� �������� ������ �� ���������
    init_rep_email_sended(v_log_files);
    ---------------------------------------------------
  
    -- �������� ������� ������ ��������������� ����
    v_files.extend(2);
    v_files(1).v_file_type := 'application/excel';
    dbms_lob.createtemporary(lob_loc => v_files(1).v_file, cache => TRUE);
    v_files(2).v_file_type := 'application/excel';
    dbms_lob.createtemporary(lob_loc => v_files(2).v_file, cache => TRUE);
  
    make_file_02(par_plan_fact => 'P', par_file => v_files(1).v_file);
  
    v_files(1).v_file_name := '����_' || c_plan_period || gc_file_ext;
  
    make_file_02(par_plan_fact => 'F', par_file => v_files(2).v_file);
  
    v_files(2).v_file_name := '����_' || c_fact_period || gc_file_ext;
  
    pkg_email.send_mail_with_attachment(par_to            => par_control_email
                                       ,par_subject       => '����� �� ��������� + �����������' ||
                                                             v_is_test
                                       ,par_text          => v_message
                                       ,par_attachment    => v_files
                                       ,par_ignore_errors => TRUE);
  
    IF par_to_only_control_email = 0
    THEN
      -- �������� ����� ����������
      FOR vr_dir IN (SELECT DISTINCT dp.contact_id
                                    ,dp.contact_name
                                    ,dp.email
                                    ,tmp.agency
                                    ,dp.lead_contact_id
                                    ,dp.lead_name
                                    ,dp.lead_email
                                    ,roo_name
                                    ,roo_email
                       FROM (SELECT co.contact_id
                                   ,co.obj_name_orig AS contact_name
                                   ,ce.email AS email
                                   ,dp.name AS NAME
                                   ,co_lead.contact_id AS lead_contact_id
                                   ,co_lead.obj_name_orig AS lead_name
                                   ,ce_lead.email AS lead_email
                                   ,(SELECT decode(COUNT(*), 1, MAX(ro_.roo_name), 0, NULL, NULL)
                                       FROM t_roo_header      rh_
                                           ,t_roo             ro_
                                           ,sales_dept_header sh_
                                           ,sales_dept        sd_
                                      WHERE sh_.organisation_tree_id = dp.org_tree_id
                                        AND sh_.last_sales_dept_id = sd_.sales_dept_id
                                        AND sd_.t_roo_header_id = rh_.t_roo_header_id
                                        AND rh_.last_roo_id = ro_.t_roo_id) AS roo_name
                                   ,(SELECT decode(COUNT(*), 1, MAX(ro_.corp_mail), 0, NULL, NULL)
                                       FROM t_roo_header      rh_
                                           ,t_roo             ro_
                                           ,sales_dept_header sh_
                                           ,sales_dept        sd_
                                      WHERE sh_.organisation_tree_id = dp.org_tree_id
                                        AND sh_.last_sales_dept_id = sd_.sales_dept_id
                                        AND sd_.t_roo_header_id = rh_.t_roo_header_id
                                        AND rh_.last_roo_id = ro_.t_roo_id) AS roo_email
                               FROM department dp
                                   ,ag_contract cn
                                   ,ag_contract_header ch
                                   ,contact co
                                   ,ag_category_agent ca
                                   ,document dc
                                   ,doc_status_ref dsr
                                   ,(SELECT ce.contact_id
                                           ,ce.email
                                       FROM cn_contact_email ce
                                           ,t_email_type     et
                                      WHERE ce.email_type = et.id
                                        AND ce.status = 1
                                        AND et.description = '�������') ce
                                    --
                                   ,(SELECT * FROM ag_contract_header WHERE is_new = 1) ch_lead
                                   ,ag_contract cn_lead
                                   ,contact co_lead
                                   ,document dc_lead
                                   ,(SELECT * FROM doc_status_ref WHERE brief = 'CURRENT') dsr_lead
                                   ,(SELECT ce_.contact_id
                                           ,ce_.email
                                       FROM cn_contact_email ce_
                                           ,t_email_type     et_
                                      WHERE ce_.email_type = et_.id
                                        AND ce_.status = 1
                                        AND et_.description = '�������') ce_lead
                             
                              WHERE dp.department_id = cn.agency_id
                                AND SYSDATE BETWEEN cn.date_begin AND cn.date_end
                                AND cn.category_id = ca.ag_category_agent_id
                                AND cn.contract_id = dc.document_id
                                AND dc.doc_status_ref_id = dsr.doc_status_ref_id
                                AND dsr.brief = 'CURRENT'
                                AND cn.contract_id = ch.ag_contract_header_id
                                AND ch.is_new = 1
                                AND ca.brief IN ('DR', 'DR2')
                                AND ch.agent_id = co.contact_id
                                AND co.contact_id = ce.contact_id(+)
                                   --
                                AND cn.contract_leader_id = cn_lead.ag_contract_id(+)
                                AND cn_lead.contract_id = ch_lead.ag_contract_header_id(+)
                                AND ch_lead.agent_id = co_lead.contact_id(+)
                                AND ch_lead.ag_contract_header_id = dc_lead.document_id(+)
                                AND dc_lead.doc_status_ref_id = dsr_lead.doc_status_ref_id(+)
                                AND co_lead.contact_id = ce_lead.contact_id(+)) dp
                           ,tmp_ag_nonpayment tmp
                      WHERE tmp.agency = dp.name(+)
                     -------------------------
                     --and dp.name in ('����������')
                     --and dp.name in ('������')
                     
                     -------------------------
                     )
      LOOP
        IF vr_dir.email IS NOT NULL
        THEN
          make_file_02(par_agency    => vr_dir.agency
                      ,par_plan_fact => 'P'
                      ,par_file      => v_files(1).v_file);
        
          v_files(1).v_file_name := REPLACE(vr_dir.agency, '"') || '_����_' || c_plan_period ||
                                    gc_file_ext;
        
          make_file_02(par_agency    => vr_dir.agency
                      ,par_plan_fact => 'F'
                      ,par_file      => v_files(2).v_file);
        
          v_files(2).v_file_name := REPLACE(vr_dir.agency, '"') || '_����_' || c_fact_period ||
                                    gc_file_ext;
        
          v_recipients.delete;
          v_recipients.extend(3);
          v_recipients(1) := vr_dir.email;
          v_recipients(2) := vr_dir.lead_email;
          v_recipients(3) := vr_dir.roo_email;       
          pkg_email.send_mail_with_attachment(par_to            => v_recipients
                                             ,par_subject       => '����� �� ��������� + �����������' ||
                                                                   v_is_test
                                             ,par_text          => v_message
                                             ,par_attachment    => v_files
                                             ,par_ignore_errors => TRUE);
        
          --������� ������ �� ������������ ������� � �����  
          --/������/181084: ������������ ������� �������� ������ �� ���������   
        
          add_rep_email_sended(par_rep_name  => '����� �� ��������� + �����������' || v_is_test
                              ,par_rep_type  => '����� ���������'
                              ,par_agency    => vr_dir.agency
                              ,par_name_to   => vr_dir.contact_name
                              ,par_email_to  => vr_dir.email
                              ,par_name_cc   => vr_dir.lead_name
                              ,par_email_cc  => vr_dir.lead_email
                              ,par_name_cc2  => vr_dir.roo_name
                              ,par_email_cc2 => vr_dir.roo_email
                              ,par_file      => v_log_files(1).v_file); ----------------------------------------------------                                            
        
        END IF;
        -- �������� ����� ����������
        FOR vr_mn IN (SELECT DISTINCT tmp.leader_contact_id
                                     ,tmp.agent_leader
                                     ,c.obj_name_orig AS contact_name
                                     ,ce.email
                                     ,tmp.agency
                        FROM tmp_ag_nonpayment tmp
                            ,cn_contact_email  ce
                            ,t_email_type      et
                            ,contact           c
                       WHERE tmp.leader_contact_id = ce.contact_id
                         AND ce.email_type = et.id
                         AND ce.status = 1
                         AND et.description(+) = '�������'
                         AND tmp.agency = vr_dir.agency
                         AND c.contact_id = ce.contact_id)
        LOOP
          make_file_02(par_mn_contact_id => vr_mn.leader_contact_id
                      ,par_plan_fact     => 'P'
                      ,par_file          => v_files(1).v_file);
          v_files(1).v_file_name := vr_mn.agent_leader || '_����_' || c_plan_period || gc_file_ext;
        
          make_file_02(par_mn_contact_id => vr_mn.leader_contact_id
                      ,par_plan_fact     => 'F'
                      ,par_file          => v_files(2).v_file);
          v_files(2).v_file_name := vr_mn.agent_leader || '_����_' || c_fact_period || gc_file_ext;
        
          pkg_email.send_mail_with_attachment(par_to            => pkg_email.t_recipients(vr_mn.email)
                                             ,par_cc            => CASE
                                                                     WHEN vr_dir.email IS NOT NULL THEN
                                                                      pkg_email.t_recipients(vr_dir.email)
                                                                   END
                                             ,par_subject       => '����� �� ��������� + �����������' ||
                                                                   v_is_test
                                             ,par_text          => v_message
                                             ,par_attachment    => v_files
                                             ,par_ignore_errors => TRUE);
        
          --������� ������ �� ������������ ������� � �����  
          --/������/181084: ������������ ������� �������� ������ �� ���������                          
          add_rep_email_sended(par_rep_name  => '����� �� ��������� + �����������' || v_is_test
                              ,par_rep_type  => '����� ���������'
                              ,par_agency    => vr_mn.agency
                              ,par_name_to   => vr_mn.contact_name
                              ,par_email_to  => vr_mn.email
                              ,par_name_cc   => vr_dir.contact_name
                              ,par_email_cc  => vr_dir.email
                              ,par_name_cc2  => NULL
                              ,par_email_cc2 => NULL
                              ,par_file      => v_log_files(1).v_file); ---------------------------------------------------- 
        
        END LOOP vr_mn;
      END LOOP vr_dir;
    
    END IF;
    
      --���������� ����� �� ������������ ������� �� ����� ��������������� ����
      --/������/181084: ������������ ������� �������� ������ �� ���������
    pkg_email.send_mail_with_attachment(par_to            => par_control_email
                                         ,par_cc            => NULL
                                         ,par_subject       => '����� �� ��������� + �����������' ||
                                                               v_is_test
                                         ,par_text          => '������� �������� ������ �� ���������'
                                         ,par_attachment    => v_log_files
                                         ,par_ignore_errors => TRUE);
    
      ------------------------------------------------------------------------------
    
    --����������� ��������� ������� ���� LOB
    dbms_lob.freetemporary(v_log_files(1).v_file);
    dbms_lob.freetemporary(v_files(1).v_file);
    dbms_lob.freetemporary(v_files(2).v_file);
  END send_mail_02;

  -- Author  : �������� �.�.
  -- Created : 27.04.2015
  -- Purpose : 410200: ������������� ������������ ������ � ���������
  -- Comment : ��������� ������������������ �������� ������ � ���������.
  --           ���������� �� ����� JOB_REP_AG_NONPAYMENT
  PROCEDURE send_ag_nonpayment_job IS
    v_control_email pkg_email.t_recipients := pkg_email.t_recipients();
  BEGIN
  
    v_control_email.extend(2);
    v_control_email(1) := 'policy_change_report@Renlife.com';
    v_control_email(2) := 'call_center_report@Renlife.com';
    --v_control_email(1) := '1C_SDO_Test1@renlife.com';
    --v_control_email(2) := '1C_SDO_Test2@renlife.com';
  
    pkg_ag_nonpayment_frm.send_mail_02(par_pol_plan_date_from => to_date('01.01.2005', 'dd.mm.yyyy')
                                      ,par_pol_plan_date_to   => last_day(ADD_MONTHS(trunc(SYSDATE)
                                                                                    ,-1))
                                      ,par_epg_plan_date_from => trunc(SYSDATE, 'MM')
                                      ,par_epg_plan_date_to   => last_day(trunc(SYSDATE))
                                       --------------------------------------------------------------
                                      ,par_pol_fact_date_from => to_date('01.01.2005', 'dd.mm.yyyy')
                                      ,par_pol_fact_date_to   => last_day(ADD_MONTHS(trunc(SYSDATE)
                                                                                    ,-3))
                                      ,par_epg_fact_date_from => ADD_MONTHS(trunc(SYSDATE, 'MM'), -2)
                                      ,par_epg_fact_date_to   => last_day(ADD_MONTHS(trunc(SYSDATE)
                                                                                    ,-2))
                                       -------------------------------------------------------------- 
                                      ,par_control_email         => v_control_email
                                      ,par_to_only_control_email => 0);
  
  END send_ag_nonpayment_job;

END pkg_ag_nonpayment_frm;
/

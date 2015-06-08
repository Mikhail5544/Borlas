CREATE OR REPLACE PACKAGE "PKG_EMAIL_REPORTS_FMB" IS

  -- Author  : VLADIMIR.CHIRKOV
  -- Created : 17.08.2012 14:11:18
  -- Purpose : ������������ ��� �������� ������� �� Email
  PROCEDURE prepare_issurer_adr_tel;
  /*������� ����� � ��������� ������� �� ������ ������
  * @autor - ������ �.
  * @param par_to_all - ��������� ���� ��� ������ �� ����� ��������� ��� ������� ������
  * @param par_control_email       - ����� ��� �������� ������� ������
  * @param par_content_email       - �������������� ����� � ������
  */
  PROCEDURE send_mail_issurer_adr_tel
  (
    par_to_all        VARCHAR2 -- ��������� ���� ��� ������ �� ����� ��������� ��� ������� ������
   ,par_control_email VARCHAR2 -- ����� ��� �������� ������� ������
   ,par_content_email VARCHAR2 := NULL -- �������������� ����� � ������
  );

  ---------------------------------------------------------------------------------------------------
  -- Author  : �������� �.�.
  -- Created : 14.01.2014
  -- Purpose : 295293: �������� ����������
  -- Comment : ��������� ������������ ������ ������� ��� ������� �
  --           �������� ������ � ��������� �������������.
  --           ���������� �� ����� JOB_USER_MONITORING_DAILY
  PROCEDURE send_mail_user_monitoring_job;

  -- Author  : �������� �.�.
  -- Created : 14.01.2014
  -- Purpose : 295293: �������� ����������
  -- Param   : par_control_email       - ������ ������� ��� �������� ������
  --           par_dt_f                - ���� �
  --           par_dt_t                - ���� ��
  --           par_control_email_cc    - ������ ������� ��� �������� ����� ������
  --           par_content_email       - �������������� ����� � ������
  -- Comment : ��������� �������� ������ � ��������� �������������.
  PROCEDURE send_mail_user_monitoring
  (
    par_control_email    pkg_email.t_recipients -- ������ ��� �������� ������
   ,par_date_from        DATE -- ���� �
   ,par_date_to          DATE -- ���� ��
   ,par_control_email_cc pkg_email.t_recipients := NULL -- ������ ��� �������� ����� ������
   ,par_content_email    VARCHAR2 := NULL -- �������������� ����� � ������
  );

  ---------------------------------------------------------------------------------------------------
  -- Author  : �������� �.�.
  -- Created : 17.01.2014
  -- Purpose : 297034: �������� 115 ��
  -- Comment : ��������� ������������ ������ ������� ��� ������� �
  --           �������� ������ <�������� 115 ��>.
  --           ���������� �� ����� JOB_rep_control_115_DAILY
  PROCEDURE send_mail_rep_control_115_job;

  -- Author  : �������� �.�.
  -- Created : 17.01.2014
  -- Purpose : 297034: �������� 115 ��
  -- Param   : par_control_email       - ������ ������� ��� �������� ������
  --           par_control_email_cc    - ������ ������� ��� �������� ����� ������
  --           par_content_email       - �������������� ����� � ������
  -- Comment : ��������� �������� ������ <�������� 115 ��>.
  PROCEDURE send_mail_rep_control_115
  (
    par_control_email    pkg_email.t_recipients -- ������ ��� �������� ������
   ,par_control_email_cc pkg_email.t_recipients := NULL -- ������ ��� �������� ����� ������
   ,par_content_email    VARCHAR2 := NULL -- �������������� ����� � ������
  );

  /*
    ������ �.
    310647 ���������� ������� ������ ����, ��������� ������ �������� 115 ��
  */
  PROCEDURE send_mail_rep_finmon_fatf
  (
    par_control_email    pkg_email.t_recipients -- ������ ��� �������� ������
   ,par_control_email_cc pkg_email.t_recipients := NULL -- ������ ��� �������� ����� ������
  );

  /*
    ������ �.
    310647 ���������� ������� ������ ����, ��������� ������ �������� 115 ��
  */
  PROCEDURE send_mail_rep_finmon_fatf_job;

  /* ������� �.�. 
  ��������� "������. �������� ������ ����"
  */
  PROCEDURE send_mail_claim_ndfl
  (
    par_claim_id ins.c_claim.c_claim_id%TYPE -- ID ����
   ,par_email    pkg_email.t_recipients := NULL -- ����� ��� �������� ������
  );

  /* ������� �.�. 
  ��������� "�����������. �������� ������ ����"
  */
  PROCEDURE send_mail_decline_ndfl
  (
    par_policy_id ins.p_policy.policy_id%TYPE ---- ID ���� 
   ,par_email     pkg_email.t_recipients := NULL -- ����� ��� �������� ������
  );

  /*
     ��������� �.
    399852 �������� �������� �������� � �������� �������� mpos. Job.
  */
  PROCEDURE send_mail_writeoff_control_job;

  /*
    ��������� �.
    399852 �������� �������� ��������. ������������ ������ + �������� ��������
  */
  PROCEDURE send_mail_rep_acq_recurrent
  (
    par_control_email    pkg_email.t_recipients -- ������ ��� �������� ������
   ,par_control_email_cc pkg_email.t_recipients := NULL -- ������ ��� �������� ����� ������
  );

  /*
    ��������� �.
    399986 �������� �������� mpos. ������������ ������ + �������� ��������
  */
  PROCEDURE send_mail_mpos_paym_not_payed
  (
    par_control_email    pkg_email.t_recipients -- ������ ��� �������� ������
   ,par_control_email_cc pkg_email.t_recipients := NULL -- ������ ��� �������� ����� ������
  );

   /*
     ��������� �.
    408398 �������� ������ DWH_����� � ���������_������ ������_2015 ��� ����-������. Job.
  */
  PROCEDURE send_mail_nopaym_2015_cc_job;
  
  
  /*
    ��������� �.
    408398 �������� ������ DWH_����� � ���������_������ ������_2015 ��� ����-������. ������������ ������ + �������� ��������
  */
  PROCEDURE send_mail_rep_nonpaym_2015_cc
  (
    par_control_email    pkg_email.t_recipients -- ������ ��� �������� ������
   ,par_control_email_cc pkg_email.t_recipients := NULL -- ������ ��� �������� ����� ������
  );

-- ��������� �������� ������ <�������� 115 ��> ��� ��������� ��������
  -- ������ 314488
  -- Params:  par_control_email       - ������ ������� ��� �������� ������
  --         par_control_email_cc    - ������ ������� ��� �������� ����� ������
  --         par_content_email       - �������������� ����� � ������
  PROCEDURE send_mail_rep_control_115_ppi
  (
    par_control_email    pkg_email.t_recipients -- ������ ��� �������� ������
   ,par_control_email_cc pkg_email.t_recipients := NULL -- ������ ��� �������� ����� ������
   ,par_content_email    VARCHAR2 := NULL -- �������������� ����� � ������
  );

END pkg_email_reports_fmb; 
/
CREATE OR REPLACE PACKAGE BODY "PKG_EMAIL_REPORTS_FMB" IS

  gc_file_ext CONSTANT VARCHAR2(30) := '.xls';

  /*
    ������ �.
    ���������� ��������� ������� ������� ��� ������:
    ��. ����� �� ������������� ������� � ���������
  */
  PROCEDURE prepare_issurer_adr_tel IS
  BEGIN
    INSERT INTO tmp_issurer_adr_tel
      (contact_id
      ,contact_name
      ,type_requisit_absenced
      ,ids
      ,dep_name
      ,department_id
      ,agent_name
      ,agent_id
      ,leader_name
      ,leader_id
      ,requisites_type_name
      ,requisites_name
      ,requisites_status_name
      ,is_check_adr_tel
      ,prod_description
      ,prod_brief
      ,contact_number)
      SELECT contact_id
            ,contact_name
            ,type_requisit_absenced
            ,ids
            ,dep_name
            ,department_id
            ,agent_name
            ,agent_id
            ,leader_name
            ,leader_id
            ,requisites_type_name
            ,requisites_name
            ,requisites_status_name
            ,is_check_adr_tel
            ,prod_description
            ,prod_brief
            ,contact_number
        FROM v_rep_issurer_adr_tel v;
  
  END prepare_issurer_adr_tel;

  /*
      ������ �.
      ���������� ���������� � ������ �� ������ ������
      ��. ����� �� ������������� ������� � ���������
  */

  /*
    ������ 332603 ������� �� ������ �������������
    ����������� �.  
    � ���� ������ ������������� �������� (329826)
    �������� ��� ���  � ����������� �� ������ ������ (8187958, 8187959, 8187960)
  */

  FUNCTION make_issurer_adr_tel
  (
    par_num           NUMBER
   ,par_leader_id     NUMBER := NULL
   ,par_department_id NUMBER := NULL
   ,par_file          IN OUT NOCOPY BLOB
  ) RETURN INT IS
    CURSOR cur_send_data
    (
      par_num           NUMBER
     ,par_leader_id     NUMBER
     ,par_department_id NUMBER
    ) IS
      SELECT rownum rn
            ,x.*
        FROM (SELECT contact_id
                    ,contact_name
                    ,type_requisit_absenced
                    ,ids
                    ,dep_name
                    ,department_id
                    ,agent_name
                    ,agent_id
                    ,leader_name
                    ,leader_id
                    ,requisites_type_name
                    ,requisites_name
                    ,requisites_status_name
                    ,is_check_adr_tel
                    ,prod_description
                    ,contact_number
                FROM tmp_issurer_adr_tel tmp
               WHERE ((par_num = 1 AND tmp.prod_brief = 'GN') --������������� �������
                     OR (par_num = 2 AND tmp.prod_brief != 'GN' --������������� �������
                     AND tmp.agent_id IN (329826, 8187958, 8187959, 8187960, 1116423)) --������ ������������� ��������, ������������ ���������� �����
                     OR (par_num = 3 AND tmp.prod_brief != 'GN' --������������� �������
                     AND tmp.agent_id NOT IN (329826, 8187958, 8187959, 8187960, 1116423) --������ ������������� ��������, ������������ ���������� �����
                     AND tmp.department_id = 8127) --������� ������ � ���������
                     OR (par_num = 4 AND tmp.prod_brief != 'GN' --������������� �������
                     AND tmp.agent_id NOT IN (329826, 8187958, 8187959, 8187960) --������ ������������� ��������
                     AND tmp.department_id = 6065 --������ ��
                     AND tmp.leader_id = par_leader_id) OR
                     (par_num = 5 AND tmp.prod_brief != 'GN' --������������� �������
                     AND tmp.agent_id NOT IN (329826, 8187958, 8187959, 8187960) --������ ������������� ��������
                     AND tmp.department_id != 8127 --������� ������ � ���������
                     AND tmp.department_id != 6065 --������ ��
                     AND tmp.department_id = par_department_id) OR
                     (par_num = 6 AND tmp.prod_brief != 'GN' --������������� �������
                     AND tmp.agent_id NOT IN (329826, 8187958, 8187959, 8187960) --������ ������������� ��������
                     AND tmp.department_id != 8127 --������� ������ � ���������
                     AND tmp.department_id != 6065 --������ ��
                     AND tmp.leader_id = par_leader_id) OR (par_num = 7))
               ORDER BY leader_name
                       ,agent_name
                       ,contact_name) x;
  
    v_data_row cur_send_data%ROWTYPE;
    v_row      VARCHAR2(2500);
    v_row_raw  RAW(2500);
    v_result   INT;
  BEGIN
    v_result := 1;
    dbms_lob.trim(lob_loc => par_file, newlen => 0);
    -- ����� ���������
    v_row_raw := utl_raw.cast_to_raw('�' || chr(9) || '��� ��������' || chr(9) ||
                                     '��� �������������� ���������' || chr(9) || '����������� �������' ||
                                     chr(9) || '��������' || chr(9) || '����������� �����' || chr(9) ||
                                     '������������ ������/���������' || chr(9) ||
                                     '�������� �� ������������ ������/��������' || chr(9) ||
                                     '��� ���������� ��������� � ��������' || chr(9) ||
                                     '��������� �������� � ��������' || chr(9) ||
                                     '������ ����������� ��������� � ��������' || chr(9) || '�������' ||
                                     chr(9) || '���������� �����' || chr(9) || utl_tcp.crlf);
    dbms_lob.writeappend(lob_loc => par_file
                        ,amount  => utl_raw.length(v_row_raw)
                        ,buffer  => v_row_raw);
  
    -- ��������� ������ �����
    OPEN cur_send_data(par_num           => par_num
                      ,par_leader_id     => par_leader_id
                      ,par_department_id => par_department_id);
  
    LOOP
      FETCH cur_send_data
        INTO v_data_row;
      EXIT WHEN cur_send_data%NOTFOUND;
      v_row := v_data_row.rn || chr(9) --'�'
               || v_data_row.contact_name || chr(9) --'��� ��������'                             
               || v_data_row.type_requisit_absenced || chr(9) --'��� �������������� ���������' 
               || v_data_row.ids || chr(9) --'����������� �������'                     
               || v_data_row.dep_name || chr(9) --'��������'                              
               || v_data_row.agent_name || chr(9) --'����������� �����'                        
               || v_data_row.leader_name || chr(9) --'������������ ������/���������'          
               || v_data_row.requisites_type_name || chr(9) --'�������� �� ������������ ������/��������' 
               || v_data_row.requisites_name || chr(9) --'��� ���������� ��������� � ��������'     
               || v_data_row.requisites_status_name || chr(9) --'��������� �������� � ��������'            
               || v_data_row.is_check_adr_tel || chr(9) --'������ ����������� ��������� � ��������'  
               || v_data_row.prod_description || chr(9) --'�������'       
               || v_data_row.contact_number || chr(9) --'���������� �����'                     
               || utl_tcp.crlf;
    
      v_row_raw := utl_raw.cast_to_raw(v_row);
      dbms_lob.writeappend(lob_loc => par_file
                          ,amount  => utl_raw.length(v_row_raw)
                          ,buffer  => v_row_raw);
    END LOOP;
    IF cur_send_data%ROWCOUNT = 0
    THEN
      v_result := 0;
    END IF;
  
    CLOSE cur_send_data;
  
    RETURN v_result;
  END make_issurer_adr_tel;

  /*
    ������ �.
    ������� ����� � ��������� ������� �� ������ ������
    ��. ����� �� ������������� ������� � ��������� 
  */
  PROCEDURE send_mail_issurer_adr_tel
  (
    par_to_all        VARCHAR2 -- ��������� ���� ��� ������ �� ����� ��������� ��� ������� ������
   ,par_control_email VARCHAR2 -- ����� ��� �������� ������� ������
   ,par_content_email VARCHAR2 := NULL -- �������������� ����� � ������
  ) IS
    v_recipients    pkg_email.t_recipients := pkg_email.t_recipients();
    v_files         pkg_email.t_files := pkg_email.t_files();
    c_message       VARCHAR2(2000) := '������ ����!
    �������� ��� ������ ��������, ������� �� ���� ���������� ������/ ��� ��� ��������� �������/ ���������. 
    ' || chr(10) || '������ ������ ������� ������������� �������� BI. ������ ��� �� �������� �� �����, � �������� ���� ���������� ������ ������.
    ' || chr(10) || par_content_email;
    v_result        INT;
    v_email_message pkg_email.t_email_message := pkg_email.t_email_message();
  BEGIN
    -- ���������� ������
    DELETE FROM tmp_issurer_adr_tel;
  
    prepare_issurer_adr_tel;
  
    -- �������� ������� ������ ��������������� ����
    v_files.extend(1);
    v_files(1).v_file_type := 'application/excel';
    dbms_lob.createtemporary(lob_loc => v_files(1).v_file, cache => TRUE);
    v_files(1).v_file_name := '����� �� ������������� ������� � ���������' || gc_file_ext;
  
    v_result := make_issurer_adr_tel(par_num => 7, par_file => v_files(1).v_file);
  
    IF v_result = 1
    THEN
      v_email_message.extend(1);
      v_email_message(v_email_message.last).recipients := pkg_email.t_recipients(par_control_email);
      v_email_message(v_email_message.last).text := c_message;
      v_email_message(v_email_message.last).subject := '����� �� ������������� ������� � ��������� ';
      v_email_message(v_email_message.last).attachment := v_files;
    END IF;
  
    IF par_to_all = 1
    THEN
    
      --�������� ����� �� �������          
      DECLARE
        --������ � ������� ��� �������������� �������� �����  
        TYPE rec_individual_send IS RECORD(
           email      VARCHAR2(50)
          ,ind        INT
          ,contact_id NUMBER
          ,NAME       VARCHAR2(500));
        --��������� ������� ��� �������������� �������� �����   
        TYPE t_individual_send IS TABLE OF rec_individual_send;
      
        v_individual_send t_individual_send := t_individual_send();
      BEGIN
        v_individual_send.extend(7);
        
        v_individual_send(1).email := 'Viktoria.Ovchinnikova@Renlife.com';
        v_individual_send(1).ind := 1;
        v_individual_send(1).contact_id := NULL;
        v_individual_send(1).name := '�������� �����������';

        v_individual_send(2).email := 'Mariya.Hristoforova@Renlife.com';
        v_individual_send(2).ind := 2;
        v_individual_send(2).contact_id := NULL;
        v_individual_send(2).name := '����� ������������';
      
        v_individual_send(3).email := 'broker@renlife.com';
        v_individual_send(3).ind := 3;
        v_individual_send(3).contact_id := NULL;
        v_individual_send(3).name := '���� ��������';
      
        v_individual_send(4).email := 'Yuriy.Smyshlyaev@Renlife.com';
        v_individual_send(4).ind := 4;
        v_individual_send(4).contact_id := 211999;
        v_individual_send(4).name := '���� ��������';
      
        v_individual_send(5).email := 'Natalya.Glushkova@Renlife.com';
        v_individual_send(5).ind := 4;
        v_individual_send(5).contact_id := 257976;
        v_individual_send(5).name := '������� ��������';
      
        v_individual_send(6).email := 'Valeriya.Lepetan@Renlife.com';
        v_individual_send(6).ind := 4;
        v_individual_send(6).contact_id := 1114024;
        v_individual_send(6).name := '������� �������';
      
        v_individual_send(7).email := 'client@renlife.com';
        v_individual_send(7).ind := 2;
        v_individual_send(7).contact_id := null;
        v_individual_send(7).name := 'client';
      
        --��������� ��������� ������� �������� ����� 
        FOR v_ind IN v_individual_send.first .. v_individual_send.last
        LOOP
          v_result := make_issurer_adr_tel(par_num       => v_individual_send(v_ind).ind
                                          ,par_leader_id => v_individual_send(v_ind).contact_id
                                          ,par_file      => v_files(1).v_file);
        
          IF v_result = 1
          THEN
            v_email_message.extend(1);
            v_email_message(v_email_message.last).recipients := pkg_email.t_recipients(v_individual_send(v_ind)
                                                                                       .email);
            v_email_message(v_email_message.last).text := c_message;
            v_email_message(v_email_message.last).subject := '����� �� ������������� ������� � ��������� ' || v_individual_send(v_ind).name;
            v_email_message(v_email_message.last).attachment := v_files;
          END IF;
        END LOOP;
      END;
    
      -- �������� ����� ����������
      FOR vr_dir IN (SELECT DISTINCT dp.contact_id
                                    ,dp.email
                                    ,tmp.dep_name
                                    ,tmp.department_id
                                    ,dp.obj_name_orig NAME
                                    ,roo_email
                       FROM (SELECT co.contact_id
                                   ,ce.email
                                   ,dp.name
                                   ,dp.department_id
                                   ,co.obj_name_orig
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
                           ,tmp_issurer_adr_tel tmp
                      WHERE tmp.department_id = dp.department_id(+) --���� ��� � ��������� ������, �� ���� ����������� ����� � ��������� ������ (+)
                     -------------------------
                     --  and tmp.dep_name in ('������-4', '�����')
                     -------------------------
                     )
      LOOP
        IF vr_dir.email IS NOT NULL
        THEN
          v_result := make_issurer_adr_tel(par_num           => 5
                                          ,par_department_id => vr_dir.department_id
                                          ,par_file          => v_files(1).v_file);
          IF v_result = 1
          THEN
            v_recipients.delete;
            v_recipients.extend(2);
            v_recipients(1) := vr_dir.roo_email;
            v_recipients(2) := vr_dir.email;
          
            v_email_message.extend(1);
            v_email_message(v_email_message.last).recipients := v_recipients;
            v_email_message(v_email_message.last).text := c_message;
            v_email_message(v_email_message.last).subject := '����� �� ������������� ������� � ���������. �������� ' ||
                                                             vr_dir.dep_name;
            v_email_message(v_email_message.last).attachment := v_files;
          END IF;
        END IF;
      
        -- �������� ����� ���������� ���� ��� ���������
        v_recipients.delete;
        FOR vr_mn IN (SELECT rownum rn
                            ,x.*
                        FROM (SELECT DISTINCT tmp.leader_id
                                             ,tmp.leader_name
                                             ,ce.email
                                             ,tmp.department_id
                                             ,tmp.dep_name
                                             ,(SELECT decode(COUNT(*)
                                                            ,1
                                                            ,MAX(ro_.corp_mail)
                                                            ,0
                                                            ,NULL
                                                            ,NULL)
                                                 FROM t_roo_header      rh_
                                                     ,t_roo             ro_
                                                     ,sales_dept_header sh_
                                                     ,sales_dept        sd_
                                                WHERE sh_.organisation_tree_id = dp.org_tree_id
                                                  AND sh_.last_sales_dept_id = sd_.sales_dept_id
                                                  AND sd_.t_roo_header_id = rh_.t_roo_header_id
                                                  AND rh_.last_roo_id = ro_.t_roo_id) AS roo_email
                                FROM tmp_issurer_adr_tel tmp
                                    ,department          dp
                                    ,cn_contact_email    ce
                                    ,t_email_type        et
                               WHERE tmp.leader_id = ce.contact_id
                                 AND ce.email_type = et.id
                                 AND ce.status = 1
                                 AND et.description = '�������'
                                 AND tmp.department_id = vr_dir.department_id
                                 AND tmp.department_id = dp.department_id
                                 AND vr_dir.contact_id IS NULL) x)
        LOOP
          IF vr_mn.email IS NOT NULL
          THEN
            IF vr_mn.rn = 1
            THEN
              v_recipients.extend(1);
              v_recipients(1) := vr_mn.roo_email;
            END IF;
            v_recipients.extend(1);
            v_recipients(vr_mn.rn + 1) := vr_mn.email;
          END IF;
        END LOOP vr_mn;
        IF v_recipients.count > 0
        THEN
          v_result := make_issurer_adr_tel(par_num           => 5
                                          ,par_department_id => vr_dir.department_id
                                          ,par_file          => v_files(1).v_file);
        
          IF v_result = 1
          THEN
            v_email_message.extend(1);
            v_email_message(v_email_message.last).recipients := v_recipients;
            v_email_message(v_email_message.last).text := c_message;
            v_email_message(v_email_message.last).subject := '����� �� ������������� ������� � ���������. �������� ' ||
                                                             vr_dir.dep_name;
            v_email_message(v_email_message.last).attachment := v_files;
          END IF;
        END IF;
      END LOOP vr_dir;
    END IF; --if par_to_all = 1 then
  
    --���������� ������ �� ������ ��������� �������
    FOR v_i IN v_email_message.first .. v_email_message.last
    LOOP
      pkg_email.send_mail_with_attachment(par_to         => v_email_message(v_i).recipients
                                         ,par_subject    => v_email_message(v_i).subject
                                         ,par_text       => v_email_message(v_i).text
                                         ,par_attachment => v_email_message(v_i).attachment);
    END LOOP;
    dbms_lob.freetemporary(v_files(1).v_file);
  EXCEPTION
    WHEN OTHERS THEN
      dbms_lob.freetemporary(v_files(1).v_file);
      raise_application_error('-20000', SQLERRM);
  END send_mail_issurer_adr_tel;
  --------------------------------------------------------------------------------------------------------------
  -- Author  : �������� �.�.
  -- Created : 14.01.2014
  -- Purpose : 295293: �������� ����������
  -- Comment : ��������� ������������ ������ ������� ��� ������� �
  --           �������� ������ � ��������� �������������.
  --           ���������� �� ����� JOB_USER_MONITORING_DAILY

  PROCEDURE send_mail_user_monitoring_job IS
    v_control_email pkg_email.t_recipients := pkg_email.t_recipients();
  BEGIN
    -- ���������� ������ ������� ��� ���� ���-��������.
    FOR ce IN (SELECT v_mail.email
                 FROM ven_sys_user         u
                     ,v_rel_role_user      vru
                     ,contact              c
                     ,ven_cn_contact_email v_mail
                WHERE vru.userid = u.sys_user_id
                  AND c.contact_id = u.contact_id
                  AND v_mail.contact_id = c.contact_id
                  AND vru.rolename = '���-��������'
                  AND vru.assigned = 1)
    LOOP
      v_control_email.extend(1);
      v_control_email(v_control_email.last) := ce.email;
    END LOOP;
    --���� ��� �� ������ ������.
    IF v_control_email IS empty
    THEN
      raise_application_error('-20000'
                             ,'�� ������� �� ������ ������ ��� ��������. ' || SQLERRM);
    END IF;
    send_mail_user_monitoring(par_control_email => v_control_email
                             ,par_date_from     => (SYSDATE - 1)
                             ,par_date_to       => SYSDATE);
  END;

  -- Author  : �������� �.�.
  -- Created : 14.01.2014
  -- Purpose : 295293: �������� ����������
  -- Param   : par_control_email       - ������ ������� ��� �������� ������
  --           par_dt_f                - ���� �
  --           par_dt_t                - ���� ��
  --           par_content_email       - �������������� ����� � ������
  -- Comment : ��������� �������� ������ � ��������� �������������.

  PROCEDURE send_mail_user_monitoring
  (
    par_control_email    pkg_email.t_recipients -- ������ ��� �������� ������
   ,par_date_from        DATE -- ���� �
   ,par_date_to          DATE -- ���� ��
   ,par_control_email_cc pkg_email.t_recipients := NULL -- ������ ��� �������� ����� ������
   ,par_content_email    VARCHAR2 := NULL -- �������������� ����� � ������
  ) IS
    file_ext        VARCHAR2(5) := '.xlsx';
    v_files         pkg_email.t_files := pkg_email.t_files();
    c_message       VARCHAR2(2000) := '������ ����!
    �������� ��� ����� � ��������� ������������� �� ' ||
                                      to_char(SYSDATE - 1, 'dd.mm.yyyy') || chr(10) ||
                                      par_content_email;
    v_email_message pkg_email.t_email_message := pkg_email.t_email_message();
  
    --���������� �����
    FUNCTION make_file_user_monitoring
    (
      par_file      IN OUT NOCOPY BLOB
     ,par_date_from DATE
     ,par_date_to   DATE
    ) RETURN BOOLEAN IS
      CURSOR cur_send_data IS
        SELECT rownum rn
              ,user_name
              ,name_doc_templ
              ,document_id
              ,name_state
              ,start_date
          FROM v_rep_user_monitoring
              ,sys_user su
         WHERE user_name = su.sys_user_name
           AND su.act_control = 1
           AND start_date BETWEEN trunc(par_date_from) AND trunc(par_date_to)
        /*      --��� �������!
                UNION ALL
                SELECT 9998,'A','DT1',0,'ST1',SYSDATE FROM dual UNION ALL
                SELECT 9999,'B','DT2',1,'ST2',SYSDATE FROM dual
        */
        ;
      v_data_row cur_send_data%ROWTYPE;
      v_result   INT;
    BEGIN
      --�������� ���������
      ora_excel.new_document;
      ora_excel.add_sheet('�������� �������������');
      --�������� �����
      ora_excel.add_row;
      ora_excel.set_cell_value('A', '�');
      ora_excel.set_cell_value('B', '������������');
      ora_excel.set_cell_value('C', '������ ���������');
      ora_excel.set_cell_value('D', 'ID ���������');
      ora_excel.set_cell_value('E', '������');
      ora_excel.set_cell_value('F', '����');
      --�������� ����
      OPEN cur_send_data;
      LOOP
        FETCH cur_send_data
          INTO v_data_row;
        EXIT WHEN cur_send_data%NOTFOUND;
        ora_excel.add_row;
        ora_excel.set_cell_value('A', v_data_row.rn);
        ora_excel.set_cell_value('B', v_data_row.user_name);
        ora_excel.set_cell_value('C', v_data_row.name_doc_templ);
        ora_excel.set_cell_value('D', v_data_row.document_id);
        ora_excel.set_cell_value('E', v_data_row.name_state);
        ora_excel.set_cell_value('F', v_data_row.start_date);
      END LOOP;
    
      ora_excel.save_to_blob(par_file);
      RETURN cur_send_data%ROWCOUNT > 0;
    END make_file_user_monitoring;
  
  BEGIN
    -- ��������
    v_files.extend(1);
    v_files(1).v_file_type := 'application/excel';
    v_files(1).v_file_name := '����� � ��������� ������������� �� ' ||
                              to_char(SYSDATE - 1, 'yyyy-mm-dd') || file_ext;
  
    IF make_file_user_monitoring(par_file      => v_files(1).v_file
                                ,par_date_from => par_date_from
                                ,par_date_to   => par_date_to)
    THEN
      v_email_message.extend(1);
      v_email_message(v_email_message.last).recipients := par_control_email;
      v_email_message(v_email_message.last).text := c_message;
      v_email_message(v_email_message.last).subject := '����� � ��������� �������������';
      v_email_message(v_email_message.last).attachment := v_files;
    
      --���������� ������ �� ������ ��������� �������
      FOR v_i IN v_email_message.first .. v_email_message.last
      LOOP
        pkg_email.send_mail_with_attachment(par_to         => v_email_message(v_i).recipients
                                           ,par_cc         => par_control_email_cc
                                           ,par_subject    => v_email_message(v_i).subject
                                           ,par_text       => v_email_message(v_i).text
                                           ,par_attachment => v_email_message(v_i).attachment);
      END LOOP;
    END IF;
    dbms_lob.freetemporary(v_files(1).v_file);
  END send_mail_user_monitoring;

  --------------------------------------------------------------------------------------------------------------
  -- Author  : �������� �.�.
  -- Created : 17.01.2014
  -- Purpose : 297034: �������� 115 ��
  -- Comment : ��������� ������������ ������ ������� ��� ������� �
  --           �������� ������ <�������� 115 ��>.
  --           ���������� �� ����� JOB_rep_control_115_DAILY

  PROCEDURE send_mail_rep_control_115_job IS
    v_control_email pkg_email.t_recipients := pkg_email.t_recipients();
  BEGIN
    -- ���������� ������ ������� ��� ���� ���-��������.
    v_control_email.extend(1);
    v_control_email(v_control_email.last) := '115fz@renlife.com';
    --���� ��� �� ������ ������.
    IF v_control_email IS empty
    THEN
      raise_application_error('-20000'
                             ,'�� ������� �� ������ ������ ��� ��������. ' || SQLERRM);
    END IF;
    send_mail_rep_control_115(par_control_email => v_control_email);
    -- �������� ��������� ��������
    send_mail_rep_control_115_ppi(par_control_email => v_control_email);
  END;

  -- Author  : �������� �.�.
  -- Created : 17.01.2014
  -- Purpose : 297034: �������� 115 ��
  -- Param   : par_control_email       - ������ ������� ��� �������� ������
  --           par_control_email_cc    - ������ ������� ��� �������� ����� ������
  --           par_content_email       - �������������� ����� � ������
  -- Comment : ��������� �������� ������ <�������� 115 ��>.

  PROCEDURE send_mail_rep_control_115
  (
    par_control_email    pkg_email.t_recipients -- ������ ��� �������� ������
   ,par_control_email_cc pkg_email.t_recipients := NULL -- ������ ��� �������� ����� ������
   ,par_content_email    VARCHAR2 := NULL -- �������������� ����� � ������
  ) IS
    v_files         pkg_email.t_files := pkg_email.t_files();
    c_message       VARCHAR2(2000) := '������ ����!
    �������� ��� ����� "�������� 115 ��" �� ' ||
                                      to_char(SYSDATE, 'dd.mm.yyyy') || chr(10) || par_content_email;
    v_result        INT;
    v_email_message pkg_email.t_email_message := pkg_email.t_email_message();
  
    --���������� �����
    FUNCTION make_file_user_monitoring(par_file IN OUT NOCOPY BLOB) RETURN INT IS
      CURSOR cur_send_data IS
        SELECT "���"
               ,"����� ��������"
               ,"������ �������� ������"
               ,"������ ��������� ������"
               ,"���"
               ,"���� ��������"
               ,"��� ���������"
               ,"�����"
               ,"�����"
               ,"��� �����"
               ,"���� ������"
               ,"����� �����������"
               ,"�������������� �����"
               ,"���"
               ,"����� �������, ���."
               ,"��������� ������, ���."
               ,"���� ��������� ������"
               ,"����������"
               ,"���� ���������� ��������"
               ,"������������� ������"
               ,"����"
          FROM v_rep_ipdl_600 r
         WHERE r."����� ����� �����. �����, ���." >= 600000;
    
      v_data_row cur_send_data%ROWTYPE;
      v_row      VARCHAR2(2500);
      v_row_raw  RAW(2500);
      v_result   INT;
    BEGIN
      v_result := 1;
      dbms_lob.trim(lob_loc => par_file, newlen => 0);
      -- ����� ���������
      v_row_raw := utl_raw.cast_to_raw('���' || chr(9) || '����� ��������' || chr(9) ||
                                       '������ �������� ������' || chr(9) || '������ ��������� ������' ||
                                       chr(9) || '���' || chr(9) || '���� ��������' || chr(9) ||
                                       '��� ���������' || chr(9) || '�����' || chr(9) || '�����' ||
                                       chr(9) || '��� �����' || chr(9) || '���� ������' || chr(9) ||
                                       '����� �����������' || chr(9) || '�������������� �����' ||
                                       chr(9) || '���' || chr(9) || '����� �������, ���.' || chr(9) ||
                                       '��������� ������, ���.' || chr(9) || '���� ��������� ������' ||
                                       chr(9) || '����������' || chr(9) || '���� ���������� ��������' ||
                                       chr(9) || '������������� ������' || chr(9) || '����' || chr(9) ||
                                       utl_tcp.crlf);
      dbms_lob.writeappend(lob_loc => par_file
                          ,amount  => utl_raw.length(v_row_raw)
                          ,buffer  => v_row_raw);
    
      -- ��������� ������ �����
      OPEN cur_send_data;
    
      LOOP
        FETCH cur_send_data
          INTO v_data_row;
        EXIT WHEN cur_send_data%NOTFOUND;
        v_row := v_data_row."���" || chr(9) || --���
                 v_data_row."����� ��������" || chr(9) || --����� ��������
                 v_data_row."������ �������� ������" || chr(9) || --������ �������� ������
                 v_data_row."������ ��������� ������" || chr(9) || --������ ��������� ������
                 v_data_row."���" || chr(9) || --���
                 v_data_row."���� ��������" || chr(9) || --���� ��������
                 v_data_row."��� ���������" || chr(9) || --��� ���������
                 v_data_row."�����" || chr(9) || --�����
                 v_data_row."�����" || chr(9) || --�����
                 v_data_row."��� �����" || chr(9) || --��� �����
                 v_data_row."���� ������" || chr(9) || --���� ������
                 v_data_row."����� �����������" || chr(9) || --����� �����������
                 v_data_row."�������������� �����" || chr(9) || --�������������� �����
                 v_data_row."���" || chr(9) || --���
                 v_data_row."����� �������, ���." || chr(9) || --�����. ����� �� ���. ���.
                 v_data_row."��������� ������, ���." || chr(9) || --����� ����� �����. �����, ���.
                 v_data_row."���� ��������� ������" || chr(9) || --���� ������
                 v_data_row."����������" || chr(9) || --����������
                 v_data_row."���� ���������� ��������" || chr(9) || --���� ���������� ��������
                 v_data_row."������������� ������" || chr(9) || --������������� ������
                 v_data_row."����" || chr(9) || --����
                 utl_tcp.crlf;
      
        v_row_raw := utl_raw.cast_to_raw(v_row);
        dbms_lob.writeappend(lob_loc => par_file
                            ,amount  => utl_raw.length(v_row_raw)
                            ,buffer  => v_row_raw);
      END LOOP;
      RETURN v_result;
    END make_file_user_monitoring;
  
  BEGIN
    -- ��������
    v_files.extend(1);
    v_files(1).v_file_type := 'application/excel';
    dbms_lob.createtemporary(lob_loc => v_files(1).v_file, cache => TRUE);
    v_files(1).v_file_name := '�������� 115 �� �� ' || to_char(SYSDATE, 'yyyy-mm-dd') || gc_file_ext;
  
    v_result := make_file_user_monitoring(par_file => v_files(1).v_file);
  
    IF v_result = 1
    THEN
      v_email_message.extend(1);
      v_email_message(v_email_message.last).recipients := par_control_email;
      v_email_message(v_email_message.last).text := c_message;
      v_email_message(v_email_message.last).subject := '"�������� 115 ��"';
      v_email_message(v_email_message.last).attachment := v_files;
    END IF;
    --���������� ������ �� ������ ��������� �������
    FOR v_i IN v_email_message.first .. v_email_message.last
    LOOP
      pkg_email.send_mail_with_attachment(par_to         => v_email_message(v_i).recipients
                                         ,par_cc         => par_control_email_cc
                                         ,par_subject    => v_email_message(v_i).subject
                                         ,par_text       => v_email_message(v_i).text
                                         ,par_attachment => v_email_message(v_i).attachment);
    END LOOP;
    dbms_lob.freetemporary(v_files(1).v_file);
  END send_mail_rep_control_115;

  /*
    ������ �.
    310647 ���������� ������� ������ ����, ��������� ������ �������� 115 ��
  */
  PROCEDURE send_mail_rep_finmon_fatf_job IS
    v_control_email pkg_email.t_recipients := pkg_email.t_recipients();
  BEGIN
    -- ���������� ������ �������
    v_control_email.extend(1);
    v_control_email(v_control_email.last) := '115fz@renlife.com';
    --���� ��� �� ������ ������.
    IF v_control_email IS empty
    THEN
      raise_application_error('-20000'
                             ,'�� ������� �� ������ ������ ��� ��������. ' || SQLERRM);
    END IF;
    send_mail_rep_finmon_fatf(par_control_email => v_control_email);
  END send_mail_rep_finmon_fatf_job;

  /*
    ������ �.
    310647 ���������� ������� ������ ����, ��������� ������ �������� 115 ��
  */
  PROCEDURE send_mail_rep_finmon_fatf
  (
    par_control_email    pkg_email.t_recipients -- ������ ��� �������� ������
   ,par_control_email_cc pkg_email.t_recipients := NULL -- ������ ��� �������� ����� ������
  ) IS
    file_ext        VARCHAR2(5) := '.xlsx';
    v_files         pkg_email.t_files := pkg_email.t_files();
    c_message       VARCHAR2(2000) := '������ ����!';
    v_email_message pkg_email.t_email_message := pkg_email.t_email_message();
  
    --���������� �����
    PROCEDURE make_file_report(par_file IN OUT NOCOPY BLOB) IS
    BEGIN
      --�������� ���������
      ora_excel.new_document;
      ora_excel.add_sheet('�������� �� ������ ������� ����');
      --�������� �����
      ora_excel.add_row;
      ora_excel.set_cell_value('A', '���');
      ora_excel.set_cell_value('B', '���� ��������');
      ora_excel.set_cell_value('C', '�����������');
      ora_excel.set_cell_value('D', '��������');
      ora_excel.set_cell_value('E', '��� ��������������');
      ora_excel.set_cell_value('F', '�����');
      ora_excel.set_cell_value('G', '�����');
      ora_excel.set_cell_value('H', '��� �����');
      ora_excel.set_cell_value('I', '���� ������');
      ora_excel.set_cell_value('J', '��� ������');
      ora_excel.set_cell_value('K', '�����');
      ora_excel.set_cell_value('L', '����');
      ora_excel.set_cell_value('M', '��� ������ �����');
      ora_excel.set_cell_value('N', '����� �����');
      ora_excel.set_cell_value('O', '�������');
      ora_excel.set_cell_value('P', '������ �������� ������');
      ora_excel.set_cell_value('Q', '���� ����������');
      ora_excel.set_cell_value('R', '�����');
      ora_excel.set_cell_value('S', '���������');
      ora_excel.set_cell_value('T', '���');
    
      --�������� ����
      FOR cur IN (SELECT * FROM v_rep_finmon_fatf_list)
      LOOP
        ora_excel.add_row;
        ora_excel.set_cell_value('A', cur."���");
        ora_excel.set_cell_value('B', cur."���� ��������");
        ora_excel.set_cell_value('C', cur."�����������");
        ora_excel.set_cell_value('D', cur."��������");
        ora_excel.set_cell_value('E', cur."��� ��������������");
        ora_excel.set_cell_value('F', cur."�����");
        ora_excel.set_cell_value('G', cur."�����");
        ora_excel.set_cell_value('H', cur."��� �����");
        ora_excel.set_cell_value('I', cur."���� ������");
        ora_excel.set_cell_value('J', cur."��� ������");
        ora_excel.set_cell_value('K', cur."�����");
        ora_excel.set_cell_value('L', cur."����");
        ora_excel.set_cell_value('M', cur."��� ������ �����");
        ora_excel.set_cell_value('N', cur."����� �����");
        ora_excel.set_cell_value('O', cur."�������");
        ora_excel.set_cell_value('P', cur."������ �������� ������");
        ora_excel.set_cell_value('Q', cur."���� ����������");
        ora_excel.set_cell_value('R', cur."�����");
        ora_excel.set_cell_value('S', cur."���������");
        ora_excel.set_cell_value('T', cur."���");
      END LOOP;
    
      ora_excel.save_to_blob(par_file);
    END make_file_report;
  
  BEGIN
    -- ��������
    v_files.extend(1);
    v_files(1).v_file_type := 'application/excel';
    v_files(1).v_file_name := 'rep_finmon_fatf_list' || file_ext;
  
    make_file_report(par_file => v_files(1).v_file);
    v_email_message.extend(1);
    v_email_message(v_email_message.last).recipients := par_control_email;
    v_email_message(v_email_message.last).text := c_message;
    v_email_message(v_email_message.last).subject := '�������� �� ������ ������� ����';
    v_email_message(v_email_message.last).attachment := v_files;
  
    --���������� ������ �� ������ ��������� �������
    FOR v_i IN v_email_message.first .. v_email_message.last
    LOOP
      pkg_email.send_mail_with_attachment(par_to         => v_email_message(v_i).recipients
                                         ,par_cc         => par_control_email_cc
                                         ,par_subject    => v_email_message(v_i).subject
                                         ,par_text       => v_email_message(v_i).text
                                         ,par_attachment => v_email_message(v_i).attachment);
    END LOOP;
    dbms_lob.freetemporary(v_files(1).v_file);
  END send_mail_rep_finmon_fatf;

  /* ������� �.�. 
  ��������� "������. �������� ������ ����"
  */
  PROCEDURE send_mail_claim_ndfl
  (
    par_claim_id ins.c_claim.c_claim_id%TYPE -- 
   ,par_email    pkg_email.t_recipients := NULL -- ����� ��� �������� ������
  ) IS
    file_ext        VARCHAR2(5) := '.xlsx';
    v_files         pkg_email.t_files := pkg_email.t_files();
    c_message       VARCHAR2(2000) := '���������� ������ <�������> �� ���� ';
    v_ids           p_pol_header.ids%TYPE;
    v_claim_num     ins.ven_c_claim_header.num%TYPE;
    v_email_message pkg_email.t_email_message := pkg_email.t_email_message();
  
    FUNCTION make_file_claim_ndfl(par_file IN OUT NOCOPY BLOB) RETURN BOOLEAN IS
      v_pol_id ins.p_policy.policy_id%TYPE;
    
      CURSOR cur_claim_ndfl IS
        SELECT ndfl.product_description
              ,ndfl.ids
              ,ndfl.pol_num
              ,ndfl.tip_dog
              ,to_char(ndfl.confirm_date, 'dd.mm.yyyy') confirm_date
              ,to_char(ndfl.end_date, 'dd.mm.yyyy hh24:mi:ss') end_date
              ,ndfl.fio_ass
              ,ndfl.id_ass
              ,ndfl.tip_ass
              ,ndfl.fio_ins
              ,ndfl.fio_recipient
              ,to_char(ndfl.event_date, 'dd.mm.yyyy') event_date
              ,ndfl.risk
              ,ndfl.id_recipient
              ,ndfl.tip_recipient
              ,ndfl.country
              ,ndfl.resident_recipient
              ,to_char(ndfl.date_of_birth, 'dd.mm.yyyy') date_of_birth
              ,ndfl.address
              ,ndfl.pasport
              ,ndfl.attorney
              ,ndfl.famaly
              ,ndfl.ins_pay
              ,ndfl.did
              ,ndfl.other
              ,ndfl.itogo
              ,ndfl.prev_paid
              ,ndfl.ins_pay_inc_ref
              ,ndfl.val
              ,ndfl.relation
          FROM ins.v_rep_damage_ndfl_email ndfl
         WHERE ndfl.c_claim_id = to_char(par_claim_id);
      v_data_row cur_claim_ndfl%ROWTYPE;
    BEGIN
      v_pol_id := pkg_claim.get_policy_by_claim_id(par_claim_id);
      IF v_pol_id IS NOT NULL
      THEN
        ora_excel.new_document;
        ora_excel.set_1900_date_system;
        ora_excel.add_sheet('���� �� ' || to_char(SYSDATE - 1, 'yyyy-mm-dd'));
        ora_excel.add_row;
        ora_excel.set_cell_value('A', '�������');
        ora_excel.set_cell_value('B', '������� IDS');
        ora_excel.set_cell_value('C', '����� ��������');
        ora_excel.set_cell_value('D'
                                ,'��� �������� (��� �������/�� ������� � ��������� �������)');
        ora_excel.set_cell_value('E', '���� ���������� �������� � ����');
        ora_excel.set_cell_value('F', '���� ��������� �������� ��������');
        ora_excel.set_cell_value('G', '������������ ���/������������');
        ora_excel.set_cell_value('H', '������������ ID ��������');
        ora_excel.set_cell_value('I'
                                ,'��� ������������ *���. ����/��. ����)');
        ora_excel.set_cell_value('J', '�������������� ���');
        ora_excel.set_cell_value('K', '���������� ���/������������');
        ora_excel.set_cell_value('L'
                                ,'���� ����������� ���������� ������');
        ora_excel.set_cell_value('M'
                                ,'�������� ���������� �����, �� �������� ������������ �������');
        ora_excel.set_cell_value('N', '���������� ID ��������');
        ora_excel.set_cell_value('O', '��� ���������� (���. ����/��. ����)');
        ora_excel.set_cell_value('P', '����������� ����������');
        ora_excel.set_cell_value('Q', '���������� ��������?');
        ora_excel.set_cell_value('R'
                                ,'���������� ������ ���������� (���� ��������)');
        ora_excel.set_cell_value('S'
                                ,'���������� ������ ���������� (����� �����������)');
        ora_excel.set_cell_value('T'
                                ,'���������� ������ ���������� (�����, ����� ��������, ����� � ��� �����)');
        ora_excel.set_cell_value('U', '������������ �� ����������');
        ora_excel.set_cell_value('V'
                                ,'����������� ����� ������������ � ����������');
        ora_excel.set_cell_value('W', '��������� �������');
        ora_excel.set_cell_value('X', '���');
        ora_excel.set_cell_value('Y', '������');
        ora_excel.set_cell_value('Z', '����� �� ��������');
        ora_excel.set_cell_value('AA'
                                ,'����� ����� ������������� ������');
        ora_excel.set_cell_value('AB'
                                ,'����� ��������� ��������� �������, ����������� �� ������ ����������������');
        ora_excel.set_cell_value('AC', '������ ��������');
        ora_excel.set_cell_value('AD'
                                ,'��� ����� �/� ���������� ������������ � ����������');
        --�������� ����
        OPEN cur_claim_ndfl;
        LOOP
          FETCH cur_claim_ndfl
            INTO v_data_row;
          EXIT WHEN cur_claim_ndfl%NOTFOUND;
          ora_excel.add_row;
          ora_excel.set_cell_value('A', v_data_row.product_description);
          ora_excel.set_cell_value('B', v_data_row.ids);
          ora_excel.set_cell_value('C', v_data_row.pol_num);
          ora_excel.set_cell_value('D', v_data_row.tip_dog);
          ora_excel.set_cell_value('E', v_data_row.confirm_date);
          ora_excel.set_cell_value('F', v_data_row.end_date);
          ora_excel.set_cell_value('G', v_data_row.fio_ass);
          ora_excel.set_cell_value('H', v_data_row.id_ass);
          ora_excel.set_cell_value('I', v_data_row.tip_ass);
          ora_excel.set_cell_value('J', v_data_row.fio_ins);
          ora_excel.set_cell_value('K', v_data_row.fio_recipient);
          ora_excel.set_cell_value('L', v_data_row.event_date);
          ora_excel.set_cell_value('M', v_data_row.risk);
          ora_excel.set_cell_value('N', v_data_row.id_recipient);
          ora_excel.set_cell_value('O', v_data_row.tip_recipient);
          ora_excel.set_cell_value('P', v_data_row.country);
          ora_excel.set_cell_value('Q', v_data_row.resident_recipient);
          ora_excel.set_cell_value('R', v_data_row.date_of_birth);
          ora_excel.set_cell_value('S', v_data_row.address);
          ora_excel.set_cell_value('T', v_data_row.pasport);
          ora_excel.set_cell_value('U', v_data_row.attorney);
          ora_excel.set_cell_value('V', v_data_row.famaly);
          ora_excel.set_cell_value('W', v_data_row.ins_pay);
          ora_excel.set_cell_value('X', v_data_row.did);
          ora_excel.set_cell_value('Y', v_data_row.other);
          ora_excel.set_cell_value('Z', v_data_row.itogo);
          ora_excel.set_cell_value('AA', v_data_row.prev_paid);
          ora_excel.set_cell_value('AB', v_data_row.ins_pay_inc_ref);
          ora_excel.set_cell_value('AC', v_data_row.val);
          ora_excel.set_cell_value('AD', v_data_row.relation);
        END LOOP;
      
        ora_excel.save_to_blob(par_file);
        RETURN cur_claim_ndfl%ROWCOUNT > 0;
      ELSE
        RETURN FALSE;
      END IF;
    END make_file_claim_ndfl;
  
  BEGIN
    v_files.extend(1);
    v_files(1).v_file_type := 'application/excel';
    v_files(1).v_file_name := '������. �������� ������ ���� �� ' || to_char(SYSDATE - 1, 'yyyy-mm-dd') ||
                              file_ext;
  
    IF make_file_claim_ndfl(par_file => v_files(1).v_file)
    THEN
      SELECT ids
            ,num
        INTO v_ids
            ,v_claim_num
        FROM c_claim            cc
            ,ven_c_claim_header ch
            ,p_policy           pp
            ,p_pol_header       ph
       WHERE ph.policy_header_id = pp.pol_header_id
         AND ch.c_claim_header_id = cc.c_claim_header_id
         AND ch.p_policy_id = pp.policy_id
         AND cc.c_claim_id = par_claim_id;
    
      v_email_message.extend(1);
      v_email_message(v_email_message.last).recipients := nvl(par_email
                                                             ,pkg_email.t_recipients('ndfl@renlife.com'));
      v_email_message(v_email_message.last).text := c_message || v_claim_num ||
                                                    ', ������ ��� ������� ���� �� ��������';
      v_email_message(v_email_message.last).subject := '������ ' || v_ids;
      v_email_message(v_email_message.last).attachment := v_files;
    
      --���������� ������ �� ������ ��������� �������
      FOR v_i IN v_email_message.first .. v_email_message.last
      LOOP
        pkg_email.send_mail_with_attachment(par_to         => v_email_message(v_i).recipients
                                           ,par_subject    => v_email_message(v_i).subject
                                           ,par_text       => v_email_message(v_i).text
                                           ,par_attachment => v_email_message(v_i).attachment);
      END LOOP;
    END IF;
    dbms_lob.freetemporary(v_files(1).v_file);
  END send_mail_claim_ndfl;

  /* ������� �.�. 
  ��������� "�����������. �������� ������ ����"
  */
  PROCEDURE send_mail_decline_ndfl
  (
    par_policy_id ins.p_policy.policy_id%TYPE -- 
   ,par_email     pkg_email.t_recipients := NULL -- ����� ��� �������� ������
  ) IS
    file_ext        VARCHAR2(5) := '.xlsx';
    v_files         pkg_email.t_files := pkg_email.t_files();
    c_message       VARCHAR2(2000) := '���������� ������ <���������. � �������> �� �������� ';
    v_ids           p_pol_header.ids%TYPE;
    v_email_message pkg_email.t_email_message := pkg_email.t_email_message();
  
    FUNCTION make_file_decline_ndfl(par_file IN OUT NOCOPY BLOB) RETURN BOOLEAN IS
      v_pol_header_id             ins.p_policy.policy_id%TYPE;
      v_amount_insurance_premiums VARCHAR2(32767);
    BEGIN
      v_pol_header_id := pkg_policy.get_policy_header_id(par_policy_id);
      IF v_pol_header_id IS NOT NULL
      THEN
        SELECT nvl2(listagg(sum_set_off_amount || ' as ' || YEAR, ',') within GROUP(ORDER BY YEAR)
                   ,',' || listagg(sum_set_off_amount || ' as ' || YEAR, ',') within
                    GROUP(ORDER BY YEAR)
                   ,'')
          INTO v_amount_insurance_premiums
          FROM (SELECT '"����� ������� � ' || extract(YEAR FROM po.list_doc_date) || ' ����"' YEAR
                      ,SUM(nvl(set_off_amount, 0)) sum_set_off_amount
                  FROM v_policy_payment_schedule ps
                      ,v_policy_payment_set_off  po
                      ,p_policy_contact          pc
                      ,t_contact_pol_role        cpr
                 WHERE ps.pol_header_id = v_pol_header_id
                   AND ps.doc_status_ref_name != '�����������'
                   AND ps.document_id = po.main_doc_id
                   AND po.list_doc_date > to_date('31/12/2014', 'dd/mm/yyyy')
                   AND po.doc_status_ref_name != '�����������'
                   AND ps.policy_id = pc.policy_id
                   AND cpr.id = pc.contact_policy_role_id
                   AND cpr.brief = '������������'
                   AND ((pc.contact_id = ps.contact_id) OR
                       (fn_check_double_contact(pc.contact_id, ps.contact_id) = 1))
                   AND pc.contact_id IN (SELECT MAX(ap.contact_id) keep(dense_rank FIRST ORDER BY ap.payment_id DESC NULLS LAST)
                                  FROM ven_ac_payment   ap
                                      ,doc_doc          dd
                                      ,ac_payment_templ apt
                                      ,doc_templ        dt
                                 WHERE ap.payment_id = dd.child_id
                                   AND ap.payment_templ_id = apt.payment_templ_id
                                   AND apt.brief = 'PAYREQ'
                                   AND ap.doc_templ_id = dt.doc_templ_id
                                   AND dt.brief = 'PAYREQ'
                                   AND dd.parent_id = par_policy_id /* policy_id ������ "���������. ��������� ��������"*/
                                )
                 GROUP BY '"����� ������� � ' || extract(YEAR FROM po.list_doc_date) || ' ����"'
                 ORDER BY YEAR);
      
        ora_excel.new_document;
        ora_excel.set_1900_date_system;
        ora_excel.add_sheet('���� �� ' || to_char(SYSDATE - 1, 'yyyy-mm-dd'));
        ora_excel.query_to_sheet(query             => 'SELECT quit."������� IDS"
       ,quit."����� ��������"
       ,quit."���� ��� ��� � ����"
       ,quit."������������ ���/������������"
       ,SUM(quit."������������ ID ��������") "������������ ID ��������"
       ,quit."��� �����(���.����/��.����)"
       ,quit."���������� ���/����"
       ,quit."���������� ID ��������"
       ,quit."��� �����(���.����/��.����)"
       ,quit."����������� ����������"
       ,quit."���������� ��������?"
       ,quit."����.������(���� ��������)"
       ,quit."���������� ������"
       ,quit."����.������(����� �����������)"
       ,quit."������������ �� ����������"
       ,SUM(quit."�������� �����") "�������� �����"
       ,SUM(quit."������. �����") "������. �����"
       ,SUM(quit."������� ���. ������") "������� ���. ������"
       ,quit."������"
       ,SUM(quit."����� �� ��������") "����� �� ��������"
       ,quit."������ ��������"             
       ,quit."���/���"' ||
                                                      v_amount_insurance_premiums ||
                                                      'FROM ins.v_rep_quit_to_pay quit
 WHERE quit.policy_header_id = ' ||
                                                      to_char(v_pol_header_id) || '
 GROUP BY quit."������"
          ,quit."����� ��������"
          ,quit."������������ ���/������������"
          ,quit."������ ��������"
          ,quit."����.������(����� �����������)"
          ,quit."���������� ������"
          ,quit."��� �����(���.����/��.����)"
          ,quit."���������� ���/����"
          ,quit."��� �����(���.����/��.����)"
          ,quit."����������� ����������"
          ,quit."���������� ��������?"
          ,quit."����.������(���� ��������)"
          ,quit."������� IDS"
          ,quit."���������� ID ��������"
          ,quit."������������ �� ����������"
          ,quit."���� ��� ��� � ����"
          ,quit."���/���"'
                                ,show_column_names => TRUE);
        ora_excel.save_to_blob(par_file);
        RETURN TRUE;
      ELSE
        RETURN FALSE;
      END IF;
    END make_file_decline_ndfl;
  
  BEGIN
    v_files.extend(1);
    v_files(1).v_file_type := 'application/excel';
  
    IF make_file_decline_ndfl(par_file => v_files(1).v_file)
    THEN
    
      SELECT ph.ids
        INTO v_ids
        FROM p_policy     pp
            ,p_pol_header ph
       WHERE ph.policy_header_id = pp.pol_header_id
         AND pp.policy_id = par_policy_id;
      v_files(1).v_file_name := '����������� ' || v_ids || '. �������� ������ ���� �� ' ||
                                to_char(SYSDATE - 1, 'yyyy-mm-dd') || file_ext;
      -- �������� �� ������, ��� IDS ���� ������
      v_email_message.extend(1);
      v_email_message(v_email_message.last).recipients := nvl(par_email
                                                             ,pkg_email.t_recipients('ndfl@renlife.com'));
      v_email_message(v_email_message.last).text := c_message || v_ids ||
                                                    ', ������ ��� ������� ���� �� ��������';
      v_email_message(v_email_message.last).subject := '����������� ' || v_ids;
      v_email_message(v_email_message.last).attachment := v_files;
    
      --���������� ������ �� ������ ��������� �������
      FOR v_i IN v_email_message.first .. v_email_message.last
      LOOP
        pkg_email.send_mail_with_attachment(par_to         => v_email_message(v_i).recipients
                                           ,par_subject    => v_email_message(v_i).subject
                                           ,par_text       => v_email_message(v_i).text
                                           ,par_attachment => v_email_message(v_i).attachment);
      END LOOP;
    END IF;
    dbms_lob.freetemporary(v_files(1).v_file);
  END send_mail_decline_ndfl;

  /*
    ��������� �.
    399852 �������� �������� �������� � �������� mpos. Job.
  */

  PROCEDURE send_mail_writeoff_control_job IS
    v_control_email     pkg_email.t_recipients := pkg_email.t_recipients();
    v_control_email_cc  pkg_email.t_recipients := pkg_email.t_recipients();
  BEGIN
    -- ���������� ������ �������
    IF ins.is_test_server = 0
    THEN
      FOR rec IN (SELECT 'Mariya.Chistova@Renlife.com' email
                    FROM dual
                  UNION
                  SELECT 'client@Renlife.com'
                    FROM dual
                  UNION
                  SELECT 'Marina.Ivacheva@Renlife.com'
                    FROM dual
                  UNION
                  SELECT 'Mariya.Hristoforova@Renlife.com'
                    FROM dual
                  UNION
                  SELECT 'roo_corpbox@Renlife.com'
                    FROM dual
                  UNION
                  SELECT 'DSFDirectors@Renlife.com'
                    FROM dual
                  UNION
                  SELECT 'broker@renlife.com'
                    FROM dual)
      LOOP
        v_control_email.extend(1);
        v_control_email(v_control_email.last) := rec.email;
      END LOOP;
    ELSE
      v_control_email.extend(1);
      v_control_email(v_control_email.last) := 'Marina.Ivacheva@Renlife.com';
      v_control_email.extend(1);
      v_control_email(v_control_email.last) := 'Yuriy.Grigoryev@Renlife.com';
    END IF;
  
    --���� ��� �� ������ ������.
    IF v_control_email IS empty
    THEN
      raise_application_error('-20000'
                             ,'�� ������� �� ������ ������ ��� ��������. ' || SQLERRM);
    END IF;
  
    send_mail_rep_acq_recurrent(par_control_email => v_control_email); -- �������� ��������
    send_mail_mpos_paym_not_payed(par_control_email => v_control_email); -- �������� mPos

  END send_mail_writeoff_control_job;

  /*
    ��������� �.
    399852 �������� �������� ��������. ������������ ������ + �������� ��������
  */
  PROCEDURE send_mail_rep_acq_recurrent
  (
    par_control_email    pkg_email.t_recipients -- ������ ��� �������� ������
   ,par_control_email_cc pkg_email.t_recipients := NULL -- ������ ��� �������� ����� ������
  ) IS
    file_ext        VARCHAR2(5) := '.xlsx';
    v_files         pkg_email.t_files := pkg_email.t_files();
    c_message       VARCHAR2(2000) := '������ ����! �� �������� ����� "������ �������� ������������ ��������" c ' ||
                                      to_char(SYSDATE - 1, 'dd.mm.yyyy') || ' �� ' ||
                                      to_char(SYSDATE, 'dd.mm.yyyy') || '.';
    v_email_message pkg_email.t_email_message := pkg_email.t_email_message();
    v_is_test       VARCHAR2(10) := NULL; -- ��� �������� ����� � �������� "... ����!" � ������ �������� ��������
    --���������� �����
    PROCEDURE make_file_report(par_file IN OUT NOCOPY BLOB) IS
    BEGIN
      --�������� ���������
      ora_excel.new_document;
      ora_excel.set_1900_date_system;
      ora_excel.add_sheet('C������� ������������ ��������');
      ora_excel.query_to_sheet('SELECT * FROM ins.V_REP_ACQ_RECURRENT where "���� � ����� ����������" between trunc(sysdate)-1 and trunc(sysdate)-interval ''1'' second');
      ora_excel.save_to_blob(par_file);
    END make_file_report;
  
  BEGIN
    IF ins.is_test_server = 1
    THEN
      v_is_test := ' ����!';
    END IF;
    -- ��������
    v_files.extend(1);
    v_files(1).v_file_type := 'application/excel';
    v_files(1).v_file_name := 'rep_acq_recurrent' || file_ext;
  
    make_file_report(par_file => v_files(1).v_file);
  
    --���������� ������ �� ������ ��������� �������
      pkg_email.send_mail_with_attachment(par_to         => par_control_email
                                         ,par_cc         => par_control_email_cc
                                         ,par_subject    => '������ �������� ������������ ��������' ||
                                                     v_is_test
                                         ,par_text       => c_message
                                         ,par_attachment => v_files);
                                         
    dbms_lob.freetemporary(v_files(1).v_file);
  
  END send_mail_rep_acq_recurrent;

  /*
    ��������� �.
    399986 �������� �������� mpos. ������������ ������ + �������� ��������
  */
  PROCEDURE send_mail_mpos_paym_not_payed
  (
    par_control_email    pkg_email.t_recipients -- ������ ��� �������� ������
   ,par_control_email_cc pkg_email.t_recipients := NULL -- ������ ��� �������� ����� ������
  ) IS
    file_ext        VARCHAR2(5) := '.xlsx';
    v_files         pkg_email.t_files := pkg_email.t_files();
    c_message       VARCHAR2(2000) := '������ ����! �� �������� ����� "���������� �������� mPos" c ' ||
                                      to_char(SYSDATE - 1, 'dd.mm.yyyy') || ' �� ' ||
                                      to_char(SYSDATE, 'dd.mm.yyyy') || '.';
    v_email_message pkg_email.t_email_message := pkg_email.t_email_message();
    v_is_test       VARCHAR2(10) := NULL; -- ��� �������� ����� � �������� "... ����!" � ������ �������� ��������
    --���������� �����
    PROCEDURE make_file_report(par_file IN OUT NOCOPY BLOB) IS
    BEGIN
      --�������� ���������
      ora_excel.new_document;
      ora_excel.set_1900_date_system;
      ora_excel.add_sheet('���������� �������� mPos');
      ora_excel.query_to_sheet('SELECT * FROM ins.V_MPOS_PAYMENT_NOT_PAYED where end_date between trunc(sysdate)-1 and trunc(sysdate)-interval ''1'' second');
      ora_excel.save_to_blob(par_file);
    END make_file_report;
  
  BEGIN
    IF ins.is_test_server = 1
    THEN
      v_is_test := ' ����!';
    END IF;
    -- ��������
    v_files.extend(1);
    v_files(1).v_file_type := 'application/excel';
    v_files(1).v_file_name := 'mpos_paym_not_payed' || file_ext;
  
    make_file_report(par_file => v_files(1).v_file);
    
    --���������� ������ �� ������ ��������� �������

      pkg_email.send_mail_with_attachment(par_to         => par_control_email
                                         ,par_cc         => par_control_email_cc
                                         ,par_subject    => '���������� �������� mPos' || v_is_test
                                         ,par_text       => c_message
                                         ,par_attachment => v_files);

    dbms_lob.freetemporary(v_files(1).v_file);
  
  END send_mail_mpos_paym_not_payed;

  /*
    ��������� �.
    408398 �������� ������ DWH_����� � ���������_������ ������_2015 ��� ����-������. Job.
  */
  PROCEDURE send_mail_nopaym_2015_cc_job IS
     v_control_email     pkg_email.t_recipients := pkg_email.t_recipients();
     v_control_email_cc  pkg_email.t_recipients := pkg_email.t_recipients();
  BEGIN
    -- ���������� ������ �������
    IF ins.is_test_server = 0
    THEN
      FOR rec IN (SELECT 'call_center_report@renlife.com' email
                    FROM dual
                 )
      LOOP
        v_control_email.extend(1);
        v_control_email(v_control_email.last) := rec.email;
      END LOOP;
    ELSE
      v_control_email.extend(1);
      v_control_email(v_control_email.last) := 'Yuriy.Grigoryev@Renlife.com';
      v_control_email.extend(1);
      v_control_email(v_control_email.last) := 'Vasiiy.Chehovskoy@Renlife.com';
    END IF;
  
    --���� ��� �� ������ ������.
    IF v_control_email IS empty
    THEN
      raise_application_error('-20000'
                             ,'�� ������� �� ������ ������ ��� ��������. ' || SQLERRM);
    END IF;
  
    send_mail_rep_nonpaym_2015_cc(par_control_email => v_control_email);

  END send_mail_nopaym_2015_cc_job;
  
  /*
    ��������� �.
    408398 �������� ������ DWH_����� � ���������_������ ������_2015 ��� ����-������. ������������ ������ + �������� ��������
  */
  PROCEDURE send_mail_rep_nonpaym_2015_cc
  (
    par_control_email    pkg_email.t_recipients -- ������ ��� �������� ������
   ,par_control_email_cc pkg_email.t_recipients := NULL -- ������ ��� �������� ����� ������
  ) IS
    file_ext        VARCHAR2(5) := '.xlsx';
    v_files         pkg_email.t_files := pkg_email.t_files();
    c_message       VARCHAR2(2000) := '������ ����! �� �������� ����� � ��������� �� ' || to_char(SYSDATE, 'dd.mm.yyyy') || '.';
    v_email_message pkg_email.t_email_message := pkg_email.t_email_message();
    v_is_test       VARCHAR2(10) := NULL; -- ��� �������� ����� � �������� "... ����!" � ������ �������� ��������
    --���������� �����
    PROCEDURE make_file_report(par_file IN OUT NOCOPY BLOB) IS
    BEGIN
      --�������� ���������
      ora_excel.new_document;
      ora_excel.set_1900_date_system;
      ora_excel.add_sheet('��������');
      ora_excel.query_to_sheet('SELECT * FROM ins.V_REP_NONPAYMENT_2015_CC');
      ora_excel.save_to_blob(par_file);
    END make_file_report;
  
  BEGIN
    IF ins.is_test_server = 1
    THEN
      v_is_test := ' ����!';
    END IF;
    -- ��������
    v_files.extend(1);
    v_files(1).v_file_type := 'application/excel';
    v_files(1).v_file_name := 'v_rep_nonpayment' || file_ext;
  
    make_file_report(par_file => v_files(1).v_file);

    --���������� ������ �� ������ ��������� �������

    pkg_email.send_mail_with_attachment(par_to         => par_control_email
                                       ,par_cc         => par_control_email_cc
                                       ,par_subject    => '����� � ���������' ||
                                                   v_is_test
                                       ,par_text       => c_message
                                       ,par_attachment => v_files);

    dbms_lob.freetemporary(v_files(1).v_file);
  END send_mail_rep_nonpaym_2015_cc;

  -- ��������� �������� ������ <�������� 115 ��> ��� ��������� ��������
  -- ������ 314488
  -- Params:  par_control_email       - ������ ������� ��� �������� ������
  --         par_control_email_cc    - ������ ������� ��� �������� ����� ������
  --         par_content_email       - �������������� ����� � ������
  PROCEDURE send_mail_rep_control_115_ppi
  (
    par_control_email    pkg_email.t_recipients -- ������ ��� �������� ������
   ,par_control_email_cc pkg_email.t_recipients := NULL -- ������ ��� �������� ����� ������
   ,par_content_email    VARCHAR2 := NULL -- �������������� ����� � ������
  ) IS
    file_ext  VARCHAR2(5) := '.xlsx';
    v_files   pkg_email.t_files := pkg_email.t_files();
    c_message VARCHAR2(2000) := '������ ����!
    �������� ��� ����� "�������� 115 �� �� ��������� ��������" �� ' ||
                                to_char(SYSDATE, 'dd.mm.yyyy') || chr(10) || par_content_email;
    --���������� �����
    PROCEDURE make_file_report(par_file IN OUT NOCOPY BLOB) IS
    BEGIN
      --�������� ���������
      ora_excel.new_document;
      ora_excel.add_sheet('�������� 115 �� �� ' || to_char(SYSDATE, 'yyyy-mm-dd'));
      --�������� �����
      ora_excel.add_row;
    
      ora_excel.set_column_width('A', 16);
      ora_excel.set_column_width('B', 42);
      ora_excel.set_column_width('C', 25);
      ora_excel.set_column_width('D', 60);
      ora_excel.set_column_width('E', 24);
      ora_excel.set_column_width('F', 36);
      ora_excel.set_column_width('G', 36);
      ora_excel.set_column_width('H', 36);
      ora_excel.set_column_width('I', 36);
      ora_excel.set_column_width('J', 36);
    
      ora_excel.set_cell_value('A', '���');
      ora_excel.set_cell_value('B', '������������ ������������');
      ora_excel.set_cell_value('C', '������� ����� �����������');
      ora_excel.set_cell_value('D', '�����');
      ora_excel.set_cell_value('E', '�����������');
      ora_excel.set_cell_value('F'
                              ,'���� ���������� ���������� �������');
      ora_excel.set_cell_value('G'
                              ,'����� ���������� ���������� �������');
      ora_excel.set_cell_value('H'
                              ,'���������� ���������� ���������� �������');
      ora_excel.set_cell_value('I'
                              ,'����� ���������� ���������� �������');
      ora_excel.set_cell_value('J', '����� ��������� ��������');
    
      --�������� ����
      FOR cur IN (SELECT *
                    FROM v_rep_ppi_600 v
                   WHERE v."����� ��������� ��������" >= 600000
                      OR v."������� ����� �����������" IS NOT NULL
                      OR v."������� ��������� � �.�. ����" IS NOT NULL
                   ORDER BY v."���� ���������� ���. �������")
      LOOP
        ora_excel.add_row;
      
        ora_excel.set_column_width('A', 16);
        ora_excel.set_column_width('B', 42);
        ora_excel.set_column_width('C', 25);
        ora_excel.set_column_width('D', 60);
        ora_excel.set_column_width('E', 24);
        ora_excel.set_column_width('F', 36);
        ora_excel.set_column_width('G', 36);
        ora_excel.set_column_width('H', 36);
        ora_excel.set_column_width('I', 36);
        ora_excel.set_column_width('J', 36);
      
        ora_excel.set_cell_value('A', cur."���");
        ora_excel.set_cell_value('B', cur."������������ ������������");
        ora_excel.set_cell_value('C', cur."������� ����� �����������");
        ora_excel.set_cell_value('D', cur."�����");
        ora_excel.set_cell_value('E', cur."�����������");
        ora_excel.set_cell_value('F', cur."���� ���������� ���. �������");
        ora_excel.set_cell_value('G', cur."����� ���������� ���. �������");
        ora_excel.set_cell_value('H', cur."���������� ������.���. �������");
        ora_excel.set_cell_value('I', cur."����� ���������� ���. �������");
        ora_excel.set_cell_value('J', cur."����� ��������� ��������");
      END LOOP;
    
      ora_excel.save_to_blob(par_file);
    END make_file_report;
  
  BEGIN
    -- ��������
    v_files.extend(1);
    v_files(1).v_file_type := 'application/excel';
    v_files(1).v_file_name := 'rep_finmon_fatf_list_out' || file_ext;
  
    make_file_report(par_file => v_files(1).v_file);
  
    pkg_email.send_mail_with_attachment(par_to         => par_control_email
                                       ,par_cc         => par_control_email_cc
                                       ,par_subject    => '�������� 115 ��. ��������� �������'
                                       ,par_text       => c_message
                                       ,par_attachment => v_files);
  
    dbms_lob.freetemporary(v_files(1).v_file);
  
  END send_mail_rep_control_115_ppi;
 
END pkg_email_reports_fmb; 
/ 

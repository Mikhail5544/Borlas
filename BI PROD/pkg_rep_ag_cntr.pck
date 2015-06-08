CREATE OR REPLACE PACKAGE pkg_rep_ag_cntr IS

  -- Author  : ����� �.
  -- Created : 27.02.2015
  -- Purpose : ������ ��� ����� AG_CNTR

  /* 
    ��������� ������������ ������ "���������� � ����������� ������������� ��������"
    ��� ���� ��������� "����������� ������������� �������� � RLP" ���������� ��������
    
    399868: ���������� � ����������� ������������� �������� �������� �����
    ����� �., 27.02.2015
  */
  PROCEDURE rep_cancel_subagent_contract
  (
    par_content_type OUT VARCHAR2
   ,par_file_name    OUT VARCHAR2
   ,par_data         OUT NOCOPY BLOB
  );

  /* 
    ��������� ������������ ������ "��� ������-�������� ��������� �����������"
    ��� ���� ��������� "��� �������� �� ��� �������� � ��" ���������� ��������
    
    407277: ���������� �������� ����� ��� ���� "��� ������-�������� ��������� �����������"
    ����� �., 02.04.2015
  */
  PROCEDURE rep_policy_acceptance_act
  (
    par_content_type OUT VARCHAR2
   ,par_file_name    OUT VARCHAR2
   ,par_data         OUT NOCOPY BLOB
  );

  /* 
    ��������� ������������ ������ "��� ������ ��������� ��������� ������"
    ��� ���� ��������� "������ ��������� ������ ��� �������� � ��" ���������� ��������
    
    407342: ���������� �������� ����� ��� ���� "��� ������ ��������� ��������� ������"
    ����� �., 06.04.2015
  */
  PROCEDURE rep_agent_reconciliation_act
  (
    par_content_type OUT VARCHAR2
   ,par_file_name    OUT VARCHAR2
   ,par_data         OUT NOCOPY BLOB
  );

  /* 
    ��������� ������������ ������ "��� �������� ��������� �����������", �������
    ����������� �� ����� TRANS_AGENT_DOC
    
    415449: ���������� �������� ����� "��� �������� ��"
    ����� �., 21.05.2015
  */
  PROCEDURE rep_policy_transfer_act_cp
  (
    par_content_type OUT VARCHAR2
   ,par_file_name    OUT VARCHAR2
   ,par_data         OUT NOCOPY BLOB
  );

  /* 
    ��������� ������������ ������ "��� ������ ��������� ��������� ����", �������
    ����������� �� ����� AGENCY_JOURNAL
    
    415345: ��� ������ ��������� ��������� ����
    ����� �., 22.05.2015
  */
  PROCEDURE rep_agent_structure_verify_act
  (
    par_content_type OUT VARCHAR2
   ,par_file_name    OUT VARCHAR2
   ,par_data         OUT NOCOPY BLOB
  );
END pkg_rep_ag_cntr;
/
CREATE OR REPLACE PACKAGE BODY pkg_rep_ag_cntr IS

  /* 
    ��������� ������������ ������ "���������� � ����������� ������������� ��������"
    ��� ���� ��������� "����������� ������������� �������� � RLP" ���������� ��������
    
    399868: ���������� � ����������� ������������� �������� �������� �����
    ����� �., 27.02.2015
  */
  PROCEDURE rep_cancel_subagent_contract
  (
    par_content_type OUT VARCHAR2
   ,par_file_name    OUT VARCHAR2
   ,par_data         OUT NOCOPY BLOB
  ) IS
    v_ag_contract_header_id ag_contract_header.ag_contract_header_id%TYPE;
    v_orig_category_name    ag_category_agent.category_name%TYPE;
    v_general_category      VARCHAR2(500);
    v_category_name         ag_category_agent.category_name%TYPE;
    v_category_tvirot       VARCHAR2(500);
    v_ag_contract_number    document.num%TYPE;
    v_doc_date              VARCHAR2(50);
    v_decline_rlp_doc_date  VARCHAR2(100);
    v_agent_name            contact.obj_name_orig%TYPE;
    v_passport_serial_nr    cn_contact_ident.serial_nr%TYPE;
    v_passport_nr           cn_contact_ident.id_value%TYPE;
    v_passport_issue_date   cn_contact_ident.issue_date%TYPE;
    v_place_of_issue        cn_contact_ident.place_of_issue%TYPE;
    v_reg_address           cn_address.name%TYPE;
    v_inn                   cn_contact_ident.id_value%TYPE;
    v_pension_nr            cn_contact_ident.id_value%TYPE;
  
    v_str VARCHAR(32767);
  BEGIN
    v_ag_contract_header_id := to_number(repcore.get_context('P_CH_ID'));
  
    BEGIN
      SELECT decode(ac.contract_type_name
                   ,'������������ �������'
                   ,NULL
                   ,ac.category_name) category_name
            ,ac.category_name
            ,ac.num ag_contract_number
            ,regexp_replace(pkg_utils.date2genitive_case((SELECT MAX(doc_date)
                                                           FROM v_agn_documents
                                                          WHERE ag_contract_header_id =
                                                                ac.ag_contract_header_id
                                                            AND doc_type IN
                                                                ('���������� ��'
                                                                ,'��������� ���������'
                                                                ,'��������� ������ ������'
                                                                ,'���������� ������������� �������� � RLP')))
                           ,'(���)$'
                           ,'.') doc_date
            ,regexp_replace(pkg_utils.date2genitive_case((SELECT MAX(doc_date)
                                                           FROM v_agn_documents
                                                          WHERE ag_contract_header_id =
                                                                ac.ag_contract_header_id
                                                            AND doc_type IN
                                                                ('����������� ������������� �������� � RLP')))
                           ,'(���)$'
                           ,'.') decline_rlp_doc_date
            ,ac.agent_name
            ,ci_passport.serial_nr passport_serial_nr
            ,ci_passport.id_value passport_nr
            ,ci_passport.issue_date
            ,ci_passport.place_of_issue
            ,pkg_contact_rep_utils.get_address_by_mask(pkg_contact_rep_utils.get_last_active_address_id(c.contact_id
                                                                                                       ,'CONST')
                                                      ,'<#ADDRESS_NAME>') reg_address
            ,(SELECT MAX(id_value) keep(dense_rank FIRST ORDER BY ci.is_used DESC NULLS LAST)
                FROM cn_contact_ident ci
               WHERE ci.contact_id = c.contact_id
                 AND ci.id_type = 1) inn
            ,(SELECT MAX(id_value) keep(dense_rank FIRST ORDER BY ci.is_used DESC NULLS LAST)
                FROM cn_contact_ident ci
               WHERE ci.contact_id = c.contact_id
                 AND ci.id_type = 104) pension_nr
        INTO v_category_name
            ,v_orig_category_name
            ,v_ag_contract_number
            ,v_doc_date
            ,v_decline_rlp_doc_date
            ,v_agent_name
            ,v_passport_serial_nr
            ,v_passport_nr
            ,v_passport_issue_date
            ,v_place_of_issue
            ,v_reg_address
            ,v_inn
            ,v_pension_nr
        FROM v_agn_contract   ac
            ,contact          c
            ,cn_contact_ident ci_passport
       WHERE ci_passport.table_id(+) =
             pkg_contact_rep_utils.get_last_doc_by_type(c.contact_id, 'PASS_RF')
         AND ac.ag_contract_header_id = v_ag_contract_header_id
         AND trunc(SYSDATE) BETWEEN ac.ac_date_begin AND ac.ac_date_end
         AND c.contact_id = ac.agent_id;
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20001
                               ,'�� ������� ����� ���������� �� ��������������: ag_contract_header_id');
    END;
  
    IF v_orig_category_name = '�����'
    THEN
      v_general_category := '��������';
      v_category_tvirot  := '����������';
      v_category_name    := NULL;
    ELSIF v_orig_category_name LIKE '��������%'
    THEN
      v_general_category := '��������';
      v_category_tvirot  := '����������';
      v_category_name    := '�������� ';
    ELSIF v_orig_category_name = '��������'
    THEN
      v_general_category := '��������';
      v_category_tvirot  := '����������';
      v_category_name    := '�������� ';
    END IF;
  
    pkg_rep_plpdf.init(par_default_font_size => 11);
    pkg_rep_plpdf.set_font(par_size => 11, par_style => pkg_rep_plpdf.gc_style_bold);
  
    plpdf.printcell(p_txt => '����������', p_align => 'C', p_h => -1, p_ln => 1);
  
    plpdf.printmultilinecell(p_ln => 1, p_align => 'J', p_clipping => 0, p_h => 3, p_txt => '');
  
    plpdf.printmultilinecell(p_txt   => '� ����������� C������������ �������� (�������������) ��������� ' ||
                                        v_category_name || 'DSF N ' || v_ag_contract_number || ' �� ' ||
                                        v_doc_date
                            ,p_align => 'C'
                            ,p_h     => -1
                            ,p_ln    => 1);
  
    pkg_rep_plpdf.set_font(par_style => pkg_rep_plpdf.gc_style_regular);
    plpdf.printmultilinecell(p_ln => 1, p_align => 'J', p_clipping => 0, p_h => 3, p_txt => '');
		
    plpdf.printcell(p_txt => '�. ������', p_align => 'L', p_clipping => 0, p_h => 3, p_ln => 0);
                            
    plpdf.printcell(p_txt      => v_decline_rlp_doc_date
                            ,p_ln       => 1
                            ,p_align    => 'R'
                   ,p_w        => plpdf.getpagespace
                            ,p_clipping => 0
                            ,p_h        => 3);
    plpdf.printmultilinecell(p_ln => 1, p_align => 'J', p_clipping => 0, p_h => 3, p_txt => '');
  
    v_str := '��� �������� ��������, ��������� � ���������� ������, � ���� ������������ ��������� ��������� ���� ���������, ������������ �� ��������� ������, � ����� �������, � ' ||
             v_agent_name || ', ���������(��) � ���������� �' || v_general_category ||
             '�, � ������ �������, ������ ��������� ���������, ��������� ��������� ���������� � ����������� ������������� �������� (�������������) ��������� ' ||
             v_category_name || ' DSF �� ' || v_doc_date || ' N ' || v_ag_contract_number ||
             ' ����� ���������� � ���������: ';
    plpdf.printmultilinecell(p_txt => v_str, p_align => 'J', p_h => -1, p_ln => 1);
  
    v_str := '1. ����� � ' || v_general_category ||
             ' ������������ ����������� ������������ ������� (�������������) ��������� ' ||
             v_category_name || 'DSF �� ' || v_doc_date || ' N ' || v_ag_contract_number ||
             ' ����� ������� � ' || v_category_tvirot || ' ' || v_decline_rlp_doc_date;
    plpdf.printmultilinecell(p_txt => v_str, p_align => 'J', p_h => -1, p_ln => 1);
    v_str := '2. ����� ��������� �������� ��� �������������, ��������������� ������������ ��������� (�������������) ��������� ' ||
             v_category_name || 'DSF.';
    plpdf.printmultilinecell(p_txt => v_str, p_align => 'J', p_h => -1, p_ln => 1);
    v_str := '3. ������� ��������� ���� � ����� �� �����.';
    plpdf.printmultilinecell(p_txt => v_str, p_align => 'J', p_h => -1, p_ln => 1);
    v_str := '4. ��������� ���������� ���������� � ���� �����������, ������� ������ ����������� ����, �� ������ ��� ������ �� ������.';
    plpdf.printmultilinecell(p_txt => v_str, p_align => 'J', p_h => -1, p_ln => 1);
  
    pkg_rep_plpdf.set_font(par_style => pkg_rep_plpdf.gc_style_bold);
  
    plpdf.printmultilinecell(p_txt => NULL, p_h => -1, p_ln => 1);
    plpdf.printmultilinecell(p_txt => v_general_category, p_align => 'J', p_h => -1, p_ln => 1);
    pkg_rep_plpdf.set_font(par_style => pkg_rep_plpdf.gc_style_regular);
    plpdf.printmultilinecell(p_txt => '��� ' || v_agent_name, p_align => 'J', p_h => -1, p_ln => 1);
    plpdf.printmultilinecell(p_txt   => '�������� � ���������, �������������� ��������:'
                            ,p_align => 'J'
                            ,p_h     => -1
                            ,p_ln    => 1);
    plpdf.printmultilinecell(p_txt   => '��� ��������� - ������� ���������� ���������� ��������� '
                            ,p_align => 'J'
                            ,p_h     => -1
                            ,p_ln    => 1);
    plpdf.printmultilinecell(p_txt   => '����� ' || v_passport_serial_nr || ' ����� ' || v_passport_nr
                            ,p_align => 'J'
                            ,p_h     => -1
                            ,p_ln    => 1);
    plpdf.printmultilinecell(p_txt   => '���� ������: ' ||
                                        to_char(v_passport_issue_date, 'dd.mm.yyyy') || ' �.'
                            ,p_align => 'J'
                            ,p_h     => -1
                            ,p_ln    => 1);
    plpdf.printmultilinecell(p_txt   => '��� �����: ' || v_place_of_issue
                            ,p_align => 'J'
                            ,p_h     => -1
                            ,p_ln    => 1);
  
    plpdf.printmultilinecell(p_txt   => '����� ����� �����������: ' || v_reg_address
                            ,p_align => 'J'
                            ,p_h     => -1
                            ,p_ln    => 1);
  
    plpdf.printmultilinecell(p_txt => '���: ' || v_inn, p_align => 'J', p_h => -1, p_ln => 1);
  
    plpdf.printmultilinecell(p_txt   => '����� ���������� ������������� ���������������� ����������� �����������: ' ||
                                        v_pension_nr
                            ,p_align => 'J'
                            ,p_h     => -1
                            ,p_ln    => 1);
  
    pkg_rep_plpdf.set_font(par_style => pkg_rep_plpdf.gc_style_bold);
  
    plpdf.printmultilinecell(p_txt => NULL, p_h => -1, p_ln => 1);
    plpdf.printmultilinecell(p_txt => '�����', p_align => 'J', p_h => -1, p_ln => 1);
    pkg_rep_plpdf.set_font(par_style => pkg_rep_plpdf.gc_style_regular);
  
    plpdf.printmultilinecell(p_txt   => '��� �������� ��������' || chr(13) ||
                                        '115114, �. ������, ������������ ����������, ��� 7, ���.  22.' ||
                                        chr(13) ||
                                        '�/� 40701810800001410925 � ���� �� "�������������� " �. ������;' ||
                                        chr(13) || '�/� 30101810200000000700' || chr(13) ||
                                        '��� 044525700, ��� 7725520440'
                            ,p_align => 'J'
                            ,p_h     => -1
                            ,p_ln    => 1);
  
    plpdf.printmultilinecell(p_txt => NULL, p_h => -1, p_ln => 1);
    plpdf.printmultilinecell(p_txt => NULL, p_h => -1, p_ln => 1);
  
    plpdf.printcell(p_txt => '�����', p_w => 110, p_h => -1, p_ln => 0);
    plpdf.printcell(p_txt => v_general_category, p_h => -1, p_ln => 1);
  
    plpdf.printmultilinecell(p_txt => NULL, p_h => -1, p_ln => 1);
    plpdf.printcell(p_txt => '___________________/', p_w => 110, p_h => -1, p_ln => 0);
    plpdf.printcell(p_txt => '___________________/', p_h => -1, p_ln => 1);
  
    plpdf.printmultilinecell(p_txt => NULL, p_h => -1, p_ln => 1);
    plpdf.printcell(p_txt => '��������� ���������� �� ���� �������(-�): __________________________/_________________/'
                   ,p_h   => -1
                   ,p_ln  => 1);
  
    plpdf.printmultilinecell(p_txt => NULL, p_h => -1, p_ln => 1);
  
    plpdf.printcell(p_txt => '�_____�__________________20___�. ', p_h => -1, p_ln => 1);
  
    plpdf.senddoc(p_blob => par_data);
    par_file_name    := 'rep_cancel_subagent_contract_' || v_ag_contract_number || '.pdf';
    par_content_type := pkg_rep_plpdf.gc_pdf_content_type;
  END rep_cancel_subagent_contract;

  /* 
    ��������� ������������ ������ "��� ������-�������� ��������� �����������"
    ��� ���� ��������� "��� �������� �� ��� �������� � ��" ���������� ��������
    
    407277: ���������� �������� ����� ��� ���� "��� ������-�������� ��������� �����������"
    ����� �., 02.04.2015
  */
  PROCEDURE rep_policy_acceptance_act
  (
    par_content_type OUT VARCHAR2
   ,par_file_name    OUT VARCHAR2
   ,par_data         OUT NOCOPY BLOB
  ) IS
    v_ag_contract_header_id  ag_contract_header.ag_contract_header_id%TYPE;
    v_ag_documents_id        v_agn_documents.ag_documents_id%TYPE;
    v_ag_contract_number     document.num%TYPE;
    v_doc_date               VARCHAR2(50);
    v_d_doc_date             DATE;
    v_agency                 v_agn_contract.name%TYPE;
    v_agent_name             contact.dative%TYPE;
    v_agent_category         ag_category_agent.brief%TYPE;
    v_str                    VARCHAR(32767);
    v_agent                  VARCHAR(200);
    v_agent_num              VARCHAR(200);
    v_agent_sales_channel    VARCHAR(200);
    v_agent_agent_name       VARCHAR(200);
    v_manager                VARCHAR(200);
    v_manager_num            VARCHAR(200);
    v_manager_sales_channel  VARCHAR(200);
    v_manager_agent_name     VARCHAR(200);
    v_director               VARCHAR(200);
    v_director_num           VARCHAR(200);
    v_director_sales_channel VARCHAR(200);
    v_director_agent_name    VARCHAR(200);
  
  BEGIN
    v_ag_contract_header_id := to_number(repcore.get_context('P_CH_ID'));
    v_ag_documents_id       := to_number(repcore.get_context('P_DOCUMENT_ID'));
  
    BEGIN
      SELECT pkg_utils.date2genitive_case(ad.doc_date)
            ,ad.doc_date
        INTO v_doc_date
            ,v_d_doc_date
        FROM v_agn_documents ad
       WHERE ad.ag_documents_id = v_ag_documents_id;
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20001
                               ,'�� ������� ����� ���������� �� ��������������: ag_documents_id');
  END;
  
    BEGIN
      SELECT ac.num    ag_contract_number
            ,ac.name   agency
            ,c.dative  agent_name
            ,aca.brief
        INTO v_ag_contract_number
            ,v_agency
            ,v_agent_name
            ,v_agent_category
        FROM v_agn_contract    ac
            ,contact           c
            ,ag_contract       a
            ,ag_category_agent aca
       WHERE ac.agent_id = c.contact_id
         AND ac.ag_contract_header_id = v_ag_contract_header_id
         AND ac.ag_contract_id = a.ag_contract_id
         AND a.category_id = aca.ag_category_agent_id
         AND trunc(v_d_doc_date) BETWEEN ac.ac_date_begin AND ac.ac_date_end;
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20001
                               ,'�� ������� ����� ���������� �� ��������������: ag_contract_header_id');
    END;
  
    FOR cur
       IN (SELECT agent_category,
                  num,
                  sales_channel,
                  agent_name
             FROM (    SELECT LEVEL,
                              aca.brief agent_category,
                              DECODE (aca.brief,
                                      'AG', ach.num,
                                      ac.personnel_number)
                                 num,
                              NVL (ac_ch.description, ach_ch.description)
                                 sales_channel,
                              c.obj_name_orig agent_name,
                              ROW_NUMBER ()
                              OVER (
                                 PARTITION BY CASE WHEN aca.brief = 'AG' THEN 1
                                                   WHEN aca.brief = 'MN' THEN 2
                                                   WHEN aca.brief IN ('DR', 'DR2') THEN 3
                                              END
                                 ORDER BY LEVEL)  rn
                         FROM  ag_agent_tree aat
                              ,ven_ag_contract_header ach
                              ,ag_contract ac
                              ,contact c
                              ,ag_category_agent aca
                              ,t_sales_channel ach_ch
                              ,t_sales_channel ac_ch
                        WHERE     aat.ag_contract_header_id = ach.ag_contract_header_id
                              AND ach.ag_contract_header_id = ac.contract_id
                              AND ach.agent_id = c.contact_id
                              AND ac.category_id = aca.ag_category_agent_id
                              AND ach_ch.id = ach.t_sales_channel_id
                              AND ac.ag_sales_chn_id = ac_ch.id
                              AND TRUNC (v_d_doc_date) BETWEEN ach.date_begin AND ach.date_break
                              AND TRUNC (v_d_doc_date) BETWEEN ac.date_begin AND ac.date_end
                              AND TRUNC (v_d_doc_date) BETWEEN aat.date_begin AND aat.date_end
                              AND aca.brief IN ('AG', 'MN', 'DR', 'DR2')
                              AND LEVEL <= 3
                   START WITH     aat.ag_contract_header_id = v_ag_contract_header_id
                              AND TRUNC (v_d_doc_date) BETWEEN aat.date_begin AND aat.date_end
                              AND TRUNC (v_d_doc_date) BETWEEN ac.date_begin AND ac.date_end
                              AND TRUNC (v_d_doc_date) BETWEEN aat.date_begin AND aat.date_end
                   CONNECT BY PRIOR aat.ag_parent_header_id = aat.ag_contract_header_id
                                AND TRUNC (v_d_doc_date) BETWEEN ach.date_begin AND ach.date_break
                                AND TRUNC (v_d_doc_date) BETWEEN ac.date_begin AND ac.date_end
                                AND TRUNC (v_d_doc_date) BETWEEN aat.date_begin AND aat.date_end)
            WHERE rn = 1)
    LOOP
    CASE
      WHEN cur.agent_category = 'AG' THEN
        v_agent               := '�����';
        v_agent_num           := to_char(cur.num);
        v_agent_sales_channel := to_char(cur.sales_channel);
        v_agent_agent_name    := to_char(cur.agent_name);
      WHEN cur.agent_category = 'MN' THEN
        v_manager               := '��������';
        v_manager_num                 := to_char(cur.num);
        v_manager_sales_channel := to_char(cur.sales_channel);
        v_manager_agent_name    := to_char(cur.agent_name);
      WHEN cur.agent_category IN ('DR', 'DR2') THEN
        v_director               := '��������';
        v_director_num                 := to_char(cur.num);
        v_director_sales_channel := to_char(cur.sales_channel);
        v_director_agent_name    := to_char(cur.agent_name);
    END CASE;
    END LOOP;
  
    plpdf.init(p_orientation => 'L');
    pkg_rep_plpdf.font_init;
    plpdf.setencoding(p_enc => plpdf_const.cp1251);
    plpdf.newpage;
    plpdf.setprintfont(p_family => 'Times', p_style => NULL, p_size => 11);
  
    plpdf.printcell(p_txt   => v_doc_date
                   ,p_w     => plpdf.getpagespace * 5 / 6
                   ,p_h     => -1
                   ,p_align => 'R'
                   ,p_ln    => 1);
  
    plpdf.printcell(p_txt   => '��� ������-�������� ��������� �����������'
                   ,p_h     => -1
                   ,p_align => 'C'
                   ,p_ln    => 1);
  
    plpdf.printcell(p_txt => '���������: ' || v_agency, p_h => -1, p_align => 'L', p_ln => 1);
  
    plpdf.linebreak(p_h => 3);
    plpdf.printmultilinecell(p_txt => '', p_align => 'J', p_w => 5, p_h => -1, p_ln => 0);
    v_str := '1. ��� ��� ���������� ������ � ���� ��������� �� �������� ��������� �.�., ������������ �� ��������� ������������ � 2015/138 (�����-����������) �������� ' ||
             v_agent_name || ' �������� ����������� ��� ����������� ������������.';
    plpdf.printmultilinecell(p_txt => v_str, p_align => 'J', p_h => -1, p_ln => 1);
  
    -- ������� 1
    plpdf.linebreak(p_h => 3);
    plpdf.printcell(p_txt   => '������� 1. ��������� ��������� ������'
                   ,p_h     => -1
                   ,p_align => 'L'
                   ,p_ln    => 1);
    plpdf.linebreak(p_h => 3);
    plpdf.setprintfont(p_size => 8);
    plpdf.printcell(p_txt    => '���������'
                   ,p_w      => 30
                   ,p_h      => 15
                   ,p_align  => 'C'
                   ,p_ln     => 0
                   ,p_border => 1);
    plpdf.printcell(p_txt    => '������ �� ������/���������/���������, �� �������� ���������� �������� �����������'
                   ,p_w      => 150
                   ,p_h      => 5
                   ,p_align  => 'C'
                   ,p_ln     => 1
                   ,p_border => 1);
    plpdf.printmultilinecell(p_txt => '', p_align => 'J', p_w => 30, p_h => 10, p_ln => 0);
    plpdf.printmultilinecell(p_txt    => '�� ������/��������� ����� ���������, ���������'
                            ,p_w      => 40
                            ,p_h      => 5
                            ,p_align  => 'C'
                            ,p_ln     => 0
                            ,p_border => 1);
    plpdf.printcell(p_txt    => '��� ��������� ����'
                   ,p_w      => 30
                   ,p_h      => 10
                   ,p_align  => 'C'
                   ,p_ln     => 0
                   ,p_border => 1);
    plpdf.printcell(p_txt => '���', p_w => 80, p_h => 10, p_align => 'C', p_ln => 1, p_border => 1);
    plpdf.printcell(p_txt    => '�����'
                   ,p_w      => 30
                   ,p_h      => 5
                   ,p_align  => 'C'
                   ,p_ln     => 0
                   ,p_border => 1);
    plpdf.printcell(p_txt    => v_agent_num
                   ,p_w      => 40
                   ,p_h      => 5
                   ,p_align  => 'R'
                   ,p_ln     => 0
                   ,p_border => 1);
    plpdf.printcell(p_txt    => v_agent_sales_channel
                   ,p_w      => 30
                   ,p_h      => 5
                   ,p_align  => 'R'
                   ,p_ln     => 0
                   ,p_border => 1);
    plpdf.printcell(p_txt    => v_agent_agent_name
                   ,p_w      => 80
                   ,p_h      => 5
                   ,p_align  => 'R'
                   ,p_ln     => 1
                   ,p_border => 1);
    plpdf.printcell(p_txt    => '��������'
                   ,p_w      => 30
                   ,p_h      => 5
                   ,p_align  => 'C'
                   ,p_ln     => 0
                   ,p_border => 1);
    plpdf.printcell(p_txt    => v_manager_num
                   ,p_w      => 40
                   ,p_h      => 5
                   ,p_align  => 'R'
                   ,p_ln     => 0
                   ,p_border => 1);
    plpdf.printcell(p_txt    => v_manager_sales_channel
                   ,p_w      => 30
                   ,p_h      => 5
                   ,p_align  => 'R'
                   ,p_ln     => 0
                   ,p_border => 1);
    plpdf.printcell(p_txt    => v_manager_agent_name
                   ,p_w      => 80
                   ,p_h      => 5
                   ,p_align  => 'R'
                   ,p_ln     => 1
                   ,p_border => 1);
    plpdf.printcell(p_txt    => '��������'
                   ,p_w      => 30
                   ,p_h      => 5
                   ,p_align  => 'C'
                   ,p_ln     => 0
                   ,p_border => 1);
    plpdf.printcell(p_txt    => v_director_num
                   ,p_w      => 40
                   ,p_h      => 5
                   ,p_align  => 'R'
                   ,p_ln     => 0
                   ,p_border => 1);
    plpdf.printcell(p_txt    => v_director_sales_channel
                   ,p_w      => 30
                   ,p_h      => 5
                   ,p_align  => 'R'
                   ,p_ln     => 0
                   ,p_border => 1);
    plpdf.printcell(p_txt    => v_director_agent_name
                   ,p_w      => 80
                   ,p_h      => 5
                   ,p_align  => 'R'
                   ,p_ln     => 1
                   ,p_border => 1);
  
    -- ������� 2
    plpdf.setprintfont(p_size => 11);
    plpdf.linebreak(p_h => 3);
    plpdf.printcell(p_txt   => '������� 2. �������� �����������'
                   ,p_h     => -1
                   ,p_align => 'L'
                   ,p_ln    => 1);
    plpdf.linebreak(p_h => 3);
    plpdf.setprintfont(p_size => 8);
    plpdf.printcell(p_txt    => '� �/�'
                   ,p_w      => 15
                   ,p_h      => 5
                   ,p_align  => 'C'
                   ,p_ln     => 0
                   ,p_border => 1);
    plpdf.printcell(p_txt    => '� �������� �����������'
                   ,p_w      => 40
                   ,p_h      => 5
                   ,p_align  => 'C'
                   ,p_ln     => 0
                   ,p_border => 1);
    plpdf.printcell(p_txt    => '��� ������������'
                   ,p_w      => 80
                   ,p_h      => 5
                   ,p_align  => 'C'
                   ,p_ln     => 0
                   ,p_border => 1);
    plpdf.printcell(p_txt    => '���� �������� �����������'
                   ,p_w      => 40
                   ,p_h      => 5
                   ,p_align  => 'C'
                   ,p_ln     => 1
                   ,p_border => 1);
  
    FOR cur IN (SELECT rownum row_num
                      ,pol_num
                      ,insurer_name
                      ,start_date
                  FROM (SELECT p.pol_num
                              ,c.obj_name_orig insurer_name
                              ,p.start_date
                          FROM p_policy_agent_doc pad
                              ,p_pol_header       ph
                              ,p_policy           p
                              ,p_policy_contact   pc
                              ,t_contact_pol_role cpr
                              ,contact            c
                         WHERE pad.policy_header_id = ph.policy_header_id
                           AND ph.policy_id = p.policy_id
                           AND p.policy_id = pc.policy_id
                           AND pc.contact_policy_role_id = cpr.id
                           AND cpr.brief = '������������'
                           AND pc.contact_id = c.contact_id
                              -- �������� ������� ��������� "�������� - ����� �� ��������" �� ���� ���� �������� ������, 
                              -- ������� ��������� ������� �������
                              --AND doc.get_last_doc_status_brief(pad.p_policy_agent_doc_id) IN ('CURRENT', 'NEW')
                           AND doc.get_last_doc_status_brief(pad.p_policy_agent_doc_id) NOT IN
                               ('ERROR', 'CANCEL')
                           AND trunc(v_d_doc_date) BETWEEN pad.date_begin AND pad.date_end
                           AND pad.ag_contract_header_id = v_ag_contract_header_id
                         ORDER BY 1
                                 ,3))
    LOOP
      plpdf.printcell(p_txt    => to_char(cur.row_num)
                     ,p_w      => 15
                     ,p_h      => 5
                     ,p_align  => 'R'
                     ,p_ln     => 0
                     ,p_border => 1);
      plpdf.printcell(p_txt    => to_char(cur.pol_num)
                     ,p_w      => 40
                     ,p_h      => 5
                     ,p_align  => 'R'
                     ,p_ln     => 0
                     ,p_border => 1);
      plpdf.printcell(p_txt    => to_char(cur.insurer_name)
                     ,p_w      => 80
                     ,p_h      => 5
                     ,p_align  => 'R'
                     ,p_ln     => 0
                     ,p_border => 1);
      plpdf.printcell(p_txt    => to_char(cur.start_date, 'dd.mm.yyyy')
                     ,p_w      => 40
                     ,p_h      => 5
                     ,p_align  => 'R'
                     ,p_ln     => 1
                     ,p_border => 1);
    END LOOP;
  
    plpdf.setprintfont(p_size => 11);
    plpdf.linebreak(p_h => 3);
    plpdf.printmultilinecell(p_txt => '', p_align => 'J', p_w => 5, p_h => -1, p_ln => 0);
    v_str := '2. ��������� ��� ������-�������� ��������� ����������� ��������� � ���� �����������, �� ������ ���������� ��� ' || CASE
               WHEN v_agent_category = 'AG' THEN
                '������'
               WHEN v_agent_category = 'MN' THEN
                '���������'
               WHEN v_agent_category IN ('DR', 'DR2') THEN
                '���������'
             END || ' � �����������.';
    plpdf.printmultilinecell(p_txt => v_str, p_align => 'J', p_h => -1, p_ln => 1);
  
    -- ������ �����������
    plpdf.linebreak(p_h => 10);
  
    IF plpdf.checkpagebreak(70)
    THEN
      NULL;
    END IF;
  
    plpdf.printmultilinecell(p_txt    => '�������:' || chr(13) || '�� ����� �����������' || chr(13) ||
                                         chr(13) || chr(13) || ' _______________/�������� �.�./' ||
                                         chr(13) || chr(13) || chr(13) || v_doc_date
                            ,p_w      => plpdf.getpagespace * 1 / 2
                            ,p_h      => -1
                            ,p_align  => 'L'
                            ,p_ln     => 0
                            ,p_border => 0);
    plpdf.printmultilinecell(p_txt    => '������:                                             ' ||
                                         chr(13) || chr(13)
                            ,p_w      => plpdf.getpagespace * 1 / 2
                            ,p_h      => -1
                            ,p_align  => 'L'
                            ,p_ln     => 1
                            ,p_border => 0);
    plpdf.printmultilinecell(p_txt => NULL, p_w => plpdf.getpagespace * 1 / 2, p_h => -1, p_ln => 0);
    plpdf.printmultilinecell(p_txt    => coalesce(v_agent, v_manager, v_director) ||
                                         ' _______________/____________________________/'
                            ,p_w      => plpdf.getpagespace
                            ,p_h      => -1
                            ,p_align  => 'L'
                            ,p_ln     => 1
                            ,p_border => 0);
    plpdf.printmultilinecell(p_txt => NULL, p_w => plpdf.getpagespace * 1 / 2, p_h => -1, p_ln => 0);
    plpdf.setprintfont(p_size => 8);
    plpdf.printmultilinecell(p_txt    => CASE
                                           WHEN v_agent = '�����' THEN
                                            '                            (�������)                                               (���)'
                                           ELSE
                                            '                                      (�������)                                               (���)'
                                         END
                            ,p_w      => plpdf.getpagespace
                            ,p_h      => -1
                            ,p_align  => 'L'
                            ,p_ln     => 1
                            ,p_border => 0);
    plpdf.setprintfont(p_size => 11);
  
    CASE
      WHEN v_agent = '�����' THEN
        plpdf.setprintfont(p_size => 11);
        plpdf.linebreak(p_h => 5);
        plpdf.printmultilinecell(p_txt => NULL
                                ,p_w   => plpdf.getpagespace * 1 / 2
                                ,p_h   => -1
                                ,p_ln  => 0);
        plpdf.printmultilinecell(p_txt    => '����������:                                             ' ||
                                             chr(13) || chr(13)
                                ,p_w      => plpdf.getpagespace
                                ,p_h      => -1
                                ,p_align  => 'L'
                                ,p_ln     => 1
                                ,p_border => 0);
        plpdf.printmultilinecell(p_txt => NULL
                                ,p_w   => plpdf.getpagespace * 1 / 2
                                ,p_h   => -1
                                ,p_ln  => 0);
        plpdf.printmultilinecell(p_txt    => '�������� _______________/____________________________/'
                                ,p_w      => plpdf.getpagespace
                                ,p_h      => -1
                                ,p_align  => 'L'
                                ,p_ln     => 1
                                ,p_border => 0);
        plpdf.printmultilinecell(p_txt => NULL
                                ,p_w   => plpdf.getpagespace * 1 / 2
                                ,p_h   => -1
                                ,p_ln  => 0);
        plpdf.setprintfont(p_size => 8);
        plpdf.printmultilinecell(p_txt    => '                                      (�������)                                               (���)'
                                ,p_w      => plpdf.getpagespace
                                ,p_h      => -1
                                ,p_align  => 'L'
                                ,p_ln     => 1
                                ,p_border => 0);
        plpdf.setprintfont(p_size => 11);
        plpdf.printmultilinecell(p_txt => NULL
                                ,p_w   => plpdf.getpagespace * 1 / 2
                                ,p_h   => -1
                                ,p_ln  => 0);
        plpdf.printmultilinecell(p_txt    => '�������� _______________/____________________________/'
                                ,p_w      => plpdf.getpagespace
                                ,p_h      => -1
                                ,p_align  => 'L'
                                ,p_ln     => 1
                                ,p_border => 0);
        plpdf.printmultilinecell(p_txt => NULL
                                ,p_w   => plpdf.getpagespace * 1 / 2
                                ,p_h   => -1
                                ,p_ln  => 0);
        plpdf.setprintfont(p_size => 8);
        plpdf.printmultilinecell(p_txt    => '                                      (�������)                                               (���)'
                                ,p_w      => plpdf.getpagespace
                                ,p_h      => -1
                                ,p_align  => 'L'
                                ,p_ln     => 1
                                ,p_border => 0);
      WHEN v_agent IS NULL
           AND v_manager = '��������' THEN
        plpdf.setprintfont(p_size => 11);
        plpdf.linebreak(p_h => 5);
        plpdf.printmultilinecell(p_txt => NULL
                                ,p_w   => plpdf.getpagespace * 1 / 2
                                ,p_h   => -1
                                ,p_ln  => 0);
        plpdf.printmultilinecell(p_txt    => '����������:                                             ' ||
                                             chr(13) || chr(13)
                                ,p_w      => plpdf.getpagespace
                                ,p_h      => -1
                                ,p_align  => 'L'
                                ,p_ln     => 1
                                ,p_border => 0);
        plpdf.printmultilinecell(p_txt => NULL
                                ,p_w   => plpdf.getpagespace * 1 / 2
                                ,p_h   => -1
                                ,p_ln  => 0);
        plpdf.printmultilinecell(p_txt    => '�������� _______________/____________________________/'
                                ,p_w      => plpdf.getpagespace
                                ,p_h      => -1
                                ,p_align  => 'L'
                                ,p_ln     => 1
                                ,p_border => 0);
        plpdf.printmultilinecell(p_txt => NULL
                                ,p_w   => plpdf.getpagespace * 1 / 2
                                ,p_h   => -1
                                ,p_ln  => 0);
        plpdf.setprintfont(p_size => 8);
        plpdf.printmultilinecell(p_txt    => '                                      (�������)                                               (���)'
                                ,p_w      => plpdf.getpagespace
                                ,p_h      => -1
                                ,p_align  => 'L'
                                ,p_ln     => 1
                                ,p_border => 0);
      ELSE
        NULL;
    END CASE;
    plpdf.setprintfont(p_size => 11);
    plpdf.printmultilinecell(p_txt => NULL, p_w => plpdf.getpagespace * 1 / 2, p_h => -1, p_ln => 0);
    plpdf.printmultilinecell(p_txt    => chr(13) || v_doc_date
                            ,p_w      => plpdf.getpagespace
                            ,p_h      => -1
                            ,p_align  => 'L'
                            ,p_ln     => 1
                            ,p_border => 0);
  
    plpdf.senddoc(p_blob => par_data);
    par_file_name    := 'rep_policy_acceptance_act_' || v_ag_contract_number || '.pdf';
    par_content_type := pkg_rep_plpdf.gc_pdf_content_type;
  END rep_policy_acceptance_act;

  /* 
    ��������� ������������ ������ "��� ������ ��������� ��������� ������"
    ��� ���� ��������� "������ ��������� ������ ��� �������� � ��" ���������� ��������
    
    407342: ���������� �������� ����� ��� ���� "��� ������ ��������� ��������� ������"
    ����� �., 06.04.2015
  */
  PROCEDURE rep_agent_reconciliation_act
  (
    par_content_type OUT VARCHAR2
   ,par_file_name    OUT VARCHAR2
   ,par_data         OUT NOCOPY BLOB
  ) IS
    TYPE t_cur IS RECORD(
       ag_sales_channel VARCHAR2(200)
      ,ag_agency        VARCHAR2(200)
      ,ag_num           VARCHAR2(200)
      ,ag_agent_name    VARCHAR2(200)
      ,ag_category_name VARCHAR2(200)
      ,mn_sales_channel VARCHAR2(200)
      ,mn_agency        VARCHAR2(200)
      ,mn_num           VARCHAR2(200)
      ,mn_agent_name    VARCHAR2(200)
      ,mn_category_name VARCHAR2(200)
      ,dr_sales_channel VARCHAR2(200)
      ,dr_agency        VARCHAR2(200)
      ,dr_num           VARCHAR2(200)
      ,dr_agent_name    VARCHAR2(200)
      ,dr_category_name VARCHAR2(200));
    TYPE tt_agents IS TABLE OF t_cur INDEX BY PLS_INTEGER;
  
    v_ag_contract_header_id ag_contract_header.ag_contract_header_id%TYPE;
    v_ag_documents_id       v_agn_documents.ag_documents_id%TYPE;
    v_ag_contract_number    document.num%TYPE;
    v_doc_date              DATE;
    v_agency                v_agn_contract.name%TYPE;
    v_agent_category        ag_category_agent.brief%TYPE;
    v_agents                tt_agents;
    i                       NUMBER := 1;
  
  BEGIN
    v_ag_contract_header_id := to_number(repcore.get_context('P_CH_ID'));
    v_ag_documents_id       := to_number(repcore.get_context('P_DOCUMENT_ID'));
  
    BEGIN
      SELECT ad.doc_date
        INTO v_doc_date
        FROM v_agn_documents ad
       WHERE ad.ag_documents_id = v_ag_documents_id;
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20001
                               ,'�� ������� ����� ���������� �� ��������������: ag_documents_id');
    END;
  
    BEGIN
      SELECT ac.num    ag_contract_number
            ,ac.name   agency
            ,aca.brief
        INTO v_ag_contract_number
            ,v_agency
            ,v_agent_category
        FROM v_agn_contract    ac
            ,contact           c
            ,ag_contract       a
            ,ag_category_agent aca
       WHERE ac.agent_id = c.contact_id
         AND ac.ag_contract_header_id = v_ag_contract_header_id
         AND ac.ag_contract_id = a.ag_contract_id
         AND a.category_id = aca.ag_category_agent_id
         AND trunc(v_doc_date) BETWEEN ac.ac_date_begin AND ac.ac_date_end;
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20001
                               ,'�� ������� ����� ���������� �� ��������������: ag_contract_header_id');
    END;
  
    FOR cur IN (SELECT *
                  FROM (WITH src AS (SELECT aat.ag_contract_header_id
                                           ,aat.ag_parent_header_id
                                           ,nvl(ac_ch.description, ach_ch.description) sales_channel
                                           ,d.name agency
                                           ,decode(aca.brief, 'AG', ach.num, ac.personnel_number) num
                                           ,c.obj_name_orig agent_name
                                           ,aca.brief category_brief
                                           ,aca.category_name
                                       FROM ag_agent_tree          aat
                                           ,ven_ag_contract_header ach
                                           ,ag_contract            ac
                                           ,contact                c
                                           ,department             d
                                           ,ag_category_agent      aca
                                           ,t_sales_channel        ach_ch
                                           ,t_sales_channel        ac_ch
                                      WHERE aat.ag_contract_header_id = ach.ag_contract_header_id
                                        AND ach.ag_contract_header_id = ac.contract_id
                                        AND ach.agent_id = c.contact_id
                                        AND ac.agency_id = d.department_id(+)
                                        AND ac.category_id = aca.ag_category_agent_id
                                        AND ach_ch.id = ach.t_sales_channel_id
                                        AND ac.ag_sales_chn_id = ac_ch.id
                                        AND v_agent_category = 'MN'
                                        AND aat.ag_contract_header_id =
                                            (SELECT ag_parent_header_id
                                               FROM ag_agent_tree
                                              WHERE ag_contract_header_id = v_ag_contract_header_id
                                                AND trunc(v_doc_date) BETWEEN date_begin AND date_end)
                                        AND trunc(v_doc_date) BETWEEN aat.date_begin AND aat.date_end
                                        AND trunc(v_doc_date) BETWEEN ac.date_begin AND ac.date_end
                                     
                                     UNION ALL
                                     
                                     SELECT aat.ag_contract_header_id
                                           ,aat.ag_parent_header_id
                                           ,nvl(ac_ch.description, ach_ch.description) sales_channel
                                           ,d.name agency
                                           ,decode(aca.brief, 'AG', ach.num, ac.personnel_number) num
                                           ,c.obj_name_orig agent_name
                                           ,aca.brief category_brief
                                           ,aca.category_name
                                       FROM ag_agent_tree          aat
                                           ,ven_ag_contract_header ach
                                           ,ag_contract            ac
                                           ,contact                c
                                           ,department             d
                                           ,ag_category_agent      aca
                                           ,t_sales_channel        ach_ch
                                           ,t_sales_channel        ac_ch
                                      WHERE aat.ag_contract_header_id = ach.ag_contract_header_id
                                        AND ach.ag_contract_header_id = ac.contract_id
                                        AND ach.agent_id = c.contact_id
                                        AND ac.agency_id = d.department_id(+)
                                        AND ac.category_id = aca.ag_category_agent_id
                                        AND ach_ch.id = ach.t_sales_channel_id
                                        AND ac.ag_sales_chn_id = ac_ch.id
                                        AND trunc(v_doc_date) BETWEEN ach.date_begin AND ach.date_break
                                        AND trunc(v_doc_date) BETWEEN ac.date_begin AND ac.date_end
                                        AND trunc(v_doc_date) BETWEEN aat.date_begin AND aat.date_end
                                        AND doc.get_doc_status_brief(aat.ag_contract_header_id
                                                                    ,v_doc_date) NOT IN
                                            ('BREAK', 'CANCEL')
                                        AND ((aca.brief = 'AG' AND EXISTS
                                             (SELECT NULL
                                                 FROM ag_documents ad
                                                     ,ag_doc_type  adt
                                                WHERE ad.ag_doc_type_id = adt.ag_doc_type_id
                                                  AND adt.brief = 'NEW_AD_RENLIFE'
                                                  AND ad.ag_contract_header_id = ach.ag_contract_header_id
                                                  AND doc.get_doc_status_brief(ad.ag_documents_id, SYSDATE) IN
                                                      ('CO_ACCEPTED', 'CO_ACHIVE', 'DEFICIENCY'))) OR
                                            (aca.brief = 'MN' AND EXISTS
                                             (SELECT NULL
                                                 FROM ag_documents ad
                                                     ,ag_doc_type  adt
                                                WHERE ad.ag_doc_type_id = adt.ag_doc_type_id
                                                  AND adt.brief = 'BONUSES_PROVISION'
                                                  AND ad.ag_contract_header_id = ach.ag_contract_header_id
                                                  AND doc.get_doc_status_brief(ad.ag_documents_id, SYSDATE) IN
                                                      ('CO_ACCEPTED', 'CO_ACHIVE')) AND EXISTS
                                             (SELECT NULL
                                                 FROM ag_documents ad
                                                     ,ag_doc_type  adt
                                                WHERE ad.ag_doc_type_id = adt.ag_doc_type_id
                                                  AND adt.brief = 'DECLINE_RLP'
                                                  AND ad.ag_contract_header_id = ach.ag_contract_header_id
                                                  AND doc.get_doc_status_brief(ad.ag_documents_id, SYSDATE) IN
                                                      ('CO_ACCEPTED', 'CO_ACHIVE'))) OR
                                            aca.brief IN ('DR', 'DR2'))
                                        AND LEVEL IN (1, 2)
                                      START WITH aat.ag_contract_header_id = v_ag_contract_header_id
                                             AND trunc(v_doc_date) BETWEEN aat.date_begin AND
                                                 aat.date_end
                                             AND trunc(v_doc_date) BETWEEN ac.date_begin AND ac.date_end
                                             AND trunc(v_doc_date) BETWEEN aat.date_begin AND
                                                 aat.date_end
                                     CONNECT BY PRIOR aat.ag_contract_header_id = aat.ag_parent_header_id
                                            AND trunc(v_doc_date) BETWEEN ach.date_begin AND
                                                ach.date_break
                                            AND trunc(v_doc_date) BETWEEN ac.date_begin AND ac.date_end
                                            AND trunc(v_doc_date) BETWEEN aat.date_begin AND aat.date_end)
                       
                         SELECT ag_mn.ag_sales_channel
                               ,ag_mn.ag_agency
                               ,ag_mn.ag_num
                               ,ag_mn.ag_agent_name
                               ,ag_mn.ag_category_name
                               ,ag_mn.mn_sales_channel
                               ,ag_mn.mn_agency
                               ,ag_mn.mn_num
                               ,ag_mn.mn_agent_name
                               ,ag_mn.mn_category_name
                               ,decode(ag_mn.mn_ag_parent_header_id
                                      ,NULL
                                      ,dr_ag.sales_channel
                                      ,dr_mn.sales_channel) dr_sales_channel
                               ,decode(ag_mn.mn_ag_parent_header_id, NULL, dr_ag.agency, dr_mn.agency) dr_agency
                               ,decode(ag_mn.mn_ag_parent_header_id, NULL, dr_ag.num, dr_mn.num) dr_num
                               ,decode(ag_mn.mn_ag_parent_header_id
                                      ,NULL
                                      ,dr_ag.agent_name
                                      ,dr_mn.agent_name) dr_agent_name
                               ,decode(ag_mn.mn_ag_parent_header_id
                                      ,NULL
                                      ,dr_ag.category_name
                                      ,dr_mn.category_name) dr_category_name
                           FROM (SELECT ag.ag_parent_header_id ag_ag_parent_header_id
                                       ,mn.ag_parent_header_id mn_ag_parent_header_id
                                       ,ag.sales_channel       ag_sales_channel
                                       ,ag.agency              ag_agency
                                       ,ag.num                 ag_num
                                       ,ag.agent_name          ag_agent_name
                                       ,ag.category_name       ag_category_name
                                       ,mn.sales_channel       mn_sales_channel
                                       ,mn.agency              mn_agency
                                       ,mn.num                 mn_num
                                       ,mn.agent_name          mn_agent_name
                                       ,mn.category_name       mn_category_name
                                   FROM (SELECT * FROM src WHERE category_brief = 'AG') ag
                                   FULL JOIN (SELECT * FROM src WHERE category_brief = 'MN') mn
                                     ON ag.ag_parent_header_id = mn.ag_contract_header_id) ag_mn
                               ,(SELECT * FROM src WHERE category_brief IN ('DR', 'DR2')) dr_ag
                               ,(SELECT * FROM src WHERE category_brief IN ('DR', 'DR2')) dr_mn
                          WHERE ag_mn.ag_ag_parent_header_id = dr_ag.ag_contract_header_id(+)
                            AND ag_mn.mn_ag_parent_header_id = dr_mn.ag_contract_header_id(+)
                          ORDER BY ag_mn.ag_num
                                  ,ag_mn.mn_num
                                  ,dr_ag.num
                                  ,dr_mn.num)
                )
    LOOP
      v_agents(i).ag_sales_channel := to_char(cur.ag_sales_channel);
      v_agents(i).ag_agency := to_char(cur.ag_agency);
      v_agents(i).ag_num := to_char(cur.ag_num);
      v_agents(i).ag_agent_name := to_char(cur.ag_agent_name);
      v_agents(i).ag_category_name := to_char(cur.ag_category_name);
    
      v_agents(i).mn_sales_channel := to_char(cur.mn_sales_channel);
      v_agents(i).mn_agency := to_char(cur.mn_agency);
      v_agents(i).mn_num := to_char(cur.mn_num);
      v_agents(i).mn_agent_name := to_char(cur.mn_agent_name);
      v_agents(i).mn_category_name := to_char(cur.mn_category_name);
    
      v_agents(i).dr_sales_channel := to_char(cur.dr_sales_channel);
      v_agents(i).dr_agency := to_char(cur.dr_agency);
      v_agents(i).dr_num := to_char(cur.dr_num);
      v_agents(i).dr_agent_name := to_char(cur.dr_agent_name);
      v_agents(i).dr_category_name := to_char(cur.dr_category_name);
      i := i + 1;
    END LOOP;
  
    plpdf.init(p_orientation => 'L');
    pkg_rep_plpdf.font_init;
    plpdf.setencoding(p_enc => plpdf_const.cp1251);
    plpdf.newpage;
  
    plpdf.setprintfont(p_family => 'Times', p_style => 'B', p_size => 10);
    plpdf.printcell(p_txt   => '��� ������ ��������� ��������� ������'
                   ,p_h     => -1
                   ,p_align => 'C'
                   ,p_ln    => 1);
  
    plpdf.setprintfont(p_family => 'Times', p_style => NULL, p_size => 10);
    plpdf.printcell(p_txt => '���������: ' || v_agency, p_h => -1, p_align => 'L', p_ln => 1);
    plpdf.printcell(p_txt   => '�������� ������: ����'
                   ,p_h     => -1
                   ,p_align => 'L'
                   ,p_ln    => 1);
    plpdf.printcell(p_txt   => '���� �����������: ' || to_char(v_doc_date, 'dd.mm.yyyy')
                   ,p_h     => -1
                   ,p_align => 'L'
                   ,p_ln    => 1);
  
    -- ������� - ���������
    plpdf.linebreak(p_h => 3);
    plpdf.setprintfont(p_size => 7);
    plpdf.printcell(p_txt    => '� �/�'
                   ,p_w      => 10
                   ,p_h      => 20
                   ,p_align  => 'C'
                   ,p_ln     => 0
                   ,p_border => 1);
    plpdf.printcell(p_txt    => '�����'
                   ,p_w      => 85
                   ,p_h      => 5
                   ,p_align  => 'C'
                   ,p_ln     => 0
                   ,p_border => 1);
    plpdf.printcell(p_txt    => '��������'
                   ,p_w      => 85
                   ,p_h      => 5
                   ,p_align  => 'C'
                   ,p_ln     => 0
                   ,p_border => 1);
    plpdf.printcell(p_txt    => '��������'
                   ,p_w      => 100
                   ,p_h      => 5
                   ,p_align  => 'C'
                   ,p_ln     => 1
                   ,p_border => 1);
    plpdf.printcell(p_txt => NULL, p_align => 'J', p_w => 10, p_h => -1, p_ln => 0);
    plpdf.printmultilinecell(p_txt    => '��� ��������� ����'
                            ,p_w      => 15
                            ,p_h      => 5
                            ,p_align  => 'C'
                            ,p_ln     => 0
                            ,p_border => 1);
    plpdf.printmultilinecell(p_txt    => '���������'
                            ,p_w      => 25
                            ,p_h      => 15
                            ,p_align  => 'C'
                            ,p_ln     => 0
                            ,p_border => 1);
    plpdf.printmultilinecell(p_txt    => '� ��'
                            ,p_w      => 10
                            ,p_h      => 15
                            ,p_align  => 'C'
                            ,p_ln     => 0
                            ,p_border => 1);
    plpdf.printmultilinecell(p_txt    => '���'
                            ,p_w      => 35
                            ,p_h      => 15
                            ,p_align  => 'C'
                            ,p_ln     => 0
                            ,p_border => 1);
    plpdf.printmultilinecell(p_txt    => '��� ��������� ����'
                            ,p_w      => 15
                            ,p_h      => 5
                            ,p_align  => 'C'
                            ,p_ln     => 0
                            ,p_border => 1);
    plpdf.printmultilinecell(p_txt    => '���������'
                            ,p_w      => 25
                            ,p_h      => 15
                            ,p_align  => 'C'
                            ,p_ln     => 0
                            ,p_border => 1);
    plpdf.printmultilinecell(p_txt    => '���. �����'
                            ,p_w      => 10
                            ,p_h      => 7.5
                            ,p_align  => 'C'
                            ,p_ln     => 0
                            ,p_border => 1);
    plpdf.printmultilinecell(p_txt    => '���'
                            ,p_w      => 35
                            ,p_h      => 15
                            ,p_align  => 'C'
                            ,p_ln     => 0
                            ,p_border => 1);
    plpdf.printmultilinecell(p_txt    => '��� ��������� ����'
                            ,p_w      => 15
                            ,p_h      => 5
                            ,p_align  => 'C'
                            ,p_ln     => 0
                            ,p_border => 1);
    plpdf.printmultilinecell(p_txt    => '���������'
                            ,p_w      => 25
                            ,p_h      => 15
                            ,p_align  => 'C'
                            ,p_ln     => 0
                            ,p_border => 1);
    plpdf.printmultilinecell(p_txt    => '���. �����'
                            ,p_w      => 10
                            ,p_h      => 7.5
                            ,p_align  => 'C'
                            ,p_ln     => 0
                            ,p_border => 1);
    plpdf.printmultilinecell(p_txt    => '���'
                            ,p_w      => 35
                            ,p_h      => 15
                            ,p_align  => 'C'
                            ,p_ln     => 0
                            ,p_border => 1);
    plpdf.printmultilinecell(p_txt    => '��������� ���������'
                            ,p_w      => 15
                            ,p_h      => 7.5
                            ,p_align  => 'C'
                            ,p_ln     => 1
                            ,p_border => 1);
  
    -- ������� - ������
    pkg_rep_plpdf.delete_row_print_cache;
  
    pkg_rep_plpdf.gv_widths(1) := 10;
    pkg_rep_plpdf.gv_widths(2) := 15;
    pkg_rep_plpdf.gv_widths(3) := 25;
    pkg_rep_plpdf.gv_widths(4) := 10;
    pkg_rep_plpdf.gv_widths(5) := 35;
    pkg_rep_plpdf.gv_widths(6) := 15;
    pkg_rep_plpdf.gv_widths(7) := 25;
    pkg_rep_plpdf.gv_widths(8) := 10;
    pkg_rep_plpdf.gv_widths(9) := 35;
    pkg_rep_plpdf.gv_widths(10) := 15;
    pkg_rep_plpdf.gv_widths(11) := 25;
    pkg_rep_plpdf.gv_widths(12) := 10;
    pkg_rep_plpdf.gv_widths(13) := 35;
    pkg_rep_plpdf.gv_widths(14) := 15;
  
    FOR i IN 1 .. 14
    LOOP
      pkg_rep_plpdf.gv_borders(i) := 1;
      pkg_rep_plpdf.gv_aligns(i) := 'C';
      pkg_rep_plpdf.gv_styles(i) := NULL;
    END LOOP;
  
    FOR q IN 1 .. v_agents.count
    LOOP
      pkg_rep_plpdf.gv_datas(1) := to_char(q);
      pkg_rep_plpdf.gv_datas(2) := v_agents(q).ag_sales_channel;
      pkg_rep_plpdf.gv_datas(3) := v_agents(q).ag_agency;
      pkg_rep_plpdf.gv_datas(4) := v_agents(q).ag_num;
      pkg_rep_plpdf.gv_datas(5) := v_agents(q).ag_agent_name;
      pkg_rep_plpdf.gv_datas(6) := v_agents(q).mn_sales_channel;
      pkg_rep_plpdf.gv_datas(7) := v_agents(q).mn_agency;
      pkg_rep_plpdf.gv_datas(8) := v_agents(q).mn_num;
      pkg_rep_plpdf.gv_datas(9) := v_agents(q).mn_agent_name;
      pkg_rep_plpdf.gv_datas(10) := v_agents(q).dr_sales_channel;
      pkg_rep_plpdf.gv_datas(11) := v_agents(q).dr_agency;
      pkg_rep_plpdf.gv_datas(12) := v_agents(q).dr_num;
      pkg_rep_plpdf.gv_datas(13) := v_agents(q).dr_agent_name;
      pkg_rep_plpdf.gv_datas(14) := v_agents(q).dr_category_name;
    
      plpdf.row_print2(p_data     => pkg_rep_plpdf.gv_datas
                      ,p_border   => pkg_rep_plpdf.gv_borders
                      ,p_width    => pkg_rep_plpdf.gv_widths
                      ,p_align    => pkg_rep_plpdf.gv_aligns
                      ,p_style    => pkg_rep_plpdf.gv_styles
                      ,p_clipping => 0
                      ,p_h        => 4
                      ,p_maxline  => pkg_rep_plpdf.gv_maxlines);
    END LOOP;
  
    -- ������ �����������
    plpdf.linebreak(p_h => 5);
    CASE
      WHEN v_agent_category = 'MN' THEN
        IF plpdf.checkpagebreak(50)
        THEN
          NULL;
        END IF;
        plpdf.setprintfont(p_size => 11);
        plpdf.linebreak(p_h => 5);
        plpdf.printmultilinecell(p_txt => NULL, p_w => plpdf.getpagespace / 7, p_h => -1, p_ln => 0);
        plpdf.printmultilinecell(p_txt    => '�������� _______________/____________________________/'
                                ,p_w      => plpdf.getpagespace
                                ,p_h      => -1
                                ,p_align  => 'L'
                                ,p_ln     => 1
                                ,p_border => 0);
        plpdf.printmultilinecell(p_txt => NULL, p_w => plpdf.getpagespace / 7, p_h => -1, p_ln => 0);
        plpdf.setprintfont(p_size => 8);
        plpdf.printmultilinecell(p_txt    => '                                      (�������)                                               (���)'
                                ,p_w      => plpdf.getpagespace
                                ,p_h      => -1
                                ,p_align  => 'L'
                                ,p_ln     => 1
                                ,p_border => 0);
        plpdf.setprintfont(p_size => 11);
        plpdf.linebreak(p_h => 5);
        plpdf.printmultilinecell(p_txt => NULL, p_w => plpdf.getpagespace / 7, p_h => -1, p_ln => 0);
        plpdf.printmultilinecell(p_txt    => '����������:' || chr(13) || chr(13)
                                ,p_w      => plpdf.getpagespace
                                ,p_h      => -1
                                ,p_align  => 'L'
                                ,p_ln     => 1
                                ,p_border => 0);
        plpdf.printmultilinecell(p_txt => NULL, p_w => plpdf.getpagespace / 7, p_h => -1, p_ln => 0);
        plpdf.printmultilinecell(p_txt    => '�������� _______________/____________________________/'
                                ,p_w      => plpdf.getpagespace
                                ,p_h      => -1
                                ,p_align  => 'L'
                                ,p_ln     => 1
                                ,p_border => 0);
        plpdf.printmultilinecell(p_txt => NULL, p_w => plpdf.getpagespace / 7, p_h => -1, p_ln => 0);
        plpdf.setprintfont(p_size => 8);
        plpdf.printmultilinecell(p_txt    => '                                      (�������)                                               (���)'
                                ,p_w      => plpdf.getpagespace
                                ,p_h      => -1
                                ,p_align  => 'L'
                                ,p_ln     => 1
                                ,p_border => 0);
        plpdf.setprintfont(p_size => 11);
        plpdf.printmultilinecell(p_txt => NULL, p_w => plpdf.getpagespace / 7, p_h => -1, p_ln => 0);
        plpdf.printmultilinecell(p_txt    => '�____� _______________________ 201_ �.'
                                ,p_w      => plpdf.getpagespace
                                ,p_h      => -1
                                ,p_align  => 'L'
                                ,p_ln     => 1
                                ,p_border => 0);
      WHEN v_agent_category IN ('DR', 'DR2') THEN
        IF plpdf.checkpagebreak(25)
        THEN
          NULL;
        END IF;
        plpdf.setprintfont(p_size => 11);
        plpdf.linebreak(p_h => 5);
        plpdf.printmultilinecell(p_txt => NULL, p_w => plpdf.getpagespace / 7, p_h => -1, p_ln => 0);
        plpdf.printmultilinecell(p_txt    => '�������� _______________/____________________________/'
                                ,p_w      => plpdf.getpagespace
                                ,p_h      => -1
                                ,p_align  => 'L'
                                ,p_ln     => 1
                                ,p_border => 0);
        plpdf.printmultilinecell(p_txt => NULL, p_w => plpdf.getpagespace / 7, p_h => -1, p_ln => 0);
        plpdf.setprintfont(p_size => 8);
        plpdf.printmultilinecell(p_txt    => '                                      (�������)                                               (���)'
                                ,p_w      => plpdf.getpagespace
                                ,p_h      => -1
                                ,p_align  => 'L'
                                ,p_ln     => 1
                                ,p_border => 0);
        plpdf.setprintfont(p_size => 11);
        plpdf.printmultilinecell(p_txt => NULL, p_w => plpdf.getpagespace / 7, p_h => -1, p_ln => 0);
        plpdf.printmultilinecell(p_txt    => '�____� _______________________ 201_ �.'
                                ,p_w      => plpdf.getpagespace
                                ,p_h      => -1
                                ,p_align  => 'L'
                                ,p_ln     => 1
                                ,p_border => 0);
      ELSE
        NULL;
    END CASE;
  
    plpdf.senddoc(p_blob => par_data);
    par_file_name    := 'rep_policy_acceptance_act_' || v_ag_contract_number || '.pdf';
    par_content_type := pkg_rep_plpdf.gc_pdf_content_type;
  END rep_agent_reconciliation_act;

  /* 
    ��������� ������������ ������ "��� �������� ��������� �����������", �������
    ����������� �� ����� TRANS_AGENT_DOC
    
    415449: ���������� �������� ����� "��� �������� ��"
    ����� �., 21.05.2015
  */
  PROCEDURE rep_policy_transfer_act_cp
  (
    par_content_type OUT VARCHAR2
   ,par_file_name    OUT VARCHAR2
   ,par_data         OUT NOCOPY BLOB
  ) IS
    v_ag_contract_header_id       ag_contract_header.ag_contract_header_id%TYPE;
    v_trans_ag_contract_header_id ag_contract_header.ag_contract_header_id%TYPE;
    v_trans_date                  DATE;
    v_reporting_period            VARCHAR2(100);
    v_ag_contract_number          document.num%TYPE;
    v_agency                      v_agn_contract.name%TYPE;
    v_agent_name                  contact.dative%TYPE;
    v_agent_category              ag_category_agent.brief%TYPE;
    v_trans_agent_name            contact.dative%TYPE;
    v_trans_agent_category        VARCHAR2(100);
    v_trans_agent_cat_genitive    VARCHAR2(100);
    v_str                         VARCHAR(32767);
    v_ag_num                      ag_contract.personnel_number%TYPE;
    v_ag_sales_channel            t_sales_channel.description%TYPE;
    v_ag_agent_name               contact.obj_name_orig%TYPE;
    v_mn_num                      ag_contract.personnel_number%TYPE;
    v_mn_sales_channel            t_sales_channel.description%TYPE;
    v_mn_agent_name               contact.obj_name_orig%TYPE;
    v_dr_num                      ag_contract.personnel_number%TYPE;
    v_dr_sales_channel            t_sales_channel.description%TYPE;
    v_dr_agent_name               contact.obj_name_orig%TYPE;
    v_td_num                      ag_contract.personnel_number%TYPE;
    v_td_sales_channel            t_sales_channel.description%TYPE;
    v_td_agent_name               contact.obj_name_orig%TYPE;
  BEGIN
    v_ag_contract_header_id       := to_number(repcore.get_context('P_CH_ID'));
    v_trans_ag_contract_header_id := to_number(repcore.get_context('P_TRANS_CH_ID'));
    v_trans_date                  := to_date(repcore.get_context('P_DATE_TRANS'), 'dd.mm.yyyy');
  
    v_reporting_period := CASE
                            WHEN extract(DAY FROM v_trans_date) <= 25 THEN
                             CASE extract(MONTH FROM v_trans_date)
                               WHEN 1 THEN
                                '������ ' || to_char(extract(YEAR FROM v_trans_date))
                               WHEN 2 THEN
                                '������� ' || to_char(extract(YEAR FROM v_trans_date))
                               WHEN 3 THEN
                                '���� ' || to_char(extract(YEAR FROM v_trans_date))
                               WHEN 4 THEN
                                '������ ' || to_char(extract(YEAR FROM v_trans_date))
                               WHEN 5 THEN
                                '��� ' || to_char(extract(YEAR FROM v_trans_date))
                               WHEN 6 THEN
                                '���� ' || to_char(extract(YEAR FROM v_trans_date))
                               WHEN 7 THEN
                                '���� ' || to_char(extract(YEAR FROM v_trans_date))
                               WHEN 8 THEN
                                '������ ' || to_char(extract(YEAR FROM v_trans_date))
                               WHEN 9 THEN
                                '�������� ' || to_char(extract(YEAR FROM v_trans_date))
                               WHEN 10 THEN
                                '������� ' || to_char(extract(YEAR FROM v_trans_date))
                               WHEN 11 THEN
                                '������ ' || to_char(extract(YEAR FROM v_trans_date))
                               WHEN 12 THEN
                                '������� ' || to_char(extract(YEAR FROM v_trans_date))
                             END
                            ELSE
                             CASE extract(MONTH FROM v_trans_date) + 1
                               WHEN 1 THEN
                                '������ ' || to_char(extract(YEAR FROM ADD_MONTHS(v_trans_date, 1)))
                               WHEN 2 THEN
                                '������� ' || to_char(extract(YEAR FROM ADD_MONTHS(v_trans_date, 1)))
                               WHEN 3 THEN
                                '���� ' || to_char(extract(YEAR FROM ADD_MONTHS(v_trans_date, 1)))
                               WHEN 4 THEN
                                '������ ' || to_char(extract(YEAR FROM ADD_MONTHS(v_trans_date, 1)))
                               WHEN 5 THEN
                                '��� ' || to_char(extract(YEAR FROM ADD_MONTHS(v_trans_date, 1)))
                               WHEN 6 THEN
                                '���� ' || to_char(extract(YEAR FROM ADD_MONTHS(v_trans_date, 1)))
                               WHEN 7 THEN
                                '���� ' || to_char(extract(YEAR FROM ADD_MONTHS(v_trans_date, 1)))
                               WHEN 8 THEN
                                '������ ' || to_char(extract(YEAR FROM ADD_MONTHS(v_trans_date, 1)))
                               WHEN 9 THEN
                                '�������� ' || to_char(extract(YEAR FROM ADD_MONTHS(v_trans_date, 1)))
                               WHEN 10 THEN
                                '������� ' || to_char(extract(YEAR FROM ADD_MONTHS(v_trans_date, 1)))
                               WHEN 11 THEN
                                '������ ' || to_char(extract(YEAR FROM ADD_MONTHS(v_trans_date, 1)))
                               WHEN 12 THEN
                                '������� ' || to_char(extract(YEAR FROM ADD_MONTHS(v_trans_date, 1)))
                             END
                          END;
  
    BEGIN
      SELECT ac.num
            ,ac.name
            ,c.dative
            ,aca.brief
        INTO v_ag_contract_number
            ,v_agency
            ,v_agent_name
            ,v_agent_category
        FROM v_agn_contract    ac
            ,contact           c
            ,ag_contract       a
            ,ag_category_agent aca
       WHERE ac.agent_id = c.contact_id
         AND ac.ag_contract_header_id = v_ag_contract_header_id
         AND ac.ag_contract_id = a.ag_contract_id
         AND a.category_id = aca.ag_category_agent_id
         AND trunc(v_trans_date) BETWEEN ac.ac_date_begin AND ac.ac_date_end;
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20001
                               ,'�� ������� ����� ���������� �� ��������������: ag_contract_header_id');
    END;
  
    BEGIN
      SELECT c.dative
            ,CASE aca.brief
               WHEN 'AG' THEN
                '�����'
               WHEN 'MN' THEN
                '��������'
               WHEN 'DR' THEN
                '��������'
               WHEN 'DR2' THEN
                '��������'
               WHEN 'TD' THEN
                '��������������� ��������'
             END
            ,CASE aca.brief
               WHEN 'AG' THEN
                '������'
               WHEN 'MN' THEN
                '���������'
               WHEN 'DR' THEN
                '���������'
               WHEN 'DR2' THEN
                '���������'
               WHEN 'TD' THEN
                '���������������� ���������'
             END
        INTO v_trans_agent_name
            ,v_trans_agent_category
            ,v_trans_agent_cat_genitive
        FROM v_agn_contract    ac
            ,contact           c
            ,ag_contract       a
            ,ag_category_agent aca
       WHERE ac.agent_id = c.contact_id
         AND ac.ag_contract_header_id = v_trans_ag_contract_header_id
         AND ac.ag_contract_id = a.ag_contract_id
         AND a.category_id = aca.ag_category_agent_id
         AND trunc(v_trans_date) BETWEEN ac.ac_date_begin AND ac.ac_date_end;
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20001
                               ,'�� ������� ����� ���������� �� ��������������: ag_contract_header_id');
    END;
  
    plpdf.init(p_orientation => 'L');
    pkg_rep_plpdf.font_init;
    plpdf.setencoding(p_enc => plpdf_const.cp1251);
    plpdf.newpage;
    plpdf.setprintfont(p_family => 'Times', p_style => NULL, p_size => 8);
  
    plpdf.printcell(p_txt   => '��� ������-�������� ��������� �����������'
                   ,p_h     => -1
                   ,p_align => 'C'
                   ,p_ln    => 1);
  
    plpdf.printcell(p_txt => '���������: ' || v_agency, p_h => -1, p_align => 'L', p_ln => 1);
  
    plpdf.printcell(p_txt   => '�������� ������: ' || v_reporting_period
                   ,p_h     => -1
                   ,p_align => 'L'
                   ,p_ln    => 1);
  
    plpdf.printcell(p_txt   => '���� �����������: ' || to_char(v_trans_date, 'dd.mm.yyyy')
                   ,p_h     => -1
                   ,p_align => 'L'
                   ,p_ln    => 1);
  
    plpdf.linebreak(p_h => 3);
    v_str := '1. ��� ��� ���������� ������ � ���� ��������� �� �������� ��������� �.�., ������������ �� ��������� ������������ � 2015/138 (����� - ����������) �������� ' ||
             v_trans_agent_name || ' (����� - ' || v_trans_agent_category || ') ' ||
             '�������� ����������� ��� ����������� ������������.';
    plpdf.printmultilinecell(p_txt => v_str, p_align => 'J', p_h => -1, p_ln => 1);
  
    -- ������� 1 - �������� �������
    plpdf.linebreak(p_h => 3);
    plpdf.printcell(p_txt   => '������� �1. ������� ��������� ��������� ������'
                   ,p_h     => -1
                   ,p_align => 'L'
                   ,p_ln    => 1);
    plpdf.setprintfont(p_size => 6);
  
    -- ������� 1 - ��������� �������
    pkg_rep_plpdf.delete_row_print_cache;
  
    pkg_rep_plpdf.gv_widths(1) := 30;
    pkg_rep_plpdf.gv_widths(2) := 25;
    pkg_rep_plpdf.gv_widths(3) := 40;
    pkg_rep_plpdf.gv_widths(4) := 15;
    pkg_rep_plpdf.gv_widths(5) := 15;
    pkg_rep_plpdf.gv_widths(6) := 40;
    pkg_rep_plpdf.gv_widths(7) := 20;
    pkg_rep_plpdf.gv_widths(8) := 80;
    pkg_rep_plpdf.gv_widths(9) := 15;
  
    FOR i IN 1 .. 9
    LOOP
      pkg_rep_plpdf.gv_borders(i) := 1;
      pkg_rep_plpdf.gv_aligns(i) := 'C';
      pkg_rep_plpdf.gv_styles(i) := NULL;
    END LOOP;
  
    -- ������� 1 - �������� ������� �������
    pkg_rep_plpdf.gv_datas(1) := '���������� �����/��������/��������';
    pkg_rep_plpdf.gv_datas(2) := '�� ������/��������� ����� ���������, ���������';
    pkg_rep_plpdf.gv_datas(3) := '���';
    pkg_rep_plpdf.gv_datas(4) := '� �������� �����������';
    pkg_rep_plpdf.gv_datas(5) := '���� �������� �����������';
    pkg_rep_plpdf.gv_datas(6) := '��� ������������';
    pkg_rep_plpdf.gv_datas(7) := '�������';
    pkg_rep_plpdf.gv_datas(8) := '�����';
    pkg_rep_plpdf.gv_datas(9) := '���� ���';
    plpdf.row_print2(p_data     => pkg_rep_plpdf.gv_datas
                    ,p_border   => pkg_rep_plpdf.gv_borders
                    ,p_width    => pkg_rep_plpdf.gv_widths
                    ,p_align    => pkg_rep_plpdf.gv_aligns
                    ,p_style    => pkg_rep_plpdf.gv_styles
                    ,p_clipping => 0
                    ,p_h        => 4
                    ,p_maxline  => pkg_rep_plpdf.gv_maxlines);
  
    -- ������� 1 - ������
    FOR i IN 1 .. 9
    LOOP
      pkg_rep_plpdf.gv_aligns(i) := 'J';
    END LOOP;
    FOR cur IN (SELECT '�����' prev_ag
                      ,agh.num
                      ,c.obj_name_orig
                      ,doc.pol_num
                      ,doc.start_date
                      ,doc.holder
                      ,doc.tel_num
                      ,doc.adr_name
                      ,to_char(doc.plan_date, 'dd.mm.yyyy') plan_date
                  FROM ins.ven_ag_contract_header agh
                      ,ins.t_sales_channel ch
                      ,ins.contact c
                      ,ins.ag_contract ag
                      ,ins.ag_category_agent cat
                      ,(SELECT pol.pol_num
                              ,to_char(ph.start_date, 'dd.mm.yyyy') start_date
                              ,cpol.obj_name_orig holder
                              ,pad.ag_contract_header_id
                              ,pkg_utils.get_aggregated_string(CAST(MULTISET (SELECT tel.telephone_number
                                                                       FROM ins.cn_contact_telephone tel
                                                                           ,ins.t_telephone_type     t
                                                                      WHERE tel.contact_id =
                                                                            cpol.contact_id
                                                                        AND tel.telephone_type = t.id
                                                                        AND tel.status = 1
                                                                     /*AND tel.deleted = 0*/
                                                                     ) AS tt_one_col)
                                                              ,', ') tel_num
                              ,pkg_utils.get_aggregated_string(CAST(MULTISET
                                                                    (SELECT ta.description || '-' ||
                                                                            (CASE
                                                                              WHEN ca.province_name IS NULL THEN
                                                                               ca.name
                                                                              ELSE
                                                                               ins.pkg_contact.get_address_name(ca.id)
                                                                            END)
                                                                       FROM ins.cn_contact_address cca
                                                                           ,ins.cn_address         ca
                                                                           ,ins.t_address_type     ta
                                                                      WHERE cca.contact_id =
                                                                            cpol.contact_id
                                                                        AND cca.adress_id = ca.id
                                                                        AND cca.status = 1
                                                                        AND cca.address_type = ta.id) AS
                                                                    tt_one_col)
                                                              ,'; ') adr_name
                              ,(SELECT MAX(ac.plan_date)
                                  FROM ins.doc_doc        dd
                                      ,ins.ac_payment     ac
                                      ,ins.document       d
                                      ,ins.doc_templ      dt
                                      ,ins.doc_status_ref rf
                                 WHERE dd.parent_id IN
                                       (SELECT p.policy_id
                                          FROM ins.p_policy p
                                         WHERE p.pol_header_id = ph.policy_header_id)
                                   AND dd.child_id = ac.payment_id
                                   AND ac.payment_id = d.document_id
                                   AND d.doc_templ_id = dt.doc_templ_id
                                   AND dt.brief = 'PAYMENT'
                                   AND d.doc_status_ref_id = rf.doc_status_ref_id
                                   AND rf.brief = 'PAID') plan_date
                          FROM ins.p_policy_agent_doc pad
                              ,ins.document           d
                              ,ins.p_pol_header       ph
                              ,ins.p_policy           pol
                              ,ins.t_contact_pol_role polr
                              ,ins.p_policy_contact   pcnt
                              ,ins.contact            cpol
                              ,ins.doc_status_ref     rf
                              ,ins.document           dc
                              ,ins.doc_status_ref     dsr
                              ,ins.document           dav
                              , --�������� ������ �� ��
                               ins.doc_status_ref     dsr_av --������ �������� ������ ��
                         WHERE pad.policy_header_id = ph.policy_header_id
                           AND pol.policy_id = ph.last_ver_id --policy_id
                           AND polr.brief = '������������'
                           AND pcnt.policy_id = pol.policy_id
                           AND pcnt.contact_policy_role_id = polr.id
                           AND cpol.contact_id = pcnt.contact_id
                           AND pad.p_policy_agent_doc_id = d.document_id
                           AND pol.end_date >= v_trans_date
                           AND d.doc_status_ref_id = rf.doc_status_ref_id
                           AND rf.brief = 'CURRENT'
                           AND pol.policy_id = dc.document_id
                           AND dc.doc_status_ref_id = dsr.doc_status_ref_id
                           AND dsr.brief NOT IN ('RECOVER'
                                                , --�������������� /������� 325234/
                                                 'READY_TO_CANCEL'
                                                , --��������� � �����������
                                                 --'STOPED',            --�������� /������� 325234/
                                                 'TO_QUIT'
                                                , --� �����������
                                                 'TO_QUIT_CHECK_READY'
                                                , --� �����������. ����� ��� ��������
                                                 'TO_QUIT_CHECKED'
                                                , --� �����������. ��������
                                                 'RECOVER_DENY'
                                                , --����� � ��������������
                                                 --'CANCEL',              --������� /������� 325234/
                                                 'QUIT'
                                                , --���������
                                                 'QUIT_REQ_QUERY'
                                                , --���������. ������ ����������
                                                 'QUIT_REQ_GET'
                                                , --���������. ��������� ��������
                                                 'QUIT_TO_PAY'
                                                , --���������.� �������
                                                 --'STOP',                --������������� /������� 325234/
                                                 'BREAK' --����������
                                                ,'QUIT_DECL' --��������� �� �����������
                                                ,'DECLINE_CALCULATION' --������ ����� �����������
                                                 )
                              --325234
                           AND ph.policy_id = dav.document_id
                           AND dav.doc_status_ref_id = dsr_av.doc_status_ref_id
                           AND dsr_av.brief NOT IN ('STOPED'
                                                   , --�������� 325234
                                                    'CANCEL'
                                                   , --������� 325234
                                                    'STOP' --������������� 325234
                                                    )
                        --325234--                  
                        
                        ) doc
                 WHERE agh.t_sales_channel_id = ch.id
                   AND agh.agent_id = c.contact_id
                   AND agh.ag_contract_header_id = v_ag_contract_header_id
                   AND ag.ag_contract_id = agh.last_ver_id
                   AND cat.ag_category_agent_id = ag.category_id
                   AND doc.ag_contract_header_id = agh.ag_contract_header_id
                   AND cat.brief = 'AG'
                UNION ALL
                SELECT '�����'
                      ,''
                      ,''
                      ,''
                      ,''
                      ,''
                      ,''
                      ,''
                      ,''
                  FROM ins.ven_ag_contract_header agh
                      ,ins.t_sales_channel        ch
                      ,ins.ag_contract            ag
                      ,ins.ag_category_agent      cat
                 WHERE agh.ag_contract_header_id = v_ag_contract_header_id
                   AND agh.t_sales_channel_id = ch.id
                   AND ag.ag_contract_id = agh.last_ver_id
                   AND cat.ag_category_agent_id = ag.category_id
                   AND cat.brief <> 'AG'
                UNION ALL
                SELECT '��������'
                      ,ag.personnel_number
                      ,c.obj_name_orig
                      ,doc.pol_num
                      ,doc.start_date
                      ,doc.holder
                      ,doc.tel_num
                      ,doc.adr_name
                      ,to_char(doc.plan_date, 'dd.mm.yyyy') plan_date
                  FROM ins.ven_ag_contract_header agh
                      ,ins.t_sales_channel ch
                      ,ins.contact c
                      ,ins.ag_contract ag
                      ,ins.ag_category_agent cat
                      ,(SELECT pol.pol_num
                              ,to_char(ph.start_date, 'dd.mm.yyyy') start_date
                              ,cpol.obj_name_orig holder
                              ,pad.ag_contract_header_id
                              ,pkg_utils.get_aggregated_string(CAST(MULTISET (SELECT tel.telephone_number
                                                                       FROM ins.cn_contact_telephone tel
                                                                           ,ins.t_telephone_type     t
                                                                      WHERE tel.contact_id =
                                                                            cpol.contact_id
                                                                        AND tel.telephone_type = t.id
                                                                        AND tel.status = 1
                                                                     /*AND tel.deleted = 0*/
                                                                     ) AS tt_one_col)
                                                              ,', ') tel_num
                              ,pkg_utils.get_aggregated_string(CAST(MULTISET
                                                                    (SELECT ta.description || '-' ||
                                                                            (CASE
                                                                              WHEN ca.province_name IS NULL THEN
                                                                               ca.name
                                                                              ELSE
                                                                               ins.pkg_contact.get_address_name(ca.id)
                                                                            END)
                                                                       FROM ins.cn_contact_address cca
                                                                           ,ins.cn_address         ca
                                                                           ,ins.t_address_type     ta
                                                                      WHERE cca.contact_id =
                                                                            cpol.contact_id
                                                                        AND cca.adress_id = ca.id
                                                                        AND cca.status = 1
                                                                        AND cca.address_type = ta.id) AS
                                                                    tt_one_col)
                                                              ,'; ') adr_name
                              ,(SELECT MAX(ac.plan_date)
                                  FROM ins.doc_doc        dd
                                      ,ins.ac_payment     ac
                                      ,ins.document       d
                                      ,ins.doc_templ      dt
                                      ,ins.doc_status_ref rf
                                 WHERE dd.parent_id IN
                                       (SELECT p.policy_id
                                          FROM ins.p_policy p
                                         WHERE p.pol_header_id = ph.policy_header_id)
                                   AND dd.child_id = ac.payment_id
                                   AND ac.payment_id = d.document_id
                                   AND d.doc_templ_id = dt.doc_templ_id
                                   AND dt.brief = 'PAYMENT'
                                   AND d.doc_status_ref_id = rf.doc_status_ref_id
                                   AND rf.brief = 'PAID') plan_date
                          FROM ins.p_policy_agent_doc pad
                              ,ins.document           d
                              ,ins.p_pol_header       ph
                              ,ins.p_policy           pol
                              ,ins.t_contact_pol_role polr
                              ,ins.p_policy_contact   pcnt
                              ,ins.contact            cpol
                              ,ins.doc_status_ref     rf
                              ,ins.document           dc
                              ,ins.doc_status_ref     dsr
                              ,ins.document           dav
                              , --�������� ������ �� ��
                               ins.doc_status_ref     dsr_av --������ �������� ������ ��
                         WHERE pad.policy_header_id = ph.policy_header_id
                           AND pol.policy_id = ph.last_ver_id --policy_id
                           AND polr.brief = '������������'
                           AND pcnt.policy_id = pol.policy_id
                           AND pcnt.contact_policy_role_id = polr.id
                           AND cpol.contact_id = pcnt.contact_id
                           AND pad.p_policy_agent_doc_id = d.document_id
                           AND pol.end_date >= v_trans_date
                           AND d.doc_status_ref_id = rf.doc_status_ref_id
                           AND rf.brief = 'CURRENT'
                           AND pol.policy_id = dc.document_id
                           AND dc.doc_status_ref_id = dsr.doc_status_ref_id
                           AND dsr.brief NOT IN ('RECOVER'
                                                , --�������������� /������� 325234/
                                                 'READY_TO_CANCEL'
                                                , --��������� � �����������
                                                 --'STOPED',            --�������� /������� 325234/
                                                 'TO_QUIT'
                                                , --� �����������
                                                 'TO_QUIT_CHECK_READY'
                                                , --� �����������. ����� ��� ��������
                                                 'TO_QUIT_CHECKED'
                                                , --� �����������. ��������
                                                 'RECOVER_DENY'
                                                , --����� � ��������������
                                                 --'CANCEL',              --������� /������� 325234/
                                                 'QUIT'
                                                , --���������
                                                 'QUIT_REQ_QUERY'
                                                , --���������. ������ ����������
                                                 'QUIT_REQ_GET'
                                                , --���������. ��������� ��������
                                                 'QUIT_TO_PAY'
                                                , --���������.� �������
                                                 --'STOP',                --������������� /������� 325234/
                                                 'BREAK' --����������
                                                ,'QUIT_DECL' --��������� �� �����������
                                                ,'DECLINE_CALCULATION' --������ ����� �����������
                                                 )
                              --325234
                           AND ph.policy_id = dav.document_id
                           AND dav.doc_status_ref_id = dsr_av.doc_status_ref_id
                           AND dsr_av.brief NOT IN ('STOPED'
                                                   , --�������� 325234
                                                    'CANCEL'
                                                   , --������� 325234
                                                    'STOP' --������������� 325234
                                                    )
                        --325234--
                        
                        ) doc
                 WHERE agh.t_sales_channel_id = ch.id
                   AND agh.agent_id = c.contact_id
                   AND agh.ag_contract_header_id = v_ag_contract_header_id
                   AND ag.ag_contract_id = agh.last_ver_id
                   AND cat.ag_category_agent_id = ag.category_id
                   AND doc.ag_contract_header_id = agh.ag_contract_header_id
                   AND cat.brief = 'MN'
                UNION ALL
                SELECT '��������'
                      ,(SELECT aghf.personnel_number
                         FROM ins.ag_contract            agl
                             ,ins.ven_ag_contract_header aghl
                             ,ins.ag_contract            aghf
                             ,ins.contact                cl
                        WHERE ag.contract_leader_id = agl.ag_contract_id
                          AND aghl.ag_contract_header_id = agl.contract_id
                          AND aghf.ag_contract_id = aghl.last_ver_id
                          AND aghl.agent_id = cl.contact_id
                          AND aghf.category_id IN (SELECT cat.ag_category_agent_id
                                                     FROM ins.ag_category_agent cat
                                                    WHERE cat.brief IN ('MN')))
                      ,(SELECT cl.obj_name_orig
                         FROM ins.ag_contract            agl
                             ,ins.ven_ag_contract_header aghl
                             ,ins.ag_contract            aghf
                             ,ins.contact                cl
                        WHERE ag.contract_leader_id = agl.ag_contract_id
                          AND aghl.ag_contract_header_id = agl.contract_id
                          AND aghf.ag_contract_id = aghl.last_ver_id
                          AND aghl.agent_id = cl.contact_id
                          AND aghf.category_id IN (SELECT cat.ag_category_agent_id
                                                     FROM ins.ag_category_agent cat
                                                    WHERE cat.brief IN ('MN')))
                      ,''
                      ,''
                      ,''
                      ,''
                      ,''
                      ,''
                  FROM ins.ven_ag_contract_header agh
                      ,ins.t_sales_channel        ch
                      ,ins.ag_contract            ag
                      ,ins.ag_category_agent      cat
                 WHERE agh.ag_contract_header_id = v_ag_contract_header_id
                   AND agh.t_sales_channel_id = ch.id
                   AND ag.ag_contract_id = agh.last_ver_id
                   AND cat.ag_category_agent_id = ag.category_id
                   AND cat.brief <> 'MN'
                UNION ALL
                SELECT '��������' prev_ag
                      ,ag.personnel_number
                      ,c.obj_name_orig
                      ,doc.pol_num
                      ,doc.start_date
                      ,doc.holder
                      ,doc.tel_num
                      ,doc.adr_name
                      ,to_char(doc.plan_date, 'dd.mm.yyyy') plan_date
                  FROM ins.ven_ag_contract_header agh
                      ,ins.t_sales_channel ch
                      ,ins.contact c
                      ,ins.ag_contract ag
                      ,ins.ag_category_agent cat
                      ,(SELECT pol.pol_num
                              ,to_char(ph.start_date, 'dd.mm.yyyy') start_date
                              ,cpol.obj_name_orig holder
                              ,pad.ag_contract_header_id
                              ,pkg_utils.get_aggregated_string(CAST(MULTISET (SELECT tel.telephone_number
                                                                       FROM ins.cn_contact_telephone tel
                                                                           ,ins.t_telephone_type     t
                                                                      WHERE tel.contact_id =
                                                                            cpol.contact_id
                                                                        AND tel.telephone_type = t.id
                                                                        AND tel.status = 1
                                                                     /*AND tel.deleted = 0*/
                                                                     ) AS tt_one_col)
                                                              ,', ') tel_num
                              ,pkg_utils.get_aggregated_string(CAST(MULTISET
                                                                    (SELECT ta.description || '-' ||
                                                                            (CASE
                                                                              WHEN ca.province_name IS NULL THEN
                                                                               ca.name
                                                                              ELSE
                                                                               ins.pkg_contact.get_address_name(ca.id)
                                                                            END)
                                                                       FROM ins.cn_contact_address cca
                                                                           ,ins.cn_address         ca
                                                                           ,ins.t_address_type     ta
                                                                      WHERE cca.contact_id =
                                                                            cpol.contact_id
                                                                        AND cca.adress_id = ca.id
                                                                        AND cca.status = 1
                                                                        AND cca.address_type = ta.id) AS
                                                                    tt_one_col)
                                                              ,'; ') adr_name
                              ,(SELECT MAX(ac.plan_date)
                                  FROM ins.doc_doc        dd
                                      ,ins.ac_payment     ac
                                      ,ins.document       d
                                      ,ins.doc_templ      dt
                                      ,ins.doc_status_ref rf
                                 WHERE dd.parent_id IN
                                       (SELECT p.policy_id
                                          FROM ins.p_policy p
                                         WHERE p.pol_header_id = ph.policy_header_id)
                                   AND dd.child_id = ac.payment_id
                                   AND ac.payment_id = d.document_id
                                   AND d.doc_templ_id = dt.doc_templ_id
                                   AND dt.brief = 'PAYMENT'
                                   AND d.doc_status_ref_id = rf.doc_status_ref_id
                                   AND rf.brief = 'PAID') plan_date
                          FROM ins.p_policy_agent_doc pad
                              ,ins.document           d
                              ,ins.p_pol_header       ph
                              ,ins.p_policy           pol
                              ,ins.t_contact_pol_role polr
                              ,ins.p_policy_contact   pcnt
                              ,ins.contact            cpol
                              ,ins.doc_status_ref     rf
                              ,ins.document           dc
                              ,ins.doc_status_ref     dsr
                              ,ins.document           dav
                              , --�������� ������ �� ��
                               ins.doc_status_ref     dsr_av --������ �������� ������ ��
                        
                         WHERE pad.policy_header_id = ph.policy_header_id
                           AND pol.policy_id = ph.last_ver_id --policy_id
                           AND polr.brief = '������������'
                           AND pcnt.policy_id = pol.policy_id
                           AND pcnt.contact_policy_role_id = polr.id
                           AND cpol.contact_id = pcnt.contact_id
                           AND pad.p_policy_agent_doc_id = d.document_id
                           AND pol.end_date >= v_trans_date
                           AND d.doc_status_ref_id = rf.doc_status_ref_id
                           AND rf.brief = 'CURRENT'
                           AND pol.policy_id = dc.document_id
                           AND dc.doc_status_ref_id = dsr.doc_status_ref_id
                           AND dsr.brief NOT IN ('RECOVER'
                                                , --�������������� /������� 325234/
                                                 'READY_TO_CANCEL'
                                                , --��������� � �����������
                                                 --'STOPED',            --�������� /������� 325234/
                                                 'TO_QUIT'
                                                , --� �����������
                                                 'TO_QUIT_CHECK_READY'
                                                , --� �����������. ����� ��� ��������
                                                 'TO_QUIT_CHECKED'
                                                , --� �����������. ��������
                                                 'RECOVER_DENY'
                                                , --����� � ��������������
                                                 --'CANCEL',              --������� /������� 325234/
                                                 'QUIT'
                                                , --���������
                                                 'QUIT_REQ_QUERY'
                                                , --���������. ������ ����������
                                                 'QUIT_REQ_GET'
                                                , --���������. ��������� ��������
                                                 'QUIT_TO_PAY'
                                                , --���������.� �������
                                                 --'STOP',                --������������� /������� 325234/
                                                 'BREAK' --����������
                                                ,'QUIT_DECL' --��������� �� �����������
                                                ,'DECLINE_CALCULATION' --������ ����� �����������
                                                 )
                              --325234
                           AND ph.policy_id = dav.document_id
                           AND dav.doc_status_ref_id = dsr_av.doc_status_ref_id
                           AND dsr_av.brief NOT IN ('STOPED'
                                                   , --�������� 325234
                                                    'CANCEL'
                                                   , --������� 325234
                                                    'STOP' --������������� 325234
                                                    )
                        --325234--
                        
                        ) doc
                 WHERE agh.t_sales_channel_id = ch.id
                   AND agh.agent_id = c.contact_id
                   AND agh.ag_contract_header_id = v_ag_contract_header_id
                   AND ag.ag_contract_id = agh.last_ver_id
                   AND cat.ag_category_agent_id = ag.category_id
                   AND doc.ag_contract_header_id = agh.ag_contract_header_id
                   AND cat.brief IN ('DR', 'DR2')
                UNION ALL
                SELECT '��������'
                      ,(SELECT aghf.personnel_number
                         FROM ins.ag_contract            agl
                             ,ins.ven_ag_contract_header aghl
                             ,ins.ag_contract            agd
                             ,ins.ag_contract            gdl
                             ,ins.ven_ag_contract_header aghd
                             ,ins.ag_contract            aghf
                        WHERE ag.contract_leader_id = agl.ag_contract_id
                          AND agl.contract_id = aghl.ag_contract_header_id
                          AND aghl.last_ver_id = agd.ag_contract_id
                          AND agd.contract_leader_id = gdl.ag_contract_id
                          AND gdl.contract_id = aghd.ag_contract_header_id
                          AND aghd.last_ver_id = aghf.ag_contract_id
                          AND gdl.category_id IN
                              (SELECT cat.ag_category_agent_id
                                 FROM ins.ag_category_agent cat
                                WHERE cat.brief IN ('DR', 'DR2'))
                       UNION ALL
                       SELECT aghf.personnel_number
                         FROM ins.ag_contract            agl
                             ,ins.ven_ag_contract_header aghl
                             ,ins.ag_contract            aghf
                             ,ins.contact                cl
                        WHERE ag.contract_leader_id = agl.ag_contract_id
                          AND aghl.ag_contract_header_id = agl.contract_id
                          AND aghf.ag_contract_id = aghl.last_ver_id
                          AND aghl.agent_id = cl.contact_id
                          AND aghf.category_id IN
                              (SELECT cat.ag_category_agent_id
                                 FROM ins.ag_category_agent cat
                                WHERE cat.brief IN ('DR', 'DR2')))
                      ,(SELECT c.obj_name_orig
                         FROM ins.ag_contract            agl
                             ,ins.ven_ag_contract_header aghl
                             ,ins.ag_contract            agd
                             ,ins.ag_contract            gdl
                             ,ins.ven_ag_contract_header aghd
                             ,ins.contact                c
                        WHERE ag.contract_leader_id = agl.ag_contract_id
                          AND agl.contract_id = aghl.ag_contract_header_id
                          AND aghl.last_ver_id = agd.ag_contract_id
                          AND agd.contract_leader_id = gdl.ag_contract_id
                          AND gdl.contract_id = aghd.ag_contract_header_id
                          AND aghd.agent_id = c.contact_id
                          AND gdl.category_id IN
                              (SELECT cat.ag_category_agent_id
                                 FROM ins.ag_category_agent cat
                                WHERE cat.brief IN ('DR', 'DR2'))
                       UNION ALL
                       SELECT cl.obj_name_orig
                         FROM ins.ag_contract            agl
                             ,ins.ven_ag_contract_header aghl
                             ,ins.ag_contract            aghf
                             ,ins.contact                cl
                        WHERE ag.contract_leader_id = agl.ag_contract_id
                          AND aghl.ag_contract_header_id = agl.contract_id
                          AND aghf.ag_contract_id = aghl.last_ver_id
                          AND aghl.agent_id = cl.contact_id
                          AND aghf.category_id IN
                              (SELECT cat.ag_category_agent_id
                                 FROM ins.ag_category_agent cat
                                WHERE cat.brief IN ('DR', 'DR2')))
                      ,''
                      ,''
                      ,''
                      ,''
                      ,''
                      ,''
                  FROM ins.ven_ag_contract_header agh
                      ,ins.t_sales_channel        ch
                      ,ins.ag_contract            ag
                      ,ins.ag_category_agent      cat
                 WHERE agh.ag_contract_header_id = v_ag_contract_header_id
                   AND agh.t_sales_channel_id = ch.id
                   AND ag.ag_contract_id = agh.last_ver_id
                   AND cat.ag_category_agent_id = ag.category_id
                   AND cat.brief NOT IN ('DR', 'DR2', 'TD'))
    LOOP
      pkg_rep_plpdf.gv_datas(1) := cur.prev_ag;
      pkg_rep_plpdf.gv_datas(2) := cur.num;
      pkg_rep_plpdf.gv_datas(3) := cur.obj_name_orig;
      pkg_rep_plpdf.gv_datas(4) := cur.pol_num;
      pkg_rep_plpdf.gv_datas(5) := cur.start_date;
      pkg_rep_plpdf.gv_datas(6) := cur.holder;
      pkg_rep_plpdf.gv_datas(7) := cur.tel_num;
      pkg_rep_plpdf.gv_datas(8) := cur.adr_name;
      pkg_rep_plpdf.gv_datas(9) := cur.plan_date;
      plpdf.row_print2(p_data     => pkg_rep_plpdf.gv_datas
                      ,p_border   => pkg_rep_plpdf.gv_borders
                      ,p_width    => pkg_rep_plpdf.gv_widths
                      ,p_align    => pkg_rep_plpdf.gv_aligns
                      ,p_style    => pkg_rep_plpdf.gv_styles
                      ,p_clipping => 0
                      ,p_h        => 4
                      ,p_maxline  => pkg_rep_plpdf.gv_maxlines);
      NULL;
    END LOOP;
  
    -- ������� 2 - �������� �������
    plpdf.setprintfont(p_size => 8);
    plpdf.linebreak(p_h => 3);
    plpdf.printcell(p_txt   => '������� � 2. ����� ��������� ��������� ������'
                   ,p_h     => -1
                   ,p_align => 'L'
                   ,p_ln    => 1);
    plpdf.setprintfont(p_size => 6);
  
    -- ������� 2 - ��������� �������
    pkg_rep_plpdf.delete_row_print_cache;
  
    pkg_rep_plpdf.gv_widths(1) := 70;
    pkg_rep_plpdf.gv_widths(2) := 70;
    pkg_rep_plpdf.gv_widths(3) := 70;
    pkg_rep_plpdf.gv_widths(4) := 70;
  
    FOR i IN 1 .. 4
    LOOP
      pkg_rep_plpdf.gv_borders(i) := 1;
      pkg_rep_plpdf.gv_aligns(i) := 'C';
      pkg_rep_plpdf.gv_styles(i) := NULL;
    END LOOP;
  
    -- ������� 2 - �������� ������� �������
    pkg_rep_plpdf.gv_datas(1) := '�����';
    pkg_rep_plpdf.gv_datas(2) := '��������';
    pkg_rep_plpdf.gv_datas(3) := '��������';
    pkg_rep_plpdf.gv_datas(4) := '��������������� ��������';
    plpdf.row_print2(p_data     => pkg_rep_plpdf.gv_datas
                    ,p_border   => pkg_rep_plpdf.gv_borders
                    ,p_width    => pkg_rep_plpdf.gv_widths
                    ,p_align    => pkg_rep_plpdf.gv_aligns
                    ,p_style    => pkg_rep_plpdf.gv_styles
                    ,p_clipping => 0
                    ,p_h        => 4
                    ,p_maxline  => pkg_rep_plpdf.gv_maxlines);
  
    -- ������� 2 - ��������� �������
    pkg_rep_plpdf.delete_row_print_cache;
  
    pkg_rep_plpdf.gv_widths(1) := 15;
    pkg_rep_plpdf.gv_widths(2) := 15;
    pkg_rep_plpdf.gv_widths(3) := 40;
    pkg_rep_plpdf.gv_widths(4) := 15;
    pkg_rep_plpdf.gv_widths(5) := 15;
    pkg_rep_plpdf.gv_widths(6) := 40;
    pkg_rep_plpdf.gv_widths(7) := 15;
    pkg_rep_plpdf.gv_widths(8) := 15;
    pkg_rep_plpdf.gv_widths(9) := 40;
    pkg_rep_plpdf.gv_widths(10) := 15;
    pkg_rep_plpdf.gv_widths(11) := 15;
    pkg_rep_plpdf.gv_widths(12) := 40;
  
    FOR i IN 1 .. 12
    LOOP
      pkg_rep_plpdf.gv_borders(i) := 1;
      pkg_rep_plpdf.gv_aligns(i) := 'C';
      pkg_rep_plpdf.gv_styles(i) := NULL;
    END LOOP;
  
    -- ������� 2 - �������� ������� �������
    pkg_rep_plpdf.gv_datas(1) := '��';
    pkg_rep_plpdf.gv_datas(2) := '��� ��������� ����';
    pkg_rep_plpdf.gv_datas(3) := '���';
    pkg_rep_plpdf.gv_datas(4) := '��������� �����';
    pkg_rep_plpdf.gv_datas(5) := '��� ��������� ����';
    pkg_rep_plpdf.gv_datas(6) := '���';
    pkg_rep_plpdf.gv_datas(7) := '��������� �����';
    pkg_rep_plpdf.gv_datas(8) := '��� ��������� ����';
    pkg_rep_plpdf.gv_datas(9) := '���';
    pkg_rep_plpdf.gv_datas(10) := '��������� �����';
    pkg_rep_plpdf.gv_datas(11) := '��� ��������� ����';
    pkg_rep_plpdf.gv_datas(12) := '���';
    plpdf.row_print2(p_data     => pkg_rep_plpdf.gv_datas
                    ,p_border   => pkg_rep_plpdf.gv_borders
                    ,p_width    => pkg_rep_plpdf.gv_widths
                    ,p_align    => pkg_rep_plpdf.gv_aligns
                    ,p_style    => pkg_rep_plpdf.gv_styles
                    ,p_clipping => 0
                    ,p_h        => 4
                    ,p_maxline  => pkg_rep_plpdf.gv_maxlines);
  
    -- ������� 2 - ������
    FOR i IN 1 .. 12
    LOOP
      pkg_rep_plpdf.gv_aligns(i) := 'J';
    END LOOP;
    SELECT max(case agent_category when 'AG' then num end) ag_num,
           max(case agent_category when 'AG' then sales_channel end) ag_sales_channel,
           max(case agent_category when 'AG' then agent_name end) ag_agent_name,
           max(case agent_category when 'MN' then num end) mn_num,
           max(case agent_category when 'MN' then sales_channel end) mn_sales_channel,
           max(case agent_category when 'MN' then agent_name end) mn_agent_name,
           max(case when agent_category in ('DR','DR2') then num end) dr_num,
           max(case when agent_category in ('DR','DR2') then sales_channel end) dr_sales_channel,
           max(case when agent_category in ('DR','DR2') then agent_name end) dr_agent_name,
           max(case agent_category when 'TD' then num end) td_num,
           max(case agent_category when 'TD' then sales_channel end) td_sales_channel,
           max(case agent_category when 'TD' then agent_name end) td_agent_name
    INTO v_ag_num
        ,v_ag_sales_channel
        ,v_ag_agent_name
        ,v_mn_num
        ,v_mn_sales_channel
        ,v_mn_agent_name
        ,v_dr_num
        ,v_dr_sales_channel
        ,v_dr_agent_name
        ,v_td_num
        ,v_td_sales_channel
        ,v_td_agent_name
    FROM ( SELECT LEVEL,
                  aca.brief agent_category,
                  DECODE (aca.brief,
                          'AG', ach.num,
                          ac.personnel_number) num,
                  NVL (ac_ch.description, ach_ch.description) sales_channel,
                  c.obj_name_orig agent_name,
                  ROW_NUMBER () OVER (PARTITION BY CASE WHEN aca.brief = 'AG' THEN 1
                                                        WHEN aca.brief = 'MN' THEN 2
                                                        WHEN aca.brief IN ('DR', 'DR2') THEN 3
                                                        WHEN aca.brief = 'TD' THEN 4
                                                   END
                                      ORDER BY LEVEL)  rn
           FROM  ag_agent_tree aat
                ,ven_ag_contract_header ach
                ,ag_contract ac
                ,contact c
                ,ag_category_agent aca
                ,t_sales_channel ach_ch
                ,t_sales_channel ac_ch
           WHERE     aat.ag_contract_header_id = ach.ag_contract_header_id
                 AND ach.ag_contract_header_id = ac.contract_id
                 AND ach.agent_id = c.contact_id
                 AND ac.category_id = aca.ag_category_agent_id
                 AND ach_ch.id = ach.t_sales_channel_id
                 AND ac.ag_sales_chn_id = ac_ch.id
                 AND TRUNC (v_trans_date) BETWEEN ach.date_begin AND ach.date_break
                 AND TRUNC (v_trans_date) BETWEEN ac.date_begin AND ac.date_end
                 AND TRUNC (v_trans_date) BETWEEN aat.date_begin AND aat.date_end
                 AND aca.brief IN ('AG', 'MN', 'DR', 'DR2', 'TD')
                 AND LEVEL <= 4
           START WITH     aat.ag_contract_header_id = v_trans_ag_contract_header_id
                      AND TRUNC (v_trans_date) BETWEEN aat.date_begin AND aat.date_end
                      AND TRUNC (v_trans_date) BETWEEN ac.date_begin AND ac.date_end
                      AND TRUNC (v_trans_date) BETWEEN aat.date_begin AND aat.date_end
           CONNECT BY PRIOR aat.ag_parent_header_id = aat.ag_contract_header_id
                        AND TRUNC (v_trans_date) BETWEEN ach.date_begin AND ach.date_break
                        AND TRUNC (v_trans_date) BETWEEN ac.date_begin AND ac.date_end
                        AND TRUNC (v_trans_date) BETWEEN aat.date_begin AND aat.date_end) 
           WHERE rn = 1;
    pkg_rep_plpdf.gv_datas(1) := v_ag_num;
    pkg_rep_plpdf.gv_datas(2) := v_ag_sales_channel;
    pkg_rep_plpdf.gv_datas(3) := v_ag_agent_name;
    pkg_rep_plpdf.gv_datas(4) := v_mn_num;
    pkg_rep_plpdf.gv_datas(5) := v_mn_sales_channel;
    pkg_rep_plpdf.gv_datas(6) := v_mn_agent_name;
    pkg_rep_plpdf.gv_datas(7) := v_dr_num;
    pkg_rep_plpdf.gv_datas(8) := v_dr_sales_channel;
    pkg_rep_plpdf.gv_datas(9) := v_dr_agent_name;
    pkg_rep_plpdf.gv_datas(10) := v_td_num;
    pkg_rep_plpdf.gv_datas(11) := v_td_sales_channel;
    pkg_rep_plpdf.gv_datas(12) := v_td_agent_name;
    plpdf.row_print2(p_data     => pkg_rep_plpdf.gv_datas
                    ,p_border   => pkg_rep_plpdf.gv_borders
                    ,p_width    => pkg_rep_plpdf.gv_widths
                    ,p_align    => pkg_rep_plpdf.gv_aligns
                    ,p_style    => pkg_rep_plpdf.gv_styles
                    ,p_clipping => 0
                    ,p_h        => 4
                    ,p_maxline  => pkg_rep_plpdf.gv_maxlines);
  
    plpdf.setprintfont(p_size => 8);
    plpdf.linebreak(p_h => 3);
    v_str := '2. ��������� ��� ������-�������� ��������� ����������� ��������� � ���� �����������, �� ������ ���������� ��� ' ||
             v_trans_agent_cat_genitive || ' � �����������.';
    plpdf.printmultilinecell(p_txt => v_str, p_align => 'J', p_h => -1, p_ln => 1);
  
    -- ������ �����������
    plpdf.linebreak(p_h => 10);
  
    IF plpdf.checkpagebreak(100)
    THEN
      NULL;
    END IF;
  
    plpdf.printmultilinecell(p_txt    => '�������:' || chr(13) || chr(13)
                            ,p_w      => plpdf.getpagespace * 1 / 2
                            ,p_h      => -1
                            ,p_align  => 'L'
                            ,p_ln     => 0
                            ,p_border => 0);
    plpdf.printmultilinecell(p_txt    => '������:' || chr(13) || chr(13)
                            ,p_w      => plpdf.getpagespace
                            ,p_h      => -1
                            ,p_align  => 'L'
                            ,p_ln     => 1
                            ,p_border => 0);
    plpdf.printmultilinecell(p_txt    => '�� ����� �����������' || chr(13) || chr(13)
                            ,p_w      => plpdf.getpagespace * 1 / 2
                            ,p_h      => -1
                            ,p_align  => 'L'
                            ,p_ln     => 0
                            ,p_border => 0);
    CASE
      WHEN v_ag_agent_name IS NOT NULL THEN
        v_str := '�����';
      WHEN v_mn_agent_name IS NOT NULL THEN
        v_str := '��������';
      WHEN v_dr_agent_name IS NOT NULL THEN
        v_str := '��������';
      WHEN v_td_agent_name IS NOT NULL THEN
        v_str := '��������������� ��������';
    END CASE;
    plpdf.printmultilinecell(p_txt    => v_str || ':' || chr(13) || chr(13)
                            ,p_w      => plpdf.getpagespace
                            ,p_h      => -1
                            ,p_align  => 'L'
                            ,p_ln     => 1
                            ,p_border => 0);
    plpdf.printmultilinecell(p_txt    => ' _________________      /____________________________________/'
                            ,p_w      => plpdf.getpagespace * 1 / 2
                            ,p_h      => -1
                            ,p_align  => 'L'
                            ,p_ln     => 0
                            ,p_border => 0);
    plpdf.printmultilinecell(p_txt    => ' _________________      /____________________________________/'
                            ,p_w      => plpdf.getpagespace
                            ,p_h      => -1
                            ,p_align  => 'L'
                            ,p_ln     => 1
                            ,p_border => 0);
    plpdf.setprintfont(p_size => 5);
    plpdf.printmultilinecell(p_txt    => '                     (�������)                                                                                  (���)'
                            ,p_w      => plpdf.getpagespace * 1 / 2
                            ,p_h      => -1
                            ,p_align  => 'L'
                            ,p_ln     => 0
                            ,p_border => 0);
    plpdf.printmultilinecell(p_txt    => '                     (�������)                                                                                  (���)'
                            ,p_w      => plpdf.getpagespace
                            ,p_h      => -1
                            ,p_align  => 'L'
                            ,p_ln     => 1
                            ,p_border => 0);
    IF v_mn_agent_name IS NOT NULL
       AND v_str != '��������'
    THEN
      plpdf.setprintfont(p_size => 8);
      plpdf.printmultilinecell(p_txt => NULL, p_w => plpdf.getpagespace * 1 / 2, p_h => -1, p_ln => 0);
      plpdf.printmultilinecell(p_txt    => chr(13) || '��������:' || chr(13) || chr(13)
                              ,p_w      => plpdf.getpagespace
                              ,p_h      => -1
                              ,p_align  => 'L'
                              ,p_ln     => 1
                              ,p_border => 0);
      plpdf.printmultilinecell(p_txt => NULL, p_w => plpdf.getpagespace * 1 / 2, p_h => -1, p_ln => 0);
      plpdf.printmultilinecell(p_txt    => ' _________________      /____________________________________/'
                              ,p_w      => plpdf.getpagespace
                              ,p_h      => -1
                              ,p_align  => 'L'
                              ,p_ln     => 1
                              ,p_border => 0);
      plpdf.printmultilinecell(p_txt => NULL, p_w => plpdf.getpagespace * 1 / 2, p_h => -1, p_ln => 0);
      plpdf.setprintfont(p_size => 5);
      plpdf.printmultilinecell(p_txt    => '                     (�������)                                                                                  (���)'
                              ,p_w      => plpdf.getpagespace * 1 / 2
                              ,p_h      => -1
                              ,p_align  => 'L'
                              ,p_ln     => 1
                              ,p_border => 0);
    
    END IF;
    IF v_dr_agent_name IS NOT NULL
       AND v_str != '��������'
    THEN
      plpdf.setprintfont(p_size => 8);
      plpdf.printmultilinecell(p_txt => NULL, p_w => plpdf.getpagespace * 1 / 2, p_h => -1, p_ln => 0);
      plpdf.printmultilinecell(p_txt    => chr(13) || '��������:' || chr(13) || chr(13)
                              ,p_w      => plpdf.getpagespace
                              ,p_h      => -1
                              ,p_align  => 'L'
                              ,p_ln     => 1
                              ,p_border => 0);
      plpdf.printmultilinecell(p_txt => NULL, p_w => plpdf.getpagespace * 1 / 2, p_h => -1, p_ln => 0);
      plpdf.printmultilinecell(p_txt    => ' _________________      /____________________________________/'
                              ,p_w      => plpdf.getpagespace
                              ,p_h      => -1
                              ,p_align  => 'L'
                              ,p_ln     => 1
                              ,p_border => 0);
      plpdf.printmultilinecell(p_txt => NULL, p_w => plpdf.getpagespace * 1 / 2, p_h => -1, p_ln => 0);
      plpdf.setprintfont(p_size => 5);
      plpdf.printmultilinecell(p_txt    => '                     (�������)                                                                                  (���)'
                              ,p_w      => plpdf.getpagespace * 1 / 2
                              ,p_h      => -1
                              ,p_align  => 'L'
                              ,p_ln     => 1
                              ,p_border => 0);
    END IF;
    IF v_td_agent_name IS NOT NULL
       AND v_str != '��������������� ��������'
    THEN
      plpdf.setprintfont(p_size => 8);
      plpdf.printmultilinecell(p_txt => NULL, p_w => plpdf.getpagespace * 1 / 2, p_h => -1, p_ln => 0);
      plpdf.printmultilinecell(p_txt    => chr(13) || '��������������� ��������:' || chr(13) ||
                                           chr(13)
                              ,p_w      => plpdf.getpagespace
                              ,p_h      => -1
                              ,p_align  => 'L'
                              ,p_ln     => 1
                              ,p_border => 0);
      plpdf.printmultilinecell(p_txt => NULL, p_w => plpdf.getpagespace * 1 / 2, p_h => -1, p_ln => 0);
      plpdf.printmultilinecell(p_txt    => ' _________________      /____________________________________/'
                              ,p_w      => plpdf.getpagespace
                              ,p_h      => -1
                              ,p_align  => 'L'
                              ,p_ln     => 1
                              ,p_border => 0);
      plpdf.printmultilinecell(p_txt => NULL, p_w => plpdf.getpagespace * 1 / 2, p_h => -1, p_ln => 0);
      plpdf.setprintfont(p_size => 5);
      plpdf.printmultilinecell(p_txt    => '                     (�������)                                                                                  (���)'
                              ,p_w      => plpdf.getpagespace * 1 / 2
                              ,p_h      => -1
                              ,p_align  => 'L'
                              ,p_ln     => 1
                              ,p_border => 0);
    END IF;
    plpdf.setprintfont(p_size => 8);
    plpdf.printmultilinecell(p_txt    => chr(13) || chr(13) ||
                                         '�____� _______________________ 201_ �.'
                            ,p_w      => plpdf.getpagespace * 1 / 2
                            ,p_h      => -1
                            ,p_align  => 'L'
                            ,p_ln     => 0
                            ,p_border => 0);
    plpdf.printmultilinecell(p_txt    => chr(13) || chr(13) ||
                                         '�____� _______________________ 201_ �.'
                            ,p_w      => plpdf.getpagespace
                            ,p_h      => -1
                            ,p_align  => 'L'
                            ,p_ln     => 0
                            ,p_border => 0);
  
    plpdf.senddoc(p_blob => par_data);
    par_file_name    := 'rep_policy_transfer_act_cp_' || v_ag_contract_number || '.pdf';
    par_content_type := pkg_rep_plpdf.gc_pdf_content_type;
  END rep_policy_transfer_act_cp;

  /* 
    ��������� ������������ ������ "��� ������ ��������� ��������� ����", �������
    ����������� �� ����� AGENCY_JOURNAL
    
    415345: ��� ������ ��������� ��������� ����
    ����� �., 22.05.2015
  */
  PROCEDURE rep_agent_structure_verify_act
  (
    par_content_type OUT VARCHAR2
   ,par_file_name    OUT VARCHAR2
   ,par_data         OUT NOCOPY BLOB
  ) IS
    v_agency_id        ag_contract_header.ag_contract_header_id%TYPE;
    v_date_begin       DATE;
    v_act_date         DATE;
    v_reporting_period VARCHAR2(100);
    v_agency           department.name%TYPE;
    v_x                NUMBER;
    v_y                NUMBER;
    j                  NUMBER := 0;
    v_td_ind           NUMBER := 0;
    v_dr_ind           NUMBER := 0;
    v_mn_ind           NUMBER := 0;
  BEGIN
    v_agency_id  := to_number(repcore.get_context('P_DEPT_ID'));
    v_date_begin := to_date(repcore.get_context('P_DATE_BEGIN'), 'dd.mm.yyyy');
    v_act_date   := SYSDATE;
  
    v_reporting_period := CASE extract(MONTH FROM v_act_date) - 1
                            WHEN 1 THEN
                             '������ ' || to_char(extract(YEAR FROM ADD_MONTHS(v_act_date, -1)))
                            WHEN 2 THEN
                             '������� ' || to_char(extract(YEAR FROM ADD_MONTHS(v_act_date, -1)))
                            WHEN 3 THEN
                             '���� ' || to_char(extract(YEAR FROM ADD_MONTHS(v_act_date, -1)))
                            WHEN 4 THEN
                             '������ ' || to_char(extract(YEAR FROM ADD_MONTHS(v_act_date, -1)))
                            WHEN 5 THEN
                             '��� ' || to_char(extract(YEAR FROM ADD_MONTHS(v_act_date, -1)))
                            WHEN 6 THEN
                             '���� ' || to_char(extract(YEAR FROM ADD_MONTHS(v_act_date, -1)))
                            WHEN 7 THEN
                             '���� ' || to_char(extract(YEAR FROM ADD_MONTHS(v_act_date, -1)))
                            WHEN 8 THEN
                             '������ ' || to_char(extract(YEAR FROM ADD_MONTHS(v_act_date, -1)))
                            WHEN 9 THEN
                             '�������� ' || to_char(extract(YEAR FROM ADD_MONTHS(v_act_date, -1)))
                            WHEN 10 THEN
                             '������� ' || to_char(extract(YEAR FROM ADD_MONTHS(v_act_date, -1)))
                            WHEN 11 THEN
                             '������ ' || to_char(extract(YEAR FROM ADD_MONTHS(v_act_date, -1)))
                            WHEN 12 THEN
                             '������� ' || to_char(extract(YEAR FROM ADD_MONTHS(v_act_date, -1)))
                          END;
  
    BEGIN
      SELECT d.name INTO v_agency FROM department d WHERE d.department_id = v_agency_id;
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20001
                               ,'�� ������� ����� ���������� �� ��������������: department_id');
    END;
  
    plpdf.init(p_orientation => 'L');
    pkg_rep_plpdf.font_init;
    plpdf.setencoding(p_enc => plpdf_const.cp1251);
    plpdf.newpage;
    plpdf.setprintfont(p_family => 'Times', p_style => NULL, p_size => 8);
  
    plpdf.printcell(p_txt   => '��� ������ ��������� ��������� � ������������ �����'
                   ,p_h     => -1
                   ,p_align => 'C'
                   ,p_ln    => 1);
  
    plpdf.printcell(p_txt => '���������: ' || v_agency, p_h => -1, p_align => 'L', p_ln => 1);
  
    plpdf.printcell(p_txt   => '�������� ������: ' || v_reporting_period
                   ,p_h     => -1
                   ,p_align => 'L'
                   ,p_ln    => 1);
  
    plpdf.printcell(p_txt   => '���� �����������: ' || to_char(v_act_date, 'dd.mm.yyyy')
                   ,p_h     => -1
                   ,p_align => 'L'
                   ,p_ln    => 1);
  
    -- ������� 1 - �������� ������� �������
    plpdf.linebreak(p_h => 3);
    plpdf.setprintfont(p_size => 6);
    plpdf.printcell(p_txt    => '� �/�'
                   ,p_w      => 7.5
                   ,p_h      => 21.25
                   ,p_align  => 'C'
                   ,p_ln     => 0
                   ,p_border => 1);
    plpdf.printcell(p_txt    => '��������������� ��������'
                   ,p_w      => 55
                   ,p_h      => 5
                   ,p_align  => 'C'
                   ,p_ln     => 0
                   ,p_border => 1);
    plpdf.printcell(p_txt    => '��������'
                   ,p_w      => 72.5
                   ,p_h      => 5
                   ,p_align  => 'C'
                   ,p_ln     => 0
                   ,p_border => 1);
    plpdf.printcell(p_txt    => '��������'
                   ,p_w      => 55
                   ,p_h      => 5
                   ,p_align  => 'C'
                   ,p_ln     => 0
                   ,p_border => 1);
    v_x := plpdf.getcurrentx;
    v_y := plpdf.getcurrenty;
    plpdf.printcell(p_txt    => '�����'
                   ,p_w      => 55
                   ,p_h      => 5
                   ,p_align  => 'C'
                   ,p_ln     => 1
                   ,p_border => 1);
    plpdf.printmultilinecell(p_txt => '', p_align => 'J', p_w => 7.5, p_h => 10, p_ln => 0);
  
    pkg_rep_plpdf.delete_row_print_cache;
  
    pkg_rep_plpdf.gv_widths(1) := 10;
    pkg_rep_plpdf.gv_widths(2) := 17.5;
    pkg_rep_plpdf.gv_widths(3) := 10;
    pkg_rep_plpdf.gv_widths(4) := 17.5;
    pkg_rep_plpdf.gv_widths(5) := 10;
    pkg_rep_plpdf.gv_widths(6) := 17.5;
    pkg_rep_plpdf.gv_widths(7) := 10;
    pkg_rep_plpdf.gv_widths(8) := 17.5;
    pkg_rep_plpdf.gv_widths(9) := 17.5;
    pkg_rep_plpdf.gv_widths(10) := 10;
    pkg_rep_plpdf.gv_widths(11) := 17.5;
    pkg_rep_plpdf.gv_widths(12) := 10;
    pkg_rep_plpdf.gv_widths(13) := 17.5;
    pkg_rep_plpdf.gv_widths(14) := 10;
    pkg_rep_plpdf.gv_widths(15) := 17.5;
    pkg_rep_plpdf.gv_widths(16) := 10;
    pkg_rep_plpdf.gv_widths(17) := 17.5;
  
    FOR i IN 1 .. 17
    LOOP
      pkg_rep_plpdf.gv_borders(i) := 1;
      pkg_rep_plpdf.gv_aligns(i) := 'C';
      pkg_rep_plpdf.gv_styles(i) := NULL;
    END LOOP;
  
    pkg_rep_plpdf.gv_datas(1) := '��� ��������� ����';
    pkg_rep_plpdf.gv_datas(2) := '���������';
    pkg_rep_plpdf.gv_datas(3) := '��������� �����';
    pkg_rep_plpdf.gv_datas(4) := '���';
    pkg_rep_plpdf.gv_datas(5) := '��� ��������� ����';
    pkg_rep_plpdf.gv_datas(6) := '���������';
    pkg_rep_plpdf.gv_datas(7) := '��������� �����';
    pkg_rep_plpdf.gv_datas(8) := '���';
    pkg_rep_plpdf.gv_datas(9) := '��������� ���������';
    pkg_rep_plpdf.gv_datas(10) := '��� ��������� ����';
    pkg_rep_plpdf.gv_datas(11) := '���������';
    pkg_rep_plpdf.gv_datas(12) := '��������� �����';
    pkg_rep_plpdf.gv_datas(13) := '���';
    pkg_rep_plpdf.gv_datas(14) := '��� ��������� ����';
    pkg_rep_plpdf.gv_datas(15) := '���������';
    pkg_rep_plpdf.gv_datas(16) := '� ��';
    pkg_rep_plpdf.gv_datas(17) := '���';
    plpdf.row_print2(p_data     => pkg_rep_plpdf.gv_datas
                    ,p_border   => pkg_rep_plpdf.gv_borders
                    ,p_width    => pkg_rep_plpdf.gv_widths
                    ,p_align    => pkg_rep_plpdf.gv_aligns
                    ,p_style    => pkg_rep_plpdf.gv_styles
                    ,p_clipping => 0
                    ,p_h        => 5.4
                    ,p_maxline  => pkg_rep_plpdf.gv_maxlines);
  
    plpdf.setcurrentxy(v_x + 55, v_y);
    pkg_rep_plpdf.delete_row_print_cache;
    pkg_rep_plpdf.gv_widths(1) := 35;
    pkg_rep_plpdf.gv_borders(1) := 1;
    pkg_rep_plpdf.gv_aligns(1) := 'C';
    pkg_rep_plpdf.gv_styles(1) := NULL;
    pkg_rep_plpdf.gv_datas(1) := '����������: ���, ����������, ���� �����������, ���������� � �������� ��/��������� � ������/��������� �� ��������� ��� ���������';
    plpdf.row_print2(p_data     => pkg_rep_plpdf.gv_datas
                    ,p_border   => pkg_rep_plpdf.gv_borders
                    ,p_width    => pkg_rep_plpdf.gv_widths
                    ,p_align    => pkg_rep_plpdf.gv_aligns
                    ,p_style    => pkg_rep_plpdf.gv_styles
                    ,p_clipping => 0
                    ,p_h        => 4.25
                    ,p_maxline  => pkg_rep_plpdf.gv_maxlines);
  
    -- ������� 1 - ������
    pkg_rep_plpdf.delete_row_print_cache;
  
    pkg_rep_plpdf.gv_widths(1) := 7.5;
    pkg_rep_plpdf.gv_widths(2) := 10;
    pkg_rep_plpdf.gv_widths(3) := 17.5;
    pkg_rep_plpdf.gv_widths(4) := 10;
    pkg_rep_plpdf.gv_widths(5) := 17.5;
    pkg_rep_plpdf.gv_widths(6) := 10;
    pkg_rep_plpdf.gv_widths(7) := 17.5;
    pkg_rep_plpdf.gv_widths(8) := 10;
    pkg_rep_plpdf.gv_widths(9) := 17.5;
    pkg_rep_plpdf.gv_widths(10) := 17.5;
    pkg_rep_plpdf.gv_widths(11) := 10;
    pkg_rep_plpdf.gv_widths(12) := 17.5;
    pkg_rep_plpdf.gv_widths(13) := 10;
    pkg_rep_plpdf.gv_widths(14) := 17.5;
    pkg_rep_plpdf.gv_widths(15) := 10;
    pkg_rep_plpdf.gv_widths(16) := 17.5;
    pkg_rep_plpdf.gv_widths(17) := 10;
    pkg_rep_plpdf.gv_widths(18) := 17.5;
    pkg_rep_plpdf.gv_widths(19) := 35;
  
    FOR i IN 1 .. 19
    LOOP
      pkg_rep_plpdf.gv_borders(i) := 1;
      pkg_rep_plpdf.gv_aligns(i) := 'J';
      pkg_rep_plpdf.gv_styles(i) := NULL;
    END LOOP;
  
    FOR cur IN (SELECT *
                  FROM (WITH src1 AS (SELECT aat.ag_contract_header_id
                                            ,aat.ag_parent_header_id
                                            ,nvl(ac_ch.description, ach_ch.description) sales_channel
                                            ,d.name agency
                                            ,decode(aca.brief, 'AG', ach.num, ac.personnel_number) num
                                            ,c.obj_name_orig agent_name
                                            ,aca.brief category_brief
                                            ,aca.category_name
                                        FROM ag_agent_tree          aat
                                            ,ven_ag_contract_header ach
                                            ,ag_contract            ac
                                            ,contact                c
                                            ,department             d
                                            ,ag_category_agent      aca
                                            ,t_sales_channel        ach_ch
                                            ,t_sales_channel        ac_ch
                                       WHERE aat.ag_contract_header_id = ach.ag_contract_header_id
                                         AND ach.ag_contract_header_id = ac.contract_id
                                         AND ach.agent_id = c.contact_id
                                         AND ac.agency_id = d.department_id(+)
                                         AND ac.category_id = aca.ag_category_agent_id
                                         AND ach_ch.id = ach.t_sales_channel_id
                                         AND ac.ag_sales_chn_id = ac_ch.id
                                         AND trunc(v_act_date) BETWEEN ach.date_begin AND ach.date_break
                                         AND trunc(v_act_date) BETWEEN ac.date_begin AND ac.date_end
                                         AND trunc(v_act_date) BETWEEN aat.date_begin AND aat.date_end
                                         AND ach.agency_id = v_agency_id
                                         AND doc.get_last_doc_status_brief(aat.ag_contract_header_id) NOT IN
                                             ('BREAK', 'CANCEL')
                                         AND ((aca.brief = 'AG' AND
                                             (EXISTS
                                              (SELECT s.ag_documents_id
                                                   FROM (SELECT ag_contract_header_id
                                                               ,ad.ag_documents_id
                                                               ,row_number() over(PARTITION BY ag_contract_header_id ORDER BY ad.ag_documents_id DESC NULLS LAST) rn
                                                           FROM ag_documents    ad
                                                               ,ag_doc_type     adt
                                                               ,ag_props_change apc
                                                               ,ag_props_type   apt
                                                          WHERE ad.ag_doc_type_id = adt.ag_doc_type_id
                                                            AND ad.ag_documents_id = apc.ag_documents_id
                                                            AND apc.ag_props_type_id = apt.ag_props_type_id
                                                            AND adt.brief = 'CAT_CHG'
                                                            AND apt.brief = 'CAT_PROP'
                                                            AND apc.new_value = '2') s
                                                  WHERE s.rn = 1
                                                    AND s.ag_contract_header_id = ach.ag_contract_header_id
                                                    AND doc.get_last_doc_status_brief(s.ag_documents_id) IN
                                                        ('CO_ACCEPTED', 'CO_ACHIVE', 'DEFICIENCY')) OR
                                              ((ach.date_begin < to_date('26.02.2015', 'dd.mm.yyyy') AND
                                              EXISTS
                                               (SELECT NULL
                                                     FROM ag_documents ad
                                                         ,ag_doc_type  adt
                                                    WHERE ad.ag_doc_type_id = adt.ag_doc_type_id
                                                      AND adt.brief = 'NEW_AD_RENLIFE'
                                                      AND ad.ag_contract_header_id =
                                                          ach.ag_contract_header_id
                                                      AND doc.get_last_doc_status_brief(ad.ag_documents_id) IN
                                                          ('CO_ACCEPTED', 'CO_ACHIVE', 'DEFICIENCY'))) OR
                                              (ach.date_begin >= to_date('26.02.2015', 'dd.mm.yyyy') AND
                                              EXISTS
                                               (SELECT NULL
                                                     FROM ag_documents ad
                                                         ,ag_doc_type  adt
                                                    WHERE ad.ag_doc_type_id = adt.ag_doc_type_id
                                                      AND adt.brief = 'NEW_AD'
                                                      AND ad.ag_contract_header_id =
                                                          ach.ag_contract_header_id
                                                      AND doc.get_last_doc_status_brief(ad.ag_documents_id) IN
                                                          ('CO_ACCEPTED', 'CO_ACHIVE', 'DEFICIENCY'))))))
                                             
                                             OR
                                             (aca.brief IN ('MN', 'DR', 'DR2') AND EXISTS
                                              (SELECT NULL
                                                  FROM ag_documents ad
                                                      ,ag_doc_type  adt
                                                 WHERE ad.ag_doc_type_id = adt.ag_doc_type_id
                                                   AND adt.brief = 'BONUSES_PROVISION'
                                                   AND ad.ag_contract_header_id = ach.ag_contract_header_id
                                                   AND doc.get_doc_status_brief(ad.ag_documents_id, SYSDATE) IN
                                                       ('CO_ACCEPTED', 'CO_ACHIVE'))) OR
                                             aca.brief IN ('TD'))),
                       
                       src2 AS (SELECT *
                                  FROM src1
                                UNION
                                SELECT ach.ag_contract_header_id
                                      ,aat.ag_parent_header_id
                                      ,nvl(ac_ch.description, ach_ch.description) sales_channel
                                      ,d.name agency
                                      ,decode(aca.brief, 'AG', ach.num, ac.personnel_number) num
                                      ,c.obj_name_orig agent_name
                                      ,aca.brief category_brief
                                      ,aca.category_name
                                  FROM ag_agent_tree          aat
                                      ,ven_ag_contract_header ach
                                      ,ag_contract            ac
                                      ,contact                c
                                      ,department             d
                                      ,ag_category_agent      aca
                                      ,t_sales_channel        ach_ch
                                      ,t_sales_channel        ac_ch
                                 WHERE aat.ag_contract_header_id = ach.ag_contract_header_id
                                   AND ach.ag_contract_header_id = ac.contract_id
                                   AND ach.agent_id = c.contact_id
                                   AND ac.agency_id = d.department_id(+)
                                   AND ac.category_id = aca.ag_category_agent_id
                                   AND ach_ch.id = ach.t_sales_channel_id
                                   AND ac.ag_sales_chn_id = ac_ch.id
                                   AND trunc(v_act_date) BETWEEN ach.date_begin AND ach.date_break
                                   AND trunc(v_act_date) BETWEEN ac.date_begin AND ac.date_end
                                   AND trunc(v_act_date) BETWEEN aat.date_begin AND aat.date_end
                                   AND aca.brief IN ('AG', 'MN', 'DR', 'DR2', 'TD')
                                   AND doc.get_last_doc_status_brief(ach.ag_contract_header_id) NOT IN
                                       ('BREAK', 'CANCEL')
                                   AND ach.ag_contract_header_id IN
                                       (SELECT ag_parent_header_id FROM src1))
                       
                         SELECT decode(ag_mn_dr.dr_ag_parent_header_id
                                      ,NULL
                                      ,decode(ag_mn_dr.mn_ag_parent_header_id
                                             ,NULL
                                             ,td_ag.sales_channel
                                             ,td_mn.sales_channel)
                                      ,td_dr.sales_channel) td_sales_channel
                               ,decode(ag_mn_dr.dr_ag_parent_header_id
                                      ,NULL
                                      ,decode(ag_mn_dr.mn_ag_parent_header_id
                                             ,NULL
                                             ,td_ag.agency
                                             ,td_mn.agency)
                                      ,td_dr.agency) td_agency
                               ,decode(ag_mn_dr.dr_ag_parent_header_id
                                      ,NULL
                                      ,decode(ag_mn_dr.mn_ag_parent_header_id
                                             ,NULL
                                             ,td_ag.num
                                             ,td_mn.num)
                                      ,td_dr.num) td_num
                               ,decode(ag_mn_dr.dr_ag_parent_header_id
                                      ,NULL
                                      ,decode(ag_mn_dr.mn_ag_parent_header_id
                                             ,NULL
                                             ,td_ag.agent_name
                                             ,td_mn.agent_name)
                                      ,td_dr.agent_name) td_agent_name
                               ,ag_mn_dr.dr_sales_channel
                               ,ag_mn_dr.dr_agency
                               ,ag_mn_dr.dr_num
                               ,ag_mn_dr.dr_agent_name
                               ,ag_mn_dr.dr_category_name
                               ,ag_mn_dr.mn_sales_channel
                               ,ag_mn_dr.mn_agency
                               ,ag_mn_dr.mn_num
                               ,ag_mn_dr.mn_agent_name
                               ,ag_mn_dr.ag_sales_channel
                               ,ag_mn_dr.ag_agency
                               ,ag_mn_dr.ag_num
                               ,ag_mn_dr.ag_agent_name
                               ,COUNT(DISTINCT decode(ag_mn_dr.dr_ag_parent_header_id
                                            ,NULL
                                            ,decode(ag_mn_dr.mn_ag_parent_header_id
                                                   ,NULL
                                                   ,td_ag.num
                                                   ,td_mn.num)
                                            ,td_dr.num)) over() td_ind
                               ,COUNT(DISTINCT ag_mn_dr.dr_num) over() dr_ind
                               ,COUNT(DISTINCT ag_mn_dr.mn_num) over() mn_ind
                           FROM (SELECT ag_mn.ag_ag_parent_header_id
                                       ,ag_mn.mn_ag_parent_header_id
                                       ,decode(ag_mn.mn_ag_parent_header_id
                                              ,NULL
                                              ,dr_ag.ag_parent_header_id
                                              ,dr_mn.ag_parent_header_id) dr_ag_parent_header_id
                                       ,ag_mn.ag_sales_channel
                                       ,ag_mn.ag_agency
                                       ,ag_mn.ag_num
                                       ,ag_mn.ag_agent_name
                                       ,ag_mn.mn_sales_channel
                                       ,ag_mn.mn_agency
                                       ,ag_mn.mn_num
                                       ,ag_mn.mn_agent_name
                                       ,decode(ag_mn.mn_ag_parent_header_id
                                              ,NULL
                                              ,dr_ag.sales_channel
                                              ,dr_mn.sales_channel) dr_sales_channel
                                       ,decode(ag_mn.mn_ag_parent_header_id
                                              ,NULL
                                              ,dr_ag.agency
                                              ,dr_mn.agency) dr_agency
                                       ,dr_mn.num dr_mn_num
                                       ,dr_ag.num dr_ag_num
                                       ,decode(ag_mn.mn_ag_parent_header_id, NULL, dr_ag.num, dr_mn.num) dr_num
                                       ,decode(ag_mn.mn_ag_parent_header_id
                                              ,NULL
                                              ,dr_ag.agent_name
                                              ,dr_mn.agent_name) dr_agent_name
                                       ,decode(ag_mn.mn_ag_parent_header_id
                                              ,NULL
                                              ,dr_ag.category_name
                                              ,dr_mn.category_name) dr_category_name
                                   FROM (SELECT ag.ag_parent_header_id ag_ag_parent_header_id
                                               ,mn.ag_parent_header_id mn_ag_parent_header_id
                                               ,ag.sales_channel       ag_sales_channel
                                               ,ag.agency              ag_agency
                                               ,ag.num                 ag_num
                                               ,ag.agent_name          ag_agent_name
                                               ,mn.sales_channel       mn_sales_channel
                                               ,mn.agency              mn_agency
                                               ,mn.num                 mn_num
                                               ,mn.agent_name          mn_agent_name
                                           FROM (SELECT * FROM src2 WHERE category_brief = 'AG') ag
                                           FULL JOIN (SELECT * FROM src2 WHERE category_brief = 'MN') mn
                                             ON ag.ag_parent_header_id = mn.ag_contract_header_id) ag_mn
                                       ,(SELECT * FROM src2 WHERE category_brief IN ('DR', 'DR2')) dr_ag
                                       ,(SELECT * FROM src2 WHERE category_brief IN ('DR', 'DR2')) dr_mn
                                  WHERE ag_mn.ag_ag_parent_header_id = dr_ag.ag_contract_header_id(+)
                                    AND ag_mn.mn_ag_parent_header_id = dr_mn.ag_contract_header_id(+)) ag_mn_dr
                               ,(SELECT * FROM src2 WHERE category_brief IN ('TD')) td_ag
                               ,(SELECT * FROM src2 WHERE category_brief IN ('TD')) td_mn
                               ,(SELECT * FROM src2 WHERE category_brief IN ('TD')) td_dr
                          WHERE ag_mn_dr.ag_ag_parent_header_id = td_ag.ag_contract_header_id(+)
                            AND ag_mn_dr.mn_ag_parent_header_id = td_mn.ag_contract_header_id(+)
                            AND ag_mn_dr.dr_ag_parent_header_id = td_dr.ag_contract_header_id(+)
                          ORDER BY td_dr.num
                                  ,td_mn.num
                                  ,td_ag.num
                                  ,ag_mn_dr.dr_mn_num
                                  ,ag_mn_dr.dr_ag_num
                                  ,ag_mn_dr.mn_num
                                  ,ag_mn_dr.ag_num)
                )
    LOOP
      j := j + 1;
      pkg_rep_plpdf.gv_datas(1) := j;
      v_td_ind := cur.td_ind;
      v_dr_ind := cur.dr_ind;
      v_mn_ind := cur.mn_ind;
      pkg_rep_plpdf.gv_datas(2) := cur.td_sales_channel;
      pkg_rep_plpdf.gv_datas(3) := cur.td_agency;
      pkg_rep_plpdf.gv_datas(4) := cur.td_num;
      pkg_rep_plpdf.gv_datas(5) := cur.td_agent_name;
      pkg_rep_plpdf.gv_datas(6) := cur.dr_sales_channel;
      pkg_rep_plpdf.gv_datas(7) := cur.dr_agency;
      pkg_rep_plpdf.gv_datas(8) := cur.dr_num;
      pkg_rep_plpdf.gv_datas(9) := cur.dr_agent_name;
      pkg_rep_plpdf.gv_datas(10) := cur.dr_category_name;
      pkg_rep_plpdf.gv_datas(11) := cur.mn_sales_channel;
      pkg_rep_plpdf.gv_datas(12) := cur.mn_agency;
      pkg_rep_plpdf.gv_datas(13) := cur.mn_num;
      pkg_rep_plpdf.gv_datas(14) := cur.mn_agent_name;
      pkg_rep_plpdf.gv_datas(15) := cur.ag_sales_channel;
      pkg_rep_plpdf.gv_datas(16) := cur.ag_agency;
      pkg_rep_plpdf.gv_datas(17) := cur.ag_num;
      pkg_rep_plpdf.gv_datas(18) := cur.ag_agent_name;
      pkg_rep_plpdf.gv_datas(19) := '';
      plpdf.row_print2(p_data     => pkg_rep_plpdf.gv_datas
                      ,p_border   => pkg_rep_plpdf.gv_borders
                      ,p_width    => pkg_rep_plpdf.gv_widths
                      ,p_align    => pkg_rep_plpdf.gv_aligns
                      ,p_style    => pkg_rep_plpdf.gv_styles
                      ,p_clipping => 0
                      ,p_h        => 4
                      ,p_maxline  => pkg_rep_plpdf.gv_maxlines);
    END LOOP;
  
    -- ������ �����������
    CASE
      WHEN v_dr_ind > 0 THEN
        plpdf.linebreak(p_h => 10);
        plpdf.setprintfont(p_size => 8);
        plpdf.printmultilinecell(p_txt    => '��������' ||
                                             ' _________________      /____________________________________/'
                                ,p_w      => plpdf.getpagespace
                                ,p_h      => -1
                                ,p_align  => 'L'
                                ,p_ln     => 1
                                ,p_border => 0);
        plpdf.setprintfont(p_size => 6);
        plpdf.printmultilinecell(p_txt    => CASE
                                               WHEN v_dr_ind > 0 THEN
                                                ''
                                               ELSE
                                                '                                                        '
                                             END ||
                                             '                                       (�������)                                                                   (���)'
                                ,p_w      => plpdf.getpagespace
                                ,p_h      => -1
                                ,p_align  => 'L'
                                ,p_ln     => 0
                                ,p_border => 0);
      WHEN v_td_ind > 0
           AND v_dr_ind = 0 THEN
        plpdf.linebreak(p_h => 10);
        plpdf.setprintfont(p_size => 8);
        plpdf.printmultilinecell(p_txt    => '��������������� ��������' ||
                                             ' _________________      /____________________________________/'
                                ,p_w      => plpdf.getpagespace
                                ,p_h      => -1
                                ,p_align  => 'L'
                                ,p_ln     => 1
                                ,p_border => 0);
        plpdf.setprintfont(p_size => 6);
        plpdf.printmultilinecell(p_txt    => CASE
                                               WHEN v_dr_ind > 0 THEN
                                                ''
                                               ELSE
                                                '                                           '
                                             END ||
                                             '                                       (�������)                                                                   (���)'
                                ,p_w      => plpdf.getpagespace
                                ,p_h      => -1
                                ,p_align  => 'L'
                                ,p_ln     => 0
                                ,p_border => 0);
      ELSE
        NULL;
    END CASE;
    FOR i IN 1 .. v_mn_ind
    LOOP
      plpdf.setprintfont(p_size => 8);
      plpdf.linebreak(p_h => 10);
      plpdf.printmultilinecell(p_txt    => '�������� _________________      /____________________________________/'
                              ,p_w      => plpdf.getpagespace
                              ,p_h      => -1
                              ,p_align  => 'L'
                              ,p_ln     => 1
                              ,p_border => 0);
      plpdf.setprintfont(p_size => 6);
      plpdf.printmultilinecell(p_txt    => '                                       (�������)                                                                   (���)'
                              ,p_w      => plpdf.getpagespace
                              ,p_h      => -1
                              ,p_align  => 'L'
                              ,p_ln     => 0
                              ,p_border => 0);
    END LOOP;
  
    plpdf.setprintfont(p_size => 8);
    plpdf.linebreak(p_h => 10);
    plpdf.printmultilinecell(p_txt    => '�____� _______________________ 201_ �.'
                            ,p_w      => plpdf.getpagespace
                            ,p_h      => -1
                            ,p_align  => 'L'
                            ,p_ln     => 1
                            ,p_border => 0);
  
    plpdf.newpage;
    plpdf.printcell(p_txt   => '��� ������ ��������� ��������� � ������������ �����'
                   ,p_h     => -1
                   ,p_align => 'C'
                   ,p_ln    => 1);
  
    plpdf.printcell(p_txt => '���������: ' || v_agency, p_h => -1, p_align => 'L', p_ln => 1);
  
    plpdf.printcell(p_txt   => '�������� ������: ' || v_reporting_period
                   ,p_h     => -1
                   ,p_align => 'L'
                   ,p_ln    => 1);
  
    plpdf.printcell(p_txt   => '���� �����������: ' || to_char(v_act_date, 'dd.mm.yyyy')
                   ,p_h     => -1
                   ,p_align => 'L'
                   ,p_ln    => 1);
  
    -- ������� 2 - �������� ������� �������
    plpdf.linebreak(p_h => 3);
    plpdf.setprintfont(p_size => 6);
    plpdf.printcell(p_txt    => '� �/�'
                   ,p_w      => 10
                   ,p_h      => 25
                   ,p_align  => 'C'
                   ,p_ln     => 0
                   ,p_border => 1);
    plpdf.printcell(p_txt    => '��������'
                   ,p_w      => 132.5
                   ,p_h      => 5
                   ,p_align  => 'C'
                   ,p_ln     => 0
                   ,p_border => 1);
    v_x := plpdf.getcurrentx;
    v_y := plpdf.getcurrenty;
    plpdf.printcell(p_txt    => '��������'
                   ,p_w      => 97.5
                   ,p_h      => 5
                   ,p_align  => 'C'
                   ,p_ln     => 1
                   ,p_border => 1);
    plpdf.printmultilinecell(p_txt => '', p_align => 'J', p_w => 10, p_h => 10, p_ln => 0);
  
    pkg_rep_plpdf.delete_row_print_cache;
  
    pkg_rep_plpdf.gv_widths(1) := 15;
    pkg_rep_plpdf.gv_widths(2) := 17.5;
    pkg_rep_plpdf.gv_widths(3) := 15;
    pkg_rep_plpdf.gv_widths(4) := 17.5;
    pkg_rep_plpdf.gv_widths(5) := 17.5;
    pkg_rep_plpdf.gv_widths(6) := 15;
    pkg_rep_plpdf.gv_widths(7) := 17.5;
    pkg_rep_plpdf.gv_widths(8) := 17.5;
    pkg_rep_plpdf.gv_widths(9) := 15;
    pkg_rep_plpdf.gv_widths(10) := 17.5;
    pkg_rep_plpdf.gv_widths(11) := 15;
    pkg_rep_plpdf.gv_widths(12) := 17.5;
    pkg_rep_plpdf.gv_widths(13) := 15;
    pkg_rep_plpdf.gv_widths(14) := 17.5;
  
    FOR i IN 1 .. 15
    LOOP
      pkg_rep_plpdf.gv_borders(i) := 1;
      pkg_rep_plpdf.gv_aligns(i) := 'C';
      pkg_rep_plpdf.gv_styles(i) := NULL;
    END LOOP;
  
    pkg_rep_plpdf.gv_datas(1) := '��� ��������� ����';
    pkg_rep_plpdf.gv_datas(2) := '���������';
    pkg_rep_plpdf.gv_datas(3) := '��������� �����';
    pkg_rep_plpdf.gv_datas(4) := '���';
    pkg_rep_plpdf.gv_datas(5) := '��������� ���������';
    pkg_rep_plpdf.gv_datas(6) := '��������� ����� ���������������� ���������';
    pkg_rep_plpdf.gv_datas(7) := '��� ���������������� ���������';
    pkg_rep_plpdf.gv_datas(8) := '��������� ���������������� ���������';
    pkg_rep_plpdf.gv_datas(9) := '��� ��������� ����';
    pkg_rep_plpdf.gv_datas(10) := '���������';
    pkg_rep_plpdf.gv_datas(11) := '��������� �����';
    pkg_rep_plpdf.gv_datas(12) := '���';
    pkg_rep_plpdf.gv_datas(13) := '��������� ����� ���������������� ���������';
    pkg_rep_plpdf.gv_datas(14) := '��� ���������������� ���������';
    plpdf.row_print2(p_data     => pkg_rep_plpdf.gv_datas
                    ,p_border   => pkg_rep_plpdf.gv_borders
                    ,p_width    => pkg_rep_plpdf.gv_widths
                    ,p_align    => pkg_rep_plpdf.gv_aligns
                    ,p_style    => pkg_rep_plpdf.gv_styles
                    ,p_clipping => 0
                    ,p_h        => 4
                    ,p_maxline  => pkg_rep_plpdf.gv_maxlines);
  
    plpdf.setcurrentxy(v_x + 97.5, v_y);
    pkg_rep_plpdf.delete_row_print_cache;
    pkg_rep_plpdf.gv_widths(1) := 40;
    pkg_rep_plpdf.gv_borders(1) := 1;
    pkg_rep_plpdf.gv_aligns(1) := 'C';
    pkg_rep_plpdf.gv_styles(1) := NULL;
    pkg_rep_plpdf.gv_datas(1) := '����������:';
    plpdf.row_print2(p_data     => pkg_rep_plpdf.gv_datas
                    ,p_border   => pkg_rep_plpdf.gv_borders
                    ,p_width    => pkg_rep_plpdf.gv_widths
                    ,p_align    => pkg_rep_plpdf.gv_aligns
                    ,p_style    => pkg_rep_plpdf.gv_styles
                    ,p_clipping => 0
                    ,p_h        => 25
                    ,p_maxline  => pkg_rep_plpdf.gv_maxlines);
  
    -- ������� 2 - ������
    pkg_rep_plpdf.delete_row_print_cache;
  
    pkg_rep_plpdf.gv_widths(1) := 10;
    pkg_rep_plpdf.gv_widths(2) := 15;
    pkg_rep_plpdf.gv_widths(3) := 17.5;
    pkg_rep_plpdf.gv_widths(4) := 15;
    pkg_rep_plpdf.gv_widths(5) := 17.5;
    pkg_rep_plpdf.gv_widths(6) := 17.5;
    pkg_rep_plpdf.gv_widths(7) := 15;
    pkg_rep_plpdf.gv_widths(8) := 17.5;
    pkg_rep_plpdf.gv_widths(9) := 17.5;
    pkg_rep_plpdf.gv_widths(10) := 15;
    pkg_rep_plpdf.gv_widths(11) := 17.5;
    pkg_rep_plpdf.gv_widths(12) := 15;
    pkg_rep_plpdf.gv_widths(13) := 17.5;
    pkg_rep_plpdf.gv_widths(14) := 15;
    pkg_rep_plpdf.gv_widths(15) := 17.5;
    pkg_rep_plpdf.gv_widths(16) := 40;
  
    FOR i IN 1 .. 16
    LOOP
      pkg_rep_plpdf.gv_borders(i) := 1;
      pkg_rep_plpdf.gv_aligns(i) := 'J';
      pkg_rep_plpdf.gv_styles(i) := NULL;
    END LOOP;
  
    j        := 0;
    v_mn_ind := 0;
    FOR cur IN (SELECT *
                  FROM (WITH src AS (SELECT nvl(ac_ch.description, ach_ch.description) sales_channel
                                           ,d.name agency
                                           ,ac.personnel_number num
                                           ,c.obj_name_orig agent_name
                                           ,aca.brief category_brief
                                           ,aca.category_name
                                           ,aca_f_lead.brief lead_category_brief
                                           ,aca_f_lead.category_name lead_category_name
                                           ,nvl(ac_ch_f_lead.description, ach_ch_f_lead.description) lead_sales_channel
                                           ,d_f_lead.name lead_agency
                                           ,ac_f_lead_last.personnel_number lead_num
                                           ,c_f_lead.obj_name_orig lead_agent_name
                                       FROM ven_ag_contract_header ach
                                           ,ag_contract            ac
                                           ,contact                c
                                           ,department             d
                                           ,ag_category_agent      aca
                                           ,t_sales_channel        ach_ch
                                           ,t_sales_channel        ac_ch
                                           ,ven_ag_contract_header ach_f_lead
                                           ,ag_contract            ac_f_lead
                                           ,ag_contract            ac_f_lead_last
                                           ,contact                c_f_lead
                                           ,department             d_f_lead
                                           ,ag_category_agent      aca_f_lead
                                           ,t_sales_channel        ach_ch_f_lead
                                           ,t_sales_channel        ac_ch_f_lead
                                      WHERE ach.ag_contract_header_id = ac.contract_id
                                        AND ach.agent_id = c.contact_id
                                        AND ac.agency_id = d.department_id(+)
                                        AND ac.category_id = aca.ag_category_agent_id
                                        AND ach_ch.id = ach.t_sales_channel_id
                                        AND ac.ag_sales_chn_id = ac_ch.id
                                        AND ac.contract_f_lead_id = ac_f_lead.ag_contract_id
                                        AND ac_f_lead.contract_id = ach_f_lead.ag_contract_header_id
                                        AND ach_f_lead.ag_contract_header_id = ac_f_lead_last.contract_id
                                        AND ach_f_lead.agent_id = c_f_lead.contact_id
                                        AND ac_f_lead_last.category_id = aca_f_lead.ag_category_agent_id
                                        AND ac_f_lead_last.agency_id = d_f_lead.department_id(+)
                                        AND ach_ch_f_lead.id = ach_f_lead.t_sales_channel_id
                                        AND ac_f_lead_last.ag_sales_chn_id = ac_ch_f_lead.id
                                        AND trunc(v_act_date) BETWEEN ach.date_begin AND ach.date_break
                                        AND trunc(v_act_date) BETWEEN ac.date_begin AND ac.date_end
                                        AND trunc(v_act_date) BETWEEN ach_f_lead.date_begin AND
                                            ach_f_lead.date_break
                                        AND trunc(v_act_date) BETWEEN ac_f_lead_last.date_begin AND
                                            ac_f_lead_last.date_end
                                        AND ach_f_lead.agency_id = v_agency_id
                                        AND doc.get_last_doc_status_brief(ach.ag_contract_header_id) NOT IN
                                            ('BREAK', 'CANCEL')
                                        AND doc.get_last_doc_status_brief(ach_f_lead.ag_contract_header_id) NOT IN
                                            ('BREAK', 'CANCEL')
                                        AND aca.brief IN ('MN', 'DR', 'DR2'))
                       
                         SELECT dr.lead_sales_channel dr_lead_sales_channel
                               ,dr.lead_agency dr_lead_agency
                               ,dr.lead_num dr_lead_num
                               ,dr.lead_agent_name dr_lead_agent_name
                               ,dr.lead_category_name dr_lead_category_name
                               ,dr.num dr_num
                               ,dr.agent_name dr_agent_name
                               ,dr.category_name dr_category_name
                               ,mn.lead_sales_channel mn_lead_sales_channel
                               ,mn.lead_agency mn_lead_agency
                               ,mn.lead_num mn_lead_num
                               ,mn.lead_agent_name mn_lead_agent_name
                               ,mn.num mn_num
                               ,mn.agent_name mn_agent_name
                               ,COUNT(DISTINCT mn.lead_num) over() mn_ind
                           FROM (SELECT *
                                   FROM src
                                  WHERE category_brief IN ('DR', 'DR2')
                                    AND lead_category_brief IN ('DR', 'DR2')) dr
                           FULL JOIN (SELECT *
                                        FROM src
                                       WHERE category_brief IN ('MN')
                                         AND lead_category_brief IN ('MN')) mn
                             ON dr.num = mn.num
                          ORDER BY dr.num
                                  ,mn.num)
                )
    LOOP
      j := j + 1;
      v_mn_ind := cur.mn_ind;
      pkg_rep_plpdf.gv_datas(1) := j;
      pkg_rep_plpdf.gv_datas(2) := cur.dr_lead_sales_channel;
      pkg_rep_plpdf.gv_datas(3) := cur.dr_lead_agency;
      pkg_rep_plpdf.gv_datas(4) := cur.dr_lead_num;
      pkg_rep_plpdf.gv_datas(5) := cur.dr_lead_agent_name;
      pkg_rep_plpdf.gv_datas(6) := cur.dr_lead_category_name;
      pkg_rep_plpdf.gv_datas(7) := cur.dr_num;
      pkg_rep_plpdf.gv_datas(8) := cur.dr_agent_name;
      pkg_rep_plpdf.gv_datas(9) := cur.dr_category_name;
      pkg_rep_plpdf.gv_datas(10) := cur.mn_lead_sales_channel;
      pkg_rep_plpdf.gv_datas(11) := cur.mn_lead_agency;
      pkg_rep_plpdf.gv_datas(12) := cur.mn_lead_num;
      pkg_rep_plpdf.gv_datas(13) := cur.mn_lead_agent_name;
      pkg_rep_plpdf.gv_datas(14) := cur.mn_num;
      pkg_rep_plpdf.gv_datas(15) := cur.mn_agent_name;
      pkg_rep_plpdf.gv_datas(16) := '';
      plpdf.row_print2(p_data     => pkg_rep_plpdf.gv_datas
                      ,p_border   => pkg_rep_plpdf.gv_borders
                      ,p_width    => pkg_rep_plpdf.gv_widths
                      ,p_align    => pkg_rep_plpdf.gv_aligns
                      ,p_style    => pkg_rep_plpdf.gv_styles
                      ,p_clipping => 0
                      ,p_h        => 4
                      ,p_maxline  => pkg_rep_plpdf.gv_maxlines);
    END LOOP;
  
    -- ������ �����������
    plpdf.linebreak(p_h => 10);
    plpdf.setprintfont(p_size => 8);
    plpdf.printmultilinecell(p_txt    => '��������������� ��������' ||
                                         ' _________________      /____________________________________/'
                            ,p_w      => plpdf.getpagespace
                            ,p_h      => -1
                            ,p_align  => 'L'
                            ,p_ln     => 1
                            ,p_border => 0);
    plpdf.setprintfont(p_size => 6);
    plpdf.printmultilinecell(p_txt    => '                                           ' ||
                                         '                                       (�������)                                                                   (���)'
                            ,p_w      => plpdf.getpagespace
                            ,p_h      => -1
                            ,p_align  => 'L'
                            ,p_ln     => 0
                            ,p_border => 0);
    plpdf.linebreak(p_h => 10);
    plpdf.setprintfont(p_size => 8);
    plpdf.printmultilinecell(p_txt    => '��������' ||
                                         ' _________________      /____________________________________/'
                            ,p_w      => plpdf.getpagespace
                            ,p_h      => -1
                            ,p_align  => 'L'
                            ,p_ln     => 1
                            ,p_border => 0);
    plpdf.setprintfont(p_size => 6);
    plpdf.printmultilinecell(p_txt    => '                                       (�������)                                                                   (���)'
                            ,p_w      => plpdf.getpagespace
                            ,p_h      => -1
                            ,p_align  => 'L'
                            ,p_ln     => 0
                            ,p_border => 0);
  
    FOR i IN 1 .. v_mn_ind
    LOOP
      plpdf.setprintfont(p_size => 8);
      plpdf.linebreak(p_h => 10);
      plpdf.printmultilinecell(p_txt    => '�������� _________________      /____________________________________/'
                              ,p_w      => plpdf.getpagespace
                              ,p_h      => -1
                              ,p_align  => 'L'
                              ,p_ln     => 1
                              ,p_border => 0);
      plpdf.setprintfont(p_size => 6);
      plpdf.printmultilinecell(p_txt    => '                                       (�������)                                                                   (���)'
                              ,p_w      => plpdf.getpagespace
                              ,p_h      => -1
                              ,p_align  => 'L'
                              ,p_ln     => 0
                              ,p_border => 0);
    END LOOP;
  
    plpdf.setprintfont(p_size => 8);
    plpdf.linebreak(p_h => 10);
    plpdf.printmultilinecell(p_txt    => '�____� _______________________ 201_ �.'
                            ,p_w      => plpdf.getpagespace
                            ,p_h      => -1
                            ,p_align  => 'L'
                            ,p_ln     => 1
                            ,p_border => 0);
  
    plpdf.senddoc(p_blob => par_data);
    par_file_name    := '��� ������ ��������� ��������� ����: ' || v_agency || '.pdf';
    par_content_type := pkg_rep_plpdf.gc_pdf_content_type;
  END rep_agent_structure_verify_act;
END pkg_rep_ag_cntr;
/

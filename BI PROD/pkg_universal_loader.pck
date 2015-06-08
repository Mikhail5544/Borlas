CREATE OR REPLACE PACKAGE pkg_universal_loader IS

  /**
  * ������ � ����������� �������������� ����������
  * ������ ��������� 05.04.2013
  * ����� ���� ����� =)
  */

  --������ �������� "�������� ��������� ���������� ��� ���"
  --���������       "������ ��������� ���������� ��� ���"
  --��������� ��������
  PROCEDURE import_hkf_check
  (
    par_load_file_rows_id NUMBER
   ,par_status            OUT VARCHAR2
   ,par_comment           OUT VARCHAR2
  );

  --������ �������� "�������� ��������� ���������� ��� ���"
  --���������       "������ ��������� ���������� ��� ���"
  --��������� ��������                            
  PROCEDURE import_hkf_load(par_load_file_rows_id NUMBER);

  /*
    ������ �.
    �������� ��� �������� �������������
    ���� ������ ������������� ��������� �������� ��� ������� �����������
  */
  PROCEDURE check_annulation_row
  (
    par_load_file_rows_id NUMBER
   ,par_status            OUT VARCHAR2
   ,par_comment           OUT VARCHAR2
  );

  /*
    ������ �.
    ��������� ������������� ���������, ��������� ��������
  */
  PROCEDURE annulate_list(par_load_file_rows_id NUMBER);

  /*
  ������ �������� �������� ��������� �� ����������� �� ���� (� 6.11.2014 ��������� ��-������)
   ������ �.
  */
  PROCEDURE group_decline_hkb_old(par_load_file_id load_file.load_file_id%TYPE);

  /*
  ����� �������� �������� ��������� �� ����������� �� ����
  ������ �.
  30.10.2014
  */
  PROCEDURE group_decline_hkb(par_load_file_id load_file.load_file_id%TYPE);

  /*
  ��������� ����������� ��������� ���. �������� ���� �������
  25.06.2014 ������ �.
  */
  PROCEDURE decline_hkb_payoff_date(par_load_file_id load_file.load_file_id%TYPE);

  /*
    ������ �., 24.10.2013, 217702 �������������� ����������� ��������� 0 ��� ������� �������� � ��������
    ������ �������� "��������� ����������� ���������"
    ��������� "�������� ������ ��������� �� ����������� �� � �������� ������"
    ��������� ��������
  */
  PROCEDURE check_termination_zero_akt_row
  (
    par_load_file_rows_id NUMBER
   ,par_status            OUT NUMBER
   ,par_comment           OUT VARCHAR2
  );

  /*
    ������ �., 24.10.2013, 217702 �������������� ����������� ��������� 0 ��� ������� �������� � ��������
    ������ �������� "��������� ����������� ���������"
    ��������� "�������� ������ ��������� �� ����������� �� � �������� ������"
    ��������� ��������
  */
  PROCEDURE terminate_zero_akt_list(par_load_file_rows_id NUMBER);

  /*  
    ������ �., 28.10.2013, 217272 ��������� �������� �������� Contact
    ������ �������� "�������� ����������� Contact"
    ��������� "�������� ������ ������� ����� �������� ������� Contact"
    ��������� ��������
  */
  PROCEDURE check_load_contact_pp(par_load_file_id NUMBER);

  /*  
    ������ �., 28.10.2013, 217272 ��������� �������� �������� Contact
    ������ �������� "�������� ����������� Contact"
    ��������� "�������� ������ ������� ����� �������� ������� Contact"
    ��������� ��������
  */
  PROCEDURE load_contact_pp(par_load_file_id NUMBER);

  /* ����������� �., ���� 2014, 328575: ������� ����������� ���� ��� ������� � BI ���.
     ������ �������� "�������� ��������� ������" (ACTUARIAL_DATA)
     ��������� "�������� ���" (ADD_INVEST_INCOME)
     ��������� ��������      
  */

  PROCEDURE check_aii_data
  (
    par_load_file_rows_id NUMBER
   ,par_status            OUT VARCHAR2
   ,par_comment           OUT VARCHAR2
  );

  /* ����������� �., ���� 2014, 328575: ������� ����������� ���� ��� ������� � BI ���.
     ������ �������� "�������� ��������� ������" (ACTUARIAL_DATA)
     ��������� "�������� ���" (ADD_INVEST_INCOME)
     ��������� ��������      
  */
  PROCEDURE load_aii_data(par_load_file_rows_id NUMBER);

  /*
  �������� ��� �������� �������� mPos
  ������ �. 24.09.2014
  */
  PROCEDURE check_mpos_payment
  (
    par_load_file_rows_id NUMBER
   ,par_status            OUT VARCHAR2
   ,par_comment           OUT VARCHAR2
  );
  /*
  �������� �������� mPos
  ������ �. 18.09.2014
  */
  PROCEDURE load_mpos_payment(par_load_file_rows_id load_file_rows.load_file_rows_id%TYPE);

  PROCEDURE check_prod_coef
  (
    par_load_file_rows_id NUMBER
   ,par_status            OUT VARCHAR2
   ,par_comment           OUT VARCHAR2
  );
  PROCEDURE load_prod_coef(par_load_file_rows_id NUMBER);

END pkg_universal_loader;
/
CREATE OR REPLACE PACKAGE BODY pkg_universal_loader IS

  --������ �������� "�������� ��������� ���������� ��� ���"
  --���������       "������ ��������� ���������� ��� ���"
  --��������� �������� ������� ��������� ���������� ��� ��� ��� ����� ������������� ���������
  PROCEDURE import_hkf_check
  (
    par_load_file_rows_id NUMBER
   ,par_status            OUT VARCHAR2
   ,par_comment           OUT VARCHAR2
  ) IS
    v_is_check   NUMBER(10);
    v_contact_id ins.contact.contact_id%TYPE;
    v_ach_agent  ins.ag_contract_header.ag_contract_header_id%TYPE;
    v_agnum      ins.document.num%TYPE;
    v_fio_agent  ins.contact.obj_name_orig%TYPE;
    -- v_place_issue           ins.cn_contact_bank_acc.place_of_issue%TYPE;
    v_used_flag   ins.cn_contact_bank_acc.used_flag%TYPE;
    v_acc_bank_id ins.cn_contact_bank_acc.id%TYPE;
    --  v_sdt             date;
    -- v_lic_code              ins.cn_contact_bank_acc.lic_code%TYPE;
  BEGIN
    --��������� ��� �� �����
    SELECT initcap(lf.val_2)
      INTO v_fio_agent
      FROM load_file_rows lf
     WHERE lf.load_file_rows_id = par_load_file_rows_id;
  
    UPDATE load_file_rows lf
       SET lf.val_4 = to_char(SYSDATE, 'dd.mm.yyyy')
     WHERE lf.load_file_rows_id = par_load_file_rows_id;
  
    -- ����� ��� � ����� ������
    BEGIN
      SELECT co.contact_id
            ,
             --  co.obj_name_orig,-- cr.card_num
             ch.ag_contract_header_id
            ,ch.num
        INTO v_contact_id
            ,
             --v_agent_fio,
             v_ach_agent
            ,v_agnum
        FROM ins.contact co
             --   ,cards              cr
            ,ins.ven_ag_contract_header ch
            ,ins.document               dc
            ,ins.doc_status_ref         dsr
       WHERE co.obj_name_orig LIKE v_fio_agent || '%'
         AND ch.agent_id = co.contact_id
         AND dc.document_id = ch.ag_contract_header_id
         AND dsr.doc_status_ref_id = dc.doc_status_ref_id
         AND dsr.brief IN ('CURRENT') --������ ��� - �����������
         AND ch.is_new = 1; -- ����� ��������� ������
    EXCEPTION
      WHEN too_many_rows THEN
        par_status  := pkg_load_file_to_table.get_error;
        par_comment := '������� ����� ������ ������������ ���';
        UPDATE load_file_rows lf
           SET lf.val_3 = par_comment
              ,lf.val_2 = initcap(v_fio_agent)
         WHERE lf.load_file_rows_id = par_load_file_rows_id;
        RETURN;
      WHEN no_data_found THEN
        par_status  := pkg_load_file_to_table.get_error;
        par_comment := '�� ������ ����������� ��';
        UPDATE load_file_rows lf
           SET lf.val_3 = par_comment
              ,lf.val_2 = initcap(v_fio_agent)
         WHERE lf.load_file_rows_id = par_load_file_rows_id;
        RETURN;
    END;
    --�������� ������������� ����� ���.
    --�������� ������� ����� ���
    SELECT COUNT(*)
      INTO v_is_check
      FROM cn_contact_bank_acc      cb
          ,ins.cn_document_bank_acc cdba
     WHERE cb.bank_name = '��� "��� ����"'
       AND cb.contact_id = v_contact_id
       AND cdba.cn_contact_bank_acc_id(+) = cb.id
       AND doc.get_doc_status_brief(cdba.cn_document_bank_acc_id) != 'CANCEL'
       AND rownum = 1; --�� ����� �������, ����� - ���� ��� ���
    --���� ������ ��
    IF v_is_check > 0
    THEN
      --�������� ��������� ���������� �����
      BEGIN
        SELECT cb.used_flag
          INTO v_used_flag
          FROM cn_contact_bank_acc      cb
              ,ins.cn_document_bank_acc cdb
         WHERE cb.bank_name = '��� "��� ����"'
           AND cb.contact_id = v_contact_id
           AND cb.lic_code = (SELECT regexp_replace(lf.val_1, '[^0-9]+', '')
                                FROM load_file_rows lf
                               WHERE lf.load_file_rows_id = par_load_file_rows_id)
           AND rownum = 1
           AND doc.get_doc_status_name(cdb.cn_document_bank_acc_id) != '������'
           AND cdb.cn_contact_bank_acc_id = cb.id;
        IF v_used_flag = 1
        THEN
          par_comment := '���� ���� ��� ������� ��� �������� ������ � ������������';
        ELSE
          par_comment := '���� ���� ��� ������� ��� �������� ������';
        END IF;
        par_status := pkg_load_file_to_table.get_not_need_to_load;
        UPDATE load_file_rows lf
           SET lf.val_3      = par_comment
              ,lf.val_2      = initcap(v_fio_agent)
              ,lf.row_status = par_status
         WHERE lf.load_file_rows_id = par_load_file_rows_id;
        RETURN;
      EXCEPTION
        WHEN no_data_found THEN
          NULL; --����� ����� �� ���������, ���� ������
      END;
      --���� ����� ����� �� ���������, �������� �������� �� ���� ��� � ������:
      BEGIN
        SELECT cb.id
          INTO v_acc_bank_id
          FROM ins.cn_contact_bank_acc  cb
              ,ins.cn_document_bank_acc cdb
         WHERE cdb.cn_contact_bank_acc_id = cb.id
           AND cb.bank_name = '��� "��� ����"'
           AND cb.contact_id = v_contact_id
           AND ((doc.get_doc_status_name(cdb.cn_document_bank_acc_id) NOT IN
               ('������', '�������') --1
               AND cb.lic_code IS NULL) OR
               (doc.get_doc_status_name(cdb.cn_document_bank_acc_id) IN ('������')
               /*AND cb.lic_code is null
               AND cb.account_nr is null*/
               )) --2
              --  AND cb.place_of_issue is not null                                  --3
           AND rownum = 1;
      EXCEPTION
        WHEN no_data_found THEN
          par_status  := pkg_load_file_to_table.get_error;
          par_comment := '���� ����� ��� ����� ���� ��� � ������� �����������';
          UPDATE load_file_rows lf
             SET lf.val_3 = par_comment
                ,lf.val_2 = initcap(v_fio_agent)
           WHERE lf.load_file_rows_id = par_load_file_rows_id;
          RETURN;
      END;
      --���� ��� ������
    END IF;
    --���������� �����
    IF v_contact_id IS NOT NULL
       AND v_ach_agent IS NOT NULL
    THEN
      ---���������� �������� �����
      IF v_acc_bank_id IS NOT NULL
      THEN
        par_status  := pkg_load_file_to_table.get_checked;
        par_comment := '��. ������� ���� ����� ��������';
        ---���������� ������ �����
      ELSE
        par_status  := pkg_load_file_to_table.get_checked;
        par_comment := 'OK. ���� ����� ��������';
      END IF;
    END IF;
    UPDATE load_file_rows lf
       SET lf.val_3 = par_comment
          ,lf.val_2 = initcap(lf.val_2)
     WHERE lf.load_file_rows_id = par_load_file_rows_id;
  END import_hkf_check;

  --������ �������� "�������� ��������� ���������� ��� ���"
  --���������       "������ ��������� ���������� ��� ���"
  --��������� ��������  
  PROCEDURE import_hkf_load(par_load_file_rows_id NUMBER) IS
    v_res        VARCHAR2(200);
    v_contact_id NUMBER;
    vc_bank_id CONSTANT NUMBER := 836996; --��� ����
    v_card                    VARCHAR2(20);
    v_fio_agent               ins.contact.obj_name_orig%TYPE;
    v_cn_contact_bank_acc_id  NUMBER;
    v_ach_agent               ins.ag_contract_header.ag_contract_header_id%TYPE;
    v_cn_document_bank_acc_id ins.cn_document_bank_acc.cn_document_bank_acc_id%TYPE;
    v_acc_bank_id             ins.cn_contact_bank_acc.id%TYPE;
    v_ag_documents_id         NUMBER;
    v_ag_bank_props_id        NUMBER;
    v_comment                 VARCHAR2(200);
  BEGIN
    --������� ������ ������
    SELECT lf.val_3
      INTO v_res
      FROM load_file_rows lf
     WHERE lf.load_file_rows_id = par_load_file_rows_id;
  
    SELECT regexp_replace(lf.val_1, '[^0-9]+', '')
      INTO v_card
      FROM load_file_rows lf
     WHERE lf.load_file_rows_id = par_load_file_rows_id;
  
    --��������� ��� �� �����
    SELECT initcap(lf.val_2)
      INTO v_fio_agent
      FROM load_file_rows lf
     WHERE lf.load_file_rows_id = par_load_file_rows_id;
  
    BEGIN
      SELECT co.contact_id
            ,ch.ag_contract_header_id
        INTO v_contact_id
            ,v_ach_agent
        FROM ins.contact                co
            ,ins.ven_ag_contract_header ch
            ,ins.document               dc
            ,ins.doc_status_ref         dsr
       WHERE co.obj_name_orig = v_fio_agent
         AND ch.agent_id = co.contact_id
         AND dc.document_id = ch.ag_contract_header_id
         AND dsr.doc_status_ref_id = dc.doc_status_ref_id
         AND dsr.brief IN ('CURRENT') --������ ��� - �����������
         AND ch.is_new = 1; -- ����� ��������� ������
    EXCEPTION
      WHEN no_data_found THEN
        v_res := '�� ������ ����������� ��';
        UPDATE load_file_rows lf
           SET lf.val_3 = v_res
         WHERE lf.load_file_rows_id = par_load_file_rows_id;
        RETURN;
    END;
    --�������� ���������� ��������� � ������
    BEGIN
      SELECT cb.id
        INTO v_acc_bank_id
        FROM ins.cn_contact_bank_acc  cb
            ,ins.cn_document_bank_acc cdb
       WHERE cdb.cn_contact_bank_acc_id = cb.id
         AND cb.bank_name = '��� "��� ����"'
         AND cb.contact_id = v_contact_id
         AND doc.get_doc_status_name(cdb.cn_document_bank_acc_id) != '������' --1
         AND cb.lic_code IS NOT NULL --2                                 --3
         AND rownum = 1;
      --par_status := pkg_load_file_to_table.get_not_need_to_load;
      v_comment := '������. ��������� ����� � ������';
      UPDATE load_file_rows lf
         SET lf.val_3      = v_comment
            ,lf.row_status = pkg_load_file_to_table.get_error
       WHERE lf.load_file_rows_id = par_load_file_rows_id;
      RETURN;
    EXCEPTION
      WHEN no_data_found THEN
        NULL; --��� ��.
    END;
  
    BEGIN
      --��������� ����� ������������� �������� ����� ��������
      UPDATE cn_contact_bank_acc ba SET ba.used_flag = 0 WHERE ba.contact_id = v_contact_id;
      --���������� �������� �����
      IF v_res = 'OK. ���� ����� ��������'
      THEN
        --����� ������� ������ ������.
        -- ��������� �������� �������� ��� ���������� ������ � ������� cn_contact_bank_acc
        SELECT sq_cn_contact_bank_acc.nextval INTO v_cn_contact_bank_acc_id FROM dual;
        --���������� ��� ����� � ���������� ���� ��������
        INSERT INTO ven_cn_contact_bank_acc
          (id
          ,contact_id
          ,bank_id --�� �����
          ,bank_name --�������� �����
          ,account_nr --� �����
          ,bic_code --���
          ,bank_account_currency_id --�� ������ �����
          ,lic_code --� �������� �����
          ,owner_contact_id --�������� (�� ��������)
          ,is_check_owner --�������� ����� (����)
          ,used_flag) --���� ������������� ����� 1/0
        VALUES
          (v_cn_contact_bank_acc_id --�� ��������
          ,v_contact_id --�� �������� �� SOURCE �������
          ,vc_bank_id --v_bank_id constant number := 836996; --��� ����
          ,'��� "��� ����"' --��������
          ,v_card --����� ����� �� source �������
          ,'044585216' --��� ���
          ,122 --Id ������ - �����
          ,v_card --����� ����� �� source �������
          ,v_contact_id --�� �������� �� �������, � �������� ������ ��
          ,1 --�������� ���������� �����
          ,1); --���������� ���� ������������� �����
      
        -- ��������� �������� �������� ��� ���������� ������ � ������� cn_document_bank_acc
        SELECT sq_cn_document_bank_acc.nextval INTO v_cn_document_bank_acc_id FROM dual;
        --����� ��������� � ���������� ������ ��������
        INSERT INTO ven_cn_document_bank_acc
          (cn_document_bank_acc_id --����� ��������� � ���������� ������ ��������
          ,note --����������� �� ������� document
          ,cn_contact_bank_acc_id) --���������� ���� ��������
        VALUES
          (v_cn_document_bank_acc_id --�������
          ,'������ ����� ��������� �� ' || to_char(SYSDATE, 'DD.MM.YYYY HH24:MI:ss') --�����������
          ,v_cn_contact_bank_acc_id); --�� ����� ����������� �������� � ���������� INSERT
        --������� ������� �����
        doc.set_doc_status(p_doc_id => v_cn_document_bank_acc_id, p_status_brief => 'PROJECT');
        doc.set_doc_status(p_doc_id => v_cn_document_bank_acc_id, p_status_brief => 'ACTIVE');
        v_res := '���� ��������';
      
        ----���� ���������� ���� � ������ ��������� �������� �����, �� ��������� ������������
      ELSIF v_res = '��. ������� ���� ����� ��������'
      THEN
      
        SELECT cb.id
          INTO v_acc_bank_id
          FROM ins.cn_contact_bank_acc cb
         WHERE cb.contact_id = v_contact_id
           AND cb.bank_id = vc_bank_id;
      
        UPDATE ins.cn_contact_bank_acc cb
           SET cb.lic_code         = v_card
              ,cb.account_nr       = v_card
              ,cb.owner_contact_id = v_contact_id
              ,cb.is_check_owner   = 1
              ,cb.used_flag        = 1
         WHERE cb.id = v_acc_bank_id;
        --  dbms_output.put_line(hkbtab(i).card_num||';'||hkbtab(i).contact_name||';������������ ��� ���� ������ ������� ��������.');
        --�������� id ������������� �����
        BEGIN
          SELECT cdb.cn_document_bank_acc_id
            INTO v_cn_document_bank_acc_id
            FROM ins.cn_contact_bank_acc  cb
                ,ins.cn_document_bank_acc cdb
           WHERE cdb.cn_contact_bank_acc_id = cb.id
             AND cb.bank_name = '��� "��� ����"'
             AND cb.contact_id = v_contact_id;
        EXCEPTION
          WHEN no_data_found THEN
            raise_application_error(20020, '�� ������ ���� ���!');
        END;
        v_res := '������������ ��� ���� ������� ��������';
      
      ELSE
        v_res := '������� ��������� ��������.';
        RETURN;
      END IF;
      --��������� �������� �������� ��� ������� �������� � ������� ag_documents
      SELECT sq_ag_documents.nextval INTO v_ag_documents_id FROM dual;
      --�������� ��������� ��������� ����������
      INSERT INTO ven_ag_documents
        (ag_documents_id --��������� ����
        ,ent_id --�� �������� ��������� �� ������� document
        ,doc_templ_id --�� ������� ���������
        ,note --����������
        ,ag_contract_header_id --�� ��������� ��
        ,ag_doc_type_id --��� ��������� ��
        ,doc_date) --���� �������� ���������
      VALUES
        (v_ag_documents_id --�������
        ,4564 --�������� ��������� ���������� ��������(�� ������� ENTITY)
        ,17973 --������ - ��������� ���������� ��������
        ,'' --�����������
        ,v_ach_agent --�� ��������� ��
        ,7 --��������� ��������� ����������
        ,trunc(SYSDATE, 'dd')); --������� ����(��� �����, �����, ������)
      --���������� ������� ���������� ���������� ������
      UPDATE ag_bank_props bp SET bp.enable = 0 WHERE bp.ag_contract_header_id = v_ach_agent;
      --��������� �������� �������� ��� ���������� ����� ����������(������� ag_bank_props)
      SELECT sq_ag_bank_props.nextval INTO v_ag_bank_props_id FROM dual;
      --���������� ����� ���������� ���������� �� �����(1 �������)
      INSERT INTO ven_ag_bank_props
        (ag_bank_props_id
        ,account --��������� ����
        ,ag_contract_header_id --��������� ��
        ,ag_documents_id --�������� ��
        ,bank_id --����
        ,cn_contact_bank_acc_id --���������� ���� ��������
        ,ENABLE --���� �������������
        ,fund_id --������
        ,note --����������
        ,payment_props) --��������� ���������
      VALUES
        (v_ag_bank_props_id --�������
        ,v_card --����� ����� �� SOURCE �������
        ,v_ach_agent --��������� �� ��������
        ,v_ag_documents_id --������� �� insert into ven_ag_documents
        ,vc_bank_id --�� ��� �����
        ,v_cn_contact_bank_acc_id --������� �� insert into ven_cn_contact_bank_acc
        ,1 --���������� ���� �������������
        ,122 --������ - �����
        ,'������ ����� ��������� �� ' || to_char(SYSDATE, 'DD.MM.YYYY HH24:MI:ss') --����� ����������
        ,v_card); --����� ����� �� SOURCE �������
      --������� �������� ��������� "���������� ��������� ����������"
      doc.set_doc_status(p_doc_id => v_cn_document_bank_acc_id, p_status_brief => 'ACTIVE');
      doc.set_doc_status(p_doc_id => v_ag_documents_id, p_status_brief => 'PROJECT');
      doc.set_doc_status(p_doc_id => v_ag_documents_id, p_status_brief => 'PRINTED');
      doc.set_doc_status(p_doc_id => v_ag_documents_id, p_status_brief => 'RECEIVED_FROM_AGENT');
      doc.set_doc_status(p_doc_id => v_ag_documents_id, p_status_brief => 'CO_ACCEPTED');
      -- v_res:='���� ���������';
      -- dbms_output.put_line(hkbtab(i).card_num||';'||v_agnum||';'||hkbtab(i).contact_name||';Ok ' ||V_res);
      -- v_res:=null; v_acc_bank_id:=null;v_is_check:=null;v_lic_code:=null;v_agnum:=null;
      UPDATE load_file_rows lf
         SET lf.val_3 = v_res
       WHERE lf.load_file_rows_id = par_load_file_rows_id;
    EXCEPTION
      WHEN OTHERS THEN
        -- par_status := pkg_load_file_to_table.get_error;
      
        v_res := '������' || SQLERRM;
        UPDATE load_file_rows lf
           SET lf.val_3 = v_res
         WHERE lf.load_file_rows_id = par_load_file_rows_id;
        RETURN;
    END;
  END import_hkf_load;

  /*
    ������ �.
    �������� ��� �������� �������������
    ������������� ��������� �������� ��� ������� �����������, ������� ���� � ���, ���� �� ����������
  */
  PROCEDURE check_annulation_row
  (
    par_load_file_rows_id NUMBER
   ,par_status            OUT VARCHAR2
   ,par_comment           OUT VARCHAR2
  ) IS
    v_reason_name t_decline_reason.name%TYPE;
    v_check       NUMBER;
  BEGIN
    BEGIN
      -- �������� ����� �� ������������. ��������� 07.06.2013
      --IDS(����� ����� ������ ������ � �������� � ������� � �������� ���)
      v_check := NULL;
      SELECT CASE
               WHEN length(regexp_replace(TRIM(lf.val_2), '[^0-9]+', '')) = length(TRIM(lf.val_2)) THEN
                1
               ELSE
                0
             END checking
        INTO v_check
        FROM ins.load_file_rows lf
       WHERE lf.load_file_rows_id = par_load_file_rows_id;
      IF v_check = 0
      THEN
        par_status  := pkg_load_file_to_table.get_error;
        par_comment := '��� �������� ������ ��������� ������ �����. ��������� ���� �������';
        RETURN;
      
      END IF;
      --���
      SELECT CASE
               WHEN lf.val_3 IS NULL
                    OR length(regexp_replace(TRIM(lf.val_3), '[^0-9]+', '')) = length(TRIM(lf.val_3)) THEN
                1
               ELSE
                0
             END checking
        INTO v_check
        FROM ins.load_file_rows lf
       WHERE lf.load_file_rows_id = par_load_file_rows_id;
      IF v_check = 0
      THEN
        par_status  := pkg_load_file_to_table.get_error;
        par_comment := '��� ������ ��������� ������ �����. ��������� ���� �������';
        RETURN;
      END IF;
      --��������� ����
      SELECT CASE
               WHEN lf.val_4 IS NULL
                    OR length(regexp_replace(TRIM(lf.val_4), '[^0-9]+', '')) = length(TRIM(lf.val_4)) THEN
                1
               ELSE
                0
             END checking
        INTO v_check
        FROM ins.load_file_rows lf
       WHERE lf.load_file_rows_id = par_load_file_rows_id;
      IF v_check = 0
      THEN
        par_status  := pkg_load_file_to_table.get_error;
        par_comment := '��������� ���� ������ ��������� ������ �����. ��������� ���� �������';
        RETURN;
      END IF;
      --Id ������� �����������
      SELECT CASE
               WHEN length(regexp_replace(TRIM(lf.val_5), '[^0-9]+', '')) = length(TRIM(lf.val_5)) THEN
                1
               ELSE
                0
             END checking
        INTO v_check
        FROM ins.load_file_rows lf
       WHERE lf.load_file_rows_id = par_load_file_rows_id;
      IF v_check = 0
      THEN
        par_status  := pkg_load_file_to_table.get_error;
        par_comment := 'ID ������� ����������� ������ ��������� ������ �����. ��������� ���� �������';
        RETURN;
      END IF;
      -----------------------------------------------------
      -- ������� ������� ����������� � ����� "�����������"
      SELECT dr.name
        INTO v_reason_name
        FROM t_decline_reason dr
       WHERE dr.t_decline_reason_id =
             (SELECT to_number(lf.val_5)
                FROM load_file_rows lf
               WHERE lf.load_file_rows_id = par_load_file_rows_id)
         AND dr.brief IN ('�������� ������� ������'
                         ,'����� �����������'
                         ,'����� ������������ �� ��'
                         ,'������� ���� (�������������)'
                         ,'����� ������������ �� ��������'
                         ,'�������������������������');
      -- ���� �����, ��� ��
      par_status  := pkg_load_file_to_table.get_checked;
      par_comment := NULL;
    EXCEPTION
      WHEN no_data_found THEN
        -- ���� �� �����, ��� �����
        par_status  := pkg_load_file_to_table.get_error;
        par_comment := '�� ������� ������� ����������� �� ��';
    END;
    -- ������ ������� �����������, ���������� �������� 0 � ���
    UPDATE load_file_rows lf
       SET lf.val_8 = v_reason_name
          ,lf.val_3 = CASE
                        WHEN NOT regexp_like(lf.val_3, '^0') THEN
                         '0' || lf.val_3
                        ELSE
                         lf.val_3
                      END
     WHERE lf.load_file_rows_id = par_load_file_rows_id;
  
  END check_annulation_row;

  /*
    ������ �.
    ��������� ������������� ���������, ��������� ��������
  */
  PROCEDURE annulate_list(par_load_file_rows_id NUMBER) IS
    TYPE t_file_row IS RECORD(
       ids        NUMBER
      ,bic        VARCHAR2(20)
      ,account    VARCHAR2(20)
      ,reason_id  NUMBER
      ,policy_num VARCHAR2(1024)
      ,insured    VARCHAR2(50));
    v_file_row          t_file_row;
    v_policy_id         NUMBER;
    v_insured_id        NUMBER;
    v_product_conds_id  NUMBER;
    v_decline_reason_id NUMBER;
    v_commission        NUMBER;
    v_new_policy_id     NUMBER;
    v_error_message     VARCHAR2(250);
    v_continue          BOOLEAN := TRUE;
    v_to_req_query      BOOLEAN := FALSE;
    v_pay_req_id        NUMBER;
    v_product_breif     t_product.brief%TYPE;
    /* ������ "�������" �� ������ */
    PROCEDURE set_not_checked(par_load_file_rows_id NUMBER) IS
    BEGIN
      UPDATE load_file_rows lf
         SET lf.is_checked = 0
       WHERE lf.load_file_rows_id = par_load_file_rows_id;
    END set_not_checked;
  
    /* ������� ������� � ��������� �� ����������� */
    PROCEDURE find_policy_and_decline
    (
      par_ids           NUMBER
     ,par_policy_id     OUT NUMBER
     ,par_error_message OUT VARCHAR2
     ,par_continue      OUT BOOLEAN
    ) IS
    BEGIN
      SELECT ph.last_ver_id INTO par_policy_id FROM p_pol_header ph WHERE ph.ids = par_ids;
    
      BEGIN
        doc.set_doc_status(p_doc_id => par_policy_id, p_status_brief => 'QUIT_DECL');
        par_continue := TRUE;
      EXCEPTION
        WHEN OTHERS THEN
          par_error_message := '���������� ������� ��������� ������ � ������ "��������� �� �����������". ����� ������: ' ||
                               SQLERRM;
          par_continue      := FALSE;
      END;
    EXCEPTION
      WHEN no_data_found THEN
        par_error_message := '������� �� ��������� �� ��������������';
        par_continue      := FALSE;
    END find_policy_and_decline;
  
    /* ����� ��������������� � ��������� ���������� */
    PROCEDURE find_insured_and_req
    (
      par_policy_id     NUMBER
     ,par_insured       VARCHAR2
     ,par_account       VARCHAR2
     ,par_bic           VARCHAR2
     ,par_insured_id    OUT NUMBER
     ,par_pay_req_id    OUT NUMBER
     ,par_error_message OUT VARCHAR2
     ,par_continue      OUT BOOLEAN
     ,par_to_req_query  OUT BOOLEAN
    ) IS
      v_bank_id                 NUMBER;
      v_owner_id                contact.contact_id%TYPE;
      v_can_create              BOOLEAN := TRUE;
      v_bank_name               contact.obj_name_orig%TYPE;
      v_cn_document_bank_acc_id NUMBER;
    BEGIN
      par_to_req_query := FALSE;
      par_continue     := TRUE;
      -- ���� ��� ��������������� �������, ����� �� ���
      IF par_insured IS NOT NULL
      THEN
        SELECT pi.contact_id
          INTO par_insured_id
          FROM v_pol_issuer pi
         WHERE pi.policy_id = par_policy_id
           AND upper(pi.contact_name) = upper(par_insured);
      ELSE
        -- �����, �������������� �� ��������
        SELECT pi.contact_id
          INTO par_insured_id
          FROM v_pol_issuer pi
         WHERE pi.policy_id = par_policy_id;
      END IF;
    
      -- ������ �.
      -- ������ �191616
      IF par_account IS NOT NULL
         AND par_bic IS NOT NULL
      THEN
        -- ����� ��������� ���������
        BEGIN
          SELECT ba.id
            INTO par_pay_req_id
            FROM cn_contact_bank_acc  ba
                ,cn_document_bank_acc da
                ,document             dc
                ,doc_status_ref       dsr
                ,cn_contact_ident     ci
                ,t_id_type            it
           WHERE ba.contact_id = par_insured_id
             AND ba.id = da.cn_contact_bank_acc_id
             AND da.cn_document_bank_acc_id = dc.document_id
             AND dc.doc_status_ref_id = dsr.doc_status_ref_id
             AND dsr.brief = 'ACTIVE'
             AND ba.account_nr = par_account
             AND ba.bank_id = ci.contact_id
             AND ci.id_type = it.id
             AND it.brief = 'BIK'
             AND ci.id_value = par_bic
                -- �.�. ������ ���������
             AND rownum = 1;
        EXCEPTION
          WHEN no_data_found THEN
            BEGIN
              -- ���� �� ������, �������� ���������
              -- ����� ����� �� ���
              SELECT co.contact_id
                    ,co.obj_name_orig
                INTO v_bank_id
                    ,v_bank_name
                FROM contact co
               WHERE co.contact_id IN (SELECT cr.contact_id
                                         FROM cn_contact_role cr
                                             ,t_contact_role  tr
                                        WHERE cr.role_id = tr.id
                                          AND tr.description = '����')
                 AND co.contact_id IN (SELECT ci.contact_id
                                         FROM cn_contact_ident ci
                                             ,t_id_type        it
                                        WHERE ci.id_type = it.id
                                          AND it.brief = 'BIK'
                                          AND ci.id_value = par_bic)
                    -- �.�. ������ ����� ���� ����� � ���������� �����
                 AND rownum = 1;
            
              -- �������� ����� �� ������������ ����������
              pkg_contact.check_account_nr(par_account_nr    => par_account
                                          ,par_bank_id       => v_bank_id
                                          ,par_can_continue  => v_can_create
                                          ,par_error_message => par_error_message);
              -- ���� �������� �� ������, ��������� �� �������� ��� ���
              IF par_error_message IS NOT NULL
              THEN
                pkg_contact.check_account_nr_rkc(par_account       => par_account
                                                ,par_bik           => par_bic
                                                ,par_can_continue  => v_can_create
                                                ,par_error_message => par_error_message);
                NULL;
              END IF;
            
              -- ���� ��� �������� �������, �������� ���������
              IF par_error_message IS NULL
              THEN
                -- ���������� ����� ����������� ��������� �����
                BEGIN
                  SELECT c.contact_id
                    INTO v_owner_id
                    FROM cn_contact_bank_acc  bac
                        ,cn_document_bank_acc dac
                        ,contact              c
                   WHERE bac.account_nr = par_account
                     AND bac.bank_id = v_bank_id
                     AND bac.id = dac.cn_contact_bank_acc_id
                     AND doc.get_doc_status_name(dac.cn_document_bank_acc_id) = '��������'
                     AND nvl(bac.is_check_owner, 0) = 1
                     AND bac.contact_id = c.contact_id
                     AND rownum = 1;
                EXCEPTION
                  WHEN no_data_found THEN
                    v_owner_id := par_insured_id;
                END;
                -- �������
                pkg_contact.insert_account_nr(par_contact_id               => par_insured_id
                                             ,par_account_corr             => NULL
                                             ,par_account_nr               => par_account
                                             ,par_bank_account_currency_id => 122 --'RUR'
                                             ,par_bank_approval_date       => NULL
                                             ,par_bank_approval_end_date   => NULL
                                             ,par_bank_approval_reference  => NULL
                                             ,par_bank_id                  => v_bank_id
                                             ,par_bank_name                => v_bank_name
                                             ,par_bic_code                 => par_bic
                                             ,par_branch_id                => NULL
                                             ,par_branch_name              => NULL
                                             ,par_country_id               => NULL
                                             ,par_iban_reference           => NULL
                                             ,par_is_check_owner           => CASE
                                                                                WHEN par_insured_id = v_owner_id THEN
                                                                                 1
                                                                                ELSE
                                                                                 0
                                                                              END
                                             ,par_lic_code                 => NULL
                                             ,par_order_number             => NULL
                                             ,par_owner_contact_id         => v_owner_id
                                             ,par_remarks                  => NULL
                                             ,par_swift_code               => NULL
                                             ,par_used_flag                => 1
                                             ,par_cn_contact_bank_acc_id   => par_pay_req_id
                                             ,par_cn_document_bank_acc_id  => v_cn_document_bank_acc_id);
              
                doc.set_doc_status(p_doc_id => v_cn_document_bank_acc_id, p_status_brief => 'ACTIVE');
              ELSE
                par_to_req_query := TRUE;
              END IF;
            EXCEPTION
              WHEN no_data_found THEN
                par_error_message := '�� ������ ������� � ����� "����" � ����������� ������� ���';
                par_to_req_query  := TRUE;
            END;
        END;
      ELSE
        par_to_req_query := TRUE;
      END IF;
    EXCEPTION
      WHEN no_data_found THEN
        par_error_message := '��� ������������ ���������� �������� �� ��������� � ��� ������������ ������������ �����';
        par_continue      := FALSE;
        par_to_req_query  := FALSE;
    END find_insured_and_req;
  
    /* ����� ������� ����������� */
    FUNCTION find_decline_reason(par_decline_reason_id NUMBER) RETURN NUMBER IS
      v_decline_reason_id NUMBER;
    BEGIN
      SELECT dr.t_decline_reason_id
        INTO v_decline_reason_id
        FROM t_decline_reason dr
       WHERE dr.t_decline_reason_id = par_decline_reason_id;
      RETURN v_decline_reason_id;
    EXCEPTION
      WHEN no_data_found THEN
        RETURN NULL;
    END find_decline_reason;
  
    /* ����� �������� ������� */
    FUNCTION find_product_conds(par_policy_id NUMBER) RETURN NUMBER IS
      v_product_conds_id NUMBER;
    BEGIN
      SELECT pp.t_product_conds_id
        INTO v_product_conds_id
        FROM p_policy pp
       WHERE pp.policy_id = par_policy_id;
    
      RETURN v_product_conds_id;
    EXCEPTION
      WHEN no_data_found THEN
        RETURN v_product_conds_id;
    END find_product_conds;
  
    /* �������� ����� ������ � ��������� �� �� ������� "� �����������. ��������"
       ����� �������� ���������� ����������
    */
    PROCEDURE create_policy_cancel
    (
      par_policy_id         NUMBER
     ,par_decline_reason_id NUMBER
     ,par_commission        NUMBER
     ,par_product_conds_id  NUMBER
     ,par_payreq_contact_id NUMBER
     ,par_payreq_id         NUMBER
     ,par_to_req_query      BOOLEAN
     ,par_new_policy_id     OUT NUMBER
     ,par_error_message     OUT VARCHAR2
     ,par_continue          OUT BOOLEAN
    ) IS
      v_region_id     p_policy.region_id%TYPE;
      v_result        NUMBER(1);
      v_payment_id    NUMBER;
      v_version_start p_policy.start_date%TYPE;
    BEGIN
      -- ������ �.
      -- ������� ������� �� ������ 273406
      -- � ������� ������ ����, ����� ������� ���� ������ ������
      SELECT pp.region_id
            ,pp.start_date
        INTO v_region_id
            ,v_version_start
        FROM p_policy pp
       WHERE pp.policy_id = par_policy_id;
    
      IF par_decline_reason_id NOT IN
         (222 /*������� ����*/, 226 /*������� �����*/)
      THEN
        v_version_start := SYSDATE;
      END IF;
    
      BEGIN
        par_new_policy_id := pkg_policy.new_policy_version(par_policy_id
                                                          ,NULL
                                                          ,'TO_QUIT'
                                                          ,NULL
                                                          ,v_version_start);
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
    
      IF par_new_policy_id IS NOT NULL
      THEN
        v_result := pkg_decline.policy_cancel(par_new_policy_id
                                             ,par_decline_reason_id
                                             ,pkg_decline.check_hkf(par_policy_id)
                                             ,pkg_decline.check_medo(par_policy_id)
                                             ,par_commission
                                             , /*p_cover_admin*/0 -- ����� ������ �� ��������
                                             ,v_region_id
                                             ,par_product_conds_id);
      
        BEGIN
          pkg_decline.policy_to_state_check_ready(par_policy_id => par_new_policy_id);
          BEGIN
            doc.set_doc_status(par_new_policy_id, 'TO_QUIT_CHECKED');
            UPDATE p_pol_decline pd
               SET pd.issuer_return_date = NULL
             WHERE pd.p_policy_id = par_new_policy_id;
            IF par_to_req_query
            THEN
              doc.set_doc_status(par_new_policy_id, 'QUIT_REQ_QUERY');
              -- �������� � ��������� �����
              /*            ELSE
              v_payment_id := pkg_decline.create_payreq(par_new_policy_id
                                                       ,par_payreq_contact_id
                                                       ,par_payreq_id);*/
            END IF;
            par_continue := TRUE;
          EXCEPTION
            WHEN OTHERS THEN
              par_continue      := FALSE;
              par_error_message := '���������� ������� ������ �� ������� "� �����������. ����� ��� ��������" � ������ "� �����������. ��������".';
          END;
        EXCEPTION
          WHEN OTHERS THEN
            par_continue      := FALSE;
            par_error_message := '���������� ������� ������ �� ������� "� �����������" � ������ "� �����������. ����� ��� ��������".';
        END;
      ELSE
        par_continue      := FALSE;
        par_error_message := '�� ������� ������� ������ "� �����������"';
      END IF;
    END;
  
  BEGIN
    SAVEPOINT before_annulate;
    BEGIN
      SELECT to_number(lf.val_2)
            ,lf.val_3
            ,lf.val_4
            ,to_number(lf.val_5)
            ,lf.val_6
            ,lf.val_7
        INTO v_file_row
        FROM load_file_rows lf
       WHERE lf.load_file_rows_id = par_load_file_rows_id
         AND lf.row_status = pkg_load_file_to_table.get_checked;
    EXCEPTION
      WHEN no_data_found THEN
        pkg_load_file_to_table.set_row_status(par_load_file_rows_id => par_load_file_rows_id
                                             ,par_row_status        => pkg_load_file_to_table.get_error
                                             ,par_row_comment       => '������ �� ����� ���� ���������, �.�. �� ������ ��������');
        v_continue := FALSE;
    END;
    IF v_continue
    THEN
      /* �� �������� �������� �IDS� ������� �GROUP_QUIT_FILE_ROW2� ������ �� � ������ ��������� �������� �������������� */
      find_policy_and_decline(par_ids           => v_file_row.ids
                             ,par_policy_id     => v_policy_id
                             ,par_error_message => v_error_message
                             ,par_continue      => v_continue);
      IF v_continue
      THEN
        /* ���� �����, ����� ���������������/����������, ���� ���������� ���, ������� */
        find_insured_and_req(par_policy_id     => v_policy_id
                            ,par_insured       => v_file_row.insured
                            ,par_account       => v_file_row.account
                            ,par_bic           => v_file_row.bic
                            ,par_insured_id    => v_insured_id
                            ,par_pay_req_id    => v_pay_req_id
                            ,par_error_message => v_error_message
                            ,par_continue      => v_continue
                            ,par_to_req_query  => v_to_req_query);
        IF v_continue
        THEN
          v_decline_reason_id := find_decline_reason(par_decline_reason_id => v_file_row.reason_id);
          IF v_decline_reason_id IS NOT NULL
          THEN
            v_product_conds_id := find_product_conds(par_policy_id => v_policy_id);
            IF v_product_conds_id IS NOT NULL
            THEN
              v_commission := pkg_decline.check_comiss(v_policy_id);
              SELECT p.brief
                INTO v_product_breif
                FROM t_product    p
                    ,p_pol_header ph
                    ,p_policy     pp
               WHERE pp.policy_id = v_policy_id
                 AND pp.pol_header_id = ph.policy_header_id
                 AND ph.product_id = p.product_id;
              IF v_commission != 0
                 OR v_product_breif LIKE 'RenCap%'
              THEN
                create_policy_cancel(par_policy_id         => v_policy_id
                                    ,par_decline_reason_id => v_decline_reason_id
                                    ,par_commission        => v_commission
                                    ,par_product_conds_id  => v_product_conds_id
                                    ,par_payreq_contact_id => v_insured_id
                                    ,par_payreq_id         => v_pay_req_id
                                    ,par_to_req_query      => v_to_req_query
                                    ,par_new_policy_id     => v_new_policy_id
                                    ,par_error_message     => v_error_message
                                    ,par_continue          => v_continue);
                IF v_continue
                THEN
                  IF NOT v_to_req_query
                  THEN
                    DECLARE
                      v_payment_id NUMBER;
                    BEGIN
                      v_payment_id := pkg_decline.create_payreq(v_new_policy_id
                                                               ,v_insured_id
                                                               ,v_pay_req_id);
                      UPDATE load_file_rows lf
                         SET lf.ure_id     = 283
                            ,lf.uro_id     = v_new_policy_id
                            ,lf.is_checked = 1
                       WHERE lf.load_file_rows_id = par_load_file_rows_id;
                      pkg_load_file_to_table.set_row_status(par_load_file_rows_id => par_load_file_rows_id
                                                           ,par_row_status        => pkg_load_file_to_table.get_loaded
                                                           ,par_row_comment       => v_error_message);
                    EXCEPTION
                      WHEN OTHERS THEN
                        set_not_checked(par_load_file_rows_id);
                        pkg_load_file_to_table.set_row_status(par_load_file_rows_id => par_load_file_rows_id
                                                             ,par_row_status        => pkg_load_file_to_table.get_error
                                                             ,par_row_comment       => dbms_utility.format_error_stack);
                    END;
                  END IF;
                ELSE
                  ROLLBACK TO before_annulate;
                  set_not_checked(par_load_file_rows_id);
                  pkg_load_file_to_table.set_row_status(par_load_file_rows_id => par_load_file_rows_id
                                                       ,par_row_status        => pkg_load_file_to_table.get_error
                                                       ,par_row_comment       => v_error_message);
                END IF;
              ELSE
                ROLLBACK TO before_annulate;
                set_not_checked(par_load_file_rows_id);
                pkg_load_file_to_table.set_row_status(par_load_file_rows_id => par_load_file_rows_id
                                                     ,par_row_status        => pkg_load_file_to_table.get_error
                                                     ,par_row_comment       => '����� �������� ����� 0');
              END IF;
            ELSE
              ROLLBACK TO before_annulate;
              set_not_checked(par_load_file_rows_id);
              pkg_load_file_to_table.set_row_status(par_load_file_rows_id => par_load_file_rows_id
                                                   ,par_row_status        => pkg_load_file_to_table.get_error
                                                   ,par_row_comment       => '�������� ������� �� ������� � ��������� ������ ��������');
            END IF;
          ELSE
            ROLLBACK TO before_annulate;
            set_not_checked(par_load_file_rows_id);
            pkg_load_file_to_table.set_row_status(par_load_file_rows_id => par_load_file_rows_id
                                                 ,par_row_status        => pkg_load_file_to_table.get_error
                                                 ,par_row_comment       => '��������� ������� ����������� �� ����������');
          END IF;
        ELSE
          ROLLBACK TO before_annulate;
          set_not_checked(par_load_file_rows_id);
          pkg_load_file_to_table.set_row_status(par_load_file_rows_id => par_load_file_rows_id
                                               ,par_row_status        => pkg_load_file_to_table.get_error
                                               ,par_row_comment       => v_error_message);
        END IF;
      ELSE
        ROLLBACK TO before_annulate;
        set_not_checked(par_load_file_rows_id);
        pkg_load_file_to_table.set_row_status(par_load_file_rows_id => par_load_file_rows_id
                                             ,par_row_status        => pkg_load_file_to_table.get_error
                                             ,par_row_comment       => v_error_message);
      END IF;
    END IF;
  END annulate_list;

  /*
  ������ �������� �������� ��������� �� ����������� �� ���� (� 6.11.2014 ��������� ��-������)
  */
  PROCEDURE group_decline_hkb_old(par_load_file_id load_file.load_file_id%TYPE) IS
    policy_not_found      EXCEPTION;
    bank_annulation       EXCEPTION;
    court_annulation      EXCEPTION;
    other_annulation      EXCEPTION;
    too_many_policies     EXCEPTION;
    exists_payment_to_pay EXCEPTION;
    exists_claim          EXCEPTION;
    exists_closed_claim   EXCEPTION;
    loan_is_not_repaid    EXCEPTION;
    set_status_error      EXCEPTION;
    policy_locked         EXCEPTION;
  
    c_to pkg_email.t_recipients := pkg_email.t_recipients('bank_cancel_hkb@renlife.com');
    c_cc pkg_email.t_recipients := pkg_email.t_recipients('cancel_hkb@renlife.com'
                                                         ,'pavel.vrona@renlife.com'
                                                         ,'Tatyana.Gorshkova@Renlife.com'
                                                         ,'Rustam.Ahtyamov@renlife.com'
                                                         ,'Andrey.Gizhunov@Renlife.com'
                                                         ,'Aleksey.Sharin@renlife.com'
                                                         ,'Ivan.Holodov@renlife.com');
  
    vr_policy               p_policy%ROWTYPE;
    vr_pol_header           p_pol_header%ROWTYPE;
    v_policy_status_brief   doc_status_ref.brief%TYPE;
    v_ag_contract_header_id ag_contract_header.ag_contract_header_id%TYPE;
    v_decline_reason_id     t_decline_reason.t_decline_reason_id%TYPE;
    vr_decline_reason       t_decline_reason%ROWTYPE;
    v_decline_policy_id     p_policy.policy_id%TYPE;
    v_refusal_reason        VARCHAR2(20);
    v_decline_date          DATE;
    v_pol_decline_id        p_pol_decline.p_pol_decline_id%TYPE;
    v_client_return_summ    p_policy.return_summ%TYPE;
    v_rko_return_sum        NUMBER;
    v_agent_return_summ     NUMBER;
    v_decision              VARCHAR2(10);
    v_errors_exists         NUMBER(1);
    v_result                NUMBER(1);
    v_comment               VARCHAR2(2000);
  
    c_decision_refusal CONSTANT VARCHAR2(30) := '�����';
    c_decision_error   CONSTANT VARCHAR2(30) := '������';
    c_decision_payback CONSTANT VARCHAR2(30) := '�������';
    c_rvd_perc         CONSTANT NUMBER := 0.23;
  
    /* ����� �� �� ������ � ��� ������������ */
    FUNCTION find_policy(par_policy_num p_policy.pol_num%TYPE) RETURN p_policy%ROWTYPE IS
      vr_result_policy p_policy%ROWTYPE;
    BEGIN
      SELECT pp.*
        INTO vr_result_policy
        FROM p_pol_header ph
            ,p_policy     pp
       WHERE ph.max_uncancelled_policy_id = pp.policy_id
         AND pp.pol_num = par_policy_num
         AND EXISTS (SELECT NULL
                FROM document       dc
                    ,doc_status_ref dsr
               WHERE dc.document_id = ph.policy_id
                 AND dc.doc_status_ref_id = dsr.doc_status_ref_id
                 AND dsr.brief != 'CANCEL');
      RETURN vr_result_policy;
    EXCEPTION
      WHEN no_data_found THEN
        RAISE policy_not_found;
      WHEN too_many_rows THEN
        RAISE too_many_policies;
    END find_policy;
  
    /* ��������� ������� ����������� ������ */
    FUNCTION find_pol_decline_reason(par_policy_id p_policy.policy_id%TYPE)
      RETURN t_decline_reason%ROWTYPE IS
      v_decline_reason_id t_decline_reason.t_decline_reason_id%TYPE;
      v_decline_reason    t_decline_reason%ROWTYPE;
    BEGIN
      SELECT dr.t_decline_reason_id
        INTO v_decline_reason_id
        FROM p_policy         pp
            ,t_decline_reason dr
       WHERE pp.policy_id = par_policy_id
         AND pp.decline_reason_id = dr.t_decline_reason_id;
    
      v_decline_reason := dml_t_decline_reason.get_record(v_decline_reason_id);
    
      RETURN v_decline_reason;
    
    EXCEPTION
      WHEN no_data_found THEN
        RETURN v_decline_reason;
    END find_pol_decline_reason;
  
    PROCEDURE check_payments_to_pay(par_pol_header_id p_pol_header.policy_header_id%TYPE) IS
      v_exists_to_pay NUMBER(1);
    BEGIN
      SELECT COUNT(1)
        INTO v_exists_to_pay
        FROM dual
       WHERE EXISTS (SELECT NULL
                FROM p_policy       pp
                    ,doc_doc        dd
                    ,document       dc
                    ,doc_templ      dt
                    ,doc_status_ref dsr
               WHERE pp.pol_header_id = par_pol_header_id
                 AND pp.policy_id = dd.parent_id
                 AND dd.child_id = dc.document_id
                 AND dc.doc_templ_id = dt.doc_templ_id
                 AND dt.brief = 'PAYMENT'
                 AND dc.doc_status_ref_id = dsr.doc_status_ref_id
                 AND dsr.brief = 'TO_PAY');
      IF v_exists_to_pay = 1
      THEN
        RAISE exists_payment_to_pay;
      END IF;
    END check_payments_to_pay;
  
    PROCEDURE check_claims(par_pol_header_id p_pol_header.policy_header_id%TYPE) IS
      v_exists_claim NUMBER(1);
    BEGIN
      SELECT COUNT(1)
        INTO v_exists_claim
        FROM dual
       WHERE EXISTS (SELECT NULL
                FROM p_policy       pp
                    ,c_claim_header ch
                    ,c_claim        cl
                    ,document       dc
                    ,doc_status_ref dsr
               WHERE pp.pol_header_id = par_pol_header_id
                 AND pp.policy_id = ch.p_policy_id
                 AND ch.active_claim_id = cl.c_claim_id
                 AND cl.c_claim_id = dc.document_id
                 AND dc.doc_status_ref_id = dsr.doc_status_ref_id
                 AND dsr.brief != 'CLOSE');
      IF v_exists_claim = 1
      THEN
        RAISE exists_claim;
      END IF;
    END check_claims;
  
    PROCEDURE check_closed_claims(par_pol_header_id p_pol_header.policy_header_id%TYPE) IS
      v_exists_closed_claim NUMBER(1);
    BEGIN
      SELECT COUNT(1)
        INTO v_exists_closed_claim
        FROM dual
       WHERE EXISTS (SELECT NULL
                FROM p_policy       pp
                    ,c_claim_header ch
                    ,c_claim        cl
                    ,document       dc
                    ,doc_status_ref dsr
                    ,c_damage       cd
               WHERE pp.pol_header_id = par_pol_header_id
                 AND pp.policy_id = ch.p_policy_id
                 AND ch.active_claim_id = cl.c_claim_id
                 AND cl.c_claim_id = dc.document_id
                 AND dc.doc_status_ref_id = dsr.doc_status_ref_id
                 AND dsr.brief = 'CLOSE'
                 AND cl.c_claim_id = cd.c_claim_id
                 AND cd.payment_sum > 0);
      IF v_exists_closed_claim = 1
      THEN
        RAISE exists_closed_claim;
      END IF;
    END check_closed_claims;
  
    PROCEDURE get_cooling_period
    (
      par_decline_notice_date DATE
     ,par_repayment_date      DATE
     ,par_policy_confirm_date p_policy.confirm_date%TYPE
     ,par_header_start_date   p_pol_header.start_date%TYPE
     ,par_decline_reason_id   OUT t_decline_reason.t_decline_reason_id%TYPE
     ,par_refusal_reason      OUT VARCHAR2
    ) IS
    
    BEGIN
      /* �������������� �������� ��������� ��������� �� ����������� � ������ ����������.
      ������� ����� ��������� ���� ����� ��������� �� ������������ �������
      � ��������� ���� ����� ���������� � ���� ������� ����������� �����
      �������� ������������*/
      IF par_decline_notice_date - par_policy_confirm_date + 1 /* ����� �.: ���������� ���� ��� ������������� �� ������ 385527*/
         > pkg_policy.define_cooling_period_length(par_header_start_date)
      THEN
        /* ������ 30 ����, �.�. ��������� �� ������� �� �������� � ������ ����������.
        � ���� ������ ����������� ���������� ���� ����� ��������� ������� � ������� */
        IF par_repayment_date IS NULL
        THEN
          /* ���� �������� ���� ����� ��������� ������� ������� ������,
          �� ���� �������� ������� ��������� �������� ������,
          ���� ������������ ������� ��������� ��������
          ����� ������ ��������� ��������� 30 ���� � ���� ����������,
          ������ �� �������, ���������� ��������� ������ ������� ��� ���������.*/
          RAISE loan_is_not_repaid;
        ELSE
          /* ���� �������� ���� ����� ��������� ������� �� ������, �� ���������
          ������ ����������� � ��������� �������� ������������ ������
          ���������� ���������, ���� �������� ������ �������
          ��������� �������� ���ϻ */
          par_decline_reason_id := pkg_t_decline_reason_dml.get_id_by_brief('��������� ���������');
          par_refusal_reason    := '���';
        END IF;
      ELSE
        /* ������ 30 ����, �� ��������� �������� � ������ ����������.
        � ������ ������ �������� ������ ����������� � ��������� �������� ������������
        ������ 225 � ������ ������������ �� ��������,
        � ���� �������� ������ ������� ��������� �������� ������� �����������.*/
        par_decline_reason_id := pkg_t_decline_reason_dml.get_id_by_brief('����� ������������ �� ��������');
        par_refusal_reason    := '������ ����������';
      END IF;
    END get_cooling_period;
  
    PROCEDURE create_new_version
    (
      par_policy_id           p_policy.policy_id%TYPE
     ,par_decline_reason_id   t_decline_reason.t_decline_reason_id%TYPE
     ,par_decline_notice_date DATE
     ,par_decline_date        DATE
     ,par_declined_policy_id  OUT p_policy.policy_id%TYPE
    ) IS
    BEGIN
      doc.set_doc_status(p_doc_id => par_policy_id, p_status_brief => 'QUIT_DECL');
    
      par_declined_policy_id := pkg_policy.new_policy_version(par_policy_id            => par_policy_id
                                                             ,par_version_status       => 'DECLINE_CALCULATION' /*������ ����� �����������*/
                                                             ,par_start_date           => vr_policy.start_date
                                                             ,par_notice_date_addendum => par_decline_notice_date);
    
      UPDATE p_policy pp
         SET pp.decline_date      = par_decline_date
            ,pp.decline_reason_id = par_decline_reason_id
       WHERE pp.policy_id = par_declined_policy_id;
    
    END create_new_version;
  
    PROCEDURE create_pol_decline
    (
      par_policy_id          p_policy.policy_id%TYPE
     ,par_declined_policy_id p_policy.policy_id%TYPE
     ,par_product_conds_id   p_policy.t_product_conds_id%TYPE
     ,par_pol_decline_id     OUT p_pol_decline.p_pol_decline_id%TYPE
    ) IS
    BEGIN
    
      dml_p_pol_decline.insert_record(par_p_policy_id        => par_declined_policy_id
                                     ,par_reg_code           => 45
                                     ,par_t_product_conds_id => par_product_conds_id
                                     ,par_act_date           => trunc(SYSDATE)
                                     ,par_medo_cost          => 0
                                     ,par_p_pol_decline_id   => par_pol_decline_id);
    
      -- ����� ������� � ����� ������ ����� ��������� ��� �������� ������� ������
      FOR rec IN (SELECT aa.as_asset_id
                        ,plo.product_line_id
                        ,ROUND(MONTHS_BETWEEN(trunc(pc.end_date) + 1, pc.start_date) / 12, 2) AS cover_period
                    FROM as_asset           aa
                        ,p_cover            pc
                        ,t_prod_line_option plo
                   WHERE aa.p_policy_id = par_policy_id
                     AND aa.as_asset_id = pc.as_asset_id
                     AND pc.t_prod_line_option_id = plo.id)
      LOOP
        dml_p_cover_decline.insert_record(par_p_pol_decline_id  => par_pol_decline_id
                                         ,par_as_asset_id       => rec.as_asset_id
                                         ,par_t_product_line_id => rec.product_line_id
                                         ,par_cover_period      => rec.cover_period);
      END LOOP;
    
    END create_pol_decline;
  
    PROCEDURE regular_decline_calc
    (
      par_old_policy_id       p_policy.policy_id%TYPE
     ,par_new_policy_id       p_policy.policy_id%TYPE
     ,par_decline_reason_id   t_decline_reason.t_decline_reason_id%TYPE
     ,par_decline_notice_date p_pol_decline.decline_notice_date%TYPE
    ) IS
    
      v_commission       NUMBER;
      v_product_conds_id NUMBER;
      v_result           NUMBER(1);
    
      FUNCTION find_product_conds(par_policy_id NUMBER) RETURN NUMBER IS
        v_product_conds_id NUMBER;
      BEGIN
        SELECT pp.t_product_conds_id
          INTO v_product_conds_id
          FROM p_policy pp
         WHERE pp.policy_id = par_policy_id;
      
        RETURN v_product_conds_id;
      EXCEPTION
        WHEN no_data_found THEN
          RETURN v_product_conds_id;
      END find_product_conds;
    
    BEGIN
    
      v_commission       := pkg_decline.check_comiss(par_old_policy_id);
      v_product_conds_id := find_product_conds(par_policy_id => par_old_policy_id);
      v_result           := pkg_decline.policy_cancel(par_new_policy_id
                                                     ,par_decline_reason_id
                                                     ,pkg_decline.check_hkf(par_old_policy_id)
                                                     ,pkg_decline.check_medo(par_old_policy_id)
                                                     ,v_commission
                                                     , /*p_cover_admin*/0 -- ����� ������ �� ��������
                                                     , /*v_region_id*/0
                                                     ,v_product_conds_id);
    
      UPDATE p_pol_decline pd
         SET pd.issuer_return_date  = NULL
            ,pd.decline_notice_date = par_decline_notice_date
       WHERE pd.p_policy_id = par_new_policy_id;
    END regular_decline_calc;
  
    PROCEDURE custom_decline_calc(par_policy_id p_policy.policy_id%TYPE
                                  
                                  ) IS
      v_rvd_percent t_decline_calc_policy.rvd_percent%TYPE;
    
      --���������� % ���
      FUNCTION rvd_procent(par_policy_id p_policy.policy_id%TYPE)
        RETURN t_decline_calc_policy.rvd_percent%TYPE IS
        v_rvd_percent t_decline_calc_policy.rvd_percent%TYPE;
      BEGIN
        SELECT dc.rvd_percent
          INTO v_rvd_percent
          FROM t_decline_calc_policy dc
              ,p_policy              pp
              ,p_pol_header          pph
         WHERE dc.t_decline_reason_id = dml_t_decline_reason.get_id_by_brief('��������� ���������')
           AND pp.t_product_conds_id = dc.t_policyform_product_id
           AND pp.pol_header_id = pph.policy_header_id
           AND pp.policy_id = par_policy_id;
        RETURN v_rvd_percent;
      EXCEPTION
        WHEN no_data_found
             OR too_many_rows THEN
          RETURN NULL;
      END rvd_procent;
    BEGIN
      /*����������� ��� �� ������*/
      v_rvd_percent := rvd_procent(par_policy_id);
      /*
        � �� ������������ ������� ������� ���.
      */
      FOR rec IN (SELECT cover_vchp + CASE
                           WHEN row_number()
                            over(ORDER BY cover_vchp NULLS LAST, p_cover_decline_id) = 1 THEN
                            total_vchp - SUM(cover_vchp) over()
                           ELSE
                            0
                         END AS vchp
                        ,rid
                    FROM (SELECT ROUND((trunc(pp.end_date) + 1 - pp.decline_date) /
                                       (trunc(pp.end_date) + 1 - pp.start_date) * pp.premium
                                      ,2) total_vchp
                                ,ROUND((trunc(pp.end_date) + 1 - pp.decline_date) /
                                       (trunc(pp.end_date) + 1 - pp.start_date) * pp.premium *
                                       ratio_to_report(pc.fee) over()
                                      ,2) cover_vchp
                                ,cd.p_cover_decline_id
                                ,cd.rowid AS rid
                            FROM p_pol_decline      pd
                                ,p_cover_decline    cd
                                ,p_policy           pp
                                ,p_cover            pc
                                ,t_prod_line_option plo
                           WHERE pp.policy_id = par_policy_id
                             AND pp.policy_id = pd.p_policy_id
                             AND pd.p_pol_decline_id = cd.p_pol_decline_id
                             AND cd.as_asset_id = pc.as_asset_id
                             AND cd.t_product_line_id = plo.product_line_id
                             AND pc.t_prod_line_option_id = plo.id))
      LOOP
        UPDATE p_cover_decline cd
           SET cd.return_bonus_part   = rec.vchp
              ,cd.admin_expenses      = ROUND(rec.vchp * nvl(v_rvd_percent, 0) / 100, 2) /*��� �� ������ (������� �� ������� ���� �� ������)*/
              ,cd.redemption_sum      = 0
              ,cd.add_invest_income   = 0
              ,cd.bonus_off_prev      = 0
              ,cd.bonus_off_current   = 0
              ,cd.underpayment_actual = 0
         WHERE cd.rowid = rec.rid;
      END LOOP;
    END custom_decline_calc;
  
    PROCEDURE update_pol_decline
    (
      par_pol_decline_id       p_pol_decline.p_pol_decline_id%TYPE
     ,par_decline_notice_date  p_pol_decline.decline_notice_date%TYPE
     ,par_return_sum_from_bank NUMBER /*����� ������� ������� �� ������ �� ����� �� �����, ��� ������������� �������*/
    ) IS
      v_pol_decline p_pol_decline%ROWTYPE;
      v_hold_amount p_policy.debt_summ%TYPE;
      v_return_sum  p_policy.return_summ%TYPE;
    
      PROCEDURE adjust_return_summ
      (
        par_pol_decline_id       p_pol_decline.p_pol_decline_id%TYPE
       ,par_policy_id            p_policy.policy_id%TYPE
       ,par_return_sum_from_bank NUMBER
      ) IS
      BEGIN
        /*�������������� ��� ������� ����� �� ��������, �� ������� �� ��������*/
        UPDATE p_cover_decline p
           SET p.return_bonus_part = p.return_bonus_part + par_return_sum_from_bank - v_return_sum
         WHERE p.p_cover_decline_id = (SELECT p_cover_decline_id
                                         FROM (SELECT p.p_cover_decline_id
                                                 FROM p_cover_decline p
                                                WHERE p.p_pol_decline_id = par_pol_decline_id
                                                ORDER BY p.p_cover_decline_id)
                                        WHERE rownum < 2);
        UPDATE p_pol_decline p
           SET p.issuer_return_sum = par_return_sum_from_bank
         WHERE p.p_pol_decline_id = par_pol_decline_id;
        /*������������� �������� ����� � ������� �� ����� �� �����*/
        UPDATE p_policy pp
           SET pp.return_summ = par_return_sum_from_bank
         WHERE pp.policy_id = par_policy_id;
      END;
    BEGIN
    
      v_pol_decline := dml_p_pol_decline.get_record(par_pol_decline_id);
    
      v_pol_decline.admin_expenses      := 0;
      v_pol_decline.medo_cost           := 0;
      v_pol_decline.other_pol_sum       := 0;
      v_pol_decline.overpayment         := 0;
      v_pol_decline.decline_notice_date := par_decline_notice_date;
    
      SELECT SUM(pp.premium) * c_rvd_perc
        INTO v_pol_decline.management_expenses
        FROM p_policy pp
       WHERE pp.policy_id = v_pol_decline.p_policy_id;
    
      SELECT greatest(nvl(SUM(cd.return_bonus_part), 0) + nvl(SUM(cd.redemption_sum), 0) +
                      nvl(SUM(cd.add_invest_income), 0) - nvl(SUM(cd.admin_expenses), 0) -
                      nvl(v_pol_decline.other_pol_sum, 0)
                     ,0)
            ,nvl(SUM(cd.underpayment_actual), 0)
        INTO v_pol_decline.issuer_return_sum
            ,v_pol_decline.debt_fee_fact
        FROM p_cover_decline cd
       WHERE cd.p_pol_decline_id = v_pol_decline.p_pol_decline_id;
    
      v_hold_amount := least(nvl(v_pol_decline.debt_fee_fact, 0)
                            ,nvl(v_pol_decline.issuer_return_sum, 0));
    
      -- ����� � �������
      v_return_sum := nvl(v_pol_decline.issuer_return_sum, 0) + nvl(v_pol_decline.overpayment, 0) -
                      v_hold_amount - nvl(v_pol_decline.medo_cost, 0); /*-NVL(v_pol_decline_row.admin_expenses, 0)*/
    
      UPDATE p_policy pp
         SET pp.return_summ = v_return_sum
            ,pp.debt_summ   = v_hold_amount
       WHERE pp.policy_id = v_pol_decline.p_policy_id;
    
      dml_p_pol_decline.update_record(par_record => v_pol_decline);
    
      --������������� ���, ���� �� ������� �������� ����� � ������ �� ����� 22.4.2015 ������ �., �������� �.
      IF abs(par_return_sum_from_bank - v_return_sum) <= 0.03 /*���� ������� �� ����� 3 �������, �� �����������*/
      THEN
        adjust_return_summ(par_pol_decline_id       => v_pol_decline.p_pol_decline_id
                          ,par_policy_id            => v_pol_decline.p_policy_id
                          ,par_return_sum_from_bank => par_return_sum_from_bank);
      END IF;
    
    END update_pol_decline;
  
    FUNCTION get_product_brief(par_pol_header_id p_policy.pol_header_id%TYPE)
      RETURN t_product.brief%TYPE IS
      v_brief t_product.brief%TYPE;
    BEGIN
    
      SELECT p.brief
        INTO v_brief
        FROM p_pol_header ph
            ,t_product    p
       WHERE ph.policy_header_id = par_pol_header_id
         AND ph.product_id = p.product_id;
    
      RETURN v_brief;
    
    END get_product_brief;
  
    PROCEDURE update_register_info
    (
      par_row_id            load_file_rows.load_file_rows_id%TYPE
     ,par_decline_reason    VARCHAR2
     ,par_decision          VARCHAR2
     ,par_comment           VARCHAR2
     ,par_return_summ       NUMBER
     ,par_agent_return_summ NUMBER
     ,par_rko_return_sum    NUMBER
     ,par_product_id        t_product.product_id%TYPE
    ) IS
      v_category_name t_prod_category.name%TYPE;
    BEGIN
    
      v_category_name := nvl(pkg_product_category.get_product_category_name(par_category_type_brief => 'HKB'
                                                                           ,par_product_id          => par_product_id)
                            ,'������� �� ������������');
    
      UPDATE load_file_rows fr
         SET fr.val_23 = par_decline_reason
            ,fr.val_18 = par_decision
            ,fr.val_19 = par_comment
            ,fr.val_20 = par_return_summ
            ,fr.val_21 = par_agent_return_summ
            ,fr.val_22 = par_rko_return_sum
            ,fr.val_24 = SYSDATE
            ,fr.val_25 = USER
            ,fr.val_26 = v_category_name
       WHERE fr.load_file_rows_id = par_row_id;
    END;
  
    /* ��������� ������� � �����������*/
    PROCEDURE set_decision_comment
    (
      par_row_id   load_file_rows.load_file_rows_id%TYPE
     ,par_decision VARCHAR2
     ,par_comment  VARCHAR2
    ) IS
    BEGIN
      assert_deprecated(par_decision NOT IN (c_decision_refusal, c_decision_error)
                       ,'������� �������� �������: ' || par_decision);
    
      UPDATE load_file_rows fr
         SET fr.val_18 = par_decision
            ,fr.val_19 = par_comment
       WHERE fr.load_file_rows_id = par_row_id;
      pkg_load_file_to_table.set_row_status(par_load_file_rows_id => par_row_id
                                           ,par_row_status        => pkg_load_file_to_table.get_loaded
                                           ,par_is_checked        => 1);
    END set_decision_comment;
  
    PROCEDURE get_decline_policy_info
    (
      par_policy_id             p_policy.policy_id%TYPE
     ,par_policy_header_id      p_pol_header.policy_header_id%TYPE
     ,par_ag_contract_header_id ag_contract_header.ag_contract_header_id%TYPE
     ,par_refusal_reason        VARCHAR2
     ,par_repayment_date        DATE
     ,par_client_return_sum     OUT p_pol_decline.issuer_return_sum%TYPE
     ,par_agent_return_sum      OUT NUMBER
     ,par_rko_return_sum        OUT NUMBER
    ) IS
      v_estimated_liabilites estimated_liabilities.trans_sum%TYPE;
      v_bank_support_perc    ag_contract_header.bank_support_perc%TYPE;
      v_rko                  ag_contract_header.rko%TYPE;
      v_premium              estimated_liabilities.trans_sum%TYPE;
      v_days_till_refuse     NUMBER;
      v_days_till_end        NUMBER;
      v_storage              ag_contract_header.storage_ds%TYPE;
    BEGIN
      SELECT pd.issuer_return_sum
        INTO par_client_return_sum
        FROM p_pol_decline pd
       WHERE pd.p_policy_id = par_policy_id;
    
      SELECT nvl(SUM(el.trans_sum * el.sav), 0)
            ,nvl(SUM(el.trans_sum), 0)
        INTO v_estimated_liabilites
            ,v_premium
        FROM estimated_liabilities el
       WHERE el.policy_header_id = par_policy_header_id;
    
      SELECT ch.bank_support_perc
            ,ch.rko
            ,ch.storage_ds
        INTO v_bank_support_perc
            ,v_rko
            ,v_storage
        FROM ag_contract_header ch
       WHERE ch.ag_contract_header_id = par_ag_contract_header_id;
    
      IF par_refusal_reason = '������ ����������'
      THEN
        /* ���� �������� ���� �������� ������������ ������� ����� ������� �����������,
        �� ����� ��������� ������������ �� �������� ����������� �� ���� ������ */
        par_agent_return_sum := ROUND(v_estimated_liabilites, 2);
        par_rko_return_sum   := ROUND(v_premium * v_rko, 2);
      ELSIF par_refusal_reason = '���'
      THEN
        /* ���� �������� ���� �������� ������������ ������� ����� ���ϻ,
        �� ������ �������� ���������� ��������������� �������������� �� ������� */
      
        SELECT pp.end_date - par_repayment_date
              ,pp.end_date - pp.start_date
          INTO v_days_till_refuse
              ,v_days_till_end
          FROM p_policy pp
         WHERE pp.pol_header_id = par_policy_header_id
           AND pp.version_num = 1;
      
        par_agent_return_sum := ROUND((v_estimated_liabilites - nvl(v_storage, 0)) *
                                      (1 - v_bank_support_perc / 100) * v_days_till_refuse /
                                      v_days_till_end
                                     ,2);
        par_rko_return_sum   := 0;
      END IF;
    
    END get_decline_policy_info;
  
    PROCEDURE send_registry(par_load_file_id IN load_file.load_file_id%TYPE) IS
      v_registry_hkf_clob  CLOB;
      v_registry_zrs_clob  CLOB;
      v_files              pkg_email.t_files := pkg_email.t_files();
      v_csv_fields_count   NUMBER;
      v_process_start_date DATE := SYSDATE;
      v_blob_offset        NUMBER := 1;
      v_clob_offset        NUMBER := 1;
      v_warning            NUMBER;
      v_registry_hkf_query VARCHAR2(2000);
      v_registry_zsp_query VARCHAR2(2000);
      v_order_by_clause    VARCHAR2(50);
      v_lang_context       INTEGER := dbms_lob.default_lang_ctx;
      v_row_count          PLS_INTEGER;
    BEGIN
      SELECT COUNT(*)
        INTO v_csv_fields_count
        FROM load_csv_list     cl
            ,load_csv_settings st
       WHERE cl.brief = 'DECLINE_HKB_OLD'
         AND cl.load_csv_list_id = st.load_csv_list_id
       ORDER BY st.num;
    
      v_registry_hkf_query := 'select ';
      FOR v_idx IN 1 .. v_csv_fields_count
      LOOP
        v_registry_hkf_query := v_registry_hkf_query || 'val_' || to_char(v_idx) || ',';
      END LOOP;
      v_registry_hkf_query := rtrim(v_registry_hkf_query, ',') ||
                              ' from load_file_rows where load_file_id = ' ||
                              to_char(par_load_file_id);
      v_order_by_clause    := 'order by load_file_rows_id';
    
      /* ������ ���� �������*/
      v_files := pkg_email.t_files();
      v_files.extend(1);
    
      -- �������� �������� �����
      SELECT nvl(regexp_substr(lf.file_name, '[^\]+\.csv$', 1, 1, 'i'), '���������.csv')
        INTO v_files(1).v_file_name
        FROM load_file lf
       WHERE lf.load_file_id = par_load_file_id;
    
      v_files(1).v_file_type := tt_file.get_mime_type(par_file_name_or_ext => v_files(1).v_file_name);
      dbms_lob.createtemporary(lob_loc => v_files(1).v_file, cache => TRUE);
      dbms_lob.createtemporary(lob_loc => v_registry_hkf_clob, cache => TRUE);
    
      pkg_csv.select_to_csv(par_select        => v_registry_hkf_query || ' ' || v_order_by_clause
                           ,par_header_option => pkg_csv.gc_without_header
                           ,par_csv           => v_registry_hkf_clob);
    
      dbms_lob.converttoblob(src_clob     => v_registry_hkf_clob
                            ,dest_lob     => v_files(1).v_file
                            ,amount       => dbms_lob.lobmaxsize
                            ,dest_offset  => v_blob_offset
                            ,src_offset   => v_clob_offset
                            ,blob_csid    => dbms_lob.default_csid
                            ,lang_context => v_lang_context
                            ,warning      => v_warning);
    
      dbms_lob.freetemporary(lob_loc => v_registry_hkf_clob);
    
      v_blob_offset := 1;
      v_clob_offset := 1;
    
      /* ������ ���� ������� (���) */
      v_registry_zsp_query := 'select val_1
                                     ,trunc(sysdate) as today
                                     ,val_4
                                     ,val_3
                                     ,val_5
                                     ,case
                                        when upper(val_14) = ''���''
                                        then ''��������� ����''
                                        else ''����''
                                       end as bank
                                     ,case
                                        when upper(val_14) = ''���''
                                        then val_15
                                       end as bik
                                     ,case
                                        when upper(val_14) = ''���''
                                        then val_16
                                       end as rs
                                 from load_file_rows where load_file_id = ' ||
                              to_char(par_load_file_id) || ' and val_19 = ''������� �� ������''';
    
      dbms_lob.createtemporary(lob_loc => v_registry_zrs_clob, cache => TRUE);
    
      pkg_csv.select_to_csv(par_select        => v_registry_zsp_query || ' ' || v_order_by_clause
                           ,par_header_option => pkg_csv.gc_header_from_parameter
                           ,par_header        => tt_one_col('� �/�'
                                                           ,'���� ������������ �������'
                                                           ,'����� ��������'
                                                           ,'��� �������'
                                                           ,'���� ���������� ���������'
                                                           ,'����, � ������� ���������� ����������� ��������� ������'
                                                           ,'���'
                                                           ,'�/�')
                           ,par_row_count     => v_row_count
                           ,par_csv           => v_registry_zrs_clob);
      IF v_row_count > 0
      THEN
        v_files.extend(1);
        v_files(2).v_file_name := '���������.csv';
        v_files(2).v_file_type := tt_file.get_mime_type(par_file_name_or_ext => v_files(2).v_file_name);
        dbms_lob.createtemporary(lob_loc => v_files(2).v_file, cache => TRUE);
      
        dbms_lob.converttoblob(src_clob     => v_registry_zrs_clob
                              ,dest_lob     => v_files(2).v_file
                              ,amount       => dbms_lob.lobmaxsize
                              ,dest_offset  => v_blob_offset
                              ,src_offset   => v_clob_offset
                              ,blob_csid    => dbms_lob.default_csid
                              ,lang_context => v_lang_context
                              ,warning      => v_warning);
      
        dbms_lob.freetemporary(lob_loc => v_registry_zrs_clob);
      END IF;
      pkg_email.send_mail_with_attachment(par_to         => c_to
                                         ,par_cc         => c_cc
                                         ,par_subject    => '������ ���_���������_' ||
                                                            to_char(v_process_start_date, 'dd.mm.yyyy')
                                         ,par_text       => '������������ ��������� ������� ����������� ���.'
                                         ,par_attachment => v_files);
      dbms_lob.freetemporary(lob_loc => v_files(1).v_file);
    END send_registry;
  
    /*���������� ���� ��������� �� �����������*/
    PROCEDURE set_pol_decline_notice_date
    (
      par_pol_decline_id      p_pol_decline.p_pol_decline_id%TYPE
     ,par_decline_notice_date p_pol_decline.decline_notice_date%TYPE
    ) IS
    BEGIN
      UPDATE p_pol_decline p
         SET p.decline_notice_date = par_decline_notice_date
       WHERE p.p_pol_decline_id = par_pol_decline_id;
    END set_pol_decline_notice_date;
  BEGIN
    assert_deprecated(par_load_file_id IS NULL, '�� ����� ������ ���� ������!');
    /* ����� ��������� ����� � ����������, ����� ������, �,
       ��������, ��������� ���������� �������� ��� �������� ���������.
       ����� ����� �����, ���� ���������� pkg_load_file_to_table.str_to_array
    */
    DECLARE
      v_first_row_id NUMBER;
    BEGIN
      SELECT MIN(fr.load_file_rows_id)
        INTO v_first_row_id
        FROM load_file_rows fr
       WHERE fr.load_file_id = par_load_file_id;
    
      UPDATE load_file_rows fr
         SET fr.val_1  = NULL
            ,fr.val_2  = fr.val_1
            ,fr.val_3  = fr.val_2
            ,fr.val_4  = fr.val_3
            ,fr.val_5  = fr.val_4
            ,fr.val_6  = fr.val_5
            ,fr.val_7  = fr.val_6
            ,fr.val_8  = fr.val_7
            ,fr.val_9  = fr.val_8
            ,fr.val_10 = fr.val_9
            ,fr.val_11 = fr.val_10
            ,fr.val_12 = fr.val_11
            ,fr.val_13 = fr.val_12
            ,fr.val_14 = fr.val_13
            ,fr.val_15 = fr.val_14
            ,fr.val_16 = fr.val_15
            ,fr.val_17 = fr.val_16
            ,fr.val_18 = fr.val_17
            ,fr.val_19 = fr.val_18
            ,fr.val_20 = fr.val_19
            ,fr.val_21 = fr.val_20
            ,fr.val_22 = fr.val_21
            ,fr.val_23 = fr.val_22
            ,fr.val_24 = fr.val_23
            ,fr.val_25 = fr.val_24
            ,fr.val_26 = fr.val_25
            ,fr.val_27 = fr.val_26
       WHERE fr.load_file_rows_id = v_first_row_id
         AND fr.val_1 IS NOT NULL;
    END;
  
    /* ���� � ���� �������� ������� ������� ��������, �� ������� � ��������� ������ */
    FOR vr_row IN (SELECT fr.load_file_rows_id
                         ,fr.val_4 AS policy_num
                         ,to_date(fr.val_8, 'dd.mm.yyyy') AS repayment_date
                         ,to_date(fr.val_11, 'dd.mm.yyyy') AS decline_notice_date
                         ,fr.val_16 AS account_number
                         ,fr.val_15 AS bik
                         ,to_number(REPLACE(TRIM(fr.val_20), ',', '.')
                                   ,'99999999999999999999999999999D99999999999999999999999999999'
                                   ,'NLS_NUMERIC_CHARACTERS = ''.,''') AS return_sum_from_bank
                     FROM load_file_rows fr
                    WHERE fr.load_file_id = par_load_file_id
                      AND fr.val_18 IS NULL /* ������� ������ ���� ������*/
                      AND fr.row_status = pkg_load_file_to_table.get_checked
                      AND fr.is_checked = 1)
    LOOP
      SAVEPOINT before_process;
      /* ����� ������� ����������� �������� ���� ������ �������� ��������� �� ���������
      ���� ������ �������� �������, � ���λ �������� ������������ ��������� �� ���������
      ����  ���� ������������� ������� */
      BEGIN
        vr_policy := find_policy(par_policy_num => vr_row.policy_num);
      
        -- �������� ���������� ��������
        BEGIN
          SELECT ph.*
            INTO vr_pol_header
            FROM p_pol_header ph
           WHERE ph.policy_header_id = vr_policy.pol_header_id
             FOR UPDATE NOWAIT;
        EXCEPTION
          WHEN pkg_oracle_exceptions.resource_busy_nowait THEN
            RAISE policy_locked;
        END;
        v_policy_status_brief := doc.get_doc_status_brief(doc_id => vr_policy.policy_id);
      
        /* �������������� �������� ���������� ������� ��������� ������ �� */
        vr_decline_reason       := find_pol_decline_reason(par_policy_id => vr_policy.policy_id);
        v_ag_contract_header_id := pkg_agn_control.get_current_policy_agent(par_pol_header_id => vr_policy.pol_header_id);
      
        IF v_policy_status_brief IN ('TO_QUIT'
                                    ,'TO_QUIT_CHECK_READY'
                                    ,'TO_QUIT_CHECKED'
                                    ,'QUIT'
                                    ,'QUIT_REQ_QUERY'
                                    ,'QUIT_REQ_GET'
                                    ,'QUIT_TO_PAY'
                                    ,'DECLINE_CALCULATION')
        THEN
          /* � ����������� �� ������� �����������, ���� �����������
          ����������� ��������� �������� */
          v_decline_policy_id := vr_policy.policy_id;
          IF vr_decline_reason.brief = '�������������������������'
          THEN
            RAISE bank_annulation;
          ELSIF vr_decline_reason.brief = '������� ���� (�������������)'
          THEN
            RAISE court_annulation;
          ELSE
            RAISE other_annulation;
          END IF;
        END IF;
      
        /* ��� ������������ �������� ����������� ����������� ��������
        ������� ��� � ������� "� ������" */
        check_payments_to_pay(par_pol_header_id => vr_policy.pol_header_id);
      
        /* ���� �� �� ���� ������ � ������� �������� �� �������,
        �� ���� "�������" ������� ��������� �������� "�����",
        � ���� ������������ ������� ��������� �������� "�� �������� ������� ������" */
        check_claims(par_pol_header_id => vr_policy.pol_header_id);
      
        /* ����������� �������� ������� �� ���������� �� ������ � ������� �������,
        �������� ���� �� ������� �������� ������ 0 */
        check_closed_claims(par_pol_header_id => vr_policy.pol_header_id);
      
        /* �������������� �������� ��������� ��������� �� ����������� � ������ ����������.*/
        get_cooling_period(par_decline_notice_date => vr_row.decline_notice_date
                          ,par_repayment_date      => vr_row.repayment_date
                          ,par_policy_confirm_date => vr_policy.confirm_date
                          ,par_header_start_date   => vr_pol_header.start_date
                          ,par_decline_reason_id   => v_decline_reason_id
                          ,par_refusal_reason      => v_refusal_reason);
      
        IF v_refusal_reason = '������ ����������'
        THEN
          v_decline_date := vr_policy.confirm_date;
        ELSE
          v_decline_date := vr_row.repayment_date;
        END IF;
      
        create_new_version(par_policy_id           => vr_policy.policy_id
                          ,par_decline_reason_id   => v_decline_reason_id
                          ,par_decline_notice_date => vr_row.decline_notice_date
                          ,par_decline_date        => v_decline_date
                          ,par_declined_policy_id  => v_decline_policy_id);
        -- ������� ������ ������ � �������� �����������   
        create_pol_decline(par_policy_id          => vr_policy.policy_id
                          ,par_declined_policy_id => v_decline_policy_id
                          ,par_product_conds_id   => vr_policy.t_product_conds_id
                          ,par_pol_decline_id     => v_pol_decline_id);
        IF v_refusal_reason = '������ ����������'
        THEN
          /*������ ��� �������������� ��������*/
          /*������ ��� �� ������ "���������� �������" ����� �����������*/
          pkg_policy_decline.calculate_decline(par_policy_id  => v_decline_policy_id /*�������� ������ �����������*/
                                              ,par_result     => v_result
                                              ,par_commentary => v_comment);
          /*���������� ���� ��������� �� ����������� (�� ������ �� ����� ��������), �.�. � ������������� 
          ��������� ������� �� ��������� �� ��������� ������� ��������, � � ������ ������ ��������� ���
          20.4.2015 ������ �.
          */
          set_pol_decline_notice_date(par_pol_decline_id      => v_pol_decline_id
                                     ,par_decline_notice_date => vr_row.decline_notice_date);
        ELSE
          custom_decline_calc(par_policy_id => v_decline_policy_id);
          update_pol_decline(par_pol_decline_id       => v_pol_decline_id
                            ,par_decline_notice_date  => vr_row.decline_notice_date
                            ,par_return_sum_from_bank => vr_row.return_sum_from_bank);
        END IF;
      
        -- ��������� ������������� ���� ����� �����������
        get_decline_policy_info(par_policy_id             => v_decline_policy_id
                               ,par_policy_header_id      => vr_policy.pol_header_id
                               ,par_ag_contract_header_id => v_ag_contract_header_id
                               ,par_refusal_reason        => v_refusal_reason
                               ,par_repayment_date        => vr_row.repayment_date
                               ,par_client_return_sum     => v_client_return_summ
                               ,par_agent_return_sum      => v_agent_return_summ
                               ,par_rko_return_sum        => v_rko_return_sum);
      
        update_register_info(par_row_id            => vr_row.load_file_rows_id
                            ,par_decline_reason    => v_refusal_reason
                            ,par_decision          => c_decision_payback
                            ,par_comment           => NULL
                            ,par_return_summ       => v_client_return_summ
                            ,par_agent_return_summ => v_agent_return_summ
                            ,par_rko_return_sum    => v_rko_return_sum
                            ,par_product_id        => vr_pol_header.product_id);
      
        pkg_load_file_to_table.set_row_status(par_load_file_rows_id => vr_row.load_file_rows_id
                                             ,par_row_status        => pkg_load_file_to_table.get_loaded
                                              /*,par_ure_id => 
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             ,par_uro_id => */);
      EXCEPTION
        WHEN policy_not_found THEN
          ROLLBACK TO before_process;
          v_decision := c_decision_refusal;
          set_decision_comment(par_row_id   => vr_row.load_file_rows_id
                              ,par_decision => c_decision_refusal
                              ,par_comment  => '������� �� ������');
        WHEN bank_annulation THEN
          ROLLBACK TO before_process;
          v_decision := c_decision_refusal;
          set_decision_comment(par_row_id   => vr_row.load_file_rows_id
                              ,par_decision => c_decision_refusal
                              ,par_comment  => '����������� �� ���������� �����');
        WHEN court_annulation THEN
          ROLLBACK TO before_process;
          v_decision := c_decision_refusal;
          set_decision_comment(par_row_id   => vr_row.load_file_rows_id
                              ,par_decision => c_decision_refusal
                              ,par_comment  => '����������� �� ������� ����');
        WHEN other_annulation THEN
          ROLLBACK TO before_process;
          v_decision := c_decision_refusal;
          set_decision_comment(par_row_id   => vr_row.load_file_rows_id
                              ,par_decision => c_decision_refusal
                              ,par_comment  => '������� ����������� ��� ����������/����������� �����');
        WHEN exists_payment_to_pay THEN
          ROLLBACK TO before_process;
          v_decision := c_decision_refusal;
          set_decision_comment(par_row_id   => vr_row.load_file_rows_id
                              ,par_decision => c_decision_refusal
                              ,par_comment  => '������� �� �������');
        WHEN exists_claim THEN
          ROLLBACK TO before_process;
          v_decision := c_decision_refusal;
          set_decision_comment(par_row_id   => vr_row.load_file_rows_id
                              ,par_decision => c_decision_refusal
                              ,par_comment  => '�� �������� ������� ������');
        WHEN exists_closed_claim THEN
          ROLLBACK TO before_process;
          v_decision := c_decision_refusal;
          set_decision_comment(par_row_id   => vr_row.load_file_rows_id
                              ,par_decision => c_decision_refusal
                              ,par_comment  => '�� �������� ����������� ���� ������������ ��������� �������');
        WHEN loan_is_not_repaid THEN
          ROLLBACK TO before_process;
          v_decision := c_decision_refusal;
          set_decision_comment(par_row_id   => vr_row.load_file_rows_id
                              ,par_decision => c_decision_refusal
                              ,par_comment  => '��������� ������ ����� 30 ��, ��� �� ����');
        WHEN too_many_policies THEN
          ROLLBACK TO before_process;
          pkg_load_file_to_table.set_row_status(par_load_file_rows_id => vr_row.load_file_rows_id
                                               ,par_row_status        => pkg_load_file_to_table.get_error
                                               ,par_is_checked        => 0
                                               ,par_row_comment       => '������� ��������� ��������� � ��������� ������� � ��� ������������');
        WHEN policy_locked THEN
          ROLLBACK TO before_process;
          pkg_load_file_to_table.set_row_status(par_load_file_rows_id => vr_row.load_file_rows_id
                                               ,par_row_status        => pkg_load_file_to_table.get_error
                                               ,par_is_checked        => 0
                                               ,par_row_comment       => '������� ������������ ������ �������������');
        WHEN set_status_error THEN
          ROLLBACK TO before_process;
          pkg_load_file_to_table.set_row_status(par_load_file_rows_id => vr_row.load_file_rows_id
                                               ,par_row_status        => pkg_load_file_to_table.get_error
                                               ,par_is_checked        => 0
                                               ,par_row_comment       => dbms_utility.format_error_stack);
      END;
    END LOOP;
  
    -- ���������� ��������� CSV
    SELECT COUNT(*)
      INTO v_errors_exists
      FROM dual
     WHERE EXISTS (SELECT NULL
              FROM load_file_rows fr
             WHERE fr.load_file_id = par_load_file_id
               AND fr.row_status = pkg_load_file_to_table.get_error
               AND regexp_like(fr.val_1, '^\d+$'));
  
    IF v_errors_exists = 0
    THEN
      send_registry(par_load_file_id);
    END IF;
  END group_decline_hkb_old;
  /*
  ����� �������� �������� ��������� �� ����������� �� ����
  ������ �.
  30.10.2014
  */
  PROCEDURE group_decline_hkb(par_load_file_id load_file.load_file_id%TYPE) IS
    policy_not_found      EXCEPTION;
    bank_annulation       EXCEPTION;
    court_annulation      EXCEPTION;
    other_annulation      EXCEPTION;
    too_many_policies     EXCEPTION;
    exists_payment_to_pay EXCEPTION;
    exists_claim          EXCEPTION;
    exists_closed_claim   EXCEPTION;
    loan_is_not_repaid    EXCEPTION;
    set_status_error      EXCEPTION;
    policy_locked         EXCEPTION;
  
    /*������ ������������ �����*/
    TYPE typ_group_decline_hkfb IS RECORD(
       decline_journal_hkfb_id   decline_journal_hkfb.decline_journal_hkfb_id%TYPE
      ,registry_name             decline_journal_hkfb.registry_name%TYPE
      ,recieve_date              decline_journal_hkfb.recieve_date%TYPE
      ,insured_name              decline_journal_hkfb.insured_name%TYPE
      ,policy_number             decline_journal_hkfb.policy_number%TYPE
      ,notice_date               decline_journal_hkfb.notice_date%TYPE
      ,policy_start_date         decline_journal_hkfb.policy_start_date%TYPE
      ,days_of_credit            decline_journal_hkfb.days_of_credit%TYPE
      ,credit_end_date           decline_journal_hkfb.credit_end_date%TYPE
      ,home_phone                decline_journal_hkfb.home_phone%TYPE
      ,cell_phone                decline_journal_hkfb.cell_phone%TYPE
      ,decline_notice_date       decline_journal_hkfb.decline_notice_date%TYPE
      ,payment_generated         decline_journal_hkfb.payment_generated%TYPE
      ,application_place         decline_journal_hkfb.application_place%TYPE
      ,is_hkfb_account           decline_journal_hkfb.is_hkfb_account%TYPE
      ,bank_bik                  decline_journal_hkfb.bank_bik%TYPE
      ,account_number            decline_journal_hkfb.account_number%TYPE
      ,is_credit                 decline_journal_hkfb.is_credit%TYPE
      ,application_reason        decline_journal_hkfb.application_reason%TYPE
      ,bank_return_amount        decline_journal_hkfb.bank_return_amount%TYPE
      ,bank_return_ag_amount     decline_journal_hkfb.bank_return_ag_amount%TYPE
      ,bank_return_rko_amount    decline_journal_hkfb.bank_return_rko_amount%TYPE
      ,decision                  decline_journal_hkfb.decision%TYPE
      ,decline_note              decline_journal_hkfb.decline_note%TYPE
      ,company_return_amount     decline_journal_hkfb.company_return_amount%TYPE
      ,company_return_ag_amount  decline_journal_hkfb.company_return_ag_amount%TYPE
      ,company_return_rko_amount decline_journal_hkfb.company_return_rko_amount%TYPE
      ,registration_date         decline_journal_hkfb.registration_date%TYPE
      ,responsible               decline_journal_hkfb.responsible%TYPE
      ,product_name              decline_journal_hkfb.product_name%TYPE
      ,bank_notice               decline_journal_hkfb.bank_notice%TYPE);
    --������ ������������ ����� 
    vr_load_row typ_group_decline_hkfb;
    v_result    p_decline_pack_detail.result%TYPE; --��� ��������� �������� �������� ������� ������� �����������
    v_comment   p_decline_pack_detail.commentary%TYPE;
  
    c_to pkg_email.t_recipients;
    c_cc pkg_email.t_recipients;
  
    vr_policy               p_policy%ROWTYPE;
    vr_pol_header           p_pol_header%ROWTYPE;
    v_policy_status_brief   doc_status_ref.brief%TYPE;
    v_ag_contract_header_id ag_contract_header.ag_contract_header_id%TYPE;
    v_decline_reason_id     t_decline_reason.t_decline_reason_id%TYPE;
    vr_decline_reason       t_decline_reason%ROWTYPE;
    v_decline_policy_id     p_policy.policy_id%TYPE;
    v_refusal_reason        VARCHAR2(20);
    v_decline_date          DATE;
    v_pol_decline_id        p_pol_decline.p_pol_decline_id%TYPE;
    v_client_return_summ    p_policy.return_summ%TYPE;
    v_rko_return_sum        NUMBER;
    v_agent_return_summ     NUMBER;
    v_decision              VARCHAR2(10);
    v_errors_exists         NUMBER(1);
  
    /*������ ��������� �����*/
    CURSOR cur_file IS
      SELECT fr.load_file_rows_id
            ,fr.val_4 AS policy_num
            ,to_date(fr.val_8, 'dd.mm.yyyy') + 1 AS repayment_date -- ������ 380073
            ,to_date(fr.val_11, 'dd.mm.yyyy') AS decline_notice_date
            ,fr.val_16 AS account_number
            ,fr.val_15 AS bik
            ,to_number(REPLACE(TRIM(fr.val_19), ',', '.')
                      ,'99999999999999999999999999999D99999999999999999999999999999'
                      ,'NLS_NUMERIC_CHARACTERS = ''.,''') AS return_sum_from_bank
            ,fr.row_comment
        FROM load_file_rows fr
       WHERE fr.load_file_id = par_load_file_id
         AND fr.val_22 IS NULL /* ������� ������ ���� ������*/
         AND fr.row_status = pkg_load_file_to_table.get_checked
         AND fr.is_checked = 1;
  
    c_decision_refusal           CONSTANT VARCHAR2(30) := '�����';
    c_decision_error             CONSTANT VARCHAR2(30) := '������';
    c_decision_payback           CONSTANT VARCHAR2(30) := '�������';
    c_rvd_perc                   CONSTANT NUMBER := 0.23;
    c_application_place_company  CONSTANT VARCHAR2(30) := '��'; --����� ������ ��������� - ��������� ��������
    c_application_reason_pdp     CONSTANT VARCHAR2(50) := '���'; --������� ��������� "���"
    c_application_reason_cooling CONSTANT VARCHAR2(50) := '������ ����������'; --������� ��������� "������ ����������"
  
    FUNCTION convert_to_number(par_value VARCHAR2) RETURN NUMBER IS
      v_value NUMBER;
    BEGIN
      v_value := to_number(REPLACE(TRIM(par_value), ',', '.')
                          ,'99999999999999999999999999999D99999999999999999999999999999'
                          ,'NLS_NUMERIC_CHARACTERS = ''.,''');
    
      RETURN v_value;
    END convert_to_number;
    -- ������� ���������� �������� ����������� ������, ����������� �� ������
    FUNCTION get_row_values RETURN typ_group_decline_hkfb IS
      vr_load_row typ_group_decline_hkfb;
    BEGIN
      vr_load_row.recieve_date              := pkg_load_file_to_table.get_value_by_brief('RECIEVE_DATE');
      vr_load_row.insured_name              := pkg_load_file_to_table.get_value_by_brief('INSURED_NAME');
      vr_load_row.policy_number             := pkg_load_file_to_table.get_value_by_brief('POLICY_NUMBER'); --����� ��������
      vr_load_row.notice_date               := pkg_load_file_to_table.get_value_by_brief('NOTICE_DATE');
      vr_load_row.policy_start_date         := pkg_load_file_to_table.get_value_by_brief('POLICY_START_DATE');
      vr_load_row.days_of_credit            := pkg_load_file_to_table.get_value_by_brief('DAYS_OF_CREDIT');
      vr_load_row.credit_end_date           := pkg_load_file_to_table.get_value_by_brief('CREDIT_END_DATE');
      vr_load_row.home_phone                := pkg_load_file_to_table.get_value_by_brief('HOME_PHONE');
      vr_load_row.cell_phone                := pkg_load_file_to_table.get_value_by_brief('CELL_PHONE');
      vr_load_row.decline_notice_date       := pkg_load_file_to_table.get_value_by_brief('DECLINE_NOTICE_DATE'); --���� ������ ���������
      vr_load_row.payment_generated         := pkg_load_file_to_table.get_value_by_brief('PAYMENT_GENERATED');
      vr_load_row.application_place         := pkg_load_file_to_table.get_value_by_brief('APPLICATION_PLACE');
      vr_load_row.is_hkfb_account           := pkg_load_file_to_table.get_value_by_brief('IS_HKFB_ACCOUNT');
      vr_load_row.bank_bik                  := pkg_load_file_to_table.get_value_by_brief('BANK_BIK');
      vr_load_row.account_number            := pkg_load_file_to_table.get_value_by_brief('ACCOUNT_NUMBER');
      vr_load_row.is_credit                 := pkg_load_file_to_table.get_value_by_brief('IS_CREDIT');
      vr_load_row.application_reason        := pkg_load_file_to_table.get_value_by_brief('APPLICATION_REASON');
      vr_load_row.bank_return_amount        := convert_to_number(pkg_load_file_to_table.get_value_by_brief('BANK_RETURN_AMOUNT'));
      vr_load_row.bank_return_ag_amount     := convert_to_number(pkg_load_file_to_table.get_value_by_brief('BANK_RETURN_AG_AMOUNT'));
      vr_load_row.bank_return_rko_amount    := convert_to_number(pkg_load_file_to_table.get_value_by_brief('BANK_RETURN_RKO_AMOUNT'));
      vr_load_row.decision                  := pkg_load_file_to_table.get_value_by_brief('DECISION');
      vr_load_row.decline_note              := pkg_load_file_to_table.get_value_by_brief('DECLINE_NOTE');
      vr_load_row.company_return_amount     := convert_to_number(pkg_load_file_to_table.get_value_by_brief('COMPANY_RETURN_AMOUNT'));
      vr_load_row.company_return_ag_amount  := convert_to_number(pkg_load_file_to_table.get_value_by_brief('COMPANY_RETURN_AG_AMOUNT'));
      vr_load_row.company_return_rko_amount := convert_to_number(pkg_load_file_to_table.get_value_by_brief('COMPANY_RETURN_RKO_AMOUNT'));
      vr_load_row.registration_date         := pkg_load_file_to_table.get_value_by_brief('REGISTRATION_DATE');
      vr_load_row.responsible               := pkg_load_file_to_table.get_value_by_brief('RESPONSIBLE');
      vr_load_row.product_name              := pkg_load_file_to_table.get_value_by_brief('PRODUCT_NAME');
      vr_load_row.bank_notice               := pkg_load_file_to_table.get_value_by_brief('BANK_NOTICE');
      vr_load_row.bank_notice               := pkg_load_file_to_table.get_value_by_brief('STATUS');
    
      RETURN vr_load_row;
    END get_row_values;
  
    /* ����� �� �� ������ � ��� ������������ */
    FUNCTION find_policy(par_policy_num p_policy.pol_num%TYPE) RETURN p_policy%ROWTYPE IS
      vr_result_policy p_policy%ROWTYPE;
    BEGIN
      SELECT pp.*
        INTO vr_result_policy
        FROM p_pol_header ph
            ,p_policy     pp
       WHERE ph.max_uncancelled_policy_id = pp.policy_id
         AND pp.pol_num = par_policy_num
         AND EXISTS (SELECT NULL
                FROM document       dc
                    ,doc_status_ref dsr
               WHERE dc.document_id = ph.policy_id
                 AND dc.doc_status_ref_id = dsr.doc_status_ref_id
                 AND dsr.brief != 'CANCEL');
      RETURN vr_result_policy;
    EXCEPTION
      WHEN no_data_found THEN
        RAISE policy_not_found;
      WHEN too_many_rows THEN
        RAISE too_many_policies;
    END find_policy;
  
    /*�������� ��� �����*/
    FUNCTION get_file_name RETURN VARCHAR2 IS
      v_file_name load_file.file_name%TYPE;
    BEGIN
      -- �������� �������� �����
      SELECT nvl(regexp_substr(lf.file_name, '[^\]+\.csv$', 1, 1, 'i'), '���������.csv')
        INTO v_file_name
        FROM load_file lf
       WHERE lf.load_file_id = par_load_file_id;
      RETURN v_file_name;
    END get_file_name;
  
    /* ��������� ������� ����������� ������ */
    FUNCTION find_pol_decline_reason(par_policy_id p_policy.policy_id%TYPE)
      RETURN t_decline_reason%ROWTYPE IS
      v_decline_reason_id t_decline_reason.t_decline_reason_id%TYPE;
      v_decline_reason    t_decline_reason%ROWTYPE;
    BEGIN
      SELECT dr.t_decline_reason_id
        INTO v_decline_reason_id
        FROM p_policy         pp
            ,t_decline_reason dr
       WHERE pp.policy_id = par_policy_id
         AND pp.decline_reason_id = dr.t_decline_reason_id;
    
      v_decline_reason := dml_t_decline_reason.get_record(v_decline_reason_id);
    
      RETURN v_decline_reason;
    
    EXCEPTION
      WHEN no_data_found THEN
        RETURN v_decline_reason;
    END find_pol_decline_reason;
  
    PROCEDURE check_payments_to_pay(par_pol_header_id p_pol_header.policy_header_id%TYPE) IS
      v_exists_to_pay NUMBER(1);
    BEGIN
      SELECT COUNT(1)
        INTO v_exists_to_pay
        FROM dual
       WHERE EXISTS (SELECT NULL
                FROM p_policy       pp
                    ,doc_doc        dd
                    ,document       dc
                    ,doc_templ      dt
                    ,doc_status_ref dsr
               WHERE pp.pol_header_id = par_pol_header_id
                 AND pp.policy_id = dd.parent_id
                 AND dd.child_id = dc.document_id
                 AND dc.doc_templ_id = dt.doc_templ_id
                 AND dt.brief = 'PAYMENT'
                 AND dc.doc_status_ref_id = dsr.doc_status_ref_id
                 AND dsr.brief = 'TO_PAY');
      IF v_exists_to_pay = 1
      THEN
        RAISE exists_payment_to_pay;
      END IF;
    END check_payments_to_pay;
  
    PROCEDURE check_claims(par_pol_header_id p_pol_header.policy_header_id%TYPE) IS
      v_exists_claim NUMBER(1);
    BEGIN
      SELECT COUNT(1)
        INTO v_exists_claim
        FROM dual
       WHERE EXISTS (SELECT NULL
                FROM p_policy       pp
                    ,c_claim_header ch
                    ,c_claim        cl
                    ,document       dc
                    ,doc_status_ref dsr
               WHERE pp.pol_header_id = par_pol_header_id
                 AND pp.policy_id = ch.p_policy_id
                 AND ch.active_claim_id = cl.c_claim_id
                 AND cl.c_claim_id = dc.document_id
                 AND dc.doc_status_ref_id = dsr.doc_status_ref_id
                 AND dsr.brief != 'CLOSE');
      IF v_exists_claim = 1
      THEN
        RAISE exists_claim;
      END IF;
    END check_claims;
  
    PROCEDURE check_closed_claims(par_pol_header_id p_pol_header.policy_header_id%TYPE) IS
      v_exists_closed_claim NUMBER(1);
    BEGIN
      SELECT COUNT(1)
        INTO v_exists_closed_claim
        FROM dual
       WHERE EXISTS (SELECT NULL
                FROM p_policy       pp
                    ,c_claim_header ch
                    ,c_claim        cl
                    ,document       dc
                    ,doc_status_ref dsr
                    ,c_damage       cd
               WHERE pp.pol_header_id = par_pol_header_id
                 AND pp.policy_id = ch.p_policy_id
                 AND ch.active_claim_id = cl.c_claim_id
                 AND cl.c_claim_id = dc.document_id
                 AND dc.doc_status_ref_id = dsr.doc_status_ref_id
                 AND dsr.brief = 'CLOSE'
                 AND cl.c_claim_id = cd.c_claim_id
                 AND cd.payment_sum > 0);
      IF v_exists_closed_claim = 1
      THEN
        RAISE exists_closed_claim;
      END IF;
    END check_closed_claims;
  
    PROCEDURE get_cooling_period
    (
      par_decline_notice_date DATE
     ,par_repayment_date      DATE
     ,par_policy_confirm_date p_policy.confirm_date%TYPE
      --,par_header_start_date   p_pol_header.start_date%TYPE --414948
     ,par_pol_notice_date   p_policy.notice_date%TYPE
     ,par_decline_reason_id   OUT t_decline_reason.t_decline_reason_id%TYPE
     ,par_refusal_reason      OUT VARCHAR2
    ) IS
    BEGIN
      /* �������������� �������� ��������� ��������� �� ����������� � ������ ����������.
      ������� ����� ��������� ���� ����� ��������� �� ������������ �������
      � ��������� ���� ����� ���������� � ���� ������� ����������� �����
      �������� ������������*/
      IF par_decline_notice_date - par_policy_confirm_date + 1 /* ����� �.: ���������� ���� ��� ������������� �� ������ 385527*/
         > --pkg_policy.define_cooling_period_length(par_header_start_date) par_pol_notice_date --414948
         pkg_policy.define_cooling_period_length(par_pol_notice_date)
      THEN
        /* ������ 30 ����, �.�. ��������� �� ������� �� �������� � ������ ����������.
        � ���� ������ ����������� ���������� ���� ����� ��������� ������� � ������� */
        IF par_repayment_date IS NULL
        THEN
          /* ���� �������� ���� ����� ��������� ������� ������� ������,
          �� ���� �������� ������� ��������� �������� ������,
          ���� ������������ ������� ��������� ��������
          ����� ������ ��������� ��������� 30 ���� � ���� ����������,
          ������ �� �������, ���������� ��������� ������ ������� ��� ���������.*/
          RAISE loan_is_not_repaid;
        ELSE
          /* ���� �������� ���� ����� ��������� ������� �� ������, �� ���������
          ������ ����������� � ��������� �������� ������������ ������
          ���������� ���������, ���� �������� ������ �������
          ��������� �������� ���ϻ */
          par_decline_reason_id := pkg_t_decline_reason_dml.get_id_by_brief('��������� ���������');
          par_refusal_reason    := '���';
        END IF;
      ELSE
        /* ������ 30 ����, �� ��������� �������� � ������ ����������.
        � ������ ������ �������� ������ ����������� � ��������� �������� ������������
        ������ 225 � ������ ������������ �� ��������,
        � ���� �������� ������ ������� ��������� �������� ������� �����������.*/
        par_decline_reason_id := pkg_t_decline_reason_dml.get_id_by_brief('����� ������������ �� ��������');
        par_refusal_reason    := '������ ����������';
      END IF;
    END get_cooling_period;
  
    PROCEDURE create_new_version
    (
      par_policy_id           p_policy.policy_id%TYPE
     ,par_decline_reason_id   t_decline_reason.t_decline_reason_id%TYPE
     ,par_decline_notice_date DATE
     ,par_decline_date        DATE
     ,par_declined_policy_id  OUT p_policy.policy_id%TYPE
    ) IS
    BEGIN
      doc.set_doc_status(p_doc_id => par_policy_id, p_status_brief => 'QUIT_DECL');
    
      par_declined_policy_id := pkg_policy.new_policy_version(par_policy_id            => par_policy_id
                                                             ,par_version_status       => 'DECLINE_CALCULATION' /*������ ����� �����������*/
                                                             ,par_start_date           => vr_policy.start_date
                                                             ,par_notice_date_addendum => par_decline_notice_date);
    
      UPDATE p_policy pp
         SET pp.decline_date      = par_decline_date
            ,pp.decline_reason_id = par_decline_reason_id
       WHERE pp.policy_id = par_declined_policy_id;
    
    END create_new_version;
  
    PROCEDURE create_pol_decline
    (
      par_policy_id          p_policy.policy_id%TYPE
     ,par_declined_policy_id p_policy.policy_id%TYPE
     ,par_product_conds_id   p_policy.t_product_conds_id%TYPE
     ,par_pol_decline_id     OUT p_pol_decline.p_pol_decline_id%TYPE
    ) IS
    BEGIN
    
      dml_p_pol_decline.insert_record(par_p_policy_id        => par_declined_policy_id
                                     ,par_reg_code           => 45
                                     ,par_t_product_conds_id => par_product_conds_id
                                     ,par_act_date           => trunc(SYSDATE)
                                     ,par_medo_cost          => 0
                                     ,par_p_pol_decline_id   => par_pol_decline_id);
    
      -- ����� ������� � ����� ������ ����� ��������� ��� �������� ������� ������
      FOR rec IN (SELECT aa.as_asset_id
                        ,plo.product_line_id
                        ,ROUND(MONTHS_BETWEEN(trunc(pc.end_date) + 1, pc.start_date) / 12, 2) AS cover_period
                    FROM as_asset           aa
                        ,p_cover            pc
                        ,t_prod_line_option plo
                   WHERE aa.p_policy_id = par_policy_id
                     AND aa.as_asset_id = pc.as_asset_id
                     AND pc.t_prod_line_option_id = plo.id)
      LOOP
        dml_p_cover_decline.insert_record(par_p_pol_decline_id  => par_pol_decline_id
                                         ,par_as_asset_id       => rec.as_asset_id
                                         ,par_t_product_line_id => rec.product_line_id
                                         ,par_cover_period      => rec.cover_period);
      END LOOP;
    
    END create_pol_decline;
  
    PROCEDURE regular_decline_calc
    (
      par_old_policy_id       p_policy.policy_id%TYPE
     ,par_new_policy_id       p_policy.policy_id%TYPE
     ,par_decline_reason_id   t_decline_reason.t_decline_reason_id%TYPE
     ,par_decline_notice_date p_pol_decline.decline_notice_date%TYPE
    ) IS
    
      v_commission       NUMBER;
      v_product_conds_id NUMBER;
      v_result           NUMBER(1);
    
      FUNCTION find_product_conds(par_policy_id NUMBER) RETURN NUMBER IS
        v_product_conds_id NUMBER;
      BEGIN
        SELECT pp.t_product_conds_id
          INTO v_product_conds_id
          FROM p_policy pp
         WHERE pp.policy_id = par_policy_id;
      
        RETURN v_product_conds_id;
      EXCEPTION
        WHEN no_data_found THEN
          RETURN v_product_conds_id;
      END find_product_conds;
    
    BEGIN
    
      v_commission       := pkg_decline.check_comiss(par_old_policy_id);
      v_product_conds_id := find_product_conds(par_policy_id => par_old_policy_id);
      v_result           := pkg_decline.policy_cancel(par_new_policy_id
                                                     ,par_decline_reason_id
                                                     ,pkg_decline.check_hkf(par_old_policy_id)
                                                     ,pkg_decline.check_medo(par_old_policy_id)
                                                     ,v_commission
                                                     , /*p_cover_admin*/0 -- ����� ������ �� ��������
                                                     , /*v_region_id*/0
                                                     ,v_product_conds_id);
    
      UPDATE p_pol_decline pd
         SET pd.issuer_return_date  = NULL
            ,pd.decline_notice_date = par_decline_notice_date
       WHERE pd.p_policy_id = par_new_policy_id;
    END regular_decline_calc;
  
    PROCEDURE custom_decline_calc(par_policy_id p_policy.policy_id%TYPE
                                  
                                  ) IS
      v_rvd_percent t_decline_calc_policy.rvd_percent%TYPE;
    
      --���������� % ���
      FUNCTION rvd_procent(par_policy_id p_policy.policy_id%TYPE)
        RETURN t_decline_calc_policy.rvd_percent%TYPE IS
        v_rvd_percent t_decline_calc_policy.rvd_percent%TYPE;
      BEGIN
        SELECT dc.rvd_percent
          INTO v_rvd_percent
          FROM t_decline_calc_policy dc
              ,p_policy              pp
              ,p_pol_header          pph
         WHERE dc.t_decline_reason_id = dml_t_decline_reason.get_id_by_brief('��������� ���������')
           AND pp.t_product_conds_id = dc.t_policyform_product_id
           AND pp.pol_header_id = pph.policy_header_id
           AND pp.policy_id = par_policy_id;
        RETURN v_rvd_percent;
      EXCEPTION
        WHEN no_data_found
             OR too_many_rows THEN
          RETURN NULL;
      END rvd_procent;
    BEGIN
      /*����������� ��� �� ������*/
      v_rvd_percent := rvd_procent(par_policy_id);
      /*
        � �� ������������ ������� ������� ���.
      */
      FOR rec IN (SELECT cover_vchp + CASE
                           WHEN row_number()
                            over(ORDER BY cover_vchp NULLS LAST, p_cover_decline_id) = 1 THEN
                            total_vchp - SUM(cover_vchp) over()
                           ELSE
                            0
                         END AS vchp
                        ,rid
                    FROM (SELECT ROUND((trunc(pp.end_date) + 1 - pp.decline_date) /
                                       (trunc(pp.end_date) + 1 - pp.start_date) * pp.premium
                                      ,2) total_vchp
                                ,ROUND((trunc(pp.end_date) + 1 - pp.decline_date) /
                                       (trunc(pp.end_date) + 1 - pp.start_date) * pp.premium *
                                       ratio_to_report(pc.fee) over()
                                      ,2) cover_vchp
                                ,cd.p_cover_decline_id
                                ,cd.rowid AS rid
                            FROM p_pol_decline      pd
                                ,p_cover_decline    cd
                                ,p_policy           pp
                                ,p_cover            pc
                                ,t_prod_line_option plo
                           WHERE pp.policy_id = par_policy_id
                             AND pp.policy_id = pd.p_policy_id
                             AND pd.p_pol_decline_id = cd.p_pol_decline_id
                             AND cd.as_asset_id = pc.as_asset_id
                             AND cd.t_product_line_id = plo.product_line_id
                             AND pc.t_prod_line_option_id = plo.id))
      LOOP
        UPDATE p_cover_decline cd
           SET cd.return_bonus_part   = rec.vchp
              ,cd.admin_expenses      = ROUND(rec.vchp * nvl(v_rvd_percent, 0) / 100, 2) /*��� �� ������ (������� �� ������� ���� �� ������)*/
              ,cd.redemption_sum      = 0
              ,cd.add_invest_income   = 0
              ,cd.bonus_off_prev      = 0
              ,cd.bonus_off_current   = 0
              ,cd.underpayment_actual = 0
         WHERE cd.rowid = rec.rid;
      END LOOP;
    END custom_decline_calc;
  
    PROCEDURE update_pol_decline
    (
      par_pol_decline_id       p_pol_decline.p_pol_decline_id%TYPE
     ,par_decline_notice_date  p_pol_decline.decline_notice_date%TYPE
     ,par_return_sum_from_bank NUMBER /*����� ������� ������� �� ������ �� ����� �� �����, ��� ������������� �������*/
    ) IS
      v_pol_decline p_pol_decline%ROWTYPE;
      v_hold_amount p_policy.debt_summ%TYPE;
      v_return_sum  p_policy.return_summ%TYPE;
    
      PROCEDURE adjust_return_summ
      (
        par_pol_decline_id       p_pol_decline.p_pol_decline_id%TYPE
       ,par_policy_id            p_policy.policy_id%TYPE
       ,par_return_sum_from_bank NUMBER
      ) IS
      BEGIN
        /*�������������� ��� ������� ����� �� ��������, �� ������� �� ��������*/
        UPDATE p_cover_decline p
           SET p.return_bonus_part = p.return_bonus_part + par_return_sum_from_bank - v_return_sum
         WHERE p.p_cover_decline_id = (SELECT p_cover_decline_id
                                         FROM (SELECT p.p_cover_decline_id
                                                 FROM p_cover_decline p
                                                WHERE p.p_pol_decline_id = par_pol_decline_id
                                                ORDER BY p.p_cover_decline_id)
                                        WHERE rownum < 2);
        UPDATE p_pol_decline p
           SET p.issuer_return_sum = par_return_sum_from_bank
         WHERE p.p_pol_decline_id = par_pol_decline_id;
        /*������������� �������� ����� � ������� �� ����� �� �����*/
        UPDATE p_policy pp
           SET pp.return_summ = par_return_sum_from_bank
         WHERE pp.policy_id = par_policy_id;
      END;
    BEGIN
    
      v_pol_decline := dml_p_pol_decline.get_record(par_pol_decline_id);
    
      v_pol_decline.admin_expenses      := 0;
      v_pol_decline.medo_cost           := 0;
      v_pol_decline.other_pol_sum       := 0;
      v_pol_decline.overpayment         := 0;
      v_pol_decline.decline_notice_date := par_decline_notice_date;
    
      SELECT SUM(pp.premium) * c_rvd_perc
        INTO v_pol_decline.management_expenses
        FROM p_policy pp
       WHERE pp.policy_id = v_pol_decline.p_policy_id;
    
      SELECT greatest(nvl(SUM(cd.return_bonus_part), 0) + nvl(SUM(cd.redemption_sum), 0) +
                      nvl(SUM(cd.add_invest_income), 0) - nvl(SUM(cd.admin_expenses), 0) -
                      nvl(v_pol_decline.other_pol_sum, 0)
                     ,0)
            ,nvl(SUM(cd.underpayment_actual), 0)
        INTO v_pol_decline.issuer_return_sum
            ,v_pol_decline.debt_fee_fact
        FROM p_cover_decline cd
       WHERE cd.p_pol_decline_id = v_pol_decline.p_pol_decline_id;
    
      v_hold_amount := least(nvl(v_pol_decline.debt_fee_fact, 0)
                            ,nvl(v_pol_decline.issuer_return_sum, 0));
    
      -- ����� � �������
      v_return_sum := nvl(v_pol_decline.issuer_return_sum, 0) + nvl(v_pol_decline.overpayment, 0) -
                      v_hold_amount - nvl(v_pol_decline.medo_cost, 0); /*-NVL(v_pol_decline_row.admin_expenses, 0)*/
    
      UPDATE p_policy pp
         SET pp.return_summ = v_return_sum
            ,pp.debt_summ   = v_hold_amount
       WHERE pp.policy_id = v_pol_decline.p_policy_id;
    
      dml_p_pol_decline.update_record(par_record => v_pol_decline);
    
      --������������� ���, ���� �� ������� �������� ����� � ������ �� ����� 22.4.2015 ������ �., �������� �.
      IF abs(par_return_sum_from_bank - v_return_sum) <= 0.03 /*���� ������� �� ����� 3 �������, �� �����������*/
      THEN
        adjust_return_summ(par_pol_decline_id       => v_pol_decline.p_pol_decline_id
                          ,par_policy_id            => v_pol_decline.p_policy_id
                          ,par_return_sum_from_bank => par_return_sum_from_bank);
      END IF;
    
    END update_pol_decline;
  
    FUNCTION get_product_brief(par_pol_header_id p_policy.pol_header_id%TYPE)
      RETURN t_product.brief%TYPE IS
      v_brief t_product.brief%TYPE;
    BEGIN
    
      SELECT p.brief
        INTO v_brief
        FROM p_pol_header ph
            ,t_product    p
       WHERE ph.policy_header_id = par_pol_header_id
         AND ph.product_id = p.product_id;
    
      RETURN v_brief;
    
    END get_product_brief;
  
    PROCEDURE update_register_info
    (
      par_row_id            load_file_rows.load_file_rows_id%TYPE
     ,par_decline_reason    VARCHAR2
     ,par_decision          VARCHAR2
     ,par_comment           VARCHAR2
     ,par_return_summ       NUMBER
     ,par_agent_return_summ NUMBER
     ,par_rko_return_sum    NUMBER
     ,par_product_id        t_product.product_id%TYPE
    ) IS
      v_category_name t_prod_category.name%TYPE;
    BEGIN
    
      v_category_name := nvl(pkg_product_category.get_product_category_name(par_category_type_brief => 'HKB'
                                                                           ,par_product_id          => par_product_id)
                            ,'������� �� ������������');
    
      UPDATE load_file_rows fr
         SET fr.val_18 = par_decline_reason
            ,fr.val_22 = par_decision
            ,fr.val_23 = par_comment
            ,fr.val_24 = to_char(par_return_summ
                                ,'FM999999999999999999999990D0099999999999999999999999999999'
                                ,'NLS_NUMERIC_CHARACTERS = ''. ''')
            ,fr.val_25 = to_char(par_agent_return_summ
                                ,'FM999999999999999999999990D0099999999999999999999999999999'
                                ,'NLS_NUMERIC_CHARACTERS = ''. ''')
            ,fr.val_26 = to_char(par_rko_return_sum
                                ,'FM999999999999999999999990D0099999999999999999999999999999'
                                ,'NLS_NUMERIC_CHARACTERS = ''. ''')
            ,fr.val_27 = SYSDATE
            ,fr.val_28 = USER
            ,fr.val_29 = v_category_name
       WHERE fr.load_file_rows_id = par_row_id;
    END;
  
    /* ��������� ������� � �����������*/
    PROCEDURE set_decision_comment
    (
      par_row_id   load_file_rows.load_file_rows_id%TYPE
     ,par_decision VARCHAR2
     ,par_comment  VARCHAR2
    ) IS
    BEGIN
      assert_deprecated(par_decision NOT IN (c_decision_refusal, c_decision_error)
                       ,'������� �������� �������: ' || par_decision);
    
      UPDATE load_file_rows fr
         SET fr.val_22 = par_decision
            ,fr.val_23 = par_comment
       WHERE fr.load_file_rows_id = par_row_id;
      pkg_load_file_to_table.set_row_status(par_load_file_rows_id => par_row_id
                                           ,par_row_status        => pkg_load_file_to_table.get_loaded
                                           ,par_is_checked        => 1);
    END set_decision_comment;
  
    PROCEDURE get_decline_policy_info
    (
      par_policy_id             p_policy.policy_id%TYPE
     ,par_policy_header_id      p_pol_header.policy_header_id%TYPE
     ,par_ag_contract_header_id ag_contract_header.ag_contract_header_id%TYPE
     ,par_refusal_reason        VARCHAR2
     ,par_repayment_date        DATE
     ,par_client_return_sum     OUT p_pol_decline.issuer_return_sum%TYPE
     ,par_agent_return_sum      OUT NUMBER
     ,par_rko_return_sum        OUT NUMBER
    ) IS
      v_estimated_liabilites estimated_liabilities.trans_sum%TYPE;
      v_bank_support_perc    ag_contract_header.bank_support_perc%TYPE;
      v_rko                  ag_contract_header.rko%TYPE;
      v_premium              estimated_liabilities.trans_sum%TYPE;
      v_days_till_refuse     NUMBER;
      v_days_till_end        NUMBER;
      v_storage              ag_contract_header.storage_ds%TYPE;
    BEGIN
      SELECT pd.issuer_return_sum
        INTO par_client_return_sum
        FROM p_pol_decline pd
       WHERE pd.p_policy_id = par_policy_id;
    
      SELECT nvl(SUM(el.trans_sum * el.sav), 0)
            ,nvl(SUM(el.trans_sum), 0)
        INTO v_estimated_liabilites
            ,v_premium
        FROM estimated_liabilities el
       WHERE el.policy_header_id = par_policy_header_id;
    
      SELECT ch.bank_support_perc
            ,ch.rko
            ,ch.storage_ds
        INTO v_bank_support_perc
            ,v_rko
            ,v_storage
        FROM ag_contract_header ch
       WHERE ch.ag_contract_header_id = par_ag_contract_header_id;
    
      IF par_refusal_reason = '������ ����������'
      THEN
        /* ���� �������� ���� �������� ������������ ������� ����� ������� �����������,
        �� ����� ��������� ������������ �� �������� ����������� �� ���� ������ */
        par_agent_return_sum := ROUND(v_estimated_liabilites, 2);
        par_rko_return_sum   := ROUND(v_premium * v_rko, 2);
      ELSIF par_refusal_reason = '���'
      THEN
        /* ���� �������� ���� �������� ������������ ������� ����� ���ϻ,
        �� ������ �������� ���������� ��������������� �������������� �� ������� */
      
        SELECT ROUND(pp.end_date - par_repayment_date)
              ,ROUND(pp.end_date - pp.start_date)
          INTO v_days_till_refuse
              ,v_days_till_end
          FROM p_policy pp
         WHERE pp.pol_header_id = par_policy_header_id
           AND pp.version_num = 1;
      
        par_agent_return_sum := ROUND((ROUND(v_estimated_liabilites, 2) - nvl(v_storage, 0)) *
                                      (1 - v_bank_support_perc / 100) * v_days_till_refuse /
                                      v_days_till_end
                                     ,2);
        par_rko_return_sum   := 0;
      END IF;
    
    END get_decline_policy_info;
  
    /*������������ ������� ��� �������� � ����*/
    PROCEDURE send_registry(par_load_file_id IN load_file.load_file_id%TYPE) IS
      v_registry_hkf_clob  CLOB;
      v_registry_zrs_clob  CLOB;
      v_files              pkg_email.t_files := pkg_email.t_files();
      v_csv_fields_count   NUMBER;
      v_process_start_date DATE := SYSDATE;
      v_blob_offset        NUMBER := 1;
      v_clob_offset        NUMBER := 1;
      v_warning            NUMBER;
      v_registry_hkf_query VARCHAR2(2000);
      v_registry_zsp_query VARCHAR2(2000);
      v_order_by_clause    VARCHAR2(50);
      v_lang_context       INTEGER := dbms_lob.default_lang_ctx;
      v_row_count          PLS_INTEGER;
    BEGIN
      SELECT COUNT(*)
        INTO v_csv_fields_count
        FROM load_csv_list     cl
            ,load_csv_settings st
       WHERE cl.brief = 'DECLINE_HKB'
         AND cl.load_csv_list_id = st.load_csv_list_id
       ORDER BY st.num;
    
      v_registry_hkf_query := 'select ';
      FOR v_idx IN 1 .. v_csv_fields_count
      LOOP
        v_registry_hkf_query := v_registry_hkf_query || 'val_' || to_char(v_idx) || ',';
      END LOOP;
      v_registry_hkf_query := rtrim(v_registry_hkf_query, ',') ||
                              ' from load_file_rows where load_file_id = ' ||
                              to_char(par_load_file_id);
      v_order_by_clause    := 'order by load_file_rows_id';
    
      /* ������ ���� �������*/
      v_files := pkg_email.t_files();
      v_files.extend(1);
    
      -- �������� �������� �����
      v_files(1).v_file_name := get_file_name;
    
      v_files(1).v_file_type := tt_file.get_mime_type(par_file_name_or_ext => v_files(1).v_file_name);
      dbms_lob.createtemporary(lob_loc => v_files(1).v_file, cache => TRUE);
      dbms_lob.createtemporary(lob_loc => v_registry_hkf_clob, cache => TRUE);
    
      pkg_csv.select_to_csv(par_select        => v_registry_hkf_query || ' ' || v_order_by_clause
                           ,par_header_option => pkg_csv.gc_without_header
                           ,par_csv           => v_registry_hkf_clob);
    
      dbms_lob.converttoblob(src_clob     => v_registry_hkf_clob
                            ,dest_lob     => v_files(1).v_file
                            ,amount       => dbms_lob.lobmaxsize
                            ,dest_offset  => v_blob_offset
                            ,src_offset   => v_clob_offset
                            ,blob_csid    => dbms_lob.default_csid
                            ,lang_context => v_lang_context
                            ,warning      => v_warning);
    
      dbms_lob.freetemporary(lob_loc => v_registry_hkf_clob);
    
      v_blob_offset := 1;
      v_clob_offset := 1;
    
      /* ������ ���� ������� (���) */
      v_registry_zsp_query := 'select val_1
                                     ,trunc(sysdate) as today
                                     ,val_4
                                     ,val_3
                                     ,val_5
                                     ,case
                                        when upper(val_14) = ''���''
                                        then ''��������� ����''
                                        else ''����''
                                       end as bank
                                     ,case
                                        when upper(val_14) = ''���''
                                        then val_15
                                       end as bik
                                     ,case
                                        when upper(val_14) = ''���''
                                        then val_16
                                       end as rs
                                 from load_file_rows where load_file_id = ' ||
                              to_char(par_load_file_id) || ' and val_23 = ''������� �� ������''';
    
      dbms_lob.createtemporary(lob_loc => v_registry_zrs_clob, cache => TRUE);
    
      pkg_csv.select_to_csv(par_select        => v_registry_zsp_query || ' ' || v_order_by_clause
                           ,par_header_option => pkg_csv.gc_header_from_parameter
                           ,par_header        => tt_one_col('� �/�'
                                                           ,'���� ������������ �������'
                                                           ,'����� ��������'
                                                           ,'��� �������'
                                                           ,'���� ���������� ���������'
                                                           ,'����, � ������� ���������� ����������� ��������� ������'
                                                           ,'���'
                                                           ,'�/�')
                           ,par_row_count     => v_row_count
                           ,par_csv           => v_registry_zrs_clob);
      IF v_row_count > 0
      THEN
        v_files.extend(1);
        v_files(2).v_file_name := '���������.csv';
        v_files(2).v_file_type := tt_file.get_mime_type(par_file_name_or_ext => v_files(2).v_file_name);
        dbms_lob.createtemporary(lob_loc => v_files(2).v_file, cache => TRUE);
      
        dbms_lob.converttoblob(src_clob     => v_registry_zrs_clob
                              ,dest_lob     => v_files(2).v_file
                              ,amount       => dbms_lob.lobmaxsize
                              ,dest_offset  => v_blob_offset
                              ,src_offset   => v_clob_offset
                              ,blob_csid    => dbms_lob.default_csid
                              ,lang_context => v_lang_context
                              ,warning      => v_warning);
      
        dbms_lob.freetemporary(lob_loc => v_registry_zrs_clob);
      END IF;
    
      pkg_email.send_mail_with_attachment(par_to         => c_to
                                         ,par_cc         => c_cc
                                         ,par_subject    => '������ ���_���������_' ||
                                                            to_char(v_process_start_date, 'dd.mm.yyyy')
                                         ,par_text       => '������������ ��������� ������� ����������� ���.'
                                         ,par_attachment => v_files);
      dbms_lob.freetemporary(lob_loc => v_files(1).v_file);
    END send_registry;
  
    /*���������� ���������� � "������� �����������" �� ��������� �� ������� �� �����*/
    PROCEDURE refresh_decline_journal IS
      v_decline_journal_hkfb_id decline_journal_hkfb.decline_journal_hkfb_id%TYPE;
      v_file_name               load_file.file_name%TYPE;
      v_tmp                     VARCHAR2(50);
      /*����������� �������*/
      FUNCTION define_status RETURN doc_status_ref.brief%TYPE IS
        v_status_brief doc_status_ref.brief%TYPE;
      BEGIN
        CASE vr_load_row.decision
          WHEN c_decision_payback THEN
            v_status_brief := 'PAYMENT';
          WHEN c_decision_refusal THEN
            v_status_brief := 'REFUSE';
          ELSE
            ex.raise('���  ���� ������� (' || vr_load_row.decision ||
                     ') �� ��������� ������ ��������� �� �����������');
        END CASE;
        RETURN v_status_brief;
      END define_status;
      /*����� ������ � ������� ����������� � ������� ��������� � ����, 
      ��� ����� �������� � ���� ��������� ��������� � ������� �������� � ����� ������ � �������*/
      FUNCTION find_journal_id_by_pol_num
      (
        par_policy_number       decline_journal_hkfb.policy_number%TYPE
       ,par_decline_notice_date decline_journal_hkfb.decline_notice_date%TYPE
      ) RETURN decline_journal_hkfb.decline_journal_hkfb_id%TYPE IS
        v_decline_journal_hkfb_id decline_journal_hkfb.decline_journal_hkfb_id%TYPE;
      BEGIN
        SELECT d.decline_journal_hkfb_id
          INTO v_decline_journal_hkfb_id
          FROM ven_decline_journal_hkfb d
         WHERE d.policy_number = par_policy_number
           AND d.decline_notice_date = par_decline_notice_date
           AND d.doc_status_ref_id = dml_doc_status_ref.get_id_by_brief('TRANSFER_TO_BANK');
        RETURN v_decline_journal_hkfb_id;
      EXCEPTION
        WHEN no_data_found THEN
          RETURN NULL;
        WHEN too_many_rows THEN
          ex.raise('������� ��������� ��������� �� ������ ��=' || par_policy_number ||
                   ', ���� ������ ��������� ' || to_char(par_decline_notice_date, 'dd.mm.rrrr'));
      END find_journal_id_by_pol_num;
    
      /*����� ������ � ������� ����������� � ������� ������, ��� ����� �������, ����� �������� � ���� ��������� ��������� � 
      ������� ������� (������ ���� ������������ �����), ������� �������� � ����� ������ � ������� ������*/
      FUNCTION find_journal_id_by_reg_num
      (
        par_policy_number       decline_journal_hkfb.policy_number%TYPE
       ,par_decline_notice_date decline_journal_hkfb.decline_notice_date%TYPE
       ,par_registry_number     VARCHAR2
      ) RETURN decline_journal_hkfb.decline_journal_hkfb_id%TYPE IS
      BEGIN
        SELECT d.decline_journal_hkfb_id
          INTO v_decline_journal_hkfb_id
          FROM ven_decline_journal_hkfb d
         WHERE d.policy_number = par_policy_number
           AND d.decline_notice_date = par_decline_notice_date
           AND d.registry_name = par_registry_number
           AND d.doc_status_ref_id = dml_doc_status_ref.get_id_by_brief('REFUSE');
        RETURN v_decline_journal_hkfb_id;
      EXCEPTION
        WHEN no_data_found THEN
          RETURN NULL;
        WHEN too_many_rows THEN
          ex.raise('������� ��������� ��������� �� ������ ��=' || par_policy_number ||
                   ', ���� ������ ��������� ' || to_char(par_decline_notice_date, 'dd.mm.rrrr'));
      END find_journal_id_by_reg_num;
    
      /*���������� ����� ��������� �� �����������*/
      PROCEDURE update_journal_row(par_decline_journal_hkfb_id decline_journal_hkfb.decline_journal_hkfb_id%TYPE) IS
        vr_decline_journal_hkfb dml_decline_journal_hkfb.tt_decline_journal_hkfb;
      
      BEGIN
        vr_decline_journal_hkfb := dml_decline_journal_hkfb.get_record(par_decline_journal_hkfb_id => par_decline_journal_hkfb_id);
      
        vr_decline_journal_hkfb.registry_name             := v_file_name;
        vr_decline_journal_hkfb.recieve_date              := vr_load_row.recieve_date;
        vr_decline_journal_hkfb.notice_date               := vr_load_row.notice_date;
        vr_decline_journal_hkfb.policy_start_date         := vr_load_row.notice_date;
        vr_decline_journal_hkfb.days_of_credit            := vr_load_row.days_of_credit;
        vr_decline_journal_hkfb.credit_end_date           := vr_load_row.credit_end_date;
        vr_decline_journal_hkfb.home_phone                := vr_load_row.home_phone;
        vr_decline_journal_hkfb.cell_phone                := vr_load_row.cell_phone;
        vr_decline_journal_hkfb.payment_generated         := vr_load_row.payment_generated;
        vr_decline_journal_hkfb.is_hkfb_account           := vr_load_row.is_hkfb_account;
        vr_decline_journal_hkfb.bank_bik                  := nvl(vr_decline_journal_hkfb.bank_bik
                                                                ,vr_load_row.bank_bik); --����������� ������ � ������, ���� �� ��������� � ������� �����������
        vr_decline_journal_hkfb.account_number            := nvl(vr_decline_journal_hkfb.account_number
                                                                ,vr_load_row.account_number); --����������� ������ � ������, ���� �� ��������� � ������� �����������
        vr_decline_journal_hkfb.is_credit                 := vr_load_row.is_credit;
        vr_decline_journal_hkfb.application_reason        := nvl(vr_decline_journal_hkfb.application_reason
                                                                ,vr_load_row.application_reason); --����������� ������ � ������, ���� �� ��������� � ������� �����������
        vr_decline_journal_hkfb.bank_return_amount        := vr_load_row.bank_return_amount;
        vr_decline_journal_hkfb.bank_return_ag_amount     := vr_load_row.bank_return_ag_amount;
        vr_decline_journal_hkfb.bank_return_rko_amount    := vr_load_row.bank_return_rko_amount;
        vr_decline_journal_hkfb.decision                  := vr_load_row.decision;
        vr_decline_journal_hkfb.decline_note              := vr_load_row.decline_note;
        vr_decline_journal_hkfb.company_return_amount     := vr_load_row.company_return_amount;
        vr_decline_journal_hkfb.company_return_ag_amount  := vr_load_row.company_return_ag_amount;
        vr_decline_journal_hkfb.company_return_rko_amount := vr_load_row.company_return_rko_amount;
        vr_decline_journal_hkfb.registration_date         := vr_load_row.registration_date;
        vr_decline_journal_hkfb.responsible               := vr_load_row.responsible;
        vr_decline_journal_hkfb.product_name              := vr_load_row.product_name;
        vr_decline_journal_hkfb.bank_notice               := vr_load_row.bank_notice;
        /*���������� ���������� � ���������*/
        dml_decline_journal_hkfb.update_record(par_record => vr_decline_journal_hkfb);
        /*������� ��������� � ������ ������*/
        doc.set_doc_status(p_doc_id       => vr_decline_journal_hkfb.decline_journal_hkfb_id
                          ,p_status_brief => define_status);
      END update_journal_row;
    
      /*������������ ������ ���������*/
      PROCEDURE insert_journal_row IS
        vr_decline_journal_hkfb dml_decline_journal_hkfb.tt_decline_journal_hkfb;
      BEGIN
        vr_decline_journal_hkfb.registry_name             := v_file_name;
        vr_decline_journal_hkfb.insured_name              := vr_load_row.insured_name;
        vr_decline_journal_hkfb.policy_number             := vr_load_row.policy_number;
        vr_decline_journal_hkfb.recieve_date              := vr_load_row.recieve_date;
        vr_decline_journal_hkfb.notice_date               := vr_load_row.notice_date;
        vr_decline_journal_hkfb.policy_start_date         := vr_load_row.notice_date;
        vr_decline_journal_hkfb.days_of_credit            := vr_load_row.days_of_credit;
        vr_decline_journal_hkfb.credit_end_date           := vr_load_row.credit_end_date;
        vr_decline_journal_hkfb.home_phone                := vr_load_row.home_phone;
        vr_decline_journal_hkfb.cell_phone                := vr_load_row.cell_phone;
        vr_decline_journal_hkfb.decline_notice_date       := vr_load_row.decline_notice_date;
        vr_decline_journal_hkfb.payment_generated         := vr_load_row.payment_generated;
        vr_decline_journal_hkfb.application_place         := vr_load_row.application_place;
        vr_decline_journal_hkfb.is_hkfb_account           := vr_load_row.is_hkfb_account;
        vr_decline_journal_hkfb.bank_bik                  := vr_load_row.bank_bik;
        vr_decline_journal_hkfb.account_number            := vr_load_row.account_number;
        vr_decline_journal_hkfb.is_credit                 := vr_load_row.is_credit;
        vr_decline_journal_hkfb.application_reason        := vr_load_row.application_reason;
        vr_decline_journal_hkfb.bank_return_amount        := vr_load_row.bank_return_amount;
        vr_decline_journal_hkfb.bank_return_ag_amount     := vr_load_row.bank_return_ag_amount;
        vr_decline_journal_hkfb.bank_return_rko_amount    := vr_load_row.bank_return_rko_amount;
        vr_decline_journal_hkfb.decision                  := vr_load_row.decision;
        vr_decline_journal_hkfb.decline_note              := vr_load_row.decline_note;
        vr_decline_journal_hkfb.company_return_amount     := vr_load_row.company_return_amount;
        vr_decline_journal_hkfb.company_return_ag_amount  := vr_load_row.company_return_ag_amount;
        vr_decline_journal_hkfb.company_return_rko_amount := vr_load_row.company_return_rko_amount;
        vr_decline_journal_hkfb.registration_date         := vr_load_row.registration_date;
        vr_decline_journal_hkfb.responsible               := vr_load_row.responsible;
        vr_decline_journal_hkfb.product_name              := vr_load_row.product_name;
        vr_decline_journal_hkfb.bank_notice               := vr_load_row.bank_notice;
        vr_decline_journal_hkfb.doc_templ_id              := doc.templ_id_by_brief('DECLINE_JOURNAL_HKFB');
      
        dml_decline_journal_hkfb.insert_record(vr_decline_journal_hkfb);
        /*������� ��������� � ������ ������*/
        doc.set_doc_status(p_doc_id       => vr_decline_journal_hkfb.decline_journal_hkfb_id
                          ,p_status_brief => define_status);
      END insert_journal_row;
    
    BEGIN
    
      v_file_name := get_file_name;
      v_tmp       := vr_load_row.policy_number;
      /*����� ��������� � ������� "�������� � ����"*/
      v_decline_journal_hkfb_id := find_journal_id_by_pol_num(par_policy_number       => vr_load_row.policy_number
                                                             ,par_decline_notice_date => vr_load_row.decline_notice_date);
      /*���� ����� ������, �� ������������� ������*/
      IF v_decline_journal_hkfb_id IS NOT NULL
      THEN
        update_journal_row(v_decline_journal_hkfb_id);
      ELSE
        /*���� � ������� "�����"*/
      
        v_decline_journal_hkfb_id := find_journal_id_by_reg_num(par_policy_number       => vr_load_row.policy_number
                                                               ,par_decline_notice_date => vr_load_row.decline_notice_date
                                                               ,par_registry_number     => v_file_name /*���� �� ����� �������*/);
        /*����� ������, �� ���������, �� ����� - ��������� ����� ���������*/
        IF v_decline_journal_hkfb_id IS NOT NULL
        THEN
          update_journal_row(v_decline_journal_hkfb_id);
        ELSE
          insert_journal_row;
        END IF;
      
      END IF; --����� ���� ����� � ������� "�������� � ����"
    
    END refresh_decline_journal;
    /*��� ��������� ������� � ������� �����������, ��� ������ ��������� � ���� ���������� ����� 10�� ���� ����� � � ���� 
    ������ ���������� ���������� ������� �������� ��ʔ � ������������ ������ ������������ � �ʔ.*/
    PROCEDURE set_status_4_the_rest_journal IS
      c_old_count CONSTANT NUMBER := 10; --���-�� ����, ����� �������� ��������� ����������� � ������ "����������� � ��"
    BEGIN
      FOR vr_row IN (SELECT
                     /*+ INDEX (d IX_DOCUMENT_DOC_STATUS_REF_ID)*/
                      v.decline_journal_hkfb_id
                       FROM decline_journal_hkfb v
                           ,document             d
                           ,doc_status           ds
                      WHERE v.decline_journal_hkfb_id = d.document_id
                        AND d.doc_status_id = ds.doc_status_id
                        AND d.doc_status_ref_id =
                            dml_doc_status_ref.get_id_by_brief('TRANSFER_TO_BANK')
                        AND ds.start_date <= SYSDATE - c_old_count
                        AND v.application_place = c_application_place_company /*��������� ��������*/
                     )
      LOOP
        doc.set_doc_status(p_doc_id       => vr_row.decline_journal_hkfb_id
                          ,p_status_brief => 'BRAKE_IN_COMPANY');
      END LOOP;
    END set_status_4_the_rest_journal;
  
    /*�������� � ������ ��� �������� � ���� ����� ���������, ����������� � ��*/
    PROCEDURE add_decline_notice_from_journl IS
    BEGIN
      /*2.2)  � ������ ����������� ���������� �� ���� ������� � ������� � ������� ������, 
      � ������� �������� � ���� �������� ���������� �� �������, ��� ����� ���ϔ ��� ������� �����������*/
      FOR vr_row IN (SELECT v.*
                       FROM decline_journal_hkfb v
                           ,document             d
                      WHERE d.doc_status_ref_id = dml_doc_status_ref.get_id_by_brief('NEW')
                        AND v.decline_journal_hkfb_id = d.document_id
                        AND (v.application_reason IN
                            (c_application_reason_pdp, c_application_reason_cooling) OR
                            v.application_reason IS NULL))
      LOOP
        dml_load_file_rows.insert_record(par_load_file_id => par_load_file_id
                                        ,par_row_status   => 1
                                        ,par_is_checked   => 1
                                        ,par_row_comment  => '��������� �� ������� ����������� � ��'
                                         --,par_val_3        => vr_row.insured_name -- ����� �.: ������ 390606
                                        ,par_val_4  => vr_row.policy_number
                                        ,par_val_11 => vr_row.decline_notice_date
                                        ,par_val_13 => c_application_place_company /*��*/
                                        ,par_val_18 => vr_row.application_reason);
        /*������� �� "�����" � "�������� � ����" ��������� �� �������*/
        doc.set_doc_status(p_doc_id       => vr_row.decline_journal_hkfb_id
                          ,p_status_brief => 'TRANSFER_TO_BANK');
      END LOOP;
    END add_decline_notice_from_journl;
  
    /*���������� ���� ��������� �� �����������*/
    PROCEDURE set_pol_decline_notice_date
    (
      par_pol_decline_id      p_pol_decline.p_pol_decline_id%TYPE
     ,par_decline_notice_date p_pol_decline.decline_notice_date%TYPE
    ) IS
    BEGIN
      UPDATE p_pol_decline p
         SET p.decline_notice_date = par_decline_notice_date
       WHERE p.p_pol_decline_id = par_pol_decline_id;
    END set_pol_decline_notice_date;
  
  BEGIN
    IF is_test_server != 1
    THEN
      c_to := pkg_email.t_recipients('bank_cancel_hkb@renlife.com');
      c_cc := pkg_email.t_recipients('cancel_hkb@renlife.com'
                                    ,'pavel.vrona@renlife.com'
                                    ,'Tatyana.Gorshkova@Renlife.com'
                                    ,'Rustam.Ahtyamov@renlife.com'
                                    ,'Andrey.Gizhunov@Renlife.com'
                                    ,'Aleksey.Sharin@renlife.com'
                                    ,'Ivan.Holodov@renlife.com');
    ELSE
      c_to := pkg_email.t_recipients('Tatyana.Gorshkova@Renlife.com');
    END IF;
  
    assert_deprecated(par_load_file_id IS NULL, '�� ����� ������ ���� ������!');
  
    /* ���� � ���� �������� ������� ������� ��������, �� ������� � ��������� ������ */
    FOR vr_row IN cur_file
    LOOP
      SAVEPOINT before_process;
    
      /* ����� ������� ����������� �������� ���� ������ �������� ��������� �� ���������
      ���� ������ �������� �������, � ���λ �������� ������������ ��������� �� ���������
      ����  ���� ������������� ������� */
      BEGIN
        vr_policy := find_policy(par_policy_num => vr_row.policy_num);
      
        -- �������� ���������� ��������
        BEGIN
          SELECT ph.*
            INTO vr_pol_header
            FROM p_pol_header ph
           WHERE ph.policy_header_id = vr_policy.pol_header_id
             FOR UPDATE NOWAIT;
        EXCEPTION
          WHEN pkg_oracle_exceptions.resource_busy_nowait THEN
            RAISE policy_locked;
        END;
        v_policy_status_brief := doc.get_doc_status_brief(doc_id => vr_policy.policy_id);
      
        /* �������������� �������� ���������� ������� ��������� ������ �� */
        vr_decline_reason       := find_pol_decline_reason(par_policy_id => vr_policy.policy_id);
        v_ag_contract_header_id := pkg_agn_control.get_current_policy_agent(par_pol_header_id => vr_policy.pol_header_id);
      
        IF v_policy_status_brief IN ('TO_QUIT'
                                    ,'TO_QUIT_CHECK_READY'
                                    ,'TO_QUIT_CHECKED'
                                    ,'QUIT'
                                    ,'QUIT_REQ_QUERY'
                                    ,'QUIT_REQ_GET'
                                    ,'QUIT_TO_PAY'
                                    ,'DECLINE_CALCULATION')
        THEN
          /* � ����������� �� ������� �����������, ���� �����������
          ����������� ��������� �������� */
          v_decline_policy_id := vr_policy.policy_id;
          IF vr_decline_reason.brief = '�������������������������'
          THEN
            RAISE bank_annulation;
          ELSIF vr_decline_reason.brief = '������� ���� (�������������)'
          THEN
            RAISE court_annulation;
          ELSE
            RAISE other_annulation;
          END IF;
        END IF;
      
        /* ��� ������������ �������� ����������� ����������� ��������
        ������� ��� � ������� "� ������" */
        check_payments_to_pay(par_pol_header_id => vr_policy.pol_header_id);
      
        /* ���� �� �� ���� ������ � ������� �������� �� �������,
        �� ���� "�������" ������� ��������� �������� "�����",
        � ���� ������������ ������� ��������� �������� "�� �������� ������� ������" */
        check_claims(par_pol_header_id => vr_policy.pol_header_id);
      
        /* ����������� �������� ������� �� ���������� �� ������ � ������� �������,
        �������� ���� �� ������� �������� ������ 0 */
        check_closed_claims(par_pol_header_id => vr_policy.pol_header_id);
      
        /* �������������� �������� ��������� ��������� �� ����������� � ������ ����������.*/
        get_cooling_period(par_decline_notice_date => vr_row.decline_notice_date
                          ,par_repayment_date      => vr_row.repayment_date
                          ,par_policy_confirm_date => vr_policy.confirm_date
                           --,par_header_start_date   => vr_pol_header.start_date
                          ,par_pol_notice_date   => vr_policy.notice_date
                          ,par_decline_reason_id   => v_decline_reason_id
                          ,par_refusal_reason      => v_refusal_reason);
      
        IF v_refusal_reason = '������ ����������'
        THEN
          v_decline_date := vr_policy.confirm_date;
        ELSE
          v_decline_date := vr_row.repayment_date;
        END IF;
      
        create_new_version(par_policy_id           => vr_policy.policy_id
                          ,par_decline_reason_id   => v_decline_reason_id
                          ,par_decline_notice_date => vr_row.decline_notice_date
                          ,par_decline_date        => v_decline_date /* + 1 �������� �� vr_row.repayment_date ������ 380073*/ /*���� ����������� +1 ����*/
                          ,par_declined_policy_id  => v_decline_policy_id);
        -- ������� ������ ������ � �������� �����������
        create_pol_decline(par_policy_id          => vr_policy.policy_id
                          ,par_declined_policy_id => v_decline_policy_id
                          ,par_product_conds_id   => vr_policy.t_product_conds_id
                          ,par_pol_decline_id     => v_pol_decline_id);
        IF v_refusal_reason = '������ ����������'
        THEN
          /*������ ��� �������������� ��������*/
          /*������ ��� �� ������ "���������� �������" ����� �����������*/
          pkg_policy_decline.calculate_decline(par_policy_id  => v_decline_policy_id /*�������� ������ �����������*/
                                              ,par_result     => v_result
                                              ,par_commentary => v_comment);
          /*���������� ���� ��������� �� ����������� (�� ������ �� ����� ��������), �.�. � ������������� 
          ��������� ������� �� ��������� �� ��������� ������� ��������, � � ������ ������ ��������� ���
          20.4.2015 ������ �.
          */
          set_pol_decline_notice_date(par_pol_decline_id      => v_pol_decline_id
                                     ,par_decline_notice_date => vr_row.decline_notice_date);
        ELSE
          custom_decline_calc(par_policy_id => v_decline_policy_id);
          update_pol_decline(par_pol_decline_id       => v_pol_decline_id
                            ,par_decline_notice_date  => vr_row.decline_notice_date
                            ,par_return_sum_from_bank => vr_row.return_sum_from_bank);
        END IF;
      
        -- ��������� ������������� ���� ����� �����������
        get_decline_policy_info(par_policy_id             => v_decline_policy_id
                               ,par_policy_header_id      => vr_policy.pol_header_id
                               ,par_ag_contract_header_id => v_ag_contract_header_id
                               ,par_refusal_reason        => v_refusal_reason
                               ,par_repayment_date        => vr_row.repayment_date
                               ,par_client_return_sum     => v_client_return_summ
                               ,par_agent_return_sum      => v_agent_return_summ
                               ,par_rko_return_sum        => v_rko_return_sum);
      
        update_register_info(par_row_id            => vr_row.load_file_rows_id
                            ,par_decline_reason    => v_refusal_reason
                            ,par_decision          => c_decision_payback
                            ,par_comment           => NULL
                            ,par_return_summ       => v_client_return_summ
                            ,par_agent_return_summ => v_agent_return_summ
                            ,par_rko_return_sum    => v_rko_return_sum
                            ,par_product_id        => vr_pol_header.product_id);
      
      EXCEPTION
        WHEN policy_not_found THEN
          ROLLBACK TO before_process;
          v_decision := c_decision_refusal;
          set_decision_comment(par_row_id   => vr_row.load_file_rows_id
                              ,par_decision => c_decision_refusal
                              ,par_comment  => '������� �� ������');
        WHEN bank_annulation THEN
          ROLLBACK TO before_process;
          v_decision := c_decision_refusal;
          set_decision_comment(par_row_id   => vr_row.load_file_rows_id
                              ,par_decision => c_decision_refusal
                              ,par_comment  => '����������� �� ���������� �����');
        WHEN court_annulation THEN
          ROLLBACK TO before_process;
          v_decision := c_decision_refusal;
          set_decision_comment(par_row_id   => vr_row.load_file_rows_id
                              ,par_decision => c_decision_refusal
                              ,par_comment  => '����������� �� ������� ����');
        WHEN other_annulation THEN
          ROLLBACK TO before_process;
          v_decision := c_decision_refusal;
          set_decision_comment(par_row_id   => vr_row.load_file_rows_id
                              ,par_decision => c_decision_refusal
                              ,par_comment  => '������� ����������� ��� ����������/����������� �����');
        WHEN exists_payment_to_pay THEN
          ROLLBACK TO before_process;
          v_decision := c_decision_refusal;
          set_decision_comment(par_row_id   => vr_row.load_file_rows_id
                              ,par_decision => c_decision_refusal
                              ,par_comment  => '������� �� �������');
        WHEN exists_claim THEN
          ROLLBACK TO before_process;
          v_decision := c_decision_refusal;
          set_decision_comment(par_row_id   => vr_row.load_file_rows_id
                              ,par_decision => c_decision_refusal
                              ,par_comment  => '�� �������� ������� ������');
        WHEN exists_closed_claim THEN
          ROLLBACK TO before_process;
          v_decision := c_decision_refusal;
          set_decision_comment(par_row_id   => vr_row.load_file_rows_id
                              ,par_decision => c_decision_refusal
                              ,par_comment  => '�� �������� ����������� ���� ������������ ��������� �������');
        WHEN loan_is_not_repaid THEN
          ROLLBACK TO before_process;
          v_decision := c_decision_refusal;
          set_decision_comment(par_row_id   => vr_row.load_file_rows_id
                              ,par_decision => c_decision_refusal
                              ,par_comment  => '��������� ������ ����� 30 ��, ��� �� ����');
        WHEN too_many_policies THEN
          ROLLBACK TO before_process;
          pkg_load_file_to_table.set_row_status(par_load_file_rows_id => vr_row.load_file_rows_id
                                               ,par_row_status        => pkg_load_file_to_table.get_error
                                               ,par_is_checked        => 0
                                               ,par_row_comment       => '������� ��������� ��������� � ��������� ������� � ��� ������������');
        WHEN policy_locked THEN
          ROLLBACK TO before_process;
          pkg_load_file_to_table.set_row_status(par_load_file_rows_id => vr_row.load_file_rows_id
                                               ,par_row_status        => pkg_load_file_to_table.get_error
                                               ,par_is_checked        => 0
                                               ,par_row_comment       => '������� ������������ ������ �������������');
        WHEN set_status_error THEN
          ROLLBACK TO before_process;
          pkg_load_file_to_table.set_row_status(par_load_file_rows_id => vr_row.load_file_rows_id
                                               ,par_row_status        => pkg_load_file_to_table.get_error
                                               ,par_is_checked        => 0
                                               ,par_row_comment       => dbms_utility.format_error_stack);
      END;
    END LOOP;
  
    /*��������� ����� ��� ��� ��� ������������ ���������� � "������� ����������� ����"*/
  
    FOR vr_row IN (SELECT fr.load_file_rows_id
                         ,fr.row_comment
                     FROM load_file_rows fr
                    WHERE fr.load_file_id = par_load_file_id
                      AND fr.row_status NOT IN (pkg_load_file_to_table.get_error) /*�� ����� � ������� "������"*/
                      AND fr.is_checked = 1)
    LOOP
      SAVEPOINT before_journal_process;
      BEGIN
        /*����������� ������*/
        pkg_load_file_to_table.cache_row(vr_row.load_file_rows_id);
        /*������������ ������ �� ������*/
        vr_load_row := get_row_values;
        /*���������� ���������� � ������� ��� ������ ������*/
        refresh_decline_journal;
        /*���� ��� ������, �� �������� ������ ��� ������������*/
        pkg_load_file_to_table.set_row_status(par_load_file_rows_id => vr_row.load_file_rows_id
                                             ,par_row_status        => pkg_load_file_to_table.get_loaded);
      EXCEPTION
        /*���� ���� �����-�� ������, �� ����� � �����������*/
        WHEN OTHERS THEN
          ROLLBACK TO before_journal_process;
          pkg_load_file_to_table.set_row_status(par_load_file_rows_id => vr_row.load_file_rows_id
                                               ,par_row_status        => pkg_load_file_to_table.get_error
                                               ,par_is_checked        => 0
                                               ,par_row_comment       => vr_row.row_comment || SQLERRM);
      END;
    END LOOP;
    /*����� ����� ��� ������������ ���������� � "������� ����������� ����"*/
  
    --��������� ������� "����������� � ��" ��� ���������, ���������� � ���� ����� 10 ���� �����
    set_status_4_the_rest_journal;
    /*�������� ����� ��������� �� ������� � ������ ��� �������� �����*/
    add_decline_notice_from_journl;
  
    -- ���������� ��������� CSV
    SELECT COUNT(*)
      INTO v_errors_exists
      FROM dual
     WHERE EXISTS (SELECT NULL
              FROM load_file_rows fr
             WHERE fr.load_file_id = par_load_file_id
               AND fr.row_status = pkg_load_file_to_table.get_error
               AND regexp_like(fr.val_1, '^\d+$'));
  
    IF v_errors_exists = 0
    THEN
      send_registry(par_load_file_id);
    END IF;
  END group_decline_hkb;

  /*
  ��������� ����������� ��������� ���. �������� ���� �������
  25.06.2014 ������ �.
  */
  PROCEDURE decline_hkb_payoff_date(par_load_file_id load_file.load_file_id%TYPE) IS
    policy_not_found_by_num      EXCEPTION; --�� ������� ������ �� ������ ��
    too_many_policies            EXCEPTION; --��������� ������
    wrong_pol_status             EXCEPTION; --������ ������ != � �����������. ��������
    wrong_credit_sum             EXCEPTION; --����� ������� > 0
    ex_errors_while_chain_status EXCEPTION; --������ ��� �������� �������� (������ ����� ����������� � � ����������� � � �����������. ����� ��� ��������- � �����������. �������� � ���������)
  
    vr_policy p_policy%ROWTYPE;
  
    /*����� �� �� ������*/
    FUNCTION find_policy_by_num(par_policy_num p_policy.pol_num%TYPE) RETURN p_policy%ROWTYPE IS
      vr_result_policy p_policy%ROWTYPE;
    BEGIN
      SELECT pp.*
        INTO vr_result_policy
        FROM p_policy     pp
            ,p_pol_header pph
       WHERE pp.pol_num = par_policy_num
         AND pph.max_uncancelled_policy_id = pp.policy_id
         AND EXISTS (SELECT NULL
                FROM document       dc
                    ,doc_status_ref dsr
               WHERE dc.document_id = pph.policy_id
                 AND dc.doc_status_ref_id = dsr.doc_status_ref_id
                 AND dsr.brief != 'CANCEL');
      RETURN vr_result_policy;
    EXCEPTION
      WHEN no_data_found THEN
        RAISE policy_not_found_by_num;
      WHEN too_many_rows THEN
        RAISE too_many_policies;
    END find_policy_by_num;
  
  BEGIN
  
    FOR vr_row IN (SELECT '2' ||
                          substr(regexp_substr(fr.val_4, '\d{9}. ��� �� ����������', 1)
                                ,1
                                ,9) pol_num
                         ,fr.load_file_rows_id
                         ,to_date(fr.val_2, 'dd.mm.rrrr') payoff_date
                         ,fr.val_1 pay_doc_num
                     FROM load_file_rows fr
                    WHERE fr.load_file_id = par_load_file_id
                      AND fr.row_status = pkg_load_file_to_table.get_checked
                      AND fr.is_checked = 1)
    LOOP
      BEGIN
        SAVEPOINT before_process;
      
        /*���� �� ������� ������ �� ������, ���� ����� ���������, �� ��������*/
        vr_policy := find_policy_by_num(par_policy_num => vr_row.pol_num);
      
        /*��� �� � ������� "������ ����� �����������" ��������� ���� ������� � ��������� � "���������" ��
        ������� "������ ����� ����������� � � ����������� � � �����������. ����� ��� ��������- � �����������. �������� � ���������"
        409773: ����� ������� ���� ������ �.*/
      
        IF doc.get_last_doc_status_brief(vr_policy.policy_id) IN
           ('DECLINE_CALCULATION', 'TO_QUIT_CHECKED')
        THEN
          UPDATE p_pol_decline pd
             SET pd.issuer_return_date = vr_row.payoff_date
                ,pd.pay_doc_num        = vr_row.pay_doc_num
                ,pd.act_date           = vr_row.payoff_date /*���� ���� ����� �� ��� ���� ������� 409773 ������ �.*/
           WHERE pd.p_policy_id = vr_policy.policy_id;
        
          BEGIN
            IF doc.get_last_doc_status_brief(vr_policy.policy_id) = 'TO_QUIT_CHECKED'
            THEN
              --���������
              doc.set_doc_status(p_doc_id => vr_policy.policy_id, p_status_brief => 'QUIT');
            ELSE
              --������� ������ � ������ "� �����������"
              doc.set_doc_status(p_doc_id => vr_policy.policy_id, p_status_brief => 'TO_QUIT');
              --� �����������. ����� ��� ��������
              doc.set_doc_status(p_doc_id       => vr_policy.policy_id
                                ,p_status_brief => 'TO_QUIT_CHECK_READY');
              --� �����������. ��������
              doc.set_doc_status(p_doc_id => vr_policy.policy_id, p_status_brief => 'TO_QUIT_CHECKED');
              --���������
              doc.set_doc_status(p_doc_id => vr_policy.policy_id, p_status_brief => 'QUIT');
            END IF;
          EXCEPTION
            WHEN OTHERS THEN
              RAISE ex_errors_while_chain_status;
          END;
          --��������� ������������� ������ �� P_POLICY
          UPDATE load_file_rows fr
             SET fr.ure_id = ent.id_by_brief('P_POLICY')
                ,fr.uro_id = vr_policy.policy_id
           WHERE fr.load_file_rows_id = vr_row.load_file_rows_id;
          --�������� ������� ������ - ���������
          pkg_load_file_to_table.set_row_status(par_load_file_rows_id => vr_row.load_file_rows_id
                                               ,par_row_status        => pkg_load_file_to_table.get_loaded);
        ELSE
          RAISE wrong_pol_status;
        END IF;
      EXCEPTION
        WHEN ex_errors_while_chain_status THEN
          ROLLBACK TO before_process;
          pkg_load_file_to_table.set_row_status(par_load_file_rows_id => vr_row.load_file_rows_id
                                               ,par_row_status        => pkg_load_file_to_table.get_error
                                               ,par_is_checked        => 0
                                               ,par_row_comment       => '������ ��� �������� �������� ������ ����� ����������� � � ����������� � � �����������. ����� ��� ��������- � �����������. �������� � ���������.');
        WHEN policy_not_found_by_num THEN
          ROLLBACK TO before_process;
          pkg_load_file_to_table.set_row_status(par_load_file_rows_id => vr_row.load_file_rows_id
                                               ,par_row_status        => pkg_load_file_to_table.get_error
                                               ,par_is_checked        => 0
                                               ,par_row_comment       => '�� ������ ������� ���������� �' ||
                                                                         vr_row.pol_num ||
                                                                         ' ��� ������ ������ �� ������');
        WHEN too_many_policies THEN
          ROLLBACK TO before_process;
          pkg_load_file_to_table.set_row_status(par_load_file_rows_id => vr_row.load_file_rows_id
                                               ,par_row_status        => pkg_load_file_to_table.get_error
                                               ,par_is_checked        => 0
                                               ,par_row_comment       => '������� ��������� ��������� ����������� �' ||
                                                                         vr_row.pol_num);
        WHEN wrong_pol_status THEN
          ROLLBACK TO before_process;
          pkg_load_file_to_table.set_row_status(par_load_file_rows_id => vr_row.load_file_rows_id
                                               ,par_row_status        => pkg_load_file_to_table.get_error
                                               ,par_is_checked        => 0
                                               ,par_row_comment       => '������� ����������� ��������� � ������� �������� �� "������ ����� �����������"');
        WHEN wrong_credit_sum THEN
          ROLLBACK TO before_process;
          pkg_load_file_to_table.set_row_status(par_load_file_rows_id => vr_row.load_file_rows_id
                                               ,par_row_status        => pkg_load_file_to_table.get_error
                                               ,par_is_checked        => 0
                                               ,par_row_comment       => '����� �� ������� ������ 0');
      END;
    
    END LOOP;
  END decline_hkb_payoff_date;

  /*
    ������ �., 24.10.2013, 217702 �������������� ����������� ��������� 0 ��� ������� �������� � ��������
    ������ �������� "��������� ����������� ���������"
    ��������� "�������� ������ ��������� �� ����������� �� � �������� ������"
    ��������� ��������
  */
  PROCEDURE check_termination_zero_akt_row
  (
    par_load_file_rows_id NUMBER
   ,par_status            OUT NUMBER
   ,par_comment           OUT VARCHAR2
  ) IS
    TYPE t_file_row IS RECORD(
       ids          NUMBER
      ,start_date   DATE
      ,end_date     DATE
      ,purpose_code NUMBER
      ,pol_num      VARCHAR2(50));
  
    v_file_row      t_file_row;
    v_pol_header_id NUMBER;
    v_pol_num       p_policy.pol_num%TYPE;
  BEGIN
    par_status := pkg_load_file_to_table.get_checked;
    -- �������� ����
    IF safety.check_right_custom(p_obj_id => 'LOAD_POLICY_TERMINATE_ZERO_AKT') = 1
    THEN
      -- ������ ����������� ������ � �����
      SELECT to_number(lf.val_1)
            ,lf.val_2
            ,lf.val_3
            ,to_number(lf.val_4)
            ,lf.val_5
        INTO v_file_row
        FROM load_file_rows lf
       WHERE lf.load_file_rows_id = par_load_file_rows_id;
    
      -- �������� ��� � ������ �� �� ������������
      BEGIN
        SELECT DISTINCT ph.policy_header_id
                       ,p.pol_num
          INTO v_pol_header_id
              ,v_pol_num
          FROM p_pol_header   ph
              ,p_policy       p
              ,document       d
              ,doc_status_ref dsr
         WHERE 1 = 1
           AND p.policy_id = ph.last_ver_id
           AND d.document_id = p.policy_id
           AND dsr.doc_status_ref_id = d.doc_status_ref_id
           AND dsr.brief IN ('PASSED_TO_AGENT' -- �������� ������
                            ,'CONCLUDED' -- ������� ��������
                            ,'CURRENT' -- �����������
                             )
           AND CASE
                 WHEN v_file_row.pol_num IS NOT NULL THEN
                  CASE
                    WHEN p.pol_num = v_file_row.pol_num THEN
                     1
                    ELSE
                     0
                  END
                 ELSE
                  1
               END = 1
           AND ph.ids = v_file_row.ids;
      EXCEPTION
        WHEN no_data_found THEN
          par_status  := pkg_load_file_to_table.get_error;
          par_comment := '� �� ����������� �������� � ��� ' || v_file_row.ids ||
                         ' � ������� ��������� ������, �������� �������� � ������������';
      END;
    
      IF par_comment IS NULL
      THEN
        -- �������� ������ ��
        IF (v_file_row.pol_num IS NOT NULL)
           AND (v_file_row.pol_num <> v_pol_num)
        THEN
          par_status  := pkg_load_file_to_table.get_error;
          par_comment := '� �� ����������� �������� � ��� ' || v_file_row.ids || ' � ������� ' ||
                         v_file_row.pol_num ||
                         ' � ������� ��������� ������ , �������� �������� � ������������';
        END IF;
      
        IF par_comment IS NULL
        THEN
          -- �������� ���� ����
          IF v_file_row.start_date > trunc(SYSDATE)
          THEN
            par_status  := pkg_load_file_to_table.get_error;
            par_comment := '���� ���� ������� � �������: ' ||
                           to_char(v_file_row.start_date, 'DD.MM.YYYY') || '';
          END IF;
        
          IF par_comment IS NULL
          THEN
            -- �������� ���� �����������
            IF v_file_row.end_date > v_file_row.start_date
            THEN
              par_status  := pkg_load_file_to_table.get_error;
              par_comment := '���� ����������� ' || to_char(v_file_row.end_date, 'DD.MM.YYYY') ||
                             ' �� ������ ���� ������ ���� ���� ' ||
                             to_char(v_file_row.start_date, 'DD.MM.YYYY') || '';
            END IF;
          
            IF par_comment IS NULL
            THEN
              -- �������� ���� ������� �����������
              IF v_file_row.purpose_code NOT IN (182, 221)
              THEN
                par_status  := pkg_load_file_to_table.get_error;
                par_comment := '� ���� ���� ������� ������������ ������� ������������ ��������: ' ||
                               v_file_row.purpose_code || '';
              END IF;
            END IF;
          END IF;
        END IF;
      END IF;
    ELSE
      -- �������� ������ ���� �������
      par_status  := pkg_load_file_to_table.get_error;
      par_comment := '������������ ���� �� �������� ������������ ��������� � �������� ������';
    END IF;
  END check_termination_zero_akt_row;

  /*
    ������ �., 24.10.2013, 217702 �������������� ����������� ��������� 0 ��� ������� �������� � ��������
    ������ �������� "��������� ����������� ���������"
    ��������� "�������� ������ ��������� �� ����������� �� � �������� ������"
    ��������� ��������
  */
  PROCEDURE terminate_zero_akt_list(par_load_file_rows_id NUMBER) IS
    TYPE t_file_row IS RECORD(
       ids          NUMBER
      ,start_date   DATE
      ,end_date     DATE
      ,purpose_code NUMBER
      ,pol_num      VARCHAR2(50));
  
    v_file_row         t_file_row;
    v_continue         BOOLEAN := TRUE;
    v_policy_id        NUMBER;
    v_quit_policy_id   NUMBER;
    v_pol_decline_id   NUMBER;
    v_product_conds_id NUMBER;
    v_reg_code         NUMBER;
    v_insured_fio      VARCHAR2(300);
  
    CURSOR cover_curs(pcurs_pol_decline_id NUMBER) IS
      SELECT cd.p_cover_decline_id
            ,cd.as_asset_id
            ,cd.t_product_line_id
        FROM p_cover_decline cd
       WHERE cd.p_pol_decline_id = pcurs_pol_decline_id;
  
    -- ������ ���������� �������
    PROCEDURE update_row_load_result
    (
      par_load_file_rows_id NUMBER
     ,par_comment           VARCHAR2
    ) IS
    BEGIN
      UPDATE load_file_rows lf
         SET lf.val_6 = par_comment
       WHERE lf.load_file_rows_id = par_load_file_rows_id;
    END update_row_load_result;
  
    -- ��������� ������� ������ ��� ����������� ������
    PROCEDURE set_row_error_status
    (
      par_load_file_rows_id NUMBER
     ,par_comment           VARCHAR2
    ) IS
    BEGIN
      pkg_load_file_to_table.set_row_status(par_load_file_rows_id => par_load_file_rows_id
                                           ,par_row_status        => pkg_load_file_to_table.get_error
                                           ,par_row_comment       => par_comment
                                           ,par_is_checked        => 0 -- ������ ������� �� ������
                                            );
    END set_row_error_status;
  
  BEGIN
    -- �������� ����
    IF safety.check_right_custom(p_obj_id => 'LOAD_POLICY_TERMINATE_ZERO_AKT') = 1
    THEN
      -- ������ ����������� ������ � �����
      BEGIN
        SELECT to_number(lf.val_1)
              ,lf.val_2
              ,lf.val_3
              ,to_number(lf.val_4)
              ,lf.val_5
          INTO v_file_row
          FROM load_file_rows lf
         WHERE lf.load_file_rows_id = par_load_file_rows_id
           AND lf.row_status = pkg_load_file_to_table.get_checked;
      EXCEPTION
        WHEN OTHERS THEN
          set_row_error_status(par_load_file_rows_id
                              ,'������ �� ����� ���� ���������: �������� �� ��������');
          v_continue := FALSE;
      END;
    
      IF v_continue
      THEN
        SELECT p.policy_id
          INTO v_policy_id
          FROM p_pol_header ph
              ,p_policy     p
         WHERE 1 = 1
           AND p.policy_id = ph.last_ver_id
           AND ph.ids = v_file_row.ids;
      
        -- ������ ��� ������������
        BEGIN
          SELECT c.obj_name_orig
            INTO v_insured_fio
            FROM as_insured ai
                ,contact    c
           WHERE ai.insured_contact_id = c.contact_id
             AND ai.policy_id = v_policy_id;
        
          UPDATE load_file_rows lf
             SET lf.val_7 = v_insured_fio
           WHERE lf.load_file_rows_id = par_load_file_rows_id;
        EXCEPTION
          WHEN no_data_found THEN
            NULL;
        END;
      
        -- ����� ������
        SAVEPOINT before_load;
      
        BEGIN
          -- ��������� �������� ������� �� "��������� � �����������"
          doc.set_doc_status(p_doc_id => v_policy_id, p_status_brief => 'QUIT_DECL');
        
          -- �������� ����� ������ �� � �����������
          v_quit_policy_id := pkg_policy.new_policy_version(v_policy_id
                                                           ,NULL
                                                           ,'TO_QUIT'
                                                           ,NULL
                                                           ,SYSDATE);
        
          -- ���������� ������ � ������� ������ ��� �����������
          pkg_policy_quit.add_pol_decline(v_quit_policy_id);
          -- ���������� ������ � ������� "����������� ��������. ������ �� ����������"
          pkg_policy_quit.add_cover_decline(v_quit_policy_id);
        
          -- ����� p_pol_decline_id
          SELECT pd.p_pol_decline_id
            INTO v_pol_decline_id
            FROM p_pol_decline pd
           WHERE pd.p_policy_id = v_quit_policy_id;
        
          -- ���������� ������� �� ��������������/����������
          FOR cover_rec IN cover_curs(v_pol_decline_id)
          LOOP
            pkg_policy_quit.fill_cover_decline_line(v_quit_policy_id
                                                   ,cover_rec.p_cover_decline_id
                                                   ,cover_rec.as_asset_id
                                                   ,cover_rec.t_product_line_id
                                                   ,v_file_row.end_date -- ���� ����������� ��
                                                    );
          END LOOP;
        
          -- �������� �������
          SELECT pp.t_product_conds_id
            INTO v_product_conds_id
            FROM p_policy pp
           WHERE pp.policy_id = v_policy_id;
        
          -- ��� �������
          SELECT ot.reg_code
            INTO v_reg_code
            FROM p_policy_agent_doc ad
                ,document           d
                ,ag_contract_header ch
                ,department         dp
                ,organisation_tree  ot
           WHERE ad.policy_header_id =
                 (SELECT pol_header_id FROM p_policy WHERE policy_id = v_policy_id)
             AND d.document_id = ad.p_policy_agent_doc_id
             AND d.doc_status_ref_id = 2 -- CURRENT
             AND ch.ag_contract_header_id = ad.ag_contract_header_id
             AND dp.department_id = ch.agency_id
             AND ot.organisation_tree_id = dp.org_tree_id;
          IF v_reg_code IS NULL
          THEN
            SELECT o.reg_code
              INTO v_reg_code
              FROM organisation_tree o
                  ,department        d
             WHERE d.org_tree_id = o.organisation_tree_id
               AND d.department_id = (SELECT ph.agency_id
                                        FROM p_pol_header ph
                                            ,p_policy     p
                                       WHERE p.pol_header_id = ph.policy_header_id
                                         AND p.policy_id = v_policy_id);
          END IF;
        
          -- ���������� ������ ������ �� �����������
          UPDATE p_policy
             SET decline_date      = v_file_row.end_date -- ���� ����������� ��
                ,debt_summ         = 0 -- ��������� �� ������, ������������ �� �������
                ,decline_reason_id = v_file_row.purpose_code -- ������� ����������� ��: ��������� �������
                ,return_summ       = 0 -- ����� � �������
           WHERE policy_id = v_quit_policy_id;
        
          UPDATE p_cover_decline cd
             SET cd.redemption_sum      = 0 -- �������� �����
                ,cd.add_invest_income   = 0 -- ���. ������. �����
                ,cd.return_bonus_part   = 0 -- ������� ����� ������
                ,cd.bonus_off_prev      = 0 -- ����������� ������ � �������� ������� ���
                ,cd.bonus_off_current   = 0 -- -- ����������� ������ � �������� ����� ����
                ,cd.admin_expenses      = 0 -- ���������������� ��������
                ,cd.underpayment_actual = 0 -- ��������� �����������
           WHERE cd.p_pol_decline_id = v_pol_decline_id;
        
          UPDATE p_pol_decline
             SET t_product_conds_id    = v_product_conds_id -- �������� �������
                ,other_pol_sum         = 0 -- ����� ������ �� ������ �������
                ,debt_fee_fact         = 0 -- ��������� �����������
                ,medo_cost             = 0 -- ������� �� ����
                ,overpayment           = 0 -- ��������� �� ������ ����������
                ,reg_code              = v_reg_code
                ,issuer_return_sum     = 0 -- ����� � �������� ������������
                ,total_fee_payment_sum = 0
                ,act_date              = v_file_row.start_date -- ���� ����
                ,issuer_return_date    = v_file_row.start_date -- ���� ������� ������������ --313898: FW: ������ ��� �������������� ����������� ��
           WHERE p_pol_decline_id = v_pol_decline_id;
        
          -- ��������� �������� ������� �� "� �����������. ����� ��� ��������"
          doc.set_doc_status(p_doc_id => v_quit_policy_id, p_status_brief => 'TO_QUIT_CHECK_READY');
          -- ��������� �������� ������� �� "� �����������. ��������"
          doc.set_doc_status(p_doc_id => v_quit_policy_id, p_status_brief => 'TO_QUIT_CHECKED');
          -- ��������� �������� ������� �� "���������"
          doc.set_doc_status(p_doc_id => v_quit_policy_id, p_status_brief => 'QUIT');
        
          -- ������ ������� �� �������� ���������� �������� ������
          update_row_load_result(par_load_file_rows_id, '��������� �����������');
          pkg_load_file_to_table.set_row_status(par_load_file_rows_id => par_load_file_rows_id
                                               ,par_row_status        => pkg_load_file_to_table.get_loaded);
        EXCEPTION
          WHEN OTHERS THEN
            -- ������� � ����� ������
            ROLLBACK TO before_load;
            update_row_load_result(par_load_file_rows_id
                                  ,'�� ������� ������ ��� �������� ��� �������� � ������ ����������');
            set_row_error_status(par_load_file_rows_id, SQLERRM);
        END;
      END IF;
    ELSE
      -- �������� ������ ���� �������
      pkg_load_file_to_table.set_row_status(par_load_file_rows_id => par_load_file_rows_id
                                           ,par_row_status        => pkg_load_file_to_table.get_error
                                           ,par_row_comment       => '������������ ���� �� �������� ������������ ��������� � �������� ������');
    END IF;
  END terminate_zero_akt_list;

  /*  
    ������ �., 28.10.2013, 217272 ��������� �������� �������� Contact
    ������ �������� "�������� ����������� Contact"
    ��������� "�������� ������ ������� ����� �������� ������� Contact"
    ��������� ��������
  */
  PROCEDURE check_load_contact_pp(par_load_file_id NUMBER) IS
  BEGIN
    -- �������� ����
    IF safety.check_right_custom(p_obj_id => 'LOAD_T_CONTACT_PP') = 1
    THEN
      -- �������� ��� ������ ��� ����������� � ������� � ��������
      UPDATE load_file_rows
         SET row_status = pkg_load_file_to_table.get_checked
       WHERE load_file_id = par_load_file_id;
    
      -- �������� �� ������������ �� ��
      UPDATE load_file_rows
         SET row_status  = pkg_load_file_to_table.get_error
            ,row_comment = '� ������ ����� ���������� ����� ����� ������ �� ��������� ' || val_1 ||
                           ' � ���� ��Ļ'
       WHERE val_1 IN (SELECT val_1
                         FROM load_file_rows
                        WHERE load_file_id = par_load_file_id
                        GROUP BY val_1
                       HAVING COUNT(*) > 1);
    
      -- �������� �� ������������ �� ��� ������
      UPDATE load_file_rows
         SET row_status  = pkg_load_file_to_table.get_error
            ,row_comment = '� ������ ����� ���������� ����� ����� ������ �� ��������� ' || val_3 ||
                           ' � ���� ���� ������'
       WHERE val_3 IN (SELECT val_3
                         FROM load_file_rows
                        WHERE load_file_id = par_load_file_id
                        GROUP BY val_3
                       HAVING COUNT(*) > 1);
    
    ELSE
      raise_application_error(-20001
                             ,'������������ ���� �� �������� ����������� ������� ������ �������� Contact.');
    END IF;
  END check_load_contact_pp;

  /*  
    ������ �., 28.10.2013, 217272 ��������� �������� �������� Contact
    ������ �������� "�������� ����������� Contact"
    ��������� "�������� ������ ������� ����� �������� ������� Contact"
    ��������� ��������
  */

  PROCEDURE load_contact_pp(par_load_file_id NUMBER) IS
  BEGIN
    -- �������� ����
    IF safety.check_right_custom(p_obj_id => 'LOAD_T_CONTACT_PP') = 1
    THEN
      -- �������� �������� ���� �����
      MERGE INTO t_contact_pp trg
      USING (SELECT lf.val_1  id
                   ,lf.val_2  parent_id
                   ,lf.val_3  pp_code
                   ,lf.val_4  bic
                   ,lf.val_5  NAME
                   ,lf.val_6  city_head
                   ,lf.val_7  address1
                   ,lf.val_8  address2
                   ,lf.val_9  address3
                   ,lf.val_10 address4
                   ,lf.val_11 phone
                   ,lf.val_12 name_rus
                   ,lf.val_13 country
                   ,lf.val_14 deleted
                   ,lf.val_15 city_lat
                   ,lf.val_22 addr_lat
                   ,lf.val_23 contact
                   ,lf.val_24 region
                   ,lf.val_25 is_kfm
                   ,lf.val_26 is_online
                   ,SYSDATE   create_date
                   ,USER      create_user
                   ,SYSDATE   edit_date
                   ,USER      edit_user
               FROM load_file_rows lf
              WHERE lf.load_file_id = par_load_file_id
                AND lf.is_checked = 1
                AND lf.row_status = pkg_load_file_to_table.get_checked) src
      ON (trg.id = src.id)
      WHEN MATCHED THEN
        UPDATE
           SET trg.parent_id = src.parent_id
              ,trg.pp_code   = src.pp_code
              ,trg.bic       = src.bic
              ,trg.name      = src.name
              ,trg.city_head = src.city_head
              ,trg.address1  = src.address1
              ,trg.address2  = src.address2
              ,trg.address3  = src.address3
              ,trg.address4  = src.address4
              ,trg.phone     = src.phone
              ,trg.name_rus  = src.name_rus
              ,trg.country   = src.country
              ,trg.deleted   = src.deleted
              ,trg.city_lat  = src.city_lat
              ,trg.addr_lat  = src.addr_lat
              ,trg.contact   = src.contact
              ,trg.region    = src.region
              ,trg.is_kfm    = src.is_kfm
              ,trg.is_online = src.is_online
              ,trg.edit_date = src.edit_date
              ,trg.edit_user = src.edit_user
      WHEN NOT MATCHED THEN
        INSERT
          (trg.t_contact_pp_id
          ,trg.id
          ,trg.parent_id
          ,trg.pp_code
          ,trg.bic
          ,trg.name
          ,trg.city_head
          ,trg.address1
          ,trg.address2
          ,trg.address3
          ,trg.address4
          ,trg.phone
          ,trg.name_rus
          ,trg.country
          ,trg.deleted
          ,trg.city_lat
          ,trg.addr_lat
          ,trg.contact
          ,trg.region
          ,trg.is_kfm
          ,trg.is_online
          ,trg.create_date
          ,trg.create_user
          ,trg.edit_date
          ,trg.edit_user)
        VALUES
          (sq_t_contact_pp.nextval
          ,src.id
          ,src.parent_id
          ,src.pp_code
          ,src.bic
          ,src.name
          ,src.city_head
          ,src.address1
          ,src.address2
          ,src.address3
          ,src.address4
          ,src.phone
          ,src.name_rus
          ,src.country
          ,src.deleted
          ,src.city_lat
          ,src.addr_lat
          ,src.contact
          ,src.region
          ,src.is_kfm
          ,src.is_online
          ,src.create_date
          ,src.create_user
          ,src.edit_date
          ,src.edit_user);
    
      -- ���������� ������� ������������ ������� �� ������� ��������
      UPDATE load_file_rows
         SET row_status = pkg_load_file_to_table.get_loaded
       WHERE load_file_id = par_load_file_id
         AND is_checked = 1
         AND row_status = pkg_load_file_to_table.get_checked;
    ELSE
      raise_application_error(-20001
                             ,'������������ ���� �� �������� ����������� ������� ������ �������� Contact.');
    END IF;
  END load_contact_pp;

  /* ����������� �., ���� 2014, 328575: ������� ����������� ���� ��� ������� � BI ���.
     ������ �������� "�������� ��������� ������" (ACTUARIAL_DATA)
     ��������� "�������� ���" (ADD_INVEST_INCOME)
     ��������� ��������      
  */
  PROCEDURE check_aii_data
  (
    par_load_file_rows_id NUMBER
   ,par_status            OUT VARCHAR2
   ,par_comment           OUT VARCHAR2
  ) IS
  
    TYPE t_file_row IS RECORD(
       pol_header_id  NUMBER
      ,cover_id       NUMBER
      ,add_income_cur NUMBER
      ,add_income_rur NUMBER
      ,income_date    DATE);
    v_file_row t_file_row;
  
    v_cnt        NUMBER;
    v_start_date DATE;
    v_end_date   DATE;
    v_msg        VARCHAR2(1000);
  BEGIN
    pkg_load_logging.clear_log_by_row_id(par_load_file_rows_id);
    -- �������� ����
    IF safety.check_right_custom(p_obj_id => 'LOAD_ADD_INVEST_INCOME') = 1
    THEN
      SELECT lf.row_comment
            ,lf.row_status
        INTO par_comment
            ,par_status
        FROM load_file_rows lf
       WHERE lf.load_file_rows_id = par_load_file_rows_id;
      IF par_status = pkg_load_file_to_table.get_error
      THEN
        pkg_load_logging.add_error(par_load_file_rows_id    => par_load_file_rows_id
                                  ,par_load_order_num       => pkg_load_file_to_table.get_current_log_load_order_num
                                  ,par_t_load_check_type_id => dml_t_load_check_type.get_id_by_brief('CHECK_FORMAT')
                                  ,par_log_msg              => par_comment
                                  ,par_load_stage           => pkg_load_logging.get_check_single);
      ELSE
        -- �������� ��������������� �������� pkg_load_file_to_table.standard_check_row
      
        -- ������ ����������� ������ � �����
        BEGIN
          SELECT lf.val_1
                ,lf.val_2
                ,to_number(REPLACE(TRIM(lf.val_3), ',', '.')
                          ,'999G999G999G999G999G999G999G999D99999999999999999999999999999'
                          ,'NLS_NUMERIC_CHARACTERS = ''. ''')
                ,to_number(REPLACE(TRIM(lf.val_4), ',', '.')
                          ,'999G999G999G999G999G999G999G999D99999999999999999999999999999'
                          ,'NLS_NUMERIC_CHARACTERS = ''. ''')
                ,lf.val_5
            INTO v_file_row
            FROM load_file_rows lf
           WHERE lf.load_file_rows_id = par_load_file_rows_id;
        EXCEPTION
          WHEN OTHERS THEN
            v_msg       := '������ ��� ������ ������ � ����� ' || chr(13) || chr(10) || SQLERRM;
            par_comment := v_msg || chr(13) || chr(10);
            pkg_load_logging.add_error(par_load_file_rows_id    => par_load_file_rows_id
                                      ,par_load_order_num       => pkg_load_file_to_table.get_current_log_load_order_num
                                      ,par_t_load_check_type_id => dml_t_load_check_type.get_id_by_brief('CHECK_FORMAT')
                                      ,par_log_msg              => v_msg
                                      ,par_load_stage           => pkg_load_logging.get_check_single);
        END;
        IF par_comment IS NULL
        THEN
          -- �������� ���� POL_HEADER_ID �� ������������
          SELECT COUNT(*)
            INTO v_cnt
            FROM p_pol_header ph
           WHERE ph.policy_header_id = v_file_row.pol_header_id;
          IF v_cnt = 0
          THEN
            v_msg       := '������� ����������� POL_HEADER_ID = ' || v_file_row.pol_header_id ||
                           ' �� ������ � �������!';
            par_comment := par_comment || v_msg || chr(13) || chr(10);
          
            pkg_load_logging.add_error(par_load_file_rows_id    => par_load_file_rows_id
                                      ,par_load_order_num       => pkg_load_file_to_table.get_current_log_load_order_num
                                      ,par_t_load_check_type_id => dml_t_load_check_type.get_id_by_brief('CHECK_VALUE')
                                      ,par_log_msg              => v_msg
                                      ,par_load_stage           => pkg_load_logging.get_check_single);
          END IF;
        
          -- �������� ���� COVER_ID, income_date
          BEGIN
            SELECT decode(ph.policy_header_id, NULL, 0, 1)
                  ,ph.start_date
            --                ,c.end_date
              INTO v_cnt
                  ,v_start_date
            --                ,v_end_date
              FROM ins.p_pol_header ph
                  ,ins.p_policy     p
                  ,ins.as_asset     aa
                  ,ins.p_cover      c
             WHERE ph.policy_header_id(+) = v_file_row.pol_header_id
               AND ph.policy_header_id(+) = p.pol_header_id
               AND p.policy_id = aa.p_policy_id
               AND c.as_asset_id = aa.as_asset_id
               AND c.p_cover_id = v_file_row.cover_id;
            IF v_cnt = 0
            THEN
              v_msg       := '�������� COVER_ID = ' || v_file_row.cover_id ||
                             ' �� ������������ �������� ����������� POL_HEADER_ID = ' ||
                             v_file_row.pol_header_id || ' �� ������ ��������!';
              par_comment := par_comment || v_msg || chr(13) || chr(10);
              pkg_load_logging.add_error(par_load_file_rows_id    => par_load_file_rows_id
                                        ,par_load_order_num       => pkg_load_file_to_table.get_current_log_load_order_num
                                        ,par_t_load_check_type_id => dml_t_load_check_type.get_id_by_brief('CHECK_VALUE')
                                        ,par_log_msg              => v_msg
                                        ,par_load_stage           => pkg_load_logging.get_check_single);
            ELSE
              SELECT MAX(p.end_date)
                INTO v_end_date
                FROM ins.p_pol_header   ph
                    ,ins.p_policy       p
                    ,document           d
                    ,ins.doc_status_ref dsr
               WHERE ph.policy_header_id = v_file_row.pol_header_id
                 AND ph.policy_header_id = p.pol_header_id
                 AND d.document_id = p.policy_id
                 AND dsr.doc_status_ref_id = d.doc_status_ref_id
                 AND dsr.brief NOT IN ('CANCEL'); --�� �������
            
              IF v_file_row.income_date NOT BETWEEN v_start_date AND v_end_date
              THEN
                v_msg       := '���� ��� ' || to_char(v_file_row.income_date, 'dd.mm.yyyy') ||
                               ' �� ����������� ������� �������� �������� [' ||
                               to_char(v_start_date, 'dd.mm.yyyy') || ',' ||
                               to_char(v_end_date, 'dd.mm.yyyy') || ']';
                par_comment := par_comment || v_msg || chr(13) || chr(10);
                pkg_load_logging.add_error(par_load_file_rows_id    => par_load_file_rows_id
                                          ,par_load_order_num       => pkg_load_file_to_table.get_current_log_load_order_num
                                          ,par_t_load_check_type_id => dml_t_load_check_type.get_id_by_brief('CHECK_VALUE')
                                          ,par_log_msg              => v_msg
                                          ,par_load_stage           => pkg_load_logging.get_check_single);
              END IF;
            END IF;
          EXCEPTION
            WHEN no_data_found THEN
              v_msg       := '�������� COVER_ID = ' || v_file_row.cover_id || ' �� ������� � �������!';
              par_comment := par_comment || v_msg || chr(13) || chr(10);
              pkg_load_logging.add_error(par_load_file_rows_id    => par_load_file_rows_id
                                        ,par_load_order_num       => pkg_load_file_to_table.get_current_log_load_order_num
                                        ,par_t_load_check_type_id => dml_t_load_check_type.get_id_by_brief('CHECK_VALUE')
                                        ,par_log_msg              => v_msg
                                        ,par_load_stage           => pkg_load_logging.get_check_single);
          END;
        
          -- �������� ���� ADD_INCOME_CUR �� ������������  
          IF v_file_row.add_income_cur < 0
          THEN
            v_msg       := '�������� ���/��� � ������ � ����� �������� �� �������� ���������������!';
            par_comment := par_comment || v_msg || chr(13) || chr(10);
            pkg_load_logging.add_error(par_load_file_rows_id    => par_load_file_rows_id
                                      ,par_load_order_num       => pkg_load_file_to_table.get_current_log_load_order_num
                                      ,par_t_load_check_type_id => dml_t_load_check_type.get_id_by_brief('CHECK_FORMAT')
                                      ,par_log_msg              => v_msg
                                      ,par_load_stage           => pkg_load_logging.get_check_single);
          END IF;
        
          -- �������� ���� ADD_INCOME_RUR �� ������������    
          IF v_file_row.add_income_rur < 0
          THEN
            v_msg       := '�������� ���/��� � ������ � ����� �������� �� �������� ���������������!';
            par_comment := par_comment || v_msg || chr(13) || chr(10);
            pkg_load_logging.add_error(par_load_file_rows_id    => par_load_file_rows_id
                                      ,par_load_order_num       => pkg_load_file_to_table.get_current_log_load_order_num
                                      ,par_t_load_check_type_id => dml_t_load_check_type.get_id_by_brief('CHECK_FORMAT')
                                      ,par_log_msg              => v_msg
                                      ,par_load_stage           => pkg_load_logging.get_check_single);
          END IF;
        
          -- �������� ���� income_date �� ������������    
          IF v_file_row.income_date <> trunc(ADD_MONTHS(v_file_row.income_date, 3), 'Q') - 1
          THEN
            v_msg       := '���� ��� ' || to_char(v_file_row.income_date, 'dd.mm.yyyy') ||
                           ' �� ��������� � ����������� ������ ��������';
            par_comment := par_comment || v_msg || chr(13) || chr(10);
            pkg_load_logging.add_error(par_load_file_rows_id    => par_load_file_rows_id
                                      ,par_load_order_num       => pkg_load_file_to_table.get_current_log_load_order_num
                                      ,par_t_load_check_type_id => dml_t_load_check_type.get_id_by_brief('CHECK_VALUE')
                                      ,par_log_msg              => v_msg
                                      ,par_load_stage           => pkg_load_logging.get_check_single);
          END IF;
        
          -- �������� ������� ��� ����������� ������ 
          SELECT COUNT(*)
            INTO v_cnt
            FROM p_add_invest_income aii
                ,p_cover             c
                ,as_asset            a
                ,t_prod_line_option  plo
                ,as_assured          su
                ,contact             co
           WHERE aii.pol_header_id = v_file_row.pol_header_id
             AND aii.income_date = v_file_row.income_date
             AND c.p_cover_id = v_file_row.cover_id
             AND c.as_asset_id = a.as_asset_id
             AND a.as_asset_id = su.as_assured_id
             AND su.assured_contact_id = co.contact_id
             AND nvl(aii.as_asset_name, ' ') = nvl(co.obj_name_orig, ' ')
             AND c.t_prod_line_option_id = plo.id
             AND plo.product_line_id = aii.t_product_line_id;
          IF v_cnt > 0
          THEN
            v_msg       := '�� ���� ' || to_char(v_file_row.income_date, 'dd.mm.yyyy') ||
                           ' ������ ��� ��� ���������!';
            par_comment := par_comment || v_msg || chr(13) || chr(10);
            pkg_load_logging.add_error(par_load_file_rows_id    => par_load_file_rows_id
                                      ,par_load_order_num       => pkg_load_file_to_table.get_current_log_load_order_num
                                      ,par_t_load_check_type_id => dml_t_load_check_type.get_id_by_brief('CHECK_UNIQUE')
                                      ,par_log_msg              => v_msg
                                      ,par_load_stage           => pkg_load_logging.get_check_single);
          END IF;
        END IF;
      END IF;
    ELSE
      -- �������� ������ ���� �������
      par_comment := '������������ ���� �� �������� ���';
      pkg_load_logging.add_error(par_load_file_rows_id    => par_load_file_rows_id
                                ,par_load_order_num       => pkg_load_file_to_table.get_current_log_load_order_num
                                ,par_t_load_check_type_id => dml_t_load_check_type.get_id_by_brief('CHECK_RIGHT')
                                ,par_log_msg              => par_comment
                                ,par_load_stage           => pkg_load_logging.get_check_single);
    END IF;
  
    IF par_comment IS NOT NULL
    THEN
      par_status := pkg_load_file_to_table.get_error;
    ELSE
      par_status := pkg_load_file_to_table.get_checked;
    END IF;
  
  END check_aii_data;

  /* ����������� �., ���� 2014, 328575: ������� ����������� ���� ��� ������� � BI ���.
     ������ �������� "�������� ��������� ������" (ACTUARIAL_DATA)
     ��������� "�������� ���" (ADD_INVEST_INCOME)
     ��������� ��������      
  */
  PROCEDURE load_aii_data(par_load_file_rows_id NUMBER) IS
    TYPE t_file_row IS RECORD(
       pol_header_id  NUMBER
      ,cover_id       NUMBER
      ,add_income_cur NUMBER
      ,add_income_rur NUMBER
      ,income_date    DATE);
    v_file_row t_file_row;
    v_p_aii_id NUMBER;
    v_msg      VARCHAR2(1000);
  
    -- ��������� ������� ������ ��� ����������� ������
    PROCEDURE set_row_error_status(par_comment VARCHAR2) IS
    BEGIN
      pkg_load_file_to_table.set_row_status(par_load_file_rows_id => par_load_file_rows_id
                                           ,par_row_status        => pkg_load_file_to_table.get_error
                                           ,par_row_comment       => par_comment
                                           ,par_is_checked        => 0 -- ������ ������� �� ������
                                            );
    END set_row_error_status;
  
  BEGIN
    -- �������� ����
    IF safety.check_right_custom(p_obj_id => 'LOAD_ADD_INVEST_INCOME') = 1
    THEN
      SAVEPOINT before_load;
      -- ������ ����������� ������ � �����
      BEGIN
        SELECT lf.val_1
              ,lf.val_2
              ,to_number(REPLACE(lf.val_3, ',', '.')
                        ,'999G999G999G999G999G999G999G999D99999999999999999999999999999'
                        ,'NLS_NUMERIC_CHARACTERS = ''. ''')
              ,to_number(REPLACE(lf.val_4, ',', '.')
                        ,'999G999G999G999G999G999G999G999D99999999999999999999999999999'
                        ,'NLS_NUMERIC_CHARACTERS = ''. ''')
              ,lf.val_5
          INTO v_file_row
          FROM load_file_rows lf
         WHERE lf.load_file_rows_id = par_load_file_rows_id
           AND lf.row_status = pkg_load_file_to_table.get_checked;
      EXCEPTION
        WHEN OTHERS THEN
          v_msg := '������ �� ����� ���� ���������: �������� �� ��������';
          set_row_error_status(v_msg);
          pkg_load_logging.add_error(par_load_file_rows_id    => par_load_file_rows_id
                                    ,par_load_order_num       => pkg_load_file_to_table.get_current_log_load_order_num
                                    ,par_t_load_check_type_id => dml_t_load_check_type.get_id_by_brief('UNDEFINED_GROUP')
                                    ,par_log_msg              => v_msg
                                    ,par_load_stage           => pkg_load_logging.get_process);
          RETURN;
      END;
    
      BEGIN
        SELECT sq_p_add_invest_income.nextval INTO v_p_aii_id FROM dual;
      
        INSERT INTO p_add_invest_income
          (p_add_invest_income_id
          ,pol_header_id
          ,t_product_line_id
          ,as_asset_name
          ,add_income_cur
          ,add_income_rur
          ,income_date)
          SELECT v_p_aii_id
                ,v_file_row.pol_header_id
                ,plo.product_line_id
                ,co.obj_name_orig
                ,v_file_row.add_income_cur
                ,v_file_row.add_income_rur
                ,v_file_row.income_date
            FROM p_cover            pc
                ,as_asset           se
                ,t_prod_line_option plo
                ,as_assured         su
                ,contact            co
           WHERE pc.p_cover_id = v_file_row.cover_id
             AND pc.as_asset_id = se.as_asset_id
             AND su.assured_contact_id = co.contact_id
             AND pc.t_prod_line_option_id = plo.id
             AND se.as_asset_id = su.as_assured_id;
      
        pkg_load_file_to_table.set_row_status(par_load_file_rows_id => par_load_file_rows_id
                                             ,par_row_status        => pkg_load_file_to_table.get_loaded
                                             ,par_row_comment       => '��� ��������'
                                             ,par_is_checked        => 1);
      EXCEPTION
        WHEN OTHERS THEN
          v_msg := '������ �� ����� ���� ���������: ' || SQLERRM;
          set_row_error_status(v_msg);
          pkg_load_logging.add_error(par_load_file_rows_id    => par_load_file_rows_id
                                    ,par_load_order_num       => pkg_load_file_to_table.get_current_log_load_order_num
                                    ,par_t_load_check_type_id => dml_t_load_check_type.get_id_by_brief('UNDEFINED_GROUP')
                                    ,par_log_msg              => v_msg
                                    ,par_load_stage           => pkg_load_logging.get_process);
          ROLLBACK TO before_load;
      END;
    ELSE
      -- �������� ������ ���� �������
      v_msg := '������������ ���� �� �������� ���';
      set_row_error_status(v_msg);
      pkg_load_logging.add_error(par_load_file_rows_id    => par_load_file_rows_id
                                ,par_load_order_num       => pkg_load_file_to_table.get_current_log_load_order_num
                                ,par_t_load_check_type_id => dml_t_load_check_type.get_id_by_brief('CHECK_RIGHT')
                                ,par_log_msg              => v_msg
                                ,par_load_stage           => pkg_load_logging.get_process);
    END IF;
  END load_aii_data;

  /*
  �������� ��� �������� �������� mPos
  ������ �. 24.09.2014
  */
  PROCEDURE check_mpos_payment
  (
    par_load_file_rows_id NUMBER
   ,par_status            OUT VARCHAR2
   ,par_comment           OUT VARCHAR2
  ) IS
    vc_error_message CONSTANT VARCHAR2(100) := '��� ���� ������� ��� �������� �������� mPos';
  BEGIN
    IF safety.check_right_custom('LOAD_MPOS_PAYMENT') = 0
    THEN
      UPDATE load_file_rows fr
         SET row_status  = pkg_load_file_to_table.get_error
            ,row_comment = vc_error_message
       WHERE fr.load_file_rows_id = par_load_file_rows_id
         AND fr.row_status NOT IN
             (pkg_load_file_to_table.get_loaded, pkg_load_file_to_table.get_part_loaded);
      par_status  := pkg_load_file_to_table.get_error;
      par_comment := vc_error_message;
    ELSE
      par_status := pkg_load_file_to_table.get_checked;
    END IF;
  END check_mpos_payment;

  /*
  �������� �������� mPos
  ������ �. 18.09.2014
  */
  PROCEDURE load_mpos_payment(par_load_file_rows_id load_file_rows.load_file_rows_id%TYPE) IS
    ex_get_row_values EXCEPTION;
    vc_refuse CONSTANT VARCHAR2(100) := '��������'; --������ �������, ������� ��������� � ������
  
    TYPE t_mpos_payment IS RECORD(
       transaction_id    mpos_writeoff_notice.transaction_id%TYPE
      ,cliche            mpos_writeoff_notice.cliche%TYPE
      ,tid               NUMBER
      ,transaction_date  mpos_writeoff_notice.transaction_date%TYPE
      ,card_number       mpos_writeoff_notice.card_number%TYPE
      ,card_type         VARCHAR2(100)
      ,amount            mpos_writeoff_notice.amount%TYPE
      ,account           NUMBER
      ,authcode          VARCHAR2(100)
      ,rrn               mpos_writeoff_notice.rrn%TYPE
      ,processing_result mpos_writeoff_notice.processing_result%TYPE
      ,processing_status mpos_writeoff_notice.processing_status%TYPE
      ,device_name       mpos_writeoff_notice.device_name%TYPE
      ,insurance_product VARCHAR2(250)
      ,policy_number     mpos_writeoff_notice.processing_policy_number%TYPE);
    vr_mpos_payment t_mpos_payment;
    v_load_file_id  load_file_rows.load_file_id%TYPE;
  
    /*�������� ������ ������ �����*/
    FUNCTION get_row_values RETURN t_mpos_payment IS
      vr_mpos_payment t_mpos_payment;
    BEGIN
      vr_mpos_payment.transaction_id   := pkg_load_file_to_table.get_value_by_brief('ID');
      vr_mpos_payment.cliche           := pkg_load_file_to_table.get_value_by_brief('MID');
      vr_mpos_payment.tid              := pkg_load_file_to_table.get_value_by_brief('TID');
      vr_mpos_payment.transaction_date := to_date(pkg_load_file_to_table.get_value_by_brief('CREATED_DATE')
                                                 ,'DD.MM.RRRR HH24:MI');
      vr_mpos_payment.card_number      := pkg_load_file_to_table.get_value_by_brief('CARD_NUMBER');
    
      vr_mpos_payment.card_type         := pkg_load_file_to_table.get_value_by_brief('CARD_TYPE');
      vr_mpos_payment.amount            := pkg_load_file_to_table.get_value_by_brief('AMOUNT');
      vr_mpos_payment.account           := pkg_load_file_to_table.get_value_by_brief('ACCOUNT');
      vr_mpos_payment.authcode          := pkg_load_file_to_table.get_value_by_brief('AUTHCODE');
      vr_mpos_payment.rrn               := pkg_load_file_to_table.get_value_by_brief('RRN');
      vr_mpos_payment.processing_result := pkg_load_file_to_table.get_value_by_brief('GATEWAY_RETURN_CODE');
      vr_mpos_payment.processing_status := pkg_load_file_to_table.get_value_by_brief('STATUS');
      vr_mpos_payment.device_name       := pkg_load_file_to_table.get_value_by_brief('DEVICE');
      vr_mpos_payment.insurance_product := pkg_load_file_to_table.get_value_by_brief('INSURANCE_PRODUCT');
      vr_mpos_payment.policy_number     := regexp_substr(pkg_load_file_to_table.get_value_by_brief('CONTRACT_NUMBER')
                                                        ,'\d+'); --����� ������ ����� (���� �������� � ��������� ������ �� MySQL)
    
      RETURN vr_mpos_payment;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE ex_get_row_values;
    END get_row_values;
  
    /*��������, ��� ������ ������������� ����� ���������*/
    FUNCTION is_need_load(par_mpos_payment IN t_mpos_payment) RETURN BOOLEAN IS
      v_is_need_load BOOLEAN := TRUE;
    
      FUNCTION is_already_loaded RETURN BOOLEAN IS
        v_is_already_loaded BOOLEAN := FALSE;
        v_is_exist          NUMBER;
      BEGIN
        SELECT COUNT(1)
          INTO v_is_exist
          FROM dual
         WHERE EXISTS (SELECT NULL
                  FROM mpos_writeoff_notice wn
                 WHERE wn.transaction_id = par_mpos_payment.transaction_id);
      
        IF v_is_exist = 1
        THEN
          v_is_already_loaded := TRUE;
        ELSE
          /*��������� �� ������ �������*/
          SELECT COUNT(1)
            INTO v_is_exist
            FROM dual
           WHERE EXISTS (SELECT NULL
                    FROM mpos_payment_notice wn
                   WHERE wn.transaction_id = par_mpos_payment.transaction_id);
          IF v_is_exist = 1
          THEN
            v_is_already_loaded := TRUE;
          END IF;
        END IF;
      
        RETURN v_is_already_loaded;
      END is_already_loaded;
    
      /*��������, ��� ������ ������������� ����� ���������*/
      FUNCTION exist_this_day RETURN BOOLEAN IS
        v_exist_this_day BOOLEAN := FALSE;
        v_count          NUMBER;
      BEGIN
        SELECT COUNT(1)
          INTO v_count
          FROM dual
         WHERE EXISTS (SELECT NULL
                  FROM ven_mpos_writeoff_form wn
                      ,doc_status_ref         dsr
                 WHERE wn.policy_number = par_mpos_payment.policy_number
                   AND wn.amount = par_mpos_payment.amount
                   AND trunc(wn.transaction_date) = trunc(par_mpos_payment.transaction_date)
                   AND substr(wn.card_number, -4) = substr(par_mpos_payment.card_number, -4)
                   AND wn.doc_status_ref_id = dsr.doc_status_ref_id
                   AND dsr.brief = 'CONFIRMED' /*�����������*/
                );
      
        IF v_count = 1
        THEN
          v_exist_this_day := TRUE;
        ELSE
          /*��������� �� ������ �������*/
          SELECT COUNT(1)
            INTO v_count
            FROM dual
           WHERE EXISTS (SELECT NULL
                    FROM ven_mpos_payment_notice wn
                        ,doc_status_ref          dsr
                   WHERE wn.policy_number = par_mpos_payment.policy_number
                     AND wn.amount = par_mpos_payment.amount
                     AND trunc(wn.transaction_date) = trunc(par_mpos_payment.transaction_date)
                     AND substr(wn.card_number, -4) = substr(par_mpos_payment.card_number, -4)
                     AND wn.doc_status_ref_id = dsr.doc_status_ref_id
                     AND dsr.brief = 'LOADED' /*��������*/
                  );
          IF v_count = 1
          THEN
            v_exist_this_day := TRUE;
          END IF;
        END IF;
      
        RETURN v_exist_this_day;
      END exist_this_day;
    
    BEGIN
      --1. �������� �������
      IF par_mpos_payment.processing_status != vc_refuse /*��������� ������ ����������� �������*/
      THEN
        v_is_need_load := FALSE;
      END IF;
    
      --2. �� ��������� ��� ����������� ����������
      IF is_already_loaded
      THEN
        v_is_need_load := FALSE;
      END IF;
    
      --3. � ������ ������� ����������� � ���� ���� �� ������ ���� �������� ��������
      IF exist_this_day
      THEN
        v_is_need_load := FALSE;
      END IF;
    
      RETURN v_is_need_load;
    END is_need_load;
  
    /*�������� ���������� � �������*/
    PROCEDURE load_payment(par_mpos_payment IN t_mpos_payment) IS
      vr_mpos_writeoff_notice dml_mpos_writeoff_notice.tt_mpos_writeoff_notice;
      vr_mpos_writeoff_form   dml_mpos_writeoff_form.tt_mpos_writeoff_form;
      v_mpos_writeoff_form_id mpos_writeoff_form.mpos_writeoff_form_id%TYPE;
      v_t_payment_system_id   t_payment_system.t_payment_system_id%TYPE;
    
      -- Author  : ������ �.
      -- Created : 19.09.2014 11:18:32
      -- Purpose : ��������� ������� ���������
      PROCEDURE set_writeoff_notice_status
      (
        par_mpos_writeoff_notice_id mpos_writeoff_notice.mpos_writeoff_notice_id%TYPE
       ,par_work_status             mpos_writeoff_notice.work_status%TYPE
      ) IS
      BEGIN
      
        IF par_work_status = pkg_mpos.gc_work_status_processed /*���������*/
        THEN
          doc.set_doc_status(p_doc_id       => par_mpos_writeoff_notice_id
                            ,p_status_brief => 'REFUSE' /*�����*/);
        ELSE
          doc.set_doc_status(p_doc_id       => par_mpos_writeoff_notice_id
                            ,p_status_brief => 'PROJECT' /*������*/);
        END IF;
      
      END set_writeoff_notice_status;
    
    BEGIN
      /*����� ����������� � �������� �������������� ��������*/
      v_mpos_writeoff_form_id                          := pkg_mpos.get_writeoff_form_by_refuse(par_policy_number    => par_mpos_payment.policy_number
                                                                                              ,par_transaction_date => par_mpos_payment.transaction_date
                                                                                              ,par_amount           => par_mpos_payment.amount
                                                                                              ,par_card_number      => par_mpos_payment.card_number);
      vr_mpos_writeoff_form                            := dml_mpos_writeoff_form.get_record(par_mpos_writeoff_form_id => v_mpos_writeoff_form_id);
      v_t_payment_system_id                            := dml_t_payment_system.get_id_by_brief(upper(par_mpos_payment.card_type));
      vr_mpos_writeoff_notice.mpos_writeoff_form_id    := v_mpos_writeoff_form_id;
      vr_mpos_writeoff_notice.transaction_id           := par_mpos_payment.transaction_id;
      vr_mpos_writeoff_notice.amount                   := par_mpos_payment.amount;
      vr_mpos_writeoff_notice.writeoff_number          := 0; --���������� ����� ��������
      vr_mpos_writeoff_notice.transaction_date         := par_mpos_payment.transaction_date; --���� �������� ����������
      vr_mpos_writeoff_notice.description              := par_mpos_payment.policy_number || ' ' ||
                                                          vr_mpos_writeoff_form.insured_name;
      vr_mpos_writeoff_notice.rrn                      := par_mpos_payment.rrn;
      vr_mpos_writeoff_notice.t_payment_system_id      := v_t_payment_system_id;
      vr_mpos_writeoff_notice.cliche                   := par_mpos_payment.cliche;
      vr_mpos_writeoff_notice.card_number              := par_mpos_payment.card_number;
      vr_mpos_writeoff_notice.device_name              := par_mpos_payment.device_name;
      vr_mpos_writeoff_notice.reg_date                 := SYSDATE;
      vr_mpos_writeoff_notice.processing_result        := par_mpos_payment.processing_result;
      vr_mpos_writeoff_notice.processing_policy_number := par_mpos_payment.policy_number;
      vr_mpos_writeoff_notice.work_status              := pkg_mpos.get_work_status(par_mpos_writeoff_form_id => v_mpos_writeoff_form_id
                                                                                  ,par_processing_result     => par_mpos_payment.processing_result);
      vr_mpos_writeoff_notice.t_mpos_result_id         := dml_t_mpos_result.get_id_by_result_code(pkg_mpos.get_result_code(par_mpos_payment.processing_result)
                                                                                                 ,par_raise_on_error => FALSE);
      dml_mpos_writeoff_notice.insert_record(vr_mpos_writeoff_notice);
    
      --���������� ������ � ����������� �� "������� ���������"
      set_writeoff_notice_status(par_mpos_writeoff_notice_id => vr_mpos_writeoff_notice.mpos_writeoff_notice_id
                                ,par_work_status             => vr_mpos_writeoff_notice.work_status);
    
    END load_payment;
  BEGIN
  
    /*�������� ������*/
    pkg_load_file_to_table.cache_row(par_load_file_rows_id);
  
    /*��������� ������ �������*/
    vr_mpos_payment := get_row_values;
  
    /*��������, ��� ������ ����� ���������*/
    IF is_need_load(par_mpos_payment => vr_mpos_payment)
    THEN
      /*��������� ���������� � �������*/
      load_payment(par_mpos_payment => vr_mpos_payment);
    END IF;
    /*�������� ������ ��� ������������*/
    pkg_load_file_to_table.set_current_row_status(par_row_status => pkg_load_file_to_table.get_loaded);
  
  EXCEPTION
    WHEN ex_get_row_values THEN
      /*������ ��� �������������� ������*/
      pkg_load_file_to_table.set_current_row_status(par_row_status  => pkg_load_file_to_table.get_error
                                                   ,par_row_comment => '�� ������� ��������� �������� ����� �����');
    WHEN OTHERS THEN
      /*�������� ������ ��� ���������*/
      pkg_load_file_to_table.set_current_row_status(par_row_status  => pkg_load_file_to_table.get_error
                                                   ,par_row_comment => SQLERRM);
  END load_mpos_payment;

  PROCEDURE check_prod_coef
  (
    par_load_file_rows_id NUMBER
   ,par_status            OUT VARCHAR2
   ,par_comment           OUT VARCHAR2
  ) IS
    v_prod_coef_brief VARCHAR2(32767);
    v_prod_coef_rec   dml_t_prod_coef_type.tt_t_prod_coef_type;
  BEGIN
  
    IF safety.check_right_custom('UNIVERSAL_LOADER_LOAD_PROD_COEF') = 0
    THEN
      par_status  := pkg_load_file_to_table.get_error;
      par_comment := '������������ ����';
      RETURN;
    END IF;
  
    v_prod_coef_brief := pkg_load_file_to_table.get_value_string(par_brief => 'PROD_COEF_BRIEF');
  
    BEGIN
      v_prod_coef_rec := dml_t_prod_coef_type.get_rec_by_brief(par_brief => v_prod_coef_brief);
    
      IF dml_func_define_type.get_record(v_prod_coef_rec.func_define_type_id).brief = 'TABLE_OF_VALUES'
      THEN
        par_status := pkg_load_file_to_table.get_checked;
      ELSE
        par_status  := pkg_load_file_to_table.get_error;
        par_comment := '������ �� �������� ���������';
      END IF;
    
    EXCEPTION
      WHEN ex.no_data_found THEN
        par_status  := pkg_load_file_to_table.get_error;
        par_comment := '�� ������� ��������� ������� �� ����� ' || nvl(v_prod_coef_brief, 'NULL');
    END;
  
  END check_prod_coef;

  PROCEDURE load_prod_coef(par_load_file_rows_id NUMBER) IS
    TYPE typ_prod_coef IS RECORD(
       brief       VARCHAR2(4000)
      ,VALUE       NUMBER
      ,criteria_1  NUMBER
      ,criteria_2  NUMBER
      ,criteria_3  NUMBER
      ,criteria_4  NUMBER
      ,criteria_5  NUMBER
      ,criteria_6  NUMBER
      ,criteria_7  NUMBER
      ,criteria_8  NUMBER
      ,criteria_9  NUMBER
      ,criteria_10 NUMBER);
  
    vr_prod_coef typ_prod_coef;
  BEGIN
		
    IF safety.check_right_custom('UNIVERSAL_LOADER_LOAD_PROD_COEF') = 0
    THEN
			ex.raise_custom('������������ ����');
    END IF;
  
    vr_prod_coef.brief       := pkg_load_file_to_table.get_value_string(par_brief => 'PROD_COEF_BRIEF');
    vr_prod_coef.value       := pkg_load_file_to_table.get_value_number(par_brief => 'VALUE');
    vr_prod_coef.criteria_1  := pkg_load_file_to_table.get_value_number(par_brief => 'CRITERIA_1');
    vr_prod_coef.criteria_2  := pkg_load_file_to_table.get_value_number(par_brief => 'CRITERIA_2');
    vr_prod_coef.criteria_3  := pkg_load_file_to_table.get_value_number(par_brief => 'CRITERIA_3');
    vr_prod_coef.criteria_4  := pkg_load_file_to_table.get_value_number(par_brief => 'CRITERIA_4');
    vr_prod_coef.criteria_5  := pkg_load_file_to_table.get_value_number(par_brief => 'CRITERIA_5');
    vr_prod_coef.criteria_6  := pkg_load_file_to_table.get_value_number(par_brief => 'CRITERIA_6');
    vr_prod_coef.criteria_7  := pkg_load_file_to_table.get_value_number(par_brief => 'CRITERIA_7');
    vr_prod_coef.criteria_8  := pkg_load_file_to_table.get_value_number(par_brief => 'CRITERIA_8');
    vr_prod_coef.criteria_9  := pkg_load_file_to_table.get_value_number(par_brief => 'CRITERIA_9');
    vr_prod_coef.criteria_10 := pkg_load_file_to_table.get_value_number(par_brief => 'CRITERIA_10');
  
    pkg_prod_coef.add_prod_coef(par_prod_coef_type_brief => vr_prod_coef.brief
                               ,par_value                => vr_prod_coef.value
                               ,par_criteria_1           => vr_prod_coef.criteria_1
                               ,par_criteria_2           => vr_prod_coef.criteria_2
                               ,par_criteria_3           => vr_prod_coef.criteria_3
                               ,par_criteria_4           => vr_prod_coef.criteria_4
                               ,par_criteria_5           => vr_prod_coef.criteria_5
                               ,par_criteria_6           => vr_prod_coef.criteria_6
                               ,par_criteria_7           => vr_prod_coef.criteria_7
                               ,par_criteria_8           => vr_prod_coef.criteria_8
                               ,par_criteria_9           => vr_prod_coef.criteria_9
                               ,par_criteria_10          => vr_prod_coef.criteria_10);
  
    pkg_load_file_to_table.set_current_row_status(par_row_status => pkg_load_file_to_table.get_loaded);
  EXCEPTION
    WHEN OTHERS THEN
      /*�������� ������ ��� ���������*/
      pkg_load_file_to_table.set_current_row_status(par_row_status  => pkg_load_file_to_table.get_error
                                                   ,par_row_comment => SQLERRM);
    
  END load_prod_coef;

END pkg_universal_loader;
/

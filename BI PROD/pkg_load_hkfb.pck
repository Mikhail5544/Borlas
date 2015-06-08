CREATE OR REPLACE PACKAGE pkg_load_hkfb IS

  -- Author  : ������ �.
  -- Created : 20.10.2014 
  -- Purpose : �������� ������� ����������� ���� ����� ������������� ���������
  /*�������� ������������ ���������*/
  FUNCTION is_unique
  (
    par_policy_number       decline_journal_hkfb.policy_number%TYPE
   ,par_decline_notice_date decline_journal_hkfb.decline_notice_date%TYPE
  ) RETURN BOOLEAN;

  /*�������� ��������*/
  PROCEDURE check_load_decline_journal(par_load_file_id load_file.load_file_id%TYPE);
  /*��������� ��������*/
  PROCEDURE load_decline_journal(par_load_file_id load_file.load_file_id%TYPE);

  /*���������� ������� ��������� ������� �� ���������� �� �����������*/
  PROCEDURE cancel_hkf_control;

  /*���������� ������� ��������� ������� �� �������������� ���������� �� �����������*/
  PROCEDURE refusal_not_processed;

END pkg_load_hkfb;
/
CREATE OR REPLACE PACKAGE BODY pkg_load_hkfb IS

  /*�������� ������������ ���������*/
  FUNCTION is_unique
  (
    par_policy_number       decline_journal_hkfb.policy_number%TYPE
   ,par_decline_notice_date decline_journal_hkfb.decline_notice_date%TYPE
  ) RETURN BOOLEAN IS
    v_is_unique NUMBER;
  BEGIN
    SELECT COUNT(*)
      INTO v_is_unique
      FROM dual
     WHERE EXISTS (SELECT NULL
              FROM ven_decline_journal_hkfb v
             WHERE v.policy_number = par_policy_number
               AND v.decline_notice_date = par_decline_notice_date
               AND v.doc_status_ref_id != dml_doc_status_ref.get_id_by_brief('CANCEL'));
    RETURN v_is_unique = 0;
  END is_unique;

  /*�������� ��������*/
  PROCEDURE check_load_decline_journal(par_load_file_id load_file.load_file_id%TYPE) IS
  BEGIN
    NULL;
  END check_load_decline_journal;

  /*��������� ��������*/
  PROCEDURE load_decline_journal(par_load_file_id load_file.load_file_id%TYPE) IS
    policy_not_found  EXCEPTION;
    too_many_policies EXCEPTION;
  
    /*������� ���������*/
    gc_reason_decline98 CONSTANT VARCHAR2(50) := '����������� 98%';
    gc_reason_pdp       CONSTANT VARCHAR2(50) := '���';
    gc_reason_cooling   CONSTANT VARCHAR2(50) := '������ ����������';
  
    /*������ ������������ �����*/
    TYPE typ_decline_journal_hkfb IS RECORD(
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
      ,bank_notice               decline_journal_hkfb.bank_notice%TYPE
      ,status                    load_file_rows.val_1%TYPE);
    -- �� ����������� ������
    gv_load_file_rows_id load_file_rows.load_file_rows_id%TYPE;
    vr_load_row          typ_decline_journal_hkfb;
    v_file_name          load_file.file_name%TYPE;
    vr_policy            p_policy%ROWTYPE;
    vr_p_pol_header      dml_p_pol_header.tt_p_pol_header;
    vr_p_policy          dml_p_policy.tt_p_policy;
    v_decision           VARCHAR2(10);
  
    c_decision_refusal CONSTANT VARCHAR2(30) := '�����';
    c_decision_error   CONSTANT VARCHAR2(30) := '������';
  
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
  
    -- ������� ���������� �������� ����������� ������, ����������� �� ������
    FUNCTION get_row_values RETURN typ_decline_journal_hkfb IS
      vr_load_row typ_decline_journal_hkfb;
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
      vr_load_row.bank_return_amount        := pkg_load_file_to_table.get_value_by_brief('BANK_RETURN_AMOUNT');
      vr_load_row.bank_return_ag_amount     := pkg_load_file_to_table.get_value_by_brief('BANK_RETURN_AG_AMOUNT');
      vr_load_row.bank_return_rko_amount    := pkg_load_file_to_table.get_value_by_brief('BANK_RETURN_RKO_AMOUNT');
      vr_load_row.decision                  := pkg_load_file_to_table.get_value_by_brief('DECISION');
      vr_load_row.decline_note              := pkg_load_file_to_table.get_value_by_brief('DECLINE_NOTE');
      vr_load_row.company_return_amount     := pkg_load_file_to_table.get_value_by_brief('COMPANY_RETURN_AMOUNT');
      vr_load_row.company_return_ag_amount  := pkg_load_file_to_table.get_value_by_brief('COMPANY_RETURN_AG_AMOUNT');
      vr_load_row.company_return_rko_amount := pkg_load_file_to_table.get_value_by_brief('COMPANY_RETURN_RKO_AMOUNT');
      vr_load_row.registration_date         := pkg_load_file_to_table.get_value_by_brief('REGISTRATION_DATE');
      vr_load_row.responsible               := pkg_load_file_to_table.get_value_by_brief('RESPONSIBLE');
      vr_load_row.product_name              := pkg_load_file_to_table.get_value_by_brief('PRODUCT_NAME');
      vr_load_row.bank_notice               := pkg_load_file_to_table.get_value_by_brief('BANK_NOTICE');
      vr_load_row.bank_notice               := pkg_load_file_to_table.get_value_by_brief('STATUS');
    
      RETURN vr_load_row;
    END get_row_values;
  
    /*�������� ��������� �� �����*/
    PROCEDURE load_decline_notice IS
      v_notice_from_journal_id decline_journal_hkfb.decline_journal_hkfb_id%TYPE;
    
      /*����� ��������� �� ������ �� � ���� ���������*/
      FUNCTION find_notice_in_journal
      (
        par_policy_number       decline_journal_hkfb.policy_number%TYPE
       ,par_decline_notice_date decline_journal_hkfb.decline_notice_date%TYPE
      ) RETURN decline_journal_hkfb.decline_journal_hkfb_id%TYPE IS
        v_decline_journal_hkfb decline_journal_hkfb.decline_journal_hkfb_id%TYPE;
      BEGIN
        SELECT d.decline_journal_hkfb_id
          INTO v_decline_journal_hkfb
          FROM ven_decline_journal_hkfb d
         WHERE d.policy_number = par_policy_number
           AND d.decline_notice_date = par_decline_notice_date
           AND d.doc_status_ref_id != dml_doc_status_ref.get_id_by_brief('CANCEL');
        RETURN v_decline_journal_hkfb;
      EXCEPTION
        WHEN no_data_found THEN
          RETURN NULL;
        WHEN too_many_rows THEN
          ex.raise('������� ��������� ������������ ��������� �� ������ ��=' || par_policy_number ||
                   ' � ���� ��������� ' || to_char(par_decline_notice_date, 'dd.mm.rrrr'));
      END find_notice_in_journal;
    
      /*���������� ������ � ������ ���������*/
      PROCEDURE insert_notice_in_journal IS
        v_decline_journal_hkfb_id decline_journal_hkfb.decline_journal_hkfb_id%TYPE;
        /*���������� ������, � ������� ����� ��������� ���������*/
        FUNCTION define_notice_status RETURN doc_status_ref.brief%TYPE IS
          v_status_brief doc_status_ref.brief%TYPE;
          vr_stsatus     dml_doc_status_ref.tt_doc_status_ref;
        BEGIN
          /*�������� ��������� � ������� ��������� � ���� ������� ������������ �����*/
          IF vr_load_row.status IS NOT NULL
          THEN
          
            vr_stsatus     := dml_doc_status_ref.get_rec_by_name(par_name           => vr_load_row.status
                                                                ,par_raise_on_error => TRUE);
            v_status_brief := vr_stsatus.brief;
          ELSE
            /*����������� � �� � ���� � ���� �������� ���������� ������� ������� �������� ������������ 98%�*/
            IF vr_load_row.application_reason = gc_reason_decline98
            THEN
              v_status_brief := 'BRAKE_IN_COMPANY'; --����������� � ��
            ELSIF vr_load_row.application_reason IS NULL
                  OR vr_load_row.application_reason IN (gc_reason_pdp, gc_reason_cooling)
            THEN
              v_status_brief := 'NEW'; --�����
            END IF; --����� ���� ������� ���������
          END IF; --����� ���� ������ ��������
        
          RETURN v_status_brief;
        END define_notice_status;
      BEGIN
        dml_decline_journal_hkfb.insert_record(par_insured_name              => vr_load_row.insured_name
                                              ,par_policy_number             => vr_load_row.policy_number
                                              ,par_doc_templ_id              => doc.templ_id_by_brief('DECLINE_JOURNAL_HKFB')
                                              ,par_reg_date                  => SYSDATE
                                              ,par_registry_name             => v_file_name
                                              ,par_recieve_date              => vr_load_row.recieve_date
                                              ,par_notice_date               => vr_load_row.notice_date
                                              ,par_policy_start_date         => vr_load_row.policy_start_date
                                              ,par_days_of_credit            => vr_load_row.days_of_credit
                                              ,par_credit_end_date           => vr_load_row.credit_end_date
                                              ,par_home_phone                => vr_load_row.home_phone
                                              ,par_cell_phone                => vr_load_row.cell_phone
                                              ,par_decline_notice_date       => vr_load_row.decline_notice_date
                                              ,par_payment_generated         => vr_load_row.payment_generated
                                              ,par_application_place         => vr_load_row.application_place
                                              ,par_is_hkfb_account           => vr_load_row.is_hkfb_account
                                              ,par_bank_bik                  => vr_load_row.bank_bik
                                              ,par_account_number            => vr_load_row.account_number
                                              ,par_is_credit                 => vr_load_row.is_credit
                                              ,par_application_reason        => vr_load_row.application_reason
                                              ,par_bank_return_amount        => vr_load_row.bank_return_amount
                                              ,par_bank_return_ag_amount     => vr_load_row.bank_return_ag_amount
                                              ,par_bank_return_rko_amount    => vr_load_row.bank_return_rko_amount
                                              ,par_decision                  => vr_load_row.decision
                                              ,par_decline_note              => vr_load_row.decline_note
                                              ,par_company_return_amount     => vr_load_row.company_return_amount
                                              ,par_company_return_ag_amount  => vr_load_row.company_return_ag_amount
                                              ,par_company_return_rko_amount => vr_load_row.company_return_rko_amount
                                              ,par_registration_date         => vr_load_row.registration_date
                                              ,par_responsible               => vr_load_row.responsible
                                              ,par_product_name              => vr_load_row.product_name
                                              ,par_bank_notice               => vr_load_row.bank_notice
                                              ,par_decline_journal_hkfb_id   => v_decline_journal_hkfb_id);
        doc.set_doc_status(p_doc_id       => v_decline_journal_hkfb_id
                          ,p_status_brief => define_notice_status);
      END insert_notice_in_journal;
    
      /*���������� ����������*/
      PROCEDURE update_notice_in_journal(par_decline_journal_hkfb_id decline_journal_hkfb.decline_journal_hkfb_id%TYPE) IS
        vr_decline_journal_hkfb dml_decline_journal_hkfb.tt_decline_journal_hkfb;
      BEGIN
        vr_decline_journal_hkfb := dml_decline_journal_hkfb.get_record(par_decline_journal_hkfb_id => par_decline_journal_hkfb_id);
        --���������� ����� �� ������ �� ����� (���� � ����� ���� ��������, �� ����� �� ����)
        vr_decline_journal_hkfb.insured_name              := nvl(vr_load_row.insured_name
                                                                ,vr_decline_journal_hkfb.insured_name);
        vr_decline_journal_hkfb.policy_number             := nvl(vr_load_row.policy_number
                                                                ,vr_decline_journal_hkfb.policy_number);
        vr_decline_journal_hkfb.reg_date                  := SYSDATE;
        vr_decline_journal_hkfb.registry_name             := nvl(vr_load_row.registry_name
                                                                ,vr_decline_journal_hkfb.registry_name);
        vr_decline_journal_hkfb.recieve_date              := nvl(vr_load_row.recieve_date
                                                                ,vr_decline_journal_hkfb.recieve_date);
        vr_decline_journal_hkfb.notice_date               := nvl(vr_load_row.notice_date
                                                                ,vr_decline_journal_hkfb.notice_date);
        vr_decline_journal_hkfb.policy_start_date         := nvl(vr_load_row.policy_start_date
                                                                ,vr_decline_journal_hkfb.policy_start_date);
        vr_decline_journal_hkfb.days_of_credit            := nvl(vr_load_row.days_of_credit
                                                                ,vr_decline_journal_hkfb.days_of_credit);
        vr_decline_journal_hkfb.credit_end_date           := nvl(vr_load_row.credit_end_date
                                                                ,vr_decline_journal_hkfb.credit_end_date);
        vr_decline_journal_hkfb.home_phone                := nvl(vr_load_row.home_phone
                                                                ,vr_decline_journal_hkfb.home_phone);
        vr_decline_journal_hkfb.cell_phone                := nvl(vr_load_row.cell_phone
                                                                ,vr_decline_journal_hkfb.cell_phone);
        vr_decline_journal_hkfb.decline_notice_date       := nvl(vr_load_row.decline_notice_date
                                                                ,vr_decline_journal_hkfb.decline_notice_date);
        vr_decline_journal_hkfb.payment_generated         := nvl(vr_load_row.payment_generated
                                                                ,vr_decline_journal_hkfb.payment_generated);
        vr_decline_journal_hkfb.application_place         := nvl(vr_load_row.application_place
                                                                ,vr_decline_journal_hkfb.application_place);
        vr_decline_journal_hkfb.is_hkfb_account           := nvl(vr_load_row.is_hkfb_account
                                                                ,vr_decline_journal_hkfb.is_hkfb_account);
        vr_decline_journal_hkfb.bank_bik                  := nvl(vr_load_row.bank_bik
                                                                ,vr_decline_journal_hkfb.bank_bik);
        vr_decline_journal_hkfb.account_number            := nvl(vr_load_row.account_number
                                                                ,vr_decline_journal_hkfb.account_number);
        vr_decline_journal_hkfb.is_credit                 := nvl(vr_load_row.is_credit
                                                                ,vr_decline_journal_hkfb.is_credit);
        vr_decline_journal_hkfb.application_reason        := nvl(vr_load_row.application_reason
                                                                ,vr_decline_journal_hkfb.application_reason);
        vr_decline_journal_hkfb.bank_return_amount        := nvl(vr_load_row.bank_return_amount
                                                                ,vr_decline_journal_hkfb.bank_return_amount);
        vr_decline_journal_hkfb.bank_return_ag_amount     := nvl(vr_load_row.bank_return_ag_amount
                                                                ,vr_decline_journal_hkfb.bank_return_ag_amount);
        vr_decline_journal_hkfb.bank_return_rko_amount    := nvl(vr_load_row.bank_return_rko_amount
                                                                ,vr_decline_journal_hkfb.bank_return_rko_amount);
        vr_decline_journal_hkfb.decision                  := nvl(vr_load_row.decision
                                                                ,vr_decline_journal_hkfb.decision);
        vr_decline_journal_hkfb.decline_note              := nvl(vr_load_row.decline_note
                                                                ,vr_decline_journal_hkfb.decline_note);
        vr_decline_journal_hkfb.company_return_amount     := nvl(vr_load_row.company_return_amount
                                                                ,vr_decline_journal_hkfb.company_return_amount);
        vr_decline_journal_hkfb.company_return_ag_amount  := nvl(vr_load_row.company_return_ag_amount
                                                                ,vr_decline_journal_hkfb.company_return_ag_amount);
        vr_decline_journal_hkfb.company_return_rko_amount := nvl(vr_load_row.company_return_rko_amount
                                                                ,vr_decline_journal_hkfb.company_return_rko_amount);
        vr_decline_journal_hkfb.registration_date         := nvl(vr_load_row.registration_date
                                                                ,vr_decline_journal_hkfb.registration_date);
        vr_decline_journal_hkfb.responsible               := nvl(vr_load_row.responsible
                                                                ,vr_decline_journal_hkfb.responsible);
        vr_decline_journal_hkfb.product_name              := nvl(vr_load_row.product_name
                                                                ,vr_decline_journal_hkfb.product_name);
        vr_decline_journal_hkfb.bank_notice               := nvl(vr_load_row.bank_notice
                                                                ,vr_decline_journal_hkfb.bank_notice);
      
        vr_decline_journal_hkfb.registry_name := v_file_name;
        
        dml_decline_journal_hkfb.update_record(vr_decline_journal_hkfb);
      
        /*������� � ���� ���� ������ �� ������� � ������� ��������� �� ������� ������������ 98%� � ����������� ������� � ������ "����������� � ��"*/
        IF vr_load_row.status IS NULL
           AND vr_load_row.application_reason = gc_reason_decline98
        THEN
          doc.set_doc_status(p_doc_id       => par_decline_journal_hkfb_id
                            ,p_status_brief => 'BRAKE_IN_COMPANY' /*����������� � ��*/);
        END IF;
      END update_notice_in_journal;
    BEGIN
      --����� ������ � ������� ��������� �� "������ ��������" � "���� ������ ���������"
      v_notice_from_journal_id := find_notice_in_journal(par_policy_number       => vr_load_row.policy_number
                                                        ,par_decline_notice_date => vr_load_row.decline_notice_date);
      IF v_notice_from_journal_id IS NOT NULL
      THEN
        update_notice_in_journal(par_decline_journal_hkfb_id => v_notice_from_journal_id);
      ELSE
        insert_notice_in_journal;
      END IF;
    END load_decline_notice;
  
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
  
    /* ����� �� �� ������ */
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
  
  BEGIN
    pkg_load_file_to_table.init_file(par_load_file_id => par_load_file_id);
    /*��� �����*/
    v_file_name := get_file_name;
  
    /*���� �� ���� ������� �����*/
    FOR cur_file_row IN (SELECT *
                           FROM load_file_rows
                          WHERE 1 = 1
                            AND row_status IN (pkg_load_file_to_table.get_checked
                                              ,pkg_load_file_to_table.get_nc_error)
                            AND load_file_id = par_load_file_id)
    LOOP
      SAVEPOINT before_process;
    
      BEGIN
      gv_load_file_rows_id := cur_file_row.load_file_rows_id;
      pkg_load_file_to_table.cache_row(gv_load_file_rows_id);
    
      vr_load_row := get_row_values;
    
        /* ����� �.: ������ 390606 - ��������� ����������� ������� ������ �� �������� � pkg_universal_loader.group_decline_hkb.get_cooling_period */
        vr_policy := find_policy(par_policy_num => vr_load_row.policy_number);
        vr_p_pol_header := dml_p_pol_header.get_record(par_policy_header_id => vr_policy.pol_header_id);
        vr_p_policy := dml_p_policy.get_record(par_policy_id => vr_p_pol_header.max_uncancelled_policy_id);
        
        IF vr_load_row.application_reason IS NULL
        THEN
          IF vr_load_row.decline_notice_date - vr_policy.confirm_date + 1 >
             pkg_policy.define_cooling_period_length(par_header_start_date => vr_p_policy.notice_date)/*409773: ����� ������� ���� ������ �. 10.4.2015*/
          THEN
            vr_load_row.application_reason := '���';
          ELSE
            vr_load_row.application_reason := '������ ����������';
          END IF;
        END IF;
        /* ����� �.: ������ 390606 */
      
      -- ��������� ���������
      load_decline_notice;
    
      /*�������� ������ ��� ������������*/
      pkg_load_file_to_table.set_row_status(par_load_file_rows_id => cur_file_row.load_file_rows_id
                                           ,par_row_status        => pkg_load_file_to_table.get_loaded);
      EXCEPTION
        WHEN policy_not_found THEN
          ROLLBACK TO before_process;
          v_decision := c_decision_refusal;
          set_decision_comment(par_row_id   => cur_file_row.load_file_rows_id
                              ,par_decision => c_decision_refusal
                              ,par_comment  => '������� �� ������');
        WHEN too_many_policies THEN
          ROLLBACK TO before_process;
          pkg_load_file_to_table.set_row_status(par_load_file_rows_id => cur_file_row.load_file_rows_id
                                               ,par_row_status        => pkg_load_file_to_table.get_error
                                               ,par_is_checked        => 0
                                               ,par_row_comment       => '������� ��������� ��������� � ��������� �������');
      END;
    
    END LOOP; -- ����� ���� �� ���� ������� �����
  END load_decline_journal;

  /*���������� ������� ��������� ������� �� ���������� �� �����������*/
  PROCEDURE cancel_hkf_control IS
    v_registry_hkf_control_clob CLOB;
    v_blob_offset               NUMBER := 1;
    v_clob_offset               NUMBER := 1;
    v_lang_context              INTEGER := dbms_lob.default_lang_ctx;
    v_warning                   NUMBER;
    c_to                        pkg_email.t_recipients :=  /*pkg_email.t_recipients('mihail.chernyh@renlife.com');*/
    
     pkg_email.t_recipients('cancel_hkb@renlife.com');
    v_files                     pkg_email.t_files := pkg_email.t_files();
    c_message_text     CONSTANT VARCHAR2(10) := ' ';
    c_file_name        CONSTANT VARCHAR2(100) := '������ � ����������� �� ����_' ||
                                                 to_char(SYSDATE, 'DDMMRRRR') || '.CSV';
    c_query_string     CONSTANT VARCHAR2(4000) := 'select * from V_CANCEL_HKF_CONTROL t';
    v_row_count PLS_INTEGER;
  BEGIN
    /*������������ ���-�� �������*/
    SELECT COUNT(*) INTO v_row_count FROM v_cancel_hkf_control t;
    IF v_row_count > 0
    THEN
      v_files := pkg_email.t_files();
      v_files.extend(1);
      -- �������� �������� �����
      v_files(1).v_file_name := c_file_name;
      v_files(1).v_file_type := tt_file.get_mime_type(par_file_name_or_ext => v_files(1).v_file_name);
      dbms_lob.createtemporary(lob_loc => v_files(1).v_file, cache => TRUE);
      dbms_lob.createtemporary(lob_loc => v_registry_hkf_control_clob, cache => TRUE);
    
      pkg_csv.select_to_csv(par_select        => c_query_string
                           ,par_header_option => pkg_csv.gc_without_header
                           ,par_csv           => v_registry_hkf_control_clob);
    
      dbms_lob.converttoblob(src_clob     => v_registry_hkf_control_clob
                            ,dest_lob     => v_files(1).v_file
                            ,amount       => dbms_lob.lobmaxsize
                            ,dest_offset  => v_blob_offset
                            ,src_offset   => v_clob_offset
                            ,blob_csid    => dbms_lob.default_csid
                            ,lang_context => v_lang_context
                            ,warning      => v_warning);
    
      dbms_lob.freetemporary(lob_loc => v_registry_hkf_control_clob);
      /*�������� �� �����*/
      pkg_email.send_mail_with_attachment(par_to         => c_to
                                         ,par_subject    => '������ ����� �� ���������� �������� � ��_' ||
                                                            to_char(SYSDATE, 'DDMMRRRR') || '_' ||
                                                            v_row_count || ' ���������'
                                         ,par_text       => c_message_text
                                         ,par_attachment => v_files);
    ELSE
      /*�������� �� �����*/
      pkg_email.send_mail_with_attachment(par_to         => c_to
                                         ,par_subject    => '������ ����� �� ���������� �������� � ��_' ||
                                                            to_char(SYSDATE, 'DDMMRRRR') ||
                                                            '_0 �������'
                                         ,par_text       => c_message_text
                                         ,par_attachment => NULL);
    END IF;
  END cancel_hkf_control;

  /*���������� ������� ��������� ������� �� �������������� ���������� �� �����������*/
  PROCEDURE refusal_not_processed IS
    v_registry_hkf_control_clob CLOB;
    v_blob_offset               NUMBER := 1;
    v_clob_offset               NUMBER := 1;
    v_lang_context              INTEGER := dbms_lob.default_lang_ctx;
    v_warning                   NUMBER;
    c_to                        pkg_email.t_recipients := pkg_email.t_recipients('rustam.ahtyamov@renlife.com');
    v_files pkg_email.t_files := pkg_email.t_files();
    c_message_text CONSTANT VARCHAR2(10) := ' ';
    c_file_name    CONSTANT VARCHAR2(100) := '�������������� ������_' || to_char(SYSDATE, 'DDMMRRRR') ||
                                             '.CSV';
    c_query_string CONSTANT VARCHAR2(4000) := 'select * from v_refusal_not_processed t';
    v_row_count PLS_INTEGER;
  BEGIN
    /*������������ ���-�� �������*/
    SELECT COUNT(*) INTO v_row_count FROM v_refusal_not_processed t;
    IF v_row_count > 0
    THEN
      v_files := pkg_email.t_files();
      v_files.extend(1);
      -- �������� �������� �����
      v_files(1).v_file_name := c_file_name;
      v_files(1).v_file_type := tt_file.get_mime_type(par_file_name_or_ext => v_files(1).v_file_name);
      dbms_lob.createtemporary(lob_loc => v_files(1).v_file, cache => TRUE);
      dbms_lob.createtemporary(lob_loc => v_registry_hkf_control_clob, cache => TRUE);
    
      pkg_csv.select_to_csv(par_select        => c_query_string
                           ,par_header_option => pkg_csv.gc_without_header
                           ,par_csv           => v_registry_hkf_control_clob);
    
      dbms_lob.converttoblob(src_clob     => v_registry_hkf_control_clob
                            ,dest_lob     => v_files(1).v_file
                            ,amount       => dbms_lob.lobmaxsize
                            ,dest_offset  => v_blob_offset
                            ,src_offset   => v_clob_offset
                            ,blob_csid    => dbms_lob.default_csid
                            ,lang_context => v_lang_context
                            ,warning      => v_warning);
    
      dbms_lob.freetemporary(lob_loc => v_registry_hkf_control_clob);
      /*�������� �� �����*/
      pkg_email.send_mail_with_attachment(par_to         => c_to
                                         ,par_subject    => '������ � ��������� �� ���������� �����_' ||
                                                            to_char(SYSDATE, 'DDMMRRRR') || '_' ||
                                                            v_row_count || ' ���������'
                                         ,par_text       => c_message_text
                                         ,par_attachment => v_files);
    ELSE
      /*�������� �� �����*/
      pkg_email.send_mail_with_attachment(par_to         => c_to
                                         ,par_subject    => '������ � ��������� �� ���������� ����� _' ||
                                                            to_char(SYSDATE, 'DDMMRRRR') ||
                                                            '_0 �������'
                                         ,par_text       => c_message_text
                                         ,par_attachment => NULL);
    END IF;
  END refusal_not_processed;

END pkg_load_hkfb;
/

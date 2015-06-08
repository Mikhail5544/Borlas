CREATE OR REPLACE PACKAGE pkg_mpos IS

  -- Author  : ARTUR.BAYTIN
  -- Created : 08.11.2013 19:39:44
  -- Purpose : ������ � ������������ mPOS ����������

  cant_write_exception CONSTANT NUMBER := -20011;
  cant_write EXCEPTION;
  PRAGMA EXCEPTION_INIT(cant_write, -20011);
  /*������� ���������*/
  gc_work_status_no_notice CONSTANT VARCHAR2(50) := '��� ���������';
  gc_work_status_no_result CONSTANT VARCHAR2(50) := '��� ����������� ��������';
  gc_work_status_processed CONSTANT VARCHAR2(50) := '���������';

  FUNCTION get_2can_url(par_oper_type VARCHAR2) RETURN VARCHAR2;

  /*
    ������ �.
    
    �������� � ���������� 2can ���������� � ������������� ��� ������ ��,
  
    �� 2can �������� ��������� � ������� JSON ����:
    {
      "Model": {
        "Id": 161,
        "Hash": "c0aeee10269e0eea8bb0e17faedbbc75",
        "Company": "2can",
        "Merchant": 111222,
        
      },
      "Status": "Success"
    }
   , ��� ��� ����� ������, ��������� ������ ����� �������������
  */
  PROCEDURE send_to_2can
  (
    par_operation_url  VARCHAR2
   ,par_transaction_id mpos_writeoff_form.transaction_id%TYPE
   ,par_is_success     OUT BOOLEAN
  );

  /*
   ����� �.
   ���� JOB'� JOB_SEND_WRITEOFF_FORM
  */
  PROCEDURE job_send_writeoff_form;

  /*
    ������ �. 25.09.2014
    ���������� ��������� � �� (����������� � �������� ��) � ������ ������ ������ �� �������� �� ������� (����������� � ��)
  */
  PROCEDURE stop_writeoff_form_by_notice(par_mpos_writeoff_notice_id mpos_writeoff_notice.mpos_writeoff_notice_id%TYPE);

  /*
    ������ �.
    
    ����������� � �������� �������������� ��������
    
    ��. � �������� ��. ����������
    ��������� ����������� �� �������� ����������� - ��������
  */
  PROCEDURE stop_writeoff_form(par_mpos_writeoff_form_id mpos_writeoff_form.mpos_writeoff_form_id%TYPE);

  /*
    ������ �.
    
    ��� ���������� �������� ����������� � �������� �������������� ��������
    ������������ ��������� ����� ��������� ��������.
    ��� ���� ����������� � �������� �������������� �������� � ������� ������������,
    ���� ������� �����������, �� ������� ���������
    ����������� � �������� �������������� ��������,
    ����� ���� �� ������������� ��������, ��:
       ����������� � �������� �������������� �������� ��������� ������ ���������, 
       � ���� ������� ������ ��������� �������� �4 � ����������� ��������, 
       � ���� ����� ������ ��������� ������� ����.   
    ������ ������������� ��������:
       �������; 
       ��������; 
       ���������; 
       ��������� � �����������; 
       ��������� �� �����������;  
       � �����������; 
       � �����������. ����� ��� ��������; 
       � �����������. ��������; 
       ���������. ������ ����������; 
       ���������. ��������� ��������; 
       ���������. � �������
       ��������������.
  */
  PROCEDURE stop_confirmed_writeoff_forms;

  /*
    ����� �.
    ��������� ��������������� ����������� �� ������� ���� �� ��������
  */
  FUNCTION get_confirmed_templ_by_header(par_pol_header_id p_pol_header.policy_header_id%TYPE)
    RETURN mpos_writeoff_form.mpos_writeoff_form_id%TYPE;

  /*
    ������ �.
    
    ������������ ����������� � �� �� ��������� ����������� � ��
    ����������� � �������� ��.
    "��. � �������� ��. ������������ ����������� � ��������"
    ����������� �� �������� "<�������� ��������>" - "�����"
  */

  PROCEDURE create_notice_from_form(par_mpos_writeoff_form_id mpos_writeoff_form.mpos_writeoff_form_id%TYPE);

  /*
    ������ �.
    
    ��������� �� ������ �� �������������� ��������
    ������� �������� "�����" - "�����������"
    ����������� �������� �������������� ��������,
    ������������ � ��������� �� ������ �� �������������� ��������
    ����������� �� ������� ������������ � ������ ���������
  */
  PROCEDURE confirm_writeoff_cancel(par_mpos_writeoff_cancel_id mpos_writeoff_cancel.mpos_writeoff_cancel_id%TYPE);

  /*
    ������ �.
    
    ��. � �������� ��. �������������. ����� �������� �����������
    ������� �������� "�����" - "�����������"
    ������ ������ ������
  */

  PROCEDURE search_writeoff_form_policy(par_mpos_writeoff_form_id mpos_writeoff_form.mpos_writeoff_form_id%TYPE);
  /*
    ������ �.
  
    ������� �������� ������ - ������������
    
    1. ����� �������� �����������:  
    �  ���� ���� ���� ��� �������������� ���������,
       �� �������������� ����� ������������ ���� ���� ��� ��������������
       � �������� ��� �������� �����������.
       ���� ������������ �������, �� �� �������� ����������� � ���� ��� ��������;
    �  ���� ���� ���� ��� �������������� �� ��������� ��� ������������ �� �������,
       �� �������������� ����� ������������ �������� ������ �������� ������������,
       ����������� �� ����������� � ��� �������� �����������.
       ���� ������������ �������, �� �� �������� ����������� � ���� ��� ��������;
  
    2. ��� ������������ ��������:
    �  �������� ������������ ���, ���������� ����������� � �������� �� � ���
       � �������� �����������;
    �  �������� ������������ ����� �������� ����������� � �������� ��
       � ����� ������ ������ �������� �����������;
    �  �������� ������ ����������� � �������� �� � ������ ������ �������� �����������;
    �  �������� ������������ ������������� �������� ����������� � �������� ��
       � ������������� �������� � �������� �����������;
      � ������� �� ��������� � ����� �� ������������� ��������
      (�������; ��������; ���������; ��������� � �����������;
       ��������� �� �����������;  � �����������; � �����������. ����� ��� ��������;
       � �����������. ��������; ���������. ������ ����������;
       ���������. ��������� ��������; ���������. � �������.)
  
    3. �������� ���������� ��� ������������ ��������
       ����������� � �������� �������������� �������� � ������� ������������. 
  */
  PROCEDURE confirm_writeoff_form(par_mpos_writeoff_form_id mpos_writeoff_form.mpos_writeoff_form_id%TYPE);

  PROCEDURE send_confirm_write_off_form(par_mpos_writeoff_form_id mpos_writeoff_form.mpos_writeoff_form_id%TYPE);
  /*���������� ������ ���������*/
  FUNCTION get_work_status
  (
    par_mpos_writeoff_form_id mpos_writeoff_form.mpos_writeoff_form_id%TYPE
   ,par_processing_result     mpos_writeoff_notice.processing_result%TYPE
  ) RETURN mpos_writeoff_notice.work_status%TYPE;
  /*�������� ��� ���������� �� ����� ������*/
  FUNCTION get_result_code(par_result_text VARCHAR2) RETURN NUMBER;
  /*�������� ������ ����� ���������� �� ����� ������*/
  FUNCTION get_result_name(par_result_text VARCHAR2) RETURN VARCHAR2;
  /*
      ���������� �� ����������� � �������� �� �� ������� ���������� �� ������������ 2Can �������
      ������ �. 18.09.2014
  -- %param par_policy_number  ����� ��������
  -- %param par_transaction_date  ���� ��������
  -- %param par_amount ����� ��������
  -- %param par_card_number ����� �����
  
    */
  FUNCTION get_writeoff_form_by_refuse
  (
    par_policy_number    mpos_writeoff_notice.processing_policy_number%TYPE
   ,par_transaction_date mpos_writeoff_notice.transaction_date%TYPE
   ,par_amount           mpos_writeoff_notice.amount%TYPE
   ,par_card_number      mpos_writeoff_notice.card_number%TYPE
  ) RETURN mpos_writeoff_form.mpos_writeoff_form_id%TYPE;
  /*
    ������ �.
    
    ���������� �� ��������������� ����������� � �������� �� �� �� ��������� ��
  */
  FUNCTION get_writeoff_form_by_policy
  (
    par_pol_header_id  p_pol_header.policy_header_id%TYPE
   ,par_raise_on_error BOOLEAN DEFAULT TRUE
  ) RETURN mpos_writeoff_form.mpos_writeoff_form_id%TYPE;

  /*
    ������ �.
    
    ��. � �������� ��. ������
    ������� ����� - �������
  */
  PROCEDURE cancel_writeoff_form(par_mpos_writeoff_form_id mpos_writeoff_form.mpos_writeoff_form_id%TYPE);

  /*
    ������ �.
    
    ������� ��������� ������� �� �����������
  */
  PROCEDURE unbind_registr_from_pay_notice(par_mpos_payment_notice_id mpos_payment_notice.mpos_payment_notice_id%TYPE);

  /*
    ������ �.
    
    ����� � �������� �������� ��� ����������� � ���������� �������
  */
  PROCEDURE bind_register_to_pay_notice
  (
    par_payment_register_item_id payment_register_item.payment_register_item_id%TYPE
   ,par_mpos_payment_notice_id   mpos_payment_notice.mpos_payment_notice_id%TYPE
  );

  PROCEDURE unbind_register_from_wo_notice
  (
    par_payment_register_item_id payment_register_item.payment_register_item_id%TYPE
   ,par_mpos_writeoff_notice_id  mpos_writeoff_notice.mpos_writeoff_notice_id%TYPE
  );

  /*
    ������ �.
    
    ����� � �������� �������� ��� ����������� � ������������� ��������
  */
  PROCEDURE bind_register_to_wo_notice
  (
    par_payment_register_item_id payment_register_item.payment_register_item_id%TYPE
   ,par_mpos_writeoff_notice_id  mpos_writeoff_notice.mpos_writeoff_notice_id%TYPE
  );

  PROCEDURE process_writeoff_notice
  (
    par_g_mpos_id g_mpos.g_mpos_id%TYPE
   ,par_commit    BOOLEAN DEFAULT TRUE
  );

  PROCEDURE process_writeoff_form
  (
    par_g_mpos_id g_mpos.g_mpos_id%TYPE
   ,par_commit    BOOLEAN DEFAULT TRUE
  );

  PROCEDURE process_payment_notice
  (
    par_g_mpos_id g_mpos.g_mpos_id%TYPE
   ,par_commit    BOOLEAN
  );

  /*
    ������ �.
    ��������� �������� �������� 2can
  */
  PROCEDURE process_2can_request
  (
    par_request VARCHAR2
   ,par_commit  BOOLEAN DEFAULT TRUE
  );
  /*
  ������ �.
  ��������� ������� �� ������ ���������� �� �����
  */
  PROCEDURE process_record_from_forms(par_mpos_writeoff_notice_id mpos_writeoff_notice.mpos_writeoff_notice_id%TYPE);

  --�������� �.�.
  --����������� �� �������� �������� "�������" � ������ "�����"
  PROCEDURE clear_reason_for_rejection(par_mpos_writeoff_form_id mpos_writeoff_form.mpos_writeoff_form_id%TYPE);

  /*
     ������ �. 25.09.2014
    �������� ������� �������� ��� ��������
  */
  PROCEDURE create_schedule(par_mpos_writeoff_form_id mpos_writeoff_form.mpos_writeoff_form_id%TYPE);

  /*
    ������ �. 25.09.2014
    ��������� �������� ������� �� �������� (��� ������� ��������� �������)
  */
  PROCEDURE pass_to_writeoff_at_night;

  --���������� �� �������� ������� "�����������" - "��������"
  --���� ������ ��������� "����������� � �������� �������������� ��������"  ����� "��������", "��������.�� ������� � ����������"
  --� ��� ��������� ���������� ��������� ��������� "������ �������� mPos" � ������� "�� ��������" ��� "�����",
  --�� ��������� ���������� �� � ������ "�������". 
  PROCEDURE cancel_shedule(par_mpos_writeoff_form_id NUMBER);

  -- ��������� �������� ������������ �������� ������� ��������� 
  -- "������������� ��������"
  -- ����������� �� �������� �� ������� ������� � ������ ������   
  PROCEDURE check_succesfull_wo_noti�e(par_mpos_writeoff_notice_id NUMBER);

  -- ��������� �������� ������������ �������� ������� ��������� 
  -- "����������� � �������� �������������� ��������"
  -- ����������� �� �������� �� ������� ������� � ������ ������   
  PROCEDURE check_succesfull_wo_form(par_mpos_writeoff_form_id NUMBER);

  -- ��������� �������� ������������ �������� ������� ��������� 
  -- "����������� ��������" (MPOS_PAYMENT_NOTICE)
  -- ����������� �� �������� �� ������� ������� � ������ ������   
  PROCEDURE check_succesfull_paym_notice(par_mpos_payment_notice_id NUMBER);

  PROCEDURE req_m4bank_initialinstallments
  (
    par_date_from      DATE
   ,par_date_to        DATE
   ,par_is_success_out OUT BOOLEAN
   ,par_result_out     OUT JSON
   ,par_error_out      OUT VARCHAR2
  );

  PROCEDURE req_m4bank_confirminstallments
  (
    par_installment_id NUMBER
   ,par_is_success_out OUT BOOLEAN
   ,par_result_out     OUT JSON
   ,par_error_out      OUT VARCHAR2
  );

  PROCEDURE req_m4bank_stopinstallments
  (
    par_installment_id NUMBER
   ,par_is_success_out OUT BOOLEAN
   ,par_result_out     OUT JSON
   ,par_error_out      OUT VARCHAR2
  );

  -- ��������� ������ ��������
  -- par_date_from, par_date_to - ���������� ������,�� ������� 
  --   ���-������ ���������� ������ � �� ������� ����������� ������
  -- ���������� JOB��
  PROCEDURE sync_payment_data
  (
    par_date_from DATE DEFAULT trunc(SYSDATE - 1) + INTERVAL '1' SECOND
   ,par_date_to   DATE DEFAULT trunc(SYSDATE)
  );
END pkg_mpos;
/
CREATE OR REPLACE PACKAGE BODY pkg_mpos IS

  SUBTYPE t_request_type IS VARCHAR2(30);

  TYPE t_converted_values IS RECORD(
     transaction_id           mpos_payment_notice.transaction_id%TYPE
    ,transaction_date         mpos_payment_notice.transaction_date%TYPE
    ,amount                   mpos_payment_notice.amount%TYPE
    ,t_mpos_payment_status_id mpos_payment_notice.t_mpos_payment_status_id%TYPE
    ,description              mpos_payment_notice.description%TYPE
    ,rrn                      mpos_writeoff_form.rrn%TYPE
    ,terminal_bank_id         mpos_writeoff_form.terminal_bank_id%TYPE
    ,cliche                   mpos_payment_notice.cliche%TYPE
    ,t_payment_system_id      mpos_payment_notice.t_payment_system_id%TYPE
    ,card_number              mpos_payment_notice.card_number%TYPE
    ,device_id                mpos_payment_notice.device_id%TYPE
    ,device_name              mpos_payment_notice.device_name%TYPE
    ,device_model             mpos_payment_notice.device_model%TYPE
    ,insured_name             mpos_payment_notice.insured_name%TYPE
    ,product_name             mpos_payment_notice.product_name%TYPE
    ,policy_number            mpos_payment_notice.policy_number%TYPE
    ,policy_start_date        mpos_payment_notice.policy_start_date%TYPE
    ,ins_premium              mpos_payment_notice.ins_premium%TYPE
    ,t_payment_terms_id       mpos_writeoff_form.t_payment_terms_id%TYPE
    ,writeoff_number          mpos_writeoff_notice.writeoff_number%TYPE
    ,mpos_writeoff_form_id    mpos_writeoff_notice.mpos_writeoff_form_id%TYPE);

  -- ��������� ������������ ��������� ���������� �� ���� ���������� (HRC)
  -- ���������:  
  -- par_result_code    - HRC 
  -- out_mpos_result_id - id ������ � t_mpos_result, 
  --                      ��� null, ���� ������ �� �������                          
  -- out_succes_flag    - ������� ���������/����������� �������� (1/0), 
  --                      ��� null, ���� ������ �� �������
  PROCEDURE get_mpos_result
  (
    par_result_code    IN VARCHAR2
   ,out_mpos_result_id OUT NUMBER
   ,out_succes_flag    OUT NUMBER
  ) IS
    vr_mpos_result dml_t_mpos_result.tt_t_mpos_result;
  BEGIN
    BEGIN
      vr_mpos_result := dml_t_mpos_result.get_rec_by_process_description(par_result_code);
    EXCEPTION
      WHEN ex.no_data_found THEN
        NULL;
    END;
    out_mpos_result_id := vr_mpos_result.t_mpos_result_id;
    out_succes_flag    := vr_mpos_result.successful_writeoff_flag;
  END;
  -- ��������� ���������� ������� ��� ��������� � ������� ���-�������
  PROCEDURE fill_headers(par_headers IN OUT pkg_communication.tt_headers) IS
    v_salt                   VARCHAR(30);
    c_m4bank_password_sha256 VARCHAR2(256);
  BEGIN
    SELECT to_char((SYSDATE - to_date('01.01.1970', 'dd.mm.yyyy')) * 24 * 60 * 60)
      INTO v_salt
      FROM dual;
  
    v_salt := v_salt || dbms_random.string('p', 30 - length(v_salt));
    v_salt := REPLACE(v_salt, ' ', 'x'); -- �������� �������� ��������� ������, ��-�� ����� ����� �� ������� ���
    v_salt := REPLACE(v_salt, '''', 'x');
  
    -- ����� � ������ ����� ��� ���� �������
    c_m4bank_password_sha256 := pkg_borlas_b2b.get_b2b_props_val(par_oper_type_brief  => 'InitialInstallments_m4bank'
                                                                ,par_props_type_brief => 'password');
  
    par_headers('X-2can-Login') := pkg_borlas_b2b.get_b2b_props_val(par_oper_type_brief  => 'InitialInstallments_m4bank'
                                                                   ,par_props_type_brief => 'login');
    par_headers('X-2can-Salt') := v_salt;
    par_headers('X-2can-Hash') := lower(pkg_utils.get_sha256(v_salt || c_m4bank_password_sha256));
  END;

  FUNCTION get_t_paym_terms_id_by_ext_id(par_ext_id NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN pkg_t_payment_terms_dml.get_id_by_brief(par_brief => CASE par_ext_id
                                                                  WHEN 0 THEN
                                                                   'DAILY'
                                                                  WHEN 1 THEN
                                                                   'WEEKLY'
                                                                  WHEN 2 THEN
                                                                   'MONTHLY'
                                                                  WHEN 3 THEN
                                                                   'EVERY_QUARTER'
                                                                  WHEN 4 THEN
                                                                   'HALF_YEAR'
                                                                  WHEN 5 THEN
                                                                   'EVERY_YEAR'
                                                                END);
  END;

  FUNCTION get_2can_url(par_oper_type VARCHAR2) RETURN VARCHAR2 IS
    v_url t_b2b_props_vals.props_value%TYPE;
  BEGIN
    BEGIN
      SELECT pv.props_value
        INTO v_url
        FROM t_b2b_props_db   db
            ,t_b2b_props_vals pv
            ,t_b2b_props_oper op
            ,t_b2b_props_type ty
       WHERE pv.t_b2b_props_db_id = db.t_b2b_props_db_id
         AND pv.t_b2b_props_oper_id = op.t_b2b_props_oper_id
         AND pv.t_b2b_props_type_id = ty.t_b2b_props_type_id
            --params
         AND op.oper_brief = par_oper_type
         AND ty.type_brief = 'URL'
         AND db.db_brief = sys.database_name;
    EXCEPTION
      WHEN no_data_found THEN
        v_url := NULL;
    END;
    RETURN v_url;
  END get_2can_url;

  /*
    ������ �.
    
    �������� � ���������� 2can ���������� � ������������� ��� ������ ��,
  
    �� 2can �������� ��������� � ������� JSON ����:
    {
      "Model": {
        "Id": 161,
        "Hash": "c0aeee10269e0eea8bb0e17faedbbc75",
        "Company": "2can",
        "Merchant": 111222,
        
      },
      "Status": "Success"
    }
   , ��� ��� ����� ������, ��������� ������ ����� �������������
  */
  PROCEDURE send_to_2can
  (
    par_operation_url  VARCHAR2
   ,par_transaction_id mpos_writeoff_form.transaction_id%TYPE
   ,par_is_success     OUT BOOLEAN
  ) IS
    va_headers      pkg_communication.tt_headers;
    v_string_answer VARCHAR2(500);
    v_json_answer   JSON;
  BEGIN
    assert_deprecated(par_operation_url IS NULL, '�� ������ URL ��������');
    assert_deprecated(par_transaction_id IS NULL
                     ,'�� ������ ID ���������� � �����������');
  
    fill_headers(va_headers);
  
    BEGIN
      v_string_answer := pkg_communication.request(par_url           => par_operation_url
                                                  ,par_send          => 'InitialInstallment=' ||
                                                                        to_char(par_transaction_id)
                                                  ,par_add_headers   => va_headers
                                                  ,par_use_def_proxy => TRUE);
      BEGIN
        v_json_answer := JSON(v_string_answer);
      EXCEPTION
        WHEN OTHERS THEN
          raise_application_error(-20001, '������ ��� ������� ������');
      END;
    
      IF v_json_answer.exist('Status')
      THEN
        par_is_success := upper(v_json_answer.get('Status').get_string) = 'SUCCESS';
      ELSE
        par_is_success := FALSE;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        par_is_success := FALSE;
    END;
  END send_to_2can;
  /* 17-03-2015 ��������� �� ����� �����  ���-�������*/
  PROCEDURE job_send_writeoff_form IS
    v_is_success  BOOLEAN;
    v_result_json JSON;
    v_error       VARCHAR2(32000);
  BEGIN
    FOR vr_wf IN (SELECT wf.transaction_id
                        ,mpos_writeoff_form_id
                        ,CASE dsr.brief
                           WHEN 'CONFIRMED_NOT_SENT' THEN
                            'CONFIRMED'
                           WHEN 'CANCEL_NOT_SENT' THEN
                            'CANCEL'
                           WHEN 'STOPED_NOT_SENT' THEN
                            'STOPED'
                         END AS next_status
                        ,dsr.brief status_brief
                    FROM mpos_writeoff_form wf
                        ,document           dc
                        ,doc_status_ref     dsr
                   WHERE wf.mpos_writeoff_form_id = dc.document_id
                     AND dc.doc_status_ref_id = dsr.doc_status_ref_id
                     AND dsr.brief IN ('CONFIRMED_NOT_SENT', 'CANCEL_NOT_SENT', 'STOPED_NOT_SENT'))
    LOOP
      v_is_success := NULL;
    
      IF vr_wf.status_brief = 'CONFIRMED_NOT_SENT'
      THEN
        req_m4bank_confirminstallments(par_installment_id => vr_wf.transaction_id
                                      ,par_is_success_out => v_is_success
                                      ,par_result_out     => v_result_json
                                      ,par_error_out      => v_error);
      END IF;
    
      IF vr_wf.status_brief IN ('CANCEL_NOT_SENT', 'STOPED_NOT_SENT')
      THEN
        req_m4bank_stopinstallments(par_installment_id => vr_wf.transaction_id
                                   ,par_is_success_out => v_is_success
                                   ,par_result_out     => v_result_json
                                   ,par_error_out      => v_error);
      END IF;
    
      IF v_is_success
      THEN
        doc.set_doc_status(p_doc_id       => vr_wf.mpos_writeoff_form_id
                          ,p_status_brief => vr_wf.next_status);
        COMMIT;
      END IF;
    END LOOP;
    COMMIT;
  END job_send_writeoff_form;
  /*
    ������ �. 25.09.2014
    ���������� ��������� � �� (����������� � �������� ��) � ������ ������ ������ �� �������� �� ������� (����������� � ��)
  */
  PROCEDURE stop_writeoff_form_by_notice(par_mpos_writeoff_notice_id mpos_writeoff_notice.mpos_writeoff_notice_id%TYPE) IS
    vr_mpos_writeoff_notice dml_mpos_writeoff_notice.tt_mpos_writeoff_notice;
    vr_mpos_writeoff_form   dml_mpos_writeoff_form.tt_mpos_writeoff_form;
    vr_doc_status_ref       dml_doc_status_ref.tt_doc_status_ref;
    vr_t_mpos_result        dml_t_mpos_result.tt_t_mpos_result;
  BEGIN
    vr_mpos_writeoff_notice := dml_mpos_writeoff_notice.get_record(par_mpos_writeoff_notice_id => par_mpos_writeoff_notice_id);
    vr_t_mpos_result        := dml_t_mpos_result.get_record(par_t_mpos_result_id => vr_mpos_writeoff_notice.t_mpos_result_id);
  
    IF vr_t_mpos_result.stop_writeoff_flag = 1 /*���� ���������� �� ���������� �������� "��" � ���� ������ �� ���������, �� ��������� ���������*/
       AND vr_mpos_writeoff_notice.mpos_writeoff_form_id IS NOT NULL
    THEN
      vr_mpos_writeoff_form := dml_mpos_writeoff_form.get_record(par_mpos_writeoff_form_id => vr_mpos_writeoff_notice.mpos_writeoff_form_id);
      /*��������� � ��������� ������� �� ������ ������*/
      vr_mpos_writeoff_form.mpos_writeoff_notice_id := vr_mpos_writeoff_notice.mpos_writeoff_notice_id;
      vr_mpos_writeoff_form.t_mpos_rejection_id     := dml_t_mpos_rejection.get_id_by_brief(par_brief => 'BANK_REJECTION'); /*����� �����*/
      dml_mpos_writeoff_form.update_record(par_record => vr_mpos_writeoff_form);
    
      /*���������� ������ ���������*/
      vr_doc_status_ref := dml_doc_status_ref.get_record(par_doc_status_ref_id => vr_mpos_writeoff_form.doc_status_ref_id);
      IF vr_doc_status_ref.brief IN ('CONFIRMED', 'CONFIRMED_NOT_SENT')
      THEN
        doc.set_doc_status(p_doc_id       => vr_mpos_writeoff_form.mpos_writeoff_form_id
                          ,p_status_brief => 'STOPED');
      END IF;
    END IF;
  
  END stop_writeoff_form_by_notice;
  /*
    ������ �.
    
    ����������� � �������� �������������� ��������
    
    ��. � �������� ��. ����������
    ��������� ����������� �� �������� ����������� - ��������
    
     17-03-2015 ��������� �� ����� �����  ���-�������
  */
  PROCEDURE stop_writeoff_form(par_mpos_writeoff_form_id mpos_writeoff_form.mpos_writeoff_form_id%TYPE) IS
    vr_mpos_writeoff_form mpos_writeoff_form%ROWTYPE;
    v_sent_successfully   BOOLEAN;
    v_json_answer         JSON;
    v_error               VARCHAR2(32000);
  BEGIN
    assert_deprecated(par_mpos_writeoff_form_id IS NULL
                     ,'�������� �������������� ����������� � �������� �� ������ ���� �������');
    vr_mpos_writeoff_form := pkg_mpos_writeoff_form_dml.get_record(par_mpos_writeoff_form_id);
  
    req_m4bank_stopinstallments(par_installment_id => vr_mpos_writeoff_form.transaction_id
                               ,par_is_success_out => v_sent_successfully
                               ,par_result_out     => v_json_answer
                               ,par_error_out      => v_error);
  
    IF NOT v_sent_successfully
    THEN
      doc.set_doc_status(p_doc_id => par_mpos_writeoff_form_id, p_status_brief => 'STOPED_NOT_SENT');
    END IF;
  END stop_writeoff_form;

  /*
    ������ �.
    
    ��������� ��� ��������� �������� � ���������� �������� �����������
  */
  PROCEDURE stop_confirmed_writeoff_forms IS
    v_rejection_id t_mpos_rejection.t_mpos_rejection_id%TYPE;
  BEGIN
    /*
      ��� ���� ����������� � �������� �������������� �������� � ������� ������������ ���� �������� ������ �������� �����������, �� ������� ��������� ����������� � �������� �������������� ��������:
      1.  ��������� � ������� ���������, �� ���������������
          ����������� � �������� �������������� �������� ��������� ������
          ��������� � ������� ������ �6 - ���� �������� �������� �����
      2.  ��������� � ����� �� ��������, �� ���������������
          ����������� � �������� �������������� �������� ��������� ������
          ��������� � ������� ������ �4 - ����������� ��������. 
          �������;
          ���������;
          ��������� � �����������;
          ��������� �� �����������; 
          � �����������;
          � �����������. ����� ��� ��������;
          � �����������. ��������;
          ���������. ������ ����������;
          ���������. ��������� ��������;
          ���������. � �������;
          ��������������.
      ��������� �� ������ �� �������������� ��������,
      � ������� ������, �� ������� ��������� ����������� � �������� ��,
      ��������� ������ ��������
    */
    FOR vr_pol_stop IN (SELECT wf.mpos_writeoff_form_id
                              ,(SELECT wc.mpos_writeoff_cancel_id
                                  FROM mpos_writeoff_cancel wc
                                      ,document             dcc
                                      ,doc_status_ref       dsrc
                                 WHERE wc.mpos_writeoff_form_id = wf.mpos_writeoff_form_id
                                   AND wc.mpos_writeoff_cancel_id = dcc.document_id
                                   AND dcc.doc_status_ref_id = dsrc.doc_status_ref_id
                                   AND dsrc.brief = 'NEW') AS mpos_writeoff_cancel_id
                              ,dsrp.brief AS policy_status_brief
                          FROM mpos_writeoff_form wf
                              ,document           dcf
                              ,doc_status_ref     dsrf
                              ,p_pol_header       ph
                              ,p_policy           pp
                              ,document           dcp
                              ,doc_status_ref     dsrp
                         WHERE wf.mpos_writeoff_form_id = dcf.document_id
                           AND dcf.doc_status_ref_id = dsrf.doc_status_ref_id
                           AND dsrf.brief = 'CONFIRMED'
                           AND wf.policy_header_id = ph.policy_header_id
                           AND ph.policy_id = pp.policy_id
                           AND pp.policy_id = dcp.document_id
                           AND dcp.doc_status_ref_id = dsrp.doc_status_ref_id
                           AND dsrp.brief IN ('RECOVER'
                                             ,'READY_TO_CANCEL'
                                             ,'STOPED'
                                             ,'QUIT_DECL'
                                             ,'TO_QUIT'
                                             ,'TO_QUIT_CHECK_READY'
                                             ,'TO_QUIT_CHECKED'
                                             ,'CANCEL'
                                             ,'QUIT'
                                             ,'QUIT_REQ_QUERY'
                                             ,'QUIT_REQ_GET'
                                             ,'QUIT_TO_PAY'))
    LOOP
      -- ��������� ������� ����������� �����������
      IF vr_pol_stop.policy_status_brief = 'STOPED'
      THEN
        -- ���� �������� �������� �����
        v_rejection_id := pkg_t_mpos_rejection_dml.get_id_by_brief('POLICY_EXPIRED');
      ELSE
        -- ����������� ��������
        v_rejection_id := pkg_t_mpos_rejection_dml.get_id_by_brief('POLICY_BREAK');
      END IF;
      pkg_mpos_writeoff_form_dml.set_rejection_status(par_mpos_writeoff_form_id => vr_pol_stop.mpos_writeoff_form_id
                                                     ,par_t_mpos_rejection_id   => v_rejection_id);
      -- ����� ������� �����������
      doc.set_doc_status(p_doc_id => vr_pol_stop.mpos_writeoff_form_id, p_status_brief => 'STOPED');
      -- ����� ������� ���������
      IF vr_pol_stop.mpos_writeoff_cancel_id IS NOT NULL
      THEN
        doc.set_doc_status(p_doc_id       => vr_pol_stop.mpos_writeoff_cancel_id
                          ,p_status_brief => 'CANCEL');
      END IF;
    END LOOP;
    /*
      �������� �������� ����������� � �������� �������������� ��������.
      ��� ��� ����������� � �������� �������������� �������� ���������
      ���� �������� ����� 1 ��� ����� ��������, �� ��� ����
      ����������� � �������� �������������� �������� � ������� ������������,
      ������� �������� ������� ���� � ���� ����� ��������� ������� ������ ��� ���� ���,
      ���������� ������ �� ������������ � ��������� � �������� ������
      "����� ���� �������� ���������"
    */
    FOR vr_expired IN (SELECT wf.mpos_writeoff_form_id
                         FROM mpos_writeoff_form wf
                             ,document           dc
                             ,doc_status_ref     dsr
                        WHERE wf.mpos_writeoff_form_id = dc.document_id
                          AND dc.doc_status_ref_id = dsr.doc_status_ref_id
                          AND dsr.brief = 'CONFIRMED'
                          AND MONTHS_BETWEEN(SYSDATE, wf.transaction_date) / 12 > 1)
    LOOP
      v_rejection_id := pkg_t_mpos_rejection_dml.get_id_by_brief('NOTICE_EXPIRED');
      pkg_mpos_writeoff_form_dml.set_rejection_status(par_mpos_writeoff_form_id => vr_expired.mpos_writeoff_form_id
                                                     ,par_t_mpos_rejection_id   => v_rejection_id);
      -- ����� ������� �����������
      doc.set_doc_status(p_doc_id => vr_expired.mpos_writeoff_form_id, p_status_brief => 'STOPED');
    END LOOP;
  END stop_confirmed_writeoff_forms;

  /*
    ������ �.
    
    ��. � �������� ��. ������
    ������� ����� - �������
            ����������� - �������
            
     17-03-2015 ��������� �� ����� �����  ���-�������          
  */
  PROCEDURE cancel_writeoff_form(par_mpos_writeoff_form_id mpos_writeoff_form.mpos_writeoff_form_id%TYPE) IS
    vr_mpos_writeoff_form mpos_writeoff_form%ROWTYPE;
    v_sent_successfully   BOOLEAN;
    v_json_answer         JSON;
    v_error               VARCHAR2(32000);
  BEGIN
    assert_deprecated(par_mpos_writeoff_form_id IS NULL
                     ,'�������� �������������� ����������� � �������� �� ������ ���� �������');
    vr_mpos_writeoff_form := pkg_mpos_writeoff_form_dml.get_record(par_mpos_writeoff_form_id);
    IF vr_mpos_writeoff_form.t_mpos_rejection_id IS NULL
    THEN
      raise_application_error(-20001
                             ,'���� "������� ������" ������ ���� ���������');
    END IF;
  
    assert_deprecated(par_mpos_writeoff_form_id IS NULL
                     ,'�������� �������������� ����������� � �������� �� ������ ���� �������');
  
    vr_mpos_writeoff_form := pkg_mpos_writeoff_form_dml.get_record(par_mpos_writeoff_form_id);
  
    req_m4bank_stopinstallments(par_installment_id => vr_mpos_writeoff_form.transaction_id
                               ,par_is_success_out => v_sent_successfully
                               ,par_result_out     => v_json_answer
                               ,par_error_out      => v_error);
  
    IF NOT v_sent_successfully
    THEN
      doc.set_doc_status(p_doc_id => par_mpos_writeoff_form_id, p_status_brief => 'CANCEL_NOT_SENT');
    END IF;
  END cancel_writeoff_form;

  FUNCTION get_confirmed_templ_by_header(par_pol_header_id p_pol_header.policy_header_id%TYPE)
    RETURN mpos_writeoff_form.mpos_writeoff_form_id%TYPE IS
    var_mpos_id mpos_writeoff_form.mpos_writeoff_form_id%TYPE;
  BEGIN
    BEGIN
      SELECT wf.mpos_writeoff_form_id
        INTO var_mpos_id
        FROM mpos_writeoff_form wf
            ,document           dc
            ,doc_status_ref     dsr
       WHERE wf.policy_header_id = par_pol_header_id
         AND wf.mpos_writeoff_form_id = dc.document_id
         AND dc.doc_status_ref_id = dsr.doc_status_ref_id
         AND dsr.brief IN ('CONFIRMED', 'CONFIRMED_NOT_SENT');
    EXCEPTION
      WHEN no_data_found THEN
        NULL;
      WHEN too_many_rows THEN
        ex.raise('������� ��������� �������������� ����������� �� ��������');
    END;
    RETURN var_mpos_id;
  END get_confirmed_templ_by_header;

  /*
    ������ �.
    
    ������������ ����������� � �� �� ��������� ����������� � ��
    ����������� � �������� ��.
    "��. � �������� ��. ������������ ����������� � ��������"
    ����������� �� �������� "<�������� ��������>" - "�����"
  */

  PROCEDURE create_notice_from_form(par_mpos_writeoff_form_id mpos_writeoff_form.mpos_writeoff_form_id%TYPE) IS
    vr_writeoff_form mpos_writeoff_form%ROWTYPE;
    v_dummy_id       mpos_writeoff_notice.mpos_writeoff_notice_id%TYPE;
  BEGIN
    assert_deprecated(par_mpos_writeoff_form_id IS NULL
                     ,'�������� �������������� ����������� � �������� �� ������ ���� �������');
  
    vr_writeoff_form := pkg_mpos_writeoff_form_dml.get_record(par_mpos_writeoff_form_id => par_mpos_writeoff_form_id);
  
    IF pkg_t_mpos_payment_status_dml.get_id_by_brief('COMPLETED') =
       vr_writeoff_form.t_mpos_payment_status_id
    THEN
    
      dml_mpos_writeoff_notice.insert_record(par_transaction_date        => vr_writeoff_form.transaction_date
                                            ,par_transaction_id          => vr_writeoff_form.transaction_id
                                            ,par_t_payment_system_id     => vr_writeoff_form.t_payment_system_id
                                            ,par_writeoff_number         => 1
                                            ,par_amount                  => vr_writeoff_form.amount
                                            ,par_cliche                  => vr_writeoff_form.cliche
                                            ,par_rrn                     => vr_writeoff_form.rrn
                                            ,par_description             => vr_writeoff_form.description
                                            ,par_terminal_bank_id        => vr_writeoff_form.terminal_bank_id
                                            ,par_card_number             => vr_writeoff_form.card_number
                                            ,par_device_id               => vr_writeoff_form.device_id
                                            ,par_device_name             => vr_writeoff_form.device_name
                                            ,par_device_model            => vr_writeoff_form.device_model
                                            ,par_mpos_writeoff_form_id   => par_mpos_writeoff_form_id
                                            ,par_processing_result       => '000'
                                            ,par_mpos_writeoff_notice_id => v_dummy_id);
    
      doc.set_doc_status(p_doc_id => v_dummy_id, p_status_brief => 'NEW');
    END IF;
  END create_notice_from_form;

  /*
    ������ �.
    
    ��������� �� ������ �� �������������� ��������
    ������� �������� "�����" - "�����������"
    
    ��������� �� ������ �� ��. �������������
  
    ����������� � �������� �� ����������� � ������ ��������� � ����������� ����
    �������� ������ ��������� ���������� �������
  */
  PROCEDURE confirm_writeoff_cancel(par_mpos_writeoff_cancel_id mpos_writeoff_cancel.mpos_writeoff_cancel_id%TYPE) IS
    vr_writeoff_cancel    mpos_writeoff_cancel%ROWTYPE;
    v_t_mpos_rejection_id mpos_writeoff_form.t_mpos_rejection_id%TYPE;
  BEGIN
    assert_deprecated(par_mpos_writeoff_cancel_id IS NULL
                     ,'������� �������� par_mpos_writeoff_form_id �� ����� ��������');
    vr_writeoff_cancel := pkg_mpos_writeoff_cancel_dml.get_record(par_mpos_writeoff_cancel_id => par_mpos_writeoff_cancel_id);
  
    IF vr_writeoff_cancel.mpos_writeoff_form_id IS NOT NULL
    THEN
      v_t_mpos_rejection_id := pkg_t_mpos_rejection_dml.get_id_by_brief(par_brief          => 'PAYER_REJECTION'
                                                                       ,par_raise_on_error => FALSE);
      pkg_mpos_writeoff_form_dml.set_rejection_status(par_mpos_writeoff_form_id => vr_writeoff_cancel.mpos_writeoff_form_id
                                                     ,par_t_mpos_rejection_id   => v_t_mpos_rejection_id);
      doc.set_doc_status(p_doc_id       => vr_writeoff_cancel.mpos_writeoff_form_id
                        ,p_status_brief => 'STOPED');
    ELSE
      raise_application_error(-20001
                             ,'���������� ����������� ���������, �.�. �� ������� ��������� � ��');
    END IF;
  END confirm_writeoff_cancel;

  /*
    ������ �.
    
    ��. � �������� ��. �������������. ����� �������� �����������
    ������� �������� "�����" - "�����������"
    ������ ������ ������
  */

  PROCEDURE search_writeoff_form_policy(par_mpos_writeoff_form_id mpos_writeoff_form.mpos_writeoff_form_id%TYPE) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    vr_writeoff_form mpos_writeoff_form%ROWTYPE;
  BEGIN
    assert_deprecated(par_mpos_writeoff_form_id IS NULL
                     ,'������� �������� par_mpos_writeoff_form_id �� ����� ��������');
    -- ��������� ������
    vr_writeoff_form := pkg_mpos_writeoff_form_dml.get_record(par_mpos_writeoff_form_id => par_mpos_writeoff_form_id);
    -- ���� ��� ��� ������������� ������, ���� �� �� ���.
    -- ���� ��� ��� ������������� �� ������, ���� �� ������ �� �����������
    vr_writeoff_form.policy_header_id := pkg_policy.get_policy_header_by_ids(par_ids            => nvl(vr_writeoff_form.ids_for_recognition
                                                                                                      ,to_number(vr_writeoff_form.policy_number))
                                                                            ,par_raise_on_error => FALSE);
  
    IF vr_writeoff_form.policy_header_id IS NULL
    THEN
      raise_application_error(-20001
                             ,'�� ������ ������� � ��� "' ||
                              to_char(nvl(vr_writeoff_form.ids_for_recognition
                                         ,to_number(vr_writeoff_form.policy_number))) || '"');
    
    ELSE
      pkg_mpos_writeoff_form_dml.set_pol_header(par_mpos_writeoff_form_id => par_mpos_writeoff_form_id
                                               ,par_policy_header_id      => vr_writeoff_form.policy_header_id);
      COMMIT;
    END IF;
  END search_writeoff_form_policy;

  /*
    ������ �.
  
    ����������� � �������� �������������� ��������
    ��. � �������� ��. �������������
    ������� �������� "�����" - "�����������"
    
    ����������� � ������������ ������
  */
  PROCEDURE confirm_writeoff_form(par_mpos_writeoff_form_id mpos_writeoff_form.mpos_writeoff_form_id%TYPE) IS
    TYPE tt_errors IS TABLE OF VARCHAR2(500);
    vt_errors tt_errors := tt_errors();
  
    v_error_message          VARCHAR2(2000);
    v_pol_active_ver_status  doc_status_ref.brief%TYPE;
    v_pol_last_ver_status    doc_status_ref.brief%TYPE;
    v_insured_id             contact.contact_id%TYPE;
    v_contact_name           contact.obj_name_orig%TYPE;
    v_policy_fund_id         fund.fund_id%TYPE;
    vr_writeoff_form         mpos_writeoff_form%ROWTYPE;
    vr_policy                p_policy%ROWTYPE;
    vr_pol_header            p_pol_header%ROWTYPE;
    v_last_uncanceled_ver_id p_pol_header.last_ver_id%TYPE;
    -- �������� ������������� ������� ����������� � �������� �������������� ��������, ���������� � ��� �� ���������
    FUNCTION is_another_form_exists
    (
      par_mpos_writeoff_form_id mpos_writeoff_form.mpos_writeoff_form_id%TYPE
     ,par_pol_header_id         p_pol_header.policy_header_id%TYPE
    ) RETURN BOOLEAN IS
      v_is_exists NUMBER(1);
    BEGIN
      SELECT COUNT(1)
        INTO v_is_exists
        FROM dual
       WHERE EXISTS (SELECT NULL
                FROM mpos_writeoff_form wf
                    ,document           dc
                    ,doc_status_ref     dsr
               WHERE wf.policy_header_id = par_pol_header_id
                 AND wf.mpos_writeoff_form_id != par_mpos_writeoff_form_id
                 AND wf.mpos_writeoff_form_id = dc.document_id
                 AND dc.doc_status_ref_id = dsr.doc_status_ref_id
                 AND dsr.brief IN ('CONFIRMED', 'CONFIRMED_NOT_SENT'));
      RETURN v_is_exists = 1;
    END is_another_form_exists;
  BEGIN
    assert_deprecated(par_mpos_writeoff_form_id IS NULL
                     ,'������� �������� par_mpos_writeoff_form_id �� ����� ��������');
    -- ��������� ������
    vr_writeoff_form := pkg_mpos_writeoff_form_dml.get_record(par_mpos_writeoff_form_id => par_mpos_writeoff_form_id);
  
    IF vr_writeoff_form.policy_header_id IS NULL
    THEN
      raise_application_error(-20001, '����������� ������� �����������.');
    
    END IF;
    -- ���������
    vr_pol_header := pkg_policy.get_header_record(par_policy_header_id => vr_writeoff_form.policy_header_id);
    -- ��������� �� ���������� ������
    v_last_uncanceled_ver_id := pkg_policy.get_last_active_version(par_policy_id => vr_pol_header.last_ver_id);
    --�������� ������� ��������
    v_pol_active_ver_status := doc.get_last_doc_status_brief(p_document_id => vr_pol_header.policy_id);
    IF v_pol_active_ver_status IN ('READY_TO_CANCEL'
                                  ,'STOPED'
                                  ,'QUIT_DECL'
                                  ,'TO_QUIT'
                                  ,'TO_QUIT_CHECK_READY'
                                  ,'TO_QUIT_CHECKED'
                                  ,'CANCEL'
                                  ,'QUIT'
                                  ,'QUIT_REQ_QUERY'
                                  ,'QUIT_REQ_GET'
                                  ,'QUIT_TO_PAY')
    THEN
      vr_writeoff_form.t_mpos_rejection_id := pkg_t_mpos_rejection_dml.get_id_by_brief('POLICY_NOT_VALID');
      pkg_mpos_writeoff_form_dml.set_rejection_status(par_mpos_writeoff_form_id => par_mpos_writeoff_form_id
                                                     ,par_t_mpos_rejection_id   => vr_writeoff_form.t_mpos_rejection_id);
      doc.set_doc_status(p_doc_id => par_mpos_writeoff_form_id, p_status_brief => 'CANCEL');
    ELSE
      vr_policy := pkg_policy.get_version_record(par_policy_id => v_last_uncanceled_ver_id /*vr_pol_header.last_ver_id*/);
      -- ������������
      v_insured_id := pkg_policy.get_policy_holder_id(p_policy_id => v_last_uncanceled_ver_id /*vr_pol_header.last_ver_id*/);
      -- ��� ������������ �� ��������
      v_contact_name := pkg_contact.get_contact_name_by_id(par_contact_id     => v_insured_id
                                                          ,par_raise_on_error => TRUE);
      -- ���������� ��� �� �� � �� �����������
      IF TRIM(upper(v_contact_name)) != TRIM(upper(vr_writeoff_form.insured_name))
      THEN
        vt_errors.extend(1);
        vt_errors(vt_errors.count) := '���, ��������� � ����������� � ��� � �������� ����������� �� �����';
      END IF;
    
      -- ���� ��������� ������ ����������, ��������� �� � �������� ������
      v_pol_last_ver_status := doc.get_last_doc_status_brief(p_document_id => v_last_uncanceled_ver_id /*vr_pol_header.last_ver_id*/);
      IF v_pol_last_ver_status = 'INDEXATING'
      THEN
        IF vr_writeoff_form.amount NOT IN (nvl(pkg_policy.get_policy_fee(par_policy_id          => vr_pol_header.policy_id
                                                                        ,par_include_admin_cost => FALSE)
                                              ,0)
                                          ,nvl(pkg_policy.get_policy_fee(par_policy_id          => vr_pol_header.policy_id
                                                                        ,par_include_admin_cost => TRUE)
                                              ,0)
                                          ,nvl(pkg_policy.get_policy_fee(par_policy_id          => v_last_uncanceled_ver_id /*vr_pol_header.last_ver_id*/
                                                                        ,par_include_admin_cost => FALSE)
                                              ,0))
        THEN
          vt_errors.extend(1);
          vt_errors(vt_errors.count) := '����� �������� ����������� � ����� ������-������ � �������� ����������� �� �����';
        END IF;
        -- ���� �� ����������, ������ ��������� ������
      ELSIF vr_writeoff_form.amount NOT IN (nvl(pkg_policy.get_policy_fee(par_policy_id          => v_last_uncanceled_ver_id /*vr_pol_header.last_ver_id*/
                                                                         ,par_include_admin_cost => FALSE)
                                               ,0)
                                           ,nvl(pkg_policy.get_policy_fee(par_policy_id          => v_last_uncanceled_ver_id /*vr_pol_header.last_ver_id*/
                                                                         ,par_include_admin_cost => TRUE)
                                               ,0))
      THEN
        vt_errors.extend(1);
        vt_errors(vt_errors.count) := '����� �������� ����������� � ����� ������-������ � �������� ����������� �� �����';
      END IF;
    
      v_policy_fund_id := pkg_policy.get_policy_fund_id_by_header(par_pol_header_id  => vr_writeoff_form.policy_header_id
                                                                 ,par_raise_on_error => TRUE);
    
      -- �������, ����� ������ �������� ���� �������
      -- (��������, ���� ������ �� ������ ��������� �� �����������)
      IF v_policy_fund_id != 122 -- RUR
      THEN
        vt_errors.extend(1);
        vt_errors(vt_errors.count) := '������ ������ �������� ����������� ������ ���� "RUR"';
      END IF;
    
      -- ���������� ������������� �������� �� �� � �� �����������
      IF vr_policy.payment_term_id != vr_writeoff_form.t_payment_terms_id
      THEN
        vt_errors.extend(1);
        vt_errors(vt_errors.count) := '������������� �������� ����������� � ������������� �������� � �������� ����������� �� �����';
      END IF;
    
      -- �������� ���������� ��� ������������ ��������
      -- ����������� � �������� �������������� �������� � ������� ������������. 
      IF is_another_form_exists(par_mpos_writeoff_form_id, vr_writeoff_form.policy_header_id)
      THEN
        vt_errors.extend(1);
        vt_errors(vt_errors.count) := '� ����������� ��������� ��� ������� ������ ����������� � ������� "�����������"';
      END IF;
    END IF;
    IF vt_errors.count > 0
    THEN
      FOR v_idx IN vt_errors.first .. vt_errors.last
      LOOP
        v_error_message := v_error_message || chr(10) || vt_errors(v_idx);
      END LOOP;
      raise_application_error(-20001, v_error_message);
    END IF;
  END confirm_writeoff_form;

  /* 17-03-2015 ��������� �� ����� �����  ���-������� */
  PROCEDURE send_confirm_write_off_form(par_mpos_writeoff_form_id mpos_writeoff_form.mpos_writeoff_form_id%TYPE) IS
    vr_writeoff_form    mpos_writeoff_form%ROWTYPE;
    v_sent_successfully BOOLEAN DEFAULT FALSE;
    v_json_answer       JSON;
    v_error             VARCHAR2(32000);
  BEGIN
    assert_deprecated(par_mpos_writeoff_form_id IS NULL
                     ,'������� �������� par_mpos_writeoff_form_id �� ����� ��������');
    -- ������� �� ������
    IF doc.get_doc_status_brief(doc_id => par_mpos_writeoff_form_id) = 'CONFIRMED'
    THEN
      -- ��������� ������
      vr_writeoff_form := pkg_mpos_writeoff_form_dml.get_record(par_mpos_writeoff_form_id => par_mpos_writeoff_form_id);
    
      req_m4bank_confirminstallments(par_installment_id => vr_writeoff_form.transaction_id
                                    ,par_is_success_out => v_sent_successfully
                                    ,par_result_out     => v_json_answer
                                    ,par_error_out      => v_error);
    
      IF NOT v_sent_successfully
      THEN
        doc.set_doc_status(p_doc_id       => par_mpos_writeoff_form_id
                          ,p_status_brief => 'CONFIRMED_NOT_SENT');
      END IF;
    END IF;
  END send_confirm_write_off_form;

  /*���������� ������ ���������*/
  FUNCTION get_work_status
  (
    par_mpos_writeoff_form_id mpos_writeoff_form.mpos_writeoff_form_id%TYPE
   ,par_processing_result     mpos_writeoff_notice.processing_result%TYPE
  ) RETURN mpos_writeoff_notice.work_status%TYPE IS
    v_work_status   mpos_writeoff_notice.work_status%TYPE := pkg_mpos.gc_work_status_processed; --���������
    v_t_mpos_result t_mpos_result.t_mpos_result_id%TYPE;
  BEGIN
    /*���� ��� ������ �� ���������, �� ������ '��� ���������'*/
    IF par_mpos_writeoff_form_id IS NULL
    THEN
      v_work_status := pkg_mpos.gc_work_status_no_notice; --��� ���������
    ELSE
      BEGIN
        v_t_mpos_result := dml_t_mpos_result.get_id_by_result_code(pkg_mpos.get_result_code(par_processing_result)
                                                                  ,par_raise_on_error => FALSE);
      EXCEPTION
        WHEN no_data_found THEN
          v_t_mpos_result := dml_t_mpos_result.get_id_by_process_description(pkg_mpos.get_result_code(pkg_mpos.get_result_code(par_processing_result))
                                                                            ,par_raise_on_error => FALSE);
      END;
    
      /*���� � ����������� ����������� ��� ������ ����, �� ������ '��� ����������'*/
      IF v_t_mpos_result IS NULL
      THEN
        v_work_status := pkg_mpos.gc_work_status_no_result; --��� ����������
      END IF;
    END IF; --����� ���� ��� ������ �� ���������
    RETURN v_work_status;
  END get_work_status;

  /*�������� ��� ���������� �� ����� ������*/
  FUNCTION get_result_code(par_result_text VARCHAR2) RETURN NUMBER IS
  BEGIN
    RETURN to_number(regexp_substr(par_result_text, '^\d+'));
  END get_result_code;

  /*�������� ������ ����� ���������� �� ����� ������*/
  FUNCTION get_result_name(par_result_text VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN regexp_replace(par_result_text, '^\d+ - ');
  END get_result_name;
  /*
    ���������� �� ����������� � �������� �� �� ������� ���������� �� ������������ 2Can �������
    ������ �. 18.09.2014
  
  */
  FUNCTION get_writeoff_form_by_refuse
  (
    par_policy_number    mpos_writeoff_notice.processing_policy_number%TYPE
   ,par_transaction_date mpos_writeoff_notice.transaction_date%TYPE
   ,par_amount           mpos_writeoff_notice.amount%TYPE
   ,par_card_number      mpos_writeoff_notice.card_number%TYPE
  ) RETURN mpos_writeoff_form.mpos_writeoff_form_id%TYPE IS
    v_writeoff_form_id mpos_writeoff_form.mpos_writeoff_form_id%TYPE;
    vr_doc_status_ref  dml_doc_status_ref.tt_doc_status_ref;
    vr_writeoff_form   dml_mpos_writeoff_form.tt_mpos_writeoff_form;
  
    /*���������, ��� ����������� ����������� � �������� ����������� �� ������ �������*/
    FUNCTION was_writeoff_form_valid
    (
      par_mpos_writeoff_form_id mpos_writeoff_form.mpos_writeoff_form_id%TYPE
     ,par_transaction_date      mpos_writeoff_notice.transaction_date%TYPE
    ) RETURN BOOLEAN IS
      v_is_valid NUMBER;
    BEGIN
      SELECT COUNT(1)
        INTO v_is_valid
        FROM dual
       WHERE EXISTS (SELECT NULL
                FROM ven_mpos_writeoff_form wf
                    ,doc_status             ds
                    ,doc_status_ref         dsr
               WHERE wf.doc_status_id = ds.doc_status_id
                 AND wf.doc_status_ref_id = dsr.doc_status_ref_id
                 AND par_transaction_date BETWEEN wf.reg_date AND ds.change_date
                 AND wf.mpos_writeoff_form_id = par_mpos_writeoff_form_id);
      RETURN v_is_valid = 1;
    END was_writeoff_form_valid;
  
    /*������� ���� ���������, ���� ������� ���������
        ���������� �����������, � ������ �������� ������� ���� ������������ ��������:
    o ��� ����������� � ������� ��������� ��� �������� �������� �������� ��������� ����� �������� ��������
    � �������� ��� <���� �������� ���������; ���� ���������� ��������� �������>;
    o ��� ��������� �������� �������� �������� ��������� ����� �������� ������ ���� �������� ���������.
    � ���� ������� ���� �����������, �� � �������� ��������� �������� ������������ �� ���������� ���������.
    � ���� ������� ����� ������ �����������, �� � �������� ��������� �������� ������������ �� ����������� � �����
    �� �������� ������������, ������������. �� ������� � ����������. ���� ����� ����������� ���,
    �� ������� ����������� � ������������ ��.
    � ���� �� ������� �� ������ �����������, �� �������� ��������� ��������� �������� ������.
    */
    FUNCTION get_one_writeoff_form
    (
      par_policy_number    mpos_writeoff_notice.processing_policy_number%TYPE
     ,par_transaction_date mpos_writeoff_notice.transaction_date%TYPE
     ,par_amount           mpos_writeoff_notice.amount%TYPE
     ,par_card_number      mpos_writeoff_notice.card_number%TYPE
    ) RETURN mpos_writeoff_form.mpos_writeoff_form_id%TYPE IS
      v_writeoff_form_id mpos_writeoff_form.mpos_writeoff_form_id%TYPE;
      /*������� ������ ���� �����������*/
      FUNCTION get_only_one_writeoff_form
      (
        par_policy_number    mpos_writeoff_notice.processing_policy_number%TYPE
       ,par_transaction_date mpos_writeoff_notice.transaction_date%TYPE
       ,par_amount           mpos_writeoff_notice.amount%TYPE
       ,par_card_number      mpos_writeoff_notice.card_number%TYPE
      ) RETURN mpos_writeoff_form.mpos_writeoff_form_id%TYPE IS
        v_writeoff_form_id mpos_writeoff_form.mpos_writeoff_form_id%TYPE;
      BEGIN
        BEGIN
          SELECT wf.mpos_writeoff_form_id
            INTO v_writeoff_form_id
            FROM mpos_writeoff_form wf
                ,document           dc
                ,doc_status_ref     dsr
                ,doc_status         ds
           WHERE wf.policy_number = par_policy_number
             AND wf.amount = par_amount
             AND substr(wf.card_number, -4) = substr(par_card_number, -4)
             AND wf.mpos_writeoff_form_id = dc.document_id
             AND dc.doc_status_ref_id = dsr.doc_status_ref_id
             AND dc.doc_status_id = ds.doc_status_id
             AND dsr.brief IN ('CONFIRMED', 'CONFIRMED_NOT_SENT') /*�����������, �����������. �� ��������� � ����������*/
             AND par_transaction_date > dc.reg_date;
        EXCEPTION
          WHEN no_data_found
               OR too_many_rows THEN
            /*������� ������������ ��, ���� �� ����� � ��������������*/
            SELECT MAX(wf.mpos_writeoff_form_id)
              INTO v_writeoff_form_id
              FROM mpos_writeoff_form wf
                  ,document           dc
                  ,doc_status_ref     dsr
                  ,doc_status         ds
             WHERE wf.policy_number = par_policy_number
               AND wf.amount = par_amount
               AND substr(wf.card_number, -4) = substr(par_card_number, -4)
               AND wf.mpos_writeoff_form_id = dc.document_id
               AND dc.doc_status_ref_id = dsr.doc_status_ref_id
               AND dc.doc_status_id = ds.doc_status_id
               AND (dsr.brief IN ('STOPED', 'CANCEL') AND par_transaction_date BETWEEN dc.reg_date AND
                   ds.change_date OR par_transaction_date > dc.reg_date);
        END;
      
        RETURN v_writeoff_form_id;
      END get_only_one_writeoff_form;
    
    BEGIN
      BEGIN
        SELECT wf.mpos_writeoff_form_id
          INTO v_writeoff_form_id
          FROM mpos_writeoff_form wf
              ,document           dc
              ,doc_status_ref     dsr
              ,doc_status         ds
         WHERE wf.policy_number = par_policy_number
           AND wf.amount = par_amount
           AND substr(wf.card_number, -4) = substr(par_card_number, -4)
           AND wf.mpos_writeoff_form_id = dc.document_id
           AND dc.doc_status_ref_id = dsr.doc_status_ref_id
           AND dc.doc_status_id = ds.doc_status_id
           AND (dsr.brief IN ('STOPED', 'CANCEL') AND par_transaction_date BETWEEN dc.reg_date AND
               ds.change_date OR par_transaction_date > dc.reg_date);
      EXCEPTION
        WHEN no_data_found THEN
          v_writeoff_form_id := NULL;
        WHEN too_many_rows THEN
          v_writeoff_form_id := get_only_one_writeoff_form(par_policy_number    => par_policy_number
                                                          ,par_transaction_date => par_transaction_date
                                                          ,par_amount           => par_amount
                                                          ,par_card_number      => par_card_number);
      END;
    
      RETURN v_writeoff_form_id;
    END get_one_writeoff_form;
  
  BEGIN
    BEGIN
      /*��������� ����������� � �������� ��*/
      SELECT wf.mpos_writeoff_form_id
        INTO v_writeoff_form_id
        FROM mpos_writeoff_form wf
       WHERE wf.policy_number = par_policy_number
         AND wf.amount = par_amount
         AND substr(wf.card_number, -4) = substr(par_card_number, -4);
    
      vr_writeoff_form := dml_mpos_writeoff_form.get_record(par_mpos_writeoff_form_id => v_writeoff_form_id);
      --����������� ������ ����������� � �������� ��, ���� �� "��������" ��� "������",
      --�� ��������� �������� ����������� �� ������ ����������
      vr_doc_status_ref := dml_doc_status_ref.get_record(par_doc_status_ref_id => vr_writeoff_form.doc_status_ref_id);
      IF vr_doc_status_ref.brief IN ('STOPED', 'CANCEL') /*"��������" ��� "������"*/
      THEN
        --���������, ��� ����������� ����������� �� ��� ������
        IF NOT was_writeoff_form_valid(par_mpos_writeoff_form_id => v_writeoff_form_id
                                      ,par_transaction_date      => par_transaction_date)
        THEN
          v_writeoff_form_id := NULL; --����������� �� ����������� �� ��� ������
        END IF;
      ELSE
        --��� ������ �������
        --���� ������� ������ ���� ����� ���� ����������� � �������� ��
        IF par_transaction_date <= vr_writeoff_form.reg_date
        THEN
          v_writeoff_form_id := NULL;
        END IF;
      END IF; --����� ������� �������� ����������� � �������� ��
    EXCEPTION
      WHEN no_data_found THEN
        v_writeoff_form_id := NULL; --��������� ������
      WHEN too_many_rows THEN
        --������� ���� ���������, ���� ������� ���������
        v_writeoff_form_id := get_one_writeoff_form(par_policy_number    => par_policy_number
                                                   ,par_transaction_date => par_transaction_date
                                                   ,par_amount           => par_amount
                                                   ,par_card_number      => par_card_number);
    END; --����� ������� ����������� �������� � ��
  
    RETURN v_writeoff_form_id;
  END get_writeoff_form_by_refuse;

  /*
    ������ �.
    
    ���������� �� ��������������� ����������� � �������� �� �� �� ��������� ��
  */
  FUNCTION get_writeoff_form_by_policy
  (
    par_pol_header_id  p_pol_header.policy_header_id%TYPE
   ,par_raise_on_error BOOLEAN DEFAULT TRUE
  ) RETURN mpos_writeoff_form.mpos_writeoff_form_id%TYPE IS
    v_writeoff_form_id mpos_writeoff_form.mpos_writeoff_form_id%TYPE;
  BEGIN
    BEGIN
      SELECT wf.mpos_writeoff_form_id
        INTO v_writeoff_form_id
        FROM mpos_writeoff_form wf
            ,document           dc
            ,doc_status_ref     dsr
       WHERE wf.policy_header_id = par_pol_header_id
         AND wf.mpos_writeoff_form_id = dc.document_id
         AND dc.doc_status_ref_id = dsr.doc_status_ref_id
         AND dsr.brief IN ('CONFIRMED', 'CONFIRMED_NOT_SENT');
    EXCEPTION
      WHEN no_data_found THEN
        IF par_raise_on_error
        THEN
          raise_application_error(-20001
                                 ,'�� ������� �������������� ����������� � �������� �������������� �������� �� �� �������� "' ||
                                  par_pol_header_id || '"');
        ELSE
          v_writeoff_form_id := NULL;
        END IF;
    END;
    RETURN v_writeoff_form_id;
  END get_writeoff_form_by_policy;

  PROCEDURE unbind_registr_from_pay_notice(par_mpos_payment_notice_id mpos_payment_notice.mpos_payment_notice_id%TYPE) IS
  BEGIN
    UPDATE mpos_payment_notice
       SET payment_register_item_id = NULL
     WHERE mpos_payment_notice_id = par_mpos_payment_notice_id;
  
    doc.set_doc_status(p_doc_id => par_mpos_payment_notice_id, p_status_brief => 'NEW');
  END unbind_registr_from_pay_notice;

  PROCEDURE bind_register_to_pay_notice
  (
    par_payment_register_item_id payment_register_item.payment_register_item_id%TYPE
   ,par_mpos_payment_notice_id   mpos_payment_notice.mpos_payment_notice_id%TYPE
  ) IS
  BEGIN
    UPDATE mpos_payment_notice
       SET payment_register_item_id = par_payment_register_item_id
     WHERE mpos_payment_notice_id = par_mpos_payment_notice_id;
  
    doc.set_doc_status(p_doc_id => par_mpos_payment_notice_id, p_status_brief => 'LOADED');
  END bind_register_to_pay_notice;

  PROCEDURE unbind_register_from_wo_notice
  (
    par_payment_register_item_id payment_register_item.payment_register_item_id%TYPE
   ,par_mpos_writeoff_notice_id  mpos_writeoff_notice.mpos_writeoff_notice_id%TYPE
  ) IS
  BEGIN
    UPDATE mpos_writeoff_notice
       SET payment_register_item_id = NULL
     WHERE mpos_writeoff_notice_id = par_mpos_writeoff_notice_id;
  
    doc.set_doc_status(p_doc_id => par_mpos_writeoff_notice_id, p_status_brief => 'NEW');
  END unbind_register_from_wo_notice;

  PROCEDURE bind_register_to_wo_notice
  (
    par_payment_register_item_id payment_register_item.payment_register_item_id%TYPE
   ,par_mpos_writeoff_notice_id  mpos_writeoff_notice.mpos_writeoff_notice_id%TYPE
  ) IS
  BEGIN
    UPDATE mpos_writeoff_notice
       SET payment_register_item_id = par_payment_register_item_id
     WHERE mpos_writeoff_notice_id = par_mpos_writeoff_notice_id;
  
    doc.set_doc_status(p_doc_id => par_mpos_writeoff_notice_id, p_status_brief => 'LOADED');
  END bind_register_to_wo_notice;

  FUNCTION get_xml_value
  (
    par_xml   xmltype
   ,par_xpath VARCHAR2
  ) RETURN VARCHAR2 IS
  BEGIN
    IF par_xml.existsnode(par_xpath) = 1
    THEN
      RETURN par_xml.extract(par_xpath).getstringval();
    ELSE
      RETURN NULL;
    END IF;
  END get_xml_value;

  PROCEDURE write_to_gate
  (
    par_xml          xmltype
   ,par_root_element VARCHAR2
   ,par_commit       BOOLEAN
   ,par_g_mpos_id    OUT g_mpos.g_mpos_id%TYPE
  ) IS
    vr_g_mpos g_mpos%ROWTYPE;
  BEGIN
    vr_g_mpos.import_date := SYSDATE;
  
    vr_g_mpos.writeoff_frequency := get_xml_value(par_xml, '/' || par_root_element || '/@Frequency');
  
    vr_g_mpos.transaction_init_id := get_xml_value(par_xml
                                                  ,'/' || par_root_element ||
                                                   '/@InitialInstallmentPayment');
    vr_g_mpos.writeoff_number     := get_xml_value(par_xml
                                                  ,'/' || par_root_element || '/@InstallemntIndex');
    vr_g_mpos.rrn                 := get_xml_value(par_xml, '/' || par_root_element || '/@RRN');
    vr_g_mpos.transaction_date    := get_xml_value(par_xml, '/' || par_root_element || '/@CreatedAt');
    vr_g_mpos.amount              := get_xml_value(par_xml, '/' || par_root_element || '/@Amount');
    vr_g_mpos.payment_status      := get_xml_value(par_xml, '/' || par_root_element || '/@Status');
    vr_g_mpos.description         := get_xml_value(par_xml, '/' || par_root_element || '/@Description');
    vr_g_mpos.ins_premium         := get_xml_value(par_xml
                                                  ,'/' || par_root_element ||
                                                   '/InsurancePaymentData/@InsurancePremium');
    vr_g_mpos.payment_system      := get_xml_value(par_xml, '/' || par_root_element || '/@CardType');
    vr_g_mpos.terminal_bank_id    := get_xml_value(par_xml, '/' || par_root_element || '/@TID');
    vr_g_mpos.cliche              := get_xml_value(par_xml, '/' || par_root_element || '/@MID');
    vr_g_mpos.card_number         := get_xml_value(par_xml, '/' || par_root_element || '/@Card');
    vr_g_mpos.device_id           := get_xml_value(par_xml, '/' || par_root_element || '/Device/@Id');
    vr_g_mpos.device_name         := get_xml_value(par_xml, '/' || par_root_element || '/Device/@Name');
    vr_g_mpos.device_model        := get_xml_value(par_xml
                                                  ,'/' || par_root_element || '/Device/@Model');
    vr_g_mpos.insured_name        := get_xml_value(par_xml
                                                  ,'/' || par_root_element ||
                                                   '/InsurancePaymentData/@InsuredName');
    vr_g_mpos.product_name        := get_xml_value(par_xml
                                                  ,'/' || par_root_element ||
                                                   '/InsurancePaymentData/@InsuranceProduct');
    vr_g_mpos.policy_number       := get_xml_value(par_xml
                                                  ,'/' || par_root_element ||
                                                   '/InsurancePaymentData/@ContractNumber');
    vr_g_mpos.transaction_id      := get_xml_value(par_xml, '/' || par_root_element || '/@Id');
  
    vr_g_mpos.policy_start_date := get_xml_value(par_xml
                                                ,'/' || par_root_element ||
                                                 '/InsurancePaymentData/PolicyDate/text()');
    --���� ������ �������, ������������� ������ 9999
    vr_g_mpos.result_code := nvl(get_xml_value(par_xml, '/' || par_root_element || '/@HRC'), '9999');
  
    pkg_g_mpos_dml.insert_record(par_record => vr_g_mpos);
  
    par_g_mpos_id := vr_g_mpos.g_mpos_id;
  
    IF par_commit
    THEN
      COMMIT;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
      --raise_application_error(cant_write_exception, '������ ������ � ����');
  END write_to_gate;

  PROCEDURE convert_values
  (
    par_g_mpos    g_mpos%ROWTYPE
   ,par_converted OUT t_converted_values
  ) IS
    v_delimeter VARCHAR2(1) := pkg_utils.get_numeric_delimeter(par_raise_on_error => TRUE);
  BEGIN
    -- �����������
    IF par_g_mpos.writeoff_frequency IS NOT NULL
    THEN
      BEGIN
        par_converted.t_payment_terms_id := get_t_paym_terms_id_by_ext_id(to_number(par_g_mpos.writeoff_frequency));
      EXCEPTION
        WHEN value_error THEN
          raise_application_error(-20001
                                 ,'������ �������������� ������� �������� (' ||
                                  par_g_mpos.writeoff_frequency || ') � �����');
      END;
    END IF;
    -- ������������� ���������� ��������
    IF par_g_mpos.transaction_init_id IS NOT NULL
    THEN
      par_converted.mpos_writeoff_form_id := pkg_mpos_writeoff_form_dml.get_id_by_transaction_id(par_transaction_id => par_g_mpos.transaction_init_id);
    END IF;
    -- ���������� ����� ��������
    IF par_g_mpos.writeoff_number IS NOT NULL
    THEN
      BEGIN
        par_converted.writeoff_number := to_number(par_g_mpos.writeoff_number);
      EXCEPTION
        WHEN value_error THEN
          raise_application_error(-20001
                                 ,'������ �������������� ����������� ������ �������� (' ||
                                  par_g_mpos.writeoff_number || ') � �����');
      END;
    END IF;
    -- ���������� ������������� ���������� � ����������� 2can
    IF par_g_mpos.transaction_id IS NOT NULL
    THEN
      BEGIN
        par_converted.transaction_id := to_number(par_g_mpos.transaction_id);
      EXCEPTION
        WHEN value_error THEN
          raise_application_error(-20001
                                 ,'������ �������������� �������������� ���������� (' ||
                                  par_g_mpos.transaction_id || ') � �����');
      END;
    END IF;
    -- �����
    IF par_g_mpos.amount IS NOT NULL
    THEN
      BEGIN
        par_converted.amount := to_number(regexp_replace(par_g_mpos.amount, '[,.]', v_delimeter));
      EXCEPTION
        WHEN value_error THEN
          raise_application_error(-20001
                                 ,'������ �������������� ����� (' || par_g_mpos.amount || ') � �����');
      END;
    END IF;
    -- ��������� �������
    IF par_g_mpos.payment_status IS NOT NULL
    THEN
      par_converted.t_mpos_payment_status_id := pkg_t_mpos_payment_status_dml.get_id_by_brief(upper(par_g_mpos.payment_status));
    END IF;
    -- ���� �������� ����������
    IF par_g_mpos.transaction_date IS NOT NULL
    THEN
      IF regexp_like(par_g_mpos.transaction_date
                    ,'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{1,3}[+-]\d{2}:\d{2}$')
      THEN
        /* ������� �� ����������, �.�. ��� ��������� ������ timestamp
        SELECT to_date(to_char(to_timestamp_tz(REPLACE(par_g_mpos.transaction_date, 'T')
                                             ,'yyyy-MM-dd HH24:MI:SS.FF3+TZH:TZM') at TIME ZONE
                              'Europe/Moscow'
                             ,'dd.mm.yyyy HH24:MI:SS')
                     ,'dd.mm.yyyy HH24:MI:SS')
         INTO par_converted.transaction_date
         FROM dual;*/
        SELECT to_date(regexp_replace(REPLACE(par_g_mpos.transaction_date, 'T')
                                     ,'\.\d{3}\+\d{2}:\d{2}')
                      ,'yyyy-mm-ddHH24:MI:SS')
          INTO par_converted.transaction_date
          FROM dual;
      ELSE
        raise_application_error(-20001
                               ,'�������� ������ ���� �������� ���������� (' ||
                                par_g_mpos.transaction_date || ')');
      END IF;
    END IF;
    -- �������� ��������� ��� ������
    par_converted.description := par_g_mpos.description;
    -- ����� �������� � ��������� �������
    par_converted.rrn := par_g_mpos.rrn;
    -- ��� �����
    par_converted.t_payment_system_id := pkg_t_payment_system_dml.get_id_by_ext_name(upper(par_g_mpos.payment_system));
    -- ������������� ��������� � �����
    par_converted.terminal_bank_id := par_g_mpos.terminal_bank_id;
    -- ����� mPOS
    par_converted.cliche := par_g_mpos.cliche;
    -- ������ 6 � ��������� 4 ����� ������ �����
    par_converted.card_number := par_g_mpos.card_number;
  
    -- ���������� ������ �� ����������
    -- ���������� ������������� ���������� � �����������
    IF par_g_mpos.device_id IS NOT NULL
    THEN
      BEGIN
        par_converted.device_id := to_number(par_g_mpos.device_id);
      EXCEPTION
        WHEN value_error THEN
          raise_application_error(-20001
                                 ,'������ �������������� �������������� ���������� (' ||
                                  par_g_mpos.device_id || ') � �����');
      END;
    END IF;
    -- �������� ���������� ��������� �������������
    par_converted.device_name := par_g_mpos.device_name;
    -- ������ ����������
    par_converted.device_model := par_g_mpos.device_model;
    -- ������ ����������
    par_converted.device_model := par_g_mpos.device_model;
  
    -- ���������� ������ � ������
    -- ��� ������������
    par_converted.insured_name := par_g_mpos.insured_name;
    -- ��� ���������� ��������
    par_converted.product_name := par_g_mpos.product_name;
    -- ����� �������� �����������
    par_converted.policy_number := par_g_mpos.policy_number;
    -- ���� ������ �������� �����������
    IF par_g_mpos.policy_start_date IS NOT NULL
    THEN
      IF regexp_like(par_g_mpos.policy_start_date, '\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}')
      THEN
        par_converted.policy_start_date := to_date(REPLACE(par_g_mpos.policy_start_date, 'T')
                                                  ,'yyyy-mm-ddHH24:mi:ss');
      ELSE
        raise_application_error(-20001
                               ,'�������� ������ ���� ������ �������� ��������');
      END IF;
    END IF;
    -- ��������� ������
    IF par_g_mpos.ins_premium IS NOT NULL
    THEN
      BEGIN
        par_converted.ins_premium := to_number(regexp_replace(par_g_mpos.ins_premium
                                                             ,'[,.]'
                                                             ,v_delimeter));
      EXCEPTION
        WHEN value_error THEN
          raise_application_error(-20001
                                 ,'������ �������������� ��������� ������ (' || par_g_mpos.amount ||
                                  ') � �����');
      END;
    END IF;
  END convert_values;

  PROCEDURE save_error(par_g_mpos_id g_mpos.g_mpos_id%TYPE) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    UPDATE g_mpos gm
       SET gm.error_message   = substr(dbms_utility.format_error_stack, 1, 250)
          ,gm.error_backtrace = substr(dbms_utility.format_error_backtrace, 1, 250)
     WHERE gm.g_mpos_id = par_g_mpos_id;
    COMMIT;
  END save_error;

  PROCEDURE process_writeoff_notice
  (
    par_g_mpos_id g_mpos.g_mpos_id%TYPE
   ,par_commit    BOOLEAN DEFAULT TRUE
  ) IS
    vr_g_mpos                  g_mpos%ROWTYPE;
    vr_converted               t_converted_values;
    v_mpos_writeoff_notice_id  mpos_writeoff_notice.mpos_writeoff_notice_id%TYPE;
    v_mpos_result_id           NUMBER;
    v_successful_writeoff_flag NUMBER;
  BEGIN
    -- ����������� ������ �����
    vr_g_mpos := pkg_g_mpos_dml.get_record(par_g_mpos_id => par_g_mpos_id);
    convert_values(par_g_mpos => vr_g_mpos, par_converted => vr_converted);
  
    -- �������� ����������
  
    -- ������ � �������
    -- ���������� ������������� ���������� � ����������� 2can
    assert_deprecated(vr_converted.transaction_id IS NULL
                     ,'����������� �������� �������������� ����������');
    -- �����
    assert_deprecated(vr_converted.amount IS NULL
                     ,'����������� �������� �����');
    -- ���� �������� ����������
    assert_deprecated(vr_converted.transaction_date IS NULL
                     ,'����������� �������� ���� �������� ����������');
    -- ��� �����
    assert_deprecated(vr_converted.t_payment_system_id IS NULL
                     ,'����������� �������� ���� �����');
    -- ���������� ����� ��������
    assert_deprecated(vr_converted.writeoff_number IS NULL
                     ,'����������� �������� ����������� ������ ��������');
  
    -- id ���������� �������� mPOS
    get_mpos_result(vr_g_mpos.result_code, v_mpos_result_id, v_successful_writeoff_flag);
  
    -- ������� � ������� � ��������� �������
    dml_mpos_writeoff_notice.insert_record(par_transaction_date         => vr_converted.transaction_date
                                          ,par_transaction_id           => vr_converted.transaction_id
                                          ,par_t_payment_system_id      => vr_converted.t_payment_system_id
                                          ,par_writeoff_number          => vr_converted.writeoff_number
                                          ,par_amount                   => vr_converted.amount
                                          ,par_cliche                   => vr_converted.cliche
                                          ,par_g_mpos_id                => par_g_mpos_id
                                          ,par_rrn                      => vr_converted.rrn
                                          ,par_description              => vr_converted.description
                                          ,par_terminal_bank_id         => vr_converted.terminal_bank_id
                                          ,par_card_number              => vr_converted.card_number
                                          ,par_device_id                => vr_converted.device_id
                                          ,par_device_name              => vr_converted.device_name
                                          ,par_device_model             => vr_converted.device_model
                                          ,par_mpos_writeoff_form_id    => vr_converted.mpos_writeoff_form_id
                                          ,par_payment_register_item_id => NULL
                                          ,par_processing_result        => vr_g_mpos.result_code
                                          ,par_t_mpos_result_id         => v_mpos_result_id
                                          ,par_mpos_writeoff_notice_id  => v_mpos_writeoff_notice_id);
  
    CASE
      WHEN v_successful_writeoff_flag IS NULL THEN
        -- ������ = ������
        doc.set_doc_status(p_doc_id => v_mpos_writeoff_notice_id, p_status_brief => 'PROJECT');
      WHEN v_successful_writeoff_flag = 1 THEN
        -- ������ = �����
        doc.set_doc_status(p_doc_id => v_mpos_writeoff_notice_id, p_status_brief => 'NEW');
      WHEN v_successful_writeoff_flag = 0 THEN
        -- ������ = ����� 
        doc.set_doc_status(p_doc_id => v_mpos_writeoff_notice_id, p_status_brief => 'REFUSE');
    END CASE;
  
    IF par_commit
    THEN
      COMMIT;
    END IF;
  END process_writeoff_notice;

  PROCEDURE process_writeoff_form
  (
    par_g_mpos_id g_mpos.g_mpos_id%TYPE
   ,par_commit    BOOLEAN DEFAULT TRUE
  ) IS
    vr_g_mpos                  g_mpos%ROWTYPE;
    vr_converted               t_converted_values;
    v_mpos_writeoff_form_id    mpos_writeoff_form.mpos_writeoff_form_id%TYPE;
    v_mpos_result_id           NUMBER;
    v_successful_writeoff_flag NUMBER;
  BEGIN
    -- ����������� ������ �����
    vr_g_mpos := pkg_g_mpos_dml.get_record(par_g_mpos_id => par_g_mpos_id);
    convert_values(par_g_mpos => vr_g_mpos, par_converted => vr_converted);
  
    -- �������� ����������
  
    -- ������ � �������
    -- ������� ��������
    assert_deprecated(vr_converted.t_payment_terms_id IS NULL
                     ,'����������� �������� ������� ��������');
    -- ���������� ������������� ���������� � ����������� 2can
    assert_deprecated(vr_converted.transaction_id IS NULL
                     ,'����������� �������� �������������� ����������');
    -- �����
    assert_deprecated(vr_converted.amount IS NULL
                     ,'����������� �������� �����');
    -- ��������� �������
    assert_deprecated(vr_converted.t_mpos_payment_status_id IS NULL
                     ,'����������� �������� ��������� �������');
    -- ���� �������� ����������
    assert_deprecated(vr_converted.transaction_date IS NULL
                     ,'����������� �������� ���� �������� ����������');
    -- ��� �����
    assert_deprecated(vr_converted.t_payment_system_id IS NULL
                     ,'����������� �������� ���� �����');
  
    -- ���������� ������ � ������
    -- ��� ������������
    assert_deprecated(vr_converted.insured_name IS NULL
                     ,'����������� �������� ��� ������������');
    -- ����� �������� �����������
    assert_deprecated(vr_converted.policy_number IS NULL
                     ,'����������� �������� ������ �������� �����������');
  
    get_mpos_result(vr_g_mpos.result_code, v_mpos_result_id, v_successful_writeoff_flag);
  
    pkg_mpos_writeoff_form_dml.insert_record(par_t_payment_system_id      => vr_converted.t_payment_system_id
                                            ,par_fund_id                  => 122 -- ���� �� ������ �������, ������ �����
                                            ,par_transaction_id           => vr_converted.transaction_id
                                            ,par_t_payment_terms_id       => vr_converted.t_payment_terms_id
                                            ,par_policy_number            => vr_converted.policy_number
                                            ,par_transaction_date         => vr_converted.transaction_date
                                            ,par_insured_name             => TRIM(regexp_replace(vr_converted.insured_name
                                                                                                ,'\s+'
                                                                                                ,' '))
                                            ,par_t_mpos_payment_status_id => vr_converted.t_mpos_payment_status_id
                                            ,par_amount                   => vr_converted.amount
                                            ,par_policy_header_id         => NULL
                                            ,par_ins_premium              => vr_converted.ins_premium
                                            ,par_ids_for_recognition      => NULL
                                            ,par_product_name             => vr_converted.product_name
                                            ,par_device_model             => vr_converted.device_model
                                            ,par_device_name              => vr_converted.device_name
                                            ,par_device_id                => vr_converted.device_id
                                            ,par_card_number              => vr_converted.card_number
                                            ,par_cliche                   => vr_converted.cliche
                                            ,par_terminal_bank_id         => vr_converted.terminal_bank_id
                                            ,par_rrn                      => vr_converted.rrn
                                            ,par_description              => vr_converted.description
                                            ,par_g_mpos_id                => par_g_mpos_id
                                            ,par_t_mpos_rejection_id      => NULL
                                            ,par_mpos_writeoff_form_id    => v_mpos_writeoff_form_id);
  
    doc.set_doc_status(p_doc_id => v_mpos_writeoff_form_id, p_status_brief => 'NEW');
  
    IF par_commit
    THEN
      COMMIT;
    END IF;
  END process_writeoff_form;

  PROCEDURE process_payment_notice
  (
    par_g_mpos_id g_mpos.g_mpos_id%TYPE
   ,par_commit    BOOLEAN
  ) IS
    vr_g_mpos                  g_mpos%ROWTYPE;
    vr_converted               t_converted_values;
    v_mpos_payment_notice_id   mpos_payment_notice.mpos_payment_notice_id%TYPE;
    v_mpos_result_id           NUMBER;
    v_successful_writeoff_flag NUMBER;
  BEGIN
    -- ����������� ������ �����
    vr_g_mpos := pkg_g_mpos_dml.get_record(par_g_mpos_id => par_g_mpos_id);
    convert_values(par_g_mpos => vr_g_mpos, par_converted => vr_converted);
  
    -- �������� ����������
  
    -- ������ � �������
    -- ���������� ������������� ���������� � ����������� 2can
    assert_deprecated(vr_converted.transaction_id IS NULL
                     ,'����������� �������� �������������� ����������');
    -- �����
    assert_deprecated(vr_converted.amount IS NULL
                     ,'����������� �������� �����');
    -- ��������� �������
    assert_deprecated(vr_converted.t_mpos_payment_status_id IS NULL
                     ,'����������� �������� ��������� �������');
    -- ���� �������� ����������
    assert_deprecated(vr_converted.transaction_date IS NULL
                     ,'����������� �������� ���� �������� ����������');
    -- ��� �����
    assert_deprecated(vr_converted.t_payment_system_id IS NULL
                     ,'����������� �������� ���� �����');
  
    -- ���������� ������ � ������
    -- ��� ������������
    assert_deprecated(vr_converted.insured_name IS NULL
                     ,'����������� �������� ��� ������������');
    -- ����� �������� �����������
    assert_deprecated(vr_converted.policy_number IS NULL
                     ,'����������� �������� ������ �������� �����������');
  
    get_mpos_result(vr_g_mpos.result_code, v_mpos_result_id, v_successful_writeoff_flag);
  
    pkg_mpos_payment_notice_dml.insert_record(par_transaction_id           => vr_converted.transaction_id
                                             ,par_transaction_date         => vr_converted.transaction_date
                                             ,par_g_mpos_id                => par_g_mpos_id
                                             ,par_amount                   => vr_converted.amount
                                             ,par_t_payment_system_id      => vr_converted.t_payment_system_id
                                             ,par_policy_number            => vr_converted.policy_number
                                             ,par_policy_start_date        => vr_converted.policy_start_date
                                             ,par_t_mpos_payment_status_id => vr_converted.t_mpos_payment_status_id
                                             ,par_insured_name             => vr_converted.insured_name
                                             ,par_ins_premium              => vr_converted.ins_premium
                                             ,par_payment_register_item_id => NULL
                                             ,par_product_name             => vr_converted.product_name
                                             ,par_device_model             => vr_converted.device_model
                                             ,par_device_name              => vr_converted.device_name
                                             ,par_device_id                => vr_converted.device_id
                                             ,par_card_number              => vr_converted.card_number
                                             ,par_cliche                   => vr_converted.cliche
                                             ,par_terminal_bank_id         => vr_converted.terminal_bank_id
                                             ,par_rrn                      => vr_converted.rrn
                                             ,par_description              => vr_converted.description
                                             ,par_mpos_payment_notice_id   => v_mpos_payment_notice_id);
  
    doc.set_doc_status(p_doc_id => v_mpos_payment_notice_id, p_status_brief => 'NEW');
  
    IF par_commit
    THEN
      COMMIT;
    END IF;
  END process_payment_notice;

  /*
    ��������� ������ ������� �������� ����������� 2can
  */
  PROCEDURE process_2can_request
  (
    par_request VARCHAR2
   ,par_commit  BOOLEAN
  ) IS
    v_xml               xmltype;
    v_request_type      t_request_type;
    v_format_brief      t_exchange_format.brief%TYPE;
    v_format_id         t_exchange_format.t_exchange_format_id%TYPE;
    v_g_mpos_id         g_mpos.g_mpos_id%TYPE;
    vr_log_info         pkg_communication.typ_log_info;
    v_converted_request VARCHAR2(4000);
  BEGIN
    BEGIN
      -- ���������
      v_converted_request := utl_url.unescape(par_request, 'UTF-8');
      -- ������� ������ ���� �������
      v_converted_request := ltrim(v_converted_request, '?');
      -- ������
      v_xml := xmltype(v_converted_request);
      -- �������� �������� �������
      v_request_type := v_xml.getrootelement;
      -- �������� ������, �� �������� ���������
      CASE v_request_type
        WHEN 'Payment' THEN
          v_format_brief := '2CAN_PAYMENT_NOTICE';
        WHEN 'InitialInstallmentPayment' THEN
          v_format_brief := '2CAN_WRITEOFF_FORM';
        WHEN 'InstallmentPayment' THEN
          v_format_brief := '2CAN_WRITEOFF_NOTICE';
        ELSE
          raise_application_error(-20001, '������ �� ��������������');
      END CASE;
    
      v_format_id := pkg_t_exchange_format_dml.get_id_by_brief(par_brief => v_format_brief);
      -- ��������� �� ������������ �������
      pkg_exchange_format.validate_format(par_format_id => v_format_id, par_xml => v_xml);
      -- ����� � �������� �������
      write_to_gate(par_xml          => v_xml
                   ,par_root_element => v_request_type
                   ,par_g_mpos_id    => v_g_mpos_id
                   ,par_commit       => par_commit);
    EXCEPTION
      -- ���� ������ ���������� �� ��� �� ����� ������ � �������� �������
      -- ����� �� � ���
      WHEN OTHERS THEN
        IF par_commit
        THEN
          -- ���� ������ ��� �������� ��� ��� ������ � ����, �������� �����
          vr_log_info.operation_name        := v_request_type;
          vr_log_info.source_pkg_name       := 'pkg_mpos';
          vr_log_info.source_procedure_name := 'process_2can_request';
          pkg_communication.log(par_log_info      => vr_log_info
                               ,par_data          => par_request
                               ,par_error_message => dbms_utility.format_error_stack
                               ,par_backtrace     => dbms_utility.format_error_backtrace);
        END IF;
        RAISE;
    END;
    BEGIN
      -- � ����������� �� ���� ��������� �������� ���������� � �������� ���
      -- ��������� ������
      CASE v_request_type
        WHEN 'Payment' THEN
          -- ����������� � ���������� �������
          process_payment_notice(par_g_mpos_id => v_g_mpos_id, par_commit => par_commit);
        WHEN 'InitialInstallmentPayment' THEN
          -- ����������� � �������� �������������� ��������
          process_writeoff_form(par_g_mpos_id => v_g_mpos_id, par_commit => par_commit);
        WHEN 'InstallmentPayment' THEN
          -- ����������� � ������������� ��������
          process_writeoff_notice(par_g_mpos_id => v_g_mpos_id, par_commit => par_commit);
      END CASE;
    EXCEPTION
      -- ���� ����� ������ � ����, �� ����� ������ ����� � ������ �����
      WHEN OTHERS THEN
        IF par_commit
        THEN
          save_error(par_g_mpos_id => v_g_mpos_id);
        END IF;
        RAISE;
    END;
  END process_2can_request;

  /*
  ������ �.
  ��������� ������� �� ������ ���������� �� �����
  */
  PROCEDURE process_record_from_forms(par_mpos_writeoff_notice_id mpos_writeoff_notice.mpos_writeoff_notice_id%TYPE) IS
    vr_mpos_writeoff_notice dml_mpos_writeoff_notice.tt_mpos_writeoff_notice;
    v_mpos_writeoff_form_id mpos_writeoff_form.mpos_writeoff_form_id%TYPE;
  BEGIN
    vr_mpos_writeoff_notice := dml_mpos_writeoff_notice.get_record(par_mpos_writeoff_notice_id => par_mpos_writeoff_notice_id);
  
    /*���� ������ ��������� ������� "��� ���������" ��� "��� ����������", �� �������� ����� �������� � ��������� ���-�*/
    IF vr_mpos_writeoff_notice.work_status IN
       (pkg_mpos.gc_work_status_no_notice, pkg_mpos.gc_work_status_no_result) /*��� ��������� ��� ��� ����������*/
    THEN
      /*��������� ���������*/
      v_mpos_writeoff_form_id := get_writeoff_form_by_refuse(par_policy_number    => vr_mpos_writeoff_notice.processing_policy_number
                                                            ,par_transaction_date => vr_mpos_writeoff_notice.transaction_date
                                                            ,par_amount           => vr_mpos_writeoff_notice.amount
                                                            ,par_card_number      => vr_mpos_writeoff_notice.card_number);
    
      IF v_mpos_writeoff_form_id IS NOT NULL /*��������� ���������*/
      THEN
        /*��������� ������ �� ��������� ���������*/
        vr_mpos_writeoff_notice.mpos_writeoff_form_id := v_mpos_writeoff_form_id;
        /*������ �� ���-� ��������*/
        BEGIN
          vr_mpos_writeoff_notice.t_mpos_result_id := dml_t_mpos_result.get_id_by_result_code(pkg_mpos.get_result_code(vr_mpos_writeoff_notice.processing_result)
                                                                                             ,par_raise_on_error => FALSE);
        EXCEPTION
          WHEN no_data_found THEN
            -- � ����� � �������� ����� ������ � ����������, 
            -- �������� �������,����� �� result_code ������ �� ��������
            vr_mpos_writeoff_notice.t_mpos_result_id := dml_t_mpos_result.get_id_by_process_description(pkg_mpos.get_result_code(vr_mpos_writeoff_notice.processing_result)
                                                                                                       ,par_raise_on_error => FALSE);
          
        END;
      
        /*��������� ������ ���������*/
        vr_mpos_writeoff_notice.work_status := get_work_status(par_mpos_writeoff_form_id => v_mpos_writeoff_form_id
                                                              ,par_processing_result     => vr_mpos_writeoff_notice.processing_result);
        dml_mpos_writeoff_notice.update_record(par_record => vr_mpos_writeoff_notice);
        /*������ ����������, �� ���������  ������ � �����*/
        IF vr_mpos_writeoff_notice.work_status = pkg_mpos.gc_work_status_processed
        THEN
          doc.set_doc_status(vr_mpos_writeoff_notice.mpos_writeoff_notice_id, 'REFUSE');
        END IF;
      ELSE
        /*��������� �� �����, �� ������ ��������������� ������*/
        vr_mpos_writeoff_notice.work_status := pkg_mpos.gc_work_status_no_notice;
        dml_mpos_writeoff_notice.update_record(par_record => vr_mpos_writeoff_notice);
      END IF; --����� ���� ��������� ��������� ��� ���
    END IF; --����� ���� ��������� � ������ �������
  
  END process_record_from_forms;

  --�������� �.�.
  --����������� �� �������� �������� "�������" � ������ "�����"
  PROCEDURE clear_reason_for_rejection(par_mpos_writeoff_form_id mpos_writeoff_form.mpos_writeoff_form_id%TYPE) IS
  BEGIN
    UPDATE mpos_writeoff_form f
       SET f.t_mpos_rejection_id = NULL
     WHERE f.mpos_writeoff_form_id = par_mpos_writeoff_form_id;
  END;

  /*
     ������ �. 25.09.2014
    �������� ������� �������� ��� ��������
  */
  PROCEDURE create_schedule(par_mpos_writeoff_form_id mpos_writeoff_form.mpos_writeoff_form_id%TYPE) IS
    v_plan_end_date        mpos_writeoff_sch.end_date%TYPE; --�������� ���� ��������� �������� (���� ��������� + 1 ���)
    v_next_start_date      mpos_writeoff_sch.start_date%TYPE;
    vr_mpos_writeoff_form  dml_mpos_writeoff_form.tt_mpos_writeoff_form;
    vr_payment_terms       dml_t_payment_terms.tt_t_payment_terms;
    v_mpos_writeoff_sch_id mpos_writeoff_sch.mpos_writeoff_sch_id%TYPE;
    /*�������� ������������� �� ��*/
    FUNCTION get_payment_term_id(par_policy_header_id p_pol_header.policy_header_id%TYPE)
      RETURN p_policy.payment_term_id%TYPE IS
      v_payment_term_id p_policy.payment_term_id%TYPE;
    BEGIN
      SELECT pp.payment_term_id
        INTO v_payment_term_id
        FROM p_pol_header pph
            ,p_policy     pp
       WHERE pph.policy_header_id = par_policy_header_id
         AND pph.policy_id = pp.policy_id;
      RETURN v_payment_term_id;
    EXCEPTION
      WHEN no_data_found
           OR too_many_rows THEN
        ex.raise('���������� ���������� ������������� �� �������� �����������. policy_header_id=' ||
                 par_policy_header_id);
    END get_payment_term_id;
  
  BEGIN
    IF doc.get_doc_status_brief(par_mpos_writeoff_form_id) IN ('CONFIRMED', 'CONFIRMED_NOT_SENT')
    THEN
      vr_mpos_writeoff_form := dml_mpos_writeoff_form.get_record(par_mpos_writeoff_form_id => par_mpos_writeoff_form_id);
    
      assert_deprecated(vr_mpos_writeoff_form.policy_header_id IS NULL
                       ,'��������� �� ��������� � �������� �����������. ������������ ������� ����������');
      /*�������� ������������� �� ��*/
      vr_payment_terms := dml_t_payment_terms.get_record(par_id => get_payment_term_id(par_policy_header_id => vr_mpos_writeoff_form.policy_header_id));
    
      v_plan_end_date   := ADD_MONTHS(trunc(vr_mpos_writeoff_form.transaction_date), 12);
      v_next_start_date := ADD_MONTHS(trunc(vr_mpos_writeoff_form.transaction_date)
                                     ,12 / vr_payment_terms.number_of_payments);
    
      LOOP
        EXIT WHEN v_next_start_date >= v_plan_end_date; /*�.�. ��������� �� 23:59:59 ����������� ���, �� ��� ���������� ��� �� ���������*/
        dml_mpos_writeoff_sch.insert_record(par_mpos_writeoff_form_id => par_mpos_writeoff_form_id
                                           ,par_start_date            => v_next_start_date
                                           ,par_end_date              => least(v_next_start_date + 20
                                                                              ,v_plan_end_date)
                                           ,par_mpos_writeoff_sch_id  => v_mpos_writeoff_sch_id
                                           ,par_doc_templ_id          => doc.templ_id_by_brief('MPOS_WRITEOFF_SCH'));
        doc.set_doc_status(p_doc_id => v_mpos_writeoff_sch_id, p_status_brief => 'NEW');
        v_next_start_date := ADD_MONTHS(v_next_start_date, 12 / vr_payment_terms.number_of_payments);
      END LOOP;
    END IF;
  
  END create_schedule;

  /*
    ������ �. 25.09.2014
    ��������� �������� ������� �� �������� (��� ������� ��������� �������)
  */
  PROCEDURE pass_to_writeoff_at_night IS
    /*
      ������ �. 26.09.2014
      ���������, ���� �� ��������
    */
    FUNCTION is_exists_writeoff
    (
      par_mpos_writeoff_form_id mpos_writeoff_form.mpos_writeoff_form_id%TYPE
     ,par_start_date            mpos_writeoff_sch.start_date%TYPE
     ,par_end_date              mpos_writeoff_sch.end_date%TYPE
    ) RETURN BOOLEAN IS
      v_count NUMBER;
    BEGIN
      SELECT COUNT(*)
        INTO v_count
        FROM dual
       WHERE EXISTS (SELECT NULL
                FROM mpos_writeoff_notice wn
                    ,document             d
                    ,doc_status_ref       dsr
               WHERE d.document_id = wn.mpos_writeoff_notice_id
                 AND dsr.doc_status_ref_id = d.doc_status_ref_id
                 AND dsr.brief IN ('NEW', 'LOADED')
                 AND wn.mpos_writeoff_form_id = par_mpos_writeoff_form_id
                 AND wn.transaction_date BETWEEN par_start_date AND par_end_date);
      RETURN v_count = 1;
    END is_exists_writeoff;
  
  BEGIN
  
    /*��� ������� �������� � ������� ������, ���� ������ ������� �������� ������� ������ ���
    ����� ������� ���� ���������� � ������ ��� ��������.*/
    FOR vr_sched IN (SELECT wc.mpos_writeoff_sch_id
                       FROM mpos_writeoff_sch wc
                           ,document          dc
                           ,doc_status_ref    dsr
                      WHERE wc.mpos_writeoff_sch_id = dc.document_id
                        AND dc.doc_status_ref_id = dsr.doc_status_ref_id
                        AND dsr.brief = 'NEW'
                        AND wc.start_date <= trunc(SYSDATE))
    LOOP
      doc.set_doc_status(p_doc_id => vr_sched.mpos_writeoff_sch_id, p_status_brief => 'TO_WRITEOFF');
    END LOOP;
  
    /*��� ������� � ������� ��� ��������, ���� ��������� ������� �������� ������� ������ ��� ����� ������� ����
         ��������� � ������:
    o ���� ��� ����������� � �������� �������������� ��������, �� ������� ��������� ������, ���������� ����������� � ��������� ��������  � ������� ������ ��� ��������� ���� ���������� �������� �������� � ������ ����� ������ ��������� � ����� ��������� ��������� �������, �� ��������� ������ � ������ ��������.
    o � ��������� ������, ��������� ������ � ������ ��� �������.
    */
    FOR vr_sched IN (SELECT wc.mpos_writeoff_sch_id
                           ,wc.mpos_writeoff_form_id
                           ,wc.start_date
                           ,wc.end_date
                       FROM mpos_writeoff_sch wc
                           ,document          dc
                           ,doc_status_ref    dsr
                      WHERE wc.mpos_writeoff_sch_id = dc.document_id
                        AND dc.doc_status_ref_id = dsr.doc_status_ref_id
                        AND dsr.brief = 'TO_WRITEOFF'
                        AND wc.end_date <= trunc(SYSDATE))
    LOOP
      /*���� ���� ������, �� ������ ����������� � ��������� "�������", ����� "�� �������"*/
      IF is_exists_writeoff(par_mpos_writeoff_form_id => vr_sched.mpos_writeoff_form_id
                           ,par_start_date            => vr_sched.start_date
                           ,par_end_date              => vr_sched.end_date)
      THEN
        doc.set_doc_status(p_doc_id => vr_sched.mpos_writeoff_sch_id, p_status_brief => 'WRITEDOFF');
      ELSE
      
        doc.set_doc_status(p_doc_id       => vr_sched.mpos_writeoff_sch_id
                          ,p_status_brief => 'NOT_WRITEDOFF');
      END IF;
    END LOOP;
  
  END pass_to_writeoff_at_night;

  --���������� �� �������� ������� "�����������" - "��������"
  --���� ������ ��������� "����������� � �������� �������������� ��������"  ����� "��������", "��������.�� ������� � ����������"
  --� ��� ��������� ���������� ��������� ��������� "������ �������� mPos" � ������� "�� ��������" ��� "�����",
  --�� ��������� ���������� �� � ������ "�������". 
  PROCEDURE cancel_shedule(par_mpos_writeoff_form_id NUMBER) IS
  BEGIN
  
    FOR rec IN (SELECT s.mpos_writeoff_sch_id
                
                  FROM mpos_writeoff_form f
                      ,document           fd
                      ,doc_status_ref     fdsr
                      ,mpos_writeoff_sch  s
                      ,document           sd
                      ,doc_status_ref     sdsr
                
                 WHERE s.mpos_writeoff_form_id = f.mpos_writeoff_form_id
                   AND fd.document_id = f.mpos_writeoff_form_id
                   AND fdsr.doc_status_ref_id = fd.doc_status_ref_id
                   AND sd.document_id = s.mpos_writeoff_sch_id
                   AND sdsr.doc_status_ref_id = sd.doc_status_ref_id
                   AND fdsr.brief IN ('STOPED', 'STOPED_NOT_SENT')
                   AND sdsr.brief IN ('TO_WRITEOFF', 'NEW')
                   AND f.mpos_writeoff_form_id = par_mpos_writeoff_form_id)
    LOOP
      doc.set_doc_status(p_doc_id => rec.mpos_writeoff_sch_id, p_status_brief => 'CANCEL');
    END LOOP;
  
  END cancel_shedule;

  -- ��������� �������� ������������ �������� ������� ��������� 
  -- "������������� ��������"
  -- ����������� �� �������� �� ������� ������� � ������ ������
  PROCEDURE check_succesfull_wo_noti�e(par_mpos_writeoff_notice_id NUMBER) IS
    vr_mpos_writeoff_notice dml_mpos_writeoff_notice.tt_mpos_writeoff_notice;
    v_mpos_result_id        NUMBER;
    v_succes_flag           NUMBER;
  BEGIN
    vr_mpos_writeoff_notice := dml_mpos_writeoff_notice.get_record(par_mpos_writeoff_notice_id => par_mpos_writeoff_notice_id);
    get_mpos_result(vr_mpos_writeoff_notice.processing_result, v_mpos_result_id, v_succes_flag);
  
    IF v_mpos_result_id IS NOT NULL
    THEN
      IF v_succes_flag = 1
      THEN
        NULL; -- �������� ��������
      ELSE
        -- ��������� � ������ �����
        doc.set_doc_status(p_doc_id => par_mpos_writeoff_notice_id, p_status_brief => 'REFUSE');
      END IF;
    ELSE
      -- ���� ��� �������� �� ��������� ���������(�� ������� �����. ���� � ����������� ����������� ��������)
      raise_application_error(-20001
                             ,'��������� �������� ����������� � �����������(id ������ ' ||
                              par_mpos_writeoff_notice_id || ')');
    END IF;
  
  END;

  -- ��������� �������� ������������ �������� ������� ��������� 
  -- "����������� � �������� �������������� ��������"
  -- ����������� �� �������� �� ������� ������� � ������ ������   
  PROCEDURE check_succesfull_wo_form(par_mpos_writeoff_form_id NUMBER) IS
    vr_mpos_writeoff_form dml_mpos_writeoff_form.tt_mpos_writeoff_form;
    v_mpos_result_id      NUMBER;
    v_succes_flag         NUMBER;
  BEGIN
    vr_mpos_writeoff_form := dml_mpos_writeoff_form.get_record(par_mpos_writeoff_form_id => par_mpos_writeoff_form_id);
    get_mpos_result(vr_mpos_writeoff_form.processing_result, v_mpos_result_id, v_succes_flag);
  
    IF v_mpos_result_id IS NOT NULL
    THEN
      IF v_succes_flag = 1
      THEN
        NULL; -- �������� ��������
      ELSE
        -- ��������� � ������ �������
        doc.set_doc_status(p_doc_id => par_mpos_writeoff_form_id, p_status_brief => 'CANCEL');
      END IF;
    ELSE
      -- ���� ��� �������� �� ��������� ���������(�� ������� �����. ���� � ����������� ����������� ��������)
      raise_application_error(-20001
                             ,'��������� �������� ����������� � �����������(id ������ ' ||
                              par_mpos_writeoff_form_id || ')');
    END IF;
  END;

  -- ��������� �������� ������������ �������� ������� ��������� 
  -- "����������� ��������" (MPOS_PAYMENT_NOTICE)
  -- ����������� �� �������� �� ������� ������� � ������ ������   
  PROCEDURE check_succesfull_paym_notice(par_mpos_payment_notice_id NUMBER) IS
    vr_mpos_paym_notice dml_mpos_payment_notice.tt_mpos_payment_notice;
    v_mpos_result_id    NUMBER;
    v_succes_flag       NUMBER;
  BEGIN
    vr_mpos_paym_notice := dml_mpos_payment_notice.get_record(par_mpos_payment_notice_id => par_mpos_payment_notice_id);
    get_mpos_result(vr_mpos_paym_notice.processing_result, v_mpos_result_id, v_succes_flag);
  
    IF v_mpos_result_id IS NOT NULL
    THEN
      IF v_succes_flag = 1
      THEN
        NULL; -- �������� ��������
      ELSE
        -- ��������� � ������ �������
        doc.set_doc_status(p_doc_id => par_mpos_payment_notice_id, p_status_brief => 'CANCEL');
      END IF;
    ELSE
      -- ���� ��� �������� �� ��������� ���������(�� ������� �����. ���� � ����������� ����������� ��������)
      raise_application_error(-20001
                             ,'��������� �������� ����������� � �����������(id ������ ' ||
                              par_mpos_payment_notice_id || ')');
    END IF;
  END;

  PROCEDURE req_m4bank_initialinstallments
  (
    par_date_from      DATE
   ,par_date_to        DATE
   ,par_is_success_out OUT BOOLEAN
   ,par_result_out     OUT JSON
   ,par_error_out      OUT VARCHAR2
  ) IS
    va_headers    pkg_communication.tt_headers;
    v_answer      CLOB;
    v_json_answer JSON;
    c_date_mask   VARCHAR2(30) := 'yyyy-mm-dd hh24:mi:ss';
    v_url         VARCHAR2(200) := pkg_borlas_b2b.get_b2b_props_val(par_oper_type_brief  => 'InitialInstallments_m4bank'
                                                                   ,par_props_type_brief => 'URL');
    v_send        VARCHAR2(200);
    par_log_info  pkg_communication.typ_log_info;
  BEGIN
  
    assert_deprecated(par_date_from IS NULL
                     ,'�� ������ ������������ �������� ���� �');
    assert_deprecated(par_date_to IS NULL
                     ,'�� ������ ������������ �������� ���� ��');
  
    par_log_info.source_pkg_name       := 'pkg_mpos';
    par_log_info.source_procedure_name := 'req_m4bank_InitialInstallments';
    par_log_info.operation_name        := 'InitialInstallments';
  
    fill_headers(va_headers);
  
    v_send := 'FromDate=' || to_char(par_date_from, c_date_mask) || '&ToDate=' ||
              to_char(par_date_to, c_date_mask);
  
    BEGIN
      dbms_lob.createtemporary(lob_loc => v_answer, cache => TRUE);
      v_answer := pkg_communication.request(par_url           => v_url
                                           ,par_method        => 'POST'
                                           ,par_send          => v_send
                                           ,par_add_headers   => va_headers
                                           ,par_use_def_proxy => TRUE
                                           ,par_body_charset  => 'UTF-8'
                                           ,par_log_info      => par_log_info);
    
      BEGIN
        v_json_answer := JSON(v_answer);
      EXCEPTION
        WHEN OTHERS THEN
          raise_application_error(-20001
                                 ,'������ ��� ������� ������(����� InitialInstallments)');
      END;
    
      IF v_json_answer.exist('Status')
      THEN
        par_is_success_out := upper(v_json_answer.get('Status').get_string) = 'SUCCESS';
      ELSE
        par_is_success_out := FALSE;
      END IF;
      par_result_out := v_json_answer;
    EXCEPTION
      WHEN OTHERS THEN
        par_is_success_out := FALSE;
        par_error_out      := SQLERRM;
    END;
  END req_m4bank_initialinstallments;

  PROCEDURE req_m4bank_confirminstallments
  (
    par_installment_id NUMBER
   ,par_is_success_out OUT BOOLEAN
   ,par_result_out     OUT JSON
   ,par_error_out      OUT VARCHAR2
  ) IS
    va_headers    pkg_communication.tt_headers;
    v_answer      CLOB;
    v_json_answer JSON;
    v_url         VARCHAR2(200) := pkg_borlas_b2b.get_b2b_props_val(par_oper_type_brief  => 'ConfirmInstallments_m4bank'
                                                                   ,par_props_type_brief => 'URL');
    v_send        VARCHAR2(200);
    par_log_info  pkg_communication.typ_log_info;
  BEGIN
  
    par_log_info.source_pkg_name       := 'pkg_mpos';
    par_log_info.source_procedure_name := 'req_m4bank_ConfirmInstallments';
    par_log_info.operation_name        := 'ConfirmInstallments';
  
    fill_headers(va_headers);
  
    v_send := 'InitialInstallment=' || to_char(par_installment_id);
  
    BEGIN
      dbms_lob.createtemporary(lob_loc => v_answer, cache => TRUE);
      v_answer := pkg_communication.request(par_url           => v_url
                                           ,par_method        => 'POST'
                                           ,par_send          => v_send
                                           ,par_add_headers   => va_headers
                                           ,par_use_def_proxy => TRUE
                                           ,par_body_charset  => 'UTF-8'
                                           ,par_log_info      => par_log_info);
    
      BEGIN
        v_json_answer := JSON(v_answer);
      EXCEPTION
        WHEN OTHERS THEN
          raise_application_error(-20001
                                 ,'������ ��� ������� ������(����� ConfirmInstallments)');
      END;
    
      IF v_json_answer.exist('Status')
      THEN
        par_is_success_out := upper(v_json_answer.get('Status').get_string) = 'SUCCESS';
      ELSE
        par_is_success_out := FALSE;
      END IF;
      par_result_out := v_json_answer;
    EXCEPTION
      WHEN OTHERS THEN
        par_is_success_out := FALSE;
        par_error_out      := SQLERRM;
    END;
  END;

  PROCEDURE req_m4bank_stopinstallments
  (
    par_installment_id NUMBER
   ,par_is_success_out OUT BOOLEAN
   ,par_result_out     OUT JSON
   ,par_error_out      OUT VARCHAR2
  ) IS
    va_headers    pkg_communication.tt_headers;
    v_answer      CLOB;
    v_json_answer JSON;
    v_url         VARCHAR2(200) := pkg_borlas_b2b.get_b2b_props_val(par_oper_type_brief  => 'StopInstallments_m4bank'
                                                                   ,par_props_type_brief => 'URL');
    v_send        VARCHAR2(200);
    par_log_info  pkg_communication.typ_log_info;
  BEGIN
  
    par_log_info.source_pkg_name       := 'pkg_mpos';
    par_log_info.source_procedure_name := 'req_m4bank_StopInstallments';
    par_log_info.operation_name        := 'StopInstallments';
  
    fill_headers(va_headers);
  
    v_send := 'InitialInstallment=' || to_char(par_installment_id);
  
    BEGIN
      dbms_lob.createtemporary(lob_loc => v_answer, cache => TRUE);
      v_answer := pkg_communication.request(par_url           => v_url
                                           ,par_method        => 'POST'
                                           ,par_send          => v_send
                                           ,par_add_headers   => va_headers
                                           ,par_use_def_proxy => TRUE
                                           ,par_body_charset  => 'UTF-8'
                                           ,par_log_info      => par_log_info);
    
      BEGIN
        v_json_answer := JSON(v_answer);
      EXCEPTION
        WHEN OTHERS THEN
          raise_application_error(-20001
                                 ,'������ ��� ������� ������(����� StopInstallments)');
      END;
    
      IF v_json_answer.exist('Status')
      THEN
        par_is_success_out := upper(v_json_answer.get('Status').get_string) = 'SUCCESS';
      ELSE
        par_is_success_out := FALSE;
      END IF;
      par_result_out := v_json_answer;
    EXCEPTION
      WHEN OTHERS THEN
        par_is_success_out := FALSE;
        par_error_out      := SQLERRM;
    END;
  END;

  -- ��������� ������ � �������� � ���-��������
  PROCEDURE send_sync_ws_err_message
  (
    par_ws_method    VARCHAR2
   ,par_date_from    DATE
   ,par_date_to      DATE
   ,par_request_date DATE
  ) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  
    v_recipients_list pkg_email.t_recipients := pkg_email.t_recipients();
  BEGIN
    v_recipients_list.extend(3);
    v_recipients_list(1) := 'Vladislav.Zalesov@Renlife.com';
    v_recipients_list(2) := 'Alla.Salahova@Renlife.com';
    v_recipients_list(3) := 'Pavel.Kaplya@Renlife.com';
  
    pkg_email.send_mail_with_attachment(par_to      => v_recipients_list
                                       ,par_subject => sys.database_name ||
                                                       ': ������ ��� ��������� ������ ��� MPOS'
                                       ,par_text    => '�������� ������ ��� ��������� � ���-������� �� ����� ������ ��������� ������ ������ �� MPOS.' ||
                                                       chr(10) || chr(10) || '��������� �������:' ||
                                                       chr(10) || '���� �: ' ||
                                                       to_char(par_date_from, 'dd.mm.yyyy hh24:mi:ss') ||
                                                       chr(10) || '���� ��: ' ||
                                                       to_char(par_date_to, 'dd.mm.yyyy hh24:mi:ss') ||
                                                       chr(10) || '�����: ' || par_ws_method ||
                                                       chr(10) || chr(10) ||
                                                       '���� ������ ������� ���������: ' ||
                                                       to_char(par_request_date
                                                              ,'dd.mm.yyyy hh24:mi:ss') ||
                                                       '; ���� ������������ ������: ' ||
                                                       to_char(SYSDATE, 'dd.mm.yyyy hh24:mi:ss'));
  END;
  -- ��������� ������ �� ������ � ���������
  PROCEDURE send_sync_err_message(par_error_text CLOB) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  
    v_recipients_list pkg_email.t_recipients := pkg_email.t_recipients();
    v_error_text_blob BLOB;
    v_attachment      pkg_email.t_files := pkg_email.t_files();
  
    l_dest_offset   INTEGER := 1;
    l_source_offset INTEGER := 1;
    l_lang_context  INTEGER := dbms_lob.default_lang_ctx;
    l_warning       INTEGER := dbms_lob.warn_inconvertible_char;
  
    FUNCTION clobtoblob
    (
      p_clob IN CLOB
     ,p_csid NUMBER
    ) RETURN BLOB IS
      l_dest_offset   INTEGER := 1;
      l_source_offset INTEGER := 1;
      l_lang_context  INTEGER := dbms_lob.default_lang_ctx;
      l_warning       INTEGER := dbms_lob.warn_inconvertible_char;
      l_tmpblob       BLOB;
    
    BEGIN
      dbms_lob.createtemporary(l_tmpblob, TRUE);
      dbms_lob.converttoblob(l_tmpblob
                            ,p_clob
                            ,dbms_lob.lobmaxsize
                            ,l_dest_offset
                            ,l_source_offset
                            ,p_csid
                            ,l_lang_context
                            ,l_warning);
      RETURN l_tmpblob;
    END;
  BEGIN
    v_recipients_list.extend(3);
    v_recipients_list(1) := 'Vladislav.Zalesov@Renlife.com';
    v_recipients_list(2) := 'Alla.Salahova@Renlife.com';
    v_recipients_list(3) := 'Pavel.Kaplya@Renlife.com';
  
    v_error_text_blob := clobtoblob(par_error_text, 0);
  
    v_attachment.extend(1);
    v_attachment(1).v_file_name := 'WS_sync_log.txt';
    v_attachment(1).v_file_type := 'text/plain';
    v_attachment(1).v_file := v_error_text_blob;
  
    pkg_email.send_mail_with_attachment(par_to         => v_recipients_list
                                       ,par_subject    => sys.database_name ||
                                                          ': ������ ��� ������ ������ ��� MPOS'
                                       ,par_text       => 'Log-���� �� ��������'
                                       ,par_attachment => v_attachment);
  END;

  -- ��������� ������ ��������
  -- par_date_from, par_date_to - ���������� ������,�� ������� 
  -- ���-������ ���������� ������ � �� ������� ����������� ������
  -- ���������� JOB��
  PROCEDURE sync_payment_data
  (
    par_date_from DATE DEFAULT trunc(SYSDATE - 1) + INTERVAL '1' SECOND
   ,par_date_to   DATE DEFAULT trunc(SYSDATE)
  ) IS
  
    v_initial_installments JSON;
    v_data_element         JSON := JSON();
    v_data_array           JSON_LIST := JSON_LIST();
    v_success_request_flag BOOLEAN;
    v_request_date         DATE;
  
    v_err_log CLOB;
  
    v_id          NUMBER;
    v_tp          VARCHAR2(50);
    v_st          VARCHAR2(50);
    v_sti         VARCHAR2(255);
    v_sm          NUMBER(15, 2);
    v_cdt         VARCHAR2(50);
    v_rrn         VARCHAR2(50);
    v_tpan        VARCHAR2(50);
    v_tid         VARCHAR2(50);
    v_mid         VARCHAR2(50);
    v_card        VARCHAR2(50);
    v_hrc         VARCHAR2(50);
    v_hrs         VARCHAR2(255);
    v_acd         VARCHAR2(50);
    v_frequency   NUMBER;
    v_phone       VARCHAR2(255);
    v_fio         VARCHAR2(255);
    v_cn          VARCHAR2(255);
    v_prod        VARCHAR2(255);
    v_bdt         VARCHAR2(50);
    v_edt         VARCHAR2(50);
    v_asum        NUMBER(15, 2);
    v_aval        VARCHAR2(50);
    v_osum        NUMBER(15, 2);
    v_oval        VARCHAR2(50);
    v_expd        VARCHAR2(50);
    v_indx        NUMBER;
    v_original_id NUMBER;
    v_rp_st       NUMBER;
  
    v_mpos_result_id          NUMBER;
    v_success_flag            NUMBER;
    v_mpos_writeoff_form_id   NUMBER;
    v_mpos_payment_notice_id  NUMBER;
    v_mpos_writeoff_notice_id NUMBER;
  
    v_error VARCHAR2(32000);
  
    --���������� true, ���� � ������� mpos_writeoff_form
    -- ������� ������ � id ���������� = par_transaction_id
    FUNCTION chk_exists_rec_mpos_wo_form(par_transaction_id NUMBER) RETURN BOOLEAN IS
      res NUMBER := 0;
      CURSOR cur(cp_transaction_id NUMBER) IS
        SELECT 1 val FROM mpos_writeoff_form t WHERE t.transaction_id = cp_transaction_id;
    
    BEGIN
      OPEN cur(par_transaction_id);
      FETCH cur
        INTO res;
      CLOSE cur;
      IF (res = 1)
      THEN
        RETURN TRUE;
      ELSE
        RETURN FALSE;
      END IF;
    END;
  
    --���������� true, ���� � ������� mpos_payment_notice
    -- ������� ������ � id ���������� = par_transaction_id
    FUNCTION chk_exists_rec_mpos_payment_n(par_transaction_id NUMBER) RETURN BOOLEAN IS
      res NUMBER := 0;
      CURSOR cur(cp_transaction_id NUMBER) IS
        SELECT 1 val FROM mpos_payment_notice t WHERE t.transaction_id = cp_transaction_id;
    
    BEGIN
      OPEN cur(par_transaction_id);
      FETCH cur
        INTO res;
      CLOSE cur;
      IF (res = 1)
      THEN
        RETURN TRUE;
      ELSE
        RETURN FALSE;
      END IF;
    END;
  
    --���������� true, ���� � ������� MPOS_WRITEOFF_NOTICE
    -- ������� ������ � id ���������� = par_transaction_id
    FUNCTION chk_exists_rec_mpos_wo_notice(par_transaction_id NUMBER) RETURN BOOLEAN IS
      res NUMBER := 0;
      CURSOR cur(cp_transaction_id NUMBER) IS
        SELECT 1 val FROM mpos_writeoff_notice t WHERE t.transaction_id = cp_transaction_id;
    
    BEGIN
      OPEN cur(par_transaction_id);
      FETCH cur
        INTO res;
      CLOSE cur;
      IF (res = 1)
      THEN
        RETURN TRUE;
      ELSE
        RETURN FALSE;
      END IF;
    END;
  
    -- ����������� ������ � ������� yyyy-mm-ddThh24:mi:ss.zTZH:TZM � ����
    FUNCTION convert_to_date(par_text VARCHAR2) RETURN DATE IS
      t                TIMESTAMP;
      c_timestamp_mask VARCHAR2(50) := 'YYYY-MM-DD HH24:MI:SS.FFTZH:TZM';
    BEGIN
      t := to_timestamp_tz(REPLACE(par_text, 'T', ' '), c_timestamp_mask);
      RETURN CAST(t AS DATE);
    END;
  
    FUNCTION get_payment_system_id(par_tpan VARCHAR2) RETURN NUMBER IS
    BEGIN
      RETURN dml_t_payment_system.get_id_by_brief(upper(REPLACE(par_tpan, ' ', '')));
    END;
  
    FUNCTION get_mpos_wo_frm_id_by_trans_id(par_trans_id NUMBER) RETURN NUMBER IS
      CURSOR cur(cp_transaction_id NUMBER) IS
        SELECT f.mpos_writeoff_form_id
          FROM mpos_writeoff_form f
         WHERE f.transaction_id = cp_transaction_id;
      mpos_writeoff_form_id NUMBER;
    BEGIN
      OPEN cur(par_trans_id);
      FETCH cur
        INTO mpos_writeoff_form_id;
      CLOSE cur;
      RETURN mpos_writeoff_form_id;
    END;
  
  BEGIN
    dbms_lob.createtemporary(v_err_log, TRUE);
    -- ��������� ������
    v_request_date := SYSDATE;
    FOR cnt IN 1 .. 3
    LOOP
      pkg_mpos.req_m4bank_initialinstallments(par_date_from      => par_date_from
                                             ,par_date_to        => par_date_to
                                             ,par_is_success_out => v_success_request_flag
                                             ,par_result_out     => v_initial_installments
                                             ,par_error_out      => v_error);
      IF v_success_request_flag = TRUE
      THEN
        EXIT;
      END IF;
    END LOOP;
    IF (v_success_request_flag = FALSE)
    THEN
      -- ���������� ��������� �� �������, ���� ���-�� ����� �� ���
      send_sync_ws_err_message('InitialInstallments', par_date_from, par_date_to, v_request_date);
    ELSE
      -- �������� ���������, ��������� JSON 
      IF v_initial_installments.exist('Model')
      THEN
        -- ������ ��� �� ������
        v_data_array := JSON_LIST(v_initial_installments.get('Model'));
    
        FOR i IN 1 .. v_data_array.count
        LOOP
          -- �������� ������
          v_data_element := JSON(v_data_array.get(i));
        
          v_id          := v_data_element.get('ID').get_number;
          v_tp          := v_data_element.get('TP').get_string;
          v_st          := v_data_element.get('ST').get_string;
          v_sti         := v_data_element.get('STI').get_string;
          v_sm          := to_number(REPLACE(v_data_element.get('SM').get_string, '.', ','));
          v_cdt         := v_data_element.get('CDT').get_string;
          v_rrn         := v_data_element.get('RRN').get_string;
          v_tpan        := v_data_element.get('TPAN').get_string;
          v_tid         := v_data_element.get('TID').get_string;
          v_mid         := v_data_element.get('MID').get_string;
          v_card        := v_data_element.get('CARD').get_string;
          v_hrc         := v_data_element.get('HRC').get_string;
          v_hrs         := v_data_element.get('HRS').get_string;
          v_acd         := v_data_element.get('ACD').get_string;
          v_frequency   := v_data_element.get('FREQUENCY').get_number;
          v_phone       := v_data_element.get('PHONE').get_string;
          v_fio         := v_data_element.get('FIO').get_string;
          v_cn          := v_data_element.get('CN').get_string;
          v_prod        := v_data_element.get('PROD').get_string;
          v_bdt         := v_data_element.get('BDT').get_string;
          v_edt         := v_data_element.get('EDT').get_string;
          v_asum        := to_number(REPLACE(v_data_element.get('ASUM').get_string, '.', ','));
          v_aval        := v_data_element.get('AVAL').get_string;
          v_osum        := to_number(REPLACE(v_data_element.get('OSUM').get_string, '.', ','));
          v_oval        := v_data_element.get('OVAL').get_string;
          v_expd        := v_data_element.get('EXPD').get_string;
          v_indx        := v_data_element.get('INDX').get_number;
          v_original_id := v_data_element.get('ORIGINAL_ID').get_number;
          v_rp_st       := v_data_element.get('RP_ST').get_number;
        
          -- �������� ������ �� ���� ����������
          get_mpos_result(v_hrc, v_mpos_result_id, v_success_flag);
        
          -- ������������ ������
          CASE
            WHEN v_tp = 'RECURRENTFIRST' THEN
              --dbms_output.put_line(v_id || ' ' || 'RECURRENTFIRST');
              IF NOT chk_exists_rec_mpos_wo_form(v_id)
                 AND
                 ((v_mpos_result_id IS NOT NULL AND v_success_flag = 1) OR (v_mpos_result_id IS NULL))
              THEN
                v_mpos_writeoff_form_id := NULL;
                BEGIN
                  dml_mpos_writeoff_form.insert_record(par_fund_id                  => 122
                                                      ,par_transaction_id           => v_id
                                                      ,par_t_payment_terms_id       => get_t_paym_terms_id_by_ext_id(v_frequency)
                                                      ,par_policy_number            => v_cn
                                                      ,par_transaction_date         => convert_to_date(v_cdt)
                                                      ,par_insured_name             => v_fio
                                                      ,par_t_mpos_payment_status_id => 1 --COMPLETED
                                                      ,par_amount                   => v_sm
                                                      ,par_policy_header_id         => NULL
                                                      ,par_ins_premium              => NULL
                                                      ,par_ids_for_recognition      => NULL
                                                      ,par_product_name             => v_prod
                                                      ,par_device_model             => v_phone
                                                      ,par_device_name              => NULL
                                                      ,par_device_id                => NULL
                                                      ,par_card_number              => v_card
                                                      ,par_t_payment_system_id      => get_payment_system_id(v_tpan)
                                                      ,par_cliche                   => v_mid
                                                      ,par_terminal_bank_id         => v_tid
                                                      ,par_rrn                      => v_rrn
                                                      ,par_description              => NULL
                                                      ,par_g_mpos_id                => NULL
                                                      ,par_t_mpos_rejection_id      => NULL
                                                      ,par_processing_result        => CASE
                                                                                         WHEN v_mpos_result_id IS NOT NULL THEN
                                                                                          NULL
                                                                                         ELSE
                                                                                          v_hrc
                                                                                       END
                                                      ,par_mpos_writeoff_form_id    => v_mpos_writeoff_form_id);
                
                  IF v_mpos_result_id IS NOT NULL
                  THEN
                    doc.set_doc_status(p_doc_id => v_mpos_writeoff_form_id, p_status_brief => 'NEW'); -- ��������� � ������ ����� 
                  ELSE
                    doc.set_doc_status(p_doc_id       => v_mpos_writeoff_form_id
                                      ,p_status_brief => 'PROJECT'); --��������� � ������ ������
                  END IF;
                
                EXCEPTION
                  WHEN OTHERS THEN
                    dbms_lob.append(v_err_log
                                   ,'������ ��� ������������ ������ ���� RECURRENTFIRST:' || chr(10) ||
                                    SQLERRM || chr(10));
                    dbms_lob.append(v_err_log
                                   ,'���������:' || chr(10) || 'policy_number: ' || v_cn || chr(10) ||
                                    'insured_name: ' || v_fio || chr(10) || 'amount: ' ||
                                    to_char(v_sm) || chr(10) || 'card_number: ' || v_card || chr(10));
                END;
              
              END IF;
            
            WHEN v_tp = 'PAYMENT' THEN
              --dbms_output.put_line(v_id || ' ' || 'PAYMENT');
              IF NOT chk_exists_rec_mpos_payment_n(v_id)
                 AND
                 ((v_mpos_result_id IS NOT NULL AND v_success_flag = 1) OR (v_mpos_result_id IS NULL))
              THEN
                v_mpos_payment_notice_id := NULL;
                BEGIN
                  dml_mpos_payment_notice.insert_record(par_transaction_id           => v_id
                                                       ,par_policy_number            => v_cn
                                                       ,par_transaction_date         => convert_to_date(v_cdt)
                                                       ,par_insured_name             => v_fio
                                                       ,par_t_mpos_payment_status_id => 1 --COMPLETED
                                                       ,par_amount                   => v_sm
                                                       ,par_ins_premium              => NULL
                                                       ,par_product_name             => v_prod
                                                       ,par_device_model             => v_phone
                                                       ,par_device_name              => NULL
                                                       ,par_device_id                => NULL
                                                       ,par_card_number              => v_card
                                                       ,par_t_payment_system_id      => get_payment_system_id(v_tpan)
                                                       ,par_cliche                   => v_mid
                                                       ,par_terminal_bank_id         => v_tid
                                                       ,par_rrn                      => v_rrn
                                                       ,par_description              => NULL
                                                       ,par_g_mpos_id                => NULL
                                                       ,par_payment_register_item_id => NULL
                                                       ,par_processing_result        => CASE
                                                                                          WHEN v_mpos_result_id IS NOT NULL THEN
                                                                                           NULL
                                                                                          ELSE
                                                                                           v_hrc
                                                                                        END
                                                       ,par_mpos_payment_notice_id   => v_mpos_payment_notice_id);
                
                  IF v_mpos_result_id IS NOT NULL
                  THEN
                    IF v_success_flag = 1
                    THEN
                      doc.set_doc_status(p_doc_id       => v_mpos_payment_notice_id
                                        ,p_status_brief => 'NEW'); -- ��������� � ������ ����� 
                    ELSE
                      NULL;
                    END IF;
                  ELSE
                    doc.set_doc_status(p_doc_id       => v_mpos_payment_notice_id
                                      ,p_status_brief => 'PROJECT'); --��������� � ������ ������
                  END IF;
                EXCEPTION
                  WHEN OTHERS THEN
                    dbms_lob.append(v_err_log
                                   ,'������ ��� ������������ ������ ���� PAYMENT' || chr(10) ||
                                    SQLERRM || chr(10));
                    dbms_lob.append(v_err_log
                                   ,'���������:' || chr(10) || 'transaction_id: ' || v_id || chr(10) ||
                                    'transaction_date: ' || v_cdt || chr(10) || 'insured_name: ' ||
                                    v_fio || chr(10) || 'amount: ' || to_char(v_sm) || chr(10) ||
                                    'card_number: ' || v_card || chr(10));
                END;
              END IF;
            
            WHEN v_tp = 'RECURRENT' THEN
              --dbms_output.put_line(v_id || ' ' || 'RECURRENT');
              IF NOT chk_exists_rec_mpos_wo_notice(v_id)
              THEN
                v_mpos_writeoff_notice_id := NULL;
              
                BEGIN
                  dml_mpos_writeoff_notice.insert_record(par_transaction_id          => v_id
                                                        ,par_transaction_date        => convert_to_date(v_cdt)
                                                        ,par_writeoff_number         => v_indx
                                                        ,par_mpos_writeoff_form_id   => get_mpos_wo_frm_id_by_trans_id(v_original_id)
                                                        ,par_amount                  => v_sm
                                                        ,par_device_model            => v_phone
                                                        ,par_device_name             => NULL
                                                        ,par_device_id               => NULL
                                                        ,par_card_number             => v_card
                                                        ,par_t_payment_system_id     => get_payment_system_id(v_tpan)
                                                        ,par_cliche                  => v_mid
                                                        ,par_terminal_bank_id        => v_tid
                                                        ,par_rrn                     => v_rrn
                                                        ,par_description             => NULL
                                                        ,par_processing_result       => v_hrc
                                                        ,par_t_mpos_result_id        => v_mpos_result_id
                                                        ,par_mpos_writeoff_notice_id => v_mpos_writeoff_notice_id);
                
                  IF v_mpos_result_id IS NOT NULL
                  THEN
                    IF v_success_flag = 1
                    THEN
                      doc.set_doc_status(p_doc_id       => v_mpos_writeoff_notice_id
                                        ,p_status_brief => 'NEW'); -- ��������� � ������ ����� 
                    ELSE
                      doc.set_doc_status(p_doc_id       => v_mpos_writeoff_notice_id
                                        ,p_status_brief => 'REFUSE'); -- ��������� � ������ �����  
                    END IF;
                  
                  ELSE
                    doc.set_doc_status(p_doc_id       => v_mpos_writeoff_notice_id
                                      ,p_status_brief => 'PROJECT'); --��������� � ������ ������
                  END IF;
                EXCEPTION
                  WHEN OTHERS THEN
                    NULL;
                    dbms_lob.append(v_err_log
                                   ,'������ ��� ������������ ������ ���� RECURRENT' || chr(10) ||
                                    SQLERRM || chr(10));
                    dbms_lob.append(v_err_log
                                   ,'���������:' || chr(10) || 'transaction_id: ' || v_id || chr(10) ||
                                    'transaction_date: ' || v_cdt || chr(10) ||
                                    
                                    'amount: ' || to_char(v_sm) || chr(10) || 'card_number: ' ||
                                    v_card || chr(10) || 'original_id: ' || to_char(v_original_id) ||
                                    chr(10));
                END;
              END IF;
            ELSE
              NULL; -- ����������� ���
          END CASE;
        END LOOP;
      END IF;
    END IF;
  
    IF dbms_lob.getlength(v_err_log) > 0
    THEN
      send_sync_err_message(v_err_log);
    END IF;
  
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      dbms_lob.append(v_err_log
                     ,'������: ' || SQLERRM || chr(10) || '���������� ��������� ������ ��������.');
      send_sync_err_message(v_err_log);
  END;

END pkg_mpos;
/

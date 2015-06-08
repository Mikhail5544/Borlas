CREATE OR REPLACE PACKAGE pkg_pol_change_notice_fmb IS

  -- Author  : ������ �.
  -- Created : 29.12.2014
  -- Purpose : ������� ��� ����� "��������� �� ��������� ������� ��"

  /**
    * ������� ������ ��������� 
    * @author ������ �. 30.12.2014
  -- %param par_t_message_kind_id �� ���� ���������
  -- %param par_t_message_type_id �� ���� ���������
  -- %param par_client_type_id    ��� �������
  -- %param par_t_crm_request_theme_id ���� ���������
  -- %param par_subj_message 
  -- %param par_note                   �����������
  -- %param par_pol_header_id          �� �������� ����������
  -- %param par_t_pol_chang_notice_type_id �� ���� ���������
  -- %param par_notice_date           ���� ���������
  -- %param par_notice_num            ����� ���������
  -- %param par_t_decline_reason_id   �� ������� �����������
  -- %param par_policy_decline_date   ���� �����������
  -- %param par_commentary            ����������� �� ���������
  -- %param par_ticket_num            ����� ������
  -- %param par_is_to_set_off         ���� "����� �� ������ ��"
  -- %param par_credit_repayment_date  ���� ��������� �������
  -- %param par_main_program_surr     �������� ����� �� �������� ���������
  -- %param par_invest_program_surr   �������� ����� �����
  -- %param par_reg_date              ���� �����������
  -- %param par_user_name             �������������
  -- %param par_index_number          ���������� �����
  -- %param par_user_name_loaded      �������� ������
  -- %param par_user_name_change      �������� �������
    */
  PROCEDURE insert_pol_change_notice
  (
    par_t_message_kind_id          inoutput_info.inoutput_info_id%TYPE
   ,par_t_message_type_id          inoutput_info.t_message_type_id%TYPE
   ,par_client_type_id             inoutput_info.client_type_id%TYPE
   ,par_t_crm_request_theme_id     inoutput_info.t_crm_request_theme_id%TYPE
   ,par_subj_message               inoutput_info.subj_message%TYPE
   ,par_note                       inoutput_info.note%TYPE
   ,par_pol_header_id              inoutput_info.pol_header_id%TYPE
   ,par_t_pol_chang_notice_type_id p_pol_change_notice.t_pol_change_notice_type_id%TYPE
   ,par_notice_date                p_pol_change_notice.notice_date%TYPE
   ,par_notice_num                 p_pol_change_notice.notice_num%TYPE
   ,par_t_decline_reason_id        p_pol_change_notice.t_decline_reason_id%TYPE
   ,par_policy_decline_date        p_pol_change_notice.policy_decline_date%TYPE
   ,par_commentary                 p_pol_change_notice.commentary%TYPE
   ,par_ticket_num                 p_pol_change_notice.ticket_num%TYPE
   ,par_is_to_set_off              p_pol_change_notice.is_to_set_off%TYPE
   ,par_credit_repayment_date      p_pol_change_notice.credit_repayment_date%TYPE
   ,par_reg_date                   document.reg_date%TYPE
   ,par_user_name                  inoutput_info.user_name%TYPE
   ,par_index_number               inoutput_info.index_number%TYPE
   ,par_user_name_loaded           inoutput_info.user_name_loaded%TYPE
   ,par_user_name_change           inoutput_info.user_name_change%TYPE
   ,par_inoutput_info_id_out       OUT inoutput_info.inoutput_info_id%TYPE
   ,par_p_pol_change_notice_id_out OUT p_pol_change_notice.p_pol_change_notice_id%TYPE
  );

  /**
      * ���������� ���������� � ���������
      * @author ������ �. 12.1.2015
  -- %param par_inoutput_info_id  �� ��������/��������� ���-�
  -- %param par_p_pol_change_notice_id  �� ��������� 
  -- %param par_t_message_type_id  ���� ���������
  -- %param par_client_type_id   ��� �������
  -- %param par_note                   �����������
  -- %param par_pol_header_id          �� �������� ����������
  -- %param par_t_pol_chang_notice_type_id �� ���� ���������
  -- %param par_notice_date           ���� ���������
  -- %param par_notice_num            ����� ���������
  -- %param par_t_decline_reason_id   �� ������� �����������
  -- %param par_policy_decline_date   ���� �����������
  -- %param par_commentary            ����������� �� ���������
  -- %param par_ticket_num            ����� ������
  -- %param par_is_to_set_off         ���� "����� �� ������ ��"
  -- %param par_credit_repayment_date  ���� ��������� �������
  -- %param par_main_program_surr     �������� ����� �� �������� ���������
  -- %param par_invest_program_surr   �������� ����� �����
  -- %param par_reg_date              ���� �����������
  -- %param par_user_name             �������������
  -- %param par_index_number          ���������� �����
  -- %param par_user_name_loaded      �������� ������
  -- %param par_user_name_change      �������� �������
    */
  PROCEDURE update_pol_change_notice
  (
    par_inoutput_info_id           inoutput_info.inoutput_info_id%TYPE
   ,par_p_pol_change_notice_id     p_pol_change_notice.p_pol_change_notice_id%TYPE
   ,par_t_message_type_id          inoutput_info.t_message_type_id%TYPE
   ,par_client_type_id             inoutput_info.client_type_id%TYPE
   ,par_note                       inoutput_info.note%TYPE
   ,par_pol_header_id              inoutput_info.pol_header_id%TYPE
   ,par_t_pol_chang_notice_type_id p_pol_change_notice.t_pol_change_notice_type_id%TYPE
   ,par_notice_date                p_pol_change_notice.notice_date%TYPE
   ,par_notice_num                 p_pol_change_notice.notice_num%TYPE
   ,par_t_decline_reason_id        p_pol_change_notice.t_decline_reason_id%TYPE
   ,par_policy_decline_date        p_pol_change_notice.policy_decline_date%TYPE
   ,par_commentary                 p_pol_change_notice.commentary%TYPE
   ,par_ticket_num                 p_pol_change_notice.ticket_num%TYPE
   ,par_is_to_set_off              p_pol_change_notice.is_to_set_off%TYPE
   ,par_credit_repayment_date      p_pol_change_notice.credit_repayment_date%TYPE
   ,par_user_name                  inoutput_info.user_name%TYPE
   ,par_index_number               inoutput_info.index_number%TYPE
   ,par_user_name_loaded           inoutput_info.user_name_loaded%TYPE
   ,par_user_name_change           inoutput_info.user_name_change%TYPE
  );
  /**
  * �������� ���������
  * @author ������ �. 05.02.2015
  * @param par_p_pol_change_notice_id - �� ���������
  */
  PROCEDURE delete_pol_change_notice(par_p_pol_change_notice_id p_pol_change_notice.p_pol_change_notice_id%TYPE);

  /**
   * ��� ������������ c �������� ������ ��
   * @author ������ �. 13.1.2015
   -- %param par_p_pol_header      �� ��������� ��
  */
  FUNCTION get_insurer_name(par_p_pol_header p_pol_header.policy_header_id%TYPE)
    RETURN contact.obj_name_orig%TYPE;
  /**
   * �� �������� ������������ c �������� ������ ��
   * @author ������ �. 13.1.2015
   -- %param par_p_pol_header      �� ��������� ��
  */
  FUNCTION get_insurer_contact_id(par_p_pol_header p_pol_header.policy_header_id%TYPE)
    RETURN contact.contact_id%TYPE;
  /**
   * ����� �������� c �������� ������ ��
   * @author ������ �. 13.1.2015
   -- %param par_p_pol_header      �� ��������� ��
  */
  FUNCTION get_pol_num(par_p_pol_header p_pol_header.policy_header_id%TYPE) RETURN p_policy.pol_num%TYPE;
  /**
   * �������� ��� �����
   * @author ������ �. 14.1.2015
   -- %param par_bank_contact_id      �� �������� �����
  */
  FUNCTION get_bank_bik(par_bank_contact_id p_decline_bank_requisite.bank_contact_id%TYPE)
    RETURN cn_contact_ident.id_value%TYPE;

  /**
   * ���������� ���� ����������� � ����������� �� �������
   * @author ������ �. 16.1.2015
   -- %param par_t_decline_reason      �� ������� �����������
   -- %param par_policy_header_id  �� ������������� ��������
  */

  FUNCTION get_policy_decline_date
  (
    par_t_decline_reason t_decline_reason.t_decline_reason_id%TYPE
   ,par_policy_header_id p_pol_header.policy_header_id%TYPE
  ) RETURN p_pol_change_notice.policy_decline_date%TYPE;

  /**
   * �������� ���������� �����
   * @author ������ �. 16.1.2015
   -- %param par_account_number  ��������� ���� ��� ��������
  */
  PROCEDURE check_account_number
  (
    par_account_number    VARCHAR2
   ,par_bank_id           NUMBER
   ,par_bank_name         VARCHAR2
   ,par_error_message_out OUT VARCHAR2
   ,par_is_raise_out      OUT NUMBER
  );

  /**
   * �������� ��������� �����
   * @author ������ �. 16.1.2015
   -- %param par_account_number  ��������� ���� ��� ��������
  */
  PROCEDURE check_card_number
  
  (
    par_card_number               VARCHAR2
   ,par_error_message_out         OUT VARCHAR2
   ,par_is_raise_out              OUT NUMBER
   ,par_formatted_card_number_out OUT VARCHAR2
  );
  
END pkg_pol_change_notice_fmb;
/
CREATE OR REPLACE PACKAGE BODY pkg_pol_change_notice_fmb IS

  /**
    * ������� ������ ��������� 
    * @author ������ �. 30.12.2014
  -- %param par_t_message_kind_id �� ���� ���������
  -- %param par_t_message_type_id �� ���� ���������
  -- %param par_client_type_id    ��� �������
  -- %param par_t_crm_request_theme_id ���� ���������
  -- %param par_subj_message 
  -- %param par_note                   �����������
  -- %param par_pol_header_id          �� �������� ����������
  -- %param par_t_pol_chang_notice_type_id �� ���� ���������
  -- %param par_notice_date           ���� ���������
  -- %param par_notice_num            ����� ���������
  -- %param par_t_decline_reason_id   �� ������� �����������
  -- %param par_policy_decline_date   ���� �����������
  -- %param par_commentary            ����������� �� ���������
  -- %param par_ticket_num            ����� ������
  -- %param par_is_to_set_off         ���� "����� �� ������ ��"
  -- %param par_credit_repayment_date  ���� ��������� �������
  -- %param par_main_program_surr     �������� ����� �� �������� ���������
  -- %param par_invest_program_surr   �������� ����� �����
  -- %param par_reg_date              ���� �����������
  -- %param par_user_name             �������������
  -- %param par_index_number          ���������� �����
  -- %param par_user_name_loaded      �������� ������
  -- %param par_user_name_change      �������� �������
    */
  PROCEDURE insert_pol_change_notice
  (
    par_t_message_kind_id          inoutput_info.inoutput_info_id%TYPE
   ,par_t_message_type_id          inoutput_info.t_message_type_id%TYPE
   ,par_client_type_id             inoutput_info.client_type_id%TYPE
   ,par_t_crm_request_theme_id     inoutput_info.t_crm_request_theme_id%TYPE
   ,par_subj_message               inoutput_info.subj_message%TYPE
   ,par_note                       inoutput_info.note%TYPE
   ,par_pol_header_id              inoutput_info.pol_header_id%TYPE
   ,par_t_pol_chang_notice_type_id p_pol_change_notice.t_pol_change_notice_type_id%TYPE
   ,par_notice_date                p_pol_change_notice.notice_date%TYPE
   ,par_notice_num                 p_pol_change_notice.notice_num%TYPE
   ,par_t_decline_reason_id        p_pol_change_notice.t_decline_reason_id%TYPE
   ,par_policy_decline_date        p_pol_change_notice.policy_decline_date%TYPE
   ,par_commentary                 p_pol_change_notice.commentary%TYPE
   ,par_ticket_num                 p_pol_change_notice.ticket_num%TYPE
   ,par_is_to_set_off              p_pol_change_notice.is_to_set_off%TYPE
   ,par_credit_repayment_date      p_pol_change_notice.credit_repayment_date%TYPE
   ,par_reg_date                   document.reg_date%TYPE
   ,par_user_name                  inoutput_info.user_name%TYPE
   ,par_index_number               inoutput_info.index_number%TYPE
   ,par_user_name_loaded           inoutput_info.user_name_loaded%TYPE
   ,par_user_name_change           inoutput_info.user_name_change%TYPE
   ,par_inoutput_info_id_out       OUT inoutput_info.inoutput_info_id%TYPE
   ,par_p_pol_change_notice_id_out OUT p_pol_change_notice.p_pol_change_notice_id%TYPE
  ) IS
  BEGIN
    /*������� � ������ "��������/��������� ����������"*/
    dml_inoutput_info.insert_record(par_t_message_kind_id      => par_t_message_kind_id
                                   ,par_t_message_type_id      => par_t_message_type_id
                                   ,par_subj_message           => par_subj_message
                                   ,par_note                   => par_note
                                   ,par_pol_header_id          => par_pol_header_id
                                   ,par_t_crm_request_theme_id => par_t_crm_request_theme_id
                                   ,par_client_type_id         => par_client_type_id
                                   ,par_reg_date               => par_reg_date
                                   ,par_user_name              => par_user_name
                                   ,par_index_number           => par_index_number
                                   ,par_user_name_loaded       => par_user_name_loaded
                                   ,par_user_name_change       => par_user_name_change
                                   ,par_inoutput_info_id       => par_inoutput_info_id_out
                                   ,par_t_message_state_id     => dml_t_message_state.get_id_by_message_state_brief('POSTED') /*���������*/
                                   ,par_state_date             => SYSDATE);
    /*��������� ���� ����������� �� ��������, �.�. ������� ���� ���� ������ � document*/
    UPDATE inoutput_info i
       SET i.reg_date = SYSDATE /*timestampt*/
     WHERE i.inoutput_info_id = par_inoutput_info_id_out;
    /*������� � ""��������� �� ��������� ������� ��*/
    dml_p_pol_change_notice.insert_record(par_inoutput_info_id           => par_inoutput_info_id_out
                                         ,par_policy_header_id           => par_pol_header_id
                                         ,par_t_pol_chang_notice_type_id => par_t_pol_chang_notice_type_id
                                         ,par_notice_date                => par_notice_date
                                         ,par_doc_templ_id               => dml_doc_templ.get_id_by_brief('P_POL_CHANGE_NOTICE')
                                         ,par_reg_date                   => SYSDATE
                                         ,par_notice_num                 => par_notice_num
                                         ,par_t_decline_reason_id        => par_t_decline_reason_id
                                         ,par_policy_decline_date        => par_policy_decline_date
                                         ,par_commentary                 => par_commentary
                                         ,par_ticket_num                 => par_ticket_num
                                         ,par_is_to_set_off              => par_is_to_set_off
                                         ,par_credit_repayment_date      => par_credit_repayment_date
                                         ,par_p_pol_change_notice_id     => par_p_pol_change_notice_id_out);
    /*������*/
    doc.set_doc_status(par_p_pol_change_notice_id_out, 'PROJECT');
    
  END insert_pol_change_notice;

  /**
      * ���������� ���������� � ���������
      * @author ������ �. 12.1.2015
  -- %param par_inoutput_info_id  �� ��������/��������� ���-�
  -- %param par_p_pol_change_notice_id  �� ��������� 
  -- %param par_t_message_type_id  ���� ���������
  -- %param par_client_type_id   ��� �������
  -- %param par_note                   �����������
  -- %param par_pol_header_id          �� �������� ����������
  -- %param par_t_pol_chang_notice_type_id �� ���� ���������
  -- %param par_notice_date           ���� ���������
  -- %param par_notice_num            ����� ���������
  -- %param par_t_decline_reason_id   �� ������� �����������
  -- %param par_policy_decline_date   ���� �����������
  -- %param par_commentary            ����������� �� ���������
  -- %param par_ticket_num            ����� ������
  -- %param par_is_to_set_off         ���� "����� �� ������ ��"
  -- %param par_credit_repayment_date  ���� ��������� �������
  -- %param par_main_program_surr     �������� ����� �� �������� ���������
  -- %param par_invest_program_surr   �������� ����� �����
  -- %param par_reg_date              ���� �����������
  -- %param par_user_name             �������������
  -- %param par_index_number          ���������� �����
  -- %param par_user_name_loaded      �������� ������
  -- %param par_user_name_change      �������� �������
    */
  PROCEDURE update_pol_change_notice
  (
    par_inoutput_info_id           inoutput_info.inoutput_info_id%TYPE
   ,par_p_pol_change_notice_id     p_pol_change_notice.p_pol_change_notice_id%TYPE
   ,par_t_message_type_id          inoutput_info.t_message_type_id%TYPE
   ,par_client_type_id             inoutput_info.client_type_id%TYPE
   ,par_note                       inoutput_info.note%TYPE
   ,par_pol_header_id              inoutput_info.pol_header_id%TYPE
   ,par_t_pol_chang_notice_type_id p_pol_change_notice.t_pol_change_notice_type_id%TYPE
   ,par_notice_date                p_pol_change_notice.notice_date%TYPE
   ,par_notice_num                 p_pol_change_notice.notice_num%TYPE
   ,par_t_decline_reason_id        p_pol_change_notice.t_decline_reason_id%TYPE
   ,par_policy_decline_date        p_pol_change_notice.policy_decline_date%TYPE
   ,par_commentary                 p_pol_change_notice.commentary%TYPE
   ,par_ticket_num                 p_pol_change_notice.ticket_num%TYPE
   ,par_is_to_set_off              p_pol_change_notice.is_to_set_off%TYPE
   ,par_credit_repayment_date      p_pol_change_notice.credit_repayment_date%TYPE
   ,par_user_name                  inoutput_info.user_name%TYPE
   ,par_index_number               inoutput_info.index_number%TYPE
   ,par_user_name_loaded           inoutput_info.user_name_loaded%TYPE
   ,par_user_name_change           inoutput_info.user_name_change%TYPE
  ) IS
    vr_inoutput_info       dml_inoutput_info.tt_inoutput_info;
    vr_p_pol_change_notice dml_p_pol_change_notice.tt_p_pol_change_notice;
  
  BEGIN
    vr_inoutput_info       := dml_inoutput_info.get_record(par_inoutput_info_id);
    vr_p_pol_change_notice := dml_p_pol_change_notice.get_record(par_p_pol_change_notice_id);
  
    /*���������� ������*/
    vr_inoutput_info.t_message_type_id := par_t_message_type_id;
    vr_inoutput_info.client_type_id    := par_client_type_id;
    vr_inoutput_info.note              := par_note;
    vr_inoutput_info.pol_header_id     := par_pol_header_id;
    vr_inoutput_info.user_name         := par_user_name;
    vr_inoutput_info.user_name_loaded  := par_user_name_loaded;
    vr_inoutput_info.user_name_change  := par_user_name_change;
    vr_inoutput_info.index_number      := par_index_number;
  
    vr_p_pol_change_notice.t_pol_change_notice_type_id := par_t_pol_chang_notice_type_id;
    vr_p_pol_change_notice.notice_date                 := par_notice_date;
    vr_p_pol_change_notice.notice_num                  := par_notice_num;
    vr_p_pol_change_notice.t_decline_reason_id         := par_t_decline_reason_id;
    vr_p_pol_change_notice.policy_decline_date         := par_policy_decline_date;
    vr_p_pol_change_notice.commentary                  := par_commentary;
    vr_p_pol_change_notice.ticket_num                  := par_ticket_num;
    vr_p_pol_change_notice.is_to_set_off               := par_is_to_set_off;
    vr_p_pol_change_notice.credit_repayment_date       := par_credit_repayment_date;
  
    dml_inoutput_info.update_record(vr_inoutput_info);
    dml_p_pol_change_notice.update_record(vr_p_pol_change_notice);
  
  END update_pol_change_notice;

  /**
  * �������� ���������
  * @author ������ �. 05.02.2015
  * @param par_p_pol_change_notice_id - �� ���������
  */
  PROCEDURE delete_pol_change_notice(par_p_pol_change_notice_id p_pol_change_notice.p_pol_change_notice_id%TYPE) IS
    vr_p_pol_change_notice dml_p_pol_change_notice.tt_p_pol_change_notice;
  BEGIN
    vr_p_pol_change_notice := dml_p_pol_change_notice.get_record(par_p_pol_change_notice_id);
  
    DELETE FROM p_pol_change_notice cn WHERE cn.p_pol_change_notice_id = par_p_pol_change_notice_id;
    DELETE FROM inoutput_info ii WHERE ii.inoutput_info_id = vr_p_pol_change_notice.inoutput_info_id;
  
  END delete_pol_change_notice;

  /**
   * ��� ������������ c �������� ������ ��
   * @author ������ �. 13.1.2015
   -- %param par_p_pol_header      �� ��������� ��
  */
  FUNCTION get_insurer_name(par_p_pol_header p_pol_header.policy_header_id%TYPE)
    RETURN contact.obj_name_orig%TYPE IS
    v_insurer_name contact.obj_name_orig%TYPE;
  BEGIN
    SELECT v.contact_name
      INTO v_insurer_name
      FROM v_pol_issuer v
          ,p_pol_header h
     WHERE h.policy_header_id = par_p_pol_header
       AND h.policy_id = v.policy_id;
    RETURN v_insurer_name;
  EXCEPTION
    WHEN no_data_found
         OR too_many_rows THEN
      RETURN NULL;
  END get_insurer_name;

  /**
   * �� �������� ������������ c �������� ������ ��
   * @author ������ �. 13.1.2015
   -- %param par_p_pol_header      �� ��������� ��
  */
  FUNCTION get_insurer_contact_id(par_p_pol_header p_pol_header.policy_header_id%TYPE)
    RETURN contact.contact_id%TYPE IS
    v_insurer_name contact.obj_name_orig%TYPE;
  BEGIN
    SELECT v.contact_id
      INTO v_insurer_name
      FROM v_pol_issuer v
          ,p_pol_header h
     WHERE h.policy_header_id = par_p_pol_header
       AND h.policy_id = v.policy_id;
    RETURN v_insurer_name;
  EXCEPTION
    WHEN no_data_found
         OR too_many_rows THEN
      RETURN NULL;
  END get_insurer_contact_id;

  /**
   * ����� �������� c �������� ������ ��
   * @author ������ �. 13.1.2015
   -- %param par_p_pol_header      �� ��������� ��
  */
  FUNCTION get_pol_num(par_p_pol_header p_pol_header.policy_header_id%TYPE) RETURN p_policy.pol_num%TYPE IS
    v_pol_num p_policy.pol_num%TYPE;
  BEGIN
    SELECT p.pol_num
      INTO v_pol_num
      FROM p_policy     p
          ,p_pol_header h
     WHERE h.policy_header_id = par_p_pol_header
       AND h.policy_id = p.policy_id;
    RETURN v_pol_num;
  EXCEPTION
    WHEN no_data_found
         OR too_many_rows THEN
      RETURN NULL;
  END get_pol_num;

  /**
   * �������� ��� �����
   * @author ������ �. 14.1.2015
   -- %param par_bank_contact_id      �� �������� �����
  */
  FUNCTION get_bank_bik(par_bank_contact_id p_decline_bank_requisite.bank_contact_id%TYPE)
    RETURN cn_contact_ident.id_value%TYPE IS
    /*��� �����*/
    v_bank_bik cn_contact_ident.id_value%TYPE;
  BEGIN
    SELECT cci.id_value
      INTO v_bank_bik
      FROM cn_contact_ident cci
     WHERE cci.contact_id = par_bank_contact_id
       AND cci.table_id = pkg_contact.get_contact_document_id(par_bank_contact_id, 'BIK');
    RETURN v_bank_bik;
  EXCEPTION
    WHEN no_data_found
         OR too_many_rows THEN
      RETURN NULL;
  END get_bank_bik;

  /**
   * ���������� ���� ����������� � ����������� �� �������
   * @author ������ �. 16.1.2015
   -- %param par_t_decline_reason      �� ������� �����������
   -- %param par_policy_header_id  �� ������������� ��������
  */

  FUNCTION get_policy_decline_date
  (
    par_t_decline_reason t_decline_reason.t_decline_reason_id%TYPE
   ,par_policy_header_id p_pol_header.policy_header_id%TYPE
  ) RETURN p_pol_change_notice.policy_decline_date%TYPE IS
    /*���������� ������� �����������*/
    vr_t_decline_reason dml_t_decline_reason.tt_t_decline_reason; --������� ����������
    vr_t_decline_type   dml_t_decline_type.tt_t_decline_type; --��� �������
    vr_policy_header    dml_p_pol_header.tt_p_pol_header;
    vr_poilcy           dml_p_policy.tt_p_policy;
  
    v_policy_decline_date p_pol_change_notice.policy_decline_date%TYPE;
  
    /*���� ������ ���������������*/
    FUNCTION get_assured_death_date(par_policy_header_id p_pol_header.policy_header_id%TYPE)
      RETURN cn_person.date_of_death%TYPE IS
      v_date_of_death cn_person.date_of_death%TYPE;
    BEGIN
      SELECT cp.date_of_death
        INTO v_date_of_death
        FROM p_pol_header pph
            ,as_asset     ass
            ,as_assured   asd
            ,cn_person    cp
       WHERE pph.policy_header_id = par_policy_header_id
         AND pph.policy_id = ass.p_policy_id
         AND ass.as_asset_id = asd.as_assured_id
         AND asd.assured_contact_id = cp.contact_id;
      RETURN v_date_of_death;
    EXCEPTION
      WHEN no_data_found
           OR too_many_rows THEN
        RETURN NULL;
    END get_assured_death_date;
  
    /*���� ������ ������������*/
    FUNCTION get_insurer_death_date(par_policy_header_id p_pol_header.policy_header_id%TYPE)
      RETURN cn_person.date_of_death%TYPE IS
      v_date_of_death cn_person.date_of_death%TYPE;
    BEGIN
      SELECT cp.date_of_death
        INTO v_date_of_death
        FROM p_pol_header pph
            ,v_pol_issuer vpi
            ,cn_person    cp
       WHERE pph.policy_header_id = par_policy_header_id
         AND pph.policy_id = vpi.policy_id
         AND vpi.contact_id = cp.contact_id;
      RETURN v_date_of_death;
    EXCEPTION
      WHEN no_data_found
           OR too_many_rows THEN
        RETURN NULL;
    END get_insurer_death_date;
  BEGIN
    /*� ����������� �� ������� �����������: 
    � ���� ��� ������� ����������� ����� ��������������, �� ���� ���������� �������� �����������;
    � ���� ������� ����������� ����� ������� ���������������, ��  �������� ���� ����� ������ �������� ���������������;
    � ���� ������� ����������� ����� ������� �������������, �� �������� ���� ����� ������ �������� ������������;
    � ���� ������� ����������� ����� ���������� �������������� �������, �� �������� ���� ����� ��������� �������������� ������� �������� ������ ��
    � ��� ���� ��������� ������ � ������ ����
    */
    vr_t_decline_reason := dml_t_decline_reason.get_record(par_t_decline_reason_id => par_t_decline_reason);
    vr_t_decline_type   := dml_t_decline_type.get_record(par_t_decline_type_id => vr_t_decline_reason.t_decline_type_id);
    vr_policy_header    := dml_p_pol_header.get_record(par_policy_header_id);
  
    /*��� ������� - �������������*/
    IF vr_t_decline_type.brief = '�������������'
    THEN
      v_policy_decline_date := vr_policy_header.start_date;
    ELSIF vr_t_decline_reason.brief = '������ ���������������'
    THEN
      v_policy_decline_date := get_assured_death_date(par_policy_header_id);
    ELSIF vr_t_decline_reason.brief = '������ ������������'
    THEN
      v_policy_decline_date := get_insurer_death_date(par_policy_header_id);
    ELSIF vr_t_decline_reason.brief = '��������� ���. �������'
    THEN
      vr_poilcy             := dml_p_policy.get_record(par_policy_id => vr_policy_header.policy_id);
      v_policy_decline_date := vr_poilcy.waiting_period_end_date;
    END IF;
  
    RETURN v_policy_decline_date;
  END get_policy_decline_date;

  /**
   * �������� ���������� �����
   * @author ������ �. 16.1.2015
   -- %param par_account_number  ��������� ���� ��� ��������
  */
  PROCEDURE check_account_number
  (
    par_account_number    VARCHAR2
   ,par_bank_id           NUMBER
   ,par_bank_name         VARCHAR2
   ,par_error_message_out OUT VARCHAR2
   ,par_is_raise_out      OUT NUMBER
  ) IS
    c_is_hkf            BOOLEAN := par_bank_name = '��� "��� ����"';
    v_currency_code     VARCHAR2(3);
    v_bank_account      VARCHAR2(5);
    v_is_account_exists NUMBER(1);
    v_control_number    VARCHAR2(1);
    v_user_have_right   NUMBER(1);
  BEGIN
    v_user_have_right := safety.check_right_custom('PAYM_DETAIL_WITHOUT_RESTRICTION');
    IF length(par_account_number) != 20
    THEN
      IF v_user_have_right = 0
      THEN
        par_error_message_out := '���������� �������� ������ ���� ������ 20';
        par_is_raise_out      := 1;
      ELSIF c_is_hkf
            AND par_account_number IS NULL
      THEN
        NULL;
      ELSE
        par_error_message_out := '���������� �������� ������ ���� ������ 20';
        par_is_raise_out      := 0;
      END IF;
    END IF;
  
    IF v_user_have_right = 0
    THEN
      DECLARE
        v_dummy NUMBER;
      BEGIN
        v_dummy := to_number(par_account_number);
      EXCEPTION
        WHEN value_error THEN
          IF c_is_hkf
             AND par_account_number IS NULL
          THEN
            NULL;
          ELSE
            par_error_message_out := '�������� �������� ������ �������� ������ �� ����';
            par_is_raise_out      := 1;
          END IF;
      END;
    
      v_currency_code := substr(substr(par_account_number, 1, 8), -3);
    
      IF v_currency_code = '810'
         OR v_currency_code = '643'
         OR (c_is_hkf AND par_account_number IS NULL)
      THEN
        NULL;
      ELSE
        par_error_message_out := '������ ����� - ������� � ������� ��� �������: �������� 810 ��� 643.';
        par_is_raise_out      := 1;
      END IF;
    
    END IF;
  
    v_bank_account := substr(par_account_number, 1, 5);
  
    SELECT COUNT(*)
      INTO v_is_account_exists
      FROM dual
     WHERE EXISTS (SELECT NULL
              FROM t_desc_account dacc
             WHERE dacc.num_account = v_bank_account
               AND dacc.state_account = '��������'
               AND dacc.type_account = 1);
  
    IF v_is_account_exists = 0
    THEN
      IF c_is_hkf
         AND par_account_number IS NULL
      THEN
        NULL;
      ELSIF v_user_have_right = 0
      THEN
        par_error_message_out := '����� ����� - ������� � ������� ���� ��������: �������� ' ||
                                 v_bank_account || ' ��� � ����������� ������.';
        par_is_raise_out      := 1;
      ELSE
        par_error_message_out := '����� ����� - ������� � ������� ���� ��������: �������� ' ||
                                 v_bank_account || ' ��� � ����������� ������.';
        par_is_raise_out      := 0;
      END IF;
    END IF;
  
    v_control_number := pkg_contact.check_control_account(par_bank_id, par_account_number);
  
    IF v_control_number <> substr(par_account_number, 9, 1)
    THEN
      IF c_is_hkf
         AND par_account_number IS NULL
      THEN
        NULL;
      ELSIF v_user_have_right = 0
      THEN
        par_error_message_out := '����������� ����� - ������� � �������� ���� ������: �������� ' ||
                                 substr(par_account_number, 9, 1) || ' �� �������� �����������.';
        par_is_raise_out      := 1;
      ELSE
        par_error_message_out := '����������� ����� - ������� � �������� ���� ������: �������� ' ||
                                 substr(par_account_number, 9, 1) || ' �� �������� �����������.';
        par_is_raise_out      := 0;
      END IF;
    END IF;
  
  END check_account_number;

  /**
   * �������� ��������� �����
   * @author ������ �. 16.1.2015
   -- %param par_account_number  ��������� ���� ��� ��������
  */
  PROCEDURE check_card_number
  (
    par_card_number               VARCHAR2
   ,par_error_message_out         OUT VARCHAR2
   ,par_is_raise_out              OUT NUMBER
   ,par_formatted_card_number_out OUT VARCHAR2
  ) IS
    p_len          NUMBER;
    p_corr         NUMBER;
    p_check_custom NUMBER;
    p_cur_corr     VARCHAR2(100);
  BEGIN
    IF par_card_number IS NOT NULL
       AND instr(par_card_number, 'X') = 0
    THEN
      p_check_custom := safety.check_right_custom('PAYM_DETAIL_WITHOUT_RESTRICTION');
      /*��������� ���-�� ����*/
      SELECT length(TRIM(translate(upper(par_card_number)
                                  ,'ABCDEFGHIJKLMNOPQRSTUVWXYZ�����Ũ�������������������������-=+,.!@#$%^&*()_\|/ '
                                  ,' ')))
        INTO p_len
        FROM dual;
    
      IF p_len < 4
         OR p_len > 19
      THEN
        par_error_message_out := '���������� ���� � ������ ����� �� ����� ���� ������ 4 � ������ 19';
        par_is_raise_out      := 1;
      END IF;
    
      SELECT nvl(length(TRIM(translate(upper(par_card_number), '1234567890X-', ' '))), 0)
        INTO p_corr
        FROM dual;
    
      IF p_corr > 0
         AND p_check_custom = 0
      THEN
        par_error_message_out := '������� ������ ������ � ������ �����';
        par_is_raise_out      := 1;
      END IF;
    
      /*��������� ����� �����*/
      SELECT translate(upper(par_card_number)
                      ,'ABCDEFGHIJKLMNOPQRSTUVWXYZ�����Ũ�������������������������-=+,.!@#$%^&*()_\|/ '
                      ,' ')
        INTO p_cur_corr
        FROM dual;
    
      /*��� ����������� (���������� ������ ����� �� ��� ����� 12-22-23*/
      IF p_check_custom = 1
      THEN
      
        CASE p_len
          WHEN 4 THEN
            SELECT substr(p_cur_corr, 1, 2) || '-' || substr(p_cur_corr, 3, 2)
              INTO par_formatted_card_number_out
              FROM dual;
          WHEN 5 THEN
            SELECT substr(p_cur_corr, 1, 2) || '-' || substr(p_cur_corr, 3, 3)
              INTO par_formatted_card_number_out
              FROM dual;
          WHEN 6 THEN
            SELECT substr(p_cur_corr, 1, 2) || '-' || substr(p_cur_corr, 3, 2) || '-' ||
                   substr(p_cur_corr, 5, 2)
              INTO par_formatted_card_number_out
              FROM dual;
          WHEN 7 THEN
            SELECT substr(p_cur_corr, 1, 2) || '-' || substr(p_cur_corr, 3, 2) || '-' ||
                   substr(p_cur_corr, 5, 3)
              INTO par_formatted_card_number_out
              FROM dual;
          WHEN 8 THEN
            SELECT substr(p_cur_corr, 1, 2) || '-' || substr(p_cur_corr, 3, 2) || '-' ||
                   substr(p_cur_corr, 5, 2) || '-' || substr(p_cur_corr, 7, 2)
              INTO par_formatted_card_number_out
              FROM dual;
          WHEN 9 THEN
            SELECT substr(p_cur_corr, 1, 2) || '-' || substr(p_cur_corr, 3, 2) || '-' ||
                   substr(p_cur_corr, 5, 2) || '-' || substr(p_cur_corr, 7, 3)
              INTO par_formatted_card_number_out
              FROM dual;
          WHEN 10 THEN
            SELECT substr(p_cur_corr, 1, 2) || '-' || substr(p_cur_corr, 3, 2) || '-' ||
                   substr(p_cur_corr, 5, 2) || '-' || substr(p_cur_corr, 7, 2) || '-' ||
                   substr(p_cur_corr, 9, 2)
              INTO par_formatted_card_number_out
              FROM dual;
          WHEN 11 THEN
            SELECT substr(p_cur_corr, 1, 2) || '-' || substr(p_cur_corr, 3, 2) || '-' ||
                   substr(p_cur_corr, 5, 2) || '-' || substr(p_cur_corr, 7, 2) || '-' ||
                   substr(p_cur_corr, 9, 3)
              INTO par_formatted_card_number_out
              FROM dual;
          WHEN 12 THEN
            SELECT substr(p_cur_corr, 1, 2) || '-' || substr(p_cur_corr, 3, 2) || '-' ||
                   substr(p_cur_corr, 5, 2) || '-' || substr(p_cur_corr, 7, 2) || '-' ||
                   substr(p_cur_corr, 9, 2) || '-' || substr(p_cur_corr, 11, 2)
              INTO par_formatted_card_number_out
              FROM dual;
          WHEN 13 THEN
            SELECT substr(p_cur_corr, 1, 2) || '-' || substr(p_cur_corr, 3, 2) || '-' ||
                   substr(p_cur_corr, 5, 2) || '-' || substr(p_cur_corr, 7, 2) || '-' ||
                   substr(p_cur_corr, 9, 2) || '-' || substr(p_cur_corr, 11, 3)
              INTO par_formatted_card_number_out
              FROM dual;
          WHEN 14 THEN
            SELECT substr(p_cur_corr, 1, 2) || '-' || substr(p_cur_corr, 3, 2) || '-' ||
                   substr(p_cur_corr, 5, 2) || '-' || substr(p_cur_corr, 7, 2) || '-' ||
                   substr(p_cur_corr, 9, 2) || '-' || substr(p_cur_corr, 11, 2) || '-' ||
                   substr(p_cur_corr, 13, 2)
              INTO par_formatted_card_number_out
              FROM dual;
          WHEN 15 THEN
            SELECT substr(p_cur_corr, 1, 2) || '-' || substr(p_cur_corr, 3, 2) || '-' ||
                   substr(p_cur_corr, 5, 2) || '-' || substr(p_cur_corr, 7, 2) || '-' ||
                   substr(p_cur_corr, 9, 2) || '-' || substr(p_cur_corr, 11, 2) || '-' ||
                   substr(p_cur_corr, 13, 3)
              INTO par_formatted_card_number_out
              FROM dual;
          WHEN 16 THEN
            SELECT substr(p_cur_corr, 1, 2) || '-' || substr(p_cur_corr, 3, 2) || '-' ||
                   substr(p_cur_corr, 5, 2) || '-' || substr(p_cur_corr, 7, 2) || '-' ||
                   substr(p_cur_corr, 9, 2) || '-' || substr(p_cur_corr, 11, 2) || '-' ||
                   substr(p_cur_corr, 13, 2) || '-' || substr(p_cur_corr, 15, 2)
              INTO par_formatted_card_number_out
              FROM dual;
          WHEN 17 THEN
            SELECT substr(p_cur_corr, 1, 2) || '-' || substr(p_cur_corr, 3, 2) || '-' ||
                   substr(p_cur_corr, 5, 2) || '-' || substr(p_cur_corr, 7, 2) || '-' ||
                   substr(p_cur_corr, 9, 2) || '-' || substr(p_cur_corr, 11, 2) || '-' ||
                   substr(p_cur_corr, 13, 2) || '-' || substr(p_cur_corr, 15, 3)
              INTO par_formatted_card_number_out
              FROM dual;
          WHEN 18 THEN
            SELECT substr(p_cur_corr, 1, 2) || '-' || substr(p_cur_corr, 3, 2) || '-' ||
                   substr(p_cur_corr, 5, 2) || '-' || substr(p_cur_corr, 7, 2) || '-' ||
                   substr(p_cur_corr, 9, 2) || '-' || substr(p_cur_corr, 11, 2) || '-' ||
                   substr(p_cur_corr, 13, 2) || '-' || substr(p_cur_corr, 15, 2) || '-' ||
                   substr(p_cur_corr, 17, 2)
              INTO par_formatted_card_number_out
              FROM dual;
          WHEN 19 THEN
            SELECT substr(p_cur_corr, 1, 2) || '-' || substr(p_cur_corr, 3, 2) || '-' ||
                   substr(p_cur_corr, 5, 2) || '-' || substr(p_cur_corr, 7, 2) || '-' ||
                   substr(p_cur_corr, 9, 2) || '-' || substr(p_cur_corr, 11, 2) || '-' ||
                   substr(p_cur_corr, 13, 2) || '-' || substr(p_cur_corr, 15, 2) || '-' ||
                   substr(p_cur_corr, 17, 3)
              INTO par_formatted_card_number_out
              FROM dual;
          ELSE
            NULL;
        END CASE;
      
      ELSE
        /*�������� �����, ���� ��� ����*/
        CASE p_len
          WHEN 4 THEN
            SELECT substr(p_cur_corr, 1, 2) || '-' || 'XX'
              INTO par_formatted_card_number_out
              FROM dual;
          WHEN 5 THEN
            SELECT substr(p_cur_corr, 1, 2) || '-' || 'XXX'
              INTO par_formatted_card_number_out
              FROM dual;
          WHEN 6 THEN
            SELECT substr(p_cur_corr, 1, 2) || '-' || 'XX-XX'
              INTO par_formatted_card_number_out
              FROM dual;
          WHEN 7 THEN
            SELECT substr(p_cur_corr, 1, 2) || '-' || 'XX-XX' || substr(p_cur_corr, 7, 1)
              INTO par_formatted_card_number_out
              FROM dual;
          WHEN 8 THEN
            SELECT substr(p_cur_corr, 1, 2) || '-' || 'XX-XX-X' || substr(p_cur_corr, 8, 1)
              INTO par_formatted_card_number_out
              FROM dual;
          WHEN 9 THEN
            SELECT substr(p_cur_corr, 1, 2) || '-' || 'XX-XX-XX' || substr(p_cur_corr, 9, 1)
              INTO par_formatted_card_number_out
              FROM dual;
          WHEN 10 THEN
            SELECT substr(p_cur_corr, 1, 2) || '-' || 'XX-XX-XX-' || substr(p_cur_corr, 9, 2)
              INTO par_formatted_card_number_out
              FROM dual;
          WHEN 11 THEN
            SELECT substr(p_cur_corr, 1, 2) || '-' || 'XX-XX-XX-X' || substr(p_cur_corr, 10, 2)
              INTO par_formatted_card_number_out
              FROM dual;
          WHEN 12 THEN
            SELECT substr(p_cur_corr, 1, 2) || '-' || 'XX-XX-XX-XX-' || substr(p_cur_corr, 11, 2)
              INTO par_formatted_card_number_out
              FROM dual;
          WHEN 13 THEN
            SELECT substr(p_cur_corr, 1, 2) || '-' || 'XX-XX-XX-XX-' || substr(p_cur_corr, 11, 3)
              INTO par_formatted_card_number_out
              FROM dual;
          WHEN 14 THEN
            SELECT substr(p_cur_corr, 1, 2) || '-' || 'XX-XX-XX-XX-X' || substr(p_cur_corr, 12, 1) || '-' ||
                   substr(p_cur_corr, 13, 2)
              INTO par_formatted_card_number_out
              FROM dual;
          WHEN 15 THEN
            SELECT substr(p_cur_corr, 1, 2) || '-' || 'XX-XX-XX-XX-XX-' || substr(p_cur_corr, 13, 3)
              INTO par_formatted_card_number_out
              FROM dual;
          WHEN 16 THEN
            SELECT substr(p_cur_corr, 1, 2) || '-' || 'XX-XX-XX-XX-XX-' || substr(p_cur_corr, 13, 2) || '-' ||
                   substr(p_cur_corr, 15, 2)
              INTO par_formatted_card_number_out
              FROM dual;
          WHEN 17 THEN
            SELECT substr(p_cur_corr, 1, 2) || '-' || 'XX-XX-XX-XX-XX-X' || substr(p_cur_corr, 14, 1) || '-' ||
                   substr(p_cur_corr, 15, 3)
              INTO par_formatted_card_number_out
              FROM dual;
          WHEN 18 THEN
            SELECT substr(p_cur_corr, 1, 2) || '-' || 'XX-XX-XX-XX-XX-XX-' ||
                   substr(p_cur_corr, 15, 2) || '-' || substr(p_cur_corr, 17, 2)
              INTO par_formatted_card_number_out
              FROM dual;
          WHEN 19 THEN
            SELECT substr(p_cur_corr, 1, 2) || '-' || 'XX-XX-XX-XX-XX-XX-X' ||
                   substr(p_cur_corr, 16, 1) || '-' || substr(p_cur_corr, 17, 3)
              INTO par_formatted_card_number_out
              FROM dual;
          ELSE
            NULL;
        END CASE;
      END IF;
    END IF;
  END check_card_number;

  

END pkg_pol_change_notice_fmb;
/

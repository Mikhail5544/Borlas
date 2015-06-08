CREATE OR REPLACE PACKAGE pkg_pol_change_notice_fmb IS

  -- Author  : Черных М.
  -- Created : 29.12.2014
  -- Purpose : Утилиты для формы "Заявление на изменение условий ДС"

  /**
    * Вставка нового заявления 
    * @author Черных М. 30.12.2014
  -- %param par_t_message_kind_id ИД вида обращения
  -- %param par_t_message_type_id ИД типа обращения
  -- %param par_client_type_id    Тип клиента
  -- %param par_t_crm_request_theme_id Тема обращения
  -- %param par_subj_message 
  -- %param par_note                   Комментарий
  -- %param par_pol_header_id          ИД договора страховаия
  -- %param par_t_pol_chang_notice_type_id ИД типа заявления
  -- %param par_notice_date           Дата заявления
  -- %param par_notice_num            Номер заявления
  -- %param par_t_decline_reason_id   ИД причины расторжения
  -- %param par_policy_decline_date   Дата расторжения
  -- %param par_commentary            Комментарий на заявлении
  -- %param par_ticket_num            Номер заявки
  -- %param par_is_to_set_off         Флаг "Зачет на другие ДС"
  -- %param par_credit_repayment_date  Дата погашения кредита
  -- %param par_main_program_surr     Выкупная сумма по основной программе
  -- %param par_invest_program_surr   Выкупная сумма Ивест
  -- %param par_reg_date              Дата регистрации
  -- %param par_user_name             Ответственный
  -- %param par_index_number          Порядковый номер
  -- %param par_user_name_loaded      Оператор создал
  -- %param par_user_name_change      Оператор изменил
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
      * Обновление информации в заявлении
      * @author Черных М. 12.1.2015
  -- %param par_inoutput_info_id  ИД входящей/исходящей инф-т
  -- %param par_p_pol_change_notice_id  ИД заявления 
  -- %param par_t_message_type_id  Тема сообщения
  -- %param par_client_type_id   Тип клиента
  -- %param par_note                   Комментарий
  -- %param par_pol_header_id          ИД договора страховаия
  -- %param par_t_pol_chang_notice_type_id ИД типа заявления
  -- %param par_notice_date           Дата заявления
  -- %param par_notice_num            Номер заявления
  -- %param par_t_decline_reason_id   ИД причины расторжения
  -- %param par_policy_decline_date   Дата расторжения
  -- %param par_commentary            Комментарий на заявлении
  -- %param par_ticket_num            Номер заявки
  -- %param par_is_to_set_off         Флаг "Зачет на другие ДС"
  -- %param par_credit_repayment_date  Дата погашения кредита
  -- %param par_main_program_surr     Выкупная сумма по основной программе
  -- %param par_invest_program_surr   Выкупная сумма Ивест
  -- %param par_reg_date              Дата регистрации
  -- %param par_user_name             Ответственный
  -- %param par_index_number          Порядковый номер
  -- %param par_user_name_loaded      Оператор создал
  -- %param par_user_name_change      Оператор изменил
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
  * Удаление заявления
  * @author Черных М. 05.02.2015
  * @param par_p_pol_change_notice_id - ИД заявления
  */
  PROCEDURE delete_pol_change_notice(par_p_pol_change_notice_id p_pol_change_notice.p_pol_change_notice_id%TYPE);

  /**
   * ФИО страхователя c активной версии ДС
   * @author Черных М. 13.1.2015
   -- %param par_p_pol_header      ИД заголовка ДС
  */
  FUNCTION get_insurer_name(par_p_pol_header p_pol_header.policy_header_id%TYPE)
    RETURN contact.obj_name_orig%TYPE;
  /**
   * ИД контакта страхователя c активной версии ДС
   * @author Черных М. 13.1.2015
   -- %param par_p_pol_header      ИД заголовка ДС
  */
  FUNCTION get_insurer_contact_id(par_p_pol_header p_pol_header.policy_header_id%TYPE)
    RETURN contact.contact_id%TYPE;
  /**
   * Номер договора c активной версии ДС
   * @author Черных М. 13.1.2015
   -- %param par_p_pol_header      ИД заголовка ДС
  */
  FUNCTION get_pol_num(par_p_pol_header p_pol_header.policy_header_id%TYPE) RETURN p_policy.pol_num%TYPE;
  /**
   * Получить БИК банка
   * @author Черных М. 14.1.2015
   -- %param par_bank_contact_id      ИД контакта Банка
  */
  FUNCTION get_bank_bik(par_bank_contact_id p_decline_bank_requisite.bank_contact_id%TYPE)
    RETURN cn_contact_ident.id_value%TYPE;

  /**
   * Определить дату расторжения в зависимости от причины
   * @author Черных М. 16.1.2015
   -- %param par_t_decline_reason      ИД причины расторжения
   -- %param par_policy_header_id  ИД расторгаемого договора
  */

  FUNCTION get_policy_decline_date
  (
    par_t_decline_reason t_decline_reason.t_decline_reason_id%TYPE
   ,par_policy_header_id p_pol_header.policy_header_id%TYPE
  ) RETURN p_pol_change_notice.policy_decline_date%TYPE;

  /**
   * Проверка Расчетного счета
   * @author Черных М. 16.1.2015
   -- %param par_account_number  Расчетный счет для проверки
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
   * Проверка кредитной карты
   * @author Черных М. 16.1.2015
   -- %param par_account_number  Расчетный счет для проверки
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
    * Вставка нового заявления 
    * @author Черных М. 30.12.2014
  -- %param par_t_message_kind_id ИД вида обращения
  -- %param par_t_message_type_id ИД типа обращения
  -- %param par_client_type_id    Тип клиента
  -- %param par_t_crm_request_theme_id Тема обращения
  -- %param par_subj_message 
  -- %param par_note                   Комментарий
  -- %param par_pol_header_id          ИД договора страховаия
  -- %param par_t_pol_chang_notice_type_id ИД типа заявления
  -- %param par_notice_date           Дата заявления
  -- %param par_notice_num            Номер заявления
  -- %param par_t_decline_reason_id   ИД причины расторжения
  -- %param par_policy_decline_date   Дата расторжения
  -- %param par_commentary            Комментарий на заявлении
  -- %param par_ticket_num            Номер заявки
  -- %param par_is_to_set_off         Флаг "Зачет на другие ДС"
  -- %param par_credit_repayment_date  Дата погашения кредита
  -- %param par_main_program_surr     Выкупная сумма по основной программе
  -- %param par_invest_program_surr   Выкупная сумма Ивест
  -- %param par_reg_date              Дата регистрации
  -- %param par_user_name             Ответственный
  -- %param par_index_number          Порядковый номер
  -- %param par_user_name_loaded      Оператор создал
  -- %param par_user_name_change      Оператор изменил
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
    /*Вставка в журнал "Входящей/исходящей информации"*/
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
                                   ,par_t_message_state_id     => dml_t_message_state.get_id_by_message_state_brief('POSTED') /*Отправлен*/
                                   ,par_state_date             => SYSDATE);
    /*Обновляем дату регистрации на журанале, т.к. вставка идет даты только в document*/
    UPDATE inoutput_info i
       SET i.reg_date = SYSDATE /*timestampt*/
     WHERE i.inoutput_info_id = par_inoutput_info_id_out;
    /*Вставка в ""Заявление на изменение условий ДС*/
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
    /*Проект*/
    doc.set_doc_status(par_p_pol_change_notice_id_out, 'PROJECT');
    
  END insert_pol_change_notice;

  /**
      * Обновление информации в заявлении
      * @author Черных М. 12.1.2015
  -- %param par_inoutput_info_id  ИД входящей/исходящей инф-т
  -- %param par_p_pol_change_notice_id  ИД заявления 
  -- %param par_t_message_type_id  Тема сообщения
  -- %param par_client_type_id   Тип клиента
  -- %param par_note                   Комментарий
  -- %param par_pol_header_id          ИД договора страховаия
  -- %param par_t_pol_chang_notice_type_id ИД типа заявления
  -- %param par_notice_date           Дата заявления
  -- %param par_notice_num            Номер заявления
  -- %param par_t_decline_reason_id   ИД причины расторжения
  -- %param par_policy_decline_date   Дата расторжения
  -- %param par_commentary            Комментарий на заявлении
  -- %param par_ticket_num            Номер заявки
  -- %param par_is_to_set_off         Флаг "Зачет на другие ДС"
  -- %param par_credit_repayment_date  Дата погашения кредита
  -- %param par_main_program_surr     Выкупная сумма по основной программе
  -- %param par_invest_program_surr   Выкупная сумма Ивест
  -- %param par_reg_date              Дата регистрации
  -- %param par_user_name             Ответственный
  -- %param par_index_number          Порядковый номер
  -- %param par_user_name_loaded      Оператор создал
  -- %param par_user_name_change      Оператор изменил
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
  
    /*Обновление данных*/
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
  * Удаление заявления
  * @author Черных М. 05.02.2015
  * @param par_p_pol_change_notice_id - ИД заявления
  */
  PROCEDURE delete_pol_change_notice(par_p_pol_change_notice_id p_pol_change_notice.p_pol_change_notice_id%TYPE) IS
    vr_p_pol_change_notice dml_p_pol_change_notice.tt_p_pol_change_notice;
  BEGIN
    vr_p_pol_change_notice := dml_p_pol_change_notice.get_record(par_p_pol_change_notice_id);
  
    DELETE FROM p_pol_change_notice cn WHERE cn.p_pol_change_notice_id = par_p_pol_change_notice_id;
    DELETE FROM inoutput_info ii WHERE ii.inoutput_info_id = vr_p_pol_change_notice.inoutput_info_id;
  
  END delete_pol_change_notice;

  /**
   * ФИО страхователя c активной версии ДС
   * @author Черных М. 13.1.2015
   -- %param par_p_pol_header      ИД заголовка ДС
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
   * ИД контакта страхователя c активной версии ДС
   * @author Черных М. 13.1.2015
   -- %param par_p_pol_header      ИД заголовка ДС
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
   * Номер договора c активной версии ДС
   * @author Черных М. 13.1.2015
   -- %param par_p_pol_header      ИД заголовка ДС
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
   * Получить БИК банка
   * @author Черных М. 14.1.2015
   -- %param par_bank_contact_id      ИД контакта Банка
  */
  FUNCTION get_bank_bik(par_bank_contact_id p_decline_bank_requisite.bank_contact_id%TYPE)
    RETURN cn_contact_ident.id_value%TYPE IS
    /*БИК Банка*/
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
   * Определить дату расторжения в зависимости от причины
   * @author Черных М. 16.1.2015
   -- %param par_t_decline_reason      ИД причины расторжения
   -- %param par_policy_header_id  ИД расторгаемого договора
  */

  FUNCTION get_policy_decline_date
  (
    par_t_decline_reason t_decline_reason.t_decline_reason_id%TYPE
   ,par_policy_header_id p_pol_header.policy_header_id%TYPE
  ) RETURN p_pol_change_notice.policy_decline_date%TYPE IS
    /*Заполнение причины расторжения*/
    vr_t_decline_reason dml_t_decline_reason.tt_t_decline_reason; --Причина растржения
    vr_t_decline_type   dml_t_decline_type.tt_t_decline_type; --Тип причины
    vr_policy_header    dml_p_pol_header.tt_p_pol_header;
    vr_poilcy           dml_p_policy.tt_p_policy;
  
    v_policy_decline_date p_pol_change_notice.policy_decline_date%TYPE;
  
    /*Дата смерти застрахованного*/
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
  
    /*Дата смерти Страхователя*/
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
    /*В зависимости от причины расторжения: 
    • Если тип причины расторжения равен «Аннулирование», то дата заключения договора страхования;
    • Если причина расторжения равна «Смерть Застрахованного», то  значение поля «Дата смерти» Контакта Застрахованного;
    • Если причина расторжения равна «Смерть Страхователя», то значение поля «Дата смерти» Контакта Страхователя;
    • Если причина расторжения равна «Окончание выжидательного периода», то значение поля «Дата окончания выжидательного периода» активной версии ДС
    • Для всех остальных причин – ручной ввод
    */
    vr_t_decline_reason := dml_t_decline_reason.get_record(par_t_decline_reason_id => par_t_decline_reason);
    vr_t_decline_type   := dml_t_decline_type.get_record(par_t_decline_type_id => vr_t_decline_reason.t_decline_type_id);
    vr_policy_header    := dml_p_pol_header.get_record(par_policy_header_id);
  
    /*Тип причины - Аннулирование*/
    IF vr_t_decline_type.brief = 'Аннулирование'
    THEN
      v_policy_decline_date := vr_policy_header.start_date;
    ELSIF vr_t_decline_reason.brief = 'Смерть Застрахованного'
    THEN
      v_policy_decline_date := get_assured_death_date(par_policy_header_id);
    ELSIF vr_t_decline_reason.brief = 'Смерть Страхователя'
    THEN
      v_policy_decline_date := get_insurer_death_date(par_policy_header_id);
    ELSIF vr_t_decline_reason.brief = 'Окончание выж. периода'
    THEN
      vr_poilcy             := dml_p_policy.get_record(par_policy_id => vr_policy_header.policy_id);
      v_policy_decline_date := vr_poilcy.waiting_period_end_date;
    END IF;
  
    RETURN v_policy_decline_date;
  END get_policy_decline_date;

  /**
   * Проверка Расчетного счета
   * @author Черных М. 16.1.2015
   -- %param par_account_number  Расчетный счет для проверки
  */
  PROCEDURE check_account_number
  (
    par_account_number    VARCHAR2
   ,par_bank_id           NUMBER
   ,par_bank_name         VARCHAR2
   ,par_error_message_out OUT VARCHAR2
   ,par_is_raise_out      OUT NUMBER
  ) IS
    c_is_hkf            BOOLEAN := par_bank_name = 'ООО "ХКФ БАНК"';
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
        par_error_message_out := 'Количество символов должно быть равным 20';
        par_is_raise_out      := 1;
      ELSIF c_is_hkf
            AND par_account_number IS NULL
      THEN
        NULL;
      ELSE
        par_error_message_out := 'Количество символов должно быть равным 20';
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
            par_error_message_out := 'Введённое значение должно состоять только из цифр';
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
        par_error_message_out := 'Валюта счета - начиная с шестого три символа: возможны 810 или 643.';
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
               AND dacc.state_account = 'Активный'
               AND dacc.type_account = 1);
  
    IF v_is_account_exists = 0
    THEN
      IF c_is_hkf
         AND par_account_number IS NULL
      THEN
        NULL;
      ELSIF v_user_have_right = 0
      THEN
        par_error_message_out := 'Номер счета - начиная с первого пять символов: значения ' ||
                                 v_bank_account || ' нет в справочнике счетов.';
        par_is_raise_out      := 1;
      ELSE
        par_error_message_out := 'Номер счета - начиная с первого пять символов: значения ' ||
                                 v_bank_account || ' нет в справочнике счетов.';
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
        par_error_message_out := 'Контрольное число - начиная с девятого один символ: значение ' ||
                                 substr(par_account_number, 9, 1) || ' не является контрольным.';
        par_is_raise_out      := 1;
      ELSE
        par_error_message_out := 'Контрольное число - начиная с девятого один символ: значение ' ||
                                 substr(par_account_number, 9, 1) || ' не является контрольным.';
        par_is_raise_out      := 0;
      END IF;
    END IF;
  
  END check_account_number;

  /**
   * Проверка кредитной карты
   * @author Черных М. 16.1.2015
   -- %param par_account_number  Расчетный счет для проверки
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
      /*Проверяем кол-во цифр*/
      SELECT length(TRIM(translate(upper(par_card_number)
                                  ,'ABCDEFGHIJKLMNOPQRSTUVWXYZАБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЬЪЭЮЯ-=+,.!@#$%^&*()_\|/ '
                                  ,' ')))
        INTO p_len
        FROM dual;
    
      IF p_len < 4
         OR p_len > 19
      THEN
        par_error_message_out := 'Количество цифр в номере карты не может быть меньше 4 и больше 19';
        par_is_raise_out      := 1;
      END IF;
    
      SELECT nvl(length(TRIM(translate(upper(par_card_number), '1234567890X-', ' '))), 0)
        INTO p_corr
        FROM dual;
    
      IF p_corr > 0
         AND p_check_custom = 0
      THEN
        par_error_message_out := 'Наличие лишних знаков в номере карты';
        par_is_raise_out      := 1;
      END IF;
    
      /*Введенный номер карты*/
      SELECT translate(upper(par_card_number)
                      ,'ABCDEFGHIJKLMNOPQRSTUVWXYZАБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЬЪЭЮЯ-=+,.!@#$%^&*()_\|/ '
                      ,' ')
        INTO p_cur_corr
        FROM dual;
    
      /*Без ограничений (разделение номера карты по две цифры 12-22-23*/
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
        /*скрываем цифры, если нет прав*/
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

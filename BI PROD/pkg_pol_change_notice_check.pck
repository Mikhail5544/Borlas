CREATE OR REPLACE PACKAGE pkg_pol_change_notice_check IS

  -- Author  : Черных М.
  -- Created : 22.01.2015 
  -- Purpose : Процедуры проверки на переходах статусов заявления на изменение условий ДС

  /**
  * Проверка наличия другого заявления по данному ДС
  * @author Черных М. 22.1.2015
  * @param par_p_pol_change_notice_id - ИД заявления
  *
  */
  PROCEDURE check_notice_already_exists(par_p_pol_change_notice_id p_pol_change_notice.p_pol_change_notice_id%TYPE);

  /**
  * Проверка досрочного погашения кредита
  * @author Черных М. 22.1.2015
  * @param par_p_pol_change_notice_id - ИД заявления
  *
  */
  PROCEDURE check_early_payment(par_p_pol_change_notice_id p_pol_change_notice.p_pol_change_notice_id%TYPE);

  /**
  * Проверка оплаты
  * @author Черных М. 22.1.2015
  * @param par_p_pol_change_notice_id - ИД заявления
  */
  PROCEDURE check_not_payed(par_p_pol_change_notice_id p_pol_change_notice.p_pol_change_notice_id%TYPE);

  /**
    * Поиск владельца счета
    * @author  : Черных М.
    * @created : 19.02.2015
    -- %param par_account_nr  Рассчетный счет
  -- %param par_bank_name Наименование банка
  -- %param par_lic_code  Лицевой счет
  -- %param par_account_corr Корреспондентский счет
  */
  FUNCTION get_account_owner_contact
  (
    par_account_nr   cn_contact_bank_acc.account_nr%TYPE
   ,par_bank_name    cn_contact_bank_acc.bank_name%TYPE
   ,par_lic_code     cn_contact_bank_acc.lic_code%TYPE
   ,par_account_corr cn_contact_bank_acc.account_corr%TYPE
  ) RETURN cn_contact_bank_acc.id%TYPE;

  /**
  * Проверка заполения банковских реквизитов
  * @author Черных М. 22.1.2015
  * @param par_p_pol_change_notice_id - ИД заявления
  */
  PROCEDURE check_bank_requsite(par_p_pol_change_notice_id p_pol_change_notice.p_pol_change_notice_id%TYPE);

  /**
  * Проверка Банковский канал продаж
  * @author Черных М. 22.1.2015
  * @param par_p_pol_change_notice_id - ИД заявления
  */
  PROCEDURE check_sales_channel(par_p_pol_change_notice_id p_pol_change_notice.p_pol_change_notice_id%TYPE);

  /**
  * Проверка заполнения даты погашения кредита для досрочного погашения
  * @author Черных М. 22.1.2015
  * @param par_p_pol_change_notice_id - ИД заявления
  */
  PROCEDURE check_credit_repayment_date(par_p_pol_change_notice_id p_pol_change_notice.p_pol_change_notice_id%TYPE);

  /**
  * Установка записи в журнале вх.исх информации в статус "Обработан"
  * @author Черных М. 22.1.2015
  * @param par_p_pol_change_notice_id - ИД заявления
  */
  PROCEDURE set_inoutput_info_processed(par_p_pol_change_notice_id p_pol_change_notice.p_pol_change_notice_id%TYPE);

  /*
  * Контроль даты расторжения при аннулировании
  * Дата расторжения по причине с типом Анунлирование не может быть больше
  * даты начала действия договора
  * @param par_p_pol_change_notice_id - ИД Заявления на изменение условий  договора
  */
  PROCEDURE check_decline_date_annulate(par_p_pol_change_notice_id NUMBER);

END pkg_pol_change_notice_check;
/
CREATE OR REPLACE PACKAGE BODY pkg_pol_change_notice_check IS

  /*Конкатенация комментариев через запятую*/
  FUNCTION concat_note
  (
    par_src VARCHAR2
   ,par_new VARCHAR2
  ) RETURN VARCHAR2 IS
    v_result VARCHAR2(32767);
  BEGIN
    SELECT nvl2(par_src, par_src || ', ', NULL) || par_new INTO v_result FROM dual;
    RETURN v_result;
  END concat_note;
  /**
  * Проверка наличия другого заявления по данному ДС
  * @author Черных М. 22.1.2015
  * @param par_p_pol_change_notice_id - ИД заявления
  *
  */
  PROCEDURE check_notice_already_exists(par_p_pol_change_notice_id p_pol_change_notice.p_pol_change_notice_id%TYPE) IS
    vr_p_pol_change_notice      dml_p_pol_change_notice.tt_p_pol_change_notice;
    vr_t_pol_change_notice_type dml_t_pol_change_notice_type.tt_t_pol_change_notice_type;
    vr_inoutput_info            dml_inoutput_info.tt_inoutput_info;
    v_count                     NUMBER;
  BEGIN
    /*Если тип заявления равен «Заявление на расторжение», «Заявление на аннулирование», «Исключение Застрахованных», 
    «Исключение страхового покрытия» и для ДС, указанного в Заявлении, существует другое Заявление в статусе отличном от «Отменен»,
     то перевести текущее Заявление в статус «Отменен» 
    и в поле «Комментарий» указать значение: «Существует другое Заявление по ДС в статусе отличном от «Отменен». */
    vr_p_pol_change_notice      := dml_p_pol_change_notice.get_record(par_p_pol_change_notice_id => par_p_pol_change_notice_id);
    vr_inoutput_info            := dml_inoutput_info.get_record(par_inoutput_info_id => vr_p_pol_change_notice.inoutput_info_id);
    vr_t_pol_change_notice_type := dml_t_pol_change_notice_type.get_record(par_t_pol_chang_notice_type_id => vr_p_pol_change_notice.t_pol_change_notice_type_id);
  
    IF vr_t_pol_change_notice_type.brief IN
       ('BREAK_OFF', 'ANNULATE', 'ASSURED_EXCLUDE', 'COVER_EXCLUDE')
    THEN
      SELECT COUNT(*)
        INTO v_count
        FROM dual
       WHERE EXISTS (SELECT NULL
                FROM p_pol_change_notice p
               WHERE p.policy_header_id = vr_p_pol_change_notice.policy_header_id
                 AND p.p_pol_change_notice_id != vr_p_pol_change_notice.p_pol_change_notice_id /*Исключаем саму строку*/
                 AND doc.get_last_doc_status_brief(p.p_pol_change_notice_id) != 'CANCEL');
      IF v_count = 1
      THEN
        vr_inoutput_info.note := concat_note(vr_inoutput_info.note
                                            ,'Существует другое Заявление по ДС в статусе отличном от «Отменен»');
        dml_inoutput_info.update_record(par_record => vr_inoutput_info);
      
        doc.set_doc_status(par_p_pol_change_notice_id, 'CANCEL');
      END IF;
    END IF;
  END check_notice_already_exists;

  /**
  * Проверка досрочного погашения кредита
  * @author Черных М. 22.1.2015
  * @param par_p_pol_change_notice_id - ИД заявления
  *
  */
  PROCEDURE check_early_payment(par_p_pol_change_notice_id p_pol_change_notice.p_pol_change_notice_id%TYPE) IS
    vr_p_pol_change_notice dml_p_pol_change_notice.tt_p_pol_change_notice;
    vr_t_decline_reason    dml_t_decline_reason.tt_t_decline_reason;
  BEGIN
    /*Если причина расторжения равна «Досрочное погашение кредита» и значение поля «Дата погашения кредита» пустое, 
    то перевести Заявление в статус «Запрос документов».*/
    vr_p_pol_change_notice := dml_p_pol_change_notice.get_record(par_p_pol_change_notice_id => par_p_pol_change_notice_id);
    vr_t_decline_reason    := dml_t_decline_reason.get_record(par_t_decline_reason_id => vr_p_pol_change_notice.t_decline_reason_id);
  
    IF vr_t_decline_reason.brief = 'Досрочное погашение'
       AND vr_p_pol_change_notice.credit_repayment_date IS NULL
    THEN
      doc.set_doc_status(par_p_pol_change_notice_id, 'DOC_REQUEST');
    END IF;
  END check_early_payment;

  /**
  * Проверка оплаты
  * @author Черных М. 22.1.2015
  * @param par_p_pol_change_notice_id - ИД заявления
  */
  PROCEDURE check_not_payed(par_p_pol_change_notice_id p_pol_change_notice.p_pol_change_notice_id%TYPE) IS
    vr_p_pol_change_notice dml_p_pol_change_notice.tt_p_pol_change_notice;
    v_count                NUMBER;
    vr_inoutput_info       dml_inoutput_info.tt_inoutput_info;
  
  BEGIN
    vr_p_pol_change_notice := dml_p_pol_change_notice.get_record(par_p_pol_change_notice_id => par_p_pol_change_notice_id);
    vr_inoutput_info       := dml_inoutput_info.get_record(par_inoutput_info_id => vr_p_pol_change_notice.inoutput_info_id);
    --В статусе "Отменен" не проверяем
    IF doc.get_last_doc_status_brief(par_p_pol_change_notice_id) NOT IN ('CANCEL')
    THEN
      /*Если для ДС, указанного в Заявлении канал продаж равен «Банковский» и  
      существует ЭПГ в статусе «К оплате», то перевести Заявление в статус «Доработка», 
      указав при этом в поле «Комментарии» следующий текст «неоплачен»*/
      SELECT COUNT(*)
        INTO v_count
        FROM dual
       WHERE EXISTS (SELECT NULL
                FROM p_pol_header        pph
                    ,doc_doc             dd
                    ,p_pol_change_notice pn
                    ,t_sales_channel     ts
               WHERE pph.policy_id = dd.parent_id
                 AND pph.policy_header_id = pn.policy_header_id
                 AND doc.get_last_doc_status_brief(dd.child_id) = 'TO_PAY'
                 AND pn.p_pol_change_notice_id = par_p_pol_change_notice_id
                 AND pph.sales_channel_id = ts.id
                 AND ts.brief = 'BANK');
      IF v_count = 1
      THEN
        vr_inoutput_info.note := concat_note(vr_inoutput_info.note, 'Неоплачен');
        dml_inoutput_info.update_record(par_record => vr_inoutput_info);
      
        doc.set_doc_status(par_p_pol_change_notice_id, 'REVISION');
      END IF;
    END IF;
  END check_not_payed;

  /**
    * Поиск владельца счета
    * @author  : Черных М.
    * @created : 19.02.2015
    -- %param par_account_nr  Рассчетный счет
  -- %param par_bank_name Наименование банка
  -- %param par_lic_code  Лицевой счет
  -- %param par_account_corr Корреспондентский счет
  */
  FUNCTION get_account_owner_contact
  (
    par_account_nr   cn_contact_bank_acc.account_nr%TYPE
   ,par_bank_name    cn_contact_bank_acc.bank_name%TYPE
   ,par_lic_code     cn_contact_bank_acc.lic_code%TYPE
   ,par_account_corr cn_contact_bank_acc.account_corr%TYPE
  ) RETURN cn_contact_bank_acc.id%TYPE IS
    v_cn_contact_bank_acc_id cn_contact_bank_acc.id%TYPE;
  BEGIN
  
    SELECT bac.contact_id
      INTO v_cn_contact_bank_acc_id
      FROM cn_contact_bank_acc  bac
          ,cn_document_bank_acc dac
          ,contact              c
     WHERE bac.account_nr = par_account_nr
       AND bac.bank_name = par_bank_name
       AND nvl(bac.lic_code, 'X') = nvl(par_lic_code, 'X')
       AND nvl(bac.account_corr, 'X') = nvl(par_account_corr, 'X')
       AND bac.id = dac.cn_contact_bank_acc_id
       AND doc.get_doc_status_name(dac.cn_document_bank_acc_id) = 'Активный'
       AND nvl(bac.is_check_owner, 0) = 1
       AND bac.contact_id = c.contact_id;
  
    RETURN(v_cn_contact_bank_acc_id);
  EXCEPTION
    WHEN no_data_found
         OR too_many_rows THEN
      RETURN NULL;
  END get_account_owner_contact;

  /**
  * Проверка заполения банковских реквизитов
  * @author Черных М. 22.1.2015
  * @param par_p_pol_change_notice_id - ИД заявления
  */
  PROCEDURE check_bank_requsite(par_p_pol_change_notice_id p_pol_change_notice.p_pol_change_notice_id%TYPE) IS
    vr_p_pol_change_notice     dml_p_pol_change_notice.tt_p_pol_change_notice;
    v_cn_contact_bank_acc      cn_contact_bank_acc.id%TYPE;
    vr_policy_header           dml_p_pol_header.tt_p_pol_header;
    v_issuere_contact_id       contact.contact_id%TYPE;
    vr_bank_contact            dml_contact.tt_contact;
    v_account_owner_contact_id cn_contact_bank_acc.owner_contact_id%TYPE;
  
    PROCEDURE create_bank_requisite_doc
    (
      par_contact_id       cn_contact_bank_acc.contact_id%TYPE
     ,par_bank_id          cn_contact_bank_acc.bank_id%TYPE
     ,par_account_nr       cn_contact_bank_acc.account_nr%TYPE
     ,par_lic_code         cn_contact_bank_acc.lic_code%TYPE
     ,par_fund_id          cn_contact_bank_acc.bank_account_currency_id%TYPE
     ,par_card_number      cn_contact_bank_acc.account_corr%TYPE
     ,par_owner_contact_id cn_contact_bank_acc.owner_contact_id%TYPE
     ,par_is_check_owner   cn_contact_bank_acc.is_check_owner%TYPE
    ) IS
      sq_doc_id   NUMBER;
      p_cnt       NUMBER;
      v_bank_name contact.obj_name_orig%TYPE;
      v_bank_bik  cn_contact_ident.id_value%TYPE;
      v_bank_korr cn_contact_ident.id_value%TYPE;
    
      /*Получить атрибуты банка*/
      PROCEDURE get_bank_attr
      (
        par_bank_id       cn_contact_bank_acc.bank_id%TYPE
       ,par_bank_name_out OUT contact.obj_name_orig%TYPE
       ,par_bank_bik_out  OUT cn_contact_ident.id_value%TYPE
       ,par_bank_korr_out OUT cn_contact_ident.id_value%TYPE
        
      ) IS
      BEGIN
        SELECT c.obj_name_orig NAME
              ,(SELECT cci.id_value
                  FROM cn_contact_ident cci
                 WHERE cci.contact_id = c.contact_id
                   AND cci.table_id = pkg_contact.get_contact_document_id(c.contact_id, 'BIK')
                
                ) bik
              ,(SELECT cci.id_value
                  FROM cn_contact_ident cci
                 WHERE cci.contact_id = c.contact_id
                   AND cci.table_id = pkg_contact.get_contact_document_id(c.contact_id, 'KORR')
                
                ) korr
          INTO par_bank_name_out
              ,par_bank_bik_out
              ,par_bank_korr_out
          FROM contact        c
              ,t_contact_type ct
         WHERE c.contact_type_id = ct.id
           AND c.contact_id = par_bank_id
           AND EXISTS (SELECT NULL
                  FROM cn_contact_role v
                      ,t_contact_role  t
                 WHERE v.role_id = t.id
                   AND t.brief = 'BANK'
                   AND v.contact_id = c.contact_id);
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END get_bank_attr;
    
    BEGIN
    
      SELECT COUNT(*)
        INTO p_cnt
        FROM ven_cn_contact_bank_acc  bac
            ,ven_cn_document_bank_acc dac
            ,document                 d
       WHERE bac.contact_id = par_contact_id
         AND bac.bank_id = par_bank_id
         AND bac.account_nr = par_account_nr
         AND bac.lic_code = par_lic_code
         AND bac.id = dac.cn_contact_bank_acc_id
         AND dac.cn_document_bank_acc_id = d.document_id
         AND d.doc_status_ref_id IN
             (SELECT rf.doc_status_ref_id FROM doc_status_ref rf WHERE rf.name != 'Отменен');
    
      IF p_cnt = 0
      THEN
        /*Получить реквизиты банка*/
        get_bank_attr(par_bank_id       => par_bank_id
                     ,par_bank_name_out => v_bank_name
                     ,par_bank_bik_out  => v_bank_bik
                     ,par_bank_korr_out => v_bank_korr);
      
        SELECT sq_cn_contact_bank_acc.nextval INTO v_cn_contact_bank_acc FROM dual;
        INSERT INTO ven_cn_contact_bank_acc
          (id
          ,account_corr
          ,account_nr
          ,bank_account_currency_id
          ,bank_id
          ,bank_name
          ,bic_code
          ,contact_id
          ,lic_code
          ,owner_contact_id
          ,used_flag
          ,is_check_owner)
        VALUES
          (v_cn_contact_bank_acc
          ,par_card_number --Номер банковской карты
          ,par_account_nr
          ,par_fund_id
          ,par_bank_id
          ,v_bank_name
          ,v_bank_bik
          ,par_contact_id
          ,par_lic_code
          ,par_owner_contact_id
          ,1 /*Флаг использования*/
          ,par_is_check_owner /*Флаг - владелец счета*/);
      
        --Снимаем флаг использования у "старых" счетов контакта
        UPDATE cn_contact_bank_acc c
           SET c.used_flag = 0
         WHERE c.contact_id = par_contact_id
           AND c.id != v_cn_contact_bank_acc;
      
        SELECT sq_document.nextval INTO sq_doc_id FROM dual;
      
        INSERT INTO ven_cn_document_bank_acc
          (cn_document_bank_acc_id, cn_contact_bank_acc_id)
        VALUES
          (sq_doc_id, v_cn_contact_bank_acc);
      
        doc.set_doc_status(sq_doc_id, 'PROJECT');
        doc.set_doc_status(sq_doc_id, 'ACTIVE');
      END IF;
    END create_bank_requisite_doc;
  
  BEGIN
    vr_p_pol_change_notice := dml_p_pol_change_notice.get_record(par_p_pol_change_notice_id => par_p_pol_change_notice_id);
    vr_policy_header       := dml_p_pol_header.get_record(par_policy_header_id => vr_p_pol_change_notice.policy_header_id);
    v_issuere_contact_id   := pkg_policy.get_policy_contact(vr_policy_header.policy_id
                                                           ,'Страхователь');
  
    /*Если блок «Банковские реквизиты» заполнен, то создать новый документ  
    «Банковский счет Контакта» в статусе «Активный»*/
    FOR vr_row IN (SELECT p.bank_contact_id
                         ,p.account_nr
                         ,p.lic_code
                         ,p.fund_id
                         ,p.card_number
                         ,p.owner_contact_id
                     FROM p_decline_bank_requisite p
                    WHERE p.p_pol_change_notice_id = par_p_pol_change_notice_id)
    LOOP
    
      vr_bank_contact := dml_contact.get_record(par_contact_id => vr_row.bank_contact_id);
      /*Если нет владельца для данного номера счета*/
      v_account_owner_contact_id := get_account_owner_contact(par_account_nr   => vr_row.account_nr
                                                             ,par_bank_name    => vr_bank_contact.obj_name_orig
                                                             ,par_lic_code     => vr_row.lic_code
                                                             ,par_account_corr => NULL);
    
      /*Создать банковские реквизиты у контакта-владельца, если нет счета в БД*/
      IF v_account_owner_contact_id IS NULL
      THEN
        create_bank_requisite_doc(par_contact_id       => vr_row.owner_contact_id --Владелец счета 
                                 ,par_bank_id          => vr_row.bank_contact_id
                                 ,par_account_nr       => vr_row.account_nr
                                 ,par_lic_code         => vr_row.lic_code
                                 ,par_fund_id          => vr_row.fund_id
                                 ,par_card_number      => vr_row.card_number
                                 ,par_owner_contact_id => vr_row.owner_contact_id
                                 ,par_is_check_owner   => 1 /*Владелец счета*/);
      END IF;
    
      /*Если владелец счета и страхователь разные контакты, то создать реквизиты и у владельца*/
      IF v_issuere_contact_id != vr_row.owner_contact_id
      THEN
        create_bank_requisite_doc(par_contact_id       => v_issuere_contact_id --Страхователь
                                 ,par_bank_id          => vr_row.bank_contact_id
                                 ,par_account_nr       => vr_row.account_nr
                                 ,par_lic_code         => vr_row.lic_code
                                 ,par_fund_id          => vr_row.fund_id
                                 ,par_card_number      => vr_row.card_number
                                 ,par_owner_contact_id => vr_row.owner_contact_id
                                 ,par_is_check_owner   => 0 /*Не Владелец счета*/);
      END IF;
    END LOOP;
  
  END check_bank_requsite;

  /**
  * Проверка Банковский канал продаж
  * @author Черных М. 22.1.2015
  * @param par_p_pol_change_notice_id - ИД заявления
  */
  PROCEDURE check_sales_channel(par_p_pol_change_notice_id p_pol_change_notice.p_pol_change_notice_id%TYPE) IS
    v_count NUMBER;
  BEGIN
    /*Если для ДС, указанного в Заявлении канал продаж равен «Банковский», 
    то   отсутствует ЭПГ в статусе «К оплате».*/
    SELECT COUNT(*)
      INTO v_count
      FROM dual
     WHERE EXISTS (SELECT NULL
              FROM p_pol_header        pph
                  ,doc_doc             dd
                  ,p_pol_change_notice pn
                  ,t_sales_channel     ts
             WHERE pph.policy_id = dd.parent_id
               AND pph.policy_header_id = pn.policy_header_id
               AND doc.get_last_doc_status_brief(dd.child_id) = 'TO_PAY'
               AND pn.p_pol_change_notice_id = par_p_pol_change_notice_id
               AND pph.sales_channel_id = ts.id
               AND ts.brief = 'BANK');
    IF v_count = 1
    THEN
      ex.raise_custom('Имеется неоплаченный ЭПГ. Канал продаж "Банковский"');
    END IF;
  
  END check_sales_channel;

  /**
  * Проверка заполнения даты погашения кредита для досрочного погашения
  * @author Черных М. 22.1.2015
  * @param par_p_pol_change_notice_id - ИД заявления
  */
  PROCEDURE check_credit_repayment_date(par_p_pol_change_notice_id p_pol_change_notice.p_pol_change_notice_id%TYPE) IS
    vr_p_pol_change_notice dml_p_pol_change_notice.tt_p_pol_change_notice;
  BEGIN
    /*Если причина расторжения равна «Досрочное погашение кредита» и 
    значение поле «Дата погашения кредита» заполнено.*/
    vr_p_pol_change_notice := dml_p_pol_change_notice.get_record(par_p_pol_change_notice_id => par_p_pol_change_notice_id);
  
    IF dml_t_decline_reason.get_record(vr_p_pol_change_notice.t_decline_reason_id)
     .brief = 'Досрочное погашение'
        AND vr_p_pol_change_notice.credit_repayment_date IS NULL
    THEN
      ex.raise_custom('Не заполнена дата погашения кредита для причины расторжения "Досрочное погашение кредита"');
    END IF;
  END check_credit_repayment_date;

  /**
  * Установка записи в журнале вх.исх информации в статус "Обработан"
  * @author Черных М. 22.1.2015
  * @param par_p_pol_change_notice_id - ИД заявления
  */
  PROCEDURE set_inoutput_info_processed(par_p_pol_change_notice_id p_pol_change_notice.p_pol_change_notice_id%TYPE) IS
    vr_p_pol_change_notice dml_p_pol_change_notice.tt_p_pol_change_notice;
  BEGIN
    /*Если причина расторжения равна «Досрочное погашение кредита» и 
    значение поле «Дата погашения кредита» заполнено.*/
    vr_p_pol_change_notice := dml_p_pol_change_notice.get_record(par_p_pol_change_notice_id => par_p_pol_change_notice_id);
    UPDATE inoutput_info i
       SET i.t_message_state_id = dml_t_message_state.get_id_by_message_state_brief('PROCESSED') /*Обработан*/
     WHERE i.inoutput_info_id = vr_p_pol_change_notice.inoutput_info_id;
  
  END set_inoutput_info_processed;

  /*
  * Контроль даты расторжения при аннулировании
  * Дата расторжения по причине с типом Анунлирование не может быть больше
  * даты начала действия договора
  * @param par_p_pol_change_notice_id - ИД Заявления на изменение условий  договора
  */
  PROCEDURE check_decline_date_annulate(par_p_pol_change_notice_id NUMBER) IS
    vr_p_pol_change_notice  dml_p_pol_change_notice.tt_p_pol_change_notice;
    v_decline_type_brief    t_decline_type.brief%TYPE;
    v_pol_header_start_date DATE;
  BEGIN
    vr_p_pol_change_notice := dml_p_pol_change_notice.get_record(par_p_pol_change_notice_id => par_p_pol_change_notice_id);
  
    v_decline_type_brief := dml_t_decline_type.get_record(dml_t_decline_reason.get_record(vr_p_pol_change_notice.t_decline_reason_id).t_decline_type_id)
                            .brief;
  
    IF v_decline_type_brief = 'Аннулирование'
    THEN
      v_pol_header_start_date := dml_p_pol_header.get_record(vr_p_pol_change_notice.policy_header_id)
                                 .start_date;
    
      IF v_pol_header_start_date != vr_p_pol_change_notice.policy_decline_date
      THEN
        ex.raise_custom('При аннулировании дата расторжения должна быть равна дате начала действия договора');
      END IF;
    END IF;
  
  END check_decline_date_annulate;

END pkg_pol_change_notice_check;
/

CREATE OR REPLACE PACKAGE pkg_direct_writeoff IS

  -- Author  : Черных М.
  -- Created : 16.07.2014 
  -- Purpose : Процедуры по Прямому списанию

  /*Проверка на дубль заявления по ИДС*/
  PROCEDURE check_ids(par_dwo_notice_id dwo_notice.dwo_notice_id%TYPE);
  /*Проверка "Даты первого платежа по договору"*/
  PROCEDURE check_pol_first_pay_date(par_dwo_notice_id dwo_notice.dwo_notice_id%TYPE);
  /*Проверка "Статуса активной версии ДС"*/
  PROCEDURE check_pol_status(par_dwo_notice_id dwo_notice.dwo_notice_id%TYPE);
  /*Проверка "Брутто взнос"*/
  PROCEDURE check_notice_fee(par_dwo_notice_id dwo_notice.dwo_notice_id%TYPE);
  /*Проверка "Административные издержки"*/
  PROCEDURE check_admin_cost(par_dwo_notice_id dwo_notice.dwo_notice_id%TYPE);
  /*Проверка "Периодичность"*/
  PROCEDURE check_payment_term(par_dwo_notice_id dwo_notice.dwo_notice_id%TYPE);
  /*Проверка "Проверка срока действия карты"*/
  PROCEDURE check_card(par_dwo_notice_id dwo_notice.dwo_notice_id%TYPE);
  /*Проверка "Причина отказа"*/
  PROCEDURE check_rejection(par_dwo_notice_id dwo_notice.dwo_notice_id%TYPE);
  /*Проверка "Дата списания по заявлению"*/
  PROCEDURE check_notice_writeoff_date(par_dwo_notice_id dwo_notice.dwo_notice_id%TYPE);
  /*Проверка для заявления "Отказ от списания"*/
  PROCEDURE check_refusal(par_dwo_notice_id dwo_notice.dwo_notice_id%TYPE);
  /* Проверка на переходе Принято - отклонено */
  PROCEDURE check_double_writeoff(par_dwo_notice_id dwo_notice.dwo_notice_id%TYPE);
  /* Проверка на переходе ЭС в Обработано (завершает заявления при определенных результатах списания)
  02.09.2014*/
  PROCEDURE check_notice_quit(par_dwo_operation_id dwo_operation.dwo_operation_id%TYPE);
  /*Отмена завершения заявления по результатам списания (в случае отмены всего реестра "Результат списания")
  09.09.2014*/
  PROCEDURE cancel_notice_quit(par_dwo_operation_id dwo_operation.dwo_operation_id%TYPE);
  /*
  Создание операции по ПС
  17.07.2014
  */
  PROCEDURE create_operations
  (
    par_registry_id   dwo_oper_registry.dwo_oper_registry_id%TYPE
   ,par_writeoff_date DATE
  );

  /*
  Создание графика списаний
  17.07.2014
  */
  PROCEDURE create_schedule(par_dwo_notice_id dwo_notice.dwo_notice_id%TYPE);
  /*Создание реестра на списание*/
  PROCEDURE create_registry
  (
    par_start_date DATE
   ,par_end_date   DATE
  );

  /*Удаление реестра и всех его операций*/
  PROCEDURE delete_registry(par_dwo_oper_registry dwo_oper_registry.dwo_oper_registry_id%TYPE);
  /*Удаление заявления*/
  PROCEDURE delete_notice(par_dwo_notice_id dwo_notice.dwo_notice_id%TYPE);
  /*Формирование CSV на списание*/
  PROCEDURE create_registry_file
  (
    par_registry_id dwo_oper_registry.dwo_oper_registry_id%TYPE
   ,par_file_path   VARCHAR2
   ,par_is_revision BOOLEAN := FALSE /*Реестр операций "Доработка. Нет результата"*/
   ,par_csv         IN OUT CLOB
  );

  /*Формирование файла CSV, с операциями в статуса "Доработка. Нет результата"*/
  FUNCTION create_csv_revision_no_result RETURN CLOB;
  /*
  Обработать операции в реестре "Результат списания"
  29.07.2014
  */
  PROCEDURE process_registry_result(par_dwo_oper_registry_id dwo_oper_registry.dwo_oper_registry_id%TYPE);
  /*
  Отмена реестра на списание
  @author Черных М.
  @param par_dwo_oper_registry_id ИД реестра на списание
  */
  PROCEDURE cancel_registry_result(par_dwo_oper_registry_id dwo_oper_registry.dwo_oper_registry_id%TYPE);
  /*Последний день действия карты*/
  FUNCTION get_card_last_day
  (
    par_card_month VARCHAR2
   ,par_card_year  VARCHAR2
  ) RETURN DATE;
  /*Преобразование CLOB в BLOB*/
  FUNCTION get_blob(par_clob CLOB) RETURN BLOB;

  /*Получить ИД исходного заявления по ИД операции результата*/
  FUNCTION get_notice_by_res_operation_id(par_result_operation_id dwo_operation.dwo_operation_id%TYPE)
    RETURN dwo_notice.dwo_notice_id%TYPE;
  /*Получить ИД операции "На списание" по операции "Результат"*/
  FUNCTION get_writeoff_oper_by_res_oper(par_result_operation_id dwo_operation.dwo_operation_id%TYPE)
    RETURN dwo_operation.dwo_operation_id%TYPE;

  /*Привязка результата списания к исходной операции при ручном переводе статуса из
  "Доработка. Нет операции" в "Обработано"*/
  PROCEDURE attach_result(par_result_operation_id dwo_operation.dwo_operation_id%TYPE);

  /*Загрузка файла "Реестр результатов списания"*/
  PROCEDURE load_registry_result
  (
    par_file_id   temp_load_blob.session_id%TYPE
   ,par_file_path dwo_oper_registry.file_path%TYPE
  );
  /*
  Загрузка платежей по прямому списанию
  02.09.2014
  */
  PROCEDURE load_payment
  (
    par_writeoff_date dwo_operation.writeoff_datetime%TYPE
   ,par_ac_payment_id ac_payment.payment_id%TYPE
  );

  /*Пролонгация заявления на прямое списание 03.09.2014 Черных М.*/
  PROCEDURE prolongate_notice(par_payment_register_item_id payment_register_item.payment_register_item_id%TYPE);

  -- Author  : Гаргонов Д.А.
  -- Created : 21.10.2014
  -- Purpose : 368935: Прямое списание
  -- Comment : Процедура завершения задания на списание по расторгнутым/прекращенным договорам.
  --           Запускается джобом.
  PROCEDURE stop_writeoff;

  -- Author  : Гаргонов Д.А.
  -- Created : 21.10.2014
  -- Purpose : 368935: Прямое списание
  -- Comment : Процедура удаления графиков списания.
  PROCEDURE delete_dwo_schedule(par_dwo_notice_id ins.dwo_notice.dwo_notice_id%TYPE);

  -- Author  : Григорьев Ю.А.
  -- Created : 12.02.2015
  -- Purpose : 396379: 1910069084 Прямое списание
  -- Comment : Процедура установления запрета на переход статуса Заявления на отказ из Принято в Прекращен.

  PROCEDURE cancel_notice_deny_change_stat(par_dwo_notice_id ins.dwo_notice.dwo_notice_id%TYPE);

  /**
  * Содержит ли период даты списания
  * @author  : Черных М. 03.04.2015
  * @param par_start_date  Дата начала перида
  * @param par_end_date  Дата конца периода
  */
  FUNCTION is_exists_writeoff_date
  (
    par_start_date DATE
   ,par_end_date   DATE
  ) RETURN BOOLEAN;

  /**
  * Получить номер статуса Графика списания 
  * @author   Черных М. 03.04.2015
  * @par_dwo_schedule_id  ИД графика списания
  * @return 1-Списано, 2-Не списано, 3-Новый, 4-На списаниии
   */
  FUNCTION schedule_status_code(par_dwo_schedule_id dwo_schedule.dwo_schedule_id%TYPE) RETURN NUMBER;

  /**
  * Получить название статуса Графика списания 
  * @author   Черных М. 03.04.2015
  * @par_dwo_schedule_id  ИД графика списания
  * @return 1-Списано, 2-Не списано, 3-Новый, 4-На списании
   */
  FUNCTION schedule_status_name(par_dwo_schedule_id dwo_schedule.dwo_schedule_id%TYPE) RETURN VARCHAR2;

END pkg_direct_writeoff;
/
CREATE OR REPLACE PACKAGE BODY pkg_direct_writeoff IS

  -- Author  : Черных М.
  -- Created : 16.07.2014 
  -- Purpose : Процедуры по Прямому списанию

  gc_refuse  CONSTANT VARCHAR2(30) := 'Отказ'; --Результат списания - ОТКАЗ
  gc_success CONSTANT VARCHAR2(30) := 'Успешно'; --Результат списания - УСПЕШНО

  /*Проверка на дубль заявления по ИДС*/
  PROCEDURE check_ids(par_dwo_notice_id dwo_notice.dwo_notice_id%TYPE) IS
    vr_dn        dml_dwo_notice.tt_dwo_notice;
    v_error_flag NUMBER;
  BEGIN
    vr_dn := dml_dwo_notice.get_record(par_dwo_notice_id => par_dwo_notice_id);
  
    SELECT COUNT(1)
      INTO v_error_flag
      FROM dual
     WHERE EXISTS (SELECT NULL
              FROM ven_dwo_notice dn
                  ,doc_status_ref dsr
             WHERE dn.ids = vr_dn.ids
               AND dn.doc_status_ref_id = dsr.doc_status_ref_id
               AND dsr.brief = 'RECEIVED'
               AND dn.dwo_notice_id != vr_dn.dwo_notice_id /*Исключаем саму себя, т.к. сначала переходит статус*/
               AND dn.notice_type_id = vr_dn.notice_type_id
               AND dn.notice_type_id != 3 /*Заявление на отказ*/
            );
    IF v_error_flag = 1
    THEN
      ex.raise('Существует заявление в статусе "Принято" с ИД договора = ' || vr_dn.ids);
    END IF;
  
  END check_ids;

  /*Проверка "Даты первого платежа по договору"*/
  PROCEDURE check_pol_first_pay_date(par_dwo_notice_id dwo_notice.dwo_notice_id%TYPE) IS
    vr_dn            dml_dwo_notice.tt_dwo_notice;
    v_first_pay_date DATE;
  BEGIN
    vr_dn := dml_dwo_notice.get_record(par_dwo_notice_id => par_dwo_notice_id);
  
    SELECT pp.first_pay_date
      INTO v_first_pay_date
      FROM p_policy     pp
          ,p_pol_header pph
     WHERE pp.policy_id = pph.policy_id /*Активная версия*/
       AND pph.policy_header_id = vr_dn.policy_header_id;
    IF v_first_pay_date != vr_dn.pol_first_pay_date
    THEN
      ex.raise('Дата 1-го платежа в заявлении ' || to_char(vr_dn.pol_first_pay_date, 'dd.mm.rrrr') ||
               ' не совпадает с Договором ' || to_char(v_first_pay_date, 'dd.mm.rrrr'));
    END IF;
  
  END check_pol_first_pay_date;

  /*Проверка "Статуса активной версии ДС"*/
  PROCEDURE check_pol_status(par_dwo_notice_id dwo_notice.dwo_notice_id%TYPE) IS
    vr_dn        dml_dwo_notice.tt_dwo_notice;
    v_error_flag NUMBER;
  BEGIN
    vr_dn := dml_dwo_notice.get_record(par_dwo_notice_id => par_dwo_notice_id);
  
    SELECT COUNT(1)
      INTO v_error_flag
      FROM dual
     WHERE EXISTS (SELECT NULL
              FROM ven_p_policy   pp
                  ,p_pol_header   pph
                  ,doc_status_ref dsr
             WHERE pp.policy_id = pph.policy_id /*Активная версия*/
               AND pph.policy_header_id = vr_dn.policy_header_id
               AND pp.doc_status_ref_id = dsr.doc_status_ref_id
               AND dsr.brief IN ('RECOVER'
                                ,'READY_TO_CANCEL'
                                ,'TO_QUIT'
                                ,'TO_QUIT_CHECK_READY'
                                ,'TO_QUIT_CHECKED'
                                ,'CANCEL'
                                ,'QUIT'
                                ,'QUIT_REQ_QUERY'
                                ,'QUIT_REQ_GET'
                                ,'QUIT_TO_PAY'
                                ,'STOP'
                                ,'PROJECT'
                                ,'STOPED'
                                ,'BREAK'));
    IF v_error_flag = 1
    THEN
      ex.raise('Договор страховаия не действует');
    END IF;
  END;

  /*Проверка "Брутто взнос"*/
  PROCEDURE check_notice_fee(par_dwo_notice_id dwo_notice.dwo_notice_id%TYPE) IS
    vr_dn          dml_dwo_notice.tt_dwo_notice;
    vr_notice_type dml_t_dwo_notice_type.tt_t_dwo_notice_type;
    vr_pph         dml_p_pol_header.tt_p_pol_header;
    v_policy_fee   p_cover.fee%TYPE;
  BEGIN
    vr_dn          := dml_dwo_notice.get_record(par_dwo_notice_id => par_dwo_notice_id);
    vr_notice_type := dml_t_dwo_notice_type.get_record(par_t_dwo_notice_type_id => vr_dn.notice_type_id);
    vr_pph         := dml_p_pol_header.get_record(par_policy_header_id => vr_dn.policy_header_id);
    v_policy_fee   := pkg_policy.get_policy_fee(par_policy_id => vr_pph.policy_id);
    IF vr_dn.notice_fee != v_policy_fee
       AND vr_notice_type.brief = 'WRITEOFF' /*Проверка только для типа 'Списание'*/
    THEN
      ex.raise('Ошибка в поле размер страхового взноса. Размер страхового взноса (без админ. издержек) в договоре = ' ||
               v_policy_fee);
    END IF;
  END check_notice_fee;

  /*Проверка "Административные издержки"*/
  PROCEDURE check_admin_cost(par_dwo_notice_id dwo_notice.dwo_notice_id%TYPE) IS
    vr_dn          dml_dwo_notice.tt_dwo_notice;
    vr_notice_type dml_t_dwo_notice_type.tt_t_dwo_notice_type;
    vr_pph         dml_p_pol_header.tt_p_pol_header;
  BEGIN
    vr_dn          := dml_dwo_notice.get_record(par_dwo_notice_id => par_dwo_notice_id);
    vr_notice_type := dml_t_dwo_notice_type.get_record(par_t_dwo_notice_type_id => vr_dn.notice_type_id);
  
    /*Для типа заявления 'Доп. списание' проверка не нужна*/
    IF vr_notice_type.brief = 'EXTRA_WRITEOFF'
    THEN
      RETURN;
    END IF;
  
    vr_pph := dml_p_pol_header.get_record(par_policy_header_id => vr_dn.policy_header_id);
  
    IF pkg_policy.get_admin_cost_fee(p_pol_id => vr_pph.policy_id) = 0
       AND vr_dn.admin_costs != 0
    THEN
      ex.raise('В договоре административные издержки не найдены');
    END IF;
  
    IF vr_dn.admin_costs != pkg_policy.get_admin_cost_sum(p_pol_id => vr_pph.policy_id)
    THEN
      ex.raise('В договоре размер административных издержек - другой, Обратитесь к руководителю!');
    END IF;
  END check_admin_cost;

  /*Проверка "Периодичность"*/
  PROCEDURE check_payment_term(par_dwo_notice_id dwo_notice.dwo_notice_id%TYPE) IS
    vr_dn  dml_dwo_notice.tt_dwo_notice;
    vr_pph dml_p_pol_header.tt_p_pol_header;
    vr_pp  dml_p_policy.tt_p_policy;
  BEGIN
    vr_dn  := dml_dwo_notice.get_record(par_dwo_notice_id => par_dwo_notice_id);
    vr_pph := dml_p_pol_header.get_record(par_policy_header_id => vr_dn.policy_header_id);
    vr_pp  := dml_p_policy.get_record(par_policy_id => vr_pph.policy_id);
  
    IF vr_dn.payment_term_id != vr_pp.payment_term_id
    THEN
      ex.raise('Периодичность не совпадает с Договором');
    END IF;
  END check_payment_term;

  /*Проверка "Проверка срока действия карты"*/
  PROCEDURE check_card(par_dwo_notice_id dwo_notice.dwo_notice_id%TYPE) IS
    vr_dn dml_dwo_notice.tt_dwo_notice;
  BEGIN
    vr_dn := dml_dwo_notice.get_record(par_dwo_notice_id => par_dwo_notice_id);
    IF get_card_last_day(vr_dn.card_month, vr_dn.card_year) < SYSDATE
    THEN
      ex.raise('Срок действия карты меньше текущей даты');
    END IF;
  END;

  /*Проверка "Причина отказа"*/
  PROCEDURE check_rejection(par_dwo_notice_id dwo_notice.dwo_notice_id%TYPE) IS
    vr_dn dml_dwo_notice.tt_dwo_notice;
  BEGIN
    vr_dn := dml_dwo_notice.get_record(par_dwo_notice_id => par_dwo_notice_id);
    IF vr_dn.rejection_reason_id IS NULL
    THEN
      ex.raise('Поле "Причина отказа" должно быть заполнено');
    END IF;
  END;

  /*Проверка "Дата списания по заявлению"*/
  PROCEDURE check_notice_writeoff_date(par_dwo_notice_id dwo_notice.dwo_notice_id%TYPE) IS
    vr_dn          dml_dwo_notice.tt_dwo_notice;
    vr_period_info pkg_period.t_period_info;
  BEGIN
    vr_dn          := dml_dwo_notice.get_record(par_dwo_notice_id => par_dwo_notice_id);
    vr_period_info := pkg_period.get_period_info(par_period_id => vr_dn.pol_privilege_period_id);
  
    IF vr_dn.notice_writeoff_date >
       pkg_period.add_period(par_value             => vr_period_info.period.period_value
                            ,par_period_type_brief => vr_period_info.period_type.brief
                            ,par_date              => vr_dn.first_writeoff_date)
    THEN
      ex.raise('Дата списания по заявлению не должна превышать дату первого списания в счет уплаты взносов влючая льготный период');
    END IF;
  END;

  /*Проверка для заявления "Отказ от списания"*/
  PROCEDURE check_refusal(par_dwo_notice_id dwo_notice.dwo_notice_id%TYPE) IS
    vr_dn          dml_dwo_notice.tt_dwo_notice;
    vr_notice_type dml_t_dwo_notice_type.tt_t_dwo_notice_type;
    v_notice_id    dwo_notice.dwo_notice_id%TYPE;
  BEGIN
    vr_dn          := dml_dwo_notice.get_record(par_dwo_notice_id => par_dwo_notice_id);
    vr_notice_type := dml_t_dwo_notice_type.get_record(par_t_dwo_notice_type_id => vr_dn.notice_type_id);
  
    IF vr_notice_type.brief = 'REFUSAL'
    THEN
      BEGIN
        SELECT dn.dwo_notice_id
          INTO v_notice_id
          FROM dwo_notice        dn
              ,document          dc
              ,doc_status_ref    dsr
              ,t_dwo_notice_type nt
         WHERE dn.ids = vr_dn.ids
           AND dn.dwo_notice_id = dc.document_id
           AND dc.doc_status_ref_id = dsr.doc_status_ref_id
           AND dsr.brief IN ('RECEIVED', 'REFINE_DETAILS')
           AND dn.notice_type_id = nt.t_dwo_notice_type_id
           AND nt.brief IN ('WRITEOFF');
        /*В заявлении "на отказ" ставим ссылку на "заявление на списание"*/
        UPDATE dwo_notice dn
           SET dn.dwo_notice_parent_id = v_notice_id
         WHERE dn.dwo_notice_id = par_dwo_notice_id;
        /*В заявлении "на списание"*/
        UPDATE dwo_notice dn
           SET dn.rejection_reason_id = 7 /*Заявление клиента*/
         WHERE dn.dwo_notice_id = v_notice_id;
        doc.set_doc_status(v_notice_id, 'STOPED' /*Завершено*/);
      EXCEPTION
        WHEN no_data_found THEN
          /*Если исходное заявление на списание не нашли, то отклоняем "заявление на отказ"*/
          UPDATE dwo_notice dn
             SET dn.rejection_reason_id = 15 /*Нет действующего заявления*/
           WHERE dn.dwo_notice_id = par_dwo_notice_id;
          doc.set_doc_status(par_dwo_notice_id, 'DECLINED');
        WHEN too_many_rows THEN
          ex.raise('Найдено несколько заявлений по ИДС = ' || vr_dn.ids);
      END;
    END IF;
  END check_refusal;

  /* Проверка на переходе Принято - отклонено */
  PROCEDURE check_double_writeoff(par_dwo_notice_id dwo_notice.dwo_notice_id%TYPE) IS
    vr_dwo_notice  dml_dwo_notice.tt_dwo_notice;
    vr_notice_type dml_t_dwo_notice_type.tt_t_dwo_notice_type;
    -- Есть ли подтвержденное списание через mPOS
    FUNCTION is_exists_mpos(par_pol_header_id p_pol_header.policy_header_id%TYPE) RETURN BOOLEAN IS
      v_exists NUMBER(1);
    BEGIN
      SELECT COUNT(*)
        INTO v_exists
        FROM dual
       WHERE EXISTS (SELECT NULL
                FROM mpos_writeoff_form wf
                    ,document           dc
                    ,doc_status_ref     dsr
               WHERE wf.policy_header_id = par_pol_header_id
                 AND wf.mpos_writeoff_form_id = dc.document_id
                 AND dc.doc_status_ref_id = dsr.doc_status_ref_id
                 AND dsr.brief = 'CONFIRMED');
      RETURN v_exists = 1;
    END is_exists_mpos;
  
    -- Есть ли подтвержденное списание через эквайринг
    FUNCTION is_exists_acquiring(par_pol_header_id p_pol_header.policy_header_id%TYPE) RETURN BOOLEAN IS
      v_exists NUMBER(1);
    BEGIN
      SELECT COUNT(*)
        INTO v_exists
        FROM dual
       WHERE EXISTS (SELECT NULL
                FROM acq_payment_template pt
                    ,document             dc
                    ,doc_status_ref       dsr
               WHERE pt.policy_header_id = par_pol_header_id
                 AND pt.acq_payment_template_id = dc.document_id
                 AND dc.doc_status_ref_id = dsr.doc_status_ref_id
                 AND dsr.brief = 'CONFIRMED');
      RETURN v_exists = 1;
    END is_exists_acquiring;
  BEGIN
    vr_dwo_notice  := dml_dwo_notice.get_record(par_dwo_notice_id => par_dwo_notice_id);
    vr_notice_type := dml_t_dwo_notice_type.get_record(par_t_dwo_notice_type_id => vr_dwo_notice.notice_type_id);
    IF vr_notice_type.brief != 'REFUSAL'
    THEN
      -- Проверка, есть ли действующее списание через mPOS или эквайринг
      IF is_exists_mpos(par_pol_header_id => vr_dwo_notice.policy_header_id)
         OR is_exists_acquiring(vr_dwo_notice.policy_header_id)
      THEN
        -- Если есть, ставим причину отказа - двойное списание
        vr_dwo_notice.rejection_reason_id := pkg_t_mpos_rejection_dml.get_id_by_brief('DOUBLE_WRITEOFF');
        dml_dwo_notice.update_record(vr_dwo_notice);
      ELSE
        -- Иначе возврат ошибки
        ex.raise('Двойного списания нет, перевод статуса невозможен');
      END IF;
    END IF;
  END check_double_writeoff;

  /* Проверка на переходе ЭС в Обработано (завершает заявления при определенных результатах списания)
  02.09.2014*/
  PROCEDURE check_notice_quit(par_dwo_operation_id dwo_operation.dwo_operation_id%TYPE) IS
    vr_operation              dml_dwo_operation.tt_dwo_operation;
    vr_notice                 dml_dwo_notice.tt_dwo_notice;
    vr_direct_writeoff_result dml_t_direct_writeoff_result.tt_t_direct_writeoff_result; --Справочник результатов списания
  
  BEGIN
    vr_operation := dml_dwo_operation.get_record(par_dwo_operation_id => par_dwo_operation_id);
  
    /*В случае отказа - нужно завершать заявление*/
    IF vr_operation.writeoff_result = gc_refuse
    THEN
      --Справочник результатов списания
      vr_direct_writeoff_result := dml_t_direct_writeoff_result.get_record(par_t_direct_writeof_result_id => vr_operation.t_direct_writeoff_result_id);
    
      /*Завершаем заявление, если признак у результата - прекращать заявление*/
      IF vr_direct_writeoff_result.stop_writeoff_flag = 1
      THEN
        --Заявление в статусе "Принято" завершаем
        vr_notice := dml_dwo_notice.get_record(get_notice_by_res_operation_id(par_dwo_operation_id));
      
        IF vr_notice.doc_status_ref_id = dml_doc_status_ref.get_id_by_brief('RECEIVED') /*Принято*/
        THEN
          doc.set_doc_status(vr_notice.dwo_notice_id, 'STOPED');
          --Проставляем причину отказа
          UPDATE dwo_notice dn
             SET dn.rejection_reason_id = dml_t_mpos_rejection.get_id_by_brief('BANK_REJECTION') /*Отказ Банка*/
           WHERE dn.dwo_notice_id = vr_notice.dwo_notice_id;
        END IF;
      
      END IF; --Конец если прекращать списание
    END IF; --Конец если "Отказ"
  
  END check_notice_quit;

  /*Отмена завершения заявления по результатам списания (в случае отмены всего реестра "Результат списания")
  @param par_dwo_operation_id ИД операции результата
  09.09.2014*/
  PROCEDURE cancel_notice_quit(par_dwo_operation_id dwo_operation.dwo_operation_id%TYPE) IS
    vr_operation              dml_dwo_operation.tt_dwo_operation;
    vr_notice                 dml_dwo_notice.tt_dwo_notice;
    vr_direct_writeoff_result dml_t_direct_writeoff_result.tt_t_direct_writeoff_result; --Справочник результатов списания
  BEGIN
    vr_operation := dml_dwo_operation.get_record(par_dwo_operation_id => par_dwo_operation_id);
  
    /*В случае отказа - нужно завершать заявление*/
    IF vr_operation.writeoff_result = gc_refuse
    THEN
      --Справочник результатов списания
      vr_direct_writeoff_result := dml_t_direct_writeoff_result.get_record(par_t_direct_writeof_result_id => vr_operation.t_direct_writeoff_result_id);
    
      IF vr_direct_writeoff_result.stop_writeoff_flag = 1
      THEN
        --Заявление в статусе "Завершено", то возобновляем
        vr_notice := dml_dwo_notice.get_record(get_notice_by_res_operation_id(par_dwo_operation_id));
      
        IF vr_notice.doc_status_ref_id = -1 /*Завершено*/
        THEN
          doc.set_doc_status(vr_notice.dwo_notice_id, 'RECEIVED');
          --Проставляем причину отказа
          UPDATE dwo_notice dn
             SET dn.rejection_reason_id = NULL
           WHERE dn.dwo_notice_id = vr_notice.dwo_notice_id;
        END IF;
      
      END IF; --Конец если описание результата в списке
    END IF; --Конец если "Отказ"
  END cancel_notice_quit;

  /*
  Создание операции по ПС
  17.07.2014
  */
  /*Создание операций для реестра на списание*/
  PROCEDURE create_operations
  (
    par_registry_id   dwo_oper_registry.dwo_oper_registry_id%TYPE
   ,par_writeoff_date DATE
  ) IS
    v_doc_templ_id doc_templ.doc_templ_id%TYPE;
    v_operation_id dwo_operation.dwo_operation_id%TYPE;
    v_oper_register_date dwo_oper_registry.creation_date%TYPE;
  
    /*Проверка, что данные в ДС не поменялись относительно Заявления*/
    FUNCTION check_permanence(par_notice_id dwo_notice.dwo_notice_id%TYPE) RETURN BOOLEAN IS
      v_is_permanent NUMBER(1);
    BEGIN
      SELECT COUNT(*)
        INTO v_is_permanent
        FROM dual
       WHERE EXISTS (SELECT NULL
                FROM dwo_notice   dn
                    ,p_policy     pp
                    ,p_pol_header ph
                    ,t_product    tp
               WHERE ph.policy_header_id = dn.policy_header_id
                 AND ph.last_ver_id = pp.policy_id
                 AND dn.dwo_notice_id = par_notice_id
                 AND ph.product_id = tp.product_id
                    -- Проверка соответствия ключевых значений
                 AND dn.pol_first_pay_date = pp.first_pay_date
                 AND dn.payment_term_id = pp.payment_term_id
                 AND dn.pol_privilege_period_id = pp.pol_privilege_period_id
                 AND dn.product_name = tp.public_description
                 AND dn.plan_end_date =
                     least(pp.end_date, get_card_last_day(dn.card_month, dn.card_year)));
      RETURN v_is_permanent = 1;
    END check_permanence;
  
    /*
    Добавляем в Комментарий к заявлению информацию о том, что поменялось относительно 
    текущего состояния ДС
    */
    PROCEDURE add_note_about_difference(par_notice_id dwo_notice.dwo_notice_id%TYPE) IS
      v_difference_text document.note%TYPE;
      v_equal           NUMBER := 0;
    BEGIN
      FOR vr IN (SELECT dn.pol_first_pay_date notice_first_pay_date
                       ,pp.first_pay_date policy_first_pay_date
                       ,dn.payment_term_id notice_payment_term_id
                       ,pp.payment_term_id policy_payment_term_id
                       ,dn.pol_privilege_period_id notice_privilege_period_id
                       ,pp.pol_privilege_period_id policy_privilege_period_id
                       ,dn.product_name notice_product_name
                       ,tp.public_description policy_product_name
                       ,dn.plan_end_date notice_plan_end_date
                       ,get_card_last_day(dn.card_month, dn.card_year) policy_plan_end_date
                       ,dn.dwo_notice_id
                   FROM dwo_notice   dn
                       ,p_policy     pp
                       ,p_pol_header ph
                       ,t_product    tp
                  WHERE ph.policy_header_id = dn.policy_header_id
                    AND ph.last_ver_id = pp.policy_id
                    AND dn.dwo_notice_id = par_notice_id
                    AND ph.product_id = tp.product_id)
      LOOP
        SELECT decode(vr.notice_plan_end_date, vr.policy_plan_end_date, 1, 0) INTO v_equal FROM dual;
        IF v_equal = 0
        THEN
          v_difference_text := v_difference_text ||
                               'Отличие в "Плановой дате окончания". В заявлении:' ||
                               to_char(vr.notice_plan_end_date, 'dd.mm.rrrr hh24:mi:ss') || ', в ДС: ' ||
                               to_char(vr.policy_plan_end_date, 'dd.mm.rrrr hh24:mi:ss');
        END IF;
      
        SELECT decode(vr.notice_product_name, vr.policy_product_name, 1, 0) INTO v_equal FROM dual;
        IF v_equal = 0
        THEN
          v_difference_text := v_difference_text || 'Отличие в "Наименовании продукта". В заявлении:' ||
                               vr.notice_product_name || ', в ДС: ' || vr.policy_product_name;
        END IF;
      
        SELECT decode(vr.notice_privilege_period_id, vr.policy_privilege_period_id, 1, 0)
          INTO v_equal
          FROM dual;
        IF v_equal = 0
        THEN
          v_difference_text := v_difference_text || 'Отличие в "Льготном периоде"';
        END IF;
      
        SELECT decode(vr.notice_payment_term_id, vr.policy_payment_term_id, 1, 0)
          INTO v_equal
          FROM dual;
        IF v_equal = 0
        THEN
          v_difference_text := v_difference_text ||
                               'Отличие в "Периодичности страхового взноса". В заявлении: ' ||
                               ent.obj_name('T_PAYMENT_TERMS', vr.notice_payment_term_id) ||
                               ', в ДС: ' ||
                               ent.obj_name('T_PAYMENT_TERMS', vr.policy_payment_term_id);
        END IF;
      
        SELECT decode(vr.notice_first_pay_date, vr.policy_first_pay_date, 1, 0)
          INTO v_equal
          FROM dual;
        IF v_equal = 0
        THEN
          v_difference_text := v_difference_text ||
                               'Отличие в "Дате первого платежа по ДС". В заявлении: ' ||
                               to_char(vr.notice_first_pay_date, 'dd.mm.rrrr hh24:mi:ss') ||
                               ', в ДС: ' ||
                               to_char(vr.policy_first_pay_date, 'dd.mm.rrrr hh24:mi:ss');
        END IF;
      
        UPDATE document dn
           SET dn.note = dn.note || v_difference_text
         WHERE dn.document_id = vr.dwo_notice_id;
      END LOOP;
    END add_note_about_difference;
  BEGIN
  
    v_doc_templ_id := doc.templ_id_by_brief('DWO_OPERATION');
  
      SELECT dor.creation_date
        INTO v_oper_register_date
        FROM dwo_oper_registry dor
       WHERE dor.dwo_oper_registry_id = par_registry_id;

  
    FOR vr_notice IN (SELECT dn.dwo_notice_id
                            ,dn.insured_id
                            ,dn.product_name
                            ,dn.ids
                            ,f.brief pay_fund_brief
                            ,dn.cell_phone
                            ,dn.region_name
                            ,dn.region_id
                            ,dn.insured_fio
                            ,dn.card_type_id
                            ,ph.policy_header_id
                            ,co.obj_name_orig AS agent_name
                            ,sc.notice_fee
                            ,dn.pay_fund_id
                            ,dn.payer_fio
                            ,dn.payer_id
                            ,dn.notice_writeoff_date
                            ,sc.dwo_schedule_id
                            ,sc.date_end AS schedule_end
                            ,doc.get_doc_status_id(ph.last_ver_id) AS last_ver_status_id
                            ,sc.prolongation_flag
                            ,(SELECT kl.name FROM t_kladr kl WHERE kl.t_kladr_id = pp.region_id) AS filial_name
                            ,pkg_agn_control.get_current_policy_agent(ph.policy_header_id) AS agent_id
                            ,(SELECT dsr.name
                                FROM ven_p_policy   pp
                                    ,doc_status_ref dsr
                                    ,p_pol_header   pph
                               WHERE pp.doc_status_ref_id = dsr.doc_status_ref_id
                                 AND pph.policy_id = pp.policy_id
                                 AND dn.policy_header_id = pph.policy_header_id) AS last_ver_status_name
                        FROM dwo_notice     dn
                            ,document       dc
                            ,doc_status_ref dsr
                            ,dwo_schedule   sc
                            ,p_pol_header   ph
                            ,p_policy       pp
                            ,fund           f
                            ,contact        co
                       WHERE dn.dwo_notice_id = dc.document_id
                         AND dn.dwo_notice_id = sc.dwo_notice_id
                         AND dc.doc_status_ref_id = dsr.doc_status_ref_id
                         AND dsr.brief IN ('RECEIVED', 'REFINE_DETAILS') /*Принято, Принято. Уточнение реквизитов*/
                         AND par_writeoff_date BETWEEN sc.date_start AND sc.date_end
                         AND dn.policy_header_id = ph.policy_header_id
                         AND ph.policy_id = pp.policy_id
                         AND dn.pay_fund_id = f.fund_id
                         AND pkg_policy.get_policy_agent_id(pp.policy_id) = co.contact_id
                         AND
                            /*Нет операций для этого графика, которые успешно списаны*/
                             NOT EXISTS (SELECT NULL
                                FROM dwo_operation  dwo
                                    ,document       dc
                                    ,doc_status_ref dsr
                               WHERE dwo.dwo_schedule_id = sc.dwo_schedule_id
                                 AND dwo.dwo_operation_id = dc.document_id
                                 AND dc.doc_status_ref_id = dsr.doc_status_ref_id
                                 AND dsr.brief = 'PROCESSED' /*Обработан*/
                                 AND dwo.writeoff_description = gc_success /*Результат - успешно*/
                              )
                         AND /*В данном реестре нет операций для графика списания*/
                             NOT EXISTS (SELECT NULL
                                FROM dwo_operation do
                               WHERE do.dwo_oper_registry_id = par_registry_id
                                 AND do.dwo_schedule_id = sc.dwo_schedule_id))
    
    LOOP
    
      dml_dwo_operation.insert_record(par_dwo_oper_registry_id => par_registry_id
                                     ,par_dwo_schedule_id      => vr_notice.dwo_schedule_id
                                     ,par_insured_fio          => vr_notice.insured_fio
                                     ,par_doc_templ_id         => v_doc_templ_id
                                     ,par_reg_date             => SYSDATE
                                     ,par_dwo_notice_id        => vr_notice.dwo_notice_id
                                     ,par_insured_id           => vr_notice.insured_id
                                     ,par_card_type_id         => vr_notice.card_type_id
                                     ,par_policy_fee           => ROUND((acc_new.get_rate_by_brief('ЦБ'
                                                                                                  ,vr_notice.pay_fund_brief
                                                                                                  ,v_oper_register_date /*Курс на дату формирования реестра.*/) *
                                                                        vr_notice.notice_fee)
                                                                       ,2)
                                     ,par_notice_fee           => vr_notice.notice_fee
                                     ,par_pay_fund_id          => vr_notice.pay_fund_id
                                     ,par_payer_fio            => vr_notice.payer_fio
                                     ,par_payer_id             => vr_notice.payer_id
                                     ,par_agent                => vr_notice.agent_name
                                     ,par_cell_phone           => vr_notice.cell_phone
                                     ,par_notice_writeoff_date => vr_notice.notice_writeoff_date
                                     ,par_plan_end_date        => vr_notice.schedule_end
                                     ,par_region_name          => vr_notice.region_name
                                     ,par_region_id            => vr_notice.region_id
                                     ,par_download_date        => SYSDATE
                                     ,par_author_id            => safety.curr_sys_user
                                     ,par_prolongation_flag    => vr_notice.prolongation_flag
                                     ,par_product_name         => vr_notice.product_name
                                     ,par_ids                  => vr_notice.ids
                                     ,par_pay_fund_name        => vr_notice.pay_fund_brief
                                     ,par_pol_last_status      => vr_notice.last_ver_status_name
                                     ,par_dwo_operation_id     => v_operation_id);
      --Операции переводим в статус "В реестре на списание"
      doc.set_doc_status(p_doc_id => v_operation_id, p_status_brief => 'PROJECT');
      doc.set_doc_status(p_doc_id => v_operation_id, p_status_brief => 'TO_WRITEOFF');
      doc.set_doc_status(p_doc_id => v_operation_id, p_status_brief => 'IN_REGISTRY');
    
      /*Проверить, что атрибуты в заявлении не изменились (график формируется в любом случае)*/
      IF NOT check_permanence(vr_notice.dwo_notice_id)
      THEN
        doc.set_doc_status(p_doc_id       => vr_notice.dwo_notice_id
                          ,p_status_brief => 'REFINE_DETAILS' /*Принято.Уточнение реквизитов*/);
        /*Добавить в комментарий причину расхождений*/
        add_note_about_difference(vr_notice.dwo_notice_id);
      END IF;
    END LOOP;
  END create_operations;
  /*
  Создание графика списаний
  17.07.2014
  */
  PROCEDURE create_schedule(par_dwo_notice_id dwo_notice.dwo_notice_id%TYPE) IS
    v_start_date          dwo_schedule.date_start%TYPE;
    v_end_date_base       dwo_schedule.date_end%TYPE;
    v_end_date            dwo_schedule.date_end%TYPE;
    v_new_end_date_base   dwo_schedule.date_end%TYPE;
    vr_notice             dml_dwo_notice.tt_dwo_notice;
    vr_notice_type        dml_t_dwo_notice_type.tt_t_dwo_notice_type;
    vr_payment_terms      dml_t_payment_terms.tt_t_payment_terms;
    v_pol_start_date      p_pol_header.start_date%TYPE;
    v_pol_end_date        p_policy.end_date%TYPE;
    v_amount              dwo_schedule.notice_fee%TYPE;
    vr_period_info        pkg_period.t_period_info;
    v_privelege_period_id p_policy.pol_privilege_period_id%TYPE;
    v_till                DATE;
    v_period_length       NUMBER;
    v_initial_start_date  DATE;
    v_offset              NUMBER := 0;
    v_pol_header_offset   NUMBER := 0;
    /*Проверка возможности пролонгации договора страхования*/
    FUNCTION can_prolongate(par_pol_header_id p_pol_header.policy_header_id%TYPE) RETURN BOOLEAN IS
      v_is_prolongation t_product.is_prolongation%TYPE;
    BEGIN
      SELECT pr.is_prolongation
        INTO v_is_prolongation
        FROM p_pol_header ph
            ,t_product    pr
       WHERE ph.product_id = pr.product_id
         AND ph.policy_header_id = par_pol_header_id;
      RETURN v_is_prolongation = 1;
    END can_prolongate;
  
    /*Проверяет попадает ли дата годовщины начала ДС в период графика списания*/
    FUNCTION annual_in_period
    (
      par_pol_start_date p_pol_header.start_date%TYPE
     ,par_period_start   DATE
     ,par_period_end     DATE
    ) RETURN BOOLEAN IS
      v_annuals_in_period NUMBER;
    BEGIN
      SELECT COUNT(*)
        INTO v_annuals_in_period
        FROM (SELECT to_date(to_char(par_pol_start_date, 'ddmm') ||
                             to_char(extract(YEAR FROM ADD_MONTHS(par_period_start, (rownum - 1) * 12)))
                            ,'ddmmyyyy') AS start_date
                FROM dual
              CONNECT BY rownum <=
                         (extract(YEAR FROM par_period_end) + 1) - extract(YEAR FROM par_period_start))
       WHERE start_date BETWEEN par_period_start AND par_period_end;
    
      RETURN v_annuals_in_period > 0;
    END annual_in_period;
  
    /*Получить дату начала и окончания ДС и льготный период*/
    PROCEDURE get_policy_info
    (
      par_pol_header_id       p_pol_header.policy_header_id%TYPE
     ,par_start_date          OUT p_pol_header.start_date%TYPE
     ,par_end_date            OUT p_policy.end_date%TYPE
     ,par_privelege_period_id OUT p_policy.pol_privilege_period_id%TYPE
    ) IS
    BEGIN
      SELECT ph.start_date
            ,pp.end_date
            ,pp.pol_privilege_period_id
        INTO par_start_date
            ,par_end_date
            ,par_privelege_period_id
        FROM p_pol_header ph
            ,p_policy     pp
       WHERE ph.policy_header_id = par_pol_header_id
         AND ph.max_uncancelled_policy_id = pp.policy_id;
    EXCEPTION
      WHEN no_data_found THEN
        ex.raise('Договор страхования с ID заголовка: ' || nvl(to_char(par_pol_header_id), 'null') ||
                 ' не найден');
    END get_policy_info;
  
    PROCEDURE receive_start_and_end_dates
    (
      par_dwo_notice_id dwo_schedule.dwo_notice_id%TYPE
     ,par_start_date    OUT dwo_schedule.date_start%TYPE
     ,par_end_date      OUT dwo_schedule.date_end%TYPE
    ) IS
    BEGIN
      SELECT ws.date_start
            ,ws.date_end
        INTO par_start_date
            ,par_end_date
        FROM dwo_schedule ws
       WHERE ws.dwo_schedule_id IN (SELECT MAX(ws.dwo_schedule_id)
                                      FROM dwo_schedule ws
                                     WHERE ws.dwo_notice_id = par_dwo_notice_id);
    EXCEPTION
      WHEN no_data_found THEN
        NULL;
    END receive_start_and_end_dates;
  
    FUNCTION get_initial_start_date(par_dwo_notice_id dwo_schedule.dwo_notice_id%TYPE) RETURN DATE IS
      v_date DATE;
    BEGIN
      SELECT MAX(ws.date_start) keep(dense_rank /*FIRST*/ LAST ORDER BY ws.dwo_schedule_id)
        INTO v_date
        FROM dwo_schedule ws
       WHERE ws.dwo_notice_id = par_dwo_notice_id;
      RETURN v_date;
    END get_initial_start_date;
  
  BEGIN
    /******************************************/
    /*Информация по заявлению*/
    vr_notice := dml_dwo_notice.get_record(par_dwo_notice_id);
    /*Тип заявления*/
    vr_notice_type := dml_t_dwo_notice_type.get_record(vr_notice.notice_type_id);
    /*Для типа заявления "На отказ" не нужно формировать графики*/
    IF vr_notice_type.brief = 'REFUSAL'
    THEN
      RETURN;
    END IF;
    /*Дата окончания действия карты*/
    v_till := last_day(to_date('01' || vr_notice.card_month || vr_notice.card_year, 'ddmmrr'));
    get_policy_info(par_pol_header_id       => vr_notice.policy_header_id
                   ,par_start_date          => v_pol_start_date
                   ,par_end_date            => v_pol_end_date
                   ,par_privelege_period_id => v_privelege_period_id);
  
    vr_period_info := pkg_period.get_period_info(par_period_id => v_privelege_period_id);
  
    receive_start_and_end_dates(par_dwo_notice_id => vr_notice.dwo_notice_id
                               ,par_start_date    => v_start_date
                               ,par_end_date      => v_end_date);
    /*Периодичность*/
    vr_payment_terms := dml_t_payment_terms.get_record(vr_notice.payment_term_id);
  
    -- Получаем дату (start_date) последней записи графика
    v_initial_start_date := get_initial_start_date(vr_notice.dwo_notice_id);
    v_period_length      := 12 / vr_payment_terms.number_of_payments;
  
    IF v_initial_start_date IS NULL
    THEN
      v_initial_start_date := vr_notice.notice_writeoff_date; /* Первую дату берем с "Дата списания по заявлению"  31.10.2014 По указанию Аллы*/
    ELSE
      v_offset := ROUND(MONTHS_BETWEEN(v_initial_start_date
                                      ,vr_notice.notice_writeoff_date /*Дата списания по заявлению*/ /*vr_notice.first_writeoff_date*/)) /
                  v_period_length + 1;
    END IF;
  
    /*Для заявления на "Списание"*/
    IF vr_notice_type.brief = 'WRITEOFF'
    THEN
      -- Определяем дату графика без учета льготного периода
      v_pol_header_offset := ROUND(MONTHS_BETWEEN(vr_notice.first_writeoff_date, v_pol_start_date)) /
                             v_period_length;
      -- v_end_date_base     := ADD_MONTHS(v_pol_start_date, v_pol_header_offset * v_period_length); --Первое списание в счет уплаты взноса (плановая дата платежа из ДС)
      /*Для заявления типа "Доп. списание" списание происходит в день списания по заявлению*/
    ELSIF vr_notice_type.brief = 'EXTRA_WRITEOFF'
    THEN
      v_end_date_base := v_start_date;
    ELSE
      ex.raise('Для типа заявлеия ' || vr_notice_type.description ||
               ' формирование графика списания не предусмотрено');
    END IF;
  
    /*Пропускаем несколько (offset) ЭПГ при доформировывании графиков, по умолчанию 0*/
    v_start_date        := ADD_MONTHS(vr_notice.notice_writeoff_date, v_offset * v_period_length);
    v_new_end_date_base := ADD_MONTHS(v_pol_start_date
                                     ,(v_pol_header_offset + v_offset) * v_period_length);
  
    v_end_date := least(v_till
                       ,pkg_period.add_period(par_period_info => vr_period_info
                                             ,par_date        => v_new_end_date_base)
                       ,v_pol_end_date);
  
    /* Формирование графиков */
    LOOP
      /* Если полученная дата меньше чем значение поля «Срок действия списания» Шаблона */
      EXIT WHEN v_start_date >= least(v_till, v_pol_end_date) OR v_new_end_date_base > least(v_till
                                                                                            ,v_pol_end_date) OR vr_notice_type.brief = 'EXTRA_WRITEOFF';
    
      IF annual_in_period(v_pol_start_date
                         ,v_new_end_date_base /*Период берется именно от даты ЭПГ Черных М. 18.12.2014 #384158*/
                         ,v_end_date)
      THEN
        v_amount := vr_notice.notice_fee + nvl(vr_notice.admin_costs, 0);
      ELSE
        v_amount := vr_notice.notice_fee;
      END IF;
      /* Если дата окончания получилась меньше даты начала, ошибка */
      IF v_end_date < v_start_date
      THEN
        ex.raise(par_message => 'Ошибка формирования графика. Дата окончания меньше даты начала.');
      END IF;
    
      /*Формируем строку графика только, если дата начала больше или равна дате очередного списания 370529 31.10.2014*/
      IF v_new_end_date_base >= vr_notice.next_writeoff_date
      THEN
        dml_dwo_schedule.insert_record(par_dwo_notice_id     => par_dwo_notice_id
                                      ,par_date_start        => v_start_date
                                      ,par_date_end          => trunc(v_end_date, 'dd')
                                      ,par_notice_fee        => v_amount
                                      ,par_prolongation_flag => 0);
      END IF;
      v_offset := v_offset + 1;
      /* Вычислить значение «Дата начала периода списания» для следующего ЭГС */
      v_start_date := ADD_MONTHS(vr_notice.notice_writeoff_date, v_offset * v_period_length);
    
      v_new_end_date_base := ADD_MONTHS(v_pol_start_date
                                       ,(v_pol_header_offset + v_offset) * v_period_length);
    
      v_end_date := least(v_till
                         ,pkg_period.add_period(par_period_info => vr_period_info
                                               ,par_date        => v_new_end_date_base)
                         ,v_pol_end_date);
    
    END LOOP;
  
    /*Для ДС с возможностью пролонгации, формируем доп. строку графика списания*/
    IF can_prolongate(par_pol_header_id => vr_notice.policy_header_id)
       AND v_new_end_date_base > v_pol_end_date /*Изменено 24.11.2014 Черных М.  #377388 v_end_date > v_pol_end_date*/
       AND vr_notice_type.brief = 'WRITEOFF'
    THEN
      v_start_date := ROUND(v_pol_end_date) - 30;
      v_end_date   := v_pol_end_date;
    
      IF annual_in_period(v_pol_start_date, v_start_date, v_end_date)
      THEN
        v_amount := vr_notice.notice_fee + vr_notice.admin_costs;
      ELSE
        v_amount := vr_notice.notice_fee;
      END IF;
      dml_dwo_schedule.insert_record(par_dwo_notice_id     => par_dwo_notice_id
                                    ,par_date_start        => v_start_date
                                    ,par_date_end          => trunc(v_end_date, 'dd')
                                    ,par_notice_fee        => v_amount
                                    ,par_prolongation_flag => 1);
    END IF;
  
  END create_schedule;

  /*Создание реестра на списание*/
  PROCEDURE create_registry
  (
    par_start_date DATE
   ,par_end_date   DATE
  ) IS
  
    v_registry_id dwo_oper_registry.dwo_oper_registry_id%TYPE;
    /*Проверка наличия незавершенных операций*/
    FUNCTION check_for_uncompleted_ops RETURN BOOLEAN IS
      v_is_exists NUMBER(1);
    BEGIN
      SELECT COUNT(1)
        INTO v_is_exists
        FROM dual
       WHERE EXISTS (SELECT NULL
                FROM dwo_operation  dwo
                    ,document       dc
                    ,doc_status_ref dsr
               WHERE dwo.dwo_operation_id = dc.document_id
                 AND dc.doc_status_ref_id = dsr.doc_status_ref_id
                 AND dsr.brief IN ( /*'PROJECT', 'TO_WRITEOFF',*/'IN_REGISTRY'
                                  ,'IN_ACCOUNTANCY'
                                  ,'REVISION'
                                  ,'REVISION_NO_OPERATION'
                                  ,'REVISION_NO_RESULT'));
      RETURN v_is_exists = 0;
    END check_for_uncompleted_ops;
  
  BEGIN
    IF NOT is_exists_writeoff_date(par_start_date, par_end_date)
    THEN
      ex.raise('Период с ' || to_char(par_start_date, 'dd.mm.rrrr') || ' по ' ||
               to_char(par_start_date, 'dd.mm.rrrr') ||
               ' не содержит даты списания: 1,5,10,15,20,25 число месяца');
    END IF;
  
    IF check_for_uncompleted_ops
    THEN
      dml_dwo_oper_registry.insert_record(par_registry_type_id     => dml_t_dwo_registry_type.get_id_by_brief('TO_WRITEOFF')
                                         ,par_start_date           => par_start_date
                                         ,par_end_date             => par_end_date
                                         ,par_creation_date        => SYSDATE
                                         ,par_author_id            => safety.curr_sys_user
                                         ,par_doc_templ_id         => doc.templ_id_by_brief('DWO_OPER_REGISTRY')
                                         ,par_dwo_oper_registry_id => v_registry_id);
      /*Сформировать операции для реестр за даты списания (1,5,10,15,20,25 дни месяца), которые попадают в период реестра*/
      FOR vr_row IN (SELECT par_start_date + LEVEL - 1 writeoff_date
                       FROM dual
                      WHERE extract(DAY FROM(par_start_date + LEVEL - 1)) IN (1, 5, 10, 15, 20, 25)
                     CONNECT BY par_start_date + LEVEL - 1 <= par_end_date)
      LOOP
        create_operations(par_registry_id => v_registry_id, par_writeoff_date => vr_row.writeoff_date);
      END LOOP;
    
      doc.set_doc_status(p_doc_id => v_registry_id, p_status_brief => 'PROJECT');
      /*Статус реестра "На списание"*/
      doc.set_doc_status(p_doc_id => v_registry_id, p_status_brief => 'TO_WRITEOFF');
    ELSE
      ex.raise('Существуют ЭС в статусе "В реестре", или "В бухгалтерии", или "Доработка. Нет операции", или "Доработка. Нет результата"!');
    END IF;
  END create_registry;

  /*Удаление реестра и всех его операций*/
  PROCEDURE delete_registry(par_dwo_oper_registry dwo_oper_registry.dwo_oper_registry_id%TYPE) IS
  BEGIN
    DELETE FROM dwo_operation do WHERE do.dwo_oper_registry_id = par_dwo_oper_registry;
    DELETE FROM dwo_oper_registry dr WHERE dr.dwo_oper_registry_id = par_dwo_oper_registry;
  END delete_registry;

  /*Удаление заявления*/
  PROCEDURE delete_notice(par_dwo_notice_id dwo_notice.dwo_notice_id%TYPE) IS
  BEGIN
    --Удаление всех графиков списания
    DELETE FROM dwo_schedule ds WHERE ds.dwo_notice_id = par_dwo_notice_id;
    dml_dwo_notice.delete_record(par_dwo_notice_id => par_dwo_notice_id);
  END delete_notice;

  /*Формирование CSV на списание*/
  PROCEDURE create_registry_file
  (
    par_registry_id dwo_oper_registry.dwo_oper_registry_id%TYPE
   ,par_file_path   VARCHAR2
   ,par_is_revision BOOLEAN := FALSE /*Реестр операций "Доработка. Нет результата"*/
   ,par_csv         IN OUT CLOB
  ) IS
    v_registry_id dwo_oper_registry.dwo_oper_registry_id%TYPE;
    v_is_revision NUMBER;
  
    CURSOR cur_ops
    (
      par_registry_id dwo_oper_registry.dwo_oper_registry_id%TYPE
     ,par_is_revision NUMBER
    ) IS
      SELECT a.*
        FROM (SELECT row_number() over(PARTITION BY dn.card_num ORDER BY dn.card_num) - 1 AS j
                    ,dense_rank() over(ORDER BY dn.card_num) AS i
                    ,to_char(op.dwo_operation_id) AS dwo_operation_id
                    ,op.product_name AS product_brief
                    ,op.insured_fio
                    ,ps.name AS card_type
                    ,regexp_replace(dn.card_num, '(\d{4})(\d{4})(\d{4})(\d{4})', '\1 \2 \3 \4') card_num
                    ,to_char(op.ids) AS ids
                    ,to_char(op.policy_fee) AS policy_fee
                    ,dn.card_month || '/' || dn.card_year AS card_expired
                    ,to_char(op.notice_fee, 'FM9999999999999999999999990D00') AS notice_fee
                    ,fd.brief AS fund_brief
                    ,op.payer_fio
                    ,op.agent AS agent_name
                    ,op.cell_phone
                    ,to_char(dn.notice_date, 'dd.mm.yyyy') AS date_dwo_notice
                    ,to_char(op.plan_end_date, 'dd.mm.yyyy') AS plan_end_date
                    ,to_char(dn.notice_writeoff_date, 'dd.mm.yyyy') AS notice_writeoff_date /*Дата списания по заявлению*/
                    ,op.region_name AS region_name
                    ,to_char(op.download_date, 'dd.mm.yyyy') AS download_date
                    ,to_char(dor.end_date, 'dd.mm.yyyy') AS registry_date
                    ,(SELECT dsr.name
                        FROM ven_p_policy   pp
                            ,doc_status_ref dsr
                            ,p_pol_header   pph
                       WHERE pp.doc_status_ref_id = dsr.doc_status_ref_id
                         AND pph.policy_id = pp.policy_id
                         AND dn.policy_header_id = pph.policy_header_id) AS last_ver_status_name
                    ,to_char(dc.reg_date, 'dd.mm.yyyy') AS reg_date
                    ,to_char(dn.first_writeoff_date, 'dd.mm.yyyy') AS first_writeoff_date
                    ,op.prolongation_flag
                FROM dwo_operation     op
                    ,document          dc
                    ,t_payment_system  ps
                    ,dwo_notice        dn
                    ,fund              fd
                    ,doc_status_ref    dsrl
                    ,dwo_oper_registry dor
               WHERE op.dwo_oper_registry_id = nvl(par_registry_id, op.dwo_oper_registry_id)
                 AND dsrl.brief = nvl2(par_is_revision, 'REVISION_NO_RESULT', dsrl.brief) /*Реестр операций "Доработка. Нет результата"*/
                 AND op.dwo_operation_id = dc.document_id
                 AND op.card_type_id = ps.t_payment_system_id
                 AND op.dwo_notice_id = dn.dwo_notice_id
                 AND op.pay_fund_id = fd.fund_id
                 AND dc.doc_status_ref_id = dsrl.doc_status_ref_id
                 AND op.dwo_oper_registry_id = dor.dwo_oper_registry_id) a
       ORDER BY i + j * 45 /*Перемешивание по номерам карт для PIN PAD(повторяться должны, не чаще чем через 45)*/
      ;
  
  BEGIN
    IF par_csv IS NULL
    THEN
      dbms_lob.createtemporary(lob_loc => par_csv, cache => TRUE);
    END IF;
  
    /*Для CSV  - "Доработка. Нет результата"*/
    IF par_is_revision
    THEN
      v_registry_id := NULL; --Операции формируем по всем реестрам
      v_is_revision := 1;
    ELSE
      v_registry_id := par_registry_id;
      v_is_revision := NULL;
    END IF;
  
    FOR vr_ops IN cur_ops(v_registry_id, v_is_revision)
    LOOP
      /*Последовательность столбцов важна*/
      pkg_csv.add_value(par_value => nvl(vr_ops.region_name, ' ')); /*1.Регион*/
      pkg_csv.add_value(par_value => vr_ops.registry_date /*vr_ops.download_date*/); /*2. Дата реестра 19.12.2014 Черрных М. 383900(2.Дата выгрузки)*/
      pkg_csv.add_value(par_value => vr_ops.insured_fio); /*3.ФИО страховщика*/
      pkg_csv.add_value(par_value => vr_ops.card_type); /*4.Тип карты*/
      pkg_csv.add_value(par_value => vr_ops.card_num); /*5.Номер карты*/
      pkg_csv.add_value(par_value => vr_ops.ids); /*6.ИДС*/
      pkg_csv.add_value(par_value => vr_ops.policy_fee); /*7.Сумма взноса по договору, руб (для валютных платежей по курсу ЦБ РФ на день списания*/
      pkg_csv.add_value(par_value => vr_ops.card_expired); /*8.Месяц и год карты*/
    
      pkg_csv.add_value(par_value => vr_ops.payer_fio); /*9.ФИО плательщика*/
      pkg_csv.add_value(par_value => vr_ops.agent_name); /*10.Агент*/
      pkg_csv.add_value(par_value => to_char(vr_ops.prolongation_flag)); /*11.Флаг пролонгации*/
      pkg_csv.add_value(par_value => vr_ops.dwo_operation_id); /*12.ИД операции списания, по ней загружается результат списания*/
      pkg_csv.add_value(par_value => vr_ops.product_brief); /*13.Продукт*/
      pkg_csv.add_value(par_value => vr_ops.fund_brief); /*14.Наименование валюты*/
      pkg_csv.add_value(par_value => vr_ops.notice_fee); /*15.Сумма в валюте платежа*/
      pkg_csv.add_value(par_value => vr_ops.cell_phone); /*16.Сотовыц телефон*/
      pkg_csv.add_value(par_value => vr_ops.first_writeoff_date); /*17.Дата первого списания*/
      pkg_csv.add_value(par_value => vr_ops.plan_end_date); /*18.Плановая дата окончания*/
      pkg_csv.add_value(par_value => vr_ops.last_ver_status_name); /*19.Статус последней версии ДС*/
    
      pkg_csv.write_row(par_csv => par_csv);
      --Операции переводим в статус "В бухгалтерии"
      /*Для CSV  - "Доработка. Нет результата" - статусы не меняем*/
      IF NOT par_is_revision
      THEN
        doc.set_doc_status(to_number(vr_ops.dwo_operation_id), 'IN_ACCOUNTANCY');
      END IF;
    END LOOP;
  
    /*Указывем путь выгрузка файла*/
    UPDATE dwo_oper_registry dr
       SET dr.file_path = par_file_path
     WHERE dr.dwo_oper_registry_id = par_registry_id;
  
    /*Переводим статус "В бухгалтерии" после выгрузки реестра*/
    /*Для CSV  - "Доработка. Нет результата" - статусы не меняем*/
    IF NOT par_is_revision
    THEN
      doc.set_doc_status(par_registry_id, 'IN_ACCOUNTANCY');
    END IF;
  
  END create_registry_file;

  /*Формирование файла CSV, с операциями в статуса "Доработка. Нет результата"*/
  FUNCTION create_csv_revision_no_result RETURN CLOB IS
    v_csv CLOB;
  BEGIN
    /*Формируем реестр операций "Доработка. Нет результата"*/
    create_registry_file(par_registry_id => NULL
                        ,par_file_path   => NULL
                        ,par_is_revision => TRUE
                        ,par_csv         => v_csv);
    RETURN v_csv;
  
  END create_csv_revision_no_result;

  /*Проверка, что существует операция списания в нужных статусах*/
  FUNCTION is_exists_writeoff_operation(par_writeoff_operation_id dwo_operation.dwo_operation_id%TYPE)
    RETURN BOOLEAN IS
    v_is_exists NUMBER(1);
  BEGIN
    /*Проверяем, что по ИД, которое введ пользователь есть операция списания*/
    SELECT COUNT(*)
      INTO v_is_exists
      FROM dual
     WHERE EXISTS
     (SELECT NULL
              FROM dwo_operation do
             WHERE do.dwo_operation_id = par_writeoff_operation_id
               AND EXISTS (SELECT NULL
                      FROM document       dc
                          ,doc_status_ref dsr
                     WHERE dc.document_id = do.dwo_operation_id
                       AND dc.doc_status_ref_id = dsr.doc_status_ref_id
                       AND dsr.brief IN
                           ('IN_ACCOUNTANCY' /*В бухгалтерии*/
                           ,'REVISION_NO_RESULT' /*Доработка. Нет результата*/)));
    RETURN v_is_exists = 1;
  END is_exists_writeoff_operation;

  /*Обработать одну строку операции "Результат списания"*/
  PROCEDURE process_operation_result
  (
    par_result_operation_id dwo_operation.dwo_operation_id%TYPE
   ,par_is_user_recognize   BOOLEAN := FALSE /*признак, что операция подобрана пользователем*/
  ) IS
    vr_result_operation       dml_dwo_operation.tt_dwo_operation;
    v_writeoff_operation_id   dwo_operation.dwo_operation_id%TYPE;
    vr_direct_writeoff_result dml_t_direct_writeoff_result.tt_t_direct_writeoff_result; --Справочник результатов списания
  
  BEGIN
    vr_result_operation := dml_dwo_operation.get_record(par_result_operation_id);
  
    /*При загрузке файла заполняется dwo_ext_id=исходная операция списания, при ручной доработке пользователем
    operation_id_recognize*/
    IF par_is_user_recognize
    THEN
      v_writeoff_operation_id := vr_result_operation.operation_id_recognize;
    ELSE
      v_writeoff_operation_id := vr_result_operation.dwo_ext_id;
    END IF;
  
    IF is_exists_writeoff_operation(v_writeoff_operation_id)
    THEN
    
      IF vr_result_operation.writeoff_description IS NOT NULL
      THEN
      
        /*Заполняем ссылку на справочник результатов списания по тексту результата*/
        vr_direct_writeoff_result := dml_t_direct_writeoff_result.get_rec_by_description(vr_result_operation.writeoff_description
                                                                                        ,par_raise_on_error => FALSE);
        /*Если текста результата нет в справочнике, то выдаем ошибку*/
        IF vr_direct_writeoff_result.t_direct_writeoff_result_id IS NULL
        THEN
          ex.raise('Причина отказа: "' || vr_result_operation.writeoff_description ||
                   '" не найдена в справочнике');
        ELSE
          --Проставляем ссылку
          vr_result_operation.t_direct_writeoff_result_id := vr_direct_writeoff_result.t_direct_writeoff_result_id;
          dml_dwo_operation.update_record(par_record => vr_result_operation);
        END IF;
      
        /*Фиксируем результат списания для исходной операции*/
        UPDATE dwo_operation do
           SET do.writeoff_result             = vr_result_operation.writeoff_result
              ,do.writeoff_description        = vr_result_operation.writeoff_description
              ,do.check_num                   = vr_result_operation.check_num
              ,do.writeoff_datetime           = vr_result_operation.writeoff_datetime
              ,do.writeoff_reference          = vr_result_operation.writeoff_reference
              ,do.t_direct_writeoff_result_id = vr_result_operation.t_direct_writeoff_result_id
              ,do.upload_date                 = vr_result_operation.upload_date
         WHERE do.dwo_operation_id = v_writeoff_operation_id;
      
        --Заполняем ссылку на исходную "операцию списания" в операции "результат списания"
        UPDATE dwo_operation do
           SET do.parent_operation_id = v_writeoff_operation_id
         WHERE do.dwo_operation_id = par_result_operation_id;
      
        doc.set_doc_status(v_writeoff_operation_id, 'PROCESSED'); --Исходная операция обработана
        doc.set_doc_status(par_result_operation_id, 'PROCESSED'); --Обработано
      ELSE
        doc.set_doc_status(v_writeoff_operation_id, 'REVISION_NO_RESULT'); --Исходная операция без результата
        doc.set_doc_status(vr_result_operation.dwo_operation_id, 'REVISION_NO_RESULT'); --В операции "результата" не прописан результат
      END IF; /*Конец если не прописан результат */
    
    ELSE
      doc.set_doc_status(vr_result_operation.dwo_operation_id, 'REVISION_NO_OPERATION'); --Доработка (не нашли исходную операцию списания)
    END IF;
  END process_operation_result;

  /*
  Обработать операции в реестре "Результат списания"
  29.07.2014
  */
  PROCEDURE process_registry_result(par_dwo_oper_registry_id dwo_oper_registry.dwo_oper_registry_id%TYPE) IS
    vr_result_operation dml_dwo_operation.tt_dwo_operation;
  BEGIN
    --Обрабатываем все строки реестра результатов
    FOR vr_result_operation IN (SELECT do.dwo_operation_id
                                  FROM dwo_operation do
                                 WHERE do.dwo_oper_registry_id = par_dwo_oper_registry_id)
    LOOP
      process_operation_result(par_result_operation_id => vr_result_operation.dwo_operation_id);
    
    END LOOP;
    /*Статус реестру "Результат списания. Обработан"*/
    doc.set_doc_status(par_dwo_oper_registry_id, 'WRITEOFF_RESULT_PROCESSED');
  
    --Все оставшиеся операции в статусе "В бухгалтерии" переводим в статус "Доработка. Нет результата"
    --При загрузке результатов операции в статусе "Доработка. Нет результата" тоже подбираются
    FOR vr_writeoff_opration IN (SELECT do.dwo_operation_id
                                   FROM dwo_operation  do
                                       ,document       dc
                                       ,doc_status_ref dsr
                                  WHERE do.dwo_operation_id = dc.document_id
                                    AND dc.doc_status_ref_id = dsr.doc_status_ref_id
                                    AND dsr.brief = 'IN_ACCOUNTANCY' /*В бухгалтерии*/
                                 )
    LOOP
      doc.set_doc_status(vr_writeoff_opration.dwo_operation_id, 'REVISION_NO_RESULT');
    END LOOP;
  
  END process_registry_result;

  /*
  Отмена реестра на списание
  @author Черных М.
  @param par_dwo_oper_registry_id ИД реестра на списание
  */
  PROCEDURE cancel_registry_result(par_dwo_oper_registry_id dwo_oper_registry.dwo_oper_registry_id%TYPE) IS
    v_writeoff_oper_id dwo_operation.dwo_operation_id%TYPE;
  BEGIN
    /*Переводим все операции в "Отменен"*/
    FOR vr_row IN (SELECT dor.dwo_operation_id
                     FROM dwo_operation dor
                    WHERE dor.dwo_oper_registry_id = par_dwo_oper_registry_id)
    LOOP
      /*Если по результатам реестра было завершено заявление, то возобновляем его*/
      cancel_notice_quit(par_dwo_operation_id => vr_row.dwo_operation_id);
      v_writeoff_oper_id := get_writeoff_oper_by_res_oper(vr_row.dwo_operation_id);
      IF v_writeoff_oper_id IS NOT NULL
      THEN
        /*Вернуть операцию "На списание" в статус "В бухгалтерии", как будто результ и не загружался*/
        doc.set_doc_status(p_doc_id => v_writeoff_oper_id, p_status_brief => 'IN_ACCOUNTANCY');
      END IF;
      /*Саму операцию "Результат списания" в статус "Отменен"*/
      doc.set_doc_status(p_doc_id => vr_row.dwo_operation_id, p_status_brief => 'CANCEL');
      /*Убираем ссылку на исходную оперцию списания*/
      UPDATE dwo_operation do
         SET do.parent_operation_id = NULL
       WHERE do.dwo_operation_id = vr_row.dwo_operation_id;
    END LOOP;
    /*Сам реестр в отменен*/
    doc.set_doc_status(p_doc_id => par_dwo_oper_registry_id, p_status_brief => 'CANCEL');
  END cancel_registry_result;

  /*Последний день действия карты*/
  FUNCTION get_card_last_day
  (
    par_card_month VARCHAR2
   ,par_card_year  VARCHAR2
  ) RETURN DATE IS
  BEGIN
    IF par_card_month IS NULL
       OR par_card_year IS NULL
    THEN
      RETURN NULL;
    END IF;
    RETURN last_day(to_date(to_char('01.' || par_card_month || '.' || par_card_year), 'dd.mm.rr'));
  END get_card_last_day;

  /*Преобразование CLOB в BLOB*/
  FUNCTION get_blob(par_clob CLOB) RETURN BLOB IS
    v_blob         BLOB;
    v_blob_offset  NUMBER := 1;
    v_clob_offset  NUMBER := 1;
    v_lang_context NUMBER := 0; --DBMS_LOB.DEFAULT_LANG_CTX;
    v_warning      NUMBER;
  BEGIN
    dbms_lob.createtemporary(lob_loc => v_blob, cache => TRUE);
  
    dbms_lob.converttoblob(src_clob     => par_clob
                          ,dest_lob     => v_blob
                          ,amount       => dbms_lob.lobmaxsize
                          ,dest_offset  => v_blob_offset
                          ,src_offset   => v_clob_offset
                          ,blob_csid    => dbms_lob.default_csid
                          ,lang_context => v_lang_context
                          ,warning      => v_warning);
  
    RETURN v_blob;
  END get_blob;

  /*Получить ИД исходного заявления по ИД операции результата*/
  FUNCTION get_notice_by_res_operation_id(par_result_operation_id dwo_operation.dwo_operation_id%TYPE)
    RETURN dwo_notice.dwo_notice_id%TYPE IS
    v_dwo_notice_id dwo_notice.dwo_notice_id%TYPE;
  BEGIN
    assert_deprecated(par_result_operation_id IS NULL
                     ,'Входной параметр par_result_operation_id пустой');
    SELECT src.dwo_notice_id
      INTO v_dwo_notice_id
      FROM dwo_operation res
          ,dwo_operation src
     WHERE res.dwo_operation_id = par_result_operation_id
       AND res.parent_operation_id = src.dwo_operation_id;
    RETURN v_dwo_notice_id;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN NULL;
    WHEN too_many_rows THEN
      ex.raise('Для операции Результат списания ИД=' || par_result_operation_id ||
               ' найдено несколько заявлений');
  END get_notice_by_res_operation_id;

  /*Получить ИД операции "На списание" по операции "Результат"*/
  FUNCTION get_writeoff_oper_by_res_oper(par_result_operation_id dwo_operation.dwo_operation_id%TYPE)
    RETURN dwo_operation.dwo_operation_id%TYPE IS
    v_dwo_operation_id dwo_operation.dwo_operation_id%TYPE;
  BEGIN
    assert_deprecated(par_result_operation_id IS NULL
                     ,'Входной параметр par_result_operation_id пустой');
    SELECT res.parent_operation_id
      INTO v_dwo_operation_id
      FROM dwo_operation res
     WHERE res.dwo_operation_id = par_result_operation_id;
    RETURN v_dwo_operation_id;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN NULL;
    WHEN too_many_rows THEN
      ex.raise('Для операции Результат списания ИД=' || par_result_operation_id ||
               ' найдено несколько операций на списание');
  END get_writeoff_oper_by_res_oper;

  /*Привязка результата списания к исходной операции при ручном переводе статуса из
  "Доработка. Нет операции" в "Обработано"*/
  PROCEDURE attach_result(par_result_operation_id dwo_operation.dwo_operation_id%TYPE) IS
    vr_result_operation dml_dwo_operation.tt_dwo_operation;
  
  BEGIN
    vr_result_operation := dml_dwo_operation.get_record(par_result_operation_id);
  
    IF NOT is_exists_writeoff_operation(vr_result_operation.operation_id_recognize)
    THEN
      ex.raise('По указанному ИД=' || vr_result_operation.operation_id_recognize ||
               ' операция не найдена в статусе "В бухгалтерии" или "Доработка. Нет результата"');
    END IF;
  
    --Обрабатываем операцию результата по ИД ручной привязки
    process_operation_result(par_result_operation_id => par_result_operation_id
                            ,par_is_user_recognize   => TRUE);
  
  END attach_result;

  /*Загрузка файла "Реестр результатов списания" из файла в таблицу операций*/
  PROCEDURE load_registry_result
  (
    par_file_id   temp_load_blob.session_id%TYPE
   ,par_file_path dwo_oper_registry.file_path%TYPE
  ) IS
    v_line                 VARCHAR2(2000);
    v_blob                 BLOB;
    v_clob                 CLOB;
    v_lang_context         NUMBER := dbms_lob.default_lang_ctx;
    v_dest_offset          NUMBER := 1;
    v_src_offset           NUMBER := 1;
    v_warning              NUMBER;
    v_row_idx              NUMBER := 0; -- Пропускаем заголовок
    vt_line                tt_one_col;
    v_dwo_operation_id     dwo_operation.dwo_operation_id%TYPE;
    v_dwo_oper_registry_id dwo_oper_registry.dwo_oper_registry_id%TYPE;
    v_writeoff_result      dwo_operation.writeoff_result%TYPE;
  
    /*Проверка, что строка не пустая */
    FUNCTION line_is_not_empty(par_line tt_one_col) RETURN BOOLEAN IS
      v_is_not_empty BOOLEAN := FALSE;
    BEGIN
      FOR i IN 1 .. par_line.count
      LOOP
        IF par_line(i) IS NOT NULL
        THEN
          v_is_not_empty := TRUE;
        END IF;
      END LOOP;
      RETURN v_is_not_empty;
    
    END line_is_not_empty;
  
    /*Проверка корректности строки файла*/
    PROCEDURE validate_row
    (
      par_line    tt_one_col
     ,par_row_idx NUMBER
    ) IS
      v_id NUMBER;
    BEGIN
      BEGIN
        v_id := dml_t_payment_system.get_id_by_brief(upper(REPLACE(par_line(4), ' ', ''))) /*Тип карты*/
         ;
      EXCEPTION
        WHEN OTHERS THEN
          ex.raise('В строке №' || par_row_idx ||
                   ' в столбце №4 задан не корретный тип платежной системы: ' || par_line(4));
      END;
    
      BEGIN
        v_id := dml_fund.get_id_by_brief(upper(vt_line(14))) /*Валюта*/
         ;
      EXCEPTION
        WHEN OTHERS THEN
          ex.raise('В строке №' || par_row_idx || ' в столбце №14 задан не корретный тип валюты: ' ||
                   par_line(14) || v_id);
      END;
    
    END validate_row;
  
  BEGIN
    dml_dwo_oper_registry.insert_record(par_registry_type_id     => dml_t_dwo_registry_type.get_id_by_brief('RESULT_WRITEOFF') /*Результат списания*/
                                       ,par_creation_date        => SYSDATE
                                       ,par_start_date           => trunc(SYSDATE)
                                       ,par_end_date             => trunc(SYSDATE)
                                       ,par_file_path            => par_file_path
                                       ,par_doc_templ_id         => doc.templ_id_by_brief('DWO_OPER_REGISTRY')
                                       ,par_reg_date             => SYSDATE
                                       ,par_author_id            => safety.curr_sys_user
                                       ,par_num                  => NULL
                                       ,par_dwo_oper_registry_id => v_dwo_oper_registry_id);
    doc.set_doc_status(p_doc_id => v_dwo_oper_registry_id, p_status_brief => 'PROJECT');
    doc.set_doc_status(p_doc_id => v_dwo_oper_registry_id, p_status_brief => 'WRITEOFF_RESULT');
  
    SELECT file_blob INTO v_blob FROM temp_load_blob WHERE session_id = par_file_id;
  
    dbms_lob.createtemporary(lob_loc => v_clob, cache => TRUE);
    dbms_lob.converttoclob(dest_lob     => v_clob
                          ,src_blob     => v_blob
                          ,amount       => dbms_lob.lobmaxsize
                          ,dest_offset  => v_dest_offset
                          ,src_offset   => v_src_offset
                          ,blob_csid    => dbms_lob.default_csid
                          ,lang_context => v_lang_context
                          ,warning      => v_warning);
    ---INSERT INTO test_table (col1,id) VALUES (v_clob,2);
    -- return;
    --SELECT t.col1 INTO v_clob FROM test_table t WHERE id = 2;
  
    LOOP
      v_row_idx := v_row_idx + 1;
      v_line    := pkg_csv.get_row(par_csv => v_clob, par_row_number => v_row_idx);
      EXIT WHEN v_line IS NULL;
    
      vt_line := pkg_csv.csv_string_to_array(par_line => v_line, par_columns_count => 25);
      IF line_is_not_empty(vt_line) /*Пустые строки не грузим*/
      THEN
        /*Проверка корректности строки*/
        validate_row(par_line => vt_line, par_row_idx => v_row_idx);
      
        --Формируем поле "Результат списания" по "Описанию результата"
        IF vt_line(20) = gc_success
           OR vt_line(20) IS NULL
        THEN
          v_writeoff_result := vt_line(20);
        ELSE
          v_writeoff_result := gc_refuse;
        END IF;
      
        dml_dwo_operation.insert_record(par_upload_date          => SYSDATE /*Дата загрузки*/
                                       ,par_region_name          => vt_line(1) /*Регион*/
                                       ,par_download_date        => to_date(vt_line(2)
                                                                           ,'dd.mm.rrrr hh24:mi:ss') /*Дата выгрузки реестра на списание из Борлас*/
                                       ,par_insured_fio          => vt_line(3) /*ФИО Страхователя*/
                                       ,par_card_type_id         => dml_t_payment_system.get_id_by_brief(upper(REPLACE(vt_line(4)
                                                                                                                      ,' '
                                                                                                                      ,''))) /*Тип карты*/
                                       ,par_ids                  => vt_line(6) /*ИДС*/
                                       ,par_policy_fee           => to_number(vt_line(7)
                                                                             ,'FM99999999999D99') /*Сумма взноса по договору в руб.*/
                                       ,par_payer_fio            => vt_line(9) /*ФИО плательщика*/
                                       ,par_agent                => vt_line(10) /*Агент*/
                                       ,par_prolongation_flag    => vt_line(11) /*Флаг пролонгации*/
                                       ,par_dwo_ext_id           => vt_line(12) /*ИД исходной операции, для которой данный результат*/
                                       ,par_product_name         => vt_line(13) /*Наименование продукта*/
                                       ,par_pay_fund_id          => dml_fund.get_id_by_brief(upper(vt_line(14))
                                                                                            ,FALSE) /*Валюта*/
                                       ,par_pay_fund_name        => upper(vt_line(14))
                                       ,par_notice_fee           => to_number(vt_line(15)
                                                                             ,'FM99999999999D99') /*Сумма в валюте платежа.*/
                                       ,par_cell_phone           => vt_line(16) /*Мобильный телефон*/
                                       ,par_plan_end_date        => to_date(vt_line(18)
                                                                           ,'dd.mm.rrrr hh24:mi:ss') /*Плановая дата окончания списания*/
                                       ,par_pol_last_status      => vt_line(19) /*Статус последней версии*/
                                       ,par_writeoff_description => vt_line(20) /*Расшифровка рез-та списания*/
                                       ,par_writeoff_result      => v_writeoff_result /*Результат списания*/
                                       ,par_writeoff_reference   => vt_line(21) /*Ссылка операции списания*/
                                       ,par_check_num            => vt_line(22) /*№Чека с терминала*/
                                       ,par_writeoff_datetime    => to_date(vt_line(23)
                                                                           ,'dd.mm.rrrr hh24:mi:ss') /*Дата/время операции*/
                                       ,par_doc_templ_id         => doc.templ_id_by_brief('DWO_OPERATION')
                                       ,par_reg_date             => SYSDATE
                                       ,par_author_id            => safety.curr_sys_user
                                       ,par_dwo_oper_registry_id => v_dwo_oper_registry_id
                                       ,par_dwo_operation_id     => v_dwo_operation_id);
        /*При загрузке операции в статусе "Проект"*/
        doc.set_doc_status(p_doc_id => v_dwo_operation_id, p_status_brief => 'PROJECT');
      END IF; --Конец, если строка не пустая
    END LOOP;
    dbms_lob.freetemporary(lob_loc => v_clob);
  
  END load_registry_result;

  /*
  Загрузка платежей по прямому списанию
  02.09.2014
  */
  PROCEDURE load_payment
  (
    par_writeoff_date dwo_operation.writeoff_datetime%TYPE
   ,par_ac_payment_id ac_payment.payment_id%TYPE
  ) IS
    vr_payment           dml_ac_payment.tt_ac_payment;
    vr_comission         dml_t_commission_rules.tt_t_commission_rules;
    v_to_writeoff_amount dwo_operation.policy_fee%TYPE;
    v_register_item_id   payment_register_item.payment_register_item_id%TYPE;
  
    /*Сумма по заявлениям на списание*/
    FUNCTION get_to_writeoff_amount RETURN ac_payment.amount%TYPE IS
      v_result ac_payment.amount%TYPE;
    BEGIN
      SELECT SUM(do.policy_fee)
        INTO v_result
        FROM v_dwo_operation do
       WHERE do.registry_type_brief = 'TO_WRITEOFF' /*На списание*/
         AND trunc(do.writeoff_datetime) = trunc(par_writeoff_date)
         AND do.writeoff_result = gc_success /*Успешно обработаны*/
      ;
      RETURN v_result;
    END get_to_writeoff_amount;
  BEGIN
    --Информация по ППВх
    vr_payment := dml_ac_payment.get_record(par_ac_payment_id);
    --% комиссии банка
    vr_comission := dml_t_commission_rules.get_record(vr_payment.t_commission_rules_id);
    --Сумма ЭС в реестрах на списания на заданную дату
    v_to_writeoff_amount := get_to_writeoff_amount;
  
    IF nvl(vr_payment.amount, -1) != nvl(v_to_writeoff_amount, -2)
    THEN
      ex.raise('Сумма ЭС (' || v_to_writeoff_amount || ') не совпадает с суммой ППВх (' ||
               vr_payment.amount || ')');
    END IF;
  
    /*Создаем элементы реестра платежей*/
    FOR vr_row IN (SELECT do.*
                     FROM v_dwo_operation do
                    WHERE do.registry_type_brief = 'TO_WRITEOFF' /*На списание*/
                      AND trunc(do.writeoff_datetime) = trunc(par_writeoff_date)
                      AND do.writeoff_result = gc_success /*Успешно обработаны*/
                   )
    LOOP
      v_register_item_id := NULL;
      pkg_payment_register.insert_register_item(par_register_item_id     => v_register_item_id
                                               ,par_payment_sum          => vr_row.policy_fee
                                               ,par_payment_currency     => 'RUR'
                                               ,par_payment_purpose      => vr_row.ids || ' ' ||
                                                                            vr_row.insured_fio || CASE
                                                                             vr_row.prolongation_flag
                                                                              WHEN 1 THEN
                                                                               ' Для пролонгации'
                                                                              ELSE
                                                                               NULL
                                                                            END
                                               ,par_commission_currency  => 'RUR'
                                               ,par_ac_payment_id        => vr_payment.payment_id
                                               ,par_payment_id           => NULL
                                               ,par_doc_num              => vr_row.check_num
                                               ,par_payment_data         => vr_row.registry_end_date /*vr_row.registry_date*/
                                               ,par_payer_fio            => vr_row.payer_fio
                                               ,par_payer_birth          => NULL
                                               ,par_payer_address        => NULL
                                               ,par_payer_id_name        => NULL
                                               ,par_payer_id_ser_num     => NULL
                                               ,par_payer_id_issuer      => NULL
                                               ,par_payer_id_issue_date  => NULL
                                               ,par_pol_ser              => NULL
                                               ,par_pol_num              => vr_row.ids
                                               ,par_ids                  => vr_row.ids
                                               ,par_insured_fio          => vr_row.insured_fio
                                               ,par_commission           => ROUND(vr_row.policy_fee *
                                                                                  nvl(vr_comission.commission_rate
                                                                                     ,0)/100
                                                                                 ,2) /*Сумма комиссии банка*/
                                               ,par_territory            => vr_row.region_name
                                               ,par_add_info             => NULL
                                               ,par_status               => 0
                                               ,par_is_dummy             => 0
                                               ,par_set_off_state        => 21 /*??*/
                                               ,par_collection_method_id => 3 /*Прямое списание с карты*/);
      /*Привязывем к операции платеж, которым она оплачена*/
      UPDATE dwo_operation do
         SET do.payment_register_item_id = v_register_item_id
       WHERE do.dwo_operation_id = vr_row.dwo_operation_id;
    END LOOP;
  
    /*Удаляем фиктивный реестр платежей*/
    DELETE FROM payment_register_item pri
     WHERE pri.ac_payment_id = par_ac_payment_id
       AND pri.is_dummy = 1;
  
  END load_payment;

  /*Пролонгация заявления на прямое списание 03.09.2014 Черных М.*/
  PROCEDURE prolongate_notice(par_payment_register_item_id payment_register_item.payment_register_item_id%TYPE) IS
    v_dwo_notice_id          dwo_notice.dwo_notice_id%TYPE;
    vr_notice                dml_dwo_notice.tt_dwo_notice;
    vr_payment_register_item dml_payment_register_item.tt_payment_register_item;
    v_str_date               VARCHAR2(100);
    /*Находим заявление для пролонгации для данного элемента реестра платежей*/
    FUNCTION get_notice_for_prolongation RETURN dwo_notice.dwo_notice_id%TYPE IS
      v_dwo_notice_id dwo_notice.dwo_notice_id%TYPE;
    BEGIN
      SELECT src.dwo_notice_id
        INTO v_dwo_notice_id
        FROM dwo_operation src
       WHERE src.payment_register_item_id = par_payment_register_item_id
         AND src.prolongation_flag = 1 /*Для пролонгации*/
      ;
      RETURN v_dwo_notice_id;
    EXCEPTION
      WHEN no_data_found THEN
        RETURN NULL;
    END get_notice_for_prolongation;
  
    FUNCTION find_pol_header_by_regitem(par_payment_register_item_id payment_register_item.payment_register_item_id%TYPE)
      RETURN p_pol_header.policy_header_id%TYPE IS
      v_pol_header_id p_pol_header.policy_header_id%TYPE;
    BEGIN
      BEGIN
        SELECT ph1.policy_header_id
          INTO v_pol_header_id
          FROM ac_payment   acp_epg
              ,doc_doc      dd1
              ,p_policy     pp1
              ,p_pol_header ph1
              ,doc_set_off  dso
         WHERE acp_epg.payment_id = dd1.child_id
           AND dd1.parent_id = pp1.policy_id
           AND pp1.pol_header_id = ph1.policy_header_id
           AND dso.parent_doc_id = acp_epg.payment_id
           AND dso.pay_registry_item = par_payment_register_item_id;
      EXCEPTION
        WHEN no_data_found THEN
          BEGIN
            --Ветка когда реестр разнесен с ПП на копию А7/ПД4
            SELECT ph2.policy_header_id
              INTO v_pol_header_id
              FROM document     acp_a7
                  ,doc_doc      dd2_1
                  ,doc_set_off  dso2
                  ,ac_payment   epg2
                  ,doc_doc      dd2
                  ,p_policy     pp2
                  ,p_pol_header ph2
                  ,doc_set_off  dso
             WHERE acp_a7.doc_templ_id IN (6432, 6533, 23095)
               AND acp_a7.document_id = dd2_1.child_id
               AND dd2_1.parent_id = dso2.child_doc_id
               AND dso2.parent_doc_id = epg2.payment_id
               AND epg2.payment_id = dd2.child_id
               AND dd2.parent_id = pp2.policy_id
               AND pp2.pol_header_id = ph2.policy_header_id
               AND acp_a7.document_id = dso.parent_doc_id
               AND dso.pay_registry_item = par_payment_register_item_id;
          EXCEPTION
            WHEN no_data_found THEN
              NULL;
          END;
        
      END;
      RETURN v_pol_header_id;
    END find_pol_header_by_regitem;
  
    /*Дата списания по заявлению ДД – день списания из родительского заявления, ММ – текущий месяц, ГГГГ – текущий год*/
    FUNCTION get_notice_writeoff_date(par_old_date DATE) RETURN DATE IS
      v_notice_writeoff_date dwo_notice.notice_writeoff_date%TYPE;
    BEGIN
      v_str_date := to_char(par_old_date, 'dd') || '.' || to_char(SYSDATE, 'mm.rrrr');
      IF substr(v_str_date, 1, 5) = '29.02'
      THEN
        v_notice_writeoff_date := last_day(to_char(v_str_date, 'mm.rrrr'));
      ELSE
        v_notice_writeoff_date := to_date(v_str_date, 'dd.mm.rrrr');
      END IF;
      RETURN v_notice_writeoff_date;
    END get_notice_writeoff_date;
  
    /*«Дата графика» для следующего ЭПГ по договору*/
    FUNCTION get_next_plan_date
    (
      par_policy_header_id p_pol_header.policy_header_id%TYPE
     ,par_writeoff_date    dwo_notice.notice_writeoff_date%TYPE
    ) RETURN ac_payment.plan_date%TYPE IS
      v_plan_date ac_payment.plan_date%TYPE;
    BEGIN
      SELECT plan_date
        INTO v_plan_date
        FROM (SELECT ap.plan_date
                FROM p_pol_header pph
                    ,p_policy     pp
                    ,doc_doc      dd
                    ,ac_payment   ap
               WHERE pph.policy_header_id = par_policy_header_id
                 AND pph.policy_id = pp.policy_id
                 AND pp.policy_id = dd.parent_id
                 AND dd.child_id = ap.payment_id
                 AND ap.plan_date > par_writeoff_date
               ORDER BY ap.plan_date) a
       WHERE rownum = 1;
      RETURN v_plan_date;
    EXCEPTION
      WHEN no_data_found THEN
        RETURN NULL;
    END get_next_plan_date;
  
    /*Значение поля «по» активной версии ДС*/
    FUNCTION get_end_policy_date(par_policy_header_id p_pol_header.policy_header_id%TYPE)
      RETURN p_policy.end_date%TYPE IS
      v_end_date p_policy.end_date%TYPE;
    BEGIN
      SELECT pp.end_date
        INTO v_end_date
        FROM p_pol_header pph
            ,p_policy     pp
       WHERE pph.policy_header_id = par_policy_header_id
         AND pph.policy_id = pp.policy_id;
      RETURN v_end_date;
    EXCEPTION
      WHEN no_data_found THEN
        RETURN NULL;
    END;
  
  BEGIN
    v_dwo_notice_id := get_notice_for_prolongation;
    IF v_dwo_notice_id IS NOT NULL
    THEN
      vr_notice                := dml_dwo_notice.get_record(v_dwo_notice_id);
      vr_payment_register_item := dml_payment_register_item.get_record(par_payment_register_item_id => par_payment_register_item_id);
    
      vr_notice.ids                 := vr_payment_register_item.ids;
      vr_notice.policy_header_id    := find_pol_header_by_regitem(par_payment_register_item_id);
      vr_notice.prolongation_flag   := 1; /*Для пролонгации*/
      vr_notice.rejection_reason_id := NULL;
    
      vr_notice.notice_writeoff_date := get_notice_writeoff_date(vr_notice.notice_writeoff_date);
    
      vr_notice.first_writeoff_date := get_next_plan_date(vr_notice.policy_header_id
                                                         ,vr_notice.notice_writeoff_date); --Значение поля «Дата графика» для следующего ЭПГ по договору
      vr_notice.plan_end_date       := least(get_end_policy_date(vr_notice.policy_header_id)
                                            ,get_card_last_day(vr_notice.card_month
                                                              ,vr_notice.card_year));
    
      vr_notice.doc_status_id     := NULL;
      vr_notice.doc_status_ref_id := NULL;
    
      /*Формирование нового заявления для нового договора*/
      dml_dwo_notice.insert_record(vr_notice);
      --Отключить проверики (Для тестирования)
      --UPDATE doc_status_action t SET t.is_execute = 0 WHERE t.doc_status_allowed_id = 42729;
    
      doc.set_doc_status(vr_notice.dwo_notice_id, 'PROJECT');
      --Перевести в статус "Принято" заявление на отказ
      doc.set_doc_status(vr_notice.dwo_notice_id, 'RECEIVED');
    
      --Завершить старое заявление
      --Указываем причину завершения «Пролонгация»
      UPDATE dwo_notice d
         SET d.rejection_reason_id = 9 /*Пролонгация*/
       WHERE d.dwo_notice_id = v_dwo_notice_id;
      doc.set_doc_status(v_dwo_notice_id, 'STOPED');
    
      --UPDATE doc_status_action t SET t.is_execute = 1 WHERE t.doc_status_allowed_id = 42729;
    
    END IF; --Конец если есть заявление для пролонгации  
  END prolongate_notice;

  -- Author  : Гаргонов Д.А.
  -- Created : 21.10.2014
  -- Purpose : 368935: Прямое списание
  -- Comment : Процедура завершения задания на списание по расторгнутым/прекращенным договорам.
  --           Запускается джобом.
  PROCEDURE stop_writeoff IS
  BEGIN
    FOR vr_rec IN (SELECT dn.dwo_notice_id
                         ,dsr.brief dwo_brief
                         ,dsrp.brief ds_brief
                         ,CASE dsrp.brief
                            WHEN 'STOPED' THEN
                             ins.dml_t_mpos_rejection.get_id_by_brief('POLICY_EXPIRED')
                            ELSE
                             ins.dml_t_mpos_rejection.get_id_by_brief('POLICY_BREAK')
                          END AS reason_id
                   
                     FROM ins.dwo_notice     dn
                         ,ins.document       d
                         ,ins.doc_status_ref dsr
                         ,ins.p_pol_header   h
                         ,ins.document       dp
                         ,ins.doc_status_ref dsrp
                   
                    WHERE dn.dwo_notice_id = d.document_id
                      AND d.doc_status_ref_id = dsr.doc_status_ref_id
                         
                      AND dn.policy_header_id = h.policy_header_id
                      AND dp.document_id = h.policy_id
                      AND dsrp.doc_status_ref_id = dp.doc_status_ref_id
                         
                      AND dsr.brief IN ('RECEIVED', 'REFINE_DETAILS')
                      AND dsrp.brief IN ('RECOVER'
                                        ,'READY_TO_CANCEL'
                                        ,'QUIT_DECL'
                                        ,'TO_QUIT'
                                        ,'TO_QUIT_CHECK_READY'
                                        ,'TO_QUIT_CHECKED'
                                        ,'CANCEL'
                                        ,'QUIT'
                                        ,'QUIT_REQ_QUERY'
                                        ,'QUIT_REQ_GET'
                                        ,'QUIT_TO_PAY'
                                        ,'STOPED'))
    LOOP
    
      UPDATE dwo_notice dn
         SET dn.rejection_reason_id = vr_rec.reason_id
       WHERE dn.dwo_notice_id = vr_rec.dwo_notice_id;
    
      doc.set_doc_status(p_doc_id => vr_rec.dwo_notice_id, p_status_brief => 'STOPED');
    
    END LOOP;
  END stop_writeoff;

  -- Author  : Гаргонов Д.А.
  -- Created : 21.10.2014
  -- Purpose : 368935: Прямое списание
  -- Comment : Процедура удаления графиков списания.
  PROCEDURE delete_dwo_schedule(par_dwo_notice_id ins.dwo_notice.dwo_notice_id%TYPE) IS
  BEGIN
    DELETE dwo_schedule WHERE dwo_notice_id = par_dwo_notice_id;
  END delete_dwo_schedule;

  -- Author  : Григорьев Ю.А.
  -- Created : 12.02.2015
  -- Purpose : 396379: 1910069084 Прямое списание
  -- Comment : Процедура установления запрета на переход статуса Заявления на отказ из Принято в Прекращен.

  PROCEDURE cancel_notice_deny_change_stat(par_dwo_notice_id ins.dwo_notice.dwo_notice_id%TYPE) IS
    v_notice_brief t_dwo_notice_type.brief%TYPE;
  BEGIN
  
    SELECT tdnt.brief
      INTO v_notice_brief
      FROM dwo_notice        dn
          ,t_dwo_notice_type tdnt
     WHERE dn.notice_type_id = tdnt.t_dwo_notice_type_id
       AND dn.dwo_notice_id = par_dwo_notice_id;
  
    IF v_notice_brief = 'REFUSAL' -- Отказ на списание
    THEN
      ex.raise('Заявление на отказ не может быть в статусе Прекращен');
    END IF;
    
  END cancel_notice_deny_change_stat;

  /**
  * Содержит ли период даты списания
  * @author  : Черных М. 03.04.2015
  * @param par_start_date  Дата начала перида
  * @param par_end_date  Дата конца периода
  */
  FUNCTION is_exists_writeoff_date
  (
    par_start_date DATE
   ,par_end_date   DATE
  ) RETURN BOOLEAN IS
    v_result NUMBER;
  BEGIN
    SELECT COUNT(*)
      INTO v_result
      FROM dual
     WHERE EXISTS (SELECT par_start_date + LEVEL - 1 writeoff_date
              FROM dual
             WHERE extract(DAY FROM(par_start_date + LEVEL - 1)) IN (1, 5, 10, 15, 20, 25)
            CONNECT BY par_start_date + LEVEL - 1 <= par_end_date);
    RETURN v_result = 1;
  END is_exists_writeoff_date;

  /**
  * Получить номер статуса Графика списания 
  * @author   Черных М. 03.04.2015
  * @par_dwo_schedule_id  ИД графика списания
  * @return 1-Списано, 2-Не списано, 3-Новый, 4-На списаниии
   */
  FUNCTION schedule_status_code(par_dwo_schedule_id dwo_schedule.dwo_schedule_id%TYPE) RETURN NUMBER IS
    vr_dwo_schedule dml_dwo_schedule.tt_dwo_schedule;
    v_result        NUMBER;
    --Списано
    FUNCTION is_written_off(par_dwo_schedule_id dwo_schedule.dwo_schedule_id%TYPE) RETURN BOOLEAN IS
      v_count NUMBER;
    BEGIN
      SELECT COUNT(*)
        INTO v_count
        FROM dual
       WHERE EXISTS (SELECT NULL
                FROM dwo_operation  dwo
                    ,document       dc
                    ,doc_status_ref dsr
               WHERE dwo.dwo_schedule_id = par_dwo_schedule_id
                 AND dwo.dwo_operation_id = dc.document_id
                 AND dc.doc_status_ref_id = dsr.doc_status_ref_id
                 AND dsr.brief = 'PROCESSED' /*Обработан*/
                 AND dwo.writeoff_description = gc_success /*Результат - успешно*/
              );
      RETURN v_count = 1;
    END is_written_off;
  BEGIN
    /*
    • Если для графика существует успешно списанная операция, то состояние графика 1 – Списано.
    • Если для графика не существует успешно списанной операции и текущая дата больше, чем дата окончания периода списания, то состояние графика 2 – Не списано.
    • Если для графика не существует успешно списанной операции и текущая дата меньше чем дата начала окончания периода списания, то состояние графика 3 – Новый.
    • Если для графика не существует успешно списанной операции и текущая дата попадает в интервал между датой начала периода списания и датой окончания периода списания, то состояние графика 4 – На списании. 
    */
    vr_dwo_schedule := dml_dwo_schedule.get_record(par_dwo_schedule_id);
    CASE
      WHEN is_written_off(par_dwo_schedule_id) THEN
        v_result := 1; --Списано
      WHEN SYSDATE > vr_dwo_schedule.date_end THEN
        v_result := 2; --Не списано
      WHEN SYSDATE < vr_dwo_schedule.date_start THEN
        v_result := 3; --Новый
      WHEN SYSDATE BETWEEN vr_dwo_schedule.date_start AND vr_dwo_schedule.date_end THEN
        v_result := 4; --На списании
    END CASE;
  
    RETURN v_result;
  END schedule_status_code;

  /**
  * Получить название статуса Графика списания 
  * @author   Черных М. 03.04.2015
  * @par_dwo_schedule_id  ИД графика списания
  * @return 1-Списано, 2-Не списано, 3-Новый, 4-На списании
   */
  FUNCTION schedule_status_name(par_dwo_schedule_id dwo_schedule.dwo_schedule_id%TYPE) RETURN VARCHAR2 IS
    v_schedule_status_name VARCHAR2(100);
  BEGIN
  
    CASE schedule_status_code(par_dwo_schedule_id)
      WHEN 1 THEN
        v_schedule_status_name := 'Списано';
      WHEN 2 THEN
        v_schedule_status_name := 'Не списано';
      WHEN 3 THEN
        v_schedule_status_name := 'Новый';
      WHEN 4 THEN
        v_schedule_status_name := 'На списании';
      ELSE
        ex.raise_custom('Неверный код статуса');
    END CASE;
    RETURN v_schedule_status_name;
  END schedule_status_name;

END pkg_direct_writeoff;
/

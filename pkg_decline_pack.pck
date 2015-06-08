CREATE OR REPLACE PACKAGE pkg_decline_pack IS

  -- Author  : Черных М.
  -- Created : 27.01.2015 
  -- Purpose : Пакетная обработка прекращения

  /**
   * Создание нового пакета обработки
   * @author  Черных М. 27.1.2015
   -- %param par_t_decline_pack_type_id  ИД типа пакета обработки
  */
  PROCEDURE create_decline_pack(par_t_decline_pack_type_id t_decline_pack_type.t_decline_pack_type_id%TYPE);
  /**
   * Удаление  пакета обработки и его детализации
   * @author  Черных М. 29.1.2015
   -- %param par_t_decline_pack_type_id  ИД типа пакета обработки
  */
  PROCEDURE delete_decline_pack(par_t_decline_pack_type_id t_decline_pack_type.t_decline_pack_type_id%TYPE);

  /**
   * Обработка пакета обработки построчная
   * @author  Черных М. 10.2.2015
   -- %param par_t_decline_pack_type_id  ИД типа пакета обработки
  */

  PROCEDURE process_decline_pack_detail(par_p_decline_pack_detail_id p_decline_pack_detail.p_decline_pack_detail_id%TYPE);
  /**
   * Прекращение договора страхования
   * @author  Черных М. 27.1.2015
   -- %param par_decline_pack_detail_id  ИД детализации
   -- %param par_result Рузельтат
   -- %param par_commentary Комментарий
  */
  PROCEDURE quit_policy_by_detail_id
  (
    par_decline_pack_detail_id p_decline_pack_detail.p_decline_pack_detail_id%TYPE
   ,par_result                 OUT p_decline_pack_detail.result%TYPE
   ,par_commentary             OUT p_decline_pack_detail.commentary%TYPE
  );

  /**
   * Перевод статуса договора (то что делают пользователи руками, выполняется автоматически)
   * @author  Черных М. 27.1.2015
   -- %param par_decline_pack_detail_id  ИД детализации
   -- %param par_result Рузельтат
   -- %param par_commentary Комментарий
  */
  PROCEDURE set_next_status
  (
    par_decline_pack_detail_id p_decline_pack_detail.p_decline_pack_detail_id%TYPE
   ,par_result                 OUT p_decline_pack_detail.result%TYPE
   ,par_commentary             OUT p_decline_pack_detail.commentary%TYPE
  );

  /**
   * Достижение целевого статуса (целевой статус - "Прекращен")
   * @author  Черных М. 28.1.2015
   -- %param par_decline_pack_detail_id  ИД детализации
   -- %param par_result Рузельтат
   -- %param par_commentary Комментарий
  */
  PROCEDURE achieve_target_status
  (
    par_decline_pack_detail_id p_decline_pack_detail.p_decline_pack_detail_id%TYPE
   ,par_result                 OUT p_decline_pack_detail.result%TYPE
   ,par_commentary             OUT p_decline_pack_detail.commentary%TYPE
  );

  /*
  * @author  Черных М. 20.2.2015
  * Получить статус пакета 
    0 - не обработан, если хоть одна строка детализации не обработана;
    1- обработан, когда все строки детализации обработаны
    -- %param par_p_decline_pack_id ИД пакета
  */
  FUNCTION get_process_status(par_p_decline_pack_id p_decline_pack.p_decline_pack_id%TYPE)
    RETURN p_decline_pack.process_status%TYPE;

END pkg_decline_pack;
/
CREATE OR REPLACE PACKAGE BODY pkg_decline_pack IS

  gc_new   CONSTANT p_decline_pack_detail.result%TYPE := 0; -- Результат вычисления: Новый (статус ДС)
  gc_ok    CONSTANT p_decline_pack_detail.result%TYPE := 1; -- Результат вычисления: ОК
  gc_error CONSTANT p_decline_pack_detail.result%TYPE := 2; -- Результат вычисления: Ошибка

  /**
   * Создание нового пакета обработки
   * @author  Черных М. 27.1.2015
   -- %param par_t_decline_pack_type_id  ИД типа пакета обработки
  */
  PROCEDURE create_decline_pack(par_t_decline_pack_type_id t_decline_pack_type.t_decline_pack_type_id%TYPE) IS
    v_cur                    SYS_REFCURSOR;
    v_policy_id              p_policy.policy_id%TYPE;
    v_p_pol_change_notice_id p_pol_change_notice.p_pol_change_notice_id%TYPE;
  
    v_p_decline_pack_id    p_decline_pack.p_decline_pack_id%TYPE;
    vr_t_decline_pack_type dml_t_decline_pack_type.tt_t_decline_pack_type;
    c_required_col_names   tt_one_col := tt_one_col('POLICY_ID', 'P_POL_CHANGE_NOTICE_ID'); --список обязательных полей
    v_was_records_flag     BOOLEAN := FALSE; --Флаг, что в детализации есть записи
    /*Проверка наличия обязательных полей в обзорах*/
    FUNCTION is_required_cols_exists(par_table_name VARCHAR2) RETURN BOOLEAN IS
      v_count NUMBER;
    BEGIN
      SELECT COUNT(*)
        INTO v_count
        FROM user_tab_cols t
       WHERE t.table_name = par_table_name
         AND t.column_name IN
             (SELECT column_value FROM TABLE(CAST(c_required_col_names AS tt_one_col)));
      RETURN v_count = c_required_col_names.count;
    
    END is_required_cols_exists;
    /*Вывести название полей в строчку*/
    FUNCTION get_required_cols_names RETURN VARCHAR2 IS
      v_str VARCHAR2(4000);
    BEGIN
      FOR i IN 1 .. c_required_col_names.count
      LOOP
        v_str := v_str || c_required_col_names(i) || ', ';
      END LOOP;
      RETURN regexp_replace(v_str, ', $');
    END get_required_cols_names;
  
  BEGIN
  
    assert(par_t_decline_pack_type_id IS NULL
          ,'Не указано значение ID типа пакета');
    vr_t_decline_pack_type := dml_t_decline_pack_type.get_record(par_t_decline_pack_type_id => par_t_decline_pack_type_id);
    assert(NOT is_required_cols_exists(vr_t_decline_pack_type.view_name)
          ,'В обзорах отсутствуют обязательные поля ' || get_required_cols_names());
    SAVEPOINT before_creation;
    /*Создание пакета*/
    dml_p_decline_pack.insert_record(par_t_decline_pack_type_id => par_t_decline_pack_type_id
                                    ,par_created_by             => safety.curr_sys_user
                                    ,par_created_at             => SYSDATE
                                    ,par_p_decline_pack_id      => v_p_decline_pack_id);
  
    OPEN v_cur FOR 'select ' || get_required_cols_names || ' from ' || vr_t_decline_pack_type.view_name;
    LOOP
      FETCH v_cur
        INTO v_policy_id
            ,v_p_pol_change_notice_id;
      EXIT WHEN v_cur%NOTFOUND;
    
      /*Добалвение ДС для пакетной обработки*/
      dml_p_decline_pack_detail.insert_record(par_p_decline_pack_id      => v_p_decline_pack_id
                                             ,par_p_policy_id            => v_policy_id /*ИД активной версии ДС*/
                                             ,par_result                 => gc_new /*Новый*/
                                             ,par_doc_status_id          => doc.get_last_doc_status_id(v_policy_id)
                                             ,par_process_date           => NULL
                                             ,par_commentary             => NULL
                                             ,par_p_pol_change_notice_id => v_p_pol_change_notice_id);
      v_was_records_flag := TRUE;
    END LOOP;
    CLOSE v_cur;
  
    --Не формируем пустые пакеты
    IF NOT v_was_records_flag
    THEN
      ROLLBACK TO before_creation;
      ex.raise_custom('Нет данных для формирования пакета. Формирование пустого пакета запрещено');
    END IF;
  
  EXCEPTION
    WHEN OTHERS THEN
      IF v_cur%ISOPEN
      THEN
        CLOSE v_cur;
      END IF;
      RAISE;
  END create_decline_pack;

  /**
   * Удаление  пакета обработки и его детализации
   * @author  Черных М. 29.1.2015
   -- %param par_t_decline_pack_type_id  ИД типа пакета обработки
  */
  PROCEDURE delete_decline_pack(par_t_decline_pack_type_id t_decline_pack_type.t_decline_pack_type_id%TYPE) IS
  BEGIN
    DELETE FROM p_decline_pack_detail pd WHERE pd.p_decline_pack_id = par_t_decline_pack_type_id;
    DELETE FROM p_decline_pack p WHERE p.p_decline_pack_id = par_t_decline_pack_type_id;
  END delete_decline_pack;

  /**
   * Обработка пакета обработки построчная
   * @author  Черных М. 10.2.2015
   -- %param par_t_decline_pack_type_id  ИД типа пакета обработки
  */

  PROCEDURE process_decline_pack_detail(par_p_decline_pack_detail_id p_decline_pack_detail.p_decline_pack_detail_id%TYPE) IS
    vr_t_decline_pack_type   dml_t_decline_pack_type.tt_t_decline_pack_type;
    vr_p_decline_pack_detail dml_p_decline_pack_detail.tt_p_decline_pack_detail;
    vr_p_decline_pack        dml_p_decline_pack.tt_p_decline_pack;
    v_result                 p_decline_pack_detail.result%TYPE;
    v_commentary             p_decline_pack_detail.commentary%TYPE;
    /*Проверка: заблокирована ли версия ДС другимм пользователем*/
    FUNCTION is_policy_locked(par_policy_id p_policy.policy_id%TYPE) RETURN BOOLEAN IS
      v_dummy   p_policy.policy_id%TYPE;
      vr_policy dml_p_policy.tt_p_policy;
    BEGIN
      vr_policy := dml_p_policy.get_record(par_policy_id => par_policy_id);
    
      SELECT ph.policy_header_id
        INTO v_dummy
        FROM p_pol_header ph
       WHERE ph.policy_header_id = vr_policy.pol_header_id
         FOR UPDATE NOWAIT;
    
      RETURN(FALSE);
    EXCEPTION
      WHEN pkg_oracle_exceptions.resource_busy_nowait THEN
        RETURN(TRUE);
      WHEN no_data_found THEN
        RETURN(FALSE);
    END is_policy_locked;
  
    --Проверка, что заявление отменено
    FUNCTION is_notice_cancelled(par_p_pol_change_notice_id p_pol_change_notice.p_pol_change_notice_id%TYPE)
      RETURN BOOLEAN IS
      v_count NUMBER;
    BEGIN
      SELECT COUNT(*)
        INTO v_count
        FROM dual
       WHERE EXISTS (SELECT NULL
                FROM document       d
                    ,doc_status_ref dsr
               WHERE d.document_id = par_p_pol_change_notice_id
                 AND d.doc_status_ref_id = dsr.doc_status_ref_id
                 AND dsr.brief = 'CANCEL');
    
      RETURN v_count = 1;
    END is_notice_cancelled;
  
  BEGIN
    /*Найти детали*/
    vr_p_decline_pack_detail := dml_p_decline_pack_detail.get_record(par_p_decline_pack_detail_id => par_p_decline_pack_detail_id);
    vr_p_decline_pack        := dml_p_decline_pack.get_record(par_p_decline_pack_id => vr_p_decline_pack_detail.p_decline_pack_id);
    vr_t_decline_pack_type   := dml_t_decline_pack_type.get_record(par_t_decline_pack_type_id => vr_p_decline_pack.t_decline_pack_type_id);
  
    --Проверка, что ДС заблокирован другим пользоватлем
    IF is_policy_locked(par_policy_id => vr_p_decline_pack_detail.p_policy_id)
    THEN
      vr_p_decline_pack_detail.process_date := SYSDATE;
      vr_p_decline_pack_detail.result       := gc_error;
      vr_p_decline_pack_detail.commentary   := 'Договор открыт на редактирование другим пользователем. Обработка невозможна';
      /*Переводим и заявление, если есть на него ссылка*/
      IF vr_p_decline_pack_detail.p_pol_change_notice_id IS NOT NULL
      THEN
        doc.set_doc_status(p_doc_id       => vr_p_decline_pack_detail.p_pol_change_notice_id
                          ,p_status_brief => 'NOT_PROCESSED');
      END IF;
    
    ELSIF
    /*Если заявление было отменено, то помечаем детализацию как "Обработано успешно"*/
     is_notice_cancelled(par_p_pol_change_notice_id => vr_p_decline_pack_detail.p_pol_change_notice_id)
    THEN
      vr_p_decline_pack_detail.process_date := SYSDATE;
      vr_p_decline_pack_detail.result       := gc_ok;
      vr_p_decline_pack_detail.commentary   := 'Заявление отменено';
    ELSE
      /*Выполнить процедуру обработки записи*/
      EXECUTE IMMEDIATE 'begin ' || vr_t_decline_pack_type.procedure_name ||
                        '(:param_id, :result_out, :commentary_out); end;'
        USING IN vr_p_decline_pack_detail.p_decline_pack_detail_id, OUT v_result, OUT v_commentary;
      /*Перезапросить данные после выполнения процедуры (т.к. меняются внутри)*/
      vr_p_decline_pack_detail := dml_p_decline_pack_detail.get_record(par_p_decline_pack_detail_id => par_p_decline_pack_detail_id);
    
      /*Статус, достигрутый в результате обработки*/
      vr_p_decline_pack_detail.doc_status_id := doc.get_last_doc_status_id(p_doc => vr_p_decline_pack_detail.p_policy_id);
      vr_p_decline_pack_detail.process_date  := SYSDATE;
      vr_p_decline_pack_detail.result        := v_result;
      vr_p_decline_pack_detail.commentary    := ex.get_ora_trimmed_errmsg(v_commentary);
    END IF;
    /*Обовить данные с результатами*/
    dml_p_decline_pack_detail.update_record(vr_p_decline_pack_detail);
  END process_decline_pack_detail;

  /**
   * Прекращение договора страхования
   * @author  Черных М. 27.1.2015
   -- %param par_decline_pack_detail_id  ИД детализации
   -- %param par_result Рузельтат
   -- %param par_commentary Комментарий
  */
  PROCEDURE quit_policy_by_detail_id
  (
    par_decline_pack_detail_id p_decline_pack_detail.p_decline_pack_detail_id%TYPE
   ,par_result                 OUT p_decline_pack_detail.result%TYPE
   ,par_commentary             OUT p_decline_pack_detail.commentary%TYPE
  ) IS
    vr_p_decline_pack_detail dml_p_decline_pack_detail.tt_p_decline_pack_detail;
    v_new_version_id         p_policy.policy_id%TYPE;
    vr_doc_status            dml_doc_status.tt_doc_status;
    vr_doc_status_ref        dml_doc_status_ref.tt_doc_status_ref;
  BEGIN
    vr_p_decline_pack_detail := dml_p_decline_pack_detail.get_record(par_p_decline_pack_detail_id => par_decline_pack_detail_id);
    vr_doc_status            := dml_doc_status.get_record(par_doc_status_id => vr_p_decline_pack_detail.doc_status_id);
    vr_doc_status_ref        := dml_doc_status_ref.get_record(par_doc_status_ref_id => vr_doc_status.doc_status_ref_id);
  
    /*Если новый, то создется версия прекращения
    или если, обработан с ошибкой, но статус не входит в перечень для процедуры достижения целевого статуса,
    чтобы была возможность повторно обрабатывать, если не создалась версия прекращения
    */
    IF vr_p_decline_pack_detail.result = gc_new /*Новый*/
       OR (vr_p_decline_pack_detail.result = gc_error AND
       vr_doc_status_ref.brief NOT IN ('TO_QUIT'
                                          ,'TO_QUIT_AWAITING_USVE'
                                          ,'TO_QUIT_CHECK_READY'
                                          ,'TO_QUIT_CHECKED'
                                          ,'QUIT_REQ_QUERY'
                                          ,'QUIT_REQ_GET'
                                          ,'DECLINE_CALCULATION'
                                          ,'TO_QUIT_AWAITING_VS'))
    THEN
      --Создаем версию прекращения
      pkg_policy_decline.create_decline_policy(par_decline_pack_detail_id => par_decline_pack_detail_id
                                              ,par_result                 => par_result
                                              ,par_commentary             => par_commentary
                                              ,par_new_policy_id          => v_new_version_id);
    
      /*Если версия Прекращения успешно создана, то переводим ее по статусам*/
      IF doc.get_last_doc_status_brief(v_new_version_id) = 'TO_QUIT' /*К прекращению*/
      THEN
        /*Перевод ДС по статусам до целевого "Прекращен"*/
        pkg_decline_pack.achieve_target_status(par_decline_pack_detail_id => par_decline_pack_detail_id
                                              ,par_result                 => par_result
                                              ,par_commentary             => par_commentary);
      END IF;
    ELSE
      /*Перевод ДС по статусам до целевого "Прекращен"*/
      pkg_decline_pack.achieve_target_status(par_decline_pack_detail_id => par_decline_pack_detail_id
                                            ,par_result                 => par_result
                                            ,par_commentary             => par_commentary);
    
    END IF;
  END quit_policy_by_detail_id;

  /**
   * Перевод статуса договора (то что делают пользователи руками, выполняется автоматически)
   * @author  Черных М. 27.1.2015
   -- %param par_decline_pack_detail_id  ИД детализации
   -- %param par_result Рузельтат
   -- %param par_commentary Комментарий
  */
  PROCEDURE set_next_status
  (
    par_decline_pack_detail_id p_decline_pack_detail.p_decline_pack_detail_id%TYPE
   ,par_result                 OUT p_decline_pack_detail.result%TYPE
   ,par_commentary             OUT p_decline_pack_detail.commentary%TYPE
  ) IS
    vr_p_decline_pack_detail dml_p_decline_pack_detail.tt_p_decline_pack_detail;
    v_doc_status_brief       doc_status_ref.brief%TYPE;
  
    /*Обработка ДС в "Расчет формы прекращения"*/
    PROCEDURE to_decline_calculation
    (
      par_p_decline_pack_detail dml_p_decline_pack_detail.tt_p_decline_pack_detail
     ,par_result                OUT p_decline_pack_detail.result%TYPE
     ,par_commentary            OUT p_decline_pack_detail.commentary%TYPE
    ) IS
      v_result_status_brief doc_status_ref.brief%TYPE; --Статус после выполения процедуры
    BEGIN
      /*Переводим активную версию ДС в  определнный статус*/
      BEGIN
        SAVEPOINT before_change;
        v_result_status_brief := 'TO_QUIT'; --К прекращению
        doc.set_doc_status(p_doc_id       => par_p_decline_pack_detail.p_policy_id
                          ,p_status_brief => v_result_status_brief);
      
        /*Переводим и заявление, если есть на него ссылка*/
        IF vr_p_decline_pack_detail.p_pol_change_notice_id IS NOT NULL
        THEN
          doc.set_doc_status(p_doc_id       => par_p_decline_pack_detail.p_pol_change_notice_id
                            ,p_status_brief => v_result_status_brief);
        END IF;
        par_result := gc_new;
      EXCEPTION
        WHEN OTHERS THEN
          ROLLBACK TO before_change;
          par_result     := gc_error;
          par_commentary := dbms_utility.format_error_stack;
      END;
    END to_decline_calculation;
  
    /*Обработка ДС в "К прекращению"*/
    PROCEDURE to_quit
    (
      par_p_decline_pack_detail dml_p_decline_pack_detail.tt_p_decline_pack_detail
     ,par_result                OUT p_decline_pack_detail.result%TYPE
     ,par_commentary            OUT p_decline_pack_detail.commentary%TYPE
    ) IS
      v_result_status_brief doc_status_ref.brief%TYPE; --Статус после выполения процедуры
    BEGIN
      v_result_status_brief := 'TO_QUIT_CHECK_READY'; --Прекращен. Готов для проверки
      /*Переводим активную версию ДС в  определнный статус*/
      BEGIN
        SAVEPOINT before_change;
      
        doc.set_doc_status(p_doc_id       => par_p_decline_pack_detail.p_policy_id
                          ,p_status_brief => v_result_status_brief);
      
        /*Переводим и заявление, если есть на него ссылка*/
        IF vr_p_decline_pack_detail.p_pol_change_notice_id IS NOT NULL
        THEN
          doc.set_doc_status(p_doc_id       => par_p_decline_pack_detail.p_pol_change_notice_id
                            ,p_status_brief => v_result_status_brief);
        END IF;
        /*продвинулись на один статус вперед (помечаем как Новый)*/
        par_result := gc_new;
      
      EXCEPTION
        WHEN OTHERS THEN
          ROLLBACK TO before_change;
          par_result     := gc_error;
          par_commentary := dbms_utility.format_error_stack;
      END;
    
    END to_quit;
  
    /*Обработка ДС в "К прекращению. Ожидает решения УСВЭ"*/
    PROCEDURE to_quit_awaiting_usve
    (
      par_p_decline_pack_detail dml_p_decline_pack_detail.tt_p_decline_pack_detail
     ,par_result                OUT p_decline_pack_detail.result%TYPE
     ,par_commentary            OUT p_decline_pack_detail.commentary%TYPE
    ) IS
      v_result_status_brief doc_status_ref.brief%TYPE; --Статус после выполения процедуры
    BEGIN
      /*Переводим активную версию ДС в  определнный статус*/
      BEGIN
        SAVEPOINT before_change;
        v_result_status_brief := 'DECLINE_CALCULATION';
      
        doc.set_doc_status(p_doc_id       => par_p_decline_pack_detail.p_policy_id
                          ,p_status_brief => v_result_status_brief);
      
        /*Переводим и заявление, если есть на него ссылка*/
        IF vr_p_decline_pack_detail.p_pol_change_notice_id IS NOT NULL
        THEN
          doc.set_doc_status(p_doc_id       => par_p_decline_pack_detail.p_pol_change_notice_id
                            ,p_status_brief => v_result_status_brief);
        END IF;
        par_result := gc_new;
      EXCEPTION
        WHEN OTHERS THEN
          ROLLBACK TO before_change;
          par_result     := gc_ok; --Успешно обработан, если дошел до этого статуса, и дальше не получилось
          par_commentary := dbms_utility.format_error_stack;
      END;
    END to_quit_awaiting_usve;
  
    /*Обработка ДС в "К прекращению. Ожидает ВС"*/
    PROCEDURE to_quit_awaiting_vs
    (
      par_result     OUT p_decline_pack_detail.result%TYPE
     ,par_commentary OUT p_decline_pack_detail.commentary%TYPE
    ) IS
    BEGIN
      par_result     := gc_error;
      par_commentary := 'По старым ПУ необходим ручной ввод ВС';
    END to_quit_awaiting_vs;
  
    /*Обработка ДС в "К прекращению. Готов для проверки"*/
    PROCEDURE to_quit_check_ready
    (
      par_p_decline_pack_detail dml_p_decline_pack_detail.tt_p_decline_pack_detail
     ,par_result                OUT p_decline_pack_detail.result%TYPE
     ,par_commentary            OUT p_decline_pack_detail.commentary%TYPE
    ) IS
      v_result_status_brief doc_status_ref.brief%TYPE; --Статус после выполения процедуры
    BEGIN
      /*Переводим активную версию ДС в  определнный статус*/
      BEGIN
        SAVEPOINT before_change;
        v_result_status_brief := 'TO_QUIT_CHECKED'; --К прекращению. Проверен
        doc.set_doc_status(p_doc_id       => par_p_decline_pack_detail.p_policy_id
                          ,p_status_brief => v_result_status_brief);
      
        /*Переводим и заявление, если есть на него ссылка*/
        IF vr_p_decline_pack_detail.p_pol_change_notice_id IS NOT NULL
        THEN
          doc.set_doc_status(p_doc_id       => par_p_decline_pack_detail.p_pol_change_notice_id
                            ,p_status_brief => v_result_status_brief);
        END IF;
        /*Если статус не конечный "Прекращен", то продвинулись на один статус вперед (помечаем как Новый)*/
        IF v_result_status_brief != 'QUIT'
        THEN
          par_result := gc_new;
        ELSE
          par_result := gc_ok;
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          ROLLBACK TO before_change;
          par_result     := gc_error;
          par_commentary := dbms_utility.format_error_stack;
      END;
    END to_quit_check_ready;
  
    /*Обработка ДС в "К прекращению. Проверен"*/
    PROCEDURE to_quit_checked
    (
      par_p_decline_pack_detail dml_p_decline_pack_detail.tt_p_decline_pack_detail
     ,par_result                OUT p_decline_pack_detail.result%TYPE
     ,par_commentary            OUT p_decline_pack_detail.commentary%TYPE
    ) IS
      vr_p_policy    dml_p_policy.tt_p_policy;
      v_pol_decline  p_pol_decline.p_pol_decline_id%TYPE;
      vr_pol_decline dml_p_pol_decline.tt_p_pol_decline;
    
      v_result_status_brief doc_status_ref.brief%TYPE; --Статус после выполения процедуры
      /*Проверка наличия корректировочных проводок
        Проверка необходима чтобы проследить корректное определение даты последнего оплаченного взноса для расчета ВС в случае, 
        когда при исключении страховых покрытий не были сформированы сторнирующие проводки (заявка 413562).
      */
      FUNCTION is_correct_saldo_exists(par_policy_id p_policy.policy_id%TYPE) RETURN BOOLEAN IS
        v_count NUMBER;
      BEGIN
        SELECT COUNT(*)
          INTO v_count
          FROM dual
         WHERE EXISTS (SELECT NULL
                  FROM oper        op
                      ,trans       tr
                      ,trans_templ tt
                 WHERE op.oper_id = tr.oper_id
                   AND op.document_id = par_policy_id
                   AND tr.trans_templ_id = tt.trans_templ_id
                   AND tt.brief IN ('Коррект.полож.прем.прошл.лет при расторж.'
                                   ,'Коррект.отриц.прем.прошл.лет при расторж.'));
        RETURN v_count = 1;
      END is_correct_saldo_exists;
    BEGIN
      vr_p_policy    := dml_p_policy.get_record(par_policy_id => par_p_decline_pack_detail.p_policy_id);
      v_pol_decline  := dml_p_pol_decline.get_id_by_p_policy_id(par_p_policy_id => vr_p_policy.policy_id);
      vr_pol_decline := dml_p_pol_decline.get_record(par_p_pol_decline_id => v_pol_decline);
      IF vr_p_policy.return_summ > vr_pol_decline.income_tax_sum
      THEN
        /*Если есть корректировочные проводки, то никуда не продвигаем договор, т.к. будет проверяться вручную*/
        IF is_correct_saldo_exists(vr_p_policy.policy_id)
        THEN
          v_result_status_brief := 'TO_QUIT_CHECKED'; --К прекращению. Проверен
        ELSE
        v_result_status_brief := 'QUIT_REQ_QUERY'; --Прекращен. Запрос реквизитов
        END IF;
      ELSE
        v_result_status_brief := 'QUIT'; --Прекращен
      END IF;
    
      /*Переводим активную версию ДС в  определнный статус*/
      BEGIN
        SAVEPOINT before_change;
        --Если ДС прекращаем, то дата выплаты равна дате акта
        CASE v_result_status_brief
          WHEN 'QUIT' /*Прекращен*/
        THEN
          vr_pol_decline.issuer_return_date := vr_pol_decline.act_date;
          dml_p_pol_decline.update_record(par_record => vr_pol_decline);
            par_result := gc_ok; /*Успешно обработан, если дошли до статуса "Прекращен"*/
          WHEN 'QUIT_REQ_QUERY' /*Прекращен. Запрос реквизитов*/
           THEN
            par_result := gc_new; /*Новый*/
          WHEN 'TO_QUIT_CHECKED' /*К прекращению. Проверен*/
           THEN
            par_result     := gc_error;
            par_commentary := 'Процедурой корректировки сальдо были сформированы проводки. Необходима проверка сумм прекращения';
        ELSE
            par_result     := gc_error;
            par_commentary := 'Автоматический переход из статуса "К прекращению. Проверен" в ' ||
                              v_result_status_brief || ' не предусмотрен';
        END CASE;
      
        IF par_result != gc_error
        THEN
        doc.set_doc_status(p_doc_id       => vr_p_decline_pack_detail.p_policy_id
                          ,p_status_brief => v_result_status_brief);
      
        /*Переводим и заявление, если есть на него ссылка*/
        IF vr_p_decline_pack_detail.p_pol_change_notice_id IS NOT NULL
        THEN
          doc.set_doc_status(p_doc_id       => vr_p_decline_pack_detail.p_pol_change_notice_id
                            ,p_status_brief => v_result_status_brief);
        END IF;
        END IF;
      
      EXCEPTION
        WHEN OTHERS THEN
          ROLLBACK TO before_change;
          par_result     := gc_error;
          par_commentary := dbms_utility.format_error_stack;
      END;
    END to_quit_checked;
  
    /*Обработка ДС в "Прекращен. Запрос реквизитов"*/
    PROCEDURE quit_req_query
    (
      par_p_decline_pack_detail dml_p_decline_pack_detail.tt_p_decline_pack_detail
     ,par_result                OUT p_decline_pack_detail.result%TYPE
     ,par_commentary            OUT p_decline_pack_detail.commentary%TYPE
    ) IS
      v_result_status_brief doc_status_ref.brief%TYPE; --Статус после выполения процедуры
    
      /*Бриф типа заявления*/
      FUNCTION get_notice_type_brief(par_p_pol_change_notice_id p_pol_change_notice.p_pol_change_notice_id%TYPE)
        RETURN t_pol_change_notice_type.brief%TYPE IS
        v_brief t_pol_change_notice_type.brief%TYPE;
      BEGIN
        SELECT tt.brief
          INTO v_brief
          FROM p_pol_change_notice      cn
              ,t_pol_change_notice_type tt
         WHERE cn.p_pol_change_notice_id = par_p_pol_change_notice_id
           AND cn.t_pol_change_notice_type_id = tt.t_pol_change_notice_type_id;
        RETURN v_brief;
      EXCEPTION
        WHEN no_data_found THEN
          RETURN NULL;
      END get_notice_type_brief;
    BEGIN
      /*Переводим активную версию ДС в  определнный статус*/
      BEGIN
        SAVEPOINT before_change;
        v_result_status_brief := 'QUIT_REQ_GET'; --К прекращению. Реквизиты получены
        doc.set_doc_status(p_doc_id       => par_p_decline_pack_detail.p_policy_id
                          ,p_status_brief => v_result_status_brief);
      
        /*Переводим и заявление, если есть на него ссылка*/
        IF vr_p_decline_pack_detail.p_pol_change_notice_id IS NOT NULL
        THEN
          doc.set_doc_status(p_doc_id       => par_p_decline_pack_detail.p_pol_change_notice_id
                            ,p_status_brief => v_result_status_brief);
        END IF;
      
        par_result := gc_new;
      EXCEPTION
        WHEN OTHERS THEN
          ROLLBACK TO before_change;
          --Если типа заявления "Реквизиты на выплату", то статус "Обработан с ошибкой"
          IF get_notice_type_brief(par_p_pol_change_notice_id => par_p_decline_pack_detail.p_pol_change_notice_id) =
             'PAYOFF'
          THEN
            par_result     := gc_error;
            par_commentary := dbms_utility.format_error_stack;
            doc.set_doc_status(p_doc_id       => par_p_decline_pack_detail.p_pol_change_notice_id
                              ,p_status_brief => 'NOT_PROCESSED');
          ELSE
            par_result     := gc_ok; --Тут при ошибке ставим, что "Обработан успешно", т.к. все прекратили только выплатить не можем (реквизитов нет)
            par_commentary := dbms_utility.format_error_stack;
          END IF;
      END;
    END quit_req_query;
  
    /*Обработка ДС в "Прекращен. Реквизиты получены"*/
    PROCEDURE quit_req_get
    (
      par_p_decline_pack_detail dml_p_decline_pack_detail.tt_p_decline_pack_detail
     ,par_result                OUT p_decline_pack_detail.result%TYPE
     ,par_commentary            OUT p_decline_pack_detail.commentary%TYPE
    ) IS
      v_result_status_brief doc_status_ref.brief%TYPE; --Статус после выполения процедуры
    BEGIN
      /*Переводим активную версию ДС в  определнный статус*/
      BEGIN
        SAVEPOINT before_change;
        v_result_status_brief := 'QUIT_TO_PAY'; --Прекращен.К выплате
        doc.set_doc_status(p_doc_id       => par_p_decline_pack_detail.p_policy_id
                          ,p_status_brief => v_result_status_brief);
      
        /*Переводим и заявление, если есть на него ссылка*/
        IF vr_p_decline_pack_detail.p_pol_change_notice_id IS NOT NULL
        THEN
          doc.set_doc_status(p_doc_id       => par_p_decline_pack_detail.p_pol_change_notice_id
                            ,p_status_brief => v_result_status_brief);
        END IF;
      
        par_result := gc_ok; --Успешно обработан
      EXCEPTION
        WHEN OTHERS THEN
          ROLLBACK TO before_change;
          par_result     := gc_error;
          par_commentary := dbms_utility.format_error_stack;
      END;
    END quit_req_get;
  
  BEGIN
    vr_p_decline_pack_detail := dml_p_decline_pack_detail.get_record(par_p_decline_pack_detail_id => par_decline_pack_detail_id);
    /*Определить статус Активной версии ДС*/
    v_doc_status_brief := doc.get_last_doc_status_brief(vr_p_decline_pack_detail.p_policy_id);
    CASE v_doc_status_brief
      WHEN 'DECLINE_CALCULATION' /*Расчет формы прекращения*/
       THEN
        to_decline_calculation(par_p_decline_pack_detail => vr_p_decline_pack_detail
                              ,par_result                => par_result
                              ,par_commentary            => par_commentary);
      WHEN 'TO_QUIT' /*К прекращению*/
       THEN
        to_quit(par_p_decline_pack_detail => vr_p_decline_pack_detail
               ,par_result                => par_result
               ,par_commentary            => par_commentary);
      WHEN 'TO_QUIT_AWAITING_USVE' /*К прекращению. Ожидает решения УСВЭ*/
       THEN
        to_quit_awaiting_usve(par_p_decline_pack_detail => vr_p_decline_pack_detail
                             ,par_result                => par_result
                             ,par_commentary            => par_commentary);
      WHEN 'TO_QUIT_AWAITING_VS' /*К прекращению. Ожидает ВС*/
       THEN
        to_quit_awaiting_vs(par_result => par_result, par_commentary => par_commentary);
      WHEN 'TO_QUIT_CHECK_READY' /*К прекращению. Готов для проверки*/
       THEN
        to_quit_check_ready(par_p_decline_pack_detail => vr_p_decline_pack_detail
                           ,par_result                => par_result
                           ,par_commentary            => par_commentary);
      WHEN 'TO_QUIT_CHECKED' /*К прекращению. Проверен*/
       THEN
        to_quit_checked(par_p_decline_pack_detail => vr_p_decline_pack_detail
                       ,par_result                => par_result
                       ,par_commentary            => par_commentary);
      WHEN 'QUIT_REQ_QUERY' /*Прекращен. Запрос реквизитов*/
       THEN
        quit_req_query(par_p_decline_pack_detail => vr_p_decline_pack_detail
                      ,par_result                => par_result
                      ,par_commentary            => par_commentary);
      WHEN 'QUIT_REQ_GET' /*Прекращен. Реквизиты получены*/
       THEN
        quit_req_get(par_p_decline_pack_detail => vr_p_decline_pack_detail
                    ,par_result                => par_result
                    ,par_commentary            => par_commentary);
      ELSE
        /*Переводим  заявление в статус не обработан, если ошибка*/
        IF vr_p_decline_pack_detail.p_pol_change_notice_id IS NOT NULL
        THEN
          doc.set_doc_status(p_doc_id       => vr_p_decline_pack_detail.p_pol_change_notice_id
                            ,p_status_brief => 'NOT_PROCESSED');
        END IF;
        par_result     := gc_error; --обработан с ошибкой
        par_commentary := 'Активная версия ДС не в статусе Прекращения. Статус "' ||
                          v_doc_status_brief || '"';
    END CASE;
  
  END set_next_status;

  /**
   * Достижение целевого статуса (целевой статус - "Прекращен")
   * @author  Черных М. 28.1.2015
   -- %param par_decline_pack_detail_id  ИД детализации
   -- %param par_result Рузельтат
   -- %param par_commentary Комментарий
  */
  PROCEDURE achieve_target_status
  (
    par_decline_pack_detail_id p_decline_pack_detail.p_decline_pack_detail_id%TYPE
   ,par_result                 OUT p_decline_pack_detail.result%TYPE
   ,par_commentary             OUT p_decline_pack_detail.commentary%TYPE
  ) IS
    v_result NUMBER := 0; /*Новый*/
  BEGIN
    /*Договор либо переведется в конечный статус "Прекращен", либо будет сообщение с ошибкой на определенной стадии*/
    WHILE v_result = 0 /*Пока у договора новый статус, переводим его в следующий*/
    LOOP
      set_next_status(par_decline_pack_detail_id => par_decline_pack_detail_id
                     ,par_result                 => v_result
                     ,par_commentary             => par_commentary);
    END LOOP;
  
    par_result := v_result;
  
  END achieve_target_status;

  /*
  * @author  Черных М. 20.2.2015
  * Получить статус пакета 
    0 - не обработан, если хоть одна строка детализации не обработана;
    1- обработан, когда все строки детализации обработаны
    -- %param par_p_decline_pack_id ИД пакета
  */
  FUNCTION get_process_status(par_p_decline_pack_id p_decline_pack.p_decline_pack_id%TYPE)
    RETURN p_decline_pack.process_status%TYPE IS
    v_count NUMBER;
  BEGIN
    SELECT decode(COUNT(*), 1, 0, 1) /*если есть необработанные, то пакет в статусе 0 - необработан*/
      INTO v_count
      FROM dual
     WHERE EXISTS (SELECT NULL
              FROM p_decline_pack_detail pd
             WHERE pd.p_decline_pack_id = par_p_decline_pack_id
               AND pd.result != 1 /*Есть необработанные записи*/
            );
    RETURN v_count;
  
  END get_process_status;

END pkg_decline_pack;
/

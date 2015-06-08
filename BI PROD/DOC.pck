CREATE OR REPLACE PACKAGE doc IS
  /**
  * Работа с ядром документооборота - создание документов, установление статуса, получение аналитических признаков
  * @author Sergeev D.
  * @version 1
  */

  /**
  * Удаление всех проводок и операций по документу
  * @author Sergeev D.
  * @param p_doc_id ИД документа
  */
  PROCEDURE clear_doc_trans(p_doc_id IN NUMBER);

  /**
  * Создание нового типа статуса документа
  * @author Sergeev D.
  * @param status_brief Сокращение типа статуса
  * @param status_name Наименование типа статуса
  */
  PROCEDURE create_status_ref
  (
    status_brief IN VARCHAR2
   ,status_name  IN VARCHAR2
  );

  /**
  * Установить новый статус документа по ИД статуса
  * @author Sergeev D.
  * @param p_doc_id ИД документа
  * @param p_status_id ИД типа статуса
  * @param p_status_date Дата статуса
  * @param p_status_change_type_id ИД типа изменения статуса
  * @param p_note Примечание к статусу
  * @throw Возвращает сообщение об ошибке в результате проверки
  */
  PROCEDURE set_doc_status
  (
    p_doc_id                IN NUMBER
   ,p_status_id             IN NUMBER
   ,p_status_date           IN DATE DEFAULT SYSDATE
   ,p_status_change_type_id IN NUMBER DEFAULT 2
   ,p_note                  IN VARCHAR2 DEFAULT NULL
  );

  /**
  * Установить новый статус документа по сокращению статуса
  * @author Sergeev D.
  * @param p_doc_id ИД документа
  * @param p_status_brief Сокращение типа статуса
  * @param p_status_date Дата статуса
  * @param p_status_change_type_id ИД типа изменения статуса
  * @param p_note Примечание к статусу
  * @throw Возвращает сообщение об ошибке в результате проверки
  */
  PROCEDURE set_doc_status
  (
    p_doc_id                   IN NUMBER
   ,p_status_brief             IN VARCHAR2
   ,p_status_date              IN DATE DEFAULT SYSDATE
   ,p_status_change_type_brief IN VARCHAR2 DEFAULT 'AUTO'
   ,p_note                     IN VARCHAR2 DEFAULT NULL
  );

  /**
  * Получить свойство возможности изменнеия документа
  * @author Sergeev D.
  * @param doc_id ИД сущности исходного объекта
  * @return ИД типа статуса
  */

  FUNCTION get_doc_update_property(doc_id IN NUMBER) RETURN NUMBER;

  /**
  * Получить свойство возможности изменнеия документа
  * @author Sergeev D.
  * @param doc_id ИД сущности исходного объекта
  * @return ИД типа статуса
  */

  FUNCTION get_doc_delete_property(doc_id IN NUMBER) RETURN NUMBER;

  /**
  * Получить ИД типа текущего статуса документа
  * @author Sergeev D.
  * @param doc_id ИД сущности исходного объекта
  * @param status_date Дата статуса
  * @return ИД типа статуса
  */
  FUNCTION get_doc_status_id
  (
    doc_id      IN NUMBER
   ,status_date IN DATE DEFAULT SYSDATE
  ) RETURN NUMBER;

  /**
  * Получить ИД типа текущего состояния БСО
  * @author Veselek
  * @param doc_id ИД сущности исходного объекта
  * @param status_date Дата статуса
  * @return ИД типа статуса
  */
  FUNCTION get_bso_status_id
  (
    doc_id      IN NUMBER
   ,status_date IN DATE DEFAULT SYSDATE
  ) RETURN NUMBER;

  /**
  * Получить сокращение типа текущего статуса документа
  * @author Sergeev D.
  * @param doc_id ИД сущности исходного объекта
  * @param status_date Дата статуса
  * @return Сокращение типа статуса
  */

  FUNCTION get_doc_status_brief
  (
    doc_id      IN NUMBER
   ,status_date IN DATE DEFAULT SYSDATE
  ) RETURN VARCHAR2;

  /**
  * Получить наименование типа текущего статуса документа
  * @author Sergeev D.
  * @param doc_id ИД сущности исходного объекта
  * @param status_date Дата статуса
  * @return Сокращение типа статуса
  */
  FUNCTION get_doc_status_name
  (
    doc_id      IN NUMBER
   ,status_date IN DATE DEFAULT SYSDATE
  ) RETURN VARCHAR2;

  /**
  * Получить ИД, сокращение и наименование типа текущего статуса документа в выходные параметры
  * @author Sergeev D.
  * @param doc_id ИД сущности исходного объекта
  * @param p_status_id ИД типа статуса
  * @param p_status_brief Сокращение типа статуса
  * @param p_status_name Наименование типа статуса
  * @param status_date Дата статуса
  * @return Сокращение типа статуса
  */
  PROCEDURE get_doc_status
  (
    p_doc_id       IN NUMBER
   ,p_status_id    OUT NUMBER
   ,p_status_brief OUT VARCHAR2
   ,p_status_name  OUT VARCHAR2
   ,p_status_date  IN DATE DEFAULT SYSDATE
  );

  /**
  * Установление рабочей даты в контекст
  * @author Sergeev D.
  * @param curr_date Текущая дата
  */
  PROCEDURE set_current_date(curr_date IN DATE DEFAULT SYSDATE);

  /**
  * Получить сумму по типу суммы исходного документа
  * @author Sergeev D.
  * @param p_doc ИД документа
  * @param p_summ_type ИД типа суммы
  * @return Сумма по типу суммы
  */
  FUNCTION get_summ_type
  (
    p_doc       IN NUMBER
   ,p_summ_type IN NUMBER
  ) RETURN NUMBER;

  /**
  * Получить ИД валюты по типу валюты исходного документа
  * @author Sergeev D.
  * @param p_doc ИД документа
  * @param p_fund_type ИД типа валюты
  * @return ИД валюты по типу валюты
  */
  FUNCTION get_fund_type
  (
    p_doc       IN NUMBER
   ,p_fund_type IN NUMBER
  ) RETURN NUMBER;

  /**
  * Получить ИД объекта по аналитике по типу аналитики исходного документа
  * @author Sergeev D.
  * @param p_doc ИД документа
  * @param p_an_type ИД типа аналитики
  * @return ИД объекта по типу аналитики
  */
  FUNCTION get_an_type
  (
    p_doc     IN NUMBER
   ,p_an_type IN NUMBER
  ) RETURN NUMBER;

  /**
  * Получить дату по типу даты исходного документа
  * @author Sergeev D.
  * @param p_doc ИД документа
  * @param p_date_type ИД типа даты
  * @return Дата по типу даты
  */
  FUNCTION get_date_type
  (
    p_doc       IN NUMBER
   ,p_date_type IN NUMBER
  ) RETURN DATE;

  /**
  * Получить строковое выражение значения произвольного атрибута
  * @author Sergeev D.
  * @param p_source Сокращение сущности
  * @param p_field Сокращение атрибута
  * @param p_obj_id ИД объекта
  * @return Значение атрибута приведенное к строковому значению
  */
  FUNCTION get_attr
  (
    p_source IN VARCHAR2
   ,p_field  IN VARCHAR2
   ,p_obj_id IN NUMBER
  ) RETURN VARCHAR2;

  /**
  * Получить ИД шаблона документа по сокращению
  * @author Kalabukhov A.
  * @param p_brief Сокращение шаблона документа
  * @return ИД шаблона документа
  */
  FUNCTION templ_id_by_brief(p_brief IN VARCHAR2) RETURN NUMBER;

  /**
  * Получить сокращение шаблона документа по ИД шаблона
  * @author Kalabukhov A.
  * @param p_doc_templ_id ИД шаблона документа
  * @return Сокращение шаблона документа
  */
  FUNCTION templ_brief_by_id(p_doc_templ_id IN NUMBER) RETURN VARCHAR2;

  /**
  * Получить сокращение шаблона документа по ИД документа
  * @author Kalabukhov A.
  * @param p_document_id ИД документа
  * @return Сокращение шаблона документа
  */
  FUNCTION get_doc_templ_brief(p_document_id IN NUMBER) RETURN VARCHAR2;

  /**
  * Получить ID шаблона документа по ИД документа
  * @author Капля П.
  * @param par_document_id ИД документа
  * @return id шаблона документа
  */
  FUNCTION get_doc_templ_id(par_document_id IN document.document_id%TYPE)
    RETURN doc_templ.doc_templ_id%TYPE;

  /**
  * Получить ИД типа статуса первого статуса документа
  * @author Sergeev D.
  * @param p_doc ИД документа
  * @return ИД типа статуса документа
  */
  FUNCTION get_first_doc_status(p_doc IN NUMBER) RETURN NUMBER;

  /**
  * Получить ИД последнего статуса документа
  * @author Sergeev D.
  * @param p_doc ИД документа
  * @return ИД статуса документа
  */
  FUNCTION get_last_doc_status_id(p_doc IN NUMBER) RETURN NUMBER;

  /**
  * Получить признак, является ли текущий статус документа последним
  * @author Sergeev D.
  * @param p_doc ИД документа
  * @return Признак (1/0)
  */
  FUNCTION is_last_doc_status(p_doc IN NUMBER) RETURN NUMBER;

  /*
    Получение ID статуса по сокращению
    %auth Байтин А.
    %param par_doc_status_brief Сокращенное название статуса
    %return ID статуса
  */
  FUNCTION get_doc_status_ref_id(par_doc_status_brief doc_status_ref.brief%TYPE)
    RETURN doc_status_ref.doc_status_ref_id%TYPE;

  /**
  * Получить ИД статуса документа на дату
  * @author Sergeev D.
  * @param p_doc ИД документа
  * @param status_date Дата статуса
  * @return ИД статуса документа
  */
  FUNCTION get_doc_status_rec_id
  (
    doc_id      IN NUMBER
   ,status_date IN DATE DEFAULT SYSDATE
  ) RETURN NUMBER;

  /**
  * Получить дату статуса документа
  * @author Mirovich M.
  * @param doc_id -  ИД документа
  * @param st - статус
  * @return  - дата статуса
  */
  FUNCTION get_status_date
  (
    doc_id NUMBER
   ,st     VARCHAR2
  ) RETURN DATE;

  /**
  * Получить данные о последнем статусе документа
  * @author Ганичев Ф.
  * @param p_document_id -  ИД документа
  * @param p_document_id -  ИД записи о последнем статусе
  * @param p_document_id -  ИД последнего статуса
  * @param p_document_id -  дата начала действия последнего статуса
  */

  PROCEDURE get_last_doc_status_rec
  (
    p_document_id       NUMBER
   ,p_doc_status_id     OUT NUMBER
   ,p_doc_status_ref_id OUT NUMBER
   ,p_start_date        OUT DATE
  );

  /**
  * Получить  последний статус документа
  * @author Ганичев Ф.
  * @param p_document_id -  ИД документа
  * @return краткий идентификатор последнего статуса документа
  */

  FUNCTION get_last_doc_status_brief(p_document_id NUMBER) RETURN doc_status_ref.brief%TYPE;

  ------------------------------------------------------------------------
  -- Получить  последний статус документа
  -- @author Кудрявцев Р.В.
  -- @param p_document_id -  ИД документа
  -- @return наименование Статуса документа
  -------------------------------------------------------------------------

  FUNCTION get_last_doc_status_name(p_document_id NUMBER) RETURN VARCHAR2;

  /**
  * Сторнировать проводки документа
  * @author Пацан О.
  * @param p_document_id -  ИД документа
  */

  PROCEDURE storno_doc_trans(p_document_id IN NUMBER);

  PROCEDURE storno_doc_trans
  (
    p_document_id       IN NUMBER
   ,p_doc_status_ref_id NUMBER
   ,p_obj_id            NUMBER DEFAULT NULL
   ,p_oper_id           NUMBER DEFAULT NULL
  );

  FUNCTION get_last_doc_status_date(p_document_id NUMBER) RETURN DATE;

  FUNCTION get_last_doc_status_ref_id(p_doc IN NUMBER) RETURN NUMBER;
  /* Процедура определяет есть ли проводи для документа в закрытом периоде
  * Установлена у документа с кратким наим. ПП на переход статуса из Проведен в Новый
  * Проверка нахождения проводок в закрытом периоде
  * @autor - Чирков В. Ю. 
  * @param par_doc_id - id документа
  */
  PROCEDURE check_trans_in_close(par_doc_id NUMBER);

END doc;
/
CREATE OR REPLACE PACKAGE BODY doc IS

  gc_pkg_name CONSTANT pkg_trace.t_object_name := 'DOC';

  v_attr          attr%ROWTYPE;
  sql_str         VARCHAR2(4000);
  v_main_doc_flag NUMBER := 0;
  v_main_doc_id   NUMBER;

  PROCEDURE create_status_log
  (
    p_doc_status_id        IN NUMBER
   ,p_doc_status_action_id IN NUMBER
   ,p_is_success           IN NUMBER
   ,p_is_required          IN NUMBER
   ,p_error_message        IN VARCHAR2
  ) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    v_id NUMBER;
  BEGIN
  
    SELECT sq_status_action_log.nextval INTO v_id FROM dual;
  
    INSERT INTO status_action_log_temp sal
      (status_action_log_id
      ,doc_status_id
      ,doc_status_action_id
      ,is_success
      ,is_required
      ,error_message)
    VALUES
      (v_id, p_doc_status_id, p_doc_status_action_id, p_is_success, p_is_required, p_error_message);
  
    COMMIT;
  
  END;

  PROCEDURE transfer_status_log(p_doc_status_id IN NUMBER) IS
  BEGIN
  
    INSERT INTO status_action_log
      (status_action_log_id
      ,doc_status_id
      ,doc_status_action_id
      ,is_success
      ,is_required
      ,error_message)
      SELECT status_action_log_id
            ,doc_status_id
            ,doc_status_action_id
            ,is_success
            ,is_required
            ,error_message status_action_log_temp
        FROM status_action_log_temp
       WHERE doc_status_id = p_doc_status_id;
  
  END;

  -- создать статус
  PROCEDURE create_status_ref
  (
    status_brief IN VARCHAR2
   ,status_name  IN VARCHAR2
  ) IS
  BEGIN
    INSERT INTO doc_status_ref
      (doc_status_ref_id, NAME, brief)
      SELECT sq_doc_status_ref.nextval
            ,status_name
            ,status_brief
        FROM dual;
  END;

  -- очистить все проводки документа
  PROCEDURE clear_doc_trans(p_doc_id IN NUMBER) IS
    CURSOR c_trans IS
      SELECT t.*
        FROM trans       t
            ,oper        o
            ,trans_templ tt
       WHERE t.oper_id = o.oper_id
         AND o.document_id = p_doc_id
         AND t.trans_templ_id = tt.trans_templ_id
         AND tt.is_export = 1;
    v_trans_id trans%ROWTYPE;
  BEGIN
    --Удалить выгруженные проводки из АБС
    OPEN c_trans;
    LOOP
      FETCH c_trans
        INTO v_trans_id;
      EXIT WHEN c_trans%NOTFOUND;
      --oper day
      --if pkg_oper_day.get_date_status(v_Trans_ID.Trans_Date) = 0 then
      --  macrobank_conv.Delete_Doc(v_Trans_ID.Trans_Id);
      --end if;
      --oper day
    
      --      macrobank_conv.Delete_Doc(v_Trans_ID);
    END LOOP;
    CLOSE c_trans;
    --commit;
  
    DELETE FROM trans t
     WHERE t.oper_id IN (SELECT oper_id FROM oper WHERE document_id = p_doc_id)
    /*and pkg_oper_day.get_date_status(t.trans_date) = 0*/
    ;
    BEGIN
      DELETE FROM oper o WHERE o.document_id = p_doc_id;
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;
  END;

  PROCEDURE create_doc_status_rec
  (
    par_document_id           NUMBER
   ,par_doc_status_ref_id     NUMBER
   ,par_status_start_date     DATE
   ,par_status_change_type_id NUMBER
   ,par_note                  VARCHAR2
   ,par_current_status_id     NUMBER
   ,par_doc_status_id_out     OUT NUMBER
  ) IS
    v_status_start_date DATE;
  BEGIN
    -- Обходим ограничение уникальности
    SELECT nvl(MAX(ds.start_date), par_status_start_date) + INTERVAL '1' SECOND
      INTO v_status_start_date
      FROM doc_status ds
     WHERE connect_by_isleaf = 1
     START WITH ds.document_id = par_document_id
            AND ds.start_date = par_status_start_date
    CONNECT BY PRIOR ds.document_id = ds.document_id
           AND PRIOR ds.start_date + INTERVAL '1' SECOND = ds.start_date;
  
	  -- Время выполнения dbms_utility.format_call_stack меньше 1e-4 секунды
    dml_doc_status.insert_record(par_document_id           => par_document_id
                                ,par_doc_status_ref_id     => par_doc_status_ref_id
                                ,par_start_date            => v_status_start_date
                                ,par_user_name             => USER
                                ,par_change_date           => SYSDATE
                                ,par_status_change_type_id => par_status_change_type_id
                                ,par_note                  => par_note
                                ,par_src_doc_status_ref_id => nvl(par_current_status_id, 0)
																,par_call_stack            => substr(dbms_utility.format_call_stack,1,4000)
                                ,par_doc_status_id         => par_doc_status_id_out);
  
    UPDATE document dc
       SET dc.doc_status_id     = par_doc_status_id_out
          ,dc.doc_status_ref_id = par_doc_status_ref_id
     WHERE dc.document_id = par_document_id;
  END create_doc_status_rec;

  -- установить статус документа
  PROCEDURE set_doc_status
  (
    p_doc_id                IN NUMBER
   ,p_status_id             IN NUMBER
   ,p_status_date           IN DATE DEFAULT SYSDATE
   ,p_status_change_type_id IN NUMBER DEFAULT 2
   ,p_note                  IN VARCHAR2 DEFAULT NULL
  ) IS
    v_curr_status_id       NUMBER;
    v_curr_status_brief    VARCHAR2(30);
    is_error               NUMBER;
    err_message            VARCHAR2(2000);
    is_right_ok            NUMBER(1);
    v_dsr                  doc_status_ref%ROWTYPE;
    v_cdsr                 doc_status_ref%ROWTYPE;
    v_sct                  status_change_type%ROWTYPE;
    v_dsal                 doc_status_allowed%ROWTYPE;
    v_ds_id                NUMBER;
    oper_id                NUMBER;
    v_doc                  document%ROWTYPE;
    v_oper_templ           oper_templ%ROWTYPE;
    v_proc                 doc_procedure%ROWTYPE;
    v_mess                 VARCHAR2(4000);
    v_doc_status_action_id NUMBER;
    v_is_required          NUMBER;
    v_brief                VARCHAR2(30);
    v_is_accepted          NUMBER;
    v_ure_id               NUMBER;
    v_uro_id               NUMBER;
    v_status_date          DATE;
    v_doc_status_id        NUMBER;
    v_doc_status_ref_id    NUMBER;
    v_is_annul_status      NUMBER;
    v_storno_doc_status_id NUMBER;
    v_cnt                  NUMBER;
    v_p_status_date        DATE;
    v_is_group_epg         NUMBER(1);
    c_proc_name CONSTANT pkg_trace.t_object_name := 'SET_DOC_STATUS';
    CURSOR c_auto IS
      SELECT dsa.doc_status_action_id
            ,dsa.is_required
            ,dat.brief
            ,dsr.is_accepted
            ,dsa.obj_ure_id
            ,dsa.obj_uro_id
        FROM doc_status_action  dsa
            ,doc_action_type    dat
            ,doc_status_allowed dsal
            ,doc_templ_status   dts
            ,doc_status_ref     dsr
       WHERE dsa.doc_status_allowed_id = v_dsal.doc_status_allowed_id
         AND dsa.doc_action_type_id = dat.doc_action_type_id
         AND dsa.is_execute = 1
         AND dsa.doc_status_allowed_id = dsal.doc_status_allowed_id
         AND dsal.dest_doc_templ_status_id = dts.doc_templ_status_id
         AND dts.doc_status_ref_id = dsr.doc_status_ref_id
       ORDER BY dsa.sort_order;
  
    CURSOR c_manual IS
      SELECT dsa.doc_status_action_id
            ,dsa.is_required
            ,dat.brief
            ,dsr.is_accepted
            ,dsa.obj_ure_id
            ,dsa.obj_uro_id
        FROM doc_status_action_temp dsat
            ,doc_status_action      dsa
            ,doc_action_type        dat
            ,doc_status_allowed     dsal
            ,doc_templ_status       dts
            ,doc_status_ref         dsr
       WHERE dsat.doc_status_action_id = dsa.doc_status_action_id
         AND dsat.ok_execute = 1
         AND dsa.doc_status_allowed_id = v_dsal.doc_status_allowed_id
         AND dsa.doc_action_type_id = dat.doc_action_type_id
         AND dsa.is_execute = 1
         AND dsa.doc_status_allowed_id = dsal.doc_status_allowed_id
         AND dsal.dest_doc_templ_status_id = dts.doc_templ_status_id
         AND dts.doc_status_ref_id = dsr.doc_status_ref_id
       ORDER BY dsa.sort_order;
  
    /* Байтин А.
       Удаление или сторнирование проводок в зависимости от настроек перехода статусов
    */
    PROCEDURE do_delete_or_storno
    (
      par_oper_id oper.oper_id%TYPE
     ,par_delete  BOOLEAN
     ,par_storno  BOOLEAN
    ) IS
    BEGIN
      -- Если установлен флаг "Удаление"
      IF par_delete
      THEN
        -- Попытка удалить
        BEGIN
          DELETE FROM oper op WHERE op.oper_id = par_oper_id;
        EXCEPTION
          -- Если период закрыт
          WHEN pkg_payment.v_closed_period_exception
              --У проводки есть порождённая запись ( Заявка 374058 )
               OR pkg_oracle_exceptions.child_record_found THEN
            IF par_storno
            THEN
              -- Если есть флаг "Сторнирование", сторнируем
              acc_new.storno_trans(par_oper_id);
            ELSE
              -- Если нет флага "Сторнирование", возврат ошибки
              RAISE;
            END IF;
        END;
        -- Если установлен только флаг "Сторнирование", без удаления, сторнируем
      ELSIF par_storno
      THEN
        acc_new.storno_trans(par_oper_id);
      END IF;
    END do_delete_or_storno;
  
  BEGIN
    is_error    := 0;
    err_message := NULL;
  
    SELECT *
      INTO v_sct
      FROM status_change_type sct
     WHERE sct.status_change_type_id = p_status_change_type_id;
  
    --Чирков 25.07.2011 Заявка 93942. Сделать проверку, чтобы Дата устанавливаемого статуса
    --была меньше текущей даты. А также нельзя чтобы дата статуса была больше даты изменения при
    --смене статуса.
    SELECT dt.brief
      INTO v_curr_status_brief
      FROM document  d
          ,doc_templ dt
     WHERE d.document_id = p_doc_id
       AND d.doc_templ_id = dt.doc_templ_id;
  
    IF p_status_date > SYSDATE
    THEN
      IF v_curr_status_brief NOT IN ('ВозвратБСО'
                                    ,'DMS_ACT_SELECT_MED'
                                    ,'ВыдачаБСО'
                                    ,'ПередачаБСО'
                                    ,'ИспорченныеБСО'
                                    ,'СписаниеБСО'
                                    ,'УничтожениеБСО'
                                    ,'УтеряБСО'
                                    ,'ПретензияСС'
                                    ,'C_EVENT'
                                    ,'DMS_ACT_TECH'
                                    ,'ПретензияRE'
                                    ,'СЛИП'
                                    ,'PolicyReins'
                                    ,'PayFakInReinsOff'
                                    ,'PayFakInReins'
                                    ,'RE_TANT'
                                    ,'AccFakInReins'
                                    ,'T_COMMISSION_RULES')
      THEN
        v_p_status_date := SYSDATE;
      ELSE
        v_p_status_date := p_status_date;
      END IF;
    ELSE
      v_p_status_date := p_status_date;
    END IF;
    -------------------------------
    -- Ф.Ганичев. Проверяем дату последнего статуса и корректируем дату установки нового, если
    -- она < даты последнего статуса.Статус нельзя менять где-то посередине!
    get_last_doc_status_rec(p_doc_id, v_doc_status_id, v_doc_status_ref_id, v_status_date);
    IF v_doc_status_id IS NOT NULL
    THEN
      IF v_p_status_date < v_status_date
      THEN
        v_status_date := v_status_date + 1 / 24 / 3600;
      ELSE
        v_status_date := v_p_status_date;
      END IF;
    ELSE
      v_status_date := v_p_status_date;
    END IF;
    --------------------------------------------
  
    SELECT * INTO v_doc FROM document WHERE document_id = p_doc_id;
  
    --проверка существования указанного статуса
    BEGIN
      SELECT * INTO v_dsr FROM doc_status_ref dsr WHERE dsr.doc_status_ref_id = p_status_id;
    EXCEPTION
      WHEN OTHERS THEN
        is_error    := -20001;
        err_message := 'Не найдено описание для статуса ИД#' || TRIM(to_char(p_status_id));
    END;
  
    IF is_error = 0
    THEN
    
      -- Ф.Ганичев
      IF v_doc_status_id IS NULL
      THEN
        v_curr_status_id := doc.get_doc_status_id(p_doc_id);
      ELSE
        v_curr_status_id := v_doc_status_ref_id;
      END IF;
    
      IF v_curr_status_id IS NULL
      THEN
        BEGIN
          SELECT dsal.*
            INTO v_dsal
            FROM document           d
                ,doc_templ_status   sdts
                ,doc_templ_status   ddts
                ,doc_status_allowed dsal
           WHERE d.document_id = p_doc_id
             AND d.doc_templ_id = ddts.doc_templ_id
             AND d.doc_templ_id = sdts.doc_templ_id
             AND dsal.dest_doc_templ_status_id = ddts.doc_templ_status_id
             AND dsal.src_doc_templ_status_id = sdts.doc_templ_status_id
             AND ddts.doc_status_ref_id = p_status_id
             AND sdts.doc_status_ref_id = 0;
        EXCEPTION
          WHEN OTHERS THEN
            is_error    := -20003;
            err_message := 'Не найдено правило перехода из статуса "<Новый документ>" в статус "' ||
                           v_dsr.name || '"';
        END;
      ELSE
        IF p_status_id = v_curr_status_id
        THEN
          is_error    := -20004;
          err_message := 'Исходный и результирующий статусы документа одинаковы!';
        ELSE
          SELECT * INTO v_cdsr FROM doc_status_ref dsr WHERE dsr.doc_status_ref_id = v_curr_status_id;
        
          BEGIN
            SELECT dsal.*
              INTO v_dsal
              FROM document           d
                  ,doc_templ_status   sdts
                  ,doc_templ_status   ddts
                  ,doc_status_allowed dsal
             WHERE d.document_id = p_doc_id
               AND d.doc_templ_id = ddts.doc_templ_id
               AND d.doc_templ_id = sdts.doc_templ_id
               AND dsal.dest_doc_templ_status_id = ddts.doc_templ_status_id
               AND dsal.src_doc_templ_status_id = sdts.doc_templ_status_id
               AND ddts.doc_status_ref_id = p_status_id
               AND sdts.doc_status_ref_id = v_curr_status_id;
          
            SELECT ddts.is_annul_status
              INTO v_is_annul_status
              FROM document           d
                  ,doc_templ_status   sdts
                  ,doc_templ_status   ddts
                  ,doc_status_allowed dsal
             WHERE d.document_id = p_doc_id
               AND d.doc_templ_id = ddts.doc_templ_id
               AND d.doc_templ_id = sdts.doc_templ_id
               AND dsal.dest_doc_templ_status_id = ddts.doc_templ_status_id
               AND dsal.src_doc_templ_status_id = sdts.doc_templ_status_id
               AND ddts.doc_status_ref_id = p_status_id
               AND sdts.doc_status_ref_id = v_curr_status_id;
            IF v_is_annul_status = 0
            THEN
              BEGIN
                SELECT doc_status_id
                  INTO v_storno_doc_status_id
                  FROM (SELECT ds.doc_status_id
                          FROM doc_status ds
                         WHERE ds.document_id = p_doc_id
                           AND ds.doc_status_ref_id = v_curr_status_id
                           AND ds.src_doc_status_ref_id = p_status_id
                         ORDER BY ds.start_date DESC)
                 WHERE rownum < 2;
              EXCEPTION
                WHEN no_data_found THEN
                  NULL;
              END;
            END IF;
          EXCEPTION
            WHEN OTHERS THEN
              is_error    := -20003;
              err_message := 'Не найдено правило перехода из статуса "' || v_cdsr.name ||
                             '" в статус "' || v_dsr.name || '"';
          END;
        END IF;
      END IF;
    
      -- Тип перехода check используется для проверки возможности перехода, например, при создании
      -- новой версии из текущей
      IF v_sct.brief = 'CHECK'
      THEN
        IF is_error = 0
        THEN
          RETURN;
        ELSE
          raise_application_error(is_error, err_message);
        END IF;
      END IF;
      -- пытаемся залочить документ перед сменой статуса
      DECLARE
        v_id NUMBER;
      BEGIN
        SELECT d.document_id
          INTO v_id
          FROM document d
         WHERE d.document_id = p_doc_id
           FOR UPDATE NOWAIT;
      EXCEPTION
        WHEN OTHERS THEN
          raise_application_error(-20000
                                 ,'Документ заблокирован другим пользователем. Изменение статуса невозможно');
      END;
      -- Ф.Ганичев
      -- RETURN не использовать ниже!!!
      IF v_main_doc_flag = 0
      THEN
        acc_new.analitic_cache.delete;
        v_main_doc_flag := 1;
        v_main_doc_id   := p_doc_id;
      END IF;
    
      IF safety.check_right_docstatus(v_dsal.doc_status_allowed_id) = 0
      THEN
        is_error    := -20002;
        err_message := 'У пользователя ' || USER || ' нет прав на изменение статуса документа!';
      END IF;
    
      IF is_error = 0
      THEN
      
        -- Капля П.
				-- Создание записи в истории статусов
        create_doc_status_rec(par_document_id           => p_doc_id
                             ,par_doc_status_ref_id     => p_status_id
                             ,par_status_start_date     => v_status_date
                             ,par_status_change_type_id => p_status_change_type_id
                             ,par_note                  => p_note
                             ,par_current_status_id     => v_curr_status_id
                             ,par_doc_status_id_out     => v_ds_id);
      
        --произвести удаление бухгалтерских операций
        --по предыдущему статусу, если это необходимо
        IF v_dsal.is_del_trans = 1
           OR v_dsal.is_storno_trans = 1
        THEN
          -- Если это ЭПГ для единовременного договора, не сторнируем проводки вообще
          IF v_curr_status_brief = 'PAYMENT'
          THEN
            SELECT COUNT(1)
              INTO v_is_group_epg
              FROM dual
             WHERE EXISTS (SELECT 1
                      FROM ins.p_pol_header    ph
                          ,ins.p_policy        pp
                          ,ins.doc_doc         dd
                          ,ins.t_payment_terms pt
                     WHERE ph.policy_header_id = pp.pol_header_id
                       AND pp.policy_id = dd.parent_id
                       AND dd.child_id = p_doc_id
                       AND pp.payment_term_id = pt.id
                       AND pt.description = 'Единовременно'
                       AND ph.description IN ('Единовременный договор с подключением'
                                             ,'Единовременный договор')
                       AND pp.is_group_flag = 1);
          ELSE
            v_is_group_epg := 0;
          END IF;
          -- Байтин А.
          -- Заявка 254122
          -- Если статус отмечен, как "Статус аннулирования", сторнируем все проводки по документу
          IF v_is_annul_status = 1
             AND v_is_group_epg = 0
          THEN
            FOR vr_opers IN (SELECT o.oper_id FROM oper o WHERE o.document_id = p_doc_id)
            LOOP
              do_delete_or_storno(par_oper_id => vr_opers.oper_id
                                 ,par_delete  => v_dsal.is_del_trans = 1
                                 ,par_storno  => v_dsal.is_storno_trans = 1);
            END LOOP;
            -- Если нет признака "Статус аннулирования", сторнируем проводки,
            -- относящиеся только к предыдущему переходу статусов
          ELSIF v_is_group_epg = 0
          THEN
            FOR vr_opers IN (SELECT o.oper_id
                               FROM oper o
                              WHERE o.document_id = p_doc_id
                                AND o.doc_status_id = v_storno_doc_status_id)
            LOOP
              do_delete_or_storno(par_oper_id => vr_opers.oper_id
                                 ,par_delete  => v_dsal.is_del_trans = 1
                                 ,par_storno  => v_dsal.is_storno_trans = 1);
            END LOOP;
          END IF;
        END IF;
      
        --выполнить действия для статуса
        IF v_sct.brief = 'AUTO'
        THEN
          OPEN c_auto;
        ELSE
          OPEN c_manual;
        END IF;
        LOOP
          IF v_sct.brief = 'AUTO'
          THEN
            FETCH c_auto
              INTO v_doc_status_action_id
                  ,v_is_required
                  ,v_brief
                  ,v_is_accepted
                  ,v_ure_id
                  ,v_uro_id;
            EXIT WHEN c_auto%NOTFOUND;
          ELSE
            FETCH c_manual
              INTO v_doc_status_action_id
                  ,v_is_required
                  ,v_brief
                  ,v_is_accepted
                  ,v_ure_id
                  ,v_uro_id;
            EXIT WHEN c_manual%NOTFOUND;
          END IF;
          CASE
            WHEN v_brief = 'OPER' THEN
              SELECT * INTO v_oper_templ FROM oper_templ WHERE oper_templ_id = v_uro_id;
              BEGIN
                oper_id := acc_new.run_oper_by_template(v_uro_id
                                                       ,p_doc_id
                                                       ,v_doc.ent_id
                                                       ,v_doc.document_id
                                                       ,p_status_id
                                                       ,v_is_accepted);
              
                create_status_log(v_ds_id, v_doc_status_action_id, 1, v_is_required, 'OK');
              
              EXCEPTION
                WHEN OTHERS THEN
                  -- Байтин А.
                  -- Убрал подавление ошибок, все процедуры должны выполняться обязательно,
                  -- флаг обязательного выполнения влияет только на возможность отключать процедуры
                  /*                  IF v_is_required = 1 THEN
                  */
                  is_error    := -20005;
                  err_message := 'Ошибка выполнения операции "' || v_oper_templ.name || '": ' ||
                                 SQLERRM;
                
                  create_status_log(v_ds_id, v_doc_status_action_id, 0, v_is_required, err_message);
                  /*                  ELSE
                                      v_mess := SQLERRM;
                  
                                      create_status_log (v_ds_id, v_doc_status_action_id, 0, v_is_required, 'Ошибка: ' || err_message);
                  
                                    END IF;
                  */
              END;
            WHEN v_brief = 'PROCEDURE' THEN
            
              SELECT * INTO v_proc FROM doc_procedure WHERE doc_procedure_id = v_uro_id;
            
              DECLARE
                v_proc_start TIMESTAMP := systimestamp;
              BEGIN
                pkg_trace.trace(par_trace_obj_name    => gc_pkg_name
                               ,par_trace_subobj_name => c_proc_name
                               ,par_message           => 'Выполнение процедуры: ' || v_proc.name);
              
                EXECUTE IMMEDIATE 'begin ' || v_proc.proc_name || '(:param_id); end;'
                  USING IN p_doc_id;
              
                pkg_trace.add_variable('TIME_ELAPSED'
                                      ,extract(SECOND FROM(systimestamp - v_proc_start)));
                pkg_trace.trace(par_trace_obj_name    => gc_pkg_name
                               ,par_trace_subobj_name => c_proc_name
                               ,par_message           => 'Окончание выполнение процедуры: ' ||
                                                         v_proc.name);
              
                -- Байтин А.
                -- Бесполезная ерунда
                /*UPDATE document
                   SET document_id = p_doc_id
                 WHERE document_id = p_doc_id;
                IF SQL%rowcount != 0 THEN*/
              
                create_status_log(v_ds_id, v_doc_status_action_id, 1, v_is_required, 'OK');
              
                /*END IF;*/
              EXCEPTION
                WHEN OTHERS THEN
                  -- Байтин А.
                  -- Убрал подавление ошибок, все процедуры должны выполняться обязательно,
                  -- флаг обязательного выполнения влияет только на возможность отключать процедуры
                  /*                  IF v_is_required = 1 THEN
                  */
                  is_error    := -20006;
                  err_message := 'Ошибка выполнения процедуры "' || v_proc.name || '": ' ||
                                 ltrim(SQLERRM, 'ORA-' || SQLCODE || ':');
                
                  create_status_log(v_ds_id, v_doc_status_action_id, 0, v_is_required, err_message);
                
                /*                  ELSE
                                    err_message := 'Ошибка выполнения процедуры "' ||
                                                   v_proc.name || '": ' || LTRIM (SQLERRM, 'ORA-'||SQLCODE||':');
                
                                    create_status_log (v_ds_id, v_doc_status_action_id, 0, v_is_required, 'Ошибка: ' || err_message);
                
                                  END IF;
                */
              END;
            WHEN v_brief = 'REPORT' THEN
              NULL;
            ELSE
              NULL;
          END CASE;
        
          EXIT WHEN is_error <> 0;
        
        END LOOP;
      
        IF v_sct.brief = 'AUTO'
        THEN
          CLOSE c_auto;
        ELSE
          CLOSE c_manual;
        END IF;
      
      END IF;
    
    END IF;
  
    IF v_main_doc_id = p_doc_id
    THEN
      v_main_doc_flag := 0;
    END IF;
  
    FOR cur IN (SELECT doc_status_id FROM doc_status ds WHERE doc_status_id = v_ds_id)
    LOOP
      transfer_status_log(v_ds_id);
    END LOOP;
  
    IF is_error <> 0
    THEN
      IF is_error = -20004
         AND v_sct.brief = 'AUTO'
      THEN
        NULL;
      ELSE
        raise_application_error(is_error, err_message);
      END IF;
    END IF;
  
  END;

  -- установить статус документа (по сокращению)
  PROCEDURE set_doc_status
  (
    p_doc_id                   IN NUMBER
   ,p_status_brief             IN VARCHAR2
   ,p_status_date              IN DATE DEFAULT SYSDATE
   ,p_status_change_type_brief IN VARCHAR2 DEFAULT 'AUTO'
   ,p_note                     IN VARCHAR2 DEFAULT NULL
  ) IS
    v_status_id             NUMBER;
    v_status_change_type_id NUMBER;
  BEGIN
    BEGIN
      SELECT d.doc_status_ref_id
        INTO v_status_id
        FROM doc_status_ref d
       WHERE d.brief = p_status_brief;
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20001
                               ,'Не удалось определить статус по брифу');
    END;
  
    BEGIN
      SELECT t.status_change_type_id
        INTO v_status_change_type_id
        FROM status_change_type t
       WHERE t.brief = p_status_change_type_brief;
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20001
                               ,'Не удалось определить тип изменения статуса');
    END;
  
    set_doc_status(p_doc_id, v_status_id, p_status_date, v_status_change_type_id, p_note);
  END;

  -- получить статус документа
  FUNCTION get_doc_status_id
  (
    doc_id      IN NUMBER
   ,status_date DATE DEFAULT SYSDATE
  ) RETURN NUMBER IS
    rv NUMBER;
  BEGIN
    --Каткевич А.Г. Небольшая оптимизация 29.08.2008
    --Каткевич А.Г. Добавил trunc 03.10.2008 чтобы брать последнюю версию документа в рамках одного дня
    --Вар3
    /*SELECT substr(max(TO_CHAR(START_DATE, 'YYYYMMDD')||DOC_STATUS_REF_ID), 9, 30) DOC_STATUS_REF_ID
      INTO rv
      FROM DOC_STATUS
     WHERE DOCUMENT_ID = doc_id
       AND START_DATE <= status_date;
    */
    --Вар2 Самый быстрый, НО не 100% безопасный
    --Каткевич А.Г
    SELECT /*+index_desc(doc UK_DOC_STATUS)*/
     doc_status_ref_id
      INTO rv
      FROM doc_status doc
     WHERE document_id = doc_id
       AND trunc(start_date) <= status_date
       AND rownum = 1;
  
    --Вар1
    /*  SELECT doc_status_ref_id
        INTO rv
        FROM
        (SELECT doc_status_ref_id
          FROM doc_status
         WHERE document_id = doc_id
           AND start_date <= status_date
           ORDER BY start_date DESC)
         WHERE ROWNUM = 1;
    */
    RETURN rv;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN NULL;
      --Старый расчет
    /*    FOR rc IN (SELECT doc_status_ref_id
                 INTO rv
                 FROM doc_status
                WHERE document_id = doc_id
                  AND start_date =
                      (SELECT MAX(start_date)
                         FROM doc_status
                        WHERE start_date <= status_date
                          AND document_id = doc_id)) LOOP
      RETURN rc.doc_status_ref_id;
    END LOOP;
    -- exception
    --        when no_data_found then return null;
    RETURN NULL; */
  END;

  FUNCTION get_bso_status_id
  (
    doc_id      IN NUMBER
   ,status_date DATE DEFAULT SYSDATE
  ) RETURN NUMBER IS
    rv NUMBER;
  BEGIN
    SELECT hist_type_id
      INTO rv
      FROM (SELECT doc.hist_type_id
                  ,doc.bso_id
              FROM bso_hist doc
             WHERE doc.bso_id = doc_id
               AND trunc(doc.hist_date) <= status_date
             ORDER BY doc.hist_date DESC)
     WHERE rownum = 1;
    RETURN rv;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN NULL;
  END;

  FUNCTION get_doc_update_property(doc_id IN NUMBER) RETURN NUMBER IS
  BEGIN
  
    FOR cur IN (SELECT ts.update_allowed
                      ,ts.delete_allowed
                  FROM doc_status       dc
                      ,doc_status_ref   dsr
                      ,doc_templ        t
                      ,doc_templ_status ts
                 WHERE dc.doc_status_id = doc.get_last_doc_status_id(doc_id)
                   AND dsr.doc_status_ref_id = dc.doc_status_ref_id
                   AND t.brief = doc.get_doc_templ_brief(doc_id)
                   AND ts.doc_status_ref_id = dsr.doc_status_ref_id
                   AND ts.doc_templ_id = t.doc_templ_id)
    LOOP
      RETURN cur.update_allowed;
    END LOOP;
  
  END;

  FUNCTION get_doc_delete_property(doc_id IN NUMBER) RETURN NUMBER IS
  BEGIN
  
    FOR cur IN (SELECT ts.update_allowed
                      ,ts.delete_allowed
                  FROM doc_status       dc
                      ,doc_status_ref   dsr
                      ,doc_templ        t
                      ,doc_templ_status ts
                 WHERE dc.doc_status_id = doc.get_last_doc_status_id(doc_id)
                   AND dsr.doc_status_ref_id = dc.doc_status_ref_id
                   AND t.brief = doc.get_doc_templ_brief(doc_id)
                   AND ts.doc_status_ref_id = dsr.doc_status_ref_id
                   AND ts.doc_templ_id = t.doc_templ_id)
    LOOP
      RETURN cur.delete_allowed;
    END LOOP;
  
  END;

  -- получить сокращение статуса документа
  /* Байтин А.
     Старый вариант функции
    FUNCTION get_doc_status_brief(doc_id      IN NUMBER,
                                  status_date IN DATE DEFAULT SYSDATE)
      RETURN VARCHAR2 IS
      rv   VARCHAR2(30);
      s_id NUMBER;
    BEGIN
      s_id := get_doc_status_id(doc_id, status_date);
      IF s_id IS NOT NULL THEN
        SELECT brief
          INTO rv
          FROM doc_status_ref
         WHERE doc_status_ref_id = s_id;
  
        RETURN rv;
      ELSE
        RETURN NULL;
      END IF;
    END;
  */
  FUNCTION get_doc_status_brief
  (
    doc_id      IN NUMBER
   ,status_date IN DATE DEFAULT SYSDATE
  ) RETURN VARCHAR2 IS
    v_doc_status_brief doc_status_ref.brief%TYPE;
  BEGIN
    SELECT brief
      INTO v_doc_status_brief
      FROM doc_status_ref
     WHERE doc_status_ref_id = (SELECT /*+index_desc(doc UK_DOC_STATUS)*/
                                 doc_status_ref_id
                                  FROM doc_status doc
                                 WHERE document_id = doc_id
                                   AND trunc(start_date) <= status_date
                                   AND rownum = 1);
    RETURN v_doc_status_brief;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN NULL;
  END;

  -- получить название статуса документа
  /* Байтин А.
     Старый вариант функции
    FUNCTION get_doc_status_name(doc_id      IN NUMBER,
                                 status_date IN DATE DEFAULT SYSDATE)
      RETURN VARCHAR2 IS
      rv   VARCHAR2(150);
      s_id NUMBER;
    BEGIN
      s_id := get_doc_status_id(doc_id, status_date);
  
      SELECT NAME INTO rv FROM doc_status_ref WHERE doc_status_ref_id = s_id;
  
      RETURN rv;
    EXCEPTION
      WHEN OTHERS THEN
        RETURN NULL;
    END;
  */
  FUNCTION get_doc_status_name
  (
    doc_id      IN NUMBER
   ,status_date IN DATE DEFAULT SYSDATE
  ) RETURN VARCHAR2 IS
    rv VARCHAR2(150);
  BEGIN
    SELECT NAME
      INTO rv
      FROM doc_status_ref
     WHERE doc_status_ref_id = (SELECT /*+index_desc(doc UK_DOC_STATUS)*/
                                 doc_status_ref_id
                                  FROM doc_status doc
                                 WHERE document_id = doc_id
                                   AND trunc(start_date) <= status_date
                                   AND rownum = 1);
    RETURN rv;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  PROCEDURE get_doc_status
  (
    p_doc_id       IN NUMBER
   ,p_status_id    OUT NUMBER
   ,p_status_brief OUT VARCHAR2
   ,p_status_name  OUT VARCHAR2
   ,p_status_date  IN DATE DEFAULT SYSDATE
  ) IS
  BEGIN
    p_status_id := get_doc_status_id(p_doc_id, p_status_date);
    SELECT brief
          ,NAME
      INTO p_status_brief
          ,p_status_name
      FROM doc_status_ref
     WHERE doc_status_ref_id = p_status_id;
  END;

  -- установить в контекст рабочую дату
  PROCEDURE set_current_date(curr_date IN DATE DEFAULT SYSDATE) IS
  BEGIN
    dbms_session.set_context('trs_context', 'current_date', to_char(curr_date, 'YYYYMMDD'));
  END;

  -- скл для получения значения аттрибута
  PROCEDURE get_sql IS
  BEGIN
    IF v_attr.source IS NOT NULL
       AND v_attr.col_name IS NOT NULL
    THEN
      sql_str := 'begin select ' || v_attr.col_name || ' into :ret_val from ' || v_attr.source ||
                 ' where ' || v_attr.source || '_ID = :doc_id; end;';
    ELSIF v_attr.calc IS NOT NULL
    THEN
      sql_str := v_attr.calc;
    ELSE
      raise_application_error(-20000, 'Bad definition of attribute');
    END IF;
  END;

  -- сумма по типу суммы для документа
  FUNCTION get_summ_type
  (
    p_doc       IN NUMBER
   ,p_summ_type IN NUMBER
  ) RETURN NUMBER IS
    ret_val  NUMBER;
    p_ent_id NUMBER;
  BEGIN
  
    SELECT d.ent_id INTO p_ent_id FROM document d WHERE d.document_id = p_doc;
  
    SELECT q.*
      INTO v_attr
      FROM (SELECT a.*
              FROM attr a
             INNER JOIN attr_type aty
                ON aty.attr_type_id = a.attr_type_id
               AND aty.brief = 'OI'
             WHERE a.ent_id = p_ent_id
            UNION ALL
            SELECT a.*
              FROM (SELECT e.ent_id
                          ,e.name
                      FROM entity e
                     START WITH e.ent_id = p_ent_id
                    CONNECT BY PRIOR e.parent_id = e.ent_id) t
             INNER JOIN attr a
                ON a.ent_id = t.ent_id
             INNER JOIN attr_type aty
                ON aty.attr_type_id = a.attr_type_id
               AND aty.brief IN ('F', 'R', 'UR', 'C')) q
          ,attr_summ_type ast
     WHERE ast.summ_type_id = p_summ_type
       AND ast.attr_id = q.attr_id;
  
    get_sql;
  
    EXECUTE IMMEDIATE sql_str
      USING OUT ret_val, IN p_doc;
  
    RETURN ret_val;
  
  EXCEPTION
    WHEN OTHERS THEN
      dbms_output.put_line('Тип суммы:' || p_summ_type || ' ' || SQLERRM);
      RETURN NULL;
  END;

  -- валюта по типу валюты для документа
  FUNCTION get_fund_type
  (
    p_doc       IN NUMBER
   ,p_fund_type IN NUMBER
  ) RETURN NUMBER IS
    ret_val  NUMBER;
    p_ent_id NUMBER;
  BEGIN
  
    SELECT d.ent_id INTO p_ent_id FROM document d WHERE d.document_id = p_doc;
  
    SELECT q.*
      INTO v_attr
      FROM (SELECT a.*
              FROM attr a
             INNER JOIN attr_type aty
                ON aty.attr_type_id = a.attr_type_id
               AND aty.brief = 'OI'
             WHERE a.ent_id = p_ent_id
            UNION ALL
            SELECT a.*
              FROM (SELECT e.ent_id
                          ,e.name
                      FROM entity e
                     START WITH e.ent_id = p_ent_id
                    CONNECT BY PRIOR e.parent_id = e.ent_id) t
             INNER JOIN attr a
                ON a.ent_id = t.ent_id
             INNER JOIN attr_type aty
                ON aty.attr_type_id = a.attr_type_id
               AND aty.brief IN ('F', 'R', 'UR', 'C')) q
          ,attr_fund_type aft
     WHERE aft.fund_type_id = p_fund_type
       AND aft.attr_id = q.attr_id;
  
    get_sql;
  
    EXECUTE IMMEDIATE sql_str
      USING OUT ret_val, IN p_doc;
  
    RETURN ret_val;
  
  EXCEPTION
    WHEN OTHERS THEN
      dbms_output.put_line('Тип валюты:' || p_fund_type || ' ' || SQLERRM);
      RETURN NULL;
  END;

  -- аналитика по типу аналитики для документа
  FUNCTION get_an_type
  (
    p_doc     IN NUMBER
   ,p_an_type IN NUMBER
  ) RETURN NUMBER IS
    ret_val  NUMBER;
    p_ent_id NUMBER;
  BEGIN
  
    SELECT d.ent_id INTO p_ent_id FROM document d WHERE d.document_id = p_doc;
  
    SELECT q.*
      INTO v_attr
      FROM (SELECT a.*
              FROM (SELECT e.ent_id
                          ,e.name
                      FROM entity e
                     START WITH e.ent_id = p_ent_id
                    CONNECT BY PRIOR e.parent_id = e.ent_id) t
             INNER JOIN attr a
                ON a.ent_id = t.ent_id) q
          ,attr_analytic_type aat
     WHERE aat.analytic_type_id = p_an_type
       AND aat.attr_id = q.attr_id;
  
    /*
        select q.*
          into v_attr
          from (select a.*
                  from attr a
                 inner join attr_type aty on aty.attr_type_id = a.attr_type_id
                                         and aty.brief = 'OI'
                 where a.ent_id = p_ent_id
                union all
                select a.*
                  from (select e.ent_id, e.name
                          from entity e
                         start with e.ent_id = p_ent_id
                        connect by prior e.parent_id = e.ent_id) t
                 inner join attr a on a.ent_id = t.ent_id
                 inner join attr_type aty on aty.attr_type_id = a.attr_type_id
                                         and aty.brief in ('F', 'R', 'UR', 'C')) q,
               attr_analytic_type aat
         where aat.analytic_type_id = p_an_type
           and aat.attr_id = q.attr_id;
    */
  
    get_sql;
  
    EXECUTE IMMEDIATE sql_str
      USING OUT ret_val, IN p_doc;
  
    RETURN ret_val;
  
  EXCEPTION
    WHEN OTHERS THEN
      --      dbms_output.put_line('Тип аналитики:' || p_an_type || ' ' || sqlerrm);
      RETURN NULL;
  END;

  -- дата по типу даты для документа
  FUNCTION get_date_type
  (
    p_doc       IN NUMBER
   ,p_date_type IN NUMBER
  ) RETURN DATE IS
    ret_val  DATE;
    p_ent_id NUMBER;
  BEGIN
  
    SELECT d.ent_id INTO p_ent_id FROM document d WHERE d.document_id = p_doc;
  
    SELECT q.*
      INTO v_attr
      FROM (SELECT a.*
              FROM attr a
             INNER JOIN attr_type aty
                ON aty.attr_type_id = a.attr_type_id
               AND aty.brief = 'OI'
             WHERE a.ent_id = p_ent_id
            UNION ALL
            SELECT a.*
              FROM (SELECT e.ent_id
                          ,e.name
                      FROM entity e
                     START WITH e.ent_id = p_ent_id
                    CONNECT BY PRIOR e.parent_id = e.ent_id) t
             INNER JOIN attr a
                ON a.ent_id = t.ent_id
             INNER JOIN attr_type aty
                ON aty.attr_type_id = a.attr_type_id
               AND aty.brief IN ('F', 'R', 'UR', 'C')) q
          ,attr_date_type adt
     WHERE adt.date_type_id = p_date_type
       AND adt.attr_id = q.attr_id;
  
    get_sql;
  
    EXECUTE IMMEDIATE sql_str
      USING OUT ret_val, IN p_doc;
  
    RETURN ret_val;
  
  EXCEPTION
    WHEN OTHERS THEN
      dbms_output.put_line('Тип даты:' || p_date_type || ' ' || SQLERRM);
      RETURN NULL;
  END;

  -- получить значение аттрибута по имени таблицы и обозначению аттрибута
  FUNCTION get_attr
  (
    p_source IN VARCHAR2
   ,p_field  IN VARCHAR2
   ,p_obj_id IN NUMBER
  ) RETURN VARCHAR2 IS
    v_res VARCHAR2(4000);
  BEGIN
    SELECT a.*
      INTO v_attr
      FROM attr a
     WHERE a.source = p_source
       AND a.brief = p_field;
  
    get_sql;
  
    EXECUTE IMMEDIATE sql_str
      USING OUT v_res, IN p_obj_id;
  
    RETURN v_res;
  
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  FUNCTION templ_id_by_brief(p_brief IN VARCHAR2) RETURN NUMBER AS
    v_result NUMBER;
  BEGIN
    SELECT dt.doc_templ_id INTO v_result FROM doc_templ dt WHERE dt.brief = p_brief;
    RETURN v_result;
  EXCEPTION
    WHEN no_data_found THEN
      raise_application_error(-20000
                             ,'Шаблон документа "' || p_brief || '" не найден');
    WHEN OTHERS THEN
      RAISE;
  END;

  FUNCTION templ_brief_by_id(p_doc_templ_id IN NUMBER) RETURN VARCHAR2 AS
    v_result VARCHAR2(150);
  BEGIN
    SELECT dt.brief INTO v_result FROM doc_templ dt WHERE dt.doc_templ_id = p_doc_templ_id;
    RETURN v_result;
  EXCEPTION
    WHEN no_data_found THEN
      raise_application_error(-20000
                             ,'Шаблон документа "' || p_doc_templ_id || '" не найден');
    WHEN OTHERS THEN
      RAISE;
  END;

  FUNCTION get_doc_templ_brief(p_document_id IN NUMBER) RETURN VARCHAR2 IS
    v_ret_val VARCHAR2(50);
    CURSOR cur_find IS
      SELECT dt.brief
        FROM ven_document  d
            ,ven_doc_templ dt
       WHERE dt.doc_templ_id = d.doc_templ_id
         AND d.document_id = p_document_id;
  BEGIN
    OPEN cur_find;
    FETCH cur_find
      INTO v_ret_val;
    IF cur_find%NOTFOUND
    THEN
      CLOSE cur_find;
      v_ret_val := NULL;
      raise_application_error(-20000
                             ,'Шаблон документа ' || p_document_id || ' не найден');
    END IF;
    CLOSE cur_find;
    RETURN(v_ret_val);
  END;

  FUNCTION get_doc_templ_id(par_document_id IN document.document_id%TYPE)
    RETURN doc_templ.doc_templ_id%TYPE IS
    v_doc_templ_id doc_templ.doc_templ_id%TYPE;
  BEGIN
    SELECT d.doc_templ_id INTO v_doc_templ_id FROM document d WHERE d.document_id = par_document_id;
    RETURN v_doc_templ_id;
  EXCEPTION
    WHEN no_data_found THEN
      raise_application_error(-20000
                             ,'Шаблон документа ' || par_document_id || ' не найден');
  END get_doc_templ_id;

  -- получить первый статус документа
  FUNCTION get_first_doc_status(p_doc IN NUMBER) RETURN NUMBER IS
    v_status_id NUMBER;
  BEGIN
    SELECT dsr.doc_status_ref_id INTO v_status_id FROM doc_status_ref dsr WHERE dsr.brief = 'NEW';
    RETURN v_status_id;
  END;

  -- получить признак, есть ли переходы из последнего статуса
  FUNCTION is_last_doc_status(p_doc IN NUMBER) RETURN NUMBER IS
    v_status_id NUMBER;
    i           NUMBER;
    p1          NUMBER;
    p2          DATE;
  BEGIN
    doc.get_last_doc_status_rec(p_doc, p1, v_status_id, p2);
    SELECT COUNT(*)
      INTO i
      FROM doc_status_allowed dsa
          ,doc_templ_status   dts
          ,document           d
     WHERE d.document_id = p_doc
       AND d.doc_templ_id = dts.doc_templ_id
       AND dts.doc_templ_status_id = dsa.src_doc_templ_status_id
       AND dts.doc_status_ref_id = v_status_id;
    IF i = 0
    THEN
      RETURN 1;
    ELSE
      RETURN 0;
    END IF;
  END;

  -- получить ИД последней статусной записи документа
  FUNCTION get_last_doc_status_id(p_doc IN NUMBER) RETURN NUMBER IS
    v_doc_status_id NUMBER;
  BEGIN
    BEGIN
      SELECT doc_status_id
        INTO v_doc_status_id
        FROM (SELECT ds.doc_status_id
                FROM doc_status ds
               WHERE ds.document_id = p_doc
               ORDER BY ds.start_date DESC)
       WHERE rownum < 2;
    EXCEPTION
      WHEN OTHERS THEN
        v_doc_status_id := NULL;
    END;
    RETURN v_doc_status_id;
  END;

  FUNCTION get_last_doc_status_ref_id(p_doc IN NUMBER) RETURN NUMBER IS
    v_doc_status_id     NUMBER;
    v_doc_status_ref_id NUMBER;
  BEGIN
    BEGIN
      v_doc_status_id := get_last_doc_status_id(p_doc);
    
      SELECT doc_status_ref_id
        INTO v_doc_status_ref_id
        FROM doc_status
       WHERE doc_status_id = v_doc_status_id;
    
    EXCEPTION
      WHEN OTHERS THEN
        v_doc_status_ref_id := NULL;
    END;
    RETURN v_doc_status_ref_id;
  END;

  /*
    Получение ID статуса по сокращению
    %auth Байтин А.
    %param par_doc_status_brief Сокращенное название статуса
    %return ID статуса
  */
  FUNCTION get_doc_status_ref_id(par_doc_status_brief doc_status_ref.brief%TYPE)
    RETURN doc_status_ref.doc_status_ref_id%TYPE IS
    v_doc_status_ref_id doc_status_ref.doc_status_ref_id%TYPE;
  BEGIN
    SELECT dsr.doc_status_ref_id
      INTO v_doc_status_ref_id
      FROM doc_status_ref dsr
     WHERE dsr.brief = par_doc_status_brief;
  
    RETURN v_doc_status_ref_id;
  EXCEPTION
    WHEN no_data_found THEN
      raise_application_error(-20001
                             ,'Статуса с сокращением "' || par_doc_status_brief || '" не существует');
    WHEN too_many_rows THEN
      raise_application_error(-20001
                             ,'Существует несколько статусов с сокращением "' || par_doc_status_brief || '"');
  END get_doc_status_ref_id;

  FUNCTION get_doc_status_rec_id
  (
    doc_id      IN NUMBER
   ,status_date IN DATE DEFAULT SYSDATE
  ) RETURN NUMBER IS
    rv NUMBER;
  BEGIN
    /*    FOR rc IN (SELECT doc_status_id
                 INTO rv
                 FROM doc_status
                WHERE document_id = doc_id
                  AND start_date =
                      (SELECT MAX(start_date)
                         FROM doc_status
                        WHERE start_date <= status_date
                          AND document_id = doc_id)) LOOP
      RETURN rc.doc_status_id;
    END LOOP;*/
    SELECT /*+index_desc(doc UK_DOC_STATUS)*/
     doc_status_id
      INTO rv
      FROM doc_status doc
     WHERE document_id = doc_id
       AND trunc(start_date) <= status_date
       AND rownum = 1;
  
    RETURN rv;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN NULL;
      --RETURN NULL;
  END;

  -- Возвращает дату статуса документа
  FUNCTION get_status_date
  (
    doc_id NUMBER
   ,st     VARCHAR2
  ) RETURN DATE IS
    d DATE; -- дата статуса
  BEGIN
    SELECT start_date
      INTO d
      FROM (SELECT ds.start_date
              FROM doc_status     ds
                  ,doc_status_ref dsr
             WHERE dsr.doc_status_ref_id = ds.doc_status_ref_id
               AND dsr.brief = st
               AND ds.document_id = doc_id
             ORDER BY ds.start_date DESC)
     WHERE rownum = 1;
    RETURN(d);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  PROCEDURE get_last_doc_status_rec
  (
    p_document_id       NUMBER
   ,p_doc_status_id     OUT NUMBER
   ,p_doc_status_ref_id OUT NUMBER
   ,p_start_date        OUT DATE
  ) IS
  BEGIN
    SELECT doc_status_id
          ,doc_status_ref_id
          ,start_date
      INTO p_doc_status_id
          ,p_doc_status_ref_id
          ,p_start_date
      FROM (SELECT ds.*
              FROM doc_status ds
             WHERE ds.document_id = p_document_id
             ORDER BY ds.start_date DESC)
     WHERE rownum < 2;
  EXCEPTION
    WHEN no_data_found THEN
      NULL;
  END;

  FUNCTION get_last_doc_status_brief(p_document_id NUMBER) RETURN doc_status_ref.brief%TYPE IS
    v_brief doc_status_ref.brief%TYPE;
  BEGIN
    SELECT dsf.brief
      INTO v_brief
      FROM document       dc
          ,doc_status_ref dsf
     WHERE dc.document_id = p_document_id
       AND dc.doc_status_ref_id = dsf.doc_status_ref_id;
    RETURN v_brief;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN NULL;
  END;

  FUNCTION get_last_doc_status_date(p_document_id NUMBER) RETURN DATE IS
    v_date DATE;
  BEGIN
    SELECT start_date
      INTO v_date
      FROM (SELECT ds.start_date
              FROM doc_status ds
             WHERE ds.document_id = p_document_id
             ORDER BY ds.start_date DESC)
     WHERE rownum < 2;
    RETURN v_date;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN NULL;
  END;

  PROCEDURE storno_doc_trans
  (
    p_document_id       IN NUMBER
   ,p_doc_status_ref_id NUMBER
   ,p_obj_id            NUMBER DEFAULT NULL
   ,p_oper_id           NUMBER DEFAULT NULL
  ) IS
    v_oper_id NUMBER;
  BEGIN
    FOR vr_trans IN (SELECT op.oper_id
                       FROM oper op
                      WHERE op.document_id = p_document_id
                        AND NOT EXISTS (SELECT NULL
                               FROM trans tr
                                   ,trans st
                              WHERE tr.oper_id = op.oper_id
                                AND tr.trans_id = st.storned_id))
    LOOP
      acc_new.storno_trans(par_oper_id => vr_trans.oper_id);
    END LOOP;
  END storno_doc_trans;

  PROCEDURE storno_doc_trans(p_document_id IN NUMBER) IS
    v_status_ref_id NUMBER;
  BEGIN
    -- последний статус, ид операции, тип даты
    SELECT ds.doc_status_ref_id
      INTO v_status_ref_id
      FROM doc_status ds
     WHERE ds.doc_status_id = doc.get_last_doc_status_id(p_document_id);
  
    storno_doc_trans(p_document_id, v_status_ref_id);
  END;
  ------------------------------------------------------------------------
  -- Получить  последний статус документа
  -- @author Кудрявцев Р.В.
  -- @param p_document_id -  ИД документа
  -- @return наименование Статуса документа
  -------------------------------------------------------------------------

  FUNCTION get_last_doc_status_name(p_document_id NUMBER) RETURN VARCHAR2 IS
    v_name VARCHAR2(255);
  BEGIN
    SELECT NAME
      INTO v_name
      FROM (SELECT dsf.*
              FROM doc_status     ds
                  ,doc_status_ref dsf
             WHERE ds.document_id = p_document_id
               AND ds.doc_status_ref_id = dsf.doc_status_ref_id
             ORDER BY ds.start_date DESC)
     WHERE rownum < 2;
  
    RETURN v_name;
  
  EXCEPTION
    WHEN no_data_found THEN
      RETURN NULL;
  END get_last_doc_status_name;

  /* Процедура определяет есть ли проводи для документа в закрытом периоде
  * Установлена у документа с кратким наим. ПП на переход статуса из Проведен в Новый
  * Проверка нахождения проводок в закрытом периоде*/
  PROCEDURE check_trans_in_close(par_doc_id NUMBER) IS
    v_cnt      NUMBER;
    v_is_right NUMBER;
  BEGIN
    SELECT COUNT(1)
      INTO v_cnt
      FROM oper  o
          ,trans t
     WHERE o.document_id = par_doc_id
       AND t.oper_id = o.oper_id
          --and t.is_closed   = 1;
       AND pkg_period_closed.check_date_in_closed(t.trans_date) = 1; --273031: Изменение триггера контроля закрытого периода в/Чирков/
  
    IF v_cnt > 0
    THEN
      -- проводки находятся в закрытом периоде
      v_is_right := safety.check_right_custom('CHECK_TRANS_IN_CLOSE');
    
      IF v_is_right = 0
      THEN
        raise_application_error('-20000'
                               ,'Внимание! Проводки по документу находятся в закрытом периоде - обратитесь к ответственному пользователю отдела привязки платежей');
      END IF;
    END IF;
  END;

END doc;
/

CREATE OR REPLACE PACKAGE pkg_agn_control IS

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 01.04.2010 17:08:59
  -- Purpose : Процедуры для обслуживания нового агентского модуля, и агентских договоров
  TYPE r_temp_dog IS RECORD(
     field_name  VARCHAR2(40)
    ,field_value VARCHAR2(250));

  TYPE tbl_temp_dog IS TABLE OF r_temp_dog;

  /*
    Капля П.
    12.08.2014
    До сих пор не было стандартной процедуры получения агентского договора по номеру.
  */
  FUNCTION get_ag_contract_header_by_num
  (
    par_num    VARCHAR2
   ,par_is_new NUMBER DEFAULT 1
  ) RETURN ag_contract_header.ag_contract_header_id%TYPE;

  /*
  Капля П.
  Возвращает ИД хедера текущего агента по договору
  */
  FUNCTION get_current_policy_agent(par_pol_header_id NUMBER) RETURN NUMBER;

  FUNCTION state(p_message OUT VARCHAR2) RETURN VARCHAR2;

  --Author: Sergey.Poskryakov
  --Created: 03.11.2011
  --Purpose: Удаляет версию договора
  PROCEDURE delete_ag_contract(par_document_id IN NUMBER);

  FUNCTION create_ag_doc
  (
    p_ag_contract_header_id PLS_INTEGER
   ,p_doc_type_id           PLS_INTEGER
   ,p_doc_date              DATE
  ) RETURN PLS_INTEGER;
  FUNCTION gen_contract_num RETURN VARCHAR2;
  FUNCTION create_contract( --p_contract_num VARCHAR2,
                           p_date_begin   DATE
                          ,p_contact_id   PLS_INTEGER
                          ,p_sales_chanel PLS_INTEGER) RETURN PLS_INTEGER;
  PROCEDURE create_first_ver(p_ag_doc_id PLS_INTEGER);
  PROCEDURE create_version(p_ag_doc_id PLS_INTEGER);

  /* Создает версию контракта на основе параметра версии  и  парамера даты
  * @param  p_ag_contract_id  - эталонна версия контракта
  * @param  p_new_date        - дата на которую создается новая версия
  */
  FUNCTION copy_version
  (
    p_ag_contract_id PLS_INTEGER
   ,p_new_date       DATE
  ) RETURN PLS_INTEGER;

  /* Процедура обновляет версию контракта props'ами документа
  * и связывает документ с версией контракта
  * @param  p_ag_doc_id - документ
  * @param  p_ag_contract_id - версия контракта
  */
  PROCEDURE update_version
  (
    p_ag_doc_id      PLS_INTEGER
   ,p_ag_contract_id PLS_INTEGER
  );
  FUNCTION get_last_version
  (
    p_ag_contract_id IN NUMBER
   ,p_doc_date       IN DATE
  ) RETURN NUMBER;

  PROCEDURE update_tree(p_ag_doc_id PLS_INTEGER);
  PROCEDURE fill_prop_lov
  (
    p_doc_type_prop_id PLS_INTEGER
   ,p_ag_documetns_id  PLS_INTEGER
  );
  PROCEDURE add_bank_prop(p_ag_documents_id PLS_INTEGER);
  PROCEDURE policy_transfer(p_ag_contract_header_id PLS_INTEGER);

  /*  Передает агентский договор по договору страхования от одного агента к другому
   *  @param = pv_policy_header_id ИД заголовка договора страхования
   *  @param = p_old_AG_CONTRACT_HEADER_ID ИД агентского договора от которого передается
   *  @param = p_new_AG_CONTRACT_HEADER_ID ИД агентского договора которому передается
   *  @param = p_date_break - дата расторжения договора с первым агентом и передача договора второму агенту
   *  @param = msg - выходной параметр для сообщений клиенту по ходу работы
   *  @return : <0 - код ошибки sqlcode , =0 если всё ОК, >0 если ошибка в логике
  */
  FUNCTION transmit_policy
  (
    pv_policy_header_id         IN NUMBER
   ,p_old_ag_contract_header_id IN NUMBER
   ,p_new_ag_contract_header_id IN NUMBER
   ,p_date_break                IN DATE
   ,msg                         OUT VARCHAR2
  ) RETURN NUMBER;

  PROCEDURE add_to_prev_dog(p_ag_contract_header_id PLS_INTEGER);
  PROCEDURE delete_from_prev_dog(par_ag_contract_header_id NUMBER);
  PROCEDURE old_policy_agent_cre(par_policy_agent_doc_id PLS_INTEGER);
  PROCEDURE old_policy_agent_stat(par_policy_agent_doc_id PLS_INTEGER);
  PROCEDURE import_ad_changes(p_ag_documnet_id PLS_INTEGER);
  PROCEDURE import_ad(p_ag_contract_header_id PLS_INTEGER);
  FUNCTION get_json_string(ag_gate_table_id PLS_INTEGER) RETURN VARCHAR2;
  PROCEDURE process_import;
  PROCEDURE process_http_import;
  PROCEDURE check_leader(p_ag_documents_id PLS_INTEGER);
  PROCEDURE check_subordinate_agency(p_ag_documents_id PLS_INTEGER);
  PROCEDURE check_subordinate_cat(p_ag_documents_id PLS_INTEGER);
  PROCEDURE ag_doc_type_change_status(p_ag_documents_id PLS_INTEGER);
  PROCEDURE ag_doc_chek_double_ad(p_ag_documents_id PLS_INTEGER);
  PROCEDURE set_contract_state(p_ag_documents_id PLS_INTEGER);
  PROCEDURE check_ad_lead(p_ag_documents_id PLS_INTEGER);
  PROCEDURE check_ad_pboul(p_ag_documents_id PLS_INTEGER);
  PROCEDURE check_ad_doc_class(p_ag_documents_id PLS_INTEGER);
  PROCEDURE check_agent_inn(p_ag_documents_id PLS_INTEGER);
  /*
    Байтин А.
    Проверка на наличие КП у агента.
    Перенесено из формы и немного изменен запрос
  */
  PROCEDURE check_agent_policy(par_ag_doc_id NUMBER);

  PROCEDURE ins_to_agn_sales_ops;
  PROCEDURE process_http_import_sales;
  FUNCTION get_json_string_ops(agn_sales_ops_id PLS_INTEGER) RETURN VARCHAR2;
  FUNCTION get_doc_date
  (
    p_ag_contract_header_id PLS_INTEGER
   ,p_brief_document        VARCHAR2
  ) RETURN VARCHAR2;
  FUNCTION sum_prem_for_act
  (
    p_work_act_id PLS_INTEGER
   ,p_brief       VARCHAR2
  ) RETURN NUMBER;
  FUNCTION get_plan_value
  (
    p_ag_contract_header_id PLS_INTEGER
   ,p_type_plan             PLS_INTEGER
   ,p_date_period           DATE
  ) RETURN NUMBER;
  FUNCTION get_active_agent
  (
    p_ag_num      NUMBER
   ,p_date_period DATE
  ) RETURN NUMBER;
  PROCEDURE set_data_for_prem(par_ag_roll_id ag_roll.ag_roll_id%TYPE);
  FUNCTION get_detail_amt
  (
    p_leader_num   VARCHAR2
   ,p_agent_num    VARCHAR2
   ,p_brief_detail VARCHAR2
  ) RETURN NUMBER;
  PROCEDURE get_info_ach(p_ach_id PLS_INTEGER);
  PROCEDURE set_dir_prem
  (
    p_num_vedom  VARCHAR2
   ,p_vedom_ver  PLS_INTEGER
   ,p_num_agent  VARCHAR2
   ,p_brief_prem VARCHAR2
   ,p_reestr     NUMBER DEFAULT 1
  );
  /*
    Байтин А.
    Проверка существования агента в продающем подразделении
  */
  PROCEDURE check_is_agent_in_dept(par_document_id NUMBER);

  /*
    Изместьев Д.
    заявка 173706
    проверка при изменении Категории на АГЕНТ
  
    Байтин А.
    Отключена по заявке 210001
  */
  /*  PROCEDURE check_is_manager_in_dept
  (
    par_document_id number
  );*/
  /*
    Изместьев Д.И.  26.09.2012
    Заявка 181634
    Процедура проверки импортируемых Договоров страхования, переходящих на прямое сопровождение компании
  */
  PROCEDURE set_agent_escort_latepay_check
  (
    par_load_file_rows_id NUMBER
   ,par_status            OUT VARCHAR2
   ,par_comment           OUT VARCHAR2
  );
  /*
    Изместьев Д.И.  26.09.2012
    Заявка 181634
    Процедура загрузки импортируемых Договоров страхования, переходящих на прямое сопровождение компании
  */
  PROCEDURE set_agent_escort_latepay_load(par_load_file_rows_id NUMBER);
  /*
    Байтин А.
    Заявка 191992
    Проверка наличия заполненного места рождения у агента
    при переводе из "документ добавлен" в "проект"
  */
  PROCEDURE check_birth_place(par_ag_document_id NUMBER);

  /*
    Байтин А.
    Заявка 191992
    Проверка наличия заполненного кода подразделения в паспортных данных у агента
    при переводе из "документ добавлен" в "проект"
  */
  PROCEDURE check_subdiv_code(par_ag_document_id NUMBER);

  /*
    Байтин А.
    Заявка 191992
    Проверка наличия заполненного места выдачи в банковских реквизитах
    при переводе из "документ добавлен" в "проект"
  */
  PROCEDURE check_place_of_issue(par_ag_document_id NUMBER);
  /*
  * Изместьев Д.И.  03.10.2012 №189228
  */
  FUNCTION check_agent_declaim_date
  (
    par_contact_id NUMBER
   ,par_date       DATE DEFAULT SYSDATE
  ) RETURN VARCHAR2;

  PROCEDURE check_agent_accept_30_day(p_ag_documents_id PLS_INTEGER);

  -- Байтин А.
  -- Заявка №202347
  -- Процедура проверяет право на перевод документа "Заключение АД" в Проект,
  -- если он был подтвержден ранее
  PROCEDURE check_right_to_project(par_doc_id NUMBER);

  /* Байтин А.
     Заявка №210001
  */
  PROCEDURE check_sales_dept_manager(par_doc_id NUMBER);

  /* Процедура проверяет расторгнутые по инициативе компании АД с агентом по дате рождения, Имени, Отчетсву, СНИЛС'у как у заводимого котакта par_contact_id
   *  создана по заявке 189187 Доработка Расторжения и проверки при заведении нового   
   ** @autor Чирков В.Ю.   
   * @param par_contact_id - заводимый id котакта агента
  */
  PROCEDURE check_break_initiative_company(par_contact_id NUMBER);
  /* Заявка 216248
  * Изместьев 14.02.2013
  *Проверка типа документа "Согл. на обработку персональных данных" при переходе статусов*/
  PROCEDURE check_agr_pers_data(p_ag_documents_id NUMBER);

  /*
    Байтин А.
  
    Возвращает действующего агента по договору
  */
  FUNCTION get_current_policy_agent_name(par_pol_header_id p_pol_header.policy_header_id%TYPE)
    RETURN contact.obj_name_orig%TYPE;

  /*
    Гаргонов Д.
  
    Возвращает номер действующего агента по договору
  */
  FUNCTION get_current_policy_agent_num(par_pol_header_id p_pol_header.policy_header_id%TYPE)
    RETURN document.num%TYPE;

  /*
    Капля П.
    12.08.2014
    Получение Листов переговоров по агентам на дату из системы "Навигатор"
  */
  PROCEDURE download_activity_meetings(par_date DATE);

  /*
    Капля П.
    Получение числа листов переговоров по агенту на дату начала месяца, 
    соответствующего дате окончания ведомости
  */
  FUNCTION get_activity_meetings_count
  (
    par_ag_countract_header_id NUMBER
   ,par_vedom_end_date         DATE
  ) RETURN INTEGER;

  /*
    Григорьев Ю.
    Корректировка даты завершения агентского соглашения как даты окончания договора    
  */
  PROCEDURE refresh_pol_agent_end_date(par_policy_agent_doc_id NUMBER);

END pkg_agn_control;
/
CREATE OR REPLACE PACKAGE BODY pkg_agn_control IS

  TYPE t_message IS RECORD(
     message VARCHAR2(2000)
    ,state   VARCHAR2(5));
  g_message t_message;

  TYPE t_props_chages IS TABLE OF VARCHAR2(50) INDEX BY VARCHAR2(20);
  g_ach_templ PLS_INTEGER := doc.templ_id_by_brief('AGN_CONTRACT_HEADER');
  g_agn_templ PLS_INTEGER := doc.templ_id_by_brief('AGN_CONTRACT');
  -- Байтин А.
  http_import_exception EXCEPTION;
  PRAGMA EXCEPTION_INIT(http_import_exception, -20010);

  /*
    Капля П.
    12.08.2014
    До сих пор не было стандартной процедуры получения агентского договора по номеру.
  */
  FUNCTION get_ag_contract_header_by_num
  (
    par_num    VARCHAR2
   ,par_is_new NUMBER DEFAULT 1
  ) RETURN ag_contract_header.ag_contract_header_id%TYPE IS
    v_ag_num document.num%TYPE;
  BEGIN
    SELECT ah.ag_contract_header_id
      INTO v_ag_num
      FROM ag_contract_header ah
          ,document           d
     WHERE ah.ag_contract_header_id = d.document_id
       AND d.num = par_num
       AND ah.is_new = par_is_new;
  
    RETURN v_ag_num;
  EXCEPTION
    WHEN no_data_found THEN
      ex.raise('Не удалось определить агента по номеру ' || par_num);
    WHEN too_many_rows THEN
      ex.raise('Найдено несколько агентов по номеру ' || par_num);
  END get_ag_contract_header_by_num;
  --
  -- Author  : ALEXEY.KATKEVICH
  -- Created : 15.04.2010 18:42:23
  -- Purpose : Добавляет документ
  FUNCTION create_ag_doc
  (
    p_ag_contract_header_id PLS_INTEGER
   ,p_doc_type_id           PLS_INTEGER
   ,p_doc_date              DATE
  ) RETURN PLS_INTEGER IS
    v_ag_doc_id     PLS_INTEGER;
    v_doc_type      VARCHAR2(50);
    v_doc_templ     PLS_INTEGER := doc.templ_id_by_brief('AG_DOCUMENTS');
    proc_name       VARCHAR2(25) := 'create_ag_doc';
    v_last_contract ag_contract%ROWTYPE;
    v_is_accepted   NUMBER;
  BEGIN
    --Проверка на наличие неподтвержденных документов
    SELECT MIN(pc.is_accepted)
      INTO v_is_accepted
      FROM ag_documents    agd
          ,ag_props_change pc
          ,document        d
          ,doc_status_ref  dsr
     WHERE pc.ag_documents_id = agd.ag_documents_id
       AND agd.ag_contract_header_id = p_ag_contract_header_id
          --Чирков/добавил/в статусе отменен пропсы не подтверждены, потому их исключаем
       AND agd.ag_documents_id = d.document_id
       AND dsr.doc_status_ref_id = d.doc_status_ref_id
       AND dsr.brief != 'CANCEL';
    --end_Чирков/добавил/---------------------------------------
  
    IF v_is_accepted = 0
    THEN
      g_message.state   := 'Err'; --'Warn' --'Err'
      g_message.message := 'Существуют неподтверженные документы';
      RETURN(-1);
    END IF;
    SELECT adt.description
      INTO v_doc_type
      FROM ag_documents agd
          ,ag_doc_type  adt
     WHERE agd.ag_doc_type_id = p_doc_type_id
       AND agd.ag_doc_type_id = adt.ag_doc_type_id
       AND agd.ag_contract_header_id = p_ag_contract_header_id
       AND doc.get_doc_status_brief(agd.ag_documents_id, '31.12.2999') = 'PROJECT';
  
    g_message.state   := 'Err'; --'Warn' --'Err'
    g_message.message := 'Существует документ ' || v_doc_type || ' в статусе проект';
    RETURN(-1);
  
  EXCEPTION
    WHEN no_data_found THEN
    
      SELECT sq_ag_documents.nextval INTO v_ag_doc_id FROM dual;
      -- PS
      BEGIN
        INSERT INTO ven_ag_documents
          (ag_documents_id, doc_templ_id, ag_doc_type_id, doc_date, reg_date, ag_contract_header_id)
        VALUES
          (v_ag_doc_id, v_doc_templ, p_doc_type_id, p_doc_date, SYSDATE, p_ag_contract_header_id);
      EXCEPTION
        WHEN OTHERS THEN
          g_message.state   := 'Err'; --'Warn' --'Err'
          g_message.message := SQLERRM;
          RETURN(-1);
          raise_application_error(-20001
                                 ,'Ошибка создания документа ' || proc_name || SQLERRM);
      END;
    
      RETURN(v_ag_doc_id);
    WHEN too_many_rows THEN
      g_message.state   := 'Err'; --'Warn' --'Err'
      g_message.message := 'Существует документ этого типа в статусе проект';
      RETURN(-1);
    WHEN OTHERS THEN
      g_message.state   := 'Err'; --'Warn' --'Err'
      g_message.message := SQLERRM;
      RETURN(-1);
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM);
  END create_ag_doc;

  --Author: Sergey.Poskryakov
  --Created: 03.11.2011
  --Purpose: АД. Удаление версии договора САД
  PROCEDURE delete_ag_contract(par_document_id IN NUMBER) AS
    p_old_doc_id           NUMBER;
    p_contract_id          NUMBER;
    p_contract_header_id   NUMBER;
    p_contract_leader_id   NUMBER;
    p_doc_date             DATE;
    v_sql                  VARCHAR2(1000);
    v_count                NUMBER;
    v_last_version_id      NUMBER;
    v_last_doc_date        DATE;
    v_last_new_value       NUMBER;
    v_prev_version         NUMBER;
    v_next_version         NUMBER;
    v_next_document        NUMBER;
    v_prev_document        NUMBER;
    v_date                 DATE;
    v_prop_end_date        DATE;
    v_last_props_change_id NUMBER;
    v_temp_dog             tbl_temp_dog;
    v_temp                 VARCHAR2(100);
    i                      INT;
    v_update_fields        VARCHAR2(1000);
    v_doc_brief            ag_doc_type.brief%TYPE;
    v_doc_class            INT;
  BEGIN
    SELECT agt.doc_class
          ,agt.brief
      INTO v_doc_class
          ,v_doc_brief
      FROM ins.ag_documents agd
          ,ins.ag_doc_type  agt
     WHERE agd.ag_documents_id = par_document_id
       AND agt.ag_doc_type_id = agd.ag_doc_type_id;
  
    IF v_doc_class != 1 -- если документ не основной, то на нем нет версии
       OR v_doc_brief = 'NEW_AD'
    THEN
      -- если документ <Заключение АД>
      RETURN;
    END IF;
  
    --Получаем данные по версии
    BEGIN
      SELECT c.date_begin
            ,c.ag_contract_id
            ,c.contract_id
            ,c.contract_leader_id
        INTO p_doc_date
            ,p_contract_id
            ,p_contract_header_id
            ,p_contract_leader_id
        FROM ag_contract c
       WHERE c.ag_documents_id = par_document_id;
    EXCEPTION
      WHEN no_data_found THEN
        --Документ не привязан к версии.
        raise_application_error(-20001
                               ,'У данной версии документа есть более поздний документ. Редактирование невозможно!');
    END;
  
    --********************************************************************
    --ОПРЕДЕЛЯЕМ ПРЕДЫДУЩИЙ ДОКУМЕНТ ПО ВЕРСИИ
    --********************************************************************
    --Чирков/добавил/-- Предпослдений документ определяем по дате регистрации документа
    BEGIN
      SELECT ag_documents_id
        INTO p_old_doc_id
        FROM (SELECT d.ag_documents_id
                    ,dd.reg_date
                    ,MAX(dd.reg_date) over() max_reg_date
                FROM ag_documents d
                    ,document     dd
                    ,ag_doc_type  adt
               WHERE d.ag_documents_id = dd.document_id
                 AND d.ag_doc_type_id = adt.ag_doc_type_id
                 AND adt.doc_class = 1
                 AND d.doc_date = p_doc_date
                 AND d.ag_contract_header_id = p_contract_header_id
                 AND d.ag_documents_id <> par_document_id
                    --Чирков должны отбираться только подтвержденные документы
                 AND NOT EXISTS (SELECT 1
                        FROM ag_props_change apc
                       WHERE apc.is_accepted = 0
                         AND apc.ag_documents_id = d.ag_documents_id)
              
              )
       WHERE reg_date = max_reg_date;
    EXCEPTION
      WHEN no_data_found THEN
        -- предыдущий документ по версии на дату не найден
        p_old_doc_id := NULL;
    END;
  
    --ОБНУЛЯЕМ ПРОПСЫ УДАЛЯЕМОГО ДОКУМЕНТА
    UPDATE ag_props_change apc
       SET apc.is_accepted = 0
          ,apc.end_date    = to_date('31.12.2999', 'dd.mm.yyyy')
     WHERE apc.ag_documents_id = par_document_id;
  
    --************************************************************************************
    --МЕНЯЕМ ДАТЫ ОКОНЧАНИЯ ПРОПСОВ ПРЕДЫДУЩЕЙ ВЕРСИИ НА ДАТЫ НАЧАЛА СЛЕДУЮЩЕЙ ВЕРСИИ
    --************************************************************************************
    FOR cur IN (SELECT pc.ag_props_change_id
                      ,pc.ag_documents_id
                      ,pc.new_value
                      ,pc.ag_props_type_id
                      ,apt.brief
                      ,pc.end_date
                  FROM ag_props_change pc
                      ,ag_props_type   apt
                 WHERE pc.ag_props_type_id = apt.ag_props_type_id
                   AND pc.ag_documents_id = par_document_id)
    LOOP
      --ищем такое же свойство в предыдущих документах
      BEGIN
        SELECT ag_props_change_id
              ,doc_date
              ,CASE
                 WHEN new_value = 'NULL' THEN
                  NULL
                 ELSE
                  new_value
               END
          INTO v_last_props_change_id
              ,v_last_doc_date
              ,v_last_new_value
          FROM (SELECT pc.ag_props_change_id
                      ,ad.doc_date
                      ,pc.new_value
                  FROM ven_ag_documents ad
                      ,ag_props_change  pc
                 WHERE pc.ag_documents_id = ad.ag_documents_id
                   AND pc.ag_props_type_id = cur.ag_props_type_id
                   AND ad.ag_contract_header_id = p_contract_header_id
                   AND pc.is_accepted = 1
                   AND ad.doc_date <= p_doc_date
                   AND ad.ag_documents_id != par_document_id
                 ORDER BY ad.doc_date DESC
                         ,ad.reg_date DESC)
         WHERE rownum = 1;
      
        --ищем свойство в последующих документах
        BEGIN
          SELECT ad.doc_date
            INTO v_prop_end_date
            FROM ag_documents    ad
                ,ag_props_change pc
           WHERE pc.ag_documents_id = ad.ag_documents_id
             AND ad.doc_date = (SELECT MIN(c.date_begin)
                                  FROM ag_contract c
                                 WHERE c.contract_id = p_contract_header_id
                                   AND c.date_begin > p_doc_date)
             AND pc.ag_props_type_id = cur.ag_props_type_id
             AND ad.ag_contract_header_id = p_contract_header_id
             AND pc.is_accepted = 1
             AND rownum = 1; --может быть несколько документов с одним свойством на одну дату
        
          --ставим дату окончания предыдущего пропса, соотвествущую дате начала последующей версии
          UPDATE ag_props_change apc
             SET apc.end_date = v_prop_end_date - 1 / 24 / 3600
           WHERE apc.ag_props_change_id = v_last_props_change_id;
        
        EXCEPTION
          WHEN no_data_found THEN
            --если версии окочания не найдено, то ставим максимальную дату
            v_prop_end_date := to_date('31.12.2999', 'dd.mm.yyyy');
            UPDATE ag_props_change apc
               SET apc.end_date = to_date('31.12.2999', 'dd.mm.yyyy')
             WHERE apc.ag_props_change_id = v_last_props_change_id;
        END;
      
        --***************************************
        --ОБНОВЛЕНИЕ ДЕРЕВА
        --***************************************
        --если в удаляемом документе есть свойство Руководитель, то обновляем дерево
        DECLARE
          v_lead      NUMBER;
          v_prev_lead NUMBER;
        BEGIN
          IF cur.new_value = 'NULL'
          THEN
            v_lead := NULL;
          ELSE
            SELECT ac.contract_id
              INTO v_lead
              FROM ag_contract ac
             WHERE ac.ag_contract_id = cur.new_value;
          END IF;
        
          IF cur.brief = 'LEAD_PROP'
          THEN
            --если руководитель изменялся на одну дату
            SELECT ac.contract_id
              INTO v_prev_lead
              FROM ag_contract ac
             WHERE ac.ag_contract_id = v_last_new_value;
          
            IF v_last_doc_date = p_doc_date
            THEN
              --у ветки изменяем руководителя
              UPDATE ag_agent_tree aat
                 SET aat.ag_parent_header_id = v_prev_lead
               WHERE aat.ag_contract_header_id = p_contract_header_id
                 AND aat.ag_parent_header_id = v_lead
                 AND aat.date_begin = p_doc_date;
            ELSE
              --иначе удаляем ветку
              DELETE ag_agent_tree aat
               WHERE aat.ag_contract_header_id = p_contract_header_id
                 AND aat.ag_parent_header_id = v_lead
                 AND aat.date_begin = p_doc_date;
              --изменяем у предыдущей ветки дату окончания на дату следующей
            
              UPDATE ag_agent_tree aat
                 SET aat.date_end = v_prop_end_date - INTERVAL '1' SECOND
               WHERE aat.ag_contract_header_id = p_contract_header_id
                 AND aat.ag_parent_header_id = v_prev_lead
                 AND aat.date_begin = v_last_doc_date;
            END IF;
          END IF;
        END;
      
      EXCEPTION
        WHEN no_data_found THEN
          --если до изменений не было свойства, то ничего не делаем
          NULL;
      END;
    END LOOP;
  
    --******************************
    --ФОРМИРУЕМ КОЛЛЕКЦИЮ ДЛЯ ОБНОВЛЕНИЯ ПОСЛЕДУЮЩИХ ВЕРСИЙ ПОСЛЕ ВЕРСИИ УДАЛЯЕМОГО ДОКУМЕНТА
    --******************************
    /* Чирков /добавил/
    * Если мы переводим в проект документ, то пропсы, которые висели на версии связанной с этим док-том
    * должны измениться на пропсы предыдущих документов. И у последующих версий тоже если эти пропсы
    * не изменялись
    */
    i          := 1;
    v_temp_dog := tbl_temp_dog();
    FOR cur IN (SELECT apt.dest_field
                      ,apt.ag_props_type_id
                  FROM ag_documents     agd
                      ,ag_doc_type_prop adtp
                      ,ag_props_type    apt
                 WHERE agd.ag_documents_id = par_document_id
                   AND adtp.ag_doc_type_id = agd.ag_doc_type_id
                   AND adtp.ag_props_type_id = apt.ag_props_type_id)
    LOOP
      -- Сохраняем поля для обновления во временную таблицу
      v_temp_dog.extend(1);
      v_temp_dog(i).field_name := cur.dest_field;
      BEGIN
        --Чирков В. ищем предыдущий максимальный основной документ не равный удаляемому, дата документа
        --которого меньше или равна дате документа удаляемого. С пропсом как у удаляемого документа
        --данный пропс нужен нам в коллекции для обновления версий документов с датой больше даты док-та
        SELECT new_value
          INTO v_temp_dog(i).field_value
          FROM (SELECT d.ag_documents_id
                      ,(SELECT apc.new_value
                          FROM ag_props_change apc
                         WHERE apc.ag_documents_id = d.ag_documents_id
                           AND apc.ag_props_type_id = apt.ag_props_type_id) new_value
                      ,dd.reg_date
                      ,MAX(dd.reg_date) over() max_reg_date
                  FROM ag_documents     d
                      ,document         dd
                      ,ag_doc_type      adt
                      ,ag_doc_type_prop adtp
                      ,ag_props_type    apt
                 WHERE d.ag_documents_id = dd.document_id
                   AND d.ag_doc_type_id = adt.ag_doc_type_id
                   AND adt.doc_class = 1
                   AND adtp.ag_doc_type_id = d.ag_doc_type_id
                   AND adtp.ag_props_type_id = apt.ag_props_type_id
                   AND apt.dest_field = cur.dest_field
                   AND d.doc_date <= p_doc_date
                   AND d.ag_contract_header_id = p_contract_header_id
                   AND d.ag_documents_id <> par_document_id
                      --Чирков должны отбираться только подтвержденные документы
                   AND NOT EXISTS (SELECT 1
                          FROM ag_props_change apc
                         WHERE apc.is_accepted = 0
                           AND apc.ag_documents_id = d.ag_documents_id))
         WHERE reg_date = max_reg_date;
      EXCEPTION
        WHEN no_data_found THEN
          --данные не найдены - значит пропс в удаляемом документе не был добавлен в предыдущих
          v_temp_dog(i).field_value := NULL; -- затираем в последующих версиях данный пропс
      END;
      i := i + 1;
    END LOOP;
  
    --****************************
    --РАБОТАЕМ С ВЕРСИЕЙ ДОКУМЕНТА
    --****************************
    IF p_old_doc_id IS NOT NULL
    THEN
      --Если у версии контракта был предыдущий документ на ту же дату DOC_DATE
      --если есть документ - значит версию не удаляем и у нее необходимо изменить пропсы
      v_sql           := 'UPDATE ag_contract SET ag_documents_id = ' || p_old_doc_id;
      v_update_fields := ',';
    
      FOR i IN 1 .. v_temp_dog.count
      LOOP
        v_temp := v_temp_dog(i).field_name;
        IF v_temp IS NOT NULL
        THEN
          v_update_fields := v_update_fields || v_temp || '=' ||
                             nvl(v_temp_dog(i).field_value, 'NULL') || ',';
        END IF;
      END LOOP;
    
      v_sql := v_sql || substr(v_update_fields, 1, length(v_update_fields) - 1); --Убираем последнюю запятую
      v_sql := v_sql || ' where ag_contract_id= ' || p_contract_id;
      --обновляем версию контракта новыми св-вами
      EXECUTE IMMEDIATE v_sql;
    ELSE
      --Если у версии нет другого документа, то удаляем версию
      --Проверка на дурака, чтобы не удалить последнюю версию
      SELECT COUNT(*) INTO v_count FROM ag_contract c WHERE c.contract_id = p_contract_header_id;
      --Если версия не последняя, то удаляем ее
      IF v_count > 1
      THEN
        --если есть несколько версий, то проверяем последнюю верию
        SELECT ch.last_ver_id
          INTO v_last_version_id
          FROM ag_contract_header ch
         WHERE ch.ag_contract_header_id = p_contract_header_id;
      
        IF v_last_version_id = p_contract_id
        THEN
          --если удаляется последняя версия, то ищем предыдующую верссию
          SELECT c.ag_contract_id
                ,c.ag_documents_id
            INTO v_prev_version
                ,v_prev_document
            FROM ag_contract c
           WHERE c.contract_id = p_contract_header_id
             AND c.date_begin = (SELECT MAX(c2.date_begin)
                                   FROM ag_contract c2
                                  WHERE c2.contract_id = p_contract_header_id
                                    AND c2.date_end < p_doc_date);
        
          --Меняем дату окончания последней версии
          UPDATE ag_contract c
             SET c.date_end = to_date('31.12.2999', 'dd.mm.yyyy')
           WHERE c.ag_contract_id = v_prev_version;
        
          /*Чирков закомментировал-- даты пропсов меняются выше.
          --меняем даты окончания пропсов предыдущей версии
          UPDATE ag_props_change apc
            set apc.end_date = TO_DATE('31.12.2999','dd.mm.yyyy')
          where apc.ag_documents_id = v_prev_document; */
        
          --Перепривязываем последнюю версию к шапке
          UPDATE ag_contract_header ch
             SET ch.last_ver_id = v_prev_version
           WHERE ch.ag_contract_header_id = p_contract_header_id;
        ELSE
          --Если удаляется не последняя версия, то ищем дату начала следующей версии
          --и меняем дату окончания предыдущей версии
        
          --Ищем предыдущую версию
          --begin
          SELECT c.ag_contract_id
                ,c.ag_documents_id
            INTO v_prev_version
                ,v_prev_document
            FROM ag_contract c
           WHERE c.contract_id = p_contract_header_id
             AND c.date_begin = (SELECT MAX(c2.date_begin)
                                   FROM ag_contract c2
                                  WHERE c2.contract_id = p_contract_header_id
                                    AND c2.date_end < p_doc_date);
        
          --Ищем следующую версию
          SELECT c.date_begin
                ,c.ag_contract_id
                ,c.ag_documents_id
            INTO v_date
                ,v_next_version
                ,v_next_document
            FROM ag_contract c
           WHERE c.contract_id = p_contract_header_id
             AND c.date_begin = (SELECT MIN(c2.date_begin)
                                   FROM ag_contract c2
                                  WHERE c2.contract_id = p_contract_header_id
                                    AND c2.date_begin > p_doc_date);
        
          --Меняем дату окончания предыдующей версии
          UPDATE ag_contract c
             SET c.date_end = v_date - 1 / 24 / 3600
           WHERE c.ag_contract_id = v_prev_version;
          /*exception
            when no_data_found then
              --если отменяем первую версию, то ничего не делаем
              null;
          end;*/
        END IF;
      
        --обнуляем ссылку документа на версию
        /*update ag_documents d set d.ag_contract_id = null
        where d.ag_documents_id = par_document_id;*/ --Чирков закомментировал /избавился от поля ag_contract_id/
      
        --Удаляем версию
        DELETE FROM ag_contract WHERE ag_contract_id = p_contract_id;
      ELSE
        raise_application_error('-20000'
                               ,'Нельзя отменить документ на единственно версии договора');
      END IF;
    
    END IF;
  
    --****************************************************************************
    --ОБНОВЛЕНИЕ ВЕРСИЙ КОНТРАКТА ДАТА КОТОРЫХ БОЛЬШЕ ДАТЫ УДАЛЯЕМОГО ДОКУМЕНТА
    --****************************************************************************
    --Чирков -- Добавляем свойства, которые появились в удаляемом документе
    -- версии контракта, дата  начала которых больше даты удаляемого документа,
    --Запускаем цикл по контрактам
    FOR cur IN (SELECT ac.ag_contract_id
                      ,d.ag_doc_type_id
                      ,d.ag_documents_id
                      ,nvl((SELECT DISTINCT pc.is_accepted
                             FROM ag_props_change pc
                            WHERE pc.ag_documents_id = d.ag_documents_id)
                          ,1) -- если у версии нет пропсов
                       AS is_accepted
                  FROM ag_contract  ac
                      ,ag_documents d
                 WHERE d.ag_documents_id = ac.ag_documents_id
                   AND ac.contract_id = p_contract_header_id
                   AND ac.date_begin > p_doc_date
                 ORDER BY ac.date_begin)
    LOOP
    
      IF cur.is_accepted = 1
      THEN
        --находим имя типа версии контракта
        FOR cur_d IN (SELECT apt.dest_field
                            ,apt.ag_props_type_id
                        FROM ag_doc_type_prop adtp
                            ,ag_props_type    apt
                       WHERE adtp.ag_props_type_id = apt.ag_props_type_id
                         AND adtp.ag_doc_type_id = cur.ag_doc_type_id)
        LOOP
          --если есть св-во у версии контра-та такое же как у удал-емого док-та(находится в коллекции)
          --,то очищаем имя эл-та коллекции. Это значит, что мы прекращаем добавление данного св-ва
          --в версии конт-та, т.к. данное св-во изменено в этой версии и в слею-их версиях исп-ся это св-во
          FOR i IN 1 .. v_temp_dog.count
          LOOP
            IF v_temp_dog(i).field_name IS NOT NULL
                AND v_temp_dog(i).field_name = cur_d.dest_field
            THEN
              v_temp_dog(i).field_name := NULL; --v_temp_dog.delete(i);
            END IF;
          
          END LOOP;
        END LOOP;
      
        v_sql           := 'UPDATE ag_contract SET ';
        v_update_fields := NULL;
      
        FOR i IN 1 .. v_temp_dog.count
        LOOP
          v_temp := v_temp_dog(i).field_name;
          IF v_temp IS NOT NULL
          THEN
            v_update_fields := v_update_fields || v_temp || '=' ||
                               nvl(v_temp_dog(i).field_value, 'NULL') || ',';
          END IF;
        END LOOP;
      
        IF v_update_fields IS NULL
        THEN
          --Если нет полей для обновления, ты выходим из цикла
          EXIT;
        END IF;
      
        v_sql := v_sql || substr(v_update_fields, 1, length(v_update_fields) - 1); --Убираем последнюю запятую
        v_sql := v_sql || ' where ag_contract_id= ' || cur.ag_contract_id;
        --обновляем версию контракта новыми св-вами
        EXECUTE IMMEDIATE v_sql;
      
      END IF; --is_accepted = 1
    END LOOP;
  
    -- выгрузка изменений из системы borlas в систему b2b при отмене документа <Расторжение АД>
    DECLARE
      v_type_brief ag_doc_type.brief%TYPE;
    BEGIN
      SELECT agt.brief
        INTO v_type_brief
        FROM ag_documents agd
            ,ag_doc_type  agt
       WHERE agt.ag_doc_type_id = agd.ag_doc_type_id
         AND agd.ag_documents_id = par_document_id;
    
      IF v_type_brief = 'BREAK_AD'
      THEN
        doc.set_doc_status(p_contract_header_id, 'CURRENT');
        --309813: отменить тип документа "Расторжение АД"
        --ins.pkg_agn_control.Import_ad(p_ag_contract_header_id => P_CONTRACT_HEADER_ID);
      END IF;
    END;
    --
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
    
  END delete_ag_contract;
  -- Author  : ALEXEY.KATKEVICH
  -- Created : 05.04.2010 12:38:29
  -- Purpose : Заполняет LOV для формы документа
  PROCEDURE fill_prop_lov
  (
    p_doc_type_prop_id PLS_INTEGER
   ,p_ag_documetns_id  PLS_INTEGER
  ) IS
    v_sql  VARCHAR2(4000);
    v_errm VARCHAR2(2000);
  BEGIN
    DELETE FROM ag_temp_lov;
  
    SELECT adtp.lov_sql
      INTO v_sql
      FROM ag_doc_type_prop adtp
     WHERE adtp.ag_doc_type_prop_id = p_doc_type_prop_id;
  
    IF v_sql IS NULL
    THEN
      INSERT INTO ag_temp_lov
      VALUES
        (-998
        ,'Не настроен список значений проверьте справочник');
    ELSE
      v_sql := 'BEGIN Insert into ag_temp_lov (' || v_sql || '); END;';
      EXECUTE IMMEDIATE v_sql
        USING IN p_ag_documetns_id;
    END IF;
  
  EXCEPTION
    WHEN OTHERS THEN
      v_errm := SQLERRM;
      INSERT INTO ag_temp_lov
      VALUES
        (-999, 'Ошибка при получении списка значений' || v_errm);
  END fill_prop_lov;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 01.04.2010 17:19:18
  -- Purpose : Генерация номера АД
  FUNCTION gen_contract_num RETURN VARCHAR2 IS
    RESULT    NUMBER;
    proc_name VARCHAR2(25) := 'Gen_agent_num';
  BEGIN
    SELECT sq_agn_number.nextval INTO RESULT FROM dual;
    RETURN(RESULT);
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM);
  END gen_contract_num;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 01.04.2010 17:12:23
  -- Purpose : Создание АД
  FUNCTION create_contract
  (
    p_date_begin   DATE
   ,p_contact_id   PLS_INTEGER
   ,p_sales_chanel PLS_INTEGER
  ) RETURN PLS_INTEGER IS
    proc_name              VARCHAR2(25) := 'Create_contract';
    v_ach_id               PLS_INTEGER;
    v_contact_id           PLS_INTEGER;
    v_is_rla               NUMBER;
    v_chnl_id              NUMBER;
    var_sales_chanel_brief VARCHAR2(100);
  BEGIN
    BEGIN
      SELECT ch.id INTO v_chnl_id FROM ins.t_sales_channel ch WHERE ch.brief = 'RLA';
    EXCEPTION
      WHEN no_data_found THEN
        v_chnl_id := 0;
    END;
    MERGE INTO cn_contact_role cr
    USING (SELECT t.id FROM t_contact_role t WHERE t.brief = 'AGENT') tr
    ON (cr.contact_id = p_contact_id AND cr.role_id = tr.id)
    WHEN NOT MATCHED THEN
      INSERT
        (cr.contact_id, cr.role_id, cr.id)
      VALUES
        (p_contact_id, tr.id, sq_cn_contact_role.nextval);
  
    IF pkg_contact.get_is_individual(par_contact_id => p_contact_id) = 1
    THEN
    
      /* Мизинов Г.В. Закомментировано по причине отсутствия у Крымчан документов
      Заявка №354728
      BEGIN
        SELECT ci.contact_id
          INTO v_contact_id
          FROM cn_contact_ident ci
              ,t_id_type        ti
         WHERE ci.id_type = ti.id
           AND ti.brief = 'PENS'
           AND ci.contact_id = p_contact_id;
      EXCEPTION
        WHEN no_data_found THEN
          g_message.state   := 'Err';
          g_message.message := 'У выбраного контакта нет пенсионного свидетельства';
          RETURN(-1);
       END;*/
    
      BEGIN
        /*SELECT ci.contact_id
         INTO v_contact_id
         FROM cn_contact_ident ci,
              t_id_type ti
        WHERE ci.id_type = ti.id
          AND ti.brief = 'PASS_RF'
          AND ci.contact_id = p_contact_id;*/
        SELECT contact_id
          INTO v_contact_id
          FROM (SELECT ci.contact_id
                      ,ci.is_default
                  FROM cn_contact_ident ci
                      ,t_id_type        ti
                 WHERE ci.id_type = ti.id
                   AND ti.brief IN ('PASS_RF', 'RES_PER', 'CERT_TEMP_ASYLUM')
                   AND ci.contact_id = p_contact_id
                 ORDER BY ci.is_default DESC)
         WHERE rownum = 1;
      EXCEPTION
        WHEN no_data_found THEN
          g_message.state   := 'Err';
          g_message.message := 'У выбранного контакта нет паспорта гражданина РФ или разрешения на временное проживание в РФ';
          RETURN(-1);
      END;
    
      BEGIN
        SELECT cad.contact_id
          INTO v_contact_id
          FROM v_cn_contact_address cad
         WHERE cad.contact_id = p_contact_id
           AND length(cad.address_name) > 25 --полнота заполнения адреса
           AND rownum = 1;
      EXCEPTION
        WHEN no_data_found THEN
          g_message.state   := 'Err';
          g_message.message := 'У выбранного контакта нет адреса';
          RETURN(-1);
      END;
    
      BEGIN
        SELECT MAX(cp.contact_id)
          INTO v_contact_id
          FROM ins.cn_person cp
         WHERE cp.contact_id = p_contact_id;
      EXCEPTION
        WHEN no_data_found THEN
          g_message.state   := 'Err';
          g_message.message := 'У выбранного контакта нет даты рождения';
          RETURN(-1);
      END;
    END IF;
  
    BEGIN
    
      SELECT sc.brief
        INTO var_sales_chanel_brief
        FROM ins.t_sales_channel sc
       WHERE sc.id = p_sales_chanel;
    
      SELECT ach.agent_id
        INTO v_contact_id
        FROM ag_contract_header ach
       WHERE ach.agent_id = p_contact_id
         AND doc.get_doc_status_brief(ach.ag_contract_header_id) = 'CURRENT'
         AND ach.is_new = 1;
      /*Для RLA убрать ограничение на создание АД с одним и тем же контактом
        Заявка №237953
      */
      g_message.message := 'В системе уже есть договор с выбранным контактом';
    
      IF var_sales_chanel_brief IN ('RLA', 'BANK', 'BR')
      THEN
        g_message.state := 'Warn';
      ELSE
        g_message.state := 'Err';
        RETURN(-1);
      END IF;
    EXCEPTION
      WHEN no_data_found THEN
        NULL;
      WHEN too_many_rows THEN
        g_message.message := 'В системе уже есть договор с выбранным контактом';
        IF var_sales_chanel_brief IN ('RLA', 'BANK', 'BR')
        THEN
          g_message.state := 'Warn';
        ELSE
          g_message.state := 'Err';
          RETURN(-1);
        END IF;
    END;
  
    SELECT sq_ag_contract_header.nextval INTO v_ach_id FROM dual;
  
    INSERT INTO ven_ag_contract_header
      (doc_templ_id
      ,ag_contract_header_id
      ,num
      ,reg_date
      ,ag_contract_templ_id
      ,ag_contract_templ_k
      ,agent_id
      ,date_begin
      ,date_break
      ,is_new
      ,t_sales_channel_id)
    VALUES
      (g_ach_templ
      ,v_ach_id
      ,gen_contract_num
      , -- p_contract_num,
       SYSDATE
      ,148029
      , -- Для  поддержки старого функицонала
       0
      , -- Для  поддержки старого функицонала
       p_contact_id
      ,p_date_begin
      ,to_date('31.12.2999', 'dd.mm.yyyy')
      ,1
      ,p_sales_chanel);
  
    RETURN v_ach_id;
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM);
  END create_contract;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 06.04.2010 17:33:53
  -- Purpose : Создание первой версии АД
  PROCEDURE create_first_ver(p_ag_doc_id PLS_INTEGER) IS
    proc_name      VARCHAR2(25) := 'Create_first_ver';
    v_adt_brief    VARCHAR2(20);
    v_props_ch     t_props_chages;
    v_ag_contr_id  PLS_INTEGER;
    v_ag_ch        PLS_INTEGER;
    v_adt_date     DATE;
    v_sales_chn_id PLS_INTEGER;
    v_sales_rla    NUMBER;
  BEGIN
  
    SELECT adt.brief
          ,ad.ag_contract_header_id
          ,ad.doc_date
      INTO v_adt_brief
          ,v_ag_ch
          ,v_adt_date
      FROM ag_documents ad
          ,ag_doc_type  adt
     WHERE ad.ag_documents_id = p_ag_doc_id
       AND ad.ag_doc_type_id = adt.ag_doc_type_id;
  
    SELECT agh.t_sales_channel_id
      INTO v_sales_chn_id
      FROM ag_contract_header agh
     WHERE agh.ag_contract_header_id = v_ag_ch;
  
    BEGIN
      SELECT ch.id INTO v_sales_rla FROM ins.t_sales_channel ch WHERE ch.brief = 'RLA';
    EXCEPTION
      WHEN no_data_found THEN
        v_sales_rla := 0;
    END;
  
    IF v_adt_brief <> 'NEW_AD'
    THEN
      RETURN;
    END IF;
  
    SELECT sq_ag_contract.nextval INTO v_ag_contr_id FROM dual;
  
    FOR r IN (SELECT apt.brief
                    ,(SELECT apc.new_value
                        FROM ag_props_change apc
                       WHERE apc.ag_documents_id = agd.ag_documents_id
                         AND apc.ag_props_type_id = apt.ag_props_type_id) new_value
                FROM ag_documents     agd
                    ,ag_doc_type_prop adtp
                    ,ag_props_type    apt
               WHERE 1 = 1
                 AND agd.ag_documents_id = p_ag_doc_id
                 AND adtp.ag_doc_type_id = agd.ag_doc_type_id
                 AND adtp.ag_props_type_id = apt.ag_props_type_id)
    LOOP
      v_props_ch(r.brief) := r.new_value;
    END LOOP;
  
    INSERT INTO ven_ag_contract
      (ag_contract_id
      ,doc_templ_id
      ,num
      ,reg_date
      ,ag_documents_id
      ,agency_id
      ,category_id
      ,contract_id
      ,contract_leader_id
      ,contract_recrut_id
      ,date_begin
      ,date_end
      ,leg_pos
      ,ag_sales_chn_id
      ,admin_num)
    VALUES
      (v_ag_contr_id
      ,g_agn_templ
      ,1
      ,SYSDATE
      ,p_ag_doc_id
      ,decode(v_props_ch('AGENCY_PROP'), 'NULL', NULL, v_props_ch('AGENCY_PROP'))
      ,decode(v_props_ch('CAT_PROP'), 'NULL', NULL, v_props_ch('CAT_PROP'))
      ,v_ag_ch
      ,decode(v_props_ch('LEAD_PROP'), 'NULL', NULL, v_props_ch('LEAD_PROP'))
      ,decode(v_props_ch('REC_PROP'), 'NULL', NULL, v_props_ch('REC_PROP'))
      ,v_adt_date
      ,to_date('31.12.2999', 'dd.mm.yyyy')
      ,decode(v_props_ch('L_ENTITY_PROP'), 'NULL', NULL, v_props_ch('L_ENTITY_PROP'))
      ,v_sales_chn_id
      ,decode(v_sales_chn_id
             ,v_sales_rla
             ,NULL
             ,decode((SELECT dep.code
                       FROM ins.department dep
                      WHERE dep.department_id = v_props_ch('AGENCY_PROP'))
                    ,NULL
                    ,NULL
                    ,(SELECT dep.code
                        FROM ins.department dep
                       WHERE dep.department_id = v_props_ch('AGENCY_PROP')) || '-') ||
              (SELECT num FROM document d WHERE d.document_id = v_ag_ch)));
  
    UPDATE ag_contract_header ach
       SET ach.last_ver_id        = v_ag_contr_id
          ,ach.agency_id          = v_props_ch('AGENCY_PROP')
          ,ach.t_sales_channel_id = v_sales_chn_id
     WHERE ach.ag_contract_header_id = v_ag_ch;
  
    /**/
    INSERT INTO ven_ag_agent_tree
      (ag_contract_header_id, ag_parent_header_id, date_begin, date_end, is_leaf)
    VALUES
      (v_ag_ch
      ,(SELECT ac.contract_id
         FROM ag_contract ac
        WHERE ac.ag_contract_id =
              decode(v_props_ch('LEAD_PROP'), 'NULL', NULL, v_props_ch('LEAD_PROP')))
      ,v_adt_date
      ,to_date('31.12.2999', 'dd.mm.yyyy')
      ,1);
  
    IF v_props_ch('LEAD_PROP') IS NOT NULL
       AND v_props_ch('LEAD_PROP') <> 'NULL'
    THEN
      UPDATE ag_agent_tree
         SET is_leaf = 0
       WHERE ag_contract_header_id =
             (SELECT ac.contract_id
                FROM ag_contract ac
               WHERE ac.ag_contract_id =
                     decode(v_props_ch('LEAD_PROP'), 'NULL', NULL, v_props_ch('LEAD_PROP')))
         AND date_end = to_date('31.12.2999', 'dd.mm.yyyy');
    END IF;
  
    doc.set_doc_status(v_ag_contr_id, 'PROJECT', v_adt_date);
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM);
  END create_first_ver;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 02.04.2010 12:03:24
  -- Purpose : Создание новой версии АД по документу
  PROCEDURE create_version(p_ag_doc_id PLS_INTEGER) IS
    proc_name        VARCHAR2(25) := 'Create_version';
    v_ag_contr_id    PLS_INTEGER;
    v_ag_ch          PLS_INTEGER;
    v_adt_date       DATE;
    v_ag_doc_cl      PLS_INTEGER;
    v_adt_descr      VARCHAR2(50);
    v_adt_brief      VARCHAR2(20);
    v_last_ver_id    PLS_INTEGER;
    v_last_date      DATE;
    v_next_ver_count NUMBER;
    v_current_ver    ag_contract%ROWTYPE;
    v_sales_chn_id   NUMBER;
    v_sales_rla      NUMBER;
  BEGIN
    SELECT adt.doc_class
          ,adt.description
          ,adt.brief
          ,ad.ag_contract_header_id
          ,ad.doc_date
          ,ach.last_ver_id
          ,ac.date_begin
      INTO v_ag_doc_cl
          ,v_adt_descr
          ,v_adt_brief
          ,v_ag_ch
          ,v_adt_date
          ,v_last_ver_id
          ,v_last_date
      FROM ag_documents       ad
          ,ag_doc_type        adt
          ,ag_contract_header ach
          ,ag_contract        ac
     WHERE ad.ag_documents_id = p_ag_doc_id
       AND ac.ag_contract_id = ach.last_ver_id
       AND ad.ag_doc_type_id = adt.ag_doc_type_id
       AND ach.ag_contract_header_id = ad.ag_contract_header_id;
    --1) Проверка на то что по документу можно создать версию
    IF v_ag_doc_cl <> 1
    THEN
      g_message.state   := 'Err'; --'Warn' --'Err'
      g_message.message := 'Невозможно создать версию АД по документу ' || v_adt_descr;
      RETURN;
    END IF;
  
    --1) Проверка на то что по документу заполнены все реквизиты
    FOR r IN (SELECT adtp.ag_doc_type_prop_id
                    ,apt.description          prop_t
                    ,adt.description          doc_t
                FROM ag_documents     agd
                    ,ag_doc_type      adt
                    ,ag_doc_type_prop adtp
                    ,ag_props_type    apt
               WHERE 1 = 1
                 AND agd.ag_documents_id = p_ag_doc_id
                 AND adtp.is_mandatory = 1
                 AND adt.ag_doc_type_id = agd.ag_doc_type_id
                 AND adtp.ag_doc_type_id = adt.ag_doc_type_id
                 AND adtp.ag_props_type_id = apt.ag_props_type_id
              MINUS
              SELECT adtp.ag_doc_type_prop_id
                    ,apt.description
                    ,adt.description
                FROM ag_props_change  apc
                    ,ag_props_type    apt
                    ,ag_documents     agd
                    ,ag_doc_type      adt
                    ,ag_doc_type_prop adtp
               WHERE apc.ag_documents_id = agd.ag_documents_id
                 AND apc.ag_props_type_id = apt.ag_props_type_id
                 AND agd.ag_documents_id = p_ag_doc_id
                 AND adt.ag_doc_type_id = agd.ag_doc_type_id
                 AND adtp.ag_doc_type_id = adt.ag_doc_type_id
                 AND adtp.ag_props_type_id = apt.ag_props_type_id)
    LOOP
      g_message.state   := 'Err'; --'Warn' --'Err'
      g_message.message := 'Не заполнен реквезит ' || r.prop_t || ' документа ' || r.doc_t;
      RETURN;
    END LOOP;
  
    --PS подтверждаем пропсы
    UPDATE ag_props_change apc SET apc.is_accepted = 1 WHERE apc.ag_documents_id = p_ag_doc_id;
  
    --IF v_adt_date > v_last_date THEN
    --  PS Проверяем наличие версии на дату договора
    --Чирков -- если есть версия контракта на дату документа, то у контракта изменяем
    -- текущий документ
    BEGIN
      SELECT *
        INTO v_current_ver
        FROM ag_contract ac
       WHERE ac.date_begin = v_adt_date
         AND ac.contract_id = (SELECT ch.ag_contract_header_id
                                 FROM ag_contract_header ch
                                WHERE ch.last_ver_id = v_last_ver_id)
         AND rownum = 1;
    
      --PS если контракт уже есть, то ставим контракту последнюю версию договора
      UPDATE ag_contract c
         SET c.ag_documents_id = p_ag_doc_id
       WHERE c.ag_contract_id = v_current_ver.ag_contract_id;
    
      --PS документу ставим версию контракта
      /*--Чирков закомментировал
      update ag_documents d
      set d.ag_contract_id=v_current_ver.ag_contract_id
      where d.ag_documents_id=p_ag_doc_id;*/
    
      v_ag_contr_id := v_current_ver.ag_contract_id;
      --Чирков -- указываем в функции сам документ и версию которую нашли на дату и к которой привязали документ
      update_version(p_ag_doc_id, v_ag_contr_id);
    EXCEPTION
      WHEN no_data_found THEN
        --Если нет версии на эту дату, то вставляем новую
        --Чирков -- если не нашли версию контракта на дату, то должны создать новую версию
        v_ag_contr_id := copy_version(v_last_ver_id, v_adt_date);
        --Чирков -- изменить свойства у новой версии
        update_version(p_ag_doc_id, v_ag_contr_id);
        --Чирков -- переводим новую версию контракта в статус <Действующий>
        doc.set_doc_status(v_ag_contr_id, 'PROJECT', v_adt_date);
        doc.set_doc_status(v_ag_contr_id, 'CURRENT', v_adt_date + 1 / 24 / 3600);
      
      --PS документу ставим версию контракта
      /*--Чирков закомментировал
      update ag_documents d
      set d.ag_contract_id    = v_ag_contr_id
      where d.ag_documents_id = p_ag_doc_id;
      */
    END;
    -- обновляем дерево
    update_tree(p_ag_doc_id);
  
    --PS Если документ вставлен задним числом, то не меняем шапку договора
    SELECT COUNT(*)
      INTO v_next_ver_count
      FROM ag_contract ac
     WHERE ac.contract_id = v_ag_ch
       AND ac.date_begin > v_adt_date;
  
    IF v_next_ver_count = 0
    THEN
      UPDATE ag_contract_header ach
         SET ach.last_ver_id        = v_ag_contr_id
            ,ach.agency_id         =
             (SELECT ac.agency_id FROM ag_contract ac WHERE ac.ag_contract_id = v_ag_contr_id)
            ,ach.t_sales_channel_id =
             (SELECT ac.ag_sales_chn_id FROM ag_contract ac WHERE ac.ag_contract_id = v_ag_contr_id)
       WHERE ach.ag_contract_header_id = v_ag_ch;
      /*Обновление Административного номера*/
      BEGIN
        SELECT ch.id INTO v_sales_rla FROM ins.t_sales_channel ch WHERE ch.brief = 'RLA';
      EXCEPTION
        WHEN no_data_found THEN
          v_sales_rla := 0;
      END;
    
      SELECT ac.ag_sales_chn_id
        INTO v_sales_chn_id
        FROM ag_contract ac
       WHERE ac.ag_contract_id = v_ag_contr_id;
    
      /*
      UPDATE ven_ag_contract_header ach
        SET ach.admin_num = decode(v_sales_chn_id, v_sales_rla, NULL, ach.admin_num)
      WHERE ach.ag_contract_header_id = v_ag_ch;
      */
      /**/
      --подтверждаем пропсы добавляемого документа
      UPDATE ag_props_change apc SET apc.is_accepted = 1 WHERE apc.ag_documents_id = p_ag_doc_id;
      --у пропсов совпадающих по типу с пропсами доб. документа закрываем дату датой доб. док-та
      UPDATE ag_props_change apc
         SET apc.end_date = greatest(v_adt_date - 1 / 24 / 3600
                                    ,(SELECT agd1.doc_date
                                       FROM ag_documents agd1
                                      WHERE agd1.ag_documents_id = apc.ag_documents_id))
       WHERE apc.end_date = to_date('31.12.2999', 'dd.mm.yyyy')
         AND apc.ag_props_type_id IN
             (SELECT apc1.ag_props_type_id
                FROM ag_props_change apc1
               WHERE apc1.ag_documents_id = p_ag_doc_id)
         AND apc.ag_documents_id IN (SELECT agd.ag_documents_id
                                       FROM ag_documents agd
                                      WHERE agd.ag_contract_header_id = v_ag_ch
                                        AND agd.ag_documents_id <> p_ag_doc_id);
    END IF;
    ----------------
  
    -- COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM);
  END create_version;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 06.04.2010 18:22:26
  -- Purpose : Создает копию версии АД
  FUNCTION copy_version
  (
    p_ag_contract_id PLS_INTEGER
   ,p_new_date       DATE
  ) RETURN PLS_INTEGER
  
   IS
    proc_name     VARCHAR2(25) := 'Copy_version';
    v_ag_contr_id PLS_INTEGER;
    v_last_ver_id NUMBER;
  BEGIN
  
    --PS находим последнюю версию по дате
    v_last_ver_id := get_last_version(p_ag_contract_id, p_new_date);
    IF v_last_ver_id IS NULL
    THEN
      --если версия не нашлась, то копируем рабочую версию
      v_last_ver_id := p_ag_contract_id;
    END IF;
  
    SELECT sq_ag_contract.nextval INTO v_ag_contr_id FROM dual;
  
    INSERT INTO ven_ag_contract
      (ag_contract_id
      ,doc_templ_id
      ,num
      ,reg_date
      ,agency_id
      ,category_id
      ,contract_id
      ,contract_leader_id
      ,contract_recrut_id
      ,contract_f_lead_id
      ,date_begin
      ,date_end
      ,leg_pos
      ,ag_sales_chn_id
      ,admin_num
      ,contract_type_id
      ,personnel_number)
      (SELECT v_ag_contr_id
             ,g_agn_templ
             ,1
             ,SYSDATE
             ,agency_id
             ,category_id
             ,contract_id
             ,contract_leader_id
             ,contract_recrut_id
             ,contract_f_lead_id
             ,p_new_date
             ,to_date('31.12.2999', 'dd.mm.yyyy')
             ,leg_pos
             ,ag_sales_chn_id
             ,admin_num
             ,contract_type_id
             ,personnel_number
         FROM ag_contract ac
        WHERE ac.ag_contract_id = v_last_ver_id); -- p_ag_contract_id);
  
    UPDATE ag_contract ac --Сразу меняем дату окончания предыдущей версии
       SET ac.date_end = p_new_date - 1 / 24 / 3600
     WHERE ac.ag_contract_id = v_last_ver_id; --p_ag_contract_id;
  
    RETURN v_ag_contr_id;
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM);
  END copy_version;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 07.04.2010 11:23:26
  -- Purpose : Обновляет реквизиты версии
  PROCEDURE update_version
  (
    p_ag_doc_id      PLS_INTEGER
   ,p_ag_contract_id PLS_INTEGER
  ) IS
    proc_name              VARCHAR2(25) := 'Update_version';
    v_sql                  VARCHAR2(2000);
    v_is_changed           PLS_INTEGER := 1; --PS по умолчанию привязываем документ к версии
    v_last_contract_id     NUMBER;
    v_doc_date             DATE; --дата нового документа
    v_ac_date_begin        DATE; --дата начала версии p_ag_doc_id
    v_next_doc_date        DATE;
    v_doc_type             NUMBER;
    v_contract_count       NUMBER;
    v_update_fields        VARCHAR2(1000);
    v_doc_date_exit        DATE;
    v_contract_header      NUMBER;
    v_temp_dog             tbl_temp_dog;
    i                      NUMBER;
    v_temp                 VARCHAR2(100);
    v_last_props_change_id NUMBER;
    v_prop_end_date        DATE;
    v_prop_start_date      DATE;
    v_test_doc             NUMBER;
  BEGIN
    --********************
    --Обновляем контракт
    --********************
    --Чирков -- версию контракта связываем с документом
    --и props'ы добавляемого документа указываем в версии контракта
    v_sql := 'UPDATE ag_contract
               SET ag_documents_id = ' || p_ag_doc_id;
  
    FOR r IN (SELECT (SELECT apc.new_value
                        FROM ag_props_change apc
                       WHERE apc.ag_documents_id = agd.ag_documents_id
                         AND apc.ag_props_type_id = apt.ag_props_type_id) new_value
                    ,apt.dest_field
                    ,agd.doc_date
                    ,agd.ag_doc_type_id
                    ,adtp.lov_sql
                FROM ag_documents     agd
                    ,ag_doc_type_prop adtp
                    ,ag_props_type    apt
               WHERE 1 = 1
                 AND agd.ag_documents_id = p_ag_doc_id
                 AND adtp.ag_doc_type_id = agd.ag_doc_type_id
                 AND adtp.ag_props_type_id = apt.ag_props_type_id)
    LOOP
      IF r.new_value IS NOT NULL
      THEN
        IF r.lov_sql IS NOT NULL
        THEN
          v_sql := v_sql || ', ' || chr(10) || r.dest_field || ' = ' || r.new_value;
        ELSE
          v_sql := v_sql || ', ' || chr(10) || r.dest_field || ' = ''' || r.new_value || '''';
        END IF;
        v_is_changed := 1;
        v_doc_date   := r.doc_date;
        v_doc_type   := r.ag_doc_type_id;
      END IF;
    END LOOP;
  
    v_sql := v_sql || ' WHERE ag_contract_id = ' || p_ag_contract_id;
  
    IF v_is_changed = 1
    THEN
      EXECUTE IMMEDIATE v_sql;
    END IF;
  
    --Чирков 185865 ДОРАБОТКА ПО ДОБАВЛЕНИЮ ДОКУМЕНТА ЗАДНИМ ЧИСЛОМ
    --Ищем ИД шапки договора
    SELECT d.ag_contract_header_id
      INTO v_contract_header
      FROM ag_documents d
     WHERE d.ag_documents_id = p_ag_doc_id;
  
    --Чирков -- находим ближайший контракт справа
    SELECT MIN(ac.date_begin)
      INTO v_next_doc_date
      FROM ag_contract ac
     WHERE ac.contract_id = v_contract_header
       AND ac.date_begin > v_doc_date;
  
    IF v_next_doc_date IS NOT NULL
    THEN
      --закрываем дату контракта датой ближайшего контракта справа - 1 сек
      UPDATE ag_contract c
         SET c.date_end = v_next_doc_date - 1 / 24 / 3600
       WHERE c.ag_documents_id = p_ag_doc_id;
    
      -- PS ищем дату последнего контракта с таким же типом договора
      /*--Чирков/закомментировал/ нигде дальше не используется
      select decode(min(ac2.date_begin),
                    null,
                    to_date('31.12.2999', 'DD.MM.YYYY'),
                    min(ac2.date_begin))
      into v_doc_date_exit
      from ag_contract ac2, ag_documents d2
      where d2.ag_documents_id = ac2.ag_documents_id
        and ac2.contract_id = v_contract_header
        and ac2.date_begin > v_doc_date
        and d2.ag_doc_type_id = v_doc_type;*/
    
      --формируем курсор по пропсам добавляемого документа
      i          := 1;
      v_temp_dog := tbl_temp_dog();
      FOR cur IN (SELECT apt.dest_field
                        ,apt.ag_props_type_id
                        ,(SELECT apc.new_value
                            FROM ag_props_change apc
                           WHERE apc.ag_documents_id = agd.ag_documents_id
                             AND apc.ag_props_type_id = apt.ag_props_type_id) new_value
                    FROM ag_documents     agd
                        ,ag_doc_type_prop adtp
                        ,ag_props_type    apt
                   WHERE agd.ag_documents_id = p_ag_doc_id
                     AND adtp.ag_doc_type_id = agd.ag_doc_type_id
                     AND adtp.ag_props_type_id = apt.ag_props_type_id)
      LOOP
        -- Сохраняем поля для обновления во временную таблицу
        v_temp_dog.extend(1);
        v_temp_dog(i).field_name := cur.dest_field;
        v_temp_dog(i).field_value := cur.new_value;
        i := i + 1;
      
        -- Чирков -- ищем ближайшеи пропс слева от даты добавляемого документа с типом доб. док-та
        BEGIN
          SELECT ag_props_change_id
                ,doc_date
            INTO v_last_props_change_id
                ,v_prop_start_date
            FROM (SELECT pc.ag_props_change_id
                        ,ad.doc_date
                    FROM ven_ag_documents ad
                        ,ag_props_change  pc
                   WHERE pc.ag_documents_id = ad.ag_documents_id
                     AND pc.ag_props_type_id = cur.ag_props_type_id
                     AND ad.ag_contract_header_id = v_contract_header
                     AND pc.is_accepted = 1
                     AND ad.doc_date < v_doc_date
                   ORDER BY ad.doc_date DESC
                           ,ad.reg_date DESC)
           WHERE rownum = 1;
        
          --Чирков -- закрываем дату пропса слева датой добавляегого документа - 1 сек
          UPDATE ag_props_change pc
             SET pc.end_date = v_doc_date - 1 / 24 / 3600
           WHERE pc.ag_props_change_id = v_last_props_change_id;
        EXCEPTION
          WHEN no_data_found THEN
            NULL;
        END;
      
        BEGIN
        
          --Чирков -- ищем ближайший контракт по дате регистрации документа, на ту же дату
        
          SELECT ag_props_change_id
                ,ag_documents_id
            INTO v_last_props_change_id
                ,v_test_doc
            FROM (SELECT pc.ag_props_change_id
                        ,ad.ag_documents_id
                    FROM ven_ag_documents ad
                        ,ag_props_change  pc
                   WHERE ad.ag_documents_id = pc.ag_documents_id
                     AND pc.ag_props_type_id = cur.ag_props_type_id
                     AND ad.ag_contract_header_id = v_contract_header
                     AND pc.is_accepted = 1
                     AND ad.doc_date = v_doc_date
                     AND pc.ag_documents_id <> p_ag_doc_id
                   ORDER BY ad.reg_date DESC)
           WHERE rownum = 1;
        
          --Чирков -- у пропса закрываем дату окончания датойд документа
          UPDATE ag_props_change pc
             SET pc.end_date = v_doc_date
           WHERE pc.ag_props_change_id = v_last_props_change_id;
        EXCEPTION
          WHEN no_data_found THEN
            NULL;
        END;
      
        --Находим дату по версии, следующей за вставляемой
        --Далее свойству добавляемого договора проставляем найденную дату - 1 сек
        --работает для: когда добавляем документ с датой которой нет у документах по договору
        --              когда добавляем документ с датой которая есть у документах по договору
        BEGIN
          SELECT ad.doc_date
            INTO v_prop_end_date
            FROM ag_documents    ad
                ,ag_props_change pc
           WHERE pc.ag_documents_id = ad.ag_documents_id
             AND ad.doc_date = (SELECT MIN(c.date_begin)
                                  FROM ag_contract c
                                 WHERE c.contract_id = v_contract_header
                                   AND c.date_begin > v_doc_date)
             AND pc.ag_props_type_id = cur.ag_props_type_id
             AND ad.ag_contract_header_id = v_contract_header
             AND pc.is_accepted = 1
             AND rownum = 1;
        
          SELECT pc.ag_props_change_id
            INTO v_last_props_change_id
            FROM ag_props_change pc
           WHERE pc.ag_documents_id = p_ag_doc_id
             AND pc.ag_props_type_id = cur.ag_props_type_id;
        
          --Обновляем дату измененного свойства
          UPDATE ag_props_change pc
             SET pc.end_date = v_prop_end_date - 1 / 24 / 3600
           WHERE pc.ag_documents_id = p_ag_doc_id
             AND pc.ag_props_type_id = cur.ag_props_type_id;
        EXCEPTION
          WHEN no_data_found THEN
            NULL;
        END;
      
      END LOOP;
    
      --Чирков -- Меняем у всех версий котрактов справа свойства на пропс доб-ого документа
      --Если пропс добавляемого документа изменялся в версии, то пропс не меняется в этой и
      --последующих версиях
      FOR cur IN (SELECT ac.ag_contract_id
                        ,d.ag_doc_type_id
                        ,d.ag_documents_id
                        ,nvl( --если по документу нет пропсов, то все равно меняем у версии св-ва
                             (SELECT DISTINCT pc.is_accepted
                                FROM ag_props_change pc
                               WHERE pc.ag_documents_id = d.ag_documents_id)
                            ,1) AS is_accepted
                    FROM ag_contract  ac
                        ,ag_documents d
                   WHERE d.ag_documents_id = ac.ag_documents_id
                     AND ac.contract_id = v_contract_header
                     AND ac.date_begin > v_doc_date
                   ORDER BY ac.date_begin)
      LOOP
      
        IF cur.is_accepted = 1
        THEN
          --находим имя типа версии контракта
          FOR cur_d IN (SELECT apt.dest_field
                              ,apt.ag_props_type_id
                          FROM ag_doc_type_prop adtp
                              ,ag_props_type    apt
                         WHERE adtp.ag_props_type_id = apt.ag_props_type_id
                           AND adtp.ag_doc_type_id = cur.ag_doc_type_id)
          LOOP
            --если есть св-во у версии контра-та такое же как у доб-емого док-та(находится в коллекции)
            --,то очищаем имя эл-та коллекции. Это значит, что мы прекращаем добавление данного св-ва
            --в версии конт-та
            FOR i IN 1 .. v_temp_dog.count
            LOOP
              IF v_temp_dog(i).field_name IS NOT NULL
                  AND v_temp_dog(i).field_name = cur_d.dest_field
              THEN
                v_temp_dog(i).field_name := NULL; --v_temp_dog.delete(i);
              END IF;
            
            END LOOP;
          END LOOP;
        
          v_sql           := 'UPDATE ag_contract SET ';
          v_update_fields := NULL;
        
          FOR i IN 1 .. v_temp_dog.count
          LOOP
            v_temp := v_temp_dog(i).field_name;
            IF v_temp IS NOT NULL
            THEN
              v_update_fields := v_update_fields || v_temp || '=' ||
                                 nvl(v_temp_dog(i).field_value, 'NULL') || ',';
            END IF;
          END LOOP;
        
          IF v_update_fields IS NULL
          THEN
            --Если нет полей для обновления, ты выходим из цикла
            EXIT;
          END IF;
        
          v_sql := v_sql || substr(v_update_fields, 1, length(v_update_fields) - 1); --Убираем последнюю запятую
          v_sql := v_sql || ' where ag_contract_id= ' || cur.ag_contract_id;
          --обновляем версию контракта новыми св-вами
          EXECUTE IMMEDIATE v_sql;
        
        END IF; --is_accepted = 1
      END LOOP;
    
    END IF;
    --end_Чирков 185865 ДОРАБОТКА ПО ДОБАВЛЕНИЮ ДОКУМЕНТА ЗАДНИМ ЧИСЛОМ
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20011
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM);
    
  END update_version;

  -- Author  : Sergey.Poskryakov
  -- Created : 16.03.2011
  -- Purpose : Получение последней версии контракта по дате
  FUNCTION get_last_version
  (
    p_ag_contract_id IN NUMBER
   ,p_doc_date       IN DATE
  ) RETURN NUMBER AS
    res           NUMBER;
    p_contract_id NUMBER;
  BEGIN
  
    SELECT MAX(ac1.ag_contract_id)
      INTO res
      FROM ag_contract ac1
     WHERE ac1.date_end =
           (SELECT MAX(ac.date_end)
              FROM ag_contract ac
             WHERE ac.contract_id IN (SELECT DISTINCT c.contract_id
                                        FROM ag_contract c
                                       WHERE c.ag_contract_id = p_ag_contract_id)
               AND ac.date_begin < p_doc_date)
       AND ac1.contract_id =
           (SELECT DISTINCT c.contract_id FROM ag_contract c WHERE c.ag_contract_id = p_ag_contract_id);
  
    /*
     select c.contract_id into p_contract_id
     from ag_contract c where c.ag_contract_id = p_ag_contract_id;
    
     select max(ac1.ag_contract_id) into res from ag_contract ac1 where ac1.date_begin=
        (select min(ac.date_begin) from ag_contract ac
          where ac.contract_id = p_contract_id
          and ac.date_begin > p_doc_date
         )
         and ac1.contract_id=p_contract_id;
    */
    RETURN res;
  END get_last_version;
  -- Author  : ALEXEY.KATKEVICH
  -- Created : 16.04.2010 16:49:29
  -- Purpose : Изменение дерева подчиенности на основании документа
  PROCEDURE update_tree(p_ag_doc_id PLS_INTEGER) IS
    proc_name      VARCHAR2(25) := 'Update_tree';
    v_lead         PLS_INTEGER;
    v_p_lead       PLS_INTEGER;
    v_ag_tree_id   PLS_INTEGER;
    v_doc_date     DATE;
    v_tree_date    DATE;
    v_is_leaf      PLS_INTEGER;
    v_ch_cnt       PLS_INTEGER;
    v_ag_ch        PLS_INTEGER;
    v_new_doc_date DATE; --PS
    v_new_end_date DATE; --PS
    v_parent_id    NUMBER;
  BEGIN
    --Определяем дату нового документа
    SELECT c.date_begin INTO v_new_doc_date FROM ag_contract c WHERE c.ag_documents_id = p_ag_doc_id;
  
    FOR r IN (SELECT CASE
                       WHEN apc.new_value = 'NULL' THEN
                        NULL
                       ELSE
                        (SELECT ac.contract_id
                           FROM ag_contract ac
                          WHERE ac.ag_contract_id = apc.new_value)
                     END v_lead
              --     decode(apc.new_value,'NULL',NULL,apc.new_value) v_lead
                FROM ag_props_change apc
                    ,ag_props_type   apt
               WHERE apc.ag_documents_id = p_ag_doc_id
                 AND apt.ag_props_type_id = apc.ag_props_type_id
                 AND apt.brief = 'LEAD_PROP')
    LOOP
    
      --Обновление дерева
      --Ищем запись на дату документа
      --Ищем версию на дату документа
      BEGIN
        SELECT at.ag_parent_header_id
              ,at.ag_agent_tree_id
              ,at.is_leaf
              ,at.date_begin
              ,ad.doc_date
              ,ad.ag_contract_header_id
          INTO v_p_lead
              ,v_ag_tree_id
              ,v_is_leaf
              ,v_tree_date
              ,v_doc_date
              ,v_ag_ch
          FROM ag_agent_tree at
              ,ag_documents  ad
         WHERE ad.ag_contract_header_id = at.ag_contract_header_id
           AND at.date_begin = v_new_doc_date
           AND ad.ag_documents_id = p_ag_doc_id;
      EXCEPTION
        WHEN no_data_found THEN
          --если на дату документа не создана версия с св-вом руководитель, то ищем на дату < doc_date
          SELECT aat.ag_parent_header_id
                ,aat.ag_agent_tree_id
                ,agd.doc_date
                ,aat.date_begin
                ,aat.is_leaf
                ,agd.ag_contract_header_id
            INTO v_p_lead
                ,v_ag_tree_id
                ,v_doc_date
                ,v_tree_date
                ,v_is_leaf
                ,v_ag_ch
            FROM ag_agent_tree aat
                ,ag_documents  agd
           WHERE aat.ag_contract_header_id = agd.ag_contract_header_id
                -- PS  AND aat.date_end = TO_DATE('31.12.2999','dd.mm.yyyy')
             AND aat.date_begin = (SELECT MAX(at.date_begin)
                                     FROM ag_agent_tree at
                                         ,ag_documents  ad
                                    WHERE ad.ag_contract_header_id = at.ag_contract_header_id
                                      AND ad.ag_documents_id = p_ag_doc_id
                                      AND at.date_begin < v_new_doc_date)
             AND agd.ag_documents_id = p_ag_doc_id;
      END;
    
      --PS Ищем следующую версию для определения даты окончания
      BEGIN
        SELECT aat.date_begin - INTERVAL '1' SECOND
          INTO v_new_end_date
          FROM ag_agent_tree aat
              ,ag_documents  agd
         WHERE aat.ag_contract_header_id = agd.ag_contract_header_id
           AND aat.date_begin = (SELECT MIN(at.date_begin)
                                   FROM ag_agent_tree at
                                       ,ag_documents  ad
                                  WHERE ad.ag_contract_header_id = at.ag_contract_header_id
                                    AND ad.ag_documents_id = p_ag_doc_id
                                    AND at.date_begin > v_new_doc_date)
           AND agd.ag_documents_id = p_ag_doc_id;
      EXCEPTION
        WHEN no_data_found THEN
          v_new_end_date := to_date('31.12.2999', 'dd.mm.yyyy');
      END;
      --Проверка на то что найденый руководитель отличен от предыдущего
      IF nvl(v_p_lead, 0) <> nvl(r.v_lead, 0)
      THEN
        --Если изменения на одну и ту же дату то новую ветку не создаем а только обновляем
        IF v_doc_date = v_tree_date
        THEN
          UPDATE ag_agent_tree a
             SET a.ag_parent_header_id = r.v_lead
           WHERE ag_agent_tree_id = v_ag_tree_id;
        ELSE
          UPDATE ag_agent_tree
             SET date_end = v_doc_date - 1 / 24 / 3600
           WHERE ag_agent_tree_id = v_ag_tree_id;
        
          INSERT INTO ven_ag_agent_tree
            (ag_contract_header_id, ag_parent_header_id, date_begin, date_end, is_leaf)
          VALUES
            (v_ag_ch
            ,r.v_lead
            ,v_doc_date
            ,v_new_end_date
            , -- PS  TO_DATE('31.12.2999','dd.mm.yyyy'),
             v_is_leaf);
        END IF;
        --Изменяем признак листа у нового руководителя
        IF r.v_lead IS NOT NULL
        THEN
          UPDATE ag_agent_tree
             SET is_leaf = 0
           WHERE ag_contract_header_id = r.v_lead
             AND date_end = v_new_end_date; -- PS  TO_DATE('31.12.2999','dd.mm.yyyy');
        END IF;
        --Изменяем признак листа у предыдущего руковдителя агента
        IF v_p_lead IS NOT NULL
        THEN
          SELECT COUNT(*)
            INTO v_ch_cnt
            FROM ag_agent_tree aat
           WHERE aat.ag_parent_header_id = v_p_lead
             AND aat.date_end = v_new_end_date; -- PS  TO_DATE('31.12.2999','dd.mm.yyyy');
        
          IF v_ch_cnt > 0
          THEN
            v_is_leaf := 0;
          ELSE
            v_is_leaf := 1;
          END IF;
        
          UPDATE ag_agent_tree
             SET is_leaf = v_is_leaf
           WHERE ag_contract_header_id = v_p_lead
             AND date_end = v_new_end_date; -- PS  TO_DATE('31.12.2999','dd.mm.yyyy');
        END IF;
      END IF;
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM);
  END update_tree;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 22.04.2010 16:43:23
  -- Purpose : Устанавливает статус договора в зависимости от статуса документа
  PROCEDURE set_contract_state(p_ag_documents_id PLS_INTEGER) IS
    proc_name    VARCHAR2(25) := 'Set_contract_state';
    v_adt_brief  VARCHAR2(25);
    v_adt_date   DATE;
    v_ach_id     PLS_INTEGER;
    v_doc_status VARCHAR2(50);
  BEGIN
    SELECT adt.brief
          ,ad.ag_contract_header_id
          ,ad.doc_date
          ,doc.get_doc_status_brief(ad.ag_documents_id, to_date('31.12.2999', 'dd.mm.yyyy'))
      INTO v_adt_brief
          ,v_ach_id
          ,v_adt_date
          ,v_doc_status
      FROM ag_documents ad
          ,ag_doc_type  adt
     WHERE ad.ag_documents_id = p_ag_documents_id
       AND ad.ag_doc_type_id = adt.ag_doc_type_id;
  
    CASE v_adt_brief
      WHEN 'NEW_AD' THEN
        CASE v_doc_status
          WHEN 'PROJECT' THEN
            doc.set_doc_status(v_ach_id, 'PROJECT', v_adt_date);
          WHEN 'CONFIRMED' THEN
            doc.set_doc_status(v_ach_id, 'CURRENT', v_adt_date + 1 / 24 / 3600);
          WHEN 'CANCEL' THEN
            doc.set_doc_status(v_ach_id, 'CANCEL', v_adt_date + 2 / 24 / 3600);
        END CASE;
      WHEN 'BREAK_AD' THEN
        CASE v_doc_status
          WHEN 'CONFIRMED' THEN
            doc.set_doc_status(v_ach_id, 'BREAK', v_adt_date + 2 / 24 / 3600);
          ELSE
            NULL;
        END CASE;
      ELSE
        NULL;
    END CASE;
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM);
  END set_contract_state;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 13.04.2010 10:25:11
  -- Purpose : Добавление банковских реквизитов
  PROCEDURE add_bank_prop(p_ag_documents_id PLS_INTEGER) IS
    proc_name  VARCHAR2(25) := 'add_bank_prop';
    v_doc_type VARCHAR2(20);
    v_ag_ch    PLS_INTEGER;
  BEGIN
    SELECT adt.brief
          ,agd.ag_contract_header_id
      INTO v_doc_type
          ,v_ag_ch
      FROM ag_documents agd
          ,ag_doc_type  adt
     WHERE 1 = 1
       AND agd.ag_documents_id = p_ag_documents_id
       AND agd.ag_doc_type_id = adt.ag_doc_type_id;
  
    IF v_doc_type NOT IN ('PAY_PROP_CHG', 'NEW_AD')
    THEN
      RETURN;
    END IF;
  
    INSERT INTO ven_ag_bank_props
      (ag_contract_header_id, ag_documents_id)
    VALUES
      (v_ag_ch, p_ag_documents_id);
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM);
  END add_bank_prop;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 08.04.2010 11:53:09
  -- Purpose : Возвращает стостояние работы нужна для пересылки сообщений в forms
  FUNCTION state(p_message OUT NOCOPY VARCHAR2) RETURN VARCHAR2 IS
    proc_name VARCHAR2(25) := 'State';
    v_state   VARCHAR2(10);
  BEGIN
    v_state   := g_message.state;
    p_message := g_message.message;
  
    g_message.state   := 'Ok'; --'Warn' --'Err'
    g_message.message := 'Нормальное заврешение процедуры';
  
    RETURN(v_state);
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM);
  END state;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 12.05.2010 13:38:38
  -- Purpose : Процедура производит передачу портфеля из старого АД в новый
  PROCEDURE policy_transfer(p_ag_contract_header_id PLS_INTEGER) IS
    proc_name  VARCHAR2(25) := 'Policy_transfer';
    v_agh_date DATE;
    v_pad      PLS_INTEGER;
  BEGIN
    SELECT ach.date_begin
      INTO v_agh_date
      FROM ag_contract_header ach
     WHERE ach.ag_contract_header_id = p_ag_contract_header_id;
  
    FOR r IN (SELECT apv.ag_prev_header_id
                FROM ag_prev_dog apv
               WHERE apv.ag_contract_header_id = p_ag_contract_header_id
                 AND apv.company = 'Реннесанс Жизнь' --'Renlife'
              )
    LOOP
    
      FOR p IN (SELECT *
                  FROM ven_p_policy_agent_doc apd
                 WHERE apd.ag_contract_header_id = r.ag_prev_header_id
                   AND doc.get_doc_status_brief(apd.p_policy_agent_doc_id) = 'CURRENT'
                      --Чирков /266986: "Ошибка при подтверждении, доработки в системе"/
                      --при передаче КП есть ДС в которых дата окончания может быть больше чем
                      --дата начала действия нового агента по ДС
                   AND NOT EXISTS
                 (SELECT 1
                          FROM ins.p_pol_header ph
                              ,ins.p_policy     pp
                         WHERE ph.policy_header_id = apd.policy_header_id
                           AND pp.policy_id = ph.policy_id
                           AND trunc(pp.end_date) < greatest(v_agh_date, apd.date_begin + 1))
                --end_266986
                )
      LOOP
      
        IF p.date_begin > v_agh_date
        THEN
          v_agh_date := p.date_begin + 1;
        END IF;
      
        UPDATE ven_p_policy_agent_doc a
           SET a.date_end = trunc(v_agh_date, 'DD') - 1 / 24 / 3600
         WHERE a.p_policy_agent_doc_id = p.p_policy_agent_doc_id;
      
        doc.set_doc_status(p.p_policy_agent_doc_id, 'CANCEL', trunc(v_agh_date, 'DD') - 1 / 24 / 3600);
        /*                         'AUTO' ,
        'Передача в новый модуль АД');*/
      
        SELECT sq_p_policy_agent_doc.nextval INTO v_pad FROM dual;
      
        INSERT INTO ven_p_policy_agent_doc
          (p_policy_agent_doc_id
          ,doc_templ_id
          ,ag_contract_header_id
          ,date_begin
          ,date_end
          ,policy_header_id
          ,subagent
          ,note)
        VALUES
          (v_pad
          ,p.doc_templ_id
          ,p_ag_contract_header_id
          ,v_agh_date
          ,p.date_end
          ,p.policy_header_id
          ,p.subagent
          ,'Передача в новый модуль АД');
      
        doc.set_doc_status(v_pad, 'NEW', trunc(v_agh_date, 'DD'));
      
        doc.set_doc_status(v_pad, 'CURRENT', trunc(v_agh_date, 'DD') + 1 / 24 / 3600);
      
      END LOOP;
    END LOOP;
  
  EXCEPTION
    WHEN OTHERS THEN
      g_message.state   := 'Err'; --'Warn' --'Err'
      g_message.message := 'Ошибка при передаче договоров страхования ' || SQLERRM;
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM);
  END policy_transfer;

  -- Author  : VESELEK
  -- Created : 28.05.2010 12:21:45
  -- Purpose : Процедура производит передачу портфеля с агента на агента
  --- Modified : 21.03.2014
  --- Author   : Гаргонов Д.А.
  --- Purpose  : 312860 Доработка процедуры передачи Клиентского портфеля при расторжении САД

  /*
    заявка 332603 перевод на прямое сопровождение
    Доброхотова И.  
    К коду Прямое сопровождение компании (329826)
    добавила еще три  в зависимости от канала продаж (8187958, 8187959, 8187960)
  */
  FUNCTION transmit_policy
  (
    pv_policy_header_id         IN NUMBER
   ,p_old_ag_contract_header_id IN NUMBER
   ,p_new_ag_contract_header_id IN NUMBER
   ,p_date_break                IN DATE
   ,msg                         OUT NOCOPY VARCHAR2
  ) RETURN NUMBER IS
    RESULT                      NUMBER;
    v_new_p_policy_agent_doc_id ins.p_policy_agent_doc.p_policy_agent_doc_id%TYPE;
    v_old_p_policy_agent_doc_id ins.p_policy_agent_doc.p_policy_agent_doc_id%TYPE;
    v_date_begin                ins.p_policy_agent_doc.date_begin%TYPE;
    v_doc_templ_id              ins.doc_templ.doc_templ_id%TYPE;
    v_policy_header_id          ins.p_pol_header.policy_header_id%TYPE;
    v_date_end                  ins.p_policy_agent_doc.date_end%TYPE;
    v_subagent                  ins.p_policy_agent_doc.subagent%TYPE;
    v_old_agent_id              ins.ag_contract_header.ag_contract_header_id%TYPE;
    v_old_agent_sc              ins.t_sales_channel.brief%TYPE;
    v_date_break                DATE;
  BEGIN
    SAVEPOINT func_trans_pol;
    --находим ID агента на котором договор сейчас.
    BEGIN
      SELECT agh.agent_id
            ,sc.brief
        INTO v_old_agent_id
            ,v_old_agent_sc
        FROM ins.ag_contract_header agh
            ,ins.t_sales_channel    sc
       WHERE agh.ag_contract_header_id = p_old_ag_contract_header_id
         AND sc.id = agh.t_sales_channel_id;
    EXCEPTION
      WHEN no_data_found THEN
        v_old_agent_id := -1;
        v_old_agent_sc := '!';
    END;
    --Выборка даныйх по ДС.
    BEGIN
      SELECT apd.p_policy_agent_doc_id
            ,apd.date_begin
            ,apd.doc_templ_id
            ,apd.policy_header_id
            ,ins.pkg_policy.get_policy_end_date(apd.policy_header_id)
            ,apd.subagent
        INTO v_old_p_policy_agent_doc_id
            ,v_date_begin
            ,v_doc_templ_id
            ,v_policy_header_id
            ,v_date_end
            ,v_subagent
        FROM ins.ven_p_policy_agent_doc apd
            ,ins.p_pol_header           ph
            ,ins.p_policy               pp_l
            ,ins.p_policy               pp_a
            ,ins.document               doc
            ,ins.doc_status_ref         dsr
            ,ins.document               doc_l
            ,ins.doc_status_ref         dsr_l
            ,ins.document               doc_a
            ,ins.doc_status_ref         dsr_a
       WHERE ph.policy_header_id = apd.policy_header_id
         AND ph.last_ver_id = pp_l.policy_id
         AND ph.policy_id = pp_a.policy_id
         AND apd.p_policy_agent_doc_id = doc.document_id
         AND doc.doc_status_ref_id = dsr.doc_status_ref_id
         AND dsr.brief = 'CURRENT'
         AND pp_l.policy_id = doc_l.document_id
         AND doc_l.doc_status_ref_id = dsr_l.doc_status_ref_id
         AND pp_a.policy_id = doc_a.document_id
         AND doc_a.doc_status_ref_id = dsr_a.doc_status_ref_id
         AND (dsr_l.brief NOT IN ('READY_TO_CANCEL' --'Готовится к расторжению'
                                 ,'TO_QUIT' --'К прекращению'
                                 ,'TO_QUIT_CHECK_READY' --'К прекращению. Готов для проверки'
                                 ,'TO_QUIT_CHECKED' --'К прекращению. Проверен'
                                 ,'RECOVER_DENY' --'Отказ в Восстановлении'
                                 ,'QUIT' --'Прекращен'
                                 ,'QUIT_REQ_QUERY' --'Прекращен. Запрос реквизитов'
                                 ,'QUIT_REQ_GET' --'Прекращен. Реквизиты получены'
                                 ,'QUIT_TO_PAY' --'Прекращен.К выплате'
                                 ,'BREAK' --'Расторгнут'
                                  ) OR v_old_agent_id IN (329826, 8187958, 8187959, 8187960) --Для ПСК разрешено передавать ДС в указанных выше статусах.
             OR (v_old_agent_sc IN ('RLA', 'BANK', 'BR') AND
             dsr_l.brief NOT IN ('STOPED' --Завершен
                                     ,'CANCEL' --Отменен
                                     ,'STOP' --Приостановлен
                                      ))
             --Для данных КП разрешено передовать ДС статус послдней версии которых
             --отличен от указанных выше.
             )
         AND (dsr_a.brief NOT IN ('STOPED' --Завершен
                                 ,'CANCEL' --Отменен
                                 ,'STOP' --Приостановлен
                                  ) OR v_old_agent_sc IN ('RLA', 'BANK', 'BR'))
            --Для данных КП разрешено передовать ДС 
            --статус активной версии которых указан выше.
         AND pp_a.end_date >= p_date_break
         AND ph.policy_header_id = pv_policy_header_id
         AND apd.ag_contract_header_id = p_old_ag_contract_header_id;
    EXCEPTION
      WHEN no_data_found THEN
        msg := 'Ошибка при отборе ДС для передачи.';
        RETURN 0;
    END;
  
    v_date_break := p_date_break;
    IF v_date_begin > v_date_break
    THEN
      v_date_break := v_date_begin;
    END IF;
  
    --Проставляем дату передачи, ДС и изменяем статус договора в КП старого агента.
    UPDATE ven_p_policy_agent_doc a
       SET a.date_end = trunc(v_date_break, 'DD') - 1 / 24 / 3600
     WHERE a.p_policy_agent_doc_id = v_old_p_policy_agent_doc_id;
    doc.set_doc_status(v_old_p_policy_agent_doc_id
                      ,'CANCEL'
                      ,trunc(v_date_break, 'DD') + 2 / 24 / 3600);
  
    --Создаём записи в КП нового агента.
    SELECT sq_p_policy_agent_doc.nextval INTO v_new_p_policy_agent_doc_id FROM dual;
    INSERT INTO ven_p_policy_agent_doc
      (p_policy_agent_doc_id
      ,doc_templ_id
      ,ag_contract_header_id
      ,date_begin
      ,date_end
      ,policy_header_id
      ,subagent
      ,note)
    VALUES
      (v_new_p_policy_agent_doc_id
      ,v_doc_templ_id
      ,p_new_ag_contract_header_id
      ,trunc(v_date_break, 'DD')
      ,v_date_end
      ,v_policy_header_id
      ,v_subagent
      ,'Передача пакета');
  
    --Проставляем статусы.
    doc.set_doc_status(v_new_p_policy_agent_doc_id, 'NEW', trunc(v_date_break, 'DD') + 1 / 24 / 3600);
    doc.set_doc_status(v_new_p_policy_agent_doc_id
                      ,'CURRENT'
                      ,trunc(v_date_break, 'DD') + 2 / 24 / 3600);
  
    RETURN RESULT;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK TO func_trans_pol;
      RETURN SQLCODE;
    
  END transmit_policy;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 12.05.2010 14:05:35
  -- Purpose : Процедура обеспечивает поддержку старого функционала АД по ДС
  PROCEDURE old_policy_agent_cre(par_policy_agent_doc_id PLS_INTEGER) IS
    proc_name      VARCHAR2(25) := 'Old_policy_agent_cre';
    v_policy_a_doc p_policy_agent_doc%ROWTYPE;
    v_p_policy_a   PLS_INTEGER;
  BEGIN
  
    SELECT *
      INTO v_policy_a_doc
      FROM p_policy_agent_doc apd
     WHERE apd.p_policy_agent_doc_id = par_policy_agent_doc_id;
  
    SELECT sq_p_policy_agent.nextval INTO v_p_policy_a FROM dual;
  
    --Агент по ДС
    INSERT INTO ven_p_policy_agent
      (p_policy_agent_id
      ,ag_contract_header_id
      ,ag_type_rate_value_id
      ,date_end
      ,date_start
      ,part_agent
      ,policy_header_id
      ,p_policy_agent_doc_id
      ,status_date
      ,status_id
      ,subagent)
    VALUES
      (v_p_policy_a
      ,v_policy_a_doc.ag_contract_header_id
      ,3
      ,v_policy_a_doc.date_end
      ,v_policy_a_doc.date_begin
      ,100
      ,v_policy_a_doc.policy_header_id
      ,par_policy_agent_doc_id
      ,SYSDATE
      ,1
      ,v_policy_a_doc.subagent);
  
    --Ставки АД по ДС - нужны для формирования проводок МСФО
    --НО Есть подозрения что эти проводки уже давно не учитываются
    --pkg_agent_1.Define_Agent_Prod_Line(v_p_policy_a,v_policy_a_doc.ag_contract_header_id,sysdate);
    /* INSERT INTO ven_p_policy_agent_com
               (p_policy_agent_com_id,
                t_product_line_id,
                p_policy_agent_id,
                ag_type_defin_rate_id,
                val_com)
    (SELECT sq_p_policy_agent_com.NEXTVAL,
           tpl.ID prod_line_id,
           v_p_policy_a,
           2,
           1
      FROM ven_t_product         tp,
           ven_t_product_version tpv,
           ven_t_product_ver_lob tpvl,
           ven_t_product_line    tpl,
           p_pol_header ph
     WHERE tpv.product_id(+) = tp.product_id
       AND tpvl.product_version_id(+) = tpv.t_product_version_id
       AND tpl.product_ver_lob_id = tpvl.t_product_ver_lob_id
       AND tp.product_id = ph.product_id
       AND ph.policy_header_id = v_policy_a_doc.policy_header_id
       AND tpl.description <> 'Административные издержки');*/
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM);
  END old_policy_agent_cre;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 12.05.2010 14:44:11
  -- Purpose : Процедура обеспечивает поддержку старого функционала АД по ДС
  PROCEDURE old_policy_agent_stat(par_policy_agent_doc_id PLS_INTEGER) IS
    proc_name  VARCHAR2(25) := 'Old_policy_agent_stat';
    v_pa_stat  VARCHAR2(50);
    v_pa_date  DATE;
    v_date_end DATE;
  BEGIN
    SELECT ds.start_date
          ,dsr.brief
          ,pad.date_end
      INTO v_pa_date
          ,v_pa_stat
          ,v_date_end
      FROM doc_status         ds
          ,doc_status_ref     dsr
          ,p_policy_agent_doc pad
     WHERE ds.doc_status_id = doc.get_doc_status_rec_id(pad.p_policy_agent_doc_id)
       AND ds.doc_status_ref_id = dsr.doc_status_ref_id
       AND pad.p_policy_agent_doc_id = par_policy_agent_doc_id
       AND ds.document_id = pad.p_policy_agent_doc_id;
  
    CASE v_pa_stat
      WHEN 'CANCEL' THEN
        UPDATE p_policy_agent pa
           SET pa.status_id   = 2
              ,pa.status_date = v_pa_date
              ,pa.date_end    = v_date_end
         WHERE pa.p_policy_agent_doc_id = par_policy_agent_doc_id;
      WHEN 'ERROR' THEN
        UPDATE p_policy_agent pa
           SET pa.status_id   = 4
              ,pa.status_date = v_pa_date
         WHERE pa.p_policy_agent_doc_id = par_policy_agent_doc_id;
      ELSE
        NULL;
    END CASE;
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM);
  END old_policy_agent_stat;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 22.07.2010 13:09:19
  -- Purpose : Добавляет АД в список "старых"
  PROCEDURE add_to_prev_dog(p_ag_contract_header_id PLS_INTEGER) IS
    proc_name VARCHAR2(25) := 'Add_to_prev_dog';
  BEGIN
  
    INSERT INTO ven_ag_prev_dog
      (ag_prev_header_id, company, fio, num, stat, ag_document_id)
      SELECT ach.ag_contract_header_id
            ,'Реннесанс Жизнь'
            ,cn.obj_name_orig
            ,ach.num
            ,doc.get_doc_status_name(ach.ag_contract_header_id)
            ,
             -- Байтин А.
             -- Заявка №202025
             -- Получаем Расторжение, которое не в статусе Отменен
             (SELECT doc.ag_documents_id
                FROM ag_documents   doc
                    ,ag_doc_type    dt
                    ,document       dc
                    ,doc_status_ref dsr
               WHERE doc.ag_contract_header_id = ach.ag_contract_header_id
                 AND doc.ag_doc_type_id = dt.ag_doc_type_id
                 AND dt.brief = 'BREAK_AD'
                 AND doc.ag_documents_id = dc.document_id
                 AND dc.doc_status_ref_id = dsr.doc_status_ref_id
                 AND dsr.brief != 'CANCEL'
                    -- На всякий случай
                 AND rownum = 1)
        FROM ven_ag_contract_header ach
            ,contact                cn
       WHERE ach.ag_contract_header_id = p_ag_contract_header_id
         AND ach.agent_id = cn.contact_id;
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM);
  END add_to_prev_dog;

  /*
    Байтин А.
    Заявка №202025
    Если договор переводится из Расторгнут в Действующий, запись необходимо удалить.
  */
  PROCEDURE delete_from_prev_dog(par_ag_contract_header_id NUMBER) IS
  BEGIN
    DELETE FROM ven_ag_prev_dog pd WHERE pd.ag_prev_header_id = par_ag_contract_header_id;
  END delete_from_prev_dog;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 12.07.2010 16:36:06
  -- Purpose : Запускает процесс импорта в b2b для определенных типов документов
  PROCEDURE import_ad_changes(p_ag_documnet_id PLS_INTEGER) IS
    proc_name    VARCHAR2(25) := 'Import_ad_changes';
    v_adt_brief  VARCHAR2(25);
    v_ach_id     PLS_INTEGER;
    v_doc_status VARCHAR2(50);
    v_doc_class  PLS_INTEGER;
  BEGIN
  
    SELECT adt.brief
          ,ad.ag_contract_header_id
          ,doc.get_doc_status_brief(ad.ag_documents_id, to_date('31.12.2999', 'dd.mm.yyyy'))
          ,adt.doc_class
      INTO v_adt_brief
          ,v_ach_id
          ,v_doc_status
          ,v_doc_class
      FROM ag_documents ad
          ,ag_doc_type  adt
     WHERE ad.ag_documents_id = p_ag_documnet_id
       AND ad.ag_doc_type_id = adt.ag_doc_type_id;
  
    IF v_doc_class = 2
    THEN
      RETURN;
    END IF;
    --     IF v_adt_brief NOT IN ('LEAD_CHG','AGENCY_CHG') THEN RETURN; END IF;
  
    IF v_doc_status = 'CONFIRMED'
    THEN
    
      import_ad(v_ach_id);
    
    END IF;
  
  EXCEPTION
    WHEN http_import_exception THEN
      raise_application_error(-20001
                             ,'Ошибка передачи данных в B2B. Попробуйте позже.');
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM);
  END import_ad_changes;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 12.05.2010 13:20:12
  -- Purpose : Процедруа запускает процесс импорта договора в b2b
  -- Чирков переписал работу import_ad и pkg_borlas_b2b.import_agent_contract
  -- по заявке 283676 Доработать обработчик ошибки процесса Импорт АД в B2B  
  PROCEDURE import_ad(p_ag_contract_header_id PLS_INTEGER) IS
    proc_name VARCHAR2(25) := 'Import_AD';
    v_err     VARCHAR2(255);
    v_status  VARCHAR2(50);
    v_oper    PLS_INTEGER;
  BEGIN
    BEGIN
      v_status := doc.get_doc_status_brief(p_ag_contract_header_id);
    
      CASE
        WHEN v_status = 'CURRENT' THEN
          v_oper := 1;
          -- Байтин А.
      -- Добавил передачу отмененных как и расторгнутые
        WHEN v_status IN ('CANCEL', 'BREAK') THEN
          v_oper := 0;
        ELSE
          RETURN;
          --    raise_application_error(-20001, 'у агента статус '||v_status);
      END CASE;
    
      --импортируем агента в b2b
      pkg_borlas_b2b.import_agent_contract(p_ag_contract_header_id, v_oper, v_err);
    EXCEPTION
      WHEN OTHERS THEN
        raise_application_error(-20001
                               ,'Ошибка при выполнении ' || proc_name || SQLERRM);
    END;
  
    IF v_err IS NOT NULL
    THEN
      g_message.state   := 'Err'; --'Warn'; --'Ok'
      g_message.message := v_err;
      raise_application_error(-20002
                             ,'Ошибка при выполнении ' || proc_name || ' ' || v_err);
    END IF;
  END import_ad;

  --для добавления даты по последней продаже из B2B
  --заполнение таблицы
  PROCEDURE ins_to_agn_sales_ops IS
    proc_name VARCHAR2(30) := 'INS_TO_AGN_SALES_OPS';
  BEGIN
  
    DELETE FROM agn_sales_ops;
  
    INSERT INTO agn_sales_ops
      (agn_sales_ops_id, agent_num)
      SELECT sq_agn_sales_ops.nextval
            ,to_number(agh.num) num_ad
        FROM ven_ag_contract_header agh
       WHERE doc.get_doc_status_name(agh.ag_contract_header_id) NOT IN ('Отменен')
         AND nvl(agh.is_new, 0) = 1;
  
    -- Байтин А.
    -- Переделал на более быстрый механизм
    --Process_http_import_sales;
    pkg_borlas_b2b.import_agent_sales_dates;
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM);
  END ins_to_agn_sales_ops;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 01.03.2011 19:37:24
  -- Purpose : Производит импорт АД в b2b через http
  PROCEDURE process_http_import_sales IS
    proc_name    VARCHAR2(30) := 'Process_http_import_sales';
    v_send_str   VARCHAR2(2000);
    v_get_str    VARCHAR2(2000);
    v_res_o      PLS_INTEGER;
    v_oper_t     VARCHAR2(20);
    v_err_text   VARCHAR2(2000);
    v_sales_date VARCHAR2(20);
  BEGIN
    /*
    TODO: owner="alexey.katkevich" category="Fix" priority="1 - High" created="01.03.2011"
    text="Переписать процедуру с учётом 1 - отдельной таблицы для настройки импорта (адресс / пароль и т.д.) 2- разбор полученного ответа с соответсвующими изменениями"
    */
    pkg_http_gate.set_http_address('https://npf.renlife.com/gateway/GetLastDateSalesAgent');
  
    FOR imp IN (SELECT aso.agn_sales_ops_id FROM agn_sales_ops aso)
    LOOP
    
      v_send_str := get_json_string_ops(imp.agn_sales_ops_id);
    
      UPDATE agn_sales_ops a
         SET a.operation_date = SYSDATE
       WHERE a.agn_sales_ops_id = imp.agn_sales_ops_id;
    
      v_get_str := pkg_http_gate.send_http_post('agent_key=195842589a578853e49d95c1a715df4e&agent_json=' ||
                                                v_send_str);
    
      --переписать на regexp_substr
      SELECT substr(v_get_str, instr(v_get_str, 'cod') + 5, 1)
            ,
             
             substr(v_get_str
                   ,instr(v_get_str, 'operation') + 12
                   ,((instr(v_get_str, 'errorText') - 3) - (instr(v_get_str, 'operation') + 12)))
            ,
             
             substr(v_get_str
                   ,instr(v_get_str, 'errorText') + 12
                   ,((instr(v_get_str, 'date') - 3) - (instr(v_get_str, 'errorText') + 12)))
            ,
             
             substr(v_get_str
                   ,instr(v_get_str, 'date') + 7
                   ,((length(v_get_str)) - (instr(v_get_str, 'date') + 8)))
      --SUBSTR(to_char(v_get_str),-12)
        INTO v_res_o
            ,v_oper_t
            ,v_err_text
            ,v_sales_date
        FROM dual;
    
      /*
      {"cod":0,"operation":"none","errorText":"NO LOGIN"}
      
      {"cod":1,"operation":"insert","errorText":""}
      */
    
      UPDATE agn_sales_ops a
         SET a.operation  = v_oper_t
            ,a.error_text = decode(v_res_o, 0, ' Error text : ' || v_err_text, NULL)
            ,a.state      = decode(v_res_o, 0, 99, 1, 1, 99)
            ,a.sales_date = decode(v_sales_date, '00.00.0000', '01.01.1900', v_sales_date)
       WHERE a.agn_sales_ops_id = imp.agn_sales_ops_id;
    
    END LOOP;
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM);
  END process_http_import_sales;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 01.03.2011 19:39:03
  -- Purpose : Получает json строку для записи в agn_gate_table
  FUNCTION get_json_string_ops(agn_sales_ops_id PLS_INTEGER) RETURN VARCHAR2 IS
    proc_name    VARCHAR2(30) := 'Get_json_string_ops';
    v_stmnt      VARCHAR2(2000) := 'SELECT ' || chr(10);
    v_res_string VARCHAR2(2000);
  BEGIN
  
    FOR r IN (SELECT dtc.column_name
                    ,dtc.data_type
                    ,row_number() over(ORDER BY dtc.column_name) rn
                    ,COUNT(*) over(PARTITION BY 1) cnt
                FROM user_tab_cols     dtc
                    ,user_col_comments ctc
               WHERE dtc.table_name = 'AGN_SALES_OPS'
                 AND dtc.table_name = ctc.table_name
                 AND dtc.column_name = ctc.column_name
                 AND dtc.table_name = ctc.table_name
                 AND ctc.comments NOT LIKE '%(NOT IMPORTED)'
               ORDER BY 1)
    LOOP
    
      CASE r.data_type
        WHEN 'NUMBER' THEN
          v_stmnt := v_stmnt || '''"' || r.column_name || '" : ''|| ' || r.column_name;
          IF r.rn != r.cnt
          THEN
            v_stmnt := v_stmnt || '||'',''||' || chr(10);
          END IF;
        WHEN 'VARCHAR2' THEN
          v_stmnt := v_stmnt || '''"' || r.column_name || '" : "''|| ' || 'replace(' || r.column_name ||
                     ',''"'',''\"'') ||''"''';
          IF r.rn != r.cnt
          THEN
            v_stmnt := v_stmnt || '||'', ''||' || chr(10);
          END IF;
        WHEN 'DATE' THEN
          v_stmnt := v_stmnt || '''"' || r.column_name || '" : "''||to_char(' || r.column_name ||
                     ',''DD.MM.YYYY'')||''"''';
          IF r.rn != r.cnt
          THEN
            v_stmnt := v_stmnt || '||'', ''||' || chr(10);
          END IF;
        ELSE
          NULL;
      END CASE;
    END LOOP;
  
    v_stmnt := v_stmnt || chr(10) ||
               ' INTO :v_res_str FROM AGN_SALES_OPS WHERE AGN_SALES_OPS_ID = :v_agn_id';
  
    EXECUTE IMMEDIATE v_stmnt
      INTO v_res_string
      USING agn_sales_ops_id;
  
    v_res_string := '{' || v_res_string || '}';
  
    RETURN(v_res_string);
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM);
  END get_json_string_ops;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 01.03.2011 19:37:24
  -- Purpose : Производит импорт АД в b2b через http
  PROCEDURE process_http_import IS
    proc_name  VARCHAR2(20) := 'Process_http_import';
    v_send_str VARCHAR2(2000);
    v_get_str  VARCHAR2(2000);
    v_res_o    PLS_INTEGER;
    v_oper_t   VARCHAR2(20);
    v_err_text VARCHAR2(2000);
  BEGIN
    /*
    TODO: owner="alexey.katkevich" category="Fix" priority="1 - High" created="01.03.2011"
    text="Переписать процедуру с учётом 1 - отдельной таблицы для настройки импорта (адресс / пароль и т.д.) 2- разбор полученного ответа с соответсвующими изменениями"
    */
    pkg_http_gate.set_http_address('https://npf.renlife.com/gateway/AgentUpdate');
  
    FOR imp IN (SELECT agt.agn_gate_table_id FROM agn_gate_table agt WHERE agt.state = 0)
    LOOP
    
      v_send_str := get_json_string(imp.agn_gate_table_id);
    
      UPDATE agn_gate_table a
         SET operation_stmnt  = v_send_str
            ,a.operation_date = SYSDATE
       WHERE a.agn_gate_table_id = imp.agn_gate_table_id;
    
      v_get_str := pkg_http_gate.send_http_post('agent_key=195842589a578853e49d95c1a715df4e&agent_json=' ||
                                                v_send_str);
    
      --переписать на regexp_substr
      SELECT substr(v_get_str, instr(v_get_str, 'cod') + 5, 1)
            ,
             
             substr(v_get_str
                   ,instr(v_get_str, 'operation') + 12
                   ,((instr(v_get_str, 'errorText') - 3) - (instr(v_get_str, 'operation') + 12)))
            ,
             
             substr(v_get_str
                   ,instr(v_get_str, 'errorText') + 12
                   ,((length(v_get_str)) - (instr(v_get_str, 'errorText') + 12)))
        INTO v_res_o
            ,v_oper_t
            ,v_err_text
        FROM dual;
    
      /*
      {"cod":0,"operation":"none","errorText":"NO LOGIN"}
      
      {"cod":1,"operation":"insert","errorText":""}
      */
    
      UPDATE agn_gate_table a
         SET a.operation  = v_oper_t
            ,a.error_text = decode(v_res_o, 0, ' Error text : ' || v_err_text, NULL)
            ,a.state      = decode(v_res_o, 0, 99, 1, 1, 99)
       WHERE a.agn_gate_table_id = imp.agn_gate_table_id;
    
    END LOOP;
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20010
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM);
  END process_http_import;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 01.03.2011 19:39:03
  -- Purpose : Получает json строку для записи в agn_gate_table
  FUNCTION get_json_string(ag_gate_table_id PLS_INTEGER) RETURN VARCHAR2 IS
    proc_name    VARCHAR2(20) := 'Get_json_string';
    v_stmnt      VARCHAR2(2000) := 'SELECT ' || chr(10);
    v_res_string VARCHAR2(2000);
  BEGIN
  
    FOR r IN (SELECT dtc.column_name
                    ,dtc.data_type
                    ,row_number() over(ORDER BY dtc.column_name) rn
                    ,COUNT(*) over(PARTITION BY 1) cnt
                FROM user_tab_cols     dtc
                    ,user_col_comments ctc
               WHERE dtc.table_name = 'AGN_GATE_TABLE'
                 AND dtc.table_name = ctc.table_name
                 AND dtc.column_name = ctc.column_name
                 AND dtc.table_name = ctc.table_name
                 AND ctc.comments NOT LIKE '%(NOT IMPORTED)'
               ORDER BY 1)
    LOOP
    
      CASE r.data_type
        WHEN 'NUMBER' THEN
          v_stmnt := v_stmnt || '''"' || r.column_name || '" : ''|| ' || r.column_name;
          IF r.rn != r.cnt
          THEN
            v_stmnt := v_stmnt || '||'',''||' || chr(10);
          END IF;
        WHEN 'VARCHAR2' THEN
          v_stmnt := v_stmnt || '''"' || r.column_name || '" : "''|| ' || 'replace(' || r.column_name ||
                     ',''"'',''\"'') ||''"''';
          IF r.rn != r.cnt
          THEN
            v_stmnt := v_stmnt || '||'', ''||' || chr(10);
          END IF;
        WHEN 'DATE' THEN
          v_stmnt := v_stmnt || '''"' || r.column_name || '" : "''||to_char(' || r.column_name ||
                     ',''DD.MM.YYYY'')||''"''';
          IF r.rn != r.cnt
          THEN
            v_stmnt := v_stmnt || '||'', ''||' || chr(10);
          END IF;
        ELSE
          NULL;
      END CASE;
    END LOOP;
  
    v_stmnt := v_stmnt || chr(10) ||
               ' INTO :v_res_str FROM AGN_GATE_TABLE WHERE AGN_GATE_TABLE_ID = :v_agn_id';
  
    EXECUTE IMMEDIATE v_stmnt
      INTO v_res_string
      USING ag_gate_table_id;
  
    v_res_string := '{' || v_res_string || '}';
  
    RETURN(v_res_string);
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM);
  END get_json_string;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 14.05.2010 15:35:54
  -- Purpose : Процедура производит импорт договоров из таблицы стека
  -- DEPRICATED
  PROCEDURE process_import IS
    proc_name VARCHAR2(25) := 'Process_import';
    v_err_msg VARCHAR(2000);
    v_stmnt   VARCHAR2(2000);
  BEGIN
    RETURN;
  
    FOR r IN (SELECT * FROM agn_gate_table agt WHERE agt.state IN (0, 3, 99))
    LOOP
    
      BEGIN
        /*    pkg_gate_jdbc.agent_into_b2b(agent_id => r.agent_id,
        company_id => r.company_id,
        tac_id => r.tac_id,
        first_name => r.first_name,
        last_name => r.last_name,
        middle_name => r.middle_name,
        city => r.city,
        contract_date => r.contract_date,
        birth_date => r.birth_date,
        operation => r.operation);*/
      
        --v_stmnt:=pkg_gate_jdbc.get_last_stmnt;
      
        UPDATE agn_gate_table a
           SET a.state           = 1
              ,a.error_text      = NULL
              ,a.operation_date  = SYSDATE
              ,a.operation_stmnt = v_stmnt
         WHERE a.agn_gate_table_id = r.agn_gate_table_id;
      
      EXCEPTION
        WHEN OTHERS THEN
          v_err_msg := SQLERRM;
          CASE SQLCODE
            WHEN -20002 THEN
              UPDATE agn_gate_table a
                 SET a.state           = 2
                    ,a.error_text      = v_err_msg
                    ,a.operation_date  = SYSDATE
                    ,a.operation_stmnt = v_stmnt
               WHERE a.agn_gate_table_id = r.agn_gate_table_id;
            WHEN -20003 THEN
              UPDATE agn_gate_table a
                 SET a.state           = 3
                    ,a.error_text      = v_err_msg
                    ,a.operation_date  = SYSDATE
                    ,a.operation_stmnt = v_stmnt
               WHERE a.agn_gate_table_id = r.agn_gate_table_id;
            ELSE
              UPDATE agn_gate_table a
                 SET a.state           = 99
                    ,a.error_text      = v_err_msg
                    ,a.operation_date  = SYSDATE
                    ,a.operation_stmnt = v_stmnt
               WHERE a.agn_gate_table_id = r.agn_gate_table_id;
              --        RAISE_APPLICATION_ERROR(-20001,SQLERRM);
          END CASE;
      END;
    END LOOP;
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM);
  END process_import;

  -- Author  : VESELEK
  -- Created : 17.11.2011 13:17:29
  -- Purpose : Проверка наличия ИНН у агента при подтверждении
  PROCEDURE check_agent_inn(p_ag_documents_id PLS_INTEGER) IS
    proc_name    VARCHAR2(25) := 'Check_agent_inn';
    v_check_role PLS_INTEGER;
  BEGIN
  
    SELECT COUNT(*)
      INTO v_check_role
      FROM ins.ag_documents           agd
          ,ins.ven_ag_contract_header agh
          ,ins.contact                c
     WHERE agd.ag_contract_header_id = agh.ag_contract_header_id
       AND agh.agent_id = c.contact_id
       AND EXISTS (SELECT NULL
              FROM ins.cn_contact_role rl
                  ,ins.t_contact_role  r
             WHERE rl.contact_id = c.contact_id
               AND rl.role_id = r.id
               AND r.brief = 'AGENT')
       AND agd.ag_documents_id = p_ag_documents_id;
  
    IF v_check_role > 0
    THEN
      RETURN;
    END IF;
  
    g_message.state := 'Err'; --'Warn' --'Err'
    IF v_check_role = 0
    THEN
      g_message.message := 'Внимание! Для данной операции обязательно наличие у объекта роли "Агент".' ||
                           ' Переход в статус Подтвержден невозможен.';
    END IF;
  
  EXCEPTION
    WHEN no_data_found THEN
      NULL;
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM);
  END check_agent_inn;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 16.04.2010 13:17:29
  -- Modified : 17.05.2010 12:03 Ilya.Slezin
  -- Purpose : Проверка выбора руководителя
  PROCEDURE check_leader(p_ag_documents_id PLS_INTEGER) IS
    proc_name           VARCHAR2(25) := 'Check_leader';
    v_lead              PLS_INTEGER;
    v_category          PLS_INTEGER;
    v_category_l        PLS_INTEGER;
    v_category_l_change DATE;
    v_agency            VARCHAR2(255);
    v_agency2           VARCHAR2(255);
    v_is_role           NUMBER;
    v_is_bank           NUMBER;
  BEGIN
    BEGIN
      SELECT safety.check_right_custom('CONFIRMED_AD_FOR_BANK') INTO v_is_role FROM dual;
    EXCEPTION
      WHEN no_data_found THEN
        v_is_role := 0;
    END;
    SELECT COUNT(1)
      INTO v_is_bank
      FROM ins.ag_documents       agd
          ,ins.ag_contract_header agh
          ,ins.t_sales_channel    ch
     WHERE agd.ag_documents_id = p_ag_documents_id
       AND agd.ag_contract_header_id = agh.ag_contract_header_id
       AND agh.t_sales_channel_id = ch.id
       AND ch.brief IN ('BANK', 'BR', 'BR_WDISC', 'NPF', 'MBG');
  
    SELECT decode(apc.new_value, 'NULL', NULL, apc.new_value)
          ,ac.category_id
      INTO v_lead
          ,v_category
      FROM ag_documents    agd
          ,ag_props_change apc
          ,ag_props_type   apt
          ,ag_contract     ac
     WHERE apc.ag_documents_id = p_ag_documents_id
       AND apc.ag_props_type_id = apt.ag_props_type_id
       AND apt.brief = 'LEAD_PROP'
       AND agd.ag_documents_id = apc.ag_documents_id
       AND ac.contract_id = agd.ag_contract_header_id
       AND agd.doc_date BETWEEN ac.date_begin AND ac.date_end;
    -- Байтин А.
    -- Запретил указание пустого руководителя
    --Для Банковского и брокерского, если есть право - можно
    IF v_is_role = 1
       AND v_is_bank != 0
    THEN
      NULL;
    ELSE
      IF v_lead IS NULL
      THEN
        g_message.state   := 'Err';
        g_message.message := 'Руководитель должен быть указан!';
        RETURN;
      END IF;
    END IF;
  
    SELECT ent.obj_name('DEPARTMENT', ac.agency_id)
          ,ent.obj_name('DEPARTMENT', ac2.agency_id)
          ,ac2.category_id
          ,ac2.date_begin
      INTO v_agency
          ,v_agency2
          ,v_category_l
          ,v_category_l_change
      FROM ag_contract ac
          ,ag_contract ac2
     WHERE ac.ag_contract_id = v_lead
       AND ac2.contract_id = ac.contract_id
       AND ac2.date_end = to_date('31.12.2999', 'dd.mm.yyyy')
       AND (ac.agency_id <> ac2.agency_id OR ac2.category_id <= v_category)
       AND NOT EXISTS (SELECT NULL
              FROM ag_documents    agd
                  ,ag_documents    agd2
                  ,ag_props_change apc
                  ,ag_props_type   apt
             WHERE agd.ag_documents_id = p_ag_documents_id
               AND agd.ag_contract_header_id = agd2.ag_contract_header_id
               AND agd2.doc_date >= agd.doc_date
               AND apc.ag_documents_id = agd2.ag_documents_id
               AND apc.ag_props_type_id = apt.ag_props_type_id
               AND apt.brief = 'LEAD_PROP'
               AND apc.new_value <> to_char(v_lead));
  
    g_message.state := 'Warn'; --'Warn' --'Err'
    IF v_agency <> v_agency2
    THEN
      g_message.message := 'Выбранный руководитель на текущую дату работает в агентстве ' || v_agency2 ||
                           ' прежде чем продолжить вы должны создать документ с руководителем' ||
                           ' который на ' || v_category_l_change || ' работает в агентстве ' ||
                           v_agency;
    ELSIF v_category_l <= v_category
    THEN
      g_message.message := v_category_l_change ||
                           ' категория руководителя будет меньше или равна текущей категории агента';
    END IF;
  
  EXCEPTION
    WHEN no_data_found THEN
      NULL;
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM);
  END check_leader;

  -- Author  : ILYA.SLEZIN
  -- Created : 21.04.2010
  -- Purpose : Проверка наличия подчиненных при смене агентства
  PROCEDURE check_subordinate_agency(p_ag_documents_id PLS_INTEGER) IS
    proc_name     VARCHAR2(30) := 'Check_subordinate_agency';
    v_subordinate PLS_INTEGER := 0;
    p_cat_id      NUMBER;
  BEGIN
  
    BEGIN
      SELECT decode(cat.brief, 'TD', 1, 0)
        INTO p_cat_id
        FROM ag_documents      agd
            ,ag_contract       ag
            ,ag_category_agent cat
       WHERE agd.ag_documents_id = p_ag_documents_id
         AND agd.ag_contract_header_id = ag.contract_id
         AND SYSDATE BETWEEN ag.date_begin AND ag.date_end
         AND ag.category_id = cat.ag_category_agent_id;
    EXCEPTION
      WHEN no_data_found THEN
        p_cat_id := 0;
    END;
  
    IF p_cat_id = 1
    THEN
      v_subordinate := 0;
    ELSE
    
      SELECT COUNT(*)
        INTO v_subordinate
        FROM ag_documents    agd
            ,ag_agent_tree   aat
            ,ag_props_change apc
            ,ag_props_type   apt
       WHERE agd.ag_documents_id = p_ag_documents_id
         AND apc.ag_documents_id = agd.ag_documents_id
         AND doc.get_doc_status_brief(aat.ag_contract_header_id) NOT IN ('BREAK', 'CANCEL')
         AND apc.ag_props_type_id = apt.ag_props_type_id
         AND apt.brief = 'AGENCY_PROP'
         AND aat.ag_parent_header_id = agd.ag_contract_header_id
         AND aat.date_end = to_date('31.12.2999', 'dd.mm.yyyy');
    
    END IF;
  
    IF v_subordinate = 0
    THEN
      RETURN;
    END IF;
  
    g_message.state   := 'Err'; --'Warn'; --'Ok'
    g_message.message := 'У данного агента есть подчинённые';
  
  EXCEPTION
    WHEN no_data_found THEN
      NULL;
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM);
  END check_subordinate_agency;

  -- Author  : ILYA.SLEZIN
  -- Created : 22.04.2010
  -- Purpose : Проверка наличия подчиненных при смене категории
  PROCEDURE check_subordinate_cat(p_ag_documents_id PLS_INTEGER) IS
    proc_name     VARCHAR2(30) := 'Check_subordinate_cat';
    v_subordinate PLS_INTEGER := 0;
  BEGIN
    SELECT COUNT(*)
      INTO v_subordinate
      FROM ag_documents       agd
          ,ag_agent_tree      aat
          ,ag_props_change    apc
          ,ag_props_type      apt
          ,ag_contract        ac
          ,ag_contract_header ach
     WHERE agd.ag_documents_id = p_ag_documents_id
       AND apc.ag_documents_id = agd.ag_documents_id
       AND apc.ag_props_type_id = apt.ag_props_type_id
       AND apt.brief = 'CAT_PROP'
       AND decode(apc.new_value, 'NULL', 0, apc.new_value) <= ac.category_id
       AND aat.ag_parent_header_id = agd.ag_contract_header_id
       AND agd.doc_date BETWEEN aat.date_begin AND aat.date_end
       AND ac.contract_id = aat.ag_contract_header_id
       AND ac.contract_id = ach.ag_contract_header_id
       AND doc.get_doc_status_brief(ach.ag_contract_header_id, agd.doc_date + 3 / 24 / 3600) NOT IN
           ('BREAK', 'CANCEL')
       AND agd.doc_date BETWEEN ac.date_begin AND ac.date_end;
  
    IF v_subordinate = 0
    THEN
      RETURN;
    END IF;
  
    g_message.state   := 'Err'; --'Warn'; --'Ok'
    g_message.message := 'У данного агента есть подчинённые с равной или большей категорией';
  
  EXCEPTION
    WHEN no_data_found THEN
      NULL;
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM);
  END check_subordinate_cat;

  /*
  PROCEDURE Check_subordinate_cat (P_ag_documents_id pls_integer)
  IS
  proc_name VARCHAR2(30):='Check_subordinate_cat';
  v_subordinate   PLS_INTEGER := 0;
  BEGIN
    SELECT COUNT(ac.ag_contract_id)
      INTO v_subordinate
      FROM ag_documents  agd,
           ag_agent_tree aat,
           ag_props_change apc,
           ag_props_type   apt,
           ag_contract     ac
     WHERE agd.ag_documents_id = P_ag_documents_id
       AND apc.ag_documents_id = agd.ag_documents_id
       AND apc.ag_props_type_id = apt.ag_props_type_id
       AND apt.brief = 'CAT_PROP'
       AND aat.date_end = TO_DATE('31.12.2999','dd.mm.yyyy')
       and decode(apc.new_value,'NULL',0,apc.new_value) <= ac.category_id
       and aat.ag_parent_header_id = agd.ag_contract_header_id
       and ac.contract_id = aat.ag_contract_header_id
       AND ac.date_end = TO_DATE('31.12.2999','dd.mm.yyyy');
  
    IF v_subordinate = 0 THEN RETURN; END IF;
  
    g_message.state := 'Err';--'Warn'; --'Ok'
    g_message.message := 'У данного агента есть подчинённые с равной или большей категорией';
  
  EXCEPTION
    WHEN NO_DATA_FOUND THEN NULL;
    WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20001, 'Ошибка при выполнении '||proc_name||SQLERRM);
  END Check_subordinate_cat;*/

  -- Author  : ILYA.SLEZIN
  -- Created : 22.04.2010
  -- Purpose : Проверка типа документа возможности перевода в Напечатэн
  PROCEDURE ag_doc_type_change_status(p_ag_documents_id PLS_INTEGER) IS
    proc_name VARCHAR2(30) := 'ag_doc_type_change_status';
    v_count   PLS_INTEGER := 0;
  BEGIN
    SELECT COUNT(*)
      INTO v_count
      FROM ag_documents agd
          ,ag_doc_type  adt
     WHERE agd.ag_documents_id = p_ag_documents_id
       AND adt.ag_doc_type_id = agd.ag_doc_type_id
       AND adt.brief IN ('NEW_AD', 'CAT_CHG', 'AGENCY_CHG', 'LEAD_CHG', 'LENT_CHG', 'BREAK_AD');
  
    IF v_count > 0
    THEN
      raise_application_error(-20002
                             ,'Документ должен быть подтвержден в ЦО');
    END IF;
  
  EXCEPTION
    WHEN no_data_found THEN
      NULL;
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM);
  END ag_doc_type_change_status;
  /*
    Байтин А.
    Проверка на наличие КП у агента.
    Перенесено из формы и немного изменен запрос
  */

  PROCEDURE check_agent_policy(par_ag_doc_id NUMBER) IS
    v_cnt_pol            NUMBER(1);
    v_doc_type           ag_doc_type.brief%TYPE;
    v_contract_header_id NUMBER;
    v_doc_date           DATE;
  BEGIN
    SELECT dt.brief
          ,ad.ag_contract_header_id
          ,ad.doc_date
      INTO v_doc_type
          ,v_contract_header_id
          ,v_doc_date
      FROM ag_documents ad
          ,ag_doc_type  dt
     WHERE ad.ag_documents_id = par_ag_doc_id
       AND ad.ag_doc_type_id = dt.ag_doc_type_id;
  
    IF v_doc_type = 'BREAK_AD'
    THEN
      SELECT COUNT(1)
        INTO v_cnt_pol
        FROM dual
       WHERE EXISTS (SELECT NULL
                FROM p_policy_agent_doc pad
                    ,document           dc
                    ,doc_status_ref     dsr
                    ,ins.p_pol_header   ph
                    ,document           dc2
                    ,doc_status_ref     dsr2
                    ,ins.p_policy       pol
               WHERE pad.ag_contract_header_id = v_contract_header_id
                 AND pad.p_policy_agent_doc_id = dc.document_id
                 AND dc.doc_status_ref_id = dsr.doc_status_ref_id
                 AND dsr.brief = 'CURRENT'
                 AND ph.policy_header_id = pad.policy_header_id
                 AND ph.last_ver_id = dc2.document_id
                 AND dc2.doc_status_ref_id = dsr2.doc_status_ref_id
                    --Заявка 202961. Изместьев 04.12.2012
                    --После внедрения функционала "Отмена версий ДС" изменить
                    --условие проверки статуса версии ДС:  проверять статус
                    --активной версии
                 AND (dsr2.brief NOT IN ('RECOVER'
                                        , --Восстановление
                                         'READY_TO_CANCEL'
                                        , --Готовится к расторжению
                                         'STOPED'
                                        , --Завершен
                                         'TO_QUIT'
                                        , --К прекращению
                                         'TO_QUIT_CHECK_READY'
                                        , --К прекращению. Готов для проверки
                                         'TO_QUIT_CHECKED'
                                        , --К прекращению. Проверен
                                         'RECOVER_DENY'
                                        , --Отказ в Восстановлении
                                         'CANCEL'
                                        , --Отменен
                                         'QUIT'
                                        , --Прекращен
                                         'QUIT_REQ_QUERY'
                                        , --Прекращен. Запрос реквизитов
                                         'QUIT_REQ_GET'
                                        , --Прекращен. Реквизиты получены
                                         'QUIT_TO_PAY'
                                        , --Прекращен.К выплате
                                         'STOP'
                                        , --Приостановлен
                                         'BREAK' --Расторгнут
                                         ))
                 AND NOT EXISTS (SELECT NULL
                        FROM ins.p_policy pol
                       WHERE pol.policy_id = ph.policy_id
                         AND pol.end_date <= v_doc_date));
    
      IF v_cnt_pol = 1
      THEN
        -- Проверка наличия права
        IF safety.check_right_custom('CSR_AG_CONTRACT_DONT_CHECK_KP') = 0
        THEN
          g_message.state := 'Err'; --'Warn'; --'Ok'
        ELSE
          g_message.state := 'Warn'; --'Ok'
        END IF;
        g_message.message := 'Существуют Договоры Страхования, у которых агент является действующим! Необходимо передать портфель. Расторжение АД невозможно.';
      END IF;
    END IF;
  END check_agent_policy;
  -- Author  : ILYA.SLEZIN
  -- Created : 22.04.2010
  -- Purpose : Проверка других АД у этого ж контакта
  PROCEDURE ag_doc_chek_double_ad(p_ag_documents_id PLS_INTEGER) IS
    proc_name   VARCHAR2(30) := 'ag_doc_chek_double_AD';
    v_count     PLS_INTEGER := 0;
    v_rla_sales NUMBER;
  BEGIN
    SELECT COUNT(*)
      INTO v_count
      FROM ag_documents       agd
          ,ag_contract_header ach
          ,ag_contract_header ach2
     WHERE agd.ag_documents_id = p_ag_documents_id
       AND ach.ag_contract_header_id = agd.ag_contract_header_id
       AND ach2.agent_id = ach.agent_id
       AND ach2.is_new = 1
       AND ach2.ag_contract_header_id <> ach.ag_contract_header_id
       AND doc.get_doc_status_brief(ach2.ag_contract_header_id, to_date('31.12.2999', 'dd.mm.yyyy')) =
           'CURRENT';
  
    IF v_count = 0
    THEN
      RETURN;
    ELSE
      SELECT COUNT(*)
        INTO v_rla_sales
        FROM ins.ag_documents       agd
            ,ins.ag_contract_header agh
            ,ins.t_sales_channel    ch
       WHERE agd.ag_contract_header_id = agh.ag_contract_header_id
         AND agh.t_sales_channel_id = ch.id
         AND ch.brief = 'RLA';
      IF v_rla_sales != 0
      THEN
        g_message.state   := 'Warn'; --'Warn'; --'Ok'
        g_message.message := 'Есть другой действующий АД у данного контакта, не забудьте.';
        RETURN;
      END IF;
    END IF;
  
    g_message.state   := 'Err'; --'Warn'; --'Ok'
    g_message.message := 'Есть другой действующий АД у данного контакта';
  
  EXCEPTION
    WHEN no_data_found THEN
      NULL;
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM);
  END ag_doc_chek_double_ad;

  -- Author  : ILYA.SLEZIN
  -- Created : 11.05.2010
  -- Purpose : Проверка актуальности АД руководителя
  PROCEDURE check_ad_lead(p_ag_documents_id PLS_INTEGER) IS
    proc_name        VARCHAR2(30) := 'Check_AD_lead';
    v_new_ad         PLS_INTEGER := 0;
    v_leader_is_null PLS_INTEGER := 0;
  
    v_agency_a      PLS_INTEGER;
    v_agency_l      PLS_INTEGER;
    v_category_a    PLS_INTEGER;
    v_category_l    PLS_INTEGER;
    v_lead_date_end DATE;
    v_doc_date      DATE;
    v_doc_type      VARCHAR2(20);
  
  BEGIN
    SELECT COUNT(*)
      INTO v_new_ad
      FROM ag_documents agd
          ,ag_doc_type  adt
     WHERE agd.ag_documents_id = p_ag_documents_id
       AND adt.ag_doc_type_id = agd.ag_doc_type_id
       AND adt.brief = 'NEW_AD';
  
    SELECT COUNT(*)
      INTO v_leader_is_null
      FROM ag_documents       agd
          ,ag_contract        ac
          ,ag_contract_header ach
     WHERE agd.ag_documents_id = p_ag_documents_id
       AND ach.ag_contract_header_id = agd.ag_contract_header_id
       AND ac.ag_contract_id = ach.last_ver_id
       AND ac.contract_leader_id IS NULL;
  
    IF v_new_ad = 0
       AND v_leader_is_null = 0
    THEN
      SELECT ac.agency_id
            ,ac2.agency_id
            ,ac2.date_end
            ,agd.doc_date
            ,adt.brief
            ,ac.category_id
            ,ac2.category_id
        INTO v_agency_a
            ,v_agency_l
            ,v_lead_date_end
            ,v_doc_date
            ,v_doc_type
            ,v_category_a
            ,v_category_l
        FROM ag_documents    agd
            ,ag_props_change apc
            ,ag_doc_type     adt
            ,ag_contract     ac
            ,ag_contract     ac2
       WHERE agd.ag_documents_id = p_ag_documents_id
         AND apc.ag_documents_id = agd.ag_documents_id
         AND adt.ag_doc_type_id = agd.ag_doc_type_id
         AND ac.contract_id = agd.ag_contract_header_id
         AND agd.doc_date BETWEEN ac.date_begin AND ac.date_end
         AND ac2.ag_contract_id = ac.contract_leader_id;
    
      IF (v_agency_a <> v_agency_l AND CASE WHEN v_category_l = 20 THEN 4 ELSE v_category_l END <= 4 --20 для ПРОДА
         )
      THEN
        g_message.state   := 'Err'; --'Warn'; --'Ok'
        g_message.message := 'Агенства у руководителя и подчиненного разные';
      END IF;
    
      IF v_lead_date_end + 1 / 24 / 3600 < v_doc_date
         OR (v_lead_date_end + 1 / 24 / 3600 = v_doc_date AND
         v_doc_type NOT IN ('AGENCY_CHG', 'LEAD_CHG'))
      THEN
        g_message.state   := 'Err'; --'Warn'; --'Ok'
        g_message.message := 'Дата документа не может быть больше даты окончания действия категории руководителя ' ||
                             v_lead_date_end + 1 / 24 / 3600;
      END IF;
    
      IF v_category_a >= v_category_l
      THEN
        g_message.state   := 'Err'; --'Warn'; --'Ok'
        g_message.message := 'Категория руководителя меньше или равна категории подчиненного';
      END IF;
    END IF;
  
  EXCEPTION
    WHEN no_data_found THEN
      NULL;
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM);
  END check_ad_lead;

  -- Author  : ILYA.SLEZIN
  -- Created : 25.05.2010
  -- Purpose : Проверка реквизитов ИП
  PROCEDURE check_ad_pboul(p_ag_documents_id PLS_INTEGER) IS
    proc_name       VARCHAR2(30) := 'Check_AD_PBOUL';
    v_l_entity_prop VARCHAR2(50);
    v_contact       PLS_INTEGER;
    vv_contact      PLS_INTEGER;
  BEGIN
  
    SELECT decode(apc.new_value, 'NULL', NULL, apc.new_value)
          ,ach.agent_id
      INTO v_l_entity_prop
          ,v_contact
      FROM ag_documents       agd
          ,ag_props_change    apc
          ,ag_props_type      apt
          ,ag_contract_header ach
     WHERE apc.ag_documents_id = p_ag_documents_id
       AND apc.ag_props_type_id = apt.ag_props_type_id
       AND apt.brief = 'L_ENTITY_PROP'
       AND agd.ag_documents_id = apc.ag_documents_id
       AND ach.ag_contract_header_id = agd.ag_contract_header_id;
  
    IF v_l_entity_prop = 1030
    THEN
    
      BEGIN
        SELECT ci.contact_id
          INTO vv_contact
          FROM cn_contact_ident ci
              ,t_id_type        ti
         WHERE ci.id_type = ti.id
           AND ti.brief = 'REG_SVID'
           AND ci.contact_id = v_contact;
      EXCEPTION
        WHEN no_data_found THEN
          g_message.state   := 'Err';
          g_message.message := 'У выбраного контакта нет свидетельства о регистрациии ПБОЮЛ';
      END;
    
      BEGIN
        SELECT ci.contact_id
          INTO vv_contact
          FROM cn_contact_ident ci
              ,t_id_type        ti
         WHERE ci.id_type = ti.id
           AND ti.brief = 'INN'
           AND ci.contact_id = v_contact;
      EXCEPTION
        WHEN no_data_found THEN
          g_message.state   := 'Err';
          g_message.message := 'У выбраного контакта нет ИНН';
      END;
    END IF;
  
  EXCEPTION
    WHEN no_data_found THEN
      NULL;
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM);
  END check_ad_pboul;

  -- Author  : ILYA.SLEZIN
  -- Created : 28.05.2010
  -- Purpose : Проверка вида документа. На переходе Напечатан - Проект
  PROCEDURE check_ad_doc_class(p_ag_documents_id PLS_INTEGER) IS
    proc_name   VARCHAR2(30) := 'Check_AD_doc_class';
    v_doc_class ag_doc_type.doc_class%TYPE;
    wrong_doc EXCEPTION;
    PRAGMA EXCEPTION_INIT(wrong_doc, -20099);
    v_doc_brief    ag_doc_type.brief%TYPE;
    v_ag_header_id NUMBER;
    v_docs_count   NUMBER(1);
  BEGIN
    -- Байтин А.
    -- Подправил запрос
    SELECT adt.doc_class
          ,adt.brief
          ,agd.ag_contract_header_id
      INTO v_doc_class
          ,v_doc_brief
          ,v_ag_header_id
      FROM ag_documents agd
          ,ag_doc_type  adt
     WHERE agd.ag_documents_id = p_ag_documents_id
       AND adt.ag_doc_type_id = agd.ag_doc_type_id;
  
    IF v_doc_class = 1
    THEN
      --PS делаем проверку на право откатить документ в статус Проект
      IF safety.check_right_custom('CSR_CHECK_TO_PROJECT') = 1
      THEN
        --RAISE wrong_doc;
        NULL;
        --end if;
        -- Проверка шаблона документа и наличия права "АД. Возможность перевода Заключения АД в Проект"
      ELSIF v_doc_brief = 'NEW_AD'
            AND safety.check_right_custom('CSR_NEW_AD_TO_PROJECT') = 1
      THEN
        -- Проверка наличия других основных документов в статусах "В архиве ЦО"/"Проверено в ЦО"
        SELECT COUNT(1)
          INTO v_docs_count
          FROM dual
         WHERE EXISTS (SELECT NULL
                  FROM ag_documents   ad
                      ,document       dc
                      ,doc_status_ref dsr
                      ,ag_doc_type    adt
                 WHERE ad.ag_contract_header_id = v_ag_header_id
                   AND ad.ag_documents_id = dc.document_id
                   AND dc.doc_status_ref_id = dsr.doc_status_ref_id
                   AND ad.ag_doc_type_id = adt.ag_doc_type_id
                   AND adt.doc_class = 1
                   AND dsr.brief IN ('CO_ACHIVE', 'CO_ACCEPTED'));
        IF v_docs_count = 1
        THEN
          RAISE wrong_doc;
        END IF;
      ELSE
        RAISE wrong_doc;
      END IF;
      --      g_Message.state := 'Err';
      --      g_Message.message := 'Для данного вида документа переход запрещён';
    END IF;
  
  EXCEPTION
    WHEN wrong_doc THEN
      raise_application_error(-20006
                             ,'Для данного вида документа переход запрещён');
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM);
  END check_ad_doc_class;

  FUNCTION get_doc_date
  (
    p_ag_contract_header_id PLS_INTEGER
   ,p_brief_document        VARCHAR2
  ) RETURN VARCHAR2 IS
    proc_name  VARCHAR2(20) := 'get_doc_date';
    v_res_date VARCHAR2(10);
  BEGIN
  
    SELECT to_char(MAX(agd.doc_date), 'dd.mm.yyyy')
      INTO v_res_date
      FROM ins.ag_documents agd
          ,ins.ag_doc_type  dt
     WHERE agd.ag_contract_header_id = p_ag_contract_header_id
       AND agd.ag_doc_type_id = dt.ag_doc_type_id
       AND dt.brief = p_brief_document
       AND doc.get_doc_status_brief(agd.ag_documents_id) NOT IN ('CANCEL', 'PROJECT');
  
    RETURN v_res_date;
  
  END;

  FUNCTION sum_prem_for_act
  (
    p_work_act_id PLS_INTEGER
   ,p_brief       VARCHAR2
  ) RETURN NUMBER IS
    proc_name VARCHAR2(20) := 'sum_prem_for_act';
    v_res_sum NUMBER;
  BEGIN
  
    SELECT apd1.summ
      INTO v_res_sum
      FROM ag_perfom_work_det apd1
          ,ag_rate_type       art1
     WHERE apd1.ag_perfomed_work_act_id = p_work_act_id
       AND apd1.ag_rate_type_id = art1.ag_rate_type_id
       AND art1.brief = p_brief;
  
    RETURN v_res_sum;
  
  END;

  FUNCTION get_detail_amt
  (
    p_leader_num   VARCHAR2
   ,p_agent_num    VARCHAR2
   ,p_brief_detail VARCHAR2
  ) RETURN NUMBER IS
    proc_name VARCHAR2(20) := 'get_detail_amt';
    v_res_sum NUMBER;
  BEGIN
    SELECT SUM(pr.detail_amt)
      INTO v_res_sum
      FROM t_data_for_prem pr
     WHERE 1 = 1
       AND pr.leader_manager = p_leader_num
       AND pr.prem_detail_brief = p_brief_detail
       AND pr.num = p_agent_num;
  
    RETURN v_res_sum;
  
  END;

  FUNCTION get_plan_value
  (
    p_ag_contract_header_id PLS_INTEGER
   ,p_type_plan             PLS_INTEGER
   ,p_date_period           DATE
  ) RETURN NUMBER IS
    proc_name  VARCHAR2(20) := 'get_plan_value';
    v_res_plan NUMBER;
  BEGIN
  
    SELECT pl.plan_value
      INTO v_res_plan
      FROM ins.ven_ag_sale_plan pl
     WHERE pl.ag_contract_header_id = p_ag_contract_header_id
       AND p_date_period BETWEEN pl.date_begin AND pl.date_end
       AND pl.plan_type = p_type_plan;
  
    RETURN v_res_plan;
  
  END;

  FUNCTION get_active_agent
  (
    p_ag_num      NUMBER
   ,p_date_period DATE
  ) RETURN NUMBER IS
    proc_name      VARCHAR2(20) := 'get_active_agent';
    v_active_agent NUMBER;
  BEGIN
  
    SELECT COUNT(*)
      INTO v_active_agent
      FROM (SELECT DISTINCT agent_ad
              FROM (SELECT DISTINCT pr.vol_type
                                   ,pr.agent_ad
                                   ,pr.pol_num
                                   ,pr.num
                                   ,pr.ag_fio
                      FROM t_data_for_prem pr --TEMP_DATA_FOR_PREM pr
                     WHERE pr.ag_contract_header_id = p_ag_num
                       AND (pr.pay_period = 1 AND substr(pr.epg, instr(pr.epg, '/') + 1) = '1' OR
                           pr.vol_type = 'Объемы НПФ Ренессанс')
                       AND pr.agent_ad IN (SELECT agh.num
                                             FROM ven_ag_contract_header agh
                                                 ,ag_contract            ag
                                                 ,ag_category_agent      cat
                                            WHERE agh.ag_contract_header_id = ag.contract_id
                                              AND ag.category_id = cat.ag_category_agent_id
                                              AND pr.date_end BETWEEN ag.date_begin AND ag.date_end
                                              AND cat.category_name = 'Агент')
                       AND length(pr.agent_ad) < 6
                       AND pr.prem_detail_brief = 'WG_0510'));
  
    /*     SELECT sum(CASE
             WHEN (SELECT ac.category_id
                     FROM ag_contract ac
                    WHERE ac.contract_id = aat.ag_contract_header_id
                      AND p_date_period BETWEEN ac.date_begin AND ac.date_end) = 2 THEN
              (SELECT CASE
                        WHEN SUM(DECODE(av.ag_volume_type_id, 1, 1, 0)) >= 1
                             OR SUM(DECODE(av.ag_volume_type_id, 2, 1, 0)) >= 1 THEN
                         1
                        ELSE
                         0
                      END a_o_rl
                 FROM ag_volume      av,
                      ag_roll        ar,
                      ag_roll_header arh
                WHERE av.ag_roll_id = ar.ag_roll_id
                  AND ar.ag_roll_header_id = arh.ag_roll_header_id
                  AND av.ag_volume_type_id IN (1, 2)
                  AND av.is_nbv = 1
                  AND nvl(av.index_delta_sum, 0) = 0
                  AND arh.date_end = p_date_period
                  and av.pay_period = 1
                  AND av.ag_contract_header_id = aat.ag_contract_header_id)
             ELSE
              0
           END) active_agent
     INTO v_active_agent
      FROM ag_agent_tree aat
     WHERE EXISTS (SELECT NULL
                     FROM ins.ag_contract_header ach
                    WHERE ach.ag_contract_header_id = aat.ag_contract_header_id
                      AND ach.is_new = 1)
     START WITH aat.ag_contract_header_id = p_ag_contract_header_id
            AND p_date_period BETWEEN aat.date_begin AND aat.date_end
    CONNECT BY aat.ag_parent_header_id = PRIOR aat.ag_contract_header_id
           AND p_date_period BETWEEN aat.date_begin AND aat.date_end;*/
  
    RETURN v_active_agent;
  
  END;

  PROCEDURE set_dir_prem
  (
    p_num_vedom  VARCHAR2
   ,p_vedom_ver  PLS_INTEGER
   ,p_num_agent  VARCHAR2
   ,p_brief_prem VARCHAR2
   ,p_reestr     NUMBER DEFAULT 1
  ) IS
  BEGIN
  
    DELETE FROM t_dir_prem;
    INSERT INTO t_dir_prem
      SELECT CASE
               WHEN cat_name_ag = 'Менеджер' THEN
                agent_ad
               WHEN cat_name_ag = 'Агент' THEN
                substr(leader_agent, 1, instr(leader_agent, '$') - 1)
               ELSE
                ''
             END num_manag
            ,CASE
               WHEN cat_name_ag = 'Менеджер' THEN
                agent_fio
               WHEN cat_name_ag = 'Агент' THEN
                substr(leader_agent, instr(leader_agent, '$') + 1)
               ELSE
                ''
             END name_manag
            ,CASE
               WHEN cat_name_ag IN ('Агент'
                                   ,'Директор агентства 1 года'
                                   ,'Директор агентства 2 года') THEN
                agent_ad
               ELSE
                ''
             END num_agent
            ,CASE
               WHEN cat_name_ag IN ('Агент'
                                   ,'Директор агентства 1 года'
                                   ,'Директор агентства 2 года') THEN
                agent_fio
               ELSE
                ''
             END name_agent
            ,ag_contract_header_id
        FROM (SELECT DISTINCT cn_a.obj_name_orig
                             ,aca.category_name
                             ,ach_s.num agent_ad
                             ,cn_as.obj_name_orig agent_fio
                             ,ach_s.ag_contract_header_id
                             ,(SELECT cata.category_name
                                 FROM ins.ag_contract       ag
                                     ,ins.ag_category_agent cata
                                WHERE ag.contract_id = av.ag_contract_header_id
                                  AND av.payment_date BETWEEN ag.date_begin AND ag.date_end
                                  AND cata.ag_category_agent_id = ag.category_id
                                  AND rownum = 1) cat_name_ag
                             ,(SELECT aghl.num || '$' || cl.obj_name_orig
                                 FROM ins.ag_contract            ag
                                     ,ins.ag_contract            agl
                                     ,ins.ven_ag_contract_header aghl
                                     ,ins.contact                cl
                                WHERE ag.contract_id = av.ag_contract_header_id
                                  AND av.payment_date BETWEEN ag.date_begin AND ag.date_end
                                  AND ag.contract_leader_id = agl.ag_contract_id
                                  AND agl.contract_id = aghl.ag_contract_header_id
                                  AND cl.contact_id = aghl.agent_id
                                  AND aghl.num <> ach.num
                                  AND rownum = 1) leader_agent
                FROM ven_ag_roll_header     arh
                    ,ven_ag_roll            ar
                    ,ag_perfomed_work_act   apw
                    ,ag_perfom_work_det     apd
                    ,ag_rate_type           art
                    ,ag_perf_work_vol       apv
                    ,ag_volume              av
                    ,ag_volume_type         avt
                    ,ven_ag_contract_header ach
                    ,ven_ag_contract_header ach_s
                    ,ven_ag_contract_header leader_ach
                    ,ven_ag_contract        leader_ac
                    ,contact                cn_leader
                    ,contact                cn_as
                    ,contact                cn_a
                    ,department             dep
                    ,t_sales_channel        ts
                    ,ins.ag_contract        ac
                    ,ag_category_agent      aca
                    ,t_contact_type         tct
                    ,p_pol_header           ph
                    ,t_product              tp
                    ,t_prod_line_option     tplo
                    ,t_payment_terms        pt
                    ,p_policy               pp
                    ,contact                cn_i
               WHERE 1 = 1
                 AND arh.num = p_num_vedom
                 AND ((ar.num = p_vedom_ver AND p_reestr = 1) OR p_reestr = 0)
                 AND arh.ag_roll_header_id = ar.ag_roll_header_id
                 AND ar.ag_roll_id = apw.ag_roll_id
                 AND apw.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id
                 AND apd.ag_rate_type_id = art.ag_rate_type_id
                 AND art.brief IN ('KSP_0510'
                                  ,'RE_POL_0510'
                                  ,'WG_0510'
                                  ,'ES_0510'
                                  ,'LVL_0510'
                                  ,'FAKE_Sofi_prem_0510'
                                  ,'PENROL_0510'
                                  ,'PEXEC_0510'
                                  ,'PG_0510')
                 AND apd.ag_perfom_work_det_id = apv.ag_perfom_work_det_id
                 AND apv.ag_volume_id = av.ag_volume_id
                 AND av.policy_header_id = ph.policy_header_id
                 AND av.ag_volume_type_id = avt.ag_volume_type_id
                 AND av.ag_contract_header_id = ach_s.ag_contract_header_id
                 AND ach_s.agent_id = cn_as.contact_id
                 AND ac.contract_f_lead_id = leader_ac.ag_contract_id(+)
                 AND leader_ac.contract_id = leader_ach.ag_contract_header_id(+)
                 AND leader_ach.agent_id = cn_leader.contact_id(+)
                 AND ph.policy_id = pp.policy_id
                 AND ph.product_id = tp.product_id
                 AND tplo.id = av.t_prod_line_option_id
                 AND pkg_policy.get_policy_contact(ph.policy_id, 'Страхователь') = cn_i.contact_id
                 AND ach.ag_contract_header_id = apw.ag_contract_header_id
                 AND ach.ag_contract_header_id = ac.contract_id
                 AND arh.date_end BETWEEN ac.date_begin AND ac.date_end
                 AND ac.agency_id = dep.department_id
                 AND ach.t_sales_channel_id = ts.id
                 AND ac.category_id = aca.ag_category_agent_id
                 AND cn_a.contact_id = ach.agent_id
                 AND tct.id = ac.leg_pos
                 AND pt.id = av.payment_term_id
                 AND aca.category_name IN ('Директор агентства 1 года'
                                          ,'Директор агентства 2 года')
                 AND ach.num = p_num_agent
                 AND (CASE
                       WHEN art.brief = 'KSP_0510' THEN
                        'За размер КСП'
                       WHEN art.brief = 'RE_POL_0510' THEN
                        'За договоры страхования, начиная со 2-го по 5-ый (включительно) годы действия'
                       WHEN art.brief = 'WG_0510' THEN
                        'За договоры страхования (1-го года)'
                       WHEN art.brief = 'FAKE_Sofi_prem_0510' THEN
                        'За договоры страхования (1-го года)'
                       WHEN art.brief = 'LVL_0510' THEN
                        'За достижение Уровня'
                       WHEN art.brief = 'ES_0510' THEN
                        'За сопровождение деятельности Рекрутированных Директоров'
                       WHEN art.brief = 'PENROL_0510' THEN
                        'За сопровождение деятельности Рекрутированных Директоров'
                       WHEN art.brief = 'PG_0510' THEN
                        'За договоры страхования/договоры ОПС/Кредитные договоры, заключенные при содействии Рекрутированных субагентов Директора'
                       WHEN art.brief = 'PEXEC_0510' THEN
                        'За выполнение Индивидуального плана'
                       ELSE
                        art.brief
                     END) = p_brief_prem)
      UNION
      SELECT CASE
               WHEN cat_name_ag = 'Менеджер' THEN
                agent_ad
               WHEN cat_name_ag = 'Агент' THEN
                substr(leader_agent, 1, instr(leader_agent, '$') - 1)
               ELSE
                ''
             END num_manag
            ,CASE
               WHEN cat_name_ag = 'Менеджер' THEN
                agent_fio
               WHEN cat_name_ag = 'Агент' THEN
                substr(leader_agent, instr(leader_agent, '$') + 1)
               ELSE
                ''
             END name_manag
            ,CASE
               WHEN cat_name_ag IN ('Агент'
                                   ,'Директор агентства 1 года'
                                   ,'Директор агентства 2 года') THEN
                agent_ad
               ELSE
                ''
             END num_agent
            ,CASE
               WHEN cat_name_ag IN ('Агент'
                                   ,'Директор агентства 1 года'
                                   ,'Директор агентства 2 года') THEN
                agent_fio
               ELSE
                ''
             END name_agent
            ,ag_contract_header_id
        FROM (SELECT DISTINCT cn_a.obj_name_orig
                             ,aca.category_name
                             ,ach_s.num agent_ad
                             ,cn_as.obj_name_orig agent_fio
                             ,ach_s.ag_contract_header_id
                             ,(SELECT cata.category_name
                                 FROM ins.ag_contract       ag
                                     ,ins.ag_category_agent cata
                                WHERE ag.contract_id = av.ag_contract_header_id
                                  AND arh.date_end /*anv.sign_date*/
                                      BETWEEN ag.date_begin AND ag.date_end
                                  AND cata.ag_category_agent_id = ag.category_id
                                  AND rownum = 1) cat_name_ag
                             ,(SELECT aghl.num || '$' || cl.obj_name_orig
                                 FROM ins.ag_contract            ag
                                     ,ins.ag_contract            agl
                                     ,ins.ven_ag_contract_header aghl
                                     ,ins.contact                cl
                                WHERE ag.contract_id = av.ag_contract_header_id
                                  AND arh.date_end /*anv.sign_date*/
                                      BETWEEN ag.date_begin AND ag.date_end
                                  AND ag.contract_leader_id = agl.ag_contract_id
                                  AND agl.contract_id = aghl.ag_contract_header_id
                                  AND cl.contact_id = aghl.agent_id
                                  AND aghl.num <> ach.num
                                  AND rownum = 1) leader_agent
                FROM ven_ag_roll_header     arh
                    ,ven_ag_roll            ar
                    ,ag_perfomed_work_act   apw
                    ,ag_perfom_work_det     apd
                    ,ins.ag_rate_type       art
                    ,ag_perf_work_vol       apv
                    ,ven_ag_contract_header ach_s
                    ,contact                cn_as
                    ,ag_npf_volume_det      anv
                    ,ag_volume              av
                    ,ag_volume_type         avt
                    ,ven_ag_contract_header ach
                    ,ven_ag_contract_header leader_ach
                    ,ven_ag_contract        leader_ac
                    ,contact                cn_leader
                    ,contact                cn_a
                    ,department             dep
                    ,t_sales_channel        ts
                    ,ag_contract            ac
                    ,ag_category_agent      aca
                    ,t_contact_type         tct
               WHERE 1 = 1
                 AND arh.num = p_num_vedom
                 AND ((ar.num = p_vedom_ver AND p_reestr = 1) OR p_reestr = 0)
                 AND arh.ag_roll_header_id = ar.ag_roll_header_id
                 AND ar.ag_roll_id = apw.ag_roll_id
                 AND apw.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id
                 AND apd.ag_rate_type_id = art.ag_rate_type_id
                 AND ac.contract_f_lead_id = leader_ac.ag_contract_id(+)
                 AND leader_ac.contract_id = leader_ach.ag_contract_header_id(+)
                 AND leader_ach.agent_id = cn_leader.contact_id(+)
                 AND (art.brief IN ('WG_0510'
                                   ,'SS_0510'
                                   , /*'QMOPS_0510','QOPS_0510',*/'PG_0510'
                                   ,'Policy_commiss_GRS'
                                   ,'OAV_GRS'
                                   ,'FAKE_Sofi_prem_0510'
                                   ,'PG_0510'
                                   ,'PEXEC_0510') --,'LVL_0510')
                     --
                     OR art.brief IN ('QOPS_0510', 'QMOPS_0510') AND ts.brief IN ('SAS 2', 'SAS'))
                    --
                 AND apd.ag_perfom_work_det_id = apv.ag_perfom_work_det_id
                 AND apv.ag_volume_id = av.ag_volume_id
                 AND av.ag_contract_header_id = ach_s.ag_contract_header_id
                 AND ach_s.agent_id = cn_as.contact_id
                 AND av.ag_volume_id = anv.ag_volume_id
                 AND avt.ag_volume_type_id = av.ag_volume_type_id
                 AND ach.ag_contract_header_id = apw.ag_contract_header_id
                 AND ach.ag_contract_header_id = ac.contract_id
                 AND arh.date_end BETWEEN ac.date_begin AND ac.date_end
                 AND ac.agency_id = dep.department_id
                 AND ach.t_sales_channel_id = ts.id
                 AND ac.category_id = aca.ag_category_agent_id
                 AND cn_a.contact_id = ach.agent_id
                 AND tct.id = ac.leg_pos
                 AND aca.category_name IN ('Директор агентства 1 года'
                                          ,'Директор агентства 2 года')
                 AND ach.num = p_num_agent
                 AND (CASE
                       WHEN art.brief = 'KSP_0510' THEN
                        'За размер КСП'
                       WHEN art.brief = 'RE_POL_0510' THEN
                        'За договоры страхования, начиная со 2-го по 5-ый (включительно) годы действия'
                       WHEN art.brief = 'WG_0510' THEN
                        'За договоры страхования (1-го года)'
                       WHEN art.brief = 'FAKE_Sofi_prem_0510' THEN
                        'За договоры страхования (1-го года)'
                       WHEN art.brief = 'LVL_0510' THEN
                        'За достижение Уровня'
                       WHEN art.brief = 'ES_0510' THEN
                        'За сопровождение деятельности Рекрутированных Директоров'
                       WHEN art.brief = 'PENROL_0510' THEN
                        'За сопровождение деятельности Рекрутированных Директоров'
                       WHEN art.brief = 'PG_0510' THEN
                        'За договоры страхования/договоры ОПС/Кредитные договоры, заключенные при содействии Рекрутированных субагентов Директора'
                       WHEN art.brief = 'PEXEC_0510' THEN
                        'За выполнение Индивидуального плана'
                     --
                       WHEN art.brief = 'QOPS_0510' THEN
                        'За Договоры ОПС'
                       WHEN art.brief = 'QMOPS_0510' THEN
                        'За качественные Договоры ОПС'
                     --
                       ELSE
                        art.brief
                     END) = p_brief_prem);
  
  END;

  PROCEDURE set_data_for_prem(par_ag_roll_id ag_roll.ag_roll_id%TYPE) IS
    v_buf t_number_type := t_number_type();
  BEGIN
    INSERT INTO t_data_for_prem
      SELECT apd.ag_perfom_work_det_id
            ,apw.ag_perfomed_work_act_id
            ,arh.num vedom
            ,ar.num vedom_ver
            ,arh.date_end
            ,ts.description sales_ch
            ,dep.name agency
            ,aca.category_name
            ,cn_a.obj_name_orig ag_fio
            ,ach.num
            ,ach.ag_contract_header_id
            ,(SELECT aghl.num
                FROM ven_ag_contract_header agh
                    ,ag_contract            ag
                    ,ag_contract            agl
                    ,ven_ag_contract_header aghl
               WHERE agh.ag_contract_header_id = ach.ag_contract_header_id
                 AND agh.ag_contract_header_id = ag.contract_id
                 AND (SELECT MAX(acp1.due_date)
                        FROM doc_set_off dso1
                            ,ac_payment  acp1
                       WHERE dso1.parent_doc_id = av.epg_payment
                         AND acp1.payment_id = dso1.child_doc_id
                         AND acp1.payment_templ_id IN (6277, 4983, 2, 16125, 16123)) BETWEEN
                     ag.date_begin AND ag.date_end
                 AND agl.ag_contract_id = ag.contract_leader_id
                 AND aghl.ag_contract_header_id = agl.contract_id
                 AND rownum = 1) leader_manager
            ,NULL active_agent
            ,tct.description leg_pos
            ,leader_ach.num leader_num
            ,cn_leader.obj_name_orig leader_fio
            ,apw.ag_level
            ,apw.volumes.get_volume(1) rl_vol
            ,apw.volumes.get_volume(2) ops_vol
            ,apw.volumes.get_volume(3) sofi_vol
            ,apw.volumes.get_volume(5) sofi_pay_vol
            ,apw.ag_ksp ksp
            ,(SELECT apd1.summ
                FROM ag_perfom_work_det apd1
                    ,ag_rate_type       art1
               WHERE apd1.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
                 AND apd1.ag_rate_type_id = art1.ag_rate_type_id
                 AND art1.brief = 'WG_0510') work_group
            ,(SELECT apd1.summ
                FROM ag_perfom_work_det apd1
                    ,ag_rate_type       art1
               WHERE apd1.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
                 AND apd1.ag_rate_type_id = art1.ag_rate_type_id
                 AND art1.brief = 'RE_POL_0510') renewal_ploicy
            ,(SELECT apd1.summ
                FROM ag_perfom_work_det apd1
                    ,ag_rate_type       art1
               WHERE apd1.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
                 AND apd1.ag_rate_type_id = art1.ag_rate_type_id
                 AND art1.brief = 'SS_0510') self_sale
            ,(SELECT apd1.summ
                FROM ag_perfom_work_det apd1
                    ,ag_rate_type       art1
               WHERE apd1.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
                 AND apd1.ag_rate_type_id = art1.ag_rate_type_id
                 AND art1.brief = 'LVL_0510') level_reach
            ,(SELECT apd1.summ
                FROM ag_perfom_work_det apd1
                    ,ag_rate_type       art1
               WHERE apd1.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
                 AND apd1.ag_rate_type_id = art1.ag_rate_type_id
                 AND art1.brief = 'KSP_0510') ksp_reach
            ,(SELECT apd1.summ
                FROM ag_perfom_work_det apd1
                    ,ins.ag_rate_type   art1
               WHERE apd1.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
                 AND apd1.ag_rate_type_id = art1.ag_rate_type_id
                 AND art1.brief = 'ES_0510') evol_sub
            ,(SELECT apd1.summ
                FROM ag_perfom_work_det apd1
                    ,ins.ag_rate_type   art1
               WHERE apd1.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
                 AND apd1.ag_rate_type_id = art1.ag_rate_type_id
                 AND art1.brief = 'PENROL_0510') enrol_sub
            ,(SELECT apd1.summ
                FROM ag_perfom_work_det apd1
                    ,ag_rate_type       art1
               WHERE apd1.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
                 AND apd1.ag_rate_type_id = art1.ag_rate_type_id
                 AND art1.brief = 'PG_0510') personal_group
            ,(SELECT apd1.summ
                FROM ag_perfom_work_det apd1
                    ,ag_rate_type       art1
               WHERE apd1.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
                 AND apd1.ag_rate_type_id = art1.ag_rate_type_id
                 AND art1.brief = 'QOPS_0510') qualitative_ops
            ,(SELECT apd1.summ
                FROM ag_perfom_work_det apd1
                    ,ag_rate_type       art1
               WHERE apd1.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
                 AND apd1.ag_rate_type_id = art1.ag_rate_type_id
                 AND art1.brief = 'QMOPS_0510') q_male_ops
            ,(SELECT apd1.summ
                FROM ag_perfom_work_det apd1
                    ,ag_rate_type       art1
               WHERE apd1.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
                 AND apd1.ag_rate_type_id = art1.ag_rate_type_id
                 AND art1.brief = 'PEXEC_0510') plan_reach
            ,(SELECT apd1.summ
                FROM ag_perfom_work_det apd1
                    ,ag_rate_type       art1
               WHERE apd1.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
                 AND apd1.ag_rate_type_id = art1.ag_rate_type_id
                 AND art1.brief = 'Active_agent_0510') active_agents
            ,(SELECT apd1.summ
                FROM ag_perfom_work_det apd1
                    ,ag_rate_type       art1
               WHERE apd1.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
                 AND apd1.ag_rate_type_id = art1.ag_rate_type_id
                 AND art1.brief = 'Exec_plan_GRS') exec_plan_grs
            ,(SELECT apd1.summ
                FROM ag_perfom_work_det apd1
                    ,ag_rate_type       art1
               WHERE apd1.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
                 AND apd1.ag_rate_type_id = art1.ag_rate_type_id
                 AND art1.brief = 'Policy_commiss_GRS') policy_commiss_grs
            ,(SELECT apd1.summ
                FROM ag_perfom_work_det apd1
                    ,ag_rate_type       art1
               WHERE apd1.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
                 AND apd1.ag_rate_type_id = art1.ag_rate_type_id
                 AND art1.brief = 'OAV_GRS') self_sale_grs
            ,(SELECT asp.plan_value
                FROM ag_sale_plan asp
               WHERE asp.ag_contract_header_id = ach.ag_contract_header_id
                 AND asp.plan_type = 1
                 AND arh.date_end BETWEEN asp.date_begin AND asp.date_end) plan_value
            ,art.name prem_detail_name
            ,art.brief prem_detail_brief
            ,avt.description vol_type
            ,ach_s.num agent_ad
            ,cn_as.obj_name_orig agent_fio
            ,tp.description product
            ,ph.ids
            ,pp.pol_num
            ,ph.start_date
            ,cn_i.obj_name_orig insuer
            ,NULL assured_birf_date
            ,NULL gender
            ,(SELECT num FROM document d WHERE d.document_id = av.epg_payment) epg
            ,(SELECT MAX(acp1.due_date) --После первого расчета можно будет заменить на payment_date
                FROM doc_set_off dso1
                    ,ac_payment  acp1
               WHERE dso1.parent_doc_id = av.epg_payment
                 AND acp1.payment_id = dso1.child_doc_id
                 AND acp1.payment_templ_id IN (6277, 4983, 2, 16125, 16123)) payment_date
            ,tplo.description risk
            ,av.pay_period
            ,av.ins_period
            ,pt.description payment_term
            ,av.nbv_coef
            ,av.trans_sum
            ,av.index_delta_sum
            ,apv.vol_amount detail_amt
            ,apv.vol_rate detail_rate
            ,apv.vol_amount * apv.vol_rate detail_commis
            ,(SELECT aghl.num
                FROM ag_contract            agl
                    ,ag_contract            agll
                    ,ven_ag_contract_header aghl
               WHERE agl.contract_id = ach_s.ag_contract_header_id
                 AND (SELECT MAX(acp1.due_date)
                        FROM doc_set_off dso1
                            ,ac_payment  acp1
                       WHERE dso1.parent_doc_id = av.epg_payment
                         AND acp1.payment_id = dso1.child_doc_id
                         AND acp1.payment_templ_id IN (6277, 4983, 2, 16125, 16123)) BETWEEN
                     agl.date_begin AND agl.date_end
                 AND agl.contract_leader_id = agll.ag_contract_id
                 AND agll.contract_id = aghl.ag_contract_header_id
                 AND rownum = 1) agent_ad_leader
            ,apw.volumes.get_volume(6) inv_vol
            ,(SELECT cat.category_name
                FROM ven_ag_contract_header agh
                    ,ag_contract            ag
                    ,ag_category_agent      cat
               WHERE agh.ag_contract_header_id = ach_s.ag_contract_header_id
                 AND agh.ag_contract_header_id = ag.contract_id
                 AND (SELECT MAX(acp1.due_date)
                        FROM doc_set_off dso1
                            ,ac_payment  acp1
                       WHERE dso1.parent_doc_id = av.epg_payment
                         AND acp1.payment_id = dso1.child_doc_id
                         AND acp1.payment_templ_id IN (6277, 4983, 2, 16125, 16123)) BETWEEN
                     ag.date_begin AND ag.date_end
                 AND ag.category_id = cat.ag_category_agent_id
                 AND rownum = 1) agent_ad_category_paym
            ,(SELECT cat.category_name
                FROM ven_ag_contract_header agh
                    ,ag_contract            ag
                    ,ag_category_agent      cat
               WHERE agh.ag_contract_header_id = ach_s.ag_contract_header_id
                 AND agh.ag_contract_header_id = ag.contract_id
                 AND arh.date_end BETWEEN ag.date_begin AND ag.date_end
                 AND ag.category_id = cat.ag_category_agent_id
                 AND rownum = 1) agent_ad_category_arh
            ,(SELECT aghl.num
                FROM ven_ag_contract_header agh
                    ,ag_contract            ag
                    ,ag_contract            agl
                    ,ven_ag_contract_header aghl
               WHERE agh.ag_contract_header_id = ach.ag_contract_header_id
                 AND agh.ag_contract_header_id = ag.contract_id
                 AND arh.date_end BETWEEN ag.date_begin AND ag.date_end
                 AND agl.ag_contract_id = ag.contract_leader_id
                 AND aghl.ag_contract_header_id = agl.contract_id
                 AND rownum = 1) leader_manager_arh
            ,apw.volumes.get_volume(8) ops2_vol_1
            ,(SELECT aght.num
                FROM ven_ag_contract_header agh
                    ,ag_contract            ag
                    ,ag_contract            agl
                    ,ven_ag_contract_header aghl
                    ,ag_contract            agt
                    ,ag_contract            agtt
                    ,ven_ag_contract_header aght
               WHERE agh.ag_contract_header_id = ach.ag_contract_header_id
                 AND agh.ag_contract_header_id = ag.contract_id
                 AND (SELECT MAX(acp1.due_date)
                        FROM doc_set_off dso1
                            ,ac_payment  acp1
                       WHERE dso1.parent_doc_id = av.epg_payment
                         AND acp1.payment_id = dso1.child_doc_id
                         AND acp1.payment_templ_id IN (6277, 4983, 2, 16125, 16123)) BETWEEN
                     ag.date_begin AND ag.date_end
                 AND agl.ag_contract_id = ag.contract_leader_id
                 AND aghl.ag_contract_header_id = agl.contract_id
                    
                 AND aghl.ag_contract_header_id = agt.contract_id
                 AND (SELECT MAX(acp1.due_date)
                        FROM doc_set_off dso1
                            ,ac_payment  acp1
                       WHERE dso1.parent_doc_id = av.epg_payment
                         AND acp1.payment_id = dso1.child_doc_id
                         AND acp1.payment_templ_id IN (6277, 4983, 2, 16125, 16123)) BETWEEN
                     agt.date_begin AND agt.date_end
                 AND agt.contract_leader_id = agtt.ag_contract_id
                 AND agtt.contract_id = aght.ag_contract_header_id
                 AND rownum = 1) tr_dir_arh
            ,(SELECT apd1.summ
                FROM ins.ag_perfom_work_det apd1
                    ,ins.ag_rate_type       art1
               WHERE apd1.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
                 AND apd1.ag_rate_type_id = art1.ag_rate_type_id
                 AND art1.brief = 'KSP_KPI_Reach_0510') ksp_kpi_reach_0510
            ,(SELECT apd1.summ
                FROM ag_perfom_work_det apd1
                    ,ag_rate_type       art1
               WHERE apd1.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
                 AND apd1.ag_rate_type_id = art1.ag_rate_type_id
                 AND art1.brief = 'KPI_ORIG_OPS') kpi_orig_ops
            ,(SELECT apd1.summ
                FROM ag_perfom_work_det apd1
                    ,ag_rate_type       art1
               WHERE apd1.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
                 AND apd1.ag_rate_type_id = art1.ag_rate_type_id
                 AND art1.brief = 'KPI_PLAN_OPS') kpi_plan_ops
        FROM ven_ag_roll_header     arh
            ,ven_ag_roll            ar
            ,ag_perfomed_work_act   apw
            ,ag_perfom_work_det     apd
            ,ag_rate_type           art
            ,ag_perf_work_vol       apv
            ,ag_volume              av
            ,ag_volume_type         avt
            ,ven_ag_contract_header ach
            ,ven_ag_contract_header ach_s
            ,ven_ag_contract_header leader_ach
            ,ven_ag_contract        leader_ac
            ,contact                cn_leader
            ,contact                cn_as
            ,contact                cn_a
            ,department             dep
            ,t_sales_channel        ts
            ,ins.ag_contract        ac
            ,ag_category_agent      aca
            ,t_contact_type         tct
            ,p_pol_header           ph
            ,t_product              tp
            ,t_prod_line_option     tplo
            ,t_payment_terms        pt
            ,p_policy               pp
            ,contact                cn_i
       WHERE ar.ag_roll_id = par_ag_roll_id
         AND arh.ag_roll_header_id = ar.ag_roll_header_id
         AND ar.ag_roll_id = apw.ag_roll_id
         AND apw.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id
         AND apd.ag_rate_type_id = art.ag_rate_type_id
         AND art.brief IN ('WG_0510', 'SS_0510', 'RE_POL_0510', 'PG_0510') --,'Exec_plan_GRS','Policy_commiss_GRS') --,'LVL_0510')
         AND apd.ag_perfom_work_det_id = apv.ag_perfom_work_det_id
         AND apv.ag_volume_id = av.ag_volume_id
         AND av.policy_header_id = ph.policy_header_id
         AND av.ag_volume_type_id = avt.ag_volume_type_id
         AND av.ag_contract_header_id = ach_s.ag_contract_header_id
         AND ach_s.agent_id = cn_as.contact_id
         AND ac.contract_f_lead_id = leader_ac.ag_contract_id(+)
         AND leader_ac.contract_id = leader_ach.ag_contract_header_id(+)
         AND leader_ach.agent_id = cn_leader.contact_id(+)
         AND ph.policy_id = pp.policy_id
         AND ph.product_id = tp.product_id
         AND tplo.id = av.t_prod_line_option_id
         AND pkg_policy.get_policy_contact(ph.policy_id, 'Страхователь') = cn_i.contact_id
         AND ach.ag_contract_header_id = apw.ag_contract_header_id
         AND ach.ag_contract_header_id = ac.contract_id
         AND arh.date_end BETWEEN ac.date_begin AND ac.date_end
         AND ac.agency_id = dep.department_id
         AND ach.t_sales_channel_id = ts.id
         AND ac.category_id = aca.ag_category_agent_id
         AND cn_a.contact_id = ach.agent_id
         AND tct.id = ac.leg_pos
         AND pt.id = av.payment_term_id
      /*AND ach.num = '12969'*/
      
      UNION ALL
      
      SELECT apd.ag_perfom_work_det_id
            ,apw.ag_perfomed_work_act_id
            ,arh.num vedom
            ,ar.num vedom_ver
            ,arh.date_end
            ,ts.description sales_ch
            ,dep.name agency
            ,aca.category_name
            ,cn_a.obj_name_orig ag_fio
            ,ach.num
            ,ach.ag_contract_header_id
            ,(SELECT aghl.num
                FROM ven_ag_contract_header agh
                    ,ag_contract            ag
                    ,ag_contract            agl
                    ,ven_ag_contract_header aghl
               WHERE agh.ag_contract_header_id = ach.ag_contract_header_id
                 AND agh.ag_contract_header_id = ag.contract_id
                 AND ADD_MONTHS(anv.sign_date, -1) BETWEEN ag.date_begin AND ag.date_end
                 AND agl.ag_contract_id = ag.contract_leader_id
                 AND aghl.ag_contract_header_id = agl.contract_id
                 AND rownum = 1) leader_manager
            ,NULL active_agent
            ,tct.description leg_pos
            ,leader_ach.num leader_num
            ,cn_leader.obj_name_orig leader_fio
            ,apw.ag_level
            ,apw.volumes.get_volume(1) rl_vol
            ,apw.volumes.get_volume(2) ops_vol
            ,apw.volumes.get_volume(3) sofi_vol
            ,apw.volumes.get_volume(5) sofi_pay_vol
            ,apw.ag_ksp ksp
            ,(SELECT apd1.summ
                FROM ag_perfom_work_det apd1
                    ,ag_rate_type       art1
               WHERE apd1.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id --
                 AND apd1.ag_rate_type_id = art1.ag_rate_type_id
                 AND art1.brief = 'WG_0510') work_group
            ,(SELECT apd1.summ
                FROM ag_perfom_work_det apd1
                    ,ag_rate_type       art1
               WHERE apd1.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
                 AND apd1.ag_rate_type_id = art1.ag_rate_type_id
                 AND art1.brief = 'RE_POL_0510') renewal_ploicy
            ,(SELECT apd1.summ
                FROM ag_perfom_work_det apd1
                    ,ag_rate_type       art1
               WHERE apd1.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
                 AND apd1.ag_rate_type_id = art1.ag_rate_type_id
                 AND art1.brief = 'SS_0510') self_sale
            ,(SELECT apd1.summ
                FROM ag_perfom_work_det apd1
                    ,ag_rate_type       art1
               WHERE apd1.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
                 AND apd1.ag_rate_type_id = art1.ag_rate_type_id
                 AND art1.brief = 'LVL_0510') level_reach
            ,(SELECT apd1.summ
                FROM ag_perfom_work_det apd1
                    ,ag_rate_type       art1
               WHERE apd1.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
                 AND apd1.ag_rate_type_id = art1.ag_rate_type_id
                 AND art1.brief = 'KSP_0510') ksp_reach
            ,(SELECT apd1.summ
                FROM ag_perfom_work_det apd1
                    ,ag_rate_type       art1
               WHERE apd1.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
                 AND apd1.ag_rate_type_id = art1.ag_rate_type_id
                 AND art1.brief = 'ES_0510') evol_sub
            ,(SELECT apd1.summ
                FROM ag_perfom_work_det apd1
                    ,ins.ag_rate_type   art1
               WHERE apd1.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
                 AND apd1.ag_rate_type_id = art1.ag_rate_type_id
                 AND art1.brief = 'PENROL_0510') enrol_sub
            ,(SELECT apd1.summ
                FROM ag_perfom_work_det apd1
                    ,ag_rate_type       art1
               WHERE apd1.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
                 AND apd1.ag_rate_type_id = art1.ag_rate_type_id
                 AND art1.brief = 'PG_0510') personal_group
            ,(SELECT apd1.summ
                FROM ag_perfom_work_det apd1
                    ,ag_rate_type       art1
               WHERE apd1.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
                 AND apd1.ag_rate_type_id = art1.ag_rate_type_id
                 AND art1.brief = 'QOPS_0510') qualitative_ops
            ,(SELECT apd1.summ
                FROM ag_perfom_work_det apd1
                    ,ag_rate_type       art1
               WHERE apd1.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
                 AND apd1.ag_rate_type_id = art1.ag_rate_type_id
                 AND art1.brief = 'QMOPS_0510') q_male_ops
            ,(SELECT apd1.summ
                FROM ag_perfom_work_det apd1
                    ,ag_rate_type       art1
               WHERE apd1.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
                 AND apd1.ag_rate_type_id = art1.ag_rate_type_id
                 AND art1.brief = 'PEXEC_0510') plan_reach
            ,(SELECT apd1.summ
                FROM ag_perfom_work_det apd1
                    ,ag_rate_type       art1
               WHERE apd1.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
                 AND apd1.ag_rate_type_id = art1.ag_rate_type_id
                 AND art1.brief = 'Active_agent_0510') plan_reach
            ,(SELECT apd1.summ
                FROM ag_perfom_work_det apd1
                    ,ag_rate_type       art1
               WHERE apd1.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
                 AND apd1.ag_rate_type_id = art1.ag_rate_type_id
                 AND art1.brief = 'Exec_plan_GRS') exec_plan_grs
            ,(SELECT apd1.summ
                FROM ag_perfom_work_det apd1
                    ,ag_rate_type       art1
               WHERE apd1.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
                 AND apd1.ag_rate_type_id = art1.ag_rate_type_id
                 AND art1.brief = 'Policy_commiss_GRS') policy_commiss_grs
            ,(SELECT apd1.summ
                FROM ag_perfom_work_det apd1
                    ,ag_rate_type       art1
               WHERE apd1.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
                 AND apd1.ag_rate_type_id = art1.ag_rate_type_id
                 AND art1.brief = 'OAV_GRS') self_sale_grs
            ,(SELECT asp.plan_value
                FROM ag_sale_plan asp
               WHERE asp.ag_contract_header_id = ach.ag_contract_header_id
                 AND asp.plan_type = 1
                 AND arh.date_end BETWEEN asp.date_begin AND asp.date_end) plan_value
            ,art.name prem
            ,art.brief prem_detail_brief
            ,avt.description vol_type
            ,ach_s.num agent_ad
            ,cn_as.obj_name_orig agent_fio
            ,NULL product
            ,NULL
            ,anv.snils
            ,anv.sign_date
            ,anv.fio insuer
            ,anv.assured_birf_date
            ,anv.gender
            ,NULL epg
            ,NULL
            ,NULL risk
            ,NULL
            ,NULL
            ,NULL payment_term
            ,av.nbv_coef
            ,av.trans_sum
            ,av.index_delta_sum
            ,apv.vol_amount detail_amt
            ,apv.vol_rate detail_rate
            ,apv.vol_amount * apv.vol_rate detail_commis
            ,(SELECT aghl.num
                FROM ag_contract            agl
                    ,ag_contract            agll
                    ,ven_ag_contract_header aghl
               WHERE agl.contract_id = ach_s.ag_contract_header_id
                 AND ADD_MONTHS(anv.sign_date, -1) BETWEEN agl.date_begin AND agl.date_end
                 AND agl.contract_leader_id = agll.ag_contract_id
                 AND agll.contract_id = aghl.ag_contract_header_id
                 AND rownum = 1) agent_ad_leader
            ,apw.volumes.get_volume(6) inv_vol
            ,(SELECT cat.category_name
                FROM ven_ag_contract_header agh
                    ,ag_contract            ag
                    ,ag_category_agent      cat
               WHERE agh.ag_contract_header_id = ach_s.ag_contract_header_id
                 AND agh.ag_contract_header_id = ag.contract_id
                 AND arh.date_end BETWEEN ag.date_begin AND ag.date_end
                 AND ag.category_id = cat.ag_category_agent_id
                 AND rownum = 1) agent_ad_category_paym
            ,(SELECT cat.category_name
                FROM ven_ag_contract_header agh
                    ,ag_contract            ag
                    ,ag_category_agent      cat
               WHERE agh.ag_contract_header_id = ach_s.ag_contract_header_id
                 AND agh.ag_contract_header_id = ag.contract_id
                 AND arh.date_end BETWEEN ag.date_begin AND ag.date_end
                 AND ag.category_id = cat.ag_category_agent_id
                 AND rownum = 1) agent_ad_category_arh
            ,(SELECT aghl.num
                FROM ven_ag_contract_header agh
                    ,ag_contract            ag
                    ,ag_contract            agl
                    ,ven_ag_contract_header aghl
               WHERE agh.ag_contract_header_id = ach.ag_contract_header_id
                 AND agh.ag_contract_header_id = ag.contract_id
                 AND arh.date_end BETWEEN ag.date_begin AND ag.date_end
                 AND agl.ag_contract_id = ag.contract_leader_id
                 AND aghl.ag_contract_header_id = agl.contract_id
                 AND rownum = 1) leader_manager_arh
            ,apw.volumes.get_volume(8) ops2_vol_1
            ,(SELECT aght.num
                FROM ven_ag_contract_header agh
                    ,ag_contract            ag
                    ,ag_contract            agl
                    ,ven_ag_contract_header aghl
                    ,ag_contract            agt
                    ,ag_contract            agtt
                    ,ven_ag_contract_header aght
               WHERE agh.ag_contract_header_id = ach.ag_contract_header_id
                 AND agh.ag_contract_header_id = ag.contract_id
                 AND ADD_MONTHS(anv.sign_date, -1) BETWEEN ag.date_begin AND ag.date_end
                 AND agl.ag_contract_id = ag.contract_leader_id
                 AND aghl.ag_contract_header_id = agl.contract_id
                    
                 AND aghl.ag_contract_header_id = agt.contract_id
                 AND ADD_MONTHS(anv.sign_date, -1) BETWEEN agt.date_begin AND agt.date_end
                 AND agt.contract_leader_id = agtt.ag_contract_id
                 AND agtt.contract_id = aght.ag_contract_header_id
                 AND rownum = 1) tr_dir_arh
            ,(SELECT apd1.summ
                FROM ins.ag_perfom_work_det apd1
                    ,ins.ag_rate_type       art1
               WHERE apd1.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
                 AND apd1.ag_rate_type_id = art1.ag_rate_type_id
                 AND art1.brief = 'KSP_KPI_Reach_0510') ksp_kpi_reach_0510
            ,(SELECT apd1.summ
                FROM ag_perfom_work_det apd1
                    ,ag_rate_type       art1
               WHERE apd1.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
                 AND apd1.ag_rate_type_id = art1.ag_rate_type_id
                 AND art1.brief = 'KPI_ORIG_OPS') kpi_orig_ops
            ,(SELECT apd1.summ
                FROM ag_perfom_work_det apd1
                    ,ag_rate_type       art1
               WHERE apd1.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
                 AND apd1.ag_rate_type_id = art1.ag_rate_type_id
                 AND art1.brief = 'KPI_PLAN_OPS') kpi_plan_ops
        FROM ven_ag_roll_header     arh
            ,ven_ag_roll            ar
            ,ag_perfomed_work_act   apw
            ,ag_perfom_work_det     apd
            ,ins.ag_rate_type       art
            ,ag_perf_work_vol       apv
            ,ven_ag_contract_header ach_s
            ,contact                cn_as
            ,ag_npf_volume_det      anv
            ,ag_volume              av
            ,ag_volume_type         avt
            ,ven_ag_contract_header ach
            ,ven_ag_contract_header leader_ach
            ,ven_ag_contract        leader_ac
            ,contact                cn_leader
            ,contact                cn_a
            ,department             dep
            ,t_sales_channel        ts
            ,ag_contract            ac
            ,ag_category_agent      aca
            ,t_contact_type         tct
       WHERE ar.ag_roll_id = par_ag_roll_id
         AND arh.ag_roll_header_id = ar.ag_roll_header_id
         AND ar.ag_roll_id = apw.ag_roll_id
         AND apw.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id
         AND apd.ag_rate_type_id = art.ag_rate_type_id
         AND ac.contract_f_lead_id = leader_ac.ag_contract_id(+)
         AND leader_ac.contract_id = leader_ach.ag_contract_header_id(+)
         AND leader_ach.agent_id = cn_leader.contact_id(+)
         AND art.brief IN ('WG_0510'
                          ,'SS_0510'
                          ,'QMOPS_0510'
                          ,'QOPS_0510'
                          ,'PG_0510'
                          ,'Policy_commiss_GRS'
                          ,'OAV_GRS'
                          ,'FAKE_Sofi_prem_0510') --,'LVL_0510')
         AND apd.ag_perfom_work_det_id = apv.ag_perfom_work_det_id
         AND apv.ag_volume_id = av.ag_volume_id
         AND av.ag_contract_header_id = ach_s.ag_contract_header_id
         AND ach_s.agent_id = cn_as.contact_id
         AND av.ag_volume_id = anv.ag_volume_id
         AND avt.ag_volume_type_id = av.ag_volume_type_id
         AND ach.ag_contract_header_id = apw.ag_contract_header_id
         AND ach.ag_contract_header_id = ac.contract_id
         AND arh.date_end BETWEEN ac.date_begin AND ac.date_end
         AND ac.agency_id = dep.department_id
         AND ach.t_sales_channel_id = ts.id
         AND ac.category_id = aca.ag_category_agent_id
         AND cn_a.contact_id = ach.agent_id
         AND tct.id = ac.leg_pos
      /*AND ach.num = '12969'*/
      ;
  
  END set_data_for_prem;

  PROCEDURE get_info_ach(p_ach_id PLS_INTEGER) IS
  BEGIN
  
    INSERT INTO t_info_ach
      SELECT ac.num + 1 num_ver
            ,dep.name dept
            ,decode(ch.description
                   ,'DSF'
                   ,ch.description
                   ,'SAS'
                   ,ch.description
                   ,'SAS 2'
                   ,ch.description
                   ,'') dsf
            ,d.num num
            ,to_char(ach.date_begin, 'dd.mm.yyyy') date_begin
            ,TRIM(to_char(ach.date_begin, 'DD') || ' ' ||
                  TRIM(initcap(to_char(ach.date_begin, 'MONTH', 'NLS_DATE_LANGUAGE = RUSSIAN'))) || ' ' ||
                  to_char(ach.date_begin, 'YYYY')) date_prn
            ,tct.brief || ' ' || ent.obj_name(246, ach.agent_id) agent_name
            ,(SELECT CASE rla.brief
                       WHEN 'GEN_DIR' THEN
                        'Генерального директора'
                       WHEN 'ISP_DIR' THEN
                        'Испольнительного директора'
                       WHEN 'PRED_PRAV' THEN
                        'Председателя правления'
                       ELSE
                        ''
                     END || ' ' || cdir.genitive
                FROM cn_contact_rel     cr
                    ,t_contact_rel_type rt
                    ,t_contact_role     rl
                    ,t_contact_role     rla
                    ,contact            cdir
               WHERE cr.contact_id_a = ach.agent_id
                 AND cr.relationship_type = rt.id
                 AND rt.target_contact_role_id = rl.id
                 AND rl.description = 'Агент'
                 AND rt.source_contact_role_id = rla.id
                 AND rla.brief IN ('GEN_DIR', 'ISP_DIR', 'PRED_PRAV')
                 AND cdir.contact_id = cr.contact_id_b
                 AND rownum = 1) rel_type
            ,(SELECT MAX(CASE it.description
                           WHEN 'Доверенность' THEN
                            'Доверенности № '
                           WHEN 'Устав' THEN
                            'Устава № '
                           ELSE
                            ''
                         END || ci.id_value) keep(dense_rank FIRST ORDER BY ci.is_default, it.description DESC NULLS LAST)
                FROM cn_contact_ident ci
                    ,t_id_type        it
               WHERE ci.id_type = it.id
                 AND it.description IN ('Доверенность', 'Устав')
                 AND ci.contact_id = ach.agent_id) on_ustav
            ,(SELECT 'Адрес местонахождения: ' || MAX(pkg_contact.get_address_name(adr.id)) keep(dense_rank FIRST ORDER BY ca.is_default DESC NULLS LAST)
                FROM cn_contact_address ca
                    ,cn_address         adr
                    ,t_address_type     adt
               WHERE ca.contact_id = ach.agent_id
                 AND ca.adress_id = adr.id
                 AND ca.address_type = adt.id
                 AND adt.description = 'Адрес постоянной регистрации') adr_reg
            ,(SELECT 'Почтовый адрес: ' || MAX(pkg_contact.get_address_name(adr.id)) keep(dense_rank FIRST ORDER BY ca.is_default DESC NULLS LAST)
                FROM cn_contact_address ca
                    ,cn_address         adr
                    ,t_address_type     adt
               WHERE ca.contact_id = ach.agent_id
                 AND ca.adress_id = adr.id
                 AND ca.address_type = adt.id
                 AND adt.description = 'Почтовый адрес') adr_post
            ,(SELECT 'ИНН: ' || MAX(ci.id_value) keep(dense_rank FIRST ORDER BY ci.is_default DESC NULLS LAST)
                FROM cn_contact_ident ci
                    ,t_id_type        it
               WHERE ci.id_type = it.id
                 AND it.description = 'ИНН'
                 AND ci.contact_id = ach.agent_id) v_inn
            ,(SELECT 'КПП: ' || MAX(ci.id_value) keep(dense_rank FIRST ORDER BY ci.is_default DESC NULLS LAST)
                FROM cn_contact_ident ci
                    ,t_id_type        it
               WHERE ci.id_type = it.id
                 AND it.description = 'КПП'
                 AND ci.contact_id = ach.agent_id) v_kpp
            ,(SELECT 'ОГРН: ' || MAX(ci.id_value) keep(dense_rank FIRST ORDER BY ci.is_default DESC NULLS LAST)
                FROM cn_contact_ident ci
                    ,t_id_type        it
               WHERE ci.id_type = it.id
                 AND it.description = 'ОГРН'
                 AND ci.contact_id = ach.agent_id) v_ogrn
            ,(SELECT 'Р/сч: ' || bp.account
                FROM ins.ag_bank_props bp
               WHERE bp.ag_contract_header_id = ach.ag_contract_header_id
                 AND bp.enable = 1) r_s
            ,(SELECT 'Банк: ' || c.name
                FROM ins.ag_bank_props bp
                    ,contact           c
                    ,t_contact_type    ct
                    ,cn_contact_ident  ii
                    ,t_id_type         t
               WHERE bp.ag_contract_header_id = ach.ag_contract_header_id
                 AND bp.enable = 1
                 AND c.contact_type_id = ct.id
                 AND ct.brief = 'КБ'
                 AND ii.contact_id = c.contact_id
                 AND ii.id_type = t.id
                 AND t.brief = 'BIK'
                 AND c.contact_id = bp.bank_id) bank_name
            ,(SELECT 'Корр./сч: ' || ii.id_value
                FROM ins.ag_bank_props bp
                    ,contact           c
                    ,t_contact_type    ct
                    ,cn_contact_ident  ii
                    ,t_id_type         t
               WHERE bp.ag_contract_header_id = ach.ag_contract_header_id
                 AND bp.enable = 1
                 AND c.contact_type_id = ct.id
                 AND ct.brief = 'КБ'
                 AND ii.contact_id = c.contact_id
                 AND ii.id_type = t.id
                 AND t.brief = 'KORR'
                 AND c.contact_id = bp.bank_id) korr
            ,(SELECT 'БИК: ' || ii.id_value
                FROM ins.ag_bank_props bp
                    ,contact           c
                    ,t_contact_type    ct
                    ,cn_contact_ident  ii
                    ,t_id_type         t
               WHERE bp.ag_contract_header_id = ach.ag_contract_header_id
                 AND bp.enable = 1
                 AND c.contact_type_id = ct.id
                 AND ct.brief = 'КБ'
                 AND ii.contact_id = c.contact_id
                 AND ii.id_type = t.id
                 AND t.brief = 'BIK'
                 AND c.contact_id = bp.bank_id) bik
            ,(SELECT 'Тел. ' || MAX(tel.telephone_number) keep(dense_rank FIRST ORDER BY tel.telephone_number DESC NULLS LAST)
                FROM cn_contact_telephone tel
                    ,t_telephone_type     tt
               WHERE tel.contact_id = ach.agent_id
                 AND tel.telephone_type = tt.id
                 AND tt.description = 'Рабочий телефон') tel
        FROM ven_ag_contract_header ach
            ,ven_ag_contract        ac
            ,ven_department         dep
            ,ven_document           d
            ,contact                ag_cont
            ,t_contact_type         tct
            ,t_sales_channel        ch
       WHERE ac.ag_contract_id = ach.last_ver_id
         AND ach.agency_id = dep.department_id(+)
         AND ag_cont.contact_id = ach.agent_id(+)
         AND ag_cont.contact_type_id = tct.id
         AND d.document_id = ach.ag_contract_header_id
         AND ach.t_sales_channel_id = ch.id
         AND ach.ag_contract_header_id = p_ach_id;
  
  END;

  /*
    Байтин А.
    Проверка существования агента в продающем подразделении
  */
  PROCEDURE check_is_agent_in_dept(par_document_id NUMBER) IS
    v_agent_name   contact.obj_name_orig%TYPE;
    v_agency_codes VARCHAR2(4000);
    v_is_break     INT;
  BEGIN
    -- Получаем агента
    SELECT co.obj_name_orig
      INTO v_agent_name
      FROM ag_contract_header ch
          ,contact            co
     WHERE ch.ag_contract_header_id = par_document_id
       AND ch.agent_id = co.contact_id;
  
    -- Чирков 256819 Не удается расторгнуть САД
    -- Проверяем расторгается ли договор АД
    SELECT COUNT(1)
      INTO v_is_break
      FROM dual
     WHERE EXISTS (SELECT dsr.brief
              FROM ins.document       d
                  ,ins.doc_status_ref dsr
             WHERE d.document_id = par_document_id
               AND dsr.doc_status_ref_id = d.doc_status_ref_id
               AND dsr.brief = 'BREAK');
    --end--256819
  
    -- Получаем список агентств
    SELECT pkg_utils.get_aggregated_string(CAST(MULTISET
                                                (SELECT to_char(sh.universal_code, 'FM0009')
                                                   FROM ven_sales_dept        sd
                                                       ,ven_sales_dept_header sh
                                                  WHERE sd.sales_dept_id = sh.last_sales_dept_id
                                                    AND sd.manager_id = par_document_id
                                                    AND (v_is_break = 0 OR
                                                        (v_is_break = 1 AND sd.close_date IS NULL))) AS
                                                tt_one_col)
                                          ,', ')
      INTO v_agency_codes
      FROM dual;
    IF v_agency_codes IS NOT NULL
    THEN
      g_message.state   := 'Err';
      g_message.message := 'Внимание! ' || v_agent_name ||
                           ' является руководителем в подразделении номер ' || v_agency_codes || '.' ||
                           ' Переход статусов запрещен.';
    END IF;
  END check_is_agent_in_dept;

  /*Изместьев Д.
  заявка 173706
  проверка при изменении Категории на АГЕНТ
  
  Байтин А.
  Отключена по заявке 210001
  */
  /*
    PROCEDURE check_is_manager_in_dept
    (
      par_document_id number
    )
    IS
      v_category_brief     ag_category_agent.brief%type;
      v_contract_header_id number;
    BEGIN
      SELECT (SELECT ca.brief
                FROM ag_category_agent ca
               WHERE ca.ag_category_agent_id = pc.new_value)
            ,ag.ag_contract_header_id
        INTO v_category_brief
            ,v_contract_header_id
        FROM ag_documents    ag
            ,ag_doc_type     dt
            ,ag_props_change pc
            ,ag_props_type   pt
       WHERE ag.ag_documents_id  = par_document_id
         AND ag.ag_doc_type_id   = dt.ag_doc_type_id
         AND ag.ag_documents_id  = pc.ag_documents_id
         AND pc.ag_props_type_id = pt.ag_props_type_id
         AND pt.brief            = 'CAT_PROP'
         AND dt.brief            = 'CAT_CHG';
      IF v_category_brief = 'AG' then
        check_is_agent_in_dept(par_document_id => v_contract_header_id);
      END if;
    exception
      when NO_DATA_FOUND then
        null;
    END check_is_manager_in_dept;
  */
  /*
    Изместьев Д.И.  26.09.2012
    Заявка 181634
    Процедура проверки импортируемых Договоров страхования, переходящих на прямое сопровождение компании
  */

  PROCEDURE set_agent_escort_latepay_check
  (
    par_load_file_rows_id NUMBER
   ,par_status            OUT VARCHAR2
   ,par_comment           OUT VARCHAR2
  ) IS
    v_ach            ins.ag_contract_header.ag_contract_header_id%TYPE;
    v_issuer         ins.contact.obj_name_orig%TYPE;
    v_ach_curr       ins.ag_contract_header.ag_contract_header_id%TYPE;
    v_ach_date_begin DATE;
    v_agent_ds       ins.contact.obj_name_orig%TYPE;
    v_pol_header     ins.p_pol_header.policy_header_id%TYPE;
    v_end_date       DATE;
  BEGIN
    --проверяем наличие агента 14013 Прямое сопровождение компании
    BEGIN
      SELECT ach.ag_contract_header_id
        INTO v_ach
        FROM ins.ven_ag_contract_header ach
            ,ins.contact                cn
       WHERE cn.contact_id = ach.agent_id
         AND cn.obj_name_orig = 'Прямое сопровождение компании'
         AND ach.num = '14013';
    EXCEPTION
      WHEN no_data_found THEN
        par_status  := pkg_load_file_to_table.get_error;
        par_comment := 'Не найден агент 14013 Прямое сопровождение компании';
    END;
    --проверяем ИДС на корректность
    BEGIN
      SELECT /*ph.policy_header_id,*/
       vpi.contact_name
        INTO /*v_chk,*/ v_issuer
        FROM p_pol_header     ph
            ,ins.v_pol_issuer vpi
       WHERE vpi.policy_id(+) = ph.last_ver_id
         AND ph.ids = (SELECT to_number(lf.val_1)
                         FROM load_file_rows lf
                        WHERE lf.load_file_rows_id = par_load_file_rows_id);
    EXCEPTION
      WHEN no_data_found THEN
        par_status  := pkg_load_file_to_table.get_error;
        par_comment := 'ИДС неверный, либо такого договора не существует.';
    END;
    IF par_comment IS NULL
    THEN
      --ДС найден, идем дальше
      --вычисляем текущего агента ДО и его дату окончания
      SELECT /* pad.p_policy_agent_doc_id,*/
       pad.ag_contract_header_id
      ,pad.date_begin
      ,(SELECT dc1.num FROM document dc1 WHERE dc1.document_id = ach.ag_contract_header_id) || ' ' ||
       cn.obj_name_orig
      ,ph.policy_header_id
        INTO /*v_agent_doc_id,*/ v_ach_curr
            ,v_ach_date_begin
            ,v_agent_ds
            ,v_pol_header
        FROM p_policy_agent_doc pad
             -- ,document               dc
             -- ,doc_status_ref         dsr
            ,p_pol_header       ph
            ,ag_contract_header ach
            ,contact            cn
       WHERE pad.policy_header_id = ph.policy_header_id
         AND ach.ag_contract_header_id = pad.ag_contract_header_id
         AND cn.contact_id = ach.agent_id
         AND ph.ids IN (SELECT to_number(lf.val_1)
                          FROM load_file_rows lf
                         WHERE lf.load_file_rows_id = par_load_file_rows_id)
         AND ins.doc.get_doc_status_brief(pad.p_policy_agent_doc_id) = 'CURRENT';
    
      --проверка даты перевода на корректность:
      --больше, чем дата начала последнего агента по договору
      BEGIN
        SELECT vpi.contact_name
              ,pp.end_date
          INTO v_issuer
              ,v_end_date
          FROM ins.p_pol_header ph
              ,ins.p_policy     pp
              ,ins.v_pol_issuer vpi
         WHERE pp.policy_id = ph.last_ver_id
           AND vpi.policy_id = pp.policy_id
           AND (SELECT lf.val_2
                  FROM load_file_rows lf
                 WHERE lf.load_file_rows_id = par_load_file_rows_id) BETWEEN v_ach_date_begin AND
               pp.end_date
           AND ph.ids IN (SELECT to_number(lf.val_1)
                            FROM load_file_rows lf
                           WHERE lf.load_file_rows_id = par_load_file_rows_id);
        --?? v_agent_ds:='14013 Прямое сопровождение компании';
        par_comment := 'ok';
        par_status  := pkg_load_file_to_table.get_checked;
      EXCEPTION
        WHEN no_data_found THEN
          par_comment := 'Дата перевода должна быть больше, чем дата начала последнего агента и меньше, чем дата окончания договора.';
          par_status  := pkg_load_file_to_table.get_error;
          --  dbms_output.put_line(p_result);
      END;
    END IF;
    IF v_agent_ds = '14013 Прямое сопровождение компании'
    THEN
      par_comment := 'ДС уже переведен на агента 14013 Прямое сопровождение компании от ' ||
                     to_char(v_ach_date_begin, 'dd.mm.yyyy');
      par_status  := pkg_load_file_to_table.get_not_need_to_load;
    END IF;
    UPDATE load_file_rows lf
       SET lf.val_4 = v_agent_ds
          ,lf.val_3 = v_issuer
          ,lf.val_5 = par_comment
     WHERE lf.load_file_rows_id = par_load_file_rows_id;
  END set_agent_escort_latepay_check;

  /*
    Изместьев Д.И.  26.09.2012
    Заявка 181634
    Процедура загрузки импортируемых Договоров страхования, переходящих на прямое сопровождение компании
  */

  PROCEDURE set_agent_escort_latepay_load(par_load_file_rows_id NUMBER) IS
    v_ach          ins.ag_contract_header.ag_contract_header_id%TYPE;
    v_ach_curr     ins.ag_contract_header.ag_contract_header_id%TYPE;
    v_agent_doc_id NUMBER;
    v_end_date     DATE;
    v_date_im      DATE;
    v_pol_header   ins.p_pol_header.policy_header_id%TYPE;
    v_res          VARCHAR2(200);
  BEGIN
    --на всякий случай убедимся что данного агента никто не грохнул
    BEGIN
      SELECT ach.ag_contract_header_id
        INTO v_ach
        FROM ins.ven_ag_contract_header ach
            ,ins.contact                cn
       WHERE cn.contact_id = ach.agent_id
         AND cn.obj_name_orig = 'Прямое сопровождение компании'
         AND ach.num = '14013';
      --глянем статус строки
      SELECT lf.val_5
        INTO v_res
        FROM load_file_rows lf
       WHERE lf.load_file_rows_id = par_load_file_rows_id;
    EXCEPTION
      WHEN no_data_found THEN
        v_res := 'Не найден агент 14013 Прямое сопровождение компании';
    END;
    --соберем данные для вставки
    SELECT ph.policy_header_id
          ,pp.end_date
      INTO v_pol_header
          ,v_end_date
      FROM ins.p_pol_header ph
          ,ins.p_policy     pp
     WHERE pp.policy_id = ph.last_ver_id
       AND ph.ids IN (SELECT to_number(lf.val_1)
                        FROM load_file_rows lf
                       WHERE lf.load_file_rows_id = par_load_file_rows_id);
    --Получаем дату заливки
    SELECT lf.val_2
      INTO v_date_im
      FROM load_file_rows lf
     WHERE lf.load_file_rows_id = par_load_file_rows_id;
  
    --Проверяем текущего агента ДС
    BEGIN
      SELECT pad.p_policy_agent_doc_id
            ,pad.ag_contract_header_id
        INTO v_agent_doc_id
            ,v_ach_curr
        FROM ven_p_policy_agent_doc pad
       WHERE pad.policy_header_id = v_pol_header
         AND ins.doc.get_doc_status_brief(pad.p_policy_agent_doc_id) = 'CURRENT';
    EXCEPTION
      WHEN no_data_found THEN
        v_res := 'Не найден действующий агент в ДС';
      WHEN too_many_rows THEN
        v_res := 'Найдено несколько ДЕЙСТВУЮЩИХ агентов в ДС';
    END;
    --если все ОК
    IF v_res = 'ok'
       AND v_ach_curr != v_ach
    THEN
      --Перевод предыдущего агента в статус отменен
      doc.set_doc_status(p_doc_id       => v_agent_doc_id
                        ,p_status_brief => 'CANCEL'
                        ,p_note         => 'Перевод на Прямое сопровождение компании');
      UPDATE p_policy_agent_doc pad
         SET pad.date_end = v_date_im - 1 / 24
       WHERE pad.p_policy_agent_doc_id = v_agent_doc_id;
      --
      SELECT sq_p_policy_agent_doc.nextval INTO v_agent_doc_id FROM dual;
    
      --добавляем агента:14013 Прямое сопровождение компании
      INSERT INTO ven_p_policy_agent_doc
        (p_policy_agent_doc_id
        ,ag_contract_header_id
        ,date_end
        ,date_begin
        ,policy_header_id
        ,doc_templ_id
        ,note)
      VALUES
        (v_agent_doc_id
        ,v_ach
        , --агент 14013 Прямое сопровождение компании
         v_end_date
        , --Дата окончания договора страхования
         v_date_im
        , --Дата восстановления
         v_pol_header
        ,18093
        , --Документ - агент по договору
         'Передача при импорте');
    
      doc.set_doc_status(v_agent_doc_id, 'NEW');
      doc.set_doc_status(v_agent_doc_id, 'CURRENT');
      v_res := 'загружен успешно';
    ELSE
      v_res := 'Данный ДС не прошел проверку';
    END IF;
    UPDATE load_file_rows lf SET lf.val_5 = v_res WHERE lf.load_file_rows_id = par_load_file_rows_id;
  END set_agent_escort_latepay_load;

  /*
    Байтин А.
    Заявка 191992
    Проверка наличия заполненного места рождения у агента
    при переводе из "документ добавлен" в "проект"
  */
  PROCEDURE check_birth_place(par_ag_document_id NUMBER) IS
    v_place_of_birth cn_person.place_of_birth%TYPE;
    v_doc_type       ag_doc_type.brief%TYPE;
    v_agent_id       ag_contract_header.agent_id%TYPE;
  BEGIN
    IF g_message.state = 'Ok'
    THEN
      SELECT cp.place_of_birth
            ,dt.brief
            ,ch.agent_id
        INTO v_place_of_birth
            ,v_doc_type
            ,v_agent_id
        FROM ag_documents       ad
            ,ag_contract_header ch
            ,cn_person          cp
            ,ag_doc_type        dt
       WHERE ad.ag_documents_id = par_ag_document_id
         AND ad.ag_contract_header_id = ch.ag_contract_header_id
         AND ad.ag_doc_type_id = dt.ag_doc_type_id
         AND ch.agent_id = cp.contact_id(+);
    
      --204691
      IF v_doc_type = 'NEW_AD'
         AND v_place_of_birth IS NULL
         AND pkg_contact.get_is_individual(par_contact_id => v_agent_id) = 1
      -- Капля П. Проверки на физлиц делаются через этот флаг, а не через тип. 
      -- Смотри форму контакта, чем определяется создается ли запись в cn_person
      --AND v_cont_type_brief = 'ФЛ' /*Чирков/204691 только у физ. лица должна быть проверка на место рождения*/
      THEN
        g_message.state   := 'Err';
        g_message.message := 'Обратите внимание: необходимо заполнить поле Место рождения, сохранение запрещено!';
      END IF;
    END IF;
  END check_birth_place;

  /*
    Байтин А.
    Заявка 191992
    Проверка наличия заполненного кода подразделения в паспортных данных у агента
    при переводе из "документ добавлен" в "проект"
  */
  PROCEDURE check_subdiv_code(par_ag_document_id NUMBER) IS
    v_contact_id      NUMBER;
    v_is_exists       NUMBER(1);
    v_doc_type        ag_doc_type.brief%TYPE;
    v_cont_type_brief t_contact_type.brief%TYPE;
  BEGIN
    IF g_message.state = 'Ok'
    THEN
      SELECT ch.agent_id
            ,dt.brief
            ,ct.brief --204691
        INTO v_contact_id
            ,v_doc_type
            ,v_cont_type_brief
        FROM ag_documents       ad
            ,ag_contract_header ch
            ,ag_doc_type        dt
             --204691
            ,contact        c
            ,t_contact_type ct
      --
       WHERE ad.ag_documents_id = par_ag_document_id
         AND ad.ag_contract_header_id = ch.ag_contract_header_id
         AND ad.ag_doc_type_id = dt.ag_doc_type_id
            --204691
         AND ch.agent_id = c.contact_id
         AND ct.id = c.contact_type_id;
      --
    
      IF v_doc_type = 'NEW_AD'
      THEN
        SELECT COUNT(1)
          INTO v_is_exists
          FROM dual
         WHERE EXISTS (SELECT NULL
                  FROM cn_contact_ident ci
                      ,t_id_type        it
                 WHERE ci.contact_id = v_contact_id
                   AND ci.id_type = it.id
                   AND it.brief = 'PASS_RF'
                   AND ci.subdivision_code IS NOT NULL);
      
        IF v_is_exists = 0
           AND v_cont_type_brief = 'ФЛ' /*Чирков/204691 только у физ. лица должна быть проверка*/
        THEN
          g_message.state   := 'Err';
          g_message.message := 'Обратите внимание: необходимо заполнить код подразделения в паспортных данных';
        END IF;
      END IF;
    END IF;
  END check_subdiv_code;

  /*
    Байтин А.
    Заявка 191992
    Проверка наличия заполненного места выдачи в банковских реквизитах
    при переводе из "документ добавлен" в "проект"
  */
  PROCEDURE check_place_of_issue(par_ag_document_id NUMBER) IS
    v_contact_id NUMBER;
    v_is_exists  NUMBER(1);
    v_doc_type   ag_doc_type.brief%TYPE;
  BEGIN
    IF g_message.state = 'Ok'
    THEN
      SELECT ch.agent_id
            ,dt.brief
        INTO v_contact_id
            ,v_doc_type
        FROM ag_documents       ad
            ,ag_contract_header ch
            ,ag_doc_type        dt
       WHERE ad.ag_documents_id = par_ag_document_id
         AND ad.ag_contract_header_id = ch.ag_contract_header_id
         AND ad.ag_doc_type_id = dt.ag_doc_type_id;
    
      IF v_doc_type = 'NEW_AD'
      THEN
        SELECT COUNT(1)
          INTO v_is_exists
          FROM dual
         WHERE EXISTS (SELECT NULL
                  FROM cn_contact_bank_acc ba
                 WHERE ba.contact_id = v_contact_id
                   AND ba.place_of_issue IS NOT NULL);
      
        IF v_is_exists = 0
        THEN
          g_message.state   := 'Ask';
          g_message.message := 'Создать субагентский договор без типа документа "Офис доставки ХКБ"?';
        END IF;
      END IF;
    END IF;
  END check_place_of_issue;
  /*
  * Изместьев Д.И.  03.10.2012 №189228
  */
  FUNCTION check_agent_declaim_date
  (
    par_contact_id NUMBER
   ,par_date       DATE DEFAULT SYSDATE
  ) RETURN VARCHAR2 IS
    v_date        DATE;
    v_first_name  ins.contact.first_name%TYPE;
    v_middle_name ins.contact.middle_name%TYPE;
    v_snils       ins.cn_contact_ident.id_value%TYPE;
    v_birthdate   DATE;
    v_days        NUMBER;
  BEGIN
    --определение данных контакта.T_ID_TYPE
    BEGIN
      SELECT cn.first_name
            ,cn.middle_name
            ,(SELECT cci_in.id_value
                FROM ins.cn_contact_ident cci_in
               WHERE cci_in.contact_id = cn.contact_id
                 AND cci_in.id_type = 104) snils
            ,cp.date_of_birth
        INTO v_first_name
            ,v_middle_name
            ,v_snils
            ,v_birthdate
        FROM ins.contact   cn
            ,ins.cn_person cp
       WHERE cp.contact_id = cn.contact_id
         AND cn.contact_id = par_contact_id;
    EXCEPTION
      WHEN no_data_found THEN
        /*Для ЮЛ нет обработки, нет требований*/
        IF pkg_contact.get_is_individual(par_contact_id => par_contact_id) != 1
        THEN
          RETURN NULL;
        ELSE
          raise_application_error(-20001
                                 ,'Контакт не найден в системе! ' || SQLERRM);
        END IF;
      WHEN OTHERS THEN
        raise_application_error(-20001, 'Ошибка при выполнении ' || SQLERRM);
    END;
    --получение данных по договору. Если расторгнутых договоров не обнаружено, тогда возвращаем положительный результат
    BEGIN
      SELECT MAX(ad.doc_date)
        INTO v_date
        FROM ins.ven_ag_contract_header ach
            ,ins.ag_documents           ad
            ,ins.ag_doc_type            adt
            ,ins.document               dc
            ,ins.doc_status_ref         dsr
            ,ins.contact                cn
            ,ins.cn_person              cp
            ,ins.cn_contact_ident       cci
       WHERE ad.ag_contract_header_id = ach.ag_contract_header_id
         AND adt.ag_doc_type_id = ad.ag_doc_type_id
         AND dc.document_id = ach.ag_contract_header_id
         AND dsr.doc_status_ref_id = dc.doc_status_ref_id
         AND cp.contact_id = ach.agent_id
         AND cci.contact_id = ach.agent_id
         AND cn.contact_id = ach.agent_id
         AND adt.description = 'Расторжение АД'
         AND dsr.name = 'Расторгнут' -- ORDER BY 1
         AND cci.id_type = 104 --СНИЛС
         AND cn.first_name = v_first_name
         AND cn.middle_name = v_middle_name
         AND cp.date_of_birth = v_birthdate
         AND cci.id_value = v_snils;
      v_days := to_number(trunc(par_date) - trunc(v_date));
    EXCEPTION
      WHEN no_data_found THEN
        RETURN NULL;
    END;
  
    IF v_days IS NOT NULL
    THEN
      IF v_days <= 30
      THEN
        RETURN 'Warn';
      END IF;
    END IF;
    RETURN NULL;
  END check_agent_declaim_date;

  PROCEDURE check_agent_accept_30_day(p_ag_documents_id PLS_INTEGER) IS
    proc_name    VARCHAR2(25) := 'Check_agent_accept_30_day';
    v_doc_date   DATE;
    v_contact_id ins.ag_contract_header.agent_id%TYPE;
    v_state      VARCHAR2(10);
  
  BEGIN
    --по ag_doc_id определить тип документа и если это Заключение Ад
    --то берем 2 параметра. Agent_id, doc_date и
    --соотвественно через проверку прав и проверку 30 дней либо warn, либо err
    BEGIN
      SELECT ad.doc_date
            ,ach.agent_id
        INTO v_doc_date
            ,v_contact_id
        FROM ins.ag_documents       ad
            ,ins.ag_doc_type        adt
            ,ins.ag_contract_header ach
       WHERE ad.ag_documents_id = p_ag_documents_id
         AND adt.ag_doc_type_id = ad.ag_doc_type_id
         AND adt.description = 'Заключение АД'
         AND ach.ag_contract_header_id = ad.ag_contract_header_id;
    EXCEPTION
      WHEN no_data_found THEN
        RETURN;
    END;
  
    v_state := check_agent_declaim_date(v_contact_id, v_doc_date);
    --Проверка на право выполнить подтверждение АД
    IF safety.check_right_custom('check_30_days_AD') != 1
    THEN
      --PKG.Show_Message( 'Ошибка', 'У вас нет прав на создание САД', 'ALERT_MESS' );
      g_message.state   := 'Err';
      g_message.message := 'У вас нет прав на подтверждение документа Заключение АД!';
      RETURN;
    ELSE
      IF v_state = 'Warn'
      THEN
        g_message.state   := 'Warn';
        g_message.message := 'Обратите Внимание субагентский договор заведен ранее 30 дней от даты расторжения предыдущего.';
        RETURN;
      ELSE
        g_message.state   := 'Ok';
        g_message.message := 'Нормальное завершение процедуры';
        RETURN;
      END IF;
    END IF;
  
  EXCEPTION
    WHEN no_data_found THEN
      NULL;
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM);
  END check_agent_accept_30_day;

  -- Байтин А.
  -- Заявка №202347
  -- Процедура проверяет право на перевод документа "Заключение АД" в Проект,
  -- если он был подтвержден ранее
  PROCEDURE check_right_to_project(par_doc_id NUMBER) IS
    v_exists NUMBER(1);
  BEGIN
    -- Если нет права, проверяем тип документа и был ли он подтвержден
    IF safety.check_right_custom('CONFIRMED_DOCS_TO_PROJECT') != 1
    THEN
      SELECT COUNT(1)
        INTO v_exists
        FROM dual
       WHERE EXISTS (SELECT NULL
                FROM ag_documents   ad
                    ,ag_doc_type    dt
                    ,doc_status     ds
                    ,doc_status_ref dsr
               WHERE ad.ag_documents_id = par_doc_id
                 AND ad.ag_doc_type_id = dt.ag_doc_type_id
                 AND dt.brief = 'NEW_AD'
                 AND ad.ag_documents_id = ds.document_id
                 AND ds.doc_status_ref_id = dsr.doc_status_ref_id
                 AND dsr.brief = 'CONFIRMED');
      IF v_exists = 1
      THEN
        raise_application_error(-20001
                               ,'Право на перевод в Проект есть только у роли "Главный специалист по работе с агентской сетью".');
      END IF;
    END IF;
  END check_right_to_project;

  /* Байтин А.
     Заявка №210001
     Процедура выполняет следующие проверки:
     4. В случае, если у руководителя, который указан в карточке продающего подразделения изменяется категория
        с Менеджера/Директора на Субагента необходимо сделать проверку при подтверждении в САД типа документа
        <Изменение категории> на субагент.
        При данном изменении необходимо, чтобы выходило диалоговое окно: <Обращаем Ваше внимание, что.....является руководителем.....>.
        Не давать возможность подтверждения типа документа <Изменение категории> с Менеджера/Директора на Субагент
        без внесения соответствующих изменений в карточку продающего подразделения.
  
    5. В случае, если акцептуется САД категории Директор в агентстве, где руководителем в карточке
       продающего подразделения является Территориальный Директор, Зам. руководителя DSF, Руководитель DSF
       просьба при Подтверждении типа документа <Изменение категории> на Директор выводить диалоговое окно
       <Обратите внимание! В карточке продающего подразделения руководителем агентства.......
        Является территориальный директор.......>.
       В данном диалоговом окне типа документа <Изменение категории> добавить две кнопки <Продолжить> и <Отмена>.
       В случае нажатия на кнопку <Продолжить> тип документа <Изменение категории> будет подтверждаться,
       а в случае отмены оставаться в статусе Проект.
  */
  PROCEDURE check_sales_dept_manager(par_doc_id NUMBER) IS
    v_new_cat_id         NUMBER;
    v_new_cat_brief      ag_category_agent.brief%TYPE;
    v_org_tree_id        NUMBER;
    v_contract_header_id NUMBER;
    v_unicode            VARCHAR2(5);
    v_manager            contact.obj_name_orig%TYPE;
  BEGIN
    SELECT to_number(pc.new_value)
          ,dp.org_tree_id
          ,ad.ag_contract_header_id
      INTO v_new_cat_id
          ,v_org_tree_id
          ,v_contract_header_id
      FROM ag_documents    ad
          ,ag_doc_type     dt
          ,ag_props_change pc
          ,ag_props_type   pt
          ,ag_contract     cn
          ,department      dp
     WHERE ad.ag_documents_id = par_doc_id
       AND ad.ag_doc_type_id = dt.ag_doc_type_id
       AND dt.brief = 'CAT_CHG'
       AND ad.ag_documents_id = pc.ag_documents_id
       AND pc.ag_props_type_id = pt.ag_props_type_id
       AND pt.brief = 'CAT_PROP'
       AND ad.ag_contract_header_id = cn.contract_id
       AND ad.doc_date BETWEEN cn.date_begin AND cn.date_end
       AND cn.agency_id = dp.department_id;
    BEGIN
      SELECT ca.brief
        INTO v_new_cat_brief
        FROM ag_category_agent ca
       WHERE ca.ag_category_agent_id = v_new_cat_id;
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20001
                               ,'Не найдена категория с ID:"' || v_new_cat_id || '"');
    END;
    -- п.4.
    IF v_new_cat_brief = 'AG'
    THEN
      IF g_message.state != 'Err'
      THEN
        -- Ищем этого руководителя в продающем подразделении
        BEGIN
          SELECT to_char(sh.universal_code, 'FM0009')
            INTO v_unicode
            FROM sales_dept        sd
                ,sales_dept_header sh
           WHERE sd.manager_id = v_contract_header_id
             AND sd.close_date = to_date('31.12.3000', 'dd.mm.yyyy')
             AND sd.sales_dept_id = sh.last_sales_dept_id
                -- На случай, если руководит несколькими подразделениями
             AND rownum <= 1;
          g_message.state   := 'Err';
          g_message.message := 'Обращаем Ваше внимание, что данный агент является руководителем подразделения с кодом "' ||
                               v_unicode || '"';
        EXCEPTION
          WHEN no_data_found THEN
            NULL;
        END;
      END IF;
      -- п.5.
    ELSIF v_new_cat_brief IN ('DR', 'DR2')
    THEN
      SELECT to_char(sh.universal_code, 'FM0009')
            ,co.obj_name_orig
        INTO v_unicode
            ,v_manager
        FROM sales_dept_header  sh
            ,sales_dept         sd
            ,ag_contract_header ch
            ,ag_contract        cn
            ,ag_category_agent  ca
            ,contact            co
       WHERE sd.manager_id = ch.ag_contract_header_id
         AND ch.last_ver_id = cn.ag_contract_id
         AND cn.category_id = ca.ag_category_agent_id
         AND ca.brief IN ('TD', 'ZD', 'RD')
         AND sd.sales_dept_id = sh.last_sales_dept_id
         AND sh.organisation_tree_id = v_org_tree_id
         AND ch.agent_id = co.contact_id;
      g_message.state   := 'Ask';
      g_message.message := 'Обратите внимание! В карточке продающего подразделения руководителем подразделения с кодом "' ||
                           v_unicode || '" является директор ' || v_manager;
    END IF;
  EXCEPTION
    WHEN no_data_found THEN
      -- Если не нашли запись, это значит, что не меняется категория. Поэтому ничего не делаем и выходим.
      NULL;
  END check_sales_dept_manager;

  /* Процедура проверяет расторгнутые по инициативе компании АД с агентом по дате рождения, Имени, Отчетсву, СНИЛС'у как у заводимого котакта par_contact_id
   * создана по заявке 189187 Доработка Расторжения и проверки при заведении нового
   ** @autor Чирков В.Ю.
   * @param par_contact_id - заводимый id котакта агента
  */

  PROCEDURE check_break_initiative_company(par_contact_id NUMBER) IS
    v_first_name    contact.first_name%TYPE;
    v_middle_name   contact.middle_name%TYPE;
    v_date_of_birth DATE;
    v_snils         cn_contact_ident.id_value%TYPE;
    v_ach_nums      VARCHAR2(500);
  
  BEGIN
  
    IF pkg_contact.get_is_individual(par_contact_id => par_contact_id) = 1
    THEN
      /* Проверка только для физлиц */
      SELECT c.first_name     AS first_name
            ,c.middle_name    AS middle_name
            ,cp.date_of_birth AS date_of_birth
        INTO v_first_name
            ,v_middle_name
            ,v_date_of_birth
        FROM contact   c
            ,cn_person cp
       WHERE cp.contact_id = c.contact_id
         AND c.contact_id = par_contact_id;
    
      FOR rec IN (SELECT ach.num
                    FROM ven_ag_contract_header ach
                        ,ven_ag_documents       agd
                        ,ag_doc_type            adt
                        ,ag_props_change        pc
                        ,ag_props_type          apt
                        ,contact                c
                        ,ven_cn_person          cp
                   WHERE agd.ag_contract_header_id = ach.ag_contract_header_id
                     AND agd.ag_doc_type_id = adt.ag_doc_type_id
                     AND pc.ag_documents_id = agd.ag_documents_id
                     AND apt.ag_props_type_id = pc.ag_props_type_id
                     AND ach.agent_id = c.contact_id
                     AND cp.contact_id = c.contact_id
                        --
                     AND adt.brief = 'BREAK_AD'
                     AND apt.brief = 'BREAK_REASON'
                     AND pc.new_value = '2' -- По инциативе Компании
                     AND pc.is_accepted = 1 -- подтвержден
                     AND upper(TRIM(c.first_name)) = upper(TRIM(v_first_name))
                     AND upper(TRIM(c.middle_name)) = upper(TRIM(v_middle_name))
                     AND cp.date_of_birth = v_date_of_birth
                     AND EXISTS (SELECT 1
                            FROM ven_cn_contact_ident cci_
                                ,ven_t_id_type        tit_
                          
                           WHERE c.contact_id = cci_.contact_id
                             AND tit_.id = cci_.id_type
                                --
                             AND tit_.brief = 'PENS'
                                --and cci_.is_used      = 1
                             AND cci_.id_value IN (SELECT cci_2.id_value
                                                     FROM ins.contact          c_2
                                                         ,ven_cn_contact_ident cci_2
                                                         ,ven_t_id_type        tit_2
                                                   
                                                    WHERE c_2.contact_id = cci_2.contact_id
                                                      AND tit_2.id = cci_2.id_type
                                                         --
                                                      AND tit_2.brief = 'PENS'
                                                         --and cci.is_used        = 1
                                                      AND c_2.contact_id = par_contact_id
                                                   
                                                   )))
      LOOP
        v_ach_nums := v_ach_nums || ', ' || rec.num;
      END LOOP;
    
      IF v_ach_nums IS NOT NULL
      THEN
        g_message.state   := 'Err';
        g_message.message := 'Обратите Внимание предыдущий Субагентский договор расторгнут по инициативе Компании! Номера: ' ||
                             v_ach_nums || ' Заведение данного САД НЕВОЗМОЖНО!';
      END IF;
    END IF;
  
  END check_break_initiative_company;

  --Заявка 216248
  --Изместьев 14.02.2013
  --Проверка типа документа "Согл. на обработку персональных данных" при переходе статусов
  PROCEDURE check_agr_pers_data(p_ag_documents_id NUMBER) IS
    v_ag_doc PLS_INTEGER;
  BEGIN
    BEGIN
      SELECT ad.ag_documents_id
        INTO v_ag_doc
        FROM ins.document     dc
            ,ins.ag_documents ad
            ,ins.ag_doc_type  adt
            ,ins.entity       en
       WHERE adt.ag_doc_type_id = ad.ag_doc_type_id
         AND dc.document_id = ad.ag_documents_id
         AND en.ent_id = dc.ent_id
         AND adt.brief = 'AGR_PERS_DATA' --Согл. на обработку персональных данных
         AND en.brief = 'AG_DOCUMENTS'
         AND dc.document_id = p_ag_documents_id;
    
      /*  EXCEPTION
      WHEN NO_DATA_FOUND THEN
         g_message.state := 'Err';
         g_message.message :='Ошибка при выполнении процедуры проверки типа документа "Согл. на обработку персональных данных" при переходе статусов';*/
    
    END;
  EXCEPTION
    WHEN no_data_found THEN
      raise_application_error(-20003
                             ,'Переход в данный статус разрешен только для типа документа - Согл. на обработку персональных данных');
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении процедуры проверки типа документа "Согл. на обработку персональных данных" при переходе статусов' ||
                              SQLERRM);
  END check_agr_pers_data;

  FUNCTION get_current_policy_agent(par_pol_header_id NUMBER) RETURN NUMBER IS
    v_result NUMBER;
  BEGIN
    SELECT MAX(ac.ag_contract_header_id) keep(dense_rank FIRST ORDER BY pad.p_policy_agent_doc_id DESC)
      INTO v_result
      FROM ag_contract_header ac
          ,p_policy_agent_doc pad
     WHERE pad.policy_header_id = par_pol_header_id
       AND pad.ag_contract_header_id = ac.ag_contract_header_id
          --AND SYSDATE BETWEEN pad.date_begin AND pad.date_end
       AND EXISTS (SELECT NULL
              FROM document       d1
                  ,doc_status_ref dsr
             WHERE d1.document_id = pad.p_policy_agent_doc_id
               AND d1.doc_status_ref_id = dsr.doc_status_ref_id
               AND dsr.brief = 'CURRENT');
    RETURN v_result;
    
    --Заявка 358946: Добавление новых полей в Журнал начислений.
    --Сделан поиск по MAX(p_policy_agent_doc_id) что бы не ломать ins_dwh.v_reserves_vs_profit
    --так как в договрах было по 2 действующих агента. (заявка 360104).
    
  /*EXCEPTION
    WHEN no_data_found THEN
      RETURN NULL;
    WHEN too_many_rows THEN
      raise_application_error(-20001
                             ,'На договоре несколько одновременно действующих агентов');*/
  END get_current_policy_agent;

  /*
    Байтин А.
  
    Возвращает действующего агента по договору
  */
  FUNCTION get_current_policy_agent_name(par_pol_header_id p_pol_header.policy_header_id%TYPE)
    RETURN contact.obj_name_orig%TYPE IS
    v_result contact.obj_name_orig%TYPE;
  BEGIN
    BEGIN
      SELECT co.obj_name_orig
        INTO v_result
        FROM contact            co
            ,ag_contract_header ch
       WHERE co.contact_id = ch.agent_id
         AND ch.ag_contract_header_id = pkg_agn_control.get_current_policy_agent(par_pol_header_id);
    
    EXCEPTION
      WHEN no_data_found THEN
        v_result := NULL;
    END;
    RETURN v_result;
  END get_current_policy_agent_name;

  /*
    Гаргонов Д.
  
    Возвращает номер действующего агента по договору
  */
  FUNCTION get_current_policy_agent_num(par_pol_header_id p_pol_header.policy_header_id%TYPE)
    RETURN document.num%TYPE IS
    v_result document.num%TYPE;
  BEGIN
    BEGIN
      SELECT ch.num
        INTO v_result
        FROM ven_ag_contract_header ch
       WHERE ch.ag_contract_header_id = pkg_agn_control.get_current_policy_agent(par_pol_header_id);
    
    EXCEPTION
      WHEN no_data_found THEN
        v_result := NULL;
    END;
    RETURN v_result;
  END get_current_policy_agent_num;

  /*
    Капля П.
    Получение числа листов переговоров по агенту на дату начала месяца, 
    соответствующего дате окончания ведомости
  */
  FUNCTION get_activity_meetings_count
  (
    par_ag_countract_header_id NUMBER
   ,par_vedom_end_date         DATE
  ) RETURN INTEGER IS
    v_count INTEGER;
  BEGIN
  
    SELECT nvl(SUM(t.activity_meetings_count), 0)
      INTO v_count
      FROM ag_activity_meet_journal t
     WHERE t.ag_contract_header_id IN
           (
            -- Выбираем самого агента
            SELECT ah.ag_contract_header_id
              FROM ag_contract_header ah
             WHERE ah.ag_contract_header_id = par_ag_countract_header_id
               AND ah.is_new = 1
               AND doc.get_doc_status_brief(ah.ag_contract_header_id, par_vedom_end_date) = 'CURRENT'
            UNION ALL
            -- Собираем всех его подчиненных
            SELECT at.ag_contract_header_id
              FROM ag_agent_tree at
             START WITH at.ag_parent_header_id = par_ag_countract_header_id
                    AND par_vedom_end_date BETWEEN at.date_begin AND at.date_end
                    AND (SELECT ah.is_new
                           FROM ag_contract_header ah
                          WHERE ah.ag_contract_header_id = at.ag_contract_header_id) = 1
                    AND doc.get_doc_status_brief(at.ag_contract_header_id, par_vedom_end_date) =
                        'CURRENT'
            CONNECT BY PRIOR at.ag_contract_header_id = at.ag_parent_header_id
                   AND par_vedom_end_date BETWEEN at.date_begin AND at.date_end
                   AND (SELECT ah.is_new
                          FROM ag_contract_header ah
                         WHERE ah.ag_contract_header_id = at.ag_contract_header_id) = 1
                   AND doc.get_doc_status_brief(at.ag_contract_header_id, par_vedom_end_date) =
                       'CURRENT')
       AND t.report_date = trunc(par_vedom_end_date, 'month');
  
    RETURN v_count;
  END get_activity_meetings_count;

  /*
    Капля П.
    12.08.2014
    Получение Листов переговоров по агентам на дату из системы "Навигатор"
  */
  PROCEDURE download_activity_meetings(par_date DATE) IS
    c_open_type_brief  CONSTANT VARCHAR2(250) := 'GET_ACTIVITY_MEETINGS';
    c_props_type_brief CONSTANT VARCHAR2(100) := 'URL';
    v_url       t_b2b_props_vals.props_value%TYPE;
    j_req       JSON := JSON;
    v_req_clob  CLOB;
    v_resp_clob CLOB;
    j_resp      JSON;
  
    FUNCTION generate_request(par_date DATE) RETURN JSON IS
      v_req_json JSON := JSON();
      v_data     JSON := JSON;
    BEGIN
      v_req_json.put('key', pkg_external_system.get_system_key_by_brief('BORLAS'));
      v_req_json.put('operation', 'agent_count_meeting');
    
      v_data.put('date', to_char(par_date, 'dd.mm.yyyy'));
      v_req_json.put('data', v_data.to_json_value);
    
      RETURN v_req_json;
    END generate_request;
  
    PROCEDURE store_activity_meetings
    (
      par_list JSON_LIST
     ,par_date DATE
    ) IS
      j_element   JSON;
      v_list      dml_ag_activity_meet_journal.typ_associative_array;
      v_agent_num VARCHAR2(250);
      PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
      DELETE FROM ag_activity_meet_journal t WHERE t.report_date = par_date;
    
      FOR i IN 1 .. par_list.count
      LOOP
        j_element := JSON(par_list.get(i));
        v_agent_num := j_element.get('agent_num').get_string;
        v_list(i).ag_contract_header_id := get_ag_contract_header_by_num(v_agent_num);
        v_list(i).report_date := par_date;
        v_list(i).activity_meetings_count := j_element.get('count').get_number;
      END LOOP;
    
      dml_ag_activity_meet_journal.insert_record_list(v_list);
      COMMIT;
    EXCEPTION
      WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
    END store_activity_meetings;
  BEGIN
    assert_deprecated(par_date IS NULL
          ,'Период для получения Листов переговоров должен быть указан');
    assert_deprecated(par_date != trunc(par_date, 'month')
          ,'Период для получения Листов переговоров должен быть первым днем месяца');
  
    v_url := pkg_borlas_b2b.get_b2b_props_val(par_oper_type_brief  => c_open_type_brief
                                             ,par_props_type_brief => c_props_type_brief);
  
    /*
      Формирование JSON'а
    */
    dbms_lob.createtemporary(v_req_clob, TRUE);
    dbms_lob.createtemporary(v_resp_clob, TRUE);
  
    -- Формируме JSON
    j_req := generate_request(par_date);
    j_req.to_clob(buf => v_req_clob);
  
    -- Запрашиваем данные
    v_resp_clob := pkg_communication.request(par_url    => v_url
                                            ,par_method => 'POST'
                                            ,par_send   => 'data=' || v_req_clob);
    j_resp      := JSON(v_resp_clob);
  
    -- Обрабатываем ответ
    IF j_resp.exist('status')
       AND j_resp.get('status').get_string = 'OK'
    THEN
      store_activity_meetings(JSON_LIST(j_resp.get('data')), par_date);
    ELSIF j_resp.exist('text')
    THEN
      ex.raise_custom(j_resp.get('text').get_string);
    ELSE
      ex.raise_custom('Передан невалидный JSON');
    END IF;
  
  END download_activity_meetings;

  /*
    Григорьев Ю.
    Корректировка даты завершения агентского соглашения как даты окончания договора  
  */

  PROCEDURE refresh_pol_agent_end_date(par_policy_agent_doc_id NUMBER) IS
    v_rec_p_policy_agent_doc dml_p_policy_agent_doc.tt_p_policy_agent_doc;
    v_end_date               DATE;
  BEGIN
    v_rec_p_policy_agent_doc := dml_p_policy_agent_doc.get_record(par_policy_agent_doc_id);
    v_end_date               := ins.pkg_policy.get_policy_end_date(v_rec_p_policy_agent_doc.policy_header_id);
    IF v_rec_p_policy_agent_doc.date_end != v_end_date
       OR v_rec_p_policy_agent_doc.date_end IS NULL
    THEN
      v_rec_p_policy_agent_doc.date_end := v_end_date;
      dml_p_policy_agent_doc.update_p_policy_agent_doc(par_record => v_rec_p_policy_agent_doc);
    END IF;
  END refresh_pol_agent_end_date;

BEGIN
  g_message.state   := 'Ok'; --'Warn' --'Err' -- 'Ask'
  g_message.message := 'Нормальное завершение процедуры';
END pkg_agn_control; 
/

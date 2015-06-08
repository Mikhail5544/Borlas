CREATE OR REPLACE PACKAGE PKG_JOURNAL_TECH_WORK_FMB IS

  -- Author  : VLADIMIR.CHIRKOV
  -- Created : 13.11.2012 11:18:52
  -- Purpose : Пакет для работы с формой JOURNAL_TECH_WORK

  /*
  * Присвоение полю «Дата начала» Работы значения, равного дате присвоения данного статуса
  * Срабатывает при переходе <PROJECT> -> <CURRENT>
  * @autor Чирков В. Ю.
  * @param par_doc_id - ID объекта JOURNAL_TECH_WORK
  */
  PROCEDURE set_start_date(par_doc_id NUMBER);

  /*
  * Удаление значения поля «Дата начала» Работы
  * Срабатывает при переходе <CURRENT> -> <CANCEL>
  * @autor Чирков В. Ю.
  * @param par_doc_id - ID объекта JOURNAL_TECH_WORK
  */
  PROCEDURE del_start_date(par_doc_id NUMBER);

  /*
  * Присвоение полю «Дата начала» Работы значения, равного дате присвоения статуса ДЕЙСТВУЮЩИЙ
  * Удаление значения поля «Дата начала» Работы при присвоении статуса ОТМЕНЕН
  * Присвоение полю «Дата окончания» Работы значения, равного дате присвоения статуса ЗАВЕРШЁН
  * Срабатывает при переходе статуса JOURNAL_TECH_WORK
  * @autor Чирков В. Ю.
  * @param par_doc_id - ID объекта JOURNAL_TECH_WORK
  */
  PROCEDURE set_date(par_doc_id NUMBER);

  /*
  * Добавление в Журнал Тех Работ договора если при отмене догвора аннулированы ЗАПЛ 
  * /по заявке 261259: доработка_журнал технических работ/
  * Срабатывает при переходе версии ДС в <CANCEL>
  * @autor Чирков В. Ю.
  * @param par_policy - ID объекта версии ДС
  */
  PROCEDURE add_jtw_if_policy_cancel(par_policy NUMBER);
	
  /*
  * Процедура проверки наличия договора в журнале технических работ
  * Проверяет наличие записи с типом работ Рассмотрение в СБ, Рассмотрение в ЮУ
  * @author Капля П. С.
  * @param par_pol_header_id - ИД заголовка договора стархования
  */
	FUNCTION policy_in_tech_journal(par_pol_header_id p_pol_header.policy_header_id%TYPE) RETURN NUMBER;

END PKG_JOURNAL_TECH_WORK_FMB;
/
CREATE OR REPLACE PACKAGE BODY PKG_JOURNAL_TECH_WORK_FMB IS

  /*
  * Присвоение полю «Дата начала» Работы значения, равного дате присвоения статуса ДЕЙСТВУЮЩИЙ
  * Удаление значения поля «Дата начала» Работы при присвоении статуса ОТМЕНЕН
  * Присвоение полю «Дата окончания» Работы значения, равного дате присвоения статуса ЗАВЕРШЁН
  * Срабатывает при переходе статуса JOURNAL_TECH_WORK
  * @autor Чирков В. Ю.
  * @param par_doc_id - ID объекта JOURNAL_TECH_WORK
  */
  PROCEDURE set_date(par_doc_id NUMBER) IS
    v_brief doc_status_ref.brief%TYPE;
  BEGIN
    SELECT dsr.brief
      INTO v_brief
      FROM ven_journal_tech_work jtw
          ,ins.doc_status_ref    dsr
     WHERE dsr.doc_status_ref_id = jtw.doc_status_ref_id
       AND jtw.journal_tech_work_id = par_doc_id;
  
    --если последний статус ДЕЙСТВУЮЩИЙ
    --Присвоение полю «Дата начала» Работы значения, равного дате присвоения данного статуса
    IF v_brief = 'CURRENT'
    THEN
      UPDATE ven_journal_tech_work jtw
         SET jtw.start_date =
             (SELECT ds.start_date FROM ins.doc_status ds WHERE ds.doc_status_id = jtw.doc_status_id)
       WHERE jtw.journal_tech_work_id = par_doc_id;
    
      --если последний статус ОТМЕНЕН  
      --Удаление значения поля «Дата начала» Работы  
    ELSIF v_brief = 'CANCEL'
    THEN
      UPDATE journal_tech_work jtw
         SET jtw.start_date = NULL
       WHERE jtw.journal_tech_work_id = par_doc_id;
    
      --если последний статус ЗАВЕРШЕН        
      --Присвоение полю «Дата окончания» Работы значения, равного дате присвоения данного статуса  
    ELSIF v_brief = 'STOPED'
    THEN
      UPDATE ven_journal_tech_work jtw
         SET jtw.end_date =
             (SELECT ds.start_date FROM ins.doc_status ds WHERE ds.doc_status_id = jtw.doc_status_id)
       WHERE jtw.journal_tech_work_id = par_doc_id;
    END IF;
  
  END set_date;

  /*
  * Присвоение полю «Дата начала» Работы значения, равного дате присвоения данного статуса
  * Срабатывает при переходе <PROJECT> -> <CURRENT>
  * @autor Чирков В. Ю.
  * @param par_doc_id - ID объекта JOURNAL_TECH_WORK
  */
  PROCEDURE set_start_date(par_doc_id NUMBER) IS
  BEGIN
  
    UPDATE ven_journal_tech_work jtw
       SET jtw.start_date =
           (SELECT ds.start_date FROM ins.doc_status ds WHERE ds.doc_status_id = jtw.doc_status_id)
     WHERE jtw.journal_tech_work_id = par_doc_id;
  
  END set_start_date;

  /*
  * Удаление значения поля «Дата начала» Работы
  * Срабатывает при переходе <CURRENT> -> <CANCEL>
  * @autor Чирков В. Ю.
  * @param par_doc_id - ID объекта JOURNAL_TECH_WORK
  */
  PROCEDURE del_start_date(par_doc_id NUMBER) IS
  BEGIN
  
    UPDATE journal_tech_work jtw
       SET jtw.start_date = NULL
     WHERE jtw.journal_tech_work_id = par_doc_id;
  
  END del_start_date;

  /*
  * Добавление в Журнал Тех Работ договора если при отмене договора аннулированы ЗАПЛ 
  * /по заявке 261259: доработка_журнал технических работ/
  * Срабатывает при переходе версии ДС в <CANCEL>
  * @autor Чирков В. Ю.
  * @param par_policy - ID объекта версии ДС
  */
  PROCEDURE add_jtw_if_policy_cancel(par_policy NUMBER) IS
    v_cnt                  INT;
    v_journal_tech_work_id NUMBER;
  BEGIN
    SELECT COUNT(1)
      INTO v_cnt
      FROM dual
     WHERE EXISTS (SELECT 1
              FROM ins.p_pol_header    ph
                  ,ins.ven_p_policy    pp
                  ,ins.doc_status_ref  dsr_pp
                  ,ins.doc_status      ds_pp
                  ,ins.doc_doc         dd
                  ,ins.ven_ac_payment  ac
                  ,ins.doc_templ       dt
                  ,ins.doc_status_ref  dsr_ac
                  ,ins.doc_status      ds_ac
                  ,ins.ven_doc_set_off dso
                  ,ins.doc_status_ref  dsr_dso
                  ,ins.doc_status      ds_dso
             WHERE ph.last_ver_id = pp.policy_id -- берем последнюю версию
               AND pp.doc_status_ref_id = dsr_pp.doc_status_ref_id
               AND dsr_pp.brief = 'CANCEL' -- в статусе <Отменен>
               AND pp.doc_status_id = ds_pp.doc_status_id
                  
               AND pp.policy_id = dd.parent_id
               AND dd.child_id = ac.payment_id
               AND ac.doc_templ_id = dt.doc_templ_id
               AND dt.brief = 'PAYMENT' -- ищем ЭПГ                       
               AND ac.doc_status_ref_id = dsr_ac.doc_status_ref_id
               AND dsr_ac.brief = 'ANNULATED' -- в статусе Аннулирован                       
               AND ac.doc_status_id = ds_ac.doc_status_id
                  
               AND ac.payment_id = dso.parent_doc_id -- ЗАЧПЛ по ЭПГ
               AND dso.doc_status_ref_id = dsr_dso.doc_status_ref_id
               AND dsr_dso.brief = 'ANNULATED' -- в статусе Аннулирован
               AND dso.doc_status_id = ds_dso.doc_status_id
                  
                  --и дата статуса ДС в ОТМЕНЕН меньше дат статуса АННУЛИРОВАНИЯ ЭПГ И ЗАЧПЛ
               AND ds_pp.start_date < ds_ac.start_date
               AND ds_pp.start_date < ds_dso.start_date
                  -- и нет договора в журнале тех работ статусе ДЕЙСТВУЕТ
               AND NOT EXISTS (SELECT 1
                      FROM ins.ven_journal_tech_work jtw
                          ,ins.doc_status_ref        dsr
                     WHERE jtw.policy_header_id = pp.pol_header_id
                       AND jtw.doc_status_ref_id = dsr.doc_status_ref_id
                       AND dsr.brief = 'CURRENT')
               AND pp.policy_id = par_policy);
  
    IF v_cnt = 1
    THEN
      SELECT sq_journal_tech_work.nextval INTO v_journal_tech_work_id FROM dual;
    
      INSERT INTO ven_journal_tech_work
        (journal_tech_work_id
        ,policy_header_id
        ,work_type
        ,author_id
        ,t_subdivisions_id
        ,t_work_reason_id
        ,doc_templ_id)
        SELECT v_journal_tech_work_id
              ,pp.pol_header_id
              ,0 -- Технические работы
              ,(SELECT su.sys_user_id FROM sys_user su WHERE su.sys_user_name = USER)
              ,2 -- ОД
              ,102 --Отвязаны платежи
              ,(SELECT dt.doc_templ_id FROM doc_templ dt WHERE dt.brief = 'JOURNAL_TECH_WORK')
          FROM ins.p_policy pp
         WHERE pp.policy_id = par_policy;
    
      doc.set_doc_status(v_journal_tech_work_id, 'PROJECT');
    END IF;
  END add_jtw_if_policy_cancel;

  /*
  * Процедура проверки наличия договора в журнале технических работ
  * Проверяет наличие записи с типом работ Рассмотрение в СБ, Рассмотрение в ЮУ
  * @author Капля П. С.
  * @param par_pol_header_id - ИД заголовка договора стархования
  */
  FUNCTION policy_in_tech_journal(par_pol_header_id p_pol_header.policy_header_id%TYPE) RETURN NUMBER IS
    v_found NUMBER(1);
  BEGIN
    SELECT COUNT(1)
      INTO v_found
      FROM dual
     WHERE EXISTS (SELECT NULL
              FROM JOURNAL_TECH_WORK jtw
             WHERE jtw.policy_header_id = par_pol_header_id
               AND jtw.work_type IN (1, 2)); --Рассмотрение в СБ, Рассмотрение в ЮУ
    RETURN v_found;
  END policy_in_tech_journal;

BEGIN
  NULL;
END PKG_JOURNAL_TECH_WORK_FMB;
/

CREATE OR REPLACE PACKAGE pkg_personal_profile IS

  -- Author  : ARTUR.BAYTIN
  -- Created : 07.11.2012 11:19:54
  -- Purpose : Работа с личным кабинетом

  contact_exception  EXCEPTION;
  policy_exception   EXCEPTION;
  payment_exception  EXCEPTION;
  cover_exception    EXCEPTION;
  assured_exception  EXCEPTION;
  template_exception EXCEPTION;
  persdata_exception EXCEPTION;

  contact_exception_num  CONSTANT PLS_INTEGER := -20018;
  policy_exception_num   CONSTANT PLS_INTEGER := -20019;
  payment_exception_num  CONSTANT PLS_INTEGER := -20020;
  cover_exception_num    CONSTANT PLS_INTEGER := -20021;
  assured_exception_num  CONSTANT PLS_INTEGER := -20022;
  template_exception_num CONSTANT PLS_INTEGER := -20023;
  persdata_exception_num CONSTANT PLS_INTEGER := -20024;

  PRAGMA EXCEPTION_INIT(contact_exception, -20018);
  PRAGMA EXCEPTION_INIT(policy_exception, -20019);
  PRAGMA EXCEPTION_INIT(payment_exception, -20020);
  PRAGMA EXCEPTION_INIT(cover_exception, -20021);
  PRAGMA EXCEPTION_INIT(assured_exception, -20022);
  PRAGMA EXCEPTION_INIT(template_exception, -20023);
  PRAGMA EXCEPTION_INIT(persdata_exception, -20024);

  TYPE tr_contact_info IS RECORD(
     insured_id    contact.contact_id%TYPE
    ,insured_name  contact.obj_name_orig%TYPE
    ,email         cn_contact_email.email%TYPE
    ,date_of_birth DATE
    ,card          cn_contact_ident.id_value%TYPE);

  TYPE tr_policy_info IS RECORD(
     policy_id          NUMBER
    ,product_id         NUMBER
    ,product_name       t_product.description%TYPE
    ,product_brief      t_product.brief%TYPE
    ,pol_num            p_policy.pol_num%TYPE
    ,fee                p_cover.fee%TYPE
    ,date_begin         DATE
    ,date_active        DATE
    ,date_end           DATE
    ,policy_header_id   NUMBER
    ,payment_term       t_payment_terms.description%TYPE
    ,fund               ins.fund.brief%TYPE
    ,status             doc_status_ref.name%TYPE
    ,agent_id           NUMBER
    ,agency_id          NUMBER
    ,fee_index          p_cover.fee%TYPE
    ,fee_index_rur      p_cover.fee%TYPE
    ,debt_sum           NUMBER
    ,agent_name         contact.obj_name_orig%TYPE
    ,agency_name        department.name%TYPE
    ,agency_address     VARCHAR2(1)
    ,agency_phone       VARCHAR2(1)
    ,indexing_persent   NUMBER(1)
    ,invest_income      NUMBER(1)
    ,due_date           DATE
    ,decline_date       DATE
    ,decline_reason     t_decline_reason.name%TYPE
    ,last_ver_policy_id NUMBER
    ,last_ver_status    doc_status_ref.brief%TYPE
    ,active_ver_status  doc_status_ref.brief%TYPE
    ,fund_short         ins.fund.spell_short_whole%TYPE
    ,period_value       ins.t_period.period_value%TYPE
    ,is_priority_invest NUMBER(1));

  TYPE tr_payment_info IS RECORD(
     payment_id       NUMBER
    ,policy_id        NUMBER
    ,due_date         DATE
    ,grace_date       DATE
    ,epg_amount       NUMBER
    ,pay_date         DATE
    ,epg_amount_rur   NUMBER
    ,epg_status_brief doc_status_ref.brief%TYPE
    ,epg_status       doc_status_ref.name%TYPE
    ,index_fee        NUMBER
    ,adm_cost         NUMBER
    ,debt_sum         NUMBER
    ,pol_header_id    NUMBER
    ,payment_num      NUMBER);

  TYPE tr_assured_info IS RECORD(
     assured_name  contact.obj_name_orig%TYPE
    ,assured_birth cn_person.date_of_birth%TYPE
    ,as_asset_id   as_asset.as_asset_id%TYPE
    ,contact_id    as_assured.assured_contact_id%TYPE
    ,policy_id     p_policy.policy_id%TYPE);

  TYPE tr_cover_info IS RECORD(
     p_cover_id      NUMBER
    ,date_begin      DATE
    ,date_end        DATE
    ,insurance_sum   NUMBER
    ,fee             NUMBER
    ,cover_type_name t_product_line.description%TYPE
    ,cover_brief     t_product_line.brief%TYPE
    ,lob_line_brief  t_lob_line.brief%TYPE
    ,annual          NUMBER
    ,loan            NUMBER
    ,net_premium_act NUMBER
    ,delta_deposit1  NUMBER
    ,penalty         NUMBER
    ,payment_sign    NUMBER
    ,policy_id       NUMBER
    ,as_asset_id     as_asset.as_asset_id%TYPE);

  TYPE tr_acq_template_info IS RECORD(
     acq_payment_template_id acq_payment_template.acq_payment_template_id%TYPE
    ,num                     document.num%TYPE
    ,reg_date                document.reg_date%TYPE
    ,fee                     acq_payment_template.fee%TYPE
    ,act_period              acq_payment_template.till%TYPE
    ,status_brief            doc_status_ref.brief%TYPE
    ,status_name             doc_status_ref.name%TYPE
    ,end_date                DATE
    ,rejection_id            acq_payment_template.t_mpos_rejection_id%TYPE
    ,rejection_name          t_mpos_rejection.name%TYPE
    ,pol_header_id           p_pol_header.policy_header_id%TYPE
    ,pol_num                 p_policy.pol_num%TYPE);

  TYPE tr_persdata_info IS RECORD(
     contact_id     contact.contact_id%TYPE
    ,doc_type_brief t_id_type.brief%TYPE
    ,doc_type_name  t_id_type.description%TYPE
    ,doc_series     cn_contact_ident.serial_nr%TYPE
    ,doc_number     cn_contact_ident.id_value%TYPE
    ,doc_date       cn_contact_ident.issue_date%TYPE
    ,doc_place      cn_contact_ident.place_of_issue%TYPE
    ,address        cn_address.name%TYPE
    ,ipdl           contact.is_public_contact%TYPE
    ,rpdl           cn_person.is_in_list%TYPE
    ,notify         NUMBER(1)
    ,refresh_needed NUMBER(1));

  TYPE tt_policy_info IS TABLE OF tr_policy_info;
  TYPE tt_payment_info IS TABLE OF tr_payment_info;
  TYPE tt_assured_info IS TABLE OF tr_assured_info;
  TYPE tt_cover_info IS TABLE OF tr_cover_info;
  TYPE tt_acq_template_info IS TABLE OF tr_acq_template_info;
  TYPE tt_persdata_info IS TABLE OF tr_persdata_info;

  gv_contact_info      tr_contact_info;
  gv_policy_info       tt_policy_info;
  gv_payment_info      tt_payment_info;
  gv_assured_info      tt_assured_info;
  gv_cover_info        tt_cover_info;
  gv_acq_template_info tt_acq_template_info;
  gv_persdata_info     tt_persdata_info;

  /*
    Байтин А.
    Получение таблицы с данными по договорам страхования
  */
  FUNCTION get_policy_info RETURN tt_policy_info
    PIPELINED;

  /*
    Байтин А.
    Получение таблицы с данными по платежам
  */
  FUNCTION get_payment_info RETURN tt_payment_info
    PIPELINED;

  /*
    Байтин А.
    Получение таблицы с данными по застрахованным
  */
  FUNCTION get_assured_info RETURN tt_assured_info
    PIPELINED;

  /*
    Байтин А.
    Получение таблицы с данными по покрытиям
  */
  FUNCTION get_cover_info RETURN tt_cover_info
    PIPELINED;
  /*
    Байтин А.
    Получение таблицы с данными о шаблонах списания
  */
  FUNCTION get_acq_template_info RETURN tt_acq_template_info
    PIPELINED;

  /*
    Байтин А.
    Получение таблицы с персональными данными контактов
  */
  FUNCTION get_persdata_info RETURN tt_persdata_info
    PIPELINED;

  /*
    Байтин А.
    Подготовка данных по договору страхования
  */
  PROCEDURE prepare_policy_info
  (
    par_contact_id       NUMBER
   ,par_policy_header_id NUMBER DEFAULT NULL
  );

  /*
    Байтин А.
    Подготовка данных по шаблонам списания
  */
  PROCEDURE prepare_acq_template_info;
  /*
    Байтин А.
    Подготовка данных по платежам
  */
  PROCEDURE prepare_payment_info;

  /*
    Байтин А.
  
    Получение данных по застрахованным
  */
  PROCEDURE prepare_assured_info;

  /*
    Байтин А.
    Получение данных по покрытиям
  */
  PROCEDURE prepare_cover_info(par_is_demo_cabinet NUMBER DEFAULT 0);

  /*
    Подготовка данных из словарей
  */
  FUNCTION get_dict_info_json
  (
    par_policy_id NUMBER DEFAULT NULL
   ,par_only_cost BOOLEAN DEFAULT FALSE
  ) RETURN JSON;
  /*
    Байтин А.
    Формирование и вывод всех данных
  */
  PROCEDURE get_all_data
  (
    par_contact_id    NUMBER
   ,par_pol_header_id NUMBER DEFAULT NULL
   ,par_with_dicts    BOOLEAN DEFAULT FALSE
   ,par_demo_cabinet  BOOLEAN DEFAULT FALSE
   ,par_response      OUT JSON
  );

  PROCEDURE get_all_data
  (
    par_request  JSON
   ,par_response OUT JSON
  );
  PROCEDURE post_prepared_info
  (
    par_response   OUT JSON
   ,par_with_dicts BOOLEAN DEFAULT FALSE
  );

  /*
    Байтин А.
    Передача страхователей
  */
  PROCEDURE send_insured
  (
    par_contact_id  NUMBER DEFAULT NULL
   ,par_send_errors BOOLEAN DEFAULT FALSE
   ,par_sent_quant  OUT NUMBER
   ,par_error       OUT VARCHAR2
  );

  /*
    Байтин А.
    Передача в B2B данных по изменениям стратегии по продукту Инвестор
  */
  PROCEDURE get_cabinet_cover
  (
    par_request  JSON
   ,par_response OUT JSON
  );

  /*
    Байтин А.
    Проверка пароля
  */
  PROCEDURE check_password
  (
    par_request  JSON
   ,par_response OUT JSON
  );

  PROCEDURE reset_password
  (
    par_contact_id   NUMBER
   ,par_is_from_http BOOLEAN DEFAULT TRUE
  );

  PROCEDURE reset_password
  (
    par_request  JSON
   ,par_response OUT JSON
  );

  /*
    Байтин А.
    Добавление/изменение электронной почты и/или пароля
  */
  PROCEDURE set_email_and_pass
  (
    par_request  JSON
   ,par_response OUT JSON
  );

  /*
    Байтин А.
    Создание ДС для демо-кабинета
  */
  PROCEDURE calc_demo_policy
  (
    par_request  JSON
   ,par_response OUT JSON
  );

  /*
    Подтверждение флагов ИПДЛ/РПДЛ
  */
  PROCEDURE confirm_public_flags
  (
    par_request  JSON
   ,par_response OUT JSON
  );

  /*
    Подтверждение ФИО
  */
  PROCEDURE confirm_names
  (
    par_request  JSON
   ,par_response OUT JSON
  );

  /*
    Подтверждение идентифицирующих документов
  */
  PROCEDURE confirm_documents
  (
    par_request  JSON
   ,par_response OUT JSON
  );

  /*
    Подтверждение адреса
  */
  PROCEDURE confirm_address
  (
    par_request  JSON
   ,par_response OUT JSON
  );

  /*
    Подтверждение актуальности
  */
  PROCEDURE confirm_actuality
  (
    par_request  JSON
   ,par_response OUT JSON
  );

  /*
    Для первой версии договора страхования поле «Дата последнего обновления» Контакта
    страхователя и застрахованного принимает значение текущей даты при
    следующих переходах статусов:
      из статуса «Проект» в статус «Новый»;
      из статуса «Проект» в статус «Передано агенту»;
      из статуса «Ожидает оплаты» в статус «Передано агенту»
      из статуса «Ожидает подтверждение из B2B»  в статус «Передано агенту»
  */
  PROCEDURE actualize_last_update_date(par_policy_id p_policy.policy_id%TYPE);

  /*
    Пиядин А.
    329219 Обновление информации о БСО на сайте компании
  */
  PROCEDURE bso_check
  (
    par_request  IN JSON
   ,par_response OUT JSON
  );

END pkg_personal_profile;
/
CREATE OR REPLACE PACKAGE BODY pkg_personal_profile IS

  gc_auth_key CONSTANT VARCHAR2(2000) := '1d925437c358624fc7ffd1457734810f8742ecde';
  gv_wallet_path VARCHAR2(2000);
  gc_pkg_name         CONSTANT VARCHAR2(30) := 'PKG_PERSONAL_PROFILE';
  gc_status_elem_name CONSTANT VARCHAR2(10) := 'status';
  gc_error_elem_name  CONSTANT VARCHAR2(10) := 'error_text';

  /*
    Байтин А.
    Получение таблицы с данными по договорам страхования
  */
  FUNCTION get_policy_info RETURN tt_policy_info
    PIPELINED IS
  BEGIN
    IF gv_policy_info IS NOT NULL
       AND gv_policy_info.count > 0
    THEN
      FOR v_idx IN gv_policy_info.first .. gv_policy_info.last
      LOOP
        PIPE ROW(gv_policy_info(v_idx));
      END LOOP;
    END IF;
    RETURN;
  END get_policy_info;

  /*
    Байтин А.
    Получение таблицы с данными по платежам
  */
  FUNCTION get_payment_info RETURN tt_payment_info
    PIPELINED IS
  BEGIN
    IF gv_payment_info IS NOT NULL
       AND gv_payment_info.count > 0
    THEN
      FOR v_idx IN gv_payment_info.first .. gv_payment_info.last
      LOOP
        PIPE ROW(gv_payment_info(v_idx));
      END LOOP;
    END IF;
    RETURN;
  END get_payment_info;

  /*
    Байтин А.
    Получение таблицы с данными по застрахованным
  */
  FUNCTION get_assured_info RETURN tt_assured_info
    PIPELINED IS
  BEGIN
    IF gv_assured_info IS NOT NULL
       AND gv_assured_info.count > 0
    THEN
      FOR v_idx IN gv_assured_info.first .. gv_assured_info.last
      LOOP
        PIPE ROW(gv_assured_info(v_idx));
      END LOOP;
    END IF;
    RETURN;
  END get_assured_info;

  /*
    Байтин А.
    Получение таблицы с данными по покрытиям
  */
  FUNCTION get_cover_info RETURN tt_cover_info
    PIPELINED IS
  BEGIN
    IF gv_cover_info IS NOT NULL
       AND gv_cover_info.count > 0
    THEN
      FOR v_idx IN gv_cover_info.first .. gv_cover_info.last
      LOOP
        PIPE ROW(gv_cover_info(v_idx));
      END LOOP;
    END IF;
    RETURN;
  END get_cover_info;

  /*
    Байтин А.
    Получение таблицы с персональными данными контактов
  */
  FUNCTION get_persdata_info RETURN tt_persdata_info
    PIPELINED IS
  BEGIN
    IF gv_persdata_info IS NOT NULL
       AND gv_persdata_info.count > 0
    THEN
      FOR v_idx IN gv_persdata_info.first .. gv_persdata_info.last
      LOOP
        PIPE ROW(gv_persdata_info(v_idx));
      END LOOP;
    END IF;
    RETURN;
  END get_persdata_info;

  /*
    Байтин А.
    Получение таблицы с данными о шаблонах списания
  */
  FUNCTION get_acq_template_info RETURN tt_acq_template_info
    PIPELINED IS
  BEGIN
    IF gv_acq_template_info IS NOT NULL
       AND gv_acq_template_info.count > 0
    THEN
      FOR v_idx IN gv_acq_template_info.first .. gv_acq_template_info.last
      LOOP
        PIPE ROW(gv_acq_template_info(v_idx));
      END LOOP;
    END IF;
    RETURN;
  END get_acq_template_info;

  /*
    Байтин А.
    Получение данных по страхователю
  */
  PROCEDURE prepare_contact_info(par_contact_id NUMBER) IS
    v_err_code VARCHAR2(30);
  BEGIN
    SELECT c.contact_id    AS insured_id
          ,c.obj_name      AS insured_name
          ,cntel.email     AS email
          ,p.date_of_birth
          ,vip.card
      INTO gv_contact_info
      FROM ins.contact c
          ,ins.cn_person p
          ,(SELECT cnt1.contact_id
                  ,cnt1.rn
                  ,cnt1.email
              FROM (SELECT ce.contact_id
                          ,row_number() over(PARTITION BY ce.contact_id ORDER BY decode(et.description, 'Адрес ЛК', 0, 'Адрес рассылки', 10, 'Личный', 20, 'Рабочий', 30, 100)) rn
                          ,ce.email
                      FROM ins.cn_contact_email ce
                          ,ins.t_email_type     et
                     WHERE ce.email_type = et.id
                       AND ce.contact_id = par_contact_id) cnt1
             WHERE cnt1.rn = 1) cntel
          ,(SELECT vip.card
                  ,vip.contact_id
              FROM (SELECT i.contact_id
                          ,row_number() over(PARTITION BY i.contact_id ORDER BY i.id_value) rn
                          ,i.id_value AS card
                      FROM ins.cn_contact_ident i
                          ,ins.t_id_type        it
                     WHERE i.id_type = it.id
                       AND it.brief = 'VIPCard'
                       AND i.contact_id = par_contact_id) vip
             WHERE vip.rn = 1) vip
     WHERE c.contact_id = par_contact_id
       AND c.contact_id = cntel.contact_id(+)
       AND c.contact_id = p.contact_id
       AND c.contact_id = vip.contact_id(+);
  EXCEPTION
    WHEN no_data_found THEN
      raise_application_error(contact_exception_num
                             ,'Не найдены данные контакта!');
    WHEN OTHERS THEN
      v_err_code := SQLCODE;
      raise_application_error(contact_exception_num, v_err_code);
  END prepare_contact_info;

  /*
    Байтин А.
    Получение данных по договору страхования
  */
  PROCEDURE prepare_policy_info
  (
    par_contact_id       NUMBER
   ,par_policy_header_id NUMBER DEFAULT NULL
  ) IS
    v_err_code VARCHAR2(30);
  BEGIN
    SELECT policy.policy_id
          ,policy.product_id
          ,policy.product_name
          ,policy.product_brief
          ,nvl(to_char(policy.ids), policy.pol_num) AS pol_num
          ,policy.fee
          ,policy.date_begin AS date_begin
          ,policy.date_active
          ,policy.date_end AS date_end
          ,policy.policy_header_id AS policy_header_id
          ,policy.payment_term AS payment_term
          ,policy.fund
          ,policy.status AS status
          ,policy.agent_id AS agent_id
          ,policy.agency_id AS agency_id
          ,policy.fee_index
          ,acc_new.get_rate_by_brief('ЦБ', policy.fund, SYSDATE) * policy.fee_index AS index_fee_rur
          ,CASE
             WHEN decline_date IS NULL
                  AND policy.debt_sum != 0 THEN
              policy.debt_sum
           END AS debt_sum
          ,cn.obj_name AS agent_name
          ,d.name AS agency_name
          ,to_char(NULL) AS agency_address
          ,to_char(NULL) AS agency_phone
          ,to_number(NULL) AS indexing_persent
          ,to_number(NULL) AS invest_income
          ,CASE
             WHEN decline_date IS NULL THEN
              due_date
           END AS due_date
          ,decline_date AS decline_date
          ,decline_reason AS decline_reason
          ,last_ver_policy_id
          ,last_ver_status
          ,active_ver_status
          ,policy.fund_short
          ,policy.period_value
          ,policy.is_priority_invest
      BULK COLLECT
      INTO gv_policy_info
      FROM (SELECT pol.policy_id
                  ,pol.insured_id
                  ,pol.product_id
                  ,pol.product_name
                  ,pol.product_brief
                  ,CASE
                     WHEN pol.product_brief IN ('Priority_Invest(regular)', 'Priority_Invest(lump)')
                          AND EXISTS (SELECT NULL
                             FROM p_policy            pp
                                 ,p_pol_addendum_type ta
                                 ,t_addendum_type     tt
                            WHERE pp.pol_header_id = pol.policy_header_id
                              AND pp.policy_id = ta.p_policy_id
                              AND ta.t_addendum_type_id = tt.t_addendum_type_id
                              AND tt.brief = 'CHANGE_STRATEGY_QUARTER') THEN
                      1
                     ELSE
                      0
                   END AS is_priority_invest
                  ,pol.ids
                  ,pol.pol_num
                  ,pol.date_begin
                  ,pol.date_active
                  ,pol.date_end
                  ,pol.policy_header_id
                  ,pol.payment_term
                  ,pol.fund
                  ,pol.fund_short
                  , --Гаргонов Д.А. -- Заявка 280396
                   (SELECT sll.lk_status
                      FROM status_list_lk sll
                     WHERE pol.active_ver_status_id = sll.active_ver_status_id
                       AND pol.last_ver_status_id = sll.last_ver_status_id) AS status
                  ,(SELECT (SELECT agent_id
                              FROM ins.ag_contract_header ach
                             WHERE ach.ag_contract_header_id = ac.contract_id) agent_id
                    
                      FROM ins.ag_contract ac
                     WHERE ac.category_id = 2
                       AND rownum = 1
                     START WITH ac.ag_contract_id =
                                ins.pkg_agent_1.get_status_by_date(ins.pkg_renlife_utils.get_p_agent_current(pol.policy_header_id
                                                                                                            ,least(pol.date_end
                                                                                                                  ,SYSDATE)
                                                                                                            ,1)
                                                                  ,least(pol.date_end, SYSDATE))
                    CONNECT BY nocycle PRIOR (SELECT ac1.contract_id
                                        FROM ins.ag_contract ac1
                                       WHERE ac1.ag_contract_id = ac.contract_leader_id) =
                                ac.contract_id
                           AND ac.ag_contract_id =
                               ins.pkg_agent_1.get_status_by_date(ac.contract_id
                                                                 ,least(pol.date_end, SYSDATE))
                           AND ac.category_id <= 2) agent_id
                  ,
                   
                   (SELECT ac.agency_id
                      FROM ins.ag_contract ac
                     WHERE ac.category_id = 2
                       AND rownum = 1
                     START WITH ac.ag_contract_id =
                                ins.pkg_agent_1.get_status_by_date(ins.pkg_renlife_utils.get_p_agent_current(pol.policy_header_id
                                                                                                            ,least(pol.date_end
                                                                                                                  ,SYSDATE)
                                                                                                            ,1)
                                                                  ,least(pol.date_end, SYSDATE))
                    CONNECT BY nocycle PRIOR (SELECT ac1.contract_id
                                        FROM ins.ag_contract ac1
                                       WHERE ac1.ag_contract_id = ac.contract_leader_id) =
                                ac.contract_id
                           AND ac.ag_contract_id =
                               ins.pkg_agent_1.get_status_by_date(ac.contract_id
                                                                 ,least(pol.date_end, SYSDATE))
                           AND ac.category_id <= 2) agency_id
                  ,
                   
                   CASE pol.last_ver_status
                     WHEN 'INDEXATING' THEN
                      (SELECT ROUND(SUM(pc.fee), 2)
                         FROM ins.p_cover  pc
                             ,ins.as_asset a
                             ,ins.p_policy pp
                        WHERE pp.policy_id = a.p_policy_id
                          AND a.as_asset_id = pc.as_asset_id
                          AND pp.policy_id = pol.last_ver_policy_id)
                   END fee_index
                  ,(SELECT ROUND(SUM(pc.fee), 2)
                      FROM ins.p_cover  pc
                          ,ins.as_asset a
                          ,ins.p_policy pp
                     WHERE pp.policy_id = a.p_policy_id
                       AND a.as_asset_id = pc.as_asset_id
                       AND pp.policy_id = pol.policy_id) AS fee
                  ,(SELECT nvl(SUM(ac.amount - nvl(ins.pkg_payment.get_set_off_amount(ac.payment_id
                                                                                     ,pol.policy_header_id
                                                                                     ,NULL)
                                                  ,0))
                              ,0)
                      FROM ins.ac_payment     ac
                          ,ins.doc_doc        dd
                          ,ins.p_policy       pp
                          ,ins.document       dc
                          ,ins.doc_status_ref dsr
                          ,ins.doc_templ      dt
                     WHERE pp.pol_header_id = pol.policy_header_id
                       AND pp.policy_id = dd.parent_id
                       AND dd.child_id = ac.payment_id
                       AND ac.payment_id = dc.document_id
                       AND dc.doc_templ_id = dt.doc_templ_id
                       AND dc.doc_status_ref_id = dsr.doc_status_ref_id
                       AND dt.brief = 'PAYMENT'
                       AND ac.plan_date >= to_date('01.01.2010', 'dd.mm.yyyy')
                       AND ac.plan_date <= nvl((SELECT MAX(ppd.decline_date)
                                                 FROM ins.p_policy      ppd
                                                     ,ins.p_pol_decline pdd -- Только для обхода ошибки, связанной с копированием decline_reason_id в последующие версии
                                                WHERE ppd.pol_header_id = pol.policy_header_id
                                                  AND ppd.policy_id = pdd.p_policy_id)
                                              ,ac.plan_date)
                       AND dsr.brief IN ('TO_PAY', 'PAID')) AS debt_sum
                  ,(SELECT nvl(MIN(CASE
                                     WHEN dsr.brief = 'TO_PAY' THEN
                                      ap.plan_date
                                   END)
                              ,MIN(CASE
                                     WHEN dsr.brief = 'NEW' THEN
                                      ap.plan_date
                                   END))
                      FROM ins.p_policy       po
                          ,ins.doc_doc        dd
                          ,ins.ac_payment     ap
                          ,ins.document       dc
                          ,ins.doc_status_ref dsr
                          ,ins.doc_templ      dt
                     WHERE po.pol_header_id = pol.policy_header_id
                       AND po.policy_id = dd.parent_id
                       AND dd.child_id = ap.payment_id
                       AND ap.payment_id = dc.document_id
                       AND dc.doc_templ_id = dt.doc_templ_id
                       AND dc.doc_status_ref_id = dsr.doc_status_ref_id
                       AND dt.brief = 'PAYMENT'
                       AND dsr.brief IN ('TO_PAY', 'NEW')) AS due_date
                  ,nvl(pol.last_ver_decline_date, pol.decline_date) AS decline_date
                  ,nvl(pol.last_ver_decline_reason, pol.decline_reason) AS decline_reason
                  ,pol.last_ver_policy_id
                  ,pol.last_ver_status
                  ,pol.active_ver_status
                  ,pol.period_value
              FROM (SELECT pp.policy_id
                          ,par_contact_id AS insured_id
                          ,p.product_id
                          ,p.description product_name
                          ,p.brief product_brief
                          ,ph.ids
                          ,pp.pol_num
                          ,ph.start_date date_begin
                          ,pp.start_date AS date_active
                          ,pp.end_date date_end
                          ,tp.period_value
                          ,ph.policy_header_id
                          ,pt.description payment_term
                          ,f.brief fund
                          ,f.spell_short_whole fund_short
                          ,CASE
                             WHEN pp.decline_reason_id IS NOT NULL
                                  AND pd.p_policy_id IS NOT NULL THEN
                              pp.decline_date
                           END AS decline_date
                          ,CASE
                             WHEN pd.p_policy_id IS NOT NULL THEN
                              dr.name
                           END AS decline_reason
                          ,dsr.brief AS active_ver_status
                          ,dsr.doc_status_ref_id AS active_ver_status_id
                           -- Последняя версия
                          ,pp_l.policy_id AS last_ver_policy_id
                          ,pp_l.start_date AS last_ver_start_date
                          ,pp_l.version_num AS last_ver_version_num
                          ,CASE
                             WHEN pp_l.decline_reason_id IS NOT NULL
                                  AND pd_l.p_policy_id IS NOT NULL THEN
                              pp_l.decline_date
                           END AS last_ver_decline_date
                          ,CASE
                             WHEN pd_l.p_policy_id IS NOT NULL THEN
                              dr_l.name
                           END AS last_ver_decline_reason
                          ,dsr_l.brief AS last_ver_status
                          ,dsr_l.doc_status_ref_id AS last_ver_status_id
                      FROM ins.p_policy pp
                          ,ins.p_pol_decline pd -- Только для обхода ошибки, связанной с копированием decline_reason_id в последующие версии
                          ,(SELECT pc.policy_id
                              FROM ins.p_policy_contact pc
                                  ,ins.contact          co
                             WHERE pc.contact_id = par_contact_id
                               AND pc.contact_policy_role_id = 6
                               AND pc.contact_id = co.contact_id
                               AND co.contact_type_id IN (1, 3)
                            UNION ALL
                            SELECT se.p_policy_id
                              FROM p_pol_header     ph
                                  ,p_policy         pp
                                  ,as_asset         se
                                  ,as_assured       su
                                  ,p_policy_contact pc
                                  ,contact          co
                                  ,t_product        prd
                             WHERE ph.last_ver_id = pp.policy_id
                               AND pp.pol_num IS NOT NULL
                               AND su.assured_contact_id = par_contact_id
                               AND pp.is_group_flag = 0
                               AND pp.policy_id = se.p_policy_id
                               AND se.as_asset_id = su.as_assured_id
                               AND pp.policy_id = pc.policy_id
                               AND pc.contact_policy_role_id = 6
                               AND pc.contact_id = co.contact_id
                               AND co.contact_type_id NOT IN (1, 3)
                               AND ph.product_id = prd.product_id
                               AND prd.brief NOT IN
                                   ('CR92_1', 'CR92_1.1', 'CR92_2', 'CR92_2.1', 'CR92_3', 'CR92_3.1')) pc
                          ,ins.t_product p
                          ,ins.p_pol_header ph
                          ,ins.fund f
                          ,ins.t_payment_terms pt
                          ,ins.t_decline_reason dr
                          ,ins.document dc
                          ,ins.doc_status_ref dsr
                          ,ins.t_period tp
                           -- Последняя версия
                          ,ins.p_policy         pp_l
                          ,ins.p_pol_decline    pd_l -- Только для обхода ошибки, связанной с копированием decline_reason_id в последующие версии
                          ,ins.document         dc_l
                          ,ins.doc_status_ref   dsr_l
                          ,ins.t_decline_reason dr_l
                     WHERE pp.policy_id = pc.policy_id
                       AND ph.policy_id = pp.policy_id
                       AND p.product_id = ph.product_id
                       AND (par_policy_header_id IS NULL OR ph.policy_header_id = par_policy_header_id)
                       AND f.fund_id = ph.fund_id
                       AND pt.id = pp.payment_term_id
                          -- Срок страхования
                       AND pp.period_id = tp.id
                          -- номер не должен быть пустым
                       AND pp.pol_num IS NOT NULL
                       AND pp.decline_reason_id = dr.t_decline_reason_id(+)
                       AND pp.policy_id = pd.p_policy_id(+)
                       AND pp.policy_id = dc.document_id
                       AND dc.doc_status_ref_id = dsr.doc_status_ref_id
                       AND dsr.brief NOT IN ('CANCEL')
                          
                          -- Последняя версия
                       AND pp_l.policy_id = ph.last_ver_id
                       AND pp_l.policy_id = dc_l.document_id
                       AND dc_l.doc_status_ref_id = dsr_l.doc_status_ref_id
                       AND pp_l.policy_id = pd_l.p_policy_id(+)
                       AND pp_l.decline_reason_id = dr_l.t_decline_reason_id(+)) pol) policy
          ,ins.contact cn
          ,ins.department d
     WHERE policy.agent_id = cn.contact_id(+)
       AND policy.agency_id = d.department_id(+);
  EXCEPTION
    WHEN OTHERS THEN
      v_err_code := SQLCODE;
      raise_application_error(policy_exception_num, v_err_code);
  END prepare_policy_info;

  /*
    Байтин А.
    Получение данных по платежам
  */
  PROCEDURE prepare_payment_info IS
    v_err_code VARCHAR2(30);
  BEGIN
    SELECT MIN(payment_id) AS payment_id
          ,MIN(policy_id) AS policy_id
          ,due_date AS due_date
          ,grace_date AS grace_date
          ,CASE
             WHEN nvl(MIN(pay_date), to_date('01.01.1900', 'dd.mm.yyyy')) <
                  nvl(decline_date, to_date('31.12.2999', 'dd.mm.yyyy')) THEN
              nvl(ROUND(SUM(epg_amount), 2), 0)
             ELSE
              0
           END AS epg_amount
          ,MIN(pay_date) AS pay_date
          ,CASE
             WHEN nvl(MIN(pay_date), to_date('01.01.1900', 'dd.mm.yyyy')) <
                  nvl(decline_date, to_date('31.12.2999', 'dd.mm.yyyy')) THEN
              nvl(ROUND(SUM(epg_amount_rur), 2), 0)
             ELSE
              0
           END AS epg_amount_rur
          ,epg_status_brief AS epg_status_brief
          ,CASE epg_status_brief
             WHEN 'NEW' THEN
              'Новый'
             WHEN 'TO_PAY' THEN
              'К оплате'
             WHEN 'PAID' THEN
              'Оплачен'
           END AS epg_status
          ,nvl(ROUND(SUM(index_fee), 2), 0) AS index_fee
          ,nvl(ROUND(SUM(adm_cost), 2), 0) AS adm_cost
          ,CASE
             WHEN nvl(MIN(pay_date), to_date('01.01.1900', 'dd.mm.yyyy')) <
                  nvl(decline_date, to_date('31.12.2999', 'dd.mm.yyyy')) THEN
              nvl(ROUND(SUM(debt_sum), 2), 0)
             ELSE
              nvl(ROUND(SUM(epg_amount_rur), 2), 0)
           END AS debt_sum
          ,pol_header_id
          ,row_number() over(PARTITION BY pol_header_id ORDER BY grace_date) AS payment_num
      BULK COLLECT
      INTO gv_payment_info
      FROM (SELECT payment_id
                  ,policy_id
                  ,pol_header_id
                  ,due_date
                  ,grace_date
                  ,epg_amount
                  ,(SELECT MIN(pay_doc.due_date)
                      FROM ins.doc_set_off dso
                          ,ins.ac_payment  pay_doc
                          ,ins.document    dc
                     WHERE dso.parent_doc_id = mn.true_payment_id
                       AND dso.child_doc_id = pay_doc.payment_id
                       AND dso.doc_set_off_id = dc.document_id
                       AND dc.doc_status_ref_id != 41) pay_date
                  ,epg_amount * rev_rate AS epg_amount_rur
                  ,epg_status_brief
                  ,CASE
                     WHEN epg_status_brief IN ('NEW', 'TO_PAY')
                          AND row_number()
                      over(PARTITION BY pol_header_id ORDER BY plan_date DESC) = 1 THEN
                      index_fee
                     ELSE
                      0
                   END AS index_fee
                  ,adm_cost
                  ,CASE epg_status_brief
                     WHEN 'NEW' THEN
                      0
                     ELSE
                      epg_amount -
                      nvl(ins.pkg_payment.get_set_off_amount(payment_id, pol_header_id, NULL), 0)
                   END AS debt_sum
                  ,decline_date
              FROM (SELECT /*+ LEADING(tt pp) USE_NL(pp dd ac)*/
                     ac.payment_id
                    ,tt.policy_id
                    ,pp.pol_header_id
                    ,ac.grace_date
                    ,CASE
                       WHEN dsr.brief = 'NEW'
                            OR ac.due_date > trunc(SYSDATE, 'dd') THEN
                        (SELECT nvl(SUM(se.fee), 0)
                           FROM ins.p_pol_header ph
                               ,ins.as_asset     se
                          WHERE ph.policy_header_id = pp.pol_header_id
                            AND ph.policy_id = se.p_policy_id) - CASE
                          WHEN MOD(MONTHS_BETWEEN(ac.plan_date, tt.date_begin), 12) != 0 THEN
                           (SELECT nvl(SUM(pc.fee), 0)
                              FROM ins.p_pol_header       ph
                                  ,ins.as_asset           se
                                  ,ins.p_cover            pc
                                  ,ins.t_prod_line_option plo
                             WHERE ph.policy_header_id = pp.pol_header_id
                               AND ph.policy_id = se.p_policy_id
                               AND se.as_asset_id = pc.as_asset_id
                               AND pc.t_prod_line_option_id = plo.id
                               AND plo.brief IN ('Adm_Cost_Acc', 'Adm_Cost_Life'))
                          ELSE
                           0
                        END
                       WHEN dsr.brief = 'PAID' THEN
                        ins.pkg_payment.get_set_off_amount(ac.payment_id, pp.pol_header_id, NULL)
                       WHEN dsr.brief = 'TO_PAY' THEN
                        ac.amount
                     END epg_amount
                    ,ac.rev_rate
                    ,CASE
                       WHEN COUNT(CASE dsr.brief
                                    WHEN 'TO_PAY' THEN
                                     1
                                  END) over(PARTITION BY pp.pol_header_id, ac.plan_date) > 0 THEN
                        'TO_PAY'
                       ELSE
                        dsr.brief
                     END AS epg_status_brief
                    ,CASE
                       WHEN tt.last_ver_status = 'INDEXATING' THEN
                        to_number(decode(tt.fee_index, NULL, NULL, tt.fee_index))
                       ELSE
                        0
                     END AS index_fee
                    ,CASE
                       WHEN MOD(MONTHS_BETWEEN(ac.plan_date, tt.date_begin), 12) = 0 THEN
                        (SELECT nvl(SUM(pc.fee), 0)
                           FROM ins.p_pol_header       ph
                               ,ins.as_asset           se
                               ,ins.p_cover            pc
                               ,ins.t_prod_line_option plo
                          WHERE ph.policy_header_id = pp.pol_header_id
                            AND ph.policy_id = se.p_policy_id
                            AND se.as_asset_id = pc.as_asset_id
                            AND pc.t_prod_line_option_id = plo.id
                            AND plo.brief IN ('Adm_Cost_Acc', 'Adm_Cost_Life'))
                       ELSE
                        0
                     END AS adm_cost
                    ,COUNT(CASE
                             WHEN dsr.brief = 'TO_PAY' THEN
                              1
                           END) over(PARTITION BY pp.pol_header_id) AS exists_topay
                    ,row_number() over(PARTITION BY pp.pol_header_id, dsr.brief ORDER BY ac.plan_date) AS rn_status
                    ,ac.payment_id AS true_payment_id
                    ,CASE
                       WHEN pt.brief = 'Единовременно' THEN
                        MIN(ac.payment_id) over(PARTITION BY pp.pol_header_id)
                       ELSE
                        ac.payment_id
                     END AS ed_min_payment_id
                    ,ac.due_date
                    ,ac.plan_date
                    ,ded.decline_date
                      FROM ins.ac_payment ac
                          ,ins.doc_doc dd
                          ,ins.p_policy pp
                          ,ins.t_payment_terms pt
                          ,ins.document dc
                          ,ins.doc_status_ref dsr
                          ,(SELECT /*+ LEADING (tt ppd pd) USE_NL(tt ppd)*/
                             MAX(CASE
                                   WHEN pd.p_policy_id IS NOT NULL THEN
                                    ppd.decline_date
                                 END) AS decline_date
                            ,ppd.pol_header_id
                              FROM ins.p_policy ppd
                                  ,ins.document d
                                  ,ins.doc_status_ref dsr
                                  ,ins.p_pol_decline pd -- Только для обхода ошибки, связанной с копированием decline_reason_id в последующие версии
                                  ,(SELECT policy_id
                                          ,last_ver_policy_id
                                          ,active_ver_status
                                          ,last_ver_status
                                      FROM TABLE(pkg_personal_profile.get_policy_info)) tt
                             WHERE ppd.policy_id = d.document_id
                               AND d.doc_status_ref_id = dsr.doc_status_ref_id
                               AND ppd.policy_id = pd.p_policy_id(+)
                               AND ppd.policy_id IN (tt.policy_id, tt.last_ver_policy_id)
                               AND dsr.brief != 'CANCEL'
                             GROUP BY ppd.pol_header_id) ded
                          ,(SELECT policy_header_id
                                  ,fee_index
                                  ,last_ver_status
                                  ,date_begin
                                  ,policy_id
                                  ,fund
                              FROM TABLE(pkg_personal_profile.get_policy_info)) tt
                     WHERE pp.pol_header_id = tt.policy_header_id
                       AND pp.payment_term_id = pt.id
                       AND pp.policy_id = dd.parent_id
                       AND dd.child_id = ac.payment_id
                       AND ac.payment_id = dc.document_id
                       AND dc.doc_templ_id = 4 -- PAYMENT
                       AND dc.doc_status_ref_id = dsr.doc_status_ref_id
                       AND ac.plan_date >= to_date('01.01.2010', 'dd.mm.yyyy')
                       AND pp.pol_header_id = ded.pol_header_id
                       AND ac.plan_date <= nvl(ded.decline_date, ac.plan_date)
                       AND dsr.brief IN ('TO_PAY', 'PAID', 'NEW')) mn
             WHERE (epg_status_brief IN ('PAID', 'TO_PAY') AND payment_id = ed_min_payment_id)
                OR epg_status_brief = 'NEW'
               AND exists_topay = 0
               AND rn_status = 1)
     GROUP BY pol_header_id
             ,due_date
             ,grace_date
             ,epg_status_brief
             ,decline_date;
  EXCEPTION
    WHEN OTHERS THEN
      v_err_code := SQLCODE;
      raise_application_error(payment_exception_num, v_err_code);
  END prepare_payment_info;

  /*
    Байтин А.
  
    Получение данных по застрахованным
  */
  PROCEDURE prepare_assured_info IS
    v_err_code VARCHAR2(30);
  BEGIN
    SELECT /*+ INDEX (su PK_AS_ASSURED) INDEX (co PK_CONTACT) INDEX (cp PK_CN_PERSON)*/
     co.obj_name_orig      AS assured_name
    ,cp.date_of_birth      AS assured_birth
    ,se.as_asset_id
    ,su.assured_contact_id AS contact_id
    ,pt.policy_id
      BULK COLLECT
      INTO gv_assured_info
      FROM ins.as_asset se
          ,ins.as_assured su
          ,ins.contact co
          ,ins.cn_person cp
          ,(SELECT policy_id FROM TABLE(pkg_personal_profile.get_policy_info)) pt
     WHERE pt.policy_id = se.p_policy_id
       AND se.as_asset_id = su.as_assured_id
       AND su.assured_contact_id = co.contact_id
       AND co.contact_id = cp.contact_id;
  EXCEPTION
    WHEN OTHERS THEN
      v_err_code := SQLCODE;
      raise_application_error(cover_exception_num, v_err_code);
  END prepare_assured_info;

  /*
    Байтин А.
    Получение данных по покрытиям
  */
  PROCEDURE prepare_cover_info(par_is_demo_cabinet NUMBER DEFAULT 0) IS
    v_err_code VARCHAR2(30);
    c_new_client_date CONSTANT DATE := to_date('01.10.2013', 'DD.MM.YYYY');
  BEGIN
    SELECT p_cover_id
          ,date_begin
          ,date_end
          ,insurance_sum
          ,fee
          ,cover_type_name
          ,cover_brief
          ,lob_line_brief
          ,annual
          ,loan
          ,net_premium_act
          ,delta_deposit1
          ,penalty
          ,CASE
             WHEN annual = 1
                  AND par_is_demo_cabinet = 1 THEN
              1
             ELSE
              payment_sign
           END AS payment_sign
          ,policy_id
          ,as_asset_id
      BULK COLLECT
      INTO gv_cover_info
      FROM (SELECT /*+dynamic_sampling(pt,2) dynamic_sampling(a,2)*/
             pc.p_cover_id
                  ,pc.start_date AS date_begin
                  ,pc.end_date AS date_end
                  ,nvl(pc.ins_amount, 0) AS insurance_sum
                  ,nvl(pc.fee, 0) AS fee
                  ,pl.description AS cover_type_name
                  ,ll.brief AS cover_brief
                  ,ll.brief AS lob_line_brief
                  ,to_number(NULL) AS annual
                  ,to_number(NULL) AS loan
                  ,to_number(NULL) AS net_premium_act
                  ,to_number(NULL) AS delta_deposit1
                  ,to_number(NULL) AS penalty
                  ,to_number(NULL) AS payment_sign
                  ,pt.policy_id
                  ,a.as_asset_id
              FROM ins.p_cover pc
                  ,(SELECT * FROM TABLE(pkg_personal_profile.get_assured_info)) a
                  ,(SELECT policy_id
                          ,product_brief
                          ,product_id
                      FROM TABLE(pkg_personal_profile.get_policy_info)) pt
                  ,ins.t_prod_line_option plo
                  ,ins.t_product_line pl
                  ,ins.t_lob_line ll
             WHERE pc.as_asset_id = a.as_asset_id
               AND a.policy_id = pt.policy_id
               AND plo.product_line_id = pl.id
               AND pc.t_prod_line_option_id = plo.id
               AND pl.t_lob_line_id = ll.t_lob_line_id
               AND (pl.brief != 'NonInsuranceClaims' OR pl.brief IS NULL)
                  -- Григорьев Ю.А. Исключаем отключенные риски
               AND pc.status_hist_id != pkg_cover.get_status_hist_id_del
                  -- Байтин А. Выбираем все, кроме "Инвестора"
               AND (pt.product_id NOT IN
                   (SELECT *
                       FROM TABLE(pkg_product_category.get_product_list('PRODUCT_TYPE', 'INVEST')))
                   /*
                   ('Investor'
                                         ,'INVESTOR_LUMP_OLD'
                                         ,'INVESTOR_LUMP'
                                         ,'InvestorALFA'
                   ,'Invest_in_future'
                                         ,'Priority_Invest(regular)'
                                         ,'Priority_Invest(lump)'
                                         ,'InvestorPlus'
                   ,'INVESTOR_LUMP_ALPHA'
                   ,'INVESTOR_LUMP_AKBARS')
                   */
                   OR plo.brief = 'AD'
                   --AND pt.product_brief = 'Invest_in_future' 
                   )
            -- Для продукта "Инвестор", исключаем административные издержки, а также генерим по три дополнительные строчки для каждого риска
            UNION ALL
            SELECT /*+ USE_NL(plo pl ll) */
             pc.p_cover_id
            ,pc.start_date AS date_begin
            ,pc.end_date AS date_end
            ,nvl(pc.ins_amount, 0) AS insurance_sum
            ,nvl(pc.fee, 0) AS fee
            ,lines.pl_description AS cover_type_name
            ,lines.ll_brief AS cover_brief
            ,lines.ll_brief AS lob_line_brief
            ,an.annual AS annual
            ,to_number(NULL) AS loan
            ,coalesce(pkg_cover.calc_fee_investment_part(pc.p_cover_id)
                     ,CASE lines.product_brief
                        WHEN 'Priority_Invest(regular)' THEN
                         CASE lines.plo_brief
                           WHEN 'PEPR_C' THEN
                            0.91
                           WHEN 'PEPR_B' THEN
                            0.86
                           WHEN 'PEPR_A' THEN
                            0.87
                           ELSE
                            1
                         END
                        WHEN 'Priority_Invest(lump)' THEN
                         CASE lines.plo_brief
                           WHEN 'PEPR_B' THEN
                            0.86
                           WHEN 'PEPR_A' THEN
                            0.878
                           WHEN 'PEPR_A_PLUS' THEN
                            0.9
                           ELSE
                            1
                         END
                        WHEN 'Invest_in_future' THEN
                         CASE
                           WHEN lines.date_begin >= c_new_client_date THEN
                            0.89
                           ELSE
                            CASE lines.plo_brief
                              WHEN 'PEPR_B' THEN
                               0.91
                              WHEN 'PEPR_A' THEN
                               0.92
                              WHEN 'PEPR_A_PLUS' THEN
                               0.9357
                              ELSE
                               1
                            END
                         END
                        WHEN 'INVESTOR_LUMP_ALPHA' THEN
                         CASE
                          (SELECT num
                             FROM document
                            WHERE document_id = pkg_agn_control.get_current_policy_agent(lines.policy_header_id))
                           WHEN '44730' THEN
                            CASE
                              WHEN lines.date_begin >= to_date('01.04.2014', 'dd.mm.yyyy') THEN
                               CASE lines.plo_brief
                                 WHEN 'PEPR_B' THEN
                                  1 - 0.14
                                 WHEN 'PEPR_A' THEN
                                  1 - 0.13
                                 WHEN 'PEPR_A_PLUS' THEN
                                  1 - 0.11
                                 ELSE
                                  1
                               END
                              ELSE
                               CASE lines.plo_brief
                                 WHEN 'PEPR_B' THEN
                                  1 - 0.11
                                 WHEN 'PEPR_A' THEN
                                  1 - 0.09
                                 WHEN 'PEPR_A_PLUS' THEN
                                  1 - 0.07
                                 ELSE
                                  1
                               END
                            END
                           WHEN '45130' THEN --ВТБ24
                            CASE lines.plo_brief
                              WHEN 'PEPR_B' THEN
                               1 - 0.14
                              WHEN 'PEPR_A' THEN
                               1 - 0.13
                              WHEN 'PEPR_A_PLUS' THEN
                               1 - 0.11
                              ELSE
                               1
                            END
                           WHEN '50592' THEN --ВТБ24 новый
                            CASE
                              WHEN lines.date_begin >= to_date('01.12.2014', 'dd.mm.yyyy') THEN
                              
                               CASE lines.plo_brief
                                 WHEN 'PEPR_B' THEN
                                  1 - 0.197
                                 WHEN 'PEPR_A' THEN
                                  1 - 0.194
                                 WHEN 'PEPR_A_PLUS' THEN
                                  1 - 0.182
                                 ELSE
                                  1
                               END
                              ELSE
                            CASE lines.plo_brief
                              WHEN 'PEPR_B' THEN
                               1 - 0.14
                              WHEN 'PEPR_A' THEN
                               1 - 0.13
                              WHEN 'PEPR_A_PLUS' THEN
                               1 - 0.11
                              ELSE
                               1
                            END
                            END
                           ELSE
                            CASE lines.plo_brief
                              WHEN 'PEPR_B' THEN
                               0.9
                              WHEN 'PEPR_A' THEN
                               0.93
                              WHEN 'PEPR_A_PLUS' THEN
                               0.93
                              ELSE
                               1
                            END
                         END
                        WHEN 'InvestorPlus' THEN
                         0.93
                        ELSE
                         CASE
                           WHEN lines.payment_term = 'Единовременно' THEN
                            CASE MONTHS_BETWEEN(pc.end_date + 1 / 3600, pc.start_date) / 12
                              WHEN 3 THEN
                               CASE lines.plo_brief
                                 WHEN 'PEPR_B' THEN
                                  0.9387
                                 WHEN 'PEPR_A' THEN
                                  0.9387
                                 WHEN 'PEPR_A_PLUS' THEN
                                  0.9387
                                 ELSE
                                  1
                               END
                              WHEN 5 THEN
                               CASE lines.plo_brief
                                 WHEN 'PEPR_B' THEN
                                  0.9357
                                 WHEN 'PEPR_A' THEN
                                  0.9357
                                 WHEN 'PEPR_A_PLUS' THEN
                                  0.9357
                                 ELSE
                                  1
                               END
                              ELSE
                               1
                            END
                           ELSE
                            CASE lines.plo_brief
                              WHEN 'PEPR_C' THEN
                               0.95
                              WHEN 'PEPR_B' THEN
                               0.93
                              WHEN 'PEPR_A' THEN
                               0.9
                              ELSE
                               1
                            END
                         END
                      END) * nvl(pc.fee, 0) AS net_premium_act
            ,to_number(NULL) AS delta_deposit1
            ,to_number(NULL) AS penalty
            ,CASE (SELECT cp.epg_status_brief
                 FROM (SELECT pol_header_id
                             ,payment_num
                             ,epg_status_brief
                         FROM TABLE(pkg_personal_profile.get_payment_info)) cp
                WHERE cp.pol_header_id = lines.policy_header_id
                  AND cp.payment_num = an.annual)
               WHEN 'PAID' THEN
                1
               ELSE
                0
             END AS payment_sign
            ,lines.policy_id
            ,lines.as_asset_id
              FROM (SELECT /*+dynamic_sampling(pol,2) dynamic_sampling(a,2) USE_NL (pol p pv pvl ll pl plo)*/
                     p.brief              AS product_brief
                    ,pl.description       AS pl_description
                    ,pl.brief             AS pl_brief
                    ,pl.id                AS pl_id
                    ,plo.id               AS plo_id
                    ,plo.brief            AS plo_brief
                    ,ll.t_lob_line_id     AS ll_t_lob_line_id
                    ,ll.brief             AS ll_brief
                    ,plo.product_line_id  AS plo_product_line_id
                    ,a.as_asset_id
                    ,pol.period_value
                    ,pol.policy_id
                    ,pol.payment_term
                    ,pol.date_begin
                    ,pol.policy_header_id
                    ,p.product_id
                      FROM t_product p
                          ,t_product_version pv
                          ,t_product_ver_lob pvl
                          ,t_lob_line ll
                          ,t_product_line pl
                          ,t_prod_line_option plo
                          ,(SELECT * FROM TABLE(pkg_personal_profile.get_assured_info)) a
                          ,(SELECT * FROM TABLE(pkg_personal_profile.get_policy_info)) pol
                     WHERE p.product_id = pv.product_id
                       AND pv.t_product_version_id = pvl.product_version_id
                       AND pvl.t_product_ver_lob_id = pl.product_ver_lob_id
                       AND pl.t_lob_line_id = ll.t_lob_line_id
                       AND pl.id = plo.product_line_id
                       AND p.product_id = pol.product_id
                       AND a.policy_id = pol.policy_id) lines
                  ,ins.p_cover pc
                  ,(SELECT LEVEL AS annual FROM dual CONNECT BY LEVEL <= 5) an
             WHERE lines.as_asset_id = pc.as_asset_id(+)
               AND an.annual <= lines.period_value
               AND lines.plo_id = pc.t_prod_line_option_id(+)
               AND (lines.pl_brief != 'NonInsuranceClaims' OR lines.pl_brief IS NULL)
               AND lines.product_id IN
                   (SELECT /*+dynamic_sampling(prd_gr,2) */* FROM TABLE(pkg_product_category.get_product_list('PRODUCT_TYPE', 'INVEST')) prd_gr)
               AND lines.plo_brief != 'AD'
               AND lines.pl_description NOT IN
                   ('Административные издержки'
                   ,'Административные издержки на восстановление')
               AND NOT EXISTS (SELECT NULL
                      FROM ins.p_pol_change poc
                     WHERE lines.pl_id = poc.t_prod_line_id
                       AND lines.policy_id = poc.p_policy_id)
                  -- Григорьев Ю.А. Исключаем отключенные риски
               AND pc.status_hist_id != pkg_cover.get_status_hist_id_del
            UNION ALL
            SELECT /*+ LEADING(pt se pc) dynamic_sampling(pt,2) dynamic_sampling(se,2)*/
             pc.p_cover_id
            ,pc.start_date AS date_begin
            ,pc.end_date AS date_end
            ,nvl(poc.ins_amount, 0) AS insurance_sum
            ,nvl(poc.fee, 0) AS fee
            ,pl.description AS cover_type_name
            ,ll.brief AS cover_brief
            ,ll.brief AS lob_line_brief
            ,poc.par_t AS annual
            ,poc.acc_net_prem_after_change AS loan
            ,poc.net_premium_act AS net_premium_act
            ,CASE poc.par_t
               WHEN 1 THEN
                0
               WHEN 2 THEN
                poc.delta_deposit1
               WHEN 3 THEN
                poc.delta_deposit2
               WHEN 4 THEN
                poc.delta_deposit3
               WHEN 5 THEN
                poc.delta_deposit4
             END AS delta_deposit1
            ,poc.penalty
            ,CASE (SELECT cp.epg_status_brief
                 FROM (SELECT pol_header_id
                             ,payment_num
                             ,epg_status_brief
                         FROM TABLE(pkg_personal_profile.get_payment_info)) cp
                WHERE cp.pol_header_id = pt.policy_header_id
                  AND cp.payment_num = poc.par_t)
               WHEN 'PAID' THEN
                1
               ELSE
                0
             END AS payment_sign
            ,pt.policy_id
            ,se.as_asset_id
              FROM (SELECT policy_id
                          ,product_brief
                          ,payment_term
                          ,policy_header_id
                          ,product_id
                      FROM TABLE(pkg_personal_profile.get_policy_info)) pt
                  ,(SELECT * FROM TABLE(pkg_personal_profile.get_assured_info)) se
                  ,ins.p_cover pc
                  ,ins.t_prod_line_option plo
                  ,ins.t_product_line pl
                  ,ins.p_pol_change poc
                  ,ins.t_lob_line ll
             WHERE se.policy_id = pt.policy_id
               AND se.as_asset_id = pc.as_asset_id
               AND plo.product_line_id = poc.t_prod_line_id
               AND pc.t_prod_line_option_id = plo.id
               AND plo.product_line_id = pl.id
               AND pl.t_lob_line_id = ll.t_lob_line_id
               AND pt.policy_id = poc.p_policy_id
               AND (pl.brief != 'NonInsuranceClaims' OR pl.brief IS NULL)
               AND plo.brief != 'AD'
               AND pt.product_id IN
                   (SELECT * FROM TABLE(pkg_product_category.get_product_list('PRODUCT_TYPE', 'INVEST')))
               AND pl.description NOT IN
                   ('Административные издержки'
                   ,'Административные издержки на восстановление')
                  -- Григорьев Ю.А. Исключаем отключенные риски
               AND pc.status_hist_id != pkg_cover.get_status_hist_id_del);
  EXCEPTION
    WHEN OTHERS THEN
      v_err_code := SQLCODE;
      raise_application_error(cover_exception_num, v_err_code);
  END prepare_cover_info;

  PROCEDURE prepare_acq_template_info IS
    v_err_code VARCHAR2(30);
  BEGIN
    SELECT pt.acq_payment_template_id
          ,dc.num
          ,dc.reg_date
          ,pt.fee
          ,pt.till AS act_period
          ,dsr.brief
          ,dsr.name
          ,CASE
             WHEN dsr.brief IN ('STOP', 'CANCEL') THEN
              ds.change_date
           END AS end_date
          ,pt.t_mpos_rejection_id
          ,mr.name AS rejection_name
          ,pt.policy_header_id
          ,pi.pol_num
      BULK COLLECT
      INTO gv_acq_template_info
      FROM acq_payment_template pt
          ,document dc
          ,doc_status ds
          ,doc_status_ref dsr
          ,t_mpos_rejection mr
          ,(SELECT pi.policy_header_id
                  ,pi.pol_num
              FROM TABLE(get_policy_info) pi) pi
     WHERE pt.acq_payment_template_id = dc.document_id
       AND dc.doc_status_id = ds.doc_status_id
       AND ds.doc_status_ref_id = dsr.doc_status_ref_id
       AND pt.t_mpos_rejection_id = mr.t_mpos_rejection_id(+)
       AND pt.policy_header_id = pi.policy_header_id
       AND dsr.brief NOT IN ('PROJECT', 'CANCEL');
  EXCEPTION
    WHEN OTHERS THEN
      v_err_code := SQLCODE;
      raise_application_error(template_exception_num, v_err_code);
    
  END prepare_acq_template_info;

  /*
    Байтин А.
    Получение данных по персональным данным
  */
  PROCEDURE prepare_persdata_info(par_is_demo_cabinet NUMBER DEFAULT 0) IS
    v_err_code VARCHAR2(30);
  BEGIN
    SELECT co.contact_id
          ,it.brief AS doc_type_brief
          ,it.description AS doc_type_name
          ,ci.serial_nr AS doc_series
          ,ci.id_value AS doc_number
          ,ci.issue_date AS doc_date
          ,ci.place_of_issue AS doc_place
          ,co.address
          ,co.ipdl
          ,co.rpdl
          ,co.notify
          ,CASE
             WHEN co.notify = 0
                  AND MONTHS_BETWEEN(SYSDATE, co.last_update_date) > 11
                  AND ((co.contact_id = gv_contact_info.insured_id AND EXISTS
                   (SELECT NULL
                           FROM TABLE(get_policy_info) pi
                          WHERE pi.active_ver_status NOT IN ('STOPED', 'CANCEL', 'QUIT'))) OR
                  EXISTS (SELECT NULL
                                FROM TABLE(get_assured_info) ai
                                    ,TABLE(get_policy_info) pi
                               WHERE ai.contact_id = co.contact_id
                                 AND ai.policy_id = pi.policy_id
                                 AND pi.active_ver_status NOT IN ('STOPED', 'CANCEL', 'QUIT'))) THEN
              1
             ELSE
              0
           END refresh_needed
      BULK COLLECT
      INTO gv_persdata_info
      FROM (SELECT /*+ INDEX (co pk_contact) INDEX (cp PK_CN_PERSON)*/
             coalesce(pkg_contact_rep_utils.get_last_doc_by_type(co.contact_id, 'PASS_RF')
                     ,pkg_contact_rep_utils.get_last_doc_by_type(co.contact_id, 'PASS_IN')
                     ,pkg_contact_rep_utils.get_last_doc_by_type(co.contact_id, 'BIRTH_CERT')) AS doc_id
            ,pkg_contact_rep_utils.get_address(pkg_contact_rep_utils.get_last_active_address_id(co.contact_id
                                                                                               ,'CONST')) AS address
            ,co.contact_id
            ,co.is_public_contact AS ipdl
            ,nvl(cp.is_in_list, 0) AS rpdl
            ,cp.last_update_date
            ,CASE
               WHEN EXISTS (SELECT NULL
                       FROM cn_profile_name pd
                      WHERE pd.contact_id = co.contact_id
                     UNION ALL
                     SELECT NULL
                       FROM cn_profile_public pd
                      WHERE pd.contact_id = co.contact_id
                     UNION ALL
                     SELECT NULL
                       FROM cn_profile_doc pd
                      WHERE pd.contact_id = co.contact_id
                     UNION ALL
                     SELECT NULL
                       FROM cn_profile_address pd
                      WHERE pd.contact_id = co.contact_id) THEN
                1
               ELSE
                0
             END AS notify
              FROM contact   co
                  ,cn_person cp
             WHERE co.contact_id IN ((SELECT ai.contact_id
                                       FROM TABLE(pkg_personal_profile.get_assured_info) ai
                                     UNION ALL
                                     SELECT gv_contact_info.insured_id
                                       FROM dual))
               AND co.contact_id = cp.contact_id) co
          ,cn_contact_ident ci
          ,t_id_type it
     WHERE co.doc_id = ci.table_id(+)
       AND ci.id_type = it.id(+);
  EXCEPTION
    WHEN OTHERS THEN
      v_err_code := SQLCODE;
      raise_application_error(persdata_exception_num, v_err_code);
  END prepare_persdata_info;

  /*
    Подготовка данных из словарей
  */
  FUNCTION get_dict_info_json
  (
    par_policy_id NUMBER DEFAULT NULL
   ,par_only_cost BOOLEAN DEFAULT FALSE
  ) RETURN JSON IS
    vt_lob_briefs   tt_one_col;
    v_date_begin    DATE;
    v_date_end      DATE;
    v_product_brief t_product.brief%TYPE;
    v_is_investor   NUMBER(1);
  
    v_obj           JSON := JSON();
    v_norm_array    JSON_LIST := JSON_LIST();
    v_sab_array     JSON_LIST := JSON_LIST();
    v_fee_res_array JSON_LIST := JSON_LIST();
    v_fonds_array   JSON_LIST := JSON_LIST();
    v_dyn_array     JSON_LIST := JSON_LIST();
  BEGIN
    IF par_only_cost
    THEN
      -- Смотрим, есть ли нужные риски
      SELECT COUNT(*)
        INTO v_is_investor
        FROM dual
       WHERE EXISTS
       (SELECT NULL
                FROM TABLE(get_cover_info)
               WHERE lob_line_brief IN ('PEPR_C', 'PEPR_B', 'PEPR_A', 'PEPR_A_PLUS', 'OIL', 'GOLD'));
    
      IF v_is_investor = 1
      THEN
        -- Динамика стоимости активов
        FOR vr_dyn IN (SELECT change_date
                             ,cons_6_months
                             ,cons_from_year_begining
                             ,cons_year
                             ,cons_whole_history
                             ,bal_6_months
                             ,bal_from_year_begining
                             ,bal_year
                             ,bal_whole_history
                             ,aggr_6_months
                             ,aggr_from_year_begining
                             ,aggr_year
                             ,aggr_whole_history
                             ,aggr_pl_6_months
                             ,aggr_pl_from_year_begining
                             ,aggr_pl_year
                             ,aggr_pl_whole_history
                             ,common_6_months
                             ,common_from_year_begining
                             ,common_year
                             ,common_whole_history
                         FROM t_dynamics_of_assets
                        ORDER BY change_date)
        LOOP
          v_obj := JSON();
          v_obj.put('date', to_char(vr_dyn.change_date, 'dd.mm.yyyy'));
          /* Консервативная */
          v_obj.put('cons_6m', vr_dyn.cons_6_months);
          v_obj.put('cons_beg', vr_dyn.cons_from_year_begining);
          v_obj.put('cons_year', vr_dyn.cons_year);
          v_obj.put('cons_hist', vr_dyn.cons_whole_history);
          /* Сбалансированная */
          v_obj.put('bal_6m', vr_dyn.bal_6_months);
          v_obj.put('bal_beg', vr_dyn.bal_from_year_begining);
          v_obj.put('bal_year', vr_dyn.bal_year);
          v_obj.put('bal_hist', vr_dyn.bal_whole_history);
          /* Агрессивная */
          v_obj.put('aggr_6m', vr_dyn.aggr_6_months);
          v_obj.put('aggr_beg', vr_dyn.aggr_from_year_begining);
          v_obj.put('aggr_year', vr_dyn.aggr_year);
          v_obj.put('aggr_hist', vr_dyn.aggr_whole_history);
          /* Агрессивная плюс */
          v_obj.put('aggr_pl_6m', vr_dyn.aggr_pl_6_months);
          v_obj.put('aggr_pl_beg', vr_dyn.aggr_pl_from_year_begining);
          v_obj.put('aggr_pl_year', vr_dyn.aggr_pl_year);
          v_obj.put('aggr_pl_hist', vr_dyn.aggr_pl_whole_history);
          v_obj.put('com_6m', vr_dyn.common_6_months);
          v_obj.put('com_beg', vr_dyn.common_from_year_begining);
          v_obj.put('com_year', vr_dyn.common_year);
          v_obj.put('com_hist', vr_dyn.common_whole_history);
          v_dyn_array.append(v_obj.to_json_value);
        END LOOP;
      END IF;
    ELSE
      -- Отбираем риски для проецирования
      SELECT DISTINCT lob_line_brief
        BULK COLLECT
        INTO vt_lob_briefs
        FROM TABLE(get_cover_info)
       WHERE lob_line_brief IN ('PEPR_C', 'PEPR_B', 'PEPR_A', 'PEPR_A_PLUS', 'OIL', 'GOLD')
         AND policy_id = par_policy_id;
      -- Получаем дату начала и окончания договора
      SELECT trunc(date_begin, 'mm')
            ,date_end
            ,product_brief
        INTO v_date_begin
            ,v_date_end
            ,v_product_brief
        FROM TABLE(get_policy_info)
       WHERE policy_id = par_policy_id;
      IF vt_lob_briefs.count > 0
      THEN
        -- Нормы доходности
        FOR vr_yield IN (SELECT t_date_yield
                               ,conservative_min
                               ,conservative_max
                               ,base_min
                               ,base_max
                               ,aggressive_min
                               ,aggressive_max
                               ,aggressive_plus_min
                               ,aggressive_plus_max
                               ,petroleum_prot_min
                               ,petroleum_prot_max
                               ,petroleum_peril_min
                               ,petroleum_peril_max
                               ,gold_prot_min
                               ,gold_prot_max
                               ,gold_peril_min
                               ,gold_peril_max
                               ,petroleum_change
                               ,total_petroleum_min
                               ,total_petroleum_max
                               ,gold_change
                               ,total_gold_min
                               ,total_gold_max
                           FROM t_reference_yield
                          WHERE v_date_begin < to_date('01.06.2013', 'dd.mm.yyyy')
                            AND t_date_yield BETWEEN CASE v_product_brief
                                  WHEN 'InvestorPlus' THEN
                                   ADD_MONTHS(v_date_begin, -12 * 3)
                                  ELSE
                                   v_date_begin
                                END
                               
                                AND v_date_end
                         UNION ALL
                         SELECT t_date_yield
                               ,conservative_min
                               ,conservative_max
                               ,base_min
                               ,base_max
                               ,aggressive_min
                               ,aggressive_max
                               ,aggressive_plus_min
                               ,aggressive_plus_max
                               ,petroleum_prot_min
                               ,petroleum_prot_max
                               ,petroleum_peril_min
                               ,petroleum_peril_max
                               ,gold_prot_min
                               ,gold_prot_max
                               ,gold_peril_min
                               ,gold_peril_max
                               ,petroleum_change
                               ,total_petroleum_min
                               ,total_petroleum_max
                               ,gold_change
                               ,total_gold_min
                               ,total_gold_max
                           FROM t_reference_yield_profile
                          WHERE v_date_begin >= to_date('01.06.2013', 'dd.mm.yyyy')
                            AND t_date_yield BETWEEN CASE v_product_brief
                                  WHEN 'InvestorPlus' THEN
                                   ADD_MONTHS(v_date_begin, -12 * 3)
                                  ELSE
                                   v_date_begin
                                END AND v_date_end)
        LOOP
          v_obj := JSON();
          v_obj.put('date', to_char(vr_yield.t_date_yield, 'dd.mm.yyyy'));
          FOR v_idx IN vt_lob_briefs.first .. vt_lob_briefs.last
          LOOP
            /* Консервативная */
            v_obj.put('cons_min', vr_yield.conservative_min);
            v_obj.put('cons_max', vr_yield.conservative_max);
            /* Сбалансированная */
            v_obj.put('bal_min', vr_yield.base_min);
            v_obj.put('bal_max', vr_yield.base_max);
            /* Агрессивная */
            v_obj.put('aggr_min', vr_yield.aggressive_min);
            v_obj.put('aggr_max', vr_yield.aggressive_max);
            /* Агрессивная плюс */
            v_obj.put('aggr_pl_min', vr_yield.aggressive_plus_min);
            v_obj.put('aggr_pl_max', vr_yield.aggressive_plus_max);
            /* Нефть */
            v_obj.put('oil_prot_min', vr_yield.petroleum_prot_min);
            v_obj.put('oil_prot_max', vr_yield.petroleum_prot_max);
            v_obj.put('oil_risk_min', vr_yield.petroleum_peril_min);
            v_obj.put('oil_risk_max', vr_yield.petroleum_peril_max);
            v_obj.put('oil_change', vr_yield.petroleum_change);
            v_obj.put('oil_tot_min', vr_yield.total_petroleum_min);
            v_obj.put('oil_tot_max', vr_yield.total_petroleum_max);
            /* Золото */
            v_obj.put('gold_prot_min', vr_yield.gold_prot_min);
            v_obj.put('gold_prot_max', vr_yield.gold_prot_max);
            v_obj.put('gold_risk_min', vr_yield.gold_peril_min);
            v_obj.put('gold_risk_max', vr_yield.gold_peril_max);
            v_obj.put('gold_change', vr_yield.gold_change);
            v_obj.put('gold_tot_min', vr_yield.total_gold_min);
            v_obj.put('gold_tot_max', vr_yield.total_gold_max);
          END LOOP;
          v_norm_array.append(v_obj.to_json_value);
        END LOOP;
        -- Справочник акции-облигации
        FOR vr_sab IN (SELECT CASE strategy
                                WHEN 0 THEN
                                 'Сбалансированная'
                                WHEN 1 THEN
                                 'Агрессивная'
                                WHEN 2 THEN
                                 'Консервативная'
                                WHEN 3 THEN
                                 'Агрессивная плюс'
                                WHEN 4 THEN
                                 'Нефть'
                                WHEN 5 THEN
                                 'Золото'
                              END AS strategy
                             ,CASE stock_or_bond
                                WHEN 0 THEN
                                 'Акции'
                                WHEN 1 THEN
                                 'Облигации'
                                WHEN 2 THEN
                                 'Депозиты'
                                WHEN 3 THEN
                                 'Фьючерсы'
                              END AS stock_or_bond
                             ,numb
                             ,NAME
                             ,part
                         FROM t_stocks_and_bonds sb
                        WHERE sb.strategy IN
                              ( --Гаргонов Д.А. --Заявка 282628.
                               SELECT decode(ll.brief
                                             ,'PEPR_C'
                                             ,2
                                             ,'PEPR_B'
                                             ,0
                                             ,'PEPR_A'
                                             ,1
                                             ,'PEPR_A_PLUS'
                                             ,3
                                             ,'OIL'
                                             ,4
                                             ,'GOLD'
                                             ,5)
                                 FROM t_product             pr
                                      ,t_product_version     tpv
                                      ,t_product_ver_lob     pvl
                                      ,t_lob                 tl
                                      ,t_product_line        pl
                                      ,t_prod_line_option    plo
                                      ,t_prod_line_opt_peril op
                                      ,t_peril               tp
                                      ,t_lob_line            ll
                                      ,p_pol_header          ph
                                      ,p_policy              p
                                WHERE pr.product_id = tpv.product_id
                                  AND pvl.product_version_id = tpv.t_product_version_id
                                  AND tl.t_lob_id = pvl.lob_id
                                  AND pvl.t_product_ver_lob_id = pl.product_ver_lob_id
                                  AND pl.id = plo.product_line_id
                                  AND plo.id = op.product_line_option_id
                                  AND op.peril_id = tp.id
                                  AND ll.t_lob_line_id = pl.t_lob_line_id
                                  AND ph.product_id = pr.product_id
                                  AND ph.policy_header_id = p.pol_header_id
                                  AND pr.product_id IN (SELECT *
                                                          FROM TABLE(pkg_product_category.get_product_list('PRODUCT_TYPE'
                                                                                                          ,'INVEST'))
                                                        /*'Investor'
                                                        ,'INVESTOR_LUMP_OLD'
                                                        ,'INVESTOR_LUMP'
                                                        ,'InvestorALFA'
                                                        ,'Invest_in_future'
                                                        ,'Priority_Invest(regular)'
                                                        ,'Priority_Invest(lump)'
                                                        ,'InvestorPlus'
                                                              ,'INVESTOR_LUMP_ALPHA'
                                                              ,'INVESTOR_LUMP_AKBARS'*/
                                                        )
                                  AND ll.brief IN
                                      ('PEPR_C', 'PEPR_B', 'PEPR_A', 'PEPR_A_PLUS', 'OIL', 'GOLD')
                                     --
                                  AND p.policy_id = par_policy_id --65016931
                               ))
        LOOP
          v_obj := JSON();
          v_obj.put('stgy', vr_sab.strategy);
          v_obj.put('stock', vr_sab.stock_or_bond);
          v_obj.put('numb', vr_sab.numb);
          v_obj.put('name', vr_sab.name);
          v_obj.put('part', vr_sab.part);
          v_sab_array.append(v_obj.to_json_value);
          dbms_output.put_line(vr_sab.strategy || ' ');
        END LOOP;
      
        -- Взнос-резерв
        FOR vr_fee_res IN (SELECT program
                                 ,period
                                 ,year_num
                                 ,CASE strategy
                                    WHEN 0 THEN
                                     'Сбалансированная'
                                    WHEN 1 THEN
                                     'Агрессивная'
                                    WHEN 2 THEN
                                     'Консервативная'
                                    WHEN 3 THEN
                                     'Агрессивная плюс'
                                  END AS strategy
                                 ,reserve_in_fee_part
                             FROM t_fee_reserve fr
                            WHERE fr.strategy IN
                                  ( --Гаргонов Д.А. --Заявка 282628.
                                   SELECT decode(ll.brief
                                                 ,'PEPR_C'
                                                 ,2
                                                 ,'PEPR_B'
                                                 ,0
                                                 ,'PEPR_A'
                                                 ,1
                                                 ,'PEPR_A_PLUS'
                                                 ,3
                                                  /*,'OIL'
                                                  ,4
                                                  ,'GOLD'
                                                  ,5*/)
                                     FROM t_product             pr
                                          ,t_product_version     tpv
                                          ,t_product_ver_lob     pvl
                                          ,t_lob                 tl
                                          ,t_product_line        pl
                                          ,t_prod_line_option    plo
                                          ,t_prod_line_opt_peril op
                                          ,t_peril               tp
                                          ,t_lob_line            ll
                                          ,p_pol_header          ph
                                          ,p_policy              p
                                    WHERE pr.product_id = tpv.product_id
                                      AND pvl.product_version_id = tpv.t_product_version_id
                                      AND tl.t_lob_id = pvl.lob_id
                                      AND pvl.t_product_ver_lob_id = pl.product_ver_lob_id
                                      AND pl.id = plo.product_line_id
                                      AND plo.id = op.product_line_option_id
                                      AND op.peril_id = tp.id
                                      AND ll.t_lob_line_id = pl.t_lob_line_id
                                      AND ph.product_id = pr.product_id
                                      AND ph.policy_header_id = p.pol_header_id
                                      AND pr.product_id IN (SELECT *
                                                              FROM TABLE(pkg_product_category.get_product_list('PRODUCT_TYPE'
                                                                                                              ,'INVEST'))
                                                            /*'Investor'
                                                            ,'INVESTOR_LUMP_OLD'
                                                            ,'INVESTOR_LUMP'
                                                            ,'InvestorALFA'
                                                            ,'Invest_in_future'
                                                            ,'Priority_Invest(regular)'
                                                            ,'Priority_Invest(lump)'
                                                            ,'InvestorPlus'
                                                                  ,'INVESTOR_LUMP_ALPHA'
                                                                  ,'INVESTOR_LUMP_AKBARS'
                                                                  */
                                                            )
                                      AND ll.brief IN ('PEPR_C'
                                                      ,'PEPR_B'
                                                      ,'PEPR_A'
                                                      ,'PEPR_A_PLUS' /*, 'OIL', 'GOLD'*/)
                                         --
                                      AND p.policy_id = par_policy_id --65016931
                                   ))
        LOOP
          v_obj := JSON();
          v_obj.put('prog', vr_fee_res.program);
          v_obj.put('period', vr_fee_res.period);
          v_obj.put('year', vr_fee_res.year_num);
          v_obj.put('stgy', vr_fee_res.strategy);
          v_obj.put('part', vr_fee_res.reserve_in_fee_part);
          v_fee_res_array.append(v_obj.to_json_value);
        END LOOP;
      
        -- Фонды
        FOR vr_fonds IN (SELECT CASE strategy
                                  WHEN 0 THEN
                                   'Сбалансированная'
                                  WHEN 1 THEN
                                   'Агрессивная'
                                  WHEN 2 THEN
                                   'Консервативная'
                                  WHEN 3 THEN
                                   'Агрессивная плюс'
                                  WHEN 4 THEN
                                   'Нефть'
                                  WHEN 5 THEN
                                   'Золото'
                                END AS strategy
                               ,CASE stock_or_bond
                                  WHEN 0 THEN
                                   'Акции'
                                  WHEN 1 THEN
                                   'Облигации'
                                  WHEN 2 THEN
                                   'Депозиты'
                                  WHEN 3 THEN
                                   'Фьючерсы'
                                END AS stock_or_bond
                               ,part
                           FROM t_fonds fo
                          WHERE fo.strategy IN
                                ( --Гаргонов Д.А. --Заявка 282628.
                                 SELECT decode(ll.brief
                                               ,'PEPR_C'
                                               ,2
                                               ,'PEPR_B'
                                               ,0
                                               ,'PEPR_A'
                                               ,1
                                               ,'PEPR_A_PLUS'
                                               ,3
                                               ,'OIL'
                                               ,4
                                               ,'GOLD'
                                               ,5)
                                   FROM t_product             pr
                                        ,t_product_version     tpv
                                        ,t_product_ver_lob     pvl
                                        ,t_lob                 tl
                                        ,t_product_line        pl
                                        ,t_prod_line_option    plo
                                        ,t_prod_line_opt_peril op
                                        ,t_peril               tp
                                        ,t_lob_line            ll
                                        ,p_pol_header          ph
                                        ,p_policy              p
                                  WHERE pr.product_id = tpv.product_id
                                    AND pvl.product_version_id = tpv.t_product_version_id
                                    AND tl.t_lob_id = pvl.lob_id
                                    AND pvl.t_product_ver_lob_id = pl.product_ver_lob_id
                                    AND pl.id = plo.product_line_id
                                    AND plo.id = op.product_line_option_id
                                    AND op.peril_id = tp.id
                                    AND ll.t_lob_line_id = pl.t_lob_line_id
                                    AND ph.product_id = pr.product_id
                                    AND ph.policy_header_id = p.pol_header_id
                                    AND pr.product_id IN
                                        (SELECT *
                                           FROM TABLE(pkg_product_category.get_product_list('PRODUCT_TYPE'
                                                                                           ,'INVEST')))
                                       /*
                                       AND pr.brief IN ('Investor'
                                                       ,'INVESTOR_LUMP_OLD'
                                                       ,'INVESTOR_LUMP'
                                                       ,'InvestorALFA'
                                                       ,'Invest_in_future'
                                                       ,'Priority_Invest(regular)'
                                                       ,'Priority_Invest(lump)'
                                                       ,'InvestorPlus'
                                                          ,'INVESTOR_LUMP_ALPHA'
                                                          ,'INVESTOR_LUMP_AKBARS')
                                          */
                                    AND ll.brief IN
                                        ('PEPR_C', 'PEPR_B', 'PEPR_A', 'PEPR_A_PLUS', 'OIL', 'GOLD')
                                       --
                                    AND p.policy_id = par_policy_id --65016931
                                 ))
        LOOP
          v_obj := JSON();
          v_obj.put('stgy', vr_fonds.strategy);
          v_obj.put('stock', vr_fonds.stock_or_bond);
          v_obj.put('part', vr_fonds.part);
          v_fonds_array.append(v_obj.to_json_value);
        END LOOP;
      END IF;
    END IF;
    v_obj := JSON();
    IF par_only_cost
    THEN
      v_obj.put('cost', v_dyn_array.to_json_value);
    ELSE
      v_obj.put('profitability', v_norm_array.to_json_value);
      v_obj.put('stock', v_sab_array.to_json_value);
      v_obj.put('contribution', v_fee_res_array.to_json_value);
      v_obj.put('fonds', v_fonds_array.to_json_value);
    END IF;
    RETURN v_obj;
    /*EXCEPTION
    WHEN OTHERS THEN
      v_err_code := SQLCODE;
      raise_application_error(cover_exception_num, v_err_code);*/
  END get_dict_info_json;
  /*
    Байтин А.
    Формирование JSON и вывод в качестве ответа
  */
  PROCEDURE post_prepared_info
  (
    par_response   OUT JSON
   ,par_with_dicts BOOLEAN DEFAULT FALSE
  ) IS
    c_proc_name CONSTANT VARCHAR2(30) := 'POST_PREPARED_INFO';
    v_insured          JSON := JSON();
    v_policy_array     JSON_LIST := JSON_LIST();
    v_payment_array    JSON_LIST := JSON_LIST();
    v_assured_array    JSON_LIST := JSON_LIST();
    v_cover_array      JSON_LIST := JSON_LIST();
    v_acq_templ_array  JSON_LIST := JSON_LIST();
    vr_persdata        tr_persdata_info;
    v_assured_persdata JSON;
    v_send             CLOB;
    v_log_info         pkg_communication.typ_log_info;
  BEGIN
    v_insured.put('insured_id', gv_contact_info.insured_id);
    v_insured.put('insured_name', gv_contact_info.insured_name);
    v_insured.put('email', gv_contact_info.email);
    v_insured.put('date_of_birth', gv_contact_info.date_of_birth);
    v_insured.put('card', gv_contact_info.card);
  
    SELECT *
      INTO vr_persdata
      FROM TABLE(get_persdata_info) pi
     WHERE pi.contact_id = gv_contact_info.insured_id;
  
    par_response := JSON();
  
    par_response.put('doc_type_brief', vr_persdata.doc_type_brief);
    par_response.put('doc_type_name', vr_persdata.doc_type_name);
    par_response.put('doc_series', vr_persdata.doc_series);
    par_response.put('doc_number', vr_persdata.doc_number);
    par_response.put('doc_date', vr_persdata.doc_date);
    par_response.put('doc_place', vr_persdata.doc_place);
    par_response.put('address', vr_persdata.address);
    par_response.put('ipdl', vr_persdata.ipdl);
    par_response.put('rpdl', vr_persdata.rpdl);
    par_response.put('notify', vr_persdata.notify);
    par_response.put('refresh_needed', vr_persdata.refresh_needed);
    v_insured.put('persdata', par_response);
  
    FOR vr_template IN (SELECT * FROM TABLE(pkg_personal_profile.get_acq_template_info) pa)
    LOOP
      par_response := JSON();
      par_response.put('rec_pmnt_id', vr_template.num);
      par_response.put('reg_date', vr_template.reg_date);
      par_response.put('fee', vr_template.fee);
      par_response.put('act_period', vr_template.act_period);
      par_response.put('status_brief', vr_template.status_brief);
      par_response.put('status_name', vr_template.status_name);
      par_response.put('end_date', vr_template.end_date);
      par_response.put('reject_id', vr_template.rejection_id);
      par_response.put('reject_name', vr_template.rejection_name);
      par_response.put('pol_header_id', vr_template.pol_header_id);
      par_response.put('pol_num', vr_template.pol_num);
      v_acq_templ_array.append(par_response.to_json_value);
    END LOOP;
  
    FOR vr_policy IN (SELECT pi.*
                            ,(SELECT COUNT(DISTINCT 1)
                                FROM TABLE(pkg_personal_profile.get_acq_template_info) ti
                               WHERE ti.pol_header_id = pi.policy_header_id
                                 AND ti.status_brief = 'CONFIRMED') AS is_exists_template
                        FROM TABLE(pkg_personal_profile.get_policy_info) pi
                       ORDER BY CASE status
                                  WHEN 'Выпуск полиса' THEN
                                   0
                                  WHEN 'Действует' THEN
                                   1
                                  WHEN 'Завершен' THEN
                                   2
                                  WHEN 'Отменен' THEN
                                   3
                                  WHEN 'Расторгнут' THEN
                                   4
                                END)
    LOOP
      v_payment_array := JSON_LIST();
      FOR vr_payment IN (SELECT *
                           FROM TABLE(pkg_personal_profile.get_payment_info) pa
                          WHERE pa.policy_id = vr_policy.policy_id)
      LOOP
        par_response := JSON();
        par_response.put('payment_id', vr_payment.payment_id);
        par_response.put('policy_id', vr_payment.policy_id);
        par_response.put('due_date', vr_payment.due_date);
        par_response.put('grace_date', vr_payment.grace_date);
        par_response.put('epg_amount', vr_payment.epg_amount);
        par_response.put('pay_date', vr_payment.pay_date);
        par_response.put('epg_amount_rur', vr_payment.epg_amount_rur);
        par_response.put('epg_status_brief', vr_payment.epg_status_brief);
        par_response.put('epg_status', vr_payment.epg_status);
        par_response.put('index_fee', vr_payment.index_fee);
        par_response.put('adm_cost', vr_payment.adm_cost);
        par_response.put('debt_sum', vr_payment.debt_sum);
        par_response.put('pol_header_id', vr_payment.pol_header_id);
        v_payment_array.append(par_response.to_json_value);
      END LOOP;
    
      v_assured_array := JSON_LIST();
      FOR vr_assured IN (SELECT *
                           FROM TABLE(pkg_personal_profile.get_assured_info) su
                          WHERE su.policy_id = vr_policy.policy_id)
      LOOP
        v_cover_array := JSON_LIST();
        FOR vr_cover IN (SELECT *
                           FROM TABLE(pkg_personal_profile.get_cover_info) pa
                          WHERE pa.as_asset_id = vr_assured.as_asset_id)
        LOOP
          par_response := JSON();
          par_response.put('p_cover_id', vr_cover.p_cover_id);
          par_response.put('date_begin', vr_cover.date_begin);
          par_response.put('date_end', vr_cover.date_end);
          par_response.put('insurance_sum', vr_cover.insurance_sum);
          par_response.put('fee', vr_cover.fee);
          par_response.put('cover_type_name', vr_cover.cover_type_name);
          par_response.put('cover_brief', vr_cover.cover_brief);
          par_response.put('payment_sign', vr_cover.payment_sign);
          par_response.put('annual', vr_cover.annual);
          par_response.put('loan', vr_cover.loan);
          par_response.put('invest_part', vr_cover.loan);
          par_response.put('net_premium_act', vr_cover.net_premium_act);
          par_response.put('delta_deposit1', vr_cover.delta_deposit1);
          par_response.put('penalty', vr_cover.penalty);
          v_cover_array.append(par_response.to_json_value);
        END LOOP;
      
        SELECT *
          INTO vr_persdata
          FROM TABLE(get_persdata_info) pi
         WHERE pi.contact_id = vr_assured.contact_id;
        v_assured_persdata := JSON();
      
        v_assured_persdata.put('doc_type_brief', vr_persdata.doc_type_brief);
        v_assured_persdata.put('doc_type_name', vr_persdata.doc_type_name);
        v_assured_persdata.put('doc_series', vr_persdata.doc_series);
        v_assured_persdata.put('doc_number', vr_persdata.doc_number);
        v_assured_persdata.put('doc_date', vr_persdata.doc_date);
        v_assured_persdata.put('doc_place', vr_persdata.doc_place);
        v_assured_persdata.put('address', vr_persdata.address);
        v_assured_persdata.put('ipdl', vr_persdata.ipdl);
        v_assured_persdata.put('rpdl', vr_persdata.rpdl);
        v_assured_persdata.put('notify', vr_persdata.notify);
        v_assured_persdata.put('refresh_needed', vr_persdata.refresh_needed);
      
        par_response := JSON();
        par_response.put('assured_id', vr_assured.contact_id);
        par_response.put('assured_name', vr_assured.assured_name);
        par_response.put('assured_birth', vr_assured.assured_birth);
      
        par_response.put('persdata', v_assured_persdata.to_json_value);
        par_response.put('covers', v_cover_array.to_json_value);
        v_assured_array.append(par_response.to_json_value);
      
      END LOOP;
      par_response := JSON();
      par_response.put('policy_id', vr_policy.policy_id);
      par_response.put('product_name', vr_policy.product_name);
      par_response.put('product_brief', vr_policy.product_brief);
      par_response.put('pol_num', vr_policy.pol_num);
      par_response.put('date_begin', vr_policy.date_begin);
      par_response.put('date_active', vr_policy.date_active);
      par_response.put('date_end', vr_policy.date_end);
      par_response.put('policy_header_id', vr_policy.policy_header_id);
      par_response.put('payment_term', vr_policy.payment_term);
      par_response.put('fund', vr_policy.fund);
      par_response.put('fund_short', vr_policy.fund_short);
      par_response.put('status', vr_policy.status);
      par_response.put('agent_id', vr_policy.agent_id);
      par_response.put('agency_id', vr_policy.agency_id);
      par_response.put('fee', vr_policy.fee);
      par_response.put('fee_index', vr_policy.fee_index);
      par_response.put('fee_index_rur', vr_policy.fee_index_rur);
      par_response.put('debt_sum', vr_policy.debt_sum);
      par_response.put('agent_name', vr_policy.agent_name);
      par_response.put('agency_name', vr_policy.agency_name);
      par_response.put('agency_address', vr_policy.agency_address);
      par_response.put('agency_phone', vr_policy.agency_phone);
      par_response.put('indexing_persent', vr_policy.indexing_persent);
      par_response.put('invest_income', vr_policy.invest_income);
      par_response.put('due_date', vr_policy.due_date);
      par_response.put('decline_date', vr_policy.decline_date);
      par_response.put('decline_reason', vr_policy.decline_reason);
      par_response.put('is_priority_invest', vr_policy.is_priority_invest);
      par_response.put('is_exists_template', vr_policy.is_exists_template);
      par_response.put('payments', v_payment_array.to_json_value);
      par_response.put('assured', v_assured_array.to_json_value);
    
      IF par_with_dicts
      THEN
        par_response.put('dictionaries', get_dict_info_json(vr_policy.policy_id));
      END IF;
      v_policy_array.append(par_response.to_json_value);
    END LOOP;
    v_insured.put('templates', v_acq_templ_array.to_json_value);
    v_insured.put('policies', v_policy_array.to_json_value);
    par_response := JSON();
    par_response.put(gc_status_elem_name, pkg_communication.gc_ok);
    par_response.put(gc_error_elem_name, to_char(NULL));
    par_response.put('userdata', v_insured.to_json_value);
    IF par_with_dicts
    THEN
      par_response.put('dictionaries', get_dict_info_json(par_only_cost => TRUE));
    END IF;
  END post_prepared_info;

  /*
    Байтин А.
    Формирование и вывод всех данных
  */
  PROCEDURE get_all_data
  (
    par_contact_id    NUMBER
   ,par_pol_header_id NUMBER DEFAULT NULL
   ,par_with_dicts    BOOLEAN DEFAULT FALSE
   ,par_demo_cabinet  BOOLEAN DEFAULT FALSE
   ,par_response      OUT JSON
  ) IS
    v_error_message VARCHAR2(200);
  BEGIN
    pkg_personal_profile.prepare_contact_info(par_contact_id => par_contact_id);
    pkg_personal_profile.prepare_policy_info(par_contact_id       => par_contact_id
                                            ,par_policy_header_id => par_pol_header_id);
    pkg_personal_profile.prepare_acq_template_info;
    pkg_personal_profile.prepare_payment_info;
    pkg_personal_profile.prepare_assured_info;
    pkg_personal_profile.prepare_cover_info(CASE WHEN par_demo_cabinet THEN 1 ELSE 0 END);
    pkg_personal_profile.prepare_persdata_info;
    post_prepared_info(par_response => par_response, par_with_dicts => par_with_dicts);
  EXCEPTION
    WHEN contact_exception THEN
      v_error_message := substr(SQLERRM, 1, 200);
      ex.raise('Ошибка получения данных контакта (' || v_error_message || ').');
    WHEN policy_exception THEN
      v_error_message := substr(SQLERRM, 1, 200);
      ex.raise('Ошибка получения данных договоров страхования (' || v_error_message || ').');
    WHEN payment_exception THEN
      v_error_message := substr(SQLERRM, 1, 200);
      ex.raise('Ошибка получения данных платежей (' || v_error_message || ').');
    WHEN cover_exception THEN
      v_error_message := substr(SQLERRM, 1, 200);
      ex.raise('Ошибка получения данных покрытий (' || v_error_message || ').');
    WHEN persdata_exception THEN
      v_error_message := substr(SQLERRM, 1, 200);
      ex.raise('Ошибка получения персональных данных (' || v_error_message || ').');
  END get_all_data;

  PROCEDURE get_all_data
  (
    par_request  JSON
   ,par_response OUT JSON
  ) IS
    v_insured_id    contact.contact_id%TYPE;
    v_pol_header_id p_pol_header.policy_header_id%TYPE;
  BEGIN
    v_insured_id    := par_request.get('insured_id').get_number;
    v_pol_header_id := par_request.get('pol_header_id').get_number;
    get_all_data(par_contact_id    => v_insured_id
                ,par_pol_header_id => v_pol_header_id
                ,par_with_dicts    => TRUE
                ,par_response      => par_response);
  END get_all_data;
  /*
    Байтин А.
    Передача страхователей
  */
  PROCEDURE send_insured
  (
    par_contact_id  NUMBER DEFAULT NULL
   ,par_send_errors BOOLEAN DEFAULT FALSE
   ,par_sent_quant  OUT NUMBER
   ,par_error       OUT VARCHAR2
  ) IS
    v_array      JSON_LIST := JSON_LIST();
    v_obj        JSON;
    v_answer     JSON;
    v_email      VARCHAR2(255);
    v_b2b_error  personal_profile_insured.sending_error%TYPE;
    v_insured_id NUMBER;
  BEGIN
    par_sent_quant := 0;
    IF par_send_errors
    THEN
      BEGIN
        SELECT pv.props_value
          INTO v_email
          FROM t_b2b_props_vals pv
              ,t_b2b_props_oper op
              ,t_b2b_props_db   db
              ,t_b2b_props_type ty
         WHERE pv.t_b2b_props_db_id = db.t_b2b_props_db_id
           AND db.db_brief = sys.database_name
           AND pv.t_b2b_props_oper_id = op.t_b2b_props_oper_id
           AND op.oper_brief = 'send_insured'
           AND pv.t_b2b_props_type_id = ty.t_b2b_props_type_id
           AND ty.type_brief = 'email';
      EXCEPTION
        WHEN no_data_found THEN
          raise_application_error(-20001
                                 ,'Не найден email для операции "send_insured"');
        WHEN too_many_rows THEN
          raise_application_error(-20001
                                 ,'Найдено несколько email для операции "send_insured"');
      END;
    END IF;
    FOR vr_logins IN (SELECT ROWID AS rid
                            ,(SELECT MAX(REPLACE(upper(ci.serial_nr || ci.id_value), ' ')) keep(dense_rank FIRST ORDER BY decode(it.description, 'Паспорт гражданина РФ', 0, 'Иностранный паспорт', 1, 'Свидетельство о рождении', 2, 'Вид на жительство', 3, 'Разрешение на временное проживание в Российской Федерации', 4, 'Удостоверение личности офицера', 5, 'Паспорт моряка', 6, 'Дипломатический паспорт гражданина РФ', 7), ci.issue_date DESC) AS pas_number
                                FROM ins.cn_contact_ident ci
                                    ,ins.t_id_type        it
                               WHERE ci.id_type = it.id
                                 AND it.description IN
                                     ('Паспорт гражданина РФ'
                                     ,'Иностранный паспорт'
                                     ,'Свидетельство о рождении'
                                     ,'Вид на жительство'
                                     ,'Разрешение на временное проживание в Российской Федерации'
                                     ,'Удостоверение личности офицера'
                                     ,'Паспорт моряка'
                                     ,'Дипломатический паспорт гражданина РФ')
                                 AND ci.issue_date IS NOT NULL
                                 AND ci.contact_id = co.contact_id) profile_login
                            ,(SELECT lower(pkg_utils.get_md5_string(MAX(to_char(ci.issue_date
                                                                               ,'dd.mm.yyyy'))
                                                                    keep(dense_rank FIRST ORDER BY
                                                                         decode(it.description
                                                                               ,'Паспорт гражданина РФ'
                                                                               ,0
                                                                               ,'Иностранный паспорт'
                                                                               ,1
                                                                               ,'Свидетельство о рождении'
                                                                               ,2
                                                                               ,'Вид на жительство'
                                                                               ,3
                                                                               ,'Разрешение на временное проживание в Российской Федерации'
                                                                               ,4
                                                                               ,'Удостоверение личности офицера'
                                                                               ,5
                                                                               ,'Паспорт моряка'
                                                                               ,6
                                                                               ,'Дипломатический паспорт гражданина РФ'
                                                                               ,7)
                                                                        ,ci.issue_date DESC))) AS pas_number
                                FROM ins.cn_contact_ident ci
                                    ,ins.t_id_type        it
                               WHERE ci.id_type = it.id
                                 AND it.description IN
                                     ('Паспорт гражданина РФ'
                                     ,'Иностранный паспорт'
                                     ,'Свидетельство о рождении'
                                     ,'Вид на жительство'
                                     ,'Разрешение на временное проживание в Российской Федерации'
                                     ,'Удостоверение личности офицера'
                                     ,'Паспорт моряка'
                                     ,'Дипломатический паспорт гражданина РФ')
                                 AND ci.issue_date IS NOT NULL
                                 AND ci.contact_id = co.contact_id) AS profile_password
                        FROM contact co
                       WHERE co.profile_login IS NULL
                         AND EXISTS
                       (SELECT NULL FROM cn_person cp WHERE cp.contact_id = co.contact_id)
                            -- Должен быть паспорт
                         AND EXISTS
                       (SELECT NULL
                                FROM ins.cn_contact_ident ci
                                    ,ins.t_id_type        it
                               WHERE ci.id_type = it.id
                                 AND it.description IN
                                     ('Паспорт гражданина РФ'
                                     ,'Иностранный паспорт'
                                     ,'Свидетельство о рождении'
                                     ,'Вид на жительство'
                                     ,'Разрешение на временное проживание в Российской Федерации'
                                     ,'Удостоверение личности офицера'
                                     ,'Паспорт моряка'
                                     ,'Дипломатический паспорт гражданина РФ')
                                 AND ci.issue_date IS NOT NULL
                                 AND ci.id_value IS NOT NULL
                                 AND ci.contact_id = co.contact_id)
                         AND co.contact_id IN
                             (SELECT pc.contact_id
                                FROM ins.p_policy_contact pc
                                    ,ins.p_pol_header     ph
                                    ,ins.p_policy         pp
                                    ,t_product            prd
                               WHERE ph.last_ver_id = pp.policy_id
                                 AND pp.policy_id = pc.policy_id
                                 AND pc.contact_policy_role_id = 6
                                 AND ph.product_id = prd.product_id
                                    -- Отбираются договоры, имеющие номера
                                 AND pp.pol_num IS NOT NULL
                                    -- Кроме ХКБ
                                 AND prd.brief NOT IN
                                     ('CR92_1', 'CR92_1.1', 'CR92_2', 'CR92_2.1', 'CR92_3', 'CR92_3.1')
                                    -- Не групповые
                                 AND pp.is_group_flag = 0
                              UNION ALL
                              SELECT su.assured_contact_id
                                FROM p_pol_header     ph
                                    ,p_policy         pp
                                    ,as_asset         se
                                    ,as_assured       su
                                    ,p_policy_contact pc
                                    ,contact          co_
                                    ,t_product        prd
                               WHERE ph.last_ver_id = pp.policy_id
                                 AND pp.pol_num IS NOT NULL
                                 AND pp.is_group_flag = 0
                                 AND pp.policy_id = se.p_policy_id
                                 AND se.as_asset_id = su.as_assured_id
                                 AND pp.policy_id = pc.policy_id
                                 AND pc.contact_policy_role_id = 6
                                 AND pc.contact_id = co_.contact_id
                                 AND co_.contact_type_id NOT IN (1, 3)
                                 AND ph.product_id = prd.product_id
                                 AND prd.brief NOT IN
                                     ('CR92_1', 'CR92_1.1', 'CR92_2', 'CR92_2.1', 'CR92_3', 'CR92_3.1')))
    LOOP
      BEGIN
        UPDATE contact co
           SET co.profile_login = vr_logins.profile_login
              ,co.profile_pass  = vr_logins.profile_password
         WHERE co.rowid = vr_logins.rid;
        par_sent_quant := par_sent_quant + 1;
      EXCEPTION
        WHEN dup_val_on_index THEN
          NULL;
      END;
    END LOOP;
  
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      par_error := SQLERRM;
      IF par_send_errors
      THEN
        IF v_email IS NOT NULL
        THEN
          pkg_email.send_mail_with_attachment(par_to      => pkg_email.t_recipients(v_email)
                                             ,par_subject => 'Ошибка при генерации паролей страхователей'
                                             ,par_text    => par_error || chr(10) || ' БД: ' ||
                                                             sys.database_name);
        ELSE
          RAISE;
        END IF;
      END IF;
  END send_insured;

  /*
    Байтин А.
    Передача в B2B данных по изменениям стратегии по продукту Инвестор
  */
  PROCEDURE get_cabinet_cover
  (
    par_request  JSON
   ,par_response OUT JSON
  ) IS
    record_locked EXCEPTION;
    PRAGMA EXCEPTION_INIT(record_locked, -54);
    v_last_policy_id NUMBER;
    v_change_id      NUMBER;
    v_contact_id     NUMBER;
    v_start_date     DATE;
    vt_add_resultset pkg_p_pol_addendum_type.t_resultset;
    --v_xml            CLOB;
    v_error_message VARCHAR2(2000);
    v_object        JSON := JSON();
    v_program_brief t_prod_line_option.brief%TYPE;
  
    v_policy_header_id p_pol_header.policy_header_id%TYPE;
    v_year_num         NUMBER;
    v_programs_array   JSON_LIST;
    v_prog_sums        pkg_borlas_b2b.t_prog_sums;
  
  BEGIN
  
    v_policy_header_id := par_request.get('header_id').get_string;
    v_year_num         := par_request.get('year_num').get_number;
    v_programs_array   := JSON_LIST(par_request.get('programs'));
  
    FOR v_idx IN 1 .. v_programs_array.count
    LOOP
      v_prog_sums(JSON(v_programs_array.get(v_idx)).get('program_brief').get_string) := JSON(v_programs_array.get(v_idx)).get('sum')
                                                                                        .get_number;
    END LOOP;
  
    -- Последняя версия и следующая годовщина
    BEGIN
      SELECT ph.policy_id
            ,ADD_MONTHS(ph.start_date, (v_year_num - 1) * 12)
        INTO v_last_policy_id
            ,v_start_date
        FROM p_pol_header ph
       WHERE ph.policy_header_id = v_policy_header_id
         FOR UPDATE OF ph.ids NOWAIT;
    EXCEPTION
      WHEN record_locked THEN
        raise_application_error(-20001
                               ,'Договор заблокирован пользователем.');
      WHEN no_data_found THEN
        raise_application_error(-20001
                               ,'Полис с ID (' || to_char(v_policy_header_id) || ') не существует.');
    END;
  
    -- Тип доп. соглашения
    BEGIN
      SELECT NULL
            ,NULL
            ,NULL
            ,NULL
            ,v_last_policy_id
            ,t.t_addendum_type_id
        BULK COLLECT
        INTO vt_add_resultset
        FROM t_addendum_type t
       WHERE t.brief IN ('CHANGE_STRATEGY_OF_THE_PREMIUM', 'INCREASE_SIZE_OF_THE_TOTAL_PREMIUM');
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20001
                               ,'Тип соглашения с кратким наименованием "CHANGE_STRATEGY_OF_THE_PREMIUM" не существует.');
    END;
  
    -- ID страхователя
    BEGIN
      SELECT pi.contact_id
        INTO v_contact_id
        FROM v_pol_issuer pi
       WHERE pi.policy_id = v_last_policy_id;
    END;
    -- Тип изменений
    BEGIN
      SELECT ct.t_policy_change_type_id
        INTO v_change_id
        FROM t_policy_change_type ct
       WHERE ct.brief = 'Основные';
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20001
                               ,'Не найден вид изменений "Основные".');
    END;
  
    -- Добавляем доп. соглашение
    pkg_p_pol_addendum_type.new_p_pol_addendum_type(vt_add_resultset);
  
    -- Создаем версию
    v_last_policy_id := pkg_policy.new_policy_version(par_policy_id             => v_last_policy_id
                                                     ,par_policy_change_type_id => v_change_id
                                                     ,par_start_date            => v_start_date);
    -- Меняем соотвествующим покрытиям суммы
    v_program_brief := v_prog_sums.first;
    WHILE v_program_brief IS NOT NULL
    LOOP
    
      UPDATE p_cover pc
         SET pc.fee = v_prog_sums(v_program_brief)
       WHERE pc.t_prod_line_option_id IN
             (SELECT plo.id
                FROM t_prod_line_option plo
               WHERE plo.id = pc.t_prod_line_option_id
                 AND plo.brief = v_program_brief)
         AND pc.as_asset_id IN
             (SELECT se.as_asset_id FROM as_asset se WHERE se.p_policy_id = v_last_policy_id);
    
      v_program_brief := v_prog_sums.next(v_program_brief);
    END LOOP;
  
    -- Проверка отключена
    --pkg_change_anniversary.check_investor(v_last_policy_id);
    -- Изменение стратегии
    pkg_change_anniversary.increase_size_total_premium(v_last_policy_id);
    UPDATE p_pol_header ph
       SET ph.policy_id = v_last_policy_id
     WHERE ph.policy_header_id = v_policy_header_id;
    -- Формирование ответа
    get_all_data(par_contact_id    => v_contact_id
                ,par_pol_header_id => v_policy_header_id
                ,par_with_dicts    => TRUE
                ,par_response      => par_response);
    -- Откат изменений
    ROLLBACK;
  END get_cabinet_cover;

  /*
    Байтин А.
    Проверка пароля
  */
  PROCEDURE check_password
  (
    par_request  JSON
   ,par_response OUT JSON
  ) IS
    v_login    contact.profile_login%TYPE;
    v_password contact.profile_pass%TYPE;
  
    v_profile_pass contact.profile_pass%TYPE;
    v_insured_id   contact.contact_id%TYPE;
  BEGIN
    v_login    := par_request.get('login').get_string;
    v_password := par_request.get('password').get_string;
    BEGIN
      IF v_login IS NOT NULL
         AND v_password IS NOT NULL
      THEN
        -- Ищем контакт
        SELECT co.profile_pass
              ,co.contact_id
          INTO v_profile_pass
              ,v_insured_id
          FROM contact co
         WHERE co.profile_login = v_login;
      
        IF v_password = v_profile_pass
        THEN
          get_all_data(par_contact_id => v_insured_id
                      ,par_with_dicts => TRUE
                      ,par_response   => par_response);
        ELSE
          ex.raise('Неверно указан пароль');
        END IF;
      ELSIF v_login IS NULL
      THEN
        ex.raise('Отсутствует логин');
      ELSE
        ex.raise('Отсутствует пароль');
      END IF;
    EXCEPTION
      WHEN no_data_found THEN
        ex.raise('Контакт с полученным логином, не найден');
    END;
  END check_password;

  PROCEDURE reset_password
  (
    par_contact_id   NUMBER
   ,par_is_from_http BOOLEAN DEFAULT TRUE
  ) IS
    v_is_exists NUMBER(1);
  BEGIN
    SELECT COUNT(1) INTO v_is_exists FROM contact co WHERE co.contact_id = par_contact_id;
  
    -- Если контакт есть, обновляем
    IF v_is_exists = 1
    THEN
      UPDATE contact co
         SET co.profile_pass =
             (SELECT lower(pkg_utils.get_md5_string(MAX(to_char(ci.issue_date, 'dd.mm.yyyy'))
                                                    keep(dense_rank FIRST ORDER BY decode(it.description
                                                               ,'Паспорт гражданина РФ'
                                                               ,0
                                                               ,'Иностранный паспорт'
                                                               ,1
                                                               ,'Свидетельство о рождении'
                                                               ,2
                                                               ,'Вид на жительство'
                                                               ,3
                                                               ,'Разрешение на временное проживание в Российской Федерации'
                                                               ,4
                                                               ,'Удостоверение личности офицера'
                                                               ,5
                                                               ,'Паспорт моряка'
                                                               ,6
                                                               ,'Дипломатический паспорт гражданина РФ'
                                                               ,7)
                                                        ,ci.issue_date DESC))) AS pas_number
                FROM ins.cn_contact_ident ci
                    ,ins.t_id_type        it
               WHERE ci.id_type = it.id
                 AND it.description IN ('Паспорт гражданина РФ'
                                       ,'Иностранный паспорт'
                                       ,'Свидетельство о рождении'
                                       ,'Вид на жительство'
                                       ,'Разрешение на временное проживание в Российской Федерации'
                                       ,'Удостоверение личности офицера'
                                       ,'Паспорт моряка'
                                       ,'Дипломатический паспорт гражданина РФ')
                 AND ci.issue_date IS NOT NULL
                 AND ci.contact_id = co.contact_id)
       WHERE co.contact_id = par_contact_id
         AND EXISTS
       (SELECT NULL
                FROM ins.cn_contact_ident ci
                    ,ins.t_id_type        it
               WHERE ci.id_type = it.id
                 AND it.description IN ('Паспорт гражданина РФ'
                                       ,'Иностранный паспорт'
                                       ,'Свидетельство о рождении'
                                       ,'Вид на жительство'
                                       ,'Разрешение на временное проживание в Российской Федерации'
                                       ,'Удостоверение личности офицера'
                                       ,'Паспорт моряка'
                                       ,'Дипломатический паспорт гражданина РФ')
                 AND ci.issue_date IS NOT NULL
                 AND ci.contact_id = co.contact_id);
      IF SQL%ROWCOUNT = 0
      THEN
        ex.raise('Не найден документ для формирования пароля');
      END IF;
    ELSE
      ex.raise('Не найден контакт с таким insured_id');
    END IF;
  END reset_password;

  PROCEDURE reset_password
  (
    par_request  JSON
   ,par_response OUT JSON
  ) IS
    v_contact_id    contact.contact_id%TYPE;
    v_error_code    NUMBER(2) := 0;
    v_error_message VARCHAR2(50);
    v_obj           JSON := JSON();
    v_login         contact.profile_login%TYPE;
  BEGIN
    v_login := par_request.get('login').get_string;
    BEGIN
      SELECT co.contact_id INTO v_contact_id FROM contact co WHERE co.profile_login = v_login;
      reset_password(par_contact_id => v_contact_id);
      par_response := JSON();
      par_response.put(gc_status_elem_name, pkg_communication.gc_ok);
      par_response.put(gc_error_elem_name, to_char(NULL));
    EXCEPTION
      WHEN no_data_found THEN
        ex.raise('Контакт с полученным логином, не найден');
    END;
  END;

  /*
    Байтин А.
    Добавление/изменение электронной почты и/или пароля
  */
  PROCEDURE set_email_and_pass
  (
    par_request  JSON
   ,par_response OUT JSON
  ) IS
    v_obj           JSON := JSON();
    v_error_message VARCHAR2(50);
    v_email_id      NUMBER;
    v_is_exists     NUMBER(1);
  
    v_insured_id   NUMBER;
    v_new_email    cn_contact_email.email%TYPE;
    v_new_password contact.profile_pass%TYPE;
  BEGIN
    v_insured_id := par_request.get('insured_id').get_number;
    IF par_request.exist('email')
    THEN
      v_new_email := par_request.get('email').get_string;
    END IF;
    IF par_request.exist('password')
    THEN
      v_new_password := par_request.get('password').get_string;
    END IF;
    IF v_insured_id IS NOT NULL
       AND (v_new_email IS NOT NULL OR v_new_password IS NOT NULL)
    THEN
      IF v_new_password IS NOT NULL
      THEN
        UPDATE contact co SET co.profile_pass = v_new_password WHERE co.contact_id = v_insured_id;
      
        IF SQL%ROWCOUNT = 0
        THEN
          ex.raise('Не найден контакт с таким insured_id');
        END IF;
      END IF;
      IF v_new_email IS NOT NULL
      THEN
        SELECT COUNT(1) INTO v_is_exists FROM contact co WHERE co.contact_id = v_insured_id;
        IF v_is_exists = 1
        THEN
          UPDATE cn_contact_email ce
             SET ce.email = v_new_email
           WHERE ce.contact_id = v_insured_id
             AND ce.email_type IN
                 (SELECT et.id FROM t_email_type et WHERE et.description = 'Адрес ЛК');
          IF SQL%ROWCOUNT = 0
          THEN
            BEGIN
              v_email_id := pkg_contact.insert_email(par_contact_id  => v_insured_id
                                                    ,par_email       => v_new_email
                                                    ,par_email_type  => 'Адрес ЛК'
                                                    ,par_field_count => 0
                                                    ,par_status      => 1);
            EXCEPTION
              WHEN OTHERS THEN
                ex.raise('Email не добавлен, т.к. не был найден тип адреса: "Адрес ЛК"');
            END;
          END IF;
        ELSE
          ex.raise('Не найден контакт с таким insured_id');
        END IF;
      END IF;
    ELSE
      ex.raise('Не указан insured_id или email или password');
    END IF;
    par_response := JSON();
    par_response.put(gc_status_elem_name, pkg_communication.gc_ok);
    par_response.put(gc_error_elem_name, to_char(NULL));
  END set_email_and_pass;

  /*
    Байтин А.
    Создание ДС для демо-кабинета
  */
  PROCEDURE calc_demo_policy
  (
    par_request  JSON
   ,par_response OUT JSON
  ) IS
    v_start_date     DATE := trunc(SYSDATE);
    vr_assured_array pkg_asset.t_assured_array := pkg_asset.t_assured_array();
    v_pol_header_id  NUMBER;
    v_policy_id      NUMBER;
    v_fund_id        NUMBER;
    v_period_id      NUMBER;
    v_program_brief  t_prod_line_option.brief%TYPE;
    v_idx            NUMBER(3) := 0;
    v_error_message  VARCHAR2(200);
    v_array          JSON_LIST;
    v_product_brief  t_product.brief%TYPE;
    v_fund           fund.brief%TYPE;
    v_period         t_period.period_value%TYPE;
    v_prog_sums      pkg_borlas_b2b.t_prog_sums;
    v_ag_num         document.num%TYPE := '001784';
  
    vc_insured_id CONSTANT NUMBER := 214247; -- Test Test Test
  BEGIN
    v_product_brief := par_request.get('product').get_string;
    v_fund          := par_request.get('fund').get_string;
    v_period        := par_request.get('policy_period').get_number;
    v_array         := JSON_LIST(par_request.get('programs'));
  
    IF par_request.exist('ag_num')
    THEN
      v_ag_num := par_request.get('ag_num').get_string;
    END IF;
  
    FOR v_idx IN 1 .. v_array.count
    LOOP
      v_prog_sums(JSON(v_array.get(v_idx)).get('program_brief').get_string) := JSON(v_array.get(v_idx)).get('sum')
                                                                               .get_number;
    END LOOP;
  
    -- Обновляем возраст контакту
    UPDATE cn_person cp
       SET cp.date_of_birth = ADD_MONTHS(trunc(SYSDATE), -12 * 20)
          ,cp.gender        = 1 -- М
     WHERE cp.contact_id = vc_insured_id;
  
    -- Данные по застрахованному
    vr_assured_array.extend(1);
    vr_assured_array(1).contact_id := vc_insured_id;
  
    vr_assured_array(1).assured_type_brief := 'ASSET_PERSON';
  
    vr_assured_array(1).cover_array := pkg_cover.t_cover_array();
    vr_assured_array(1).cover_array.extend(v_prog_sums.count);
  
    -- Данные по программам
    v_program_brief := v_prog_sums.first;
    WHILE v_program_brief IS NOT NULL
    LOOP
      v_idx := v_idx + 1;
    
      vr_assured_array(1).cover_array(v_idx).t_prod_line_opt_brief := v_program_brief;
      vr_assured_array(1).cover_array(v_idx).fee := v_prog_sums(v_program_brief);
      vr_assured_array(1).cover_array(v_idx).exclude := 0;
      vr_assured_array(1).cover_array(v_idx).premia_base_type := 1;
      vr_assured_array(1).cover_array(v_idx).is_handchange_fee := 1;
    
      v_program_brief := v_prog_sums.next(v_program_brief);
    END LOOP;
  
    BEGIN
      SELECT fd.fund_id INTO v_fund_id FROM fund fd WHERE fd.brief = v_fund;
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20001
                               ,'Не найдена валюта с кратким названием "' || v_fund || '"');
    END;
  
    BEGIN
      SELECT pp.period_id
        INTO v_period_id
        FROM t_product        pr
            ,t_product_period pp
            ,t_period         pd
            ,t_period_type    pt
       WHERE pr.brief = v_product_brief
         AND pp.product_id = pr.product_id
         AND pp.t_period_use_type_id = 1 /*Срок страхования*/
         AND pp.period_id = pd.id
         AND pd.period_type_id = pt.id
         AND pd.period_value = v_period
         AND pt.brief = 'Y';
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20001
                               ,'Не найден срок страхования для "' || to_number(v_period) || '" лет');
    END;
  
    -- Создаем договор
    pkg_policy.create_universal(par_product_brief      => v_product_brief
                               ,par_ag_num             => nvl(v_ag_num, '001784')
                               ,par_pol_num            => 'DEMO_CAB_POLICY'
                               ,par_start_date         => v_start_date
                               ,par_end_date           => NULL
                               ,par_insuree_contact_id => vc_insured_id
                               ,par_bso_number         => NULL
                               ,par_assured_array      => vr_assured_array
                               ,par_fund_id            => v_fund_id
                               ,par_period_id          => v_period_id
                               ,par_policy_header_id   => v_pol_header_id
                               ,par_policy_id          => v_policy_id);
    -- Возврат всех данных
    pkg_personal_profile.get_all_data(par_contact_id    => vc_insured_id
                                     ,par_pol_header_id => v_pol_header_id
                                     ,par_with_dicts    => TRUE
                                     ,par_demo_cabinet  => TRUE
                                     ,par_response      => par_response);
    ROLLBACK;
  END calc_demo_policy;

  /*
    Подтверждение флагов ИПДЛ/РПДЛ
  */
  PROCEDURE confirm_public_flags
  (
    par_request  JSON
   ,par_response OUT JSON
  ) IS
    vr_flags dml_cn_profile_public.tt_cn_profile_public;
  BEGIN
    vr_flags.contact_id                := par_request.get('insured_id').get_number;
    vr_flags.is_foreign_public_contact := par_request.get('ipdl').get_number;
    vr_flags.is_russian_public_contact := par_request.get('rpdl').get_number;
  
    dml_cn_profile_public.insert_record(par_record => vr_flags);
  
    par_response := JSON();
    par_response.put(gc_status_elem_name, pkg_communication.gc_ok);
    par_response.put(gc_error_elem_name, '');
  END confirm_public_flags;

  /*
    Подтверждение ФИО
  */
  PROCEDURE confirm_names
  (
    par_request  JSON
   ,par_response OUT JSON
  ) IS
    vr_names dml_cn_profile_name.tt_cn_profile_name;
  BEGIN
    par_response         := JSON();
    vr_names.contact_id  := to_number(par_request.get('insured_id').get_string);
    vr_names.last_name   := par_request.get('last_name').get_string;
    vr_names.first_name  := par_request.get('first_name').get_string;
    vr_names.middle_name := par_request.get('middle_name').get_string;
  
    dml_cn_profile_name.insert_record(par_record => vr_names);
  
    par_response.put(gc_status_elem_name, 'OK');
    par_response.put(gc_error_elem_name, '');
  END confirm_names;

  /*
    Подтверждение идентифицирующих документов
  */
  PROCEDURE confirm_documents
  (
    par_request  JSON
   ,par_response OUT JSON
  ) IS
    vr_docs          dml_cn_profile_doc.tt_cn_profile_doc;
    v_doc_type_brief t_id_type.brief%TYPE;
  BEGIN
    par_response         := JSON();
    vr_docs.contact_id   := par_request.get('insured_id').get_number;
    v_doc_type_brief     := par_request.get('doc_type').get_string;
    vr_docs.t_id_type_id := dml_t_id_type.get_id_by_brief(par_brief => v_doc_type_brief);
    vr_docs.doc_series   := par_request.get('doc_series').get_string;
    vr_docs.doc_number   := par_request.get('doc_number').get_string;
    vr_docs.doc_who      := par_request.get('doc_place').get_string;
    vr_docs.doc_when     := to_date(par_request.get('doc_date').get_string, 'dd.mm.yyyy');
  
    dml_cn_profile_doc.insert_record(par_record => vr_docs);
  
    par_response.put(gc_status_elem_name, pkg_communication.gc_ok);
    par_response.put(gc_error_elem_name, '');
  END confirm_documents;

  /*
    Подтверждение адреса
  */
  PROCEDURE confirm_address
  (
    par_request  JSON
   ,par_response OUT JSON
  ) IS
    vr_address       dml_cn_profile_address.tt_cn_profile_address;
    v_doc_type_brief t_id_type.brief%TYPE;
  BEGIN
    par_response          := JSON();
    vr_address.contact_id := par_request.get('insured_id').get_number;
    vr_address.address    := par_request.get('address').get_string;
  
    dml_cn_profile_address.insert_record(par_record => vr_address);
  
    par_response.put(gc_status_elem_name, pkg_communication.gc_ok);
    par_response.put(gc_error_elem_name, '');
  END confirm_address;

  /*
    Подтверждение актуальности
  */
  PROCEDURE confirm_actuality
  (
    par_request  JSON
   ,par_response OUT JSON
  ) IS
    v_contact_id contact.contact_id%TYPE;
  BEGIN
    par_response := JSON();
    v_contact_id := par_request.get('insured_id').get_number;
  
    UPDATE cn_person cp
       SET cp.last_update_date = trunc(SYSDATE, 'dd')
     WHERE cp.contact_id = v_contact_id;
  
    IF SQL%ROWCOUNT = 0
    THEN
      par_response.put(gc_status_elem_name, pkg_communication.gc_error);
      par_response.put(gc_error_elem_name, 'Не найден контакт по ID');
    ELSE
      par_response.put(gc_status_elem_name, pkg_communication.gc_ok);
      par_response.put(gc_error_elem_name, '');
    END IF;
  END confirm_actuality;

  /*
    Для первой версии договора страхования поле «Дата последнего обновления» Контакта
    страхователя и застрахованного принимает значение текущей даты при
    следующих переходах статусов:
      из статуса «Проект» в статус «Новый»;
      из статуса «Проект» в статус «Передано агенту»;
      из статуса «Ожидает оплаты» в статус «Передано агенту»
      из статуса «Ожидает подтверждение из B2B»  в статус «Передано агенту»
  */
  PROCEDURE actualize_last_update_date(par_policy_id p_policy.policy_id%TYPE) IS
    v_current_date      cn_person.last_update_date%TYPE := trunc(SYSDATE, 'dd');
    v_issuer_contact_id contact.contact_id%TYPE;
    PROCEDURE actualize_contact
    (
      par_contact_id cn_person.contact_id%TYPE
     ,v_current_date cn_person.last_update_date%TYPE
    ) IS
    BEGIN
      UPDATE cn_person cp
         SET cp.last_update_date = v_current_date
       WHERE cp.contact_id = par_contact_id;
    END actualize_contact;
  
    FUNCTION get_issuer_contact_id(par_policy_id p_policy.policy_id%TYPE)
      RETURN cn_person.contact_id%TYPE IS
      v_contact_id cn_person.contact_id%TYPE;
    BEGIN
      BEGIN
        SELECT pi.contact_id
          INTO v_contact_id
          FROM v_pol_issuer pi
         WHERE pi.policy_id = par_policy_id;
      EXCEPTION
        WHEN no_data_found
             OR too_many_rows THEN
          NULL;
      END;
      RETURN v_contact_id;
    END get_issuer_contact_id;
  
    FUNCTION is_first_version(par_policy_id p_policy.policy_id%TYPE) RETURN BOOLEAN IS
      v_version_num p_policy.version_num%TYPE;
    BEGIN
      BEGIN
        SELECT pp.version_num
          INTO v_version_num
          FROM p_policy pp
         WHERE pp.policy_id = par_policy_id
           AND pp.is_group_flag = 0;
      EXCEPTION
        WHEN no_data_found THEN
          NULL;
      END;
      RETURN v_version_num = 1;
    END is_first_version;
  BEGIN
    -- Проверяем номер версии
    IF is_first_version(par_policy_id)
    THEN
      -- Актуализируем для страхователя
      v_issuer_contact_id := get_issuer_contact_id(par_policy_id);
      IF v_issuer_contact_id IS NOT NULL
      THEN
        actualize_contact(v_issuer_contact_id, v_current_date);
        -- Актуализируем для застрахованных, кроме являющихся страхователями
        FOR vr_ass IN (SELECT su.assured_contact_id
                         FROM as_asset   se
                             ,as_assured su
                        WHERE se.p_policy_id = par_policy_id
                          AND se.as_asset_id = su.as_assured_id
                          AND su.assured_contact_id != v_issuer_contact_id)
        LOOP
          actualize_contact(vr_ass.assured_contact_id, v_current_date);
        END LOOP;
      END IF;
    END IF;
  END actualize_last_update_date;

  /*
    Пиядин А.
    329219 Обновление информации о БСО на сайте компании
  */
  PROCEDURE bso_check
  (
    par_request  IN JSON
   ,par_response OUT JSON
  ) IS
  
    /* Локальные переменные */
    v_bso_str  VARCHAR2(1000);
    v_bso_num  NUMBER := NULL;
    v_bso_ser  NUMBER := NULL;
    v_data     JSON := JSON();
    v_response JSON := JSON();
    v_bso_list JSON_LIST := JSON_LIST();
  
    e_bso_not_found    EXCEPTION;
    e_bso_wrong_format EXCEPTION;
  
    PRAGMA EXCEPTION_INIT(e_bso_not_found, -20001);
    PRAGMA EXCEPTION_INIT(e_bso_wrong_format, -20002);
  
    /*
      Функция проверки формата поступившего на вход БСО
    */
    FUNCTION check_format(par_bso VARCHAR2) RETURN BOOLEAN IS
      v_result NUMBER;
    BEGIN
      v_result := to_number(par_bso);
    
      IF length(par_bso) NOT IN (6, 7, 9, 10)
      THEN
        RETURN FALSE;
      ELSE
        RETURN TRUE;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        RETURN FALSE;
    END check_format;
  
  BEGIN
    par_response := NULL;
    v_bso_str    := par_request.get('bso').get_string;
  
    -- Проверка формата поступившего БСО
    IF NOT check_format(v_bso_str)
    THEN
      RAISE e_bso_wrong_format;
    END IF;
  
    -- Получение серии/номера
    IF length(v_bso_str) IN (9, 10)
    THEN
      v_bso_ser := to_number(substr(v_bso_str, 1, 3));
      v_bso_num := to_number(substr(v_bso_str, 4, 7));
    ELSE
      v_bso_num := to_number(v_bso_str);
    END IF;
  
    -- Формирование ответа
    FOR cur_bso_list IN (SELECT bt.name         typ
                               ,b.num           numb
                               ,bs.series_num   series
                               ,bh.hist_date    dt
                               ,bht.name        status
                               ,c.obj_name_orig agnt
                           FROM bso           b
                               ,bso_series    bs
                               ,bso_type      bt
                               ,bso_hist      bh
                               ,bso_hist_type bht
                               ,contact       c
                          WHERE 1 = 1
                            AND b.bso_series_id = bs.bso_series_id
                            AND bs.bso_type_id = bt.bso_type_id
                            AND b.bso_hist_id = bh.bso_hist_id
                            AND bh.hist_type_id = bht.bso_hist_type_id
                            AND b.contact_id = c.contact_id(+)
                            AND b.num = v_bso_num
                            AND bs.series_num = nvl(v_bso_ser, bs.series_num))
    LOOP
      DECLARE
        v_bso_json JSON := JSON();
      BEGIN
        v_bso_json.put('type', cur_bso_list.typ);
        v_bso_json.put('number', cur_bso_list.numb);
        v_bso_json.put('series', cur_bso_list.series);
        v_bso_json.put('date', cur_bso_list.dt);
        v_bso_json.put('status', cur_bso_list.status);
        v_bso_json.put('agent', cur_bso_list.agnt);
        v_bso_list.append(v_bso_json.to_json_value);
      END;
    END LOOP;
  
    IF v_bso_list.count = 0
    THEN
      RAISE e_bso_not_found;
    END IF;
  
    v_data.put('bso', v_bso_list);
    v_response.put(gc_status_elem_name, pkg_communication.gc_ok);
    v_response.put('data', v_data);
    par_response := v_response;
  
  EXCEPTION
    WHEN e_bso_not_found THEN
      v_response.put(gc_status_elem_name, pkg_communication.gc_error);
      v_response.put(gc_error_elem_name
                    ,'БСО с указанным номером не найден');
      v_response.put('data', '');
      par_response := v_response;
    WHEN e_bso_wrong_format THEN
      v_response.put(gc_status_elem_name, pkg_communication.gc_error);
      v_response.put(gc_error_elem_name
                    ,'Допустимое количество символов в номере БСО: 6, 7, 9 или 10');
      v_response.put('data', '');
      par_response := v_response;
  END bso_check;

END pkg_personal_profile;
/

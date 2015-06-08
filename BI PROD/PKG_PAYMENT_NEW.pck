CREATE OR REPLACE PACKAGE "PKG_PAYMENT_NEW" IS

  /**
  * Работа с платежами: планирование взносов, выплат; зачет (взаимозачет) платежей
  * @author  : Sergeev D.
  * @version 1.0
  * @since 1.0
  */

  --Содержимое платежа и информации по зачету содержимого
  TYPE t_paym_cont IS RECORD(
     ac_payment_id             NUMBER
    , -- ид платежа
    obj_ure_id                NUMBER
    , -- объект учета
    obj_uro_id                NUMBER
    , -- объект учета
    acc_fund_id               NUMBER
    , -- валюта счета
    trans_fund_id             NUMBER
    , -- валюта проводки
    acc_amount                NUMBER
    , -- сумма содержимого в валюте счета
    trans_amount              NUMBER
    , -- сумма содержимого в валюте проводки
    dso_acc_amount            NUMBER
    , -- сумма зачета в валюте
    dso_trans_amount          NUMBER
    , -- сумма зачета в базовой валюте
    no_dso_acc_amount         NUMBER
    , -- незачтенная сумма в валюте
    no_dso_trans_amount       NUMBER
    , -- незачтенная сумма в базовой валюте
    total_no_dso_acc_amount   NUMBER
    , -- незачтенная сумма всего в валюте
    total_no_dso_trans_amount NUMBER
    , -- незачтенная сумма всего в базовой валюте
    count_cont                NUMBER); -- количество записей в содержимом

  --Курсор, возвращающий содержимое платежа
  TYPE t_paym_cont_cur IS REF CURSOR RETURN t_paym_cont;

  --Запись о сумме
  TYPE t_amount IS RECORD(
     fund_amount     NUMBER
    , --Сумма в валюте ответственности
    pay_fund_amount NUMBER --Сумма в валюте зачета
    );

  --Счета расчетов бухгалтерии страхования
  v_contact_acc_id      NUMBER; -- 77.01.01 Расчёты со страхователями по премиям
  v_charge_acc_id       NUMBER; -- 92.01    Страховые премии по договорам прямого страхования
  v_pay_acc_id          NUMBER; -- 77.01.02 Расчёты со страхователями по премиям по выставленным счетам
  v_repay_charge_acc_id NUMBER; -- 77.08.01 Расчёты со страхователями по возвратам премий
  v_ret_acc_id          NUMBER; --77.08.02 Выплата возвратов
  v_ag_acc_id           NUMBER; -- 77.08.01 Расчёты со страхователями по возвратам премий
  v_ag_com_acc_id       NUMBER; -- 77.08.01 Расчёты со страхователями по возвратам премий
  v_advance_pay_acc_id  NUMBER; -- 77.01.03 Расчёты со страхователями по премиям по выставленным счетам(транзитный)

  --Шаблоны операций
  v_charge_oper_templ_id         NUMBER; --Шаблон операции "Премия начислена"
  v_repay_charge_oper_templ_id   NUMBER; --Шаблон операции "Возврат премии начислен"
  v_dop_charge_oper_templ_id     NUMBER; --шаблон операции "Возврат доп дохода"
  v_surr_charge_oper_templ_id    NUMBER; --шаблон операции "Возврат выкупной"
  v_msfo_charge_oper_id          NUMBER; --Шаблон операции "Премия начислена по МСФО"
  v_msfo_comm_oper_id            NUMBER; --Шаблон операции "Вознаграждение агенту начислено по МСФО"
  v_msfo_ape_oper_id             NUMBER; --Шаблон операции "Премия начислена APE по МСФО"
  v_surr_charge_oper_fo_templ_id NUMBER; --Шаблон операции  "!Начислена выкупная сумма по Фин.Каникулам"
  v_prem_to_pay_plan_oper_id     NUMBER;
  v_vzch_oper_id                 NUMBER; --Шаблон операции "Возврат премии выплачен взаимозачетом"
  v_rsbu_stnachprem_templ_id     NUMBER;
  v_prem_paid_oper_id            NUMBER; -- Шаблон операции "Страховая премия оплачена"

  v_closed_period_exception_id NUMBER := -20150;
  v_closed_period_exception EXCEPTION;
  PRAGMA EXCEPTION_INIT(v_closed_period_exception, -20150);

  PROCEDURE calc_fee_delta
  (
    p_pol_id         NUMBER
   ,p_due_date       DATE
   ,p_return_sum     OUT NUMBER
   ,p_paym_sum       OUT NUMBER
   ,p_adm_cost       NUMBER DEFAULT 0
   ,p_is_period      NUMBER DEFAULT 1
   ,p_start_per_date DATE DEFAULT NULL
   ,p_end_per_date   DATE DEFAULT NULL
  );

  /**
  * Создание платежного документа по шаблону
  * @author Sergeev D.
  * @param p_payment_templ_id ИД шаблона платежа
  * @param p_payment_terms_id ИД условия рассрочки
  * @param p_number номер платежа
  * @param p_date дата документа
  * @param p_grace_date срок платежа
  * @param p_amount сумма счета
  * @param p_fund_id ИД валюты счета
  * @param p_rev_amount сумма оплаты
  * @param p_rev_fund_id ИД валюты оплаты
  * @param p_rev_rate_type_id ИД типа курса пересчета
  * @param p_rev_rate курс пересчета
  * @param p_contact_id ИД плательщика-получателя
  * @param p_contact_bank_acc_id ИД банковского реквизита плательщика-получателя
  * @param p_company_bank_acc_id ИД банковского реквизита компании
  * @param p_note примечание документа
  * @param p_primary_doc_id ИД исходного документа
  * @return ИД платежного документа
  */
  FUNCTION create_paymnt_by_templ
  (
    p_payment_templ_id    VARCHAR2
   ,p_payment_terms_id    NUMBER
   ,p_number              VARCHAR2
   ,p_date                DATE
   ,p_grace_date          DATE
   ,p_amount              NUMBER
   ,p_fund_id             NUMBER
   ,p_rev_amount          NUMBER
   ,p_rev_fund_id         NUMBER
   ,p_rev_rate_type_id    NUMBER
   ,p_rev_rate            NUMBER
   ,p_contact_id          NUMBER
   ,p_contact_bank_acc_id NUMBER DEFAULT NULL
   ,p_company_bank_acc_id NUMBER DEFAULT NULL
   ,p_note                VARCHAR2
   ,p_primary_doc_id      NUMBER DEFAULT NULL
   ,p_plan_date           DATE DEFAULT NULL
  ) RETURN NUMBER;

  /**
  * Создание плана-графика платежей
  * @author Sergeev D.
  * @param p_payment_templ_brief сокращение шаблона платежа
  * @param p_payment_terms_id ИД условия рассрочки
  * @param p_total_amount общая сумма по плану-графику
  * @param p_fund_id ИД валюты
  * @param p_rev_fund_id ИД валюты
  * @param p_rev_rate_type_id ИД типа курса пересчета
  * @param p_rev_rate курс пересчета
  * @param p_contact_id ИД плательщика-получателя
  * @param p_contact_bank_acc_id ИД банковского реквизита плательщика-получателя
  * @param p_company_bank_acc_id ИД банковского реквизита компании
  * @param p_first_date дата первого платежа
  * @param p_primary_doc_id ИД исходного документа
  * @param p_fee_payment_term Срок рассрочки платежа
  */
  PROCEDURE create_paymnt_sheduler
  (
    p_payment_templ_id    NUMBER
   ,p_payment_terms_id    NUMBER
   ,p_total_amount        NUMBER
   ,p_fund_id             NUMBER
   ,p_rev_fund_id         NUMBER
   ,p_rev_rate_type_id    NUMBER
   ,p_rev_rate            NUMBER
   ,p_contact_id          NUMBER
   ,p_contact_bank_acc_id NUMBER DEFAULT NULL
   ,p_company_bank_acc_id NUMBER DEFAULT NULL
   ,p_first_date          DATE DEFAULT SYSDATE
   ,p_primary_doc_id      NUMBER DEFAULT NULL
   ,p_fee_payment_term    NUMBER DEFAULT 1
  );

  /**
  * Процедура смены статуса документа "Счет на оплату взносов"
  * @author Sergeev D.
  * @param doc_id ИД платежного документа
  */
  PROCEDURE set_invoice_to_pay(doc_id IN NUMBER);

  /**
  * Процедура смены статуса нескольких видов платежных документов
  * @author Sergeev D.
  * @param doc_id ИД платежного документа
  */
  PROCEDURE set_payment_status(doc_id IN NUMBER);

  /**
  * Процедура смены статуса фактического платежного документа
  * @author Sergeev D.
  * @param doc_id ИД платежного документа
  */
  PROCEDURE set_money_doc_status(p_doc_id IN NUMBER);

  /**
  * Процедура смены статуса квитанции ф.А7
  * @author Sergeev D.
  * @param doc_id ИД платежного документа
  */
  PROCEDURE set_a7_doc_status(p_doc_id IN NUMBER);

  /**
  * Процедура смены статуса акта выполненных работ ДМС
  * @author Sergeev D.
  * @param doc_id ИД акта ДМС
  */
  PROCEDURE set_dms_act_status(p_doc_id IN NUMBER);

  /**
  * Процедура смены статуса акта выполненных работ агента
  * @author Sergeev D.
  * @param doc_id ИД акта выполненных работ агента
  */
  PROCEDURE set_agent_report_status(doc_id IN NUMBER);

  /**
  * Получить оплаченную сумму по выставленному счету
  * @author Sergeev D.
  * @param bill_doc_id ИД выставленного счета
  * @param set_off_doc_id ИД текущего документа по зачету
  * @return Оплаченная сумма
  */
  FUNCTION get_bill_set_off_amount
  (
    bill_doc_id    IN NUMBER
   ,set_off_doc_id IN NUMBER
  ) RETURN NUMBER;

  /**
  * Получить оплаченную сумму по выставленному счету в рамках одного договора страхования
  * @author Sergeev D.
  * @param bill_doc_id ИД выставленного счета
  * @param p_pol_header_id ИД заголовка договора страхования
  * @param set_off_doc_id ИД текущего документа по зачету
  * @return Оплаченная сумма
  */
  FUNCTION get_part_set_off_amount
  (
    bill_doc_id     IN NUMBER
   ,p_pol_header_id IN NUMBER
   ,set_off_doc_id  IN NUMBER
  ) RETURN NUMBER;

  /**
  * Получить зачтенную сумму по платежному/кассовому документу
  * @author Sergeev D.
  * @param paym_doc_id ИД платежного/кассового документа
  * @param set_off_doc_id ИД текущего документа по зачету
  * @return Зачтенная сумма
  */
  FUNCTION get_paym_set_off_amount
  (
    paym_doc_id    IN NUMBER
   ,set_off_doc_id IN NUMBER
  ) RETURN NUMBER;

  /**
  * Получить зачтенную сумму вознаграждения агента по платежному/кассовому документу
  * @author Sergeev D.
  * @param paym_doc_id ИД платежного/кассового документа
  * @param set_off_doc_id ИД текущего документа по зачету
  * @return Зачтенная сумма
  */
  FUNCTION get_comm_set_off_amount
  (
    paym_doc_id    IN NUMBER
   ,set_off_doc_id IN NUMBER
  ) RETURN NUMBER;

  /**
  * Получить оплаченную сумму по покрытию за период
  * @author Ivanov D.
  * @param p_start_date Дата начала периода
  * @param p_end_date Дата окончания периода
  * @param p_p_cover_id ИД покрытия
  * @return Запись типа t_amount, содержащую значения в валюте ответсвенности и в валюте зачета
  */
  FUNCTION get_pay_cover_amount
  (
    p_start_date DATE
   ,p_end_date   DATE
   ,p_p_cover_id NUMBER
  ) RETURN t_amount;

  /**
  * Получить оплаченную сумму по покрытию за период
  * @author Ivanov D.
  * @param p_start_date Дата начала периода
  * @param p_end_date Дата окончания периода
  * @param p_p_cover_id ИД покрытия
  * @return Оплаченная сумма по покрыти
  */
  FUNCTION get_pay_cover_amount_pfa
  (
    p_start_date DATE
   ,p_end_date   DATE
   ,p_p_cover_id NUMBER
  ) RETURN NUMBER;

  FUNCTION get_pay_cover_amount_epg
  (
    p_start_date DATE
   ,p_end_date   DATE
   ,p_p_cover_id NUMBER
  ) RETURN NUMBER;

  /**
  * Получить оплаченную сумму по договору страхования за период
  * @author Sergeev D.
  * @param p_start_date Дата начала периода
  * @param p_end_date Дата окончания периода
  * @param p_p_pol_header_id ИД заголовка договора страхования
  * @return Оплаченная сумма договора
  */
  FUNCTION get_pay_pol_header_amount_pfa
  (
    p_start_date      DATE
   ,p_end_date        DATE
   ,p_p_pol_header_id NUMBER
  ) RETURN NUMBER;

  /**
  * Получить выплаченную сумму по договору страхования за период
  * @author Sergeev D.
  * @param p_start_date Дата начала периода
  * @param p_end_date Дата окончания периода
  * @param p_p_pol_header_id ИД заголовка договора страхования
  * @return Выплаченная сумма по договору
  */
  FUNCTION get_ret_pay_pol_header_pfa
  (
    p_start_date      DATE
   ,p_end_date        DATE
   ,p_p_pol_header_id NUMBER
  ) RETURN NUMBER;

  /**
  * Получить выплаченную сумму по акту выполненных работ агента за период
  * @author Sergeev D.
  * @param p_start_date Дата начала периода
  * @param p_end_date Дата окончания периода
  * @param p_agent_report_id ИД акта выполненных работ агента
  * @return Выплаченная сумма по договору
  */
  FUNCTION get_pay_agent_report_pfa
  (
    p_start_date      DATE
   ,p_end_date        DATE
   ,p_agent_report_id NUMBER
  ) RETURN NUMBER;

  /**
  * Получить сумму премии по последней версии договора страхования
  * @author Sergeev D.
  * @param p_pol_header_id ИД договора страхования
  * @return Сумма премии
  */
  FUNCTION get_last_premium_amount(p_pol_header_id IN NUMBER) RETURN NUMBER;

  /**
  * Получить начисленную сумму к возврату премиии по последней версии договора страхования
  * @author Sergeev D.
  * @param p_pol_header_id ИД договора страхования
  * @return Начисленная сумма возврата премии
  */
  FUNCTION get_last_ret_amount(p_pol_header_id IN NUMBER) RETURN NUMBER;

  /**
  * Получить запланированную к оплате сумму премии по договору страхования
  * @author Sergeev D.
  * @param p_pol_header_id ИД договора страхования
  * @return Запланированная сумма к оплате
  */
  FUNCTION get_plan_amount(p_pol_header_id IN NUMBER) RETURN NUMBER;

  /**
  * Получить начисленную сумму премии по договору страхования
  * @author Sergeev D.
  * @param p_pol_header_id ИД договора страхования
  * @return Начисленная сумма премии
  */
  FUNCTION get_calc_amount(p_pol_header_id IN NUMBER) RETURN NUMBER;

  /**
  * Получить начисленную сумму премии по версии договора страхования
  * @author Sergeev D.
  * @param par_policy_id ИД версии договора страхования
  * @return Начисленная сумма премии
  */
  FUNCTION get_calc_amount_policy(par_policy_id IN NUMBER) RETURN NUMBER;

  FUNCTION get_pay_cover_amount_fo
  (
    p_p_cover_id NUMBER
   ,p_year       NUMBER
  ) RETURN t_amount;
  FUNCTION get_charge_cover_amount_foy
  (
    p_p_cover_id NUMBER
   ,p_year       NUMBER
  ) RETURN t_amount;

  /**
  * Получить начисленную к оплате сумму премии по договору страхования
  * @author Sergeev D.
  * @param p_pol_header_id ИД договора страхования
  * @return Начисленная к оплате сумма премии
  */
  FUNCTION get_to_pay_amount(p_pol_header_id IN NUMBER) RETURN NUMBER;

  /**
  * Получить запланированную сумму выплаты вознаграждения по акту выполненных работ агента
  * @author Sergeev D.
  * @param p_agent_report_id ИД акта выполненных работ агента
  * @return Запланированная сумма вознаграждения
  */
  FUNCTION get_ag_plan_amount(p_agent_report_id IN NUMBER) RETURN NUMBER;

  /**
  * Получить начисленную сумму выплаты вознаграждения по акту выполненных работ агента
  * @author Sergeev D.
  * @param p_agent_report_id ИД акта выполненных работ агента
  * @return Начисленная сумма вознаграждения
  */
  FUNCTION get_ag_calc_amount(p_agent_report_id IN NUMBER) RETURN NUMBER;

  /**
  * Получить удержанную сумму вознаграждения по акту выполненных работ агента
  * @author Sergeev D.
  * @param p_agent_report_id ИД акта выполненных работ агента
  * @return Удержанная сумма вознаграждения
  */
  FUNCTION get_ag_hold_amount(p_agent_report_id IN NUMBER) RETURN NUMBER;

  /**
  * Получить начисленную к выплате сумму вознаграждения по акту выполненных работ агента
  * @author Sergeev D.
  * @param p_agent_report_id ИД акта выполненных работ агента
  * @return Начисленная к выплате сумма вознаграждения
  */
  FUNCTION get_ag_to_pay_amount(p_agent_report_id IN NUMBER) RETURN NUMBER;

  /**
  * Получить запланированную к выплате сумму возврата премии по договору страхования
  * @author Sergeev D.
  * @param p_pol_header_id ИД договора страхования
  * @return Запланированная сумма возврата к выплате
  */
  FUNCTION get_plan_ret_amount(p_pol_header_id IN NUMBER) RETURN NUMBER;

  /**
  * Получить начисленную сумму возврата премии по договору страхования
  * @author Sergeev D.
  * @param p_pol_header_id ИД договора страхования
  * @return Начисленная сумма возврата премии
  */
  FUNCTION get_calc_ret_amount(p_pol_header_id IN NUMBER) RETURN NUMBER;

  /**
  * Получить начисленную к выплате сумму возврата премии по договору страхования
  * @author Sergeev D.
  * @param p_pol_header_id ИД договора страхования
  * @return Начисленная к выплате сумма возврата премии
  */
  FUNCTION get_to_pay_ret_amount(p_pol_header_id IN NUMBER) RETURN NUMBER;

  /**
  * Получить расчитанную сумму выплат по претензии
  * @author Sergeev D.
  * @param p_claim_header_id ИД заголовка претензии
  * @return Расчитанная сумма выплат по претензии
  */
  FUNCTION get_claim_payment_amount(p_claim_header_id IN NUMBER) RETURN NUMBER;

  /**
  * Получить запланированную сумму выплат по претензии
  * @author Sergeev D.
  * @param p_claim_header_id ИД заголовка претензии
  * @return Запланированная сумма выплат по претензии
  */
  FUNCTION get_claim_plan_amount(p_claim_header_id IN NUMBER) RETURN NUMBER;

  /**
  * По полису возвращает страховую сумму, премию и оплаченную премию
  * @author Patsan O.
  * @param par_pol_id ИД полиса
  * @param par_ins_amount Страховая сумма
  * @param par_prem_amount Премия
  * @param par_pay_amount Оплаченная премия
  */
  PROCEDURE get_pol_pay_status
  (
    par_pol_id      IN NUMBER
   ,par_ins_amount  OUT NUMBER
   ,par_prem_amount OUT NUMBER
   ,par_pay_amount  OUT NUMBER
  );

  /**
  * Создать счета-распоряжения по полису
  * Создает, корректирует существующий планы-графики оплаты и выплаты
  * @author   Ivanov D.
  * @param p_p_policy_id ИД версии полиса
  * @param p_Payment_Term_ID ИД вида рассрочки платежа
  * @param p_planning_type Вид графика платежей
  */
  PROCEDURE policy_make_planning
  (
    p_p_policy_id     NUMBER
   ,p_payment_term_id NUMBER
   ,p_planning_type   VARCHAR2
  );
  /**
  * Создать счета-распоряжения по генеральному договору страхования
  * Создает, корректирует существующий планы-графики оплаты и выплаты
  * @author   Sergeev D.
  * @param p_gen_policy_id ИД генерального договора страхования
  * @param p_Payment_Term_ID ИД вида рассрочки платежа
  * @param p_planning_type Вид графика платежей
  */
  PROCEDURE gpolicy_make_planning
  (
    p_gen_policy_id   NUMBER
   ,p_payment_term_id NUMBER
   ,p_planning_type   VARCHAR2
  );
  /**
  * Создать счета-распоряжения по претензии
  * Создает, корректирует существующий планы-графики выплаты
  * @author Budkova A.
  * @param p_claim_id ИД претензии
  * @param p_Payment_Term_ID ИД вида рассрочки платежа
  * @param p_planning_type Вид графика платежей
  */
  PROCEDURE claim_make_planning
  (
    p_claim_id        NUMBER
   ,p_payment_term_id NUMBER
   ,p_planning_type   VARCHAR2
  );

  /**
  * Создать распоряжения на выплату по акту выполненных работ агента
  * Создает, план-график выплаты
  * @author   Sergeev D.
  * @param p_agent_report_id ИД версии полиса
  */
  PROCEDURE agent_make_planning(p_agent_report_id NUMBER);

  /**
  * Проведение зачета двух платежей
  * @author Ivanov D.
  * @param doc_id Ид документа по зачету (doc_set_off)
  */
  PROCEDURE set_off_status(doc_id IN NUMBER);

  /**
  * Процедура начисления версии договора страхования
  * @author Ivanov D.
  * @param p_policy_id ИД версии договора страхования
  */
  PROCEDURE policy_charge(p_p_policy_id NUMBER);

  /**
  * Получить объекты-содержимое платежа к зачету
  * @author Ivanov D.
  * @param ac_payment_id ИД платежа
  * @param p_date дата на которую будут получено состояние по зачету
  * @return Открытый курсор типа t_paym_cont_cur
  */
  FUNCTION get_payment_sum
  (
    p_ac_payment_id NUMBER
   ,p_date          DATE DEFAULT to_date('01.01.3000', 'DD.MM.YYYY')
  ) RETURN t_paym_cont_cur;

  /**
  * Получить строку даты (ДД.ММ) уплаты последующих взносов
  * @author Budkova A.
  * @param p_policy_id ИД версии договора страхования
  * @return Строка даты уплаты последующих взносов
  */
  FUNCTION get_date_payments(p_policy_id IN NUMBER) RETURN VARCHAR2;

  /**
  * Создать счета на оплату премии и распоряжения на выплату возврата по версии договора страхования
  * @author   Sergeev D.
  * @param p_policy_id ИД версии договора страхования
  */
  PROCEDURE make_pay_schedule(p_policy_id NUMBER);

  /**
  * Выполнить определенные действия перед отменой зачета документов
  * @author   Sergeev D.
  * @param p_doc_id ИД документа по зачету
  */
  PROCEDURE dso_before_delete(p_doc_id NUMBER);

  /**
  * Получить количество лет между датами
  * @author Budkova A.
  * @param p_start_date Дата начала периода
  * @param p_end_date Дата окончания периода
  * @return Количество лет между датами
  */
  FUNCTION get_year_number
  (
    p_start_date DATE
   ,p_end_date   DATE
  ) RETURN NUMBER;

  /**
  * Сформировать график платежей по договору страхования при переходе статуса версии договора страхования
  * @author   Sergeev D.
  * @param doc_id ИД документа по зачету
  */
  PROCEDURE set_policy_new_renlife(doc_id NUMBER);

  /**
  * Удалить неоплаченные счета по договору страхования
  * @author Patsan O.
  * @param doc_id ИД договора страхования
  */
  PROCEDURE delete_unpayed
  (
    doc_id     IN NUMBER
   ,p_due_date DATE DEFAULT NULL
  );

  /**
  * Удалить неоплаченные счета по версии договору страхования
  * @author Patsan O.
  * @param doc_id ИД версии договора страхования
  */
  PROCEDURE delete_unpayed_pol(doc_id IN NUMBER);

  /**
  * Удалить неоплаченные счета по генеральному договору страхования
  * @author Patsan O.
  * @param doc_id ИД генерального договора страхования
  */
  PROCEDURE delete_unpayed_gpol(doc_id IN NUMBER);

  /**
  * Получить сумму взаимозачета по покрытию
  **/
  FUNCTION get_vzch_amount
  (
    p_p_cover_id  NUMBER
   ,p_type        VARCHAR2 DEFAULT 'PROD_LINE'
   ,p_document_id NUMBER DEFAULT NULL
   ,p_acc_id      NUMBER DEFAULT v_ret_acc_id
  ) RETURN t_amount;

  /**
  * Получить сумму выплаченного возмещения по договору страхования за период
  * @author Sergeev D.
  * @param p_pol_header_id ИД договора страхования
  * @param p_start_date Дата начала периода
  * @param p_end_date Дата окончания периода
  * @return Сумма выплаты возмещения
  */
  FUNCTION get_ph_claim_pay_amount
  (
    p_pol_header_id IN NUMBER
   ,p_start_date    IN DATE
   ,p_end_date      IN DATE
  ) RETURN NUMBER;
  /**
  * Получить сумму выплаченного возврата по договору страхования за период
  * @author Sergeev D.
  * @param p_pol_header_id ИД договора страхования
  * @param p_start_date Дата начала периода
  * @param p_end_date Дата окончания периода
  * @return Сумма выплаты возврата
  */
  FUNCTION get_ph_ret_pay_amount
  (
    p_pol_header_id IN NUMBER
   ,p_start_date    IN DATE
   ,p_end_date      IN DATE
  ) RETURN NUMBER;
  /**
  * Получить сумму начисленной премии по покрытию
  * @author Ivanov D.
  * @param p_p_cover_id ид покрытия
  * @param p_start_date дата начала периода
  * @param p_end_date дата окончания периода
  * @return запись типа t_amount, содержащую значения в валюте ответсвенности и в валюте
  */
  FUNCTION get_charge_cover_amount
  (
    p_start_date DATE
   ,p_end_date   DATE
   ,p_p_cover_id NUMBER
  ) RETURN t_amount;
  /**
  * Получить сумму начисленной премии по покрытию
  * @author BALSHOV
  * @param p_p_cover_id ид покрытия
  * @param p_start_date дата начала периода
  * @param p_end_date дата окончания периода
  * @return запись типа number, содержащую значения в валюте ответсвенности и в валюте
  */
  FUNCTION get_charge_cover_amount_pfa
  (
    p_start_date DATE
   ,p_end_date   DATE
   ,p_p_cover_id NUMBER
  ) RETURN NUMBER;

  /**
  * Получить сумму начисленной премии по P_COVER
  * @author BALSHOV
  * @param p_p_cover_id ид покрытия
  * @param p_start_date дата начала периода
  * @param p_end_date дата окончания периода
  * @return запись типа number, содержащую значения в валюте ответсвенности и в валюте
  */
  FUNCTION get_charge_pcover_amount_pfa
  (
    p_start_date DATE
   ,p_end_date   DATE
   ,p_p_cover_id NUMBER
  ) RETURN NUMBER;

  /**
  * Получить сумму задолженности по покрытию
  * @author Ganichev F.
  * @param p_p_cover_id ид покрытия
  * @param p_date дата
  * @return сумму задолженности
  */
  FUNCTION get_debt_cover_amount
  (
    p_p_cover_id NUMBER
   ,p_date       DATE
  ) RETURN t_amount;

  /**
  * Получить сумму оплаты премии за период по аналитикам
  * Оборот в корреспонденции Д счет расчетов со страхователями,перестрахователями - К счет начисленных премий
  * @author Ivanov D.
  * @param p_fund_id ИД валюты
  * @param p_start_date Дата начала периода
  * @param p_end_date Дата окончания периода
  * @param p_A1_ID ИД 1-го типа аналитики
  * @param p_A2_ID ИД 2-го типа аналитики
  * @param p_A3_ID ИД 3-го типа аналитики
  * @param p_A4_ID ИД 4-го типа аналитики
  * @param p_A5_ID ИД 5-го типа аналитики
  */
  FUNCTION get_pay_amount
  (
    p_fund_id    NUMBER
   ,p_start_date DATE
   ,p_end_date   DATE
   ,p_a1_id      NUMBER DEFAULT NULL
   ,p_a2_id      NUMBER DEFAULT NULL
   ,p_a3_id      NUMBER DEFAULT NULL
   ,p_a4_id      NUMBER DEFAULT NULL
   ,p_a5_id      NUMBER DEFAULT NULL
  ) RETURN t_amount;

  /**
  * Получить начисленную сумму агентского вознаграждения по договору страхования
  * @author Sergeev D.
  * @param p_pol_header_id ИД договора страхования
  * @param p_start_date Дата начала периода
  * @param p_end_date   Дата окончания периода
  * @return Начисленная сумма вознаграждени
  */
  FUNCTION get_calc_agent_amount_pfa
  (
    p_pol_header_id IN NUMBER
   ,p_start_date    IN DATE
   ,p_end_date      IN DATE
  ) RETURN NUMBER;

  /**
  * Получить сумму начисленного возврата
  * @author Sergeev D.
  * @param p_start_date дата начала периода
  * @param p_end_date дата окончания периода
  * @param p_p_cover_id ид покрытия
  * @return запись типа t_amount, содержащую значения в валюте ответсвенности и в валюте
  */
  FUNCTION get_repay_charge_amount_pfa
  (
    p_start_date DATE
   ,p_end_date   DATE
   ,p_p_cover_id NUMBER
  ) RETURN NUMBER;

  PROCEDURE create_paymnt_sheduler_renlife(p_p_policy_id NUMBER);
  FUNCTION get_charge_prodline_amount
  (
    p_p_cover_id NUMBER
   ,p_start_date DATE
   ,p_end_date   DATE
  ) RETURN t_amount;
  PROCEDURE set_payments_to_pay(doc_id NUMBER);
  FUNCTION delete_payment
  (
    p_payment_id NUMBER
   ,p_doc_templ  VARCHAR2
   ,p_amount     NUMBER DEFAULT NULL
  ) RETURN NUMBER;
  PROCEDURE delete_payments_pol(doc_id NUMBER);

  /**
  * Получить сумму недоплаты по договору
  * @author Mirovich M.
  * @param p_pol_header_id - id договора
  * @return сумму недоплаты по договору в валюте договора
  */
  FUNCTION get_underpayment_amount(p_pol_header_id NUMBER) RETURN NUMBER;

  /**
  * Определяет, является ли счет первым в страховом году(признак начисления административных издержек)
  * @author Ganichev F.
  * @param p_acc_id - id счета
  * @return 1-если счет первый,0 если нет
  */

  FUNCTION is_first_acc(p_acc_id NUMBER) RETURN NUMBER;

  /**
  * Определяет дату элемента план-графика для счета
  * @author Ganichev F.
  * @param p_acc_id - id счета
  * @return Дату элемента план-графика
  */
  FUNCTION get_plan_acc_date(p_acc_id NUMBER) RETURN DATE;

  /**
  * Вычисляет сколько начислено или оплачено по покрытию
  * @author Ganichev F.
  * @param p_p_cover_id  - id покрытия
  * @return исходящий остаток на счете 92.01(начислено) или 77.01.02(оплачено)
  */
  FUNCTION get_charge_cover_amount
  (
    p_p_cover_id  NUMBER
   ,p_type        VARCHAR2 DEFAULT 'PROD_LINE'
   ,p_document_id NUMBER DEFAULT NULL
   ,p_acc_id      NUMBER DEFAULT v_charge_acc_id
  ) RETURN t_amount;

  /**
  * Вычисляет сколько оплачено по покрытию всего
  * @author Ganichev F.
  * @param p_p_cover_id  - id покрытия
  * @return исходящий остаток на счете 77.01.02
  */
  FUNCTION get_pay_cover_amount(p_p_cover_id NUMBER) RETURN t_amount;

  FUNCTION is_version_cover
  (
    p_pol_id        NUMBER
   ,p_cov_id        NUMBER
   ,p_as_header_id  NUMBER
   ,p_plo_id        NUMBER
   ,p_pol_header_id NUMBER
  ) RETURN NUMBER;
  -- Остаток на счете 77.01.02
  FUNCTION get_debt_cover_amount(p_p_cover_id NUMBER) RETURN t_amount;

  /**
  * Вызывается при аннулировании зачета. Переводит зачитываемый счет в статус к оплате
  * @author Ganichev F.
  * @param p_setoff_id   - id документа по зачету
  */
  PROCEDURE setoff_annulated(p_setoff_id NUMBER);

  /**
  * Вызывается при отмене аннулирования зачета.
  * @author Ganichev F.
  * @param p_setoff_id   - id документа по зачету
  */

  PROCEDURE setoff_cancel_annulated(p_setoff_id NUMBER);

  FUNCTION get_ret_pay_policy_amount_num
  (
    p_start_date  DATE
   ,p_end_date    DATE
   ,p_p_policy_id NUMBER
  ) RETURN NUMBER;
  PROCEDURE update_paym_scheduler(p_pol_id NUMBER);

  /**
  * Вызывается при переводе счета в статус Оплачен
  * Формирует проводки по дебету 77.01.03 кредиту 77.01.02 (авансовая схема)
  * Взнос считается оплаченным (кредит 77.01.02) только когда счет оплачен полностью.
  * До этого момента деньги аккумулируются на транзитном счете 77.01.03
  * @author Ganichev F.
  * @param p_setoff_id   - id документа по зачету
  */
  PROCEDURE set_acc_paid(p_acc_id NUMBER);

  PROCEDURE load_tmp
  (
    p_payment_type_id     NUMBER
   ,p_fund_brief_bill     VARCHAR2
   ,p_fund_brief_order    VARCHAR2
   ,p_fund_id_bill        NUMBER
   ,p_rev_fund_id         NUMBER
   ,p_rev_rate_type_brief VARCHAR2
   ,p_rev_rate_type_id    NUMBER
   ,p_rev_rate            NUMBER
   ,p_due_date            DATE
   ,p_flt_status          VARCHAR2
   ,p_payment_direct_id   NUMBER
   ,p_payment_id          NUMBER
   ,p_flt_contact_id      NUMBER
   ,p_flt_start_date      DATE
   ,p_flt_end_date        DATE
   ,p_flt_doc_num         VARCHAR2
   ,p_flt_notice_num      VARCHAR2
   ,p_flt_sum             NUMBER
   ,p_flt_index_sum       NUMBER
   ,p_flt_ids             VARCHAR2 DEFAULT NULL
  );
  PROCEDURE validate_setoff(p_setoff_id NUMBER);
  PROCEDURE validate_setoff
  (
    p_setoff_id   NUMBER
   ,p_payment_sum OUT NUMBER
   ,p_setoff_sum  OUT NUMBER
  );
  /**
  * Рассчитать зачтенную сумму по выставленному счету(распоряжению) по указанному договору(если задан)
  * @author Ganichev F.
  * @param bill_doc_id   - id элемента план-графика (счет или распоряжение)
  * @param p_pol_header_id - id договора. Если задан, то сумма рассчитывается в только заданного договора
  * @param set_off_doc_id - id зачета. Если задан, то сумма данного зачета не учитывается
  */
  FUNCTION get_set_off_amount
  (
    bill_doc_id     IN NUMBER
   ,p_pol_header_id IN NUMBER
   ,set_off_doc_id  NUMBER
  ) RETURN NUMBER;

  -- Сумма всех платежных документов определенного типа по договору (счета, распоряжения)
  FUNCTION get_pol_acc_doc_amount
  (
    p_ph_id    NUMBER
   ,p_dt_brief VARCHAR2 DEFAULT 'PAYMENT'
  ) RETURN NUMBER;
  -- Сумма начислений по договору (премии, возврата)
  FUNCTION get_pol_charge_amount
  (
    p_ph_id  NUMBER
   ,p_acc_id NUMBER DEFAULT v_charge_acc_id
  ) RETURN NUMBER;

  /**
  * Проверяет статус версии полиса, если он в проекте, то генерится эксепшн
  * @author D.Syrovetskiy
  * @param p_id ИД документа
  */
  PROCEDURE check_policy_status(p_id NUMBER);
  PROCEDURE annulate_payment(p_doc_id NUMBER);

  /**Незачтенная сумма по счету Aphynogenov**/
  PROCEDURE get_uncharge_acc_amount
  (
    p_policy_id      NUMBER
   ,p_ac_payment_id  NUMBER
   ,p_doc_set_off_id NUMBER
   ,p_amount         OUT NUMBER
   ,p_fund_id        OUT NUMBER
  );

  /**Незачтенная сумма по платежке Aphynogenov**/
  PROCEDURE get_uncharge_set_off_amount
  (
    p_ac_payment_id  NUMBER
   ,p_doc_set_off_id NUMBER
   ,p_amount         OUT NUMBER
   ,p_fund_id        OUT NUMBER
  );
  -- 
  --
  /**
  * Возвращает дату начала периода, в который попадает контольная дата
  * @author Ф.Ганичев
  * @param p_start_date - дата, от которой отсчитываются периоды
  * @param p_num_of_payments - кол-во платежей в году
  * @param p_date - контольная дата
  */
  FUNCTION get_period_date
  (
    p_start_date      DATE
   ,p_num_of_payments NUMBER
   ,p_date            DATE
  ) RETURN DATE;

  /**
  * Проверяет сумму счетов и взосов по договору при переводе счета в статус Аннулирован
  * @author O.Chikashova
  * @param p_payment_id ИД счета
  */
  PROCEDURE check_payment_sum(p_payment_id NUMBER);
  ag_comm_cache     utils.hashmap_t;
  tariff_calc_cache utils.hashmap_t;
END;
/
CREATE OR REPLACE PACKAGE BODY "PKG_PAYMENT_NEW" IS

  g_debug BOOLEAN := TRUE;

  FUNCTION calc_prodline_fee_delta
  (
    p_asset_id       NUMBER
   ,p_pl_id          NUMBER
   ,p_due_date       DATE
   ,p_is_period      NUMBER DEFAULT 1
   ,p_start_per_date DATE DEFAULT NULL
   ,p_end_per_date   DATE DEFAULT NULL
  ) RETURN NUMBER;
  charge_prodline_ar utils.hashmap_t;

  PROCEDURE log
  (
    p_object_id IN NUMBER
   ,p_message   IN VARCHAR2
  ) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    IF g_debug
    THEN
      INSERT INTO p_payment_debug
        (object_id, execution_date, operation_type, debug_message)
      VALUES
        (p_object_id, SYSDATE, 'INS.PKG_PAYMENT', substr(p_message, 1, 4000));
    END IF;
  
    COMMIT;
  
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END;

  PROCEDURE calc_fee_delta
  (
    p_pol_id         NUMBER
   ,p_due_date       DATE
   ,p_return_sum     OUT NUMBER
   ,p_paym_sum       OUT NUMBER
   ,p_adm_cost       NUMBER DEFAULT 0
   ,p_is_period      NUMBER DEFAULT 1
   ,p_start_per_date DATE DEFAULT NULL
   ,p_end_per_date   DATE DEFAULT NULL
  ) IS
    v_pl_delta NUMBER;
  BEGIN
  
    p_return_sum := 0;
    p_paym_sum   := 0;
  
    FOR pl IN (SELECT plo.product_line_id
                     ,pl.brief
                     ,a.as_asset_id
                     ,CASE
                        WHEN pc.end_date < p_end_per_date
                             AND pc.end_date >= p_start_per_date THEN
                         pc.end_date
                        ELSE
                         NULL
                      END end_date
                     ,CASE
                        WHEN pc.status_hist_id = pkg_cover.status_hist_id_new
                             AND pc.start_date <> p_due_date
                             AND p_start_per_date IS NOT NULL THEN
                         pc.start_date
                        ELSE
                         p_due_date
                      END p_due_date
                     ,pc.fee
                 FROM p_cover            pc
                     ,as_asset           a
                     ,t_prod_line_option plo
                     ,t_product_line     pl
                     ,t_lob_line         ll
                WHERE a.p_policy_id = p_pol_id
                  AND pc.as_asset_id = a.as_asset_id
                  AND plo.id = pc.t_prod_line_option_id
                  AND pl.id = plo.product_line_id
                  AND a.status_hist_id <> pkg_asset.status_hist_id_del
                  AND pc.status_hist_id <> pkg_cover.status_hist_id_del
                  AND (pc.start_date <= p_due_date OR p_is_period = 0)
                  AND (pc.end_date >= p_due_date OR p_is_period = 0)
                  AND pl.t_lob_line_id = ll.t_lob_line_id
                  AND (ll.brief NOT LIKE '%Adm_Cost%' OR p_adm_cost = 1))
    --Каткевич А.Г. Так будет надежнее
    --                         AND (p_adm_cost=1 OR UPPER(NVL(pl.BRIEF,'?'))!= 'ADMIN_EXPENCES')) 
    LOOP
      v_pl_delta := calc_prodline_fee_delta(pl.as_asset_id
                                           ,pl.product_line_id
                                           ,pl.p_due_date
                                           ,p_is_period
                                           ,p_start_per_date
                                           ,p_end_per_date);
      IF v_pl_delta > 0
      THEN
        p_paym_sum := p_paym_sum + v_pl_delta;
      ELSE
        p_return_sum := p_return_sum - v_pl_delta;
      END IF;
    END LOOP;
  END;

  FUNCTION calc_prodline_fee_delta
  (
    p_asset_id       NUMBER
   ,p_pl_id          NUMBER
   ,p_due_date       DATE
   ,p_is_period      NUMBER DEFAULT 1
   ,p_start_per_date DATE DEFAULT NULL
   ,p_end_per_date   DATE DEFAULT NULL
  ) RETURN NUMBER IS
    v_curr_sum  NUMBER;
    v_prev_sum  NUMBER;
    v_cover_id  NUMBER;
    v_amount    t_amount;
    v_amount_fa NUMBER;
    v_prorata   NUMBER;
  BEGIN
  
    IF p_start_per_date IS NULL
    THEN
      --Каткевчи А.Г. 01/12/2008 В групповом договоре покрытие может оканчиваться не на дату план графика 
      SELECT nvl(SUM(fee), 0)
            ,MIN(p_cover_id)
        INTO v_curr_sum
            ,v_cover_id
        FROM (SELECT CASE
                       WHEN (p_end_per_date - p_due_date) <> 0
                            AND CEIL((pc.end_date + 1 - p_due_date) / (p_end_per_date - p_due_date)) = 1 THEN
                        ROUND(pc.fee * (pc.end_date + 1 - p_due_date) / (p_end_per_date - p_due_date), 2)
                       ELSE
                        pc.fee
                     END fee
                    ,pc.p_cover_id
                FROM p_cover            pc
                    ,t_prod_line_option plo
               WHERE pc.as_asset_id = p_asset_id
                 AND pc.t_prod_line_option_id = plo.id
                 AND plo.product_line_id = p_pl_id);
    ELSE
    
      v_prorata := (p_end_per_date - p_due_date) / (p_end_per_date - p_start_per_date);
    
      SELECT (c.fee - nvl(c.old_fee, 0)) * v_prorata
            ,c.p_cover_id
        INTO v_curr_sum
            ,v_cover_id
        FROM (SELECT pc.p_cover_id
                    ,pc.fee
                    ,lag(pc.fee) over(PARTITION BY a1.p_asset_header_id, plo.product_line_id ORDER BY pc.p_cover_id ASC) old_fee
                FROM p_cover            pc
                    ,t_prod_line_option plo
                    ,as_asset           a
                    ,as_asset           a1
               WHERE a.as_asset_id = p_asset_id
                 AND a.p_asset_header_id = a1.p_asset_header_id
                 AND pc.as_asset_id = a1.as_asset_id
                 AND pc.t_prod_line_option_id = plo.id
                 AND plo.product_line_id = p_pl_id
               ORDER BY pc.p_cover_id DESC) c
       WHERE rownum = 1;
    END IF;
  
    -- Уже оплачено по покрытию на дату = начислено на дату, если удалены все неоплаченые счета
    IF utils.get_null(charge_prodline_ar, p_asset_id) IS NOT NULL
    THEN
      -- Вообще нет счетов по договору
      v_amount_fa := 0;
    ELSE
      v_amount_fa := utils.get_null(charge_prodline_ar, 'A_' || v_cover_id || '_' || p_due_date);
    END IF;
  
    IF v_amount_fa IS NULL
    THEN
      IF p_is_period != 1
      THEN
        v_amount := get_charge_prodline_amount(v_cover_id, NULL, NULL);
      ELSE
        v_amount := get_charge_prodline_amount(v_cover_id, p_due_date, p_due_date);
      END IF;
      v_amount_fa := v_amount.fund_amount;
      charge_prodline_ar('A_' || v_cover_id || '_' || p_due_date) := v_amount_fa;
    END IF;
  
    v_prev_sum := nvl(v_amount_fa, 0);
    RETURN v_curr_sum - v_prev_sum;
  END calc_prodline_fee_delta;

  FUNCTION create_paymnt_by_templ
  (
    p_payment_templ_id    VARCHAR2
   ,p_payment_terms_id    NUMBER
   ,p_number              VARCHAR2
   ,p_date                DATE
   ,p_grace_date          DATE
   ,p_amount              NUMBER
   ,p_fund_id             NUMBER
   ,p_rev_amount          NUMBER
   ,p_rev_fund_id         NUMBER
   ,p_rev_rate_type_id    NUMBER
   ,p_rev_rate            NUMBER
   ,p_contact_id          NUMBER
   ,p_contact_bank_acc_id NUMBER DEFAULT NULL
   ,p_company_bank_acc_id NUMBER DEFAULT NULL
   ,p_note                VARCHAR2
   ,p_primary_doc_id      NUMBER DEFAULT NULL
   ,p_plan_date           DATE DEFAULT NULL
  ) RETURN NUMBER IS
    v_document_id           NUMBER;
    v_payment_type_id       NUMBER;
    v_payment_direct_id     NUMBER;
    v_doc_templ_id          NUMBER;
    v_collection_metod_id   NUMBER;
    v_collection_metod_desc VARCHAR2(150);
    v_contact_bank_acc_id   NUMBER;
    v_company_bank_acc_id   NUMBER;
    v_doc_status_ref_id     NUMBER;
    v_doc_ent_id            NUMBER;
    v_parent_doc            document%ROWTYPE;
    v_doc_ent_brief         VARCHAR2(30);
    v_part_amount           NUMBER;
    v_total_amount          NUMBER;
    v_due_date              DATE := p_date; -- дата счета
    v_plan_date             DATE := nvl(p_plan_date, p_date);
  BEGIN
  
    IF (p_amount IS NULL OR p_rev_amount IS NULL)
    THEN
      raise_application_error(-20000, 'Сумма платежа не может быть null');
    END IF;
    IF (p_primary_doc_id IS NOT NULL)
    THEN
      -- получить родительский документ
      BEGIN
        SELECT * INTO v_parent_doc FROM document d WHERE d.document_id = p_primary_doc_id;
      
        SELECT e.brief INTO v_doc_ent_brief FROM entity e WHERE e.ent_id = v_parent_doc.ent_id;
      
      EXCEPTION
        WHEN no_data_found THEN
          raise_application_error(-20000, 'Не найден исходный документ');
      END;
    END IF;
    -- выберем шаблон платежа
    BEGIN
      SELECT e.ent_id INTO v_doc_ent_id FROM entity e WHERE e.source = 'AC_PAYMENT';
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20000
                               ,'Не найден заданный шаблон платежа');
    END;
  
    -- выберем шаблон платежа
    BEGIN
      SELECT pt.payment_type_id
            ,pt.payment_direct_id
            ,pt.doc_templ_id
        INTO v_payment_type_id
            ,v_payment_direct_id
            ,v_doc_templ_id
        FROM ac_payment_templ pt
       WHERE pt.payment_templ_id = p_payment_templ_id;
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20000
                               ,'Не найден заданный шаблон платежа');
    END;
  
    -- условие рассрочки
    BEGIN
      SELECT term.collection_method_id
            ,cm.description
        INTO v_collection_metod_id
            ,v_collection_metod_desc
        FROM t_payment_terms     term
            ,t_collection_method cm
       WHERE term.id = p_payment_terms_id
         AND term.collection_method_id = cm.id;
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20000
                               ,'Не найдено заданное условие рассрочки');
    END;
  
    v_contact_bank_acc_id := NULL;
  
    IF p_company_bank_acc_id IS NULL
    THEN
      --Каткевич А.Г. Не всегда требуются 
      --    RAISE_APPLICATION_ERROR(-20000,
      --                          'Не заданы банковские реквизиты компании');
      v_company_bank_acc_id := NULL;
    ELSE
      v_company_bank_acc_id := p_company_bank_acc_id;
    END IF;
  
    --выбираем статус документа
    SELECT dsr.doc_status_ref_id
      INTO v_doc_status_ref_id
      FROM doc_status_ref dsr
     WHERE dsr.brief = 'NEW';
  
    -- создаем платеж
    BEGIN
    
      SELECT sq_document.nextval INTO v_document_id FROM dual;
    
      INSERT INTO document
        (document_id, ent_id, num, reg_date, doc_templ_id, note)
      VALUES
        (v_document_id
        ,v_doc_ent_id
        ,v_parent_doc.num || '/' || p_number
        ,p_date
        ,v_doc_templ_id
        ,p_note);
    
      dbms_output.put_line('№ документа =>' || v_parent_doc.num || '/' || p_number);
    
      IF p_primary_doc_id IS NOT NULL
      THEN
        DECLARE
          v_confirm_date DATE;
        BEGIN
          BEGIN
            SELECT p.confirm_date_addendum
              INTO v_confirm_date
              FROM p_policy p
             WHERE p.policy_id = p_primary_doc_id;
          EXCEPTION
            WHEN no_data_found THEN
              NULL;
          END;
          IF (v_confirm_date IS NOT NULL)
             AND (v_confirm_date > v_due_date)
          THEN
            v_due_date := v_confirm_date;
          END IF;
        END;
      END IF;
    
      INSERT INTO ac_payment
        (payment_id
        ,payment_number
        ,payment_type_id
        ,payment_direct_id
        ,plan_date
        ,due_date
        ,grace_date
        ,real_pay_date
        ,amount
        ,fund_id
        ,rev_amount
        ,rev_fund_id
        ,rev_rate_type_id
        ,rev_rate
        ,contact_id
        ,payment_templ_id
        ,payment_terms_id
        ,collection_metod_id
        ,contact_bank_acc_id
        ,company_bank_acc_id)
      VALUES
        (v_document_id
        ,p_number
        ,v_payment_type_id
        ,v_payment_direct_id
        ,v_plan_date
        ,v_due_date
        ,p_grace_date
        ,NULL
        ,p_amount
        ,p_fund_id
        ,p_rev_amount
        ,p_rev_fund_id
        ,p_rev_rate_type_id
        ,p_rev_rate
        ,p_contact_id
        ,p_payment_templ_id
        ,p_payment_terms_id
        ,v_collection_metod_id
        ,v_contact_bank_acc_id
        ,v_company_bank_acc_id);
    
    EXCEPTION
      WHEN OTHERS THEN
        raise_application_error(-20000, 'Ошибка создания платежа.' || SQLERRM);
      
    END;
  
    --opatsan
    pkg_policy.check_policy_payment_date(v_document_id);
  
    IF (p_primary_doc_id IS NOT NULL)
    THEN
      BEGIN
        -- связываем с родительским документом
        IF v_doc_ent_brief <> 'GEN_POLICY'
        THEN
          INSERT INTO doc_doc
            (doc_doc_id
            ,parent_id
            ,child_id
            ,parent_amount
            ,parent_fund_id
            ,child_amount
            ,child_fund_id)
          VALUES
            (sq_doc_doc.nextval
            ,p_primary_doc_id
            ,v_document_id
            ,p_amount
            ,p_fund_id
            ,p_amount
            ,p_fund_id);
        ELSE
          v_total_amount := 0;
          FOR rec IN (SELECT DISTINCT p.policy_id
                                     ,p.pol_header_id
                        FROM doc_doc  dd
                            ,p_policy p
                       WHERE dd.parent_id = p_primary_doc_id
                         AND dd.child_id = p.pol_header_id)
          LOOP
            --тут будет разнесение суммы по разным договорам
            v_total_amount := v_total_amount + get_last_premium_amount(rec.pol_header_id) +
                              pkg_payment.get_last_ret_amount(rec.pol_header_id) -
                              get_plan_amount(rec.pol_header_id);
          END LOOP;
          FOR rec IN (SELECT DISTINCT p.policy_id
                                     ,p.pol_header_id
                        FROM doc_doc  dd
                            ,p_policy p
                       WHERE dd.parent_id = p_primary_doc_id
                         AND dd.child_id = p.pol_header_id)
          LOOP
            --тут будет разнесение суммы по разным договорам
            v_part_amount := get_last_premium_amount(rec.pol_header_id) +
                             pkg_payment.get_last_ret_amount(rec.pol_header_id) -
                             get_plan_amount(rec.pol_header_id);
            v_part_amount := ROUND(v_part_amount * p_amount / v_total_amount, 2);
            IF v_part_amount > 0
            THEN
              INSERT INTO doc_doc
                (doc_doc_id
                ,parent_id
                ,child_id
                ,parent_amount
                ,parent_fund_id
                ,child_amount
                ,child_fund_id)
              VALUES
                (sq_doc_doc.nextval
                ,rec.policy_id
                ,v_document_id
                ,v_part_amount
                ,p_fund_id
                ,v_part_amount
                ,p_fund_id);
            END IF;
          END LOOP;
        END IF;
      
        doc.set_doc_status(v_document_id, v_doc_status_ref_id);
        RETURN v_document_id;
      EXCEPTION
        WHEN OTHERS THEN
          raise_application_error(-20000
                                 ,'Ошибка привязки платежа к родительскому документу');
      END;
    END IF;
    RETURN v_document_id;
  END;

  PROCEDURE create_paymnt_sheduler
  (
    p_payment_templ_id    NUMBER
   ,p_payment_terms_id    NUMBER
   ,p_total_amount        NUMBER
   ,p_fund_id             NUMBER
   ,p_rev_fund_id         NUMBER
   ,p_rev_rate_type_id    NUMBER
   ,p_rev_rate            NUMBER
   ,p_contact_id          NUMBER
   ,p_contact_bank_acc_id NUMBER DEFAULT NULL
   ,p_company_bank_acc_id NUMBER DEFAULT NULL
   ,p_first_date          DATE DEFAULT SYSDATE
   ,p_primary_doc_id      NUMBER DEFAULT NULL
   ,p_fee_payment_term    NUMBER DEFAULT 1
  ) IS
    v_num_of_pays         NUMBER;
    v_cur_num             NUMBER(9);
    v_amount_temp         NUMBER;
    v_next_pay_amount     NUMBER;
    v_note                VARCHAR2(4000);
    v_next_pay_due_date   DATE;
    v_next_pay_grace_date DATE;
    v_next_pay_id         NUMBER;
    v_doc_ent_brief       VARCHAR2(30);
    v_policy_header_id    NUMBER;
    v_claim_header_id     NUMBER;
    v_re_slip_header_id   NUMBER;
    v_gen_policy_id       NUMBER;
    v_subr_doc_id         NUMBER;
    v_fee_payment_term    NUMBER;
    i                     NUMBER;
    v_pct                 NUMBER;
    v_cnt                 NUMBER;
    s                     VARCHAR2(8);
    v_is_period           NUMBER;
  BEGIN
  
    IF (p_total_amount IS NULL)
    THEN
      raise_application_error(-20000, 'Сумма не может быть null');
    END IF;
  
    BEGIN
      SELECT term.number_of_payments
            ,term.is_periodical
        INTO v_num_of_pays
            ,v_is_period
        FROM t_payment_terms term
       WHERE term.id = p_payment_terms_id;
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20000
                               ,'Не найдено заданное условие рассрочки');
    END;
  
    SELECT e.brief
      INTO v_doc_ent_brief
      FROM document d
          ,entity   e
     WHERE d.ent_id = e.ent_id
       AND d.document_id = p_primary_doc_id;
  
    --raise_application_error(-20000,v_Doc_Ent_Brief);
  
    CASE
      WHEN v_doc_ent_brief = 'P_POLICY' THEN
        SELECT ps.pol_header_id
          INTO v_policy_header_id
          FROM p_policy ps
         WHERE ps.policy_id = p_primary_doc_id;
      
        SELECT nvl(MAX(aps.payment_number), 0)
          INTO v_cur_num
          FROM doc_doc    dds
              ,ac_payment aps
              ,p_policy   ps
         WHERE dds.child_id = aps.payment_id
           AND dds.parent_id = ps.policy_id
           AND ps.pol_header_id = v_policy_header_id;
      
      WHEN v_doc_ent_brief = 'GEN_POLICY' THEN
      
        v_gen_policy_id := p_primary_doc_id;
      
        SELECT nvl(MAX(aps.payment_number), 0)
          INTO v_cur_num
          FROM doc_doc    dds
              ,ac_payment aps
              ,p_policy   ps
              ,doc_doc    gdd
         WHERE dds.child_id = aps.payment_id
           AND dds.parent_id = ps.policy_id
           AND ps.pol_header_id = gdd.child_id
           AND gdd.parent_id = v_gen_policy_id;
      
      WHEN v_doc_ent_brief = 'C_SUBR_DOC' THEN
      
        v_subr_doc_id := p_primary_doc_id;
      
        SELECT nvl(MAX(aps.payment_number), 0)
          INTO v_cur_num
          FROM doc_doc    dds
              ,ac_payment aps
         WHERE dds.child_id = aps.payment_id
           AND dds.parent_id = v_subr_doc_id;
      
      WHEN TRIM(upper(v_doc_ent_brief)) = 'RE_BORDERO_PACKAGE' THEN
      
        SELECT nvl(MAX(aps.payment_number), 0)
          INTO v_cur_num
          FROM doc_doc    dds
              ,ac_payment aps
         WHERE dds.child_id = aps.payment_id
           AND dds.parent_id = p_primary_doc_id;
      
      WHEN v_doc_ent_brief = 'C_CLAIM' THEN
        SELECT c.c_claim_header_id
          INTO v_claim_header_id
          FROM c_claim c
         WHERE c.c_claim_id = p_primary_doc_id;
      
        SELECT nvl(MAX(aps.payment_number), 0)
          INTO v_cur_num
          FROM doc_doc    dds
              ,ac_payment aps
              ,c_claim    cs
         WHERE dds.child_id = aps.payment_id
           AND dds.parent_id = cs.c_claim_id
           AND cs.c_claim_header_id = v_claim_header_id;
      
      WHEN v_doc_ent_brief = 'RE_SLIP' THEN
        SELECT rs.re_slip_header_id
          INTO v_re_slip_header_id
          FROM re_slip rs
         WHERE rs.re_slip_id = p_primary_doc_id;
      
        SELECT nvl(MAX(aps.payment_number), 0)
          INTO v_cur_num
          FROM doc_doc    dds
              ,ac_payment aps
              ,re_slip    rs
         WHERE dds.child_id = aps.payment_id
           AND dds.parent_id = rs.re_slip_id
           AND rs.re_slip_header_id = v_re_slip_header_id;
      ELSE
        v_cur_num := 0;
    END CASE;
  
    v_cur_num := v_cur_num + 1;
  
    v_amount_temp         := 0;
    v_next_pay_due_date   := p_first_date;
    v_next_pay_grace_date := p_first_date;
    v_next_pay_amount     := 0;
  
    v_fee_payment_term := p_fee_payment_term;
    IF v_fee_payment_term IS NULL
       OR v_fee_payment_term = 0
    THEN
      v_fee_payment_term := 1;
    END IF;
    v_num_of_pays := v_num_of_pays * v_fee_payment_term;
  
    IF v_is_period <> 1
    THEN
      v_fee_payment_term := 1;
    END IF;
  
    DELETE tmp_pay_detail;
    FOR i IN 1 .. v_fee_payment_term
    LOOP
      INSERT INTO tmp_pay_detail
        SELECT t.payment_nr
              ,t.payment_percent
              ,t.grace
              ,t.days_diff
              ,i - 1
              ,t.months_diff
          FROM t_pay_term_details t
         WHERE t.payment_term_id = p_payment_terms_id;
    END LOOP;
  
    SELECT COUNT(*) INTO v_cnt FROM tmp_pay_detail;
  
    -- comented by opatsan to fix bug 1571 
    --v_pct := 100 / v_cnt;
    --UPDATE TMP_PAY_DETAIL t SET t.payment_percent = v_pct;
  
    -- opatsan
    v_cur_num := 1;
    -- opatsan
  
    --D.Syrovetskiy
    --v_cur_num := 1 написано в связи с тем, что предыдущий цикл не учитывает кол-во
    --уже вставленных записей. Поэтому расчет происходит на оставшуюся сумму и по
    -- полным правилам рассрочки
  
    FOR rec IN (SELECT d.payment_nr
                      ,d.payment_percent
                      ,d.grace
                      ,d.months_diff
                      ,d.days_diff
                      ,d.year_num
                  FROM tmp_pay_detail d)
    LOOP
    
      -- если не последний
      dbms_output.put_line(v_cur_num || ' < ' || v_num_of_pays);
      IF (v_cur_num < v_num_of_pays)
      THEN
        v_next_pay_amount := ROUND(p_total_amount * rec.payment_percent / 100, 2);
        v_amount_temp     := v_amount_temp + v_next_pay_amount;
        dbms_output.put_line(v_amount_temp);
      ELSE
        v_next_pay_amount := p_total_amount - v_amount_temp;
      END IF;
      v_next_pay_due_date   := ADD_MONTHS(p_first_date, nvl(rec.months_diff, 0)) +
                               nvl(rec.days_diff, 0);
      v_next_pay_grace_date := v_next_pay_due_date + nvl(rec.grace, 0);
    
      -- сдвинуть год
      s                     := to_char(v_next_pay_due_date, 'yyyymmdd');
      v_next_pay_due_date   := to_date(to_char(to_number(substr(s, 1, 4)) + rec.year_num, '0000') ||
                                       substr(s, 5, 4)
                                      ,'yyyymmdd');
      s                     := to_char(v_next_pay_grace_date, 'yyyymmdd');
      v_next_pay_grace_date := to_date(to_char(to_number(substr(s, 1, 4)) + rec.year_num, '0000') ||
                                       substr(s, 5, 4)
                                      ,'yyyymmdd');
    
      -- создаем платеж
      v_next_pay_id := create_paymnt_by_templ(p_payment_templ_id
                                             ,p_payment_terms_id
                                             ,v_cur_num
                                             ,v_next_pay_due_date
                                             ,v_next_pay_grace_date
                                             ,v_next_pay_amount
                                             ,p_fund_id
                                             ,ROUND(v_next_pay_amount * p_rev_rate * 100) / 100
                                             ,p_rev_fund_id
                                             ,p_rev_rate_type_id
                                             ,p_rev_rate
                                             ,p_contact_id
                                             ,p_contact_bank_acc_id
                                             ,p_company_bank_acc_id
                                             ,v_note
                                             ,p_primary_doc_id);
      v_cur_num     := v_cur_num + 1;
    END LOOP;
  
    NULL;
  END;

  PROCEDURE create_paymnt_sheduler_new
  (
    p_payment_templ_id    NUMBER
   ,p_payment_terms_id    NUMBER
   ,p_total_amount        NUMBER
   ,p_fund_id             NUMBER
   ,p_rev_fund_id         NUMBER
   ,p_rev_rate_type_id    NUMBER
   ,p_rev_rate            NUMBER
   ,p_contact_id          NUMBER
   ,p_contact_bank_acc_id NUMBER DEFAULT NULL
   ,p_company_bank_acc_id NUMBER DEFAULT NULL
   ,p_first_date          DATE DEFAULT SYSDATE
   ,p_primary_doc_id      NUMBER DEFAULT NULL
   ,p_fee_payment_term    NUMBER DEFAULT 1
  ) IS
    v_num_of_pays         NUMBER;
    v_cur_num             NUMBER(9);
    v_amount_temp         NUMBER;
    v_next_pay_amount     NUMBER;
    v_note                VARCHAR2(4000);
    v_next_pay_due_date   DATE;
    v_next_pay_grace_date DATE;
    v_next_pay_id         NUMBER;
    v_doc_ent_brief       VARCHAR2(30);
    v_policy_header_id    NUMBER;
    v_claim_header_id     NUMBER;
    v_re_slip_header_id   NUMBER;
    v_fee_payment_term    NUMBER;
    i                     NUMBER;
    v_pct                 NUMBER;
    v_cnt                 NUMBER;
    s                     VARCHAR2(8);
  BEGIN
  
    IF (p_total_amount IS NULL)
    THEN
      raise_application_error(-20000, 'Сумма не может быть null');
    END IF;
  
    BEGIN
      SELECT term.number_of_payments
        INTO v_num_of_pays
        FROM t_payment_terms term
       WHERE term.id = p_payment_terms_id;
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20000
                               ,'Не найдено заданное условие рассрочки');
    END;
  
    SELECT e.brief
      INTO v_doc_ent_brief
      FROM document d
          ,entity   e
     WHERE d.ent_id = e.ent_id
       AND d.document_id = p_primary_doc_id;
    SELECT ps.pol_header_id
      INTO v_policy_header_id
      FROM p_policy ps
     WHERE ps.policy_id = p_primary_doc_id;
  
    SELECT nvl(MAX(aps.payment_number), 0)
      INTO v_cur_num
      FROM doc_doc    dds
          ,ac_payment aps
          ,p_policy   ps
     WHERE dds.child_id = aps.payment_id
       AND dds.parent_id = ps.policy_id
       AND ps.pol_header_id = v_policy_header_id;
    v_cur_num := v_cur_num + 1;
  
    v_amount_temp         := 0;
    v_next_pay_due_date   := p_first_date;
    v_next_pay_grace_date := p_first_date;
    v_next_pay_amount     := 0;
  
    v_fee_payment_term := p_fee_payment_term;
    IF v_fee_payment_term IS NULL
       OR v_fee_payment_term = 0
    THEN
      v_fee_payment_term := 1;
    END IF;
    v_num_of_pays := v_num_of_pays * v_fee_payment_term;
  
    DELETE tmp_pay_detail;
    FOR i IN 1 .. v_fee_payment_term
    LOOP
      INSERT INTO tmp_pay_detail
        SELECT t.payment_nr
              ,t.payment_percent
              ,t.grace
              ,t.days_diff
              ,i - 1
              ,t.months_diff
          FROM t_pay_term_details t
         WHERE t.payment_term_id = p_payment_terms_id;
    END LOOP;
  
    SELECT COUNT(*) INTO v_cnt FROM tmp_pay_detail;
    v_pct := 100 / v_cnt;
    UPDATE tmp_pay_detail t SET t.payment_percent = v_pct;
  
    FOR rec IN (SELECT d.payment_nr
                      ,d.payment_percent
                      ,d.grace
                      ,d.months_diff
                      ,d.days_diff
                      ,d.year_num
                  FROM tmp_pay_detail d)
    LOOP
    
      -- если не последний
      IF (v_cur_num < v_num_of_pays)
      THEN
        v_next_pay_amount := ROUND(p_total_amount * rec.payment_percent / 100, 2);
        v_amount_temp     := v_amount_temp + v_next_pay_amount;
      ELSE
        v_next_pay_amount := p_total_amount - v_amount_temp;
      END IF;
      v_next_pay_due_date   := ADD_MONTHS(p_first_date, nvl(rec.months_diff, 0)) +
                               nvl(rec.days_diff, 0);
      v_next_pay_grace_date := v_next_pay_due_date + nvl(rec.grace, 0);
    
      -- сдвинуть год
      s                     := to_char(v_next_pay_due_date, 'yyyymmdd');
      v_next_pay_due_date   := to_date(to_char(to_number(substr(s, 1, 4)) + rec.year_num, '0000') ||
                                       substr(s, 5, 4)
                                      ,'yyyymmdd');
      s                     := to_char(v_next_pay_grace_date, 'yyyymmdd');
      v_next_pay_grace_date := to_date(to_char(to_number(substr(s, 1, 4)) + rec.year_num, '0000') ||
                                       substr(s, 5, 4)
                                      ,'yyyymmdd');
    
      -- создаем платеж
      v_next_pay_id := create_paymnt_by_templ(p_payment_templ_id
                                             ,p_payment_terms_id
                                             ,v_cur_num
                                             ,v_next_pay_due_date
                                             ,v_next_pay_grace_date
                                             ,v_next_pay_amount
                                             ,p_fund_id
                                             ,ROUND(v_next_pay_amount * p_rev_rate * 100) / 100
                                             ,p_rev_fund_id
                                             ,p_rev_rate_type_id
                                             ,p_rev_rate
                                             ,p_contact_id
                                             ,p_contact_bank_acc_id
                                             ,p_company_bank_acc_id
                                             ,v_note
                                             ,p_primary_doc_id);
      v_cur_num     := v_cur_num + 1;
    END LOOP;
  
    NULL;
  END;

  FUNCTION get_pol_charge_amount
  (
    p_ph_id  NUMBER
   ,p_acc_id NUMBER DEFAULT v_charge_acc_id
  ) RETURN NUMBER IS
    v_amount NUMBER;
  BEGIN
    SELECT nvl(SUM(t.acc_amount), 0)
      INTO v_amount
      FROM trans    t
          ,p_policy pp
          ,oper     o
     WHERE o.document_id = pp.policy_id
       AND t.ct_account_id = p_acc_id
       AND pp.pol_header_id = p_ph_id
       AND o.oper_id = t.oper_id;
    RETURN v_amount;
  END;

  FUNCTION get_pol_acc_doc_amount
  (
    p_ph_id    NUMBER
   ,p_dt_brief VARCHAR2 DEFAULT 'PAYMENT'
  ) RETURN NUMBER IS
    v_amount NUMBER;
  BEGIN
    SELECT nvl(SUM(ap.amount), 0)
      INTO v_amount
      FROM ven_ac_payment ap
          ,p_policy       pp
          ,doc_doc        dd
     WHERE dd.parent_id = pp.policy_id
       AND dd.child_id = ap.payment_id
       AND pp.pol_header_id = p_ph_id
       AND doc.get_doc_templ_brief(ap.payment_id) = p_dt_brief;
    RETURN v_amount;
  END;

  PROCEDURE create_paymnt_sheduler_renlife(p_p_policy_id NUMBER) IS
    v_payment_id          NUMBER;
    v_payment_templ_id    NUMBER;
    v_payment_terms_id    NUMBER;
    v_fund_id             NUMBER;
    v_rev_rate            NUMBER;
    v_rev_fund_id         NUMBER;
    v_rev_rate_type_id    NUMBER;
    v_return_sum          NUMBER;
    v_paym_sum            NUMBER;
    v_adm_cost            NUMBER := 0;
    v_contact_id          NUMBER;
    v_contact_bank_acc_id NUMBER;
    v_company_bank_acc_id NUMBER;
    v_note                VARCHAR2(4000);
    v_is_period           NUMBER;
    v_num_of_pay          NUMBER;
    v_num_of_years        NUMBER;
    v_curr_year           NUMBER;
    v_year_count          NUMBER;
    v_pay_count           NUMBER;
    v_grace_period        NUMBER;
    v_months_diff         NUMBER;
    v_days_diff           NUMBER;
    v_payordback_templ_id NUMBER;
    v_pol_header_id       NUMBER;
    v_acc_cnt             NUMBER;
    v_is_group            NUMBER;
    v_addition_acc        NUMBER := 0;
    v_head_start_date     DATE; --Дата начала договора
    v_period_date         DATE; --Дата ближайшего меньшего периода оплаты к дате версии
    v_start_date          DATE; --Дата начала версии
    v_first_date          DATE; --Дата первого платежа (по версии)
    v_end_date            DATE; --Дата окончания вресии
    v_next_plan_date      DATE; --Дата следующего план графика plan_date 
    v_start_plan_date     DATE; --Дата ближайшей меньшей страховой годовщины к дате версии
    v_next_due_date       DATE; --Дата следующего план графика due_date "Дата выставления" - по этой дате формируются проводки
    v_next_grace_date     DATE; --"Срок платежа"
    v_next_next_plan_date DATE; --Дата следующего план графика после v_next_due_date
    v_name_addend         VARCHAR2(350);
  BEGIN
    charge_prodline_ar.delete;
  
    BEGIN
      SELECT pt.payment_templ_id
        INTO v_payment_templ_id
        FROM ac_payment_templ pt
       WHERE pt.brief = 'PAYMENT';
    
      SELECT pt.payment_templ_id
        INTO v_payordback_templ_id
        FROM ac_payment_templ pt
       WHERE pt.brief = 'PAYMENT_SETOFF_ACC';
    
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20100
                               ,'Не найден шаблон док. для план графика');
    END;
  
    SELECT p.payment_term_id
          ,ph.fund_id
          ,ph.start_date
          ,p.start_date
          ,p.first_pay_date
          ,nvl(pt.is_periodical, 0)
          ,pt.number_of_payments
          ,
           --pp.period_value,
           p.fee_payment_term
          ,nvl(gp.period_value, 0)
          ,p.pol_header_id
          ,p.is_group_flag
          ,p.end_date
          ,dd.description
      INTO v_payment_terms_id
          ,v_fund_id
          ,v_head_start_date
          ,v_start_date
          ,v_first_date
          ,v_is_period
          ,v_num_of_pay
          ,v_num_of_years
          ,v_grace_period
          ,v_pol_header_id
          ,v_is_group
          ,v_end_date
          ,v_name_addend
      FROM p_policy            p
          ,p_pol_header        ph
          ,t_payment_terms     pt
          ,t_period            pp
          ,t_period            gp
          ,p_pol_addendum_type atd
          ,t_addendum_type     dd
     WHERE p.policy_id = p_p_policy_id
       AND p.pol_header_id = ph.policy_header_id
       AND p.payment_term_id = pt.id
       AND p.pol_privilege_period_id = gp.id(+)
       AND p.period_id = pp.id
       AND atd.p_policy_id(+) = p.policy_id
       AND dd.t_addendum_type_id(+) = atd.t_addendum_type_id;
  
    IF trunc(v_head_start_date, 'DD') > trunc(v_first_date, 'DD')
    THEN
      raise_application_error(-20100
                             ,'Дата 1-го платежа не должна быть раньше даты начала договора');
    END IF;
  
    IF v_num_of_pay >= 1
       AND trunc(v_first_date, 'DD') >= ADD_MONTHS(trunc(v_head_start_date, 'DD'), 12 / v_num_of_pay)
    THEN
      raise_application_error(-20100
                             ,'Дата 1-го платежа должна быть раньше окончания первого периода оплаты');
    END IF;
  
    -- Групповые договора. Счет на доплату. Проверка того, что в версиях договора
    -- не менялся признак группового договора и периодичность оплаты
    IF nvl(v_is_group, 0) = 1
    THEN
    
      DECLARE
        v_changed_cnt NUMBER;
      BEGIN
        SELECT COUNT(*)
          INTO v_changed_cnt
          FROM (SELECT nvl(p.is_group_flag, 0) is_group
                      ,nvl(p.payment_term_id, 0) pay_term
                      ,lead(p.is_group_flag) over(PARTITION BY p.pol_header_id ORDER BY policy_id ASC) next_is_group
                      ,lead(p.payment_term_id) over(PARTITION BY p.pol_header_id ORDER BY policy_id ASC) next_pay_term
                  FROM p_policy p
                 WHERE pol_header_id = v_pol_header_id) c
         WHERE nvl(c.next_is_group, c.is_group) <> c.is_group
            OR nvl(c.next_pay_term, c.pay_term) <> c.pay_term;
      
        IF v_changed_cnt != 0
        THEN
          raise_application_error(-20100
                                 ,'В версиях группового договора изменен признак группового договора или периодичность оплаты');
        END IF;
      END;
    
    END IF;
    -- Групповые договора. Счет на доплату.Получаю дату начала периода оплаты в который попадает
    -- дата версии
    v_period_date := pkg_payment.get_period_date(v_head_start_date, v_num_of_pay, v_start_date);
  
    IF (nvl(v_is_group, 0) = 0)
       AND (v_period_date <> v_start_date)
       AND (v_name_addend <> 'Услуга Финансовые каникулы')
    THEN
      raise_application_error(-20100
                             ,'Для не групповых договоров дата начала версии должна попадать в страховую годовщину');
    END IF;
  
    SELECT COUNT(*)
      INTO v_acc_cnt
      FROM doc_doc        dd
          ,ven_ac_payment d
          ,doc_templ      dt
          ,p_policy       p
     WHERE dd.parent_id = p.policy_id
       AND dd.child_id = d.payment_id
       AND dt.doc_templ_id = d.doc_templ_id
       AND p.pol_header_id = v_pol_header_id
       AND dt.brief IN ('PAYMENT', 'PAYMENT_SET_OFF', 'PAYORDBACK', 'PAYMENT_SET_OFF_ACC')
       AND d.plan_date >= p.start_date;
  
    IF v_acc_cnt = 0
    THEN
      charge_prodline_ar(p_p_policy_id) := 0;
    END IF;
  
    SELECT pc.contact_id
      INTO v_contact_id
      FROM p_policy_contact   pc
          ,t_contact_pol_role cpr
     WHERE pc.policy_id = p_p_policy_id
       AND pc.contact_policy_role_id = cpr.id
       AND cpr.brief = 'Страхователь';
  
    SELECT rt.rate_type_id INTO v_rev_rate_type_id FROM rate_type rt WHERE rt.brief = 'ЦБ';
  
    SELECT f.fund_id INTO v_rev_fund_id FROM fund f WHERE f.brief = 'RUR';
  
    SELECT cba.id
      INTO v_company_bank_acc_id
      FROM cn_contact_bank_acc cba
     WHERE cba.contact_id = pkg_app_param.get_app_param_u('WHOAMI')
       AND cba.id = (SELECT MAX(cbas.id)
                       FROM cn_contact_bank_acc cbas
                      WHERE cbas.contact_id = pkg_app_param.get_app_param_u('WHOAMI'));
  
    v_contact_bank_acc_id := NULL;
  
    -- Групповые договора. Дата начала может не попадать в страх.годовщину 
    v_start_plan_date := pkg_payment.get_period_date(v_head_start_date, 1, v_start_date);
    v_curr_year       := get_year_number(v_head_start_date, v_start_plan_date);
  
    IF v_is_period != 1
    THEN
      v_num_of_pay   := 1;
      v_curr_year    := 0;
      v_num_of_years := 1;
    END IF;
  
    v_first_date := ADD_MONTHS(v_first_date, v_curr_year * 12);
  
    --Цикл по годам
    FOR v_year_count IN v_curr_year .. CEIL(v_num_of_years) - 1
    LOOP
      -- если срок уплаты взносов дробный, то последний год график формировать не на весь год(кол-во платежей меньше)
      IF trunc(v_num_of_years) <> v_num_of_years
         AND v_year_count = CEIL(v_num_of_years) - 1
      THEN
        v_num_of_pay := (v_num_of_years - trunc(v_num_of_years)) * v_num_of_pay;
        IF trunc(v_num_of_pay) <> v_num_of_pay
        THEN
          raise_application_error(-20100
                                 ,'Ошибка формирования ГП.Срок уплаты взносов не кратен периодичности');
        END IF;
      END IF;
      --Цикл внутри года
      FOR v_pay_count IN 1 .. v_num_of_pay
      LOOP
      
        SELECT t.months_diff
              ,t.days_diff
          INTO v_months_diff
              ,v_days_diff
          FROM t_pay_term_details t
         WHERE t.payment_term_id = v_payment_terms_id
           AND t.payment_nr = v_pay_count;
      
        IF v_year_count = v_curr_year
           AND v_pay_count = 1
        THEN
          v_next_due_date  := v_first_date;
          v_next_plan_date := v_start_plan_date;
        ELSE
          v_next_due_date := ADD_MONTHS(v_first_date
                                       ,nvl(v_months_diff, 0) + (v_year_count - v_curr_year) * 12) +
                             nvl(v_days_diff, 0);
        
          v_next_plan_date := ADD_MONTHS(v_start_plan_date
                                        ,nvl(v_months_diff, 0) + (v_year_count - v_curr_year) * 12) +
                              nvl(v_days_diff, 0);
        END IF;
      
        --05/09/2009 изменил на дату план графика
        --Каткевич А.Г. не вижу смысла сравнивать с датой выставления?!!!
        --возможны косяки, которых сразу не видно!!!
        IF /*v_next_due_date*/
         v_next_plan_date < v_start_date
        THEN
          IF NOT ((v_num_of_pay = 1) AND (v_year_count = CEIL(v_num_of_years) - 1))
          THEN
            GOTO next_period;
          END IF;
        END IF;
      
        v_next_grace_date := v_next_due_date + v_grace_period;
      
        --Каткевич А.Г. 01/12/2008 В групповом договоре покрытие может оканчиваться не на дату план графика
        --Для подсчета нам понадобится дата сл. ЭПГ
        SELECT t.months_diff
              ,t.days_diff
          INTO v_months_diff
              ,v_days_diff
          FROM t_pay_term_details t
         WHERE t.payment_term_id = v_payment_terms_id
           AND t.payment_nr = decode(v_pay_count, v_num_of_pay, v_num_of_pay, v_pay_count + 1);
      
        v_next_next_plan_date := ADD_MONTHS(v_start_plan_date /*v_first_date*/
                                           ,nvl(v_months_diff, 0) + (v_year_count - v_curr_year) * 12) +
                                 nvl(v_days_diff, 0);
      
        v_rev_rate := acc_new.get_rate_by_id(v_rev_rate_type_id, v_fund_id, v_next_due_date);
      
        IF v_acc_cnt = 0
        THEN
          v_note := 'Первый платеж';
        ELSE
          v_note := 'RENLIFE';
        END IF;
      
        DECLARE
          v_end_per_date DATE;
          v_date         DATE;
        BEGIN
          IF nvl(v_is_period, 0) = 1
          THEN
            v_end_per_date := ADD_MONTHS(v_period_date, 12 / v_num_of_pay);
          ELSE
            v_end_per_date := trunc(v_end_date, 'DD') + 1;
          END IF;
        
          IF v_next_due_date > v_start_date
             AND ADD_MONTHS(v_next_due_date, -12 / v_num_of_pay) < v_start_date
             AND v_is_group = 1
             AND v_period_date <> v_start_date
          THEN
            calc_fee_delta(p_p_policy_id
                          ,v_start_date
                          ,v_return_sum
                          ,v_paym_sum
                          ,v_adm_cost
                          ,v_is_period
                          ,v_period_date
                          ,v_end_per_date);
            v_addition_acc := 1;
            GOTO create_acc;
          END IF;
        
          <<add_acc_created>>
        
          IF v_pay_count = 1
          THEN
            v_adm_cost := 1;
          ELSE
            v_adm_cost := 0;
          END IF;
        
          calc_fee_delta(p_p_policy_id
                        ,v_next_plan_date /*v_next_due_date*/
                        ,v_return_sum
                        ,v_paym_sum
                        ,v_adm_cost
                        ,v_is_period
                        ,NULL
                        ,v_next_next_plan_date);
        
          <<create_acc>>
        
          IF v_addition_acc = 1
          THEN
            v_date := v_start_date;
          ELSE
            v_date := v_next_due_date;
          END IF;
        
          IF ROUND(v_paym_sum, 2) > 0
          THEN
            v_acc_cnt    := v_acc_cnt + 1;
            v_payment_id := create_paymnt_by_templ(v_payment_templ_id
                                                  ,v_payment_terms_id
                                                  ,v_acc_cnt
                                                  ,v_date
                                                  ,v_next_grace_date
                                                  ,v_paym_sum
                                                  ,v_fund_id
                                                  ,ROUND(v_paym_sum * v_rev_rate * 100) / 100
                                                  ,v_rev_fund_id
                                                  ,v_rev_rate_type_id
                                                  ,v_rev_rate
                                                  ,v_contact_id
                                                  ,v_contact_bank_acc_id
                                                  ,v_company_bank_acc_id
                                                  ,v_note
                                                  ,p_p_policy_id
                                                  ,v_next_plan_date);
          END IF;
          IF ROUND(v_return_sum, 2) > 0
          THEN
            v_acc_cnt    := v_acc_cnt + 1;
            v_payment_id := create_paymnt_by_templ(v_payordback_templ_id
                                                  ,v_payment_terms_id
                                                  ,v_acc_cnt
                                                  ,v_date
                                                  ,v_next_grace_date
                                                  ,v_return_sum
                                                  ,v_fund_id
                                                  ,ROUND(v_return_sum * v_rev_rate * 100) / 100
                                                  ,v_rev_fund_id
                                                  ,v_rev_rate_type_id
                                                  ,v_rev_rate
                                                  ,v_contact_id
                                                  ,v_contact_bank_acc_id
                                                  ,v_company_bank_acc_id
                                                  ,v_note
                                                  ,p_p_policy_id
                                                  ,v_next_plan_date);
          END IF;
        
          IF v_addition_acc = 1
          THEN
            v_addition_acc := 0;
            GOTO add_acc_created;
          END IF;
        END;
        <<next_period>>
        NULL;
      END LOOP;
    END LOOP;
  END create_paymnt_sheduler_renlife;

  -- выставить счет на оплату взносов
  PROCEDURE set_invoice_to_pay(doc_id IN NUMBER) IS
    c                  NUMBER;
    v_is_del           NUMBER;
    id                 NUMBER;
    v_policy_id        NUMBER;
    v_claim_id         NUMBER;
    v_slip_id          NUMBER;
    v_cover_obj_id     NUMBER;
    v_cover_ent_id     NUMBER;
    v_oper_templ_id    NUMBER;
    v_is_accepted      NUMBER;
    v_premium_amount   NUMBER;
    v_decline_amount   NUMBER;
    v_plan_amount      NUMBER;
    v_count            NUMBER;
    v_amount           NUMBER;
    v_oper_count       NUMBER;
    v_oper_amount      NUMBER;
    v_delta_amount     NUMBER;
    v_total_amount     NUMBER;
    v_doc_amount       NUMBER;
    v_doc_templ_brief  VARCHAR2(30);
    v_parent_ent_brief VARCHAR2(30);
    v_doc_status_id    NUMBER;
    v_doc_status       doc_status%ROWTYPE;
  
    CURSOR c_oper IS
      SELECT (SELECT tt.trans_templ_id
                FROM trans_templ tt
               WHERE tt.trans_templ_id = apt.self_oper_templ_id)
            ,c.ent_id
            ,c.p_cover_id
            ,c.premium premium_amount
            ,nvl((SELECT SUM(t.acc_amount)
                   FROM trans       t
                       ,trans_templ tt
                       ,p_policy    pp
                  WHERE t.trans_templ_id = tt.trans_templ_id
                    AND tt.trans_templ_id = apt.self_oper_templ_id
                    AND t.a2_dt_uro_id = pp.policy_id
                    AND t.a3_dt_uro_id = ass.p_asset_header_id
                    AND t.a4_dt_uro_id = c.t_prod_line_option_id
                    AND pp.pol_header_id = p.pol_header_id)
                ,0) plan_amount
        FROM p_policy         p
            ,as_asset         ass
            ,status_hist      sh
            ,p_cover          c
            ,doc_doc          dd
            ,document         d
            ,doc_templ        dt
            ,ac_payment_templ apt
       WHERE ass.p_policy_id = p.policy_id
         AND ass.status_hist_id = sh.status_hist_id(+)
         AND sh.brief IN ('NEW', 'CURRENT')
         AND c.as_asset_id = ass.as_asset_id
         AND p.policy_id = dd.parent_id
         AND dd.child_id = d.document_id
         AND d.document_id = doc_id
         AND d.doc_templ_id = dt.doc_templ_id
         AND apt.doc_templ_id = dt.doc_templ_id;
  BEGIN
  
    v_doc_status_id := doc.get_last_doc_status_id(doc_id);
    IF v_doc_status_id IS NOT NULL
    THEN
      SELECT * INTO v_doc_status FROM doc_status ds WHERE ds.doc_status_id = v_doc_status_id;
    
      -- находим договор страхования по которому создан элемент плана графика
      BEGIN
        SELECT DISTINCT dd.parent_id INTO v_policy_id FROM doc_doc dd WHERE dd.child_id = doc_id;
      EXCEPTION
        WHEN OTHERS THEN
          raise_application_error(-20000, 'Не найден договор страхования!');
      END;
    
      -- создание операций
      BEGIN
        v_count  := 0;
        v_amount := 0;
        OPEN c_oper;
        LOOP
          FETCH c_oper
            INTO v_oper_templ_id
                ,v_cover_ent_id
                ,v_cover_obj_id
                ,v_premium_amount
                ,v_plan_amount;
          EXIT WHEN c_oper%NOTFOUND;
          IF (v_premium_amount > v_plan_amount)
          THEN
            v_count  := v_count + 1;
            v_amount := v_amount + v_premium_amount - v_plan_amount;
          END IF;
        END LOOP;
        CLOSE c_oper;
      
        SELECT p.amount INTO v_doc_amount FROM ac_payment p WHERE p.payment_id = doc_id;
      
        -- создаем операции по шаблону
        v_oper_count   := 0;
        v_total_amount := 0;
        OPEN c_oper;
        LOOP
          FETCH c_oper
            INTO v_oper_templ_id
                ,v_cover_ent_id
                ,v_cover_obj_id
                ,v_premium_amount
                ,v_plan_amount;
          EXIT WHEN c_oper%NOTFOUND;
          IF (v_premium_amount > v_plan_amount)
          THEN
            v_oper_count := v_oper_count + 1;
            IF v_oper_count <> v_count
            THEN
              v_oper_amount  := (v_premium_amount - v_plan_amount) * v_doc_amount / v_amount;
              v_oper_amount  := ROUND(v_oper_amount * 100) / 100;
              v_total_amount := v_total_amount + v_oper_amount;
            ELSE
              v_oper_amount := v_doc_amount - v_total_amount;
            END IF;
            id := acc_new.run_oper_by_template(v_oper_templ_id
                                              ,doc_id
                                              ,v_cover_ent_id
                                              ,v_cover_obj_id
                                              ,v_doc_status.doc_status_ref_id
                                              ,1
                                              ,v_oper_amount);
          END IF;
        END LOOP;
        CLOSE c_oper;
      EXCEPTION
        WHEN OTHERS THEN
          dbms_output.put_line(SQLERRM);
      END;
    END IF;
  END;

  PROCEDURE set_paym_setoffacc_status(doc_id IN NUMBER) IS
    v_policy_rec        ven_p_policy%ROWTYPE;
    v_paym_rec          ven_ac_payment%ROWTYPE;
    v_adm_cost          NUMBER := 0;
    v_date              DATE;
    v_return_sum        NUMBER;
    v_paym_sum          NUMBER;
    v_oper_sum          NUMBER;
    v_pl_delta          NUMBER;
    v_doc_status_ref_id NUMBER;
    v_oper_templ_id     NUMBER;
    v_oper_templ2_id    NUMBER;
    v_oper_id           NUMBER;
  BEGIN
    IF doc.get_last_doc_status_brief(doc_id) = 'TO_PAY'
    THEN
      SELECT p.*
        INTO v_policy_rec
        FROM ven_p_policy p
            ,doc_doc      d
       WHERE p.policy_id = d.parent_id
         AND d.child_id = doc_id;
      SELECT ap.* INTO v_paym_rec FROM ven_ac_payment ap WHERE ap.payment_id = doc_id;
      IF v_paym_rec.amount <= 0
      THEN
        RETURN;
      END IF;
      SELECT oper_templ_id
        INTO v_oper_templ_id
        FROM oper_templ
       WHERE brief = 'ВыстРаспоряжВозврат';
      SELECT oper_templ_id INTO v_oper_templ2_id FROM oper_templ WHERE brief = 'НачВозврат';
      v_date := v_policy_rec.start_date;
      WHILE v_date <= v_paym_rec.due_date
      LOOP
        IF v_date = v_paym_rec.due_date
        THEN
          v_adm_cost := 1;
        END IF;
        v_date := ADD_MONTHS(v_date, 12);
      END LOOP;
      SELECT doc_status_ref_id
        INTO v_doc_status_ref_id
        FROM doc_status
       WHERE doc_status_id = doc.get_last_doc_status_id(doc_id);
      calc_fee_delta(v_policy_rec.policy_id
                    ,v_paym_rec.plan_date
                    ,v_return_sum
                    ,v_paym_sum
                    ,v_adm_cost);
      FOR pl IN (SELECT plo.product_line_id
                       ,pl.brief
                       ,pc.ent_id
                       ,pc.p_cover_id id
                       ,a.as_asset_id
                   FROM p_cover            pc
                       ,as_asset           a
                       ,t_prod_line_option plo
                       ,t_product_line     pl
                  WHERE a.p_policy_id = v_policy_rec.policy_id
                    AND pc.as_asset_id = a.as_asset_id
                    AND plo.id = pc.t_prod_line_option_id
                    AND pl.id = plo.product_line_id
                    AND a.status_hist_id <> pkg_asset.status_hist_id_del
                    AND pc.status_hist_id <> pkg_cover.status_hist_id_del
                    AND pc.start_date <= v_paym_rec.due_date
                    AND pc.end_date >= v_paym_rec.due_date
                    AND (v_adm_cost = 1 OR upper(nvl(pl.brief, '?')) != 'ADMIN_EXPENCES'))
      LOOP
        v_pl_delta := calc_prodline_fee_delta( /*v_policy_rec.policy_id */pl.as_asset_id
                                             ,pl.product_line_id
                                             ,v_paym_rec.plan_date);
        IF v_pl_delta < 0
        THEN
          v_oper_sum := abs(v_pl_delta) * v_return_sum / v_paym_rec.amount;
          IF v_oper_sum != 0
          THEN
            v_oper_id := acc_new.run_oper_by_template(v_oper_templ_id
                                                     ,doc_id
                                                     ,pl.ent_id
                                                     ,pl.id
                                                     ,v_doc_status_ref_id
                                                     ,1
                                                     ,v_oper_sum);
            v_oper_id := acc_new.run_oper_by_template(v_oper_templ2_id
                                                     ,doc_id
                                                     ,pl.ent_id
                                                     ,pl.id
                                                     ,v_doc_status_ref_id
                                                     ,1
                                                     ,v_oper_sum);
          END IF;
        END IF;
      END LOOP;
    END IF;
  END;
  -- установить статус платежного документа

  PROCEDURE set_payment_status(doc_id IN NUMBER) IS
    TYPE t_ag_com_data IS RECORD(
       v_oper_templ_id NUMBER
      ,v_cover_ent_id  NUMBER
      ,v_cover_obj_id  NUMBER
      ,v_pac_id        NUMBER);
    TYPE t_ag_com_array IS TABLE OF t_ag_com_data INDEX BY BINARY_INTEGER;
    TYPE t_ag_com_arrays IS TABLE OF t_ag_com_array INDEX BY VARCHAR2(10);
    v_ag_com_arrays t_ag_com_arrays;
  
    id NUMBER;
    --    v_Parent_Doc_ID    number;
    v_cover_obj_id     NUMBER;
    v_cover_ent_id     NUMBER;
    v_oper_templ_id    NUMBER;
    v_is_accepted      NUMBER;
    v_real_amount      NUMBER;
    v_plan_amount      NUMBER;
    v_set_off_amount   NUMBER;
    v_self_amount      NUMBER;
    v_count            NUMBER;
    v_amount           NUMBER;
    v_oper_count       NUMBER;
    v_oper_amount      NUMBER;
    v_total_amount     NUMBER;
    v_doc_amount       NUMBER;
    v_doc_templ_brief  VARCHAR2(30);
    v_parent_ent_brief VARCHAR2(30);
    v_doc_status_id    NUMBER;
    v_doc_status       doc_status%ROWTYPE;
    v_is_storno        NUMBER(1);
    v_doc_status_ref   doc_status_ref%ROWTYPE;
    v_storno_amount    NUMBER;
    v_company_brief    VARCHAR2(30);
    v_doc_date         DATE;
    v_is_first         NUMBER;
    v_is_renlife       NUMBER;
    v_is_self          NUMBER;
    v_val_com          NUMBER;
    v_prod_line_id     NUMBER;
    v_st               NUMBER;
    v_key              NUMBER;
    v_comm_amt         NUMBER;
    v_payment_due_date DATE;
    v_pac_id           NUMBER;
  
    v_pol_id NUMBER;
    hashmap  utils.hashmap_t;
  
    CURSOR c_oper
    (
      cp_src_dsr_id NUMBER
     ,cp_dst_dsr_id NUMBER
    ) IS
      SELECT dsa.obj_uro_id oper_templ_id
            ,CASE
               WHEN dsa.obj_uro_id = sot.oper_templ_id THEN
                1
               ELSE
                0
             END is_self
            ,dsr.is_accepted
            ,c.ent_id
            ,c.p_cover_id
            ,c.premium premium_amount
            ,nvl((SELECT SUM(t.acc_amount)
                   FROM trans    t
                       ,p_policy pp
                  WHERE t.trans_templ_id = srott.trans_templ_id
                    AND t.a2_dt_uro_id = pp.policy_id
                    AND t.a3_dt_uro_id = ass.p_asset_header_id
                    AND t.a4_dt_uro_id = c.t_prod_line_option_id
                    AND pp.pol_header_id = p.pol_header_id
                    AND is_version_cover(p.policy_id
                                        ,t.a5_dt_uro_id
                                        ,ass.p_asset_header_id
                                        ,c.t_prod_line_option_id
                                        ,p.pol_header_id) = 1)
                ,0) plan_amount
            ,(SELECT nvl(SUM(t.acc_amount), 0)
                FROM oper     o
                    ,trans    t
                    ,p_policy pp
               WHERE d.document_id = o.document_id
                 AND o.oper_id = t.oper_id
                 AND t.trans_templ_id = srott.trans_templ_id
                 AND t.a2_dt_uro_id = pp.policy_id
                 AND t.a3_dt_uro_id = ass.p_asset_header_id
                 AND t.a4_dt_uro_id = c.t_prod_line_option_id
                 AND pp.pol_header_id = p.pol_header_id) self_amount
            ,(SELECT nvl(SUM(t.acc_amount), 0)
                FROM doc_set_off dso
                    ,oper        o
                    ,trans       t
                    ,p_policy    pp
               WHERE dso.parent_doc_id = d.document_id
                 AND dso.doc_set_off_id = o.document_id
                 AND o.oper_id = t.oper_id
                 AND t.trans_templ_id = drott.trans_templ_id
                 AND t.a2_ct_uro_id = pp.policy_id
                 AND t.a3_ct_uro_id = ass.p_asset_header_id
                 AND t.a4_ct_uro_id = c.t_prod_line_option_id
                 AND pp.pol_header_id = p.pol_header_id) set_off_amount
        FROM doc_doc              pdd
            ,p_policy             p
            ,as_asset             ass
            ,status_hist          sh
            ,p_cover              c
            ,doc_action_type      dat
            ,doc_doc              dd
            ,document             d
            ,doc_templ            dt
            ,doc_status_action    dsa
            ,doc_status_allowed   dsal
            ,doc_templ_status     sdts
            ,doc_templ_status     ddts
            ,doc_status_ref       dsr
            ,ac_payment           ap
            ,ac_payment_templ     apt
            ,oper_templ           dot
            ,rel_oper_trans_templ drott
            ,oper_templ           sot
            ,rel_oper_trans_templ srott
            ,oper_templ           ot
       WHERE pdd.parent_id = p.policy_id
         AND pdd.child_id = d.document_id
         AND ass.p_policy_id = p.policy_id
         AND ass.status_hist_id = sh.status_hist_id(+)
         AND sh.brief IN ('NEW', 'CURRENT')
         AND c.as_asset_id = ass.as_asset_id
         AND p.policy_id = dd.parent_id
         AND dd.child_id = d.document_id
         AND d.document_id = doc_id
         AND d.doc_templ_id = dt.doc_templ_id
         AND dt.doc_templ_id = sdts.doc_templ_id
         AND dt.doc_templ_id = ddts.doc_templ_id
         AND sdts.doc_status_ref_id = cp_src_dsr_id
         AND ddts.doc_status_ref_id = cp_dst_dsr_id
         AND dsa.doc_action_type_id = dat.doc_action_type_id
         AND dat.brief = 'OPER'
         AND dsa.is_execute = 0
         AND dsa.doc_status_allowed_id = dsal.doc_status_allowed_id
         AND dsal.src_doc_templ_status_id = sdts.doc_templ_status_id
         AND dsal.dest_doc_templ_status_id = ddts.doc_templ_status_id
         AND ddts.doc_status_ref_id = dsr.doc_status_ref_id
         AND d.document_id = ap.payment_id
         AND ap.payment_templ_id = apt.payment_templ_id
         AND apt.dso_oper_templ_id = dot.oper_templ_id
         AND dot.oper_templ_id = drott.oper_templ_id
         AND apt.self_oper_templ_id = sot.oper_templ_id
         AND sot.oper_templ_id = srott.oper_templ_id
         AND ot.oper_templ_id = dsa.obj_uro_id;
  
    CURSOR c_oper_renlife
    (
      cp_src_dsr_id NUMBER
     ,cp_dst_dsr_id NUMBER
     ,cp_doc_date   DATE
     ,cp_is_first   NUMBER
    ) IS
      SELECT dsa.obj_uro_id oper_templ_id
            ,CASE
               WHEN dsa.obj_uro_id = sot.oper_templ_id THEN
                1
               ELSE
                0
             END is_self
            ,dsr.is_accepted
            ,c.ent_id
            ,c.p_cover_id
            ,c.fee
            ,
             
             nvl((SELECT SUM(t.acc_amount)
                   FROM oper     o
                       ,trans    t
                       ,p_policy pp
                  WHERE t.oper_id = o.oper_id
                    AND t.trans_templ_id = srott.trans_templ_id
                    AND t.a2_dt_uro_id = pp.policy_id
                    AND t.a3_dt_uro_id = ass.p_asset_header_id
                    AND t.a4_dt_uro_id = c.t_prod_line_option_id
                    AND t.a5_dt_uro_id = c.p_cover_id
                    AND o.document_id = d.document_id
                    AND pp.pol_header_id = p.pol_header_id)
                ,0) plan_amount
            ,(SELECT nvl(SUM(t.acc_amount), 0)
                FROM oper     o
                    ,trans    t
                    ,p_policy pp
               WHERE d.document_id = o.document_id
                 AND o.oper_id = t.oper_id
                 AND t.trans_templ_id = srott.trans_templ_id
                 AND t.a2_dt_uro_id = pp.policy_id
                 AND t.a3_dt_uro_id = ass.p_asset_header_id
                 AND t.a4_dt_uro_id = c.t_prod_line_option_id
                 AND t.a5_dt_uro_id = c.p_cover_id
                 AND pp.pol_header_id = p.pol_header_id) self_amount
            ,(SELECT nvl(SUM(t.acc_amount), 0)
                FROM doc_set_off dso
                    ,oper        o
                    ,trans       t
                    ,p_policy    pp
               WHERE dso.parent_doc_id = d.document_id
                 AND dso.doc_set_off_id = o.document_id
                 AND o.oper_id = t.oper_id
                    --AND t.trans_templ_id = drott.trans_templ_id
                 AND t.a2_ct_uro_id = pp.policy_id
                 AND t.a3_ct_uro_id = ass.p_asset_header_id
                 AND t.a4_ct_uro_id = c.t_prod_line_option_id
                 AND t.a5_ct_uro_id = c.p_cover_id
                 AND pp.pol_header_id = p.pol_header_id) set_off_amount
        FROM p_policy             p
            ,as_asset             ass
            ,status_hist          sh
            ,p_cover              c
            ,doc_action_type      dat
            ,doc_doc              dd
            ,document             d
            ,doc_templ            dt
            ,doc_status_action    dsa
            ,doc_status_allowed   dsal
            ,doc_templ_status     sdts
            ,doc_templ_status     ddts
            ,doc_status_ref       dsr
            ,ac_payment           ap
            ,ac_payment_templ     apt
            ,oper_templ           dot
            ,rel_oper_trans_templ drott
            ,oper_templ           sot
            ,rel_oper_trans_templ srott
            ,t_prod_line_option   plo
            ,t_product_line       pl
            ,t_lob_line           ll
            ,oper_templ           ot
            ,status_hist          pc_sh
       WHERE ass.p_policy_id = p.policy_id
         AND ass.status_hist_id = sh.status_hist_id(+)
         AND sh.brief IN ('NEW', 'CURRENT')
         AND c.as_asset_id = ass.as_asset_id
         AND p.policy_id = dd.parent_id
         AND dd.child_id = d.document_id
         AND d.document_id = doc_id
         AND d.doc_templ_id = dt.doc_templ_id
         AND dt.doc_templ_id = sdts.doc_templ_id
         AND dt.doc_templ_id = ddts.doc_templ_id
         AND sdts.doc_status_ref_id = cp_src_dsr_id
         AND ddts.doc_status_ref_id = cp_dst_dsr_id
         AND dsa.doc_action_type_id = dat.doc_action_type_id
         AND dat.brief = 'OPER'
         AND dsa.is_execute = 0
         AND dsa.doc_status_allowed_id = dsal.doc_status_allowed_id
         AND dsal.src_doc_templ_status_id = sdts.doc_templ_status_id
         AND dsal.dest_doc_templ_status_id = ddts.doc_templ_status_id
         AND ddts.doc_status_ref_id = dsr.doc_status_ref_id
         AND d.document_id = ap.payment_id
         AND ap.payment_templ_id = apt.payment_templ_id
         AND apt.dso_oper_templ_id = dot.oper_templ_id
         AND dot.oper_templ_id = drott.oper_templ_id
         AND apt.self_oper_templ_id = sot.oper_templ_id
         AND sot.oper_templ_id = srott.oper_templ_id
         AND c.status_hist_id = pc_sh.status_hist_id
            --Каткевич А.Г. Испрален баг с неверным формированием проводок после отключения рисков!!!!
         AND pc_sh.brief IN ('NEW', 'CURRENT')
         AND c.start_date <= cp_doc_date
         AND c.end_date >= cp_doc_date
         AND c.t_prod_line_option_id = plo.id
         AND plo.product_line_id = pl.id
         AND pl.t_lob_line_id = ll.t_lob_line_id
         AND dsa.obj_uro_id = ot.oper_templ_id
         AND ot.brief <> 'МСФОВознаграждениеНачисленоСч'
         AND ((cp_is_first = 1) OR (cp_is_first = 0) AND (ll.brief NOT LIKE '%Adm_Cost%'));
  
    CURSOR c_oper_agent
    (
      cp_src_dsr_id NUMBER
     ,cp_dst_dsr_id NUMBER
    ) IS
      SELECT dsa.obj_uro_id           oper_templ_id
            ,1                        is_self
            ,dsr.is_accepted
            ,arc.ent_id
            ,arc.agent_report_cont_id
            ,arc.comission_sum        real_amount
            ,0                        plan_amount
            ,0                        self_amount
            ,0                        set_off_amount
        FROM agent_report       ar
            ,agent_report_cont  arc
            ,p_policy_agent_com pac
            ,doc_action_type    dat
            ,doc_doc            dd
            ,document           d
            ,doc_templ          dt
            ,doc_status_action  dsa
            ,doc_status_allowed dsal
            ,doc_templ_status   sdts
            ,doc_templ_status   ddts
            ,doc_status_ref     dsr
       WHERE arc.agent_report_id = ar.agent_report_id
         AND arc.p_policy_agent_com_id = pac.p_policy_agent_com_id
         AND ar.agent_report_id = dd.parent_id
         AND dd.child_id = d.document_id
         AND d.document_id = doc_id
         AND d.doc_templ_id = dt.doc_templ_id
         AND dt.doc_templ_id = sdts.doc_templ_id
         AND dt.doc_templ_id = ddts.doc_templ_id
         AND sdts.doc_status_ref_id = cp_src_dsr_id
         AND ddts.doc_status_ref_id = cp_dst_dsr_id
         AND dsa.doc_action_type_id = dat.doc_action_type_id
         AND dat.brief = 'OPER'
         AND dsa.is_execute = 0
         AND arc.is_deduct = 0
         AND dsa.doc_status_allowed_id = dsal.doc_status_allowed_id
         AND dsal.src_doc_templ_status_id = sdts.doc_templ_status_id
         AND dsal.dest_doc_templ_status_id = ddts.doc_templ_status_id
         AND ddts.doc_status_ref_id = dsr.doc_status_ref_id;
  
    CURSOR c_oper_back
    (
      cp_src_dsr_id NUMBER
     ,cp_dst_dsr_id NUMBER
    ) IS
      SELECT dsa.obj_uro_id oper_templ_id
            ,1 is_self
            ,dsr.is_accepted
            ,t.obj_ure_id
            ,t.obj_uro_id
            ,t.acc_amount real_amount
            ,nvl((SELECT SUM(xt.acc_amount)
                   FROM trans       xt
                       ,trans_templ xtt
                  WHERE xt.trans_templ_id = xtt.trans_templ_id
                    AND xtt.brief = 'УтвРаспВозврат'
                    AND xt.obj_ure_id = t.obj_ure_id
                    AND xt.obj_uro_id = t.obj_uro_id)
                ,0) plan_amount
            ,0 self_amount
            ,0 set_off_amount
        FROM trans              t
            ,trans_templ        tt
            ,oper               o
            ,p_policy           p
            ,p_policy           pd
            ,doc_doc            dd
            ,doc_action_type    dat
            ,document           d
            ,doc_templ          dt
            ,doc_status_action  dsa
            ,doc_status_allowed dsal
            ,doc_templ_status   sdts
            ,doc_templ_status   ddts
            ,doc_status_ref     dsr
       WHERE t.trans_templ_id = tt.trans_templ_id
         AND tt.brief = 'НачВозврат'
         AND t.oper_id = o.oper_id
         AND p.policy_id = o.document_id
         AND p.pol_header_id = pd.pol_header_id
         AND pd.policy_id = dd.parent_id
         AND dd.child_id = d.document_id
         AND d.document_id = doc_id
         AND d.doc_templ_id = dt.doc_templ_id
         AND dt.doc_templ_id = sdts.doc_templ_id
         AND dt.doc_templ_id = ddts.doc_templ_id
         AND sdts.doc_status_ref_id = cp_src_dsr_id
         AND ddts.doc_status_ref_id = cp_dst_dsr_id
         AND dsa.doc_action_type_id = dat.doc_action_type_id
         AND dat.brief = 'OPER'
         AND dsa.is_execute = 0
         AND dsa.doc_status_allowed_id = dsal.doc_status_allowed_id
         AND dsal.src_doc_templ_status_id = sdts.doc_templ_status_id
         AND dsal.dest_doc_templ_status_id = ddts.doc_templ_status_id
         AND ddts.doc_status_ref_id = dsr.doc_status_ref_id;
  
    CURSOR c_oper_lpu
    (
      cp_src_dsr_id NUMBER
     ,cp_dst_dsr_id NUMBER
    ) IS
      SELECT dsa.obj_uro_id oper_templ_id
            ,CASE
               WHEN dsa.obj_uro_id = sot.oper_templ_id THEN
                1
               ELSE
                0
             END is_self
            ,dsr.is_accepted
            ,c.ent_id
            ,c.p_cover_id
            ,c.premium premium_amount
            ,0 plan_amount
            ,0 self_amount
            ,0 set_off_amount
        FROM p_policy             p
            ,as_asset             ass
            ,status_hist          sh
            ,p_cover              c
            ,doc_action_type      dat
            ,doc_doc              dd
            ,document             d
            ,doc_templ            dt
            ,doc_status_action    dsa
            ,doc_status_allowed   dsal
            ,doc_templ_status     sdts
            ,doc_templ_status     ddts
            ,doc_status_ref       dsr
            ,ac_payment           ap
            ,ac_payment_templ     apt
            ,oper_templ           dot
            ,rel_oper_trans_templ drott
            ,oper_templ           sot
            ,rel_oper_trans_templ srott
       WHERE ass.p_policy_id = p.policy_id
         AND ass.status_hist_id = sh.status_hist_id(+)
         AND sh.brief IN ('NEW', 'CURRENT')
         AND c.as_asset_id = ass.as_asset_id
         AND p.policy_id = dd.parent_id
         AND dd.child_id = d.document_id
         AND d.document_id = doc_id
         AND d.doc_templ_id = dt.doc_templ_id
         AND dt.doc_templ_id = sdts.doc_templ_id
         AND dt.doc_templ_id = ddts.doc_templ_id
         AND sdts.doc_status_ref_id = cp_src_dsr_id
         AND ddts.doc_status_ref_id = cp_dst_dsr_id
         AND dsa.doc_action_type_id = dat.doc_action_type_id
         AND dat.brief = 'OPER'
         AND dsa.is_execute = 0
         AND dsa.doc_status_allowed_id = dsal.doc_status_allowed_id
         AND dsal.src_doc_templ_status_id = sdts.doc_templ_status_id
         AND dsal.dest_doc_templ_status_id = ddts.doc_templ_status_id
         AND ddts.doc_status_ref_id = dsr.doc_status_ref_id
         AND d.document_id = ap.payment_id
         AND ap.payment_templ_id = apt.payment_templ_id
         AND apt.dso_oper_templ_id = dot.oper_templ_id
         AND dot.oper_templ_id = drott.oper_templ_id
         AND apt.self_oper_templ_id = sot.oper_templ_id
         AND sot.oper_templ_id = srott.oper_templ_id;
  
    CURSOR c_oper_claim
    (
      cp_src_dsr_id NUMBER
     ,cp_dst_dsr_id NUMBER
    ) IS
      SELECT dsa.obj_uro_id oper_templ_id
            ,1 is_self
            ,dsr.is_accepted
            ,dam.ent_id
            ,dam.c_damage_id
            ,acc.get_cross_rate_by_id(1, dam.damage_fund_id, ch.fund_pay_id, c.claim_status_date) *
             dam.payment_sum premium_amount
            ,0 plan_amount
            ,0 self_amount
            ,0 set_off_amount
        FROM c_claim            c
            ,c_damage           dam
            ,status_hist        sh
            ,c_damage_status    ds
            ,c_claim_header     ch
            ,c_damage_type      cdt
            ,c_damage_cost_type cdct
            ,
             
             doc_action_type    dat
            ,doc_doc            dd
            ,document           d
            ,doc_templ          dt
            ,doc_status_action  dsa
            ,doc_status_allowed dsal
            ,doc_templ_status   sdts
            ,doc_templ_status   ddts
            ,doc_status_ref     dsr
       WHERE
      
       dam.c_claim_id = c.c_claim_id
       AND c.c_claim_id = dd.parent_id
       AND dam.c_damage_status_id = ds.c_damage_status_id
       AND dam.status_hist_id = sh.status_hist_id
       AND ds.brief IN ('ОТКРЫТ', 'ЗАКРЫТ')
       AND sh.brief IN ('NEW', 'CURRENT')
       AND dam.c_damage_type_id = cdt.c_damage_type_id
       AND dam.c_damage_cost_type_id = cdct.c_damage_cost_type_id(+)
       AND (cdt.brief = 'СТРАХОВОЙ' OR cdct.brief = 'ВОЗМЕЩАЕМЫЕ')
       AND ch.c_claim_header_id = c.c_claim_header_id
      
       AND dd.child_id = d.document_id
       AND d.document_id = doc_id
       AND d.doc_templ_id = dt.doc_templ_id
       AND dt.doc_templ_id = sdts.doc_templ_id
       AND dt.doc_templ_id = ddts.doc_templ_id
       AND sdts.doc_status_ref_id = cp_src_dsr_id
       AND ddts.doc_status_ref_id = cp_dst_dsr_id
       AND dsa.doc_action_type_id = dat.doc_action_type_id
       AND dat.brief = 'OPER'
       AND dsa.is_execute = 0
       AND dsa.doc_status_allowed_id = dsal.doc_status_allowed_id
       AND dsal.src_doc_templ_status_id = sdts.doc_templ_status_id
       AND dsal.dest_doc_templ_status_id = ddts.doc_templ_status_id
       AND ddts.doc_status_ref_id = dsr.doc_status_ref_id;
  
    CURSOR c_oper_subrog
    (
      cp_src_dsr_id NUMBER
     ,cp_dst_dsr_id NUMBER
    ) IS
      SELECT dsa.obj_uro_id  oper_templ_id
            ,1               is_self
            ,dsr.is_accepted
            ,dam.ent_id
            ,dam.c_damage_id
            ,dam.payment_sum premium_amount
            ,0               plan_amount
            ,0               self_amount
            ,0               set_off_amount
        FROM c_claim            c
            ,c_damage           dam
            ,status_hist        sh
            ,c_damage_status    ds
            ,c_claim_header     ch
            ,c_subr_doc         csd
            ,doc_action_type    dat
            ,doc_doc            dd
            ,document           d
            ,doc_templ          dt
            ,doc_status_action  dsa
            ,doc_status_allowed dsal
            ,doc_templ_status   sdts
            ,doc_templ_status   ddts
            ,doc_status_ref     dsr
       WHERE
      
       dam.c_claim_id = c.c_claim_id
       AND csd.c_subr_doc_id = dd.parent_id
       AND dam.c_damage_status_id = ds.c_damage_status_id
       AND dam.status_hist_id = sh.status_hist_id
       AND ds.brief IN ('ОТКРЫТ', 'ЗАКРЫТ')
       AND sh.brief IN ('NEW', 'CURRENT')
       AND ch.c_claim_header_id = c.c_claim_header_id
       AND csd.c_claim_header_id = ch.c_claim_header_id
      
       AND dd.child_id = d.document_id
       AND d.document_id = doc_id
       AND d.doc_templ_id = dt.doc_templ_id
       AND dt.doc_templ_id = sdts.doc_templ_id
       AND dt.doc_templ_id = ddts.doc_templ_id
       AND sdts.doc_status_ref_id = cp_src_dsr_id
       AND ddts.doc_status_ref_id = cp_dst_dsr_id
       AND dsa.doc_action_type_id = dat.doc_action_type_id
       AND dat.brief = 'OPER'
       AND dsa.is_execute = 0
       AND dsa.doc_status_allowed_id = dsal.doc_status_allowed_id
       AND dsal.src_doc_templ_status_id = sdts.doc_templ_status_id
       AND dsal.dest_doc_templ_status_id = ddts.doc_templ_status_id
       AND ddts.doc_status_ref_id = dsr.doc_status_ref_id;
  
    CURSOR c_oper_comm(cp_prod_line_id NUMBER) IS
      SELECT ot.oper_templ_id
            ,ca.ent_id
            ,ca.cover_agent_id
            ,ppac.p_policy_agent_com_id
        FROM doc_doc            dd
            ,p_policy           p
            ,p_policy_agent     ppa
            ,p_policy_agent_com ppac
            ,p_cover_agent      ca
            ,as_asset           aa
            ,p_cover            pc
            ,t_prod_line_option plo
            ,oper_templ         ot
       WHERE ot.brief = 'МСФОВознаграждениеНачисленоСч'
         AND ca.p_policy_agent_com_id = ppac.p_policy_agent_com_id
         AND dd.child_id = doc_id
         AND aa.p_policy_id = p.policy_id
         AND aa.as_asset_id = pc.as_asset_id
         AND dd.parent_id = p.policy_id
         AND p.pol_header_id = ppa.policy_header_id
         AND ppa.p_policy_agent_id = ppac.p_policy_agent_id
         AND ppac.t_product_line_id = cp_prod_line_id
         AND pc.p_cover_id = ca.cover_id
         AND pc.t_prod_line_option_id = plo.id
         AND plo.product_line_id = cp_prod_line_id;
  
  BEGIN
    hashmap.delete;
    tariff_calc_cache.delete;
    ag_comm_cache.delete;
    SELECT plan_date INTO v_payment_due_date FROM ac_payment WHERE payment_id = doc_id;
    v_doc_status_id := doc.get_last_doc_status_id(doc_id);
  
    SELECT ap.grace_date
          ,CASE
             WHEN ap.note = 'Первый платеж' THEN
              1
             ELSE
              0
           END
      INTO v_doc_date
          ,v_is_first
      FROM ven_ac_payment ap
     WHERE ap.payment_id = doc_id;
  
    IF v_doc_status_id IS NOT NULL
    THEN
    
      SELECT * INTO v_doc_status FROM doc_status ds WHERE ds.doc_status_id = v_doc_status_id;
    
      SELECT *
        INTO v_doc_status_ref
        FROM doc_status_ref dsr
       WHERE dsr.doc_status_ref_id = v_doc_status.doc_status_ref_id;
    
      SELECT c.short_name
        INTO v_company_brief
        FROM contact c
       WHERE c.contact_id = pkg_app_param.get_app_param_u('WHOAMI');
    
      IF v_doc_status_ref.brief IN ('PAID', 'ANNULATED')
      THEN
        v_is_storno := 1;
      ELSE
        v_is_storno := 0;
      END IF;
    
      BEGIN
        SELECT DISTINCT e.brief
          INTO v_parent_ent_brief
          FROM entity   e
              ,document d
              ,doc_doc  dd
         WHERE dd.child_id = doc_id
           AND dd.parent_id = d.document_id
           AND d.ent_id = e.ent_id;
      EXCEPTION
        WHEN OTHERS THEN
          v_parent_ent_brief := NULL;
      END;
    
      BEGIN
        SELECT dt.brief
          INTO v_doc_templ_brief
          FROM document  d
              ,doc_templ dt
         WHERE d.document_id = doc_id
           AND d.doc_templ_id = dt.doc_templ_id
           AND dt.brief IN ('PAYMENT'
                           ,'PAYORDBACK'
                           ,'PAYMENT_SETOFF'
                           ,'PAYMENT_SETOFF_ACC'
                           ,'PAYAGENT'
                           ,'PAYORDLPU'
                           ,'PAYORDER'
                           ,'PAYORDER_SETOFF'
                           ,'AccPayRegress');
      EXCEPTION
        WHEN OTHERS THEN
          v_doc_templ_brief := NULL;
      END;
    
      IF (pkg_app_param.get_app_param_n('CLIENTID') = 11)
         AND (v_payment_due_date IS NULL)
         AND (v_doc_templ_brief IN ('PAYMENT', 'PAYMENT_SETOFF_ACC'))
      THEN
        raise_application_error(-20100
                               ,'Невозможно начислить по документу. Не задана дата план-графика.');
      END IF;
    
      -- Ф.Ганичев
      -- Определяет первый платеж
      IF pkg_app_param.get_app_param_n('CLIENTID') = 10
      THEN
        v_is_first := 1;
      END IF;
      IF v_is_first != 1
         AND v_doc_templ_brief IN ('PAYMENT', 'PAYMENT_SETOFF', 'PAYMENT_SETOFF_ACC')
      THEN
        v_is_first := is_first_acc(doc_id);
      END IF;
    
      IF v_doc_templ_brief = 'PAYMENT_SETOFF_ACC'
      THEN
        set_paym_setoffacc_status(doc_id);
        RETURN;
      END IF;
      -- находим исходный документ, по которым совершен платеж
      v_is_renlife := 0;
    
      CASE
        WHEN v_parent_ent_brief = 'P_POLICY' THEN
          /*
          SELECT COUNT(*)
            INTO v_Is_Renlife
            FROM DOC_DOC                pdd,
                 ven_as_asset           a,
                 ven_p_cover            pc,
                 ven_t_prod_line_option plo,
                 ven_t_product_line     pl,
                 ven_t_product_ver_lob  pvl,
                 ven_t_lob_line         ll,
                 ven_t_insurance_group  ig
           WHERE a.p_policy_id = pdd.parent_id
             AND pdd.child_id = doc_id
             AND a.as_asset_id = pc.as_asset_id
             AND pc.t_prod_line_option_id = plo.id
             AND plo.product_line_id = pl.id
             AND pl.product_ver_lob_id = pvl.t_product_ver_lob_id
             AND pl.t_lob_line_id = ll.t_lob_line_id
             AND pvl.lob_id = ll.t_lob_id
             AND ll.insurance_group_id = ig.t_insurance_group_id
             AND ig.life_property = 1;
          
          IF v_Is_Renlife > 0 THEN
            v_Is_Renlife := 1;
          END IF;*/
          IF pkg_app_param.get_app_param_n('CLIENTID') = 11
          THEN
            v_is_renlife := 1;
          END IF;
        ELSE
          NULL;
      END CASE;
    
      -- создание операций(проводок) для этого статуса документа
      BEGIN
      
        IF v_doc_templ_brief IS NOT NULL
        THEN
        
          v_count  := 0;
          v_amount := 0;
          SELECT SUM(dd.parent_amount)
            INTO v_doc_amount
            FROM ac_payment ap
                ,doc_doc    dd
           WHERE ap.payment_id = doc_id
             AND ap.payment_id = dd.child_id;
          CASE
            WHEN v_doc_templ_brief = 'PAYMENT'
                 AND v_is_renlife = 1 THEN
              OPEN c_oper_renlife(v_doc_status.src_doc_status_ref_id
                                 ,v_doc_status.doc_status_ref_id
                                 ,v_doc_date
                                 ,v_is_first);
            WHEN v_doc_templ_brief = 'PAYMENT'
                 AND v_is_renlife = 0 THEN
              OPEN c_oper(v_doc_status.src_doc_status_ref_id, v_doc_status.doc_status_ref_id);
            WHEN v_doc_templ_brief IN ('PAYORDBACK', 'PAYMENT_SETOFF') THEN
              OPEN c_oper_back(v_doc_status.src_doc_status_ref_id, v_doc_status.doc_status_ref_id);
            WHEN v_doc_templ_brief = 'PAYAGENT' THEN
              OPEN c_oper_agent(v_doc_status.src_doc_status_ref_id, v_doc_status.doc_status_ref_id);
            WHEN v_doc_templ_brief = 'PAYORDLPU' THEN
              OPEN c_oper_lpu(v_doc_status.src_doc_status_ref_id, v_doc_status.doc_status_ref_id);
            WHEN v_doc_templ_brief IN ('PAYORDER', 'PAYORDER_SETOFF') THEN
              OPEN c_oper_claim(v_doc_status.src_doc_status_ref_id, v_doc_status.doc_status_ref_id);
            WHEN v_doc_templ_brief = 'AccPayRegress' THEN
              OPEN c_oper_subrog(v_doc_status.src_doc_status_ref_id, v_doc_status.doc_status_ref_id);
            ELSE
              NULL;
          END CASE;
          LOOP
            CASE
              WHEN v_doc_templ_brief = 'PAYMENT'
                   AND v_is_renlife = 1 THEN
                FETCH c_oper_renlife
                  INTO v_oper_templ_id
                      ,v_is_self
                      ,v_is_accepted
                      ,v_cover_ent_id
                      ,v_cover_obj_id
                      ,v_real_amount
                      ,v_plan_amount
                      ,v_self_amount
                      ,v_set_off_amount;
                EXIT WHEN c_oper_renlife%NOTFOUND;
                -- Ф.Ганичев. По-другому считает сумму уже начисленного по покрытию
                v_plan_amount := utils.get_null(hashmap, 'ACC_' || v_cover_obj_id);
                IF v_plan_amount IS NULL
                THEN
                  v_plan_amount := get_charge_prodline_amount(v_cover_obj_id, v_payment_due_date, v_payment_due_date)
                                   .fund_amount;
                  hashmap('ACC_' || v_cover_obj_id) := v_plan_amount;
                END IF;
                ------------------
              WHEN v_doc_templ_brief = 'PAYMENT'
                   AND v_is_renlife = 0 THEN
                FETCH c_oper
                  INTO v_oper_templ_id
                      ,v_is_self
                      ,v_is_accepted
                      ,v_cover_ent_id
                      ,v_cover_obj_id
                      ,v_real_amount
                      ,v_plan_amount
                      ,v_self_amount
                      ,v_set_off_amount;
                EXIT WHEN c_oper%NOTFOUND;
              WHEN v_doc_templ_brief IN ('PAYORDBACK', 'PAYMENT_SETOFF') THEN
                FETCH c_oper_back
                  INTO v_oper_templ_id
                      ,v_is_self
                      ,v_is_accepted
                      ,v_cover_ent_id
                      ,v_cover_obj_id
                      ,v_real_amount
                      ,v_plan_amount
                      ,v_self_amount
                      ,v_set_off_amount;
                EXIT WHEN c_oper_back%NOTFOUND;
              WHEN v_doc_templ_brief = 'PAYAGENT' THEN
                FETCH c_oper_agent
                  INTO v_oper_templ_id
                      ,v_is_self
                      ,v_is_accepted
                      ,v_cover_ent_id
                      ,v_cover_obj_id
                      ,v_real_amount
                      ,v_plan_amount
                      ,v_self_amount
                      ,v_set_off_amount;
                EXIT WHEN c_oper_agent%NOTFOUND;
              WHEN v_doc_templ_brief = 'PAYORDLPU' THEN
                FETCH c_oper_lpu
                  INTO v_oper_templ_id
                      ,v_is_self
                      ,v_is_accepted
                      ,v_cover_ent_id
                      ,v_cover_obj_id
                      ,v_real_amount
                      ,v_plan_amount
                      ,v_self_amount
                      ,v_set_off_amount;
                EXIT WHEN c_oper_lpu%NOTFOUND;
              WHEN v_doc_templ_brief IN ('PAYORDER', 'PAYORDER_SETOFF') THEN
                FETCH c_oper_claim
                  INTO v_oper_templ_id
                      ,v_is_self
                      ,v_is_accepted
                      ,v_cover_ent_id
                      ,v_cover_obj_id
                      ,v_real_amount
                      ,v_plan_amount
                      ,v_self_amount
                      ,v_set_off_amount;
                EXIT WHEN c_oper_claim%NOTFOUND;
              WHEN v_doc_templ_brief = 'AccPayRegress' THEN
                FETCH c_oper_subrog
                  INTO v_oper_templ_id
                      ,v_is_self
                      ,v_is_accepted
                      ,v_cover_ent_id
                      ,v_cover_obj_id
                      ,v_real_amount
                      ,v_plan_amount
                      ,v_self_amount
                      ,v_set_off_amount;
                EXIT WHEN c_oper_subrog%NOTFOUND;
              ELSE
                NULL;
            END CASE;
            IF v_is_self = 1
            THEN
              IF (v_real_amount > v_plan_amount)
              THEN
                v_count  := v_count + 1;
                v_amount := v_amount + v_real_amount - v_plan_amount;
              END IF;
            END IF;
          END LOOP;
          CASE
            WHEN v_doc_templ_brief = 'PAYMENT'
                 AND v_is_renlife = 1 THEN
              CLOSE c_oper_renlife;
            WHEN v_doc_templ_brief = 'PAYMENT'
                 AND v_is_renlife = 0 THEN
              CLOSE c_oper;
            WHEN v_doc_templ_brief IN ('PAYORDBACK', 'PAYMENT_SETOFF') THEN
              CLOSE c_oper_back;
            WHEN v_doc_templ_brief = 'PAYAGENT' THEN
              CLOSE c_oper_agent;
            WHEN v_doc_templ_brief = 'PAYORDLPU' THEN
              CLOSE c_oper_lpu;
            WHEN v_doc_templ_brief IN ('PAYORDER', 'PAYORDER_SETOFF') THEN
              CLOSE c_oper_claim;
            WHEN v_doc_templ_brief = 'AccPayRegress' THEN
              CLOSE c_oper_subrog;
            ELSE
              NULL;
          END CASE;
        
          -- создаем операции по шаблону
          v_oper_count   := 0;
          v_total_amount := 0;
        
          CASE
            WHEN v_doc_templ_brief = 'PAYMENT'
                 AND v_is_renlife = 1 THEN
              OPEN c_oper_renlife(v_doc_status.src_doc_status_ref_id
                                 ,v_doc_status.doc_status_ref_id
                                 ,v_doc_date
                                 ,v_is_first);
            WHEN v_doc_templ_brief = 'PAYMENT'
                 AND v_is_renlife = 0 THEN
              OPEN c_oper(v_doc_status.src_doc_status_ref_id, v_doc_status.doc_status_ref_id);
            WHEN v_doc_templ_brief IN ('PAYORDBACK', 'PAYMENT_SETOFF') THEN
              OPEN c_oper_back(v_doc_status.src_doc_status_ref_id, v_doc_status.doc_status_ref_id);
            WHEN v_doc_templ_brief = 'PAYAGENT' THEN
              OPEN c_oper_agent(v_doc_status.src_doc_status_ref_id, v_doc_status.doc_status_ref_id);
            WHEN v_doc_templ_brief = 'PAYORDLPU' THEN
              OPEN c_oper_lpu(v_doc_status.src_doc_status_ref_id, v_doc_status.doc_status_ref_id);
            WHEN v_doc_templ_brief IN ('PAYORDER', 'PAYORDER_SETOFF') THEN
              OPEN c_oper_claim(v_doc_status.src_doc_status_ref_id, v_doc_status.doc_status_ref_id);
            WHEN v_doc_templ_brief = 'AccPayRegress' THEN
              OPEN c_oper_subrog(v_doc_status.src_doc_status_ref_id, v_doc_status.doc_status_ref_id);
            ELSE
              NULL;
          END CASE;
          <<outer_loop>>
          LOOP
            CASE
              WHEN v_doc_templ_brief = 'PAYMENT'
                   AND v_is_renlife = 1 THEN
                FETCH c_oper_renlife
                  INTO v_oper_templ_id
                      ,v_is_self
                      ,v_is_accepted
                      ,v_cover_ent_id
                      ,v_cover_obj_id
                      ,v_real_amount
                      ,v_plan_amount
                      ,v_self_amount
                      ,v_set_off_amount;
                EXIT WHEN c_oper_renlife%NOTFOUND;
                -- Ф.Ганичев. По-другому считает сумму уже начисленного по покрытию
              
                v_plan_amount := utils.get_null(hashmap, 'ACC_' || v_cover_obj_id);
                IF v_plan_amount IS NULL
                THEN
                  v_plan_amount := get_charge_prodline_amount(v_cover_obj_id, v_payment_due_date, v_payment_due_date)
                                   .fund_amount;
                  hashmap('ACC_' || v_cover_obj_id) := v_plan_amount;
                END IF;
                ------------------
              WHEN v_doc_templ_brief = 'PAYMENT'
                   AND v_is_renlife = 0 THEN
                FETCH c_oper
                  INTO v_oper_templ_id
                      ,v_is_self
                      ,v_is_accepted
                      ,v_cover_ent_id
                      ,v_cover_obj_id
                      ,v_real_amount
                      ,v_plan_amount
                      ,v_self_amount
                      ,v_set_off_amount;
                EXIT WHEN c_oper%NOTFOUND;
              WHEN v_doc_templ_brief IN ('PAYORDBACK', 'PAYMENT_SETOFF') THEN
                FETCH c_oper_back
                  INTO v_oper_templ_id
                      ,v_is_self
                      ,v_is_accepted
                      ,v_cover_ent_id
                      ,v_cover_obj_id
                      ,v_real_amount
                      ,v_plan_amount
                      ,v_self_amount
                      ,v_set_off_amount;
                EXIT WHEN c_oper_back%NOTFOUND;
              WHEN v_doc_templ_brief = 'PAYAGENT' THEN
                FETCH c_oper_agent
                  INTO v_oper_templ_id
                      ,v_is_self
                      ,v_is_accepted
                      ,v_cover_ent_id
                      ,v_cover_obj_id
                      ,v_real_amount
                      ,v_plan_amount
                      ,v_self_amount
                      ,v_set_off_amount;
                EXIT WHEN c_oper_agent%NOTFOUND;
              WHEN v_doc_templ_brief = 'PAYORDLPU' THEN
                FETCH c_oper_lpu
                  INTO v_oper_templ_id
                      ,v_is_self
                      ,v_is_accepted
                      ,v_cover_ent_id
                      ,v_cover_obj_id
                      ,v_real_amount
                      ,v_plan_amount
                      ,v_self_amount
                      ,v_set_off_amount;
                EXIT WHEN c_oper_lpu%NOTFOUND;
              WHEN v_doc_templ_brief IN ('PAYORDER', 'PAYORDER_SETOFF') THEN
                FETCH c_oper_claim
                  INTO v_oper_templ_id
                      ,v_is_self
                      ,v_is_accepted
                      ,v_cover_ent_id
                      ,v_cover_obj_id
                      ,v_real_amount
                      ,v_plan_amount
                      ,v_self_amount
                      ,v_set_off_amount;
                EXIT WHEN c_oper_claim%NOTFOUND;
              WHEN v_doc_templ_brief = 'AccPayRegress' THEN
                FETCH c_oper_subrog
                  INTO v_oper_templ_id
                      ,v_is_self
                      ,v_is_accepted
                      ,v_cover_ent_id
                      ,v_cover_obj_id
                      ,v_real_amount
                      ,v_plan_amount
                      ,v_self_amount
                      ,v_set_off_amount;
                EXIT WHEN c_oper_subrog%NOTFOUND;
              ELSE
                NULL;
            END CASE;
          
            IF v_is_storno = 0
            THEN
              IF (v_real_amount > v_plan_amount)
              THEN
                --                v_Oper_Count := v_Oper_Count + 1;
                --                if v_Oper_Count <> v_Count then
                v_oper_amount := (v_real_amount - v_plan_amount) * v_doc_amount / v_amount;
                v_oper_amount := ROUND(v_oper_amount * 100) / 100;
                --                  v_Total_Amount := v_Total_Amount + v_Oper_Amount;
                --                else
                --                  v_Oper_Amount := v_Doc_Amount - v_Total_Amount;
                --                end if;
                id := acc_new.run_oper_by_template(v_oper_templ_id
                                                  ,doc_id
                                                  ,v_cover_ent_id
                                                  ,v_cover_obj_id
                                                  ,v_doc_status.doc_status_ref_id
                                                  ,1
                                                  ,v_oper_amount);
                IF v_doc_templ_brief = 'PAYMENT'
                   AND v_is_renlife = 1
                   AND v_is_self = 1
                THEN
                  SELECT plo.product_line_id
                    INTO v_prod_line_id
                    FROM p_cover            pc
                        ,t_prod_line_option plo
                   WHERE pc.p_cover_id = v_cover_obj_id
                     AND pc.t_prod_line_option_id = plo.id;
                  SELECT a.p_policy_id
                    INTO v_pol_id
                    FROM as_asset a
                        ,p_cover  pc
                   WHERE pc.as_asset_id = a.as_asset_id
                     AND pc.p_cover_id = v_cover_obj_id;
                  dbms_output.put_line('PROD_LINE_ID=' || v_prod_line_id || ', DOC_ID=' || doc_id);
                  pkg_agent_rate.date_pay := to_char(v_doc_date, 'dd.mm.yyyy');
                
                  IF (NOT v_ag_com_arrays.exists(v_prod_line_id))
                  THEN
                    DECLARE
                      ii NUMBER := 1;
                    BEGIN
                      OPEN c_oper_comm(v_prod_line_id);
                      LOOP
                        FETCH c_oper_comm
                          INTO v_oper_templ_id
                              ,v_cover_ent_id
                              ,v_cover_obj_id
                              ,v_pac_id;
                        EXIT WHEN c_oper_comm%NOTFOUND;
                        v_ag_com_arrays(v_prod_line_id)(ii).v_oper_templ_id := v_oper_templ_id;
                        v_ag_com_arrays(v_prod_line_id)(ii).v_cover_ent_id := v_cover_ent_id;
                        v_ag_com_arrays(v_prod_line_id)(ii).v_cover_obj_id := v_cover_obj_id;
                        v_ag_com_arrays(v_prod_line_id)(ii).v_pac_id := v_pac_id;
                        ii := ii + 1;
                      END LOOP;
                      CLOSE c_oper_comm;
                    END;
                  END IF;
                  <<inner_loop>>
                  IF (v_ag_com_arrays.exists(v_prod_line_id))
                  THEN
                    FOR iii IN 1 .. v_ag_com_arrays(v_prod_line_id).count
                    LOOP
                    
                      --  FETCH c_Oper_Comm INTO v_Oper_Templ_ID, v_Cover_Ent_ID, v_Cover_Obj_ID, v_pac_id;
                      --  EXIT WHEN c_Oper_Comm%NOTFOUND;
                    
                      --  v_oper_templ_id:=agcom.oper_templ_id;
                      --  v_Cover_Ent_ID:= agcom.ent_id;
                      --  v_Cover_Obj_ID:=agcom.cover_agent_id;
                      --  v_pac_id:= agcom.p_policy_agent_com_id;
                    
                      v_oper_templ_id := v_ag_com_arrays(v_prod_line_id)(iii).v_oper_templ_id;
                      v_cover_ent_id  := v_ag_com_arrays(v_prod_line_id)(iii).v_cover_ent_id;
                      v_cover_obj_id  := v_ag_com_arrays(v_prod_line_id)(iii).v_cover_obj_id;
                      v_pac_id        := v_ag_com_arrays(v_prod_line_id)(iii).v_pac_id;
                    
                      v_st := utils.get_null(ag_comm_cache
                                            ,'AG_COMM_VST' || v_pac_id || ' ' ||
                                             pkg_agent_rate.date_pay);
                      IF v_st IS NULL
                      THEN
                        pkg_agent_rate.av_oav_pol_ag_com(v_pac_id
                                                        ,pkg_agent_rate.date_pay
                                                        ,v_st
                                                        ,v_key);
                        ag_comm_cache('AG_COMM_VST' || v_pac_id || ' ' || pkg_agent_rate.date_pay) := v_st;
                        ag_comm_cache('AG_COMM_VKEY' || v_pac_id || ' ' || pkg_agent_rate.date_pay) := v_key;
                      ELSE
                        v_key := utils.get_null(ag_comm_cache
                                               ,'AG_COMM_VKEY' || v_pac_id || ' ' ||
                                                pkg_agent_rate.date_pay);
                      END IF;
                      IF v_key = 0
                      THEN
                        v_comm_amt := ROUND(v_oper_amount * v_st / 100, 2);
                      ELSE
                        v_comm_amt := v_st;
                      END IF;
                    
                      IF v_comm_amt > 0
                      THEN
                      
                        id := acc_new.run_oper_by_template(v_oper_templ_id
                                                          ,doc_id
                                                          ,v_cover_ent_id
                                                          ,v_cover_obj_id
                                                          ,v_doc_status.doc_status_ref_id
                                                          ,1
                                                          ,v_comm_amt);
                      END IF;
                    END LOOP inner_loop;
                  END IF;
                  --CLOSE c_Oper_Comm;
                
                END IF;
              END IF;
            ELSE
              v_storno_amount := v_self_amount - v_set_off_amount;
              IF v_storno_amount > 0
              THEN
              
                IF (v_oper_templ_id = 2322)
                THEN
                
                  IF (to_char(pkg_financy_weekend_fo.getduedate(doc_id), 'YYYY') =
                     to_char(SYSDATE, 'YYYY'))
                  THEN
                  
                    id := acc_new.run_oper_by_template(v_oper_templ_id
                                                      ,doc_id
                                                      ,v_cover_ent_id
                                                      ,v_cover_obj_id
                                                      ,v_doc_status.doc_status_ref_id
                                                      ,1
                                                      ,-v_storno_amount);
                  ELSE
                    id := acc_new.run_oper_by_template(v_rsbu_stnachprem_templ_id
                                                      ,doc_id
                                                      ,v_cover_ent_id
                                                      ,v_cover_obj_id
                                                      ,v_doc_status.doc_status_ref_id
                                                      ,1
                                                      ,v_storno_amount);
                  
                  END IF;
                
                ELSE
                
                  id := acc_new.run_oper_by_template(v_oper_templ_id
                                                    ,doc_id
                                                    ,v_cover_ent_id
                                                    ,v_cover_obj_id
                                                    ,v_doc_status.doc_status_ref_id
                                                    ,1
                                                    ,-v_storno_amount);
                
                END IF;
              
              END IF;
            END IF;
          
          END LOOP outer_loop;
          CASE
            WHEN v_doc_templ_brief = 'PAYMENT'
                 AND v_is_renlife = 1 THEN
              CLOSE c_oper_renlife;
            WHEN v_doc_templ_brief = 'PAYMENT'
                 AND v_is_renlife = 0 THEN
              CLOSE c_oper;
            WHEN v_doc_templ_brief IN ('PAYORDBACK', 'PAYMENT_SETOFF') THEN
              CLOSE c_oper_back;
            WHEN v_doc_templ_brief = 'PAYAGENT' THEN
              CLOSE c_oper_agent;
            WHEN v_doc_templ_brief = 'PAYORDLPU' THEN
              CLOSE c_oper_lpu;
            WHEN v_doc_templ_brief IN ('PAYORDER', 'PAYORDER_SETOFF') THEN
              CLOSE c_oper_claim;
            WHEN v_doc_templ_brief = 'AccPayRegress' THEN
              CLOSE c_oper_subrog;
            ELSE
              NULL;
          END CASE;
        
        END IF;
        /*
        EXCEPTION
          WHEN OTHERS THEN
            dbms_output.put_line(SQLERRM);*/
      END;
    END IF;
  END;

  -- установить статус денежного документа (касса, банк)
  PROCEDURE set_money_doc_status(p_doc_id IN NUMBER) IS
    id              NUMBER;
    v_cover_obj_id  NUMBER;
    v_cover_ent_id  NUMBER;
    v_oper_templ_id NUMBER;
    v_is_accepted   NUMBER;
    v_amount        NUMBER;
    v_doc_status_id NUMBER;
    v_doc_status    doc_status%ROWTYPE;
  
    CURSOR c_oper
    (
      cp_src_dsr_id NUMBER
     ,cp_dst_dsr_id NUMBER
    ) IS
      SELECT dsa.obj_uro_id  oper_templ_id
            ,dsr.is_accepted
            ,22
            ,c.contact_id
            ,d.amount        amount
        FROM ven_ac_payment     d
            ,doc_status_action  dsa
            ,doc_action_type    dat
            ,contact            c
            ,doc_status_allowed dsal
            ,doc_templ_status   sdts
            ,doc_templ_status   ddts
            ,doc_status_ref     dsr
       WHERE d.payment_id = p_doc_id
         AND d.doc_templ_id = sdts.doc_templ_id
         AND d.doc_templ_id = ddts.doc_templ_id
         AND dsa.doc_action_type_id = dat.doc_action_type_id
         AND dat.brief = 'OPER'
         AND dsa.is_execute = 0
         AND d.contact_id = c.contact_id
         AND dsa.doc_status_allowed_id = dsal.doc_status_allowed_id
         AND sdts.doc_status_ref_id = cp_src_dsr_id
         AND ddts.doc_status_ref_id = cp_dst_dsr_id
         AND dsal.src_doc_templ_status_id = sdts.doc_templ_status_id
         AND dsal.dest_doc_templ_status_id = ddts.doc_templ_status_id
         AND ddts.doc_status_ref_id = dsr.doc_status_ref_id;
  BEGIN
  
    -- создание операций(проводок) для этого статуса документа
    BEGIN
      v_doc_status_id := doc.get_last_doc_status_id(p_doc_id);
      IF v_doc_status_id IS NOT NULL
      THEN
        SELECT * INTO v_doc_status FROM doc_status ds WHERE ds.doc_status_id = v_doc_status_id;
        -- создаем операции по шаблону
        OPEN c_oper(v_doc_status.src_doc_status_ref_id, v_doc_status.doc_status_ref_id);
        LOOP
          FETCH c_oper
            INTO v_oper_templ_id
                ,v_is_accepted
                ,v_cover_ent_id
                ,v_cover_obj_id
                ,v_amount;
          EXIT WHEN c_oper%NOTFOUND;
          id := acc_new.run_oper_by_template(v_oper_templ_id
                                            ,p_doc_id
                                            ,v_cover_ent_id
                                            ,v_cover_obj_id
                                            ,v_doc_status.doc_status_ref_id
                                            ,v_is_accepted
                                            ,v_amount);
        END LOOP;
        CLOSE c_oper;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        dbms_output.put_line(SQLERRM);
    END;
  END;

  -- установить статус акта выполненных работ ДМС
  PROCEDURE set_dms_act_status(p_doc_id IN NUMBER) IS
    id                NUMBER;
    v_cover_obj_id    NUMBER;
    v_cover_ent_id    NUMBER;
    v_oper_templ_id   NUMBER;
    v_is_accepted     NUMBER;
    v_count           NUMBER;
    v_oper_count      NUMBER;
    v_amount          NUMBER;
    v_total_amount    NUMBER;
    v_oper_amount     NUMBER;
    v_doc_status_id   NUMBER;
    v_doc_status      doc_status%ROWTYPE;
    v_doc_status_ref  doc_status_ref%ROWTYPE;
    v_doc_templ_brief VARCHAR2(30);
    v_doc_amount      NUMBER;
    v_real_amount     NUMBER;
  
    CURSOR c_oper
    (
      cp_src_dsr_id NUMBER
     ,cp_dst_dsr_id NUMBER
    ) IS
      SELECT dsa.obj_uro_id       oper_templ_id
            ,dsr.is_accepted
            ,csm.ent_id
            ,csm.c_service_med_id
            ,csm.amount_plan      amount
        FROM ven_dms_serv_act   d
            ,doc_doc            dd
            ,ven_dms_serv_reg   r
            ,c_service_med      csm
            ,doc_status_action  dsa
            ,doc_action_type    dat
            ,doc_status_allowed dsal
            ,doc_templ_status   sdts
            ,doc_templ_status   ddts
            ,doc_status_ref     dsr
       WHERE d.dms_serv_act_id = p_doc_id
         AND d.dms_serv_act_id = dd.parent_id
         AND dd.child_id = r.dms_serv_reg_id
         AND csm.dms_serv_reg_id = r.dms_serv_reg_id
         AND d.doc_templ_id = sdts.doc_templ_id
         AND d.doc_templ_id = ddts.doc_templ_id
         AND dsa.doc_action_type_id = dat.doc_action_type_id
         AND dat.brief = 'OPER'
         AND dsa.is_execute = 0
         AND dsa.doc_status_allowed_id = dsal.doc_status_allowed_id
         AND sdts.doc_status_ref_id = cp_src_dsr_id
         AND ddts.doc_status_ref_id = cp_dst_dsr_id
         AND dsal.src_doc_templ_status_id = sdts.doc_templ_status_id
         AND dsal.dest_doc_templ_status_id = ddts.doc_templ_status_id
         AND ddts.doc_status_ref_id = dsr.doc_status_ref_id;
  
  BEGIN
  
    v_doc_status_id := doc.get_last_doc_status_id(p_doc_id);
  
    IF v_doc_status_id IS NOT NULL
    THEN
    
      SELECT * INTO v_doc_status FROM doc_status ds WHERE ds.doc_status_id = v_doc_status_id;
    
      SELECT *
        INTO v_doc_status_ref
        FROM doc_status_ref dsr
       WHERE dsr.doc_status_ref_id = v_doc_status.doc_status_ref_id;
    
      BEGIN
        SELECT dt.brief
          INTO v_doc_templ_brief
          FROM document  d
              ,doc_templ dt
         WHERE d.document_id = p_doc_id
           AND d.doc_templ_id = dt.doc_templ_id
           AND dt.brief IN ('DMS_SERV_ACT');
      EXCEPTION
        WHEN OTHERS THEN
          v_doc_templ_brief := NULL;
      END;
    
      -- создание операций(проводок) для этого статуса документа
      BEGIN
      
        IF v_doc_templ_brief IS NOT NULL
        THEN
        
          v_count  := 0;
          v_amount := 0;
          SELECT dsa.amount
            INTO v_doc_amount
            FROM dms_serv_act dsa
           WHERE dsa.dms_serv_act_id = p_doc_id;
          OPEN c_oper(v_doc_status.src_doc_status_ref_id, v_doc_status.doc_status_ref_id);
          LOOP
            FETCH c_oper
              INTO v_oper_templ_id
                  ,v_is_accepted
                  ,v_cover_ent_id
                  ,v_cover_obj_id
                  ,v_real_amount;
            EXIT WHEN c_oper%NOTFOUND;
            IF (v_real_amount > 0)
            THEN
              v_count  := v_count + 1;
              v_amount := v_amount + v_real_amount;
            END IF;
          END LOOP;
          CLOSE c_oper;
        
          -- создаем операции по шаблону
          v_oper_count   := 0;
          v_total_amount := 0;
        
          OPEN c_oper(v_doc_status.src_doc_status_ref_id, v_doc_status.doc_status_ref_id);
          LOOP
            FETCH c_oper
              INTO v_oper_templ_id
                  ,v_is_accepted
                  ,v_cover_ent_id
                  ,v_cover_obj_id
                  ,v_real_amount;
            EXIT WHEN c_oper%NOTFOUND;
          
            IF (v_real_amount > 0)
            THEN
              v_oper_count := v_oper_count + 1;
              IF v_oper_count <> v_count
              THEN
                v_oper_amount  := (v_real_amount) * v_doc_amount / v_amount;
                v_oper_amount  := ROUND(v_oper_amount * 100) / 100;
                v_total_amount := v_total_amount + v_oper_amount;
              ELSE
                v_oper_amount := v_doc_amount - v_total_amount;
              END IF;
            
              id := acc_new.run_oper_by_template(v_oper_templ_id
                                                ,p_doc_id
                                                ,v_cover_ent_id
                                                ,v_cover_obj_id
                                                ,v_doc_status.doc_status_ref_id
                                                ,1
                                                ,v_oper_amount);
            END IF;
          
          END LOOP;
          CLOSE c_oper;
        
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          dbms_output.put_line(SQLERRM);
      END;
    END IF;
  END;

  -- установить статус квитанции А7
  PROCEDURE set_a7_doc_status(p_doc_id IN NUMBER) IS
    v_parent_a7_id  NUMBER := pkg_a7.get_a7_parent(p_doc_id);
    v_payment       NUMBER;
    v_dso           NUMBER;
    v_dso_oper_id   NUMBER;
    id              NUMBER;
    v_doc_status_id NUMBER;
    v_doc_status    doc_status%ROWTYPE;
    v_oper_templ_id NUMBER;
  BEGIN
  
    v_doc_status_id := doc.get_last_doc_status_id(p_doc_id);
  
    IF v_doc_status_id IS NOT NULL
    THEN
    
      SELECT * INTO v_doc_status FROM doc_status ds WHERE ds.doc_status_id = v_doc_status_id;
    
      BEGIN
        SELECT ds.doc_set_off_id
              ,ap.payment_id
          INTO v_dso
              ,v_payment
          FROM doc_set_off ds
              ,ac_payment  ap
         WHERE ds.parent_doc_id = ap.payment_id
           AND ds.child_doc_id = v_parent_a7_id;
      EXCEPTION
        WHEN OTHERS THEN
          raise_application_error(-20100
                                 ,'Ошибка при получении зачета: ' || SQLERRM || ' p_doc_id = ' ||
                                  p_doc_id || ', v_parent_a7_id = ' || v_parent_a7_id ||
                                  ', v_doc_status_id = ' || v_doc_status_id);
      END;
    
      SELECT pt.dso_oper_templ_id
        INTO v_dso_oper_id
        FROM ac_payment_templ pt
            ,ac_payment       p
       WHERE p.payment_id = v_payment
         AND p.payment_templ_id = pt.payment_templ_id;
    
      SELECT ot.oper_templ_id
        INTO v_oper_templ_id
        FROM oper_templ ot
       WHERE ot.brief = 'ПремияНачОплПоср';
    
      FOR tr IN (SELECT tr.*
                   FROM trans tr
                       ,oper  o
                  WHERE o.document_id = v_dso
                    AND o.oper_templ_id = v_dso_oper_id
                    AND tr.oper_id = o.oper_id)
      LOOP
        id := acc_new.run_oper_by_template(v_oper_templ_id
                                          ,p_doc_id
                                          ,tr.obj_ure_id
                                          ,tr.obj_uro_id
                                          ,v_doc_status.doc_status_ref_id
                                          ,1
                                          ,tr.trans_amount);
      END LOOP;
    END IF;
  END;
  /*
   PROCEDURE set_a7_doc_status(p_doc_id IN NUMBER) IS
      id                NUMBER;
      v_cover_obj_id    NUMBER;
      v_cover_ent_id    NUMBER;
      v_Oper_Templ_ID   NUMBER;
      v_Is_Accepted     NUMBER;
      v_Count           NUMBER;
      v_Oper_Count      NUMBER;
      v_Amount          NUMBER;
      v_Total_Amount    NUMBER;
      v_Oper_Amount     NUMBER;
      v_doc_status_id   NUMBER;
      v_doc_status      DOC_STATUS%ROWTYPE;
      v_doc_status_ref  DOC_STATUS_REF%ROWTYPE;
      v_Doc_Templ_Brief VARCHAR2(30);
      v_Doc_Amount      NUMBER;
      v_Real_Amount     NUMBER;
      v_Plan_Amount     NUMBER;
      v_doc_id NUMBER := Pkg_A7.get_a7_parent(p_doc_id);
  
      CURSOR c_Oper(cp_src_dsr_id NUMBER, cp_dst_dsr_id NUMBER) IS
        SELECT dsa.obj_uro_id oper_templ_id,
               dsr.is_accepted,
               c.ent_id,
               c.p_cover_id,
               c.premium Amount,
               0 Plan_Amount
          FROM ven_ac_payment     d,
               ven_bso            b,
               P_POLICY           p,
               AS_ASSET           ass,
               STATUS_HIST        sh,
               P_COVER            c,
               DOC_STATUS_ACTION  dsa,
               DOC_ACTION_TYPE    dat,
               DOC_STATUS_ALLOWED dsal,
               DOC_TEMPL_STATUS   sdts,
               DOC_TEMPL_STATUS   ddts,
               DOC_STATUS_REF     dsr
         WHERE d.payment_id = v_doc_id
           AND b.document_id = v_doc_id
           AND b.policy_id = p.policy_id
           AND ass.p_policy_id = p.policy_id
           AND ass.status_hist_id = sh.status_hist_id(+)
           AND sh.brief IN ('NEW', 'CURRENT')
           AND c.as_asset_id = ass.as_asset_id
           AND d.doc_templ_id = sdts.doc_templ_id
           AND d.doc_templ_id = ddts.doc_templ_id
           AND dsa.doc_action_type_id = dat.doc_action_type_id
           AND dat.brief = 'OPER'
           AND dsa.is_execute = 0
           AND dsa.doc_status_allowed_id = dsal.doc_status_allowed_id
           AND sdts.doc_status_ref_id = cp_src_dsr_id
           AND ddts.doc_status_ref_id = cp_dst_dsr_id
           AND dsal.src_doc_templ_status_id = sdts.doc_templ_status_id
           AND dsal.dest_doc_templ_status_id = ddts.doc_templ_status_id
           AND ddts.doc_status_ref_id = dsr.doc_status_ref_id;
  
    BEGIN
     v_doc_status_id := Doc.get_last_doc_status_id(p_doc_id);
  
      IF v_doc_status_id IS NOT NULL THEN
  
        SELECT *
          INTO v_doc_status
          FROM DOC_STATUS ds
         WHERE ds.doc_status_id = v_doc_status_id;
  
        SELECT *
          INTO v_doc_status_ref
          FROM DOC_STATUS_REF dsr
         WHERE dsr.doc_status_ref_id = v_doc_status.doc_status_ref_id;
  
        BEGIN
          SELECT dt.brief
            INTO v_Doc_Templ_Brief
            FROM DOCUMENT d, DOC_TEMPL dt
           WHERE d.document_id = p_doc_id
             AND d.doc_templ_id = dt.doc_templ_id
             AND dt.brief IN ('A7COPY');
        EXCEPTION
          WHEN OTHERS THEN
            v_Doc_Templ_Brief := NULL;
        END;
  
        -- создание операций(проводок) для этого статуса документа
        BEGIN
  
          IF v_Doc_Templ_Brief IS NOT NULL THEN
  
            v_Count  := 0;
            v_Amount := 0;
            SELECT ap.amount
              INTO v_Doc_Amount
              FROM AC_PAYMENT ap
             WHERE ap.payment_id = p_doc_id;
            OPEN c_Oper(v_doc_status.src_doc_status_ref_id,
                        v_doc_status.doc_status_ref_id);
            LOOP
              FETCH c_Oper
                INTO v_Oper_Templ_ID, v_Is_Accepted, v_Cover_Ent_ID, v_Cover_Obj_ID, v_Real_Amount, v_Plan_Amount;
              EXIT WHEN c_Oper%NOTFOUND;
              IF (v_Real_Amount > v_Plan_Amount) THEN
                v_Count  := v_Count + 1;
                v_Amount := v_Amount + v_Real_Amount - v_Plan_Amount;
              END IF;
            END LOOP;
            CLOSE c_Oper;
  
            -- создаем операции по шаблону
            v_Oper_Count   := 0;
            v_Total_Amount := 0;
  
            OPEN c_Oper(v_doc_status.src_doc_status_ref_id,
                        v_doc_status.doc_status_ref_id);
            LOOP
              FETCH c_Oper
                INTO v_Oper_Templ_ID, v_Is_Accepted, v_Cover_Ent_ID, v_Cover_Obj_ID, v_Real_Amount, v_Plan_Amount;
              EXIT WHEN c_Oper%NOTFOUND;
              IF (v_Real_Amount > v_Plan_Amount) THEN
                v_Oper_Count := v_Oper_Count + 1;
                IF v_Oper_Count <> v_Count THEN
                  v_Oper_Amount  := (v_Real_Amount - v_Plan_Amount) *
                                    v_Doc_Amount / v_Amount;
                  v_Oper_Amount  := ROUND(v_Oper_Amount * 100) / 100;
                  v_Total_Amount := v_Total_Amount + v_Oper_Amount;
                ELSE
                  v_Oper_Amount := v_Doc_Amount - v_Total_Amount;
                END IF;
                id := Acc_New.Run_Oper_By_Template(v_Oper_Templ_ID,
                                                   p_doc_id,
                                                   v_Cover_Ent_ID,
                                                   v_Cover_Obj_ID,
                                                   v_doc_status.doc_status_ref_id,
                                                   1,
                                                   v_Oper_Amount);
              dbms_output.put_line('After run oper: id='||id);
              END IF;
  
            END LOOP;
            CLOSE c_Oper;
  
          END IF;
        EXCEPTION
          WHEN OTHERS THEN
            dbms_output.put_line(SQLERRM);
        END;
      END IF;
    END;
  */

  -- установить статус акта выполненных работ
  PROCEDURE set_agent_report_status(doc_id IN NUMBER) IS
  
    id              NUMBER;
    v_cover_obj_id  NUMBER;
    v_cover_ent_id  NUMBER;
    v_oper_templ_id NUMBER;
    v_is_accepted   NUMBER;
    v_amount        NUMBER;
    v_doc_status_id NUMBER;
    v_doc_status    doc_status%ROWTYPE;
  
    CURSOR c_oper_agent
    (
      cp_src_dsr_id NUMBER
     ,cp_dst_dsr_id NUMBER
    ) IS
      SELECT dsa.obj_uro_id oper_templ_id
            ,dsr.is_accepted
            ,arc.ent_id
            ,arc.agent_report_cont_id
            ,arc.comission_sum
        FROM agent_report       ar
            ,agent_report_cont  arc
            ,doc_action_type    dat
            ,document           d
            ,doc_templ          dt
            ,doc_status_action  dsa
            ,doc_status_allowed dsal
            ,doc_templ_status   sdts
            ,doc_templ_status   ddts
            ,doc_status_ref     dsr
            ,oper_templ         ot
       WHERE arc.agent_report_id = ar.agent_report_id
         AND ar.agent_report_id = doc_id
         AND d.document_id = ar.agent_report_id
         AND d.doc_templ_id = dt.doc_templ_id
         AND dt.doc_templ_id = sdts.doc_templ_id
         AND dt.doc_templ_id = ddts.doc_templ_id
         AND sdts.doc_status_ref_id = cp_src_dsr_id
         AND ddts.doc_status_ref_id = cp_dst_dsr_id
         AND dsa.doc_action_type_id = dat.doc_action_type_id
         AND dat.brief = 'OPER'
         AND ot.oper_templ_id = dsa.obj_uro_id
         AND ot.brief = 'НачКВАгент'
         AND dsa.is_execute = 0
         AND dsa.doc_status_allowed_id = dsal.doc_status_allowed_id
         AND dsal.src_doc_templ_status_id = sdts.doc_templ_status_id
         AND dsal.dest_doc_templ_status_id = ddts.doc_templ_status_id
         AND ddts.doc_status_ref_id = dsr.doc_status_ref_id;
  
    CURSOR c_oper_agent_deduct
    (
      cp_src_dsr_id NUMBER
     ,cp_dst_dsr_id NUMBER
    ) IS
      SELECT dsa.obj_uro_id oper_templ_id
            ,dsr.is_accepted
            ,arc.ent_id
            ,arc.agent_report_cont_id
            ,arc.comission_sum
        FROM agent_report       ar
            ,agent_report_cont  arc
            ,doc_action_type    dat
            ,document           d
            ,doc_templ          dt
            ,doc_status_action  dsa
            ,doc_status_allowed dsal
            ,doc_templ_status   sdts
            ,doc_templ_status   ddts
            ,doc_status_ref     dsr
            ,oper_templ         ot
       WHERE arc.agent_report_id = ar.agent_report_id
         AND ar.agent_report_id = doc_id
         AND d.document_id = ar.agent_report_id
         AND d.doc_templ_id = dt.doc_templ_id
         AND dt.doc_templ_id = sdts.doc_templ_id
         AND dt.doc_templ_id = ddts.doc_templ_id
         AND sdts.doc_status_ref_id = cp_src_dsr_id
         AND ddts.doc_status_ref_id = cp_dst_dsr_id
         AND dsa.doc_action_type_id = dat.doc_action_type_id
         AND dat.brief = 'OPER'
         AND ot.oper_templ_id = dsa.obj_uro_id
         AND ot.brief = 'УдержКомиссия'
         AND dsa.is_execute = 0
         AND arc.is_deduct = 1
         AND dsa.doc_status_allowed_id = dsal.doc_status_allowed_id
         AND dsal.src_doc_templ_status_id = sdts.doc_templ_status_id
         AND dsal.dest_doc_templ_status_id = ddts.doc_templ_status_id
         AND ddts.doc_status_ref_id = dsr.doc_status_ref_id;
  
    CURSOR c_oper_agent_dav
    (
      cp_src_dsr_id NUMBER
     ,cp_dst_dsr_id NUMBER
    ) IS
      SELECT dsa.obj_uro_id oper_templ_id
            ,dsr.is_accepted
            ,ardc.ent_id
            ,ardc.agent_report_dav_ct_id
            ,ardc.comission_sum
        FROM agent_report        ar
            ,agent_report_dav    ard
            ,agent_report_dav_ct ardc
            ,t_prod_coef_type    pct
            ,doc_action_type     dat
            ,document            d
            ,doc_templ           dt
            ,doc_status_action   dsa
            ,doc_status_allowed  dsal
            ,doc_templ_status    sdts
            ,doc_templ_status    ddts
            ,doc_status_ref      dsr
            ,oper_templ          ot
       WHERE ard.agent_report_id = ar.agent_report_id
         AND ardc.agent_report_dav_id = ard.agent_report_dav_id
         AND ard.prod_coef_type_id = pct.t_prod_coef_type_id
         AND pct.brief IN ('PREM_MENEDG', 'PREM_DIR_GR', 'PREM_DIR')
         AND ar.agent_report_id = doc_id
         AND d.document_id = ar.agent_report_id
         AND d.doc_templ_id = dt.doc_templ_id
         AND dt.doc_templ_id = sdts.doc_templ_id
         AND dt.doc_templ_id = ddts.doc_templ_id
         AND sdts.doc_status_ref_id = cp_src_dsr_id
         AND ddts.doc_status_ref_id = cp_dst_dsr_id
         AND dsa.doc_action_type_id = dat.doc_action_type_id
         AND dat.brief = 'OPER'
         AND ot.oper_templ_id = dsa.obj_uro_id
         AND ot.brief = 'НачКВАгент'
         AND dsa.is_execute = 0
         AND dsa.doc_status_allowed_id = dsal.doc_status_allowed_id
         AND dsal.src_doc_templ_status_id = sdts.doc_templ_status_id
         AND dsal.dest_doc_templ_status_id = ddts.doc_templ_status_id
         AND ddts.doc_status_ref_id = dsr.doc_status_ref_id;
  
  BEGIN
  
    -- создание операций(проводок) для этого статуса документа
    BEGIN
      v_doc_status_id := doc.get_last_doc_status_id(doc_id);
      IF v_doc_status_id IS NOT NULL
      THEN
        SELECT * INTO v_doc_status FROM doc_status ds WHERE ds.doc_status_id = v_doc_status_id;
        -- создаем операции по шаблону
        OPEN c_oper_agent(v_doc_status.src_doc_status_ref_id, v_doc_status.doc_status_ref_id);
        LOOP
          FETCH c_oper_agent
            INTO v_oper_templ_id
                ,v_is_accepted
                ,v_cover_ent_id
                ,v_cover_obj_id
                ,v_amount;
          EXIT WHEN c_oper_agent%NOTFOUND;
          id := acc_new.run_oper_by_template(v_oper_templ_id
                                            ,doc_id
                                            ,v_cover_ent_id
                                            ,v_cover_obj_id
                                            ,v_doc_status.doc_status_ref_id
                                            ,v_is_accepted
                                            ,v_amount);
        END LOOP;
        CLOSE c_oper_agent;
      
        OPEN c_oper_agent_deduct(v_doc_status.src_doc_status_ref_id, v_doc_status.doc_status_ref_id);
        LOOP
          FETCH c_oper_agent_deduct
            INTO v_oper_templ_id
                ,v_is_accepted
                ,v_cover_ent_id
                ,v_cover_obj_id
                ,v_amount;
          EXIT WHEN c_oper_agent_deduct%NOTFOUND;
          id := acc_new.run_oper_by_template(v_oper_templ_id
                                            ,doc_id
                                            ,v_cover_ent_id
                                            ,v_cover_obj_id
                                            ,v_doc_status.doc_status_ref_id
                                            ,v_is_accepted
                                            ,v_amount);
        END LOOP;
        CLOSE c_oper_agent_deduct;
        --- внимание, отходим от начисления дава из Дава.т.к. перед ээтим выполняется функция размазывания на оав
        /*
                OPEN c_Oper_Agent_DAV(v_doc_status.src_doc_status_ref_id,
                                      v_doc_status.doc_status_ref_id);
                LOOP
                  FETCH c_Oper_Agent_DAV
                    INTO v_Oper_Templ_ID, v_Is_Accepted, v_Cover_Ent_ID, v_Cover_Obj_ID, v_Amount;
                  EXIT WHEN c_Oper_Agent_DAV%NOTFOUND;
                  id := Acc_New.Run_Oper_By_Template(v_Oper_Templ_ID,
                                                     doc_id,
                                                     v_Cover_Ent_ID,
                                                     v_Cover_Obj_ID,
                                                     v_doc_status.doc_status_ref_id,
                                                     v_Is_Accepted,
                                                     v_Amount);
                END LOOP;
                CLOSE c_Oper_Agent_DAV;
        */
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        dbms_output.put_line(SQLERRM);
    END;
  
  END;
  -- расчитать зачтенную сумму по выставленному счету(распоряжению) по указанному договору(если задан)
  FUNCTION get_set_off_amount
  (
    bill_doc_id     IN NUMBER
   ,p_pol_header_id IN NUMBER
   ,set_off_doc_id  NUMBER
  ) RETURN NUMBER IS
    v_result  NUMBER;
    v_result1 NUMBER;
  BEGIN
    IF p_pol_header_id IS NOT NULL
    THEN
      SELECT nvl(SUM(t.acc_amount), 0)
        INTO v_result
        FROM trans            t
            ,oper             o
            ,doc_set_off      dso
            ,ac_payment_templ apt
            ,document         d
            ,p_policy         p
       WHERE dso.parent_doc_id = bill_doc_id
         AND dso.doc_set_off_id <> nvl(set_off_doc_id, 0)
         AND t.a2_ct_uro_id = p.policy_id
         AND o.document_id = dso.doc_set_off_id
         AND o.oper_id = t.oper_id
         AND o.oper_templ_id = apt.dso_oper_templ_id
         AND apt.doc_templ_id = d.doc_templ_id
         AND d.document_id = bill_doc_id
         AND p.pol_header_id = p_pol_header_id;
    ELSE
      SELECT nvl(SUM(t.acc_amount), 0)
        INTO v_result
        FROM trans            t
            ,oper             o
            ,doc_set_off      dso
            ,ac_payment_templ apt
            ,document         d
       WHERE dso.parent_doc_id = bill_doc_id
         AND dso.doc_set_off_id <> nvl(set_off_doc_id, 0)
         AND o.document_id = dso.doc_set_off_id
         AND o.oper_id = t.oper_id
         AND o.oper_templ_id = apt.dso_oper_templ_id
         AND apt.doc_templ_id = d.doc_templ_id
         AND d.document_id = bill_doc_id;
    END IF;
  
    -- Процедура зачета на шаблоне раньше была другой!
    -- Счет мог быть зачтен по-разному и обоими способами сразу
  
    IF p_pol_header_id IS NOT NULL
    THEN
      SELECT nvl(SUM(t.acc_amount), 0)
        INTO v_result1
        FROM trans            t
            ,oper             o
            ,doc_set_off      dso
            ,oper_templ       ot
            ,p_policy         p
            ,ac_payment_templ apt
            ,document         d
      
       WHERE dso.parent_doc_id = bill_doc_id
         AND dso.doc_set_off_id <> nvl(set_off_doc_id, 0)
         AND t.a2_ct_uro_id = p.policy_id
         AND o.document_id = dso.doc_set_off_id
         AND o.oper_id = t.oper_id
         AND o.oper_templ_id = ot.oper_templ_id
         AND ot.brief IN ('СтраховаяПремияОплачена'
                         ,'ЗачтВыплВозвр'
                         ,'Аннулирование'
                         ,'УдержКомиссия')
         AND p.pol_header_id = p_pol_header_id
         AND o.oper_templ_id <> apt.dso_oper_templ_id
         AND apt.doc_templ_id = d.doc_templ_id
         AND d.document_id = bill_doc_id;
    ELSE
      SELECT nvl(SUM(t.acc_amount), 0)
        INTO v_result1
        FROM trans            t
            ,oper             o
            ,doc_set_off      dso
            ,oper_templ       ot
            ,ac_payment_templ apt
            ,document         d
      
       WHERE dso.parent_doc_id = bill_doc_id
         AND dso.doc_set_off_id <> nvl(set_off_doc_id, 0)
         AND o.document_id = dso.doc_set_off_id
         AND o.oper_id = t.oper_id
         AND o.oper_templ_id = ot.oper_templ_id
         AND ot.brief IN ('СтраховаяПремияОплачена'
                         ,'ЗачтВыплВозвр'
                         ,'Аннулирование'
                         ,'УдержКомиссия')
         AND o.oper_templ_id <> apt.dso_oper_templ_id
         AND apt.doc_templ_id = d.doc_templ_id
         AND d.document_id = bill_doc_id;
    END IF;
  
    RETURN v_result + v_result1;
  END;

  -- расчитать зачтенную сумму по выставленному счету
  -- Ф.Ганичев.
  -- 1-й select -дает сумму зачетов счета, исключая сумму переданного зачета
  -- 2-й select ничего возвращать не должен для счета,т.к. в системе один документ либо зачитывает, либо зачитываем
  -- т.е. счет может быть только родителем. 2-й select для a7(pd4)
  FUNCTION get_bill_set_off_amount
  (
    bill_doc_id    IN NUMBER
   ,set_off_doc_id NUMBER
  ) RETURN NUMBER IS
    v_result     NUMBER;
    v_tmp_amount NUMBER;
  BEGIN
    BEGIN
      SELECT nvl(SUM(t.acc_amount), 0)
        INTO v_tmp_amount
        FROM trans       t
            ,trans_templ tt
            ,oper        o
            ,doc_set_off dso
       WHERE dso.parent_doc_id = bill_doc_id
         AND dso.doc_set_off_id <> nvl(set_off_doc_id, 0)
         AND o.document_id = dso.doc_set_off_id
         AND o.oper_id = t.oper_id
         AND t.trans_templ_id = tt.trans_templ_id
         AND tt.brief IN ('СтраховаяПремияАвансОпл'
                         ,'СтраховаяПремияОплачена'
                         ,'ЗачтВыплВозвр'
                         ,'ЗакрЗадолжАг'
                         ,'ПремияОплаченаПоср'
                         ,'Аннулирование'
                         ,'РегрессныйИскОплачен');
      v_result := v_tmp_amount;
      SELECT nvl(SUM(t.acc_amount), 0)
        INTO v_tmp_amount
        FROM trans       t
            ,trans_templ tt
            ,oper        o
            ,doc_set_off dso
       WHERE dso.child_doc_id = bill_doc_id
         AND dso.doc_set_off_id <> nvl(set_off_doc_id, 0)
         AND o.document_id = dso.doc_set_off_id
         AND o.oper_id = t.oper_id
         AND t.trans_templ_id = tt.trans_templ_id
         AND tt.brief IN ('СтраховаяПремияАвансОпл'
                         ,'СтраховаяПремияОплачена'
                         ,'ЗачтВыплВозвр'
                         ,'ЗакрЗадолжАг'
                         ,'ПремияОплаченаПоср'
                         ,'Аннулирование'
                         ,'РегрессныйИскОплачен');
      v_result := v_result + v_tmp_amount;
    EXCEPTION
      WHEN OTHERS THEN
        v_result := 0;
    END;
    RETURN v_result;
  END;

  -- расчитать зачтенную сумму по выставленному счету по указанному договору
  FUNCTION get_part_set_off_amount
  (
    bill_doc_id     IN NUMBER
   ,p_pol_header_id IN NUMBER
   ,set_off_doc_id  NUMBER
  ) RETURN NUMBER IS
    v_result NUMBER;
  BEGIN
    SELECT nvl(SUM(t.acc_amount), 0)
      INTO v_result
      FROM trans       t
          ,trans_templ tt
          ,oper        o
          ,doc_set_off dso
          ,p_policy    p
     WHERE dso.parent_doc_id = bill_doc_id
       AND dso.doc_set_off_id <> set_off_doc_id
       AND p.pol_header_id = p_pol_header_id
       AND o.document_id = dso.doc_set_off_id
       AND o.oper_id = t.oper_id
       AND t.trans_templ_id = tt.trans_templ_id
       AND tt.brief IN ('СтраховаяПремияОплачена'
                       ,'ЗачтВыплВозвр'
                       ,'СтраховаяПремияАвансОпл'
                       ,'Аннулирование')
       AND t.a2_ct_uro_id = p.policy_id;
    RETURN v_result;
  END;

  -- расчитать зачтенную сумму по полученному платежному/кассовому документу
  FUNCTION get_paym_set_off_amount
  (
    paym_doc_id    IN NUMBER
   ,set_off_doc_id IN NUMBER
  ) RETURN NUMBER IS
    v_result NUMBER;
  BEGIN
    SELECT nvl(SUM(dso.set_off_child_amount), 0)
      INTO v_result
      FROM doc_set_off dso
     WHERE dso.child_doc_id = paym_doc_id
       AND dso.doc_set_off_id <> set_off_doc_id;
    RETURN v_result;
  END;

  -- расчитать зачтенную сумму вознаграждения по полученному платежному/кассовому документу
  FUNCTION get_comm_set_off_amount
  (
    paym_doc_id    IN NUMBER
   ,set_off_doc_id IN NUMBER
  ) RETURN NUMBER IS
    v_result NUMBER;
  BEGIN
    SELECT nvl(SUM(t.acc_amount), 0)
      INTO v_result
      FROM trans       t
          ,trans_templ tt
          ,oper        o
          ,doc_set_off dso
     WHERE t.trans_templ_id = tt.trans_templ_id
       AND tt.brief = 'ЗакрЗадолжКВАг'
       AND o.oper_id = t.oper_id
       AND o.document_id = dso.doc_set_off_id
       AND dso.child_doc_id = paym_doc_id
       AND dso.doc_set_off_id <> set_off_doc_id;
    RETURN v_result;
  END;

  /**
  * Получить сумму начисления премии.
  * Оборот в корреспонденции Д счет расчетов со страхователями,перестрахователями - К счет начисленных премий
  * @author Denis Ivanov
  * @param
  */
  FUNCTION get_pay_amount
  (
    p_fund_id    NUMBER
   ,p_start_date DATE
   ,p_end_date   DATE
   ,p_a1_id      NUMBER DEFAULT NULL
   ,p_a2_id      NUMBER DEFAULT NULL
   ,p_a3_id      NUMBER DEFAULT NULL
   ,p_a4_id      NUMBER DEFAULT NULL
   ,p_a5_id      NUMBER DEFAULT NULL
  ) RETURN t_amount IS
    v_turn_rest       acc_new.t_turn_rest;
    v_ret_val         t_amount;
    v_asset_header_id NUMBER;
    v_plo_id          NUMBER;
  BEGIN
  
    SELECT nvl(SUM(t.trans_amount), 0)
          ,nvl(SUM(t.acc_amount), 0)
      INTO v_turn_rest.turn_ct_base_fund
          ,v_turn_rest.turn_ct_fund
      FROM trans t
     WHERE t.acc_fund_id = p_fund_id
       AND t.ct_account_id = v_pay_acc_id
       AND (p_start_date IS NULL OR t.trans_date >= p_start_date)
       AND (p_end_date IS NULL OR t.trans_date < p_end_date)
       AND (p_a1_id IS NULL OR t.a1_ct_uro_id = p_a1_id)
       AND (p_a2_id IS NULL OR t.a2_ct_uro_id = p_a2_id)
       AND (p_a3_id IS NULL OR t.a3_ct_uro_id = p_a3_id)
       AND (p_a4_id IS NULL OR t.a4_ct_uro_id = p_a4_id)
       AND (p_a5_id IS NULL OR t.a5_ct_uro_id = p_a5_id);
  
    /*v_turn_rest               := Acc_New.Get_Acc_Turn_Rest(v_pay_acc_id,
    p_fund_id,
    p_start_date,
    p_end_date,
    p_A1_ID,
    0,
    p_A2_ID,
    0,
    p_A3_ID,
    0,
    p_A4_ID,
    0,
    p_A5_ID,
    0);*/
    v_ret_val.fund_amount     := v_turn_rest.turn_ct_fund;
    v_ret_val.pay_fund_amount := v_turn_rest.turn_ct_base_fund;
    RETURN v_ret_val;
  END;

  /*Каткевч А.Г. 07/10/2008 внес небольшое исправление*/
  FUNCTION get_pay_amount_exec
  (
    p_fund_id    NUMBER
   ,p_start_date DATE
   ,p_end_date   DATE
   ,p_a1_id      NUMBER DEFAULT NULL
   ,p_a2_id      NUMBER DEFAULT NULL
   ,p_a3_id      NUMBER DEFAULT NULL
   ,p_a4_id      NUMBER DEFAULT NULL
   ,p_a5_id      NUMBER DEFAULT NULL
  ) RETURN t_amount IS
    v_turn_rest       acc_new.t_turn_rest;
    v_ret_val         t_amount;
    v_asset_header_id NUMBER;
    v_plo_id          NUMBER;
  
    v_sql_clause VARCHAR2(2000);
  BEGIN
  
    v_sql_clause := 'select nvl(sum(t.trans_amount),0) result1,
                     NVL(SUM(t.acc_amount),0) result2
                    FROM trans t
                    WHERE t.acc_fund_id = :p_fund_id
                    AND t.ct_account_id =  :p_pay_acc_id';
    IF p_start_date IS NULL
    THEN
      v_sql_clause := v_sql_clause || ' ' || ' and :p_start_date is null';
    ELSE
      v_sql_clause := v_sql_clause || ' ' || ' and t.trans_date >= :p_start_date';
    END IF;
  
    IF p_end_date IS NULL
    THEN
      v_sql_clause := v_sql_clause || ' ' || ' and :p_end_date is null ';
    ELSE
      --Нужно учитывать дату как <= а не как <
      v_sql_clause := v_sql_clause || ' ' || ' and t.trans_date <= :p_end_date';
    END IF;
  
    IF p_a1_id IS NULL
    THEN
      v_sql_clause := v_sql_clause || ' ' || ' and :p_A1_ID is null ';
    ELSE
      v_sql_clause := v_sql_clause || ' ' || ' and t.a1_ct_uro_id = :p_a1_id';
    END IF;
  
    IF p_a2_id IS NULL
    THEN
      v_sql_clause := v_sql_clause || ' ' || ' and :p_A2_ID is null';
    ELSE
      v_sql_clause := v_sql_clause || ' ' || ' and t.a2_ct_uro_id = :p_a2_id';
    END IF;
  
    IF p_a3_id IS NULL
    THEN
      v_sql_clause := v_sql_clause || ' ' || ' and :p_A3_ID is null';
    ELSE
      v_sql_clause := v_sql_clause || ' ' || ' and t.a3_ct_uro_id = :p_a3_id';
    END IF;
  
    IF p_a4_id IS NULL
    THEN
      v_sql_clause := v_sql_clause || ' ' || ' and :p_A4_ID is null';
    ELSE
      v_sql_clause := v_sql_clause || ' ' || ' and t.a4_ct_uro_id = :p_a4_id';
    END IF;
  
    IF p_a5_id IS NULL
    THEN
      v_sql_clause := v_sql_clause || ' ' || ' and :p_A5_ID is null';
    ELSE
      v_sql_clause := v_sql_clause || ' ' || ' and t.a5_ct_uro_id = :p_a5_id';
    END IF;
  
    log(p_fund_id, 'GET_PAY_AMOUNT_EXEC ' || chr(13) || v_sql_clause);
    log(p_fund_id
       ,'GET_PAY_AMOUNT_EXEC p_fund_id ' || p_fund_id || ' v_pay_acc_id ' || v_pay_acc_id ||
        ' p_A2_ID ' || p_a2_id);
  
    EXECUTE IMMEDIATE v_sql_clause
      INTO v_turn_rest.turn_ct_base_fund, v_turn_rest.turn_ct_fund
      USING p_fund_id, v_pay_acc_id, p_start_date, p_end_date, p_a1_id, p_a2_id, p_a3_id, p_a4_id, p_a5_id;
  
    /*
    v_turn_rest               := Acc_New.Get_Acc_Turn_Rest(v_pay_acc_id,
                                                           p_fund_id,
                                                           p_start_date,
                                                           p_end_date,
                                                           p_A1_ID,
                                                           0,
                                                           p_A2_ID,
                                                           0,
                                                           p_A3_ID,
                                                           0,
                                                           p_A4_ID,
                                                           0,
                                                           p_A5_ID,
                                                           0);*/
    v_ret_val.fund_amount     := v_turn_rest.turn_ct_fund;
    v_ret_val.pay_fund_amount := v_turn_rest.turn_ct_base_fund;
    RETURN v_ret_val;
  END;

  /**
  * Получить сумму выплаты агентского вознаграждения
  * Оборот в корреспонденции Д счет расчетов со страхователями,перестрахователями - К счет начисленных премий
  * @author Denis Ivanov
  * @param
  */
  FUNCTION get_ag_pay_amount
  (
    p_fund_id    NUMBER
   ,p_start_date DATE
   ,p_end_date   DATE
   ,p_a1_id      NUMBER DEFAULT NULL
   ,p_a2_id      NUMBER DEFAULT NULL
   ,p_a3_id      NUMBER DEFAULT NULL
   ,p_a4_id      NUMBER DEFAULT NULL
   ,p_a5_id      NUMBER DEFAULT NULL
  ) RETURN t_amount IS
    v_turn_rest acc_new.t_turn_rest;
    v_ret_val   t_amount;
  BEGIN
    v_ret_val.fund_amount     := 0;
    v_ret_val.pay_fund_amount := 0;
  
    FOR rec IN (SELECT arc.agent_report_cont_id
                  FROM agent_report_cont arc
                 WHERE arc.agent_report_id = p_a5_id)
    LOOP
      v_turn_rest               := acc_new.get_acc_turn_rest(v_ag_acc_id
                                                            ,p_fund_id
                                                            ,p_start_date
                                                            ,p_end_date
                                                            ,p_a1_id
                                                            ,0
                                                            ,p_a2_id
                                                            ,0
                                                            ,p_a3_id
                                                            ,0
                                                            ,p_a4_id
                                                            ,0
                                                            ,rec.agent_report_cont_id
                                                            ,0);
      v_ret_val.fund_amount     := v_ret_val.fund_amount + v_turn_rest.turn_ct_fund;
      v_ret_val.pay_fund_amount := v_ret_val.pay_fund_amount + v_turn_rest.turn_ct_base_fund;
    END LOOP;
    RETURN v_ret_val;
  END;

  /**
  * Получить сумму начисления возврата премии.
  * @author Denis Sergeev
  * @param
  */
  FUNCTION get_ret_pay_amount
  (
    p_fund_id    NUMBER
   ,p_start_date DATE
   ,p_end_date   DATE
   ,p_a1_id      NUMBER DEFAULT NULL
   ,p_a2_id      NUMBER DEFAULT NULL
   ,p_a3_id      NUMBER DEFAULT NULL
   ,p_a4_id      NUMBER DEFAULT NULL
   ,p_a5_id      NUMBER DEFAULT NULL
  ) RETURN t_amount IS
    v_turn_rest       acc_new.t_turn_rest;
    v_ret_val         t_amount;
    v_asset_header_id NUMBER;
    v_plo_id          NUMBER;
  BEGIN
  
    SELECT nvl(SUM(t.trans_amount), 0)
          ,nvl(SUM(t.acc_amount), 0)
      INTO v_turn_rest.turn_dt_base_fund
          ,v_turn_rest.turn_dt_fund
      FROM trans t
     WHERE t.acc_fund_id = p_fund_id
       AND t.dt_account_id = v_ret_acc_id
       AND (p_start_date IS NULL OR t.trans_date >= p_start_date)
       AND (p_end_date IS NULL OR t.trans_date < p_end_date)
       AND (p_a1_id IS NULL OR t.a1_dt_uro_id = p_a1_id)
       AND (p_a2_id IS NULL OR t.a2_dt_uro_id = p_a2_id)
       AND (p_a3_id IS NULL OR t.a3_dt_uro_id = p_a3_id)
       AND (p_a4_id IS NULL OR t.a4_dt_uro_id = p_a4_id)
       AND (p_a5_id IS NULL OR t.a5_dt_uro_id = p_a5_id);
    /*
    v_turn_rest               := Acc_New.Get_Acc_Turn_Rest(v_ret_acc_id,
                                                           p_fund_id,
                                                           p_start_date,
                                                           p_end_date,
                                                           p_A1_ID,
                                                           0,
                                                           p_A2_ID,
                                                           0,
                                                           p_A3_ID,
                                                           0,
                                                           p_A4_ID,
                                                           0,
                                                           p_A5_ID,
                                                           0);*/
    v_ret_val.fund_amount     := v_turn_rest.turn_dt_fund;
    v_ret_val.pay_fund_amount := v_turn_rest.turn_dt_base_fund;
    RETURN v_ret_val;
  END;

  /**
  * Получить сумму начисления возврата.
  * Кредитовый оборот по счету v_charge_acc_id
  * @author Denis Ivanov
  * @param
  */
  FUNCTION get_repay_charge_amount
  (
    p_fund_id    NUMBER
   ,p_start_date DATE
   ,p_end_date   DATE
   ,p_a1_id      NUMBER DEFAULT NULL
   ,p_a2_id      NUMBER DEFAULT NULL
   ,p_a3_id      NUMBER DEFAULT NULL
   ,p_a4_id      NUMBER DEFAULT NULL
   ,p_a5_id      NUMBER DEFAULT NULL
  ) RETURN t_amount IS
    v_turn_rest       acc_new.t_turn_rest;
    v_ret_val         t_amount;
    v_asset_header_id NUMBER;
    v_plo_id          NUMBER;
  BEGIN
    v_turn_rest               := acc_new.get_acc_turn_rest(v_repay_charge_acc_id
                                                          ,p_fund_id
                                                          ,p_start_date
                                                          ,p_end_date
                                                          ,p_a1_id
                                                          ,0
                                                          ,p_a2_id
                                                          ,0
                                                          ,p_a3_id
                                                          ,0
                                                          ,p_a4_id
                                                          ,0
                                                          ,p_a5_id
                                                          ,0);
    v_ret_val.fund_amount     := v_turn_rest.turn_ct_fund;
    v_ret_val.pay_fund_amount := v_turn_rest.turn_ct_base_fund;
    RETURN v_ret_val;
  END;

  /**
  * Получить сумму начисления возврата по покрытию
  * @author Denis Ivanov
  * @param p_p_cover_id ид покрытия
  * @param p_start_date дата начала периода
  * @param p_end_date дата окончания периода
  * @return запись типа t_amount, содержащую значения в валюте ответсвенности и в валюте
  */
  FUNCTION get_repay_charge_cover_amount
  (
    p_start_date DATE
   ,p_end_date   DATE
   ,p_p_cover_id NUMBER
  ) RETURN t_amount IS
    v_turn_rest       acc_new.t_turn_rest;
    v_ret_val         t_amount;
    v_asset_header_id NUMBER;
    v_plo_id          NUMBER;
    v_fund_id         NUMBER;
  BEGIN
    SELECT a.p_asset_header_id
          ,pc.t_prod_line_option_id
          ,ph.fund_id
      INTO v_asset_header_id
          ,v_plo_id
          ,v_fund_id
      FROM p_cover      pc
          ,as_asset     a
          ,p_policy     p
          ,p_pol_header ph
     WHERE pc.p_cover_id = p_p_cover_id
       AND pc.as_asset_id = a.as_asset_id
       AND a.p_policy_id = p.policy_id
       AND p.pol_header_id = ph.policy_header_id;
  
    RETURN get_repay_charge_amount(v_fund_id
                                  ,p_start_date
                                  ,p_end_date
                                  ,NULL
                                  ,NULL
                                  ,v_asset_header_id
                                  ,v_plo_id);
  END;

  /**
  * Получить сумму начисленной премии.
  * Кредитовый оборот по счету v_charge_acc_id
  * @author Denis Ivanov
  * @param
  */
  FUNCTION get_charge_amount
  (
    p_fund_id    NUMBER
   ,p_start_date DATE
   ,p_end_date   DATE
   ,p_a1_id      NUMBER DEFAULT NULL
   ,p_a2_id      NUMBER DEFAULT NULL
   ,p_a3_id      NUMBER DEFAULT NULL
   ,p_a4_id      NUMBER DEFAULT NULL
   ,p_a5_id      NUMBER DEFAULT NULL
  ) RETURN t_amount IS
    v_turn_rest       acc_new.t_turn_rest;
    v_ret_val         t_amount;
    v_asset_header_id NUMBER;
    v_plo_id          NUMBER;
  BEGIN
    v_turn_rest               := acc_new.get_acc_turn_rest(v_charge_acc_id
                                                          ,p_fund_id
                                                          ,p_start_date
                                                          ,p_end_date
                                                          ,p_a1_id
                                                          ,0
                                                          ,p_a2_id
                                                          ,0
                                                          ,p_a3_id
                                                          ,0
                                                          ,p_a4_id
                                                          ,0
                                                          ,p_a5_id
                                                          ,0);
    v_ret_val.fund_amount     := v_turn_rest.turn_ct_fund;
    v_ret_val.pay_fund_amount := v_turn_rest.turn_ct_base_fund;
    RETURN v_ret_val;
  END;

  /**
  * Получить сумму начисленной премии по покрытию
  * @author Denis Ivanov
  * @param p_p_cover_id ид покрытия
  * @param p_start_date дата начала периода
  * @param p_end_date дата окончания периода
  * @return запись типа t_amount, содержащую значения в валюте ответсвенности и в валюте
  */
  FUNCTION get_charge_cover_amount
  (
    p_start_date DATE
   ,p_end_date   DATE
   ,p_p_cover_id NUMBER
  ) RETURN t_amount IS
    v_turn_rest       acc_new.t_turn_rest;
    v_ret_val         t_amount;
    v_asset_header_id NUMBER;
    v_plo_id          NUMBER;
    v_fund_id         NUMBER;
  BEGIN
    SELECT a.p_asset_header_id
          ,pc.t_prod_line_option_id
          ,ph.fund_id
      INTO v_asset_header_id
          ,v_plo_id
          ,v_fund_id
      FROM p_cover      pc
          ,as_asset     a
          ,p_policy     p
          ,p_pol_header ph
     WHERE pc.p_cover_id = p_p_cover_id
       AND pc.as_asset_id = a.as_asset_id
       AND a.p_policy_id = p.policy_id
       AND p.pol_header_id = ph.policy_header_id;
  
    RETURN get_charge_amount(v_fund_id
                            ,p_start_date
                            ,p_end_date
                            ,NULL
                            ,NULL
                            ,v_asset_header_id
                            ,v_plo_id);
  END;

  FUNCTION get_pay_cover_amount(p_p_cover_id NUMBER) RETURN t_amount IS
  BEGIN
    RETURN get_charge_cover_amount(p_p_cover_id, 'PROLONG', NULL, v_pay_acc_id);
  END;

  FUNCTION get_charge_cover_amount
  (
    p_p_cover_id  NUMBER
   ,p_type        VARCHAR2 DEFAULT 'PROD_LINE'
   ,p_document_id NUMBER DEFAULT NULL
   ,p_acc_id      NUMBER DEFAULT v_charge_acc_id
  ) RETURN t_amount IS
    v_ret_val         t_amount;
    v_asset_header_id NUMBER;
    v_plo_id          NUMBER;
    v_fund_id         NUMBER;
    v_policy_id       NUMBER;
    v_pol_header_id   NUMBER;
  BEGIN
    SELECT a.p_asset_header_id
          ,pc.t_prod_line_option_id
          ,ph.fund_id
          ,a.p_policy_id
          ,ph.policy_header_id
      INTO v_asset_header_id
          ,v_plo_id
          ,v_fund_id
          ,v_policy_id
          ,v_pol_header_id
      FROM p_cover      pc
          ,as_asset     a
          ,p_policy     p
          ,p_pol_header ph
     WHERE pc.p_cover_id = p_p_cover_id
       AND pc.as_asset_id = a.as_asset_id
       AND a.p_policy_id = p.policy_id
       AND p.pol_header_id = ph.policy_header_id;
  
    IF p_type = 'PROD_LINE'
    THEN
      -- Начислено по программе (программа+объект)
      SELECT nvl(SUM(t.trans_amount), 0)
            ,nvl(SUM(t.acc_amount), 0)
        INTO v_ret_val.pay_fund_amount
            ,v_ret_val.fund_amount
        FROM trans t
       WHERE t.ct_account_id = p_acc_id
         AND t.a3_ct_uro_id = v_asset_header_id
         AND t.a4_ct_uro_id = v_plo_id
         AND t.acc_fund_id = v_fund_id;
      RETURN v_ret_val;
    ELSIF p_type = 'COVER'
    THEN
      -- Начислено по конкретному покрытию в одной версии
      SELECT nvl(SUM(t.trans_amount), 0)
            ,nvl(SUM(t.acc_amount), 0)
        INTO v_ret_val.pay_fund_amount
            ,v_ret_val.fund_amount
        FROM trans t
       WHERE t.ct_account_id = p_acc_id
         AND t.a5_ct_uro_id = p_p_cover_id
         AND t.acc_fund_id = v_fund_id;
      RETURN v_ret_val;
    ELSIF p_type = 'PROLONG'
    THEN
      -- Начислено по покрытию в договоре
      SELECT nvl(SUM(t.trans_amount), 0)
            ,nvl(SUM(t.acc_amount), 0)
        INTO v_ret_val.pay_fund_amount
            ,v_ret_val.fund_amount
        FROM trans    t
            ,p_policy pp
      
       WHERE t.a2_ct_uro_id = pp.policy_id
         AND t.ct_account_id = p_acc_id
         AND t.a3_ct_uro_id = v_asset_header_id
         AND t.a4_ct_uro_id = v_plo_id
         AND pp.pol_header_id = v_pol_header_id
         AND is_version_cover(v_policy_id
                             ,t.a5_ct_uro_id
                             ,v_asset_header_id
                             ,v_plo_id
                             ,v_pol_header_id) = 1;
      RETURN v_ret_val;
    ELSIF p_type = 'ACC'
    THEN
      -- начислено по программе  в разрезе конкретного счета
      SELECT nvl(SUM(t.trans_amount), 0)
            ,nvl(SUM(t.acc_amount), 0)
        INTO v_ret_val.pay_fund_amount
            ,v_ret_val.fund_amount
        FROM trans t
            ,oper  o
       WHERE t.ct_account_id = p_acc_id
         AND t.acc_fund_id = v_fund_id
         AND o.oper_id = t.oper_id
         AND o.document_id = p_document_id
         AND t.a3_ct_uro_id = v_asset_header_id
         AND t.a4_ct_uro_id = v_plo_id;
    END IF;
    RETURN v_ret_val;
  END;

  /**
  * Получить сумму взаимозачета по покрытию
  * Веселуха
  * 29-06-2009
  **/

  FUNCTION get_vzch_amount
  (
    p_p_cover_id  NUMBER
   ,p_type        VARCHAR2 DEFAULT 'PROD_LINE'
   ,p_document_id NUMBER DEFAULT NULL
   ,p_acc_id      NUMBER DEFAULT v_ret_acc_id
  ) RETURN t_amount IS
    v_ret_val         t_amount;
    v_asset_header_id NUMBER;
    v_plo_id          NUMBER;
    v_fund_id         NUMBER;
    v_policy_id       NUMBER;
    v_pol_header_id   NUMBER;
  BEGIN
    SELECT a.p_asset_header_id
          ,pc.t_prod_line_option_id
          ,ph.fund_id
          ,a.p_policy_id
          ,ph.policy_header_id
      INTO v_asset_header_id
          ,v_plo_id
          ,v_fund_id
          ,v_policy_id
          ,v_pol_header_id
      FROM p_cover      pc
          ,as_asset     a
          ,p_policy     p
          ,p_pol_header ph
     WHERE pc.p_cover_id = p_p_cover_id
       AND pc.as_asset_id = a.as_asset_id
       AND a.p_policy_id = p.policy_id
       AND p.pol_header_id = ph.policy_header_id;
  
    IF p_type = 'PROD_LINE'
    THEN
      -- Взаимозачет по программе (программа+объект)
      SELECT nvl(SUM(t.trans_amount), 0)
            ,nvl(SUM(t.acc_amount), 0)
        INTO v_ret_val.pay_fund_amount
            ,v_ret_val.fund_amount
        FROM trans t
       WHERE t.ct_account_id = p_acc_id
         AND t.a3_ct_uro_id = v_asset_header_id
         AND t.a4_ct_uro_id = v_plo_id
         AND t.acc_fund_id = v_fund_id;
      RETURN v_ret_val;
    ELSIF p_type = 'COVER'
    THEN
      -- Взаимозачет по конкретному покрытию в одной версии
      SELECT nvl(SUM(t.trans_amount), 0)
            ,nvl(SUM(t.acc_amount), 0)
        INTO v_ret_val.pay_fund_amount
            ,v_ret_val.fund_amount
        FROM trans t
       WHERE t.ct_account_id = p_acc_id
         AND t.a5_ct_uro_id = p_p_cover_id
         AND t.acc_fund_id = v_fund_id;
      RETURN v_ret_val;
    ELSIF p_type = 'PROLONG'
    THEN
      -- Взаимозачет по покрытию в договоре
      SELECT nvl(SUM(t.trans_amount), 0)
            ,nvl(SUM(t.acc_amount), 0)
        INTO v_ret_val.pay_fund_amount
            ,v_ret_val.fund_amount
        FROM trans    t
            ,p_policy pp
      
       WHERE t.a2_ct_uro_id = pp.policy_id
         AND t.ct_account_id = p_acc_id
         AND t.a3_ct_uro_id = v_asset_header_id
         AND t.a4_ct_uro_id = v_plo_id
         AND pp.pol_header_id = v_pol_header_id
         AND is_version_cover(v_policy_id
                             ,t.a5_ct_uro_id
                             ,v_asset_header_id
                             ,v_plo_id
                             ,v_pol_header_id) = 1;
      RETURN v_ret_val;
    ELSIF p_type = 'ACC'
    THEN
      -- Взаимозачет по программе  в разрезе конкретного счета
      SELECT nvl(SUM(t.trans_amount), 0)
            ,nvl(SUM(t.acc_amount), 0)
        INTO v_ret_val.pay_fund_amount
            ,v_ret_val.fund_amount
        FROM trans t
            ,oper  o
       WHERE t.ct_account_id = p_acc_id
         AND t.acc_fund_id = v_fund_id
         AND o.oper_id = t.oper_id
         AND o.document_id = p_document_id
         AND t.a3_ct_uro_id = v_asset_header_id
         AND t.a4_ct_uro_id = v_plo_id;
    END IF;
    RETURN v_ret_val;
  END;

  -- специально для фин каникул
  FUNCTION get_charge_cover_amount_fo
  (
    p_p_cover_id  NUMBER
   ,p_type        VARCHAR2 DEFAULT 'PROD_LINE'
   ,p_document_id NUMBER DEFAULT NULL
   ,p_acc_id      NUMBER DEFAULT v_charge_acc_id
   ,p_year        NUMBER
  ) RETURN t_amount IS
    v_ret_val         t_amount;
    v_asset_header_id NUMBER;
    v_plo_id          NUMBER;
    v_fund_id         NUMBER;
    v_policy_id       NUMBER;
    v_pol_header_id   NUMBER;
  BEGIN
  
    log(p_p_cover_id
       ,'GET_CHARGE_COVER_AMOUNT p_type ' || p_type || ' p_document_id ' || p_document_id ||
        ' p_acc_id ' || p_acc_id);
  
    SELECT a.p_asset_header_id
          ,pc.t_prod_line_option_id
          ,ph.fund_id
          ,a.p_policy_id
          ,ph.policy_header_id
      INTO v_asset_header_id
          ,v_plo_id
          ,v_fund_id
          ,v_policy_id
          ,v_pol_header_id
      FROM p_cover      pc
          ,as_asset     a
          ,p_policy     p
          ,p_pol_header ph
     WHERE pc.p_cover_id = p_p_cover_id
       AND pc.as_asset_id = a.as_asset_id
       AND a.p_policy_id = p.policy_id
       AND p.pol_header_id = ph.policy_header_id;
  
    log(p_p_cover_id
       ,'GET_CHARGE_COVER_AMOUNT v_asset_header_id ' || v_asset_header_id || ' v_plo_id ' || v_plo_id ||
        ' v_fund_id ' || v_fund_id || ' v_policy_id ' || v_policy_id || ' v_pol_header_id ' ||
        v_pol_header_id);
  
    IF p_type = 'PROD_LINE'
    THEN
      -- Начислено по программе (программа+объект)
      SELECT nvl(SUM(t.trans_amount), 0)
            ,nvl(SUM(t.acc_amount), 0)
        INTO v_ret_val.pay_fund_amount
            ,v_ret_val.fund_amount
        FROM trans t
       WHERE t.ct_account_id = p_acc_id
         AND t.a3_ct_uro_id = v_asset_header_id
         AND t.a4_ct_uro_id = v_plo_id
         AND t.acc_fund_id = v_fund_id
         AND to_char(t.trans_date, 'YYYY') = p_year
         AND is_version_cover(v_policy_id
                             ,t.a5_ct_uro_id
                             ,v_asset_header_id
                             ,v_plo_id
                             ,v_pol_header_id) = 1;
    
      RETURN v_ret_val;
    ELSIF p_type = 'COVER'
    THEN
      -- Начислено по конкретному покрытию в одной версии
      SELECT nvl(SUM(t.trans_amount), 0)
            ,nvl(SUM(t.acc_amount), 0)
        INTO v_ret_val.pay_fund_amount
            ,v_ret_val.fund_amount
        FROM trans t
       WHERE t.ct_account_id = p_acc_id
         AND t.a5_ct_uro_id = p_p_cover_id
         AND t.acc_fund_id = v_fund_id;
      RETURN v_ret_val;
    ELSIF p_type = 'PLAN'
    THEN
      -- Начислено по покрытию в договоре 
      SELECT nvl(SUM(t.trans_amount), 0)
            ,nvl(SUM(t.acc_amount), 0)
        INTO v_ret_val.pay_fund_amount
            ,v_ret_val.fund_amount
        FROM trans      t
            ,p_policy   pp
            ,oper       o
            ,ac_payment ap
      
       WHERE t.a2_ct_uro_id = pp.policy_id
         AND t.ct_account_id = 52 --p_acc_id
         AND t.a3_ct_uro_id = v_asset_header_id
         AND t.a4_ct_uro_id = v_plo_id
         AND pp.pol_header_id = v_pol_header_id
            --and to_char(T.TRANS_DATE,'YYYY') = p_year
         AND t.oper_id = o.oper_id
         AND ap.payment_id = o.document_id
         AND to_char(ap.due_date, 'YYYY') = p_year
         AND is_version_cover(v_policy_id
                             ,t.a5_ct_uro_id
                             ,v_asset_header_id
                             ,v_plo_id
                             ,v_pol_header_id) = 1;
    
      RETURN v_ret_val;
    ELSIF p_type = 'PROLONG'
    THEN
      -- Начислено по покрытию в договоре 
      SELECT nvl(SUM(t.trans_amount), 0)
            ,nvl(SUM(t.acc_amount), 0)
        INTO v_ret_val.pay_fund_amount
            ,v_ret_val.fund_amount
        FROM trans    t
            ,p_policy pp
      
       WHERE t.a2_ct_uro_id = pp.policy_id
         AND t.ct_account_id = p_acc_id
         AND t.a3_ct_uro_id = v_asset_header_id
         AND t.a4_ct_uro_id = v_plo_id
         AND pp.pol_header_id = v_pol_header_id
         AND to_char(t.trans_date, 'YYYY') = p_year
         AND is_version_cover(v_policy_id
                             ,t.a5_ct_uro_id
                             ,v_asset_header_id
                             ,v_plo_id
                             ,v_pol_header_id) = 1;
      RETURN v_ret_val;
    ELSIF p_type = 'ACC'
    THEN
      -- начислено по программе  в разрезе конкретного счета
      SELECT nvl(SUM(t.trans_amount), 0)
            ,nvl(SUM(t.acc_amount), 0)
        INTO v_ret_val.pay_fund_amount
            ,v_ret_val.fund_amount
        FROM trans t
            ,oper  o
       WHERE t.ct_account_id = p_acc_id
         AND t.acc_fund_id = v_fund_id
         AND o.oper_id = t.oper_id
         AND o.document_id = p_document_id
         AND t.a3_ct_uro_id = v_asset_header_id
         AND t.a4_ct_uro_id = v_plo_id;
    END IF;
    RETURN v_ret_val;
  END;

  -- специально для фин каникул -- оплатал
  FUNCTION get_pay_cover_amount_fo
  (
    p_p_cover_id NUMBER
   ,p_year       NUMBER
  ) RETURN t_amount IS
  BEGIN
    log(p_p_cover_id, 'GET_PAY_COVER_AMOUNT v_pay_acc_id ' || v_pay_acc_id);
    RETURN get_charge_cover_amount_fo(p_p_cover_id, 'PROLONG', NULL, v_pay_acc_id, p_year);
  END;

  -- специально для фин каникул -- начисленно к оплате за год
  FUNCTION get_charge_cover_amount_foy
  (
    p_p_cover_id NUMBER
   ,p_year       NUMBER
  ) RETURN t_amount IS
  BEGIN
    log(p_p_cover_id, 'GET_PAY_COVER_AMOUNT v_pay_acc_id ' || v_pay_acc_id);
    RETURN get_charge_cover_amount_fo(p_p_cover_id, 'PLAN', NULL, v_pay_acc_id, p_year);
  END;

  /**
  * Получить сумму начисленной премии по покрытию
  * @author BALASHOV
  * @param p_p_cover_id ид покрытия
  * @param p_start_date дата начала периода
  * @param p_end_date дата окончания периода
  * @return запись типа number, содержащую значения в валюте ответсвенности и в валюте
  */
  FUNCTION get_charge_cover_amount_pfa
  (
    p_start_date DATE
   ,p_end_date   DATE
   ,p_p_cover_id NUMBER
  ) RETURN NUMBER IS
    v_turn_rest       acc_new.t_turn_rest;
    v_ret_val         t_amount;
    v_asset_header_id NUMBER;
    v_plo_id          NUMBER;
    v_fund_id         NUMBER;
  BEGIN
    --if v_fund_id = 122 then
    RETURN get_charge_cover_amount(p_start_date, p_end_date, p_p_cover_id).fund_amount;
    /*else
      RETURN get_charge_cover_amount(p_start_date,p_end_date,p_p_cover_id).pay_fund_amount;
    end if;*/
  END;

  /**
  * Получить сумму начисленной премии по P_COVER
  * @author BALASHOV
  * @param p_p_cover_id ид покрытия
  * @param p_start_date дата начала периода
  * @param p_end_date дата окончания периода
  * @return запись типа number, содержащую значения в валюте ответсвенности и в валюте
  */
  FUNCTION get_charge_pcover_amount_pfa
  (
    p_start_date DATE
   ,p_end_date   DATE
   ,p_p_cover_id NUMBER
  ) RETURN NUMBER IS
    v_fund_id NUMBER;
  BEGIN
    SELECT ph.fund_id
      INTO v_fund_id
      FROM p_cover      pc
          ,as_asset     a
          ,p_policy     p
          ,p_pol_header ph
     WHERE pc.p_cover_id = p_p_cover_id
       AND pc.as_asset_id = a.as_asset_id
       AND a.p_policy_id = p.policy_id
       AND p.pol_header_id = ph.policy_header_id;
  
    RETURN get_charge_amount(v_fund_id
                            ,p_start_date
                            ,p_end_date
                            ,NULL
                            ,NULL
                            ,NULL
                            ,NULL
                            ,p_p_cover_id).fund_amount;
  END;

  /**
  * Получить оплаченную сумму по покрытию
  * @author Denis Ivanov
  * @param p_p_cover_id ид покрытия
  * @param p_start_date дата начала периода
  * @param p_end_date дата окончания периода
  * @return запись типа t_amount, содержащую значения в валюте ответсвенности и в валюте
  * зачета
  */
  FUNCTION get_pay_cover_amount
  (
    p_start_date DATE
   ,p_end_date   DATE
   ,p_p_cover_id NUMBER
  ) RETURN t_amount IS
    v_turn_rest       acc_new.t_turn_rest;
    v_ret_val         t_amount;
    v_asset_header_id NUMBER;
    v_plo_id          NUMBER;
    v_fund_id         NUMBER;
    v_result          t_amount;
  BEGIN
    SELECT a.p_asset_header_id
          ,pc.t_prod_line_option_id
          ,ph.fund_id
      INTO v_asset_header_id
          ,v_plo_id
          ,v_fund_id
      FROM p_cover      pc
          ,as_asset     a
          ,p_policy     p
          ,p_pol_header ph
     WHERE pc.p_cover_id = p_p_cover_id
       AND pc.as_asset_id = a.as_asset_id
       AND a.p_policy_id = p.policy_id
       AND p.pol_header_id = ph.policy_header_id;
  
    v_result := get_pay_amount(v_fund_id
                              ,p_start_date
                              ,p_end_date
                              ,NULL
                              ,NULL
                              ,v_asset_header_id
                              ,v_plo_id
                              ,NULL);
  
    RETURN v_result;
  END;

  FUNCTION get_pay_cover_amount_pfa
  (
    p_start_date DATE
   ,p_end_date   DATE
   ,p_p_cover_id NUMBER
  ) RETURN NUMBER IS
  BEGIN
    RETURN get_pay_cover_amount(p_start_date, p_end_date, p_p_cover_id).pay_fund_amount;
  END;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 30.03.2009 17:14:21
  -- Purpose : Получает оплаченную сумму по покрытию с привязкой к дате планграфика
  FUNCTION get_pay_cover_amount_epg
  (
    p_start_date DATE
   ,p_end_date   DATE
   ,p_p_cover_id NUMBER
  ) RETURN NUMBER IS
    amount    NUMBER;
    proc_name VARCHAR2(30) := 'get_pay_cover_amount_epg';
  BEGIN
    SELECT /*+ ORDERED */
     SUM(t.trans_amount)
      INTO amount
      FROM p_cover    pc
          ,as_asset   ass
          ,trans      t
          ,oper       o
          ,ac_payment acp
     WHERE t.ct_account_id = v_pay_acc_id
       AND t.oper_id = o.oper_id
       AND o.document_id = acp.payment_id
       AND acp.plan_date BETWEEN p_start_date AND p_end_date
       AND t.a3_ct_uro_id = ass.p_asset_header_id
       AND t.a4_ct_uro_id = pc.t_prod_line_option_id
       AND pc.p_cover_id = p_p_cover_id
       AND pc.as_asset_id = ass.as_asset_id;
  
    RETURN(amount);
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM);
  END get_pay_cover_amount_epg;

  /**
  * Получить оплаченную сумму по версии договора
  * @author Denis Ivanov
  * @param p_p_policy_id ид полиса
  * @param p_start_date дата начала периода
  * @param p_end_date дата окончания периода
  * @return запись типа t_amount, содержащую значения в валюте ответсвенности и в валюте
  * зачета
  */
  FUNCTION get_pay_policy_amount
  (
    p_start_date  DATE
   ,p_end_date    DATE
   ,p_p_policy_id NUMBER
  ) RETURN t_amount IS
    v_fund_id NUMBER;
    RESULT    t_amount;
  
  BEGIN
    SELECT ph.fund_id
      INTO v_fund_id
      FROM p_pol_header ph
          ,p_policy     p
     WHERE p.policy_id = p_p_policy_id
       AND p.pol_header_id = ph.policy_header_id;
  
    RESULT := get_pay_amount_exec(v_fund_id, p_start_date, p_end_date, NULL, p_p_policy_id);
  
    RETURN RESULT;
  
  END;

  /**
  * Получить оплаченную сумму по версии договора
  * @author Denis Ivanov
  * @param p_p_policy_id ид полиса
  * @param p_start_date дата начала периода
  * @param p_end_date дата окончания периода
  * @return запись типа t_amount, содержащую значения в валюте ответсвенности и в валюте
  * зачета
  */
  FUNCTION get_pay_agent_report_amount
  (
    p_start_date      DATE
   ,p_end_date        DATE
   ,p_agent_report_id NUMBER
  ) RETURN t_amount IS
    v_fund_id NUMBER;
  
  BEGIN
    SELECT f.fund_id INTO v_fund_id FROM fund f WHERE f.brief = 'RUR';
    RETURN get_ag_pay_amount(v_fund_id
                            ,p_start_date
                            ,p_end_date
                            ,NULL
                            ,NULL
                            ,NULL
                            ,NULL
                            ,p_agent_report_id);
  END;

  /**
  * Получить выплаченную сумму по версии договора
  * @author Denis Sergeev
  * @param p_p_policy_id ид полиса
  * @param p_start_date дата начала периода
  * @param p_end_date дата окончания периода
  * @return запись типа t_amount, содержащую значения в валюте ответсвенности и в валюте
  * зачета
  */
  FUNCTION get_ret_pay_policy_amount
  (
    p_start_date  DATE
   ,p_end_date    DATE
   ,p_p_policy_id NUMBER
  ) RETURN t_amount IS
    v_fund_id NUMBER;
  
  BEGIN
    SELECT ph.fund_id
      INTO v_fund_id
      FROM p_pol_header ph
          ,p_policy     p
     WHERE p.policy_id = p_p_policy_id
       AND p.pol_header_id = ph.policy_header_id;
    RETURN get_ret_pay_amount(v_fund_id, p_start_date, p_end_date, NULL, p_p_policy_id);
  END;

  /**
  * Получить оплаченную сумму по договору
  * @author Denis Ivanov
  * @param p_p_policy_id ид полиса
  * @param p_start_date дата начала периода
  * @param p_end_date дата окончания периода
  * @return запись типа t_amount, содержащую значения в валюте ответсвенности и в валюте
  * зачета
  */
  FUNCTION get_pay_pol_header_amount
  (
    p_start_date      DATE
   ,p_end_date        DATE
   ,p_p_pol_header_id NUMBER
  ) RETURN t_amount IS
    v_fund_id     NUMBER;
    v_ret_val     t_amount;
    v_temp_amount t_amount;
  BEGIN
    v_ret_val.fund_amount     := 0;
    v_ret_val.pay_fund_amount := 0;
    -- поскольку нет такой аналитики приходится делать цикл
    -- возможен вариант получения этой суммы через doc_set_off, но тогда
    -- выходим из концепции расчетов по плану счетов, и проводки, сделанные вручную,
    -- учитываться не будут.
    FOR rec IN (SELECT p.policy_id FROM p_policy p WHERE p.pol_header_id = p_p_pol_header_id)
    LOOP
      v_temp_amount             := get_pay_policy_amount(p_start_date, p_end_date, rec.policy_id);
      v_ret_val.fund_amount     := v_ret_val.fund_amount + v_temp_amount.fund_amount;
      v_ret_val.pay_fund_amount := v_ret_val.pay_fund_amount + v_temp_amount.pay_fund_amount;
    END LOOP;
    RETURN v_ret_val;
  END;

  /**
  * Получить выплаченную сумму возврата по договору
  * @author Denis Sergeev
  * @param p_p_policy_id ид полиса
  * @param p_start_date дата начала периода
  * @param p_end_date дата окончания периода
  * @return запись типа t_amount, содержащую значения в валюте ответсвенности и в валюте
  * зачета
  */
  FUNCTION get_ret_pay_pol_header_amount
  (
    p_start_date      DATE
   ,p_end_date        DATE
   ,p_p_pol_header_id NUMBER
  ) RETURN t_amount IS
    v_fund_id     NUMBER;
    v_ret_val     t_amount;
    v_temp_amount t_amount;
  BEGIN
    v_ret_val.fund_amount     := 0;
    v_ret_val.pay_fund_amount := 0;
    -- поскольку нет такой аналитики приходится делать цикл
    -- возможен вариант получения этой суммы через doc_set_off, но тогда
    -- выходим из концепции расчетов по плану счетов, и проводки, сделанные вручную,
    -- учитываться не будут.
    FOR rec IN (SELECT p.policy_id FROM p_policy p WHERE p.pol_header_id = p_p_pol_header_id)
    LOOP
      v_temp_amount             := get_ret_pay_policy_amount(p_start_date, p_end_date, rec.policy_id);
      v_ret_val.fund_amount     := v_ret_val.fund_amount + v_temp_amount.fund_amount;
      v_ret_val.pay_fund_amount := v_ret_val.pay_fund_amount + v_temp_amount.pay_fund_amount;
    END LOOP;
    RETURN v_ret_val;
  END;

  /**
  * Получить выплаченную сумму по отчету агента
  * @author Denis Sergeev
  * @param p_start_date дата начала периода
  * @param p_end_date дата окончания периода
  * @return запись типа t_amount, содержащую значения в валюте ответсвенности и в валюте
  * зачета
  */
  FUNCTION get_pay_agent_report
  (
    p_start_date      DATE
   ,p_end_date        DATE
   ,p_agent_report_id NUMBER
  ) RETURN t_amount IS
    v_fund_id     NUMBER;
    v_ret_val     t_amount;
    v_temp_amount t_amount;
  BEGIN
    v_ret_val.fund_amount     := 0;
    v_ret_val.pay_fund_amount := 0;
    -- поскольку нет такой аналитики приходится делать цикл
    -- возможен вариант получения этой суммы через doc_set_off, но тогда
    -- выходим из концепции расчетов по плану счетов, и проводки, сделанные вручную,
    -- учитываться не будут.
    v_temp_amount             := get_pay_agent_report_amount(p_start_date
                                                            ,p_end_date
                                                            ,p_agent_report_id);
    v_ret_val.fund_amount     := v_ret_val.fund_amount + v_temp_amount.fund_amount;
    v_ret_val.pay_fund_amount := v_ret_val.pay_fund_amount + v_temp_amount.pay_fund_amount;
    RETURN v_ret_val;
  END;

  /**
  * Получить оплаченную сумму по договору
  * @author Denis Ivanov
  * @param p_p_policy_id ид полиса
  * @param p_start_date дата начала периода
  * @param p_end_date дата окончания периода
  * @return запись типа t_amount, содержащую значения в валюте ответсвенности и в валюте
  * зачета
  */
  FUNCTION get_pay_pol_header_amount_pfa
  (
    p_start_date      DATE
   ,p_end_date        DATE
   ,p_p_pol_header_id NUMBER
  ) RETURN NUMBER IS
  BEGIN
    RETURN get_pay_pol_header_amount(p_start_date, p_end_date, p_p_pol_header_id).fund_amount;
  END;

  /**
  * Получить выплаченную сумму возврата по договору
  * @author Denis Sergeev
  * @param p_p_policy_id ид полиса
  * @param p_start_date дата начала периода
  * @param p_end_date дата окончания периода
  * @return запись типа t_amount, содержащую значения в валюте ответсвенности и в валюте
  * зачета
  */
  FUNCTION get_ret_pay_pol_header_pfa
  (
    p_start_date      DATE
   ,p_end_date        DATE
   ,p_p_pol_header_id NUMBER
  ) RETURN NUMBER IS
  BEGIN
    RETURN get_ret_pay_pol_header_amount(p_start_date, p_end_date, p_p_pol_header_id).fund_amount;
  END;

  /**
  * Получить выплаченную сумму по отчету агент а
  * @author Denis Sergeev
  * @param p_start_date дата начала периода
  * @param p_end_date дата окончания периода
  * @return запись типа t_amount, содержащую значения в валюте ответсвенности и в валюте
  * зачета
  */
  FUNCTION get_pay_agent_report_pfa
  (
    p_start_date      DATE
   ,p_end_date        DATE
   ,p_agent_report_id NUMBER
  ) RETURN NUMBER IS
  BEGIN
    RETURN get_pay_agent_report_amount(p_start_date, p_end_date, p_agent_report_id).fund_amount;
  END;

  -- расчитать сумму премии по последней версии договора
  FUNCTION get_last_premium_amount(p_pol_header_id IN NUMBER) RETURN NUMBER IS
    v_result      NUMBER;
    v_year_number NUMBER;
  
  BEGIN
    BEGIN
      v_result := 0;
      /*
      for rec in (
        select nvl(sum(c.premium * get_year_number(c.start_date, c.end_date)), 0) premium
        from   p_pol_header ph,
               p_policy p,
               as_asset a,
               p_cover c,
               status_hist sh
        where  ph.policy_header_id = p_pol_header_id and
               ph.policy_id = p.policy_id and
               p.policy_id = a.p_policy_id and
               c.as_asset_id = a.as_asset_id and
               sh.status_hist_id = c.status_hist_id and
               sh.brief in ('NEW', 'CURRENT')
      ) loop
        v_result := v_result + rec.premium;
      end loop;
      
      */
      SELECT nvl(p.premium, 0)
        INTO v_result
        FROM p_policy p
       WHERE p.policy_id = (SELECT ph.last_ver_id
                              FROM ins.p_pol_header ph
                             WHERE ph.policy_header_id = p_pol_header_id) /*p.version_num =
                                                 (SELECT MAX(p1.version_num)
                                                    FROM P_POLICY p1
                                                   WHERE p1.pol_header_id = p.pol_header_id)*/
         AND p.pol_header_id = p_pol_header_id;
      /*
      select nvl(sum(t.trans_amount), 0)
      into   v_result
      from   p_policy xp, oper o, trans t, trans_templ tt
      where  t.trans_templ_id = tt.trans_templ_id and
             t.oper_id = o.oper_id and
             o.document_id = xp.policy_id and
             xp.pol_header_id = p_pol_header_id and
             tt.brief = 'НачПремия';
       */
    
    EXCEPTION
      WHEN OTHERS THEN
        v_result := 0;
    END;
  
    RETURN v_result;
  END;

  -- расчитать сумму возврата по последней версии договора
  FUNCTION get_last_ret_amount(p_pol_header_id IN NUMBER) RETURN NUMBER IS
    v_result NUMBER;
  BEGIN
    BEGIN
      SELECT nvl(SUM(t.acc_amount), 0)
        INTO v_result
        FROM p_policy    xp
            ,oper        o
            ,trans       t
            ,trans_templ tt
       WHERE t.trans_templ_id = tt.trans_templ_id
         AND t.oper_id = o.oper_id
         AND o.document_id = xp.policy_id
         AND xp.pol_header_id = p_pol_header_id
         AND tt.brief IN ('НачВозврат', 'НачВыкСуммаФинКан');
    EXCEPTION
      WHEN OTHERS THEN
        v_result := 0;
    END;
    RETURN v_result;
  END;

  -- расчитать запланированную сумму по договору
  FUNCTION get_plan_amount(p_pol_header_id IN NUMBER) RETURN NUMBER IS
    v_result NUMBER;
  BEGIN
    BEGIN
      SELECT nvl(SUM(dd.parent_amount), 0)
        INTO v_result
        FROM p_policy       xp
            ,doc_doc        dd
            ,ven_ac_payment ap
            ,doc_templ      dt
       WHERE ap.payment_id = dd.child_id
         AND dd.parent_id = xp.policy_id
         AND xp.pol_header_id = p_pol_header_id
         AND ap.doc_templ_id = dt.doc_templ_id
         AND dt.brief = 'PAYMENT'
         AND doc.get_last_doc_status_brief(ap.payment_id) = 'NEW';
    EXCEPTION
      WHEN OTHERS THEN
        v_result := 0;
    END;
    RETURN v_result;
  END;

  FUNCTION get_policy_plan_amount(p_pol_id IN NUMBER) RETURN NUMBER IS
    v_result NUMBER;
  BEGIN
    BEGIN
      SELECT nvl(SUM(dd.parent_amount), 0)
        INTO v_result
        FROM doc_doc        dd
            ,ven_ac_payment ap
            ,doc_templ      dt
       WHERE ap.payment_id = dd.child_id
         AND dd.parent_id = p_pol_id
         AND ap.doc_templ_id = dt.doc_templ_id
         AND dt.brief = 'PAYMENT'
         AND doc.get_doc_status_brief(ap.payment_id) IN ('NEW', 'TO_PAY');
    EXCEPTION
      WHEN OTHERS THEN
        v_result := 0;
    END;
    RETURN v_result;
  END;

  -- расчитать запланированную сумму по отчету агента
  FUNCTION get_ag_plan_amount(p_agent_report_id IN NUMBER) RETURN NUMBER IS
    v_result NUMBER;
  BEGIN
    BEGIN
      SELECT nvl(SUM(ap.amount), 0)
        INTO v_result
        FROM ven_agent_report ar
            ,doc_doc          dd
            ,ven_ac_payment   ap
            ,doc_templ        dt
       WHERE ap.payment_id = dd.child_id
         AND dd.parent_id = ar.agent_report_id
         AND ar.agent_report_id = p_agent_report_id
         AND ap.doc_templ_id = dt.doc_templ_id
         AND dt.brief = 'PAYAGENT';
    EXCEPTION
      WHEN OTHERS THEN
        v_result := 0;
    END;
    RETURN v_result;
  END;

  -- расчитать начисленную сумму по договору
  FUNCTION get_calc_amount(p_pol_header_id IN NUMBER) RETURN NUMBER IS
    v_result  NUMBER;
    v_tmp_sum NUMBER;
  BEGIN
    BEGIN
      v_result := 0;
      SELECT nvl(SUM(t.acc_amount), 0)
        INTO v_tmp_sum
        FROM p_policy    xp
            ,oper        o
            ,trans       t
            ,trans_templ tt
       WHERE t.trans_templ_id = tt.trans_templ_id
         AND t.oper_id = o.oper_id
         AND o.document_id = xp.policy_id
         AND xp.pol_header_id = p_pol_header_id
         AND tt.brief = 'НачПремия';
      v_result := v_result + v_tmp_sum;
      SELECT nvl(SUM(t.acc_amount), 0)
        INTO v_tmp_sum
        FROM p_policy    xp
            ,doc_doc     dd
            ,ac_payment  ap
            ,oper        o
            ,trans       t
            ,trans_templ tt
       WHERE t.trans_templ_id = tt.trans_templ_id
         AND t.oper_id = o.oper_id
         AND o.document_id = ap.payment_id
         AND ap.payment_id = dd.child_id
         AND dd.parent_id = xp.policy_id
         AND xp.pol_header_id = p_pol_header_id
         AND tt.brief = 'НачПремия';
      v_result := v_result + v_tmp_sum;
    EXCEPTION
      WHEN OTHERS THEN
        v_result := 0;
    END;
    RETURN v_result;
  END;

  -- расcчитать начисленную сумму по версии договора
  FUNCTION get_calc_amount_policy(par_policy_id IN NUMBER) RETURN NUMBER IS
    v_result NUMBER;
  BEGIN
    BEGIN
      SELECT nvl(SUM(t.acc_amount), 0)
        INTO v_result
        FROM p_policy    xp
            ,oper        o
            ,trans       t
            ,trans_templ tt
       WHERE t.trans_templ_id = tt.trans_templ_id
         AND t.oper_id = o.oper_id
         AND o.document_id = xp.policy_id
         AND xp.policy_id = par_policy_id
         AND tt.brief = 'НачПремия';
    EXCEPTION
      WHEN OTHERS THEN
        v_result := 0;
    END;
    RETURN v_result;
  END;

  -- расчитать начисленную сумму по отчету агента
  FUNCTION get_ag_calc_amount(p_agent_report_id IN NUMBER) RETURN NUMBER IS
    v_result NUMBER;
  BEGIN
    BEGIN
      SELECT nvl(SUM(t.trans_amount), 0)
        INTO v_result
        FROM ven_agent_report ar
            ,oper             o
            ,trans            t
            ,trans_templ      tt
       WHERE t.trans_templ_id = tt.trans_templ_id
         AND t.oper_id = o.oper_id
         AND o.document_id = ar.agent_report_id
         AND ar.agent_report_id = p_agent_report_id
         AND tt.brief = 'НачКВ';
    EXCEPTION
      WHEN OTHERS THEN
        v_result := 0;
    END;
    RETURN v_result;
  END;

  -- расчитать удержанную сумму по отчету агента
  FUNCTION get_ag_hold_amount(p_agent_report_id IN NUMBER) RETURN NUMBER IS
    v_result NUMBER;
  BEGIN
    BEGIN
      SELECT nvl(SUM(t.trans_amount), 0)
        INTO v_result
        FROM ven_agent_report ar
            ,oper             o
            ,trans            t
            ,trans_templ      tt
       WHERE t.trans_templ_id = tt.trans_templ_id
         AND t.oper_id = o.oper_id
         AND o.document_id = ar.agent_report_id
         AND ar.agent_report_id = p_agent_report_id
         AND tt.brief = 'УдержКВ';
    EXCEPTION
      WHEN OTHERS THEN
        v_result := 0;
    END;
    RETURN v_result;
  END;

  -- расчитать сумму к оплате по договору
  -- Ф.Ганичев. Рассчитывается как незачтенная сумма по счетам в статусе к оплате
  FUNCTION get_to_pay_amount(p_pol_header_id IN NUMBER) RETURN NUMBER IS
    v_result NUMBER;
  BEGIN
    BEGIN
      /*
      SELECT NVL(SUM(t.acc_amount), 0)
        INTO v_result
        FROM P_POLICY    xp,
             DOC_DOC     dd,
             AC_PAYMENT  ap,
             OPER        o,
             TRANS       t,
             TRANS_TEMPL tt
       WHERE t.trans_templ_id = tt.trans_templ_id
         AND t.oper_id = o.oper_id
         AND o.document_id = ap.payment_id
         AND ap.payment_id = dd.child_id
         AND dd.parent_id = xp.policy_id
         AND xp.pol_header_id = p_pol_header_id
         AND t.a2_dt_uro_id = xp.policy_id
         AND tt.brief = 'ПремияНачисленаКОплате'
         AND Doc.get_doc_status_brief(ap.payment_id) = 'TO_PAY';*/
      SELECT nvl(SUM(child_amount), 0) - nvl(SUM(set_off_amount), 0)
        INTO v_result
        FROM (SELECT dd.child_amount
                    ,(SELECT SUM(dsf.set_off_amount)
                        FROM doc_set_off dsf
                       WHERE dsf.parent_doc_id(+) = ac.payment_id
                         AND doc.get_last_doc_status_brief(dsf.doc_set_off_id) <> 'ANNULATED') set_off_amount
                FROM p_policy       p
                    ,ven_ac_payment ac
                    ,doc_doc        dd
                    ,doc_templ      dt
               WHERE doc.get_last_doc_status_brief(ac.payment_id) = 'TO_PAY'
                 AND ac.payment_id = dd.child_id
                 AND p.policy_id = dd.parent_id
                 AND p.pol_header_id = p_pol_header_id
                 AND ac.doc_templ_id = dt.doc_templ_id
                 AND dt.brief = 'PAYMENT');
    EXCEPTION
      WHEN OTHERS THEN
        v_result := 0;
    END;
    RETURN v_result;
  END;

  -- расчитать сумму к выплате по отчету агента
  FUNCTION get_ag_to_pay_amount(p_agent_report_id IN NUMBER) RETURN NUMBER IS
    v_result NUMBER;
  BEGIN
    BEGIN
      SELECT nvl(SUM(t.trans_amount), 0)
        INTO v_result
        FROM ven_agent_report ar
            ,doc_doc          dd
            ,ac_payment       ap
            ,oper             o
            ,trans            t
            ,trans_templ      tt
       WHERE t.trans_templ_id = tt.trans_templ_id
         AND t.oper_id = o.oper_id
         AND o.document_id = ap.payment_id
         AND ap.payment_id = dd.child_id
         AND dd.parent_id = ar.agent_report_id
         AND ar.agent_report_id = p_agent_report_id
         AND tt.brief = 'НачКВВыпл';
    EXCEPTION
      WHEN OTHERS THEN
        v_result := 0;
    END;
    RETURN v_result;
  END;

  -- расчитать запланированную к возврату сумму по договору
  FUNCTION get_plan_ret_amount(p_pol_header_id IN NUMBER) RETURN NUMBER IS
    v_result NUMBER;
  BEGIN
    BEGIN
      SELECT nvl(SUM(ap.amount), 0)
        INTO v_result
        FROM p_policy       xp
            ,doc_doc        dd
            ,ven_ac_payment ap
            ,doc_templ      dt
       WHERE ap.payment_id = dd.child_id
         AND dd.parent_id = xp.policy_id
         AND xp.pol_header_id = p_pol_header_id
         AND ap.doc_templ_id = dt.doc_templ_id
         AND dt.brief IN ('PAYORDBACK', 'PAYMENT_SETOFF', 'PAYMENT_SETOFF_ACC', 'PAYORDER_SETOFF')
         AND doc.get_doc_status_brief(ap.payment_id) = 'NEW';
    EXCEPTION
      WHEN OTHERS THEN
        v_result := 0;
    END;
    RETURN v_result;
  END;

  -- расчитать начисленную к возврату сумму по договору
  FUNCTION get_calc_ret_amount(p_pol_header_id IN NUMBER) RETURN NUMBER IS
    v_result NUMBER;
  BEGIN
    BEGIN
      /*  select nvl(sum(t.trans_amount), 0)
       into v_result
       from p_policy    xp,
            doc_doc     dd,
            ac_payment  ap,
            oper        o,
            trans       t,
            trans_templ tt
      where t.trans_templ_id = tt.trans_templ_id
        and t.oper_id = o.oper_id
        and o.document_id = ap.payment_id
        and ap.payment_id = dd.child_id
        and dd.parent_id = xp.policy_id
        and xp.pol_header_id = p_pol_header_id
        and tt.brief = 'НачВозврат';*/
      SELECT nvl(SUM(t.acc_amount), 0)
        INTO v_result
        FROM p_policy    xp
            ,oper        o
            ,trans       t
            ,trans_templ tt
       WHERE t.trans_templ_id = tt.trans_templ_id
         AND t.oper_id = o.oper_id
         AND o.document_id = xp.policy_id
         AND xp.pol_header_id = p_pol_header_id
         AND tt.brief = 'НачВозврат';
    EXCEPTION
      WHEN OTHERS THEN
        v_result := 0;
    END;
    RETURN v_result;
  END;

  -- расчитать сумму к выплате по возврату по договору
  FUNCTION get_to_pay_ret_amount(p_pol_header_id IN NUMBER) RETURN NUMBER IS
    v_result NUMBER;
  BEGIN
    BEGIN
      SELECT nvl(SUM(ac.amount), 0) - nvl(SUM(dsf.set_off_amount), 0)
        INTO v_result
        FROM p_policy       p
            ,ven_ac_payment ac
            ,doc_doc        dd
            ,doc_templ      dt
            ,doc_set_off    dsf
       WHERE doc.get_doc_status_brief(ac.payment_id) = 'TO_PAY'
         AND ac.payment_id = dd.child_id
         AND p.policy_id = dd.parent_id
         AND p.pol_header_id = 1
         AND ac.doc_templ_id = dt.doc_templ_id
         AND dt.brief IN ('PAYMENT_SETOFF', 'PAYMENT_SETOFF_ACC', 'PAYORDBACK', 'PAYORDER_SETOFF')
         AND ac.payment_id = dsf.parent_doc_id(+);
      /*
            SELECT NVL(SUM(t.acc_amount), 0)
              INTO v_result
              FROM P_POLICY    xp,
                   DOC_DOC     dd,
                   AC_PAYMENT  ap,
                   OPER        o,
                   TRANS       t,
                   TRANS_TEMPL tt
             WHERE t.trans_templ_id = tt.trans_templ_id
               AND t.oper_id = o.oper_id
               AND o.document_id = ap.payment_id
               AND ap.payment_id = dd.child_id
               AND dd.parent_id = xp.policy_id
               AND xp.pol_header_id = p_pol_header_id
               AND tt.brief = 'УтвРаспВозврат'
               AND Doc.get_doc_status_brief(ap.payment_id) = 'TO_PAY';
      */
    EXCEPTION
      WHEN OTHERS THEN
        v_result := 0;
    END;
    RETURN v_result;
  END;

  -- расчитать сумму выплат по претензиям
  FUNCTION get_claim_payment_amount(p_claim_header_id IN NUMBER) RETURN NUMBER IS
    v_result           NUMBER;
    v_cancel_status_id NUMBER;
  BEGIN
    SELECT dsr.doc_status_ref_id
      INTO v_cancel_status_id
      FROM doc_status_ref dsr
     WHERE dsr.brief = 'CANCEL';
    BEGIN
      SELECT nvl(c.payment_sum, 0)
        INTO v_result
        FROM c_claim c
       WHERE c.c_claim_header_id = p_claim_header_id
         AND c.claim_status_id <> v_cancel_status_id
         AND c.seqno = (SELECT MAX(cs.seqno)
                          FROM c_claim cs
                         WHERE cs.c_claim_header_id = p_claim_header_id
                           AND cs.claim_status_id <> v_cancel_status_id);
    EXCEPTION
      WHEN OTHERS THEN
        v_result := 0;
    END;
    RETURN v_result;
  END;

  -- расчитать запланированную сумму по претензиям
  FUNCTION get_claim_plan_amount(p_claim_header_id IN NUMBER) RETURN NUMBER IS
    v_result           NUMBER;
    v_cancel_status_id NUMBER;
  BEGIN
    SELECT dsr.doc_status_ref_id
      INTO v_cancel_status_id
      FROM doc_status_ref dsr
     WHERE dsr.brief = 'CANCEL';
    BEGIN
      SELECT nvl(SUM(ap.amount), 0)
        INTO v_result
        FROM ven_ac_payment ap
            ,c_claim        c
            ,doc_doc        dd
       WHERE ap.payment_id = dd.child_id
         AND c.c_claim_id = dd.parent_id
         AND c.c_claim_header_id = p_claim_header_id
         AND doc.get_doc_status_id(ap.payment_id) <> v_cancel_status_id
         AND c.claim_status_id <> v_cancel_status_id;
    EXCEPTION
      WHEN OTHERS THEN
        v_result := 0;
    END;
    RETURN v_result;
  END;

  PROCEDURE get_pol_pay_status
  (
    par_pol_id      IN NUMBER
   ,par_ins_amount  OUT NUMBER
   ,par_prem_amount OUT NUMBER
   ,par_pay_amount  OUT NUMBER
  ) IS
    v_start DATE;
    v_ph    NUMBER;
  BEGIN
  
    SELECT p.sign_date
          ,p.ins_amount
          ,p.premium
          ,p.pol_header_id
    
      INTO v_start
          ,par_ins_amount
          ,par_prem_amount
          ,v_ph
      FROM p_policy p
     WHERE p.policy_id = par_pol_id;
  
    par_pay_amount := get_pay_pol_header_amount(v_start, SYSDATE, v_ph).fund_amount;
  
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
    
  END;

  PROCEDURE validate_pol_setoff_sum(p_pol_id NUMBER) IS
    v_cnt NUMBER;
  BEGIN
    SELECT COUNT(*)
      INTO v_cnt
      FROM doc_doc        dd
          ,ven_ac_payment ap
          ,doc_templ      dt
     WHERE ap.payment_id = dd.child_id
       AND dd.parent_id = p_pol_id
       AND ap.doc_templ_id = dt.doc_templ_id
       AND dt.brief IN ('PAYMENT', 'PAYMENT_SETOFF_ACC')
       AND doc.get_last_doc_status_brief(ap.payment_id) IN ('NEW');
    IF nvl(v_cnt, 0) != 0
    THEN
      raise_application_error(-20100
                             ,'По версии полиса есть неоплаченные счета');
    END IF;
  END;

  PROCEDURE policy_make_planning
  (
    p_p_policy_id     NUMBER
   ,p_payment_term_id NUMBER
   ,p_planning_type   VARCHAR2
  ) IS
    v_policy               p_policy%ROWTYPE;
    v_payment_id           NUMBER;
    v_fund_id              NUMBER;
    v_fund_pay_id          NUMBER;
    v_payment_templ_id     NUMBER;
    v_rate_type_id         NUMBER;
    v_company_bank_acc_id  NUMBER;
    v_total_amount         NUMBER;
    v_payment_term_id      NUMBER;
    v_collection_method_id NUMBER;
    v_company_brief        VARCHAR2(30);
    v_pol_charge_amount    NUMBER;
    --
    v_p_policy_id NUMBER;
  
  BEGIN
  
    log(p_p_policy_id, 'POLICY_MAKE_PLANNING');
    dbms_output.put_line(p_planning_type);
    -- Определение идентификатора версии полиса, по которой будет создаваться график    
    v_p_policy_id := pkg_payment_11.policy_id_for_schedule(p_p_policy_id);
    -- Определение параметров версии полиса, по которой будет создаваться график
    SELECT * INTO v_policy FROM p_policy p WHERE p.policy_id = v_p_policy_id;
    --
  
    SELECT ph.fund_id
          ,ph.fund_pay_id
      INTO v_fund_id
          ,v_fund_pay_id
      FROM p_pol_header ph
     WHERE ph.policy_header_id = v_policy.pol_header_id;
  
    SELECT c.latin_name
      INTO v_company_brief
      FROM contact c
     WHERE c.contact_id = pkg_app_param.get_app_param_u('WHOAMI');
  
    log(v_p_policy_id, 'POLICY_MAKE_PLANNING COMPANY_BRIEF ' || v_company_brief);
  
    IF p_planning_type = 'PAYMENT'
    THEN
      -- проверить наличие созданных счетов на оплату
      IF v_company_brief = 'RenLife'
      THEN
        -- Переформировать план-график можно, если удалены все неоплаченные счета, но
        -- проверка этого возлагается на оператора
        v_payment_id := NULL;
      
      ELSE
        -- Если есть хоть 1 неоплаченный счет, то график не формируем
        IF pkg_payment.get_plan_amount(v_policy.pol_header_id) > 0
        THEN
          v_payment_id := NULL;
        END IF;
      END IF;
    
      IF v_payment_id IS NULL
      THEN
      
        SELECT pt.payment_templ_id
          INTO v_payment_templ_id
          FROM ac_payment_templ pt
         WHERE pt.brief = 'PAYMENT';
      
        SELECT rt.rate_type_id INTO v_rate_type_id FROM rate_type rt WHERE rt.brief = 'ЦБ';
      
        IF v_company_brief = 'RenLife'
        THEN
          SELECT cba.id
            INTO v_company_bank_acc_id
            FROM cn_contact_bank_acc cba
           WHERE cba.contact_id = pkg_app_param.get_app_param_u('WHOAMI')
             AND cba.id = (SELECT MAX(cbas.id)
                             FROM cn_contact_bank_acc cbas
                            WHERE cbas.contact_id = pkg_app_param.get_app_param_u('WHOAMI'));
        ELSE
          SELECT cba.id
            INTO v_company_bank_acc_id
            FROM cn_contact_bank_acc cba
                ,organisation_tree   ot
           WHERE cba.contact_id = ot.company_id
             AND ot.organisation_tree_id = pkg_filial.get_user_org_tree_id
             AND cba.id = (SELECT MAX(cbas.id)
                             FROM cn_contact_bank_acc cbas
                            WHERE cbas.contact_id = ot.company_id);
        END IF;
      
        IF v_company_brief = 'RenLife'
        THEN
        
          log(v_p_policy_id, 'POLICY_MAKE_PLANNING VALIDATE_POL_SETOFF_SUM ');
          validate_pol_setoff_sum(v_p_policy_id);
        
          log(v_p_policy_id, 'POLICY_MAKE_PLANNING CREATE_PAYMNT_SHEDULER_RENLIFE ');
          pkg_payment.create_paymnt_sheduler_renlife(v_p_policy_id);
        ELSE
        
          -- v_Total_Amount := get_last_premium_amount(v_policy.pol_header_id) +
          --                   Pkg_Payment.get_last_ret_amount(v_policy.pol_header_id) -
          --                   get_plan_amount(v_policy.pol_header_id);
        
          -- Ф.Ганичев. План-график иногда необходимо формировать в статусе проект, когда еще нет начислений
          v_pol_charge_amount := get_pol_charge_amount(v_policy.pol_header_id, v_charge_acc_id);
          -- Если первая версия в статусе проект и начислений по договору нет
          IF v_pol_charge_amount = 0
             AND doc.get_last_doc_status_brief(v_p_policy_id) = 'PROJECT'
             AND pkg_policy.is_addendum(v_p_policy_id) = 0
          THEN
            SELECT nvl(SUM(a.ins_premium), 0)
              INTO v_pol_charge_amount
              FROM as_asset a
             WHERE a.p_policy_id = v_p_policy_id;
          END IF;
          -- TODO: Учитывать распоряжения на возврат, написав -get_pol_acc_doc_amount(v_policy.pol_header_id, 'PAYMENT_SETOFF')
          v_total_amount := v_pol_charge_amount -
                            get_pol_acc_doc_amount(v_policy.pol_header_id, 'PAYMENT');
        
          IF v_total_amount > 0
          THEN
          
            v_payment_term_id := p_payment_term_id;
          
            -- закоментировал опацан, ибо если существуют платежи, то 2-й запрос возвращает 2 строки
            /*  else
            select pt.collection_method_id
              into v_collection_method_id
              from t_payment_terms pt
             where pt.id = p_payment_term_id;
            select pt.id
              into v_Payment_Term_ID
              from t_payment_terms pt
             where pt.is_periodical = 0
               and pt.collection_method_id = v_collection_method_id; */
            --            end if;
          
            pkg_payment.create_paymnt_sheduler(v_payment_templ_id
                                              ,v_payment_term_id
                                              ,v_total_amount
                                              ,v_fund_id
                                              ,v_fund_pay_id
                                              ,v_rate_type_id
                                              ,CASE WHEN v_fund_id = v_fund_pay_id THEN 1.0 ELSE CASE WHEN
                                               acc_new.get_rate_by_id(v_rate_type_id
                                                                     ,v_fund_pay_id
                                                                     ,v_policy.start_date) <> 0 THEN
                                               acc_new.get_rate_by_id(v_rate_type_id
                                                                     ,v_fund_id
                                                                     ,v_policy.start_date) /
                                               acc_new.get_rate_by_id(v_rate_type_id
                                                                     ,v_fund_pay_id
                                                                     ,v_policy.start_date) ELSE 1.0 END END
                                              ,ent.calc_attr('P_POLICY'
                                                            ,'POLICY_HOLDER_ID'
                                                            ,v_policy.policy_id)
                                              ,NULL
                                              ,v_company_bank_acc_id
                                              ,
                                               --v_policy.start_date,
                                               v_policy.first_pay_date
                                              ,v_policy.policy_id
                                              ,v_policy.fee_payment_term);
          END IF;
        END IF;
      
      END IF;
    END IF;
  
    -- проверить наличие созданных распоряжений на возврат
    IF p_planning_type IN ('PAYORDBACK')
    THEN
    
      IF pkg_payment.get_plan_ret_amount(v_policy.pol_header_id) =
         pkg_payment.get_last_ret_amount(v_policy.pol_header_id)
      THEN
        v_payment_id := 1;
      ELSE
        v_payment_id := NULL;
      END IF;
    
      IF v_payment_id IS NULL
      THEN
      
        --dbms_output.put_line(1);
      
        SELECT pt.payment_templ_id
          INTO v_payment_templ_id
          FROM ac_payment_templ pt
         WHERE pt.brief = 'PAYORDBACK';
      
        --dbms_output.put_line(2);
      
        SELECT rt.rate_type_id INTO v_rate_type_id FROM rate_type rt WHERE rt.brief = 'ЦБ';
      
        --dbms_output.put_line(3);
      
        SELECT cba.id
          INTO v_company_bank_acc_id
          FROM cn_contact_bank_acc cba
         WHERE cba.contact_id = pkg_app_param.get_app_param_u('WHOAMI')
           AND cba.id = (SELECT MAX(cbas.id)
                           FROM cn_contact_bank_acc cbas
                          WHERE cbas.contact_id = pkg_app_param.get_app_param_u('WHOAMI'));
      
        --dbms_output.put_line(4);
      
        IF p_payment_term_id IS NULL
        THEN
          SELECT pt.id
                ,cm.id
            INTO v_payment_term_id
                ,v_collection_method_id
            FROM t_payment_terms     pt
                ,t_collection_method cm
                ,t_payment_terms     ptm
           WHERE pt.collection_method_id = cm.id
             AND pt.is_periodical = 0
             AND ptm.collection_method_id = cm.id
             AND ptm.id = v_policy.payment_term_id;
        
          --dbms_output.put_line(5);
        
          UPDATE p_policy p
             SET p.paymentoff_term_id = v_payment_term_id
           WHERE p.policy_id = p_p_policy_id;
        
        ELSE
          --dbms_output.put_line(6);
        
          SELECT pt.id
                ,pt.collection_method_id
            INTO v_payment_term_id
                ,v_collection_method_id
            FROM t_payment_terms pt
           WHERE pt.id = p_payment_term_id;
        
          --       dbms_output.put_line(6);
        
        END IF;
      
        -- v_Total_Amount := get_calc_ret_amount(v_policy.pol_header_id) -
        --                   get_plan_ret_amount(v_policy.pol_header_id);
        v_total_amount := get_pol_charge_amount(v_policy.pol_header_id, v_repay_charge_acc_id) -
                          get_pol_acc_doc_amount(v_policy.pol_header_id, 'PAYORDBACK');
        IF v_total_amount > 0
           AND v_payment_term_id IS NOT NULL
        THEN
        
          pkg_payment.create_paymnt_sheduler(v_payment_templ_id
                                            ,v_payment_term_id
                                            ,v_total_amount
                                            ,v_fund_id
                                            ,v_fund_pay_id
                                            ,v_rate_type_id
                                            ,CASE WHEN v_fund_id = v_fund_pay_id THEN 1.0 ELSE CASE WHEN
                                             acc_new.get_rate_by_id(v_rate_type_id
                                                                   ,v_fund_pay_id
                                                                   ,v_policy.start_date) <> 0 THEN
                                             acc_new.get_rate_by_id(v_rate_type_id
                                                                   ,v_fund_id
                                                                   ,v_policy.start_date) /
                                             acc_new.get_rate_by_id(v_rate_type_id
                                                                   ,v_fund_pay_id
                                                                   ,v_policy.start_date) ELSE 1.0 END END
                                            ,ent.calc_attr('P_POLICY'
                                                          ,'POLICY_HOLDER_ID'
                                                          ,v_policy.policy_id)
                                            ,NULL
                                            ,v_company_bank_acc_id
                                            ,v_policy.start_date
                                            ,v_policy.policy_id);
        END IF;
      END IF;
    END IF;
  END;

  PROCEDURE gpolicy_make_planning
  (
    p_gen_policy_id   NUMBER
   ,p_payment_term_id NUMBER
   ,p_planning_type   VARCHAR2
  ) IS
    v_gen_policy           gen_policy%ROWTYPE;
    v_payment_id           NUMBER;
    v_payment_templ_id     NUMBER;
    v_rate_type_id         NUMBER;
    v_company_bank_acc_id  NUMBER;
    v_total_amount         NUMBER;
    v_payment_term_id      NUMBER;
    v_collection_method_id NUMBER;
    v_plan_amount          NUMBER;
    v_premium_amount       NUMBER;
  BEGIN
  
    log(p_gen_policy_id, 'POLICY_MAKE_PLANNING');
  
    SELECT * INTO v_gen_policy FROM gen_policy gp WHERE gp.gen_policy_id = p_gen_policy_id;
  
    IF p_planning_type = 'PAYMENT'
    THEN
      v_plan_amount    := 0;
      v_premium_amount := 0;
      FOR rec IN (SELECT DISTINCT dd.child_id
                    FROM doc_doc dd
                   WHERE dd.parent_id = v_gen_policy.gen_policy_id)
      LOOP
        v_plan_amount    := v_plan_amount + pkg_payment.get_plan_amount(rec.child_id);
        v_premium_amount := v_premium_amount + get_last_premium_amount(rec.child_id);
      END LOOP;
    
      -- проверить наличие созданных счетов на оплату
      IF v_plan_amount = v_premium_amount
      THEN
        v_payment_id := 1;
      ELSE
        v_payment_id := NULL;
      END IF;
    
      IF v_payment_id IS NULL
      THEN
      
        SELECT pt.payment_templ_id
          INTO v_payment_templ_id
          FROM ac_payment_templ pt
         WHERE pt.brief = 'PAYMENT';
      
        SELECT rt.rate_type_id INTO v_rate_type_id FROM rate_type rt WHERE rt.brief = 'ЦБ';
      
        SELECT cba.id
          INTO v_company_bank_acc_id
          FROM cn_contact_bank_acc cba
         WHERE cba.contact_id = pkg_app_param.get_app_param_u('WHOAMI')
           AND cba.id = (SELECT MAX(cbas.id)
                           FROM cn_contact_bank_acc cbas
                          WHERE cbas.contact_id = pkg_app_param.get_app_param_u('WHOAMI'));
      
        v_total_amount := 0;
        FOR rec IN (SELECT DISTINCT dd.child_id
                      FROM doc_doc dd
                     WHERE dd.parent_id = v_gen_policy.gen_policy_id)
        LOOP
          v_total_amount := v_total_amount + get_last_premium_amount(rec.child_id) +
                            pkg_payment.get_last_ret_amount(rec.child_id) -
                            get_plan_amount(rec.child_id);
        END LOOP;
      
        -- закоментировал опацан, ибо если существуют платежи, то 2-й запрос возвращает 2 строки
        IF v_total_amount > 0
        THEN
          v_payment_term_id := p_payment_term_id;
        
          pkg_payment.create_paymnt_sheduler(v_payment_templ_id
                                            ,v_payment_term_id
                                            ,v_total_amount
                                            ,v_gen_policy.fund_id
                                            ,v_gen_policy.fund_pay_id
                                            ,v_rate_type_id
                                            ,CASE WHEN
                                             v_gen_policy.fund_id = v_gen_policy.fund_pay_id THEN 1.0 ELSE CASE WHEN
                                             acc_new.get_rate_by_id(v_rate_type_id
                                                                   ,v_gen_policy.fund_pay_id
                                                                   ,v_gen_policy.start_date) <> 0 THEN
                                             acc_new.get_rate_by_id(v_rate_type_id
                                                                   ,v_gen_policy.fund_id
                                                                   ,v_gen_policy.start_date) /
                                             acc_new.get_rate_by_id(v_rate_type_id
                                                                   ,v_gen_policy.fund_pay_id
                                                                   ,v_gen_policy.start_date) ELSE 1.0 END END
                                            ,v_gen_policy.insurer_id
                                            ,NULL
                                            ,v_company_bank_acc_id
                                            ,v_gen_policy.start_date
                                            ,v_gen_policy.gen_policy_id
                                            ,1);
        END IF;
      
      END IF;
    END IF;
  END;

  PROCEDURE claim_make_planning
  (
    p_claim_id        NUMBER
   ,p_payment_term_id NUMBER
   ,p_planning_type   VARCHAR2
  ) IS
    v_claim                c_claim%ROWTYPE;
    v_payment_id           NUMBER;
    v_payment_templ_id     NUMBER;
    v_rate_type_id         NUMBER;
    v_company_bank_acc_id  NUMBER;
    v_collection_method_id NUMBER;
    v_total_amount         NUMBER;
    v_payment_term_id      NUMBER;
    v_rate_on_date_id      NUMBER;
    v_ch_rate_on_date_id   NUMBER;
    v_first_payment_date   DATE;
    v_fund_id              NUMBER;
    v_fund_pay_id          NUMBER;
    v_declarant_id         NUMBER;
    v_company_brief        VARCHAR2(200);
  BEGIN
    SELECT * INTO v_claim FROM c_claim c WHERE c.c_claim_id = p_claim_id;
  
    SELECT ch.rate_on_date_id
          ,nvl(ch.first_payment_date, trunc(v_claim.claim_status_date, 'dd'))
          ,ch.fund_id
          ,nvl(ch.fund_pay_id, f.fund_id)
          ,(SELECT t.cn_person_id
             FROM c_event_contact t
                  --Чирков удаление старых связей заявителей
                 ,c_declarants cd
            WHERE cd.c_claim_header_id = ch.c_claim_header_id
              AND cd.declarant_id = t.c_event_contact_id
              AND cd.c_declarants_id =
                  (SELECT MAX(cd_1.c_declarants_id)
                     FROM c_declarants cd_1
                    WHERE cd_1.c_claim_header_id = cd.c_claim_header_id))
    --end_Чирков удаление старых связей заявителей                                 
    --WHERE t.c_event_contact_id = ch.declarant_id)
      INTO v_ch_rate_on_date_id
          ,v_first_payment_date
          ,v_fund_id
          ,v_fund_pay_id
          ,v_declarant_id
      FROM ven_c_claim_header ch
          ,fund               f
     WHERE ch.c_claim_header_id = v_claim.c_claim_header_id
       AND f.brief = 'RUR';
  
    IF p_planning_type = 'PAYMENT'
    THEN
      -- проверить наличие созданных счетов на оплату
      IF pkg_claim_payment.get_claim_plan_sum(v_claim.c_claim_id) =
         pkg_claim_payment.get_claim_payment_sum(v_claim.c_claim_id)
      THEN
        v_payment_id := 1;
      ELSE
        v_payment_id := NULL;
      END IF;
    
      IF v_payment_id IS NULL
      THEN
        --Шаблон платежа
        SELECT pt.payment_templ_id
          INTO v_payment_templ_id
          FROM ac_payment_templ pt
         WHERE pt.brief = 'PAYORDER';
        --Тип курса: Курс ЦБ
        SELECT t_rate_on_date_id
          INTO v_rate_on_date_id
          FROM t_rate_on_date d
         WHERE lower(brief) = 'date_event';
      
        CASE
          WHEN v_ch_rate_on_date_id = v_rate_on_date_id THEN
            SELECT rt.rate_type_id INTO v_rate_type_id FROM rate_type rt WHERE rt.brief = 'ФИКС';
          ELSE
            SELECT rt.rate_type_id INTO v_rate_type_id FROM rate_type rt WHERE rt.brief = 'ЦБ';
        END CASE;
        --Банк
        --        select cba.id
        --          into v_Company_Bank_Acc_ID
        --          from cn_contact_bank_acc cba
        --         where cba.contact_id = pkg_app_param.get_app_param_u('WHOAMI')
        --           and cba.id =
        --               (select max(cbas.id)
        --                  from cn_contact_bank_acc cbas
        --                 where cbas.contact_id =
        --                       pkg_app_param.get_app_param_u('WHOAMI'));
      
        SELECT c.latin_name
          INTO v_company_brief
          FROM contact c
         WHERE c.contact_id = pkg_app_param.get_app_param_u('WHOAMI');
      
        IF v_company_brief = 'RenLife'
        THEN
          SELECT cba.id
            INTO v_company_bank_acc_id
            FROM cn_contact_bank_acc cba
           WHERE cba.contact_id = pkg_app_param.get_app_param_u('WHOAMI')
             AND cba.id = (SELECT MAX(cbas.id)
                             FROM cn_contact_bank_acc cbas
                            WHERE cbas.contact_id = pkg_app_param.get_app_param_u('WHOAMI'));
        ELSE
          SELECT cba.id
            INTO v_company_bank_acc_id
            FROM cn_contact_bank_acc cba
                ,organisation_tree   ot
           WHERE cba.contact_id = ot.company_id
             AND ot.organisation_tree_id = pkg_filial.get_user_org_tree_id
             AND cba.id = (SELECT MAX(cbas.id)
                             FROM cn_contact_bank_acc cbas
                            WHERE cbas.contact_id = ot.company_id);
        END IF;
      
        v_total_amount := pkg_claim_payment.get_claim_payment_sum(v_claim.c_claim_id) -
                          pkg_claim_payment.get_claim_plan_sum(v_claim.c_claim_id);
      
        IF v_total_amount > 0
        THEN
          --   IF Pkg_Claim_Payment.get_claim_plan_sum(v_claim.c_claim_id) = 0 THEN
          v_payment_term_id := p_payment_term_id;
          /*  ELSE
            SELECT pt.collection_method_id
              INTO v_collection_method_id
              FROM T_PAYMENT_TERMS pt
             WHERE pt.id = p_payment_term_id;
            SELECT pt.id
              INTO v_Payment_Term_ID
              FROM T_PAYMENT_TERMS pt
             WHERE pt.is_periodical = 0
               AND pt.collection_method_id = v_collection_method_id;
          END IF; */
        
          pkg_payment.create_paymnt_sheduler(v_payment_templ_id
                                            ,v_payment_term_id
                                            ,v_total_amount
                                            ,v_fund_id
                                            ,v_fund_pay_id
                                            ,v_rate_type_id
                                            ,CASE WHEN v_fund_id = v_fund_pay_id THEN 1.0 ELSE CASE WHEN
                                             acc_new.get_rate_by_id(v_rate_type_id
                                                                   ,v_fund_pay_id
                                                                   ,v_first_payment_date) <> 0 THEN
                                             acc_new.get_rate_by_id(v_rate_type_id
                                                                   ,v_fund_id
                                                                   ,v_first_payment_date) /
                                             acc_new.get_rate_by_id(v_rate_type_id
                                                                   ,v_fund_pay_id
                                                                   ,v_first_payment_date) ELSE 1.0 END END
                                            ,v_declarant_id
                                            ,NULL
                                            ,v_company_bank_acc_id
                                            ,v_first_payment_date
                                            ,v_claim.c_claim_id);
        END IF;
      END IF;
    END IF;
  END;

  FUNCTION get_period_date
  (
    p_start_date      DATE
   ,p_num_of_payments NUMBER
   ,p_date            DATE
  ) RETURN DATE IS
  
    v_months_diff      NUMBER;
    v_years            NUMBER;
    v_pay_period       NUMBER;
    v_pay_period_count NUMBER;
  BEGIN
    v_pay_period := 12 / p_num_of_payments;
  
    v_months_diff := MONTHS_BETWEEN(p_date, p_start_date);
    -- сколько целых лет между датами
    v_years := FLOOR(v_months_diff / 12);
    -- сколько ЦЕЛЫХ периодов оплаты от начала страхового года до даты начала версии
    v_pay_period_count := FLOOR(MOD(v_months_diff, 12) / v_pay_period);
  
    RETURN ADD_MONTHS(ADD_MONTHS(p_start_date, 12 * v_years), v_pay_period * v_pay_period_count);
  END;

  FUNCTION get_plan_acc_date(p_acc_id NUMBER) RETURN DATE IS
    v_months_cnt      NUMBER;
    v_num_of_payments NUMBER;
    v_first_pay_date  DATE;
    v_pol_id          NUMBER;
    v_pt_brief        VARCHAR2(100);
    v_due_date        DATE;
    v_months_diff     NUMBER;
    v_years           NUMBER;
    v_months          NUMBER;
  BEGIN
    -- Получаю полис
    BEGIN
      SELECT dd.parent_id
            ,ap.due_date
        INTO v_pol_id
            ,v_due_date
        FROM doc_doc    dd
            ,document   d
            ,doc_templ  dt
            ,ac_payment ap
       WHERE dd.child_id = p_acc_id
         AND dd.parent_id = d.document_id
         AND d.doc_templ_id = dt.doc_templ_id
         AND dt.brief = 'POLICY'
         AND ap.payment_id = p_acc_id;
    EXCEPTION
      WHEN no_data_found THEN
        RETURN NULL;
    END;
    -- Получаю кол-во платежей в году и дату первого платежа
    SELECT pt.number_of_payments
          ,
           --p.FIRST_PAY_DATE,
           -- исправлено. дата эл-та план-графика должна считаться не от даты 1 платежа,
           -- а от даты начала версии
           -- ДЛЯ ГРУППОВЫХ ДОГОВОРОВ БЕРЕТСЯ START_DATE 1-й версии
           decode(nvl(p.is_group_flag, 0), 1, ph.start_date, p.start_date)
          ,pt.brief
      INTO v_num_of_payments
          ,v_first_pay_date
          ,v_pt_brief
      FROM t_payment_terms pt
          ,p_policy        p
          ,p_pol_header    ph
     WHERE p.policy_id = v_pol_id
       AND pt.id(+) = p.payment_term_id
       AND ph.policy_header_id = p.pol_header_id;
  
    IF nvl(v_pt_brief, '?') = 'Единовременно'
    THEN
      RETURN v_first_pay_date;
    ELSE
      IF v_num_of_payments IS NULL
      THEN
        raise_application_error(-20100
                               ,'Количество платежей в год не задано. p_policy_id= ' || v_pol_id);
      END IF;
      v_due_date       := trunc(v_due_date, 'DD');
      v_first_pay_date := trunc(v_first_pay_date, 'DD');
      IF v_due_date < v_first_pay_date
      THEN
        RETURN v_first_pay_date;
      END IF;
      v_months_diff := MONTHS_BETWEEN(v_due_date, v_first_pay_date);
      -- сколько целых лет между датами
      v_years := trunc(v_months_diff / 12);
      -- сколько целых периодов оплаты от начала страхового года до даты счета
      v_months := trunc(MOD(v_months_diff, 12) / (12 / v_num_of_payments));
      RETURN ADD_MONTHS(ADD_MONTHS(v_first_pay_date, 12 * v_years)
                       ,(12 / v_num_of_payments) * v_months);
    END IF;
  END;

  FUNCTION is_first_acc(p_acc_id NUMBER) RETURN NUMBER IS
    v_months_cnt      NUMBER;
    v_num_of_payments NUMBER;
    v_first_pay_date  DATE;
    v_pol_id          NUMBER;
  BEGIN
    -- Получаю полис
    SELECT dd.parent_id
      INTO v_pol_id
      FROM doc_doc   dd
          ,document  d
          ,doc_templ dt
     WHERE dd.child_id = p_acc_id
       AND dd.parent_id = d.document_id
       AND d.doc_templ_id = dt.doc_templ_id
       AND dt.brief = 'POLICY';
    -- Получаю кол-во платежей в году и дату первого платежа
    SELECT pt.number_of_payments
          ,p.first_pay_date
      INTO v_num_of_payments
          ,v_first_pay_date
      FROM t_payment_terms pt
          ,p_policy        p
     WHERE p.policy_id = v_pol_id
       AND pt.id(+) = p.payment_term_id;
    -- Если 1 в год или единовременно, то это первый счет в страховом году
    IF nvl(v_num_of_payments, 1) = 1
    THEN
      RETURN 1;
    ELSE
      BEGIN
        SELECT MOD(MONTHS_BETWEEN(trunc(ap.due_date, 'DD'), trunc(v_first_pay_date, 'DD')), 12)
          INTO v_months_cnt
          FROM ac_payment ap
         WHERE ap.payment_id = p_acc_id;
        IF v_months_cnt >= 0
           AND v_months_cnt < 12 / v_num_of_payments
        THEN
          RETURN 1;
        END IF;
      END;
    END IF;
  
    RETURN 0;
  
  END;

  PROCEDURE agent_make_planning(p_agent_report_id NUMBER) IS
    v_agent_report        ven_agent_report%ROWTYPE;
    v_pay_count           NUMBER;
    v_payment_id          NUMBER;
    v_fund_id             NUMBER;
    v_payment_templ_id    NUMBER;
    v_rate_type_id        NUMBER;
    v_company_bank_acc_id NUMBER;
    v_total_amount        NUMBER;
    v_payment_term_id     NUMBER;
    v_agent_id            NUMBER;
  BEGIN
  
    SELECT * INTO v_agent_report FROM ven_agent_report t WHERE t.agent_report_id = p_agent_report_id;
  
    SELECT f.fund_id INTO v_fund_id FROM fund f WHERE f.brief = 'RUR';
  
    -- проверить наличие созданных распоряжений на выплату агенту
    SELECT COUNT(*)
      INTO v_pay_count
      FROM doc_doc   dd
          ,document  d
          ,doc_templ dt
     WHERE dd.parent_id = p_agent_report_id
       AND d.document_id = dd.child_id
       AND d.doc_templ_id = dt.doc_templ_id
       AND dt.brief = 'PAYAGENT';
  
    IF v_pay_count = 0
    THEN
    
      SELECT pt.payment_templ_id
        INTO v_payment_templ_id
        FROM ac_payment_templ pt
       WHERE pt.brief = 'PAYAGENT';
    
      SELECT rt.rate_type_id INTO v_rate_type_id FROM rate_type rt WHERE rt.brief = 'ЦБ';
    
      SELECT cba.id
        INTO v_company_bank_acc_id
        FROM cn_contact_bank_acc cba
       WHERE cba.contact_id = pkg_app_param.get_app_param_u('WHOAMI')
         AND cba.id = (SELECT MAX(cbas.id)
                         FROM cn_contact_bank_acc cbas
                        WHERE cbas.contact_id = pkg_app_param.get_app_param_u('WHOAMI'));
    
      SELECT nvl(SUM(arc.comission_sum), 0)
        INTO v_total_amount
        FROM agent_report_cont arc
       WHERE arc.agent_report_id = p_agent_report_id
         AND arc.is_deduct = 0;
    
      SELECT pt.id
        INTO v_payment_term_id
        FROM t_payment_terms     pt
            ,t_collection_method cm
       WHERE pt.collection_method_id = cm.id
         AND pt.is_periodical = 0
         AND cm.description = 'Наличный расчет'
         AND pt.description = 'Единовременно';
    
      SELECT ach.agent_id
        INTO v_agent_id
        FROM ag_contract_header ach
       WHERE ach.ag_contract_header_id = v_agent_report.ag_contract_h_id;
    
      dbms_output.put_line('v_Total_Amount=' || v_total_amount);
    
      IF v_total_amount > 0
      THEN
        v_payment_id := create_paymnt_by_templ(v_payment_templ_id
                                              ,v_payment_term_id
                                              ,1
                                              ,v_agent_report.report_date
                                              ,v_agent_report.report_date
                                              ,v_total_amount
                                              ,v_fund_id
                                              ,v_total_amount
                                              ,v_fund_id
                                              ,v_rate_type_id
                                              ,1.0
                                              ,v_agent_id
                                              ,NULL
                                              ,v_company_bank_acc_id
                                              ,'Выплатить согласно отчета агента №' ||
                                               v_agent_report.num || ' от ' ||
                                               to_char(v_agent_report.report_date, 'dd.mm.yyyy')
                                              ,v_agent_report.agent_report_id);
      
      END IF;
    END IF;
  END;

  /*
    старая версия.
    с 01.03.2007 использовать новую версию
  
    procedure policy_charge(p_p_policy_id number) is
      v_pol_header      p_pol_header%rowtype;
      v_policy          p_policy%rowtype;
      v_charge_id       number;
      v_repay_charge_id number;
      v_status_id       number;
      v_res_id          number;
      v_diff_amount     number; --сумма разницы начисления по объекту+риску
      v_ret_amount      number; --сумма возврата премии
    begin
      if p_p_policy_id is null then
        return;
      end if;
      select p.*
        into v_policy
        from p_policy p
       where p.policy_id = p_p_policy_id;
      SELECT ph.*
        into v_pol_header
        FROM p_pol_header ph
       where ph.policy_header_id = v_policy.pol_header_id;
  
      v_status_id := doc.get_doc_status_id(p_p_policy_id);
  
      for rec in (select pc.p_cover_id,
                         pc.ent_id,
                         pc.start_date,
                         pc.end_date,
                         pc.premium,
                         sh.brief
                    from p_cover pc, as_asset a, status_hist sh
                   where a.p_policy_id = p_p_policy_id
                     and pc.as_asset_id = a.as_asset_id
                     and pc.status_hist_id = sh.status_hist_id) loop
        -- сумма к начислению возврата = оплаченная сумма - новая премия - начисленная сумма возврата
  
        v_diff_amount := case
                           when rec.brief <> 'DELETED' then rec.premium
                           else 0
                         end -
                         get_pay_cover_amount(to_date('01011900', 'DDMMYYYY'),
                                              to_date('01012900', 'DDMMYYYY'),
                                              rec.p_cover_id).fund_amount +
                         get_repay_charge_cover_amount(to_date('01011900',
                                                               'DDMMYYYY'),
                                                       to_date('01012900',
                                                               'DDMMYYYY'),
                                                       rec.p_cover_id).fund_amount;
  
  
  
        -- создаем операцию по начислению возврата
        if (v_diff_amount < 0) then
          v_res_id := acc_new.Run_Oper_By_Template(v_repay_charge_Oper_Templ_ID,
                                                       p_p_policy_id,
                                                       rec.ent_id,
                                                       rec.p_cover_id,
                                                       v_status_id,
                                                       1,
                                                       abs(v_diff_amount));
        else
          if (v_diff_amount > 0) then
            v_res_id := acc_new.Run_Oper_By_Template(v_charge_Oper_Templ_ID,
                                                     p_p_policy_id,
                                                     rec.ent_id,
                                                     rec.p_cover_id,
                                                     v_status_id,
                                                     1,
                                                     v_diff_amount);
          end if;
        end if;
  
      end loop;
  
      -- todo начисленный возврат зачесть в счет неолаченных рисков
  
      exception
      when others then
        raise_application_error(-20000,sqlerrm);
    end;
  */

  FUNCTION iscloseperiod(p_year NUMBER) RETURN NUMBER AS
    res NUMBER;
  BEGIN
    SELECT COUNT(*)
      INTO res
      FROM t_period_closed
     WHERE period_date = to_date('31.12.' || p_year, 'DD.MM.YYYY');
  
    RETURN res;
  END iscloseperiod;

  PROCEDURE policy_charge(p_p_policy_id NUMBER) IS
    v_pol_header        p_pol_header%ROWTYPE;
    v_policy            p_policy%ROWTYPE;
    v_charge_id         NUMBER;
    v_repay_charge_id   NUMBER;
    v_status_id         NUMBER;
    v_res_id            NUMBER;
    v_diff_amount       NUMBER; --сумма разницы начисления по объекту+риску
    v_ret_amount        NUMBER; --сумма возврата премии
    v_ret_dop           NUMBER; --сумма возврата доп дохода
    v_ret_surr          NUMBER; --сумма возврата выкупной суммы
    v_paid_amount       NUMBER; --ранее оплаченная премия
    v_ret_charge_amount NUMBER; --ранее начисленная к возврату премия
    v_ape_amount        NUMBER;
    v_st                NUMBER;
    v_key               NUMBER;
    v_comm_amt          NUMBER;
    v_company           VARCHAR2(100);
    v_year_number       NUMBER;
    v_charge_amount     NUMBER;
  BEGIN
    IF p_p_policy_id IS NULL
    THEN
      RETURN;
    END IF;
    SELECT p.* INTO v_policy FROM p_policy p WHERE p.policy_id = p_p_policy_id;
    SELECT ph.*
      INTO v_pol_header
      FROM p_pol_header ph
     WHERE ph.policy_header_id = v_policy.pol_header_id;
  
    v_status_id := doc.get_last_doc_status_id(p_p_policy_id);
    SELECT doc_status_ref_id INTO v_status_id FROM doc_status WHERE doc_status_id = v_status_id;
    ag_comm_cache.delete;
    <<loop_cover>>
    FOR rec IN (SELECT DISTINCT pc.p_cover_id
                               ,pc.ent_id
                               ,pc.start_date
                               ,pc.end_date
                               ,pc.premium
                               ,pc.old_premium
                               ,pc.status_hist_id
                               ,sh.brief
                               ,ig.life_property
                               ,pl.id product_line_id
                               ,pc.return_summ
                --pc.handch_dop
                --   pc.handch_surr
                  FROM as_asset               a
                      ,p_cover                pc
                      ,status_hist            sh
                      ,ven_t_prod_line_option plo
                      ,ven_t_product_line     pl
                      ,ven_t_lob_line         ll
                      ,ven_t_insurance_group  ig
                 WHERE pc.t_prod_line_option_id = plo.id
                   AND plo.product_line_id = pl.id
                   AND pl.t_lob_line_id = ll.t_lob_line_id
                   AND ll.insurance_group_id = ig.t_insurance_group_id
                   AND a.p_policy_id = p_p_policy_id
                   AND pc.as_asset_id = a.as_asset_id
                   AND pc.status_hist_id = sh.status_hist_id)
    LOOP
      -- сумма к начислению возврата = оплаченная сумма - новая премия - начисленная сумма возврата
    
      -- Ф.Ганичев      
      v_paid_amount   := pkg_payment.get_pay_cover_amount(rec.p_cover_id).fund_amount;
      v_charge_amount := pkg_payment.get_charge_cover_amount(rec.p_cover_id).fund_amount;
    
      IF nvl(pkg_app_param.get_app_param_n('CLIENTID'), 0) != 11
      THEN
        v_diff_amount := rec.premium - nvl(rec.old_premium, 0);
        -- Если уменьшили премию, то сторнируем только неоплаченное
        IF v_diff_amount < 0
        THEN
          v_diff_amount := least(0, v_paid_amount - v_charge_amount);
        END IF;
      ELSE
        v_diff_amount := rec.premium - nvl(rec.old_premium, 0);
      END IF;
      ---------------------------------
      /*
       v_paid_amount       := Pkg_Payment.get_pay_cover_amount(rec.start_date,
                                                               rec.end_date,
                                                               rec.p_cover_id)
                             .fund_amount;
       v_ret_charge_amount := get_repay_charge_cover_amount(rec.start_date,
                                                            rec.end_date,
                                                            rec.p_cover_id)
                             .fund_amount;
       IF v_paid_amount - v_ret_charge_amount > rec.premium THEN
         v_ret_amount := v_paid_amount - v_ret_charge_amount - rec.premium;
       ELSE
         v_ret_amount := 0;
       END IF;
      */
      v_ret_amount := 0;
      v_ret_dop    := 0;
      v_ret_surr   := 0;
      -- Ф.Ганичев
      BEGIN
        SELECT c.latin_name
          INTO v_company
          FROM contact c
         WHERE c.contact_id = pkg_app_param.get_app_param_u('WHOAMI');
      EXCEPTION
        WHEN no_data_found THEN
          NULL;
      END;
    
      IF v_company = 'RenLife'
         AND nvl(rec.life_property, 0) = 0
         AND doc.get_last_doc_status_brief(p_p_policy_id) IN ('BREAK', 'READY_TO_CANCEL')
      THEN
        NULL;
      ELSE
        v_diff_amount := v_diff_amount + v_ret_amount;
      END IF;
      ------------------------------
    
      IF (v_diff_amount <> 0)
      THEN
        IF nvl(rec.life_property, 0) = 0
        THEN
        
          IF (pkg_financy_weekend_fo.isfoweekpolicy(p_p_policy_id) = 1 AND v_diff_amount < 0 AND
             iscloseperiod(to_char(SYSDATE, 'YYYY') - 1) > 0)
          THEN
          
            DECLARE
              p_cover_prev_id  NUMBER := pkg_financy_weekend_fo.getprevcover(rec.p_cover_id);
              charge_year      NUMBER := get_charge_cover_amount_foy(p_cover_prev_id, to_number(to_char(SYSDATE,'YYYY')))
                                         .fund_amount;
              charge_prev_year NUMBER := get_charge_cover_amount_foy(p_cover_prev_id, to_number(to_char(SYSDATE,'YYYY') - 1))
                                         .fund_amount;
              --           pay_prev_year number :=  
              --            get_pay_cover_amount_FO(p_cover_prev_id,to_number(to_char(SYSDATE,'YYYY'))-1).fund_amount;
              --            
              --           pay_cur_year number :=  
              --            get_pay_cover_amount_FO(p_cover_prev_id,to_number(to_char(SYSDATE,'YYYY'))).fund_amount;
              --           
            BEGIN
              log(p_p_policy_id
                 ,'POLICY_CHARGE ' || v_diff_amount || ' charge_year ' || charge_year ||
                  ' charge_prev_year ' || charge_prev_year);
              -- начилсенные деньги за прошлый год  не равно оплаченному
              IF (charge_prev_year <> 0)
              THEN
              
                v_res_id := acc_new.run_oper_by_template(v_rsbu_stnachprem_templ_id
                                                        ,p_p_policy_id
                                                        ,rec.ent_id
                                                        ,rec.p_cover_id
                                                        ,v_status_id
                                                        ,1
                                                        ,abs(v_diff_amount));
              
              ELSIF (charge_year <> 0)
              THEN
              
                IF rec.status_hist_id <> pkg_cover.status_hist_id_del
                THEN
                  v_res_id := acc_new.run_oper_by_template(v_charge_oper_templ_id
                                                          ,p_p_policy_id
                                                          ,rec.ent_id
                                                          ,rec.p_cover_id
                                                          ,v_status_id
                                                          ,1
                                                          ,v_diff_amount);
                END IF;
              
              END IF;
            END;
          
          ELSE
          
            IF rec.status_hist_id <> pkg_cover.status_hist_id_del
            THEN
              v_res_id := acc_new.run_oper_by_template(v_charge_oper_templ_id
                                                      ,p_p_policy_id
                                                      ,rec.ent_id
                                                      ,rec.p_cover_id
                                                      ,v_status_id
                                                      ,1
                                                      ,v_diff_amount);
            END IF;
          END IF;
        END IF;
      
        IF nvl(pkg_app_param.get_app_param_n('CLIENTID'), 0) != 10
           AND rec.status_hist_id <> pkg_cover.status_hist_id_del
        THEN
          v_res_id := acc_new.run_oper_by_template(v_msfo_charge_oper_id
                                                  ,p_p_policy_id
                                                  ,rec.ent_id
                                                  ,rec.p_cover_id
                                                  ,v_status_id
                                                  ,1
                                                  ,v_diff_amount);
        
          v_ape_amount := nvl(rec.premium, 0) - nvl(rec.old_premium, 0);
        
          IF v_ape_amount <> 0
          THEN
            v_year_number := get_year_number(v_pol_header.start_date, v_policy.start_date);
            IF v_year_number = 0
            THEN
              v_res_id := acc_new.run_oper_by_template(v_msfo_ape_oper_id
                                                      ,p_p_policy_id
                                                      ,rec.ent_id
                                                      ,rec.p_cover_id
                                                      ,v_status_id
                                                      ,1
                                                      ,v_ape_amount);
            END IF;
          END IF;
        
          --Каткевич А.Г. 02/06/209 заменил to_char на trunc
          pkg_agent_rate.date_pay := trunc(rec.start_date, 'DD'); -- 'dd.mm.yyyy');        
          <<loop_agent>>
          FOR arec IN (SELECT ca.ent_id
                             ,ppac.p_policy_agent_com_id
                             ,ca.cover_agent_id
                             ,ppa.p_policy_agent_id
                         FROM p_policy           p
                             ,p_policy_agent     ppa
                             ,p_policy_agent_com ppac
                             ,p_cover_agent      ca
                        WHERE p.policy_id = p_p_policy_id
                          AND p.pol_header_id = ppa.policy_header_id
                          AND ppa.p_policy_agent_id = ppac.p_policy_agent_id
                          AND ppac.t_product_line_id = rec.product_line_id
                          AND ca.p_policy_agent_com_id = ppac.p_policy_agent_com_id
                          AND ca.cover_id = rec.p_cover_id)
          LOOP
          
            pkg_agent_rate.av_oav_pol_ag_com(arec.p_policy_agent_com_id
                                            ,pkg_agent_rate.date_pay
                                            ,v_st
                                            ,v_key);
            IF v_key = 0
            THEN
              v_comm_amt := ROUND(v_diff_amount * v_st / 100, 2);
            ELSE
              v_comm_amt := v_st;
            END IF;
            IF v_comm_amt <> 0
            THEN
              v_res_id := acc_new.run_oper_by_template(v_msfo_comm_oper_id
                                                      ,p_p_policy_id
                                                      ,arec.ent_id
                                                      ,arec.cover_agent_id
                                                      ,v_status_id
                                                      ,1
                                                      ,v_comm_amt);
            END IF;
          END LOOP loop_agent;
        
        END IF;
      END IF; --IF NVL(Pkg_App_Param.get_app_param_n('CLIENTID'),0)!= 10 THEN
    
      -- Ф.Ганичев. Для Жизни сумму к возврату всегда брать c покрытия
      -- Появляется эта сумма при расторжении и при исключении покрытия
      -- при этом надо исключить вариант уменьшения премии(Для РЖ)
      -- IF (Doc.get_last_doc_status_brief(p_p_policy_id) IN ('BREAK', 'READY_TO_CANCEL'))OR(rec.status_hist_id=Pkg_Cover.status_hist_id_del) THEN
      -- SELECT NVL(return_summ, 0) INTO v_ret_amount FROM
      --     P_COVER WHERE p_cover_id = rec.p_cover_id;
      -- END IF;
    
      IF (pkg_app_param.get_app_param_n('CLIENTID') = 10)
      THEN
        IF (doc.get_last_doc_status_brief(p_p_policy_id) IN ('BREAK', 'READY_TO_CANCEL'))
           OR (rec.status_hist_id = pkg_cover.status_hist_id_del)
        THEN
          v_ret_amount := nvl(rec.return_summ, 0);
          -- Ф.Ганичев  
        ELSE
          -- Возврат: оплаченная премия минус новая премия, если это >0 
          v_ret_amount := greatest(0, v_paid_amount - rec.premium);
          -------   
        
        END IF;
      ELSE
        -- Уменьшение премии, для РЖ реализуется через распоряжение на взаимозачет возврата, поэтому условие - расторгается договор или исключается покрытие
        IF (doc.get_last_doc_status_brief(p_p_policy_id) IN ('BREAK', 'READY_TO_CANCEL'))
           OR (rec.status_hist_id = pkg_cover.status_hist_id_del)
        THEN
          v_ret_amount := nvl(rec.return_summ, 0);
          v_ret_dop    := 0; --nvl(rec.handch_dop, 0);
          v_ret_surr   := 0; --nvl(rec.handch_surr,0);
        ELSE
          v_ret_amount := 0;
          v_ret_dop    := 0;
          v_ret_surr   := 0;
        END IF;
      END IF;
    
      IF (v_ret_amount <> 0)
      THEN
      
        IF (pkg_financy_weekend_fo.isfoweekpolicy(p_p_policy_id) = 1)
        THEN
        
          v_res_id := acc_new.run_oper_by_template(v_surr_charge_oper_fo_templ_id
                                                  ,p_p_policy_id
                                                  ,rec.ent_id
                                                  ,rec.p_cover_id
                                                  ,v_status_id
                                                  ,1
                                                  ,abs(v_ret_amount));
        ELSE
        
          v_res_id := acc_new.run_oper_by_template(v_repay_charge_oper_templ_id
                                                  ,p_p_policy_id
                                                  ,rec.ent_id
                                                  ,rec.p_cover_id
                                                  ,v_status_id
                                                  ,1
                                                  ,abs(v_ret_amount));
        
        END IF;
      
      END IF;
    
      IF (v_ret_dop <> 0)
      THEN
        v_res_id := acc_new.run_oper_by_template(v_dop_charge_oper_templ_id
                                                ,p_p_policy_id
                                                ,rec.ent_id
                                                ,rec.p_cover_id
                                                ,v_status_id
                                                ,1
                                                ,abs(v_ret_dop));
      END IF;
    
      IF (v_ret_surr <> 0)
      THEN
        v_res_id := acc_new.run_oper_by_template(v_surr_charge_oper_templ_id
                                                ,p_p_policy_id
                                                ,rec.ent_id
                                                ,rec.p_cover_id
                                                ,v_status_id
                                                ,1
                                                ,abs(v_ret_surr));
      END IF;
    
    END LOOP loop_cover;
  
    -- todo начисленный возврат зачесть в счет неолаченных рисков
    /*
    exception when others then
      raise_application_error(-20000,sqlerrm);
    */
  END;

  FUNCTION get_payment_sum
  (
    p_ac_payment_id NUMBER
   ,p_date          DATE DEFAULT to_date('01.01.3000', 'DD.MM.YYYY')
  ) RETURN t_paym_cont_cur IS
    c t_paym_cont_cur;
  BEGIN
  
    OPEN c FOR
      SELECT p_ac_payment_id
            ,paym_cont.obj_ure_id
            ,paym_cont.obj_uro_id
            ,paym_cont.acc_fund_id
            ,paym_cont.trans_fund_id
            ,paym_cont.acc_amount
            ,paym_cont.trans_amount
            ,nvl(dso_paym_cont.acc_amount, 0) dso_acc_amount
            ,nvl(dso_paym_cont.trans_amount, 0) dso_trans_amount
            ,paym_cont.acc_amount - nvl(dso_paym_cont.acc_amount, 0) no_dso_acc_amount
            ,paym_cont.trans_amount - nvl(dso_paym_cont.trans_amount, 0) no_dso_trans_amount
            ,SUM(paym_cont.acc_amount - nvl(dso_paym_cont.acc_amount, 0)) over() total_no_dso_acc_amount
            ,SUM(paym_cont.trans_amount - nvl(dso_paym_cont.trans_amount, 0)) over() total_no_dso_trans_amount
            ,COUNT(paym_cont.obj_uro_id) over() count_cont
        FROM -- содержимое платежа
             (SELECT t.acc_fund_id
                    ,t.trans_fund_id
                    ,SUM(t.acc_amount) acc_amount
                    ,SUM(t.trans_amount) trans_amount
                    ,t.obj_ure_id
                    ,t.obj_uro_id
                FROM ac_payment           p
                    ,ac_payment_templ     pt
                    ,trans                t
                    ,oper                 o
                    ,oper_templ           ot
                    ,rel_oper_trans_templ rot
               WHERE p.payment_id = p_ac_payment_id
                 AND p.payment_templ_id = pt.payment_templ_id
                 AND pt.self_oper_templ_id = ot.oper_templ_id
                 AND rot.oper_templ_id = ot.oper_templ_id
                 AND rot.parent_id IS NULL
                 AND t.trans_templ_id = rot.trans_templ_id
                 AND t.oper_id = o.oper_id
                 AND o.oper_templ_id = ot.oper_templ_id
                 AND o.document_id = p.payment_id
               GROUP BY t.acc_fund_id
                       ,t.trans_fund_id
                       ,t.obj_ure_id
                       ,t.obj_uro_id) paym_cont
            ,
             -- зачеты платежа
             (SELECT tt.acc_fund_id
                    ,tt.trans_fund_id
                    ,SUM(tt.acc_amount) acc_amount
                    ,SUM(tt.trans_amount) trans_amount
                    ,tt.obj_ure_id
                    ,tt.obj_uro_id
                FROM (SELECT t.acc_fund_id
                            ,t.trans_fund_id
                            ,t.acc_amount
                            ,t.trans_amount
                            ,t.obj_ure_id
                            ,t.obj_uro_id
                        FROM ac_payment  p
                            ,doc_set_off dso
                            ,
                             --      AC_PAYMENT_TEMPL     pt,
                             trans t
                            ,oper  o --,
                      --      OPER_TEMPL           ot,
                      --      REL_OPER_TRANS_TEMPL rot
                       WHERE dso.parent_doc_id = p_ac_payment_id
                         AND p.payment_id = dso.parent_doc_id
                            --AND p.payment_templ_id = pt.payment_templ_id
                            --AND pt.dso_oper_templ_id = ot.oper_templ_id
                            --AND rot.oper_templ_id = ot.oper_templ_id
                            --AND rot.oper_templ_id = pt.dso_oper_templ_id
                            --AND rot.parent_id IS NULL
                            --AND t.trans_templ_id = rot.trans_templ_id
                         AND t.oper_id = o.oper_id
                            --AND o.oper_templ_id = ot.oper_templ_id
                         AND o.document_id = dso.doc_set_off_id) tt
               GROUP BY tt.acc_fund_id
                       ,tt.trans_fund_id
                       ,tt.obj_ure_id
                       ,tt.obj_uro_id
              UNION ALL
              SELECT tt.acc_fund_id
                    ,tt.trans_fund_id
                    ,SUM(tt.acc_amount) acc_amount
                    ,SUM(tt.trans_amount) trans_amount
                    ,tt.obj_ure_id
                    ,tt.obj_uro_id
                FROM (SELECT t.acc_fund_id
                            ,t.trans_fund_id
                            ,t.acc_amount
                            ,t.trans_amount
                            ,t.obj_ure_id
                            ,t.obj_uro_id
                        FROM ac_payment           p
                            ,doc_set_off          dso
                            ,ac_payment_templ     pt
                            ,trans                t
                            ,oper                 o
                            ,oper_templ           ot
                            ,rel_oper_trans_templ rot
                       WHERE dso.child_doc_id = p_ac_payment_id
                         AND p.payment_id = dso.child_doc_id
                         AND p.payment_templ_id = pt.payment_templ_id
                         AND pt.dso_oper_templ_id = ot.oper_templ_id
                         AND rot.oper_templ_id = ot.oper_templ_id
                         AND rot.oper_templ_id = pt.dso_oper_templ_id
                         AND rot.parent_id IS NULL
                         AND t.trans_templ_id = rot.trans_templ_id
                         AND t.oper_id = o.oper_id
                         AND o.oper_templ_id = ot.oper_templ_id
                         AND o.document_id = dso.doc_set_off_id) tt
               GROUP BY tt.acc_fund_id
                       ,tt.trans_fund_id
                       ,tt.obj_ure_id
                       ,tt.obj_uro_id) dso_paym_cont
       WHERE paym_cont.obj_ure_id = dso_paym_cont.obj_ure_id(+)
         AND paym_cont.obj_uro_id = dso_paym_cont.obj_uro_id(+)
         AND paym_cont.acc_fund_id = dso_paym_cont.acc_fund_id(+)
         AND paym_cont.trans_fund_id = dso_paym_cont.trans_fund_id(+);
  
    RETURN c;
  END;

  /**
  * Процедура зачета одного платежа другим.
  * Использует фукнцию получения объектов зачитываемого платежа к зачету.
  * Пропорционально распеределяет сумму зачета пропорционально незачтенным суммам
  * объктов-содержимого платежа.
  * @author Denis Ivanov
  * @param
  */
  PROCEDURE set_off
  (
    p_parent_doc_id NUMBER
   ,p_child_doc_id  NUMBER
   ,p_dso           ven_doc_set_off%ROWTYPE
  ) IS
    v_parent_doc                 ven_ac_payment%ROWTYPE; -- родительский (зачитываемый)платеж в зачете платежей
    v_child_doc                  ven_ac_payment%ROWTYPE; -- дочерний (зачитывающий) платеж в зачете платежей
    c_no_dso_cont_cur            t_paym_cont_cur; -- курсор по суммам содержимого платежа
    v_paym_cont                  t_paym_cont; -- запись содержимого платежа
    v_coeff                      NUMBER;
    v_oper_count                 NUMBER;
    v_oper_amount                NUMBER;
    v_total_amount               NUMBER;
    v_amount_type                VARCHAR2(1);
    v_id                         NUMBER;
    v_status_id                  NUMBER;
    v_oper_templ_id              NUMBER;
    v_final_set_off_amount       NUMBER;
    v_final_child_set_off_amount NUMBER;
    v_parent_doc_amount          NUMBER;
    v_child_doc_amount           NUMBER;
    v_paid_status_id             NUMBER;
    v_paid_status_count          NUMBER;
    v_eq                         NUMBER;
    v_child_type                 VARCHAR2(50);
  
    CURSOR c_dso_oper(pc_doc_id NUMBER) IS
      SELECT rotd.oper_templ_id
            ,rotd.amount_type
        FROM rel_oper_templ_dso rotd
            ,ven_ac_payment     ap
       WHERE ap.payment_id = pc_doc_id
         AND rotd.doc_templ_id = ap.doc_templ_id;
  
    v_oper_full_amount NUMBER;
  
  BEGIN
  
    SELECT dsr.doc_status_ref_id
      INTO v_paid_status_id
      FROM doc_status_ref dsr
     WHERE dsr.brief = 'PAID';
  
    -- находим родительский (зачитываемый) и дочерний (зачитывающий) платежи
    SELECT vap.* INTO v_parent_doc FROM ven_ac_payment vap WHERE vap.payment_id = p_parent_doc_id;
  
    SELECT vap.* INTO v_child_doc FROM ven_ac_payment vap WHERE vap.payment_id = p_child_doc_id;
  
    -- находим статус документа к зачету
    SELECT dsr.doc_status_ref_id INTO v_status_id FROM doc_status_ref dsr WHERE dsr.brief = 'NEW';
  
    -- зачет родительского документа
    -- определим неоплаченные суммы зачитываемого платежа
    -- неоплаченные суммы родительского документа
    c_no_dso_cont_cur := get_payment_sum(v_parent_doc.payment_id);
    v_total_amount    := 0;
    v_oper_amount     := 0;
    v_oper_count      := 0;
  
    LOOP
      FETCH c_no_dso_cont_cur
        INTO v_paym_cont;
      EXIT WHEN c_no_dso_cont_cur%NOTFOUND;
    
      v_oper_count := v_oper_count + 1;
    
      IF v_oper_count <> v_paym_cont.count_cont
      THEN
        IF v_paym_cont.total_no_dso_acc_amount = 0
        THEN
          raise_application_error(-20110, 'Незачтенная сумма равна 0');
        END IF;
        v_coeff        := v_paym_cont.no_dso_acc_amount / v_paym_cont.total_no_dso_acc_amount;
        v_oper_amount  := v_coeff * p_dso.set_off_amount;
        v_oper_amount  := ROUND(v_oper_amount, 2);
        v_total_amount := v_total_amount + v_oper_amount;
        v_eq           := 0;
      ELSE
        v_oper_amount := ROUND(p_dso.set_off_amount - v_total_amount, 2);
        v_eq          := 1;
      END IF;
    
      dbms_output.put_line(v_oper_amount);
    
      --Каткевич А.Г. Временоне решение для зачета по удеражнной комиссии
      SELECT dt.brief
        INTO v_child_type
        FROM doc_templ dt
       WHERE dt.doc_templ_id = v_child_doc.doc_templ_id;
    
      IF v_child_type = 'ЗачетУ_КВ'
      THEN
        OPEN c_dso_oper(v_child_doc.payment_id);
      ELSE
        OPEN c_dso_oper(v_parent_doc.payment_id);
      END IF;
    
      LOOP
        FETCH c_dso_oper
          INTO v_oper_templ_id
              ,v_amount_type;
        EXIT WHEN c_dso_oper%NOTFOUND;
      
        v_oper_full_amount := ROUND(v_oper_amount * 100) / 100;
      
        v_id := acc_new.run_oper_by_template(v_oper_templ_id
                                            ,p_dso.doc_set_off_id
                                            ,v_paym_cont.obj_ure_id
                                            ,v_paym_cont.obj_uro_id
                                            ,v_status_id
                                            ,1
                                            ,v_oper_full_amount);
        IF v_eq = 1
        THEN
          FOR transes IN (SELECT * FROM trans WHERE oper_id = v_id)
          LOOP
            -- Валюта рассчета(валюта зачитываемого документа) = валюте проводки
            IF (p_dso.set_off_child_fund_id = transes.trans_fund_id)
               AND (transes.trans_fund_id <> transes.acc_fund_id)
            THEN
              DECLARE
                v_sum NUMBER;
              BEGIN
                SELECT nvl(SUM(t.trans_amount), 0)
                  INTO v_sum
                  FROM trans t
                      ,oper  o
                 WHERE t.oper_id = o.oper_id
                   AND t.trans_templ_id = transes.trans_templ_id
                   AND t.oper_id <> v_id
                   AND o.document_id = p_dso.doc_set_off_id;
                -- Сумма всех проводок по зачету в рублях должна быть равна сумме платежки
                UPDATE trans t
                   SET t.trans_amount =
                       (p_dso.set_off_child_amount - v_sum)
                      ,t.acc_rate    =
                       (p_dso.set_off_child_amount - v_sum) / t.acc_amount
                 WHERE t.trans_id = transes.trans_id;
              END;
            
            END IF;
          END LOOP;
        END IF;
      END LOOP;
      CLOSE c_dso_oper;
    END LOOP;
    CLOSE c_no_dso_cont_cur;
  
    -- зачет подчиненного документа
    -- определим неоплаченные суммы зачитываемого платежа
    -- неоплаченные суммы подчиненного документа
    c_no_dso_cont_cur := get_payment_sum(v_child_doc.payment_id);
    v_total_amount    := 0;
    v_oper_amount     := 0;
    v_oper_count      := 0;
    v_coeff           := 0;
    LOOP
      FETCH c_no_dso_cont_cur
        INTO v_paym_cont;
      EXIT WHEN c_no_dso_cont_cur%NOTFOUND;
    
      v_oper_count := v_oper_count + 1;
    
      IF v_oper_count <> v_paym_cont.count_cont
      THEN
        v_coeff        := v_paym_cont.no_dso_acc_amount / v_paym_cont.total_no_dso_acc_amount;
        v_oper_amount  := v_coeff * p_dso.set_off_child_amount;
        v_oper_amount  := ROUND(v_oper_amount, 2);
        v_total_amount := v_total_amount + v_oper_amount;
        v_eq           := 0;
      ELSE
        v_oper_amount := ROUND(p_dso.set_off_child_amount - v_total_amount, 2);
        v_eq          := 1;
      END IF;
    
      OPEN c_dso_oper(v_child_doc.payment_id);
      LOOP
        FETCH c_dso_oper
          INTO v_oper_templ_id
              ,v_amount_type;
        EXIT WHEN c_dso_oper%NOTFOUND;
        v_oper_full_amount := ROUND(v_oper_amount * 100) / 100;
      
        v_id := acc_new.run_oper_by_template(v_oper_templ_id
                                            ,p_dso.doc_set_off_id
                                            ,v_paym_cont.obj_ure_id
                                            ,v_paym_cont.obj_uro_id
                                            ,v_status_id
                                            ,1
                                            ,v_oper_full_amount);
        IF v_eq = 1
        THEN
          FOR transes IN (SELECT * FROM trans WHERE oper_id = v_id)
          LOOP
            -- Валюта рассчета(валюта подчиненного документа) = валюте проводки?
            IF (p_dso.set_off_fund_id = transes.trans_fund_id)
               AND (transes.trans_fund_id <> transes.acc_fund_id)
            THEN
              DECLARE
                v_sum NUMBER;
              BEGIN
                SELECT SUM(t.trans_amount)
                  INTO v_sum
                  FROM trans t
                      ,oper  o
                 WHERE t.oper_id = o.oper_id
                   AND t.trans_templ_id = transes.trans_templ_id
                   AND t.oper_id <> v_id
                   AND o.document_id = p_dso.doc_set_off_id;
              
                UPDATE trans t
                   SET t.trans_amount =
                       (p_dso.set_off_amount - v_sum)
                      ,t.acc_rate    =
                       (p_dso.set_off_amount - v_sum) / t.acc_amount
                 WHERE t.trans_id = transes.trans_id;
              END;
            
            END IF;
          END LOOP;
        END IF;
      
      END LOOP;
      CLOSE c_dso_oper;
    END LOOP;
    CLOSE c_no_dso_cont_cur;
  
    --проверить сумму зачета родительского документа
    --в случае полного зачета выставить статус Оплачен
  
    SELECT ap.amount
      INTO v_parent_doc_amount
      FROM ven_ac_payment ap
     WHERE ap.payment_id = p_parent_doc_id;
  
    SELECT ap.amount
      INTO v_child_doc_amount
      FROM ven_ac_payment ap
     WHERE ap.payment_id = p_child_doc_id;
  
    SELECT COUNT(*)
      INTO v_paid_status_count
      FROM ven_ac_payment   ap
          ,doc_templ_status dts
          ,doc_status_ref   dsr
     WHERE ap.payment_id = p_child_doc_id
       AND dts.doc_templ_id = ap.doc_templ_id
       AND dts.doc_status_ref_id = dsr.doc_status_ref_id
       AND dsr.brief = 'PAID';
  
    SELECT nvl(SUM(dso.set_off_amount), 0)
      INTO v_final_set_off_amount
      FROM doc_set_off dso
     WHERE dso.parent_doc_id = p_parent_doc_id
       AND dso.cancel_date IS NULL;
  
    SELECT nvl(SUM(dso.set_off_child_amount), 0)
      INTO v_final_child_set_off_amount
      FROM doc_set_off dso
     WHERE dso.child_doc_id = p_child_doc_id
       AND dso.cancel_date IS NULL;
  
    IF v_parent_doc_amount = v_final_set_off_amount
    THEN
      doc.set_doc_status(p_parent_doc_id, v_paid_status_id);
    END IF;
  
    IF v_paid_status_count > 0
    THEN
      IF v_child_doc_amount = v_final_child_set_off_amount
      THEN
        doc.set_doc_status(p_child_doc_id, v_paid_status_id);
      END IF;
    END IF;
  
  END;

  /**
  * Проведение зачета двух платежей
  * @author Denis Ivanov
  * @param doc_id Ид документа по зачету (doc_set_off)
  * @param status_id статус документа по зачету
  * @param status_date дата статуса документа по зачету
  */

  PROCEDURE set_off_status(doc_id IN NUMBER) IS
    v_dso        ven_doc_set_off%ROWTYPE; -- документ по зачету платежей
    v_paym_sum   NUMBER;
    v_setoff_sum NUMBER;
  BEGIN
  
    validate_setoff(doc_id, v_paym_sum, v_setoff_sum);
  
    -- находим документ по зачету
    SELECT vdso.* INTO v_dso FROM ven_doc_set_off vdso WHERE vdso.doc_set_off_id = doc_id;
  
    -- зачет
    set_off(v_dso.parent_doc_id, v_dso.child_doc_id, v_dso);
    -- EXCEPTION WHEN OTHERS THEN
    --                                       RAISE_APPLICATION_ERROR(-20100,SQLERRM);
  END;

  FUNCTION get_date_payments(p_policy_id IN NUMBER) RETURN VARCHAR2 IS
    v VARCHAR2(100);
  BEGIN
  
    FOR v_c IN (SELECT DISTINCT to_char(s.grace_date, 'DD.MM') d
                  FROM v_policy_payment_schedule s
                 WHERE s.policy_id = p_policy_id
                 ORDER BY d)
    LOOP
      IF v IS NOT NULL
      THEN
        v := v || ', ' || v_c.d;
      ELSE
        v := v_c.d;
      END IF;
    END LOOP;
  
    RETURN nvl(v, ' ');
  END;

  PROCEDURE make_pay_schedule(p_policy_id NUMBER) IS
    v_payment_term_id    NUMBER;
    v_paymentoff_term_id NUMBER;
  BEGIN
    SELECT p.payment_term_id
          ,p.paymentoff_term_id
      INTO v_payment_term_id
          ,v_paymentoff_term_id
      FROM ven_p_policy p
     WHERE p.policy_id = p_policy_id;
  
    log(p_policy_id, 'MAKE_PAY_SCHEDULE');
  
    pkg_payment.policy_make_planning(p_policy_id, v_payment_term_id, 'PAYMENT');
  
    pkg_payment.policy_make_planning(p_policy_id
                                    ,nvl(v_paymentoff_term_id, v_payment_term_id)
                                    ,'PAYORDBACK');
  
  END;

  PROCEDURE dso_before_delete(p_doc_id NUMBER) IS
    v_to_pay_status_id    NUMBER;
    v_paid_status_id      NUMBER;
    v_curr_status_id      NUMBER;
    v_doc_set_off         doc_set_off%ROWTYPE;
    v_to_pay_status_count NUMBER;
  BEGIN
    SELECT dsr.doc_status_ref_id
      INTO v_to_pay_status_id
      FROM doc_status_ref dsr
     WHERE dsr.brief = 'TO_PAY';
    SELECT dsr.doc_status_ref_id
      INTO v_paid_status_id
      FROM doc_status_ref dsr
     WHERE dsr.brief = 'PAID';
    SELECT * INTO v_doc_set_off FROM doc_set_off dso WHERE dso.doc_set_off_id = p_doc_id;
  
    SELECT COUNT(*)
      INTO v_to_pay_status_count
      FROM ven_ac_payment   ap
          ,doc_templ_status dts
          ,doc_status_ref   dsr
     WHERE ap.payment_id = v_doc_set_off.parent_doc_id
       AND dts.doc_templ_id = ap.doc_templ_id
       AND dts.doc_status_ref_id = dsr.doc_status_ref_id
       AND dsr.brief = 'TO_PAY';
  
    IF v_to_pay_status_count > 0
    THEN
      v_curr_status_id := doc.get_doc_status_id(v_doc_set_off.parent_doc_id);
      IF v_curr_status_id = v_paid_status_id
      THEN
        doc.set_doc_status(v_doc_set_off.parent_doc_id, v_to_pay_status_id);
      END IF;
    END IF;
  
    SELECT COUNT(*)
      INTO v_to_pay_status_count
      FROM ven_ac_payment   ap
          ,doc_templ_status dts
          ,doc_status_ref   dsr
     WHERE ap.payment_id = v_doc_set_off.child_doc_id
       AND dts.doc_templ_id = ap.doc_templ_id
       AND dts.doc_status_ref_id = dsr.doc_status_ref_id
       AND dsr.brief = 'TO_PAY';
  
    IF v_to_pay_status_count = 0
    THEN
      v_curr_status_id := doc.get_doc_status_id(v_doc_set_off.child_doc_id);
      IF v_curr_status_id = v_paid_status_id
      THEN
        doc.set_doc_status(v_doc_set_off.child_doc_id, v_to_pay_status_id);
      END IF;
    END IF;
  
  END;

  FUNCTION get_year_number
  (
    p_start_date DATE
   ,p_end_date   DATE
  ) RETURN NUMBER IS
    v_result NUMBER;
  BEGIN
    v_result := trunc(MONTHS_BETWEEN(p_end_date, p_start_date) / 12, 0);
    IF v_result < 0
    THEN
      v_result := 0;
    END IF;
    RETURN v_result;
  END;

  PROCEDURE set_policy_new_renlife(doc_id NUMBER) IS
    v_first_doc_id     NUMBER;
    v_to_pay_status_id NUMBER;
  BEGIN
    make_pay_schedule(doc_id);
  
    -- Комментарий Ф.Ганичев. Выставить первый счет к оплате нельзя если его дата больше текущей,
    -- т.к. курс на будущее(для формирования проводок) неизвестен
    /*
        SELECT MIN(ap.payment_id)
          INTO v_First_Doc_ID
          FROM doc_doc dd, ven_ac_payment ap, doc_templ dt
         WHERE dd.child_id = ap.payment_id
           AND ap.doc_templ_id = dt.doc_templ_id
           AND dt.brief = 'PAYMENT'
           AND dd.parent_id = doc_id;
    
    
        SELECT dsr.doc_status_ref_id
        INTO   v_To_Pay_Status_ID
        FROM   doc_status_ref dsr
        WHERE  dsr.brief = 'TO_PAY';
        IF v_First_Doc_ID IS NOT NULL THEN
          Doc.set_doc_status(v_First_Doc_ID, v_To_Pay_Status_ID, SYSDATE+1/24/3600);
        END IF;
    */
  END;

  PROCEDURE set_payments_to_pay(doc_id NUMBER) IS
    v_paym_status_id   NUMBER;
    v_to_pay_status_id NUMBER;
  BEGIN
    SELECT dsr.doc_status_ref_id
      INTO v_to_pay_status_id
      FROM doc_status_ref dsr
     WHERE dsr.brief = 'TO_PAY';
  
    FOR rc_paym IN (SELECT ap.payment_id
                      FROM doc_doc        dd
                          ,ven_ac_payment ap
                          ,doc_templ      dt
                     WHERE dd.child_id = ap.payment_id
                       AND ap.doc_templ_id = dt.doc_templ_id
                       AND dt.brief = 'PAYMENT'
                       AND ap.due_date <= SYSDATE
                       AND dd.parent_id = doc_id)
    LOOP
      v_paym_status_id := doc.get_last_doc_status_id(rc_paym.payment_id);
      BEGIN
        -- Проверка, что счет в статусе Новый статус действует с даты<=sysdate
        SELECT doc_status_id
          INTO v_paym_status_id
          FROM doc_status     ds
              ,doc_status_ref dsr
         WHERE dsr.brief = 'NEW'
           AND ds.doc_status_ref_id = dsr.doc_status_ref_id
           AND ds.start_date <= SYSDATE
           AND ds.doc_status_id = v_paym_status_id;
        doc.set_doc_status(rc_paym.payment_id, v_to_pay_status_id, SYSDATE + 1 / 24 / 3600);
      EXCEPTION
        WHEN no_data_found THEN
          NULL;
      END;
    END LOOP;
  END;

  PROCEDURE delete_payments_pol(doc_id NUMBER) IS
    v_deleted NUMBER;
  BEGIN
    FOR rc IN (SELECT ap.payment_id
                     ,ap.amount
                     ,dt.brief
                     ,dt.name
                     ,ap.num
                     ,ap.reg_date
                     ,f.brief fund
                 FROM ven_ac_payment ap
                     ,doc_doc        dd
                     ,doc_templ      dt
                     ,fund           f
                WHERE dd.child_id = ap.payment_id
                  AND dd.parent_id = doc_id
                  AND dt.doc_templ_id = ap.doc_templ_id
                  AND dt.brief IN ('PAYMENT', 'PAYMENT_SETOFF_ACC')
                  AND f.fund_id = ap.fund_id)
    LOOP
      v_deleted := delete_payment(rc.payment_id, rc.brief, rc.amount);
      IF v_deleted != 1
      THEN
        -- Не генерить ошибку при создании новой версии
        IF utils.get_null('new_policy_version', 0) != 1
        THEN
          raise_application_error(-20100
                                 ,'По версии есть оплаченный ' || rc.name || ' №' || rc.num || ' от ' ||
                                  rc.reg_date || ' на сумму ' || rc.amount || ' ' || rc.fund);
        END IF;
      END IF;
    END LOOP;
  END;

  FUNCTION delete_payment
  (
    p_payment_id NUMBER
   ,p_doc_templ  VARCHAR2
   ,p_amount     NUMBER DEFAULT NULL
  ) RETURN NUMBER IS
    v_amount           NUMBER;
    v_res              NUMBER := 0;
    v_last_status_id   NUMBER;
    v_last_status      VARCHAR2(100);
    v_last_status_date DATE;
  BEGIN
    IF p_amount IS NULL
    THEN
      SELECT ap.amount INTO v_amount FROM ven_ac_payment ap WHERE ap.payment_id = p_payment_id;
    ELSE
      v_amount := p_amount;
    END IF;
    v_last_status_id := doc.get_last_doc_status_id(p_payment_id);
  
    SELECT dsf.brief
          ,greatest(ds.start_date + 1 / 24 / 3600, SYSDATE)
      INTO v_last_status
          ,v_last_status_date
      FROM doc_status     ds
          ,doc_status_ref dsf
     WHERE ds.doc_status_id = v_last_status_id
       AND ds.doc_status_ref_id = dsf.doc_status_ref_id;
  
    CASE v_last_status
      WHEN 'NEW' THEN
        DELETE FROM document d WHERE document_id = p_payment_id;
        v_res := 1;
      WHEN 'TO_PAY' THEN
        IF p_doc_templ = 'PAYMENT'
        THEN
          FOR rc_dso IN (SELECT nvl(SUM(dso.set_off_amount), 0) s
                           FROM doc_set_off dso
                          WHERE dso.parent_doc_id = p_payment_id
                            AND p_doc_templ = 'PAYMENT'
                               --05/05/2009 Каткевич А.Г. ЭПГ по аннулированным зачетам тоже аннулируем
                            AND doc.get_doc_status_brief(dso.doc_set_off_id) <> 'ANNULATED')
          LOOP
            IF rc_dso.s = 0
            THEN
              BEGIN
                SAVEPOINT spp;
                doc.set_doc_status(p_payment_id, 'NEW', v_last_status_date);
                DELETE FROM document d WHERE document_id = p_payment_id;
              EXCEPTION
                WHEN OTHERS THEN
                  ROLLBACK TO spp;
                  doc.set_doc_status(p_payment_id, 'ANNULATED', v_last_status_date);
              END;
              v_res := 1;
            ELSIF rc_dso.s < v_amount
            THEN
              UPDATE ac_payment ap
                 SET ap.amount     = rc_dso.s
                    ,ap.rev_amount = ROUND(ap.rev_rate * rc_dso.s, 2)
               WHERE ap.payment_id = p_payment_id;
              doc.set_doc_status(p_payment_id, 'PAID', v_last_status_date);
            END IF;
          END LOOP;
        ELSE
          FOR rc_dso IN (SELECT nvl(SUM(dso.set_off_amount), 0) s
                           FROM doc_set_off dso
                          WHERE dso.child_doc_id = p_payment_id
                            AND p_doc_templ = 'PAYMENT_SETOFF_ACC')
          LOOP
            IF rc_dso.s = 0
            THEN
              BEGIN
                SAVEPOINT spp;
                doc.set_doc_status(p_payment_id, 'NEW', v_last_status_date);
                DELETE FROM document d WHERE document_id = p_payment_id;
              EXCEPTION
                WHEN OTHERS THEN
                  ROLLBACK TO spp;
                  doc.set_doc_status(p_payment_id, 'ANNULATED', v_last_status_date);
              END;
              v_res := 1;
            ELSIF rc_dso.s < v_amount
            THEN
              UPDATE ac_payment ap
                 SET ap.amount     = rc_dso.s
                    ,ap.rev_amount = ROUND(ap.rev_rate * rc_dso.s, 2)
               WHERE ap.payment_id = p_payment_id;
              doc.set_doc_status(p_payment_id, 'PAID', v_last_status_date);
            END IF;
          END LOOP;
        END IF;
      ELSE
        NULL;
    END CASE;
    RETURN v_res;
  END;

  PROCEDURE delete_unpayed
  (
    doc_id     IN NUMBER
   ,p_due_date DATE DEFAULT NULL
  ) IS
    v_deleted NUMBER;
  BEGIN
    FOR rc IN (SELECT ap.payment_id
                     ,ap.amount
                     ,dt.brief
                 FROM p_policy       p
                     ,ven_ac_payment ap
                     ,doc_doc        dd
                     ,doc_templ      dt
                WHERE p.pol_header_id = doc_id
                  AND dd.child_id = ap.payment_id
                  AND dd.parent_id = p.policy_id
                  AND dt.doc_templ_id = ap.doc_templ_id
                  AND dt.brief IN ('PAYMENT', 'PAYMENT_SETOFF_ACC')
                  AND ap.due_date >= nvl(p_due_date, ap.due_date))
    LOOP
      v_deleted := delete_payment(rc.payment_id, rc.brief, rc.amount);
    END LOOP;
  END;

  PROCEDURE delete_unpayed_pol(doc_id IN NUMBER) IS
  BEGIN
    FOR rc IN (SELECT p.pol_header_id
                     ,p.start_date
                 FROM p_policy p
                WHERE p.policy_id = doc_id)
    LOOP
      delete_unpayed(rc.pol_header_id, rc.start_date);
    END LOOP;
  END;

  PROCEDURE delete_unpayed_gpol(doc_id IN NUMBER) IS
  BEGIN
    FOR rc IN (SELECT DISTINCT p.pol_header_id
                 FROM gen_policy gp
                     ,doc_doc    dd
                     ,p_policy   p
                WHERE gp.gen_policy_id = doc_id
                  AND gp.gen_policy_id = dd.parent_id
                  AND dd.child_id = p.policy_id)
    LOOP
      delete_unpayed(rc.pol_header_id);
    END LOOP;
  END;

  --Сумма выплаченного возмещения по договору за период
  FUNCTION get_ph_claim_pay_amount
  (
    p_pol_header_id IN NUMBER
   ,p_start_date    IN DATE
   ,p_end_date      IN DATE
  ) RETURN NUMBER IS
  
    v_sum        NUMBER;
    v_result     acc_new.t_turn_rest;
    v_account_id NUMBER;
    v_fund_id    NUMBER;
    v_policy_id  NUMBER;
  BEGIN
    SELECT a.account_id INTO v_account_id FROM account a WHERE a.num = '77.09.02';
    SELECT f.fund_id INTO v_fund_id FROM fund f WHERE f.brief = 'RUR';
    v_sum := 0;
    FOR v_num IN (SELECT p.policy_id
                    FROM p_policy p
                   WHERE p.pol_header_id = p_pol_header_id
                     AND p_start_date BETWEEN p.start_date AND p.end_date
                     AND p_end_date BETWEEN p.start_date AND p.end_date)
    LOOP
      v_result := acc_new.get_acc_turn_rest(v_account_id
                                           ,v_fund_id
                                           ,p_start_date
                                           ,p_end_date
                                           ,NULL
                                           ,0
                                           ,v_num.policy_id
                                           ,0
                                           ,NULL
                                           ,0
                                           ,NULL
                                           ,0
                                           ,NULL
                                           ,0);
      v_sum    := v_result.turn_dt_base_fund + v_sum;
    END LOOP;
    RETURN v_sum;
  END;

  --Сумма выплаченного возврата по договору за период
  FUNCTION get_ph_ret_pay_amount
  (
    p_pol_header_id IN NUMBER
   ,p_start_date    IN DATE
   ,p_end_date      IN DATE
  ) RETURN NUMBER IS
    v_sum        NUMBER;
    v_result     acc_new.t_turn_rest;
    v_account_id NUMBER;
    v_fund_id    NUMBER;
    v_policy_id  NUMBER;
  BEGIN
    SELECT a.account_id INTO v_account_id FROM account a WHERE a.num = '77.09.04';
    SELECT f.fund_id INTO v_fund_id FROM fund f WHERE f.brief = 'RUR';
    v_sum := 0;
    FOR v_num IN (SELECT p.policy_id
                    FROM p_policy p
                   WHERE p.pol_header_id = p_pol_header_id
                     AND p_start_date BETWEEN p.start_date AND p.end_date
                     AND p_end_date BETWEEN p.start_date AND p.end_date)
    LOOP
      v_result := acc_new.get_acc_turn_rest(v_account_id
                                           ,v_fund_id
                                           ,p_start_date
                                           ,p_end_date
                                           ,NULL
                                           ,0
                                           ,v_num.policy_id
                                           ,0
                                           ,NULL
                                           ,0
                                           ,NULL
                                           ,0
                                           ,NULL
                                           ,0);
      v_sum    := v_result.turn_ct_base_fund + v_sum;
    END LOOP;
    RETURN v_sum;
  END;

  FUNCTION get_charge_prodline_amount
  (
    p_p_cover_id NUMBER
   ,p_start_date DATE
   ,p_end_date   DATE
  ) RETURN t_amount IS
    v_rest            acc_new.t_turn_rest;
    v_ret_val         t_amount;
    v_asset_header_id NUMBER;
    v_plo_id          NUMBER;
    v_fund_id         NUMBER;
    v_sum             NUMBER;
    v_pol_id          NUMBER;
  BEGIN
    SELECT a.p_asset_header_id
          ,pc.t_prod_line_option_id
          ,ph.fund_id
          ,p.policy_id
      INTO v_asset_header_id
          ,v_plo_id
          ,v_fund_id
          ,v_pol_id
      FROM p_cover      pc
          ,as_asset     a
          ,p_policy     p
          ,p_pol_header ph
     WHERE pc.p_cover_id = p_p_cover_id
       AND pc.as_asset_id = a.as_asset_id
       AND a.p_policy_id = p.policy_id
       AND p.pol_header_id = ph.policy_header_id;
    /*
        v_Rest:= Acc_New.Get_Acc_Turn_Rest(v_pay_acc_id,
                              v_fund_id,
                              p_start_date,
                              p_end_date,
                              NULL,
                              0,
                              NULL,
                              0,
                              v_asset_header_id,
                              0,
                              v_plo_id,
                              0);
            v_ret_val.fund_amount:=   v_rest.turn_dt_fund;
            v_ret_val.pay_fund_amount := v_rest.turn_dt_base_fund;
    */
  
    SELECT nvl(SUM(t.acc_amount), 0)
      INTO v_sum
      FROM trans      t
          ,oper       o
          ,ac_payment acp
          ,doc_doc    dd
          ,p_policy   p1
          ,p_policy   p2
     WHERE o.document_id = acp.payment_id
       AND (p_start_date IS NULL OR acp.plan_date = p_start_date)
       AND acp.payment_id = dd.child_id
       AND dd.parent_id = p1.policy_id
       AND t.dt_account_id = v_pay_acc_id
       AND t.a3_dt_uro_id = v_asset_header_id
          --
          -- Каткевич А.Г. 
          -- Не понятно зачем смтореть на версию если мы уже смотрим на хедер
          -- 
          -- AND  t.A4_DT_URO_ID = v_plo_id
       AND p1.pol_header_id = p2.pol_header_id
       AND p2.policy_id = v_pol_id
       AND o.oper_id = t.oper_id;
  
    v_ret_val.fund_amount := v_sum;
    RETURN v_ret_val;
  END;

  -- Остаток на счете 77.01.02
  FUNCTION get_debt_cover_amount(p_p_cover_id NUMBER) RETURN t_amount IS
    v_ret_val1        t_amount;
    v_ret_val2        t_amount;
    v_asset_header_id NUMBER;
    v_plo_id          NUMBER;
    v_fund_id         NUMBER;
    v_pol_header_id   NUMBER;
    v_policy_id       NUMBER;
  BEGIN
  
    SELECT a.p_asset_header_id
          ,pc.t_prod_line_option_id
          ,ph.fund_id
          ,p.policy_id
          ,p.pol_header_id
      INTO v_asset_header_id
          ,v_plo_id
          ,v_fund_id
          ,v_policy_id
          ,v_pol_header_id
      FROM p_cover      pc
          ,as_asset     a
          ,p_policy     p
          ,p_pol_header ph
     WHERE pc.p_cover_id = p_p_cover_id
       AND pc.as_asset_id = a.as_asset_id
       AND a.p_policy_id = p.policy_id
       AND p.pol_header_id = ph.policy_header_id;
  
    -- Оплачено
    SELECT nvl(SUM(t.trans_amount), 0)
          ,nvl(SUM(t.acc_amount), 0)
      INTO v_ret_val1.pay_fund_amount
          ,v_ret_val1.fund_amount
      FROM trans    t
          ,p_policy pp
    
     WHERE t.a2_ct_uro_id = pp.policy_id
       AND t.ct_account_id = v_pay_acc_id
       AND t.a3_ct_uro_id = v_asset_header_id
       AND t.a4_ct_uro_id = v_plo_id
       AND pp.pol_header_id = v_pol_header_id
       AND is_version_cover(v_policy_id, t.a5_ct_uro_id, v_asset_header_id, v_plo_id, v_pol_header_id) = 1;
  
    -- Начислено
    SELECT nvl(SUM(t.trans_amount), 0)
          ,nvl(SUM(t.acc_amount), 0)
      INTO v_ret_val2.pay_fund_amount
          ,v_ret_val2.fund_amount
      FROM trans    t
          ,p_policy pp
    
     WHERE t.a2_dt_uro_id = pp.policy_id
       AND t.dt_account_id = v_pay_acc_id
       AND t.a3_dt_uro_id = v_asset_header_id
       AND t.a4_dt_uro_id = v_plo_id
       AND pp.pol_header_id = v_pol_header_id
       AND is_version_cover(v_policy_id, t.a5_dt_uro_id, v_asset_header_id, v_plo_id, v_pol_header_id) = 1;
  
    v_ret_val1.fund_amount     := nvl(v_ret_val2.fund_amount, 0) - nvl(v_ret_val1.fund_amount, 0);
    v_ret_val1.pay_fund_amount := nvl(v_ret_val2.pay_fund_amount, 0) - nvl(v_ret_val2.fund_amount, 0);
    RETURN v_ret_val1;
  END;

  FUNCTION get_debt_cover_amount
  (
    p_p_cover_id NUMBER
   ,p_date       DATE
  ) RETURN t_amount IS
    v_rest            acc_new.t_rest;
    v_ret_val         t_amount;
    v_asset_header_id NUMBER;
    v_plo_id          NUMBER;
    v_fund_id         NUMBER;
  BEGIN
    SELECT a.p_asset_header_id
          ,pc.t_prod_line_option_id
          ,ph.fund_id
      INTO v_asset_header_id
          ,v_plo_id
          ,v_fund_id
      FROM p_cover      pc
          ,as_asset     a
          ,p_policy     p
          ,p_pol_header ph
     WHERE pc.p_cover_id = p_p_cover_id
       AND pc.as_asset_id = a.as_asset_id
       AND a.p_policy_id = p.policy_id
       AND p.pol_header_id = ph.policy_header_id;
  
    v_rest                    := acc_new.get_acc_rest(v_pay_acc_id
                                                     ,v_fund_id
                                                     ,p_date
                                                     ,NULL
                                                     ,0
                                                     ,NULL
                                                     ,0
                                                     ,v_asset_header_id
                                                     ,0
                                                     ,v_plo_id
                                                     ,0
                                                     ,NULL
                                                     ,0);
    v_ret_val.fund_amount     := v_rest.rest_amount_fund;
    v_ret_val.pay_fund_amount := v_rest.rest_amount_base_fund;
    RETURN v_ret_val;
  END;

  FUNCTION get_calc_agent_amount_pfa
  (
    p_pol_header_id IN NUMBER
   ,p_start_date    IN DATE
   ,p_end_date      IN DATE
  ) RETURN NUMBER IS
    v_result    NUMBER;
    v_turn_rest acc_new.t_turn_rest;
    v_fund_id   NUMBER;
  BEGIN
  
    SELECT f.fund_id INTO v_fund_id FROM fund f WHERE f.brief = 'RUR';
  
    v_turn_rest := acc_new.get_acc_turn_rest(v_ag_com_acc_id
                                            ,v_fund_id
                                            ,p_start_date
                                            ,p_end_date
                                            ,NULL
                                            ,0
                                            ,NULL
                                            ,0
                                            ,p_pol_header_id
                                            ,0
                                            ,NULL
                                            ,0
                                            ,NULL
                                            ,0);
  
    v_result := v_turn_rest.turn_ct_fund;
  
    RETURN v_result;
  END;

  FUNCTION get_repay_charge_amount_pfa
  (
    p_start_date DATE
   ,p_end_date   DATE
   ,p_p_cover_id NUMBER
  ) RETURN NUMBER IS
    v_fund_id NUMBER;
  BEGIN
  
    SELECT f.fund_id INTO v_fund_id FROM fund f WHERE f.brief = 'RUR';
  
    RETURN get_repay_charge_amount(v_fund_id
                                  ,p_start_date
                                  ,p_end_date
                                  ,NULL
                                  ,NULL
                                  ,NULL
                                  ,NULL
                                  ,p_p_cover_id
                                   
                                   ).fund_amount;
  END;

  -- Возвращает размер недоплаты по договору
  FUNCTION get_underpayment_amount(p_pol_header_id NUMBER) RETURN NUMBER IS
    v_rest acc_new.t_rest;
    summ   NUMBER(11, 2);
  BEGIN
    summ := 0;
    FOR rec IN (SELECT pp.policy_id
                      ,ph.fund_id
                  FROM ven_p_pol_header ph
                  JOIN ven_p_policy pp
                    ON pp.pol_header_id = ph.policy_header_id
                 WHERE ph.policy_header_id = p_pol_header_id)
    LOOP
      v_rest := acc_new.get_acc_rest(v_pay_acc_id
                                    ,rec.fund_id
                                    ,SYSDATE
                                    ,NULL
                                    ,0
                                    ,rec.policy_id
                                    ,0
                                    ,NULL
                                    ,0
                                    ,NULL
                                    ,0
                                    ,NULL
                                    ,0);
      summ   := summ + v_rest.rest_amount_fund;
    END LOOP;
    RETURN to_char(summ, '999999999D99');
  END;

  PROCEDURE prem_to_pay_plan(p_acc_id NUMBER) IS
    v_oper_id NUMBER;
  BEGIN
    IF v_prem_to_pay_plan_oper_id IS NULL
    THEN
      raise_application_error(-20100
                             ,'Нет операции: ' || 'ПремияНачисленаКОплатеПлан');
    END IF;
    FOR v_pol IN (SELECT p.policy_id
                        ,dd.parent_amount
                    FROM p_policy p
                        ,doc_doc  dd
                   WHERE p.policy_id = dd.parent_id
                     AND dd.child_id = p_acc_id)
    LOOP
      v_oper_id := acc_new.run_oper_by_template(v_prem_to_pay_plan_oper_id
                                               ,v_pol.policy_id
                                               ,NULL
                                               ,NULL
                                               ,doc.get_doc_status_id(p_acc_id)
                                               ,NULL
                                               ,v_pol.parent_amount
                                               ,NULL);
    END LOOP;
  END;

  PROCEDURE setoff_annulated(p_setoff_id NUMBER) IS
  BEGIN
    FOR acp IN (SELECT ap.payment_id
                      ,dd.cancel_date
                  FROM ven_ac_payment ap
                      ,doc_set_off    dd
                      ,doc_templ      dt
                 WHERE ap.payment_id = dd.parent_doc_id
                   AND dd.doc_set_off_id = p_setoff_id
                   AND dt.doc_templ_id = ap.doc_templ_id
                /*AND dt.BRIEF IN ('PAYMENT')*/
                )
    LOOP
      doc.set_doc_status(acp.payment_id, 'TO_PAY', acp.cancel_date);
    END LOOP;
  END;

  PROCEDURE validate_setoff(p_setoff_id NUMBER) IS
    v_paym_sum   NUMBER;
    v_setoff_sum NUMBER;
  BEGIN
    validate_setoff(p_setoff_id, v_paym_sum, v_setoff_sum);
    FOR acc IN (SELECT parent_doc_id
                  FROM doc_set_off
                 WHERE doc_set_off_id = p_setoff_id
                   AND v_paym_sum = v_setoff_sum)
    LOOP
      doc.set_doc_status(acc.parent_doc_id, 'PAID');
    END LOOP;
  END;

  PROCEDURE validate_setoff
  (
    p_setoff_id   NUMBER
   ,p_payment_sum OUT NUMBER
   ,p_setoff_sum  OUT NUMBER
  ) IS
    v_setoff_sum       NUMBER;
    v_setoff_child_sum NUMBER;
    v_payment_id       NUMBER;
    v_child_id         NUMBER;
    v_paym_sum         NUMBER;
    v_child_paym_sum   NUMBER;
    v_setoff_date      DATE;
  BEGIN
    SELECT ap.payment_id
          ,ap.amount
      INTO v_payment_id
          ,v_paym_sum
      FROM ven_ac_payment ap
          ,doc_set_off    dd
          ,doc_templ      dt
     WHERE ap.payment_id = dd.parent_doc_id
       AND dd.doc_set_off_id = p_setoff_id
       AND dt.doc_templ_id = ap.doc_templ_id
    /*AND dt.BRIEF IN ('PAYMENT')*/
    ;
  
    SELECT ap.payment_id
          ,ap.amount
      INTO v_child_id
          ,v_child_paym_sum
      FROM ven_ac_payment ap
          ,doc_set_off    dd
          ,doc_templ      dt
     WHERE ap.payment_id = dd.child_doc_id
       AND dd.doc_set_off_id = p_setoff_id
       AND dt.doc_templ_id = ap.doc_templ_id;
  
    SELECT nvl(SUM(dsf.set_off_amount), 0)
      INTO v_setoff_sum
      FROM doc_set_off dsf
     WHERE dsf.parent_doc_id = v_payment_id
       AND dsf.cancel_date IS NULL;
    IF v_setoff_sum > v_paym_sum
    THEN
      raise_application_error(-20100
                             ,'Сумма зачитываемого документа меньше суммы всех зачетов по документу. Сумма документа = ' ||
                              to_char(v_paym_sum, '99g999g999d99') || ', сумма зачетов =  ' ||
                              to_char(v_setoff_sum, '99g999g999d99'));
    END IF;
  
    SELECT nvl(SUM(dsf.set_off_child_amount), 0)
      INTO v_setoff_child_sum
      FROM doc_set_off dsf
     WHERE dsf.child_doc_id = v_child_id
       AND dsf.cancel_date IS NULL;
    IF v_setoff_child_sum > v_child_paym_sum
    THEN
      raise_application_error(-20100
                             ,'Сумма зачитывающего документа меньше суммы всех зачетов по документу. Сумма документа = ' ||
                              to_char(v_child_paym_sum, '99g999g999d99') || ', сумма зачетов =  ' ||
                              to_char(v_setoff_child_sum, '99g999g999d99'));
    END IF;
  
    p_payment_sum := v_paym_sum;
    p_setoff_sum  := v_setoff_sum;
  END;

  PROCEDURE setoff_cancel_annulated(p_setoff_id NUMBER) IS
    v_setoff_sum NUMBER;
    v_payment_id NUMBER;
    v_paym_sum   NUMBER;
  BEGIN
    validate_setoff(p_setoff_id, v_paym_sum, v_setoff_sum);
    IF v_setoff_sum = v_paym_sum
    THEN
      doc.set_doc_status(v_payment_id, 'PAID', doc.get_last_doc_status_date(p_setoff_id));
    END IF;
  END;

  PROCEDURE update_paym_scheduler(p_pol_id NUMBER) IS
    v_acc_plan_date DATE;
  BEGIN
    FOR acp IN (SELECT ap.payment_id
                  FROM ac_payment ap
                      ,doc_doc    dd
                      ,p_policy   p
                      ,p_policy   p1
                 WHERE ap.payment_id = dd.child_id
                   AND dd.parent_id = p.policy_id
                   AND p1.policy_id = p_pol_id
                   AND p1.pol_header_id = p.pol_header_id)
    LOOP
      v_acc_plan_date := get_plan_acc_date(acp.payment_id);
      UPDATE ac_payment SET plan_date = v_acc_plan_date WHERE payment_id = acp.payment_id;
    END LOOP;
  END;

  FUNCTION get_ret_pay_policy_amount_num
  (
    p_start_date  DATE
   ,p_end_date    DATE
   ,p_p_policy_id NUMBER
  ) RETURN NUMBER IS
  BEGIN
    RETURN get_ret_pay_policy_amount(p_start_date, p_end_date, p_p_policy_id).fund_amount;
  END;

  FUNCTION is_version_cover
  (
    p_pol_id        NUMBER
   ,p_cov_id        NUMBER
   ,p_as_header_id  NUMBER
   ,p_plo_id        NUMBER
   ,p_pol_header_id NUMBER
  ) RETURN NUMBER IS
  
    v_pol_cover_id NUMBER;
    v_max_pc_id    NUMBER;
    v_min_pc_id    NUMBER;
  BEGIN
    BEGIN
      SELECT pc.p_cover_id
        INTO v_pol_cover_id
        FROM p_cover  pc
            ,as_asset a
       WHERE a.p_policy_id = p_pol_id
         AND pc.as_asset_id = a.as_asset_id
         AND pc.status_hist_id <> pkg_cover.status_hist_id_del
         AND pc.t_prod_line_option_id = p_plo_id
         AND a.p_asset_header_id = p_as_header_id;
    EXCEPTION
      WHEN no_data_found THEN
        RETURN 0;
    END;
  
    SELECT nvl(MAX(pc.p_cover_id), p_cov_id)
      INTO v_min_pc_id
      FROM p_cover  pc
          ,as_asset a
     WHERE a.p_policy_id IN (SELECT p_policy_id FROM p_policy WHERE pol_header_id = p_pol_header_id)
       AND pc.as_asset_id = a.as_asset_id
       AND pc.status_hist_id = pkg_cover.status_hist_id_new
       AND pc.t_prod_line_option_id = p_plo_id
       AND a.p_asset_header_id = p_as_header_id
       AND pc.p_cover_id <= v_pol_cover_id;
  
    SELECT nvl(MIN(pc.p_cover_id), p_cov_id + 1)
      INTO v_max_pc_id
      FROM p_cover  pc
          ,as_asset a
     WHERE a.p_policy_id IN (SELECT p_policy_id FROM p_policy WHERE pol_header_id = p_pol_header_id)
       AND pc.as_asset_id = a.as_asset_id
       AND pc.status_hist_id = pkg_cover.status_hist_id_new
       AND pc.t_prod_line_option_id = p_plo_id
       AND a.p_asset_header_id = p_as_header_id
       AND pc.p_cover_id > v_pol_cover_id;
    IF (v_min_pc_id <= p_cov_id)
       AND (v_max_pc_id > p_cov_id)
    THEN
      RETURN 1;
    ELSE
      RETURN 0;
    END IF;
  END;

  PROCEDURE set_acc_paid(p_acc_id NUMBER) IS
    v_cover_ent_id      NUMBER := ent.id_by_brief('P_COVER');
    v_status_ref_id     NUMBER;
    v_oper_id           NUMBER;
    v_paid_acc_amount   NUMBER;
    v_paid_trans_amount NUMBER;
  BEGIN
    IF v_prem_paid_oper_id IS NULL
    THEN
      raise_application_error(-20100
                             ,'Не найден шаблон операции "Страховая Премия Оплачена"');
    END IF;
    IF v_advance_pay_acc_id IS NULL
    THEN
      raise_application_error(-20100, 'Не найден счет  77.01.03');
    END IF;
  
    SELECT doc_status_ref_id
      INTO v_status_ref_id
      FROM (SELECT doc_status_ref_id
              FROM doc_status
             WHERE document_id = p_acc_id
             ORDER BY start_date DESC)
     WHERE rownum < 2;
  
    FOR trs IN (SELECT nvl(SUM(t.trans_amount), 0) trans_amount
                      ,nvl(SUM(t.acc_amount), 0) acc_amount
                      ,t.a5_ct_uro_id p_cover_id
                  FROM oper        o
                      ,trans       t
                      ,doc_set_off dsf
                 WHERE o.oper_id = t.oper_id
                   AND o.document_id = dsf.doc_set_off_id
                   AND dsf.parent_doc_id = p_acc_id
                   AND t.ct_account_id = v_advance_pay_acc_id
                 GROUP BY t.a5_ct_uro_id)
    LOOP
    
      SELECT nvl(SUM(t.trans_amount), 0) trans_amount
            ,nvl(SUM(t.acc_amount), 0) acc_amount
        INTO v_paid_trans_amount
            ,v_paid_acc_amount
        FROM oper  o
            ,trans t
       WHERE o.oper_id = t.oper_id
         AND o.document_id = p_acc_id
         AND t.ct_account_id = v_pay_acc_id
         AND t.a5_ct_uro_id = trs.p_cover_id;
    
      trs.acc_amount   := trs.acc_amount - v_paid_acc_amount;
      trs.trans_amount := trs.trans_amount - v_paid_trans_amount;
    
      --if trs.acc_amount<0 or trs.trans_amount<0 then
      --    raise_application_error(-20100,'Сумма операции "СтраховаяПремияОплачена" превышает сумму операции "СтраховаяПремияАвансОплачен" по покрытию p_cover_id='||trs.p_cover_id);
      --end if;
    
      IF trs.acc_amount <> 0
         AND trs.trans_amount = 0
      THEN
        raise_application_error(-20101
                               ,'Несоответствие сумм операции "СтраховаяПремияОплачена" по покрытию p_cover_id=' ||
                                trs.p_cover_id);
      END IF;
    
      IF trs.acc_amount > 0
         AND trs.trans_amount > 0
      THEN
        v_oper_id := acc_new.run_oper_by_template(v_prem_paid_oper_id
                                                 ,p_acc_id
                                                 ,v_cover_ent_id
                                                 ,trs.p_cover_id
                                                 ,v_status_ref_id
                                                 ,1
                                                 ,trs.acc_amount);
        UPDATE trans t SET t.trans_amount = trs.trans_amount WHERE t.oper_id = v_oper_id;
      END IF;
    END LOOP;
  END;

  PROCEDURE load_tmp
  (
    p_payment_type_id     NUMBER
   ,p_fund_brief_bill     VARCHAR2
   ,p_fund_brief_order    VARCHAR2
   ,p_fund_id_bill        NUMBER
   ,p_rev_fund_id         NUMBER
   ,p_rev_rate_type_brief VARCHAR2
   ,p_rev_rate_type_id    NUMBER
   ,p_rev_rate            NUMBER
   ,p_due_date            DATE
   ,p_flt_status          VARCHAR2
   ,p_payment_direct_id   NUMBER
   ,p_payment_id          NUMBER
   ,p_flt_contact_id      NUMBER
   ,p_flt_start_date      DATE
   ,p_flt_end_date        DATE
   ,p_flt_doc_num         VARCHAR2
   ,p_flt_notice_num      VARCHAR2
   ,p_flt_sum             NUMBER
   ,p_flt_index_sum       NUMBER
   ,p_flt_ids             VARCHAR2 DEFAULT NULL
  ) IS
    v_rate_type_id   NUMBER;
    v_native_fund_id NUMBER;
  BEGIN
    DELETE tmp_set_off;
  
    SELECT rt.rate_type_id INTO v_rate_type_id FROM rate_type rt WHERE rt.brief = 'ЦБ';
  
    SELECT f.fund_id INTO v_native_fund_id FROM fund f WHERE f.brief = 'RUR';
  
    -- Запрос состоит из 2-х частей. 1-я это документы из существующих зачетов(в том числе аннулированных),
    -- 2-я - документы с которыми будет проводиться зачет (0 is exists)
    INSERT INTO tmp_set_off
      SELECT *
        FROM (SELECT /*+ NO_MERGE (tt) */
               tt.document_id
              ,tt.doc_set_off_id
              ,tt.num
              ,tt.due_date
              ,tt.contact_name
              ,tt.doc_templ_brief
              ,tt.main_fund_brief
              ,tt.list_fund_brief
              ,tt.rate
              ,tt.is_exists
              ,tt.main_amount
              ,tt.list_amount
              ,tt.main_set_off_amount
              ,tt.list_set_off_amount
              ,tt.main_amount - tt.main_set_off_amount main_rest_amount
              ,tt.list_amount - tt.list_set_off_amount list_rest_amount
              ,tt.doc_amount
              ,doc.get_last_doc_status_name(tt.document_id)
              ,doc.get_last_doc_status_brief(tt.document_id)
              ,tt.cancel_date
              ,tt.cancel_flag
              ,tt.idx_sum
              ,tt.ph_ids
              ,tt.ph_pol_num
                FROM (SELECT t.filial_id
                            ,t.payment_id document_id
                            ,dso.doc_set_off_id doc_set_off_id
                            ,t.num num
                            ,t.due_date due_date
                            ,c.obj_name_orig contact_name
                            ,(SELECT ph.ids
                                FROM ins.p_policy     pol
                                    ,ins.p_pol_header ph
                                    ,ins.doc_doc      dd
                                    ,ins.ac_payment   ac --ЭПГ
                                    ,ins.doc_set_off  dso
                                    ,ins.ac_payment   dso_ac --ПД4
                                    ,ins.doc_doc      pd_dd
                                    ,ins.ac_payment   ac_copy --Копия
                               WHERE pol.pol_header_id = ph.policy_header_id
                                 AND pol.policy_id = dd.parent_id
                                 AND dd.child_id = ac.payment_id
                                 AND ac.payment_id = dso.parent_doc_id
                                 AND dso.child_doc_id = dso_ac.payment_id
                                 AND pd_dd.parent_id = dso_ac.payment_id
                                 AND pd_dd.child_id = ac_copy.payment_id
                                 AND ac_copy.payment_id = t.payment_id
                              UNION
                              SELECT ph.ids
                                FROM ins.p_policy     pol
                                    ,ins.p_pol_header ph
                                    ,ins.doc_doc      dd
                                    ,ins.ac_payment   ac --ЭПГ
                                    ,ins.doc_set_off  dso
                                    ,ins.ac_payment   dso_ac --ПД4
                               WHERE pol.pol_header_id = ph.policy_header_id
                                 AND pol.policy_id = dd.parent_id
                                 AND dd.child_id = ac.payment_id
                                 AND ac.payment_id = dso.parent_doc_id
                                 AND dso.child_doc_id = dso_ac.payment_id
                                 AND ac.payment_id = t.payment_id) ph_ids
                            ,(SELECT pol.pol_num
                                FROM ins.p_policy    pol
                                    ,ins.doc_doc     dd
                                    ,ins.ac_payment  ac --ЭПГ
                                    ,ins.doc_set_off dso
                                    ,ins.ac_payment  dso_ac --ПД4
                                    ,ins.doc_doc     pd_dd
                                    ,ins.ac_payment  ac_copy --Копия
                               WHERE pol.policy_id = dd.parent_id
                                 AND dd.child_id = ac.payment_id
                                 AND ac.payment_id = dso.parent_doc_id
                                 AND dso.child_doc_id = dso_ac.payment_id
                                 AND pd_dd.parent_id = dso_ac.payment_id
                                 AND pd_dd.child_id = ac_copy.payment_id
                                 AND ac_copy.payment_id = t.payment_id
                              UNION
                              SELECT pol.pol_num
                                FROM ins.p_policy    pol
                                    ,ins.doc_doc     dd
                                    ,ins.ac_payment  ac --ЭПГ
                                    ,ins.doc_set_off dso
                                    ,ins.ac_payment  dso_ac --ПД4
                               WHERE pol.policy_id = dd.parent_id
                                 AND dd.child_id = ac.payment_id
                                 AND ac.payment_id = dso.parent_doc_id
                                 AND dso.child_doc_id = dso_ac.payment_id
                                 AND ac.payment_id = t.payment_id) ph_pol_num
                            ,CASE
                               WHEN dt.brief LIKE '%SETOFF' THEN
                                'Взаим'
                               WHEN dt.brief = 'A7COPY' THEN
                                'А7 копия'
                               WHEN dt.brief = 'PD4COPY' THEN
                                'ПД4 копия'
                               ELSE
                                CASE
                                  WHEN (pt.payment_type_id = 1)
                                       AND (t.collection_metod_id = 1) THEN
                                   CASE
                                     WHEN dt.brief = 'A7' THEN
                                      'A7'
                                     ELSE
                                      'Касса'
                                   END
                                  WHEN (pt.payment_type_id = 1)
                                       AND (t.collection_metod_id = 2) THEN
                                   'Банк'
                                  WHEN (pt.payment_type_id = 0)
                                       AND (pt.payment_direct_id = 1) THEN
                                   'Счет'
                                  WHEN (pt.payment_type_id = 0)
                                       AND (pt.payment_direct_id = 0) THEN
                                   'Расп'
                                END
                             END doc_templ_brief
                            ,CASE
                               WHEN (p_payment_type_id = 0) THEN
                                p_fund_brief_bill
                               WHEN (p_payment_type_id = 1) THEN
                                p_fund_brief_order
                             END main_fund_brief
                            ,f.brief list_fund_brief
                            ,CASE
                               WHEN (p_payment_type_id = 0) THEN
                                dso.set_off_rate
                               WHEN (p_payment_type_id = 1) THEN
                                dso.set_off_rate
                             END rate
                            ,CASE
                               WHEN dso.cancel_date IS NULL THEN
                                1
                               ELSE
                                0
                             END is_exists
                            ,CASE
                               WHEN (p_payment_type_id = 0) THEN
                                ROUND((t.amount + t.comm_amount -
                                      pkg_payment.get_paym_set_off_amount(t.payment_id
                                                                          ,dso.doc_set_off_id)) /
                                      dso.set_off_rate * 100) / 100
                               WHEN (p_payment_type_id = 1) THEN
                                ROUND((t.amount + t.comm_amount -
                                      pkg_payment.get_bill_set_off_amount(t.payment_id
                                                                          ,dso.doc_set_off_id)) *
                                      dso.set_off_rate * 100) / 100
                             END main_amount
                            ,CASE
                               WHEN (p_payment_type_id = 0) THEN
                                t.amount + t.comm_amount -
                                pkg_payment.get_paym_set_off_amount(t.payment_id, dso.doc_set_off_id)
                               WHEN (p_payment_type_id = 1) THEN
                                t.amount + t.comm_amount -
                                pkg_payment.get_bill_set_off_amount(t.payment_id, dso.doc_set_off_id)
                             END list_amount
                            ,CASE
                               WHEN (dso.cancel_date IS NOT NULL) THEN
                                0
                               WHEN (p_payment_type_id = 0) THEN
                                dso.set_off_amount
                               WHEN (p_payment_type_id = 1) THEN
                                dso.set_off_child_amount
                             END main_set_off_amount
                            ,CASE
                               WHEN (dso.cancel_date IS NOT NULL) THEN
                                0
                               WHEN (p_payment_type_id = 0) THEN
                                dso.set_off_child_amount
                               WHEN (p_payment_type_id = 1) THEN
                                dso.set_off_amount
                             END list_set_off_amount
                            ,t.amount + t.comm_amount doc_amount
                            ,dso.cancel_date cancel_date
                            ,CASE
                               WHEN dso.cancel_date IS NULL THEN
                                0
                               ELSE
                                1
                             END cancel_flag
                            ,pkg_renlife_utils.get_idx_sum(t.payment_id) idx_sum
                        FROM ven_ac_payment      t
                            ,doc_templ           dt
                            ,contact             c
                            ,fund                f
                            ,doc_set_off         dso
                            ,ac_payment_templ    pt
                            ,t_collection_method cm
                            ,rate_type           rt
                       WHERE t.doc_templ_id = dt.doc_templ_id
                         AND dt.doc_templ_id = pt.doc_templ_id
                         AND t.collection_metod_id = cm.id
                         AND t.contact_id = c.contact_id
                         AND t.fund_id = f.fund_id
                         AND t.rev_rate_type_id = rt.rate_type_id(+)
                         AND ((p_flt_sum IS NULL) OR
                             (p_flt_sum IS NOT NULL AND p_flt_sum = t.amount + t.comm_amount))
                         AND ((ROUND(p_flt_index_sum, 2) IS NULL) OR
                             (ROUND(p_flt_index_sum, 2) IS NOT NULL AND
                             ROUND(p_flt_index_sum, 2) = pkg_renlife_utils.get_idx_sum(t.payment_id)))
                         AND ((p_payment_type_id = 0) AND (p_payment_direct_id = 1) AND
                             (pt.payment_type_id = 1) AND (pt.payment_direct_id = 0) OR
                             (p_payment_type_id = 0) AND (p_payment_direct_id = 0) AND
                             (pt.payment_type_id = 1) AND (pt.payment_direct_id = 1) OR
                             (p_payment_type_id = 1) AND (p_payment_direct_id = 0) AND
                             (pt.payment_type_id = 0) AND (pt.payment_direct_id = 1) OR
                             (p_payment_type_id = 1) AND (p_payment_direct_id = 1) AND
                             (pt.payment_type_id = 0) AND (pt.payment_direct_id = 0))
                         AND ((p_payment_type_id = 0) AND (dso.parent_doc_id = p_payment_id) AND
                             (dso.child_doc_id = t.payment_id) OR
                             (p_payment_type_id = 1) AND (dso.parent_doc_id = t.payment_id) AND
                             (dso.child_doc_id = p_payment_id))) tt
               WHERE (tt.filial_id IS NULL OR
                     tt.filial_id IN (SELECT column_value FROM v_org_tree_childs_table))
              UNION ALL
              SELECT /*+ NO_MERGE (tt) */
               tt.document_id
              ,tt.doc_set_off_id
              ,tt.num
              ,tt.due_date
              ,tt.contact_name
              ,tt.doc_templ_brief
              ,tt.main_fund_brief
              ,tt.list_fund_brief
              ,tt.rate
              ,tt.is_exists
              ,tt.main_amount
              ,tt.list_amount
              ,tt.main_set_off_amount
              ,tt.list_set_off_amount
              ,tt.main_amount - tt.main_set_off_amount main_rest_amount
              ,tt.list_amount - tt.list_set_off_amount list_rest_amount
              ,tt.doc_amount
              ,doc.get_last_doc_status_name(tt.document_id)
              ,doc.get_last_doc_status_brief(tt.document_id)
              ,NULL
              ,NULL
              ,tt.idx_sum
              ,tt.ph_ids
              ,tt.ph_pol_num
                FROM (SELECT /*+ NO_MERGE (t) */
                       t.filial_id
                      ,t.payment_id document_id
                      ,NULL doc_set_off_id
                      ,t.num num
                      ,t.due_date due_date
                      ,c.obj_name_orig contact_name
                      ,(SELECT ph.ids
                          FROM ins.doc_doc      dd
                              ,ins.p_policy     pol
                              ,ins.p_pol_header ph
                         WHERE dd.child_id = t.payment_id
                           AND dd.parent_id = pol.policy_id
                           AND pol.pol_header_id = ph.policy_header_id) ph_ids
                      ,(SELECT pol.pol_num
                          FROM ins.doc_doc  dd
                              ,ins.p_policy pol
                         WHERE dd.child_id = t.payment_id
                           AND dd.parent_id = pol.policy_id) ph_pol_num
                      ,CASE
                         WHEN dt.brief LIKE '%SETOFF' THEN
                          'Взаим'
                         WHEN dt.brief = 'A7COPY' THEN
                          'А7 копия'
                         WHEN dt.brief = 'PD4' THEN
                          'ПД4'
                         WHEN dt.brief = 'PD4COPY' THEN
                          'ПД4 копия'
                         ELSE
                          CASE
                            WHEN (pt.payment_type_id = 1)
                                 AND (t.collection_metod_id = 1) THEN
                             'Касса'
                            WHEN (pt.payment_type_id = 1)
                                 AND (t.collection_metod_id = 2) THEN
                             'Банк'
                            WHEN (pt.payment_type_id = 0)
                                 AND (pt.payment_direct_id = 1) THEN
                             'Счет'
                            WHEN (pt.payment_type_id = 0)
                                 AND (pt.payment_direct_id = 0) THEN
                             'Расп'
                          END
                       END doc_templ_brief
                      ,CASE
                         WHEN (p_payment_type_id = 0) THEN
                          p_fund_brief_bill
                         WHEN (p_payment_type_id = 1) THEN
                          p_fund_brief_order
                       END main_fund_brief
                      ,f.brief list_fund_brief
                      ,CASE
                         WHEN (p_payment_type_id = 0) THEN
                          CASE
                            WHEN p_fund_id_bill = p_rev_fund_id THEN
                             1.0
                            ELSE
                             CASE
                               WHEN p_rev_rate_type_brief = 'ФИКС' THEN
                                to_number(p_rev_rate)
                               ELSE
                                acc_new.get_rate_by_id(p_rev_rate_type_id, p_fund_id_bill, t.due_date)
                             END
                          END
                         WHEN (p_payment_type_id = 1) THEN
                          CASE
                            WHEN t.fund_id = t.rev_fund_id THEN
                             1.0
                            ELSE
                             CASE
                               WHEN rt.brief = 'ФИКС' THEN
                                t.rev_rate
                               ELSE
                                acc_new.get_rate_by_id(t.rev_rate_type_id, t.fund_id, p_due_date)
                             END
                          END
                       END rate
                      ,0 is_exists
                      ,CASE
                         WHEN (p_payment_type_id = 0) THEN
                          CASE
                            WHEN p_fund_id_bill = p_rev_fund_id THEN
                             t.amount + t.comm_amount - pkg_payment.get_paym_set_off_amount(t.payment_id, 0)
                            ELSE
                             CASE
                               WHEN p_fund_id_bill = v_native_fund_id THEN
                                ROUND((t.amount + t.comm_amount -
                                      pkg_payment.get_paym_set_off_amount(t.payment_id, 0)) * (CASE
                                        WHEN p_rev_rate_type_brief = 'ФИКС' THEN
                                         p_rev_rate
                                        ELSE
                                         acc_new.get_rate_by_id(p_rev_rate_type_id, p_rev_fund_id, t.due_date)
                                      END) * 100) / 100
                               ELSE
                                ROUND((t.amount + t.comm_amount -
                                      pkg_payment.get_paym_set_off_amount(t.payment_id, 0)) / (CASE
                                        WHEN p_rev_rate_type_brief = 'ФИКС' THEN
                                         p_rev_rate
                                        ELSE
                                         acc_new.get_rate_by_id(p_rev_rate_type_id, p_fund_id_bill, t.due_date)
                                      END) * 100) / 100
                             END
                          END
                         WHEN (p_payment_type_id = 1) THEN
                          CASE
                            WHEN t.fund_id = t.rev_fund_id THEN
                             t.amount + t.comm_amount - pkg_payment.get_bill_set_off_amount(t.payment_id, 0)
                            ELSE
                             CASE
                               WHEN t.fund_id = v_native_fund_id THEN
                                ROUND((t.amount + t.comm_amount -
                                      pkg_payment.get_bill_set_off_amount(t.payment_id, 0)) / (CASE
                                        WHEN rt.brief = 'ФИКС' THEN
                                         t.rev_rate
                                        ELSE
                                         acc_new.get_rate_by_id(t.rev_rate_type_id, t.rev_fund_id, p_due_date)
                                      END) * 100) / 100
                               ELSE
                                ROUND((t.amount + t.comm_amount -
                                      pkg_payment.get_bill_set_off_amount(t.payment_id, 0)) * (CASE
                                        WHEN rt.brief = 'ФИКС' THEN
                                         t.rev_rate
                                        ELSE
                                         acc_new.get_rate_by_id(t.rev_rate_type_id, t.fund_id, p_due_date)
                                      END) * 100) / 100
                             END
                          END
                       END main_amount
                      ,CASE
                         WHEN (p_payment_type_id = 0) THEN
                          t.amount + t.comm_amount - pkg_payment.get_paym_set_off_amount(t.payment_id, 0)
                         WHEN (p_payment_type_id = 1) THEN
                          t.amount + t.comm_amount - pkg_payment.get_bill_set_off_amount(t.payment_id, 0)
                       END list_amount
                      ,0 main_set_off_amount
                      ,0 list_set_off_amount
                      ,t.amount + t.comm_amount doc_amount
                      ,pkg_renlife_utils.get_idx_sum(t.payment_id) idx_sum
                        FROM (WITH ppp AS (SELECT pol2.*
                                             FROM p_policy pol2
                                            WHERE pol2.pol_header_id IN
                                                  (SELECT pol1.pol_header_id
                                                     FROM p_policy pol1
                                                    WHERE (p_flt_doc_num IS NOT NULL OR
                                                          p_flt_notice_num IS NOT NULL OR
                                                          p_flt_ids IS NOT NULL)
                                                      AND (p_flt_doc_num IS NULL OR
                                                          pol1.pol_num = p_flt_doc_num)
                                                      AND (p_flt_notice_num IS NULL OR
                                                          pol1.notice_num LIKE p_flt_notice_num || '%')
                                                      AND (p_flt_ids IS NULL OR
                                                          pol1.pol_header_id =
                                                          (SELECT ph.policy_header_id
                                                              FROM p_pol_header ph
                                                             WHERE ph.ids = p_flt_ids))))
                               SELECT *
                                 FROM (SELECT *
                                         FROM ven_ac_payment acp
                                        WHERE acp.payment_id IN
                                              (SELECT dd.child_id
                                                 FROM doc_doc dd
                                                     ,ppp     pol2
                                                WHERE dd.parent_id = pol2.policy_id)
                                       UNION
                                       SELECT *
                                         FROM ven_ac_payment acp
                                        WHERE acp.payment_id IN
                                              (SELECT a7_a7c.child_id
                                                 FROM doc_doc     a7_a7c
                                                     ,doc_set_off acc_a7
                                                     ,doc_doc     pol_acc
                                                     ,ppp         p1
                                                WHERE acc_a7.child_doc_id = a7_a7c.parent_id
                                                  AND pol_acc.parent_id = p1.policy_id
                                                  AND pol_acc.child_id = acc_a7.parent_doc_id
                                                  AND doc.get_doc_templ_brief(a7_a7c.child_id) IN
                                                      ('A7COPY', 'PD4COPY'))
                                       UNION
                                       SELECT *
                                         FROM ven_ac_payment acp
                                        WHERE p_flt_doc_num IS NULL
                                          AND p_flt_notice_num IS NULL
                                          AND p_flt_ids IS NULL) acp
                                WHERE (p_flt_status IS NULL OR
                                      doc.get_last_doc_status_name(acp.payment_id) LIKE p_flt_status)
                                  AND (p_flt_contact_id IS NULL OR
                                      p_flt_contact_id IS NOT NULL AND p_flt_contact_id = acp.contact_id)
                                  AND (p_flt_start_date IS NULL OR
                                      p_flt_start_date IS NOT NULL AND p_flt_start_date <= acp.due_date)
                                  AND (p_flt_sum IS NULL OR
                                      p_flt_sum IS NOT NULL AND p_flt_sum = acp.amount + acp.comm_amount)
                                  AND (ROUND(p_flt_index_sum, 2) IS NULL OR
                                      ROUND(p_flt_index_sum, 2) =
                                      pkg_renlife_utils.get_idx_sum(acp.payment_id))
                                  AND (p_flt_end_date IS NULL OR p_flt_end_date >= acp.due_date)) t, doc_templ dt, contact c, fund f, ac_payment_templ pt, t_collection_method cm, rate_type rt
                                WHERE (doc.get_last_doc_status_brief(t.payment_id) IN
                                      ('TO_PAY', 'PAID', 'TRANS') OR dt.brief = 'PAYMENT')
                                  AND t.doc_templ_id = dt.doc_templ_id
                                  AND dt.doc_templ_id = pt.doc_templ_id
                                  AND t.collection_metod_id = cm.id
                                  AND t.contact_id = c.contact_id
                                  AND t.fund_id = f.fund_id
                                  AND t.rev_rate_type_id = rt.rate_type_id(+)
                                  AND ((p_payment_type_id = 0) AND (p_payment_direct_id = 1) AND
                                      (pt.payment_type_id = 1) AND (pt.payment_direct_id = 0) OR
                                      (p_payment_type_id = 0) AND (p_payment_direct_id = 0) AND
                                      (pt.payment_type_id = 1) AND (pt.payment_direct_id = 1) OR
                                      (p_payment_type_id = 1) AND (p_payment_direct_id = 0) AND
                                      (pt.payment_type_id = 0) AND (pt.payment_direct_id = 1) OR
                                      (p_payment_type_id = 1) AND (p_payment_direct_id = 1) AND
                                      (pt.payment_type_id = 0) AND (pt.payment_direct_id = 0))
                                  AND (NOT EXISTS (SELECT *
                                                     FROM doc_set_off dso
                                                    WHERE (p_payment_type_id = 0)
                                                      AND (dso.parent_doc_id = p_payment_id)
                                                      AND (dso.child_doc_id = t.payment_id)))
                                  AND (NOT EXISTS (SELECT *
                                                     FROM doc_set_off dso
                                                    WHERE (p_payment_type_id = 1)
                                                      AND (dso.parent_doc_id = t.payment_id)
                                                      AND (dso.child_doc_id = p_payment_id)))
                      ) tt
               WHERE tt.list_amount > 0
                 AND (tt.filial_id IS NULL OR
                     tt.filial_id IN (SELECT column_value FROM v_org_tree_childs_table)));
  END load_tmp;

  PROCEDURE annulate_payment(p_doc_id NUMBER) IS
  BEGIN
    IF nvl(pkg_payment.get_set_off_amount(p_doc_id, NULL, NULL), 0) != 0
    THEN
      raise_application_error(-20100
                             ,'Нельзя аннулировать счет, по которому был проведен зачет');
    END IF;
  END;

  PROCEDURE check_policy_status(p_id NUMBER) IS
  
    v_brief VARCHAR2(50);
    v_id    NUMBER;
  
  BEGIN
    SELECT dt.brief
          ,d2.document_id
      INTO v_brief
          ,v_id
      FROM document  d1
          ,doc_templ dt
          ,doc_doc   dd
          ,document  d2
     WHERE d1.doc_templ_id = dt.doc_templ_id
       AND dd.child_id = d1.document_id
       AND d2.document_id = dd.parent_id
       AND d1.document_id = p_id;
    --если этот запрос вернет ошибку, то это нормально - проверка не прошла
  
    IF doc.get_last_doc_status_brief(v_id) = 'PROJECT'
    THEN
      raise_application_error(-20000
                             ,'Документ-основание находится в статусе проект');
    END IF;
  
    --тут будет нормальное завершение проверки
  
  END;

  PROCEDURE get_uncharge_acc_amount
  (
    p_policy_id      NUMBER
   ,p_ac_payment_id  NUMBER
   ,p_doc_set_off_id NUMBER
   ,p_amount         OUT NUMBER
   ,p_fund_id        OUT NUMBER
  ) IS
  BEGIN
    FOR rec IN (SELECT (dd.child_amount -
                       nvl(SUM(ds.set_off_amount) over(PARTITION BY ds.parent_doc_id), 0)) amount
                      ,ap.fund_id fund_id
                  FROM doc_doc dd
                      ,(SELECT * FROM doc_set_off s WHERE s.doc_set_off_id <> p_doc_set_off_id) ds
                      ,ac_payment ap
                 WHERE dd.child_id = p_ac_payment_id
                   AND dd.parent_id = p_policy_id
                   AND ap.payment_id = p_ac_payment_id
                   AND ap.payment_id = ds.parent_doc_id(+))
    LOOP
      p_amount  := rec.amount;
      p_fund_id := rec.fund_id;
    END LOOP;
  
  END;

  PROCEDURE get_uncharge_set_off_amount
  (
    p_ac_payment_id  NUMBER
   ,p_doc_set_off_id NUMBER
   ,p_amount         OUT NUMBER
   ,p_fund_id        OUT NUMBER
  ) IS
  BEGIN
    FOR rec IN (SELECT (ap.amount -
                       nvl(SUM(ds.set_off_child_amount) over(PARTITION BY ap.payment_id), 0)) amount
                      ,ap.fund_id fund_id
                  FROM (SELECT * FROM doc_set_off s WHERE s.doc_set_off_id <> p_doc_set_off_id) ds
                      ,ac_payment ap
                 WHERE ap.payment_id = p_ac_payment_id
                   AND ap.payment_id = ds.child_doc_id(+))
    LOOP
      p_amount  := rec.amount;
      p_fund_id := rec.fund_id;
    END LOOP;
  
  END;

  PROCEDURE check_payment_sum(p_payment_id NUMBER) IS
    v_plan_date      DATE;
    v_pol_id         NUMBER;
    v_cover_sum      NUMBER;
    v_adm            NUMBER;
    v_sch_sum        NUMBER;
    v_payment_setoff NUMBER;
  BEGIN
    BEGIN
      SELECT acp.plan_date
            ,p.policy_id
            ,CASE MOD(MONTHS_BETWEEN(acp.plan_date, p.first_pay_date), 12)
               WHEN 0 THEN
                1
               ELSE
                0
             END adm_cost
        INTO v_plan_date
            ,v_pol_id
            ,v_adm
        FROM ven_ac_payment acp
            ,doc_templ      dt
            ,doc_doc        dd
            ,p_policy       p
       WHERE acp.payment_id = p_payment_id
         AND dt.doc_templ_id = acp.doc_templ_id
         AND dt.brief = 'PAYMENT'
         AND dd.child_id = acp.payment_id
         AND p.policy_id = dd.parent_id;
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20010, 'Текущий счет на оплату не найден');
    END;
    BEGIN
      SELECT nvl(SUM(dd.child_amount), 0)
        INTO v_sch_sum
        FROM ven_ac_payment ac
            ,doc_doc        dd
            ,doc_templ      dt
       WHERE doc.get_last_doc_status_brief(ac.payment_id) <> 'ANNULATED'
         AND ac.payment_id = dd.child_id
         AND ac.plan_date = v_plan_date
         AND dd.parent_id = v_pol_id
         AND dt.doc_templ_id = ac.doc_templ_id
         AND dt.brief = 'PAYMENT';
    EXCEPTION
      WHEN no_data_found THEN
        v_sch_sum := 0;
    END;
    BEGIN
      SELECT nvl(SUM(dd.child_amount), 0)
        INTO v_payment_setoff
        FROM ven_ac_payment ac
            ,doc_doc        dd
            ,doc_templ      dt
       WHERE doc.get_last_doc_status_brief(ac.payment_id) <> 'ANNULATED'
         AND ac.payment_id = dd.child_id
         AND ac.plan_date = v_plan_date
         AND dd.parent_id = v_pol_id
         AND dt.doc_templ_id = ac.doc_templ_id
         AND dt.brief = 'PAYMENT_SETOFF_ACC';
    EXCEPTION
      WHEN no_data_found THEN
        v_payment_setoff := 0;
    END;
    BEGIN
      SELECT nvl(SUM(pc.fee), 0)
        INTO v_cover_sum
        FROM p_cover            pc
            ,as_asset           a
            ,t_prod_line_option plo
            ,t_product_line     pl
       WHERE a.p_policy_id = v_pol_id
         AND pc.as_asset_id = a.as_asset_id
         AND plo.id = pc.t_prod_line_option_id
         AND pl.id = plo.product_line_id
         AND a.status_hist_id <> pkg_asset.status_hist_id_del
         AND pc.status_hist_id <> pkg_cover.status_hist_id_del
         AND v_plan_date BETWEEN pc.start_date AND pc.end_date
         AND (v_adm = 1 OR upper(nvl(pl.brief, '?')) != 'ADMIN_EXPENCES');
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20020
                               ,'По версии полиса не найдены действующие покрытия');
    END;
    IF (nvl(v_sch_sum, 0) - nvl(v_payment_setoff, 0)) > v_cover_sum
    THEN
      raise_application_error(-20030
                             ,'Сумма счетов на ' || v_plan_date ||
                              ' превышает сумму взносов по договору');
    END IF;
  END;

BEGIN

  BEGIN
    SELECT a.account_id INTO v_contact_acc_id FROM account a WHERE a.num = '77.01.01';
  EXCEPTION
    WHEN no_data_found THEN
      NULL;
  END;

  BEGIN
    SELECT a.account_id INTO v_charge_acc_id FROM account a WHERE a.num = '92.01';
  EXCEPTION
    WHEN no_data_found THEN
      NULL;
  END;

  BEGIN
    SELECT a.account_id INTO v_repay_charge_acc_id FROM account a WHERE a.num = '77.08.01';
  EXCEPTION
    WHEN no_data_found THEN
      NULL;
  END;

  BEGIN
    SELECT a.account_id INTO v_ret_acc_id FROM account a WHERE a.num = '77.08.02';
  EXCEPTION
    WHEN no_data_found THEN
      NULL;
  END;

  BEGIN
    SELECT a.account_id INTO v_pay_acc_id FROM account a WHERE a.num = '77.01.02';
  EXCEPTION
    WHEN no_data_found THEN
      NULL;
  END;

  BEGIN
    SELECT a.account_id INTO v_advance_pay_acc_id FROM account a WHERE a.num = '77.01.03';
  EXCEPTION
    WHEN no_data_found THEN
      NULL;
  END;

  BEGIN
    SELECT a.account_id INTO v_ag_com_acc_id FROM account a WHERE a.num = '77.07.01';
  EXCEPTION
    WHEN no_data_found THEN
      NULL;
  END;

  BEGIN
    SELECT a.account_id INTO v_ag_acc_id FROM account a WHERE a.num = '77.05.02';
  EXCEPTION
    WHEN no_data_found THEN
      NULL;
  END;

  BEGIN
    SELECT ot.oper_templ_id
      INTO v_charge_oper_templ_id
      FROM oper_templ ot
     WHERE ot.brief = 'НачПремияНеЖизнь';
  EXCEPTION
    WHEN no_data_found THEN
      NULL;
  END;

  BEGIN
    SELECT ot.oper_templ_id
      INTO v_repay_charge_oper_templ_id
      FROM oper_templ ot
     WHERE ot.brief = 'НачВозврат';
  EXCEPTION
    WHEN no_data_found THEN
      NULL;
  END;

  BEGIN
    SELECT ot.oper_templ_id
      INTO v_surr_charge_oper_templ_id
      FROM oper_templ ot
     WHERE ot.brief = 'НачВозвратВыкСум';
  EXCEPTION
    WHEN no_data_found THEN
      NULL;
  END;

  BEGIN
    SELECT ot.oper_templ_id
      INTO v_msfo_charge_oper_id
      FROM oper_templ ot
     WHERE ot.brief = 'МСФОПремияНачисленаДог';
  EXCEPTION
    WHEN no_data_found THEN
      NULL;
  END;

  BEGIN
    SELECT ot.oper_templ_id
      INTO v_msfo_comm_oper_id
      FROM oper_templ ot
     WHERE ot.brief = 'МСФОВознаграждениеНачисленоДог';
  EXCEPTION
    WHEN no_data_found THEN
      NULL;
  END;

  BEGIN
    SELECT ot.oper_templ_id
      INTO v_msfo_ape_oper_id
      FROM oper_templ ot
     WHERE ot.brief = 'МСФОПремияНачисленаAPE';
  EXCEPTION
    WHEN no_data_found THEN
      NULL;
  END;

  BEGIN
    SELECT ot.oper_templ_id
      INTO v_prem_to_pay_plan_oper_id
      FROM oper_templ ot
     WHERE ot.brief = 'ПремияНачисленаКОплатеПлан';
  EXCEPTION
    WHEN no_data_found THEN
      NULL;
  END;

  BEGIN
    SELECT ot.oper_templ_id
      INTO v_prem_paid_oper_id
      FROM oper_templ ot
     WHERE ot.brief = 'СтраховаяПремияОплачена';
  EXCEPTION
    WHEN no_data_found THEN
      NULL;
  END;

  BEGIN
    SELECT ot.oper_templ_id
      INTO v_vzch_oper_id
      FROM oper_templ ot
     WHERE ot.brief = 'ВозврПремВыплВзаим';
  EXCEPTION
    WHEN no_data_found THEN
      NULL;
  END;

  BEGIN
    SELECT ot.oper_templ_id
      INTO v_rsbu_stnachprem_templ_id
      FROM oper_templ ot
     WHERE ot.brief = 'Storno.NachPrem';
  EXCEPTION
    WHEN no_data_found THEN
      NULL;
  END;

  BEGIN
    SELECT ot.oper_templ_id
      INTO v_surr_charge_oper_fo_templ_id
      FROM oper_templ ot
     WHERE ot.brief = 'НачВыкСуммаФинКан';
  EXCEPTION
    WHEN no_data_found THEN
      NULL;
  END;

END;
/

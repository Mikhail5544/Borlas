CREATE OR REPLACE PACKAGE acc_new IS

  /**
  * Работа с бухгалтерским ядром - создание проводок, операций, работа со счетами, аналитиками, получение оборотов и остатков
  * @author Sergeev D.
  * @version 1
  */

  --Структура остатков и оборотов по счету
  TYPE t_turn_rest IS RECORD(
     rest_in_fund            NUMBER
    , --сумма входящего остатка в запрашиваемой валюте
    rest_in_base_fund       NUMBER
    , --сумма входящего остатка в базовой валюте
    rest_in_qty             NUMBER
    , --сумма входящего остатка в количественном учете
    rest_in_fund_type       VARCHAR2(1)
    , --тип (Д/К) входящего остатка в запрашиваемой валюте
    rest_in_base_fund_type  VARCHAR2(1)
    , --тип (Д/К) входящего остатка в базовой валюте
    rest_in_qty_type        VARCHAR2(1)
    , --тип (Д/К) входящего остатка в количественном учете
    turn_dt_fund            NUMBER
    , --оборот по дебету в запрашиваемой валюте
    turn_dt_base_fund       NUMBER
    , --оборот по дебету в базовой валюте
    turn_dt_qty             NUMBER
    , --оборот по дебету в количественном учете
    turn_ct_fund            NUMBER
    , --оборот по кредиту в запрашиваемой валюте
    turn_ct_base_fund       NUMBER
    , --оборот по кредиту в базовой валюте
    turn_ct_qty             NUMBER
    , --оборот по кредиту в количественном учете
    rest_out_fund           NUMBER
    , --сумма исходящего остатка в запрашиваемой валюте
    rest_out_base_fund      NUMBER
    , --сумма исходящего остатка в базовой валюте
    rest_out_qty            NUMBER
    , --сумма исходящего остатка в количественном учете
    rest_out_fund_type      VARCHAR2(1)
    , --тип (Д/К) исходящего остатка в запрашиваемой валюте
    rest_out_base_fund_type VARCHAR2(1)
    , --тип (Д/К) исходящего остатка в базовой валюте
    rest_out_qty_type       VARCHAR2(1)) --тип (Д/К) исходящего остатка в количественном учете
  ;

  --Структура остатков по счету
  TYPE t_rest IS RECORD(
     rest_amount_fund      NUMBER
    , --сумма остатка в запрашиваемой валюте
    rest_amount_base_fund NUMBER
    , --сумма остатка в базовой валюте
    rest_amount_qty       NUMBER
    , --сумма остатка в количественном учете
    rest_fund_type        VARCHAR2(1)
    , --тип (Д/К) остатка в запрашиваемой валюте
    rest_base_fund_type   VARCHAR2(1)
    , --тип (Д/К) остатка в базовой валюте
    rest_qty_type         VARCHAR2(1)) --тип (Д/К) остатка в количественном учете
  ;

  --Структура универсальной ссылки
  TYPE t_uref_id IS RECORD(
     entity_id NUMBER(6)
    , --ИД сущности
    object_id NUMBER) --ИД объекта
  ;

  --ИД сущности документа
  doc_ent_id NUMBER;

  TYPE t_cursor_trans IS REF CURSOR RETURN trans%ROWTYPE;

  /**
  * Получить текст запроса для выбора списка значений атрибута
  * @author Sergeev D.
  * @param p_attr Строка таблицы attr - описание атрибута
  * @return Текст запроса со значениями атрибута
  * @throw Возвращает сообщение об ошибке в результате проверки
  */
  FUNCTION get_sql(p_attr attr%ROWTYPE) RETURN VARCHAR2;

  /**
  * Получить объект аналитики по типу аналитики исходного объекта
  * @author Sergeev D.
  * @param p_ent_id ИД сущности исходного объекта
  * @param p_obj_id ИД исходного объекта
  * @param p_an_type ИД типа аналитики
  * @return ИД объекта по типу аналитики
  */
  FUNCTION get_an_type
  (
    p_ent_id  IN NUMBER
   ,p_obj_id  IN NUMBER
   ,p_an_type IN NUMBER
  ) RETURN NUMBER;

  /**
  * Получить дату по типу даты исходного объекта
  * @author Sergeev D.
  * @param p_ent_id ИД сущности исходного объекта
  * @param p_obj_id ИД исходного объекта
  * @param p_date_type ИД типа даты
  * @return Дата по типу даты
  */
  FUNCTION get_date_type
  (
    p_ent_id    IN NUMBER
   ,p_obj_id    IN NUMBER
   ,p_date_type IN NUMBER
  ) RETURN DATE;

  /**
  * Получить валюту по типу валюты исходного объекта
  * @author Sergeev D.
  * @param p_ent_id ИД сущности исходного объекта
  * @param p_obj_id ИД исходного объекта
  * @param p_fund_type ИД типа валюты
  * @return ИД валюты по типу валюты
  */
  FUNCTION get_fund_type
  (
    p_ent_id    IN NUMBER
   ,p_obj_id    IN NUMBER
   ,p_fund_type IN NUMBER
  ) RETURN NUMBER;

  /**
  * Получить сумму по типу суммы исходного объекта
  * @author Sergeev D.
  * @param p_ent_id ИД сущности исходного объекта
  * @param p_obj_id ИД исходного объекта
  * @param p_summ_type ИД типа суммы
  * @return Значение суммы по типу суммы
  */
  FUNCTION get_summ_type
  (
    p_ent_id    IN NUMBER
   ,p_obj_id    IN NUMBER
   ,p_summ_type IN NUMBER
  ) RETURN NUMBER;

  /**
  * Получить ИД счета по исходному объекту, документу, валюте, дате и ИД механизма определения счета
  * @author Sergeev D.
  * @param p_ADR_id ИД механизма определения счета
  * @param p_Entity_id ИД сущности исходного объекта
  * @param p_Object_id ИД исходного объекта
  * @param p_Fund_id ИД валюты
  * @param p_Date Дата
  * @param p_Doc_id ИД исходного документа
  * @return ИД счета
  * @throw ИД счета = 0
  */
  FUNCTION get_acc_by_acc_def_rule
  (
    p_adr_id    NUMBER
   ,p_entity_id NUMBER
   ,p_object_id NUMBER
   ,p_fund_id   NUMBER
   ,p_date      DATE
   ,p_doc_id    IN NUMBER DEFAULT NULL
  ) RETURN NUMBER;

  /**
  * Получить ИД счета по типу счета, плану счетов, схеме расчетов и исходному документу
  * @author Sergeev D.
  * @param p_Acc_Type_Templ_ID ИД типа счета
  * @param p_Acc_Chart_Type_ID ИД плана счетов
  * @param p_Settlement_Scheme_ID ИД схемы расчетов
  * @param p_Doc_ID ИД исходного документа
  * @return ИД счета
  */
  FUNCTION get_acc_by_acc_type
  (
    p_acc_type_templ_id    NUMBER
   ,p_acc_chart_type_id    NUMBER
   ,p_settlement_scheme_id NUMBER
   ,p_doc_id               NUMBER
  ) RETURN NUMBER;

  /**
  * Получить значение приоритета счета по типу счета, плану счетов, схеме расчетов и исходному документу
  * @author Sergeev D.
  * @param p_Acc_Type_Templ_ID ИД типа счета
  * @param p_Acc_Chart_Type_ID ИД плана счетов
  * @param p_Settlement_Scheme_ID ИД схемы расчетов
  * @param p_Doc_ID ИД исходного документа
  * @return Значение приоритета счета
  */
  FUNCTION get_acc_priority_by_acc_type
  (
    p_acc_type_templ_id    NUMBER
   ,p_acc_chart_type_id    NUMBER
   ,p_settlement_scheme_id NUMBER
   ,p_doc_id               NUMBER
  ) RETURN NUMBER;

  /**
  * Получить значение примечания к проводке по шаблону проводки и текущей операции
  * @author Sergeev D.
  * @param p_Trans_Templ_ID ИД шаблона проводки
  * @param p_Oper_ID ИД текущей операции
  * @return Значение примечания к проводке
  */
  FUNCTION get_trans_note
  (
    p_trans_templ_id NUMBER
   ,p_oper_id        NUMBER
  ) RETURN VARCHAR2;

  /**
  * Получить ИД счета по механизму определения счета "Счет в валюте"
  * @author Sergeev D.
  * @param p_Entity_id ИД сущности исходного объекта
  * @param p_Object_id ИД исходного объекта
  * @param p_Fund_id ИД валюты
  * @param p_Date Дата
  * @param p_Doc_id ИД исходного документа
  * @return ИД счета
  */
  FUNCTION acc_by_fund
  (
    p_entity_id NUMBER
   ,p_object_id NUMBER
   ,p_fund_id   NUMBER
   ,p_date      DATE
   ,p_doc_id    IN NUMBER DEFAULT NULL
  ) RETURN NUMBER;

  /**
  * Получить ИД счета по механизму определения счета "Счет дебет во внутреннем документе"
  * @author Sergeev D.
  * @param p_Entity_id ИД сущности исходного объекта
  * @param p_Object_id ИД исходного объекта
  * @param p_Fund_id ИД валюты
  * @param p_Date Дата
  * @param p_Doc_id ИД исходного документа
  * @return ИД счета
  */
  FUNCTION acc_dt_mo
  (
    p_entity_id NUMBER
   ,p_object_id NUMBER
   ,p_fund_id   NUMBER
   ,p_date      DATE
   ,p_doc_id    IN NUMBER DEFAULT NULL
  ) RETURN NUMBER;

  /**
  * Получить ИД счета по механизму определения счета "Счет дебет (приведенный) во внутреннем документе"
  * @author Sergeev D.
  * @param p_Entity_id ИД сущности исходного объекта
  * @param p_Object_id ИД исходного объекта
  * @param p_Fund_id ИД валюты
  * @param p_Date Дата
  * @param p_Doc_id ИД исходного документа
  * @return ИД счета
  */
  FUNCTION acc_dt_mo_rev
  (
    p_entity_id NUMBER
   ,p_object_id NUMBER
   ,p_fund_id   NUMBER
   ,p_date      DATE
   ,p_doc_id    IN NUMBER DEFAULT NULL
  ) RETURN NUMBER;

  /**
  * Получить ИД счета по механизму определения счета "Счет кредит во внутреннем документе"
  * @author Sergeev D.
  * @param p_Entity_id ИД сущности исходного объекта
  * @param p_Object_id ИД исходного объекта
  * @param p_Fund_id ИД валюты
  * @param p_Date Дата
  * @param p_Doc_id ИД исходного документа
  * @return ИД счета
  */
  FUNCTION acc_ct_mo
  (
    p_entity_id NUMBER
   ,p_object_id NUMBER
   ,p_fund_id   NUMBER
   ,p_date      DATE
   ,p_doc_id    IN NUMBER DEFAULT NULL
  ) RETURN NUMBER;

  /**
  * Получить ИД счета по механизму определения счета "Счет кредит (приведенный) во внутреннем документе"
  * @author Sergeev D.
  * @param p_Entity_id ИД сущности исходного объекта
  * @param p_Object_id ИД исходного объекта
  * @param p_Fund_id ИД валюты
  * @param p_Date Дата
  * @param p_Doc_id ИД исходного документа
  * @return ИД счета
  */
  FUNCTION acc_ct_mo_rev
  (
    p_entity_id NUMBER
   ,p_object_id NUMBER
   ,p_fund_id   NUMBER
   ,p_date      DATE
   ,p_doc_id    IN NUMBER DEFAULT NULL
  ) RETURN NUMBER;

  /**
  * Получить ИД счета по механизму определения счета "Счет расчетов с контрагентом по договору страхования"
  * @author Sergeev D.
  * @param p_Entity_id ИД сущности исходного объекта
  * @param p_Object_id ИД исходного объекта
  * @param p_Fund_id ИД валюты
  * @param p_Date Дата
  * @param p_Doc_id ИД исходного документа
  * @return ИД счета
  */
  FUNCTION acc_policy_ctr
  (
    p_entity_id NUMBER
   ,p_object_id NUMBER
   ,p_fund_id   NUMBER
   ,p_date      DATE
   ,p_doc_id    IN NUMBER DEFAULT NULL
  ) RETURN NUMBER;

  /**
  * Получить ИД счета по механизму определения счета "Счет расчетов с сервисной организацией"
  * @author Sergeev D.
  * @param p_Entity_id ИД сущности исходного объекта
  * @param p_Object_id ИД исходного объекта
  * @param p_Fund_id ИД валюты
  * @param p_Date Дата
  * @param p_Doc_id ИД исходного документа
  * @return ИД счета
  */
  FUNCTION acc_contract_ctr
  (
    p_entity_id NUMBER
   ,p_object_id NUMBER
   ,p_fund_id   NUMBER
   ,p_date      DATE
   ,p_doc_id    IN NUMBER DEFAULT NULL
  ) RETURN NUMBER;

  /**
  * Создать бухгалтерскую проводку по шаблону и получить ИД проводки
  * @author Sergeev D.
  * @param p_Trans_Templ_ID ИД шаблона проводки
  * @param p_Oper_ID ИД текущей операции
  * @param p_service_ent_id ИД сущности объекта учета
  * @param p_service_obj_id ИД объекта учета
  * @param p_is_accepted признак проведена/не проведена
  * @param p_date Дата проводки
  * @param p_summ Сумма проводки
  * @param p_qty Количество проводки
  * @param p_Source Наименование источника формирования проводки
  * @return ИД проводки
  * @throw Возвращает сообщение об ошибке в результате проверки
  */
  FUNCTION add_trans_by_template
  (
    p_trans_templ_id      NUMBER
   ,p_oper_id             NUMBER
   ,p_service_ent_id      NUMBER
   ,p_service_obj_id      NUMBER
   ,p_is_accepted         NUMBER DEFAULT 1
   ,p_date                DATE DEFAULT NULL
   ,p_summ                NUMBER DEFAULT NULL
   ,p_qty                 NUMBER DEFAULT NULL
   ,p_source              VARCHAR2 DEFAULT 'INS'
   ,p_templ_date_investor NUMBER DEFAULT NULL
  ) RETURN NUMBER;

  /**
  * Создать операцию по шаблону и получить ИД операции
  * @author Sergeev D.
  * @param p_Oper_Templ_ID ИД шаблона операции
  * @param p_Document_ID ИД текущего документа
  * @param p_service_ent_id ИД сущности объекта учета
  * @param p_service_obj_id ИД объекта учета
  * @param p_Doc_Status_Ref_ID ИД типа статуса документа
  * @param p_is_accepted Признак проведена/не проведена
  * @param p_summ Сумма операции
  * @param p_Source Наименование источника формирования операции
  * @return ИД операции
  * @throw Возвращает сообщение об ошибке в результате проверки
  */
  FUNCTION run_oper_by_template
  (
    p_oper_templ_id       NUMBER
   ,p_document_id         NUMBER
   ,p_service_ent_id      NUMBER DEFAULT NULL
   ,p_service_obj_id      NUMBER DEFAULT NULL
   ,p_doc_status_ref_id   NUMBER DEFAULT NULL
   ,p_is_accepted         NUMBER DEFAULT 1
   ,p_summ                NUMBER DEFAULT NULL
   ,p_source              VARCHAR2 DEFAULT 'INS'
   ,p_templ_date_investor NUMBER DEFAULT NULL
  ) RETURN NUMBER;

  /**
  * Получить курс валюты к валюте по-умолчанию по ИД типа курса и ИД валюты на дату
  * @author Sergeev D.
  * @param p_Rate_Type_ID ИД типа курса
  * @param p_Fund_ID ИД валюты
  * @param p_Date Дата
  * @return Значение курса валюты
  * @throw Значение курса = 0
  */
  FUNCTION get_rate_by_id
  (
    p_rate_type_id NUMBER
   ,p_fund_id      NUMBER
   ,p_date         DATE
  ) RETURN NUMBER;

  /**
  * Получить курс валюты к валюте по-умолчанию по сокращению типа курса и сокращению валюты на дату
  * @author Sergeev D.
  * @param p_Rate_Type_Brief Сокращение типа курса
  * @param p_Fund_Brief Сокращение валюты
  * @param p_Date Дата
  * @return Значение курса валюты
  * @throw Значение курса = 0
  */
  FUNCTION get_rate_by_brief
  (
    p_rate_type_brief VARCHAR2
   ,p_fund_brief      VARCHAR2
   ,p_date            DATE
  ) RETURN NUMBER;

  /**
  * Получить в выходные параметры ИД сущности аналитики и ИД объекта аналитики по счету и объекту
  * @author Sergeev D.
  * @param p_Account_ID ИД счета
  * @param p_An_Num Порядковый номер аналитики
  * @param p_service_ent_ID ИД сущности объекта учета
  * @param p_service_obj_id ИД объекта учета
  * @param p_an_ent_id ИД сущности объекта по аналитике
  * @param p_an_obj_id ИД объекта по аналитике
  */
  PROCEDURE get_analytic
  (
    p_account_id     IN NUMBER
   ,p_an_num         IN NUMBER
   ,p_service_ent_id IN NUMBER
   ,p_service_obj_id IN NUMBER
   ,p_an_ent_id      OUT NUMBER
   ,p_an_obj_id      OUT NUMBER
  );

  /**
  * Получить ИД сущности аналитики по счету
  * @author Sergeev D.
  * @param p_Account_ID ИД счета
  * @param p_An_Num Порядковый номер аналитики
  * @return ИД сущности аналитики
  */
  FUNCTION get_analytic_entity_id
  (
    p_account_id NUMBER
   ,p_an_num     NUMBER
  ) RETURN NUMBER;

  /**
  * Получить ИД объекта аналитики по счету
  * @author Sergeev D.
  * @param p_Account_ID ИД счета
  * @param p_An_Num Порядковый номер аналитики
  * @return ИД объекта аналитики
  */
  FUNCTION get_analytic_object_id
  (
    p_account_id     NUMBER
   ,p_an_num         NUMBER
   ,p_service_ent_id NUMBER
   ,p_service_obj_id NUMBER
  ) RETURN NUMBER;

  /**
  * Получить кросс-курс валюты к валюте по ИД типа курса и ИД двух валют на дату
  * @author Sergeev D.
  * @param p_Rate_Type_Id ИД типа курса
  * @param p_Fund_Id_In ИД валюты приведения
  * @param p_Fund_Id_Out ИД валюты приведенной
  * @param p_Date Дата
  * @return Значение кросс-курса валют
  * @throw Значение кросс-курса = 0
  */
  FUNCTION get_cross_rate_by_id
  (
    p_rate_type_id IN NUMBER
   ,p_fund_id_in   IN NUMBER
   ,p_fund_id_out  IN NUMBER
   ,p_date         IN DATE DEFAULT trunc(SYSDATE, 'dd')
  ) RETURN NUMBER;

  /**
  * Получить остатки и обороты по счету в разрезе аналитик за период
  * @author Sergeev D.
  * @param p_Account_ID ИД счета
  * @param p_Fund_ID ИД валюты
  * @param p_Start_Date Дата начала периода
  * @param p_End_Date Дата окончания периода
  * @param p_A1_ID ИД объекта по 1-й аналитике счета
  * @param p_A1_nulls Признак все объекты/пустые объекты  по 1-й аналитике
  * @param p_A2_ID ИД объекта по 2-й аналитике счета
  * @param p_A2_nulls Признак все объекты/пустые объекты  по 2-й аналитике
  * @param p_A3_ID ИД объекта по 3-й аналитике счета
  * @param p_A3_nulls Признак все объекты/пустые объекты  по 3-й аналитике
  * @param p_A4_ID ИД объекта по 4-й аналитике счета
  * @param p_A4_nulls Признак все объекты/пустые объекты  по 4-й аналитике
  * @param p_A5_ID ИД объекта по 5-й аналитике счета
  * @param p_A5_nulls Признак все объекты/пустые объекты  по 5-й аналитике
  * @return Запись об остатках и оборотах по счету
  */
  FUNCTION get_acc_turn_rest
  (
    p_account_id NUMBER
   ,p_fund_id    NUMBER
   ,p_start_date DATE DEFAULT SYSDATE
   ,p_end_date   DATE DEFAULT SYSDATE
   ,p_a1_id      NUMBER DEFAULT NULL
   ,p_a1_nulls   NUMBER DEFAULT 0
   ,p_a2_id      NUMBER DEFAULT NULL
   ,p_a2_nulls   NUMBER DEFAULT 0
   ,p_a3_id      NUMBER DEFAULT NULL
   ,p_a3_nulls   NUMBER DEFAULT 0
   ,p_a4_id      NUMBER DEFAULT NULL
   ,p_a4_nulls   NUMBER DEFAULT 0
   ,p_a5_id      NUMBER DEFAULT NULL
   ,p_a5_nulls   NUMBER DEFAULT 0
  ) RETURN t_turn_rest;

  /**
  * Получить исходящий остаток по счету в разрезе аналитик на дату
  * @author Sergeev D.
  * @param p_Account_ID ИД счета
  * @param p_Fund_ID ИД валюты
  * @param p_Start_Date Дата начала периода
  * @param p_End_Date Дата окончания периода
  * @param p_A1_ID ИД объекта по 1-й аналитике счета
  * @param p_A1_nulls Признак все объекты/пустые объекты  по 1-й аналитике
  * @param p_A2_ID ИД объекта по 2-й аналитике счета
  * @param p_A2_nulls Признак все объекты/пустые объекты  по 2-й аналитике
  * @param p_A3_ID ИД объекта по 3-й аналитике счета
  * @param p_A3_nulls Признак все объекты/пустые объекты  по 3-й аналитике
  * @param p_A4_ID ИД объекта по 4-й аналитике счета
  * @param p_A4_nulls Признак все объекты/пустые объекты  по 4-й аналитике
  * @param p_A5_ID ИД объекта по 5-й аналитике счета
  * @param p_A5_nulls Признак все объекты/пустые объекты  по 5-й аналитике
  * @return Запись об остатке
  */
  FUNCTION get_acc_rest
  (
    p_account_id NUMBER
   ,p_fund_id    NUMBER
   ,p_date       DATE DEFAULT SYSDATE
   ,p_a1_id      NUMBER DEFAULT NULL
   ,p_a1_nulls   NUMBER DEFAULT 0
   ,p_a2_id      NUMBER DEFAULT NULL
   ,p_a2_nulls   NUMBER DEFAULT 0
   ,p_a3_id      NUMBER DEFAULT NULL
   ,p_a3_nulls   NUMBER DEFAULT 0
   ,p_a4_id      NUMBER DEFAULT NULL
   ,p_a4_nulls   NUMBER DEFAULT 0
   ,p_a5_id      NUMBER DEFAULT NULL
   ,p_a5_nulls   NUMBER DEFAULT 0
  ) RETURN t_rest;

  /**
  * Получить исходящий остаток по счету в разрезе аналитик на дату во внешней системе
  * @author Sergeev D.
  * @param p_Account_ID ИД счета
  * @param p_Fund_ID ИД валюты
  * @param p_Start_Date Дата начала периода
  * @param p_End_Date Дата окончания периода
  * @param p_A1_ID ИД объекта по 1-й аналитике счета
  * @param p_A1_nulls Признак все объекты/пустые объекты  по 1-й аналитике
  * @param p_A2_ID ИД объекта по 2-й аналитике счета
  * @param p_A2_nulls Признак все объекты/пустые объекты  по 2-й аналитике
  * @param p_A3_ID ИД объекта по 3-й аналитике счета
  * @param p_A3_nulls Признак все объекты/пустые объекты  по 3-й аналитике
  * @param p_A4_ID ИД объекта по 4-й аналитике счета
  * @param p_A4_nulls Признак все объекты/пустые объекты  по 4-й аналитике
  * @param p_A5_ID ИД объекта по 5-й аналитике счета
  * @param p_A5_nulls Признак все объекты/пустые объекты  по 5-й аналитике
  * @return Запись об остатке
  */
  FUNCTION get_acc_rest_abs
  (
    p_rest_amount_type VARCHAR2
   ,p_account_id       NUMBER
   ,p_fund_id          NUMBER
   ,p_date             DATE DEFAULT SYSDATE
   ,p_a1_id            NUMBER DEFAULT NULL
   ,p_a1_nulls         NUMBER DEFAULT 0
   ,p_a2_id            NUMBER DEFAULT NULL
   ,p_a2_nulls         NUMBER DEFAULT 0
   ,p_a3_id            NUMBER DEFAULT NULL
   ,p_a3_nulls         NUMBER DEFAULT 0
   ,p_a4_id            NUMBER DEFAULT NULL
   ,p_a4_nulls         NUMBER DEFAULT 0
   ,p_a5_id            NUMBER DEFAULT NULL
   ,p_a5_nulls         NUMBER DEFAULT 0
  ) RETURN NUMBER;

  /**
  * Получить остаток или оборот по счету, характеристике счета и типу остатка/оборота в разрезе аналитик за период
  * @author Sergeev D.
  * @param p_Type Тип остатка/оборота (IR_F/IR_BF/IR_Q/IRT_F/IRT_BF/IRT_Q/TD_F/TD_BF/TD_Q/TC_F/TC_BF/TC_Q/OR_F/OR_BF/OR_Q/ORT_F/ORT_BF/ORT_Q)
  * @param p_Char Характеристика счета (А/П/С)
  * @param p_Account_ID ИД счета
  * @param p_Fund_ID ИД валюты
  * @param p_Start_Date Дата начала периода
  * @param p_End_Date Дата окончания периода
  * @param p_A1_ID ИД объекта по 1-й аналитике счета
  * @param p_A1_nulls Признак все объекты/пустые объекты  по 1-й аналитике
  * @param p_A2_ID ИД объекта по 2-й аналитике счета
  * @param p_A2_nulls Признак все объекты/пустые объекты  по 2-й аналитике
  * @param p_A3_ID ИД объекта по 3-й аналитике счета
  * @param p_A3_nulls Признак все объекты/пустые объекты  по 3-й аналитике
  * @param p_A4_ID ИД объекта по 4-й аналитике счета
  * @param p_A4_nulls Признак все объекты/пустые объекты  по 4-й аналитике
  * @param p_A5_ID ИД объекта по 5-й аналитике счета
  * @param p_A5_nulls Признак все объекты/пустые объекты  по 5-й аналитике
  * @return Запись об остатках и оборотах по счету
  */
  FUNCTION get_acc_turn_rest_by_type
  (
    p_type       VARCHAR2
   ,p_char       VARCHAR2
   ,p_account_id NUMBER
   ,p_fund_id    NUMBER
   ,p_start_date DATE DEFAULT SYSDATE
   ,p_end_date   DATE DEFAULT SYSDATE
   ,p_a1_id      NUMBER DEFAULT NULL
   ,p_a1_nulls   NUMBER DEFAULT 0
   ,p_a2_id      NUMBER DEFAULT NULL
   ,p_a2_nulls   NUMBER DEFAULT 0
   ,p_a3_id      NUMBER DEFAULT NULL
   ,p_a3_nulls   NUMBER DEFAULT 0
   ,p_a4_id      NUMBER DEFAULT NULL
   ,p_a4_nulls   NUMBER DEFAULT 0
   ,p_a5_id      NUMBER DEFAULT NULL
   ,p_a5_nulls   NUMBER DEFAULT 0
  ) RETURN NUMBER;

  /**
  * Получить кросс-курс валюты к валюте по ИД типа курса и сокращениям двух валют на дату
  * @author Sergeev D.
  * @param p_Rate_Type_Id ИД типа курса
  * @param p_Fund_Brief_In Сокращение валюты приведения
  * @param p_Fund_Brief_Out Сокращение валюты приведенной
  * @param p_Date Дата
  * @return Значение кросс-курса валют
  * @throw Значение кросс-курса = 0
  */
  FUNCTION get_cross_rate_by_brief
  (
    p_rate_type_id   IN NUMBER
   ,p_fund_brief_in  IN VARCHAR2
   ,p_fund_brief_out IN VARCHAR2
   ,p_date           IN DATE DEFAULT trunc(SYSDATE, 'dd')
  ) RETURN NUMBER;

  /**
  * Получить 20-значный банковский счет с расчитанным ключевым разрядом
  * @author Sergeev D.
  * @param p_BIC Последние три цифры банковского идентификационного кода
  * @param p_Account Номер 20-значного банковского счета
  * @return Номер счета с расчитанным ключевым разрядом
  * @throw Номер счета = null
  */
  FUNCTION get_key_account
  (
    p_bic     VARCHAR2
   ,p_account VARCHAR2
  ) RETURN VARCHAR2;

  /**
  * Установка дочерним счетам признаки родительского счета
  * @author Sergeev D.
  * @param p_Account_ID ИД счета
  * @param p_IS_CHAR Признак копирования характеристики счета дочерним счетам
  * @param p_IS_AN Признак копирования типов аналитик дочерним счетам
  */
  PROCEDURE set_attr_inherit_child_acc
  (
    p_account_id NUMBER
   ,p_is_char    NUMBER
   ,p_is_an      NUMBER
  );
  /**
  * Получить ИД счета в другом плане счетов по маске счета из исходного плана счетов
  * @author Sergeev D.
  * @param p_Account_ID ИД счета в исходном плане счетов
  * @param p_Acc_Chart_Type_ID ИД исходного плана счетов
  * @param p_Rev_Acc_Chart_Type_ID ИД приведенного плана счетов
  * @return ИД счета
  * @throw ИД счета = null
  */
  FUNCTION get_account_by_mask
  (
    p_account_id            NUMBER
   ,p_acc_chart_type_id     NUMBER
   ,p_rev_acc_chart_type_id NUMBER
  ) RETURN NUMBER;

  /**
  * Получить количество значащих символов (не %, _ и т.д.) в маске счета
  * @author Sergeev D.
  * @param p_Mask Маска счета
  * @return Количество символов
  */
  FUNCTION mask_sign_count(p_mask VARCHAR2) RETURN NUMBER;

  /**
  * Получить признак присутсвия объекта по аналитике в счете
  * @author Sergeev D.
  * @param p_Analytic_Type_ID ИД типа аналитики
  * @param p_URO_ID ИД объекта по аналитике
  * @param p_Account_ID ИД счета
  * @return Признак присутствия объекта по аналитике (1)/ или его отсутствия (0)
  */
  FUNCTION is_valid_analytic
  (
    p_analytic_type_id NUMBER
   ,p_uro_id           NUMBER
   ,p_account_id       NUMBER
  ) RETURN NUMBER;

  /**
  * Получить ИД роли счета по маске счета
  * @author Sergeev D.
  * @param p_Account_Num Номер счета
  * @param p_Acc_Char Характеристика счета (А/П/С)
  * @param p_Acc_Chart_Type_ID ИД плана счетов
  * @return ИД роли счета
  */
  FUNCTION get_role_by_mask
  (
    p_account_num       VARCHAR2
   ,p_acc_char          VARCHAR2
   ,p_acc_chart_type_id NUMBER
  ) RETURN NUMBER;

  /**
  * Массовое обновление ролей счетов в плане счетов согласно заполненным маскам
  * @author Sergeev D.
  * @param p_Acc_Chart_Type_ID ИД плана счетов
  */
  PROCEDURE refresh_acc_roles(p_acc_chart_type_id NUMBER);

  /**
  * Установка дочерним счетам всех признаков родительского счета (характеристика, признак переоценки, аналитики)
  * @author Sergeev D.
  * @param p_Account_ID ИД счета
  */
  PROCEDURE update_nested_accounts(p_account_id NUMBER);

  /**
  * Открыть курсор по всем проводкам, где в качестве аналитики по дебету или
  * по кредиту участвует указанный объект учета.
  * @author  Ivanov D.
  * @param p_ent_id ИД сущности объекта
  * @param p_obj_id ИД объекта
  * @param p_cursor Курсор с проводками
  */
  PROCEDURE open_trans_cur_for_obj
  (
    p_ent_id IN NUMBER
   ,p_obj_id IN NUMBER
   ,p_cursor OUT t_cursor_trans
  );

  /**
  * Получить дату проводки с учетом закрытого периода
  * В случае, если дата проводки попадает в закрытый период, то берется
  * ближайшая дата вне закрытого периода.
  * @author   Ivanov D.
  * @param p_trans_date Жата проводки, которую создаем
  * @return Дата проводки с учетом закрытых периодов
  */
  FUNCTION get_trans_date(p_trans_date DATE) RETURN DATE;

  /**
  * Определить существуют ли операции по документу по шаблону операции
  * @author Kiselev P.
  * @param p_doc_id ИД документа
  * @param p_oper_template_id Сокращение шаблона операции
  * @return Признак существования операций (1/0)
  */
  FUNCTION is_trans_by_templ
  (
    p_doc_id     IN NUMBER
   ,p_oper_templ IN VARCHAR2
  ) RETURN NUMBER;

  /**
  * Определить ИД аналитики в проводке
  * @author Sergeev D.
  * @param p_trans_id ИД проводки
  * @param p_an_type_brief Сокращение типа аналитики
  * @param p_corr_type - 0 - дебет, 1 - кредит
  * @return ИД объекта по аналитике
  */
  FUNCTION get_trans_an_id
  (
    p_trans_id      IN NUMBER
   ,p_an_type_brief IN VARCHAR2
   ,p_corr_type     IN NUMBER DEFAULT NULL
  ) RETURN NUMBER;

  /*
  * Стандартная процедуры сторнирования
  * Заявка 349609 + небольшой рефакторинг
  * @author Байтин А.
  * @task 349609
  */
  PROCEDURE storno_trans(par_oper_id NUMBER);

  /* DEPRECATED
  * Ошибочная процедура сторнирования
  *
  * Выделил нестандартный блок из storno_trans
  * Использование этой процедуры - ошибка. 
  * Стандартная процедура сторнирования на вход принимает только oper_id 
  * и сама определяет пусть сторнирования.
  * @author Капля П. 
  * @date 29.01.2015
  */
  PROCEDURE storno_trans
  (
    par_oper_id      NUMBER
   ,par_trans_amount NUMBER
   ,par_acc_amount   NUMBER
  );
  -- Байтин А.
  -- Сторнирование, с привязкой операции к другому документу, например, к другой версии ДС
  -- За основу взята процедура из PKG_RENLIFE_UTILS + добавлен параметр №документа
  /*FUNCTION storno_trans
  (
    par_oper_id      NUMBER
   ,par_date         DATE
   ,par_document_id  NUMBER
   ,par_trans_amount NUMBER DEFAULT NULL
   ,par_acc_amount   NUMBER DEFAULT NULL
  ) RETURN NUMBER;*/

  /** Процедура позволяет/запрещает изменять проводки в закрытом периоде
  *   273031: Изменение триггера контроля закрытого периода в
  *   @param par_is_set - если 1, то проводки можно изменять в закрытом периоде
  *                     - если 0, то проводки нельзя изменять в закрытом периоде
  */
  PROCEDURE set_can_change_trans_in_closed(par_is_set BOOLEAN);

  /** Процедура получает значение о возможности изменять проводки в закрытом периоде
  *   273031: Изменение триггера контроля закрытого периода в
  *   @param par_is_set - если 1, то проводки можно изменять в закрытом периоде
  *                     - если 0, то проводки нельзя изменять в закрытом периоде
  */
  FUNCTION get_can_change_trans_in_closed RETURN BOOLEAN;

  analitic_cache utils.hashmap_t;
END acc_new;
/
CREATE OR REPLACE PACKAGE BODY acc_new IS

  --Возможность сторнирования проводки в закрытом периоде/273031/Чирков/
  gv_allow_change_in_closed BOOLEAN := FALSE;

  gcr_oper_templ dml_oper_templ.tt_oper_templ := dml_oper_templ.get_rec_by_brief('Аннулирование');

  FUNCTION get_sql(p_attr attr%ROWTYPE) RETURN VARCHAR2 IS
    v_sql_str VARCHAR2(4000);
  BEGIN
    v_sql_str := NULL;
    IF p_attr.source IS NOT NULL
       AND p_attr.col_name IS NOT NULL
    THEN
      v_sql_str := 'begin select ' || p_attr.col_name || ' into :ret_val from ' || p_attr.source ||
                   ' where ' || ents.get_ent_pk(ent.id_by_brief(p_attr.source)) || '= :obj_id; end;';
    ELSIF p_attr.calc IS NOT NULL
    THEN
      v_sql_str := p_attr.calc;
    ELSE
      raise_application_error(-20000, 'Bad definition of attribute');
    END IF;
    RETURN v_sql_str;
  END;

  -- объект аналитики по типу аналитики и объекту сущности услуги
  PROCEDURE get_an_by_an_type
  (
    p_ent_id    IN NUMBER
   ,p_obj_id    IN NUMBER
   ,p_an_type   IN NUMBER
   ,p_an_ent_id OUT NUMBER
   ,p_an_obj_id OUT NUMBER
  ) IS
  
  BEGIN
    IF (p_ent_id = 283)
    THEN
      IF (p_an_type = 1)
      THEN
        SELECT pc.contact_id
          INTO p_an_obj_id
          FROM ins.p_policy           p
              ,ins.p_policy_contact   pc
              ,ins.t_contact_pol_role cpr
         WHERE pc.policy_id = p_obj_id
           AND pc.contact_policy_role_id = cpr.id
           AND cpr.brief = 'Страхователь';
        p_an_ent_id := 22;
      ELSIF p_an_type = 2
      THEN
        p_an_obj_id := p_obj_id;
        p_an_ent_id := 283;
      END IF;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      --      dbms_output.put_line('Тип аналитики:' || p_an_type || ' ' || sqlerrm);
      p_an_ent_id := NULL;
      p_an_obj_id := NULL;
  END;

  FUNCTION get_an_type
  (
    p_ent_id  IN NUMBER
   ,p_obj_id  IN NUMBER
   ,p_an_type IN NUMBER
  ) RETURN NUMBER IS
    ret_val   NUMBER;
    v_attr    attr%ROWTYPE;
    v_sql_str VARCHAR2(4000);
  
  BEGIN
  
    -- атрибут услуги в типе аналитики
    v_sql_str := utils.get_null(analitic_cache
                               ,'AN_TYPE_' || p_an_type || '_' || p_ent_id || '_' || p_obj_id);
    IF v_sql_str IS NULL
    THEN
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
    
      -- значение атрибута услуги
      v_sql_str := get_sql(v_attr);
      analitic_cache('AN_TYPE_' || p_an_type || '_' || p_ent_id || '_' || p_obj_id) := v_sql_str;
    END IF;
    EXECUTE IMMEDIATE v_sql_str
      USING OUT ret_val, IN p_obj_id;
  
    RETURN ret_val;
  
  EXCEPTION
    WHEN OTHERS THEN
      --      dbms_output.put_line('Тип аналитики:' || p_an_type || ' ' || sqlerrm);
      RETURN NULL;
  END;

  FUNCTION get_date_type
  (
    p_ent_id    IN NUMBER
   ,p_obj_id    IN NUMBER
   ,p_date_type IN NUMBER
  ) RETURN DATE IS
    ret_val   DATE;
    v_attr    attr%ROWTYPE;
    v_sql_str VARCHAR2(4000);
  BEGIN
    /*
      if (p_ent_id = 283) then
        if (p_date_type = 1) then
          select p.confirm_date into ret_val from ins.p_policy p where p.policy_id = p_obj_id;
        end if;
      end if;
    */
    v_sql_str := utils.get_null(analitic_cache
                               ,'DATE_TYPE_' || p_date_type || '_' || p_ent_id || '_' || p_obj_id);
    IF v_sql_str IS NULL
    THEN
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
    
      v_sql_str := get_sql(v_attr);
      analitic_cache('DATE_TYPE_' || p_date_type || '_' || p_ent_id || '_' || p_obj_id) := v_sql_str;
    END IF;
    EXECUTE IMMEDIATE v_sql_str
      USING OUT ret_val, IN p_obj_id;
  
    RETURN ret_val;
  
    /* exception
       when others then
         dbms_output.put_line('Тип даты:' || p_date_type || ' ' || sqlerrm);
         return null;
    */
  END;

  FUNCTION get_fund_type
  (
    p_ent_id    IN NUMBER
   ,p_obj_id    IN NUMBER
   ,p_fund_type IN NUMBER
  ) RETURN NUMBER IS
    ret_val   NUMBER;
    v_attr    attr%ROWTYPE;
    v_sql_str VARCHAR2(4000);
  BEGIN
    /*
     if (p_ent_id = 283) then
       select ph.fund_id into ret_val from ins.p_policy p, ins.p_pol_header ph
       where p.pol_header_id = ph.policy_header_id
       and p.policy_id = p_obj_id;
     end if;
    */
    v_sql_str := utils.get_null(analitic_cache
                               ,'FUND_TYPE_' || p_fund_type || '_' || p_ent_id || '_' || p_obj_id);
    IF v_sql_str IS NULL
    THEN
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
    
      v_sql_str := get_sql(v_attr);
      analitic_cache('FUND_TYPE_' || p_fund_type || '_' || p_ent_id || '_' || p_obj_id) := v_sql_str;
    END IF;
    EXECUTE IMMEDIATE v_sql_str
      USING OUT ret_val, IN p_obj_id;
  
    RETURN ret_val;
  
  EXCEPTION
    WHEN OTHERS THEN
      dbms_output.put_line('Тип валюты:' || p_fund_type || ' ' || SQLERRM);
      RETURN NULL;
  END;

  FUNCTION get_summ_type
  (
    p_ent_id    IN NUMBER
   ,p_obj_id    IN NUMBER
   ,p_summ_type IN NUMBER
  ) RETURN NUMBER IS
    ret_val   NUMBER;
    v_attr    attr%ROWTYPE;
    v_sql_str VARCHAR2(4000);
  BEGIN
    --DBMS_OUTPUT.PUT_LINE(p_ent_id || '  ' || p_obj_id || '  ' || p_summ_type);
    v_sql_str := utils.get_null(analitic_cache
                               ,'SUMM_TYPE_' || p_summ_type || '_' || p_ent_id || '_' || p_obj_id);
    IF v_sql_str IS NULL
    THEN
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
    
      v_sql_str := get_sql(v_attr);
      analitic_cache('SUMM_TYPE_' || p_summ_type || '_' || p_ent_id || '_' || p_obj_id) := v_sql_str;
    END IF;
    EXECUTE IMMEDIATE v_sql_str
      USING OUT ret_val, IN p_obj_id;
  
    RETURN ret_val;
  
  EXCEPTION
    WHEN OTHERS THEN
      dbms_output.put_line('Тип суммы:' || p_summ_type || ' ' || SQLERRM);
      RETURN NULL;
  END;

  --Функция для определения счета по М.О.С.
  FUNCTION get_acc_by_acc_def_rule
  (
    p_adr_id    NUMBER
   ,p_entity_id NUMBER
   ,p_object_id NUMBER
   ,p_fund_id   NUMBER
   ,p_date      DATE
   ,p_doc_id    IN NUMBER DEFAULT NULL
  ) RETURN NUMBER IS
    v_account_id NUMBER;
    v_adr_name   VARCHAR2(150);
    v_adr_brief  VARCHAR2(61);
    v_sql_text   VARCHAR2(4000);
  BEGIN
    BEGIN
      SELECT adr.name
            ,adr.brief
        INTO v_adr_name
            ,v_adr_brief
        FROM acc_def_rule adr
       WHERE adr.acc_def_rule_id = p_adr_id;
      v_sql_text := 'begin select ' || v_adr_brief ||
                    '(:p_Entity_ID, :p_Object_ID, :p_Fund_ID, :p_Date, :p_Doc_ID) ' ||
                    'Account_ID into :v_Account_ID from dual; end;';
      EXECUTE IMMEDIATE v_sql_text
        USING IN p_entity_id, IN p_object_id, IN p_fund_id, IN p_date, IN p_doc_id, OUT v_account_id;
    EXCEPTION
      WHEN OTHERS THEN
        --raise_application_error(-20000,sqlerrm);
        v_account_id := 0;
    END;
    RETURN v_account_id;
  END;

  --Функция для определения счета по типу счета
  FUNCTION get_acc_by_acc_type
  (
    p_acc_type_templ_id    NUMBER
   ,p_acc_chart_type_id    NUMBER
   ,p_settlement_scheme_id NUMBER
   ,p_doc_id               NUMBER
  ) RETURN NUMBER IS
    v_account_id NUMBER;
    CURSOR c_acc_set IS
      SELECT dta.doc_templ_acc_id
            ,dta.acc_role_id
            ,doc.get_fund_type(p_doc_id, dta.fund_type_id) fund_id
            ,dta.a1_analytic_type_id
            ,nvl2(dta.a1_analytic_type_id, doc.get_an_type(p_doc_id, dta.a1_analytic_type_id), NULL) a1_uro_id
            ,dta.a2_analytic_type_id
            ,nvl2(dta.a2_analytic_type_id, doc.get_an_type(p_doc_id, dta.a2_analytic_type_id), NULL) a2_uro_id
            ,dta.a3_analytic_type_id
            ,nvl2(dta.a3_analytic_type_id, doc.get_an_type(p_doc_id, dta.a3_analytic_type_id), NULL) a3_uro_id
            ,dta.a4_analytic_type_id
            ,nvl2(dta.a4_analytic_type_id, doc.get_an_type(p_doc_id, dta.a4_analytic_type_id), NULL) a4_uro_id
            ,dta.a5_analytic_type_id
            ,nvl2(dta.a5_analytic_type_id, doc.get_an_type(p_doc_id, dta.a5_analytic_type_id), NULL) a5_uro_id
        FROM document      d
            ,doc_templ     dt
            ,doc_templ_acc dta
       WHERE d.document_id = p_doc_id
         AND dta.acc_type_templ_id = p_acc_type_templ_id
         AND dta.acc_chart_type_id = p_acc_chart_type_id
         AND d.doc_templ_id = dt.doc_templ_id
         AND dt.doc_templ_id = dta.doc_templ_id
         AND ((dta.settlement_scheme_id IS NULL) OR
             (dta.settlement_scheme_id IS NOT NULL) AND
             (dta.settlement_scheme_id = p_settlement_scheme_id))
       ORDER BY dta.priority_order;
    v_doc_templ_acc_id    NUMBER;
    v_acc_role_id         NUMBER;
    v_fund_id             NUMBER;
    v_a1_analytic_type_id NUMBER;
    v_a1_uro_id           NUMBER;
    v_a2_analytic_type_id NUMBER;
    v_a2_uro_id           NUMBER;
    v_a3_analytic_type_id NUMBER;
    v_a3_uro_id           NUMBER;
    v_a4_analytic_type_id NUMBER;
    v_a4_uro_id           NUMBER;
    v_a5_analytic_type_id NUMBER;
    v_a5_uro_id           NUMBER;
    CURSOR c_account
    (
      cp_fund_id             NUMBER
     ,cp_acc_role_id         NUMBER
     ,cp_a1_analytic_type_id NUMBER
     ,cp_a1_uro_id           NUMBER
     ,cp_a2_analytic_type_id NUMBER
     ,cp_a2_uro_id           NUMBER
     ,cp_a3_analytic_type_id NUMBER
     ,cp_a3_uro_id           NUMBER
     ,cp_a4_analytic_type_id NUMBER
     ,cp_a4_uro_id           NUMBER
     ,cp_a5_analytic_type_id NUMBER
     ,cp_a5_uro_id           NUMBER
    ) IS
      SELECT a.account_id
        FROM account a
       WHERE a.acc_chart_type_id = p_acc_chart_type_id
         AND a.fund_id = cp_fund_id
         AND a.acc_role_id = cp_acc_role_id
         AND ((((cp_a1_analytic_type_id IS NULL) AND (cp_a1_uro_id IS NULL)) OR
             ((cp_a1_analytic_type_id IS NOT NULL) AND (cp_a1_uro_id IS NOT NULL) AND
             (acc.is_valid_analytic(cp_a1_analytic_type_id, cp_a1_uro_id, a.account_id) = 1))) AND
             (((cp_a2_analytic_type_id IS NULL) AND (cp_a2_uro_id IS NULL)) OR
             ((cp_a2_analytic_type_id IS NOT NULL) AND (cp_a2_uro_id IS NOT NULL) AND
             (acc.is_valid_analytic(cp_a2_analytic_type_id, cp_a2_uro_id, a.account_id) = 1))) AND
             (((cp_a3_analytic_type_id IS NULL) AND (cp_a3_uro_id IS NULL)) OR
             ((cp_a3_analytic_type_id IS NOT NULL) AND (cp_a3_uro_id IS NOT NULL) AND
             (acc.is_valid_analytic(cp_a3_analytic_type_id, cp_a3_uro_id, a.account_id) = 1))) AND
             (((cp_a4_analytic_type_id IS NULL) AND (cp_a4_uro_id IS NULL)) OR
             ((cp_a4_analytic_type_id IS NOT NULL) AND (cp_a4_uro_id IS NOT NULL) AND
             (acc.is_valid_analytic(cp_a4_analytic_type_id, cp_a4_uro_id, a.account_id) = 1))) AND
             (((cp_a5_analytic_type_id IS NULL) AND (cp_a5_uro_id IS NULL)) OR
             ((cp_a5_analytic_type_id IS NOT NULL) AND (cp_a5_uro_id IS NOT NULL) AND
             (acc.is_valid_analytic(cp_a5_analytic_type_id, cp_a5_uro_id, a.account_id) = 1))));
    CURSOR c_doc_acc_redefine
    (
      cp_doc_id           NUMBER
     ,cp_doc_templ_acc_id NUMBER
    ) IS
      SELECT dar.account_id
        FROM doc_acc_redefine dar
       WHERE dar.document_id = cp_doc_id
         AND dar.doc_templ_acc_id = cp_doc_templ_acc_id;
  BEGIN
    v_account_id := NULL;
    OPEN c_acc_set;
    LOOP
      FETCH c_acc_set
        INTO v_doc_templ_acc_id
            ,v_fund_id
            ,v_acc_role_id
            ,v_a1_analytic_type_id
            ,v_a1_uro_id
            ,v_a2_analytic_type_id
            ,v_a2_uro_id
            ,v_a3_analytic_type_id
            ,v_a3_uro_id
            ,v_a4_analytic_type_id
            ,v_a4_uro_id
            ,v_a5_analytic_type_id
            ,v_a5_uro_id;
      EXIT WHEN c_acc_set%NOTFOUND;
      IF (((v_a1_analytic_type_id IS NULL) AND (v_a1_uro_id IS NULL)) OR
         ((v_a1_analytic_type_id IS NOT NULL) AND (v_a1_uro_id IS NOT NULL)))
         AND (((v_a2_analytic_type_id IS NULL) AND (v_a2_uro_id IS NULL)) OR
         ((v_a2_analytic_type_id IS NOT NULL) AND (v_a2_uro_id IS NOT NULL)))
         AND (((v_a3_analytic_type_id IS NULL) AND (v_a3_uro_id IS NULL)) OR
         ((v_a3_analytic_type_id IS NOT NULL) AND (v_a3_uro_id IS NOT NULL)))
         AND (((v_a4_analytic_type_id IS NULL) AND (v_a4_uro_id IS NULL)) OR
         ((v_a4_analytic_type_id IS NOT NULL) AND (v_a4_uro_id IS NOT NULL)))
         AND (((v_a5_analytic_type_id IS NULL) AND (v_a5_uro_id IS NULL)) OR
         ((v_a5_analytic_type_id IS NOT NULL) AND (v_a5_uro_id IS NOT NULL)))
      THEN
        OPEN c_doc_acc_redefine(p_doc_id, v_doc_templ_acc_id);
        FETCH c_doc_acc_redefine
          INTO v_account_id;
        IF c_doc_acc_redefine%NOTFOUND
        THEN
          OPEN c_account(v_acc_role_id
                        ,v_fund_id
                        ,v_a1_analytic_type_id
                        ,v_a1_uro_id
                        ,v_a2_analytic_type_id
                        ,v_a2_uro_id
                        ,v_a3_analytic_type_id
                        ,v_a3_uro_id
                        ,v_a4_analytic_type_id
                        ,v_a4_uro_id
                        ,v_a5_analytic_type_id
                        ,v_a5_uro_id);
          FETCH c_account
            INTO v_account_id;
          IF c_acc_set%NOTFOUND
          THEN
            v_account_id := NULL;
          END IF;
          CLOSE c_account;
        END IF;
        CLOSE c_doc_acc_redefine;
        EXIT;
      END IF;
    END LOOP;
    CLOSE c_acc_set;
    RETURN v_account_id;
  END;

  --Функция для определения приоритета счета по типу счета
  FUNCTION get_acc_priority_by_acc_type
  (
    p_acc_type_templ_id    NUMBER
   ,p_acc_chart_type_id    NUMBER
   ,p_settlement_scheme_id NUMBER
   ,p_doc_id               NUMBER
  ) RETURN NUMBER IS
    --v_Priority_ID number;
    CURSOR c_acc_set IS
      SELECT dta.priority_order
            ,dta.a1_analytic_type_id
            ,nvl2(dta.a1_analytic_type_id, doc.get_an_type(p_doc_id, dta.a1_analytic_type_id), NULL) a1_uro_id
            ,dta.a2_analytic_type_id
            ,nvl2(dta.a2_analytic_type_id, doc.get_an_type(p_doc_id, dta.a2_analytic_type_id), NULL) a2_uro_id
            ,dta.a3_analytic_type_id
            ,nvl2(dta.a3_analytic_type_id, doc.get_an_type(p_doc_id, dta.a3_analytic_type_id), NULL) a3_uro_id
            ,dta.a4_analytic_type_id
            ,nvl2(dta.a4_analytic_type_id, doc.get_an_type(p_doc_id, dta.a4_analytic_type_id), NULL) a4_uro_id
            ,dta.a5_analytic_type_id
            ,nvl2(dta.a5_analytic_type_id, doc.get_an_type(p_doc_id, dta.a5_analytic_type_id), NULL) a5_uro_id
        FROM document      d
            ,doc_templ     dt
            ,doc_templ_acc dta
       WHERE d.document_id = p_doc_id
         AND dta.acc_type_templ_id = p_acc_type_templ_id
         AND dta.acc_chart_type_id = p_acc_chart_type_id
         AND d.doc_templ_id = dt.doc_templ_id
         AND dt.doc_templ_id = dta.doc_templ_id
         AND ((dta.settlement_scheme_id IS NULL) OR
             (dta.settlement_scheme_id IS NOT NULL) AND
             (dta.settlement_scheme_id = p_settlement_scheme_id))
       ORDER BY dta.priority_order;
    --v_Doc_Templ_Acc_ID    number;
    --v_Acc_Role_ID         number;
    --v_Fund_ID             number;
    v_a1_analytic_type_id NUMBER;
    v_a1_uro_id           NUMBER;
    v_a2_analytic_type_id NUMBER;
    v_a2_uro_id           NUMBER;
    v_a3_analytic_type_id NUMBER;
    v_a3_uro_id           NUMBER;
    v_a4_analytic_type_id NUMBER;
    v_a4_uro_id           NUMBER;
    v_a5_analytic_type_id NUMBER;
    v_a5_uro_id           NUMBER;
    v_priority            NUMBER;
    v_priority_order      NUMBER;
  BEGIN
    v_priority := 0;
    OPEN c_acc_set;
    LOOP
      FETCH c_acc_set
        INTO v_priority_order
            ,v_a1_analytic_type_id
            ,v_a1_uro_id
            ,v_a2_analytic_type_id
            ,v_a2_uro_id
            ,v_a3_analytic_type_id
            ,v_a3_uro_id
            ,v_a4_analytic_type_id
            ,v_a4_uro_id
            ,v_a5_analytic_type_id
            ,v_a5_uro_id;
      EXIT WHEN c_acc_set%NOTFOUND;
      IF (((v_a1_analytic_type_id IS NULL) AND (v_a1_uro_id IS NULL)) OR
         ((v_a1_analytic_type_id IS NOT NULL) AND (v_a1_uro_id IS NOT NULL)))
         AND (((v_a2_analytic_type_id IS NULL) AND (v_a2_uro_id IS NULL)) OR
         ((v_a2_analytic_type_id IS NOT NULL) AND (v_a2_uro_id IS NOT NULL)))
         AND (((v_a3_analytic_type_id IS NULL) AND (v_a3_uro_id IS NULL)) OR
         ((v_a3_analytic_type_id IS NOT NULL) AND (v_a3_uro_id IS NOT NULL)))
         AND (((v_a4_analytic_type_id IS NULL) AND (v_a4_uro_id IS NULL)) OR
         ((v_a4_analytic_type_id IS NOT NULL) AND (v_a4_uro_id IS NOT NULL)))
         AND (((v_a5_analytic_type_id IS NULL) AND (v_a5_uro_id IS NULL)) OR
         ((v_a5_analytic_type_id IS NOT NULL) AND (v_a5_uro_id IS NOT NULL)))
      THEN
        v_priority := v_priority_order;
        EXIT;
      END IF;
    END LOOP;
    CLOSE c_acc_set;
    RETURN v_priority;
  END;

  --Формирование примечания проводки
  FUNCTION get_trans_note
  (
    p_trans_templ_id NUMBER
   ,p_oper_id        NUMBER
  ) RETURN VARCHAR2 IS
    v_note       VARCHAR2(2000);
    v_res_note   VARCHAR2(2000);
    i            INTEGER;
    j            INTEGER;
    f            INTEGER;
    v_attr_brief VARCHAR2(30);
  BEGIN
    BEGIN
      SELECT tt.note INTO v_note FROM trans_templ tt WHERE tt.trans_templ_id = p_trans_templ_id;
    EXCEPTION
      WHEN OTHERS THEN
        v_note := '';
    END;
    IF length(v_note) > 0
    THEN
      i          := 1;
      v_res_note := '';
      WHILE i <= length(v_note)
      LOOP
        IF (substr(v_note, i, 1) <> '[')
        THEN
          v_res_note := v_res_note || substr(v_note, i, 1);
          i          := i + 1;
        ELSE
          f            := 0;
          j            := i + 1;
          v_attr_brief := '';
          WHILE (f = 0)
                AND (j <= length(v_note))
          LOOP
            IF (substr(v_note, j, 1) <> ']')
            THEN
              v_attr_brief := v_attr_brief || substr(v_note, j, 1);
              j            := j + 1;
            ELSE
              f := 1;
            END IF;
          END LOOP;
          IF (f = 1)
          THEN
            v_res_note := v_res_note || doc.get_attr('OPER', v_attr_brief, p_oper_id);
            i          := i + length(v_attr_brief) + 2;
          ELSE
            i := i + 1;
          END IF;
        END IF;
      END LOOP;
    END IF;
    RETURN v_res_note;
  END;

  --Функция для М.О.С. "Счет в валюте"
  FUNCTION acc_by_fund
  (
    p_entity_id NUMBER
   ,p_object_id NUMBER
   ,p_fund_id   NUMBER
   ,p_date      DATE
   ,p_doc_id    IN NUMBER DEFAULT NULL
  ) RETURN NUMBER IS
    v_account_id NUMBER;
  BEGIN
    -- Входящий параметр: ИД синтетического балансового счета
    -- Необходимо найти лицевой счет по баланосовому в указанной валюте
    BEGIN
      SELECT nvl(MIN(a.account_id), 0)
        INTO v_account_id
        FROM account a
       WHERE a.parent_id = p_object_id
         AND a.fund_id = p_fund_id
         AND a.open_date <= p_date
         AND ((a.close_date > p_date) OR (a.close_date IS NULL))
         AND (a.acc_status_id <> 5);
    EXCEPTION
      WHEN OTHERS THEN
        v_account_id := 0;
        dbms_output.put_line('М.О.С. "Счет в валюте"');
        dbms_output.put_line('Не найден счет по следующим параметрам:');
        dbms_output.put_line('p_Entity_ID = ' || to_char(p_entity_id));
        dbms_output.put_line('p_Object_ID = ' || to_char(p_object_id));
        dbms_output.put_line('p_Fund_ID   = ' || to_char(p_fund_id));
        dbms_output.put_line('p_Date      = ' || to_char(p_entity_id, 'DD/MM/YYYY'));
    END;
    RETURN v_account_id;
  END;

  --Функция для М.О.С. "Счет дебет во внутреннем документе"
  FUNCTION acc_dt_mo
  (
    p_entity_id NUMBER
   ,p_object_id NUMBER
   ,p_fund_id   NUMBER
   ,p_date      DATE
   ,p_doc_id    IN NUMBER DEFAULT NULL
  ) RETURN NUMBER IS
    v_account_id NUMBER;
    --v_Acc_Chart_Type_ID number;
  BEGIN
    BEGIN
      SELECT a.account_id
        INTO v_account_id
        FROM document      d
            ,doc_mem_order dmo
            ,account       a
       WHERE d.document_id = dmo.doc_mem_order_id
         AND d.document_id = p_object_id
         AND a.account_id = dmo.dt_account_id
         AND dmo.acc_chart_type_id = a.acc_chart_type_id;
    EXCEPTION
      WHEN OTHERS THEN
        v_account_id := 0;
        dbms_output.put_line('М.О.С. "Счет дебет во внутреннем документе"');
        dbms_output.put_line('Не найден счет по следующим параметрам:');
        dbms_output.put_line('p_Entity_ID = ' || to_char(p_entity_id));
        dbms_output.put_line('p_Object_ID = ' || to_char(p_object_id));
        dbms_output.put_line('p_Fund_ID   = ' || to_char(p_fund_id));
        dbms_output.put_line('p_Date      = ' || to_char(p_entity_id, 'DD/MM/YYYY'));
    END;
    RETURN v_account_id;
  END;

  --Функция для М.О.С. "Счет дебет (приведенный) во внутреннем документе"
  FUNCTION acc_dt_mo_rev
  (
    p_entity_id NUMBER
   ,p_object_id NUMBER
   ,p_fund_id   NUMBER
   ,p_date      DATE
   ,p_doc_id    IN NUMBER DEFAULT NULL
  ) RETURN NUMBER IS
    v_account_id NUMBER;
    --v_Acc_Chart_Type_ID number;
  BEGIN
    BEGIN
      SELECT a.account_id
        INTO v_account_id
        FROM document      d
            ,doc_mem_order dmo
            ,account       a
       WHERE d.document_id = dmo.doc_mem_order_id
         AND d.document_id = p_object_id
         AND a.account_id = dmo.dt_account_id
         AND dmo.acc_chart_type_id = a.acc_chart_type_id;
      v_account_id := acc.get_account_by_mask(v_account_id, 1, 2);
    EXCEPTION
      WHEN OTHERS THEN
        v_account_id := 0;
        dbms_output.put_line('М.О.С. "Счет дебет во внутреннем документе"');
        dbms_output.put_line('Не найден счет по следующим параметрам:');
        dbms_output.put_line('p_Entity_ID = ' || to_char(p_entity_id));
        dbms_output.put_line('p_Object_ID = ' || to_char(p_object_id));
        dbms_output.put_line('p_Fund_ID   = ' || to_char(p_fund_id));
        dbms_output.put_line('p_Date      = ' || to_char(p_entity_id, 'DD/MM/YYYY'));
    END;
    RETURN v_account_id;
  END;

  --Функция для М.О.С. "Счет кредит во внутреннем документе"
  FUNCTION acc_ct_mo
  (
    p_entity_id NUMBER
   ,p_object_id NUMBER
   ,p_fund_id   NUMBER
   ,p_date      DATE
   ,p_doc_id    IN NUMBER DEFAULT NULL
  ) RETURN NUMBER IS
    v_account_id NUMBER;
    --v_Acc_Chart_Type_ID number;
  BEGIN
    BEGIN
      SELECT a.account_id
        INTO v_account_id
        FROM document      d
            ,doc_mem_order dmo
            ,account       a
       WHERE d.document_id = dmo.doc_mem_order_id
         AND d.document_id = p_object_id
         AND a.account_id = dmo.ct_account_id
         AND dmo.acc_chart_type_id = a.acc_chart_type_id;
    EXCEPTION
      WHEN OTHERS THEN
        v_account_id := 0;
        dbms_output.put_line('М.О.С. "Счет кредит во внутреннем документе"');
        dbms_output.put_line('Не найден счет по следующим параметрам:');
        dbms_output.put_line('p_Entity_ID = ' || to_char(p_entity_id));
        dbms_output.put_line('p_Object_ID = ' || to_char(p_object_id));
        dbms_output.put_line('p_Fund_ID   = ' || to_char(p_fund_id));
        dbms_output.put_line('p_Date      = ' || to_char(p_entity_id, 'DD/MM/YYYY'));
    END;
    RETURN v_account_id;
  END;

  --Функция для М.О.С. "Счет кредит (приведенный) во внутреннем документе"
  FUNCTION acc_ct_mo_rev
  (
    p_entity_id NUMBER
   ,p_object_id NUMBER
   ,p_fund_id   NUMBER
   ,p_date      DATE
   ,p_doc_id    IN NUMBER DEFAULT NULL
  ) RETURN NUMBER IS
    v_account_id NUMBER;
    --v_Acc_Chart_Type_ID number;
  BEGIN
    BEGIN
      SELECT a.account_id
        INTO v_account_id
        FROM document      d
            ,doc_mem_order dmo
            ,account       a
       WHERE d.document_id = dmo.doc_mem_order_id
         AND d.document_id = p_object_id
         AND a.account_id = dmo.ct_account_id
         AND dmo.acc_chart_type_id = a.acc_chart_type_id;
      v_account_id := acc.get_account_by_mask(v_account_id, 1, 2);
    EXCEPTION
      WHEN OTHERS THEN
        v_account_id := 0;
        dbms_output.put_line('М.О.С. "Счет кредит во внутреннем документе"');
        dbms_output.put_line('Не найден счет по следующим параметрам:');
        dbms_output.put_line('p_Entity_ID = ' || to_char(p_entity_id));
        dbms_output.put_line('p_Object_ID = ' || to_char(p_object_id));
        dbms_output.put_line('p_Fund_ID   = ' || to_char(p_fund_id));
        dbms_output.put_line('p_Date      = ' || to_char(p_entity_id, 'DD/MM/YYYY'));
    END;
    RETURN v_account_id;
  END;

  --Функция для М.О.С. "Счет расчетов с контрагентом по договору страхования"
  FUNCTION acc_policy_ctr
  (
    p_entity_id NUMBER
   ,p_object_id NUMBER
   ,p_fund_id   NUMBER
   ,p_date      DATE
   ,p_doc_id    IN NUMBER DEFAULT NULL
  ) RETURN NUMBER IS
    v_account_id        NUMBER;
    v_agent_count       NUMBER;
    v_acc_chart_type_id NUMBER;
  BEGIN
    BEGIN
      SELECT COUNT(ppa.p_policy_agent_id)
        INTO v_agent_count
        FROM p_policy_agent      ppa
            ,p_pol_header        ph
            ,p_policy            p
            ,as_asset            a
            ,p_cover             pc
            ,policy_agent_status pas
       WHERE pc.p_cover_id = p_object_id
         AND pc.as_asset_id = a.as_asset_id
         AND a.p_policy_id = p.policy_id
         AND p.pol_header_id = ph.policy_header_id
         AND ppa.policy_header_id = ph.policy_header_id
         AND ppa.status_id = pas.policy_agent_status_id
         AND pas.brief <> 'CANCEL';
    
      SELECT act.acc_chart_type_id
        INTO v_acc_chart_type_id
        FROM acc_chart_type act
       WHERE act.brief = 'УПР';
    
      IF v_agent_count > 0
      THEN
        SELECT a.account_id
          INTO v_account_id
          FROM account a
         WHERE a.acc_chart_type_id = v_acc_chart_type_id
           AND a.num = '77.05.01';
      ELSE
        SELECT a.account_id
          INTO v_account_id
          FROM account a
         WHERE a.acc_chart_type_id = v_acc_chart_type_id
           AND a.num = '77.00.01';
      END IF;
    
    EXCEPTION
      WHEN OTHERS THEN
        v_account_id := 0;
        dbms_output.put_line('М.О.С. "Счет кредит во внутреннем документе"');
        dbms_output.put_line('Не найден счет по следующим параметрам:');
        dbms_output.put_line('p_Entity_ID = ' || to_char(p_entity_id));
        dbms_output.put_line('p_Object_ID = ' || to_char(p_object_id));
        dbms_output.put_line('p_Fund_ID   = ' || to_char(p_fund_id));
        dbms_output.put_line('p_Date      = ' || to_char(p_date, 'DD/MM/YYYY'));
    END;
    RETURN v_account_id;
  END;

  --Функция для М.О.С. "Счет расчетов с сервисной организацией"
  FUNCTION acc_contract_ctr
  (
    p_entity_id NUMBER
   ,p_object_id NUMBER
   ,p_fund_id   NUMBER
   ,p_date      DATE
   ,p_doc_id    IN NUMBER DEFAULT NULL
  ) RETURN NUMBER IS
    v_account_id          NUMBER;
    v_doc_templ_brief     VARCHAR2(50);
    v_contract_lpu_ver_id NUMBER;
    v_dms_lpu_acc_type_id NUMBER;
    CURSOR cur_con_adv IS
      SELECT clv.contract_lpu_ver_id
            ,clv.dms_lpu_acc_type_id
        FROM ven_doc_doc          dd
            ,ven_doc_doc          dd1
            ,ven_contract_lpu_ver clv
            ,ven_doc_templ        dt
       WHERE dt.brief = 'CONTRACT_LPU_VER'
         AND dt.doc_templ_id = clv.doc_templ_id
         AND dd1.parent_id = clv.contract_lpu_ver_id
         AND dd1.child_id = dd.parent_id
         AND dd.child_id = p_doc_id;
    CURSOR cur_acc(p_num VARCHAR2) IS
      SELECT a.account_id FROM ven_account a WHERE a.num = p_num;
  BEGIN
    BEGIN
      v_doc_templ_brief := doc.get_doc_templ_brief(p_doc_id);
      v_account_id      := NULL;
      IF v_doc_templ_brief = 'PAYADVLPU'
      THEN
        OPEN cur_con_adv;
        FETCH cur_con_adv
          INTO v_contract_lpu_ver_id
              ,v_dms_lpu_acc_type_id;
        IF cur_con_adv%NOTFOUND
        THEN
          v_contract_lpu_ver_id := NULL;
          v_dms_lpu_acc_type_id := NULL;
        END IF;
        CLOSE cur_con_adv;
        IF v_dms_lpu_acc_type_id = 1
        THEN
          OPEN cur_acc('60.02.01.01');
        ELSIF v_dms_lpu_acc_type_id = 2
        THEN
          OPEN cur_acc('60.02.01.02');
        END IF;
        FETCH cur_acc
          INTO v_account_id;
        IF cur_acc%NOTFOUND
        THEN
          v_account_id := 0;
        END IF;
        CLOSE cur_acc;
      END IF;
    
    EXCEPTION
      WHEN OTHERS THEN
        v_account_id := 0;
        dbms_output.put_line('М.О.С. "Счет кредит во внутреннем документе"');
        dbms_output.put_line('Не найден счет по следующим параметрам:');
        dbms_output.put_line('p_Entity_ID = ' || to_char(p_entity_id));
        dbms_output.put_line('p_Object_ID = ' || to_char(p_object_id));
        dbms_output.put_line('p_Fund_ID   = ' || to_char(p_fund_id));
        dbms_output.put_line('p_Date      = ' || to_char(p_date, 'DD/MM/YYYY'));
    END;
    RETURN v_account_id;
  END acc_contract_ctr;

  --Функция для создания проводки по шаблону
  FUNCTION add_trans_by_template
  (
    p_trans_templ_id      NUMBER
   ,p_oper_id             NUMBER
   ,p_service_ent_id      NUMBER
   ,p_service_obj_id      NUMBER
   ,p_is_accepted         NUMBER DEFAULT 1
   ,p_date                DATE DEFAULT NULL
   ,p_summ                NUMBER DEFAULT NULL
   ,p_qty                 NUMBER DEFAULT NULL
   ,p_source              VARCHAR2 DEFAULT 'INS'
   ,p_templ_date_investor NUMBER DEFAULT NULL
  ) RETURN NUMBER IS
    TYPE t_an IS RECORD(
       ure_name VARCHAR2(30)
      ,uro_name VARCHAR2(30)
      ,corr     VARCHAR2(1)
      ,a_num    VARCHAR2(1));
    --v_SQL_Text             varchar2(4000);
    v_doc_ent_id     NUMBER;
    v_document_id    NUMBER;
    v_rate_type_id   NUMBER;
    v_recalc_fund_id NUMBER;
    v_rate           NUMBER;
    v_recalc_rate    NUMBER;
    v_trans_templ    trans_templ%ROWTYPE;
    v_trans          trans%ROWTYPE;
    --v_An_Col_Name          varchar2(30);
    v_temp_str_1 VARCHAR2(150);
    v_temp_str_2 VARCHAR2(150);
    --v_Temp_Str_3           varchar2(150);
    v_settlement_scheme_id NUMBER;
    CURSOR c_an IS
      SELECT atc.col_name ure_name
            ,substr(atc.col_name, 0, 8) || 'O' || substr(atc.col_name, 10, 3) uro_name
            ,substr(TRIM(' ' FROM atc.col_name), 4, 1) corr
            ,substr(atc.col_name, 2, 1) a_num
        FROM attr atc --, attr atco
       WHERE atc.source = 'TRANS'
         AND TRIM(' ' FROM atc.col_name) LIKE 'A%T_URE_ID';
    v_an         t_an;
    v_trans_err  trans_err%ROWTYPE;
    v_account    account%ROWTYPE;
    v_dt_account account%ROWTYPE;
    v_ct_account account%ROWTYPE;
  BEGIN
    v_trans_err.trans_err_id := 0;
    v_trans_err.trans        := NULL;
    v_trans_err.trans_templ  := NULL;
    v_trans_err.trans_date   := NULL;
    v_trans_err.acc_fund     := NULL;
    v_trans_err.recalc_fund  := NULL;
    v_trans_err.acc_amount   := NULL;
    v_trans_err.base_fund    := NULL;
    v_trans_err.rate_type    := NULL;
    v_trans_err.dt_account   := NULL;
    v_trans_err.ct_account   := NULL;
    --Найти шаблон проводки
    BEGIN
      SELECT * INTO v_trans_templ FROM trans_templ tt WHERE tt.trans_templ_id = p_trans_templ_id;
      SELECT tt.date_type_id
        INTO v_trans_templ.date_type_id
        FROM trans_templ tt
       WHERE tt.trans_templ_id = nvl(p_templ_date_investor, p_trans_templ_id);
      v_trans_err.trans_templ := v_trans_templ.name;
    EXCEPTION
      WHEN OTHERS THEN
        v_trans_err.trans_err_id := 1;
        v_trans_err.trans_templ  := '<неизвестный> ИД=' || to_char(p_trans_templ_id);
    END;
  
    IF v_trans_err.trans_err_id = 0
    THEN
      --автономер
      SELECT sq_trans.nextval INTO v_trans.trans_id FROM dual;
      --документ
      SELECT d.ent_id
            ,o.document_id
        INTO v_doc_ent_id
            ,v_document_id
        FROM oper     o
            ,document d
       WHERE o.oper_id = p_oper_id
         AND o.document_id = d.document_id;
      --дата проведения
      BEGIN
        v_trans.trans_date := nvl(p_date
                                 ,get_date_type(v_doc_ent_id
                                               ,v_document_id
                                               ,v_trans_templ.date_type_id));
      EXCEPTION
        WHEN OTHERS THEN
          raise_application_error(-20100
                                 ,'Ошибка получения даты проводки. ИД шаблона= ' || p_trans_templ_id || '.' ||
                                  SQLERRM);
      END;
    
      -- oper day
      /*    if pkg_oper_day.get_date_status(v_Trans.Trans_Date)=1 then
            v_Trans_Err.Trans_Err_Id := 1;
            v_Trans_Err.trans_date   := to_char(v_Trans.Trans_Date, 'dd.mm.yyyy') || ' в закрытом дне';
          end if;
      */ -- oper day
    
      /*    --схема расчетов
          begin
            select df.settlement_scheme_id into v_Settlement_Scheme_ID from Doc_Fto df where df.doc_fto_id = v_document_id;
          exception when others then
            v_Settlement_Scheme_ID := null;
          end;
      */
    
      v_settlement_scheme_id := NULL;
    
      IF v_trans.trans_date IS NULL
      THEN
        BEGIN
          SELECT dt.name
            INTO v_temp_str_1
            FROM date_type dt
           WHERE dt.date_type_id = v_trans_templ.date_type_id;
        EXCEPTION
          WHEN OTHERS THEN
            v_temp_str_1 := '<неизвестный>';
        END;
        v_trans_err.trans_err_id := 1;
        v_trans_err.trans_date   := v_temp_str_1 || ', ИД=' || to_char(v_trans_templ.date_type_id);
      END IF;
      --валюта счета
      -- TODO: поменять на нужную функцию
      --      dbms_output.put_line('Вал:' || v_doc_ent_id || '-' || v_document_id || '-' || v_Trans_Templ.Fund_Type_Id);
      v_trans.acc_fund_id := get_fund_type(v_doc_ent_id, v_document_id, v_trans_templ.fund_type_id);
      IF v_trans.acc_fund_id IS NULL
      THEN
        BEGIN
          SELECT ft.name
            INTO v_temp_str_1
            FROM fund_type ft
           WHERE ft.fund_type_id = v_trans_templ.fund_type_id;
        EXCEPTION
          WHEN OTHERS THEN
            v_temp_str_1 := '<неизвестный>';
        END;
        v_trans_err.trans_err_id := 1;
        v_trans_err.acc_fund     := v_temp_str_1 || ', ИД=' || to_char(v_trans_templ.fund_type_id);
      END IF;
      --валюта пересчета суммы
      -- TODO: поменять на нужную функцию
      v_recalc_fund_id := get_fund_type(v_doc_ent_id, v_document_id, v_trans_templ.summ_fund_type_id);
      IF v_recalc_fund_id IS NULL
      THEN
        BEGIN
          SELECT ft.name
            INTO v_temp_str_1
            FROM fund_type ft
           WHERE ft.fund_type_id = v_trans_templ.summ_fund_type_id;
        EXCEPTION
          WHEN OTHERS THEN
            v_temp_str_1 := '<неизвестный>';
        END;
        v_trans_err.trans_err_id := 1;
        v_trans_err.recalc_fund  := v_temp_str_1 || ', ИД=' ||
                                    to_char(v_trans_templ.summ_fund_type_id);
      END IF;
      --сумма в валюте счета
      -- TODO: поменять на нужную функцию
      v_trans.acc_amount := nvl(p_summ
                               ,get_summ_type(p_service_ent_id
                                             ,p_service_obj_id
                                             ,v_trans_templ.summ_type_id));
      IF v_trans.acc_amount IS NULL
      THEN
        BEGIN
          SELECT st.name
            INTO v_temp_str_1
            FROM summ_type st
           WHERE st.summ_type_id = v_trans_templ.summ_type_id;
        EXCEPTION
          WHEN OTHERS THEN
            v_temp_str_1 := '<неизвестный>';
        END;
        v_trans_err.trans_err_id := 1;
        v_trans_err.acc_amount   := v_temp_str_1 || ', ИД=' || to_char(v_trans_templ.summ_type_id);
      ELSIF v_trans.acc_amount = 0
      THEN
        BEGIN
          SELECT st.name
            INTO v_temp_str_1
            FROM summ_type st
           WHERE st.summ_type_id = v_trans_templ.summ_type_id;
        EXCEPTION
          WHEN OTHERS THEN
            v_temp_str_1 := '<неизвестный>';
        END;
        v_trans_err.trans_err_id := 1;
        v_trans_err.acc_amount   := 'сумма=0, ' || v_temp_str_1 || ', ИД=' ||
                                    to_char(v_trans_templ.summ_type_id);
      END IF;
      v_trans.trans_quantity    := nvl(p_qty
                                      ,get_summ_type(p_service_ent_id
                                                    ,p_service_obj_id
                                                    ,v_trans_templ.qty_type_id));
      v_trans_templ.is_accepted := p_is_accepted;
      --DBMS_OUTPUT.PUT_LINE('v_Trans.Trans_Fund_Id = ' || v_Trans.Trans_Fund_Id || '  ' || v_Trans.Acc_Fund_Id);
      IF (v_trans_err.trans_err_id = 0)
      THEN
        --план счетов, валюта плана счетов
        SELECT act.base_fund_id
          INTO v_trans.trans_fund_id
          FROM acc_chart_type act
         WHERE v_trans_templ.acc_chart_type_id = act.acc_chart_type_id;
        --ИД Типа курса Курс ЦБ
        SELECT rt.rate_type_id INTO v_rate_type_id FROM rate_type rt WHERE rt.brief = 'ЦБ';
        --курс пересчета, сумма пересчета
        IF (v_recalc_fund_id <> v_trans.acc_fund_id)
        THEN
          -- Валюта проводки(баланса) не соответствует валюте рассчета(Для МСФО в USD)
          v_recalc_rate        := get_rate_by_id(v_rate_type_id, v_recalc_fund_id, v_trans.trans_date);
          v_trans.acc_amount   := v_trans.acc_amount * v_recalc_rate;
          v_trans.acc_amount   := ROUND(v_trans.acc_amount * 100) / 100;
          v_trans.trans_amount := v_trans.acc_amount;
          v_trans.acc_amount   := v_trans.acc_amount / v_recalc_rate;
          v_trans.acc_amount   := ROUND(v_trans.acc_amount * 100) / 100;
          v_trans.acc_rate     := v_trans.trans_amount / v_trans.acc_amount;
        ELSE
          -- Валюта проводки(баланса)=валюте рассчета
          --курс приведения, сумма приведения
          IF (v_trans.trans_fund_id = v_trans.acc_fund_id)
          THEN
            v_trans.trans_amount := v_trans.acc_amount;
            v_trans.acc_rate     := 1;
          ELSE
            -- Если платежный документ или документ по зачету,
            -- то брать курс пересчета с документа
            IF ent.brief_by_id(v_doc_ent_id) = 'AC_PAYMENT'
            THEN
              SELECT rev_rate INTO v_rate FROM ac_payment WHERE payment_id = v_document_id;
            ELSIF ent.brief_by_id(v_doc_ent_id) = 'DOC_SET_OFF'
            THEN
              SELECT set_off_rate INTO v_rate FROM doc_set_off WHERE doc_set_off_id = v_document_id;
            ELSE
              v_rate := acc.get_rate_by_id(v_rate_type_id, v_trans.acc_fund_id, v_trans.trans_date);
            END IF;
          
            IF v_rate > 0
            THEN
            
              v_trans.trans_amount := v_trans.acc_amount * v_rate;
              v_trans.trans_amount := ROUND(v_trans.trans_amount * 100) / 100;
              v_trans.acc_rate     := v_rate;
            ELSE
              v_trans.trans_amount := v_trans.acc_amount;
              v_trans.acc_rate     := 1;
            END IF;
          END IF;
        END IF;
      
        --счет по дебету
        IF v_trans_templ.dt_account_id IS NOT NULL
        THEN
          --Указан конкретный счет
          v_trans.dt_account_id := v_trans_templ.dt_account_id;
          SELECT * INTO v_account FROM account a WHERE a.account_id = v_trans_templ.dt_account_id;
          --Если план счетов счета не идентичен плану счетов проводки,
          --то найти счет по маске
          IF v_trans_templ.acc_chart_type_id <> v_account.acc_chart_type_id
          THEN
            v_trans.dt_account_id := get_account_by_mask(v_trans.dt_account_id
                                                        ,v_account.acc_chart_type_id
                                                        ,v_trans_templ.acc_chart_type_id);
            IF v_trans.dt_account_id IS NULL
            THEN
              BEGIN
                SELECT act.name
                  INTO v_temp_str_1
                  FROM acc_chart_type act
                 WHERE act.acc_chart_type_id = v_trans_templ.acc_chart_type_id;
              EXCEPTION
                WHEN OTHERS THEN
                  v_temp_str_1 := '<неизвестный>';
              END;
              v_trans_err.trans_err_id := 1;
              v_trans_err.dt_account   := 'Счет ' || v_account.num || ', ИД=' ||
                                          to_char(v_account.account_id) ||
                                          ', приведенный к плану счетов ' || v_temp_str_1 || ', ИД=' ||
                                          to_char(v_trans_templ.acc_chart_type_id);
            END IF;
          END IF;
        ELSE
          IF v_trans_templ.dt_acc_type_templ_id IS NOT NULL
          THEN
            v_trans.dt_account_id := get_acc_by_acc_type(v_trans_templ.dt_acc_type_templ_id
                                                        ,v_trans_templ.dt_rev_acc_chart_type_id
                                                        ,v_settlement_scheme_id
                                                        ,v_document_id);
            IF v_trans.dt_account_id IS NULL
            THEN
              BEGIN
                SELECT att.name
                  INTO v_temp_str_1
                  FROM acc_type_templ att
                 WHERE att.acc_type_templ_id = v_trans_templ.dt_acc_type_templ_id;
              EXCEPTION
                WHEN OTHERS THEN
                  v_temp_str_1 := '<неизвестный>';
              END;
              BEGIN
                SELECT act.name
                  INTO v_temp_str_2
                  FROM acc_chart_type act
                 WHERE act.acc_chart_type_id = v_trans_templ.dt_rev_acc_chart_type_id;
              EXCEPTION
                WHEN OTHERS THEN
                  v_temp_str_2 := '<неизвестный>';
              END;
              v_trans_err.trans_err_id := 1;
              v_trans_err.dt_account   := 'Тип счета ' || v_temp_str_1 || ', ИД=' ||
                                          to_char(v_trans_templ.dt_acc_type_templ_id) ||
                                          ', по плану счетов ' || v_temp_str_2 || ', ИД=' ||
                                          to_char(v_trans_templ.dt_rev_acc_chart_type_id);
            ELSE
              --Если счет найден, но его план счетов не идентичен плану счетов проводки,
              --то найти счет по маске
              IF v_trans_templ.acc_chart_type_id <> v_trans_templ.dt_rev_acc_chart_type_id
              THEN
                v_trans.dt_account_id := get_account_by_mask(v_trans.dt_account_id
                                                            ,v_trans_templ.dt_rev_acc_chart_type_id
                                                            ,v_trans_templ.acc_chart_type_id);
                IF v_trans.dt_account_id IS NULL
                THEN
                  BEGIN
                    SELECT att.name
                      INTO v_temp_str_1
                      FROM acc_type_templ att
                     WHERE att.acc_type_templ_id = v_trans_templ.dt_acc_type_templ_id;
                  EXCEPTION
                    WHEN OTHERS THEN
                      v_temp_str_1 := '<неизвестный>';
                  END;
                  BEGIN
                    SELECT act.name
                      INTO v_temp_str_2
                      FROM acc_chart_type act
                     WHERE act.acc_chart_type_id = v_trans_templ.acc_chart_type_id;
                  EXCEPTION
                    WHEN OTHERS THEN
                      v_temp_str_2 := '<неизвестный>';
                  END;
                  v_trans_err.trans_err_id := 1;
                  v_trans_err.dt_account   := 'Тип счета ' || v_temp_str_1 || ', ИД=' ||
                                              to_char(v_trans_templ.dt_acc_type_templ_id) ||
                                              ', приведенный к плану счетов ' || v_temp_str_2 ||
                                              ', ИД=' || to_char(v_trans_templ.acc_chart_type_id);
                END IF;
              END IF;
            END IF;
          ELSE
            IF v_trans_templ.dt_uro_id IS NOT NULL
            THEN
              --В МОС подставляется конкретный объект
              v_trans.dt_account_id := get_acc_by_acc_def_rule(v_trans_templ.dt_acc_def_rule_id
                                                              ,v_trans_templ.dt_ure_id
                                                              ,v_trans_templ.dt_uro_id
                                                              ,v_trans.acc_fund_id
                                                              ,v_trans.trans_date
                                                              ,v_document_id);
            ELSE
              IF p_service_obj_id IS NOT NULL
              THEN
                --В МОС подставляется объект-параметр
                v_trans.dt_account_id := get_acc_by_acc_def_rule(v_trans_templ.dt_acc_def_rule_id
                                                                ,p_service_ent_id
                                                                ,p_service_obj_id
                                                                ,v_trans.acc_fund_id
                                                                ,v_trans.trans_date
                                                                ,v_document_id);
              ELSE
                --В МОС подставляется документ
                v_trans.dt_account_id := get_acc_by_acc_def_rule(v_trans_templ.dt_acc_def_rule_id
                                                                ,NULL
                                                                ,v_document_id
                                                                ,v_trans.acc_fund_id
                                                                ,v_trans.trans_date
                                                                ,v_document_id);
              END IF;
            END IF;
            IF v_trans.dt_account_id IS NOT NULL
            THEN
              --Если счет найден, но его план счетов не идентичен плану счетов проводки,
              --то найти счет по маске
              IF v_trans_templ.acc_chart_type_id <> v_trans_templ.dt_rev_acc_chart_type_id
              THEN
                v_trans.dt_account_id := get_account_by_mask(v_trans.dt_account_id
                                                            ,v_trans_templ.dt_rev_acc_chart_type_id
                                                            ,v_trans_templ.acc_chart_type_id);
                IF v_trans.dt_account_id IS NULL
                THEN
                  BEGIN
                    SELECT adr.name
                      INTO v_temp_str_1
                      FROM acc_def_rule adr
                     WHERE adr.acc_def_rule_id = v_trans_templ.dt_acc_def_rule_id;
                  EXCEPTION
                    WHEN OTHERS THEN
                      v_temp_str_1 := '<неизвестный>';
                  END;
                  BEGIN
                    SELECT act.name
                      INTO v_temp_str_2
                      FROM acc_chart_type act
                     WHERE act.acc_chart_type_id = v_trans_templ.acc_chart_type_id;
                  EXCEPTION
                    WHEN OTHERS THEN
                      v_temp_str_2 := '<неизвестный>';
                  END;
                  v_trans_err.trans_err_id := 1;
                  v_trans_err.dt_account   := 'Счет по М.О.С. ' || v_temp_str_1 || ', ИД=' ||
                                              to_char(v_trans_templ.dt_acc_type_templ_id) ||
                                              ', приведенный к плану счетов ' || v_temp_str_2 ||
                                              ', ИД=' || to_char(v_trans_templ.acc_chart_type_id);
                END IF;
              END IF;
            ELSE
              BEGIN
                SELECT adr.name
                  INTO v_temp_str_1
                  FROM acc_def_rule adr
                 WHERE adr.acc_def_rule_id = v_trans_templ.dt_acc_def_rule_id;
              EXCEPTION
                WHEN OTHERS THEN
                  v_temp_str_1 := '<неизвестный>';
              END;
              v_trans_err.trans_err_id := 1;
              v_trans_err.dt_account   := 'М.О.С. ' || v_temp_str_1 || ', ИД=' ||
                                          to_char(v_trans_templ.dt_acc_def_rule_id);
            END IF;
          END IF;
        END IF;
        --счет по кредиту
        IF v_trans_templ.ct_account_id IS NOT NULL
        THEN
          --Указан конкретный счет
          v_trans.ct_account_id := v_trans_templ.ct_account_id;
          SELECT * INTO v_account FROM account a WHERE a.account_id = v_trans_templ.ct_account_id;
          --Если план счетов счета не идентичен плану счетов проводки,
          --то найти счет по маске
          IF v_trans_templ.acc_chart_type_id <> v_account.acc_chart_type_id
          THEN
            v_trans.ct_account_id := get_account_by_mask(v_trans.ct_account_id
                                                        ,v_account.acc_chart_type_id
                                                        ,v_trans_templ.acc_chart_type_id);
            IF v_trans.ct_account_id IS NULL
            THEN
              BEGIN
                SELECT act.name
                  INTO v_temp_str_1
                  FROM acc_chart_type act
                 WHERE act.acc_chart_type_id = v_trans_templ.acc_chart_type_id;
              EXCEPTION
                WHEN OTHERS THEN
                  v_temp_str_1 := '<неизвестный>';
              END;
              v_trans_err.trans_err_id := 1;
              v_trans_err.ct_account   := 'Счет ' || v_account.num || ', ИД=' ||
                                          to_char(v_account.account_id) ||
                                          ', приведенный к плану счетов ' || v_temp_str_1 || ', ИД=' ||
                                          to_char(v_trans_templ.acc_chart_type_id);
            END IF;
          END IF;
        ELSE
          IF v_trans_templ.ct_acc_type_templ_id IS NOT NULL
          THEN
            v_trans.ct_account_id := get_acc_by_acc_type(v_trans_templ.ct_acc_type_templ_id
                                                        ,v_trans_templ.ct_rev_acc_chart_type_id
                                                        ,v_settlement_scheme_id
                                                        ,v_document_id);
            IF v_trans.ct_account_id IS NULL
            THEN
              BEGIN
                SELECT att.name
                  INTO v_temp_str_1
                  FROM acc_type_templ att
                 WHERE att.acc_type_templ_id = v_trans_templ.ct_acc_type_templ_id;
              EXCEPTION
                WHEN OTHERS THEN
                  v_temp_str_1 := '<неизвестный>';
              END;
              BEGIN
                SELECT act.name
                  INTO v_temp_str_2
                  FROM acc_chart_type act
                 WHERE act.acc_chart_type_id = v_trans_templ.ct_rev_acc_chart_type_id;
              EXCEPTION
                WHEN OTHERS THEN
                  v_temp_str_2 := '<неизвестный>';
              END;
              v_trans_err.trans_err_id := 1;
              v_trans_err.ct_account   := 'Тип счета ' || v_temp_str_1 || ', ИД=' ||
                                          to_char(v_trans_templ.ct_acc_type_templ_id) ||
                                          ', по плану счетов ' || v_temp_str_2 || ', ИД=' ||
                                          to_char(v_trans_templ.ct_rev_acc_chart_type_id);
            ELSE
              --Если счет найден, но его план счетов не идентичен плану счетов проводки,
              --то найти счет по маске
              IF v_trans_templ.acc_chart_type_id <> v_trans_templ.ct_rev_acc_chart_type_id
              THEN
                v_trans.ct_account_id := get_account_by_mask(v_trans.ct_account_id
                                                            ,v_trans_templ.ct_rev_acc_chart_type_id
                                                            ,v_trans_templ.acc_chart_type_id);
                IF v_trans.ct_account_id IS NULL
                THEN
                  BEGIN
                    SELECT att.name
                      INTO v_temp_str_1
                      FROM acc_type_templ att
                     WHERE att.acc_type_templ_id = v_trans_templ.ct_acc_type_templ_id;
                  EXCEPTION
                    WHEN OTHERS THEN
                      v_temp_str_1 := '<неизвестный>';
                  END;
                  BEGIN
                    SELECT act.name
                      INTO v_temp_str_2
                      FROM acc_chart_type act
                     WHERE act.acc_chart_type_id = v_trans_templ.acc_chart_type_id;
                  EXCEPTION
                    WHEN OTHERS THEN
                      v_temp_str_2 := '<неизвестный>';
                  END;
                  v_trans_err.trans_err_id := 1;
                  v_trans_err.ct_account   := 'Тип счета ' || v_temp_str_1 || ', ИД=' ||
                                              to_char(v_trans_templ.dt_acc_type_templ_id) ||
                                              ', приведенный к плану счетов ' || v_temp_str_2 ||
                                              ', ИД=' || to_char(v_trans_templ.acc_chart_type_id);
                END IF;
              END IF;
            END IF;
          ELSE
            IF v_trans_templ.ct_uro_id IS NOT NULL
            THEN
              --В МОС подставляется конкретный объект
              v_trans.ct_account_id := get_acc_by_acc_def_rule(v_trans_templ.ct_acc_def_rule_id
                                                              ,v_trans_templ.ct_ure_id
                                                              ,v_trans_templ.ct_uro_id
                                                              ,v_trans.acc_fund_id
                                                              ,v_trans.trans_date
                                                              ,v_document_id);
            ELSE
              IF p_service_obj_id IS NOT NULL
              THEN
                --В МОС подставляется объект-параметр
                v_trans.ct_account_id := acc.get_acc_by_acc_def_rule(v_trans_templ.ct_acc_def_rule_id
                                                                    ,p_service_ent_id
                                                                    ,p_service_obj_id
                                                                    ,v_trans.acc_fund_id
                                                                    ,v_trans.trans_date
                                                                    ,v_document_id);
              ELSE
                --В МОС подставляется документ
                v_trans.ct_account_id := acc.get_acc_by_acc_def_rule(v_trans_templ.ct_acc_def_rule_id
                                                                    ,NULL
                                                                    ,v_document_id
                                                                    ,v_trans.acc_fund_id
                                                                    ,v_trans.trans_date
                                                                    ,v_document_id);
              END IF;
            END IF;
            IF v_trans.ct_account_id IS NOT NULL
            THEN
              --Если счет найден, но его план счетов не идентичен плану счетов проводки,
              --то найти счет по маске
              IF v_trans_templ.acc_chart_type_id <> v_trans_templ.ct_rev_acc_chart_type_id
              THEN
                v_trans.ct_account_id := get_account_by_mask(v_trans.ct_account_id
                                                            ,v_trans_templ.ct_rev_acc_chart_type_id
                                                            ,v_trans_templ.acc_chart_type_id);
                IF v_trans.ct_account_id IS NULL
                THEN
                  BEGIN
                    SELECT adr.name
                      INTO v_temp_str_1
                      FROM acc_def_rule adr
                     WHERE adr.acc_def_rule_id = v_trans_templ.ct_acc_def_rule_id;
                  EXCEPTION
                    WHEN OTHERS THEN
                      v_temp_str_1 := '<неизвестный>';
                  END;
                  BEGIN
                    SELECT act.name
                      INTO v_temp_str_2
                      FROM acc_chart_type act
                     WHERE act.acc_chart_type_id = v_trans_templ.acc_chart_type_id;
                  EXCEPTION
                    WHEN OTHERS THEN
                      v_temp_str_2 := '<неизвестный>';
                  END;
                  v_trans_err.trans_err_id := 1;
                  v_trans_err.ct_account   := 'Счет по М.О.С. ' || v_temp_str_1 || ', ИД=' ||
                                              to_char(v_trans_templ.ct_acc_type_templ_id) ||
                                              ', приведенный к плану счетов ' || v_temp_str_2 ||
                                              ', ИД=' || to_char(v_trans_templ.acc_chart_type_id);
                END IF;
              END IF;
            ELSE
              BEGIN
                SELECT adr.name
                  INTO v_temp_str_1
                  FROM acc_def_rule adr
                 WHERE adr.acc_def_rule_id = v_trans_templ.ct_acc_def_rule_id;
              EXCEPTION
                WHEN OTHERS THEN
                  v_temp_str_1 := '<неизвестный>';
              END;
              v_trans_err.trans_err_id := 1;
              v_trans_err.ct_account   := 'М.О.С. ' || v_temp_str_1 || ', ИД=' ||
                                          to_char(v_trans_templ.ct_acc_def_rule_id);
            END IF;
          END IF;
        END IF;
      END IF;
    
      --Проверка на равенства счета дебета и кредита
      IF (v_trans_err.trans_err_id = 0)
      THEN
        IF (v_trans.dt_account_id = v_trans.ct_account_id)
        THEN
          SELECT a.num INTO v_temp_str_1 FROM account a WHERE a.account_id = v_trans.dt_account_id;
          v_trans_err.trans_err_id := 1;
          v_trans_err.dt_account   := 'Одинаковые счета по ДТ/КТ №' || v_temp_str_1 || ', ИД=' ||
                                      to_char(v_trans.dt_account_id);
          v_trans_err.ct_account   := 'Одинаковые счета по ДТ/КТ №' || v_temp_str_1 || ', ИД=' ||
                                      to_char(v_trans.dt_account_id);
        END IF;
      END IF;
    
      IF (v_trans_err.trans_err_id = 0)
      THEN
        --Определение аналитик по счетам
        SELECT * INTO v_dt_account FROM account a WHERE a.account_id = v_trans.dt_account_id;
        SELECT * INTO v_ct_account FROM account a WHERE a.account_id = v_trans.ct_account_id;
        OPEN c_an;
        LOOP
          FETCH c_an
            INTO v_an;
          EXIT WHEN c_an%NOTFOUND;
          BEGIN
            CASE
              WHEN v_an.corr = 'D'
                   AND v_an.a_num = '1' THEN
                IF (v_dt_account.a1_uro_id IS NULL)
                THEN
                  get_analytic(v_trans.dt_account_id
                              ,1
                              ,p_service_ent_id
                              ,p_service_obj_id
                              ,v_trans.a1_dt_ure_id
                              ,v_trans.a1_dt_uro_id);
                
                  /*                 v_Trans.a1_dt_ure_id := Get_Analytic_Entity_ID(v_Trans.Dt_Account_Id,
                                                                                   1);
                                    v_Trans.a1_dt_uro_id := Get_Analytic_Object_ID(v_Trans.Dt_Account_Id,
                                                                                   1,
                                                                                   p_service_ent_ID,
                                                                                   p_service_obj_id);
                  */
                ELSE
                  v_trans.a1_dt_ure_id := v_dt_account.a1_ure_id;
                  v_trans.a1_dt_uro_id := v_dt_account.a1_uro_id;
                END IF;
              WHEN v_an.corr = 'D'
                   AND v_an.a_num = '2' THEN
                IF (v_dt_account.a2_uro_id IS NULL)
                THEN
                  get_analytic(v_trans.dt_account_id
                              ,2
                              ,p_service_ent_id
                              ,p_service_obj_id
                              ,v_trans.a2_dt_ure_id
                              ,v_trans.a2_dt_uro_id);
                  /*                  v_Trans.a2_dt_ure_id := Get_Analytic_Entity_ID(v_Trans.Dt_Account_Id,
                                                                                   2);
                                    v_Trans.a2_dt_uro_id := Get_Analytic_Object_ID(v_Trans.Dt_Account_Id,
                                                                                   2,
                                                                                   p_service_ent_ID,
                                                                                   p_service_obj_id);
                  */
                ELSE
                  v_trans.a2_dt_ure_id := v_dt_account.a2_ure_id;
                  v_trans.a2_dt_uro_id := v_dt_account.a2_uro_id;
                END IF;
              WHEN v_an.corr = 'D'
                   AND v_an.a_num = '3' THEN
                IF (v_dt_account.a3_uro_id IS NULL)
                THEN
                  get_analytic(v_trans.dt_account_id
                              ,3
                              ,p_service_ent_id
                              ,p_service_obj_id
                              ,v_trans.a3_dt_ure_id
                              ,v_trans.a3_dt_uro_id);
                  /*                  v_Trans.a3_dt_ure_id := Get_Analytic_Entity_ID(v_Trans.Dt_Account_Id,
                                                                                   3);
                                    v_Trans.a3_dt_uro_id := Get_Analytic_Object_ID(v_Trans.Dt_Account_Id,
                                                                                   3,
                                                                                   p_service_ent_ID,
                                                                                   p_service_obj_id);
                  */
                ELSE
                  v_trans.a3_dt_ure_id := v_dt_account.a3_ure_id;
                  v_trans.a3_dt_uro_id := v_dt_account.a3_uro_id;
                END IF;
              WHEN v_an.corr = 'D'
                   AND v_an.a_num = '4' THEN
                IF (v_dt_account.a4_uro_id IS NULL)
                THEN
                  get_analytic(v_trans.dt_account_id
                              ,4
                              ,p_service_ent_id
                              ,p_service_obj_id
                              ,v_trans.a4_dt_ure_id
                              ,v_trans.a4_dt_uro_id);
                  /*                  v_Trans.a4_dt_ure_id := Get_Analytic_Entity_ID(v_Trans.Dt_Account_Id,
                                                                                   4);
                                    v_Trans.a4_dt_uro_id := Get_Analytic_Object_ID(v_Trans.Dt_Account_Id,
                                                                                   4,
                                                                                   p_service_ent_ID,
                                                                                   p_service_obj_id);
                  */
                ELSE
                  v_trans.a4_dt_ure_id := v_dt_account.a4_ure_id;
                  v_trans.a4_dt_uro_id := v_dt_account.a4_uro_id;
                END IF;
              WHEN v_an.corr = 'D'
                   AND v_an.a_num = '5' THEN
                IF (v_dt_account.a5_uro_id IS NULL)
                THEN
                  get_analytic(v_trans.dt_account_id
                              ,5
                              ,p_service_ent_id
                              ,p_service_obj_id
                              ,v_trans.a5_dt_ure_id
                              ,v_trans.a5_dt_uro_id);
                  /*
                                    v_Trans.a5_dt_ure_id := Get_Analytic_Entity_ID(v_Trans.Dt_Account_Id,
                                                                                   5);
                                    v_Trans.a5_dt_uro_id := Get_Analytic_Object_ID(v_Trans.Dt_Account_Id,
                                                                                   5,
                                                                                   p_service_ent_ID,
                                                                                   p_service_obj_id);
                  */
                ELSE
                  v_trans.a5_dt_ure_id := v_dt_account.a5_ure_id;
                  v_trans.a5_dt_uro_id := v_dt_account.a5_uro_id;
                END IF;
              WHEN v_an.corr = 'C'
                   AND v_an.a_num = '1' THEN
                IF (v_ct_account.a1_uro_id IS NULL)
                THEN
                  get_analytic(v_trans.ct_account_id
                              ,1
                              ,p_service_ent_id
                              ,p_service_obj_id
                              ,v_trans.a1_ct_ure_id
                              ,v_trans.a1_ct_uro_id);
                  /*                  v_Trans.a1_Ct_ure_id := Get_Analytic_Entity_ID(v_Trans.Ct_Account_Id,
                                                                                   1);
                                    v_Trans.a1_Ct_uro_id := Get_Analytic_Object_ID(v_Trans.Ct_Account_Id,
                                                                                   1,
                                                                                   p_service_ent_ID,
                                                                                   p_service_obj_id);
                  */
                ELSE
                  v_trans.a1_ct_ure_id := v_ct_account.a1_ure_id;
                  v_trans.a1_ct_uro_id := v_ct_account.a1_uro_id;
                END IF;
              WHEN v_an.corr = 'C'
                   AND v_an.a_num = '2' THEN
                IF (v_ct_account.a2_uro_id IS NULL)
                THEN
                  get_analytic(v_trans.ct_account_id
                              ,2
                              ,p_service_ent_id
                              ,p_service_obj_id
                              ,v_trans.a2_ct_ure_id
                              ,v_trans.a2_ct_uro_id);
                  /*                  v_Trans.a2_Ct_ure_id := Get_Analytic_Entity_ID(v_Trans.Ct_Account_Id,
                                                                                   2);
                                    v_Trans.a2_Ct_uro_id := Get_Analytic_Object_ID(v_Trans.Ct_Account_Id,
                                                                                   2,
                                                                                   p_service_ent_ID,
                                                                                   p_service_obj_id);
                  */
                ELSE
                  v_trans.a2_ct_ure_id := v_ct_account.a2_ure_id;
                  v_trans.a2_ct_uro_id := v_ct_account.a2_uro_id;
                END IF;
              WHEN v_an.corr = 'C'
                   AND v_an.a_num = '3' THEN
                IF (v_ct_account.a3_uro_id IS NULL)
                THEN
                  get_analytic(v_trans.ct_account_id
                              ,3
                              ,p_service_ent_id
                              ,p_service_obj_id
                              ,v_trans.a3_ct_ure_id
                              ,v_trans.a3_ct_uro_id);
                
                  /*                  v_Trans.a3_Ct_ure_id := Get_Analytic_Entity_ID(v_Trans.Ct_Account_Id,
                                                                                   3);
                                    v_Trans.a3_Ct_uro_id := Get_Analytic_Object_ID(v_Trans.Ct_Account_Id,
                                                                                   3,
                                                                                   p_service_ent_ID,
                                                                                   p_service_obj_id);
                  */
                ELSE
                  v_trans.a3_ct_ure_id := v_ct_account.a3_ure_id;
                  v_trans.a3_ct_uro_id := v_ct_account.a3_uro_id;
                END IF;
              WHEN v_an.corr = 'C'
                   AND v_an.a_num = '4' THEN
                IF (v_ct_account.a4_uro_id IS NULL)
                THEN
                  get_analytic(v_trans.ct_account_id
                              ,4
                              ,p_service_ent_id
                              ,p_service_obj_id
                              ,v_trans.a4_ct_ure_id
                              ,v_trans.a4_ct_uro_id);
                
                  /*                  v_Trans.a4_Ct_ure_id := Get_Analytic_Entity_ID(v_Trans.Ct_Account_Id,
                                                                                   4);
                                    v_Trans.a4_Ct_uro_id := Get_Analytic_Object_ID(v_Trans.Ct_Account_Id,
                                                                                   4,
                                                                                   p_service_ent_ID,
                                                                                   p_service_obj_id);
                  */
                ELSE
                  v_trans.a4_ct_ure_id := v_ct_account.a4_ure_id;
                  v_trans.a4_ct_uro_id := v_ct_account.a4_uro_id;
                END IF;
              WHEN v_an.corr = 'C'
                   AND v_an.a_num = '5' THEN
                IF (v_ct_account.a5_uro_id IS NULL)
                THEN
                  get_analytic(v_trans.ct_account_id
                              ,5
                              ,p_service_ent_id
                              ,p_service_obj_id
                              ,v_trans.a5_ct_ure_id
                              ,v_trans.a5_ct_uro_id);
                  /*                  v_Trans.a5_Ct_ure_id := Get_Analytic_Entity_ID(v_Trans.Ct_Account_Id,
                                                                                   5);
                                    v_Trans.a5_Ct_uro_id := Get_Analytic_Object_ID(v_Trans.Ct_Account_Id,
                                                                                   5,
                                                                                   p_service_ent_ID,
                                                                                   p_service_obj_id);
                  */
                ELSE
                  v_trans.a5_ct_ure_id := v_ct_account.a5_ure_id;
                  v_trans.a5_ct_uro_id := v_ct_account.a5_uro_id;
                END IF;
            END CASE;
          EXCEPTION
            WHEN OTHERS THEN
              dbms_output.put_line(SQLERRM);
          END;
        END LOOP;
        CLOSE c_an;
      END IF;
    END IF;
  
    -- определение объекта учета
    -- todo сделать в отдельной функции
    -- если покрытие, то объект учета
    -- тестовая реализация - пока это неверно, но позволяет проверить
    -- работу алгоритма
    v_trans.obj_ure_id := p_service_ent_id;
    v_trans.obj_uro_id := p_service_obj_id;
  
    /*if (p_service_ent_id = ent.id_by_brief('P_COVER')) then
       select pc.t_prod_line_option_id, a.p_asset_header_id into
         v_trans.obj_ure_id, v_trans.obj_uro_id
       from p_cover pc, as_asset a
       where pc.p_cover_id = p_service_obj_id
       and a.as_asset_id = pc.as_asset_id;
    end if;*/
  
    IF (v_trans_err.trans_err_id = 0)
    THEN
      INSERT INTO trans t
        (t.trans_id
        , --ok
         t.trans_date
        , --ok
         t.trans_fund_id
        , --ok
         t.trans_amount
        , --ok
         t.dt_account_id
        , --ok
         t.ct_account_id
        , --ok
         t.is_accepted
        , --ok
         t.a1_dt_ure_id
        ,t.a1_dt_uro_id
        ,t.a1_ct_ure_id
        ,t.a1_ct_uro_id
        ,t.a2_dt_ure_id
        ,t.a2_dt_uro_id
        ,t.a2_ct_ure_id
        ,t.a2_ct_uro_id
        ,t.a3_dt_ure_id
        ,t.a3_dt_uro_id
        ,t.a3_ct_ure_id
        ,t.a3_ct_uro_id
        ,t.a4_dt_ure_id
        ,t.a4_dt_uro_id
        ,t.a4_ct_ure_id
        ,t.a4_ct_uro_id
        ,t.a5_dt_ure_id
        ,t.a5_dt_uro_id
        ,t.a5_ct_ure_id
        ,t.a5_ct_uro_id
        ,t.trans_templ_id
        , --ok
         t.acc_chart_type_id
        , --ok
         t.acc_fund_id
        , --ok
         t.acc_amount
        , --ok
         t.acc_rate
        , --ok
         t.oper_id
        , --ok
         t.trans_quantity
        ,t.source
        ,t.note
        ,t.obj_ure_id
        ,t.obj_uro_id)
      VALUES
        (v_trans.trans_id
        , --ok
         v_trans.trans_date
        , --ok
         v_trans.trans_fund_id
        , --ok
         v_trans.trans_amount
        , --ok
         v_trans.dt_account_id
        , --ok
         v_trans.ct_account_id
        , --ok
         v_trans_templ.is_accepted
        , --ok
         v_trans.a1_dt_ure_id
        ,v_trans.a1_dt_uro_id
        ,v_trans.a1_ct_ure_id
        ,v_trans.a1_ct_uro_id
        ,v_trans.a2_dt_ure_id
        ,v_trans.a2_dt_uro_id
        ,v_trans.a2_ct_ure_id
        ,v_trans.a2_ct_uro_id
        ,v_trans.a3_dt_ure_id
        ,v_trans.a3_dt_uro_id
        ,v_trans.a3_ct_ure_id
        ,v_trans.a3_ct_uro_id
        ,v_trans.a4_dt_ure_id
        ,v_trans.a4_dt_uro_id
        ,v_trans.a4_ct_ure_id
        ,v_trans.a4_ct_uro_id
        ,v_trans.a5_dt_ure_id
        ,v_trans.a5_dt_uro_id
        ,v_trans.a5_ct_ure_id
        ,v_trans.a5_ct_uro_id
        ,p_trans_templ_id
        , --ok
         v_trans_templ.acc_chart_type_id
        , --ok
         v_trans.acc_fund_id
        , --ok
         v_trans.acc_amount
        , --ok
         v_trans.acc_rate
        , --ok
         p_oper_id
        , --ok
         nvl(v_trans.trans_quantity, 0)
        ,p_source
        ,acc.get_trans_note(p_trans_templ_id, p_oper_id)
        ,v_trans.obj_ure_id
        ,v_trans.obj_uro_id);
    ELSE
      INSERT INTO trans_err te
        (te.trans_err_id
        ,te.oper_id
        ,te.trans
        ,te.trans_templ
        ,te.trans_date
        ,te.acc_fund
        ,te.recalc_fund
        ,te.acc_amount
        ,te.base_fund
        ,te.rate_type
        ,te.dt_account
        ,te.ct_account
        ,te.source)
      VALUES
        (sq_trans_err.nextval
        ,p_oper_id
        ,v_trans_err.trans
        ,v_trans_err.trans_templ
        ,v_trans_err.trans_date
        ,v_trans_err.acc_fund
        ,v_trans_err.recalc_fund
        ,v_trans_err.acc_amount
        ,v_trans_err.base_fund
        ,v_trans_err.rate_type
        ,v_trans_err.dt_account
        ,v_trans_err.ct_account
        ,p_source);
    END IF;
  
    RETURN v_trans.trans_id;
  END;

  --Функция для создания операции по шаблону
  FUNCTION run_oper_by_template
  (
    p_oper_templ_id       NUMBER
   ,p_document_id         NUMBER
   ,p_service_ent_id      NUMBER DEFAULT NULL
   ,p_service_obj_id      NUMBER DEFAULT NULL
   ,p_doc_status_ref_id   NUMBER DEFAULT NULL
   ,p_is_accepted         NUMBER DEFAULT 1
   ,p_summ                NUMBER DEFAULT NULL
   ,p_source              VARCHAR2 DEFAULT 'INS'
   ,p_templ_date_investor NUMBER DEFAULT NULL
  ) RETURN NUMBER IS
    v_oper_id                 NUMBER;
    v_doc_status_ref_id       NUMBER;
    v_trans_templ_id          NUMBER;
    v_trans_templ_investor_id NUMBER;
    v_trans_id                trans%ROWTYPE;
    v_parent_id               NUMBER;
    v_parent_investor_id      NUMBER;
    v_sql                     VARCHAR2(4000);
    c_sum_type                SYS_REFCURSOR;
    v_st_date                 DATE;
    v_st_summ                 NUMBER;
    v_level                   NUMBER;
    v_level_investor          NUMBER;
    v_trans_err               trans_err%ROWTYPE;
    v_doc_ent_id              NUMBER;
    v_service_ent_id          NUMBER;
    v_service_obj_id          NUMBER;
    v_oper_date_type          NUMBER;
    v_oper_date               DATE;
    CURSOR c_rel_oper_trans_templ(cp_oper_templ_id NUMBER) IS
      SELECT LEVEL        x_level
            ,tt.id        id
            ,tt.parent_id parent_id
        FROM (SELECT NULL parent_id
                    ,0    id
                FROM oper_templ ot
               WHERE ot.oper_templ_id = cp_oper_templ_id
              UNION ALL
              SELECT DISTINCT nvl(rott.parent_id, 0) parent_id
                             ,rott.trans_templ_id id
                FROM rel_oper_trans_templ rott
               WHERE rott.oper_templ_id = cp_oper_templ_id) tt
       START WITH tt.parent_id IS NULL
      CONNECT BY PRIOR tt.id = tt.parent_id;
    CURSOR c_oper_trans_investor_templ(cp_oper_templ_id NUMBER) IS
      SELECT LEVEL        x_level
            ,tt.id        id
            ,tt.parent_id parent_id
        FROM (SELECT NULL parent_id
                    ,0    id
                FROM oper_templ ot
               WHERE ot.oper_templ_id = cp_oper_templ_id
              UNION ALL
              SELECT DISTINCT nvl(rott.parent_id, 0) parent_id
                             ,rott.trans_templ_id id
                FROM rel_oper_trans_templ rott
               WHERE rott.oper_templ_id = cp_oper_templ_id) tt
       START WITH tt.parent_id IS NULL
      CONNECT BY PRIOR tt.id = tt.parent_id;
    v_document   document%ROWTYPE;
    v_temp_str_1 VARCHAR2(150);
  
  BEGIN
    IF pkg_oper_function.get_oper_function_result(p_document_id
                                                 ,p_oper_templ_id
                                                 ,p_service_ent_id
                                                 ,p_service_obj_id) = 1
    THEN
    
      v_doc_status_ref_id := nvl(p_doc_status_ref_id, doc.get_doc_status_id(p_document_id));
      -- begin
      /*
        --Удалить операцию -- ни в коем случае. Если что-то удаляется из базы в
        -- результате отработки бизнес логики, значит,
        -- неправильно сделана постановка версионности (Иванов).
        begin
          delete Oper o
           where o.Document_Id = p_Document_ID
             and o.oper_templ_id = p_Oper_Templ_ID
             and o.doc_status_ref_id = v_Doc_Status_Ref_ID;
        exception
          when others then
            dbms_output.put_line(sqlerrm);
        end;
      */
      -- реальная сущность документа
      v_doc_ent_id := ent.get_obj_ent_id(ent.id_by_brief('DOCUMENT'), p_document_id);
      -- инициализируем объект учета (услуга)
      IF (p_service_ent_id IS NULL OR p_service_obj_id IS NULL)
      THEN
        v_service_ent_id := v_doc_ent_id;
        v_service_obj_id := p_document_id;
      ELSE
        v_service_ent_id := p_service_ent_id;
        v_service_obj_id := p_service_obj_id;
      END IF;
    
      --begin
      SELECT * INTO v_document FROM document d WHERE d.document_id = p_document_id;
      --exception
      --when others then
      --raise_application_error(-20000,'Документ не найден (id='||p_document_id||').');
      --end;
    
      --begin
      SELECT ot.date_type_id
        INTO v_oper_date_type
        FROM oper_templ ot
       WHERE ot.oper_templ_id = nvl(p_templ_date_investor, p_oper_templ_id);
    
      --   dbms_output.put_line(v_doc_ent_id || '-' || p_Document_ID || '-' || v_oper_date_type);
      BEGIN
        v_oper_date := get_date_type(v_doc_ent_id, p_document_id, v_oper_date_type);
      EXCEPTION
        WHEN OTHERS THEN
          raise_application_error(-20100
                                 ,'Ошибка получения даты операции. ИД шаблона= ' || p_oper_templ_id || '.' ||
                                  SQLERRM);
      END;
    
      --exception
      --when others then
      --raise_application_error(-20000,'Невозможно получить тип даты для шаблона операции.');
      --end;
    
      --Создать операцию по шаблону
      SELECT sq_oper.nextval INTO v_oper_id FROM dual;
      INSERT INTO oper o
        (o.oper_id
        ,o.name
        ,o.oper_templ_id
        ,o.document_id
        ,o.reg_date
        ,o.oper_date
        ,o.doc_status_ref_id)
      VALUES
        (v_oper_id
        ,(SELECT ot.name FROM oper_templ ot WHERE ot.oper_templ_id = p_oper_templ_id)
        ,p_oper_templ_id
        ,p_document_id
        ,SYSDATE
        ,
         -- changed
         -- тип даты с документа
         v_oper_date
        ,v_doc_status_ref_id);
      -- Создать проводки по шаблону операции
      OPEN c_rel_oper_trans_templ(p_oper_templ_id);
      LOOP
        v_trans_err.trans_err_id := 0;
        v_trans_err.trans        := NULL;
        v_trans_err.trans_templ  := NULL;
        v_trans_err.trans_date   := NULL;
        v_trans_err.acc_fund     := NULL;
        v_trans_err.recalc_fund  := NULL;
        v_trans_err.acc_amount   := NULL;
        v_trans_err.base_fund    := NULL;
        v_trans_err.rate_type    := NULL;
        v_trans_err.dt_account   := NULL;
        v_trans_err.ct_account   := NULL;
        FETCH c_rel_oper_trans_templ
          INTO v_level
              ,v_trans_templ_id
              ,v_parent_id;
        EXIT WHEN c_rel_oper_trans_templ%NOTFOUND;
        OPEN c_oper_trans_investor_templ(p_templ_date_investor);
        LOOP
          FETCH c_oper_trans_investor_templ
            INTO v_level_investor
                ,v_trans_templ_investor_id
                ,v_parent_investor_id;
          EXIT WHEN c_oper_trans_investor_templ%NOTFOUND;
        END LOOP;
        CLOSE c_oper_trans_investor_templ;
        --      dbms_output.put_line('Шаблон проводочки!');
      
        IF v_level >= 2
        THEN
          IF v_level > 2
          THEN
            BEGIN
              SELECT t.*
                INTO v_trans_id
                FROM trans t
               WHERE t.oper_id = v_oper_id
                 AND t.trans_templ_id = v_parent_id;
            EXCEPTION
              WHEN OTHERS THEN
                BEGIN
                  SELECT tt.name
                    INTO v_temp_str_1
                    FROM trans_templ tt
                   WHERE tt.trans_templ_id = v_parent_id;
                EXCEPTION
                  WHEN OTHERS THEN
                    v_temp_str_1 := '<неизвестный>';
                END;
                v_trans_err.trans_err_id := 1;
                v_trans_err.trans        := 'Не найдена исходная проводка по шаблону ' || v_temp_str_1 ||
                                            ', ИД=' || to_char(v_parent_id);
                BEGIN
                  SELECT tt.name
                    INTO v_temp_str_1
                    FROM trans_templ tt
                   WHERE tt.trans_templ_id = v_trans_templ_id;
                EXCEPTION
                  WHEN OTHERS THEN
                    v_temp_str_1 := '<неизвестный>';
                END;
                v_trans_err.trans_templ := v_temp_str_1 || ', ИД=' || to_char(v_parent_id);
            END;
          END IF;
        
          IF (v_trans_err.trans_err_id = 0)
          THEN
            BEGIN
              SELECT st.sql_query
                INTO v_sql
                FROM trans_templ tt
                    ,summ_type   st
               WHERE tt.trans_templ_id = v_trans_templ_id
                 AND tt.summ_type_id = st.summ_type_id;
            EXCEPTION
              WHEN no_data_found THEN
                NULL;
            END;
            IF p_summ IS NOT NULL
               OR v_sql IS NULL
            THEN
              v_trans_id.trans_id := acc_new.add_trans_by_template(v_trans_templ_id
                                                                  ,v_oper_id
                                                                  ,p_service_ent_id
                                                                  ,p_service_obj_id
                                                                  ,p_is_accepted
                                                                  ,NULL
                                                                  ,p_summ
                                                                  ,NULL
                                                                  ,p_source
                                                                  ,v_trans_templ_investor_id);
            ELSE
              OPEN c_sum_type FOR v_sql
                USING IN p_document_id;
              LOOP
                FETCH c_sum_type
                  INTO v_st_date
                      ,v_st_summ;
                EXIT WHEN c_sum_type%NOTFOUND;
                v_trans_id.trans_id := acc_new.add_trans_by_template(v_trans_templ_id
                                                                    ,v_oper_id
                                                                    ,p_service_ent_id
                                                                    ,p_service_obj_id
                                                                    ,p_is_accepted
                                                                    ,v_st_date
                                                                    ,v_st_summ
                                                                    ,NULL
                                                                    ,p_source);
              END LOOP;
              CLOSE c_sum_type;
            END IF;
          ELSE
            INSERT INTO trans_err te
              (te.trans_err_id, te.oper_id, te.trans, te.trans_templ, te.source)
            VALUES
              (sq_trans_err.nextval, v_oper_id, v_trans_err.trans, v_trans_err.trans_templ, p_source);
          END IF;
        END IF;
      
      END LOOP;
      CLOSE c_rel_oper_trans_templ;
      /*   exception
           when others then
             v_Oper_ID := 0;
         end;
      */
      -- commit;
    
      /*  --Произвести выгрузку в АБС
        open c_Trans;
        loop
          fetch c_Trans into v_Trans_ID;
          exit when c_Trans%notfound;
          --oper day
          if pkg_oper_day.get_date_status( v_Trans_ID.Trans_Date)=0 then
            macrobank_conv.Create_Doc(v_Trans_ID.Trans_Id);
          end if;
          --oper day
      
          --macrobank_conv.Create_Doc(v_Trans_ID.Trans_Id);
        end loop;
        close c_Trans;
      */
    
    ELSE
      v_oper_id := 0;
    END IF;
  
    RETURN v_oper_id;
  END;

  --Функция для расчета курса валюты
  FUNCTION get_rate_by_id
  (
    p_rate_type_id NUMBER
   ,p_fund_id      NUMBER
   ,p_date         DATE
  ) RETURN NUMBER IS
    v_rate         NUMBER;
    v_default_rate NUMBER;
  BEGIN
    BEGIN
      SELECT default_rate INTO v_default_rate FROM fund f WHERE f.fund_id = p_fund_id;
      IF p_date IS NULL
         AND v_default_rate IS NOT NULL
      THEN
        v_rate := v_default_rate;
      ELSE
        SELECT rate_value
          INTO v_rate
          FROM (SELECT r.rate_value
                  FROM rate r
                 WHERE r.contra_fund_id = p_fund_id
                   AND r.rate_type_id = p_rate_type_id
                   AND r.rate_date = (SELECT MAX(rs.rate_date)
                                        FROM rate rs
                                       WHERE rs.contra_fund_id = p_fund_id
                                         AND rs.rate_type_id = p_rate_type_id
                                         AND rs.rate_date <= p_date)
                UNION ALL
                SELECT 1
                  FROM rate_type r
                 WHERE r.rate_type_id = p_rate_type_id
                   AND r.base_fund_id = p_fund_id);
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        v_rate := 0;
    END;
    RETURN v_rate;
  END;

  FUNCTION get_cross_rate_by_brief
  (
    p_rate_type_id   IN NUMBER
   ,p_fund_brief_in  IN VARCHAR2
   ,p_fund_brief_out IN VARCHAR2
   ,p_date           IN DATE DEFAULT trunc(SYSDATE, 'dd')
  ) RETURN NUMBER IS
    v_fund_in  NUMBER;
    v_fund_out NUMBER;
  
  BEGIN
    SELECT fin.fund_id
          ,fout.fund_id
      INTO v_fund_in
          ,v_fund_out
      FROM fund fin
          ,fund fout
     WHERE fin.brief = p_fund_brief_in
       AND fout.brief = p_fund_brief_out;
  
    RETURN acc.get_cross_rate_by_id(p_rate_type_id, v_fund_in, v_fund_out, p_date);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  --Получить кросс-курс между двумя валютами через тип курса
  FUNCTION get_cross_rate_by_id
  (
    p_rate_type_id IN NUMBER
   ,p_fund_id_in   IN NUMBER
   ,p_fund_id_out  IN NUMBER
   ,p_date         IN DATE DEFAULT trunc(SYSDATE, 'dd')
  ) RETURN NUMBER IS
    v_rate NUMBER;
    v_r1   NUMBER;
    v_r2   NUMBER;
  BEGIN
    IF p_fund_id_in = p_fund_id_out
    THEN
      v_rate := 1;
    ELSE
      BEGIN
        v_r1   := get_rate_by_id(p_rate_type_id, p_fund_id_in, p_date);
        v_r2   := get_rate_by_id(p_rate_type_id, p_fund_id_out, p_date);
        v_rate := v_r1 / v_r2;
      EXCEPTION
        WHEN OTHERS THEN
          v_rate := 1;
      END;
    END IF;
    RETURN v_rate;
  END;

  --Функция для расчета курса валюты (по сокращению типа курса и валюты)
  FUNCTION get_rate_by_brief
  (
    p_rate_type_brief VARCHAR2
   ,p_fund_brief      VARCHAR2
   ,p_date            DATE
  ) RETURN NUMBER IS
    v_rate_type_id NUMBER;
    v_fund_id      NUMBER;
    v_rate         NUMBER;
    v_default_rate NUMBER;
  BEGIN
    SELECT default_rate INTO v_default_rate FROM fund WHERE brief = p_fund_brief;
    IF p_date IS NULL
       AND v_default_rate IS NOT NULL
    THEN
      v_rate := v_default_rate;
    ELSE
      BEGIN
        SELECT rt.rate_type_id
          INTO v_rate_type_id
          FROM rate_type rt
         WHERE rt.brief = p_rate_type_brief;
        SELECT f.fund_id INTO v_fund_id FROM fund f WHERE f.brief = p_fund_brief;
        v_rate := acc.get_rate_by_id(v_rate_type_id, v_fund_id, p_date);
      EXCEPTION
        WHEN OTHERS THEN
          v_rate := 0;
      END;
    END IF;
    RETURN v_rate;
  END;

  -- получить сущность аналитики и объект аналатики по счету
  PROCEDURE get_analytic
  (
    p_account_id     IN NUMBER
   ,p_an_num         IN NUMBER
   ,p_service_ent_id IN NUMBER
   ,p_service_obj_id IN NUMBER
   ,p_an_ent_id      OUT NUMBER
   ,p_an_obj_id      OUT NUMBER
  ) IS
    v_an_type_id NUMBER;
  BEGIN
    BEGIN
      p_an_ent_id := NULL;
      p_an_obj_id := NULL;
      SELECT aty.analytic_type_id
            ,aty.analytic_ent_id
        INTO v_an_type_id
            ,p_an_ent_id
        FROM analytic_type aty
       WHERE aty.analytic_type_id = (SELECT CASE
                                              WHEN p_an_num = 1 THEN
                                               a.a1_analytic_type_id
                                              WHEN p_an_num = 2 THEN
                                               a.a2_analytic_type_id
                                              WHEN p_an_num = 3 THEN
                                               a.a3_analytic_type_id
                                              WHEN p_an_num = 4 THEN
                                               a.a4_analytic_type_id
                                              WHEN p_an_num = 5 THEN
                                               a.a5_analytic_type_id
                                              ELSE
                                               0
                                            END
                                       FROM account a
                                      WHERE a.account_id = p_account_id);
    
      IF (v_an_type_id IS NOT NULL)
      THEN
        p_an_obj_id := get_an_type(p_service_ent_id, p_service_obj_id, v_an_type_id);
      END IF;
    
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;
  END;
  --Получить сущность аналитики заданного уровня по счету
  FUNCTION get_analytic_entity_id
  (
    p_account_id NUMBER
   ,p_an_num     NUMBER
  ) RETURN NUMBER IS
    v_entity_id NUMBER;
  BEGIN
    BEGIN
      SELECT aty.analytic_ent_id
        INTO v_entity_id
        FROM account       a
            ,analytic_type aty
       WHERE (a.account_id = p_account_id)
         AND (((p_an_num = 1) AND (a.a1_analytic_type_id = aty.analytic_type_id)) OR
             ((p_an_num = 2) AND (a.a2_analytic_type_id = aty.analytic_type_id)) OR
             ((p_an_num = 3) AND (a.a3_analytic_type_id = aty.analytic_type_id)) OR
             ((p_an_num = 4) AND (a.a4_analytic_type_id = aty.analytic_type_id)) OR
             ((p_an_num = 5) AND (a.a5_analytic_type_id = aty.analytic_type_id)));
    
    EXCEPTION
      WHEN OTHERS THEN
        v_entity_id := NULL;
    END;
    RETURN v_entity_id;
  END;

  --Получить ИД аналитики заданного уровня по счету
  FUNCTION get_analytic_object_id
  (
    p_account_id     NUMBER
   ,p_an_num         NUMBER
   ,p_service_ent_id NUMBER
   ,p_service_obj_id NUMBER
  ) RETURN NUMBER IS
    v_object_id  NUMBER;
    v_an_type_id NUMBER;
  BEGIN
    BEGIN
      SELECT CASE
               WHEN p_an_num = 1 THEN
                a.a1_analytic_type_id
               WHEN p_an_num = 2 THEN
                a.a2_analytic_type_id
               WHEN p_an_num = 3 THEN
                a.a3_analytic_type_id
               WHEN p_an_num = 4 THEN
                a.a4_analytic_type_id
               WHEN p_an_num = 5 THEN
                a.a5_analytic_type_id
               ELSE
                0
             END
        INTO v_an_type_id
        FROM account a
       WHERE a.account_id = p_account_id;
      --    dbms_output.put_line('An_Type = ' || to_char(v_An_Type_id));
      v_object_id := get_an_type(p_service_ent_id, p_service_obj_id, v_an_type_id);
    EXCEPTION
      WHEN OTHERS THEN
        v_object_id := NULL;
    END;
    RETURN v_object_id;
  END;

  --Остатки и обороты по счету за период
  FUNCTION get_acc_turn_rest
  (
    p_account_id NUMBER
   ,p_fund_id    NUMBER
   ,p_start_date DATE DEFAULT SYSDATE
   ,p_end_date   DATE DEFAULT SYSDATE
   ,p_a1_id      NUMBER DEFAULT NULL
   ,p_a1_nulls   NUMBER DEFAULT 0
   ,p_a2_id      NUMBER DEFAULT NULL
   ,p_a2_nulls   NUMBER DEFAULT 0
   ,p_a3_id      NUMBER DEFAULT NULL
   ,p_a3_nulls   NUMBER DEFAULT 0
   ,p_a4_id      NUMBER DEFAULT NULL
   ,p_a4_nulls   NUMBER DEFAULT 0
   ,p_a5_id      NUMBER DEFAULT NULL
   ,p_a5_nulls   NUMBER DEFAULT 0
  ) RETURN t_turn_rest IS
  
    c NUMBER;
    r NUMBER;
  
    v_turn_rest                t_turn_rest;
    v_account                  account%ROWTYPE;
    v_base_fund_id             NUMBER;
    v_temp_dt_amount_fund      NUMBER;
    v_temp_dt_amount_base_fund NUMBER;
    v_temp_dt_amount_qty       NUMBER;
    v_temp_ct_amount_fund      NUMBER;
    v_temp_ct_amount_base_fund NUMBER;
    v_temp_ct_amount_qty       NUMBER;
  
    v_sql VARCHAR2(32000);
  BEGIN
    BEGIN
      --описание счета
      SELECT * INTO v_account FROM account a WHERE a.account_id = p_account_id;
      --базовая валюта плана счетов
      SELECT act.base_fund_id
        INTO v_base_fund_id
        FROM acc_chart_type act
       WHERE act.acc_chart_type_id = v_account.acc_chart_type_id;
    
      v_sql := '       begin
        SELECT NVL(SUM(t.acc_amount), 0),
             NVL(SUM(t.trans_amount), 0),
             NVL(SUM(t.trans_quantity), 0)
        INTO :v_Temp_Dt_Amount_Fund,
             :v_Temp_Dt_Amount_Base_Fund,
             :v_Temp_Dt_Amount_Qty
        FROM TRANS t
       WHERE t.dt_account_id = :p_Account_ID
         AND t.trans_date < :p_Start_Date
         AND t.acc_fund_id = :p_Fund_ID
';
      IF p_a1_id IS NULL
         AND p_a1_nulls = 1
      THEN
        v_sql := v_sql || ' AND t.a1_dt_uro_id IS NULL ';
      END IF;
      IF p_a1_id IS NOT NULL
      THEN
        v_sql := v_sql || ' AND :p_A1_ID = t.a1_dt_uro_id';
      END IF;
    
      IF p_a2_id IS NULL
         AND p_a2_nulls = 1
      THEN
        v_sql := v_sql || ' AND t.a2_dt_uro_id IS NULL ';
      END IF;
      IF p_a2_id IS NOT NULL
      THEN
        v_sql := v_sql || ' AND :p_A2_ID = t.a2_dt_uro_id';
      END IF;
    
      IF p_a3_id IS NULL
         AND p_a3_nulls = 1
      THEN
        v_sql := v_sql || ' AND t.a3_dt_uro_id IS NULL ';
      END IF;
      IF p_a3_id IS NOT NULL
      THEN
        v_sql := v_sql || ' AND :p_A3_ID = t.a3_dt_uro_id';
      END IF;
    
      IF p_a4_id IS NULL
         AND p_a4_nulls = 1
      THEN
        v_sql := v_sql || ' AND t.a4_dt_uro_id IS NULL ';
      END IF;
      IF p_a4_id IS NOT NULL
      THEN
        v_sql := v_sql || ' AND :p_A4_ID = t.a4_dt_uro_id';
      END IF;
    
      IF p_a5_id IS NULL
         AND p_a5_nulls = 1
      THEN
        v_sql := v_sql || ' AND t.a5_dt_uro_id IS NULL ';
      END IF;
      IF p_a5_id IS NOT NULL
      THEN
        v_sql := v_sql || ' AND :p_A5_ID = t.a5_dt_uro_id';
      END IF;
    
      v_sql := v_sql || '; end;';
    
      c := dbms_sql.open_cursor;
      dbms_sql.parse(c, v_sql, dbms_sql.native);
    
      dbms_sql.bind_variable(c, 'p_Account_ID', v_account.account_id);
      dbms_sql.bind_variable(c, 'p_Start_Date', p_start_date);
      dbms_sql.bind_variable(c, 'p_Fund_ID', p_fund_id);
    
      dbms_sql.bind_variable(c, 'v_Temp_Dt_Amount_Fund', v_temp_dt_amount_fund);
      dbms_sql.bind_variable(c, 'v_Temp_Dt_Amount_Base_Fund', v_temp_dt_amount_fund);
      dbms_sql.bind_variable(c, 'v_Temp_Dt_Amount_Qty', v_temp_dt_amount_fund);
    
      IF p_a1_id IS NOT NULL
      THEN
        dbms_sql.bind_variable(c, 'p_A1_ID', p_a1_id);
      END IF;
      IF p_a2_id IS NOT NULL
      THEN
        dbms_sql.bind_variable(c, 'p_A2_ID', p_a2_id);
      END IF;
      IF p_a3_id IS NOT NULL
      THEN
        dbms_sql.bind_variable(c, 'p_A3_ID', p_a3_id);
      END IF;
      IF p_a4_id IS NOT NULL
      THEN
        dbms_sql.bind_variable(c, 'p_A4_ID', p_a4_id);
      END IF;
      IF p_a5_id IS NOT NULL
      THEN
        dbms_sql.bind_variable(c, 'p_A5_ID', p_a5_id);
      END IF;
    
      r := dbms_sql.execute(c);
    
      dbms_sql.variable_value(c, 'v_Temp_Dt_Amount_Fund', v_temp_dt_amount_fund);
      dbms_sql.variable_value(c, 'v_Temp_Dt_Amount_Base_Fund', v_temp_dt_amount_fund);
      dbms_sql.variable_value(c, 'v_Temp_Dt_Amount_Qty', v_temp_dt_amount_fund);
    
      v_sql := '       begin
        SELECT NVL(SUM(t.acc_amount), 0),
             NVL(SUM(t.trans_amount), 0),
             NVL(SUM(t.trans_quantity), 0)
        INTO :v_Temp_Ct_Amount_Fund,
             :v_Temp_Ct_Amount_Base_Fund,
             :v_Temp_Ct_Amount_Qty
        FROM TRANS t
       WHERE t.ct_account_id = :p_Account_ID
         AND t.trans_date < :p_Start_Date
         AND t.acc_fund_id = :p_Fund_ID
';
      IF p_a1_id IS NULL
         AND p_a1_nulls = 1
      THEN
        v_sql := v_sql || ' AND t.a1_ct_uro_id IS NULL ';
      END IF;
      IF p_a1_id IS NOT NULL
      THEN
        v_sql := v_sql || ' AND :p_A1_ID = t.a1_ct_uro_id';
      END IF;
    
      IF p_a2_id IS NULL
         AND p_a2_nulls = 1
      THEN
        v_sql := v_sql || ' AND t.a2_ct_uro_id IS NULL ';
      END IF;
      IF p_a2_id IS NOT NULL
      THEN
        v_sql := v_sql || ' AND :p_A2_ID = t.a2_ct_uro_id';
      END IF;
    
      IF p_a3_id IS NULL
         AND p_a3_nulls = 1
      THEN
        v_sql := v_sql || ' AND t.a3_ct_uro_id IS NULL ';
      END IF;
      IF p_a3_id IS NOT NULL
      THEN
        v_sql := v_sql || ' AND :p_A3_ID = t.a3_ct_uro_id';
      END IF;
    
      IF p_a4_id IS NULL
         AND p_a4_nulls = 1
      THEN
        v_sql := v_sql || ' AND t.a4_ct_uro_id IS NULL ';
      END IF;
      IF p_a4_id IS NOT NULL
      THEN
        v_sql := v_sql || ' AND :p_A4_ID = t.a4_ct_uro_id';
      END IF;
    
      IF p_a5_id IS NULL
         AND p_a5_nulls = 1
      THEN
        v_sql := v_sql || ' AND t.a5_ct_uro_id IS NULL ';
      END IF;
      IF p_a5_id IS NOT NULL
      THEN
        v_sql := v_sql || ' AND :p_A5_ID = t.a5_ct_uro_id';
      END IF;
    
      v_sql := v_sql || '; end;';
    
      dbms_sql.parse(c, v_sql, dbms_sql.native);
    
      dbms_sql.bind_variable(c, 'p_Account_ID', v_account.account_id);
      dbms_sql.bind_variable(c, 'p_Start_Date', p_start_date);
      dbms_sql.bind_variable(c, 'p_Fund_ID', p_fund_id);
    
      dbms_sql.bind_variable(c, 'v_Temp_Ct_Amount_Fund', v_temp_ct_amount_fund);
      dbms_sql.bind_variable(c, 'v_Temp_Ct_Amount_Base_Fund', v_temp_ct_amount_fund);
      dbms_sql.bind_variable(c, 'v_Temp_Ct_Amount_Qty', v_temp_ct_amount_fund);
    
      IF p_a1_id IS NOT NULL
      THEN
        dbms_sql.bind_variable(c, 'p_A1_ID', p_a1_id);
      END IF;
      IF p_a2_id IS NOT NULL
      THEN
        dbms_sql.bind_variable(c, 'p_A2_ID', p_a2_id);
      END IF;
      IF p_a3_id IS NOT NULL
      THEN
        dbms_sql.bind_variable(c, 'p_A3_ID', p_a3_id);
      END IF;
      IF p_a4_id IS NOT NULL
      THEN
        dbms_sql.bind_variable(c, 'p_A4_ID', p_a4_id);
      END IF;
      IF p_a5_id IS NOT NULL
      THEN
        dbms_sql.bind_variable(c, 'p_A5_ID', p_a5_id);
      END IF;
    
      r := dbms_sql.execute(c);
    
      dbms_sql.variable_value(c, 'v_Temp_Ct_Amount_Fund', v_temp_ct_amount_fund);
      dbms_sql.variable_value(c, 'v_Temp_Ct_Amount_Base_Fund', v_temp_ct_amount_fund);
      dbms_sql.variable_value(c, 'v_Temp_Ct_Amount_Qty', v_temp_ct_amount_fund);
    
      --подсчет входящего остатка
      v_turn_rest.rest_in_fund := v_temp_dt_amount_fund - v_temp_ct_amount_fund;
      IF (v_turn_rest.rest_in_fund > 0)
      THEN
        v_turn_rest.rest_in_fund_type := 'Д';
      ELSE
        IF (v_turn_rest.rest_in_fund < 0)
        THEN
          v_turn_rest.rest_in_fund_type := 'К';
        ELSE
          v_turn_rest.rest_in_fund_type := '';
        END IF;
      END IF;
      v_turn_rest.rest_in_base_fund := v_temp_dt_amount_base_fund - v_temp_ct_amount_base_fund;
      IF (v_turn_rest.rest_in_base_fund > 0)
      THEN
        v_turn_rest.rest_in_base_fund_type := 'Д';
      ELSE
        IF (v_turn_rest.rest_in_base_fund < 0)
        THEN
          v_turn_rest.rest_in_base_fund_type := 'К';
        ELSE
          v_turn_rest.rest_in_base_fund_type := '';
        END IF;
      END IF;
      v_turn_rest.rest_in_qty := v_temp_dt_amount_qty - v_temp_ct_amount_qty;
      IF (v_turn_rest.rest_in_qty > 0)
      THEN
        v_turn_rest.rest_in_qty_type := 'Д';
      ELSE
        IF (v_turn_rest.rest_in_qty < 0)
        THEN
          v_turn_rest.rest_in_qty_type := 'К';
        ELSE
          v_turn_rest.rest_in_qty_type := '';
        END IF;
      END IF;
    
      v_sql := 'begin      SELECT NVL(SUM(t.acc_amount), 0),
             NVL(SUM(t.trans_amount), 0),
             NVL(SUM(t.trans_quantity), 0)
        INTO :p_Turn_Dt_Fund,
             :p_Turn_Dt_Base_Fund,
             :p_Turn_Dt_Qty
        FROM TRANS t
       WHERE t.dt_account_id = :p_Account_Id
         AND t.trans_date >= :p_Start_Date
         AND t.trans_date <= :p_End_Date
         AND :p_Fund_ID = t.acc_fund_id

';
    
      IF p_a1_id IS NULL
         AND p_a1_nulls = 1
      THEN
        v_sql := v_sql || ' AND t.a1_dt_uro_id IS NULL ';
      END IF;
      IF p_a1_id IS NOT NULL
      THEN
        v_sql := v_sql || ' AND :p_A1_ID = t.a1_dt_uro_id';
      END IF;
    
      IF p_a2_id IS NULL
         AND p_a2_nulls = 1
      THEN
        v_sql := v_sql || ' AND t.a2_dt_uro_id IS NULL ';
      END IF;
      IF p_a2_id IS NOT NULL
      THEN
        v_sql := v_sql || ' AND :p_A2_ID = t.a2_dt_uro_id';
      END IF;
    
      IF p_a3_id IS NULL
         AND p_a3_nulls = 1
      THEN
        v_sql := v_sql || ' AND t.a3_dt_uro_id IS NULL ';
      END IF;
      IF p_a3_id IS NOT NULL
      THEN
        v_sql := v_sql || ' AND :p_A3_ID = t.a3_dt_uro_id';
      END IF;
    
      IF p_a4_id IS NULL
         AND p_a4_nulls = 1
      THEN
        v_sql := v_sql || ' AND t.a4_dt_uro_id IS NULL ';
      END IF;
      IF p_a4_id IS NOT NULL
      THEN
        v_sql := v_sql || ' AND :p_A4_ID = t.a4_dt_uro_id';
      END IF;
    
      IF p_a5_id IS NULL
         AND p_a5_nulls = 1
      THEN
        v_sql := v_sql || ' AND t.a5_dt_uro_id IS NULL ';
      END IF;
      IF p_a5_id IS NOT NULL
      THEN
        v_sql := v_sql || ' AND :p_A5_ID = t.a5_dt_uro_id';
      END IF;
    
      v_sql := v_sql || '; end;';
    
      dbms_sql.parse(c, v_sql, dbms_sql.native);
    
      dbms_sql.bind_variable(c, 'p_Account_ID', v_account.account_id);
      dbms_sql.bind_variable(c, 'p_Start_Date', p_start_date);
      dbms_sql.bind_variable(c, 'p_End_Date', p_end_date);
      dbms_sql.bind_variable(c, 'p_Fund_ID', p_fund_id);
    
      dbms_sql.bind_variable(c, 'p_Turn_Dt_Fund', v_turn_rest.turn_dt_fund);
      dbms_sql.bind_variable(c, 'p_Turn_Dt_Base_Fund', v_turn_rest.turn_dt_base_fund);
      dbms_sql.bind_variable(c, 'p_Turn_Dt_Qty', v_turn_rest.turn_dt_qty);
    
      IF p_a1_id IS NOT NULL
      THEN
        dbms_sql.bind_variable(c, 'p_A1_ID', p_a1_id);
      END IF;
      IF p_a2_id IS NOT NULL
      THEN
        dbms_sql.bind_variable(c, 'p_A2_ID', p_a2_id);
      END IF;
      IF p_a3_id IS NOT NULL
      THEN
        dbms_sql.bind_variable(c, 'p_A3_ID', p_a3_id);
      END IF;
      IF p_a4_id IS NOT NULL
      THEN
        dbms_sql.bind_variable(c, 'p_A4_ID', p_a4_id);
      END IF;
      IF p_a5_id IS NOT NULL
      THEN
        dbms_sql.bind_variable(c, 'p_A5_ID', p_a5_id);
      END IF;
    
      r := dbms_sql.execute(c);
    
      dbms_sql.variable_value(c, 'p_Turn_Dt_Fund', v_turn_rest.turn_dt_fund);
      dbms_sql.variable_value(c, 'p_Turn_Dt_Base_Fund', v_turn_rest.turn_dt_base_fund);
      dbms_sql.variable_value(c, 'p_Turn_Dt_Qty', v_turn_rest.turn_dt_qty);
    
      v_sql := 'begin      SELECT NVL(SUM(t.acc_amount), 0),
             NVL(SUM(t.trans_amount), 0),
             NVL(SUM(t.trans_quantity), 0)
        INTO :p_Turn_Ct_Fund,
             :p_Turn_Ct_Base_Fund,
             :p_Turn_Ct_Qty
        FROM TRANS t
       WHERE t.ct_account_id = :p_Account_Id
         AND t.trans_date >= :p_Start_Date
         AND t.trans_date <= :p_End_Date
         AND :p_Fund_ID = t.acc_fund_id

';
    
      IF p_a1_id IS NULL
         AND p_a1_nulls = 1
      THEN
        v_sql := v_sql || ' AND t.a1_ct_uro_id IS NULL ';
      END IF;
      IF p_a1_id IS NOT NULL
      THEN
        v_sql := v_sql || ' AND :p_A1_ID = t.a1_ct_uro_id';
      END IF;
    
      IF p_a2_id IS NULL
         AND p_a2_nulls = 1
      THEN
        v_sql := v_sql || ' AND t.a2_ct_uro_id IS NULL ';
      END IF;
      IF p_a2_id IS NOT NULL
      THEN
        v_sql := v_sql || ' AND :p_A2_ID = t.a2_ct_uro_id';
      END IF;
    
      IF p_a3_id IS NULL
         AND p_a3_nulls = 1
      THEN
        v_sql := v_sql || ' AND t.a3_ct_uro_id IS NULL ';
      END IF;
      IF p_a3_id IS NOT NULL
      THEN
        v_sql := v_sql || ' AND :p_A3_ID = t.a3_ct_uro_id';
      END IF;
    
      IF p_a4_id IS NULL
         AND p_a4_nulls = 1
      THEN
        v_sql := v_sql || ' AND t.a4_ct_uro_id IS NULL ';
      END IF;
      IF p_a4_id IS NOT NULL
      THEN
        v_sql := v_sql || ' AND :p_A4_ID = t.a4_ct_uro_id';
      END IF;
    
      IF p_a5_id IS NULL
         AND p_a5_nulls = 1
      THEN
        v_sql := v_sql || ' AND t.a5_ct_uro_id IS NULL ';
      END IF;
      IF p_a5_id IS NOT NULL
      THEN
        v_sql := v_sql || ' AND :p_A5_ID = t.a5_ct_uro_id';
      END IF;
    
      v_sql := v_sql || '; end;';
    
      dbms_sql.parse(c, v_sql, dbms_sql.native);
    
      dbms_sql.bind_variable(c, 'p_Account_ID', v_account.account_id);
      dbms_sql.bind_variable(c, 'p_Start_Date', p_start_date);
      dbms_sql.bind_variable(c, 'p_End_Date', p_end_date);
      dbms_sql.bind_variable(c, 'p_Fund_ID', p_fund_id);
    
      dbms_sql.bind_variable(c, 'p_Turn_Ct_Fund', v_turn_rest.turn_ct_fund);
      dbms_sql.bind_variable(c, 'p_Turn_Ct_Base_Fund', v_turn_rest.turn_ct_base_fund);
      dbms_sql.bind_variable(c, 'p_Turn_Ct_Qty', v_turn_rest.turn_ct_qty);
    
      IF p_a1_id IS NOT NULL
      THEN
        dbms_sql.bind_variable(c, 'p_A1_ID', p_a1_id);
      END IF;
      IF p_a2_id IS NOT NULL
      THEN
        dbms_sql.bind_variable(c, 'p_A2_ID', p_a2_id);
      END IF;
      IF p_a3_id IS NOT NULL
      THEN
        dbms_sql.bind_variable(c, 'p_A3_ID', p_a3_id);
      END IF;
      IF p_a4_id IS NOT NULL
      THEN
        dbms_sql.bind_variable(c, 'p_A4_ID', p_a4_id);
      END IF;
      IF p_a5_id IS NOT NULL
      THEN
        dbms_sql.bind_variable(c, 'p_A5_ID', p_a5_id);
      END IF;
    
      r := dbms_sql.execute(c);
    
      dbms_sql.variable_value(c, 'p_Turn_Ct_Fund', v_turn_rest.turn_ct_fund);
      dbms_sql.variable_value(c, 'p_Turn_Ct_Base_Fund', v_turn_rest.turn_ct_base_fund);
      dbms_sql.variable_value(c, 'p_Turn_Ct_Qty', v_turn_rest.turn_ct_qty);
    
      --подсчет исходящего остатка
      v_turn_rest.rest_out_fund := v_turn_rest.rest_in_fund + v_turn_rest.turn_dt_fund -
                                   v_turn_rest.turn_ct_fund;
      IF (v_turn_rest.rest_out_fund > 0)
      THEN
        v_turn_rest.rest_out_fund_type := 'Д';
      ELSE
        IF (v_turn_rest.rest_out_fund < 0)
        THEN
          v_turn_rest.rest_out_fund_type := 'К';
        ELSE
          v_turn_rest.rest_out_fund_type := '';
        END IF;
      END IF;
      v_turn_rest.rest_in_fund  := abs(v_turn_rest.rest_in_fund);
      v_turn_rest.rest_out_fund := abs(v_turn_rest.rest_out_fund);
    
      v_turn_rest.rest_out_base_fund := v_turn_rest.rest_in_base_fund + v_turn_rest.turn_dt_base_fund -
                                        v_turn_rest.turn_ct_base_fund;
      IF (v_turn_rest.rest_out_base_fund > 0)
      THEN
        v_turn_rest.rest_out_base_fund_type := 'Д';
      ELSE
        IF (v_turn_rest.rest_out_base_fund < 0)
        THEN
          v_turn_rest.rest_out_base_fund_type := 'К';
        ELSE
          v_turn_rest.rest_out_base_fund_type := '';
        END IF;
      END IF;
      v_turn_rest.rest_in_base_fund  := abs(v_turn_rest.rest_in_base_fund);
      v_turn_rest.rest_out_base_fund := abs(v_turn_rest.rest_out_base_fund);
    
      v_turn_rest.rest_out_qty := v_turn_rest.rest_in_qty + v_turn_rest.turn_dt_qty -
                                  v_turn_rest.turn_ct_qty;
      IF (v_turn_rest.rest_out_qty > 0)
      THEN
        v_turn_rest.rest_out_qty_type := 'Д';
      ELSE
        IF (v_turn_rest.rest_out_qty < 0)
        THEN
          v_turn_rest.rest_out_qty_type := 'К';
        ELSE
          v_turn_rest.rest_out_qty_type := '';
        END IF;
      END IF;
      v_turn_rest.rest_in_qty  := abs(v_turn_rest.rest_in_qty);
      v_turn_rest.rest_out_qty := abs(v_turn_rest.rest_out_qty);
      dbms_sql.close_cursor(c);
    EXCEPTION
      WHEN OTHERS THEN
        v_turn_rest.rest_in_fund            := 0.0;
        v_turn_rest.rest_in_base_fund       := 0.0;
        v_turn_rest.rest_in_qty             := 0.0;
        v_turn_rest.rest_in_fund_type       := '';
        v_turn_rest.rest_in_base_fund_type  := '';
        v_turn_rest.rest_in_qty_type        := '';
        v_turn_rest.turn_dt_fund            := 0.0;
        v_turn_rest.turn_dt_base_fund       := 0.0;
        v_turn_rest.turn_dt_qty             := 0.0;
        v_turn_rest.turn_ct_fund            := 0.0;
        v_turn_rest.turn_ct_base_fund       := 0.0;
        v_turn_rest.turn_ct_qty             := 0.0;
        v_turn_rest.rest_out_fund           := 0.0;
        v_turn_rest.rest_out_base_fund      := 0.0;
        v_turn_rest.rest_out_qty            := 0.0;
        v_turn_rest.rest_out_fund_type      := '';
        v_turn_rest.rest_out_base_fund_type := '';
        v_turn_rest.rest_out_qty_type       := '';
        IF dbms_sql.is_open(c)
        THEN
          dbms_sql.close_cursor(c);
        END IF;
        --dbms_output.put_line(SQLERRM);
    END;
    RETURN v_turn_rest;
  END;

  --Исходящий остаток по счету на дату
  -- opatsan
  FUNCTION get_acc_rest
  (
    p_account_id NUMBER
   ,p_fund_id    NUMBER
   ,p_date       DATE DEFAULT SYSDATE
   ,p_a1_id      NUMBER DEFAULT NULL
   ,p_a1_nulls   NUMBER DEFAULT 0
   ,p_a2_id      NUMBER DEFAULT NULL
   ,p_a2_nulls   NUMBER DEFAULT 0
   ,p_a3_id      NUMBER DEFAULT NULL
   ,p_a3_nulls   NUMBER DEFAULT 0
   ,p_a4_id      NUMBER DEFAULT NULL
   ,p_a4_nulls   NUMBER DEFAULT 0
   ,p_a5_id      NUMBER DEFAULT NULL
   ,p_a5_nulls   NUMBER DEFAULT 0
  ) RETURN t_rest IS
    v_rest                     acc_new.t_rest;
    v_account                  account%ROWTYPE;
    v_base_fund_id             NUMBER;
    v_temp_dt_amount_fund      NUMBER;
    v_temp_dt_amount_base_fund NUMBER;
    v_temp_dt_amount_qty       NUMBER;
    v_temp_ct_amount_fund      NUMBER;
    v_temp_ct_amount_base_fund NUMBER;
    v_temp_ct_amount_qty       NUMBER;
  BEGIN
    v_rest.rest_amount_fund      := 0;
    v_rest.rest_amount_base_fund := 0;
    v_rest.rest_amount_qty       := 0;
    v_rest.rest_fund_type        := '';
    v_rest.rest_base_fund_type   := '';
    v_rest.rest_qty_type         := '';
    --описание счета
    SELECT * INTO v_account FROM account a WHERE a.account_id = p_account_id;
    --базовая валюта плана счетов
    SELECT act.base_fund_id
      INTO v_base_fund_id
      FROM acc_chart_type act
     WHERE act.acc_chart_type_id = v_account.acc_chart_type_id;
    --расчет входящего остатка по дебету
    SELECT nvl(SUM(t.acc_amount), 0)
          ,nvl(SUM(t.trans_amount), 0)
          ,nvl(SUM(t.trans_quantity), 0)
      INTO v_temp_dt_amount_fund
          ,v_temp_dt_amount_base_fund
          ,v_temp_dt_amount_qty
      FROM trans t
     WHERE t.dt_account_id = v_account.account_id
       AND t.trans_date <= p_date
       AND t.acc_fund_id = p_fund_id
       AND (((p_a1_id IS NULL) AND (p_a1_nulls = 0)) OR
           ((p_a1_id IS NULL) AND (p_a1_nulls = 1) AND (t.a1_dt_uro_id IS NULL)) OR
           ((p_a1_id IS NOT NULL) AND (p_a1_id = t.a1_dt_uro_id)))
       AND (((p_a2_id IS NULL) AND (p_a2_nulls = 0)) OR
           ((p_a2_id IS NULL) AND (p_a2_nulls = 1) AND (t.a2_dt_uro_id IS NULL)) OR
           ((p_a2_id IS NOT NULL) AND (p_a2_id = t.a2_dt_uro_id)))
       AND (((p_a3_id IS NULL) AND (p_a3_nulls = 0)) OR
           ((p_a3_id IS NULL) AND (p_a3_nulls = 1) AND (t.a3_dt_uro_id IS NULL)) OR
           ((p_a3_id IS NOT NULL) AND (p_a3_id = t.a3_dt_uro_id)))
       AND (((p_a4_id IS NULL) AND (p_a4_nulls = 0)) OR
           ((p_a4_id IS NULL) AND (p_a4_nulls = 1) AND (t.a4_dt_uro_id IS NULL)) OR
           ((p_a4_id IS NOT NULL) AND (p_a4_id = t.a4_dt_uro_id)))
       AND (((p_a5_id IS NULL) AND (p_a5_nulls = 0)) OR
           ((p_a5_id IS NULL) AND (p_a5_nulls = 1) AND (t.a5_dt_uro_id IS NULL)) OR
           ((p_a5_id IS NOT NULL) AND (p_a5_id = t.a5_dt_uro_id)));
    --расчет входящего остатка по кредиту
    SELECT nvl(SUM(t.acc_amount), 0)
          ,nvl(SUM(t.trans_amount), 0)
          ,nvl(SUM(t.trans_quantity), 0)
      INTO v_temp_ct_amount_fund
          ,v_temp_ct_amount_base_fund
          ,v_temp_ct_amount_qty
      FROM trans t
     WHERE t.ct_account_id = v_account.account_id
       AND t.trans_date <= p_date
       AND t.acc_fund_id = p_fund_id
       AND (((p_a1_id IS NULL) AND (p_a1_nulls = 0)) OR
           ((p_a1_id IS NULL) AND (p_a1_nulls = 1) AND (t.a1_ct_uro_id IS NULL)) OR
           ((p_a1_id IS NOT NULL) AND (p_a1_id = t.a1_ct_uro_id)))
       AND (((p_a2_id IS NULL) AND (p_a2_nulls = 0)) OR
           ((p_a2_id IS NULL) AND (p_a2_nulls = 1) AND (t.a2_ct_uro_id IS NULL)) OR
           ((p_a2_id IS NOT NULL) AND (p_a2_id = t.a2_ct_uro_id)))
       AND (((p_a3_id IS NULL) AND (p_a3_nulls = 0)) OR
           ((p_a3_id IS NULL) AND (p_a3_nulls = 1) AND (t.a3_ct_uro_id IS NULL)) OR
           ((p_a3_id IS NOT NULL) AND (p_a3_id = t.a3_ct_uro_id)))
       AND (((p_a4_id IS NULL) AND (p_a4_nulls = 0)) OR
           ((p_a4_id IS NULL) AND (p_a4_nulls = 1) AND (t.a4_ct_uro_id IS NULL)) OR
           ((p_a4_id IS NOT NULL) AND (p_a4_id = t.a4_ct_uro_id)))
       AND (((p_a5_id IS NULL) AND (p_a5_nulls = 0)) OR
           ((p_a5_id IS NULL) AND (p_a5_nulls = 1) AND (t.a5_ct_uro_id IS NULL)) OR
           ((p_a5_id IS NOT NULL) AND (p_a5_id = t.a5_ct_uro_id)));
    --подсчет исходящего остатка
    v_rest.rest_amount_fund := v_temp_dt_amount_fund - v_temp_ct_amount_fund;
    IF (v_rest.rest_amount_fund > 0)
    THEN
      v_rest.rest_fund_type := 'Д';
    ELSE
      IF (v_rest.rest_amount_fund < 0)
      THEN
        v_rest.rest_fund_type   := 'К';
        v_rest.rest_amount_fund := -v_rest.rest_amount_fund;
      ELSE
        v_rest.rest_fund_type := '';
      END IF;
    END IF;
    v_rest.rest_amount_base_fund := v_temp_dt_amount_base_fund - v_temp_ct_amount_base_fund;
    IF (v_rest.rest_amount_base_fund > 0)
    THEN
      v_rest.rest_base_fund_type := 'Д';
    ELSE
      IF (v_rest.rest_amount_base_fund < 0)
      THEN
        v_rest.rest_base_fund_type   := 'К';
        v_rest.rest_amount_base_fund := -v_rest.rest_amount_base_fund;
      ELSE
        v_rest.rest_base_fund_type := '';
      END IF;
    END IF;
    v_rest.rest_amount_qty := v_temp_dt_amount_qty - v_temp_ct_amount_qty;
    IF (v_rest.rest_amount_qty > 0)
    THEN
      v_rest.rest_qty_type := 'Д';
    ELSE
      IF (v_rest.rest_amount_qty < 0)
      THEN
        v_rest.rest_qty_type   := 'К';
        v_rest.rest_amount_qty := -v_rest.rest_amount_qty;
      ELSE
        v_rest.rest_qty_type := '';
      END IF;
    END IF;
  
    RETURN v_rest;
  END;

  --Исходящий остаток по счету на дату (дебет-кредит)
  FUNCTION get_acc_rest_abs
  (
    p_rest_amount_type VARCHAR2
   ,p_account_id       NUMBER
   ,p_fund_id          NUMBER
   ,p_date             DATE DEFAULT SYSDATE
   ,p_a1_id            NUMBER DEFAULT NULL
   ,p_a1_nulls         NUMBER DEFAULT 0
   ,p_a2_id            NUMBER DEFAULT NULL
   ,p_a2_nulls         NUMBER DEFAULT 0
   ,p_a3_id            NUMBER DEFAULT NULL
   ,p_a3_nulls         NUMBER DEFAULT 0
   ,p_a4_id            NUMBER DEFAULT NULL
   ,p_a4_nulls         NUMBER DEFAULT 0
   ,p_a5_id            NUMBER DEFAULT NULL
   ,p_a5_nulls         NUMBER DEFAULT 0
  ) RETURN NUMBER IS
    v_rest           NUMBER;
    v_account        account%ROWTYPE;
    v_base_fund_id   NUMBER;
    v_temp_dt_amount NUMBER;
    v_temp_ct_amount NUMBER;
  BEGIN
    --описание счета
    SELECT * INTO v_account FROM account a WHERE a.account_id = p_account_id;
    --базовая валюта плана счетов
    SELECT act.base_fund_id
      INTO v_base_fund_id
      FROM acc_chart_type act
     WHERE act.acc_chart_type_id = v_account.acc_chart_type_id;
    --расчет исходящего остатка по дебету
    SELECT CASE
             WHEN p_rest_amount_type = 'F' THEN
              nvl(SUM(t.acc_amount), 0)
             WHEN p_rest_amount_type = 'B' THEN
              nvl(SUM(t.trans_amount), 0)
             WHEN p_rest_amount_type = 'Q' THEN
              nvl(SUM(t.trans_quantity), 0)
             ELSE
              0
           END rest
      INTO v_temp_dt_amount
      FROM trans t
     WHERE t.dt_account_id = v_account.account_id
       AND t.trans_date <= p_date
       AND t.acc_fund_id = p_fund_id
       AND (((p_a1_id IS NULL) AND (p_a1_nulls = 0)) OR
           ((p_a1_id IS NULL) AND (p_a1_nulls = 1) AND (t.a1_dt_uro_id IS NULL)) OR
           ((p_a1_id IS NOT NULL) AND (p_a1_id = t.a1_dt_uro_id)))
       AND (((p_a2_id IS NULL) AND (p_a2_nulls = 0)) OR
           ((p_a2_id IS NULL) AND (p_a2_nulls = 1) AND (t.a2_dt_uro_id IS NULL)) OR
           ((p_a2_id IS NOT NULL) AND (p_a2_id = t.a2_dt_uro_id)))
       AND (((p_a3_id IS NULL) AND (p_a3_nulls = 0)) OR
           ((p_a3_id IS NULL) AND (p_a3_nulls = 1) AND (t.a3_dt_uro_id IS NULL)) OR
           ((p_a3_id IS NOT NULL) AND (p_a3_id = t.a3_dt_uro_id)))
       AND (((p_a4_id IS NULL) AND (p_a4_nulls = 0)) OR
           ((p_a4_id IS NULL) AND (p_a4_nulls = 1) AND (t.a4_dt_uro_id IS NULL)) OR
           ((p_a4_id IS NOT NULL) AND (p_a4_id = t.a4_dt_uro_id)))
       AND (((p_a5_id IS NULL) AND (p_a5_nulls = 0)) OR
           ((p_a5_id IS NULL) AND (p_a5_nulls = 1) AND (t.a5_dt_uro_id IS NULL)) OR
           ((p_a5_id IS NOT NULL) AND (p_a5_id = t.a5_dt_uro_id)));
    --расчет исходящего остатка по кредиту
    SELECT CASE
             WHEN p_rest_amount_type = 'F' THEN
              nvl(SUM(t.acc_amount), 0)
             WHEN p_rest_amount_type = 'B' THEN
              nvl(SUM(t.trans_amount), 0)
             WHEN p_rest_amount_type = 'Q' THEN
              nvl(SUM(t.trans_quantity), 0)
             ELSE
              0
           END rest
      INTO v_temp_ct_amount
      FROM trans t
     WHERE t.ct_account_id = v_account.account_id
       AND t.trans_date <= p_date
       AND t.acc_fund_id = p_fund_id
       AND (((p_a1_id IS NULL) AND (p_a1_nulls = 0)) OR
           ((p_a1_id IS NULL) AND (p_a1_nulls = 1) AND (t.a1_ct_uro_id IS NULL)) OR
           ((p_a1_id IS NOT NULL) AND (p_a1_id = t.a1_ct_uro_id)))
       AND (((p_a2_id IS NULL) AND (p_a2_nulls = 0)) OR
           ((p_a2_id IS NULL) AND (p_a2_nulls = 1) AND (t.a2_ct_uro_id IS NULL)) OR
           ((p_a2_id IS NOT NULL) AND (p_a2_id = t.a2_ct_uro_id)))
       AND (((p_a3_id IS NULL) AND (p_a3_nulls = 0)) OR
           ((p_a3_id IS NULL) AND (p_a3_nulls = 1) AND (t.a3_ct_uro_id IS NULL)) OR
           ((p_a3_id IS NOT NULL) AND (p_a3_id = t.a3_ct_uro_id)))
       AND (((p_a4_id IS NULL) AND (p_a4_nulls = 0)) OR
           ((p_a4_id IS NULL) AND (p_a4_nulls = 1) AND (t.a4_ct_uro_id IS NULL)) OR
           ((p_a4_id IS NOT NULL) AND (p_a4_id = t.a4_ct_uro_id)))
       AND (((p_a5_id IS NULL) AND (p_a5_nulls = 0)) OR
           ((p_a5_id IS NULL) AND (p_a5_nulls = 1) AND (t.a5_ct_uro_id IS NULL)) OR
           ((p_a5_id IS NOT NULL) AND (p_a5_id = t.a5_ct_uro_id)));
    --подсчет исходящего остатка
    v_rest := v_temp_dt_amount - v_temp_ct_amount;
    RETURN v_rest;
  END;

  --Остатки и обороты по счету за период
  FUNCTION get_acc_turn_rest_by_type
  (
    p_type       VARCHAR2
   ,p_char       VARCHAR2
   ,p_account_id NUMBER
   ,p_fund_id    NUMBER
   ,p_start_date DATE DEFAULT SYSDATE
   ,p_end_date   DATE DEFAULT SYSDATE
   ,p_a1_id      NUMBER DEFAULT NULL
   ,p_a1_nulls   NUMBER DEFAULT 0
   ,p_a2_id      NUMBER DEFAULT NULL
   ,p_a2_nulls   NUMBER DEFAULT 0
   ,p_a3_id      NUMBER DEFAULT NULL
   ,p_a3_nulls   NUMBER DEFAULT 0
   ,p_a4_id      NUMBER DEFAULT NULL
   ,p_a4_nulls   NUMBER DEFAULT 0
   ,p_a5_id      NUMBER DEFAULT NULL
   ,p_a5_nulls   NUMBER DEFAULT 0
  ) RETURN NUMBER IS
    v_turn_rest t_turn_rest;
    v_result    NUMBER;
  BEGIN
    v_turn_rest := get_acc_turn_rest(p_account_id
                                    ,p_fund_id
                                    ,p_start_date
                                    ,p_end_date
                                    ,p_a1_id
                                    ,p_a1_nulls
                                    ,p_a2_id
                                    ,p_a2_nulls
                                    ,p_a3_id
                                    ,p_a3_nulls
                                    ,p_a4_id
                                    ,p_a4_nulls
                                    ,p_a5_id
                                    ,p_a5_nulls);
  
    IF (p_type = 'IR_F')
    THEN
      IF (p_char = 'А')
      THEN
        IF v_turn_rest.rest_in_fund_type = 'Д'
        THEN
          v_result := v_turn_rest.rest_in_fund;
        ELSE
          v_result := -v_turn_rest.rest_in_fund;
        END IF;
      ELSE
        IF v_turn_rest.rest_in_fund_type = 'К'
        THEN
          v_result := v_turn_rest.rest_in_fund;
        ELSE
          v_result := -v_turn_rest.rest_in_fund;
        END IF;
      END IF;
    ELSIF (p_type = 'IR_BF')
    THEN
      IF (p_char = 'А')
      THEN
        IF v_turn_rest.rest_in_base_fund_type = 'Д'
        THEN
          v_result := v_turn_rest.rest_in_base_fund;
        ELSE
          v_result := -v_turn_rest.rest_in_base_fund;
        END IF;
      ELSE
        IF v_turn_rest.rest_in_base_fund_type = 'К'
        THEN
          v_result := v_turn_rest.rest_in_base_fund;
        ELSE
          v_result := -v_turn_rest.rest_in_base_fund;
        END IF;
      END IF;
    ELSIF (p_type = 'IR_Q')
    THEN
      IF (p_char = 'А')
      THEN
        IF v_turn_rest.rest_in_qty_type = 'Д'
        THEN
          v_result := v_turn_rest.rest_in_qty;
        ELSE
          v_result := -v_turn_rest.rest_in_qty;
        END IF;
      ELSE
        IF v_turn_rest.rest_in_qty_type = 'К'
        THEN
          v_result := v_turn_rest.rest_in_qty;
        ELSE
          v_result := -v_turn_rest.rest_in_qty;
        END IF;
      END IF;
    ELSIF (p_type = 'IR_F_')
    THEN
      v_result := v_turn_rest.rest_in_fund;
    ELSIF (p_type = 'IR_BF_')
    THEN
      v_result := v_turn_rest.rest_in_base_fund;
    ELSIF (p_type = 'IR_Q_')
    THEN
      v_result := v_turn_rest.rest_in_qty;
    ELSIF (p_type = 'IRT_F')
    THEN
      IF (v_turn_rest.rest_in_fund_type = 'Д')
      THEN
        v_result := 1;
      ELSIF (v_turn_rest.rest_in_fund_type = 'К')
      THEN
        v_result := 2;
      ELSE
        v_result := 0;
      END IF;
    ELSIF (p_type = 'IRT_BF')
    THEN
      IF (v_turn_rest.rest_in_base_fund_type = 'Д')
      THEN
        v_result := 1;
      ELSIF (v_turn_rest.rest_in_base_fund_type = 'К')
      THEN
        v_result := 2;
      ELSE
        v_result := 0;
      END IF;
    ELSIF (p_type = 'IRT_Q')
    THEN
      IF (v_turn_rest.rest_in_qty_type = 'Д')
      THEN
        v_result := 1;
      ELSIF (v_turn_rest.rest_in_qty_type = 'К')
      THEN
        v_result := 2;
      ELSE
        v_result := 0;
      END IF;
    ELSIF (p_type = 'TD_F')
    THEN
      v_result := v_turn_rest.turn_dt_fund;
    ELSIF (p_type = 'TD_BF')
    THEN
      v_result := v_turn_rest.turn_dt_base_fund;
    ELSIF (p_type = 'TD_Q')
    THEN
      v_result := v_turn_rest.turn_dt_qty;
    ELSIF (p_type = 'TC_F')
    THEN
      v_result := v_turn_rest.turn_ct_fund;
    ELSIF (p_type = 'TC_BF')
    THEN
      v_result := v_turn_rest.turn_ct_base_fund;
    ELSIF (p_type = 'TC_Q')
    THEN
      v_result := v_turn_rest.turn_ct_qty;
    ELSIF (p_type = 'OR_F')
    THEN
      IF (p_char = 'А')
      THEN
        IF v_turn_rest.rest_out_fund_type = 'Д'
        THEN
          v_result := v_turn_rest.rest_out_fund;
        ELSE
          v_result := -v_turn_rest.rest_out_fund;
        END IF;
      ELSE
        IF v_turn_rest.rest_out_fund_type = 'К'
        THEN
          v_result := v_turn_rest.rest_out_fund;
        ELSE
          v_result := -v_turn_rest.rest_out_fund;
        END IF;
      END IF;
    ELSIF (p_type = 'OR_BF')
    THEN
      IF (p_char = 'А')
      THEN
        IF v_turn_rest.rest_out_base_fund_type = 'Д'
        THEN
          v_result := v_turn_rest.rest_out_base_fund;
        ELSE
          v_result := -v_turn_rest.rest_out_base_fund;
        END IF;
      ELSE
        IF v_turn_rest.rest_out_base_fund_type = 'К'
        THEN
          v_result := v_turn_rest.rest_out_base_fund;
        ELSE
          v_result := -v_turn_rest.rest_out_base_fund;
        END IF;
      END IF;
    ELSIF (p_type = 'OR_Q')
    THEN
      IF (p_char = 'А')
      THEN
        IF v_turn_rest.rest_out_qty_type = 'Д'
        THEN
          v_result := v_turn_rest.rest_out_qty;
        ELSE
          v_result := -v_turn_rest.rest_out_qty;
        END IF;
      ELSE
        IF v_turn_rest.rest_out_qty_type = 'К'
        THEN
          v_result := v_turn_rest.rest_out_qty;
        ELSE
          v_result := -v_turn_rest.rest_out_qty;
        END IF;
      END IF;
    ELSIF (p_type = 'OR_F_')
    THEN
      v_result := v_turn_rest.rest_out_fund;
    ELSIF (p_type = 'OR_BF_')
    THEN
      v_result := v_turn_rest.rest_out_base_fund;
    ELSIF (p_type = 'OR_Q_')
    THEN
      v_result := v_turn_rest.rest_out_qty;
    ELSIF (p_type = 'ORT_F')
    THEN
      IF (v_turn_rest.rest_out_fund_type = 'Д')
      THEN
        v_result := 1;
      ELSIF (v_turn_rest.rest_out_fund_type = 'К')
      THEN
        v_result := 2;
      ELSE
        v_result := 0;
      END IF;
    ELSIF (p_type = 'ORT_BF')
    THEN
      IF (v_turn_rest.rest_out_base_fund_type = 'Д')
      THEN
        v_result := 1;
      ELSIF (v_turn_rest.rest_out_base_fund_type = 'К')
      THEN
        v_result := 2;
      ELSE
        v_result := 0;
      END IF;
    ELSIF (p_type = 'ORT_Q')
    THEN
      IF (v_turn_rest.rest_out_qty_type = 'Д')
      THEN
        v_result := 1;
      ELSIF (v_turn_rest.rest_out_qty_type = 'К')
      THEN
        v_result := 2;
      ELSE
        v_result := 0;
      END IF;
    ELSE
      v_result := 0;
    END IF;
    RETURN v_result;
  END;

  --Расчитать ключевой разряд в банковском счете
  FUNCTION get_key_account
  (
    p_bic     VARCHAR2
   ,p_account VARCHAR2
  ) RETURN VARCHAR2 IS
    v_temp_acc    VARCHAR2(23);
    v_multi       VARCHAR2(23);
    i             NUMBER;
    v_number      NUMBER;
    v_temp_number NUMBER;
    v_result      VARCHAR2(20);
  BEGIN
    IF ((length(p_bic) = 3) AND (length(p_account) = 20))
    THEN
      v_temp_acc := p_bic || substr(p_account, 1, 8) || '0' || substr(p_account, 10, 11);
      v_multi    := '71371371371371371371371';
      v_number   := 0;
      FOR i IN 1 .. 23
      LOOP
        BEGIN
          v_temp_number := to_number(substr(v_temp_acc, i, 1)) * to_number(substr(v_multi, i, 1));
        EXCEPTION
          WHEN OTHERS THEN
            v_temp_number := 0;
        END;
        v_number := v_number + v_temp_number;
      END LOOP;
      v_result := TRIM(to_char(v_number));
      v_result := substr(v_result, length(v_result), 1);
      v_number := to_number(v_result) * 3;
      v_result := TRIM(to_char(v_number));
      v_result := substr(v_result, length(v_result), 1);
      v_result := substr(p_account, 1, 8) || v_result || substr(p_account, 10, 11);
    ELSE
      v_result := '';
    END IF;
    RETURN v_result;
  END;

  --Установка соответствующих признаков всем дочерним счетам
  PROCEDURE set_attr_inherit_child_acc
  (
    p_account_id NUMBER
   ,p_is_char    NUMBER
   ,p_is_an      NUMBER
  ) IS
    v_account account%ROWTYPE;
  BEGIN
    SELECT * INTO v_account FROM account a WHERE a.account_id = p_account_id;
    IF (p_is_char = 1)
    THEN
      BEGIN
        UPDATE account a
           SET a.characteristics = v_account.characteristics
         WHERE a.account_id IN (SELECT aa.account_id
                                  FROM account aa
                                 WHERE aa.acc_chart_type_id = v_account.acc_chart_type_id
                                 START WITH aa.parent_id = p_account_id
                                CONNECT BY PRIOR aa.account_id = aa.parent_id);
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
    END IF;
  
    IF (p_is_an = 1)
    THEN
      BEGIN
        UPDATE account a
           SET a.a1_analytic_type_id = v_account.a1_analytic_type_id
              ,a.a2_analytic_type_id = v_account.a2_analytic_type_id
              ,a.a3_analytic_type_id = v_account.a3_analytic_type_id
              ,a.a4_analytic_type_id = v_account.a4_analytic_type_id
              ,a.a5_analytic_type_id = v_account.a5_analytic_type_id
              ,a.a1_ure_id           = v_account.a1_ure_id
              ,a.a2_ure_id           = v_account.a2_ure_id
              ,a.a3_ure_id           = v_account.a3_ure_id
              ,a.a4_ure_id           = v_account.a4_ure_id
              ,a.a5_ure_id           = v_account.a5_ure_id
         WHERE a.account_id IN (SELECT aa.account_id
                                  FROM account aa
                                 WHERE aa.acc_chart_type_id = v_account.acc_chart_type_id
                                 START WITH aa.parent_id = p_account_id
                                CONNECT BY PRIOR aa.account_id = aa.parent_id);
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
    END IF;
  
  END;

  --Найти счет по связи счетов
  FUNCTION get_account_by_mask
  (
    p_account_id            NUMBER
   ,p_acc_chart_type_id     NUMBER
   ,p_rev_acc_chart_type_id NUMBER
  ) RETURN NUMBER IS
    v_account        account%ROWTYPE;
    v_rel_acc        rel_acc%ROWTYPE;
    v_rev_account_id NUMBER;
    --v_Rev_Account_num varchar2(50);
    CURSOR c_rel_acc
    (
      p_account_num VARCHAR2
     ,p_acc_char    VARCHAR2
    ) IS
      SELECT ra.*
        FROM rel_acc ra
            ,account a
       WHERE p_account_num LIKE ra.acc_mask
         AND ra.account_id = a.account_id
         AND a.acc_chart_type_id = p_rev_acc_chart_type_id
         AND (ra.characteristics = p_acc_char OR ra.characteristics IS NULL)
         AND ra.is_not = 0
         AND ra.acc_chart_type_id = p_acc_chart_type_id
         AND (acc.mask_sign_count(ra.acc_mask) =
             (SELECT MAX(acc.mask_sign_count(ras.acc_mask))
                 FROM rel_acc ras
                     ,account ass
                WHERE p_account_num LIKE ras.acc_mask
                  AND ras.account_id = ass.account_id
                  AND ass.acc_chart_type_id = p_rev_acc_chart_type_id
                  AND (ras.characteristics = p_acc_char OR ras.characteristics IS NULL)
                  AND ras.is_not = 0
                  AND ras.acc_chart_type_id = p_acc_chart_type_id))
         AND ra.account_id NOT IN
             (SELECT ral.account_id
                FROM rel_acc ral
                    ,account al
               WHERE p_account_num LIKE ral.acc_mask
                 AND ral.account_id = al.account_id
                 AND al.acc_chart_type_id = p_rev_acc_chart_type_id
                 AND (ral.characteristics = p_acc_char OR ral.characteristics IS NULL)
                 AND ral.is_not = 1
                 AND ral.acc_chart_type_id = p_acc_chart_type_id
                 AND (acc.mask_sign_count(ral.acc_mask) =
                     (SELECT MAX(acc.mask_sign_count(rasl.acc_mask))
                         FROM rel_acc rasl
                             ,account asl
                        WHERE p_account_num LIKE rasl.acc_mask
                          AND rasl.account_id = asl.account_id
                          AND asl.acc_chart_type_id = p_rev_acc_chart_type_id
                          AND (rasl.characteristics = p_acc_char OR rasl.characteristics IS NULL)
                          AND rasl.is_not = 1
                          AND rasl.acc_chart_type_id = p_acc_chart_type_id)));
  BEGIN
    --Получить счет для подбора
    SELECT * INTO v_account FROM account a WHERE a.account_id = p_account_id;
    --Открыть курсор
    v_rev_account_id := NULL;
    OPEN c_rel_acc(v_account.num, v_account.characteristics);
    LOOP
      FETCH c_rel_acc
        INTO v_rel_acc;
      EXIT WHEN c_rel_acc%NOTFOUND;
      v_rev_account_id := v_rel_acc.account_id;
    END LOOP;
    CLOSE c_rel_acc;
    RETURN v_rev_account_id;
  END;

  --Количество значащих символов в маске счета
  FUNCTION mask_sign_count(p_mask VARCHAR2) RETURN NUMBER IS
    j NUMBER;
  BEGIN
    j := 0;
    FOR i IN 1 .. length(p_mask)
    LOOP
      IF (substr(p_mask, i, 1) NOT IN ('%', '_'))
      THEN
        j := j + 1;
      END IF;
    END LOOP;
    RETURN j;
  END;

  --Проверка на присутствие аналитики в счете
  FUNCTION is_valid_analytic
  (
    p_analytic_type_id NUMBER
   ,p_uro_id           NUMBER
   ,p_account_id       NUMBER
  ) RETURN NUMBER IS
    v_result NUMBER;
    CURSOR c IS
      SELECT a.account_id
        FROM account a
             ----
            ,analytic_type att
      ----
       WHERE (a.account_id = p_account_id)
            /*        and
                    (
                      ((a.a1_analytic_type_id = p_Analytic_Type_ID) and (a.a1_uro_id = p_URO_ID))
                      or
                      ((a.a2_analytic_type_id = p_Analytic_Type_ID) and (a.a2_uro_id = p_URO_ID))
                      or
                      ((a.a3_analytic_type_id = p_Analytic_Type_ID) and (a.a3_uro_id = p_URO_ID))
                      or
                      ((a.a4_analytic_type_id = p_Analytic_Type_ID) and (a.a4_uro_id = p_URO_ID))
                      or
                      ((a.a5_analytic_type_id = p_Analytic_Type_ID) and (a.a5_uro_id = p_URO_ID))
            */
         AND att.analytic_type_id = p_analytic_type_id
         AND (((a.a1_analytic_type_id = nvl(att.parent_an_type_id, att.analytic_type_id)) AND
             (a.a1_uro_id = p_uro_id)) OR
             ((a.a2_analytic_type_id = nvl(att.parent_an_type_id, att.analytic_type_id)) AND
             (a.a2_uro_id = p_uro_id)) OR
             ((a.a3_analytic_type_id = nvl(att.parent_an_type_id, att.analytic_type_id)) AND
             (a.a3_uro_id = p_uro_id)) OR
             ((a.a4_analytic_type_id = nvl(att.parent_an_type_id, att.analytic_type_id)) AND
             (a.a4_uro_id = p_uro_id)) OR
             ((a.a5_analytic_type_id = nvl(att.parent_an_type_id, att.analytic_type_id)) AND
             (a.a5_uro_id = p_uro_id)));
  BEGIN
    OPEN c;
    FETCH c
      INTO v_result;
    IF c%NOTFOUND
    THEN
      v_result := 0;
    ELSE
      v_result := 1;
    END IF;
    CLOSE c;
    RETURN v_result;
  END;

  --Найти роль по маске счета
  FUNCTION get_role_by_mask
  (
    p_account_num       VARCHAR2
   ,p_acc_char          VARCHAR2
   ,p_acc_chart_type_id NUMBER
  ) RETURN NUMBER IS
    --v_Acc_Role        Acc_Role%rowtype;
    v_rel_acc_role    rel_acc_role%ROWTYPE;
    v_rev_acc_role_id NUMBER;
    --v_Rev_Account_num varchar2(50);
    CURSOR c_rel_acc_role IS
      SELECT *
        FROM rel_acc_role rar
       WHERE p_account_num LIKE rar.acc_mask
         AND (rar.characteristics = p_acc_char OR rar.characteristics IS NULL)
         AND rar.is_not = 0
         AND rar.acc_chart_type_id = p_acc_chart_type_id
         AND (acc.mask_sign_count(rar.acc_mask) =
             (SELECT MAX(acc.mask_sign_count(rars.acc_mask))
                 FROM rel_acc_role rars
                WHERE p_account_num LIKE rars.acc_mask
                  AND (rars.characteristics = p_acc_char OR rars.characteristics IS NULL)
                  AND rars.is_not = 0
                  AND rars.acc_chart_type_id = p_acc_chart_type_id))
         AND rar.acc_role_id NOT IN
             (SELECT rar1.acc_role_id
                FROM rel_acc_role rar1
               WHERE p_account_num LIKE rar1.acc_mask
                 AND (rar1.characteristics = p_acc_char OR rar1.characteristics IS NULL)
                 AND rar1.is_not = 1
                 AND rar1.acc_chart_type_id = p_acc_chart_type_id
                 AND (acc.mask_sign_count(rar1.acc_mask) =
                     (SELECT MAX(acc.mask_sign_count(rars1.acc_mask))
                         FROM rel_acc_role rars1
                        WHERE p_account_num LIKE rars1.acc_mask
                          AND (rars1.characteristics = p_acc_char OR rars1.characteristics IS NULL)
                          AND rars1.is_not = 1
                          AND rars1.acc_chart_type_id = p_acc_chart_type_id)));
  BEGIN
    v_rev_acc_role_id := NULL;
    OPEN c_rel_acc_role;
    LOOP
      FETCH c_rel_acc_role
        INTO v_rel_acc_role;
      EXIT WHEN c_rel_acc_role%NOTFOUND;
      v_rev_acc_role_id := v_rel_acc_role.acc_role_id;
    END LOOP;
    CLOSE c_rel_acc_role;
    RETURN v_rev_acc_role_id;
  END;

  --Обновить роли счетов в плане счетов, согласно заведенным маскам
  PROCEDURE refresh_acc_roles(p_acc_chart_type_id NUMBER) IS
  BEGIN
    UPDATE account a
       SET a.acc_role_id = acc.get_role_by_mask(a.num, a.characteristics, a.acc_chart_type_id)
     WHERE a.acc_chart_type_id = p_acc_chart_type_id
       AND length(a.num) = 20;
    COMMIT;
  END;

  --Унаследовать признаки родительского счета дочерним счетам
  PROCEDURE update_nested_accounts(p_account_id NUMBER) IS
    v_account_id     NUMBER;
    v_parent_account account%ROWTYPE;
    CURSOR c IS
      SELECT a.account_id
        FROM account a
       START WITH a.parent_id = p_account_id
      CONNECT BY PRIOR a.account_id = a.parent_id;
  BEGIN
    SELECT * INTO v_parent_account FROM account a WHERE a.account_id = p_account_id;
    OPEN c;
    LOOP
      FETCH c
        INTO v_account_id;
      EXIT WHEN c%NOTFOUND;
      UPDATE account a
         SET a.characteristics     = v_parent_account.characteristics
            ,a.is_revalued         = v_parent_account.is_revalued
            ,a.a1_analytic_type_id = v_parent_account.a1_analytic_type_id
            ,a.a2_analytic_type_id = v_parent_account.a2_analytic_type_id
            ,a.a3_analytic_type_id = v_parent_account.a3_analytic_type_id
            ,a.a4_analytic_type_id = v_parent_account.a4_analytic_type_id
            ,a.a5_analytic_type_id = v_parent_account.a5_analytic_type_id
            ,a.a1_ure_id           = v_parent_account.a1_ure_id
            ,a.a2_ure_id           = v_parent_account.a2_ure_id
            ,a.a3_ure_id           = v_parent_account.a3_ure_id
            ,a.a4_ure_id           = v_parent_account.a4_ure_id
            ,a.a5_ure_id           = v_parent_account.a5_ure_id
            ,a.a1_uro_id           = v_parent_account.a1_uro_id
            ,a.a2_uro_id           = v_parent_account.a2_uro_id
            ,a.a3_uro_id           = v_parent_account.a3_uro_id
            ,a.a4_uro_id           = v_parent_account.a4_uro_id
            ,a.a5_uro_id           = v_parent_account.a5_uro_id
       WHERE a.account_id = v_account_id;
    END LOOP;
    CLOSE c;
  END;

  PROCEDURE open_trans_cur_for_obj
  (
    p_ent_id IN NUMBER
   ,p_obj_id IN NUMBER
   ,p_cursor OUT t_cursor_trans
  ) IS
  BEGIN
    OPEN p_cursor FOR
      SELECT *
        FROM trans t
       WHERE (t.a1_dt_ure_id = p_ent_id AND t.a1_dt_uro_id = p_obj_id)
          OR (t.a2_dt_ure_id = p_ent_id AND t.a2_dt_uro_id = p_obj_id)
          OR (t.a3_dt_ure_id = p_ent_id AND t.a3_dt_uro_id = p_obj_id)
          OR (t.a4_dt_ure_id = p_ent_id AND t.a4_dt_uro_id = p_obj_id)
          OR (t.a5_dt_ure_id = p_ent_id AND t.a5_dt_uro_id = p_obj_id)
          OR (t.a1_ct_ure_id = p_ent_id AND t.a1_ct_uro_id = p_obj_id)
          OR (t.a2_ct_ure_id = p_ent_id AND t.a2_ct_uro_id = p_obj_id)
          OR (t.a3_ct_ure_id = p_ent_id AND t.a3_ct_uro_id = p_obj_id)
          OR (t.a4_ct_ure_id = p_ent_id AND t.a4_ct_uro_id = p_obj_id)
          OR (t.a5_ct_ure_id = p_ent_id AND t.a5_ct_uro_id = p_obj_id);
  END;

  FUNCTION get_trans_date(p_trans_date DATE) RETURN DATE IS
  BEGIN
    RETURN p_trans_date;
  END;

  FUNCTION is_trans_by_templ
  (
    p_doc_id     IN NUMBER
   ,p_oper_templ IN VARCHAR2
  ) RETURN NUMBER IS
    v_trans_count NUMBER;
  BEGIN
    v_trans_count := 0;
  
    SELECT COUNT(*)
      INTO v_trans_count
      FROM oper       o
          ,oper_templ ot
     WHERE o.oper_templ_id = ot.oper_templ_id
       AND ot.brief = p_oper_templ
       AND o.document_id = p_doc_id;
  
    RETURN v_trans_count;
  
  END;

  FUNCTION get_trans_an_id
  (
    p_trans_id      IN NUMBER
   ,p_an_type_brief IN VARCHAR2
   ,p_corr_type     IN NUMBER DEFAULT NULL
  ) RETURN NUMBER IS
    v_result NUMBER;
  BEGIN
    SELECT CASE
             WHEN dat1.brief = p_an_type_brief
                  AND (p_corr_type = 0 OR p_corr_type IS NULL) THEN
              t.a1_dt_uro_id
             WHEN dat2.brief = p_an_type_brief
                  AND (p_corr_type = 0 OR p_corr_type IS NULL) THEN
              t.a2_dt_uro_id
             WHEN dat3.brief = p_an_type_brief
                  AND (p_corr_type = 0 OR p_corr_type IS NULL) THEN
              t.a3_dt_uro_id
             WHEN dat4.brief = p_an_type_brief
                  AND (p_corr_type = 0 OR p_corr_type IS NULL) THEN
              t.a4_dt_uro_id
             WHEN dat5.brief = p_an_type_brief
                  AND (p_corr_type = 0 OR p_corr_type IS NULL) THEN
              t.a5_dt_uro_id
             WHEN cat1.brief = p_an_type_brief
                  AND (p_corr_type = 1 OR p_corr_type IS NULL) THEN
              t.a1_ct_uro_id
             WHEN cat2.brief = p_an_type_brief
                  AND (p_corr_type = 1 OR p_corr_type IS NULL) THEN
              t.a2_ct_uro_id
             WHEN cat3.brief = p_an_type_brief
                  AND (p_corr_type = 1 OR p_corr_type IS NULL) THEN
              t.a3_ct_uro_id
             WHEN cat4.brief = p_an_type_brief
                  AND (p_corr_type = 1 OR p_corr_type IS NULL) THEN
              t.a4_ct_uro_id
             WHEN cat5.brief = p_an_type_brief
                  AND (p_corr_type = 1 OR p_corr_type IS NULL) THEN
              t.a5_ct_uro_id
             ELSE
              NULL
           END
      INTO v_result
      FROM trans         t
          ,account       da
          ,account       ca
          ,analytic_type dat1
          ,analytic_type dat2
          ,analytic_type dat3
          ,analytic_type dat4
          ,analytic_type dat5
          ,analytic_type cat1
          ,analytic_type cat2
          ,analytic_type cat3
          ,analytic_type cat4
          ,analytic_type cat5
     WHERE t.trans_id = p_trans_id
       AND t.dt_account_id = da.account_id
       AND t.ct_account_id = ca.account_id
       AND da.a1_analytic_type_id = dat1.analytic_type_id(+)
       AND da.a2_analytic_type_id = dat2.analytic_type_id(+)
       AND da.a3_analytic_type_id = dat3.analytic_type_id(+)
       AND da.a4_analytic_type_id = dat4.analytic_type_id(+)
       AND da.a5_analytic_type_id = dat5.analytic_type_id(+)
       AND ca.a1_analytic_type_id = cat1.analytic_type_id(+)
       AND ca.a2_analytic_type_id = cat2.analytic_type_id(+)
       AND ca.a3_analytic_type_id = cat3.analytic_type_id(+)
       AND ca.a4_analytic_type_id = cat4.analytic_type_id(+)
       AND ca.a5_analytic_type_id = cat5.analytic_type_id(+);
    RETURN v_result;
  END;

  /*
  * Стандартная процедуры сторнирования
  * Заявка 349609 + небольшой рефакторинг
  * @author Байтин А.
  * @task 349609
  */
  PROCEDURE storno_trans(par_oper_id NUMBER) IS
    c_reg_date CONSTANT oper.reg_date%TYPE := SYSDATE;
    vr_oper           dml_oper.tt_oper;
    vr_trans          dml_trans.tt_trans;
    v_is_oper_created BOOLEAN := FALSE;
  BEGIN
    vr_oper := dml_oper.get_record(par_oper_id);
  
    vr_oper.oper_templ_id := gcr_oper_templ.oper_templ_id;
    vr_oper.name          := gcr_oper_templ.name;
    vr_oper.reg_date      := c_reg_date;
  
    FOR transes IN (SELECT t.*
                      FROM trans t
                     WHERE t.oper_id = par_oper_id
                       AND t.storned_id IS NULL
                       AND NOT EXISTS
                     (SELECT NULL FROM trans t2 WHERE t2.storned_id = t.trans_id))
    LOOP
    
      IF v_is_oper_created
      THEN
        vr_oper.doc_status_ref_id := doc.get_last_doc_status_ref_id(vr_oper.document_id);
        dml_oper.insert_record(vr_oper);
        v_is_oper_created := TRUE;
      END IF;
    
      vr_trans                := transes;
      vr_trans.trans_amount   := -vr_trans.trans_amount;
      vr_trans.acc_amount     := -vr_trans.acc_amount;
      vr_trans.trans_quantity := -vr_trans.trans_quantity;
      vr_trans.reg_date       := c_reg_date;
      vr_trans.oper_id        := vr_oper.oper_id;
      vr_trans.note           := 'Сторно проводки: ' || transes.trans_id;
      vr_trans.storned_id     := transes.trans_id;
    
      dml_trans.insert_record(vr_trans);
    END LOOP;
  END storno_trans;

  /* DEPRECATED
  * Ошибочная процедура сторнирования
  *
  * Выделил нестандартный блок из storno_trans
  * Использование этой процедуры - ошибка. 
  * Стандартная процедура сторнирования на вход принимает только oper_id 
  * и сама определяет пусть сторнирования.
  * @author Капля П. 
  * @date 29.01.2015
  */
  PROCEDURE storno_trans
  (
    par_oper_id      NUMBER
   ,par_trans_amount NUMBER
   ,par_acc_amount   NUMBER
  ) IS
    c_reg_date CONSTANT oper.reg_date%TYPE := SYSDATE;
    vr_oper  dml_oper.tt_oper;
    vr_trans dml_trans.tt_trans;
  BEGIN
    vr_oper := dml_oper.get_record(par_oper_id);
  
    vr_oper.oper_templ_id := gcr_oper_templ.oper_templ_id;
    vr_oper.name          := gcr_oper_templ.name;
    vr_oper.reg_date      := c_reg_date;
  
    vr_oper.doc_status_ref_id := doc.get_last_doc_status_ref_id(vr_oper.document_id);
    dml_oper.insert_record(vr_oper);
  
    FOR transes IN (SELECT t.* FROM trans t WHERE t.oper_id = par_oper_id)
    LOOP
    
      vr_trans                := transes;
      vr_trans.trans_amount   := -nvl(par_trans_amount, vr_trans.trans_amount);
      vr_trans.acc_amount     := -nvl(par_acc_amount, vr_trans.acc_amount);
      vr_trans.trans_quantity := -vr_trans.trans_quantity;
      vr_trans.reg_date       := c_reg_date;
      vr_trans.oper_id        := vr_oper.oper_id;
      vr_trans.note           := 'Сторно проводки: ' || transes.trans_id;
      vr_trans.storned_id     := transes.trans_id;
    
      dml_trans.insert_record(vr_trans);
    END LOOP;
  END storno_trans;

  -- Байтин А.
  -- Сторнирование, с привязкой операции к другому документу, например, к другой версии ДС
  -- За основу взята процедура из PKG_RENLIFE_UTILS + добавлен параметр №документа
  /*FUNCTION storno_trans
  (
    par_oper_id      NUMBER
   ,par_date         DATE
   ,par_document_id  NUMBER
   ,par_trans_amount NUMBER DEFAULT NULL
   ,par_acc_amount   NUMBER DEFAULT NULL
  ) RETURN NUMBER IS
    proc_name VARCHAR2(20) := 'storno_trans';
    --  v_trans trans%rowtype;
    v_storno_oper_id  PLS_INTEGER;
    v_storno_trans_id PLS_INTEGER;
    v_storno_date     DATE;
  BEGIN
    SELECT nvl(par_date, doc.get_last_doc_status_date(document_id))
      INTO v_storno_date
      FROM oper
     WHERE oper_id = par_oper_id;
  
    FOR transes IN (SELECT t.* FROM trans t WHERE t.oper_id = par_oper_id)
    LOOP
      IF v_storno_oper_id IS NULL
      THEN
        SELECT sq_oper.nextval INTO v_storno_oper_id FROM dual;
      
        INSERT INTO oper
          (oper_id, oper_templ_id, document_id, reg_date, oper_date, doc_status_ref_id, NAME)
          SELECT v_storno_oper_id
                ,ot.oper_templ_id
                ,par_document_id
                ,SYSDATE
                ,v_storno_date
                ,doc.get_last_doc_status_ref_id(par_document_id)
                ,NAME
            FROM oper_templ ot
           WHERE ot.brief = 'Аннулирование';
      END IF;
      v_storno_trans_id := transes.trans_id;
      SELECT sq_trans.nextval
            ,-nvl(par_trans_amount, transes.trans_amount)
            ,-nvl(par_acc_amount, transes.acc_amount)
            ,-transes.trans_quantity
            ,0
            ,SYSDATE
            ,v_storno_oper_id
            ,v_storno_date
            ,'Сторно проводки: ' || v_storno_trans_id
            ,v_storno_trans_id
        INTO transes.trans_id
            ,transes.trans_amount
            ,transes.acc_amount
            ,transes.trans_quantity
            ,transes.is_closed
            ,transes.reg_date
            ,transes.oper_id
            ,transes.trans_date
            ,transes.note
            ,transes.storned_id
        FROM dual;
      INSERT INTO trans VALUES transes;
    END LOOP;
    RETURN(v_storno_oper_id);
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001, 'Ошибка при выполнении ' || proc_name);
  END storno_trans;*/

  /** Процедура позволяет/запрещает изменять проводки в закрытом периоде
  *   273031: Изменение триггера контроля закрытого периода в
  *   @param par_is_set - если 1, то проводки можно изменять в закрытом периоде
  *                     - если 0, то проводки нельзя изменять в закрытом периоде
  */
  PROCEDURE set_can_change_trans_in_closed(par_is_set BOOLEAN) IS
  BEGIN
    gv_allow_change_in_closed := nvl(par_is_set, FALSE);
  END;

  /** Процедура получает значение о возможности изменять проводки в закрытом периоде
  *   273031: Изменение триггера контроля закрытого периода в
  *   @param par_is_set - если 1, то проводки можно изменять в закрытом периоде
  *                     - если 0, то проводки нельзя изменять в закрытом периоде
  */
  FUNCTION get_can_change_trans_in_closed RETURN BOOLEAN IS
  BEGIN
    RETURN gv_allow_change_in_closed;
  END;

BEGIN
  doc_ent_id := ent.id_by_brief('DOCUMENT');
END acc_new;
/

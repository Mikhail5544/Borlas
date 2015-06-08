CREATE OR REPLACE PACKAGE pkg_agent IS
  v_contract_id  NUMBER;
  STATUS_NEW     VARCHAR2(10) := 'NEW'; --Brief статуса Новый документа
  STATUS_RESUME  VARCHAR2(10) := 'RESUME'; --Brief статуса Возобновлен
  STATUS_CURRENT VARCHAR2(10) := 'CURRENT'; --Brief статуса Действующий
  STATUS_BREAK   VARCHAR2(10) := 'BREAK'; --Brief статуса расторгнут
  STATUS_STOP    VARCHAR2(10) := 'STOP'; --Brief статуса приостановлен

  /**
  * Работа с агентскими договорами - создание, редактирование, удаление, изменения статусов
  * @author Budkova A.
  * @version 1
  */

  /**
   * Перевод договор из статуса Новый в Действующий.
   * @author Budkova A.
   * @param p_doc_id       ИД договора
   * @param p_status_date  Дата начала действия статуса
  
  procedure set_contract_status(p_doc_id in number,
                                p_status_date IN DATE DEFAULT SYSDATE);
  */

  --Обновляет актуальную версию договора
  PROCEDURE set_last_ver
  (
    p_contr_id   NUMBER
   ,p_version_id NUMBER
  );

  /**
  * Определяет статус последней версии договора
  * @author Budkova A.
  * @param p_contr_id ИД договора
  * @return ИД статуса
  */
  FUNCTION get_status_contr(p_contr_id NUMBER) RETURN NUMBER;

  /**
  * Определяет действующую версию договора актуальную на дату
  * @author Budkova A.
  * @param p_ag_contract_header_id ИД заголовка агентского договора
  * @param p_date Дата
  * @return ИД версии договора
  */
  FUNCTION get_status_by_date
  (
    p_ag_contract_header_id NUMBER
   ,p_date                  DATE
  ) RETURN NUMBER;
  /**
  * Определяет актуальный статус договора
  * @author Budkova A.
  * @param p_contr_id ИД договора
  * @return ИД статуса
  */
  --Возвращает ИД статуса
  FUNCTION get_status_contr_activ(p_contr_id NUMBER) RETURN NUMBER;
  --Возвращает Название статуса
  FUNCTION get_status_contr_activ_name(p_contr_id NUMBER) RETURN VARCHAR2;
  --Возвращает Brief статуса
  FUNCTION get_status_contr_activ_brief(p_contr_id NUMBER) RETURN VARCHAR2;
  --Возвращает ИД актуальной версии договора
  FUNCTION get_status_contr_activ_id(p_contr_id NUMBER) RETURN NUMBER;
  /**
  * Определяет дату окончания действия договора
  * @author Budkova A.
  * @param p_contr_id ИД договора
  * @return ИД статуса
  */
  FUNCTION get_end_contr(p_contr_id NUMBER) RETURN DATE;

  /**
  * Изменение статуса версии аг. договора по ИД статуса
  * @author Budkova A.
  * @param p_doc_id       ИД версии
  * @param p_status_id    ИД нового статуса
  * @param p_status_date  Дата начала действия статуса
  */
  PROCEDURE set_version_status
  (
    p_doc_id    IN NUMBER
   ,p_status_id IN NUMBER
  );

  /**
  * Изменение статуса версии аг. договора по сокращению статуса
  * @author Budkova A.
  * @param p_doc_id        ИД версии
  * @param p_status_brief  brief нового статуса
  * @param p_status_date   Дата начала действия статуса
  */
  PROCEDURE set_version_status
  (
    p_doc_id       IN NUMBER
   , --ИД доп.соглашения
    p_status_brief IN VARCHAR2
  );

  /**
  * Генерация номера версии
  * @author Budkova A.
  * @param p_contract_id  ИД аг. договора
  * @return p_num         Номер версии
  */
  FUNCTION get_ver_num(p_contract_id IN NUMBER) RETURN VARCHAR2;

  /**
  * Получить номер договора
  * @author Budkova A.
  * @return Номер договора
  */
  FUNCTION get_num_contract RETURN VARCHAR2;
  /**
  * Определяет возможность изменения статуса версии
  * @author Budkova A.
  * @param p_version_id ИД версии
  * @return 1-да, 0-нет
  */
  FUNCTION can_be_current(p_version_id IN NUMBER) RETURN NUMBER;

  /**
  * Определяет возможность создания копии версии полиса из текущего
  * @author Budkova A.
  * @param p_version_id ИД версии
  * @return 1-да, 0-нет
  */
  FUNCTION can_be_copied(p_version_id IN NUMBER) RETURN NUMBER;
  /**
  * Определяет возможность удаления версии
  * @author Budkova A.
  * @param p_version_id ИД версии
  * @return 1-да, 0-нет
  */
  FUNCTION can_be_del(p_version_id IN NUMBER) RETURN NUMBER;
  /**
  * Добавление версии договора
  * @author Budkova A.
  * @param p_contract_id     ИД договора
  * @param p_date_begin      Дата начала действия версии
  * @param p_date_end        Дата окончания действия версии
  * @param p_status_brief    Сокращение статуса
  * @param p_class_agent_id  ИД разряд агента
  * @param p_category_id     ИД категория агента
  * @param p_note            Примечания
  * @param p_obj_id          ИД версии
  */
  PROCEDURE version_insert
  (
    p_contract_id NUMBER
   , --ИД контракта
    p_date_begin  DATE
   ,p_date_end    DATE
   ,
    -- p_status_brief varchar2 DEFAULT 'NEW',
    p_class_agent_id     NUMBER DEFAULT NULL
   ,p_category_id        NUMBER DEFAULT NULL
   ,p_note               VARCHAR2 DEFAULT NULL
   ,p_obj_id             IN OUT NUMBER
   , --ИД доп соглашения
    p_CONTRACT_LEADER_ID NUMBER DEFAULT NULL
   ,p_RATE_AGENT         NUMBER DEFAULT NULL
   ,p_RATE_MAIN_AGENT    NUMBER DEFAULT NULL
   ,p_RATE_TYPE_ID       NUMBER DEFAULT NULL
   ,p_RATE_TYPE_MAIN_ID  NUMBER DEFAULT NULL
   ,p_fact_dop_rate      NUMBER DEFAULT 0
   ,p_date_break         DATE DEFAULT SYSDATE
   ,p_signer_id          NUMBER DEFAULT NULL
   ,p_delegate_id        NUMBER DEFAULT NULL
  );

  /**
  * Изменение версии договора
  * @author Budkova A.
  * @param p_contract_id     ИД договора
  * @param p_date_begin      Дата начала действия версии
  * @param p_date_end        Дата окончания действия версии
  * @param p_status_id       ИД статуса
  * @param p_class_agent_id  ИД разряд агента
  * @param p_category_id     ИД категория агента
  * @param p_note            Примечания
  * @param p_ver_id          ИД версии
  */
  PROCEDURE version_update
  (
    p_contract_id        NUMBER
   , --ИД контракта
    p_date_begin         DATE
   ,p_date_end           DATE
   ,p_class_agent_id     NUMBER
   ,p_category_id        NUMBER
   ,p_note               VARCHAR2
   ,p_ver_id             NUMBER
   , --ИД доп соглашения
    p_CONTRACT_LEADER_ID NUMBER DEFAULT NULL
   ,p_RATE_AGENT         NUMBER DEFAULT NULL
   ,p_RATE_MAIN_AGENT    NUMBER DEFAULT NULL
   ,p_RATE_TYPE_ID       NUMBER DEFAULT NULL
   ,p_RATE_TYPE_MAIN_ID  NUMBER DEFAULT NULL
   ,p_fact_dop_rate      NUMBER DEFAULT 0
   ,p_signer_id          NUMBER DEFAULT NULL
   ,p_delegate_id        NUMBER DEFAULT NULL --,
    --p_num varchar2 default null,
    -- p_num_old varchar2 default null
  );

  /**
  * Удаление версии договора (Удаление возможно только в статусе Новый)
  * @author Budkova A.
  * @param p_ver_id        ИД версии договора
  */
  PROCEDURE version_del(p_ver_id NUMBER);

  /**
  * Добавление договора
  * @author Budkova A.
  * @param p_contr_id        ИД договора
  * @param p_vers_id         ИД версии
  * @param p_num             Номер договора
  * @param p_date_begin      Дата начала действия версии
  * @param p_date_end        Дата окончания действия версии
  * @param p_agent_id        ИД Агента
  * @param p_note            Примечания
  * @param p_class_agent_id  ИД разряд агента
  * @param p_category_id     ИД категория агента
  * @param p_CONTRACT_LEADER_ID ИД договора руководителя
  * @param p_RATE_AGENT      Ставка агента
  * @param p_RATE_MAIN_AGENT Ставка ведущего агента
  * @param p_RATE_TYPE_ID    ИД типа Ставки агента
  * @param p_RATE_TYPE_MAIN_ID ИД типа Ставки ведущего агента
  * @param p_sales_channel_id Ид канал продаж
  * @param p_AG_CONTRACT_TEMP_ID ссылка на основе какого шаблона сделан договор
  */
  PROCEDURE contract_insert
  (
    p_contr_id            OUT NUMBER
   ,p_vers_id             OUT NUMBER
   ,p_num                 VARCHAR2
   ,p_date_begin          DATE DEFAULT SYSDATE
   ,p_date_end            DATE
   ,p_agent_id            NUMBER
   ,p_date_break          DATE DEFAULT NULL
   ,p_agency_id           NUMBER DEFAULT NULL
   ,p_note                VARCHAR2 DEFAULT NULL
   ,p_class_agent_id      NUMBER DEFAULT NULL
   ,p_category_id         NUMBER DEFAULT NULL
   ,p_CONTRACT_LEADER_ID  NUMBER DEFAULT NULL
   ,p_RATE_AGENT          NUMBER DEFAULT NULL
   ,p_RATE_MAIN_AGENT     NUMBER DEFAULT NULL
   ,p_RATE_TYPE_ID        NUMBER DEFAULT NULL
   ,p_RATE_TYPE_MAIN_ID   NUMBER DEFAULT NULL
   ,p_fact_dop_rate       NUMBER DEFAULT 0
   ,p_note_ver            VARCHAR2 DEFAULT NULL
   ,p_sales_channel_id    NUMBER
   ,p_AG_CONTRACT_TEMP_ID NUMBER DEFAULT NULL
   ,p_signer_id           NUMBER DEFAULT NULL
   ,p_delegate_id         NUMBER DEFAULT NULL
  );

  /**
  * Изменение договора
  * @author Budkova A.
  * @param p_contr_id        ИД договора
  * @param p_vers_id         ИД версии
  * @param p_num             Номер договора
  * @param p_date_begin      Дата начала действия версии
  * @param p_date_end        Дата окончания действия версии
  * @param p_agent_id        ИД Агента
  * @param p_note            Примечания
  */
  PROCEDURE contract_update
  (
    p_ag_ch_id           NUMBER
   ,p_vers_id            NUMBER
   ,p_num                VARCHAR2
   ,p_date_begin         DATE
   ,p_date_end           DATE
   ,p_agent_id           NUMBER
   ,p_date_break         DATE DEFAULT NULL
   ,p_agency_id          NUMBER DEFAULT NULL
   ,p_note               VARCHAR2
   ,p_CONTRACT_LEADER_ID NUMBER DEFAULT NULL
   ,p_RATE_AGENT         NUMBER DEFAULT NULL
   ,p_RATE_MAIN_AGENT    NUMBER DEFAULT NULL
   ,p_RATE_TYPE_ID       NUMBER DEFAULT NULL
   ,p_RATE_TYPE_MAIN_ID  NUMBER DEFAULT NULL
   ,p_fact_dop_rate      NUMBER DEFAULT 0
   ,p_sales_channel_id   NUMBER
   ,p_signer_id          NUMBER DEFAULT NULL
   ,p_delegate_id        NUMBER DEFAULT NULL
  );

  /**
  * Расторжение аг.договора
  v_ch_id - ИД Аг.договора (ag_contract_header)
  */
  PROCEDURE contract_break(v_ch_id NUMBER);

  /**
  * Процедура для разработки и тестирования!!!
  * Удаляет договор и все его версии. Не содержит бизнес-логики
  * @author Budkova A.
  * @param v_contract_id ИД договора
  */
  PROCEDURE contract_del(v_contract_id NUMBER);

  /**
  * Процедура для вставки нового шаблона агентского договора
  * @author Гурьев А., декабрь 2006
  * @param p_contr_id        ИД договора
  * @param p_vers_id         ИД версии
  * @param p_agency_id       ИД агентства
  * @param p_date_begin      Дата изменения шаблона
  * @param p_sales_channel_id ИД канала продаж
  * @param p_note            Примечания
  * @param p_templ_name      Название шаблона
  * @param p_templ_brief     Brief шаблона
  */

  PROCEDURE template_insert
  (
    p_contr_id         OUT NUMBER
   ,p_vers_id          OUT NUMBER
   ,p_date_begin       DATE DEFAULT SYSDATE
   ,p_agency_id        NUMBER DEFAULT NULL
   ,p_note             VARCHAR2 DEFAULT NULL
   ,p_class_agent_id   NUMBER DEFAULT NULL
   ,p_category_id      NUMBER DEFAULT NULL
   ,p_sales_channel_id NUMBER
   ,p_TEMPL_NAME       VARCHAR2 DEFAULT NULL
   ,p_TEMPL_BRIEF      VARCHAR2 DEFAULT NULL
  );
  /**
  * Процедура для обновления шаблона агентского договора
  * @author Гурьев А., декабрь 2006
  * @param p_contr_id        ИД договора
  * @param p_vers_id         ИД версии
  * @param p_agency_id       ИД агентства
  * @param p_date_begin      Дата изменения шаблона
  * @param p_sales_channel_id ИД канала продаж
  * @param p_note            Примечания
  * @param p_templ_name      Название шаблона
  * @param p_templ_brief     Brief шаблона
  */
  PROCEDURE template_update
  (
    p_ag_ch_id         NUMBER
   ,p_vers_id          NUMBER
   ,p_date_begin       DATE
   ,p_agency_id        NUMBER DEFAULT NULL
   ,p_note             VARCHAR2
   ,p_class_agent_id   NUMBER DEFAULT NULL
   ,p_category_id      NUMBER DEFAULT NULL
   ,p_sales_channel_id NUMBER
   ,p_templ_name       VARCHAR2 DEFAULT NULL
   ,p_templ_brief      VARCHAR2 DEFAULT NULL
  );

  /**
  * Создается копия версии договора
  * @author Budkova A.
  * @param p_ver_id_old  ИД старой версии
  * @param p_ver_id_new  ИД новой версии
  */
  PROCEDURE contract_copy
  (
    p_ver_id_old  IN NUMBER
   ,p_ver_id_new  OUT NUMBER
   ,p_anyway_copy IN BOOLEAN DEFAULT FALSE
   ,p_date_break  DATE DEFAULT SYSDATE
  );

  /**
  * Заполняются таблицы Вид риска по договору, Период действия, Ставка
    (ag_prod_line_contr, ag_period_rate, ag_rate)
  * @author Budkova A.
  * @param p_ver_cont_id         ИД версии
  * @param p_insurance_group_id  ИД вида страхования
  * @param p_product_id          ИД продукта
  * @param p_product_line_id     ИД вида покрытия
  * @param p_defin_rate_id       ИД типа определения ставки
  * @param p_type_value_rate     ИД тип значения ставки
  * @param p_rule_id             ИД функции
  * @param p_rate                Значение ставки
  * @param p_db                  Дата начала действия
  * @param p_de                  Дата окончания действия
  * @param p_notes               Примечание
  */
  PROCEDURE prod_line_contr_insert( --p_AG_PROD_LINE_CONTR_ID out number,
                                   p_ver_cont_id        NUMBER
                                  ,p_insurance_group_id NUMBER
                                  ,p_product_id         NUMBER
                                  ,p_product_line_id    NUMBER
                                  ,p_defin_rate_id      NUMBER
                                  ,p_type_value_rate    NUMBER
                                  ,
                                   --   p_rule_id            number,
                                   p_rate              NUMBER
                                  ,p_db                DATE
                                  ,p_de                DATE
                                  ,p_PROD_COEF_TYPE_ID NUMBER
                                  ,p_notes             VARCHAR2);

  /**
  * Изменения таблиц Вид риска по договору, Период действия, Ставка
    (ag_prod_line_contr, ag_period_rate, ag_rate)
  * @author Budkova A.
  * @param p_ver_cont_id         ИД версии
  * @param p_prod_line_contr_id  ИД Вид риска по договору
  * @param p_insurance_group_id  ИД вида страхования
  * @param p_product_id          ИД продукта
  * @param p_product_line_id     ИД вида покрытия
  * @param p_defin_rate_id       ИД типа определения ставки
  * @param p_type_value_rate     ИД тип значения ставки
  * @param p_rule_id             ИД функции
  * @param p_ag_rate_id          ИД ставки
  * @param p_rate                Значение ставки
  * @param p_period_rate_id      ИД периода действия
  * @param p_db                  Дата начала действия
  * @param p_de                  Дата окончания действия
  */
  PROCEDURE prod_line_contr_update
  (
    p_prod_line_contr_id NUMBER
   ,p_insurance_group_id NUMBER
   ,p_product_id         NUMBER
   ,p_product_line_id    NUMBER
   ,p_defin_rate_id      NUMBER
   ,p_type_value_rate    NUMBER
   ,
    --  p_rule_id            number,
    p_ag_rate_id        NUMBER
   ,p_rate              NUMBER
   ,p_db                DATE
   ,p_de                DATE
   ,p_PROD_COEF_TYPE_ID NUMBER
   ,p_notes             VARCHAR2
  );

  /**
  * Удаление записей из таблицы Вид риска по договору
    (ag_prod_line_contr)
  * @author Budkova A.
  * @param p_ver_id        ИД версии
  * @param p_prod_line_id  ИД Вид риска по договору.
                                если null, тогда удалить все риски по этой версии
  */
  PROCEDURE prod_line_contr_del
  (
    p_ver_id       NUMBER
   ,p_prod_line_id NUMBER
  );
  /*Изменение дат покрытия
  
  */
  PROCEDURE prod_line_update_date
  (
    p_ver_id NUMBER
   ,p_db     DATE DEFAULT NULL
   ,p_de     DATE DEFAULT NULL
  );

  /** Получение ставки из агентского договора по страховому покрытию и агенту
  * @param p_coverid - ИД страхового покрытия
  * @param p_agent_id - ИД агента по договору страхования
  * @param p_date - дата вычисления значения ставки\
  * @return ИД записи в ag_prod_line_contr
  */
  FUNCTION get_agent_rate_by_cover
  (
    p_p_cover_id NUMBER
   ,p_agent_id   NUMBER
   ,p_date       DATE
  ) RETURN NUMBER;

  /** Получение значения ставки КВ
  * @param p_categ_from_id - ИД категории-источника агента
  * @param p_categ_to_id - ИД категории-приемника агента
  * @param p_product_id - ИД продукта
  * @param p_sq_year_id - ИД год выпуска
  * @param p_date - Дата, на которую получить значение ставки
  * @return Значение ставки КВ
  */
  PROCEDURE get_rate
  (
    p_categ_from_id IN NUMBER
   ,p_categ_to_id   IN NUMBER
   ,p_product_id    IN NUMBER
   ,p_sq_year_id    IN NUMBER DEFAULT 1
   ,p_date          IN DATE DEFAULT SYSDATE
   ,p_def_id        OUT NUMBER
   ,p_type_id       OUT NUMBER
   ,p_com           OUT NUMBER
  );
  /**
  * Изменение статуса заголовка договора
  * @author Budkova A.
  * @param p_doc_id       ИД заголовка
  */
  PROCEDURE set_header_status(p_doc_id IN NUMBER);

  /** Получение процента комиссии по связи категорий агентов, страховому продукту,
  *   году действия договора страхования, дате
  *   @author Kiselev P.
  *   @param p_product_id          Страховой продукт
  *   @param p_year_contract       Год действия договора
  *   @param p_ctg_source_id       Категория-источник
  *   @param p_ctg_destination_id  Категория-приемник
  *   @param p_date                Дата определения ставки
  */
  /*function get_commiss_by_ctg_rel(p_product_id number,
                                  p_year_contract number,
                                  p_ctg_source_id number,
                                  p_ctg_destination_id number,
                                  p_date date
                                 ) return number;
  */

  /** Функция считает сумму комиссии для начисления руководящему агенту от подчинённого агент
  *   @author Kiselev P
  *   @param p_ag_contract_source_id ИД агентского договора от которого идут деньги
  *   @param p_ag_contract_dest_id   ИД агентского договора которому идут деньги
  *   @param p_date                  Дата
  *
  */
  PROCEDURE make_comiss_to_manager(p_akt_agent_id IN NUMBER);

  /* Возвращает ID статуса агентского договора по brief
  *   @author Гурьев Андрей
  */
  FUNCTION get_aps_id_by_brief(par_brief IN VARCHAR2) RETURN NUMBER;

  /* Возвращает статус агентского договора по P_POLICY_AGENT_ID
  *   @author Гурьев Андрей, декабрь 2006
  */
  FUNCTION get_status_agent_policy(par_POLICY_AGENT_ID IN NUMBER) RETURN NUMBER;

  --Вспомогательная процедура
  FUNCTION get_id RETURN NUMBER;
  PROCEDURE get_parameter(p_contract_id NUMBER);

  /*  Передает агентский договор по договору страхования от одного агента к другому
   * @author Гурьев Андрей,   декабрь 2006
   *  @param = pv_policy_header_id ИД заголовка договора страхования
   *  @param = p_old_AG_CONTRACT_HEADER_ID ИД агентского договора от которого передается
   *  @param = p_new_AG_CONTRACT_HEADER_ID ИД агентского договора которому передается
   *  @param = p_date_break - дата расторжения договора с первым агентом и передача договора второму агенту
   *  @param = msg - выходной параметр для сообщений клиенту по ходу работы
   *  @return : <0 - код ошибки sqlcode , =0 если всё ОК, >0 если ошибка в логике
  */
  FUNCTION Transmit_Policy
  (
    pv_policy_header_id         IN NUMBER
   ,p_old_AG_CONTRACT_HEADER_ID IN NUMBER
   ,p_new_AG_CONTRACT_HEADER_ID IN NUMBER
   ,p_date_break                IN DATE
   ,msg                         OUT VARCHAR2
  ) RETURN NUMBER;

  /*  Определяет страховые программы для агента по договору страхования
     * @author Гурьев Андрей,   декабрь 2006
     * @param pv_policy_agent_id ИД записи агента по договору страхования
     * @param p_ag_contract_header_id ИД агентского договора
     * @param p_cur_date Дата на которую ищется активный агентский договор
     @return - код ошибки sqlcode или 0 если всё ОК
  */
  FUNCTION Define_Agent_Prod_Line
  (
    pv_policy_agent_id      IN NUMBER
   ,p_ag_contract_header_id IN NUMBER
   ,p_cur_date              IN DATE DEFAULT SYSDATE
  ) RETURN NUMBER;
  /* Определяет есть ли неопределенные ставки КВ для агента
     * @author Гурьев Андрей,   декабрь 2006
     * @param = p_policy_header_id ИД записи заголовка договора страхования
     * @param = p_ag_contract_header_id ИД заголовка агентского договора который надо проверить
     *  @return : <0 - код ошибки sqlcode , =0 если неопределенные ставки КВ не найдены, >0 - число неопределенных ставок КВ
  */
  FUNCTION check_defined_commission
  (
    p_policy_header_id      IN NUMBER
   ,p_ag_contract_header_id IN NUMBER
  ) RETURN NUMBER;

  /* Определяет договоры, по которым агент идет вторым. Если нет других договоров,
       то осуществляется перевод долей агента на первого.
     * @author Гурьев Андрей,   декабрь 2006
     * @param = p_ag_contract_header_id ИД заголовка агентского договора который надо проверить
     *  @return : 1 - если были найдены договоры, по которым агент не является вторым, а так же если возникли ошибки
                  0 - если были найдены только договора, по которым агент второй и доли были успешно переведены на первого агента.
  */

  FUNCTION policy_check_trans(p_ag_contract_header_id NUMBER) RETURN NUMBER;

  /* Определяет и возвраащает ID статуса агента
   * при изменениии категории автоматически устанавливается статус равный наименьшему статусу данной категории
   * создает в таблице history соотествующщую запись, при ее отсутствии.
   * @author Шидловская Татьяна
   * @param = p_ag_contract_header_id ИД заголовка агентского договора который надо проверить
  */

  FUNCTION find_id_agent_status(p_ag_contract_header_id NUMBER) RETURN NUMBER;

  FUNCTION UpdateContract(p_rec VEN_AG_CONTRACT%ROWTYPE) RETURN NUMBER;
  FUNCTION UpdateContractHeader(p_rec VEN_AG_CONTRACT_HEADER%ROWTYPE) RETURN NUMBER;

  FUNCTION GetAgContract(p_id NUMBER) RETURN VEN_AG_CONTRACT%ROWTYPE;
  FUNCTION GetAgContractHeader(p_id NUMBER) RETURN VEN_AG_CONTRACT_HEADER%ROWTYPE;

  FUNCTION CopyTemplateToContractByBrief
  (
    p_brief      IN VARCHAR2
   ,p_ver_id_new OUT NUMBER
  ) RETURN NUMBER;
  FUNCTION CopyTemplateToContractById
  (
    p_id         IN NUMBER
   ,p_ver_id_new OUT NUMBER
  ) RETURN NUMBER;
  FUNCTION template_to_contract_copy
  (
    p_header_id_old IN NUMBER
   ,p_ver_id_new    OUT NUMBER
  ) RETURN NUMBER;

  FUNCTION UpdateVersionContractHeader
  (
    p_ag_header_id    NUMBER
   ,p_contract_new_id NUMBER
  ) RETURN NUMBER;
  FUNCTION GetLastAgContractByHeader(p_header_id NUMBER) RETURN VEN_AG_CONTRACT%ROWTYPE;

  FUNCTION CreateContractByTemplateId
  (
    p_ag_header_id    IN NUMBER
   ,p_tempalte_id     IN NUMBER
   ,p_contract_new_id OUT NUMBER
  ) RETURN NUMBER;
  FUNCTION CreateContractHeadByTemplId
  (
    p_template_id      IN NUMBER
   ,p_sales_channel_id IN NUMBER
   ,p_date_begin       IN DATE
   ,p_agent_id         IN NUMBER
   ,p_ag_header_id     OUT NUMBER
   ,p_contract_new_id  OUT NUMBER
  ) RETURN NUMBER;

END pkg_agent;
/
CREATE OR REPLACE PACKAGE BODY pkg_agent IS

  --Обновляет актуальную версию договора
  PROCEDURE set_last_ver
  (
    p_contr_id   NUMBER
   ,p_version_id NUMBER
  ) IS
    err  NUMBER;
    v_br VARCHAR2(30);
    v_sd DATE;
  BEGIN
    BEGIN
      UPDATE ven_ag_contract_header
         SET last_ver_id = p_version_id
       WHERE ag_contract_header_id = p_contr_id;
    EXCEPTION
      WHEN OTHERS THEN
        raise_application_error(err
                               ,'Не обновляется действующая версия договора. ' || SQLERRM(err));
    END;
    SELECT brief
          ,start_date
      INTO v_br
          ,v_sd
      FROM (SELECT dsr.brief
                  ,ds.start_date
              FROM ven_doc_status     ds
                  ,ven_doc_status_ref dsr
             WHERE ds.document_id = p_version_id
               AND ds.doc_status_ref_id = dsr.doc_status_ref_id
             ORDER BY ds.change_date DESC)
     WHERE rownum = 1;
    doc.set_doc_status(p_contr_id, v_br, v_sd);
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE < -20000
      THEN
        err := SQLCODE;
      ELSE
        err := SQLCODE - 20000;
      END IF;
      raise_application_error(err
                             ,'Не обновляется действующая версия договора. ' || SQLERRM(err));
  END;

  --Изменяем статус версии с Нового на другой
  PROCEDURE set_current_status
  (
    p_ver_id       IN NUMBER
   ,p_status_brief VARCHAR2
  ) IS
    v_contr_id NUMBER;
  BEGIN
    IF can_be_current(p_ver_id) = 1
    THEN
      -- устанавливаем статус
      doc.set_doc_status(p_ver_id, p_status_brief);
      -- в шапке устанавливаем ссылку на действующую версию
      SELECT c.contract_id INTO v_contr_id FROM ven_ag_contract c WHERE c.ag_contract_id = p_ver_id;
    
      set_last_ver(v_contr_id, p_ver_id);
      -- else
      --  raise_application_error(-20002,
      --                        'Невозможно изменить статус текущей версии');
    END IF;
  END;

  FUNCTION get_num_contract RETURN VARCHAR2 IS
    ret_val VARCHAR2(255);
  BEGIN
    SELECT sq_ag_contract_num.nextval INTO ret_val FROM dual;
    RETURN ret_val;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  FUNCTION get_status_contr(p_contr_id NUMBER) RETURN NUMBER IS
    v_status_id NUMBER;
    v_last_ver  NUMBER;
  BEGIN
    SELECT ch.last_ver_id
      INTO v_last_ver
      FROM ven_ag_contract_header ch
     WHERE ch.ag_contract_header_id = p_contr_id;
  
    v_status_id := doc.get_doc_status_ID(v_last_ver);
  
    RETURN v_status_id;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN NULL;
  END;

  FUNCTION get_status_contr_activ_name(p_contr_id NUMBER) RETURN VARCHAR2 IS
    v_status_id NUMBER;
    v_status1   VARCHAR2(50);
  BEGIN
    v_status_id := get_status_contr_activ(p_contr_id);
    SELECT NAME INTO v_status1 FROM doc_status_ref WHERE doc_status_ref_id = v_status_id;
    RETURN v_status1;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN NULL;
  END;

  FUNCTION get_status_contr_activ_brief(p_contr_id NUMBER) RETURN VARCHAR2 IS
    v_status_id NUMBER;
    v_status1   VARCHAR2(50);
  BEGIN
    v_status_id := get_status_contr_activ(p_contr_id);
    SELECT r.brief INTO v_status1 FROM doc_status_ref r WHERE doc_status_ref_id = v_status_id;
    RETURN v_status1;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN NULL;
  END;
  /*Каткевич А.Г. 
  depricated
  Не использовать - возвращает не корректные результаты*/
  FUNCTION get_status_by_date
  (
    p_ag_contract_header_id NUMBER
   ,p_date                  DATE
  ) RETURN NUMBER IS
    v_ch_num      VARCHAR2(25);
    v_cont_ver_id NUMBER;
  BEGIN
  
    v_cont_ver_id := pkg_agent_1.get_status_by_date(p_ag_contract_header_id, p_date);
    RETURN v_cont_ver_id;
  
    SELECT ch.num
      INTO v_ch_num
      FROM ven_ag_contract_header ch
     WHERE ch.ag_contract_header_id = p_ag_contract_header_id;
  
    SELECT c1.ag_contract_id
      INTO v_cont_ver_id
      FROM ven_ag_contract c1
     WHERE c1.num = (SELECT MAX(c.num) num
                       FROM ven_ag_contract c
                      WHERE c.contract_id = p_ag_contract_header_id
                        AND doc.get_doc_status_brief(c.ag_contract_id) <> STATUS_NEW
                        AND to_date(c.date_begin) <= to_date(p_date))
          --??? не понятно к чему это условие тут --and doc.get_doc_status_brief(c1.ag_contract_id) in (STATUS_RESUME,STATUS_CURRENT)
       AND c1.contract_id = p_ag_contract_header_id;
    RETURN v_cont_ver_id;
  
  EXCEPTION
    WHEN no_data_found THEN
      RETURN 0;
      --when others then return 0;
  
  END;

  FUNCTION get_status_contr_activ(p_contr_id NUMBER) RETURN NUMBER IS
    v_status_id NUMBER;
    v_last_ver  NUMBER;
    v_ch_num    VARCHAR2(25);
  BEGIN
    --Возвращаем ИД статуса активной версии
    v_last_ver  := get_status_contr_activ_id(p_contr_id);
    v_status_id := doc.get_doc_status_id(v_last_ver);
    /*  for v_c in (select c.ag_contract_id,
                       doc.get_doc_status_brief(c.ag_contract_id) status,
                       to_number(num) as num
                from ven_ag_contract c
                where c.contract_id=p_contr_id
                order by num)
    LOOP
       if ((v_c.num=0)
           or
           (v_c.status<>STATUS_NEW and v_c.num<>0))
       then
          v_status_id:=doc.get_doc_status_ID(V_c.ag_contract_id);
       end if;
    END LOOP; */
    RETURN v_status_id;
  END;

  FUNCTION get_status_contr_activ_id(p_contr_id NUMBER) RETURN NUMBER IS
    v_contr_id NUMBER;
    v_last_ver NUMBER;
    v_ch_num   VARCHAR2(25);
  BEGIN
    --возвращает ИД актуальной версии по договору
    SELECT ch.last_ver_id
      INTO v_contr_id
      FROM ven_ag_contract_header ch
     WHERE ch.ag_contract_header_id = p_contr_id;
    RETURN v_contr_id;
    /* for v_c in (select c.ag_contract_id,
                       doc.get_doc_status_brief(c.ag_contract_id) status,
                       to_number(num) as num
                from ven_ag_contract c
                where c.contract_id=p_contr_id
                order by num)
    LOOP
       if ((v_c.num=0)
           or
           (v_c.status<>STATUS_NEW and v_c.num<>0))
       then
          v_contr_id:=V_c.ag_contract_id;
       end if;
    END LOOP;
    return v_contr_id;
    */
  END;

  FUNCTION get_end_contr(p_contr_id NUMBER) RETURN DATE IS
    de DATE;
  BEGIN
    SELECT c.date_end
      INTO de
      FROM ven_ag_contract c
     WHERE c.ag_contract_id = (SELECT h.last_ver_id
                                 FROM ven_ag_contract_header h
                                WHERE h.ag_contract_header_id = p_contr_id);
    RETURN de;
  END;

  PROCEDURE set_version_status
  (
    p_doc_id    IN NUMBER
   , --ИД доп.соглашения
    p_status_id IN NUMBER
  ) IS
    v_header_id NUMBER;
    de          DATE;
    err         NUMBER;
  BEGIN
    IF can_be_current(p_doc_id) = 1
    THEN
      DOC.set_doc_status(p_doc_id, p_status_id);
    
      SELECT ac.contract_id
            ,ac.date_end
        INTO v_header_id
            ,de
        FROM ven_ag_contract ac
       WHERE ac.ag_contract_id = p_doc_id;
    
      IF get_end_contr(v_header_id) <> de
      THEN
        UPDATE ven_ag_prod_line_contr t SET t.date_end = de WHERE t.ag_contract_id = p_doc_id;
        --commit;
      END IF;
    
      set_last_ver(v_header_id, p_doc_id);
      --   else
      --  raise_application_error(-20003,
      --                          'Нельзя поменять статус данной версии');
    END IF;
  
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE < -20000
      THEN
        err := SQLCODE;
      ELSE
        err := SQLCODE - 20000;
      END IF;
      raise_application_error(err
                             ,'Не обновляется статус версии.' || chr(10) || SQLERRM(err));
    
  END;

  PROCEDURE set_version_status
  (
    p_doc_id       IN NUMBER
   , --ИД доп.соглашения
    p_status_brief IN VARCHAR2
  ) IS
    v_status_id NUMBER;
  BEGIN
    SELECT t.doc_status_ref_id
      INTO v_status_id
      FROM ven_doc_status_ref t
     WHERE t.brief = p_status_brief;
  
    set_version_status(p_doc_id, v_status_id);
  END;

  FUNCTION can_be_current(p_version_id IN NUMBER) RETURN NUMBER IS
    v_ret NUMBER := 0;
  BEGIN
    -- да - если текущий статус новый
    IF doc.get_doc_status_brief(p_version_id) = 'NEW'
    THEN
      v_ret := 1;
    END IF;
    RETURN v_ret;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
  END;

  --
  FUNCTION can_be_copied(p_version_id IN NUMBER) RETURN NUMBER IS
    v_ret     NUMBER := 0;
    v_num     NUMBER;
    v_num_ver VARCHAR2(50);
    v_st      VARCHAR2(100);
    v_ver_id  NUMBER;
    v_ch_id   NUMBER;
  BEGIN
    -- да - если это последняя актуальная версия
    SELECT c.contract_id
          ,c.num
          ,doc.get_doc_status_brief(c.ag_contract_id)
      INTO v_ch_id
          ,v_num_ver
          ,v_st
      FROM ven_ag_contract c
     WHERE c.ag_contract_id = p_version_id;
  
    SELECT ch.last_ver_id
      INTO v_ver_id
      FROM ven_ag_contract_header ch
     WHERE ch.ag_contract_header_id = v_ch_id;
  
    --v_ver_id:=get_status_contr_activ_id(v_ch_id);
    IF v_ver_id = p_version_id
    THEN
      --и если нет других новых
      SELECT COUNT(*)
        INTO v_num
        FROM ven_ag_contract c2
       WHERE c2.contract_id = v_ch_id
         AND doc.get_doc_status_brief(c2.ag_contract_id) = 'NEW';
    
      IF v_num = 0
      THEN
        v_ret := 1;
      ELSE
        v_ret := 0;
      END IF;
    
    ELSE
      v_ret := 0;
    END IF;
    --если это не самая первая версия в статусе новый
    IF v_st = 'NEW'
       AND v_num_ver = 0
    THEN
      v_ret := 0;
    END IF;
  
    RETURN v_ret;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
  END;

  FUNCTION can_be_del(p_version_id IN NUMBER) RETURN NUMBER IS
    v_r     NUMBER := 0;
    v_ver   NUMBER;
    v_ch_id NUMBER;
  BEGIN
    -- Если статус версии - Новый
    IF doc.get_doc_status_brief(p_version_id) = 'NEW'
    THEN
      v_r := 1;
    END IF;
    -- и если это не самая первая версия в статусе новый (или статус договора не Новый)
    IF v_r = 1
    THEN
      SELECT c.contract_id INTO v_ch_id FROM ven_ag_contract c WHERE c.ag_contract_id = p_version_id;
    
      IF doc.get_doc_status_brief(v_ch_id) = 'NEW'
      THEN
        v_r := 0;
        /*select count(*)
          into v_ver
          from ven_ag_contract v
         where v.contract_id =
               (select c.contract_id
                  from ven_ag_contract c
                 where c.ag_contract_id = p_version_id);
        
        if v_ver = 1 then
          v_r := 0; */
      END IF;
    END IF;
    RETURN v_r;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
  END;

  FUNCTION get_ver_num(p_contract_id IN NUMBER) --ИД контракта
   RETURN VARCHAR2 IS
    p_num          VARCHAR2(50);
    v_num          NUMBER;
    v_contract_num VARCHAR(10);
  BEGIN
    --находим последнюю версию по данному договору
    SELECT MAX(to_number(substr(ltrim(c.num, ch.num), 2))) -- max(to_number(ltrim(c.num,ch.num||'/')))
      INTO v_num
      FROM ven_ag_contract_header ch
          ,ven_ag_contract        c
     WHERE ch.ag_contract_header_id = c.contract_id
       AND ch.ag_contract_header_id = p_contract_id;
  
    SELECT t.num
      INTO v_contract_num
      FROM ven_ag_contract_header t
     WHERE t.ag_contract_header_id = p_contract_id; --(select c.contract_id from ven_ag_contract c where c.ag_contract_id=p_contract_id);
    --меняем номер
    IF v_num IS NULL
    THEN
      p_num := v_contract_num || '/0';
    ELSE
      p_num := v_contract_num || '/' || (v_num + 1);
    END IF;
    RETURN p_num;
  END;

  --Добавление версии договора
  PROCEDURE version_insert
  (
    p_contract_id        NUMBER
   , --ИД контракта
    p_date_begin         DATE
   ,p_date_end           DATE
   ,p_class_agent_id     NUMBER DEFAULT NULL
   ,p_category_id        NUMBER DEFAULT NULL
   ,p_note               VARCHAR2 DEFAULT NULL
   ,p_obj_id             IN OUT NUMBER
   , --ИД доп соглашения
    p_CONTRACT_LEADER_ID NUMBER DEFAULT NULL
   ,p_RATE_AGENT         NUMBER DEFAULT NULL
   ,p_RATE_MAIN_AGENT    NUMBER DEFAULT NULL
   ,p_RATE_TYPE_ID       NUMBER DEFAULT NULL
   ,p_RATE_TYPE_MAIN_ID  NUMBER DEFAULT NULL
   ,p_fact_dop_rate      NUMBER DEFAULT 0
   ,p_date_break         DATE DEFAULT SYSDATE
   ,p_signer_id          NUMBER DEFAULT NULL
   ,p_delegate_id        NUMBER DEFAULT NULL
  ) IS
  
    v_status_brief VARCHAR2(10) := 'NEW';
    db             DATE;
    de             DATE;
    v_num          VARCHAR2(10);
    v_Doc_Templ_ID NUMBER;
  BEGIN
  
    SELECT date_begin
          ,get_end_contr(p_contract_id)
      INTO db
          ,de
      FROM ven_ag_contract_header h
     WHERE h.ag_contract_header_id = p_contract_id;
  
    SELECT COUNT(*) INTO v_num FROM ven_ag_contract ac WHERE ac.contract_id = p_contract_id;
    --    v_num := get_ver_num(p_contract_id);
  
    SELECT dt.doc_templ_id INTO v_Doc_Templ_ID FROM Doc_Templ dt WHERE dt.brief = 'AG_CONTRACT';
  
    IF ((db <= p_date_begin OR de >= p_date_end) AND
       (p_class_agent_id IS NOT NULL OR p_category_id IS NOT NULL))
    THEN
    
      BEGIN
        IF p_obj_id IS NULL
        THEN
          SELECT sq_ag_contract.nextval INTO p_obj_id FROM dual;
        END IF;
      
        INSERT INTO ven_ag_contract
          (doc_templ_id
          ,note
          ,num
          ,reg_date
          ,ag_contract_id
          ,class_agent_id
          ,category_id
          ,date_begin
          ,date_end
          ,contract_id
          ,CONTRACT_LEADER_ID
          ,RATE_AGENT
          ,RATE_MAIN_AGENT
          ,RATE_TYPE_ID
          ,RATE_TYPE_MAIN_ID
          ,fact_dop_rate
          ,signer_id
          ,delegate_id)
        VALUES
          (v_Doc_Templ_ID
          ,p_note
          ,v_num
          ,SYSDATE
          ,p_obj_id
          ,p_class_agent_id
          ,p_category_id
          ,p_date_begin
          ,p_date_end
          ,p_contract_id
          ,p_CONTRACT_LEADER_ID
          ,p_RATE_AGENT
          ,p_RATE_MAIN_AGENT
          ,p_RATE_TYPE_ID
          ,p_RATE_TYPE_MAIN_ID
          ,p_fact_dop_rate
          ,p_signer_id
          ,p_delegate_id);
      
        doc.set_doc_status(p_obj_id, v_status_brief, nvl(p_date_break, SYSDATE));
      
        --commit;
      
      END;
    END IF;
  END;

  PROCEDURE version_update
  (
    p_contract_id        NUMBER
   , --ИД контракта
    p_date_begin         DATE
   ,p_date_end           DATE
   ,p_class_agent_id     NUMBER
   ,p_category_id        NUMBER
   ,p_note               VARCHAR2
   ,p_ver_id             NUMBER
   , --ИД доп соглашения
    p_CONTRACT_LEADER_ID NUMBER DEFAULT NULL
   ,p_RATE_AGENT         NUMBER DEFAULT NULL
   ,p_RATE_MAIN_AGENT    NUMBER DEFAULT NULL
   ,p_RATE_TYPE_ID       NUMBER DEFAULT NULL
   ,p_RATE_TYPE_MAIN_ID  NUMBER DEFAULT NULL
   ,p_fact_dop_rate      NUMBER DEFAULT 0
   ,p_signer_id          NUMBER DEFAULT NULL
   ,p_delegate_id        NUMBER DEFAULT NULL
    -- p_num varchar2 default null,
    --  p_num_old varchar2 default null
  ) IS
    db            DATE;
    db_old        DATE;
    de_old        DATE;
    v_class_agent NUMBER;
    v_category_id NUMBER;
    v_note        VARCHAR2(1000);
    v_db          DATE;
    v_de          DATE;
    --v_num         varchar2(50);
  BEGIN
    --Если статус доп.соглашения Новый, тогда возможно редактирование
    --   if (doc.get_doc_status_brief(p_ver_id) = 'NEW') then
  
    SELECT c.class_agent_id
          ,c.category_id
          ,c.note
          ,c.date_begin
          ,c.date_end --,
    -- c.num
      INTO v_class_agent
          ,v_category_id
          ,v_note
          ,v_db
          ,v_de --, v_num
      FROM ven_ag_contract c
     WHERE c.ag_contract_id = p_ver_id;
  
    de_old        := v_de;
    db_old        := v_db;
    v_class_agent := nvl(p_class_agent_id, v_class_agent);
    v_category_id := nvl(p_category_id, v_category_id);
    v_note        := nvl(p_note, v_note);
    v_db          := nvl(p_date_begin, v_db);
    v_de          := nvl(p_date_end, v_de);
  
    /*  if p_num=p_num_old
     then
       v_num := v_num;
     else
       v_num := p_num||'/'||to_number(substr(ltrim(v_num, p_num_old), 2));
     end if;
    */
    --Проверка: дата начала договора<=дате начала версии
    SELECT date_begin
      INTO db
      FROM ven_ag_contract_header h
     WHERE h.ag_contract_header_id = p_contract_id;
  
    IF v_db < db
    THEN
      v_db := SYSDATE;
    END IF;
  
    UPDATE ven_ag_contract t
       SET t.note               = v_note
          ,t.class_agent_id     = v_class_agent
          ,t.category_id        = v_category_id
          ,t.date_begin         = v_db
          ,t.date_end           = v_de
          ,t.contract_leader_id = p_CONTRACT_LEADER_ID
          ,t.rate_agent         = p_RATE_AGENT
          ,t.rate_main_agent    = p_RATE_MAIN_AGENT
          ,t.rate_type_id       = p_RATE_TYPE_ID
          ,t.rate_type_main_id  = p_RATE_TYPE_MAIN_ID
          ,t.fact_dop_rate      = p_fact_dop_rate
          ,t.signer_id          = p_signer_id
          ,t.delegate_id        = p_delegate_id --,
    --  t.num = v_num
     WHERE t.ag_contract_id = p_ver_id;
  
    IF de_old <> v_de
    THEN
      UPDATE ven_ag_prod_line_contr t SET t.date_end = v_de WHERE t.ag_contract_id = p_ver_id;
    END IF;
    IF db_old <> v_db
    THEN
      UPDATE ven_ag_prod_line_contr t
         SET t.date_begin = v_db
       WHERE t.ag_contract_id = p_ver_id
         AND t.date_begin < v_db;
    END IF;
    -- commit;
    -- else
    -- raise_application_error(-20005,
    --                        'Интервал действия версии выбран не правильно');
    -- end if;
    --  else raise_application_error(-20006,
    --                             'Не обновилась версия');
    --  end if;
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20007
                             ,'Не обновляется версия. ' || SQLERRM(SQLCODE));
    
  END;

  PROCEDURE version_del(p_ver_id NUMBER) IS
  
    v_ch_id NUMBER;
    v_c_id  NUMBER;
  BEGIN
    --   if can_be_del(p_ver_id) = 1 then
    SELECT ac.contract_id INTO v_ch_id FROM ven_ag_contract ac WHERE ac.ag_contract_id = p_ver_id;
    --Удаляем виды риска
    prod_line_contr_del(p_ver_id, NULL);
    --Удаляем Версию
    DELETE FROM ven_ag_contract WHERE ag_contract_id = p_ver_id;
    --Удаляем Статус
    DELETE FROM ven_doc_status WHERE document_id = p_ver_id;
    --Удаляем План
    DELETE FROM ven_ag_plan_dop_rate r WHERE r.ag_contract_id = p_ver_id;
    --Удаляем комиссии
    DELETE FROM ven_ag_commiss com WHERE com.parent_id = p_ver_id;
    DELETE FROM ven_ag_commiss com WHERE com.child_id = p_ver_id;
    /* Удалять можно только версию в статусе новый
          а на договоре ссылка на последнюю актуальныю версию,
          следовательно менять ссылку не надо
    */
    --обновляем ссылку на последнюю версию на договоре
    SELECT ac.ag_contract_id
      INTO v_c_id
      FROM ven_ag_contract        ac
          ,ven_ag_contract_header ach
     WHERE ach.ag_contract_header_id = ac.contract_id
       AND ac.num = (SELECT MAX(to_number(c.num)) m
                       FROM ven_ag_contract_header ch
                           ,ven_ag_contract        c
                      WHERE ch.ag_contract_header_id = c.contract_id
                        AND ch.ag_contract_header_id = v_ch_id)
       AND ach.ag_contract_header_id = v_ch_id;
  
    UPDATE ven_ag_contract_header h
       SET h.last_ver_id = v_c_id
     WHERE h.ag_contract_header_id = v_ch_id;
    --   else
    --     null;
    --   end if;
    -- commit;
  END;

  PROCEDURE contract_header_insert
  (
    p_contr_id            OUT NUMBER
   ,p_num                 VARCHAR2
   ,p_date_begin          DATE DEFAULT SYSDATE
   ,p_date_end            DATE
   ,p_agent_id            NUMBER
   ,p_date_break          DATE DEFAULT NULL
   ,p_note                VARCHAR2 DEFAULT NULL
   ,p_agency_id           NUMBER DEFAULT NULL
   ,p_sales_channel_id    NUMBER
   ,p_AG_CONTRACT_TEMP_ID NUMBER DEFAULT NULL
  ) IS
    v_obj_id_contr NUMBER;
    v_obj_id_vers  NUMBER;
    v_status_id    NUMBER;
    v_Doc_Templ_ID NUMBER;
  
  BEGIN
  
    v_obj_id_contr := PKG_AGENT_UTILS.GetNewSqAgContractHeader;
    v_status_id    := DOC.GET_FIRST_DOC_STATUS(v_obj_id_contr);
    v_Doc_Templ_ID := DOC.TEMPL_ID_BY_BRIEF('AG_CONTRACT_HEADER');
    p_contr_id     := v_obj_id_contr;
  
    INSERT INTO ven_ag_contract_header
      (doc_templ_id
      ,ag_contract_header_id
      ,note
      ,num
      ,reg_date
      ,date_begin
      ,agent_id
      ,date_break
      ,last_ver_id
      ,agency_id
      ,t_sales_channel_id
      ,ag_contract_templ_k
      ,AG_CONTRACT_TEMPL_ID)
    VALUES
      (v_Doc_Templ_ID
      ,v_obj_id_contr
      ,p_note
      ,p_num
      ,SYSDATE
      ,p_date_begin
      ,p_agent_id
      ,p_date_break
      ,NULL
      ,p_agency_id
      ,p_sales_channel_id
      ,0
      , -- для документов всегда 0
       p_AG_CONTRACT_TEMP_ID);
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20008, 'Ошибка: pkg_agent.contract_header_insert');
  END contract_header_insert;

  PROCEDURE contract_insert
  (
    p_contr_id            OUT NUMBER
   ,p_vers_id             OUT NUMBER
   ,p_num                 VARCHAR2
   ,p_date_begin          DATE DEFAULT SYSDATE
   ,p_date_end            DATE
   ,p_agent_id            NUMBER
   ,p_date_break          DATE DEFAULT NULL
   ,p_agency_id           NUMBER DEFAULT NULL
   ,p_note                VARCHAR2 DEFAULT NULL
   ,p_class_agent_id      NUMBER DEFAULT NULL
   ,p_category_id         NUMBER DEFAULT NULL
   ,p_CONTRACT_LEADER_ID  NUMBER DEFAULT NULL
   ,p_RATE_AGENT          NUMBER DEFAULT NULL
   ,p_RATE_MAIN_AGENT     NUMBER DEFAULT NULL
   ,p_RATE_TYPE_ID        NUMBER DEFAULT NULL
   ,p_RATE_TYPE_MAIN_ID   NUMBER DEFAULT NULL
   ,p_fact_dop_rate       NUMBER DEFAULT 0
   ,p_note_ver            VARCHAR2 DEFAULT NULL
   ,p_sales_channel_id    NUMBER
   ,p_AG_CONTRACT_TEMP_ID NUMBER DEFAULT NULL
   ,p_signer_id           NUMBER DEFAULT NULL
   ,p_delegate_id         NUMBER DEFAULT NULL
  ) IS
    v_obj_id_contr NUMBER;
    v_obj_id_vers  NUMBER;
    v_status_id    NUMBER;
    v_Doc_Templ_ID NUMBER;
  BEGIN
    IF (p_date_begin < p_date_end /*and p_agent_id is not null*/
       AND p_date_begin IS NOT NULL AND p_date_end IS NOT NULL)
    THEN
    
      contract_header_insert(p_contr_id
                            ,p_num
                            ,p_date_begin
                            ,p_date_end
                            ,p_agent_id
                            ,p_date_break
                            ,p_note
                            ,p_agency_id
                            ,p_sales_channel_id
                            ,p_AG_CONTRACT_TEMP_ID);
    
      --Добавляется Первая версия
      version_insert(v_obj_id_contr
                    ,p_date_begin
                    ,p_date_end
                    ,p_class_agent_id
                    ,p_category_id
                    ,p_note_ver
                    ,v_obj_id_vers
                    ,p_CONTRACT_LEADER_ID
                    ,p_RATE_AGENT
                    ,p_RATE_MAIN_AGENT
                    ,p_RATE_TYPE_ID
                    ,p_RATE_TYPE_MAIN_ID
                    ,p_fact_dop_rate
                    ,p_date_break
                    ,p_signer_id
                    ,p_delegate_id);
    
      --Обновляется актуальная версия
      set_last_ver(v_obj_id_contr, v_obj_id_vers);
    
      -- commit;
    
      p_contr_id := v_obj_id_contr;
      p_vers_id  := v_obj_id_vers;
    
    ELSE
      raise_application_error(-20008, 'Не корректно заданны параметры');
    END IF;
  END;

  PROCEDURE contract_update
  (
    p_ag_ch_id           NUMBER
   ,p_vers_id            NUMBER
   ,p_num                VARCHAR2
   ,p_date_begin         DATE
   ,p_date_end           DATE
   ,p_agent_id           NUMBER
   ,p_date_break         DATE DEFAULT NULL
   ,p_agency_id          NUMBER DEFAULT NULL
   ,p_note               VARCHAR2
   ,p_CONTRACT_LEADER_ID NUMBER DEFAULT NULL
   ,p_RATE_AGENT         NUMBER DEFAULT NULL
   ,p_RATE_MAIN_AGENT    NUMBER DEFAULT NULL
   ,p_RATE_TYPE_ID       NUMBER DEFAULT NULL
   ,p_RATE_TYPE_MAIN_ID  NUMBER DEFAULT NULL
   ,p_fact_dop_rate      NUMBER DEFAULT 0
   ,p_sales_channel_id   NUMBER
   ,p_signer_id          NUMBER DEFAULT NULL
   ,p_delegate_id        NUMBER DEFAULT NULL
  ) IS
    --v_num_old varchar2(50);
    v_contract     ven_ag_contract_header%ROWTYPE;
    v_version      ven_ag_contract%ROWTYPE;
    v_date_con     DATE;
    v_date_ver     DATE;
    v_date_ver_end DATE;
  BEGIN
    --Если статус договора Новый, тогда возможно изменение
    --   if (get_status_contr(p_contr_id) = 'NEW') then
  
    BEGIN
      -- значения по контракту до изменений
      SELECT * INTO v_contract FROM ven_ag_contract_header WHERE ag_contract_header_id = p_ag_ch_id;
      -- значения по версии до изменений
      SELECT * INTO v_version FROM ven_ag_contract WHERE ag_contract_id = p_vers_id;
      -- начальные значения дат по договору и версии
      v_date_con     := v_contract.date_begin;
      v_date_ver     := v_version.date_begin;
      v_date_ver_end := v_version.date_end;
    EXCEPTION
      WHEN no_data_found THEN
        v_date_con     := p_date_begin;
        v_date_ver     := p_date_begin;
        v_date_ver_end := p_date_end;
    END;
    -- проверка возможности изменений дат по контракту и версии
    IF p_date_begin < v_contract.date_begin
       AND v_contract.date_begin < SYSDATE
    THEN
      -- уменьшение дат (относительно текущей) невозможно
      NULL;
    ELSIF p_date_begin <> v_contract.date_begin
    THEN
      v_date_con := p_date_begin;
      v_date_ver := p_date_begin;
    END IF;
    BEGIN
    
      UPDATE ven_ag_contract_header ch
         SET ch.num                = p_num
            ,ch.note               = p_note
            ,ch.agent_id           = p_agent_id
            ,ch.date_begin         = v_date_con
            ,ch.last_ver_id        = p_vers_id
            ,ch.date_break         = p_date_break
            ,ch.t_sales_channel_id = p_sales_channel_id
       WHERE ch.ag_contract_header_id = p_ag_ch_id;
    
      IF get_status_contr_activ_brief(p_ag_ch_id) = 'NEW'
      THEN
        UPDATE ven_ag_contract_header
           SET agency_id = p_agency_id
         WHERE ag_contract_header_id = p_ag_ch_id;
      END IF;
    
      version_update(p_ag_ch_id
                    ,v_date_ver
                    ,v_date_ver_end
                    ,NULL
                    ,NULL
                    ,NULL
                    ,p_vers_id
                    ,p_CONTRACT_LEADER_ID
                    ,p_RATE_AGENT
                    ,p_RATE_MAIN_AGENT
                    ,p_RATE_TYPE_ID
                    ,p_RATE_TYPE_MAIN_ID
                    ,p_fact_dop_rate
                    ,p_signer_id
                    ,p_delegate_id);
    
    END;
    --  else raise_application_error(-20009,
    --                              'Договор невозможно редактировать');
    --   end if;
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20010
                             ,'Не обновляется договор. ' || SQLERRM(SQLCODE));
  END; --proc

  --Расторжение договора
  PROCEDURE contract_break(v_ch_id IN NUMBER) IS
    ver_id  NUMBER;
    v_st_id NUMBER;
    v_id    NUMBER;
  BEGIN
    SELECT h.last_ver_id
      INTO ver_id
      FROM ven_ag_contract_header h
     WHERE h.ag_contract_header_id = v_ch_id;
  
    v_st_id := ent.get_obj_id('DOC_STATUS_REF', 'BREAK');
    /*    SELECT R.doc_status_ref_id
        INTO V_ST_ID
        FROM VEN_DOC_STATUS_REF R WHERE R.brief=('BREAK');
    */
    -- проверка на БСО и передача пакета
  
    pkg_agent.contract_copy(ver_id, v_id, TRUE);
    pkg_agent.set_version_status(v_id, v_st_id);
  
  END;

  PROCEDURE template_insert
  (
    p_contr_id         OUT NUMBER
   ,p_vers_id          OUT NUMBER
   ,p_date_begin       DATE DEFAULT SYSDATE
   ,p_agency_id        NUMBER DEFAULT NULL
   ,p_note             VARCHAR2 DEFAULT NULL
   ,p_class_agent_id   NUMBER DEFAULT NULL
   ,p_category_id      NUMBER DEFAULT NULL
   ,p_sales_channel_id NUMBER
   ,p_TEMPL_NAME       VARCHAR2 DEFAULT NULL
   ,p_TEMPL_BRIEF      VARCHAR2 DEFAULT NULL
  ) IS
    v_ag_contract_header_id NUMBER;
    v_obj_id_vers           NUMBER;
    v_status_id             NUMBER;
    v_Doc_Templ_ID          NUMBER;
  BEGIN
  
    SELECT sq_ag_contract_header.nextval INTO v_ag_contract_header_id FROM dual;
  
    SELECT sq_ag_contract.nextval INTO v_obj_id_vers FROM dual;
  
    SELECT v.doc_status_ref_id INTO v_status_id FROM ven_doc_status_ref v WHERE v.brief = 'CURRENT';
  
    SELECT dt.doc_templ_id
      INTO v_Doc_Templ_ID
      FROM Doc_Templ dt
     WHERE dt.brief = 'AG_CONTRACT_HEADER_TEMP';
  
    INSERT INTO ven_ag_contract_header
      (doc_templ_id
      ,ag_contract_header_id
      ,note
      ,num
      ,reg_date
      ,date_begin
      ,last_ver_id
      ,agency_id
      ,t_sales_channel_id
      ,ag_contract_templ_k
      ,TEMPL_NAME
      ,TEMPL_BRIEF)
    VALUES
      (v_Doc_Templ_ID
      ,v_ag_contract_header_id
      ,p_note
      ,'0'
      ,SYSDATE
      ,p_date_begin
      ,NULL
      , --v_obj_id_vers,
       p_agency_id
      ,p_sales_channel_id
      ,1
      , -- для шаблонов всегда = 1
       p_TEMPL_NAME
      ,p_TEMPL_BRIEF);
  
    --Добавляется Первая версия
    version_insert(v_ag_contract_header_id
                  ,p_date_begin
                  ,to_date('01.01.9999')
                  ,p_class_agent_id
                  ,p_category_id
                  ,NULL
                  , --p_note_ver,
                   v_obj_id_vers
                  ,NULL
                  , --p_CONTRACT_LEADER_ID,
                   NULL
                  , --p_RATE_AGENT,
                   NULL
                  , --p_RATE_MAIN_AGENT,
                   NULL
                  , --p_RATE_TYPE_ID,
                   NULL
                  , --p_RATE_TYPE_MAIN_ID,
                   NULL --p_fact_dop_rate
                   );
  
    --Обновляется актуальная версия
    set_last_ver(v_ag_contract_header_id, v_obj_id_vers);
  
    -- commit;
  
    p_contr_id := v_ag_contract_header_id;
    p_vers_id  := v_obj_id_vers;
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20000 + SQLCODE, SQLERRM(SQLCODE));
  END; --proc template_insert

  PROCEDURE template_update
  (
    p_ag_ch_id         NUMBER
   ,p_vers_id          NUMBER
   ,p_date_begin       DATE
   ,p_agency_id        NUMBER DEFAULT NULL
   ,p_note             VARCHAR2
   ,p_class_agent_id   NUMBER DEFAULT NULL
   ,p_category_id      NUMBER DEFAULT NULL
   ,p_sales_channel_id NUMBER
   ,p_templ_name       VARCHAR2 DEFAULT NULL
   ,p_templ_brief      VARCHAR2 DEFAULT NULL
  ) IS
    --v_num_old varchar2(50);
  
  BEGIN
    --Если статус договора Новый, тогда возможно изменение
    --   if (get_status_contr(p_contr_id) = 'NEW') then
    BEGIN
    
      UPDATE ven_ag_contract_header ch
         SET ch.note               = p_note
            ,ch.date_begin         = p_date_begin
            ,ch.last_ver_id        = p_vers_id
            ,ch.t_sales_channel_id = p_sales_channel_id
            ,ch.agency_id          = p_agency_id
            ,ch.templ_name         = p_templ_name
            ,ch.templ_brief        = p_templ_brief
       WHERE ch.ag_contract_header_id = p_ag_ch_id;
    
      version_update(p_ag_ch_id
                    ,p_date_begin
                    ,NULL
                    , --p_date_end,
                     p_class_agent_id
                    ,p_category_id
                    ,NULL
                    , --note
                     p_vers_id
                    ,NULL
                    , --p_CONTRACT_LEADER_ID,
                     NULL
                    , --p_RATE_AGENT,
                     NULL
                    , --p_RATE_MAIN_AGENT,
                     NULL
                    , --p_RATE_TYPE_ID,
                     NULL
                    , --p_RATE_TYPE_MAIN_ID,
                     NULL
                    , --p_fact_dop_rate
                     NULL --p_signer_id
                     );
    
    END;
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20000 + SQLCODE, SQLERRM(SQLCODE));
  END; -- proc template_update

  FUNCTION GetTemplateContractById(p_id IN NUMBER) RETURN VEN_AG_CONTRACT%ROWTYPE IS
    CURSOR cur(cv_id NUMBER) IS
      SELECT * FROM VEN_AG_CONTRACT VAC WHERE VAC.AG_CONTRACT_ID = cv_id;
  
    rec cur%ROWTYPE;
  BEGIN
  
    OPEN cur(p_id);
    FETCH cur
      INTO rec;
  
    IF (cur%NOTFOUND)
    THEN
      CLOSE cur;
      RETURN NULL;
    END IF;
  
    CLOSE cur;
    RETURN rec;
  
  END GetTemplateContractById;

  FUNCTION GetTemplateContractByBrief(p_brief IN VARCHAR2) RETURN VEN_AG_CONTRACT%ROWTYPE IS
    v_id NUMBER;
  BEGIN
  
    SELECT VAC.AG_CONTRACT_ID
      INTO v_id
      FROM VEN_AG_CONTRACT        VAC
          ,VEN_AG_CONTRACT_HEADER VACH
     WHERE VACH.TEMPL_BRIEF = p_brief
       AND VACH.LAST_VER_ID = vac.AG_CONTRACT_ID;
  
    RETURN GetTemplateContractById(v_id);
  
  END GetTemplateContractByBrief;

  FUNCTION GetAgContractHeader(p_id NUMBER) RETURN VEN_AG_CONTRACT_HEADER%ROWTYPE IS
    CURSOR cur(cv_id NUMBER) IS
      SELECT * FROM VEN_AG_CONTRACT_HEADER v WHERE v.AG_CONTRACT_HEADER_ID = cv_id;
  
    rec cur%ROWTYPE;
  BEGIN
    OPEN cur(p_id);
    FETCH cur
      INTO rec;
  
    IF (cur%NOTFOUND)
    THEN
      CLOSE cur;
      RETURN NULL;
    END IF;
  
    CLOSE cur;
    RETURN rec;
  
  END GetAgContractHeader;

  FUNCTION GetLastAgContractByHeader(p_header_id NUMBER) RETURN VEN_AG_CONTRACT%ROWTYPE IS
    CURSOR cur(cv_id NUMBER) IS
      SELECT * FROM VEN_AG_CONTRACT_HEADER v WHERE v.AG_CONTRACT_HEADER_ID = cv_id;
  
    rec cur%ROWTYPE;
  BEGIN
    OPEN cur(p_header_id);
    FETCH cur
      INTO rec;
  
    IF (cur%NOTFOUND)
    THEN
      CLOSE cur;
      RETURN NULL;
    END IF;
  
    CLOSE cur;
    RETURN GetAgContract(rec.LAST_VER_ID);
  
  END GetLastAgContractByHeader;

  FUNCTION GetAgContract(p_id NUMBER) RETURN VEN_AG_CONTRACT%ROWTYPE IS
    CURSOR cur(cv_id NUMBER) IS
      SELECT * FROM VEN_AG_CONTRACT v WHERE v.AG_CONTRACT_ID = cv_id;
  
    rec cur%ROWTYPE;
  BEGIN
    OPEN cur(p_id);
    FETCH cur
      INTO rec;
  
    IF (cur%NOTFOUND)
    THEN
      CLOSE cur;
      RETURN NULL;
    END IF;
  
    CLOSE cur;
    RETURN rec;
  END GetAgContract;

  FUNCTION CopyTemplateToContractByBrief
  (
    p_brief      IN VARCHAR2
   ,p_ver_id_new OUT NUMBER
  ) RETURN NUMBER IS
  BEGIN
    RETURN CopyTemplateToContractById(GetTemplateContractByBrief(p_brief).AG_CONTRACT_ID
                                     ,p_ver_id_new);
  END CopyTemplateToContractByBrief;

  FUNCTION CopyTemplateToContractById
  (
    p_id         IN NUMBER
   ,p_ver_id_new OUT NUMBER
  ) RETURN NUMBER IS
    p_ret NUMBER;
  BEGIN
  
    p_ret := template_to_contract_copy(p_id, p_ver_id_new);
  
    /*инверция*/
    IF (p_ret = 0)
    THEN
      p_ret := 1;
    ELSE
      IF (p_ret = 1)
      THEN
        p_ret := 0;
      END IF;
    END IF;
  
    RETURN p_ret;
  
  END CopyTemplateToContractById;

  FUNCTION CreateContractByTemplateBrief
  (
    p_ag_header_id IN NUMBER
   ,p_brief        IN VARCHAR2
  ) RETURN NUMBER IS
    p_id           NUMBER;
    p_new_contract NUMBER;
  BEGIN
    SELECT a.AG_CONTRACT_HEADER_ID INTO p_id FROM AG_CONTRACT_HEADER a WHERE a.templ_brief = p_brief;
  
    RETURN CreateContractByTemplateId(p_ag_header_id, p_id, p_new_contract);
  
  END CreateContractByTemplateBrief;

  FUNCTION CreateContractByTemplateId
  (
    p_ag_header_id    IN NUMBER
   ,p_tempalte_id     IN NUMBER
   ,p_contract_new_id OUT NUMBER
  ) RETURN NUMBER IS
    p NUMBER;
  BEGIN
  
    p := CopyTemplateToContractById(p_tempalte_id, p_contract_new_id);
  
    IF (p != Utils.c_true)
    THEN
      RETURN Utils.c_false;
    END IF;
  
    /*    doc.set_doc_status(p_contract_new_id,
                          'NULL',
                          SYSDATE,
                          'AUTO',
                          'Автоматическое');
    
    dbms_output.put_line(p_contract_new_id);
    
    doc.set_doc_status(p_contract_new_id,
                          'NEW',
                          SYSDATE,
                          'AUTO',
                          'Автоматическое');
    
                            dbms_output.put_line(p_contract_new_id);
    
      doc.set_doc_status(p_contract_new_id,
                          'CURRENT',
                          SYSDATE,
                          'AUTO',
                          'Автоматическое');*/
  
    p := UpdateVersionContractHeader(p_ag_header_id, p_contract_new_id);
  
    IF (p != Utils.c_true)
    THEN
      RETURN Utils.c_false;
    END IF;
  
    RETURN Utils.c_true;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN Utils.c_false;
  END CreateContractByTemplateId;

  FUNCTION UpdateVersionContractHeader
  (
    p_ag_header_id    NUMBER
   ,p_contract_new_id NUMBER
  ) RETURN NUMBER IS
  BEGIN
  
    UPDATE VEN_AG_CONTRACT v
       SET v.CONTRACT_ID = p_ag_header_id
     WHERE v.AG_CONTRACT_ID = p_contract_new_id;
  
    set_last_ver(p_ag_header_id, p_contract_new_id);
  
    RETURN Utils.c_true;
  
  EXCEPTION
    WHEN OTHERS THEN
      RETURN Utils.c_false;
  END UpdateVersionContractHeader;

  FUNCTION template_to_contract_copy
  (
    p_header_id_old IN NUMBER
   ,p_ver_id_new    OUT NUMBER
  ) RETURN NUMBER IS
    db                          DATE;
    de                          DATE;
    v_e                         NUMBER;
    v_new_AG_PROD_LINE_CONTR_ID NUMBER;
    p_ver_id_old                NUMBER;
  BEGIN
  
    --    if can_be_copied(p_ver_id_old) = 1 then
    --копирование версии
  
    p_ver_id_old := GetAgContractHeader(p_header_id_old).LAST_VER_ID;
  
    IF (p_ver_id_new IS NULL)
    THEN
      p_ver_id_new := pkg_agent_utils.GetNewSqAgContract();
    END IF;
  
    IF (p_ver_id_old IS NULL)
    THEN
      RETURN 1;
    END IF;
  
    FOR v_r IN (SELECT * FROM ven_ag_contract t WHERE t.ag_contract_id = p_ver_id_old)
    LOOP
    
      v_r.ag_contract_id := p_ver_id_new;
      v_r.note           := '';
      IF v_r.date_begin < SYSDATE
      THEN
        v_r.date_begin := SYSDATE;
      END IF;
    
      v_r.reg_date := SYSDATE;
      --  v_r.num      := get_ver_num(v_r.contract_id);
      db := v_r.date_begin;
      de := v_r.date_end;
    
      version_insert(v_r.contract_id
                    , --ИД контракта
                     v_r.date_begin
                    ,v_r.date_end
                    ,v_r.class_agent_id
                    ,v_r.category_id
                    ,v_r.note
                    ,p_ver_id_new
                    , --ИД доп соглашения
                     v_r.contract_leader_id
                    ,v_r.rate_agent
                    ,v_r.rate_main_agent
                    ,v_r.rate_type_id
                    ,v_r.rate_type_main_id
                    ,0
                    ,SYSDATE
                    ,v_r.signer_id
                    ,v_r.delegate_id);
    
    END LOOP;
  
    --Копирование рисков для версии
    FOR v_id IN (SELECT pl.ag_prod_line_contr_id
                   FROM ven_ag_prod_line_contr pl
                  WHERE pl.ag_contract_id = p_ver_id_old)
    LOOP
    
      FOR v_plc IN (SELECT p.insurance_group_id
                          ,p.product_id
                          ,p.product_line_id
                          ,r.type_defin_rate_id
                          ,r.type_rate_value_id
                          ,
                           --  r.t_rule_id,
                           r.value
                          ,p.date_begin
                          ,p.date_end
                          ,r.t_prod_coef_type_id
                          ,p.notes
                      FROM ven_ag_prod_line_contr p
                          ,ven_ag_rate            r
                     WHERE p.ag_rate_id = r.ag_rate_id
                       AND p.ag_prod_line_contr_id = v_id.ag_prod_line_contr_id)
      LOOP
        prod_line_contr_insert( --v_new_AG_PROD_LINE_CONTR_ID,
                               p_ver_id_new
                              ,v_plc.insurance_group_id
                              ,v_plc.product_id
                              ,v_plc.product_line_id
                              ,v_plc.type_defin_rate_id
                              ,v_plc.type_rate_value_id
                              ,
                               -- v_plc.t_rule_id,
                               v_plc.value
                              ,v_plc.date_begin
                              ,de
                              ,v_plc.t_prod_coef_type_id
                              ,v_plc.notes);
      END LOOP;
    END LOOP;
  
    --копирование плана доп. вознаграждений
    FOR v_plan IN (SELECT r.order_num
                         ,r.prem_b
                         ,r.prem_e
                         ,r.rate
                         ,r.ag_type_rate_value_id
                     FROM ven_ag_plan_dop_rate r
                    WHERE r.ag_contract_id = p_ver_id_old)
    LOOP
      INSERT INTO ven_ag_plan_dop_rate
        (order_num, ag_contract_id, prem_b, prem_e, rate, ag_type_rate_value_id)
      VALUES
        (v_plan.order_num
        ,p_ver_id_new
        ,v_plan.prem_b
        ,v_plan.prem_e
        ,v_plan.rate
        ,v_plan.ag_type_rate_value_id);
    
    END LOOP;
    --копирование комиссий
    FOR v_com_from IN (SELECT com.parent_id
                             ,com.child_id
                             ,com.t_product_id
                         FROM ven_ag_commiss com
                        WHERE com.parent_id = p_ver_id_old)
    LOOP
      INSERT INTO ven_ag_commiss
        (parent_id, child_id, t_product_id)
      VALUES
        (p_ver_id_new, v_com_from.child_id, v_com_from.t_product_id);
    END LOOP;
  
    FOR v_com_to IN (SELECT com.parent_id
                           ,com.child_id
                           ,com.t_product_id
                       FROM ven_ag_commiss com
                      WHERE com.child_id = p_ver_id_old)
    LOOP
      INSERT INTO ven_ag_commiss
        (parent_id, child_id, t_product_id)
      VALUES
        (v_com_to.parent_id, p_ver_id_new, v_com_to.t_product_id);
    END LOOP;
  
    INSERT INTO ven_ag_dav
      (ag_dav_id, contract_id, note, payment_ag_id, payment_terms_id, prod_coef_type_id)
      SELECT sq_ag_dav.nextval
            ,p_ver_id_new
            ,a.note
            ,a.payment_ag_id
            ,a.payment_terms_id
            ,a.prod_coef_type_id
        FROM ven_ag_dav a
       WHERE A.CONTRACT_ID = p_ver_id_old;
  
    RETURN 0;
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20011
                             ,'Невозможно создать новую версию из текущей');
  END;

  PROCEDURE contract_del(v_contract_id NUMBER) IS
  BEGIN
    --удаляем версии
    FOR v_r IN (SELECT c.ag_contract_id FROM ven_ag_contract c WHERE c.contract_id = v_contract_id)
    LOOP
      version_del(v_r.ag_contract_id);
    END LOOP;
    --удаляем договор
    DELETE FROM ven_ag_contract_header WHERE ag_contract_header_id = v_contract_id;
    --удаляем статус
    DELETE FROM ven_doc_status WHERE document_id = v_contract_id;
    --  commit;
  END;

  --Копируется версия с новым ключом
  PROCEDURE contract_copy
  (
    p_ver_id_old  IN NUMBER
   ,p_ver_id_new  OUT NUMBER
   ,p_anyway_copy IN BOOLEAN DEFAULT FALSE
   ,p_date_break  DATE DEFAULT SYSDATE
  ) IS
    db                          DATE;
    de                          DATE;
    v_new_AG_PROD_LINE_CONTR_ID NUMBER;
  BEGIN
    IF p_anyway_copy
       OR can_be_copied(p_ver_id_old) = 1
    THEN
      --копирование версии
      FOR v_r IN (SELECT * FROM ven_ag_contract t WHERE t.ag_contract_id = p_ver_id_old)
      LOOP
        v_r.ag_contract_id := p_ver_id_new;
        v_r.note           := '';
        IF v_r.date_begin < SYSDATE
        THEN
          v_r.date_begin := SYSDATE;
        END IF;
        v_r.reg_date := SYSDATE;
        --  v_r.num      := get_ver_num(v_r.contract_id);
        db := v_r.date_begin;
        de := v_r.date_end;
      
        version_insert(v_r.contract_id
                      , --ИД контракта
                       v_r.date_begin
                      ,v_r.date_end
                      ,v_r.class_agent_id
                      ,v_r.category_id
                      ,v_r.note
                      ,p_ver_id_new
                      , --ИД доп соглашения
                       v_r.contract_leader_id
                      ,v_r.rate_agent
                      ,v_r.rate_main_agent
                      ,v_r.rate_type_id
                      ,v_r.rate_type_main_id
                      ,0
                      ,p_date_break
                      ,v_r.signer_id
                      ,v_r.delegate_id);
      
      END LOOP;
      --  commit;
      --Копирование рисков для версии
      FOR v_id IN (SELECT pl.ag_prod_line_contr_id
                     FROM ven_ag_prod_line_contr pl
                    WHERE pl.ag_contract_id = p_ver_id_old)
      LOOP
      
        FOR v_plc IN (SELECT p.insurance_group_id
                            ,p.product_id
                            ,p.product_line_id
                            ,r.type_defin_rate_id
                            ,r.type_rate_value_id
                            ,
                             --  r.t_rule_id,
                             r.value
                            ,p.date_begin
                            ,p.date_end
                            ,r.t_prod_coef_type_id
                            ,p.notes
                        FROM ven_ag_prod_line_contr p
                            ,ven_ag_rate            r
                       WHERE p.ag_rate_id = r.ag_rate_id
                         AND p.ag_prod_line_contr_id = v_id.ag_prod_line_contr_id)
        LOOP
          prod_line_contr_insert( --v_new_AG_PROD_LINE_CONTR_ID,
                                 p_ver_id_new
                                ,v_plc.insurance_group_id
                                ,v_plc.product_id
                                ,v_plc.product_line_id
                                ,v_plc.type_defin_rate_id
                                ,v_plc.type_rate_value_id
                                ,
                                 --  v_plc.t_rule_id,
                                 v_plc.value
                                ,v_plc.date_begin
                                ,de
                                ,v_plc.t_prod_coef_type_id
                                ,v_plc.notes);
        END LOOP;
      END LOOP;
    
      --копирование плана доп. вознаграждений
      FOR v_plan IN (SELECT r.order_num
                           ,r.prem_b
                           ,r.prem_e
                           ,r.rate
                           ,r.ag_type_rate_value_id
                       FROM ven_ag_plan_dop_rate r
                      WHERE r.ag_contract_id = p_ver_id_old)
      LOOP
        INSERT INTO ven_ag_plan_dop_rate
          (order_num, ag_contract_id, prem_b, prem_e, rate, ag_type_rate_value_id)
        VALUES
          (v_plan.order_num
          ,p_ver_id_new
          ,v_plan.prem_b
          ,v_plan.prem_e
          ,v_plan.rate
          ,v_plan.ag_type_rate_value_id);
      
      END LOOP;
      --копирование комиссий
      FOR v_com_from IN (SELECT com.parent_id
                               ,com.child_id
                               ,com.t_product_id
                           FROM ven_ag_commiss com
                          WHERE com.parent_id = p_ver_id_old)
      LOOP
        INSERT INTO ven_ag_commiss
          (parent_id, child_id, t_product_id)
        VALUES
          (p_ver_id_new, v_com_from.child_id, v_com_from.t_product_id);
      END LOOP;
    
      FOR v_com_to IN (SELECT com.parent_id
                             ,com.child_id
                             ,com.t_product_id
                         FROM ven_ag_commiss com
                        WHERE com.child_id = p_ver_id_old)
      LOOP
        INSERT INTO ven_ag_commiss
          (parent_id, child_id, t_product_id)
        VALUES
          (v_com_to.parent_id, p_ver_id_new, v_com_to.t_product_id);
      END LOOP;
    
      -- commit;
      -- else raise_application_error(-20011,
      --            'Невозможно создать новую версию из текущей');
    END IF;
  
  END;

  PROCEDURE prod_line_contr_insert( --p_AG_PROD_LINE_CONTR_ID out number,
                                   p_ver_cont_id        NUMBER
                                  ,p_insurance_group_id NUMBER
                                  ,p_product_id         NUMBER
                                  ,p_product_line_id    NUMBER
                                  ,p_defin_rate_id      NUMBER
                                  ,p_type_value_rate    NUMBER
                                  ,
                                   --   p_rule_id            number,
                                   p_rate              NUMBER
                                  ,p_db                DATE
                                  ,p_de                DATE
                                  ,p_PROD_COEF_TYPE_ID NUMBER
                                  ,p_notes             VARCHAR2) IS
    v_prod_line_cont_id NUMBER;
    v_rate_id           NUMBER;
    de                  DATE;
  BEGIN
    --if p_db < p_de then
    BEGIN
      SELECT sq_ag_prod_line_contr.nextval INTO v_prod_line_cont_id FROM dual;
      SELECT sq_ag_rate.nextval INTO v_rate_id FROM dual;
      --Добавляем ставку
      INSERT INTO ven_ag_rate
        (ag_rate_id
        ,
         --  t_rule_id,
         type_rate_value_id
        ,VALUE
        ,type_defin_rate_id
        ,T_PROD_COEF_TYPE_ID)
      VALUES
        (v_rate_id
        ,
         --  p_rule_id,
         p_type_value_rate
        ,p_rate
        ,p_defin_rate_id
        ,p_PROD_COEF_TYPE_ID);
    
      --   commit;
    
      SELECT c.date_end INTO de FROM ven_ag_contract c WHERE c.ag_contract_id = p_ver_cont_id;
    
      IF de > p_de
      THEN
        de := p_de;
      END IF;
    
      --вид риск
      INSERT INTO ven_ag_prod_line_contr
        (ag_prod_line_contr_id
        ,ag_contract_id
        ,ag_rate_id
        ,product_line_id
        ,product_id
        ,insurance_group_id
        ,date_begin
        ,date_end
        ,notes)
      VALUES
        (v_prod_line_cont_id
        ,p_ver_cont_id
        ,v_rate_id
        ,p_product_line_id
        ,p_product_id
        ,p_insurance_group_id
        ,p_db
        ,de
        ,p_notes);
    
      --  commit;
    END;
    /*      else
      raise_application_error(-20001,
                              'Дата начала '||p_db||' больше либо равна дате окончания '||p_de);
    end if;*/
  END;

  PROCEDURE prod_line_contr_update
  (
    p_prod_line_contr_id NUMBER
   ,p_insurance_group_id NUMBER
   ,p_product_id         NUMBER
   ,p_product_line_id    NUMBER
   ,p_defin_rate_id      NUMBER
   ,p_type_value_rate    NUMBER
   ,
    --  p_rule_id            number,
    p_ag_rate_id        NUMBER
   ,p_rate              NUMBER
   ,p_db                DATE
   ,p_de                DATE
   ,p_PROD_COEF_TYPE_ID NUMBER
   ,p_notes             VARCHAR2
  ) IS
    v_insurance_group_id NUMBER;
    v_product_id         NUMBER;
    v_product_line_id    NUMBER;
    v_db                 DATE;
    v_de                 DATE;
  BEGIN
    SELECT pl.insurance_group_id
          ,pl.product_id
          ,pl.product_line_id
          ,pl.date_begin
          ,pl.date_end
      INTO v_insurance_group_id
          ,v_product_id
          ,v_product_line_id
          ,v_db
          ,v_de
      FROM ven_ag_prod_line_contr pl
     WHERE pl.ag_prod_line_contr_id = p_prod_line_contr_id;
  
    v_insurance_group_id := p_insurance_group_id;
    v_product_id         := p_product_id;
    v_product_line_id    := p_product_line_id;
    v_db                 := p_db;
    v_de                 := p_de;
    /*    v_insurance_group_id := nvl(p_insurance_group_id, v_insurance_group_id);
      v_product_id         := nvl(p_product_id, v_product_id);
      v_product_line_id    := nvl(p_product_line_id, v_product_line_id);
      v_db                 := nvl(p_db, v_db);
      v_de                 := nvl(p_de, v_de);
    */
    --  if (p_rule_id is not null and p_type_value_rate is not null and
    --     p_rate is not null and p_defin_rate_id is not null) then
    --Изменить ставку
    UPDATE ven_ag_rate
       SET /* t_rule_id          = p_rule_id,*/  type_rate_value_id = p_type_value_rate
          ,VALUE               = p_rate
          ,type_defin_rate_id  = p_defin_rate_id
          ,T_PROD_COEF_TYPE_ID = p_PROD_COEF_TYPE_ID
     WHERE ag_rate_id = p_ag_rate_id;
    --  end if;
    --Изменить вид риска
    UPDATE ven_ag_prod_line_contr
       SET ag_rate_id         = p_ag_rate_id
          ,product_line_id    = v_product_line_id
          ,product_id         = v_product_id
          ,insurance_group_id = v_insurance_group_id
          ,date_begin         = v_db
          ,date_end           = v_de
          ,notes              = p_notes
     WHERE ag_prod_line_contr_id = p_prod_line_contr_id;
  
    --  commit;
  END;

  PROCEDURE prod_line_contr_del
  (
    p_ver_id       NUMBER
   ,p_prod_line_id NUMBER
  ) --если null, тогда удалить все риски по этой версии
   IS
  BEGIN
    IF p_prod_line_id IS NULL
    THEN
      DELETE FROM ven_ag_prod_line_contr WHERE ag_contract_id = p_ver_id;
      --???Ещё необходимо удалять поля из полей ставки.
    ELSE
      DELETE FROM ven_ag_prod_line_contr
       WHERE ag_contract_id = p_ver_id
         AND ag_prod_line_contr_id = p_prod_line_id;
    END IF;
    --  commit;
  END;

  PROCEDURE prod_line_update_date
  (
    p_ver_id NUMBER
   ,p_db     DATE DEFAULT NULL
   ,p_de     DATE DEFAULT NULL
  ) IS
  BEGIN
    IF p_db IS NOT NULL
    THEN
      UPDATE ven_ag_prod_line_contr c SET c.date_begin = p_db WHERE c.ag_contract_id = p_ver_id;
    END IF;
  
    IF p_de IS NOT NULL
    THEN
      UPDATE ven_ag_prod_line_contr c SET c.date_end = p_de WHERE c.ag_contract_id = p_ver_id;
    END IF;
  
  END;

  FUNCTION get_agent_rate_by_cover
  (
    p_p_cover_id NUMBER
   ,p_agent_id   NUMBER
   ,p_date       DATE
  ) RETURN NUMBER IS
    v_ret_val            NUMBER;
    v_product_line_id    NUMBER;
    v_product_id         NUMBER;
    v_insurance_group_id NUMBER;
  BEGIN
    v_ret_val            := NULL;
    v_product_id         := NULL;
    v_product_line_id    := NULL;
    v_insurance_group_id := NULL;
  
    BEGIN
      SELECT pv.product_id
            ,pl.insurance_group_id
            ,plo.product_line_id
        INTO v_product_id
            ,v_insurance_group_id
            ,v_product_line_id
        FROM p_cover c
        JOIN t_prod_line_option plo
          ON c.t_prod_line_option_id = plo.id
        JOIN t_product_line pl
          ON pl.id = plo.product_line_id
        JOIN t_product_ver_lob pvl
          ON pvl.t_product_ver_lob_id = pl.product_ver_lob_id
        JOIN t_product_version pv
          ON pv.t_product_version_id = pvl.product_version_id
       WHERE c.p_cover_id = p_p_cover_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
    END;
  
    BEGIN
      SELECT *
        INTO v_ret_val
        FROM (SELECT aplc.ag_prod_line_contr_id
                FROM ag_contract_header ach
                JOIN ag_contract ac
                  ON ac.ag_contract_id = ach.last_ver_id
                 AND p_date BETWEEN ac.date_begin AND ac.date_end
                JOIN ag_prod_line_contr aplc
                  ON aplc.ag_contract_id = ac.ag_contract_id
              --join ag_rate ar on ar.ag_rate_id = aplc.ag_rate_id
                JOIN doc_status ds
                  ON ds.document_id = ac.ag_contract_id
                JOIN doc_status_ref dsr
                  ON dsr.doc_status_ref_id = ds.doc_status_ref_id
               WHERE dsr.name = 'Действующий'
                 AND ach.agent_id = p_agent_id
                 AND aplc.product_line_id = v_product_line_id)
       WHERE rownum = 1;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        BEGIN
          SELECT *
            INTO v_ret_val
            FROM (SELECT aplc.ag_prod_line_contr_id
                    FROM ag_contract_header ach
                    JOIN ag_contract ac
                      ON ac.ag_contract_id = ach.last_ver_id
                     AND p_date BETWEEN ac.date_begin AND ac.date_end
                    JOIN ag_prod_line_contr aplc
                      ON aplc.ag_contract_id = ac.ag_contract_id
                  --join ag_rate ar on ar.ag_rate_id = aplc.ag_rate_id
                    JOIN doc_status ds
                      ON ds.document_id = ac.ag_contract_id
                    JOIN doc_status_ref dsr
                      ON dsr.doc_status_ref_id = ds.doc_status_ref_id
                   WHERE dsr.name = 'Действующий'
                     AND ach.agent_id = p_agent_id
                     AND aplc.product_id = v_product_id)
           WHERE rownum = 1;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            BEGIN
              SELECT *
                INTO v_ret_val
                FROM (SELECT aplc.ag_prod_line_contr_id
                        FROM ag_contract_header ach
                        JOIN ag_contract ac
                          ON ac.ag_contract_id = ach.last_ver_id
                         AND p_date BETWEEN ac.date_begin AND ac.date_end
                        JOIN ag_prod_line_contr aplc
                          ON aplc.ag_contract_id = ac.ag_contract_id
                      --join ag_rate ar on ar.ag_rate_id = aplc.ag_rate_id
                        JOIN doc_status ds
                          ON ds.document_id = ac.ag_contract_id
                        JOIN doc_status_ref dsr
                          ON dsr.doc_status_ref_id = ds.doc_status_ref_id
                       WHERE dsr.name = 'Действующий'
                         AND ach.agent_id = p_agent_id
                         AND aplc.insurance_group_id = v_insurance_group_id)
               WHERE rownum = 1;
            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                NULL;
            END;
        END;
    END;
    RETURN v_ret_val;
  END;

  PROCEDURE set_header_status(p_doc_id IN NUMBER) IS
    v_New_Status_ID NUMBER;
    v_Contract_ID   NUMBER;
  BEGIN
    SELECT dsr.doc_status_ref_id INTO v_New_Status_ID FROM Doc_Status_Ref dsr WHERE dsr.brief = 'NEW';
    --    v_New_Status_ID:=ent.g
    BEGIN
      SELECT ach.last_ver_id
        INTO v_Contract_ID
        FROM ag_contract_header ach
       WHERE ach.ag_contract_header_id = p_doc_id;
      doc.set_doc_status(p_doc_id, doc.get_doc_status_id(v_Contract_ID));
    EXCEPTION
      WHEN OTHERS THEN
        doc.set_doc_status(p_doc_id, v_New_Status_ID);
    END;
  END;

  PROCEDURE get_rate
  (
    p_categ_from_id IN NUMBER
   ,p_categ_to_id   IN NUMBER
   ,p_product_id    IN NUMBER
   ,p_sq_year_id    IN NUMBER DEFAULT 1
   ,p_date          IN DATE DEFAULT SYSDATE
   ,p_def_id        OUT NUMBER
   ,p_type_id       OUT NUMBER
   ,p_com           OUT NUMBER
  ) IS
    v_brief_def    VARCHAR2(200);
    v_brief_tariff VARCHAR2(200);
    v_com          NUMBER;
    v_ct           NUMBER;
    v_attrs        pkg_tariff_calc.attr_type;
  
  BEGIN
    SELECT a.commis
          ,a.ag_type_defin_rate_id
          ,a.ag_type_rate_value_id
          ,a.t_prod_coef_type_id
      INTO v_com
          ,p_def_id
          ,p_type_id
          ,v_ct
      FROM ven_t_agent_commis a
     WHERE a.ag_category_from_id = p_categ_from_id
       AND (a.ag_category_to_id = nvl(p_categ_to_id, 0) OR
           (a.ag_category_to_id IS NULL AND nvl(p_categ_to_id, 0) = 0))
       AND a.date_in <= p_date
       AND rownum = 1
     ORDER BY a.date_in;
  
    SELECT r.brief
      INTO v_brief_def
      FROM ven_ag_type_defin_rate r
     WHERE r.ag_type_defin_rate_id = p_def_id;
  
    IF v_brief_def = 'CONSTANT'
    THEN
      p_com := v_com;
    ELSIF v_brief_def = 'FUNCTION'
    THEN
      SELECT ty.brief
        INTO v_brief_tariff
        FROM t_prod_coef_type ty
       WHERE ty.t_prod_coef_type_id = v_ct;
      --год действия = 1
    
      v_attrs(1) := p_product_id;
      v_attrs(2) := nvl(p_sq_year_id, 1);
      p_com := pkg_tariff_calc.calc_coeff_val(v_brief_tariff, v_attrs, 2);
    ELSE
      p_com := NULL;
    END IF;
  EXCEPTION
    WHEN no_data_found THEN
      p_def_id  := NULL;
      p_type_id := NULL;
      p_com     := NULL;
  END;

  /*
    function get_commiss_by_ctg_rel(p_product_id number,
                                    p_year_contract number,
                                    p_ctg_source_id number,
                                    p_ctg_destination_id number,
                                    p_date date
                                   ) return number is
    v_ret_val number;
    begin
      begin
      select ac.commis into v_ret_val
      from t_agent_commis ac
      where ac.ag_category_from_id = p_ctg_source_id
        and ac.ag_category_to_id = p_ctg_destination_id
        and ac.contract_period = p_year_contract
        and ac.product_id = p_product_id
        and ac.date_in = (
                          select max(ac2.date_in)
                            from t_agent_commis ac2
                           where
                              ac2.ag_category_from_id = p_ctg_source_id
                              and ac2.ag_category_to_id = p_ctg_destination_id
                              and ac2.contract_period = p_year_contract
                              and ac2.product_id = p_product_id
                              and ac2.date_in < p_date
                         );
      exception
        when NO_DATA_FOUND then
          v_ret_val := 0;
      end;
      return v_ret_val;
    end;
  
  */

  --процедуру надо исправлять в связи с изменением полей в таблице AGENT_REPORT
  --для ВТБ не используется процедура
  PROCEDURE make_comiss_to_manager(p_akt_agent_id IN NUMBER) IS
  
    /* v_agent_id          number;
    v_akt_date          date;
    v_date_begin        date;
    v_product_id        number;
    v_contract_period   number;
    v_ctg_source_id     number;
    v_amount            number;
    v_oper_templ_id     number;
    v_trans_templ_id    number;
    v_dt_acc_id         number;
    v_ct_acc_id         number;
    v_Doc_Status_Ref_ID number;
    v_oper_id           number;
    v_oper_name         varchar2(1000);
    v_ent_contact_id    number;
    v_amount_acc        number;
    v_sq_year_id        number;
    v_def_id            number;
    v_type_id           number;
    v_commiss           number;  */
  BEGIN
    NULL;
    /*
       v_agent_id := null;
       v_akt_date := null;
       v_date_begin := null;
       v_product_id := null;
       v_contract_period := null;
       v_ctg_source_id := null;
       v_amount := null;
       v_oper_templ_id := null;
       v_trans_templ_id := null;
       v_dt_acc_id := null;
       v_ct_acc_id := null;
       v_Doc_Status_Ref_ID := null;
       v_oper_id := null;
       v_oper_name := null;
       v_ent_contact_id := ent.id_by_brief('CONTACT');
       v_amount_acc := null;
       begin
    -- находим агента, его категорию и период (v_date_begin, v_akt_date) за который ищем проводки
        select ar.report_date, ac.date_begin, ach.agent_id, ac.category_id
          into v_akt_date, v_date_begin, v_agent_id, v_ctg_source_id
          from agent_report ar, ag_contract_header ach, ag_contract ac
          where ar.agent_report_id = p_akt_agent_id
            and ar.ag_contract_id = ac.ag_contract_id
            and ac.contract_id = ach.ag_contract_header_id;
    
    -- найдём oper_template_id
       select ot.oper_templ_id, ot.name into v_oper_templ_id, v_oper_name
       from oper_templ ot where ot.brief = 'ВзаимозачКомисМежАгент';
    -- найдём Doc_Status_Ref_ID
       select dsr.doc_status_ref_id into v_Doc_Status_Ref_ID
       from doc_status_ref dsr where dsr.name = 'Новый';
    
    -- Узнаём общие параметры для проводок
       select tt.trans_templ_id, tt.dt_account_id, tt.ct_account_id
       into v_trans_templ_id, v_dt_acc_id, v_ct_acc_id
       from trans_templ tt where tt.brief = 'ВзаимозачКомисМежАгент';
    
    
        -- цикл по проводкам по переносу задолженности
        -- для определения аналитик.
        for c_trans in (
                         select t.trans_id,
                                t.trans_amount,
                                t.trans_fund_id,
                                t.a1_dt_ure_id,
                                t.a1_dt_uro_id,
                                t.a1_ct_ure_id,
                                t.a1_ct_uro_id,
                                t.a2_dt_ure_id,
                                t.a2_dt_uro_id,
                                t.a2_ct_ure_id,
                                t.a2_ct_uro_id,
                                t.a3_dt_ure_id,
                                t.a3_dt_uro_id,
                                t.a3_ct_ure_id,
                                t.a3_ct_uro_id,
                                t.a4_dt_ure_id,
                                t.a4_dt_uro_id,
                                t.a4_ct_ure_id,
                                t.a4_ct_uro_id,
                                t.a5_dt_ure_id,
                                t.a5_dt_uro_id,
                                t.a5_ct_ure_id,
                                t.a5_ct_uro_id,
                                t.acc_chart_type_id,
                                t.acc_fund_id,
                                t.acc_amount,
                                t.acc_rate,
                                t.source
                           from trans t, trans_templ tt
                           where t.trans_templ_id = tt.trans_templ_id
                             and tt.brief = 'ПеренесЗадолж'
                             and t.a1_dt_uro_id = v_agent_id
                             and t.trans_date between v_date_begin and v_akt_date
                            -- условие на то что проводки по переносу задолженности больше нигде не учтены
                             and not exists
                                           ( select t2.trans_id
                                                   from trans t2,
                                                        trans_templ tt2,
                                                        oper o,
                                                        doc_set_off dso,
                                                        ac_payment ap,
                                                        agent_report_cont arc
                                                   where tt2.brief = 'ПеренесЗадолж'
                                                     and tt2.trans_templ_id = t2.trans_templ_id
                                                     and o.oper_id = t2.oper_id
                                                     and o.document_id = dso.doc_set_off_id
                                                     and ap.payment_id = dso.child_doc_id
                                                     and ap.payment_id = arc.payment_id
                                                     and t2.trans_id = t.trans_id
                                                     and arc.agent_report_id <> p_akt_agent_id
                                           )
                       )
       loop
          -- находим продукт
          select pv.product_id into v_product_id
          from t_product_version pv, t_product_ver_lob pvl, t_product_line pl, t_prod_line_option plo
          where pvl.product_version_id = pv.t_product_version_id
            and pl.product_ver_lob_id = pvl.t_product_ver_lob_id
            and plo.product_line_id = pl.id
            and plo.id = c_trans.a4_dt_uro_id;
    
          -- находим срок действия договора страхования
          select decode(ceil((v_akt_date - p.start_date)/365.33),0,1,ceil((v_akt_date - p.start_date)/365.33))
          into v_contract_period
          from p_policy p
          where p.policy_id = c_trans.a2_dt_uro_id;
    
          select y.t_sq_year_id
            into v_sq_year_id
            from t_sq_year y
          where y.brief=v_contract_period;
    
          -- узнаём кому платить и его категорию
          for c_manager in (
                             select ac.category_id,
                                    ach.agent_id
                             from doc_doc dd,
                                  ag_commiss agc,
                                  ag_contract ac,
                                  ag_contract_header ach
                             where agc.ag_commiss_id = dd.doc_doc_id
                               and ac.ag_contract_id = dd.parent_id
                               and ach.ag_contract_header_id = ac.contract_id
                               and dd.child_id = (select ar.ag_contract_id from agent_report ar
                                                   where ar.agent_report_id = p_akt_agent_id
                                                 )
                           )
          loop
            get_rate(v_ctg_source_id,
                     c_manager.category_id,
                     v_product_id,
                     v_sq_year_id,
                     v_akt_date,
                     v_def_id,
                     v_type_id,
                     v_commiss
                    );
           v_amount := round(c_trans.trans_amount * v_commiss/100,2);
    
           v_amount_acc := round(c_trans.acc_amount * v_commiss/100,2);
    
           if v_amount > 0.009 then
    -- вставляем операцию
             insert into oper
               (
                 oper_id,
                 oper_templ_id,
                 document_id,
                 oper_date,
                 name,
                 doc_status_ref_id
               )
             values
               (
                 sq_oper.nextval,
                 v_oper_templ_id,
                 p_akt_agent_id,
                 v_akt_date,
                 v_oper_name,
                 v_Doc_Status_Ref_ID
               )
             returning oper_id into v_oper_id;
             commit;
    
             insert into trans
               (
                trans_id,
                trans_date,
                trans_fund_id,
                trans_amount,
                dt_account_id,
                ct_account_id,
                is_accepted,
                a1_dt_ure_id,
                a1_dt_uro_id,
                a1_ct_ure_id,
                a1_ct_uro_id,
                a2_dt_ure_id,
                a2_dt_uro_id,
                a2_ct_ure_id,
                a2_ct_uro_id,
                a3_dt_ure_id,
                a3_dt_uro_id,
                a3_ct_ure_id,
                a3_ct_uro_id,
                a4_dt_ure_id,
                a4_dt_uro_id,
                a4_ct_ure_id,
                a4_ct_uro_id,
                a5_dt_ure_id,
                a5_dt_uro_id,
                a5_ct_ure_id,
                a5_ct_uro_id,
                trans_templ_id,
                acc_chart_type_id,
                acc_fund_id,
                acc_amount,
                acc_rate,
                oper_id,
                source
               )
             values
               (
                sq_trans.nextval,
                v_akt_date,
                c_trans.trans_fund_id,
                v_amount,
                v_dt_acc_id,
                v_ct_acc_id,
                1,
                v_ent_contact_id,
                v_agent_id, -- агент от которого
                v_ent_contact_id,
                c_manager.agent_id, -- агент которому
                c_trans.a2_dt_ure_id,
                c_trans.a2_dt_uro_id,
                c_trans.a2_ct_ure_id,
                c_trans.a2_ct_uro_id,
                c_trans.a3_dt_ure_id,
                c_trans.a3_dt_uro_id,
                c_trans.a3_ct_ure_id,
                c_trans.a3_ct_uro_id,
                c_trans.a4_dt_ure_id,
                c_trans.a4_dt_uro_id,
                c_trans.a4_ct_ure_id,
                c_trans.a4_ct_uro_id,
                c_trans.a5_dt_ure_id,
                c_trans.a5_dt_uro_id,
                c_trans.a5_ct_ure_id,
                c_trans.a5_ct_uro_id,
                v_trans_templ_id,
                c_trans.acc_chart_type_id,
                c_trans.acc_fund_id,
                v_amount_acc,
                c_trans.acc_rate,
                v_oper_id,
                c_trans.source
               );
             commit;
             v_oper_id := null;
           end if;
          end loop;
       end loop;
       commit;
       exception
         when NO_DATA_FOUND then null;
       end;
      */
  END;

  FUNCTION get_aps_id_by_brief(par_brief IN VARCHAR2) RETURN NUMBER IS
    RESULT NUMBER;
  BEGIN
    SELECT p.policy_agent_status_id
      INTO RESULT
      FROM ven_POLICY_AGENT_STATUS p
     WHERE p.brief = par_brief;
    RETURN RESULT;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN NULL;
    
  END; --func

  FUNCTION get_status_agent_policy(par_POLICY_AGENT_ID IN NUMBER) RETURN NUMBER IS
    RESULT NUMBER;
  BEGIN
    SELECT p.status_id
      INTO RESULT
      FROM ven_p_policy_agent p
     WHERE p.p_policy_agent_id = par_POLICY_AGENT_ID;
  
    RETURN RESULT;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN NULL;
  END; --func

  FUNCTION get_id RETURN NUMBER IS
  BEGIN
    RETURN pkg_agent.v_contract_id;
  END;

  PROCEDURE get_parameter(p_contract_id NUMBER) IS
  BEGIN
    pkg_agent.v_contract_id := p_contract_id;
  END;

  FUNCTION Transmit_Policy
  (
    pv_policy_header_id         IN NUMBER
   ,p_old_AG_CONTRACT_HEADER_ID IN NUMBER
   ,p_new_AG_CONTRACT_HEADER_ID IN NUMBER
   ,p_date_break                IN DATE
   ,msg                         OUT VARCHAR2
  ) RETURN NUMBER IS
    --de date;
    rec1 p_policy_agent%ROWTYPE;
    rec2 p_policy_agent%ROWTYPE;
  
    v_rate_type  INTEGER;
    v_rate_value INTEGER;
  
    v_policy_agent_id INTEGER;
    RESULT            NUMBER;
    res               INTEGER;
    s1                VARCHAR(255);
    s2                VARCHAR(255);
    --res1 integer;
    v_pr_gen NUMBER := 0; -- признак принадлежности договора генеральным договорам
  
    dt1 DATE;
    dt2 DATE;
  
    CURSOR curs
    (
      p_h_id   IN NUMBER
     ,p_id     IN NUMBER
     ,p_status VARCHAR2
    ) IS
      SELECT *
        FROM p_policy_agent ppa
       WHERE ppa.policy_header_id = p_h_id
         AND ppa.ag_contract_header_id = p_id
            -- для исключения случаев , когда доля агента не выражается ни в каких единицах
         AND ppa.ag_type_rate_value_id IS NOT NULL
         AND ppa.status_id = ent.get_obj_id('policy_agent_status', p_status);
  
  BEGIN
    msg    := '';
    RESULT := 0;
  
    SAVEPOINT func_trans_pol;
  
    -- получаем запись для определения доли "старого" агента
    OPEN curs(pv_policy_header_id, p_old_AG_CONTRACT_HEADER_ID, 'current');
    FETCH curs
      INTO rec1;
  
    IF curs%NOTFOUND
    THEN
      msg := 'Не найден агент (id=' || p_old_AG_CONTRACT_HEADER_ID ||
             '), привязанный к контракту (id=' || pv_policy_header_id || ')';
      CLOSE curs;
      RETURN 1;
    END IF; -- не смог найти этого агента
    CLOSE curs;
  
    -- дата окончания версии договора агента
    BEGIN
      IF doc.get_doc_status_brief(p_new_AG_CONTRACT_HEADER_ID, p_date_break) = 'BREAK'
      THEN
        SELECT DISTINCT ch.agent_id
          INTO res
          FROM ag_contract_header ch
         WHERE ch.ag_contract_header_id = p_new_AG_CONTRACT_HEADER_ID;
      
        msg := 'Договор агента, получающего пакет договоров, не действует на дату передачи договоров ' ||
               ent.obj_name(ent.id_by_brief('CONTACT'), res) || chr(10) ||
               'Передача договора не была осуществлена';
        RETURN 1;
      ELSE
        BEGIN
          SELECT c.date_end
            INTO dt1
            FROM ven_ag_contract_header ch
                ,ven_ag_contract        c
           WHERE ch.last_ver_id = c.ag_contract_id
             AND ch.ag_contract_header_id = p_new_AG_CONTRACT_HEADER_ID;
        EXCEPTION
          WHEN no_data_found THEN
            msg := 'Не найден агент (id=' || p_new_AG_CONTRACT_HEADER_ID || ')';
            RETURN SQLCODE;
          WHEN OTHERS THEN
            dt1 := SYSDATE + (360 * 100);
        END;
      END IF;
    END;
  
    BEGIN
      BEGIN
        SELECT 1
          INTO v_pr_gen
          FROM dual
         WHERE EXISTS (SELECT '1' FROM ven_gen_policy gp WHERE gp.gen_policy_id = pv_policy_header_id);
      EXCEPTION
        WHEN OTHERS THEN
          v_pr_gen := 0;
      END;
      IF v_pr_gen <> 1
      THEN
        SELECT pp.end_date
          INTO dt2
          FROM ven_p_policy pp
         WHERE pp.policy_id = pkg_policy.get_curr_policy(pv_policy_header_id);
      ELSE
        dt2 := nvl(rec1.date_end, p_date_break);
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        dt2 := nvl(rec1.date_end, p_date_break); -- rec1.date_end; -- p_date_break; -- добавл nvl
    END;
  
    -- ставим старому агенту статус "ОТМЕНЕН"
    UPDATE p_policy_agent pa
       SET date_end       = p_date_break
          ,status_id      = ent.get_obj_id('policy_agent_status', 'CANCEL')
          ,pa.status_date = p_date_break
     WHERE pa.POLICY_HEADER_ID = pv_policy_header_id --cur.num
       AND pa.AG_CONTRACT_HEADER_ID = p_old_AG_CONTRACT_HEADER_ID; --:db_e.AG_CONTRACT_HEADER_ID;
  
    -- ищем нового агента, привязан он уже к этому договору или нет
    OPEN curs(pv_policy_header_id, p_new_AG_CONTRACT_HEADER_ID, 'current');
    FETCH curs
      INTO rec2;
  
    IF curs%FOUND
    THEN
      CLOSE curs;
      -- новый агент уже привязан к этому договору в статуса "действующий"
      IF rec1.ag_type_rate_value_id <> rec2.ag_type_rate_value_id
      THEN
        v_rate_type  := rec2.ag_type_rate_value_id;
        v_rate_value := rec2.part_agent;
        SELECT DISTINCT ch.agent_id
          INTO res
          FROM ag_contract_header ch
         WHERE ch.ag_contract_header_id = p_new_AG_CONTRACT_HEADER_ID;
        msg    := 'Агент ' || ent.obj_name(ent.id_by_brief('CONTACT'), res) ||
                  ', которому передаётся пакет уже привязан к договору страхования.' || chr(10) ||
                  'Тип ставки и ставка этого агента оставлены без изменения';
        RESULT := 2;
      END IF;
      IF rec1.ag_type_rate_value_id = rec2.ag_type_rate_value_id
      THEN
        v_rate_type  := rec2.ag_type_rate_value_id;
        v_rate_value := rec1.part_agent + rec2.part_agent;
        SELECT DISTINCT ch.agent_id
          INTO res
          FROM ag_contract_header ch
         WHERE ch.ag_contract_header_id = p_new_AG_CONTRACT_HEADER_ID;
        msg    := 'Агент ' || ent.obj_name(ent.id_by_brief('CONTACT'), res) ||
                  ', которому передаётся пакет уже привязан к договору страхования.' || chr(10) ||
                  'Ставка агента была увеличина на ' || rec1.part_agent;
        RESULT := 2;
      END IF;
    
      v_policy_agent_id := rec2.p_policy_agent_id;
    
      UPDATE p_policy_agent ppa
         SET --ppa.date_start= не меняется
             ppa.date_end = GREATEST(to_date(rec1.date_end), to_date(rec2.date_end))
            ,
             --ppa.status_id=не меняется
             --ppa.status_date= не меняется
             ppa.part_agent            = v_rate_value
            ,ppa.ag_type_rate_value_id = v_rate_type
       WHERE ppa.policy_header_id = pv_policy_header_id
         AND ppa.ag_contract_header_id = p_new_AG_CONTRACT_HEADER_ID;
    
    ELSE
      CLOSE curs;
      -- новый агент не находиться в статусе "действующий" для этого договора.
      OPEN curs(pv_policy_header_id, p_new_AG_CONTRACT_HEADER_ID, 'new');
      FETCH curs
        INTO rec2;
    
      IF curs%FOUND
      THEN
        -- агент привязан в статусе "новый"
        CLOSE curs;
        v_policy_agent_id := rec2.p_policy_agent_id;
      
        UPDATE p_policy_agent ppa
           SET ppa.date_start = p_date_break
              ,ppa.date_end   = least(dt1, dt2)
              , -- rec2.date_end,
               /*least(rec1.date_end,rec2.date_end),*/ppa.status_id             = ent.get_obj_id('policy_agent_status'
                                                         ,'current')
              ,ppa.status_date           = p_date_break
              ,ppa.part_agent            = rec1.part_agent
              ,ppa.ag_type_rate_value_id = rec1.ag_type_rate_value_id
         WHERE ppa.p_policy_agent_id = v_policy_agent_id;
        /*where ppa.policy_header_id=pv_policy_header_id
        and ppa.ag_contract_header_id=p_new_AG_CONTRACT_HEADER_ID;*/
      
      ELSE
        CLOSE curs;
        -- агент не привязан к договору
        SELECT sq_p_policy_agent.nextval INTO v_policy_agent_id FROM dual;
      
        INSERT INTO p_policy_agent ppa
          (ppa.p_policy_agent_id
          ,ppa.date_start
          ,ppa.date_end
          ,ppa.status_id
          ,ppa.status_date
          ,ppa.part_agent
          ,ppa.ag_type_rate_value_id
          ,ppa.ag_contract_header_id
          ,ppa.policy_header_id)
        VALUES
          (v_policy_agent_id
          ,p_date_break
          ,least(dt1, dt2)
          , --rec1.date_end,--дата конца = min(дате окончания действия нового аг.договора и договора страх.)
           ent.get_obj_id('policy_agent_status', 'current')
          ,p_date_break
          ,rec1.part_agent
          ,rec1.ag_type_rate_value_id
          ,p_new_AG_CONTRACT_HEADER_ID
          ,pv_policy_header_id); /**/
      
      END IF;
    END IF;
  
    -- определяем для нового агента страховые программы, если они еще не определены для него.
    SELECT COUNT(*) INTO res FROM VEN_P_POLICY_AGENT_COM WHERE p_policy_agent_id = v_policy_agent_id;
  
    IF res = 0
    THEN
      res := pkg_agent.Define_Agent_Prod_Line(v_policy_agent_id, p_new_ag_contract_header_id);
      IF res <> 0
      THEN
        msg    := 'Ошибка при определении страховой программы. 1' || chr(10) || SQLERRM(res);
        RESULT := 1;
      ELSE
        res := pkg_agent.check_defined_commission(pv_policy_header_id, p_new_AG_CONTRACT_HEADER_ID);
        IF res < 0
        THEN
          msg    := 'Ошибка при определении страховой программы. 2' || chr(10) || SQLERRM(res);
          RESULT := 1;
        END IF;
        IF v_pr_gen <> 1
        THEN
          SELECT ch1.num
            INTO s1
            FROM ven_p_pol_header ch1
           WHERE ch1.policy_header_id = pv_policy_header_id;
          --select ch.num into s1 from ven_ag_contract_header ch where ch.ag_contract_header_id=p_old_AG_CONTRACT_HEADER_ID;
        ELSE
          SELECT gp.num INTO s1 FROM ven_gen_policy gp WHERE gp.gen_policy_id = pv_policy_header_id;
        END IF;
        SELECT ch.num
          INTO s2
          FROM ven_ag_contract_header ch
         WHERE ch.ag_contract_header_id = p_new_AG_CONTRACT_HEADER_ID;
      
        IF res > 0
        THEN
          msg    := 'При передаче договора страхования номер ' || s1 || chr(10) ||
                    'агенту с аг.договором номер ' || s2 || chr(10) ||
                    ' значения ставок комиссионного вознаграждения не определены для ' || res ||
                    ' программ.';
          RESULT := 2;
        END IF;
      END IF;
    END IF;
    -- привязка в P_POL_HEADER к новому агенту
    /*    v_new_contract_id:=get_status_contr_activ_id(p_new_AG_CONTRACT_HEADER_ID);
       update P_POL_HEADER pp
       set pp.AG_CONTRACT_1_ID = v_new_contract_id
        where
        ;--p_new_AG_CONTRACT_HEADER_ID;--:db_e.TRANS_AG_CONTRACT_ID;
    */
    RETURN RESULT; -- всё ОК
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK TO func_trans_pol;
      IF curs%ISOPEN
      THEN
        CLOSE curs;
      END IF;
      RETURN SQLCODE;
  END; -- func

  -- проверяет есть ли неопределенные комиссии по договору страхования для
  FUNCTION check_defined_commission
  (
    p_policy_header_id      IN NUMBER
   ,p_ag_contract_header_id IN NUMBER
  ) RETURN NUMBER IS
    v_c               NUMBER;
    RESULT            NUMBER;
    v_id              NUMBER;
    v_policy_agent_id NUMBER;
    v_pr_gen          NUMBER := 0; -- признак принадлежности договора генеральным договорам
  BEGIN
  
    SELECT pa.p_policy_agent_id
      INTO v_policy_agent_id
      FROM p_policy_agent pa
     WHERE pa.policy_header_id = p_policy_header_id
       AND pa.ag_contract_header_id = p_ag_contract_header_id
       AND pa.status_id = ent.get_obj_id('policy_agent_status', 'current');
  
    --v_policy_agent_id:=pkg_policy.get_curr_policy(p_policy_header_id);
  
    /*      SELECT ph.product_id INTO v_id
          FROM p_pol_header ph, p_policy_agent pa
          WHERE ph.policy_header_id=pa.policy_header_id
          AND pa.p_policy_agent_id=v_policy_agent_id;
    */
    BEGIN
      BEGIN
        SELECT 1
          INTO v_pr_gen
          FROM dual
         WHERE EXISTS (SELECT '1' FROM ven_gen_policy gp WHERE gp.gen_policy_id = p_policy_header_id);
      EXCEPTION
        WHEN OTHERS THEN
          v_pr_gen := 0;
      END;
    
      IF v_pr_gen <> 1
      THEN
        SELECT ph.product_id
          INTO v_id
          FROM p_pol_header   ph
              ,p_policy_agent pa
         WHERE ph.policy_header_id = pa.policy_header_id
           AND pa.p_policy_agent_id = v_policy_agent_id;
      ELSE
        SELECT gp.product_id
          INTO v_id
          FROM gen_policy     gp
              ,p_policy_agent pa
         WHERE gp.gen_policy_id = pa.policy_header_id
           AND pa.p_policy_agent_id = v_policy_agent_id;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        RETURN SQLCODE;
    END;
  
    RESULT := 0;
    FOR idx IN (SELECT tpl.id --into result
                  FROM ven_t_product         tp
                      ,ven_t_product_version tpv
                      ,ven_t_product_ver_lob tpvl
                      ,ven_t_product_line    tpl
                 WHERE tpv.product_id(+) = tp.product_id
                   AND tpvl.product_version_id(+) = tpv.t_product_version_id
                   AND tpl.product_ver_lob_id = tpvl.t_product_ver_lob_id
                   AND tp.product_id = v_id)
    LOOP
      --v_id:=get_prod_line_by_product(v_id);
      --if v_id is null then return 0;end if;
      BEGIN
        SELECT COUNT(*)
          INTO v_c
          FROM ven_p_policy_agent_com pac
         WHERE pac.t_product_line_id = idx.id
           AND pac.p_policy_agent_id = v_policy_agent_id
           AND val_com IS NULL
           AND t_prod_coef_type_id IS NULL
         GROUP BY pac.p_policy_agent_id;
      EXCEPTION
        WHEN no_data_found THEN
          v_c := 0;
      END;
      RESULT := RESULT + v_c;
    END LOOP;
    RETURN RESULT;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN 0;
    WHEN OTHERS THEN
      RETURN SQLCODE;
  END; -- func check_defined_commission

  FUNCTION Define_Agent_Prod_Line
  (
    pv_policy_agent_id      IN NUMBER
   ,p_ag_contract_header_id IN NUMBER
   ,p_cur_date              IN DATE DEFAULT SYSDATE
  ) RETURN NUMBER IS
    v_c          NUMBER;
    v_product_id NUMBER;
    v_pr_gen     NUMBER := 0; -- признак принадлежности договора генеральным договорам
  BEGIN
  
    SELECT COUNT(*)
      INTO V_C
      FROM VEN_P_POLICY_AGENT_COM C
     WHERE C.p_policy_agent_id = pv_policy_agent_id;
    /*       select ph.product_id into v_product_id
          FROM p_pol_header ph, p_policy_agent pa
          WHERE ph.policy_header_id=pa.policy_header_id
          AND pa.p_policy_agent_id=pv_policy_agent_id;
    */
    BEGIN
      BEGIN
        SELECT 1
          INTO v_pr_gen
          FROM dual
         WHERE EXISTS (SELECT '1'
                  FROM ven_gen_policy gp
                      ,p_policy_agent pa
                 WHERE gp.gen_policy_id = pa.policy_header_id
                   AND pa.p_policy_agent_id = pv_policy_agent_id);
      EXCEPTION
        WHEN OTHERS THEN
          v_pr_gen := 0;
      END;
    
      IF v_pr_gen <> 1
      THEN
        SELECT ph.product_id
          INTO v_product_id
          FROM p_pol_header   ph
              ,p_policy_agent pa
         WHERE ph.policy_header_id = pa.policy_header_id
           AND pa.p_policy_agent_id = pv_policy_agent_id;
      ELSE
        SELECT gp.product_id
          INTO v_product_id
          FROM gen_policy     gp
              ,p_policy_agent pa
         WHERE gp.gen_policy_id = pa.policy_header_id
           AND pa.p_policy_agent_id = pv_policy_agent_id;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        RETURN SQLCODE;
    END;
  
    IF (V_C <> 0)
    THEN
      DELETE FROM ven_p_policy_agent_com WHERE p_policy_agent_id = pv_policy_agent_id;
    END IF;
  
    INSERT INTO ven_p_policy_agent_com
      (p_policy_agent_com_id
      ,t_product_line_id
      ,p_policy_agent_id
      ,ag_type_rate_value_id
      ,val_com
      ,ag_type_defin_rate_id
      ,t_prod_coef_type_id)
      SELECT sq_p_policy_agent_com.nextval
            ,tpl.id prod_line_id
            ,pv_policy_agent_id
            ,pkg_policy.find_commission(1, p_ag_contract_header_id, tpl.id, p_cur_date)
            ,pkg_policy.find_commission(2, p_ag_contract_header_id, tpl.id, p_cur_date)
            ,pkg_policy.find_commission(3, p_ag_contract_header_id, tpl.id, p_cur_date)
            ,pkg_policy.find_commission(4, p_ag_contract_header_id, tpl.id, p_cur_date)
        FROM ven_t_product         tp
            ,ven_t_product_version tpv
            ,ven_t_product_ver_lob tpvl
            ,ven_t_product_line    tpl
       WHERE tpv.product_id(+) = tp.product_id
         AND tpvl.product_version_id(+) = tpv.t_product_version_id
         AND tpl.product_ver_lob_id = tpvl.t_product_ver_lob_id
         AND tp.product_id = v_product_id;
    RETURN 0;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN SQLCODE;
    
  END; --func

  FUNCTION policy_check_trans(p_ag_contract_header_id NUMBER) RETURN NUMBER IS
    n   NUMBER;
    msg VARCHAR2(255);
    -- возвращает всех агентов с контрактами в "статусе действующий" по всем контрактам,
    -- где агент с p_id является вторым, кроме этого агента с p_id
    CURSOR curs(p_id IN NUMBER) IS
      SELECT *
        FROM p_policy_agent pp
       WHERE pp.status_id = ent.get_obj_id('policy_agent_status', 'CURRENT')
         AND pp.ag_contract_header_id <> p_id
         AND pp.policy_header_id IN
             (SELECT p.policy_header_id
                FROM p_policy_agent p
               WHERE p.ag_contract_header_id = p_id
                 AND p.status_id = ent.get_obj_id('policy_agent_status', 'CURRENT'));
    -- возвращает по заданному контракту p_h_id и id агента p_id все строки из p_policy_agent
    CURSOR curs1
    (
      p_h_id   IN NUMBER
     ,p_id     IN NUMBER
     ,p_status VARCHAR2
    ) IS
      SELECT *
        FROM p_policy_agent ppa
       WHERE ppa.policy_header_id = p_h_id
         AND ppa.ag_contract_header_id = p_id
         AND ppa.status_id = ent.get_obj_id('policy_agent_status', Upper(p_status));
  
    rec1 curs1%ROWTYPE;
    rec  curs%ROWTYPE;
  BEGIN
    BEGIN
      SELECT 1
        INTO n
        FROM dual
       WHERE EXISTS (SELECT COUNT(p.ag_contract_header_id)
                    ,p.policy_header_id
                FROM p_policy_agent p
               WHERE p.status_id = ent.get_obj_id('policy_agent_status', 'CURRENT')
                 AND EXISTS
               (SELECT p1.policy_header_id
                        FROM p_policy_agent p1
                       WHERE p1.ag_contract_header_id = p_ag_contract_header_id
                         AND p1.policy_header_id = p.policy_header_id
                         AND p1.status_id = ent.get_obj_id('policy_agent_status', 'CURRENT'))
              --       and p.ag_contract_header_id=p_ag_contract_header_id
               GROUP BY p.policy_header_id
              HAVING COUNT(p.ag_contract_header_id) <> 2);
    EXCEPTION
      WHEN no_data_found THEN
        n := 0;
    END;
  
    IF n = 1
    THEN
      RETURN 1;
    END IF;
    msg := '';
  
    -- находим всех агентов, которым можно передать доли
    OPEN curs(p_ag_contract_header_id);
    --   while curs%FOUND
    LOOP
      FETCH curs
        INTO rec;
      EXIT WHEN curs%NOTFOUND;
      -- открываем по выбранному контракту (rec.policy_header_id) записи,
      -- относящиеся к проверяемому агенту p_ag_contract_header_id в статусе "действующий"
      OPEN curs1(rec.policy_header_id, p_ag_contract_header_id, 'CURRENT');
      FETCH curs1
        INTO rec1;
      IF curs1%NOTFOUND
      THEN
        CLOSE curs1;
        CLOSE curs;
        EXIT; -- контрактов нет, значит всё ОК, передавать нечего
      END IF;
      -- передаем по выбранному контракту (rec.policy_header_id) долю агента
      -- rec1.ag_contract_header_id (== p_ag_contract_header_id)
      -- агенту  rec.ag_contract_header_id
      n := Transmit_policy(rec.policy_header_id
                          ,rec1.ag_contract_header_id
                          ,rec.ag_contract_header_id
                          ,SYSDATE
                          ,msg);
      IF n < 0
      THEN
        CLOSE curs;
        CLOSE curs1;
        RETURN n;
      END IF;
      CLOSE curs1;
    END LOOP;
  
    UPDATE ven_p_policy_agent pa
       SET pa.status_id = ent.get_obj_id('policy_agent_status', 'CANCEL')
     WHERE pa.ag_contract_header_id = p_ag_contract_header_id
       AND pa.status_id = ent.get_obj_id('policy_agent_status', 'NEW');
  
    RETURN 0;
  END;
  ----------------------------------------------------------------------------
  --****************************************************************************
  -- Функция : Определяет и возвраащает ID статуса агента
  FUNCTION find_id_agent_status(p_ag_contract_header_id NUMBER) RETURN NUMBER IS
  
    v_rez  NUMBER := 1;
    v_hist ven_ag_stat_hist%ROWTYPE;
  BEGIN
    -- определяем актуальную категорию агента
  
    BEGIN
      SELECT c.category_id
        INTO v_hist.ag_category_agent_id
        FROM ven_ag_contract_header ch
            ,ven_ag_contract        c
       WHERE ch.last_ver_id = c.ag_contract_id
         AND ch.ag_contract_header_id = p_ag_contract_header_id;
    EXCEPTION
      WHEN OTHERS THEN
        v_hist.ag_category_agent_id := 1;
    END;
  
    -- определяем текущую категорию агента
    /*
    begin
       select c.category_id into v_hist.ag_category_agent_id
      from   ven_ag_contract_header ch,
              ven_ag_contract c
      where  ch.ag_contract_header_id=c.contract_id
        and  ch.ag_contract_header_id=p_ag_contract_header_id
          and  c.ag_contract_id in (select max(c1.ag_contract_id)
                                    from ven_ag_contract c1
                                    where c1.contract_id=c.contract_id);
    
      exception when others then v_hist.ag_category_agent_id:=1;
       end;
    */
    -- определяем наличие записи в таблице изменения статусов по данной категории
    BEGIN
      SELECT 1
        INTO v_rez
        FROM dual
       WHERE EXISTS (SELECT '1'
                FROM ven_ag_stat_hist t
               WHERE t.ag_contract_header_id = p_ag_contract_header_id
                 AND t.ag_category_agent_id = v_hist.ag_category_agent_id);
    EXCEPTION
      WHEN OTHERS THEN
        v_rez := 0;
    END;
    -- при отсутствии записи - формируем новую запись с наименьшим статусом по данной категории
    IF v_rez = 0
    THEN
    
      BEGIN
        SELECT nvl(MAX(sh.num), 0)
          INTO v_hist.num
          FROM ven_ag_stat_hist sh
         WHERE sh.ag_contract_header_id = p_ag_contract_header_id;
      EXCEPTION
        WHEN OTHERS THEN
          v_hist.num := 0;
      END;
    
      v_hist.num       := v_hist.num + 1;
      v_hist.stat_date := SYSDATE;
    
      BEGIN
        SELECT sa.ag_stat_agent_id
          INTO v_hist.ag_stat_agent_id
          FROM ag_stat_agent sa
         WHERE sa.ag_category_agent_id = v_hist.ag_category_agent_id
           AND sa.is_default = 1;
      EXCEPTION
        WHEN no_data_found THEN
          SELECT NULL INTO v_hist.ag_stat_agent_id FROM dual;
      END;
    
      BEGIN
        INSERT INTO ven_ag_stat_hist
          (ag_category_agent_id, ag_contract_header_id, ag_stat_agent_id, num, stat_date)
        VALUES
          (v_hist.ag_category_agent_id
          ,p_ag_contract_header_id
          ,v_hist.ag_stat_agent_id
          ,v_hist.num
          ,v_hist.stat_date);
      EXCEPTION
        WHEN OTHERS THEN
          raise_application_error(SQLCODE
                                 ,'Не формируется запись изменения статусов:' || SQLERRM);
      END;
    END IF;
    -- возвращаем иди статуса по данной категории
    BEGIN
      SELECT sa.ag_stat_agent_id
        INTO v_hist.ag_stat_agent_id
        FROM ven_ag_stat_hist      sh
            ,ven_ag_category_agent ac
            ,ven_ag_stat_agent     sa
       WHERE sh.ag_category_agent_id = ac.ag_category_agent_id
         AND sh.ag_category_agent_id = sa.ag_category_agent_id(+)
         AND sh.ag_stat_agent_id = sa.ag_stat_agent_id(+)
         AND sh.ag_contract_header_id = p_ag_contract_header_id
         AND sh.num IN (SELECT MAX(t.num)
                          FROM ven_ag_stat_hist t
                         WHERE t.ag_contract_header_id = sh.ag_contract_header_id);
    
    EXCEPTION
      WHEN no_data_found THEN
        SELECT NULL INTO v_hist.ag_stat_agent_id FROM dual;
      
    END;
    RETURN(v_hist.ag_stat_agent_id);
  END;

  FUNCTION CreateContractHeadByTemplId
  (
    p_template_id      IN NUMBER
   ,p_sales_channel_id IN NUMBER
   ,p_date_begin       IN DATE
   ,p_agent_id         IN NUMBER
   ,p_ag_header_id     OUT NUMBER
   ,p_contract_new_id  OUT NUMBER
  ) RETURN NUMBER IS
  
    v_ven_ag_contract_header ven_ag_contract_header%ROWTYPE;
    ret_val                  NUMBER;
    v_ag_header_id           NUMBER;
  BEGIN
  
    --v_ven_ag_contract_header.num := '11111';
  
    contract_header_insert(p_ag_header_id
                          ,v_ven_ag_contract_header.num
                          ,p_date_begin
                          ,NULL
                          ,p_agent_id
                          ,NULL
                          ,NULL
                          ,NULL
                          ,p_sales_channel_id
                          ,p_template_id);
  
    v_ven_ag_contract_header.AG_CONTRACT_HEADER_ID := p_ag_header_id;
  
    ret_val := CreateContractByTemplateId(p_ag_header_id, p_template_id, p_contract_new_id);
  
    IF (ret_val != Utils.c_true)
    THEN
      RETURN ret_val;
    END IF;
  
    RETURN Utils.c_true;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN Utils.c_false;
  END;

  FUNCTION UpdateContract(p_rec VEN_AG_CONTRACT%ROWTYPE) RETURN NUMBER IS
  BEGIN
  
    UPDATE ven_ag_contract
       SET --  ag_contract_id,
                          ent_id = p_rec.ent_id
          ,filial_id            = p_rec.filial_id
          ,ext_id               = p_rec.ext_id
          ,doc_folder_id        = p_rec.doc_folder_id
          ,doc_templ_id         = p_rec.doc_templ_id
          ,guid                 = p_rec.guid
          ,note                 = p_rec.note
          ,num                  = p_rec.num
          ,reg_date             = p_rec.reg_date
          ,agency_id            = p_rec.agency_id
          ,ag_contract_templ_id = p_rec.ag_contract_templ_id
          ,category_id          = p_rec.category_id
          ,class_agent_id       = p_rec.class_agent_id
          ,contract_f_lead_id   = p_rec.contract_f_lead_id
          ,contract_id          = p_rec.contract_id
          ,contract_leader_id   = p_rec.contract_leader_id
          ,contract_recrut_id   = p_rec.contract_recrut_id
          ,date_begin           = p_rec.date_begin
          ,date_end             = p_rec.date_end
          ,delegate_id          = p_rec.delegate_id
          ,fact_dop_rate        = p_rec.fact_dop_rate
          ,initiator_id         = p_rec.initiator_id
          ,is_call_center       = p_rec.is_call_center
          ,leg_pos              = p_rec.leg_pos
          ,method_payment       = p_rec. method_payment
          ,rate_agent           = p_rec.rate_agent
          ,rate_main_agent      = p_rec.rate_main_agent
          ,rate_type_id         = p_rec.rate_type_id
          ,rate_type_main_id    = p_rec.rate_type_main_id
          ,reason_id            = p_rec.reason_id
          ,signer_id            = p_rec.signer_id
     WHERE ag_contract_id = p_rec.ag_contract_id;
  
    RETURN Utils.c_true;
  
  EXCEPTION
    WHEN OTHERS THEN
      RETURN Utils.c_false;
    
  END UpdateContract;

  FUNCTION UpdateContractHeader(p_rec VEN_AG_CONTRACT_HEADER%ROWTYPE) RETURN NUMBER IS
  BEGIN
  
    UPDATE ven_ag_contract_header
       SET --  ag_contract_header_id,
                          ent_id = p_rec.ent_id
          ,filial_id            = p_rec.filial_id
          ,ext_id               = p_rec.ext_id
          ,doc_folder_id        = p_rec.doc_folder_id
          ,doc_templ_id         = p_rec.doc_templ_id
          ,guid                 = p_rec.guid
          ,note                 = p_rec.note
          ,num                  = p_rec.num
          ,reg_date             = p_rec.reg_date
          ,agency_id            = p_rec.agency_id
          ,agent_id             = p_rec.agent_id
          ,ag_contract_templ_id = p_rec.ag_contract_templ_id
          ,ag_contract_templ_k  = p_rec.ag_contract_templ_k
          ,date_begin           = p_rec.date_begin
          ,date_break           = p_rec.date_break
          ,last_ver_id          = p_rec.last_ver_id
          ,templ_brief          = p_rec.templ_brief
          ,templ_name           = p_rec.templ_name
          ,trans_ag_contract_id = p_rec.trans_ag_contract_id
          ,t_sales_channel_id   = p_rec.t_sales_channel_id
     WHERE ag_contract_header_id = p_rec.ag_contract_header_id;
  
    RETURN Utils.c_true;
  
  EXCEPTION
    WHEN OTHERS THEN
      RETURN Utils.c_false;
  END UpdateContractHeader;

END pkg_agent;
/

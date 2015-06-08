CREATE OR REPLACE PACKAGE pkg_rep_utils_ins11 IS

  -- Author  : MMIROVICH
  -- Created : 16.05.2007 13:21:30
  -- Purpose : Пакет для отчетов, предназначенных для Ренессанса

  -- Public type declarations

  -- таблица количества нанятых агентов
  -- автор: Мирович
  TYPE tbl_ag_number IS TABLE OF NUMBER;

  -- таблица с id претензий (c_clam_header)
  -- с фмльтром по названию и типу риска
  -- автор: Мирович
  TYPE tbl_claim_id IS TABLE OF NUMBER;

  -- таблица с id агентских договоров для агентов
  -- со статусом "консультант" и категорией "агент"
  -- автор: Мирович
  TYPE tbl_ag_contract_id IS TABLE OF NUMBER;

  -- универсальная таблица с id договоров
  -- автор: Мирович
  TYPE tbl_id IS TABLE OF NUMBER;

  TYPE tbl_id_test IS TABLE OF NUMBER;

  -- запись с полями "название агенства/канала продаж",
  --"id агенства"," brief канала продаж"
  -- автор: Мирович
  TYPE ag_ch_rec IS RECORD(
     NAME     VARCHAR2(150)
    ,ag_id    NUMBER
    ,ch_brief VARCHAR2(100));

  -- таблица с полями "название агенства/канала продаж",
  --"id агенства"," brief канала продаж"
  -- автор: Мирович
  TYPE tbl_ag_ch IS TABLE OF ag_ch_rec;

  -- запись с полями "id договора", "id агента", "фио агента","id агентства", 
  -- "агентство","brief канала продаж", "канал продаж"
  -- автор: Мирович
  TYPE agents_chanales_rec IS RECORD(
     pol_id   NUMBER
    ,ag_id    NUMBER
    ,ag_fio   VARCHAR2(250)
    ,dep_id   NUMBER
    ,dep_name VARCHAR2(150)
    ,ch_br    VARCHAR2(30)
    ,ch_name  VARCHAR2(150));

  -- таблица записей agents_chanales_rec
  -- автор: Мирович
  TYPE tbl_agents_chanales IS TABLE OF agents_chanales_rec;

  -- запись с полями "id агента", "фио агента","id агентства", 
  -- "агентство","brief канала продаж", "канал продаж", "brief продукта","продукт"
  -- автор: Мирович
  TYPE ag_ch_pr_rec IS RECORD(
     ag_id    NUMBER
    ,ag_fio   VARCHAR2(250)
    ,dep_id   NUMBER
    ,dep_name VARCHAR2(150)
    ,ch_br    VARCHAR2(30)
    ,ch_name  VARCHAR2(150)
    ,pr_br    VARCHAR2(30)
    ,pr_name  VARCHAR2(250));

  -- таблица записей ag_ch_pr_rec
  -- автор: Мирович
  TYPE tbl_ag_ch_pr IS TABLE OF ag_ch_pr_rec;

  -- запись с полями "id договора",
  --"brief продукта","название продукта"
  -- автор: Мирович
  TYPE pol_prod_rec IS RECORD(
     pol_id  NUMBER
    ,pr_br   VARCHAR2(30)
    ,pr_name VARCHAR2(150));

  -- таблица с полями ""id договора",
  --"brief продукта","название продукта"
  -- автор: Мирович
  TYPE tbl_pol_prod IS TABLE OF pol_prod_rec;

  -- Public constant declarations

  -- Public variable declarations

  -- Public function and procedure declarations

  /**
  * Возвращает строку вида "Филиал - Департамент"
  * если они совпадают, то только "Филиал"
  *  @autor Mirovich M.
  *  @param ag_id - ид версии договора,
   * @return - дата
  */
  FUNCTION get_pol_agency_name(p_dep_id NUMBER) RETURN VARCHAR2;

  /**
  * Возвращает дату окончания агентского договора по ид версии договора
  * (дата статуса "расторгнут", "закрыт", "отменен")
  *  @autor Mirovich M.
  *  @param ag_id - ид версии договора,
   * @return - дата
  */
  FUNCTION get_ag_contract_end_date(ag_id NUMBER) RETURN DATE;

  /**
  * Возвращает количество агентов, нанятых в указанном месяце года
  *  @autor Mirovich M.
  *  @param month - месяц,
  *  @param month - год,
   * @return - количество
  */
  FUNCTION get_agent_number
  (
    MONTH VARCHAR2
   ,YEAR  VARCHAR2
  ) RETURN NUMBER;

  /**
  * Возвращает количество агентов, нанятых в указанном месяце года
  * с фильтром по статусу и категории агента
  *  @autor Mirovich M.
  *  @param month - месяц,
  *  @param month - год,
  *  @param st - статус,
  *  @param cat - категория,
   * @return - количество
  */
  FUNCTION get_agent_number
  (
    MONTH VARCHAR2
   ,YEAR  VARCHAR2
   ,st    VARCHAR2
   ,cat   VARCHAR2
  ) RETURN NUMBER;

  /**
  * Возвращает количество агентов, нанятых в месяце month_start и уволенных до месяца month_end
  *  @autor Mirovich M.
  *  @param month_start - месяц (начало периода),
  *  @param month_end - месяц (окончания периода),
  *  @param month - год,
   * @return - количество
  */
  FUNCTION get_agent_drop_number
  (
    month_start VARCHAR2
   ,month_end   VARCHAR2
   ,YEAR        VARCHAR2
  ) RETURN NUMBER;

  /**
  * Возвращает количество агентов, нанятых в месяце month_start и уволенных до месяца month_end
  * с фильтром по статусу и категории агента
  *  @autor Mirovich M.
  *  @param month_start - месяц (начало периода),
  *  @param month_end - месяц (окончания периода),
  *  @param month - год,
  *  @param st - статус,
  *  @param cat - категория,
   * @return - количество
  */
  FUNCTION get_agent_drop_number
  (
    month_start VARCHAR2
   ,month_end   VARCHAR2
   ,YEAR        VARCHAR2
   ,st          VARCHAR2
   ,cat         VARCHAR2
  ) RETURN NUMBER;

  /**
  * Возвращает количество агентов, нанятых в месяце month_start
  * и оставшихся работать вплоть до месяца month_end
  *  @autor Mirovich M.
  *  @param month_start - месяц (начало периода),
  *  @param month_end - месяц (окончания периода),
  *  @param month - год,
   * @return - количество
  */
  FUNCTION get_agent_active
  (
    month_start VARCHAR2
   ,month_end   VARCHAR2
   ,YEAR        VARCHAR2
  ) RETURN NUMBER;

  /**
  * Возвращает количество агентов, нанятых в месяце month_start
  * и оставшихся работать вплоть до месяца month_end
  * с фильтром по статусу и категории агента
  *  @autor Mirovich M.
  *  @param month_start - месяц (начало периода),
  *  @param month_end - месяц (окончания периода),
  *  @param month - год,
   * @return - количество
  */
  FUNCTION get_agent_active
  (
    month_start VARCHAR2
   ,month_end   VARCHAR2
   ,YEAR        VARCHAR2
   ,st          VARCHAR2
   ,cat         VARCHAR2
  ) RETURN NUMBER;

  /**
  * Возвращает сумму продаж по агентам, нанятых в месяце month_start
  * и оставшихся работать вплоть до месяца month_end
  *  @autor Mirovich M.
  *  @param month_start - месяц (начало периода),
  *  @param month_end - месяц (окончания периода),
  *  @param month - год,
   * @return - сумма
  */
  FUNCTION get_agent_sales
  (
    month_start VARCHAR2
   ,month_end   VARCHAR2
   ,YEAR        VARCHAR2
  ) RETURN NUMBER;

  /**
  * Возвращает сумму продаж на одного агента по агентам, нанятых в месяце month_start
  * и оставшихся работать вплоть до месяца month_end
  *  @autor Mirovich M.
  *  @param month_start - месяц (начало периода),
  *  @param month_end - месяц (окончания периода),
  *  @param month - год,
   * @return - сумма на одного агента
  */
  FUNCTION get_agent_sales_per
  (
    month_start VARCHAR2
   ,month_end   VARCHAR2
   ,YEAR        VARCHAR2
  ) RETURN NUMBER;

  /**
  * Возвращает сумму продаж на одного агента по агентам, нанятых в месяце month_start
  * и оставшихся работать вплоть до месяца month_end
  * с фильтром по статусу и категории агента
  *  @autor Mirovich M.
  *  @param month_start - месяц (начало периода),
  *  @param month_end - месяц (окончания периода),
  *  @param month - год,
   * @return - сумма на одного агента
  */
  FUNCTION get_agent_sales_per
  (
    month_start VARCHAR2
   ,month_end   VARCHAR2
   ,YEAR        VARCHAR2
   ,st          VARCHAR2
   ,cat         VARCHAR2
  ) RETURN NUMBER;

  /**
  * Возвращает сумму бонусов на одного агента по агентам, нанятых в месяце month_start
  * и оставшихся работать вплоть до месяца month_end
  *  @autor Mirovich M.
  *  @param month_start - месяц (начало периода),
  *  @param month_end - месяц (окончания периода),
  *  @param month - год,
   * @return - сумма на одного агента
  */
  FUNCTION get_agent_bonus_per
  (
    month_start VARCHAR2
   ,month_end   VARCHAR2
   ,YEAR        VARCHAR2
  ) RETURN NUMBER;

  /**
  * Возвращает сумму бонусов на одного агента по агентам, нанятых в месяце month_start
  * и оставшихся работать вплоть до месяца month_end
  * с фильтром по статусу и категории агента
  *  @autor Mirovich M.
  *  @param month_start - месяц (начало периода),
  *  @param month_end - месяц (окончания периода),
  *  @param month - год,
   * @return - сумма на одного агента
  */
  FUNCTION get_agent_bonus_per
  (
    month_start VARCHAR2
   ,month_end   VARCHAR2
   ,YEAR        VARCHAR2
   ,st          VARCHAR2
   ,cat         VARCHAR2
  ) RETURN NUMBER;

  /**
  * Возвращает сумму продаж по агентам, нанятых в месяце month_start
  * и оставшихся работать вплоть до месяца month_end
  * с фильтром по статусу и категории агента
  *  @autor Mirovich M.
  *  @param month_start - месяц (начало периода),
  *  @param month_end - месяц (окончания периода),
  *  @param month - год,
  *  @param st - статус,
  *  @param cat - категория,
  * @return - сумма
  */
  FUNCTION get_agent_sales
  (
    month_start VARCHAR2
   ,month_end   VARCHAR2
   ,YEAR        VARCHAR2
   ,st          VARCHAR2
   ,cat         VARCHAR2
  ) RETURN NUMBER;

  /**
  * Возвращает таблицу количества агентов, нанятых в каждом месяце года
  * и оставшихся работать вплоть до месяца month_end
  *  @autor Mirovich M.
   *  @param month_start - месяц (начало периода),
  *  @param month_end - месяц (окончания периода),
  *  @param month - год,
  * @return - бонус
  */
  FUNCTION get_agent_bonus
  (
    month_start VARCHAR2
   ,month_end   VARCHAR2
   ,YEAR        VARCHAR2
  ) RETURN NUMBER;

  /**
  * Возвращает сумму продаж по агентам, нанятых в месяце month_start
  * и оставшихся работать вплоть до месяца month_end
  * с фильтром по статусу и категории агента
  *  @autor Mirovich M.
  *  @param month_start - месяц (начало периода),
  *  @param month_end - месяц (окончания периода),
  *  @param month - год,
  *  @param st - статус,
  *  @param cat - категория,
  * @return - бонус
   */
  FUNCTION get_agent_bonus
  (
    month_start VARCHAR2
   ,month_end   VARCHAR2
   ,YEAR        VARCHAR2
   ,st          VARCHAR2
   ,cat         VARCHAR2
  ) RETURN NUMBER;

  /**
  * Возвращает ДАВ как процент от продаж по агентам, нанятых в месяце month_start
  * и оставшихся работать вплоть до месяца month_end
  *  @autor Mirovich M.
  *  @param month_start - месяц (начало периода),
  *  @param month_end - месяц (окончания периода),
  * @return - бонус как % от продаж
   */
  FUNCTION get_agent_bonus_sales
  (
    month_start VARCHAR2
   ,month_end   VARCHAR2
   ,YEAR        VARCHAR2
  ) RETURN NUMBER;
  /**
  * Возвращает ДАВ как процент от  продаж по агентам, нанятых в месяце month_start
  * и оставшихся работать вплоть до месяца month_end
  * с фильтром по статусу и категории агента
  *  @autor Mirovich M.
  *  @param month_start - месяц (начало периода),
  *  @param month_end - месяц (окончания периода),
  *  @param month - год,
  *  @param st - статус,
  *  @param cat - категория,
  * @return - бонус как процент о продаж
   */
  FUNCTION get_agent_bonus_sales
  (
    month_start VARCHAR2
   ,month_end   VARCHAR2
   ,YEAR        VARCHAR2
   ,st          VARCHAR2
   ,cat         VARCHAR2
  ) RETURN NUMBER;

  /**
  * Возвращает таблицу количества агентов, нанятых в каждом месяце года
  * и оставшихся работать вплоть до месяца month_end
  *  @autor Mirovich M.
  *  @param month - месяц,
  *  @param month - год,
  * @return - таблица
  */
  FUNCTION get_agent_active_year
  (
    MONTH VARCHAR2
   ,YEAR  VARCHAR2
  ) RETURN tbl_ag_number
    PIPELINED;

  /**
  * Возвращает таблицу с id агентских договоров для агентов с
  * заданными статусом и категорией
  *  @autor Mirovich M.
  *  @param month - месяц,
  *  @param month - год,
  * @return - таблица
  */
  FUNCTION get_ag_contract_id
  (
    st  VARCHAR2
   ,cat VARCHAR2
  ) RETURN tbl_ag_contract_id
    PIPELINED;

  /**
  * Возвращает номер месяца, предшествующий данному на col месяцев
  * специфическая функция для отчета Tracking Report 1
  *  @autor Mirovich M.
  *  @param month - месяц,
  *  @param year - год,
  *  @param col - количество месяцев,
   * @return - номер месяца (строка)
  */
  FUNCTION get_prev_month
  (
    DATA DATE
   ,COL  NUMBER
  ) RETURN VARCHAR2;
  /**
  * Возвращает процент уволившихся агентов за период с month_start по month_end
  * принятых на работу в month_start
  * специфическая функция для отчета Tracking Report 1
  *  @autor Mirovich M.
  *  @param month_start - месяц (начало периода),
  *  @param month_end - месяц (окончания периода),
  * @return - процент
  */
  FUNCTION get_agent_drop_percent
  (
    month_start VARCHAR2
   ,month_end   VARCHAR2
   ,YEAR        VARCHAR2
  ) RETURN NUMBER;

  /**
  * Возвращает процент уволившихся агентов за период с month_start по month_end
  * принятых на работу в month_start
  * с фильтром по статусу и категории агента
  * специфическая функция для отчета Tracking Report 1
  *  @autor Mirovich M.
  *  @param month_start - месяц (начало периода),
  *  @param month_end - месяц (окончания периода),
  * @return - процент
  */
  FUNCTION get_agent_drop_percent
  (
    month_start VARCHAR2
   ,month_end   VARCHAR2
   ,YEAR        VARCHAR2
   ,st          VARCHAR2
   ,cat         VARCHAR2
  ) RETURN NUMBER;

  /**
  * Процедура обновляет строку таблицы для формирования отчета Tracking Report 1
  * специфическая функция для отчета Tracking Report 1
  *  @autor Mirovich M.
  *  @param tyear - год,
  *  @param tmonth - месяц,
  */
  PROCEDURE create_month_tr1
  (
    tmonth VARCHAR2
   ,tyear  VARCHAR2
  );

  /**
  * Процедура обновляет строку таблицы для формирования отчета Tracking Report 1
  * с фильтром по категориии и статусу агента
  * специфическая функция для отчета Tracking Report 1
  *  @autor Mirovich M.
  *  @param tyear - год,
  *  @param tmonth - месяц,
  *  @param st - статус,
  *  @param cat - категория,
  */
  PROCEDURE create_month_tr1
  (
    tmonth VARCHAR2
   ,tyear  VARCHAR2
   ,st     VARCHAR2
   ,cat    VARCHAR2
  );

  -------------------------------------------------------------------------------
  -------------------------------------------------------------------------------
  ------------------------- Отчет о состоянии договора
  -------------------------------------------------------------------------------
  -------------------------------------------------------------------------------
  /**
  * Возвращает месяц, в котором договор участвовал в расчете ДАВ
  *  @autor Mirovich M.
  *  @param pol_id - id версии договора
  * @return - номер месяц
  */

  FUNCTION get_month_agent_dav(pol_id NUMBER) RETURN DATE;

  -------------------------------------------------------------------------------
  -------------------------------------------------------------------------------
  ------------------------- Отчет TRACKING REPORT 2
  -------------------------------------------------------------------------------
  -------------------------------------------------------------------------------
  /**
  * Возвращает количество агенств, существующих в текущем месяце
   *  @autor Mirovich M.
   *  @param month - месяц
   *  @param year - год
   *  @return - количество агенств
  */
  FUNCTION get_agency_number
  (
    MONTH VARCHAR2
   ,YEAR  VARCHAR2
  ) RETURN NUMBER;

  /**
  * Возвращает таблицу с id агентов для которых задан признак ПБОЮЛ, канал продаж
  *  @autor Mirovich M.
  *  @return - таблицу с is агентов
  */
  FUNCTION get_part_time_id RETURN tbl_ag_contract_id
    PIPELINED;

  /**
  * Возвращает таблицу с id агентов для которых задан канал продаж
  *  @autor Mirovich M.
  *  @param chanal - канал продаж
  *  @return - таблицу с is агентов
  */
  FUNCTION get_ag_chanal_id(chanal VARCHAR2) RETURN tbl_ag_contract_id
    PIPELINED;

  /**
  * Возвращает таблицу с id агентов для всех каналов продаж
  * кроме агентского, банковского, брокерского и call - центра
  *  @autor Mirovich M.
  *  @param chanal - канал продаж
  *  @return - таблицу с is агентов
  */
  FUNCTION get_ag_other_chanal_id RETURN tbl_ag_contract_id
    PIPELINED;

  /**
  * Возвращает количество агентов Part time, работающих в указанные месяц и год
   *  @autor Mirovich M.
   *  @param month - месяц
   *  @param year - год
   *  @return - количество агентов Part timr
  */
  FUNCTION get_ag_part_time_num
  (
    MONTH VARCHAR2
   ,YEAR  VARCHAR2
  ) RETURN NUMBER;

  /**
  * Возвращает количество агентов , работающих в указанные месяц и год
  * с фильтром по статусу и категории агента
   *  @autor Mirovich M.
   *  @param month - месяц
   *  @param year - год
   *  @return - количество агентов
  */
  FUNCTION get_ag_st_cat_num
  (
    MONTH VARCHAR2
   ,YEAR  VARCHAR2
   ,st    VARCHAR2
   ,cat   VARCHAR2
  ) RETURN NUMBER;

  /**
  * Возвращает количество агентов , уволенных в указанном месяце года
  * с фильтром по статусу и категории агента
   *  @autor Mirovich M.
   *  @param month - месяц
   *  @param year - год
   *  @param st - статус
   *  @param cat - категория
   *  @return - количество уволенных агентов
  */
  FUNCTION get_agent_drop_number
  (
    MONTH VARCHAR2
   ,YEAR  VARCHAR2
   ,st    VARCHAR2
   ,cat   VARCHAR2
  ) RETURN NUMBER;

  /**
  * Возвращает количество агентов PT, уволенных в указанном месяце года
   *  @autor Mirovich M.
   *  @param month - месяц
   *  @param year - год
   *  @return - количество уволенных агентов
  */
  FUNCTION get_ag_drop_part_time
  (
    MONTH VARCHAR2
   ,YEAR  VARCHAR2
  ) RETURN NUMBER;

  /**
  * Возвращает количество агентов , сменивших категорию в указанном месяце
  *  @autor Mirovich M.
   *  @param month - месяц
   *  @param year - год
   *  @param cat_old - категория в начале периода
   *  @param cat_new - категория в конце приода
   *  @param st - статус агента в начале периода
   *  @return - количество агентов, сменивших категорию
  */
  FUNCTION get_ag_change_cat_num
  (
    MONTH   VARCHAR2
   ,YEAR    VARCHAR2
   ,cat_old VARCHAR2
   ,cat_new VARCHAR2
   ,st      VARCHAR2
  ) RETURN NUMBER;

  /**
  * Возвращает сумму продаж по агентам с указнными категорией и статусом
  *  @autor Mirovich M.
   *  @param month - месяц
   *  @param year - год
   *  @param cat - категория в начале периода
   *  @param st - статус агента в начале периода
   *  @return - сумму продаж
  */
  FUNCTION get_agent_sales
  (
    MONTH VARCHAR2
   ,YEAR  VARCHAR2
   ,st    VARCHAR2
   ,cat   VARCHAR2
  ) RETURN NUMBER;

  /**
  * Возвращает сумму продаж по агентам с накопленным итогом с начала года
  *  @autor Mirovich M.
   *  @param month - месяц
   *  @param year - год
   *  @param cat - категория в начале периода
   *  @param st - статус агента в начале периода
   *  @return - сумму продаж
  */
  FUNCTION get_agent_sales_ytd
  (
    MONTH VARCHAR2
   ,YEAR  VARCHAR2
   ,st    VARCHAR2
   ,cat   VARCHAR2
  ) RETURN NUMBER;

  /**
  * Возвращает сумму продаж по агентам PT
  *  @autor Mirovich M.
  *  @param month - месяц
  *  @param year - год
  *  @return - сумму продаж
  */
  FUNCTION get_ag_sales_part_time
  (
    MONTH VARCHAR2
   ,YEAR  VARCHAR2
  ) RETURN NUMBER;

  /**
  * Возвращает сумму продаж по агентам с указанным каналом продаж
  *  @autor Mirovich M.
  *  @param month - месяц
  *  @param year - год
  *  @param chanal - канал продаж
  *  @return - сумму продаж
  */
  FUNCTION get_ag_sales_chanal
  (
    MONTH  VARCHAR2
   ,YEAR   VARCHAR2
   ,chanal VARCHAR2
  ) RETURN NUMBER;

  /**
  * Возвращает сумму продаж для всех каналов продаж
  * кроме агентского, банковского,брокерского и call - центра
  *  @autor Mirovich M.
  *  @param month - месяц
  *  @param year - год
  *  @return - сумму продаж
  */
  FUNCTION get_ag_sales_other_chanal
  (
    MONTH VARCHAR2
   ,YEAR  VARCHAR2
  ) RETURN NUMBER;

  /**
  * Возвращает сумму продаж по агентам PT с накопленным итогом с начала года
  *  @autor Mirovich M.
  *  @param month - месяц
  *  @param year - год
  *  @return - сумму продаж
  */
  FUNCTION get_ag_sales_part_time_ytd
  (
    MONTH VARCHAR2
   ,YEAR  VARCHAR2
  ) RETURN NUMBER;

  /**
  * Возвращает сумму продаж по агентам с указанным каналом продаж
  * с накопленным итогом с начала года
  *  @autor Mirovich M.
  *  @param month - месяц
  *  @param year - год
  *  @param chanal - канал продаж
  *  @return - сумму продаж
  */
  FUNCTION get_ag_sales_chanal_ytd
  (
    MONTH  VARCHAR2
   ,YEAR   VARCHAR2
   ,chanal VARCHAR2
  ) RETURN NUMBER;

  /**
  * Возвращает сумму продаж для всех каналов продаж
  * кроме агентского, банковского,брокерского и call - центра
  * с накопленным итогом с начала года
  *  @autor Mirovich M.
  *  @param month - месяц
  *  @param year - год
  *  @return - сумму продаж
  */
  FUNCTION get_ag_sales_other_chanal_ytd
  (
    MONTH VARCHAR2
   ,YEAR  VARCHAR2
  ) RETURN NUMBER;

  /**
  * Возвращает сумму продаж по для групп менеджеров
  *  @autor Mirovich M.
  *  @param month - месяц
  *  @param year - год
  *  @return - сумму продаж
  */
  FUNCTION get_sales_um_groop
  (
    MONTH VARCHAR2
   ,YEAR  VARCHAR2
  ) RETURN NUMBER;

  /**
  * Возвращает сумму продаж по для групп менеджеров с накопленным итогом с начала года
  *  @autor Mirovich M.
  *  @param month - месяц
  *  @param year - год
  *  @return - сумму продаж
  */
  FUNCTION get_sales_um_groop_ytd
  (
    MONTH VARCHAR2
   ,YEAR  VARCHAR2
  ) RETURN NUMBER;

  /**
  * Вызывает создание отчета Tracking Report - 2
  *  @autor Mirovich M.
  *  @param month - месяц
  *  @param year - год
  */
  PROCEDURE create_month_tr2
  (
    tmonth VARCHAR2
   ,tyear  VARCHAR2
  );

  -------------------------------------------------------------------------------
  -------------------------------------------------------------------------------
  ------------------------- NEW and EXISTING BUSINESS REPORT
  -------------------------------------------------------------------------------
  -------------------------------------------------------------------------------
  /**
  * Возвращает таблицу с id  договоров
  * для конкретного агентства или канала продаж
   *  @autor Mirovich M.
   *  @param dep_id - ид отделения
   *  @param ch_br - канал продаж
   *  @return - количество заявлений
  */
  FUNCTION get_pol_dep_ch_id
  (
    dep_id NUMBER
   ,ch_br  VARCHAR2
  ) RETURN tbl_id
    PIPELINED;

  /**
  * Возвращает количество заявлений, зарегистрированных в указанный период
  * для конкретного агентства или канала продаж
   *  @autor Mirovich M.
   *  @param dleft - начало периода
   *  @param dright - окончание периода
   *  @param depart_id - ид отделения
   *  @param chanal - канал продаж
   *  @return - количество заявлений
  */
  FUNCTION get_notice_num
  (
    dleft     DATE
   ,dright    DATE
   ,depart_id VARCHAR2
   ,chanal    VARCHAR2
  ) RETURN NUMBER;

  /**
  * Возвращает сумму премий по завялениям, зарегистрированным в указанный период
   * для конкретного агентства или канала продаж
   *  @autor Mirovich M.
   *  @param dleft - начало периода
   *  @param dright - окончание периода
   *  @param depart_id - ид отделения
   *  @param chanal - канал продаж
   *  @return - премию по заявлениям
  */
  FUNCTION get_notice_premium
  (
    dleft     DATE
   ,dright    DATE
   ,depart_id VARCHAR2
   ,chanal    VARCHAR2
  ) RETURN NUMBER;

  /**
  * Возвращает количество полисов, ставших активными в указанный период
   * для конкретного агентства или канала продаж
   *  @autor Mirovich M.
   *  @param dleft - начало периода
   *  @param dright - окончание периода
   *  @param depart_id - ид отделения
   *  @param chanal - канал продаж
   *  @return - премию по заявлениям
  */
  FUNCTION get_pol_active_num
  (
    dleft     DATE
   ,dright    DATE
   ,depart_id VARCHAR2
   ,chanal    VARCHAR2
  ) RETURN NUMBER;

  /**
  * Возвращает сумму премий по полисам, ставшими активными в указанный период
   * для конкретного агентства или канала продаж
   *  @autor Mirovich M.
   *  @param dleft - начало периода
   *  @param dright - окончание периода
   *  @param depart_id - ид отделения
   *  @param chanal - канал продаж
   *  @return - премию по заявлениям
  */
  FUNCTION get_pol_active_premium
  (
    dleft     DATE
   ,dright    DATE
   ,depart_id VARCHAR2
   ,chanal    VARCHAR2
  ) RETURN NUMBER;

  /**
  * Возвращает количество заявлений, зарегистрированных в указанный период
  * в статусе "Проект" или "Готовится к расторжению"
  * для конкретного агентства или канала продаж
   *  @autor Mirovich M.
   *  @param dleft - начало периода
   *  @param dright - окончание периода
   *  @param depart_id - ид отделения
   *  @param chanal - канал продаж
   *  @return - количество заявлений
  */
  FUNCTION get_notice_outside_num
  (
    dleft     DATE
   ,dright    DATE
   ,depart_id VARCHAR2
   ,chanal    VARCHAR2
  ) RETURN NUMBER;

  /**
  * Возвращает сумму премий по завялениям, зарегистрированным в указанный период
  * в статусе "Проект" или "Готовится к расторжению"
   * для конкретного агентства или канала продаж
   *  @autor Mirovich M.
   *  @param dleft - начало периода
   *  @param dright - окончание периода
   *  @param depart_id - ид отделения
   *  @param chanal - канал продаж
   *  @return - премию по заявлениям
  */
  FUNCTION get_notice_outside_premium
  (
    dleft     DATE
   ,dright    DATE
   ,depart_id VARCHAR2
   ,chanal    VARCHAR2
  ) RETURN NUMBER;

  /**
  * Возвращает количество агентов, сделавших продажу в указанный период
  * для конкретного агентства или канала продаж
   *  @autor Mirovich M.
   *  @param dleft - начало периода
   *  @param dright - окончание периода
   *  @param depart_id - ид отделения
   *  @param chanal - канал продаж
   *  @return - количество заявлений
  */
  FUNCTION get_agent_have_sales_num
  (
    dleft     DATE
   ,dright    DATE
   ,depart_id VARCHAR2
   ,chanal    VARCHAR2
  ) RETURN NUMBER;

  /**
  * Возвращает количество агентов, действующих на конец периода
  * для конкретного агентства или канала продаж
   *  @autor Mirovich M.
   *  @param dright - окончание периода
   *  @param depart_id - ид отделения
   *  @param chanal - канал продаж
   *  @return - количество заявлений
  */
  FUNCTION get_total_agent_number
  (
    dright    DATE
   ,depart_id VARCHAR2
   ,chanal    VARCHAR2
  ) RETURN NUMBER;

  /**
  * Возвращает количество агентов, действующих на конец периода
  * для конкретного агентства или канала продаж
   *  @autor Mirovich M.
   *  @param dright - окончание периода
   *  @param depart_id - ид отделения
   *  @param chanal - канал продаж
   *  @return - количество заявлений
  */
  FUNCTION get_list_departments_chanals(dright DATE) RETURN tbl_ag_ch
    PIPELINED;

  /**
  * Вызывает добавление строки в таблицу rep_neb
  *  @autor Mirovich M.
  *  @param fday - дата
  *  @param fperiod - период
  *  @param fregion - регион / канал продаж
  *  @param fblock - название блока
  *  @param fparam - название параметра
  *  @param fvalue - значение параметра
  */
  PROCEDURE insert_row_to_rep_neb
  (
    fday    DATE
   ,fperiod VARCHAR2
   ,fregion VARCHAR2
   ,fblock  VARCHAR2
   ,fparam  VARCHAR2
   ,fvalue  NUMBER
  );

  /**
   * Вызывает обновление строки таблицы rep_neb
   *  @autor Mirovich M.
  *  @param fday - дата
   *  @param fperiod - период
   *  @param fregion - регион / канал продаж
   *  @param fblock - название блока
   *  @param fparam - название параметра
   *  @param fvalue - значение параметра
   */
  PROCEDURE update_row_to_rep_neb
  (
    fday    DATE
   ,fperiod VARCHAR2
   ,fregion VARCHAR2
   ,fblock  VARCHAR2
   ,fparam  VARCHAR2
   ,fvalue  NUMBER
  );

  /**
  * Вызывает формирование отчета New and Existing Business report на дату
  * обновляет строку таблицы rep_neb
  *  @autor Mirovich M.
  *  @param d - дата, на которую формируется отчет
  */

  PROCEDURE create_day_neb(dright DATE);

  PROCEDURE create_day_neb2(dright DATE);

  -------------------------------------------------------------------------------
  -------------------------------------------------------------------------------
  ------------------------- СТАТИСТИЧЕСКИЙ ОТЧЕТ ПО ВЫПЛАТАМ
  -------------------------------------------------------------------------------
  -------------------------------------------------------------------------------

  /**
  * Возвращает id претензий (c_claim_header)
  * с фильтром по названию и типу риска
  * @autor Mirovich M.
  * @param br - бриф риска
  * @param rtype - тип риска
  * @return - таблицу с id претензий
  */
  FUNCTION get_claim_header_id
  (
    br    VARCHAR2
   ,rtype VARCHAR2
  ) RETURN tbl_claim_id
    PIPELINED;

  /**
  * Возвращает количество претензий, поступивших в компанию в указанный период
  * с фильтром по названию и типу риска
  * @autor Mirovich M.
  * @param br - бриф риска
  * @param rtype - тип риска
  * @param dleft - начало периода
  * @param dright - окончание периода
  * @return - количество дел
  */
  FUNCTION get_claim_number
  (
    br     VARCHAR2
   ,rtype  VARCHAR2
   ,dleft  DATE
   ,dright DATE
  ) RETURN NUMBER;

  /**
  * Возвращает количество претензий, поступивших в компанию в указанный год
  * и оплаченных в указанный период
  * с фильтром по названию и типу риска
  * @autor Mirovich M.
  * @param br - бриф риска
  * @param rtype - тип риска
  * @param dleft - начало периода
  * @param dright - окончание периода
  * @return - количество дел
  */
  FUNCTION get_claim_pay_number
  (
    br     VARCHAR2
   ,rtype  VARCHAR2
   ,YEAR   VARCHAR2
   ,dleft  DATE
   ,dright DATE
  ) RETURN NUMBER;

  /**
  * Возвращает выплаченную сумму по претензиям , поступивших в компанию в указанный год
  * и оплаченных в указанный период
  * с фильтром по названию и типу риска
  * @autor Mirovich M.
  * @param br - бриф риска
  * @param rtype - тип риска
  * @param dleft - начало периода
  * @param dright - окончание периода
  * @return - выплаченная сумма по претензиям
  */
  FUNCTION get_claim_pay_amount
  (
    br     VARCHAR2
   ,rtype  VARCHAR2
   ,YEAR   VARCHAR2
   ,dleft  DATE
   ,dright DATE
  ) RETURN NUMBER;

  /**
  * Возвращает количество претензий, поступивших в компанию в указанный период
  * с фильтром по названию и типу риска
  * @autor Mirovich M.
  * @param br - бриф риска
  * @param rtype - тип риска
  * @param year - год
  * @return - количество дел на рассмотрении
  */
  FUNCTION get_claim_pending_number
  (
    br    VARCHAR2
   ,rtype VARCHAR2
   ,YEAR  VARCHAR2
  ) RETURN NUMBER;

  /**
  * Возвращает сумму заявленных убытков, поступивших в компанию в указанный период
  * с фильтром по названию и типу риска
  * @autor Mirovich M.
  * @param br - бриф риска
  * @param rtype - тип риска
  * @param year - год
  * @return - заявленная сумма
  */
  FUNCTION get_panding_claims_amount
  (
    br    VARCHAR2
   ,rtype VARCHAR2
   ,YEAR  VARCHAR2
  ) RETURN NUMBER;

  /**
  * Возвращает количество отказанных убытков, поступивших в компанию в указанный период
  * с фильтром по названию и типу риска
  * @autor Mirovich M.
  * @param br - бриф риска
  * @param rtype - тип риска
  * @param year - год
  * @param dleft - начало периода
  * @param dleft - окончание периода
  * @return - количество убытков, в которых отказано
  */
  FUNCTION get_rejected_claims_number
  (
    br     VARCHAR2
   ,rtype  VARCHAR2
   ,YEAR   VARCHAR2
   ,dleft  DATE
   ,dright DATE
  ) RETURN NUMBER;

  /**
  * Возвращает сумму по  убыткам, отказанным в указанный период
  * с фильтром по названию и типу риска
  * @autor Mirovich M.
  * @param br - бриф риска
  * @param rtype - тип риска
  * @param dleft - начало периода
  * @param dleft - окончание периода
  * @return - сумма по убыткам, в которых отказано
  */
  FUNCTION get_rejected_claims_amount
  (
    br     VARCHAR2
   ,rtype  VARCHAR2
   ,dleft  DATE
   ,dright DATE
  ) RETURN NUMBER;

  /**
  * Добавляем строку в таблицу ins_dwh.rep_payoff
  * @autor Mirovich M.
  * @param fyear - год
  * @param fmonth - месяц
  * @param frisk_type -  тип риска
  * @param frisk - название риска
  * @param fparam - параметр 
  * @param fvalue - значение параметра
  * @param frisk_brief - сокрашение риска
  * @param ftype_brief - сокращение типа
  */
  PROCEDURE insert_row_to_rep_payoff
  (
    fyear       VARCHAR2
   ,fmonth      VARCHAR2
   ,frisk_type  VARCHAR2
   ,frisk       VARCHAR2
   ,fparam      VARCHAR2
   ,fvalue      NUMBER
   ,frisk_brief VARCHAR2
   ,ftype_brief VARCHAR2
  );
  /**
  * Обновляет строку в таблице ins_dwh.rep_payoff
  * @autor Mirovich M.
  * @param fyear - год
  * @param fmonth - месяц
  * @param fparam - параметр 
  * @param fvalue - значение параметра
  * @param frisk_brief - сокрашение риска
  * @param ftype_brief - сокращение типа
  */
  PROCEDURE update_row_to_rep_payoff
  (
    fyear       VARCHAR2
   ,fmonth      VARCHAR2
   ,fparam      VARCHAR2
   ,fvalue      NUMBER
   ,frisk_brief VARCHAR2
   ,ftype_brief VARCHAR2
  );

  /**
  * Добавляет все строки в таблице ins_dwh.rep_payoff для одного риска
  * @autor Mirovich M.
  * @param month - месяц
  * @param year - год
  * @param frisk - название риска
  * @param frisk_br - сокращение риска
  * @param ft_gr - сокрашение типа риска
  */
  PROCEDURE insert_rep_payoff
  (
    tmonth   VARCHAR2
   ,tyear    VARCHAR2
   ,frisk    VARCHAR2
   ,frisk_br VARCHAR2
   ,ft_gr    VARCHAR2
  );

  /**
  * Обновляет все строки в таблице ins_dwh.rep_payoff для одного риска
  * @autor Mirovich M.
  * @param month - месяц
  * @param year - год
  * @param frisk_br - сокращение риска
  * @param ft_gr - сокрашение типа риска
  */
  PROCEDURE update_rep_payoff
  (
    tmonth   VARCHAR2
   ,tyear    VARCHAR2
   ,frisk_br VARCHAR2
   ,ft_gr    VARCHAR2
  );
  /**
  * Вызывает формирование отчета "Статистический отчет по выплатам"
  * заполнение таблицы ins_dwh.rep_payoff
  * @autor Mirovich M.
  * @param month- месяц
  * @param year - год
  */
  PROCEDURE create_month_payoff
  (
    tmonth VARCHAR2
   ,tyear  VARCHAR2
  );

  -------------------------------------------------------------------------------
  -------------------------------------------------------------------------------
  ------------------------- SALES REPORT (WITHOUT PROGRAMM)
  -------------------------------------------------------------------------------
  -------------------------------------------------------------------------------

  /**
  * Возвращает id контракта агента, заключившего договор
  * @autor Mirovich M.
  * @param p_pol_h_id- ид заголовка договора
  * @return  - ид агентского договора
  */
  FUNCTION get_agch_id_by_polid(p_pol_h_id NUMBER) RETURN NUMBER;
  /**
  * Возвращает id агентства, заключившего договор
  * @autor Mirovich M.
  * @param p_pol_h_id- ид заголовка договора
  * @return  - ид агентства
  */
  FUNCTION get_dep_id_by_polid(p_pol_header_id NUMBER) RETURN NUMBER;

  /**
  * Возвращает id агентства, ко которому отнеосится агент
  * @autor Mirovich M.
  * @param p_agent_id - ид агента
  * @return  - ид агентства
  */
  FUNCTION get_dep_id_by_agid(p_agent_id NUMBER) RETURN NUMBER;

  /**
  * Возвращает таблицу с информацией по договорам, заключенным в указанный период
  * с указанием агента, агентсва, канала продаж и продукта
  * @autor Mirovich M.
  * @param dleft - начало периода
  * @param dright - окончание периода
  * @return  - таблицу с договорами
  */
  FUNCTION get_tbl_ag_ch_pr
  (
    dleft  DATE
   ,dright DATE
  ) RETURN tbl_ag_ch_pr
    PIPELINED;

  /**
  * Возвращает сумму APE по заключенным договорам 
  * @autor Mirovich M.
  * @param dleft - начало периода
  * @param dright - окончание периода
  * @param ag_id - id агента
  * @param dep_id - id агентсва 
  * @param ch_br - сокращение канала продаж
  * @param pr_br - сокращение продукта
  * @return  - сумму APE
  */
  FUNCTION get_ape_policy
  (
    dleft  DATE
   ,dright DATE
   ,ag_id  NUMBER
   ,dep_id NUMBER
   ,ch_br  VARCHAR2
   ,pr_br  VARCHAR2
  ) RETURN NUMBER;
  /**
  * Возвращает сумму APE по расторгнутым договорам 
  * @autor Mirovich M.
  * @param dleft - начало периода
  * @param dright - окончание периода
  * @param ag_id - id агента
  * @param dep_id - id агентсва 
  * @param ch_br - сокращение канала продаж
  * @param pr_br - сокращение продукта
  * @return  - сумму APE
  */
  FUNCTION get_ape_pol_dec
  (
    dleft  DATE
   ,dright DATE
   ,ag_id  NUMBER
   ,dep_id NUMBER
   ,ch_br  VARCHAR2
   ,pr_br  VARCHAR2
  ) RETURN NUMBER;

  /**
  * Возвращает сумму APE по расторгнутым договорам по иной причине
  * @autor Mirovich M.
  * @param dleft - начало периода
  * @param dright - окончание периода
  * @param ag_id - id агента
  * @param dep_id - id агентсва 
  * @param ch_br - сокращение канала продаж
  * @param pr_br - сокращение продукта
  * @return  - сумму APE
  */
  FUNCTION get_ape_pol_dec_oth
  (
    dleft  DATE
   ,dright DATE
   ,ag_id  NUMBER
   ,dep_id NUMBER
   ,ch_br  VARCHAR2
   ,pr_br  VARCHAR2
  ) RETURN NUMBER;

  /**
  * Возвращает сумму APE по активным договорам 
  * @autor Mirovich M.
  * @param dleft - начало периода
  * @param dright - окончание периода
  * @param ag_id - id агента
  * @param dep_id - id агентсва 
  * @param ch_br - сокращение канала продаж
  * @param pr_br - сокращение продукта
  * @return  - сумму APE
  */
  FUNCTION get_ape_pol_act
  (
    dleft  DATE
   ,dright DATE
   ,ag_id  NUMBER
   ,dep_id NUMBER
   ,ch_br  VARCHAR2
   ,pr_br  VARCHAR2
  ) RETURN NUMBER;

  /**
  * Возвращает сумму сумму оплаченной премии по заключенным договорам
  * @autor Mirovich M.
  * @param dleft - начало периода
  * @param dright - окончание периода
  * @param ag_id - id агента
  * @param dep_id - id агентсва 
  * @param ch_br - сокращение канала продаж
  * @param pr_br - сокращение продукта
  * @return  - сумму оплаченной премии
  */
  FUNCTION get_pol_pay_amount
  (
    dleft  DATE
   ,dright DATE
   ,ag_id  NUMBER
   ,dep_id NUMBER
   ,ch_br  VARCHAR2
   ,pr_br  VARCHAR2
  ) RETURN NUMBER;

  /**
  * Возвращает сумму сумму оплаченной премии по активным договорам
  * @autor Mirovich M.
  * @param dleft - начало периода
  * @param dright - окончание периода
  * @param ag_id - id агента
  * @param dep_id - id агентсва 
  * @param ch_br - сокращение канала продаж
  * @param pr_br - сокращение продукта
  * @return  - сумму оплаченной премии
  */
  FUNCTION get_pol_pay_amount_act
  (
    dleft  DATE
   ,dright DATE
   ,ag_id  NUMBER
   ,dep_id NUMBER
   ,ch_br  VARCHAR2
   ,pr_br  VARCHAR2
  ) RETURN NUMBER;
  /**
  * Возвращает сумму сумму возврата по расторгнутым договорам
  * @autor Mirovich M.
  * @param dleft - начало периода
  * @param dright - окончание периода
  * @param ag_id - id агента
  * @param dep_id - id агентсва 
  * @param ch_br - сокращение канала продаж
  * @param pr_br - сокращение продукта
  * @return  - сумму возврата
  */
  FUNCTION get_pol_dec_amount
  (
    dleft  DATE
   ,dright DATE
   ,ag_id  NUMBER
   ,dep_id NUMBER
   ,ch_br  VARCHAR2
   ,pr_br  VARCHAR2
  ) RETURN NUMBER;

  /**
  * Возвращает сумму сумму возврата по расторгнутым договорам по иным причинам
  * @autor Mirovich M.
  * @param dleft - начало периода
  * @param dright - окончание периода
  * @param ag_id - id агента
  * @param dep_id - id агентсва 
  * @param ch_br - сокращение канала продаж
  * @param pr_br - сокращение продукта
  * @return  - сумму возврата
  */
  FUNCTION get_pol_dec_amount_oth
  (
    dleft  DATE
   ,dright DATE
   ,ag_id  NUMBER
   ,dep_id NUMBER
   ,ch_br  VARCHAR2
   ,pr_br  VARCHAR2
  ) RETURN NUMBER;

  /**
  * Заполняет таблицу соответствий "id полиса - id агента"
  * @autor Mirovich M.
  * @param dleft - начало периода
  * @param dright - окончание периода
  */
  PROCEDURE fill_tbl_pol_ag
  (
    dleft  DATE
   ,dright DATE
  );

  /**
  * Возвращает таблицу с договорами, заключенным в период
  * @autor Mirovich M.
  * @param dleft - начало периода
  * @param dright - окончание периода
  * @param ag_id - id агента
  * @param dep_id - id агентсва 
  * @param ch_br - сокращение канала продаж
  * @param pr_br - сокращение продукта
  * @return  - таблицу с id договоров
  */

  FUNCTION get_policy_id
  (
    dleft  DATE
   ,dright DATE
   ,ag_id  NUMBER
   ,dep_id NUMBER
   ,ch_br  VARCHAR2
   ,pr_br  VARCHAR2
  ) RETURN tbl_id
    PIPELINED;

  /**
  * Возвращает таблицу с договорами, заключенным и действующих в период
  * @autor Mirovich M.
  * @param dleft - начало периода
  * @param dright - окончание периода
  * @return  - таблицу с id договоров
  */
  FUNCTION get_pol_active_id
  (
    dleft  DATE
   ,dright DATE
   ,ag_id  NUMBER
   ,dep_id NUMBER
   ,ch_br  VARCHAR2
   ,pr_br  VARCHAR2
  ) RETURN tbl_id
    PIPELINED;

  /**
  * Возвращает id договоров, заключенных  и расторгнутым в указанный период
  * по результатам андерреайтинга или заявлению страхователя
  * @autor Mirovich M.
  * @param dleft - начало периода
  * @param dright - окончание периода
  * @return  - таблицу с id договоров
  */
  FUNCTION get_pol_dec_anderr_id
  (
    dleft  DATE
   ,dright DATE
   ,ag_id  NUMBER
   ,dep_id NUMBER
   ,ch_br  VARCHAR2
   ,pr_br  VARCHAR2
  ) RETURN tbl_id
    PIPELINED;

  /**
  * Возвращает id договоров, заключенных  и расторгнутым в указанный период
  * по иным причинам
  * @autor Mirovich M.
  * @param dleft - начало периода
  * @param dright - окончание периода
  * @return  - таблицу с id договоров
  */
  FUNCTION get_pol_dec_other_id
  (
    dleft  DATE
   ,dright DATE
   ,ag_id  NUMBER
   ,dep_id NUMBER
   ,ch_br  VARCHAR2
   ,pr_br  VARCHAR2
  ) RETURN tbl_id
    PIPELINED;

  /** Добавляет строку в таблицу ins_dwh.rep_sr_wo_prog
  * @autor Mirovich M.
  * @param fchanal - канал продаж
  * @param fdep - агентство
  * @param fagent - агент
  * @param fprod - продукт
  * @param fparam - параметр
  * @param fvalue - значение параметра
  */
  PROCEDURE insert_row_to_sr_wo
  (
    fchanal VARCHAR2
   ,fdep    VARCHAR2
   ,fagent  VARCHAR2
   ,fprod   VARCHAR2
   ,fparam  VARCHAR2
   ,fvalue  NUMBER
  );

  /**
  * Функция вызывает создание отчета Sales Report с детализацией до продукта
  * заполнение таблицы ins_dwh.rep_sr_wo_prog
  * @autor Mirovich M.
  * @param dleft - начало периода
  * @param dright - окончание периода
  */
  PROCEDURE create_period_sr_wo
  (
    dleft  DATE
   ,dright DATE
  );

  -------------------------------------------------------------------------------
  -------------------------------------------------------------------------------
  ------------------------- SALES REPORT (WITH PROGRAMM)
  -------------------------------------------------------------------------------
  -------------------------------------------------------------------------------

  /**
  * Возвращает таблицу с информацией по договорам, заключенным в указанный период
  * с указанием агента, агентсва, канала продаж и программы
  * @autor Mirovich M.
  * @param dleft - начало периода
  * @param dright - окончание периода
  * @return  - таблицу с договорами
  */
  FUNCTION get_tbl_ag_ch_progr
  (
    dleft  DATE
   ,dright DATE
  ) RETURN tbl_ag_ch_pr
    PIPELINED;

  /**
  * Возвращает сумму APE по заключенным договорам 
  * @autor Mirovich M.
  * @param dleft - начало периода
  * @param dright - окончание периода
  * @param ag_id - id агента
  * @param dep_id - id агентсва 
  * @param ch_br - сокращение канала продаж
  * @param pr_br - сокращение программы
  * @return  - сумму APE
  */
  FUNCTION get_ape_policy_pr
  (
    dleft  DATE
   ,dright DATE
   ,ag_id  NUMBER
   ,dep_id NUMBER
   ,ch_br  VARCHAR2
   ,pr_br  VARCHAR2
  ) RETURN NUMBER;
  /**
  * Возвращает сумму APE по расторгнутым договорам 
  * @autor Mirovich M.
  * @param dleft - начало периода
  * @param dright - окончание периода
  * @param ag_id - id агента
  * @param dep_id - id агентсва 
  * @param ch_br - сокращение канала продаж
  * @param pr_br - сокращение программы
  * @return  - сумму APE
  */
  FUNCTION get_ape_pol_dec_pr
  (
    dleft  DATE
   ,dright DATE
   ,ag_id  NUMBER
   ,dep_id NUMBER
   ,ch_br  VARCHAR2
   ,pr_br  VARCHAR2
  ) RETURN NUMBER;

  /**
  * Возвращает сумму APE по расторгнутым договорам по иной причине
  * @autor Mirovich M.
  * @param dleft - начало периода
  * @param dright - окончание периода
  * @param ag_id - id агента
  * @param dep_id - id агентсва 
  * @param ch_br - сокращение канала продаж
  * @param pr_br - сокращение программы
  * @return  - сумму APE
  */
  FUNCTION get_ape_pol_dec_oth_pr
  (
    dleft  DATE
   ,dright DATE
   ,ag_id  NUMBER
   ,dep_id NUMBER
   ,ch_br  VARCHAR2
   ,pr_br  VARCHAR2
  ) RETURN NUMBER;

  /**
  * Возвращает сумму APE по активным договорам 
  * @autor Mirovich M.
  * @param dleft - начало периода
  * @param dright - окончание периода
  * @param ag_id - id агента
  * @param dep_id - id агентсва 
  * @param ch_br - сокращение канала продаж
  * @param pr_br - сокращение программы
  * @return  - сумму APE
  */
  FUNCTION get_ape_pol_act_pr
  (
    dleft  DATE
   ,dright DATE
   ,ag_id  NUMBER
   ,dep_id NUMBER
   ,ch_br  VARCHAR2
   ,pr_br  VARCHAR2
  ) RETURN NUMBER;

  /**
  * Возвращает сумму сумму оплаченной премии по заключенным договорам
  * @autor Mirovich M.
  * @param dleft - начало периода
  * @param dright - окончание периода
  * @param ag_id - id агента
  * @param dep_id - id агентсва 
  * @param ch_br - сокращение канала продаж
  * @param pr_br - сокращение программы
  * @return  - сумму оплаченной премии
  */
  FUNCTION get_pol_pay_amount_pr
  (
    dleft  DATE
   ,dright DATE
   ,ag_id  NUMBER
   ,dep_id NUMBER
   ,ch_br  VARCHAR2
   ,pr_br  VARCHAR2
  ) RETURN NUMBER;

  /**
  * Возвращает сумму сумму оплаченной премии по активным договорам
  * @autor Mirovich M.
  * @param dleft - начало периода
  * @param dright - окончание периода
  * @param ag_id - id агента
  * @param dep_id - id агентсва 
  * @param ch_br - сокращение канала продаж
  * @param pr_br - сокращение программы
  * @return  - сумму оплаченной премии
  */
  FUNCTION get_pol_pay_amount_act_pr
  (
    dleft  DATE
   ,dright DATE
   ,ag_id  NUMBER
   ,dep_id NUMBER
   ,ch_br  VARCHAR2
   ,pr_br  VARCHAR2
  ) RETURN NUMBER;
  /**
  * Возвращает сумму сумму возврата по расторгнутым договорам
  * @autor Mirovich M.
  * @param dleft - начало периода
  * @param dright - окончание периода
  * @param ag_id - id агента
  * @param dep_id - id агентсва 
  * @param ch_br - сокращение канала продаж
  * @param pr_br - сокращение программы
  * @return  - сумму возврата
  */
  FUNCTION get_pol_dec_amount_pr
  (
    dleft  DATE
   ,dright DATE
   ,ag_id  NUMBER
   ,dep_id NUMBER
   ,ch_br  VARCHAR2
   ,pr_br  VARCHAR2
  ) RETURN NUMBER;

  /**
  * Возвращает сумму сумму возврата по расторгнутым договорам по иным причинам
  * @autor Mirovich M.
  * @param dleft - начало периода
  * @param dright - окончание периода
  * @param ag_id - id агента
  * @param dep_id - id агентсва 
  * @param ch_br - сокращение канала продаж
  * @param pr_br - сокращение программы
  * @return  - сумму возврата
  */
  FUNCTION get_pol_dec_amount_oth_pr
  (
    dleft  DATE
   ,dright DATE
   ,ag_id  NUMBER
   ,dep_id NUMBER
   ,ch_br  VARCHAR2
   ,pr_br  VARCHAR2
  ) RETURN NUMBER;

  /**
  * Возвращает таблицу с договорами, заключенными в период
  * @autor Mirovich M.
  * @param dleft - начало периода
  * @param dright - окончание периода
  * @param ag_id - id агента
  * @param dep_id - id агентсва 
  * @param ch_br - сокращение канала продаж
  * @param pr_br - сокращение программы
  * @return  - таблицу с id договоров
  */

  FUNCTION get_policy_id_pr
  (
    dleft  DATE
   ,dright DATE
   ,ag_id  NUMBER
   ,dep_id NUMBER
   ,ch_br  VARCHAR2
   ,pr_br  VARCHAR2
  ) RETURN tbl_id
    PIPELINED;

  /**
  * Возвращает таблицу с договорами, заключенным и действующих в период
  * @autor Mirovich M.
  * @param dleft - начало периода
  * @param dright - окончание периода
  * @param ag_id - id агента
  * @param dep_id - id агентсва 
  * @param ch_br - сокращение канала продаж
  * @param pr_br - сокращение программы
  * @return  - таблицу с id договоров
  */
  FUNCTION get_pol_active_id_pr
  (
    dleft  DATE
   ,dright DATE
   ,ag_id  NUMBER
   ,dep_id NUMBER
   ,ch_br  VARCHAR2
   ,pr_br  VARCHAR2
  ) RETURN tbl_id
    PIPELINED;

  /**
  * Возвращает id договоров, заключенных  и расторгнутым в указанный период
  * по результатам андерреайтинга или заявлению страхователя
  * @autor Mirovich M.
  * @param dleft - начало периода
  * @param dright - окончание периода
  * @param ag_id - id агента
  * @param dep_id - id агентсва 
  * @param ch_br - сокращение канала продаж
  * @param pr_br - сокращение программы
  * @return  - таблицу с id договоров
  */
  FUNCTION get_pol_dec_anderr_id_pr
  (
    dleft  DATE
   ,dright DATE
   ,ag_id  NUMBER
   ,dep_id NUMBER
   ,ch_br  VARCHAR2
   ,pr_br  VARCHAR2
  ) RETURN tbl_id
    PIPELINED;

  /**
  * Возвращает id договоров, заключенных  и расторгнутым в указанный период
  * по иным причинам
  * @autor Mirovich M.
  * @param dleft - начало периода
  * @param dright - окончание периода
  * @param ag_id - id агента
  * @param dep_id - id агентсва 
  * @param ch_br - сокращение канала продаж
  * @param pr_br - сокращение программы
  * @return  - таблицу с id договоров
  */
  FUNCTION get_pol_dec_other_id_pr
  (
    dleft  DATE
   ,dright DATE
   ,ag_id  NUMBER
   ,dep_id NUMBER
   ,ch_br  VARCHAR2
   ,pr_br  VARCHAR2
  ) RETURN tbl_id
    PIPELINED;

  /** Добавляет строку в таблицу ins_dwh.rep_sr_prog
  * @autor Mirovich M.
  * @param fchanal - канал продаж
  * @param fdep - агентство
  * @param fagent - агент
  * @param fprog - программа
  * @param fparam - параметр
  * @param fvalue - значение параметра
  */
  PROCEDURE insert_row_to_sr_prog
  (
    fchanal VARCHAR2
   ,fdep    VARCHAR2
   ,fagent  VARCHAR2
   ,fprog   VARCHAR2
   ,fparam  VARCHAR2
   ,fvalue  NUMBER
  );

  /**
  * Функция вызывает создание отчета Sales Report с детализацией до программы
  * заполнение таблицы ins_dwh.rep_sr_prog
  * @autor Mirovich M.
  * @param dleft - начало периода
  * @param dright - окончание периода
  */
  PROCEDURE create_period_sr_prog
  (
    dleft  DATE
   ,dright DATE
  );

  /*
  \** Для отчет NewBusines EndOfMonth
  *\
  procedure create_endmonth (dleft date, dright date);
  
  \** Для отчет NewBusines NextMonth
  *\
  procedure create_nextmonth (dleft date, dright date);
  
  \** Для отчет NewBusines CurrentMonth
  *\
  procedure create_currentmonth (dleft date, dright date);
  */

  /**
  * Процедура вызывает создание отчета Sales Report
  * @autor Mirovich M.
  * @param dleft - начало периода
  * @param dright - окончание периода
  */
  PROCEDURE create_period_sales_report
  (
    dleft  DATE
   ,dright DATE
  );

  -------------------------------------------------------------------------------
  -------------------------------------------------------------------------------
  ------------------------- ВЫЗОВЫ ПРОЦЕДУР
  -------------------------------------------------------------------------------
  -------------------------------------------------------------------------------
  /**
  * Функция вызывает создание отчета Tracking Report-1 и отслеживает ошибки
  * @autor Mirovich M.
  * @param p_work_date - дата отчета
  * @param p_error_msg - сообщение о ошибке
  * @return - признак ошибки
  */
  FUNCTION f_rep_tr_1
  (
    p_work_date IN DATE
   ,p_error_msg OUT VARCHAR2
  ) RETURN NUMBER;

  /**
  * Функция вызывает создание отчета Tracking Report-2 и отслеживает ошибки
  * @autor Mirovich M.
  * @param p_work_date - дата отчета
  * @param p_error_msg - сообщение о ошибке
  * @return - признак ошибки
  */
  FUNCTION f_rep_tr_2
  (
    p_work_date IN DATE
   ,p_error_msg OUT VARCHAR2
  ) RETURN NUMBER;
  /**
  * Функция вызывает создание отчета New and Exsisting Business Report и отслеживает ошибки
  * @autor Mirovich M.
  * @param p_work_date - дата отчета
  * @param p_error_msg - сообщение о ошибке
  * @return - признак ошибки
  */
  FUNCTION f_rep_neb
  (
    p_work_date IN DATE
   ,p_error_msg OUT VARCHAR2
  ) RETURN NUMBER;

  /**
  * Функция вызывает создание отчета Статистический отчет по выплатам и отслеживает ошибки
  * @autor Mirovich M.
  * @param p_work_date - дата отчета
  * @param p_error_msg - сообщение о ошибке
  * @return - признак ошибки
  */
  FUNCTION f_rep_payoff
  (
    p_work_date IN DATE
   ,p_error_msg OUT VARCHAR2
  ) RETURN NUMBER;

END;
/
CREATE OR REPLACE PACKAGE BODY pkg_rep_utils_ins11 IS

  -- Private type declarations

  -- Private constant declarations

  -- Private variable declarations

  -- Function and procedure implementations

  -- ************************************************************************
  --///////////////////////// ОБЩИЕ ФУНКЦИИ///////////////////////////////
  -- ************************************************************************

  FUNCTION get_pol_agency_name(p_dep_id NUMBER) RETURN VARCHAR2 IS
    v_agency_name VARCHAR2(1000);
    temp_dep      VARCHAR2(1000);
    temp_agency   VARCHAR2(1000);
  BEGIN
    SELECT ot.NAME
          ,d.NAME
      INTO temp_agency
          ,temp_dep
      FROM ins.ven_department        d
          ,ins.ven_organisation_tree ot
     WHERE d.department_id = p_dep_id
       AND ot.ORGANISATION_TREE_ID = d.ORG_TREE_ID;
    IF temp_agency = temp_dep
    THEN
      v_agency_name := temp_dep;
    ELSE
      v_agency_name := temp_agency || ' - ' || temp_dep;
    END IF;
    RETURN v_agency_name;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN NULL;
  END;

  -- ************************************************************************
  --/////////////////////////TRACKING REPORT 1///////////////////////////////
  -- ************************************************************************
  -- Возвращает дату окончания агентского договора
  FUNCTION get_ag_contract_end_date(ag_id NUMBER) RETURN DATE IS
    DATA DATE;
  BEGIN
    SELECT MAX(ds.start_date)
      INTO DATA
      FROM ins.ven_doc_status     ds
          ,ins.ven_doc_status_ref dsr
     WHERE dsr.doc_status_ref_id = ds.doc_status_ref_id
       AND ds.document_id = ag_id
       AND dsr.brief IN ('BREAK', 'CLOSE', 'CANCEL', 'STOPED');
  
    RETURN(DATA);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  -- Возвращает количество агентов, нанятых в указанный месяц и год
  FUNCTION get_agent_number
  (
    MONTH VARCHAR2
   ,YEAR  VARCHAR2
  ) RETURN NUMBER IS
    COL NUMBER;
  BEGIN
    SELECT COUNT(agch.agent_id)
      INTO COL
      FROM ins.ven_ag_contract_header agch
     WHERE TO_CHAR(agch.date_begin, 'yyyy') = TO_CHAR(TO_DATE(YEAR, 'yyyy'), 'yyyy')
       AND TO_CHAR(agch.date_begin, 'mm') = TO_CHAR(TO_DATE(MONTH, 'mm'), 'mm');
    RETURN(COL);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
  END;
  --/*
  -- Возвращает количество агентов, нанятых в указанный месяц и год
  -- с фильтром по статусу и категории агента
  FUNCTION get_agent_number
  (
    MONTH VARCHAR2
   ,YEAR  VARCHAR2
   ,st    VARCHAR2
   ,cat   VARCHAR2
  ) RETURN NUMBER IS
    COL NUMBER;
  BEGIN
    SELECT COUNT(agch.agent_id)
      INTO COL
      FROM ins.ven_ag_contract_header agch
      JOIN (SELECT * FROM TABLE(pkg_rep_utils_ins11.get_ag_contract_id(st, cat))) agch_id
        ON agch.ag_contract_header_id = agch_id.COLUMN_VALUE
     WHERE TO_CHAR(agch.date_begin, 'yyyy') = TO_CHAR(TO_DATE(YEAR, 'yyyy'), 'yyyy')
       AND TO_CHAR(agch.date_begin, 'mm') = TO_CHAR(TO_DATE(MONTH, 'mm'), 'mm');
    RETURN(COL);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
  END;

  --*/
  -- Возвращает количество агентов, нанятых в месяце month_start и уволенных до месяца month_end
  FUNCTION get_agent_drop_number
  (
    month_start VARCHAR2
   ,month_end   VARCHAR2
   ,YEAR        VARCHAR2
  ) RETURN NUMBER IS
    COL NUMBER;
  BEGIN
    SELECT COUNT(agch.agent_id)
      INTO COL
      FROM ins.ven_ag_contract_header agch
      JOIN ins.ven_ag_contract agc
        ON agc.ag_contract_id = agch.last_ver_id
     WHERE TO_CHAR(agch.date_begin, 'yyyy') = TO_CHAR(TO_DATE(YEAR, 'yyyy'), 'yyyy')
       AND TO_CHAR(agch.date_begin, 'mm') = TO_CHAR(TO_DATE(month_start, 'mm'), 'mm')
       AND TO_CHAR(get_ag_contract_end_date(agc.ag_contract_id), 'mm') <
           TO_CHAR(TO_DATE(month_end, 'mm'), 'mm')
       AND TO_CHAR(get_ag_contract_end_date(agc.ag_contract_id), 'yyyy') =
           TO_CHAR(TO_DATE(YEAR, 'yyyy'), 'yyyy');
    RETURN(COL);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
  END;

  -- Возвращает количество агентов, нанятых в месяце month_start и уволенных до месяца month_end
  -- с фильтром по статусу и категории агента
  FUNCTION get_agent_drop_number
  (
    month_start VARCHAR2
   ,month_end   VARCHAR2
   ,YEAR        VARCHAR2
   ,st          VARCHAR2
   ,cat         VARCHAR2
  ) RETURN NUMBER IS
    COL NUMBER;
  BEGIN
    SELECT COUNT(agch.agent_id)
      INTO COL
      FROM ins.ven_ag_contract_header agch
      JOIN ins.ven_ag_contract agc
        ON agc.ag_contract_id = agch.last_ver_id
      JOIN (SELECT * FROM TABLE(pkg_rep_utils_ins11.get_ag_contract_id(st, cat))) agch_id
        ON agch.ag_contract_header_id = agch_id.COLUMN_VALUE
     WHERE TO_CHAR(agch.date_begin, 'yyyy') = TO_CHAR(TO_DATE(YEAR, 'yyyy'), 'yyyy')
       AND TO_CHAR(agch.date_begin, 'mm') = TO_CHAR(TO_DATE(month_start, 'mm'), 'mm')
       AND TO_CHAR(get_ag_contract_end_date(agc.ag_contract_id), 'mm') <
           TO_CHAR(TO_DATE(month_end, 'mm'), 'mm')
       AND TO_CHAR(get_ag_contract_end_date(agc.ag_contract_id), 'yyyy') =
           TO_CHAR(TO_DATE(YEAR, 'yyyy'), 'yyyy');
    RETURN(COL);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
  END;

  -- Возвращает количество агентов, принятых в месяце month_start
  -- и оставшихся работать вплоть до месяца month_end
  FUNCTION get_agent_active
  (
    month_start VARCHAR2
   ,month_end   VARCHAR2
   ,YEAR        VARCHAR2
  ) RETURN NUMBER IS
    COL         NUMBER;
    ag_col      NUMBER; -- количество принятых агентов
    ag_drop_col NUMBER; -- количество уволенных агентов
  BEGIN
    IF month_start IS NOT NULL
    THEN
      ag_col      := (NVL(get_agent_number(TO_CHAR(TO_DATE(month_start, 'mm'), 'mm')
                                          ,TO_CHAR(TO_DATE(YEAR, 'yyyy'), 'yyyy'))
                         ,0));
      ag_drop_col := NVL(get_agent_drop_number(TO_CHAR(TO_DATE(month_start, 'mm'), 'mm')
                                              ,TO_CHAR(TO_DATE(month_end, 'mm'), 'mm')
                                              ,TO_CHAR(TO_DATE(YEAR, 'yyyy'), 'yyyy'))
                        ,0);
      COL         := ag_col - ag_drop_col;
    ELSE
      COL := NULL;
    END IF;
    RETURN(COL);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  -- Возвращает количество агентов, принятых в месяце month_start
  -- и оставшихся работать вплоть до месяца month_end
  -- с фильтром по статусу и категории
  FUNCTION get_agent_active
  (
    month_start VARCHAR2
   ,month_end   VARCHAR2
   ,YEAR        VARCHAR2
   ,st          VARCHAR2
   ,cat         VARCHAR2
  ) RETURN NUMBER IS
    COL         NUMBER;
    ag_col      NUMBER; -- количество принятых агентов
    ag_drop_col NUMBER; -- количество уволенных агентов
  BEGIN
    IF month_start IS NOT NULL
    THEN
      ag_col      := (NVL(get_agent_number(TO_CHAR(TO_DATE(month_start, 'mm'), 'mm')
                                          ,TO_CHAR(TO_DATE(YEAR, 'yyyy'), 'yyyy')
                                          ,st
                                          ,cat)
                         ,0));
      ag_drop_col := NVL(get_agent_drop_number(TO_CHAR(TO_DATE(month_start, 'mm'), 'mm')
                                              ,TO_CHAR(TO_DATE(month_end, 'mm'), 'mm')
                                              ,TO_CHAR(TO_DATE(YEAR, 'yyyy'), 'yyyy')
                                              ,st
                                              ,cat)
                        ,0);
      COL         := ag_col - ag_drop_col;
    ELSE
      COL := NULL;
    END IF;
    RETURN(COL);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  -- Возвращает сумму продаж по агентам, принятых в месяце month_start
  -- и оставшихся работать вплоть до месяца month_end
  FUNCTION get_agent_sales
  (
    month_start VARCHAR2
   ,month_end   VARCHAR2
   ,YEAR        VARCHAR2
  ) RETURN NUMBER IS
    SALES NUMBER(11, 2); -- сумма продаж
    str   STRING(10);
    d     DATE;
  BEGIN
    str := '01.' || month_end || '.' || YEAR;
    d   := TO_DATE(str, 'dd.mm.yyyy');
    IF month_start IS NOT NULL
    THEN
      SELECT NVL(SUM(ppag.part_agent / 100 * pp.premium *
                     ins.acc_new.Get_Cross_Rate_By_Id((SELECT t.rate_type_id
                                                        FROM ins.ven_rate_type t
                                                       WHERE t.brief = 'ЦБ')
                                                     ,pph.fund_id
                                                     ,(SELECT f.fund_id
                                                        FROM ins.ven_fund f
                                                       WHERE f.brief = 'RUR')
                                                     ,pp.notice_date))
                ,0)
        INTO SALES
        FROM ins.ven_ag_contract_header agch
        JOIN ins.ven_ag_contract agc
          ON agc.ag_contract_id = agch.last_ver_id
        LEFT JOIN ins.ven_p_policy_agent ppag
          ON ppag.ag_contract_header_id = agch.ag_contract_header_id
        LEFT JOIN ins.ven_p_pol_header pph
          ON pph.policy_header_id = ppag.policy_header_id
        LEFT JOIN ins.ven_p_policy pp
          ON pp.pol_header_id = pph.policy_header_id
         AND pp.version_num = 1
         AND TO_CHAR(pp.notice_date, 'mm') = TO_CHAR(TO_DATE(month_end, 'mm'), 'mm')
         AND TO_CHAR(pp.notice_date, 'yyyy') = TO_CHAR(TO_DATE(YEAR, 'yyyy'), 'yyyy')
       WHERE TO_CHAR(agch.date_begin, 'yyyy') = TO_CHAR(TO_DATE(YEAR, 'yyyy'), 'yyyy')
         AND TO_CHAR(agch.date_begin, 'mm') = TO_CHAR(TO_DATE(month_start, 'mm'), 'mm')
         AND NVL(get_ag_contract_end_date(agc.ag_contract_id), LAST_DAY(d) + 1) > LAST_DAY(d);
      --or get_ag_contract_end_date(agc.ag_contract_id) is null);
    ELSE
      SALES := NULL;
    END IF;
    RETURN(TO_CHAR(SALES, '999999999D99'));
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  -- Возвращает сумму продаж по агентам, принятых в месяце month_start
  -- и оставшихся работать вплоть до месяца month_end
  -- с фильтром по статусу и категории агента
  FUNCTION get_agent_sales
  (
    month_start VARCHAR2
   ,month_end   VARCHAR2
   ,YEAR        VARCHAR2
   ,st          VARCHAR2
   ,cat         VARCHAR2
  ) RETURN NUMBER IS
    SALES NUMBER(11, 2); -- сумма продаж
    str   STRING(10);
    d     DATE;
  BEGIN
    str := '01.' || month_end || '.' || YEAR;
    d   := TO_DATE(str, 'dd.mm.yyyy');
    IF month_start IS NOT NULL
    THEN
      SELECT NVL(SUM(ppag.part_agent / 100 * pp.premium *
                     ins.acc_new.Get_Cross_Rate_By_Id((SELECT t.rate_type_id
                                                        FROM ins.ven_rate_type t
                                                       WHERE t.brief = 'ЦБ')
                                                     ,pph.fund_id
                                                     ,(SELECT f.fund_id
                                                        FROM ins.ven_fund f
                                                       WHERE f.brief = 'RUR')
                                                     ,pp.notice_date))
                ,0)
        INTO SALES
        FROM ins.ven_ag_contract_header agch
        JOIN ins.ven_ag_contract agc
          ON agc.ag_contract_id = agch.last_ver_id
        JOIN (SELECT * FROM TABLE(pkg_rep_utils_ins11.get_ag_contract_id(st, cat))) agch_id
          ON agch.ag_contract_header_id = agch_id.COLUMN_VALUE
        LEFT JOIN ins.ven_p_policy_agent ppag
          ON ppag.ag_contract_header_id = agch.ag_contract_header_id
        LEFT JOIN ins.ven_p_pol_header pph
          ON pph.policy_header_id = ppag.policy_header_id
        LEFT JOIN ins.ven_p_policy pp
          ON pp.pol_header_id = pph.policy_header_id
         AND pp.version_num = 1
         AND TO_CHAR(pp.notice_date, 'mm') = TO_CHAR(TO_DATE(month_end, 'mm'), 'mm')
         AND TO_CHAR(pp.notice_date, 'yyyy') = TO_CHAR(TO_DATE(YEAR, 'yyyy'), 'yyyy')
       WHERE TO_CHAR(agch.date_begin, 'yyyy') = TO_CHAR(TO_DATE(YEAR, 'yyyy'), 'yyyy')
         AND TO_CHAR(agch.date_begin, 'mm') = TO_CHAR(TO_DATE(month_start, 'mm'), 'mm')
         AND NVL(get_ag_contract_end_date(agc.ag_contract_id), LAST_DAY(d) + 1) > LAST_DAY(d);
      --or get_ag_contract_end_date(agc.ag_contract_id) is null);
    ELSE
      SALES := NULL;
    END IF;
    RETURN(TO_CHAR(SALES, '999999999D99'));
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  -- Возвращает сумму бонусов по агентам, принятых в месяце month_start
  -- и оставшихся работать вплоть до месяца month_end
  FUNCTION get_agent_bonus
  (
    month_start VARCHAR2
   ,month_end   VARCHAR2
   ,YEAR        VARCHAR2
  ) RETURN NUMBER IS
    bonus NUMBER(11, 2); -- ДАВ
    str   STRING(10);
    d     DATE;
  BEGIN
    str := '01.' || month_end || '.' || YEAR;
    d   := TO_DATE(str, 'dd.mm.yyyy');
    IF month_start IS NOT NULL
    THEN
      SELECT NVL(SUM(agrd.comission_sum), 0)
        INTO bonus
        FROM ins.ven_ag_contract_header agch
        JOIN ins.ven_ag_contract agc
          ON agc.ag_contract_id = agch.last_ver_id
        JOIN ins.ven_agent_report agp
          ON agp.ag_contract_h_id = agch.ag_contract_header_id
        JOIN ins.ven_ag_vedom_av agv
          ON agv.ag_vedom_av_id = agp.ag_vedom_av_id
         AND TO_CHAR(agv.date_begin, 'mm') = TO_CHAR(TO_DATE(month_end, 'mm'), 'mm')
         AND TO_CHAR(agv.date_begin, 'yyyy') = TO_CHAR(TO_DATE(YEAR, 'yyyy'), 'yyyy')
        JOIN ins.ven_t_ag_av tagv
          ON agv.t_ag_av_id = tagv.t_ag_av_id
         AND tagv.brief = 'ДАВ'
        JOIN ins.ven_agent_report_dav agrd
          ON agp.agent_report_id = agrd.agent_report_id
       WHERE TO_CHAR(agch.date_begin, 'yyyy') = TO_CHAR(TO_DATE(YEAR, 'yyyy'), 'yyyy')
         AND TO_CHAR(agch.date_begin, 'mm') = TO_CHAR(TO_DATE(month_start, 'mm'), 'mm')
         AND NVL(get_ag_contract_end_date(agc.ag_contract_id), LAST_DAY(d) + 1) > LAST_DAY(d);
      --or get_ag_contract_end_date(agc.ag_contract_id) is null);
    ELSE
      bonus := NULL;
    END IF;
    RETURN(TO_CHAR(bonus, '999999999D99'));
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  -- Возвращает сумму бонусов по агентам, принятых в месяце month_start
  -- и оставшихся работать вплоть до месяца month_end
  -- с фильтром по статусу и категории агента
  FUNCTION get_agent_bonus
  (
    month_start VARCHAR2
   ,month_end   VARCHAR2
   ,YEAR        VARCHAR2
   ,st          VARCHAR2
   ,cat         VARCHAR2
  ) RETURN NUMBER IS
    bonus NUMBER(11, 2); -- ДАВ
    str   STRING(10);
    d     DATE;
  BEGIN
    str := '01.' || month_end || '.' || YEAR;
    d   := TO_DATE(str, 'dd.mm.yyyy');
    IF month_start IS NOT NULL
    THEN
      SELECT NVL(SUM(agrd.comission_sum), 0)
        INTO bonus
        FROM ins.ven_ag_contract_header agch
        JOIN ins.ven_ag_contract agc
          ON agc.ag_contract_id = agch.last_ver_id
        JOIN (SELECT * FROM TABLE(pkg_rep_utils_ins11.get_ag_contract_id(st, cat))) agch_id
          ON agch.ag_contract_header_id = agch_id.COLUMN_VALUE
        JOIN ins.ven_agent_report agp
          ON agp.ag_contract_h_id = agch.ag_contract_header_id
        JOIN ins.ven_ag_vedom_av agv
          ON agv.ag_vedom_av_id = agp.ag_vedom_av_id
         AND TO_CHAR(agv.date_begin, 'mm') = TO_CHAR(TO_DATE(month_end, 'mm'), 'mm')
         AND TO_CHAR(agv.date_begin, 'yyyy') = TO_CHAR(TO_DATE(YEAR, 'yyyy'), 'yyyy')
        JOIN ins.ven_t_ag_av tagv
          ON agv.t_ag_av_id = tagv.t_ag_av_id
         AND tagv.brief = 'ДАВ'
        JOIN ins.ven_agent_report_dav agrd
          ON agp.agent_report_id = agrd.agent_report_id
       WHERE TO_CHAR(agch.date_begin, 'yyyy') = TO_CHAR(TO_DATE(YEAR, 'yyyy'), 'yyyy')
         AND TO_CHAR(agch.date_begin, 'mm') = TO_CHAR(TO_DATE(month_start, 'mm'), 'mm')
         AND NVL(get_ag_contract_end_date(agc.ag_contract_id), LAST_DAY(d) + 1) > LAST_DAY(d);
      --or get_ag_contract_end_date(agc.ag_contract_id) is null);
    ELSE
      bonus := NULL;
    END IF;
    RETURN(TO_CHAR(bonus, '999999999D99'));
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  -- Возвращает количество агентов, принятых в месяце month_start
  -- и оставшихся работать вплоть до месяца month_end
  --type tbl_ag_number is table of number;
  FUNCTION get_agent_active_year
  (
    MONTH VARCHAR2
   ,YEAR  VARCHAR2
  ) RETURN tbl_ag_number
    PIPELINED IS
  BEGIN
    FOR i IN 1 .. 11
    LOOP
      PIPE ROW(get_agent_active(get_prev_month(TO_DATE(MONTH, 'mm'), i * (-1)), MONTH, YEAR));
    END LOOP;
    RETURN;
  END;

  -- Возвращает таблицу с id агентских договоров для агентов с
  -- заданными статусом и категорией
  FUNCTION get_ag_contract_id
  (
    st  VARCHAR2
   ,cat VARCHAR2
  ) RETURN tbl_ag_contract_id
    PIPELINED IS
  BEGIN
    FOR ag_rec IN (SELECT agch.*
                     FROM ins.ven_ag_contract_header agch
                     JOIN ins.ven_ag_stat_hist sth
                       ON sth.ag_contract_header_id = agch.ag_contract_header_id
                     JOIN (SELECT t.ag_contract_header_id tid
                                ,MAX(num) tnum
                            FROM ins.ven_ag_stat_hist t
                           GROUP BY t.ag_contract_header_id) tbl
                       ON sth.ag_contract_header_id = tbl.tid
                      AND sth.num = tbl.tnum
                     JOIN ins.ven_ag_stat_agent agst
                       ON agst.ag_stat_agent_id = sth.ag_stat_agent_id
                     JOIN ins.ven_ag_category_agent agCat
                       ON agCat.Ag_Category_Agent_Id = sth.ag_category_agent_id
                    WHERE agst.brief LIKE st
                      AND agCat.Brief LIKE cat)
    LOOP
      PIPE ROW(ag_rec.ag_contract_header_id);
    END LOOP;
    RETURN;
  END;

  -- Возвращает номер месяца, предшествующий данному на col месяцев
  FUNCTION get_prev_month
  (
    DATA DATE
   ,COL  NUMBER
  ) RETURN VARCHAR2 IS
    m VARCHAR2(2);
  BEGIN
    IF (TO_CHAR(ADD_MONTHS(DATA, COL), 'yyyy') = TO_CHAR(DATA, 'yyyy'))
    THEN
      m := TO_CHAR(ADD_MONTHS(DATA, COL), 'mm');
    ELSE
      m := NULL;
    END IF;
    RETURN(m);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  -- Возвращает процент уволившихся агентов за период с month_start по month_end
  -- принятых на работу в month_start
  FUNCTION get_agent_drop_percent
  (
    month_start VARCHAR2
   ,month_end   VARCHAR2
   ,YEAR        VARCHAR2
  ) RETURN NUMBER IS
    per         NUMBER(5, 2);
    ag_col      NUMBER; -- количество принятых агентов
    ag_drop_col NUMBER; -- количество уволенных агентов
  BEGIN
    IF month_start IS NOT NULL
    THEN
      ag_col      := (NVL(get_agent_number(TO_CHAR(TO_DATE(month_start, 'mm'), 'mm')
                                          ,TO_CHAR(TO_DATE(YEAR, 'yyyy'), 'yyyy'))
                         ,0));
      ag_drop_col := NVL(get_agent_drop_number(TO_CHAR(TO_DATE(month_start, 'mm'), 'mm')
                                              ,TO_CHAR(TO_DATE(month_end, 'mm'), 'mm')
                                              ,TO_CHAR(TO_DATE(YEAR, 'yyyy'), 'yyyy'))
                        ,0);
      IF ag_col > 0
      THEN
        per := (ag_drop_col / ag_col) * 100;
      ELSE
        per := 0;
      END IF;
    ELSE
      per := NULL;
    END IF;
    RETURN(TO_CHAR((per), '999D99'));
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  -- Возвращает процент уволившихся агентов за период с month_start по month_end
  -- принятых на работу в month_start
  -- с фильтром по статусу и категории
  FUNCTION get_agent_drop_percent
  (
    month_start VARCHAR2
   ,month_end   VARCHAR2
   ,YEAR        VARCHAR2
   ,st          VARCHAR2
   ,cat         VARCHAR2
  ) RETURN NUMBER IS
    per         NUMBER(5, 2);
    ag_col      NUMBER; -- количество принятых агентов
    ag_drop_col NUMBER; -- количество уволенных агентов
  BEGIN
    IF month_start IS NOT NULL
    THEN
      ag_col      := (NVL(get_agent_number(TO_CHAR(TO_DATE(month_start, 'mm'), 'mm')
                                          ,TO_CHAR(TO_DATE(YEAR, 'yyyy'), 'yyyy')
                                          ,st
                                          ,cat)
                         ,0));
      ag_drop_col := NVL(get_agent_drop_number(TO_CHAR(TO_DATE(month_start, 'mm'), 'mm')
                                              ,TO_CHAR(TO_DATE(month_end, 'mm'), 'mm')
                                              ,TO_CHAR(TO_DATE(YEAR, 'yyyy'), 'yyyy')
                                              ,st
                                              ,cat)
                        ,0);
      IF ag_col > 0
      THEN
        per := (ag_drop_col / ag_col) * 100;
      ELSE
        per := 0;
      END IF;
    ELSE
      per := NULL;
    END IF;
    RETURN(TO_CHAR((per), '999D99'));
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  -- Возвращает сумму продаж на одного агента, по агентам за период с month_start по month_end
  -- принятых на работу в month_start
  FUNCTION get_agent_sales_per
  (
    month_start VARCHAR2
   ,month_end   VARCHAR2
   ,YEAR        VARCHAR2
  ) RETURN NUMBER IS
    per      NUMBER(11, 2);
    ag_col   NUMBER; -- количество принятых агентов
    ag_sales NUMBER; -- сумма продаж по агентам
  BEGIN
    IF month_start IS NOT NULL
    THEN
      ag_col   := (NVL(get_agent_number(TO_CHAR(TO_DATE(month_start, 'mm'), 'mm')
                                       ,TO_CHAR(TO_DATE(YEAR, 'yyyy'), 'yyyy'))
                      ,0));
      ag_sales := NVL(get_agent_sales(TO_CHAR(TO_DATE(month_start, 'mm'), 'mm')
                                     ,TO_CHAR(TO_DATE(month_end, 'mm'), 'mm')
                                     ,TO_CHAR(TO_DATE(YEAR, 'yyyy'), 'yyyy'))
                     ,0);
      IF ag_col > 0
      THEN
        per := ag_sales / ag_col;
      ELSE
        per := 0;
      END IF;
    ELSE
      per := NULL;
    END IF;
    RETURN(TO_CHAR((per), '999999999D99'));
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  -- Возвращает сумму продаж на одного агента, по агентам за период с month_start по month_end
  -- принятых на работу в month_start
  -- с фильтром по статусу и категории
  FUNCTION get_agent_sales_per
  (
    month_start VARCHAR2
   ,month_end   VARCHAR2
   ,YEAR        VARCHAR2
   ,st          VARCHAR2
   ,cat         VARCHAR2
  ) RETURN NUMBER IS
    per      NUMBER(11, 2);
    ag_col   NUMBER; -- количество принятых агентов
    ag_sales NUMBER; -- сумма продаж по агентам
  BEGIN
    IF month_start IS NOT NULL
    THEN
      ag_col   := (NVL(get_agent_number(TO_CHAR(TO_DATE(month_start, 'mm'), 'mm')
                                       ,TO_CHAR(TO_DATE(YEAR, 'yyyy'), 'yyyy')
                                       ,st
                                       ,cat)
                      ,0));
      ag_sales := NVL(get_agent_sales(TO_CHAR(TO_DATE(month_start, 'mm'), 'mm')
                                     ,TO_CHAR(TO_DATE(month_end, 'mm'), 'mm')
                                     ,TO_CHAR(TO_DATE(YEAR, 'yyyy'), 'yyyy')
                                     ,st
                                     ,cat)
                     ,0);
      IF ag_col > 0
      THEN
        per := ag_sales / ag_col;
      ELSE
        per := 0;
      END IF;
    ELSE
      per := NULL;
    END IF;
    RETURN(TO_CHAR((per), '999999999D99'));
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  -- Возвращает сумму бонусов на одного агента, по агентам за период с month_start по month_end
  -- принятых на работу в month_start
  FUNCTION get_agent_bonus_per
  (
    month_start VARCHAR2
   ,month_end   VARCHAR2
   ,YEAR        VARCHAR2
  ) RETURN NUMBER IS
    per      NUMBER(11, 2);
    ag_col   NUMBER; -- количество принятых агентов
    ag_bonus NUMBER; -- сумма бонусов по агентам
  BEGIN
    IF month_start IS NOT NULL
    THEN
      ag_col   := (NVL(get_agent_number(TO_CHAR(TO_DATE(month_start, 'mm'), 'mm')
                                       ,TO_CHAR(TO_DATE(YEAR, 'yyyy'), 'yyyy'))
                      ,0));
      ag_bonus := NVL(get_agent_bonus(TO_CHAR(TO_DATE(month_start, 'mm'), 'mm')
                                     ,TO_CHAR(TO_DATE(month_end, 'mm'), 'mm')
                                     ,TO_CHAR(TO_DATE(YEAR, 'yyyy'), 'yyyy'))
                     ,0);
      IF ag_col > 0
      THEN
        per := ag_bonus / ag_col;
      ELSE
        per := 0;
      END IF;
    ELSE
      per := NULL;
    END IF;
    RETURN(TO_CHAR((per), '999999999D99'));
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  -- Возвращает сумму бонусов на одного агента, по агентам за период с month_start по month_end
  -- принятых на работу в month_start
  -- с фильтром по статусу и категории
  FUNCTION get_agent_bonus_per
  (
    month_start VARCHAR2
   ,month_end   VARCHAR2
   ,YEAR        VARCHAR2
   ,st          VARCHAR2
   ,cat         VARCHAR2
  ) RETURN NUMBER IS
    per      NUMBER(11, 2);
    ag_col   NUMBER; -- количество принятых агентов
    ag_bonus NUMBER; -- сумма бонусов по агентам
  BEGIN
    IF month_start IS NOT NULL
    THEN
      ag_col   := (NVL(get_agent_number(TO_CHAR(TO_DATE(month_start, 'mm'), 'mm')
                                       ,TO_CHAR(TO_DATE(YEAR, 'yyyy'), 'yyyy')
                                       ,st
                                       ,cat)
                      ,0));
      ag_bonus := NVL(get_agent_bonus(TO_CHAR(TO_DATE(month_start, 'mm'), 'mm')
                                     ,TO_CHAR(TO_DATE(month_end, 'mm'), 'mm')
                                     ,TO_CHAR(TO_DATE(YEAR, 'yyyy'), 'yyyy')
                                     ,st
                                     ,cat)
                     ,0);
      IF ag_col > 0
      THEN
        per := ag_bonus / ag_col;
      ELSE
        per := 0;
      END IF;
    ELSE
      per := NULL;
    END IF;
    RETURN(TO_CHAR((per), '999999999D99'));
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  -- Возвращает бонусы как процент от продаж, по агентам за период с month_start по month_end
  -- принятых на работу в month_start
  FUNCTION get_agent_bonus_sales
  (
    month_start VARCHAR2
   ,month_end   VARCHAR2
   ,YEAR        VARCHAR2
  ) RETURN NUMBER IS
    per      NUMBER(5, 2);
    ag_sales NUMBER; -- сумма продаж по агентам
    ag_bonus NUMBER; -- сумма бонусов по агентам
  BEGIN
    IF month_start IS NOT NULL
    THEN
      ag_sales := (NVL(get_agent_sales(TO_CHAR(TO_DATE(month_start, 'mm'), 'mm')
                                      ,TO_CHAR(TO_DATE(month_end, 'mm'), 'mm')
                                      ,TO_CHAR(TO_DATE(YEAR, 'yyyy'), 'yyyy'))
                      ,0));
      ag_bonus := NVL(get_agent_bonus(TO_CHAR(TO_DATE(month_start, 'mm'), 'mm')
                                     ,TO_CHAR(TO_DATE(month_end, 'mm'), 'mm')
                                     ,TO_CHAR(TO_DATE(YEAR, 'yyyy'), 'yyyy'))
                     ,0);
      IF ag_sales > 0
      THEN
        per := (ag_bonus / ag_sales) * 100;
      ELSE
        per := 0;
      END IF;
    ELSE
      per := NULL;
    END IF;
    RETURN(TO_CHAR((per), '999D99'));
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  -- Возвращает бонусы как процент от продаж, по агентам за период с month_start по month_end
  -- принятых на работу в month_start
  -- с фильтром по статусу и категории агента
  FUNCTION get_agent_bonus_sales
  (
    month_start VARCHAR2
   ,month_end   VARCHAR2
   ,YEAR        VARCHAR2
   ,st          VARCHAR2
   ,cat         VARCHAR2
  ) RETURN NUMBER IS
    per      NUMBER(5, 2);
    ag_sales NUMBER; -- сумма продаж по агентам
    ag_bonus NUMBER; -- сумма бонусов по агентам
  BEGIN
    IF month_start IS NOT NULL
    THEN
      ag_sales := (NVL(get_agent_sales(TO_CHAR(TO_DATE(month_start, 'mm'), 'mm')
                                      ,TO_CHAR(TO_DATE(month_end, 'mm'), 'mm')
                                      ,TO_CHAR(TO_DATE(YEAR, 'yyyy'), 'yyyy')
                                      ,st
                                      ,cat)
                      ,0));
      ag_bonus := NVL(get_agent_bonus(TO_CHAR(TO_DATE(month_start, 'mm'), 'mm')
                                     ,TO_CHAR(TO_DATE(month_end, 'mm'), 'mm')
                                     ,TO_CHAR(TO_DATE(YEAR, 'yyyy'), 'yyyy')
                                     ,st
                                     ,cat)
                     ,0);
      IF ag_sales > 0
      THEN
        per := (ag_bonus / ag_sales) * 100;
      ELSE
        per := 0;
      END IF;
    ELSE
      per := NULL;
    END IF;
    RETURN(TO_CHAR((per), '999D99'));
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  -- Процедура вызывает формирование отчета Tracking Report - 1
  PROCEDURE create_month_tr1
  (
    tmonth VARCHAR2
   ,tyear  VARCHAR2
  ) IS
    str      STRING(10000);
    strMonth VARCHAR2(2);
    -- столбцы по динамике
    COL             NUMBER;
    col_ag          VARCHAR2(5); -- количество агентов
    col_do          VARCHAR2(5); -- количество уволенных
    sum_sales       VARCHAR2(10); -- сумма продаж
    sum_sales_per   VARCHAR2(10); -- сумма продаж на одного агента
    sum_bonus       VARCHAR2(10); -- сумма бонусов
    sum_bonus_per   VARCHAR2(10); -- сумма бонусов на одного агента
    sum_bonus_sales VARCHAR2(6); -- бонус как процент от продаж
    -- столбцы итоговов
    tot_ag NUMBER := 0; -- итоги по агентам
    tot_do NUMBER := 0; -- итоги по уволенным
    tot_s  NUMBER := 0; -- итоги по продажам
    tot_sp NUMBER := 0; -- итоги по продажам в расчете на 1 агента
    tot_b  NUMBER := 0; -- итоги по бонусам
    tot_bp NUMBER := 0; -- итоги по бонусам в расчете на 1 агента
    tot_bs NUMBER := 0; -- итоги по бонусам как проценту с продаж
  
    row_month NUMBER; -- переменная для проверки существования месяца
  
  BEGIN
    -- проверяем существование месяца
    -- ////////////////////////////////////////////////////////////////////////
    SELECT COUNT(*)
      INTO row_month
      FROM ins_dwh.rep_tr_1 tr
     WHERE tr.MONTH = tmonth
       AND tr.YEAR = tyear;
  
    IF row_month = 0
    THEN
      INSERT INTO ins_dwh.rep_tr_1 tr (YEAR, MONTH) VALUES (tyear, tmonth);
    END IF;
  
    -- заполняем строку месяца
    -- ////////////////////////////////////////////////////////////////////////////
    -- столбец "количество рекрутированных агентов"
    COL := get_agent_number(tmonth, tyear);
    UPDATE ins_dwh.rep_tr_1 t
       SET t.ag_num    = COL
          ,t.ag_num_do = COL
          ,t.ag_num_s  = COL
          ,t.ag_num_sp = COL
          ,t.ag_num_b  = COL
          ,t.ag_num_bp = COL
          ,t.ag_num_bs = COL
     WHERE t.YEAR = tyear
       AND t.MONTH = tmonth;
    --/*
    -- заполняем столбцы, отражающие динамику рекрутированных агентов
    FOR i IN 1 .. TO_NUMBER(tmonth) - 1
    LOOP
      strMonth := get_prev_month(TO_DATE(tmonth, 'mm'), i * (-1));
    
      col_ag := TO_CHAR(get_agent_active(strMonth, tmonth, tyear));
      tot_ag := tot_ag + (NVL(col_ag, 0));
      IF col_ag IS NULL
      THEN
        col_ag := 'null';
      END IF;
    
      col_do := TO_CHAR(get_agent_drop_percent(strMonth, tmonth, tyear));
      tot_do := tot_do + (NVL(col_do, 0));
      IF col_do IS NULL
      THEN
        col_do := 'null';
      END IF;
    
      sum_sales := TO_CHAR(get_agent_sales(strMonth, tmonth, tyear));
      tot_s     := tot_s + (NVL(sum_sales, 0));
      IF sum_sales IS NULL
      THEN
        sum_sales := 'null';
      END IF;
    
      sum_sales_per := TO_CHAR(get_agent_sales_per(strMonth, tmonth, tyear));
      tot_sp        := tot_sp + (NVL(sum_sales_per, 0));
      IF sum_sales_per IS NULL
      THEN
        sum_sales_per := 'null';
      END IF;
    
      sum_bonus := TO_CHAR(get_agent_bonus(strMonth, tmonth, tyear));
      tot_b     := tot_b + (NVL(sum_bonus, 0));
      IF sum_bonus IS NULL
      THEN
        sum_bonus := 'null';
      END IF;
    
      sum_bonus_per := TO_CHAR(get_agent_bonus_per(strMonth, tmonth, tyear));
      tot_bp        := tot_bp + (NVL(sum_bonus_per, 0));
      IF sum_bonus_per IS NULL
      THEN
        sum_bonus_per := 'null';
      END IF;
    
      sum_bonus_sales := TO_CHAR(get_agent_bonus_sales(strMonth, tmonth, tyear));
      tot_bs          := tot_bs + (NVL(sum_bonus_sales, 0));
      IF sum_bonus_sales IS NULL
      THEN
        sum_bonus_sales := 'null';
      END IF;
    
      str := 'update ins_dwh.rep_tr_1 t set t.ag_' || (i + 1) || ' = ' || col_ag || -- рекрутированные агенты
             ', t.ag_do_' || (i + 1) || ' = ' || REPLACE(col_do, ',', '.') || -- уволенные агенты
             ', t.ag_s_' || (i + 1) || ' = ' || REPLACE(sum_sales, ',', '.') || -- сумма продаж
             ', t.ag_sp_' || (i + 1) || ' = ' || REPLACE(sum_sales_per, ',', '.') || -- сумма продаж на 1 агента
             ', t.ag_b_' || (i + 1) || ' = ' || REPLACE(sum_bonus, ',', '.') || -- сумма бонусов
             ', t.ag_bp_' || (i + 1) || ' = ' || REPLACE(sum_bonus_per, ',', '.') || -- сумма бонусов на 1 агента
             ', t.ag_bs_' || (i + 1) || ' = ' || REPLACE(sum_bonus_sales, ',', '.') || -- бонус как процент от продаж
             ' where t.year = ' || tyear || 'and t.month = ' || tmonth;
      EXECUTE IMMEDIATE str;
    END LOOP;
    --*/
    -- столбцы итогов
    UPDATE ins_dwh.rep_tr_1 t
       SET t.t_ag =
           (tot_ag + COL)
          , -- итоги по рекрутированным агентам
           t.t_do = tot_do
          , -- итоги по уволенным агентам
           t.t_s  = tot_s
          , -- итоги по продажам
           t.t_sp = tot_sp
          , -- итоги по продажам на 1 агента
           t.T_B  = tot_b
          , -- итоги по бонусам
           t.t_bp = tot_bp
          , -- итоги по бонусам на 1 агента
           t.t_bs = tot_bs -- итоги по бонусам как % от продаж
     WHERE t.YEAR = tyear
       AND t.MONTH = tmonth;
    COMMIT;
  END;

  -- Процедура вызывает формирование отчета Tracking Report - 1
  -- с фильтром по категории и статутсу агента
  PROCEDURE create_month_tr1
  (
    tmonth VARCHAR2
   ,tyear  VARCHAR2
   ,st     VARCHAR2
   ,cat    VARCHAR2
  ) IS
    str             STRING(1000);
    strMonth        VARCHAR2(2);
    COL             NUMBER;
    col_ag          VARCHAR2(5); -- количество агентов
    col_do          VARCHAR2(5); -- количество уволенных агентов
    sum_sales       VARCHAR2(10); -- сумма продаж
    sum_sales_per   VARCHAR2(10); -- сумма продаж на одного агента
    sum_bonus       VARCHAR2(10); -- сумма бонусов
    sum_bonus_per   VARCHAR2(10); -- сумма бонусов на одного агента
    sum_bonus_sales VARCHAR2(6); -- бонус как процент от продаж
    -- столбцы итоговов
    tot_ag NUMBER := 0; -- итоги по агентам
    tot_do NUMBER := 0; -- итоги по уволенным
    tot_s  NUMBER := 0; -- итоги по продажам
    tot_sp NUMBER := 0; -- итоги по продажам в расчете на 1 агента
    tot_b  NUMBER := 0; -- итоги по бонусам
    tot_bp NUMBER := 0; -- итоги по бонусам в расчете на 1 агента
    tot_bs NUMBER := 0; -- итоги по бонусам как проценту с продаж
  
    row_month NUMBER; -- переменная для проверки существования месяца
  BEGIN
  
    -- проверяем существование месяца
    -- ////////////////////////////////////////////////////////////////////////
    SELECT COUNT(*)
      INTO row_month
      FROM ins_dwh.rep_tr_1 tr
     WHERE tr.MONTH = tmonth
       AND tr.YEAR = tyear;
  
    IF row_month = 0
    THEN
      INSERT INTO ins_dwh.rep_tr_1 tr (YEAR, MONTH) VALUES (tyear, tmonth);
    END IF;
  
    -- заполняем строку месяца
    -- ////////////////////////////////////////////////////////////////////////////
  
    -- столбец "количество рекрутированных агентов"
    COL := get_agent_number(tmonth, tyear, st, cat);
    UPDATE ins_dwh.rep_tr_1 t
       SET t.ag_num    = COL
          ,t.ag_num_do = COL
          ,t.ag_num_s  = COL
          ,t.ag_num_sp = COL
          ,t.ag_num_b  = COL
          ,t.ag_num_bp = COL
          ,t.ag_num_bs = COL
     WHERE t.YEAR = tyear
       AND t.MONTH = tmonth;
    --/*
    -- заполняем столбцы, отражающие динамику рекрутированных агентов
    FOR i IN 1 .. TO_NUMBER(tmonth) - 1
    LOOP
      strMonth := get_prev_month(TO_DATE(tmonth, 'mm'), i * (-1));
    
      col_ag := TO_CHAR(get_agent_active(strMonth, tmonth, tyear, st, cat));
      tot_ag := tot_ag + (NVL(col_ag, 0));
      IF col_ag IS NULL
      THEN
        col_ag := 'null';
      END IF;
    
      col_do := TO_CHAR(get_agent_drop_percent(strMonth, tmonth, tyear, st, cat));
      tot_do := tot_do + (NVL(col_do, 0));
      IF col_do IS NULL
      THEN
        col_do := 'null';
      END IF;
    
      sum_sales := TO_CHAR(get_agent_sales(strMonth, tmonth, tyear, st, cat));
      tot_s     := tot_s + (NVL(sum_sales, 0));
      IF sum_sales IS NULL
      THEN
        sum_sales := 'null';
      END IF;
    
      sum_sales_per := TO_CHAR(get_agent_sales_per(strMonth, tmonth, tyear, st, cat));
      tot_sp        := tot_sp + (NVL(sum_sales_per, 0));
      IF sum_sales_per IS NULL
      THEN
        sum_sales_per := 'null';
      END IF;
    
      sum_bonus := TO_CHAR(get_agent_bonus(strMonth, tmonth, tyear, st, cat));
      tot_b     := tot_b + (NVL(sum_bonus, 0));
      IF sum_bonus IS NULL
      THEN
        sum_bonus := 'null';
      END IF;
    
      sum_bonus_per := TO_CHAR(get_agent_bonus_per(strMonth, tmonth, tyear, st, cat));
      tot_bp        := tot_bp + (NVL(sum_bonus_per, 0));
      IF sum_bonus_per IS NULL
      THEN
        sum_bonus_per := 'null';
      END IF;
    
      sum_bonus_sales := TO_CHAR(get_agent_bonus_sales(strMonth, tmonth, tyear, st, cat));
      tot_bs          := tot_bs + (NVL(sum_bonus_sales, 0));
      IF sum_bonus_sales IS NULL
      THEN
        sum_bonus_sales := 'null';
      END IF;
      str := 'update ins_dwh.rep_tr_1 t set t.ag_' || (i + 1) || ' = ' || col_ag || -- рекрутированные агенты
             ', t.ag_do_' || (i + 1) || ' = ' || REPLACE(col_do, ',', '.') || -- уволенные агенты
             ', t.ag_s_' || (i + 1) || ' = ' || REPLACE(sum_sales, ',', '.') || -- сумма продаж
             ', t.ag_sp_' || (i + 1) || ' = ' || REPLACE(sum_sales_per, ',', '.') || -- сумма продаж на 1 агента
             ', t.ag_b_' || (i + 1) || ' = ' || REPLACE(sum_bonus, ',', '.') || -- сумма бонусов
             ', t.ag_bp_' || (i + 1) || ' = ' || REPLACE(sum_bonus_per, ',', '.') || -- сумма бонусов на 1 агента
             ', t.ag_bs_' || (i + 1) || ' = ' || REPLACE(sum_bonus_sales, ',', '.') || -- бонус как процент от продаж
             ' where t.year = ' || tyear || 'and t.month = ' || tmonth;
      EXECUTE IMMEDIATE str;
    END LOOP;
    --*/
    -- столбцы итогов
    UPDATE ins_dwh.rep_tr_1 t
       SET t.t_ag =
           (tot_ag + COL)
          , -- итоги по рекрутированным агентам
           t.t_do = tot_do
          , -- итоги по уволенным агентам
           t.t_s  = tot_s
          , -- итоги по продажам
           t.t_sp = tot_sp
          , -- итоги по продажам на 1 агента
           t.T_B  = tot_b
          , -- итоги по бонусам
           t.t_bp = tot_bp
          , -- итоги по бонусам на 1 агента
           t.t_bs = tot_bs -- итоги по бонусам как % от продаж
     WHERE t.YEAR = tyear
       AND t.MONTH = tmonth;
    COMMIT;
  END;

  -- ************************************************************************
  --//////////////////////////END TRACKING REPORT 1//////////////////////////
  -- ***********************************************************************

  -- ************************************************************************
  --/////////////////////////Отчет о состоянии договора//////////////////////
  -- ************************************************************************

  -- Возвращает месяц, в котором договор участвовал в расчете ДАВ
  FUNCTION get_month_agent_dav(pol_id NUMBER) RETURN DATE IS
    res DATE;
  BEGIN
    SELECT agva.date_begin
      INTO res
      FROM ins.ven_p_pol_header ph
      JOIN ins.ven_p_policy_agent ppag
        ON ppag.policy_header_id = ph.policy_header_id
      JOIN ins.ven_ag_contract_header agch
        ON agch.ag_contract_header_id = ppag.ag_contract_header_id
      JOIN ins.ven_agent_report agr
        ON agr.ag_contract_h_id = agch.ag_contract_header_id
      JOIN ins.ven_agent_report_dav agrd
        ON agrd.agent_report_id = agr.agent_report_id
      JOIN ins.ven_t_prod_coef_type tpct
        ON tpct.t_prod_coef_type_id = agrd.prod_coef_type_id
       AND tpct.brief = 'ДАВ'
      JOIN ins.ven_agent_report_dav_ct ardc
        ON ardc.agent_report_dav_id = agrd.agent_report_dav_id
       AND ardc.policy_id = pol_id
      JOIN ins.ven_ag_vedom_av agva
        ON agva.ag_vedom_av_id = agr.ag_vedom_av_id
     WHERE ph.policy_id = pol_id;
    RETURN(TO_DATE(TO_CHAR(res, 'mm.yyyy'), 'mm.yyyy'));
  END;

  -- ************************************************************************
  --/////////////////////////END отчет о состоянии договора///////////////////
  -- ************************************************************************

  -- ************************************************************************
  --/////////////////////////TRACKING REPORT 2///////////////////////////////
  -- ************************************************************************

  -- Возврашает количество агенств, действующих в указанном месяце и году
  FUNCTION get_agency_number
  (
    MONTH VARCHAR2
   ,YEAR  VARCHAR2
  ) RETURN NUMBER IS
    num NUMBER;
    str STRING(10);
    d   DATE;
  BEGIN
    str := '01.' || MONTH || '.' || YEAR;
    d   := TO_DATE(str, 'dd.mm.yyyy');
    SELECT COUNT(*)
      INTO num
      FROM ins.ven_department dep
     WHERE dep.date_open <= LAST_DAY(d)
       AND NVL(dep.date_close, d + 1) > d;
    --or dep.date_close is null
    RETURN(num);
  END;

  -- Возвращает таблицу с id агентских договоров для агентов с
  -- c признаком ПБОЮЛ и каналом продаж не агентский и не call- центр
  FUNCTION get_part_time_id RETURN tbl_ag_contract_id
    PIPELINED IS
  BEGIN
    FOR ag_rec IN (SELECT agch.*
                     FROM ins.ven_ag_contract_header agch
                     JOIN ins.ven_ag_contract agc
                       ON agc.ag_contract_id = agch.last_ver_id
                     JOIN ins.ven_t_sales_channel sCh
                       ON sCh.ID = agch.t_sales_channel_id
                    WHERE agc.leg_pos = 1
                      AND sCh.brief NOT IN ('CC', 'MLM')
                   --and sCh.brief != 'CC'
                   --and sCh.brief != 'MLM'
                   )
    LOOP
      PIPE ROW(ag_rec.ag_contract_header_id);
    END LOOP;
    RETURN;
  END;

  -- Возвращает таблицу с id агентских договоров для агентов
  -- c указанным каналом продаж
  FUNCTION get_ag_chanal_id(chanal VARCHAR2) RETURN tbl_ag_contract_id
    PIPELINED IS
  BEGIN
    FOR ag_rec IN (SELECT agch.*
                     FROM ins.ven_ag_contract_header agch
                     JOIN ins.ven_t_sales_channel sCh
                       ON sCh.ID = agch.t_sales_channel_id
                      AND sCh.brief = chanal)
    LOOP
      PIPE ROW(ag_rec.ag_contract_header_id);
    END LOOP;
    RETURN;
  END;

  -- Возвращает таблицу с id агентских договоров для агентов
  -- c каналом продаж, кроме брокерского, агентского, call - центра, банковского
  FUNCTION get_ag_other_chanal_id RETURN tbl_ag_contract_id
    PIPELINED IS
  BEGIN
    FOR ag_rec IN (SELECT agch.*
                     FROM ins.ven_ag_contract_header agch
                     JOIN ins.ven_t_sales_channel sCh
                       ON sCh.ID = agch.t_sales_channel_id
                      AND sCh.brief NOT IN ('MLM', 'BR', 'CC', 'BANK')
                   --and sCh.brief != 'MLM'
                   --and sCh.brief != 'BR'
                   --and sCh.brief != 'CC'
                   --and sCh.brief != 'BANK'
                   )
    LOOP
      PIPE ROW(ag_rec.ag_contract_header_id);
    END LOOP;
    RETURN;
  END;

  -- Возвращает количество агентов "Part time" работающих в указанном месяце
  FUNCTION get_ag_part_time_num
  (
    MONTH VARCHAR2
   ,YEAR  VARCHAR2
  ) RETURN NUMBER IS
    num NUMBER;
    str STRING(10);
    d   DATE;
  BEGIN
    str := '01.' || MONTH || '.' || YEAR;
    d   := TO_DATE(str, 'dd.mm.yyyy');
    SELECT COUNT(*)
      INTO num
      FROM ins.ven_ag_contract_header agch
      JOIN ins.ven_ag_contract agc
        ON agc.ag_contract_id = agch.last_ver_id
      JOIN (SELECT * FROM TABLE(pkg_rep_utils_ins11.get_part_time_id)) agch_id
        ON agch.ag_contract_header_id = agch_id.COLUMN_VALUE
     WHERE agch.date_begin <= LAST_DAY(d)
       AND NVL(get_ag_contract_end_date(agc.ag_contract_id), LAST_DAY(d) + 1) > LAST_DAY(d);
    --or get_ag_contract_end_date(agc.ag_contract_id) is null);
    RETURN(num);
  END;

  -- Возвращает количество агентов работающих в указанном месяце
  -- с фильтром по статусу и категории агента
  FUNCTION get_ag_st_cat_num
  (
    MONTH VARCHAR2
   ,YEAR  VARCHAR2
   ,st    VARCHAR2
   ,cat   VARCHAR2
  ) RETURN NUMBER IS
    num NUMBER;
    str STRING(10);
    d   DATE;
  BEGIN
    str := '01.' || MONTH || '.' || YEAR;
    d   := TO_DATE(str, 'dd.mm.yyyy');
    SELECT COUNT(*)
      INTO num
      FROM ins.ven_ag_contract_header agch
      JOIN ins.ven_ag_contract agc
        ON agc.ag_contract_id = agch.last_ver_id
      JOIN (SELECT * FROM TABLE(pkg_rep_utils_ins11.get_ag_contract_id(st, cat))) agch_id
        ON agch.ag_contract_header_id = agch_id.COLUMN_VALUE
     WHERE agch.date_begin <= LAST_DAY(d)
       AND NVL(get_ag_contract_end_date(agc.ag_contract_id), LAST_DAY(d) + 1) > LAST_DAY(d);
    --or get_ag_contract_end_date(agc.ag_contract_id) is null);
    RETURN(num);
  END;

  -- Возвращает количество агентов, уволенных в указанном месяце
  -- с фильтром по статусу и категории агента
  FUNCTION get_agent_drop_number
  (
    MONTH VARCHAR2
   ,YEAR  VARCHAR2
   ,st    VARCHAR2
   ,cat   VARCHAR2
  ) RETURN NUMBER IS
    COL NUMBER;
  BEGIN
    SELECT COUNT(agch.agent_id)
      INTO COL
      FROM ins.ven_ag_contract_header agch
      JOIN ins.ven_ag_contract agc
        ON agc.ag_contract_id = agch.last_ver_id
      JOIN (SELECT * FROM TABLE(pkg_rep_utils_ins11.get_ag_contract_id(st, cat))) agch_id
        ON agch.ag_contract_header_id = agch_id.COLUMN_VALUE
     WHERE TO_CHAR(get_ag_contract_end_date(agc.ag_contract_id), 'mm') =
           TO_CHAR(TO_DATE(MONTH, 'mm'), 'mm')
       AND TO_CHAR(get_ag_contract_end_date(agc.ag_contract_id), 'yyyy') =
           TO_CHAR(TO_DATE(YEAR, 'yyyy'), 'yyyy');
    RETURN(COL);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
  END;

  -- Возвращает количество агентов PT, уволенных в указанном месяце
  FUNCTION get_ag_drop_part_time
  (
    MONTH VARCHAR2
   ,YEAR  VARCHAR2
  ) RETURN NUMBER IS
    COL NUMBER;
  BEGIN
    SELECT COUNT(agch.agent_id)
      INTO COL
      FROM ins.ven_ag_contract_header agch
      JOIN ins.ven_ag_contract agc
        ON agc.ag_contract_id = agch.last_ver_id
      JOIN (SELECT * FROM TABLE(pkg_rep_utils_ins11.get_part_time_id)) agch_id
        ON agch.ag_contract_header_id = agch_id.COLUMN_VALUE
     WHERE TO_CHAR(get_ag_contract_end_date(agc.ag_contract_id), 'mm') =
           TO_CHAR(TO_DATE(MONTH, 'mm'), 'mm')
       AND TO_CHAR(get_ag_contract_end_date(agc.ag_contract_id), 'yyyy') =
           TO_CHAR(TO_DATE(YEAR, 'yyyy'), 'yyyy');
    RETURN(COL);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
  END;

  -- Возвращает количество агентов, сменивших категорию в течение указанного месяца
  FUNCTION get_ag_change_cat_num
  (
    MONTH   VARCHAR2
   ,YEAR    VARCHAR2
   ,cat_old VARCHAR2
   ,cat_new VARCHAR2
   ,st      VARCHAR2
  ) RETURN NUMBER IS
    num NUMBER;
    str STRING(10);
    d   DATE;
  BEGIN
    str := '01.' || MONTH || '.' || YEAR;
    d   := TO_DATE(str, 'dd.mm.yyyy');
    SELECT COUNT(*)
      INTO num
      FROM ins.ven_ag_contract_header agch
      JOIN ins.ven_ag_contract agc
        ON agc.ag_contract_id = agch.last_ver_id
       AND agc.ag_contract_id =
           ins.pkg_agent_1.get_status_by_date(agch.ag_contract_header_id, LAST_DAY(ADD_MONTHS(d, -1)))
      JOIN ins.ven_ag_category_agent agCat
        ON agCat.ag_category_agent_id = agc.category_id
       AND agCat.brief LIKE cat_old
    --join ins.ven_ag_stat_hist agStH on agStH.ag_contract_header_id = agch.ag_contract_header_id
    --join ins.ven_ag_stat_agent agSt on agSt.ag_stat_agent_id = agStH.ag_stat_agent_id and agSt.brief = st
      JOIN ins.ven_ag_contract agc1
        ON agc1.contract_id = agch.ag_contract_header_id
       AND agc1.ag_contract_id =
           ins.pkg_agent_1.get_status_by_date(agch.ag_contract_header_id, LAST_DAY(d))
      JOIN ins.ven_ag_category_agent agCat1
        ON agCat1.ag_category_agent_id = agc.category_id
       AND agCat1.brief LIKE cat_new
     WHERE ins.pkg_agent_1.get_agent_status_brief_by_date(agch.ag_contract_header_id
                                                         ,LAST_DAY(ADD_MONTHS(d, -1))) LIKE st;
    RETURN(num);
  END;

  -- Возвращает сумму продаж по агентам
  -- с фильтром по статусу и категории агента
  FUNCTION get_agent_sales
  (
    MONTH VARCHAR2
   ,YEAR  VARCHAR2
   ,st    VARCHAR2
   ,cat   VARCHAR2
  ) RETURN NUMBER IS
    SALES NUMBER(11, 2); -- сумма продаж
  BEGIN
    SELECT NVL(SUM(ppag.part_agent / 100 * pp.premium *
                   ins.acc_new.Get_Cross_Rate_By_Id((SELECT t.rate_type_id
                                                      FROM ins.ven_rate_type t
                                                     WHERE t.brief = 'ЦБ')
                                                   ,pph.fund_id
                                                   ,(SELECT f.fund_id
                                                      FROM ins.ven_fund f
                                                     WHERE f.brief = 'RUR')
                                                   ,pp.notice_date))
              ,0)
      INTO SALES
      FROM ins.ven_ag_contract_header agch
      JOIN ins.ven_ag_contract agc
        ON agc.ag_contract_id = agch.last_ver_id
      JOIN (SELECT * FROM TABLE(pkg_rep_utils_ins11.get_ag_contract_id(st, cat))) agch_id
        ON agch.ag_contract_header_id = agch_id.COLUMN_VALUE
      LEFT JOIN ins.ven_p_policy_agent ppag
        ON ppag.ag_contract_header_id = agch.ag_contract_header_id
      LEFT JOIN ins.ven_p_pol_header pph
        ON pph.policy_header_id = ppag.policy_header_id
      LEFT JOIN ins.ven_p_policy pp
        ON pp.pol_header_id = pph.policy_header_id
       AND pp.version_num = 1
       AND TO_CHAR(pp.notice_date, 'mm') = TO_CHAR(TO_DATE(MONTH, 'mm'), 'mm')
       AND TO_CHAR(pp.notice_date, 'yyyy') = TO_CHAR(TO_DATE(YEAR, 'yyyy'), 'yyyy');
    RETURN(TO_CHAR(SALES, '999999999D99'));
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  -- Возвращает сумму продаж по агентам c накопленным итогом с начала года
  -- с фильтром по статусу и категории агента
  FUNCTION get_agent_sales_ytd
  (
    MONTH VARCHAR2
   ,YEAR  VARCHAR2
   ,st    VARCHAR2
   ,cat   VARCHAR2
  ) RETURN NUMBER IS
    SALES   NUMBER(11, 2); -- сумма продаж
    tempSal NUMBER; -- временная переменная
  BEGIN
    SALES := 0;
    FOR i IN 1 .. TO_NUMBER(MONTH)
    LOOP
      SELECT NVL(SUM(ppag.part_agent / 100 * pp.premium *
                     ins.acc_new.Get_Cross_Rate_By_Id((SELECT t.rate_type_id
                                                        FROM ins.ven_rate_type t
                                                       WHERE t.brief = 'ЦБ')
                                                     ,pph.fund_id
                                                     ,(SELECT f.fund_id
                                                        FROM ins.ven_fund f
                                                       WHERE f.brief = 'RUR')
                                                     ,pp.notice_date))
                ,0)
        INTO tempSal
        FROM ins.ven_ag_contract_header agch
        JOIN ins.ven_ag_contract agc
          ON agc.ag_contract_id = agch.last_ver_id
        JOIN (SELECT * FROM TABLE(pkg_rep_utils_ins11.get_ag_contract_id(st, cat))) agch_id
          ON agch.ag_contract_header_id = agch_id.COLUMN_VALUE
        LEFT JOIN ins.ven_p_policy_agent ppag
          ON ppag.ag_contract_header_id = agch.ag_contract_header_id
        LEFT JOIN ins.ven_p_pol_header pph
          ON pph.policy_header_id = ppag.policy_header_id
        LEFT JOIN ins.ven_p_policy pp
          ON pp.pol_header_id = pph.policy_header_id
         AND pp.version_num = 1
         AND TO_CHAR(pp.notice_date, 'mm') = TO_CHAR(TO_DATE(i, 'mm'), 'mm')
         AND TO_CHAR(pp.notice_date, 'yyyy') = TO_CHAR(TO_DATE(YEAR, 'yyyy'), 'yyyy');
      SALES := SALES + tempSal;
    END LOOP;
    RETURN(TO_CHAR(SALES, '999999999D99'));
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  -- Возвращает сумму продаж по агентам
  -- с фильтром по статусу и категории агента
  FUNCTION get_ag_sales_part_time
  (
    MONTH VARCHAR2
   ,YEAR  VARCHAR2
  ) RETURN NUMBER IS
    SALES NUMBER(11, 2); -- сумма продаж
  BEGIN
    SELECT NVL(SUM(ppag.part_agent / 100 * pp.premium *
                   ins.acc_new.Get_Cross_Rate_By_Id((SELECT t.rate_type_id
                                                      FROM ins.ven_rate_type t
                                                     WHERE t.brief = 'ЦБ')
                                                   ,pph.fund_id
                                                   ,(SELECT f.fund_id
                                                      FROM ins.ven_fund f
                                                     WHERE f.brief = 'RUR')
                                                   ,pp.notice_date))
              ,0)
      INTO SALES
      FROM ins.ven_ag_contract_header agch
      JOIN ins.ven_ag_contract agc
        ON agc.ag_contract_id = agch.last_ver_id
      JOIN (SELECT * FROM TABLE(pkg_rep_utils_ins11.get_part_time_id)) agch_id
        ON agch.ag_contract_header_id = agch_id.COLUMN_VALUE
      LEFT JOIN ins.ven_p_policy_agent ppag
        ON ppag.ag_contract_header_id = agch.ag_contract_header_id
      LEFT JOIN ins.ven_p_pol_header pph
        ON pph.policy_header_id = ppag.policy_header_id
      LEFT JOIN ins.ven_p_policy pp
        ON pp.pol_header_id = pph.policy_header_id
       AND pp.version_num = 1
       AND TO_CHAR(pp.notice_date, 'mm') = TO_CHAR(TO_DATE(MONTH, 'mm'), 'mm')
       AND TO_CHAR(pp.notice_date, 'yyyy') = TO_CHAR(TO_DATE(YEAR, 'yyyy'), 'yyyy');
    IF SALES IS NULL
    THEN
      SALES := 0;
    END IF;
    RETURN(TO_CHAR(SALES, '999999999D99'));
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  -- Возвращает сумму продаж по агентам
  -- с фильтром по каналу продаж
  FUNCTION get_ag_sales_chanal
  (
    MONTH  VARCHAR2
   ,YEAR   VARCHAR2
   ,chanal VARCHAR2
  ) RETURN NUMBER IS
    SALES NUMBER(11, 2); -- сумма продаж
  BEGIN
    SELECT NVL(SUM(ppag.part_agent / 100 * pp.premium *
                   ins.acc_new.Get_Cross_Rate_By_Id((SELECT t.rate_type_id
                                                      FROM ins.ven_rate_type t
                                                     WHERE t.brief = 'ЦБ')
                                                   ,pph.fund_id
                                                   ,(SELECT f.fund_id
                                                      FROM ins.ven_fund f
                                                     WHERE f.brief = 'RUR')
                                                   ,pp.notice_date))
              ,0)
      INTO SALES
      FROM ins.ven_ag_contract_header agch
      JOIN ins.ven_ag_contract agc
        ON agc.ag_contract_id = agch.last_ver_id
      JOIN (SELECT * FROM TABLE(pkg_rep_utils_ins11.get_ag_chanal_id(chanal))) agch_id
        ON agch.ag_contract_header_id = agch_id.COLUMN_VALUE
      LEFT JOIN ins.ven_p_policy_agent ppag
        ON ppag.ag_contract_header_id = agch.ag_contract_header_id
      LEFT JOIN ins.ven_p_pol_header pph
        ON pph.policy_header_id = ppag.policy_header_id
      LEFT JOIN ins.ven_p_policy pp
        ON pp.pol_header_id = pph.policy_header_id
       AND pp.version_num = 1
       AND TO_CHAR(pp.notice_date, 'mm') = TO_CHAR(TO_DATE(MONTH, 'mm'), 'mm')
       AND TO_CHAR(pp.notice_date, 'yyyy') = TO_CHAR(TO_DATE(YEAR, 'yyyy'), 'yyyy');
    IF SALES IS NULL
    THEN
      SALES := 0;
    END IF;
    RETURN(TO_CHAR(SALES, '999999999D99'));
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  -- Возвращает сумму продаж по агентам
  -- для всех канадов продаж, кроме агентского, банковского, брокерского, call - центра
  FUNCTION get_ag_sales_other_chanal
  (
    MONTH VARCHAR2
   ,YEAR  VARCHAR2
  ) RETURN NUMBER IS
    SALES NUMBER(11, 2); -- сумма продаж
  BEGIN
    SELECT NVL(SUM(ppag.part_agent / 100 * pp.premium *
                   ins.acc_new.Get_Cross_Rate_By_Id((SELECT t.rate_type_id
                                                      FROM ins.ven_rate_type t
                                                     WHERE t.brief = 'ЦБ')
                                                   ,pph.fund_id
                                                   ,(SELECT f.fund_id
                                                      FROM ins.ven_fund f
                                                     WHERE f.brief = 'RUR')
                                                   ,pp.notice_date))
              ,0)
      INTO SALES
      FROM ins.ven_ag_contract_header agch
      JOIN ins.ven_ag_contract agc
        ON agc.ag_contract_id = agch.last_ver_id
      JOIN (SELECT * FROM TABLE(pkg_rep_utils_ins11.get_ag_other_chanal_id)) agch_id
        ON agch.ag_contract_header_id = agch_id.COLUMN_VALUE
      LEFT JOIN ins.ven_p_policy_agent ppag
        ON ppag.ag_contract_header_id = agch.ag_contract_header_id
      LEFT JOIN ins.ven_p_pol_header pph
        ON pph.policy_header_id = ppag.policy_header_id
      LEFT JOIN ins.ven_p_policy pp
        ON pp.pol_header_id = pph.policy_header_id
       AND pp.version_num = 1
       AND TO_CHAR(pp.notice_date, 'mm') = TO_CHAR(TO_DATE(MONTH, 'mm'), 'mm')
       AND TO_CHAR(pp.notice_date, 'yyyy') = TO_CHAR(TO_DATE(YEAR, 'yyyy'), 'yyyy');
    IF SALES IS NULL
    THEN
      SALES := 0;
    END IF;
    RETURN(TO_CHAR(SALES, '999999999D99'));
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  -- Возвращает сумму продаж по агентам с накопленным итогом с начала года
  -- с фильтром по статусу и категории агента
  FUNCTION get_ag_sales_part_time_ytd
  (
    MONTH VARCHAR2
   ,YEAR  VARCHAR2
  ) RETURN NUMBER IS
    SALES   NUMBER(11, 2); -- сумма продаж
    tempSal NUMBER; -- временная переменная
  BEGIN
    SALES := 0;
    FOR i IN 1 .. TO_NUMBER(MONTH)
    LOOP
      SELECT NVL(SUM(ppag.part_agent / 100 * pp.premium *
                     ins.acc_new.Get_Cross_Rate_By_Id((SELECT t.rate_type_id
                                                        FROM ins.ven_rate_type t
                                                       WHERE t.brief = 'ЦБ')
                                                     ,pph.fund_id
                                                     ,(SELECT f.fund_id
                                                        FROM ins.ven_fund f
                                                       WHERE f.brief = 'RUR')
                                                     ,pp.notice_date))
                ,0)
        INTO tempSal
        FROM ins.ven_ag_contract_header agch
        JOIN ins.ven_ag_contract agc
          ON agc.ag_contract_id = agch.last_ver_id
        JOIN (SELECT * FROM TABLE(pkg_rep_utils_ins11.get_part_time_id)) agch_id
          ON agch.ag_contract_header_id = agch_id.COLUMN_VALUE
        LEFT JOIN ins.ven_p_policy_agent ppag
          ON ppag.ag_contract_header_id = agch.ag_contract_header_id
        LEFT JOIN ins.ven_p_pol_header pph
          ON pph.policy_header_id = ppag.policy_header_id
        LEFT JOIN ins.ven_p_policy pp
          ON pp.pol_header_id = pph.policy_header_id
         AND pp.version_num = 1
         AND TO_CHAR(pp.notice_date, 'mm') = TO_CHAR(TO_DATE(i, 'mm'), 'mm')
         AND TO_CHAR(pp.notice_date, 'yyyy') = TO_CHAR(TO_DATE(YEAR, 'yyyy'), 'yyyy');
      SALES := SALES + tempSal;
    END LOOP;
    RETURN(TO_CHAR(SALES, '999999999D99'));
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  -- Возвращает сумму продаж по агентам с накопленным итогом с начала года
  -- с фильтром по каналу продаж
  FUNCTION get_ag_sales_chanal_ytd
  (
    MONTH  VARCHAR2
   ,YEAR   VARCHAR2
   ,chanal VARCHAR2
  ) RETURN NUMBER IS
    SALES   NUMBER(11, 2); -- сумма продаж
    tempSal NUMBER; -- временная переменная
  BEGIN
    SALES := 0;
    FOR i IN 1 .. TO_NUMBER(MONTH)
    LOOP
      SELECT NVL(SUM(ppag.part_agent / 100 * pp.premium *
                     ins.acc_new.Get_Cross_Rate_By_Id((SELECT t.rate_type_id
                                                        FROM ins.ven_rate_type t
                                                       WHERE t.brief = 'ЦБ')
                                                     ,pph.fund_id
                                                     ,(SELECT f.fund_id
                                                        FROM ins.ven_fund f
                                                       WHERE f.brief = 'RUR')
                                                     ,pp.notice_date))
                ,0)
        INTO tempSal
        FROM ins.ven_ag_contract_header agch
        JOIN ins.ven_ag_contract agc
          ON agc.ag_contract_id = agch.last_ver_id
        JOIN (SELECT * FROM TABLE(pkg_rep_utils_ins11.get_ag_chanal_id(chanal))) agch_id
          ON agch.ag_contract_header_id = agch_id.COLUMN_VALUE
        LEFT JOIN ins.ven_p_policy_agent ppag
          ON ppag.ag_contract_header_id = agch.ag_contract_header_id
        LEFT JOIN ins.ven_p_pol_header pph
          ON pph.policy_header_id = ppag.policy_header_id
        LEFT JOIN ins.ven_p_policy pp
          ON pp.pol_header_id = pph.policy_header_id
         AND pp.version_num = 1
         AND TO_CHAR(pp.notice_date, 'mm') = TO_CHAR(TO_DATE(i, 'mm'), 'mm')
         AND TO_CHAR(pp.notice_date, 'yyyy') = TO_CHAR(TO_DATE(YEAR, 'yyyy'), 'yyyy');
      SALES := SALES + tempSal;
    END LOOP;
    RETURN(TO_CHAR(SALES, '999999999D99'));
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  -- Возвращает сумму продаж по агентам с накопленным итогом с начала года
  -- для всех каналов кроме агентского , банковского, брокерского и call - центра
  FUNCTION get_ag_sales_other_chanal_ytd
  (
    MONTH VARCHAR2
   ,YEAR  VARCHAR2
  ) RETURN NUMBER IS
    SALES   NUMBER(11, 2); -- сумма продаж
    tempSal NUMBER; -- временная переменная
  BEGIN
    SALES := 0;
    FOR i IN 1 .. TO_NUMBER(MONTH)
    LOOP
      SELECT NVL(SUM(ppag.part_agent / 100 * pp.premium *
                     ins.acc_new.Get_Cross_Rate_By_Id((SELECT t.rate_type_id
                                                        FROM ins.ven_rate_type t
                                                       WHERE t.brief = 'ЦБ')
                                                     ,pph.fund_id
                                                     ,(SELECT f.fund_id
                                                        FROM ins.ven_fund f
                                                       WHERE f.brief = 'RUR')
                                                     ,pp.notice_date))
                ,0)
        INTO tempSal
        FROM ins.ven_ag_contract_header agch
        JOIN ins.ven_ag_contract agc
          ON agc.ag_contract_id = agch.last_ver_id
        JOIN (SELECT * FROM TABLE(pkg_rep_utils_ins11.get_ag_other_chanal_id)) agch_id
          ON agch.ag_contract_header_id = agch_id.COLUMN_VALUE
        LEFT JOIN ins.ven_p_policy_agent ppag
          ON ppag.ag_contract_header_id = agch.ag_contract_header_id
        LEFT JOIN ins.ven_p_pol_header pph
          ON pph.policy_header_id = ppag.policy_header_id
        LEFT JOIN ins.ven_p_policy pp
          ON pp.pol_header_id = pph.policy_header_id
         AND pp.version_num = 1
         AND TO_CHAR(pp.notice_date, 'mm') = TO_CHAR(TO_DATE(i, 'mm'), 'mm')
         AND TO_CHAR(pp.notice_date, 'yyyy') = TO_CHAR(TO_DATE(YEAR, 'yyyy'), 'yyyy');
      SALES := SALES + tempSal;
    END LOOP;
    RETURN(TO_CHAR(SALES, '999999999D99'));
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  -- Вовзвращает сумму продаж для групп менеджеров
  FUNCTION get_sales_um_groop
  (
    MONTH VARCHAR2
   ,YEAR  VARCHAR2
  ) RETURN NUMBER IS
    sal NUMBER;
  BEGIN
    SELECT NVL(SUM(pa.part_agent / 100 * pp.premium *
                   ins.acc_new.Get_Cross_Rate_By_Id((SELECT t.rate_type_id
                                                      FROM ins.ven_rate_type t
                                                     WHERE t.brief = 'ЦБ')
                                                   ,ph.fund_id
                                                   ,(SELECT f.fund_id
                                                      FROM ins.ven_fund f
                                                     WHERE f.brief = 'RUR')
                                                   ,pp.notice_date))
              ,0)
      INTO sal
      FROM ins.ven_p_pol_header ph
      JOIN ins.ven_p_policy pp
        ON pp.pol_header_id = ph.policy_header_id
       AND pp.version_num = 1
       AND TO_CHAR(pp.notice_date, 'mm') = TO_CHAR(TO_DATE(MONTH, 'mm'), 'mm')
       AND TO_CHAR(pp.notice_date, 'yyyy') = TO_CHAR(TO_DATE(YEAR, 'yyyy'), 'yyyy')
      JOIN ins.ven_p_policy_agent pa
        ON pa.policy_header_id = ph.policy_header_id
      JOIN ins.ven_ag_contract_header agch
        ON agch.ag_contract_header_id = pa.ag_contract_header_id
      JOIN ins.ven_ag_contract agc
        ON agc.ag_contract_id = agch.last_ver_id
       AND ins.pkg_agent_1.get_status_by_date(agch.ag_contract_header_id, pp.notice_date) =
           agc.ag_contract_id
      JOIN ins.ven_ag_contract agcLead
        ON agc.contract_leader_id = agcLead.Ag_Contract_Id
      JOIN ins.ven_ag_category_agent agCat
        ON agCat.Ag_Category_Agent_Id = agcLead.Category_Id
       AND agCat.Brief = 'MN';
    IF sal IS NULL
    THEN
      sal := 0;
    END IF;
    RETURN(sal);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  -- Вовзвращает сумму продаж для групп менеджеров с накопленным итогом с начала года
  FUNCTION get_sales_um_groop_ytd
  (
    MONTH VARCHAR2
   ,YEAR  VARCHAR2
  ) RETURN NUMBER IS
    sal     NUMBER;
    tempNum NUMBER; --  времнная переменная
  BEGIN
    sal := 0;
    FOR i IN 1 .. TO_NUMBER(MONTH)
    LOOP
      SELECT NVL(SUM(pa.part_agent / 100 * pp.premium *
                     ins.acc_new.Get_Cross_Rate_By_Id((SELECT t.rate_type_id
                                                        FROM ins.ven_rate_type t
                                                       WHERE t.brief = 'ЦБ')
                                                     ,ph.fund_id
                                                     ,(SELECT f.fund_id
                                                        FROM ins.ven_fund f
                                                       WHERE f.brief = 'RUR')
                                                     ,pp.notice_date))
                ,0)
        INTO tempNum
        FROM ins.ven_p_pol_header ph
        JOIN ins.ven_p_policy pp
          ON pp.pol_header_id = ph.policy_header_id
         AND pp.version_num = 1
         AND TO_CHAR(pp.notice_date, 'mm') = TO_CHAR(TO_DATE(MONTH, 'mm'), 'mm')
         AND TO_CHAR(pp.notice_date, 'yyyy') = TO_CHAR(TO_DATE(YEAR, 'yyyy'), 'yyyy')
        JOIN ins.ven_p_policy_agent pa
          ON pa.policy_header_id = ph.policy_header_id
        JOIN ins.ven_ag_contract_header agch
          ON agch.ag_contract_header_id = pa.ag_contract_header_id
        JOIN ins.ven_ag_contract agc
          ON agc.ag_contract_id = agch.last_ver_id
         AND ins.pkg_agent_1.get_status_by_date(agch.ag_contract_header_id, pp.notice_date) =
             agc.ag_contract_id
        JOIN ins.ven_ag_contract agcLead
          ON agc.contract_leader_id = agcLead.Ag_Contract_Id
        JOIN ins.ven_ag_category_agent agCat
          ON agCat.Ag_Category_Agent_Id = agcLead.Category_Id
         AND agCat.Brief = 'MN';
      sal := sal + tempNum;
    END LOOP;
    RETURN(sal);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  -- Процедура вызывает формирование отчета Tracking Report - 2
  PROCEDURE create_month_tr2
  (
    tmonth VARCHAR2
   ,tyear  VARCHAR2
  ) IS
    ag_recr NUMBER; -- количество рекрутированных агентов
    -- столбцы по количеству агентов
    col_agency NUMBER; -- количество агенств
    col_UM     NUMBER; -- количество UM (unit manager)
    col_TR     NUMBER; -- количество TR (traainee)
    col_PT     NUMBER; -- количество PT (part time)
    col_C      NUMBER; -- количество С (consultant)
    col_SC     NUMBER; -- количество SC (senior consultant)
    col_EC     NUMBER; -- количество EC (elite consultant)
    col_tot    NUMBER; -- общее количество агентов, без UM
    -- столбцы по увольнению
    drop_UM     NUMBER; -- количество уволившихся UM
    change_UM   NUMBER; -- количество UM, категорию
    drop_TR     NUMBER; -- количество уволившихся TR
    change_TR   NUMBER; -- количество TR, сменивших категорию
    drop_PT     NUMBER; -- количество уволившихся PT
    drop_C      NUMBER; -- количество уволившихся C
    change_C    NUMBER; -- количество C, сменивших категорию
    drop_SC     NUMBER; -- количество уволившихся SC
    change_SC   NUMBER; -- количество SC, сменивших категорию
    change_EC   NUMBER; -- количество EC, сменивших категорию
    drop_EC     NUMBER; -- количество уволившихся EC
    drop_per_UM NUMBER; -- процент уволившихся UM
    drop_per_TR NUMBER; -- процент уволившихся TR
    drop_per_FT NUMBER; -- процент уволившихся FT (full time)
    drop_per_PT NUMBER; -- процент уволившихся PT
    drop_per_C  NUMBER; -- процент уволившихся С
    drop_per_SC NUMBER; -- процент уволившихся SС
    drop_per_EC NUMBER; -- процент уволившихся EС
    -- стобцы по продажам
    sales_um    NUMBER; -- сумма продаж по агентам UM
    sales_TR    NUMBER; -- сумма продаж по агентам TR
    sales_PT    NUMBER; -- сумма продаж по агентам PT
    sales_C     NUMBER; -- сумма продаж по агентам C
    sales_SC    NUMBER; -- сумма продаж по агентам SC
    sales_EC    NUMBER; -- сумма продаж по агентам EC
    sales_um_gr NUMBER; -- сумма продаж по агентам UM - groop
    sales_total NUMBER; -- сумма продаж по всем агентам, кроме UM
    -- столбцы по продажам в разрезе каналов продаж
    sales_br       NUMBER; -- сумма продаж по брокерам
    sales_b        NUMBER; -- сумма продаж по банкам
    sales_oth      NUMBER; -- сумма продаж по другим каналам продаж
    sales_ch_total NUMBER; -- сумма по всем каналам продаж
    -- столбцы по продажам с накопленным итогом с начала года
    sales_um_ytd    NUMBER; -- сумма продаж по агентам UM
    sales_TR_ytd    NUMBER; -- сумма продаж по агентам TR
    sales_PT_ytd    NUMBER; -- сумма продаж по агентам PT
    sales_C_ytd     NUMBER; -- сумма продаж по агентам C
    sales_SC_ytd    NUMBER; -- сумма продаж по агентам SC
    sales_EC_ytd    NUMBER; -- сумма продаж по агентам EC
    sales_um_gr_ytd NUMBER; -- сумма продаж по агентам UM - groop
    sales_total_ytd NUMBER; -- сумма продаж по всем агентам, кроме UM
    -- столбцы по продажам в разрезе каналов продаж с накопленным итогом с начала года
    sales_br_ytd       NUMBER; -- сумма продаж по брокерам
    sales_b_ytd        NUMBER; -- сумма продаж по банкам
    sales_oth_ytd      NUMBER; -- сумма продаж по другим каналам продаж
    sales_ch_total_ytd NUMBER; -- сумма по всем каналам продаж
    -- столбцы по продуктивности
    prod_um    NUMBER; -- продуктивность по агентам UM
    prod_TR    NUMBER; -- продуктивность по агентам TR
    prod_PT    NUMBER; -- продуктивность по агентам PT
    prod_C     NUMBER; -- продуктивность по агентам C
    prod_SC    NUMBER; -- продуктивность по агентам SC
    prod_EC    NUMBER; -- продуктивность по агентам EC
    prod_total NUMBER; -- продуктивность по всем агентам, кроме UM
  
    row_month NUMBER; -- переменная для проверки существования месяца
  
  BEGIN
    -- проверяем существование месяца
    -- ////////////////////////////////////////////////////////////////////////
    SELECT COUNT(*)
      INTO row_month
      FROM ins_dwh.rep_tr_2 tr
     WHERE tr.MONTH = tmonth
       AND tr.YEAR = tyear;
  
    IF row_month = 0
    THEN
      INSERT INTO ins_dwh.rep_tr_2 tr (YEAR, MONTH, PERIOD) VALUES (tyear, tmonth, 'CURR');
      INSERT INTO ins_dwh.rep_tr_2 tr (YEAR, MONTH, period) VALUES (tyear, tmonth, 'YTD');
    END IF;
  
    -- заполняем строку месяца
    -- ////////////////////////////////////////////////////////////////////////////
    --  столбцы "количество агенств" и "кол-во агенств с накопленным итогом"
    col_agency := get_agency_number(tmonth, tyear);
    UPDATE ins_dwh.rep_tr_2 t
       SET t.agency_num = col_agency
     WHERE t.YEAR = tyear
       AND t.MONTH = tmonth;
  
    -- cтолбец "количество UM"
    col_um := get_ag_st_cat_num(tmonth, tyear, '%', 'MN');
    UPDATE ins_dwh.rep_tr_2 t
       SET t.um_num = col_UM
     WHERE t.YEAR = tyear
       AND t.MONTH = tmonth
       AND t.period = 'CURR';
  
    -- cтолбец "количество TR"
    col_tr := get_ag_st_cat_num(tmonth, tyear, 'Конс', 'AG');
    UPDATE ins_dwh.rep_tr_2 t
       SET t.tr_num = col_TR
     WHERE t.YEAR = tyear
       AND t.MONTH = tmonth
       AND t.period = 'CURR';
  
    -- cтолбец "количество PT"
    col_pt := get_ag_part_time_num(tmonth, tyear);
    UPDATE ins_dwh.rep_tr_2 t
       SET t.pt_num = col_pt
     WHERE t.YEAR = tyear
       AND t.MONTH = tmonth
       AND t.period = 'CURR';
  
    -- cтолбец "количество C"
    col_c := get_ag_st_cat_num(tmonth, tyear, 'ФинКонс', 'AG');
    UPDATE ins_dwh.rep_tr_2 t
       SET t.c_num = col_c
     WHERE t.YEAR = tyear
       AND t.MONTH = tmonth
       AND t.period = 'CURR';
  
    -- cтолбец "количество SC"
    col_sc := get_ag_st_cat_num(tmonth, tyear, 'ВедКонс', 'AG');
    UPDATE ins_dwh.rep_tr_2 t
       SET t.sc_num = col_sc
     WHERE t.YEAR = tyear
       AND t.MONTH = tmonth
       AND t.period = 'CURR';
  
    -- cтолбец "количество EC"
    col_ec := get_ag_st_cat_num(tmonth, tyear, 'ФинСов', 'AG');
    UPDATE ins_dwh.rep_tr_2 t
       SET t.ec_num = col_ec
     WHERE t.YEAR = tyear
       AND t.MONTH = tmonth
       AND t.period = 'CURR';
  
    -- cтолбец "общее количество агентов"
    col_tot := col_tr + col_pt + col_c + col_sc + col_ec;
    UPDATE ins_dwh.rep_tr_2 t
       SET t.tot_num = col_tot
     WHERE t.YEAR = tyear
       AND t.MONTH = tmonth
       AND t.period = 'CURR';
  
    -- столбец "процент уволившихся UM"
    drop_UM   := get_agent_drop_number(tmonth, tyear, '%', 'MN');
    change_UM := get_ag_change_cat_num(tmonth, tyear, 'MN', 'AG', '%');
    IF col_UM = 0
    THEN
      drop_per_UM := 0;
    ELSE
      drop_per_UM := ((drop_UM + change_UM) / col_UM) * 100;
    END IF;
    UPDATE ins_dwh.rep_tr_2 t
       SET t.um_drop = drop_per_UM
     WHERE t.YEAR = tyear
       AND t.MONTH = tmonth
       AND t.period = 'CURR';
  
    -- столбец "процент уволившихся TR"
    drop_tr   := get_agent_drop_number(tmonth, tyear, 'Конс', 'AG');
    change_tr := get_ag_change_cat_num(tmonth, tyear, 'AG', 'MN', 'Конс');
    IF col_tr = 0
    THEN
      drop_per_tr := 0;
    ELSE
      drop_per_tr := ((drop_tr + change_tr) / col_tr) * 100;
    END IF;
    UPDATE ins_dwh.rep_tr_2 t
       SET t.tr_drop = drop_per_tr
     WHERE t.YEAR = tyear
       AND t.MONTH = tmonth
       AND t.period = 'CURR';
  
    -- столбец "процент уволившихся FT"
    drop_C    := get_agent_drop_number(tmonth, tyear, 'ФинКонс', 'AG');
    drop_SC   := get_agent_drop_number(tmonth, tyear, 'ВедКонс', 'AG');
    drop_EC   := get_agent_drop_number(tmonth, tyear, 'ФинСов', 'AG');
    change_C  := get_ag_change_cat_num(tmonth, tyear, 'AG', 'MN', 'ФинКонс');
    change_SC := get_ag_change_cat_num(tmonth, tyear, 'AG', 'MN', 'ВедКонс');
    change_EC := get_ag_change_cat_num(tmonth, tyear, 'AG', 'MN', 'ФинСов');
  
    IF col_C = 0
    THEN
      drop_per_C := 0;
    ELSE
      drop_per_C := (drop_C + change_C) / col_C;
    END IF;
    IF col_SC = 0
    THEN
      drop_per_SC := 0;
    ELSE
      drop_per_SC := (drop_SC + change_SC) / col_SC;
    END IF;
    IF col_EC = 0
    THEN
      drop_per_EC := 0;
    ELSE
      drop_per_EC := (drop_EC + change_EC) / col_EC;
    END IF;
    drop_per_FT := ((drop_per_C + drop_per_SC + drop_per_EC) / 3) * 100;
    UPDATE ins_dwh.rep_tr_2 t
       SET t.ft_drop = drop_per_ft
     WHERE t.YEAR = tyear
       AND t.MONTH = tmonth
       AND t.period = 'CURR';
  
    -- столбец "процент уволившихся PT"
    drop_PT := get_ag_part_time_num(tmonth, tyear);
    IF col_PT = 0
    THEN
      drop_per_PT := 0;
    ELSE
      drop_per_PT := (drop_PT / col_PT) * 100;
    END IF;
    UPDATE ins_dwh.rep_tr_2 t
       SET t.pt_drop = drop_per_pt
     WHERE t.YEAR = tyear
       AND t.MONTH = tmonth
       AND t.period = 'CURR';
  
    -- столбец "продажи UM"
    sales_um := get_agent_sales(tmonth, tyear, '%', 'MN');
    UPDATE ins_dwh.rep_tr_2 t
       SET t.um_sales = sales_um
     WHERE t.YEAR = tyear
       AND t.MONTH = tmonth
       AND t.period = 'CURR';
  
    -- столбец "продажи TR"
    sales_tr := get_agent_sales(tmonth, tyear, 'Конс', 'AG');
    UPDATE ins_dwh.rep_tr_2 t
       SET t.tr_sales = sales_tr
     WHERE t.YEAR = tyear
       AND t.MONTH = tmonth
       AND t.period = 'CURR';
  
    -- столбец "продажи PT"
    sales_pt := get_ag_sales_part_time(tmonth, tyear);
    UPDATE ins_dwh.rep_tr_2 t
       SET t.pt_sales = sales_pt
     WHERE t.YEAR = tyear
       AND t.MONTH = tmonth
       AND t.period = 'CURR';
  
    -- столбец "продажи C"
    sales_c := get_agent_sales(tmonth, tyear, 'ФинКонс', 'AG');
    UPDATE ins_dwh.rep_tr_2 t
       SET t.c_sales = sales_c
     WHERE t.YEAR = tyear
       AND t.MONTH = tmonth
       AND t.period = 'CURR';
  
    -- столбец "продажи SC"
    sales_sc := get_agent_sales(tmonth, tyear, 'ВедКонс', 'AG');
    UPDATE ins_dwh.rep_tr_2 t
       SET t.sc_sales = sales_sc
     WHERE t.YEAR = tyear
       AND t.MONTH = tmonth
       AND t.period = 'CURR';
  
    -- столбец "продажи EC"
    sales_ec := get_agent_sales(tmonth, tyear, 'ФинСов', 'AG');
    UPDATE ins_dwh.rep_tr_2 t
       SET t.ec_sales = sales_ec
     WHERE t.YEAR = tyear
       AND t.MONTH = tmonth
       AND t.period = 'CURR';
  
    -- столбец "продажи группы агентов"
    sales_um_gr := get_sales_um_groop(tmonth, tyear);
    UPDATE ins_dwh.rep_tr_2 t
       SET t.um_groop_sales = sales_um_gr
     WHERE t.YEAR = tyear
       AND t.MONTH = tmonth
       AND t.period = 'CURR';
  
    -- столбец "общие продажи"
    sales_total := sales_tr + sales_pt + sales_c + sales_sc + sales_ec + sales_um_gr;
    UPDATE ins_dwh.rep_tr_2 t
       SET t.tot_ape = sales_total
     WHERE t.YEAR = tyear
       AND t.MONTH = tmonth
       AND t.period = 'CURR';
  
    -- столбец "продажи UM - YTD"
    sales_um_ytd := get_agent_sales_ytd(tmonth, tyear, '%', 'MN');
    UPDATE ins_dwh.rep_tr_2 t
       SET t.um_sales = sales_um_ytd
     WHERE t.YEAR = tyear
       AND t.MONTH = tmonth
       AND t.period = 'YTD';
  
    -- столбец "продажи TR - YTD"
    sales_tr_ytd := get_agent_sales_ytd(tmonth, tyear, 'Конс', 'AG');
    UPDATE ins_dwh.rep_tr_2 t
       SET t.tr_sales = sales_tr_ytd
     WHERE t.YEAR = tyear
       AND t.MONTH = tmonth
       AND t.period = 'YTD';
  
    -- столбец "продажи PT - YTD"
    sales_pt_ytd := get_ag_sales_part_time_ytd(tmonth, tyear);
    UPDATE ins_dwh.rep_tr_2 t
       SET t.pt_sales = sales_pt_ytd
     WHERE t.YEAR = tyear
       AND t.MONTH = tmonth
       AND t.period = 'YTD';
  
    -- столбец "продажи C - YTD"
    sales_c_ytd := get_agent_sales_ytd(tmonth, tyear, 'ФинКонс', 'AG');
    UPDATE ins_dwh.rep_tr_2 t
       SET t.c_sales = sales_c_ytd
     WHERE t.YEAR = tyear
       AND t.MONTH = tmonth
       AND t.period = 'YTD';
  
    -- столбец "продажи SC - YTD"
    sales_sc_ytd := get_agent_sales_ytd(tmonth, tyear, 'ВедКонс', 'AG');
    UPDATE ins_dwh.rep_tr_2 t
       SET t.sc_sales = sales_sc_ytd
     WHERE t.YEAR = tyear
       AND t.MONTH = tmonth
       AND t.period = 'YTD';
  
    -- столбец "продажи EC - YTD"
    sales_ec_ytd := get_agent_sales_ytd(tmonth, tyear, 'ФинСов', 'AG');
    UPDATE ins_dwh.rep_tr_2 t
       SET t.ec_sales = sales_ec_ytd
     WHERE t.YEAR = tyear
       AND t.MONTH = tmonth
       AND t.period = 'YTD';
  
    -- столбец "продажи группы агентов" с накопленным итогом
    sales_um_gr_ytd := get_sales_um_groop_ytd(tmonth, tyear);
    UPDATE ins_dwh.rep_tr_2 t
       SET t.um_groop_sales = sales_um_gr_ytd
     WHERE t.YEAR = tyear
       AND t.MONTH = tmonth
       AND t.period = 'YTD';
  
    -- столбец "общие продажи"
    sales_total_ytd := sales_TR_ytd + sales_PT_ytd + sales_C_ytd + sales_SC_ytd + sales_EC_ytd +
                       sales_um_gr_ytd;
    UPDATE ins_dwh.rep_tr_2 t
       SET t.tot_ape = sales_total_ytd
     WHERE t.YEAR = tyear
       AND t.MONTH = tmonth
       AND t.period = 'YTD';
  
    -- столбец "продуктивность UM"
    IF col_um = 0
    THEN
      prod_um := 0;
    ELSE
      prod_um := sales_um / col_um;
    END IF;
    UPDATE ins_dwh.rep_tr_2 t
       SET t.um_prod = prod_um
     WHERE t.YEAR = tyear
       AND t.MONTH = tmonth
       AND t.period = 'CURR';
  
    -- столбец "продуктивность TR"
    IF col_tr = 0
    THEN
      prod_tr := 0;
    ELSE
      prod_tr := sales_tr / col_tr;
    END IF;
    UPDATE ins_dwh.rep_tr_2 t
       SET t.tr_prod = prod_tr
     WHERE t.YEAR = tyear
       AND t.MONTH = tmonth
       AND t.period = 'CURR';
  
    -- столбец "продуктивность PT"
    IF col_pt = 0
    THEN
      prod_pt := 0;
    ELSE
      prod_pt := sales_pt / col_pt;
    END IF;
    UPDATE ins_dwh.rep_tr_2 t
       SET t.pt_prod = prod_pt
     WHERE t.YEAR = tyear
       AND t.MONTH = tmonth
       AND t.period = 'CURR';
  
    -- столбец "продуктивность C"
    IF col_c = 0
    THEN
      prod_c := 0;
    ELSE
      prod_c := sales_c / col_c;
    END IF;
    UPDATE ins_dwh.rep_tr_2 t
       SET t.c_prod = prod_c
     WHERE t.YEAR = tyear
       AND t.MONTH = tmonth
       AND t.period = 'CURR';
  
    -- столбец "продуктивность SC"
    IF col_sc = 0
    THEN
      prod_sc := 0;
    ELSE
      prod_sc := sales_sc / col_sc;
    END IF;
    UPDATE ins_dwh.rep_tr_2 t
       SET t.sc_prod = prod_sc
     WHERE t.YEAR = tyear
       AND t.MONTH = tmonth
       AND t.period = 'CURR';
  
    -- столбец "продуктивность EC"
    IF col_ec = 0
    THEN
      prod_ec := 0;
    ELSE
      prod_ec := sales_ec / col_ec;
    END IF;
    UPDATE ins_dwh.rep_tr_2 t
       SET t.ec_prod = prod_ec
     WHERE t.YEAR = tyear
       AND t.MONTH = tmonth
       AND t.period = 'CURR';
  
    -- столбец "общая продуктивность"
    prod_total := prod_tr + prod_pt + prod_c + prod_sc + prod_ec;
    UPDATE ins_dwh.rep_tr_2 t
       SET t.tot_prod = prod_total
     WHERE t.YEAR = tyear
       AND t.MONTH = tmonth
       AND t.period = 'CURR';
  
    -- столбец "продажи брокеров"
    sales_br := get_ag_sales_chanal(tmonth, tyear, 'BR');
    UPDATE ins_dwh.rep_tr_2 t
       SET t.br_ape = sales_br
     WHERE t.YEAR = tyear
       AND t.MONTH = tmonth
       AND t.period = 'CURR';
  
    -- столбец "продажи банков"
    sales_b := get_ag_sales_chanal(tmonth, tyear, 'BANK');
    UPDATE ins_dwh.rep_tr_2 t
       SET t.banc_ape = sales_b
     WHERE t.YEAR = tyear
       AND t.MONTH = tmonth
       AND t.period = 'CURR';
  
    -- столбец "продажи прочих каналов"
    sales_oth := get_ag_sales_other_chanal(tmonth, tyear);
    UPDATE ins_dwh.rep_tr_2 t
       SET t.other_ape = sales_oth
     WHERE t.YEAR = tyear
       AND t.MONTH = tmonth
       AND t.period = 'CURR';
  
    -- столбец "общие продажи по всем каналам"
    sales_ch_total := sales_total + sales_br + sales_b + sales_oth;
    UPDATE ins_dwh.rep_tr_2 t
       SET t.tot_ape_crand = sales_ch_total
     WHERE t.YEAR = tyear
       AND t.MONTH = tmonth
       AND t.period = 'CURR';
  
    -- столбец "продажи брокеров - YTD"
    sales_br_ytd := get_ag_sales_chanal_ytd(tmonth, tyear, 'BR');
    UPDATE ins_dwh.rep_tr_2 t
       SET t.br_ape = sales_br_ytd
     WHERE t.YEAR = tyear
       AND t.MONTH = tmonth
       AND t.period = 'YTD';
  
    -- столбец "продажи банков - YTD"
    sales_b_ytd := get_ag_sales_chanal_ytd(tmonth, tyear, 'BANK');
    UPDATE ins_dwh.rep_tr_2 t
       SET t.banc_ape = sales_b_ytd
     WHERE t.YEAR = tyear
       AND t.MONTH = tmonth
       AND t.period = 'YTD';
  
    -- столбец "продажи прочих каналов - YTD"
    sales_oth_ytd := get_ag_sales_other_chanal_ytd(tmonth, tyear);
    UPDATE ins_dwh.rep_tr_2 t
       SET t.other_ape = sales_oth_ytd
     WHERE t.YEAR = tyear
       AND t.MONTH = tmonth
       AND t.period = 'YTD';
  
    -- столбец "общие продажи по всем каналам - YTD"
    sales_ch_total_ytd := sales_total_ytd + sales_br_ytd + sales_b_ytd + sales_oth_ytd;
    UPDATE ins_dwh.rep_tr_2 t
       SET t.tot_ape_crand = sales_ch_total_ytd
     WHERE t.YEAR = tyear
       AND t.MONTH = tmonth
       AND t.period = 'YTD';
  
    -- столбец "количество рекрутированных агентов"
    ag_recr := get_agent_number(tmonth, tyear);
    UPDATE ins_dwh.rep_tr_2 t
       SET t.ag_recr = ag_recr
     WHERE t.YEAR = tyear
       AND t.MONTH = tmonth
       AND t.period = 'CURR';
    COMMIT;
  END;

  -- ************************************************************************
  --/////////////////////////END TRACKING REPORT 2///////////////////////////
  -- ************************************************************************

  -- ************************************************************************
  --//////////////////////////NEW and EXISTING BUSINESS REPORT///////////////
  -- ************************************************************************

  -- Возвращает id договоров, заключенных агентством и каналом продаж
  FUNCTION get_pol_dep_ch_id
  (
    dep_id NUMBER
   ,ch_br  VARCHAR2
  ) RETURN tbl_id
    PIPELINED IS
    -- временные переменные
    t_dep_id VARCHAR2(10); -- id агентства
    t_ch_br  VARCHAR2(30); -- cсокращение канала продаж
  BEGIN
    -- устанавливаем переменные
    IF (dep_id = -1 OR dep_id IS NULL)
    THEN
      t_dep_id := '%';
    ELSE
      t_dep_id := dep_id;
    END IF;
  
    IF ch_br IS NULL
    THEN
      t_ch_br := '%';
    ELSE
      t_ch_br := ch_br;
    END IF;
  
    -- заполняем таблицу
    FOR rec IN (SELECT DISTINCT ph.*
                  FROM ins.ven_p_pol_header ph
                  JOIN ins.ven_t_sales_channel sch
                    ON ph.sales_channel_id = sch.ID
                 WHERE sch.brief LIKE t_ch_br
                   AND ph.agency_id LIKE t_dep_id)
    LOOP
      PIPE ROW(rec.policy_header_id);
    END LOOP;
    RETURN;
  END;

  -- Возвращает количество заявлений, зарегистрированных в указанный период
  FUNCTION get_notice_num
  (
    dleft     DATE
   ,dright    DATE
   ,depart_id VARCHAR2
   ,chanal    VARCHAR2
  ) RETURN NUMBER IS
    num NUMBER; -- количество заявлений
  BEGIN
    SELECT COUNT(*)
      INTO num
      FROM ins.ven_p_pol_header ph
      JOIN ins.ven_p_policy pp
        ON pp.policy_id = ph.policy_id
      JOIN (SELECT * FROM TABLE(pkg_rep_utils_ins11.get_pol_dep_ch_id(depart_id, chanal))) tbl
        ON ph.policy_header_id = tbl.COLUMN_VALUE
     WHERE pp.notice_date BETWEEN dleft AND dright;
    RETURN(num);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
  END;

  -- Возвращает сумму премий по завялениям, зарегистрированным в указанный период
  FUNCTION get_notice_premium
  (
    dleft     DATE
   ,dright    DATE
   ,depart_id VARCHAR2
   ,chanal    VARCHAR2
  ) RETURN NUMBER IS
    summa NUMBER; --  сумма премий
  BEGIN
    SELECT SUM(pp.premium * ins.acc_new.Get_Cross_Rate_By_Id((SELECT t.rate_type_id
                                                               FROM ins.ven_rate_type t
                                                              WHERE t.brief = 'ЦБ')
                                                            ,ph.fund_id
                                                            ,(SELECT f.fund_id
                                                               FROM ins.ven_fund f
                                                              WHERE f.brief = 'RUR')
                                                            ,pp.notice_date))
      INTO summa
      FROM ins.ven_p_pol_header ph
      JOIN ins.ven_p_policy pp
        ON pp.policy_id = ph.policy_id
      JOIN (SELECT * FROM TABLE(pkg_rep_utils_ins11.get_pol_dep_ch_id(depart_id, chanal))) tbl
        ON ph.policy_header_id = tbl.COLUMN_VALUE
     WHERE pp.notice_date BETWEEN dleft AND dright;
    RETURN(summa);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
  END;

  -- Возвращает количество полисов, ставших активными в указанный период
  FUNCTION get_pol_active_num
  (
    dleft     DATE
   ,dright    DATE
   ,depart_id VARCHAR2
   ,chanal    VARCHAR2
  ) RETURN NUMBER IS
    num NUMBER; -- количество заявлений
  BEGIN
    SELECT COUNT(*)
      INTO num
      FROM ins.ven_p_pol_header ph
      JOIN ins.ven_p_policy pp
        ON pp.policy_id = ph.policy_id
      JOIN (SELECT * FROM TABLE(pkg_rep_utils_ins11.get_pol_dep_ch_id(depart_id, chanal))) tbl
        ON ph.policy_header_id = tbl.COLUMN_VALUE
     WHERE ins.doc.get_status_date(pp.policy_id, 'ACTIVE') BETWEEN dleft AND dright;
    RETURN(num);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
  END;

  -- Возвращает сумму премий по полисам, ставшиими активными в указанный период
  FUNCTION get_pol_active_premium
  (
    dleft     DATE
   ,dright    DATE
   ,depart_id VARCHAR2
   ,chanal    VARCHAR2
  ) RETURN NUMBER IS
    summa NUMBER; -- сумма премий
  BEGIN
    SELECT SUM(pp.premium * ins.acc_new.Get_Cross_Rate_By_Id((SELECT t.rate_type_id
                                                               FROM ins.ven_rate_type t
                                                              WHERE t.brief = 'ЦБ')
                                                            ,ph.fund_id
                                                            ,(SELECT f.fund_id
                                                               FROM ins.ven_fund f
                                                              WHERE f.brief = 'RUR')
                                                            ,pp.notice_date))
      INTO summa
      FROM ins.ven_p_pol_header ph
      JOIN ins.ven_p_policy pp
        ON pp.policy_id = ph.policy_id
      JOIN (SELECT * FROM TABLE(pkg_rep_utils_ins11.get_pol_dep_ch_id(depart_id, chanal))) tbl
        ON ph.policy_header_id = tbl.COLUMN_VALUE
     WHERE ins.doc.get_status_date(pp.policy_id, 'ACTIVE') BETWEEN dleft AND dright;
    RETURN(summa);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
  END;

  -- Возвращает количество заявлений, зарегистрированных в указанный период
  -- в статусе "Проект" или "Готовится к расторжению"
  FUNCTION get_notice_outside_num
  (
    dleft     DATE
   ,dright    DATE
   ,depart_id VARCHAR2
   ,chanal    VARCHAR2
  ) RETURN NUMBER IS
    num NUMBER; -- количество заявлений
  BEGIN
    SELECT COUNT(*)
      INTO num
      FROM ins.ven_p_pol_header ph
      JOIN ins.ven_p_policy pp
        ON pp.policy_id = ph.policy_id
      JOIN (SELECT * FROM TABLE(pkg_rep_utils_ins11.get_pol_dep_ch_id(depart_id, chanal))) tbl
        ON ph.policy_header_id = tbl.COLUMN_VALUE
     WHERE pp.notice_date BETWEEN dleft AND dright
       AND ins.doc.get_doc_status_brief(pp.policy_id) IN ('PROJECT', 'READY_TO_CANCEL');
    RETURN(num);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
  END;

  -- Возвращает сумму премий по завялениям, зарегистрированных в указанный период
  -- в статусе "Проект" или "Готовится к расторжению"
  FUNCTION get_notice_outside_premium
  (
    dleft     DATE
   ,dright    DATE
   ,depart_id VARCHAR2
   ,chanal    VARCHAR2
  ) RETURN NUMBER IS
    summa NUMBER; --сумма премий
  BEGIN
    SELECT SUM(pp.premium * ins.acc_new.Get_Cross_Rate_By_Id((SELECT t.rate_type_id
                                                               FROM ins.ven_rate_type t
                                                              WHERE t.brief = 'ЦБ')
                                                            ,ph.fund_id
                                                            ,(SELECT f.fund_id
                                                               FROM ins.ven_fund f
                                                              WHERE f.brief = 'RUR')
                                                            ,pp.notice_date))
      INTO summa
      FROM ins.ven_p_pol_header ph
      JOIN ins.ven_p_policy pp
        ON pp.policy_id = ph.policy_id
      JOIN (SELECT * FROM TABLE(pkg_rep_utils_ins11.get_pol_dep_ch_id(depart_id, chanal))) tbl
        ON ph.policy_header_id = tbl.COLUMN_VALUE
     WHERE pp.notice_date BETWEEN dleft AND dright
       AND ins.doc.get_doc_status_brief(pp.policy_id) IN ('PROJECT', 'READY_TO_CANCEL');
    RETURN(summa);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
  END;

  -- Возвращает количество агентов, совершивших сделку в указанный период
  FUNCTION get_agent_have_sales_num
  (
    dleft     DATE
   ,dright    DATE
   ,depart_id VARCHAR2
   ,chanal    VARCHAR2
  ) RETURN NUMBER IS
    num NUMBER; -- количество агентов
    -- временные переменные
    t_dep_id VARCHAR2(10); -- id агентства
    t_ch_br  VARCHAR2(30); -- cокращение канала продаж
  BEGIN
    -- устанавливаем переменные
    IF (depart_id = -1 OR depart_id IS NULL)
    THEN
      t_dep_id := '%';
    ELSE
      t_dep_id := depart_id;
    END IF;
  
    IF chanal IS NULL
    THEN
      t_ch_br := '%';
    ELSE
      t_ch_br := chanal;
    END IF;
  
    SELECT COUNT(DISTINCT agch.agent_id)
      INTO num
      FROM ins.ven_ag_contract_header agch
      JOIN ins.ven_p_policy_agent ppag
        ON ppag.ag_contract_header_id = agch.ag_contract_header_id
      JOIN ins.ven_p_pol_header ph
        ON ppag.policy_header_id = ph.policy_header_id
      JOIN ins.ven_p_policy pp
        ON pp.policy_id = ph.policy_id
      JOIN ins.ven_t_sales_channel sch
        ON ph.sales_channel_id = sch.ID
     WHERE pp.notice_date BETWEEN dleft AND dright
       AND NVL(TO_CHAR(agch.agency_id), t_dep_id) LIKE t_dep_id
       AND sch.brief LIKE t_ch_br;
    RETURN(num);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
  END;

  -- Возвращает общее количество агентов, дейсвующих на определенную дату
  FUNCTION get_total_agent_number
  (
    dright    DATE
   ,depart_id VARCHAR2
   ,chanal    VARCHAR2
  ) RETURN NUMBER IS
    num NUMBER; -- общее количество агентов
    -- временные переменные
    t_dep_id VARCHAR2(10); -- id агентства
    t_ch_br  VARCHAR2(30); -- cсокращение канала продаж
  BEGIN
    -- устанавливаем переменные
    IF depart_id = -1
    THEN
      t_dep_id := '%';
    ELSE
      t_dep_id := depart_id;
    END IF;
  
    IF chanal IS NULL
    THEN
      t_ch_br := '%';
    ELSE
      t_ch_br := chanal;
    END IF;
  
    SELECT COUNT(agch.agent_id)
      INTO num
      FROM ins.ven_ag_contract_header agch
      JOIN ins.ven_ag_contract agc
        ON agc.ag_contract_id = agch.last_ver_id
      JOIN ins.ven_t_sales_channel sch
        ON agch.t_sales_channel_id = sch.ID
     WHERE NVL(get_ag_contract_end_date(agc.ag_contract_id), dright + 1) > dright
          --or get_ag_contract_end_date(agc.ag_contract_id) is null)
       AND NVL(TO_CHAR(agch.agency_id), t_dep_id) LIKE t_dep_id
       AND sch.brief LIKE t_ch_br;
    RETURN(num);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
  END;

  -- Возвращает таблицу с названиями департаментов и каналов продаж
  -- поля "название", id агенства, канал продаж
  FUNCTION get_list_departments_chanals(dright DATE) RETURN tbl_ag_ch
    PIPELINED IS
  BEGIN
    -- находим действующие агентства
    FOR ag_rec IN (SELECT DISTINCT get_pol_agency_name(dep.department_id)
                                  ,dep.department_id
                                  ,sch.brief
                     FROM ins.ven_ag_contract_header agch
                     JOIN ins.ven_department dep
                       ON dep.department_id = agch.agency_id
                     JOIN ins.ven_t_sales_channel sch
                       ON sch.ID = agch.t_sales_channel_id
                    WHERE NVL(dep.date_close, dright + 1) > dright
                      AND sch.brief = 'MLM')
    LOOP
      PIPE ROW(ag_rec);
    END LOOP;
    -- добавляем каналы продаж
    FOR ch_rec IN (SELECT sch.description || ' канал продаж'
                         ,-1
                         ,sch.brief
                     FROM ins.ven_t_sales_channel sch
                    WHERE sch.brief != 'MLM')
    LOOP
      PIPE ROW(ch_rec);
    END LOOP;
    RETURN;
  END;

  -- добавляет строку в таблицу rep_neb
  PROCEDURE insert_row_to_rep_neb
  (
    fday    DATE
   ,fperiod VARCHAR2
   ,fregion VARCHAR2
   ,fblock  VARCHAR2
   ,fparam  VARCHAR2
   ,fvalue  NUMBER
  ) IS
  BEGIN
    INSERT INTO ins_dwh.rep_neb rn
      (DAY, period, region, BLOCK, param, VALUE)
    VALUES
      (fday, fperiod, fregion, fblock, fparam, fvalue);
  END;

  -- обновляет строку в таблицу rep_neb
  PROCEDURE update_row_to_rep_neb
  (
    fday    DATE
   ,fperiod VARCHAR2
   ,fregion VARCHAR2
   ,fblock  VARCHAR2
   ,fparam  VARCHAR2
   ,fvalue  NUMBER
  ) IS
  BEGIN
    UPDATE ins_dwh.rep_neb rn
       SET VALUE = fvalue
     WHERE rn.DAY = fday
       AND rn.period = fperiod
       AND rn.region = fregion
       AND rn.BLOCK = fblock
       AND rn.param = fparam;
  END;

  -- Процедура вызывает формирование отчета New and Exsiting Business report на дату
  PROCEDURE create_day_neb(dright DATE) IS
    -- вычисляемые переменные
    pol_act_num      NUMBER := 0; --количество активных договоров
    pol_act_prem     NUMBER := 0; --премия по активным договорам
    pol_out_num      NUMBER := 0; --количество невыпущенных полюсов
    pol_out_prem     NUMBER := 0; --премия по невыпущенным договорам
    ag_active_num_m  NUMBER := 0; -- количество активных агентов
    ag_tot_num_m     NUMBER := 0; -- общее количество агентов
    prod_ag_act_not  NUMBER := 0; -- продуктивность активных агентов по заявлениям
    prod_ag_act_prem NUMBER := 0; -- продуктивность активных агентов по премии
    prod_ag_tot_not  NUMBER := 0; --продуктивность вех агентов по заявлениям
    prod_ag_tot_prem NUMBER := 0; -- продуктивность всех агентов по премии
  
    -- вспомогательные переменные
    dep_name VARCHAR2(200); -- название агентства
    d_id     VARCHAR2(10); -- для передачи id агенства
  
    d_name VARCHAR(250); -- для передачи имени агентсва
  
  BEGIN
    -- чистим таблицу 
    DELETE ins_dwh.rep_neb rn WHERE rn.DAY = dright;
  
    DBMS_OUTPUT.PUT_LINE(TO_CHAR(dright, 'yyyy.mm.dd.hh24.mi.ss'));
  
    --/*
    --ag_active_num_m:= get_agent_have_sales_num(trunc(dright,'mm'),dright,d_id,ch_br);
    --ag_tot_num_m:= get_total_agent_number(dright,d_id,ch_br);
  
    FOR rec IN (SELECT tbl.dep_name
                      ,tbl.dep_id
                      ,tbl.sh_br
                       -- ***********************
                       -- за день
                       -- ***********************
                      ,SUM(CASE
                             WHEN tbl.not_date = dright THEN
                              1
                             ELSE
                              0
                           END) AS notice_num --notice_num
                      ,SUM(CASE
                             WHEN tbl.not_date = dright THEN
                              pp.premium * ins.acc_new.Get_Cross_Rate_By_Id((SELECT t.rate_type_id
                                                                              FROM ins.ven_rate_type t
                                                                             WHERE t.brief = 'ЦБ')
                                                                           ,ph.fund_id
                                                                           ,(SELECT f.fund_id
                                                                              FROM ins.ven_fund f
                                                                             WHERE f.brief = 'RUR')
                                                                           ,pp.notice_date)
                             ELSE
                              0
                           END) AS notice_prem -- notice_prem
                       /*     ,sum(case
                                    when to_char((ins.doc.get_status_date(pp.policy_id, 'ACTIVE'))= dright
                         --                and tbl.not_date = dright 
                                         then
                                         1
                                    else
                                         0
                                    end) as pol_act_num -- pol_act_num
                             ,sum(case
                                    when trunc (ins.doc.get_status_date(pp.policy_id, 'ACTIVE'))= dright
                       --                 and tbl.not_date = dright 
                                         then
                                         pp.premium* 
                                         ins.acc_new.Get_Cross_Rate_By_Id(
                                                      (select t.rate_type_id 
                                                              from ins.ven_rate_type t 
                                                              where t.brief ='ЦБ' ),
                                                       ph.fund_id,
                                                       (select f.fund_id from ins.ven_fund f where f.brief = 'RUR'),
                                                       pp.notice_date
                                                       )
                                    else
                                         0
                                    end) as pol_act_prem  -- pol_act_prem  */
                       /*      ,sum(case
                                when ins.doc.get_doc_status_brief(pp.policy_id) = ('PROJECT') 
                                and ins.doc.get_doc_status_brief(pp.policy_id) != ('READY_TO_CANCEL')
                                    and tbl.not_date = dright 
                                     then
                                     1
                                else
                                     0
                                end) as pol_out_num  -- pol_out_num
                         ,sum(case
                                when ins.doc.get_doc_status_brief(pp.policy_id) = ('PROJECT') 
                                and ins.doc.get_doc_status_brief(pp.policy_id) != ('READY_TO_CANCEL') 
                                 and tbl.not_date = dright 
                       then
                                    pp.premium * 
                                    ins.acc_new.Get_Cross_Rate_By_Id(
                                                  (select t.rate_type_id 
                                                          from ins.ven_rate_type t 
                                                          where t.brief ='ЦБ' ),
                                                   ph.fund_id,
                                                   (select f.fund_id from ins.ven_fund f where f.brief = 'RUR'),
                                                   pp.notice_date
                                                   )
                                else
                                     0
                                end) as pol_out_prem  -- pol_out_prem */
                       
                       -- ***********************
                       -- за месяц
                       -- ***********************
                       
                      ,COUNT(pp.policy_id) AS notice_num_m --notice_num_m
                      ,SUM(pp.premium * ins.acc_new.Get_Cross_Rate_By_Id((SELECT t.rate_type_id
                                                                           FROM ins.ven_rate_type t
                                                                          WHERE t.brief = 'ЦБ')
                                                                        ,ph.fund_id
                                                                        ,(SELECT f.fund_id
                                                                           FROM ins.ven_fund f
                                                                          WHERE f.brief = 'RUR')
                                                                        ,pp.notice_date)) AS notice_prem_m -- notice_prem_m
                       
                      ,SUM(CASE
                             WHEN TRUNC(ins.doc.get_status_date(pp.policy_id, 'ACTIVE')) <= dright
                                  AND TRUNC(ins.doc.get_status_date(pp.policy_id, 'ACTIVE')) >=
                                  TRUNC(dright, 'mm') THEN
                              1
                             ELSE
                              0
                           END) AS pol_act_num_m -- pol_act_num_m
                      ,SUM(CASE
                             WHEN TRUNC(ins.doc.get_status_date(pp.policy_id, 'ACTIVE')) = dright
                                  AND TRUNC(ins.doc.get_status_date(pp.policy_id, 'ACTIVE')) >=
                                  TRUNC(dright, 'mm') THEN
                              pp.premium * ins.acc_new.Get_Cross_Rate_By_Id((SELECT t.rate_type_id
                                                                              FROM ins.ven_rate_type t
                                                                             WHERE t.brief = 'ЦБ')
                                                                           ,ph.fund_id
                                                                           ,(SELECT f.fund_id
                                                                              FROM ins.ven_fund f
                                                                             WHERE f.brief = 'RUR')
                                                                           ,pp.notice_date)
                             ELSE
                              0
                           END) AS pol_act_prem_m -- pol_act_prem_m 
                       
                      ,SUM(CASE
                             WHEN ins.doc.get_doc_status_brief(pp.policy_id) IN
                                  ('PROJECT', 'READY_TO_CANCEL') THEN
                              1
                             ELSE
                              0
                           END) AS pol_out_num_m -- pol_out_num_m
                      ,SUM(CASE
                             WHEN ins.doc.get_doc_status_brief(pp.policy_id) IN
                                  ('PROJECT', 'READY_TO_CANCEL') THEN
                              pp.premium * ins.acc_new.Get_Cross_Rate_By_Id((SELECT t.rate_type_id
                                                                              FROM ins.ven_rate_type t
                                                                             WHERE t.brief = 'ЦБ')
                                                                           ,ph.fund_id
                                                                           ,(SELECT f.fund_id
                                                                              FROM ins.ven_fund f
                                                                             WHERE f.brief = 'RUR')
                                                                           ,pp.notice_date)
                             ELSE
                              0
                           END) AS pol_out_prem_m -- pol_out_prem_m 
                
                  FROM (SELECT NVL(DECODE(sch.brief
                                         ,'MLM'
                                         ,pkg_rep_utils_ins11.get_pol_agency_name(ph.agency_id)
                                         ,sch.description || ' канал продаж')
                                  ,'Неопределенный канал продаж') AS dep_name
                              ,NVL(ph.agency_id, -1) AS dep_id
                              ,sch.brief AS sh_br
                              ,pp.policy_id AS pol_id
                              ,pp.notice_date AS not_date
                          FROM ins.ven_p_pol_header ph
                          JOIN ins.ven_p_policy pp
                            ON ph.policy_header_id = pp.pol_header_id
                          JOIN ins.ven_t_sales_channel sch
                            ON ph.sales_channel_id = sch.ID
                         WHERE ins.pkg_rep_utils.get_notice_date(ph.policy_header_id) BETWEEN
                               TRUNC(dright, 'mm') AND dright
                           AND pp.version_num = (SELECT MAX(p.version_num)
                                                   FROM ins.ven_p_policy p
                                                  WHERE ph.policy_header_id = p.pol_header_id
                                                    AND p.start_date < = dright)
                        
                        ) tbl
                      ,ins.ven_p_policy pp
                      ,ins.ven_p_pol_header ph
                 WHERE pp.policy_id = tbl.pol_id
                   AND ph.policy_header_id = pp.pol_header_id
                 GROUP BY tbl.dep_name
                         ,tbl.dep_id
                         ,tbl.sh_br)
    LOOP
    
      IF (NVL(rec.dep_id, -1) = -1)
      THEN
        d_id := '%';
      ELSE
        d_id := TO_CHAR(rec.dep_id);
      END IF;
    
      ag_active_num_m  := 0;
      ag_tot_num_m     := 0;
      pol_act_num      := 0;
      pol_act_prem     := 0;
      prod_ag_act_not  := 0;
      prod_ag_act_prem := 0;
      prod_ag_tot_not  := 0;
      prod_ag_tot_prem := 0;
    
      -- определяем показатели по агентам
      -- число активных агентов
      SELECT COUNT(DISTINCT agch.agent_id)
        INTO ag_active_num_m
        FROM ins.ven_ag_contract_header agch
        JOIN ins.ven_p_policy_agent ppag
          ON ppag.ag_contract_header_id = agch.ag_contract_header_id
        JOIN ins.ven_p_pol_header ph
          ON ppag.policy_header_id = ph.policy_header_id
        JOIN ins.ven_p_policy pp
          ON pp.policy_id = ph.policy_id
        JOIN ins.ven_t_sales_channel sch
          ON ph.sales_channel_id = sch.ID
       WHERE pp.notice_date BETWEEN TRUNC(dright, 'mm') AND dright
         AND NVL(TO_CHAR(agch.agency_id), d_id) LIKE d_id
         AND sch.brief LIKE rec.sh_br;
    
      -- общее число агентов
      SELECT (COUNT(agch.agent_id))
        INTO ag_tot_num_m
        FROM ins.ven_ag_contract_header agch
        JOIN ins.ven_ag_contract agc
          ON agc.contract_id = agch.ag_contract_header_id
        JOIN ins.ven_t_sales_channel sch
          ON agch.t_sales_channel_id = sch.ID
       WHERE NVL(get_ag_contract_end_date(agc.ag_contract_id), dright + 1) > dright
         AND agc.reg_date = (SELECT MAX(a.reg_date)
                               FROM ins.ven_ag_contract a
                              WHERE agch.ag_contract_header_id = a.contract_id
                                AND a.reg_date < = dright)
         AND NVL(TO_CHAR(agch.agency_id), d_id) LIKE d_id
         AND sch.brief LIKE rec.sh_br;
    
      -- количество и премия активных договоров 
      SELECT
      
       COUNT(TO_CHAR(ins.doc.get_doc_status_brief(pp.policy_id)))
      ,NVL(SUM(pp.premium * ins.acc_new.Get_Cross_Rate_By_Id((SELECT t.rate_type_id
                                                               FROM ins.ven_rate_type t
                                                              WHERE t.brief = 'ЦБ')
                                                            ,ph.fund_id
                                                            ,(SELECT f.fund_id
                                                               FROM ins.ven_fund f
                                                              WHERE f.brief = 'RUR')
                                                            ,pp.notice_date))
          ,0)
      --,ph.agency_id                              
        INTO pol_act_num
            ,pol_act_prem
        FROM ins.ven_p_pol_header ph
        JOIN ins.ven_p_policy pp
          ON ph.policy_header_id = pp.pol_header_id
        JOIN ins.ven_t_sales_channel sch
          ON ph.sales_channel_id = sch.ID
       WHERE NVL(ph.agency_id, -1) LIKE d_id
         AND sch.brief LIKE rec.sh_br
         AND TO_CHAR((ins.doc.get_status_date(pp.policy_id, 'ACTIVE')), 'dd.mm.yyyy') =
             TO_CHAR(dright, 'dd.mm.yyyy');
    
      --  количество и премия договоров до отчетной даты, не ставших активными
    
      SELECT COUNT(TO_CHAR(ins.doc.get_doc_status_brief(pp.policy_id)))
             --as pol_out_num  -- pol_out_num
            ,NVL(SUM(pp.premium * ins.acc_new.Get_Cross_Rate_By_Id((SELECT t.rate_type_id
                                                                     FROM ins.ven_rate_type t
                                                                    WHERE t.brief = 'ЦБ')
                                                                  ,ph.fund_id
                                                                  ,(SELECT f.fund_id
                                                                     FROM ins.ven_fund f
                                                                    WHERE f.brief = 'RUR')
                                                                  ,pp.notice_date))
                ,0)
        INTO pol_out_num
            ,pol_out_prem
        FROM ins.ven_p_pol_header ph
        JOIN ins.ven_p_policy pp
          ON ph.policy_header_id = pp.pol_header_id
        JOIN ins.ven_t_sales_channel sch
          ON ph.sales_channel_id = sch.ID
       WHERE NVL(ph.agency_id, -1) LIKE d_id
         AND sch.brief LIKE rec.sh_br
         AND ins.doc.get_doc_status_brief(pp.policy_id) = ('PROJECT')
         AND ins.doc.get_doc_status_brief(pp.policy_id) != ('READY_TO_CANCEL')
         AND TO_CHAR(pp.notice_date, 'dd.mm.yyyy') = TO_CHAR(dright, 'dd.mm.yyyy');
      -- вычисляем значение переменных
      d_name := rec.dep_name;
    
      IF (NVL(ag_active_num_m, 1) <> 0)
      THEN
        prod_ag_act_not := rec.notice_num_m / ag_active_num_m;
      ELSE
        prod_ag_act_not := 0;
      END IF;
    
      IF (NVL(ag_active_num_m, 1) <> 0)
      THEN
        prod_ag_act_prem := rec.notice_prem_m / ag_active_num_m;
      ELSE
        prod_ag_act_prem := 0;
      END IF;
    
      IF (ag_tot_num_m <> 0)
      THEN
        prod_ag_tot_not := rec.notice_num_m / ag_tot_num_m;
      ELSE
        prod_ag_tot_not := 0;
      END IF;
    
      IF (ag_tot_num_m <> 0)
      THEN
        prod_ag_tot_prem := rec.notice_prem_m / ag_tot_num_m;
      ELSE
        prod_ag_tot_prem := 0;
      END IF;
    
      -- количество заявлений
      insert_row_to_rep_neb(dright, 'at date', d_name, 'Proposals received', 'Number', rec.notice_num);
    
      -- премия по заявлениям
      insert_row_to_rep_neb(dright
                           ,'at date'
                           ,d_name
                           ,'Proposals received'
                           ,'Premium'
                           ,rec.notice_prem);
    
      -- количество активных полисов
      insert_row_to_rep_neb(dright, 'at date', d_name, 'Active policies', 'Number', pol_act_num);
    
      -- премия по активным полисам
      insert_row_to_rep_neb(dright, 'at date', d_name, 'Active policies', 'Premium', pol_act_prem);
    
      -- количество невыпущенных полисов
      insert_row_to_rep_neb(dright, 'at date', d_name, 'Outstanding policies', 'Number', pol_out_num);
    
      -- премия по невыпущенным полисам
      insert_row_to_rep_neb(dright
                           ,'at date'
                           ,d_name
                           ,'Outstanding policies'
                           ,'Premium'
                           ,pol_out_prem);
    
      -- количество заявлений по месяцу
      insert_row_to_rep_neb(dright
                           ,'month to date'
                           ,d_name
                           ,'Proposals received'
                           ,'Number'
                           ,rec.notice_num_m);
    
      -- премия по заявлениям по месяцу
      insert_row_to_rep_neb(dright
                           ,'month to date'
                           ,d_name
                           ,'Proposals received'
                           ,'Premium'
                           ,rec.notice_prem_m);
    
      -- количество активных полисов по месяцу
      insert_row_to_rep_neb(dright
                           ,'month to date'
                           ,d_name
                           ,'Active policies'
                           ,'Number'
                           ,rec.pol_act_num_m);
    
      -- премия по активным полисам по месяцу
      insert_row_to_rep_neb(dright
                           ,'month to date'
                           ,d_name
                           ,'Active policies'
                           ,'Premium'
                           ,rec.pol_act_prem_m);
    
      -- количество невыпущенных полисов по месяцу
      insert_row_to_rep_neb(dright
                           ,'month to date'
                           ,d_name
                           ,'Outstanding policies'
                           ,'Number'
                           ,rec.pol_out_num_m);
    
      -- премия по невыпущенным полисам по месяцу
      insert_row_to_rep_neb(dright
                           ,'month to date'
                           ,d_name
                           ,'Outstanding policies'
                           ,'Premium'
                           ,rec.pol_out_prem_m);
    
      -- количество активных агентов
      insert_row_to_rep_neb(dright, 'month to date', d_name, 'Agents', 'Active', ag_active_num_m);
    
      insert_row_to_rep_neb(dright
                           ,'month to date'
                           ,d_name
                           ,'Agents'
                           ,'Agents contracts'
                           ,ag_tot_num_m);
    
      -- продуктивность активных агентов по заявлениям
      insert_row_to_rep_neb(dright
                           ,'month to date'
                           ,d_name
                           ,'Productivity per active agents'
                           ,'Number'
                           ,prod_ag_act_not);
    
      -- продуктивность активных агентов по премии
      insert_row_to_rep_neb(dright
                           ,'month to date'
                           ,d_name
                           ,'Productivity per active agents'
                           ,'Premium'
                           ,prod_ag_act_prem);
    
      -- продуктивность всех агентов по заявлениям
      insert_row_to_rep_neb(dright
                           ,'month to date'
                           ,d_name
                           ,'Productivity per all agents'
                           ,'Number'
                           ,prod_ag_tot_not);
    
      -- продуктивность всех агентов по премии
      insert_row_to_rep_neb(dright
                           ,'month to date'
                           ,d_name
                           ,'Productivity per all agents'
                           ,'Premium'
                           ,prod_ag_tot_prem);
    END LOOP;
    --*/
    COMMIT;
  END;

  -- Процедура вызывает формирование отчета New and Exsiting Business report на дату
  PROCEDURE create_day_neb2(dright DATE) IS
    -- столбцы на текущую дату
    notice_num   NUMBER := 0; -- количество заявлений
    notice_prem  NUMBER := 0; -- премия по заявлениям
    pol_act_num  NUMBER := 0; -- количество полисов, ставших активными
    pol_act_prem NUMBER := 0; -- премия по полисам, ставшими активными
    pol_out_num  NUMBER := 0; -- количество пропущенных полисов
    pol_out_prem NUMBER := 0; -- премия по пропущенным полисам
  
    -- столбцы по месяцу
    notice_num_m   NUMBER := 0; -- количество заявлений
    notice_prem_m  NUMBER := 0; -- премия по заявлениям
    pol_act_num_m  NUMBER := 0; -- количество полисов, ставших активными
    pol_act_prem_m NUMBER := 0; -- премия по полисам, ставшими активными
    pol_out_num_m  NUMBER := 0; -- количество пропущенных полисов
    pol_out_prem_m NUMBER := 0; -- премия по пропущенным полисам
  
    ag_active_num_m  NUMBER := 0; -- количество активных агентов
    ag_tot_num_m     NUMBER := 0; -- общее количество агентов
    prod_ag_act_not  NUMBER := 0; -- продуктивность активных агентов по заявлениям
    prod_ag_act_prem NUMBER := 0; -- продуктивность активных агентов по премии
    prod_ag_tot_not  NUMBER := 0; --продуктивность вех агентов по заявлениям
    prod_ag_tot_prem NUMBER := 0; -- продуктивность всех агентов по премии
  
    -- вспомогательные переменные
    row_day NUMBER := 0; -- для проверки существования записи
    d_id    VARCHAR2(10); -- для передачи id агенства
    ch_br   VARCHAR2(30); -- для передачи брифа канала продаж
    d_name  VARCHAR(250); -- для передачи имени агентсва
  
  BEGIN
    FOR rec IN (SELECT NAME
                      ,ag_id
                      ,ch_brief
                  FROM TABLE(pkg_rep_utils_ins11.get_list_departments_chanals(dright)))
    LOOP
      DBMS_OUTPUT.PUT_LINE('START для ' || d_name || ' Время: ' || TO_CHAR(SYSDATE, 'hh24:mi:ss'));
      -- считаем значение переменных
      -- ////////////////////////////////////////////////////////////////////////
      IF (rec.ag_id = -1)
      THEN
        d_id := '%';
      ELSE
        d_id := TO_CHAR(rec.ag_id);
      END IF;
    
      IF (rec.ch_brief IS NULL)
      THEN
        ch_br := '%';
      ELSE
        ch_br := rec.ch_brief;
      END IF;
    
      d_name := rec.NAME;
    
      -- текущая дата
      notice_num   := get_notice_num(dright, dright, d_id, ch_br);
      notice_prem  := get_notice_premium(dright, dright, d_id, ch_br);
      pol_act_num  := get_pol_active_num(dright, dright, d_id, ch_br);
      pol_act_prem := get_pol_active_premium(dright, dright, d_id, ch_br);
      pol_out_num  := get_notice_outside_num(dright, dright, d_id, ch_br);
      pol_out_prem := get_notice_outside_premium(dright, dright, d_id, ch_br);
      -- месяц
      notice_num_m   := get_notice_num(TRUNC(dright, 'mm'), dright, d_id, ch_br);
      notice_prem_m  := get_notice_premium(TRUNC(dright, 'mm'), dright, d_id, ch_br);
      pol_act_num_m  := get_pol_active_num(TRUNC(dright, 'mm'), dright, d_id, ch_br);
      pol_act_prem_m := get_pol_active_premium(TRUNC(dright, 'mm'), dright, d_id, ch_br);
      pol_out_num_m  := get_notice_outside_num(TRUNC(dright, 'mm'), dright, d_id, ch_br);
      pol_out_prem_m := get_notice_outside_premium(TRUNC(dright, 'mm'), dright, d_id, ch_br);
    
      ag_active_num_m := get_agent_have_sales_num(TRUNC(dright, 'mm'), dright, d_id, ch_br);
      ag_tot_num_m    := get_total_agent_number(dright, d_id, ch_br);
    
      IF (ag_active_num_m <> 0)
      THEN
        prod_ag_act_not := notice_num_m / ag_active_num_m;
      ELSE
        prod_ag_act_not := 0;
      END IF;
    
      IF (ag_active_num_m <> 0)
      THEN
        prod_ag_act_prem := notice_prem_m / ag_active_num_m;
      ELSE
        prod_ag_act_prem := 0;
      END IF;
    
      IF (ag_tot_num_m <> 0)
      THEN
        prod_ag_tot_not := notice_num_m / ag_tot_num_m;
      ELSE
        prod_ag_act_not := 0;
      END IF;
    
      IF (ag_tot_num_m <> 0)
      THEN
        prod_ag_tot_prem := notice_prem_m / ag_tot_num_m;
      ELSE
        prod_ag_act_prem := 0;
      END IF;
    
      -- проверяем существование даты для региона
      -- ////////////////////////////////////////////////////////////////////////
      SELECT COUNT(*)
        INTO row_day
        FROM ins_dwh.rep_neb rn
       WHERE rn.DAY = dright
         AND rn.region = d_name;
      IF row_day = 0
      THEN
        -- количество заявлений
        insert_row_to_rep_neb(dright, 'at date', d_name, 'Proposals received', 'Number', notice_num);
        --dbms_output.put_line('+ Proposals received number(D) для ' || d_name || ' Время: ' || to_char(sysdate, 'hh24:mi:ss'));
        -- премия по заявлениям
        insert_row_to_rep_neb(dright, 'at date', d_name, 'Proposals received', 'Premium', notice_prem);
        --dbms_output.put_line('+ Proposals received premium(D) для ' || d_name || ' Время: ' || to_char(sysdate, 'hh24:mi:ss'));
        -- количество активных полисов
        insert_row_to_rep_neb(dright, 'at date', d_name, 'Active policies', 'Number', pol_act_num);
        --dbms_output.put_line('+ Active policies number для(D) ' || d_name || ' Время: ' || to_char(sysdate, 'hh24:mi:ss'));
        -- премия по активным полисам
        insert_row_to_rep_neb(dright, 'at date', d_name, 'Active policies', 'Premium', pol_act_prem);
        --dbms_output.put_line('+ Active policies premium(D) для ' || d_name || ' Время: ' || to_char(sysdate, 'hh24:mi:ss'));
        -- количество невыпущенных полисов
        insert_row_to_rep_neb(dright
                             ,'at date'
                             ,d_name
                             ,'Outstanding policies'
                             ,'Number'
                             ,pol_out_num);
        --dbms_output.put_line('+ Outstanding policies number(D) для ' || d_name || ' Время: ' || to_char(sysdate, 'hh24:mi:ss'));
        -- премия по невыпущенным полисам
        insert_row_to_rep_neb(dright
                             ,'at date'
                             ,d_name
                             ,'Outstanding policies'
                             ,'Premium'
                             ,pol_out_prem);
        --dbms_output.put_line('+ Outstanding policies premium(D) для ' || d_name || ' Время: ' || to_char(sysdate, 'hh24:mi:ss'));
      
        -- количество заявлений по месяцу
        insert_row_to_rep_neb(dright
                             ,'month to date'
                             ,d_name
                             ,'Proposals received'
                             ,'Number'
                             ,notice_num_m);
        --dbms_output.put_line('+ Proposals received number(M) для ' || d_name || ' Время: ' || to_char(sysdate, 'hh24:mi:ss'));
        -- премия по заявлениям по месяцу
        insert_row_to_rep_neb(dright
                             ,'month to date'
                             ,d_name
                             ,'Proposals received'
                             ,'Premium'
                             ,notice_prem_m);
        --dbms_output.put_line('+ Proposals received premium(M) для ' || d_name || ' Время: ' || to_char(sysdate, 'hh24:mi:ss'));
        -- количество активных полисов по месяцу
        insert_row_to_rep_neb(dright
                             ,'month to date'
                             ,d_name
                             ,'Active policies'
                             ,'Number'
                             ,pol_act_num_m);
        --dbms_output.put_line('+ Active policies number(M) для ' || d_name || ' Время: ' || to_char(sysdate, 'hh24:mi:ss'));
        -- премия по активным полисам по месяцу
        insert_row_to_rep_neb(dright
                             ,'month to date'
                             ,d_name
                             ,'Active policies'
                             ,'Premium'
                             ,pol_act_prem_m);
        --dbms_output.put_line('+ Active policies premium(M) для ' || d_name || ' Время: ' || to_char(sysdate, 'hh24:mi:ss'));
        -- количество невыпущенных полисов по месяцу
        insert_row_to_rep_neb(dright
                             ,'month to date'
                             ,d_name
                             ,'Outstanding policies'
                             ,'Number'
                             ,pol_out_num_m);
        --dbms_output.put_line('+ Outstanding policies number(M) для ' || d_name || ' Время: ' || to_char(sysdate, 'hh24:mi:ss'));
        -- премия по невыпущенным полисам по месяцу
        insert_row_to_rep_neb(dright
                             ,'month to date'
                             ,d_name
                             ,'Outstanding policies'
                             ,'Premium'
                             ,pol_out_prem_m);
        --dbms_output.put_line('+ Outstanding policies premium(M) для ' || d_name || ' Время: ' || to_char(sysdate, 'hh24:mi:ss'));
      
        -- количество активных агентов
        insert_row_to_rep_neb(dright, 'month to date', d_name, 'Agents', 'Active', ag_active_num_m);
        --dbms_output.put_line('+ Agents active(M) для ' || d_name || ' Время: ' || to_char(sysdate, 'hh24:mi:ss'));
        -- общее количество агентов
        insert_row_to_rep_neb(dright
                             ,'month to date'
                             ,d_name
                             ,'Agents'
                             ,'Agents contracts'
                             ,ag_tot_num_m);
        --dbms_output.put_line('+ Agents total(M) для ' || d_name || ' Время: ' || to_char(sysdate, 'hh24:mi:ss'));
        -- продуктивность активных агентов по заявлениям
        insert_row_to_rep_neb(dright
                             ,'month to date'
                             ,d_name
                             ,'Productivity per active agents'
                             ,'Number'
                             ,prod_ag_act_not);
        --dbms_output.put_line('+ Productivity number(M) для ' || d_name || ' Время: ' || to_char(sysdate, 'hh24:mi:ss'));
        -- продуктивность активных агентов по премии
        insert_row_to_rep_neb(dright
                             ,'month to date'
                             ,d_name
                             ,'Productivity per active agents'
                             ,'Premium'
                             ,prod_ag_act_prem);
        --dbms_output.put_line('+ Productivity premium(M) для ' || d_name || ' Время: ' || to_char(sysdate, 'hh24:mi:ss'));
        -- продуктивность всех агентов по заявлениям
        insert_row_to_rep_neb(dright
                             ,'month to date'
                             ,d_name
                             ,'Productivity per all agents'
                             ,'Number'
                             ,prod_ag_tot_not);
        --dbms_output.put_line('+ Productivity total number(M) для ' || d_name || ' Время: ' || to_char(sysdate, 'hh24:mi:ss'));
        -- продуктивность всех агентов по премии
        insert_row_to_rep_neb(dright
                             ,'month to date'
                             ,d_name
                             ,'Productivity per all agents'
                             ,'Premium'
                             ,prod_ag_tot_prem);
        --dbms_output.put_line('+ Productivity total premium(M) для ' || d_name || ' Время: ' || to_char(sysdate, 'hh24:mi:ss'));
      ELSE
        -- количество заявлений
        update_row_to_rep_neb(dright, 'at date', d_name, 'Proposals received', 'Number', notice_num);
        -- премия по заявлениям
        update_row_to_rep_neb(dright, 'at date', d_name, 'Proposals received', 'Premium', notice_prem);
        -- количество активных полисов
        update_row_to_rep_neb(dright, 'at date', d_name, 'Active policies', 'Number', pol_act_num);
        -- премия по активным полисам
        update_row_to_rep_neb(dright, 'at date', d_name, 'Active policies', 'Premium', pol_act_prem);
        -- количество невыпущенных полисов
        update_row_to_rep_neb(dright
                             ,'at date'
                             ,d_name
                             ,'Outstanding policies'
                             ,'Number'
                             ,pol_out_num);
        -- премия по невыпущенным полисам
        update_row_to_rep_neb(dright
                             ,'at date'
                             ,d_name
                             ,'Outstanding policies'
                             ,'Premium'
                             ,pol_out_prem);
      
        -- количество заявлений по месяцу
        update_row_to_rep_neb(dright
                             ,'month to date'
                             ,d_name
                             ,'Proposals received'
                             ,'Number'
                             ,notice_num_m);
        -- премия по заявлениям по месяцу
        update_row_to_rep_neb(dright
                             ,'month to date'
                             ,d_name
                             ,'Proposals received'
                             ,'Premium'
                             ,notice_prem_m);
        -- количество активных полисов по месяцу
        update_row_to_rep_neb(dright
                             ,'month to date'
                             ,d_name
                             ,'Active policies'
                             ,'Number'
                             ,pol_act_num_m);
        -- премия по активным полисам по месяцу
        update_row_to_rep_neb(dright
                             ,'month to date'
                             ,d_name
                             ,'Active policies'
                             ,'Premium'
                             ,pol_act_prem_m);
        -- количество невыпущенных полисов по месяцу
        update_row_to_rep_neb(dright
                             ,'month to date'
                             ,d_name
                             ,'Outstanding policies'
                             ,'Number'
                             ,pol_out_num_m);
        -- премия по невыпущенным полисам по месяцу
        update_row_to_rep_neb(dright
                             ,'month to date'
                             ,d_name
                             ,'Outstanding policies'
                             ,'Premium'
                             ,pol_out_prem_m);
      
        -- количество активных агентов
        update_row_to_rep_neb(dright, 'month to date', d_name, 'Agents', 'Active', ag_active_num_m);
        -- общее количество агентов
        update_row_to_rep_neb(dright
                             ,'month to date'
                             ,d_name
                             ,'Agents'
                             ,'Agents contracts'
                             ,ag_tot_num_m);
        -- продуктивность активных агентов по заявлениям
        update_row_to_rep_neb(dright
                             ,'month to date'
                             ,d_name
                             ,'Productivity per active agents'
                             ,'Number'
                             ,prod_ag_act_not);
        -- продуктивность активных агентов по премии
        update_row_to_rep_neb(dright
                             ,'month to date'
                             ,d_name
                             ,'Productivity per active agents'
                             ,'Premium'
                             ,prod_ag_act_prem);
        -- продуктивность всех агентов по заявлениям
        update_row_to_rep_neb(dright
                             ,'month to date'
                             ,d_name
                             ,'Productivity per all agents'
                             ,'Number'
                             ,prod_ag_tot_not);
        -- продуктивность всех агентов по премии
        update_row_to_rep_neb(dright
                             ,'month to date'
                             ,d_name
                             ,'Productivity per all agents'
                             ,'Premium'
                             ,prod_ag_tot_prem);
      END IF;
      --dbms_output.put_line('FINISH для ' || d_name || ' Время: ' || to_char(sysdate, 'hh24:mi:ss'));
    END LOOP;
    --dbms_output.put_line('Остался commit! время: ' || to_char(sysdate, 'hh24:mi:ss'));
    COMMIT;
    --dbms_output.put_line('Успешно завершено! время: ' || to_char(sysdate, 'hh24:mi:ss'));
  END;

  -- ************************************************************************
  --/////////////////////////END NEW and EXISTING BUSINESS REPORT////////////
  -- ************************************************************************

  -- ************************************************************************
  --///////////////////////// Отчет по выплатам //////////////////////////
  -- ************************************************************************

  -- Возвращает таблицу с id претензий (c_claim_header)
  -- с заданными названием и типом риска
  FUNCTION get_claim_header_id
  (
    br    VARCHAR2
   ,rtype VARCHAR2
  ) RETURN tbl_claim_id
    PIPELINED IS
    rt NUMBER;
  BEGIN
    -- вычисляем флаг группы
    IF (rtype = 'GL')
    THEN
      rt := 1;
    ELSE
      IF (rtype = 'IL')
      THEN
        rt := 0;
      END IF;
    END IF;
    -- запрос id претензий
    FOR cl_rec IN (SELECT clh.*
                     FROM ins.ven_c_claim_header clh
                     JOIN ins.ven_p_policy pp
                       ON clh.p_policy_id = pp.policy_id
                     JOIN ins.ven_t_peril tp
                       ON tp.ID = clh.peril_id
                    WHERE pp.is_group_flag LIKE rt
                      AND tp.brief LIKE br)
    LOOP
      PIPE ROW(cl_rec.c_claim_header_id);
    END LOOP;
    RETURN;
  END;

  -- Возвращает количество претензий, поступивших в указанный период
  -- с фильтром по названию и типу риска
  FUNCTION get_claim_number
  (
    br     VARCHAR2
   ,rtype  VARCHAR2
   ,dleft  DATE
   ,dright DATE
  ) RETURN NUMBER IS
    num NUMBER;
  BEGIN
    SELECT COUNT(*)
      INTO num
      FROM ins.ven_c_claim_header clh
      JOIN (SELECT * FROM TABLE(pkg_rep_utils_ins11.get_claim_header_id(br, rtype))) clh_id
        ON clh.c_claim_header_id = clh_id.COLUMN_VALUE
      JOIN ins.ven_c_event ce
        ON ce.c_event_id = clh.c_event_id
     WHERE ce.date_company BETWEEN dleft AND dright;
    RETURN(num);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  -- Возвращает количество уведомлений, пришедших в указанный год, оплаченных в указанный период
  -- с фильтром по названию и типу риска
  FUNCTION get_claim_pay_number
  (
    br     VARCHAR2
   ,rtype  VARCHAR2
   ,YEAR   VARCHAR2
   ,dleft  DATE
   ,dright DATE
  ) RETURN NUMBER IS
    num NUMBER;
  BEGIN
    SELECT COUNT(*)
      INTO num
      FROM ins.ven_c_claim_header clh
      JOIN (SELECT * FROM TABLE(pkg_rep_utils_ins11.get_claim_header_id(br, rtype))) clh_id
        ON clh.c_claim_header_id = clh_id.COLUMN_VALUE
      JOIN ins.ven_c_event ce
        ON ce.c_event_id = clh.c_event_id
      JOIN ins.ven_c_claim cc
        ON cc.c_claim_id = clh.active_claim_id
     WHERE TO_CHAR(ce.date_company, 'yyyy') LIKE YEAR
       AND ins.pkg_claim_payment.get_claim_pay_sum_per(cc.c_claim_id, dleft, dright) > 0;
    RETURN(num);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  -- Возвращает сумму по проводкам по делам, пришедшим в указанный год, оплаченных в указанный период
  -- с фильтром по названию и типу риска
  FUNCTION get_claim_pay_amount
  (
    br     VARCHAR2
   ,rtype  VARCHAR2
   ,YEAR   VARCHAR2
   ,dleft  DATE
   ,dright DATE
  ) RETURN NUMBER IS
    amount NUMBER(11, 2);
  BEGIN
    SELECT SUM(ins.pkg_claim_payment.get_claim_pay_sum_per(cc.c_claim_id, dleft, dright))
      INTO amount
      FROM ins.ven_c_claim_header clh
      JOIN (SELECT * FROM TABLE(pkg_rep_utils_ins11.get_claim_header_id(br, rtype))) clh_id
        ON clh.c_claim_header_id = clh_id.COLUMN_VALUE
      JOIN ins.ven_c_event ce
        ON ce.c_event_id = clh.c_event_id
      JOIN ins.ven_c_claim cc
        ON cc.c_claim_id = clh.active_claim_id
     WHERE TO_CHAR(ce.date_company, 'yyyy') LIKE YEAR
       AND ins.pkg_claim_payment.get_claim_pay_sum_per(cc.c_claim_id, dleft, dright) > 0;
    RETURN(TO_CHAR(amount, '999999999D99'));
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  -- Возвращает количество уведомлений, поступивших в указанном году, находящихся на рассмотрении
  -- с фильтром по названию и типу риска
  FUNCTION get_claim_pending_number
  (
    br    VARCHAR2
   ,rtype VARCHAR2
   ,YEAR  VARCHAR2
  ) RETURN NUMBER IS
    num NUMBER;
  BEGIN
    SELECT COUNT(*)
      INTO num
      FROM ins.ven_c_claim_header clh
      JOIN (SELECT * FROM TABLE(pkg_rep_utils_ins11.get_claim_header_id(br, rtype))) clh_id
        ON clh.c_claim_header_id = clh_id.COLUMN_VALUE
      JOIN ins.ven_c_claim cc
        ON cc.c_claim_id = clh.active_claim_id
      JOIN ins.ven_c_event ce
        ON ce.c_event_id = clh.c_event_id
     WHERE ins.doc.get_doc_status_brief(cc.c_claim_id) != 'CLOSE'
       AND TO_CHAR(ce.date_company, 'yyyy') = YEAR;
    RETURN(num);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  -- Возвращает запланированную сумму к выплате по делам, поступившим в указанный год
  -- с фильтром по названию и типу риска
  FUNCTION get_panding_claims_amount
  (
    br    VARCHAR2
   ,rtype VARCHAR2
   ,YEAR  VARCHAR2
  ) RETURN NUMBER IS
    amount NUMBER(11, 2);
  BEGIN
    SELECT SUM(ins.pkg_claim_payment.get_claim_plan_sum(cc.c_claim_id))
      INTO amount
      FROM ins.ven_c_claim_header clh
      JOIN (SELECT * FROM TABLE(pkg_rep_utils_ins11.get_claim_header_id(br, rtype))) clh_id
        ON clh.c_claim_header_id = clh_id.COLUMN_VALUE
      JOIN ins.ven_c_event ce
        ON ce.c_event_id = clh.c_event_id
      JOIN ins.ven_c_claim cc
        ON cc.c_claim_id = clh.active_claim_id
     WHERE TO_CHAR(ce.date_company, 'yyyy') = YEAR;
    RETURN(TO_CHAR(amount, '999999999D99'));
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
  END;

  -- Возврашает количество дел, в которых отказано из числа поступивших в указанном году
  FUNCTION get_rejected_claims_number
  (
    br     VARCHAR2
   ,rtype  VARCHAR2
   ,YEAR   VARCHAR2
   ,dleft  DATE
   ,dright DATE
  ) RETURN NUMBER IS
    num NUMBER;
  BEGIN
    SELECT COUNT(*)
      INTO num
      FROM ins.ven_c_claim_header clh
      JOIN (SELECT * FROM TABLE(pkg_rep_utils_ins11.get_claim_header_id(br, rtype))) clh_id
        ON clh.c_claim_header_id = clh_id.COLUMN_VALUE
      JOIN ins.ven_c_claim cc
        ON cc.c_claim_id = clh.active_claim_id
      JOIN ins.ven_c_event ce
        ON ce.c_event_id = clh.c_event_id
     WHERE ins.doc.get_doc_status_brief(cc.c_claim_id) = 'CLOSE'
       AND NVL(ins.pkg_claim_payment.get_claim_payment_sum(cc.c_claim_id), 0) = 0
          --or ins.pkg_claim_payment.get_claim_payment_sum (cc.c_claim_id) is null)
       AND TO_CHAR(ce.date_company, 'yyyy') LIKE YEAR
       AND ins.doc.get_status_date(cc.c_claim_id, 'CLOSE') BETWEEN dleft AND dright;
    RETURN(num);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  -- Возвращает сумму по делам, отказанным в указанном году
  FUNCTION get_rejected_claims_amount
  (
    br     VARCHAR2
   ,rtype  VARCHAR2
   ,dleft  DATE
   ,dright DATE
  ) RETURN NUMBER IS
    amount NUMBER(11, 2);
  BEGIN
    SELECT SUM(ins.pkg_claim_payment.get_claim_plan_sum(cc.c_claim_id))
      INTO amount
      FROM ins.ven_c_claim_header clh
      JOIN (SELECT * FROM TABLE(pkg_rep_utils_ins11.get_claim_header_id(br, rtype))) clh_id
        ON clh.c_claim_header_id = clh_id.COLUMN_VALUE
      JOIN ins.ven_c_claim cc
        ON cc.c_claim_id = clh.active_claim_id
     WHERE ins.doc.get_doc_status_brief(cc.c_claim_id) = 'CLOSE'
       AND NVL(ins.pkg_claim_payment.get_claim_payment_sum(cc.c_claim_id), 0) = 0
          --or ins.pkg_claim_payment.get_claim_payment_sum (cc.c_claim_id) is null)
       AND ins.doc.get_status_date(cc.c_claim_id, 'CLOSE') BETWEEN dleft AND dright;
    RETURN(TO_CHAR(amount, '999999999D99'));
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
  END;

  -- добавляет строку в таблицу rep_payoff
  PROCEDURE insert_row_to_rep_payoff
  (
    fyear       VARCHAR2
   ,fmonth      VARCHAR2
   ,frisk_type  VARCHAR2
   ,frisk       VARCHAR2
   ,fparam      VARCHAR2
   ,fvalue      NUMBER
   ,frisk_brief VARCHAR2
   ,ftype_brief VARCHAR2
  ) IS
  BEGIN
    INSERT INTO ins_dwh.rep_payoff rp
      (YEAR, MONTH, risk_type, risk, param, VALUE, risk_brief, type_brief)
    VALUES
      (fyear, fmonth, frisk_type, frisk, fparam, fvalue, frisk_brief, ftype_brief);
  END;

  -- обновляет строку в таблицу rep_payoff
  PROCEDURE update_row_to_rep_payoff
  (
    fyear       VARCHAR2
   ,fmonth      VARCHAR2
   ,fparam      VARCHAR2
   ,fvalue      NUMBER
   ,frisk_brief VARCHAR2
   ,ftype_brief VARCHAR2
  ) IS
  BEGIN
    UPDATE ins_dwh.rep_payoff rp
       SET rp.VALUE = fvalue
     WHERE rp.YEAR = fyear
       AND rp.MONTH = fmonth
       AND rp.risk_brief = frisk_brief
       AND rp.type_brief = ftype_brief
       AND rp.param = fparam;
  END;

  -- Осуществляет добавление всех строк в таблицу ins_dwh.rep_payoff для одного риска
  PROCEDURE insert_rep_payoff
  (
    tmonth   VARCHAR2
   ,tyear    VARCHAR2
   ,frisk    VARCHAR2
   ,frisk_br VARCHAR2
   ,ft_gr    VARCHAR2
  ) IS
    -- столбцы на текущую дату
    claim_num         NUMBER; -- количество претензий за месяц
    claim_num_ytd     NUMBER; -- количество претензий с накопленным итогом
    claim_pay_num     NUMBER; -- количество оплаченных претензий за месяц по годам
    claim_pay_sum     NUMBER; -- сумма по оплаченным претензиям за месяц по годам
    claim_pay_num_ytd NUMBER; -- количество оплаченных дел с накопленным итогом
    retr_pay_num      NUMBER; -- количество оплаченных дел за ретроспектиыне года
    retr_pay_sum      NUMBER; -- оплаченная сумма по делам за ретроспеткивные года
    claim_panding_num NUMBER; -- количество дел на рассмотрении
    claim_panding_sum NUMBER; -- сумма к выплате
    retr_panding_num  NUMBER; -- количество дел на рассмотрении за ретроспективные года
    retr_panding_sum  NUMBER; -- сумма к выплате за ретроспективные года
    gr_risk           NUMBER; -- сумма к выплате по всем групповым рискам
    ind_risk          NUMBER; -- сумма к выплате по всем индивидуальным рискам
    --tot_risk number; -- сумма к выплате по ВСЕМ  рискам
    retr_gr_risk      NUMBER; -- сумма к выплате по всем групповым рискам в ретроспективе
    retr_ind_risk     NUMBER; -- сумма к выплате по всем индивидуальным рискам в ретроспективе
    retr_tot_risk     NUMBER; -- сумма к выплате по ВСЕМ  рискам в ретроспективе
    claim_rej_num     NUMBER; -- количество отказанных дел
    retr_rej_num      NUMBER; -- количество отказанных дел в ретроспективе
    claim_rej_num_ytd NUMBER; -- количество отказанных дел с накопленным итогом
    claim_rej_sum_ytd NUMBER; -- сумма по отказанным делам с накопленным итогом
  
    -- вспомогательные переменные
    first_day  DATE; --  первый день месяца
    LAST_DAY   DATE; -- последний день месяца
    y          NUMBER; -- год ретроспективы
    k          NUMBER; -- количество лет ретроспективы
    ft_gr_name VARCHAR2(50); -- название риска
  
  BEGIN
    -- определяем название типа риска
    IF (ft_gr = 'GL')
    THEN
      ft_gr_name := 'Group Life';
    ELSE
      IF (ft_gr = 'IL')
      THEN
        ft_gr_name := 'Individual Life';
      END IF;
    END IF;
    -- определяем первую и последнюю даты месяца
    first_day := TO_DATE('01.' || tmonth || '.' || tyear, 'dd.mm.yyyy');
    LAST_DAY  := ADD_MONTHS(first_day, 1) - 1;
    -- количество лет рестроспективы
    IF (TO_NUMBER(tyear) > 2007)
    THEN
      k := 3; -- начиная с 2008 года рассматриваем 3 предыдущих года
    ELSE
      k := 2; -- если год 2007, то рассматриваем только 2 предыдущих года
    END IF;
  
    -- считаем зарезервированные суммы по групповым, индивидуальным рискам
    -- ///////////////////////////////////////////////////////////////////
    y := TO_NUMBER(tyear);
    FOR l IN 0 .. k - 1
    LOOP
      -- зарезервированная сумма по всем групповым рискам
      gr_risk      := get_panding_claims_amount('%', 'GL', TO_CHAR(y));
      retr_gr_risk := retr_gr_risk + gr_risk;
    
      ind_risk      := get_panding_claims_amount('%', 'IL', TO_CHAR(y));
      retr_ind_risk := retr_ind_risk + ind_risk;
      -- зарезервированная сумма по всем индивидуальным рискам
    
      -- зарезервированная сумма по ВСЕМ рискам
      y := y - 1;
    END LOOP;
  
    -- ДОБАВЛЯЕМ СТРОКИ
    -- ////////////////////////////////////////////////////////////////////////////
  
    -- количество претензий
    claim_num := get_claim_number(frisk_br, ft_gr, first_day, LAST_DAY);
    insert_row_to_rep_payoff(tyear
                            ,tmonth
                            ,ft_gr_name
                            ,frisk
                            ,'number of notifications'
                            ,claim_num
                            ,frisk_br
                            ,ft_gr);
  
    -- количество претензий с накопленным итогом с начала года
    claim_num_ytd := get_claim_number(frisk_br
                                     ,ft_gr
                                     ,TO_DATE('01.01.' || tyear, 'dd.mm.yyyy')
                                     ,LAST_DAY);
    insert_row_to_rep_payoff(tyear
                            ,tmonth
                            ,ft_gr_name
                            ,frisk
                            ,'number of notifications accumulated ' || tyear
                            ,claim_num_ytd
                            ,frisk_br
                            ,ft_gr);
  
    -- ретроспектива по оплаченным делам
    y := TO_NUMBER(tyear);
    FOR j IN 0 .. k - 1
    LOOP
      -- количество оплаченных дел
      claim_pay_num := get_claim_pay_number(frisk_br, ft_gr, TO_CHAR(y), first_day, LAST_DAY);
      insert_row_to_rep_payoff(tyear
                              ,tmonth
                              ,ft_gr_name
                              ,frisk
                              ,'number of claims ' || y || ' paid'
                              ,claim_pay_num
                              ,frisk_br
                              ,ft_gr);
      -- сумма по оплаченным делам
      claim_pay_sum := get_claim_pay_amount(frisk_br, ft_gr, TO_CHAR(y), first_day, LAST_DAY);
      insert_row_to_rep_payoff(tyear
                              ,tmonth
                              ,ft_gr_name
                              ,frisk
                              ,'amount of claims ' || y || ' paid'
                              ,claim_pay_sum
                              ,frisk_br
                              ,ft_gr);
      -- итог по ретроспектиным годам - число дел
      retr_pay_num := retr_pay_num + claim_pay_num;
      -- итог по ретроспективным годам - сумма
      retr_pay_sum := retr_pay_sum + claim_pay_sum;
      y            := y - 1;
    END LOOP;
  
    -- добавляем итог по ретроспектиным годам - число дел
    insert_row_to_rep_payoff(tyear
                            ,tmonth
                            ,ft_gr_name
                            ,frisk
                            ,'number of claims paid in TOTAL'
                            ,retr_pay_num
                            ,frisk_br
                            ,ft_gr);
    -- добавляем итог по ретроспективным годам - сумма
    insert_row_to_rep_payoff(tyear
                            ,tmonth
                            ,ft_gr_name
                            ,frisk
                            ,'accumulated claims paid amount in ' || tyear
                            ,retr_pay_sum
                            ,frisk_br
                            ,ft_gr);
  
    -- количество оплаченных итогов за текущий год
    claim_pay_num_ytd := get_claim_pay_number(frisk_br
                                             ,ft_gr
                                             ,'%'
                                             ,TO_DATE('01.01.' || tyear, 'dd.mm.yyyy')
                                             ,LAST_DAY);
    insert_row_to_rep_payoff(tyear
                            ,tmonth
                            ,ft_gr_name
                            ,frisk
                            ,'accumulated number of claims paid in ' || tyear
                            ,claim_pay_num_ytd
                            ,frisk_br
                            ,ft_gr);
  
    -- дела на рассмотрении в рестроспективе
    y := TO_NUMBER(tyear);
    FOR j IN 0 .. k - 1
    LOOP
      -- количество дел на рассмотрении
      claim_panding_num := get_claim_pending_number(frisk_br, ft_gr, TO_CHAR(y));
      insert_row_to_rep_payoff(tyear
                              ,tmonth
                              ,ft_gr_name
                              ,frisk
                              ,'number of pending claims ' || y
                              ,claim_panding_num
                              ,frisk_br
                              ,ft_gr);
      --количество дел на рассмотреии в ретроспективе
      retr_panding_num := retr_panding_num + claim_panding_num;
      y                := y - 1;
    END LOOP;
    -- добавляем количество дел на рассмотреии в ретроспективе
    insert_row_to_rep_payoff(tyear
                            ,tmonth
                            ,ft_gr_name
                            ,frisk
                            ,'number of panding claims in TOTAL'
                            ,retr_panding_num
                            ,frisk_br
                            ,ft_gr);
  
    -- зарезервированная сумма в рестроспективе
    y := TO_NUMBER(tyear);
    FOR j IN 0 .. k - 1
    LOOP
      -- зарезервированная сумма
      claim_panding_sum := get_panding_claims_amount(frisk_br, ft_gr, TO_CHAR(y));
      insert_row_to_rep_payoff(tyear
                              ,tmonth
                              ,ft_gr_name
                              ,frisk
                              ,'amount of panding claims ' || y
                              ,claim_panding_num
                              ,frisk_br
                              ,ft_gr);
      -- зарезервированная сумма в ретроспективе
      retr_panding_sum := retr_panding_sum + claim_panding_sum;
      y                := y - 1;
    END LOOP;
    -- добавляем зарезервированную сумму в ретроспективе
    insert_row_to_rep_payoff(tyear
                            ,tmonth
                            ,ft_gr_name
                            ,frisk
                            ,'amount of panding claims in TOTAL'
                            ,retr_panding_sum
                            ,frisk_br
                            ,ft_gr);
  
    -- добавляем процент от всех групповых рисков
    IF (retr_gr_risk != 0)
    THEN
      insert_row_to_rep_payoff(tyear
                              ,tmonth
                              ,ft_gr_name
                              ,frisk
                              ,'percent of all groop claims in a period'
                              ,(retr_panding_sum / retr_gr_risk)
                              ,frisk_br
                              ,ft_gr);
    ELSE
      insert_row_to_rep_payoff(tyear
                              ,tmonth
                              ,ft_gr_name
                              ,frisk
                              ,'percent of all groop claims in a period'
                              ,0
                              ,frisk_br
                              ,ft_gr);
    END IF;
  
    -- добавляем процент от ВСЕХ рисков
    IF (retr_tot_risk != 0)
    THEN
      insert_row_to_rep_payoff(tyear
                              ,tmonth
                              ,ft_gr_name
                              ,frisk
                              ,'percent of all claims in a period'
                              ,(retr_panding_sum / retr_tot_risk)
                              ,frisk_br
                              ,ft_gr);
    ELSE
      insert_row_to_rep_payoff(tyear
                              ,tmonth
                              ,ft_gr_name
                              ,frisk
                              ,'percent of all claims in a period'
                              ,0
                              ,frisk_br
                              ,ft_gr);
    END IF;
  
    -- количество отказанных дел
    y := TO_NUMBER(tyear);
    FOR j IN 0 .. k - 1
    LOOP
      -- количество отказанных дел
      claim_rej_num := get_rejected_claims_number(frisk_br, ft_gr, TO_CHAR(y), first_day, LAST_DAY);
      insert_row_to_rep_payoff(tyear
                              ,tmonth
                              ,ft_gr_name
                              ,frisk
                              ,'number of rejected claims ' || y
                              ,claim_rej_num
                              ,frisk_br
                              ,ft_gr);
      -- количество отказанных дел в ретроспективе
      retr_rej_num := retr_rej_num + claim_rej_num;
      y            := y - 1;
    END LOOP;
    -- добавляем количество отказанных дел в ретроспективе
    insert_row_to_rep_payoff(tyear
                            ,tmonth
                            ,ft_gr_name
                            ,frisk
                            ,'number of rejected claims in TOTAL'
                            ,retr_rej_num
                            ,frisk_br
                            ,ft_gr);
  
    -- количество отказанных дел с нарастающим итогом
    claim_rej_num_ytd := get_rejected_claims_number(frisk_br
                                                   ,ft_gr
                                                   ,'%'
                                                   ,TO_DATE('01.01.' || tyear, 'dd.mm.yyyy')
                                                   ,LAST_DAY);
    insert_row_to_rep_payoff(tyear
                            ,tmonth
                            ,ft_gr_name
                            ,frisk
                            ,'number of rejected claims accumulated ' || tyear
                            ,claim_rej_num_ytd
                            ,frisk_br
                            ,ft_gr);
  
    -- сумма по отказанным делам с нарастающим итогом
    claim_rej_sum_ytd := get_rejected_claims_amount(frisk_br
                                                   ,ft_gr
                                                   ,TO_DATE('01.01.' || tyear, 'dd.mm.yyyy')
                                                   ,LAST_DAY);
    insert_row_to_rep_payoff(tyear
                            ,tmonth
                            ,ft_gr_name
                            ,frisk
                            ,'amount of rejected claims'
                            ,claim_rej_sum_ytd
                            ,frisk_br
                            ,ft_gr);
  END;

  -- Осуществляет обновление всех строк в таблицу ins_dwh.rep_payoff для одного риска
  PROCEDURE update_rep_payoff
  (
    tmonth   VARCHAR2
   ,tyear    VARCHAR2
   ,frisk_br VARCHAR2
   ,ft_gr    VARCHAR2
  ) IS
    -- столбцы на текущую дату
    claim_num         NUMBER; -- количество претензий за месяц
    claim_num_ytd     NUMBER; -- количество претензий с накопленным итогом
    claim_pay_num     NUMBER; -- количество оплаченных претензий за месяц по годам
    claim_pay_sum     NUMBER; -- сумма по оплаченным претензиям за месяц по годам
    claim_pay_num_ytd NUMBER; -- количество оплаченных дел с накопленным итогом
    retr_pay_num      NUMBER; -- количество оплаченных дел за ретроспектиыне года
    retr_pay_sum      NUMBER; -- оплаченная сумма по делам за ретроспеткивные года
    claim_panding_num NUMBER; -- количество дел на рассмотрении
    claim_panding_sum NUMBER; -- сумма к выплате
    retr_panding_num  NUMBER; -- количество дел на рассмотрении за ретроспективные года
    retr_panding_sum  NUMBER; -- сумма к выплате за ретроспективные года
    gr_risk           NUMBER; -- сумма к выплате по всем групповым рискам
    ind_risk          NUMBER; -- сумма к выплате по всем индивидуальным рискам
    --tot_risk number; -- сумма к выплате по ВСЕМ  рискам
    retr_gr_risk      NUMBER; -- сумма к выплате по всем групповым рискам в ретроспективе
    retr_ind_risk     NUMBER; -- сумма к выплате по всем индивидуальным рискам в ретроспективе
    retr_tot_risk     NUMBER; -- сумма к выплате по ВСЕМ  рискам в ретроспективе
    claim_rej_num     NUMBER; -- количество отказанных дел
    retr_rej_num      NUMBER; -- количество отказанных дел в ретроспективе
    claim_rej_num_ytd NUMBER; -- количество отказанных дел с накопленным итогом
    claim_rej_sum_ytd NUMBER; -- сумма по отказанным делам с накопленным итогом
  
    -- вспомогательные переменные
    first_day DATE; --  первый день месяца
    LAST_DAY  DATE; -- последний день месяца
    y         NUMBER; -- год ретроспективы
    k         NUMBER; -- количество лет ретроспективы
  
  BEGIN
  
    -- определяем первую и последнюю даты месяца
    first_day := TO_DATE('01.' || tmonth || '.' || tyear, 'dd.mm.yyyy');
    LAST_DAY  := ADD_MONTHS(first_day, 1) - 1;
    -- количество лет рестроспективы
    IF (TO_NUMBER(tyear) > 2007)
    THEN
      k := 3; -- начиная с 2008 года рассматриваем 3 предыдущих года
    ELSE
      k := 2; -- если год 2007, то рассматриваем только 2 предыдущих года
    END IF;
  
    -- считаем зарезервированные суммы по групповым, индивидуальным рискам
    -- ///////////////////////////////////////////////////////////////////
    y := TO_NUMBER(tyear);
    FOR l IN 0 .. k - 1
    LOOP
      -- зарезервированная сумма по всем групповым рискам
      gr_risk      := get_panding_claims_amount('%', 'GL', TO_CHAR(y));
      retr_gr_risk := retr_gr_risk + gr_risk;
    
      ind_risk      := get_panding_claims_amount('%', 'IL', TO_CHAR(y));
      retr_ind_risk := retr_ind_risk + ind_risk;
      -- зарезервированная сумма по всем индивидуальным рискам
    
      -- зарезервированная сумма по ВСЕМ рискам
      y := y - 1;
    END LOOP;
  
    -- ОБНОВЛЯЕМ СТРОКИ
    -- ////////////////////////////////////////////////////////////////////////////
  
    -- количество претензий
    claim_num := get_claim_number(frisk_br, ft_gr, first_day, LAST_DAY);
    update_row_to_rep_payoff(tyear, tmonth, 'number of notifications', claim_num, frisk_br, ft_gr);
  
    -- количество претензий с накопленным итогом с начала года
    claim_num_ytd := get_claim_number(frisk_br
                                     ,ft_gr
                                     ,TO_DATE('01.01.' || tyear, 'dd.mm.yyyy')
                                     ,LAST_DAY);
    update_row_to_rep_payoff(tyear
                            ,tmonth
                            ,'number of notifications accumulated ' || tyear
                            ,claim_num_ytd
                            ,frisk_br
                            ,ft_gr);
  
    -- ретроспектива по оплаченным делам
    y := TO_NUMBER(tyear);
    FOR j IN 0 .. k - 1
    LOOP
      -- количество оплаченных дел
      claim_pay_num := get_claim_pay_number(frisk_br, ft_gr, TO_CHAR(y), first_day, LAST_DAY);
      update_row_to_rep_payoff(tyear
                              ,tmonth
                              ,'number of claims ' || y || ' paid'
                              ,claim_pay_num
                              ,frisk_br
                              ,ft_gr);
      -- сумма по оплаченным делам
      claim_pay_sum := get_claim_pay_amount(frisk_br, ft_gr, TO_CHAR(y), first_day, LAST_DAY);
      update_row_to_rep_payoff(tyear
                              ,tmonth
                              ,'amount of claims ' || y || ' paid'
                              ,claim_pay_sum
                              ,frisk_br
                              ,ft_gr);
      -- итог по ретроспектиным годам - число дел
      retr_pay_num := retr_pay_num + claim_pay_num;
      -- итог по ретроспективным годам - сумма
      retr_pay_sum := retr_pay_sum + claim_pay_sum;
      y            := y - 1;
    END LOOP;
  
    -- добавляем итог по ретроспектиным годам - число дел
    update_row_to_rep_payoff(tyear
                            ,tmonth
                            ,'number of claims paid in TOTAL'
                            ,retr_pay_num
                            ,frisk_br
                            ,ft_gr);
    -- добавляем итог по ретроспективным годам - сумма
    update_row_to_rep_payoff(tyear
                            ,tmonth
                            ,'accumulated claims paid amount in ' || tyear
                            ,retr_pay_sum
                            ,frisk_br
                            ,ft_gr);
  
    -- количество оплаченных итогов за текущий год
    claim_pay_num_ytd := get_claim_pay_number(frisk_br
                                             ,ft_gr
                                             ,'%'
                                             ,TO_DATE('01.01.' || tyear, 'dd.mm.yyyy')
                                             ,LAST_DAY);
    update_row_to_rep_payoff(tyear
                            ,tmonth
                            ,'accumulated number of claims paid in ' || tyear
                            ,claim_pay_num_ytd
                            ,frisk_br
                            ,ft_gr);
  
    -- дела на рассмотрении в рестроспективе
    y := TO_NUMBER(tyear);
    FOR j IN 0 .. k - 1
    LOOP
      -- количество дел на рассмотрении
      claim_panding_num := get_claim_pending_number(frisk_br, ft_gr, TO_CHAR(y));
      update_row_to_rep_payoff(tyear
                              ,tmonth
                              ,'number of pending claims ' || y
                              ,claim_panding_num
                              ,frisk_br
                              ,ft_gr);
      --количество дел на рассмотреии в ретроспективе
      retr_panding_num := retr_panding_num + claim_panding_num;
      y                := y - 1;
    END LOOP;
    -- добавляем количество дел на рассмотреии в ретроспективе
    update_row_to_rep_payoff(tyear
                            ,tmonth
                            ,'number of panding claims in TOTAL'
                            ,retr_panding_num
                            ,frisk_br
                            ,ft_gr);
  
    -- зарезервированная сумма в рестроспективе
    y := TO_NUMBER(tyear);
    FOR j IN 0 .. k - 1
    LOOP
      -- зарезервированная сумма
      claim_panding_sum := get_panding_claims_amount(frisk_br, ft_gr, TO_CHAR(y));
      update_row_to_rep_payoff(tyear
                              ,tmonth
                              ,'amount of panding claims ' || y
                              ,claim_panding_num
                              ,frisk_br
                              ,ft_gr);
      -- зарезервированная сумма в ретроспективе
      retr_panding_sum := retr_panding_sum + claim_panding_sum;
      y                := y - 1;
    END LOOP;
    -- добавляем зарезервированную сумму в ретроспективе
    update_row_to_rep_payoff(tyear
                            ,tmonth
                            ,'amount of panding claims in TOTAL'
                            ,retr_panding_sum
                            ,frisk_br
                            ,ft_gr);
  
    -- добавляем процент от всех групповых рисков
    IF (retr_gr_risk != 0)
    THEN
      update_row_to_rep_payoff(tyear
                              ,tmonth
                              ,'percent of all groop claims in a period'
                              ,(retr_panding_sum / retr_gr_risk)
                              ,frisk_br
                              ,ft_gr);
    ELSE
      update_row_to_rep_payoff(tyear
                              ,tmonth
                              ,'percent of all groop claims in a period'
                              ,0
                              ,frisk_br
                              ,ft_gr);
    END IF;
  
    -- добавляем процент от ВСЕХ рисков
    IF (retr_tot_risk != 0)
    THEN
      update_row_to_rep_payoff(tyear
                              ,tmonth
                              ,'percent of all claims in a period'
                              ,(retr_panding_sum / retr_tot_risk)
                              ,frisk_br
                              ,ft_gr);
    ELSE
      update_row_to_rep_payoff(tyear, tmonth, 'percent of all claims in a period', 0, frisk_br, ft_gr);
    END IF;
  
    -- количество отказанных дел
    y := TO_NUMBER(tyear);
    FOR j IN 0 .. k - 1
    LOOP
      -- количество отказанных дел
      claim_rej_num := get_rejected_claims_number(frisk_br, ft_gr, TO_CHAR(y), first_day, LAST_DAY);
      update_row_to_rep_payoff(tyear
                              ,tmonth
                              ,'number of rejected claims ' || y
                              ,claim_rej_num
                              ,frisk_br
                              ,ft_gr);
      -- количество отказанных дел в ретроспективе
      retr_rej_num := retr_rej_num + claim_rej_num;
      y            := y - 1;
    END LOOP;
    -- добавляем количество отказанных дел в ретроспективе
    update_row_to_rep_payoff(tyear
                            ,tmonth
                            ,'number of rejected claims in TOTAL'
                            ,retr_rej_num
                            ,frisk_br
                            ,ft_gr);
  
    -- количество отказанных дел с нарастающим итогом
    claim_rej_num_ytd := get_rejected_claims_number(frisk_br
                                                   ,ft_gr
                                                   ,'%'
                                                   ,TO_DATE('01.01.' || tyear, 'dd.mm.yyyy')
                                                   ,LAST_DAY);
    update_row_to_rep_payoff(tyear
                            ,tmonth
                            ,'number of rejected claims accumulated ' || tyear
                            ,claim_rej_num_ytd
                            ,frisk_br
                            ,ft_gr);
  
    -- сумма по отказанным делам с нарастающим итогом
    claim_rej_sum_ytd := get_rejected_claims_amount(frisk_br
                                                   ,ft_gr
                                                   ,TO_DATE('01.01.' || tyear, 'dd.mm.yyyy')
                                                   ,LAST_DAY);
    update_row_to_rep_payoff(tyear
                            ,tmonth
                            ,'amount of rejected claims'
                            ,claim_rej_sum_ytd
                            ,frisk_br
                            ,ft_gr);
  
  END;

  -- Вызывает формирование отчета о выплатах
  PROCEDURE create_month_payoff
  (
    tmonth VARCHAR2
   ,tyear  VARCHAR2
  ) IS
    -- вспомогательные переменные
    row_day VARCHAR2(10); -- для проверки существования даты
  
    -- типы
    TYPE t_risks_gr IS VARRAY(13) OF VARCHAR2(200); -- групповые риски
    TYPE t_risks_gr_br IS VARRAY(13) OF VARCHAR2(30); -- групповые риски - сокращение
    TYPE t_risks_ind IS VARRAY(11) OF VARCHAR2(200); -- индивидуальные риски
    TYPE t_risks_ind_br IS VARRAY(11) OF VARCHAR2(30); -- индивидуальные риски - сокращение
    -- групповые риски
    ar_risk_gr t_risks_gr := t_risks_gr('General Death (GDB)'
                                       ,'Dread Disease (DD)'
                                       ,'Accidental Death Benefit (ADB)'
                                       ,'Total Permanent Disability any cause (TPD any cause)'
                                       ,'Total Permanent Disability accidental cause (TPD acc cause)'
                                       ,'Total and Partial Temporary Disability any cause (TPTD any cause)'
                                       ,'Total and Partial Temporary Disability accidental cause (TPTD acc cause)'
                                       ,'Bodily Injury (BI)'
                                       ,'Hospital Allowance any cause (HA any cause)'
                                       ,'Hospital Allowance accidental cause (HA acc cause)'
                                       ,'Accidental Surgery (S acc cause)'
                                       ,'Surgery any cause (S any cause)'
                                       ,'Consenquences of Arteriosclerosis (CA),of Cancer (CC),of Pregnancy, Delivery and Postpartum (CPDP), Consequences of Traumas (CT)');
  
    -- групповые риски (сокращение)                                    
    ar_risk_gr_br t_risks_gr_br := t_risks_gr_br('GDB'
                                                ,'DD'
                                                ,'ADB'
                                                ,'TPD_any'
                                                ,'TPD_acc'
                                                ,'TPTD_%'
                                                ,'TPTD_acc'
                                                ,'BI_%'
                                                ,'HA_any'
                                                ,'HA_acc'
                                                ,'S_acc'
                                                ,'S_any'
                                                ,'CA_CC_CPDP_CT');
  
    -- индивидуальные риски                                           
    ar_risk_ind t_risks_ind := t_risks_ind('General Death (GDB)'
                                          ,'Dread Disease (DD)'
                                          ,'Accidental Death Benefit (ADB)'
                                          ,'Total Permanent Disability any cause (TPD any cause)'
                                          ,'Total Permanent Disability accidental cause (TPD acc cause)'
                                          ,'Total and Partial Temporary Disability accidental cause (TPTD acc cause)'
                                          ,'Bodily Injury (BI)'
                                          ,'Hospital Allowance accidental cause (HA acc cause)'
                                          ,'Accidental Surgery (S acc cause)'
                                          ,'Waiver of Premium policy holder equal insured person (WP ph eq ip)'
                                          ,'Waiver of Premium policy holder not equal insured person (WP ph not eq ip)');
    -- индивидуальные риски (сокращение)
    ar_risk_ind_br t_risks_ind_br := t_risks_ind_br('GDB'
                                                   ,'DD'
                                                   ,'ADB'
                                                   ,'TPD_any'
                                                   ,'TPD_acc'
                                                   ,'TPTD_acc'
                                                   ,'BI_%'
                                                   ,'HA_acc'
                                                   ,'S_acc'
                                                   ,'WP_1'
                                                   ,'WP_2_%');
  BEGIN
    row_day := 0;
  
    -- проверяем существование даты
    -- ////////////////////////////////////////////////////////////////////////
    SELECT COUNT(*)
      INTO row_day
      FROM ins_dwh.rep_payoff rp
     WHERE rp.MONTH = tmonth
       AND rp.YEAR = tyear;
  
    IF row_day = 0
    THEN
    
      -- добавляем строки для групповых рисков
      FOR i IN 1 .. ar_risk_gr.COUNT
      LOOP
        insert_rep_payoff(tmonth, tyear, ar_risk_gr(i), ar_risk_gr_br(i), 'GL');
      END LOOP;
      -- добавляем строки для индивидуальных рисков
      FOR i IN 1 .. ar_risk_ind.COUNT
      LOOP
        insert_rep_payoff(tmonth, tyear, ar_risk_ind(i), ar_risk_ind_br(i), 'IL');
      END LOOP;
      --/*
    ELSE
    
      -- обновляем строки для групповых рисков
      FOR i IN 1 .. ar_risk_gr.COUNT
      LOOP
        update_rep_payoff(tmonth, tyear, ar_risk_gr_br(i), 'GL');
      END LOOP;
      -- обновляем строки для индивидуальных рисков
      FOR i IN 1 .. ar_risk_ind.COUNT
      LOOP
        update_rep_payoff(tmonth, tyear, ar_risk_ind_br(i), 'IL');
      END LOOP;
      --*/
    END IF;
    COMMIT;
  END;

  -- ************************************************************************
  --/////////////////////////END Отчет по выплатам //////////////////////////
  -- ************************************************************************

  -- ************************************************************************
  --/////////////////////////SALES REPORT WITHOUT PROGRAMM //////////////////
  -- ************************************************************************

  -- Возвращает агента, заключившего договор
  FUNCTION get_agch_id_by_polid(p_pol_h_id NUMBER) RETURN NUMBER IS
    ag_id NUMBER; -- id агентского договора для агента, заключившего договор страхования
  BEGIN
    SELECT tbl.agent_id
      INTO ag_id
      FROM (SELECT agch.agent_id
                  ,DECODE(sch.brief, 'CC', 1, 0) ord
              FROM ins.ven_p_pol_header ph
              JOIN ins.ven_p_policy_agent ppag
                ON ppag.policy_header_id = ph.policy_header_id
              JOIN ins.ven_ag_contract_header agch
                ON agch.ag_contract_header_id = ppag.ag_contract_header_id
              JOIN ins.ven_t_sales_channel sch
                ON sch.ID = agch.t_sales_channel_id
             WHERE ph.policy_header_id = p_pol_h_id
               AND ppag.date_start =
                   (SELECT MIN(pa.date_start)
                      FROM ins.ven_p_policy_agent pa
                     WHERE pa.policy_header_id = ph.policy_header_id)
             ORDER BY DECODE(sch.brief, 'CC', 1, 0)) tbl
     WHERE ROWNUM < 2;
    RETURN(ag_id);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
    
  END;

  -- Возвращает название агентства, заключившего договор
  FUNCTION get_dep_id_by_polid(p_pol_header_id NUMBER) RETURN NUMBER IS
    dep_id NUMBER;
  BEGIN
    SELECT dep.department_id
      INTO dep_id
      FROM ins.ven_ag_contract_header agch
      JOIN ins.ven_department dep
        ON agch.agency_id = dep.department_id
     WHERE agch.agent_id = get_agch_id_by_polid(p_pol_header_id)
       AND ROWNUM < 2;
    RETURN(dep_id);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  -- Возвращает название агентства, к которому относится агент
  FUNCTION get_dep_id_by_agid(p_agent_id NUMBER) RETURN NUMBER IS
    dep_id NUMBER;
  BEGIN
    SELECT dep.department_id
      INTO dep_id
      FROM ins.ven_ag_contract_header agch
      JOIN ins.ven_department dep
        ON agch.agency_id = dep.department_id
     WHERE agch.agent_id = p_agent_id
       AND ROWNUM < 2;
    RETURN(dep_id);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  --/*
  -- Возвращает таблицу договоров, заключенных в указанный период
  -- с указанием агента, агентства, канала продаж и продукта
  FUNCTION get_tbl_ag_ch_pr
  (
    dleft  DATE
   ,dright DATE
  ) RETURN tbl_ag_ch_pr
    PIPELINED IS
  BEGIN
    -- находим договра, заключенные в период
    FOR t_rec IN (SELECT DISTINCT NVL(tbl.agent_id, -1)
                                 ,NVL(ins.ent.obj_name('CONTACT', tbl.agent_id), ' -') AS agent_fio
                                 ,NVL(tbl.dep_id, -1)
                                 ,NVL(tbl.dep_name, ' -')
                                 ,tbl.ch_br
                                 ,tbl.ch_name
                                 ,tbl.pr_br
                                 ,tbl.pr_name
                    FROM (SELECT DISTINCT (SELECT tt.ag_id
                                             FROM ins_dwh.rep_sr_ag tt
                                            WHERE tt.pol_id = ph.policy_header_id) AS agent_id
                                         ,sch.brief AS ch_br
                                         ,sch.description AS ch_name
                                         ,ph.agency_id AS dep_id
                                         ,pkg_rep_utils_ins11.get_pol_agency_name(ph.agency_id) AS dep_name
                                         ,pr.brief AS pr_br
                                         ,pr.description AS pr_name
                            FROM ins.ven_p_pol_header    ph
                                ,ins.ven_t_sales_channel sch
                                ,ins.ven_t_product       pr
                           WHERE ph.start_date BETWEEN dleft AND dright
                             AND sch.ID = ph.sales_channel_id
                             AND pr.product_id = ph.product_id) tbl)
    LOOP
      PIPE ROW(t_rec);
    END LOOP;
    RETURN;
  END;
  --*/

  /* УДАЛИТЬ
  -- Возвращает сумму APE (годовой премии по договорам)
  function get_ape_policy (tbl tbl_id) return number
  is
  summ number (11,2);
  begin
  select sum(pp.premium)
  into summ 
  from ins.ven_p_pol_header ph
  join ins.ven_p_policy pp on pp.policy_id = ph.policy_id
  join (select column_value from table(tbl)) f on ph.policy_header_id = f.column_value;
  return(to_char(summ,'999999999D99'));
  exception
  when others then return null;
  end;
  
  /*
  -- рабочий вариант
  -- Возвращает id договоров, заключенных в указанный период
  function get_pol_id (dleft date, dright date) return tbl_id
  is
  tbl tbl_id;
  begin
  select ph.policy_header_id
  bulk collect into tbl
  from ins.ven_p_pol_header ph
  where ph.start_date between dleft and dright;
  return (tbl);
  end;
  */

  -- Возвращает сумму APE по заключенным договорам
  FUNCTION get_ape_policy
  (
    dleft  DATE
   ,dright DATE
   ,ag_id  NUMBER
   ,dep_id NUMBER
   ,ch_br  VARCHAR2
   ,pr_br  VARCHAR2
  ) RETURN NUMBER IS
    summ NUMBER(11, 2);
  BEGIN
    SELECT NVL(SUM(pp.premium), 0)
      INTO summ
      FROM ins.ven_p_pol_header ph
      JOIN ins.ven_p_policy pp
        ON pp.policy_id = ph.policy_id
      JOIN (SELECT *
              FROM TABLE(pkg_rep_utils_ins11.get_policy_id(dleft, dright, ag_id, dep_id, ch_br, pr_br))) f
        ON ph.policy_header_id = f.COLUMN_VALUE;
    RETURN(TO_CHAR(summ, '000000000D00'));
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  -- Возвращает сумму APE по расторгнутым договорам
  FUNCTION get_ape_pol_dec
  (
    dleft  DATE
   ,dright DATE
   ,ag_id  NUMBER
   ,dep_id NUMBER
   ,ch_br  VARCHAR2
   ,pr_br  VARCHAR2
  ) RETURN NUMBER IS
    summ NUMBER(11, 2);
  BEGIN
    SELECT NVL(SUM(pp.premium), 0)
      INTO summ
      FROM ins.ven_p_pol_header ph
      JOIN ins.ven_p_policy pp
        ON pp.policy_id = ph.policy_id
      JOIN (SELECT *
              FROM TABLE(pkg_rep_utils_ins11.get_pol_dec_anderr_id(dleft
                                                                  ,dright
                                                                  ,ag_id
                                                                  ,dep_id
                                                                  ,ch_br
                                                                  ,pr_br))) f
        ON ph.policy_header_id = f.COLUMN_VALUE;
    RETURN(TO_CHAR(summ, '000000000D00'));
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  -- Возвращает сумму APE по расторгнутым договорам по иным приичнам
  FUNCTION get_ape_pol_dec_oth
  (
    dleft  DATE
   ,dright DATE
   ,ag_id  NUMBER
   ,dep_id NUMBER
   ,ch_br  VARCHAR2
   ,pr_br  VARCHAR2
  ) RETURN NUMBER IS
    summ NUMBER(11, 2);
  BEGIN
    SELECT NVL(SUM(pp.premium), 0)
      INTO summ
      FROM ins.ven_p_pol_header ph
      JOIN ins.ven_p_policy pp
        ON pp.policy_id = ph.policy_id
      JOIN (SELECT *
              FROM TABLE(pkg_rep_utils_ins11.get_pol_dec_other_id(dleft
                                                                 ,dright
                                                                 ,ag_id
                                                                 ,dep_id
                                                                 ,ch_br
                                                                 ,pr_br))) f
        ON ph.policy_header_id = f.COLUMN_VALUE;
    RETURN(TO_CHAR(summ, '000000000D00'));
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  -- Возвращает сумму APE по активным договорам
  FUNCTION get_ape_pol_act
  (
    dleft  DATE
   ,dright DATE
   ,ag_id  NUMBER
   ,dep_id NUMBER
   ,ch_br  VARCHAR2
   ,pr_br  VARCHAR2
  ) RETURN NUMBER IS
    summ NUMBER(11, 2);
  BEGIN
    SELECT NVL(SUM(pp.premium), 0)
      INTO summ
      FROM ins.ven_p_pol_header ph
      JOIN ins.ven_p_policy pp
        ON pp.policy_id = ph.policy_id
      JOIN (SELECT *
              FROM TABLE(pkg_rep_utils_ins11.get_pol_active_id(dleft
                                                              ,dright
                                                              ,ag_id
                                                              ,dep_id
                                                              ,ch_br
                                                              ,pr_br))) f
        ON ph.policy_header_id = f.COLUMN_VALUE;
    RETURN(TO_CHAR(summ, '000000000D00'));
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  -- Возвращает сумму оплаченной премии по заключенным договорам
  FUNCTION get_pol_pay_amount
  (
    dleft  DATE
   ,dright DATE
   ,ag_id  NUMBER
   ,dep_id NUMBER
   ,ch_br  VARCHAR2
   ,pr_br  VARCHAR2
  ) RETURN NUMBER IS
    summ NUMBER(11, 2);
  BEGIN
    SELECT NVL(SUM(ins.pkg_payment.get_pay_pol_header_amount_pfa(dleft, dright, ph.policy_header_id))
              ,0)
      INTO summ
      FROM ins.ven_p_pol_header ph
      JOIN (SELECT *
              FROM TABLE(pkg_rep_utils_ins11.get_policy_id(dleft, dright, ag_id, dep_id, ch_br, pr_br))) f
        ON ph.policy_header_id = f.COLUMN_VALUE;
    RETURN(TO_CHAR(summ, '000000000D00'));
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  -- Возвращает сумму оплаченной премии по активным договорам
  FUNCTION get_pol_pay_amount_act
  (
    dleft  DATE
   ,dright DATE
   ,ag_id  NUMBER
   ,dep_id NUMBER
   ,ch_br  VARCHAR2
   ,pr_br  VARCHAR2
  ) RETURN NUMBER IS
    summ NUMBER(11, 2);
  BEGIN
    SELECT NVL(SUM(ins.pkg_payment.get_pay_pol_header_amount_pfa(dleft, dright, ph.policy_header_id))
              ,0)
      INTO summ
      FROM ins.ven_p_pol_header ph
      JOIN (SELECT *
              FROM TABLE(pkg_rep_utils_ins11.get_pol_active_id(dleft
                                                              ,dright
                                                              ,ag_id
                                                              ,dep_id
                                                              ,ch_br
                                                              ,pr_br))) f
        ON ph.policy_header_id = f.COLUMN_VALUE;
    RETURN(TO_CHAR(summ, '000000000D00'));
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  -- Возвращает сумму возврата по расторгнутым договорам
  FUNCTION get_pol_dec_amount
  (
    dleft  DATE
   ,dright DATE
   ,ag_id  NUMBER
   ,dep_id NUMBER
   ,ch_br  VARCHAR2
   ,pr_br  VARCHAR2
  ) RETURN NUMBER IS
    summ NUMBER(11, 2);
  BEGIN
    SELECT NVL(SUM(pp.decline_summ), 0)
      INTO summ
      FROM ins.ven_p_pol_header ph
      JOIN ins.ven_p_policy pp
        ON pp.policy_id = ph.policy_id
      JOIN (SELECT *
              FROM TABLE(pkg_rep_utils_ins11.get_pol_dec_anderr_id(dleft
                                                                  ,dright
                                                                  ,ag_id
                                                                  ,dep_id
                                                                  ,ch_br
                                                                  ,pr_br))) f
        ON ph.policy_header_id = f.COLUMN_VALUE;
    RETURN(TO_CHAR(summ, '000000000D00'));
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  -- Возвращает сумму возврата по расторгнутым договорам по иным причинам
  FUNCTION get_pol_dec_amount_oth
  (
    dleft  DATE
   ,dright DATE
   ,ag_id  NUMBER
   ,dep_id NUMBER
   ,ch_br  VARCHAR2
   ,pr_br  VARCHAR2
  ) RETURN NUMBER IS
    summ NUMBER(11, 2);
  BEGIN
    SELECT NVL(SUM(pp.decline_summ), 0)
      INTO summ
      FROM ins.ven_p_pol_header ph
      JOIN ins.ven_p_policy pp
        ON pp.policy_id = ph.policy_id
      JOIN (SELECT *
              FROM TABLE(pkg_rep_utils_ins11.get_pol_dec_other_id(dleft
                                                                 ,dright
                                                                 ,ag_id
                                                                 ,dep_id
                                                                 ,ch_br
                                                                 ,pr_br))) f
        ON ph.policy_header_id = f.COLUMN_VALUE;
    RETURN(TO_CHAR(summ, '000000000D00'));
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  -- Заполняет таблицу соответствий "id полиса - id агента"
  PROCEDURE fill_tbl_pol_ag
  (
    dleft  DATE
   ,dright DATE
  ) IS
  BEGIN
    -- чистим таблицу 
    DELETE ins_dwh.rep_sr_ag;
    -- заполняем таблицу
    FOR rec IN (SELECT ph.policy_header_id AS pol_id
                      ,pkg_rep_utils_ins11.get_agch_id_by_polid(ph.policy_header_id) AS ag_id
                  FROM ins.ven_p_pol_header ph
                 WHERE ph.start_date BETWEEN dleft AND dright)
    LOOP
      INSERT INTO ins_dwh.rep_sr_ag tt (tt.pol_id, tt.ag_id) VALUES (rec.pol_id, NVL(rec.ag_id, -1));
    END LOOP;
    COMMIT;
  END;

  -- Возвращает id договоров, заключенных в период
  FUNCTION get_policy_id
  (
    dleft  DATE
   ,dright DATE
   ,ag_id  NUMBER
   ,dep_id NUMBER
   ,ch_br  VARCHAR2
   ,pr_br  VARCHAR2
  ) RETURN tbl_id
    PIPELINED IS
    -- временные переменные
    t_ag_id  VARCHAR2(10); -- id агента
    t_dep_id VARCHAR2(10); -- id агентства
    t_ch_br  VARCHAR2(30); -- cокращение канала продаж
    t_pr_br  VARCHAR2(30); -- сокращение продукта
  BEGIN
    -- устанавливаем переменные
    IF ag_id IS NULL
    THEN
      t_ag_id := '-1';
    ELSE
      t_ag_id := ag_id;
    END IF;
  
    IF dep_id IS NULL
    THEN
      t_dep_id := '-1';
    ELSE
      t_dep_id := dep_id;
    END IF;
    --/*
    IF ch_br IS NULL
    THEN
      t_ch_br := '%';
    ELSE
      t_ch_br := ch_br;
    END IF;
  
    IF pr_br IS NULL
    THEN
      t_pr_br := '%';
    ELSE
      t_pr_br := pr_br;
    END IF;
    --*/
    -- заполняем таблицу
    FOR rec IN (
                
                SELECT tbl.policy_header_id
                  FROM (SELECT ph.policy_header_id
                               ,(SELECT tt.ag_id
                                   FROM ins_dwh.rep_sr_ag tt
                                  WHERE tt.pol_id = ph.policy_header_id) AS ag_id
                           FROM ins.ven_p_pol_header ph
                           JOIN ins.ven_t_sales_channel sch
                             ON sch.ID = ph.sales_channel_id
                           JOIN ins.ven_t_product pr
                             ON pr.product_id = ph.product_id
                          WHERE ph.start_date BETWEEN dleft AND dright
                            AND sch.brief LIKE t_ch_br
                            AND pr.brief LIKE t_pr_br
                            AND NVL(TO_CHAR(ph.agency_id), -1) LIKE t_dep_id) tbl
                 WHERE NVL(TO_CHAR(tbl.ag_id), -1) LIKE t_ag_id
                
                )
    LOOP
      PIPE ROW(rec.policy_header_id);
    END LOOP;
    RETURN;
  END;

  -- Возвращает id договоров, заключенных и действующий в указанном периоде
  FUNCTION get_pol_active_id
  (
    dleft  DATE
   ,dright DATE
   ,ag_id  NUMBER
   ,dep_id NUMBER
   ,ch_br  VARCHAR2
   ,pr_br  VARCHAR2
  ) RETURN tbl_id
    PIPELINED IS
  BEGIN
    FOR rec IN (SELECT ph.policy_header_id
                  FROM ins.ven_p_pol_header ph
                  JOIN ins.ven_p_policy pp
                    ON pp.policy_id = ph.policy_id
                  JOIN (SELECT *
                         FROM TABLE(pkg_rep_utils_ins11.get_policy_id(dleft
                                                                     ,dright
                                                                     ,ag_id
                                                                     ,dep_id
                                                                     ,ch_br
                                                                     ,pr_br))) tbl
                    ON ph.policy_header_id = tbl.COLUMN_VALUE
                 WHERE NVL(pp.end_date, dright + 1) > dright
                --or pp.end_date is null;
                )
    LOOP
      PIPE ROW(rec.policy_header_id);
    END LOOP;
    RETURN;
  END;

  -- Возвращает id договоров, заключенных  и расторгнутым в указанный период
  -- по результатам андерреайтинга или заявлению страхователя
  FUNCTION get_pol_dec_anderr_id
  (
    dleft  DATE
   ,dright DATE
   ,ag_id  NUMBER
   ,dep_id NUMBER
   ,ch_br  VARCHAR2
   ,pr_br  VARCHAR2
  ) RETURN tbl_id
    PIPELINED IS
  BEGIN
    FOR rec IN (SELECT ph.policy_header_id
                  FROM ins.ven_p_pol_header ph
                  JOIN ins.ven_p_policy pp
                    ON pp.policy_id = ph.policy_id
                  JOIN ins.ven_t_decline_reason dr
                    ON dr.t_decline_reason_id = pp.decline_reason_id
                  JOIN (SELECT *
                         FROM TABLE(pkg_rep_utils_ins11.get_policy_id(dleft
                                                                     ,dright
                                                                     ,ag_id
                                                                     ,dep_id
                                                                     ,ch_br
                                                                     ,pr_br))) tbl
                    ON ph.policy_header_id = tbl.COLUMN_VALUE
                 WHERE pp.decline_date BETWEEN dleft AND dright
                   AND dr.brief IN ('ЗаявСтрахователя', 'ОтказВпредПокр'))
    LOOP
      PIPE ROW(rec.policy_header_id);
    END LOOP;
    RETURN;
  END;

  -- Возвращает id договоров, заключенных  и расторгнутым в указанный период
  -- по иным причинам
  FUNCTION get_pol_dec_other_id
  (
    dleft  DATE
   ,dright DATE
   ,ag_id  NUMBER
   ,dep_id NUMBER
   ,ch_br  VARCHAR2
   ,pr_br  VARCHAR2
  ) RETURN tbl_id
    PIPELINED IS
  BEGIN
    FOR rec IN (SELECT ph.policy_header_id
                  FROM ins.ven_p_pol_header ph
                  JOIN ins.ven_p_policy pp
                    ON pp.policy_id = ph.policy_id
                  JOIN ins.ven_t_decline_reason dr
                    ON dr.t_decline_reason_id = pp.decline_reason_id
                  JOIN (SELECT *
                         FROM TABLE(pkg_rep_utils_ins11.get_policy_id(dleft
                                                                     ,dright
                                                                     ,ag_id
                                                                     ,dep_id
                                                                     ,ch_br
                                                                     ,pr_br))) tbl
                    ON ph.policy_header_id = tbl.COLUMN_VALUE
                 WHERE pp.decline_date BETWEEN dleft AND dright
                   AND dr.brief NOT IN
                       ('ЗаявСтрахователя', 'ОтказВпредПокр'))
    LOOP
      PIPE ROW(rec.policy_header_id);
    END LOOP;
    RETURN;
  END;

  -- добавляет строку в таблицу rep_sr_wo_prog
  PROCEDURE insert_row_to_sr_wo
  (
    fchanal VARCHAR2
   ,fdep    VARCHAR2
   ,fagent  VARCHAR2
   ,fprod   VARCHAR2
   ,fparam  VARCHAR2
   ,fvalue  NUMBER
  ) IS
  BEGIN
    INSERT INTO ins_dwh.rep_sr_wo_prog sr
      (chanal, agency, AGENT, product, param, VALUE)
    VALUES
      (fchanal, fdep, fagent, fprod, fparam, fvalue);
  END;

  -- Вызывает формирование отчета Sales Report с детализацией до продукта
  -- opatsan version
  --новая версия pkg_rep_utils_ins11.create_period_sr_wo (модифицировал Сизон С.Л.) 
  PROCEDURE create_period_sr_wo
  (
    dleft  DATE
   ,dright DATE
  ) IS
    -- вспомогательные переменные
    first_day DATE; -- дата начала года
  
    -- активные договора с накопленным итогом с начала года
    act_ape_ytd        NUMBER; -- годовая премия
    act_pay_amount_ytd NUMBER DEFAULT 0; -- оплаченная премия
    act_num_ytd        NUMBER; -- количество договоров
  
    v_fund_id      NUMBER;
    v_rate_type_id NUMBER;
  
  BEGIN
  
    -- заполняем таблицу соответсвия "договор  - агент" 
    fill_tbl_pol_ag(dleft, dright);
  
    -- вычисляем первую дату года
    first_day := TRUNC(dleft, 'yyyy');
    DELETE FROM ins_dwh.rep_sr_wo_prog;
  
    SELECT f.fund_id INTO v_fund_id FROM ins.ven_fund f WHERE f.brief = 'RUR';
  
    SELECT t.rate_type_id INTO v_rate_type_id FROM ins.ven_rate_type t WHERE t.brief = 'ЦБ';
  
    FOR rec IN (SELECT SUM(CASE
                             WHEN ph.start_date BETWEEN dleft AND dright THEN
                              pp.premium * ins.acc_new.Get_Cross_Rate_By_Id(v_rate_type_id
                                                                           ,ph.fund_id
                                                                           ,v_fund_id
                                                                           ,ph.start_date)
                             ELSE
                              0
                           END) pol_ape
                      , --pol_ape
                       SUM(CASE
                             WHEN ph.start_date BETWEEN dleft AND dright THEN
                              ins.pkg_payment.get_pay_pol_header_amount_pfa(dleft
                                                                           ,dright
                                                                           ,ph.policy_header_id) *
                              ins.acc_new.Get_Cross_Rate_By_Id(v_rate_type_id
                                                              ,ph.fund_id
                                                              ,v_fund_id
                                                              ,ph.start_date)
                             ELSE
                              0
                           END) pol_pay_amount
                      , --pol_pay_amount
                       SUM(CASE
                             WHEN ph.start_date BETWEEN dleft AND dright THEN
                              1
                             ELSE
                              0
                           END) pol_num
                      , --pol_num
                       SUM(CASE
                             WHEN (pp.decline_date BETWEEN dleft AND dright)
                                  AND tdr.brief IN
                                  ('ЗаявСтрахователя', 'ОтказВпредПокр')
                                  AND (ph.start_date BETWEEN dleft AND dright) THEN
                              pp.premium * ins.acc_new.Get_Cross_Rate_By_Id(v_rate_type_id
                                                                           ,ph.fund_id
                                                                           ,v_fund_id
                                                                           ,ph.start_date)
                             ELSE
                              0
                           END) dec_ape
                      , --dec_ape
                       SUM(CASE
                             WHEN pp.decline_date BETWEEN dleft AND dright
                                  AND tdr.brief IN
                                  ('ЗаявСтрахователя', 'ОтказВпредПокр')
                                  AND (ph.start_date BETWEEN dleft AND dright) THEN
                              1
                             ELSE
                              0
                           END) dec_num
                      , --dec_num
                       SUM(CASE
                             WHEN pp.decline_date BETWEEN dleft AND dright
                                  AND tdr.brief IN
                                  ('ЗаявСтрахователя', 'ОтказВпредПокр')
                                  AND (ph.start_date BETWEEN dleft AND dright) THEN
                              pp.decline_summ *
                              ins.acc_new.Get_Cross_Rate_By_Id(v_rate_type_id
                                                              ,ph.fund_id
                                                              ,v_fund_id
                                                              ,ph.start_date)
                             ELSE
                              0
                           END) dec_pay_amount
                      , --dec_pay_amount
                       SUM(CASE
                             WHEN (NVL(pp.end_date, dright + 1) > dright)
                                  AND (ph.start_date BETWEEN dleft AND dright) THEN
                              pp.premium * ins.acc_new.Get_Cross_Rate_By_Id(v_rate_type_id
                                                                           ,ph.fund_id
                                                                           ,v_fund_id
                                                                           ,ph.start_date)
                             ELSE
                              0
                           END) act_ape
                      , --act_ape
                       SUM(CASE
                             WHEN (NVL(pp.end_date, dright + 1) > dright)
                                  AND (ph.start_date BETWEEN dleft AND dright) THEN
                              ins.pkg_payment.get_pay_pol_header_amount_pfa(dleft
                                                                           ,dright
                                                                           ,ph.policy_header_id) *
                              ins.acc_new.Get_Cross_Rate_By_Id(v_rate_type_id
                                                              ,ph.fund_id
                                                              ,v_fund_id
                                                              ,ph.start_date)
                             ELSE
                              0
                           END) act_pay_amount
                      , --act_pay_amount
                       SUM(CASE
                             WHEN (NVL(pp.end_date, dright + 1) > dright)
                                  AND (ph.start_date BETWEEN dleft AND dright) THEN
                              1
                             ELSE
                              0
                           END) act_num
                      , --act_num       
                       SUM(CASE
                             WHEN pp.decline_date BETWEEN dleft AND dright
                                  AND tdr.brief NOT IN
                                  ('ЗаявСтрахователя', 'ОтказВпредПокр')
                                  AND (ph.start_date BETWEEN dleft AND dright) THEN
                              pp.premium * ins.acc_new.Get_Cross_Rate_By_Id(v_rate_type_id
                                                                           ,ph.fund_id
                                                                           ,v_fund_id
                                                                           ,ph.start_date)
                           
                             ELSE
                              0
                           END) dec_oth_ape
                      , --dec_oth_ape
                       SUM(CASE
                             WHEN pp.decline_date BETWEEN dleft AND dright
                                  AND tdr.brief NOT IN
                                  ('ЗаявСтрахователя', 'ОтказВпредПокр')
                                  AND (ph.start_date BETWEEN dleft AND dright) THEN
                              1
                             ELSE
                              0
                           END) dec_oth_num
                      , --dec_oth_num
                       SUM(CASE
                             WHEN pp.decline_date BETWEEN dleft AND dright
                                  AND tdr.brief NOT IN
                                  ('ЗаявСтрахователя', 'ОтказВпредПокр')
                                  AND (ph.start_date BETWEEN dleft AND dright) THEN
                              pp.decline_summ *
                              ins.acc_new.Get_Cross_Rate_By_Id(v_rate_type_id
                                                              ,ph.fund_id
                                                              ,v_fund_id
                                                              ,ph.start_date)
                             ELSE
                              0
                           END) dec_oth_pay_amount
                      , --dec_oth_pay_amount    
                       SUM(pp.premium * ins.acc_new.Get_Cross_Rate_By_Id(v_rate_type_id
                                                                        ,ph.fund_id
                                                                        ,v_fund_id
                                                                        ,ph.start_date)) act_ape_ytd
                      ,COUNT(*) act_num_ytd
                      ,
                       /*sum(
                       nvl(td.trans_amount
                           , 0) + 
                       nvl(-tc.trans_amount
                           , 0))*/SUM(ins.pkg_payment.get_pay_pol_header_amount_pfa(first_day
                                                                        ,dright
                                                                        ,ph.policy_header_id) *
                           ins.acc_new.Get_Cross_Rate_By_Id(v_rate_type_id
                                                           ,ph.fund_id
                                                           ,v_fund_id
                                                           ,ph.start_date)) act_pay_amount_ytd
                      ,tt.ag_id agent_id
                      ,c.obj_name_orig ag_fio
                      ,sch.brief ch_br
                      ,ph.sales_channel_id
                      ,sch.description ch_name
                      ,ph.agency_id dep_id
                      ,pkg_rep_utils_ins11.get_pol_agency_name(ph.agency_id) dep_name
                      ,pr.product_id
                      ,pr.brief pr_br
                      ,pr.description pr_name
                  FROM ins.ven_p_pol_header     ph
                      ,ins.ven_p_policy         pp
                      ,ins.ven_t_sales_channel  sch
                      ,ins.ven_t_product        pr
                      ,ins_dwh.rep_sr_ag        tt
                      ,ins.ven_contact          c
                      ,ins.ven_t_decline_reason tdr --,
                --вложение по проводкам 
                /*ins.ven_trans td,
                ins.ven_trans tc*/
                 WHERE ph.start_date BETWEEN first_day AND dright
                   AND ph.policy_id = pp.policy_id(+)
                   AND sch.ID = ph.sales_channel_id
                   AND pr.product_id = ph.product_id
                   AND tt.pol_id(+) = ph.policy_header_id
                   AND c.contact_id(+) = tt.ag_id
                   AND tdr.t_decline_reason_id(+) = pp.decline_reason_id
                --вложение по проводкам 
                /*and td.dt_account_id(+) = ins.pkg_payment.v_pay_acc_id
                and td.A2_DT_URO_ID(+) = pp.policy_id
                and td.trans_date(+) between first_day and dright
                and tc.ct_account_id(+) = ins.pkg_payment.v_pay_acc_id
                and tc.A2_CT_URO_ID(+) = pp.policy_id
                and tc.trans_date(+) between first_day and dright*/
                 GROUP BY tt.ag_id
                         ,pr.product_id
                         ,c.obj_name_orig
                         ,ph.sales_channel_id
                         ,sch.brief
                         ,sch.description
                         ,ph.agency_id
                         ,pkg_rep_utils_ins11.get_pol_agency_name(ph.agency_id)
                         ,pr.brief
                         ,pr.description
                HAVING SUM(CASE
                  WHEN ph.start_date BETWEEN dleft AND dright THEN
                   1
                  ELSE
                   0
                END) > 0)
    LOOP
    
      -- добавляем строки в таблицу
      -- ////////////////////////////////////////////
    
      insert_row_to_sr_wo(rec.ch_name
                         ,rec.dep_name
                         ,rec.ag_fio
                         ,rec.pr_name
                         ,'Годовая премия (gross)'
                         ,rec.pol_ape);
      insert_row_to_sr_wo(rec.ch_name
                         ,rec.dep_name
                         ,rec.ag_fio
                         ,rec.pr_name
                         ,'Сумма оплаты (gross)'
                         ,rec.pol_pay_amount);
      insert_row_to_sr_wo(rec.ch_name
                         ,rec.dep_name
                         ,rec.ag_fio
                         ,rec.pr_name
                         ,'Количество заключенных договоров'
                         ,rec.pol_num);
    
      insert_row_to_sr_wo(rec.ch_name
                         ,rec.dep_name
                         ,rec.ag_fio
                         ,rec.pr_name
                         ,'APE по расторгнутым договорам'
                         ,rec.dec_ape);
      insert_row_to_sr_wo(rec.ch_name
                         ,rec.dep_name
                         ,rec.ag_fio
                         ,rec.pr_name
                         ,'Сумма возвращенной премии'
                         ,rec.dec_pay_amount);
      insert_row_to_sr_wo(rec.ch_name
                         ,rec.dep_name
                         ,rec.ag_fio
                         ,rec.pr_name
                         ,'Количество расторгнутых договоров'
                         ,rec.dec_num);
    
      insert_row_to_sr_wo(rec.ch_name
                         ,rec.dep_name
                         ,rec.ag_fio
                         ,rec.pr_name
                         ,'APE (net)'
                         ,rec.act_ape);
      insert_row_to_sr_wo(rec.ch_name
                         ,rec.dep_name
                         ,rec.ag_fio
                         ,rec.pr_name
                         ,'Сумма оплаченной премии (net)'
                         ,rec.act_pay_amount);
      insert_row_to_sr_wo(rec.ch_name
                         ,rec.dep_name
                         ,rec.ag_fio
                         ,rec.pr_name
                         ,'Количество заключенных договоров (net)'
                         ,rec.act_num);
    
      insert_row_to_sr_wo(rec.ch_name
                         ,rec.dep_name
                         ,rec.ag_fio
                         ,rec.pr_name
                         ,'APE YTD (net)'
                         ,rec.act_ape_ytd);
      insert_row_to_sr_wo(rec.ch_name
                         ,rec.dep_name
                         ,rec.ag_fio
                         ,rec.pr_name
                         ,'Оплаченная премия YTD (net)'
                         ,rec.act_pay_amount_ytd);
      insert_row_to_sr_wo(rec.ch_name
                         ,rec.dep_name
                         ,rec.ag_fio
                         ,rec.pr_name
                         ,'Количество договоров YTD (net)'
                         ,rec.act_num_ytd);
    
      insert_row_to_sr_wo(rec.ch_name
                         ,rec.dep_name
                         ,rec.ag_fio
                         ,rec.pr_name
                         ,'APE по иным случаям расторжения'
                         ,rec.dec_oth_ape);
      insert_row_to_sr_wo(rec.ch_name
                         ,rec.dep_name
                         ,rec.ag_fio
                         ,rec.pr_name
                         ,'Сумма возвращенной премии по иным случаям расторжения'
                         ,rec.dec_oth_pay_amount);
      insert_row_to_sr_wo(rec.ch_name
                         ,rec.dep_name
                         ,rec.ag_fio
                         ,rec.pr_name
                         ,'Количество договоров по иным случаям расторжения'
                         ,rec.dec_oth_num);
    
    END LOOP;
    COMMIT;
  END;

  -- Вызывает формирование отчета Sales Report с детализацией до продукта
  PROCEDURE create_period_sr_wo2
  (
    dleft  DATE
   ,dright DATE
  ) IS
    -- заключенные договора
    pol_ape        NUMBER; -- годовая премия
    pol_pay_amount NUMBER; -- оплаченная премия
    pol_num        NUMBER; -- количество заключенных договоров
    -- договора заключенные и расторгнутые (заявление страхователя, отказ андеррайтинга)
    dec_ape        NUMBER; -- годовая премия 
    dec_pay_amount NUMBER; -- сумма возврата
    dec_num        NUMBER; -- количество договоров
    --активные договора
    act_ape        NUMBER; -- годовая премия
    act_pay_amount NUMBER; -- оплаченная премия
    act_num        NUMBER; -- количество договоров
    -- активные договора с накопленным итогом с начала года
    act_ape_ytd        NUMBER; -- годовая премия
    act_pay_amount_ytd NUMBER; -- оплаченная премия
    act_num_ytd        NUMBER; -- количество договоров
    -- договора заключенные и расторгнутые (по иным причинам)
    dec_oth_ape        NUMBER; -- годовая премия 
    dec_oth_pay_amount NUMBER; -- сумма возврата
    dec_oth_num        NUMBER; -- количество договоров
  
    -- вспомогательные переменные
    first_day DATE; -- дата начала года
  
  BEGIN
    -- заполняем таблицу соответсвия "договор  - агент" 
    fill_tbl_pol_ag(dleft, dright);
  
    -- вычисляем первую дату года
    first_day := TRUNC(dleft, 'yyyy');
    --first_day:= to_date ('01.01.' || to_char(dleft,'yyyy'),'dd.mm.yyyy');
    -- удаляем все данные в таблице
    DELETE FROM ins_dwh.rep_sr_wo_prog;
    -- формируем таблицу по заключенным договорам
    --/*
    FOR rec IN (SELECT ag_id
                      ,ag_fio
                      ,dep_id
                      ,dep_name
                      ,ch_br
                      ,ch_name
                      ,pr_br
                      ,pr_name
                  FROM TABLE(pkg_rep_utils_ins11.get_tbl_ag_ch_pr(dleft, dright)))
    
    LOOP
      -- считаем показатели
      -- ////////////////////////////////////////////
    
      -- заключенные договора
      pol_ape        := TO_NUMBER(get_ape_policy(dleft
                                                ,dright
                                                ,rec.ag_id
                                                ,rec.dep_id
                                                ,rec.ch_br
                                                ,rec.pr_br)); -- годовая премия
      pol_pay_amount := get_pol_pay_amount(dleft, dright, rec.ag_id, rec.dep_id, rec.ch_br, rec.pr_br); -- оплаченная премия
      SELECT COUNT(*)
        INTO pol_num
        FROM TABLE(pkg_rep_utils_ins11.get_policy_id(dleft
                                                    ,dright
                                                    ,rec.ag_id
                                                    ,rec.dep_id
                                                    ,rec.ch_br
                                                    ,rec.pr_br)); -- количество заключенных договоров
    
      -- договора заключенные и расторгнутые (заявление страхователя, отказ андеррайтинга)
      dec_ape        := TO_NUMBER(get_ape_pol_dec(dleft
                                                 ,dright
                                                 ,rec.ag_id
                                                 ,rec.dep_id
                                                 ,rec.ch_br
                                                 ,rec.pr_br)); -- годовая премия
      dec_pay_amount := get_pol_dec_amount(dleft, dright, rec.ag_id, rec.dep_id, rec.ch_br, rec.pr_br); -- сумма возврата
      SELECT COUNT(*)
        INTO dec_num
        FROM TABLE(pkg_rep_utils_ins11.get_pol_dec_anderr_id(dleft
                                                            ,dright
                                                            ,rec.ag_id
                                                            ,rec.dep_id
                                                            ,rec.ch_br
                                                            ,rec.pr_br)); -- количество договоров
    
      --активные договора
      act_ape        := TO_NUMBER(get_ape_pol_act(dleft
                                                 ,dright
                                                 ,rec.ag_id
                                                 ,rec.dep_id
                                                 ,rec.ch_br
                                                 ,rec.pr_br)); -- годовая премия
      act_pay_amount := get_pol_pay_amount_act(dleft
                                              ,dright
                                              ,rec.ag_id
                                              ,rec.dep_id
                                              ,rec.ch_br
                                              ,rec.pr_br); -- оплаченная премия
      SELECT COUNT(*)
        INTO act_num
        FROM TABLE(pkg_rep_utils_ins11.get_pol_active_id(dleft
                                                        ,dright
                                                        ,rec.ag_id
                                                        ,rec.dep_id
                                                        ,rec.ch_br
                                                        ,rec.pr_br)); -- количество договоров
    
      -- активные договора с накопленным итогом с начала года
      act_ape_ytd        := TO_NUMBER(get_ape_pol_act(first_day
                                                     ,dright
                                                     ,rec.ag_id
                                                     ,rec.dep_id
                                                     ,rec.ch_br
                                                     ,rec.pr_br)); -- годовая премия
      act_pay_amount_ytd := get_pol_pay_amount_act(first_day
                                                  ,dright
                                                  ,rec.ag_id
                                                  ,rec.dep_id
                                                  ,rec.ch_br
                                                  ,rec.pr_br); -- оплаченная премия
      SELECT COUNT(*)
        INTO act_num_ytd
        FROM TABLE(pkg_rep_utils_ins11.get_pol_active_id(first_day
                                                        ,dright
                                                        ,rec.ag_id
                                                        ,rec.dep_id
                                                        ,rec.ch_br
                                                        ,rec.pr_br)); -- количество договоров
    
      -- договора заключенные и расторгнутые (по иным причинам)
      dec_oth_ape        := TO_NUMBER(get_ape_pol_dec_oth(dleft
                                                         ,dright
                                                         ,rec.ag_id
                                                         ,rec.dep_id
                                                         ,rec.ch_br
                                                         ,rec.pr_br)); -- годовая премия
      dec_oth_pay_amount := get_pol_dec_amount_oth(dleft
                                                  ,dright
                                                  ,rec.ag_id
                                                  ,rec.dep_id
                                                  ,rec.ch_br
                                                  ,rec.pr_br); -- сумма возврата
      SELECT COUNT(*)
        INTO dec_oth_num
        FROM TABLE(pkg_rep_utils_ins11.get_pol_dec_other_id(dleft
                                                           ,dright
                                                           ,rec.ag_id
                                                           ,rec.dep_id
                                                           ,rec.ch_br
                                                           ,rec.pr_br)); -- количество договоров
    
      -- добавляем строки в таблицу
      -- ////////////////////////////////////////////
      insert_row_to_sr_wo(rec.ch_name
                         ,rec.dep_name
                         ,rec.ag_fio
                         ,rec.pr_name
                         ,'Годовая премия (gross)'
                         ,pol_ape);
      insert_row_to_sr_wo(rec.ch_name
                         ,rec.dep_name
                         ,rec.ag_fio
                         ,rec.pr_name
                         ,'Сумма оплаты (gross)'
                         ,pol_pay_amount);
      insert_row_to_sr_wo(rec.ch_name
                         ,rec.dep_name
                         ,rec.ag_fio
                         ,rec.pr_name
                         ,'Количество заключенных договоров'
                         ,pol_num);
    
      insert_row_to_sr_wo(rec.ch_name
                         ,rec.dep_name
                         ,rec.ag_fio
                         ,rec.pr_name
                         ,'APE по расторгнутым договорам'
                         ,dec_ape);
      insert_row_to_sr_wo(rec.ch_name
                         ,rec.dep_name
                         ,rec.ag_fio
                         ,rec.pr_name
                         ,'Сумма возвращенной премии'
                         ,dec_pay_amount);
      insert_row_to_sr_wo(rec.ch_name
                         ,rec.dep_name
                         ,rec.ag_fio
                         ,rec.pr_name
                         ,'Количество расторгнутых договоров'
                         ,dec_num);
    
      insert_row_to_sr_wo(rec.ch_name, rec.dep_name, rec.ag_fio, rec.pr_name, 'APE (net)', act_ape);
      insert_row_to_sr_wo(rec.ch_name
                         ,rec.dep_name
                         ,rec.ag_fio
                         ,rec.pr_name
                         ,'Сумма оплаченной премии (net)'
                         ,act_pay_amount);
      insert_row_to_sr_wo(rec.ch_name
                         ,rec.dep_name
                         ,rec.ag_fio
                         ,rec.pr_name
                         ,'Количество заключенных договоров (net)'
                         ,act_num);
    
      insert_row_to_sr_wo(rec.ch_name
                         ,rec.dep_name
                         ,rec.ag_fio
                         ,rec.pr_name
                         ,'APE YTD (net)'
                         ,act_ape_ytd);
      insert_row_to_sr_wo(rec.ch_name
                         ,rec.dep_name
                         ,rec.ag_fio
                         ,rec.pr_name
                         ,'Оплаченная премия YTD (net)'
                         ,act_pay_amount_ytd);
      insert_row_to_sr_wo(rec.ch_name
                         ,rec.dep_name
                         ,rec.ag_fio
                         ,rec.pr_name
                         ,'Количество договоров YTD (net)'
                         ,act_num_ytd);
    
      insert_row_to_sr_wo(rec.ch_name
                         ,rec.dep_name
                         ,rec.ag_fio
                         ,rec.pr_name
                         ,'APE по иным случаям расторжения'
                         ,dec_oth_ape);
      insert_row_to_sr_wo(rec.ch_name
                         ,rec.dep_name
                         ,rec.ag_fio
                         ,rec.pr_name
                         ,'Сумма возвращенной премии по иным случаям расторжения'
                         ,dec_oth_pay_amount);
      insert_row_to_sr_wo(rec.ch_name
                         ,rec.dep_name
                         ,rec.ag_fio
                         ,rec.pr_name
                         ,'Количество договоров по иным случаям расторжения'
                         ,dec_oth_num);
    
    END LOOP;
    -- обновляем период
    UPDATE rep_sr_wo_prog t SET t.period_name = dleft || ' - ' || dright;
    COMMIT;
  END;

  -- ************************************************************************
  --/////////////////////////END SALES REPORT WITHOUT PROGRAMM///////////////
  -- ************************************************************************

  -- ************************************************************************
  --/////////////////////////SALES REPORT WITH PROGRAMM///////////////
  -- ************************************************************************

  -- Возвращает таблицу договоров, заключенных в указанный период
  -- с указанием агента, агентства, канала продаж и программы
  FUNCTION get_tbl_ag_ch_progr
  (
    dleft  DATE
   ,dright DATE
  ) RETURN tbl_ag_ch_pr
    PIPELINED IS
  BEGIN
    -- находим договра, заключенные в период
    FOR t_rec IN (SELECT DISTINCT tbl.agent_id
                                 ,ins.ent.obj_name('CONTACT', tbl.agent_id) AS agent_fio
                                 ,tbl.dep_id
                                 ,tbl.dep_name
                                 ,tbl.ch_br
                                 ,tbl.ch_name
                                 ,tbl.pr_br
                                 ,tbl.pr_name
                    FROM (SELECT DISTINCT (SELECT tt.ag_id
                                             FROM ins_dwh.rep_sr_ag tt
                                            WHERE tt.pol_id = ph.policy_header_id) AS agent_id
                                         ,ph.agency_id AS dep_id
                                         ,pkg_rep_utils_ins11.get_pol_agency_name(ph.agency_id) AS dep_name
                                         ,sch.brief AS ch_br
                                         ,sch.description AS ch_name
                                         ,tPrLn.brief AS pr_br
                                         ,tPrLn.description AS pr_name
                            FROM ins.ven_p_pol_header ph
                            JOIN ins.ven_t_sales_channel sch
                              ON sch.ID = ph.sales_channel_id
                            JOIN ins.ven_p_policy pp
                              ON pp.policy_id = ph.policy_id
                            JOIN ins.ven_as_asset ass
                              ON ass.p_policy_id = pp.policy_id
                            JOIN ins.ven_p_cover pCov
                              ON pCov.as_asset_id = ass.as_asset_id
                            JOIN ins.ven_t_prod_line_option tPrLnOp
                              ON tPrLnOp.ID = pCov.t_prod_line_option_id
                            JOIN ins.ven_t_product_line tPrLn
                              ON tPrLn.ID = tPrLnOp.product_line_id
                           WHERE ph.start_date BETWEEN dleft AND dright) tbl)
    LOOP
      PIPE ROW(t_rec);
    END LOOP;
    RETURN;
  END;

  -- Возвращает сумму APE по заключенным договорам
  FUNCTION get_ape_policy_pr
  (
    dleft  DATE
   ,dright DATE
   ,ag_id  NUMBER
   ,dep_id NUMBER
   ,ch_br  VARCHAR2
   ,pr_br  VARCHAR2
  ) RETURN NUMBER IS
    summ NUMBER(11, 2);
  BEGIN
    SELECT SUM(pCov.premium)
      INTO summ
      FROM ins.ven_p_pol_header ph
      JOIN ins.ven_p_policy pp
        ON pp.policy_id = ph.policy_id
      JOIN ins.ven_as_asset ass
        ON ass.p_policy_id = pp.policy_id
      JOIN ins.ven_p_cover pCov
        ON pCov.as_asset_id = ass.as_asset_id
      JOIN (SELECT *
              FROM TABLE(pkg_rep_utils_ins11.get_policy_id_pr(dleft
                                                             ,dright
                                                             ,ag_id
                                                             ,dep_id
                                                             ,ch_br
                                                             ,pr_br))) f
        ON ph.policy_header_id = f.COLUMN_VALUE;
    RETURN(TO_CHAR(summ, '000000000D00'));
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  -- Возвращает сумму APE по расторгнутым договорам
  FUNCTION get_ape_pol_dec_pr
  (
    dleft  DATE
   ,dright DATE
   ,ag_id  NUMBER
   ,dep_id NUMBER
   ,ch_br  VARCHAR2
   ,pr_br  VARCHAR2
  ) RETURN NUMBER IS
    summ NUMBER(11, 2);
  BEGIN
    SELECT SUM(pCov.premium)
      INTO summ
      FROM ins.ven_p_pol_header ph
      JOIN ins.ven_p_policy pp
        ON pp.policy_id = ph.policy_id
      JOIN ins.ven_as_asset ass
        ON ass.p_policy_id = pp.policy_id
      JOIN ins.ven_p_cover pCov
        ON pCov.as_asset_id = ass.as_asset_id
      JOIN (SELECT *
              FROM TABLE(pkg_rep_utils_ins11.get_pol_dec_anderr_id_pr(dleft
                                                                     ,dright
                                                                     ,ag_id
                                                                     ,dep_id
                                                                     ,ch_br
                                                                     ,pr_br))) f
        ON ph.policy_header_id = f.COLUMN_VALUE;
    RETURN(TO_CHAR(summ, '000000000D00'));
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  -- Возвращает сумму APE по расторгнутым договорам по иным приичнам
  FUNCTION get_ape_pol_dec_oth_pr
  (
    dleft  DATE
   ,dright DATE
   ,ag_id  NUMBER
   ,dep_id NUMBER
   ,ch_br  VARCHAR2
   ,pr_br  VARCHAR2
  ) RETURN NUMBER IS
    summ NUMBER(11, 2);
  BEGIN
    SELECT SUM(pCov.premium)
      INTO summ
      FROM ins.ven_p_pol_header ph
      JOIN ins.ven_p_policy pp
        ON pp.policy_id = ph.policy_id
      JOIN ins.ven_as_asset ass
        ON ass.p_policy_id = pp.policy_id
      JOIN ins.ven_p_cover pCov
        ON pCov.as_asset_id = ass.as_asset_id
      JOIN (SELECT *
              FROM TABLE(pkg_rep_utils_ins11.get_pol_dec_other_id_pr(dleft
                                                                    ,dright
                                                                    ,ag_id
                                                                    ,dep_id
                                                                    ,ch_br
                                                                    ,pr_br))) f
        ON ph.policy_header_id = f.COLUMN_VALUE;
    RETURN(TO_CHAR(summ, '000000000D00'));
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  -- Возвращает сумму APE по активным договорам
  FUNCTION get_ape_pol_act_pr
  (
    dleft  DATE
   ,dright DATE
   ,ag_id  NUMBER
   ,dep_id NUMBER
   ,ch_br  VARCHAR2
   ,pr_br  VARCHAR2
  ) RETURN NUMBER IS
    summ NUMBER(11, 2);
  BEGIN
    SELECT SUM(pCov.premium)
      INTO summ
      FROM ins.ven_p_pol_header ph
      JOIN ins.ven_p_policy pp
        ON pp.policy_id = ph.policy_id
      JOIN ins.ven_as_asset ass
        ON ass.p_policy_id = pp.policy_id
      JOIN ins.ven_p_cover pCov
        ON pCov.as_asset_id = ass.as_asset_id
      JOIN (SELECT *
              FROM TABLE(pkg_rep_utils_ins11.get_pol_active_id_pr(dleft
                                                                 ,dright
                                                                 ,ag_id
                                                                 ,dep_id
                                                                 ,ch_br
                                                                 ,pr_br))) f
        ON ph.policy_header_id = f.COLUMN_VALUE;
    RETURN(TO_CHAR(summ, '000000000D00'));
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  -- Возвращает сумму оплаченной премии по заключенным договорам
  FUNCTION get_pol_pay_amount_pr
  (
    dleft  DATE
   ,dright DATE
   ,ag_id  NUMBER
   ,dep_id NUMBER
   ,ch_br  VARCHAR2
   ,pr_br  VARCHAR2
  ) RETURN NUMBER IS
    summ NUMBER(11, 2);
  BEGIN
    SELECT SUM(ins.pkg_payment.get_pay_cover_amount_pfa(dleft, dright, pCov.p_cover_id))
      INTO summ
      FROM ins.ven_p_pol_header ph
      JOIN ins.ven_p_policy pp
        ON pp.policy_id = ph.policy_id
      JOIN ins.ven_as_asset ass
        ON ass.p_policy_id = pp.policy_id
      JOIN ins.ven_p_cover pCov
        ON pCov.as_asset_id = ass.as_asset_id
      JOIN (SELECT *
              FROM TABLE(pkg_rep_utils_ins11.get_policy_id_pr(dleft
                                                             ,dright
                                                             ,ag_id
                                                             ,dep_id
                                                             ,ch_br
                                                             ,pr_br))) f
        ON ph.policy_header_id = f.COLUMN_VALUE;
    RETURN(TO_CHAR(summ, '000000000D00'));
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  -- Возвращает сумму оплаченной премии по активным договорам
  FUNCTION get_pol_pay_amount_act_pr
  (
    dleft  DATE
   ,dright DATE
   ,ag_id  NUMBER
   ,dep_id NUMBER
   ,ch_br  VARCHAR2
   ,pr_br  VARCHAR2
  ) RETURN NUMBER IS
    summ NUMBER(11, 2);
  BEGIN
    SELECT SUM(ins.pkg_payment.get_pay_cover_amount_pfa(dleft, dright, pCov.p_cover_id))
      INTO summ
      FROM ins.ven_p_pol_header ph
      JOIN ins.ven_p_policy pp
        ON pp.policy_id = ph.policy_id
      JOIN ins.ven_as_asset ass
        ON ass.p_policy_id = pp.policy_id
      JOIN ins.ven_p_cover pCov
        ON pCov.as_asset_id = ass.as_asset_id
      JOIN (SELECT *
              FROM TABLE(pkg_rep_utils_ins11.get_pol_active_id_pr(dleft
                                                                 ,dright
                                                                 ,ag_id
                                                                 ,dep_id
                                                                 ,ch_br
                                                                 ,pr_br))) f
        ON ph.policy_header_id = f.COLUMN_VALUE;
    RETURN(TO_CHAR(summ, '000000000D00'));
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  -- Возвращает сумму возврата по расторгнутым договорам
  FUNCTION get_pol_dec_amount_pr
  (
    dleft  DATE
   ,dright DATE
   ,ag_id  NUMBER
   ,dep_id NUMBER
   ,ch_br  VARCHAR2
   ,pr_br  VARCHAR2
  ) RETURN NUMBER IS
    summ NUMBER(11, 2);
  BEGIN
    SELECT SUM(pCov.decline_summ)
      INTO summ
      FROM ins.ven_p_pol_header ph
      JOIN ins.ven_p_policy pp
        ON pp.policy_id = ph.policy_id
      JOIN ins.ven_as_asset ass
        ON ass.p_policy_id = pp.policy_id
      JOIN ins.ven_p_cover pCov
        ON pCov.as_asset_id = ass.as_asset_id
      JOIN (SELECT *
              FROM TABLE(pkg_rep_utils_ins11.get_pol_dec_anderr_id_pr(dleft
                                                                     ,dright
                                                                     ,ag_id
                                                                     ,dep_id
                                                                     ,ch_br
                                                                     ,pr_br))) f
        ON ph.policy_header_id = f.COLUMN_VALUE;
    RETURN(TO_CHAR(summ, '000000000D00'));
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  -- Возвращает сумму возврата по расторгнутым договорам по иным причинам
  FUNCTION get_pol_dec_amount_oth_pr
  (
    dleft  DATE
   ,dright DATE
   ,ag_id  NUMBER
   ,dep_id NUMBER
   ,ch_br  VARCHAR2
   ,pr_br  VARCHAR2
  ) RETURN NUMBER IS
    summ NUMBER(11, 2);
  BEGIN
    SELECT SUM(pCov.decline_summ)
      INTO summ
      FROM ins.ven_p_pol_header ph
      JOIN ins.ven_p_policy pp
        ON pp.policy_id = ph.policy_id
      JOIN ins.ven_as_asset ass
        ON ass.p_policy_id = pp.policy_id
      JOIN ins.ven_p_cover pCov
        ON pCov.as_asset_id = ass.as_asset_id
      JOIN (SELECT *
              FROM TABLE(pkg_rep_utils_ins11.get_pol_dec_other_id_pr(dleft
                                                                    ,dright
                                                                    ,ag_id
                                                                    ,dep_id
                                                                    ,ch_br
                                                                    ,pr_br))) f
        ON ph.policy_header_id = f.COLUMN_VALUE;
    RETURN(TO_CHAR(summ, '000000000D00'));
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  -- Возвращает id договоров, заключенных в период
  FUNCTION get_policy_id_pr
  (
    dleft  DATE
   ,dright DATE
   ,ag_id  NUMBER
   ,dep_id NUMBER
   ,ch_br  VARCHAR2
   ,pr_br  VARCHAR2
  ) RETURN tbl_id
    PIPELINED IS
    -- временные переменные
    t_ag_id  VARCHAR2(10); -- id агента
    t_dep_id VARCHAR2(10); -- id агентства
    t_ch_br  VARCHAR2(30); -- cсокращение канала продаж
    t_pr_br  VARCHAR2(30); -- сокращение продукта
  BEGIN
    -- устанавливаем переменные
    IF ag_id IS NULL
    THEN
      t_ag_id := '%';
    ELSE
      t_ag_id := ag_id;
    END IF;
  
    IF dep_id IS NULL
    THEN
      t_dep_id := '%';
    ELSE
      t_dep_id := dep_id;
    END IF;
  
    IF ch_br IS NULL
    THEN
      t_ch_br := '%';
    ELSE
      t_ch_br := ch_br;
    END IF;
  
    IF pr_br IS NULL
    THEN
      t_pr_br := '%';
    ELSE
      t_pr_br := pr_br;
    END IF;
    -- заполняем таблицу
    FOR rec IN (SELECT tbl.policy_header_id
                  FROM (SELECT ph.policy_header_id
                              ,(SELECT tt.ag_id
                                  FROM ins_dwh.rep_sr_ag tt
                                 WHERE tt.pol_id = ph.policy_header_id) AS ag_id
                          FROM ins.ven_p_pol_header ph
                          JOIN ins.ven_t_sales_channel sch
                            ON sch.ID = ph.sales_channel_id
                          JOIN ins.ven_p_policy pp
                            ON pp.policy_id = ph.policy_id
                          JOIN ins.ven_as_asset ass
                            ON ass.p_policy_id = pp.policy_id
                          JOIN ins.ven_p_cover pCov
                            ON pCov.as_asset_id = ass.as_asset_id
                          JOIN ins.ven_t_prod_line_option tPrLnOp
                            ON tPrLnOp.ID = pCov.t_prod_line_option_id
                          JOIN ins.ven_t_product_line tPrLn
                            ON tPrLn.ID = tPrLnOp.product_line_id
                         WHERE ph.start_date BETWEEN dleft AND dright
                           AND NVL(TO_CHAR(ph.agency_id), t_dep_id) LIKE t_dep_id
                           AND NVL(sch.brief, t_ch_br) LIKE t_ch_br
                           AND NVL(tPrLn.brief, t_pr_br) LIKE t_pr_br) tbl
                 WHERE NVL(TO_CHAR(tbl.ag_id), t_ag_id) LIKE t_ag_id)
    LOOP
      PIPE ROW(rec.policy_header_id);
    END LOOP;
    RETURN;
  END;

  -- Возвращает id договров, заключенных и действующий в указанном периоде
  FUNCTION get_pol_active_id_pr
  (
    dleft  DATE
   ,dright DATE
   ,ag_id  NUMBER
   ,dep_id NUMBER
   ,ch_br  VARCHAR2
   ,pr_br  VARCHAR2
  ) RETURN tbl_id
    PIPELINED IS
  BEGIN
    FOR rec IN (SELECT ph.policy_header_id
                  FROM ins.ven_p_pol_header ph
                  JOIN ins.ven_p_policy pp
                    ON pp.policy_id = ph.policy_id
                  JOIN (SELECT *
                         FROM TABLE(pkg_rep_utils_ins11.get_policy_id_pr(dleft
                                                                        ,dright
                                                                        ,ag_id
                                                                        ,dep_id
                                                                        ,ch_br
                                                                        ,pr_br))) tbl
                    ON ph.policy_header_id = tbl.COLUMN_VALUE
                 WHERE NVL(pp.end_date, dright + 1) > dright
                --or pp.end_date is null
                )
    LOOP
      PIPE ROW(rec.policy_header_id);
    END LOOP;
    RETURN;
  END;

  -- Возвращает id договоров, заключенных  и расторгнутым в указанный период
  -- по результатам андерреайтинга или заявлению страхователя
  FUNCTION get_pol_dec_anderr_id_pr
  (
    dleft  DATE
   ,dright DATE
   ,ag_id  NUMBER
   ,dep_id NUMBER
   ,ch_br  VARCHAR2
   ,pr_br  VARCHAR2
  ) RETURN tbl_id
    PIPELINED IS
  BEGIN
    FOR rec IN (SELECT ph.policy_header_id
                  FROM ins.ven_p_pol_header ph
                  JOIN ins.ven_p_policy pp
                    ON pp.policy_id = ph.policy_id
                  JOIN ins.ven_t_decline_reason dr
                    ON dr.t_decline_reason_id = pp.decline_reason_id
                  JOIN (SELECT *
                         FROM TABLE(pkg_rep_utils_ins11.get_policy_id_pr(dleft
                                                                        ,dright
                                                                        ,ag_id
                                                                        ,dep_id
                                                                        ,ch_br
                                                                        ,pr_br))) tbl
                    ON ph.policy_header_id = tbl.COLUMN_VALUE
                 WHERE pp.decline_date BETWEEN dleft AND dright
                   AND dr.brief IN ('ЗаявСтрахователя', 'ОтказВпредПокр'))
    LOOP
      PIPE ROW(rec.policy_header_id);
    END LOOP;
    RETURN;
  END;

  -- Возвращает id договоров, заключенных  и расторгнутым в указанный период
  -- по иным причинам
  FUNCTION get_pol_dec_other_id_pr
  (
    dleft  DATE
   ,dright DATE
   ,ag_id  NUMBER
   ,dep_id NUMBER
   ,ch_br  VARCHAR2
   ,pr_br  VARCHAR2
  ) RETURN tbl_id
    PIPELINED IS
  BEGIN
    FOR rec IN (SELECT ph.policy_header_id
                  FROM ins.ven_p_pol_header ph
                  JOIN ins.ven_p_policy pp
                    ON pp.policy_id = ph.policy_id
                  JOIN ins.ven_t_decline_reason dr
                    ON dr.t_decline_reason_id = pp.decline_reason_id
                  JOIN (SELECT *
                         FROM TABLE(pkg_rep_utils_ins11.get_policy_id_pr(dleft
                                                                        ,dright
                                                                        ,ag_id
                                                                        ,dep_id
                                                                        ,ch_br
                                                                        ,pr_br))) tbl
                    ON ph.policy_header_id = tbl.COLUMN_VALUE
                 WHERE pp.decline_date BETWEEN dleft AND dright
                   AND dr.brief NOT IN
                       ('ЗаявСтрахователя', 'ОтказВпредПокр'))
    LOOP
      PIPE ROW(rec.policy_header_id);
    END LOOP;
    RETURN;
  END;

  -- добавляет строку в таблицу rep_sr_prog
  PROCEDURE insert_row_to_sr_prog
  (
    fchanal VARCHAR2
   ,fdep    VARCHAR2
   ,fagent  VARCHAR2
   ,fprog   VARCHAR2
   ,fparam  VARCHAR2
   ,fvalue  NUMBER
  ) IS
  BEGIN
    INSERT INTO ins_dwh.rep_sr_prog sr
      (chanal, agency, AGENT, programm, param, VALUE)
    VALUES
      (fchanal, fdep, fagent, fprog, fparam, fvalue);
  END;

  -- Вызывает формирование очета Sales Report с детализацией до программы 
  --версия Сергея Сизона 
  PROCEDURE create_period_sr_prog
  (
    dleft  DATE
   ,dright DATE
  ) IS
    -- вспомогательные переменные
    first_day DATE; -- дата начала года 
  
    v_fund_id      NUMBER;
    v_rate_type_id NUMBER;
  
  BEGIN
  
    -- заполняем таблицу соответсвия "договор  - агент" 
    fill_tbl_pol_ag(dleft, dright);
  
    -- вычисляем первую дату года
    first_day := TRUNC(dleft, 'yyyy');
  
    SELECT f.fund_id INTO v_fund_id FROM ins.ven_fund f WHERE f.brief = 'RUR';
  
    SELECT t.rate_type_id INTO v_rate_type_id FROM ins.ven_rate_type t WHERE t.brief = 'ЦБ';
  
    DELETE FROM ins_dwh.rep_sr_prog;
  
    FOR rec IN (SELECT SUM(CASE
                             WHEN ph.start_date BETWEEN dleft AND dright THEN
                              pCov.premium * ins.acc_new.Get_Cross_Rate_By_Id(v_rate_type_id
                                                                             ,ph.fund_id
                                                                             ,v_fund_id
                                                                             ,ph.start_date)
                             ELSE
                              0
                           END) pol_ape
                      ,SUM(CASE
                             WHEN ph.start_date BETWEEN dleft AND dright THEN
                              ins.pkg_payment.get_pay_cover_amount_pfa(dleft, dright, pCov.p_cover_id)
                             ELSE
                              0
                           END) pol_pay_amount
                      ,SUM(CASE
                             WHEN ph.start_date BETWEEN dleft AND dright THEN
                              1
                             ELSE
                              0
                           END) pol_num
                      ,SUM(CASE
                             WHEN ph.start_date BETWEEN dleft AND dright
                                  AND tdr.brief IN
                                  ('ЗаявСтрахователя', 'ОтказВпредПокр')
                                  AND pp.decline_date BETWEEN dleft AND dright THEN
                              pCov.premium * ins.acc_new.Get_Cross_Rate_By_Id(v_rate_type_id
                                                                             ,ph.fund_id
                                                                             ,v_fund_id
                                                                             ,ph.start_date)
                             ELSE
                              0
                           END) dec_ape
                      ,SUM(CASE
                             WHEN ph.start_date BETWEEN dleft AND dright
                                  AND tdr.brief IN
                                  ('ЗаявСтрахователя', 'ОтказВпредПокр')
                                  AND pp.decline_date BETWEEN dleft AND dright THEN
                              pCov.decline_summ *
                              ins.acc_new.Get_Cross_Rate_By_Id(v_rate_type_id
                                                              ,ph.fund_id
                                                              ,v_fund_id
                                                              ,ph.start_date)
                             ELSE
                              0
                           END) dec_pay_amount
                      ,SUM(CASE
                             WHEN ph.start_date BETWEEN dleft AND dright
                                  AND tdr.brief IN
                                  ('ЗаявСтрахователя', 'ОтказВпредПокр')
                                  AND pp.decline_date BETWEEN dleft AND dright THEN
                              1
                             ELSE
                              0
                           END) dec_num
                      ,SUM(CASE
                             WHEN ph.start_date BETWEEN dleft AND dright
                                  AND NVL(pp.end_date, dright + 1) > dright THEN
                              pCov.premium * ins.acc_new.Get_Cross_Rate_By_Id(v_rate_type_id
                                                                             ,ph.fund_id
                                                                             ,v_fund_id
                                                                             ,ph.start_date)
                             ELSE
                              0
                           END) act_ape
                      ,SUM(CASE
                             WHEN ph.start_date BETWEEN dleft AND dright
                                  AND NVL(pp.end_date, dright + 1) > dright THEN
                              ins.pkg_payment.get_pay_cover_amount_pfa(dleft, dright, pCov.p_cover_id)
                             ELSE
                              0
                           END) act_pay_amount
                      ,SUM(CASE
                             WHEN ph.start_date BETWEEN dleft AND dright
                                  AND NVL(pp.end_date, dright + 1) > dright THEN
                              1
                             ELSE
                              0
                           END) act_num
                      ,SUM(CASE
                             WHEN NVL(pp.end_date, dright + 1) > dright THEN
                              pCov.premium * ins.acc_new.Get_Cross_Rate_By_Id(v_rate_type_id
                                                                             ,ph.fund_id
                                                                             ,v_fund_id
                                                                             ,ph.start_date)
                             ELSE
                              0
                           END) act_ape_ytd
                      ,SUM(CASE
                             WHEN NVL(pp.end_date, dright + 1) > dright THEN
                              ins.pkg_payment.get_pay_cover_amount_pfa(first_day, dright, pCov.p_cover_id)
                             ELSE
                              0
                           END) act_pay_amount_ytd
                      ,SUM(CASE
                             WHEN NVL(pp.end_date, dright + 1) > dright THEN
                              1
                             ELSE
                              0
                           END) act_num_ytd
                      ,SUM(CASE
                             WHEN ph.start_date BETWEEN dleft AND dright
                                  AND tdr.brief NOT IN
                                  ('ЗаявСтрахователя', 'ОтказВпредПокр')
                                  AND pp.decline_date BETWEEN dleft AND dright THEN
                              pCov.premium * ins.acc_new.Get_Cross_Rate_By_Id(v_rate_type_id
                                                                             ,ph.fund_id
                                                                             ,v_fund_id
                                                                             ,ph.start_date)
                             ELSE
                              0
                           END) dec_oth_ape
                      ,SUM(CASE
                             WHEN ph.start_date BETWEEN dleft AND dright
                                  AND tdr.brief NOT IN
                                  ('ЗаявСтрахователя', 'ОтказВпредПокр')
                                  AND pp.decline_date BETWEEN dleft AND dright THEN
                              pCov.decline_summ *
                              ins.acc_new.Get_Cross_Rate_By_Id(v_rate_type_id
                                                              ,ph.fund_id
                                                              ,v_fund_id
                                                              ,ph.start_date)
                             ELSE
                              0
                           END) dec_oth_pay_amount
                      ,SUM(CASE
                             WHEN ph.start_date BETWEEN dleft AND dright
                                  AND tdr.brief NOT IN
                                  ('ЗаявСтрахователя', 'ОтказВпредПокр')
                                  AND pp.decline_date BETWEEN dleft AND dright THEN
                              1
                             ELSE
                              0
                           END) dec_oth_num
                      ,tt.ag_id agent_id
                      ,c.obj_name_orig ag_fio
                      ,sch.brief ch_br
                      ,ph.sales_channel_id
                      ,sch.description ch_name
                      ,ph.agency_id dep_id
                      ,pkg_rep_utils_ins11.get_pol_agency_name(ph.agency_id) dep_name
                      ,tPrLn.ID
                      ,tPrLn.brief
                      ,tPrLn.description pr_name
                  FROM ins.ven_p_pol_header ph
                  JOIN ins.ven_p_policy pp
                    ON pp.policy_id = ph.policy_id
                  JOIN ins.ven_t_sales_channel sch
                    ON sch.ID = ph.sales_channel_id
                  JOIN ins.ven_as_asset ass
                    ON ass.p_policy_id = pp.policy_id
                  JOIN ins.ven_p_cover pCov
                    ON pCov.as_asset_id = ass.as_asset_id
                  JOIN ins.ven_t_prod_line_option tPrLnOp
                    ON tPrLnOp.ID = pCov.t_prod_line_option_id
                  JOIN ins.ven_t_product_line tPrLn
                    ON tPrLn.ID = tPrLnOp.product_line_id
                  LEFT JOIN ins_dwh.rep_sr_ag tt
                    ON tt.pol_id = ph.policy_header_id
                  LEFT JOIN ins.ven_contact c
                    ON c.contact_id = tt.ag_id
                  LEFT JOIN ins.ven_t_decline_reason tdr
                    ON tdr.t_decline_reason_id = pp.decline_reason_id
                 WHERE ph.start_date BETWEEN first_day AND dright
                 GROUP BY tt.ag_id
                         ,pCov.P_COVER_ID
                         ,c.obj_name_orig
                         ,ph.sales_channel_id
                         ,sch.brief
                         ,sch.description
                         ,ph.agency_id
                         ,pkg_rep_utils_ins11.get_pol_agency_name(ph.agency_id)
                         ,tPrLn.ID
                         ,tPrLn.brief
                         ,tPrLn.description
                HAVING SUM(CASE
                  WHEN ph.start_date BETWEEN dleft AND dright THEN
                   1
                  ELSE
                   0
                END) > 0)
    LOOP
    
      -- добавляем строки в таблицу 
      -- ////////////////////////////////////////////
    
      insert_row_to_sr_prog(rec.ch_name
                           ,rec.dep_name
                           ,rec.ag_fio
                           ,rec.pr_name
                           ,'Годовая премия (gross)'
                           ,rec.pol_ape);
      insert_row_to_sr_prog(rec.ch_name
                           ,rec.dep_name
                           ,rec.ag_fio
                           ,rec.pr_name
                           ,'Сумма оплаты (gross)'
                           ,rec.pol_pay_amount);
      insert_row_to_sr_prog(rec.ch_name
                           ,rec.dep_name
                           ,rec.ag_fio
                           ,rec.pr_name
                           ,'Количество заключенных договоров'
                           ,rec.pol_num);
    
      insert_row_to_sr_prog(rec.ch_name
                           ,rec.dep_name
                           ,rec.ag_fio
                           ,rec.pr_name
                           ,'APE по расторгнутым договорам'
                           ,rec.dec_ape);
      insert_row_to_sr_prog(rec.ch_name
                           ,rec.dep_name
                           ,rec.ag_fio
                           ,rec.pr_name
                           ,'Сумма возвращенной премии'
                           ,rec.dec_pay_amount);
      insert_row_to_sr_prog(rec.ch_name
                           ,rec.dep_name
                           ,rec.ag_fio
                           ,rec.pr_name
                           ,'Количество расторгнутых договоров'
                           ,rec.dec_num);
    
      insert_row_to_sr_prog(rec.ch_name
                           ,rec.dep_name
                           ,rec.ag_fio
                           ,rec.pr_name
                           ,'APE (net)'
                           ,rec.act_ape);
      insert_row_to_sr_prog(rec.ch_name
                           ,rec.dep_name
                           ,rec.ag_fio
                           ,rec.pr_name
                           ,'Сумма оплаченной премии (net)'
                           ,rec.act_pay_amount);
      insert_row_to_sr_prog(rec.ch_name
                           ,rec.dep_name
                           ,rec.ag_fio
                           ,rec.pr_name
                           ,'Количество заключенных договоров (net)'
                           ,rec.act_num);
    
      insert_row_to_sr_prog(rec.ch_name
                           ,rec.dep_name
                           ,rec.ag_fio
                           ,rec.pr_name
                           ,'APE YTD (net)'
                           ,rec.act_ape_ytd);
      insert_row_to_sr_prog(rec.ch_name
                           ,rec.dep_name
                           ,rec.ag_fio
                           ,rec.pr_name
                           ,'Оплаченная премия YTD (net)'
                           ,rec.act_pay_amount_ytd);
      insert_row_to_sr_prog(rec.ch_name
                           ,rec.dep_name
                           ,rec.ag_fio
                           ,rec.pr_name
                           ,'Количество договоров YTD (net)'
                           ,rec.act_num_ytd);
    
      insert_row_to_sr_prog(rec.ch_name
                           ,rec.dep_name
                           ,rec.ag_fio
                           ,rec.pr_name
                           ,'APE по иным случаям расторжения'
                           ,rec.dec_oth_ape);
      insert_row_to_sr_prog(rec.ch_name
                           ,rec.dep_name
                           ,rec.ag_fio
                           ,rec.pr_name
                           ,'Сумма возвращенной премии по иным случаям расторжения'
                           ,rec.dec_oth_pay_amount);
      insert_row_to_sr_prog(rec.ch_name
                           ,rec.dep_name
                           ,rec.ag_fio
                           ,rec.pr_name
                           ,'Количество договоров по иным случаям расторжения'
                           ,rec.dec_oth_num);
    
    END LOOP;
    COMMIT;
  END;

  -- ************************************************************************
  --/////////////////////////END SALES REPORT WITH PROGRAMM///////////////
  -- ************************************************************************
  PROCEDURE create_period_sales_report
  (
    dleft  DATE
   ,dright DATE
  ) IS
  BEGIN
    -- вызываем построение отчета по продукту
    create_period_sr_wo(dleft, dright);
    -- вызываем построение отчета по программе
    create_period_sr_prog(dleft, dright);
  END;

  -- ************************************************************************
  --///////////////////////// ВЫЗОВЫ ПРОЦЕДУР ///////////////////////////////
  -- ************************************************************************
  FUNCTION f_rep_tr_1
  (
    p_work_date IN DATE
   ,p_error_msg OUT VARCHAR2
  ) RETURN NUMBER IS
    --res number:=0;
    tmonth VARCHAR2(2) := TO_CHAR(p_work_date, 'mm');
    tyear  VARCHAR2(4) := TO_CHAR(p_work_date, 'yyyy');
    st     VARCHAR2(30) := 'Конс';
    cat    VARCHAR2(30) := 'AG';
  BEGIN
    create_month_tr1(tmonth, tyear, st, cat);
    RETURN 0;
  EXCEPTION
    WHEN OTHERS THEN
      p_error_msg := 'Произошла ошибка: ' || SQLCODE || '. ' || SQLERRM;
      RETURN 1;
  END;

  FUNCTION f_rep_tr_2
  (
    p_work_date IN DATE
   ,p_error_msg OUT VARCHAR2
  ) RETURN NUMBER IS
    --res number:=0;
    tmonth VARCHAR2(2) := TO_CHAR(p_work_date, 'mm');
    tyear  VARCHAR2(4) := TO_CHAR(p_work_date, 'yyyy');
  BEGIN
    create_month_tr2(tmonth, tyear);
    RETURN 0;
  EXCEPTION
    WHEN OTHERS THEN
      p_error_msg := 'Произошла ошибка: ' || SQLCODE || '. ' || SQLERRM;
      RETURN 1;
  END;

  FUNCTION f_rep_neb
  (
    p_work_date IN DATE
   ,p_error_msg OUT VARCHAR2
  ) RETURN NUMBER IS
    --res number:=0;
    tdate DATE := p_work_date - 1;
  BEGIN
    create_day_neb(TRUNC(tdate));
    RETURN 0;
  EXCEPTION
    WHEN OTHERS THEN
      p_error_msg := 'Произошла ошибка: ' || SQLCODE || '. ' || SQLERRM;
      RETURN 1;
  END;

  FUNCTION f_rep_payoff
  (
    p_work_date IN DATE
   ,p_error_msg OUT VARCHAR2
  ) RETURN NUMBER IS
    --res number:=0;
    tmonth VARCHAR2(2) := TO_CHAR(p_work_date, 'mm');
    tyear  VARCHAR2(4) := TO_CHAR(p_work_date, 'yyyy');
  BEGIN
    create_month_payoff(tmonth, tyear);
    RETURN 0;
  EXCEPTION
    WHEN OTHERS THEN
      p_error_msg := 'Произошла ошибка: ' || SQLCODE || '. ' || SQLERRM;
      RETURN 1;
  END;

/*
function test return varchar2
is
v_msg varchar2(1000):='';
v_msg2 varchar2 (1000):='';
begin
return f_rep_neb(to_date('01.01.2007'),v_msg);
v_msg2:= v_msg;
end; 
*/

-- ************************************************************************
--///////////////////////// END ВЫЗОВЫ ПРОЦЕДУР ///////////////////////////
-- ************************************************************************

END pkg_rep_utils_ins11;
/

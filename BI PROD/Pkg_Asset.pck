CREATE OR REPLACE PACKAGE pkg_asset IS

  TYPE t_beneficiary_rec IS RECORD(
     contact_id      NUMBER
    ,relation_name   t_contact_rel_type.relationship_dsc%TYPE
    ,part_type_brief t_path_type.brief%TYPE := 'percent'
    ,part_value      as_beneficiary.value%TYPE
    ,currency_brief  fund.brief%TYPE := 'RUR'
    ,COMMENT         as_beneficiary.comments%TYPE);

  TYPE t_beneficiary_array IS TABLE OF t_beneficiary_rec;

  TYPE t_insuree_rec IS RECORD(
     work_group_id NUMBER
    ,hobby_id      NUMBER
    ,profession_id NUMBER);

  TYPE t_assured_rec IS RECORD(
     contact_id            NUMBER
    ,assured_type_brief    t_asset_type.brief%TYPE DEFAULT 'ASSET_PERSON'
    ,hobby_id              NUMBER
    ,smoke_id              NUMBER
    ,profession_id         NUMBER
    ,work_group_id         NUMBER
    ,default_fee           NUMBER
    ,default_ins_amount    NUMBER
    ,cover_array           pkg_cover.t_cover_array
    ,benificiary_array     t_beneficiary_array
    ,credit_account_number as_assured.credit_account_number%TYPE);

  TYPE t_assured_array IS TABLE OF t_assured_rec;

  --test svn
  /**
  * Пакет обслуживания объектов страхования
  * @author Alexander Kalabukhov
  * @version 1
  */

  /**
  * ИД статуса историчного значения 'Новый'
  */
  status_hist_id_new NUMBER;
  /**
  * ИД статуса историчного значения 'Действующий'
  */
  status_hist_id_curr NUMBER;
  /**
  * ИД статуса историчного значения 'Удален'
  */
  status_hist_id_del NUMBER;

  /**
  * Создать и инициализировать объект страхования
  * @author Alexander Kalabukhov
  * @param p_ref_id ИД полиса
  * @param p_p_asset_header_id ИД заголовка объекта страхования
  * @param p_t_asset_type_id ИД типа объекта страхования
  */
  --  function create_as_asset(p_ref_id in number, p_p_asset_header_id in number, p_t_asset_type_id in number) return number;

  /**
  * Скопировать объект страхования по версии полиса
  * Копируется все объекты страхования, за исключением, имеющих статус "Исключен".
  * @author Alexander Kalabukhov
  * @param p_old_id ИД полиса источника
  * @param p_new_id ИД полиса приемника
  */
  PROCEDURE copy_as_asset
  (
    p_old_id IN NUMBER
   ,p_new_id IN NUMBER
  );
  PROCEDURE copy_insured
  (
    p_old_id IN NUMBER
   ,p_new_id IN NUMBER
  );
  /**
  * Скопировать объект страхования по версии полиса
  * Копируется все объекты страхования, за исключением, имеющих статус "Исключен".
  * @author Alexander Kalabukhov
  * @param p_old_id ИД полиса источника
  * @param p_new_id ИД полиса приемника
  * @param p_new_asset_type_id ИД типа Объекта
  */
  PROCEDURE copy_as_asset
  (
    p_old_id            IN NUMBER
   ,p_new_id            IN NUMBER
   ,p_new_asset_type_id IN NUMBER
  );

  /**
  * Скопировать ТС
  * @author Alexander Kalabukhov
  * @param p_old_id ИД ТС источника
  * @param p_new_id ИД ТС приемника
  */
  --procedure copy_as_vehicle(p_old_id in number, p_new_id in number);

  /**
  * Скопировать периоды использования объекта страхования
  * @author Alexander Kalabukhov
  * @param p_old_id ИД объекта страхования источника
  * @param p_new_id ИД объекта страхования приемника
  */
  PROCEDURE copy_as_asset_per
  (
    p_old_id IN NUMBER
   ,p_new_id IN NUMBER
  );

  /**
  * Скопировать водителей по ТС
  * @author Alexander Kalabukhov
  * @param p_old_id ИД ТС источника
  * @param p_new_id ИД ТС приемника
  */
  PROCEDURE copy_as_vehicle_driver
  (
    p_old_id IN NUMBER
   ,p_new_id IN NUMBER
  );

  /**
  * Скопировать данные о доп оборудовании ТС
  * @author Alexander Kalabukhov
  * @param p_old_id ИД ТС источника
  * @param p_new_id ИД ТС приемника
  */
  PROCEDURE copy_as_vehicle_stuff
  (
    p_old_id IN NUMBER
   ,p_new_id IN NUMBER
  );

  /**
  * Скопировать данные об установленных противоугонных системах ТС
  * @author Alexander Kalabukhov
  * @param p_old_id ИД ТС источника
  * @param p_new_id ИД ТС приемника
  */
  PROCEDURE copy_as_vehicle_device
  (
    p_old_id IN NUMBER
   ,p_new_id IN NUMBER
  );

  /**
  * Рассчитать возраст водителя
  * @author Alexander Kalabukhov
  * @param p_p_policy_id ИД полиса
  * @param p_cn_person_id ИД физического лица (водителя)
  * @return Возраст водителя
  */
  FUNCTION calc_driver_age
  (
    p_p_policy_id  IN NUMBER
   ,p_cn_person_id IN NUMBER
  ) RETURN NUMBER;

  /**
  * Рассчитать стаж водителя
  * @author Alexander Kalabukhov
  * @param par_per
  * @param par_pp
  * @return Стаж водителя
  */
  FUNCTION get_staj_driver
  (
    par_per IN NUMBER
   ,par_pp  IN NUMBER
  ) RETURN NUMBER;

  /**
  * Рассчитать на дату p_date остаточную стоимость ТС и ДО с учетом износа
  * @param p_asset_header ИД заголовка объекта страхования
  * @param p_date дата рассчета
  * @return остаточная стоимость
  */
  FUNCTION get_price_asset
  (
    p_asset_header IN NUMBER
   ,p_date         IN DATE
  ) RETURN NUMBER;

  /**
  * Рассчитать на дату p_date остаточную стоимость ДО с учетом износа
  * @param p_asset_header ИД заголовка объекта страхования
  * @param p_date дата рассчета
  * @return остаточная стоимость ДО
  */
  FUNCTION get_price_av_stuff
  (
    p_asset_header IN NUMBER
   ,p_date         IN DATE
  ) RETURN NUMBER;

  /**
  *
  * @author Alexander Kalabukhov
  * @param p_p_policy_id ИД полиса
  * @param p_cn_person_id ИД физического лица (водителя)
  * @return
  */
  FUNCTION calc_driver_start_date
  (
    p_p_policy_id  IN NUMBER
   ,p_cn_person_id IN NUMBER
  ) RETURN DATE;

  /**
  * Перевести мощность в лошадиных силах в киловаты
  * @author Alexander Kalabukhov
  * @param p_val мощность в л.с.
  * @return мощность в квт
  */
  FUNCTION kw_to_hp(p_val IN NUMBER) RETURN NUMBER;

  /**
  * Исключить объект страхования из полиса
  * @param p_p_policy_id ИД полиса
  * @param p_as_asset_id ИД объекта страхования
  */
  PROCEDURE exclude_as_asset
  (
    p_p_policy    NUMBER
   ,p_as_asset_id NUMBER
  );

  /**
  * Выполнить действия после изменения объекта страхования
  * @author Denis Ivanov
  * @param p_as_asset_id ИД объекта старахования
  */
  PROCEDURE after_asset_update(p_as_asset_id NUMBER);

  /**
  * Перевести мощность в лошадиных силах в киловаты
  * @author Alexander Kalabukhov
  * @param p_val мощность в л.с.
  * @return мощность в квт
  */
  FUNCTION get_card_nr RETURN VARCHAR2;

  /**
  * Адрес объекта страхования
  * @author Alexander Kalabukhov
  * @param p_asset_id ИД объекта страхования
  * @return адрес объекта страхования
  */
  FUNCTION get_address(p_asset_id NUMBER) RETURN VARCHAR2;

  /**
  * Список допущенных к управлению для транспортного средства
  * @author Filipp Ganichev
  * @param p_as_vehicle_idИД объекта страхования
  * @return список допущенных к управлению для транспортного средства
  */
  FUNCTION get_as_vehicle_drivers(p_as_vehicle_id NUMBER) RETURN VARCHAR2;

  /**
  * @param p_tst
  * @param p_pol_id
  * @param p_if
  * @return
  */
  FUNCTION get_note
  (
    p_tst    NUMBER
   ,p_pol_id NUMBER
   ,p_if     NUMBER
  ) RETURN VARCHAR2;

  /**
  * Застрахованные объекты (Имущество ЮЛ):
  *     p_res=1 признак наличия (взависимости от типа) - да/нет,
  *        p_res=2 описание,
  *        p_res=3 страховая сумма/стоимость
  * @author Protsvetov Evgeniy
  * @param p_policy_header_id ИД заголовка договора страхования
  *           p_type Тип объекта, кот. необходимо застраховать
  *        p_res Тип результата, который необходимо вернуть
  * @return признак наличия,описание,страховая сумма/стоимость
  */
  FUNCTION get_property_ul
  (
    p_policy_header_id NUMBER
   ,p_type             NUMBER
   ,p_res              NUMBER DEFAULT 1
  ) RETURN VARCHAR2;

  /**
  * Проверка корректности VIN
  * @author Vitaly Ustinov
  * @param p_vin проверяемый VIN
  * @param p_error_msg out текст ошибки
  * @return true/flase
  */
  FUNCTION check_vin
  (
    p_vin       VARCHAR2
   ,p_error_msg OUT VARCHAR2
  ) RETURN BOOLEAN;

  /**
  * Проверка наличия двух одинаковых водителей в списке допущенных к управлению
  * @author Ганичев
  * @param p_as_vehicle_id ИД транспортного средства
  * @param p_contact_id ИД водителя
  * @throw Исключение если есть одинаковые водители
  */
  PROCEDURE check_duplicate_drivers
  (
    p_as_vehicle_id NUMBER
   ,p_contact_id    NUMBER DEFAULT NULL
  );

  /**
  * Проверка правильности задания водителей в контактах по претензии
  * @author Ганичев
  * @param p_claim_header_id ИД заголовка претензии
  * @throw Исключение если задано более одного водителя или водителя нет в списке допущенных к управлению ТС
  */
  PROCEDURE check_claim_driver(p_claim_header_id NUMBER);

  /**
  * Создать объект Застрахованный в полисе
  * @author Ганичев
  * @param p_pol_id ИД полиса
  * @param p_contact_id ИД контакта
  * @param p_work_group_id - ИД группы профессий
  * @return ИД застрахованного
  */
  FUNCTION create_as_assured
  (
    p_pol_id                NUMBER
   ,p_contact_id            NUMBER
   ,p_work_group_id         NUMBER DEFAULT NULL
   ,p_asset_type            VARCHAR2 DEFAULT NULL
   ,p_hobby_id              NUMBER DEFAULT NULL
   ,p_smoke_id              NUMBER DEFAULT NULL
   ,p_profession_id         NUMBER DEFAULT NULL
   ,p_credit_account_number as_assured.credit_account_number%TYPE DEFAULT NULL
  ) RETURN NUMBER;

  /**
  * Создать информацию о страхователе
  * @author Капля П.С.
  * @param p_pol_id ИД полиса
  * @param p_work_group_id - ИД группы профессий
  * @param p_hobby_id - ИД хобби страхвоателя
  * @para, p_profession_id - ИД професии страхователя 
     (если не указано, ставится галка "Профессия не выбрана")
  */
  PROCEDURE create_insuree_info
  (
    p_pol_id        NUMBER
   ,p_work_group_id NUMBER DEFAULT NULL
   ,p_hobby_id      NUMBER DEFAULT NULL
   ,p_profession_id NUMBER DEFAULT NULL
  );

  /**
  * Загрузить застрахованных из промежуточной таблицы в договор страхования
  * @author Ганичев
  * @param p_pol_id ИД полиса
  * @param p_session_id - Номер сессии загрузки
  * @return ИД застрахованного
  */
  FUNCTION load_assured_old
  (
    p_pol_id        NUMBER
   ,p_session_id    NUMBER
   ,p_check_present NUMBER DEFAULT 0
   ,p_out_number    OUT NUMBER
  ) RETURN VARCHAR2;

  FUNCTION load_assured
  (
    p_pol_id     NUMBER
   ,p_session_id NUMBER
   ,p_out_number OUT NUMBER
  ) RETURN VARCHAR2;

  /**
  * служебная, для загрузки списка застрахованных
  * @author Устинов
  * @param p_id - ИД записи загрузки
  * @param p_person_id
  */
  PROCEDURE set_user_person_id
  (
    p_id        NUMBER
   ,p_person_id NUMBER
  );
  PROCEDURE set_user_person_id_old
  (
    p_id        NUMBER
   ,p_person_id NUMBER
  );

  /**
  *Проверка на наличие мин. кол-ва покрытий по полису для каждого объекта
  * @author Чикашова
  * @param p_pol_id - ИД версии договора
  */
  PROCEDURE check_count_cover(par_policy_id NUMBER);
  PROCEDURE copy_as_assured_re
  (
    p_old_id IN NUMBER
   ,p_new_id IN NUMBER
  );

  /*
    Байтин А.
    Добавление выгодоприобретателя застрахованному
  */
  PROCEDURE add_beneficiary
  (
    par_asset_id          NUMBER
   ,par_contact_id        NUMBER
   ,par_value             NUMBER
   ,par_value_type_brief  VARCHAR2 DEFAULT 'percent'
   ,par_currency_brief    VARCHAR2 DEFAULT 'RUR'
   ,par_contact_rel_brief VARCHAR2 DEFAULT NULL
   ,par_comments          VARCHAR2 DEFAULT NULL
   ,par_beneficiary_id    OUT NUMBER
  );

  /*
    Капля П.
    Процедура простого обновления информации о завтрахованном в записи таблицы as_asset
  */
  --PROCEDURE update_asset_info(p_as_asset_id NUMBER);

  /*
    Капля П.
    Процедура создания застрахованных по договору из массива
  */
  PROCEDURE create_assured_from_array
  (
    par_policy_id        NUMBER
   ,par_as_assured_array t_assured_array
   ,par_calc_on_creation BOOLEAN DEFAULT TRUE
  );

  /** Определение даты начала объекта страхования
  *   создана по заявке 282426
  *   @autor Чирков В. Ю.
  *   @param par_as_asset_id - ID объекта страхования
  */
  FUNCTION get_asset_start_date
  (
    par_as_asset_id     NUMBER
   ,par_asset_header_id NUMBER
   ,par_is_group        NUMBER
  ) RETURN DATE;

  /** Определение даты окончания объекта страхования
  *   создана по заявке 282426
  *   @autor Чирков В. Ю.
  *   @param par_as_asset_id - ID объекта страхования
  */
  FUNCTION get_asset_end_date(par_as_asset_id NUMBER) RETURN DATE;

  /*
    Капля П.
    Вынес функцию пересчета СС и премии по застрахованному
  */
  PROCEDURE update_asset_summary
  (
    par_as_asset_id as_asset.as_asset_id%TYPE
   ,par_premium     OUT as_asset.ins_premium%TYPE
   ,par_ins_amount  OUT as_asset.ins_amount%TYPE
  );
  PROCEDURE update_asset_summary(par_as_asset_id as_asset.as_asset_id%TYPE);

  /*
    Капля П.
    Процедура пересчета дат объекта договора страхования (Застрахованного)
  */
  PROCEDURE update_asset_dates(par_as_asset_id as_asset.as_asset_id%TYPE);

  /*
    Капля П.
    Пересчет покрытий по договору
  */
  PROCEDURE recalc_asset(par_asset_id as_asset.as_asset_id%TYPE);

END;
/
CREATE OR REPLACE PACKAGE BODY pkg_asset IS

  gc_pkg_name CONSTANT pkg_trace.t_object_name := 'PKG_ASSET';

  benif_error EXCEPTION;
  PRAGMA EXCEPTION_INIT(benif_error, -20001);

  PROCEDURE log(p_msg VARCHAR2) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    IF p_msg IS NULL
    THEN
      NULL;
    END IF;
    /*insert into tmp_message(text) values (p_msg);
    commit;*/
  END;

  PROCEDURE create_as_asset_per
  (
    p_ref_id     IN NUMBER
   ,p_start_date IN DATE
   ,p_end_date   IN DATE
  ) AS
    v_obj_id NUMBER;
  BEGIN
    SELECT sq_as_asset_per.nextval INTO v_obj_id FROM dual;
    INSERT INTO ven_as_asset_per
      (as_asset_per_id, as_asset_id, start_date, end_date)
    VALUES
      (v_obj_id, p_ref_id, p_start_date, p_end_date);
  END;

  /*
    procedure create_as_vehicle_driver(p_ref_id in number, p_cn_person_id in number)
    as
      v_obj_id number;
    begin
      select sq_as_vehicle_driver.nextval into v_obj_id from dual;
      insert into ven_as_vehicle_driver (as_vehicle_driver_id, as_vehicle_id, cn_person_id)
      values (v_obj_id, p_ref_id, p_cn_person_id);
    end;
  */
  /*
  function create_as_vehicle_osago(p_ref_id in number, p_p_asset_header_id in number) return number
  as
    v_obj_id number;
    v_contact_id number;
    v_is_individual number;
    v_t_vehicle_usage_id number;
    v_t_vehicle_type_id number;
    v_t_vehicle_mark_id number;
    v_cn_contact_address_id number;
    v_start_date date;
    v_end_date date;
  begin
    select sq_as_vehicle.nextval into v_obj_id from dual;
  
    select ppc.contact_id, tct.is_individual, cca.id
    into v_contact_id, v_is_individual, v_cn_contact_address_id
    from p_policy_contact ppc,
         t_contact_pol_role tcpr,
         contact c,
         t_contact_type tct,
         cn_contact_address cca,
         t_address_type tat
    where tcpr.brief = 'Страхователь'
          and ppc.policy_id = p_ref_id
          and tcpr.id = ppc.contact_policy_role_id
          and c.contact_id = ppc.contact_id
          and tct.id = c.contact_type_id
          and cca.contact_id(+) = ppc.contact_id
          and tat.is_default = 1
          and tat.id = cca.address_type;
  
    select t_vehicle_usage_id into v_t_vehicle_usage_id from t_vehicle_usage where is_default = 1;
    select t_vehicle_type_id into v_t_vehicle_type_id from t_vehicle_type where is_default = 1;
    select t_vehicle_mark_id into v_t_vehicle_mark_id from t_vehicle_mark where is_default = 1;
  
    select pp.start_date, pp.end_date
    into v_start_date, v_end_date
    from p_policy pp
    where pp.policy_id = p_ref_id;
  
    insert into ven_as_vehicle (as_vehicle_id, p_policy_id, contact_id, t_vehicle_mark_id,
                                t_vehicle_type_id, t_vehicle_usage_id, cn_contact_address_id,
                                status_hist_id, p_asset_header_id, start_date, end_date)
    values (v_obj_id, p_ref_id, v_contact_id, v_t_vehicle_mark_id, v_t_vehicle_type_id,
            v_t_vehicle_usage_id, v_cn_contact_address_id, status_hist_id_new, p_p_asset_header_id, v_start_date, v_end_date);
  
  
    create_as_asset_per(v_obj_id, v_start_date, v_end_date);
    if v_is_individual = 1 then
      create_as_vehicle_driver(v_obj_id, v_contact_id);
    end if;
  
    return v_obj_id;
  end;
  */
  -- переписать это после показа
  -- 1. Сначала создвавать as_asset (без использования vew)
  /*function create_as_asset(p_ref_id in number, p_p_asset_header_id in number, p_t_asset_type_id in number) return number
  as
    v_obj_id number;
    v_p_asset_header_id number;
    v_t_asset_type_brief varchar2(30);
  begin
    -- Создание заголовка объекта
    v_p_asset_header_id := p_p_asset_header_id;
    if v_p_asset_header_id is null then
      select sq_p_asset_header.nextval into v_p_asset_header_id from dual;
      insert into ven_p_asset_header(p_asset_header_id, t_asset_type_id)
      values(v_p_asset_header_id, p_t_asset_type_id);
    end if;
  
    select brief
    into v_t_asset_type_brief
    from t_asset_type tat
    where tat.t_asset_type_id = p_t_asset_type_id;
    case v_t_asset_type_brief
      when 'VEHICLE_OSAGO' then
        v_obj_id := create_as_vehicle_osago(p_ref_id, v_p_asset_header_id);
    end case;
  
    return v_obj_id;
  end;
   */
  PROCEDURE copy_as_vehicle_driver
  (
    p_old_id IN NUMBER
   ,p_new_id IN NUMBER
  ) AS
    is_n       NUMBER;
    clas       VARCHAR2(2);
    d_s        DATE;
    d_e        DATE;
    col_loss   NUMBER;
    is_end_pol NUMBER;
    v_d_e_prev DATE;
    v_d_s_new  DATE;
  BEGIN
  
    SELECT ph.is_new
          ,ph.start_date
      INTO is_n
          ,d_e -- признак пролонгации, дата начала нового договора и соответственно дата окончания старого +1 день
      FROM as_asset ass
      JOIN p_policy pp
        ON pp.policy_id = ass.p_policy_id
      JOIN p_pol_header ph
        ON ph.policy_header_id = pp.pol_header_id
     WHERE ass.as_asset_id = p_new_id;
  
    v_d_s_new := d_e;
  
    SELECT pp.end_date
      INTO v_d_e_prev
      FROM p_policy pp
          ,as_asset aa
     WHERE pp.policy_id = aa.p_policy_id
       AND aa.as_asset_id = p_old_id;
  
    -- бежим по водителям
    FOR v_r IN (SELECT * FROM ven_as_vehicle_driver t WHERE t.as_vehicle_id = p_old_id)
    LOOP
      SELECT sq_as_vehicle_driver.nextval INTO v_r.as_vehicle_driver_id FROM dual;
      v_r.as_vehicle_id := p_new_id;
      v_r.ext_id        := NULL;
      INSERT INTO ven_as_vehicle_driver VALUES v_r;
    
      IF (is_n = 0)
      THEN
        -- пролонгация
        -- поиск кбм водителя и дата старта последнего заключенном договоре с данным водителем
        BEGIN
          SELECT bm.class
                ,pp.start_date
            INTO clas
                ,d_s
            FROM p_pol_header ph
            JOIN p_policy pp
              ON pp.pol_header_id = ph.policy_header_id
            JOIN ven_as_vehicle av
              ON av.p_policy_id = pp.policy_id
            JOIN as_vehicle_driver avd
              ON avd.as_vehicle_id = av.as_vehicle_id
            JOIN t_bonus_malus bm
              ON bm.t_bonus_malus_id = avd.t_bonus_malus_id
           WHERE avd.cn_person_id = v_r.cn_person_id
             AND av.as_vehicle_id <> p_new_id
             AND pp.version_num = (SELECT MIN(pp1.version_num)
                                     FROM p_policy pp1
                                     JOIN ven_as_vehicle av1
                                       ON av1.p_policy_id = pp1.policy_id
                                     JOIN as_vehicle_driver avd1
                                       ON avd1.as_vehicle_id = av1.as_vehicle_id
                                    WHERE pp1.pol_header_id = pp.policy_id
                                      AND avd1.cn_person_id = v_r.cn_person_id)
             AND rownum = 1
           ORDER BY pp.start_date
                   ,pp.policy_id DESC;
        EXCEPTION
          WHEN no_data_found THEN
            NULL;
        END;
        -- были ли убытки по водителю после даты заключения последнего договора
        SELECT COUNT(DISTINCT ce.c_event_id)
          INTO col_loss
          FROM c_event ce
          JOIN c_claim_header ch
            ON ch.c_event_id = ce.c_event_id
          JOIN c_event_contact cec
            ON cec.c_claim_header_id = ch.c_claim_header_id
          JOIN c_event_contact_role cecr
            ON cecr.c_event_contact_role_id = cec.c_event_contact_role_id
         WHERE cecr.brief = 'Виновник'
           AND cec.cn_person_id = v_r.cn_person_id
           AND ch.declare_date >= d_s
           AND ch.declare_date < d_e;
      
        IF (col_loss > 0)
        THEN
          UPDATE ven_as_vehicle_driver v_dr
             SET v_dr.t_bonus_malus_id = pkg_osago.kbm_prolongation_id(v_r.t_bonus_malus_id, col_loss)
           WHERE v_dr.as_vehicle_driver_id = v_r.as_vehicle_driver_id;
        ELSE
          -- заканчивались ли договора страхования сроком 1 год  позже даты d_s и ранее даты пролонгации
          SELECT COUNT(ph2.policy_header_id)
            INTO is_end_pol
            FROM p_pol_header ph2
            JOIN p_policy pp2
              ON pp2.policy_id = ph2.policy_id
            JOIN t_period tp
              ON tp.id = pp2.period_id
            JOIN ven_as_vehicle av2
              ON av2.p_policy_id = pp2.policy_id
            JOIN as_vehicle_driver avd2
              ON avd2.as_vehicle_id = av2.as_vehicle_id
           WHERE avd2.cn_person_id = v_r.cn_person_id
             AND tp.description = '12 месяцев'
                --AND pp2.end_date >= d_s
             AND MONTHS_BETWEEN(v_d_s_new, v_d_e_prev) <= 12;
          --AND pp2.end_date < d_e;
        
          IF is_end_pol > 0
          THEN
            UPDATE ven_as_vehicle_driver v_dr
               SET v_dr.t_bonus_malus_id = pkg_osago.kbm_prolongation_id(v_r.t_bonus_malus_id, 0)
             WHERE v_dr.as_vehicle_driver_id = v_r.as_vehicle_driver_id;
          END IF;
        END IF;
      END IF;
    END LOOP;
  END;

  PROCEDURE copy_as_vehicle_device
  (
    p_old_id IN NUMBER
   ,p_new_id IN NUMBER
  ) AS
  BEGIN
    INSERT INTO as_vehicle_at_device
      (as_vehicle_at_device_id
      ,ent_id
      ,filial_id
      ,as_vehicle_id
      ,t_model_at_device_id
      ,key_count
      ,ext_id
      ,t_at_device_category_id
      ,t_at_device_type_id
      ,description)
    
      SELECT sq_as_vehicle_at_device.nextval
            ,tt.ent_id
            ,tt.filial_id
            ,p_new_id
            ,tt.t_model_at_device_id
            ,tt.key_count
            ,NULL
            ,tt.t_at_device_category_id
            ,tt.t_at_device_type_id
            ,tt.description
        FROM as_vehicle_at_device tt
       WHERE tt.as_vehicle_id = p_old_id;
  END;

  PROCEDURE copy_as_vehicle_stuff
  (
    p_old_id IN NUMBER
   ,p_new_id IN NUMBER
  ) AS
  BEGIN
    FOR rec IN (SELECT * FROM as_vehicle_stuff vs WHERE vs.as_vehicle_id = p_old_id)
    LOOP
      SELECT sq_as_vehicle_stuff.nextval
            ,p_new_id
            ,NULL
        INTO rec.as_vehicle_stuff_id
            ,rec.as_vehicle_id
            ,rec.ext_id
        FROM dual;
      INSERT INTO as_vehicle_stuff VALUES rec;
    END LOOP;
  END;

  PROCEDURE copy_as_vehicle
  (
    p_old_id IN NUMBER
   ,p_new_id IN NUMBER
  ) AS
    v_r as_vehicle%ROWTYPE;
  BEGIN
    SELECT * INTO v_r FROM as_vehicle WHERE as_vehicle_id = p_old_id;
  
    v_r.as_vehicle_id := p_new_id;
    INSERT INTO as_vehicle VALUES v_r;
  
    copy_as_vehicle_driver(p_old_id, p_new_id);
  
    copy_as_vehicle_stuff(p_old_id, p_new_id);
  
    copy_as_vehicle_device(p_old_id, p_new_id);
  END;

  PROCEDURE copy_as_asset_contact
  (
    p_old_id IN NUMBER
   ,p_new_id IN NUMBER
  ) AS
  BEGIN
    INSERT INTO as_asset_contact ass
      (ass.as_asset_contact_id
      ,ass.ent_id
      ,ass.filial_id
      ,ass.ext_id
      ,ass.as_asset_id
      ,ass.comments
      ,ass.contact_id
      ,ass.t_contact_pol_role_id)
    
      SELECT sq_as_asset_contact.nextval
            ,tt.ent_id
            ,tt.filial_id
            ,tt.ext_id
            ,p_new_id
            ,tt.comments
            ,tt.contact_id
            ,tt.t_contact_pol_role_id
      
        FROM as_asset_contact tt
       WHERE tt.as_asset_id = p_old_id;
  END;

  PROCEDURE copy_as_property
  (
    p_old_id IN NUMBER
   ,p_new_id IN NUMBER
  ) IS
    v_r as_property%ROWTYPE;
  BEGIN
    SELECT * INTO v_r FROM as_property WHERE as_property_id = p_old_id;
  
    v_r.as_property_id := p_new_id;
    INSERT INTO as_property VALUES v_r;
  
    FOR rec IN (SELECT * FROM as_property_stuff a WHERE a.as_property_id = p_old_id)
    LOOP
      SELECT sq_as_property_stuff.nextval
            ,p_new_id
            ,NULL
        INTO rec.as_property_stuff_id
            ,rec.as_property_id
            ,rec.ext_id
        FROM dual;
      INSERT INTO as_property_stuff VALUES rec;
    END LOOP;
    copy_as_asset_contact(p_old_id, p_new_id);
  END;

  PROCEDURE copy_as_assured_re
  (
    p_old_id IN NUMBER
   ,p_new_id IN NUMBER
  ) IS
    v_a as_assured_re%ROWTYPE;
  BEGIN
  
    FOR rec1 IN (SELECT * FROM as_assured_re WHERE p_policy_id = p_old_id)
    LOOP
      SELECT sq_as_assured_re.nextval
            ,p_new_id
        INTO rec1.as_assured_re_id
            ,rec1.p_policy_id
        FROM dual;
      INSERT INTO as_assured_re VALUES rec1;
    END LOOP;
  
    FOR rec2 IN (SELECT *
                   FROM as_assured_cover_re ac
                  WHERE ac.as_assured_re_id IN
                        (SELECT r.as_assured_re_id FROM as_assured_re r WHERE r.p_policy_id = p_new_id))
    LOOP
      SELECT sq_as_assured_cover_re.nextval INTO rec2.as_assured_cover_re_id FROM dual;
      INSERT INTO as_assured_cover_re VALUES rec2;
    END LOOP;
  END;

  PROCEDURE copy_as_assured_orig
  (
    p_old_id IN NUMBER
   ,p_new_id IN NUMBER
  ) IS
    v_r as_assured%ROWTYPE;
  BEGIN
    SELECT * INTO v_r FROM as_assured WHERE as_assured_id = p_old_id;
  
    v_r.as_assured_id := p_new_id;
    INSERT INTO as_assured VALUES v_r;
    -- выгодоприобретатели
    FOR rec IN (SELECT * FROM as_beneficiary a WHERE a.as_asset_id = p_old_id)
    LOOP
      SELECT sq_as_beneficiary.nextval
            ,p_new_id
        INTO rec.as_beneficiary_id
            ,rec.as_asset_id
        FROM dual;
      INSERT INTO as_beneficiary VALUES rec;
    END LOOP;
  END;

  PROCEDURE copy_as_assured
  (
    p_old_id IN NUMBER
   ,p_new_id IN NUMBER
  ) IS
    v_r as_asset_assured%ROWTYPE;
  BEGIN
    SELECT * INTO v_r FROM as_asset_assured WHERE as_asset_assured_id = p_old_id;
  
    v_r.as_asset_assured_id := p_new_id;
    INSERT INTO as_asset_assured VALUES v_r;
    -- выгодоприобретатели
    FOR rec IN (SELECT * FROM as_beneficiary a WHERE a.as_asset_id = p_old_id)
    LOOP
      SELECT sq_as_beneficiary.nextval
            ,p_new_id
        INTO rec.as_beneficiary_id
            ,rec.as_asset_id
        FROM dual;
      INSERT INTO as_beneficiary VALUES rec;
    END LOOP;
  END;

  PROCEDURE copy_as_person_med
  (
    p_old_id IN NUMBER
   ,p_new_id IN NUMBER
  ) IS
    v_apm as_person_med%ROWTYPE;
  BEGIN
    SELECT * INTO v_apm FROM as_person_med WHERE as_person_med_id = p_old_id;
  
    v_apm.as_person_med_id := p_new_id;
  
    --    select t.new_id into v_apm.dms_ins_var_id from tmp_id t where t.old_id = v_apm.dms_ins_var_id;
    INSERT INTO as_person_med VALUES v_apm;
    -- выгодоприобретатели
    FOR rec IN (SELECT * FROM as_beneficiary a WHERE a.as_asset_id = p_old_id)
    LOOP
      SELECT sq_as_beneficiary.nextval
            ,p_new_id
            ,NULL
        INTO rec.as_beneficiary_id
            ,rec.as_asset_id
            ,rec.ext_id
        FROM dual;
      INSERT INTO as_beneficiary VALUES rec;
    END LOOP;
  END;

  PROCEDURE copy_as_asset
  (
    p_old_id IN NUMBER
   ,p_new_id IN NUMBER
  ) AS
    v_old_id NUMBER;
    p_p      p_policy%ROWTYPE;
    p_h      p_pol_header%ROWTYPE;
  BEGIN
    SELECT ph.*
      INTO p_h
      FROM p_policy pp
      JOIN p_pol_header ph
        ON ph.policy_header_id = pp.pol_header_id
     WHERE pp.policy_id = p_new_id;
  
    SELECT pp.* INTO p_p FROM p_policy pp WHERE pp.policy_id = p_new_id;
  
    FOR v_r IN (SELECT t.*
                  FROM as_asset t
                 WHERE t.p_policy_id = p_old_id
                   AND t.status_hist_id <> status_hist_id_del)
    LOOP
      v_old_id := v_r.as_asset_id;
      SELECT sq_as_asset.nextval INTO v_r.as_asset_id FROM dual;
      v_r.p_policy_id := p_new_id;
      v_r.ext_id      := NULL;
    
      -- если пролонгация
      IF (p_h.is_new = 0 AND p_p.version_num = 1)
      THEN
        v_r.status_hist_id := status_hist_id_new;
      ELSE
        IF v_r.status_hist_id = status_hist_id_new
        THEN
          v_r.status_hist_id := status_hist_id_curr;
        END IF;
      END IF;
    
      INSERT INTO as_asset VALUES v_r;
      pkg_cover.copy_p_cover(v_old_id, v_r.as_asset_id);
      copy_as_asset_per(v_old_id, v_r.as_asset_id); -- копируем периоды использования
    
      CASE ent.brief_by_id(v_r.ent_id)
        WHEN 'AS_VEHICLE' THEN
          copy_as_vehicle(v_old_id, v_r.as_asset_id);
        WHEN 'AS_PROPERTY' THEN
          copy_as_property(v_old_id, v_r.as_asset_id);
        WHEN 'AS_ASSET_ASSURED' THEN
          copy_as_assured(v_old_id, v_r.as_asset_id);
        WHEN 'AS_ASSURED' THEN
          copy_as_assured_orig(v_old_id, v_r.as_asset_id);
        WHEN 'AS_PERSON_MED' THEN
          copy_as_person_med(v_old_id, v_r.as_asset_id);
        ELSE
          NULL;
      END CASE;
    END LOOP;
  END;

  PROCEDURE copy_insured
  (
    p_old_id IN NUMBER
   ,p_new_id IN NUMBER
  ) AS
    p_p p_policy%ROWTYPE;
    p_h p_pol_header%ROWTYPE;
  BEGIN
    SELECT ph.*
      INTO p_h
      FROM p_policy pp
      JOIN p_pol_header ph
        ON ph.policy_header_id = pp.pol_header_id
     WHERE pp.policy_id = p_new_id;
  
    SELECT pp.* INTO p_p FROM p_policy pp WHERE pp.policy_id = p_new_id;
  
    FOR v_r IN (SELECT t.* FROM as_insured t WHERE t.policy_id = p_old_id)
    LOOP
      SELECT sq_as_insured.nextval INTO v_r.as_insured_id FROM dual;
      v_r.policy_id := p_new_id;
    
      INSERT INTO as_insured VALUES v_r;
    
    END LOOP;
  END;

  PROCEDURE copy_as_asset
  (
    p_old_id            IN NUMBER
   ,p_new_id            IN NUMBER
   ,p_new_asset_type_id IN NUMBER
  ) AS
    v_old_id        NUMBER;
    v_new_header_id NUMBER;
    p_p             p_policy%ROWTYPE;
    p_h             p_pol_header%ROWTYPE;
  BEGIN
    SELECT ph.*
      INTO p_h
      FROM p_policy pp
      JOIN p_pol_header ph
        ON ph.policy_header_id = pp.pol_header_id
     WHERE pp.policy_id = p_new_id;
  
    SELECT pp.* INTO p_p FROM p_policy pp WHERE pp.policy_id = p_new_id;
  
    SELECT sq_p_asset_header.nextval INTO v_new_header_id FROM dual;
  
    INSERT INTO ven_p_asset_header
      (p_asset_header_id, t_asset_type_id)
    VALUES
      (v_new_header_id, p_new_asset_type_id);
  
    FOR v_r IN (SELECT t.*
                  FROM as_asset t
                 WHERE t.p_policy_id = p_old_id
                   AND t.status_hist_id <> status_hist_id_del)
    LOOP
      v_old_id := v_r.as_asset_id;
    
      SELECT sq_as_asset.nextval INTO v_r.as_asset_id FROM dual;
    
      v_r.p_asset_header_id := v_new_header_id;
      v_r.p_policy_id       := p_new_id;
      v_r.ext_id            := NULL;
      v_r.ins_amount        := NULL;
      v_r.ins_premium       := NULL;
      v_r.deductible_value  := NULL;
      v_r.ins_limit         := NULL;
    
      -- если пролонгация
      IF (p_h.is_new = 0 AND p_p.version_num = 1)
      THEN
        v_r.status_hist_id := status_hist_id_new;
      ELSE
        IF v_r.status_hist_id = status_hist_id_new
        THEN
          v_r.status_hist_id := status_hist_id_curr;
        END IF;
      END IF;
    
      INSERT INTO as_asset VALUES v_r;
    
      -- Pkg_Cover.copy_p_cover(v_old_id, v_r.as_asset_id);
      copy_as_asset_per(v_old_id, v_r.as_asset_id); -- копируем периоды использования
    
      CASE ent.brief_by_id(v_r.ent_id)
        WHEN 'AS_VEHICLE' THEN
          copy_as_vehicle(v_old_id, v_r.as_asset_id);
        WHEN 'AS_PROPERTY' THEN
          copy_as_property(v_old_id, v_r.as_asset_id);
        WHEN 'AS_ASSET_ASSURED' THEN
          copy_as_assured(v_old_id, v_r.as_asset_id);
        WHEN 'AS_ASSURED' THEN
          copy_as_assured_orig(v_old_id, v_r.as_asset_id);
        WHEN 'AS_PERSON_MED' THEN
          copy_as_person_med(v_old_id, v_r.as_asset_id);
        ELSE
          NULL;
      END CASE;
    END LOOP;
  END;

  PROCEDURE copy_as_asset_per
  (
    p_old_id IN NUMBER
   ,p_new_id IN NUMBER
  ) AS
  BEGIN
    FOR v_r IN (SELECT * FROM ven_as_asset_per t WHERE t.as_asset_id = p_old_id)
    LOOP
      SELECT sq_as_asset_per.nextval INTO v_r.as_asset_per_id FROM dual;
      v_r.as_asset_id := p_new_id;
      v_r.ext_id      := NULL;
      INSERT INTO ven_as_asset_per VALUES v_r;
    END LOOP;
  END;

  /*
    function calc_as_vehicle_driver_age(p_as_vehicle_driver_id in number) return number
    as
      v_p_policy_id number;
      v_cn_person_id number;
    begin
       select aa.p_policy_id, avd.cn_person_id into v_p_policy_id, v_cn_person_id
       from as_vehicle_driver avd
            inner join as_asset aa on aa.as_asset_id = avd.as_vehicle_id
       where avd.as_vehicle_driver_id = p_as_vehicle_driver_id;
       return calc_as_vehicle_driver_age(v_p_policy_id, v_cn_person_id);
    end;
  */

  FUNCTION get_price_av_stuff
  (
    p_asset_header IN NUMBER
   ,p_date         IN DATE
  ) RETURN NUMBER AS
    v_price_prev NUMBER;
    --p_1          NUMBER;
    --p_2          NUMBER;
  BEGIN
  
    SELECT ROUND(st.summ * 0.8, 2)
      INTO v_price_prev
      FROM p_asset_header pah
      JOIN as_asset ass
        ON ass.p_asset_header_id = pah.p_asset_header_id
      JOIN p_policy pp
        ON pp.policy_id = ass.p_policy_id
      JOIN (SELECT avs.as_vehicle_id
                  ,SUM(avs.price) summ
              FROM as_vehicle_stuff avs
             GROUP BY avs.as_vehicle_id) st
        ON st.as_vehicle_id = ass.as_asset_id
     WHERE pah.p_asset_header_id = p_asset_header
       AND pp.version_num = (SELECT MAX(pp1.version_num)
                               FROM ins.p_policy       pp1
                                   ,ins.document       d
                                   ,ins.doc_status_ref rf
                              WHERE pp1.pol_header_id = pp.pol_header_id
                                AND pp1.start_date < p_date
                                AND pp1.policy_id = d.document_id
                                AND d.doc_status_ref_id = rf.doc_status_ref_id
                                AND rf.brief != 'CANCEL');
    RETURN v_price_prev;
  
  END;

  FUNCTION get_price_asset
  (
    p_asset_header IN NUMBER
   ,p_date         IN DATE
  ) RETURN NUMBER AS
    v_price      NUMBER;
    v_price_prev NUMBER;
    p_1          NUMBER;
    p_2          NUMBER;
    p_3          NUMBER;
  
  BEGIN
  
    --ищем предыдущую версию
    SELECT ass.ins_price
          , -- пред стр. стоимость
           CASE
             WHEN vt.brief = 'CAR'
                  AND vm.is_national_mark = 1 THEN
              1
             WHEN vt.brief = 'CAR'
                  AND vm.is_national_mark = 0 THEN
              2
             WHEN vt.brief IN ('TRUCK', 'BUS', 'TRUCK_TRAILER') THEN
              4
             ELSE
              3
           END
          ,extract(YEAR FROM p_date) - av.model_year
          , -- возраст ТС на дату
           extract(YEAR FROM pp.start_date) - av.model_year -- возраст ТС на пред дату
      INTO v_price_prev
          ,p_1
          ,p_2
          ,p_3
      FROM p_asset_header pah
      JOIN as_asset ass
        ON ass.p_asset_header_id = pah.p_asset_header_id
      JOIN as_vehicle av
        ON av.as_vehicle_id = ass.as_asset_id
      JOIN t_vehicle_type vt
        ON vt.t_vehicle_type_id = av.t_vehicle_type_id
      JOIN p_policy pp
        ON pp.policy_id = ass.p_policy_id
      JOIN t_vehicle_mark vm
        ON vm.t_vehicle_mark_id = av.t_vehicle_mark_id
     WHERE pah.p_asset_header_id = p_asset_header
       AND pp.version_num = (SELECT MAX(pp1.version_num)
                               FROM ins.p_policy       pp1
                                   ,ins.document       d
                                   ,ins.doc_status_ref rf
                              WHERE pp1.pol_header_id = pp.pol_header_id
                                AND pp1.start_date < p_date
                                AND pp1.policy_id = d.document_id
                                AND d.doc_status_ref_id = rf.doc_status_ref_id
                                AND rf.brief != 'CANCEL');
  
    v_price := v_price_prev;
  
    IF (p_2 = p_3)
    THEN
      RETURN v_price;
    END IF;
  
    FOR cur IN (SELECT w.wear
                  FROM as_vehicle_wear w
                 WHERE w.type = p_1
                   AND w.srok > p_3
                   AND w.srok <= p_2)
    LOOP
      v_price := v_price * cur.wear;
    END LOOP;
    RETURN v_price;
  END;

  FUNCTION calc_driver_age
  (
    p_p_policy_id  IN NUMBER
   ,p_cn_person_id IN NUMBER
  ) RETURN NUMBER AS
    v_date_of_birth DATE;
  BEGIN
    IF p_p_policy_id IS NULL
       OR p_cn_person_id IS NULL
    THEN
      RETURN NULL;
    END IF;
  
    SELECT cp.date_of_birth
      INTO v_date_of_birth
      FROM cn_person cp
     WHERE cp.contact_id = p_cn_person_id;
  
    RETURN trunc(MONTHS_BETWEEN(calc_driver_start_date(p_p_policy_id, p_cn_person_id)
                               ,v_date_of_birth) / 12);
  END;

  FUNCTION calc_driver_start_date
  (
    p_p_policy_id  IN NUMBER
   ,p_cn_person_id IN NUMBER
  ) RETURN DATE AS
    v_result DATE;
  BEGIN
    IF p_p_policy_id IS NULL
       OR p_cn_person_id IS NULL
    THEN
      RETURN NULL;
    END IF;
  
    SELECT start_date
      INTO v_result
      FROM (SELECT pp2.start_date
              FROM p_policy pp
             INNER JOIN p_policy pp2
                ON pp2.pol_header_id = pp.pol_header_id
               AND doc.get_doc_status_brief(pp2.policy_id) IN ('NEW', 'CURRENT')
             INNER JOIN as_asset aa
                ON aa.p_policy_id = pp2.policy_id
               AND aa.status_hist_id IN (status_hist_id_new, status_hist_id_curr)
             INNER JOIN as_vehicle_driver avd
                ON avd.as_vehicle_id = aa.as_asset_id
               AND avd.cn_person_id = p_cn_person_id
             WHERE pp.policy_id = p_p_policy_id
             ORDER BY pp2.version_num) t
     WHERE rownum = 1;
    RETURN v_result;
  EXCEPTION
    WHEN no_data_found THEN
      SELECT pp.start_date INTO v_result FROM p_policy pp WHERE pp.policy_id = p_p_policy_id;
      RETURN v_result;
    WHEN OTHERS THEN
      RAISE;
  END;

  PROCEDURE exclude_as_asset
  (
    p_p_policy    NUMBER
   ,p_as_asset_id NUMBER
  ) IS
    v_asset as_asset%ROWTYPE;
  
    PROCEDURE clear_insured_data(par_policy_id p_policy.policy_id%TYPE) IS
      v_other_assured_exists NUMBER;
    BEGIN
      SELECT COUNT(*)
        INTO v_other_assured_exists
        FROM dual
       WHERE EXISTS (SELECT NULL FROM as_asset aa WHERE aa.p_policy_id = par_policy_id);
    
      IF v_other_assured_exists = 0
      THEN
        DELETE FROM as_insured ai WHERE ai.policy_id = par_policy_id;
      END IF;
    END clear_insured_data;
  BEGIN
    SAVEPOINT covers;
    BEGIN
      -- Исключаем(расторгаем) покрытия. При этом по всем покрытиям должен быть уже посчитан возврат
      -- т.к. вместе с родительскими будут исключены и дочернии
      FOR rec IN (SELECT pc.p_cover_id FROM p_cover pc WHERE pc.as_asset_id = p_as_asset_id)
      LOOP
        BEGIN
          pkg_cover.exclude_cover(rec.p_cover_id);
          -- Покрытие может быть уже удалено, если оно дочернее
        EXCEPTION
          WHEN no_data_found THEN
            NULL;
        END;
      END LOOP;
      SELECT * INTO v_asset FROM as_asset a WHERE a.as_asset_id = p_as_asset_id;
      IF v_asset.status_hist_id = status_hist_id_new
      THEN
        DELETE FROM p_asset_header pah WHERE pah.p_asset_header_id = v_asset.p_asset_header_id;
        clear_insured_data(par_policy_id => v_asset.p_policy_id);
      ELSIF v_asset.status_hist_id = status_hist_id_curr
      THEN
        UPDATE as_asset a SET a.status_hist_id = status_hist_id_del WHERE as_asset_id = p_as_asset_id;
      END IF;
      -- пересчитать премию по полису
      pkg_policy.update_policy_sum(p_p_policy);
    EXCEPTION
      WHEN OTHERS THEN
        ROLLBACK TO SAVEPOINT covers;
        RAISE;
    END;
  END;

  PROCEDURE after_asset_update(p_as_asset_id NUMBER) IS
  BEGIN
    FOR rec IN (SELECT pc.p_cover_id
                  FROM p_cover pc
                 WHERE pc.as_asset_id = p_as_asset_id
                   AND (pc.status_hist_id = status_hist_id_new OR
                       pc.status_hist_id = status_hist_id_curr))
    LOOP
      pkg_cover.update_cover_sum(rec.p_cover_id);
    END LOOP;
    NULL;
  END;

  FUNCTION kw_to_hp(p_val IN NUMBER) RETURN NUMBER AS
  BEGIN
    RETURN ROUND(p_val * 1.35962, 2);
  END;

  FUNCTION get_card_nr RETURN VARCHAR2 IS
    ret_val VARCHAR2(255);
  BEGIN
    SELECT 'Пр' || TRIM(to_char(sq_card_person_med_num.nextval, '00000000')) INTO ret_val FROM dual;
    RETURN ret_val;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  FUNCTION get_address(p_asset_id NUMBER) RETURN VARCHAR2 AS
    v_brief  VARCHAR2(30);
    v_id     NUMBER;
    v_result VARCHAR2(300);
  BEGIN
    SELECT e.brief
          ,aa.contact_id
      INTO v_brief
          ,v_id
      FROM as_asset aa
     INNER JOIN entity e
        ON e.ent_id = aa.ent_id
     WHERE aa.as_asset_id = p_asset_id;
  
    IF v_brief = 'AS_PROPERTY'
    THEN
      SELECT pkg_contact.get_address_name(ap.cn_address_id)
        INTO v_result
        FROM as_property ap
       WHERE ap.as_property_id = p_asset_id;
    ELSE
      v_id     := pkg_contact.get_primary_address(v_id);
      v_result := pkg_contact.get_address_name(v_id);
    END IF;
  
    RETURN v_result;
  END;

  FUNCTION get_as_vehicle_drivers(p_as_vehicle_id NUMBER) RETURN VARCHAR2 IS
    v_driver_names VARCHAR2(2000) := NULL;
    v_as_veh_id    NUMBER;
  BEGIN
    SELECT as_vehicle_id INTO v_as_veh_id FROM ven_as_vehicle WHERE as_vehicle_id = p_as_vehicle_id;
    FOR v_drivers IN (SELECT * FROM ven_as_vehicle_driver WHERE as_vehicle_id = p_as_vehicle_id)
    LOOP
      SELECT nvl2(v_driver_names
                 ,v_driver_names || ', ' || ent.obj_name('CN_PERSON', v_drivers.cn_person_id)
                 ,ent.obj_name('CN_PERSON', v_drivers.cn_person_id))
        INTO v_driver_names
        FROM dual;
    END LOOP;
    RETURN nvl(v_driver_names, 'Без ограничения');
  EXCEPTION
    WHEN no_data_found THEN
      RETURN NULL;
  END;

  FUNCTION get_note
  (
    p_tst    NUMBER
   ,p_pol_id NUMBER
   ,p_if     NUMBER
  ) RETURN VARCHAR2 IS
    note VARCHAR2(2000) := NULL;
  
  BEGIN
  
    IF (p_if = 1)
    THEN
      -- со типу  as_property_stuff
      FOR cur IN (SELECT aps.name
                    FROM p_policy pp
                    JOIN as_asset ass
                      ON ass.p_policy_id = pp.policy_id
                    JOIN as_property ap
                      ON ap.as_property_id = ass.as_asset_id
                    JOIN as_property_stuff aps
                      ON aps.as_property_id = ap.as_property_id
                   WHERE pp.policy_id = p_pol_id
                     AND aps.t_property_stuff_typ_id = p_tst)
      LOOP
        IF note IS NULL
        THEN
          note := note || cur.name;
        ELSE
          note := note || ',';
          note := note || cur.name;
        END IF;
      END LOOP;
    ELSE
      -- по типу объекта страхования
      FOR cur IN (SELECT ass.note
                    FROM p_policy pp
                    JOIN as_asset ass
                      ON ass.p_policy_id = pp.policy_id
                    JOIN as_property ap
                      ON ap.as_property_id = ass.as_asset_id
                    JOIN p_asset_header pah
                      ON ass.p_asset_header_id = pah.p_asset_header_id
                   WHERE pp.policy_id = p_pol_id
                     AND pah.t_asset_type_id = p_tst)
      LOOP
        IF note IS NULL
        THEN
          note := note || cur.note;
        ELSE
          note := note || ',';
          note := note || cur.note;
        END IF;
      END LOOP;
    END IF;
    RETURN note;
  END;

  FUNCTION get_staj_driver
  (
    par_per IN NUMBER
   ,par_pp  IN NUMBER
  ) RETURN NUMBER IS
    v_st    NUMBER;
    v_vod   DATE;
    v_start DATE;
  BEGIN
  
    SELECT pp.start_date INTO v_start FROM p_policy pp WHERE pp.policy_id = par_pp;
  
    BEGIN
      SELECT cp.standing
            ,fod.issue_date
        INTO v_st
            ,v_vod
        FROM cn_person cp
        LEFT JOIN (SELECT ci.contact_id
                         ,ci.issue_date
                     FROM cn_contact_ident ci
                     JOIN t_id_type tt
                       ON ci.id_type = tt.id
                    WHERE tt.brief = 'VOD_UDOS') fod
          ON fod.contact_id = cp.contact_id
       WHERE cp.contact_id = par_per
         AND rownum = 1
       ORDER BY fod.issue_date;
    EXCEPTION
      WHEN no_data_found THEN
        RETURN 0;
    END;
  
    IF (v_st IS NOT NULL)
    THEN
      v_st := extract(YEAR FROM v_start) - v_st;
    ELSIF (v_vod IS NOT NULL)
    THEN
      v_st := trunc(MONTHS_BETWEEN(v_start, v_vod) / 12);
    ELSE
      v_st := 0;
    END IF;
  
    RETURN v_st;
  END;

  FUNCTION get_property_ul
  (
    p_policy_header_id NUMBER
   ,p_type             NUMBER
   ,p_res              NUMBER DEFAULT 1
  ) RETURN VARCHAR2 IS
    p_note VARCHAR2(2000);
    p_sum  VARCHAR2(2000);
  BEGIN
    SELECT obj_note
          ,obj_sum
      INTO p_note
          ,p_sum
      FROM (SELECT CASE obj_name
                      WHEN
                       'Здание ("коробка"), включая стены, перекрытия, кровлю, внутреннюю и внешнюю отделки' THEN
                       1
                      WHEN 'Здание (только "коробка")' THEN
                       2
                      WHEN 'Внутренняя отделка' THEN
                       3
                      WHEN 'Окна, витрины, витражи' THEN
                       4
                      WHEN 'Производственное (технологическое) оборудование' THEN
                       7
                      WHEN 'Офисное оборудование' THEN
                       8
                      WHEN 'Торговое оборудование' THEN
                       9
                      WHEN 'Инструмент/инвентарь' THEN
                       10
                      WHEN 'Мебель' THEN
                       11
                      WHEN 'Запасы готовой продукции/продукции для реализации' THEN
                       13
                      WHEN 'Запасы сырья и материалов' THEN
                       14
                      WHEN 'Запасы в незавершенном производстве' THEN
                       15
                      ELSE
                       12
                    END obj_type
                   ,obj_name
                   ,obj_note
                   ,obj_sum
               FROM (SELECT pst.name obj_name
                            ,pkg_asset.get_note(aps.t_property_stuff_typ_id, pp.policy_id, 1) obj_note
                            ,SUM(aps.ins_sum) || '/' || SUM(aps.ins_price) obj_sum
                        FROM p_pol_header ph
                        JOIN p_policy pp
                          ON pp.pol_header_id = ph.policy_header_id
                         AND pp.version_num = 1
                        JOIN as_asset ass
                          ON ass.p_policy_id = pp.policy_id
                        JOIN as_property ap
                          ON ap.as_property_id = ass.as_asset_id
                        JOIN as_property_stuff aps /*'Перечень имущества, подлежащего страхованиюэ*/
                        ON aps.as_property_id = ap.as_property_id
                      JOIN t_property_stuff_typ pst /*'Вид страхуемого имущества'*/
                        ON pst.t_property_stuff_typ_id = aps.t_property_stuff_typ_id
                     WHERE ph.policy_header_id = p_policy_header_id --52021
                     GROUP BY pst.name
                             ,pkg_asset.get_note(aps.t_property_stuff_typ_id, pp.policy_id, 1))
            UNION
            SELECT 4
                  ,'Окна, витрины, витражи'
                  ,pkg_asset.get_note(pah.t_asset_type_id, pp.policy_id, 2)
                  ,SUM(ass.ins_amount) || '/' || SUM(ass.ins_price)
              FROM p_pol_header ph
              JOIN p_policy pp
                ON pp.pol_header_id = ph.policy_header_id
               AND pp.version_num = 1
              JOIN as_asset ass
                ON ass.p_policy_id = pp.policy_id
              JOIN as_property ap
                ON ap.as_property_id = ass.as_asset_id
              JOIN p_asset_header pah
                ON ass.p_asset_header_id = pah.p_asset_header_id
              JOIN t_asset_type tat
                ON tat.t_asset_type_id = pah.t_asset_type_id
               AND tat.name = 'Стекла, витрины'
             WHERE ph.policy_header_id = p_policy_header_id
             GROUP BY pkg_asset.get_note(pah.t_asset_type_id, pp.policy_id, 2))
     WHERE obj_type = p_type;
  
    CASE
      WHEN p_res = 1 THEN
        RETURN 'Y';
      WHEN p_res = 2 THEN
        RETURN p_note;
      WHEN p_res = 3 THEN
        RETURN p_sum;
    END CASE;
  
  EXCEPTION
    WHEN no_data_found THEN
      IF p_res = 1
      THEN
        RETURN 'N';
      ELSE
        RETURN NULL;
      END IF;
    
  END get_property_ul;

  FUNCTION check_vin
  (
    p_vin       VARCHAR2
   ,p_error_msg OUT NOCOPY VARCHAR2
  ) RETURN BOOLEAN IS
    --
    v_vin   VARCHAR2(17);
    v_vin_1 VARCHAR2(17);
    v_vin_2 VARCHAR2(17);
    --v_l     NUMBER;
    RESULT BOOLEAN DEFAULT TRUE;
  BEGIN
    --
    IF length(p_vin) <> 17
    THEN
      p_error_msg := 'Длина VIN должна составлять 17 символов';
      RETURN FALSE;
    END IF;
    --
    IF p_vin LIKE '%O%'
       OR p_vin LIKE '%Q%'
       OR p_vin LIKE '%I%'
    THEN
      p_error_msg := 'VIN не должен содержать буквы I, O и Q';
      RETURN FALSE;
    END IF;
    --
    v_vin := translate(upper(p_vin)
                      ,'ЙЦУКЕНГШЩЗХЪФЫВАПРОЛДЖЭЯЧСМИТЬБЮ'
                      ,' ');
    IF upper(v_vin) != upper(p_vin)
    THEN
      p_error_msg := 'VIN не должен содержать букв русского алфавита';
      RETURN FALSE;
    END IF;
    --
    v_vin_1 := rtrim(substr(p_vin, 14, 4), '*');
    v_vin_2 := rtrim(v_vin_1, '1234567890');
    --
    IF v_vin_2 IS NOT NULL
    THEN
      p_error_msg := 'Последние четыре символа VIN должны быть цифрами';
      RETURN FALSE;
    END IF;
    --
    RETURN RESULT;
    --
  END;

  PROCEDURE check_duplicate_drivers
  (
    p_as_vehicle_id NUMBER
   ,p_contact_id    NUMBER DEFAULT NULL
  ) IS
    v_dupl_drivers_count NUMBER;
  BEGIN
    SELECT COUNT(*)
      INTO v_dupl_drivers_count
      FROM (SELECT cn_person_id
                  ,as_vehicle_id
                  ,COUNT(*) cnt
              FROM as_vehicle_driver
             GROUP BY cn_person_id
                     ,as_vehicle_id)
     WHERE (cnt > 1 OR cn_person_id = nvl(p_contact_id, 0))
       AND as_vehicle_id = p_as_vehicle_id;
    IF nvl(v_dupl_drivers_count, 0) > 0
    THEN
      raise_application_error(-20110
                             ,'Повторяются водители в списке допущенных к управлению');
    END IF;
  END;

  PROCEDURE check_claim_driver(p_claim_header_id NUMBER) IS
    v_id  NUMBER;
    v_id1 NUMBER;
  BEGIN
    BEGIN
      SELECT ec.cn_person_id
        INTO v_id
        FROM c_event_contact      ec
            ,c_event_contact_role ecr
            ,c_claim_header       ch
       WHERE ec.c_event_contact_role_id = ecr.c_event_contact_role_id
         AND ecr.brief = 'Водитель'
         AND ec.c_event_id = ch.c_event_id
         AND ch.c_claim_header_id = p_claim_header_id;
    EXCEPTION
      WHEN too_many_rows THEN
        raise_application_error(-20100
                               ,'Не может быть задано более 1 водителя');
      WHEN no_data_found THEN
        NULL;
    END;
    IF v_id IS NOT NULL
    THEN
      BEGIN
        SELECT d.cn_person_id
          INTO v_id1
          FROM as_vehicle_driver d
              ,as_vehicle        v
              ,c_claim_header    ch
         WHERE d.as_vehicle_id(+) = v.as_vehicle_id
           AND ch.as_asset_id = v.as_vehicle_id
           AND ch.c_claim_header_id = p_claim_header_id
           AND (d.cn_person_id = v_id OR nvl(v.is_driver_no_lim, 0) = 1);
      EXCEPTION
        WHEN no_data_found THEN
          raise_application_error(-20200
                                 ,'Водителя нет в списке допущенных к управлению');
        WHEN too_many_rows THEN
          NULL;
      END;
    END IF;
  END;
  FUNCTION create_as_assured
  (
    p_pol_id                NUMBER
   ,p_contact_id            NUMBER
   ,p_work_group_id         NUMBER DEFAULT NULL
   ,p_asset_type            VARCHAR2 DEFAULT NULL
   ,p_hobby_id              NUMBER DEFAULT NULL
   ,p_smoke_id              NUMBER DEFAULT NULL
   ,p_profession_id         NUMBER DEFAULT NULL
   ,p_credit_account_number as_assured.credit_account_number%TYPE DEFAULT NULL
  ) RETURN NUMBER IS
    v_ah               NUMBER;
    v_sh               NUMBER;
    v_a                NUMBER;
    v_asset_type       NUMBER;
    v_asset_start_date DATE;
    v_asset_end_date   DATE;
    v_issuer_id        NUMBER;
    v_hobby_id         NUMBER;
    v_gender           NUMBER;
    v_work_group_id    NUMBER;
    --
  BEGIN
    SELECT t_asset_type_id
      INTO v_asset_type
      FROM t_asset_type
     WHERE brief = nvl(p_asset_type, 'ASSET_PERSON');
  
    IF p_work_group_id IS NULL
    THEN
      BEGIN
        SELECT t_work_group_id
          INTO v_work_group_id
          FROM t_work_group
         WHERE description = '1 группа';
      EXCEPTION
        WHEN no_data_found THEN
          raise_application_error(-20001
                                 ,'Не найдена группа профессий с названием "1 группа"');
        WHEN too_many_rows THEN
          raise_application_error(-20001
                                 ,'Найдено несколько групп профессий с названием "1 группа"');
      END;
    ELSE
      v_work_group_id := p_work_group_id;
    END IF;
  
    SELECT sq_p_asset_header.nextval INTO v_ah FROM dual;
    INSERT INTO ven_p_asset_header (p_asset_header_id, t_asset_type_id) VALUES (v_ah, v_asset_type);
  
    /*Получим тип записи, даты страхования, застрахованного, хобби*/
    SELECT status_hist_id INTO v_sh FROM status_hist WHERE brief = 'NEW';
  
    SELECT p.confirm_date
          ,p.end_date
      INTO v_asset_start_date
          ,v_asset_end_date
      FROM ven_p_policy p
     WHERE p.policy_id = p_pol_id;
  
    SELECT sq_as_asset.nextval INTO v_a FROM dual;
  
    SELECT contact_id INTO v_issuer_id FROM v_pol_issuer WHERE policy_id = p_pol_id;
  
    IF p_contact_id IS NOT NULL
    THEN
      SELECT coalesce(p_hobby_id, vcp.hobby_id, 0)
            ,vcp.gender
        INTO v_hobby_id
            ,v_gender
        FROM ven_cn_person vcp
       WHERE vcp.contact_id = p_contact_id;
    ELSE
      v_hobby_id := nvl(p_hobby_id, 0);
      v_gender   := 0;
    END IF;
  
    IF v_hobby_id = 0
    THEN
      SELECT t_hobby_id INTO v_hobby_id FROM t_hobby WHERE description = 'нет';
    END IF;
  
    INSERT INTO ven_as_assured
      (as_assured_id
      ,contact_id
      ,p_policy_id
      ,p_asset_header_id
      ,status_hist_id
      ,start_date
      ,end_date
      ,assured_contact_id
      ,work_group_id
      ,t_hobby_id
      ,gender
      ,smoke_id
      ,is_get_prof
      ,t_profession_id
      ,credit_account_number)
    VALUES
      (v_a
      ,v_issuer_id
      ,p_pol_id
      ,v_ah
      ,v_sh
      ,v_asset_start_date
      ,v_asset_end_date
      ,p_contact_id
      ,p_work_group_id
      ,v_hobby_id
      ,v_gender
      ,p_smoke_id
      ,nvl2(p_profession_id, 0, 1)
      ,p_profession_id
      ,p_credit_account_number);
  
    RETURN v_a;
  END;

  PROCEDURE create_insuree_info
  (
    p_pol_id        NUMBER
   ,p_work_group_id NUMBER DEFAULT NULL
   ,p_hobby_id      NUMBER DEFAULT NULL
   ,p_profession_id NUMBER DEFAULT NULL
  ) IS
    v_hobby_id        NUMBER;
    v_gender          NUMBER;
    v_work_group_id   NUMBER;
    v_contact_id      NUMBER;
    v_start_date      DATE;
    v_date_of_birth   DATE;
    v_age             NUMBER;
    v_insuree_info_id NUMBER;
  BEGIN
  
    SELECT pi.contact_id
          ,pp.start_date
          ,cp.date_of_birth
      INTO v_contact_id
          ,v_start_date
          ,v_date_of_birth
      FROM v_pol_issuer pi
          ,p_policy     pp
          ,cn_person    cp
     WHERE pi.policy_id = p_pol_id
       AND pp.policy_id = pi.policy_id
       AND pi.contact_id = cp.contact_id(+);
  
    BEGIN
      SELECT coalesce(p_hobby_id, vcp.hobby_id, 0)
            ,vcp.gender
        INTO v_hobby_id
            ,v_gender
        FROM ven_cn_person vcp
       WHERE vcp.contact_id = v_contact_id;
    EXCEPTION
      WHEN no_data_found THEN
        v_hobby_id := nvl(p_hobby_id, 0);
        v_gender   := 0;
    END;
  
    IF v_hobby_id = 0
    THEN
      SELECT t_hobby_id INTO v_hobby_id FROM t_hobby WHERE description = 'нет';
    END IF;
  
    IF p_work_group_id IS NULL
    THEN
      BEGIN
        SELECT t_work_group_id
          INTO v_work_group_id
          FROM t_work_group
         WHERE description = '1 группа';
      EXCEPTION
        WHEN no_data_found THEN
          raise_application_error(-20001
                                 ,'Не найдена группа профессий с названием "1 группа"');
        WHEN too_many_rows THEN
          raise_application_error(-20001
                                 ,'Найдено несколько групп профессий с названием "1 группа"');
      END;
    ELSE
      v_work_group_id := p_work_group_id;
    END IF;
  
    IF v_date_of_birth IS NOT NULL
    THEN
      v_age := trunc(MONTHS_BETWEEN(v_start_date, v_date_of_birth) / 12);
    END IF;
  
    BEGIN
    
      SELECT as_insured_id INTO v_insuree_info_id FROM as_insured t WHERE t.policy_id = p_pol_id;
    
      UPDATE as_insured t
         SET t.gender             = v_gender
            ,t.t_hobby_id         = v_hobby_id
            ,t.insured_contact_id = v_contact_id
            ,t.is_get_prof        = nvl2(p_profession_id, 0, 1)
            ,t.work_group_id      = p_work_group_id
            ,t.t_profession_id    = p_profession_id
            ,t.insured_age        = v_age
       WHERE t.as_insured_id = v_insuree_info_id;
    
    EXCEPTION
      WHEN no_data_found THEN
      
        INSERT INTO ven_as_insured
          (gender
          ,t_hobby_id
          ,insured_contact_id
          ,is_get_prof
          ,policy_id
          ,work_group_id
          ,t_profession_id
          ,insured_age)
        VALUES
          (v_gender
          ,v_hobby_id
          ,v_contact_id
          ,nvl2(p_profession_id, 0, 1)
          ,p_pol_id
          ,p_work_group_id
          ,p_profession_id
          ,v_age);
    END;
  
  END create_insuree_info;

  PROCEDURE recalc_asset(par_asset_id as_asset.as_asset_id%TYPE) IS
  BEGIN
    FOR rec IN (SELECT pc.p_cover_id
                  FROM p_cover pc
                 WHERE pc.as_asset_id = par_asset_id
                   AND pc.status_hist_id <> pkg_cover.status_hist_id_del
                 ORDER BY (SELECT plt.sort_order
                             FROM t_prod_line_option  plo
                                 ,t_product_line      pl
                                 ,t_product_line_type plt
                            WHERE pc.t_prod_line_option_id = plo.id
                              AND plo.product_line_id = pl.id
                              AND pl.product_line_type_id = plt.product_line_type_id))
    LOOP
      pkg_cover.update_cover_sum(p_p_cover_id => rec.p_cover_id);
    END LOOP;
  END recalc_asset;

  PROCEDURE update_asset_summary
  (
    par_as_asset_id as_asset.as_asset_id%TYPE
   ,par_premium     OUT as_asset.ins_premium%TYPE
   ,par_ins_amount  OUT as_asset.ins_amount%TYPE
  ) IS
    vc_proc_name CONSTANT pkg_trace.t_object_name := 'UPDATE_ASSET_SUMMARY';
    v_fee                   NUMBER;
    ins_amount_recalculated NUMBER;
    v_asset_ent_id CONSTANT entity.ent_id%TYPE := ent.id_by_brief('AS_ASSET');
  BEGIN
  
    SELECT SUM(CASE
                 WHEN at.is_ins_prem_agregate = 1 THEN
                  nvl(pc.premium, 0)
                 ELSE
                  0
               END) premium
          ,SUM(CASE
                 WHEN at.is_ins_fee_agregate = 1 THEN
                  nvl(pc.fee, 0)
                 ELSE
                  0
               END) fee
          ,SUM(CASE
                 WHEN at.is_ins_amount_agregate = 1
                      AND (at.is_ins_amount_date = 0 OR SYSDATE BETWEEN pc.start_date AND pc.end_date) THEN
                  nvl(CASE
                        WHEN at.ins_amount_func_id IS NULL THEN
                         pc.ins_amount
                        ELSE
                         pkg_tariff_calc.calc_fun(at.ins_amount_func_id, v_asset_ent_id, par_as_asset_id)
                      END
                     ,0)
                 ELSE
                  0
               END) ins_amount
          ,COUNT(CASE
                   WHEN at.is_ins_amount_agregate = 1
                        AND (at.is_ins_amount_date = 0 OR SYSDATE BETWEEN pc.start_date AND pc.end_date) THEN
                    1
                   ELSE
                    NULL
                 END) ins_amount_recalculated
      INTO par_premium
          ,v_fee
          ,par_ins_amount
          ,ins_amount_recalculated
      FROM p_cover             pc
          ,t_prod_line_option  plo
          ,t_as_type_prod_line at
          ,t_product_line      pl
          ,p_asset_header      ah
          ,as_asset            a
     WHERE pc.as_asset_id = par_as_asset_id
       AND pc.status_hist_id != pkg_cover.get_status_hist_id_del
       AND pc.t_prod_line_option_id = plo.id
       AND plo.product_line_id = pl.id
       AND pl.for_premium = 1
       AND pc.as_asset_id = a.as_asset_id
       AND a.p_asset_header_id = ah.p_asset_header_id
       AND at.product_line_id = pl.id
       AND at.asset_common_type_id = ah.t_asset_type_id;
  
    UPDATE as_asset a
       SET a.fee         = v_fee
          ,a.ins_premium = par_premium
          ,a.ins_amount = CASE
                            WHEN ins_amount_recalculated > 0 THEN
                             par_ins_amount
                            ELSE
                             a.ins_amount
                          END
     WHERE a.as_asset_id = par_as_asset_id
    RETURNING a.ins_amount INTO par_ins_amount;
  
  END update_asset_summary;

  PROCEDURE update_asset_summary(par_as_asset_id as_asset.as_asset_id%TYPE) IS
    v_premium    as_asset.ins_premium%TYPE;
    v_ins_amount as_asset.ins_amount%TYPE;
  BEGIN
    update_asset_summary(par_as_asset_id => par_as_asset_id
                        ,par_premium     => v_premium
                        ,par_ins_amount  => v_ins_amount);
  END update_asset_summary;

  PROCEDURE update_asset_dates(par_as_asset_id as_asset.as_asset_id%TYPE) IS
    vc_proc_name CONSTANT pkg_trace.t_object_name := 'UPDATE_ASSET_DATES';
    v_start_date      DATE;
    v_end_date        DATE;
    v_asset_header_id as_asset.p_asset_header_id%TYPE;
    v_is_group_flag   p_policy.is_group_flag%TYPE;
  BEGIN
    pkg_trace.add_variable(par_trace_var_name  => 'par_as_asset_id'
                          ,par_trace_var_value => par_as_asset_id);
    pkg_trace.trace_procedure_start(par_trace_obj_name    => gc_pkg_name
                                   ,par_trace_subobj_name => vc_proc_name);
  
    SELECT aa.p_asset_header_id
          ,pp.is_group_flag
      INTO v_asset_header_id
          ,v_is_group_flag
      FROM as_asset aa
          ,p_policy pp
     WHERE aa.as_asset_id = par_as_asset_id
       AND aa.p_policy_id = pp.policy_id;
  
    v_start_date := get_asset_start_date(par_as_asset_id, v_asset_header_id, v_is_group_flag);
    v_end_date   := get_asset_end_date(par_as_asset_id);
  
    pkg_trace.add_variable(par_trace_var_name => 'v_start_date', par_trace_var_value => v_start_date);
    pkg_trace.add_variable(par_trace_var_name => 'v_end_date', par_trace_var_value => v_end_date);
    pkg_trace.trace(par_trace_obj_name    => gc_pkg_name
                   ,par_trace_subobj_name => vc_proc_name
                   ,par_message           => 'Обновление дат начала и окончания объекта страхования');
  
    UPDATE as_asset a
       SET a.start_date = v_start_date
          ,a.end_date   = v_end_date
     WHERE a.as_asset_id = par_as_asset_id;
  
    pkg_trace.trace_procedure_end(par_trace_obj_name    => gc_pkg_name
                                 ,par_trace_subobj_name => vc_proc_name);
  
  END update_asset_dates;

  PROCEDURE create_assured_from_array
  (
    par_policy_id        NUMBER
   ,par_as_assured_array t_assured_array
   ,par_calc_on_creation BOOLEAN DEFAULT TRUE
  ) IS
    v_as_assured_rec     t_assured_rec;
    v_asset_id           NUMBER;
    v_beneficiary_record pkg_asset.t_beneficiary_rec;
    v_beneficiary_id     NUMBER;
  BEGIN
    IF par_as_assured_array IS NOT NULL
       AND par_as_assured_array.count > 0
    THEN
      FOR i IN par_as_assured_array.first .. par_as_assured_array.last
      LOOP
        v_as_assured_rec := par_as_assured_array(i);
        /* Заполняем информацию о застрахованном */
        v_asset_id := create_as_assured(p_pol_id                => par_policy_id
                                       ,p_contact_id            => v_as_assured_rec.contact_id
                                       ,p_work_group_id         => v_as_assured_rec.work_group_id
                                       ,p_asset_type            => v_as_assured_rec.assured_type_brief
                                       ,p_hobby_id              => v_as_assured_rec.hobby_id
                                       ,p_smoke_id              => v_as_assured_rec.smoke_id
                                       ,p_credit_account_number => v_as_assured_rec.credit_account_number);
      
        /* Создаем покрытия */
        pkg_cover.create_cover_from_array(par_as_asset_id        => v_asset_id
                                         ,par_cover_array        => v_as_assured_rec.cover_array
                                         ,par_default_fee        => v_as_assured_rec.default_fee
                                         ,par_default_ins_amount => v_as_assured_rec.default_ins_amount
                                         ,par_update_cover_sum   => par_calc_on_creation);
      
        /* Привязываем выгодоприобретателей */
        IF v_as_assured_rec.benificiary_array IS NOT NULL AND v_as_assured_rec.benificiary_array.count > 0 
        THEN
          FOR j IN v_as_assured_rec.benificiary_array.first .. v_as_assured_rec.benificiary_array.last
          LOOP
            v_beneficiary_record := v_as_assured_rec.benificiary_array(j);        
            v_beneficiary_id := NULL;
            BEGIN
              add_beneficiary(par_asset_id          => v_asset_id
                             ,par_contact_id        => v_beneficiary_record.contact_id
                             ,par_contact_rel_brief => v_beneficiary_record.relation_name
                             ,par_value             => v_beneficiary_record.part_value
                             ,par_value_type_brief  => v_beneficiary_record.part_type_brief
                             ,par_currency_brief    => v_beneficiary_record.currency_brief
                             ,par_comments          => v_beneficiary_record.comment
                             ,par_beneficiary_id    => v_beneficiary_id);
            EXCEPTION
              WHEN benif_error THEN
                add_beneficiary(par_asset_id          => v_asset_id
                               ,par_contact_id        => v_beneficiary_record.contact_id
                               ,par_contact_rel_brief => 'Другой'
                               ,par_value             => v_beneficiary_record.part_value
                               ,par_value_type_brief  => v_beneficiary_record.part_type_brief
                               ,par_currency_brief    => v_beneficiary_record.currency_brief
                               ,par_comments          => v_beneficiary_record.comment
                               ,par_beneficiary_id    => v_beneficiary_id);
            END;
          END LOOP;
        END IF;
      
        /* Обновляем суммы и сроки действия asset'а */
        IF par_calc_on_creation
        THEN
          update_asset_summary(par_as_asset_id => v_asset_id);
        END IF;
      
        -- Рассчитываем даты объекта страхвоания
        update_asset_dates(par_as_asset_id => v_asset_id);
      END LOOP;
    END IF;
  END create_assured_from_array;

  FUNCTION get_assured_group
  (
    p_gr_name VARCHAR2
   ,p_pol_id  NUMBER
  ) RETURN NUMBER IS
    v_pgr_id NUMBER; -- Группа в полисе
    v_gr_id  NUMBER; -- Группа
  BEGIN
    IF TRIM(p_gr_name) IS NULL
    THEN
      RETURN NULL;
    END IF;
    BEGIN
      SELECT pag.p_pol_assured_group_id
        INTO v_pgr_id
        FROM p_pol_assured_group pag
            ,p_assured_group     ag
       WHERE ag.p_assured_group_id = pag.assured_group_id
         AND lower(ag.name) = lower(TRIM(p_gr_name))
         AND pag.policy_id = p_pol_id
         AND rownum < 2;
    EXCEPTION
      WHEN no_data_found THEN
        BEGIN
          SELECT ag.p_assured_group_id
            INTO v_gr_id
            FROM p_assured_group ag
           WHERE lower(ag.name) = lower(TRIM(p_gr_name))
             AND rownum < 2;
        EXCEPTION
          WHEN no_data_found THEN
            SELECT sq_p_assured_group.nextval INTO v_gr_id FROM dual;
            INSERT INTO ven_p_assured_group (p_assured_group_id, NAME) VALUES (v_gr_id, p_gr_name);
        END;
        SELECT sq_p_pol_assured_group.nextval INTO v_pgr_id FROM dual;
        INSERT INTO ven_p_pol_assured_group
          (p_pol_assured_group_id, policy_id, assured_group_id)
        VALUES
          (v_pgr_id, p_pol_id, v_gr_id);
    END;
    RETURN v_pgr_id;
  END;

  PROCEDURE set_loaded_flag_old
  (
    p_id   NUMBER
   ,p_flag NUMBER
  ) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    UPDATE as_assured_load_tmp_old SET is_loaded = p_flag WHERE as_assured_load_tmp_old_id = p_id;
    COMMIT;
  END;

  PROCEDURE set_loaded_flag
  (
    p_id   NUMBER
   ,p_flag NUMBER
  ) IS
    --    PRAGMA autonomous_transaction;
  BEGIN
    UPDATE as_assured_load_tmp SET is_loaded = p_flag WHERE as_assured_load_tmp_id = p_id;
    --    COMMIT WORK WRITE BATCH;
  END;

  PROCEDURE set_user_person_id
  (
    p_id        NUMBER
   ,p_person_id NUMBER
  ) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    UPDATE as_assured_load_tmp SET user_person_id = p_person_id WHERE as_assured_load_tmp_id = p_id;
    COMMIT;
  END;

  PROCEDURE set_user_person_id_old
  (
    p_id        NUMBER
   ,p_person_id NUMBER
  ) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    UPDATE as_assured_load_tmp_old
       SET user_person_id = p_person_id
     WHERE as_assured_load_tmp_old_id = p_id;
    COMMIT;
  END;

  FUNCTION load_assured_old
  (
    p_pol_id        NUMBER
   ,p_session_id    NUMBER
   ,p_check_present NUMBER DEFAULT 0
   ,p_out_number    OUT NUMBER
  ) RETURN VARCHAR2 IS
    v_contact_id    NUMBER;
    v_as_assured_id NUMBER;
    v_work_group_id NUMBER;
  
    v_death_pl_id                NUMBER; -- Смерть по любой причине
    v_failing_mortally_ill_pl_id NUMBER; -- ПДСОЗ
    v_hospitalization_pl_id      NUMBER; -- Госпитализация по любой причине
    v_accident_pl_id             NUMBER; -- Страхование от несчастных случаев
    v_disability_pl_id           NUMBER; -- Инвалидность по любой причине
  
    v_accident_death_pl_id       NUMBER; -- Смерть в результате НС
    v_accident_disability_pl_id  NUMBER; -- Инвалидность в результате НС
    v_accident_trauma_pl_id      NUMBER; -- Телесн. повреждения в рез-те НС
    v_acc_hospitalization_pl_id  NUMBER; -- Госпитализация в рез-те НС
    v_acc_temp_disablement_pl_id NUMBER; -- Врем. нетрудоспособность в рез-те НС
  
    v_cover_id   NUMBER;
    v_asset_sum  NUMBER;
    v_asset_prem NUMBER;
    v_group_id   NUMBER; -- Группа застрахованных в полисе
  
    v_product_brief VARCHAR2(100);
  
    v_as_status_hist NUMBER;
    v_prem           NUMBER;
    v_sum            NUMBER;
  
    v_def_decline_reason_id NUMBER;
    v_def_decline_party_id  NUMBER;
    v_decline_date          DATE;
  
    v_pay_term NUMBER; -- периодичность выплат
    v_new_prem NUMBER;
    v_fee      NUMBER;
  
    PROCEDURE raise_app_error
    (
      p_asset as_assured_load_tmp_old%ROWTYPE
     ,p_msg   VARCHAR2
    ) IS
    BEGIN
      raise_application_error(-20100
                             ,p_msg || ' :: Объект: ' || p_asset.first_name || ' ' ||
                              p_asset.middle_name || ' ' || p_asset.last_name || ' ,дата рождения ' ||
                              to_char(p_asset.birth_date, 'DD.MM.YYYY'));
    END;
  
  BEGIN
  
    pkg_cover.cover_property_cache.delete;
  
    SELECT pr.brief
      INTO v_product_brief
      FROM t_product    pr
          ,p_policy     p
          ,p_pol_header ph
     WHERE pr.product_id = ph.product_id
       AND ph.policy_header_id = p.pol_header_id
       AND p.policy_id = p_pol_id;
    BEGIN
      SELECT t_decline_reason_id
        INTO v_def_decline_reason_id
        FROM t_decline_reason
       WHERE brief = 'ЗаявСтрахователя';
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20100
                               ,'Не найдена запись в справочнике: T_DECLINE_REASON (brief=ЗаявСтрахователя)');
    END;
  
    BEGIN
      SELECT t_decline_party_id
        INTO v_def_decline_party_id
        FROM t_decline_party
       WHERE brief = 'Страхователь';
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20100
                               ,'Не найдена запись в справочнике: T_DECLINE_PARTY (brief=Страхователь)');
    END;
  
    SELECT (trunc(p.start_date, 'DD') - 1)
      INTO v_decline_date
      FROM p_policy p
     WHERE p.policy_id = p_pol_id;
  
    BEGIN
      SELECT pl.id
        INTO v_death_pl_id
        FROM t_product         p
            ,t_product_line    pl
            ,t_product_ver_lob vl
            ,t_product_version v
       WHERE p.brief = v_product_brief
         AND pl.brief = 'DEATH_ANY_CAUSE'
         AND p.product_id = v.product_id
         AND vl.t_product_ver_lob_id = pl.product_ver_lob_id
         AND vl.product_version_id = v.t_product_version_id;
    EXCEPTION
      WHEN no_data_found THEN
        NULL;
    END;
  
    BEGIN
      SELECT pl.id
        INTO v_failing_mortally_ill_pl_id
        FROM t_product         p
            ,t_product_line    pl
            ,t_product_ver_lob vl
            ,t_product_version v
       WHERE p.brief = v_product_brief
         AND pl.brief = 'FAILING_MORTALLY_ILL'
         AND p.product_id = v.product_id
         AND vl.t_product_ver_lob_id = pl.product_ver_lob_id
         AND vl.product_version_id = v.t_product_version_id;
    EXCEPTION
      WHEN no_data_found THEN
        NULL;
    END;
  
    BEGIN
      SELECT pl.id
        INTO v_disability_pl_id
        FROM t_product         p
            ,t_product_line    pl
            ,t_product_ver_lob vl
            ,t_product_version v
       WHERE p.brief = v_product_brief
         AND pl.brief = 'DISABILITY'
         AND p.product_id = v.product_id
         AND vl.t_product_ver_lob_id = pl.product_ver_lob_id
         AND vl.product_version_id = v.t_product_version_id;
    EXCEPTION
      WHEN no_data_found THEN
        NULL;
    END;
  
    BEGIN
      SELECT pl.id
        INTO v_hospitalization_pl_id
        FROM t_product         p
            ,t_product_line    pl
            ,t_product_ver_lob vl
            ,t_product_version v
       WHERE p.brief = v_product_brief
         AND pl.brief = 'HOSPITALIZATION'
         AND p.product_id = v.product_id
         AND vl.t_product_ver_lob_id = pl.product_ver_lob_id
         AND vl.product_version_id = v.t_product_version_id;
    EXCEPTION
      WHEN no_data_found THEN
        NULL;
    END;
  
    BEGIN
      SELECT pl.id
        INTO v_accident_pl_id
        FROM t_product         p
            ,t_product_line    pl
            ,t_product_ver_lob vl
            ,t_product_version v
       WHERE p.brief = v_product_brief
         AND pl.brief = 'ACCIDENT'
         AND p.product_id = v.product_id
         AND vl.t_product_ver_lob_id = pl.product_ver_lob_id
         AND vl.product_version_id = v.t_product_version_id;
    EXCEPTION
      WHEN no_data_found THEN
        NULL;
    END;
  
    BEGIN
      SELECT pl.id
        INTO v_accident_death_pl_id
        FROM t_product         p
            ,t_product_line    pl
            ,t_product_ver_lob vl
            ,t_product_version v
       WHERE p.brief = v_product_brief
         AND pl.brief = 'ACCIDENT_DEATH'
         AND p.product_id = v.product_id
         AND vl.t_product_ver_lob_id = pl.product_ver_lob_id
         AND vl.product_version_id = v.t_product_version_id;
    EXCEPTION
      WHEN no_data_found THEN
        NULL;
    END;
  
    BEGIN
      SELECT pl.id
        INTO v_accident_disability_pl_id
        FROM t_product         p
            ,t_product_line    pl
            ,t_product_ver_lob vl
            ,t_product_version v
       WHERE p.brief = v_product_brief
         AND pl.brief = 'ACCIDENT_DISABILITY'
         AND p.product_id = v.product_id
         AND vl.t_product_ver_lob_id = pl.product_ver_lob_id
         AND vl.product_version_id = v.t_product_version_id;
    EXCEPTION
      WHEN no_data_found THEN
        NULL;
    END;
  
    BEGIN
      SELECT pl.id
        INTO v_acc_hospitalization_pl_id
        FROM t_product         p
            ,t_product_line    pl
            ,t_product_ver_lob vl
            ,t_product_version v
       WHERE p.brief = v_product_brief
         AND pl.brief = 'ACCIDENT_HOSPITALIZATION'
         AND p.product_id = v.product_id
         AND vl.t_product_ver_lob_id = pl.product_ver_lob_id
         AND vl.product_version_id = v.t_product_version_id;
    EXCEPTION
      WHEN no_data_found THEN
        NULL;
    END;
  
    BEGIN
      SELECT pl.id
        INTO v_acc_temp_disablement_pl_id
        FROM t_product         p
            ,t_product_line    pl
            ,t_product_ver_lob vl
            ,t_product_version v
       WHERE p.brief = v_product_brief
         AND pl.brief = 'ACCIDENT_TEMPORARY_DISABLEMENT'
         AND p.product_id = v.product_id
         AND vl.t_product_ver_lob_id = pl.product_ver_lob_id
         AND vl.product_version_id = v.t_product_version_id;
    EXCEPTION
      WHEN no_data_found THEN
        NULL;
    END;
  
    BEGIN
      SELECT pl.id
        INTO v_accident_trauma_pl_id
        FROM t_product         p
            ,t_product_line    pl
            ,t_product_ver_lob vl
            ,t_product_version v
       WHERE p.brief = v_product_brief
         AND pl.brief = 'ACCIDENT_TRAUMA'
         AND p.product_id = v.product_id
         AND vl.t_product_ver_lob_id = pl.product_ver_lob_id
         AND vl.product_version_id = v.t_product_version_id;
    EXCEPTION
      WHEN no_data_found THEN
        NULL;
    END;
  
    FOR assets IN (SELECT *
                     FROM as_assured_load_tmp_old
                   --where as_assured_load_tmp_id = 1570) loop
                    WHERE session_id = p_session_id
                      AND nvl(is_loaded, 0) = 0)
    LOOP
      BEGIN
        SAVEPOINT sp_load_ass;
        v_as_assured_id := NULL;
      
        IF nvl(assets.action, '!') NOT IN ('A', 'R', 'C')
        THEN
          raise_app_error(assets
                         ,'Неверное значение флага операции (A- добавление,C-изменение,R-удаление)');
        ELSIF assets.first_name IS NULL
        THEN
          raise_app_error(assets, 'Не заполнено ИМЯ');
        ELSIF assets.last_name IS NULL
        THEN
          raise_app_error(assets, 'Не заполнена ФАМИЛИЯ');
        ELSIF assets.birth_date IS NULL
        THEN
          raise_app_error(assets, 'Не заполнена ДАТА РОДЖЕНИЯ');
        ELSIF assets.gender IS NULL
        THEN
          raise_app_error(assets, 'Не заполнен ПОЛ');
        ELSIF assets.proff_class IS NULL
        THEN
          raise_app_error(assets, 'Не заполнена ГРУППА РИСКА');
        ELSIF assets.total_prem IS NULL
        THEN
          raise_app_error(assets, 'Не заполнена ПРЕМИЯ ИТОГО');
        ELSIF assets.cover_start_date IS NULL
        THEN
          raise_app_error(assets, 'Не заполнена ДАТА НАЧ ДЕЙСТВИЯ');
        ELSIF assets.cover_end_date IS NULL
        THEN
          raise_app_error(assets, 'Не заполнена ДАТА ОКОНЧ ДЕЙСТВИЯ');
        ELSIF assets.group_name IS NULL
        THEN
          raise_app_error(assets, 'Не заполнен ГРУППА ЗАСТРАХОВАННЫХ');
        END IF;
      
        BEGIN
        
          IF assets.user_person_id IS NOT NULL
          THEN
            v_contact_id := assets.user_person_id;
          
          ELSE
          
            v_contact_id := pkg_contact.create_person_contact(p_first_name      => assets.first_name
                                                             ,p_middle_name     => assets.middle_name
                                                             ,p_last_name       => assets.last_name
                                                             ,p_birth_date      => assets.birth_date
                                                             ,p_gender          => assets.gender
                                                             ,p_pass_ser        => assets.passport_ser
                                                             ,p_pass_num        => assets.passport_num
                                                             ,p_pass_issue_date => assets.issue_date
                                                             ,p_pass_issued_by  => assets.issued_by);
          END IF;
        EXCEPTION
          WHEN OTHERS THEN
            BEGIN
              IF SQLCODE = pkg_contact.errc_plural_contacts
              THEN
                ROLLBACK TO SAVEPOINT sp_load_ass;
                p_out_number := assets.as_assured_load_tmp_old_id;
                RETURN '@SELECT_PERSON';
              ELSE
                RAISE;
              END IF;
            END;
        END;
      
        IF assets.action IN ('A')
        THEN
          BEGIN
            SELECT a.as_assured_id
                  ,a.status_hist_id
              INTO v_as_assured_id
                  ,v_as_status_hist
              FROM ven_as_assured a
             WHERE a.p_policy_id = p_pol_id
               AND a.assured_contact_id = v_contact_id;
          
            IF p_check_present = 0
            THEN
              raise_app_error(assets
                             ,'Попытка добавить существующего застрахованного');
            ELSE
              GOTO next_asset;
            END IF;
          
          EXCEPTION
            WHEN no_data_found THEN
              NULL;
            WHEN too_many_rows THEN
            
              raise_app_error(assets
                             ,'Контакту соответствуют несколько застрахованных');
            
          END;
        END IF;
      
        IF assets.action IN ('R', 'C')
        THEN
          BEGIN
            SELECT a.as_assured_id
                  ,a.status_hist_id
              INTO v_as_assured_id
                  ,v_as_status_hist
              FROM ven_as_assured a
             WHERE a.p_policy_id = p_pol_id
               AND a.assured_contact_id = v_contact_id;
          EXCEPTION
            WHEN no_data_found THEN
              raise_app_error(assets, 'Не найден застрахованный');
            WHEN too_many_rows THEN
              raise_app_error(assets
                             ,'Контакту соответствуют несколько застрахованных');
          END;
        
          IF assets.action = 'R'
          THEN
          
            IF v_as_status_hist = status_hist_id_del
            THEN
              raise_app_error(assets, 'Застрахованный удален');
            END IF;
          
            IF v_as_status_hist = status_hist_id_curr
            THEN
              pkg_decline2.decline_asset_covers(v_as_assured_id
                                               ,v_decline_date
                                               ,v_def_decline_reason_id
                                               ,v_def_decline_party_id);
            END IF;
            pkg_asset.exclude_as_asset(p_pol_id, v_as_assured_id);
            GOTO next_asset;
          END IF;
        
        END IF;
      
        v_asset_sum  := 0;
        v_asset_prem := 0;
      
        BEGIN
          SELECT t_work_group_id
            INTO v_work_group_id
            FROM t_work_group
           WHERE description LIKE assets.proff_class || '%';
        EXCEPTION
          WHEN no_data_found THEN
            v_work_group_id := 1;
        END;
      
        IF v_as_assured_id IS NULL
        THEN
          v_as_assured_id := create_as_assured(p_pol_id, v_contact_id, v_work_group_id);
        END IF;
      
        v_group_id := get_assured_group(assets.group_name, p_pol_id);
      
        UPDATE as_assured SET pol_assured_group_id = v_group_id WHERE as_assured_id = v_as_assured_id;
      
        BEGIN
          SELECT pc.p_cover_id
                ,pc.premium
                ,pc.ins_amount
            INTO v_cover_id
                ,v_prem
                ,v_sum
            FROM p_cover            pc
                ,t_prod_line_option plo
           WHERE plo.product_line_id = v_death_pl_id
             AND pc.t_prod_line_option_id = plo.id
             AND pc.as_asset_id = v_as_assured_id;
        EXCEPTION
          WHEN no_data_found THEN
            v_cover_id := NULL;
        END;
      
        IF v_death_pl_id IS NOT NULL
        THEN
          IF assets.death_sum IS NOT NULL
          THEN
            IF (assets.action = 'A')
               OR (v_cover_id IS NULL)
            THEN
              -- Добавляем покрытие к объекту(если объект добавили или покрытия нет)
              v_cover_id := pkg_cover.include_cover(v_as_assured_id, v_death_pl_id);
            END IF;
          
            SELECT pt.number_of_payments
              INTO v_pay_term
              FROM ven_p_policy        pol
                  ,ven_t_payment_terms pt
                  ,ven_as_asset        ass
                  ,ven_p_cover         pc
             WHERE pol.payment_term_id = pt.id
               AND pol.policy_id = ass.p_policy_id
               AND ass.as_asset_id = pc.as_asset_id
               AND pc.p_cover_id = v_cover_id;
          
            FOR rec_pol IN (SELECT p.version_num version_num
                                  ,p.start_date pol_start_date
                                  ,p.end_date pol_end_date
                                  ,ph.start_date ph_start_date
                                  ,MIN(p.version_num) over(PARTITION BY p.pol_header_id) first_version
                              FROM p_policy     p
                                  ,p_pol_header ph
                             WHERE p.policy_id = p_pol_id
                               AND p.pol_header_id = ph.policy_header_id)
            LOOP
            
              IF rec_pol.version_num = rec_pol.first_version --первая версия
              THEN
                UPDATE p_cover
                   SET is_handchange_amount  = 1
                      ,is_handchange_premium = 1
                      ,is_handchange_fee     = 1
                      ,is_handchange_tariff  = 1
                      ,ins_amount            = assets.death_sum
                      ,fee                   = assets.death_prem
                      ,premium               = assets.death_prem * v_pay_term
                 WHERE p_cover_id = v_cover_id;
              
                v_asset_prem := v_asset_prem + assets.death_prem * v_pay_term;
              
              ELSE
              
                -- Ф.Ганичев. Если по покрытию изменен взнос, то пересчитывается премия
                SELECT pc.fee
                      ,pc.premium
                  INTO v_fee
                      ,v_new_prem
                  FROM p_cover pc
                 WHERE pc.p_cover_id = v_cover_id;
              
                UPDATE p_cover
                   SET is_handchange_amount  = 1
                      ,is_handchange_premium = 1
                      ,is_handchange_fee     = 1
                      ,is_handchange_tariff  = 1
                      ,ins_amount            = assets.death_sum
                      ,fee                   = assets.death_prem
                 WHERE p_cover_id = v_cover_id;
              
                IF nvl(v_fee, 0) != nvl(assets.death_prem, 0)
                THEN
                  v_new_prem := pkg_cover.calc_new_cover_premium(v_cover_id);
                  UPDATE p_cover SET premium = v_new_prem WHERE p_cover_id = v_cover_id;
                END IF;
              
                v_asset_prem := v_asset_prem + v_new_prem;
              END IF;
            
              EXIT;
            
            END LOOP;
          
            v_asset_sum := v_asset_sum + assets.death_sum;
          
          ELSIF (assets.action = 'C')
                AND (v_cover_id IS NOT NULL)
                AND (v_as_status_hist != status_hist_id_del)
          THEN
            -- Покрытие удалить
            IF v_as_status_hist = status_hist_id_curr
            THEN
              UPDATE p_cover
                 SET decline_date      = v_decline_date
                    ,decline_reason_id = v_def_decline_reason_id
                    ,decline_party_id  = v_def_decline_party_id
               WHERE p_cover_id = v_cover_id;
              pkg_decline2.calc_decline_cover(v_cover_id);
            END IF;
            pkg_cover.exclude_cover(v_cover_id);
          END IF;
        END IF;
      
        BEGIN
          SELECT pc.p_cover_id
                ,pc.premium
                ,pc.ins_amount
            INTO v_cover_id
                ,v_prem
                ,v_sum
            FROM p_cover            pc
                ,t_prod_line_option plo
           WHERE plo.product_line_id = v_hospitalization_pl_id
             AND pc.t_prod_line_option_id = plo.id
             AND pc.as_asset_id = v_as_assured_id;
        EXCEPTION
          WHEN no_data_found THEN
            v_cover_id := NULL;
        END;
      
        IF v_hospitalization_pl_id IS NOT NULL
        THEN
          IF assets.hospitalization_sum IS NOT NULL
          THEN
            IF (assets.action = 'A')
               OR (v_cover_id IS NULL)
            THEN
              -- Добавляем покрытие к объекту(если объект добавили или покрытия нет)
              v_cover_id := pkg_cover.include_cover(v_as_assured_id, v_hospitalization_pl_id);
            END IF;
          
            SELECT pt.number_of_payments
              INTO v_pay_term
              FROM ven_p_policy        pol
                  ,ven_t_payment_terms pt
                  ,ven_as_asset        ass
                  ,ven_p_cover         pc
             WHERE pol.payment_term_id = pt.id
               AND pol.policy_id = ass.p_policy_id
               AND ass.as_asset_id = pc.as_asset_id
               AND pc.p_cover_id = v_cover_id;
          
            FOR rec_pol IN (SELECT p.version_num version_num
                                  ,p.start_date pol_start_date
                                  ,p.end_date pol_end_date
                                  ,ph.start_date ph_start_date
                                  ,MIN(p.version_num) over(PARTITION BY p.pol_header_id) first_version
                              FROM p_policy     p
                                  ,p_pol_header ph
                             WHERE p.policy_id = p_pol_id
                               AND p.pol_header_id = ph.policy_header_id)
            LOOP
            
              IF rec_pol.version_num = rec_pol.first_version --первая версия
              THEN
                UPDATE p_cover
                   SET is_handchange_amount  = 1
                      ,is_handchange_premium = 1
                      ,is_handchange_fee     = 1
                      ,is_handchange_tariff  = 1
                      ,ins_amount            = assets.hospitalization_sum
                      ,fee                   = assets.hospitalization_prem
                      ,premium               = assets.hospitalization_prem * v_pay_term
                 WHERE p_cover_id = v_cover_id;
              
                v_asset_prem := v_asset_prem + assets.hospitalization_prem * v_pay_term;
              
              ELSE
              
                -- Ф.Ганичев. Если по покрытию изменен взнос, то пересчитывается премия
                SELECT pc.fee
                      ,pc.premium
                  INTO v_fee
                      ,v_new_prem
                  FROM p_cover pc
                 WHERE pc.p_cover_id = v_cover_id;
              
                UPDATE p_cover
                   SET is_handchange_amount  = 1
                      ,is_handchange_premium = 1
                      ,is_handchange_fee     = 1
                      ,is_handchange_tariff  = 1
                      ,ins_amount            = assets.hospitalization_sum
                      ,fee                   = assets.hospitalization_prem
                 WHERE p_cover_id = v_cover_id;
              
                IF nvl(v_fee, 0) != nvl(assets.hospitalization_prem, 0)
                THEN
                  v_new_prem := pkg_cover.calc_new_cover_premium(v_cover_id);
                  UPDATE p_cover SET premium = v_new_prem WHERE p_cover_id = v_cover_id;
                END IF;
              
                v_asset_prem := v_asset_prem + v_new_prem;
              END IF;
            
              EXIT;
            
            END LOOP;
          
            v_asset_sum := v_asset_sum + assets.hospitalization_sum;
          
          ELSIF (assets.action = 'C')
                AND (v_cover_id IS NOT NULL)
                AND (v_as_status_hist != status_hist_id_del)
          THEN
            -- Покрытие удалить
            IF v_as_status_hist = status_hist_id_curr
            THEN
              UPDATE p_cover
                 SET decline_date      = v_decline_date
                    ,decline_reason_id = v_def_decline_reason_id
                    ,decline_party_id  = v_def_decline_party_id
               WHERE p_cover_id = v_cover_id;
              pkg_decline2.calc_decline_cover(v_cover_id);
            END IF;
            pkg_cover.exclude_cover(v_cover_id);
          END IF;
        END IF;
      
        BEGIN
          SELECT pc.p_cover_id
                ,pc.premium
                ,pc.ins_amount
            INTO v_cover_id
                ,v_prem
                ,v_sum
            FROM p_cover            pc
                ,t_prod_line_option plo
           WHERE plo.product_line_id = v_failing_mortally_ill_pl_id
             AND pc.t_prod_line_option_id = plo.id
             AND pc.as_asset_id = v_as_assured_id;
        EXCEPTION
          WHEN no_data_found THEN
            v_cover_id := NULL;
        END;
      
        IF v_failing_mortally_ill_pl_id IS NOT NULL
        THEN
          IF assets.failing_mortally_ill_sum IS NOT NULL
          THEN
            IF (assets.action = 'A')
               OR (v_cover_id IS NULL)
            THEN
              v_cover_id := pkg_cover.include_cover(v_as_assured_id, v_failing_mortally_ill_pl_id);
            END IF;
          
            SELECT pt.number_of_payments
              INTO v_pay_term
              FROM ven_p_policy        pol
                  ,ven_t_payment_terms pt
                  ,ven_as_asset        ass
                  ,ven_p_cover         pc
             WHERE pol.payment_term_id = pt.id
               AND pol.policy_id = ass.p_policy_id
               AND ass.as_asset_id = pc.as_asset_id
               AND pc.p_cover_id = v_cover_id;
          
            FOR rec_pol IN (SELECT p.version_num version_num
                                  ,p.start_date pol_start_date
                                  ,p.end_date pol_end_date
                                  ,ph.start_date ph_start_date
                                  ,MIN(p.version_num) over(PARTITION BY p.pol_header_id) first_version
                              FROM p_policy     p
                                  ,p_pol_header ph
                             WHERE p.policy_id = p_pol_id
                               AND p.pol_header_id = ph.policy_header_id)
            LOOP
            
              IF rec_pol.version_num = rec_pol.first_version --первая версия
              THEN
                UPDATE p_cover
                   SET is_handchange_amount  = 1
                      ,is_handchange_premium = 1
                      ,is_handchange_fee     = 1
                      ,is_handchange_tariff  = 1
                      ,ins_amount            = assets.failing_mortally_ill_sum
                      ,fee                   = assets.failing_mortally_ill_prem
                      ,premium               = assets.failing_mortally_ill_prem * v_pay_term
                 WHERE p_cover_id = v_cover_id;
              
                v_asset_prem := v_asset_prem + assets.failing_mortally_ill_prem * v_pay_term;
              
              ELSE
                -- Ф.Ганичев. Если по покрытию изменен взнос, то пересчитывается премия
                SELECT pc.fee
                      ,pc.premium
                  INTO v_fee
                      ,v_new_prem
                  FROM p_cover pc
                 WHERE pc.p_cover_id = v_cover_id;
              
                UPDATE p_cover
                   SET is_handchange_amount  = 1
                      ,is_handchange_premium = 1
                      ,is_handchange_fee     = 1
                      ,is_handchange_tariff  = 1
                      ,ins_amount            = assets.failing_mortally_ill_sum
                      ,fee                   = assets.failing_mortally_ill_prem
                 WHERE p_cover_id = v_cover_id;
              
                IF nvl(v_fee, 0) != nvl(assets.failing_mortally_ill_prem, 0)
                THEN
                  v_new_prem := pkg_cover.calc_new_cover_premium(v_cover_id);
                  UPDATE p_cover SET premium = v_new_prem WHERE p_cover_id = v_cover_id;
                END IF;
              
                v_asset_prem := v_asset_prem + v_new_prem;
              
              END IF;
            
              EXIT;
            
            END LOOP;
          
            v_asset_sum := v_asset_sum + assets.failing_mortally_ill_sum;
          
          END IF;
        END IF;
      
        BEGIN
          SELECT pc.p_cover_id
                ,pc.premium
                ,pc.ins_amount
            INTO v_cover_id
                ,v_prem
                ,v_sum
            FROM p_cover            pc
                ,t_prod_line_option plo
           WHERE plo.product_line_id = v_accident_pl_id
             AND pc.t_prod_line_option_id = plo.id
             AND pc.as_asset_id = v_as_assured_id;
        EXCEPTION
          WHEN no_data_found THEN
            v_cover_id := NULL;
        END;
      
        IF v_accident_pl_id IS NOT NULL
        THEN
          IF assets.accident_sum IS NOT NULL
          THEN
            IF (assets.action = 'A')
               OR (v_cover_id IS NULL)
            THEN
              v_cover_id := pkg_cover.include_cover(v_as_assured_id, v_accident_pl_id);
            END IF;
          
            SELECT pt.number_of_payments
              INTO v_pay_term
              FROM ven_p_policy        pol
                  ,ven_t_payment_terms pt
                  ,ven_as_asset        ass
                  ,ven_p_cover         pc
             WHERE pol.payment_term_id = pt.id
               AND pol.policy_id = ass.p_policy_id
               AND ass.as_asset_id = pc.as_asset_id
               AND pc.p_cover_id = v_cover_id;
          
            FOR rec_pol IN (SELECT p.version_num version_num
                                  ,p.start_date pol_start_date
                                  ,p.end_date pol_end_date
                                  ,ph.start_date ph_start_date
                                  ,MIN(p.version_num) over(PARTITION BY p.pol_header_id) first_version
                              FROM p_policy     p
                                  ,p_pol_header ph
                             WHERE p.policy_id = p_pol_id
                               AND p.pol_header_id = ph.policy_header_id)
            LOOP
            
              IF rec_pol.version_num = rec_pol.first_version --первая версия
              THEN
                UPDATE p_cover
                   SET is_handchange_amount  = 1
                      ,is_handchange_premium = 1
                      ,is_handchange_fee     = 1
                      ,is_handchange_tariff  = 1
                      ,ins_amount            = assets.accident_sum
                      ,fee                   = assets.accident_prem
                      ,premium               = assets.accident_prem * v_pay_term
                 WHERE p_cover_id = v_cover_id;
              
                v_asset_prem := v_asset_prem + assets.accident_prem * v_pay_term;
              
              ELSE
              
                SELECT pc.fee
                      ,pc.premium
                  INTO v_fee
                      ,v_new_prem
                  FROM p_cover pc
                 WHERE pc.p_cover_id = v_cover_id;
              
                UPDATE p_cover
                   SET is_handchange_amount  = 1
                      ,is_handchange_premium = 1
                      ,is_handchange_fee     = 1
                      ,is_handchange_tariff  = 1
                      ,ins_amount            = assets.accident_sum
                      ,fee                   = assets.accident_prem
                 WHERE p_cover_id = v_cover_id;
              
                IF nvl(v_fee, 0) != nvl(assets.accident_prem, 0)
                THEN
                  v_new_prem := pkg_cover.calc_new_cover_premium(v_cover_id);
                  UPDATE p_cover SET premium = v_new_prem WHERE p_cover_id = v_cover_id;
                END IF;
              
                v_asset_prem := v_asset_prem + v_new_prem;
              END IF;
            
              EXIT;
            
            END LOOP;
          
            v_asset_sum := v_asset_sum + assets.accident_sum;
          
          ELSIF (assets.action = 'C')
                AND (v_cover_id IS NOT NULL)
                AND (v_as_status_hist != status_hist_id_del)
          THEN
            -- Покрытие удалить
            IF v_as_status_hist = status_hist_id_curr
            THEN
              UPDATE p_cover
                 SET decline_date      = v_decline_date
                    ,decline_reason_id = v_def_decline_reason_id
                    ,decline_party_id  = v_def_decline_party_id
               WHERE p_cover_id = v_cover_id;
              pkg_decline2.calc_decline_cover(v_cover_id);
            END IF;
            pkg_cover.exclude_cover(v_cover_id);
          END IF;
        END IF;
      
        BEGIN
          SELECT pc.p_cover_id
                ,pc.premium
                ,pc.ins_amount
            INTO v_cover_id
                ,v_prem
                ,v_sum
            FROM p_cover            pc
                ,t_prod_line_option plo
           WHERE plo.product_line_id = v_disability_pl_id
             AND pc.t_prod_line_option_id = plo.id
             AND pc.as_asset_id = v_as_assured_id;
        EXCEPTION
          WHEN no_data_found THEN
            v_cover_id := NULL;
        END;
      
        IF v_disability_pl_id IS NOT NULL
        THEN
          IF assets.disability_sum IS NOT NULL
          THEN
            IF (assets.action = 'A')
               OR (v_cover_id IS NULL)
            THEN
              v_cover_id := pkg_cover.include_cover(v_as_assured_id, v_disability_pl_id);
            END IF;
          
            SELECT pt.number_of_payments
              INTO v_pay_term
              FROM ven_p_policy        pol
                  ,ven_t_payment_terms pt
                  ,ven_as_asset        ass
                  ,ven_p_cover         pc
             WHERE pol.payment_term_id = pt.id
               AND pol.policy_id = ass.p_policy_id
               AND ass.as_asset_id = pc.as_asset_id
               AND pc.p_cover_id = v_cover_id;
          
            FOR rec_pol IN (SELECT p.version_num version_num
                                  ,p.start_date pol_start_date
                                  ,p.end_date pol_end_date
                                  ,ph.start_date ph_start_date
                                  ,MIN(p.version_num) over(PARTITION BY p.pol_header_id) first_version
                              FROM p_policy     p
                                  ,p_pol_header ph
                             WHERE p.policy_id = p_pol_id
                               AND p.pol_header_id = ph.policy_header_id)
            LOOP
            
              IF rec_pol.version_num = rec_pol.first_version --первая версия
              THEN
                UPDATE p_cover
                   SET is_handchange_amount  = 1
                      ,is_handchange_premium = 1
                      ,is_handchange_fee     = 1
                      ,is_handchange_tariff  = 1
                      ,ins_amount            = assets.disability_sum
                      ,fee                   = assets.disability_prem
                      ,premium               = assets.disability_prem * v_pay_term
                 WHERE p_cover_id = v_cover_id;
              
                v_asset_prem := v_asset_prem + assets.disability_prem * v_pay_term;
              
              ELSE
              
                SELECT pc.fee
                      ,pc.premium
                  INTO v_fee
                      ,v_new_prem
                  FROM p_cover pc
                 WHERE pc.p_cover_id = v_cover_id;
              
                UPDATE p_cover
                   SET is_handchange_amount  = 1
                      ,is_handchange_premium = 1
                      ,is_handchange_fee     = 1
                      ,is_handchange_tariff  = 1
                      ,ins_amount            = assets.disability_sum
                      ,fee                   = assets.disability_prem
                 WHERE p_cover_id = v_cover_id;
              
                IF nvl(v_fee, 0) != nvl(assets.disability_prem, 0)
                THEN
                  v_new_prem := pkg_cover.calc_new_cover_premium(v_cover_id);
                  UPDATE p_cover SET premium = v_new_prem WHERE p_cover_id = v_cover_id;
                END IF;
              
                v_asset_prem := v_asset_prem + v_new_prem;
              
              END IF;
            
              EXIT;
            
            END LOOP;
          
            v_asset_sum := v_asset_sum + assets.disability_sum;
          
          ELSIF (assets.action = 'C')
                AND (v_cover_id IS NOT NULL)
                AND (v_as_status_hist != status_hist_id_del)
          THEN
            -- Покрытие удалить
            IF v_as_status_hist = status_hist_id_curr
            THEN
              UPDATE p_cover
                 SET decline_date      = v_decline_date
                    ,decline_reason_id = v_def_decline_reason_id
                    ,decline_party_id  = v_def_decline_party_id
               WHERE p_cover_id = v_cover_id;
              pkg_decline2.calc_decline_cover(v_cover_id);
            END IF;
            pkg_cover.exclude_cover(v_cover_id);
          
          END IF;
        END IF;
      
        BEGIN
          SELECT pc.p_cover_id
                ,pc.premium
                ,pc.ins_amount
            INTO v_cover_id
                ,v_prem
                ,v_sum
            FROM p_cover            pc
                ,t_prod_line_option plo
           WHERE plo.product_line_id = v_accident_death_pl_id
             AND pc.t_prod_line_option_id = plo.id
             AND pc.as_asset_id = v_as_assured_id;
        EXCEPTION
          WHEN no_data_found THEN
            v_cover_id := NULL;
        END;
      
        IF v_accident_death_pl_id IS NOT NULL
        THEN
          IF assets.accident_death_sum IS NOT NULL
          THEN
            IF (assets.action = 'A')
               OR (v_cover_id IS NULL)
            THEN
              -- Добавляем покрытие к объекту(если объект добавили или покрытия нет)
              v_cover_id := pkg_cover.include_cover(v_as_assured_id, v_accident_death_pl_id);
            END IF;
          
            SELECT pt.number_of_payments
              INTO v_pay_term
              FROM ven_p_policy        pol
                  ,ven_t_payment_terms pt
                  ,ven_as_asset        ass
                  ,ven_p_cover         pc
             WHERE pol.payment_term_id = pt.id
               AND pol.policy_id = ass.p_policy_id
               AND ass.as_asset_id = pc.as_asset_id
               AND pc.p_cover_id = v_cover_id;
          
            FOR rec_pol IN (SELECT p.version_num version_num
                                  ,p.start_date pol_start_date
                                  ,p.end_date pol_end_date
                                  ,ph.start_date ph_start_date
                                  ,MIN(p.version_num) over(PARTITION BY p.pol_header_id) first_version
                              FROM p_policy     p
                                  ,p_pol_header ph
                             WHERE p.policy_id = p_pol_id
                               AND p.pol_header_id = ph.policy_header_id)
            LOOP
            
              IF rec_pol.version_num = rec_pol.first_version --первая версия
              THEN
                UPDATE p_cover
                   SET is_handchange_amount  = 1
                      ,is_handchange_premium = 1
                      ,is_handchange_fee     = 1
                      ,is_handchange_tariff  = 1
                      ,ins_amount            = assets.accident_death_sum
                      ,fee                   = assets.accident_death_prem
                      ,premium               = assets.accident_death_prem * v_pay_term
                 WHERE p_cover_id = v_cover_id;
              
                v_asset_prem := v_asset_prem + assets.accident_death_prem * v_pay_term;
              
              ELSE
              
                SELECT pc.fee
                      ,pc.premium
                  INTO v_fee
                      ,v_new_prem
                  FROM p_cover pc
                 WHERE pc.p_cover_id = v_cover_id;
              
                UPDATE p_cover
                   SET is_handchange_amount  = 1
                      ,is_handchange_premium = 1
                      ,is_handchange_fee     = 1
                      ,is_handchange_tariff  = 1
                      ,ins_amount            = assets.accident_death_sum
                      ,fee                   = assets.accident_death_prem
                 WHERE p_cover_id = v_cover_id;
              
                IF nvl(v_fee, 0) != nvl(assets.accident_death_prem, 0)
                THEN
                  v_new_prem := pkg_cover.calc_new_cover_premium(v_cover_id);
                  UPDATE p_cover SET premium = v_new_prem WHERE p_cover_id = v_cover_id;
                END IF;
              
                v_asset_prem := v_asset_prem + v_new_prem;
              END IF;
            
              EXIT;
            
            END LOOP;
          
            v_asset_sum := v_asset_sum + assets.accident_death_sum;
          
          ELSIF (assets.action = 'C')
                AND (v_cover_id IS NOT NULL)
                AND (v_as_status_hist != status_hist_id_del)
          THEN
            -- Покрытие удалить
            IF v_as_status_hist = status_hist_id_curr
            THEN
              UPDATE p_cover
                 SET decline_date      = v_decline_date
                    ,decline_reason_id = v_def_decline_reason_id
                    ,decline_party_id  = v_def_decline_party_id
               WHERE p_cover_id = v_cover_id;
              pkg_decline2.calc_decline_cover(v_cover_id);
            END IF;
          
            pkg_cover.exclude_cover(v_cover_id);
          
          END IF;
        END IF;
      
        BEGIN
          SELECT pc.p_cover_id
                ,pc.premium
                ,pc.ins_amount
            INTO v_cover_id
                ,v_prem
                ,v_sum
            FROM p_cover            pc
                ,t_prod_line_option plo
           WHERE plo.product_line_id = v_acc_hospitalization_pl_id
             AND pc.t_prod_line_option_id = plo.id
             AND pc.as_asset_id = v_as_assured_id;
        EXCEPTION
          WHEN no_data_found THEN
            v_cover_id := NULL;
        END;
      
        IF v_acc_hospitalization_pl_id IS NOT NULL
        THEN
          IF assets.accident_hospitalization_sum IS NOT NULL
          THEN
            IF (assets.action = 'A')
               OR (v_cover_id IS NULL)
            THEN
              v_cover_id := pkg_cover.include_cover(v_as_assured_id, v_acc_hospitalization_pl_id);
            END IF;
          
            SELECT pt.number_of_payments
              INTO v_pay_term
              FROM ven_p_policy        pol
                  ,ven_t_payment_terms pt
                  ,ven_as_asset        ass
                  ,ven_p_cover         pc
             WHERE pol.payment_term_id = pt.id
               AND pol.policy_id = ass.p_policy_id
               AND ass.as_asset_id = pc.as_asset_id
               AND pc.p_cover_id = v_cover_id;
          
            FOR rec_pol IN (SELECT p.version_num version_num
                                  ,p.start_date pol_start_date
                                  ,p.end_date pol_end_date
                                  ,ph.start_date ph_start_date
                                  ,MIN(p.version_num) over(PARTITION BY p.pol_header_id) first_version
                              FROM p_policy     p
                                  ,p_pol_header ph
                             WHERE p.policy_id = p_pol_id
                               AND p.pol_header_id = ph.policy_header_id)
            LOOP
            
              IF rec_pol.version_num = rec_pol.first_version --первая версия
              THEN
                UPDATE p_cover
                   SET is_handchange_amount  = 1
                      ,is_handchange_premium = 1
                      ,is_handchange_fee     = 1
                      ,is_handchange_tariff  = 1
                      ,ins_amount            = assets.accident_hospitalization_sum
                      ,fee                   = assets.accident_hospitalization_prem
                      ,premium               = assets.accident_hospitalization_prem * v_pay_term
                 WHERE p_cover_id = v_cover_id;
              
                v_asset_prem := v_asset_prem + assets.accident_hospitalization_prem * v_pay_term;
              
              ELSE
              
                SELECT pc.fee
                      ,pc.premium
                  INTO v_fee
                      ,v_new_prem
                  FROM p_cover pc
                 WHERE pc.p_cover_id = v_cover_id;
              
                UPDATE p_cover
                   SET is_handchange_amount  = 1
                      ,is_handchange_premium = 1
                      ,is_handchange_fee     = 1
                      ,is_handchange_tariff  = 1
                      ,ins_amount            = assets.accident_hospitalization_sum
                      ,fee                   = assets.accident_hospitalization_prem
                 WHERE p_cover_id = v_cover_id;
              
                IF nvl(v_fee, 0) != nvl(assets.accident_hospitalization_prem, 0)
                THEN
                  v_new_prem := pkg_cover.calc_new_cover_premium(v_cover_id);
                  UPDATE p_cover SET premium = v_new_prem WHERE p_cover_id = v_cover_id;
                END IF;
              
                v_asset_prem := v_asset_prem + v_new_prem;
              
              END IF;
            
              EXIT;
            
            END LOOP;
          
            v_asset_sum := v_asset_sum + assets.accident_hospitalization_sum;
          
          ELSIF (assets.action = 'C')
                AND (v_cover_id IS NOT NULL)
                AND (v_as_status_hist != status_hist_id_del)
          THEN
            -- Покрытие удалить
            IF v_as_status_hist = status_hist_id_curr
            THEN
              UPDATE p_cover
                 SET decline_date      = v_decline_date
                    ,decline_reason_id = v_def_decline_reason_id
                    ,decline_party_id  = v_def_decline_party_id
               WHERE p_cover_id = v_cover_id;
              pkg_decline2.calc_decline_cover(v_cover_id);
            END IF;
            pkg_cover.exclude_cover(v_cover_id);
          
          END IF;
        END IF;
      
        BEGIN
          SELECT pc.p_cover_id
                ,pc.premium
                ,pc.ins_amount
            INTO v_cover_id
                ,v_prem
                ,v_sum
            FROM p_cover            pc
                ,t_prod_line_option plo
           WHERE plo.product_line_id = v_accident_disability_pl_id
             AND pc.t_prod_line_option_id = plo.id
             AND pc.as_asset_id = v_as_assured_id;
        EXCEPTION
          WHEN no_data_found THEN
            v_cover_id := NULL;
        END;
      
        IF v_accident_disability_pl_id IS NOT NULL
        THEN
          IF assets.accident_disability_sum IS NOT NULL
          THEN
            IF (assets.action = 'A')
               OR (v_cover_id IS NULL)
            THEN
              v_cover_id := pkg_cover.include_cover(v_as_assured_id, v_accident_disability_pl_id);
            END IF;
          
            SELECT pt.number_of_payments
              INTO v_pay_term
              FROM ven_p_policy        pol
                  ,ven_t_payment_terms pt
                  ,ven_as_asset        ass
                  ,ven_p_cover         pc
             WHERE pol.payment_term_id = pt.id
               AND pol.policy_id = ass.p_policy_id
               AND ass.as_asset_id = pc.as_asset_id
               AND pc.p_cover_id = v_cover_id;
          
            FOR rec_pol IN (SELECT p.version_num version_num
                                  ,p.start_date pol_start_date
                                  ,p.end_date pol_end_date
                                  ,ph.start_date ph_start_date
                                  ,MIN(p.version_num) over(PARTITION BY p.pol_header_id) first_version
                              FROM p_policy     p
                                  ,p_pol_header ph
                             WHERE p.policy_id = p_pol_id
                               AND p.pol_header_id = ph.policy_header_id)
            LOOP
            
              IF rec_pol.version_num = rec_pol.first_version --первая версия
              THEN
                UPDATE p_cover
                   SET is_handchange_amount  = 1
                      ,is_handchange_premium = 1
                      ,is_handchange_fee     = 1
                      ,is_handchange_tariff  = 1
                      ,ins_amount            = assets.accident_disability_sum
                      ,fee                   = assets.accident_disability_prem
                      ,premium               = assets.accident_disability_prem * v_pay_term
                 WHERE p_cover_id = v_cover_id;
              
                v_asset_prem := v_asset_prem + assets.accident_disability_prem * v_pay_term;
              
              ELSE
              
                SELECT pc.fee
                      ,pc.premium
                  INTO v_fee
                      ,v_new_prem
                  FROM p_cover pc
                 WHERE pc.p_cover_id = v_cover_id;
              
                UPDATE p_cover
                   SET is_handchange_amount  = 1
                      ,is_handchange_premium = 1
                      ,is_handchange_fee     = 1
                      ,is_handchange_tariff  = 1
                      ,ins_amount            = assets.accident_disability_sum
                      ,fee                   = assets.accident_disability_prem
                 WHERE p_cover_id = v_cover_id;
              
                IF nvl(v_fee, 0) != nvl(assets.accident_disability_prem, 0)
                THEN
                  v_new_prem := pkg_cover.calc_new_cover_premium(v_cover_id);
                  UPDATE p_cover SET premium = v_new_prem WHERE p_cover_id = v_cover_id;
                END IF;
              
                v_asset_prem := v_asset_prem + v_new_prem;
              
              END IF;
            
              EXIT;
            
            END LOOP;
          
            v_asset_sum := v_asset_sum + assets.accident_disability_sum;
          
          ELSIF (assets.action = 'C')
                AND (v_cover_id IS NOT NULL)
                AND (v_as_status_hist != status_hist_id_del)
          THEN
            -- Покрытие удалить
            IF v_as_status_hist = status_hist_id_curr
            THEN
              UPDATE p_cover
                 SET decline_date      = v_decline_date
                    ,decline_reason_id = v_def_decline_reason_id
                    ,decline_party_id  = v_def_decline_party_id
               WHERE p_cover_id = v_cover_id;
              pkg_decline2.calc_decline_cover(v_cover_id);
            END IF;
            pkg_cover.exclude_cover(v_cover_id);
          
          END IF;
        END IF;
      
        BEGIN
          SELECT pc.p_cover_id
                ,pc.premium
                ,pc.ins_amount
            INTO v_cover_id
                ,v_prem
                ,v_sum
            FROM p_cover            pc
                ,t_prod_line_option plo
           WHERE plo.product_line_id = v_accident_trauma_pl_id
             AND pc.t_prod_line_option_id = plo.id
             AND pc.as_asset_id = v_as_assured_id;
        EXCEPTION
          WHEN no_data_found THEN
            v_cover_id := NULL;
        END;
      
        IF v_accident_trauma_pl_id IS NOT NULL
        THEN
          IF assets.accident_trauma_sum IS NOT NULL
          THEN
            IF (assets.action = 'A')
               OR (v_cover_id IS NULL)
            THEN
              v_cover_id := pkg_cover.include_cover(v_as_assured_id, v_accident_trauma_pl_id);
            END IF;
          
            SELECT pt.number_of_payments
              INTO v_pay_term
              FROM ven_p_policy        pol
                  ,ven_t_payment_terms pt
                  ,ven_as_asset        ass
                  ,ven_p_cover         pc
             WHERE pol.payment_term_id = pt.id
               AND pol.policy_id = ass.p_policy_id
               AND ass.as_asset_id = pc.as_asset_id
               AND pc.p_cover_id = v_cover_id;
          
            FOR rec_pol IN (SELECT p.version_num version_num
                                  ,p.start_date pol_start_date
                                  ,p.end_date pol_end_date
                                  ,ph.start_date ph_start_date
                                  ,MIN(p.version_num) over(PARTITION BY p.pol_header_id) first_version
                              FROM p_policy     p
                                  ,p_pol_header ph
                             WHERE p.policy_id = p_pol_id
                               AND p.pol_header_id = ph.policy_header_id)
            LOOP
            
              IF rec_pol.version_num = rec_pol.first_version --первая версия
              THEN
                UPDATE p_cover
                   SET is_handchange_amount  = 1
                      ,is_handchange_premium = 1
                      ,is_handchange_fee     = 1
                      ,is_handchange_tariff  = 1
                      ,ins_amount            = assets.accident_trauma_sum
                      ,fee                   = assets.accident_trauma_prem
                      ,premium               = assets.accident_trauma_prem * v_pay_term
                 WHERE p_cover_id = v_cover_id;
              
                v_asset_prem := v_asset_prem + assets.accident_trauma_prem * v_pay_term;
              
              ELSE
              
                SELECT pc.fee
                      ,pc.premium
                  INTO v_fee
                      ,v_new_prem
                  FROM p_cover pc
                 WHERE pc.p_cover_id = v_cover_id;
              
                UPDATE p_cover
                   SET is_handchange_amount  = 1
                      ,is_handchange_premium = 1
                      ,is_handchange_fee     = 1
                      ,is_handchange_tariff  = 1
                      ,ins_amount            = assets.accident_trauma_sum
                      ,fee                   = assets.accident_trauma_prem
                 WHERE p_cover_id = v_cover_id;
              
                IF nvl(v_fee, 0) != nvl(assets.accident_trauma_prem, 0)
                THEN
                  v_new_prem := pkg_cover.calc_new_cover_premium(v_cover_id);
                  UPDATE p_cover SET premium = v_new_prem WHERE p_cover_id = v_cover_id;
                END IF;
              
                v_asset_prem := v_asset_prem + v_new_prem;
              
              END IF;
            
              EXIT;
            
            END LOOP;
          
            v_asset_sum := v_asset_sum + assets.accident_trauma_sum;
          
          ELSIF (assets.action = 'C')
                AND (v_cover_id IS NOT NULL)
                AND (v_as_status_hist != status_hist_id_del)
          THEN
            -- Покрытие удалить
            IF v_as_status_hist = status_hist_id_curr
            THEN
              UPDATE p_cover
                 SET decline_date      = v_decline_date
                    ,decline_reason_id = v_def_decline_reason_id
                    ,decline_party_id  = v_def_decline_party_id
               WHERE p_cover_id = v_cover_id;
              pkg_decline2.calc_decline_cover(v_cover_id);
            END IF;
            pkg_cover.exclude_cover(v_cover_id);
          
          END IF;
        END IF;
      
        BEGIN
          SELECT pc.p_cover_id
                ,pc.premium
                ,pc.ins_amount
            INTO v_cover_id
                ,v_prem
                ,v_sum
            FROM p_cover            pc
                ,t_prod_line_option plo
           WHERE plo.product_line_id = v_acc_temp_disablement_pl_id
             AND pc.t_prod_line_option_id = plo.id
             AND pc.as_asset_id = v_as_assured_id;
        EXCEPTION
          WHEN no_data_found THEN
            v_cover_id := NULL;
        END;
      
        IF v_acc_temp_disablement_pl_id IS NOT NULL
        THEN
          IF assets.accident_temp_disablement_sum IS NOT NULL
          THEN
            IF (assets.action = 'A')
               OR (v_cover_id IS NULL)
            THEN
              v_cover_id := pkg_cover.include_cover(v_as_assured_id, v_acc_temp_disablement_pl_id);
            END IF;
          
            SELECT pt.number_of_payments
              INTO v_pay_term
              FROM ven_p_policy        pol
                  ,ven_t_payment_terms pt
                  ,ven_as_asset        ass
                  ,ven_p_cover         pc
             WHERE pol.payment_term_id = pt.id
               AND pol.policy_id = ass.p_policy_id
               AND ass.as_asset_id = pc.as_asset_id
               AND pc.p_cover_id = v_cover_id;
          
            FOR rec_pol IN (SELECT p.version_num version_num
                                  ,p.start_date pol_start_date
                                  ,p.end_date pol_end_date
                                  ,ph.start_date ph_start_date
                                  ,MIN(p.version_num) over(PARTITION BY p.pol_header_id) first_version
                              FROM p_policy     p
                                  ,p_pol_header ph
                             WHERE p.policy_id = p_pol_id
                               AND p.pol_header_id = ph.policy_header_id)
            LOOP
            
              IF rec_pol.version_num = rec_pol.first_version --первая версия
              THEN
                UPDATE p_cover
                   SET is_handchange_amount  = 1
                      ,is_handchange_premium = 1
                      ,is_handchange_fee     = 1
                      ,is_handchange_tariff  = 1
                      ,ins_amount            = assets.accident_temp_disablement_sum
                      ,fee                   = assets.accident_temp_disablement_prem
                      ,premium               = assets.accident_temp_disablement_prem * v_pay_term
                 WHERE p_cover_id = v_cover_id;
              
                v_asset_prem := v_asset_prem + assets.accident_temp_disablement_prem * v_pay_term;
              
              ELSE
              
                SELECT pc.fee
                      ,pc.premium
                  INTO v_fee
                      ,v_new_prem
                  FROM p_cover pc
                 WHERE pc.p_cover_id = v_cover_id;
              
                UPDATE p_cover
                   SET is_handchange_amount  = 1
                      ,is_handchange_premium = 1
                      ,is_handchange_fee     = 1
                      ,is_handchange_tariff  = 1
                      ,ins_amount            = assets.accident_temp_disablement_sum
                      ,fee                   = assets.accident_temp_disablement_prem
                 WHERE p_cover_id = v_cover_id;
              
                IF nvl(v_fee, 0) != nvl(assets.accident_temp_disablement_prem, 0)
                THEN
                  v_new_prem := pkg_cover.calc_new_cover_premium(v_cover_id);
                  UPDATE p_cover SET premium = v_new_prem WHERE p_cover_id = v_cover_id;
                END IF;
              
                v_asset_prem := v_asset_prem + v_new_prem;
              
              END IF;
            
              EXIT;
            
            END LOOP;
          
            v_asset_sum := v_asset_sum + assets.accident_temp_disablement_sum;
          
          ELSIF (assets.action = 'C')
                AND (v_cover_id IS NOT NULL)
                AND (v_as_status_hist != status_hist_id_del)
          THEN
            -- Покрытие удалить
            IF v_as_status_hist = status_hist_id_curr
            THEN
              UPDATE p_cover
                 SET decline_date      = v_decline_date
                    ,decline_reason_id = v_def_decline_reason_id
                    ,decline_party_id  = v_def_decline_party_id
               WHERE p_cover_id = v_cover_id;
              pkg_decline2.calc_decline_cover(v_cover_id);
            END IF;
            pkg_cover.exclude_cover(v_cover_id);
          
          END IF;
        END IF;
      
        UPDATE as_asset
           SET ins_amount  = v_asset_sum
              ,ins_premium = v_asset_prem
         WHERE as_asset_id = v_as_assured_id;
      
        <<next_asset>>
      
        set_loaded_flag_old(assets.as_assured_load_tmp_old_id, 1);
      
      EXCEPTION
        WHEN OTHERS THEN
        
          set_loaded_flag_old(assets.as_assured_load_tmp_old_id, 3);
          ROLLBACK TO SAVEPOINT sp_load_ass;
          pkg_cover.cover_property_cache.delete;
          RETURN SQLERRM;
      END;
    
      <<next_asset>>
    
      NULL;
    END LOOP;
    pkg_cover.cover_property_cache.delete;
    RETURN 'Ok';
  END;

  PROCEDURE check_count_cover(par_policy_id NUMBER) IS
    v_prog_num     t_product_version.min_package_number%TYPE;
    v_cover_num    NUMBER := 0;
    v_contact_name contact.obj_name_orig%TYPE;
  BEGIN
    /*
      Байтин А.
      
      В рамках заявки 188491
      Убрал нахождение последней версии продукта (версионность не используется), убрал ven
    */
    SELECT pv.min_package_number
      INTO v_prog_num
      FROM t_product_version pv
          ,p_pol_header      ph
          ,p_policy          p
     WHERE p.policy_id = par_policy_id
       AND ph.policy_header_id = p.pol_header_id
       AND pv.product_id = ph.product_id;
  
    /* Байтин А.
    Оптимизировал для групповых ДС*/
  
    FOR rec IN (SELECT se.as_asset_id
                  FROM as_asset se
                      ,p_cover  pc
                 WHERE se.p_policy_id = par_policy_id
                   AND se.as_asset_id = pc.as_asset_id
                 GROUP BY se.as_asset_id
                HAVING COUNT(*) < v_prog_num)
    LOOP
    
      SELECT co.obj_name_orig
        INTO v_contact_name
        FROM contact    co
            ,as_assured su
       WHERE su.as_assured_id = rec.as_asset_id
         AND su.assured_contact_id = co.contact_id;
    
      raise_application_error(-20000
                             ,'Для застрахованного ' || /*rec.NAME*/
                              v_contact_name || ' не выбрано минимальное количество покрытий');
    END LOOP;
  END check_count_cover;

  /**********************************************************************************************************************/
  FUNCTION load_assured
  (
    p_pol_id     NUMBER
   ,p_session_id NUMBER
   ,p_out_number OUT NUMBER
  ) RETURN VARCHAR2 IS
    skip_exception_num     CONSTANT NUMBER := -20011;
    critical_exception_num CONSTANT NUMBER := -20012;
  
    skip_exception     EXCEPTION;
    critical_exception EXCEPTION;
    PRAGMA EXCEPTION_INIT(skip_exception, -20011);
    PRAGMA EXCEPTION_INIT(critical_exception, -20012);
    v_contact_id PLS_INTEGER;
    --v_as_prev       PLS_INTEGER;
    --v_skip_update   PLS_INTEGER:=0;
    v_as_assured_id PLS_INTEGER;
    v_work_group_id PLS_INTEGER;
  
    /*    v_death_pl_id                PLS_INTEGER; -- Смерть по любой причине
    v_failing_mortally_ill_pl_id PLS_INTEGER; -- ПДСОЗ
    v_hospitalization_pl_id      PLS_INTEGER; -- Госпитализация по любой причине
    v_accident_pl_id             PLS_INTEGER; -- Страхование от несчастных случаев
    v_disability_pl_id           PLS_INTEGER; -- Инвалидность по любой причине
    
    v_accident_death_pl_id       PLS_INTEGER; -- Смерть в результате НС
    v_accident_disability_pl_id  PLS_INTEGER; -- Инвалидность в результате НС
    v_accident_trauma_pl_id      PLS_INTEGER; -- Телесн. повреждения в рез-те НС
    v_acc_hospitalization_pl_id  PLS_INTEGER; -- Госпитализация в рез-те НС
    v_acc_temp_disablement_pl_id PLS_INTEGER; -- Врем. нетрудоспособность в рез-те НС*/
  
    v_cover_id        PLS_INTEGER;
    v_asset_sum       NUMBER := 0;
    v_asset_prem      NUMBER := 0;
    v_asset_fee       NUMBER := 0;
    v_group_id        PLS_INTEGER; -- Группа застрахованных в полисе
    v_asset_header_id PLS_INTEGER;
  
    --v_product_brief VARCHAR2(100);
  
    v_as_status_hist PLS_INTEGER;
    --v_prem           NUMBER;
    --v_sum            NUMBER;
  
    v_def_decline_reason_id PLS_INTEGER;
    v_def_decline_party_id  NUMBER;
    v_decline_date          DATE;
    v_cover_count           PLS_INTEGER;
  
    v_pay_term      PLS_INTEGER; -- периодичность выплат
    v_is_group_flag ins.p_policy.is_group_flag%TYPE;
    --v_new_prem   NUMBER;
    --v_fee    NUMBER;
    --is_dbms PLS_INTEGER := 0;
  
    ------------Новое---------------------
    v_prod_line_option_id  NUMBER;
    v_period_id            NUMBER;
    v_accum_period_end_age NUMBER;
    v_max_cover_end        DATE;
    v_age                  NUMBER;
    v_is_autoprolongation  NUMBER;
    v_pol_header_desc      p_pol_header.description%TYPE;
    v_error_message        VARCHAR2(2000);
    v_cnt                  PLS_INTEGER := 0;
    v_status_hist_id       NUMBER;
    v_n_contacts           NUMBER;
    --------------------------------------
  
    PROCEDURE raise_app_error
    (
      par_last_name     VARCHAR2
     ,par_first_name    VARCHAR2
     ,par_num_field     VARCHAR2
     ,p_msg             VARCHAR2
     ,par_exception_num NUMBER
    ) IS
    BEGIN
      IF par_exception_num = skip_exception_num
      THEN
        raise_application_error(skip_exception_num, p_msg);
      ELSIF par_exception_num = critical_exception_num
      THEN
        raise_application_error(-20100
                               ,p_msg || ' Объект: ' || par_last_name || ' ' || par_first_name ||
                                ' номер строки ' || par_num_field);
      END IF;
    END;
  
    PROCEDURE create_contact
    (
      par_first_name          VARCHAR2
     ,par_middle_name         VARCHAR2
     ,par_last_name           VARCHAR2
     ,par_birth_date          DATE
     ,par_gender              VARCHAR2
     ,par_passport_ser        VARCHAR2
     ,par_passport_num        VARCHAR2
     ,par_passport_issue_date DATE
     ,par_passport_issued_by  VARCHAR2
     ,par_contact_id_out      OUT NUMBER
    ) IS
      v_contact_object pkg_contact_object.t_person_object;
      v_passport       pkg_contact_object.t_contact_id_doc_rec;
    BEGIN
      v_contact_object.first_name    := par_first_name;
      v_contact_object.middle_name   := par_middle_name;
      v_contact_object.name          := par_last_name;
      v_contact_object.date_of_birth := par_birth_date;
      v_contact_object.gender        := par_gender;
    
      IF par_passport_num IS NOT NULL
      THEN
      
        v_passport.id_doc_type_brief := 'PASS_RF';
        v_passport.series_nr         := par_passport_ser;
        v_passport.id_value          := par_passport_num;
        v_passport.issue_date        := par_passport_issue_date;
        v_passport.place_of_issue    := par_passport_issued_by;
      
        pkg_contact_object.add_id_doc_rec_to_object(par_contact_object => v_contact_object
                                                   ,par_id_doc_rec     => v_passport);
      END IF;
    
      pkg_contact_object.process_person_object(par_person_obj => v_contact_object
                                              ,par_contact_id => par_contact_id_out);
    
    END create_contact;
  
  BEGIN
    --Каткевич А.Г. 20/03/2009 - Изрядно переделал всю функцию
    pkg_cover.cover_property_cache.delete;
  
    BEGIN
      SELECT tp.id
            ,tp.period_value_to
        INTO v_period_id
            ,v_accum_period_end_age
        FROM t_period tp
       WHERE tp.description = 'Другой';
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20001
                               ,'Не найден период с названием "Другой"!');
    END;
  
    SELECT pt.number_of_payments
      INTO v_pay_term
      FROM p_policy        pp
          ,t_payment_terms pt
     WHERE pp.policy_id = p_pol_id
       AND pp.payment_term_id = pt.id;
  
    SELECT ph.description INTO v_pol_header_desc FROM p_pol_header ph WHERE ph.last_ver_id = p_pol_id;
  
    BEGIN
      SELECT t_decline_reason_id
        INTO v_def_decline_reason_id
        FROM t_decline_reason
       WHERE brief = 'ЗаявСтрахователя';
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20100
                               ,'Не найдена запись в справочнике: T_DECLINE_REASON (brief=ЗаявСтрахователя)');
    END;
  
    BEGIN
      SELECT t_decline_party_id
        INTO v_def_decline_party_id
        FROM t_decline_party
       WHERE brief = 'Страхователь';
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20100
                               ,'Не найдена запись в справочнике: T_DECLINE_PARTY (brief=Страхователь)');
    END;
  
    FOR assets IN (SELECT a.*
                         ,nvl(lag(0) over(PARTITION BY a.first_name || a.last_name || a.middle_name
                                  ,a.birth_date
                                  ,a.cover_start_date ORDER BY
                                   a.first_name || a.last_name || a.middle_name
                                  ,a.birth_date
                                  ,a.cover_start_date)
                             ,1) AS is_first
                         ,nvl(lead(0) over(PARTITION BY a.first_name || a.last_name || a.middle_name
                                  ,a.birth_date
                                  ,a.cover_start_date ORDER BY
                                   a.first_name || a.last_name || a.middle_name
                                  ,a.birth_date
                                  ,a.cover_start_date)
                             ,1) AS is_last
                     FROM as_assured_load_tmp a
                    WHERE session_id = p_session_id
                         --AND a.as_assured_load_tmp_id = 30212038
                      AND nvl(is_loaded, 0) = 0 /*
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 ORDER BY a.first_name||a.last_name||a.middle_name, a.birth_date, a.cover_start_date*/
                   )
    LOOP
      BEGIN
        SAVEPOINT import_assured;
        --SAVEPOINT sp_load_ass;
        --Проверка правильности формата
        IF nvl(assets.action, '!') NOT IN ('A', 'R', 'C')
        THEN
          raise_app_error(assets.last_name
                         ,assets.first_name
                         ,assets.num_field
                         ,'Неверное значение флага операции (A- добавление,C-изменение,R-удаление)'
                         ,critical_exception_num);
        ELSIF assets.first_name IS NULL
              AND assets.action != 'R'
        THEN
          raise_app_error(assets.last_name
                         ,assets.first_name
                         ,assets.num_field
                         ,'Не заполнено ИМЯ'
                         ,critical_exception_num);
        ELSIF assets.last_name IS NULL
        THEN
          raise_app_error(assets.last_name
                         ,assets.first_name
                         ,assets.num_field
                         ,'Не заполнена ФАМИЛИЯ'
                         ,critical_exception_num);
        ELSIF assets.birth_date IS NULL
        THEN
          raise_app_error(assets.last_name
                         ,assets.first_name
                         ,assets.num_field
                         ,'Не заполнена ДАТА РОДЖЕНИЯ'
                         ,critical_exception_num);
        ELSIF assets.gender IS NULL
        THEN
          raise_app_error(assets.last_name
                         ,assets.first_name
                         ,assets.num_field
                         ,'Не заполнен ПОЛ'
                         ,critical_exception_num);
        ELSIF assets.proff_class IS NULL
        THEN
          raise_app_error(assets.last_name
                         ,assets.first_name
                         ,assets.num_field
                         ,'Не заполнена ГРУППА РИСКА'
                         ,critical_exception_num);
        ELSIF assets.ammount IS NULL
        THEN
          raise_app_error(assets.last_name
                         ,assets.first_name
                         ,assets.num_field
                         ,'Не заполнена СТРАХОВАЯ СУММА'
                         ,critical_exception_num);
        ELSIF assets.premium IS NULL
        THEN
          raise_app_error(assets.last_name
                         ,assets.first_name
                         ,assets.num_field
                         ,'Не заполнена СТРАХОВАЯ ПРЕМИЯ'
                         ,critical_exception_num);
        ELSIF assets.product_line_brief IS NULL
        THEN
          raise_app_error(assets.last_name
                         ,assets.first_name
                         ,assets.num_field
                         ,'Не заполнено СОКРАЩЕНИЕ ПРОДУКТА СТРАХОВАНИЯ'
                         ,critical_exception_num);
        ELSIF assets.cover_start_date IS NULL
        THEN
          raise_app_error(assets.last_name
                         ,assets.first_name
                         ,assets.num_field
                         ,'Не заполнена ДАТА НАЧ ДЕЙСТВИЯ'
                         ,critical_exception_num);
        ELSIF assets.cover_end_date IS NULL
        THEN
          raise_app_error(assets.last_name
                         ,assets.first_name
                         ,assets.num_field
                         ,'Не заполнена ДАТА ОКОНЧ ДЕЙСТВИЯ'
                         ,critical_exception_num);
        ELSIF assets.group_name IS NULL
        THEN
          raise_app_error(assets.last_name
                         ,assets.first_name
                         ,assets.num_field
                         ,'Не заполнен ГРУППА ЗАСТРАХОВАННЫХ'
                         ,critical_exception_num);
        END IF;
      
        v_cover_id := NULL;
      
        CASE
          WHEN assets.action = 'R' THEN
          
            v_decline_date := assets.cover_end_date;
          
            v_as_assured_id := NULL;
            BEGIN
            
              SELECT as_assured_id
                    ,status_hist_id
                    ,p_asset_header_id
                    ,contact_id
                    ,contact_dublicates
                INTO v_as_assured_id
                    ,v_as_status_hist
                    ,v_asset_header_id
                    ,v_contact_id
                    ,v_n_contacts
                FROM (SELECT /* LEADING(a) USE_NL(a se) */
                       a.as_assured_id
                      ,se.status_hist_id
                      ,se.p_asset_header_id
                      ,c.contact_id
                      ,COUNT(DISTINCT c.contact_id) over() contact_dublicates
                        FROM as_assured a
                            ,as_asset   se
                            ,contact    c
                            ,cn_person  cn
                       WHERE se.p_policy_id = p_pol_id
                         AND c.contact_id = cn.contact_id
                         AND a.assured_contact_id = c.contact_id
                         AND se.as_asset_id = a.as_assured_id
                         AND se.start_date = assets.cover_start_date
                         AND TRIM(c.obj_name) =
                             TRIM(upper(assets.last_name ||
                                        decode(assets.first_name, NULL, '', ' ' || assets.first_name) ||
                                        decode(assets.middle_name, NULL, '', ' ' || assets.middle_name)))
                         AND cn.date_of_birth = assets.birth_date
                         AND EXISTS (SELECT NULL
                                FROM p_cover            pc
                                    ,t_prod_line_option plo
                                    ,t_product_line     pl
                               WHERE pc.as_asset_id = se.as_asset_id
                                 AND pc.t_prod_line_option_id = plo.id
                                 AND plo.product_line_id = pl.id
                                 AND pl.brief = assets.product_line_brief)
                       ORDER BY se.as_asset_id DESC)
               WHERE rownum = 1;
            EXCEPTION
              WHEN no_data_found THEN
                raise_app_error(assets.last_name
                               ,assets.first_name
                               ,assets.num_field
                               ,'Не найден застрахованный'
                               ,skip_exception_num);
            END;
            IF v_n_contacts > 1
            THEN
              BEGIN
                SELECT as_assured_id
                      ,status_hist_id
                      ,p_asset_header_id
                      ,contact_id
                      ,contact_dublicates
                  INTO v_as_assured_id
                      ,v_as_status_hist
                      ,v_asset_header_id
                      ,v_contact_id
                      ,v_n_contacts
                  FROM (SELECT /* LEADING(a) USE_NL(a se) */
                         a.as_assured_id
                        ,se.status_hist_id
                        ,se.p_asset_header_id
                        ,c.contact_id
                        ,COUNT(DISTINCT c.contact_id) over() contact_dublicates
                          FROM as_assured       a
                              ,as_asset         se
                              ,contact          c
                              ,cn_person        cn
                              ,cn_contact_ident ci
                              ,t_id_type        it
                         WHERE se.p_policy_id = p_pol_id
                           AND c.contact_id = cn.contact_id
                           AND a.assured_contact_id = c.contact_id
                           AND se.as_asset_id = a.as_assured_id
                           AND se.start_date = assets.cover_start_date
                           AND TRIM(c.obj_name) =
                               TRIM(upper(assets.last_name ||
                                          decode(assets.first_name, NULL, '', ' ' || assets.first_name) ||
                                          decode(assets.middle_name
                                                ,NULL
                                                ,''
                                                ,' ' || assets.middle_name)))
                           AND cn.date_of_birth = assets.birth_date
                           AND it.brief IN ('PASS_RF', 'PASS_SSSR', 'PASS_IN')
                           AND ci.serial_nr = assets.passport_ser
                           AND ci.id_value = assets.passport_num
                           AND ci.issue_date = assets.issue_date
                           AND EXISTS (SELECT NULL
                                  FROM p_cover            pc
                                      ,t_prod_line_option plo
                                      ,t_product_line     pl
                                 WHERE pc.as_asset_id = se.as_asset_id
                                   AND pc.t_prod_line_option_id = plo.id
                                   AND plo.product_line_id = pl.id
                                   AND pl.brief = assets.product_line_brief)
                         ORDER BY se.as_asset_id DESC)
                 WHERE rownum = 1;
              EXCEPTION
                WHEN no_data_found THEN
                  raise_app_error(assets.last_name
                                 ,assets.first_name
                                 ,assets.num_field
                                 ,'Не удалось идентифицировать застрахованного по паспорту'
                                 ,skip_exception_num);
              END;
              IF v_n_contacts > 1
              THEN
                raise_app_error(assets.last_name
                               ,assets.first_name
                               ,assets.num_field
                               ,'Контакту соответствуют несколько застрахованных'
                               ,skip_exception_num);
              END IF;
            END IF;
          
            BEGIN
              SELECT pc.p_cover_id
                    ,plo.id
                INTO v_cover_id
                    ,v_prod_line_option_id
                FROM p_cover            pc
                    ,t_product_line     tpl
                    ,t_prod_line_option plo
               WHERE pc.as_asset_id = v_as_assured_id
                 AND pc.t_prod_line_option_id = plo.id
                 AND plo.product_line_id = tpl.id
                 AND tpl.brief = assets.product_line_brief;
            EXCEPTION
              WHEN no_data_found THEN
                --RAISE_APP_ERROR(assets, 'Не найдено исключаемое покрытие');
                NULL;
            END;
            IF v_cover_id IS NOT NULL
            THEN
              pkg_decline2.calc_decline_cover_group(par_cover_id            => v_cover_id
                                                   ,par_as_asset_id         => v_as_assured_id
                                                   ,par_prod_line_option_id => v_prod_line_option_id
                                                   ,par_policy_id           => p_pol_id
                                                   ,par_decline_date        => v_decline_date
                                                   ,par_decline_reason_id   => v_def_decline_reason_id
                                                   ,par_decline_party_id    => v_def_decline_party_id);
            
              pkg_cover.exclude_cover_group(par_cover_id  => v_cover_id
                                           ,par_asset_id  => v_as_assured_id
                                           ,par_policy_id => p_pol_id);
            
              UPDATE p_cover pc SET pc.return_summ = assets.premium WHERE pc.p_cover_id = v_cover_id;
            
              v_cover_count := 0;
            
              SELECT COUNT(*)
                INTO v_cover_count
                FROM p_cover pc
               WHERE pc.as_asset_id = v_as_assured_id
                 AND pc.status_hist_id IN (status_hist_id_new, status_hist_id_curr);
            
              IF v_cover_count = 0
              THEN
                IF v_as_status_hist = status_hist_id_new
                THEN
                  DELETE FROM ven_p_asset_header pah WHERE pah.p_asset_header_id = v_asset_header_id;
                
                ELSIF v_as_status_hist = status_hist_id_curr
                THEN
                  UPDATE ven_as_asset a
                     SET a.status_hist_id = status_hist_id_del
                   WHERE as_asset_id = v_as_assured_id;
                END IF;
              END IF;
            END IF;
          WHEN (assets.action = 'A') THEN
          
            --BEGIN
            IF assets.user_person_id IS NOT NULL
            THEN
              v_contact_id := assets.user_person_id;
            ELSIF assets.is_first = 1
            THEN
            
              create_contact(par_first_name          => assets.first_name
                            ,par_middle_name         => assets.middle_name
                            ,par_last_name           => assets.last_name
                            ,par_birth_date          => assets.birth_date
                            ,par_gender              => assets.gender
                            ,par_passport_ser        => assets.passport_ser
                            ,par_passport_num        => assets.passport_num
                            ,par_passport_issue_date => assets.issue_date
                            ,par_passport_issued_by  => assets.issued_by
                            ,par_contact_id_out      => v_contact_id);
            
              /*              v_contact_id := pkg_contact.create_person_contact(p_first_name      => assets.first_name
              ,p_middle_name     => assets.middle_name
              ,p_last_name       => assets.last_name
              ,p_birth_date      => assets.birth_date
              ,p_gender          => assets.gender
              ,p_pass_ser        => assets.passport_ser
              ,p_pass_num        => assets.passport_num
              ,p_pass_issue_date => assets.issue_date
              ,p_pass_issued_by  => assets.issued_by);*/
            
            END IF;
            /*
            EXCEPTION
              WHEN OTHERS THEN
                IF SQLCODE = pkg_contact.errc_plural_contacts
                THEN
                  p_out_number := assets.as_assured_load_tmp_id;
                  RETURN '@SELECT_PERSON';
                ELSE
                  raise_application_error(-20100, SQLERRM);
                END IF;
            END;
            */
            --v_as_assured_id := NULL;
          
            --Создадим застрахованного или выберем из существующих
            --на случай если заливаем несколько бордеро в одну версию
            BEGIN
              --Для банков возможно несколько застрахованных на одном и том же человеке
              IF assets.is_first = 1
              THEN
                IF v_pol_header_desc = 'Единовременный договор с подключением'
                THEN
                  SELECT /*+ LEADING(a) USE_NL(a se) */
                   a.as_assured_id
                  ,trunc(MONTHS_BETWEEN(se.start_date, assets.birth_date) / 12)
                    INTO v_as_assured_id
                        ,v_age
                    FROM as_assured a
                        ,as_asset   se
                   WHERE se.p_policy_id = p_pol_id
                     AND se.status_hist_id IN (1, 2) --Новый, Действующий /Чирков 334650/
                     AND se.as_asset_id = a.as_assured_id
                     AND se.start_date = assets.cover_start_date
                     AND a.assured_contact_id = v_contact_id;
                ELSE
                  SELECT /*+ LEADING(a) USE_NL(a se) */
                   a.as_assured_id
                  ,trunc(MONTHS_BETWEEN(se.start_date, assets.birth_date) / 12)
                    INTO v_as_assured_id
                        ,v_age
                    FROM as_assured a
                        ,as_asset   se
                   WHERE se.p_policy_id = p_pol_id
                     AND se.status_hist_id IN (1, 2) --Новый, Действующий /Чирков 334650/
                     AND se.as_asset_id = a.as_assured_id
                     AND a.assured_contact_id = v_contact_id;
                END IF;
              END IF;
            EXCEPTION
              WHEN too_many_rows THEN
                raise_app_error(assets.last_name
                               ,assets.first_name
                               ,assets.num_field
                               ,'Контакту соответствуют несколько застрахованных'
                               ,skip_exception_num);
              WHEN no_data_found THEN
                --v_as_assured_id := NULL;
                --v_as_status_hist := NULL;
                BEGIN
                  SELECT t_work_group_id
                    INTO v_work_group_id
                    FROM t_work_group
                   WHERE description LIKE assets.proff_class || '%';
                EXCEPTION
                  WHEN no_data_found THEN
                    v_work_group_id := 1;
                END;
              
                v_as_assured_id := create_as_assured(p_pol_id, v_contact_id, v_work_group_id);
                SELECT trunc(MONTHS_BETWEEN(se.start_date, assets.birth_date) / 12)
                  INTO v_age
                  FROM as_asset se
                 WHERE se.as_asset_id = v_as_assured_id;
                v_group_id := get_assured_group(assets.group_name, p_pol_id);
              
            END;
            -- END IF;
          
            BEGIN
              SELECT a.is_avtoprolongation
                    ,a.id
                INTO v_is_autoprolongation
                    ,v_prod_line_option_id
                FROM (SELECT pl.is_avtoprolongation
                            ,plo.id
                        FROM t_product_line     pl
                            ,t_prod_line_option plo
                       WHERE pl.id = plo.product_line_id
                         AND pl.brief = assets.product_line_brief
                       ORDER BY plo.default_flag) a
               WHERE rownum = 1;
            EXCEPTION
              WHEN no_data_found THEN
                raise_app_error(assets.last_name
                               ,assets.first_name
                               ,assets.num_field
                               ,'не найден подключаемый риск'
                               ,skip_exception_num);
            END;
            --v_cover_id := Pkg_Cover.include_cover(v_as_assured_id, v_pl_id);
            assets.cover_end_date := trunc(assets.cover_end_date) + 1 - INTERVAL '1' SECOND;
            --Будем считать что избыточные проверки нам не нужны.
            BEGIN
              v_cover_id := pkg_cover.create_cover(par_as_asset_id           => v_as_assured_id
                                                  ,par_prod_line_option_id   => v_prod_line_option_id
                                                  ,par_period_id             => v_period_id
                                                  ,par_insured_age           => v_age
                                                  ,par_start_date            => assets.cover_start_date
                                                  ,par_end_date              => assets.cover_end_date
                                                  ,par_ins_price             => NULL
                                                  ,par_ins_amount            => assets.ammount
                                                  ,par_fee                   => assets.premium
                                                  ,par_premium               => assets.premium *
                                                                                v_pay_term
                                                  ,par_is_autoprolongation   => v_is_autoprolongation
                                                  ,par_accum_period_end_age  => v_accum_period_end_age
                                                  ,par_is_handchange_amount  => 1
                                                  ,par_is_handchange_premium => 1
                                                  ,par_is_handchange_fee     => 1
                                                  ,par_is_handchange_tariff  => 1
                                                  ,par_status_hist_id        => pkg_cover.get_status_hist_id_new);
            EXCEPTION
              WHEN dup_val_on_index THEN
                SELECT pc.p_cover_id
                      ,pc.status_hist_id
                  INTO v_cover_id
                      ,v_status_hist_id
                  FROM p_cover pc
                 WHERE pc.as_asset_id = v_as_assured_id
                   AND pc.t_prod_line_option_id = v_prod_line_option_id;
                IF v_status_hist_id = status_hist_id_del
                THEN
                  UPDATE p_cover pc
                     SET pc.status_hist_id = status_hist_id_curr
                   WHERE pc.p_cover_id = v_cover_id;
                  -- отменяем расторжение
                  pkg_decline2.rollback_cover_decline(v_cover_id, 1);
                END IF;
            END;
            --Покрытие может прикрепляться на произвольную дату
          
            UPDATE ven_as_assured
               SET (start_date, end_date, pol_assured_group_id) =
                   (SELECT MIN(start_date)
                          ,MAX(end_date)
                          ,v_group_id
                      FROM p_cover pc
                     WHERE pc.as_asset_id = as_assured_id)
             WHERE as_assured_id = v_as_assured_id;
          WHEN (assets.action = 'C') THEN
            v_as_assured_id := NULL;
            BEGIN
            
              SELECT as_assured_id
                    ,status_hist_id
                    ,p_asset_header_id
                    ,contact_id
                    ,contact_dublicates
                INTO v_as_assured_id
                    ,v_as_status_hist
                    ,v_asset_header_id
                    ,v_contact_id
                    ,v_n_contacts
                FROM (SELECT /* LEADING(a) USE_NL(a se) */
                       a.as_assured_id
                      ,se.status_hist_id
                      ,se.p_asset_header_id
                      ,c.contact_id
                      ,COUNT(DISTINCT c.contact_id) over() contact_dublicates
                        FROM as_assured a
                            ,as_asset   se
                            ,contact    c
                            ,cn_person  cn
                       WHERE se.p_policy_id = p_pol_id
                         AND c.contact_id = cn.contact_id
                         AND a.assured_contact_id = c.contact_id
                         AND se.as_asset_id = a.as_assured_id
                            --Чирков/комментарий/237362: изменение страховых сумм 
                            --AND se.start_date = assets.cover_start_date
                         AND TRIM(c.obj_name) =
                             TRIM(upper(assets.last_name ||
                                        decode(assets.first_name, NULL, '', ' ' || assets.first_name) ||
                                        decode(assets.middle_name, NULL, '', ' ' || assets.middle_name)))
                         AND cn.date_of_birth = assets.birth_date
                         AND EXISTS (SELECT NULL
                                FROM p_cover            pc
                                    ,t_prod_line_option plo
                                    ,t_product_line     pl
                               WHERE pc.as_asset_id = se.as_asset_id
                                 AND pc.t_prod_line_option_id = plo.id
                                 AND plo.product_line_id = pl.id
                                 AND pl.brief = assets.product_line_brief)
                       ORDER BY se.as_asset_id DESC)
               WHERE rownum = 1;
            EXCEPTION
              WHEN no_data_found THEN
                raise_app_error(assets.last_name
                               ,assets.first_name
                               ,assets.num_field
                               ,'Не найден застрахованный'
                               ,skip_exception_num);
            END;
            IF v_n_contacts > 1
            THEN
              BEGIN
                SELECT as_assured_id
                      ,status_hist_id
                      ,p_asset_header_id
                      ,contact_id
                      ,contact_dublicates
                  INTO v_as_assured_id
                      ,v_as_status_hist
                      ,v_asset_header_id
                      ,v_contact_id
                      ,v_n_contacts
                  FROM (SELECT /* LEADING(a) USE_NL(a se) */
                         a.as_assured_id
                        ,se.status_hist_id
                        ,se.p_asset_header_id
                        ,c.contact_id
                        ,COUNT(DISTINCT c.contact_id) over() contact_dublicates
                          FROM as_assured       a
                              ,as_asset         se
                              ,contact          c
                              ,cn_person        cn
                              ,cn_contact_ident ci
                              ,t_id_type        it
                         WHERE se.p_policy_id = p_pol_id
                           AND c.contact_id = cn.contact_id
                           AND a.assured_contact_id = c.contact_id
                           AND se.as_asset_id = a.as_assured_id
                           AND se.start_date = assets.cover_start_date
                           AND TRIM(c.obj_name) =
                               TRIM(upper(assets.last_name ||
                                          decode(assets.first_name, NULL, '', ' ' || assets.first_name) ||
                                          decode(assets.middle_name
                                                ,NULL
                                                ,''
                                                ,' ' || assets.middle_name)))
                           AND cn.date_of_birth = assets.birth_date
                           AND it.brief IN ('PASS_RF', 'PASS_SSSR', 'PASS_IN')
                           AND ci.serial_nr = assets.passport_ser
                           AND ci.id_value = assets.passport_num
                           AND ci.issue_date = assets.issue_date
                           AND EXISTS (SELECT NULL
                                  FROM p_cover            pc
                                      ,t_prod_line_option plo
                                      ,t_product_line     pl
                                 WHERE pc.as_asset_id = se.as_asset_id
                                   AND pc.t_prod_line_option_id = plo.id
                                   AND plo.product_line_id = pl.id
                                   AND pl.brief = assets.product_line_brief)
                         ORDER BY se.as_asset_id DESC)
                 WHERE rownum = 1;
              EXCEPTION
                WHEN no_data_found THEN
                  raise_app_error(assets.last_name
                                 ,assets.first_name
                                 ,assets.num_field
                                 ,'Не удалось идентифицировать застрахованного по паспорту'
                                 ,skip_exception_num);
              END;
              IF v_n_contacts > 1
              THEN
                raise_app_error(assets.last_name
                               ,assets.first_name
                               ,assets.num_field
                               ,'Контакту соответствуют несколько застрахованных'
                               ,skip_exception_num);
              END IF;
            END IF;
          
            BEGIN
              SELECT pc.p_cover_id
                INTO v_cover_id
                FROM p_cover            pc
                    ,t_product_line     tpl
                    ,t_prod_line_option plo
               WHERE pc.as_asset_id = v_as_assured_id
                 AND pc.t_prod_line_option_id = plo.id
                 AND plo.product_line_id = tpl.id
                 AND tpl.brief = assets.product_line_brief;
            EXCEPTION
              WHEN no_data_found THEN
                raise_app_error(assets.last_name
                               ,assets.first_name
                               ,assets.num_field
                               ,'Не найдено изменяемое покрытие'
                               ,skip_exception_num);
            END;
          
            SELECT pt.number_of_payments
                  ,pol.is_group_flag
              INTO v_pay_term
                  ,v_is_group_flag
              FROM p_policy        pol
                  ,t_payment_terms pt
                  ,as_asset        ass
                  ,p_cover         pc
             WHERE pol.payment_term_id = pt.id
               AND pol.policy_id = ass.p_policy_id
               AND ass.as_asset_id = pc.as_asset_id
               AND pc.p_cover_id = v_cover_id;
          
            UPDATE p_cover
               SET is_handchange_amount  = 1
                  ,is_handchange_premium = 1
                  ,is_handchange_fee     = 1
                  ,is_handchange_tariff  = 1
                  ,ins_amount            = assets.ammount
                  ,fee                   = assets.premium
                  ,
                   --Чирков 212654: Заливка Застрахованных с признаком "С"
                   premium    = assets.premium * v_pay_term
                  ,start_date = assets.cover_start_date
                  ,end_date   = assets.cover_end_date
                  ,period_id  = v_period_id
            --
             WHERE p_cover_id = v_cover_id;
          
            v_asset_prem := v_asset_prem + assets.premium * v_pay_term;
            v_asset_sum  := v_asset_sum + assets.ammount;
          
            UPDATE ven_as_asset a
               SET ins_amount  = v_asset_sum
                  ,ins_premium = v_asset_prem
                   /*изменил дату начала окончания по заявке 282426/Чирков/
                   ,(start_date, end_date) =
                    (SELECT MIN(start_date)
                           ,MAX(end_date)
                       FROM p_cover pc
                                    WHERE pc.as_asset_id = v_as_assured_id)*/
                  ,start_date = get_asset_start_date(v_as_assured_id
                                                    ,a.p_asset_header_id
                                                    ,v_is_group_flag)
                  ,end_date   = get_asset_end_date(v_as_assured_id)
            
             WHERE as_asset_id = v_as_assured_id;
          
        END CASE;
      
        set_loaded_flag(assets.as_assured_load_tmp_id, 1);
        --        COMMIT;
      EXCEPTION
        /*          WHEN OTHERS THEN
                  set_loaded_flag(assets.as_assured_load_tmp_id, 3);
                  ROLLBACK;
                  --          ROLLBACK TO SAVEPOINT sp_load_ass;
                  pkg_cover.cover_property_cache.DELETE;
                  RETURN SQLERRM;
        */
        WHEN skip_exception THEN
          v_error_message := substr(SQLERRM, 1, 2000);
          ROLLBACK TO import_assured;
          UPDATE as_assured_load_tmp lt
             SET lt.error_text = v_error_message
                ,lt.is_loaded  = 3
           WHERE lt.as_assured_load_tmp_id = assets.as_assured_load_tmp_id;
          --          COMMIT;
        -- Пока критичные ошибки обрабатываются также, как OTHERS
        WHEN critical_exception THEN
          v_error_message := substr(SQLERRM, 1, 2000);
          ROLLBACK TO import_assured;
          set_loaded_flag(assets.as_assured_load_tmp_id, 3);
          -- пересчитать премию по полису
          pkg_policy.update_policy_sum(p_pol_id);
          --COMMIT;
          pkg_cover.cover_property_cache.delete;
          RETURN v_error_message;
        WHEN OTHERS THEN
          ROLLBACK TO import_assured;
          set_loaded_flag(assets.as_assured_load_tmp_id, 3);
          -- пересчитать премию по полису
          pkg_policy.update_policy_sum(p_pol_id);
          --COMMIT;
          pkg_cover.cover_property_cache.delete;
          RETURN SQLERRM;
      END;
      v_cnt := v_cnt + 1;
      IF MOD(v_cnt, 50) = 0
      THEN
        dbms_application_info.set_client_info('Обработано: ' || to_char(v_cnt));
      END IF;
    END LOOP;
    -- пересчитать премию по полису
    pkg_policy.update_policy_sum(p_pol_id);
    pkg_cover.cover_property_cache.delete;
    --COMMIT;
    RETURN 'Ok';
  END load_assured;

  /*
    Байтин А.
    Базовое добавление выгодоприобретателя застрахованному
  */
  PROCEDURE add_beneficiary_base
  (
    par_asset_id       NUMBER
   ,par_contact_id     NUMBER
   ,par_value          NUMBER
   ,par_value_type_id  NUMBER
   ,par_currency_id    NUMBER
   ,par_contact_rel_id NUMBER
   ,par_comments       VARCHAR2 DEFAULT NULL
   ,par_beneficiary_id OUT NUMBER
  ) IS
  BEGIN
    SELECT sq_as_beneficiary.nextval INTO par_beneficiary_id FROM dual;
  
    INSERT INTO ven_as_beneficiary
      (as_beneficiary_id
      ,as_asset_id
      ,contact_id
      ,VALUE
      ,value_type_id
      ,t_currency_id
      ,cn_contact_rel_id
      ,comments)
    VALUES
      (par_beneficiary_id
      ,par_asset_id
      ,par_contact_id
      ,nvl(par_value, 0)
      ,par_value_type_id
      ,par_currency_id
      ,par_contact_rel_id
      ,par_comments);
  EXCEPTION
    WHEN dup_val_on_index THEN
      raise_application_error(-20001
                             ,'Нарушение ограничения уникальности выгодоприобретателей у застрахованного');
  END add_beneficiary_base;

  /*
  Капля П.
  Механизм работал не правильно.
  Заменил на более прозначный
  
  PROCEDURE add_relation_to_beneficiary
  (
    par_asset_contact_id       NUMBER
   ,par_beneficiary_contact_id NUMBER
   ,par_assured_rel_name       VARCHAR2 DEFAULT NULL
   ,par_beneficiary_rel_name   VARCHAR2 DEFAULT NULL
   ,par_relation_id            IN OUT NUMBER
   ,par_rev_relation_id        IN OUT NUMBER
  ) IS
    v_relation_type_id     NUMBER;
    v_rev_relation_type_id NUMBER;
    v_gender_id            NUMBER;
    v_gender_desc          t_gender.description%TYPE;
  BEGIN
    BEGIN
      SELECT rt.id
            ,rt.reverse_relationship_type
            ,CASE
               WHEN par_relation_id IS NULL THEN
                cr.id
               ELSE
                par_relation_id
             END
        INTO v_relation_type_id
            ,v_rev_relation_type_id
            ,par_relation_id
        FROM cn_contact_rel     cr
            ,t_contact_rel_type rt
       WHERE cr.contact_id_a = par_asset_contact_id
         AND cr.contact_id_b = par_beneficiary_contact_id
         AND cr.relationship_type = rt.id
         AND ((rt.relationship_dsc = par_assured_rel_name OR par_assured_rel_name IS NULL) OR
             (upper(rt.for_dsc) = upper(par_beneficiary_rel_name) OR par_beneficiary_rel_name IS NULL));
    EXCEPTION
      WHEN no_data_found THEN
        IF par_assured_rel_name IS NOT NULL
           AND par_beneficiary_rel_name IS NOT NULL
        THEN
          BEGIN
            SELECT rt.id
                  ,rt.reverse_relationship_type
              INTO v_relation_type_id
                  ,v_rev_relation_type_id
              FROM t_contact_rel_type rt
             WHERE rt.source_contact_role_id = 1
               AND rt.target_contact_role_id = 12
               AND rt.relationship_dsc = par_assured_rel_name
               AND rt.for_dsc = par_beneficiary_rel_name;
          EXCEPTION
            WHEN no_data_found THEN
              raise_application_error(-20001
                                     ,'Не найден тип связи между "' || par_assured_rel_name ||
                                      '" и "' || par_beneficiary_rel_name || '"');
            WHEN too_many_rows THEN
              raise_application_error(-20001
                                     ,'Найдено несколько типов связи между "' || par_assured_rel_name ||
                                      '" и "' || par_beneficiary_rel_name || '"');
          END;
        ELSIF par_assured_rel_name IS NOT NULL
        THEN
          BEGIN
            SELECT cp.gender
              INTO v_gender_id
              FROM cn_person cp
             WHERE cp.contact_id = par_beneficiary_contact_id;
          EXCEPTION
            WHEN no_data_found THEN
              raise_application_error(-20001
                                     ,'Не удалось определить значение пола у контакта с ID: "' ||
                                      par_beneficiary_contact_id || '"');
          END;
        
          BEGIN
            SELECT rt.id
                  ,rt.reverse_relationship_type
              INTO v_relation_type_id
                  ,v_rev_relation_type_id
              FROM t_contact_rel_type rt
             WHERE rt.source_contact_role_id = 1
               AND rt.target_contact_role_id = 12
               AND rt.relationship_dsc = par_assured_rel_name
               AND (rt.target_gender_id = v_gender_id OR
                   rt.target_gender_id IS NULL AND rt.gender_id IS NULL);
          EXCEPTION
            WHEN no_data_found THEN
              SELECT tg.description INTO v_gender_desc FROM t_gender tg WHERE tg.id = v_gender_id;
              raise_application_error(-20001
                                     ,'Не найден тип связи между "' || par_assured_rel_name ||
                                      '" и объектом с полом "' || v_gender_desc || '"');
            WHEN too_many_rows THEN
              SELECT tg.description INTO v_gender_desc FROM t_gender tg WHERE tg.id = v_gender_id;
              raise_application_error(-20001
                                     ,'Найдено несколько типов связи между "' || par_assured_rel_name ||
                                      '" и объектом с полом "' || v_gender_desc || '"');
          END;
        ELSIF par_beneficiary_rel_name IS NOT NULL
        THEN
          BEGIN
            SELECT cp.gender
              INTO v_gender_id
              FROM cn_person cp
             WHERE cp.contact_id = par_asset_contact_id;
          EXCEPTION
            WHEN no_data_found THEN
              raise_application_error(-20001
                                     ,'Не удалось определить значение пола у контакта с ID: "' ||
                                      par_asset_contact_id || '"');
          END;
        
          BEGIN
            SELECT rt.id
                  ,rt.reverse_relationship_type
              INTO v_relation_type_id
                  ,v_rev_relation_type_id
              FROM t_contact_rel_type rt
             WHERE rt.source_contact_role_id = 1
               AND rt.target_contact_role_id = 12
               AND upper(rt.relationship_dsc) = upper(par_beneficiary_rel_name)
               AND (rt.target_gender_id = v_gender_id OR
                   rt.target_gender_id IS NULL AND rt.gender_id IS NULL);
          EXCEPTION
            WHEN no_data_found THEN
              SELECT tg.description INTO v_gender_desc FROM t_gender tg WHERE tg.id = v_gender_id;
              raise_application_error(-20001
                                     ,'Не найден тип связи между "' || par_beneficiary_rel_name ||
                                      '" и объектом с полом "' || v_gender_desc || '"');
            WHEN too_many_rows THEN
              SELECT tg.description INTO v_gender_desc FROM t_gender tg WHERE tg.id = v_gender_id;
              raise_application_error(-20001
                                     ,'Найдено несколько типов связи между "' ||
                                      par_beneficiary_rel_name || '" и объектом с полом "' ||
                                      v_gender_desc || '"');
          END;
        ELSE
          raise_application_error(-20001
                                 ,'Связь между контактами должна быть обязательно указана');
        END IF;
        IF par_relation_id IS NULL
        THEN
          SELECT sq_cn_contact_rel.nextval INTO par_relation_id FROM dual;
        END IF;
      
        INSERT INTO ven_cn_contact_rel
          (id, contact_id_a, contact_id_b, relationship_type)
        VALUES
          (par_relation_id, par_asset_contact_id, par_beneficiary_contact_id, v_relation_type_id);
      
        IF par_asset_contact_id != par_beneficiary_contact_id
        THEN
          IF par_rev_relation_id IS NULL
          THEN
            SELECT sq_cn_contact_rel.nextval INTO par_rev_relation_id FROM dual;
          END IF;
        
          INSERT INTO ven_cn_contact_rel
            (id, contact_id_b, contact_id_a, relationship_type)
          VALUES
            (par_rev_relation_id
            ,par_asset_contact_id
            ,par_beneficiary_contact_id
            ,v_relation_type_id);
        END IF;
    END;
  END add_relation_to_beneficiary;*/

  /*
    Байтин А.
    Добавление выгодоприобретателя застрахованному
  */
  PROCEDURE add_beneficiary
  (
    par_asset_id          NUMBER
   ,par_contact_id        NUMBER
   ,par_value             NUMBER
   ,par_value_type_brief  VARCHAR2 DEFAULT 'percent'
   ,par_currency_brief    VARCHAR2 DEFAULT 'RUR'
   ,par_contact_rel_brief VARCHAR2 DEFAULT NULL
   ,par_comments          VARCHAR2 DEFAULT NULL
   ,par_beneficiary_id    OUT NUMBER
  ) IS
    v_path_type_id     t_path_type.t_path_type_id%TYPE;
    v_fund_id          fund.fund_id%TYPE;
    v_relation_id      cn_contact_rel.id%TYPE;
    v_relation_type_id t_contact_rel_type.id%TYPE;
    v_asset_contact_id as_assured.assured_contact_id%TYPE;
  
    FUNCTION get_value_type_by_brief(par_value_type_brief t_path_type.brief%TYPE)
      RETURN t_path_type.t_path_type_id%TYPE IS
      v_path_type_id t_path_type.t_path_type_id%TYPE;
    BEGIN
      SELECT pt.t_path_type_id
        INTO v_path_type_id
        FROM t_path_type pt
       WHERE pt.brief = par_value_type_brief;
      RETURN v_path_type_id;
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20001
                               ,'Не найден тип доли выгодоприобретателя с кратким наименованием "' ||
                                par_value_type_brief || '"');
    END get_value_type_by_brief;
  
    FUNCTION get_fund_by_brief(par_fund_brief fund.brief%TYPE) RETURN fund.fund_id%TYPE IS
      v_fund_id fund.fund_id%TYPE;
    BEGIN
      SELECT fd.fund_id INTO v_fund_id FROM fund fd WHERE fd.brief = par_fund_brief;
      RETURN v_fund_id;
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20001
                               ,'Не найдена валюта с кратким наименованием "' || par_fund_brief || '"');
    END get_fund_by_brief;
  
    -- Проверка, чтобы сумма процентов не превышала 100
    PROCEDURE check_value_limit
    (
      par_asset_id     as_beneficiary.as_asset_id%TYPE
     ,par_path_type_id t_path_type.t_path_type_id%TYPE
     ,par_value        as_beneficiary.value%TYPE
    ) IS
      v_percents as_beneficiary.value%TYPE;
    BEGIN
      SELECT nvl(SUM(be.value), 0)
        INTO v_percents
        FROM as_beneficiary be
       WHERE be.value_type_id = par_path_type_id
         AND be.as_asset_id = par_asset_id;
    
      IF v_percents + par_value NOT BETWEEN 0 AND 100
      THEN
        raise_application_error(-20001
                               ,'Доля не должна быть меньше 0% или превышать 100%');
      END IF;
    
    END check_value_limit;
  
    FUNCTION get_relation_type_by_desc
    (
      par_asset_contact_id        contact.contact_id%TYPE
     ,par_beneficiary_contact_id  contact.contact_id%TYPE
     ,par_benef_to_asset_rel_name t_contact_rel_type.relationship_dsc%TYPE
    ) RETURN t_contact_rel_type.id%TYPE IS
      v_contact_rel_type_id t_contact_rel_type.id%TYPE;
      v_gender_id           t_gender.id%TYPE := pkg_contact.get_sex_id(par_beneficiary_contact_id);
      v_target_gender_id    t_gender.id%TYPE := pkg_contact.get_sex_id(par_asset_contact_id);
    
      FUNCTION get_gender_name_by_id(par_gender_id t_gender.id%TYPE) RETURN t_gender.description%TYPE IS
        v_gender_name t_gender.description%TYPE;
      BEGIN
        SELECT g.description INTO v_gender_name FROM t_gender g WHERE g.id = par_gender_id;
      
        RETURN v_gender_name;
      EXCEPTION
        WHEN no_data_found THEN
          RETURN NULL;
      END get_gender_name_by_id;
    BEGIN
    
      SELECT crt.id
        INTO v_contact_rel_type_id
        FROM t_contact_rel_type crt
            ,t_contact_role     cr_benif
            ,t_contact_role     cr_asset
       WHERE crt.source_contact_role_id = cr_asset.id
         AND crt.target_contact_role_id = cr_benif.id
         AND cr_asset.brief = 'ASSURED'
         AND cr_benif.brief = 'BENEFICIARY'
         AND upper(crt.relationship_dsc) = TRIM(upper(par_benef_to_asset_rel_name))
         AND lnnvl(crt.gender_id != v_gender_id)
         AND lnnvl(crt.target_gender_id != v_target_gender_id)
         AND rownum = 1;
    
      RETURN v_contact_rel_type_id;
    EXCEPTION
      WHEN no_data_found THEN
        DECLARE
          v_msg VARCHAR2(1000);
        BEGIN
          v_msg := 'Не удалось найти тип связи "' || nvl(par_benef_to_asset_rel_name, 'NULL') ||
                   '" в справочнике для выгодоприобритателя ';
          IF v_gender_id IS NOT NULL
          THEN
            v_msg := v_msg || 'с полом "' || get_gender_name_by_id(v_gender_id);
          ELSE
            v_msg := v_msg || 'без пола';
          
          END IF;
          v_msg := v_msg || ' и застрахованного с полом "' ||
                   get_gender_name_by_id(v_target_gender_id) || '"';
          raise_application_error(-20001, v_msg);
        END;
    END get_relation_type_by_desc;
  BEGIN
  
    SELECT su.assured_contact_id
      INTO v_asset_contact_id
      FROM as_assured su
     WHERE su.as_assured_id = par_asset_id;
  
    v_relation_type_id := get_relation_type_by_desc(par_asset_contact_id        => v_asset_contact_id
                                                   ,par_beneficiary_contact_id  => par_contact_id
                                                   ,par_benef_to_asset_rel_name => par_contact_rel_brief);
  
    BEGIN
      SELECT ccr.id
        INTO v_relation_id
        FROM cn_contact_rel ccr
       WHERE ccr.contact_id_a = v_asset_contact_id
         AND ccr.contact_id_b = par_contact_id
         AND ccr.relationship_type = v_relation_type_id;
    EXCEPTION
      WHEN no_data_found THEN
        pkg_contact.add_contacts_relation(par_contact_a_id   => v_asset_contact_id
                                         ,par_contact_b_id   => par_contact_id
                                         ,par_rel_type_id    => v_relation_type_id
                                         ,par_contact_rel_id => v_relation_id);
    END;
  
    v_path_type_id := get_value_type_by_brief(par_value_type_brief);
  
    IF par_value_type_brief = 'percent'
    THEN
      check_value_limit(par_asset_id     => par_asset_id
                       ,par_path_type_id => v_path_type_id
                       ,par_value        => par_value);
    END IF;
  
    v_fund_id := get_fund_by_brief(par_currency_brief);
  
    add_beneficiary_base(par_asset_id       => par_asset_id
                        ,par_contact_id     => par_contact_id
                        ,par_value          => nvl(par_value, 0)
                        ,par_value_type_id  => v_path_type_id
                        ,par_currency_id    => v_fund_id
                        ,par_contact_rel_id => v_relation_id
                        ,par_comments       => par_comments
                        ,par_beneficiary_id => par_beneficiary_id);
  
  END add_beneficiary;

  /** Определение даты начала объекта страхования
  *   создана по заявке 282426
  *   @autor Чирков В. Ю.
  *   @param par_as_asset_id - ID объекта страхования
  *   @param par_asset_header_id - ID заголовка объекта страхования
  *   @param par_is_group - групповой договор или нет
  */
  FUNCTION get_asset_start_date
  (
    par_as_asset_id     NUMBER
   ,par_asset_header_id NUMBER
   ,par_is_group        NUMBER
  ) RETURN DATE IS
    v_is_group   ins.p_policy.is_group_flag%TYPE;
    v_start_date DATE;
  BEGIN
    --определяем признак группопвого договора
  
    /*если договор групповой, то дата начала объекта (as_asset.start_date) 
    определяется как минимальное значение из всех покрытий по всем объектам (as_asset_id),
    имеющих тот же заголовок объекта (as_asset_header_id).
    */
    IF par_is_group = 1
    THEN
      SELECT MIN(pc.start_date)
        INTO v_start_date
        FROM ins.as_asset aa
            ,ins.p_cover  pc
       WHERE aa.as_asset_id = pc.as_asset_id
         AND pc.status_hist_id IN (1, 2)
            --
         AND aa.p_asset_header_id = par_asset_header_id;
    ELSE
      /*если договоре не групповой, то берем минимальную дату по покрытиям данного объекта*/
      SELECT MIN(pc.start_date)
        INTO v_start_date
        FROM ins.p_cover pc
       WHERE pc.status_hist_id IN (1, 2)
            --
         AND pc.as_asset_id = par_as_asset_id;
    END IF;
    RETURN v_start_date;
  END get_asset_start_date;

  /** Определение даты окончания объекта страхования
  *   создана по заявке 282426
  *   @autor Чирков В. Ю.
  *   @param par_as_asset_id - ID объекта страхования
  */
  FUNCTION get_asset_end_date(par_as_asset_id NUMBER) RETURN DATE IS
    v_is_group ins.p_policy.is_group_flag%TYPE;
    v_end_date DATE;
  BEGIN
    SELECT MAX(pc.end_date)
      INTO v_end_date
      FROM ins.p_cover pc
     WHERE pc.status_hist_id IN (1, 2)
       AND pc.as_asset_id = par_as_asset_id;
    RETURN v_end_date;
  END get_asset_end_date;

/**********************************************************************************************************************/

BEGIN
  SELECT sh.status_hist_id INTO status_hist_id_new FROM ven_status_hist sh WHERE sh.brief = 'NEW';
  SELECT sh.status_hist_id
    INTO status_hist_id_curr
    FROM ven_status_hist sh
   WHERE sh.brief = 'CURRENT';
  SELECT sh.status_hist_id INTO status_hist_id_del FROM ven_status_hist sh WHERE sh.brief = 'DELETED';

END;
/

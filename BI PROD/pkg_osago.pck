CREATE OR REPLACE PACKAGE Pkg_Osago IS

  -- Author  : ABALASHOV
  -- Created : 11.12.2006 11:12:23
  -- Purpose :

  PROCEDURE load_city;
  FUNCTION kbm_prolongation_str
  (
    kbm_old IN VARCHAR2
   ,c_ev    NUMBER
  ) RETURN VARCHAR;
  FUNCTION kbm_prolongation_id
  (
    kbm_old_id IN NUMBER
   ,c_ev       NUMBER
  ) RETURN NUMBER;
  FUNCTION customer_is(p_ph_id IN NUMBER) RETURN NUMBER;
  FUNCTION owner_is(p_ph_id IN NUMBER) RETURN NUMBER;

  -- Protsvetov 03.01.2007
  -- ID Страхователя ТС
  FUNCTION customer_id(p_ph_id IN NUMBER) RETURN NUMBER;
  -- ID Собственника ТС
  FUNCTION owner_id(p_ph_id IN NUMBER) RETURN NUMBER;
  -- Класс, присвоееный собственнику ТС
  FUNCTION owner_klass(p_ph_id IN NUMBER) RETURN VARCHAR2;
  -- Функция расчета РНП по версии полиса
  FUNCTION rnp_policy
  (
    p_pol IN NUMBER
   ,p_dt  DATE
  ) RETURN NUMBER;
  -- Функция расчета RZU по претензии
  FUNCTION rzu_claim
  (
    p_ch IN NUMBER
   ,p_dt DATE
  ) RETURN NUMBER;
  -- Функция расчета RZU по расторжению
  FUNCTION rzu_policy
  (
    p_pol IN NUMBER
   ,p_dt  DATE
  ) RETURN NUMBER;

  ---------------------------------------------------------

  PROCEDURE get_casco_summ
  (
    p_ph_id       IN NUMBER
   ,p_year_number IN NUMBER
   ,p_asset_id    IN NUMBER
   ,p_s_casco     OUT NUMBER
   ,p_s_do        OUT NUMBER
   ,p_s_otv       OUT NUMBER
   ,p_s_ns        OUT NUMBER
   ,p_pr_casco    OUT NUMBER
   ,p_pr_do       OUT NUMBER
   ,p_pr_otv      OUT NUMBER
   ,p_pr_ns       OUT NUMBER
   ,p_srok_beg    OUT VARCHAR2
   ,p_srok_end    OUT VARCHAR2
  );
  --Функция проверки на совпадение номера полиса с номером БСО
--FUNCTION check_bso_policy_num(p_policy_id IN NUMBER) RETURN NUMBER;

END Pkg_Osago;
/
CREATE OR REPLACE PACKAGE BODY Pkg_Osago IS

  PROCEDURE load_city AS
  BEGIN
  
    -- по регионам
    DELETE FROM T_PROD_COEF pc
     WHERE pc.t_prod_coef_type_id =
           (SELECT pct.t_prod_coef_type_id
              FROM T_PROD_COEF_TYPE pct
             WHERE pct.brief = 'OSAGO_AREA_PROVINCE');
    -- грузим москву и питер
    INSERT INTO T_PROD_COEF
      (t_prod_coef_id, t_prod_coef_type_id, criteria_1, val)
      SELECT sq_t_prod_coef.NEXTVAL
            ,(SELECT pct.t_prod_coef_type_id
               FROM T_PROD_COEF_TYPE pct
              WHERE pct.brief = 'OSAGO_AREA_PROVINCE')
            ,tp.province_id
            ,DECODE(tp.province_name, 'Москва', '1', '2')
        FROM T_PROVINCE tp
       WHERE tp.province_name IN ('Санкт-Петербург', 'Москва');
  
    -- по городам
    DELETE FROM T_PROD_COEF pc
     WHERE pc.t_prod_coef_type_id = (SELECT pct.t_prod_coef_type_id
                                       FROM T_PROD_COEF_TYPE pct
                                      WHERE pct.brief = 'OSAGO_AREA_CITY');
  
    -- грузим города
    INSERT INTO T_PROD_COEF
      (t_prod_coef_id, t_prod_coef_type_id, criteria_1, val)
      SELECT sq_t_prod_coef.NEXTVAL
            ,(SELECT pct.t_prod_coef_type_id
               FROM T_PROD_COEF_TYPE pct
              WHERE pct.brief = 'OSAGO_AREA_CITY')
            ,t.city_id
            ,CASE
               WHEN SUBSTR(t.ocatd, 1, 2) = '46' THEN
                '3'
               WHEN SUBSTR(t.ocatd, 1, 2) = '41' THEN
                '4'
               WHEN t.city_name IN ('Астрахань'
                                   ,'Барнаул'
                                   ,'Брянск'
                                   ,'Владивосток'
                                   ,'Волгоград'
                                   ,'Воронеж'
                                   ,'Екатеринбург'
                                   ,'Иваново'
                                   ,'Ижевск'
                                   ,'Иркутск'
                                   ,'Казань'
                                   ,'Калининград'
                                   ,'Кемерово'
                                   ,'Киров'
                                   ,'Краснодар'
                                   ,'Красноярск'
                                   ,'Курск'
                                   ,'Липецк'
                                   ,'Магнитогорск'
                                   ,'Набережные Челны'
                                   ,'Нижний Новгород'
                                   ,'Новокузнецк'
                                   ,'Новосибирск'
                                   ,'Омск'
                                   ,'Оренбург'
                                   ,'Пенза'
                                   ,'Пермь'
                                   ,'Ростов-на-Дону'
                                   ,'Рязань'
                                   ,'Самара'
                                   ,'Саратов'
                                   ,'Тверь'
                                   ,'Тольятти'
                                   ,'Томск'
                                   ,'Тула'
                                   ,'Тюмень'
                                   ,'Ульяновск'
                                   ,'Уфа'
                                   ,'Хабаровск'
                                   ,'Чебоксары'
                                   ,'Челябинск'
                                   ,'Ярославль') THEN
                '5'
               WHEN t.city_name IN ('Абакан'
                                   ,'Азов'
                                   ,'Александров'
                                   ,'Алексин'
                                   ,'Альметьевск'
                                   ,'Амурск'
                                   ,'Анапа'
                                   ,'Ангарск'
                                   ,'Анжеро-Судженск'
                                   ,'Апатиты'
                                   ,'Арзамас'
                                   ,'Армавир'
                                   ,'Арсеньев'
                                   ,'Артем'
                                   ,'Архангельск'
                                   ,'Асбест'
                                   ,'Ачинск'
                                   ,'Балаково'
                                   ,'Балахна'
                                   ,'Балашов'
                                   ,'Батайск'
                                   ,'Белгород'
                                   ,'Белебей'
                                   ,'Белово'
                                   ,'Белогорск'
                                   ,'Белорецк'
                                   ,'Белореченск'
                                   ,'Бердск'
                                   ,'Березники'
                                   ,'Березовский'
                                   ,'Бийск'
                                   ,'Биробиджан'
                                   ,'Благовещенск'
                                   ,'Бор'
                                   ,'Борисоглебск'
                                   ,'Боровичи'
                                   ,'Братск'
                                   ,'Бугульма'
                                   ,'Бугуруслан'
                                   ,'Буденновск'
                                   ,'Бузулук'
                                   ,'Буйнакск'
                                   ,'Великие Луки'
                                   ,'Великий Новгород'
                                   ,'Верхняя Пышма'
                                   ,'Верхняя Салда'
                                   ,'Владикавказ'
                                   ,'Владимир'
                                   ,'Волгодонск'
                                   ,'Волжск'
                                   ,'Волжский'
                                   ,'Вологда'
                                   ,'Вольск'
                                   ,'Воркута'
                                   ,'Воткинск'
                                   ,'Выкса'
                                   ,'Вышний Волочек'
                                   ,'Вязьма'
                                   ,'Геленджик'
                                   ,'Георгиевск'
                                   ,'Глазов'
                                   ,'Горно-Алтайск'
                                   ,'Губкин'
                                   ,'Гуково'
                                   ,'Гусь-Хрустальный'
                                   ,'Дербент'
                                   ,'Дзержинск'
                                   ,'Димитровград'
                                   ,'Ейск'
                                   ,'Елабуга'
                                   ,'Елец'
                                   ,'Ессентуки'
                                   ,'Ефремов'
                                   ,'Железногорск'
                                   ,'Заречный'
                                   ,'Заринск'
                                   ,'Зеленогорск'
                                   ,'Зеленодольск'
                                   ,'Златоуст'
                                   ,'Инта'
                                   ,'Искитим'
                                   ,'Ишим'
                                   ,'Ишимбай'
                                   ,'Йошкар-Ола'
                                   ,'Калуга'
                                   ,'Каменск-Уральский'
                                   ,'Каменск-Шахтинский'
                                   ,'Камышин'
                                   ,'Канаш'
                                   ,'Канск'
                                   ,'Каспийск'
                                   ,'Кимры'
                                   ,'Кинешма'
                                   ,'Кирово-Чепецк'
                                   ,'Киселевск'
                                   ,'Кисловодск'
                                   ,'Клинцы'
                                   ,'Ковров'
                                   ,'Когалым'
                                   ,'Комсомольск-на-Амуре'
                                   ,'Копейск'
                                   ,'Кострома'
                                   ,'Котлас'
                                   ,'Краснокаменск'
                                   ,'Краснокамск'
                                   ,'Краснотурьинск'
                                   ,'Кропоткин'
                                   ,'Крымск'
                                   ,'Кстово'
                                   ,'Кузнецк'
                                   ,'Куйбышев'
                                   ,'Кумертау'
                                   ,'Кунгур'
                                   ,'Курган'
                                   ,'Курганинск'
                                   ,'Кызыл'
                                   ,'Лабинск'
                                   ,'Лениногорск'
                                   ,'Ленинск-Кузнецкий'
                                   ,'Лесной'
                                   ,'Лесосибирск'
                                   ,'Ливны'
                                   ,'Лиски'
                                   ,'Лысьва'
                                   ,'Магадан'
                                   ,'Майкоп'
                                   ,'Малгобек'
                                   ,'Махачкала'
                                   ,'Междуреченск'
                                   ,'Мелеуз'
                                   ,'Миасс'
                                   ,'Минеральные Воды'
                                   ,'Минусинск'
                                   ,'Михайловка'
                                   ,'Михайловск'
                                   ,'Мичуринск'
                                   ,'Мончегорск'
                                   ,'Мурманск'
                                   ,'Муром'
                                   ,'Мценск'
                                   ,'Назарово'
                                   ,'Назрань'
                                   ,'Нальчик'
                                   ,'Находка'
                                   ,'Невинномысск'
                                   ,'Нерюнгри'
                                   ,'Нефтекамск'
                                   ,'Нефтеюганск'
                                   ,'Нижневартовск'
                                   ,'Нижнекамск'
                                   ,'Нижний Тагил'
                                   ,'Новоалтайск'
                                   ,'Новокуйбышевск'
                                   ,'Новомосковск'
                                   ,'Новороссийск'
                                   ,'Новотроицк'
                                   ,'Новоуральск'
                                   ,'Новочебоксарск'
                                   ,'Новочеркасск'
                                   ,'Новошахтинск'
                                   ,'Новый Уренгой'
                                   ,'Норильск'
                                   ,'Ноябрьск'
                                   ,'Нягань'
                                   ,'Обнинск'
                                   ,'Озерск'
                                   ,'Октябрьский'
                                   ,'Орел'
                                   ,'Орск'
                                   ,'Осинники'
                                   ,'Отрадный'
                                   ,'Павлово'
                                   ,'Первоуральск'
                                   ,'Петрозаводск'
                                   ,'Петропавловск-Камчатский'
                                   ,'Печора'
                                   ,'Полевской'
                                   ,'Прокопьевск'
                                   ,'Прохладный'
                                   ,'Псков'
                                   ,'Пятигорск'
                                   ,'Ревда'
                                   ,'Ржев'
                                   ,'Рославль'
                                   ,'Россошь'
                                   ,'Рубцовск'
                                   ,'Рузаевка'
                                   ,'Рыбинск'
                                   ,'Салават'
                                   ,'Сальск'
                                   ,'Саранск'
                                   ,'Сарапул'
                                   ,'Саров'
                                   ,'Сатка'
                                   ,'Сафоново'
                                   ,'Саяногорск'
                                   ,'Свободный'
                                   ,'Северодвинск'
                                   ,'Североморск'
                                   ,'Северск'
                                   ,'Серов'
                                   ,'Сибай'
                                   ,'Славянск-на-Кубани'
                                   ,'Смоленск'
                                   ,'Соликамск'
                                   ,'Сочи'
                                   ,'Спасск-Дальний'
                                   ,'Ставрополь'
                                   ,'Старый Оскол'
                                   ,'Стерлитамак'
                                   ,'Сургут'
                                   ,'Сызрань'
                                   ,'Сыктывкар'
                                   ,'Таганрог'
                                   ,'Талнах'
                                   ,'Тамбов'
                                   ,'Тимашевск'
                                   ,'Тихорецк'
                                   ,'Тобольск'
                                   ,'Троицк (Челябинская область)'
                                   ,'Туапсе'
                                   ,'Туймазы'
                                   ,'Тулун'
                                   ,'Узловая'
                                   ,'Улан-Удэ'
                                   ,'Усолье-Сибирское'
                                   ,'Уссурийск'
                                   ,'Усть-Илимск'
                                   ,'Усть-Кут'
                                   ,'Ухта'
                                   ,'Ханты-Мансийск'
                                   ,'Хасавюрт'
                                   ,'Чайковский'
                                   ,'Чапаевск'
                                   ,'Чебаркуль'
                                   ,'Черемхово, Череповец'
                                   ,'Черкесск'
                                   ,'Черногорск'
                                   ,'Чистополь'
                                   ,'Чита'
                                   ,'Чусовой'
                                   ,'Шадринск'
                                   ,'Шахты'
                                   ,'Шелехов'
                                   ,'Шуя'
                                   ,'Щекино'
                                   ,'Элиста'
                                   ,'Энгельс'
                                   ,'Южно-Сахалинск'
                                   ,'Юрга'
                                   ,'Якутск'
                                   ,'Ярцево') THEN
                '6'
               ELSE
                '7'
             END CASE
        FROM T_CITY t;
  
    -- НАСЕЛЕННЫЕ ПУНКТЫ
    DELETE FROM T_PROD_COEF pc
     WHERE pc.t_prod_coef_type_id =
           (SELECT pct.t_prod_coef_type_id
              FROM T_PROD_COEF_TYPE pct
             WHERE pct.brief = 'OSAGO_AREA_DISTRICT');
    -- нас пункты Московской и Ленинградской области
    INSERT INTO T_PROD_COEF
      (t_prod_coef_id, t_prod_coef_type_id, criteria_1, val)
      SELECT sq_t_prod_coef.NEXTVAL
            ,(SELECT pct.t_prod_coef_type_id
               FROM T_PROD_COEF_TYPE pct
              WHERE pct.brief = 'OSAGO_AREA_DISTRICT')
            ,td.district_id
            ,CASE SUBSTR(td.ocatd, 1, 2)
               WHEN '46' THEN
                '3'
               WHEN '41' THEN
                '4'
             END
        FROM T_DISTRICT td
       WHERE SUBSTR(td.ocatd, 1, 2) IN ('46', '41');
    COMMIT;
  END;

  FUNCTION kbm_prolongation_str
  (
    kbm_old IN VARCHAR2
   ,c_ev    NUMBER
  ) RETURN VARCHAR AS
  BEGIN
  
    CASE kbm_old
      WHEN 'М' THEN
        IF (c_ev = 0)
        THEN
          RETURN '0';
        ELSE
          RETURN 'М';
        END IF;
      
      WHEN '0' THEN
        IF (c_ev = 0)
        THEN
          RETURN '1';
        ELSE
          RETURN 'М';
        END IF;
      
      WHEN '1' THEN
        IF (c_ev = 0)
        THEN
          RETURN '2';
        ELSE
          RETURN 'М';
        END IF;
      
      WHEN '2' THEN
        IF (c_ev = 0)
        THEN
          RETURN '3';
        ELSIF c_ev = 1
        THEN
          RETURN '1';
        ELSE
          RETURN 'М';
        END IF;
      
      WHEN '3' THEN
        IF (c_ev = 0)
        THEN
          RETURN '4';
        ELSIF c_ev = 1
        THEN
          RETURN '1';
        ELSE
          RETURN 'М';
        END IF;
      
      WHEN '4' THEN
        IF (c_ev = 0)
        THEN
          RETURN '5';
        ELSIF c_ev = 1
        THEN
          RETURN '2';
        ELSIF c_ev = 2
        THEN
          RETURN '1';
        ELSE
          RETURN 'М';
        END IF;
      
      WHEN '5' THEN
        IF (c_ev = 0)
        THEN
          RETURN '6';
        ELSIF c_ev = 1
        THEN
          RETURN '3';
        ELSIF c_ev = 2
        THEN
          RETURN '1';
        ELSE
          RETURN 'М';
        END IF;
      
      WHEN '6' THEN
        IF (c_ev = 0)
        THEN
          RETURN '7';
        ELSIF c_ev = 1
        THEN
          RETURN '4';
        ELSIF c_ev = 2
        THEN
          RETURN '2';
        ELSE
          RETURN 'М';
        END IF;
      
      WHEN '7' THEN
        IF (c_ev = 0)
        THEN
          RETURN '8';
        ELSIF c_ev = 1
        THEN
          RETURN '4';
        ELSIF c_ev = 2
        THEN
          RETURN '2';
        ELSE
          RETURN 'М';
        END IF;
      
      WHEN '8' THEN
        IF (c_ev = 0)
        THEN
          RETURN '9';
        ELSIF c_ev = 1
        THEN
          RETURN '5';
        ELSIF c_ev = 2
        THEN
          RETURN '2';
        ELSE
          RETURN 'М';
        END IF;
      
      WHEN '9' THEN
        IF (c_ev = 0)
        THEN
          RETURN '10';
        ELSIF c_ev = 1
        THEN
          RETURN '5';
        ELSIF c_ev = 2
        THEN
          RETURN '2';
        ELSIF c_ev = 3
        THEN
          RETURN '1';
        ELSE
          RETURN 'М';
        END IF;
      
      WHEN '10' THEN
        IF (c_ev = 0)
        THEN
          RETURN '11';
        ELSIF c_ev = 1
        THEN
          RETURN '6';
        ELSIF c_ev = 2
        THEN
          RETURN '3';
        ELSIF c_ev = 3
        THEN
          RETURN '1';
        ELSE
          RETURN 'М';
        END IF;
      
      WHEN '11' THEN
        IF (c_ev = 0)
        THEN
          RETURN '12';
        ELSIF c_ev = 1
        THEN
          RETURN '6';
        ELSIF c_ev = 2
        THEN
          RETURN '3';
        ELSIF c_ev = 3
        THEN
          RETURN '1';
        ELSE
          RETURN 'М';
        END IF;
      
      WHEN '12' THEN
        IF (c_ev = 0)
        THEN
          RETURN '13';
        ELSIF c_ev = 1
        THEN
          RETURN '6';
        ELSIF c_ev = 2
        THEN
          RETURN '3';
        ELSIF c_ev = 3
        THEN
          RETURN '1';
        ELSE
          RETURN 'М';
        END IF;
      
      WHEN '13' THEN
        IF (c_ev = 0)
        THEN
          RETURN '13';
        ELSIF c_ev = 1
        THEN
          RETURN '7';
        ELSIF c_ev = 2
        THEN
          RETURN '3';
        ELSIF c_ev = 3
        THEN
          RETURN '1';
        ELSE
          RETURN 'М';
        END IF;
    END CASE;
  END kbm_prolongation_str;

  FUNCTION kbm_prolongation_id
  (
    kbm_old_id IN NUMBER
   ,c_ev       NUMBER
  ) RETURN NUMBER AS
    kbm_str_old VARCHAR2(2);
    kbm_str_new VARCHAR2(2);
    kmd_id_new  NUMBER;
  BEGIN
  
    SELECT bm.CLASS INTO kbm_str_old FROM T_BONUS_MALUS bm WHERE bm.t_bonus_malus_id = kbm_old_id;
  
    kbm_str_new := kbm_prolongation_str(kbm_str_old, c_ev);
    SELECT bm.t_bonus_malus_id INTO kmd_id_new FROM T_BONUS_MALUS bm WHERE bm.CLASS = kbm_str_new;
    RETURN kmd_id_new;
  END kbm_prolongation_id;

  FUNCTION customer_is(p_ph_id IN NUMBER) RETURN NUMBER AS
    v_cust     NUMBER;
    v_cust_yes NUMBER;
  BEGIN
  
    SELECT pc.contact_id
      INTO v_cust
      FROM P_POL_HEADER ph
      JOIN P_POLICY pp
        ON pp.pol_header_id = ph.policy_header_id
       AND pp.version_num = 1
      JOIN P_POLICY_CONTACT pc
        ON pc.policy_id = pp.policy_id
      JOIN T_CONTACT_POL_ROLE r
        ON r.ID = pc.contact_policy_role_id
     WHERE r.brief = 'Страхователь'
       AND ph.policy_header_id = p_ph_id;
  
    SELECT COUNT(avd.as_vehicle_driver_id)
      INTO v_cust_yes
      FROM P_POL_HEADER ph
      JOIN P_POLICY pp
        ON pp.pol_header_id = ph.policy_header_id
       AND pp.version_num = 1
      JOIN AS_ASSET ass
        ON ass.p_policy_id = pp.policy_id
      JOIN AS_VEHICLE_DRIVER avd
        ON avd.as_vehicle_id = ass.as_asset_id
     WHERE avd.cn_person_id = v_cust
       AND ph.policy_header_id = p_ph_id;
  
    RETURN v_cust_yes;
  
  END customer_is;

  FUNCTION owner_is(p_ph_id IN NUMBER) RETURN NUMBER AS
    v_own     NUMBER;
    v_own_yes NUMBER;
  BEGIN
  
    SELECT ass.contact_id
      INTO v_own
      FROM P_POL_HEADER ph
      JOIN P_POLICY pp
        ON pp.pol_header_id = ph.policy_header_id
       AND pp.version_num = 1
      JOIN AS_ASSET ass
        ON ass.p_policy_id = pp.policy_id
     WHERE ph.policy_header_id = p_ph_id;
  
    SELECT COUNT(avd.as_vehicle_driver_id)
      INTO v_own_yes
      FROM P_POL_HEADER ph
      JOIN P_POLICY pp
        ON pp.pol_header_id = ph.policy_header_id
       AND pp.version_num = 1
      JOIN AS_ASSET ass
        ON ass.p_policy_id = pp.policy_id
      JOIN AS_VEHICLE_DRIVER avd
        ON avd.as_vehicle_id = ass.as_asset_id
     WHERE avd.cn_person_id = v_own
       AND ph.policy_header_id = p_ph_id;
  
    RETURN v_own_yes;
  END owner_is;

  -- ID Страхователя ТС
  FUNCTION customer_id(p_ph_id IN NUMBER) RETURN NUMBER AS
    p_customer_id NUMBER;
  BEGIN
    SELECT pc.contact_id
      INTO p_customer_id
      FROM ven_p_pol_header ph
      JOIN ven_p_policy pp
        ON (pp.pol_header_id = ph.policy_header_id AND pp.version_num = 1)
      JOIN ven_as_vehicle av
        ON av.p_policy_id = pp.policy_id
      JOIN ven_as_asset ass
        ON (ass.p_policy_id = pp.policy_id AND ass.as_asset_id = av.as_vehicle_id)
      JOIN ven_p_policy_contact pc
        ON (pc.policy_id = pp.policy_id)
      JOIN ven_t_contact_pol_role tpr
        ON (pc.contact_policy_role_id = tpr.ID AND tpr.brief = 'Страхователь')
     WHERE ph.policy_header_id = p_ph_id;
    RETURN p_customer_id;
  END customer_id;

  -- ID Собственника ТС
  FUNCTION owner_id(p_ph_id IN NUMBER) RETURN NUMBER AS
    p_owner_id NUMBER;
  BEGIN
    SELECT ass.contact_id
      INTO p_owner_id
      FROM ven_p_pol_header ph
      JOIN ven_p_policy pp
        ON (pp.pol_header_id = ph.policy_header_id AND pp.version_num = 1)
      JOIN ven_as_vehicle av
        ON av.p_policy_id = pp.policy_id
      JOIN ven_as_asset ass
        ON (ass.p_policy_id = pp.policy_id AND ass.as_asset_id = av.as_vehicle_id AND
           ass.contact_id = av.contact_id)
     WHERE ph.policy_header_id = p_ph_id;
    RETURN p_owner_id;
  END owner_id;

  -- Класс, присвоееный собственнику ТС
  FUNCTION owner_klass(p_ph_id IN NUMBER) RETURN VARCHAR2 AS
    p_owner_klass VARCHAR2(10);
  BEGIN
    SELECT DR_KLASS
      INTO p_owner_klass
      FROM (SELECT DECODE(UPPER(bm.CLASS), 'M', ' M', 'М', ' M', TO_CHAR(bm.CLASS, '00')) DR_KLASS
                  ,DECODE(UPPER(bm.CLASS), 'M', -1, 'М', -1, bm.CLASS) sort_klass
              FROM ven_p_pol_header ph
              JOIN ven_p_policy pp
                ON (pp.pol_header_id = ph.policy_header_id AND pp.version_num = 1)
              JOIN ven_as_vehicle av
                ON av.p_policy_id = pp.policy_id
              JOIN VEN_AS_VEHICLE_DRIVER avd
                ON avd.as_vehicle_id = av.as_vehicle_id
              JOIN VEN_CN_PERSON cp
                ON avd.cn_person_id = cp.contact_id
              JOIN ven_contact con
                ON cp.contact_id = con.contact_id
              JOIN ven_t_gender tg
                ON cp.gender = tg.ID
              LEFT JOIN VEN_T_BONUS_MALUS bm
                ON avd.t_bonus_malus_id = bm.t_bonus_malus_id
              LEFT JOIN (SELECT ci.*
                          FROM ven_cn_contact_ident ci
                          JOIN ven_t_id_type it
                            ON it.ID = ci.id_type
                           AND it.brief = 'VOD_UDOS') dc
                ON dc.contact_id = cp.contact_id
             WHERE ph.policy_header_id = p_ph_id --64728,64593,55823
             ORDER BY sort_klass ASC)
     WHERE ROWNUM = 1;
    RETURN p_owner_klass;
  END owner_klass;

  FUNCTION rnp_policy
  (
    p_pol IN NUMBER
   ,p_dt  DATE
  ) RETURN NUMBER AS
    res      NUMBER;
    v_policy P_POLICY%ROWTYPE;
    d_all    NUMBER;
    d_end    NUMBER;
    ag       NUMBER;
  BEGIN
    SELECT * INTO v_policy FROM P_POLICY pp WHERE pp.policy_id = p_pol;
  
    ag := 0;
    FOR c IN (SELECT ppa.part_agent
                    ,ppas.val_com
                FROM P_POLICY_AGENT ppa
                JOIN AG_CONTRACT_HEADER ch
                  ON ch.ag_contract_header_id = ppa.ag_contract_header_id
                JOIN POLICY_AGENT_STATUS pas
                  ON pas.policy_agent_status_id = ppa.status_id
                JOIN P_POLICY_AGENT_COM ppas
                  ON ppas.p_policy_agent_id = ppa.p_policy_agent_id
                JOIN T_PRODUCT_LINE pl
                  ON ppas.t_product_line_id = pl.ID
               WHERE pl.description = 'ОСАГО'
                 AND pas.brief NOT IN ('NEW')
                 AND ppa.date_start <= p_dt
                 AND ppa.date_end > p_dt
                 AND ppa.policy_header_id = v_policy.pol_header_id)
    LOOP
      ag := ag + v_policy.premium * c.part_agent * c.val_com / 10000;
    END LOOP;
    IF ((v_policy.end_date <= p_dt) OR Doc.get_doc_status_brief(p_pol, p_dt) != 'CURRENT' OR
       Doc.get_doc_status_brief(p_pol, p_dt) IS NULL)
    THEN
      res := 0;
    ELSE
      d_all := 0;
      d_end := 0;
      FOR cur IN (SELECT asp.start_date
                        ,asp.end_date
                    FROM AS_ASSET ass
                    JOIN AS_ASSET_PER asp
                      ON asp.as_asset_id = ass.as_asset_id
                   WHERE ass.p_policy_id = p_pol
                   ORDER BY asp.start_date)
      LOOP
        DBMS_OUTPUT.PUT_LINE(cur.start_date);
        DBMS_OUTPUT.PUT_LINE(cur.end_date);
        d_all := ROUND(d_all + cur.end_date - cur.start_date);
        IF (p_dt >= cur.start_date AND p_dt <= cur.end_date)
        THEN
          d_end := d_end + p_dt - cur.start_date;
        ELSIF (p_dt > cur.end_date)
        THEN
          d_end := d_end + cur.end_date - cur.start_date;
        ELSE
          NULL;
        END IF;
      END LOOP;
      DBMS_OUTPUT.PUT_LINE(d_end);
      DBMS_OUTPUT.PUT_LINE(d_all);
      DBMS_OUTPUT.PUT_LINE(v_policy.premium);
      DBMS_OUTPUT.PUT_LINE(ag);
      DBMS_OUTPUT.PUT_LINE(d_all - d_end);
      DBMS_OUTPUT.PUT_LINE(0.97 * (v_policy.premium - ag));
      res := ROUND((d_all - d_end) * (0.97 * (v_policy.premium - ag)) / d_all, 2);
    END IF;
    RETURN res;
  END rnp_policy;

  FUNCTION rzu_policy
  (
    p_pol IN NUMBER
   ,p_dt  DATE
  ) RETURN NUMBER AS
    res      NUMBER;
    v_policy P_POLICY%ROWTYPE;
  BEGIN
    SELECT * INTO v_policy FROM P_POLICY pp WHERE pp.policy_id = p_pol;
  
    RETURN res;
  END rzu_policy;

  FUNCTION rzu_claim
  (
    p_ch IN NUMBER
   ,p_dt DATE
  ) RETURN NUMBER AS
    res NUMBER;
  BEGIN
  
    SELECT DECODE(ccs.brief, 'ЗАКРЫТО', 0, cc.payment_sum * 1.03)
      INTO res
      FROM C_CLAIM_HEADER ch
      JOIN P_POLICY pp
        ON pp.policy_id = ch.p_policy_id
      JOIN P_POL_HEADER ph
        ON ph.policy_header_id = pp.pol_header_id
      JOIN T_PRODUCT pr
        ON pr.product_id = ph.product_id
      JOIN C_CLAIM cc
        ON cc.c_claim_header_id = ch.c_claim_header_id
      JOIN C_CLAIM_STATUS ccs
        ON ccs.c_claim_status_id = cc.claim_status_id
     WHERE ch.c_claim_header_id = p_ch
       AND pr.brief = 'ОСАГО'
       AND cc.seqno = (SELECT MAX(cc1.seqno)
                         FROM C_CLAIM cc1
                        WHERE cc1.c_claim_header_id = cc.c_claim_header_id
                          AND cc1.claim_status_date <= p_dt);
  
    RETURN res;
  END rzu_claim;

  FUNCTION policy_kod(p_p IN NUMBER) RETURN VARCHAR AS
    res VARCHAR2(35);
    x1  VARCHAR2(1);
    x2  VARCHAR2(1);
    x3  VARCHAR2(1);
    x4  VARCHAR2(2);
    x5  VARCHAR2(1);
    x6  VARCHAR2(1);
    x7  VARCHAR2(1);
    x8  VARCHAR2(1);
    x9  VARCHAR2(1);
    x10 VARCHAR2(1);
    x11 VARCHAR2(1);
    x12 VARCHAR2(5);
    x13 VARCHAR2(5);
    x14 VARCHAR2(2);
    x15 VARCHAR2(1);
    x16 VARCHAR2(1);
    x17 VARCHAR2(2);
    x18 VARCHAR2(2);
    x19 VARCHAR2(1);
  BEGIN
    SELECT 1
          , -- x1
           1
          , -- x2
           CASE
             WHEN (TO_NUMBER(TO_CHAR(ph.start_date, 'YYYY')) - av.model_year) <= 3 THEN
              '1'
             WHEN (TO_NUMBER(TO_CHAR(ph.start_date, 'YYYY')) - av.model_year) <= 5 THEN
              '2'
             WHEN (TO_NUMBER(TO_CHAR(ph.start_date, 'YYYY')) - av.model_year) <= 7 THEN
              '3'
             WHEN (TO_NUMBER(TO_CHAR(ph.start_date, 'YYYY')) - av.model_year) <= 10 THEN
              '4'
             WHEN (TO_NUMBER(TO_CHAR(ph.start_date, 'YYYY')) - av.model_year) <= 15 THEN
              '5'
             ELSE
              '6'
           END
          , --x3
           CASE
             WHEN av.power_hp <= 20 THEN
              '01'
             WHEN av.power_hp <= 35 THEN
              '02'
             WHEN av.power_hp <= 50 THEN
              '03'
             WHEN av.power_hp <= 70 THEN
              '04'
             WHEN av.power_hp <= 95 THEN
              '05'
             WHEN av.power_hp <= 120 THEN
              '06'
             WHEN av.power_hp <= 160 THEN
              '07'
             WHEN av.power_hp <= 200 THEN
              '08'
             WHEN av.power_hp <= 250 THEN
              '09'
             ELSE
              '10'
           END
          , --x4
           CASE
             WHEN vt.brief <> 'TRUCK' THEN
              '0'
             WHEN av.max_weight <= 3500 THEN
              '1'
             WHEN av.max_weight <= 10000 THEN
              '2'
             WHEN av.max_weight <= 20000 THEN
              '3'
             WHEN av.max_weight <= 30000 THEN
              '4'
             WHEN av.max_weight <= 40000 THEN
              '5'
             WHEN av.max_weight <= 50000 THEN
              '6'
             ELSE
              '7'
           END
          , --x5
           CASE
             WHEN vt.brief NOT IN ('BUS', 'TROLLEYBUS', 'TRAM') THEN
              '0'
             WHEN av.passangers <= 20 THEN
              '1'
             ELSE
              '2'
           END
          , --x6
           CASE av.is_foreing_reg
             WHEN 1 THEN
              '2'
             ELSE
              '1'
           END
          , --x7
           CASE vu.brief
             WHEN 'OWN' THEN
              '1'
             WHEN 'LEARN' THEN
              '2'
             WHEN 'BANK' THEN
              '3'
             WHEN 'AVBULANCE' THEN
              '4'
             WHEN 'TAXI' THEN
              '5'
             WHEN 'SPEC' THEN
              '6'
             ELSE
              '7'
           END
          , --x8
           CASE
             WHEN av.is_driver_no_lim = 1 THEN
              '3'
             WHEN vd.col_dr = 1 THEN
              '1'
             ELSE
              '2'
           END
          , --x9
           CASE tp.description
             WHEN '12 месяцев' THEN
              '1'
             WHEN '6 месяцев' THEN
              '8'
             WHEN '5 месяцев' THEN
              '7'
             WHEN '4 месяца' THEN
              '6'
             WHEN '3 месяца' THEN
              '5'
             WHEN '2 месяца' THEN
              '4'
             WHEN 'до 1 месяца' THEN
              '3'
             ELSE
              '2'
           END
          , --x10
           CASE
             WHEN av.is_foreing_reg = 1
                  OR av.is_to_reg = 1 THEN
              '0'
             WHEN osu.description = '6 месяцев' THEN
              '1'
             WHEN osu.description = '7 месяцев' THEN
              '2'
             WHEN osu.description = '8 месяцев' THEN
              '3'
             WHEN osu.description = '9 месяцев' THEN
              '4'
             ELSE
              '5'
           END
          , --x11
           CASE
             WHEN SUBSTR(Fn_Get_Ocatd(cca.adress_id), 2) = '45' THEN
              '45000'
             WHEN SUBSTR(Fn_Get_Ocatd(cca.adress_id), 2) = '40' THEN
              '40000'
             WHEN SUBSTR(Fn_Get_Ocatd(cca.adress_id), 2) = '41' THEN
              '41000'
           END --, --x12
    --case
    --  end --x13
      INTO x1
          ,x2
          ,x3
          ,x4
          ,x5
          ,x6
          ,x7
          ,x8
          ,x9
          ,x10
          ,x11
          ,x12 --,x13,x14,x15,x16,x17,x18,x19
      FROM ven_p_policy pp
      JOIN ven_as_vehicle av
        ON av.p_policy_id = pp.policy_id
      JOIN ven_t_vehicle_type vt
        ON vt.t_vehicle_type_id = av.t_vehicle_type_id
      JOIN ven_t_vehicle_usage vu
        ON vu.t_vehicle_usage_id = av.t_vehicle_usage_id
      JOIN ven_OSAGO_PERIOD_USE osu
        ON osu.osago_period_use_id = av.osago_period_use_id
      JOIN ven_cn_contact_address cca
        ON cca.ID = av.cn_contact_address_id
    --   join ven_cn_address ad on ad.id = cca.adress_id
      JOIN ven_p_pol_header ph
        ON ph.policy_header_id = pp.pol_header_id
      JOIN ven_t_period tp
        ON pp.period_id = tp.ID
      LEFT JOIN (SELECT avd.as_vehicle_id
                       ,COUNT(avd.as_vehicle_driver_id) col_dr
                   FROM ven_as_vehicle_driver avd
                  GROUP BY avd.as_vehicle_id) vd
        ON vd.as_vehicle_id = av.as_vehicle_id
     WHERE pp.policy_id = p_p;
  
    res := x1 || x2 || x3 || x4 || x5 || x6 || x7 || x8 || x9 || x10 || x11 || x12 || x13 || x14 || x15 || x16 || x17 || x18 || x19;
    RETURN res;
  END;

  PROCEDURE get_casco_summ
  (
    p_ph_id       IN NUMBER
   ,p_year_number IN NUMBER
   ,p_asset_id    IN NUMBER
   ,p_s_casco     OUT NUMBER
   ,p_s_do        OUT NUMBER
   ,p_s_otv       OUT NUMBER
   ,p_s_ns        OUT NUMBER
   ,p_pr_casco    OUT NUMBER
   ,p_pr_do       OUT NUMBER
   ,p_pr_otv      OUT NUMBER
   ,p_pr_ns       OUT NUMBER
   ,p_srok_beg    OUT VARCHAR2
   ,p_srok_end    OUT VARCHAR2
  ) AS
    i        NUMBER;
    s_casco  NUMBER;
    s_do     NUMBER;
    s_otv    NUMBER;
    s_ns     NUMBER;
    pr_casco NUMBER;
    pr_do    NUMBER;
    pr_otv   NUMBER;
    pr_ns    NUMBER;
    srok_beg DATE;
    srok_end DATE;
    srok     NUMBER;
  BEGIN
    FOR cur IN (SELECT ROUND(MONTHS_BETWEEN(pp.end_date, pp.start_date) / 12) y
                      ,plo.description
                      ,pc.ins_amount
                      ,pc.premium
                      ,pp.start_date
                      ,pp.end_date
                      ,ass.p_asset_header_id
                  FROM P_POL_HEADER ph
                  JOIN P_POLICY pp
                    ON pp.pol_header_id = ph.policy_header_id
                  JOIN AS_ASSET ass
                    ON ass.p_policy_id = pp.policy_id
                   AND ass.as_asset_id = p_asset_id
                  JOIN P_COVER pc
                    ON pc.as_asset_id = ass.as_asset_id
                  JOIN T_PROD_LINE_OPTION plo
                    ON plo.ID = pc.t_prod_line_option_id
                 WHERE pp.version_num = 1
                   AND ph.policy_header_id = p_ph_id
                
                )
    LOOP
      IF p_year_number <= cur.y
      THEN
        --Год расчета премии не должен превышать время действия договора
        -- for i in 1..cur.y
        --  loop
        srok_beg := ADD_MONTHS(cur.start_date, 12 * (p_year_number - 1));
        IF p_year_number < cur.y
        THEN
          srok_end := ADD_MONTHS(cur.start_date, 12 * p_year_number) - 1;
        ELSE
          srok_end := cur.end_date;
        END IF;
      
        CASE cur.description
          WHEN 'Гражданская ответственность' THEN
            s_otv  := cur.ins_amount;
            pr_otv := cur.premium;
          WHEN 'Несчастные случаи' THEN
            s_ns  := cur.ins_amount;
            pr_ns := cur.premium;
          WHEN 'Автокаско' THEN
            -- Проверка (pkg_asset.get_price_asset = cur.ins_amount при i=1)
            IF p_year_number = 1
            THEN
              s_casco := cur.ins_amount;
            ELSE
              s_casco := Pkg_Asset.get_price_asset(cur.p_asset_header_id, srok_beg);
            END IF;
            -- dbms_output.put_line(s_casco);
            -- dbms_output.put_line(srok_beg);
            -- dbms_output.put_line(srok_end);
            -- dbms_output.put_line(MONTHS_BETWEEN(srok_beg,srok_end));
            pr_casco := cur.premium;
            FOR i IN 2 .. p_year_number
            LOOP
              pr_casco := ROUND(pr_casco * 0.94, 2);
            
              IF i = p_year_number
              THEN
                SELECT NVL(pc.val, CEIL(MONTHS_BETWEEN(srok_end, srok_beg) / 12))
                  INTO srok
                  FROM T_PROD_COEF_TYPE pct
                  JOIN T_PROD_COEF pc
                    ON pc.t_prod_coef_type_id = pct.t_prod_coef_type_id
                 WHERE pct.brief = 'DURATION'
                   AND pc.criteria_1 = CEIL(MONTHS_BETWEEN(srok_end, srok_beg));
                pr_casco := ROUND(pr_casco * srok, 2);
              END IF;
              --   dbms_output.put_line(pr_casco);
            END LOOP;
          
          WHEN 'Дополнительное оборудование' THEN
          
            s_do  := cur.ins_amount;
            pr_do := cur.premium;
            FOR i IN 2 .. p_year_number
            LOOP
              s_do  := ROUND(s_do * 0.8, 2);
              pr_do := ROUND(pr_do * 0.94, 2);
              IF i = p_year_number
              THEN
                SELECT NVL(pc.val, CEIL(MONTHS_BETWEEN(srok_end, srok_beg) / 12))
                  INTO srok
                  FROM T_PROD_COEF_TYPE pct
                  JOIN T_PROD_COEF pc
                    ON pc.t_prod_coef_type_id = pct.t_prod_coef_type_id
                 WHERE pct.brief = 'DURATION'
                   AND pc.criteria_1 = CEIL(MONTHS_BETWEEN(srok_end, srok_beg));
                pr_do := ROUND(pr_do * srok, 2);
              END IF;
            END LOOP;
        END CASE;
        --  end loop;
      END IF;
    END LOOP;
    -- Кущенко. Убрал Pkg_Rep_Utils.to_money(
    p_s_casco  := NVL(s_casco, 0);
    p_s_do     := NVL(s_do, 0);
    p_s_otv    := NVL(s_otv, 0);
    p_s_ns     := NVL(s_ns, 0);
    p_pr_casco := NVL(pr_casco, 0);
    p_pr_do    := NVL(pr_do, 0);
    p_pr_otv   := NVL(pr_otv, 0);
    p_pr_ns    := NVL(pr_ns, 0);
    p_srok_beg := TO_CHAR(srok_beg, 'dd.mm.yyyy');
    p_srok_end := TO_CHAR(srok_end, 'dd.mm.yyyy');
  
  END;

END Pkg_Osago;
/

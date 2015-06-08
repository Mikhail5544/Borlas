CREATE OR REPLACE PACKAGE reserve.pkg_reserve_r_life IS
  /**
  * Расчет резервов по страхованию жизни
  * @author Ivanov D.
  * @version Reserve For Life 1.1
  * @since 1.1
  */

  -- В комментариях введено понятие регистра резерва. Регистром резерва
  -- здесь называется отношение договор страхования жизни (далее полис)-
  -- вариант страхования - застрахованный. Абстракцией регистра резерва
  -- является запись в таблице r_reserve_ross.

  pkg_name CONSTANT VARCHAR2(20) := 'pkg_reserve';

  TYPE my_cursor_type IS REF CURSOR RETURN r_reserve%ROWTYPE;

  /**
  * Застрахованный
  */
  TYPE who_is IS RECORD(
     sex        NUMBER
    , -- пол, мужской 1, женский 0
    age        NUMBER
    , -- страховой возраст
    death_date DATE -- дата смерти
    );

  /**
  * значение таблицы смертности
  */
  TYPE mortality_value_type IS RECORD(
     number_lives      NUMBER
    , -- число доживших
    number_died       NUMBER
    , -- число умерающих
    death_portability NUMBER); -- вероятность умереть

  /**
  * Значения из первичного учета, необходимые для расчета резервов.
  * <br> Значения по регистру резерва, являющиеся функциями от номера
  * <br> текущего страхового года.
  * <br> Т.е историчные значения
  */
  TYPE hist_values_type IS RECORD(
     policy_number     VARCHAR2(100)
    ,fact_yield_rate   NUMBER
    , -- фактическая норма доходности (атрибут полиса)
    is_periodical     NUMBER
    , -- взнос периодичный или единовременный
    periodicity       NUMBER
    , -- периодичность (1,2,4,12) (атрибут полиса)
    payment_duration  NUMBER
    , -- срок оплаты взносов  (атрибут полиса)
    start_date        DATE
    , -- дата начала ответственности (атрибут полиса)
    end_date          DATE
    , -- дата окончания ответсвенности (атрибут варианта страхования)
    payment           NUMBER
    , -- размер взноса (атрибут варианта страхования)
    insurance_amount  NUMBER
    , -- страховая сумма (атрибут варианта страхования)
    b                 NUMBER
    , -- коэффициент на договоре
    rent_periodicity  NUMBER
    , -- периодичность выплаты ренты
    rent_payment      NUMBER
    , -- размер одной выплаты ренты
    rent_duration     NUMBER
    , -- срок выплаты ренты
    rent_start_date   DATE
    , -- дата начала выплаты ренты
    has_additional    NUMBER
    , -- имеется ли дополнительный вариант страхования
    payment_base      NUMBER
    , -- сумма взносов по вариантам страхования в договоре за исключением данного
    k_coef            NUMBER
    ,s_coef            NUMBER
    ,rvb_value         NUMBER
    ,g                 NUMBER
    ,p                 NUMBER
    ,g_re              NUMBER
    ,p_re              NUMBER
    ,k_coef_re         NUMBER
    ,s_coef_re         NUMBER
    ,deathrate_id      NUMBER
    ,age               NUMBER
    ,sex               NUMBER
    ,death_date        DATE
    ,t_product_line_id NUMBER
    ,policy_id         NUMBER
    ,ins_premium       NUMBER);

  /**
  * Значение резерва
  */

  TYPE reserve_value_type IS RECORD(
     reserve_id            NUMBER
    ,insurance_year_date   DATE
    ,insurance_year_number NUMBER
    ,par_plan              NUMBER
    ,par_fact              NUMBER);

  /**
  * Фиксировать ошибку в журнале ошибок.
  * @param par_pkg_name пакет
  * @param par_func_name имя функции или процедуры где вызвана error
  * @param par_description описание ошибки
  */
  PROCEDURE error
  (
    par_pkg_name    VARCHAR2
   ,par_func_name   VARCHAR2
   ,par_description VARCHAR2
  );

  /**
  * Получить значение таблицы смертности для застрахованного
  * @param par_sex пол застрахованного
  * @param par_age возраст застрахованного
  * @return запись типа mortality_value_type
  */
  FUNCTION get_mortality_value
  (
    par_sex IN NUMBER
   ,par_age IN NUMBER
  ) RETURN mortality_value_type;

  /**
  * Получить значение таблицы смертности для застрахованного
  * @param par_insured ключ таблицы смертности
  * @return запись типа mortality_value_type
  */
  FUNCTION get_mortality_value(par_values pkg_reserve_r_life.hist_values_type)
    RETURN mortality_value_type;

  /**
  * Получить вероятность смерти застрахованного в течение года
  * @param par_sex пол застрахованного
  * @param par_age возраст застрахованного
  * @return значение вероятности смерти застрахованного в течение года
  */
  FUNCTION get_death_portability
  (
    par_sex IN NUMBER
   ,par_age IN NUMBER
  ) RETURN NUMBER;

  /**
  * Получить вероятность смерти застрахованного в течение следующих
  * <br> k лет
  * @param par_sex пол застрахованного
  * @param par_age возраст застрахованного
  * @param par_k количество лет, в течение которых возможна смерть.
  * <br> количество лет может быть дробной величиной
  * @return значение вероятности того, что застрахованный умрет в течение к лет
  */
  FUNCTION get_death_portability
  (
    par_sex IN NUMBER
   ,par_age IN NUMBER
   ,par_k   NUMBER
  ) RETURN NUMBER;

  /**
  * Вероятность того, что застрахованный начального возраста par_age умрет
  * <br> в течение par_k лет или станет инвалидом 1-ой или 2-ой группы
  * <br> в течение того же промежутка времени. Вероятность НС.
  * @param par_sex пол застрахованного
  * @param par_age возраст застрахованного
  * @param par_k количество лет .
  * <br> количество лет может быть дробной величиной
  * @return значение вероятности НС в течение следующих par_k лет
  */
  FUNCTION get_accident_portability
  (
    par_sex IN NUMBER
   ,par_age IN NUMBER
   ,par_k   NUMBER
  ) RETURN NUMBER;

  /**
  * Получить значение плановой нормы доходности
  * @param par_calc_date
  * @return значение плановой нормы доходности, действующей на
  * <br> дату par_calc_date
  */
  FUNCTION get_plan_yield_rate(par_calc_date DATE) RETURN NUMBER;

  /**
  * Получить значение фактической нормы доходности.
  * <br> Результатом является среднее арифметическое по периодам
  * <br> действия фактической нормы доходности, содержащихся в заданном периоде.
  * <br> Используется для получения средней фактической нормы
  * <br> доходности для страхового года.
  * @param par_begin_date дата начала периода
  * @param par_end_date дата окончания периода
  * @return значение среднеарифметической фактической нормы доходности
  */
  FUNCTION get_fact_yield_rate
  (
    par_begin_date DATE
   ,par_end_date   DATE
  ) RETURN NUMBER;

  /**
  * Получить значение коэффициента B
  * @param par_insurance_duration период оплаты взносов
  * @return значение коэффициента В
  */
  FUNCTION get_b(par_insurance_duration t_b.insurance_duration%TYPE) RETURN t_b.value%TYPE;

  /**
  * Получить значение вероятности инвалидности по возрасту застрахованного
  * <br >из таблицы сил инвалидности.
  * @param par_age возраст застрахованного
  * @return Вероятность стать инвалидом в возрасте age
  */
  FUNCTION get_u(par_age t_u.age%TYPE) RETURN t_u.portability%TYPE;

  /**
  * Доля всей комиссии, полученной агентом
  * par_t номер страхового года
  */
  FUNCTION get_kom(par_t t_b.insurance_duration%TYPE) RETURN t_b.commission_part%TYPE;

  /**
  * Функция получения значения резерва на дату расчета методом линейной интерполяции
  * <br> по известным значениям на концах периода, в котором лежит дата расчета.
  * @param par_date_begin дата начала периода
  * @param par_date_end дата конца периода
  * @param par_value_for_begin значение на дату начала периода
  * @param par_value_for_end значение на дату конца периода
  * @param par_cal_date дата расчета
  * @return значение на дату расчета, полученное методом линейной интерполяции
  */
  FUNCTION line_interpolation
  (
    par_date_begin      IN r_reserve_value.insurance_year_date%TYPE
   ,par_date_end        IN r_reserve_value.insurance_year_date%TYPE
   ,par_value_for_begin IN r_reserve_value.fact%TYPE
   ,par_value_for_end   IN r_reserve_value.plan%TYPE
   ,par_calc_date       IN DATE
  ) RETURN r_reserve_value.plan%TYPE;

  /**
  * Функция получения номера страхового года по дате начала ответственности
  * <br> и дате расчета
  * @param par_start_date
  * @param par_cal_date
  * @return номер страхового года на дату расчета
  */
  FUNCTION get_insurance_year_number
  (
    par_start_date DATE
   ,par_calc_date  DATE
  ) RETURN NUMBER;

  /**
  * Получить историчные значения по регистру резерва на дату
  * Функция зависит от БД
  * @param par_reserve полис - вариант страхования - застрахованный
  * @param par_date дата, на которую необходимо получить историчные значения
  * @return историчные значения типа hist_values_type
  */
  FUNCTION get_history_values
  (
    p_reserve   r_reserve%ROWTYPE
   ,p_calc_date DATE
  ) RETURN pkg_reserve_r_life.hist_values_type;

  /**
  * Получить дату начала ответственности по регистру резерва
  * @param par_reserve полис - вариант страхования - застрахованный
  * @return дата начала ответственности
  */
  FUNCTION get_start_date(par_reserve r_reserve%ROWTYPE) RETURN DATE;

  /**
  * Процедура добавляет записи в r_reserve_ross для неучтенных регистров
  * резерва.
  * Процедура зависит от БД
  */
  PROCEDURE check_new_regisry;

  /**
  * Открывает курсор со всеми резервами по полису.
  * <br> При этом проверят полноту таблицы r_reserve_ross.
  * <br> Если при вызове функции не оказалось записей в таблице r_reserve_ross
  * <br> то, записи создаются для всех недостающих застрахованных
  * <br> и вариантов страхования.
  * @param par_policy_id ид полиса
  * @param par_reserve_cursor курсор по регистрам резерва по полису
  */
  PROCEDURE open_reserve_cursor
  (
    par_policy_id      IN NUMBER
   ,par_reserve_cursor IN OUT my_cursor_type
  );

  /**
  * Процедура расчета резервов (выкупных сумм) по полису.
  * Может быть вызвана, когда полис только создался.
  * @param par_policy_id ИД полиса, по которому считаем резервы
  * @param par_calc_date дата расчета
  */
  PROCEDURE calc_reserve_for_policy
  (
    par_policy_id IN NUMBER
   ,par_calc_date IN DATE DEFAULT NULL
  );
  /**
  * Процедура удаления резервов по полису.
  * Может быть вызвана, когда полис только создался.
  * @param par_policy_id ИД полиса, по которому считаем резервы
  * @param par_calc_date дата расчета
  */
  PROCEDURE drop_reserve_for_policy(par_policy_id IN NUMBER);

  /**
  * Найти значение резерва по ключу
  * @param par_reserve_id ид регистра резерва, по которому нужно записть значение
  * @param par_insurance_year_date дата начала страхового года
  * @param par_insurance_year_number номер страхового года
  * @return строка таблицы r_reserve_value_ross
  */
  FUNCTION get_reserve_value
  (
    par_reserve_id          IN NUMBER
   ,par_insurance_year_date DATE
  ) RETURN r_reserve_value%ROWTYPE;

  /**
  * Записать значение резерва по регистру.
  * <p> Пытается найти значение резерва. Если не найдено, то добавляет
  * <br> новую запись. Если найдено, то делает апдейт.
  * @param par_reserve_value запись таблицы r_reserve_value_ross
  */
  PROCEDURE add_reserve_value(par_reserve_value IN r_reserve_value%ROWTYPE);

  /**
  * Функция расчета значений резерва на страховую годовщину
  * <br> на дату начала и дату окочания страхового года с номером par_t.
  * <p> Если значение на дату начала неизвестна рекурсивно
  * <br> вызывает расчет для номера страхового года par_t-1.
  * <br> Рекурсия заканчивается, когда найдено значение
  * <br> резерва на дату начала страхового года, либо если
  * <br> произведен расчет на дату начала первого страхового
  * <br> года. Расчет значения на дату начала первого страхового
  * <br> года производится при помощи фукнкции calc_reserve_for_iv.
  * <p> Если неизвестно значение резерва на дату окончания
  * <br> страхового года с номером par_t, то оно рассчитывается
  * <br> при помощи функции calc_reserve_for_iv.
  * @param par_registry регистр резерва
  * @param par_t номер страхового года, для которого производится расчет
  * @return значение резерва на конец страхового года
  */
  PROCEDURE calc_reserve_anniversary
  (
    par_registry IN reserve.r_reserve%ROWTYPE
   ,p_i          IN NUMBER
   ,p_t          IN OUT NUMBER
   ,p_start_date IN DATE
   ,p_end_date   IN DATE
  );

  /**
  * Функция расчета значения резерва по регистру
  * <br> резерва на произвольную дату.
  * @param par_registry регистр резерва, по которому проводится расчет
  */
  PROCEDURE calc_reserve_for_registry(par_registry IN r_reserve%ROWTYPE);

  /**
  * Процедура расчета резервов по компании. Расчет производится на дату по
  * выбранным вариантам страхования.
  * @param par_calc_reserve Запись таблицы r_calc_reserve_ross. Это запись
  * вида ИД, Номер расчета, Дата расчета. Расчет производится по всем вариантам
  * которые являются параметрами данного расчета. Т.е из на основании записей таблицы
  * r_calc_results_ross, которые ссылаются на данный расчет (par_calc_reserve).
  * После проведения расчетов записи в таблице r_calc_results_ross заменяются
  * на результаты расчета по этим вариантам страхования. Для хранения проме
  * жуточных результатов используется таблица r_calc_results_temp.
  * Регистры резервов, которые участвуют в расчете получаются на основании пересения
  * выбранных в качестве параметров расчета вариантов страхования и
  * действующих договоров страхования жизни из представления v_active_policy_ross
  */
  PROCEDURE calc_reserve_for_company(par_calc_reserve r_calc_reserve%ROWTYPE);

  /**
  * Актуарная функция. Значение равно отношению брутто-взноса к страховой сумме
  * @param par_inv вариант страхования (ИД t_product_line_option)
  * @param par_sex пол застрахованного (1- мужской, 0 - женский)
  * @param par_age страховой возраст застрахованного
  * @param par_start_date дата начала ответственности по варианту страхования
  * @param par_end_date дата окончания ответственности по варианту страхования
  * @param par_periodisity периодичность оплаты взносов (количество платежей в год по полису)
  * @param par_r срок уплаты взносов (по полису)
  * @param par_j норма доходности, указанная на договоре (по полису)
  * @param par_b коэффициент b (по полису)
  * @param par_rent_periodicity периодичность выплаты ренты
  * @param par_rent_payment размер разовой ренты
  * @param par_rent_duration срок выплаты ренты
  * @param par_has_additional имеется дополнительный вариант страхования
  * @param par_payment_base сумма брутто_взносов по остальным вариантам страхования
  * @return брутто-взнос/страховая сумма, либо 0, если
  * при расчете были ошибки
  */
  FUNCTION act_function
  (
    par_inv              IN NUMBER
   ,par_sex              IN NUMBER
   ,par_age              IN NUMBER
   ,par_start_date       IN DATE
   ,par_end_date         IN DATE
   ,par_periodicity      IN NUMBER
   ,par_r                IN NUMBER
   ,par_j                IN NUMBER
   ,par_b                IN NUMBER
   ,par_rent_periodicity IN NUMBER DEFAULT NULL
   ,par_rent_payment     IN NUMBER DEFAULT NULL
   ,par_rent_duration    IN NUMBER DEFAULT NULL
   ,par_has_additional   IN NUMBER DEFAULT 0
   ,par_payment_base     IN NUMBER DEFAULT 0
  ) RETURN NUMBER;

  /**
  * Функция значения балансового резерка на дату
  * @param p_policy_header_id ИД договора страхования
  * @param p_insurance_variant_id ИД страховой программы
  * @param p_contact_id ИД застрахованного
  * @param p_calc_date Дата, на которую расчитывается балансовый резерв
  */
  FUNCTION get_vb
  (
    p_policy_header_id     IN NUMBER
   ,p_policy_id            IN NUMBER
   ,p_insurance_variant_id IN NUMBER
   ,p_p_asset_header_id    IN NUMBER
   ,p_calc_date            IN DATE
  ) RETURN NUMBER;
  FUNCTION get_vb_paid
  (
    p_policy_header_id     IN NUMBER
   ,p_policy_id            IN NUMBER
   ,p_insurance_variant_id IN NUMBER
   ,p_p_asset_header_id    IN NUMBER
   ,p_reserve_date         IN DATE
  ) RETURN NUMBER;
  /**
  * Функция значения нетто резерка на дату
  * @param p_policy_header_id ИД договора страхования
  * @param p_insurance_variant_id ИД страховой программы
  * @param p_contact_id ИД застрахованного
  * @param p_calc_date Дата, на которую расчитывается балансовый резерв
  */
  FUNCTION get_v
  (
    p_policy_header_id     IN NUMBER
   ,p_policy_id            IN NUMBER
   ,p_insurance_variant_id IN NUMBER
   ,p_p_asset_header_id    IN NUMBER
   ,p_calc_date            IN DATE
  ) RETURN NUMBER;

  /**
  * Функция значения нетто на дату
  * @param p_policy_header_id ИД договора страхования
  * @param p_insurance_variant_id ИД страховой программы
  * @param p_contact_id ИД застрахованного
  * @param p_calc_date Дата, на которую расчитывается балансовый резерв
  */
  FUNCTION get_p
  (
    p_policy_header_id     IN NUMBER
   ,p_policy_id            IN NUMBER
   ,p_insurance_variant_id IN NUMBER
   ,p_p_asset_header_id    IN NUMBER
   ,p_calc_date            IN DATE
  ) RETURN NUMBER;
  FUNCTION get_pp
  (
    p_policy_header_id     IN NUMBER
   ,p_policy_id            IN NUMBER
   ,p_insurance_variant_id IN NUMBER
   ,p_p_asset_header_id    IN NUMBER
   ,p_calc_date            IN DATE
  ) RETURN NUMBER;

  /**
  * Функция значения нетто на дату
  * @param p_policy_header_id ИД договора страхования
  * @param p_insurance_variant_id ИД страховой программы
  * @param p_contact_id ИД застрахованного
  * @param p_calc_date Дата, на которую расчитывается балансовый резерв
  */
  FUNCTION get_vs
  (
    p_policy_header_id     IN NUMBER
   ,p_policy_id            IN NUMBER
   ,p_insurance_variant_id IN NUMBER
   ,p_p_asset_header_id    IN NUMBER
   ,p_reserve_date         IN DATE
  ) RETURN NUMBER;
  /**
  * Функция значения страховой суммы на дату
  * @param p_policy_header_id ИД договора страхования
  * @param p_insurance_variant_id ИД страховой программы
  * @param p_contact_id ИД застрахованного
  * @param p_calc_date Дата, на которую расчитывается балансовый резерв
  */
  FUNCTION get_s
  (
    p_policy_header_id     IN NUMBER
   ,p_policy_id            IN NUMBER
   ,p_insurance_variant_id IN NUMBER
   ,p_p_asset_header_id    IN NUMBER
   ,p_calc_date            IN DATE
  ) RETURN NUMBER;
  /**/
  FUNCTION get_pl_s
  (
    p_policy_header_id     IN NUMBER
   ,p_policy_id            IN NUMBER
   ,p_insurance_variant_id IN NUMBER
   ,p_p_asset_header_id    IN NUMBER
   ,p_calc_date            IN DATE
   ,p_pl_id                NUMBER
  ) RETURN NUMBER;
  /**/
  FUNCTION get_pl_vs
  (
    p_policy_header_id     IN NUMBER
   ,p_policy_id            IN NUMBER
   ,p_insurance_variant_id IN NUMBER
   ,p_p_asset_header_id    IN NUMBER
   ,p_reserve_date         IN DATE
   ,p_pl_id                NUMBER
  ) RETURN NUMBER;
  /**/
  FUNCTION get_ss
  (
    p_policy_header_id     IN NUMBER
   ,p_policy_id            IN NUMBER
   ,p_insurance_variant_id IN NUMBER
   ,p_p_asset_header_id    IN NUMBER
   ,p_calc_date            IN DATE
  ) RETURN NUMBER;
END;
/
CREATE OR REPLACE PACKAGE BODY reserve.pkg_reserve_r_life IS
  gc_pkg_name CONSTANT ins.pkg_trace.t_object_name := $$PLSQL_UNIT;

  g_start_date_header DATE;
  /**
  * Фиксировать ошибку в журнале ошибок.
  * @param par_pkg_name пакет
  * @param par_func_name имя функции или процедуры где вызвана error
  * @param par_description описание ошибки
  */
  PROCEDURE error
  (
    par_pkg_name    VARCHAR2
   ,par_func_name   VARCHAR2
   ,par_description VARCHAR2
  ) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    INSERT INTO r_error_journal
      (error_description, error_date, function_call, id)
    VALUES
      (par_description, SYSDATE, par_pkg_name || '.' || par_func_name, 1);
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END;

  /**
  * Получить значение таблицы смертности для застрахованного
  *@param par_sex пол застрахованного
  *@param age возраст застрахованного 
  *@return запись типа mortality_value_type
  */
  FUNCTION get_mortality_value
  (
    par_sex IN NUMBER
   ,par_age IN NUMBER
  ) RETURN mortality_value_type IS
    mortality_value mortality_value_type;
  
    CURSOR c1
    (
      cur_sex NUMBER
     ,cur_age NUMBER
    ) IS
      SELECT mtv.number_lives      AS f1
            ,mtv.number_died       AS f2
            ,mtv.death_portability AS f3
        FROM t_mortality_fast_table mtv
       WHERE mtv.sex = cur_sex
         AND mtv.age = cur_age;
    v_age NUMBER;
  BEGIN
    v_age := par_age;
    IF v_age > 100
    THEN
      v_age := 100;
    END IF;
    FOR rec IN c1(par_sex, v_age)
    LOOP
      mortality_value.number_lives      := rec.f1; -- Lx
      mortality_value.number_died       := rec.f2; -- Dx
      mortality_value.death_portability := rec.f3; -- Qx
    END LOOP;
    RETURN mortality_value;
  END;

  /**
  * Получить значение таблицы смертности для застрахованного
  *@param par_insured ключ таблицы смертности
  *@return запись типа mortality_value_type
  */
  FUNCTION get_mortality_value(par_values pkg_reserve_r_life.hist_values_type)
    RETURN mortality_value_type IS
  BEGIN
    RETURN get_mortality_value(par_values.sex, par_values.age);
  END;

  /** 
  * Получить вероятность смерти застрахованного в течение года
  * @param par_sex пол застрахованного
  * @param par_age возраст застрахованного
  * @return значение вероятности смерти застрахованного в течение года
  */
  FUNCTION get_death_portability
  (
    par_sex IN NUMBER
   ,par_age IN NUMBER
  ) RETURN NUMBER IS
  BEGIN
    RETURN get_mortality_value(par_sex, par_age).death_portability;
  END;

  /**
  * Получить вероятность смерти застрахованного в течение следующих
  * <br> k лет
  * @param par_sex пол застрахованного
  * @param par_age возраст застрахованного
  * @param par_k количество лет, в течение которых возможна смерть
  * <br> количество лет может быть дробной величиной  
  * @return значение вероятности того, что застрахованный умрет в течение к лет
  */
  FUNCTION get_death_portability
  (
    par_sex IN NUMBER
   ,par_age IN NUMBER
   ,par_k   NUMBER
  ) RETURN NUMBER IS
    --    CURSOR c1(cur_sex NUMBER, cur_age NUMBER, cur_last_age NUMBER) IS
    --      SELECT SUM(mtv.death_portability)
    --        FROM t_mortality_fast_table mtv
    --       WHERE mtv.sex = cur_sex
    --         AND mtv.age BETWEEN cur_age AND cur_last_age; 
    res_portability NUMBER;
    v_k_integer     NUMBER; -- целая часть снизу от par_k
    q_t_x           mortality_value_type;
    q_t_x_k         mortality_value_type;
  BEGIN
    IF par_k <= 0
    THEN
      res_portability := 0;
    ELSIF par_k + par_age > 100
    THEN
      res_portability := 1;
    ELSE
      v_k_integer := trunc(par_k, 0);
      IF par_k = v_k_integer
      THEN
        -- Вариант Степанова вместо курсора
        q_t_x           := get_mortality_value(par_sex, par_age);
        q_t_x_k         := get_mortality_value(par_sex, par_age + v_k_integer);
        res_portability := (q_t_x.number_lives - q_t_x_k.number_lives) / q_t_x.number_lives;
        --        OPEN c1(par_sex, par_age, par_age + par_k - 1);
        --        FETCH c1
        --          INTO res_portability;
        --        CLOSE c1;
      ELSE
        -- Вариант Рассказова
        res_portability := 1 - (1 - get_death_portability(par_sex, par_age, v_k_integer)) *
                           (1 - (par_k - v_k_integer) *
                           get_death_portability(par_sex, par_age + v_k_integer));
      END IF;
    END IF;
    RETURN res_portability;
  END;

  /**
  * Вероятность того, что застрахованный начального возраста par_age умрет 
  * <br> в течение par_k лет или станет инвалидом 1-ой или 2-ой группы
  * <br> в течение того же промежутка времени. Т.е. вероятность НС.
  * @param par_sex пол застрахованного
  * @param par_age возраст застрахованного
  * @param par_k количество лет. 
  * <br> количество лет может быть дробной величиной
  * @return значение вероятности НС в течение следующих par_k лет
  */
  FUNCTION get_accident_portability
  (
    par_sex IN NUMBER
   ,par_age IN NUMBER
   ,par_k   NUMBER
  ) RETURN NUMBER IS
    v_k_integer     NUMBER;
    res_portability NUMBER;
    v_i_multi       NUMBER;
    v_u             NUMBER;
    v_q             NUMBER;
  BEGIN
    IF par_k <= 0
    THEN
      res_portability := 0;
    ELSE
      v_k_integer := trunc(par_k, 0);
      IF par_k = v_k_integer
      THEN
        -- для целых значений par_k
        v_i_multi := 1;
        FOR i IN 0 .. par_k - 1
        LOOP
          v_u       := get_u(par_age + i);
          v_q       := get_death_portability(par_sex, par_age + i);
          v_i_multi := v_i_multi * (1 - v_u - v_q + v_u * v_q);
        END LOOP;
        res_portability := 1 - v_i_multi;
      ELSE
        -- для нецелых
        v_u             := get_u(par_age + v_k_integer);
        v_q             := get_death_portability(par_sex, par_age + v_k_integer);
        res_portability := 1 - (1 - get_accident_portability(par_sex, par_age, v_k_integer)) *
                           (1 - (par_k - v_k_integer) * (v_q + v_u - v_q * v_u));
      END IF;
    END IF;
    RETURN res_portability;
  END;

  /**
  * Получить значение плановой нормы доходности
  * @param par_calc_date
  * @return значение плановой нормы доходности, действующей на
  * <br> дату par_calc_date
  */
  FUNCTION get_plan_yield_rate(par_calc_date DATE) RETURN NUMBER IS
    CURSOR c1(cur_calc_date DATE) IS
      SELECT yr1.value
        FROM t_yield_rate yr1
       WHERE yr1.date_change = (SELECT MAX(yr2.date_change)
                                  FROM t_yield_rate yr2
                                 WHERE yr2.date_change <= par_calc_date
                                   AND yr2.flag = yr1.flag)
         AND yr1.flag = 0;
    res_yield_rate NUMBER;
  BEGIN
    OPEN c1(par_calc_date);
    FETCH c1
      INTO res_yield_rate;
    CLOSE c1;
    RETURN res_yield_rate;
  END;

  /**
  * Получить значение фактической нормы доходности.
  * <br> Результатом является среднее арифметическое по периодам
  * <br> действия фактической нормы доходности, содержащихся в заданном периоде.
  * <br> Используется для получения средней фактической нормы
  * <br> доходности для страхового года.
  * @param par_begin_date дата начала периода
  * @param par_end_date дата окончания периода
  * @return значение среднеарифметической фактической нормы доходности
  */
  FUNCTION get_fact_yield_rate
  (
    par_begin_date DATE
   ,par_end_date   DATE
  ) RETURN NUMBER IS
    CURSOR c1
    (
      cur_begin_date DATE
     ,cur_end_date   DATE
    ) IS
      SELECT nvl((SELECT SUM(res) / MONTHS_BETWEEN(cur_end_date, cur_begin_date)
                   FROM ((SELECT MONTHS_BETWEEN(yr.date_change
                                               ,lag(yr.date_change, 1, cur_begin_date)
                                                over(ORDER BY yr.date_change)) * yr.value AS res
                            FROM t_yield_rate yr
                           WHERE yr.date_change >= cur_begin_date
                             AND yr.date_change <= cur_end_date
                             AND yr.flag = 1)
                        
                         UNION ALL
                        
                         (SELECT MONTHS_BETWEEN(cur_end_date, prev_date) * val AS res
                            FROM (SELECT nvl((SELECT yr.value
                                               FROM t_yield_rate yr
                                              WHERE yr.date_change =
                                                    (SELECT MIN(yr1.date_change)
                                                       FROM t_yield_rate yr1
                                                      WHERE yr1.flag = yr.flag
                                                        AND yr1.date_change >= cur_end_date)
                                                AND yr.flag = 1)
                                            ,
                                             -- плановая норма доходности
                                             (SELECT yr1.value
                                                FROM t_yield_rate yr1
                                               WHERE yr1.date_change =
                                                     (SELECT MAX(yr2.date_change)
                                                        FROM t_yield_rate yr2
                                                       WHERE yr2.date_change <= cur_end_date
                                                         AND yr2.flag = yr1.flag)
                                                 AND yr1.flag = 0)) AS val
                                        ,(SELECT yr.date_change
                                            FROM t_yield_rate yr
                                           WHERE yr.date_change =
                                                 (SELECT MAX(yr1.date_change)
                                                    FROM t_yield_rate yr1
                                                   WHERE yr1.flag = yr.flag
                                                     AND yr1.date_change <= cur_end_date
                                                     AND yr1.date_change >= cur_begin_date)
                                             AND yr.flag = 1) AS prev_date
                                    FROM dual))))
                ,(SELECT yr1.value
                   FROM t_yield_rate yr1
                  WHERE yr1.date_change = (SELECT MAX(yr2.date_change)
                                             FROM t_yield_rate yr2
                                            WHERE yr2.date_change <= cur_end_date
                                              AND yr2.flag = yr1.flag)
                    AND yr1.flag = 0)) AS res
        FROM dual;
  
    res_fact_yield_rate NUMBER;
  BEGIN
    OPEN c1(par_begin_date, par_end_date);
    FETCH c1
      INTO res_fact_yield_rate;
    CLOSE c1;
    RETURN res_fact_yield_rate;
  END;

  /**
  * Получить значение коэффициента B
  * @param 
  * @return 
  */
  FUNCTION get_b(par_insurance_duration t_b.insurance_duration%TYPE) RETURN t_b.value%TYPE IS
  
    res_value t_b.value%TYPE;
    CURSOR c1(cur_ins_dur t_b.insurance_duration%TYPE) IS
      SELECT b.value AS v FROM t_b b WHERE b.insurance_duration = cur_ins_dur;
  BEGIN
    OPEN c1(par_insurance_duration);
    LOOP
      FETCH c1
        INTO res_value;
      EXIT WHEN c1%NOTFOUND;
    END LOOP;
    CLOSE c1;
    RETURN nvl(res_value, 0);
  END;

  /**
  * Получить значение вероятности инвалидности по возрасту застрахованного
  * <br >из таблицы сил инвалидности.
  * @param par_age возраст застрахованного
  * @return Вероятность стать инвалидом в возрасте age
  */
  FUNCTION get_u(par_age t_u.age%TYPE) RETURN t_u.portability%TYPE IS
    CURSOR c1(cur_age_of_insured t_u.age%TYPE) IS
      SELECT portability FROM t_u WHERE age = cur_age_of_insured;
    res_value t_u.portability%TYPE;
  BEGIN
    OPEN c1(par_age);
    LOOP
      FETCH c1
        INTO res_value;
      EXIT WHEN c1%NOTFOUND;
    END LOOP;
    CLOSE c1;
    RETURN nvl(res_value, 0);
  END;

  /**
  * Доля всей комиссии, полученной агентом
  * par_t номер страхового года
  */
  FUNCTION get_kom(par_t t_b.insurance_duration%TYPE) RETURN t_b.commission_part%TYPE IS
    res_value t_b.commission_part%TYPE;
    CURSOR c1(cur_ins_dur t_b.insurance_duration%TYPE) IS
      SELECT b.commission_part AS v FROM t_b b WHERE b.insurance_duration = cur_ins_dur;
  BEGIN
    IF par_t >= 5
    THEN
      res_value := 0;
      RETURN res_value;
    ELSE
      OPEN c1(par_t);
      LOOP
        FETCH c1
          INTO res_value;
        EXIT WHEN c1%NOTFOUND;
      END LOOP;
      CLOSE c1;
      RETURN nvl(res_value, 0);
    END IF;
  END;

  /**  
  * Функция получения значения на дату расчета методом линейной интерполяции
  * <br> по известным значениям на концах периода, в котором лежит дата расчета.
  * @param par_date_begin дата начала периода
  * @param par_date_end дата конца периода
  * @param par_value_for_begin значение на дату начала периода
  * @param par_value_for_end значение на дату конца периода
  * @param par_cal_date дата расчета
  * @return значение на дату расчета, полученное методом линейной интерполяции
  */
  FUNCTION line_interpolation
  (
    par_date_begin      IN r_reserve_value.insurance_year_date%TYPE
   ,par_date_end        IN r_reserve_value.insurance_year_date%TYPE
   ,par_value_for_begin IN r_reserve_value.fact%TYPE
   ,par_value_for_end   IN r_reserve_value.plan%TYPE
   ,par_calc_date       IN DATE
  ) RETURN r_reserve_value.plan%TYPE IS
  
  BEGIN
    --DBMS_OUTPUT.PUT_LINE ('line_interpolation '||' par_date_begin '||par_date_begin||' par_date_end '||par_date_end||' par_value_for_begin '||par_value_for_begin||' par_value_for_end '||par_value_for_end||' par_calc_date '||par_calc_date);
    -- если даты равны, то выдаем значение на дату начала или окончания периода
    -- Степанов В.
    IF (par_calc_date < par_date_begin)
    THEN
      RETURN par_value_for_begin;
    ELSE
      IF (par_calc_date > par_date_end)
      THEN
        RETURN par_value_for_end;
      END IF;
    END IF;
    -- 
    IF (par_date_begin = par_date_end)
    THEN
      RETURN nvl(par_value_for_begin, par_value_for_end);
    ELSE
      RETURN(par_value_for_end - par_value_for_begin) * MONTHS_BETWEEN(par_calc_date, par_date_begin) / MONTHS_BETWEEN(par_date_end
                                                                                                                      ,par_date_begin) + par_value_for_begin;
    END IF;
  END;

  /**
  * Функция получения номера страхового года по дате начала ответственности
  * <br> и дате расчета
  * @param par_start_date
  * @param par_cal_date
  * @return номер страхового года на дату расчета
  */
  FUNCTION get_insurance_year_number
  (
    par_start_date DATE
   ,par_calc_date  DATE
  ) RETURN NUMBER IS
    var_year_number NUMBER;
  BEGIN
    -- получим номер страхового года, в который попадает дата расчета
    dbms_output.put_line('par_calc_date ' || par_calc_date || ' par_start_date ' || par_start_date);
    var_year_number := MONTHS_BETWEEN(par_calc_date, par_start_date) / 12;
    var_year_number := trunc(var_year_number, 0);
    IF var_year_number < 0
    THEN
      var_year_number := 0;
    END IF;
    RETURN var_year_number + 1;
  END;

  /**
  * Получить историчные значения по регистру резерва на дату
  * Функция зависит от БД
  * @param par_reserve полис - вариант страхования - застрахованный
  * @param par_date дата, на которую необходимо получить историчные значения
  * @return историчные значения типа PKG_RESERVE_LIFE.hist_values_type
  */
  FUNCTION get_history_values
  (
    p_reserve   r_reserve%ROWTYPE
   ,p_calc_date IN DATE
  ) RETURN pkg_reserve_r_life.hist_values_type IS
  
    CURSOR c_history IS
    
      SELECT a.p_policy_id policy_id
            ,aa.assured_contact_id
        FROM ins.as_asset a
            ,ins.as_assured aa
            ,(SELECT pp.policy_id
                    ,pp.pol_header_id
                    ,pp.version_num
                    ,pp.start_date
                    ,pp_cur.start_date start_date_cur
                    ,nvl((lead(pp.start_date)
                          over(PARTITION BY pp.pol_header_id ORDER BY pp.version_num) - 1)
                        ,trunc(pp.end_date)) end_date
                FROM ins.p_policy       pp_cur
                    ,ins.p_policy       pp
                    ,ins.p_pol_header   ph
                    ,ins.document       d
                    ,ins.doc_status_ref rf
               WHERE 1 = 1
                 AND ph.policy_header_id = p_reserve.pol_header_id
                 AND pp.pol_header_id = ph.policy_header_id
                 AND pp_cur.policy_id = p_reserve.policy_id
                 AND pp.policy_id = d.document_id
                 AND d.doc_status_ref_id = rf.doc_status_ref_id
                 AND rf.brief != 'CANCEL') pp
       WHERE 1 = 1
         AND pp.pol_header_id = p_reserve.pol_header_id
            -- При поиске историчных данных на прошлые даты отбираем полисы по периоду действия. если дата после начала действия рабочей версии полиса
            -- то выбираем данные по этой версии
         AND ((trunc(pp.start_date_cur) > trunc(p_calc_date /*- 1*/) AND
             trunc(p_calc_date /*- 1*/) BETWEEN pp.start_date AND pp.end_date) OR
             (trunc(pp.start_date_cur) <= trunc(p_calc_date /*- 1*/) AND
             pp.policy_id = p_reserve.policy_id))
         AND a.p_asset_header_id = p_reserve.p_asset_header_id
         AND a.p_policy_id = pp.policy_id
         AND aa.as_assured_id = a.as_asset_id;
    --
    r_history c_history%ROWTYPE;
    --
    CURSOR c_current IS
      SELECT a.p_policy_id policy_id
            ,aa.assured_contact_id
        FROM ins.as_asset       a
            ,ins.as_assured     aa
            ,ins.p_policy       pp
            ,ins.document       d
            ,ins.doc_status_ref rf
            ,ins.p_pol_header   ph
       WHERE 1 = 1
         AND ph.policy_header_id = p_reserve.pol_header_id
         AND pp.pol_header_id = ph.policy_header_id
         AND pp.policy_id = p_reserve.policy_id
         AND pp.pol_header_id = p_reserve.pol_header_id
         AND a.p_asset_header_id = p_reserve.p_asset_header_id
         AND a.p_policy_id = pp.policy_id
         AND aa.as_assured_id = a.as_asset_id
         AND pp.policy_id = d.document_id
         AND d.doc_status_ref_id = rf.doc_status_ref_id
         AND rf.brief != 'CANCEL';
    r_current c_current%ROWTYPE;
  
    CURSOR c1
    (
      cur_policy_id       IN NUMBER
     ,cur_contact_id      IN NUMBER
     ,cur_variant_id      IN NUMBER
     ,cur_product_line_id IN NUMBER
     ,cur_calc_date       IN DATE
    ) IS
      SELECT h.policy_number
            ,h.policy_fact_yield_rate
            ,h.is_periodical
            ,h.periodicity
            ,h.payment_duration
            ,h.start_date
            ,h.end_date
            ,h.payment
            ,h.insurance_amount
            ,h.b
            ,h.rent_periodicity
            ,h.rent_payment
            ,h.rent_duration
            ,h.rent_start_date
            ,h.has_additional
            ,h.payment_base
            ,h.k_coef
            ,h.s_coef
            ,h.rvb_value
            ,h.g
            ,h.p
            ,h.g_re
            ,h.p_re
            ,h.k_coef_re
            ,h.s_coef_re
            ,h.deathrate_id
            ,h.age
            ,h.sex
            ,h.death_date
            ,
             --             
             h.t_product_line_id
            ,h.policy_id
            ,h.ins_premium
      --
        FROM v_registry_hist_values h
       WHERE h.policy_id = cur_policy_id
         AND h.insurance_variant_id = cur_variant_id
         AND h.t_product_line_id = cur_product_line_id;
    res_values    pkg_reserve_r_life.hist_values_type;
    p_contact_id  NUMBER;
    v_cnt         NUMBER DEFAULT 0;
    l_new_cover   NUMBER;
    v_open_cursor NUMBER := 0;
  BEGIN
    dbms_output.put_line('Процедура получ. ист. данных. Текущий полис ' || 'policy_id ' ||
                         p_reserve.policy_id || ' на дату ' || ' par_calc_date ' || p_calc_date ||
                         ' cur_p_asset_header_id ' || p_reserve.p_asset_header_id ||
                         ' par_reserve.insurance_variant_id ' || p_reserve.insurance_variant_id);
  
    /* Проверка условий на выход из условий "финансовых каникул"   */
    SELECT COUNT(1) --COUNT(at.brief)
      INTO l_new_cover
      FROM ins.p_policy            pp
          ,ins.p_pol_addendum_type pa
          ,ins.t_addendum_type     at
     WHERE pp.policy_id = p_reserve.policy_id
       AND pa.p_policy_id = pp.policy_id
       AND at.t_addendum_type_id = pa.t_addendum_type_id
       AND at.brief IN ('CLOSE_FIN_WEEKEND', 'CHANGE_STRATEGY_QUARTER', 'INCREASE_SIZE_QUARTER');
  
    OPEN c_history;
    FETCH c_history
      INTO r_history;
  
    IF l_new_cover = 0
       AND c_history%FOUND
    THEN
      dbms_output.put_line('Поиск данных по нужной версии полиса ' || r_history.policy_id ||
                           ' assured_contact_id ' || r_history.assured_contact_id ||
                           ' t_product_line_id ' || p_reserve.t_product_line_id ||
                           ' insurance_variant_id ' || p_reserve.insurance_variant_id ||
                           ' p_calc_date ' || to_char(p_calc_date, 'dd.mm.yyyy hh24:mi:ss'));
      OPEN c1(r_history.policy_id
             ,r_history.assured_contact_id
             ,p_reserve.insurance_variant_id
             ,p_reserve.t_product_line_id
             ,p_calc_date);
      FETCH c1
        INTO res_values;
      IF c1%FOUND
      THEN
        dbms_output.put_line('Историчные данные найдены');
        v_open_cursor := 1;
      END IF;
      CLOSE c1;
      CLOSE c_history;
      /**/
      IF v_open_cursor != 1
      THEN
        OPEN c_current;
        FETCH c_current
          INTO r_current;
        IF c_current%FOUND
        THEN
        
          dbms_output.put_line('Поиск данных по текущей версии полиса ' || r_current.policy_id ||
                               ' assured_contact_id ' || r_current.assured_contact_id ||
                               ' t_product_line_id ' || p_reserve.t_product_line_id ||
                               ' insurance_variant_id ' || p_reserve.insurance_variant_id ||
                               ' p_calc_date ' || to_char(p_calc_date, 'dd.mm.yyyy hh24:mi:ss'));
          OPEN c1(r_current.policy_id
                 ,r_current.assured_contact_id
                 ,p_reserve.insurance_variant_id
                 ,p_reserve.t_product_line_id
                 ,p_calc_date);
          FETCH c1
            INTO res_values;
          IF c1%FOUND
          THEN
            dbms_output.put_line('Оперативные данные найдены');
          END IF;
          CLOSE c1;
        ELSE
          dbms_output.put_line('Оперативные данные не найдены');
        END IF;
        CLOSE c_current;
      END IF;
      /**/
    ELSE
      OPEN c_current;
      FETCH c_current
        INTO r_current;
      IF c_current%FOUND
      THEN
      
        dbms_output.put_line('Поиск данных по текущей версии полиса ' || r_current.policy_id ||
                             ' assured_contact_id ' || r_current.assured_contact_id ||
                             ' t_product_line_id ' || p_reserve.t_product_line_id ||
                             ' insurance_variant_id ' || p_reserve.insurance_variant_id ||
                             ' p_calc_date ' || to_char(p_calc_date, 'dd.mm.yyyy hh24:mi:ss'));
        OPEN c1(r_current.policy_id
               ,r_current.assured_contact_id
               ,p_reserve.insurance_variant_id
               ,p_reserve.t_product_line_id
               ,p_calc_date);
        FETCH c1
          INTO res_values;
        IF c1%FOUND
        THEN
          dbms_output.put_line('Оперативные данные найдены');
        END IF;
        CLOSE c1;
      ELSE
        dbms_output.put_line('Оперативные данные не найдены');
      END IF;
      CLOSE c_current;
    
    END IF;
  
    dbms_output.put_line(' policy_number ' || res_values.policy_number || ' insurance_amount ' ||
                         res_values.insurance_amount);
  
    RETURN res_values;
  
  END;

  /**                            
  * Получить дату начала ответственности по регистру резерва
  * Функция зависит от БД    
  * @param par_reserve полис - вариант страхования - застрахованный                              
  * @return дата начала ответственности
  */
  FUNCTION get_start_date(par_reserve r_reserve%ROWTYPE) RETURN DATE IS
    v_ret_val DATE;
  BEGIN
    SELECT ph.start_date
      INTO v_ret_val
      FROM ins.p_pol_header ph
     WHERE ph.policy_header_id = par_reserve.pol_header_id;
    RETURN v_ret_val;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN SYSDATE;
  END;

  /**
  * Открывает курсор со всеми резервами по полису.
  * <br> При этом проверят полноту таблицы r_reserve.
  * <br> Если при вызове функции не оказалось записей в таблице r_reserve
  * <br> то, записи создаются для всех недостающих застрахованных 
  * <br> и вариантов страхования.
  * @param par_policy_id ид полиса
  * @param par_reserve_cursor курсор по регистрам резерва по полису
  */
  PROCEDURE open_reserve_cursor
  (
    par_policy_id      IN NUMBER
   ,par_reserve_cursor IN OUT my_cursor_type
  ) IS
    -- получить набор данных по полису, которые нужно записать в резервы
    CURSOR new_reserves(cur_policy_id NUMBER) IS
      SELECT vner.policy_header_id
            ,cur_policy_id policy_id
            ,p_asset_header_id
            ,vner.insurance_variant_id
            ,vner.t_product_line_id
            ,vner.p_cover_id
        FROM v_not_exists_registry vner
       WHERE 1 = 1
         AND vner.policy_id = cur_policy_id;
    -- 
  
  BEGIN
    dbms_output.put_line('ENTER open_reserve_cursor par_policy_id' || par_policy_id);
    -- учтем регистры резерва по полису
    FOR rec IN new_reserves(par_policy_id)
    LOOP
      dbms_output.put('Создание новой записи в регистре...par_policy_id = ' || rec.policy_id);
      dbms_output.put(' pol_header_id ' || rec.policy_header_id || ' insurance_variant_id ' ||
                      rec.insurance_variant_id);
      dbms_output.put_line(' p_asset_header_id' || rec.p_asset_header_id || ' t_product_line_id ' ||
                           rec.t_product_line_id);
      INSERT INTO r_reserve
        (id
        ,policy_id
        ,pol_header_id
        ,insurance_variant_id
        ,t_product_line_id
        ,p_asset_header_id
        ,p_cover_id)
      VALUES
        (sq_r_reserve.nextval
        ,rec.policy_id
        ,rec.policy_header_id
        ,rec.insurance_variant_id
        ,rec.t_product_line_id
        ,rec.p_asset_header_id
        ,rec.p_cover_id);
    END LOOP;
  
    -- получим регистры резерва по полису
  
    OPEN par_reserve_cursor FOR
      SELECT rr.id
            ,rr.policy_id
            ,rr.insurance_variant_id
            ,rr.contact_id
            ,rr.pol_header_id
            ,rr.p_asset_header_id
            ,rr.t_product_line_id
            ,rr.p_cover_id
        FROM r_reserve    rr
            ,ins.p_policy pp
       WHERE 1 = 1
         AND pp.policy_id = par_policy_id
         AND rr.policy_id = pp.policy_id
       ORDER BY rr.policy_id
               ,rr.insurance_variant_id;
  
  END;

  /**
  * Получить значение резерва по ключу
  * @param par_reserve_id ид регистра резерва, по которому нужно записть значение
  * @param par_insurance_year_date дата начала страхового года
  * @param par_insurance_year_number номер страхового года  
  * @return строка таблицы r_reserve_value
  */
  FUNCTION get_reserve_value
  (
    par_reserve_id          IN NUMBER
   ,par_insurance_year_date DATE
  )
  --
   RETURN r_reserve_value%ROWTYPE IS
    -- получаем значение резерва по ключу
    CURSOR val
    (
      cur_reserve_id          NUMBER
     ,cur_insurance_year_date DATE
    ) IS
      SELECT *
        FROM r_reserve_value rvr
       WHERE 1 = 1
         AND rvr.insurance_year_date = cur_insurance_year_date
         AND rvr.reserve_id = cur_reserve_id;
  
    res_reserve_value r_reserve_value%ROWTYPE;
  BEGIN
    IF par_reserve_id IS NULL
       OR par_insurance_year_date IS NULL
    THEN
      raise_application_error(-20000
                             ,'reserve.find_reserve_value: ключ не может содержать значения null');
    END IF;
  
    OPEN val(par_reserve_id, par_insurance_year_date);
    FETCH val
      INTO res_reserve_value;
    dbms_output.put_line('Значение на начало года найдено ' || res_reserve_value.s || 'tVZ ' ||
                         res_reserve_value.tvz_p);
    IF val%NOTFOUND
    THEN
      dbms_output.put_line('Значение на начало года не найдено ...par_reserve_id ' || par_reserve_id || ' ' ||
                           to_char(par_insurance_year_date, 'dd.mm.yyyy'));
    END IF;
    CLOSE val;
  
    RETURN res_reserve_value;
  END;

  PROCEDURE add_reserve_value(par_reserve_value IN r_reserve_value%ROWTYPE) IS
  
    find_flag NUMBER(1); -- флаг, показывает, были найдены значения и какие
    -- 0 - не найдено записей для этого года страхования
    -- 1 - найдена запись, требуется update
    -- 2 - найдена запись и значение резерва совпадает - ничего не надо делать
    value_id NUMBER;
  
    reserve_value r_reserve_value%ROWTYPE;
  BEGIN
    dbms_output.put_line('Процесс сохранения рассчитанных значений для года ' ||
                         to_date(par_reserve_value.insurance_year_date, 'dd.mm.yyyy'));
    find_flag := 0; -- не найдено записи по ключу
  
    reserve_value := get_reserve_value(par_reserve_value.reserve_id
                                      ,par_reserve_value.insurance_year_date);
  
    IF reserve_value.id IS NOT NULL
    THEN
      find_flag := 1; --  найдена запись с таким же ключем
      value_id  := reserve_value.id;
    END IF;
  
    IF find_flag = 0
    THEN
      -- не было найдено, добавляем
      dbms_output.put_line('Создаем запись в базовой таблице .... ');
      INSERT INTO reserve.r_reserve_value
        (id
        ,reserve_id
        ,insurance_year_date
        ,insurance_year_number
        ,reserve_date
        ,a_z
        ,plan
        ,fact
        ,c
        ,j
        ,p
        ,g
        ,p_re
        ,g_re
        ,s
        ,tv_p
        ,tv_f
        ,tv_p_re
        ,tv_f_re
        ,tvz_p
        ,tvz_f
        ,tvexp_p
        ,tvexp_f
        ,tvs_p
        ,tvs_f
        ,fee)
      VALUES
        (sq_r_reserve_value.nextval
        ,par_reserve_value.reserve_id
        ,par_reserve_value.insurance_year_date
        ,par_reserve_value.insurance_year_number
        ,par_reserve_value.insurance_year_date - 1
        ,par_reserve_value.a_z
        ,par_reserve_value.plan
        ,par_reserve_value.fact
        ,par_reserve_value.c
        ,par_reserve_value.j
        ,par_reserve_value.p
        ,par_reserve_value.g
        ,par_reserve_value.p_re
        ,par_reserve_value.g_re
        ,par_reserve_value.s
        ,par_reserve_value.tv_p
        ,par_reserve_value.tv_f
        ,par_reserve_value.tv_p_re
        ,par_reserve_value.tv_f_re
        ,par_reserve_value.tvz_p
        ,par_reserve_value.tvz_f
        ,par_reserve_value.tvexp_p
        ,par_reserve_value.tvexp_f
        ,par_reserve_value.tvs_p
        ,par_reserve_value.tvs_f
        ,par_reserve_value.fee);
    ELSIF find_flag = 1
    THEN
      -- было найдено с другими значениями, апдейт
      UPDATE r_reserve_value r
         SET r.plan    = par_reserve_value.plan
            ,r.fact    = par_reserve_value.fact
            ,r.c       = par_reserve_value.c
            ,r.j       = par_reserve_value.j
            ,r.p       = par_reserve_value.p
            ,r.g       = par_reserve_value.g
            ,r.p_re    = par_reserve_value.p_re
            ,r.g_re    = par_reserve_value.g_re
            ,r.s       = par_reserve_value.s
            ,r.tv_p    = par_reserve_value.tv_p
            ,r.tv_f    = par_reserve_value.tv_f
            ,r.tv_p_re = par_reserve_value.tv_p_re
            ,r.tv_f_re = par_reserve_value.tv_f_re
            ,r.tvz_p   = par_reserve_value.tvz_p
            ,r.tvz_f   = par_reserve_value.tvz_f
            ,r.tvexp_p = par_reserve_value.tvexp_p
            ,r.tvexp_f = par_reserve_value.tvexp_f
            ,r.tvs_p   = par_reserve_value.tvs_p
            ,r.tvs_f   = par_reserve_value.tvs_f
            ,r.a_z     = par_reserve_value.a_z
            ,r.fee     = par_reserve_value.fee
       WHERE r.id = value_id;
    END IF;
    /* exception
    when others then
      rollback to sp1; 
      error(pkg_name, 'add_reserve_value', 'Ошибка записи резерва ИД = ' || par_reserve_value.reserve_id);
      raise; */
  END;

  /**
  * Процедура расчета резервов (выкупных сумм) по полису.
  * Может быть вызвана, когда полис только создался.
  * @param par_policy_id ИД полиса, по которому считаем резервы
  * @param par_calc_date дата расчета
  */
  PROCEDURE calc_reserve_for_policy
  (
    par_policy_id IN NUMBER
   ,par_calc_date IN DATE DEFAULT NULL
  ) IS
    -- набор регистров резерва по полису  
    reserve_cursor my_cursor_type;
  
    -- строка курсора
    rec_reserve       r_reserve%ROWTYPE;
    res_reserve_value NUMBER;
    --
    v_policy_end_date       DATE;
    v_reserve_value_for_end r_reserve_value%ROWTYPE;
  
  BEGIN
    -- Получаем регистры резервов по полису, по которым нужно провести расчет.
    open_reserve_cursor(par_policy_id, reserve_cursor);
    IF reserve_cursor%ISOPEN
    THEN
      LOOP
        FETCH reserve_cursor
          INTO rec_reserve;
        EXIT WHEN reserve_cursor%NOTFOUND OR reserve_cursor%NOTFOUND IS NULL;
        -- по варианту страхованя по полису и застрахованному
        dbms_output.put_line('Расчет по варианту страхованя по полису и застрахованному ' ||
                             rec_reserve.policy_id);
        calc_reserve_for_registry(rec_reserve);
      END LOOP;
    ELSE
      dbms_output.put_line('курсор пустой... ');
    END IF;
    --EXCEPTION
    --  WHEN OTHERS THEN
    --    raise_application_error(-20000, 'calc_reserve_for_policy() ' || sqlerrm || 'policy_id = ' || par_policy_id);
  END;

  /**
  * Процедура удаления резервов по полису.
  * Может быть вызвана, когда полис только создался.
  * @param par_policy_id ИД полиса, по которому считаем резервы
  * @param par_calc_date дата расчета
  */
  PROCEDURE drop_reserve_for_policy(par_policy_id IN NUMBER) IS
  BEGIN
    DELETE FROM reserve.r_reserve WHERE policy_id = par_policy_id;
  END;

  /**
    * Функция расчета значений резерва по регистру резерва
    * <br> на дату начала и дату окочаниBegin
  FND_GLOBAL.APPS_INITIALIZE(1163,20678,20005); 
  FND_GLOBAL.set_nls_context(p_nls_language => 'RUSSIAN',
                   p_nls_date_format => null,
                     p_nls_date_language => null,
                     p_nls_numeric_characters => null,
                     p_nls_sort => null,
                     p_nls_territory => null);
  end;
  я страхового года с номером par_t. 
    * <p> Если значение на дату начала неизвестна рекурсивно
    * <br> вызывает расчет для номера страхового года par_t-1.
    * <br> Рекурсия заканчивается, когда найдено значение     
    * <br> резерва на дату начала страхового года, либо если
    * <br> произведен расчет на дату начала первого страхового       
    * <br> года. Расчет значения на дату начала первого страхового
    * <br> года производится при помощи фукнкции calc_reserve_for_iv.
    * <p> Если неизвестно значение резерва на дату окончания 
    * <br> страхового года с номером par_t, то оно рассчитывается
    * <br> при помощи функции calc_reserve_for_iv.
    * @param par_registry регистр резерва
    * @param par_start_date дата начала ответственности по регистру
    * @param par_t номер страхового года, для которого производится расчет
    * @param par_reserve_value_for_begin значение резерва на начало
    * @param par_depth глубина рекурсии  
    * @return значение резерва на конец страхового года  
    */
  PROCEDURE calc_reserve_anniversary
  (
    par_registry IN reserve.r_reserve%ROWTYPE
   ,p_i          IN NUMBER
   ,p_t          IN OUT NUMBER
   ,p_start_date IN DATE
   ,p_end_date   IN DATE
  ) IS
    c_proc_name CONSTANT ins.pkg_trace.t_object_name := 'CALC_RESERVE_ANNIVERSARY';
    v_values                pkg_reserve_r_life.hist_values_type;
    v_hist_date             DATE; -- дата начала страхового года с номером par_t
    v_ins_end_date          DATE; -- дата окончания стрхового года с номером par_t
    v_cur_date              DATE; -- дата окончания текущего стр. года
    v_c                     NUMBER; -- плановая норма доходности
    v_j                     NUMBER; -- фактическая норма доходности    
    v_n                     NUMBER; -- срок страхования
    v_t                     NUMBER; -- срок страхования
    v_b                     NUMBER; -- todo необходимо получить
    v_kom                   NUMBER; -- 
    v_periodical            NUMBER(1);
    v_reserve_value_start   r_reserve_value%ROWTYPE;
    v_reserve_value_end     r_reserve_value%ROWTYPE;
    v_insurance_year_number NUMBER(3);
  
    l_cur_policy_start_date DATE;
    l_version_num           NUMBER;
  
    PROCEDURE trace(par_text VARCHAR2) IS
    BEGIN
      ins.pkg_trace.trace(par_trace_obj_name    => gc_pkg_name
                         ,par_trace_subobj_name => c_proc_name
                         ,par_message           => par_text);
    END trace;
  
    PROCEDURE get_history_reserve IS
      c_local_proc_name CONSTANT ins.pkg_trace.t_object_name := 'GET_HISTORY_RESERVE';
    BEGIN
    
      ins.pkg_trace.add_variable(par_trace_var_name  => c_local_proc_name
                                ,par_trace_var_value => v_hist_date);
      ins.pkg_trace.add_variable(par_trace_var_name  => 'reserve_id'
                                ,par_trace_var_value => par_registry.id);
      ins.pkg_trace.trace_procedure_start(par_trace_obj_name    => gc_pkg_name
                                         ,par_trace_subobj_name => c_local_proc_name);
    
      v_reserve_value_end.reserve_id := par_registry.id;
    
      ins.pkg_trace.trace_procedure_end(par_trace_obj_name    => gc_pkg_name
                                       ,par_trace_subobj_name => c_local_proc_name);
    
    END;
  
    FUNCTION check_history_reserve RETURN NUMBER IS
      c_local_proc_name CONSTANT ins.pkg_trace.t_object_name := 'CHECK_HISTORY_RESERVE';
      l_new_cover NUMBER;
      v_result    NUMBER := 0;
    BEGIN
      ins.pkg_trace.trace_procedure_start(par_trace_obj_name    => gc_pkg_name
                                         ,par_trace_subobj_name => c_local_proc_name);
    
      /* Проверка условий на выход из условий "финансовых каникул"   */
      SELECT COUNT(1) --COUNT(at.brief)
        INTO l_new_cover
        FROM ins.p_policy            pp
            ,ins.p_pol_addendum_type pa
            ,ins.t_addendum_type     at
       WHERE pp.policy_id = par_registry.policy_id
         AND pa.p_policy_id = pp.policy_id
         AND at.t_addendum_type_id = pa.t_addendum_type_id
         AND at.brief IN ('CLOSE_FIN_WEEKEND', 'CHANGE_STRATEGY_QUARTER', 'INCREASE_SIZE_QUARTER');
    
      IF l_new_cover != 1
      THEN
        ins.pkg_trace.add_variable('POL_HEADER_ID', par_registry.pol_header_id);
        ins.pkg_trace.add_variable('l_version_num', l_version_num);
        ins.pkg_trace.add_variable('INSURANCE_VARIANT_ID', par_registry.insurance_variant_id);
        ins.pkg_trace.add_variable('v_hist_date', v_hist_date);
        ins.pkg_trace.trace(gc_pkg_name
                           ,c_local_proc_name
                           ,'Поиск исторических данных');
      
        BEGIN
          SELECT rv.*
            INTO v_reserve_value_end
            FROM reserve.r_reserve_value rv
                ,reserve.r_reserve       rr
                ,ins.p_policy            pp
                ,ins.document            d
                ,ins.doc_status_ref      rf
           WHERE 1 = 1
             AND pp.pol_header_id = par_registry.pol_header_id
             AND pp.version_num =
                 (SELECT MAX(a.version_num)
                    FROM ins.p_policy       a
                        ,ins.document       da
                        ,ins.doc_status_ref rfa
                   WHERE pol_header_id = par_registry.pol_header_id
                     AND a.version_num < l_version_num
                     AND a.policy_id = da.document_id
                     AND da.doc_status_ref_id = rfa.doc_status_ref_id
                     AND rfa.brief != 'CANCEL'
                     AND EXISTS
                   (SELECT 1 FROM reserve.r_reserve rr_1 WHERE rr_1.policy_id = a.policy_id))
             AND rr.policy_id = pp.policy_id
             AND pp.policy_id = d.document_id
             AND d.doc_status_ref_id = rf.doc_status_ref_id
             AND rf.brief != 'CANCEL'
             AND rr.insurance_variant_id = par_registry.insurance_variant_id
             AND trunc(rv.insurance_year_date) = trunc(v_hist_date)
             AND rv.reserve_id = rr.id;
        
          ins.pkg_trace.trace(gc_pkg_name
                             ,c_local_proc_name
                             ,'Исторические данные найдены');
        
          v_result := 1;
        
        EXCEPTION
          WHEN no_data_found THEN
            ins.pkg_trace.trace(gc_pkg_name
                               ,c_local_proc_name
                               ,'Исторические данные не найдены');
            NULL;
          WHEN too_many_rows THEN
            ins.pkg_trace.trace(gc_pkg_name
                               ,c_local_proc_name
                               ,'Исторические данные не найдены');
        END;
      
      END IF;
    
      ins.pkg_trace.trace_function_end(par_trace_obj_name    => gc_pkg_name
                                      ,par_trace_subobj_name => c_local_proc_name
                                      ,par_result_value      => v_result);
    
      RETURN v_result;
    
    EXCEPTION
      WHEN OTHERS THEN
        --dbms_output.put_line('CHECK_HISTORY_RESERVE NOT EXISTS ');
        RETURN 0;
    END check_history_reserve;
  
    PROCEDURE calculate_reserve IS
      c_local_proc_name CONSTANT ins.pkg_trace.t_object_name := 'CHECK_HISTORY_RESERVE';
    BEGIN
      ins.pkg_trace.add_variable('p_t', p_t);
      ins.pkg_trace.add_variable('v_n', v_n);
      ins.pkg_trace.trace_procedure_start(gc_pkg_name, c_local_proc_name);
      -- получить историчные значения по полису и варианту страхования
      -- на конец страхового года
      IF p_t < v_n
      THEN
        ins.pkg_trace.add_variable('v_hist_date', v_hist_date);
        ins.pkg_trace.trace(gc_pkg_name
                           ,c_local_proc_name
                           ,'Исторические данные на дату');
      
        v_values := get_history_values(par_registry, v_hist_date);
      ELSIF p_t = v_n
            AND p_t = 1
      THEN
        ins.pkg_trace.add_variable('p_start_date', p_start_date);
        ins.pkg_trace.trace(gc_pkg_name
                           ,c_local_proc_name
                           ,'Исторические данные на дату');
        v_values := get_history_values(par_registry, p_start_date);
      ELSE
        ins.pkg_trace.add_variable('ADD_MONTHS(p_end_date,-12)+1', ADD_MONTHS(p_end_date, -12) + 1);
        ins.pkg_trace.trace(gc_pkg_name
                           ,c_local_proc_name
                           ,'Исторические данные на дату');
        v_values := get_history_values(par_registry, p_start_date);
      
        /*v_values := get_history_values(par_registry, p_start_date);*/
        /*Выкупные в последний год №195854: если так - то пересчитает резервы, если как вверху,
        то найдет версию от начала ДС и возьмет историю, что не верно, т.к. изменение суммы в
        последней версии*/
        v_values := get_history_values(par_registry, ADD_MONTHS(p_end_date, -12) + 1);
      END IF;
    
      IF v_values.start_date IS NOT NULL
      THEN
        v_n := MONTHS_BETWEEN(v_values.end_date + 1, p_start_date) / 12;
        v_t := p_t;
        --v_t := v_values.t;
      
        --    Если покрытие не действует на дату, то закрываем расчет
        v_cur_date := ADD_MONTHS(p_start_date, p_i * 12);
        IF NOT (to_char(v_cur_date, 'dd') = to_char(p_start_date, 'dd'))
        THEN
          v_cur_date := v_cur_date - 1;
        END IF;
        IF v_cur_date > v_values.end_date + 1
        THEN
          /*
          DBMS_OUTPUT.PUT_LINE('Полис не действует... Выход из расчета ' || p_start_date || ' p_i ' || p_i || ' ' ||
                               ADD_MONTHS(p_start_date, p_t * 12) || ' ' || (v_values.end_date + 1));
          */
          p_t := -1;
          RETURN;
        END IF;
        -- срок страхования      
        -- плановая норма доходности на конец страхового года
        v_c := get_plan_yield_rate(v_ins_end_date);
        -- фактическая норма доходности
        IF v_values.fact_yield_rate IS NULL
           OR v_values.fact_yield_rate = 0
        THEN
          v_j := get_fact_yield_rate(v_hist_date, v_ins_end_date);
        ELSE
          v_j := v_values.fact_yield_rate;
        END IF;
      
        -- коэффициент В
        IF v_values.b IS NULL
           OR v_values.b = 0
        THEN
          v_b := get_b(p_i);
        ELSE
          v_b := v_values.b;
        END IF;
      
        -- доля коммиссии
        v_kom := get_kom(p_t);
      
        /*DBMS_OUTPUT.PUT_LINE('Поиск значения на начало года id ' || par_registry.ID || ' start_date ' ||
        ADD_MONTHS(v_hist_date, -12) || ' (t - 1) ' || (p_i - 1));*/
        IF MOD(extract(YEAR FROM g_start_date_header), 4) = 0
           AND to_char(g_start_date_header, 'DD') = 28
        THEN
          v_reserve_value_start := get_reserve_value(par_registry.id
                                                    ,to_date('28.' ||
                                                             to_char(ADD_MONTHS(v_hist_date, -12)
                                                                    ,'MM.YYYY')
                                                            ,'dd.mm.yyyy'));
        ELSE
          v_reserve_value_start := get_reserve_value(par_registry.id, ADD_MONTHS(v_hist_date, -12));
        END IF;
      
        ins.pkg_trace.add_variable('p_start_date', p_start_date);
        ins.pkg_trace.add_variable('v_hist_date', v_hist_date);
        ins.pkg_trace.add_variable('v_t', v_t);
        ins.pkg_trace.add_variable('v_values.is_periodical', v_values.is_periodical);
        ins.pkg_trace.add_variable('v_n', v_n);
        ins.pkg_trace.add_variable('v_c', v_c);
        ins.pkg_trace.add_variable('v_j', v_j);
        ins.pkg_trace.add_variable('v_b', v_b);
        ins.pkg_trace.add_variable('v_kom', v_kom);
      
        ins.pkg_trace.trace(gc_pkg_name, c_local_proc_name, 'Расчет резерва');
        v_reserve_value_end := reserve.pkg_reserve_life_alg.calc_reserve_for_iv(par_registry
                                                                               ,p_start_date
                                                                               ,v_hist_date
                                                                               ,v_values
                                                                               ,v_t
                                                                               ,v_reserve_value_start
                                                                               ,v_values.is_periodical
                                                                               ,v_n
                                                                               ,v_c
                                                                               ,v_j
                                                                               ,v_b
                                                                               ,v_kom);
      ELSE
        p_t := -1;
        ins.pkg_trace.add_variable('p_t', p_t);
        ins.pkg_trace.trace(gc_pkg_name
                           ,c_local_proc_name
                           ,'Данные не найдены .... устанавливаем p_t');
      END IF;
    
      ins.pkg_trace.trace_procedure_end(gc_pkg_name, c_local_proc_name);
    END calculate_reserve;
  
    PROCEDURE calculate_first_year IS
      c_local_proc_name CONSTANT ins.pkg_trace.t_object_name := 'CALCULATE_FIRST_YEAR';
    BEGIN
      ins.pkg_trace.add_variable('POLICY_ID', par_registry.policy_id);
      ins.pkg_trace.add_variable('POL_HEADER_ID', par_registry.pol_header_id);
      ins.pkg_trace.add_variable('P_T', p_t);
      ins.pkg_trace.add_variable('HIST_DATE', v_hist_date);
      ins.pkg_trace.trace_procedure_start(gc_pkg_name, c_local_proc_name);
    
      -- todo проверить правильность получения значений j, b, c,
      -- todo значения нужно брать, если не найдено значение на конец страх. года 
      -- получить историчные значения по полису и варианту страхования
      -- на начало страхового года 
    
      v_values := get_history_values(par_registry, v_hist_date);
    
      IF v_values.start_date IS NOT NULL
      THEN
        ins.pkg_trace.add_variable('START_DATE', v_values.start_date);
        ins.pkg_trace.add_variable('END_DATE', v_values.end_date);
        ins.pkg_trace.trace(gc_pkg_name
                           ,c_local_proc_name
                           ,'Дана начала определена');
        -- срок страхования
        v_n := MONTHS_BETWEEN(v_values.end_date + 1, p_start_date) / 12;
      
        -- плановая норма доходности на начало страхового года
        v_c := get_plan_yield_rate(v_hist_date);
      
        -- фактическая норма доходности
        v_j := nvl(v_values.fact_yield_rate, get_fact_yield_rate(v_hist_date, v_ins_end_date));
      
        -- коэффициент В
        v_b := nvl(v_values.b, get_b(p_i + 1));
      
        -- доля коммиссии
        v_kom := get_kom(p_t + 1);
      
        -- рассрочены ли взносы
      
        -- плановая норма доходности на начало страхового года
        v_c := get_plan_yield_rate(v_hist_date);
      
        v_reserve_value_start.insurance_year_date   := p_start_date;
        v_reserve_value_start.insurance_year_number := 0;
      
        ins.pkg_trace.add_variable('v_n', v_n);
        ins.pkg_trace.add_variable('v_c', v_c);
        ins.pkg_trace.add_variable('v_j', v_j);
        ins.pkg_trace.add_variable('v_b', v_b);
        ins.pkg_trace.add_variable('v_kom', v_kom);
        ins.pkg_trace.add_variable('v_c', v_c);
        ins.pkg_trace.add_variable('insurance_year_date', v_reserve_value_start.insurance_year_date);
        ins.pkg_trace.add_variable('insurance_year_number'
                                  ,v_reserve_value_start.insurance_year_number);
        ins.pkg_trace.add_variable('deathrate_id', v_values.deathrate_id);
        ins.pkg_trace.trace(gc_pkg_name, c_local_proc_name, 'Расчет резерва');
      
        v_reserve_value_start := pkg_reserve_life_alg.calc_reserve_for_iv(par_registry
                                                                         ,p_start_date
                                                                         ,v_hist_date
                                                                         ,v_values
                                                                         ,p_t
                                                                         ,v_reserve_value_start
                                                                         ,v_values.is_periodical
                                                                         ,v_n
                                                                         ,v_c
                                                                         ,v_j
                                                                         ,v_b
                                                                         ,v_kom);
      
        v_reserve_value_end := v_reserve_value_start;
        -- запишем значение резерва на начало первого страхового года      
        -- add_reserve_value(v_reserve_value_start);
        -- запишем значение резерва на начало первого страхового года
      ELSE
        p_t := -1;
        dbms_output.put_line('Данные не найдены .... p_t устанавливаем как ' || p_t);
      END IF;
    
      ins.pkg_trace.trace_procedure_end(gc_pkg_name, c_local_proc_name);
      --
    END calculate_first_year;
  
  BEGIN
    ins.pkg_trace.add_variable('par_registry.id', par_registry.id);
    ins.pkg_trace.add_variable('p_i', p_i);
    ins.pkg_trace.add_variable('p_t', p_t);
    ins.pkg_trace.add_variable('p_start_date', p_start_date);
    ins.pkg_trace.add_variable('p_end_date', p_end_date);
    ins.pkg_trace.trace_procedure_start(gc_pkg_name, c_proc_name);
  
    SELECT pol.start_date
          ,pol.version_num
      INTO l_cur_policy_start_date
          ,l_version_num
      FROM ins.p_policy pol
     WHERE pol.policy_id = par_registry.policy_id;
  
    -- определим дату начала страхового года с номером par_t
    v_hist_date := ADD_MONTHS(p_start_date
                             ,(p_i /*- 1*/
                              ) * 12);
  
    -- дата окончания страхового года с номером par_t
    v_ins_end_date := ADD_MONTHS(p_start_date, 12) - 1;
    v_n            := MONTHS_BETWEEN(p_end_date + 1, p_start_date) / 12;
  
    IF p_t <= 0
       AND trunc(l_cur_policy_start_date) >= trunc(v_hist_date)
       AND check_history_reserve = 1
    THEN
      get_history_reserve;
      -- add_reserve_value (v_reserve_value_end);        
    ELSIF p_t <= 0
    THEN
      -- если на начало первого страхового года    
      calculate_first_year;
    END IF;
  
    IF p_t > 0
    THEN
      IF trunc(l_cur_policy_start_date) >= trunc(v_hist_date)
         AND check_history_reserve = 1
      THEN
        get_history_reserve;
      ELSE
        calculate_reserve;
      END IF;
    
    END IF;
  
    IF p_t > -1
    THEN
      -- запишем значение рассчитанного резерва
      add_reserve_value(v_reserve_value_end);
    END IF;
  
    ins.pkg_trace.trace_procedure_end(gc_pkg_name, c_proc_name);
    /*exception 
    WHEN others THEN 
      raise;*/
  END;

  /**
  * Функция расчета значения резерва по регистру 
  * <br> резерва на произвольную дату.
  * @param par_registry регистр резерва, по которому проводится расчет
  * @param par_calc_date дата расчета
  */
  PROCEDURE calc_reserve_for_registry(par_registry IN r_reserve%ROWTYPE) IS
    v_reserve_value_for_begin r_reserve_value%ROWTYPE; -- резерв на начало
    v_reserve_value_for_end   r_reserve_value%ROWTYPE; -- резерв на конец
    v_n                       NUMBER; -- номер текущего страхового года
    v_start_date              DATE; -- дата начала страхового года,  который попала par_calc_date
    v_end_date                DATE; -- дата окончания страхового года, в который попала par_calc_date
    res_reserve_value         NUMBER; -- значение фактического резерва на дату расчета
    v_t                       NUMBER DEFAULT - 1;
    v_start_date_header       DATE;
  BEGIN
    -- получим дату начала ответственности
    dbms_output.put_line('CALC_RESERVE_FOR_REGISTRY получим дату начала ответственности ' ||
                         par_registry.pol_header_id || ' ' || par_registry.policy_id);
  
    SELECT
    /*     (CASE WHEN (SELECT COUNT(*)
                FROM ins.t_addendum_type t,
                     ins.p_pol_addendum_type pt
                WHERE t.t_addendum_type_id = pt.t_addendum_type_id
                      AND pt.p_policy_id = pp.policy_id
                      AND t.brief = 'CLOSE_FIN_WEEKEND'
                ) > 0
          THEN TRUNC(MONTHS_BETWEEN(pc.end_date + 1, ph.start_date)/12)
     ELSE TRUNC(MONTHS_BETWEEN(pc.end_date + 1, pc.start_date)/12)
     END
    )*/
     trunc(MONTHS_BETWEEN(pc.end_date + 1, pc.start_date) / 12)
    ,pc.start_date
    ,pc.end_date
    ,ph.start_date
      INTO v_n
          ,v_start_date
          ,v_end_date
          ,g_start_date_header
      FROM ins.p_pol_header ph
          ,ins.p_policy     pp
          ,ins.p_cover      pc
     WHERE 1 = 1
       AND ph.policy_header_id = par_registry.pol_header_id
       AND pp.policy_id = par_registry.policy_id
       AND pc.p_cover_id = par_registry.p_cover_id;
  
    dbms_output.put_line('START_DATE ' || v_start_date || ' v_n ' || v_n);
  
    -- расчитаем резерв на начало и на конец страхового года v_t
    FOR i IN 0 .. v_n
    LOOP
      v_t := v_t + 1;
      dbms_output.put_line('i ' || i || 'v_t ' || v_t);
    
      calc_reserve_anniversary(par_registry, i, v_t, v_start_date, v_end_date);
    END LOOP;
    -- интерполяция
  
    /*    exception 
          WHEN others then 
            -- todo выводить в комментарии не ИД, а название варианта страхования, номер договора
            -- и информацию по застрахованному - вопрос какую?
            pkg_reserve_life.error(pkg_name, 'calc_reserve_for_iv', 'При расчете резерва по варианту страхования произошли ошибки (см. выше)' ||
                      par_registry.insurance_variant_id ||' для договора ' || par_registry.policy_id 
                      || ' и застрахованного ' || par_registry.contact_id);
            raise;    
    */
  END;

  /**
  * Процедура добавляет записи в r_reserve_ross для неучтенных регистров
  * резерва.
  * Процедура зависит от БД
  */
  PROCEDURE check_new_regisry IS
    -- неучтенные регистры по договорам страхования жизни
    CURSOR new_reserves IS
      SELECT vner.policy_id
            ,vner.p_asset_header_id
            ,vner.insurance_variant_id
            ,vner.t_product_line_id
        FROM v_not_exists_registry vner;
  BEGIN
    -- добавим новые регистры 
    FOR rec IN new_reserves
    LOOP
      INSERT INTO r_reserve
        (id, policy_id, insurance_variant_id, p_asset_header_id)
      VALUES
        (sq_r_reserve.nextval, rec.policy_id, rec.insurance_variant_id, rec.p_asset_header_id);
    END LOOP;
    NULL;
  END;

  /**
  * Процедура расчета резервов по компании. 
  * @param par_calc_reserve Запись таблицы r_calc_reserve. Это запись
  * вида ИД, Номер расчета, Дата расчета. Расчет производится по всем вариантам
  * которые являются параметрами данного расчета. Т.е из на основании записей таблицы 
  * r_calc_results, которые ссылаются на данный расчет (par_calc_reserve). 
  * После проведения расчетов записи в таблице r_calc_results заменяются
  * на результаты расчета по этим вариантам страхования. Для хранения проме
  * жуточных результатов используется таблица r_calc_results_temp.
  * Регистры резервов, которые участвуют в расчете получаются на основании пересения
  * выбранных в качестве параметров расчета вариантов страхования и 
  * действующих договоров страхования жизни из представления v_active_policy_ross
  */
  PROCEDURE calc_reserve_for_company(par_calc_reserve r_calc_reserve%ROWTYPE) IS
    -- выдает регистры резервов по действующим на дату расчета договорам 
    -- страхования жизни 
    CURSOR registry_map(cur_calc_reserve r_calc_reserve%ROWTYPE) IS
      SELECT r.id
            ,r.policy_id
            ,r.insurance_variant_id
            ,r.t_product_line_id
            ,r.contact_id
            ,r.p_asset_header_id
            ,f.brief AS cur
        FROM r_reserve r
            ,(SELECT ap.policy_id
                    ,ap.fund_id
                FROM v_active_policy_life ap
              -- todo проверить правильность выборки договоров
               WHERE ap.start_date <= cur_calc_reserve.calc_date) apr
            ,fund f
       WHERE 1 = 1
         AND r.policy_id = apr.policy_id
         AND apr.fund_id = f.fund_id
         AND r.insurance_variant_id IN (SELECT DISTINCT r.insurance_variant_id FROM r_reserve r);
    /*  (SELECT crr.insurance_variant_id 
     FROM r_calc_results crr
    WHERE crr.calc_reserve_id = cur_calc_reserve.id);*/
  
    registry      r_reserve%ROWTYPE;
    reserve_value NUMBER;
  BEGIN
    -- учтем новые регистры резервов в r_reserve
    check_new_regisry;
  
    -- очистим таблицу для промежуточных результатов   
    DELETE FROM r_calc_results_temp;
    -- очистим журнал ошибок;
    DELETE FROM r_error_journal;
  
    -- по всем регистрам резерва
    FOR rec IN registry_map(par_calc_reserve)
    LOOP
      registry.id                   := rec.id;
      registry.policy_id            := rec.policy_id;
      registry.insurance_variant_id := rec.insurance_variant_id;
      registry.contact_id           := rec.contact_id;
    
      BEGIN
        -- считаем значение резерва по регистру на дату расчета
        calc_reserve_for_registry(registry);
      
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
    
    END LOOP;
    /*    
        -- удаляем параметры расчета
        delete from r_calc_results where calc_reserve_id = par_calc_reserve.id;
        
        -- вставляем результаты расчета 
        insert into r_calc_results (ID,
                                         calc_reserve_id, 
                                         insurance_variant_id, 
                                         reserve_value,
                                         currency, 
                                         reserve_value_rur)
          -- вставляем сгруппированные по варианту страхования
          -- и валюте значения резервов по регистрам на дату
          SELECT sq_r_calc_results.nextval, 
                 par_calc_reserve.id,
                 t.iv,
                 t.res,
                 t.cur,
                 t.res_rur
            from (select crt.insurance_variant_id as iv, 
                         sum(crt.reserve_value) as res, 
                         crt.currency as cur, 
                         sum(crt.reserve_value) * pkg_reserve.get_cross_rate_by_brief_cb(crt.currency,'RUR', par_calc_reserve.calc_date) as res_rur
                    from r_calc_results_temp crt
                group by crt.insurance_variant_id, crt.currency) t;
    */
  END;

  /** 
  * Актуарная функция. Значение равно отношению брутто-взноса к страховой сумме
  * @param par_inv вариант страхования
  * @param par_sex пол застрахованного
  * @param par_age страховой возраст застрахованного
  * @param par_start_date дата начала ответственности по варианту страхования 
  * @param par_end_date дата окончания ответственности по варианту страхования
  * @param par_periodisity периодичность оплаты взносов (количество платежей в год)
  * @param par_r срок уплаты взносов
  * @param par_j норма доходности, указанная на договоре
  * @param par_b коэффициент b
  * @param par_rent_periodicity периодичность выплаты ренты
  * @param par_rent_payment размер разовой ренты
  * @param par_rent_duration срок выплаты ренты
  * @param par_has_additional имеется дополнительный вариант страхования
  * @param par_payment_base сумма брутто_взносов по остальным вариантам страхования
  * @return брутто-взнос/страховая сумма, либо 0, если 
  * при расчете были ошибки
  */
  FUNCTION act_function
  (
    par_inv              IN NUMBER
   ,par_sex              IN NUMBER
   ,par_age              IN NUMBER
   ,par_start_date       IN DATE
   ,par_end_date         IN DATE
   ,par_periodicity      IN NUMBER
   ,par_r                IN NUMBER
   ,par_j                IN NUMBER
   ,par_b                IN NUMBER
   ,par_rent_periodicity IN NUMBER DEFAULT NULL
   ,par_rent_payment     IN NUMBER DEFAULT NULL
   ,par_rent_duration    IN NUMBER DEFAULT NULL
   ,par_has_additional   IN NUMBER DEFAULT 0
   ,par_payment_base     IN NUMBER DEFAULT 0
  ) RETURN NUMBER IS
    v_values  pkg_reserve_r_life.hist_values_type;
    res_value NUMBER;
  BEGIN
    BEGIN
      -- инициализируем данные по регистру резерва
      v_values.fact_yield_rate := par_j;
      IF v_values.fact_yield_rate IS NULL
         OR v_values.fact_yield_rate = 0
      THEN
        v_values.fact_yield_rate := get_plan_yield_rate(par_start_date);
      END IF;
      v_values.periodicity      := par_periodicity;
      v_values.payment_duration := par_r;
      v_values.start_date       := par_start_date;
      v_values.end_date         := par_end_date;
      v_values.b                := par_b;
      v_values.rent_periodicity := par_rent_periodicity;
      v_values.rent_payment     := par_rent_payment;
      v_values.rent_payment     := par_rent_duration;
      v_values.has_additional   := par_has_additional;
      v_values.payment_base     := par_payment_base;
    
      -- инициализируем данные по застрахованному;
      v_values.sex := par_sex;
      v_values.age := par_age;
    
      res_value := pkg_reserve_life_alg.act_iv(par_inv, v_values);
    
      /*   exception 
      when others then 
        res_value := 0;
         */
    END;
  
    RETURN res_value;
  END;

  /** 
  * Функция значения балансового резерка на дату
  * @param p_policy_header_id ИД договора страхования
  * @param p_insurance_variant_id ИД страховой программы
  * @param p_contact_id ИД застрахованного
  * @param p_calc_date Дата, на которую расчитывается балансовый резерв 
  */
  FUNCTION get_vb
  (
    p_policy_header_id     IN NUMBER
   ,p_policy_id            IN NUMBER
   ,p_insurance_variant_id IN NUMBER
   ,p_p_asset_header_id    IN NUMBER
   ,p_calc_date            IN DATE
  ) RETURN NUMBER IS
  
    RESULT NUMBER;
  
  BEGIN
    FOR i IN (SELECT par_date_begin
                    ,par_date_end
                    ,par_value_for_begin
                    ,par_value_for_end
                    ,par_calc_date
                FROM (SELECT rv.reserve_date par_date_begin
                            ,lead(rv.reserve_date) over(PARTITION BY reserve_id ORDER BY reserve_date) par_date_end
                            ,rv.plan par_value_for_begin
                            ,lead(rv.plan) over(PARTITION BY reserve_id ORDER BY reserve_date) par_value_for_end
                            ,p_calc_date par_calc_date
                        FROM reserve.r_reserve_value rv
                       WHERE rv.reserve_id IN
                             (SELECT rr.id
                                FROM reserve.r_reserve rr
                               WHERE 1 = 1
                                 AND rr.pol_header_id = p_policy_header_id
                                 AND rr.policy_id = p_policy_id
                                 AND rr.insurance_variant_id = p_insurance_variant_id
                                 AND rr.p_asset_header_id = p_p_asset_header_id)
                       ORDER BY rv.reserve_date)
               WHERE 1 = 1
                 AND p_calc_date BETWEEN par_date_begin AND par_date_end)
    LOOP
      --DBMS_OUTPUT.PUT_LINE ('Поиск вилки значений '||p_policy_header_id||' '||p_policy_id||' '||p_insurance_variant_id||' '||p_p_asset_header_id||' '||p_calc_date);             
      --DBMS_OUTPUT.PUT_LINE ('Поиск иинтерп. значения '||i.par_date_begin||' '||i.par_date_end||' '||i.par_value_for_begin||' '||i.par_value_for_begin||' '||i.par_calc_date);             
      RESULT := line_interpolation(i.par_date_begin
                                  ,i.par_date_end
                                  ,i.par_value_for_begin
                                  ,i.par_value_for_end
                                  ,i.par_calc_date);
    
    END LOOP;
    RETURN RESULT;
  END;

  FUNCTION get_v
  (
    p_policy_header_id     IN NUMBER
   ,p_policy_id            IN NUMBER
   ,p_insurance_variant_id IN NUMBER
   ,p_p_asset_header_id    IN NUMBER
   ,p_calc_date            IN DATE
  ) RETURN NUMBER IS
  
    RESULT NUMBER;
  
  BEGIN
    FOR i IN (SELECT rv.tv_p
                FROM reserve.r_reserve_value rv
                    ,reserve.r_reserve       rr
               WHERE 1 = 1
                 AND rr.pol_header_id = p_policy_header_id
                 AND rr.policy_id = p_policy_id
                 AND rr.insurance_variant_id = p_insurance_variant_id
                 AND rr.p_asset_header_id = p_p_asset_header_id
                 AND rv.reserve_id = rr.id
                 AND rv.reserve_date = p_calc_date
                 AND rownum < 2)
    LOOP
      RESULT := i.tv_p;
    END LOOP;
    RETURN RESULT;
  END;

  FUNCTION get_p
  (
    p_policy_header_id     IN NUMBER
   ,p_policy_id            IN NUMBER
   ,p_insurance_variant_id IN NUMBER
   ,p_p_asset_header_id    IN NUMBER
   ,p_calc_date            IN DATE
  ) RETURN NUMBER IS
  
    RESULT NUMBER;
  
  BEGIN
    FOR i IN (SELECT rv.p
                FROM reserve.r_reserve_value rv
                    ,reserve.r_reserve       rr
               WHERE 1 = 1
                 AND rr.pol_header_id = p_policy_header_id
                 AND rr.policy_id = p_policy_id
                 AND rr.insurance_variant_id = p_insurance_variant_id
                 AND rr.p_asset_header_id = p_p_asset_header_id
                 AND rv.reserve_id = rr.id
                 AND rv.insurance_year_date = p_calc_date
                 AND rownum < 2)
    LOOP
      RESULT := i.p;
    END LOOP;
    RETURN RESULT;
  END;

  FUNCTION get_vs
  (
    p_policy_header_id     IN NUMBER
   ,p_policy_id            IN NUMBER
   ,p_insurance_variant_id IN NUMBER
   ,p_p_asset_header_id    IN NUMBER
   ,p_reserve_date         IN DATE
  ) RETURN NUMBER IS
  
    RESULT NUMBER;
  
  BEGIN
    FOR i IN (SELECT rv.tvs_p
                FROM reserve.r_reserve_value rv
                    ,reserve.r_reserve       rr
               WHERE 1 = 1
                 AND rr.pol_header_id = p_policy_header_id
                 AND rr.policy_id = p_policy_id
                 AND rr.insurance_variant_id = p_insurance_variant_id
                 AND rr.p_asset_header_id = p_p_asset_header_id
                 AND rv.reserve_id = rr.id
                 AND rv.reserve_date = p_reserve_date
                 AND rownum < 2)
    LOOP
      RESULT := i.tvs_p;
    END LOOP;
    RETURN RESULT;
  END;

  FUNCTION get_vb_paid
  (
    p_policy_header_id     IN NUMBER
   ,p_policy_id            IN NUMBER
   ,p_insurance_variant_id IN NUMBER
   ,p_p_asset_header_id    IN NUMBER
   ,p_reserve_date         IN DATE
  ) RETURN NUMBER IS
  
    RESULT NUMBER;
  
  BEGIN
    FOR i IN (SELECT rv.plan
                FROM reserve.r_reserve_value rv
                    ,reserve.r_reserve       rr
               WHERE 1 = 1
                 AND rr.pol_header_id = p_policy_header_id
                 AND rr.policy_id = p_policy_id
                 AND rr.insurance_variant_id = p_insurance_variant_id
                 AND rr.p_asset_header_id = p_p_asset_header_id
                 AND rv.reserve_id = rr.id
                 AND rv.reserve_date = p_reserve_date
                 AND rownum < 2)
    LOOP
      RESULT := i.plan;
    END LOOP;
    RETURN RESULT;
  END;
  /**/
  FUNCTION get_pl_vs
  (
    p_policy_header_id     IN NUMBER
   ,p_policy_id            IN NUMBER
   ,p_insurance_variant_id IN NUMBER
   ,p_p_asset_header_id    IN NUMBER
   ,p_reserve_date         IN DATE
   ,p_pl_id                NUMBER
  ) RETURN NUMBER IS
  
    RESULT NUMBER;
  
  BEGIN
    FOR i IN (SELECT rv.tvs_p
                FROM reserve.r_reserve_value rv
                    ,reserve.r_reserve       rr
               WHERE 1 = 1
                 AND rr.pol_header_id = p_policy_header_id
                 AND rr.policy_id = p_policy_id
                 AND rr.insurance_variant_id = p_insurance_variant_id
                 AND rr.p_asset_header_id = p_p_asset_header_id
                 AND rv.reserve_id = rr.id
                 AND rv.reserve_date = p_reserve_date
                 AND rr.t_product_line_id = p_pl_id
                 AND rownum < 2)
    LOOP
      RESULT := i.tvs_p;
    END LOOP;
    RETURN RESULT;
  END;
  /**/
  FUNCTION get_s
  (
    p_policy_header_id     IN NUMBER
   ,p_policy_id            IN NUMBER
   ,p_insurance_variant_id IN NUMBER
   ,p_p_asset_header_id    IN NUMBER
   ,p_calc_date            IN DATE
  ) RETURN NUMBER IS
    RESULT NUMBER;
  
  BEGIN
    FOR i IN (SELECT rv.s
                FROM reserve.r_reserve_value rv
                    ,reserve.r_reserve       rr
               WHERE 1 = 1
                 AND rr.pol_header_id = p_policy_header_id
                 AND rr.policy_id = p_policy_id
                 AND rr.insurance_variant_id = p_insurance_variant_id
                 AND rr.p_asset_header_id = p_p_asset_header_id
                 AND rv.reserve_id = rr.id
                 AND rv.insurance_year_date = p_calc_date
                 AND rownum < 2)
    LOOP
      RESULT := i.s;
    END LOOP;
    RETURN RESULT;
  END;

  /**/
  FUNCTION get_pl_s
  (
    p_policy_header_id     IN NUMBER
   ,p_policy_id            IN NUMBER
   ,p_insurance_variant_id IN NUMBER
   ,p_p_asset_header_id    IN NUMBER
   ,p_calc_date            IN DATE
   ,p_pl_id                NUMBER
  ) RETURN NUMBER IS
    RESULT NUMBER;
  
  BEGIN
    FOR i IN (SELECT rv.s
                FROM reserve.r_reserve_value rv
                    ,reserve.r_reserve       rr
               WHERE 1 = 1
                 AND rr.pol_header_id = p_policy_header_id
                 AND rr.policy_id = p_policy_id
                 AND rr.insurance_variant_id = p_insurance_variant_id
                 AND rr.p_asset_header_id = p_p_asset_header_id
                 AND rv.reserve_id = rr.id
                 AND rv.insurance_year_date = p_calc_date
                 AND rr.t_product_line_id = p_pl_id
                 AND rownum < 2)
    LOOP
      RESULT := i.s;
    END LOOP;
    RETURN RESULT;
  END;

  FUNCTION get_pp
  (
    p_policy_header_id     IN NUMBER
   ,p_policy_id            IN NUMBER
   ,p_insurance_variant_id IN NUMBER
   ,p_p_asset_header_id    IN NUMBER
   ,p_calc_date            IN DATE
  ) RETURN NUMBER IS
  
    RESULT NUMBER;
  
  BEGIN
    FOR i IN (SELECT rv.p
                FROM reserve.r_reserve_value rv
                    ,reserve.r_reserve       rr
               WHERE 1 = 1
                 AND rr.pol_header_id = p_policy_header_id
                 AND rr.policy_id = p_policy_id
                 AND rr.insurance_variant_id = p_insurance_variant_id
                 AND rr.p_asset_header_id = p_p_asset_header_id
                 AND rv.reserve_id = rr.id
                 AND rv.reserve_date = p_calc_date
                 AND rownum < 2)
    LOOP
      RESULT := i.p;
    END LOOP;
    RETURN RESULT;
  END;

  FUNCTION get_ss
  (
    p_policy_header_id     IN NUMBER
   ,p_policy_id            IN NUMBER
   ,p_insurance_variant_id IN NUMBER
   ,p_p_asset_header_id    IN NUMBER
   ,p_calc_date            IN DATE
  ) RETURN NUMBER IS
    RESULT NUMBER;
  
  BEGIN
    FOR i IN (SELECT rv.s
                FROM reserve.r_reserve_value rv
                    ,reserve.r_reserve       rr
               WHERE 1 = 1
                 AND rr.pol_header_id = p_policy_header_id
                 AND rr.policy_id = p_policy_id
                 AND rr.insurance_variant_id = p_insurance_variant_id
                 AND rr.p_asset_header_id = p_p_asset_header_id
                 AND rv.reserve_id = rr.id
                 AND rv.reserve_date = p_calc_date
                 AND rownum < 2)
    LOOP
      RESULT := i.s;
    END LOOP;
    RETURN RESULT;
  END;

/*

  BEGIN
    -- Initialization
    < STATEMENT >;*/

END;
/

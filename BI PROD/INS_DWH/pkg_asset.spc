CREATE OR REPLACE PACKAGE Pkg_Asset IS

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
  FUNCTION get_property_UL
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
    p_pol_id        NUMBER
   ,p_contact_id    NUMBER
   ,p_work_group_id NUMBER
  ) RETURN NUMBER;

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
  *Изменить суммы страхования по всем объектам страхования
  * @author Чикашова
  * @param p_pol_id - ИД версии договора
  * @param p_sum - сумма
  */
  PROCEDURE update_asset_sum
  (
    p_pol_id IN NUMBER
   ,p_sum    IN NUMBER
  );

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
END;
/

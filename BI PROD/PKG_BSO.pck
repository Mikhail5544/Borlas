CREATE OR REPLACE PACKAGE ins.pkg_bso IS

  --БСО

  v_series  NUMBER;
  v_current NUMBER := 0;
  v_max     NUMBER := 0;

  /**
  * Процедура добавления Акта движения БСО аналогично {%link pkg_bso.insert_bso_document;2}, но без выходного параметра
  * @author Капля П.
  * @param par_doc_templ_id       ИД шаблона документа
  * @param par_contact_from_id    ИД контакта, от которого передаются БСО
  * @param par_contact_to_id      ИД контакта, которому передаются БСО
  * @param par_department_from_id ИД подразделения, от кого передаются БСО
  * @param par_department_to_id   ИД подразделения, кому передаются БСО
  * @param par_allow_over_norm    Флаг, что можно передавать сверх нормы
                                  {*} 0 Производить контроль норм выдачи
                                  {*} 1 Разрешить передавать сверх нормы
  * @param par_num                Номер Акта движения БСО, по умолчанию - ИД документа
  * @param par_reg_date           Дата документа Акта движения БСО. По умолчанию - текущая дата
  */
  PROCEDURE insert_bso_document
  (
    par_doc_templ_id       doc_templ.doc_templ_id%TYPE
   ,par_contact_from_id    bso_document.contact_from_id%TYPE
   ,par_contact_to_id      bso_document.contact_to_id%TYPE
   ,par_department_from_id bso_document.department_from_id%TYPE
   ,par_department_to_id   bso_document.department_to_id%TYPE
   ,par_allow_over_norm    bso_document.allow_over_norm%TYPE
   ,par_num                document.num%TYPE DEFAULT NULL
   ,par_reg_date           document.reg_date%TYPE DEFAULT SYSDATE
  );

  /**
  * Процедура добавления Акта движения БСО (с выходным параметром)
  * @author Капля П.
  * @param par_doc_templ_id       ИД шаблона документа
  * @param par_contact_from_id    ИД контакта, от которого передаются БСО
  * @param par_contact_to_id      ИД контакта, которому передаются БСО
  * @param par_department_from_id ИД подразделения, от кого передаются БСО
  * @param par_department_to_id   ИД подразделения, кому передаются БСО
  * @param par_allow_over_norm    Флаг, что можно передавать сверх нормы
                                  {*} 0 Производить контроль норм выдачи
                                  {*} 1 Разрешить передавать сверх нормы
  * @param par_num                Номер Акта движения БСО, по умолчанию - ИД документа
  * @param par_reg_date           Дата документа Акта движения БСО. По умолчанию - текущая дата
  * @param par_bso_document_id    Выходной парамтр - ИД Акта движения БСО
  */
  PROCEDURE insert_bso_document
  (
    par_doc_templ_id       doc_templ.doc_templ_id%TYPE
   ,par_contact_from_id    bso_document.contact_from_id%TYPE
   ,par_contact_to_id      bso_document.contact_to_id%TYPE
   ,par_department_from_id bso_document.department_from_id%TYPE
   ,par_department_to_id   bso_document.department_to_id%TYPE
   ,par_allow_over_norm    bso_document.allow_over_norm%TYPE
   ,par_num                document.num%TYPE DEFAULT NULL
   ,par_reg_date           document.reg_date%TYPE DEFAULT SYSDATE
   ,par_bso_document_id    OUT bso_document.bso_document_id%TYPE
  );

  /**
  * Добавление содержимого документа БСО
  * @author Patsan O.
  * @param p_doc_id ИД документа
  * @param p_doc_cont_id ИД содержимого документа
  * @param p_start начало диапазона номеров бланков
  * @param p_bso_series Тип БСО
  * @param p_end конец диапазона номеров, если пустой, то в диапазоне 1 бланк
  * @param p_bso_type тип бланка
  * @param p_bso_notes_type_id ИД типа примечаний
  */
  PROCEDURE insert_cont
  (
    p_doc_id            IN NUMBER
   ,p_doc_cont_id       IN NUMBER
   ,p_start             IN VARCHAR2
   ,p_end               IN VARCHAR2
   ,p_bso_series        IN NUMBER
   ,p_bso_hist_type     IN NUMBER
   ,p_bso_notes_type_id IN NUMBER
   ,p_bso_count         IN NUMBER
   ,p_num_comment       IN VARCHAR2
  );

  /**
  * Изменение содержимого документа БСО
  * @author Patsan O.
  * @param p_doc_cont_id ИД содержимого документа
  * @param p_start начало диапазона номеров бланков
  * @param p_end конец диапазона номеров, если пустой, то в диапазоне 1 бланк
  * @param p_bso_series Тип БСО
  * @param p_bso_type тип бланка
  * @param p_bso_notes_type_id ИД типа примечаний
  */
  PROCEDURE update_cont
  (
    p_doc_cont_id       IN NUMBER
   ,p_start             IN VARCHAR2
   ,p_end               IN VARCHAR2
   ,p_bso_series        IN NUMBER
   ,p_bso_hist_type     IN NUMBER
   ,p_bso_notes_type_id IN NUMBER
   ,p_bso_count         IN NUMBER
   ,p_num_comment       IN VARCHAR2
  );

  /**
  * удаление содержимого документа БСО
  * @author Patsan O.
  * @param p_doc_cont_id ИД содержимого документа
  */
  PROCEDURE delete_cont(p_doc_cont_id IN NUMBER);

  /**
  * Удаление документа БСО
  * @author Kushenko S.
  * @param p_document_id ИД документа
  */

  PROCEDURE delete_document(p_document_id IN NUMBER);

  /**
  * Анулирование документа БСО
  * @author Chirkov V.
  * @param p_document_id ИД документа
  */
  PROCEDURE bso_act_annulated(p_document_id IN NUMBER);

  /**
  * Блокировака содержимого документа БСО
  * @author Patsan O.
  * @param p_doc_cont_id ИД содержимого документа
  */

  PROCEDURE lock_cont(p_doc_cont_id IN NUMBER);

  /**
  * Получение автономера для документа БСО
  * @author Patsan O.
  * @param p_bso_doc_templ ИД шаблона документа
  * @return автономер для документа БСО
  */
  FUNCTION get_bso_doc_num(p_bso_doc_templ IN NUMBER) RETURN VARCHAR2;

  /**
  * Проверка возможности установки бланка для полиса
  * @author Patsan O.
  * @param par_policy_id ИД версии полиса
  * @param par_is_set необходимо привязать бланк к полису, по умолчанию - нет
  * @param par_is_clear необходимо отвязать бланк от полиса - по умолчанию - нет
  * @param par_bso_type_brief - проверка номера полиса или спецзнака по ОСАГО - по умолчанию - ОСАГО
  */
  PROCEDURE check_bso_on_policy
  (
    par_policy_id      IN NUMBER
   ,par_is_set         IN NUMBER DEFAULT 0
   ,par_is_clear       IN NUMBER DEFAULT 0
   ,par_bso_type_brief IN VARCHAR2 DEFAULT 'ОСАГО'
  );

  /**
  * Проверка возможности установки бланков всех возможных для данного продукта типов для полиса
  * @author Ganichev F.
  * @param par_policy_id ИД версии полиса
  * @param par_is_set необходимо привязать бланк к полису
  * @param par_is_clear необходимо отвязать бланк от полиса
  */
  PROCEDURE check_all_bso_on_policy
  (
    par_policy_id IN NUMBER
   ,par_is_set    IN NUMBER DEFAULT 0
   ,par_is_clear  IN NUMBER DEFAULT 0
  );

  /** Вероятно не верная функция!!! (08.2014, вроде бы все норм)
  * Подсчет бланков, имеющихся в наличии у контакта в статусах Выдан, Передан, PRINTED_EMPTY
  * @author Shidlovskaya T.
  * @param p_contact_id иди контакта, владеющего БСО
  */
  FUNCTION count_bso_to_contact(p_contact_id IN NUMBER) RETURN NUMBER;

  /**
  * Подсчет бланков , имеющихся в наличии у контакта в статусах Выдан, Зарезервирован, Передан, PRINTED_EMPTY
  * @param p_contact_id иди контакта, владеющего БСО
  */
  FUNCTION count_bso_to_contact2(p_contact_id IN NUMBER) RETURN NUMBER;

  /**
  * Анализ привязки конкретного БСО к договору
  * аналог версии процедуры check_bso_on_policy
  * @author Shidlovskaya T.
  * @param p_bso_typ_br тип БСО значение brief из ven_bso_type
  * @param p_bso_ser серия бланка
  * @param p_bso_num номер бланка
  * @param p_policy_id ИД версии полиса
  * @return функция возвращает код ошибки:
   {*} 0 - без ошибок
   {*} 1 -- БСО не найден
   {*} 2 -- Договор не найден
   {*} 3 -- БСО не принадлежит продукту
   {*} 4 -- колич. по данному типу БСО (не группа)
   {*} 5 -- БСО привязан к другому полису
   {*} 6 -- БСО привязан к другой версии полиса
   {*} 7 -- состояние БСО не позволяет работать с ним
   {*} 99 -- Проверьте целостность БД
  */
  FUNCTION check_relation_bso_pol
  (
    p_bso_typ_br IN VARCHAR2 DEFAULT 'ОСАГО'
   ,p_bso_ser    IN VARCHAR2 DEFAULT 'ААА'
   ,p_bso_num    IN VARCHAR2
   ,p_policy_id  IN NUMBER
  ) RETURN NUMBER;

  /**
  * Создание строки состояния БСО при привязки его к договору
  * @author Shidlovskaya T.
  * @param p_bso_typ_br тип БСО значение brief из  ven_bso_type
  * @param p_bso_ser серия бланка
  * @param p_bso_num номер бланка
  * @param p_policy_id ИД версии полиса
  */
  PROCEDURE create_relation_bso_pol
  (
    p_bso_typ_br IN VARCHAR2 DEFAULT 'ОСАГО'
   ,p_bso_ser    IN VARCHAR2 DEFAULT 'ААА'
   ,p_bso_num    IN VARCHAR2
   ,p_policy_id  IN NUMBER
  );

  /**
   * Генерация номеров бланков по диапазону и генерация состояний этих бланков
   * @param p_doc_id ИД документа
  */
  PROCEDURE gen_doc(p_doc_id IN NUMBER);

  /**
  * Проверка возможности установки статуса сотрудника
  * @author Patsan O.
  * @param p_employee_hist_id ИД записи истории сотрудника
  * @param p_employee_id ИД сотрудника
  * @param p_department_id ИД департамента
  * @param p_date_hist Дата
  * @param p_is_kicked Флаг уволен
  * @param p_is_brokeage Флаг МО
  */
  PROCEDURE check_employee
  (
    p_employee_hist_id IN NUMBER
   ,p_employee_id      IN NUMBER
   ,p_department_id    IN NUMBER
   ,p_date_hist        IN DATE
   ,p_is_kicked        IN NUMBER
   ,p_is_brokeage      IN NUMBER
  );

  /**
  * Отвязать БСО от платежного документа, откатить статус "Использован"
  * @author Sergeev D.
  * @param p_bso_id ИД БСО
  */
  PROCEDURE unlink_bso_payment(p_bso_id NUMBER);

  /**
  * Отвязать ВСЕ БСО от договора, откатить статус в "Использован"
  * Используется для освобождения БСО перед удалением временного договора из В2В
  * @author Капля П.
  * @param p_pol_header_id ИД заголовка договора
  */
  PROCEDURE unlink_bso_policy(p_pol_header_id NUMBER);

  /**
  * Привязать БСО к полису и платежному документу-квитанции
  * @author Sergeev D.
  * @param p_bso_id ИД БСО
  * @param p_payment_id ИД платежного документа
  * @param p_policy_id  ИД версии договора страхования
  */
  PROCEDURE link_bso_payment
  (
    p_bso_id     NUMBER
   ,p_payment_id NUMBER
   ,p_policy_id  NUMBER
  );

  /**
  * Функция определения состояния бланка на дату
  * @author Балашов: 03.04.2007
  * @param p_bso_id ИД БСО
  * @param dt Дата, по умолчанию - текущая дата
  * @return Бриф статуса
  */
  FUNCTION get_bso_status_brief
  (
    p_bso_id IN NUMBER
   ,dt       IN DATE DEFAULT SYSDATE
  ) RETURN VARCHAR2;

  /**
  * Функция определения статуса бланка
  * @author Балашов: 03.04.2007
  * @param   p_bso_id ИД БСО
  * @return  Бриф статуса
  */
  FUNCTION get_bso_last_status_brief(p_bso_id IN NUMBER) RETURN VARCHAR2;

  /**
  * Процедура проверки возможности изменения статуса документа по БСО
  * @author Shidlovskaya T.
  * @param p_act_id иди документа по БСО
  */
  PROCEDURE check_act_bso(p_act_id NUMBER);

  /**
  * Процедура проверки возможности изменения статуса документа по БСО
  * @author Kushenko S.
  * @param p_act_id ИД документа БСО
  * @param p_reg_date Дата документа БСО
  */
  PROCEDURE check_act_bso_date_update
  (
    p_act_id   NUMBER
   ,p_reg_date DATE
  );

  /**
  * Процедура проверки на пересечение с уже существующими БСО
  * @author Pavel A. Mikushin
  * @param p_bso_series_id Серия документа БСО
  * @param p_start Начало диапазона
  * @param p_end конец диапазона БСО
  */
  PROCEDURE check_cre_bdc
  (
    p_bso_series_id IN NUMBER
   ,p_start         IN VARCHAR2
   ,p_end           IN VARCHAR2
  );

  PROCEDURE calc_bso_norm
  (
    p_p_contact_id NUMBER
   ,p_p_date_act   DATE
  );
  PROCEDURE calc_bso_doc
  (
    p_p_contact_id NUMBER
   ,p_p_doc_id     NUMBER
  );
  PROCEDURE set_status_bso(p_p_doc_id NUMBER);
  PROCEDURE check_bso_norm(p_p_doc_id NUMBER);
  PROCEDURE calc_check_bso_norm(p_p_doc_id NUMBER);
  FUNCTION state(p_message OUT NOCOPY VARCHAR2) RETURN VARCHAR2;
  PROCEDURE calc_num
  (
    p_num_start             IN VARCHAR2
   ,p_num_end               IN VARCHAR2
   ,p_id                    IN NUMBER
   ,p_hist_value            IN VARCHAR2
   ,p_is_created            IN NUMBER
   ,p_is_status_change_type IN NUMBER DEFAULT 1
  );

  /* ilyushkin.sergey 18/07/2012
    Возвращает количество доступных для выдачи БСО согласно ТЗ "Администрирование БСО"
    @par_contact_id - ИД контакта, которому требуется выдача БСО 
    @par_series_id - ИД серии БСО
    @par_date - Дата расчета
    @return - доступный остаток БСО
  */
  FUNCTION get_bso_limit
  (
    par_contact_id NUMBER
   ,par_series_id  NUMBER
   ,par_date       DATE DEFAULT SYSDATE
  ) RETURN NUMBER;

  /*
    Капля П.
    05.06.2014
    Процедура заполнения временной таблицы пустыми бланками, и перевод их в статуем "Распечатан пустой бланк"
    Используется в интеграционной схеме ряда партнеров, когда сначала они печатают пустые бланки,
    а потом заводят на них договоры.
  */
  PROCEDURE create_empty_bso_pool
  (
    par_bso_series_id     bso_series.bso_series_id%TYPE
   ,par_to_generate_count PLS_INTEGER
   ,par_agent_id          contact.contact_id%TYPE DEFAULT NULL
  );

  /*
  Капля П.
  Генерация следующего по счету свободного номера БСО
  */
  FUNCTION gen_next_bso_id
  (
    par_bso_series_id NUMBER
   ,par_agent_id      NUMBER DEFAULT NULL
  ) RETURN bso.bso_id%TYPE;

  FUNCTION gen_next_bso_number
  (
    par_bso_series_id NUMBER
   ,par_agent_id      NUMBER DEFAULT NULL
  ) RETURN bso.num%TYPE;
  /*
  Капля П.
  Прикрепление БСО к полису
  */
  PROCEDURE attach_bso_to_policy
  (
    par_policy_id  p_policy.policy_id%TYPE
   ,par_bso_id     bso.bso_id%TYPE
   ,par_is_pol_num bso.is_pol_num%TYPE DEFAULT 1
  );
  /*
  Deprecated
  PROCEDURE attach_bso_to_policy
  (
    par_product_id           NUMBER
   ,par_policy_id            p_policy.policy_id%TYPE
   ,par_pol_header_id        p_pol_header.policy_header_id%TYPE
   ,par_notice_num           as_bordero_load.notice_num%TYPE
   ,par_bso_series           NUMBER DEFAULT NULL
   ,par_raise_when_not_found BOOLEAN := FALSE
  );
  */

  -- Функция формировния строки истории БСО
  -- Параметры:
  -- par_bso_id    - id БСО
  -- par_policy_id - id версии договора страхования
  -- Байтин А.
  -- Перенес в спецификацию
  FUNCTION create_bso_history
  (
    par_bso_id    NUMBER
   ,par_policy_id NUMBER
  ) RETURN NUMBER;

  /*
  Создаем БСО для агента, переводим статусы и тп. Значительно быстрее чем делать это вручную через систему.
  */
  PROCEDURE create_bso_for_series
  (
    p_bso_series_num VARCHAR2
   ,p_start          VARCHAR2
   ,p_end            VARCHAR2
   ,p_ag_num         VARCHAR2 DEFAULT NULL
  );

  /*
  Процедура создания Типа БСО
  */
  PROCEDURE add_bso_series_to_bso_type
  (
    par_bso_type_brief      VARCHAR2
   ,par_series_name         VARCHAR2
   ,par_series_num          VARCHAR2
   ,par_t_policy_form_name  VARCHAR2
   ,par_chars_in_num        NUMBER DEFAULT 6
   ,par_is_default          NUMBER DEFAULT 1
   ,par_proposal_valid_days bso_series.proposal_valid_days%TYPE DEFAULT NULL
  );

  /*
  Процедура добавления серии БСО к типу БСО
  */
  PROCEDURE create_bso_type
  (
    par_name       VARCHAR2
   ,par_brief      VARCHAR2
   ,par_kind_brief VARCHAR2 DEFAULT 'Полис'
   ,par_check_ac   NUMBER DEFAULT 0
   ,par_check_mo   NUMBER DEFAULT 1
  );

  FUNCTION get_bso_series_id(par_bso_series_num bso_series.series_num%TYPE)
    RETURN bso_series.bso_series_id%TYPE;

  FUNCTION find_bso_by_num
  (
    par_policy_id     NUMBER
   ,par_bso_num       NUMBER
   ,par_bso_series_id NUMBER DEFAULT NULL
  ) RETURN NUMBER;

  /*
    Капля П.
    Создание записи в истории БСО
  */
  FUNCTION create_bso_history_rec
  (
    par_bso_id            bso.bso_id%TYPE
   ,par_bso_hist_type_id  bso_hist_type.bso_hist_type_id%TYPE
   ,par_bso_notes_type_id bso_notes_type.bso_notes_type_id%TYPE DEFAULT NULL
   ,par_hist_date         bso_hist.hist_date%TYPE DEFAULT SYSDATE
  ) RETURN bso_hist.bso_hist_id%TYPE;
  FUNCTION create_bso_history_rec
  (
    par_bso_id               bso.bso_id%TYPE
   ,par_bso_hist_type_brief  bso_hist_type.brief%TYPE
   ,par_bso_notes_type_brief bso_notes_type.brief%TYPE DEFAULT NULL
   ,par_hist_date            bso_hist.hist_date%TYPE DEFAULT SYSDATE
  ) RETURN bso_hist.bso_hist_id%TYPE;

  PROCEDURE create_bso_history_rec
  (
    par_bso_id               bso.bso_id%TYPE
   ,par_bso_hist_type_brief  bso_hist_type.brief%TYPE
   ,par_bso_notes_type_brief bso_notes_type.brief%TYPE DEFAULT NULL
   ,par_hist_date            bso_hist.hist_date%TYPE DEFAULT SYSDATE
  );

  /*
    Капля П.
    Процедура создания Акта утери БСО по распечатанным неиспользованным бланкам БСО
    Впервые было применено для партнера SGI, который печатал упстые бланки, 
    с которыми агенты шли по квартирам. Акты, по которым так и не были созданы договоры теряются
  */
  PROCEDURE loose_proposal_elapsed_bso(par_date DATE DEFAULT SYSDATE);
END pkg_bso;
/
CREATE OR REPLACE PACKAGE BODY ins.pkg_bso IS

  -- Тип для получения данных из курсора
  TYPE r_bso_norm IS RECORD(
     bso_series_id NUMBER
    ,bso_norm      NUMBER
    ,dep_id        NUMBER);

  TYPE t_bso_norm IS TABLE OF r_bso_norm INDEX BY BINARY_INTEGER;
  recordset t_bso_norm;

  TYPE t_message IS RECORD(
     message VARCHAR2(2000)
    ,state   VARCHAR2(5));
  g_message t_message;

  gc_pkg_name              CONSTANT pkg_trace.t_object_name := $$PLSQL_UNIT;
  gc_dummy_bso_holder_name CONSTANT contact.obj_name_orig%TYPE := 'Владелец Фиктивных Бсо';

  --
  -- Author  : ALEXEY.KATKEVICH
  -- Created : 08.04.2010 11:53:09
  -- Purpose : Возвращает стостояние работы нужна для пересылки сообщений в forms
  FUNCTION state(p_message OUT NOCOPY VARCHAR2) RETURN VARCHAR2 IS
    proc_name VARCHAR2(25) := 'State';
    v_state   VARCHAR2(10);
  BEGIN
    v_state   := g_message.state;
    p_message := g_message.message;
  
    g_message.state   := 'Ok'; --'Warn' --'Err'
    g_message.message := 'Нормальное заврешение процедуры';
  
    RETURN(v_state);
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM);
  END state;

  FUNCTION get_bso_dummy_contact_id RETURN contact.contact_id%TYPE IS
    v_contact_id contact.contact_id%TYPE;
  BEGIN
    SELECT contact_id
      INTO v_contact_id
      FROM contact c
     WHERE c.obj_name_orig = gc_dummy_bso_holder_name;
  
    RETURN v_contact_id;
  EXCEPTION
    WHEN no_data_found THEN
      ex.raise('Не удалось найти контакта Владельца Фиктивных БСО');
    WHEN too_many_rows THEN
      ex.raise('В системе найдено несколько контактов с служебным названием ' ||
               gc_dummy_bso_holder_name);
  END get_bso_dummy_contact_id;

  PROCEDURE check_serie_num
  (
    p_bso_ser IN NUMBER
   ,p_num     IN VARCHAR2
  ) IS
  BEGIN
    FOR rc IN (SELECT bs.chars_in_num
                 FROM bso_series bs
                WHERE bs.bso_series_id = p_bso_ser
                  AND nvl(bs.chars_in_num, 0) <> 0)
    LOOP
      IF length(p_num) <> rc.chars_in_num
      THEN
        raise_application_error(-20000
                               ,'Неправильное количество символов в № бланка ' || p_num ||
                                '. Должно быть ' || rc.chars_in_num);
      END IF;
    END LOOP;
  END;

  -- функция определения серии по и типа БСО по ИДИ
  FUNCTION get_type_s_name(p_bso_ser IN NUMBER) RETURN VARCHAR2 IS
    v_name VARCHAR2(150);
  BEGIN
    SELECT t.name || ' серия ' || s.series_name
      INTO v_name
      FROM ven_bso_type t
      JOIN ven_bso_series s
        ON (s.bso_type_id = t.bso_type_id)
     WHERE s.bso_series_id = p_bso_ser;
    RETURN v_name;
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20000
                             ,'Проверьте целостность БД (ven_bso_hist_type)');
  END;

  -- создание записи состояния БСО
  PROCEDURE proceed_one_num
  (
    p_num               IN VARCHAR2
   ,p_id                IN NUMBER
   ,p_is_created        NUMBER
   ,p_hist_type         IN OUT NUMBER
   ,p_reg_date          DATE
   ,p_contact_to        IN OUT NUMBER
   ,p_bso_series        NUMBER
   ,p_contact_from      NUMBER
   ,p_department        NUMBER
   ,v_department_from   NUMBER
   ,p_bso_notes_type_id NUMBER
  ) IS
    v_bso_id          NUMBER;
    v_hist_id         NUMBER;
    v_hist_num        NUMBER;
    v_count           NUMBER;
    v_rez             NUMBER := 0;
    v_doc_status      VARCHAR2(30);
    v_hist_date       DATE;
    p_p_name_hist     VARCHAR2(30);
    v_pr              NUMBER := 0;
    p_p_doc_templ     VARCHAR2(65);
    p_p_contact_co    NUMBER;
    p_p_department_to NUMBER;
    v_p_department    NUMBER;
  BEGIN
  
    v_p_department := p_department;
  
    SELECT c.contact_id INTO p_p_contact_co FROM contact c WHERE c.obj_name_orig = 'Склад Ц О';
  
    SELECT dep.department_id
      INTO p_p_department_to
      FROM department dep
     WHERE dep.name = 'Административно-хозяйственный  отдел';
  
    SELECT tp.brief
      INTO p_p_doc_templ
      FROM bso_document dc
          ,document     d
          ,doc_templ    tp
          ,bso_doc_cont cb
     WHERE dc.bso_document_id = d.document_id
       AND d.doc_templ_id = tp.doc_templ_id
       AND dc.bso_document_id = cb.bso_document_id
       AND cb.bso_doc_cont_id = p_id;
  
    SELECT doc.get_doc_status_brief(b.bso_document_id)
      INTO v_doc_status
      FROM bso_doc_cont b
     WHERE b.bso_doc_cont_id = p_id;
  
    --pkg_renlife_utils.tmp_log_writer('proceed_one_num = '||p_id||' '||p_hist_type||' '||p_bso_series);
    IF v_doc_status = 'NEW'
    THEN
    
      p_contact_to := p_contact_from;
    
      SELECT bht.bso_hist_type_id
        INTO p_hist_type
        FROM bso_hist_type bht
       WHERE bht.brief = 'Зарезервирован';
    
    END IF;
  
    -- если такого бланка еще не было, то создаем его
    IF p_is_created = 1
    THEN
      SELECT sq_bso.nextval INTO v_bso_id FROM dual;
      INSERT INTO bso (bso_id, bso_series_id, num) VALUES (v_bso_id, p_bso_series, p_num);
      -- Пиядин А. 239416 ФТ по штрих-кодированию
      pkg_barcode.bso_barcode_create(v_bso_id);
      -- если бланк на удаление, то проверка, чтобы он был предварительно списан
    ELSIF p_is_created = 2
    THEN
      BEGIN
        SELECT COUNT('1')
          INTO v_count
          FROM bso           b
              ,bso_hist      bh
              ,bso_hist_type bht
         WHERE b.num = p_num
           AND b.bso_series_id = p_bso_series
           AND bh.bso_hist_id = b.bso_hist_id
           AND bh.hist_type_id = bht.bso_hist_type_id
           AND bht.brief = 'Уничтожен'
           AND bh.bso_doc_cont_id <> p_id;
        IF v_count = 0
        THEN
          SELECT b.bso_id
            INTO v_bso_id
            FROM bso      b
                ,bso_hist bh
           WHERE b.num = p_num
             AND b.bso_series_id = p_bso_series
             AND bh.bso_hist_id = b.bso_hist_id
             AND EXISTS (SELECT '1' -- существует списание не утерянного или похощенного
                    FROM bso_doc_cont  bdc
                        ,document      d
                        ,doc_templ     dt
                        ,bso_hist_type bht
                   WHERE d.document_id = bdc.bso_document_id
                     AND b.num BETWEEN bdc.num_start AND nvl(bdc.num_end, bdc.num_start)
                     AND b.bso_series_id = bdc.bso_series_id
                     AND dt.doc_templ_id = d.doc_templ_id
                     AND bdc.bso_hist_type_id = bht.bso_hist_type_id
                     AND bht.brief NOT IN ('Утерян', 'Похищен')
                     AND dt.brief = 'СписаниеБСО');
        ELSE
          raise_application_error(-20000
                                 ,'Бланк ' || get_type_s_name(p_bso_series) || ' №' || p_num ||
                                  'был ранее уничтожен');
        END IF;
      EXCEPTION
        WHEN no_data_found THEN
          raise_application_error(-20000
                                 ,'Бланк ' || get_type_s_name(p_bso_series) || ' №' || p_num ||
                                  'необходимо предварительно списать');
      END;
    ELSE
      -- проверяем наличие бланка у источника
      -- не уничтоженного и не списанного бланка
      IF ((p_p_doc_templ = 'УтеряБСО' OR p_p_doc_templ = 'ИспорченныеБСО' OR
         p_p_doc_templ = 'СписаниеБСО' OR p_p_doc_templ = 'УничтожениеБСО') AND
         v_doc_status = 'CO_ACHIVE')
      THEN
        BEGIN
          SELECT b.bso_id
            INTO v_bso_id
            FROM bso b
           WHERE b.num = p_num
             AND b.bso_series_id = p_bso_series;
        
          p_contact_to   := p_p_contact_co;
          v_p_department := p_p_department_to;
        
        EXCEPTION
          WHEN no_data_found THEN
            raise_application_error(-20000
                                   ,'Бланк ' || get_type_s_name(p_bso_series) || ' №' || p_num ||
                                    ' не найден ');
            NULL;
        END;
      ELSE
      
        --pkg_renlife_utils.tmp_log_writer('p_p_doc_templ = '||p_p_doc_templ);
        --pkg_renlife_utils.tmp_log_writer('v_doc_status = '||v_doc_status);
        --pkg_renlife_utils.tmp_log_writer('p_contact_to = '||p_contact_to);
      
        IF (p_p_doc_templ = 'ПередачаБСО' OR p_p_doc_templ = 'ВозвратБСО')
           AND v_doc_status = 'CONFIRMED'
        THEN
          BEGIN
            SELECT b.bso_id
              INTO v_bso_id
              FROM bso           b
                  ,bso_hist_type bht
             WHERE b.num = p_num
               AND bht.bso_hist_type_id = b.hist_type_id
               AND bht.brief = 'Зарезервирован'
               AND b.bso_series_id = p_bso_series
               AND b.contact_id = p_contact_to;
          EXCEPTION
            WHEN no_data_found THEN
              raise_application_error(-20000
                                     ,'Бланк ' || get_type_s_name(p_bso_series) || ' №' || p_num ||
                                      ' не Зарезервирован для ' ||
                                      ent.obj_name(ent.id_by_brief('CONTACT'), p_contact_from));
              NULL;
          END;
        ELSE
          IF p_p_doc_templ = 'УничтожениеБСО'
          THEN
          
            BEGIN
              SELECT b.bso_id
                INTO v_bso_id
                FROM bso           b
                    ,bso_hist_type bht
               WHERE b.num = p_num
                 AND bht.bso_hist_type_id = b.hist_type_id
                 AND b.bso_series_id = p_bso_series
                    -- Байтин А.
                    -- Убрана привязка к контактам
                    --                   AND bh.contact_id = p_contact_from
                 AND (bht.brief IN ('Испорчен', 'Зарезервирован') OR EXISTS
                      (SELECT '1' -- существует предварительного списания
                         FROM bso_doc_cont  bdc
                             ,document      d
                             ,doc_templ     dt
                             ,bso_hist_type bht
                        WHERE d.document_id = bdc.bso_document_id
                          AND b.num BETWEEN bdc.num_start AND nvl(bdc.num_end, bdc.num_start)
                          AND b.bso_series_id = bdc.bso_series_id
                          AND dt.doc_templ_id = d.doc_templ_id
                          AND bdc.bso_hist_type_id = bht.bso_hist_type_id
                          AND (dt.brief = 'СписаниеБСО')
                          AND bdc.bso_doc_cont_id <> p_id));
            EXCEPTION
              WHEN no_data_found THEN
                raise_application_error(-20000
                                       ,'Бланк ' || get_type_s_name(p_bso_series) || ' №' || p_num ||
                                        ' нет в наличии у ' ||
                                        ent.obj_name(ent.id_by_brief('CONTACT'), p_contact_from));
                NULL;
            END;
          ELSIF p_p_doc_templ = 'ВосстановлениеБСО'
          THEN
            SELECT b.bso_id
              INTO v_bso_id
              FROM bso b
             WHERE b.num = p_num
               AND b.bso_series_id = p_bso_series;
          ELSE
            BEGIN
              SELECT b.bso_id
                INTO v_bso_id
                FROM bso           b
                    ,bso_hist_type bht
               WHERE b.num = p_num
                 AND bht.bso_hist_type_id = b.hist_type_id
                 AND b.bso_series_id = p_bso_series
                 AND b.contact_id = p_contact_from
                 AND NOT EXISTS
               (SELECT NULL
                        FROM bso_doc_cont   bdc
                            ,document       d
                            ,doc_templ      dt
                            ,bso_hist_type  bht
                            ,doc_status_ref dsr
                       WHERE d.document_id = bdc.bso_document_id
                         AND b.num BETWEEN bdc.num_start AND nvl(bdc.num_end, bdc.num_start)
                         AND b.bso_series_id = bdc.bso_series_id
                         AND dt.doc_templ_id = d.doc_templ_id
                         AND bdc.bso_hist_type_id = bht.bso_hist_type_id
                         AND (dt.brief = 'УничтожениеБСО')
                         AND bdc.bso_doc_cont_id <> p_id
                         AND d.doc_status_ref_id != dsr.doc_status_ref_id
                         AND dsr.brief = 'ANNULATED');
            EXCEPTION
              WHEN no_data_found THEN
                raise_application_error(-20000
                                       ,'Бланк ' || get_type_s_name(p_bso_series) || ' №' || p_num ||
                                        ' нет в наличии у ' ||
                                        ent.obj_name(ent.id_by_brief('CONTACT'), p_contact_from));
            END;
          END IF;
        
        END IF;
      
      END IF;
    END IF;
  
    --проверка списания БСО у действующего договора
    BEGIN
      SELECT COUNT(1)
        INTO v_count
        FROM bso b --, bso_hist bh
       WHERE b.num = p_num
         AND b.bso_series_id = p_bso_series
         AND doc.get_doc_status_brief(b.policy_id) = 'CURRENT'
         AND EXISTS (SELECT '1'
                FROM bso_doc_cont bdc
                    ,document     d
                    ,doc_templ    dt
               WHERE d.document_id = bdc.bso_document_id
                 AND b.num BETWEEN bdc.num_start AND nvl(bdc.num_end, bdc.num_start)
                 AND b.bso_series_id = bdc.bso_series_id
                 AND dt.doc_templ_id = d.doc_templ_id
                 AND dt.brief = 'СписаниеБСО');
      IF v_count > 0
      THEN
        RAISE too_many_rows;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        raise_application_error(-20000
                               ,'Вы не можете списать бланк по действующей версии договора.');
    END;
  
    -- проверка наличия дат больше вводимой
    BEGIN
      SELECT 3
        INTO v_rez
        FROM dual
       WHERE EXISTS (SELECT '1'
                FROM bso      b
                    ,bso_hist bh
               WHERE b.bso_id = v_bso_id
                 AND bh.bso_id = b.bso_id
                 AND bh.hist_date > p_reg_date);
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;
  
    --закрыто
  
    /*IF v_rez <> 0 THEN
      RAISE_APPLICATION_ERROR(-20000,
                              'Существует дата изменения состояния БСО больше даты АКТА ' ||
                              p_reg_date);
    END IF;*/
  
    -- проверка на невозможность создавать движение БСО датой,
    -- позднее чем БСО был "Использован".
    -- vustinov, 09/07/2007
    BEGIN
      SELECT hist_date
        INTO v_hist_date
        FROM bso_hist
       WHERE hist_type_id =
             (SELECT bso_hist_type_id FROM bso_hist_type WHERE brief = 'Использован')
         AND bso_id = v_bso_id;
    
    EXCEPTION
      WHEN OTHERS THEN
        v_hist_date := NULL;
    END;
    IF v_hist_date < p_reg_date
    THEN
      -- анализ существования "Испорчен" после 'Использован' => разрешить возврат
      -- Shidlovskaya 08.08.2007
    
      -- opatsan --
      -- SELECT 1 INTO v_pr FROM dual
      SELECT COUNT(*)
        INTO v_pr
        FROM dual
       WHERE EXISTS (SELECT '1'
                FROM bso_hist h
                JOIN bso_hist_type t
                  ON (t.bso_hist_type_id = h.hist_type_id AND t.brief = 'Испорчен')
               WHERE h.hist_date > v_hist_date
                 AND h.bso_id = v_bso_id);
      IF v_pr = 1
      THEN
      
        SELECT 2
          INTO v_pr
          FROM dual
         WHERE EXISTS (SELECT '1'
                  FROM bso_hist_type t
                 WHERE t.bso_hist_type_id = p_hist_type
                   AND t.brief = 'Возвращен');
      
      END IF;
      IF v_pr = 1
      THEN
        raise_application_error(-20000
                               ,'Для испорченных БСО разрешен только Возврат');
      
        /*ELSIF v_pr=0 THEN
        RAISE_APPLICATION_ERROR(-20000,
                            'Дата использования БСО меньше даты АКТА ' ||
                            p_reg_date);*/
      ELSE
        NULL;
      END IF;
    
    END IF;
  
    -- ид записи состояния бланка
    SELECT sq_bso_hist.nextval INTO v_hist_id FROM dual;
    -- № записи состояния бланка
    SELECT nvl(MAX(b.num), 0) + 1 INTO v_hist_num FROM bso_hist b WHERE b.bso_id = v_bso_id;
    --пусть будет контакт, если даже мы списали или уничтожили
    IF (p_p_doc_templ = 'УтеряБСО' OR p_p_doc_templ = 'ИспорченныеБСО' OR
       p_p_doc_templ = 'СписаниеБСО' OR p_p_doc_templ = 'УничтожениеБСО')
    THEN
      p_contact_to   := p_contact_from;
      v_p_department := v_department_from;
    END IF;
    -- записываем состояние БСО
    INSERT INTO bso_hist
      (bso_hist_id
      ,bso_id
      ,hist_date
      ,contact_id
      ,hist_type_id
      ,num
      ,bso_doc_cont_id
      ,department_id
      ,bso_notes_type_id
      ,reg_date)
    VALUES
      (v_hist_id
      ,v_bso_id
      ,p_reg_date
      ,p_contact_to
      ,p_hist_type
      ,v_hist_num
      ,p_id
      ,v_p_department
      ,p_bso_notes_type_id
      ,SYSDATE);
    UPDATE bso b
       SET b.bso_hist_id  = v_hist_id
          ,b.hist_type_id = p_hist_type
          ,b.contact_id   = p_contact_to
     WHERE b.bso_id = v_bso_id;
  
    -- Пиядин А. 239416 ФТ по штрих-кодированию
    IF p_is_created = 1
    THEN
      pkg_barcode.bso_barcode_create(v_bso_id);
    END IF;
  
  EXCEPTION
    WHEN no_data_found THEN
      raise_application_error(-20000
                             ,'Бланк ' || get_type_s_name(p_bso_series) || ' №' || p_num ||
                              ' не существует.');
    WHEN dup_val_on_index THEN
      raise_application_error(-20000
                             ,'Бланк ' || get_type_s_name(p_bso_series) || ' №' || p_num ||
                              ' уже существует.');
  END;

  -- генерация номеров бланков по диапазону и генерация состояний этих бланков
  PROCEDURE gen_num
  (
    p_num_start IN VARCHAR2
   ,p_num_end   IN VARCHAR2
   ,p_id        IN NUMBER
  ) IS
    v_start VARCHAR2(150);
    v_end   VARCHAR2(150);
    n_start NUMBER;
    n_end   NUMBER;
    v_pref  VARCHAR2(150);
    m_len   NUMBER;
    p_len   NUMBER;
    i       NUMBER := 0;
  
    v_bso_series        NUMBER;
    v_bso_series_num    NUMBER;
    v_chars_in_num      NUMBER;
    v_is_created        NUMBER(1);
    v_hist_type         NUMBER;
    v_reg_date          DATE;
    v_contact_to        NUMBER;
    v_contact_from      NUMBER;
    v_department        NUMBER;
    v_department_from   NUMBER;
    v_bso_notes_type_id NUMBER;
  
    FUNCTION correct_num
    (
      p_ser NUMBER
     ,p_num VARCHAR2
    ) RETURN VARCHAR2 IS
      v_num VARCHAR2(10);
    BEGIN
      IF length(p_num) = 7
      THEN
        --для новых серий с последним контрольным символом
        v_num := substr(pkg_xx_pol_ids.cre_new_ids(p_ser, substr(p_num, 1, 6)), 4);
      ELSE
        v_num := p_num;
      END IF;
    
      RETURN v_num;
    EXCEPTION
      WHEN OTHERS THEN
        RETURN p_num;
    END correct_num;
  
  BEGIN
    -- pkg_renlife_utils.tmp_log_writer('gen_num = сюда чтоль тоже зашли?');
    SELECT bdc.bso_series_id
          ,(SELECT bs.series_num FROM bso_series bs WHERE bs.bso_series_id = bdc.bso_series_id)
          ,(SELECT bs.chars_in_num FROM bso_series bs WHERE bs.bso_series_id = bdc.bso_series_id)
          ,dtht.is_bso_created
          ,dtht.bso_hist_type_id
          ,d.reg_date
          ,d.contact_to_id
          ,d.contact_from_id
          ,d.department_to_id
          ,d.department_from_id
          ,bdc.bso_notes_type_id
      INTO v_bso_series
          ,v_bso_series_num
          ,v_chars_in_num
          ,v_is_created
          ,v_hist_type
          ,v_reg_date
          ,v_contact_to
          ,v_contact_from
          ,v_department
          ,v_department_from
          ,v_bso_notes_type_id
      FROM bso_doc_cont bdc
     INNER JOIN ven_bso_document d
        ON d.bso_document_id = bdc.bso_document_id
     INNER JOIN bso_dtempl_hist_type dtht
        ON d.doc_templ_id = dtht.doc_templ_id
       AND bdc.bso_hist_type_id = dtht.bso_hist_type_id
     WHERE bdc.bso_doc_cont_id = p_id;
    -- pkg_renlife_utils.tmp_log_writer('gen_num = '||' '||v_bso_series||' '||v_hist_type);
    IF p_num_end IS NULL
    THEN
      proceed_one_num(correct_num(v_bso_series_num, p_num_start)
                     ,p_id
                     ,v_is_created
                     ,v_hist_type
                     ,v_reg_date
                     ,v_contact_to
                     ,v_bso_series
                     ,v_contact_from
                     ,v_department
                     ,v_department_from
                     ,v_bso_notes_type_id);
    ELSE
      IF v_chars_in_num = 7
      THEN
        --Для новых бланков, отрезаем последний контрольный символ
        v_start := substr(p_num_start, 1, v_chars_in_num - 1);
        v_end   := substr(p_num_end, 1, v_chars_in_num - 1);
      ELSE
        v_start := p_num_start;
        v_end   := p_num_end;
      END IF;
    
      m_len   := greatest(length(v_start), length(v_end));
      v_start := lpad(p_num_start, m_len);
      v_end   := lpad(p_num_end, m_len);
    
      WHILE i < m_len
      LOOP
        i := i + 1;
        IF substr(v_start, 1, i) <> substr(v_end, 1, i)
        THEN
          EXIT;
        END IF;
      END LOOP;
      v_pref := substr(v_start, 1, i - 1);
      p_len  := m_len - nvl(length(v_pref), 0);
    
      n_start := to_number(substr(v_start, i));
      n_end   := to_number(substr(v_end, i));
      FOR i IN n_start .. n_end
      LOOP
        IF v_chars_in_num = 7
        THEN
          proceed_one_num(substr(pkg_xx_pol_ids.cre_new_ids(v_bso_series_num
                                                           ,v_pref || lpad(i, p_len, '0'))
                                ,4)
                         ,p_id
                         ,v_is_created
                         ,v_hist_type
                         ,v_reg_date
                         ,v_contact_to
                         ,v_bso_series
                         ,v_contact_from
                         ,v_department
                         ,v_department_from
                         ,v_bso_notes_type_id);
        ELSE
          --  pkg_renlife_utils.tmp_log_writer(' начинаем еще proceed_one_num');
          proceed_one_num(v_pref || lpad(i, p_len, '0')
                         ,p_id
                         ,v_is_created
                         ,v_hist_type
                         ,v_reg_date
                         ,v_contact_to
                         ,v_bso_series
                         ,v_contact_from
                         ,v_department
                         ,v_department_from
                         ,v_bso_notes_type_id);
        END IF;
      
      END LOOP;
    END IF;
  END;

  -- очистка состояний бланков по содержанию документа
  PROCEDURE clear_cont(p_cont_id IN NUMBER) IS
    v_bso_hist_id   NUMBER;
    v_bso_in_policy INT;
  BEGIN
    FOR rec IN (SELECT bh.bso_id
                      ,b.bso_hist_id curr_hist_id
                      ,bh.bso_hist_id
                      ,bh.num
                      ,s.series_name || '-' || b.num bso_num
                  FROM bso b
                  JOIN bso_hist bh
                    ON (b.bso_id = bh.bso_id)
                  JOIN bso_series s
                    ON (s.bso_series_id = b.bso_series_id)
                 WHERE bh.bso_doc_cont_id = p_cont_id
                 ORDER BY bso_id
                         ,bh.num DESC)
    LOOP
      --pkg_renlife_utils.tmp_log_writer('clear_cont = '||rec.bso_num||' '||rec.curr_hist_id||' '||rec.bso_hist_id);                                  
      BEGIN
        SELECT COUNT(1)
          INTO v_bso_in_policy
          FROM bso          b
              ,p_pol_header ph
              ,p_policy     p
         WHERE ph.policy_header_id = p.pol_header_id
           AND p.policy_id = b.policy_id
           AND b.pol_header_id = ph.policy_header_id
           AND b.bso_id = rec.bso_id;
        --если bso есть в договоре страхования, то не очищаем историю
        IF v_bso_in_policy = 0
        THEN
          BEGIN
            SELECT b.bso_hist_id INTO v_bso_hist_id FROM bso b WHERE b.bso_id = rec.bso_id;
          EXCEPTION
            WHEN OTHERS THEN
              v_bso_hist_id := NULL;
          END;
        
          IF v_bso_hist_id <> rec.bso_hist_id
          THEN
            raise_application_error(-20000
                                   ,'Бланк ' || rec.bso_num || ' не редактируется. БСО ' ||
                                    ' используется в документах, созданных позднее ');
          ELSE
            IF rec.num = 1
            THEN
              DELETE FROM bso b WHERE b.bso_id = rec.bso_id;
            ELSE
              UPDATE bso b
                 SET (b.bso_hist_id, b.hist_type_id, b.contact_id) =
                     (SELECT bh.bso_hist_id
                            ,bh.hist_type_id
                            ,bh.contact_id
                        FROM bso_hist bh
                       WHERE bh.bso_id = b.bso_id
                         AND bh.num = rec.num - 1)
               WHERE b.bso_id = rec.bso_id;
            END IF;
            DELETE FROM bso_hist bh WHERE bh.bso_hist_id = rec.bso_hist_id;
          END IF;
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          raise_application_error(-20000
                                 ,'Ошибка при анулировании. Бланк БСО ' || rec.bso_num || ' ' ||
                                  SQLERRM);
      END;
    END LOOP;
  END;

  -- добавление содержимого документа БСО
  PROCEDURE insert_cont
  (
    p_doc_id            IN NUMBER
   ,p_doc_cont_id       IN NUMBER
   ,p_start             IN VARCHAR2
   ,p_end               IN VARCHAR2
   ,p_bso_series        IN NUMBER
   ,p_bso_hist_type     IN NUMBER
   ,p_bso_notes_type_id IN NUMBER
   ,p_bso_count         IN NUMBER
   ,p_num_comment       IN VARCHAR2
  ) IS
    v_c  NUMBER;
    v_id bso_doc_cont.bso_doc_cont_id%TYPE;
  BEGIN
    IF length(p_start) <> length(p_end)
    THEN
      raise_application_error(-20000
                             ,'Количество значащих цифр должно совпадать');
    END IF;
    IF p_start > nvl(p_end, p_start)
    THEN
      raise_application_error(-20000
                             ,'Первый номер должен быть меньше последнего');
    END IF;
    check_serie_num(p_bso_series, p_start);
  
    SELECT COUNT(*)
      INTO v_c
      FROM document d
     WHERE d.document_id = p_doc_id
       AND d.doc_templ_id =
           (SELECT dt.doc_templ_id FROM doc_templ dt WHERE dt.brief = 'ФормированиеБСО');
    --Проверка только для Формирования БСО
    IF v_c > 0
    THEN
      check_cre_bdc(p_bso_series, p_start, p_end);
    END IF;
  
    SELECT nvl(p_doc_cont_id, sq_bso_doc_cont.nextval) INTO v_id FROM dual;
  
    INSERT INTO bso_doc_cont
      (bso_doc_cont_id
      ,bso_document_id
      ,num_start
      ,num_end
      ,bso_series_id
      ,bso_hist_type_id
      ,bso_notes_type_id
      ,bso_count
      ,num_comment)
    VALUES
      (v_id
      ,p_doc_id
      ,p_start
      ,p_end
      ,p_bso_series
      ,p_bso_hist_type
      ,p_bso_notes_type_id
      ,p_bso_count
      ,p_num_comment);
    --gen_num(p_start, p_end, p_doc_cont_id);
  END;

  -- изменение содержимого документа БСО
  PROCEDURE update_cont
  (
    p_doc_cont_id       IN NUMBER
   ,p_start             IN VARCHAR2
   ,p_end               IN VARCHAR2
   ,p_bso_series        IN NUMBER
   ,p_bso_hist_type     IN NUMBER
   ,p_bso_notes_type_id IN NUMBER
   ,p_bso_count         IN NUMBER
   ,p_num_comment       IN VARCHAR2
  ) IS
    v_rec bso_doc_cont%ROWTYPE;
  BEGIN
    IF length(p_start) <> length(p_end)
    THEN
      raise_application_error(-20000
                             ,'Количество значащих цифр должно совпадать');
    END IF;
    IF p_start > nvl(p_end, p_start)
    THEN
      raise_application_error(-20000
                             ,'Первый номер должен быть меньше последнего');
    END IF;
    check_serie_num(p_bso_series, p_start);
    SELECT * INTO v_rec FROM bso_doc_cont WHERE bso_doc_cont_id = p_doc_cont_id;
    IF v_rec.num_start <> p_start
       OR nvl(v_rec.num_end, 'nodatafound') <> nvl(p_end, 'nodatafound')
       OR v_rec.bso_series_id <> p_bso_series
       OR nvl(v_rec.bso_notes_type_id, 0) <> nvl(p_bso_notes_type_id, 0)
    THEN
      UPDATE bso_doc_cont
         SET (num_start
            ,num_end
            ,bso_series_id
            ,bso_hist_type_id
            ,bso_notes_type_id
            ,bso_count
            ,num_comment) =
             (SELECT p_start
                    ,p_end
                    ,p_bso_series
                    ,p_bso_hist_type
                    ,p_bso_notes_type_id
                    ,p_bso_count
                    ,p_num_comment
                FROM dual)
       WHERE bso_doc_cont_id = p_doc_cont_id;
    
      clear_cont(p_doc_cont_id);
      --gen_num(p_start, p_end, p_doc_cont_id);
    END IF;
  END;

  PROCEDURE insert_bso_document
  (
    par_doc_templ_id       doc_templ.doc_templ_id%TYPE
   ,par_contact_from_id    bso_document.contact_from_id%TYPE
   ,par_contact_to_id      bso_document.contact_to_id%TYPE
   ,par_department_from_id bso_document.department_from_id%TYPE
   ,par_department_to_id   bso_document.department_to_id%TYPE
   ,par_allow_over_norm    bso_document.allow_over_norm%TYPE
   ,par_num                document.num%TYPE DEFAULT NULL
   ,par_reg_date           document.reg_date%TYPE DEFAULT SYSDATE
   ,par_bso_document_id    OUT bso_document.bso_document_id%TYPE
  ) IS
    v_initial_status doc_status_ref.doc_status_ref_id%TYPE;
  BEGIN
    SELECT sq_document.nextval INTO par_bso_document_id FROM dual;
  
    SELECT dts.doc_status_ref_id
      INTO v_initial_status
      FROM doc_templ_status dts
     WHERE dts.doc_templ_id = par_doc_templ_id
       AND dts.order_num = 1;
    /**  
    Создание Акта дмижения БСО
    */
  
    INSERT INTO ven_bso_document
      (bso_document_id
      ,doc_templ_id
      ,num
      ,reg_date
      ,allow_over_norm
      ,contact_from_id
      ,contact_to_id
      ,department_from_id
      ,department_to_id)
    VALUES
      (par_bso_document_id
      ,par_doc_templ_id
      ,nvl(par_num, par_bso_document_id)
      ,par_reg_date
      ,par_allow_over_norm
      ,par_contact_from_id
      ,par_contact_to_id
      ,par_department_from_id
      ,par_department_to_id);
    /**   
    Автоматический перевод статуса в статус с порядком сортировки 1
    */
  
    doc.set_doc_status(p_doc_id                => par_bso_document_id
                      ,p_status_id             => v_initial_status
                      ,p_status_date           => par_reg_date
                      ,p_status_change_type_id => dml_status_change_type.get_id_by_brief('AUTO')
                      ,p_note                  => 'Создание документа');
  END insert_bso_document;

  PROCEDURE insert_bso_document
  (
    par_doc_templ_id       doc_templ.doc_templ_id%TYPE
   ,par_contact_from_id    bso_document.contact_from_id%TYPE
   ,par_contact_to_id      bso_document.contact_to_id%TYPE
   ,par_department_from_id bso_document.department_from_id%TYPE
   ,par_department_to_id   bso_document.department_to_id%TYPE
   ,par_allow_over_norm    bso_document.allow_over_norm%TYPE
   ,par_num                document.num%TYPE DEFAULT NULL
   ,par_reg_date           document.reg_date%TYPE DEFAULT SYSDATE
  ) IS
    v_bso_document_id bso_document.bso_document_id%TYPE;
  BEGIN
    insert_bso_document(par_doc_templ_id       => par_doc_templ_id
                       ,par_contact_from_id    => par_contact_from_id
                       ,par_contact_to_id      => par_contact_to_id
                       ,par_department_from_id => par_department_from_id
                       ,par_department_to_id   => par_department_to_id
                       ,par_allow_over_norm    => par_allow_over_norm
                       ,par_num                => par_num
                       ,par_reg_date           => par_reg_date
                       ,par_bso_document_id    => v_bso_document_id);
  
  END insert_bso_document;

  -- удаление содержимого документа БСО
  PROCEDURE delete_cont(p_doc_cont_id IN NUMBER) IS
  BEGIN
    clear_cont(p_doc_cont_id);
    DELETE FROM bso_doc_cont b WHERE b.bso_doc_cont_id = p_doc_cont_id;
  END;

  -- удаление документа БСО
  PROCEDURE delete_document(p_document_id IN NUMBER) IS
  BEGIN
    FOR rec IN (SELECT dc.bso_doc_cont_id FROM bso_doc_cont dc WHERE dc.bso_document_id = p_document_id)
    LOOP
      delete_cont(rec.bso_doc_cont_id);
    END LOOP;
    DELETE FROM ven_bso_document bd WHERE bd.bso_document_id = p_document_id;
  END;

  -- анулирование документа БСО
  PROCEDURE bso_act_annulated(p_document_id IN NUMBER) IS
  BEGIN
    FOR rec IN (SELECT dc.bso_doc_cont_id FROM bso_doc_cont dc WHERE dc.bso_document_id = p_document_id)
    LOOP
      clear_cont(rec.bso_doc_cont_id);
    END LOOP;
  END;

  -- блокировака содержимого документа БСО
  PROCEDURE lock_cont(p_doc_cont_id IN NUMBER) IS
    v_id NUMBER;
  BEGIN
    SELECT b.bso_doc_cont_id
      INTO v_id
      FROM bso_doc_cont b
     WHERE b.bso_doc_cont_id = p_doc_cont_id
       FOR UPDATE NOWAIT;
  END;

  FUNCTION get_bso_doc_num(p_bso_doc_templ IN NUMBER) RETURN VARCHAR2 IS
    v_ret VARCHAR2(150);
  BEGIN
    v_ret := p_bso_doc_templ;
    RETURN v_ret;
  END;

  PROCEDURE check_all_bso_on_policy
  (
    par_policy_id IN NUMBER
   ,par_is_set    IN NUMBER DEFAULT 0
   ,par_is_clear  IN NUMBER DEFAULT 0
  ) IS
  BEGIN
    FOR rc IN (SELECT bt.brief
                 FROM ven_t_product_bso_types t
                     ,ven_bso_type            bt
                     ,ven_p_policy            p
                     ,ven_p_pol_header        ph
                WHERE t.t_product_id = ph.product_id
                  AND t.bso_type_id = bt.bso_type_id
                  AND ph.policy_header_id = p.pol_header_id
                  AND p.policy_id = par_policy_id
                  AND ph.is_park = 0)
    LOOP
      check_bso_on_policy(par_policy_id, par_is_set, par_is_clear, rc.brief);
    END LOOP;
  END;
  PROCEDURE check_bso_on_policy
  (
    par_policy_id      IN NUMBER
   ,par_is_set         IN NUMBER DEFAULT 0
   ,par_is_clear       IN NUMBER DEFAULT 0
   ,par_bso_type_brief IN VARCHAR2 DEFAULT 'ОСАГО'
  ) IS
    v_policy        ven_p_policy%ROWTYPE;
    v_pol_head      ven_p_pol_header%ROWTYPE;
    v_prod_bso_type NUMBER;
    v_bso           bso%ROWTYPE;
    v_count         NUMBER;
  BEGIN
    -- невозможно одновременно установить и очистить БСО в полисе
    -- ОШИБКА
    IF par_is_set = 1
       AND par_is_clear = 1
    THEN
      raise_application_error(-20000, 'check_bso_on_policy parameter error');
    END IF;
    -- запись версии полиса
    SELECT * INTO v_policy FROM ven_p_policy p WHERE p.policy_id = par_policy_id;
    -- запись заголовка полиса
    SELECT *
      INTO v_pol_head
      FROM ven_p_pol_header p
     WHERE p.policy_header_id = v_policy.pol_header_id;
    BEGIN
      -- Проверяем есть ли такой тип БСО на продукте, если нет, то конец
      SELECT t.bso_type_id
        INTO v_prod_bso_type
        FROM ven_t_product_bso_types t
            ,ven_bso_type            bt
       WHERE t.t_product_id = v_pol_head.product_id
         AND t.bso_type_id = bt.bso_type_id
         AND bt.brief = par_bso_type_brief
         AND rownum < 2;
      BEGIN
        -- ищем бланк по серии и номеру и типу, если нет - генерится exception, что БСО не найден
        SELECT b.*
          INTO v_bso
          FROM bso        b
              ,bso_series bs
         WHERE bs.bso_type_id = v_prod_bso_type
           AND b.bso_series_id = bs.bso_series_id
           AND bs.series_name =
               decode(par_bso_type_brief, 'ОСАГО', v_policy.pol_ser, v_policy.osago_sign_ser)
           AND b.num =
               decode(par_bso_type_brief, 'ОСАГО', v_policy.pol_num, v_policy.osago_sign_num);
      
        -- если бланк уже используется в другом полисе
        -- ОШИБКА
        IF nvl(v_bso.pol_header_id, v_pol_head.policy_header_id) <> v_pol_head.policy_header_id
        THEN
          raise_application_error(-20000, 'БСО привязан к другому полису');
        END IF;
      
        -- если необходимо установить БСО для полиса и он еще не использовался
        IF par_is_set = 1
           AND v_bso.pol_header_id IS NULL
        THEN
          UPDATE bso b
             SET b.pol_header_id = v_pol_head.policy_header_id
           WHERE b.bso_id = v_bso.bso_id;
        END IF;
      
        -- если необходимо снять БСО с полиса
        IF par_is_clear = 1
        THEN
        
          -- если этот БСО не использовался в других версиях этого полиса
          SELECT COUNT(*)
            INTO v_count
            FROM p_policy p
           WHERE p.pol_header_id = v_pol_head.policy_header_id
             AND p.policy_id <> par_policy_id
             AND doc.get_doc_status_brief(p.policy_id) = 'CURRENT'
             AND (par_bso_type_brief = 'ОСАГО' AND p.pol_ser = v_policy.pol_ser AND
                 p.pol_num = v_policy.pol_num OR
                 par_bso_type_brief = 'СЗОСАГО' AND p.osago_sign_ser = v_policy.osago_sign_ser AND
                 p.osago_sign_num = v_policy.osago_sign_num);
        
          IF v_count = 0
          THEN
            UPDATE bso b SET b.pol_header_id = NULL WHERE b.bso_id = v_bso.bso_id;
          END IF;
        END IF;
      
      EXCEPTION
        WHEN no_data_found THEN
          IF par_is_clear = 0
          THEN
            raise_application_error(-20000, 'БСО не найден');
          END IF;
      END;
    EXCEPTION
      WHEN no_data_found THEN
        NULL;
    END;
  
  END;

  FUNCTION count_bso_to_contact(p_contact_id IN NUMBER) RETURN NUMBER IS
    v_count NUMBER;
  BEGIN
    SELECT COUNT(b.bso_id)
      INTO v_count
      FROM bso      b
          ,bso_hist bh
     WHERE b.bso_id = bh.bso_id
       AND b.contact_id = p_contact_id
       AND EXISTS (SELECT '1'
              FROM bso_hist_type t
             WHERE t.bso_hist_type_id = b.hist_type_id
               AND t.brief IN ('Выдан', 'Передан', 'PRINTED_EMPTY'));
    RETURN v_count;
  END count_bso_to_contact;

  -- Анализ привязки конкретного БСО к договору
  FUNCTION check_relation_bso_pol
  (
    p_bso_typ_br IN VARCHAR2 DEFAULT 'ОСАГО'
   ,p_bso_ser    IN VARCHAR2 DEFAULT 'ААА'
   ,p_bso_num    IN VARCHAR2
   ,p_policy_id  IN NUMBER
  ) RETURN NUMBER IS
  
    v_bso      ven_bso%ROWTYPE;
    v_pol_head ven_p_pol_header%ROWTYPE;
    v_pol      ven_p_policy%ROWTYPE;
    v_count    NUMBER;
    v_rez      NUMBER; -- результат проверки
  
  BEGIN
    v_rez   := 0;
    v_count := 0;
    -- определение БСО, заголовка полиси, полиси
    BEGIN
      -- запись бсо
      SELECT b.*
        INTO v_bso
        FROM ven_bso        b
            ,ven_bso_series s
            ,ven_bso_type   t
       WHERE s.bso_series_id = b.bso_series_id
         AND t.bso_type_id = s.bso_type_id
         AND b.num = p_bso_num
         AND s.series_name = p_bso_ser
         AND t.brief = p_bso_typ_br;
    EXCEPTION
      WHEN no_data_found THEN
        v_rez := 1;
        RETURN(v_rez); --'БСО не найден'
      WHEN too_many_rows THEN
        v_rez := 99;
        RETURN(v_rez); -- 'Проверьте целостность БД (bso)'
    END;
    BEGIN
      -- запись полиси
      SELECT * INTO v_pol FROM ven_p_policy p WHERE p.policy_id = p_policy_id;
      -- запись заголовка полиса
      SELECT * INTO v_pol_head FROM ven_p_pol_header p WHERE p.policy_header_id = v_pol.pol_header_id;
    EXCEPTION
      WHEN no_data_found THEN
        v_rez := 2;
        RETURN(v_rez); -- 'Договор не найден'
      WHEN too_many_rows THEN
        v_rez := 99;
        RETURN(v_rez); -- 'Проверьте целостность БД (policy)'
    END;
  
    IF nvl(v_bso.pol_header_id, v_pol.pol_header_id) <> v_pol.pol_header_id
    THEN
      raise_application_error(-20000, 'БСО привязан к другому полису');
    ELSIF nvl(v_bso.policy_id, v_pol.policy_id) <> v_pol.policy_id
    THEN
      raise_application_error(-20000
                             ,'БСО привязан к другой версии полиса');
    END IF;
  
    -- проверка принадлежности БСО - продукту
    SELECT COUNT(*)
      INTO v_count
      FROM ven_bso_type            bt
          ,ven_t_product_bso_types pt
     WHERE pt.bso_type_id = bt.bso_type_id
       AND pt.t_product_id = v_pol_head.product_id
       AND bt.brief = p_bso_typ_br;
    -- признак проверки
    IF v_count > 0
    THEN
      v_rez := 0;
    ELSE
      v_rez := 3; -- БСО не принадлежит продукту
      RETURN(v_rez);
    END IF;
    v_count := 0;
    -- проверка количества БСО по данному типу, уже привязанных к договору (если не группа)
    BEGIN
      SELECT COUNT(*)
        INTO v_count
        FROM bso           b
            ,bso_hist_type bht
       WHERE b.hist_type_id = bht.bso_hist_type_id
         AND bht.brief IN ('Использован')
         AND b.policy_id = p_policy_id;
    EXCEPTION
      WHEN no_data_found THEN
        v_count := 0;
    END;
    -- признак проверки
    IF v_rez = 0
       AND (v_count = 0 AND nvl(v_pol_head.is_park, 0) = 0)
    THEN
      v_rez := 0;
    ELSIF v_rez = 0
          AND (v_pol_head.is_park = 1)
    THEN
      v_rez := 0;
    ELSE
      v_rez := 4; --колич. по данному типу БСО (не группа)
      RETURN(v_rez);
    END IF;
    -- анализируем существующую привязку данного БСО
    IF v_rez = 0
       AND (v_bso.pol_header_id <> 0)
    THEN
      IF nvl(v_bso.pol_header_id, v_pol.pol_header_id) <> v_pol.pol_header_id
      THEN
        v_rez := 5; -- 'БСО привязан к другому полису'
        RETURN(v_rez);
      ELSIF nvl(v_bso.policy_id, v_pol.policy_id) <> v_pol.policy_id
      THEN
        v_rez := 6; -- 'БСО привязан к другой версии полиса'
        RETURN(v_rez);
      END IF;
    END IF;
    IF v_rez = 0
    THEN
      -- анализируем настоящее состояние данного БСО
      v_count := 0;
      SELECT COUNT(*)
        INTO v_count
        FROM ven_bso           b
            ,ven_bso_hist_type bht
       WHERE b.bso_id = v_bso.bso_id
         AND b.hist_type_id = bht.bso_hist_type_id
         AND bht.brief IN ('Использован'
                          ,'Устарел'
                          ,'Похищен'
                          ,'Уничтожен'
                          ,'Испорчен'
                          ,'Утерян');
      IF v_count > 0
      THEN
        v_rez := 7; -- состояние БСО не позволяет работать с ним
      END IF;
    END IF;
    RETURN(v_rez);
  
  END;

  -- Создание строки состояния БСО при привязке его к договору
  PROCEDURE create_relation_bso_pol
  (
    p_bso_typ_br IN VARCHAR2 DEFAULT 'ОСАГО'
   ,p_bso_ser    IN VARCHAR2 DEFAULT 'ААА'
   ,p_bso_num    IN VARCHAR2
   ,p_policy_id  IN NUMBER
  ) IS
    v_bso  ven_bso%ROWTYPE;
    v_hist bso_hist%ROWTYPE;
    v_pol  ven_p_policy%ROWTYPE;
  
  BEGIN
    -- определение БСО, полиси
    BEGIN
      -- запись бсо
      SELECT b.*
        INTO v_bso
        FROM ven_bso        b
            ,ven_bso_series s
            ,ven_bso_type   t
       WHERE s.bso_series_id = b.bso_series_id
         AND t.bso_type_id = s.bso_type_id
         AND b.num = p_bso_num
         AND s.series_name = p_bso_ser
         AND t.brief = p_bso_typ_br;
    
      IF p_bso_typ_br = 'ОСАГО'
      THEN
        UPDATE bso b SET b.is_pol_num = 1 WHERE b.bso_id = v_bso.bso_id;
      END IF;
    
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20001, 'БСО не найден');
      WHEN too_many_rows THEN
        raise_application_error(-20002, 'Проверьте целостность БД (bso)');
    END;
    BEGIN
      -- запись полиси
      SELECT * INTO v_pol FROM ven_p_policy p WHERE p.policy_id = p_policy_id;
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20003, 'Договор не найден');
      WHEN too_many_rows THEN
        raise_application_error(-20004, 'Проверьте целостность БД (policy)');
    END;
  
    IF nvl(v_bso.pol_header_id, v_pol.pol_header_id) <> v_pol.pol_header_id
    THEN
      raise_application_error(-20005, 'БСО привязан к другому полису');
    ELSIF nvl(v_bso.policy_id, v_pol.policy_id) <> v_pol.policy_id
    THEN
      raise_application_error(-20006
                             ,'БСО привязан к другой версии полиса');
    END IF;
  
    -- существующая запись в истории
    BEGIN
      SELECT bh.*
        INTO v_hist
        FROM bso      b
            ,bso_hist bh
       WHERE b.bso_id = v_bso.bso_id
         AND b.bso_id = bh.bso_id
         AND b.bso_hist_id = bh.bso_hist_id;
    EXCEPTION
      WHEN OTHERS THEN
        raise_application_error(-20007, 'Проверьте целостность БД (bso_hist)');
    END;
    -- определение кода для испорченного БСО:
    BEGIN
      SELECT t.bso_hist_type_id
        INTO v_hist.hist_type_id
        FROM ven_bso_hist_type t
       WHERE t.brief = 'Использован';
    EXCEPTION
      WHEN OTHERS THEN
        raise_application_error(-20008
                               ,'Проверьте целостность БД (ven_bso_hist_type)');
    END;
  
    -- № записи состояния бланка
    v_hist.num := v_hist.num + 1;
  
    -- 386741 Григорьев Ю. Поправил формирование даты состояния БСО. 
    -- Должна быть фактическая дата привязки А7 к договору.
    -- До этого стояла дата подписания договора.
  
    -- записываем состояние БСО
    dml_bso_hist.insert_record(par_bso_id            => v_hist.bso_id
                              ,par_hist_date         => SYSDATE
                              ,par_hist_type_id      => v_hist.hist_type_id
                              ,par_bso_doc_cont_id   => v_hist.bso_doc_cont_id
                              ,par_num               => v_hist.num
                              ,par_contact_id        => v_hist.contact_id
                              ,par_department_id     => v_hist.department_id
                              ,par_bso_notes_type_id => v_hist.bso_notes_type_id
                              ,par_reg_date          => SYSDATE
                              ,par_bso_hist_id       => v_hist.bso_hist_id);
    -- изменяем строку в бсо
    BEGIN
      UPDATE bso b
         SET b.bso_hist_id   = v_hist.bso_hist_id
            ,b.hist_type_id  = v_hist.hist_type_id
            ,b.contact_id    = v_hist.contact_id
            ,b.pol_header_id = v_pol.pol_header_id
            ,b.policy_id     = v_pol.policy_id
       WHERE b.bso_id = v_bso.bso_id;
    EXCEPTION
      WHEN OTHERS THEN
        raise_application_error(-20010, ' Error in updating bso');
    END;
  END;

  PROCEDURE gen_doc(p_doc_id IN NUMBER) IS
  BEGIN
    FOR rc IN (SELECT * FROM bso_doc_cont b WHERE b.bso_document_id = p_doc_id)
    LOOP
      clear_cont(rc.bso_doc_cont_id);
      gen_num(rc.num_start, rc.num_end, rc.bso_doc_cont_id);
    END LOOP;
  END;

  FUNCTION count_bso_to_contact2(p_contact_id IN NUMBER) RETURN NUMBER IS
  BEGIN
    FOR rc IN (SELECT COUNT(*) c
                 FROM bso_hist      bh
                     ,bso           b
                     ,bso_hist_type bht
                WHERE b.contact_id = p_contact_id
                  AND bht.bso_hist_type_id = b.hist_type_id
                     /*AND bht.brief NOT IN ('Использован') */
                  AND bht.brief IN
                      ('Выдан', 'Зарезервирован', 'Передан', 'PRINTED_EMPTY'))
    LOOP
      RETURN rc.c;
    END LOOP;
    RETURN 0;
  END;

  PROCEDURE check_employee
  (
    p_employee_hist_id IN NUMBER
   ,p_employee_id      IN NUMBER
   ,p_department_id    IN NUMBER
   ,p_date_hist        IN DATE
   ,p_is_kicked        IN NUMBER
   ,p_is_brokeage      IN NUMBER
  ) IS
    v_last_is_brokeage   NUMBER;
    v_last_department_id NUMBER;
  BEGIN
    FOR rc IN (SELECT *
                 FROM employee_hist eh
                WHERE eh.employee_hist_id <> p_employee_hist_id
                  AND eh.employee_id = p_employee_id
                  AND eh.department_id = p_department_id
                  AND eh.date_hist > p_date_hist)
    LOOP
      raise_application_error(-20000
                             ,'Существует более поздняя запись. Сохранение невозможны');
    END LOOP;
  
    BEGIN
      SELECT is_brokeage
            ,department_id
        INTO v_last_is_brokeage
            ,v_last_department_id
        FROM (SELECT veh.is_brokeage
                    ,veh.department_id
                FROM ven_employee_hist veh
               WHERE veh.employee_id = p_employee_id
                 AND veh.date_hist <= p_date_hist
               ORDER BY veh.date_hist DESC)
       WHERE rownum < 2;
    EXCEPTION
      WHEN no_data_found THEN
        v_last_is_brokeage   := 0;
        v_last_department_id := p_department_id;
    END;
  
    IF p_is_kicked = 1
       OR (p_is_brokeage = 0 AND v_last_is_brokeage = 1)
       OR (p_department_id <> v_last_department_id)
    THEN
    
      FOR rc IN (SELECT e.contact_id FROM employee e WHERE e.employee_id = p_employee_id)
      LOOP
      
        IF count_bso_to_contact2(rc.contact_id) > 0
        THEN
          raise_application_error(-20000
                                 ,'У сотрудника есть в наличии бланки строгой отчетности. Сохранение невозможны');
        END IF;
      END LOOP;
    END IF;
  
  END;

  PROCEDURE unlink_bso_payment(p_bso_id NUMBER) IS
    v_bso_hist_brief   VARCHAR2(30);
    v_bso_hist_id      NUMBER;
    v_bso_hist_num     NUMBER;
    v_prev_bso_hist_id NUMBER;
    v_hist_type_id     NUMBER;
    v_contact_id       NUMBER;
  BEGIN
    --получить текущий статус бланка
    SELECT bh.bso_hist_id
          ,bht.brief
          ,bh.num
      INTO v_bso_hist_id
          ,v_bso_hist_brief
          ,v_bso_hist_num
      FROM bso_hist      bh
          ,bso_hist_type bht
     WHERE bh.bso_id = p_bso_id
       AND bh.hist_type_id = bht.bso_hist_type_id
       AND bh.bso_hist_id =
           (SELECT MAX(bhs.bso_hist_id) FROM bso_hist bhs WHERE bhs.bso_id = p_bso_id);
  
    IF v_bso_hist_brief = 'Использован'
    THEN
      IF v_bso_hist_num > 1
      THEN
        --получить предыдущую статусную запись бланка
        SELECT bh.bso_hist_id
              ,bh.hist_type_id
              ,bh.contact_id
          INTO v_prev_bso_hist_id
              ,v_hist_type_id
              ,v_contact_id
          FROM bso_hist bh
         WHERE bh.bso_id = p_bso_id
           AND bh.num = v_bso_hist_num - 1;
      
        --отвязываем бланк от полиса и платежного документа-квитанции
        --прописываем предыдущий статус бланка
        UPDATE ven_bso b
           SET b.pol_header_id = NULL
              ,b.policy_id     = NULL
              ,b.document_id   = NULL
              ,b.bso_hist_id   = v_prev_bso_hist_id
              ,b.hist_type_id  = v_hist_type_id
              ,b.contact_id    = v_contact_id
         WHERE b.bso_id = p_bso_id;
      ELSE
        --Удаляем запись из BSO, если в BSO_HIST была единственная запись
        DELETE FROM ven_bso WHERE bso_id = p_bso_id;
      END IF;
      --удалить статусную запись бланка
      DELETE ven_bso_hist bh WHERE bh.bso_hist_id = v_bso_hist_id;
    END IF;
  END;

  PROCEDURE unlink_bso_policy(p_pol_header_id NUMBER) IS
    v_pol_header_id       p_pol_header.policy_header_id%TYPE;
    v_bso_id              bso.bso_id%TYPE;
    v_bso_hist_num        bso_hist.num%TYPE;
    v_bso_hist_id         bso_hist.bso_hist_id%TYPE;
    v_bso_hist_contact_id bso_hist.contact_id%TYPE;
    v_bso_hist_type_id    bso_hist.hist_type_id%TYPE;
  BEGIN
    FOR rec IN (SELECT bso_id
                  FROM bso      b
                      ,p_policy pp
                 WHERE pp.pol_header_id = p_pol_header_id
                   AND b.pol_header_id = pp.pol_header_id)
    LOOP
    
      SELECT bso_hist_id
            ,num
            ,hist_type_id
            ,contact_id
        INTO v_bso_hist_id
            ,v_bso_hist_num
            ,v_bso_hist_type_id
            ,v_bso_hist_contact_id
        FROM bso_hist bh
       WHERE bh.bso_id = rec.bso_id
         AND bh.num = (SELECT MAX(bh1.num)
                         FROM bso_hist      bh1
                             ,bso_hist_type bht1
                        WHERE bh1.bso_id = bh.bso_id
                          AND bh1.hist_type_id = bht1.bso_hist_type_id
                          AND bht1.brief IN ('Передан', 'PRINTED_EMPTY'));
    
      DELETE FROM ven_bso_hist bh
       WHERE bh.bso_id = rec.bso_id
         AND bh.num > v_bso_hist_num;
    
      UPDATE ven_bso b
         SET b.pol_header_id = NULL
            ,b.policy_id     = NULL
             --            ,b.document_id   = NULL
            ,b.is_pol_num   = 0
            ,b.hist_type_id = v_bso_hist_type_id
            ,b.contact_id   = v_bso_hist_contact_id
            ,b.bso_hist_id  = v_bso_hist_id
       WHERE b.bso_id = rec.bso_id;
    
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001, 'Не удалось отвязать БСО');
  END;

  PROCEDURE link_bso_payment
  (
    p_bso_id     NUMBER
   ,p_payment_id NUMBER
   ,p_policy_id  NUMBER
  ) IS
    v_bso_series VARCHAR2(30);
    v_bso_num    VARCHAR2(150);
    v_a7_num     VARCHAR2(150);
  BEGIN
    --поиск бланка
    SELECT bs.series_name
          ,b.num
      INTO v_bso_series
          ,v_bso_num
      FROM bso        b
          ,bso_series bs
     WHERE b.bso_series_id = bs.bso_series_id
       AND b.bso_id = p_bso_id;
    --добавляем движение БСО, статус Использован, привязка к полису
    pkg_bso.create_relation_bso_pol('A7', v_bso_series, v_bso_num, p_policy_id);
    --привязываем бланк к платежному документу
    UPDATE bso b SET b.document_id = p_payment_id WHERE b.bso_id = p_bso_id;
  
    -- Ищем соответствующую копию a7  и, если найдена меняем номер
  
    SELECT num INTO v_a7_num FROM document WHERE document_id = p_payment_id;
  
    FOR a7_copy IN (SELECT child_id
                      FROM doc_doc
                     WHERE parent_id = p_payment_id
                       AND doc.get_doc_templ_brief(child_id) = 'A7COPY')
    LOOP
      UPDATE document SET num = v_a7_num WHERE document_id = a7_copy.child_id;
    
    END LOOP;
  
  END;

  FUNCTION get_bso_status_brief
  (
    p_bso_id IN NUMBER
   ,dt       IN DATE DEFAULT SYSDATE
  ) RETURN VARCHAR2 IS
    v_name VARCHAR2(150);
  BEGIN
    IF dt IS NULL
    THEN
      SELECT bht.brief
        INTO v_name
        FROM bso_hist bh
        JOIN bso_hist_type bht
          ON bht.bso_hist_type_id = bh.hist_type_id
       WHERE bh.bso_id = p_bso_id
         AND bh.num = (SELECT MAX(bh1.num) FROM bso_hist bh1 WHERE bh1.bso_id = bh.bso_id);
    ELSE
      SELECT bht.brief
        INTO v_name
        FROM bso_hist bh
        JOIN bso_hist_type bht
          ON bht.bso_hist_type_id = bh.hist_type_id
       WHERE bh.bso_id = p_bso_id
         AND bh.num = (SELECT MAX(bh1.num)
                         FROM bso_hist bh1
                        WHERE bh1.bso_id = bh.bso_id
                          AND bh1.hist_date <= dt);
    END IF;
    RETURN v_name;
  END;

  FUNCTION get_bso_last_status_brief(p_bso_id IN NUMBER) RETURN VARCHAR2 IS
    v_brief bso_hist_type.brief%TYPE;
  BEGIN
    SELECT bht.brief
      INTO v_brief
      FROM bso           b
          ,bso_hist_type bht
     WHERE b.bso_id = p_bso_id
       AND bht.bso_hist_type_id = b.hist_type_id;
    RETURN v_brief;
  
  END get_bso_last_status_brief;
  --// процедура проверки возможности изменения статуса документа по БСО
  PROCEDURE check_act_bso(p_act_id NUMBER) IS
    v_rez NUMBER := 0;
  BEGIN
    -- если статус изменен на "Проект"
    IF doc.get_doc_status_brief(p_act_id) IN ('PROJECT')
    THEN
      BEGIN
        -- существуют бланки, которые нельзя обновляться
        SELECT 1
          INTO v_rez
          FROM dual
         WHERE EXISTS (SELECT '1'
                  FROM bso          b
                      ,bso_hist     bh
                      ,bso_doc_cont dc
                 WHERE dc.bso_document_id = p_act_id
                   AND dc.bso_doc_cont_id = bh.bso_doc_cont_id
                   AND b.bso_id = bh.bso_id
                   AND b.bso_hist_id <> bh.bso_hist_id);
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
      IF v_rez > 0
      THEN
        raise_application_error(-20000
                               ,'По документу существуют БСО, имеющие последущее движение');
      END IF;
    END IF;
  END;
  -- Процедура проверки возможности проведения update ven_bso_document.reg_date
  PROCEDURE check_act_bso_date_update
  (
    p_act_id   NUMBER
   ,p_reg_date DATE
  ) IS
  BEGIN
  
    FOR rec IN (SELECT bh.bso_id AS bso_id
                  FROM bso_doc_cont     dc
                      ,bso_hist         bh
                      ,ven_bso_document d
                 WHERE d.bso_document_id = p_act_id
                   AND dc.bso_document_id = d.bso_document_id
                   AND bh.bso_doc_cont_id = dc.bso_doc_cont_id
                   AND d.reg_date <> bh.hist_date)
    LOOP
      raise_application_error(-20001
                             ,'У бланка ID = ' || rec.bso_id || ' существует следующее состояние');
    END LOOP;
  
    FOR rec IN (SELECT bh.bso_id AS bso_id
                  FROM bso_doc_cont dc
                      ,bso_hist     bh
                      ,bso_hist     bh2
                 WHERE dc.bso_document_id = p_act_id
                   AND bh.bso_doc_cont_id = dc.bso_doc_cont_id
                   AND bh.bso_id = bh2.bso_id
                   AND bh2.num = bh.num + 1)
    LOOP
      raise_application_error(-20001
                             ,'У бланка ID = ' || rec.bso_id || ' существует следующее состояние');
    END LOOP;
  
    FOR rec IN (SELECT bh.bso_id AS bso_id
                  FROM bso_doc_cont dc
                      ,bso_hist     bh
                      ,bso_hist     bh3
                 WHERE dc.bso_document_id = p_act_id
                   AND bh.bso_doc_cont_id = dc.bso_doc_cont_id
                   AND bh.bso_id = bh3.bso_id
                   AND bh3.num = bh.num - 1
                   AND bh3.hist_date > p_reg_date)
    LOOP
      raise_application_error(-20001
                             ,'У бланка ID = ' || rec.bso_id ||
                              ' предыдущая запись в истории датируется более поздним числом');
    END LOOP;
  
  END;

  PROCEDURE check_cre_bdc
  (
    p_bso_series_id IN NUMBER
   ,p_start         IN VARCHAR2
   ,p_end           IN VARCHAR2
  ) IS
    vr_bso_series bso_series%ROWTYPE;
    v_err         VARCHAR2(100);
  BEGIN
    SELECT * INTO vr_bso_series FROM bso_series WHERE bso_series_id = p_bso_series_id;
  
    IF vr_bso_series.chars_in_num = 7
    THEN
      --Проверка только для новых БСО
      FOR x IN (SELECT *
                  FROM bso_doc_cont bdc
                 WHERE bdc.bso_series_id = p_bso_series_id
                   AND (to_number(substr(p_start, 1, 6)) BETWEEN to_number(bdc.num_start) AND
                       to_number(bdc.num_end) OR to_number(substr(p_end, 1, 6)) BETWEEN
                       to_number(bdc.num_start) AND to_number(bdc.num_end)))
      LOOP
        v_err := v_err || ', ' || x.bso_document_id || '(' || x.num_start || ' - ' || x.num_end || ')';
      
        IF length(v_err) > 50
        THEN
          EXIT;
        END IF;
      END LOOP;
    
      IF v_err IS NOT NULL
      THEN
        raise_application_error(-20001
                               ,'Создаваемый диапазон пересекается с уже существующими. №№ (' ||
                                ltrim(v_err, ', ') || ').');
      END IF;
    END IF;
  END check_cre_bdc;

  PROCEDURE calc_bso_norm_dep
  (
    p_p_dep_id   NUMBER
   ,p_p_rep_date DATE
  ) IS
  
  BEGIN
    NULL;
  END calc_bso_norm_dep;

  PROCEDURE calc_bso_norm
  (
    p_p_contact_id NUMBER
   ,p_p_date_act   DATE
  ) IS
  
    p_p_ag_contract_header_id NUMBER;
    p_p_cnt_1parent           NUMBER;
    p_p_cnt_2parent           NUMBER;
    p_p_cnt_sum_parent        NUMBER;
    p_p_cnt_sum_bso           NUMBER;
    p_p_cnt_2bso              NUMBER;
    p_p_cnt_1bso              NUMBER;
    p_p_series_id             NUMBER;
    p_p_bso_norm              NUMBER;
    p_p_ag_category_id        NUMBER;
    p_p_cnt_contact           NUMBER;
    p_p_cat_brief             VARCHAR2(65);
  
    CURSOR c_series IS(
      SELECT ser.bso_series_id
        FROM bso_series ser
            ,bso_type   ts
       WHERE ser.bso_type_id = ts.bso_type_id
         AND nvl(ts.check_ac, 0) = 1);
  
    CURSOR c_terdir
    (
      v_ag_contract_header_id IN NUMBER
     ,v_date_act              IN DATE
    ) IS
    --
      SELECT tr.ag_contract_header_id
            ,agh.agent_id
        FROM ins.ag_agent_tree      tr
            ,ins.ag_contract_header agh
            ,ag_contract            agc
            ,ag_category_agent      cat
       WHERE tr.ag_parent_header_id = v_ag_contract_header_id --p_p_ag_contract_header_id
         AND v_date_act /*p_p_date_act*/
             BETWEEN tr.date_begin AND tr.date_end
         AND tr.ag_contract_header_id = agh.ag_contract_header_id
         AND agc.contract_id = tr.ag_contract_header_id
         AND v_date_act BETWEEN agc.date_begin AND agc.date_end
         AND agc.category_id = cat.ag_category_agent_id
         AND cat.brief IN ('MN')
         AND (SELECT /*+index_desc(doc UK_DOC_STATUS)*/
               rf.brief
                FROM doc_status     doc
                    ,doc_status_ref rf
               WHERE document_id = tr.ag_contract_header_id
                 AND trunc(start_date) <= v_date_act
                 AND doc.doc_status_ref_id = rf.doc_status_ref_id
                 AND rownum = 1) = 'CURRENT';
    --
  
    CURSOR c_dir
    (
      v_ag_contract_header_id IN NUMBER
     ,v_date_act              IN DATE
    ) IS
    --
      SELECT tr.ag_contract_header_id
            ,agh.agent_id
        FROM ins.ag_agent_tree      tr
            ,ins.ag_contract_header agh
       WHERE tr.ag_parent_header_id = v_ag_contract_header_id
         AND v_date_act BETWEEN tr.date_begin AND tr.date_end
         AND tr.ag_contract_header_id = agh.ag_contract_header_id
         AND (SELECT /*+index_desc(doc UK_DOC_STATUS)*/
               rf.brief
                FROM doc_status     doc
                    ,doc_status_ref rf
               WHERE document_id = tr.ag_contract_header_id
                 AND trunc(start_date) <= v_date_act
                 AND doc.doc_status_ref_id = rf.doc_status_ref_id
                 AND rownum = 1) = 'CURRENT';
    --
  BEGIN
  
    DELETE FROM t_norm_bso_agent;
  
    BEGIN
      SELECT COUNT(*)
        INTO p_p_cnt_contact
        FROM ag_contract_header agh
       WHERE agh.agent_id = p_p_contact_id;
    EXCEPTION
      WHEN no_data_found THEN
        p_p_cnt_contact := 0;
    END;
  
    BEGIN
      SELECT cat.ag_category_agent_id
            ,cat.brief
        INTO p_p_ag_category_id
            ,p_p_cat_brief
        FROM contact            c
            ,ag_contract_header agh
            ,ag_contract        ag
            ,ag_category_agent  cat
       WHERE agh.agent_id = c.contact_id
         AND nvl(agh.is_new, 0) = 1
         AND ag.contract_id = agh.ag_contract_header_id
         AND ag.date_end = to_date('31-12-2999', 'dd-mm-yyyy')
         AND doc.get_doc_status_brief(agh.ag_contract_header_id) = 'CURRENT'
         AND cat.ag_category_agent_id = ag.category_id
         AND c.contact_id = p_p_contact_id
         AND rownum = 1; --Заявка 246267
    EXCEPTION
      WHEN no_data_found THEN
        p_p_ag_category_id := 2;
        p_p_cat_brief      := 'AG';
    END;
  
    IF p_p_cnt_contact > 0
       AND p_p_cat_brief IN ('MN', 'DR', 'DR2', 'TD')
    THEN
    
      SELECT agh.ag_contract_header_id
        INTO p_p_ag_contract_header_id
        FROM contact            c
            ,ag_contract_header agh
       WHERE agh.agent_id = c.contact_id
         AND nvl(agh.is_new, 0) = 1
         AND doc.get_doc_status_brief(agh.ag_contract_header_id) = 'CURRENT'
         AND c.contact_id = p_p_contact_id;
    
      IF p_p_cat_brief IN ('MN', 'DR', 'DR2')
      THEN
      
        SELECT COUNT(*)
          INTO p_p_cnt_1parent
          FROM ins.ag_agent_tree tr
         WHERE tr.ag_parent_header_id = p_p_ag_contract_header_id
           AND p_p_date_act BETWEEN tr.date_begin AND tr.date_end
           AND (SELECT /*+index_desc(doc UK_DOC_STATUS)*/
                 rf.brief
                  FROM doc_status     doc
                      ,doc_status_ref rf
                 WHERE document_id = tr.ag_contract_header_id
                   AND trunc(start_date) <= p_p_date_act
                   AND doc.doc_status_ref_id = rf.doc_status_ref_id
                   AND rownum = 1) = 'CURRENT';
      ELSE
      
        SELECT COUNT(*)
          INTO p_p_cnt_1parent
          FROM ins.ag_agent_tree      tr
              ,ins.ag_contract_header agh
              ,ag_contract            agc
              ,ag_category_agent      cat
         WHERE tr.ag_parent_header_id = p_p_ag_contract_header_id --p_p_ag_contract_header_id
           AND p_p_date_act BETWEEN tr.date_begin AND tr.date_end
           AND tr.ag_contract_header_id = agh.ag_contract_header_id
           AND agc.contract_id = tr.ag_contract_header_id
           AND p_p_date_act BETWEEN agc.date_begin AND agc.date_end
           AND agc.category_id = cat.ag_category_agent_id
           AND cat.brief IN ('MN')
           AND (SELECT /*+index_desc(doc UK_DOC_STATUS)*/
                 rf.brief
                  FROM doc_status     doc
                      ,doc_status_ref rf
                 WHERE document_id = tr.ag_contract_header_id
                   AND trunc(start_date) <= p_p_date_act
                   AND doc.doc_status_ref_id = rf.doc_status_ref_id
                   AND rownum = 1) = 'CURRENT';
      
      END IF;
    
      p_p_cnt_sum_parent := 0;
      IF p_p_cnt_1parent > 0
         AND p_p_cat_brief IN ('TD')
      THEN
        --------------------------------------------------------------------------------       
        FOR cur IN c_terdir(p_p_ag_contract_header_id, p_p_date_act)
        LOOP
        
          SELECT COUNT(*)
            INTO p_p_cnt_2parent
            FROM ins.ag_agent_tree tr
           WHERE tr.ag_parent_header_id = cur.ag_contract_header_id
             AND p_p_date_act BETWEEN tr.date_begin AND tr.date_end
             AND (SELECT /*+index_desc(doc UK_DOC_STATUS)*/
                   rf.brief
                    FROM doc_status     doc
                        ,doc_status_ref rf
                   WHERE document_id = tr.ag_contract_header_id
                     AND trunc(start_date) <= p_p_date_act
                     AND doc.doc_status_ref_id = rf.doc_status_ref_id
                     AND rownum = 1) = 'CURRENT';
          IF nvl(p_p_cnt_2parent, 0) > 0
          THEN
            p_p_cnt_sum_parent := p_p_cnt_sum_parent + p_p_cnt_2parent;
          END IF;
        
        END LOOP;
      
      ELSIF p_p_cnt_1parent > 0
            AND p_p_cat_brief IN ('MN', 'DR', 'DR2')
      THEN
        ---------------------------------------------------------------------------------       
        FOR cur IN c_dir(p_p_ag_contract_header_id, p_p_date_act)
        LOOP
        
          SELECT COUNT(*)
            INTO p_p_cnt_2parent
            FROM ins.ag_agent_tree tr
           WHERE tr.ag_parent_header_id = cur.ag_contract_header_id
             AND p_p_date_act BETWEEN tr.date_begin AND tr.date_end
             AND (SELECT /*+index_desc(doc UK_DOC_STATUS)*/
                   rf.brief
                    FROM doc_status     doc
                        ,doc_status_ref rf
                   WHERE document_id = tr.ag_contract_header_id
                     AND trunc(start_date) <= p_p_date_act
                     AND doc.doc_status_ref_id = rf.doc_status_ref_id
                     AND rownum = 1) = 'CURRENT';
          IF nvl(p_p_cnt_2parent, 0) > 0
          THEN
            p_p_cnt_sum_parent := p_p_cnt_sum_parent + p_p_cnt_2parent;
          END IF;
        
        END LOOP;
      END IF;
    
      p_p_cnt_sum_parent := p_p_cnt_sum_parent + p_p_cnt_1parent;
    
      OPEN c_series;
      LOOP
        FETCH c_series
          INTO p_p_series_id;
        EXIT WHEN c_series%NOTFOUND;
      
        SELECT COUNT(*)
          INTO p_p_cnt_1bso
          FROM bso           b
              ,bso_hist_type t
         WHERE b.hist_type_id = t.bso_hist_type_id
           AND t.name IN ('Зарезервирован', 'Передан', 'PRINTED_EMPTY')
           AND b.contact_id = p_p_contact_id
              --and p_p_date_act between h.hist_date and h.hist_date
           AND b.bso_series_id = p_p_series_id;
      
        p_p_cnt_sum_bso := 0;
        IF p_p_cnt_1parent > 0
           AND p_p_ag_category_id > 3
        THEN
          FOR cur IN (SELECT tr.ag_contract_header_id
                            ,agh.agent_id
                        FROM ins.ag_agent_tree      tr
                            ,ins.ag_contract_header agh
                       WHERE tr.ag_parent_header_id = p_p_ag_contract_header_id
                         AND p_p_date_act BETWEEN tr.date_begin AND tr.date_end
                         AND tr.ag_contract_header_id = agh.ag_contract_header_id
                         AND (SELECT /*+index_desc(doc UK_DOC_STATUS)*/
                               rf.brief
                                FROM doc_status     doc
                                    ,doc_status_ref rf
                               WHERE document_id = tr.ag_contract_header_id
                                 AND trunc(start_date) <= p_p_date_act
                                 AND doc.doc_status_ref_id = rf.doc_status_ref_id
                                 AND rownum = 1) = 'CURRENT')
          LOOP
          
            SELECT COUNT(*)
              INTO p_p_cnt_2bso
              FROM bso           b
                  ,bso_hist_type t
             WHERE b.hist_type_id = t.bso_hist_type_id
               AND t.name IN ('Зарезервирован', 'Передан', 'PRINTED_EMPTY')
               AND b.contact_id = cur.agent_id
                  --and p_p_date_act between h.hist_date and h.hist_date
               AND b.bso_series_id = p_p_series_id;
            IF nvl(p_p_cnt_2bso, 0) > 0
            THEN
              p_p_cnt_sum_bso := p_p_cnt_sum_bso + p_p_cnt_2bso;
            END IF;
          
          END LOOP;
        END IF;
        p_p_cnt_sum_bso := p_p_cnt_sum_bso + p_p_cnt_1bso;
      
        BEGIN
          SELECT n.bso_norm
            INTO p_p_bso_norm
            FROM t_bso_norm n
           WHERE n.bso_series_id = p_p_series_id
             AND SYSDATE BETWEEN n.norm_date_begin AND n.norm_date_end;
        EXCEPTION
          WHEN no_data_found THEN
            p_p_bso_norm := 0;
        END;
      
        IF p_p_ag_category_id > 3
        THEN
          p_p_bso_norm := (((p_p_cnt_sum_parent + 1) * p_p_bso_norm) * 2 - p_p_cnt_sum_bso);
        ELSE
          p_p_bso_norm := ((p_p_cnt_sum_parent + 1) * p_p_bso_norm - p_p_cnt_sum_bso);
        END IF;
      
        INSERT INTO t_norm_bso_agent tt
          (t_norm_bso_agent_id, bso_series_id, ag_contract_header, bso_norm)
        VALUES
          (sq_t_norm_bso_agent.nextval, p_p_series_id, p_p_ag_contract_header_id, p_p_bso_norm);
      
      END LOOP;
      CLOSE c_series;
    
    END IF;
  
  END calc_bso_norm;

  PROCEDURE calc_check_bso_norm(p_p_doc_id NUMBER) IS
    p_p_contact_from NUMBER;
    p_p_contact_to   NUMBER;
    p_p_reg_date     DATE;
    proc_name        VARCHAR2(35) := 'calc_check_bso_norm';
    no_calc EXCEPTION;
    p_p_cnt_contact NUMBER;
  
  BEGIN
  
    --pkg_renlife_utils.tmp_log_writer('calc_check_bso_norm');
  
    BEGIN
      SELECT bs.contact_from_id
            ,bs.contact_to_id
            ,d.reg_date
        INTO p_p_contact_from
            ,p_p_contact_to
            ,p_p_reg_date
        FROM bso_document bs
            ,document     d
       WHERE bs.bso_document_id = p_p_doc_id
         AND d.document_id = bs.bso_document_id;
    EXCEPTION
      WHEN no_data_found THEN
        RAISE no_calc;
    END;
  
    BEGIN
      SELECT COUNT(*)
        INTO p_p_cnt_contact
        FROM ag_contract_header agh
       WHERE agh.agent_id = p_p_contact_to;
    EXCEPTION
      WHEN no_data_found THEN
        p_p_cnt_contact := 0;
    END;
  
    --pkg_renlife_utils.tmp_log_writer(p_p_contact_from||' '||p_p_contact_to||' '||p_p_reg_date);
    IF p_p_cnt_contact > 0
    THEN
      calc_bso_norm(p_p_contact_to, p_p_reg_date);
    END IF;
  
  EXCEPTION
  
    WHEN no_calc THEN
      raise_application_error(-20002
                             ,'Невозможно по указанным параметрам рассчитать НОРМЫ БСО');
    WHEN OTHERS THEN
      raise_application_error(-20003, 'Ошибка при выполнении ' || proc_name);
  END calc_check_bso_norm;

  PROCEDURE check_bso_norm(p_p_doc_id NUMBER) IS
    p_p_contact_from NUMBER;
    p_p_contact_to   NUMBER;
    p_p_reg_date     DATE;
    p_bso_norm       NUMBER;
    proc_name        VARCHAR2(35) := 'check_bso_norm';
    no_check EXCEPTION;
    no_calc  EXCEPTION;
    p_sys_role  NUMBER;
    p_name_role VARCHAR(255);
    p_p_res     NUMBER := 0;
  BEGIN
  
    --pkg_renlife_utils.tmp_log_writer('check_bso_norm');
    ------------------------
    BEGIN
      SELECT ins.safety.get_curr_role
        INTO p_sys_role
        FROM ven_sys_user us
       WHERE upper(us.sys_user_name) = upper(USER);
    EXCEPTION
      WHEN no_data_found THEN
        p_sys_role := 0;
    END;
  
    BEGIN
      SELECT u.name INTO p_name_role FROM ven_sys_role u WHERE u.sys_role_id = p_sys_role;
    EXCEPTION
      WHEN no_data_found THEN
        p_name_role := '';
    END;
    --pkg_renlife_utils.tmp_log_writer('p_name_role = '||p_name_role);
    IF p_name_role IN ('Офис - менеджер')
    THEN
      p_p_res := 1;
    END IF;
    --------------------------------
  
    --pkg_renlife_utils.tmp_log_writer('перешли к расчету в документе');
    FOR cur_b IN (SELECT nvl(SUM(CASE
                                   WHEN ser.chars_in_num > 6 THEN
                                    to_number(nvl(substr(bdc.num_end, 1, ser.chars_in_num - 1)
                                                 ,substr(bdc.num_start, 1, ser.chars_in_num - 1))) + 1 -
                                    to_number(substr(bdc.num_start, 1, ser.chars_in_num - 1))
                                   ELSE
                                    to_number(nvl(bdc.num_end, bdc.num_start)) + 1 - to_number(bdc.num_start)
                                 END)
                            ,0) sum_bso_ser
                        ,bdc.bso_series_id
                    FROM bso_document bs
                        ,bso_doc_cont bdc
                        ,bso_series   ser
                   WHERE bs.bso_document_id = bdc.bso_document_id
                     AND bs.bso_document_id = p_p_doc_id
                     AND ser.bso_series_id = bdc.bso_series_id
                   GROUP BY bdc.bso_series_id)
    LOOP
    
      --pkg_renlife_utils.tmp_log_writer('bso_series_id = '||cur_b.bso_series_id);
      --pkg_renlife_utils.tmp_log_writer('sum_bso_ser = '||cur_b.sum_bso_ser);
      BEGIN
        SELECT tnb.bso_norm
          INTO p_bso_norm
          FROM t_norm_bso_agent tnb
         WHERE tnb.bso_series_id = cur_b.bso_series_id;
      EXCEPTION
        WHEN no_data_found THEN
          p_bso_norm := 0;
      END;
    
      --pkg_renlife_utils.tmp_log_writer('p_p_bso_norm = '||p_bso_norm);
      --pkg_renlife_utils.tmp_log_writer('p_p_res = '|| p_p_res);
    
      IF cur_b.sum_bso_ser > p_bso_norm
         AND p_p_res = 1
      THEN
        RAISE no_check;
      ELSIF cur_b.sum_bso_ser > p_bso_norm
            AND p_p_res = 0
      THEN
        g_message.state   := 'Warn'; --'Warn'; --'Ok'
        g_message.message := 'Превышен лимит выдачи БСО';
      END IF;
      --pkg_renlife_utils.tmp_log_writer('g_message.state = '|| g_message.state);
    --pkg_renlife_utils.tmp_log_writer('g_message.message = '|| g_message.message);
    
    END LOOP;
  EXCEPTION
    WHEN no_check THEN
      raise_application_error(-20001
                             ,'Внимание! Превышен лимит выдачи БСО');
    WHEN OTHERS THEN
      raise_application_error(-20003, 'Ошибка при выполнении ' || proc_name);
  END check_bso_norm;

  PROCEDURE calc_bso_doc
  (
    p_p_contact_id NUMBER
   ,p_p_doc_id     NUMBER
  ) IS
  
    p_p_cnt_bso_ser NUMBER;
    p_p_ser_id      NUMBER;
    p_p_bso_num     VARCHAR2(35);
    p_p_num2char    VARCHAR2(35);
    num1            NUMBER;
    num2            NUMBER;
    p_p_chars_num   NUMBER;
    p_p_first       NUMBER;
  
  BEGIN
  
    DELETE FROM t_norm_bso_calc;
  
    FOR cur IN (SELECT tb.bso_series_id
                      ,tb.bso_norm
                      ,ser.series_name
                  FROM ins.t_norm_bso_agent tb
                      ,bso_series           ser
                 WHERE ser.bso_series_id = tb.bso_series_id)
    LOOP
      DELETE FROM t_bso_calculate;
    
      SELECT ser.chars_in_num
        INTO p_p_chars_num
        FROM bso_series ser
       WHERE ser.bso_series_id = cur.bso_series_id;
    
      p_p_cnt_bso_ser := 0;
    
      BEGIN
        SELECT nvl(SUM(CASE
                         WHEN p_p_chars_num > 6 THEN
                          to_number(nvl(substr(bdc.num_end, 1, p_p_chars_num - 1)
                                       ,substr(bdc.num_start, 1, p_p_chars_num - 1))) + 1 -
                          to_number(substr(bdc.num_start, 1, p_p_chars_num - 1))
                         ELSE
                          to_number(nvl(bdc.num_end, bdc.num_start)) + 1 - to_number(bdc.num_start)
                       END)
                  ,0)
          INTO p_p_cnt_bso_ser
          FROM bso_doc_cont bdc
         WHERE bdc.bso_document_id = p_p_doc_id
           AND bdc.bso_series_id = cur.bso_series_id;
      EXCEPTION
        WHEN no_data_found THEN
          p_p_cnt_bso_ser := 0;
      END;
    
      IF p_p_cnt_bso_ser < cur.bso_norm
      THEN
      
        IF cur.bso_norm > 0
        THEN
        
          INSERT INTO t_bso_calculate
            SELECT b.bso_series_id
                  ,b.bso_id
                  ,b.num
                  ,t.name status
              FROM bso           b
                  ,bso_hist_type t
             WHERE b.hist_type_id = t.bso_hist_type_id
               AND t.name IN ('Склад ЦО', 'Передан', 'PRINTED_EMPTY')
               AND b.contact_id = p_p_contact_id
               AND b.bso_series_id = cur.bso_series_id
               AND NOT EXISTS
             (SELECT '1' -- существуют уже такие бланки в данном документе
                      FROM bso_doc_cont  bdc
                          ,document      d
                          ,doc_templ     dt
                          ,bso_hist_type bht
                     WHERE d.document_id = bdc.bso_document_id
                       AND b.num BETWEEN bdc.num_start AND nvl(bdc.num_end, bdc.num_start)
                       AND b.bso_series_id = bdc.bso_series_id
                       AND dt.doc_templ_id = d.doc_templ_id
                       AND bdc.bso_hist_type_id = bht.bso_hist_type_id
                       AND bht.brief IN ('Передан', 'Зарезервирован')
                       AND dt.brief = 'ПередачаБСО'
                       AND bdc.bso_document_id = p_p_doc_id)
             ORDER BY b.num;
        
        END IF;
      
        BEGIN
          SELECT bn.bso_series_id
                ,MIN(bn.bso_num)
            INTO p_p_ser_id
                ,p_p_bso_num
            FROM t_bso_calculate bn
           GROUP BY bn.bso_series_id;
        EXCEPTION
          WHEN no_data_found THEN
            p_p_ser_id  := 0;
            p_p_bso_num := '';
        END;
      
        IF p_p_ser_id <> 0
        THEN
        
          num2 := 999999;
        
          FOR cr IN (SELECT bso_series_id
                           ,bso_id
                           ,bso_num
                           ,bso_status
                       FROM t_bso_calculate
                      ORDER BY bso_num)
          LOOP
          
            IF p_p_cnt_bso_ser >= cur.bso_norm
            THEN
              GOTO end_loop;
            END IF;
          
            num1 := to_number(cr.bso_num);
            IF num1 = num2 + 1
            THEN
            
              SELECT lpad(to_char(num1), p_p_chars_num, '0') INTO p_p_num2char FROM dual;
            
              UPDATE t_norm_bso_calc SET bso_num_end = p_p_num2char WHERE bso_num_start = p_p_first;
              p_p_cnt_bso_ser := p_p_cnt_bso_ser + 1;
            
            ELSE
              SELECT lpad(to_char(num1), p_p_chars_num, '0') INTO p_p_num2char FROM dual;
            
              p_p_first := num1;
            
              INSERT INTO t_norm_bso_calc
                (bso_series_id, bso_num_start)
              VALUES
                (cr.bso_series_id, p_p_num2char);
              p_p_cnt_bso_ser := p_p_cnt_bso_ser + 1;
            END IF;
          
            num2 := num1;
          
            <<end_loop>>
            NULL;
          END LOOP;
        
          --end if;
        
        END IF;
      END IF;
    
    END LOOP;
  END calc_bso_doc;

  PROCEDURE set_status_bso(p_p_doc_id NUMBER) IS
  
    p_p_doc_templ_id        NUMBER;
    p_p_brief               VARCHAR2(65);
    p_p_hist_value          VARCHAR2(65);
    proc_name               VARCHAR2(65) := 'set_status_bso';
    p_p_status_doc          VARCHAR2(65);
    p_p_is_created          NUMBER := 0;
    p_p_prev_status         ins.doc_status_ref.brief%TYPE;
    p_is_status_change_type NUMBER DEFAULT NULL;
  
  BEGIN
    FOR cur_bso IN (SELECT cnt.num_start
                          ,cnt.num_end
                          ,cnt.bso_doc_cont_id
                          ,cnt.bso_hist_type_id
                      FROM bso_document bs
                          ,bso_doc_cont cnt
                     WHERE bs.bso_document_id = cnt.bso_document_id
                       AND bs.bso_document_id = p_p_doc_id)
    LOOP
      -- pkg_renlife_utils.tmp_log_writer(p_p_doc_id);
      p_p_is_created := 0;
    
      SELECT dsr.brief
            ,dsr2.brief
        INTO p_p_status_doc
            ,p_p_prev_status
        FROM doc_status         ds
            ,doc_status_ref     dsr
            ,ins.doc_status_ref dsr2
       WHERE ds.doc_status_ref_id = dsr.doc_status_ref_id
         AND dsr2.doc_status_ref_id = ds.src_doc_status_ref_id
         AND ds.doc_status_id =
             (SELECT MAX(dss.doc_status_id) FROM doc_status dss WHERE dss.document_id = p_p_doc_id);
    
      pkg_renlife_utils.tmp_log_writer(' п_п_док = ' || p_p_doc_id || ' п_п_статус = ' ||
                                       p_p_status_doc);
    
      SELECT tp.doc_templ_id
            ,tp.brief
        INTO p_p_doc_templ_id
            ,p_p_brief
        FROM bso_document bs
            ,document     d
            ,doc_templ    tp
       WHERE bs.bso_document_id = p_p_doc_id
         AND bs.bso_document_id = d.document_id
         AND d.doc_templ_id = tp.doc_templ_id;
      pkg_renlife_utils.tmp_log_writer(p_p_doc_id || '    ' || '2');
    
      IF p_p_status_doc = 'PRINTED'
      THEN
      
        IF p_p_brief = 'ПередачаБСО'
        THEN
          p_p_hist_value := 'Зарезервирован';
        ELSIF p_p_brief = 'ВозвратБСО'
        THEN
          p_p_hist_value := 'Зарезервирован';
        ELSIF p_p_brief = 'ИспорченныеБСО'
        THEN
          p_p_hist_value := 'Зарезервирован';
        ELSIF p_p_brief = 'УтеряБСО'
        THEN
          p_p_hist_value := 'Зарезервирован';
        ELSIF p_p_brief = 'СписаниеБСО'
        THEN
          p_p_hist_value := 'Зарезервирован';
        ELSIF p_p_brief = 'УничтожениеБСО'
        THEN
          p_p_hist_value := 'Зарезервирован';
        ELSIF p_p_brief = 'ВосстановлениеБСО'
        THEN
          --Чирков 27.02.2012 добалил для статуса ВосстановлениеБСО
          p_p_hist_value := 'Зарезервирован';
        END IF;
      
      ELSIF p_p_status_doc = 'CONFIRMED'
      THEN
      
        IF p_p_brief = 'ПередачаБСО'
        THEN
          p_p_hist_value := 'Передан';
        
        ELSIF p_p_brief = 'ВозвратБСО'
        THEN
          p_p_hist_value := 'Склад ЦО';
        
        ELSIF p_p_brief = 'ИспорченныеБСО'
        THEN
          p_p_hist_value := 'Испорчен';
        
        ELSIF p_p_brief = 'УтеряБСО'
        THEN
          p_p_hist_value := 'Утерян';
        ELSIF p_p_brief = 'СписаниеБСО'
        THEN
          p_p_hist_value := 'Списан';
        ELSIF p_p_brief = 'УничтожениеБСО'
        THEN
          p_p_hist_value := 'Уничтожен';
        
        ELSIF p_p_brief = 'НакладнаяБСО'
        THEN
          p_p_hist_value := 'Склад ЦО';
        
        ELSIF p_p_brief = 'ФормированиеБСО'
        THEN
          p_p_is_created := 1;
          p_p_hist_value := 'Сформирован';
        ELSIF p_p_brief = 'ВосстановлениеБСО'
        THEN
          --Чирков 27.02.2012 добалил для статуса ВосстановлениеБСО 
          p_p_hist_value := 'Передан';
        END IF;
        --восстановление статуса бланков при переводе акта из статуса Напечатан в Проект
      ELSIF p_p_status_doc = 'PROJECT'
            AND p_p_prev_status = 'PRINTED'
      THEN
      
        IF p_p_brief = 'ПередачаБСО'
        THEN
          p_p_hist_value          := 'Передан';
          p_is_status_change_type := 0; --Тип изменения статуса Акта
        END IF;
      ELSE
        NULL;
      END IF;
      pkg_renlife_utils.tmp_log_writer('начало бсо = ' || cur_bso.num_start || ' конец бсо = ' ||
                                       cur_bso.num_end || ' бсо_док_конт = ' ||
                                       cur_bso.bso_doc_cont_id || ' p_p_brief = ' || p_p_brief ||
                                       'п_п_хист_вэлью = ' || p_p_hist_value);
      calc_num(cur_bso.num_start
              ,cur_bso.num_end
              ,cur_bso.bso_doc_cont_id
              ,p_p_hist_value
              ,p_p_is_created
              ,p_is_status_change_type);
    END LOOP;
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM);
  END set_status_bso;

  PROCEDURE calc_num
  (
    p_num_start             IN VARCHAR2
   ,p_num_end               IN VARCHAR2
   ,p_id                    IN NUMBER
   ,p_hist_value            IN VARCHAR2
   ,p_is_created            NUMBER
   ,p_is_status_change_type IN NUMBER DEFAULT 1 --тип изменения статуса Акта. Заявка 239016
  ) IS
    v_start VARCHAR2(150);
    v_end   VARCHAR2(150);
    n_start NUMBER;
    n_end   NUMBER;
    v_pref  VARCHAR2(150);
    m_len   NUMBER;
    p_len   NUMBER;
    i       NUMBER := 0;
  
    v_bso_series        NUMBER;
    v_bso_series_num    NUMBER;
    v_chars_in_num      NUMBER;
    v_is_created        NUMBER(1);
    v_hist_type         NUMBER;
    v_reg_date          DATE;
    v_contact_to        NUMBER;
    v_contact_from      NUMBER;
    v_department        NUMBER;
    v_department_from   NUMBER;
    v_bso_notes_type_id NUMBER;
    v_stat_hist_type    NUMBER;
    proc_name           VARCHAR2(35) := 'calc_num';
  
  BEGIN
  
    v_is_created := p_is_created;
    --pkg_renlife_utils.tmp_log_writer('Хист тип1 = '||p_hist_value);
    BEGIN
      SELECT tp.bso_hist_type_id INTO v_hist_type FROM bso_hist_type tp WHERE tp.name = p_hist_value;
    EXCEPTION
      WHEN no_data_found THEN
        RETURN;
    END;
    --pkg_renlife_utils.tmp_log_writer('Хист тип2 = '||v_hist_type);
    BEGIN
      SELECT bdc.bso_series_id
            ,(SELECT bs.series_num FROM bso_series bs WHERE bs.bso_series_id = bdc.bso_series_id)
            ,(SELECT bs.chars_in_num FROM bso_series bs WHERE bs.bso_series_id = bdc.bso_series_id)
            ,d.reg_date
             --Заявка 239016. В общем если акт обратно переходит из Напечатан в проект, то делаем обратную передачу
            ,CASE
               WHEN p_is_status_change_type = 0 THEN
                d.contact_from_id
               ELSE
                d.contact_to_id
             END contact_to_id
            ,CASE
               WHEN p_is_status_change_type = 0 THEN
                d.contact_to_id
               ELSE
                contact_from_id
             END contact_from_id
            ,CASE
               WHEN p_is_status_change_type = 0 THEN
                d.department_from_id
               ELSE
                d.department_to_id
             END department_to_id
            ,CASE
               WHEN p_is_status_change_type = 0 THEN
                d.department_to_id
               ELSE
                d.department_from_id
             END department_from_id
             --end
            ,bdc.bso_notes_type_id
            ,bdc.bso_hist_type_id
        INTO v_bso_series
            ,v_bso_series_num
            ,v_chars_in_num
            ,v_reg_date
            ,v_contact_to
            ,v_contact_from
            ,v_department
            ,v_department_from
            ,v_bso_notes_type_id
            ,v_stat_hist_type
        FROM bso_doc_cont bdc
       INNER JOIN ven_bso_document d
          ON d.bso_document_id = bdc.bso_document_id
       WHERE bdc.bso_doc_cont_id = p_id /*
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               and bdc.bso_hist_type_id = v_hist_type*/
      ;
    EXCEPTION
      WHEN no_data_found THEN
        RETURN;
    END;
    --pkg_renlife_utils.tmp_log_writer('в_бсо_сериес = '||v_bso_series||' в_контакт_ту = '||v_contact_to||' в_контакт_фром = '||v_contact_from);
    IF p_num_end IS NULL
    THEN
      proceed_one_num(p_num_start
                     ,p_id
                     ,v_is_created
                     ,v_hist_type
                     ,v_reg_date
                     ,v_contact_to
                     ,v_bso_series
                     ,v_contact_from
                     ,v_department
                     ,v_department_from
                     ,v_bso_notes_type_id);
    ELSE
      IF v_chars_in_num = 7
      THEN
        --Для новых бланков, отрезаем последний контрольный символ
        v_start := substr(p_num_start, 1, v_chars_in_num - 1);
        v_end   := substr(p_num_end, 1, v_chars_in_num - 1);
      ELSE
        v_start := p_num_start;
        v_end   := p_num_end;
      END IF;
    
      m_len   := greatest(length(v_start), length(v_end));
      v_start := lpad(p_num_start, m_len);
      v_end   := lpad(p_num_end, m_len);
    
      WHILE i < m_len
      LOOP
        i := i + 1;
        IF substr(v_start, 1, i) <> substr(v_end, 1, i)
        THEN
          EXIT;
        END IF;
      END LOOP;
      v_pref := substr(v_start, 1, i - 1);
      p_len  := m_len - nvl(length(v_pref), 0);
    
      n_start := to_number(substr(v_start, i));
      n_end   := to_number(substr(v_end, i));
      --pkg_renlife_utils.tmp_log_writer('начало цикла = '||n_start||' конец цикла = '||n_end);
      FOR i IN n_start .. n_end
      LOOP
        IF v_chars_in_num = 7
        THEN
          proceed_one_num(substr(pkg_xx_pol_ids.cre_new_ids(v_bso_series_num
                                                           ,v_pref || lpad(i, p_len, '0'))
                                ,4)
                         ,p_id
                         ,v_is_created
                         ,v_hist_type
                         ,v_reg_date
                         ,v_contact_to
                         ,v_bso_series
                         ,v_contact_from
                         ,v_department
                         ,v_department_from
                         ,v_bso_notes_type_id);
        ELSE
          proceed_one_num(v_pref || lpad(i, p_len, '0')
                         ,p_id
                         ,v_is_created
                         ,v_hist_type
                         ,v_reg_date
                         ,v_contact_to
                         ,v_bso_series
                         ,v_contact_from
                         ,v_department
                         ,v_department_from
                         ,v_bso_notes_type_id);
        END IF;
      
      END LOOP;
    END IF;
    UPDATE bso_doc_cont cnt SET cnt.bso_hist_type_id = v_hist_type WHERE cnt.bso_doc_cont_id = p_id;
    --pkg_renlife_utils.tmp_log_writer('Конец процы калк_нам');
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM);
  END calc_num;

  /* ilyushkin.sergey 18/07/2012
    Возвращает количество доступных для выдачи БСО согласно ТЗ "Администрирование БСО"
    @par_contact_id - ИД контакта, которому требуется выдача БСО 
    @par_series_id - ИД серии БСО
    @par_date - Дата расчета
    @return - доступный остаток БСО
  */
  FUNCTION get_bso_limit
  (
    par_contact_id NUMBER
   ,par_series_id  NUMBER
   ,par_date       DATE DEFAULT SYSDATE
  ) RETURN NUMBER IS
    v_agent_category        NUMBER := NULL;
    v_ag_contract_header_id NUMBER := NULL;
  
    TYPE t_array IS TABLE OF NUMBER;
    v_array t_array;
  
    v_ag_count  NUMBER := 0;
    v_all_count NUMBER := 0;
    v_norm      NUMBER := 0;
    v_limit     NUMBER := 0;
  BEGIN
    BEGIN
      SELECT ag_contract_header_id
            ,sort_id
        INTO v_ag_contract_header_id
            ,v_agent_category
        FROM ag_contract_header ach
            ,document           dc
            ,doc_status_ref     dsr
            ,ag_contract        ac
            ,ag_category_agent  aca
       WHERE nvl(ach.is_new, 0) = 1
         AND ac.ag_contract_id = ach.last_ver_id
         AND dc.document_id = ach.ag_contract_header_id
         AND dsr.doc_status_ref_id = dc.doc_status_ref_id
         AND dsr.brief IN ('CURRENT')
         AND aca.ag_category_agent_id = ac.category_id
         AND ach.agent_id = par_contact_id;
    EXCEPTION
      WHEN OTHERS THEN
        v_ag_contract_header_id := NULL;
        v_agent_category        := NULL;
    END;
  
    IF v_ag_contract_header_id IS NULL
    THEN
      RETURN - 1;
    END IF;
  
    /**/
    ins.pkg_bso.calc_bso_norm(par_contact_id, par_date);
    SELECT tt.bso_norm
      INTO v_limit
      FROM t_norm_bso_agent tt
     WHERE tt.bso_series_id = par_series_id
       AND tt.ag_contract_header = v_ag_contract_header_id;
    /**/
  
    /*select ach.ag_contract_header_id
    bulk collect into v_array
      from ag_contract_header ach,
           document dc,
           doc_status_ref dsr
     where NVL (ach.Is_New, 0) = 1
       and DC.DOCUMENT_ID = ACH.AG_CONTRACT_HEADER_ID
       and DSR.DOC_STATUS_REF_ID = DC.DOC_STATUS_REF_ID
       and dsr.brief in ('CURRENT')
       and ACH.AG_CONTRACT_HEADER_ID in 
                    (select aat.ag_contract_header_id 
                      from (select ac.ag_contract_id,
                                   aat.ag_contract_header_id,
                                   case when aat.ag_parent_header_id is null or ac_lead.agency_id <> ac.agency_id
                                   then (select TO_NUMBER('-'||ts.id||agency_id)
                                           from ag_contract_header ach,
                                                t_sales_channel ts 
                                          where ach.ag_contract_header_id = aat.ag_contract_header_id
                                            and ach.t_sales_channel_id = ts.id) 
                                   else aat.ag_parent_header_id
                                   end ag_parent_header_id,
                                   aat.date_end
                              from ag_agent_tree aat,
                                   ag_contract ac,
                                   ag_contract ac_lead
                             where aat.ag_contract_header_id = ac.contract_id
                               and ac.contract_leader_id = ac_lead.ag_contract_id (+)
                               and par_date between aat.date_begin and aat.date_end
                               and par_date between ac.date_begin and ac.date_end) aat
                    START with aat.ag_parent_header_id = v_ag_contract_header_id
                    CONNECT by nocycle AaT.ag_parent_header_id = prior AaT.ag_contract_header_id
                    union
                    select ac.ag_contract_header_id
                      from ag_contract_header ac 
                      where ac.ag_contract_header_id = v_ag_contract_header_id);
    
    v_all_count := 0;
    for i in v_array.first..v_array.last loop
      v_ag_count := 0;
      select count(BH.BSO_HIST_ID)
        into v_ag_count
        from bso_hist bh,
             bso_hist_type bht,
             bso bs,
             ag_contract_header ach
       where BH.CONTACT_ID = ACH.AGENT_ID
         and BHT.BSO_HIST_TYPE_ID = BH.HIST_TYPE_ID
         and upper(BHT.BRIEF) IN ('ПЕРЕДАН')
         and BS.BSO_ID = BH.BSO_ID
         and BS.BSO_SERIES_ID = par_series_id
         and ACH.AG_CONTRACT_HEADER_ID = v_array(i);
      v_all_count := v_all_count + v_ag_count;   
    end loop;                    
    
    begin
      select bso_norm
        into v_norm
        from t_bso_norm
       where bso_series_id = par_series_id
         and par_date between norm_date_begin and norm_date_end;
    exception
      when others then
        v_norm := 0;
    end;          
    
    if v_agent_category <= 2 then
      v_limit := (v_array.count + 1) * v_norm - v_all_count;
    else
      v_limit := (v_array.count + 1) * v_norm * 2 - v_all_count;
    end if;*/
  
    IF v_limit < 0
    THEN
      v_limit := 0;
    END IF;
  
    RETURN v_limit;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END get_bso_limit;

  PROCEDURE lock_bso_by_rowid
  (
    par_rowid  UROWID
   ,par_bso_id OUT bso.bso_id%TYPE
  ) IS
  BEGIN
    SELECT bso_id INTO par_bso_id FROM bso WHERE ROWID = par_rowid FOR UPDATE NOWAIT;
  END lock_bso_by_rowid;

  /*
    Капля П.
    05.06.2014
    Процедура заполнения временной таблицы пустыми бланками, и перевод их в статуем "Распечатан пустой бланк"
    Используется в интеграционной схеме ряда партнеров, когда сначала они печатают пустые бланки,
    а потом заводят на них договоры.
  */
  PROCEDURE create_empty_bso_pool
  (
    par_bso_series_id     bso_series.bso_series_id%TYPE
   ,par_to_generate_count PLS_INTEGER
   ,par_agent_id          contact.contact_id%TYPE DEFAULT NULL
  ) IS
    c_proc_name CONSTANT pkg_trace.t_object_name := 'CREATE_EMPTY_BSO_POOL';
    v_bso_id_list      t_number_type := t_number_type();
    v_rowid            UROWID;
    v_bso_id           bso.bso_id%TYPE;
    v_dummy_contact_id contact.contact_id%TYPE;
    v_contact_id       contact.contact_id%TYPE;
    v_found_count      PLS_INTEGER := 0;
  
    CURSOR bso_cur IS
      WITH contacts AS
       (SELECT agent_id      AS contact_id
              ,LEVEL         lv
              ,ah.date_begin
          FROM ag_contract_header ah
         START WITH ah.agent_id = v_contact_id
                AND doc.get_last_doc_status_brief(ah.ag_contract_header_id) = 'CURRENT'
                AND ah.is_new = 1
        CONNECT BY ah.ag_contract_header_id IN PRIOR
                   (SELECT at.ag_parent_header_id
                      FROM ag_agent_tree at
                     WHERE ah.ag_contract_header_id = at.ag_contract_header_id
                       AND SYSDATE BETWEEN at.date_begin AND at.date_end)
               AND ah.is_new = 1
               AND doc.get_last_doc_status_brief(ah.ag_contract_header_id) = 'CURRENT')
      SELECT b.rowid
        FROM bso           b
            ,bso_hist_type bht
            ,contacts      c
       WHERE b.bso_series_id = par_bso_series_id
         AND b.contact_id = c.contact_id
         AND b.hist_type_id = bht.bso_hist_type_id
         AND bht.brief = 'Передан'
       ORDER BY c.lv
               ,c.date_begin DESC
               ,b.num;
  
    PROCEDURE save_bso_list_to_temp IS
    BEGIN
      FORALL i IN v_bso_id_list.first .. v_bso_id_list.last
        INSERT INTO tmp_bso_to_print (bso_id) VALUES (v_bso_id_list(i));
    END save_bso_list_to_temp;
  
    PROCEDURE change_printed_bso_status IS
      c_bso_hist_type_brief  CONSTANT bso_hist_type.brief%TYPE := 'PRINTED_EMPTY';
      c_bso_notes_type_brief CONSTANT bso_notes_type.brief%TYPE := 'РаспечатанПустой';
    
      v_bso_hist_type_id  bso_hist_type.bso_hist_type_id%TYPE;
      v_bso_notes_type_id bso_notes_type.bso_notes_type_id%TYPE;
      v_dummy             NUMBER;
    BEGIN
    
      v_bso_hist_type_id  := dml_bso_hist_type.get_id_by_brief(c_bso_hist_type_brief);
      v_bso_notes_type_id := dml_bso_notes_type.get_id_by_brief(c_bso_notes_type_brief);
    
      FOR rec IN (SELECT b.contact_id
                        ,b.bso_series_id
                        ,b.num
                        ,b.bso_id
                    FROM bso              b
                        ,tmp_bso_to_print t
                   WHERE b.bso_id = t.bso_id)
      LOOP
      
        v_dummy := pkg_bso.create_bso_history_rec(par_bso_id            => rec.bso_id
                                                 ,par_bso_hist_type_id  => v_bso_hist_type_id
                                                 ,par_bso_notes_type_id => v_bso_notes_type_id);
      END LOOP;
    END change_printed_bso_status;
  BEGIN
    pkg_trace.add_variable(par_trace_var_name  => 'par_bso_series_id'
                          ,par_trace_var_value => par_bso_series_id);
    pkg_trace.add_variable(par_trace_var_name => 'par_agent_id', par_trace_var_value => par_agent_id);
    pkg_trace.trace_function_start(par_trace_obj_name    => gc_pkg_name
                                  ,par_trace_subobj_name => c_proc_name);
  
    v_contact_id := nvl(par_agent_id, get_bso_dummy_contact_id);
  
    OPEN bso_cur;
  
    LOOP
    
      FETCH bso_cur
        INTO v_rowid;
      EXIT WHEN v_found_count >= par_to_generate_count OR bso_cur%NOTFOUND;
    
      BEGIN
        lock_bso_by_rowid(v_rowid, v_bso_id);
        v_bso_id_list.extend;
        v_bso_id_list(v_bso_id_list.last) := v_bso_id;
        v_found_count := v_found_count + 1;
      EXCEPTION
        WHEN pkg_oracle_exceptions.resource_busy_nowait THEN
          NULL;
      END;
    
    END LOOP;
  
    CLOSE bso_cur;
  
    IF v_found_count = par_to_generate_count
    THEN
      -- 
      save_bso_list_to_temp;
    
      change_printed_bso_status;
    ELSE
      ex.raise_custom('Не удалось софрировать пул пустых бланков. Не достаточно свободных БСО.');
    END IF;
  
    pkg_trace.trace_procedure_end(par_trace_obj_name    => gc_pkg_name
                                 ,par_trace_subobj_name => c_proc_name);
  
  END create_empty_bso_pool;

  FUNCTION gen_next_bso_id
  (
    par_bso_series_id NUMBER
   ,par_agent_id      NUMBER DEFAULT NULL
  ) RETURN bso.bso_id%TYPE IS
    v_id               bso.bso_id%TYPE;
    v_rowid            UROWID;
    v_dummy_contact_id contact.contact_id%TYPE;
    v_contact_id       contact.contact_id%TYPE;
    c_proc_name CONSTANT pkg_trace.t_object_name := 'GEN_NEXT_BSO_ID';
  
    CURSOR bso_cur_simple IS
      SELECT b.rowid
        FROM bso           b
            ,bso_hist_type bht
       WHERE b.bso_series_id = par_bso_series_id
         AND b.contact_id = v_contact_id
         AND b.hist_type_id = bht.bso_hist_type_id
         AND bht.brief = 'Передан'
       ORDER BY b.num;
  
    CURSOR bso_cur_advanced IS
      WITH contacts AS
       (SELECT agent_id      AS contact_id
              ,LEVEL         lv
              ,ah.date_begin
          FROM ag_contract_header ah
         WHERE LEVEL > 1
         START WITH ah.agent_id = v_contact_id
                AND doc.get_last_doc_status_brief(ah.ag_contract_header_id) = 'CURRENT'
                AND ah.is_new = 1
        CONNECT BY ah.ag_contract_header_id IN PRIOR
                   (SELECT at.ag_parent_header_id
                      FROM ag_agent_tree at
                     WHERE ah.ag_contract_header_id = at.ag_contract_header_id
                       AND SYSDATE BETWEEN at.date_begin AND at.date_end)
               AND ah.is_new = 1
               AND doc.get_last_doc_status_brief(ah.ag_contract_header_id) = 'CURRENT')
      SELECT b.rowid
        FROM bso           b
            ,bso_hist_type bht
            ,contacts      c
       WHERE b.bso_series_id = par_bso_series_id
         AND b.contact_id = c.contact_id
         AND b.hist_type_id = bht.bso_hist_type_id
         AND bht.brief = 'Передан'
       ORDER BY c.lv
               ,c.date_begin DESC
               ,b.num;
  
  BEGIN
    pkg_trace.add_variable(par_trace_var_name  => 'par_bso_series_id'
                          ,par_trace_var_value => par_bso_series_id);
    pkg_trace.add_variable(par_trace_var_name => 'par_agent_id', par_trace_var_value => par_agent_id);
    pkg_trace.trace_function_start(par_trace_obj_name    => gc_pkg_name
                                  ,par_trace_subobj_name => c_proc_name);
  
    -- Если не задан контакт, ищем на Владельце Фиктивных БСО
    v_contact_id := nvl(par_agent_id, get_bso_dummy_contact_id);
  
    /*
      Сначала пытаемся найти БСО на контакте
    */
  
    OPEN bso_cur_simple;
  
    LOOP
      EXIT WHEN v_id IS NOT NULL;
    
      FETCH bso_cur_simple
        INTO v_rowid;
      EXIT WHEN bso_cur_simple%NOTFOUND;
    
      BEGIN
        lock_bso_by_rowid(v_rowid, v_id);
      EXCEPTION
        WHEN pkg_oracle_exceptions.resource_busy_nowait THEN
          NULL;
      END;
    
    END LOOP;
  
    CLOSE bso_cur_simple;
  
    IF v_id IS NULL
    THEN
      pkg_trace.trace(par_trace_obj_name    => gc_pkg_name
                     ,par_trace_subobj_name => c_proc_name
                     ,par_message           => 'Ищем БСО у руководителей агента контакта');
      OPEN bso_cur_advanced;
    
      LOOP
        EXIT WHEN v_id IS NOT NULL;
      
        FETCH bso_cur_advanced
          INTO v_rowid;
        EXIT WHEN bso_cur_advanced%NOTFOUND;
      
        BEGIN
          lock_bso_by_rowid(v_rowid, v_id);
        EXCEPTION
          WHEN pkg_oracle_exceptions.resource_busy_nowait THEN
            NULL;
        END;
      
      END LOOP;
    
      CLOSE bso_cur_advanced;
    
    END IF;
  
    IF v_id IS NULL
    THEN
      ex.raise(par_message => 'Не удалось сгенерировать номер свободного БСО'
              ,par_sqlcode => ex.c_no_data_found);
    END IF;
  
    pkg_trace.trace_function_end(par_trace_obj_name    => gc_pkg_name
                                ,par_trace_subobj_name => c_proc_name
                                ,par_result_value      => v_id);
  
    RETURN v_id;
  EXCEPTION
    WHEN OTHERS THEN
      IF bso_cur_simple%ISOPEN
      THEN
        CLOSE bso_cur_simple;
      END IF;
      IF bso_cur_advanced%ISOPEN
      THEN
        CLOSE bso_cur_advanced;
      END IF;
      ex.raise;
  END gen_next_bso_id;

  FUNCTION gen_next_bso_number
  (
    par_bso_series_id NUMBER
   ,par_agent_id      NUMBER DEFAULT NULL
  ) RETURN bso.num%TYPE IS
    v_bso bso%ROWTYPE;
  BEGIN
    v_bso.bso_id := gen_next_bso_id(par_bso_series_id => par_bso_series_id
                                   ,par_agent_id      => par_agent_id);
  
    v_bso := dml_bso.get_record(v_bso.bso_id);
  
    RETURN v_bso.num;
  
  END gen_next_bso_number;

  FUNCTION get_bso_series_id(par_bso_series_num bso_series.series_num%TYPE)
    RETURN bso_series.bso_series_id%TYPE IS
    v_bso_series_id bso_series.bso_series_id%TYPE;
  BEGIN
    SELECT bs.bso_series_id
      INTO v_bso_series_id
      FROM bso_series bs
     WHERE bs.series_num = par_bso_series_num;
    RETURN v_bso_series_id;
  EXCEPTION
    WHEN no_data_found THEN
      raise_application_error(-20001
                             ,'Не удалось определить ИД серии БСО по номеру ' ||
                              nvl(to_char(par_bso_series_num), 'NULL'));
  END get_bso_series_id;

  /*
    Проверка доступности серии БСО для привязки к договору страхования
  */
  PROCEDURE check_bso_series_for_policy
  (
    par_bso_series_id bso_series.bso_series_id%TYPE
   ,par_policy_id     p_policy.policy_id%TYPE
  ) IS
    v_exists            NUMBER(1);
    v_bso_series_num    bso_series.series_num%TYPE;
    v_bso_type_id       bso_series.bso_type_id%TYPE;
    v_product_name      t_product.description%TYPE;
    v_policy_start_date p_pol_header.start_date%TYPE;
    v_policy_form_id    bso_series.t_product_conds_id%TYPE;
    v_product_id        t_product.product_id%TYPE;
  BEGIN
  
    SELECT bs.series_num
          ,bs.bso_type_id
          ,bs.t_product_conds_id
      INTO v_bso_series_num
          ,v_bso_type_id
          ,v_policy_form_id
      FROM bso_series bs
     WHERE bs.bso_series_id = par_bso_series_id;
  
    SELECT ph.start_date
          ,p.description
          ,p.product_id
      INTO v_policy_start_date
          ,v_product_name
          ,v_product_id
      FROM t_product    p
          ,p_pol_header ph
          ,p_policy     pp
     WHERE pp.policy_id = par_policy_id
       AND pp.pol_header_id = ph.policy_header_id
       AND ph.product_id = p.product_id;
  
    SELECT COUNT(*)
      INTO v_exists
      FROM dual
     WHERE EXISTS (SELECT NULL
              FROM t_product_bso_types pbt
             WHERE pbt.t_product_id = v_product_id
               AND pbt.bso_type_id = v_bso_type_id);
  
    IF v_exists = 0
    THEN
      raise_application_error(-20001
                             ,'Cерия БСО ' || v_bso_series_num || ' не доступна для продукта ' ||
                              v_product_name);
    END IF;
  
    IF v_policy_form_id IS NOT NULL
    THEN
      SELECT COUNT(*)
        INTO v_exists
        FROM dual
       WHERE EXISTS (SELECT NULL
                FROM t_policyform_product pp
               WHERE pp.t_product_id = v_product_id
                 AND pp.t_policy_form_id = v_policy_form_id);
    
      IF v_exists = 0
      THEN
        raise_application_error(-20001
                               ,'Полисные условия серии БСО ' || v_bso_series_num ||
                                ' не доступны для продукта ' || v_product_name);
      END IF;
    END IF;
  
    SELECT COUNT(*)
      INTO v_exists
      FROM dual
     WHERE EXISTS (SELECT NULL
              FROM t_policyform_product pp
             WHERE pp.t_product_id = v_product_id
               AND (pp.t_policy_form_id = v_policy_form_id OR v_policy_form_id IS NULL)
               AND v_policy_start_date BETWEEN pp.start_date AND pp.end_date);
  
    IF v_exists = 0
    THEN
      raise_application_error(-20001
                             ,'Дата начала действия договора выходит за рамки периода действия полисных условий, соответствующих серии БСО ' ||
                              v_bso_series_num || ' для продукта ' || v_product_name);
    END IF;
  
  END check_bso_series_for_policy;

  -- ishch (
  -- Процедура присоединения БСО к договору страхования
  -- Параметры:
  -- par_session_id    - номер сессии загрузки
  -- par_policy_id     - id версии договора
  -- par_pol_header_id - id договора
  -- par_notice_num    - номер БСО (без лидирующих нулей)
  FUNCTION find_bso_by_num
  (
    par_policy_id     NUMBER
   ,par_bso_num       NUMBER
   ,par_bso_series_id NUMBER DEFAULT NULL
  ) RETURN NUMBER IS
    v_bso_series_id  NUMBER;
    v_bso_series_num bso_series.series_num%TYPE;
    v_chars_in_num   NUMBER;
    v_bso_id         NUMBER;
  
    FUNCTION get_default_bso_series_id(par_policy_id p_policy.policy_id%TYPE)
      RETURN bso_series.bso_series_id%TYPE IS
      v_bso_series_id bso_series.bso_series_id%TYPE;
    BEGIN
      SELECT bs.bso_series_id
        INTO v_bso_series_id
        FROM bso_series           bs
            ,t_policy_form        pf
            ,t_product_bso_types  pbt
            ,t_policyform_product pp
            ,p_pol_header         ph
            ,p_policy             p
       WHERE pbt.bso_type_id = bs.bso_type_id
         AND pbt.t_product_id = ph.product_id
         AND pp.t_product_id = pbt.t_product_id
         AND pp.t_policy_form_id = pf.t_policy_form_id
         AND ph.policy_header_id = p.pol_header_id
         AND p.policy_id = par_policy_id
         AND ph.start_date BETWEEN pp.start_date AND pp.end_date
         AND (bs.t_product_conds_id = pf.t_policy_form_id OR bs.t_product_conds_id IS NULL);
    
      RETURN v_bso_series_id;
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20001
                               ,'Не удалось определить серию БСО по умолчанию для договора');
      WHEN too_many_rows THEN
        raise_application_error(-20001
                               ,'Не удалось однозначно определить серию БСО по умолчанию для договора');
    END get_default_bso_series_id;
  
    -- Количество символов в номере бланка
  BEGIN
    IF par_bso_series_id IS NOT NULL
    THEN
      BEGIN
        SELECT bs.bso_series_id
          INTO v_bso_series_id
          FROM bso_series bs
         WHERE bs.bso_series_id = par_bso_series_id;
      EXCEPTION
        WHEN no_data_found THEN
          raise_application_error(-20001, 'Не найдена серия БСО по ИД');
      END;
    
      check_bso_series_for_policy(par_bso_series_id => par_bso_series_id
                                 ,par_policy_id     => par_policy_id);
    ELSE
      v_bso_series_id := get_default_bso_series_id(par_policy_id => par_policy_id);
    END IF;
  
    -- Количество символов в номере бланка
    SELECT chars_in_num
          ,series_num
      INTO v_chars_in_num
          ,v_bso_series_num
      FROM bso_series
     WHERE bso_series_id = v_bso_series_id;
  
    -- Найти БСО по серии и номеру
    BEGIN
      SELECT bso_id
        INTO v_bso_id
        FROM bso
       WHERE bso_series_id = v_bso_series_id
         AND num = lpad(par_bso_num, v_chars_in_num, '0');
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20001
                               ,'Не найден БСО по серии ' || v_bso_series_num || ' и номеру ' ||
                                nvl(to_char(par_bso_num), 'NULL'));
    END;
  
    RETURN v_bso_id;
  
  END find_bso_by_num;
  /*
  Капля П.
  Прикрепление БСО к полису
  */
  PROCEDURE attach_bso_to_policy
  (
    par_policy_id  p_policy.policy_id%TYPE
   ,par_bso_id     bso.bso_id%TYPE
   ,par_is_pol_num bso.is_pol_num%TYPE DEFAULT 1
  ) IS
    v_pol_header_id p_pol_header.policy_header_id%TYPE;
    v_bso_series_id bso.bso_series_id%TYPE;
    v_product_id    t_product.product_id%TYPE;
    v_bso_hist_id   bso_hist.bso_hist_id%TYPE;
  
    PROCEDURE check_bso_series_for_product
    (
      par_bso_series_id bso_series.bso_series_id%TYPE
     ,par_pol_header_id p_pol_header.policy_header_id%TYPE
    ) IS
      v_dummy_value bso_series.bso_series_id%TYPE;
      --380211 Григорьев Ю. Проверяем, является ли серия БСО ПБ бланками (234 серией)
      FUNCTION is_pb_bso(par_bso_series_id NUMBER) RETURN BOOLEAN IS
        v_is_pb_bso NUMBER;
      BEGIN
        SELECT COUNT(1)
          INTO v_is_pb_bso
          FROM dual
         WHERE EXISTS (SELECT bs.bso_series_id
                  FROM ven_bso_type   bt
                      ,ven_bso_series bs
                 WHERE bt.bso_type_id = bs.bso_type_id
                   AND bs.series_num = 234
                   AND bs.bso_series_id = par_bso_series_id);
        RETURN v_is_pb_bso > 0;
      END is_pb_bso;
    
    BEGIN
      IF NOT is_pb_bso(par_bso_series_id)
      THEN
    BEGIN
      SELECT bs.bso_series_id
        INTO v_dummy_value
        FROM bso_series           bs
            ,t_policy_form        pf
            ,t_product_bso_types  pbt
            ,t_policyform_product pp
            ,p_pol_header         ph
       WHERE ph.policy_header_id = par_pol_header_id
         AND pbt.bso_type_id = bs.bso_type_id
         AND pbt.t_product_id = ph.product_id
         AND pp.t_product_id = pbt.t_product_id
         AND pp.t_policy_form_id = pf.t_policy_form_id
         AND ph.start_date BETWEEN pp.start_date AND pp.end_date
         AND bs.bso_series_id = par_bso_series_id
         AND (bs.t_product_conds_id = pf.t_policy_form_id OR bs.t_product_conds_id IS NULL);
    EXCEPTION
      WHEN no_data_found THEN
        ex.raise('Не найдена серия БСО');
      WHEN too_many_rows THEN
        raise_application_error(-20001
                               ,'Найдено несколько серий БСО для данного продукта');
        END;
      END IF;
    END check_bso_series_for_product;
  
    PROCEDURE check_bso_can_be_assigned(par_bso_id bso.bso_id%TYPE) IS
      v_bso           bso%ROWTYPE;
      v_bso_hist_type bso_hist_type%ROWTYPE;
    BEGIN
      v_bso           := dml_bso.get_record(par_bso_id => par_bso_id);
      v_bso_hist_type := dml_bso_hist_type.get_record(par_bso_hist_type_id => v_bso.hist_type_id);
    
      IF v_bso_hist_type.brief = 'Использован'
      THEN
        ex.raise('БСО занят.', ex.c_custom_error);
      ELSIF v_bso_hist_type.brief NOT IN ('Передан', 'PRINTED_EMPTY')
      THEN
        ex.raise('БCO должен быть в статусе "Передан" или "Распечатан пустой бланк"'
                ,ex.c_custom_error);
      END IF;
    
    END check_bso_can_be_assigned;
  
    FUNCTION get_bso_series_for_bso(par_bso_id bso.bso_id%TYPE) RETURN bso.bso_series_id%TYPE IS
      v_bso_series_id bso.bso_series_id%TYPE;
    BEGIN
      SELECT b.bso_series_id INTO v_bso_series_id FROM bso b WHERE b.bso_id = par_bso_id;
      RETURN v_bso_series_id;
    EXCEPTION
      WHEN no_data_found THEN
        ex.raise('Не удалось определить серию БСО');
    END get_bso_series_for_bso;
  
    FUNCTION get_pol_header_id(par_policy_id p_policy.policy_id%TYPE) RETURN p_policy.pol_header_id%TYPE IS
      v_pol_header_id p_policy.pol_header_id%TYPE;
    BEGIN
      SELECT pp.pol_header_id
        INTO v_pol_header_id
        FROM p_policy pp
       WHERE pp.policy_id = par_policy_id;
    
      RETURN v_pol_header_id;
    
    EXCEPTION
      WHEN no_data_found THEN
        ex.raise('Не удалось определить заголовок договора');
    END get_pol_header_id;
  
  BEGIN
  
    assert_deprecated(par_policy_id IS NULL
          ,'Не указано договор страхования для привязки к нему БСО');
    assert_deprecated(par_bso_id IS NULL
          ,'Не указано БСО для привязки к договору страхования');
  
    BEGIN
      dml_bso.lock_record(par_bso_id => par_bso_id);
    EXCEPTION
      WHEN pkg_oracle_exceptions.resource_busy_nowait THEN
        ex.raise('Не удалось прикрепить БСО к договору. БСО занят.');
    END;
  
    v_bso_series_id := get_bso_series_for_bso(par_bso_id => par_bso_id);
  
    v_pol_header_id := get_pol_header_id(par_policy_id => par_policy_id);
  
    check_bso_series_for_product(par_bso_series_id => v_bso_series_id
                                ,par_pol_header_id => v_pol_header_id);
  
    check_bso_can_be_assigned(par_bso_id => par_bso_id);
  
    -- Прикрепить БСО к договору
    UPDATE bso
       SET policy_id     = par_policy_id
          ,pol_header_id = v_pol_header_id
          ,is_pol_num    = par_is_pol_num
     WHERE bso_id = par_bso_id;
  
    -- Добавить строку в bso_hist
    v_bso_hist_id := create_bso_history(par_bso_id, par_policy_id);
  
  END attach_bso_to_policy;

  PROCEDURE check_bso_notes_for_hist_type
  (
    par_bso_hist_type_id  bso_hist_type.bso_hist_type_id%TYPE
   ,par_bso_notes_type_id bso_notes_type.bso_notes_type_id%TYPE
  ) IS
    v_exists NUMBER(1);
  BEGIN
    SELECT COUNT(*)
      INTO v_exists
      FROM dual
     WHERE EXISTS (SELECT NULL
              FROM bso_notes_type t
             WHERE t.bso_notes_type_id = par_bso_notes_type_id
               AND t.bso_hist_type_id = par_bso_hist_type_id);
  
    IF v_exists = 0
    THEN
      raise_application_error(-20001
                             ,'Тип примечаний для БСО не соответствует Виду состояния БСО');
    END IF;
  
  END check_bso_notes_for_hist_type;

  /*
    Капля П.
    Создание записи в истории БСО
  */
  FUNCTION create_bso_history_rec
  (
    par_bso_id            bso.bso_id%TYPE
   ,par_bso_hist_type_id  bso_hist_type.bso_hist_type_id%TYPE
   ,par_bso_notes_type_id bso_notes_type.bso_notes_type_id%TYPE DEFAULT NULL
   ,par_hist_date         bso_hist.hist_date%TYPE DEFAULT SYSDATE
  ) RETURN bso_hist.bso_hist_id%TYPE IS
    v_last_bso_hist bso_hist%ROWTYPE;
    v_bso_hist      bso_hist%ROWTYPE;
  BEGIN
    assert_deprecated(par_bso_id IS NULL, 'ИД БСО должен быть указан');
    assert_deprecated(par_bso_hist_type_id IS NULL
          ,'Бриф целевого статуса БСО должен быть указан');
  
    BEGIN
      SELECT bh.*
        INTO v_last_bso_hist
        FROM bso      b
            ,bso_hist bh
       WHERE b.bso_id = par_bso_id
         AND b.bso_id = bh.bso_id
         AND b.bso_hist_id = bh.bso_hist_id;
    EXCEPTION
      WHEN no_data_found THEN
        ex.raise('БСО не найден по ИД');
    END;
  
    IF v_last_bso_hist.hist_type_id != par_bso_hist_type_id
    THEN
    
      v_bso_hist.hist_type_id := par_bso_hist_type_id;
    
      v_bso_hist.bso_notes_type_id := par_bso_notes_type_id;
    
      /*
      Капля П.
      Проверка не справедлива т.к. целостность почти всегда нарушена :(
      
      check_bso_notes_for_hist_type(par_bso_hist_type_id  => v_bso_hist.hist_type_id
                                   ,par_bso_notes_type_id => v_bso_hist.bso_notes_type_id);
      */
    
      v_bso_hist.num             := v_last_bso_hist.num + 1;
      v_bso_hist.bso_doc_cont_id := v_last_bso_hist.bso_doc_cont_id;
      v_bso_hist.contact_id      := v_last_bso_hist.contact_id;
    
      -- Создаем запись в истории
      dml_bso_hist.insert_record(par_bso_id            => par_bso_id
                                ,par_hist_date         => par_hist_date
                                ,par_hist_type_id      => v_bso_hist.hist_type_id
                                ,par_bso_doc_cont_id   => v_last_bso_hist.bso_doc_cont_id
                                ,par_num               => v_bso_hist.num
                                ,par_contact_id        => v_last_bso_hist.contact_id
                                ,par_department_id     => v_last_bso_hist.department_id
                                ,par_bso_notes_type_id => v_bso_hist.bso_notes_type_id
                                ,par_bso_hist_id       => v_bso_hist.bso_hist_id);
    
      -- Актуализируем основной БСО                          
      UPDATE bso
         SET bso_hist_id  = v_bso_hist.bso_hist_id
            ,hist_type_id = v_bso_hist.hist_type_id
            ,contact_id   = v_bso_hist.contact_id
       WHERE bso_id = par_bso_id;
    
    END IF;
  
    RETURN v_bso_hist.bso_hist_id;
  
  END create_bso_history_rec;

  FUNCTION create_bso_history_rec
  (
    par_bso_id               bso.bso_id%TYPE
   ,par_bso_hist_type_brief  bso_hist_type.brief%TYPE
   ,par_bso_notes_type_brief bso_notes_type.brief%TYPE DEFAULT NULL
   ,par_hist_date            bso_hist.hist_date%TYPE DEFAULT SYSDATE
  ) RETURN bso_hist.bso_hist_id%TYPE IS
    v_last_bso_hist     bso_hist%ROWTYPE;
    v_bso_hist          bso_hist%ROWTYPE;
    v_bso_hist_type_id  bso_hist_type.bso_hist_type_id%TYPE;
    v_bso_notes_type_id bso_notes_type.bso_notes_type_id%TYPE;
  BEGIN
    assert_deprecated(par_bso_id IS NULL, 'ИД БСД должен быть указан');
    assert_deprecated(par_bso_hist_type_brief IS NULL
          ,'Бриф целевого статуса БСО должен быть указан');
  
    v_bso_hist_type_id := dml_bso_hist_type.get_id_by_brief(par_brief => par_bso_hist_type_brief);
    IF par_bso_notes_type_brief IS NOT NULL
    THEN
      v_bso_notes_type_id := dml_bso_notes_type.get_id_by_brief(par_brief => par_bso_notes_type_brief);
    END IF;
  
    RETURN create_bso_history_rec(par_bso_id            => par_bso_id
                                 ,par_bso_hist_type_id  => v_bso_hist_type_id
                                 ,par_bso_notes_type_id => v_bso_notes_type_id
                                 ,par_hist_date         => par_hist_date);
  
  END create_bso_history_rec;

  PROCEDURE create_bso_history_rec
  (
    par_bso_id               bso.bso_id%TYPE
   ,par_bso_hist_type_brief  bso_hist_type.brief%TYPE
   ,par_bso_notes_type_brief bso_notes_type.brief%TYPE DEFAULT NULL
   ,par_hist_date            bso_hist.hist_date%TYPE DEFAULT SYSDATE
  ) IS
    v_bso_hist_id bso_hist.bso_hist_id%TYPE;
  BEGIN
    v_bso_hist_id := create_bso_history_rec(par_bso_id               => par_bso_id
                                           ,par_bso_hist_type_brief  => par_bso_hist_type_brief
                                           ,par_bso_notes_type_brief => par_bso_notes_type_brief
                                           ,par_hist_date            => par_hist_date);
  END create_bso_history_rec;

  -- Функция формировния строки истории БСО
  -- Параметры:
  -- par_bso_id    - id БСО
  -- par_policy_id - id версии договора страхования
  FUNCTION create_bso_history
  (
    par_bso_id    NUMBER
   ,par_policy_id NUMBER
  ) RETURN NUMBER IS
    v_hist bso_hist%ROWTYPE;
    v_date DATE;
  BEGIN
  
    -- дата подписания
    BEGIN
      SELECT nvl(decode(pkg_app_param.get_app_param_n('CLIENTID'), 10, sign_date, start_date), SYSDATE)
        INTO v_date
        FROM p_policy
       WHERE policy_id = par_policy_id;
    EXCEPTION
      WHEN OTHERS THEN
        v_date := SYSDATE;
    END;
  
    v_hist.bso_hist_id := create_bso_history_rec(par_bso_id               => par_bso_id
                                                ,par_bso_hist_type_brief  => 'Использован'
                                                ,par_bso_notes_type_brief => 'WITHCOMMIT'
                                                ,par_hist_date            => v_date);
  
    RETURN(v_hist.bso_hist_id);
  END create_bso_history;

  PROCEDURE create_bso_for_series
  (
    p_bso_series_num VARCHAR2
   ,p_start          VARCHAR2
   ,p_end            VARCHAR2
   ,p_ag_num         VARCHAR2 DEFAULT NULL
  ) IS
    v_document_id   NUMBER;
    v_doc_cont_id   NUMBER;
    v_bso_series_id NUMBER;
  
    --Типография
    v_doc_templ_id    NUMBER;
    v_contact_from    NUMBER;
    v_contact_to      NUMBER;
    v_department_to   NUMBER;
    v_department_from NUMBER;
  BEGIN
  
    SELECT bso_series_id
      INTO v_bso_series_id
      FROM bso_series bs
     WHERE bs.series_num = to_char(p_bso_series_num);
  
    v_doc_templ_id := 14463; -- Формирование БСО
  
    v_contact_from    := 194594; -- Типография
    v_department_from := NULL;
    v_contact_to      := 194594; -- Типография
    v_department_to   := NULL;
  
    SELECT sq_bso_document.nextval INTO v_document_id FROM dual;
  
    INSERT INTO ven_bso_document
      (bso_document_id
      ,doc_templ_id
      ,contact_from_id
      ,contact_to_id
      ,department_from_id
      ,department_to_id
      ,reg_date)
    VALUES
      (v_document_id
      ,v_doc_templ_id
      ,v_contact_from
      ,v_contact_to
      ,v_department_from
      ,v_department_to
      ,trunc(SYSDATE));
  
    SELECT sq_bso_doc_cont.nextval INTO v_doc_cont_id FROM dual;
  
    pkg_bso.insert_cont(p_doc_id            => v_document_id
                       ,p_doc_cont_id       => v_doc_cont_id
                       ,p_start             => p_start
                       ,p_end               => p_end
                       ,p_bso_series        => v_bso_series_id
                       ,p_bso_hist_type     => 46 -- Сформирован
                       ,p_bso_notes_type_id => NULL
                       ,p_bso_count         => to_number(p_end) - to_number(p_start) + 1
                       ,p_num_comment       => NULL);
  
    -- Перевод в Проект                   
    doc.set_doc_status(p_doc_id => v_document_id, p_status_id => 16);
    -- Перевод в Напечатан                   
    doc.set_doc_status(p_doc_id => v_document_id, p_status_id => 20);
  
    -- Перевод в Подтвержден                   
    doc.set_doc_status(p_doc_id => v_document_id, p_status_id => -2);
  
    v_doc_templ_id := 581; -- Приходная канладная
  
    v_contact_from    := 194594; -- Типография
    v_department_from := NULL;
    v_contact_to      := 251861; -- Склад Ц О
    v_department_to   := 6053;
  
    SELECT sq_bso_document.nextval INTO v_document_id FROM dual;
  
    INSERT INTO ven_bso_document
      (bso_document_id
      ,doc_templ_id
      ,contact_from_id
      ,contact_to_id
      ,department_from_id
      ,department_to_id
      ,reg_date)
    VALUES
      (v_document_id
      ,v_doc_templ_id
      ,v_contact_from
      ,v_contact_to
      ,v_department_from
      ,v_department_to
      ,trunc(SYSDATE));
  
    SELECT sq_bso_doc_cont.nextval INTO v_doc_cont_id FROM dual;
  
    pkg_bso.insert_cont(p_doc_id            => v_document_id
                       ,p_doc_cont_id       => v_doc_cont_id
                       ,p_start             => p_start
                       ,p_end               => p_end
                       ,p_bso_series        => v_bso_series_id
                       ,p_bso_hist_type     => 3 -- Склад Ц О
                       ,p_bso_notes_type_id => NULL
                       ,p_bso_count         => to_number(p_end) - to_number(p_start) + 1
                       ,p_num_comment       => NULL);
  
    -- Перевод в Проект                   
    doc.set_doc_status(p_doc_id => v_document_id, p_status_id => 16);
    -- Перевод в Напечатан                   
    doc.set_doc_status(p_doc_id => v_document_id, p_status_id => 20);
  
    -- Перевод в Подтвержден                   
    doc.set_doc_status(p_doc_id => v_document_id, p_status_id => -2);
  
    v_doc_templ_id := 582; -- Акт приема передачи БСО
  
    v_contact_from    := 251861; -- Склад Ц О
    v_department_from := 6053;
  
    IF p_ag_num IS NOT NULL
    THEN
      SELECT ah.agent_id
            ,ah.agency_id
        INTO v_contact_to
            ,v_department_to
        FROM ven_ag_contract_header ah
       WHERE ah.num = p_ag_num;
    ELSE
      v_contact_to    := 4002; --Владелец фиктивных БСО
      v_department_to := NULL;
    END IF;
  
    SELECT sq_bso_document.nextval INTO v_document_id FROM dual;
  
    INSERT INTO ven_bso_document
      (bso_document_id
      ,doc_templ_id
      ,contact_from_id
      ,contact_to_id
      ,department_from_id
      ,department_to_id
      ,reg_date)
    VALUES
      (v_document_id
      ,v_doc_templ_id
      ,v_contact_from
      ,v_contact_to
      ,v_department_from
      ,v_department_to
      ,trunc(SYSDATE));
  
    SELECT sq_bso_doc_cont.nextval INTO v_doc_cont_id FROM dual;
  
    pkg_bso.insert_cont(p_doc_id            => v_document_id
                       ,p_doc_cont_id       => v_doc_cont_id
                       ,p_start             => p_start
                       ,p_end               => p_end
                       ,p_bso_series        => v_bso_series_id
                       ,p_bso_hist_type     => 10 -- Зарезервирвоан
                       ,p_bso_notes_type_id => NULL
                       ,p_bso_count         => to_number(p_end) - to_number(p_start) + 1
                       ,p_num_comment       => NULL);
  
    -- Перевод в Проект                   
    doc.set_doc_status(p_doc_id => v_document_id, p_status_id => 16);
    -- Перевод в Напечатан                   
    doc.set_doc_status(p_doc_id => v_document_id, p_status_id => 20);
  
    -- Перевод в Подтвержден                   
    doc.set_doc_status(p_doc_id => v_document_id, p_status_id => -2);
  END;

  PROCEDURE create_bso_type
  (
    par_name       VARCHAR2
   ,par_brief      VARCHAR2
   ,par_kind_brief VARCHAR2 DEFAULT 'Полис'
   ,par_check_ac   NUMBER DEFAULT 0
   ,par_check_mo   NUMBER DEFAULT 1
  ) IS
  BEGIN
  
    IF par_kind_brief NOT IN ('Полис', 'Заявление', 'Квитанция')
    THEN
      ex.raise(par_message => 'Не верный тип бланка БСО - ' || par_kind_brief
              ,par_sqlcode => ex.c_check_violated);
    END IF;
  
    dml_bso_type.insert_record(par_name       => par_name
                              ,par_brief      => par_brief
                              ,par_kind_brief => nvl(par_kind_brief, 'Полис')
                              ,par_check_mo   => nvl(par_check_mo, 1)
                              ,par_check_ac   => nvl(par_check_ac, 0));
  END create_bso_type;

  PROCEDURE add_bso_series_to_bso_type
  (
    par_bso_type_brief      VARCHAR2
   ,par_series_name         VARCHAR2
   ,par_series_num          VARCHAR2
   ,par_t_policy_form_name  VARCHAR2
   ,par_chars_in_num        NUMBER DEFAULT 6
   ,par_is_default          NUMBER DEFAULT 1
   ,par_proposal_valid_days bso_series.proposal_valid_days%TYPE DEFAULT NULL
  ) IS
    v_bso_type_id    NUMBER;
    v_policy_form_id NUMBER;
  BEGIN
    v_policy_form_id := dml_t_policy_form.get_id_by_t_policy_form_name(par_t_policy_form_name);
  
    v_bso_type_id := dml_bso_type.get_id_by_brief(par_bso_type_brief);
  
    dml_bso_series.insert_record(par_bso_type_id         => v_bso_type_id
                                ,par_is_default          => par_is_default
                                ,par_series_name         => par_series_name
                                ,par_chars_in_num        => nvl(par_chars_in_num, 6)
                                ,par_series_num          => par_series_num
                                ,par_t_product_conds_id  => v_policy_form_id
                                ,par_proposal_valid_days => par_proposal_valid_days);
  
  END add_bso_series_to_bso_type;

  /*
    Капля П.
    Процедура создания Акта утери БСО по распечатанным неиспользованным бланкам БСО
    Впервые было применено для партнера SGI, который печатал упстые бланки, 
    с которыми агенты шли по квартирам. Акты, по которым так и не были созданы договоры теряются
  */
  PROCEDURE loose_proposal_elapsed_bso(par_date DATE DEFAULT SYSDATE) IS
    c_doc_templ_brief              CONSTANT doc_templ.brief%TYPE := 'УтеряБСО';
    c_bso_hist_type_brief_to_loose CONSTANT bso_hist_type.brief%TYPE := 'PRINTED_EMPTY';
    c_bso_notes_type_brief_loose   CONSTANT bso_notes_type.brief%TYPE := 'ПотеряПустой';
  
    v_bso_document_id   bso_document.bso_document_id%TYPE;
    v_bso_doc_cont_id   bso_doc_cont.bso_doc_cont_id%TYPE;
    v_bso_hist_type_id  bso_hist_type.bso_hist_type_id%TYPE;
    v_bso_notes_type_id bso_notes_type.bso_notes_type_id%TYPE;
  
    v_old_proc_execute_status  NUMBER;
    v_old_proc_required_status NUMBER;
  BEGIN
    assert_deprecated(par_date IS NULL
          ,'Должна быть указана дата, на которую нужно отобрать бланки для актов Утери');
  
    v_bso_hist_type_id  := dml_bso_hist_type.get_id_by_brief(par_brief => c_bso_hist_type_brief_to_loose);
    v_bso_notes_type_id := dml_bso_notes_type.get_id_by_brief(par_brief => c_bso_notes_type_brief_loose);
  
    -- Убираем commit на переводе статуса.
    pkg_doc_templ_fmb.get_doc_status_proc(par_templ_brief       => c_doc_templ_brief
                                         ,par_src_status_brief  => 'PROJECT'
                                         ,par_dest_status_brief => 'PRINTED'
                                         ,par_proc_name         => 'Система. Сохранение изменений'
                                         ,par_is_execute        => v_old_proc_execute_status
                                         ,par_is_required       => v_old_proc_required_status);
  
    -- Процедура pkg_doc_templ_fmb.get_doc_status_proc не валится на no_data_found, поэтмоу, 
    -- если когда-нибудь эту процедуру уберут с перехода статусов валиться не нужно
    IF v_old_proc_execute_status IS NOT NULL
       AND v_old_proc_required_status IS NOT NULL
    THEN
      pkg_doc_templ_fmb.set_doc_status_proc(par_templ_brief       => c_doc_templ_brief
                                           ,par_src_status_brief  => 'PROJECT'
                                           ,par_dest_status_brief => 'PRINTED'
                                           ,par_proc_name         => 'Система. Сохранение изменений'
                                           ,par_is_execute        => 0
                                           ,par_is_required       => 0);
    END IF;
  
    -- Создаем акты утери БСО
    -- В акте утери указывается диапазон БСО, поэтому необходимо найти неразрывные диапазоны
    FOR rec IN (WITH bso_temp AS
                   (SELECT b.contact_id
                         ,b.bso_series_id
                         ,b.num
                     FROM bso        b
                         ,bso_series bs
                         ,bso_hist   bh
                    WHERE bs.proposal_valid_days IS NOT NULL
                      AND bs.bso_series_id = b.bso_series_id
                      AND b.hist_type_id = v_bso_hist_type_id
                      AND b.bso_hist_id = bh.bso_hist_id
                      AND bh.hist_date + bs.proposal_valid_days < trunc(par_date))
                  SELECT contact_id
                        ,bso_series_id
                        ,start_num
                        ,MAX(num) end_num
                        ,to_number(MAX(num)) - to_number(start_num) + 1 AS bso_count
                        ,nvl(lag(0) over(PARTITION BY bso_series_id, contact_id ORDER BY start_num), 1) is_first
                        ,nvl(lead(0) over(PARTITION BY bso_series_id, contact_id ORDER BY start_num)
                            ,1) is_last
                        ,(SELECT bd.department_to_id
                            FROM bso_document bd
                                ,bso_doc_cont bdc
                           WHERE bdc.bso_series_id = t.bso_series_id
                             AND t.start_num BETWEEN bdc.num_start AND bdc.num_end
                             AND bdc.bso_document_id = bd.bso_document_id
                             AND bd.contact_to_id = t.contact_id) department_id
                    FROM (SELECT bt.*
                                ,connect_by_root(bt.num) start_num
                            FROM bso_temp bt
                           START WITH NOT EXISTS (SELECT NULL
                                         FROM bso_temp bt2
                                        WHERE bt2.contact_id = bt.contact_id
                                          AND bt2.bso_series_id = bt.bso_series_id
                                          AND bt2.num = bt.num - 1)
                          CONNECT BY PRIOR bt.num + 1 = bt.num
                                 AND PRIOR bt.contact_id = bt.contact_id
                                 AND PRIOR bt.bso_series_id = bt.bso_series_id) t
                   GROUP BY start_num
                           ,bso_series_id
                           ,contact_id
                   ORDER BY bso_series_id
                           ,contact_id
                           ,start_num)
    LOOP
    
      IF rec.is_first = 1
      THEN
        insert_bso_document(par_doc_templ_id       => doc.templ_id_by_brief(c_doc_templ_brief)
                           ,par_contact_from_id    => rec.contact_id
                           ,par_contact_to_id      => NULL
                           ,par_department_from_id => rec.department_id
                           ,par_department_to_id   => NULL
                           ,par_allow_over_norm    => NULL
                           ,par_bso_document_id    => v_bso_document_id);
      END IF;
    
      -- Добавляем неразрывный диапазон БСО в акт
      insert_cont(p_doc_id            => v_bso_document_id
                 ,p_doc_cont_id       => NULL
                 ,p_start             => rec.start_num
                 ,p_end               => rec.end_num
                 ,p_bso_series        => rec.bso_series_id
                 ,p_bso_hist_type     => v_bso_hist_type_id
                 ,p_bso_notes_type_id => v_bso_notes_type_id
                 ,p_bso_count         => rec.bso_count
                 ,p_num_comment       => 'Утеря распечатанных пустых бланков');
    
      IF rec.is_last = 1
      THEN
        doc.set_doc_status(p_doc_id                   => v_bso_document_id
                          ,p_status_brief             => 'PRINTED'
                          ,p_status_date              => SYSDATE
                          ,p_status_change_type_brief => 'AUTO'
                          ,p_note                     => 'JOB Формирование актов утери по неиспользованным напечатанным бланкам');
      
        doc.set_doc_status(p_doc_id                   => v_bso_document_id
                          ,p_status_brief             => 'CONFIRMED'
                          ,p_status_date              => SYSDATE
                          ,p_status_change_type_brief => 'AUTO'
                          ,p_note                     => 'JOB Формирование актов утери по неиспользованным напечатанным бланкам');
      END IF;
    END LOOP;
  
    -- Возвращаем первычные настройки выполнения процедуры
    -- Процедура pkg_doc_templ_fmb.get_doc_status_proc не валится на no_data_found, поэтмоу, 
    -- если когда-нибудь эту процедуру уберут с перехода статусов валиться не нужно
    IF v_old_proc_execute_status IS NOT NULL
       AND v_old_proc_required_status IS NOT NULL
    THEN
      pkg_doc_templ_fmb.set_doc_status_proc(par_templ_brief       => c_doc_templ_brief
                                           ,par_src_status_brief  => 'PROJECT'
                                           ,par_dest_status_brief => 'PRINTED'
                                           ,par_proc_name         => 'Система. Сохранение изменений'
                                           ,par_is_execute        => v_old_proc_execute_status
                                           ,par_is_required       => v_old_proc_required_status);
    END IF;
  END loose_proposal_elapsed_bso;

END pkg_bso; 
/

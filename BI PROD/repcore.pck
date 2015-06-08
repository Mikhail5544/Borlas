CREATE OR REPLACE PACKAGE REPCORE IS

  /**
  * Ядро отчетности: фильтрация по контексту, запуск
  * @author V.Ustinov
  * @version 1
  * @headcom
  */

  /**
  * Тип - массив.
  * @author V.Ustinov
  */
  TYPE num_table_type IS TABLE OF VARCHAR2(18);

  /**
  * Функция возвращает таблицу ИД отчетов, отфильтрованную по контексту.
  * @author V.Ustinov
  * @return массив ИД отчетов
  */
  FUNCTION report_ids_by_context RETURN num_table_type
    PIPELINED;

  /**
  * Процедура устанавливает контекст вызова Oracle Forms.<br>
  * Вызывается из repcore.pll
  * @author V.Ustinov
  * @param p_form текущая форма
  * @param p_block текущий блок
  * @param p_item айтем под курсором
  */
  PROCEDURE set_interface_context
  (
    p_form  VARCHAR2
   ,p_block VARCHAR2
   ,p_item  VARCHAR2
  );

  /**
  * Процедура устанавливает пользовательский контекст, параметры.
  * @author V.Ustinov
  * @param p_key ключ, имя
  * @param p_value значение
  */
  PROCEDURE set_context
  (
    p_key   VARCHAR2
   ,p_value VARCHAR2
  );

  /**
  * Функция возвращает значение контекста по ключу.<br>
  * Возбуждает понятные человеку исключения.
  * @author V.Ustinov
  * @param p_key ключ, имя параметра
  * @return значение из контекста
  */
  FUNCTION get_context(p_key VARCHAR2) RETURN VARCHAR2;

  /**
  * Процедура очистки контекста.
  * @author V.Ustinov
  */
  PROCEDURE clear_context;

  /**
  * <strong>Служебная</strong> функция подготовки URL.<br>
  * Приняется контекст, готовятся параметры.<br>
  * Используется repcore.pll
  * @author V.Ustinov
  * @param p_text строка параметров URL
  * @return измененная строка параметров URL
  */
  FUNCTION prepare_paremeters(p_text VARCHAR2 /*, p_like_diskoverer boolean := false*/) RETURN VARCHAR2;

  /**
  * <strong>Служебная</strong> функция.<br>
  * Используется для отладки, возвращает весь контекст одной строкой.
  * @author V.Ustinov
  * @return весь контекст одной строкой
  */
  FUNCTION context_as_string RETURN VARCHAR2;

  /**
  * <strong>Служебная</strong> функция URL кодирования
  * @author V.Ustinov
  */
  FUNCTION encode(val VARCHAR2) RETURN VARCHAR2;

  /**
  * <strong>Служебная</strong> функция URL декодирования
  * @author V.Ustinov
  */
  FUNCTION decode(val VARCHAR2) RETURN VARCHAR2;

  /**
  * <strong>Служебная</strong> процедура URL декодирования
  * @author V.Ustinov
  */
  PROCEDURE decode(val IN OUT VARCHAR2);

  /**
  * <strong>Служебная</strong> процедура установка модального результата списка отчетов
  * @author V.Ustinov
  */

  PROCEDURE set_modal_result(mr NUMBER);
  /**
  * <strong>Служебная</strong> функция получения модального результата списка отчетов
  * @author V.Ustinov
  */
  FUNCTION get_modal_result RETURN NUMBER;

END REPCORE;
/
CREATE OR REPLACE PACKAGE BODY REPCORE IS

  TYPE hash_table_type IS TABLE OF VARCHAR2(128) INDEX BY VARCHAR2(64);
  TYPE refcursor_type IS REF CURSOR;

  -- контекст, параметры отчетов
  context_ht hash_table_type;

  -- Modal result
  form_modal_result NUMBER;

  -- применение контекста к шаблону, проверка
  FUNCTION apply_context
  (
    p_text   VARCHAR2
   ,p_is_url BOOLEAN
  ) RETURN VARCHAR2 IS
    key      VARCHAR2(64);
    res      VARCHAR2(4000) := p_text;
    rpctext  VARCHAR2(1024);
    posb     INTEGER;
    pose     INTEGER;
    bad_key  VARCHAR2(64);
    err_text VARCHAR2(1024);
  BEGIN
    key := context_ht.first;
    WHILE key IS NOT NULL
    LOOP
      IF substr(key, 1, 1) <> '#'
      THEN
        -- ключи с решеткой мы пропускаем
        IF p_is_url
        THEN
          rpctext :=  /*encode*/
           (get_context(key));
        ELSE
          rpctext := '''' || get_context(key) || '''';
        END IF;
        res := REPLACE(res, '<#' || key || '>', rpctext);
      END IF;
      key := context_ht.next(key);
    END LOOP;
    -- проверяем, все ли заменилось
    posb := instr(res, '<#');
    IF posb > 0
    THEN
      pose := instr(res, '>', posb);
      IF pose > 0
      THEN
        -- нашли конец плохого места в шаблоне
        bad_key := substr(res, posb, pose - posb + 1);
      END IF;
      err_text := 'REPCORE: Контекст установлен не полностью, либо неверный шаблон. Обратитесь к администратору.';
      IF bad_key IS NOT NULL
      THEN
        err_text := err_text || ' Найдена ошибка: ' || bad_key;
      END IF;
      raise_application_error(-20000, err_text);
    END IF;
    RETURN res;
  END;

  FUNCTION report_ids_by_context RETURN num_table_type
    PIPELINED IS
    cur         refcursor_type;
    report_id   NUMBER;
    l_condition rep_context.rep_context%TYPE;
    l_form      rep_context.form%TYPE;
    res         INTEGER;
  BEGIN
    OPEN cur FOR
      SELECT rep_report_id
            ,rep_context
            ,form
        FROM rep_context
       WHERE (form = get_context('#FORM'))
         AND (datablock IS NULL OR datablock = get_context('#BLOCK'));
    LOOP
      -- цикл по записям контекста для данной формы/блока
      FETCH cur
        INTO report_id
            ,l_condition
            ,l_form;
      EXIT WHEN cur%NOTFOUND;
      IF l_condition IS NOT NULL
         AND l_form = get_context('#FORM')
      THEN
        -- есть дополнительный контекст и требуется проверка
        -- производим замены в шаблоне
        l_condition := apply_context(l_condition, FALSE);
        BEGIN
          EXECUTE IMMEDIATE 'begin select 1 into :res from dual where (' || l_condition || '); end;'
            USING OUT res;
          PIPE ROW(report_id); -- строка нам подходит
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            NULL; -- проверка не прошла
          WHEN OTHERS THEN
            raise_application_error(-20000
                                   ,'REPCORE: Ошибка при проверке контекста! Обратитесь к администратору. Условие: ( "' ||
                                    l_condition || '")');
        END;
      ELSE
        PIPE ROW(report_id); -- доп. обработка не требуется, отдаем сразу
      END IF;
    END LOOP;
    CLOSE cur;
    RETURN;
  END;

  FUNCTION get_context(p_key VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    IF context_ht.exists(upper(p_key))
    THEN
      RETURN context_ht(upper(p_key));
    ELSE
      raise_application_error(-20000
                             ,'REPCORE: Значение контекстной переменной "' || upper(p_key) ||
                              '" не найдено. Обратитесь к администратору.');
    END IF;
  END;

  PROCEDURE set_interface_context
  (
    p_form  VARCHAR2
   ,p_block VARCHAR2
   ,p_item  VARCHAR2
  ) IS
  BEGIN
    context_ht('#FORM') := p_form;
    context_ht('#BLOCK') := p_block;
    context_ht('#ITEM') := p_item;
  END;

  PROCEDURE clear_context IS
  BEGIN
    context_ht.delete;
  END;

  PROCEDURE set_context
  (
    p_key   VARCHAR2
   ,p_value VARCHAR2
  ) IS
  BEGIN
    IF instr(p_key, '#') > 0
       OR instr(p_key, '<') > 0
       OR instr(p_key, '>') > 0
    THEN
      raise_application_error(-20000
                             ,'REPCORE: Для контекстных переменных нельзя использовать имена, содержащие знаки "#", "<", ">". Попытка дать имя "' ||
                              upper(p_key) || '". Обратитесь к администратору.');
    END IF;
    IF length(p_value) > 128
    THEN
      raise_application_error(-20000
                             ,'REPCORE: Значение контекстной переменной "' || upper(p_key) ||
                              '" превышает максимальную длину. Обратитесь к администратору.');
    END IF;
    context_ht(upper(p_key)) := p_value;
  END;

  FUNCTION context_as_string RETURN VARCHAR2 IS
    l_str VARCHAR2(2048);
    key   VARCHAR2(64);
  BEGIN
    key := context_ht.first;
    WHILE key IS NOT NULL
    LOOP
      l_str := l_str || key || ' = "' || context_ht(key) || '"   ';
      key   := context_ht.next(key);
    END LOOP;
    RETURN l_str;
  END;

  FUNCTION prepare_paremeters(p_text VARCHAR2 /*, p_like_diskoverer boolean := false*/) RETURN VARCHAR2 IS
    res VARCHAR2(6000);
  BEGIN
    res := apply_context(p_text, TRUE); -- применяем контекст
    IF substr(res, 1, 1) <> '&'
    THEN
      res := '&' || res;
    END IF;
    RETURN res;
  END;

  FUNCTION encode(val VARCHAR2) RETURN VARCHAR2 AS
  BEGIN
    RETURN utl_url.escape(val, TRUE, 'UTF8');
  END;

  FUNCTION decode(val VARCHAR2) RETURN VARCHAR2 AS
  BEGIN
    RETURN utl_url.unescape(val, 'UTF8');
  END;

  PROCEDURE decode(val IN OUT VARCHAR2) AS
  BEGIN
    val := decode(val);
  END;

  PROCEDURE set_modal_result(mr NUMBER) AS
  BEGIN
    IF mr NOT IN (utils.c_true, utils.c_false)
    THEN
      raise_application_error(-20000, 'REPCORE: SET_MODAL_RESULT failed. Bad parameter.');
    END IF;
    form_modal_result := mr;
  END;

  FUNCTION get_modal_result RETURN NUMBER AS
  BEGIN
    RETURN form_modal_result;
  END;

BEGIN
  context_ht('#FORM') := '#';
  context_ht('#BLOCK') := '#';
END REPCORE;
/

CREATE OR REPLACE PACKAGE pkg_rate IS

  -- opatsan
  -- загрузка курсов валют из ЦБ
  -- http://www.cbr.ru/scripts/Root.asp?Prtid=SXML
  -- Байтин А.
  -- Сделал все заново

  TYPE t_currency IS RECORD(
     num_code fund.code%TYPE
    ,NAME     fund.name%TYPE
    ,nominal  fund.rate_qty%TYPE
    ,VALUE    rate.rate_value%TYPE);

  TYPE t_currencies IS TABLE OF t_currency INDEX BY fund.brief%TYPE;

  /*
    Байтин А.
    
    Централизованный вызов ошибок
  */
  PROCEDURE raise_error
  (
    par_error_message VARCHAR2
   ,par_procedure     VARCHAR2
   ,par_package       VARCHAR2 DEFAULT 'PKG_RATE'
   ,par_process_name  VARCHAR2 DEFAULT 'Импорт курсов валют'
  );

  /*
    Байтин А.
  
    Базовое добавление валюты в справочник курсов валют
  */
  PROCEDURE insert_rate_base
  (
    par_base_fund_id   IN NUMBER
   ,par_contra_fund_id IN NUMBER
   ,par_rate_date      IN DATE
   ,par_rate_type_id   IN NUMBER
   ,par_rate_value     IN NUMBER
   ,par_rate_id        OUT NUMBER
  );

  /*
    Байтин А.
    
    Добавление курса валют в справочник курсов валют
  */
  PROCEDURE insert_rate
  (
    par_fund_brief      IN VARCHAR2
   ,par_rate_date       IN DATE
   ,par_rate_type_brief IN VARCHAR2
   ,par_rate_value      IN NUMBER
   ,par_rate_id         OUT NUMBER
  );

  /*
    Байтин А.
    
    Разбор XML и получение курсов USD и EUR
  */
  PROCEDURE parse_rates
  (
    par_xml        IN CLOB
   ,par_currencies OUT t_currencies
  );

  /*
    Байтин А.
  
    Получение XML с сайта ЦБ на дату
  */

  PROCEDURE import_rates
  (
    par_date          IN DATE
   ,par_reload        IN BOOLEAN DEFAULT FALSE
   ,par_url           IN VARCHAR2 DEFAULT NULL
   ,par_was_errors    OUT BOOLEAN
   ,par_error_message OUT VARCHAR2
  );

END pkg_rate;
/
CREATE OR REPLACE PACKAGE BODY pkg_rate IS

  /*
    Байтин А.
    
    Централизованный вызов ошибок
  */
  PROCEDURE raise_error
  (
    par_error_message VARCHAR2
   ,par_procedure     VARCHAR2
   ,par_package       VARCHAR2 DEFAULT 'PKG_RATE'
   ,par_process_name  VARCHAR2 DEFAULT 'Импорт курсов валют'
  ) IS
    v_error_message VARCHAR2(32767);
  BEGIN
    IF par_error_message IS NULL
    THEN
      raise_application_error(-20001
                             ,'При вызове RAISE_ERROR должно быть указано сообщение об ошибке');
    END IF;
    IF par_process_name IS NOT NULL
    THEN
      v_error_message := par_process_name;
    END IF;
  
    IF par_package IS NOT NULL
    THEN
      v_error_message := v_error_message || ' (';
    
      IF par_package IS NOT NULL
      THEN
        v_error_message := v_error_message || par_package || '.';
      END IF;
    
    END IF;
    IF par_procedure IS NOT NULL
    THEN
      v_error_message := v_error_message || par_procedure || ')';
    ELSE
      raise_application_error(-20001
                             ,'При вызове RAISE_ERROR должно быть указано название процедуры');
    END IF;
    v_error_message := v_error_message || ': ' || par_error_message;
  
    raise_application_error(-20001, v_error_message);
  END raise_error;

  /*
    Байтин А.
  
    Базовое добавление валюты в справочник курсов валют
  */
  PROCEDURE insert_rate_base
  (
    par_base_fund_id   IN NUMBER
   ,par_contra_fund_id IN NUMBER
   ,par_rate_date      IN DATE
   ,par_rate_type_id   IN NUMBER
   ,par_rate_value     IN NUMBER
   ,par_rate_id        OUT NUMBER
  ) IS
  BEGIN
    SELECT sq_rate.nextval INTO par_rate_id FROM dual;
  
    INSERT INTO ven_rate
      (rate_id, base_fund_id, contra_fund_id, rate_date, rate_type_id, rate_value)
    VALUES
      (par_rate_id
      ,par_base_fund_id
      ,par_contra_fund_id
      ,par_rate_date
      ,par_rate_type_id
      ,par_rate_value);
  END insert_rate_base;

  /*
    Байтин А.
    
    Добавление курса валют в справочник курсов валют
  */
  PROCEDURE insert_rate
  (
    par_fund_brief      IN VARCHAR2
   ,par_rate_date       IN DATE
   ,par_rate_type_brief IN VARCHAR2
   ,par_rate_value      IN NUMBER
   ,par_rate_id         OUT NUMBER
  ) IS
    v_fund_id      fund.fund_id%TYPE;
    v_base_fund_id fund.fund_id%TYPE;
    v_rate_type_id rate_type.rate_type_id%TYPE;
    c_procedure CONSTANT VARCHAR2(30) := 'INSERT_RATE';
  BEGIN
    -- Проверки
    BEGIN
      SELECT fu.fund_id INTO v_fund_id FROM fund fu WHERE fu.brief = par_fund_brief;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        raise_error('Не найдена валюта с кодом ISO: "' || par_fund_brief || '"'
                   ,c_procedure);
    END;
  
    BEGIN
      SELECT rt.rate_type_id
            ,rt.base_fund_id
        INTO v_rate_type_id
            ,v_base_fund_id
        FROM RATE_TYPE rt
       WHERE rt.brief = par_rate_type_brief;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        raise_error('Не найден тип курса с кратким наименованием "' || par_rate_type_brief || '"'
                   ,c_procedure);
    END;
  
    IF par_rate_date IS NULL
    THEN
      raise_error('Дата курса должна быть заполнена', c_procedure);
    END IF;
  
    IF par_rate_value IS NULL
    THEN
      raise_error('Должно быть указано значение курса', c_procedure);
    END IF;
    BEGIN
      insert_rate_base(par_base_fund_id   => v_base_fund_id
                      ,par_contra_fund_id => v_fund_id
                      ,par_rate_date      => par_rate_date
                      ,par_rate_type_id   => v_rate_type_id
                      ,par_rate_value     => par_rate_value
                      ,par_rate_id        => par_rate_id);
    EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
        raise_error('Невозможно добавить курс "' || par_fund_brief || '" на дату "' ||
                    to_char(par_rate_date, 'dd.mm.yyyy') || '". Такая запись уже существует.'
                   ,c_procedure);
    END;
  END insert_rate;

  /*
    Байтин А.
    
    Разбор XML и получение курсов USD и EUR
  */
  PROCEDURE parse_rates
  (
    par_xml        IN CLOB
   ,par_currencies OUT t_currencies
  ) IS
    XML_PARSING_FAILED EXCEPTION;
    PRAGMA EXCEPTION_INIT(XML_PARSING_FAILED, -31011);
    c_procedure CONSTANT VARCHAR2(30) := 'PARSE_RATES';
    v_nls_numchar VARCHAR2(1);
  BEGIN
    SELECT substr(np.value, 1, 1)
      INTO v_nls_numchar
      FROM v$nls_parameters np
     WHERE np.parameter = 'NLS_NUMERIC_CHARACTERS';
    FOR vr_xml IN (SELECT extract(VALUE(node), '/Valute/NumCode/text()').getStringVal() AS num_code
                         ,extract(VALUE(node), '/Valute/CharCode/text()').getStringVal() AS char_code
                         ,extract(VALUE(node), '/Valute/Nominal/text()').getStringVal() AS Nominal
                         ,extract(VALUE(node), '/Valute/Name/text()').getStringVal() AS NAME
                         ,extract(VALUE(node), '/Valute/Value/text()').getStringVal() AS VALUE
                     FROM TABLE(XMLSEQUENCE(EXTRACT(XMLTYPE(par_xml), '/ValCurs/Valute'))) node)
    LOOP
      par_currencies(vr_xml.char_code).num_code := vr_xml.num_code;
      par_currencies(vr_xml.char_code).name := vr_xml.name;
      IF v_nls_numchar = '.'
      THEN
        par_currencies(vr_xml.char_code).nominal := to_number(REPLACE(vr_xml.nominal, ',', '.'));
        par_currencies(vr_xml.char_code).VALUE := to_number(REPLACE(vr_xml.VALUE, ',', '.'));
      ELSE
        par_currencies(vr_xml.char_code).nominal := to_number(REPLACE(vr_xml.nominal, '.', ','));
        par_currencies(vr_xml.char_code).VALUE := to_number(REPLACE(vr_xml.VALUE, '.', ','));
      END IF;
    END LOOP;
  EXCEPTION
    WHEN XML_PARSING_FAILED THEN
      raise_error('Невозможно разобрать полученный XML-файл'
                 ,c_procedure);
  END parse_rates;

  /*
    Байтин А.
  
    Получение XML с сайта ЦБ на дату
  */

  PROCEDURE import_rates
  (
    par_date          IN DATE
   ,par_reload        IN BOOLEAN DEFAULT FALSE
   ,par_url           IN VARCHAR2 DEFAULT NULL
   ,par_was_errors    OUT BOOLEAN
   ,par_error_message OUT VARCHAR2
  ) IS
    vt_currencies t_currencies;
    v_rate_id     rate.rate_id%TYPE;
    v_xml         CLOB;
    c_procedure CONSTANT VARCHAR2(30) := 'IMPORT_RATES';
    v_url      t_b2b_props_vals.props_value%TYPE;
  BEGIN
    SAVEPOINT before_import_rates;
    par_was_errors := FALSE;
  
    -- Проверка входных значений
    IF par_date IS NULL
    THEN
      raise_error('Дата импорта курса должна быть заполнена'
                 ,c_procedure);
    END IF;
  
    IF par_reload IS NULL
    THEN
      raise_error('Параметр перезагрузки курсов должен быть указан'
                 ,c_procedure);
    END IF;
  
    --Получаем URL
    v_url := pkg_borlas_b2b.get_b2b_props_val(par_oper_type_brief  => 'UPDATE_RATE'
                                             ,par_props_type_brief => 'URL');
  
    -- Получение курса            
    v_xml := pkg_communication.request(par_url    => nvl(par_url, v_url) ||
                                                     to_char(par_date, 'dd/mm/yyyy')
                                      ,par_method => 'GET'
                                      ,par_use_def_proxy => true);
    -- Парсинг результата
    parse_rates(par_xml => v_xml, par_currencies => vt_currencies);
  
    -- Проверка получения курса USD
    IF NOT vt_currencies.exists('USD')
    THEN
      raise_error('В полученном файле отсутствует курс USD'
                 ,c_procedure);
    END IF;
  
    -- Проверка получения курса EUR
    IF NOT vt_currencies.exists('EUR')
    THEN
      raise_error('В полученном файле отсутствует курс EUR'
                 ,c_procedure);
    END IF;
  
    IF par_reload
    THEN
      DELETE FROM ven_rate r
       WHERE r.rate_date = trunc(par_date)
         AND r.rate_type_id IN (SELECT rt.rate_type_id FROM rate_type rt WHERE rt.brief = 'ЦБ')
         AND r.contra_fund_id IN (SELECT fd.fund_id FROM fund fd WHERE fd.brief IN ('USD', 'EUR'));
    END IF;
    -- Добавление курса USD
    insert_rate(par_fund_brief      => 'USD'
               ,par_rate_date       => trunc(par_date)
               ,par_rate_type_brief => 'ЦБ'
               ,par_rate_value      => vt_currencies('USD').value
               ,par_rate_id         => v_rate_id);
  
    -- Добавление курса EUR
    insert_rate(par_fund_brief      => 'EUR'
               ,par_rate_date       => trunc(par_date)
               ,par_rate_type_brief => 'ЦБ'
               ,par_rate_value      => vt_currencies('EUR').value
               ,par_rate_id         => v_rate_id);
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK TO before_import_rates;
      par_was_errors    := TRUE;
      par_error_message := substr(SQLERRM, 12);
  END import_rates;

END pkg_rate;
/

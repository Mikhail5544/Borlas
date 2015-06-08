CREATE OR REPLACE PACKAGE pkg_percent_rate IS

  TYPE t_percent_rate IS RECORD(
     NAME  percent_rate_type.name%TYPE
    ,DATE  percent_rate.rate_date%TYPE
    ,VALUE percent_rate.rate_value%TYPE);

  gv_refinance_rate_type_id NUMBER;

  /*
    Получение XML с сайта ЦБ
  */
  PROCEDURE import_percent_rates
  (
    par_date          IN DATE
   ,par_reload        IN BOOLEAN DEFAULT FALSE
   ,par_was_errors    OUT BOOLEAN
   ,par_error_message OUT VARCHAR2
  );

END pkg_percent_rate;
/
CREATE OR REPLACE PACKAGE BODY pkg_percent_rate IS

  /*
    Разбор XML и получение ставки рефинансирования ЦБ
  */
  PROCEDURE parse_percent_rates
  (
    par_xml          IN CLOB
   ,par_percent_rate OUT t_percent_rate
  ) IS
    ex_xml_parsing EXCEPTION;
    PRAGMA EXCEPTION_INIT(ex_xml_parsing, -30001);
    cv_proc_name CONSTANT VARCHAR2(50) := 'PKG_PERCENT_RATE.PARSE_PERCENT_RATES';

    v_nls_numchar VARCHAR2(1);
    v_title       VARCHAR2(50);
    v_dt          VARCHAR2(50);
    v_rate        VARCHAR2(50);
  BEGIN
    SELECT substr(np.value, 1, 1)
      INTO v_nls_numchar
      FROM v$nls_parameters np
     WHERE np.parameter = 'NLS_NUMERIC_CHARACTERS';

    WITH t AS (SELECT xmltype(par_xml) xmldata FROM dual)
    SELECT x.title
          ,x.dt
          ,x.rate
      INTO v_title
          ,v_dt
          ,v_rate
      FROM t
          ,xmltable(xmlnamespaces('http://schemas.xmlsoap.org/soap/envelope/' AS "soap"
                                  ,'http://web.cbr.ru/' AS "response")
                    ,'/soap:Envelope/soap:Body/response:MainInfoXMLResponse/response:MainInfoXMLResult/RegData'
                    passing t.xmldata columns title VARCHAR2(50) path 'stavka_ref/@Title'
                    ,dt VARCHAR2(50) path 'stavka_ref/@Date'
                    ,rate VARCHAR2(50) path 'stavka_ref') x;
    IF v_nls_numchar = '.'
    THEN
      v_rate := REPLACE(v_rate, ',', '.');
    ELSE
      v_rate := REPLACE(v_rate, '.', ',');
    END IF;

    par_percent_rate.name  := v_title;
    par_percent_rate.date  := to_date(v_dt, 'DD.MM.YYYY');
    par_percent_rate.value := to_number(v_rate);

  EXCEPTION
    WHEN ex_xml_parsing THEN
      ex.raise(par_message => cv_proc_name ||
                              ': PKG_PERCENT_RATE.Невозможно разобрать полученный XML-файл'
              ,par_sqlcode => ex.c_custom_error);
  END parse_percent_rates;

  /*
    Получение XML с сайта ЦБ
  */
  PROCEDURE import_percent_rates
  (
    par_date          IN DATE
   ,par_reload        IN BOOLEAN DEFAULT FALSE
   ,par_was_errors    OUT BOOLEAN
   ,par_error_message OUT VARCHAR2
  ) IS
    cv_proc_name CONSTANT VARCHAR2(50) := 'PKG_PERCENT_RATE.IMPORT_PERCENT_RATES';

    v_url          t_b2b_props_vals.props_value%TYPE;
    v_send         CLOB := '<?xml version="1.0" encoding="utf-8"?>
                    <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
                    <soap:Body>
                    <MainInfoXML xmlns="http://web.cbr.ru/" />
                    </soap:Body>
                    </soap:Envelope>';
    v_xml          CLOB;
    v_percent_rate t_percent_rate;

  BEGIN
    SAVEPOINT before_import_rates;
    par_was_errors := FALSE;

    -- Проверка входных значений
    IF par_date IS NULL
    THEN
      ex.raise(par_message => cv_proc_name ||
                              ': Дата импорта ставки рефинансирования должна быть заполнена'
              ,par_sqlcode => ex.c_custom_error);
    END IF;

    IF par_reload IS NULL
    THEN
      ex.raise(par_message => cv_proc_name ||
                              ': Параметр перезагрузки ставки рефинансирования должен быть указан'
              ,par_sqlcode => ex.c_custom_error);
    END IF;

    --Получаем URL
    v_url := pkg_borlas_b2b.get_b2b_props_val(par_oper_type_brief  => 'UPDATE_PERCENT_RATE'
                                             ,par_props_type_brief => 'URL');

    -- Получение курса
    v_xml := pkg_communication.request(par_url           => v_url
                                      ,par_method        => 'POST'
                                      ,par_send          => v_send
                                      ,par_content_type  => 'text/xml'
                                      ,par_use_def_proxy => TRUE);

    -- Парсинг результата
    parse_percent_rates(par_xml => v_xml, par_percent_rate => v_percent_rate);

    -- Проверка получения ставки рефинансирования
    IF v_percent_rate.value IS NULL
    THEN
      ex.raise(par_message => cv_proc_name ||
                              ': В полученном файле отсутствует ставка рефинансирования ЦБ'
              ,par_sqlcode => ex.c_custom_error);
    END IF;

    -- Добавление ставки рефинансирования
    IF par_reload
    THEN
      DELETE FROM percent_rate pr
       WHERE pr.rate_date = trunc(par_date)
         AND pr.percent_rate_type_id = gv_refinance_rate_type_id;
    END IF;

    INSERT INTO ven_percent_rate
      (percent_rate_type_id, rate_date, rate_value)
    VALUES
      (gv_refinance_rate_type_id, trunc(par_date), v_percent_rate.value);

  EXCEPTION
    WHEN dup_val_on_index THEN
      ROLLBACK TO before_import_rates;
      par_was_errors    := TRUE;
      par_error_message := cv_proc_name ||
                           ': Невозможно добавить ставку рефинансирования ЦБ на дату "' ||
                           to_char(par_date, 'dd.mm.yyyy') || '". Такая запись уже существует.';
    WHEN OTHERS THEN
      ROLLBACK TO before_import_rates;
      par_was_errors    := TRUE;
      par_error_message := SQLERRM;
  END import_percent_rates;

BEGIN
  SELECT prt.percent_rate_type_id
    INTO gv_refinance_rate_type_id
    FROM percent_rate_type prt
   WHERE prt.brief = 'REFIN_CB';
END pkg_percent_rate;
/
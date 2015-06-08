CREATE OR REPLACE PACKAGE pkg_utils IS

  gс_exp_bind_vars               CONSTANT VARCHAR2(255) := ':\w+';
  gс_exp_hyperlinks              CONSTANT VARCHAR2(255) := '<a href="[^"]+">[^<]+</a>';
  gс_exp_ip_addresses            CONSTANT VARCHAR2(255) := '(\d{1,3}\.){3}\d{1,3}';
  gс_exp_email_addresses         CONSTANT VARCHAR2(255) := '[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}';
  gс_exp_email_address_list      CONSTANT VARCHAR2(255) := '^((\s*[a-zA-Z0-9\._%-]+@[a-zA-Z0-9\.-]+\.[a-zA-Z]{2,4}\s*[,;:]){1,100}?)?(\s*[a-zA-Z0-9\._%-]+@[a-zA-Z0-9\.-]+\.[a-zA-Z]{2,4})*$';
  gс_exp_double_words            CONSTANT VARCHAR2(255) := ' ([A-Za-z]+) \1';
  gс_exp_cc_visa                 CONSTANT VARCHAR2(255) := '^4[0-9]{12}(?:[0-9]{3})?$';
  gс_exp_square_brackets         CONSTANT VARCHAR2(255) := '\[(.*?)\]';
  gс_exp_curly_brackets          CONSTANT VARCHAR2(255) := '{(.*?)}';
  gс_exp_square_or_curl_brackets CONSTANT VARCHAR2(255) := '\[.*?\]|\{.*?\}';

  FUNCTION int2speech
  (
    dig IN NUMBER
   ,sex IN VARCHAR2
  ) RETURN VARCHAR2;
  FUNCTION float2speech
  (
    VALUE IN NUMBER
   ,sex   IN VARCHAR2
   ,power IN INTEGER
  ) RETURN VARCHAR2;
  FUNCTION inttospeech
  (
    dig IN NUMBER
   ,sex IN VARCHAR2
  ) RETURN VARCHAR2;
  --Сумма в валюте прописью
  FUNCTION money2speech
  (
    quant     IN NUMBER
   ,p_fund_id IN NUMBER
  ) RETURN VARCHAR2;
  FUNCTION money2sp
  (
    quant     IN NUMBER
   ,p_fund_id IN NUMBER
  ) RETURN VARCHAR2;
  --Дата в родительном падеже
  FUNCTION date2genitive_case
  (
    p_date    DATE
   ,p_is_full NUMBER DEFAULT NULL
   ,p_quotes  NUMBER DEFAULT NULL
  ) RETURN VARCHAR2;
  --Разобрать ФИО на составные части
  PROCEDURE fio2full_name
  (
    p_fio         IN VARCHAR2
   ,p_last_name   OUT VARCHAR2
   ,p_first_name  OUT VARCHAR2
   ,p_middle_name OUT VARCHAR2
  );

  PROCEDURE return_from_select
  (
    p_sql IN VARCHAR2
   ,p_in  IN NUMBER
   ,p_out OUT VARCHAR2
  );

  --Склонение слова "месяц"
  FUNCTION month_declension(p_number NUMBER) RETURN VARCHAR2;

  --Склонение слова "год"
  FUNCTION year_declension(p_number NUMBER) RETURN VARCHAR2;

  --Склонение слова "день"
  FUNCTION day_declension(p_number NUMBER) RETURN VARCHAR2;

  --Дробные числа прописью
  FUNCTION float2speech
  (
    p_val NUMBER
   ,p_sex VARCHAR2 DEFAULT 'M'
  ) RETURN VARCHAR2;

  /**
   Падежная форма по должностям, организациям, подразделениям
   @autor Чикашова О.
   @param p_post строка, содержащая наименование должности, организации, подразделения организации
   @param p_padzh падеж (буквы русскиe): 'р'|'Р'-родительный, 'д'|'Д'-дательный,etc., либо цифры: 1-именительный, 2-родительный, 3-дательный, etc.
   @param p_sex -- пол 'ж'|'Ж'|'м'|'М' (по умолчанию используется склонение для мужского рода)
   @return Падежная форма
  */
  FUNCTION post_declination
  (
    p_post  IN VARCHAR2
   ,p_padzh IN VARCHAR2
   ,p_gen   IN VARCHAR2 DEFAULT 'м'
  ) RETURN VARCHAR2;

  /**
   Преобразует записи в строку
   @autor Чирков В.
   @param curvar_in курсор с одним полем varchar2 не более 100 символов
   @param separator разделитель
   @return строка созданная из записей курсора
  */
  FUNCTION get_aggregated_string
  (
    par_table     tt_one_col
   ,par_separator VARCHAR2
  ) RETURN VARCHAR2;

  /*
    Байтин А.
    Возвращает таблицу строк из строки с разделителями
  */
  FUNCTION get_splitted_string
  (
    par_string    VARCHAR2
   ,par_separator VARCHAR2
  ) RETURN tt_one_col;

  /*
    Байтин А.

    Возвращает хэш строки, переданной на вход.
    Хэш получается шифрованием строки по алгоритму MD5, преобразования результата в raw,
    чтобы отсутствовали непечатные символы
  */
  FUNCTION get_md5_string(par_input VARCHAR2) RETURN VARCHAR2 DETERMINISTIC;

  /*
    Байтин А.

    Возвращает разделитель десятичных знаков
  */
  FUNCTION get_numeric_delimeter(par_raise_on_error BOOLEAN DEFAULT TRUE) RETURN VARCHAR2;

  /*
    Байтин А.

    Возвращает хэш строки по алгоритму SHA-256
  */

  FUNCTION get_sha256(par_input VARCHAR2) RETURN VARCHAR2;

  /** Функция определяет является ли год високосным
  * @autor Чирков В.Ю.
  * @param par_date - вводимая дата
  */
  FUNCTION is_leap_year(par_date DATE) RETURN NUMBER;

  /** Функция работает также как и стандартная add_month,
  * но исправялет баг, когда мы из 28 февраля невисокосного года получаем дату феврая високосного года
  * Например add_months(date '2015-02-28',12) = 29.02.2016
  *          add_months(date '2015-02-27',12) = 27.02.2016 и мы не можем никак получить 27.02.2016
  * @autor Чирков В.Ю.
  * @param par_date - вводимая дата
  */
  FUNCTION add_months_leap
  (
    par_date       DATE
   ,par_cnt_months INTEGER
  ) RETURN DATE;

  /*
    Байтин А.

    Заменяет переменные значениями на основании сделанной трассировки
    @param par_trace_log_ids - Коллекция ИД строк лога трассировки
    @param par_object_name  - Название PL/SQL объекта
    @param par_object_type  - Тип PL/SQL объекта (как он назвается в user_objects)
    @param par_start_line   - Номер первой строки исходного кода
    @param par_end_line     - Номер последней строки исходного кода
  */
  FUNCTION replace_variables
  (
    par_trace_log_ids tt_one_col
   ,par_object_name   user_source.name%TYPE
   ,par_object_type   user_source.type%TYPE
   ,par_start_line    user_source.line%TYPE DEFAULT NULL
   ,par_end_line      user_source.line%TYPE DEFAULT NULL
  ) RETURN CLOB;

  /*
  Функция is_database_procedure
  проверяет, является ли процедурой пакета БД набор параметров par_package_name.par_procedure_name

  @param par_package_name - название пакета
  @param par_procedure_name - название процедуры
  @param par_owner - схема (значение по умолчанию - INS)

  Возвращаемое значение:
  1, если par_package_name.par_procedure_name является процедурой пакета бд
  0, если par_package_name.par_procedure_name процедурой не является
  null, если par_package_name или par_procedure_name пусты
  null, если возникла ошибка
  */

  FUNCTION is_database_procedure
  (
    par_package_name   IN VARCHAR2
   ,par_procedure_name IN VARCHAR2
   ,par_owner          IN VARCHAR2 DEFAULT 'INS'
  ) RETURN NUMBER;

END;
/
CREATE OR REPLACE PACKAGE BODY pkg_utils IS

  FUNCTION int2speech
  (
    dig IN NUMBER
   ,sex IN VARCHAR2
  ) RETURN VARCHAR2 IS
    ret       VARCHAR2(300);
    remainder NUMBER;
  BEGIN
    remainder := trunc(MOD(dig, 1000) / 100);
    SELECT decode(remainder
                 ,1
                 ,'сто '
                 ,2
                 ,'двести '
                 ,3
                 ,'триста '
                 ,4
                 ,'четыреста '
                 ,

                  5
                 ,'пятьсот '
                 ,6
                 ,'шестьсот '
                 ,7
                 ,'семьсот '
                 ,8
                 ,'восемьсот '
                 ,9
                 ,'девятьсот ')
      INTO ret
      FROM dual;
    IF upper(sex) IN ('M', 'F')
    THEN
      remainder := trunc(MOD(dig, 100) / 10);
      SELECT ret || decode(remainder
                          ,1
                          ,decode(MOD(dig, 10)
                                 ,0
                                 ,'десять '
                                 ,

                                  1
                                 ,'одиннадцать '
                                 ,2
                                 ,'двенадцать '
                                 ,3
                                 ,'тринадцать '
                                 ,4
                                 ,'четырнадцать '
                                 ,5
                                 ,'пятнадцать '
                                 ,6
                                 ,'шестнадцать '
                                 ,7
                                 ,'семнадцать '
                                 ,8
                                 ,'восемнадцать '
                                 ,9
                                 ,'девятнадцать ')
                          ,2
                          ,'двадцать '
                          ,3
                          ,'тридцать '
                          ,4
                          ,'сорок '
                          ,5
                          ,'пятьдесят '
                          ,6
                          ,'шестьдесят '
                          ,7
                          ,'семьдесят '
                          ,

                           8
                          ,'восемьдесят '
                          ,9
                          ,'девяносто ')
        INTO ret
        FROM dual;
    ELSE
      remainder := trunc(MOD(dig, 100) / 10);
      SELECT ret ||
             decode(remainder
                   ,1
                   ,decode(MOD(dig, 10)
                          ,0
                          ,'десятого '
                          ,1
                          ,'одиннадцатого '
                          ,2
                          ,'двенадцатого '
                          ,3
                          ,'тринадцатого '
                          ,4
                          ,'четырнадцатого '
                          ,5
                          ,'пятнадцатого '
                          ,6
                          ,'шестнадцатого '
                          ,7
                          ,'семнадцатого '
                          ,8
                          ,'восемнадцатого '
                          ,9
                          ,'девятнадцатого ')
                   ,2
                   ,decode(remainder, MOD(dig, 100) / 10, 'двадцатое ', 'двадцать ')
                   ,3
                   ,decode(remainder, MOD(dig, 100) / 10, 'тридцатое ', 'тридцать ')
                   ,4
                   ,decode(remainder, MOD(dig, 100) / 10, 'сороковое ', 'сорок ')
                   ,5
                   ,decode(remainder
                          ,MOD(dig, 100) / 10
                          ,'пятидесятое '
                          ,'пятьдесят ')
                   ,6
                   ,decode(remainder
                          ,MOD(dig, 100) / 10
                          ,'шестидесятое '
                          ,'шестьдесят ')
                   ,7
                   ,decode(remainder
                          ,MOD(dig, 100) / 10
                          ,'семидесятое '
                          ,'семьдесят ')
                   ,8
                   ,decode(remainder
                          ,MOD(dig, 100) / 10
                          ,'восьмидесятое '
                          ,'восемьдесят ')
                   ,9
                   ,decode(remainder
                          ,MOD(dig, 100) / 10
                          ,'девяностое '
                          ,'девяносто '))
        INTO ret
        FROM dual;
    END IF;
    IF remainder = 1
    THEN
      RETURN ret;
    END IF;
    remainder := MOD(dig, 10);
    IF upper(sex) IN ('M', 'F')
    THEN
      SELECT ret || decode(remainder
                          ,1
                          ,decode(upper(sex), 'M', 'один ', 'F', 'одна ')
                          ,2
                          ,decode(upper(sex), 'M', 'два ', 'F', 'две ')
                          ,3
                          ,'три '
                          ,4
                          ,'четыре '
                          ,

                           5
                          ,'пять '
                          ,6
                          ,'шесть '
                          ,7
                          ,'семь '
                          ,8
                          ,'восемь '
                          ,9
                          ,'девять ')
        INTO ret
        FROM dual;
    ELSE
      SELECT ret || decode(remainder
                          ,1
                          ,'первое '
                          ,2
                          ,'второе '
                          ,3
                          ,'третье '
                          ,4
                          ,'четвертое '
                          ,5
                          ,'пятое '
                          ,6
                          ,'шестое '
                          ,7
                          ,'седьмое '
                          ,8
                          ,'восьмое '
                          ,9
                          ,'девятое ')
        INTO ret
        FROM dual;
    END IF;
    RETURN ret;
  END;

  FUNCTION float2speech
  (
    VALUE IN NUMBER
   ,sex   IN VARCHAR2
   ,power IN INTEGER
  ) RETURN VARCHAR2 IS
    ret VARCHAR2(300);
    p   VARCHAR2(1);
    i   INTEGER;
  BEGIN
    IF power = 0
    THEN
      ret := '';
      p   := sex;
      i   := -1;
    ELSE
      IF power > 1
      THEN
        p := 'M';
      ELSE
        p := 'F';
      END IF;

      i := trunc(VALUE);
      IF trunc(MOD(i, 100) / 10) = 1
      THEN
        i := 5;
      ELSE
        i := MOD(i, 10);
      END IF;

      IF i = 1
      THEN
        SELECT decode(p, 'M', ' ', 'F', 'а ') || ret INTO ret FROM dual;
      ELSIF (i >= 2)
            AND (i <= 4)
      THEN
        SELECT decode(p, 'M', 'а ', 'F', 'и ') || ret INTO ret FROM dual;
      ELSE
        SELECT decode(p, 'M', 'ов ', 'F', ' ') || ret INTO ret FROM dual;
      END IF;

      IF (trunc(VALUE) MOD 1000) <> 0
      THEN
        SELECT decode(power
                     ,1
                     ,'тысяч'
                     ,2
                     ,'миллион'
                     ,3
                     ,'миллиард'
                     ,4
                     ,'триллион') || ret
          INTO ret
          FROM dual;
      END IF;
    END IF;
    ret := int2speech(trunc(VALUE) MOD 1000, p) || ret;
    IF VALUE >= 1000
    THEN
      ret := float2speech(VALUE / 1000, p, power + 1) || ret;
    END IF;
    RETURN ret;
  END;

  FUNCTION inttospeech
  (
    dig IN NUMBER
   ,sex IN VARCHAR2
  ) RETURN VARCHAR2 IS
    ret VARCHAR2(300);
  BEGIN
    ret := float2speech(abs(dig), sex, 0);

    IF ret IS NULL
    THEN
      RETURN 'ноль';
    ELSIF dig < 0
    THEN
      RETURN 'минус ' || ret;
    ELSE
      RETURN ret;
    END IF;
    RETURN ret;
  END;

  FUNCTION money2speech
  (
    quant     IN NUMBER
   ,p_fund_id IN NUMBER
  ) RETURN VARCHAR2 IS
    ret           VARCHAR2(500);
    v_whole_value NUMBER;
    v_whole_brief VARCHAR2(30);
    v_fract_value NUMBER;
    v_fract_brief VARCHAR2(30);
    v_last_digit  NUMBER;
    v_fund        fund%ROWTYPE;
  BEGIN
    SELECT * INTO v_fund FROM fund f WHERE f.fund_id = p_fund_id;
    v_whole_value := ROUND(quant, 2);
    v_fract_value := abs(v_whole_value - trunc(v_whole_value)) * 100;
    v_whole_value := trunc(v_whole_value);

    v_last_digit := to_number(substr(to_char(v_whole_value), length(to_char(v_whole_value)), 1));
    IF (length(to_char(v_whole_value)) > 1)
    THEN
      IF substr(to_char(v_whole_value), length(to_char(v_whole_value)) - 1, 1) = '1'
      THEN
        v_last_digit := v_last_digit + 10;
      END IF;
    END IF;
    v_whole_brief := (CASE v_last_digit
                       WHEN 1 THEN
                        v_fund.spell_1_whole
                       WHEN 2 THEN
                        v_fund.spell_2_whole
                       WHEN 3 THEN
                        v_fund.spell_2_whole
                       WHEN 4 THEN
                        v_fund.spell_2_whole
                       ELSE
                        v_fund.spell_5_whole
                     END);

    v_last_digit := to_number(substr(to_char(v_fract_value), length(to_char(v_fract_value)), 1));
    IF (length(to_char(v_fract_value)) > 1)
    THEN
      IF substr(to_char(v_fract_value), length(to_char(v_fract_value)) - 1, 1) = '1'
      THEN
        v_last_digit := v_last_digit + 10;
      END IF;
    END IF;
    v_fract_brief := (CASE v_last_digit
                       WHEN 1 THEN
                        v_fund.spell_1_fract
                       WHEN 2 THEN
                        v_fund.spell_2_fract
                       WHEN 3 THEN
                        v_fund.spell_2_fract
                       WHEN 4 THEN
                        v_fund.spell_2_fract
                       ELSE
                        v_fund.spell_5_fract
                     END);

    ret := TRIM(inttospeech(v_whole_value, 'm')) || ' ' || TRIM(v_whole_brief) || ' ' || ', ' ||
           TRIM(to_char(v_fract_value, '00')) || ' ' || TRIM(v_fract_brief);
    RETURN nls_upper(substr(ret, 1, 1)) || substr(ret, 2);
  END;

  FUNCTION money2sp
  (
    quant     IN NUMBER
   ,p_fund_id IN NUMBER
  ) RETURN VARCHAR2 IS
    ret           VARCHAR2(500);
    v_whole_value NUMBER;
    v_whole_brief VARCHAR2(30);
    v_fract_value NUMBER;
    v_fract_brief VARCHAR2(30);
    v_last_digit  NUMBER;
    v_fund        fund%ROWTYPE;
  BEGIN
    SELECT * INTO v_fund FROM fund f WHERE f.fund_id = p_fund_id;
    v_whole_value := ROUND(quant, 2);
    v_fract_value := abs(v_whole_value - trunc(v_whole_value)) * 100;
    v_whole_value := trunc(v_whole_value);

    v_last_digit := to_number(substr(to_char(v_whole_value), length(to_char(v_whole_value)), 1));
    IF (length(to_char(v_whole_value)) > 1)
    THEN
      IF substr(to_char(v_whole_value), length(to_char(v_whole_value)) - 1, 1) = '1'
      THEN
        v_last_digit := v_last_digit + 10;
      END IF;
    END IF;
    v_whole_brief := (CASE v_last_digit
                       WHEN 1 THEN
                        v_fund.spell_short_whole
                       WHEN 2 THEN
                        v_fund.spell_short_whole
                       WHEN 3 THEN
                        v_fund.spell_short_whole
                       WHEN 4 THEN
                        v_fund.spell_short_whole
                       ELSE
                        v_fund.spell_short_whole
                     END);

    v_last_digit := to_number(substr(to_char(v_fract_value), length(to_char(v_fract_value)), 1));
    IF (length(to_char(v_fract_value)) > 1)
    THEN
      IF substr(to_char(v_fract_value), length(to_char(v_fract_value)) - 1, 1) = '1'
      THEN
        v_last_digit := v_last_digit + 10;
      END IF;
    END IF;
    v_fract_brief := (CASE v_last_digit
                       WHEN 1 THEN
                        v_fund.spell_short_fract
                       WHEN 2 THEN
                        v_fund.spell_short_fract
                       WHEN 3 THEN
                        v_fund.spell_short_fract
                       WHEN 4 THEN
                        v_fund.spell_short_fract
                       ELSE
                        v_fund.spell_short_fract
                     END);

    ret := TRIM(to_char(v_whole_value)) || ' ' || TRIM(v_whole_brief) || ' ' ||
           TRIM(to_char(v_fract_value, '00')) || ' ' || TRIM(v_fract_brief);
    RETURN ret;
  END;

  FUNCTION date2genitive_case
  (
    p_date    DATE
   ,p_is_full NUMBER DEFAULT NULL
   ,p_quotes  NUMBER DEFAULT NULL
  ) RETURN VARCHAR2 IS
  BEGIN
    IF p_is_full IS NULL
    THEN
      RETURN CASE WHEN p_quotes = 1 THEN '"' || to_char(p_date, 'dd') || '"' ELSE to_char(p_date
                                                                                         ,'dd') END || ' ' ||(CASE
                                                                                                              to_number(to_char(p_date
                                                                                                                               ,'mm')) WHEN 1 THEN
                                                                                                              'января' WHEN 2 THEN
                                                                                                              'февраля' WHEN 3 THEN
                                                                                                              'марта' WHEN 4 THEN
                                                                                                              'апреля' WHEN 5 THEN
                                                                                                              'мая' WHEN 6 THEN
                                                                                                              'июня' WHEN 7 THEN
                                                                                                              'июля' WHEN 8 THEN
                                                                                                              'августа' WHEN 9 THEN
                                                                                                              'сентября' WHEN 10 THEN
                                                                                                              'октября' WHEN 11 THEN
                                                                                                              'ноября' WHEN 12 THEN
                                                                                                              'декабря' ELSE '' END) || ' ' || to_char(p_date
                                                                                                                                                      ,'yyyy') || CASE WHEN p_quotes = 1 THEN ' г.' ELSE ' года' END;
    ELSE
      RETURN inttospeech(to_number(to_char(p_date, 'dd')), 'D') || ' ' ||(CASE
                                                                          to_number(to_char(p_date
                                                                                           ,'mm')) WHEN 1 THEN
                                                                          'января' WHEN 2 THEN
                                                                          'февраля' WHEN 3 THEN
                                                                          'марта' WHEN 4 THEN
                                                                          'апреля' WHEN 5 THEN 'мая' WHEN 6 THEN
                                                                          'июня' WHEN 7 THEN 'июля' WHEN 8 THEN
                                                                          'августа' WHEN 9 THEN
                                                                          'сентября' WHEN 10 THEN
                                                                          'октября' WHEN 11 THEN
                                                                          'ноября' WHEN 12 THEN
                                                                          'декабря' ELSE '' END) || ' ' || inttospeech(to_number(to_char(p_date
                                                                                                                                        ,'yyyy'))
                                                                                                                      ,'D') || 'года';
    END IF;
  END;

  --Разобрать ФИО на составные части
  PROCEDURE fio2full_name
  (
    p_fio         IN VARCHAR2
   ,p_last_name   OUT VARCHAR2
   ,p_first_name  OUT VARCHAR2
   ,p_middle_name OUT VARCHAR2
  ) IS
    i      NUMBER;
    v_name VARCHAR2(255);
  BEGIN
    v_name := TRIM(p_fio);
    i      := instr(v_name, ' ');
    IF i > 0
    THEN
      p_last_name := TRIM(substr(v_name, 1, i - 1));
      v_name      := TRIM(substr(v_name, i + 1, length(v_name) - i));
      i           := instr(v_name, '.');
      IF i = 0
      THEN
        i := instr(v_name, ' ');
      END IF;
      IF i > 0
      THEN
        p_first_name := TRIM(substr(v_name, 1, i - 1));
        v_name       := TRIM(substr(v_name, i + 1, length(v_name) - i));
        i            := instr(v_name, '.');
        IF i = 0
        THEN
          i := instr(v_name, ' ');
        END IF;
        IF i > 0
        THEN
          p_middle_name := TRIM(substr(v_name, 1, i - 1));
        ELSE
          p_middle_name := TRIM(v_name);
        END IF;
      ELSE
        p_first_name := TRIM(v_name);
      END IF;
    ELSE
      p_last_name := v_name;
    END IF;
  END;

  PROCEDURE return_from_select
  (
    p_sql IN VARCHAR2
   ,p_in  IN NUMBER
   ,p_out OUT VARCHAR2
  ) IS
  BEGIN
    -- Байтин А.
    -- Непонятно зачем это и потенциально опасно
    /*EXECUTE IMMEDIATE p_sql
    USING OUT p_out, IN p_in;*/
    raise_application_error(-20001
                           ,'Ошибка в PKG_UTILS.return_from_select. Обратитесь к разработчикам/администратору.');
  END;

  PROCEDURE clear_schema(p_pwd IN VARCHAR2) IS
  BEGIN
    RETURN; --Ибо нефиг
    IF p_pwd = 'superpuperinsurance'
    THEN
      FOR rc IN (SELECT t.constraint_name FROM user_constraints t)
      LOOP
        BEGIN
          EXECUTE IMMEDIATE 'drop constraint ' || rc.constraint_name;
        EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END;
      END LOOP;
      FOR rc IN (SELECT t.table_name FROM user_tables t)
      LOOP
        BEGIN
          EXECUTE IMMEDIATE 'drop table ' || rc.table_name || ' cascade constraints';
        EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END;
      END LOOP;
      FOR rc IN (SELECT t.sequence_name FROM user_sequences t)
      LOOP
        BEGIN
          EXECUTE IMMEDIATE 'drop sequence ' || rc.sequence_name;
        EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END;
      END LOOP;
      FOR rc IN (SELECT t.view_name FROM user_views t)
      LOOP
        BEGIN
          EXECUTE IMMEDIATE 'drop view ' || rc.view_name;
        EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END;
      END LOOP;
      FOR rc IN (SELECT DISTINCT NAME
                                ,TYPE
                   FROM user_source)
      LOOP
        BEGIN
          EXECUTE IMMEDIATE 'drop ' || rc.type || ' ' || rc.name;
        EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END;
      END LOOP;
      FOR rc IN (SELECT t.type_name FROM user_types t)
      LOOP
        BEGIN
          EXECUTE IMMEDIATE 'drop type ' || rc.type_name;
        EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END;
      END LOOP;
    END IF;
  END;

  FUNCTION month_declension(p_number NUMBER) RETURN VARCHAR2 IS
    v_num NUMBER;
    v_tmp NUMBER;
  BEGIN
    IF p_number IS NOT NULL
    THEN
      v_tmp := abs(p_number);
      v_num := v_tmp - trunc(v_tmp, -2);
      CASE
        WHEN v_num IN (0) THEN
          RETURN 'месяцев';
        WHEN v_num IN (1) THEN
          RETURN 'месяц';
        WHEN v_num IN (2, 3, 4) THEN
          RETURN 'месяца';
        WHEN v_num BETWEEN 5 AND 20 THEN
          RETURN 'месяцев';
        ELSE
          v_num := v_num - trunc(v_num, -1);
          CASE
            WHEN v_num IN (1) THEN
              RETURN 'месяц';
            WHEN v_num IN (2, 3, 4) THEN
              RETURN 'месяца';
            ELSE
              RETURN 'месяцев';
          END CASE;
      END CASE;
    ELSE
      RETURN 'месяцев';
    END IF;
  END;

  FUNCTION year_declension(p_number NUMBER) RETURN VARCHAR2 IS
    v_num NUMBER;
    v_tmp NUMBER;
  BEGIN
    IF p_number IS NOT NULL
    THEN
      v_tmp := abs(p_number);
      v_num := v_tmp - trunc(v_tmp, -2);
      CASE
        WHEN v_num IN (0) THEN
          RETURN 'лет';
        WHEN v_num IN (1) THEN
          RETURN 'года';
        WHEN v_num BETWEEN 2 AND 20 THEN
          RETURN 'лет';
        ELSE
          v_num := v_num - trunc(v_num, -1);
          CASE
            WHEN v_num IN (1) THEN
              RETURN 'года';
            ELSE
              RETURN 'лет';
          END CASE;
      END CASE;
    ELSE
      RETURN 'лет';
    END IF;
  END;

  FUNCTION day_declension(p_number NUMBER) RETURN VARCHAR2 IS
    v_num NUMBER;
    v_tmp NUMBER;
  BEGIN
    IF p_number IS NOT NULL
    THEN
      v_tmp := abs(p_number);
      v_num := v_tmp - trunc(v_tmp, -2);
      CASE
        WHEN v_num IN (0) THEN
          RETURN 'дней';
        WHEN v_num IN (1) THEN
          RETURN 'день';
        WHEN v_num IN (2, 3, 4) THEN
          RETURN 'дня';
        WHEN v_num BETWEEN 5 AND 20 THEN
          RETURN 'дней';
        ELSE
          v_num := v_num - trunc(v_num, -1);
          CASE
            WHEN v_num IN (1) THEN
              RETURN 'день';
            WHEN v_num IN (2, 3, 4) THEN
              RETURN 'дня';
            ELSE
              RETURN 'дней';
          END CASE;
      END CASE;
    ELSE
      RETURN 'дней';
    END IF;
  END;

  FUNCTION float2speech
  (
    p_val NUMBER
   ,p_sex VARCHAR2 DEFAULT 'M'
  ) RETURN VARCHAR2 IS
    v_numi NUMBER;
    v_numf VARCHAR2(20);
    v_str  VARCHAR2(2000);
  BEGIN
    CASE
      WHEN p_val < 0 THEN
        v_str := 'минус ';
      WHEN p_val = 0 THEN
        v_str := 'ноль';
      ELSE
        v_str := '';
    END CASE;

    IF p_val <> 0
    THEN
      v_numi := trunc(p_val);
      v_numf := rtrim(substr(to_char(p_val - v_numi), 2), '0');
      v_str  := v_str || TRIM(inttospeech(v_numi, p_sex));
      IF v_numf <> 0
      THEN
        v_str := v_str || ' и ' || TRIM('0' FROM v_numf) || '/' || rpad('1', length(v_numf) + 1, '0');
      END IF;
    END IF;
    RETURN v_str;
  END;

  FUNCTION post_declination
  (
    p_post  IN VARCHAR2
   ,p_padzh IN VARCHAR2
   ,p_gen   IN VARCHAR2 DEFAULT 'м'
  ) RETURN VARCHAR2 IS
    l_pdzh_chr    VARCHAR2(1);
    l_pdzh        PLS_INTEGER;
    l_tailchr     VARCHAR2(1);
    l_uf          VARCHAR2(1) := 'N';
    l_exist_defis VARCHAR2(1) := 'N';
    l_post        VARCHAR2(500);
    l_post_end    VARCHAR2(80);
    --
    FUNCTION term_cmp
    (
      s IN VARCHAR2
     ,t IN VARCHAR2
    ) RETURN BOOLEAN IS
    BEGIN
      IF nvl(length(s), 0) < nvl(length(t), 0)
      THEN
        RETURN FALSE;
      END IF;
      IF substr(lower(s), -length(t)) = t
      THEN
        RETURN TRUE;
      ELSE
        RETURN FALSE;
      END IF;
    END term_cmp;
    --
    FUNCTION single_space
    (
      p_data VARCHAR2
     ,p_dv   VARCHAR2 DEFAULT ' '
    ) RETURN VARCHAR2 IS
      v_str VARCHAR2(2000) := p_data;
    BEGIN
      WHILE instr(v_str, p_dv || p_dv) > 0
      LOOP
        v_str := REPLACE(v_str, p_dv || p_dv, p_dv);
      END LOOP;
      RETURN v_str;
    END single_space;
    --
    PROCEDURE chng
    (
      s     IN OUT VARCHAR2
     ,n     IN NUMBER
     ,pzrod IN VARCHAR2
     ,pzdat IN VARCHAR2
     ,pzvin IN VARCHAR2
     ,pztvo IN VARCHAR2
     ,pzpre IN VARCHAR2
    ) IS
    BEGIN
      IF l_pdzh = 1
      THEN
        NULL;
      ELSE
        SELECT substr(s, 1, length(s) - n) ||
               decode(l_pdzh, 2, pzrod, 3, pzdat, 4, pzvin, 5, pztvo, 6, pzpre)
          INTO s
          FROM dual;
      END IF;
    END chng;
    --
  BEGIN
    -- post_declination()
    l_post := REPLACE(REPLACE(single_space(REPLACE(p_post, '.', '. ')), ' -', '-'), '- ', '-');
    IF l_post IS NULL
    THEN
      RETURN p_post;
    END IF;
    l_pdzh_chr := upper(substr(p_padzh, 1, 1));
    SELECT decode(l_pdzh_chr, 'И', 1, 'Р', 2, 'Д', 3, 'В', 4, 'Т', 5, 'П', 6, 0)
      INTO l_pdzh
      FROM dual;
    IF l_pdzh = 0
    THEN
      BEGIN
        l_pdzh := to_number(l_pdzh_chr);
      EXCEPTION
        WHEN OTHERS THEN
          RETURN p_post;
      END;
    END IF;
    IF upper(l_post) = l_post
    THEN
      l_uf := 'Y';
    END IF;
    -- если сдвоенная должность:
    IF instr(l_post, '-') > 0
       AND ((instr(l_post, ' ') > 0 AND instr(l_post, '-') < instr(l_post, ' ')) OR
            instr(l_post, ' ') <= 0)
    THEN
      l_exist_defis := 'Y';
      l_post_end    := substr(l_post, instr(l_post, '-') + 1);
      l_post        := substr(l_post, 1, instr(l_post, '-') - 1);
      l_post_end    := post_declination(l_post_end, p_padzh, p_gen);
    ELSIF instr(l_post, ' ') > 0
    THEN
      l_post_end := substr(l_post, instr(l_post, ' ') + 1);
      l_post     := substr(l_post, 1, instr(l_post, ' ') - 1);
      IF (lower(substr(l_post, -2)) IN
         ('ий', 'ый', 'ай', 'ей', 'ия', 'ая', 'ея', 'ое', 'ее', 'уй', 'ой') AND
         post_declination(substr(l_post_end, 1, length(l_post_end) - 2), 'Т', 'м') <> l_post_end AND
         post_declination(substr(l_post_end, 1, length(l_post_end) - 2), 'Т', 'ж') <> l_post_end)
         OR substr(l_post, -1) IN ('1', '2', '3', '4', '5', '6', '7', '8', '9', '0')
      THEN
        l_post_end := post_declination(l_post_end, p_padzh, p_gen);
      END IF;
    END IF;
    IF l_post IS NOT NULL
    THEN
      -- должность
      l_tailchr := lower(substr(l_post, -1));
      IF l_tailchr NOT IN ('е', 'и', 'у')
      THEN
        IF l_tailchr IN ('б'
                        ,'в'
                        ,'г'
                        ,'д'
                        ,'з'
                        ,'ж'
                        ,'к'
                        ,'л'
                        ,'м'
                        ,'н'
                        ,'п'
                        ,'р'
                        ,'с'
                        ,'т'
                        ,'ф'
                        ,'х'
                        ,'ц'
                        ,'ч'
                        ,'ш'
                        ,'щ')
        THEN
          chng(l_post, 0, 'а', 'у', 'а', 'ом', 'е');
        ELSIF l_tailchr = 'а'
        THEN
          IF lower(substr(l_post, -2)) IN ('га', 'ха', 'ка', 'ша', 'ча', 'ща', 'жа')
             AND lower(p_gen) = 'ж'
          THEN
            chng(l_post, 1, 'и', 'е', 'у', 'ой', 'е');
          ELSE
            chng(l_post, 1, 'ы', 'е', 'у', 'ой', 'е');
          END IF;
        ELSIF l_tailchr = 'я'
        THEN
          IF term_cmp(l_post, 'ья')
          THEN
            chng(l_post, 1, 'и', 'е', 'ю', 'ей', 'е');
          ELSIF term_cmp(l_post, 'ия')
          THEN
            IF lower(p_gen) = 'м'
               OR term_cmp(l_post, 'ьфия')
            THEN
              chng(l_post, 1, 'и', 'е', 'ю', 'ей', 'е');
            ELSE
              chng(l_post, 1, 'и', 'и', 'ю', 'ей', 'и');
            END IF;
          ELSIF term_cmp(l_post, 'ая')
          THEN
            IF lower(substr(l_post, -3, 1)) IN ('ц')
            THEN
              chng(l_post, 2, 'ей', 'ей', 'ую', 'ей', 'ей');
            ELSE
              chng(l_post, 2, 'ей', 'ей', 'ую', 'ей', 'ую');
            END IF;
          ELSE
            chng(l_post, 1, 'и', 'е', 'ю', 'ей', 'е');
          END IF;
        ELSIF l_tailchr = 'й'
        THEN
          IF (term_cmp(l_post, 'кий') OR term_cmp(l_post, 'кий'))
          THEN
            chng(l_post, 2, 'ого', 'ому', 'ого', 'им', 'ом');
          ELSIF term_cmp(l_post, 'ай')
          THEN
            chng(l_post, 1, 'я', 'ю', 'я', 'ем', 'е');
          ELSIF term_cmp(l_post, 'ей')
          THEN
            chng(l_post, 1, 'я', 'ю', 'я', 'ем', 'е');
          ELSIF term_cmp(l_post, 'ий')
          THEN
            chng(l_post, 2, 'его', 'ему', 'его', 'им', 'его');
          ELSIF term_cmp(l_post, 'ый')
          THEN
            chng(l_post, 2, 'ого', 'ому', 'ого', 'ым', 'ого');
          ELSIF term_cmp(l_post, 'ой')
          THEN
            chng(l_post, 2, 'ого', 'ому', 'ого', 'им', 'ом');
          ELSE
            chng(l_post, 1, 'я', 'ю', 'я', 'ем', 'и');
          END IF;
        ELSIF l_tailchr = 'ь'
        THEN
          IF lower(p_gen) = 'м'
          THEN
            chng(l_post, 1, 'я', 'ю', 'я', 'ем', 'е');
          ELSIF lower(substr(l_post, -2)) = 'вь'
          THEN
            chng(l_post, 1, 'и', 'и', 'ь', 'ью', 'и');
          ELSE
            chng(l_post, 1, 'и', 'и', 'ь', 'ью', 'ье');
          END IF;
        ELSIF l_tailchr = 'ц'
              AND term_cmp(l_post, 'ец')
        THEN
          IF lower(substr(l_post, -3)) IN ('аец', 'еец', 'иец', 'оец', 'уец')
          THEN
            chng(l_post, 2, 'йца', 'йцу', 'йца', 'йцем', 'йце');
          ELSIF lower(substr(l_post, -3)) IN
                ('тец', 'бец', 'вец', 'мец', 'нец', 'рец', 'сец')
                AND lower(substr(l_post, -4, 1)) IN
                ('а', 'е', 'и', 'о', 'у', 'ы', 'э', 'ю', 'я', 'ё')
          THEN
            chng(l_post, 2, 'ца', 'цу', 'ца', 'цом', 'це');
          ELSIF lower(substr(l_post, -3)) = 'лец'
          THEN
            chng(l_post, 2, 'ьца', 'ьцу', 'ьца', 'ьцом', 'ьце');
          ELSE
            chng(l_post, 0, 'а', 'у', 'а', 'ом', 'е');
          END IF;
        ELSIF l_tailchr = 'х'
              AND (term_cmp(l_post, 'их') OR term_cmp(l_post, 'ых'))
        THEN
          chng(l_post, 0, NULL, NULL, NULL, NULL, NULL);
        END IF;
      ELSIF l_tailchr = 'е'
      THEN
        chng(l_post, 1, 'я', 'ю', 'е', 'ем', 'е');
      END IF;

    END IF;
    -- окончательная конкатенация
    IF l_exist_defis = 'Y'
    THEN
      l_post := l_post || '-' || l_post_end;
    ELSE
      l_post := l_post || ' ' || l_post_end;
    END IF;
    IF l_uf = 'Y'
    THEN
      l_post := upper(l_post);
    END IF;
    RETURN nvl(ltrim(rtrim(l_post, ' -'), ' -'), ltrim(rtrim(single_space(p_post), ' -'), ' -'));
  END post_declination;

  FUNCTION get_aggregated_string
  (
    par_table     tt_one_col
   ,par_separator VARCHAR2
  ) RETURN VARCHAR2 IS
    v_result VARCHAR2(4000);
  BEGIN
    IF par_table.count > 0
    THEN
      FOR v_idx IN par_table.first .. par_table.last
      LOOP
        v_result := v_result || par_separator || par_table(v_idx);
      END LOOP;
      v_result := ltrim(v_result, par_separator);
    END IF;
    RETURN v_result;
  EXCEPTION
    WHEN value_error THEN
      RETURN 'Превышено количество символов';
  END get_aggregated_string;

  /*
    Байтин А.
    Возвращает таблицу строк из строки с разделителями
  */
  FUNCTION get_splitted_string
  (
    par_string    VARCHAR2
   ,par_separator VARCHAR2
  ) RETURN tt_one_col IS
    v_result    tt_one_col;
    v_string    VARCHAR2(4000);
    v_separator VARCHAR2(255);

  BEGIN

    v_separator := regexp_replace(par_separator, '([.\()$\^])', '\\\1');

    v_string := TRIM(both par_separator FROM par_string) || par_separator;
    SELECT rtrim(regexp_substr(v_string, '.*?' || v_separator, 1, rownum), par_separator) BULK COLLECT
      INTO v_result
      FROM dual
    CONNECT BY regexp_substr(v_string, '.*?' || v_separator, 1, rownum) IS NOT NULL;
    RETURN v_result;
  EXCEPTION
    WHEN value_error THEN
      v_result := tt_one_col('Превышено количество символов');
      RETURN v_result;
  END get_splitted_string;

  /*
    Байтин А.

    Возвращает хэш строки, переданной на вход.
    Хэш получается шифрованием строки по алгоритму MD5, преобразования результата в raw,
    чтобы отсутствовали непечатные символы
  */
  FUNCTION get_md5_string(par_input VARCHAR2) RETURN VARCHAR2 DETERMINISTIC IS
  BEGIN
    RETURN utl_raw.cast_to_raw(dbms_obfuscation_toolkit.md5(input_string => par_input));
  END get_md5_string;

  /*
    Байтин А.

    Возвращает разделитель десятичных знаков
  */
  FUNCTION get_numeric_delimeter(par_raise_on_error BOOLEAN DEFAULT TRUE) RETURN VARCHAR2 IS
    v_nls_numchar VARCHAR2(1);
  BEGIN
    BEGIN
      SELECT substr(np.value, 1, 1)
        INTO v_nls_numchar
        FROM v$nls_parameters np
       WHERE np.parameter = 'NLS_NUMERIC_CHARACTERS';
    EXCEPTION
      WHEN no_data_found THEN
        IF par_raise_on_error
        THEN
          raise_application_error(-20001
                                 ,'Не найдено значение разделителя');
        ELSE
          v_nls_numchar := NULL;
        END IF;
    END;

    RETURN v_nls_numchar;
  END get_numeric_delimeter;

  FUNCTION get_sha256(par_input VARCHAR2) RETURN VARCHAR2 AS
    LANGUAGE JAVA NAME 'SHA256Encoder.getSHA256(java.lang.String) return java.lang.String';

  /** Функция определяет является ли год високосным
  * @autor Чирков В.Ю.
  * @param par_date - вводимая дата
  */
  FUNCTION is_leap_year(par_date DATE) RETURN NUMBER IS
    RESULT NUMBER;
  BEGIN
    SELECT decode(extract(DAY FROM last_day(ADD_MONTHS(trunc(par_date, 'y'), 1))), 29, 1, 0)
      INTO RESULT
      FROM dual;
    RETURN RESULT;
  END is_leap_year;

  /** Функция работает также как и стандартная add_month,
  * но исправляет баг, когда мы из 28 февраля не високосного  года получаем дату февраля високосного года
  * Например если нам нужно из даты 2015-02-28 получить 2016-02-28,
  * то add_months(date '2015-02-28',12) не вернет нужного значения возвратив 2016-02-29
  * @autor Чирков В.Ю.
  * @param par_date - вводимая дата
  */
  FUNCTION add_months_leap
  (
    par_date       DATE
   ,par_cnt_months INTEGER
  ) RETURN DATE IS
    v_correct_koef NUMBER;
  BEGIN
    IF (is_leap_year(par_date) = 0 AND is_leap_year(ADD_MONTHS(par_date, par_cnt_months)) = 1 AND
       to_char(par_date, 'ddmm') = '2802')
    THEN
      v_correct_koef := 1;
    ELSE
      v_correct_koef := 0;
    END IF;

    RETURN ADD_MONTHS(par_date, par_cnt_months) - v_correct_koef;
  END add_months_leap;

  /*
    Байтин А.

    Заменяет переменные значениями на основании сделанной трассировки
    @param par_trace_log_id - Коллекция ИД строк лога трассировки
    @param par_object_name  - Название PL/SQL объекта
    @param par_object_type  - Тип PL/SQL объекта (как он назвается в user_objects)
    @param par_start_line   - Номер первой строки исходного кода
    @param par_end_line     - Номер последней строки исходного кода
  */
  FUNCTION replace_variables
  (
    par_trace_log_ids tt_one_col
   ,par_object_name   user_source.name%TYPE
   ,par_object_type   user_source.type%TYPE
   ,par_start_line    user_source.line%TYPE DEFAULT NULL
   ,par_end_line      user_source.line%TYPE DEFAULT NULL
  ) RETURN CLOB IS
    v_result CLOB;
  BEGIN
    assert_deprecated(par_trace_log_ids.count = 0
          ,'Указание хотя бы одного ИД в par_trace_log_ids обязательно');
    assert_deprecated(par_object_name IS NULL
          ,'Указание название объекта обязательно');
    assert_deprecated(par_object_type IS NULL, 'Указание типа объекта обязательно');
    assert_deprecated(par_start_line IS NOT NULL AND par_end_line IS NOT NULL AND par_start_line > par_end_line
          ,'Номер первой строки не может превышать номер последней строки');
    assert_deprecated(par_start_line <= 0
          ,'Номер первой строки не может быть меньше или равен нулю');
    assert_deprecated(par_end_line <= 0
          ,'Номер последней строки не может быть меньше или равен нулю');

    dbms_lob.createtemporary(lob_loc => v_result, cache => TRUE);
    FOR vr_source IN (SELECT rtrim(us.text, chr(10)) AS text
                        FROM user_source us
                       WHERE us.name = par_object_name
                         AND us.type = par_object_type
                         AND (par_start_line IS NULL OR us.line >= par_start_line)
                         AND (par_end_line IS NULL OR us.line <= par_end_line))
    LOOP
      FOR vr_vars IN (SELECT trace_var_name
                            ,'/*' || trace_var_name || '*/' || CASE
                               WHEN trace_var_type = 'DATE' THEN
                                'to_date(''' || trace_var_value || ''',''dd.mm.yyyy'')'
                               WHEN trace_var_type = 'VARCHAR2' THEN
                                '' || trace_var_value || ''
                               ELSE
                                trace_var_value
                             END AS repl_var_name
                        FROM trace_log_vars va
                       WHERE va.trace_log_id IN (SELECT column_value FROM TABLE(par_trace_log_ids)))
      LOOP
        vr_source.text := regexp_replace(vr_source.text
                                        ,'(^|[^_\dAa-Zz])' || vr_vars.trace_var_name ||
                                         '([^_\dAa-Zz]|$)'
                                        ,'\1' || vr_vars.repl_var_name || '\2');
      END LOOP;
      dbms_lob.writeappend(lob_loc => v_result
                          ,amount  => length(vr_source.text || chr(10))
                          ,buffer  => vr_source.text || chr(10));
    END LOOP;

    RETURN v_result;
  END replace_variables;

  FUNCTION is_database_procedure
  (
    par_package_name   IN VARCHAR2
   ,par_procedure_name IN VARCHAR2
   ,par_owner          IN VARCHAR2 DEFAULT 'INS'
  ) RETURN NUMBER IS
    v_cnt NUMBER;

  BEGIN
    IF (par_package_name IS NULL OR par_procedure_name IS NULL)
    THEN
      RETURN NULL;
    END IF;

    SELECT COUNT(1)
      INTO v_cnt
      FROM all_procedures x
     WHERE x.object_name = upper(par_package_name)
       AND upper(x.procedure_name) = upper(par_procedure_name)
       AND upper(x.owner) = upper(par_owner);

    IF v_cnt = 0
    THEN
      RETURN 0;
    ELSE
      RETURN 1;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;

  END is_database_procedure;

END;
/

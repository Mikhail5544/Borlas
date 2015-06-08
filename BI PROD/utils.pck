CREATE OR REPLACE PACKAGE Utils IS

  /**
    * Пакет, содержащий различные функции общего назначения
  * Содержит функции, процедуры и константы из пакетов:
  * PKG_UTILS (int2speech, float2speech, inttospeech, money2speech, date2genitive_case, fio2full_name, return_from_select)
  * PKG_MESSAGE_UTILS(register_message, get_message)
  * PKG_COMMON_UTILS(miss_num, miss_char, miss_date, c_true, c_false, is_empty)
  * @author Filipp Ganichev
  * @version 1.0
   */
  TYPE hashmap_t IS TABLE OF VARCHAR2(4000) INDEX BY VARCHAR2(100);
  /**
  *  Пустое значение типа number
  */
  miss_num CONSTANT NUMBER := -1;

  /**
  *  Пустое значение типа varchar
  */
  miss_char CONSTANT VARCHAR2(1) := '~';

  /**
  *  Пустое значение типа date
  */
  miss_date CONSTANT DATE := TO_DATE('01.01.1000', 'dd.MM.yyyy');

  /**
  *  Значение true
  */
  c_true CONSTANT NUMBER := 1;

  /**
  *  Значение false
  */
  c_false CONSTANT NUMBER := 0;

  /**
  *  Значение неопределено, либо exception, создано для того, что функция на ровне 
     лож или истана, могла сообщать о возникновении ошибки
  */
  c_exept CONSTANT NUMBER := -1;

  /**
  * Значение true
  * @author Patsan O.
  * @return Значение true
  */
  FUNCTION get_true RETURN NUMBER;

  /**
  * Значение false
  * @author Patsan O.
  * @return Значение false
  */
  FUNCTION get_false RETURN NUMBER;

  /**
  * Пустое значение типа строка
  * @author Patsan O.
  * @return Пустое значение типа строка
  */
  FUNCTION get_miss_char RETURN VARCHAR2;

  /**
  * Пустое значение типа число
  * @author Patsan O.
  * @return Пустое значение типа число
  */
  FUNCTION get_miss_num RETURN NUMBER;

  /**
  * Пустое значение типа дата
  * @author Patsan O.
  * @return Пустое значение типа дата
  */
  FUNCTION get_miss_date RETURN DATE;

  /**
  *  Проверка на пустое значение переменной типа number
  *  @author Filipp Ganichev
  *  @param p_value Значение переменной
  *  @return c_false/c_true
  */
  FUNCTION is_empty(p_value NUMBER) RETURN NUMBER;

  /**
  *  Проверка на пустое значение переменной типа varchar
  *  @author Filipp Ganichev
  *  @param p_value Значение переменной
  *  @return c_false/c_true
  */
  FUNCTION is_empty(p_value VARCHAR2) RETURN NUMBER;

  /**
  *  Проверка на пустое значение переменной типа date
  *  @author Filipp Ganichev
  *  @param p_value Значение переменной
  *  @return c_false/c_true
  */
  FUNCTION is_empty(p_value DATE) RETURN NUMBER;

  /**
  *  Добавляет/изменяет в таблице сообщений информацию о сообщении
  *  @author Filipp Ganichev
  *  @param p_message_brief Краткое имя, идентифицирующее сообщение
  *  @param p_message_name Текст сообщения с параметрами. Параметры в тексте указываются в виде %имя_параметра
  *  @param p_lang_id  Id языка в таблице lang. Необходимо задать либо p_lang_brief, либо p_lang_id
  *  @param p_upd_mes_if_exists Если параметр равен c_true, то текст сообщения будет изменен, если сообщение уже есть в таблице, иначе будет сгенерирована исключительная ситуация
  */
  PROCEDURE register_message
  (
    p_message_brief     VARCHAR2
   ,p_message_name      VARCHAR2
   ,p_lang_id           NUMBER
   ,p_upd_mes_if_exists NUMBER DEFAULT c_true
  );

  /**
  *  Добавляет/изменяет в таблице сообщений информацию о сообщении
  *  @author Filipp Ganichev
  *  @param p_message_brief Краткое имя, идентифицирующее сообщение
  *  @param p_message_name Текст сообщения с параметрами. Параметры в тексте указываются в виде %имя_параметра
  *  @param p_lang_brief Краткое наименование языка в таблице lang
  *  @param p_upd_mes_if_exists Если параметр равен c_true, то текст сообщения будет изменен, если сообщение уже есть в таблице, иначе будет сгенерирована исключительная ситуация
  */
  PROCEDURE register_message
  (
    p_message_brief     VARCHAR2
   ,p_message_name      VARCHAR2
   ,p_lang_brief        VARCHAR2
   ,p_upd_mes_if_exists NUMBER DEFAULT c_true
  );
  /**
  *  Возвращает текст сообщения на заданном языке с подстановкой параметров
  *  @author Filipp Ganichev
  *  @param p_message_brief Краткое имя, идентифицирующее сообщение
  *  @param p_lang_id  Id языка в таблице lang
  *  @param p_token_name1 Наименование параметра
  *  @param p_token1 Значение параметра
  *  @param p_token_name2 Наименование параметра
  *  @param p_token2 Значение параметра
  *  @param p_token_name3 Наименование параметра
  *  @param p_token3 Значение параметра
  *  @param p_token_name4 Наименование параметра
  *  @param p_token4 Значение параметра
  *  @param p_token_name5 Наименование параметра
  *  @param p_token5 Значение параметра
  *  @return текст сообщения
  */
  FUNCTION get_message
  (
    p_message_brief VARCHAR2
   ,p_lang_id       NUMBER DEFAULT Ents.get_lang_id
   ,p_token_name1   VARCHAR2 DEFAULT miss_char
   ,p_token1        VARCHAR2 DEFAULT miss_char
   ,p_token_name2   VARCHAR2 DEFAULT miss_char
   ,p_token2        VARCHAR2 DEFAULT miss_char
   ,p_token_name3   VARCHAR2 DEFAULT miss_char
   ,p_token3        VARCHAR2 DEFAULT miss_char
   ,p_token_name4   VARCHAR2 DEFAULT miss_char
   ,p_token4        VARCHAR2 DEFAULT miss_char
   ,p_token_name5   VARCHAR2 DEFAULT miss_char
   ,p_token5        VARCHAR2 DEFAULT miss_char
  ) RETURN VARCHAR2;

  /**
  *  Возвращает текст сообщения на заданном языке с подстановкой параметров
  *  @author Filipp Ganichev
  *  @param p_message_brief Краткое имя, идентифицирующее сообщение
  *  @param p_lang_id  Id языка в таблице lang
  *  @param p_token1 Значение 1-го параметра
  *  @param p_token2 Значение 2-го параметра
  *  @param p_token3 Значение 3-го параметра
  *  @param p_token4 Значение 4-го параметра
  *  @param p_token5 Значение 5-го параметра
  *  @return Текст сообщения
  */
  FUNCTION get_mes1
  (
    p_message_brief VARCHAR2
   ,p_lang_id       NUMBER DEFAULT Ents.get_lang_id
   ,p_token1        VARCHAR2 DEFAULT miss_char
   ,p_token2        VARCHAR2 DEFAULT miss_char
   ,p_token3        VARCHAR2 DEFAULT miss_char
   ,p_token4        VARCHAR2 DEFAULT miss_char
   ,p_token5        VARCHAR2 DEFAULT miss_char
  ) RETURN VARCHAR2;

  /**
  *  Возвращает текст сообщения на заданном языке с подстановкой параметров
  *  @author Filipp Ganichev
  *  @param p_message_brief Краткое имя, идентифицирующее сообщение
  *  @param p_token1 Значение 1-го параметра
  *  @param p_token2 Значение 2-го параметра
  *  @param p_token3 Значение 3-го параметра
  *  @param p_token4 Значение 4-го параметра
  *  @param p_token5 Значение 5-го параметра
  *  @return Текст сообщения
  */
  FUNCTION get_mes
  (
    p_message_brief VARCHAR2
   ,p_token1        VARCHAR2 DEFAULT miss_char
   ,p_token2        VARCHAR2 DEFAULT miss_char
   ,p_token3        VARCHAR2 DEFAULT miss_char
   ,p_token4        VARCHAR2 DEFAULT miss_char
   ,p_token5        VARCHAR2 DEFAULT miss_char
  ) RETURN VARCHAR2;

  /**
  *  Возвращает текст сообщения на заданном языке с подстановкой параметров
  *  @author Filipp Ganichev
  *  @param p_message_brief Краткое имя, идентифицирующее сообщение
  *  @param p_lang_brief Id языка в таблице lang
  *  @param p_token_name1 Наименование параметра
  *  @param p_token1 Значение параметра
  *  @param p_token_name2 Наименование параметра
  *  @param p_token2 Значение параметра
  *  @param p_token_name3 Наименование параметра
  *  @param p_token3 Значение параметра
  *  @param p_token_name4 Наименование параметра
  *  @param p_token4 Значение параметра
  *  @param p_token_name5 Наименование параметра
  *  @param p_token5 Значение параметра
  *  @return Текст сообщения
  */
  FUNCTION get_message
  (
    p_message_brief VARCHAR2
   ,p_lang_brief    VARCHAR2
   ,p_token_name1   VARCHAR2 DEFAULT miss_char
   ,p_token1        VARCHAR2 DEFAULT miss_char
   ,p_token_name2   VARCHAR2 DEFAULT miss_char
   ,p_token2        VARCHAR2 DEFAULT miss_char
   ,p_token_name3   VARCHAR2 DEFAULT miss_char
   ,p_token3        VARCHAR2 DEFAULT miss_char
   ,p_token_name4   VARCHAR2 DEFAULT miss_char
   ,p_token4        VARCHAR2 DEFAULT miss_char
   ,p_token_name5   VARCHAR2 DEFAULT miss_char
   ,p_token5        VARCHAR2 DEFAULT miss_char
  ) RETURN VARCHAR2;

  /**
  *  Генерация исключения с сообщением на заданном языке с подстановкой параметров
  *  @author Filipp Ganichev
  *  @param p_message_brief Краткое имя, идентифицирующее сообщение
  *  @p_error_code Код ошибки
  *  @p_text Текст сообщения
  *  @param p_token1 Значение 1-го параметра
  *  @param p_token2 Значение 2-го параметра
  *  @param p_token3 Значение 3-го параметра
  *  @param p_token4 Значение 4-го параметра
  *  @param p_token5 Значение 5-го параметра
  */
  PROCEDURE raise_err
  (
    p_message_brief VARCHAR2
   ,p_error_code    NUMBER
   ,p_text          VARCHAR2
   ,p_token1        VARCHAR2 DEFAULT miss_char
   ,p_token2        VARCHAR2 DEFAULT miss_char
   ,p_token3        VARCHAR2 DEFAULT miss_char
   ,p_token4        VARCHAR2 DEFAULT miss_char
   ,p_token5        VARCHAR2 DEFAULT miss_char
  );

  /**
  * Генерация исключения сущности с сообщением на заданном языке с подстановкой параметров
  * @author Patsan O.
  * @param p_error_code Код ошибки
  * @param p_text Текст сообщения
  * @param p_ent_id ИД сущности
  */
  PROCEDURE raise_entity_err
  (
    p_error_code NUMBER
   ,p_text       VARCHAR2
   ,p_ent_id     IN NUMBER DEFAULT NULL
  );

  /**
  * Перевод целого числа в пропись
  * @author Patsan O.
  * @param dig Число
  * @param sex Род (M/F) валюты
  * @return Сумма прописью
  */
  FUNCTION int2speech
  (
    dig IN NUMBER
   ,sex IN VARCHAR2
  ) RETURN VARCHAR2;

  /**
  * Перевод дробного числа в пропись
  * @author Patsan O.
  * @param value Число
  * @param sex Род (M/F) валюты
  * @return Сумма прописью
  */
  FUNCTION float2speech
  (
    VALUE IN NUMBER
   ,sex   IN VARCHAR2
   ,POWER IN INTEGER
  ) RETURN VARCHAR2;

  /**
  * Перевод целого числа в пропись
  * @author Patsan O.
  * @param dig Число
  * @param sex Род (M/F) валюты
  * @return Сумма прописью
  */
  FUNCTION inttospeech
  (
    dig IN NUMBER
   ,sex IN VARCHAR2
  ) RETURN VARCHAR2;

  /**
  * Перевод суммы в пропись
  * @author Patsan O.
  * @param quant Число
  * @param p_fund_id ИД валюты
  * @return Сумма прописью
  */
  FUNCTION money2speech
  (
    quant     IN NUMBER
   ,p_fund_id IN NUMBER
  ) RETURN VARCHAR2;

  /**
  * Дата в родительном падеже
  * @author Patsan O.
  * @param p_date Дата
  * @return Дата в родительном падеже
  */
  FUNCTION date2genitive_case(p_date DATE) RETURN VARCHAR2;

  /** 
  * Месяц в родительном падеже
  * @author Patsan O.
  * @param p_date Дата
  * @param p_caps 0-название с маленькой буквы, 1-с большой
  * @return Месяц в родительном падеже
  */
  FUNCTION month_declension
  (
    p_date DATE
   ,p_caps NUMBER DEFAULT 0
  ) RETURN VARCHAR2;

  /**
  * Разбор ФИО на составные части
  * @author Patsan O.
  * @param ФИО
  * @param Фамилия
  * @param Имя
  * @param Отчество
  */
  PROCEDURE fio2full_name
  (
    p_fio         IN VARCHAR2
   ,p_last_name   OUT VARCHAR2
   ,p_first_name  OUT VARCHAR2
   ,p_middle_name OUT VARCHAR2
  );

  /**
  * Выполнение PLS-SQL и возврат значения
  * @author Patsan O.
  * @param p_sql Текст исполняемого кода
  * @param p_in Значение входящего параметра
  * @param p_out Значение исходящего параметра
  */
  PROCEDURE return_from_select
  (
    p_sql IN VARCHAR2
   ,p_in  IN NUMBER
   ,p_out OUT VARCHAR2
  );

  /**
  * Выполнение PLS-SQL и возврат значения
  * @author Patsan O.
  * @param p_sql Текст исполняемого кода
  * @param res Значение исходящего параметра
  */
  PROCEDURE exec_immediate
  (
    p_sql IN VARCHAR2
   ,res   OUT NUMBER
  );

  /**
  * Замена символов и обрезание пробелов
  * @author Patsan O.
  * @param str Исходная строка
  * @param symb Заменяемый символ
  * @param symbto Заменяющий символ
  * @param dotrim Признак необходимости обрезания пробелов (Y/N)
  * @return Измененная строка
  */
  FUNCTION replaceall
  (
    str    IN VARCHAR2
   ,symb   IN VARCHAR2 DEFAULT ',,'
   ,symbto IN VARCHAR2 DEFAULT ','
   ,dotrim IN CHAR DEFAULT 'Y'
  ) RETURN VARCHAR2;

  /** 
  * Создание/изменение переменной в хэш-массив. Используется в частности для передачи параметров в процедуры вызываемые при смене статусов
  *  @author Ф. Ганичев
  * @param key_val Ключ переменной
  * @param value Значение переменной
  */
  PROCEDURE put
  (
    key_val VARCHAR2
   ,VALUE   VARCHAR2
  );

  /** 
  * Получение значения переменной из хэш-массива. Используется в частности для передачи параметров в процедуры вызываемые при смене статусов
  * @author Ф. Ганичев
  * @param key_val Ключ переменной
  * @return Значение переменной, если значения соответствующего ключу нет, то no_data_found
  */
  FUNCTION get(key_val VARCHAR2) RETURN VARCHAR2;

  /** 
  * Получение значения переменной из хэш-массива. Используется в частности для передачи параметров в процедуры вызываемые при смене статусов
  * @author Ф. Ганичев
  * @param key_val Ключ переменной
  * @return Значение переменной, если значения соответствующего ключу нет, то null
  */
  FUNCTION get_null
  (
    key_val     VARCHAR2
   ,default_val VARCHAR2 DEFAULT NULL
  ) RETURN VARCHAR2;

  FUNCTION get_null
  (
    collection  hashmap_t
   ,key_val     VARCHAR2
   ,default_val VARCHAR2 DEFAULT NULL
  ) RETURN VARCHAR2;

  /** 
  * Очищает хэщ
  * @author Ф. Ганичев
  */
  PROCEDURE CLEAR;

  /** 
  * COMMIT
  * @author Ф. Ганичев
  */
  PROCEDURE cm;

  /** 
    Падежная форма ФИО (Surname, Name and Patronymic in Case form)
    @autor valerytin, hexcept@narod.ru, 2003-11-18
    @param p_fio строка,содержащая фамилию,имя и отчество
    @param p_padzh падеж (бувквы русскиe): 'р'|'Р'-родительный, 'д'|'Д'-дательный,etc., либо цифры: 1-именительный, 2-родительный, 3-дательный, etc. 
    @param p_fio_fmt формат входной строки-ФИО (т.е.'Алексей Немов'->'ИФ','Ольга Львовна Гидова-Бережная'->'ИОФ',etc.)
    @param p_sex -- пол 'ж'|'Ж'|'м'|'М'
    @return Падежная форма ФИО 
  */
  FUNCTION snp_case
  (
    p_fio     IN VARCHAR2
   ,p_padzh   IN VARCHAR2
   ,p_fio_fmt IN VARCHAR2 DEFAULT 'ФИО'
   ,p_sex     IN VARCHAR2 DEFAULT NULL
  ) RETURN VARCHAR2;
  /** 
    Дата прописью)
    @autor Alex Khomich
    @param for_convert DATE, конвертируемая дата
    @param question_suffix NUMBER default 2: 'Вопрос: Какого? - двадцать второОГО (значение параметра 2); Какое? - двадцать вторОЕ (значение параметра 1)
    @return Символьное представление даты VACHAR2(100)
  */
  FUNCTION date2speach
  (
    for_convert     DATE
   ,question_suffix NUMBER DEFAULT 2
  ) RETURN VARCHAR2;

  /**
  *  Возвращает количество дней в указанном периоде
  *  @author D.Syrovetskiy
  *  @param p_start_date Начальная дата в периоде
  *  @parem p_end_date Конечная дата в периоде (может быть пустой)
  *  @return Количество дней в периоде
  */
  FUNCTION get_count_days
  (
    p_start_date DATE
   ,p_end_date   DATE DEFAULT NULL
  ) RETURN NUMBER;

  PROCEDURE sleep(p_delay NUMBER);

END;
/
CREATE OR REPLACE PACKAGE BODY Utils IS

  hashmap hashmap_t;
  PROCEDURE put
  (
    key_val VARCHAR2
   ,VALUE   VARCHAR2
  ) IS
  BEGIN
    hashmap(key_val) := VALUE;
  END;
  FUNCTION get(key_val VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN hashmap(key_val);
  END;

  FUNCTION get_null
  (
    key_val     VARCHAR2
   ,default_val VARCHAR2 DEFAULT NULL
  ) RETURN VARCHAR2 IS
  BEGIN
    RETURN hashmap(key_val);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN default_val;
  END;

  FUNCTION get_null
  (
    collection  hashmap_t
   ,key_val     VARCHAR2
   ,default_val VARCHAR2 DEFAULT NULL
  ) RETURN VARCHAR2 IS
  BEGIN
    RETURN collection(key_val);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN default_val;
  END;

  PROCEDURE CLEAR IS
  BEGIN
    hashmap.DELETE;
  END;

  FUNCTION get_true RETURN NUMBER IS
  BEGIN
    RETURN c_true;
  END;

  FUNCTION get_false RETURN NUMBER IS
  BEGIN
    RETURN c_false;
  END;

  FUNCTION get_miss_char RETURN VARCHAR2 IS
  BEGIN
    RETURN miss_char;
  END;

  FUNCTION get_miss_num RETURN NUMBER IS
  BEGIN
    RETURN miss_num;
  END;

  FUNCTION get_miss_date RETURN DATE IS
  BEGIN
    RETURN miss_date;
  END;

  FUNCTION int2speech
  (
    dig IN NUMBER
   ,sex IN VARCHAR2
  ) RETURN VARCHAR2 IS
    ret       VARCHAR2(300);
    REMAINDER NUMBER;
  BEGIN
    REMAINDER := TRUNC(MOD(dig, 1000) / 100);
  
    SELECT DECODE(REMAINDER
                 ,1
                 ,'сто '
                 ,2
                 ,'двести '
                 ,3
                 ,'триста '
                 ,4
                 ,'четыреста '
                 ,5
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
      FROM DUAL;
  
    REMAINDER := TRUNC(MOD(dig, 100) / 10);
  
    SELECT ret || DECODE(REMAINDER
                        ,1
                        ,DECODE(MOD(dig, 10)
                               ,0
                               ,'десять '
                               ,1
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
                        ,8
                        ,'восемьдесят '
                        ,9
                        ,'девяносто ')
      INTO ret
      FROM DUAL;
  
    IF REMAINDER = 1
    THEN
      RETURN ret;
    END IF;
  
    REMAINDER := MOD(dig, 10);
  
    SELECT ret || DECODE(REMAINDER
                        ,1
                        ,DECODE(UPPER(sex), 'M', 'один ', 'F', 'одна ')
                        ,2
                        ,DECODE(UPPER(sex), 'M', 'два ', 'F', 'две ')
                        ,3
                        ,'три '
                        ,4
                        ,'четыре '
                        ,5
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
      FROM DUAL;
  
    RETURN ret;
  END;

  FUNCTION float2speech
  (
    VALUE IN NUMBER
   ,sex   IN VARCHAR2
   ,POWER IN INTEGER
  ) RETURN VARCHAR2 IS
    ret VARCHAR2(300);
    p   VARCHAR2(1);
    i   INTEGER;
  BEGIN
    IF POWER = 0
    THEN
      ret := '';
      p   := sex;
      i   := -1;
    ELSE
      IF POWER > 1
      THEN
        p := 'M';
      ELSE
        p := 'F';
      END IF;
    
      i := TRUNC(VALUE);
    
      IF TRUNC(MOD(i, 100) / 10) = 1
      THEN
        i := 5;
      ELSE
        i := MOD(i, 10);
      END IF;
    
      IF i = 1
      THEN
        SELECT DECODE(p, 'M', ' ', 'F', 'а ') || ret INTO ret FROM DUAL;
      ELSIF (i >= 2)
            AND (i <= 4)
      THEN
        SELECT DECODE(p, 'M', 'а ', 'F', 'и ') || ret INTO ret FROM DUAL;
      ELSE
        SELECT DECODE(p, 'M', 'ов ', 'F', ' ') || ret INTO ret FROM DUAL;
      END IF;
    
      IF (TRUNC(VALUE) MOD 1000) <> 0
      THEN
        SELECT DECODE(POWER
                     ,1
                     ,'тысяч'
                     ,2
                     ,'миллион'
                     ,3
                     ,'миллиард'
                     ,4
                     ,'триллион') || ret
          INTO ret
          FROM DUAL;
      END IF;
    END IF;
  
    ret := int2speech(TRUNC(VALUE) MOD 1000, p) || ret;
  
    IF VALUE >= 1000
    THEN
      ret := float2speech(VALUE / 1000, p, POWER + 1) || ret;
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
    ret := float2speech(ABS(dig), sex, 0);
  
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
    v_fund        FUND%ROWTYPE;
  BEGIN
    SELECT * INTO v_fund FROM FUND f WHERE f.fund_id = p_fund_id;
  
    v_whole_value := ROUND(quant, 2);
    v_fract_value := ABS(v_whole_value - TRUNC(v_whole_value)) * 100;
    v_whole_value := TRUNC(v_whole_value);
    v_last_digit  := TO_NUMBER(SUBSTR(TO_CHAR(v_whole_value), LENGTH(TO_CHAR(v_whole_value)), 1));
  
    IF (LENGTH(TO_CHAR(v_whole_value)) > 1)
    THEN
      IF SUBSTR(TO_CHAR(v_whole_value), LENGTH(TO_CHAR(v_whole_value)) - 1, 1) = '1'
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
    v_last_digit  := TO_NUMBER(SUBSTR(TO_CHAR(v_fract_value), LENGTH(TO_CHAR(v_fract_value)), 1));
  
    IF (LENGTH(TO_CHAR(v_fract_value)) > 1)
    THEN
      IF SUBSTR(TO_CHAR(v_fract_value), LENGTH(TO_CHAR(v_fract_value)) - 1, 1) = '1'
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
    ret           := TRIM(inttospeech(v_whole_value, 'm')) || ' ' || TRIM(v_whole_brief) || ' ' ||
                     TRIM(TO_CHAR(v_fract_value, '00')) || ' ' || TRIM(v_fract_brief);
    RETURN NLS_UPPER(SUBSTR(ret, 1, 1)) || SUBSTR(ret, 2);
  END;

  FUNCTION date2genitive_case(p_date DATE) RETURN VARCHAR2 IS
  BEGIN
    RETURN TO_CHAR(p_date, 'dd') || ' ' ||(CASE TO_NUMBER(TO_CHAR(p_date, 'mm')) WHEN 1 THEN 'января' WHEN 2 THEN
                                           'февраля' WHEN 3 THEN 'марта' WHEN 4 THEN 'апреля' WHEN 5 THEN
                                           'мая' WHEN 6 THEN 'июня' WHEN 7 THEN 'июля' WHEN 8 THEN
                                           'августа' WHEN 9 THEN 'сентября' WHEN 10 THEN 'октября' WHEN 11 THEN
                                           'ноября' WHEN 12 THEN 'декабря' ELSE '' END) || ' ' || TO_CHAR(p_date
                                                                                                         ,'yyyy') || ' года';
  END;

  FUNCTION month_declension
  (
    p_date DATE
   ,p_caps NUMBER DEFAULT 0
  ) RETURN VARCHAR2 IS
    RESULT  VARCHAR2(50);
    p_month NUMBER;
  BEGIN
    p_month := TO_NUMBER(TO_CHAR(p_date, 'mm'));
    CASE p_month
      WHEN 1 THEN
        SELECT DECODE(p_caps, 0, 'я', 'Я') || 'нваря' INTO RESULT FROM dual;
      WHEN 2 THEN
        SELECT DECODE(p_caps, 0, 'ф', 'Ф') || 'евраля' INTO RESULT FROM dual;
      WHEN 3 THEN
        SELECT DECODE(p_caps, 0, 'м', 'М') || 'арта' INTO RESULT FROM dual;
      WHEN 4 THEN
        SELECT DECODE(p_caps, 0, 'а', 'А') || 'преля' INTO RESULT FROM dual;
      WHEN 5 THEN
        SELECT DECODE(p_caps, 0, 'м', 'М') || 'ая' INTO RESULT FROM dual;
      WHEN 6 THEN
        SELECT DECODE(p_caps, 0, 'и', 'И') || 'юня' INTO RESULT FROM dual;
      WHEN 7 THEN
        SELECT DECODE(p_caps, 0, 'и', 'И') || 'юля' INTO RESULT FROM dual;
      WHEN 8 THEN
        SELECT DECODE(p_caps, 0, 'а', 'А') || 'вгуста' INTO RESULT FROM dual;
      WHEN 9 THEN
        SELECT DECODE(p_caps, 0, 'с', 'С') || 'ентября' INTO RESULT FROM dual;
      WHEN 10 THEN
        SELECT DECODE(p_caps, 0, 'о', 'О') || 'ктября' INTO RESULT FROM dual;
      WHEN 11 THEN
        SELECT DECODE(p_caps, 0, 'н', 'Н') || 'оября' INTO RESULT FROM dual;
      WHEN 12 THEN
        SELECT DECODE(p_caps, 0, 'д', 'Д') || 'екабря' INTO RESULT FROM dual;
      ELSE
        RETURN '';
    END CASE;
    RETURN RESULT;
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
    i      := INSTR(v_name, ' ');
  
    IF i > 0
    THEN
      p_last_name := TRIM(SUBSTR(v_name, 1, i - 1));
      v_name      := TRIM(SUBSTR(v_name, i + 1, LENGTH(v_name) - i));
      i           := INSTR(v_name, '.');
    
      IF i = 0
      THEN
        i := INSTR(v_name, ' ');
      END IF;
    
      IF i > 0
      THEN
        p_first_name := TRIM(SUBSTR(v_name, 1, i - 1));
        v_name       := TRIM(SUBSTR(v_name, i + 1, LENGTH(v_name) - i));
        i            := INSTR(v_name, '.');
      
        IF i = 0
        THEN
          i := INSTR(v_name, ' ');
        END IF;
      
        IF i > 0
        THEN
          p_middle_name := TRIM(SUBSTR(v_name, 1, i - 1));
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
    EXECUTE IMMEDIATE p_sql
      USING OUT p_out, IN p_in;
  END;

  FUNCTION get_lang_id(p_lang_brief VARCHAR2) RETURN VARCHAR2 IS
    v_lang_id NUMBER;
  BEGIN
    BEGIN
      SELECT lang_id INTO v_lang_id FROM LANG WHERE brief = p_lang_brief;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20100, 'Не найден язык');
    END;
  
    RETURN v_lang_id;
  END;

  PROCEDURE register_message
  (
    p_message_brief     VARCHAR2
   ,p_message_name      VARCHAR2
   ,p_lang_id           NUMBER
   ,p_upd_mes_if_exists NUMBER DEFAULT c_true
  ) IS
    v_lang_id       NUMBER := NULL;
    v_message_brief VARCHAR2(200);
  BEGIN
    v_lang_id := p_lang_id;
  
    BEGIN
      SELECT brief
        INTO v_message_brief
        FROM SYS_MESSAGE
       WHERE lang_id = v_lang_id
         AND brief = p_message_brief;
    
      IF p_upd_mes_if_exists != c_true
      THEN
        RAISE_APPLICATION_ERROR(-20100
                               ,'Сообщение ' || v_message_brief || ' уже существует');
      END IF;
    
      UPDATE SYS_MESSAGE
         SET NAME = p_message_name
       WHERE lang_id = v_lang_id
         AND brief = v_message_brief;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        INSERT INTO SYS_MESSAGE
          (sys_message_id, lang_id, brief, NAME)
        VALUES
          (sq_message.NEXTVAL, v_lang_id, p_message_brief, p_message_name);
    END;
  
    COMMIT;
  END;

  PROCEDURE register_message
  (
    p_message_brief     VARCHAR2
   ,p_message_name      VARCHAR2
   ,p_lang_brief        VARCHAR2
   ,p_upd_mes_if_exists NUMBER DEFAULT c_true
  ) IS
    v_lang_id       NUMBER := NULL;
    v_message_brief VARCHAR2(200);
  BEGIN
    v_lang_id := get_lang_id(p_lang_brief);
  
    BEGIN
      SELECT brief
        INTO v_message_brief
        FROM SYS_MESSAGE
       WHERE lang_id = v_lang_id
         AND brief = p_message_brief;
    
      IF p_upd_mes_if_exists != c_true
      THEN
        RAISE_APPLICATION_ERROR(-20100
                               ,'Сообщение ' || v_message_brief || ' уже существует');
      END IF;
    
      UPDATE SYS_MESSAGE
         SET NAME = p_message_name
       WHERE lang_id = v_lang_id
         AND brief = v_message_brief;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        INSERT INTO SYS_MESSAGE
          (sys_message_id, lang_id, brief, NAME)
        VALUES
          (sq_message.NEXTVAL, v_lang_id, p_message_brief, p_message_name);
    END;
  
    COMMIT;
  END;

  FUNCTION GET_MESSAGE
  (
    p_message_brief VARCHAR2
   ,p_lang_id       NUMBER DEFAULT Ents.get_lang_id
   ,p_token_name1   VARCHAR2 DEFAULT miss_char
   ,p_token1        VARCHAR2 DEFAULT miss_char
   ,p_token_name2   VARCHAR2 DEFAULT miss_char
   ,p_token2        VARCHAR2 DEFAULT miss_char
   ,p_token_name3   VARCHAR2 DEFAULT miss_char
   ,p_token3        VARCHAR2 DEFAULT miss_char
   ,p_token_name4   VARCHAR2 DEFAULT miss_char
   ,p_token4        VARCHAR2 DEFAULT miss_char
   ,p_token_name5   VARCHAR2 DEFAULT miss_char
   ,p_token5        VARCHAR2 DEFAULT miss_char
  ) RETURN VARCHAR2 IS
    v_lang_id NUMBER;
    v_message VARCHAR2(4000);
  BEGIN
    v_lang_id := p_lang_id;
  
    BEGIN
      SELECT NAME
        INTO v_message
        FROM SYS_MESSAGE
       WHERE lang_id = v_lang_id
         AND brief = p_message_brief;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20100
                               ,'Сообщение ' || p_message_brief || ' для языка с ID = ' || v_lang_id ||
                                ' не найдено');
    END;
  
    IF p_token_name1 != miss_char
    THEN
      v_message := REPLACE(v_message, '%' || p_token_name1, p_token1);
    END IF;
  
    IF p_token_name2 != miss_char
    THEN
      v_message := REPLACE(v_message, '%' || p_token_name2, p_token2);
    END IF;
  
    IF p_token_name3 != miss_char
    THEN
      v_message := REPLACE(v_message, '%' || p_token_name3, p_token3);
    END IF;
  
    IF p_token_name4 != miss_char
    THEN
      v_message := REPLACE(v_message, '%' || p_token_name4, p_token4);
    END IF;
  
    IF p_token_name5 != miss_char
    THEN
      v_message := REPLACE(v_message, '%' || p_token_name5, p_token5);
    END IF;
  
    RETURN v_message;
  END;

  FUNCTION GET_MESSAGE
  (
    p_message_brief VARCHAR2
   ,p_lang_brief    VARCHAR2
   ,p_token_name1   VARCHAR2 DEFAULT miss_char
   ,p_token1        VARCHAR2 DEFAULT miss_char
   ,p_token_name2   VARCHAR2 DEFAULT miss_char
   ,p_token2        VARCHAR2 DEFAULT miss_char
   ,p_token_name3   VARCHAR2 DEFAULT miss_char
   ,p_token3        VARCHAR2 DEFAULT miss_char
   ,p_token_name4   VARCHAR2 DEFAULT miss_char
   ,p_token4        VARCHAR2 DEFAULT miss_char
   ,p_token_name5   VARCHAR2 DEFAULT miss_char
   ,p_token5        VARCHAR2 DEFAULT miss_char
  ) RETURN VARCHAR2 IS
    v_lang_id NUMBER;
  BEGIN
    v_lang_id := get_lang_id(p_lang_brief);
    RETURN GET_MESSAGE(p_message_brief
                      ,v_lang_id
                      ,p_token_name1
                      ,p_token1
                      ,p_token_name2
                      ,p_token2
                      ,p_token_name3
                      ,p_token3
                      ,p_token_name4
                      ,p_token4
                      ,p_token_name5
                      ,p_token5);
  END;

  FUNCTION get_mes1
  (
    p_message_brief VARCHAR2
   ,p_lang_id       NUMBER DEFAULT Ents.get_lang_id
   ,p_token1        VARCHAR2 DEFAULT miss_char
   ,p_token2        VARCHAR2 DEFAULT miss_char
   ,p_token3        VARCHAR2 DEFAULT miss_char
   ,p_token4        VARCHAR2 DEFAULT miss_char
   ,p_token5        VARCHAR2 DEFAULT miss_char
  ) RETURN VARCHAR2 IS
    v_lang_id    NUMBER;
    v_token_name VARCHAR(100);
    v_token      VARCHAR(1000);
    v_message    VARCHAR2(4000);
    start_pos    NUMBER;
    stop_pos     NUMBER;
    i            NUMBER := 1;
  BEGIN
    v_lang_id := p_lang_id;
  
    BEGIN
      SELECT NAME
        INTO v_message
        FROM SYS_MESSAGE
       WHERE lang_id = v_lang_id
         AND brief = p_message_brief;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20100
                               ,'Сообщение ' || p_message_brief || ' для языка с ID = ' || v_lang_id ||
                                ' не найдено');
    END;
  
    LOOP
      start_pos := INSTR(v_message, '%');
    
      IF start_pos != 0
      THEN
        stop_pos := INSTR(v_message, ' ', start_pos);
      
        IF stop_pos = 0
        THEN
          stop_pos := LENGTH(v_message);
        END IF;
      
        v_token_name := SUBSTR(v_message, start_pos, stop_pos - start_pos);
      
        IF i = 1
        THEN
          v_token := p_token1;
        ELSIF i = 2
        THEN
          v_token := p_token2;
        ELSIF i = 3
        THEN
          v_token := p_token3;
        ELSIF i = 4
        THEN
          v_token := p_token4;
        ELSIF i = 5
        THEN
          v_token := p_token5;
        ELSE
          RAISE_APPLICATION_ERROR(-20100
                                 ,'Поддерживается не более 5 параметров сообщения');
        END IF;
      
        i         := i + 1;
        v_message := REPLACE(v_message, v_token_name, v_token);
      ELSE
        EXIT;
      END IF;
    END LOOP;
  
    RETURN v_message;
  END;

  FUNCTION get_mes
  (
    p_message_brief VARCHAR2
   ,p_token1        VARCHAR2 DEFAULT miss_char
   ,p_token2        VARCHAR2 DEFAULT miss_char
   ,p_token3        VARCHAR2 DEFAULT miss_char
   ,p_token4        VARCHAR2 DEFAULT miss_char
   ,p_token5        VARCHAR2 DEFAULT miss_char
  ) RETURN VARCHAR2 IS
  BEGIN
    RETURN get_mes1(p_message_brief
                   ,Ents.get_lang_id
                   ,p_token1
                   ,p_token2
                   ,p_token3
                   ,p_token4
                   ,p_token5);
  END;

  PROCEDURE raise_err
  (
    p_message_brief VARCHAR2
   ,p_error_code    NUMBER
   ,p_text          VARCHAR2
   ,p_token1        VARCHAR2 DEFAULT miss_char
   ,p_token2        VARCHAR2 DEFAULT miss_char
   ,p_token3        VARCHAR2 DEFAULT miss_char
   ,p_token4        VARCHAR2 DEFAULT miss_char
   ,p_token5        VARCHAR2 DEFAULT miss_char
  ) IS
    v_err      VARCHAR2(4000) := NULL;
    v_err_code NUMBER := NVL(p_error_code, -20100);
  BEGIN
    IF is_empty(p_message_brief) = c_false
    THEN
      v_err := get_mes(p_message_brief, p_token1, p_token2, p_token3, p_token4, p_token5);
    END IF;
  
    IF is_empty(p_text) = c_false
    THEN
      IF v_err IS NULL
      THEN
        v_err := p_text;
      ELSE
        v_err := v_err || CHR(10) || p_text;
      END IF;
    END IF;
  
    RAISE_APPLICATION_ERROR(v_err_code, v_err);
  END;

  PROCEDURE raise_entity_err
  (
    p_error_code NUMBER
   ,p_text       VARCHAR2
   ,p_ent_id     IN NUMBER DEFAULT NULL
  ) IS
    v_err VARCHAR2(4000);
  BEGIN
    v_err := Ents.TRANS_ERR(p_error_code, p_text, p_ent_id);
    raise_err(NULL, -20000, v_err);
  END;

  FUNCTION is_empty(p_value NUMBER) RETURN NUMBER IS
  BEGIN
    IF p_value IS NULL
       OR p_value = miss_num
    THEN
      RETURN c_true;
    END IF;
  
    RETURN c_false;
  END;

  FUNCTION is_empty(p_value VARCHAR2) RETURN NUMBER IS
  BEGIN
    IF p_value IS NULL
       OR p_value = miss_char
    THEN
      RETURN c_true;
    END IF;
  
    RETURN c_false;
  END;

  FUNCTION is_empty(p_value DATE) RETURN NUMBER IS
  BEGIN
    IF p_value IS NULL
       OR p_value = miss_date
    THEN
      RETURN c_true;
    END IF;
  
    RETURN c_false;
  END;

  PROCEDURE exec_immediate
  (
    p_sql IN VARCHAR2
   ,res   OUT NUMBER
  ) IS
  BEGIN
    EXECUTE IMMEDIATE p_sql;
  
    res := 1;
  EXCEPTION
    WHEN OTHERS THEN
      res := 0;
  END;

  -- Заменяем в строке все символы symb на symbto (убираем сдвоенные символы) и вконце делаем  trim
  FUNCTION replaceall
  (
    str    IN VARCHAR2
   ,symb   IN VARCHAR2 DEFAULT ',,'
   ,symbto IN VARCHAR2 DEFAULT ','
   ,dotrim IN CHAR DEFAULT 'Y'
  ) RETURN VARCHAR2 IS
    TMP  VARCHAR2(4000);
    tmp1 VARCHAR2(4000);
  BEGIN
    DBMS_OUTPUT.PUT_LINE('str=' || str);
    IF str IS NOT NULL
       AND LENGTH(str) > 0
    THEN
      TMP := str;
    
      LOOP
        tmp1 := TMP;
        TMP  := REPLACE(TMP, symb, symbto);
        EXIT WHEN tmp1 = TMP;
      END LOOP;
    
      IF dotrim = 'Y'
      THEN
        IF LENGTH(str) > 0
        THEN
          TMP := TRIM(TMP);
          TMP := TRIM(symbto FROM TMP);
        END IF;
      END IF;
    
      RETURN TMP;
    ELSE
      RETURN '';
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN '';
  END;
  /*IF (str <> '') and (str IS NOT NULL)
     THEN RETURN '2';
    ELSE
        tmp := str;
        DBMS_OUTPUT.put_line ('1');
  
        LOOP
           tmp1 := tmp;
           tmp := REPLACE (tmp, symb, symbto);
           EXIT WHEN tmp1 = tmp;
        END LOOP;
  
        IF dotrim = 'Y'
        THEN
           IF tmp <> ''
           THEN
              tmp := TRIM (tmp);
              tmp := TRIM (symbto FROM tmp);
           END IF;
        END IF;
  
        RETURN tmp;
     END IF;
  EXCEPTION
     WHEN OTHERS
     THEN
        RETURN '5';
  END;*/
  PROCEDURE cm IS
  BEGIN
    COMMIT;
  END;

  FUNCTION snp_case
  (
    -- Падежная форма ФИО (Surname, Name and Patronymic in Case form)
    -- valerytin, hexcept@narod.ru, 2003-11-18
    p_fio   IN VARCHAR2
   , -- строка,содержащая фамилию,имя и отчество
    p_padzh IN VARCHAR2
   , -- падеж (бувквы русскиe): 'р'|'Р'-родительный,
    -- 'д'|'Д'-дательный,etc., либо цифры:
    -- 1-именительный, 2-родительный, 3-дательный, etc. 
    p_fio_fmt IN VARCHAR2 DEFAULT 'ФИО'
   , -- формат входной строки-ФИО (т.е.
    -- 'Алексей Немов'->'ИФ',
    -- 'Ольга Львовна Гидова-Бережная'->
    -- 'ИОФ',etc.)
    p_sex IN VARCHAR2 DEFAULT NULL -- пол 'ж'|'Ж'|'м'|'М'
  ) RETURN VARCHAR2 -- вывод в нужном падеже
   IS
    l_pdzh_chr VARCHAR2(1);
    l_pdzh     PLS_INTEGER;
    l_sex      VARCHAR2(1) := SUBSTR(LTRIM(LOWER(p_sex)), 1, 1);
    l_tailchr  VARCHAR2(1);
    l_nmlen    NUMBER(2, 0);
    l_ul       VARCHAR2(1) := 'N';
    l_uf       VARCHAR2(1) := 'N';
    l_um       VARCHAR2(1) := 'N';
    l_name_s   VARCHAR2(80);
    l_name_n   VARCHAR2(80) := NULL;
    l_name_p   VARCHAR2(80) := NULL;
    l_fio      VARCHAR2(500);
    l_fname    VARCHAR2(80);
    l_mname    VARCHAR2(80);
    l_fullname VARCHAR2(500) := LTRIM(RTRIM(p_fio, ' -'), ' -');
    l_pos      PLS_INTEGER;
    l_fio_fmt  VARCHAR2(3) := NVL(UPPER(SUBSTR(LTRIM(p_fio_fmt), 1, 3)), 'ФИО');
    --
    FUNCTION single_space
    (
      p_data VARCHAR2
     ,p_dv   VARCHAR2 DEFAULT ' '
    ) RETURN VARCHAR2 IS
      v_str VARCHAR2(2000) := p_data;
    BEGIN
      WHILE INSTR(v_str, p_dv || p_dv) > 0
      LOOP
        v_str := REPLACE(v_str, p_dv || p_dv, p_dv);
      END LOOP;
      RETURN v_str;
    END single_space;
    --
    FUNCTION term_cmp
    (
      s IN VARCHAR2
     ,t IN VARCHAR2
    ) RETURN BOOLEAN IS
    BEGIN
      IF NVL(LENGTH(s), 0) < NVL(LENGTH(t), 0)
      THEN
        RETURN FALSE;
      END IF;
      IF SUBSTR(LOWER(s), -LENGTH(t)) = t
      THEN
        RETURN TRUE;
      ELSE
        RETURN FALSE;
      END IF;
    END term_cmp;
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
        SELECT SUBSTR(s, 1, LENGTH(s) - n) ||
               DECODE(l_pdzh, 2, pzrod, 3, pzdat, 4, pzvin, 5, pztvo, 6, pzpre)
          INTO s
          FROM dual;
      END IF;
    END chng;
    --
    PROCEDURE prep
    (
      fnm  IN OUT VARCHAR2
     ,lfm2 IN OUT VARCHAR2
    ) IS
      pp VARCHAR2(1) := SUBSTR(lfm2, 1, 1);
      nm VARCHAR2(80);
    BEGIN
      l_pos := INSTR(fnm, ' ');
      IF l_pos > 0
      THEN
        nm    := SUBSTR(fnm, 1, l_pos - 1);
        fnm   := LTRIM(SUBSTR(fnm, l_pos + 1));
        l_pos := INSTR(fnm, ' ');
      ELSE
        nm  := fnm;
        fnm := NULL;
      END IF;
      IF pp = 'Ф'
      THEN
        l_name_s := nm;
        lfm2     := REPLACE(lfm2, 'Ф');
      ELSIF pp = 'И'
      THEN
        l_fname := nm;
        lfm2    := REPLACE(lfm2, 'И');
      ELSIF pp = 'О'
      THEN
        l_mname := nm;
        lfm2    := REPLACE(lfm2, 'О');
      END IF;
    END;
    --
  BEGIN
    -- snp_case()
    l_fullname := REPLACE(REPLACE(single_space(l_fullname), ' -', '-'), '- ', '-');
    IF l_fullname IS NULL
    THEN
      RETURN p_fio;
    END IF;
    IF SUBSTR(l_fio_fmt, 1, 1) NOT IN ('Ф', 'И', 'О')
    THEN
      RETURN p_fio;
    END IF;
    IF NVL(SUBSTR(l_fio_fmt, 2, 1), 'Ф') NOT IN ('Ф', 'И', 'О')
    THEN
      RETURN p_fio;
    END IF;
    IF NVL(SUBSTR(l_fio_fmt, 3, 1), 'Ф') NOT IN ('Ф', 'И', 'О')
    THEN
      RETURN p_fio;
    END IF;
    -- оглы, кызы:
    IF LOWER(LTRIM(RTRIM(l_fullname))) LIKE '%оглы%'
       AND LENGTH(l_fullname) > 4
    THEN
      l_name_p   := SUBSTR(l_fullname, INSTR(LOWER(l_fullname), 'оглы'), 4);
      l_fullname := REPLACE(REPLACE(REPLACE(REPLACE(l_fullname, 'оглы', NULL), 'Оглы', NULL)
                                   ,'ОГЛЫ'
                                   ,NULL)
                           ,'  '
                           ,' ');
      l_sex      := NVL(l_sex, 'м');
    ELSIF LOWER(LTRIM(RTRIM(l_fullname))) LIKE '%кызы%'
          AND LENGTH(l_fullname) > 4
    THEN
      l_name_p   := SUBSTR(l_fullname, INSTR(LOWER(l_fullname), 'кызы'), 4);
      l_fullname := REPLACE(REPLACE(REPLACE(REPLACE(l_fullname, 'кызы', NULL), 'Кызы', NULL)
                                   ,'КЫЗЫ'
                                   ,NULL)
                           ,'  '
                           ,' ');
      l_sex      := NVL(l_sex, 'ж');
    END IF;
    LOOP
      IF l_fullname IS NOT NULL
      THEN
        prep(l_fullname, l_fio_fmt);
      ELSE
        EXIT;
      END IF;
    END LOOP;
    l_nmlen    := NVL(LENGTH(l_name_s), 0);
    l_pdzh_chr := UPPER(SUBSTR(p_padzh, 1, 1));
    SELECT DECODE(l_pdzh_chr, 'И', 1, 'Р', 2, 'Д', 3, 'В', 4, 'Т', 5, 'П', 6, 0)
      INTO l_pdzh
      FROM dual;
    IF l_pdzh = 0
    THEN
      BEGIN
        l_pdzh := TO_NUMBER(l_pdzh_chr);
      EXCEPTION
        WHEN OTHERS THEN
          RETURN p_fio;
      END;
    END IF;
    IF NVL(l_sex, 'z') NOT IN ('м', 'ж')
    THEN
      -- если пол не определен,
      -- то пробуем определить его по отчеству:
      IF l_mname IS NOT NULL
         AND (UPPER(SUBSTR(l_mname, -1)) = 'Ч' OR LOWER(l_name_p) LIKE 'оглы')
      THEN
        l_sex := 'м';
      ELSE
        l_sex := 'ж';
      END IF;
    END IF;
    IF l_name_s IS NOT NULL
    THEN
      -- фамилия
      IF UPPER(l_name_s) = l_name_s
      THEN
        l_ul := 'Y';
      END IF;
      -- Предусмотрим обработку сдвоенной фамилии:
      IF INSTR(l_name_s, '-') > 0
         AND LOWER(l_name_s) NOT LIKE 'тер-%'
      THEN
        l_name_n := SUBSTR(l_name_s, 1, INSTR(l_name_s, '-') - 1) || ' ' || l_fname || ' ' || l_mname;
        l_fio    := snp_case(l_name_n, p_padzh, 'ФИО', l_sex);
        l_name_n := SUBSTR(l_fio, 1, INSTR(l_fio, ' ') - 1) || '-';
        l_name_s := SUBSTR(l_name_s, INSTR(l_name_s, '-') + 1);
      END IF;
      l_tailchr := LOWER(SUBSTR(l_name_s, -1));
      IF l_sex = 'м'
      THEN
        -- мужчины
        IF l_tailchr NOT IN ('о', 'е', 'у', 'ю', 'и', 'э', 'ы')
        THEN
          IF l_tailchr = 'в'
          THEN
            chng(l_name_s, 0, 'а', 'у', 'а', 'ым', 'е');
          ELSIF l_tailchr = 'н'
                AND term_cmp(l_name_s, 'ин')
          THEN
            chng(l_name_s, 0, 'а', 'у', 'а', 'ым', 'е');
          ELSIF l_tailchr = 'ц'
                AND term_cmp(l_name_s, 'ец')
          THEN
            IF l_nmlen > 3
               AND SUBSTR(l_name_s, -3) IN ('аец', 'еец', 'иец', 'оец', 'уец')
            THEN
              chng(l_name_s, 2, 'йца', 'йцу', 'йца', 'йцем', 'йце');
            ELSIF l_nmlen > 3
                  AND LOWER(SUBSTR(l_name_s, -3)) IN
                  ('тец', 'бец', 'вец', 'мец', 'нец', 'рец', 'сец')
                  AND LOWER(SUBSTR(l_name_s, -4, 1)) IN
                  ('а', 'е', 'и', 'о', 'у', 'ы', 'э', 'ю', 'я', 'ё')
            THEN
              chng(l_name_s, 2, 'ца', 'цу', 'ца', 'цом', 'це');
            ELSIF l_nmlen > 3
                  AND LOWER(SUBSTR(l_name_s, -3)) = 'лец'
            THEN
              chng(l_name_s, 2, 'ьца', 'ьцу', 'ьца', 'ьцом', 'ьце');
            ELSE
              chng(l_name_s, 0, 'а', 'у', 'а', 'ом', 'е');
            END IF;
          ELSIF l_tailchr = 'х'
                AND (term_cmp(l_name_s, 'их') OR term_cmp(l_name_s, 'ых'))
          THEN
            chng(l_name_s, 0, NULL, NULL, NULL, NULL, NULL);
          ELSIF l_tailchr IN ('б'
                             ,'г'
                             ,'д'
                             ,'ж'
                             ,'з'
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
            chng(l_name_s, 0, 'а', 'у', 'а', 'ом', 'е');
          ELSIF l_tailchr = 'я'
                AND NOT (term_cmp(l_name_s, 'ия') OR term_cmp(l_name_s, 'ая'))
          THEN
            chng(l_name_s, 1, 'и', 'е', 'ю', 'ей', 'е');
          ELSIF l_tailchr = 'а'
                AND NOT (term_cmp(l_name_s, 'иа') OR term_cmp(l_name_s, 'уа'))
          THEN
            chng(l_name_s, 1, 'и', 'е', 'у', 'ой', 'е');
          ELSIF l_tailchr = 'ь'
          THEN
            chng(l_name_s, 1, 'я', 'ю', 'я', 'ем', 'е');
          ELSIF l_tailchr = 'к'
          THEN
            IF l_nmlen > 4
               AND term_cmp(l_name_s, 'ок')
            THEN
              chng(l_name_s, 2, 'ка', 'ку', 'ка', 'ком', 'ке');
            ELSIF l_nmlen > 4
                  AND (term_cmp(l_name_s, 'лек') OR term_cmp(l_name_s, 'рек'))
            THEN
              chng(l_name_s, 2, 'ька', 'ьку', 'ька', 'ьком', 'ьке');
            ELSE
              chng(l_name_s, 0, 'а', 'у', 'а', 'ом', 'е');
            END IF;
          ELSIF l_tailchr = 'й'
          THEN
            IF l_nmlen > 4
            THEN
              IF (term_cmp(l_name_s, 'кий') OR term_cmp(l_name_s, 'кий'))
              THEN
                chng(l_name_s, 2, 'ого', 'ому', 'ого', 'им', 'ом');
              ELSIF term_cmp(l_name_s, 'ой')
              THEN
                chng(l_name_s, 2, 'ого', 'ому', 'ого', 'им', 'ом');
              ELSIF term_cmp(l_name_s, 'ый')
              THEN
                chng(l_name_s, 2, 'ого', 'ому', 'ого', 'ым', 'ом');
              ELSIF LOWER(SUBSTR(l_name_s, -3)) IN ('рий'
                                                   ,'жий'
                                                   ,'лий'
                                                   ,'вий'
                                                   ,'дий'
                                                   ,'бий'
                                                   ,'гий'
                                                   ,'зий'
                                                   ,'мий'
                                                   ,'ний'
                                                   ,'пий'
                                                   ,'сий'
                                                   ,'фий'
                                                   ,'хий')
              THEN
                chng(l_name_s, 1, 'я', 'ю', 'я', 'ем', 'и');
              ELSIF term_cmp(l_name_s, 'ий')
              THEN
                chng(l_name_s, 2, 'его', 'ему', 'его', 'им', 'им');
              ELSE
                chng(l_name_s, 1, 'я', 'ю', 'я', 'ем', 'е');
              END IF;
            ELSE
              chng(l_name_s, 1, 'я', 'ю', 'я', 'ем', 'е');
            END IF;
          END IF;
        END IF;
      ELSIF l_sex = 'ж'
      THEN
        -- женщины
        IF LOWER(SUBSTR(l_name_s, -3)) IN ('ова', 'ева', 'ына', 'ина', 'ена')
        THEN
          chng(l_name_s, 1, 'ой', 'ой', 'у', 'ой', 'ой');
        ELSIF term_cmp(l_name_s, 'ая')
              AND LOWER(SUBSTR(l_name_s, -3, 1)) IN ('ц')
        THEN
          chng(l_name_s, 2, 'ей', 'ей', 'ую', 'ей', 'ей');
        ELSIF term_cmp(l_name_s, 'ая')
        THEN
          chng(l_name_s, 2, 'ой', 'ой', 'ую', 'ой', 'ой');
        ELSIF term_cmp(l_name_s, 'ля')
              OR term_cmp(l_name_s, 'ня')
        THEN
          chng(l_name_s, 1, 'и', 'е', 'ю', 'ей', 'е');
        ELSIF term_cmp(l_name_s, 'а')
              AND LOWER(SUBSTR(l_name_s, -2, 1)) IN ('д')
        THEN
          chng(l_name_s, 1, 'ы', 'е', 'у', 'ой', 'е');
        END IF;
      END IF;
    END IF;
    IF l_fname IS NOT NULL
    THEN
      -- имя
      IF UPPER(l_fname) = l_fname
      THEN
        l_uf := 'Y';
      END IF;
      l_tailchr := LOWER(SUBSTR(l_fname, -1));
      IF l_sex = 'м'
      THEN
        -- мужчины
        IF l_tailchr NOT IN ('е', 'и', 'у')
        THEN
          IF UPPER(l_fname) = 'ЛЕВ'
          THEN
            chng(l_fname, 2, 'ьва', 'ьву', 'ьва', 'ьвом', 'ьве');
          ELSIF l_tailchr IN ('б'
                             ,'в'
                             ,'г'
                             ,'д'
                             ,'з'
                             ,'ж'
                             ,'к'
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
            chng(l_fname, 0, 'а', 'у', 'а', 'ом', 'е');
          ELSIF l_tailchr = 'а'
          THEN
            chng(l_fname, 1, 'ы', 'е', 'у', 'ой', 'е');
          ELSIF l_tailchr = 'о'
          THEN
            chng(l_fname, 1, 'а', 'у', 'а', 'ом', 'е');
          ELSIF l_tailchr = 'я'
          THEN
            IF term_cmp(l_fname, 'ья')
            THEN
              chng(l_fname, 1, 'и', 'е', 'ю', 'ей', 'е');
            ELSIF term_cmp(l_fname, 'ия')
            THEN
              chng(l_fname, 1, 'и', 'е', 'ю', 'ей', 'е');
            ELSE
              chng(l_fname, 1, 'и', 'е', 'ю', 'ей', 'е');
            END IF;
          ELSIF l_tailchr = 'й'
          THEN
            IF term_cmp(l_fname, 'ай')
            THEN
              chng(l_fname, 1, 'я', 'ю', 'я', 'ем', 'е');
            ELSE
              IF term_cmp(l_fname, 'ей')
              THEN
                chng(l_fname, 1, 'я', 'ю', 'я', 'ем', 'е');
              ELSE
                chng(l_fname, 1, 'я', 'ю', 'я', 'ем', 'и');
              END IF;
            END IF;
          ELSIF l_tailchr = 'ь'
          THEN
            chng(l_fname, 1, 'я', 'ю', 'я', 'ем', 'е');
          ELSIF l_tailchr = 'л'
          THEN
            IF term_cmp(l_fname, 'авел')
            THEN
              chng(l_fname, 2, 'ла', 'лу', 'ла', 'лом', 'ле');
            ELSE
              chng(l_fname, 0, 'а', 'у', 'а', 'ом', 'е');
            END IF;
          END IF;
        END IF;
      ELSIF l_sex = 'ж'
      THEN
        -- женщины
        IF l_tailchr = 'а'
           AND NVL(LENGTH(l_fname), 0) > 1
        THEN
          IF LOWER(SUBSTR(l_fname, -2)) IN ('га', 'ха', 'ка', 'ша', 'ча', 'ща', 'жа')
          THEN
            chng(l_fname, 1, 'и', 'е', 'у', 'ой', 'е');
          ELSE
            chng(l_fname, 1, 'ы', 'е', 'у', 'ой', 'е');
          END IF;
        ELSIF l_tailchr = 'я'
              AND NVL(LENGTH(l_fname), 0) > 1
        THEN
          IF term_cmp(l_fname, 'ия')
             AND LOWER(SUBSTR(l_fname, -4)) IN ('ьфия')
          THEN
            chng(l_fname, 1, 'и', 'е', 'ю', 'ей', 'е');
          ELSIF term_cmp(l_fname, 'ия')
          THEN
            chng(l_fname, 1, 'и', 'и', 'ю', 'ей', 'и');
          ELSE
            chng(l_fname, 1, 'и', 'е', 'ю', 'ей', 'е');
          END IF;
        ELSIF l_tailchr = 'ь'
        THEN
          IF term_cmp(l_fname, 'вь')
          THEN
            chng(l_fname, 1, 'и', 'и', 'ь', 'ью', 'и');
          ELSE
            chng(l_fname, 1, 'и', 'и', 'ь', 'ью', 'ье');
          END IF;
        END IF;
      END IF;
    END IF;
    IF l_mname IS NOT NULL
    THEN
      -- отчество
      IF UPPER(l_mname) = l_mname
      THEN
        l_um := 'Y';
      END IF;
      l_tailchr := LOWER(SUBSTR(l_mname, -1));
      IF l_sex = 'м'
      THEN
        -- мужчины
        IF l_tailchr = 'ч'
        THEN
          chng(l_mname, 0, 'а', 'у', 'а', 'ем', 'е');
        END IF;
      ELSIF l_sex = 'ж'
      THEN
        -- женщины
        IF l_tailchr = 'а'
           AND LENGTH(l_mname) <> 1
        THEN
          chng(l_mname, 1, 'ы', 'е', 'у', 'ой', 'е');
        END IF;
      END IF;
    END IF;
    -- окончательная конкатенация
    l_fio_fmt := NVL(UPPER(SUBSTR(LTRIM(p_fio_fmt), 1, 3)), 'ФИО'); -- м.б. рекурсия...
    l_pos     := 1;
    LOOP
      IF l_pos > 1
      THEN
        l_fullname := l_fullname || ' ';
      END IF;
      SELECT l_fullname ||
             DECODE(SUBSTR(l_fio_fmt, l_pos, 1)
                   ,'Ф'
                   ,DECODE(l_ul, 'Y', UPPER(l_name_n || l_name_s), l_name_n || l_name_s)
                   ,'И'
                   ,DECODE(l_uf, 'Y', UPPER(l_fname), l_fname)
                   ,'О'
                   ,DECODE(l_um
                          ,'Y'
                          ,UPPER(REPLACE(REPLACE(l_mname, 'оглы', NULL), 'кызы', NULL) ||
                                 DECODE(INSTR(l_mname, '-'), 0, ' ', NULL) || l_name_p)
                          ,REPLACE(REPLACE(l_mname, 'оглы', NULL), 'кызы', NULL) ||
                           DECODE(INSTR(l_mname, '-'), 0, ' ', NULL) || l_name_p))
        INTO l_fullname
        FROM dual;
      l_pos := l_pos + 1;
      IF l_pos > NVL(LENGTH(l_fio_fmt), 0)
      THEN
        EXIT;
      END IF;
    END LOOP;
    RETURN NVL(LTRIM(RTRIM(l_fullname, ' -'), ' -'), LTRIM(RTRIM(single_space(p_fio), ' -'), ' -'));
  END snp_case;

  FUNCTION date2speach
  (
    for_convert     DATE
   ,question_suffix NUMBER DEFAULT 2
  ) RETURN VARCHAR2 IS
    TYPE date_root_t IS TABLE OF VARCHAR2(30) INDEX BY PLS_INTEGER;
  
    date_root_v    date_root_t;
    converted_date VARCHAR2(100);
    day_num        PLS_INTEGER;
    day_simple     PLS_INTEGER;
    millenium      PLS_INTEGER;
    year_num       PLS_INTEGER;
    year_simple    PLS_INTEGER;
    suffix_day     VARCHAR2(5);
    third_day      VARCHAR2(10);
    suffix_year    VARCHAR2(5);
    third_year     VARCHAR2(10);
  
    FUNCTION two_dig_to_str
    (
      full_dig   PLS_INTEGER
     ,simple_dig PLS_INTEGER
     ,is_day     BOOLEAN
    ) RETURN VARCHAR2 IS
      converted_dig VARCHAR2(50) DEFAULT '';
      suffix        VARCHAR2(5);
      third         VARCHAR2(10);
    BEGIN
      IF is_day
      THEN
        suffix := suffix_day;
        third  := third_day;
      ELSE
        suffix := suffix_year;
        third  := third_year;
      END IF;
    
      IF full_dig < 20
      THEN
        CASE
          WHEN simple_dig = 3
               AND full_dig <> 13 THEN
            converted_dig := converted_dig || third;
          ELSE
            converted_dig := date_root_v(full_dig) || suffix;
        END CASE;
      ELSE
        IF simple_dig <> 0
        THEN
          converted_dig := date_root_v(TRUNC(full_dig, -1)) || ' ';
        
          IF simple_dig = 3
          THEN
            converted_dig := converted_dig || third;
          ELSE
            converted_dig := converted_dig || date_root_v(simple_dig) || suffix;
          END IF;
        ELSE
          converted_dig := converted_dig || date_root_v(-full_dig) || suffix;
        END IF;
      END IF;
    
      RETURN converted_dig;
    END two_dig_to_str;
  BEGIN
    -- инициаализация лексического массива
    date_root_v(0) := '';
    date_root_v(1) := 'перв';
    date_root_v(2) := 'втор';
    date_root_v(3) := 'трет';
    date_root_v(4) := 'четвёрт';
    date_root_v(5) := 'пят';
    date_root_v(6) := 'шест';
    date_root_v(7) := 'седьм';
    date_root_v(8) := 'восьм';
    date_root_v(9) := 'девят';
    date_root_v(10) := 'десят';
    date_root_v(11) := 'одиннадцат';
    date_root_v(12) := 'двенадцат';
    date_root_v(13) := 'тринадцат';
    date_root_v(14) := 'четырнадцат';
    date_root_v(15) := 'пятнадцат';
    date_root_v(16) := 'шестнадцат';
    date_root_v(17) := 'семнадцат';
    date_root_v(18) := 'восемнадцат';
    date_root_v(19) := 'девятнадцат';
    date_root_v(20) := 'двадцать';
    date_root_v(30) := 'тридцать';
    date_root_v(40) := 'cорок';
    date_root_v(50) := 'пятьдесят';
    date_root_v(60) := 'шестьдесят';
    date_root_v(70) := 'семьдесят';
    date_root_v(80) := 'восемьдесят';
    date_root_v(90) := 'девяносто';
    date_root_v(-20) := 'двадцат';
    date_root_v(-30) := 'тридцат';
    date_root_v(-40) := 'сороков';
    date_root_v(-50) := 'пятидесят';
    date_root_v(-60) := 'шестидесят';
    date_root_v(-70) := 'семидесят';
    date_root_v(-80) := 'восьмидесят';
    date_root_v(-90) := 'девяност';
  
    CASE question_suffix
      WHEN 1 THEN
        suffix_day := 'ое ';
        third_day  := 'третье ';
      WHEN 2 THEN
        suffix_day := 'ого ';
        third_day  := 'третьего ';
      ELSE
        RAISE NO_DATA_FOUND;
    END CASE;
  
    suffix_year := 'ого ';
    third_year  := 'третьего ';
    --день
    day_num        := TO_NUMBER(EXTRACT(DAY FROM for_convert));
    day_simple     := MOD(day_num, 10);
    converted_date := two_dig_to_str(day_num, day_simple, TRUE);
  
    --месяц
    CASE TO_NUMBER(EXTRACT(MONTH FROM for_convert))
      WHEN 1 THEN
        converted_date := converted_date || 'января';
      WHEN 2 THEN
        converted_date := converted_date || 'февраля';
      WHEN 3 THEN
        converted_date := converted_date || 'марта';
      WHEN 4 THEN
        converted_date := converted_date || 'апреля';
      WHEN 5 THEN
        converted_date := converted_date || 'мая';
      WHEN 6 THEN
        converted_date := converted_date || 'июня';
      WHEN 7 THEN
        converted_date := converted_date || 'июля';
      WHEN 8 THEN
        converted_date := converted_date || 'августа';
      WHEN 9 THEN
        converted_date := converted_date || 'сентября';
      WHEN 10 THEN
        converted_date := converted_date || 'октября';
      WHEN 11 THEN
        converted_date := converted_date || 'ноября';
      WHEN 12 THEN
        converted_date := converted_date || 'декабря';
      ELSE
        converted_date := converted_date;
    END CASE;
    -- тысячелетие 
    millenium   := TRUNC(TO_NUMBER(EXTRACT(YEAR FROM for_convert)) / 1000);
    year_num    := MOD(MOD(TO_NUMBER(EXTRACT(YEAR FROM for_convert)), 1000), 100);
    year_simple := MOD(year_num, 10);
  
    CASE millenium
      WHEN 1 THEN
        converted_date := converted_date || ' одна тысяча девятьсот ';
      WHEN 2 THEN
        converted_date := converted_date || ' две тысячи  ';
      ELSE
        converted_date := converted_date;
    END CASE;
    -- год 
    converted_date := converted_date || two_dig_to_str(year_num, year_simple, FALSE);
    RETURN converted_date;
  
  END date2speach;
  --------------------------------------------------------------------------------
  --------------------------------------------------------------------------------
  FUNCTION get_count_days
  (
    p_start_date DATE
   ,p_end_date   DATE DEFAULT NULL
  ) RETURN NUMBER IS
    v_bd    DATE;
    v_ed    DATE;
    v_count NUMBER;
    v_year  VARCHAR2(4);
  BEGIN
    v_count := 0;
    v_bd    := TRUNC(p_start_date);
    IF p_end_date IS NOT NULL
    THEN
      v_ed := TRUNC(p_end_date);
    ELSE
      --вторую дату нужно вернуть через год
    
      v_ed := v_bd + 365;
    
      v_year := TO_CHAR(v_bd, 'yyyy');
    
      IF MOD(TO_NUMBER(v_year), 4) = 0
      THEN
        -- високосный год
        IF TO_DATE('2902' || v_year, 'ddmmyyyy') >= v_bd
        THEN
          v_ed := v_ed + 1;
        END IF;
      END IF;
    
      v_year := TO_CHAR(v_ed, 'yyyy');
    
      IF MOD(TO_NUMBER(v_year), 4) = 0
      THEN
        -- високосный год
        IF TO_DATE('2902' || v_year, 'ddmmyyyy') <= v_ed
        THEN
          v_ed := v_ed + 1;
        END IF;
      END IF;
    
    END IF;
  
    BEGIN
      v_count := v_ed - v_bd;
    EXCEPTION
      WHEN OTHERS THEN
        v_count := 0;
    END;
  
    RETURN v_count;
  
  END;

  PROCEDURE sleep(p_delay NUMBER) IS
  BEGIN
    dbms_lock.sleep(p_delay);
  END;

END;
/
